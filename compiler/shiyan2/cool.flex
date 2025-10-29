%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define ZUIDAZIFUCHUANCHANGDU 1024

#define CLASS 258
#define ELSE 259
#define FI 260
#define IF 261
#define IN 262
#define INHERITS 263
#define ISVOID 264
#define LET 265
#define LOOP 266
#define POOL 267
#define THEN 268
#define WHILE 269
#define CASE 270
#define ESAC 271
#define NEW 272
#define OF 273
#define NOT 274
#define BOOL_CONST 275
#define INT_CONST 276
#define STR_CONST 277
#define TYPEID 278
#define OBJECTID 279
#define ASSIGN 280
#define DARROW 281
#define LE 282
#define ERROR 283

typedef union {
    int boolean;
    char *symbol;
    const char *error_msg;
} YYSTYPE;

YYSTYPE kulouyylval;
int dangqianhanghao = 1;

char zifuchuanhuanchongqu[ZUIDAZIFUCHUANCHANGDU];
char *zifuchuanhuanchongquzhizhen;
static int zhushiqiancengshu;

void dayintoken(int token);
%}

%option noyywrap
%x ZIFUCHUAN
%x ZHUSHI

SHUZI [0-9]
XIAOXIEZIMU [a-z]
DAXIEZIMU [A-Z]
ZIMU [a-zA-Z]
ZIMUSHIZI [a-zA-Z0-9_]
FUZHI "<-"
XIAOYUDENGYU "<="
JIANTou "=>"

%%

[ \f\r\t\v]+ { }
\n { dangqianhanghao++; }

"--".* { }

"(*" { BEGIN(ZHUSHI); zhushiqiancengshu = 1; }
<ZHUSHI>"(*" { zhushiqiancengshu++; }
<ZHUSHI>"*)" { 
    zhushiqiancengshu--; 
    if (zhushiqiancengshu == 0) BEGIN(INITIAL); 
}
<ZHUSHI>\n { dangqianhanghao++; }
<ZHUSHI><<EOF>> { 
    kulouyylval.error_msg = "EOF in comment"; 
    BEGIN(INITIAL); 
    return ERROR; 
}
<ZHUSHI>. { }

"\"" { 
    BEGIN(ZIFUCHUAN); 
    zifuchuanhuanchongquzhizhen = zifuchuanhuanchongqu; 
}
<ZIFUCHUAN>"\"" { 
    *zifuchuanhuanchongquzhizhen = '\0';
    kulouyylval.symbol = strdup(zifuchuanhuanchongqu);
    BEGIN(INITIAL);
    return STR_CONST;
}
<ZIFUCHUAN>\\n { *zifuchuanhuanchongquzhizhen++ = '\n'; }
<ZIFUCHUAN>\\t { *zifuchuanhuanchongquzhizhen++ = '\t'; }
<ZIFUCHUAN>\\b { *zifuchuanhuanchongquzhizhen++ = '\b'; }
<ZIFUCHUAN>\\f { *zifuchuanhuanchongquzhizhen++ = '\f'; }
<ZIFUCHUAN>\\\" { *zifuchuanhuanchongquzhizhen++ = '"'; }
<ZIFUCHUAN>\\\\ { *zifuchuanhuanchongquzhizhen++ = '\\'; }
<ZIFUCHUAN>\n { 
    dangqianhanghao++; 
    kulouyylval.error_msg = "Unterminated string constant";
    BEGIN(INITIAL);
    return ERROR;
}
<ZIFUCHUAN><<EOF>> { 
    kulouyylval.error_msg = "EOF in string constant";
    BEGIN(INITIAL);
    return ERROR;
}
<ZIFUCHUAN>. { 
    if (zifuchuanhuanchongquzhizhen - zifuchuanhuanchongqu >= ZUIDAZIFUCHUANCHANGDU - 1) {
        kulouyylval.error_msg = "String constant too long";
        BEGIN(INITIAL);
        return ERROR;
    }
    *zifuchuanhuanchongquzhizhen++ = yytext[0];
}

[cC][lL][aA][sS][sS] { return CLASS; }
[eE][lL][sS][eE] { return ELSE; }
[fF][iI] { return FI; }
[iI][fF] { return IF; }
[iI][nN] { return IN; }
[iI][nN][hH][eE][rR][iI][tT][sS] { return INHERITS; }
[iI][sS][vV][oO][iI][dD] { return ISVOID; }
[lL][eE][tT] { return LET; }
[lL][oO][oO][pP] { return LOOP; }
[pP][oO][oO][lL] { return POOL; }
[tT][hH][eE][nN] { return THEN; }
[wW][hH][iI][lL][eE] { return WHILE; }
[cC][aA][sS][eE] { return CASE; }
[eE][sS][aA][cC] { return ESAC; }
[nN][eE][wW] { return NEW; }
[oO][fF] { return OF; }
[nN][oO][tT] { return NOT; }

