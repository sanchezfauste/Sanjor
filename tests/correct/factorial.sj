int fact(int n) {
	if (n == 0) {
		return 1;
	} else {
		return n * fact(n-1);
	}
}

puts "Calculating fact(6)...";
write fact(6);