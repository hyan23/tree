; tree/usr/etracker.ss
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
    __TREE_LIB @4, 'queue', 0
    __TREE_LIB @5, 'string', 0

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

    __TREE_IMPORT @10, 'QueueCreate', QueueCreate
    __TREE_IMPORT @11, 'QueueDestroy', QueueDestroy
    __TREE_IMPORT @12, 'QueuePushBack', QueuePushBack
    __TREE_IMPORT @13, 'QueueGetFront', QueueGetFront
    __TREE_IMPORT @14, 'QueuePopFront', QueuePopFront
    __TREE_IMPORT @15, 'QueueGet', QueueGet

    __TREE_IMPORT @string0, 'strcpy', strcpy
    __TREE_IMPORT @string1, 'strcat', strcat
    __TREE_IMPORT @string2, 'itos', itos

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

    TREE_ETRACKER_QUEUE_LEN     EQU     6

TREE_START:
    mov dx, 300
    mov ax, 300
    TREE_CALL NewTexture
    mov cl, Color_White
    TREE_CALL PrintTexture
    push ax

    mov dx, 300                                  ; 创建窗口
    mov ax, 200
    mov ebx, TITLE
    TREE_CALL WMCreateWindow
    cmp ax, NUL_SEL
    jz .fin
    mov es, ax
    push es

    TREE_CALL QueueCreate                        ; 队列
    cmp ax, NUL_SEL
    jz .exit
    mov ds, ax
    push ds

    TREE_LOCATE_DATA                             ; 初始化
    mov ax, ds
    mov es, ax
    mov esi, BLANK
    mov edi, buf
    TREE_CALL strcpy

    pop ds
    mov ecx, TREE_ETRACKER_QUEUE_LEN
.s1:
    xor eax, eax
    call near DrawText
    TREE_CALL QueuePushBack
    loop .s1

    pop es
.s:
    TREE_CALL WMPollEvent
    cmp edx, TREE_EVENT_NOTHING
    jz .print
    cmp edx, TREE_EVENT_MSG_CLOSE
    jz .j0
    cmp edx, TREE_EVENT_MSG_LOST_FOCUS
    jz .j1
    cmp edx, TREE_EVENT_MSG_GOT_FOCUS
    jz .j2
    cmp edx, TREE_EVENT_KEYPRESS_LEFT
    jz .j3
    cmp edx, TREE_EVENT_KEYPRESS_MID
    jz .j4
    cmp edx, TREE_EVENT_KEYPRESS_RIGHT
    jz .j5
    cmp edx, TREE_EVENT_KEYPRESS_KBD
    jz .j6
    jmp near .print

.j0:
    push ds
    push es

    TREE_LOCATE_DATA
    mov ax, ds
    mov es, ax
    mov esi, CLOSE
    mov edi, buf
    TREE_CALL strcpy
    call near DrawText

    pop es
    pop ds
    TREE_CALL QueuePushBack
    jmp near .j7

.j1:
    push ds
    push es

    TREE_LOCATE_DATA
    mov ax, ds
    mov es, ax
    mov esi, LOST
    mov edi, buf
    TREE_CALL strcpy
    call near DrawText

    pop es
    pop ds
    TREE_CALL QueuePushBack
    jmp near .j7

.j2:
    push ds
    push es

    TREE_LOCATE_DATA
    mov ax, ds
    mov es, ax
    mov esi, FOCUSED
    mov edi, buf
    TREE_CALL strcpy
    call near DrawText

    pop es
    pop ds
    TREE_CALL QueuePushBack
    jmp near .j7

.j3:
    push eax
    push ds
    push es

    TREE_LOCATE_DATA
    mov ax, ds
    mov es, ax
    mov esi, LEFTBTN
    mov edi, buf
    TREE_CALL strcpy
    call near DrawText

    pop es
    pop ds
    TREE_CALL QueuePushBack
    pop eax
    jmp near .j9

