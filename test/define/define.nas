; tree/test/define/define.nas
; Author: hyan23
; Date: 2016.05.05
;

; 测试宏作用域


SECTION .data

%define __DEFINE_

%ifdef __DEFINE_
	DW 0
%else
	DB 0
%endif ; __DEFINE_


