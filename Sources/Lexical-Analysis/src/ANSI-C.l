D                       [0-9]
L                       [a-zA-Z_]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*
COM			"/*"([^*]|(\*[^/]))*"*/"

%{
#include <stdio.h>
#include <stdlib.h>


%}

%%
"extern"                { printf("extern"); }
"int"                   { printf("int"); }
"void"                  { printf("void");}
"for"                   { printf("for");}
"while"                 { printf("while"); }
"if"                    { printf("if"); }
"then"                  { printf("then");}
"else"                  { printf("else");}
"switch"                { printf("switch");}
"case"                  { printf("case"); }
"default"               { printf("default");}
"break"                 { printf("break"); }
"return"                { printf("return");}
";"						{ printf(";"); }
-?{D}+          		{ printf("number"); }
{L}({L}|{D})*           { printf("identifier"); }
{D}+{IS}?               { printf("CONSTANT:%s",yytext);}

0[xX]{H}+{IS}?          { printf("number hexa"); }
"/*"([^*]|(\*[^/]))*"*/"     { printf("commentaire");}      
"&&"                    { printf("and operation"); }
"||"                    { printf("or operation");  }
"<="                    { printf("less equal operation");  }
">="                    { printf("great equal operation"); }
"=="                    { printf("equal operation");  }
"!="                    { printf("not equal operation");  }
"<<"                    { printf("binary left operation");  }
">>"                    { printf("binary right operation"); }
"["{D}+"]"				{ printf("%c",yytext[0]); }
"("|")"|"{"|"}"   { printf("%c",yytext[0]);}
"*"|"-"|"/"|"+"   { printf("%c",yytext[0]);}
"<"|">"|"="|"&"   { printf("%c",yytext[0]);}
","|"."|":"      { printf("%c",yytext[0]);}


[ \t\v\n\f\r]     { printf("%c",yytext[0]);}

.                       { printf("Erreur lexicale.\n");return yytext[0]; }
%%