.j4:
    push eax
    push ds
    push es

    TREE_LOCATE_DATA
    mov ax, ds
    mov es, ax
    mov esi, MIDBTN
    mov edi, buf
    TREE_CALL strcpy
    call near DrawText

    pop es
    pop ds
    TREE_CALL QueuePushBack
    pop eax
    jmp near .j9

.j5:
    push eax
    push ds
    push es

    TREE_LOCATE_DATA
    mov ax, ds
    mov es, ax
    mov esi, RIGHTBTN
    mov edi, buf
    TREE_CALL strcpy
    call near DrawText

    pop es
    pop ds
    TREE_CALL QueuePushBack
    pop eax
    jmp near .j9

.j9:
    push ds
    push es

    push eax
    TREE_LOCATE_DATA
    mov ax, ds
    mov es, ax
    mov esi, POSX
    mov edi, buf
    TREE_CALL strcpy
    mov eax, [ss:esp]
    shr eax, 16
    mov ebx, num
    TREE_CALL itos
    mov esi, num
    TREE_CALL strcat
    mov esi, POSY
    TREE_CALL strcat
    pop eax
    and eax, 0x0000ffff
    mov ebx, num
    TREE_CALL itos
    mov esi, num
    TREE_CALL strcat
    call near DrawText

    pop es
    pop ds
    TREE_CALL QueuePushBack
    TREE_CALL QueueGetFront
    push ds
    mov ds, ax
    TREE_CALL FDestroyText
    pop ds
    TREE_CALL QueuePopFront
    jmp near .j7

.j6:
    push ds
    push es

    push eax
    TREE_LOCATE_DATA
    mov ax, ds
    mov es, ax
    mov esi, KEYDOWN
    mov edi, buf
    TREE_CALL strcpy
    pop eax
    mov ebx, num
    TREE_CALL itos
    mov esi, num
    TREE_CALL strcat

    call near DrawText

    pop es
    pop ds
    TREE_CALL QueuePushBack
    jmp near .j7

.j7:
    TREE_CALL QueueGetFront
    push ds
    mov ds, ax
    TREE_CALL FDestroyText
    pop ds
    TREE_CALL QueuePopFront

.print:
    push ds
    mov ax, [ss:(4 + esp)]
    mov ds, ax
    xor dx, dx
    xor ax, ax
    TREE_CALL BlitTexture
    pop ds

    mov dx, 15                                   ; 绘制
    xor eax, eax
.s0:
    push eax
    push ds
    mov ecx, eax
    TREE_CALL QueueGet
    mov ds, ax
    mov ax, 20
    TREE_CALL BlitTexture
    pop ds
    pop eax
    inc eax
    add dx, 30
    cmp eax, TREE_ETRACKER_QUEUE_LEN
    jz .bk4
    jmp near .s0
.bk4:

    TREE_SLEEP 50
    jmp near .s

.exit:
    TREE_CALL WMCloseWindow

.fin:
    TREE_EXIT


; uint16:ax DrawText(void);

DrawText:

    push ebx
    push ecx
    push ds

    TREE_LOCATE_DATA
    mov ebx, buf
    mov ch, Color_White
    mov cl, Color_Black
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

TREE_NAME 'etracker'
TREE_VER 0

TREE_STRING TITLE, 'etracker'

TREE_STRING BLANK, '-----------------------------'
TREE_STRING LEFTBTN, 'Mouse: left button pressed.'
TREE_STRING MIDBTN, 'Mouse: Mid button pressed.'
TREE_STRING RIGHTBTN, 'Mouse: Right button pressed.'
TREE_STRING POSX, 'x: '
TREE_STRING POSY, ', y: '
TREE_STRING KEYDOWN, 'KBD: KeyDown: Code: '
TREE_STRING LOST, 'WM: Lost Focus.'
TREE_STRING FOCUSED, 'WM: Focused.'
TREE_STRING CLOSE, 'WM: Close.'

TREE_SZBUF num, 20
TREE_SZBUF time, 9
TREE_SZBUF buf, 100

___TREE_DATA_END_