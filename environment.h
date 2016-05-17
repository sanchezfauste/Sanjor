#ifndef ENVIRONMENT_H
#define ENVIRONMENT_H

#include <map>
#include <string>

using namespace std;

class Environment {

	Environment *previous_env;
	map<string, int> vars;
	int nvars;

public:

	Environment(Environment *previous_env);
	int get_var(const char *var);
	bool add_var(const char *var);
	bool check_var(const char *var);
	int get_nvars();
	Environment * get_previous_environment();

};

#endif