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
    class atome_predicat;
    class atome_num;
    class atome_var;
    class arithmetique;
    class vatome;
    class latome;
    class regle;
    typedef enum {
        op_GT,
        op_GTE,
        op_LT,
        op_LTE,
        op_EQ,
        op_NEQ,
        op_NONE
    } op_comp;
}

%union{
    char*           chaine;
    int             num;
    atome*          patome;
    atome_predicat *patome_pred;
    atome_num*      patome_num;
    atome_var*      patome_var;
    class vatome*   patomes;
    arithmetique*   parit;
    class latome*   plist;
    regle*          pregle;
    op_comp         op;
}

%token<chaine>  CONSTANTE VARIABLE STRING ANON_VAR
%token<num>     NUM_CONST
%token CONJONCTION DISJONCTION POINT SI LIST_SEP
%token PLUS MOINS FOIS DIVISE ASSIGN NOT
%token EQ LTE GTE LT GT NE
%token P_R P_L B_R B_L
%token IS


%type<patome>    atome atome_corps comparaison;
%type<patome_pred>  tete function constante;
%type<patome_num>   nombre;
%type<patome_var>   variable;
%type<patomes>   corps_disjonctif corps_conjonctif termes;
%type<parit>     arit_exp arit_exp_2 arit_exp_3;
%type<pregle>    regle;
%type<op>       comparaison_operateur;
/*%type<plist>     liste;*/

%left CONJONCTION

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
    | tete SI corps_disjonctif POINT
    {
        regle * r = new regle();

        r->tete = (atome_predicat*)$1;
        r->corps = $3->t;

        $$ = r;

        delete $3;

        regles.push_back(r);

        cout << "une règle" << endl << *r << endl << endl;
    }
    | SI corps_disjonctif POINT
    {
        regle * r = new regle();

        r->corps = $2->t;

        $$ = r;

        delete $2;

        contraintes.push_back(r);

        cout << "une contrainte" << endl << *r << endl << endl;
    }
    | error POINT
    {
        cout << "une erreur" << endl << endl;
        errors++;
        $$ = nullptr;
    }

corps_disjonctif:
    corps_disjonctif DISJONCTION corps_conjonctif
    {

        for (auto i: *$3->t) {
            $1->t->push_back(i);
        }

        delete $3;

        $$ = $1;

        cout << "Disjonction d'atomes (traité comme une conjontion pour l'instant) " << endl;
    }
    | corps_conjonctif
    {
        $$ = $1;
    }

corps_conjonctif:
    corps_conjonctif CONJONCTION corps_conjonctif
    {
        for (auto i: *$3->t) {
            $1->t->push_back(i);
        }

        delete $3;

        $$ = $1;

        cout << "Conjonction d'atomes "  << endl;
    }
    | atome_corps
    {
        vatome *  atomes = new vatome();
        atomes->t->push_back($1);

        $$ = atomes;

        cout << "Un atome tout seul " << *$1 << endl;
    }
    | P_L corps_disjonctif P_R
    {
        $$ = $2;
        cout << "C'est pas traiter mais c'est des parenthèses dans la liste de termes" << endl;
    }

function:
    constante
    {
        $$ = $1;

        cout << "Prédicat d'arité 0 " << *$1 << endl;
    }
    | constante P_L termes P_R
    {
        $1->termes = $3->t;

        $$ = $1;

        cout << "On a trouvé un prédicat de fonciton " << *$1 << endl;
    }

constante:
    CONSTANTE
    {
        atome_predicat * a = new atome_predicat;

        a->predicat = $1;

        delete $1;

        $$ = a;

        cout << "Une constante " << *a << endl;
    }
    | STRING
    {
        atome_predicat * a = new atome_predicat;

        a->predicat = $1;

        delete $1;

        $$ = a;

        cout << "Une constante " << *a << endl;
    }

termes:
    atome
    {
        vatome *  atomes = new vatome();
        atomes->t->push_back($1);

        $$ = atomes;

        cout << "Un terme tout seul " << *$1 << endl;
    }
    | termes CONJONCTION atome
    {
        $1->t->push_back($3);

        $$ = $1;

        cout << "Un atome dans un terme " << *$3 << endl;
    }

nombre:
    NUM_CONST
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

