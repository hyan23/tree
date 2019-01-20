; tree/usr/usr13.ss
; Author: hyan23
; Date: 2016.07.27
;

; 测试图形库

%include "../kernel/graphic/graphic.ic"
%include "../kernel/graphic/texture.ic"
%include "../inc/nasm/io/def0.ic"
%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'graphic', 0
    __TREE_LIB @1, 'conio', 0
    __TREE_LIB @2, 'agent', 0
    __TREE_LIB @3, 'texture', 0
    __TREE_LIB @4, 'font', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @2, 'refreshscr', refreshscr
    __TREE_IMPORT @1, 'puts', puts
    __TREE_IMPORT @5, 'putn', putn
    __TREE_IMPORT @4, 'alloc_memory0', alloc_memory0
    __TREE_IMPORT @7, 'NewTexture', NewTexture
    __TREE_IMPORT @8, 'BlitTexture', BlitTexture
    __TREE_IMPORT @9, 'DestroyTexture', DestroyTexture
    __TREE_IMPORT @10, 'PrintTexture', PrintTexture
    __TREE_IMPORT @11, 'DrawLine', DrawLine
    __TREE_IMPORT @12, 'DrawRect', DrawRect
    __TREE_IMPORT @13, 'DrawPixel', DrawPixel
    __TREE_IMPORT @14, 'FRenderText', FRenderText
    __TREE_IMPORT @15, 'FDestroyText', FDestroyText

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    mov dx, SCR_WIDTH
    mov ax, SCR_HEIGHT
    TREE_CALL NewTexture
    mov cl, Color_SteelBlue3
    TREE_CALL PrintTexture
    push ax

    mov dx, 300
    mov ax, 300
    TREE_CALL NewTexture
    mov cl, Color_PeachPuff1
    TREE_CALL PrintTexture
    push ax

    mov ch, Color_PeachPuff1
    mov cl, Color_White
    mov ebx, TEXT
    TREE_CALL FRenderText
    push ax

    mov ax, [ss:esp]
    mov ds, ax
    mov ax, [ss:(2 + esp)]
    mov es, ax
    mov dx, 20
    mov ax, 20
    TREE_CALL BlitTexture
    TREE_CALL FDestroyText

    mov ax, [ss:(2 + esp)]
    mov ds, ax
    mov dx, 40
    mov ax, 20
    mov bx, 400
    shl ebx, 16
    mov bx, 400
    mov cl, Color_SteelBlue3
    TREE_CALL DrawRect

    mov dx, 70
    mov ax, 200
    mov cl, 145
    TREE_CALL DrawPixel

    mov ax, [ss:(4 + esp)]
    mov es, ax
    xor dx, dx
    xor ax, ax
    mov dx, 200
    mov ax, 500
    TREE_CALL BlitTexture
    TREE_CALL DestroyTexture

    mov ax, [es:TREE_TEXTURE_TEXTURE_OFS]
    mov ds, ax
    xor ebx, ebx
    TREE_CALL refreshscr

    TREE_EXIT

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr13'
TREE_VER 0
TREE_STRING TEXT, 'hello world!\n'

___TREE_DATA_END_