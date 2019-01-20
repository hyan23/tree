; tree/usr/palette.ss
; Author: hyan23
; Date: 2016.08.01
;

; 第一个窗口应用程序, 调色板。

%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/def0.ic"
%include "../inc/nasm/tree/wnd/evtt.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0
    __TREE_LIB @1, 'wm', 0
    __TREE_LIB @2, 'texture', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @wm0, 'WMCreateWindow', WMCreateWindow
    __TREE_IMPORT @wm1, 'WMCloseWindow', WMCloseWindow
    __TREE_IMPORT @wm2, 'WMPollEvent', WMPollEvent

    __TREE_IMPORT @0, 'NewTexture', NewTexture
    __TREE_IMPORT @2, 'DestroyTexture', DestroyTexture
    __TREE_IMPORT @3, 'PrintTexture', PrintTexture
    __TREE_IMPORT @4, 'DrawRect', DrawRect
    __TREE_IMPORT @5, 'BlitTexture', BlitTexture

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    mov dx, TREE_PALETTE_WIDTH
    mov ax, TREE_PALETTE_HEIGHT
    mov ebx, TITLE
    TREE_CALL WMCreateWindow
    cmp ax, NUL_SEL
    jz .fin
    mov es, ax

    call near DrawPalette
    cmp ax, NUL_SEL
    jz .close

    mov ds, ax
    xor edx, edx
    xor eax, eax
    TREE_CALL BlitTexture
    TREE_CALL DestroyTexture

.s:
    TREE_CALL WMPollEvent
    cmp edx, TREE_EVENT_MSG_CLOSE
    jz .close
    TREE_SLEEP 50
    jmp near .s

.close:
    TREE_CALL WMCloseWindow

.fin:
    TREE_EXIT


; uint16:ax DrawPalette(void);
; 16 * 16
; rect: 20 * 20
; border: 2
; width: 2 + 16 * (2 + 20) = 354
; height: 2 + 16 * (2 + 20) = 354
; bgcolor: White
    TREE_PALETTE_RECT_EDGE  EQU     20
    TREE_PALETTE_BORDER     EQU     2
    TREE_PALETTE_WIDTH      EQU     356
    TREE_PALETTE_HEIGHT     EQU     356

DrawPalette:

    push ebx
    push ecx
    push edx
    push ds

    mov dx, TREE_PALETTE_WIDTH                   ; 外边框
    mov ax, TREE_PALETTE_HEIGHT
    mov cl, Color_White
    TREE_CALL NewTexture
    cmp ax, NUL_SEL
    jz .overflow
    TREE_CALL PrintTexture
    mov ds, ax

    mov dx, TREE_PALETTE_BORDER                  ; position.x
    xor ebx, ebx                                 ; counter/color
    mov ecx, 16
.s0:
    push ecx

    mov ax, TREE_PALETTE_BORDER                  ; position.y
    mov ecx, 16
.s1:
    push ecx

    push ebx
    mov bx, TREE_PALETTE_RECT_EDGE
    shl ebx, 16
    mov bx, TREE_PALETTE_RECT_EDGE
    mov cl, [ss:esp]                             ; color
    TREE_CALL DrawRect
    pop ebx

    add ax, TREE_PALETTE_RECT_EDGE + \
        TREE_PALETTE_BORDER
    inc ebx
    pop ecx
    loop .s1

    add dx, TREE_PALETTE_RECT_EDGE + \
        TREE_PALETTE_BORDER
    pop ecx
    loop .s0

    mov ax, ds

.fin:
    pop ds
    pop edx
    pop ecx
    pop ebx

    ret

.overflow:
    mov ax, NUL_SEL
    jmp near .fin


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'palette'
TREE_VER 0

TREE_STRING TITLE, 'Tree-Palette'
TREE_SZBUF szbuf, 128

___TREE_DATA_END_