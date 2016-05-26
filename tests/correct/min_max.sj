int get_min(int v[3]) {
	if (v[0] <= v[1] && v[0] <= v[2]) {
		return v[0];
	} else {
		if (v[1] <= v[2] && v[1] <= v[0]) {
			return v[1];
		} else {
			return v[2];
		}
	}
}

int get_max(int v[3]) {
	if (v[0] >= v[1] && v[0] >= v[2]) {
		return v[0];
	} else {
		if (v[1] >= v[2] && v[1] >= v[0]) {
			return v[1];
		} else {
			return v[2];
		}
	}
}

int v[3];
v[0] = 7;
v[1] = 4;
v[2] = 74;
puts "Getting min of 7, 4, 74...";
write get_min(v[]);
puts "Getting max of 7, 4, 74...";
write get_max(v[]);