#ifndef ENVIRONMENT_H
#define ENVIRONMENT_H

#include <map>
#include <string>

using namespace std;

enum Type {
	integer, character
};

typedef struct Var {
	int offset;
	int size;
	bool is_const;
	bool is_defined;
	Type type;
} Var;

class Environment {

	Environment *previous_env;
	map<string, Var*> vars;
	int nvars;

public:

	Environment(Environment *previous_env);
	int get_var(const char *var, int offset = 0);
	bool add_var(const char *var, int size = 1, bool is_const = false,
		Type type = integer);
	bool check_var(const char *var);
	bool check_var_offset(const char *var, int offset);
	bool check_var_const(const char *var);
	bool check_var_defined(const char *var);
	void set_var_defined(const char *var);
	int get_var_length(const char *var);
	int get_nvars();
	Environment * get_previous_environment();

};

#endif