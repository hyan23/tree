; tree/usr/usr09.ss
; Author: hyan23
; Date: 2016.07.20
;

; 测试任务调度和时间，任务0

%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/def0.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @1, 'conio', 0
    __TREE_LIB @2, 'time', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @5, 'puts', puts
    __TREE_IMPORT @4, 'putchar', putchar
    __TREE_IMPORT @3, 'putn', putn
    __TREE_IMPORT @6, 'putbcd', putbcd
    __TREE_IMPORT @9, 'gettime', gettime
    __TREE_IMPORT @10, 'gettime_str', gettime_str
    __TREE_IMPORT @11, 'getdate_str', getdate_str

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
.s:
    mov ecx, 999
    TREE_PCI0CALL TREE_PCI0_SEL_INSTRUCTION_SLEEP
    call near show
    jmp near .s
    TREE_EXIT

show:
    mov cl, ASCLL_CR
    TREE_CALL putchar
    mov ebx, time
    TREE_CALL gettime_str
    TREE_CALL puts
    ret


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr09'
TREE_VER 0

TREE_SZBUF time, 9
TREE_STRING TEXT0, '\n'
TREE_STRING TEXT, 'usr program is runing.\n'

___TREE_DATA_END_