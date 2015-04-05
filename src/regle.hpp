#ifndef regle_h
#define regle_h

#include "atomes.hpp"
#include <vector>
#include <sstream>
#include <utility>


class regle{
public:
    atome_predicat* tete;
    vector<atome*>* corps;


    regle():tete(nullptr), corps(nullptr) {}

    virtual ~regle() {
        for (atome* i: *corps)
            delete i;

        delete corps;
    }

    string          to_string() const {
        ostringstream os;

        // os << "Tete : ";
        if (tete)
            os << *tete;
        // else
        //     os << "pas de tête" << endl;

        // os << "Corps : ";


        if (corps) {
            os << " -> ";
            auto it = corps->begin();

            if (it != corps->end()) {
                for (;it != corps->end() && it != corps->end() - 1; ++it)
                    os << **it << ", ";

                os << **it;
            }
        }
        // else {
        //     os << "pas de corps";
        // }
        return os.str();
    }

    friend ostream & operator<<(ostream & os, const regle & a) {
            os << a.to_string();

            return os;
    }
};


#endif
