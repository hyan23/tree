; tree/kernel/graphic/graphic0.ss
; Author: hyan23
; Date: 2016.05.03
;

; 图形驱动

%include "../kernel/gate.ic"
%include "../kernel/graphic/graphic.ic"
%include "../inc/nasm/tree.ic"


___TREE_IPT_LIB_BEGIN_

    __TREE_LIB @0, 'graphic0', 0

___TREE_IPT_LIB_END_

___TREE_XPT_TAB_BEGIN_

    __TREE_EXPORT @111, 'graphic0foo', graphic0foo

___TREE_XPT_TAB_END_

___TREE_IPT_TAB_BEGIN_

    __TREE_IMPORT @111, 'graphic0foo', graphic0fOO

___TREE_IPT_TAB_END_

    VRAM_OFS        EQU     0xe0000000


___TREE_CODE_BEGIN_

TREE_START:
    mov ax, [ss:TREE_USR_STACK - 4 - 1]          ; 加载:
    mov es, ax                                   ; 进程空间
    mov ax, [es:ACCESS_SRC(4 + graphic0fOO)]     ; 全局代码

    mov ebx, 0                                   ; 安装调用门。
    mov ecx, reflesh_scr
    mov edx, __REFRESH_SCR
    TREE_ABSCALL INSTALL_CALL_GATE
    test eax, TREE_LOGICAL_TRUE
    jz .failed

    call near SET_UP_PALETTE                     ; 安装色板

    xor eax, eax
.fin:
    TREE_EXIT0 TREE_EXEC_RET_LIB, eax

.failed:
    mov eax, -1
    jmp near .fin


; void reflesh_scr(uint32*ds:ebx:scrbuf);
; scrbuf >= TREE_SCR_WIDTH * TREE_SCR_HEIGHT

reflesh_scr:

    pushad
    push es

    mov ax, DATA_SEL
    mov es, ax
    mov edi, VRAM_OFS

    mov ecx, TREE_SCR_WIDTH * TREE_SCR_HEIGHT / 4
.cpy:
    mov eax, [ds:ebx]
    mov [es:edi], eax
    add ebx, 4
    add edi, 4
    loop .cpy

    pop es
    popad

    retf


; void SET_UP_PALETTE(void);

SET_UP_PALETTE:

    push eax
    push ebx
    push edx
    push ds

    xor al, al                                   ; 色板号
    mov dx, 0x03c8
    out dx, al

    TREE_LOCATE_DATA

%include "../boot/args.ic"

%if (1 == TREE_ENABLE_GRAPHIC)                  ; 256色
    mov ebx, PALETTE0
    mov ecx, 0xff
%else                                            ; 16色
    mov ebx, PALETTE
    mov ecx, 0x10
%endif ; 1 == TREE_ENABLE_GRAPHIC

    mov dx, 0x03c9
.s:
    mov al, [ds:ebx]
    out dx, al
    inc ebx
    mov al, [ds:ebx]
    out dx, al
    inc ebx
    mov al, [ds:ebx]
    out dx, al
    inc ebx
    loop .s

    pop ds
    pop edx
    pop ebx
    pop eax

    ret


; ;;;;;;;;;;;;;;;;;
graphic0foo:

    retf


___TREE_CODE_END_


___TREE_DATA_BEGIN_

TREE_NAME 'graphic0'
TREE_VER 0

                                                 ; 色板
PALETTE:

    DB  0x00,   0x00,   0x00                     ; 黑
    DB  0xff,   0xff,   0xff                     ; 白
    DB  0xc6,   0xc6,   0xc6                     ; 灰
    DB  0xff,   0x00,   0x00                     ; 红
    DB  0x00,   0xff,   0x00                     ; 绿
    DB  0x00,   0x00,   0xff                     ; 蓝
    DB  0x00,   0xff,   0xff                     ; 浅蓝
    ;DB  0xff,   0xff,   0x00                    ; 黄
    DB  0xff,   0xff,   0xff
    DB  0xff,   0x00,   0xff                     ; 紫
    DB  0x84,   0x84,   0x84                     ; 浅灰
    DB  0x84,   0x00,   0x00                     ; 暗红
    DB  0x00,   0x84,   0x00                     ; 暗绿
    DB  0x00,   0x00,   0x84                     ; 暗青
    DB  0x00,   0x84,   0x84                     ; 浅暗蓝
    DB  0x84,   0x84,   0x00                     ; 暗黄
    DB  0x84,   0x00,   0x84                     ; 暗紫

