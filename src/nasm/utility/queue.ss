; tree/src/nasm/utility/queue.ss
; Author: hyan23
; Date: 2016.07.23
;

; utility/queue
; 公共例程文件
; TODO: 空间回收, 缩小。

%include "../inc/nasm/tree.ic"
%include "../src/nasm/utility/queue.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'agent', 0
    __TREE_LIB @1, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'QueueCreate', QueueCreate
    __TREE_EXPORT @1, 'QueueDestroy', QueueDestroy
    __TREE_EXPORT @2, 'QueueGetCount', QueueGetCount
    __TREE_EXPORT @3, 'QueueEmpty', QueueEmpty
    __TREE_EXPORT @4, 'QueueClear', QueueClear
    __TREE_EXPORT @5, 'QueuePushBack', QueuePushBack
    __TREE_EXPORT @6, 'QueueGet', QueueGet
    __TREE_EXPORT @7, 'QueueGetFront', QueueGetFront
    __TREE_EXPORT @8, 'QueuePopFront', QueuePopFront
    __TREE_EXPORT @9, 'QueueGetBack', QueueGetBack
    __TREE_EXPORT @10, 'QueuePopBack', QueuePopBack

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


; uint16:ax:queue QueueCreate(void);

QueueCreate:

    push ecx
    push edx
    push ds

    mov ecx, TREE_QUEUE_CONTEXT_BYTES            ; context
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow

    mov ds, ax                                   ; dat
    mov eax, TREE_QUEUE_DEFAULT_CAPACITY
    mov ecx, 4
    mul ecx
    mov ecx, eax
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow0

    mov [ds:TREE_QUEUE_CONTEXT_SEL_OFS], ax
    mov DWORD [ds:TREE_QUEUE_CONTEXT_INDEX_OFS], 0
    mov DWORD [ds:TREE_QUEUE_CONTEXT_CAPACITY_OFS], \
                    TREE_QUEUE_DEFAULT_CAPACITY

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


; void QueueDestroy(ds:queue);

QueueDestroy:

    push ax

    push ds
    mov ax, [ds:TREE_QUEUE_CONTEXT_SEL_OFS]
    mov ds, ax
    TREE_CALL free_memory
    pop ds
    mov DWORD [ds:TREE_QUEUE_CONTEXT_INDEX_OFS], 0
    mov DWORD [ds:TREE_QUEUE_CONTEXT_CAPACITY_OFS], 0
    TREE_CALL free_memory

    pop ax

    retf


; uint32:eax QueueGetCount(ds:queue);

QueueGetCount:

    mov eax, [ds:TREE_QUEUE_CONTEXT_INDEX_OFS]
    retf


; bool:eax QueueEmpty(ds:queue);

QueueEmpty:

    cmp DWORD [ds:TREE_QUEUE_CONTEXT_INDEX_OFS], 0
    jz .empty
.not:
    mov eax, TREE_LOGICAL_FALSE

.fin:
    retf

.empty:
    mov eax, TREE_LOGICAL_TRUE
    jmp near .fin



; void QueueClear(ds:queue);

QueueClear:

    mov DWORD [ds:TREE_QUEUE_CONTEXT_INDEX_OFS], 0

    retf



; bool:eax QueuePushBack(ds:queue, uint32:eax:_E);

QueuePushBack:

    push ebx
    push ecx
    push edx
    push ds

    push eax                                     ; check range
    mov eax, [ds:TREE_QUEUE_CONTEXT_INDEX_OFS]
    mov ecx, [ds:TREE_QUEUE_CONTEXT_CAPACITY_OFS]
    cmp eax, ecx
    jb .ok                                       ; increase
    call near QUEUE_INCREASE
    test eax, TREE_LOGICAL_TRUE
    jz .failed

.ok:
    mov eax, [ds:TREE_QUEUE_CONTEXT_INDEX_OFS]   ; index in bytes
    mov ecx, 4
    mul ecx
    mov ebx, eax

    mov eax, [ds:TREE_QUEUE_CONTEXT_INDEX_OFS]   ; index ++
    inc eax
    mov [ds:TREE_QUEUE_CONTEXT_INDEX_OFS], eax

    mov ax, [ds:TREE_QUEUE_CONTEXT_SEL_OFS]      ; save
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


