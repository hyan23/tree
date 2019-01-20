; tree/usr/usr15.ss
; Author: hyan23
; Date: 2016.08.01
;

; 测试stack.bin


%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0
    __TREE_LIB @1, 'stack', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @444, 'puts', puts
    __TREE_IMPORT @445, 'putn', putn
    __TREE_IMPORT @0, 'StackCreate', StackCreate
    __TREE_IMPORT @1, 'StackDestroy', StackDestroy
    __TREE_IMPORT @2, 'StackGetCount', StackGetCount
    __TREE_IMPORT @3, 'StackEmpty', StackEmpty
    __TREE_IMPORT @4, 'StackClear', StackClear
    __TREE_IMPORT @5, 'StackPushBack', StackPushBack
    __TREE_IMPORT @10, 'StackGetBack', StackGetBack
    __TREE_IMPORT @9, 'StackPopBack', StackPopBack


___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    TREE_CALL StackCreate
    cmp ax, NUL_SEL
    jz .failed

    mov ds, ax
    xor eax, eax
    mov ecx, 140
.s0:
    push eax
    TREE_CALL StackPushBack
    pop eax
    ;TREE_CALL putn
    inc eax
    cmp eax, ecx
    jnb .bk4
    jmp near .s0
.bk4:
.s1:
    TREE_CALL StackGetBack
    TREE_CALL StackPopBack
    TREE_CALL putn
    TREE_CALL StackEmpty
    test eax, TREE_LOGICAL_TRUE
    jz .s1

    TREE_CALL StackGetCount
    TREE_CALL putn
    TREE_CALL StackDestroy
.failed:
    TREE_LOCATE_DATA
    mov ebx, TEXT
    TREE_CALL puts

    TREE_EXIT

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr15'
TREE_VER 0

TREE_STRING TEXT, 'hello world!\n'
TREE_STRING TEXT0, 'StackCreate(), failed.\n'

___TREE_DATA_END_