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


%}

%%

"extern"                { printf("extern "); return EXTERN; }
"int"                   { printf("int "); return INT; }
"void"                  { printf("void "); return VOID; }
"for"                   { printf("for "); return FOR; }
"while"                 { printf("while "); return WHILE; }
"if"                    { printf("if "); return IF; }
"then"                  { printf("then "); return THEN; }
"else"                  { printf("else "); return ELSE; }
"switch"                { printf("switch "); return SWITCH; }
"case"                  { printf("case "); return CASE; }
"default"               { printf("default "); return DEFAULT; }
"break"                 { printf("break "); return BREAK; }
"return"                { printf("return "); return RETURN; }
{L}({L}|{D})*           { printf("identifier "); return IDENTIFICATEUR; }
{D}+{IS}?               { printf("CONSTANTE "); return CONSTANTE; }
0[xX]{H}+{IS}?          { printf("const hexa "); return CONSTANTE; }
{COM}                   { printf("commentaire");}      

"&&"                    { printf("and operation "); return LAND; }
"||"                    { printf("or operation "); return LOR; }
"<="                    { printf("less equal operation "); return LEQ; }
">="                    { printf("great equal operation "); return GEQ;}
"=="                    { printf("equal operation "); return EQ; }
"!="                    { printf("not equal operation "); return NEQ; }
"<<"                    { printf("binary left shift operation "); return LSHIFT; }
">>"                    { printf("binary right shift operation "); return RSHIFT; }
"["{D}*"]"			      	{ printf("%c",yytext[0]); return CROCHET; }
"("|")"|"{"|"}"        	{ printf(" %c ",yytext[0]);return yytext[0];}
"*"                     { printf(" MUL ");return MUL;}
"-"                     { printf(" MOINS ");return MOINS;}
"/"                     { printf(" DIV ");return DIV;}
"+"   	                { printf(" PLUS ");return PLUS;}
"="|"&"       	{ printf(" %c ",yytext[0]);return yytext[0];}
"<"                    	{ printf(" %c ",yytext[0]);return LT;}
">"                    	{ printf(" %c ",yytext[0]);return GT;}
","|";"|":"	          	{ printf(" %c ",yytext[0]);return yytext[0];}


[ \t\v\n\f\r]           { printf("%c",yytext[0]);}

.                       { printf("Erreur lexicale\n");return yytext[0]; }
%%
//Penser à ajouter les +=, -=, /= et *=