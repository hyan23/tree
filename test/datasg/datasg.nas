; tree/test/datasg/datasg.nas
; Author: hyan23
; Date: 2016.05.07
;

; �������ݶεķ��ʺ��ض�λ


	;dd (section.text.start >> 2)
	dd section.data.start
	dd 5 >> 2

section text

	mov eax, section.data.start
	mov ds, eax
	mov ebx, [DATA]
	mov ebx, DATA
	mov eax, [ebx]


section data align=32 vstart=0

	DATA dw 0, 0, 0, 0