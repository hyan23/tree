; tree/kernel/graphic/texture.ss
; Author: hyan23
; Date: 2016.07.28
;

; 小型图形库。

%include "../kernel/graphic/texture.ic"
%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/def0.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'agent', 0
    __TREE_LIB @1, 'conio', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @0, 'NewTexture', NewTexture
    __TREE_EXPORT @1, 'DestroyTexture', DestroyTexture
    __TREE_EXPORT @2, 'GetDrawable', GetDrawable
    __TREE_EXPORT @3, 'PrintTexture', PrintTexture
    __TREE_EXPORT @4, 'DrawPixel', DrawPixel
    __TREE_EXPORT @5, 'DrawLine', DrawLine
    __TREE_EXPORT @6, 'DrawRect', DrawRect
    __TREE_EXPORT @7, 'BlitTexture', BlitTexture

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'alloc_memory0', alloc_memory0
    __TREE_IMPORT @1, 'free_memory', free_memory
    __TREE_IMPORT @2, 'ZeroMemory', ZeroMemory
    __TREE_IMPORT @3, 'putn', putn

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax


; uint16:ax:structure
;    NewTexture(dx:ax:width:height:param);

NewTexture:
    call near NewTexture0
    retf


NewTexture0:

    push ebx
    push ecx
    push edx
    push ds

    and edx, 0x0000ffff
    and eax, 0x0000ffff
    cmp edx, 0
    jna .checkerror
    cmp eax, 0
    jna .checkerror
    push edx
    push eax

    mov ecx, TREE_TEXTURE_CONTEXT_BYTES
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow0
    mov ds, ax
    xor ebx, ebx
    TREE_CALL ZeroMemory

    pop eax                                      ; /4*4除绘制外按双字操作
    xor edx, edx
    mov ecx, 4
    div ecx
    mul ecx
    pop edx

    mov [ds:TREE_TEXTURE_WIDTH_OFS], dx
    mov [ds:TREE_TEXTURE_HEIGHT_OFS], ax

    mul edx                                      ; 计算空间
    mov ecx, eax

    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow1
    push ds
    mov ds, ax
    xor ebx, ebx
    TREE_CALL ZeroMemory
    pop ds

    mov [ds:TREE_TEXTURE_TEXTURE_OFS], ax

    mov ax, ds
.fin:
    pop ds
    pop edx
    pop ecx
    pop ebx

    ret

.checkerror:
    xor ax, ax
    jmp near .fin

.overflow0:
    pop eax
    pop eax
    xor ax, ax
    jmp near .fin

.overflow1:
    TREE_CALL free_memory
    xor ax, ax
    jmp near .fin


; void DestroyTexture(uint16*:ds:structure);

DestroyTexture:

    call near DestroyTexture0
    retf


DestroyTexture0:

    push eax

    mov WORD [ds:TREE_TEXTURE_WIDTH_OFS], 0
    mov WORD [ds:TREE_TEXTURE_HEIGHT_OFS], 0
    mov ax, [ds:TREE_TEXTURE_TEXTURE_OFS]        ; TODO: ZeroMemory
    push ds
    mov ds, ax
    TREE_CALL free_memory
    pop ds
    mov WORD [ds:TREE_TEXTURE_TEXTURE_OFS], 0
    TREE_CALL free_memory

    pop eax

    ret


; uint16:ax GetDrawable(uint16*:ds:structure);

GetDrawable:

    mov ax, [ds:TREE_TEXTURE_TEXTURE_OFS]
    retf


; void PrintTexture(uint16:ax:structure, uint8:cl:color);

PrintTexture:

    call near PrintTexture0
    retf


PrintTexture0:

    pushad
    push ds

    mov ds, ax                                   ; 填充的块
    xor edx, edx
    xor eax, eax
    mov dx, [ds:TREE_TEXTURE_WIDTH_OFS]
    mov ax, [ds:TREE_TEXTURE_HEIGHT_OFS]
    mul edx
    mov ebx, 4
    div ebx
    push eax

    mov ax, [ds:TREE_TEXTURE_TEXTURE_OFS]
    mov ds, ax

    mov ch, cl                                   ; eax:cl_cl_cl_cl
    mov ax, cx
    shl eax, 16
    mov ax, cx

    xor ebx, ebx
    pop ecx
