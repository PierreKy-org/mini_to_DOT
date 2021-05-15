%{

#include <stdio.h>
#include <stdlib.h>
#include <glib.h>
#include "Structures/Stack.c"

#define RETOUR 16
#define BLOC 15
#define CONDITION 14
#define SELECTION 13
#define COND_COMPARE 12
#define COND_LOGIQUE 11
#define MINUS 10
#define OPERATION 9
#define LISTEXPR 8
#define CONST 7
#define AFFECTATION 3
#define EXPRESSION 6
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

GHashTable* table_hachage;
GQueue* Gstack;
struct stack *pt;
FILE* fichier;

tree_node_linked_t* listeNoeuds;
node_t* i;
%}
%union{
    char* chaine; 
	GNode* noeud;
};

%token<chaine> IDENTIFICATEUR INT VOID CONSTANTE
%type<noeud> bloc condition selection appel type affectation declaration saut liste_expressions  liste_declarateurs instruction declarateur  liste_fonctions fonction liste_instructions variable expression programme 
%type<chaine> binary_op binary_rel binary_comp 

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

programme	:	
	|	liste_declarations liste_fonctions {
		
		if(g_node_nth_child($2,0)->data == INSTRUCTION){
			//printf("chibrux maximus");
		}
		//printf("PROUT %s", g_node_nth_child($2,0)->data);
		genCode($2);
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
							g_hash_table_insert(table_hachage,strdup(ptr),l);
							acc++;
							ptr = strtok(NULL, ",");
						}
						//printf("%s  ",(char*)g_node_nth_child($$,0)->data); //Affiche la clé (iden)
						liste_noeud* ll = g_hash_table_lookup(table_hachage,g_node_nth_child($$,0)->data);
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
	|	selection {$$ = $1;}
	|	saut { $$ = $1;}
	|	affectation ';' {$$ = $1; }
	|	bloc {$$ = $1;}
	|	appel {$$ = $1;}
;
iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction
	|	WHILE '(' condition ')' instruction
;
selection	:	
		IF '(' condition ')' instruction %prec THEN { $$ = g_node_new((void*)SELECTION);
														g_node_append($$,$3);
														g_node_append($$,$5); }
	|	IF '(' condition ')' instruction ELSE instruction { $$ = g_node_new((void*)SELECTION);
														g_node_append($$,$3);
														g_node_append($$,$5);
														g_node_append($$,$7);  }
	|	SWITCH '(' expression ')' instruction
	|	CASE CONSTANTE ':' instruction
	|	DEFAULT ':' instruction
;
saut	:	
		BREAK ';'
	|	RETURN ';'	{$$ = g_node_new((void*)RETOUR);}
	|	RETURN expression ';' {$$ = g_node_new((void*)RETOUR);
									g_node_append($$,$2);}			
;
affectation	:	
		variable '=' expression {	
				liste_noeud* l = g_hash_table_lookup(table_hachage,(char*)g_node_nth_child($1, 0)->data);
				//printf("liden : %s", l->type);

				if(l != NULL){
					$$ = g_node_new((void*)AFFECTATION);
					g_node_append($$,$1);
					g_node_append($$,$3);
					l->valeur = $3;
					g_hash_table_insert(table_hachage,g_strdup(g_node_nth_child($1,0)->data),l);
					l = g_hash_table_lookup(table_hachage,(char*)g_node_nth_child($1, 0)->data);

					//printf("%s", l->valeur);
				}
				else{
					yyerror("Variable non déclarée");
				}

		}
;
bloc	:	
		'{' liste_declarations liste_instructions '}' { $$ = g_node_new((void*)BLOC);
														g_node_append($$, $3);}
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';' { $$ = g_node_new((void*)APPEL);
														g_node_append_data($$, $1);
														g_node_append($$, $3);
													}
;
variable	:	
		IDENTIFICATEUR 				{ $$ = g_node_new((void*)VARIABLE);
										g_node_append_data($$, $1); }
	|	variable '[' expression ']' { $$=$1; }
;

expression	:	
		'(' expression ')' 	{$$ = g_node_new((void*)EXPRESSION);
		g_node_append($$,$2);	}	
	|	expression binary_op expression %prec OP {$$ = g_node_new((void*)OPERATION);
			g_node_append($$, $1);
			g_node_append_data($$, $2);
			g_node_append($$, $3);
	}
	|	MOINS expression 		{$$ = g_node_new((void*)MINUS);
								g_node_append_data($$,"-"); 
								g_node_append($$,$2);}
	|	CONSTANTE {$$ = g_node_new((void*)CONST);
			g_node_append_data($$,$1);
	}
	|	variable {$$ = $1;}
	|	IDENTIFICATEUR '(' liste_expressions ')' {$$ = g_node_new((void*)APPEL);
														g_node_append_data($$, $1);
														g_node_append($$, $3);
}
;

