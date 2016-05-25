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
# Last update: Jan 25, 2016 release 4.2.0




include $(MAKEFILE_PATH)/About.mk

# UDOO Net 1.6.5 specifics
# ----------------------------------
#
PLATFORM         := UDOO
BUILD_CORE       := NeoM4
PLATFORM_TAG      = ARDUINO=10605 EMBEDXCODE=$(RELEASE_NOW) $(filter __%__ ,$(GCC_PREPROCESSOR_DEFINITIONS)) UDOO_NEO_M4
APPLICATION_PATH := $(ARDUINO_PATH)
PLATFORM_VERSION := Neo $(UDOO_NEO_RELEASE) for Arduino $(ARDUINO_CC_RELEASE)

HARDWARE_PATH     = $(UDOO_NEO_PATH)/hardware/solox/$(UDOO_NEO_RELEASE)
TOOL_CHAIN_PATH   = $(UDOO_NEO_PATH)/tools/gcc-arm-none-eabi/$(UDOO_GCC_ARM_RELEASE)
OTHER_TOOLS_PATH  = $(UDOO_NEO_PATH)/tools/udooclient/$(UDOO_CLIENT_RELEASE)

# New GCC for ARM tool-suite
#
#ifeq ($(wildcard $(APPLICATION_PATH)/hardware/tools/g++_arm_none_eabi),)
#    APP_TOOLS_PATH   := $(TOOL_CHAIN_PATH)/hardware/tools/gcc-arm-none-eabi-4.8.3-2014q1/bin
#else
#    APP_TOOLS_PATH   := $(APPLICATION_PATH)/hardware/tools/g++_arm_none_eabi/bin
#endif
APP_TOOLS_PATH   := $(TOOL_CHAIN_PATH)/bin

CORE_LIB_PATH    := $(HARDWARE_PATH)/cores/arduino
APP_LIB_PATH     := $(HARDWARE_PATH)/libraries
BOARDS_TXT       := $(HARDWARE_PATH)/boards.txt
BOARD_NAME        = $(call PARSE_BOARD,$(BOARD_TAG),name)

#FIRST_O_IN_A     = $$(find . -name variant.cpp.o)

VARIANT             = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
VARIANT_PATH        = $(HARDWARE_PATH)/variants/$(VARIANT)
VARIANT_C_SRC       = $(shell find $(VARIANT_PATH) -name \*.c)
VARIANT_CPP_SRC     = $(shell find $(VARIANT_PATH) -name \*.cpp)
VARIANT_H_SRC       = $(shell find $(VARIANT_PATH) -name \*.h)
VARIANT_OBJ_FILES   = $(VARIANT_CPP_SRC:.cpp=.cpp.o) $(VARIANT_C_SRC:.c=.c.o)
#VARIANT_OBJS      = $(patsubst $(VARIANT_PATH)/%,$(OBJDIR)/%,$(VARIANT_OBJ_FILES))
VARIANT_OBJS        = $(patsubst $(HARDWARE_PATH)/%,$(OBJDIR)/%,$(VARIANT_OBJ_FILES))


# Uploader udooclient
# UPLOADER not yet defined in .xcconfig
#
UPLOADER         = udooclient
UPLOADER_PATH    = $(OTHER_TOOLS_PATH)
UPLOADER_EXEC    = $(UPLOADER_PATH)/udooclient
UPLOADER_OPTS    = $(BOARD_PORT):5152

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
CC      = $(APP_TOOLS_PATH)/arm-none-eabi-gcc
CXX     = $(APP_TOOLS_PATH)/arm-none-eabi-g++
AR      = $(APP_TOOLS_PATH)/arm-none-eabi-ar
OBJDUMP = $(APP_TOOLS_PATH)/arm-none-eabi-objdump
OBJCOPY = $(APP_TOOLS_PATH)/arm-none-eabi-objcopy
SIZE    = $(APP_TOOLS_PATH)/arm-none-eabi-size
NM      = $(APP_TOOLS_PATH)/arm-none-eabi-nm
# ~
GDB     = $(APP_TOOLS_PATH)/arm-none-eabi-gdb
# ~~

