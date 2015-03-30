%{
#include <stdio>

using namespace std;


void yyerror(char* s) {
        cout << "Error with : " << s << endl;
}


%}



%%


int main(int argc, char ** argv) {
        yyparse();
}
