; tree/usr/usr05.ss
; Author: hyan23
; Date: 2016.05.29
;

; 测试 kernel/graphic

%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'graphic', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'startg', startg
    __TREE_IMPORT @2, 'exitg', exitg
    __TREE_IMPORT @1, 'drawpixel', drawpixel

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:

   TREE_CALL startg

    mov cx, 200                                  ; 浅蓝色填充屏幕
.s:
    push cx
    mov dx, cx
    dec dx
    mov cx, 320
.s0:
    push cx
    mov ax, cx
    dec ax
    mov cl, 100
    TREE_CALL drawpixel
    pop cx
    loop .s0
    hlt
    pop cx
    loop .s

    xor eax, eax
    TREE_EXIT TREE_EXEC_RET_COM, eax

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr05'
TREE_VER 0


___TREE_DATA_END_