; tree/inc/nasm/sys/kbd.ss
; Author: hyan23
; Date: 2016.07.21
;

; kbd0代理

%include "../kernel/gate.ic"
%include "../kernel/cgcall.ic"
%include "../inc/nasm/tree.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'kbd0', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'get_char', get_char
    __TREE_EXPORT @1, 'get_char0', get_char0
    __TREE_EXPORT @2, 'qchar_clear', qchar_clear
    __TREE_EXPORT @3, 'qchar_empty', qchar_empty
    __TREE_EXPORT @4, 'capslocked', capslocked

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:

    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax


; char get_char(void);
; 从输入队列读取一个字符(包括控制字符)
; 阻塞

get_char:

.retry:
    TREE_CALLGATE_CALL __GET_CHAR
    cmp cl, 0
    jnz .fin                                     ; 停机等待
    TREE_PCI0CALL TREE_PCI0_SEL_INSTRUCTION_HLT
    jmp near .retry

.fin:
    retf


; 失败返回0
get_char0:
    TREE_CALLGATE_CALL __GET_CHAR
    retf


; void qchar_clear(void);
; 清空输入队列

qchar_clear:
    TREE_CALLGATE_CALL __QCHAR_CLEAR
    retf


; bool qchar_empty(void);
; 查询输入队列是否为空

qchar_empty:
    TREE_CALLGATE_CALL __QCHAR_EMPTY
    retf


; bool capslocked(void);
; 查询 capslock 状态

capslocked:
    TREE_CALLGATE_CALL __CAPSLOCKED
    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'kbd'
TREE_VER 0

TREE_CALLGATE_DATA __GET_CHAR
TREE_CALLGATE_DATA __QCHAR_CLEAR
TREE_CALLGATE_DATA __QCHAR_EMPTY
TREE_CALLGATE_DATA __CAPSLOCKED

___TREE_DATA_END_