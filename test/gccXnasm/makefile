install:
	make.exe -r testc.exe

clean:
	del testc.s
	del testc.o
	del testc1.s
	del testc1.o
	del nasm.o

testc.o: ..\..\sft\gcc\cc1.exe testc.c
	..\..\sft\gcc\cc1.exe testc.c
	..\..\sft\gcc\as.exe testc.s -o testc.o

testc1.o: ..\..\sft\gcc\cc1.exe testc1.c
	..\..\sft\gcc\cc1.exe testc1.c
	..\..\sft\gcc\as.exe testc1.s -o testc1.o

nasm.o: ..\..\sft\nasm\nasm.exe nasm
	..\..\sft\nasm\nasm.exe nasm -f elf -o nasm.o

testc.exe: testc.o testc1.o nasm.o
	..\..\sft\gcc\ld.exe -s -o testc.exe testc.o testc1.o nasm.o