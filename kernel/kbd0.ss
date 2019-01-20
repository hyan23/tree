; tree/inc/nasm/sys/kbd0.ss
; Author: hyan23
; Date: 2016.05.26
;

; [TREE]键盘驱动程序
; 暂不支持左右shift和ctrl识别, 不支持数字键盘
; 另外, capslock对所有字符有效(除字母以外的)

; 一、键盘输入
; 1. 键盘上的每一个键都相当于一个开关，键盘中有一个芯片对键盘上的每一个键的状态进行扫描。
;    1）按下一个键时，开关接通，该芯片就产生一个扫描码（通码）,
;        该扫描码说明了按下的键在键盘上的位置。
;        扫描码被送入主板上的相关接口芯片的寄存器中，该寄存器的端口地址为60h。
;    2）松开按下的键时，也产生一个扫描码（断码）,
;        该扫描码说明了松开的键在键盘上的位置。
;        松开时产生的扫描码也被送入 60h 端口中。
; 2、扫描码长度为一个字节（8位），通码的第7位为0，断码的地7位为1。
;
; 二、触发9号中断
; 键盘的输入到达 60h 端口时，相关的芯片就会向CPU发出中断类型码为 9h 的可屏蔽中断信息。
;    CPU检测到该中断后，如果IF＝1，则响应中断，转去执行int 9h中断例程。

; 三、int 9h中断例程基本任务
;    1）读出 60h 端口中的扫描码;
;    2）如果是字符键的扫描码，将该扫描码和其对应的字符码送入键盘缓冲区;
;        如果是控制键（如：Ctrl）和切换键（如：CapsLock）的扫描码，
;        则将其转变为状态字节（用二进制位记录控制键和切换键状态的字节）写入状态向量。
;    3）对键盘系统进行相关的控制，比如说，向相关芯片发出应答信息。
;

; 对标准输入流(缓存区(队列)) 的控制

; int9:
;    if writec < queue_char_len
;        write t0 que_char[writec]
;        writec ++
;    else
;        drop
;        ; (1) <-- que_char
;        ; write t0 que_char[writec]
;    fi

; GET_CHAR:
;    if 0 < writec
;        read que_char[0]
;        (1) <-- que_char
;        writec --
;    else
;        wait int9(0 < writec)
;    fi

; que_char
; head | | | | | | | | | | | | | | | tail
;   readc(static 0)        writec
;

%include "../boot/LIB.ic"
%include "../kernel/gate.ic"
%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/def0.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'kbd0', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @444, 'kbd0foo', foo

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'kbd0foo', fOO

___TREE_IPT_TAB_END_


; constant
    QUEUE_CHAR_LEN          EQU         64

; 扫描码 (状态)
    SCAN_CAPSLOCK           EQU         0x3a
    SCAN_LSHIFT             EQU         0x2a
    SCAN_RSHIFT             EQU         0x36
    SCAN_LCTRL              EQU         0x1d
    SCAN_RCTRL              EQU         0x1d
    SCAN_ALT                EQU         0x38
    SCAN_SCRLOCK            EQU         0x46
    SCAN_NUMLOCK            EQU         0x45

; 状态在状态向量偏移
    STATUS_CAPSLOCK         EQU         0
    STATUS_SHIFT            EQU         1
    STATUS_CTRL             EQU         2
    STATUS_ALT              EQU         3
    STATUS_SCRLOCK          EQU         4
    STATUS_NUMLOCK          EQU         5


___TREE_CODE_BEGIN_

