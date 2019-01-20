; tree/kernel/wnd/desktop.ss
; Author: hyan23
; Date: 2016.07.30
;

; 绘制桌面, 叠加层, 调试信息。

%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/def0.ic"
%include "../kernel/wnd/desktop.ic"
%include "../kernel/graphic/texture.ic"
%include "../kernel/wnd/window.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'time', 0
    __TREE_LIB @1, 'graphic', 0
    __TREE_LIB @2, 'texture', 0
    __TREE_LIB @3, 'font', 0
    __TREE_LIB @4, 'mouse', 0
    __TREE_LIB @5, 'window', 0
    __TREE_LIB @6, 'linked', 0
    __TREE_LIB @7, 'link', 0
    __TREE_LIB @8, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'DeskStart', DeskStart
    __TREE_EXPORT @1, 'DeskBusy', DeskBusy

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @time0, 'gettime_str', gettime_str

    __TREE_IMPORT @graphic0, 'refreshscr', refreshscr

    __TREE_IMPORT @texture0, 'NewTexture', NewTexture
    __TREE_IMPORT @texture1, 'DestroyTexture', DestroyTexture
    __TREE_IMPORT @texture2, 'PrintTexture', PrintTexture
    __TREE_IMPORT @texture3, 'DrawPixel', DrawPixel
    __TREE_IMPORT @texture4, 'DrawLine', DrawLine
    __TREE_IMPORT @texture5, 'DrawRect', DrawRect
    __TREE_IMPORT @texture6, 'BlitTexture', BlitTexture

    __TREE_IMPORT @font0, 'FRenderText', FRenderText
    __TREE_IMPORT @font1, 'FDestroyText', FDestroyText

    __TREE_IMPORT @mouse0, 'get_cursor_xy', get_cursor_xy

    __TREE_IMPORT @wnd4, 'WndGetWindow', WndGetWindow
    __TREE_IMPORT @wnd6, 'WndGetDrawable', WndGetDrawable
    __TREE_IMPORT @wnd10, 'WndGetPosition', WndGetPosition

    __TREE_IMPORT @linked4, 'LinkedGetCount', LinkedGetCount
    __TREE_IMPORT @linked5, 'LinkedGet', LinkedGet

    __TREE_IMPORT @wlink2, 'WLLock', WLLock
    __TREE_IMPORT @wlink3, 'WLFree', WLFree
    __TREE_IMPORT @wlink4, 'WLGetL', WLGetL

    __TREE_IMPORT @conio1, 'putn', putn

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

%macro ____PUTN_ 1

    push eax
    mov eax, %1
    TREE_CALL putn
    pop eax

%endmacro ; ____PUTN_


TREE_START:
.wt:                                             ; 等待开始
    test BYTE [ds:desk_start], TREE_LOGICAL_TRUE
    jnz .bk4
    TREE_SLEEP 1000
    jmp near .wt
.bk4:
.s0:
    call near DrawDesktop                        ; 桌面
    cmp ax, NUL_SEL
    jnz .j
    TREE_SLEEP 10
    jmp near .s0
.j:
    push ax

    call near DrawTime                           ; 右下时间
    cmp ax, NUL_SEL
    jnz .j0
    pop ax
    mov ds, ax
    TREE_CALL DestroyTexture
    TREE_SLEEP 10
    jmp near .s0
.j0:
    push ax

    call near DrawCursor                         ; 光标
    cmp ax, NUL_SEL
    jnz .j1
    pop ax
    mov ds, ax
    TREE_CALL DestroyTexture
    pop ax
    mov ds, ax
    TREE_CALL DestroyTexture
    TREE_SLEEP 10
    jmp near .s0
.j1:
    push ax

    mov ax, [ss:(4 + esp)]
    mov es, ax

                                                 ; 叠加层，时间
    mov ax, [ss:(2 + esp)]                       ; 绘制并销毁
    mov ds, ax
    mov dx, TREE_SCR_HEIGHT - TREE_DESKTOP_BAR_HEIGHT \
        + TREE_DESKTOP_BAR_HEIGHT / 2 / 2 + 2
    mov ax, TREE_SCR_WIDTH - 85
    TREE_CALL BlitTexture
    TREE_CALL DestroyTexture

                                                 ; 绘制所有窗口

    TREE_LOCATE_DATA                             ; 窗口链
    mov ax, [ds:desk_wndlink]
    mov ds, ax
    TREE_CALL WLLock
    push ds

    TREE_CALL WLGetL
    mov ds, ax

    TREE_CALL LinkedGetCount                     ; 窗口数量
    mov ecx, eax
    xor eax, eax
