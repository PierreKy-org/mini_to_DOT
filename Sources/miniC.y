%{

#include <stdio.h>
#include <stdlib.h>
#include "Structures/Stack.c"

char* concat(const char *s1, const char *s2);
int yylex();
void yyerror (char *s) {
	fprintf (stderr, "%s\n", s);	
	exit(2);
}
struct stack *pt;

tree_node_linked_t* listeNoeuds;
node_t* i;
%}
%union{
    char* chaine; 
	struct tree_dot_t* noeud;
};

%token<chaine> IDENTIFICATEUR INT VOID CONSTANTE
%type<noeud> type affectation declaration liste_declarateurs declarateur  variable
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
				/* Dans cette partie on découpe la chaine formée 
				par la liste des déclarateur pour charger dans la TS chacun des
				token individuellement
				*/
				// Extract the first token
				char * token = strtok($2, ",");
				// loop through the string to extract all other tokens
				while( token != NULL ) {
					insert(stack_peek(pt), makeLinkedList(NULL,"int",token));
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
affectation	:	
		variable '=' expression {	
				int avonsNousTrouveIdent;
				avonsNousTrouveIdent = stack_search(pt,$1);
				if(avonsNousTrouveIdent == 0){
					yyerror("Variable non déclarée");
				}
				else{
					insert(i,makeLinkedList($3, "int", $1));

					char *code;
					code = concat(concat($1," = "),$3);
					tree_dot_t* treeVal;
					treeVal = makeTreeNode("trapezium","solid","red",NULL,code, "=","test");

					tree_dot_t* treeVariable;
					treeVariable = makeTreeNode("trapezium","solid","red",treeVal,code,$1 ,"var");
					tree_dot_t* treeExp;
					treeExp = makeTreeNode("trapezium","solid","red",treeVal,code,$3 ,"var");

					pushTreeNode(listeNoeuds, treeVariable);
					pushTreeNode(listeNoeuds, treeExp);

				$$ = treeVal;

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
	|	variable '[' expression ']' { $$=$1; }
;

expression	:	
		'(' expression ')' 	{$$ = $2;}	
	|	expression binary_op expression %prec OP {$$ = concat(concat($1,$2),$3);}
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


		listeNoeuds = (tree_node_linked_t*)malloc(sizeof(tree_node_linked_t));
		pt = newStack(10000);
		i = makeTab();
		stack_push(pt,i);
		yyparse();

		printf("Success.\n");

		return 0;
}