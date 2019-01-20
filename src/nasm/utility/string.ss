; tree/inc/nasm/utility/string.ss
; Author: hyan23
; Date: 2016.05.26
;

%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'isabc', isabc
    __TREE_EXPORT @1, 'strlen', strlen
    __TREE_EXPORT @4, 'strcpy', strcpy
    __TREE_EXPORT @2, 'strequ', strequ
    __TREE_EXPORT @3, 'strequ0', strequ0
    __TREE_EXPORT @7, 'strcat', strcat
    __TREE_EXPORT @8, 'itos', itos

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

___TREE_IPT_TAB_END_

___TREE_CODE_BEGIN_

TREE_START:
    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax


; isabc
; in:cl:ch
; ret: TREE_LOGICAL_TRUE or TREE_LOGICAL_FALSE

isabc:

    call near isabc0                             ; 远调用
    retf


; isabc0
; in:cl:ch
; ret: TREE_LOGICAL_TRUE or TREE_LOGICAL_FALSE

isabc0:

    mov eax, TREE_LOGICAL_FALSE

    cmp cl, 'A'                                  ; 是大写字母吗?
    jb .fin
    cmp cl, 'Z'
    ja .j0

    mov eax, TREE_LOGICAL_TRUE

.j0:
    cmp cl, 'a'                                  ; 或者是小写?
    jb .fin
    cmp cl, 'z'
    ja .fin

    mov eax, TREE_LOGICAL_TRUE

.fin:
    ret


; strlen
; 计算字符串长度, 不包括 PCHAR_EOS
; in: ds:ebx:sz
; ret: eax: 计算结果

strlen:

    call near strlen0
    retf


strlen0:

    push ebx

    xor eax, eax                                 ; eax 计数

.s0:
    cmp byte [ds:ebx], PCHAR_EOS
    jz .fin
    inc eax
    inc ebx
    jmp near .s0

.fin:

    pop ebx
    ret


; void strcpy(es:edi:dst, ds:esi:src);

strcpy:

    call near strcpy0
    retf


strcpy0:

    push cx
    push esi
    push edi

.s:
    mov cl, [ds:esi]
    mov [es:edi], cl
    cmp cl, PCHAR_EOS
    jz .bk
    inc esi
    inc edi
    jmp near .s

.bk:
    pop edi
    pop esi
    pop cx

    ret


; strequ
; 比较两个字符串是否相等, 区分大小写
; in: ds:esi:src, ds:edi:dst
; ret: eax: TREE_LOGICAL_TRUE or TREE_LOGICAL_FALSE

strequ:

    push ecx
    push esi
    push edi

    mov eax, TREE_LOGICAL_FALSE

.s0:                                             ; 逐个字符比较
    mov cl, [ds:esi]
    mov ch, [ds:edi]

    cmp cl, ch
    jnz .fin

    cmp cl, PCHAR_EOS                            ; cl = ch = PCHAR_EOS
    jz .ok

    inc esi
    inc edi
    jmp near .s0

.ok:
    mov eax, TREE_LOGICAL_TRUE

.fin:
    pop edi
    pop esi
    pop ecx

    retf


; strequ0
; 比较两个字符串是否相等, 不区分大小写
; in: ds:esi:src, ds:edi:dst
; ret: eax: TREE_LOGICAL_TRUE or TREE_LOGICAL_FALSE

strequ0:

    push ecx
    push edx
    push esi
    push edi

    mov eax, TREE_LOGICAL_FALSE

.s0:
    mov dl, [ds:esi]
    mov dh, [ds:edi]

    mov cl, dl                                   ; 先判断是不是同为字母
    push eax
    call near isabc0                             ; 如果不是, 直接返回 false
    test eax, TREE_LOGICAL_TRUE
    pop eax
    jz .j0
    mov cl, dh
    push eax
    call near isabc0
    test eax, TREE_LOGICAL_TRUE
    pop eax
    jz .fin

.abc:
    and dl, 1101_1111b                           ; 字母, 转换为大写再比较
    and dh, 1101_1111b
    cmp dl, dh
    jnz .fin
    jmp near .next

.j0:                                             ; 非字母相减比较
    cmp dl, dh
    jnz .fin

    cmp cl, PCHAR_EOS                            ; 相等的条件很苛刻 ^^
    jz .ok

.next:
    inc esi
    inc edi
    jmp near .s0

.ok:
    mov eax, TREE_LOGICAL_TRUE

.fin:
    pop edi
    pop esi
    pop edx
    pop ecx

    retf


; void strcat(es:edi:dst, ds:esi:src);

strcat:

    pushad

    push ds
    mov ax, es
    mov ds, ax

    mov ebx, edi                                 ; edi+=strlen
    call near strlen0                            ; strcpy
    add edi, eax

    pop ds
    call near strcpy0

    popad

    retf


; void itos(uint32:eax:i, ds:ebx:buf);

itos:

    pushad

    mov BYTE [ds:ebx], '0'                       ; 0x
    inc ebx
    mov BYTE [ds:ebx], 'x'

    mov ecx, 8                                   ; 分解。
.s0:
    push eax
    and al, 00001111b
    cmp al, 9
    ja .hex
    add al, '0'
    jmp near .j
.hex:
    sub al, 0xa
    add al, 'a'

.j:
    add ebx, ecx
    mov [ds:ebx], al
    sub ebx, ecx

    pop eax
    shr eax, 4
    loop .s0

    mov BYTE [ds:(9 + ebx)], PCHAR_EOS

    popad

    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'string'
TREE_VER 0

___TREE_DATA_END_