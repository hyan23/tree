; tree/usr/usr07.ss
; Author: hyan23
; Date: 2016.06.02
;

; 测试保护模式

%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @1, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @5, 'puts0', puts0

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:

    mov ebx, back0
    TREE_CALL puts0

    xor eax, eax
    TREE_EXIT TREE_EXEC_RET_COM, eax

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr06'
TREE_VER 0

TREE_STRING back0, 'welcome back to con.'

___TREE_DATA_END_