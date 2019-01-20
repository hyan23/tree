; tree/src/nasm/utility/stack.ss
; Author: hyan23
; Date: 2016.08.01
;

; utility/stack
; 公共例程文件
; TODO: 空间回收, 缩小

%include "../inc/nasm/tree.ic"
%include "../src/nasm/utility/stack.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'agent', 0
    __TREE_LIB @1, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'StackCreate', StackCreate
    __TREE_EXPORT @1, 'StackDestroy', StackDestroy
    __TREE_EXPORT @2, 'StackGetCount', StackGetCount
    __TREE_EXPORT @3, 'StackEmpty', StackEmpty
    __TREE_EXPORT @4, 'StackClear', StackClear
    __TREE_EXPORT @5, 'StackPushBack', StackPushBack
    __TREE_EXPORT @6, 'StackGetBack', StackGetBack
    __TREE_EXPORT @9, 'StackPopBack', StackPopBack

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'alloc_memory0', alloc_memory0
    __TREE_IMPORT @1, 'free_memory', free_memory
    __TREE_IMPORT @2, 'ZeroMemory', ZeroMemory
    __TREE_IMPORT @3, 'memcpy', memcpy
    __TREE_IMPORT @44, 'putn', putn

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax


; uint16:ax:stack StackCreate(void);

StackCreate:

    push ecx
    push edx
    push ds

    mov ecx, TREE_STACK_CONTEXT_BYTES            ; context
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow

    mov ds, ax                                   ; dat
    mov eax, TREE_STACK_DEFAULT_CAPACITY
    mov ecx, 4
    mul ecx
    mov ecx, eax
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow0

    mov [ds:TREE_STACK_CONTEXT_SEL_OFS], ax
    mov DWORD [ds:TREE_STACK_CONTEXT_INDEX_OFS], 0
    mov DWORD [ds:TREE_STACK_CONTEXT_CAPACITY_OFS], \
                    TREE_STACK_DEFAULT_CAPACITY

    mov ax, ds
.fin:
    pop ds
    pop edx
    pop ecx

    retf

.overflow:
    mov ax, NUL_SEL
    jmp near .fin

.overflow0:
    TREE_CALL free_memory
    mov ax, NUL_SEL
    jmp near .fin


; void StackDestroy(ds:stack);

StackDestroy:

    push ax

    push ds
    mov ax, [ds:TREE_STACK_CONTEXT_SEL_OFS]
    mov ds, ax
    TREE_CALL free_memory
    pop ds
    mov DWORD [ds:TREE_STACK_CONTEXT_INDEX_OFS], 0
    mov DWORD [ds:TREE_STACK_CONTEXT_CAPACITY_OFS], 0
    TREE_CALL free_memory

    pop ax

    retf


; uint32:eax StackGetCount(ds:stack);

StackGetCount:

    mov eax, [ds:TREE_STACK_CONTEXT_INDEX_OFS]
    retf


; bool:eax StackEmpty(ds:stack);

StackEmpty:

    cmp DWORD [ds:TREE_STACK_CONTEXT_INDEX_OFS], 0
    jz .empty
.not:
    mov eax, TREE_LOGICAL_FALSE

.fin:
    retf

.empty:
    mov eax, TREE_LOGICAL_TRUE
    jmp near .fin


; void StackClear(ds:stack);

StackClear:

    mov DWORD [ds:TREE_STACK_CONTEXT_INDEX_OFS], 0

    retf



; bool:eax StackPushBack(ds:stack, uint32:eax:_E);

StackPushBack:

    push ebx
    push ecx
    push edx
    push ds

    push eax                                     ; check range
    mov eax, [ds:TREE_STACK_CONTEXT_INDEX_OFS]
    mov ecx, [ds:TREE_STACK_CONTEXT_CAPACITY_OFS]
    cmp eax, ecx
    jb .ok                                       ; increase
    call near STACK_INCREASE
    test eax, TREE_LOGICAL_TRUE
    jz .failed

.ok:
    mov eax, [ds:TREE_STACK_CONTEXT_INDEX_OFS]   ; index in bytes
    mov ecx, 4
    mul ecx
    mov ebx, eax

    mov eax, [ds:TREE_STACK_CONTEXT_INDEX_OFS]   ; index ++
    inc eax
    mov [ds:TREE_STACK_CONTEXT_INDEX_OFS], eax

    mov ax, [ds:TREE_STACK_CONTEXT_SEL_OFS]      ; save
    mov ds, ax
    pop eax
    mov [ds:ebx], eax

    mov eax, TREE_LOGICAL_TRUE
.fin:
    pop ds
    pop edx
    pop ecx
    pop ebx

    retf

.failed:
    pop eax
    mov eax, TREE_LOGICAL_FALSE
    jmp near .fin


; uint32:eax StackGetBack(ds:stack);

StackGetBack:

    push ebx
    push ecx
    push edx
    push ds

    mov eax, [ds:TREE_STACK_CONTEXT_INDEX_OFS]   ; empty
    cmp eax, 0
    jna .fin

    dec eax                                      ; index
    mov ecx, 4
    mul ecx
    mov ebx, eax
    mov ax, [ds:TREE_STACK_CONTEXT_SEL_OFS]
    mov ds, ax
    mov eax, [ds:ebx]

.fin:
    pop ds
    pop edx
    pop ecx
    pop ebx

    retf


; void StackPopBack(ds:stack);

StackPopBack:

    push eax

    mov eax, [ds:TREE_STACK_CONTEXT_INDEX_OFS]
    cmp eax, 0
    jna .fin

    dec eax
    mov [ds:TREE_STACK_CONTEXT_INDEX_OFS], eax   ; wr-back

.fin:
    pop eax

    retf


; bool:eax STACK_INCREASE(ds:stack);

STACK_INCREASE:

    push ecx
    push edx
    push esi
    push edi
    push ds
    push es

    mov ecx, [ds:TREE_STACK_CONTEXT_CAPACITY_OFS] ; +=increment
    mov eax, 4
    mul ecx
    add eax, 4 * TREE_STACK_DEFAULT_INCREMENT
    mov ecx, eax

    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow
    mov es, ax

    push ecx                                     ; wr-back1
    mov ecx, [ds:TREE_STACK_CONTEXT_CAPACITY_OFS]
    add ecx, TREE_STACK_DEFAULT_INCREMENT
    mov [ds:TREE_STACK_CONTEXT_CAPACITY_OFS], ecx
    pop ecx

    mov ax, [ds:TREE_STACK_CONTEXT_SEL_OFS]      ; wr-back2
    mov [ds:TREE_STACK_CONTEXT_SEL_OFS], es
    mov ds, ax

    sub ecx, 4 * TREE_STACK_DEFAULT_INCREMENT
    xor esi, esi
    xor edi, edi
    TREE_CALL memcpy                             ; copy
    TREE_CALL free_memory                        ; free-old

    mov eax, TREE_LOGICAL_TRUE
.fin:
    pop es
    pop ds
    pop edi
    pop esi
    pop edx
    pop ecx

    ret

.overflow:
    mov eax, TREE_LOGICAL_FALSE
    jmp near .fin


___TREE_CODE_END_

___TREE_DATA_BEGIN_

TREE_NAME 'stack'
TREE_VER 0

___TREE_DATA_END_