%{

#include <stdio.h>
#include <stdlib.h>
#include <glib.h>
#include "Structures/Stack.c"

#define EXTERNF 24
#define LIST_FCT 23
#define BWHILE 22
#define BFOR 21
#define DEFAULTS 20
#define SWITCHS 19
#define CASES 18
#define BREAKS 17
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
#define EXPRESSION 6
#define INSTRUCTION 5
#define APPEL 4
#define AFFECTATION 3
#define VARIABLE 2
#define FONCTION 1
#define VIDE 0

char* numToStr(int num);
char* filename;
char *liaisonsPereFils;
int numDotVar;
int isCurrentConstNeg;
char* dotbloc;
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
%type<noeud> iteration bloc condition selection appel type affectation declaration saut liste_expressions  liste_declarateurs instruction declarateur  liste_fonctions fonction liste_instructions variable expression programme
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
		liste_fonctions fonction {$$ = g_node_new((void*) LIST_FCT);
									g_node_append($$, $1);
									g_node_append($$, $2);	}
|               fonction {$$ = g_node_new((void*) LIST_FCT);
								g_node_append($$, $1);	}
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
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' {$$ = g_node_new((void*)FONCTION);
								//premier noeud contient type
										g_node_append_data($$, $1);
								//second noeud contient nom
										g_node_append_data($$,$2);
								//dernier noeud contient data
										g_node_append($$, $8);
										}

	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';' {$$ = g_node_new((void*)EXTERNF);}
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
	|	instruction {$$ = g_node_new((void*)INSTRUCTION);
						g_node_append($$, $1);}
;
instruction	:	
		iteration {$$ = $1;}
	|	selection {$$ = $1;}
	|	saut { $$ = $1;}
	|	affectation ';' {$$ = $1; }
	|	bloc {$$ = $1;}
	|	appel {$$ = $1;}
;
iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction {$$ = g_node_new((void*)BFOR);
																			g_node_append($$,$3);
																			g_node_append($$,$5);
																			g_node_append($$,$7);
																			g_node_append($$,$9);}
	|	WHILE '(' condition ')' instruction {$$ = g_node_new((void*)BWHILE);
												g_node_append($$,$3);
												g_node_append($$,$5);}
;


selection	:	
		IF '(' condition ')' instruction %prec THEN { $$ = g_node_new((void*)SELECTION);
														g_node_append($$,$3);
														g_node_append($$,$5); }
	|	IF '(' condition ')' instruction ELSE instruction { $$ = g_node_new((void*)SELECTION);
														g_node_append($$,$3);
														g_node_append($$,$5);
														g_node_append($$,$7);  }
	|	SWITCH '(' expression ')' instruction { $$ = g_node_new((void*)SWITCHS);
														g_node_append($$,$3);
														g_node_append($$,$5); }
	|	CASE CONSTANTE ':' instruction { $$ = g_node_new((void*)CASES);
											g_node_append_data($$,$2);
											g_node_append($$,$4); }
	|	DEFAULT ':' instruction { $$ = g_node_new((void*)DEFAULTS);
									g_node_append($$,$3); }
