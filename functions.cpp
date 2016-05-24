#include "functions.h"
#include <map>
#include <string>

using namespace std;

int Functions::get_function_offset(const char *function) {
	if (functions.count(string(function))) {
		return functions[string(function)];
	} else {
		return -1;
	}
}

bool Functions::add_function(const char *function, int offset) {
	if (functions.count(string(function))) {
		return false;
	} else {
		functions[string(function)] = offset;
		return true;
	}
}