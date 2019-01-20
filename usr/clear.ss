; tree/usr/clear.ss
; Author: hyan23
; Date: 2016.05.29
;

%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @3, 'clrscr', clrscr

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    TREE_CALL clrscr

    TREE_EXIT

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'clear'
TREE_VER 0

___TREE_DATA_END_