; uint32:eax QueueGet(ds:queue, uint32:ecx:index);

QueueGet:

    push ebx
    push edx
    push ds

    cmp ecx, [ds:TREE_QUEUE_CONTEXT_INDEX_OFS]
    jnb .fin
    mov eax, 4
    mul ecx

    mov ebx, eax
    mov ax, [ds:TREE_QUEUE_CONTEXT_SEL_OFS]
    mov ds, ax
    mov eax, [ds:ebx]

.fin:
    pop ds
    pop edx
    pop ebx

    retf


; uint32:eax QueueGetFront(ds:queue);

QueueGetFront:

    push ds

    mov ax, [ds:TREE_QUEUE_CONTEXT_SEL_OFS]
    mov ds, ax
    mov eax, [ds:0]

    pop ds

    retf


; void QueuePopFront(ds:queue);

QueuePopFront:

    pushad
    push ds

    mov ecx, [ds:TREE_QUEUE_CONTEXT_INDEX_OFS]   ; 移动次数
    cmp ecx, 0
    jna .bk4
                                                 ; 写回。
    dec ecx                                      ; 同样是是操作完毕后
    mov [ds:TREE_QUEUE_CONTEXT_INDEX_OFS], ecx   ; 元素个数, 与下一索引。

    mov ax, [ds:TREE_QUEUE_CONTEXT_SEL_OFS]
    mov ds, ax

    mov esi, 4
    xor edi, edi
    xor ebx, ebx                                 ; counter
.s0:
    mov eax, [ds:esi]
    mov [ds:edi], eax
    add esi, 4
    add edi, 4

    inc ebx
    cmp ebx, ecx
    jnb .bk4

    jmp near .s0
.bk4:

    pop ds
    popad

    retf


; uint32:eax QueueGetBack(ds:queue);

QueueGetBack:

    push ebx
    push ecx
    push edx
    push ds

    mov eax, [ds:TREE_QUEUE_CONTEXT_INDEX_OFS]
    cmp eax, 0
    jna .fin

    dec eax
    mov ecx, 4
    mul ecx
    mov ebx, eax
    mov ax, [ds:TREE_QUEUE_CONTEXT_SEL_OFS]
    mov ds, ax
    mov eax, [ds:ebx]

.fin:
    pop ds
    pop edx
    pop ecx
    pop ebx

    retf


; void QueuePopBack(ds:queue);

QueuePopBack:

    push eax

    mov eax, [ds:TREE_QUEUE_CONTEXT_INDEX_OFS]
    cmp eax, 0
    jna .fin
    dec eax
    mov [ds:TREE_QUEUE_CONTEXT_INDEX_OFS], eax

.fin:
    pop eax

    retf


; bool:eax QUEUE_INCREASE(ds:stack);

QUEUE_INCREASE:

    push ecx
    push edx
    push esi
    push edi
    push ds
    push es

    mov ecx, [ds:TREE_QUEUE_CONTEXT_CAPACITY_OFS] ; +=increment
    mov eax, 4
    mul ecx
    add eax, 4 * TREE_QUEUE_DEFAULT_INCREMENT
    mov ecx, eax

    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow
    mov es, ax

    push ecx                                     ; wr-back1
    mov ecx, [ds:TREE_QUEUE_CONTEXT_CAPACITY_OFS]
    add ecx, TREE_QUEUE_DEFAULT_INCREMENT
    mov [ds:TREE_QUEUE_CONTEXT_CAPACITY_OFS], ecx
    pop ecx

    mov ax, [ds:TREE_QUEUE_CONTEXT_SEL_OFS]      ; wr-back2
    mov [ds:TREE_QUEUE_CONTEXT_SEL_OFS], es
    mov ds, ax

    sub ecx, 4 * TREE_QUEUE_DEFAULT_INCREMENT
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

TREE_NAME 'queue'
TREE_VER 0

___TREE_DATA_END_