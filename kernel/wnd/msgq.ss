; tree/kernel/wnd/msgq.ss
; Author: hyan23
; Date: 2016.08.03
;

; 消息队列同步

%include "../inc/nasm/tree.ic"
%include "../kernel/wnd/msgq.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'agent', 0
    __TREE_LIB @1, 'conio', 0
    __TREE_LIB @2, 'queue', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'MQCreate', MQCreate
    __TREE_EXPORT @1, 'MQDestroy', MQDestroy
    __TREE_EXPORT @2, 'MQLock', MQLock
    __TREE_EXPORT @3, 'MQFree', MQFree
    __TREE_EXPORT @4, 'MQGetQ', MQGetQ

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'alloc_memory0', alloc_memory0
    __TREE_IMPORT @1, 'free_memory', free_memory
    __TREE_IMPORT @2, 'putn', putn

    __TREE_IMPORT @3, 'QueueCreate', QueueCreate
    __TREE_IMPORT @4, 'QueueDestroy', QueueDestroy


___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    TREE_HUNG


; uint16:ax MQCreate(void);

MQCreate:

    push ecx
    push ds

    mov ecx, TREE_MSGQ_CONTEXT_BYTES
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow
    mov ds, ax

    TREE_CALL QueueCreate
    cmp ax, NUL_SEL
    jz .overflow0

    mov [ds:TREE_MSGQ_CONTEXT_MSGQ_OFS], ax
    mov BYTE [ds:TREE_MSGQ_CONTEXT_LOCK_OFS], TREE_LOGICAL_FALSE

    mov ax, ds
.fin:
    pop ds
    pop ecx

    retf

.overflow:
    mov ax, NUL_SEL
    jmp near .fin

.overflow0:
    TREE_CALL free_memory
    mov ax, NUL_SEL
    jmp near .fin


; void MQDestroy(ds:msgq);

MQDestroy:

    push ax

    push ds
    mov BYTE [ds:TREE_MSGQ_CONTEXT_LOCK_OFS], 0
    mov ax, [ds:TREE_MSGQ_CONTEXT_MSGQ_OFS]
    mov ds, ax
    TREE_CALL QueueDestroy
    pop ds
    TREE_CALL free_memory

    pop ax

    retf


; void MQLock(ds:msgq);

MQLock:

.wt:
    test BYTE [ds:TREE_MSGQ_CONTEXT_LOCK_OFS], TREE_LOGICAL_TRUE
                                                 ; TREE_SLEEP 10
    jnz .wt
    mov BYTE [ds:TREE_MSGQ_CONTEXT_LOCK_OFS], TREE_LOGICAL_TRUE

    retf


; void MQFree(ds:msgq);

MQFree:

    mov BYTE [ds:TREE_MSGQ_CONTEXT_LOCK_OFS], TREE_LOGICAL_FALSE

    retf


; uint16:ax MQGetQ(ds:msgq);

MQGetQ:

    mov ax, [ds:TREE_MSGQ_CONTEXT_MSGQ_OFS]

    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'msgq'
TREE_VER 0


___TREE_DATA_END_