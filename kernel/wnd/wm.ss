; tree/kernel/wnd/wm.ss
; Author: hyan23
; Date: 2016.07.24
;

; 窗口管理器

%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/def0.ic"
%include "../kernel/wnd/window.ic"
%include "../kernel/graphic/texture.ic"
%include "../inc/nasm/tree/wnd/evtt.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'texture', 0
    __TREE_LIB @1, 'font', 0
    __TREE_LIB @2, 'mouse', 0
    __TREE_LIB @3, 'conio', 0
    __TREE_LIB @4, 'queue', 0
    __TREE_LIB @5, 'window', 0
    __TREE_LIB @6, 'linked', 0
    __TREE_LIB @7, 'desktop', 0
    __TREE_LIB @8, 'msgq', 0
    __TREE_LIB @9, 'link', 0
    __TREE_LIB @10, 'task', 0
    __TREE_LIB @11, 'event', 0
    __TREE_LIB @12, 'agent', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'WMCreateWindow', WMCreateWindow
    __TREE_EXPORT @1, 'WMCloseWindow', WMCloseWindow
    __TREE_EXPORT @2, 'WMPollEvent', WMPollEvent

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

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
    __TREE_IMPORT @mouse1, 'get_mouse_btn', get_mouse_btn

    __TREE_IMPORT @conio0, 'putn', putn

    __TREE_IMPORT @queue0, 'QueueCreate', QueueCreate
    __TREE_IMPORT @queue1, 'QueueDestroy', QueueDestroy
    __TREE_IMPORT @queue2, 'QueueGetCount', QueueGetCount
    __TREE_IMPORT @queue3, 'QueueEmpty', QueueEmpty
    __TREE_IMPORT @queue4, 'QueueClear', QueueClear
    __TREE_IMPORT @queue5, 'QueuePushBack', QueuePushBack
    __TREE_IMPORT @queue6, 'QueueGetFront', QueueGetFront
    __TREE_IMPORT @queue7, 'QueuePopFront', QueuePopFront
    __TREE_IMPORT @queue8, 'QueueGetBack', QueueGetBack
    __TREE_IMPORT @queue9, 'QueuePopBack', QueuePopBack

    __TREE_IMPORT @wnd0, 'WndCreate', WndCreate
    __TREE_IMPORT @wnd1, 'WndDestroy', WndDestroy
    __TREE_IMPORT @wnd2, 'WndGetSize', WndGetSize
    __TREE_IMPORT @wnd3, 'WndGetTitle', WndGetTitle
    __TREE_IMPORT @wnd4, 'WndSetTitle', WndSetTitle
    __TREE_IMPORT @wnd5, 'WndGetWindow', WndGetWindow
    __TREE_IMPORT @wnd6, 'WndSetWindow', WndSetWindow
    __TREE_IMPORT @wnd7, 'WndGetDrawable', WndGetDrawable
    __TREE_IMPORT @wnd8, 'WndSetDrawable', WndSetDrawable
    __TREE_IMPORT @wnd9, 'WndGetMSGQ', WndGetMSGQ
    __TREE_IMPORT @wnd10, 'WndSetMSGQ', WndSetMSGQ
    __TREE_IMPORT @wnd11, 'WndGetPosition', WndGetPosition
    __TREE_IMPORT @wnd12, 'WndSetPosition', WndSetPosition
    __TREE_IMPORT @wnd13, 'WndGetPid', WndGetPid

    __TREE_IMPORT @linked0, 'LinkedCreate', LinkedCreate
    __TREE_IMPORT @linked1, 'LinkedDestroy', LinkedDestroy
    __TREE_IMPORT @linked2, 'LinkedAppend', LinkedAppend
    __TREE_IMPORT @linked3, 'LinkedRemove', LinkedRemove
    __TREE_IMPORT @linked4, 'LinkedGetCount', LinkedGetCount
    __TREE_IMPORT @linked5, 'LinkedGet', LinkedGet
    __TREE_IMPORT @linked6, 'LinkedSet', LinkedSet

    __TREE_IMPORT @desk0, 'DeskStart', DeskStart

    __TREE_IMPORT @msgq0, 'MQCreate', MQCreate
    __TREE_IMPORT @msgq1, 'MQDestroy', MQDestroy
    __TREE_IMPORT @msgq2, 'MQLock', MQLock
    __TREE_IMPORT @msgq3, 'MQFree', MQFree
    __TREE_IMPORT @msgq4, 'MQGetQ', MQGetQ

    __TREE_IMPORT @wlink0, 'WLCreate', WLCreate
    __TREE_IMPORT @wlink1, 'WLDestroy', WLDestroy
    __TREE_IMPORT @wlink2, 'WLLock', WLLock
    __TREE_IMPORT @wlink3, 'WLFree', WLFree
    __TREE_IMPORT @wlink4, 'WLGetL', WLGetL

    __TREE_IMPORT @task0, 'CreateProcess', CreateProcess
    __TREE_IMPORT @task1, 'GetTaskPid', GetTaskPid

    __TREE_IMPORT @event0, 'EvtCreateEvt', EvtCreateEvt
    __TREE_IMPORT @event1, 'EvtDestroyEvt', EvtDestroyEvt
    __TREE_IMPORT @event2, 'EvtGetType', EvtGetType
    __TREE_IMPORT @event3, 'EvtGetAttach', EvtGetAttach
    __TREE_IMPORT @event4, 'EvtPushEvt', EvtPushEvt
    __TREE_IMPORT @event5, 'EvtClearEvt', EvtClearEvt
    __TREE_IMPORT @event6, 'EvtSetWindow', EvtSetWindow

    __TREE_IMPORT @agent0, 'free_memory', free_memory

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:

    TREE_CALL WLCreate                           ; 创建窗口链表
    mov [ds:wndlink], ax
    TREE_CALL DeskStart                          ; 通知桌面开始工作

    TREE_SLEEP 500
    mov bl, TREE_LOGICAL_FALSE
    mov eax, 3000
    TREE_CALL CreateProcess

    TREE_SLEEP 500
    mov bl, TREE_LOGICAL_FALSE
    mov eax, 3020
    TREE_CALL CreateProcess

    TREE_SLEEP 500
    mov bl, TREE_LOGICAL_FALSE
    mov eax, 3040
    TREE_CALL CreateProcess

    TREE_SLEEP 500
    mov bl, TREE_LOGICAL_FALSE
    mov eax, 3060
    TREE_CALL CreateProcess

    TREE_SLEEP 500
    mov bl, TREE_LOGICAL_FALSE
    mov eax, 3080
    TREE_CALL CreateProcess

    TREE_SLEEP 500
    mov bl, TREE_LOGICAL_FALSE
    mov eax, 3100
    TREE_CALL CreateProcess


                                                 ; 窗口逻辑
