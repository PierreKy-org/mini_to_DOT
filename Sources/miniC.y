%{

#include <stdio.h>
#include <stdlib.h>
#include <glib.h>
#include "Structures/Stack.c"

#define AFFECTATION 3
#define VARIABLE 2
#define VIDE 0
#define APPEL 4
#define INSTRUCTION 5
char* concat(const char *s1, const char *s2);
int yylex();
void yyerror (char *s) {
	fprintf (stderr, "%s\n", s);	
	exit(2);
}
typedef struct liste_noeud liste_noeud;
struct liste_noeud{
	char* type;
	char* valeur;
	GNode* noeud;
};

GHashTable* table_symbole;
GQueue* Gstack;
struct stack *pt;
FILE* fichier

tree_node_linked_t* listeNoeuds;
node_t* i;
%}
%union{
    char* chaine; 
	GNode* noeud;
};

%token<chaine> IDENTIFICATEUR INT VOID CONSTANTE
%type<noeud> appel type affectation declaration  liste_declarateurs instruction declarateur  liste_fonctions fonction liste_instructions variable expression programme 
%type<chaine> binary_op liste_expressions saut

%token FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT LT GT
%token GEQ LEQ EQ NEQ NOT EXTERN
%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left OP
%left REL
%start programme
%%

code  : 
	programme {genCode($1);}
	;

programme	:	
	|	liste_declarations liste_fonctions {
		
		if(g_node_nth_child($2,0)->data == INSTRUCTION){
			printf("chibrux maximus");
		}
		//printf("PROUT %s", g_node_nth_child($2,0)->data);
		}
;
liste_declarations	:	
		liste_declarations declaration 
	|	

liste_fonctions	:	
		liste_fonctions fonction {$$ = $2;}
|               fonction {$$ = $1;}
;
declaration	:	
		type liste_declarateurs ';'     {
						liste_noeud* l = malloc(sizeof(liste_noeud));
						l->type = $1;
						l->valeur = NULL;
						$$ = g_node_new((void*) VIDE);
						char *ptr = strtok($2, ",");
						int acc = 0;
						while(ptr != NULL)
						{
							g_node_append_data($$,strdup(ptr));
							//Insert la valeur et la clé et renvoie TRUE si c'est bon
							g_hash_table_insert(table_symbole,g_strdup(g_node_nth_child($$,acc)->data),l);
							acc++;
							ptr = strtok(NULL, ",");
						}
						//printf("%s  ",(char*)g_node_nth_child($$,0)->data); //Affiche la clé (iden)
						liste_noeud* ll = g_hash_table_lookup(table_symbole,g_node_nth_child($$,0)->data);
						//printf("%s dqs\n", ll->type ); //Affiche la valeur (normalement l défini plus haut)
						
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
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' {$$ = $8;}
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
		liste_instructions instruction { $$ = g_node_new((void*)INSTRUCTION);
										g_node_append($$, $1);
										g_node_append($$, $2);
										}
	|
;
instruction	:	
		iteration
	|	selection
	|	saut
	|	affectation ';' {$$ = $1; }
	|	bloc
	|	appel {$$ = $1;}
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
	|	RETURN expression ';' {$$ = $2;}			
;
affectation	:	
		variable '=' expression {	
				liste_noeud* l = g_hash_table_lookup(table_symbole,(char*)g_node_nth_child($1, 0)->data);
				//printf("liden : %s", l->type);
				if(l != NULL){
					$$ = g_node_new((void*)AFFECTATION);
					g_node_append_data($$,$1);
					//g_node_append($$,$3);
					/*l->valeur = $3;
					g_hash_table_insert(table_symbole,g_strdup(g_node_nth_child($$,0)->data),l);
					l = g_hash_table_lookup(table_symbole,(char*)g_node_nth_child($1, 0)->data);
					//printf("%s", l->valeur);*/
				}
				else{
					yyerror("Variable non déclarée");
				}

		}
;
bloc	:	
		'{' liste_declarations liste_instructions '}'
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';' { $$ = g_node_new((void*)APPEL);
														g_node_append_data($$, $1);
														g_node_append_data($$, $3);
													}
;
variable	:	
		IDENTIFICATEUR 				{ $$ = g_node_new((void*)VARIABLE);
										g_node_append_data($$, $1); }
	|	variable '[' expression ']' { $$=$1; }
;

expression	:	
		'(' expression ')' 	{$$ = $2;}	
	|	expression binary_op expression %prec OP {$$ = concat(concat($1,$2),$3);}
	|	MOINS expression {$$ = concat("-",$2);}
	|	CONSTANTE {$$ = $1;}
	|	variable {$$ = g_node_nth_child($1, 0)->data;} //RENVOYER LIDEN DE LA VARIABLE
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
void genCode(GNode* ast){
        if(ast){
                switch((long)ast->data){
                        case SEQUENCE:
                                genCode(g_node_nth_child(ast,0));
                                genCode(g_node_nth_child(ast,1));
                                break;
                        case VARIABLE:
								printf("aaaaaaaaaaaaaaaaaaaaaaaa");
                                fprintf(fichier,"On est passé par ici %s\n",(char*)g_node_nth_child(ast,0));
                                break;
                        case AFFECTATION:
								//Mettre le template.
								//Remplir le template
								//Ecrire le template.
                                fprintf(fichier,"\tlong ");
                                printf("\naaaa %s aaaaaaa\n",g_node_nth_child(ast,0)->data);
                                genCode(g_node_nth_child(ast,0));
                                fprintf(fichier,"=");
                                genCode(g_node_nth_child(ast,1));
                                fprintf(fichier,";\n");
                                break;
							}
				}
}
int main (){
		fichier = fopen("output.dot","w");
		table_symbole = g_hash_table_new(g_str_hash,g_str_equal);
		Gstack = g_queue_new();
		g_queue_push_tail(Gstack, table_symbole);
		yyparse();

		printf("Success.\n");

		return 0;
}