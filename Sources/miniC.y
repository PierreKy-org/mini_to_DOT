%{

#include <stdio.h>
#include <stdlib.h>
#include "Structures/Stack.c"

int yylex();
void yyerror (char *s) {
	fprintf (stderr, "%s\n", s);	
	exit(2);
}
%}
%token IDENTIFICATEUR CONSTANTE VOID INT FOR WHILE IF ELSE SWITCH CASE DEFAULT
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
		type liste_declarateurs ';'
;
liste_declarateurs	:	
		liste_declarateurs ',' declarateur
	|	declarateur
;
declarateur	:	
		IDENTIFICATEUR
	|	declarateur '[' CONSTANTE ']'
;
fonction	:	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}'
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
;
type	:	
		VOID
	|	INT
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
		IDENTIFICATEUR
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
		display(i);
	
		node_t* t = search(i, "totddo");
		print_list(t);
		/*node_t* it = makeTab();
		insert(it,5, test);
		
		display(it);
		//On peut mettre dans la stack, on peut regarder le premier elem de la stack 
		stack_push(pt, i);
		printf("stack Party ------uwu");
		display(stack_peek(pt));
		stack_push(pt,it);
		display(stack_peek(pt));
		printf("POPPY POPPY");
		stack_pop(pt);
		display(stack_peek(pt));

		stack_pop(pt);
		stack_peek(pt);*/
		
		return 0;
}