.s:
    TREE_LOCATE_DATA                             ; 窗口链
    mov ax, [ds:wndlink]
    mov ds, ax
    TREE_CALL WLLock
    push ds

    TREE_CALL WLGetL                             ; 链
    mov ds, ax
    TREE_CALL LinkedGetCount                     ; 窗口数量
    mov ecx, eax

    TREE_CALL get_cursor_xy                      ; 光标
    push edx
    push eax
    TREE_CALL get_mouse_btn
    push ax

    cmp al, 0                                    ; 有按键
    jnz .j19
                                                 ; 无按键
    TREE_LOCATE_DATA                             ; 停止窗口移动
    mov WORD [ds:wndmoving], NUL_SEL
    jmp near .okk

.j19:
    push ds
    TREE_LOCATE_DATA                             ; 有窗口移动时
    cmp WORD [ds:wndmoving], NUL_SEL             ; 不处理其他
    pop ds
    jnz .movwnd
.s0:                                             ; 从后往前遍历
    cmp ecx, 0                                   ; 外层->里层
    jz .lostfocus

    push ecx
    push ds

    dec ecx                                      ; 窗口
    TREE_CALL LinkedGet
    mov ds, ax
    TREE_CALL WndGetPosition                     ; 左上点
    push dx
    push ax

    TREE_CALL WndGetSize                         ; 先判断光标是否落在标题栏
    add dx, [ss:esp]                             ; 如果没有, 再判断
    mov ax, [ss:(2 + esp)]                       ; 是否落在窗口内。
    add dx, TREE_WINDOW_LEFT_EDGE + TREE_WINDOW_RIGHT_EDGE
    add ax, TREE_WINDOW_TITLE_BAR_HEIGHT
    mov cx, ax                                   ; 右下点
    mov bx, dx

    pop ax                                       ; 左上点
    pop dx

    cmp dx, [ss:(14 + esp)]
    jg .j7
    cmp ax, [ss:(10 + esp)]
    jg .j8
    cmp cx, [ss:(14 + esp)]
    jl .j9
    cmp bx, [ss:(10 + esp)]
    jl .j10

    sub bx, [ss:(10 + esp)]                      ; 关闭按钮？
    cmp bx, TREE_WINDOW_TITLE_BAR_HEIGHT
    jnl .j99