# Specific AVRDUDE location and options
#
BOARD    = $(call PARSE_BOARD,$(BOARD_TAG),board)
LDSCRIPT = $(call PARSE_BOARD,$(BOARD_TAG),build.ldscript)

SYSTEM_LIB  = $(call PARSE_BOARD,$(BOARD_TAG),build.variant_system_lib)
SYSTEM_PATH = $(VARIANT_PATH)
SYSTEM_OBJS = $(SYSTEM_PATH)/$(SYSTEM_LIB)


# One location for Arduino libraries
#
APP_LIB_PATH     = $(HARDWARE_PATH)/libraries

samd165_00    = $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%,$(APP_LIBS_LIST)))
samd165_00   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/utility,$(APP_LIBS_LIST)))
samd165_00   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src,$(APP_LIBS_LIST)))
samd165_00   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src/utility,$(APP_LIBS_LIST)))
samd165_00   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src/arch/$(BUILD_CORE),$(APP_LIBS_LIST)))
samd165_00   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src/$(BUILD_CORE),$(APP_LIBS_LIST)))

APP_LIB_CPP_SRC = $(foreach dir,$(samd165_00),$(wildcard $(dir)/*.cpp)) # */
APP_LIB_C_SRC   = $(foreach dir,$(samd165_00),$(wildcard $(dir)/*.c)) # */
APP_LIB_H_SRC   = $(foreach dir,$(samd165_00),$(wildcard $(dir)/*.h)) # */

APP_LIB_OBJS     = $(patsubst $(HARDWARE_PATH)/%.cpp,$(OBJDIR)/%.cpp.o,$(APP_LIB_CPP_SRC))
APP_LIB_OBJS    += $(patsubst $(HARDWARE_PATH)/%.c,$(OBJDIR)/%.c.o,$(APP_LIB_C_SRC))

#BUILD_APP_LIB_PATH     = $(APPLICATION_PATH)/libraries
#
#samd165_10    = $(foreach dir,$(BUILD_APP_LIB_PATH),$(patsubst %,$(dir)/%,$(APP_LIBS_LIST)))
#samd165_10   += $(foreach dir,$(BUILD_APP_LIB_PATH),$(patsubst %,$(dir)/%/utility,$(APP_LIBS_LIST)))
#samd165_10   += $(foreach dir,$(BUILD_APP_LIB_PATH),$(patsubst %,$(dir)/%/src,$(APP_LIBS_LIST)))
#samd165_10   += $(foreach dir,$(BUILD_APP_LIB_PATH),$(patsubst %,$(dir)/%/src/arch/$(BUILD_CORE),$(APP_LIBS_LIST)))
#
#BUILD_APP_LIB_CPP_SRC = $(foreach dir,$(samd165_10),$(wildcard $(dir)/*.cpp)) # */
#BUILD_APP_LIB_C_SRC   = $(foreach dir,$(samd165_10),$(wildcard $(dir)/*.c)) # */
#BUILD_APP_LIB_H_SRC   = $(foreach dir,$(samd165_10),$(wildcard $(dir)/*.h)) # */
#
#BUILD_APP_LIB_OBJS     = $(patsubst $(APPLICATION_PATH)/%.cpp,$(OBJDIR)/%.cpp.o,$(BUILD_APP_LIB_CPP_SRC))
#BUILD_APP_LIB_OBJS    += $(patsubst $(APPLICATION_PATH)/%.c,$(OBJDIR)/%.c.o,$(BUILD_APP_LIB_C_SRC))

APP_LIBS_LOCK = 1

CORE_C_SRC      = $(wildcard $(CORE_LIB_PATH)/*.c $(CORE_LIB_PATH)/*/*.c) # */

samd165_20              = $(filter-out %main.cpp, $(wildcard $(CORE_LIB_PATH)/*.cpp $(CORE_LIB_PATH)/*/*.cpp $(CORE_LIB_PATH)/*/*/*.cpp $(CORE_LIB_PATH)/*/*/*/*.cpp)) # */
CORE_CPP_SRC      = $(filter-out %/$(EXCLUDE_LIST),$(samd165_20))
CORE_AS1_SRC _OBJ = $(patsubst %.S,%.S.o,$(filter %S, $(CORE_AS_SRC )))
CORE_AS2_SRC _OBJ = $(patsubst %.s,%.s.o,$(filter %s, $(CORE_AS_SRC )))

CORE_OBJ_FILES  += $(CORE_C_SRC:.c=.c.o) $(CORE_CPP_SRC:.cpp=.cpp.o) $(CORE_AS1_SRC _OBJ) $(CORE_AS2_SRC _OBJ)
#    CORE_OBJS       += $(patsubst $(CORE_LIB_PATH)/%,$(OBJDIR)/%,$(CORE_OBJ_FILES))
#CORE_OBJS       += $(patsubst $(APPLICATION_PATH)/%,$(OBJDIR)/%,$(CORE_OBJ_FILES))
CORE_OBJS       += $(patsubst $(HARDWARE_PATH)/%,$(OBJDIR)/%,$(CORE_OBJ_FILES))

CORE_LIBS_LOCK = 1

# MCU options
#
MCU_FLAG_NAME    = mcpu
MCU              = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)
F_CPU            = $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)

# Arduino Zero Pro USB PID VID
#
USB_VID     := $(call PARSE_BOARD,$(BOARD_TAG),build.vid)
USB_PID     := $(call PARSE_BOARD,$(BOARD_TAG),build.pid)
USB_PRODUCT := $(call PARSE_BOARD,$(BOARD_TAG),build.usb_product)

USB_FLAGS    = -DUSB_VID=$(USB_VID)
USB_FLAGS   += -DUSB_PID=$(USB_PID)
USB_FLAGS   += -DUSBCON
USB_FLAGS   += -DUSB_MANUFACTURER=''
USB_FLAGS   += -DUSB_PRODUCT='$(USB_PRODUCT)'

# Arduino Due serial 1200 reset
#
USB_TOUCH := $(call PARSE_BOARD,$(BOARD_TAG),upload.use_1200bps_touch)
#USB_RESET  = python $(UTILITIES_PATH)/reset_1200.py

# ~
ifeq ($(MAKECMDGOALS),debug)
    OPTIMISATION   = -O0 -g3
else
    OPTIMISATION   = -Os -g
endif
# ~~

#INCLUDE_PATH     = $(APPLICATION_PATH)/hardware/arduino/samd/system/libsam
#INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/arduino/samd/system/libsam/include
#INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/tools/CMSIS/CMSIS/Include/
#INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/tools/CMSIS/Device/ATMEL/
#INCLUDE_PATH    += $(OTHER_TOOLS_PATH)/CMSIS/Include
#INCLUDE_PATH    += $(OTHER_TOOLS_PATH)/Device/ATMEL
INCLUDE_PATH    += $(CORE_LIB_PATH)
INCLUDE_PATH    += $(sort $(dir $(APP_LIB_CPP_SRC) $(APP_LIB_C_SRC) $(APP_LIB_H_SRC)))
INCLUDE_PATH    += $(sort $(dir $(VARIANT_CPP_SRC) $(VARIANT_C_SRC) $(VARIANT_H_SRC)))

$(info >>> INCLUDE_PATH_H $(sort $(dir $(VARIANT_CPP_SRC) $(VARIANT_C_SRC) $(VARIANT_H_SRC))))

D_FLAGS          = _AEABI_LC_CTYPE=C __STRICT_ANSI__=1 $(PLATFORM_TAG)

# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
CPPFLAGS     = $(OPTIMISATION) $(WARNING_FLAGS)
CPPFLAGS    += -$(MCU_FLAG_NAME)=$(MCU) -march=armv7e-m
CPPFLAGS    += -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
CPPFLAGS    += -fmessage-length=0 -ffunction-sections -fdata-sections
CPPFLAGS    += $(addprefix -D, $(D_FLAGS))
#CPPFLAGS    += -fno-rtti -fno-exceptions -fno-threadsafe-statics
# $(USB_FLAGS)
CPPFLAGS    += $(addprefix -I, $(INCLUDE_PATH))

# Specific CFLAGS for gcc only
# gcc uses CPPFLAGS and CFLAGS
#
CFLAGS       = -std=gnu11

# Specific CXXFLAGS for g++ only
# g++ uses CPPFLAGS and CXXFLAGS
#
CXXFLAGS     = -std=gnu++11 -fabi-version=0

# Specific ASFLAGS for gcc assembler only
# gcc assembler uses CPPFLAGS and ASFLAGS
#
ASFLAGS      = -x assembler-with-cpp

# Specific LDFLAGS for linker only
# linker uses CPPFLAGS and LDFLAGS
#
LDFLAGS      = $(CPPFLAGS)
LDFLAGS     += -L$(OBJDIR)
LDFLAGS     += -L$(VARIANT_PATH)/mqx/release/psp
LDFLAGS     += -L$(VARIANT_PATH)/mqx/release/bsp
LDFLAGS     += -L$(VARIANT_PATH)/mqx/release/mcc
LDFLAGS     += -L/usr/lib/arm-none-eabi/lib/armv7e-m/fpu
LDFLAGS     += -T$(VARIANT_PATH)/$(LDSCRIPT) -T$(VARIANT_PATH)/linker_scripts/gcc/libs.ld -mthumb
LDFLAGS     += -nostartfiles -nodefaultlibs -nostdlib
LDFLAGS     += -Xlinker --gc-sections -Wl,-Map,$(OBJDIR)/embeddedcomputing.map -Xlinker --cref -z muldefs

#LDFLAGS     += -Wl,--cref -Wl,-Map,Builds/embeddedcomputing.map # Output a cross reference table.
#LDFLAGS     += -Wl,--check-sections -Wl,--gc-sections
#LDFLAGS     += -Wl,--unresolved-symbols=report-all
#LDFLAGS     += -Wl,--warn-common -Wl,--warn-section-align
#LDFLAGS     += -Wl,--check-sections -Wl,--gc-sections -Wl,--entry=Reset_Handl er
#LDFLAGS     += -Wl,--unresolved-symbols=report-all
#LDFLAGS     += -Wl,--warn-common -Wl,--warn-section-align -Wl,--warn-unresolved-symbols
#LDFLAGS     += -Wl,--section-start=.text=$(call PARSE_BOARD,$(BOARD_TAG),build.section.start)

# Specific OBJCOPYFLAGS for objcopy only
# objcopy uses OBJCOPYFLAGS only
#
OBJCOPYFLAGS  = -v -Obinary


# Commands
# ----------------------------------
# Link command
#
#FIRST_O_IN_LD   = $$(find . -name syscalls.c.o)
#FIRST_O_IN_LD   = $(shell find . -name syscalls.c.o)

# Archive doesn't seem to work
#FIRST_O_IN_A     = $$(find ./$(OBJDIR) -name \*mqx.c.o)

#COMMAND_LINK    = $(CC) $(LDFLAGS) $(OUT_PREPOSITION)$@ $(LOCAL_OBJS) $(TARGET_A)
COMMAND_LINK    = $(CC) $(LDFLAGS) $(OUT_PREPOSITION)$@ $$(find ./$(OBJDIR) -name \*.o)

# Upload command
#
COMMAND_UPLOAD  = $(UPLOADER_EXEC) $(UPLOADER_OPTS) $(TARGET_BIN)

#COMMAND_SERIAL  = screen udooer@$(BOARD_PORT)

# Target
#
TARGET_HEXBIN = $(TARGET_BIN)
#TARGET_EEP    = $(OBJDIR)/$(TARGET).hex
