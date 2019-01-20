; tree/kernel/task0.ss
; Author: hyan23
; Date: 2016.06.17
;

; 任务管理程序, 负责任务创建, 调度, 清理。

%include "../boot/gdt.ic"
%include "../boot/LIB.ic"
%include "../kernel/tcb.ic"
%include "../kernel/gate.ic"
%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @1, 'task0', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'InitTCBChain', InitTCBChain
    __TREE_EXPORT @1, 'CreateProcess0', CreateProcess0
    __TREE_EXPORT @1234, 'TaskFoo', TaskFoo

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'TaskFoo', TaskFOO

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    mov ax, [ss:TREE_USR_STACK - 4 - 1]          ; 加载:
    mov es, ax                                   ; 进程空间
    mov ax, [es:ACCESS_SRC(4 + TaskFOO)]         ; 全局代码

    mov ebx, int70                               ; 安装int70中断
    mov ecx, 0x70                                ; 开启任务调度
    TREE_ABSCALL INSTALL_IDT_INTGATE
    push eax

    mov eax, [ss:esp]                            ; 安装调用门。
    mov ebx, 0
    mov ecx, CreateProcess0
    mov edx, __CREATE_PROCESS
    TREE_ABSCALL INSTALL_CALL_GATE
    test eax, TREE_LOGICAL_TRUE
    jz .failed

    mov eax, [ss:esp]
    mov ebx, 0
    mov ecx, GetTickCount
    mov edx, __GET_TICK_COUNT
    TREE_ABSCALL INSTALL_CALL_GATE
    test eax, TREE_LOGICAL_TRUE
    jz .failed

    mov eax, [ss:esp]
    mov ebx, 0
    mov ecx, GetTaskPid
    mov edx, __GET_TASK_PID
    TREE_ABSCALL INSTALL_CALL_GATE
    test eax, TREE_LOGICAL_TRUE
    jz .failed


    xor eax, eax
.fin:
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax

.failed:
    pop eax
    mov eax, -1
    jmp near .fin



; 初始化tcb链, 创建tcb链的第一个节点:内核任务。
; bool:eax InitTCBChain(void);

InitTCBChain:

    push ecx
    push ds
    push es

    mov ax, LIB_SEL                              ; 静态存储区
    mov ds, ax

    mov ecx, TREE_TCB_SIZE                       ; 请求一个节点
    TREE_ABSCALL ALLOC_MEMORY0
    cmp ax, 0
    jz .overflow

    mov es, ax                                   ; 初始化节点
    mov WORD [es:TREE_TCB_PID_OFS], TREE_INVALID_PID
    mov ax, [ds:TREE_LIB_KERNEL_TSS_SEL_OFS]     ;把内核
    mov [es:TREE_TCB_TSS_SEL_OFS], ax            ; 作为第一个任务
    mov WORD [es:TREE_TCB_STATUS_OFS], TREE_TCB_STATUS_BUSY
    mov DWORD [es:TREE_TCB_SLEEP_OFS], 0
    mov [es:TREE_TCB_PREV_TCB_OFS], es           ; 自循环
    mov [es:TREE_TCB_NEXT_TCB_OFS], es

                                                 ;并标记当前任务
    mov [ds:TREE_LIB_CURRENT_TASK_OFS], es

                                                 ; 它是头结点
    mov [ds:TREE_LIB_TCB_CHAIN_HEAD_OFS], es
    mov [ds:TREE_LIB_KERNEL_TCB_OFS], es

    mov WORD [ds:TREE_LIB_TASK_COUNT_OFS], 1     ;进程计数
    mov WORD [ds:TREE_LIB_ACTIVE_COUNT_OFS], 1   ;活动进程计数

    mov eax, TREE_LOGICAL_TRUE

.fin:
    pop es
    pop ds
    pop ecx

    retf

.overflow:
    mov eax, TREE_LOGICAL_FALSE
    jmp near .fin


; xxx CreateProcess0(xxx);
; in: eax: sector in LBA, bool:ebx: sh-task
; ret: eax: 1: succeeded, 0: failed, ecx(0-15): pid

