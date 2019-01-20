; tree/kernel/tree.ss
; Author: hyan23
; Date: 2016.05.03
;

; tree-kernel

%include "../kernel/tss.ic"
%include "../kernel/tcb.ic"
%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/def0.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'task0', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'InitTCBChain', InitTCBChain
    __TREE_IMPORT @1, 'CreateProcess0', CreateProcess0
    __TREE_IMPORT @2, 'get_char', get_char

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:                                      ; 创建内核任务

    push ds
    push es

    mov ax, LIB_SEL                              ; ds:ebx:内核tss
    mov ds, ax
    mov ebx, TREE_LIB_KERNEL_TSS_OFS
    mov ax, [ss:(TREE_USR_STACK - 1 - 4)]        ; es:内核空间
    mov es, ax
                                                 ; 只填写必要信息。
    mov eax, [es:ACCESS_SRC(TREE_XFILE_ENTRY_OFS)]
    mov [ds:(TREE_TSS_REGISTER_EIP_OFS + ebx)], eax
    mov DWORD [ds:(TREE_TSS_REGISTER_EFLAGS_OFS + ebx)], \
        TREE_TSS_BUILT_EFLAGS
    mov DWORD [ds:(TREE_TSS_REGISTER_ESP_OFS + ebx)], esp
    mov ax, [es:ACCESS_SRC(4 + TREE_XFILE_ENTRY_OFS)]
    mov [ds:(TREE_TSS_SEGSEL_CS_OFS + ebx)], ax
    mov ax, [es:TREE_PROC_SEL_STK_0_SEL_OFS]
    mov [ds:(TREE_TSS_SEGSEL_SS_OFS + ebx)], ax
    mov ax, [es:ACCESS_SRC(TREE_XFILE_DATA_OFS - 2)]
    mov [ds:(TREE_TSS_SEGSEL_DS_OFS + ebx)], ax
    mov ax, [es:TREE_PROC_PRIVATE_LDT_LOCATOR_OFS]
    mov [ds:(TREE_TSS_LDT_SEL_OFS + ebx)], ax

                                                 ; 构建tss描述符
    mov eax, TREE_LIB_KERNEL_TSS_OFS + LIB_OFS
    mov edx, eax
    and edx, 0xff000000
    mov ebx, eax
    and ebx, 0x00ff0000
    shr ebx, 16
    or edx, ebx
    or edx, 0x00008900                           ; edx:高位

    and eax, 0x0000ffff
    shl eax, 16
    or eax, 103                                  ; eax:低位

    TREE_ABSCALL ADD_GDT_DESCRIPTOR              ; 安装描述符
    cmp ax, 0                                    ; 现在就overflow
    ; jz .overflow                               ;    谁信?
                                                 ; 因此无视这个错误。

    mov [ds:TREE_LIB_KERNEL_TSS_SEL_OFS], ax     ; 保存选择子
    ltr ax                                       ; 执行内核

    pop es

                                                 ; 以下更新系统时间
%macro __READ_CMOS_RAM__ 1

    mov al, %1
    out 0x70, al
    in al, 0x71

%endmacro ; __READ_CMOS_RAM__

%macro __PUSH_AL__ 0

    and ax, 0x00ff
    push ax

%endmacro ; __PUSH_AL__

.wait:                                           ; 等待时钟更新结束
                                                 ; 读寄存器A
    __READ_CMOS_RAM__ 0x8a                       ; 1000_1010 屏蔽 NMI
    test al, 0x80                                ; 测试UIP
    jnz .wait

    __READ_CMOS_RAM__ 0x80                       ; 读秒
    __PUSH_AL__
    __READ_CMOS_RAM__ 0x82                       ; 读分
    __PUSH_AL__
    __READ_CMOS_RAM__ 0x84                       ; 读时
    __PUSH_AL__
    __READ_CMOS_RAM__ 0x87                       ; day
    __PUSH_AL__
    __READ_CMOS_RAM__ 0x88                       ; month
    __PUSH_AL__
    __READ_CMOS_RAM__ 0x89                       ; year
    __PUSH_AL__

    mov al, 0x00                                 ; 恢复 NMI
    out 0x70, al

    mov ax, LIB_SEL                              ; 保存数据
    mov ds, ax

    pop ax
    mov [ds:(0 + TREE_LIB_TODAY_OFS)], al
    pop ax
    mov [ds:(1 + TREE_LIB_TODAY_OFS)], al
    pop ax
    mov [ds:(2 + TREE_LIB_TODAY_OFS)], al
    pop ax
    mov [ds:(0 + TREE_LIB_NOWTIME_OFS)], al
    pop ax
    mov [ds:(1 + TREE_LIB_NOWTIME_OFS)], al
    pop ax
    mov [ds:(2 + TREE_LIB_NOWTIME_OFS)], al

    TREE_CALL InitTCBChain                       ; 初始化tcb链

%if (1 == TREE_ENABLE_GRAPHIC)                  ; 创建sh/wm
    mov eax, LIBMSGQ_SEC
    mov bl, TREE_LOGICAL_FALSE
    TREE_CALL CreateProcess0
    mov eax, LIBLINK_SEC
    mov bl, TREE_LOGICAL_FALSE
    TREE_CALL CreateProcess0
    mov eax, LIBWINDOW_SEC
    mov bl, TREE_LOGICAL_FALSE
    TREE_CALL CreateProcess0
    mov eax, LIBDESKTOP_SEC
    mov bl, TREE_LOGICAL_FALSE
    TREE_CALL CreateProcess0
    mov eax, LIBEVENT_SEC
    mov bl, TREE_LOGICAL_FALSE
    TREE_CALL CreateProcess0
    mov eax, LIBWM_SEC
%else
    mov eax, LIBSH_SEC
%endif ; 1 == TREE_ENABLE_GRAPHIC

    mov bl, TREE_LOGICAL_FALSE
    TREE_CALL CreateProcess0

    mov ax, LIB_SEL                              ; 缓存sh的tcb节点
    mov ds, ax                                   ; 由于sh是内核创建的最后一个任务
    mov ax, [ds:TREE_LIB_TCB_CHAIN_HEAD_OFS]     ; 因此tcb_chain_head->prev
    mov ds, ax                                   ; 即是sh.tcb
    mov bx, [ds:TREE_TCB_PREV_TCB_OFS]
    mov ax, LIB_SEL
    mov ds, ax
    mov [ds:TREE_LIB_SH_TCB_SEL_OFS], bx

    pop ds


    mov al, 0x0                                  ; 开放8259所有引脚。
    out 0x21, al
    mov al, 0x00
    out 0xa1, al


    sti                                          ; 开中断,
                                                 ; 使系统开始工作。

.h:                                              ; 内核进入休眠
    ;mov cl, 'k'
    ;TREE_ABSCALL PUT_CHAR
    hlt
    jmp .h

    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_COM, eax

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'tree'
TREE_VER 0
TREE_STRING TEXT, 'kernel is runing.\n'

___TREE_DATA_END_