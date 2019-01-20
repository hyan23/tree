; tree/kernel/graphic/graphic.ss
; Author: hyan23
; Date: 2016.05.03
;

; 用户态

%include "../kernel/gate.ic"
%include "../kernel/cgcall.ic"
%include "../inc/nasm/tree.ic"


___TREE_IPT_LIB_BEGIN_

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @1, 'refreshscr', refreshscr

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax


refreshscr:
    TREE_CALLGATE_CALL __REFRESH_SCR
    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'graphic'
TREE_VER 0

TREE_CALLGATE_DATA __REFRESH_SCR


___TREE_DATA_END_