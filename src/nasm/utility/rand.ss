; tree/inc/nasm/utility/rand.ss
; Author: hyan23
; Date: 2016.08.02
;

; [TREE]随机数发生器

%include "../inc/nasm/tree.ic"


___TREE_IPT_LIB_BEGIN_

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'srand', srand
    __TREE_EXPORT @1, 'rand', rand

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

___TREE_IPT_TAB_END_

___TREE_CODE_BEGIN_

TREE_START:
    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax



; void srand(uint32:eax:seed);

srand:

    push ds

    TREE_LOCATE_DATA
    add [ds:seed], eax ;;;;;;;;;

    pop ds

    retf


; uint32:eax rand(void);

rand:

    push ecx
    push edx
    push ds

    TREE_LOCATE_DATA
    mov eax, [ds:seed]
    mov ecx, 0xabcdef23
    mul ecx
    mov [ds:seed], eax
    mov eax, edx

    pop ds
    pop edx
    pop ecx

    retf


___TREE_CODE_END_

___TREE_DATA_BEGIN_

TREE_NAME 'rand'
TREE_VER 0

seed DD 0xffffffff


___TREE_DATA_END_