[tT][rR][uU][eE] { kulouyylval.boolean = 1; return BOOL_CONST; }
[fF][aA][lL][sS][eE] { kulouyylval.boolean = 0; return BOOL_CONST; }

{DAXIEZIMU}{ZIMUSHIZI}* { 
    kulouyylval.symbol = strdup(yytext);
    return TYPEID;
}
{XIAOXIEZIMU}{ZIMUSHIZI}* { 
    kulouyylval.symbol = strdup(yytext);
    return OBJECTID;
}
{SHUZI}+ { 
    kulouyylval.symbol = strdup(yytext);
    return INT_CONST;
}

{FUZHI} { return ASSIGN; }
{XIAOYUDENGYU} { return LE; }
{JIANTou} { return DARROW; }

"+" { return '+'; }
"-" { return '-'; }
"*" { return '*'; }
"/" { return '/'; }
"<" { return '<'; }
"=" { return '='; }
"." { return '.'; }
"@" { return '@'; }
"," { return ','; }
";" { return ';'; }
":" { return ':'; }
"(" { return '('; }
")" { return ')'; }
"{" { return '{'; }
"}" { return '}'; }

"*)" { 
    kulouyylval.error_msg = "Unmatched *)";
    return ERROR;
}

. { 
    kulouyylval.error_msg = strdup(yytext);
    return ERROR;
}

%%

void dayintoken(int token) {
    printf("#%d ", dangqianhanghao);
    
    switch(token) {
        case CLASS: printf("CLASS"); break;
        case ELSE: printf("ELSE"); break;
        case FI: printf("FI"); break;
        case IF: printf("IF"); break;
        case IN: printf("IN"); break;
        case INHERITS: printf("INHERITS"); break;
        case ISVOID: printf("ISVOID"); break;
        case LET: printf("LET"); break;
        case LOOP: printf("LOOP"); break;
        case POOL: printf("POOL"); break;
        case THEN: printf("THEN"); break;
        case WHILE: printf("WHILE"); break;
        case CASE: printf("CASE"); break;
        case ESAC: printf("ESAC"); break;
        case NEW: printf("NEW"); break;
        case OF: printf("OF"); break;
        case NOT: printf("NOT"); break;
        case BOOL_CONST: printf("BOOL_CONST %s", kulouyylval.boolean ? "true" : "false"); break;
        case INT_CONST: printf("INT_CONST %s", kulouyylval.symbol); break;
        case STR_CONST: printf("STR_CONST %s", kulouyylval.symbol); break;
        case TYPEID: printf("TYPEID %s", kulouyylval.symbol); break;
        case OBJECTID: printf("OBJECTID %s", kulouyylval.symbol); break;
        case ASSIGN: printf("ASSIGN"); break;
        case DARROW: printf("DARROW"); break;
        case LE: printf("LE"); break;
        case ERROR: printf("ERROR \"%s\"", kulouyylval.error_msg); break;
        case '+': printf("'+'"); break;
        case '-': printf("'-'"); break;
        case '*': printf("'*'"); break;
        case '/': printf("'/'"); break;
        case '<': printf("'<'"); break;
        case '=': printf("'='"); break;
        case '.': printf("'.'"); break;
        case '@': printf("'@'"); break;
        case ',': printf("','"); break;
        case ';': printf("';'"); break;
        case ':': printf("':'"); break;
        case '(': printf("'('"); break;
        case ')': printf("')'"); break;
        case '{': printf("'{'"); break;
        case '}': printf("'}'"); break;
        default: printf("<UNKNOWN>"); break;
    }
    printf("\n");
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            fprintf(stderr, "无法打开文件: %s\n", argv[1]);
            return 1;
        }
        printf("#name \"%s\"\n", argv[1]);
    } else {
        printf("#name \"stdin\"\n");
    }
    
    int token;
    while ((token = yylex()) != 0) {
        dayintoken(token);
        if (token == ERROR) {
            break;
        }
    }
    
    if (yyin != stdin) {
        fclose(yyin);
    }
    
    return 0;
}