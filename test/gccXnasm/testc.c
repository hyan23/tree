extern void sayhello(void);
extern void fun(void);

// extern int printf(const char* format, ...);
extern int puts(const char* src);

int __main(void) {
	int a = 0;
	int* p = &a;

	*p = 10;
	sayhello();
	// puts("hello!");
	// printf("hello again.\n");
	fun();
}

void foo1(int a) {

}

void foo(void) {
	;
}