CreateProcess0:

    pushfd
    push ebx
    push ds

    TREE_ABSCALL LOAD_PROCESS                    ; 装载到系统
    cmp eax, LOAD_PROCESS_SUCCEEDED              ; cx(0-15): tss
    jnz .failed                                  ; (16-31): pid

    push ecx                                     ; 请求一个任务链节点
    mov ecx, TREE_TCB_SIZE                       ;    所需空间
    TREE_ABSCALL ALLOC_MEMORY0
    pop ecx
    cmp ax, 0
    jz .overflow

    mov ds, ax                                   ; 填写属性
    mov [ds:TREE_TCB_TSS_SEL_OFS], cx
    shr ecx, 16
    mov WORD [ds:TREE_TCB_PID_OFS], cx           ; 等待状态
    mov BYTE [ds:TREE_TCB_BLSH_OFS], bl          ; sh绑定任务。
    mov WORD [ds:TREE_TCB_STATUS_OFS], TREE_TCB_STATUS_WAIT
    mov DWORD [ds:TREE_TCB_SLEEP_OFS], 0
    mov WORD [ds:TREE_TCB_PREV_TCB_OFS], NUL_SEL
    mov WORD [ds:TREE_TCB_NEXT_TCB_OFS], NUL_SEL

    push ecx                                     ; 添加到tcb链
    mov cx, ds
    call near append_2_tcb_chain
    pop ecx

    mov ax, LIB_SEL                              ; 更新进程计数
    mov ds, ax
    mov ax, [ds:TREE_LIB_TASK_COUNT_OFS]
    inc ax

    mov [ds:TREE_LIB_TASK_COUNT_OFS], ax
    mov ax, [ds:TREE_LIB_ACTIVE_COUNT_OFS]
    inc ax
    mov [ds:TREE_LIB_ACTIVE_COUNT_OFS], ax

    mov eax, TREE_LOGICAL_TRUE
.fin:
    pop ds
    pop ebx
    popfd

    retf

.failed:
    mov ecx, TREE_INVALID_PID
    mov eax, TREE_LOGICAL_FALSE
    jmp near .fin

.overflow:
    ; TODO: FREE
    jmp near .failed


; void append_2_tcb_chain(uint16:cx:tcbsel);
; in: cx: tcbsel
; ret: none
; TODO: sync-tcb-chain

append_2_tcb_chain:

    pushfd
    cli
    push ax
    push ds
    push es

    mov ax, LIB_SEL                              ; 头结点
    mov ds, ax
    mov ax, [ds:TREE_LIB_TCB_CHAIN_HEAD_OFS]
                                                 ; ASSERT(NUL_SEL != ax)
    mov ds, ax
    push ax                                      ; nowLIBe: ax:head
                                                 ;    cx:newnode

.s0:                                             ; 遍历任务链
    mov ax, [ds:TREE_TCB_NEXT_TCB_OFS]           ; 如果next域 = 头结点
    cmp ax, [ss:esp]                             ; 判断当前节点是最后一个节点。
    jz .lastnode
    mov ds, ax
    jmp .s0

.lastnode:
    pop ax                                       ; nowLIBe: ax:head
                                                 ; ds:oldnode, cx:newnode

    mov es, cx                                   ; 新节点
    mov [es:TREE_TCB_PREV_TCB_OFS], ds           ; 新节点->prev=旧节点
    mov [es:TREE_TCB_NEXT_TCB_OFS], ax           ; 新节点->next=head
    mov [ds:TREE_TCB_NEXT_TCB_OFS], cx           ; 旧节点->next=新节点
    mov ds, ax                                   ; head->prev=新节点
    mov [ds:TREE_TCB_PREV_TCB_OFS], cx

.fin:
    pop es
    pop ds
    pop ax
    popfd

    ret


; uint32:eax GetTickCount(void);

GetTickCount:

    push ds

    mov ax, LIB_SEL
    mov ds, ax
    mov eax, [ds:TREE_LIB_TICK_COUNT_OFS]

    pop ds

    retf


; uint32:eax GetTaskPid(void);

GetTaskPid:

    push ds

    xor eax, eax
    mov ax, LIB_SEL
    mov ds, ax
    mov ax, [ds:TREE_LIB_CURRENT_TASK_OFS]
    mov ds, ax
    mov ax, [ds:TREE_TCB_PID_OFS]

    pop ds

    retf



; void kill_task(void);
; in: es: tcbsel
; ret: es: NUL_SEL

