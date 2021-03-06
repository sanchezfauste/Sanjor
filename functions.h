#ifndef FUNCTIONS_H
#define FUNCTIONS_H

#include <map>
#include <string>

using namespace std;

class Functions {

	map<string, int> functions;

public:

	int get_function_offset(const char *function);
	bool add_function(const char *function, int offset);

};

#endif