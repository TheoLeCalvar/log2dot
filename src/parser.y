%{
#include "parser.lex.hpp"
#include "atomes.hpp"
#include "arithmetique.hpp"
#include "regle.hpp"
#include "toDot.hpp"
#include <cstdio>
#include <vector>
#include <list>
#include <iostream>
using namespace std;

extern int yylineno;
int errors = 0;

vector<regle*>  regles;
vector<regle*>  faits;
vector<regle*>  contraintes;

class vatome {
public:
    vector<atome*> *t;

    vatome() {t = new vector<atome*>;}
};

class latome {
public:
    list<atome*> *l;

    latome() {l = new list<atome*>;}
};

extern "C" void yyerror(const char *s);

%}

%code requires {
    class atome;
    class arithmetique;
    class vatome;
    class latome;
    class regle;
}

%union{
    char*           chaine;
    int             num;
    atome*          patome;
    class vatome*   patomes;
    arithmetique*   parit;
    class latome*   plist;
    regle*          pregle;
}

%token<chaine>  CONSTANTE VARIABLE STRING ANON_VAR
%token<num>     NUM_CONST
%token CONJONCTION DISJONCTION POINT SI LIST_SEP
%token PLUS MOINS FOIS DIVISE ASSIGN NOT
%token EQ LTE GTE LT GT NE
%token P_R P_L B_R B_L
%token IS

%left PLUS MOINS
%left FOIS DIVISE

%left IS ASSIGN

%type<patome>    atome atome_corps tete;
%type<patomes>   atomes atomes_corps;
%type<parit>     arit_exp;
%type<plist>     liste;
%type<pregle>    regle;

%start input

%%


input:
                                  {}
    | input regle                 {}

regle:
    tete POINT
    {
        regle* r = new regle();

        r->tete = (atome_predicat*)$1;

        $$ = r;

        faits.push_back(r);

        cout << "un fait." << endl << *r << endl << endl;

    }
    | tete SI atomes_corps POINT
    {
        regle * r = new regle();

        r->tete = (atome_predicat*)$1;
        r->corps = $3->t;

        $$ = r;

        regles.push_back(r);

        cout << "une règle" << endl << *r << endl << endl;
    }
    | SI atomes_corps POINT
    {
        regle * r = new regle();

        r->corps = $2->t;

        $$ = r;

        contraintes.push_back(r);

        cout << "une contrainte" << endl << *r << endl << endl;
    }
    | error POINT
    {
        cout << "une erreur" << endl << endl;
        errors++;
        $$ = nullptr;
    }

atomes:
    atomes CONJONCTION atome
    {

        $1->t->push_back($3);

        $$ = $1;

        cout << "Conjonction d'atomes : " << *$3 << endl;
    }
    | atomes DISJONCTION atome
    {

        $1->t->push_back($3);

        $$ = $1;

        cout << "Disjonction d'atomes (traité comme une conjontion pour l'instant) " << *$3 << endl;
    }
    | atome
    {
        vatome *  atomes = new vatome();
        atomes->t->push_back($1);

        $$ = atomes;

        cout << "Un atome tout seul " << *$1 << endl;
    }

atomes_corps:
    atomes_corps CONJONCTION atome_corps
    {

        $1->t->push_back($3);

        $$ = $1;

        cout << "Conjonction d'atomes corps" << endl;
    }
    | atomes_corps DISJONCTION atome_corps
    {

        $1->t->push_back($3);

        $$ = $1;

        cout << "Disjonction d'atomes (traité comme une conjontion pour l'instant) corps " << *$3 << endl;
    }
    | atome_corps
    {
        vatome *  atomes = new vatome();
        atomes->t->push_back($1);

        $$ = atomes;

        cout << "Un atome tout seul corps " << *$1 << endl;
    }

