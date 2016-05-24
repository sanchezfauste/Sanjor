#include "environment.h"
#include <map>
#include <string>
#include <stdlib.h>

using namespace std;

Environment::Environment(Environment *previous_env) :
	previous_env(previous_env), nvars(0) {}

int Environment::get_var(const char *var, int offset) {
	return vars[string(var)]->offset + offset;
}

bool Environment::add_var(const char *var, int size, bool is_const) {
	if (vars.count(string(var))) {
		return false;
	} else {
		Var *v = (Var*) malloc(sizeof(Var));
		v->offset = nvars;
		v->size = size;
		v->is_const = is_const;
		nvars += size;
		vars[string(var)] = v;
		return true;
	}
}

bool Environment::check_var(const char *var) {
	return vars.count(string(var));
}

bool Environment::check_var_offset(const char *var, int offset) {
	return vars[string(var)]->size > offset;
}

bool Environment::check_var_const(const char *var) {
	return vars[string(var)]->is_const;
}

bool Environment::check_var_defined(const char *var) {
	return vars[string(var)]->is_defined;
}

void Environment::set_var_defined(const char *var) {
	vars[string(var)]->is_defined = true;
}

int Environment::get_nvars() {
	return nvars;
}

int Environment::get_var_length(const char *var) {
	return vars[string(var)]->size;
}

Environment * Environment::get_previous_environment() {
	return previous_env;
}