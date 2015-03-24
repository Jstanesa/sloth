%{
#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#define ID_SIZE 100
#define MAX_CHILDREN 3
#define STATEMENT 201
int yywrap( );
void yyerror(const char* str);
struct Node* make_node(int type, double value, char* id);
void attach_node(struct Node* parent, struct Node* child);

struct Node* tree;
/* a tree node definition */
struct Node {
  /* the type of the node */
  int type;

  /* the value of the node if it can have one */
  double value;

  /* the id of the node (used for identifiers only) */
  char id[ID_SIZE];

  /* at most three children nodes */
  int num_children;
  struct Node* children[MAX_CHILDREN];
};

%}
%token ENDLINE 115
%token ASSIGNMENT 116
%token START 119
%token END 120
%token IF 121
%token THEN 122
%token ELSE 123
%token WHILE 124
%token DO 125
%token PRINT 126
%token INPUT 127
%token <str> IDENTIFIER 100
%token <val> VALUE 101

%left OR 113
%left AND 112
%left LESS 106 LESSEQUAL 108 GREAT 107 GREATEQUAL 109 EQUAL 110 NOTEQUAL 111
%left PLUS 102 MINUS 103
%left STAR 105 SLASH 104
%right NOT 114
%right OPENPAREN 117
%left CLOSEPAREN 118
%union{
    double val;
    struct Node* node;
    char str[100];
}

%type <node> assignmentStmt
%type <node> ifStmt
%type <node> whileStmt
%type <node> ifElseStmt
%type <node> printStmt
%type <node> stmtSeq
%type <node> expr
%type <node> stmt
%type <node> stmts
/* give us more detailed errors */
%error-verbose

%%

program: stmts {
    /*tree = make_node(0,0,"");
      */
   tree = $1;
}
stmt: assignmentStmt {
	$$=$1;
      }
    | ifStmt {
	$$=$1;
    }
    | ifElseStmt {
	$$=$1;
    }
    | whileStmt {
	$$=$1;
    }
    | printStmt {
	//$$=make_node(STATEMENT,0,"");
	//attach_node($$,$1);
	$$=$1;
    }
    | stmtSeq {
	$$=$1;
    }

assignmentStmt: IDENTIFIER ASSIGNMENT expr ENDLINE {
		    $$=make_node(ASSIGNMENT,0,"");
		    struct Node* temp = make_node(IDENTIFIER,0,$1);
		    attach_node($$,temp);
		    attach_node($$,$3);
		}
ifStmt: IF expr THEN stmt {
	    $$=make_node(IF,0,"");
	    attach_node($$,$2);
	    attach_node($$,$4);
	}
ifElseStmt: IF expr THEN stmt ELSE stmt {
		$$=make_node(IF,0,"");
		attach_node($$,$2);
		attach_node($$,$4);
		attach_node($$,$6);
	    }
whileStmt: WHILE expr DO stmt {
	       $$=make_node(WHILE,0,"");
	       attach_node($$,$2);
	       attach_node($$,$4);
	   }
printStmt: PRINT expr ENDLINE {
	       $$=make_node(PRINT,0,"");
	       attach_node($$,$2);
	   }
stmtSeq: START stmts END {
	     $$=$2;
	 }
stmts: stmt {	
	$$=make_node(STATEMENT,0,"");
	attach_node($$,$1);
       }
    | stmt stmts {
	$$=make_node(STATEMENT,0,"");
	attach_node($$,$1);
	attach_node($$,$2);
    }

