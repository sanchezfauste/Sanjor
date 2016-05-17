#include "environment.h"
#include <map>
#include <string>

using namespace std;

Environment::Environment(Environment *previous_env) :
	previous_env(previous_env), nvars(0) {}

int Environment::get_var(const char *var) {
	return vars[string(var)];
}

bool Environment::add_var(const char *var) {
	if (vars.count(string(var))) {
		return false;
	} else {
		vars[string(var)] = nvars++;
		return true;
	}
}

bool Environment::check_var(const char *var) {
	return vars.count(string(var));
}

int Environment::get_nvars() {
	return nvars;
}

Environment * Environment::get_previous_environment() {
	return previous_env;
}