; tree/kernel/task.ss
; Author: hyan23
; Date: 2016.07.22
;

; 用户程序任务管理

%include "../kernel/cgcall.ic"
%include "../kernel/gate.ic"
%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @1, 'CreateProcess', CreateProcess
    __TREE_EXPORT @0, 'GetTickCount', GetTickCount
    __TREE_EXPORT @2, 'GetTaskPid', GetTaskPid

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax


; 如要创建sh绑定任务
; 这里将验证sh有效性。
; in: eax: LBA, cx: sh-tcb

CreateProcess:

    push ebx

    cmp cx, NUL_SEL                              ; 为了方便期间, NUL_SEL!=cx即可认为
    jz .nt                                       ; 该任务是合法的sh绑定任务。
    mov bl, TREE_LOGICAL_TRUE
    jmp near .create
.nt:
    mov bl, TREE_LOGICAL_FALSE
.create:
    TREE_CALLGATE_CALL __CREATE_PROCESS

    pop ebx

    retf


GetTickCount:

    TREE_CALLGATE_CALL __GET_TICK_COUNT
    retf



GetTaskPid:

    TREE_CALLGATE_CALL __GET_TASK_PID
    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'task'
TREE_VER 0

TREE_CALLGATE_DATA __CREATE_PROCESS
TREE_CALLGATE_DATA __GET_TICK_COUNT
TREE_CALLGATE_DATA __GET_TASK_PID


___TREE_DATA_END_