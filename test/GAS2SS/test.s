	.file	"test.c"
	.data
	.align 32
_a:
	.long	1
	.long	2
	.long	4
	.long	5
	.long	6
	.space 20
	.def	___main;	.scl	2;	.type	32;	.endef
	.text
	.globl	_main
	.def	_main;	.scl	2;	.type	32;	.endef
_main:
LFB0:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	andl	$-16, %esp
	subl	$48, %esp
	call	___main
	movl	$0, 44(%esp)
	movl	$0, 40(%esp)
	movl	$0, 36(%esp)
	movl	$0, 32(%esp)
	movl	$0, 28(%esp)
	movl	40(%esp), %edx
	movl	36(%esp), %eax
	addl	%eax, %edx
	movl	32(%esp), %eax
	addl	%eax, %edx
	movl	28(%esp), %eax
	addl	%edx, %eax
	movl	%eax, 44(%esp)
	movl	$5, (%esp)
	call	_foo
	movl	$0, %eax
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
LFE0:
	.globl	_foo
	.def	_foo;	.scl	2;	.type	32;	.endef
_foo:
LFB1:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	movl	_abc.1407, %eax
	addl	$1, %eax
	movl	%eax, _abc.1407
	movl	$5, _b+4
	movl	_a, %edx
	movl	_b, %eax
	addl	%edx, %eax
	movl	%eax, 8(%ebp)
	popl	%ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
LFE1:
.lcomm _abc.1407,4,4
	.ident	"GCC: (GNU) 4.9.3"
