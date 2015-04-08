#include "toDot.hpp"

void save_to_dot(const string & path, vector<regle*> & faits, vector<regle*> regles, vector<regle*> contraintes) {
    ofstream    of(path);
    int         cluster_count = 0;
    regex       quotes("\"|'");

    if (!of) {
        cout << "Erreur d'ouverture du fichier";
        return;
    }

    of <<   "digraph {\n"
            "\trankdir = LR;\n";

    //traitement des faits
    of <<   "\tsubgraph cluster_" << cluster_count++ << "{\n"
            "\t\tlabel=\"Faits\";\n";
    for (regle* r: faits) {
        //on échappe les quotes
        of <<   "\t\t\"" << regex_replace(r->tete->to_string(), quotes, "\\$&") << "\";\n";
    }
    of <<   "\t}\n";


    //traitement des règles
    for (regle* r: regles) {
        vector<pair<string, string>> p_gauche;
        string termes = r->tete->termes_to_string();


        of <<   "\tsubgraph cluster_" << cluster_count << "{\n"
                "\t\tlabel=\"Régle " << cluster_count << "\";\n";



        //on génère les parties droites
        for (atome * a: *r->tete->termes) {
            ostringstream os;
            os << "r" << cluster_count << "_" << r->tete->predicat << "_" << a->id() << "(" << termes << ")";

            p_gauche.push_back(make_pair(regex_replace(os.str(), quotes, "\\$&"), a->id()));

            of << "\t\t\"" << p_gauche.back().first << "\";\n";
        }

        //on génère les parties gauches
        for (atome * a: *r->corps) {
            atome_predicat * a1 = dynamic_cast<atome_predicat*>(a);

            if (a1) {
                string termes = a1->termes_to_string();

                if (a1->termes)
                    for (atome *b: *a1->termes) {
                        bool          alone = true;
                        ostringstream os2;
                        os2 << "r" << cluster_count << "_" << a1->predicat << "_" << b->id() << "(" << termes << ")";
                        string p_droite = regex_replace(os2.str(), quotes, "\\$&");

                        for (pair<string, string> p: p_gauche) {
                            if (b->id() == p.second) {
                                of << "\t\t\"" << p_droite << "\"" << " -> " << "\"" << p.first << "\"" << (a->negatif ? " [style=dashed] " : "") << ";\n";
                                alone = false;
                            }
                        }

                        if(alone)
                            of << "\t\t\"" << p_droite << "\";\n";
                    }
            }
        }


        of << "\t}\n";
        cluster_count++;
    }



    //traitement des contraintes
    for (regle* r: contraintes) {
        of <<   "\tsubgraph cluster_" << cluster_count << "{\n"
                "\t\tlabel=\"Contrainte " << cluster_count << "\";\n"
                "\t\tr_" << cluster_count << "_contraintes_⊥ [label=⊥];\n";

            for (atome* a: *r->corps) {
                atome_predicat * a1 = nullptr;
                if ((a1 = dynamic_cast<atome_predicat *>(a))) {

                    string termes = a1->termes_to_string();

                    if (a1->termes)
                        for (atome* b: *a1->termes) {
                            ostringstream os;
                            if (dynamic_cast<atome_var*>(b)) {
                                os << "r" << cluster_count << "_" << a1->predicat << "_" << b->id() << "(" << termes << ")";

                                of << "\t\t\"" << regex_replace(os.str(), quotes, "\\$&") << "\"-> r_" <<cluster_count << "_contraintes_⊥;\n";
                            }
                        }

                }

            }

        of << "\t}\n";
        cluster_count++;

    }

    of << "}";

    of.close();
}
