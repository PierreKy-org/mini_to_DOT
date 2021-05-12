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
int DEBUG =0;


%}

%%

"extern"                {if(DEBUG){printf("extern ");}; return EXTERN; }
"int"                   {if(DEBUG){printf("int ");}; return INT; }
"void"                  {if(DEBUG){printf("void ");}; return VOID; }
"for"                   {if(DEBUG){printf("for ");}; return FOR; }
"while"                 {if(DEBUG){printf("while ");}; return WHILE; }
"if"                    {if(DEBUG){printf("if ");}; return IF; }
"then"                  {if(DEBUG){printf("then ");}; return THEN; }
"else"                  {if(DEBUG){printf("else ");}; return ELSE; }
"switch"                {if(DEBUG){printf("switch ");}; return SWITCH; }
"case"                  {if(DEBUG){printf("case ");}; return CASE; }
"default"               {if(DEBUG){printf("default ");}; return DEFAULT; }
"break"                 {if(DEBUG){printf("break ");}; return BREAK; }
"return"                {if(DEBUG){printf("return ");}; return RETURN; }
{L}({L}|{D})*           {   if(DEBUG){printf("identifier ");}; 
                            yylval.chaine = strdup(yytext);
                            return IDENTIFICATEUR; }
{D}+{IS}?               { if(DEBUG){printf("CONSTANTE ");}; 
                            yylval.chaine = strdup(yytext);
                            return CONSTANTE; }
{COM}                   { if(DEBUG){printf("commentaire");}}      

"&&"                    {if(DEBUG){printf("and operation ");}; return LAND; }
"||"                    {if(DEBUG){printf("or operation ");}; return LOR; }
"<="                    {if(DEBUG){printf("less equal operation ");}; return LEQ; }
">="                    {if(DEBUG){printf("great equal operation ");}; return GEQ;}
"=="                    {if(DEBUG){printf("equal operation ");}; return EQ; }
"!="                    {if(DEBUG){printf("not equal operation ");}; return NEQ; }
"<<"                    {if(DEBUG){printf("binary left shift operation ");}; return LSHIFT; }
">>"                    {if(DEBUG){printf("binary right shift operation ");}; return RSHIFT; }
"("|")"|"{"|"}"        	{if(DEBUG){printf(" %c ",yytext[0]);};return yytext[0];}
"*"                     {if(DEBUG){printf(" MUL ");};return MUL;}
"-"                     {if(DEBUG){printf(" MOINS ");};return MOINS;}
"/"                     {if(DEBUG){printf(" DIV ");};return DIV;}
"+"   	                { if(DEBUG){printf(" PLUS ");};return PLUS;}
"="|"&"|"["|"]"      	{ if(DEBUG){printf(" %c ",yytext[0]);};return yytext[0];}
"<"                    	{ if(DEBUG){printf(" %c ",yytext[0]);};return LT;}
">"                    	{ if(DEBUG){printf(" %c ",yytext[0]);};return GT;}
","|";"|":"	          	{ if(DEBUG){printf(" %c ",yytext[0]);};return yytext[0];}


[ \t\v\n\f\r]           { if(DEBUG){printf("%c",yytext[0]);}}

.                       {printf("Erreur lexicale\n");return yytext[0]; }
%%
//Penser à ajouter les +=, -=, /= et *=