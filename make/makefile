#############################################
#              Makefile For TREE             #
#              Author: hyan23                #
#              Date: 2016.05.01              #
##############################################


BOOTDIR  =   ..\boot
KERDIR   =   ..\kernel
SRCDIR   =   ..\src
USRDIR   =   ..\usr
BINDIR   =   ..\bin
SETDIR   =   ..\sft

MAKE     =    make.exe
NASM     =    $(SETDIR)\nasm\nasm.exe
CC       =    $(SETDIR)\gcc\ccl.exe
AS       =    $(SETDIR)\gcc\as.exe
LD       =    $(SETDIR)\gcc\ld.exe
WR       =    $(SETDIR)\fixvhdwr0.exe

ECHO     =    echo
DEL      =    del /F
COPY     =    copy /Y


VHD      =    ..\tree\tree.vhd

LOG      =    make.log


BOOT     =    mbr.bin mbr32.bin mbrx.bin gdt.bin bits.bin LIB.bin

OBJS     =    basec.bin memory.bin loader.bin linker.bin \
	exec.bin extra.bin reserv.bin \
	int0.bin gate.bin agent.bin task0.bin task.bin \
	time.bin kbd0.bin kbd.bin mouse0.bin mouse.bin \
	graphic0.bin graphic.bin texture.bin font.bin \
	window.bin link.bin msgq.bin event.bin desktop.bin wm.bin \
	tree.bin sh.bin \
	conio.bin readisk.bin wrdisk.bin \
	string.bin math.bin rand.bin spin.bin \
	array.bin linked.bin queue.bin stack.bin

USRS     =    usr.bin debug.bin \
	calc.bin clear.bin help.bin nowtime.bin sayhello.bin whoami.bin \
	hello.bin palette.bin timer.bin counter.bin etracker.bin walk.bin


# clear log
CLEAR    =    $(ECHO). > $(LOG)
# write a blank line
WRBLK    =    $(ECHO).


default:
	$(MAKE) install

install:
	$(CLEAR)
	$(MAKE) -r TREE0.VHD
	$(MAKE) -r TREE1.VHD

	$(DEL) /S /Q ..\*.lst

clean:
	$(CLEAR)
	clean.cmd


# boot
mbr.bin : $(NASM) $(BOOTDIR)\mbr.s0
	$(NASM) $(BOOTDIR)\mbr.s0 -f bin -l $(BOOTDIR)\mbr.lst -o $(BINDIR)\mbr.bin

mbr32.bin : $(NASM) $(BOOTDIR)\mbr32.s0
	$(NASM) $(BOOTDIR)\mbr32.s0 -f bin -l $(BOOTDIR)\mbr32.lst -o $(BINDIR)\mbr32.bin

mbrx.bin : $(NASM) $(BOOTDIR)\mbrx.s0
	$(NASM) $(BOOTDIR)\mbrx.s0 -f bin -l $(BOOTDIR)\mbrx.lst -o $(BINDIR)\mbrx.bin

gdt.bin : $(NASM) $(BOOTDIR)\gdt.s0
	$(NASM) $(BOOTDIR)\gdt.s0 -f bin -l $(BOOTDIR)\gdt.lst -o $(BINDIR)\gdt.bin

bits.bin : $(NASM) $(BOOTDIR)\bits.s0
	$(NASM) $(BOOTDIR)\bits.s0 -f bin -l $(BOOTDIR)\bits.lst -o $(BINDIR)\bits.bin

LIB.bin : $(NASM) $(BOOTDIR)\LIB.s0
	$(NASM) $(BOOTDIR)\LIB.s0 -f bin -l $(BOOTDIR)\LIB.lst -o $(BINDIR)\LIB.bin


# kernel
basec.bin : $(NASM) $(KERDIR)\basec.s0
	$(NASM) $(KERDIR)\basec.s0 -f bin -l $(KERDIR)\basec.lst -o $(BINDIR)\basec.bin

memory.bin : $(NASM) $(KERDIR)\memory.s0
	$(NASM) $(KERDIR)\memory.s0 -f bin -l $(KERDIR)\memory.lst -o $(BINDIR)\memory.bin

loader.bin : $(NASM) $(KERDIR)\loader.s0
	$(NASM) $(KERDIR)\loader.s0 -f bin -l $(KERDIR)\loader.lst -o $(BINDIR)\loader.bin