variable:
    VARIABLE
    {
        atome_var * a = new atome_var;
        a->nom = $1;

        $$ = a;
        delete $1;
        cout << "Une variable " << *a << endl;
    }
    | ANON_VAR
    {
        atome_var * a = new atome_var;
        a->nom = $1;

        $$ = a;
        delete $1;
        cout << "Variable anonyme " << *a << endl;
    }

tete:
    function
    {
        $$ = $1;

        cout << "On a trouvé une tête " << *$1 << endl;
    }

atome:
    function                        {$$ = $1;}
    | nombre                        {$$ = $1;}
    | variable                      {$$ = $1;}
    // | liste                         {cout << "une liste " << endl; $$ = nullptr;}

atome_corps:
    atome                             {$$ = $1;}
    | NOT atome
    {
        $2->negatif = true;

        $$ = $2;

        cout << "atome négatif " << *$$ << endl;
    }
    | comparaison                         {$$ = $1;}
    | arit_exp
    {
        atome_arithmetique *a = new atome_arithmetique;

        a->m_droit = $1;

        $$ = a;

        cout << "Une expression arithmétique seule " << *a << endl;
    }

/*
liste:
    B_L B_R                       {cout << "Liste vide" << endl;}
    | B_L atomes B_R              {cout << "Le contenu d'une liste" << endl; delete $2;}
    | B_L atome LIST_SEP liste B_R {cout << "une liste dans une liste Oo" << endl;}
    | B_L atome LIST_SEP VARIABLE B_R {cout << "une liste concaténée à une liste Oo" << endl; delete $4;}
    | atome LIST_SEP atome        {cout << "liste concaténée à autre liste, mais sans les braquets" << endl;}
*/

comparaison_operateur:
    NE      {$$ = op_NEQ;}
    | IS    {$$ = op_EQ;}
    | EQ    {$$ = op_EQ;}
    | GT    {$$ = op_GT;}
    | GTE   {$$ = op_GTE;}
    | LT    {$$ = op_LT;}
    | LTE   {$$ = op_LTE;}

comparaison:
    arit_exp comparaison_operateur arit_exp
    {
        atome_arithmetique *a = new atome_arithmetique;

        a->op = $2;
        a->m_gauche = $1;
        a->m_droit = $3;

        $$ = a;

        cout << "Comparaison " << *a << endl;
    }


arit_exp:
    arit_exp PLUS arit_exp_2
    {
        $1->operation = arithmetique::PLUS;
        $1->m_droit = $3;

        $$ = $1;

        cout << "addition dans exp : " << *$$ << endl;
    }
    | arit_exp MOINS arit_exp_2
    {
        $1->operation = arithmetique::MOINS;
        $1->m_droit = $3;

        $$ = $1;
        cout << "soustraction dans exp : " << *$$ << endl;
    }
    | arit_exp ASSIGN arit_exp_2
    {
        $1->operation = arithmetique::ASSIGN;
        $1->m_droit = $3;

        $$ = $1;
        cout << "assignation dans exp : " << *$$ << endl;
    }
    | arit_exp_2
    {
        $$ = $1;
    }

arit_exp_2:
    arit_exp_2 DIVISE arit_exp_3
    {
        $1->operation = arithmetique::DIVISE;
        $1->m_droit = $3;

        $$ = $1;
        cout << "division dans exp : " << *$$ << endl;
    }
    | arit_exp_2 FOIS arit_exp_3
    {
        $1->operation = arithmetique::FOIS;
        $1->m_droit = $3;

        $$ = $1;
        cout << "multiplication dans exp : " << *$$ << endl;
    }
    | arit_exp_3
    {
        $$ = $1;
    }

arit_exp_3:
    variable
    {
        arithmetique * ar = new arithmetique;

        ar->var = $1;

        $$ = ar;
        cout << "var dans exp : " << *ar << endl;
    }
    | nombre
    {
        arithmetique * ar = new arithmetique;

        ar->num = $1;

        $$ = ar;
        cout << "const dans exp : " << *ar << endl;
    }
    | P_L arit_exp P_R
    {
        arithmetique * ar = new arithmetique;
        ar->m_droit = $2;

        ar->operation = arithmetique::PARENTHESE;

        $$ = ar;

        cout << "des () dans une exp : " << *ar << endl;
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

    for (regle* r: faits)
        delete r;

    for (regle* r: regles)
        delete r;

    for (regle* r: contraintes)
        delete r;

    return 0;
}


void yyerror(const char* s) {
        cout << "Error with : " << s << endl;
        cout << "Near line " << yylineno << endl;
}