.print:
    mov [ds:ebx], eax
    add ebx, 4
    loop .print

.fin:
    pop ds
    popad

    ret


; 不建议使用
; void DrawPixel(uint16*ds:structure,
;    uint16:dx:ax:position, uint8:cl:color);

DrawPixel:

    call near DrawPixel0
    retf


DrawPixel0:

    pushad
    push ds

    and edx, 0x0000ffff                          ; position
    and eax, 0x0000ffff
    push edx
    push eax

    mov dx, [ds:TREE_TEXTURE_WIDTH_OFS]          ; size
    mov ax, [ds:TREE_TEXTURE_HEIGHT_OFS]
    push edx
    push eax

    cmp edx, [ss:(8 + esp)]                      ; position.y
    jna .checkerror
    cmp eax, [ss:(12 + esp)]                     ; position.x
    jna .checkerror

    mov eax, [ss:(4 + esp)]                      ; texture.width
    mov ecx, [ss:(12 + esp)]                     ; position.x
    mul ecx
    add eax, [ss:(8 + esp)]                      ; position.y
    mov ebx, eax

    mov ax, [ds:TREE_TEXTURE_TEXTURE_OFS]
    mov ds, ax
    mov [ds:ebx], cl

.checkerror:
    pop eax
    pop eax
    pop eax
    pop eax

    pop ds
    popad

    ret


; void DrawLine(uint16*:ds:structure,
;    uint16:dx:ax:position, uint16:(ebx16-31):length,
;    uint16:bx:breadth, uint8:ch:style, uint8:cl:color);


DrawLine:

    call near DrawLine0
    retf


DrawLine0:

    push eax
    push ebx
    push ecx
    push edx
    push ds
    push es

    push eax
    mov ax, ds
    mov es, ax

    cmp ch, TREE_DRAWLINE_STYLE_HORIZONTAL
    jnz .vertical
    mov ax, bx                                   ; length/breadth
    shr ebx, 16
    mov dx, bx
    jmp near .new
.vertical:
    mov dx, bx
    shr ebx, 16
    mov ax, bx
.new:
    call near NewTexture0
    cmp ax, NUL_SEL
    jz .overflow
    call near PrintTexture0
    mov ds, ax

    mov edx, [ss:(12 + esp)]
    mov eax, [ss:esp]

    call near BlitTexture0
    call near DestroyTexture0
    pop eax

    mov eax, TREE_LOGICAL_TRUE
.fin:
    pop es
    pop ds
    pop edx
    pop ecx
    pop ebx
    pop eax

    ret


.overflow:
    mov eax, TREE_LOGICAL_FALSE
    jmp near .fin


; void DrawRect(uint16*:ds:structure,
;    uint16:dx:ax:position, uint16:(ebx16-31):width,
;    uint16:bx:height, uint8:cl:color);

DrawRect:

    call near DrawRect0
    retf


DrawRect0:

    push cx

    mov ch, TREE_DRAWLINE_STYLE_HORIZONTAL
    call near DrawLine0

    pop cx

    ret


; void BlitTexture(ds:src, es:dst,
;    int16:dx:ax:x:y:param);

BlitTexture:

    call near BlitTexture0
    retf