TREE_START:

    mov ax, [ss:TREE_USR_STACK - 4 - 1]          ; 加载:
    mov es, ax                                   ; 进程空间
    mov ax, [es:ACCESS_SRC(4 + fOO)]             ; 全局代码

    mov ebx, INT21                               ; 安装21号中断。
    mov ecx, 0x21
    TREE_ABSCALL INSTALL_IDT_INTGATE

    push eax

    mov ax, [ss:esp]                             ; 安装这些导出函数
    mov ebx, 0                                   ; 的调用门。
    mov ecx, GET_CHAR
    mov edx, __GET_CHAR
    TREE_ABSCALL INSTALL_CALL_GATE
    test eax, TREE_LOGICAL_TRUE
    jz .failed

    mov ax, [ss:esp]
    mov ebx, 0
    mov ecx, QCHAR_CLEAR
    mov edx, __QCHAR_CLEAR
    TREE_ABSCALL INSTALL_CALL_GATE
    test eax, TREE_LOGICAL_TRUE
    jz .failed

    mov ax, [ss:esp]
    mov ebx, 0
    mov ecx, QCHAR_EMPTY
    mov edx, __QCHAR_EMPTY
    TREE_ABSCALL INSTALL_CALL_GATE
    test eax, TREE_LOGICAL_TRUE
    jz .failed

    mov ax, [ss:esp]
    mov ebx, 0
    mov ecx, CAPSLOCKED
    mov edx, __CAPSLOCKED
    TREE_ABSCALL INSTALL_CALL_GATE
    test eax, TREE_LOGICAL_TRUE
    jz .failed

    mov ax, [es:TREE_PROC_PRIVATE_GD_SEL_OFS]    ; 缓存全局数据段选择子
    mov bx, LIB_SEL                              ; 以便在中断处理过程中
    mov ds, bx                                   ; 访问本地数据。
    mov [ds:TREE_LIB_KBD_DAT_SEL_OFS], ax


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
    mov ax, [ds:TREE_LIB_KBD_DAT_SEL_OFS]
    mov ds, ax

    pop ax

%endmacro ; THIS_USE_DATA



; in: ds:[bx]: que
; (1) <-- que

%macro SHIFT_QUE 1

    push cx
    push si
    push di

    mov cx, QUEUE_CHAR_LEN - 1

    mov si, bx                                   ; si: 0
    mov di, bx                                   ; di: 1
    inc di                                       ; cx: QUEUE_CHAR_LEN - 1

.shiftq%1:
    push cx
    mov cl, [ds:di]
    mov [ds:si], cl
    inc si
    inc di
    pop cx
    loop .shiftq%1

    pop di
    pop si
    pop cx

%endmacro ; SHIFT_QUE


; char GET_CHAR(void);
; 从输入队列读取一个字符(包括控制字符)

GET_CHAR:

    push ax
    push bx
    push ds

    THIS_USE_DATA                                ; 使用数据

.readc:                                          ; 读写入索引的值
    mov bx, writec
    mov ax, [ds:bx]
    cmp ax, 0                                    ; 队列不为空
    jnz .ok

.wait:
    ;hlt                                         ; 停机等待
                                                 ;jmp near .readc
    mov cl, 0
    jmp near .fin

.ok:
    mov bx, que_char                             ; 读队首字符
    mov cl, [ds:bx]

    SHIFT_QUE s1                                 ; 整个队列向前移动

    mov bx, writec                               ; writec --
    mov ax, [ds:bx]
    dec ax
    mov [ds:bx], ax

.fin:
    pop ds
    pop bx
    pop ax

    retf


; void QCHAR_CLEAR(void);
; 清空输入队列

QCHAR_CLEAR:

    push bx
    push ds

    THIS_USE_DATA

    mov bx, writec                               ; 只需将索引清零
    mov WORD [ds:(bx)], 0

    pop ds
    pop bx

    retf


; bool QCHAR_EMPTY(void);
; 查询输入队列是否为空

QCHAR_EMPTY:

    push bx
    push ds

    THIS_USE_DATA

    mov bx, writec                               ; 读索引
    mov bx, [ds:(bx)]

    cmp bx, 0
    jnz .not

    mov eax, TREE_LOGICAL_TRUE

.fin:
    pop ds
    pop bx

    retf

.not:
    mov eax, TREE_LOGICAL_FALSE
    jmp near .fin


; bool CAPSLOCKED(void);
; 查询 capslock 状态

CAPSLOCKED:

    push bx
    push ds

    xor eax, eax
    THIS_USE_DATA
    mov bx, STATUS_CAPSLOCK
    mov ax, [ds:bx]

    pop ds
    pop bx

    retf


; 键盘中断处理过程

INT21:
    pushfd
    pushad
    push ds

    THIS_USE_DATA
    mov bx, status

    xor ax, ax                                   ; 读扫描码
    in al, 0x60
    test al, 0x80                                ; 断码
    jnz .j1

