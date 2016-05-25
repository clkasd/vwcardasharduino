#
# embedXcode
# ----------------------------------
# Embedded Computing on Xcode
#
# Copyright © Rei VILO, 2010-2016
# http://embedxcode.weebly.com
# All rights reserved
#
#
# Last update: Jan 22, 2016 release 4.1.8





include $(MAKEFILE_PATH)/About.mk

# Galileo x86 specifics
# ----------------------------------
#
PLATFORM         := IntelArduino
BUILD_CORE       := x86
PLATFORM_TAG      = ARDUINO=10605 __ARDUINO_X86__ EMBEDXCODE=$(RELEASE_NOW)
APPLICATION_PATH := $(GALILEO_PATH)
PLATFORM_VERSION := $(INTEL_GALILEO_RELEASE) for Arduino $(ARDUINO_CC_RELEASE)

HARDWARE_PATH     = $(APPLICATION_PATH)/hardware/i586/$(INTEL_GALILEO_RELEASE)
TOOL_CHAIN_PATH   = $(APPLICATION_PATH)/tools/i586-poky-linux-uclibc/$(INTEL_GALILEO_RELEASE)/i586/pokysdk/usr/bin/i586-poky-linux-uclibc
SYSROOT_PATH      = $(APPLICATION_PATH)/tools/i586-poky-linux-uclibc/$(INTEL_GALILEO_RELEASE)/i586/i586-poky-linux-uclibc
OTHER_TOOLS_PATH  = $(APPLICATION_PATH)/tools/sketchUploader/1.6.2+1.0

APP_TOOLS_PATH   := $(TOOL_CHAIN_PATH)
CORE_LIB_PATH    := $(HARDWARE_PATH)/cores/arduino
APP_LIB_PATH     := $(HARDWARE_PATH)/libraries
BOARDS_TXT       := $(HARDWARE_PATH)/boards.txt

# Version check
#
#w001 = $(APPLICATION_PATH)/lib/version.txt
#VERSION_CHECK = $(shell if [ -f $(w001) ] ; then cat $(w001) ; fi)
#ifneq ($(VERSION_CHECK),1.6.0+Intel)
#    $(error Intel Arduino IDE release 1.6.0 required.)
#endif

# Uploader
#
UPLOADER         = izmirdl
#UPLOADER_PATH    = $(HARDWARE_PATH)/tools/izmir
#UPLOADER_EXEC    = $(UPLOADER_PATH)/uploader_izmir.sh
#UPLOADER_OPTS    = $(APPLICATION_PATH)/hardware/tools/x86/bin
UPLOADER_PATH    = $(OTHER_TOOLS_PATH)
UPLOADER_EXEC    = $(UPLOADER_PATH)/clupload/cluploadGalileo_osx.sh
UPLOADER_OPTS    = $(UPLOADER_PATH)/x86/bin

# Sketchbook/Libraries path
# wildcard required for ~ management
# ?ibraries required for libraries and Libraries
#
ifeq ($(USER_LIBRARY_DIR)/Arduino15/preferences.txt,)
    $(error Error: run Arduino once and define the sketchbook path)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    SKETCHBOOK_DIR = $(shell grep sketchbook.path $(USER_LIBRARY_DIR)/Arduino15/preferences.txt | cut -d = -f 2)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
   $(error Error: sketchbook path not found)
endif

USER_LIB_PATH  = $(wildcard $(SKETCHBOOK_DIR)/?ibraries)

# Rules for making a c++ file from the main sketch (.pde)
#
PDEHEADER      = \\\#include \"Arduino.h\"  

# Tool-chain names
#
CC      = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-gcc
CXX     = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-g++
AR      = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-ar
OBJDUMP = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-objdump
OBJCOPY = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-objcopy
SIZE    = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-size
NM      = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-nm
STRIP   = $(APP_TOOLS_PATH)/i586-poky-linux-uclibc-strip

# Specific AVRDUDE location and options
#
AVRDUDE_COM_OPTS  = -D -p$(MCU) -C$(AVRDUDE_CONF)

