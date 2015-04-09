#ifndef atomes_h
#define atomes_h

#include <sstream>
#include <vector>
#include "parser.hpp"

using namespace std;

class atome {
public:
    bool    negatif;

    atome():negatif(false){}
    virtual ~atome(){}

    virtual string to_string() const = 0;

    virtual string id() const = 0;

    friend ostream & operator<<(ostream & os, const atome & a) {
            os << a.to_string();

            return os;
    }
};


class atome_num: public atome {
public:
        int     valeur;

        atome_num(){}
        virtual ~atome_num(){}

        virtual string to_string()  const {return std::to_string(valeur);}
        virtual string id()         const {return to_string();}
};

class atome_var: public atome {
public:
    string nom;

    atome_var(){}
    virtual ~atome_var(){}
    virtual string to_string()  const{return nom;}
    virtual string id()         const{return nom;}
};

class atome_predicat: public atome {
public:

    string           predicat;
    vector<atome*>*  termes;
    atome_predicat():termes(nullptr){}
    virtual ~atome_predicat() {
        if (termes) {
            for (auto t: *termes)
                delete t;

            delete termes;
        }
    }

    size_t              arite() const{return termes->size();}

    string              to_string() const {
        ostringstream os;

        os << (negatif ? "¬" : "") << predicat;

        if (termes && arite() > 0) {
            os << "(";

            auto it = termes->begin();

            for (;it != termes->end() - 1; ++it) {
                os << **it << ", ";
            }

            os << **it << ")";
        }

        return os.str();
    }

    string              id() const {return predicat;}

    string              termes_to_string() const {
        ostringstream os;

        if (termes && arite() > 0) {
            auto it = termes->begin();

            for (;it != termes->end() - 1; ++it) {
                os << **it << ", ";
            }

            os << **it;
        }

        return os.str();
    }
};

class arithmetique;
ostream & operator<<(ostream & os, const arithmetique & a);

class atome_arithmetique: public atome {
public:


    arithmetique *      m_gauche;
    op_comp             op;
    arithmetique *      m_droit;

    atome_arithmetique():m_gauche(nullptr), op(op_NONE), m_droit(nullptr) {}
    ~atome_arithmetique() {
        if (m_gauche) delete m_gauche;
        if (m_droit) delete m_droit;
    }

    string  to_string() const {
        ostringstream os;

        if (m_gauche)
            os << *m_gauche;

        switch (op) {
            case op_GT:
                os << " > ";
                break;

            case op_GTE:
                os << " >= ";
                break;

            case op_LT:
                os << " < ";
                break;

            case op_LTE:
                os << " <= ";
                break;

            case op_EQ:
                os << " = ";
                break;

            case op_NEQ:
                os << " \\= ";
                break;

            case op_NONE:
                os << " ";
                break;

        }

        if (m_droit)
            os << *m_droit;

        return os.str();
    }

    virtual string  id() const {
        return "non sens";
    }
};

#endif