.j0:                                             ; 通码
    cmp al, SCAN_CAPSLOCK
    jz .capslock
    cmp al, SCAN_LCTRL
    jz .ctrl
    cmp al, SCAN_RCTRL
    jz .ctrl
    cmp al, SCAN_LSHIFT
    jz .shift
    cmp al, SCAN_RSHIFT
    jz .shift
    cmp al, SCAN_ALT
    jz .alt
    cmp al, SCAN_SCRLOCK
    jz .scrlock
    cmp al, SCAN_NUMLOCK
    jz .numlock

.com:                                            ; 普通字符
    jmp near .dec

.capslock:                                       ; 取反
    mov cl, [ds:(STATUS_CAPSLOCK + bx)]
    xor cl, 0x01
    mov [ds:(STATUS_CAPSLOCK + bx)], cl
    jmp near .dec

.ctrl:                                           ; 置状态
    mov byte [ds:(STATUS_CTRL + bx)], TREE_LOGICAL_TRUE
    jmp near .dec

.shift:
    mov byte [ds:(STATUS_SHIFT + bx)], TREE_LOGICAL_TRUE
    jmp near .dec

.alt:
    mov byte [ds:(STATUS_ALT + bx)], TREE_LOGICAL_TRUE
    jmp near .dec

.scrlock:
    mov byte [ds:(STATUS_SCRLOCK + bx)], TREE_LOGICAL_TRUE
    jmp near .dec

.numlock:
    mov byte [ds:(STATUS_NUMLOCK + bx)], TREE_LOGICAL_TRUE
    jmp near .dec

.j1:                                             ; 断码
    and al, 0x7f                                 ; 清最高位, 一致编码

    cmp al, SCAN_LCTRL
    jz .ctrl0
    cmp al, SCAN_RCTRL
    jz .ctrl0
    cmp al, SCAN_LSHIFT
    jz .shift0
    cmp al, SCAN_RSHIFT
    jz .shift0
    cmp al, SCAN_ALT
    jz .alt0
    cmp al, SCAN_SCRLOCK
    jz .scrlock0
    cmp al, SCAN_NUMLOCK
    jz .numlock0
                                                 ; default
    jmp near .fin

.ctrl0:                                          ; 清状态
    mov byte [ds:(STATUS_CTRL + bx)], TREE_LOGICAL_FALSE
    jmp near .fin

.shift0:
    mov byte [ds:(STATUS_SHIFT + bx)], TREE_LOGICAL_FALSE
    jmp near .fin

.alt0:
    mov byte [ds:(STATUS_ALT + bx)], TREE_LOGICAL_FALSE
    jmp near .fin

.scrlock0:
    mov byte [ds:(STATUS_SCRLOCK + bx)], TREE_LOGICAL_FALSE
    jmp near .fin

.numlock0:
    mov byte [ds:(STATUS_NUMLOCK + bx)], TREE_LOGICAL_FALSE
    jmp near .fin

.dec:                                            ; 解码(映射)
    cmp al, 0x51                                 ; 跳过大于 0x52 的代码
    ja .fin

    dec    al                                    ; 扫描码从1开始

    xor cx, cx                                   ; 确定映射表
    mov cl, [ds:(STATUS_CAPSLOCK + bx)]
    push cx
    mov cl, [ds:(STATUS_SHIFT + bx)]
; caps       shift         res
;   1          1            0
;   1          0            1
;   0          1            1
;   0          0            0
    xor cx, [ss:esp]

    test cl, TREE_LOGICAL_TRUE
    jnz .upper

.lower:
    mov bx, MAPPING_TAB_LOWER
    jmp near .ready

.upper:
    mov bx, MAPPING_TAB_UPPER

.ready:
    pop cx

    add bx, ax                                   ; ascll/vk
    mov al, [ds:bx]

    mov bx, writec
    mov cx, [ds:bx]                              ; 读写入索引

    mov bx, que_char                             ; .full, .ok 用
    cmp cx, QUEUE_CHAR_LEN                       ; 队列未满, 直接写入
    jl .ok

.full:
                                                 ; SHIFT_QUE s2
                                                 ; dec cx
    jmp near .fin                                ; 丢弃

