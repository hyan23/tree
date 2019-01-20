static int a[10] = { 1, 2, 4, 5 ,6 };
extern int b[10];


void foo(int );

int main(int argc, char* argv[] ) {
	int c = 0, d = 0, e = 0, f = 0, g = 0;
	c = d + e + f + g;
	foo(5 );
	return 0;
}

void foo(int val ) {
	static int abc = 0;
	abc ++;
	val + val;
	b [1] = 5;
	val = a[0] + b[0];
}