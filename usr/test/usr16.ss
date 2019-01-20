; tree/usr/usr16.ss
; Author: hyan23
; Date: 2016.08.01
;

; 调试array.bin


%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0
    __TREE_LIB @1, 'array', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @444, 'puts', puts
    __TREE_IMPORT @445, 'putn', putn
    __TREE_IMPORT @0, 'ArrayCreate', ArrayCreate
    __TREE_IMPORT @1, 'ArrayDestroy', ArrayDestroy
    __TREE_IMPORT @2, 'ArrayGetCapacity', ArrayGetCapacity
    __TREE_IMPORT @3, 'ArrayResize', ArrayResize
    __TREE_IMPORT @4, 'ArrayGet', ArrayGet
    __TREE_IMPORT @5, 'ArraySet', ArraySet

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    mov eax, 10                                  ; 创建数组(容量10)
    TREE_CALL ArrayCreate
    cmp ax, NUL_SEL
    jz .failed
    mov ds, ax                                   ; 加载

    mov eax, 0xab                                ; 合法访问
    mov ecx, 1
    TREE_CALL ArraySet
    mov eax, 0xac
    mov ecx, 2
    TREE_CALL ArraySet
    mov eax, 0xad
    mov ecx, 5
    TREE_CALL ArraySet

    mov eax, 0xae                                ; 非法访问
    mov ecx, 10
    TREE_CALL ArraySet
    mov eax, 0xaf
    mov ecx, 7
    TREE_CALL ArraySet

    mov eax, 20                                  ; 扩容
    TREE_CALL ArrayResize
    mov eax, 0xff
    mov ecx, 14
    TREE_CALL ArraySet

    TREE_CALL ArrayGetCapacity                   ; 读超界
    TREE_CALL putn
    add eax, 5

    xor ecx, ecx
.s0:
    push eax
    TREE_CALL ArrayGet
    TREE_CALL putn
    pop eax
    inc ecx
    cmp ecx, eax
    jnb .bk4
    jmp near .s0

.bk4:
.failed:
    TREE_LOCATE_DATA
    mov ebx, TEXT
    TREE_CALL puts

    TREE_EXIT

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr16'
TREE_VER 0

TREE_STRING TEXT, 'hello world!\n'
TREE_STRING TEXT0, 'ArrayCreate(), failed.\n'

___TREE_DATA_END_