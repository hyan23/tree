; tree/usr/usr17.ss
; Author: hyan23
; Date: 2016.08.01
;

; 测试linked.bin


%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0
    __TREE_LIB @1, 'linked', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @444, 'puts', puts
    __TREE_IMPORT @445, 'putn', putn
    __TREE_IMPORT @0, 'LinkedCreate', LinkedCreate
    __TREE_IMPORT @1, 'LinkedDestroy', LinkedDestroy
    __TREE_IMPORT @2, 'LinkedAppend', LinkedAppend
    __TREE_IMPORT @3, 'LinkedRemove', LinkedRemove
    __TREE_IMPORT @4, 'LinkedGetCount', LinkedGetCount
    __TREE_IMPORT @5, 'LinkedGet', LinkedGet
    __TREE_IMPORT @6, 'LinkedSet', LinkedSet


___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    TREE_CALL LinkedCreate
    cmp ax, NUL_SEL
    jz .failed
    mov ds, ax

    TREE_CALL LinkedGetCount
    TREE_CALL putn

    mov eax, 0x01
    TREE_CALL LinkedAppend
    mov eax, 0x02
    TREE_CALL LinkedAppend
    mov eax, 0x03
    TREE_CALL LinkedAppend
    mov eax, 0x04
    TREE_CALL LinkedAppend
    mov eax, 0x05
    TREE_CALL LinkedAppend
    mov eax, 0x06
    TREE_CALL LinkedAppend
    mov eax, 0x07
    TREE_CALL LinkedAppend

    TREE_CALL LinkedGetCount
    TREE_CALL putn

    mov eax, 0x0a
    mov ecx, 2
    TREE_CALL LinkedSet

    mov eax, 3
    TREE_CALL LinkedRemove

    TREE_CALL LinkedGetCount
    TREE_CALL putn

    xor ecx, ecx
.s0:
    push eax
    TREE_CALL LinkedGet
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

TREE_NAME 'usr17'
TREE_VER 0

TREE_STRING TEXT, 'hello world!\n'
TREE_STRING TEXT0, 'LinkedCreate(), failed.\n'

___TREE_DATA_END_