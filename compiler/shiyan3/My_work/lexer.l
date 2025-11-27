%option noyywrap yylineno
%{
#include "parser.tab.h"
#include <string>
#include <cstring>
#include <cstdio>
#include <cstdlib>

using namespace std;

extern int yylineno;
#define YY_USER_ACTION yylineno = yylineno; // keep line number

// helper to downcase
static string downcase(const string &s) {
    string res = s;
    for (char &c : res) c = tolower(c);
    return res;
}
%}

%option case-insensitive

DIGIT      [0-9]
ID_START   [A-Za-z_]
ID_REST    [A-Za-z0-9_]*
TYPEID     [A-Z][A-Za-z0-9_]*
OBJECTID   [a-z_][A-Za-z0-9_]*
INT        {DIGIT}+
// String: allow escape sequences, disallow newlines inside
STR        \"([^\\
\"]|\\.)*\"

%%
[ \t\r]+    ;  // skip whitespace
\n           { yylineno++; }

"class"      { return CLASS; }
"inherits"   { return INHERITS; }
"let"        { return LET; }
"in"         { return IN; }
"if"         { return IF; }
"then"       { return THEN; }
"else"       { return ELSE; }
"fi"         { return FI; }
"while"      { return WHILE; }
"loop"       { return LOOP; }
"pool"       { return POOL; }
"case"       { return CASE; }
"of"         { return OF; }
"esac"       { return ESAC; }
"new"        { return NEW; }
"isvoid"     { return ISVOID; }
"not"        { return NOT; }
"true"       { yylval.boolean = true; return BOOL_CONST; }
"false"      { yylval.boolean = false; return BOOL_CONST; }

"<-"          { return ASSIGN; }
"<="          { return LE; }
    "=>"          { return DARROW; }
"("           { return '('; }
")"           { return ')'; }
"{"           { return '{'; }
"}"           { return '}'; }
";"           { return ';'; }
":"           { return ':'; }
","           { return ','; }
"."           { return '.'; }
"@"           { return '@'; }
"+"           { return '+'; }
"-"           { return '-'; }
"*"           { return '*'; }
"/"           { return '/'; }
"<"           { return '<'; }
"="           { return '='; }
"~"           { return '~'; }

{TYPEID}       { yylval.symbol = strdup(yytext); return TYPEID; }
{OBJECTID}     { yylval.symbol = strdup(yytext); return OBJECTID; }

{INT}          { yylval.integer = atoi(yytext); return INT_CONST; }

{STR}    {
    std::string s = yytext;
    if (s.size() >= 2 && s.front() == '"' && s.back() == '"') {
        char *buf = strdup(s.substr(1, s.size()-2).c_str());
        yylval.symbol = buf;
        return STR_CONST;
    }
}

--.*            ;  // single-line comments
\(\*([^*]|\*+[^*)])*\*+\) ; // simple non-nested comments

.               { yylval.error_msg = strdup("illegal character"); return ERROR; }

%%

int yywrap() { return 1; }

