; tree/kernel/wnd/event.ss
; Author: hyan23
; Date: 2016.08.04
;

; 事件指派。

%include "../inc/nasm/tree.ic"
%include "../kernel/wnd/event.ic"
%include "../kernel/wnd/window.ic"
%include "../inc/nasm/io/def0.ic"
%include "../inc/nasm/tree/wnd/evtt.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'agent', 0
    __TREE_LIB @1, 'conio', 0
    __TREE_LIB @2, 'queue', 0
    __TREE_LIB @3, 'msgq', 0
    __TREE_LIB @4, 'window', 0
    __TREE_LIB @5, 'kbd', 0
    __TREE_LIB @6, 'mouse', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'EvtCreateEvt', EvtCreateEvt
    __TREE_EXPORT @1, 'EvtDestroyEvt', EvtDestroyEvt
    __TREE_EXPORT @2, 'EvtGetType', EvtGetType
    __TREE_EXPORT @3, 'EvtGetAttach', EvtGetAttach
    __TREE_EXPORT @4, 'EvtPushEvt', EvtPushEvt
    __TREE_EXPORT @5, 'EvtClearEvt', EvtClearEvt
    __TREE_EXPORT @6, 'EvtSetWindow', EvtSetWindow

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'alloc_memory0', alloc_memory0
    __TREE_IMPORT @1, 'free_memory', free_memory
    __TREE_IMPORT @2, 'putn', putn

    __TREE_IMPORT @queue2, 'QueueGetCount', QueueGetCount
    __TREE_IMPORT @queue3, 'QueueEmpty', QueueEmpty
    __TREE_IMPORT @queue4, 'QueueClear', QueueClear
    __TREE_IMPORT @queue5, 'QueuePushBack', QueuePushBack

    __TREE_IMPORT @msgq2, 'MQLock', MQLock
    __TREE_IMPORT @msgq3, 'MQFree', MQFree
    __TREE_IMPORT @msgq4, 'MQGetQ', MQGetQ

    __TREE_IMPORT @window2, 'WndGetSize', WndGetSize
    __TREE_IMPORT @window9, 'WndGetMSGQ', WndGetMSGQ
    __TREE_IMPORT @window11, 'WndGetPosition', WndGetPosition

    __TREE_IMPORT @kbd0, 'get_char0', get_char0

    __TREE_IMPORT @mouse0, 'get_mouse_btn', get_mouse_btn
    __TREE_IMPORT @mouse1, 'get_cursor_xy', get_cursor_xy

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:

.s0:                                             ; 按键。
    xor ecx, ecx
    TREE_CALL get_char0
    cmp cl, 0
    jz .j

    mov edx, TREE_EVENT_KEYPRESS_KBD
    mov eax, ecx
    call near EvtCreateEvt0
    cmp ax, NUL_SEL
    jz .j

    mov ds, ax
    call near EvtPushEvt0

.j:
    xor eax, eax                                 ; 鼠标。
    TREE_CALL get_mouse_btn
    cmp eax, 0
    jz .j0

    cmp eax, MOUSE_LEFT_BOTTON                   ; edx:btn
    jnz .j1
    mov edx, TREE_EVENT_KEYPRESS_LEFT
    jmp near .j3
.j1:
    cmp eax, MOUSE_MID_BOTTON
    jnz .j2
    mov edx, TREE_EVENT_KEYPRESS_MID
    jmp near .j3
.j2:
    cmp eax, MOUSE_RIGHT_BOTTON
    jnz .j0
    mov edx, TREE_EVENT_KEYPRESS_RIGHT

.j3:
                                                 ; 附加数据。
    TREE_LOCATE_DATA
    mov ax, [ds:focued]
    cmp ax, NUL_SEL
    jz .j0
    mov ds, ax
    push edx

    TREE_CALL get_cursor_xy                      ; 判断是否落在窗口內，
    push dx                                      ; 如果不是，取消发送此消息。
    push ax

    TREE_CALL WndGetPosition                     ; 左上点
    push dx
    push ax

    TREE_CALL WndGetSize                         ; 右下点
    add dx, [ss:esp]
    add ax, [ss:(2 + esp)]
    add dx, TREE_WINDOW_LEFT_EDGE + TREE_WINDOW_RIGHT_EDGE
    add ax, TREE_WINDOW_TITLE_BAR_HEIGHT + \
        TREE_WINDOW_TOP_EDGE

    mov cx, ax
    mov bx, dx

    mov dx, [ss:(2 + esp)]                       ; 区域。
    mov ax, [ss:esp]

    cmp dx, [ss:(6 + esp)]
    jg .j7
    cmp ax, [ss:(4 + esp)]
    jg .j8
    cmp cx, [ss:(6 + esp)]
    jl .j9
    cmp bx, [ss:(4 + esp)]
    jl .j10

    add dx, TREE_WINDOW_TITLE_BAR_HEIGHT         ; 点击了关闭按钮。
    cmp dx, [ss:(6 + esp)]
    jng .j11
    sub bx, [ss:(4 + esp)]
    cmp bx, TREE_WINDOW_TITLE_BAR_HEIGHT
    jnl .j12

.wndclose:                                       ; 发送关闭消息。
    mov edx, TREE_EVENT_MSG_CLOSE
    xor eax, eax
    call near EvtCreateEvt0
    cmp ax, NUL_SEL
    jz .j11
    mov ds, ax
    call near EvtPushEvt0