.j99:
                                                 ; 如果ax=左键
    cmp BYTE [ss:(8 + esp)], MOUSE_LEFT_BOTTON   ; 触发窗口移动。
    jnz .j14

    push ax                                      ; 把当前窗口设为移动窗口
    mov ax, ds
    TREE_LOCATE_DATA
    mov [ds:wndmoving], ax
    pop ax
    mov cx, [ss:(14 + esp)]                      ; 计算窗口/光标偏移
    mov bx, [ss:(10 + esp)]
    sub cx, dx
    sub bx, ax
    mov [ds:offset_x], cx                        ; 写入。
    mov [ds:offset_y], bx

.j14:
    jmp near .bk0

.j7:                                             ; 未落在标题栏
.j8:                                             ; 以下判断是否落在窗口中。
.j9:
.j10:
    push dx
    push ax

    TREE_CALL WndGetSize                         ; ax:dx右下点
    add dx, [ss:esp]                             ; dx:width+y
    add ax, [ss:(2 + esp)]                       ; dx:width+left+right
    add dx, TREE_WINDOW_LEFT_EDGE + TREE_WINDOW_RIGHT_EDGE
    add ax, TREE_WINDOW_TITLE_BAR_HEIGHT + \
        TREE_WINDOW_TOP_EDGE + TREE_WINDOW_BOTTOM_EDGE

    mov cx, ax                                   ; 右下点
    mov bx, dx

    pop ax                                       ; 左上点
    pop dx

    cmp dx, [ss:(14 + esp)]                      ; 落在窗口中
    jg .j
    cmp ax, [ss:(10 + esp)]
    jg .j0
    cmp cx, [ss:(14 + esp)]
    jl .j1
    cmp bx, [ss:(10 + esp)]
    jl .j2

    jmp near .bk0

.j:
.j0:
.j1:
.j2:
    pop ds
    pop ecx
    dec ecx
    jmp near .s0
.lostfocus:
    mov ax, NUL_SEL
    TREE_CALL EvtSetWindow
    push DWORD NUL_SEL                           ; 垃圾数据。
    jmp near .j100

.bk0:
    pop ds
    pop ecx                                      ; ecx:目标窗口索引+1
                                                 ; 被选中的窗口成为焦点窗口
                                                 ; 所有单体事件将向他发送。
    dec ecx                                      ; 调整此窗口放到最上层
    TREE_CALL LinkedGet
    push eax

    push ds
    TREE_LOCATE_DATA
    cmp ax, [ds:focused]
    pop ds
    jz .j4

    TREE_CALL EvtSetWindow                       ; 设为事件窗口
    mov eax, ecx
    TREE_CALL LinkedRemove                       ; 调整层次。
    mov eax, [ss:esp]
    TREE_CALL LinkedAppend

    mov eax, [ss:esp]                            ; 变换焦点
    mov ds, ax                                   ; 标题栏换色
    push ds
    TREE_CALL WndGetWindow
    mov ds, ax
    TREE_CALL DestroyTexture
    pop ds
    push ds
    TREE_CALL WndGetSize
    push ax
    TREE_CALL WndGetTitle                        ; ax:ebx
    mov ds, ax
    pop ax
    mov cl, TREE_WINDOW_TITLE_BAR_COLOR_FOCUSED
    call near DrawWindow                         ; TODO: do error
    pop ds
    TREE_CALL WndSetWindow

.j100:
    TREE_LOCATE_DATA                             ; 上一个焦点窗口变灰
    mov ax, [ds:focused]                         ; 如果存在的话。
    cmp ax, NUL_SEL
    jz .j4

    mov ds, ax
    push ds
    TREE_CALL WndGetWindow
    mov ds, ax
    TREE_CALL DestroyTexture
    pop ds
    push ds
    TREE_CALL WndGetSize
    push ax
    TREE_CALL WndGetTitle
    mov ds, ax
    pop ax
    mov cl, TREE_WINDOW_TITLE_BAR_COLOR
    call near DrawWindow                         ; TODO: do error
    pop ds
    TREE_CALL WndSetWindow

