; tree/usr/nowtime.ss
; Author: hyan23
; Date: 2016.05.29
;

%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/def0.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0
    __TREE_LIB @1, 'time', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'puts', puts
    __TREE_IMPORT @1, 'puts0', puts0
    __TREE_IMPORT @2, 'gettime_str', gettime_str

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    mov ebx, SAYHELLO
    TREE_CALL puts
    mov ebx, time
    TREE_CALL gettime_str
    TREE_CALL puts0

    TREE_EXIT

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'nowtime'
TREE_VER 0

TREE_STRING SAYHELLO, 'now time is: '
TREE_SZBUF time, 9

___TREE_DATA_END_