.s1:
    cmp eax, ecx
    jnb .bk1

    push ecx
    push eax
    push ds

    mov ecx, eax                                 ; 窗口
    TREE_CALL LinkedGet
    mov ds, ax
    push ds

    TREE_CALL WndGetPosition                     ; 显示位置

    push ax                                      ; 外框
    TREE_CALL WndGetWindow
    mov ds, ax
    pop ax
    TREE_CALL BlitTexture

    pop ds                                       ; 绘制区
    push ax
    TREE_CALL WndGetDrawable
    mov ds, ax
    pop ax
    add dx, TREE_WINDOW_TITLE_BAR_HEIGHT + \
        TREE_WINDOW_TOP_EDGE
    add ax, TREE_WINDOW_LEFT_EDGE
    TREE_CALL BlitTexture

    pop ds
    pop eax
    pop ecx

    inc eax
    jmp near .s1
.bk1:

    pop ds                                       ; 释放链
    TREE_CALL WLFree

                                                 ; 叠加层，光标
    mov ax, [ss:esp]                             ; 绘制并销毁1
    mov ds, ax
    TREE_CALL get_cursor_xy
    TREE_CALL BlitTexture
    TREE_CALL DestroyTexture

    mov ax, [es:TREE_TEXTURE_TEXTURE_OFS]        ; 刷新
    mov ds, ax
    xor ebx, ebx
    TREE_CALL refreshscr

    pop ax
    pop ax
    pop ax

    mov ds, ax
    TREE_CALL DestroyTexture
    mov ax, NUL_SEL
    mov es, ax

    TREE_SLEEP 50                                ; TODO: 精确速率控制

    jmp near .s0

    TREE_EXIT


; void DeskStart(uint16:ax:wndlink);

DeskStart:

    push ds

    TREE_LOCATE_DATA
    mov [ds:desk_wndlink], ax
    mov BYTE [ds:desk_start], TREE_LOGICAL_TRUE

    pop ds

    retf


; bool:eax DeskBusy(void);

DeskBusy:

    push ds

    TREE_LOCATE_DATA
    test BYTE [ds:desk_busy], TREE_LOGICAL_TRUE
    jz .nt
    mov eax, TREE_LOGICAL_TRUE

.fin:
    pop ds

    retf

.nt:
    mov eax, TREE_LOGICAL_FALSE
    jmp near .fin


; uint16:ax:texture DrawDesktop(void);

DrawDesktop:

    push ebx
    push ecx
    push edx
    push ds
    push es

    mov dx, TREE_SCR_WIDTH                       ; 屏幕大小的背景
    mov ax, TREE_SCR_HEIGHT
    TREE_CALL NewTexture
    cmp ax, NUL_SEL
    jz .overflow
    mov cl, TREE_DESKTOP_BG_COLOR                ; 填充
    TREE_CALL PrintTexture
    push ax

    mov ch, TREE_DESKTOP_BG_COLOR                ; 渲染一些文字
    mov cl, TREE_DESKTOP_TEXT_COLOR
    TREE_LOCATE_DATA
    mov ebx, TEXT0
    TREE_CALL FRenderText
    push ax

    mov ebx, TEXT1
    TREE_CALL FRenderText
    push ax

    mov ebx, TEXT2
    TREE_CALL FRenderText
    push ax

    mov ch, TREE_DESKTOP_BAR_COLOR
    mov ebx, TEXT3
    TREE_CALL FRenderText
    push ax

    mov ch, TREE_DESKTOP_BG_COLOR
    mov ebx, TEXT
    TREE_CALL FRenderText
    push ax

    cmp WORD [ss:(8 + esp)], NUL_SEL
    jz .overflow0
    cmp WORD [ss:(6 + esp)], NUL_SEL
    jz .overflow0
    cmp WORD [ss:(4 + esp)], NUL_SEL
    jz .overflow0
    cmp WORD [ss:(2 + esp)], NUL_SEL
    jz .overflow0
    cmp WORD [ss:esp], NUL_SEL
    jz .overflow0

.noh:
    mov ax, [ss:(10 + esp)]                      ; 画状态栏
    mov ds, ax
    mov dx, TREE_SCR_HEIGHT - 40
    mov ax, 0
    mov bx, TREE_SCR_WIDTH
    shl ebx, 16
    mov bx, TREE_DESKTOP_BAR_HEIGHT
    mov cl, TREE_DESKTOP_BAR_COLOR
    TREE_CALL DrawRect

    mov ax, [ss:(10 + esp)]                      ; Blit文字
    mov es, ax

    mov ax, [ss:(8 + esp)]
    mov ds, ax
    mov dx, 20
    mov ax, 20
    TREE_CALL BlitTexture

    mov ax, [ss:(6 + esp)]
    mov ds, ax
    mov dx, 40
    mov ax, 20
    TREE_CALL BlitTexture

    mov ax, [ss:(4 + esp)]
    mov ds, ax
    mov dx, 60
    mov ax, 20
    TREE_CALL BlitTexture

    mov ax, [ss:(2 + esp)]
    mov ds, ax
    mov dx, TREE_SCR_HEIGHT - TREE_DESKTOP_BAR_HEIGHT \
        + TREE_DESKTOP_BAR_HEIGHT / 2 / 2
    mov ax, TREE_DESKTOP_BAR_HEIGHT / 2
    TREE_CALL BlitTexture

    mov ax, [ss:esp]
    mov ds, ax
    mov dx, 80
    mov ax, 20
    TREE_CALL BlitTexture

    pop ax                                       ; 销毁文字
    mov ds, ax
    TREE_CALL FDestroyText
    pop ax
    mov ds, ax
    TREE_CALL FDestroyText
    pop ax
    mov ds, ax
    TREE_CALL FDestroyText
    pop ax
    mov ds, ax
    TREE_CALL FDestroyText
    pop ax
    mov ds, ax
    TREE_CALL FDestroyText

    pop ax

