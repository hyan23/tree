; tree/kernel/int0.ss
; Author: hyan23
; Date: 2016.06.17
;

; 中断管理
; 对8259a中断控制器编程，
;     并安装通用中断处理程序。

%include "../boot/absc.ic"
%include "../kernel/private.ic"
%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'int0', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'int0foo', foo

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'int0foo', fOO

___TREE_IPT_TAB_END_

; 导入自己的符号的目的是, 找到自己代码的全局选择子, 以便安装中断。
; 在全局空间内命名勿重复。

___TREE_CODE_BEGIN_

TREE_START:
    mov ax, [ss:TREE_USR_STACK - 4 - 1]          ; 进程空间
    mov es, ax                                   ; 加载
    mov ax, [es:ACCESS_SRC(4 + fOO)]             ; 全局代码

    xor ecx, ecx                                 ; 默认异常处理
.exp:
    mov ebx, general_exception_handler
    TREE_ABSCALL INSTALL_IDT_INTGATE
    inc ecx
    cmp ecx, 19
    jna .exp

    mov ecx, 32                                  ; 默认中断处理
.intr:
    mov ebx, general_interrupt_handler
    TREE_ABSCALL INSTALL_IDT_INTGATE
    inc ecx
    cmp ecx, 255
    jna .intr

    mov ecx, 0x70                                ; 实时时钟rtc
    mov ebx, int70
    TREE_ABSCALL INSTALL_IDT_INTGATE

    mov ecx, 0x74                                ; 鼠标控制器
    mov ebx, int74
    TREE_ABSCALL INSTALL_IDT_INTGATE


; 重新分配时钟中断芯片中断向量
;     对8259a编程需要使用初始化命令字(Initialize Command Word, ICW), 以设置它的
; 工作方式, 一共有4个初始化命令字, 分别是ICW1 - ICW4, 都是单字节命令, ICW1用于
; 设置中断请求的触发方式, 以及级联的芯片数量, ICW2用于设置每个芯片的中断向量,
; ICW3用于指定使用哪个引脚实现芯片的级联, ICW4用于控制芯片的工作方式。

    mov al, 0xff                                 ; 屏蔽主片所有引脚
    out 0x21, al                                 ; 屏蔽从片所有引脚。
    out 0xa1, al

                                                 ; 配置8259A中断控制器
                                                 ; 主片
    mov al, 0x11
    out 0x20, al                                 ; ICW1: 边沿触发/级联方式
    mov al, 0x20
    out 0x21, al                                 ; ICW2: 起始中断向量0x20
    mov al, 0x04
    out 0x21, al                                 ; ICW3: 从片级联到IR2
    mov al, 0x01
    out 0x21, al                                 ; ICW4: 非总线缓冲，全嵌套，正常EOI

                                                 ; 从片
    mov al, 0x11
    out 0xa0, al                                 ; ICW1：边沿触发/级联方式
    mov al, 0x70
    out 0xa1, al                                 ; ICW2: 起始中断向量0x70
    mov al, 0x04
    out 0xa1, al                                 ; ICW3: 级联到IR2
    mov al, 0x01
    out 0xa1, al                                 ; ICW4: 非总线缓冲，全嵌套，正常EOI

                                                 ; 以下配置实时时钟芯片rtc
    mov al, 0x0a                                 ; RTC寄存器A
    out 0x70, al
    mov al, 0010_0110b
    out 0x71, al

    mov al, 0x0b                                 ; RTC寄存器B
    or al, 0x80                                  ; 阻断NMI
    out 0x70, al
    mov al, 11000011b                            ; 设置寄存器B, 开启周期性中断, 禁止更
    out 0x71, al                                 ; 新结束后中断, BCD码, 24小时制

    mov al, 0x0c                                 ; 读RTC寄存器C，复位未决的中断状态
    out 0x70, al
    in al, 0x71

                                                 ; 以下对i8042键盘控制器编程。
                                                 ;    以激活鼠标
.wt:
    in al, 0x64                                  ; 等待键盘控制器
    test al, 0x02                                ;    准备好接收命令。
    jnz .wt

    mov al, 0x60                                 ; 发往命令寄存器
    out 0x64, al

.wt1:
    in al, 0x64
    test al, 0x02
    jnz .wt1

    mov al, 0x47                                 ; 允许鼠标中断。
    out 0x60, al

.wt3:
    in al, 0x64
    test al, 0x02
    jnz .wt3

    mov al, 0xd4                                 ; 发往鼠标控制器。
    out 0x64, al

.wt2:
    in al, 0x64
    test al, 0x02
    jnz .wt2

    mov al, 0xf4                                 ; 激活鼠标。
    out 0x60, al

    in al, 0x60                                  ; 读应答ack


    mov al, 0x0                                  ; 开放8259所有引脚。
    out 0x21, al
    mov al, 0x0
    out 0xa1, al


    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax


; 通用的异常处理过程
general_exception_handler:
                                                 ; 事实上, 在这里编写中断处理
                                                 ;    过程并不是一个好主意,
                                                 ;    无法访问数据, 无法调用外部
                                                 ;    例程:(
                                                 ; 2016.07.21
                                                 ; 可以将进程空间选择子缓存一份到静态存储。
    ;mov ax, LIB_SEL                             ; 打印消息并停机
    ;mov ds, ax
    ;mov ebx, TREE_LIB_EXCP_OFS
    ;TREE_ABSCALL PUT_STR
    jmp $
    cli
    hlt



; 通用的中断处理过程
general_interrupt_handler:

    pushfd
    push eax

    ;TREE_ABSCALL PUT_CHAR
                                                 ; 向8259a芯片发送
    mov al, 0x20                                 ; 中断结束命令EOI
    out 0xa0, al                                 ; 向从片发送
    out 0x20, al                                 ; 向主片发送

    pop eax
    popfd

    iretd


                                                 ; 以下硬件处理程序仅仅临时使用。
int70:
    pushfd
    pushad

    ;mov cl, 'i'
    ;TREE_ABSCALL PUT_CHAR
                                                 ; 向8259a芯片发送
    mov al, 0x20                                 ; 中断结束命令EOI
    out 0xa0, al                                 ; 向从片发送
    out 0x20, al                                 ; 向主片发送

    mov al, 0x8c                                 ; 必须访问一次寄存器C
    out 0x70, al                                 ; 否则该芯片不会再次产生此中断
    in al, 0x71
    mov al, 0x00
    out 0x70, al

    popad

    iretd


int74:

    pushfd
    pushad

    ;in al, 0x60
    ;call near TREE_DEBUG_PUT_NUM

                                                 ; 向8259a芯片发送
    mov al, 0x64                                 ; 中断结束命令EOI
    out 0xa0, al                                 ; 向从片发送
    mov al, 0x62
    out 0x20, al                                 ; 向主片发送

    popad
    popfd

    iretd


%include "../kernel/debug.s0"

foo:

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'int0'
TREE_VER 0


___TREE_DATA_END_