linker.bin : $(NASM) $(KERDIR)\linker.s0
	$(NASM) $(KERDIR)\linker.s0 -f bin -l $(KERDIR)\linker.lst -o $(BINDIR)\linker.bin

exec.bin : $(NASM) $(KERDIR)\exec.s0
	$(NASM) $(KERDIR)\exec.s0 -f bin -l $(KERDIR)\exec.lst -o $(BINDIR)\exec.bin

extra.bin : $(NASM) $(KERDIR)\extra.s0
	$(NASM) $(KERDIR)\extra.s0 -f bin -l $(KERDIR)\extra.lst -o $(BINDIR)\extra.bin

reserv.bin : $(NASM) $(KERDIR)\reserv.s0
	$(NASM) $(KERDIR)\reserv.s0 -f bin -l $(KERDIR)\reserv.lst -o $(BINDIR)\reserv.bin


int0.bin : $(NASM) $(KERDIR)\int0.ss
	$(NASM) $(KERDIR)\int0.ss -f bin -l $(KERDIR)\int0.lst -o $(BINDIR)\int0.bin

gate.bin : $(NASM) $(KERDIR)\gate.ss
	$(NASM) $(KERDIR)\gate.ss -f bin -l $(KERDIR)\gate.lst -o $(BINDIR)\gate.bin

agent.bin : $(NASM) $(KERDIR)\agent.ss
	$(NASM) $(KERDIR)\agent.ss -f bin -l $(KERDIR)\agent.lst -o $(BINDIR)\agent.bin

task0.bin : $(NASM) $(KERDIR)\task0.ss
	$(NASM) $(KERDIR)\task0.ss -f bin -l $(KERDIR)\task0.lst -o $(BINDIR)\task0.bin

task.bin : $(NASM) $(KERDIR)\task.ss
	$(NASM) $(KERDIR)\task.ss -f bin -l $(KERDIR)\task.lst -o $(BINDIR)\task.bin


# driver
time.bin: $(NASM) $(KERDIR)\time.ss
	$(NASM) $(KERDIR)\time.ss -f bin -l $(KERDIR)\time.lst -o $(BINDIR)\time.bin

kbd0.bin: $(NASM) $(KERDIR)\kbd0.ss
	$(NASM) $(KERDIR)\kbd0.ss -f bin -l $(KERDIR)\kbd0.lst -o $(BINDIR)\kbd0.bin

kbd.bin: $(NASM) $(KERDIR)\kbd.ss
	$(NASM) $(KERDIR)\kbd.ss -f bin -l $(KERDIR)\kbd.lst -o $(BINDIR)\kbd.bin

mouse0.bin: $(NASM) $(KERDIR)\mouse0.ss
	$(NASM) $(KERDIR)\mouse0.ss -f bin -l $(KERDIR)\mouse0.lst -o $(BINDIR)\mouse0.bin

mouse.bin: $(NASM) $(KERDIR)\mouse.ss
	$(NASM) $(KERDIR)\mouse.ss -f bin -l $(KERDIR)\mouse.lst -o $(BINDIR)\mouse.bin


# graphic
graphic0.bin: $(NASM) $(KERDIR)\graphic\graphic0.ss
	$(NASM) $(KERDIR)\graphic\graphic0.ss -f bin -l $(KERDIR)\graphic\graphic0.lst -o $(BINDIR)\graphic0.bin

graphic.bin: $(NASM) $(KERDIR)\graphic\graphic.ss
	$(NASM) $(KERDIR)\graphic\graphic.ss -f bin -l $(KERDIR)\graphic\graphic.lst -o $(BINDIR)\graphic.bin

texture.bin: $(NASM) $(KERDIR)\graphic\texture.ss
	$(NASM) $(KERDIR)\graphic\texture.ss -f bin -l $(KERDIR)\graphic\texture.lst -o $(BINDIR)\texture.bin

font.bin: $(NASM) $(KERDIR)\graphic\font.ss
	$(NASM) $(KERDIR)\graphic\font.ss -f bin -l $(KERDIR)\graphic\font.lst -o $(BINDIR)\font.bin


# wnd
window.bin: $(NASM) $(KERDIR)\wnd\window.ss
	$(NASM) $(KERDIR)\wnd\window.ss -f bin -l $(KERDIR)\wnd\window.lst -o $(BINDIR)\window.bin

link.bin: $(NASM) $(KERDIR)\wnd\link.ss
	$(NASM) $(KERDIR)\wnd\link.ss -f bin -l $(KERDIR)\wnd\link.lst -o $(BINDIR)\link.bin

