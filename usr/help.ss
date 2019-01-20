; tree/usr/help.ss
; Author: hyan23
; Date: 2016.05.29
;

%include "../boot/gdt.ic"
%include "../kernel/gate.ic"
%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @3, 'puts', puts

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    mov ebx, SAYHELLO
    TREE_CALL puts

    TREE_EXIT

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'help'
TREE_VER 0

TREE_STRING SAYHELLO, \
    '  belows are the instructions that supported:\n\
    sayhello  sh     nowtime   whoami\n\
    calc      clear  help      exit\n'

___TREE_DATA_END_