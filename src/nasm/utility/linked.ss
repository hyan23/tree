; tree/src/nasm/utility/linked.ss
; Author: hyan23
; Date: 2016.08.01
;

; utility/linked
; 公共例程文件

%include "../inc/nasm/tree.ic"
%include "../src/nasm/utility/linked.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'agent', 0
    __TREE_LIB @1, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'LinkedCreate', LinkedCreate
    __TREE_EXPORT @1, 'LinkedDestroy', LinkedDestroy
    __TREE_EXPORT @2, 'LinkedAppend', LinkedAppend
    __TREE_EXPORT @3, 'LinkedRemove', LinkedRemove
    __TREE_EXPORT @4, 'LinkedGetCount', LinkedGetCount
    __TREE_EXPORT @5, 'LinkedGet', LinkedGet
    __TREE_EXPORT @6, 'LinkedSet', LinkedSet

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'alloc_memory0', alloc_memory0
    __TREE_IMPORT @1, 'free_memory', free_memory
    __TREE_IMPORT @2, 'putn', putn

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax


; 头节点缓存节点数量，最高位为锁
; uint16:ax:linked LinkedCreate(void);

LinkedCreate:

    call near NodeCreate
    retf


; uint16:ax:node NodeCreate(void);

NodeCreate:

    push ecx
    push ds

    mov ecx, TREE_LINKED_CONTEXT_BYTES
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow

    mov ds, ax
    mov DWORD [ds:TREE_LINKED_CONTEXT_DAT_OFS], 0
    mov WORD [ds:TREE_LINKED_CONTEXT_NEXT_OFS], NUL_SEL

.fin:
    pop ds
    pop ecx

    ret

.overflow:
    mov ax, NUL_SEL
    jmp near .fin


; void LinkedDestroy(ds:linked);

LinkedDestroy:

    push ax

.s0:
    mov DWORD [ds:TREE_LINKED_CONTEXT_DAT_OFS], 0
    mov ax, [ds:TREE_LINKED_CONTEXT_NEXT_OFS]
    mov WORD [ds:TREE_LINKED_CONTEXT_NEXT_OFS], 0
    TREE_CALL free_memory
    cmp ax, NUL_SEL
    jz .bk4
    mov ds, ax
    jmp near .s0

.bk4:
    pop ax

    retf


; bool:eax LinkedAppend(uint32:eax:dat);

LinkedAppend:

    push ds
    push es

    push eax
    call near NodeCreate
    cmp ax, NUL_SEL
    jz .overflow

    mov es, ax
    pop eax
    mov [es:TREE_LINKED_CONTEXT_DAT_OFS], eax

.s0:                                             ; find tail
    mov ax, [ds:TREE_LINKED_CONTEXT_NEXT_OFS]
    cmp ax, NUL_SEL
    jz .bk4
    mov ds, ax
    jmp near .s0
.bk4:

    mov [ds:TREE_LINKED_CONTEXT_NEXT_OFS], es

    mov ax, [ss:(4 + esp)]                       ; head
    mov ds, ax                                   ; count
    mov eax, [ds:TREE_LINKED_CONTEXT_DAT_OFS]
    inc eax
    mov [ds:TREE_LINKED_CONTEXT_DAT_OFS], eax

    mov eax, TREE_LOGICAL_TRUE
.fin:
    pop es
    pop ds

    retf

.overflow:
    pop eax
    mov eax, TREE_LOGICAL_FALSE
    jmp near .fin


; void LinkedRemove(uint32:eax:index);

LinkedRemove:

    pushad
    push ds

    mov ecx, [ds:TREE_LINKED_CONTEXT_DAT_OFS]
    cmp eax, ecx
    jnb .fin
    mov ecx, eax

    inc ecx                                      ; including head
    mov ax, ds
.s0:
    mov bx, ax                                   ; fore
    mov ax, [ds:TREE_LINKED_CONTEXT_NEXT_OFS]    ; current
    mov ds, ax
    loop .s0

    mov ax, [ds:TREE_LINKED_CONTEXT_NEXT_OFS]    ; nxt
    TREE_CALL free_memory
    mov ds, bx                                   ; fore.nxt=nxt
    mov [ds:TREE_LINKED_CONTEXT_NEXT_OFS], ax

    mov ax, [ss:esp]                             ; count
    mov ds, ax
    mov eax, [ds:TREE_LINKED_CONTEXT_DAT_OFS]
    dec eax
    mov [ds:TREE_LINKED_CONTEXT_DAT_OFS], eax

.fin:
    pop ds
    popad

    retf


; uint32:eax LinkedGetCount(ds:linked);

LinkedGetCount:

    mov eax, [ds:TREE_LINKED_CONTEXT_DAT_OFS]
    retf


; uint32:eax LinkedGet(ds:linked, uint32:ecx:index);

LinkedGet:

    push ecx
    push ds

    mov eax, [ds:TREE_LINKED_CONTEXT_DAT_OFS]
    cmp eax, ecx
    jna .fin

    inc ecx                                      ; index+1
.s0:
    mov ax, [ds:TREE_LINKED_CONTEXT_NEXT_OFS]    ; current
    mov ds, ax
    loop .s0

    mov eax, [ds:TREE_LINKED_CONTEXT_DAT_OFS]
.fin:
    pop ds
    pop ecx

    retf


; void LinkedSet(ds:linked, uint32:eax:_E,
;   uint32:ecx:index);

LinkedSet:

    push eax
    push ecx
    push ds

    mov eax, [ds:TREE_LINKED_CONTEXT_DAT_OFS]
    cmp eax, ecx
    jna .fin

    inc ecx                                      ; index+1
.s0:
    mov ax, [ds:TREE_LINKED_CONTEXT_NEXT_OFS]    ; current
    mov ds, ax
    loop .s0

    mov eax, [ss:(8 + esp)]
    mov [ds:TREE_LINKED_CONTEXT_DAT_OFS], eax

.fin:
    pop ds
    pop ecx
    pop eax

    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'linked'
TREE_VER 0

___TREE_DATA_END_