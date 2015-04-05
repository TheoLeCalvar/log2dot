#ifndef toDot_h
#define toDot_h

#include "regle.hpp"
#include "arithmetique.hpp"
#include "atomes.hpp"

#include <iostream>
#include <sstream>
#include <vector>
#include <fstream>
#include <regex>

using namespace std;

void save_to_dot(const string & path, vector<regle*> & faits, vector<regle*> regles, vector<regle*> contraintes);

#endif