liste_expressions :      
	| expression        {$$ = g_node_new((void*)LISTEXPR);
										g_node_append($$, $1);
							}
    | liste_expressions ',' expression  {$$ = g_node_new((void*)LISTEXPR);
										g_node_append($$, $1);
										g_node_append($$,$3);
										}
    

condition	:	
		NOT '(' condition ')' {}
	|	condition binary_rel condition %prec REL {$$ = g_node_new((void*)COND_LOGIQUE);
								g_node_append($$,$1); 
								g_node_append_data($$,$2);
								g_node_append($$,$3);}
	|	'(' condition ')' {$$ = g_node_new((void*)CONDITION); g_node_append($$,$2);}
	|	expression binary_comp expression {$$ = g_node_new((void*)COND_COMPARE);
								g_node_append($$,$1); 
								g_node_append_data($$,$2);
								g_node_append($$,$3);}
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
		LAND {$$= "&&";}
	|	LOR { $$ = "||";}
;
binary_comp	:	
		LT {$$ = "<";}
	|	GT {$$ = ">";}
	|	GEQ {$$ = ">=";}
	|	LEQ {$$ = "<=";}
	|	EQ {$$ = "==";}
	|	NEQ {$$ = "!=";}
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
void genCode(GNode* node){
        if(node){
                switch((long)node->data){
						case RETOUR :
							printf("Retour\n");
							fprintf(fichier,"return ");
							if (g_node_nth_child(node,0)){
								genCode(g_node_nth_child(node,0));
							}
							else{
								printf("aucune valeur renseigner\n");
							}

							break;
						case BLOC:
							printf("Bloc\n");
							fprintf(fichier,"{\n");
							genCode(g_node_nth_child(node,0));
							fprintf(fichier,"\n}\n");

							break;
						case SELECTION: 
							printf("Selection\n");
							fprintf(fichier,"if ");
                            genCode(g_node_nth_child(node,0));
							fprintf(fichier,"then ");
						    genCode(g_node_nth_child(node,1));  
							if(g_node_nth_child(node,2) != NULL){
								printf("Else\n");
								fprintf(fichier,"else ");
								genCode(g_node_nth_child(node,2));  
							}
							break;
						case COND_LOGIQUE:
							printf("Cond logique\n");
							genCode(g_node_nth_child(node,0));
							fprintf(fichier,"%s ",(char*)g_node_nth_child(node,1)->data);
							genCode(g_node_nth_child(node,2));
							break;
						case CONDITION:
							printf("Condition\n");
							genCode(g_node_nth_child(node,0));
                            
							break;
						case COND_COMPARE:
							printf("Cond compare\n");
							genCode(g_node_nth_child(node,0));
							fprintf(fichier,"%s ",(char*)g_node_nth_child(node,1)->data);
							genCode(g_node_nth_child(node,2));
							break;
                        case VARIABLE:
								printf("Variable\n");
                                fprintf(fichier,"%s ",(char*)g_node_nth_child(node,0)->data);
                                break;
						case CONST:
								printf("CONST\n");
                                fprintf(fichier,"%s ",(char*)g_node_nth_child(node,0)->data);
								break;
						case LISTEXPR:
							genCode(g_node_nth_child(node,0));
						    genCode(g_node_nth_child(node,1));
							break;
						case EXPRESSION:
								printf("Expression\n");
                                genCode(g_node_nth_child(node,0));
                                


								break;
						case MINUS:
							printf("Minus\n");
							fprintf(fichier,"%s ",(char*)g_node_nth_child(node,0)->data);
							genCode(g_node_nth_child(node,1));
							break;
                        case AFFECTATION:
								//Mettre le template.
								//Remplir le template
								//Ecrire le template.
								printf("Affectation\n");
                                genCode(g_node_nth_child(node,0));
                                //printf("\naaaa %s aaaaaaa\n",g_node_nth_child(node,0)->data);
                                fprintf(fichier,"=");
                                genCode(g_node_nth_child(node,1));
                                fprintf(fichier,";\n");
                                break;
						case APPEL : 
							printf("Appel\n");
							fprintf(fichier,"%s ",(char*)g_node_nth_child(node,0)->data);
							genCode(g_node_nth_child(node,1));
							fprintf(fichier,"\n");
							break;

						case OPERATION :
							genCode(g_node_nth_child(node,0));
							fprintf(fichier,"%s ",(char*)g_node_nth_child(node,1)->data);
							genCode(g_node_nth_child(node,2));
							break;
						case INSTRUCTION : 
								printf("Instru\n");
                                genCode(g_node_nth_child(node,0));
								printf("------ Instru separator\n");
                                genCode(g_node_nth_child(node,1));

								break;
						}

				}
}
int main (){
		fichier = fopen("output.dot","w");
		table_hachage = g_hash_table_new(g_str_hash,g_str_equal);
		Gstack = g_queue_new();
		g_queue_push_tail(Gstack, table_hachage);
		yyparse();

		printf("Success.\n");

		return 0;
}