.j4:                                             ; 写回。
    pop eax
    TREE_LOCATE_DATA
    mov [ds:focused], ax

.movwnd:                                         ; 窗口移动。
    TREE_LOCATE_DATA
    mov ax, [ds:wndmoving]
    cmp ax, NUL_SEL
    jz .okk
    mov ds, ax
    push ds
    TREE_LOCATE_DATA
    mov dx, [ss:(10 + esp)]
    mov ax, [ss:(6 + esp)]
    sub dx, [ds:offset_x]
    sub ax, [ds:offset_y]
    cmp dx, 0
    jnl .j43
                                                 ;mov dx, 0
.j43:
    cmp ax, 0
    jnl .j44
                                                 ;mov ax, 0
.j44:
    pop ds
    TREE_CALL WndSetPosition


.okk:
    pop ax
    pop eax
    pop eax

    pop ds
    TREE_CALL WLFree
    TREE_SLEEP 100
    jmp near .s

    TREE_EXIT


; Create Window, Return Drawable Texture
; uint16:ax WMCreateWindow(ds:ebx:title, \
;   uint16:dx:ax:size);

WMCreateWindow:

    push cx
    push ds

    push ax                                      ; height

    mov cl, TREE_WINDOW_TITLE_BAR_COLOR          ; 外框
    call near DrawWindow
    cmp ax, NUL_SEL
    jz .overflow
    push ax

    mov ax, [ss:(2 + esp)]                       ; window
    TREE_CALL WndCreate
    cmp ax, NUL_SEL
    jz .overflow0
    mov ds, ax
    pop ax
    TREE_CALL WndSetWindow

    pop ax                                       ; drawable
    TREE_CALL NewTexture
    cmp ax, NUL_SEL
    jz .overflow1
    mov cl, Color_White
    TREE_CALL PrintTexture
    TREE_CALL WndSetDrawable

    TREE_CALL MQCreate                           ; msgq
    cmp ax, NUL_SEL
    jz .overflow2
    TREE_CALL WndSetMSGQ
    push ds

                                                 ; append2link
    TREE_LOCATE_DATA
    mov ax, [ds:wndlink]
    mov ds, ax
    TREE_CALL WLLock
    push ds
    TREE_CALL WLGetL
    mov ds, ax
    mov eax, [ss:(4 + esp)]
    TREE_CALL LinkedAppend
    test eax, TREE_LOGICAL_TRUE
    jz .overflow3
    pop ds
    TREE_CALL WLFree

    pop ds                                       ; success
    TREE_CALL WndGetDrawable
    ;mov ax, NUL_SEL
.fin:
    pop ds
    pop cx

    retf

.overflow:                                       ; 错误处理0
    pop ax
    mov ax, NUL_SEL
    jmp near .fin

.overflow0:                                      ; 错误处理1
    pop ax
    mov ds, ax
    TREE_CALL DestroyTexture
    pop ax
    mov ax, NUL_SEL
    jmp near .fin

.overflow1:                                      ; 错误处理2
    push ds
    TREE_CALL WndGetWindow
    mov ds, ax
    TREE_CALL DestroyTexture
    pop ds
    TREE_CALL WndDestroy
    mov ax, NUL_SEL
    jmp near .fin

.overflow2:                                      ; 错误处理3
    push ds
    TREE_CALL WndGetDrawable
    mov ds, ax
    TREE_CALL DestroyTexture
    pop ds
    push ds
    TREE_CALL WndGetWindow
    mov ds, ax
    TREE_CALL DestroyTexture
    pop ds
    TREE_CALL WndDestroy
    mov ax, NUL_SEL
    jmp near .fin

.overflow3:                                      ; 错误处理4
    pop ds
    TREE_CALL WLFree
    pop ds
    push ds
    TREE_CALL WndGetDrawable
    mov ds, ax
    TREE_CALL DestroyTexture
    pop ds
    push ds
    TREE_CALL WndGetWindow
    mov ds, ax
    TREE_CALL DestroyTexture
    pop ds
    push ds
    TREE_CALL WndGetMSGQ
    mov ds, ax
    TREE_CALL MQDestroy
    pop ds
    TREE_CALL WndDestroy
    mov ax, NUL_SEL
    jmp near .fin


; void WMCloseWindow(void);

