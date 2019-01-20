; tree/usr/hello.ss
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

    __TREE_IMPORT @0, 'WMCreateWindow', WMCreateWindow
    __TREE_IMPORT @10, 'WMPollEvent', WMPollEvent
    __TREE_IMPORT @13, 'WMCloseWindow', WMCloseWindow

    __TREE_IMPORT @1, 'NewTexture', NewTexture
    __TREE_IMPORT @2, 'DestroyTexture', DestroyTexture
    __TREE_IMPORT @3, 'PrintTexture', PrintTexture
    __TREE_IMPORT @4, 'DrawRect', DrawRect
    __TREE_IMPORT @5, 'BlitTexture', BlitTexture

    __TREE_IMPORT @6, 'FRenderText', FRenderText
    __TREE_IMPORT @7, 'FDestroyText', FDestroyText

    __TREE_IMPORT @11, 'putn', putn

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    mov dx, 220                                  ; 创建窗口
    mov ax, 100
    mov ebx, TITLE
    TREE_CALL WMCreateWindow
    cmp ax, NUL_SEL
    jz .fin
    mov es, ax

    call near DrawHello                          ; 渲染文字
    cmp ax, NUL_SEL
    jz .fin
    mov ds, ax

    mov dx, 40                                   ; 动起来
    mov ax, 40
.s:
    push edx
    push eax
    TREE_CALL WMPollEvent                        ; 如果有事件
    pop eax
    cmp edx, TREE_EVENT_NOTHING
    jz .j0
    cmp edx, TREE_EVENT_MSG_CLOSE
    jz .close

    add ax, 20
    cmp ax, 230
    jng .j0
    mov ax, 230

.j0:
    pop edx

    dec ax
    cmp ax, -130
    jnl .j
    mov ax, 230
.j:
    TREE_CALL BlitTexture
    TREE_SLEEP 30
    jmp near .s
; ---------------------------------

.close:
    pop edx
    TREE_CALL DestroyTexture
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

TREE_NAME 'hello'
TREE_VER 0

TREE_STRING TITLE, 'hello'
TREE_STRING HELLO, 'hello world!'

___TREE_DATA_END_