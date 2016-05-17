#include "functions.h"
#include <map>
#include <string>

using namespace std;

int Functions::get_function_offset(const char *var) {
	if (functions.count(string(var))) {
		return functions[string(var)];
	} else {
		return -1;
	}
}

bool Functions::add_function(const char *var, int offset) {
	if (functions.count(string(var))) {
		return false;
	} else {
		functions[string(var)] = offset;
		return true;
	}
}