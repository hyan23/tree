; tree/kernel/wnd/window.ss
; Author: hyan23
; Date: 2016.08.02
;

; 窗口

%include "../inc/nasm/tree.ic"
%include "../inc/nasm/io/def0.ic"
%include "../kernel/wnd/window.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'agent', 0
    __TREE_LIB @1, 'conio', 0
    __TREE_LIB @2, 'task', 0
    __TREE_LIB @3, 'rand', 0
    __TREE_LIB @4, 'string', 0
    __TREE_LIB @5, 'time', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

; Set...方法，除了SetTitle其他不主动释放资源。
    __TREE_EXPORT @0, 'WndCreate', WndCreate
    __TREE_EXPORT @1, 'WndDestroy', WndDestroy
    __TREE_EXPORT @2, 'WndGetPid', WndGetPid
    __TREE_EXPORT @3, 'WndGetSize', WndGetSize
    __TREE_EXPORT @4, 'WndGetTitle', WndGetTitle
    __TREE_EXPORT @5, 'WndSetTitle', WndSetTitle
    __TREE_EXPORT @6, 'WndGetWindow', WndGetWindow
    __TREE_EXPORT @7, 'WndSetWindow', WndSetWindow
    __TREE_EXPORT @8, 'WndGetDrawable', WndGetDrawable
    __TREE_EXPORT @9, 'WndSetDrawable', WndSetDrawable
    __TREE_EXPORT @10, 'WndGetMSGQ', WndGetMSGQ
    __TREE_EXPORT @11, 'WndSetMSGQ', WndSetMSGQ
    __TREE_EXPORT @12, 'WndGetPosition', WndGetPosition
    __TREE_EXPORT @13, 'WndSetPosition', WndSetPosition

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @0, 'alloc_memory0', alloc_memory0
    __TREE_IMPORT @1, 'free_memory', free_memory
    __TREE_IMPORT @2, 'putn', putn
    __TREE_IMPORT @3, 'GetTickCount', GetTickCount
    __TREE_IMPORT @4, 'GetTaskPid', GetTaskPid
    __TREE_IMPORT @5, 'srand', srand
    __TREE_IMPORT @6, 'rand', rand
    __TREE_IMPORT @7, 'strlen', strlen
    __TREE_IMPORT @8, 'strcpy', strcpy
    __TREE_IMPORT @9, 'getseed', getseed

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:
    TREE_HUNG


; uint16:ax WndCreate(ds:ebx:title, \
;   uint16:dx:ax:width:height);

WndCreate:

    push ebx
    push ecx
    push edx
    push ds
    push es

    and edx, 0x0000ffff                          ; width&height
    and eax, 0x0000ffff
    push edx
    push eax

    mov ecx, TREE_WINDOW_CONTEXT_BYTES
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow
    mov ds, ax

    TREE_CALL GetTaskPid                         ; process
    mov [ds:TREE_WINDOW_CONTEXT_PID_OFS], ax
    push ds

    mov ax, [ss:(16 + esp)]                      ; title
    mov ds, ax
    TREE_CALL strlen
    mov ecx, eax
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow0
    mov es, ax

    mov esi, ebx                                 ; strcpy
    xor edi, edi
    TREE_CALL strcpy

    pop ds
    mov [ds:TREE_WINDOW_CONTEXT_TITLE_OFS], es

                                                 ; sel
    mov WORD [ds:TREE_WINDOW_CONTEXT_WINDOW_OFS], NUL_SEL
    mov WORD [ds:TREE_WINDOW_CONTEXT_DRAWABLE_OFS], NUL_SEL
    mov WORD [ds:TREE_WINDOW_CONTEXT_MSG_OFS], NUL_SEL

    mov edx, [ss:(4 + esp)]                      ; width&height
    mov eax, [ss:esp]
    mov [ds:TREE_WINDOW_CONTEXT_WIDTH_OFS], edx
    mov [ds:TREE_WINDOW_CONTEXT_HEIGHT_OFS], eax

    TREE_CALL getseed                            ; random-pos
    TREE_CALL srand

    TREE_CALL rand                               ; -x
    xor edx, edx
    mov ecx, TREE_SCR_HEIGHT - TREE_SCR_HEIGHT / 2 - \
        TREE_WINDOW_TITLE_BAR_HEIGHT
    div ecx
    push edx

    TREE_CALL rand                               ; -y
    xor edx, edx
    mov ecx, TREE_SCR_WIDTH - TREE_SCR_WIDTH / 2 - \
        2 * TREE_WINDOW_TITLE_BAR_HEIGHT
    div ecx
    mov eax, edx
    pop edx

    mov [ds:TREE_WINDOW_CONTEXT_X_OFS], edx
    mov [ds:TREE_WINDOW_CONTEXT_Y_OFS], eax

    mov ax, ds
.fin:
    pop edx
    pop edx

    pop es
    pop ds
    pop edx
    pop ecx
    pop ebx

    retf

.overflow:
    mov ax, NUL_SEL
    jmp near .fin

.overflow0:
    pop ds
    TREE_CALL free_memory
    mov ax, NUL_SEL
    jmp near .fin


; void WndDestroy(ds:window);

WndDestroy:

    push ax

    push ds

    mov ax, [ds:TREE_WINDOW_CONTEXT_TITLE_OFS]
    mov ds, ax
    TREE_CALL free_memory

    mov ax, [ss:esp]
    mov ds, ax
    mov ax, [ds:TREE_WINDOW_CONTEXT_WINDOW_OFS]
    cmp ax, NUL_SEL
    jz .j0
    mov ds, ax
    TREE_CALL free_memory

.j0:
    mov ax, [ss:esp]
    mov ds, ax
    mov ax, [ds:TREE_WINDOW_CONTEXT_DRAWABLE_OFS]
    cmp ax, NUL_SEL
    jz .j1
    mov ds, ax
    TREE_CALL free_memory

.j1:
    mov ax, [ss:esp]
    mov ds, ax
    mov ax, [ds:TREE_WINDOW_CONTEXT_MSG_OFS]
    cmp ax, NUL_SEL
    jz .j2
    mov ds, ax
    TREE_CALL free_memory

.j2:
    pop ds
    TREE_CALL free_memory

    pop ax

    retf


; uint16:ax WndGetPid(ds:window);

WndGetPid:

    mov ax, [ds:TREE_WINDOW_CONTEXT_PID_OFS]
    retf


; dx:ax:size WndGetSize(ds:window);

WndGetSize:

    mov dx, [ds:TREE_WINDOW_CONTEXT_WIDTH_OFS]
    mov ax, [ds:TREE_WINDOW_CONTEXT_HEIGHT_OFS]

    retf


; ax:ebx WndGetTitle(ds:window);

WndGetTitle:

    mov ax, [ds:TREE_WINDOW_CONTEXT_TITLE_OFS]
    xor ebx, ebx

    retf


; bool:eax WndSetTitle(ds:window, ax:ebx:title);

WndSetTitle:

    push ecx
    push ds
    push es

    mov ds, ax
    TREE_CALL strlen
    mov ecx, eax
    TREE_CALL alloc_memory0
    cmp ax, NUL_SEL
    jz .overflow
    mov es, ax
    mov esi, ebx
    xor edi, edi
    TREE_CALL strcpy

    mov ax, [ss:(4 + esp)]
    mov ds, ax
    mov ax, [ds:TREE_WINDOW_CONTEXT_TITLE_OFS]
    ; ASSERT(NUL_SEL != ax)
    mov [ds:TREE_WINDOW_CONTEXT_TITLE_OFS], es
    mov ds, ax
    TREE_CALL free_memory

    mov eax, TREE_LOGICAL_TRUE
.fin:
    pop es
    pop ds
    pop ecx

    retf

.overflow:
    mov eax, TREE_LOGICAL_FALSE
    jmp near .fin


; uint16:ax WndGetWindow(ds:window);

WndGetWindow:

    mov ax, [ds:TREE_WINDOW_CONTEXT_WINDOW_OFS]
    retf


; void WndSetWindow(ds:window, uint16:ax:sel);

WndSetWindow:

    mov [ds:TREE_WINDOW_CONTEXT_WINDOW_OFS], ax
    retf


; uint16:ax WndGetDrawable(ds:window);

WndGetDrawable:

    mov ax, [ds:TREE_WINDOW_CONTEXT_DRAWABLE_OFS]
    retf


; void WndSetDrawable(ds:window, uint16:ax:sel);

WndSetDrawable:

    mov [ds:TREE_WINDOW_CONTEXT_DRAWABLE_OFS], ax
    retf


; uint16:ax WndGetMSGQ(ds:window);

WndGetMSGQ:

    mov ax, [ds:TREE_WINDOW_CONTEXT_MSG_OFS]
    retf


; void WndSetMSGQ(ds:window, uint16:ax:sel);

WndSetMSGQ:

    mov [ds:TREE_WINDOW_CONTEXT_MSG_OFS], ax
    retf


; int16:dx:ax:x:y WndGetPosition(ds:window);

WndGetPosition:

    mov dx, [ds:TREE_WINDOW_CONTEXT_X_OFS]
    mov ax, [ds:TREE_WINDOW_CONTEXT_Y_OFS]
    retf


; void WndSetPosition(ds:window, int16:dx:ax:x:y);

WndSetPosition:

    mov [ds:TREE_WINDOW_CONTEXT_X_OFS], dx
    mov [ds:TREE_WINDOW_CONTEXT_Y_OFS], ax
    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'window'
TREE_VER 0


___TREE_DATA_END_