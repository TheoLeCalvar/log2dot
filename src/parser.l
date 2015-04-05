%{
#include <cstdio>
#include <iostream>

#include "parser.hpp"

using namespace std;

%}
%option yylineno

constante       [a-z][a-zA-Z0-9_]*
variable        [A-Z][a-zA-Z0-9_]*
num_const       [0-9]+
string          (\"(\\\"|[^"])*\")|('(\\'|[^'])*')
comment         (%[^\n\r]*)|("/*"([^*]|"*"[^/])*"*/")


%%

"is"            return (IS);
"not"           return (NOT);

{constante}     {
                        yylval.chaine = strdup(yytext);
                        return (CONSTANTE);
                }

{variable}      {
                        yylval.chaine = strdup(yytext);
                        return (VARIABLE);
                }

{num_const}     {
                        yylval.num = stoi(yytext);
                        return (NUM_CONST);
                }

{string}        {
                        yylval.chaine = strdup(yytext);
                        return (STRING);
                }

{comment}       {
                        std::cout << "Commentaires : \n" << yytext << "\nFin commentaires" << std::endl << std::endl;
                }

"\\+"           return (NOT);
"_"{variable}?  {
                        yylval.chaine = strdup(yytext);
                        return (ANON_VAR);
                }
","             return (CONJONCTION);
";"             return (DISJONCTION);
"."             return (POINT);
":-"            return (SI);

"["             return (B_L);
"]"             return (B_R);
"|"             return (LIST_SEP);

"+"             return (PLUS);
"-"             return (MOINS);
"*"             return (FOIS);
"/"             return (DIVISE);
"="             return (ASSIGN);

"=="            return (EQ);
"<="            return (LTE);
">="            return (GTE);
"<"             return (LT);
">"             return (GT);
"\\="           return (NE);

"("             return (P_L);
")"             return (P_R);
\n              {}
\r              {}
" "             ;
\t              ;
.               {std::cout << "Unkown character '" << yytext << "', " << (int)yytext[0] << std::endl;}

%%
