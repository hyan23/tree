; tree/usr/debug.ss
; Author: hyan23
; Date: 2016.08.02
;

; 控制台调试。


%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @444, 'puts', puts
    __TREE_IMPORT @445, 'putn', putn

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
.fin:
    TREE_EXIT


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'debug'
TREE_VER 0

___TREE_DATA_END_