; tree/usr/counter.ss
; Author: hyan23
; Date: 2016.08.03
;

; 窗口程序样例。

%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/def0.ic"
%include "../inc/nasm/tree/wnd/evtt.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0
    __TREE_LIB @1, 'wm', 0
    __TREE_LIB @2, 'texture', 0
    __TREE_LIB @3, 'font', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @wm0, 'WMCreateWindow', WMCreateWindow
    __TREE_IMPORT @wm1, 'WMCloseWindow', WMCloseWindow
    __TREE_IMPORT @wm2, 'WMPollEvent', WMPollEvent

    __TREE_IMPORT @1, 'NewTexture', NewTexture
    __TREE_IMPORT @2, 'DestroyTexture', DestroyTexture
    __TREE_IMPORT @3, 'PrintTexture', PrintTexture
    __TREE_IMPORT @4, 'DrawRect', DrawRect
    __TREE_IMPORT @5, 'BlitTexture', BlitTexture

    __TREE_IMPORT @6, 'FRenderText', FRenderText
    __TREE_IMPORT @7, 'FDestroyText', FDestroyText

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    mov dx, 220
    mov ax, 100
    mov ebx, TITLE
    TREE_CALL WMCreateWindow
    cmp ax, NUL_SEL
    jz .fin
    mov es, ax

    call near DrawHello
    cmp ax, NUL_SEL
    jz .fin0
    mov ds, ax

    mov dx, 40
    mov ax, 40
    TREE_CALL BlitTexture
    TREE_CALL DestroyTexture

.s:
    TREE_CALL WMPollEvent
    cmp edx, TREE_EVENT_MSG_CLOSE
    jz .fin0
    TREE_SLEEP 50
    jmp near .s

.fin0:
    TREE_CALL WMCloseWindow
.fin:

    TREE_EXIT


; uint16:ax DrawHello(void);

DrawHello:

    push ebx
    push ecx
    push ds

    TREE_LOCATE_DATA
    mov ebx, HELLO
    mov ch, Color_Black
    mov cl, Color_White
    TREE_CALL FRenderText
    cmp ax, NUL_SEL
    jz .overflow

.fin:
    pop ds
    pop ecx
    pop ebx

    ret

.overflow:
    mov ax, NUL_SEL
    jmp near .fin


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'counter'
TREE_VER 0

TREE_STRING TITLE, 'counter'
TREE_STRING HELLO, 'hello world!'

___TREE_DATA_END_