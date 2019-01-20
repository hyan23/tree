; tree/inc/nasm/io/conio.ss
; Author: hyan23
; Date: 2016.04.30
;

; 公共例程文件, 控制台io

%include "../inc/nasm/spin.ic"
%include "../inc/nasm/io/def0.ic"
%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'kbd', 0
    __TREE_LIB @1, 'agent', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

; out
    __TREE_EXPORT @0, 'putchar', putchar
    __TREE_EXPORT @1, 'puts', puts
    __TREE_EXPORT @5, 'puts0', puts0             ; 追加 '\n'
    __TREE_EXPORT @7, 'putn', putn
    __TREE_EXPORT @6, 'putbcd', putbcd
    __TREE_EXPORT @9, 'setcolor', setcolor
    __TREE_EXPORT @2, 'clrrow', clrrow
    __TREE_EXPORT @3, 'clrscr', clrscr
    __TREE_EXPORT @4, 'gotoxy', gotoxy

; in
    __TREE_EXPORT @20, 'getchar', getchar
    __TREE_EXPORT @21, 'getchar0', getchar0      ; 不区分可打印/非
    __TREE_EXPORT @22, 'gets', gets              ; 读取以回车结束的字符串(可打印)

___TREE_XPT_TAB_END_


___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'get_char', get_char
    __TREE_IMPORT @1, 'qchar_clear', qchar_clear
    __TREE_IMPORT @2, 'put_char', put_char
    __TREE_IMPORT @3, 'put_str', put_str
    __TREE_IMPORT @4, 'set_color', set_color
    __TREE_IMPORT @5, 'clr_row', clr_row
    __TREE_IMPORT @6, 'clr_scr', clr_scr
    __TREE_IMPORT @7, 'goto_xy', goto_xy

___TREE_IPT_TAB_END_


; constant
    TAB_LENGTH        EQU        4               ; tab to spaces


; 代码区
___TREE_CODE_BEGIN_

TREE_START:
    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax


; putchar

putchar:                                         ; 托管例程

    TREE_CALL put_char
    retf


; puts

puts:                                            ; 托管例程

    TREE_CALL put_str
    retf


; puts0

puts0:                                           ; 托管例程, 追加 '\n'
                                                 ; 无同步。
    push cx

    TREE_CALL put_str

    mov cl, ASCLL_CR
    TREE_CALL put_char
    mov cl, ASCLL_LF
    TREE_CALL put_char

    pop cx

    retf


; void putn(uint16:ax);
; 打印一个无符号数字(至屏幕), 并更新

putn:

    push ax
    push cx

    mov cl, '0'                                  ; print "0x"
    TREE_CALL put_char
    mov cl, 'x'
    TREE_CALL put_char

    mov cx, ax                                   ; 逐位分解
    and cx, 0xf000
    shr cx, 12
    call near PUT_HEX

    mov cx, ax
    and cx, 0x0f00
    shr cx, 8
    call near PUT_HEX

    mov cx, ax
    and cx, 0x00f0
    shr cx, 4
    call near PUT_HEX

    mov cx, ax
    and cx, 0x000f
    call near PUT_HEX

    mov cl, ' '
    TREE_CALL put_char

    pop cx
    pop ax

    retf


; void PUT_HEX(uint8:cl:n);
; 打印一位数字(至屏幕), 并更新

PUT_HEX:

    push cx

    cmp cl, 0x0a                                 ; 0 - 9, a - f
    jnb    .hex
    add cl, '0'
    TREE_CALL put_char

    jmp near .fin

.hex:
    sub cl, 0xa
    add cl, 'a'
    TREE_CALL put_char

.fin:
    pop cx

    ret


; void putbcd(uint8:cl:n);
; 打印一位数字(至屏幕)(BCD编码), 并更新。

putbcd:

    push cx

    push cx
    and cl, 0xf0                                 ; 高四位
    shr cl, 4
    add cl, '0'
    TREE_CALL put_char

    pop cx
    and cl, 0x0f                                 ; 低四位
    add cl, '0'
    TREE_CALL put_char

    pop cx

    retf


setcolor:                                        ; 托管
    TREE_CALL set_color
    retf