kill_task:

    push eax
    push cx
    push ds

    mov cx, [es:TREE_TCB_PID_OFS]                ; pid

    TREE_LOCATE_PROC                             ; 销毁tss
    mov ax, [ds:TREE_PROC_PRIVATE_TSS_SEL_OFS]
    mov ds, ax
    TREE_ABSCALL FREE_MEMORY

    TREE_ABSCALL TREE_XENV_FREE                  ; 销毁进程空间

    mov cx, [es:TREE_TCB_TSS_SEL_OFS]            ; 移除描述符
    TREE_ABSCALL REM_GDT_DESCRIPTOR0

    mov ax, [es:TREE_TCB_PREV_TCB_OFS]           ; ax:prev
    mov cx, [es:TREE_TCB_NEXT_TCB_OFS]           ; cx:next
    mov ds, ax
    mov [ds:TREE_TCB_NEXT_TCB_OFS], cx           ; prev->next=next
    mov ds, cx
    mov [ds:TREE_TCB_PREV_TCB_OFS], ax           ; next->prev=prev

    mov ax, es
    mov ds, ax

    TREE_ABSCALL FREE_MEMORY                     ; 销毁节点

    mov ax, LIB_SEL                              ; 任务数-1
    mov ds, ax
    mov ax, [ds:TREE_LIB_TASK_COUNT_OFS]
    dec ax
    mov [ds:TREE_LIB_TASK_COUNT_OFS], ax
    mov ax, [ds:TREE_LIB_ACTIVE_COUNT_OFS]
    dec ax
    mov [ds:TREE_LIB_ACTIVE_COUNT_OFS], ax

    pop ds
    pop cx
    pop eax

    ret


; void SwitchTask(void);
; in: none
; ret: none

SwitchTask:

    pushad
    push ds
    push es

    mov ax, LIB_SEL
    mov ds, ax

    mov ax, [ds:TREE_LIB_CURRENT_TASK_OFS]       ; 当前任务
                                                 ; ASSERT(NUL_SEL != ax)
    mov ds, ax

.ready:                                          ; 如果当前任务为忙,
                                                 ; 当前任务等待。
    cmp WORD [ds:TREE_TCB_STATUS_OFS], TREE_TCB_STATUS_BUSY
    jnz .noset
    mov WORD [ds:TREE_TCB_STATUS_OFS], TREE_TCB_STATUS_WAIT

.noset:
.s0:
    mov ax, [ds:TREE_TCB_NEXT_TCB_OFS]           ; 下一个任务
    mov es, ax
                                                 ; 挂起任务?
    cmp WORD [es:TREE_TCB_STATUS_OFS], TREE_TCB_STATUS_HUNG
    jnz .switch0

.skip:
    mov ds, ax                                   ; 跳过这个任务
    jmp near .s0

.switch0:
                                                 ; 结束任务?
    cmp WORD [es:TREE_TCB_STATUS_OFS], TREE_TCB_STATUS_FIN
    jnz .sleep
.kill:
    mov ax, [es:TREE_TCB_NEXT_TCB_OFS]           ; 从tcb链移除
    call near kill_task                          ; 调度下个任务。
    mov ds, ax
    mov ax, [ds:TREE_TCB_PREV_TCB_OFS]
    mov ds, ax
    jmp near .s0

.sleep:                                          ; 睡眠？
    cmp WORD [es:TREE_TCB_STATUS_OFS], TREE_TCB_STATUS_SLEEP
    jnz .switch

    push ds
    mov bx, LIB_SEL
    mov ds, bx
    mov ebx, [ds:TREE_LIB_TICK_COUNT_OFS]
    pop ds
    mov edx, [es:TREE_TCB_SLEEP_OFS]             ; 唤醒时间
    cmp edx, ebx
    jna .awake                                   ; 唤醒进程

                                                 ; 否则,
    mov ds, ax                                   ; 跳过这个任务。
    jmp near .s0

.awake:
    mov ax, LIB_SEL
    mov ds, ax
    mov ax, [ds:TREE_LIB_ACTIVE_COUNT_OFS]
    inc ax                                       ; 活动进程数+1
    mov [ds:TREE_LIB_ACTIVE_COUNT_OFS], ax

