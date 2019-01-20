; tree/kernel/wnd/link.ss
; Author: hyan23
; Date: 2016.08.03
;

; 窗口链同步

%include "../inc/nasm/tree.ic"
%include "../kernel/wnd/link.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'agent', 0
    __TREE_LIB @1, 'conio', 0
    __TREE_LIB @2, 'linked', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'WLCreate', WLCreate
    __TREE_EXPORT @1, 'WLDestroy', WLDestroy
    __TREE_EXPORT @2, 'WLLock', WLLock
    __TREE_EXPORT @3, 'WLFree', WLFree
    __TREE_EXPORT @4, 'WLGetL', WLGetL

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'alloc_memory0', alloc_memory0
    __TREE_IMPORT @1, 'free_memory', free_memory
    __TREE_IMPORT @2, 'putn', putn

    __TREE_IMPORT @3, 'LinkedCreate', LinkedCreate
    __TREE_IMPORT @4, 'LinkedDestroy', LinkedDestroy


___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    TREE_HUNG


; uint16:ax WLCreate(void);

WLCreate:

    push ecx
    push ds

    mov ecx, TREE_LINK_CONTEXT_BYTES
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow
    mov ds, ax

    TREE_CALL LinkedCreate
    cmp ax, NUL_SEL
    jz .overflow0

    mov [ds:TREE_LINK_CONTEXT_LINK_OFS], ax
    mov BYTE [ds:TREE_LINK_CONTEXT_LOCK_OFS], TREE_LOGICAL_FALSE

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


; void WLDestroy(ds:LINK);

WLDestroy:

    push ax

    push ds
    mov BYTE [ds:TREE_LINK_CONTEXT_LOCK_OFS], 0
    mov ax, [ds:TREE_LINK_CONTEXT_LINK_OFS]
    mov ds, ax
    TREE_CALL LinkedDestroy
    pop ds
    TREE_CALL free_memory

    pop ax

    retf


; void WLLock(ds:LINK);

WLLock:

.wt:
    test BYTE [ds:TREE_LINK_CONTEXT_LOCK_OFS], TREE_LOGICAL_TRUE
    ; TREE_SLEEP 10
    jnz .wt
    mov BYTE [ds:TREE_LINK_CONTEXT_LOCK_OFS], TREE_LOGICAL_TRUE

    nop
    nop

    retf


; void WLFree(ds:LINK);

WLFree:

    mov BYTE [ds:TREE_LINK_CONTEXT_LOCK_OFS], TREE_LOGICAL_FALSE

    retf


; uint16:ax WLGetL(ds:LINK);

WLGetL:

    mov ax, [ds:TREE_LINK_CONTEXT_LINK_OFS]

    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'link'
TREE_VER 0


___TREE_DATA_END_