PALETTE0:
    Snow               DB 000,	000,	000
    ;Snow               DB 255,	250,	250
    GhostWhite         DB 248,	248,	255
    WhiteSmoke         DB 245,	245,	245
    Gainsboro          DB 220,	220,	220
    FloralWhite        DB 255,	250,	240
    OldLace            DB 253,	245,	230
    Linen              DB 250,	240,	230
    AntiqueWhite       DB 250,	235,	215
    PapayaWhip         DB 255,	239,	213
    BlanchedAlmond     DB 255,	235,	205
    Bisque             DB 255,	228,	196
    PeachPuff          DB 255,	218,	185
    NavajoWhite        DB 255,	222,	173
    Moccasin           DB 255,	228,	181
    Cornsilk           DB 255,	248,	220
    Ivory              DB 255,	255,	240
    LemonChiffon       DB 255,	250,	205
    Seashell           DB 255,	245,	238
    Honeydew           DB 240,	255,	240
    MintCream          DB 245,	255,	250
    Azure              DB 240,	255,	255
    AliceBlue          DB 240,	248,	255
    lavender           DB 230,	230,	250
    LavenderBlush      DB 255,	240,	245
    MistyRose          DB 255,	228,	225
    White              DB 255,	255,	255
    Black              DB 000,	000,	000
    DarkSlateGray      DB 047,	079,	079
    DimGrey            DB 105,	105,	105
    SlateGrey          DB 112,	128,	144
    LightSlateGray     DB 119,	136,	153
    Grey               DB 190,	190,	190
    LightGray          DB 211,	211,	211
    MidnightBlue       DB 025,	025,	112
    NavyBlue           DB 000,	000,	128
    CornflowerBlue     DB 100,	149,	237
    DarkSlateBlue      DB 072,	061,	139
    SlateBlue          DB 106,	090,	205
    MediumSlateBlue    DB 123,	104,	238
    LightSlateBlue     DB 132,	112,	255
    MediumBlue         DB 000,	000,	205
    RoyalBlue          DB 065,	105,	225
    Blue               DB 000,	000,	255
    DodgerBlue         DB 030,	144,	255
    DeepSkyBlue        DB 000,	191,	255
    SkyBlue            DB 135,	206,	235
    LightSkyBlue       DB 135,	206,	250
    SteelBlue          DB 070,	130,	180
    LightSteelBlue     DB 176,	196,	222
    LightBlue          DB 173,	216,	230
    PowderBlue         DB 176,	224,	230
    PaleTurquoise      DB 175,	238,	238
    DarkTurquoise      DB 000,	206,	209
    MediumTurquoise    DB 072,	209,	204
    Turquoise          DB 064,	224,	208
    Cyan               DB 000,	255,	255
    LightCyan          DB 224,	255,	255
    CadetBlue          DB 095,	158,	160
    MediumAquamarine   DB 102,	205,	170
    Aquamarine         DB 127,	255,	212
    DarkGreen          DB 000,	100,	000
    DarkOliveGreen     DB 085,	107,	047
    DarkSeaGreen       DB 143,	188,	143
    SeaGreen           DB 046,	139,	087
    MediumSeaGreen     DB 060,	179,	113
    LightSeaGreen      DB 032,	178,	170
    PaleGreen          DB 152,	251,	152
    SpringGreen        DB 000,	255,	127
    LawnGreen          DB 124,	252,	000
    Green              DB 000,	255,	000
    Chartreuse         DB 127,	255,	000
    MedSpringGreen     DB 000,	250,	154
    GreenYellow        DB 173,	255,	047
    LimeGreen          DB 050,	205,	050
    YellowGreen        DB 154,	205,	050
    ForestGreen        DB 034,	139,	034
    OliveDrab          DB 107,	142,	035
    DarkKhaki          DB 189,	183,	107
    PaleGoldenrod      DB 238,	232,	170
    LtGoldenrodYello   DB 250,	250,	210
    LightYellow        DB 255,	255,	224
    Yellow             DB 255,	255,	000
    Gold               DB 255,	215,	000
    LightGoldenrod     DB 238,	221,	130
    goldenrod          DB 218,	165,	032
    DarkGoldenrod      DB 184,	134,	011
    RosyBrown          DB 188,	143,	143
    IndianRed          DB 205,	092,	092
    SaddleBrown        DB 139,	069,	019
    Sienna             DB 160,	082,	045
    Peru               DB 205,	133,	063
    Burlywood          DB 222,	184,	135
    Beige              DB 245,	245,	220
    Wheat              DB 245,	222,	179
    SandyBrown         DB 244,	164,	096
    Tan                DB 210,	180,	140
    Chocolate          DB 210,	105,	030
    Firebrick          DB 178,	034,	034
    Brown              DB 165,	042,	042
    DarkSalmon         DB 233,	150,	122
    Salmon             DB 250,	128,	114
    LightSalmon        DB 255,	160,	122
    Orange             DB 255,	165,	000
    DarkOrange         DB 255,	140,	000
    Coral              DB 255,	127,	080
    LightCoral         DB 240,	128,	128
    Tomato             DB 255,	099,	071
    OrangeRed          DB 255,	069,	000
    Red                DB 255,	000,	000
    HotPink            DB 255,	105,	180
    DeepPink           DB 255,	020,	147
    Pink               DB 255,	192,	203
    LightPink          DB 255,	182,	193
    PaleVioletRed      DB 219,	112,	147
    Maroon             DB 176,	048,	096
    MediumVioletRed    DB 199,	021,	133
    VioletRed          DB 208,	032,	144
    Magenta            DB 255,	000,	255
    Violet             DB 238,	130,	238
    Plum               DB 221,	160,	221
    Orchid             DB 218,	112,	214
    MediumOrchid       DB 186,	085,	211
    DarkOrchid         DB 153,	050,	204
    DarkViolet         DB 148,	000,	211
    BlueViolet         DB 138,	043,	226
    Purple             DB 160,	032,	240
    MediumPurple       DB 147,	112,	219
    Thistle            DB 216,	191,	216
    Snow1              DB 255,	250,	250
    Snow2              DB 238,	233,	233
    Snow3              DB 205,	201,	201
    Snow4              DB 139,	137,	137
    Seashell1          DB 255,	245,	238
    Seashell2          DB 238,	229,	222
    Seashell3          DB 205,	197,	191
    Seashell4          DB 139,	134,	130
    AntiqueWhite1      DB 255,	239,	219
    AntiqueWhite2      DB 238,	223,	204
    AntiqueWhite3      DB 205,	192,	176
    AntiqueWhite4      DB 139,	131,	120
    Bisque1            DB 255,	228,	196
    Bisque2            DB 238,	213,	183
    Bisque3            DB 205,	183,	158
    Bisque4            DB 139,	125,	107
    PeachPuff1         DB 255,	218,	185
    PeachPuff2         DB 238,	203,	173
    PeachPuff3         DB 205,	175,	149
    PeachPuff4         DB 139,	119,	101
    NavajoWhite1       DB 255,	222,	173
    NavajoWhite2       DB 238,	207,	161
    NavajoWhite3       DB 205,	179,	139
    NavajoWhite4       DB 139,	121,	094
    LemonChiffon1      DB 255,	250,	205
    LemonChiffon2      DB 238,	233,	191
    LemonChiffon3      DB 205,	201,	165
    LemonChiffon4      DB 139,	137,	112
    Cornsilk1          DB 255,	248,	220
    Cornsilk2          DB 238,	232,	205
    Cornsilk3          DB 205,	200,	177
    Cornsilk4          DB 139,	136,	120
    Ivory1             DB 255,	255,	240
    Ivory2             DB 238,	238,	224
    Ivory3             DB 205,	205,	193
    Ivory4             DB 139,	139,	131
    Honeydew1          DB 240,	255,	240
    Honeydew2          DB 224,	238,	224
    Honeydew3          DB 193,	205,	193
    Honeydew4          DB 131,	139,	131
    LavenderBlush1     DB 255,	240,	245
    LavenderBlush2     DB 238,	224,	229
    LavenderBlush3     DB 205,	193,	197
    LavenderBlush4     DB 139,	131,	134
    MistyRose1         DB 255,	228,	225
    MistyRose2         DB 238,	213,	210
    MistyRose3         DB 205,	183,	181
    MistyRose4         DB 139,	125,	123
    Azure1             DB 240,	255,	255
    Azure2             DB 224,	238,	238
    Azure3             DB 193,	205,	205
    Azure4             DB 131,	139,	139
    SlateBlue1         DB 131,	111,	255
    SlateBlue2         DB 122,	103,	238
    SlateBlue3         DB 105,	089,	205
    SlateBlue4         DB 071,	060,	139
    RoyalBlue1         DB 072,	118,	255
    RoyalBlue2         DB 067,	110,	238
    RoyalBlue3         DB 058,	095,	205
    RoyalBlue4         DB 039,	064,	139
    Blue1              DB 000,	000,	255
    Blue2              DB 000,	000,	238
    Blue3              DB 000,	000,	205
    Blue4              DB 000,	000,	139
    DodgerBlue1        DB 030,	144,	255
    DodgerBlue2        DB 028,	134,	238
    DodgerBlue3        DB 024,	116,	205
    DodgerBlue4        DB 016,	078,	139
    SteelBlue1         DB 099,	184,	255
    SteelBlue2         DB 092,	172,	238
    SteelBlue3         DB 079,	148,	205
    SteelBlue4         DB 054,	100,	139
    DeepSkyBlue1       DB 000,	191,	255
    DeepSkyBlue2       DB 000,	178,	238
    DeepSkyBlue3       DB 000,	154,	205
    DeepSkyBlue4       DB 000,	104,	139
    SkyBlue1           DB 135,	206,	255
    SkyBlue2           DB 126,	192,	238
    SkyBlue3           DB 108,	166,	205
    SkyBlue4           DB 074,	112,	139
    LightSkyBlue1      DB 176,	226,	255
    LightSkyBlue2      DB 164,	211,	238
    LightSkyBlue3      DB 141,	182,	205
    LightSkyBlue4      DB 096,	123,	139
    SlateGray1         DB 198,	226,	255
    SlateGray2         DB 185,	211,	238
    SlateGray3         DB 159,	182,	205
    SlateGray4         DB 108,	123,	139
    LightSteelBlue1    DB 202,	225,	255
    LightSteelBlue2    DB 188,	210,	238
    LightSteelBlue3    DB 162,	181,	205
    LightSteelBlue4    DB 110,	123,	139
    LightBlue1         DB 191,	239,	255
    LightBlue2         DB 178,	223,	238
    LightBlue3         DB 154,	192,	205
    LightBlue4         DB 104,	131,	139
    LightCyan1         DB 224,	255,	255
    LightCyan2         DB 209,	238,	238
    LightCyan3         DB 180,	205,	205
    LightCyan4         DB 122,	139,	139
    PaleTurquoise1     DB 187,	255,	255
    PaleTurquoise2     DB 174,	238,	238
    PaleTurquoise3     DB 150,	205,	205
    PaleTurquoise4     DB 102,	139,	139
    CadetBlue1         DB 152,	245,	255
    CadetBlue2         DB 142,	229,	238
    CadetBlue3         DB 122,	197,	205
    CadetBlue4         DB 083,	134,	139
    Turquoise1         DB 000,	245,	255
    Turquoise2         DB 000,	229,	238
    Turquoise3         DB 000,	197,	205
    Turquoise4         DB 000,	134,	139
    Cyan1              DB 000,	255,	255
    Cyan2              DB 000,	238,	238
    Cyan3              DB 000,	205,	205
    Cyan4              DB 000,	139,	139
    DarkSlateGray1     DB 151,	255,	255
    DarkSlateGray2     DB 141,	238,	238
    DarkSlateGray3     DB 121,	205,	205
    DarkSlateGray4     DB 082,	139,	139
    Aquamarine1        DB 127,	255,	212
    Aquamarine2        DB 118,	238,	198
    Aquamarine3        DB 102,	205,	170
    Aquamarine4        DB 069,	139,	116
    DarkSeaGreen1      DB 193,	255,	193
    DarkSeaGreen2      DB 180,	238,	180
    DarkSeaGreen3      DB 155,	205,	155
    DarkSeaGreen4      DB 105,	139,	105
    SeaGreen1          DB 084,	255,	159
    SeaGreen2          DB 078,	238,	148
    SeaGreen3          DB 067,	205,	128
    SeaGreen4          DB 046,	139,	087
    PaleGreen1         DB 154,	255,	154
    PaleGreen2         DB 144,	238,	144
    PaleGreen3         DB 124,	205,	124
    PaleGreen4         DB 084,	139,	084
    SpringGreen1       DB 000,	255,	127
    SpringGreen2       DB 000,	238,	118
    SpringGreen3       DB 000,	205,	102
    SpringGreen4       DB 000,	139,	069
    Green1             DB 000,	255,	000
    Green2             DB 000,	238,	000
    Green3             DB 000,	205,	000
    Green4             DB 000,	139,	000
    Chartreuse1        DB 127,	255,	000
    Chartreuse2        DB 118,	238,	000
    Chartreuse3        DB 102,	205,	000
    Chartreuse4        DB 069,	139,	000
    OliveDrab1         DB 192,	255,	062
    OliveDrab2         DB 179,	238,	058
    OliveDrab3         DB 154,	205,	050
    OliveDrab4         DB 105,	139,	034
    DarkOliveGreen1    DB 202,	255,	112
    DarkOliveGreen2    DB 188,	238,	104
    DarkOliveGreen3    DB 162,	205,	090
    DarkOliveGreen4    DB 110,	139,	061
    Khaki1             DB 255,	246,	143
    Khaki2             DB 238,	230,	133
    Khaki3             DB 205,	198,	115
    Khaki4             DB 139,	134,	078
    LightGoldenrod1    DB 255,	236,	139
    LightGoldenrod2    DB 238,	220,	130
    LightGoldenrod3    DB 205,	190,	112
    LightGoldenrod4    DB 139,	129,	076
    LightYellow1       DB 255,	255,	224
    LightYellow2       DB 238,	238,	209
    LightYellow3       DB 205,	205,	180
    LightYellow4       DB 139,	139,	122
    Yellow1            DB 255,	255,	000
    Yellow2            DB 238,	238,	000
    Yellow3            DB 205,	205,	000
    Yellow4            DB 139,	139,	000
    Gold1              DB 255,	215,	000
    Gold2              DB 238,	201,	000
    Gold3              DB 205,	173,	000
    Gold4              DB 139,	117,	000
    Goldenrod1         DB 255,	193,	037
    Goldenrod2         DB 238,	180,	034
    Goldenrod3         DB 205,	155,	029
    Goldenrod4         DB 139,	105,	020
    DarkGoldenrod1     DB 255,	185,	015
    DarkGoldenrod2     DB 238,	173,	014
    DarkGoldenrod3     DB 205,	149,	012
    DarkGoldenrod4     DB 139,	101,	008
    RosyBrown1         DB 255,	193,	193
    RosyBrown2         DB 238,	180,	180
    RosyBrown3         DB 205,	155,	155
    RosyBrown4         DB 139,	105,	105
    IndianRed1         DB 255,	106,	106
    IndianRed2         DB 238,	099,	099
    IndianRed3         DB 205,	085,	085
    IndianRed4         DB 139,	058,	058
    Sienna1            DB 255,	130,	071
    Sienna2            DB 238,	121,	066
    Sienna3            DB 205,	104,	057
    Sienna4            DB 139,	071,	038
    Burlywood1         DB 255,	211,	155
    Burlywood2         DB 238,	197,	145
    Burlywood3         DB 205,	170,	125
    Burlywood4         DB 139,	115,	085
    Wheat1             DB 255,	231,	186
    Wheat2             DB 238,	216,	174
    Wheat3             DB 205,	186,	150
    Wheat4             DB 139,	126,	102
    Tan1               DB 255,	165,	079
    Tan2               DB 238,	154,	073
    Tan3               DB 205,	133,	063
    Tan4               DB 139,	090,	043
    Chocolate1         DB 255,	127,	036
    Chocolate2         DB 238,	118,	033
    Chocolate3         DB 205,	102,	029
    Chocolate4         DB 139,	069,	019
    Firebrick1         DB 255,	048,	048
    Firebrick2         DB 238,	044,	044
    Firebrick3         DB 205,	038,	038
    Firebrick4         DB 139,	026,	026
    Brown1             DB 255,	064,	064
    Brown2             DB 238,	059,	059
    Brown3             DB 205,	051,	051
    Brown4             DB 139,	035,	035
    Salmon1            DB 255,	140,	105
    Salmon2            DB 238,	130,	098
    Salmon3            DB 205,	112,	084
    Salmon4            DB 139,	076,	057
    LightSalmon1       DB 255,	160,	122
    LightSalmon2       DB 238,	149,	114
    LightSalmon3       DB 205,	129,	098
    LightSalmon4       DB 139,	087,	066
    Orange1            DB 255,	165,	000
    Orange2            DB 238,	154,	000
    Orange3            DB 205,	133,	000
    Orange4            DB 139,	090,	000
    DarkOrange1        DB 255,	127,	000
    DarkOrange2        DB 238,	118,	000
    DarkOrange3        DB 205,	102,	000
    DarkOrange4        DB 139,	069,	000
    Coral1             DB 255,	114,	086
    Coral2             DB 238,	106,	080
    Coral3             DB 205,	091,	069
    Coral4             DB 139,	062,	047
    Tomato1            DB 255,	099,	071
    Tomato2            DB 238,	092,	066
    Tomato3            DB 205,	079,	057
    Tomato4            DB 139,	054,	038
    OrangeRed1         DB 255,	069,	000
    OrangeRed2         DB 238,	064,	000
    OrangeRed3         DB 205,	055,	000
    OrangeRed4         DB 139,	037,	000
    Red1               DB 255,	000,	000
    Red2               DB 238,	000,	000
    Red3               DB 205,	000,	000
    Red4               DB 139,	000,	000
    DeepPink1          DB 255,	020,	147
    DeepPink2          DB 238,	018,	137
    DeepPink3          DB 205,	016,	118
    DeepPink4          DB 139,	010,	080
    HotPink1           DB 255,	110,	180
    HotPink2           DB 238,	106,	167
    HotPink3           DB 205,	096,	144
    HotPink4           DB 139,	058,	098
    Pink1              DB 255,	181,	197
    Pink2              DB 238,	169,	184
    Pink3              DB 205,	145,	158
    Pink4              DB 139,	099,	108
    LightPink1         DB 255,	174,	185
    LightPink2         DB 238,	162,	173
    LightPink3         DB 205,	140,	149
    LightPink4         DB 139,	095,	101
    PaleVioletRed1     DB 255,	130,	171
    PaleVioletRed2     DB 238,	121,	159
    PaleVioletRed3     DB 205,	104,	137
    PaleVioletRed4     DB 139,	071,	093
    Maroon1            DB 255,	052,	179
    Maroon2            DB 238,	048,	167
    Maroon3            DB 205,	041,	144
    Maroon4            DB 139,	028,	098
    VioletRed1         DB 255,	062,	150
    VioletRed2         DB 238,	058,	140
    VioletRed3         DB 205,	050,	120
    VioletRed4         DB 139,	034,	082
    Magenta1           DB 255,	000,	255
    Magenta2           DB 238,	000,	238
    Magenta3           DB 205,	000,	205
    Magenta4           DB 139,	000,	139
    Orchid1            DB 255,	131,	250
    Orchid2            DB 238,	122,	233
    Orchid3            DB 205,	105,	201
    Orchid4            DB 139,	071,	137
    Plum1              DB 255,	187,	255
    Plum2              DB 238,	174,	238
    Plum3              DB 205,	150,	205
    Plum4              DB 139,	102,	139
    MediumOrchid1      DB 224,	102,	255
    MediumOrchid2      DB 209,	095,	238
    MediumOrchid3      DB 180,	082,	205
    MediumOrchid4      DB 122,	055,	139
    DarkOrchid1        DB 191,	062,	255
    DarkOrchid2        DB 178,	058,	238
    DarkOrchid3        DB 154,	050,	205
    DarkOrchid4        DB 104,	034,	139
    Purple1            DB 155,	048,	255
    Purple2            DB 145,	044,	238
    Purple3            DB 125,	038,	205
    Purple4            DB 085,	026,	139
    MediumPurple1      DB 171,	130,	255
    MediumPurple2      DB 159,	121,	238
    MediumPurple3      DB 137,	104,	205
    MediumPurple4      DB 093,	071,	139
    Thistle1           DB 255,	225,	255
    Thistle2           DB 238,	210,	238
    Thistle3           DB 205,	181,	205
    Thistle4           DB 139,	123,	139
    grey11             DB 028,	028,	028
    grey21             DB 054,	054,	054
    grey31             DB 079,	079,	079
    grey41             DB 105,	105,	105
    grey51             DB 130,	130,	130
    grey61             DB 156,	156,	156
    grey71             DB 181,	181,	181
    gray81             DB 207,	207,	207
    gray91             DB 232,	232,	232
    DarkGrey           DB 169,	169,	169
    DarkBlue           DB 000,	000,	139
    DarkCyan           DB 000,	139,	139
    DarkMagenta        DB 139,	000,	139
    DarkRed            DB 139,	000,	000
    LightGreen         DB 144,	238,	144


___TREE_DATA_END_