msgq.bin: $(NASM) $(KERDIR)\wnd\msgq.ss
	$(NASM) $(KERDIR)\wnd\msgq.ss -f bin -l $(KERDIR)\wnd\msgq.lst -o $(BINDIR)\msgq.bin

event.bin: $(NASM) $(KERDIR)\wnd\event.ss
	$(NASM) $(KERDIR)\wnd\event.ss -f bin -l $(KERDIR)\wnd\event.lst -o $(BINDIR)\event.bin

desktop.bin: $(NASM) $(KERDIR)\wnd\desktop.ss
	$(NASM) $(KERDIR)\wnd\desktop.ss -f bin -l $(KERDIR)\wnd\desktop.lst -o $(BINDIR)\desktop.bin

wm.bin: $(NASM) $(KERDIR)\wnd\wm.ss
	$(NASM) $(KERDIR)\wnd\wm.ss -f bin -l $(KERDIR)\wnd\wm.lst -o $(BINDIR)\wm.bin


################

tree.bin : $(NASM) $(KERDIR)\tree.ss
	$(NASM) $(KERDIR)\tree.ss -f bin -l $(KERDIR)\tree.lst -o $(BINDIR)\tree.bin

sh.bin : $(NASM) $(KERDIR)\sh.ss
	$(NASM) $(KERDIR)\sh.ss -f bin -l $(KERDIR)\sh.lst -o $(BINDIR)\sh.bin


# io
conio.bin: $(NASM) $(SRCDIR)\nasm\io\conio.ss
	$(NASM) $(SRCDIR)\nasm\io\conio.ss -f bin -l $(SRCDIR)\nasm\io\conio.lst -o $(BINDIR)\conio.bin

readisk.bin: $(NASM) $(SRCDIR)\nasm\io\readisk.ss
	$(NASM) $(SRCDIR)\nasm\io\readisk.ss -f bin -l $(SRCDIR)\nasm\io\readisk.lst -o $(BINDIR)\readisk.bin

wrdisk.bin: $(NASM) $(SRCDIR)\nasm\io\wrdisk.ss
	$(NASM) $(SRCDIR)\nasm\io\wrdisk.ss -f bin -l $(SRCDIR)\nasm\io\wrdisk.lst -o $(BINDIR)\wrdisk.bin


# sys


# utility
string.bin: $(NASM) $(SRCDIR)\nasm\utility\string.ss
	$(NASM) $(SRCDIR)\nasm\utility\string.ss -f bin -l $(SRCDIR)\nasm\utility\string.lst -o $(BINDIR)\string.bin

math.bin: $(NASM) $(SRCDIR)\nasm\utility\math.ss
	$(NASM) $(SRCDIR)\nasm\utility\math.ss -f bin -l $(SRCDIR)\nasm\utility\math.lst -o $(BINDIR)\math.bin

rand.bin: $(NASM) $(SRCDIR)\nasm\utility\rand.ss
	$(NASM) $(SRCDIR)\nasm\utility\rand.ss -f bin -l $(SRCDIR)\nasm\utility\rand.lst -o $(BINDIR)\rand.bin

spin.bin: $(NASM) $(SRCDIR)\nasm\utility\spin.ss
	$(NASM) $(SRCDIR)\nasm\utility\spin.ss -f bin -l $(SRCDIR)\nasm\utility\spin.lst -o $(BINDIR)\spin.bin


# adt
array.bin: $(NASM) $(SRCDIR)\nasm\utility\array.ss
	$(NASM) $(SRCDIR)\nasm\utility\array.ss -f bin -l $(SRCDIR)\nasm\utility\array.lst -o $(BINDIR)\array.bin

linked.bin: $(NASM) $(SRCDIR)\nasm\utility\linked.ss
	$(NASM) $(SRCDIR)\nasm\utility\linked.ss -f bin -l $(SRCDIR)\nasm\utility\linked.lst -o $(BINDIR)\linked.bin

queue.bin: $(NASM) $(SRCDIR)\nasm\utility\queue.ss
	$(NASM) $(SRCDIR)\nasm\utility\queue.ss -f bin -l $(SRCDIR)\nasm\utility\queue.lst -o $(BINDIR)\queue.bin

stack.bin: $(NASM) $(SRCDIR)\nasm\utility\stack.ss
	$(NASM) $(SRCDIR)\nasm\utility\stack.ss -f bin -l $(SRCDIR)\nasm\utility\stack.lst -o $(BINDIR)\stack.bin


