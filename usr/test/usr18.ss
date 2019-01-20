; tree/usr/usr18.ss
; Author: hyan23
; Date: 2016.08.02
;

; 测试rand.bin


%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0
    __TREE_LIB @1, 'rand', 0
    __TREE_LIB @2, 'task', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @444, 'puts', puts
    __TREE_IMPORT @445, 'putn', putn
    __TREE_IMPORT @0, 'srand', srand
    __TREE_IMPORT @1, 'rand', rand
    __TREE_IMPORT @2, 'GetTickCount', GetTickCount

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    TREE_CALL GetTickCount
    TREE_CALL srand

    xor ebx, ebx
    mov ecx, 10
.s0:
    push ebx
    TREE_CALL rand
    TREE_CALL putn
    TREE_SLEEP 1000
    mov ebx, TEXT
    TREE_CALL puts
    pop ebx
    inc ebx
    cmp ebx, ecx
    jnb .bk4
    jmp near .s0
.bk4:

    TREE_EXIT

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr18'
TREE_VER 0
TREE_STRING TEXT, '\n'

___TREE_DATA_END_