; tree/usr/usr01.ss
; Author: hyan23
; Date: 2016.05.18
;

; 测试 kernel/time

%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/public.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0
    __TREE_LIB @2, 'time', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'puts', puts
    __TREE_IMPORT @4, 'putchar', putchar
    __TREE_IMPORT @1, 'getime', getime
    __TREE_IMPORT @2, 'putbcd', putbcd
    __TREE_IMPORT @5, 'clrscr', clrscr

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:

%macro PUT_COLON 0
    mov cl, ':'
    TREE_CALL putchar
%endmacro

    mov bx, SZ_SAYHELLO
    TREE_CALL puts

    TREE_CALL clrscr
.s0:
    mov cl, ASCLL_CR
    TREE_CALL putchar
    TREE_CALL getime
    push cx
    mov cx, dx
    TREE_CALL putbcd
    PUT_COLON
    pop cx
    TREE_CALL putbcd
    PUT_COLON
    mov cx, ax
    TREE_CALL putbcd
    hlt
    jmp .s0

    xor eax, eax
    TREE_EXIT TREE_EXEC_RET_COM, eax

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr01'
TREE_VER 0
TREE_STRING SZ_SAYHELLO, 'hello.\n'

___TREE_DATA_END_