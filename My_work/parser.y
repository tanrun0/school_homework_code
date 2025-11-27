%{
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <iostream>
#include <vector>

using namespace std;

int yylex();
void yyerror(const char *s);
extern int yylineno;

struct Node {
    string tag;
    vector<Node*> children;
    string value;
    Node(const string& t): tag(t) {}
    Node(const string& t, const string &v): tag(t), value(v) {}
};

Node *root = nullptr;

Node *make_node(const string &t, Node *c1=nullptr, Node *c2=nullptr) {
    Node *n = new Node(t);
    if (c1) n->children.push_back(c1);
    if (c2) n->children.push_back(c2);
    return n;
}

void print_node(Node* n, int indent=0) {
    if (!n) return;
    for (int i=0;i<indent;i++) cout<<"  ";
    cout << n->tag;
    if (!n->value.empty()) cout << ": " << n->value;
    cout << '\n';
    for (auto c : n->children) print_node(c, indent+1);
}

%}

%union {
    char *symbol;
    int integer;
    bool boolean;
    Node *node;
    char *error_msg;
}

%token <symbol> TYPEID OBJECTID STR_CONST
%token <integer> INT_CONST
%token <boolean> BOOL_CONST
%token CLASS INHERITS LET IN IF THEN ELSE FI
%token WHILE LOOP POOL CASE OF ESAC NEW ISVOID NOT
%token ASSIGN LE ERROR
%token DARROW

%start program
%type <node> program class_list class feature_list feature expr expr_list expr_block_list case_list case_branch formal_list formal

%%

program: class_list { root = $1; }
;

class_list: class { $$ = $1; }
         | class_list class { $$ = make_node("Classes", $1, $2); }
;

class: CLASS TYPEID '{' feature_list '}' ';' { $$ = make_node("Class", new Node("type", $2), $4); }
     | CLASS TYPEID INHERITS TYPEID '{' feature_list '}' ';' { $$ = make_node("ClassInherits", new Node("type", $2), new Node("parent", $4)); }
     | error ';' { $$ = make_node("ClassError"); }
;

feature_list: /* empty */ { $$ = make_node("FeaturesEmpty"); }
            | feature_list feature ';' { $$ = make_node("Features", $1, $2); }
;

feature: OBJECTID '(' formal_list ')' ':' TYPEID '{' expr '}' { $$ = make_node("Method", new Node("name", $1), $4); }
       | OBJECTID ':' TYPEID { $$ = make_node("Attr", new Node("name", $1), new Node("type", $3)); }
       | OBJECTID ':' TYPEID ASSIGN expr { $$ = make_node("AttrAssign", new Node("name", $1), $5); }
;

formal_list: /* empty */ { $$ = make_node("FormalsEmpty"); }
           | formal { $$ = make_node("Formals", $1); }
           | formal_list ',' formal { $$ = make_node("FormalsList", $1, $3); }
;

formal: OBJECTID ':' TYPEID { $$ = make_node("Formal", new Node("name", $1), new Node("type", $3)); }
;

expr_list: /* empty */ { $$ = make_node("ExprsEmpty"); }
         | expr { $$ = make_node("Exprs", $1); }
         | expr_list ',' expr { $$ = make_node("ExprsList", $1, $3); }
;

expr_block_list: expr ';' { $$ = make_node("Block", $1); }
               | expr_block_list expr ';' { $$ = make_node("BlockList", $1, $2); }
;

expr: OBJECTID ASSIGN expr { $$ = make_node("Assign", new Node("name", $1), $3); }
    | expr '.' OBJECTID '(' expr_list ')' { $$ = make_node("Dispatch", $1, new Node("method", $3)); }
    | OBJECTID '(' expr_list ')' { $$ = make_node("StaticDispatch", new Node("object", new Node("self")), new Node("method", $1)); }
    | IF expr THEN expr ELSE expr FI { $$ = make_node("If", $2, $4); }
    | WHILE expr LOOP expr POOL { $$ = make_node("While", $2, $4); }
    | '{' expr_block_list '}' { $$ = make_node("Block", $2); }
    | LET OBJECTID ':' TYPEID IN expr { $$ = make_node("Let", new Node("name", $2), new Node("type", $4), $6); }
    | expr '+' expr { $$ = make_node("Plus", $1, $3); }
    | expr '-' expr { $$ = make_node("Minus", $1, $3); }
    | expr '*' expr { $$ = make_node("Mul", $1, $3); }
    | expr '/' expr { $$ = make_node("Div", $1, $3); }
    | '~' expr { $$ = make_node("Neg", $2); }
    | expr '<' expr { $$ = make_node("Lt", $1, $3); }
    | expr '=' expr { $$ = make_node("Eq", $1, $3); }
    | expr LE expr { $$ = make_node("Leq", $1, $3); }
    | NOT expr { $$ = make_node("Not", $2); }
    | ISVOID expr { $$ = make_node("Isvoid", $2); }
    | NEW TYPEID { $$ = make_node("New", new Node("type", $2)); }
    | INT_CONST { $$ = new Node("Int", to_string($1)); }
    | BOOL_CONST { $$ = new Node("Bool", $1 ? "true" : "false"); }
    | STR_CONST { $$ = new Node("Str", $1); }
    | OBJECTID { $$ = new Node("Object", $1); }
    | '(' expr ')' { $$ = $2; }
;

case_list: case_branch { $$ = make_node("CaseList", $1); }
         | case_list case_branch { $$ = make_node("CaseList", $1, $2); }
;

case_branch: OBJECTID ':' TYPEID DARROW expr ';' { $$ = make_node("CaseBranch", new Node("name", $1), new Node("type", $3), $5); }
;

%%

void yyerror(const char *s) { fprintf(stderr, "Parse error at line %d: %s\n", yylineno, s); }

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { perror("open"); return 1; }
        extern FILE *yyin; yyin = f;
    }
    if (yyparse() == 0) {
        cout << "Parse succeeded" << endl;
        if (root) print_node(root);
    } else {
        cout << "Parse failed" << endl;
    }
    return 0;
}
