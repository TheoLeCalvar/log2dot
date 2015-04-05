#ifndef atomes_h
#define atomes_h

#include <sstream>
#include <vector>

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
        for (auto t: *termes)
            delete t;

        delete termes;
    }

    size_t              arite() const{return termes->size();}

    string              to_string() const {
        ostringstream os;

        os << predicat;

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
    typedef enum {
        GT,
        GTE,
        LT,
        LTE,
        EQ,
        NEQ
    } op_comp;

    atome_var *         m_gauche;
    op_comp             op;
    arithmetique *      m_droit;

    atome_arithmetique():m_gauche(nullptr), op(EQ), m_droit(nullptr) {}
    ~atome_arithmetique() {
        if (m_gauche) delete m_gauche;
        if (m_droit) delete m_droit;
    }

    string  to_string() const {
        ostringstream os;

        if (m_gauche && m_droit) {
            os << *m_gauche;

            switch (op) {
                case GT:
                    os << " > ";
                    break;

                case GTE:
                    os << ' >= ';
                    break;

                case LT:
                    os << " < ";
                    break;

                case LTE:
                    os << " <= ";
                    break;

                case EQ:
                    os << " = ";
                    break;

                case NEQ:
                    os << " \\= ";
                    break;

            }

            os << *m_droit;
        }

        return os.str();
    }

    virtual string  id() const {
        return m_gauche->id();
    }
};

#endif