atome:
    CONSTANTE P_L atomes P_R
    {
        atome_predicat * a = new atome_predicat;
        a->predicat = $1;
        a->termes = $3->t;
        $$ = a;

        cout << "Et bien ça c'est un joli atome " << *a << endl;
    }
    | STRING P_L atomes P_R
    {
        atome_predicat * a = new atome_predicat;
        a->predicat = $1;
        a->termes = $3->t;
        $$ = a;

        cout << "une string qui est avec des () ! " << *a << endl;
    }
    | P_L atomes P_R              {cout << "Des constantes entre parenthèses :o A traiter " << $2 << endl;}
    | NUM_CONST
    {
        atome_num* a = new atome_num;
        a->valeur = $1;

        $$ = a;

        cout << "une constante numérique " << *a << endl;
    }
    | MOINS NUM_CONST
    {
        atome_num * a = new atome_num;
        a->valeur = -1 * $2;

        $$ = a;
        cout << "constante numérique négative ! -" << *a << endl;
    }
    | CONSTANTE
    {
        atome_predicat * a = new atome_predicat;
        a->predicat = $1;

        $$ = a;
        cout << "un prédicat d'arité 0 " << *a << endl;
    }
    | STRING
    {
        atome_predicat * a = new atome_predicat;
        a->predicat = $1;

        $$ = a;
        cout << "chaîne de caractères, une constante :) " << *a << endl;
    }
    | VARIABLE
    {
        atome_var * a = new atome_var;
        a->nom = $1;

        $$ = a;
        cout << "Une variable " << *a << endl;
    }
    | ANON_VAR
    {
        atome_var * a = new atome_var;
        a->nom = $1;

        $$ = a;
        cout << "Variable anonyme " << *a << endl;
    }
    | liste                       {cout << "une liste " << $1 << endl;}

atome_corps:
    atome                               {$$ = $1;}
    | VARIABLE ASSIGN atome             {cout << "Une assignation de variable, à traiter !" << $1 << "=" << $3 << endl;}
    | VARIABLE NE arit_exp
    {
        atome_arithmetique *a = new atome_arithmetique;
        atome_var * at = new atome_var;
        at->nom = $1;

        a->op = atome_arithmetique::NEQ;
        a->m_gauche = at;
        a->m_droit = $3;

        $$ = a;

        cout << "Contrainte de différence " << *a << endl;
    }
    | VARIABLE LT arit_exp
    {
        atome_arithmetique *a = new atome_arithmetique;
        atome_var * at = new atome_var;
        at->nom = $1;

        a->op = atome_arithmetique::LT;
        a->m_gauche = at;
        a->m_droit = $3;

        $$ = a;
        cout << "Contrainte d'infériorité stricte " << *a << endl;
    }
    | VARIABLE LTE arit_exp
    {
        atome_arithmetique *a = new atome_arithmetique;
        atome_var * at = new atome_var;
        at->nom = $1;

        a->op = atome_arithmetique::LTE;
        a->m_gauche = at;
        a->m_droit = $3;

        $$ = a;
        cout << "Contrainte d'infériorité " << *a << endl;
    }
    | VARIABLE GT arit_exp
    {
        atome_arithmetique *a = new atome_arithmetique;
        atome_var * at = new atome_var;
        at->nom = $1;

        a->op = atome_arithmetique::GT;
        a->m_gauche = at;
        a->m_droit = $3;

        $$ = a;
        cout << "Contrainte de supériorité stricte " << *a << endl;
    }
    | VARIABLE GTE arit_exp
    {
        atome_arithmetique *a = new atome_arithmetique;
        atome_var * at = new atome_var;
        at->nom = $1;

        a->op = atome_arithmetique::GTE;
        a->m_gauche = at;
        a->m_droit = $3;

        $$ = a;
        cout << "Contrainte de supériorité " << *a << endl;
    }
    | VARIABLE ASSIGN arit_exp
    {
        atome_arithmetique *a = new atome_arithmetique;
        atome_var * at = new atome_var;
        at->nom = $1;

        a->op = atome_arithmetique::EQ;
        a->m_gauche = at;
        a->m_droit = $3;

        $$ = a;
        cout << "assignation " << *a << endl;
    }
    | VARIABLE IS arit_exp
    {
        atome_arithmetique *a = new atome_arithmetique;
        atome_var * at = new atome_var;
        at->nom = $1;

        a->op = atome_arithmetique::EQ;
        a->m_gauche = at;
        a->m_droit = $3;

        $$ = a;
        cout << "une expression arithmétique" << *a << endl;
    }
    | NOT atome
    {
        $2->negatif = true;

        $$ = $2;

        cout << "atome négatif ¬" << *$$ << endl;
    }