;
saut	:	
		BREAK ';' {$$ = g_node_new((void*)BREAKS);}
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
	|	MOINS expression %prec MOINS  {$$ = g_node_new((void*)MINUS);
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
char* numToStr(int num){
	char *str = (char*)malloc(sizeof(char)*12);
	sprintf(str, "%d", num);
	return str;
}

void genCode(GNode* node){
	char* nomVar;
	char* liaisonCourrante;
	char* liasionDessus;
	char* nomLabel;
        if(node){
                switch((long)node->data){
						case LIST_FCT:
							genCode(g_node_nth_child(node,0));
							genCode(g_node_nth_child(node,1));
							break;
						case BWHILE:
							printf("While\n");
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);
							fprintf(fichier,"[label=\"WHILE\" shape=ellipse color=black];");
							liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
							numDotVar++;
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
							char* tempo3;
							tempo3 = strdup(dotbloc);
							dotbloc = strdup(nomVar);
							genCode(g_node_nth_child(node,0));
							genCode(g_node_nth_child(node,1));
							dotbloc = strdup(tempo3);
							free(tempo3);
							break;
						case BFOR:
							printf("For\n");
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);
							fprintf(fichier,"[label=\"FOR\" shape=ellipse color=black];");
							liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
							//Concaténation des liaisons
							numDotVar++;
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
							//printf("liaison pere fils = %s\n",liaisonsPereFils);
							char* tempo;
							tempo = strdup(dotbloc);
							dotbloc = strdup(nomVar);
							genCode(g_node_nth_child(node,0));
							genCode(g_node_nth_child(node,1));
							genCode(g_node_nth_child(node,2));
							genCode(g_node_nth_child(node,3));
							dotbloc = strdup(tempo);
							free(tempo);
							break;

						case BREAKS:
							//Création du nom
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);
							//Création & écriture du template
							fprintf(fichier,"[label=\"break\" shape=box];");
							liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
							numDotVar++;
							//Incrémentation du compteur de noms global
							numDotVar++;
							break;
						case DEFAULTS:
							printf("Default\n");
							char* tempoDefault;
							//Création du nom
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);
							fprintf(fichier,"[label=\"default\" shape=diamond];");

							tempoDefault = strdup(dotbloc);
							liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
							dotbloc = strdup(nomVar);
							numDotVar++;
							//Créer un lien 
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
							//Incrémentation du compteur de noms global
							genCode(g_node_nth_child(node,0));
							dotbloc = strdup(tempoDefault);
							free(tempoDefault);
							break;
						case CASES :							
							printf("Case\n");
							char* tempoCase;
							//Création du nom
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);
							nomLabel = concat("case ",g_node_nth_child(node,0)->data);
							fprintf(fichier,"[label=\"%s\" shape=diamond];",nomLabel);

                            tempoCase = strdup(dotbloc);
							liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
                            dotbloc = strdup(nomVar);
							numDotVar++;
							//Créer un lien 
							//liaisonCourrante = concat(concat(concat(concat(nomVar," -> "),"node_"),numToStr(numDotVar)),"\n");
							//liaisonsPereFils = concat(liaisonsPereFils,liaisonCourrante);
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
							//Incrémentation du compteur de noms global
							genCode(g_node_nth_child(node,1));
                            dotbloc = strdup(tempoCase);
                            free(tempoCase);
							break;

						case SWITCHS :
							printf("Switch\n");
							char* tempo5;
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);
							fprintf(fichier,"[label=\"Switch\" shape=ellipse];",nomLabel);

                            tempo5 = strdup(dotbloc);
                            liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
                            dotbloc = strdup(nomVar);
                            numDotVar++;
                            //liaisonCourrante = concat(concat(concat(concat(nomVar," -> "),"node_"),numToStr(numDotVar)),"\n");
                            //liaisonsPereFils = concat(liaisonsPereFils,liaisonCourrante);
                            liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
                            //Genere le membre à gauche
                            genCode(g_node_nth_child(node,0));
                            //liaisonCourrante = concat(concat(concat(concat(nomVar," -> "),"node_"),numToStr(numDotVar)),"\n");
                            //liaisonsPereFils = concat(liaisonsPereFils,liaisonCourrante);
                            //Membre à droite
                            genCode(g_node_nth_child(node,1));
                            dotbloc = strdup(tempo5);
                            free(tempo5);
                            break;

						case RETOUR :
							printf("Retour\n");
							//Création du nom
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);

							//Création & écriture du template
							fprintf(fichier,"[label=\"return\" shape=trapezium color=blue];");
							if (g_node_nth_child(node,0)){

								//Calcul de la relation père fils
								char* tempo7;
								tempo7 = strdup(dotbloc);
								liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
								dotbloc = strdup(nomVar);
								numDotVar++;
								liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
								//Incrémentation du compteur de noms global
								genCode(g_node_nth_child(node,0));
								dotbloc = strdup(tempo7);
								free(tempo7);
							}
							else{
								printf("aucune valeur renseignée\n");
								liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
								numDotVar++;
								liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
							
							}

							break;
						case BLOC:
							printf("Bloc\n");
							char* tempo2;
							tempo2 = strdup(dotbloc);
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);
							fprintf(fichier,"[label=\"BLOC\" shape=ellipse color=black];");
							liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
							
							dotbloc = strdup(nomVar);
							numDotVar++;
							genCode(g_node_nth_child(node,0));
							dotbloc = strdup(tempo2);
							free(tempo2);
							
							break;
						case SELECTION: 
							printf("Selection\n");
							char* tempo4;
							tempo4 = strdup(dotbloc);
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);
							fprintf(fichier,"[label=\"IF\" shape=diamond color=black];");
                            liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
							dotbloc = strdup(nomVar);
							numDotVar++;
						    genCode(g_node_nth_child(node,0));
							char* tempo6;
							tempo6 = strdup(dotbloc);
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);
							fprintf(fichier,"[label=\"THEN\" shape=ellipse color=black];");
							liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
							dotbloc = strdup(nomVar);
							numDotVar++;
						    genCode(g_node_nth_child(node,1)); 
							dotbloc = strdup(tempo6);
							free(tempo6); 
							if(g_node_nth_child(node,2) != NULL){
								printf("Else\n");
								tempo6 = strdup(dotbloc);
								nomVar = concat("node_",numToStr(numDotVar));
								fprintf(fichier,"\n%s ",nomVar);
								fprintf(fichier,"[label=\"ELSE\" shape=ellipse color=black];");
								liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
								liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
								dotbloc = strdup(nomVar);
								numDotVar++;
								genCode(g_node_nth_child(node,2));  
								dotbloc = strdup(tempo6);
								free(tempo6); 
							}
							
							dotbloc = strdup(tempo4);
							free(tempo4);
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
							char* tempo10;
							tempo10 = strdup(dotbloc);
							//Création du nom
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);

							//Création & écriture du template
							fprintf(fichier,"[label=\"%s\" shape=ellipse];",(char*)g_node_nth_child(node,1)->data );

							liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
							
							//Incrémentation du compteur de noms global
							dotbloc = strdup(nomVar);
							numDotVar++;

							//Concaténation des liaisons
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
							//printf("liaison pere fils = %s\n",liaisonsPereFils);

							//Génération du code suivant
							genCode(g_node_nth_child(node,0));
							//Deuxième conaténation de liaison
							//Un appel à genCode augmente le compteur pas besoin de le ré-incrémenter ici
							genCode(g_node_nth_child(node,2));

							dotbloc = strdup(tempo10);
							free(tempo10); 
							break;
                        case VARIABLE:
							printf("Variable\n");
							//Création du nom
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);

							//Permet de gérer l'écriture d'entiers négatifs
							if(isCurrentConstNeg==1){
							fprintf(fichier,"[label=\"%s\" shape=ellipse];",
								concat("-",g_node_nth_child(node,0)->data));
							}else{
							fprintf(fichier,"[label=\"%s\" shape=ellipse];",
								(char*)g_node_nth_child(node,0)->data);
							}
							liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
							
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
								
							isCurrentConstNeg = 0;
							//Une variable est un terminal -> On ne génère aucun code supplémentaire

							//Incrémentation du compteur de noms global
							numDotVar++;
							break;
						case CONST:
							printf("CONST\n");
							//Création du nom
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);

							//Permet de gérer l'écriture d'entiers négatifs
							if(isCurrentConstNeg==1){
							fprintf(fichier,"[label=\"%s\" shape=ellipse];",
								concat("-",g_node_nth_child(node,0)->data));
							}else{
							//Création & écriture du template
							fprintf(fichier,"[label=\"%s\" shape=ellipse];",
								(char*)g_node_nth_child(node,0)->data);

							//idem que pour Variable
							}
							liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
							
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
								
							isCurrentConstNeg = 0;
							//Incrémentation du compteur de noms global
							numDotVar++;
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
						//Vérifie si son fils est une expression --> "-(x + y)" et crée un noeud "-" si besoin
						//Sinon, on change juste la valeur de isCurrentConstNeg pour par la suite rajouter le "-" devant une var ou une const
							printf("Minus\n");
							if(g_node_nth_child(node,1)->data == EXPRESSION){
								//Création du nom
								nomVar = concat("node_",numToStr(numDotVar));
								fprintf(fichier,"\n%s ",nomVar);
								fprintf(fichier,"[label=\"-\" shape=ellipse];");
								liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
								numDotVar++;
								liaisonCourrante = concat(concat(concat(concat(nomVar," -> "),"node_"),numToStr(numDotVar)),"\n");
								liaisonsPereFils = concat(liaisonsPereFils,liaisonCourrante);
								
								genCode(g_node_nth_child(node,1));
							}else{
								isCurrentConstNeg = 1;
								genCode(g_node_nth_child(node,1));
							}

							break;
                        case AFFECTATION:
							printf("Affectation\n");
							char* tempo12;
							tempo12 = strdup(dotbloc);

							//Création du nom
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);

							//Création & écriture du template
							fprintf(fichier,"[label=\":=\" shape=ellipse];");

							liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
							
							//Incrémentation du compteur de noms global
							dotbloc = strdup(nomVar);
							numDotVar++;

							//Concaténation des liaisons
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
							//printf("liaison pere fils = %s\n",liaisonsPereFils);

							//Génération du code suivant
							genCode(g_node_nth_child(node,0));
							//Deuxième conaténation de liaison
							//Un appel à genCode augmente le compteur pas besoin de le ré-incrémenter ici
							genCode(g_node_nth_child(node,1));
							dotbloc = strdup(tempo12);
							free(tempo12); 
							break;

						case APPEL : ; //NE PAS SUPPRIMER CE ";"
							printf("Appel\n");

							//Création du nom
							char* tempo8;
							tempo8 = strdup(dotbloc);
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);

							//Création & écriture du template
							fprintf(fichier,"[label=\"%s\" shape=septagon];",
								(char*)g_node_nth_child(node,0)->data);

							liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
							//Concaténation des liaisons
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
							//printf("liaison pere fils = %s\n",liaisonsPereFils);
							dotbloc = strdup(nomVar);
							numDotVar++;
						    genCode(g_node_nth_child(node,1)); 
							dotbloc = strdup(tempo8);
							free(tempo8); 

							break;

						case OPERATION :							
							printf("Operation\n");
							char* tempo9;
							tempo9 = strdup(dotbloc);
							//Création du nom
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);

							//Création & écriture du template
							fprintf(fichier,"[label=\"%s\" shape=ellipse];",
								(char*)g_node_nth_child(node,1)->data);

							liasionDessus = concat(concat(concat(concat(dotbloc," -> "),"node_"),numToStr(numDotVar)),"\n");
							
							//Incrémentation du compteur de noms global
							dotbloc = strdup(nomVar);
							numDotVar++;
							
							//Concaténation des liaisons
							liaisonsPereFils = concat(liaisonsPereFils,liasionDessus);
							
							//printf("liaison pere fils = %s\n",liaisonsPereFils);

							//Génération du code suivant
							genCode(g_node_nth_child(node,0));
							//Un appel à genCode augmente le compteur pas besoin de le ré-incrémenter ici
							//Deuxième conaténation de liaison
							genCode(g_node_nth_child(node,2));
							dotbloc = strdup(tempo9);
							free(tempo9); 

							break;

						case INSTRUCTION : 
								printf("Instru\n");
                                genCode(g_node_nth_child(node,0));
								printf("------ Instru separator\n");
                                genCode(g_node_nth_child(node,1));

								break;
						case FONCTION :
							//POUR FONCTION le noeud est un peu spécial mais toujours pareil.
							//Le premier node contient le type, le second le nom et le dernier la data
							printf("FONCTION\n");

							//Création du nom
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);
							
							
							//Création du label (nom de fonction + type)
							nomLabel = concat(concat(g_node_nth_child(node,1)->data,", "),g_node_nth_child(node,0)->data);
							
							//Création & écriture du template
							fprintf(fichier,"[label=\"%s\" shape=invtrapezium color=blue];",nomLabel);
							numDotVar++;
							liaisonCourrante = concat(concat(concat(concat(nomVar," -> "),"node_"),numToStr(numDotVar)),"\n");
							
							nomVar = concat("node_",numToStr(numDotVar));
							fprintf(fichier,"\n%s ",nomVar);
							dotbloc = strdup(nomVar);
							fprintf(fichier,"[label=\"BLOC\" shape=ellipse color=black];");
							free(nomLabel);

							//Incrémentation du compteur de noms global
							numDotVar++;

							//Concaténation des liaisons
							liaisonsPereFils = concat(liaisonsPereFils,liaisonCourrante);

							//Génération du code suivant
							genCode(g_node_nth_child(node,2));
							break;
					}

				}
}
int main(int argc, char *argv[]){ 
		if(argv[1]==NULL){
			filename = "Resultats/out.dot";
		}else{
			filename = concat("Resultats/",concat(argv[1],".dot"));
		}

		fichier = fopen(filename,"w");
		dotbloc = "";
		isCurrentConstNeg = 0;
		numDotVar = 0; //Permet de nommer les variables avec des noms différents (neud<i>)
		liaisonsPereFils =""; //Sera remplit durant l'éxécution puis écrit à la fin du fichier
		fprintf(fichier,"digraph G {\n");

		table_hachage = g_hash_table_new(g_str_hash,g_str_equal);
		Gstack = g_queue_new();
		g_queue_push_tail(Gstack, table_hachage);
		yyparse();
		printf("Success.\n");

		fprintf(fichier,"\n\n%s",liaisonsPereFils);
		fprintf(fichier,"}");

		return 0;
}