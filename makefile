#! make -f
#
# makefile - start
#


# option
#

# directory
#

# source file directory
SRCDIR			=	sources

# include file directory
INCDIR			=	sources

# object file directory
OBJDIR			=	objects

# binary file directory
BINDIR			=	bin

# output file directory
OUTDIR			=	rom

# tool directory
TOOLDIR			=	tools

# vpath search directories
VPATH			=	$(SRCDIR):$(INCDIR):$(OBJDIR):$(BINDIR)

# assembler
#

# assembler command
AS				=	sdasz80

# assembler flags
ASFLAGS			=	-ls -I$(INCDIR) -I.

# c compiler
#

# c compiler command
CC				=	sdcc

# c compiler flags
CFLAGS			=	-mz80 --opt-code-speed -I$(INCDIR) -I.

# linker
#

# linker command
LD				=	sdcc

# linker flags
LDFLAGS			=	-mz80 --no-std-crt0 --nostdinc --nostdlib --code-loc 0x4020 --data-loc 0xc000

# suffix rules
#
.SUFFIXES:			.s .c .rel

# assembler source suffix
.s.rel:
	$(AS) $(ASFLAGS) -o $(OBJDIR)/$@ $<

# c source suffix
.c.rel:
	$(CC) $(CFLAGS) -o $(OBJDIR)/$@ -c $<

# project files
#

# target name
TARGET			=	ACEGUN

# assembler source files
ASSRCS			=	crt0.s \
					main.s System.s \
					Sound.s Math.s \
					App.s \
					Title.s \
					Game.s Player.s Generator.s Enemy.s Back.s Bomb.s \
					pattern.s buster.s coach-0.s coach-1.s logo.s

# c source files
CSRCS			=	

# object files
OBJS			=	$(ASSRCS:.s=.rel) $(CSRCS:.c=.rel)


# build project target
#
$(TARGET).com:		$(OBJS)
	$(LD) $(LDFLAGS) -o $(BINDIR)/$(TARGET).ihx $(foreach file,$(OBJS),$(OBJDIR)/$(file))
	$(TOOLDIR)/ihx2rom32k -o $(OUTDIR)/$(TARGET).ROM $(BINDIR)/$(TARGET).ihx

# clean project
#
clean:
	@rm -f $(OBJDIR)/*
	@rm -f $(BINDIR)/*
##	@rm -f makefile.depend

# build depend file
#
depend:
##	ifneq ($(strip $(CSRCS)),)
##		$(CC) $(CFLAGS) -MM $(foreach file,$(CSRCS),$(SRCDIR)/$(file)) > makefile.depend
##	endif

# build resource file
#
resource:
#	@$(TOOLDIR)/bin2s -n patternTable -o sources/pattern.s resources/pattern.chr
	@$(TOOLDIR)/image2pattern -o sources/pattern.s -n patternTable -b 0x20 resources/picture/pattern.png
	@$(TOOLDIR)/image2screen1 -o sources/buster.s -n buster -b 0x20 resources/picture/buster.png
	@$(TOOLDIR)/image2screen1 -o sources/coach-0.s -n coach0 -b 0x80 resources/picture/coach-0.png
	@$(TOOLDIR)/image2screen1 -o sources/coach-1.s -n coach1 -b 0x80 resources/picture/coach-1.png
	@$(TOOLDIR)/image2screen1 -o sources/logo.s -n logo -b 0x80 resources/picture/logo.png

# build tools
#
tool:
	@gcc -o $(TOOLDIR)/bin2s $(TOOLDIR)/bin2s.cpp
	@gcc -o $(TOOLDIR)/ihx2bload $(TOOLDIR)/ihx2bload.cpp
	@gcc -o $(TOOLDIR)/ihx2rom32k $(TOOLDIR)/ihx2rom32k.cpp
	@g++ -o $(TOOLDIR)/image2pattern `sdl2-config --cflags --libs` -lSDL2_image $(TOOLDIR)/image2pattern.cpp
	@g++ -o $(TOOLDIR)/image2screen1 `sdl2-config --cflags --libs` -lSDL2_image $(TOOLDIR)/image2screen1.cpp

# phony targets
#
.PHONY:				clean depend

# include depend file
#
-include makefile.depend


# makefile - end