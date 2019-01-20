; tree/usr/usr04.ss
; Author: hyan23
; Date: 2016.05.29
;

; 测试 util/string::strequ

%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'conio', 0
    __TREE_LIB @2, 'string', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_
___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @4, 'puts0', puts0
    __TREE_IMPORT @10, 'strequ', strequ
    __TREE_IMPORT @11, 'strequ0', strequ0

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    TREE_LOCATE_DATA

.s0:
    mov esi, sz01
    mov edi, sz02
    TREE_CALL strequ0
    test eax, TREE_LOGICAL_TRUE
    jz .notequ

    mov ebx, szff
    jmp near .showres

.notequ:
    mov ebx, sz00

.showres:
    TREE_CALL puts0

    xor eax, eax
    TREE_EXIT TREE_EXEC_RET_COM, eax

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'usr04'
TREE_VER 0

TREE_STRING sz01, 'a123bcdedg'
TREE_STRING sz02, 'a124bcdedG'
TREE_STRING szff, 'the strings are equ!'
TREE_STRING sz00, 'the strings are not equ.'


___TREE_DATA_END_