BOARD    = $(call PARSE_BOARD,$(BOARD_TAG),board)
#LDSCRIPT = $(call PARSE_BOARD,$(BOARD_TAG),build.ldscript)
VARIANT  = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
VARIANT_PATH = $(HARDWARE_PATH)/variants/$(VARIANT)
VARIANT_CPP_SRCS  = $(wildcard $(VARIANT_PATH)/*.cpp) # */  $(VARIANT_PATH)/*/*.cpp #*/
VARIANT_OBJ_FILES = $(VARIANT_CPP_SRCS:.cpp=.cpp.o)
VARIANT_OBJS      = $(patsubst $(APPLICATION_PATH)/%,$(OBJDIR)/%,$(VARIANT_OBJ_FILES))

#SYSTEM_LIB  = $(call PARSE_BOARD,$(BOARD_TAG),build.variant_system_lib)
SYSTEM_PATH = $(VARIANT_PATH)
SYSTEM_OBJS = $(SYSTEM_PATH)/$(SYSTEM_LIB)


# Two locations for Arduino libraries
# The libraries USBHost WiFi SD Servo Ethernet are duplicated
#
APP_LIB_PATH_1    = $(HARDWARE_PATH)/libraries
APP_LIB_PATH_2    = $(APPLICATION_PATH)/libraries
APP_LIB_PATH      = $(APP_LIB_PATH_1) $(APP_LIB_PATH_2)

APP_LIBS_LIST_1   = $(APP_LIBS_LIST)
APP_LIBS_LIST_2   = $(filter-out USBHost WiFi SD Servo Ethernet,$(APP_LIBS_LIST))

a1001    = $(foreach dir,$(APP_LIB_PATH_1),$(patsubst %,$(dir)/%,$(APP_LIBS_LIST_1)))
a1001   += $(foreach dir,$(APP_LIB_PATH_1),$(patsubst %,$(dir)/%/utility,$(APP_LIBS_LIST_1)))
a1001   += $(foreach dir,$(APP_LIB_PATH_1),$(patsubst %,$(dir)/%/src,$(APP_LIBS_LIST_1)))
a1001   += $(foreach dir,$(APP_LIB_PATH_1),$(patsubst %,$(dir)/%/src/utility,$(APP_LIBS_LIST_1)))
a1001   += $(foreach dir,$(APP_LIB_PATH_1),$(patsubst %,$(dir)/%/src/arch/$(BUILD_CORE),$(APP_LIBS_LIST_1)))

a1002    = $(foreach dir,$(APP_LIB_PATH_2),$(patsubst %,$(dir)/%,$(APP_LIBS_LIST_2)))
a1002   += $(foreach dir,$(APP_LIB_PATH_2),$(patsubst %,$(dir)/%/utility,$(APP_LIBS_LIST_2)))
a1002   += $(foreach dir,$(APP_LIB_PATH_2),$(patsubst %,$(dir)/%/src,$(APP_LIBS_LIST_2)))
a1002   += $(foreach dir,$(APP_LIB_PATH_2),$(patsubst %,$(dir)/%/src/utility,$(APP_LIBS_LIST_2)))
a1002   += $(foreach dir,$(APP_LIB_PATH_2),$(patsubst %,$(dir)/%/src/arch/$(BUILD_CORE),$(APP_LIBS_LIST_2)))

APP_LIB_CPP_SRC = $(foreach dir,$(a1001) $(a1002),$(wildcard $(dir)/*.cpp)) # */
APP_LIB_C_SRC   = $(foreach dir,$(a1001) $(a1002),$(wildcard $(dir)/*.c)) # */
APP_LIB_H_SRC   = $(foreach dir,$(a1001) $(a1002),$(wildcard $(dir)/*.h)) # */

APP_LIB_OBJS     = $(patsubst $(APPLICATION_PATH)/%.cpp,$(OBJDIR)/%.cpp.o,$(APP_LIB_CPP_SRC))
APP_LIB_OBJS    += $(patsubst $(APPLICATION_PATH)/%.c,$(OBJDIR)/%.c.o,$(APP_LIB_C_SRC))

BUILD_APP_LIBS_LIST = $(subst $(BUILD_APP_LIB_PATH)/, ,$(APP_LIB_CPP_SRC))

APP_LIBS_LOCK = 1


# MCU options
#
MCU_FLAG_NAME   = march
MCU             = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)

    OPTIMISATION   = -Os

# Include paths
#
#INCLUDE_PATH     = $(APPLICATION_PATH)/hardware/arduino/samd/system/libsam
#INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/arduino/samd/system/libsam/include
#INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/tools/CMSIS/CMSIS/Include/
#INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/tools/CMSIS/Device/ATMEL/
INCLUDE_PATH     = $(CORE_LIB_PATH) $(VARIANT_PATH)
INCLUDE_PATH    += $(sort $(dir $(APP_LIB_CPP_SRC) $(APP_LIB_C_SRC) $(APP_LIB_H_SRC)))


# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
CPPFLAGS     = $(OPTIMISATION) $(WARNING_FLAGS)
CPPFLAGS    += $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu) -$(MCU_FLAG_NAME)=$(MCU)
CPPFLAGS    += --sysroot=$(SYSROOT_PATH)
CPPFLAGS    += -w -ffunction-sections -fdata-sections -MMD
CPPFLAGS    += -Xassembler -mquark-strip-lock=yes
CPPFLAGS    += $(addprefix -D, $(PLATFORM_TAG))
CPPFLAGS    += $(addprefix -I, $(INCLUDE_PATH))

# Specific CFLAGS for gcc only
# gcc uses CPPFLAGS and CFLAGS
#
CFLAGS       =

# Specific CXXFLAGS for g++ only
# g++ uses CPPFLAGS and CXXFLAGS
#
CXXFLAGS     = -fno-exceptions

# Specific ASFLAGS for gcc assembler only
# gcc assembler uses CPPFLAGS and ASFLAGS
#
ASFLAGS      = -Xassembler

# Specific LDFLAGS for linker only
# linker uses CPPFLAGS and LDFLAGS
#
LDFLAGS      = $(OPTIMISATION) $(WARNING_FLAGS)
LDFLAGS     += -$(MCU_FLAG_NAME)=$(MCU) $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)
LDFLAGS     += --sysroot=$(SYSROOT_PATH)
LDFLAGS     += -Wl,--gc-sections -march=i586
#LDFLAGS     += -T $(VARIANT_PATH)/$(LDSCRIPT)

# Specific OBJCOPYFLAGS for objcopy only
# objcopy uses OBJCOPYFLAGS only
#
OBJCOPYFLAGS  = -v -Obinary

# Target
#
TARGET_HEXBIN = $(TARGET_HEX)


# Commands
# ----------------------------------
# Link command
#
COMMAND_LINK    = $(CXX) $(LDFLAGS) $(OUT_PREPOSITION)$@ $(LOCAL_OBJS) $(TARGET_A) -L$(OBJDIR) -lm -lpthread

#COMMAND_UPLOAD  = bash $(UPLOADER_EXEC) $(UPLOADER_OPTS) $(TARGET_ELF) $(USED_SERIAL_PORT)
