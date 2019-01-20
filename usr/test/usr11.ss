; tree/usr/usr11.ss
; Author: hyan23
; Date: 2016.07.20
;

; 测试任务调度，任务1

%include "../boot/gdt.ic"
%include "../kernel/gate.ic"
%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'putchar', putchar
    __TREE_IMPORT @3, 'puts', puts

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    mov ebx, TEXT
    mov ecx, 0x100
.s0:
    TREE_CALL puts
    loop .s0

    mov ebx, SLEEP
    TREE_CALL puts
    mov ecx, 5000
    TREE_PCI0CALL TREE_PCI0_SEL_INSTRUCTION_SLEEP

    mov ebx, TEXT
    mov ecx, 0x100
.s:
    TREE_CALL puts
    loop .s

    mov ebx, FIN
    TREE_CALL puts

    TREE_EXIT

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr11'
TREE_VER 0

TREE_STRING TEXT, 'task is running...\n'
TREE_STRING SLEEP, 'sleeping for 5s ...\n'
TREE_STRING FIN, 'task terminated.\n'

___TREE_DATA_END_