########################################################################
#
# Arduino command line tools Makefile
# System part (i.e. project independent)
#
# Copyright (C) 2010,2011,2012 Martin Oldfield <m@mjo.tc>, based on
# work that is copyright Nicholas Zambetti, David A. Mellis & Hernando
# Barragan.
# 
# This file is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of the
# License, or (at your option) any later version.
#
# Adapted from Arduino 0011 Makefile by M J Oldfield
#
# Original Arduino adaptation by mellis, eighthave, oli.keller
#
# Version 0.1  17.ii.2009  M J Oldfield
#
#         0.2  22.ii.2009  M J Oldfield
#                          - fixes so that the Makefile actually works!
#                          - support for uploading via ISP
#                          - orthogonal choices of using the Arduino for
#                            tools, libraries and uploading
#
#         0.3  21.v.2010   M J Oldfield
#                          - added proper license statement
#                          - added code from Philip Hands to reset
#                            Arduino prior to upload
#
#         0.4  25.v.2010   M J Oldfield
#                          - tweaked reset target on Philip Hands' advice
#
#         0.5  23.iii.2011 Stefan Tomanek
#                          - added ad-hoc library building
#              17.v.2011   M J Oldfield
#                          - grabbed said version from Ubuntu
#
#         0.6  22.vi.2011  M J Oldfield
#                          - added ard-parse-boards supports
#                          - added -lc to linker opts, 
#                            on Fabien Le Lez's advice
#
#         0.7  12.vii.2011 M J Oldfield
#                          - moved -lm to the end of linker opts,
#	                     to solve Frank Knopf's problem;
#                          - added -F to stty opts: Craig Hollabaugh 
#	                     reckons it's good for Ubuntu
#
#         0.8  12.ii.2012  M J Oldfield
#                          - Patches for Arduino 1.0 IDE:
#                              support .ino files;
#                              handle board 'variants';
#                              tweaked compile flags.
#                          - Build a library from all the system
#                            supplied code rather than linking the .o
#                            files directly.
#                          - Let TARGET default to current directory
#			     as per Daniele Vergini's patch.
#                          - Add support for .c files in system
#                            libraries: Dirk-Willem van Gulik and Evan
#                            Goldenberg both reported this and
#                            provided patches in the same spirit.
#
########################################################################
#
# STANDARD ARDUINO WORKFLOW
#
# Given a normal sketch directory, all you need to do is to create
# a small Makefile which defines a few things, and then includes this one.
#
# For example:
#
#       ARDUINO_DIR  = /usr/share/arduino
#
#       TARGET       = CLItest
#       ARDUINO_LIBS = Ethernet Ethernet/utility SPI
#
#       BOARD_TAG    = uno
#       ARDUINO_PORT = /dev/cu.usb*
#
#       include /usr/local/share/Arduino.mk
#
# Hopefully these will be self-explanatory but in case they're not:
#
#    ARDUINO_DIR  - Where the Arduino software has been unpacked
#
#    TARGET       - The basename used for the final files. Canonically
#                   this would match the .pde file, but it's not needed
#                   here: you could always set it to xx if you wanted!
#
#    ARDUINO_LIBS - A list of any libraries used by the sketch (we
#                   assume these are in
#                   $(ARDUINO_DIR)/hardware/libraries 
#
#    ARDUINO_PORT - The port where the Arduino can be found (only needed
#                   when uploading
#
#    BOARD_TAG    - The ard-parse-boards tag for the board e.g. uno or mega
#                   'make show_boards' shows a list
#
# You might also want to specify these, but normally they'll be read from the
# boards.txt file i.e. implied by BOARD_TAG
#
#    MCU,F_CPU    - The target processor description
#
# Once this file has been created the typical workflow is just
#
#   $ make upload
#
# All of the object files are created in the build-cli subdirectory
# All sources should be in the current directory and can include:
#  - at most one .pde or .ino file which will be treated as C++ after
#    the standard Arduino header and footer have been affixed.
#  - any number of .c, .cpp, .s and .h files
#
# Included libraries are built in the build-cli/libs subdirectory.
#
# Besides make upload you can also
#   make             - no upload
#   make clean       - remove all our dependencies
#   make depends     - update dependencies
#   make reset       - reset the Arduino by tickling DTR on the serial port
#   make raw_upload  - upload without first resetting
#   make show_boards - list all the boards defined in boards.txt
#
########################################################################
#
# ARDUINO WITH OTHER TOOLS
#
# If the tools aren't in the Arduino distribution, then you need to 
# specify their location:
#
#    AVR_TOOLS_PATH = /usr/bin
#    AVRDUDE_CONF   = /etc/avrdude/avrdude.conf
#
########################################################################
#
# ARDUINO WITH ISP
#
# You need to specify some details of your ISP programmer and might
# also need to specify the fuse values:
#
#     ISP_PROG	   = -c stk500v2
#     ISP_PORT     = /dev/ttyACM0
#
# You might also need to set the fuse bits, but typically they'll be
# read from boards.txt, based on the BOARD_TAG variable:
#     
#     ISP_LOCK_FUSE_PRE  = 0x3f
#     ISP_LOCK_FUSE_POST = 0xcf
#     ISP_HIGH_FUSE      = 0xdf
#     ISP_LOW_FUSE       = 0xff
#     ISP_EXT_FUSE       = 0x01
#
# I think the fuses here are fine for uploading to the ATmega168
# without bootloader.
# 
# To actually do this upload use the ispload target:
#
#    make ispload
#
#
########################################################################

