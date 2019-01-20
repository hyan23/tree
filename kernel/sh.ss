; tree/kernel/sh.ss
; Author: hyan23
; Date: 2016.05.29
;

; [TREE] sh

%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/def0.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0
    __TREE_LIB @1, 'task', 0
    __TREE_LIB @2, 'string', 0
    __TREE_LIB @3, 'agent', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

%include "../inc/nasm/io/conio.ic"
    __TREE_IMPORT @10, 'strequ', strequ
    __TREE_IMPORT @11, 'strequ0', strequ0
    __TREE_IMPORT @12, 'CreateProcess', CreateProcess
    __TREE_IMPORT @13, 'ZeroMemory', ZeroMemory
    __TREE_IMPORT @14, 'GetTickCount', GetTickCount
    __TREE_IMPORT @15, 'GetTaskPid', GetTaskPID

___TREE_IPT_TAB_END_

; constant
    SHELL_COM_LEN        EQU            16
    SHELL_COM_NUM        EQU            1
    SHELL_PRO_NUM        EQU            8
    SHELL_BUF_LEN        EQU            128


___TREE_CODE_BEGIN_

TREE_START:
    mov ax, ds
    mov es, ax

    ;TREE_CALL GetTickCount
    ;TREE_CALL putn
    ;TREE_CALL GetTaskPID
    ;TREE_CALL putn
    ;mov ecx, 0xffffff
    ;loop $
    ;TREE_CALL GetTickCount
    ;TREE_CALL putn

    mov ebx, GREETINGS                           ; 打印问候语
    TREE_CALL puts0

.s0:                                             ; 主循环
    mov ebx, PROMPT                              ; 打印命令提示符
    TREE_CALL puts

    mov ebx, szbuf
    mov ecx, SHELL_BUF_LEN

    TREE_CALL ZeroMemory                         ; 先清空缓冲区
    TREE_CALL gets                               ; 接受输入

    cmp BYTE [ds:ebx], PCHAR_EOS                 ; 空
    jz .s0

    mov esi, szbuf
    mov edi, SH_COMMANDS                         ; 内建命令
    TREE_CALL strequ0
    test eax, TREE_LOGICAL_TRUE
    jnz .fin
                                                 ; 扩展的
    xor ebx, ebx                                 ; 命令表索引
    mov ecx, SHELL_PRO_NUM
    mov edi, SH_PROGRAMS
.s1:                                             ; 查找命令
    TREE_CALL strequ0
    test eax, TREE_LOGICAL_TRUE
    jnz .ok

    inc ebx
    add edi, SHELL_COM_LEN                       ; 下一条
    loop .s1

    mov ebx, PROMPT                              ; 失败, 打印bad com
    TREE_CALL puts
    mov ebx, BADCOM
    TREE_CALL puts0

    jmp near .s0

.ok:
    mov eax, 4                                   ; startupinf表偏移
    mul ebx
    mov ebx, eax
    add ebx, SH_STARTUPINF
    mov eax, [ds:ebx]                            ; sector
    mov cx, 1
    TREE_CALL CreateProcess                      ; 执行应用程序
    test eax, TREE_LOGICAL_TRUE
    jz .failed                                   ; 挂起
    TREE_PCI0CALL TREE_PCI0_SEL_INSTRUCTION_HUNG
    jmp near .next

.failed:
    mov ax, 0xffff
    TREE_CALL putn
    mov cl, ASCLL_LF
    TREE_CALL putchar
    mov cl, ASCLL_CR
    TREE_CALL putchar

.next:
    jmp near .s0

.fin:
    TREE_EXIT

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'tree-sh'
TREE_VER 0

TREE_STRING GREETINGS, '---Welcome to tree v1.1---\n\
Is 32-bit multi-tasking Operating System\n\n\
For a short introduction for new users type: INTRO\n\
For supported shell commands type: HELP\n\n\
HAVE FUN!\n\n\
Author: hyan23\n\
My Email: hyan23lee@gmail.com\n'

TREE_STRING PROMPT, 'tree/usr0>>'

TREE_STRING BADCOM, 'bad command'

; supported commands
SH_COMMANDS:

TREE_STRING0 COM_EXIT, 'exit', SHELL_COM_LEN

SH_PROGRAMS:
TREE_STRING0 COM_CALC, 'calc', SHELL_COM_LEN
TREE_STRING0 COM_CLEAR, 'clear', SHELL_COM_LEN
TREE_STRING0 COM_HELP, 'help', SHELL_COM_LEN
TREE_STRING0 COM_NOWTIME, 'nowtime', SHELL_COM_LEN
TREE_STRING0 COM_SAYHELLO, 'sayhello', SHELL_COM_LEN
TREE_STRING0 COM_WHOAMI, 'whoami', SHELL_COM_LEN
TREE_STRING0 COM_SH, 'sh', SHELL_COM_LEN
TREE_STRING0 COM_DEBUG, 'debug', SHELL_COM_LEN

SH_STARTUPINF:
    sec_calc        DD      2010
    sec_clear       DD      2030
    sec_help        DD      2040
    sec_nowtime     DD      2050
    sec_sayhello    DD      2060
    sec_whoami      DD      2070
    sec_sh          DD      1111            ; 不再支持嵌套sh
    ;sec_sh         DD      1110
    sec_debug       DD      2020


TREE_SZBUF szbuf, SHELL_BUF_LEN

___TREE_DATA_END_