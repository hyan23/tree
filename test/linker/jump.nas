; tree/test/linker/jump.nas
; Author: hyan23
; Date: 2016.05.06
;


; 测试绝对跳转

begin:
linker: dw 0x0000, 0xf700
dw 0, 0, 0, 0
jmp [linker]
jmp dword 0xf700:0x0000
trail:
times (510 - (trail - begin)) db 0
db 0x55, 0xaa