	.file	"testc1.c"
	.text
	.globl	_fun
	.def	_fun;	.scl	2;	.type	32;	.endef
_fun:
LFB0:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$24, %esp
	movl	$15, (%esp)
	call	_foo1
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
LFE0:
	.ident	"GCC: (GNU) 4.9.3"
	.def	_foo1;	.scl	2;	.type	32;	.endef
