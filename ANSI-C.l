D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*
COM			"/*"([^*]|(\*[^/]))*"*/"

%{
#include <stdio.h>
#include "miniC.tab.h"


/* Ne gère pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */
/*flex ANSI-C.l
  gcc lex.yy.c -o nom -lfl
  ./lel < exempleminiC.c
*/

%}

%%

"extern"                { printf("extern. "); return EXTERN; }
"int"                   { printf("int. "); return INT; }
"void"                  { printf("void. "); return VOID; }
"for"                   { printf("for. "); return FOR; }
"while"                 { printf("while. "); return WHILE; }
"if"                    { printf("if. "); return IF; }
"then"                  { printf("then. "); return THEN; }
"else"                  { printf("else. "); return ELSE; }
"switch"                { printf("switch. "); return SWITCH; }
"case"                  { printf("case. "); return CASE; }
"default"               { printf("default. "); return DEFAULT; }
"break"                 { printf("break. "); return BREAK; }
"return"                { printf("return. "); return RETURN; }
";"						{ printf("; \n"); }
{D}+          			{ printf("number. "); return NUMBER; }
{L}({L}|{D})*           { printf("identifier. "); return IDENTIFICATEUR; }
{D}+{IS}?               { printf("CONSTANT:%s",yytext);}

0[xX]{H}+{IS}?          { printf("number hexa. "); return NUMBER; }
"/*"([^*]|(\*[^/]))*"*/"     { printf("commentaire");}      
"&&"                    { printf("and operation. "); return LAND; }
"||"                    { printf("or operation. "); return LOR; }
"<="                    { printf("less equal operation. "); return LEQ; }
">="                    { printf("great equal operation. "); return GEQ;}
"=="                    { printf("equal operation. "); return EQ; }
"!="                    { printf("not equal operation. "); return NEQ; }
"<<"                    { printf("binary left operation. "); return BLO; }
">>"                    { printf("binary right operation. "); return BRO; }
"["{D}+"]"				{ printf("%c",yytext[0]); return CROCHET; }
"("|")"|"{"|"}"   { printf("%c",yytext[0]);}
"*"|"-"|"/"|"+"   { printf("%c",yytext[0]);}
"<"|">"|"="|"&"   { printf("%c",yytext[0]);}
","|"."|":"      { printf("%c",yytext[0]);}


[ \t\v\n\f\r]     { printf("%c",yytext[0]);}

.                       { printf("Erreur lexicale.\n");return yytext[0]; }
%%
