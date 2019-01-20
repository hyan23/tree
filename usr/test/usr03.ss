; tree/usr/usr03.ss
; Author: hyan23
; Date: 2016.05.29
;

; 测试 util/string::strlen

%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/public.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0
    __TREE_LIB @1, 'kbd', 0
    __TREE_LIB @2, 'string', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @4, 'puts0', puts0
    __TREE_IMPORT @5, 'puts', puts
    __TREE_IMPORT @0, 'gets', gets
    __TREE_IMPORT @3, 'getchar', getchar
    __TREE_IMPORT @2, 'putchar', putchar
    __TREE_IMPORT @20, 'putn', putn
    __TREE_IMPORT @21, 'strlen', strlen

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    TREE_LOCATE_DATA

.s0:
    mov ebx, szbuf
    mov ecx, 10
    TREE_CALL gets
    TREE_CALL strlen
    mov ebx, sz01
    TREE_CALL puts
    TREE_CALL putn
    mov ebx, sz02
    TREE_CALL puts
    jmp near .s0

    xor eax, eax
    TREE_EXIT TREE_EXEC_RET_COM, eax

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr03'
TREE_VER 0

TREE_STRING sz01, 'strlen: '
TREE_STRING sz02, '\n'

TREE_SZBUF szbuf, 128

___TREE_DATA_END_