BlitTexture0:

    pushfd
    push eax
    push ecx
    push edx
    push esi
    push edi
    push ds
    push es

    xor edx, edx
    xor eax, eax

    mov dx, [ds:TREE_TEXTURE_WIDTH_OFS]          ; 源.属性
    mov ax, [ds:TREE_TEXTURE_HEIGHT_OFS]
    push edx
    push eax

    mov dx, [es:TREE_TEXTURE_WIDTH_OFS]          ; 的.属性
    mov ax, [es:TREE_TEXTURE_HEIGHT_OFS]
    push edx
    push eax

    mov dx, [ds:TREE_TEXTURE_TEXTURE_OFS]        ; texture
    mov ax, [es:TREE_TEXTURE_TEXTURE_OFS]
    mov ds, dx
    mov es, ax

    mov edx, [ss:(32 + esp)]                     ; position
    mov eax, [ss:(40 + esp)]
    and edx, 0x0000ffff
    and eax, 0x0000ffff
    push edx
    push eax

    push DWORD 0                                 ; src.offset.x
    push DWORD 0                                 ; src.offset.y

                                                 ; check position
    cmp dx, [ss:(16 + esp)]                      ; dst.height
    jnl .checkerror
    cmp ax, [ss:(20 + esp)]                      ; dst.width
    jnl .checkerror

    ;jmp near .j1                                ; skip
    cmp dx, 0                                    ; < 0
    jnl .j0
    mov cx, 0                                    ; abs
    sub cx, dx
    and ecx, 0x0000ffff

    cmp ecx, [ss:(24 + esp)]                     ; src.height
    jnb .checkerror
    mov DWORD [ss:(12 + esp)], 0                 ; position.x
    mov [ss:(4 + esp)], ecx                      ; src.offset.x

.j0:
    cmp ax, 0                                    ; < 0
    jnl .j1
    mov cx, 0                                    ; abs
    sub cx, ax
    and ecx, 0x0000ffff

    cmp ecx, [ss:(28 + esp)]                     ; src.width
    jnb .checkerror
    mov DWORD [ss:(8 + esp)], 0                  ; position.y
    mov [ss:esp], ecx                            ; src.offset.y

.j1:
    xor eax, eax                                 ; rowcounter
    mov ecx, [ss:(24 + esp)]                     ; src.height
    mov edx, [ss:(28 + esp)]                     ; src.width
.blit:
    push eax
    push ecx
    push edx
                                                 ; calculate src.esi
    mov ecx, [ss:(40 + esp)]                     ; src.width
    mov eax, [ss:(8 + esp)]                      ; now-row
    add eax, [ss:(16 + esp)]                     ; offset.x
    mul ecx
    add eax, [ss:(12 + esp)]                     ; offset.y
    mov esi, eax
                                                 ; calculate dst.edi
    mov ecx, [ss:(32 + esp)]                     ; dst.width
    mov eax, [ss:(8 + esp)]                      ; now-row
    add eax, [ss:(24 + esp)]                     ; position.x
    mul ecx
    add eax, [ss:(20 + esp)]                     ; position.y
    mov edi, eax

    pop edx
    pop ecx
    pop eax
                                                 ; cpy-row
    push eax                                     ; colcounter
    push ecx
    xor eax, eax
.s0:
    add eax, [ss:(16 + esp)]                     ; y+colcounter<dst.width
    ;add eax, 4                                  ; next 4
    add eax, 1 ;;;
    cmp eax, [ss:(28 + esp)]
                                                 ;ja .bk4
    ja .bk0;;;;

                                                 ;mov ecx, [ds:esi]
                                                 ;mov [es:edi], ecx
    mov cl, [ds:esi];;;;
    cmp cl, Color_Transparent;;;;
    jz .skip;;;;
    mov [es:edi], cl;;;;
.skip:;;;;

    ;inc esi
    ;inc esi
    ;inc esi
    inc esi;;;;

    ;inc edi
    ;inc edi
    ;inc edi
    inc edi;;;;

    sub eax, [ss:(16 + esp)]                     ; offset.y+colcounter
    push eax                                     ;    <src.width
    add eax, [ss:(12 + esp)]
    cmp eax, edx
    pop eax
    jnb .bk0

    jmp near .s0

.bk5:
.bk0:
    pop ecx
    pop eax

    inc eax
    add eax, [ss:(12 + esp)]
    cmp eax, [ss:(16 + esp)]                     ; x+rowcounter<dst.height
    jnb .bk
    sub eax, [ss:(12 + esp)]                     ; offset.x+rowcounter
    push eax                                     ;    <src.height
    add eax, [ss:(8 + esp)]
    cmp eax, ecx
    pop eax
    jnb .bk
    jmp near .blit
.bk:
.checkerror:
.clean:
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax

.fin:
    pop es
    pop ds
    pop edi
    pop esi
    pop edx
    pop ecx
    pop eax
    popfd

    ret


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'texture'
TREE_VER 0

___TREE_DATA_END_