########################################################################
# 
# Default TARGET to cwd (ex Daniele Vergini)
ifndef TARGET
TARGET  = $(notdir $(CURDIR))
endif

########################################################################
#
# Arduino version number
ifndef ARDUINO_VERSION
ARDUINO_VERSION = 100
endif

#
# Some paths
#

ifneq (ARDUINO_DIR,)

ifndef AVR_TOOLS_PATH
AVR_TOOLS_PATH    = /usr/bin
endif

ifndef ARDUINO_ETC_PATH
ARDUINO_ETC_PATH  = /etc
endif

ifndef AVRDUDE_CONF
AVRDUDE_CONF     = $(ARDUINO_ETC_PATH)/avrdude.conf
endif

ARDUINO_LIB_PATH  = $(ARDUINO_DIR)/libraries
ARDUINO_CORE_PATH = $(ARDUINO_DIR)/hardware/arduino/cores/arduino
ARDUINO_VAR_PATH  = $(ARDUINO_DIR)/hardware/arduino/variants

endif

########################################################################
# COM PORT Selection. 
# Wensing (9/26/2012): Uses Mike Veriers com port finder program to look up 
#                      the COM port based on vendor and product ID
ifndef ARD_PORT
ARD_PORT = $(shell $(PORT_FINDER) --vendorid=$(VENDOR_ID) --productid=$(PRODUCT_ID))
endif


########################################################################
# boards.txt parsing
#
ifndef BOARD_TAG
BOARD_TAG   = uno
endif

ifndef BOARDS_TXT
BOARDS_TXT  = $(ARDUINO_DIR)/hardware/arduino/boards.txt
endif

###########################################################################################################
# Wensing(9/26/2012): The Next number of lines were in the original makefile, but are ommitted here
#                     since we don't have pearl for the parse boards. All options (MCU, F_CPU) can be
#                     looked up manually in the boards.txt file
###########################################################################################################

#ifndef PARSE_BOARD
#PARSE_BOARD = $(ARDUINO_DIR)/ard-parse-boards --boards_txt=$(BOARDS_TXT)
#endif
#
# Which variant ? This affects the include path
#ifndef VARIANT
#VARIANT = $(shell $(PARSE_BOARD) $(BOARD_TAG) build.variant)
#endif
#
# processor stuff
#ifndef MCU
#MCU   = $(shell $(PARSE_BOARD) $(BOARD_TAG) build.mcu)
#endif
#
#ifndef F_CPU
#F_CPU = $(shell $(PARSE_BOARD) $(BOARD_TAG) build.f_cpu)
#endif
#
# normal programming info
#ifndef AVRDUDE_ARD_PROGRAMMER
#AVRDUDE_ARD_PROGRAMMER = $(shell $(PARSE_BOARD) $(BOARD_TAG) upload.protocol)
#endif
#
#ifndef AVRDUDE_ARD_BAUDRATE
#AVRDUDE_ARD_BAUDRATE   = $(shell $(PARSE_BOARD) $(BOARD_TAG) upload.speed)
#endif
#
# fuses if you're using e.g. ISP
#ifndef ISP_LOCK_FUSE_PRE
#ISP_LOCK_FUSE_PRE  = $(shell $(PARSE_BOARD) $(BOARD_TAG) bootloader.unlock_bits)
#endif
#
#ifndef ISP_LOCK_FUSE_POST
#ISP_LOCK_FUSE_POST = $(shell $(PARSE_BOARD) $(BOARD_TAG) bootloader.lock_bits)
#endif
#
#ifndef ISP_HIGH_FUSE
#ISP_HIGH_FUSE      = $(shell $(PARSE_BOARD) $(BOARD_TAG) bootloader.high_fuses)
#endif
#
#ifndef ISP_LOW_FUSE
#ISP_LOW_FUSE       = $(shell $(PARSE_BOARD) $(BOARD_TAG) bootloader.low_fuses)
#endif
#
#ifndef ISP_EXT_FUSE
#ISP_EXT_FUSE       = $(shell $(PARSE_BOARD) $(BOARD_TAG) bootloader.extended_fuses)
#endif