tete:
    CONSTANTE P_L atomes P_R
    {
        atome_predicat * a = new atome_predicat;
        a->predicat = $1;
        a->termes = $3->t;

        cout << *a << endl;

        $$ = a;
        cout << "La tête ! " << *a << endl;
    }
    | STRING P_L atomes P_R
    {
        atome_predicat * a = new atome_predicat;
        a->predicat = $1;
        a->termes = $3->t;

        cout << *a << endl;


        $$ = a;
        cout << "tête avec une string et des arguments " << *a << endl;
    }
    | CONSTANTE
    {
        atome_predicat * a = new atome_predicat;
        a->predicat = $1;

        cout << *a << endl;

        $$ = a;
        cout << "Symbole de tête " << *a << endl;
    }
    | STRING
    {
        atome_predicat * a = new atome_predicat;
        a->predicat = $1;

        cout << *a << endl;

        $$ = a;
        cout << "Tete avec une string " << *a << endl;
    }

liste:
    B_L B_R                       {cout << "Liste vide" << endl;}
    | B_L atomes B_R              {cout << "Le contenu d'une liste" << endl;}
    | B_L atome LIST_SEP liste B_R {cout << "une liste dans une liste Oo" << endl;}
    | B_L atome LIST_SEP VARIABLE B_R {cout << "une liste concaténée à une liste Oo" << endl;}
    | atome LIST_SEP atome        {cout << "liste concaténée à autre liste, mais sans les braquets" << endl;}

arit_exp:
    arit_exp PLUS arit_exp
    {

        $1->operation = arithmetique::PLUS;
        $1->m_droit = $3;

        $$ = $1;

        cout << "addition dans exp : " << *$$ << endl;
    }
    | arit_exp FOIS arit_exp
    {

        $1->operation = arithmetique::FOIS;
        $1->m_droit = $3;

        $$ = $1;
        cout << "multiplication dans exp : " << *$$ << endl;
    }
    | arit_exp DIVISE arit_exp
    {

        $1->operation = arithmetique::DIVISE;
        $1->m_droit = $3;

        $$ = $1;
        cout << "division dans exp : " << *$$ << endl;
    }
    | arit_exp MOINS arit_exp
    {

        $1->operation = arithmetique::MOINS;
        $1->m_droit = $3;

        $$ = $1;
        cout << "moins dans exp : " << *$$ << endl;
    }
    | VARIABLE
    {
        arithmetique * ar = new arithmetique;

        atome_var * at = new atome_var;
        at->nom = $1;

        ar->var = at;

        $$ = ar;
        cout << "var dans exp : " << *ar << endl;
    }
    | NUM_CONST
    {
        arithmetique * ar = new arithmetique;

        atome_num * at = new atome_num;
        at->valeur = $1;

        ar->num = at;

        $$ = ar;
        cout << "const dans exp : " << *ar << endl;
    }
    | MOINS NUM_CONST
    {
        arithmetique * ar = new arithmetique;

        atome_num * at = new atome_num;
        at->valeur = -1 * $2;

        ar->num = at;

        $$ = ar;
        cout << "const négative dans exp : " << *ar << endl;
    }


%%


int main(int argc, char ** argv) {
    FILE * f;

    if (argc < 3) {
        cout << "Wrong usage : log2dot input output" << endl;
        return 0;
    }

    f = fopen(argv[1], "r");

    if (!f) {
        cout << "Can't open file" << endl;
    }

    yyin = f;


    yyparse();

    if (errors) {
            cout << errors << " errors found while parsing" << endl;
    }


    cout << "Les faits : " << endl;
    for (regle* r: faits)
        cout << *r << endl;

    cout << endl;

    cout << "Les règles : " << endl;
    for (regle* r: regles)
        cout << *r << endl;

    cout << endl;

    cout << "Les contraintes : " << endl;
    for (regle* r: contraintes)
        cout << *r << endl;

    cout << endl;

    save_to_dot(argv[2], faits, regles, contraintes);

    /*for (regle* r: faits)
        delete r;

    for (regle* r: regles)
        delete r;

    for (regle* r: contraintes)
        delete r;*/

    return 0;
}


void yyerror(const char* s) {
        cout << "Error with : " << s << endl;
        cout << "Near line " << yylineno << endl;
}
