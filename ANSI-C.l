D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*
COM			"/*"([^*]|(\*[^/]))*"*/"

%{
#include <stdio.h>
#include "y.tab.h"


/* Ne gère pas les commentaires. A rajouter */
/* Supprimer les lignes dont vous n'avez pas besoin. */

%}

%%

/* Partie des mots à transfomer en tokens */
"extern"                { printf("extern.\n"); return EXTERN; }
"int"                   { printf("int.\n"); return INT; }
"void"                  { printf("void.\n"); return VOID; }
"for"                   { printf("for.\n"); return FOR; }
"while"                 { printf("while.\n"); return WHILE; }
"if"                    { printf("if.\n"); return IF; }
"then"                  { printf("then.\n"); return THEN; }
"else"                  { printf("else.\n"); return ELSE; }
"switch"                { printf("switch.\n"); return SWITCH; }
"case"                  { printf("case.\n"); return CASE; }
"default"               { printf("default.\n"); return DEFAULT; }
"break"                 { printf("break.\n"); return BREAK; }
"return"                { printf("return.\n"); return RETURN; }

{D}*                    { printf("number.\n"); return NUMBER; }
{L}({L}|{D})*           { printf("identifier.\n"); return IDENTIFIER; }
{D}+{IS}?               { printf("CONSTANT:%s",yytext);}

0[xX]{H}+{IS}?          { printf("number hexa.\n"); return NUMBER; }
"&&"                    { printf("and operation.\n"); return AND_OP; }
"||"                    { printf("or operation.\n"); return OR_OP; }
"<="                    { printf("less equal operation.\n"); return LE_OP; }
">="                    { printf("great equal operation.\n"); return GE_OP;}
"=="                    { printf("equal operation.\n"); return EQ_OP; }
"!="                    { printf("not equal operation.\n"); return NE_OP; }
"("|")"|"{"|"}"   { printf(" %c ",yytext[0]);}
"*"|"-"|"/"|"+"   { printf(" %c ",yytext[0]);}
"<"|">"|"="|"&"   { printf(" %c ",yytext[0]);}
","|";"|"."       { printf(" %c ",yytext[0]);}

[ \t\v\n\f\r]     { printf("%c",yytext[0]);}


" "			{ printf("");}
.                       { printf("Erreur lexicale.\n"); }
.                       { return yytext[0]; }
%%