# Everything gets built in here
OBJDIR  	  = build

##############################################################################
# Local sources
#
# Wensing (9/26/2012): For non-full builds, the lines below only 
#                      grab the c and cpp sources that are listed in the 
#                      projects ".files" file. EGREP does a regexp match to find
#                      all lines of $(TARGET).files that end in .c or .cpp

ifdef FULL_BUILD
LOCAL_C_SRCS    = $(wildcard *.c)
LOCAL_CPP_SRCS  = $(wildcard *.cpp)
else
EGREP   = $(ARDUINO_DIR)\hardware\tools\avr\utils\bin\egrep
LOCAL_CPP_SRCS  = $(shell $(EGREP) c$$  $(TARGET).files)
LOCAL_CPP_SRCS  = $(shell $(EGREP) cpp$$  $(TARGET).files)
endif

LOCAL_OBJ_FILES = $(LOCAL_C_SRCS:.c=.o)   $(LOCAL_CPP_SRCS:.cpp=.o)


#LOCAL_CC_SRCS   = $(wildcard *.cc)
#LOCAL_PDE_SRCS  = $(wildcard *.pde)
#LOCAL_INO_SRCS  = $(wildcard *.ino)
#LOCAL_AS_SRCS   = $(wildcard *.S)

# Potential additional local objs
#		$(LOCAL_CC_SRCS:.cc=.o)   $(LOCAL_PDE_SRCS:.pde=.o) \
#		$(LOCAL_INO_SRCS:.ino=.o) $(LOCAL_AS_SRCS:.S=.o)

LOCAL_OBJS      = $(patsubst %,$(OBJDIR)/%,$(LOCAL_OBJ_FILES))

# Dependency files
# Wensing (9/26/2012): These dependencies are annoying. We'll just remake the student's .c and .cpp
#                      files everytime since this is a small project
#DEPS            = $(LOCAL_OBJS:.o=.d)