# usr
usr.bin : $(NASM) $(USRDIR)\usr.ss
	$(NASM) $(USRDIR)\usr.ss -f bin -l $(USRDIR)\usr.lst -o $(BINDIR)\usr.bin

debug.bin : $(NASM) $(USRDIR)\debug.ss
	$(NASM) $(USRDIR)\debug.ss -f bin -l $(USRDIR)\debug.lst -o $(BINDIR)\debug.bin


calc.bin : $(NASM) $(USRDIR)\calc.ss
	$(NASM) $(USRDIR)\calc.ss -f bin -l $(USRDIR)\calc.lst -o $(BINDIR)\calc.bin

clear.bin : $(NASM) $(USRDIR)\clear.ss
	$(NASM) $(USRDIR)\clear.ss -f bin -l $(USRDIR)\clear.lst -o $(BINDIR)\clear.bin

help.bin : $(NASM) $(USRDIR)\help.ss
	$(NASM) $(USRDIR)\help.ss -f bin -l $(USRDIR)\help.lst -o $(BINDIR)\help.bin

nowtime.bin : $(NASM) $(USRDIR)\nowtime.ss
	$(NASM) $(USRDIR)\nowtime.ss -f bin -l $(USRDIR)\nowtime.lst -o $(BINDIR)\nowtime.bin

sayhello.bin : $(NASM) $(USRDIR)\sayhello.ss
	$(NASM) $(USRDIR)\sayhello.ss -f bin -l $(USRDIR)\sayhello.lst -o $(BINDIR)\sayhello.bin

whoami.bin : $(NASM) $(USRDIR)\whoami.ss
	$(NASM) $(USRDIR)\whoami.ss -f bin -l $(USRDIR)\whoami.lst -o $(BINDIR)\whoami.bin

# wnd
hello.bin : $(NASM) $(USRDIR)\wnd\hello.ss
	$(NASM) $(USRDIR)\wnd\hello.ss -f bin -l $(USRDIR)\wnd\hello.lst -o $(BINDIR)\hello.bin

palette.bin : $(NASM) $(USRDIR)\wnd\palette.ss
	$(NASM) $(USRDIR)\wnd\palette.ss -f bin -l $(USRDIR)\wnd\palette.lst -o $(BINDIR)\palette.bin

timer.bin : $(NASM) $(USRDIR)\wnd\timer.ss
	$(NASM) $(USRDIR)\wnd\timer.ss -f bin -l $(USRDIR)\wnd\timer.lst -o $(BINDIR)\timer.bin

counter.bin : $(NASM) $(USRDIR)\wnd\counter.ss
	$(NASM) $(USRDIR)\wnd\counter.ss -f bin -l $(USRDIR)\wnd\counter.lst -o $(BINDIR)\counter.bin

etracker.bin : $(NASM) $(USRDIR)\wnd\etracker.ss
	$(NASM) $(USRDIR)\wnd\etracker.ss -f bin -l $(USRDIR)\wnd\etracker.lst -o $(BINDIR)\etracker.bin

walk.bin : $(NASM) $(USRDIR)\wnd\walk.ss
	$(NASM) $(USRDIR)\wnd\walk.ss -f bin -l $(USRDIR)\wnd\walk.lst -o $(BINDIR)\walk.bin


# write
TREE0.VHD : $(WR) $(VHD) $(BOOT) $(OBJS)
	@$(ECHO) "%DATE% %TIME%"