.j11:
.j12:

    pop ax                                       ; position
    pop dx
    pop bx                                       ; cursor
    pop cx
                                                 ; 转换为Drawable
    sub cx, dx                                   ; 坐标。
    sub cx, TREE_WINDOW_TITLE_BAR_HEIGHT + \
        TREE_WINDOW_TOP_EDGE
    sub bx, ax
    sub bx, TREE_WINDOW_LEFT_EDGE

    cmp cx, 0
    jl .j13
    cmp bx, 0
    jl .j13

    mov ax, cx                                   ; 合并。
    shl eax, 16
    mov ax, bx

    pop edx
    call near EvtCreateEvt0
    cmp ax, NUL_SEL
    jz .j0

    mov ds, ax
    call near EvtPushEvt0
    jmp near .j0

.j7:
.j8:
.j9:
.j10:
    pop ax                                       ; 垃圾数据。
    pop ax
    pop ax
    pop ax
.j13:
    pop ax
    pop ax

.j0:
    TREE_SLEEP 50
    jmp near .s0


    TREE_EXIT


; uint16:ax EvtCreateEvt(uint32:edx:type,
;   uint32:eax:attach);


EvtCreateEvt:
    call near EvtCreateEvt0
    retf


EvtCreateEvt0:

    push ecx
    push ds

    push eax
    mov ecx, TREE_EVENT_CONTEXT_BYTES
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow
    mov ds, ax
    pop eax

    mov [ds:TREE_EVENT_CONTEXT_TYPE_OFS], edx
    mov [ds:TREE_EVENT_CONTEXT_ATTACH_OFS], eax

    mov ax, ds
.fin:
    pop ds
    pop ecx

    ret

.overflow:
    pop eax
    mov ax, NUL_SEL
    jmp near .fin


; void EvtDestroyEvt(ds:event);

EvtDestroyEvt:
    call near EvtDestroyEvt0
    retf


EvtDestroyEvt0:

    TREE_CALL free_memory
    ret


; uint32:eax EvtGetType(ds:event);

EvtGetType:

    mov eax, [ds:TREE_EVENT_CONTEXT_TYPE_OFS]

    retf


; uint32:eax EvtGetAttach(ds:event);

EvtGetAttach:

    mov eax, [ds:TREE_EVENT_CONTEXT_ATTACH_OFS]

    retf


; void EvtPushEvt(ds:event);

EvtPushEvt:

    call near EvtPushEvt0
    retf


EvtPushEvt0:

    push eax
    push ds

    TREE_LOCATE_DATA                             ; 忙
    mov BYTE [ds:busy], TREE_LOGICAL_TRUE

    mov ax, [ds:focued]                          ; 焦点窗口
    cmp ax, NUL_SEL
    jz .nul

    mov ds, ax                                   ; 消息队列
    TREE_CALL WndGetMSGQ
    mov ds, ax
    TREE_CALL MQLock                             ; 锁
    TREE_CALL MQGetQ
    push ds

    mov ds, ax                                   ; 限制容量。
    TREE_CALL QueueGetCount
    cmp eax, TREE_EVENT_QUEUE_LIMIT
    jnb .qf

    mov eax, [ss:(4 + esp)]                      ; push
    TREE_CALL QueuePushBack
    jmp near .j

.qf:
    mov eax, [ss:(4 + esp)]                      ; 否则，
    mov ds, ax                                   ; 销毁本条消息。
    call near EvtDestroyEvt0

.j:
    pop ds                                       ; 释放
    TREE_CALL MQFree

    pop ds
    pop eax
.fin:
    push ds
    TREE_LOCATE_DATA
    mov BYTE [ds:busy], TREE_LOGICAL_FALSE
    pop ds

    ret

.nul:
    pop ds
    pop eax
    call near EvtDestroyEvt0
    jmp near .fin


; void EvtClearEvt(void);

EvtClearEvt:

    push ax
    push ds

    TREE_LOCATE_DATA
    mov BYTE [ds:busy], TREE_LOGICAL_TRUE

    mov ax, [ds:focued]
    cmp ax, NUL_SEL
    jz .fin

    mov ds, ax
    TREE_CALL WndGetMSGQ
    mov ds, ax

    TREE_CALL MQLock
    TREE_CALL MQGetQ
    push ds
    mov ds, ax
    TREE_CALL QueueClear

    pop ds
    TREE_CALL MQFree

.fin:
    TREE_LOCATE_DATA
    mov BYTE [ds:busy], TREE_LOGICAL_FALSE

    pop ds
    pop ax

    retf



; void EvtSetWindow(uint16:ax:window);

EvtSetWindow:

    pushad
    push ds

    push ax
    TREE_LOCATE_DATA
.wt:
    test BYTE [ds:busy], TREE_LOGICAL_TRUE
    jnz .wt

    cmp WORD [ds:focued], NUL_SEL                ; 向旧窗口发送失焦的
    jz .j                                        ; 消息，如果存在的话。

    mov edx, TREE_EVENT_MSG_LOST_FOCUS
    xor eax, eax
    call near EvtCreateEvt0
    cmp ax, NUL_SEL
    jz .j
    mov ds, ax
    call near EvtPushEvt0

.j:
    pop ax                                       ; 新的窗口
    TREE_LOCATE_DATA
    mov [ds:focued], ax

    mov edx, TREE_EVENT_MSG_GOT_FOCUS            ; 向它发送GOT_FOCUS
    xor eax, eax                                 ; 消息。
    call near EvtCreateEvt0
    cmp ax, NUL_SEL
    jz .j0
    mov ds, ax
    call near EvtPushEvt0

.j0:
    nop
    nop

    pop ds
    popad

    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'event'
TREE_VER 0

focued DW NUL_SEL
busy DB TREE_LOGICAL_FALSE


___TREE_DATA_END_