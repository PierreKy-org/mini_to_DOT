%{

#include <stdio.h>
#include <stdlib.h>
#include "Structures/Stack.c"


struct stack* global_stack;

int yylex();
char* concat(const char *s1, const char *s2);
void yyerror (char *s) {
	fprintf (stderr, "%s\n", s);	
	exit(2);
}
%}

%union{
    char* chaine; 
    int val;
};

//Il nous faut une stack globale
//Il nous faut une table globale (qui serait le haut de la stack)
//Un arbre aussi, pour construire tout en un.

%token<chaine> IDENTIFICATEUR
%token<chaine> CONSTANTE
%token<chaine> INT
%token<chaine> VOID

%type<chaine> type declaration liste_declarateurs declarateur liste_declarations 

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
	|	liste_declarations liste_fonctions	{
			printf($1);
	}
;
liste_declarations	:	
		liste_declarations declaration 		{
			$$ = concat(concat($1,", "),$2);
		}
	|										{
			
	}

liste_fonctions	:	
		liste_fonctions fonction
|               fonction
;
declaration	:	
		type liste_declarateurs ';'     {
				if (strcmp($1,"void")==0){
					yyerror("Error : Variable void");
				}
				$$ = concat(concat($1,$2),";");
		}
;
liste_declarateurs	:	
		liste_declarateurs ',' declarateur 		{
				$$ = concat(concat($1," , "),$3);
		}
	|	declarateur {
				$$ = $1;
	}
;
declarateur	:	
		IDENTIFICATEUR						{
				$$ = $1;
		}
	|	declarateur '[' CONSTANTE ']'		{
				$$ = concat(concat(concat($1,"["),$3),"]");
	}
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
affectation	:	
		variable '=' expression
;
bloc	:	
		'{' liste_declarations liste_instructions '}'
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'
;
variable	:	
		IDENTIFICATEUR 				{

									}
	|	variable '[' expression ']'
;
expression	:	
		'(' expression ')'
	|	expression binary_op expression %prec OP
	|	MOINS expression 
	|	CONSTANTE
	|	variable
	|	IDENTIFICATEUR '(' liste_expressions ')'
;

liste_expressions :      // pour accepter epsilon ou une liste d'expressions
	| expression                              // liste à un seul élément
    | liste_expressions ',' expression  // liste à n éléments
    

condition	:	
		NOT '(' condition ')'
	|	condition binary_rel condition %prec REL
	|	'(' condition ')'
	|	expression binary_comp expression
;
binary_op	:	
		PLUS
	|   MOINS
	|	MUL
	|	DIV
	|   LSHIFT
	|   RSHIFT
	|	BAND
	|	BOR
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
		yyparse();
		printf("Success.\n");
	
		struct stack *pt = newStack(10000);
		node_t* test = makeLinkedList(1,"int", "toto");
		node_t* test2 = makeLinkedList(5,"int", "totdo");
		node_t* test3 = makeLinkedList(7,"string", "totddo");
		node_t* test4 = makeLinkedList(7,"int", "prout");
		node_t* test5 = makeLinkedList(10,"string", "lol");
		node_t* test6 = makeLinkedList(7,"float", "C");
		node_t* i = makeTab();
		
		insert(i,test);
		insert(i,test2);
		insert(i,test3);
		insert(i,test4);
		insert(i,test5);
		insert(i,test6);
	
		node_t* t = search(i, "totddo");
		node_t* it = makeTab();

		insert(it, test);
		
		return 0;
}