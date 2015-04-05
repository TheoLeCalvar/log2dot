#ifndef arithmetique_h
#define arithmetique_h

#include "atomes.hpp"
#include <sstream>

class arithmetique;
ostream & operator<<(ostream & os, const arithmetique & a);

class arithmetique{
public:
    typedef enum {
        PLUS,
        MOINS,
        FOIS,
        DIVISE,
        NONE
    } op_e;

    op_e        operation;
    atome_num * num;
    atome_var * var;
    arithmetique* m_droit;

    arithmetique():operation(NONE), num(nullptr), var(nullptr), m_droit(nullptr) {}
    virtual ~arithmetique() {
        if (var) delete var;
        if (num) delete num;
        if (m_droit) delete m_droit;
    }

    string  to_string() const {
        ostringstream os;

        if (num)
            os << *num;
        else
            os << *var;

        switch (operation) {
            case PLUS:
                os << " + ";
                break;

            case MOINS:
                os << " - ";
                break;

            case FOIS:
                os << " * ";
                break;

            case DIVISE:
                os << " / ";
                break;

            case NONE:
                os << " ";
                break;
        }

        if (m_droit)
            os << *m_droit;

        return os.str();
    }

    friend ostream & operator<<(ostream & os, const arithmetique & a) {
            os << a.to_string();
            return os;
    }

};



#endif
