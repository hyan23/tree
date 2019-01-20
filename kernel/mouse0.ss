; tree/kernel/mouse0.ss
; Author: hyan23
; Date: 2016.07.31
;

; 鼠标驱动程序

; dat[0], 0x09: btn1 : keydown
; dat[0], 0x0a: btn2 : keydown
; dat[0], 0x0c: btn3 : keydown [mid]
; dat[0], 0x08: btn1 | btn2 | btn3 : keyup

; 弹起, 0x08


%include "../boot/LIB.ic"
%include "../kernel/gate.ic"
%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/def0.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'mouse0', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @444, 'mouse0foo', foo

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'mouse0foo', fOO

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:

    mov ax, [ss:TREE_USR_STACK - 4 - 1]          ; 加载:
    mov es, ax                                   ; 进程空间
    mov ax, [es:ACCESS_SRC(4 + fOO)]             ; 全局代码

    mov ebx, INT74                               ; 安装74号中断。
    mov ecx, 0x74
    TREE_ABSCALL INSTALL_IDT_INTGATE

    push eax

    mov ax, [ss:esp]                             ; 安装这些导出函数
    mov ebx, 0                                   ; 的调用门。
    mov ecx, get_mouse_xy
    mov edx, __GET_MOUSE_XY
    TREE_ABSCALL INSTALL_CALL_GATE
    test eax, TREE_LOGICAL_TRUE
    jz .failed

    mov ax, [ss:esp]
    mov ebx, 0
    mov ecx, get_mouse_btn
    mov edx, __GET_MOUSE_BTN
    TREE_ABSCALL INSTALL_CALL_GATE
    test eax, TREE_LOGICAL_TRUE
    jz .failed

    mov ax, [ss:esp]
    mov ebx, 0
    mov ecx, get_cursor_xy
    mov edx, __GET_CURSOR_XY
    TREE_ABSCALL INSTALL_CALL_GATE
    test eax, TREE_LOGICAL_TRUE
    jz .failed

    mov ax, [es:TREE_PROC_PRIVATE_GD_SEL_OFS]    ; 缓存全局数据段选择子
    mov bx, LIB_SEL                              ; 以便在中断处理过程中
    mov ds, bx                                   ; 访问本地数据。
    mov [ds:TREE_LIB_MOUSE_DAT_SEL_OFS], ax

    pop eax
    xor eax, eax
.fin:
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax

.failed:
    pop eax
    mov eax, -1
    jmp near .fin


%macro THIS_USE_DATA 0                           ; 定位本地数据。

    push ax

    mov ax, LIB_SEL
    mov ds, ax
    mov ax, [ds:TREE_LIB_MOUSE_DAT_SEL_OFS]
    mov ds, ax

    pop ax

%endmacro ; THIS_USE_DATA


; uint16:dx:ax get_mouse_xy(void);

get_mouse_xy:                                    ; 移动矢量

    push ds

    THIS_USE_DATA
    mov dx, [ds:mouse_x]
    mov ax, [ds:mouse_y]

    pop ds

    retf


; uint16:dx:ax get_cursor_xy(void);

get_cursor_xy:                                   ; 光标

    push ds

    THIS_USE_DATA
    mov dx, [ds:cursor_y]                        ; 不同的坐标系统。
    mov ax, [ds:cursor_x]
    push ax                                      ; 上下翻转。
    mov ax, TREE_SCR_HEIGHT
    sub ax, dx
    mov dx, ax
    pop ax

    pop ds

    retf


; uint16:ax get_mouse_btn(void);
; ax:0:none, ax:1:left, ax:2, right, ax:4:centre

get_mouse_btn:                                   ; 按键

    push ds

    THIS_USE_DATA
    mov al, [ds:mouse_btn]

    pop ds

    retf


INT74:
    pushfd
    pushad
    push ds

    in al, 0x60                                  ; 鼠标传回数据
    mov cl, al                                   ; 备份一次。
    THIS_USE_DATA

    cmp BYTE [ds:mouse_phase], 0                 ; 确定本次读取的是第几个字节
    jz .p0
    cmp BYTE [ds:mouse_phase], 1
    jz .p1
    cmp BYTE [ds:mouse_phase], 2
    jz .p2

    jmp near .wtf

.p0:                                             ; 成组数据可能被破坏，
    and al, 0xc8                                 ; 因此有必要添加检查措施。
    cmp al, 0x08                                 ; 第一个字节最高两位不使用为0,
    jnz .invalid                                 ; 第三位恒为1。
    mov al, cl
    mov [ds:recv_buf0], al
    mov BYTE [ds:mouse_phase], 1
    jmp near .ok
.p1:
    mov [ds:recv_buf1], al
    mov BYTE [ds:mouse_phase], 2
    jmp near .ok
.p2:                                             ; 完成一个序列
    mov [ds:recv_buf2], al                       ; 记录数据。
    mov BYTE [ds:mouse_phase], 0

    mov al, [ds:recv_buf0]                       ; buf[0]^0-3
    mov cl, al
    and al, 0x07
    mov [ds:mouse_btn], al
    mov al, cl

    xor edx, edx
    mov dl, [ds:recv_buf1]                       ; 负方向移动
    test al, 0x10
    jz .noor0
    or edx, 0xffffff00
.noor0:
    mov [ds:mouse_x], edx

    xor eax, eax
    mov al, [ds:recv_buf2]
    test cl, 0x20
    jz .noor1
    or eax, 0xffffff00
.noor1:
    mov [ds:mouse_y], eax
                                                 ; 更新光标
    mov ecx, [ds:cursor_x]
    mov ebx, [ds:cursor_y]
    add edx, ecx
    add eax, ebx
                                                 ;jmp near .j4
                                                 ; 处理超界
    cmp edx, TREE_SCR_WIDTH - 1                  ; 不同的坐标系统。
    jg .j0
    cmp edx, 0
    jl .j1
    jmp near .nxt
.j0:
    mov edx, TREE_SCR_WIDTH - 1
    jmp near .nxt
.j1:
    mov edx, 0

.nxt:
    cmp eax, TREE_SCR_HEIGHT
    jg .j2
    cmp eax, 0 + 1
    jl .j3
    jmp near .j4
.j2:
    mov eax, TREE_SCR_HEIGHT
    jmp near .j4
.j3:
    mov eax, 0 + 1

.j4:
    mov [ds:cursor_x], edx                       ; 写回
    mov [ds:cursor_y], eax

.wtf:
.invalid:
.ok:
    mov al, 0x64                                 ; 通知中断处理完成
    out 0xa0, al
    mov al, 0x62
    out 0x20, al

fin:
    pop ds
    popad
    popfd

    iretd


%include "../kernel/debug.s0"

foo:

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'mouse0'
TREE_VER 0
mouse_phase     DB      0
recv_buf0       DB      0
recv_buf1       DB      0
recv_buf2       DB      0
mouse_btn       DB      0
mouse_x         DD      0
mouse_y         DD      0

cursor_x        DD      TREE_SCR_WIDTH / 2
cursor_y        DD      TREE_SCR_HEIGHT / 2


%include "../kernel/graphic/graphic.ic"

; (768)
;  y |
;    |     鼠标使用标准坐标系统
;    |
;    |
;    |
;    |
;    |
;    |_____________________
;  0                   x(1024)

;  0  ______________________
;    |                 y(1024)
;    |
;    |     图形库使用的坐标系统
;    |
;    |
;    |
;    |
;  x |
; (768)



___TREE_DATA_END_