.ok:
    add bx, cx
    mov [ds:bx], al

    mov bx, writec                               ; writec ++
    mov cx, [ds:bx]
    inc cx
    mov [ds:bx], cx

.fin:
    mov al, 0x20                                 ; 发送中断结束命令EOI
    out 0x20, al

    pop ds
    popad
    popfd

    iretd


foo:


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'kbd0'
TREE_VER 0

; Supported Keyboard Layout
; -------------------------------------------------
; esc f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 PrtSc Ins Del |
;    1  2  3  4  5  6  7  8  9  0  -  =  backspace |
; tab q  w  e  r  t  y  u  i  o  p  []  \        |
; caps a  s  d  f  g  h  j  k  l  ;  '  enter      |
; shift z  x  c  v  b  n  m  ,  .  /  r-shift up   |
; ctrl     alt       space   alt     ctrl  L  Dn R |
; -------------------------------------------------
; home PgUp PgDn NumLock ScrollLock End
; --------------------

; 扫描码 - ascll/vk 映射表
;             esc 1 2 3 4 5 6 7 8 9 0 '-' '=' backspace
MAPPING_TAB_LOWER DB VK_ESC, '1234567890-=', VK_BACK

;      tab q w e r t y u i o p '[' ']' enter   ctrl
LOWER_0 DB VK_TAB, 'qwertyuiop[]', VK_ENTER, VK_CTRL

;      a s d f g h i j k l ';' '\''       '\'      left-shift    '\'
LOWER_1 DB 'asdfghjkl;', ASCLL_QUOTA, ASCLL_SLASH, VK_LSHIFT, ASCLL_SLASH

;  z x c v b n m ',' '.' '/'
LOWER_2 DB 'zxcvbnm,./'

;     right-shift PrtSc Alt Space CapsLock
;     F1 F2 F3 F4 F5 F6 F7 F8 F9 F10
;     NumLock ScrollLock Home arr-up '-' arr-left
;     arr-right '+' End arr-down PgDn Ins Del
LOWER_3 DB VK_RSHIFT, VK_PRTSC, VK_ALT, ' ', VK_CAPS, \
    VK_F1, VK_F2, VK_F3, VK_F4, VK_F5, VK_F6, VK_F7, VK_F8, VK_F9, VK_F10, \
    VK_NUM, VK_SCRLK, VK_HOME, VK_UP, '-', VK_LEFT, \
    VK_RIGHT, '+', VK_END, VK_DOWN, VK_PGUP, VK_INS, VK_DEL


; 扫描码 - ascll/vk 映射表0
;              esc ! @ # $ % ^ & * () '_' '+' backspace
MAPPING_TAB_UPPER DB VK_ESC, '!@#$%^&*()_+', VK_BACK

;       tab Q W E R T Y U I O P '{' '}' enter   ctrl
UPPER_0 DB VK_TAB, 'QWERTYUIOP{}', VK_ENTER, VK_CTRL

;   A S D F G H J K L ':'  '"'       '|'   left-shift   '|'
UPPER_1 DB 'ASDFGHJKL:', ASCLL_DBQUOTA, '|', VK_LSHIFT, '|'

;   Z X C V B N M '<' '>' '?'
UPPER_2 DB 'ZXCVBNM<>?'

;     right-shift PrtSc Alt Space CapsLock
;     F1 F2 F3 F4 F5 F6 F7 F8 F9 F10
;     NumLock ScrollLock Home arr-up '-' arr-left
;     arr-right '+' End arr-down PgDn Ins Del
UPPER_3 DB VK_RSHIFT, VK_PRTSC, VK_ALT, ' ', VK_CAPS, \
    VK_F1, VK_F2, VK_F3, VK_F4, VK_F5, VK_F6, VK_F7, VK_F8, VK_F9, VK_F10, \
    VK_NUM, VK_SCRLK, VK_HOME, VK_UP, '-', VK_LEFT, \
    VK_RIGHT, '+', VK_END, VK_DOWN, VK_PGUP, VK_INS, VK_DEL


; CapsLock Shift Ctrl Alt ScrollLock NumLock
status    DB 0, 0, 0, 0, 0, 0

writec DW 0                                      ; 缓冲区写索引

que_char TIMES QUEUE_CHAR_LEN DB 0               ; 缓冲区

___TREE_DATA_END_