%{

#include <stdio.h>
#include <stdlib.h>
#include "Structures/Stack.c"
#include "Structures/tree.c"

char* concat(const char *s1, const char *s2);
int yylex();
void yyerror (char *s) {
	fprintf (stderr, "%s\n", s);	
	exit(2);
}
struct stack *pt;
node_t* i;
%}
%union{
    char* chaine; 
};

%token<chaine> IDENTIFICATEUR
%token<chaine> INT
%token<chaine> VOID
%type<chaine> type affectation declaration liste_declarateurs declarateur  variable

%token<chaine> CONSTANTE
%type<chaine> binary_op liste_expressions expression

%token FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT LT GT
%token GEQ LEQ EQ NEQ NOT EXTERN
%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left OP
%left REL
%start programme
%%
programme	:	
	|	liste_declarations liste_fonctions
;
liste_declarations	:	
		liste_declarations declaration 
	|	

liste_fonctions	:	
		liste_fonctions fonction
|               fonction
;
declaration	:	
		type liste_declarateurs ';'     {
				if (strcmp($1,"void")==0){
					yyerror("variable void");
				}
				// Extract the first token
				char * token = strtok($2, ",");
				// loop through the string to extract all other tokens
				while( token != NULL ) {
					printf( " %s\n", token ); //printing each token
					insert(i, makeLinkedList(NULL,"int",token));
					token = strtok(NULL, ",");
   }

		}
;
liste_declarateurs	:	
		liste_declarateurs ',' declarateur 		{
				$$ = concat(concat($1,","),$3);
		}
	|	declarateur {
				$$ = $1;
	}
declarateur	:	
		IDENTIFICATEUR						{$$ = $1;}
	|	declarateur '[' CONSTANTE ']'
;
fonction	:	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}'
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
;
type	:	
		VOID 	{$$ = strdup("void");}
	|	INT		{$$ = "int";}
;


liste_parms	:
		parm	
	|
		liste_parms ',' parm
    | 

;
parm	:	
		INT IDENTIFICATEUR
;
liste_instructions :	
		liste_instructions instruction
	|
;
instruction	:	
		iteration
	|	selection
	|	saut
	|	affectation ';'
	|	bloc
	|	appel
;
iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction
	|	WHILE '(' condition ')' instruction
;
selection	:	
		IF '(' condition ')' instruction %prec THEN
	|	IF '(' condition ')' instruction ELSE instruction
	|	SWITCH '(' expression ')' instruction
	|	CASE CONSTANTE ':' instruction
	|	DEFAULT ':' instruction
;
saut	:	
		BREAK ';'
	|	RETURN ';'
	|	RETURN expression ';'
;
				//if(t->next == NULL && t->type == NULL){
affectation	:	
		variable '=' expression {	
				node_t* t = (node_t*)malloc(sizeof(node_t));
				t = search(i, $1);
				//ajout search stack
				printf("%s",t->type);
				if(t==NULL){
					yyerror("Variable non déclarée");
				}
				
				else{
					$$ = concat(concat($1," = "),$3);
					makeTreeNode("trapezium","solid","red",NULL);
					printf("%s",readTree( makeTreeNode("trapezium","solid","red",NULL),"TOTO","variable"));
					insert(i,makeLinkedList($3, "int", $1));
				}


		}
;
bloc	:	
		'{' liste_declarations liste_instructions '}'
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'
;
variable	:	
		IDENTIFICATEUR 				{ $$ = $1; }
	|	variable '[' expression ']' {printf("attention tableau, on gère pas");$$=$1;}
;

expression	:	
		'(' expression ')' 	{$$ = $2;}	
	|	expression binary_op expression %prec OP {printf("\nOperation incoming\n");$$ = concat(concat($1,$2),$3);}
	|	MOINS expression {$$ = concat("-",$2);}
	|	CONSTANTE {$$ = $1;}
	|	variable {$$ = $1;}
	|	IDENTIFICATEUR '(' liste_expressions ')' {$$ = concat(concat($1," "),$3);}
;

liste_expressions :      // pour accepter epsilon ou une liste d'expressions
	| expression        {$$ = $1;}
    | liste_expressions ',' expression  { $$ = concat(concat($1,","),$3); }
    

condition	:	
		NOT '(' condition ')'
	|	condition binary_rel condition %prec REL
	|	'(' condition ')'
	|	expression binary_comp expression
;
binary_op	:	
		PLUS 	{$$ = "+";}
	|   MOINS{$$ = "-";}
	|	MUL{$$ = "*";}
	|	DIV{$$ = "/";}
	|   LSHIFT{$$ = "<<";}
	|   RSHIFT{$$ = ">>";}
;
binary_rel	:	
		LAND
	|	LOR
;
binary_comp	:	
		LT
	|	GT
	|	GEQ
	|	LEQ
	|	EQ
	|	NEQ
;
%%


char* concat(const char *s1, const char *s2)
{
    char *result = malloc(strlen(s1) + strlen(s2) + 1); // +1 for the null-terminator
    // in real code you would check for errors in malloc here
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

int main (){

		pt = newStack(10000);
		i = makeTab();
		stack_push(pt,i);
		yyparse();
		printf("Success.\n");

		
		return 0;
}