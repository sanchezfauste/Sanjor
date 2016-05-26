int sum (int v[4]) {
	int sum;
	sum = 0;
	int i;
	i = 0;
	while (i < length(v)) {
		sum = sum + v[i];
		i = i + 1;
	}
	return sum;
}

puts "Sum elements of vector [1, 3, 4, 2]...";
int v[4];
v[0] = 1;
v[1] = 3;
v[2] = 4;
v[3] = 2;
write sum(v[]);
