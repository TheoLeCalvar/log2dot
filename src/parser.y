%{
#include "global.hpp"
#include "parser.lex.hpp"
#include <cstdio>
#include <iostream>
using namespace std;


extern "C" void yyerror(const char *s);

extern "C" {

%}

%token CONSTANTE VARIABLE NUM_CONST STRING
%token CONJONCTION DISJONCTION POINT SI LIST_SEP
%token PLUS MOINS FOIS DIVISE ASSIGN
%token EQ LTE GTE LT GT NE
%token P_R P_L B_R B_L
%token ANON_VAR
%token IS

%left PLUS MOINS
%left FOIS DIVISE

%left IS

%start input

%%


input:
    | input regle

regle:
    tete POINT                    {cout << "un fait." << endl;}
    | tete SI atomes POINT        {cout << "une règle" << endl;}
    | SI atomes POINT             {cout << "une contrainte" << endl;}
    | error "."                   {cout << "une erreur"  << endl;}

atomes:
    atomes CONJONCTION atome      {cout << "Une conjonction d'atome !" << endl;}
    | atomes DISJONCTION atome    {cout << "Disjonction d'atomes" << endl;}
    | atome                       {cout << "Un atome tout seul :)" << endl;}

atome:
    CONSTANTE P_L atomes P_R   {cout << "Et bien ça c'est un joli atome " << $1 << "(" << $3 << ")" << endl;}
    | NUM_CONST                   {cout << "une constante numérique " << $1 << endl;}
    | CONSTANTE                   {cout << "une constante 'arité 0 " << $1 << endl;}
    | STRING                      {cout << "chaîne de caractères, une constante :) (" << $1 << ")" << endl;}
    | VARIABLE                    {cout << "Une variable " << $1 << endl;}
    | ANON_VAR                    {cout << "Variable anonyme" << endl;}
    | P_L atomes P_R              {cout << "Des constantes entre parenthèses :o" << endl;}
    | VARIABLE ASSIGN atome       {cout << "Une assignation de variable" << endl;}
    | liste                       {cout << "une liste " << endl;}
    | VARIABLE IS arit_exp        {cout << "une expression arithmétique" << endl;}
    | VARIABLE ASSIGN arit_exp    {cout << "assignation avec =" << endl;}

tete:
    CONSTANTE P_L atomes P_R      {cout << "La tête ! " << $1 << ", " << $3 << endl;}
    | CONSTANTE                   {cout << "Symbole de tête " << $1 << "/0" << endl;}


liste:
    B_L B_R                       {cout << "Liste vide" << endl;}
    | B_L atomes B_R              {cout << "Le contenu d'une liste" << endl;}
    | B_L atome LIST_SEP liste B_R {cout << "une liste dans une liste Oo" << endl;}
    | B_L atome LIST_SEP VARIABLE B_R {cout << "une liste concaténée à une liste Oo" << endl;}


arit_exp:
    arit_exp PLUS arit_exp        {cout << "addition dans exp" << endl;}
    | arit_exp FOIS arit_exp      {cout << "multiplication dans exp" << endl;}
    | arit_exp DIVISE arit_exp    {cout << "division dans exp" << endl;}
    | arit_exp MOINS arit_exp     {cout << "moins dans exp" << endl;}
    | arit_exp ASSIGN arit_exp    {cout << "assign dans exp" << endl;}
    | VARIABLE                    {cout << "var dans exp" << endl;}
    | NUM_CONST                   {cout << "const dans exp" << endl;}


%%

}

int main(int argc, char ** argv) {
    FILE * f;

    f = fopen(argv[1], "r");

    if (!f) {
        cout << "Can't open file" << endl;
        return 1;
    }

    yyin = f;


    yyparse();

    return 0;
}


void yyerror(const char* s) {
        cout << "Error with : " << s << endl;
}
