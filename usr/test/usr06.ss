; tree/usr/usr06.ss
; Author: hyan23
; Date: 2016.06.02
;

; 测试 kernel/graphic/drawline

%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'graphic', 0
    __TREE_LIB @1, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'startg', startg
    __TREE_IMPORT @2, 'exitg', exitg
    __TREE_IMPORT @1, 'drawline', drawline
    __TREE_IMPORT @4, 'printscr', printscr
    __TREE_IMPORT @5, 'puts0', puts0

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:

    TREE_CALL startg

    mov cl, 0x50
    TREE_CALL printscr                           ; 浅蓝色填充屏幕

    mov cx, 256
.s:
    push cx
    mov ax, cx
    dec ax
    mov dx, -1
                                                 ;mov dx, cx
    sub dx, 120
    dec cx
    TREE_CALL drawline
    pop cx
                                                 ;sub cx, 4
    hlt
    loop .s

    TREE_CALL exitg
    TREE_LOCATE_DATA
    mov bx, back0
    TREE_CALL puts0

    xor eax, eax
    TREE_EXIT TREE_EXEC_RET_COM, eax

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr06'
TREE_VER 0

TREE_STRING back0, 'welcome back to con.'

___TREE_DATA_END_