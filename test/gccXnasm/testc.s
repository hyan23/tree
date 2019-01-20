	.file	"testc.c"
	.text
	.globl	___main
	.def	___main;	.scl	2;	.type	32;	.endef
___main:
LFB0:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$24, %esp
	movl	$0, -16(%ebp)
	leal	-16(%ebp), %eax
	movl	%eax, -12(%ebp)
	movl	-12(%ebp), %eax
	movl	$10, (%eax)
	call	_sayhello
	call	_fun
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
LFE0:
	.globl	_foo1
	.def	_foo1;	.scl	2;	.type	32;	.endef
_foo1:
LFB1:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	popl	%ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
LFE1:
	.globl	_foo
	.def	_foo;	.scl	2;	.type	32;	.endef
_foo:
LFB2:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	popl	%ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
LFE2:
	.ident	"GCC: (GNU) 4.9.3"
	.def	_sayhello;	.scl	2;	.type	32;	.endef
	.def	_fun;	.scl	2;	.type	32;	.endef