.switch:
                                                 ; 发起任务切换
                                                 ; 开始任务忙
    mov WORD [es:TREE_TCB_STATUS_OFS], TREE_TCB_STATUS_BUSY

    mov ax, LIB_SEL                              ; 设为当前任务
    mov ds, ax
    mov ax, [ds:TREE_LIB_CURRENT_TASK_OFS]
    mov WORD [ds:TREE_LIB_CURRENT_TASK_OFS], es

    mov bx, es                                   ; 如果到这里, 发现只有一个
    cmp ax, bx                                   ; 任务活动(内核), 此时不切换,
    jz .fin                                      ; 且不允许使用状态,防止任务重入。

                                                 ; 针对tcb结点被销毁:
                                                 ; 在切换任务前修改了段寄存器，
                                                 ; 该寄存器将会被缓存进旧任务tss
                                                 ; 如果选择子有效性在其他环境
                                                 ; 发生改变, 那么切换回任务时将
                                                 ; 产生常规保护异常。
                                                 ; 因此我在释放内存的时候
                                                 ; 没有将段描述符赋值为0
                                                 ; 只把对应的位清零使指向的
                                                 ; 槽不可信任,并清除了选择子。
                                                 ; 试图避免这个问题。
                                                 ; 该方法仍不可靠，试想:
                                                 ; 1. 原来的数据段描述符现在变成了
                                                 ; 代码段描述符。
                                                 ; 2. 描述符登记到一半时发生了
                                                 ; 一次任务切换。
                                                 ; 解决方案:
                                                 ; 1. 对系统描述符表分区。
                                                 ; 2. 串行化登记代码。
                                                 ; 3. 惰性释放
                                                 ; 先从链摘除过期任务, 让任务切换
                                                 ; 执行完整的一轮，然后统一释放所有
                                                 ; 失效节点。
.j:
    jmp far [es:TREE_TCB_TASK_ENTRY_OFS]         ;发起任务切换

                                                 ; 最后, 我选择在任务切换后释放这个
                                                 ; 烦人的节点^^。
    ;cmp WORD [es:TREE_TCB_STATUS_OFS], TREE_TCB_STATUS_FIN
    ;jnz .fin

.free:                                           ; 这个方法行不通,因为一个过期任务不
    ;mov ax, es                                  ; 一定和一个活动任务绑定。(就是说一个
    ;cmp ax, NUL_SEL                             ; 过期任务的后面不一定是一个活动任务，
    ;jz .fin                                     ;　所以过期任务得不到释放)
                                                 ;　(得不到及时释放，但肯定有机会释放,
                                                 ;　所以还是可以尝试一下的,
                                                 ; 2016.10.21)

    ;mov ds, ax
    ;TREE_ABSCALL FREE_MEMORY

.fin:
    pop es
    pop ds
    popad

    ret


; 0x70号时钟更新结束中断,
;    目前用于发起任务切换。

int70:

    pushfd
    pushad
    push ds

    mov al, 0x20                                 ; 发送EOI
    out 0xa0, al                                 ; 向从片发送
    out 0x20, al                                 ; 向主片发送

    mov al, 0x8c                                 ; 必须访问一次寄存器C
    out 0x70, al                                 ; 否则该芯片不会再次产生此中断
    in al, 0x71
    mov al, 0x00
    out 0x70, al

    mov ax, LIB_SEL
    mov ds, ax                                   ; 震荡计数
    mov ebx, [ds:TREE_LIB_TICK_COUNT_OFS]        ; TODO:绕回。
    inc ebx
    mov [ds:TREE_LIB_TICK_COUNT_OFS], ebx
    mov eax, ebx
    xor edx, edx
    mov ecx, 0x400
    div ecx
    cmp edx, 0                                   ; 新的1s。
    jz .update

.switch:
; b 0x533ce6
    call near SwitchTask

    pop ds
    popad
    popfd

    iretd

.update:
    mov eax, [ds:TREE_LIB_TIME_STAMP_OFS]        ;1s计数。
    inc eax
    mov [ds:TREE_LIB_TIME_STAMP_OFS], eax
                                                 ; 更新时间
                                                 ; TODO: 更新日期
    mov dl, [ds:(0 + TREE_LIB_NOWTIME_OFS)]
    mov cl, [ds:(1 + TREE_LIB_NOWTIME_OFS)]
    mov al, [ds:(2 + TREE_LIB_NOWTIME_OFS)]

    inc al
    daa                                          ; bcd调整
    cmp al, 0x60
    jnz .j
    mov al, cl
    inc al
    daa
    mov cl, al
    xor al, al
    cmp cl, 0x60
    jnz .j
    xor cl, cl
    push ax
    mov al, dl
    inc al
    daa
    mov dl, al
    pop ax
    cmp dl, 0x24
    jnz .j
    xor dl, dl
                                                 ; 写回
.j:
    mov [ds:(0 + TREE_LIB_NOWTIME_OFS)], dl
    mov [ds:(1 + TREE_LIB_NOWTIME_OFS)], cl
    mov [ds:(2 + TREE_LIB_NOWTIME_OFS)], al

    jmp near .switch

TaskFoo:
    retf

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'task0'
TREE_VER 0

___TREE_DATA_END_