WMCloseWindow:

    pushad
    push ds

    TREE_LOCATE_DATA                             ; 窗口链
    mov ax, [ds:wndlink]
    mov ds, ax

    TREE_CALL WLLock                             ; 加锁
    TREE_CALL WLGetL                             ; 链
    push ds
    mov ds, ax
    TREE_CALL LinkedGetCount                     ; 窗口数量
    push ds

    mov ecx, eax                                 ; 0???
    jecxz .jf
    jmp near .jnf
.jf:
    jmp near .fin0
.jnf:

    TREE_CALL GetTaskPid                         ; 待查找Pid
    push ax

.s0:                                             ; 遍历链
    push ecx
    push ds

    dec ecx
    TREE_CALL LinkedGet
    mov ds, ax
    TREE_CALL WndGetPid
    cmp ax, [ss:(8 + esp)]
    jz .bk0

    pop ds
    pop ecx
    loop .s0
    jmp near .wtf

.bk0:
    pop eax                                      ; ds:目标
    pop ecx                                      ; ecx-1:index

    pop ax

    mov ax, ds                                   ; 是否是焦点窗口,
    TREE_LOCATE_DATA                             ; 若是，应释放焦点,
    cmp ax, [ds:focused]                         ; 关闭事件指派。
    jnz .nt

    push ax                                      ; focused:NUL_SEL
    mov ax, NUL_SEL                              ; event->NUL_SEL
    mov [ds:focused], ax
    TREE_CALL EvtSetWindow
    pop ax

.nt:
    mov ds, ax                                   ; 消息队列
    TREE_CALL WndGetMSGQ
    push ds

    mov ds, ax                                   ; 锁
    TREE_CALL MQLock
    TREE_CALL MQGetQ
    push ds

    push ecx                                     ; 释放所有未被处理的
    mov ds, ax                                   ; 消息。
    TREE_CALL QueueGetCount
    mov ecx, eax
    xor eax, eax
.s1:
    cmp eax, ecx
    jnb .bk4
    push eax

    mov ecx, eax                                 ; get>destroy>pop
    TREE_CALL QueueGetFront
    push ds
    mov ds, ax
    TREE_CALL EvtClearEvt
    pop ds
    TREE_CALL QueuePopFront

    pop eax
    inc eax
    jmp near .s1
.bk4:
    pop ecx

    pop ds                                       ; 销毁消息队列
    TREE_CALL MQFree
    TREE_CALL MQDestroy

    pop ds                                       ; 销毁外框
    push ds
    TREE_CALL WndGetWindow
    mov ds, ax
    TREE_CALL DestroyTexture
    pop ds
    push ds
    TREE_CALL WndGetDrawable                     ; 销毁绘制区
    mov ds, ax
    TREE_CALL DestroyTexture
    pop ds
    TREE_CALL WndDestroy                         ; 销毁窗体

    dec ecx                                      ; index
    mov eax, ecx
    pop ds                                       ; 从窗口链移去。
    TREE_CALL LinkedRemove

.fin:
    pop ds
    TREE_CALL WLFree                             ; 释放。

    pop ds
    popad

    retf

.fin0:
    pop ds
    jmp near .fin

.wtf:
    pop ax
    pop ds
    jmp near .fin


; uint32:edx:eax WMPollEvent(void);

WMPollEvent:

    pushfd
    push ecx
    push ds

    TREE_LOCATE_DATA                             ; 窗口链
    mov ax, [ds:wndlink]
    mov ds, ax

    TREE_CALL WLLock                             ; 加锁
    TREE_CALL WLGetL                             ; 链
    push ds
    mov ds, ax
    TREE_CALL LinkedGetCount                     ; 窗口数量

    mov ecx, eax
    jecxz .jf
    jmp near .jnf
.jf:
    jmp near .fin0
.jnf:

    TREE_CALL GetTaskPid                         ; 待查找Pid
    push ax

.s0:                                             ; 遍历链
    push ecx
    push ds

    dec ecx
    TREE_CALL LinkedGet
    mov ds, ax
    TREE_CALL WndGetPid
    cmp ax, [ss:(8 + esp)]
    jz .bk0

    pop ds
    pop ecx
    loop .s0
    jmp near .wtf

