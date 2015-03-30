%{
#include "log2dot.tab.h"


%}

constant        [a-z][a-zA-Z0-9]*
variable        [A-Z][a-zA-Z0-9]*
num_const       [0-9]+
string 

%%

{separateur}    ;
{reel}          {yylval.val = atof(yytext);
                return REEL;
                }


"fin"           return (END);
"^"             return (POW);
"+"             return (PLUS);
"-"             return (MOINS);
"*"             return (FOIS);
"/"             return (DIVISE);
"="             return (ASSIGN);
"("             return (PARENTHESE_GAUCHE);
")"             return (PARENTHESE_DROITE);
"\n"            return (FIN);
{ident}         {yylval.idt = strdup(yytext);
                return (IDENT);
                }

%%
