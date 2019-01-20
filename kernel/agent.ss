; tree/kernel/agent.ss
; Author: hyan23
; Date: 2016.06.17
;

; 封装所有特权代码调用, 从调用门进入。

; 新增代理方法:

%include "../kernel/cgcall.ic"
%include "../kernel/pci0.ic"
%include "../kernel/gate.ic"
%include "../kernel/xfile.ic"
%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'read_sector', read_sector
    __TREE_EXPORT @1, 'read_block', read_block
    __TREE_EXPORT @2, 'put_char', put_char
    __TREE_EXPORT @3, 'put_str', put_str
    __TREE_EXPORT @20, 'set_color', set_color
    __TREE_EXPORT @21, 'clr_row', clr_row
    __TREE_EXPORT @22, 'clr_scr', clr_scr
    __TREE_EXPORT @23, 'goto_xy', goto_xy
    __TREE_EXPORT @9, 'tree_execute', tree_execute
    __TREE_EXPORT @10, 'tree_terminate', tree_terminate
    __TREE_EXPORT @11, 'memcpy', memcpy
    __TREE_EXPORT @24, 'ZeroMemory', ZeroMemory  ; new
    __TREE_EXPORT @13, 'alloc_memory0', alloc_memory0
    __TREE_EXPORT @16, 'free_memory', free_memory
    __TREE_EXPORT @19, 'get_des_property', get_des_property

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:

    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax


read_sector:
    TREE_CALLGATE_CALL __READ_SECTOR
    retf


read_block:
    TREE_CALLGATE_CALL __READ_BLOCK
    retf


put_char:
    TREE_CALLGATE_CALL __PUT_CHAR
    retf


put_str:
    TREE_CALLGATE_CALL __PUT_STR
    retf


set_color:
    TREE_CALLGATE_CALL __SET_COLOR
    retf


clr_row:
    TREE_CALLGATE_CALL __CLR_ROW
    retf


clr_scr:
    TREE_CALLGATE_CALL __CLR_SCR
    retf


goto_xy:
    TREE_CALLGATE_CALL __GOTO_XY
    retf


tree_execute:
    TREE_CALLGATE_CALL __TREE_EXECUTE
    retf


tree_terminate:
    TREE_CALLGATE_CALL __TREE_TERMINATE
    retf


memcpy:
    TREE_CALLGATE_CALL __MEMCPY
    retf


ZeroMemory:
    TREE_CALLGATE_CALL __ZEROMEMORY
    retf


alloc_memory0:
    push ebx
    mov ebx, 3
    TREE_CALLGATE_CALL __ALLOC_MEMORY0
    cmp ax, NUL_SEL
    jz .fin
    or ax, 0000000000000_0_11b
.fin:
    pop ebx
    retf


free_memory:
    TREE_CALLGATE_CALL __FREE_MEMORY
    retf


get_des_property:
    TREE_CALLGATE_CALL __GET_DES_PROPERTY
    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'agent'
TREE_VER 0
                                                 ; 调用门缓存数据
    TREE_CALLGATE_DATA __READ_SECTOR
    TREE_CALLGATE_DATA __READ_BLOCK

    TREE_CALLGATE_DATA __PUT_CHAR
    TREE_CALLGATE_DATA __PUT_STR
    TREE_CALLGATE_DATA __SET_COLOR
    TREE_CALLGATE_DATA __CLR_ROW
    TREE_CALLGATE_DATA __CLR_SCR
    TREE_CALLGATE_DATA __GOTO_XY

    TREE_CALLGATE_DATA __TREE_EXECUTE
    TREE_CALLGATE_DATA __TREE_TERMINATE

    TREE_CALLGATE_DATA __MEMCPY
    TREE_CALLGATE_DATA __ZEROMEMORY
    TREE_CALLGATE_DATA __ALLOC_MEMORY0
    TREE_CALLGATE_DATA __FREE_MEMORY
    TREE_CALLGATE_DATA __GET_DES_PROPERTY


___TREE_DATA_END_