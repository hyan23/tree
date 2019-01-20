; tree/usr/usr09.ss
; Author: hyan23
; Date: 2016.07.02
;

%include "../boot/gdt.ic"
%include "../kernel/gate.ic"
%include "../inc/nasm/tree.ic"


; 测试任务切换

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'putchar', putchar
    __TREE_IMPORT @3, 'puts', puts

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
.s:
    mov cl, ' '
    TREE_CALL putchar
    mov ebx, SAYHELLO
    TREE_CALL puts

    jmp .s

    xor eax, eax
    TREE_EXIT TREE_EXEC_RET_COM, eax

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'help'
TREE_VER 0

TREE_STRING SAYHELLO, \
    '  belows are the instructions that supported:\n\
    sayhello  sh     nowtime   whoami\n\
    calc      clear  help      exit\n'

___TREE_DATA_END_