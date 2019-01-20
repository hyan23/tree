; tree/inc/nasm/io/readisk.ss
; Author: hyan23
; Date: 2016.05.02
;

%include "../inc/nasm/tree.ic"
%include "../boot/absc.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'agent', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'readsec', readsec
    __TREE_EXPORT @1, 'readblock', readblock

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'read_sector', read_sector
    __TREE_IMPORT @1, 'read_block', read_block

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax

; readsec

readsec:                                         ; 托管
    TREE_CALL read_sector

    retf


; readblock

readblock:                                       ; 托管
    TREE_CALL read_block

    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'readisk'
TREE_VER 0

___TREE_DATA_END_