/* an expression uses + or - or neither */
expr: NOT expr{
	$$=make_node(NOT,0,"");
	attach_node($$,$2);
      }
    | expr PLUS expr {
      $$ = make_node(PLUS,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr MINUS expr {
      $$ = make_node(MINUS,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr STAR expr {
      $$ = make_node(STAR,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr SLASH expr {
      $$ = make_node(SLASH,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr LESS expr {
      $$ = make_node(LESS,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr LESSEQUAL expr {
      $$ = make_node(LESSEQUAL,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr GREAT expr {
      $$ = make_node(GREAT,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr GREATEQUAL expr {
      $$ = make_node(GREATEQUAL,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr EQUAL expr {
      $$ = make_node(EQUAL,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr NOTEQUAL expr {
      $$ = make_node(NOTEQUAL,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr AND expr {
      $$ = make_node(AND,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | expr OR expr {
      $$ = make_node(OR,0,"");
      attach_node($$,$1);
      attach_node($$,$3);
      }
    | OPENPAREN expr CLOSEPAREN {
      $$=$2;
      }
    | IDENTIFIER {
	$$=make_node(IDENTIFIER,0,$1);
    }
    | VALUE {
	$$=make_node(VALUE,$1,"");	
    }
    | INPUT {
	$$=make_node(INPUT,0,"");
    }

%%

void print_tree(struct Node* node, int tabs) {
  int i;

  /* base case */
  if(!node){
      printf("!node");
      return;
  }

  /* print leading tabs */
  for(i = 0; i < tabs; i++) {
    printf("    ");
  }

  switch(node->type) {
    case IDENTIFIER: printf("IDENTIFIER: %s\n", node->id); break;
    case VALUE: printf("VALUE: %lf\n", node->value); break;
    case PLUS: printf("PLUS:\n"); break;
    case MINUS: printf("MINUS:\n"); break;
    case SLASH: printf("DIVIDE:\n"); break;
    case STAR: printf("TIMES:\n"); break;
    case LESS: printf("LESS THAN:\n"); break;
    case GREAT: printf("GREATER:\n"); break;
    case LESSEQUAL: printf("LESS EQUAL:\n"); break;
    case GREATEQUAL: printf("GREATER EQUAL:\n"); break;
    case EQUAL: printf("EQUALS:\n"); break;
    case NOTEQUAL: printf("NOT EQUALS:\n"); break;
    case AND: printf("AND:\n"); break;
    case OR: printf("OR:\n"); break;
    case NOT: printf("NOT:\n"); break;
    case ASSIGNMENT: printf("ASSIGN:\n"); break;
    case IF: printf("IF:\n"); break;
    case WHILE: printf("WHILE:\n"); break;
    case PRINT: printf("PRINT:\n"); break;
    case INPUT: printf("INPUT:\n"); break;
    case STATEMENT: printf("STATEMENT:\n"); break;
    default:
      printf("Error, %d not a valid node type.\n", node->type);
      exit(1);
  }

  /* print all children nodes underneath */
  for(i = 0; i < node->num_children; i++) {
    print_tree(node->children[i], tabs + 1);
  }
}



/* creates a new node and returns it */
struct Node* make_node(int type, double value, char* id) {
  int i;

  /* allocate space */
  struct Node* node = malloc(sizeof(struct Node));

  /* set properties */
  node->type = type;
  node->value = value;
  strcpy(node->id, id);
  node->num_children = 0;
  for(i = 0; i < MAX_CHILDREN; i++) {
    node->children[i] = NULL;
  }

  /* return new node */
  return node;
}

/* attach an existing node onto a parent */
void attach_node(struct Node* parent, struct Node* child) {
  /* connect it */
  parent->children[parent->num_children] = child;
  parent->num_children++;
  assert(parent->num_children <= MAX_CHILDREN);
}

int yywrap( ) {
  return 1;
}

void yyerror(const char* str) {
  fprintf(stderr, "Compiler error: '%s'.\n", str);
}

int main(int argc, char *argv[]) {
    if(argc<2){
	printf("error: pass sloth source");
	return 0;
    }
    stdin = fopen(argv[1],"r");
    if(stdin==NULL){
	printf("Error: file does not exist\n");
	return 0;
    }
    yyparse();
    print_tree(tree,1);
    return 0;
}