.bk0:
    pop eax                                      ; ds:目标
    pop ecx

    pop ax

    TREE_CALL WndGetMSGQ                         ; 消息队列
    mov ds, ax
    TREE_CALL MQLock                             ; 加锁
    TREE_CALL MQGetQ
    push ds
    mov ds, ax

    TREE_CALL QueueEmpty                         ; 为空？
    test eax, TREE_LOGICAL_TRUE
    jnz .empty
    TREE_CALL QueueGetFront                      ; 取队首
    push ds
    mov ds, ax
    TREE_CALL EvtGetType                         ; 类型
    mov edx, eax
    TREE_CALL EvtGetAttach                       ; 附加信息
    mov eax, eax
    TREE_CALL EvtDestroyEvt                      ; 销毁
    pop ds
    TREE_CALL QueuePopFront

.fin:
    pop ds
    TREE_CALL MQFree                             ; 释放

.fin0:
    pop ds
    TREE_CALL WLFree

    pop ds
    pop ecx
    popfd

    retf

.empty:
    mov edx, TREE_EVENT_NOTHING
    jmp near .fin

.wtf:
    pop ax
    mov edx, TREE_EVENT_NOTHING
    jmp near .fin0


; void DrawWindow(uint32*:ds:ebx:title,
;   dx:ax:width:height:size, cl:color);
; size=drawable-size
; window-size = title-bar + edge

DrawWindow:

    push ebx
    push ecx
    push edx
    push ds
    push es

    and edx, 0x0000ffff                          ; 外边框
    and eax, 0x0000ffff
    add edx, TREE_WINDOW_LEFT_EDGE + \
        TREE_WINDOW_RIGHT_EDGE
    add eax, TREE_WINDOW_TITLE_BAR_HEIGHT + \
        TREE_WINDOW_TOP_EDGE + TREE_WINDOW_BOTTOM_EDGE
    push edx
    push eax
    TREE_CALL NewTexture
    cmp ax, NUL_SEL
    jz .overflow
    mov cl, TREE_WINDOW_BACKGROUND_COLOR
    TREE_CALL PrintTexture
    push ax

    mov ch, Color_Transparent                    ; 标题文字
    mov cl, TREE_WINDOW_TITLE_BAR_TEXT_COLOR
    TREE_CALL FRenderText
    cmp ax, NUL_SEL
    jz .overflow0
    push ax
                                                 ; 图标
    call near DrawClose                          ; TODO:do error
    push ax
    call near DrawMax
    push ax
    call near DrawMin
    push ax
                                                 ; 绘制
    mov ax, [ss:(8 + esp)]                       ; 标题栏背景
    mov ds, ax
    mov cl, [ss:(30 + esp)]
    mov bx, [ss:(14 + esp)]                      ; wnd.width
    shl ebx, 16
    mov bx, TREE_WINDOW_TITLE_BAR_HEIGHT
    xor dx, dx
    xor ax, ax
    TREE_CALL DrawRect

    mov ax, [ss:(8 + esp)]                       ; 标题栏元素
    mov es, ax

    mov ax, [ss:(6 + esp)]                       ; 文字
    mov ds, ax
    mov dx, TREE_WINDOW_TITLE_BAR_HEIGHT / 2 / 2
    mov ax, TREE_WINDOW_TITLE_BAR_HEIGHT / 2 / 2
    TREE_CALL BlitTexture
    TREE_CALL DestroyTexture

    mov ax, [ss:(4 + esp)]                       ; 图标
    mov ds, ax
    mov dx, TREE_WINDOW_TITLE_BAR_HEIGHT / 2 / 2 / 2
    mov ax, [ss:(14 + esp)]
    sub ax, 1 * (TREE_WINDOW_LEFT_EDGE + TREE_WINDOW_ICON_WIDTH)
    TREE_CALL BlitTexture
    TREE_CALL DestroyTexture

    mov ax, [ss:(2 + esp)]
    mov ds, ax
    mov dx, TREE_WINDOW_TITLE_BAR_HEIGHT / 2 / 2 / 2
    mov ax, [ss:(14 + esp)]
    sub ax, 2 * (TREE_WINDOW_LEFT_EDGE + TREE_WINDOW_ICON_WIDTH)
    TREE_CALL BlitTexture
    TREE_CALL DestroyTexture

    mov ax, [ss:esp ]
    mov ds, ax
    mov dx, TREE_WINDOW_TITLE_BAR_HEIGHT / 2 / 2 / 2
    mov ax, [ss:(14 + esp)]
    sub ax, 3 * (TREE_WINDOW_LEFT_EDGE + TREE_WINDOW_ICON_WIDTH)
    TREE_CALL BlitTexture
    TREE_CALL DestroyTexture

    pop ax                                       ; ret
    pop ax
    pop ax
    pop ax
    pop ax

