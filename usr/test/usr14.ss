; tree/usr/usr14.ss
; Author: hyan23
; Date: 2016.08.01
;

; 测试queue。bin


%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0
    __TREE_LIB @1, 'queue', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @444, 'puts', puts
    __TREE_IMPORT @445, 'putn', putn
    __TREE_IMPORT @0, 'QueueCreate', QueueCreate
    __TREE_IMPORT @1, 'QueueDestroy', QueueDestroy
    __TREE_IMPORT @2, 'QueueGetCount', QueueGetCount
    __TREE_IMPORT @3, 'QueueEmpty', QueueEmpty
    __TREE_IMPORT @4, 'QueueClear', QueueClear
    __TREE_IMPORT @5, 'QueuePushBack', QueuePushBack
    __TREE_IMPORT @6, 'QueueGetFront', QueueGetFront
    __TREE_IMPORT @7, 'QueuePopFront', QueuePopFront
    __TREE_IMPORT @8, 'QueueGetBack', QueueGetBack
    __TREE_IMPORT @9, 'QueuePopBack', QueuePopBack

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    TREE_CALL QueueCreate
    cmp ax, NUL_SEL
    jz .failed

    mov ds, ax
    xor eax, eax
    mov ecx, 140
.s0:
    TREE_CALL QueuePushBack
    TREE_CALL QueueGetFront
    TREE_CALL QueuePopFront
    TREE_CALL putn
    inc eax
    cmp eax, ecx
    jnb .bk4
    jmp near .s0
.bk4:
    TREE_CALL QueueGetCount
    TREE_CALL putn
    TREE_CALL QueueDestroy
.failed:
    TREE_LOCATE_DATA
    mov ebx, TEXT
    TREE_CALL puts

    TREE_EXIT

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr14'
TREE_VER 0

TREE_STRING TEXT, 'hello world!\n'
TREE_STRING TEXT0, 'QueueCreate(), failed.\n'

___TREE_DATA_END_