# kernel
	@$(WR) $(VHD) $(BINDIR)\mbr.bin 0 -skip

	@$(WR) $(VHD) $(BINDIR)\mbr32.bin 1 -skip

	@$(WR) $(VHD) $(BINDIR)\mbrx.bin 2 -skip


	@$(WR) $(VHD) $(BINDIR)\basec.bin 10 -skip

	@$(WR) $(VHD) $(BINDIR)\memory.bin 20 -skip

	@$(WR) $(VHD) $(BINDIR)\loader.bin 30 -skip

	@$(WR) $(VHD) $(BINDIR)\linker.bin 40 -skip

	@$(WR) $(VHD) $(BINDIR)\exec.bin 50 -skip

	@$(WR) $(VHD) $(BINDIR)\extra.bin 60 -skip

	@$(WR) $(VHD) $(BINDIR)\reserv.bin 70 -skip


	@$(WR) $(VHD) $(BINDIR)\int0.bin 100 -skip

	@$(WR) $(VHD) $(BINDIR)\gate.bin 110 -skip

	@$(WR) $(VHD) $(BINDIR)\agent.bin 120 -skip

	@$(WR) $(VHD) $(BINDIR)\task0.bin 130 -skip

	@$(WR) $(VHD) $(BINDIR)\task.bin 140 -skip


	@$(WR) $(VHD) $(BINDIR)\time.bin 200 -skip

	@$(WR) $(VHD) $(BINDIR)\kbd0.bin 210 -skip

	@$(WR) $(VHD) $(BINDIR)\kbd.bin 220 -skip

	@$(WR) $(VHD) $(BINDIR)\mouse0.bin 230 -skip

	@$(WR) $(VHD) $(BINDIR)\mouse.bin 240 -skip


	@$(WR) $(VHD) $(BINDIR)\graphic0.bin 300 -skip

	@$(WR) $(VHD) $(BINDIR)\graphic.bin 310 -skip

	@$(WR) $(VHD) $(BINDIR)\texture.bin 320 -skip

	@$(WR) $(VHD) $(BINDIR)\font.bin 330 -skip


	@$(WR) $(VHD) $(BINDIR)\window.bin 400 -skip

	@$(WR) $(VHD) $(BINDIR)\link.bin 410 -skip

	@$(WR) $(VHD) $(BINDIR)\msgq.bin 420 -skip

	@$(WR) $(VHD) $(BINDIR)\event.bin 430 -skip

	@$(WR) $(VHD) $(BINDIR)\desktop.bin 440 -skip

	@$(WR) $(VHD) $(BINDIR)\wm.bin 460 -skip


	@$(WR) $(VHD) $(BINDIR)\tree.bin 1100 -skip

	@$(WR) $(VHD) $(BINDIR)\sh.bin 1110 -skip


	@$(WR) $(VHD) $(BINDIR)\gdt.bin 500 -skip

	@$(WR) $(VHD) $(BINDIR)\bits.bin 756 -skip

	@$(WR) $(VHD) $(BINDIR)\LIB.bin 884 -skip


	@$(WR) $(VHD) $(BINDIR)\conio.bin 1200 -skip

	@$(WR) $(VHD) $(BINDIR)\readisk.bin 1210 -skip

	@$(WR) $(VHD) $(BINDIR)\wrdisk.bin 1220 -skip


	@$(WR) $(VHD) $(BINDIR)\string.bin 1300 -skip

	@$(WR) $(VHD) $(BINDIR)\math.bin 1310 -skip

	@$(WR) $(VHD) $(BINDIR)\rand.bin 1320 -skip

	@$(WR) $(VHD) $(BINDIR)\spin.bin 1330 -skip


	@$(WR) $(VHD) $(BINDIR)\array.bin 1400 -skip

	@$(WR) $(VHD) $(BINDIR)\linked.bin 1410 -skip

	@$(WR) $(VHD) $(BINDIR)\queue.bin 1420 -skip

	@$(WR) $(VHD) $(BINDIR)\stack.bin 1430 -skip



TREE1.VHD: $(WR) $(VHD) $(USRS)

# usr
	@$(WR) $(VHD) $(BINDIR)\usr.bin 2000 -skip

	@$(WR) $(VHD) $(BINDIR)\debug.bin 2010 -skip

	@$(WR) $(VHD) $(BINDIR)\calc.bin 2020 -skip

	@$(WR) $(VHD) $(BINDIR)\clear.bin 2030 -skip

	@$(WR) $(VHD) $(BINDIR)\help.bin 2040 -skip

	@$(WR) $(VHD) $(BINDIR)\nowtime.bin 2050 -skip

	@$(WR) $(VHD) $(BINDIR)\sayhello.bin 2060 -skip

	@$(WR) $(VHD) $(BINDIR)\whoami.bin 2070 -skip

# wnd
	@$(WR) $(VHD) $(BINDIR)\hello.bin 3000 -skip

	@$(WR) $(VHD) $(BINDIR)\palette.bin 3020 -skip

	@$(WR) $(VHD) $(BINDIR)\timer.bin 3040 -skip

	@$(WR) $(VHD) $(BINDIR)\counter.bin 3060 -skip

	@$(WR) $(VHD) $(BINDIR)\etracker.bin 3080 -skip

	@$(WR) $(VHD) $(BINDIR)\walk.bin 3100 -skip

