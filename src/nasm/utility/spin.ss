; tree/src/nasm/utility/spin.ss
; Author: hyan23
; Date: 2016.08.03
;

; 自旋锁的标准实现。


%include "../inc/nasm/tree.ic"
%include "../src/nasm/utility/spin.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'agent', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'SPINCreate', SPINCreate
    __TREE_EXPORT @1, 'SPINDestroy', SPINDestroy
    __TREE_EXPORT @2, 'SPINLock', SPINLock
    __TREE_EXPORT @3, 'SPINFree', SPINFree
    __TREE_EXPORT @4, 'SPINGetDat', SPINGetDat

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'alloc_memory0', alloc_memory0
    __TREE_IMPORT @1, 'free_memory', free_memory

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax


; uint16:ax SPINCreate(uint32:eax:dat);

SPINCreate:

    push ecx
    push ds

    push eax
    mov ecx, TREE_SPIN_CONTEXT_BYTES
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow
    mov ds, ax

    pop eax
    mov [ds:TREE_SPIN_CONTEXT_DAT_OFS], eax
    mov BYTE [ds:TREE_SPIN_CONTEXT_LOCK_OFS], TREE_LOGICAL_FALSE

    mov ax, ds
.fin:
    pop ds
    pop ecx

    retf

.overflow:
    pop eax
    mov ax, NUL_SEL
    jmp near .fin


; void SPINDestroy(ds:spin);

SPINDestroy:

    mov DWORD [ds:TREE_SPIN_CONTEXT_DAT_OFS], 0
    mov BYTE [ds:TREE_SPIN_CONTEXT_LOCK_OFS], 0
    TREE_CALL free_memory

    retf


; void SPINLock(ds:spin);

SPINLock:

.wt:
    test BYTE [ds:TREE_SPIN_CONTEXT_LOCK_OFS], TREE_LOGICAL_TRUE
    ; TREE_SLEEP 10
    jnz .wt
    mov BYTE [ds:TREE_SPIN_CONTEXT_LOCK_OFS], TREE_LOGICAL_TRUE

    retf


; void SPINFree(ds:spin);

SPINFree:

    mov BYTE [ds:TREE_SPIN_CONTEXT_LOCK_OFS], TREE_LOGICAL_FALSE

    retf


; uint32:eax SPINGetDat(ds:spin);

SPINGetDat:

    mov eax, [ds:TREE_SPIN_CONTEXT_DAT_OFS]

    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'spin'
TREE_VER 0


___TREE_DATA_END_