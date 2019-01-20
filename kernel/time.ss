; tree/kernel/time.ss
; Author: hyan23
; Date: 2016.05.03
;

; 这个文件对 8259 芯片(中断控制器) 编程
; 提供访问实时时钟芯片 RTC (8259从片引脚IR0) 的接口

; 1. 8259中断控制器

; 计算机内部安装有两片8259中断控制器, 每片包括8个中断输入引脚,
; 其中, 主片代理输出 INT 直接送往处理器的 INTR 引脚
; 从片代理输出 INT 则送往 主片 IR2 引脚, 形成级联关系
; MASTER:IR0: 系统定时器/计数器芯片, SLAVE:IR0: 实时时钟芯片 RTC
; 在8259内部, 有中断屏蔽寄存器(IMR), 它是一个8位寄存器, 每一位
; 分别对应芯片的8个输入引脚, 0: 允许, 1: 屏蔽
; 主片端口号: 0x20和0x21, 从片端口号: 0xa0和0xa1
; 8259芯片负责维护其引脚中断优先级, 优先级从高到低分别是IR0 - IR7

; 2. 实模式中断向量表

; 处理器一共可以识别 256 种中断, 不可屏蔽的硬件中断: 2
; 中断向量表存放在内存 0x00000 - 0x003ff 号单元, 每个中断向量占 2 个字
; 主片默认起始中断号: 0x08, 从片默认起始中断号: 0x70
; 通过指定芯片起始中断号的方式, 可以修改8259芯片引脚对应中断号
;

; 3. CMOS RAM

; CMOS RAM是一个有 128 字节存储容量的静态存储器
; 常规的日期和时间信息保存在CMOS RAM开始部分的10 字节, 内容如下:

; ------------------------------------------------------------
;    偏移地址   |     内容    |    偏移地址    |       内容       |
; ------------------------------------------------------------
;      0x00     |      秒     |      0x07     |      日       |
;      0x01     |    闹钟秒   |      0x08      |      月       |
;      0x02     |      分     |      0x09      |      年       |
;      0x03     |    闹钟分   |      0x0a      |    寄存器A    |
;      0x04     |      时     |      0x0b      |    寄存器B    |
;      0x05     |    闹钟时   |      0x0c      |    寄存器C    |
;      0x06     |     星期    |      0x0d      |    寄存器D    |
; ------------------------------------------------------------

; 对CMOS RAM的访问, 需要通过两个端口来进行:
; 0x70(只写) 或0x74是索引端口, 用来指定CMOS RAM内单元, 0x71或0x75是数据端口
; 特别说明: 端口0x70 ^ 7是 NMI 中断开关, 0: 允许, 1: 屏蔽

; 寄存器A 功能(简要):
; ----------------------------------------------------------
;    位    |                   描述                          |
; -----------------------------------------------------------
;          | (硬件强制位)(UIP): 正处于更新过程中                |
;    7     |  0: 更新周期至少在 488 微妙内不会启动, 可访问数据    |
;          |  1: 正处于更新周期, 或者马上就要启动                |
; -----------------------------------------------------------
;  3 - 0   | (RS), 周期性中断速率选择                          |
; -----------------------------------------------------------

; 寄存器B 功能(简要):
; ----------------------------------------------------------
;    位    |         描述          |         参数            |
; ----------------------------------------------------------
;     7    | 更新周期禁止 (SET)   | 0: 不禁止, 1: 禁止        |
; ----------------------------------------------------------
;     6    | 周期性中断允许 (PIE) | 0: 不允许, 1: 允许         |
; ----------------------------------------------------------
;     5    | 闹钟中断允许 (ALE)   | 0: 不允许, 1: 允许         |
; ----------------------------------------------------------
;     4    | 更新结束中断允许      | 0: 不允许, 1: 允许        |
; ----------------------------------------------------------
;     2    | 数据模式 (DM)        | 0: BCD, 1: BINARY       |
; ----------------------------------------------------------
;     1    | 小时格式 (HOURFORM)  |0: 12小时制, 1: 24小时制   |
; ----------------------------------------------------------

%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'string', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'gettime', gettime
    __TREE_EXPORT @3, 'gettime_str', gettime_str
    __TREE_EXPORT @1, 'getdate', getdate
    __TREE_EXPORT @4, 'getdate_str', getdate_str
    __TREE_EXPORT @5, 'getseed', getseed

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'strcpy', strcpy

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax


; 获取系统时间(从缓存)
; ret: ax: 秒, cx: 分, dx: 时(BCD 编码)

gettime:
    call near gettime0
    retf


gettime0:

    push ebx
    push ds

    TREE_LOCATE_DATA                             ; 从静态存储读取
    mov eax, TREE_LIB_NOWTIME_OFS
    mov ebx, current_time
    mov ecx, 3
    TREE_PCI0CALL TREE_PCI0_SEL_PROCEDURE_READ_LIB

    mov dl, [ds:(0 + ebx)]
    mov cl, [ds:(1 + ebx)]
    mov al, [ds:(2 + ebx)]

    pop ds
    pop ebx

    ret


gettime_str:                                     ; 时间格式化
                                                 ; hh:mm:ss
    pushad
    push ds
    push es

    mov ax, ds
    mov es, ax
    mov edi, ebx
    TREE_LOCATE_DATA
    mov esi, time_str

    call near generate_time_str
    TREE_CALL strcpy

    pop es
    pop ds
    popad

    retf


generate_time_str:                               ; 格式化过程

    pushad
    push ds

    TREE_LOCATE_DATA
    mov ebx, time_str
    call near gettime0

    push cx
    mov cx, dx
    call near bcd2char
    mov [ds:(0 + ebx)], cx
    mov BYTE [ds:(2 + ebx)], ':'
    pop cx
    call near bcd2char
    mov [ds:(3 + ebx)], cx
    mov BYTE [ds:(5 + ebx)], ':'
    mov cx, ax
    call near bcd2char
    mov [ds:(6 + ebx)], cx

    pop ds
    popad

    ret


; 获取系统日期(从缓存)
; ret: ax: day, cx: month, dx: year(BCD 编码)

getdate:

    call near getdate0
    retf


getdate0:

    push ebx
    push ds

    TREE_LOCATE_DATA                             ; 从静态存储读取
    mov eax, TREE_LIB_TODAY_OFS
    mov ebx, current_date
    mov ecx, 3
    TREE_PCI0CALL TREE_PCI0_SEL_PROCEDURE_READ_LIB

    mov dl, [ds:(0 + ebx)]
    mov cl, [ds:(1 + ebx)]
    mov al, [ds:(2 + ebx)]

    pop ds
    pop ebx

    ret


getdate_str:                                     ; 日期格式化
                                                 ; yy:mm:dd
    pushad
    push ds
    push es

    mov ax, ds
    mov es, ax
    mov edi, ebx
    TREE_LOCATE_DATA
    mov esi, date_str

    call near generate_date_str
    TREE_CALL strcpy

    pop es
    pop ds
    popad

    retf


generate_date_str:                               ; 格式化过程

    pushad
    push ds

    TREE_LOCATE_DATA
    mov ebx, date_str
    call near getdate0

    push cx
    mov cx, dx
    call bcd2char
    mov [ds:(0 + ebx)], cx
    mov BYTE [ds:(2 + ebx)], '-'
    pop cx
    call bcd2char
    mov [ds:(3 + ebx)], cx
    mov BYTE [ds:(5 + ebx)], '-'
    mov cx, ax
    call near bcd2char
    mov [ds:(6 + ebx)], cx

    pop ds
    popad

    ret


; char bcd2char(char:cl:bcd);

bcd2char:
    mov ch, cl                                   ; cl(0-3)->ch
    and ch, 00001111b                            ; cl(4-7)->cl
    and cl, 11110000b
    shr cl, 4

    cmp ch, 0x9                                  ; 高位
    jna .j0

    add ch, 'a'
    jmp near .j1

.j0:
    add ch, '0'

.j1:                                             ; 低位
    cmp cl, 0x9
    jna .j

    add cl, 'a'
    jmp near .fin

.j:
    add cl, '0'

.fin:
    ret


; uint32:eax getseed(void);

getseed:

    push ecx
    push edx
    push ds

    ;xor eax, eax ;;;;;;;;
    TREE_LOCATE_DATA
    add ax, [ds:current_time]
    mov ecx, 0xabcdef13
    mul ecx
    add dl, [ds:(2 + current_time)]
    add eax, edx
    mul ecx

    pop ds
    pop edx
    pop ecx

    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'time'
TREE_VER 0

TREE_SZBUF time_str, 9
TREE_SZBUF date_str, 9

    current_time DB 0, 0, 0
    current_date DB 0, 0, 0


___TREE_DATA_END_