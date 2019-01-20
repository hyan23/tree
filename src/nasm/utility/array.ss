; tree/src/nasm/utility/array.ss
; Author: hyan23
; Date: 2016.08.01
;

; utility/array
; 公共例程文件

%include "../inc/nasm/tree.ic"
%include "../src/nasm/utility/array.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'agent', 0
    __TREE_LIB @1, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'ArrayCreate', ArrayCreate
    __TREE_EXPORT @1, 'ArrayDestroy', ArrayDestroy
    __TREE_EXPORT @2, 'ArrayGetCapacity', ArrayGetCapacity
    __TREE_EXPORT @3, 'ArrayResize', ArrayResize
    __TREE_EXPORT @4, 'ArrayGet', ArrayGet
    __TREE_EXPORT @5, 'ArraySet', ArraySet

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


; uint16:ax:array ArrayCreate(uint32:eax:capacity);

ArrayCreate:

    push ecx
    push edx
    push ds

    push eax                                     ; context
    mov ecx, TREE_ARRAY_CONTEXT_BYTES
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow

    mov ds, ax
    pop eax
    mov DWORD [ds:TREE_ARRAY_CONTEXT_CAPACITY_OFS], eax ; capacity

    mov ecx, 4                                   ; dat
    mul ecx
    mov ecx, eax
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow0

    mov [ds:TREE_ARRAY_CONTEXT_SEL_OFS], ax

    mov ax, ds
.fin:
    pop ds
    pop edx
    pop ecx

    retf

.overflow:
    pop eax
    mov ax, NUL_SEL
    jmp near .fin

.overflow0:
    TREE_CALL free_memory
    mov ax, NUL_SEL
    jmp near .fin


; void ArrayDestroy(ds:array);

ArrayDestroy:

    push ax

    push ds
    mov ax, [ds:TREE_ARRAY_CONTEXT_SEL_OFS]
    mov ds, ax
    TREE_CALL free_memory
    pop ds
    mov DWORD [ds:TREE_ARRAY_CONTEXT_CAPACITY_OFS], 0
    TREE_CALL free_memory

    pop ax

    retf


; uint32:eax ArrayGetCapacity(ds:array);

ArrayGetCapacity:

    mov eax, [ds:TREE_ARRAY_CONTEXT_CAPACITY_OFS]
    retf


; bool:eax ArrayResize(ds:array, uint32:eax:size);

ArrayResize:

    push ecx
    push edx
    push esi
    push edi
    push ds
    push es
                                                 ; to-bytes
    push eax                                     ; new-size
    mov ecx, 4
    mul ecx
    push eax                                     ; new-bytes
    mov ecx, eax

    TREE_CALL alloc_memory0                      ; allocate
    cmp ax, NUL_SEL
    jz .overflow
    mov es, ax

    mov ecx, [ds:TREE_ARRAY_CONTEXT_CAPACITY_OFS] ; 0ld-size
    mov eax, [ss:(4 + esp)]                      ; wr-back1
    mov [ds:TREE_ARRAY_CONTEXT_CAPACITY_OFS], eax ; -new-size

    mov eax, 4                                   ; 0ld-bytes
    mul ecx

    pop ecx                                      ; new-bytes
    pop edx                                      ; not use

    cmp eax, ecx                                 ; keep minimum
    jb .j
    jmp near .j1
.j:
    mov ecx, eax
.j1:

    mov ax, [ds:TREE_ARRAY_CONTEXT_SEL_OFS]      ; wr-back2
    mov [ds:TREE_ARRAY_CONTEXT_SEL_OFS], es
    mov ds, ax

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

    retf

.overflow:
    pop eax
    pop eax

    mov eax, TREE_LOGICAL_FALSE
    jmp near .fin


; uint32:eax ArrayGet(ds:array, uint32:ecx:index);

ArrayGet:

    push ebx
    push ecx
    push edx
    push ds

    mov eax, [ds:TREE_ARRAY_CONTEXT_CAPACITY_OFS] ; check range
    cmp eax, ecx
    jna .fin

    mov eax, 4
    mul ecx
    mov ebx, eax

    mov ax, [ds:TREE_ARRAY_CONTEXT_SEL_OFS]
    mov ds, ax
    mov eax, [ds:ebx]

.fin:
    pop ds
    pop edx
    pop ecx
    pop ebx

    retf


; bool:eax ArraySet(ds:array, uint32:eax:_E,
;   uint32:ecx:index);

ArraySet:

    push ebx
    push ecx
    push edx
    push ds

    push eax                                     ; range
    mov eax, [ds:TREE_ARRAY_CONTEXT_CAPACITY_OFS]
    cmp eax, ecx
    jna .failed

    mov eax, 4
    mul ecx
    mov ebx, eax

    mov ax, [ds:TREE_ARRAY_CONTEXT_SEL_OFS]
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


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'array'
TREE_VER 0

___TREE_DATA_END_