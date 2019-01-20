; tree/usr/usr08.ss
; Author: hyan23
; Date: 2016.07.01
;

; 测试 tree/kernel/task.ss

%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'task', 0
    __TREE_LIB @1, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @1, 'InitTcbChain', InitTcbChain
    __TREE_IMPORT @0, 'CreateProcess', CreateProcess
    __TREE_IMPORT @5, 'puts0', puts0

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:


    xor eax, eax
    TREE_EXIT TREE_EXEC_RET_COM, eax

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr08'
TREE_VER 0

TREE_STRING back0, 'welcome back to con.'

___TREE_DATA_END_