clrrow:
    TREE_CALL clr_row
    retf


clrscr:
    TREE_CALL clr_scr
    retf


gotoxy:
    TREE_CALL goto_xy
    retf



; char getchar(void);
; 从键盘一个可打印字符

getchar:

    ;TREE_CALL qchar_clear
.try:
    call near GETCHAR_VISUAL

    cmp cl, ' '                                  ; 普通字符
    jb .try
    cmp cl, 127
    ja .try

    retf


; char getchar0(void);
; 从键盘一个字符

getchar0:

    ;TREE_CALL qchar_clear
.try:
    call near GETCHAR_VISUAL
    retf


; gets
; 从键盘一个字符串, 回车结束
; in: ds:ebx: dest, ecx: bufsize
; ret: eax: count

gets:

    push ebx
    push ecx

    xor eax, eax                                 ; counter
    dec ecx                                      ; PCHAR_EOS

.getc:
    call near GETCHAR_VISUAL

    cmp cl, VK_ENTER                             ; 回车结束
    jnz .j0
    cmp eax, 0                                   ; eax = 0, 拒绝
                                                 ; jz .getc
    jmp near .fin

.j0:
    cmp cl, VK_BACK                              ; 删除一个字符(已缓存的)
    jnz .j2
    cmp ebx, [ss:(4 + esp)]
    jz .getc
    dec ebx
    jmp near .getc

.j2:                                             ; 跳过 capslock
    cmp cl, VK_CAPS
    jz .getc

.j1:                                             ; 跳过 shift
    cmp cl, VK_LSHIFT
    jz .getc
    cmp cl, VK_RSHIFT
    jz .getc

    cmp cl, VK_SCRLK                             ; 跳过 scrollLock
    jz .getc
    cmp cl, VK_NUM                               ; 跳过 numlock
    jz .getc

.j4:
    cmp cl, ' '                                  ; 除了回车和控制字之外的
    jb .fin0                                     ; 不可打印字符仍能结束本次输入
    cmp cl, 127                                  ; 要输出一个额外的换行
    ja .fin0

    mov [ds:ebx], cl
    inc eax
    inc ebx

    cmp eax, ecx                                 ; 缓冲区满
    jz .fin

    jmp near .getc

.fin0:
    mov cl, ASCLL_CR
    TREE_CALL put_char
    mov cl, ASCLL_LF
    TREE_CALL put_char

.fin:
    mov byte [ds:ebx], PCHAR_EOS                 ; PCHAR_EOS

    pop ecx
    pop ebx

    retf


; char GETCHAR_VISUAL(void);
; 从键盘读取一个字符(可视化的), 支持退格,
;    制表, 回车换行

GETCHAR_VISUAL:

    TREE_CALL get_char

    cmp cl, VK_BACK                              ; 处理退格
    jnz .j4

    TREE_CALL put_char                           ; 退
    mov cl, ' '                                  ; 空白填充
    TREE_CALL put_char
    mov cl, VK_BACK                              ; 再退
    TREE_CALL put_char
    jmp near .fin

.j4:                                             ; 跳过 shift
    cmp cl, VK_LSHIFT
    jz .fin
    cmp cl, VK_RSHIFT
    jz .fin

.j0:
    cmp cl, VK_TAB                               ; 处理制表符
    jnz .j1                                      ; 打印 TAB_LENGTH 个空格
    push ecx

    mov ecx, TAB_LENGTH
.s0:
    push cx
    mov cl, ' '
    TREE_CALL put_char
    pop cx
    loop .s0

    pop ecx
    mov cl, VK_TAB
    jmp near .fin

.j1:                                             ; 回车换行
    cmp cl, VK_ENTER
    jnz .j2
    mov cl, ASCLL_CR
    TREE_CALL put_char
    mov cl, ASCLL_LF
    TREE_CALL put_char
    mov cl, VK_ENTER
    jmp near .fin

.j2:
    cmp cl, ' '                                  ; 普通字符
    jb .fin                                      ; 过滤非可打印
    cmp cl, 127
    ja .fin

    TREE_CALL put_char

.fin:

    ret


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'conio'
TREE_VER 0

___TREE_DATA_END_