# core sources
ifeq ($(strip $(NO_CORE)),)
ifdef ARDUINO_CORE_PATH
CORE_C_SRCS     = $(wildcard $(ARDUINO_CORE_PATH)/*.c)
# Wensing (9/26/2012): strip out the main, since we implement our own
CORE_CPP_SRCS_INIT   = $(wildcard $(ARDUINO_CORE_PATH)/*.cpp)
CORE_CPP_SRCS   = $(patsubst $(ARDUINO_CORE_PATH)/main.cpp,,$(CORE_CPP_SRCS_INIT))
CORE_OBJ_FILES  = $(CORE_C_SRCS:.c=.o) $(CORE_CPP_SRCS:.cpp=.o)
CORE_OBJS       = $(patsubst $(ARDUINO_CORE_PATH)/%,  \
			$(OBJDIR)/%,$(CORE_OBJ_FILES))

# Wensing (9/26/2012): This kills the dependencies on these files, so we don't try to
#                      build them if not full building
ifndef FULL_BUILD
CORE_OBJS =
endif

endif
endif

# Wensing (9/26/2012): New definitions for the FEH Core. Only used in the full build
FEH_CORE_CPP_SRCS = $(wildcard $(FEH_CORE_PATH)/*.cpp)
FEH_CORE_OBJ_FILES = $(FEH_CORE_CPP_SRCS:.cpp=.o)
FEH_CORE_OBJS       = $(patsubst $(FEH_CORE_PATH)/%,  \
			$(OBJDIR)/%,$(FEH_CORE_OBJ_FILES))
FEH_CORE_LIB = $(FEH_CORE_PATH)/libfeharduino.a
CRT_LIB = $(FEH_CORE_PATH)/crtm328p_mod.o
CRT_S = $(FEH_CORE_PATH)/crt/gcrt1.S

# Wensing (9/26/2012): This kills the dependencies on these files, so we don't try to
#                      build them if not fullly building
ifndef FULL_BUILD
FEH_CORE_OBJS =
endif



########################################################################
# Rules for making stuff
#

# The name of the main targets
TARGET_HEX = $(OBJDIR)/$(TARGET).hex
TARGET_ELF = $(OBJDIR)/$(TARGET).elf
TARGETS    = $(OBJDIR)/$(TARGET).*
CORE_LIB   = $(OBJDIR)/libcore.a

# A list of dependencies
DEP_FILE   = $(OBJDIR)/depends.mk

# Names of executables
CC      = $(AVR_TOOLS_PATH)/avr-gcc
LD	= $(AVR_TOOLS_PATH)/avr-gcc
CXX     = $(AVR_TOOLS_PATH)/avr-g++
OBJCOPY = $(AVR_TOOLS_PATH)/avr-objcopy
OBJDUMP = $(AVR_TOOLS_PATH)/avr-objdump
AR      = $(AVR_TOOLS_PATH)/avr-ar
SIZE    = $(AVR_TOOLS_PATH)/avr-size
NM      = $(AVR_TOOLS_PATH)/avr-nm
REMOVE  = rm -f
MV      = mv -f
MKDIR     = $(ARDUINO_DIR)\hardware\tools\avr\utils\bin\mkdir
CAT     = $(ARDUINO_DIR)\hardware\tools\avr\utils\bin\cat
ECHO    = $(ARDUINO_DIR)\hardware\tools\avr\utils\bin\echo


# General arguments
SYS_LIBS      = $(patsubst %,$(ARDUINO_LIB_PATH)/%,$(ARDUINO_LIBS))
SYS_INCLUDES  = $(patsubst %,-I%,$(SYS_LIBS))
LIB_C_SRCS    = $(wildcard $(patsubst %,%/*.c,$(SYS_LIBS)))
LIB_CPP_SRCS  = $(wildcard $(patsubst %,%/*.cpp,$(SYS_LIBS)))
LIB_OBJS      = $(patsubst $(ARDUINO_LIB_PATH)/%.c,$(OBJDIR)/libs/%.o,$(LIB_C_SRCS)) \
		$(patsubst $(ARDUINO_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.o,$(LIB_CPP_SRCS))

# Wensing (9/26/2012): This kills the dependencies on these files, so we don't try to
#                      build them if not fully building
ifndef FULL_BUILD
LIB_OBJS =
endif


# Wensing (0/26/2012): Modified to include FEH headers
CPPFLAGS      = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -DARDUINO=$(ARDUINO_VERSION) \
			-I. -I'$(ARDUINO_CORE_PATH)' -I'$(ARDUINO_VAR_PATH)/$(VARIANT)' \
			$(SYS_INCLUDES) -g -Os -w -Wall \
			-ffunction-sections -fdata-sections -I $(FEH_CORE_PATH)
CFLAGS        = -std=gnu99
CXXFLAGS      = -fno-exceptions
ASFLAGS       = -mmcu=$(MCU) -I. -x assembler-with-cpp

# Wensing (9/26/2012): printf_flt library allows printing of floats
LDFLAGS       = -mmcu=$(MCU) -Wl,--gc-sections -Wl,-u,vfprintf -lprintf_flt -Os 


# Implicit rules for building everything (needed to get everything in
# the right directory)
#
# Rather than mess around with VPATH there are quasi-duplicate rules
# here for building e.g. a system C++ file and a local C++
# file. Besides making things simpler now, this would also make it
# easy to change the build options in future

# library sources
$(OBJDIR)/libs/%.o: $(ARDUINO_LIB_PATH)/%.c
	mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/libs/%.o: $(ARDUINO_LIB_PATH)/%.cpp
	mkdir -p $(dir $@)
	$(CC) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# normal local sources
# .o rules are for objects, .d for dependency tracking
# there seems to be an awful lot of duplication here!!!
$(OBJDIR)/%.o: %.c
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: %.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# Wensing (9/26/2012): Removing dependency compilation
#$(OBJDIR)/%.d: %.c
#	$(CC) -MM $(CPPFLAGS) $(CFLAGS) $< -MF $@ -MT $(@:.d=.o)
#
#$(OBJDIR)/%.d: %.cpp
#	$(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) $< -MF $@ -MT $(@:.d=.o)
#

# Wensing (9/26/2012): Superfluous compatibility removed
#$(OBJDIR)/%.o: %.cc
#	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@
#
#$(OBJDIR)/%.o: %.S
#	$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< -o $@
#
#$(OBJDIR)/%.o: %.s
#	$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< -o $@
#
#$(OBJDIR)/%.d: %.cc
#	$(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) $< -MF $@ -MT $(@:.d=.o)
#
#$(OBJDIR)/%.d: %.S
#	$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.o)
#
#$(OBJDIR)/%.d: %.s
#	$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.o)
#
# the pde -> cpp -> o file
#$(OBJDIR)/%.cpp: %.pde
#	$(ECHO) '#include "WProgram.h"' > $@
#	$(CAT)  $< >> $@
#
# the ino -> cpp -> o file
#$(OBJDIR)/%.cpp: %.ino
#	$(ECHO) '#include <Arduino.h>' > $@
#	$(CAT)  $< >> $@
#
#$(OBJDIR)/%.o: $(OBJDIR)/%.cpp
#	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@
#
#$(OBJDIR)/%.d: $(OBJDIR)/%.cpp
#	$(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) $< -MF $@ -MT $(@:.d=.o)

# core files
$(OBJDIR)/%.o: $(ARDUINO_CORE_PATH)/%.c
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.o: $(ARDUINO_CORE_PATH)/%.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@


# FEH Core Files
$(OBJDIR)/%.o: $(FEH_CORE_PATH)/%.cpp
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# various object conversions
$(OBJDIR)/%.hex: $(OBJDIR)/%.elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

$(OBJDIR)/%.eep: $(OBJDIR)/%.elf
	-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom="alloc,load" \
		--change-section-lma .eeprom=0 -O ihex $< $@

$(OBJDIR)/%.lss: $(OBJDIR)/%.elf
	$(OBJDUMP) -h -S $< > $@

$(OBJDIR)/%.sym: $(OBJDIR)/%.elf
	$(NM) -n $< > $@

########################################################################
#
# Avrdude
#
ifndef AVRDUDE
AVRDUDE          = $(AVR_TOOLS_PATH)/avrdude
endif

AVRDUDE_COM_OPTS = -q -V -p $(MCU)
ifdef AVRDUDE_CONF
AVRDUDE_COM_OPTS += -C '$(AVRDUDE_CONF)'
endif

AVRDUDE_ARD_OPTS = -c $(AVRDUDE_ARD_PROGRAMMER) -b $(AVRDUDE_ARD_BAUDRATE) -P $(ARD_PORT) $(AVRDUDE_ARD_EXTRAOPTS)

ifndef ISP_PROG
ISP_PROG	   = -c stk500v2
endif

AVRDUDE_ISP_OPTS = -P $(ISP_PORT) $(ISP_PROG)


########################################################################
#
# Explicit targets start here
#

all: 		$(OBJDIR) $(TARGET_HEX)

$(OBJDIR):
		mkdir $(OBJDIR)

# Wensing (9/26/2012): This command for the target elf came from running
# $(LD) $(LDFLAGS) -v -o $@ $(LOCAL_OBJS) $(FEH_CORE_LIB) $(OTHER_OBJS) -lc -lm  
# the verbose output gave me the neccesary flags to pass to ld.exe below
# this was required to override the c-run-time that is custom compiled in $(CRT_LIB)
$(TARGET_ELF): 	$(LOCAL_OBJS) $(FEH_CORE_LIB) $(OTHER_OBJS) $(CRT_LIB)
		$(HARDWARE_TOOLS_PATH)/avr/avr/bin/ld.exe -m avr5 -Tdata 0x800100 -o $@ \
			$(CRT_LIB) \
			-L'$(HARDWARE_TOOLS_PATH)/avr/lib/gcc/avr/4.3.2/avr5' \
			-L'$(HARDWARE_TOOLS_PATH)\avr\avr\lib\avr5' \
			-L'$(HARDWARE_TOOLS_PATH)/avr/lib/gcc/avr/4.3.2' \
			-L'$(HARDWARE_TOOLS_PATH)/avr/lib/gcc' \
			-L'$(HARDWARE_TOOLS_PATH)/avr/avr/lib' \
			--gc-sections -u vfprintf -lprintf_flt $(LOCAL_OBJS) $(FEH_CORE_LIB) $(OTHER_OBJS) -lc -lm -lgcc -lc -lgcc

# Wensing (9/26/2012): This command to compile CRT_LIB came from the make process for crtm328p.o found in the avr-libc-1.7.1 source
# the make process for crtm328p.o had to be configured, but was done so with the default ./configure for avr-libc-1.7.1		
$(CRT_LIB):
ifdef FULL_BUILD
		$(CC) -I. -x assembler-with-cpp -Wa,-gstabs -mmcu=$(MCU) -c -o $(CRT_LIB) $(CRT_S)
else
		$(ECHO) No CRT Action
endif


$(FEH_CORE_LIB): $(FEH_CORE_OBJS) $(CORE_OBJS) $(LIB_OBJS)
ifdef FULL_BUILD
		 $(AR) rcs $@ $(FEH_CORE_OBJS) $(CORE_OBJS) $(LIB_OBJS)
else
		$(ECHO) No FEH Core Action
endif

upload:		reset raw_upload

# Wensing (9/26/2012): The below targets (com_reg, reg_import, and reg_modify)
#                      insert a putty configuration to the registry and modify
#                      it to connect to the correct port. 
com_reg:    	reg_import reg_modify

reg_import:
		reg import $(PUTTY_CONF)
reg_modify:
		reg add HKCU\Software\SimonTatham\PuTTY\Sessions\Arduino /v SerialLine /t REG_SZ /d $(ARD_PORT) /f

raw_upload:	$(TARGET_HEX) com_reg 
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ARD_OPTS) \
			-U flash:w:$(TARGET_HEX):i

# BSD stty likes -F, but GNU stty likes -f/--file.  Redirecting
# stdin/out appears to work but generates a spurious error on MacOS at
# least. Perhaps it would be better to just do it in perl ?
reset:		
		for STTYF in 'stty -F' 'stty --file' 'stty -f' 'stty <' ; \
		  do $$STTYF /dev/tty >/dev/null 2>&1 && break ; \
		done ; \
		$$STTYF $(ARD_PORT)  hupcl ; \
		(sleep 0.1 2>/dev/null || sleep 1) ; \
		$$STTYF $(ARD_PORT) -hupcl 

ispload:	$(TARGET_HEX)
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) -e \
			-U lock:w:$(ISP_LOCK_FUSE_PRE):m \
			-U hfuse:w:$(ISP_HIGH_FUSE):m \
			-U lfuse:w:$(ISP_LOW_FUSE):m \
			-U efuse:w:$(ISP_EXT_FUSE):m
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) -D \
			-U flash:w:$(TARGET_HEX):i
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) \
			-U lock:w:$(ISP_LOCK_FUSE_POST):m

clean:
ifdef FULL_BUILD
		$(REMOVE) $(LOCAL_OBJS) $(CORE_OBJS) $(FEH_CORE_OBJS) $(LIB_OBJS) $(FEH_CORE_LIB) $(TARGETS) $(CRT_LIB)
else
		$(REMOVE) $(LOCAL_OBJS) $(TARGETS)
endif

$(OBJ_DIR):
		$(MKDIR) $(OBJDIR)

size:		$(OBJDIR) $(TARGET_HEX)
		$(SIZE) $(TARGET_HEX)

# Wensing (9/26/2012): Unused stuff
#$(CORE_LIB):	$(CORE_OBJS) $(LIB_OBJS)
#		$(AR) rcs $@ $(CORE_OBJS) $(LIB_OBJS)
#show_boards:	
#		$(PARSE_BOARD) --boards
#$(DEP_FILE):	$(OBJDIR) $(DEPS)
#		$(CAT) $(DEPS) > $(DEP_FILE)
#include $(DEP_FILE)

