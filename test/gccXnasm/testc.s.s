[FORMAT "WCOFF"]
[INSTRSET "i486p"]
[OPTIMIZE 1]
[OPTION 1]
[BITS 32]
	EXTERN	_sayhello
	EXTERN	_fun
[FILE "testc.c"]
[SECTION .text]
	GLOBAL	___main
___main:
LFB0:
	PUSH	EBP
	MOV	EBP,ESP
	SUB	ESP,24
	MOV	DWORD [-16+EBP],0
	LEA	EAX,DWORD [-16+EBP]
	MOV	DWORD [-12+EBP],EAX
	MOV	EAX,DWORD [-12+EBP]
	MOV	DWORD [EAX],10
	CALL	_sayhello
	CALL	_fun
	LEAVE
	RET
LFE0:
	GLOBAL	_foo1
_foo1:
LFB1:
	PUSH	EBP
	MOV	EBP,ESP
	POP	EBP
	RET
LFE1:
	GLOBAL	_foo
_foo:
LFB2:
	PUSH	EBP
	MOV	EBP,ESP
	POP	EBP
	RET
LFE2:
