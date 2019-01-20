[FORMAT "WCOFF"]
[INSTRSET "i486p"]
[OPTIMIZE 1]
[OPTION 1]
[BITS 32]
	EXTERN	___main
[FILE "test3.cpp"]
[SECTION .text]
	GLOBAL	_main
_main:
LFB0:
	PUSH	EBP
	MOV	EBP,ESP
	AND	ESP,-16
	SUB	ESP,16
	CALL	___main


	mov DWORD [12 + esp], 0
	jmp L2
L3:
	add DWORD [12 + esp], 1
L2:
	cmp DWORD [12 + esp], 149999999
	jle L3



	MOV	EAX,0
	LEAVE
	RET
LFE0:
