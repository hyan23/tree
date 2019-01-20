; tree/kernel/gate.ss
; Author: hyan23
; Date: 2016.06.17
;

; 安装系统调用门, 在特权级0下运行。

; 目前仅支持安装静态特权级代码的门调用(.s0), 无法处理使用[TREE]体系结构
;    使用__TREE_EXPORT 标记导出的动态符号,(2016.07.21已经支持), 因为
;    动态加载的代码不会被运行在特权级0(可以了)。
; 若需导出tree/boot/abscall.ic 里面定义的符号, 完成以下步骤:
;    1. 在tree/kernel/gate.ic 定义符号对应调用门选择子在选择子表的索引号。
;        使用: __SYMBOL        EQU            index。
;    2. 在此文件的初始化部分使用我编写的宏安装调用门, 成功后它的选择子将自动保存
;        至选择子表, 索引已在上一步骤定义好了。
;    3. 若有必要, 在tree/kernel/agent.ss 注册符号代理, 方法请参看该文件注释。
;

%include "../boot/gdt.ic"
%include "../kernel/gate.ic"
%include "../inc/nasm/tree.ic"

___TREE_IPT_LIB_BEGIN_

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

___TREE_IPT_TAB_END_


___TREE_CODE_BEGIN_

TREE_START:

                                                 ; 安装调用门(静态代码)
                                                 ; 并保存选择子选择子表
                                                 ; 使用这个宏安装的所有调用门
%macro INSTALL_CALL_GATE0 3                      ; 都会被安装到GDT, 使用全局代码
                                                 ; 段 + 32 位索引。
    mov ax, DATA_SEL                             ; 加载全局数据段, 访问一个
    mov ds, ax                                   ; 绝对代码块首部。
    mov ecx, [ds:(%2)]                           ; 符号偏移(块内)
    add ecx, %1                                  ; 加上基地址(块偏移)
    mov ax, CODE_SEL                             ; 所在代码段(全局)
    mov ebx, 0                                   ; 参数个数0(寄存器传递)
    mov edx, %3                                  ; indexintab

    TREE_ABSCALL INSTALL_CALL_GATE

; 忘了说了: 参数: 1: 绝对代码块偏移(加载地址), 绝对符号偏移(间接远调用的地址),
;    3: 指定调用门的选择子在选择子表的索引^^。
; 如果对任何一个符号的处理出现错误, 都会终止本文件的执行从而导致系统启动失败哦。

%endmacro ; INSTALL_CALL_GATE0


.InstallCallGate:

    mov ax, DATA_SEL                             ; 安装零级特权级代码接口
    mov ds, ax                                   ;    调用门描述符
    mov ax, GDT_SEL                              ; 选择子静态。
    mov es, ax

    mov ax, PCI0CALL_SEL                         ; 选择子右移3位
    shr ax, 3                                    ; 计算表内偏移
    mov cl, 8
    mul cl
    push ax

    mov ecx, [ds:PCI0CALL]                       ; 读入口点偏移
    add ecx, EXTRA_OFS
    mov ax, CODE_SEL                             ; 所在代码段(全局)
    mov ebx, 1                                   ; 参数个数: 1
    or ebx, 0x60                                 ; 特权级: 0x60

    TREE_ABSCALL MAKE_GDT_CALLGATE               ; 生成描述符

    pop bx
    mov [es:bx], eax                             ; 填写。
    mov [es:(4 + bx)], edx

                                                 ; 以下安装系统其他调用门。
    INSTALL_CALL_GATE0 BASER_OFS, READ_SECTOR, __READ_SECTOR
    INSTALL_CALL_GATE0 BASER_OFS, READ_BLOCK, __READ_BLOCK

    INSTALL_CALL_GATE0 BASEC_OFS, PUT_CHAR, __PUT_CHAR
    INSTALL_CALL_GATE0 BASEC_OFS, PUT_STR, __PUT_STR
    INSTALL_CALL_GATE0 BASEC_OFS, SET_COLOR, __SET_COLOR
    INSTALL_CALL_GATE0 BASEC_OFS, CLR_ROW, __CLR_ROW
    INSTALL_CALL_GATE0 BASEC_OFS, CLR_SCR, __CLR_SCR
    INSTALL_CALL_GATE0 BASEC_OFS, GOTO_XY, __GOTO_XY

    INSTALL_CALL_GATE0 EXEC_OFS, TREE_EXECUTE, __TREE_EXECUTE
    INSTALL_CALL_GATE0 EXEC_OFS, TREE_TERMINATE, __TREE_TERMINATE

    INSTALL_CALL_GATE0 MEMORY_OFS, MEMCPY, __MEMCPY
    INSTALL_CALL_GATE0 MEMORY_OFS, ZEROMEMORY, __ZEROMEMORY

    INSTALL_CALL_GATE0 MEMORY_OFS, ALLOC_MEMORY0, __ALLOC_MEMORY0
    INSTALL_CALL_GATE0 MEMORY_OFS, FREE_MEMORY, __FREE_MEMORY

    INSTALL_CALL_GATE0 EXTRA_OFS, GET_DES_PROPERTY, __GET_DES_PROPERTY


    xor eax, eax
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax

.gdtoverflow:
    mov eax, -1
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax

___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'gate'
TREE_VER 0

___TREE_DATA_END_