.fin:
    pop edx
    pop edx

    pop es
    pop ds
    pop edx
    pop ecx
    pop ebx

    ret


.overflow:
    mov ax, NUL_SEL
    jmp near .fin

.overflow0:
    pop ax
    mov ax, NUL_SEL
    jmp near .fin


; uint16:ax DrawClose(void);

DrawClose:

    push ebx
    push ecx
    push edx
    push ds
    push es

    mov dx, TREE_WINDOW_ICON_WIDTH               ; 画背景
    mov ax, TREE_WINDOW_ICON_WIDTH
    TREE_CALL NewTexture
    cmp ax, NUL_SEL
    jz .overflow
    mov cl, TREE_WINDOW_ICON_BG_COLOR
    TREE_CALL PrintTexture
    push ax

    TREE_LOCATE_DATA                             ; 画前景
    mov ebx, CLOSE
    mov ch, TREE_WINDOW_ICON_BG_COLOR
    mov cl, TREE_WINDOW_ICON_FORE_COLOR
    TREE_CALL FRenderText
    cmp ax, NUL_SEL
    jz .overflow0

    mov ds, ax
    pop ax
    mov es, ax
    mov dx, TREE_WINDOW_LEFT_EDGE
    xor ax, ax
    TREE_CALL BlitTexture
    TREE_CALL FDestroyText

    mov ax, es
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

.overflow0:
    pop ax
    mov ax, NUL_SEL
    jmp near .fin


; uint16:ax DrawMax(void);

DrawMax:

    push ebx
    push ecx
    push edx
    push ds
    push es

    mov dx, TREE_WINDOW_ICON_WIDTH               ; 画背景
    mov ax, TREE_WINDOW_ICON_WIDTH
    TREE_CALL NewTexture
    cmp ax, NUL_SEL
    jz .overflow
    mov cl, TREE_WINDOW_ICON_BG_COLOR
    TREE_CALL PrintTexture
    push ax

    TREE_LOCATE_DATA                             ; 画前景
    mov ebx, MAX
    mov ch, TREE_WINDOW_ICON_BG_COLOR
    mov cl, TREE_WINDOW_ICON_FORE_COLOR0
    TREE_CALL FRenderText
    cmp ax, NUL_SEL
    jz .overflow0

    mov ds, ax
    pop ax
    mov es, ax
    mov dx, TREE_WINDOW_LEFT_EDGE
    xor ax, ax
    TREE_CALL BlitTexture
    TREE_CALL FDestroyText

    mov ax, es
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

.overflow0:
    pop ax
    mov ax, NUL_SEL
    jmp near .fin


; uint16:ax DrawMin(void);

DrawMin:

    push ebx
    push ecx
    push edx
    push ds
    push es

    mov dx, TREE_WINDOW_ICON_WIDTH               ; 画背景
    mov ax, TREE_WINDOW_ICON_WIDTH
    TREE_CALL NewTexture
    cmp ax, NUL_SEL
    jz .overflow
    mov cl, TREE_WINDOW_ICON_BG_COLOR
    TREE_CALL PrintTexture
    push ax

    TREE_LOCATE_DATA                             ; 画前景
    mov ebx, MIN
    mov ch, TREE_WINDOW_ICON_BG_COLOR
    mov cl, TREE_WINDOW_ICON_FORE_COLOR0
    TREE_CALL FRenderText
    cmp ax, NUL_SEL
    jz .overflow0

    mov ds, ax
    pop ax
    mov es, ax
    mov dx, TREE_WINDOW_LEFT_EDGE
    xor ax, ax
    TREE_CALL BlitTexture
    TREE_CALL FDestroyText

    mov ax, es
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

.overflow0:
    pop ax
    mov ax, NUL_SEL
    jmp near .fin


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'wm'
TREE_VER 0

wndlink DW NUL_SEL
; 焦点窗口, 窗口链的一个节点
focused DW NUL_SEL

wndmoving DW NUL_SEL                             ; 在移动移动的窗口
offset_x DW 0                                    ; 相对于鼠标的偏移量
offset_y DW 0

TREE_STRING CLOSE, 'X'
TREE_STRING MAX, 'O'
TREE_STRING MIN, '-'
TREE_STRING TEXT, 'Window'
TREE_STRING TEXT1, 'Window1'
TREE_STRING TEXT2, 'Window2'


___TREE_DATA_END_