.fin:
    pop es
    pop ds
    pop edx
    pop ecx
    pop ebx

    ret

.overflow:                                       ; 处理错误
    mov ax, NUL_SEL
    jmp near .fin

.overflow0:
    pop ax
    cmp ax, NUL_SEL
    jnz .j
    mov ds, ax
    TREE_CALL FDestroyText

.j:
    pop ax
    cmp ax, NUL_SEL
    jnz .j0
    mov ds, ax
    TREE_CALL FDestroyText

.j0:
    pop ax
    cmp ax, NUL_SEL
    jnz .j1
    mov ds, ax
    TREE_CALL FDestroyText

.j1:
    pop ax
    cmp ax, NUL_SEL
    jnz .j2
    mov ds, ax
    TREE_CALL FDestroyText

.j2:
    pop ax
    cmp ax, NUL_SEL
    jnz .j3
    mov ds, ax
    TREE_CALL FDestroyText

.j3:
    pop ax
    mov ax, NUL_SEL
    jmp near .fin


; uint16:ax DrawTime(void);

DrawTime:

    push ebx
    push ecx
    push ds

    TREE_LOCATE_DATA
    mov ebx, time
    TREE_CALL gettime_str
    mov ch, TREE_DESKTOP_BAR_COLOR
    mov cl, TREE_DESKTOP_TEXT_COLOR
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


; uint16:ax DrawCursor(void);

DrawCursor:

    push ebx
    push ecx
    push edx
    push ds
    push es

    mov dx, TREE_DESKTOP_CURSOR_WIDTH            ; 画背景
    mov ax, TREE_DESKTOP_CURSOR_HEIGHT
    TREE_CALL NewTexture
    cmp ax, NUL_SEL
    jz .overflow
    mov cl, Color_Transparent
    TREE_CALL PrintTexture
    push ax
    mov es, ax

    TREE_LOCATE_DATA                             ; 画前景
    mov ebx, CORSOR

    mov ax, [es:TREE_TEXTURE_TEXTURE_OFS]
    mov es, ax
    xor edi, edi

    mov ecx, TREE_DESKTOP_CURSOR_WIDTH * \
        TREE_DESKTOP_CURSOR_HEIGHT
.s0:
    push ecx
    mov cl, [ds:ebx]
    cmp cl, TREE_DESKTOP_CURSOR_CHAR_BACK
    jz .back
    cmp cl, TREE_DESKTOP_CURSOR_CHAR_FORE
    jz .fore
    jmp near .nxt

.back:
    mov BYTE [es:edi], TREE_DESKTOP_CURSOR_BACK_COLOR
    jmp near .nxt
.fore:
    mov BYTE [es:edi], TREE_DESKTOP_CURSOR_FORE_COLOR
.nxt:
    inc ebx
    inc edi
    pop ecx

    loop .s0

    pop ax
.fin:
    pop es
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

TREE_NAME 'desktop'
TREE_VER 0

desk_start DB TREE_LOGICAL_FALSE
desk_wndlink DW NUL_SEL
desk_busy DB TREE_LOGICAL_FALSE
TREE_SZBUF time, 9

TREE_STRING TEXT0, 'The Tree, OS v1.2'
TREE_STRING TEXT1, 'Author: hyan23'
TREE_STRING TEXT2, 'Date: 2016.08.07'
TREE_STRING TEXT3, 'Start |'
TREE_STRING TEXT, 'hyan23lee@gmail.com'


CORSOR:
    DB  '##############..'
    DB  '#***********#...'
    DB  '#**********#....'
    DB  '#*********#.....'
    DB  '#********#......'
    DB  '#*******#.......'
    DB  '#*******#.......'
    DB  '#********#......'
    DB  '#****##***#.....'
    DB  '#***#..#***#....'
    DB  '#**#....#***#...'
    DB  '#*#......#***#..'
    DB  '##........#***#.'
    DB  '#..........#***#'
    DB  '............#**#'
    DB  '.............###'



___TREE_DATA_END_