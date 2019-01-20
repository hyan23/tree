; tree/kernel/mouse.ss
; Author: hyan23
; Date: 2016.07.31
;

; mouse0代理

%include "../kernel/gate.ic"
%include "../kernel/cgcall.ic"
%include "../inc/nasm/tree.ic"


___TREE_IPT_LIB_BEGIN_

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'get_mouse_xy', get_mouse_xy
    __TREE_EXPORT @1, 'get_cursor_xy', get_cursor_xy
    __TREE_EXPORT @2, 'get_mouse_btn', get_mouse_btn

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax


get_mouse_xy:

    TREE_CALLGATE_CALL __GET_MOUSE_XY
    retf


get_cursor_xy:
    TREE_CALLGATE_CALL __GET_CURSOR_XY
    retf


get_mouse_btn:

    TREE_CALLGATE_CALL __GET_MOUSE_BTN
    retf



___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'mouse'
TREE_VER 0

TREE_CALLGATE_DATA __GET_MOUSE_XY
TREE_CALLGATE_DATA __GET_CURSOR_XY
TREE_CALLGATE_DATA __GET_MOUSE_BTN

___TREE_DATA_END_