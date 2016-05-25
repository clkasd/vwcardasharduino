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
# Last update: Jan 22, 2015 release 4.1.9



include $(MAKEFILE_PATH)/About.mk

# ArduinoCC 1.6.5 SAMD specifics
# ----------------------------------
#
PLATFORM         := Arduino
BUILD_CORE       := samd
PLATFORM_TAG      = ARDUINO=10607 ARDUINO_ARCH_SAMD EMBEDXCODE=$(RELEASE_NOW) ARDUINO_$(BOARD_NAME) $(filter __%__ ,$(GCC_PREPROCESSOR_DEFINITIONS))
APPLICATION_PATH := $(ARDUINO_PATH)
PLATFORM_VERSION := SAMD $(ARDUINO_SAMD_RELEASE) for Arduino $(ARDUINO_CC_RELEASE)

HARDWARE_PATH     = $(ARDUINO_SAMD_PATH)/hardware/samd/$(ARDUINO_SAMD_RELEASE)
TOOL_CHAIN_PATH   = $(ARDUINO_SAMD_PATH)/tools/arm-none-eabi-gcc/4.8.3-2014q1
CMSIS_PATH        = $(ARDUINO_SAMD_PATH)/tools/CMSIS/4.0.0-atmel
OTHER_TOOLS_PATH  = $(ARDUINO_SAMD_PATH)/tools

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
BOARD_NAME        = $(call PARSE_BOARD,$(BOARD_TAG),build.board)

#FIRST_O_IN_A     = $$(find . -name variant.cpp.o)

VARIANT             = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
VARIANT_PATH        = $(HARDWARE_PATH)/variants/$(VARIANT)
VARIANT_CPP_SRCS    = $(wildcard $(VARIANT_PATH)/*.cpp) # */  $(VARIANT_PATH)/*/*.cpp #*/
VARIANT_OBJ_FILES   = $(VARIANT_CPP_SRCS:.cpp=.cpp.o)
VARIANT_OBJS        = $(patsubst $(HARDWARE_PATH)/%,$(OBJDIR)/%,$(VARIANT_OBJ_FILES))


# Uploader openocd or avrdude
# UPLOADER defined in .xcconfig
#
ifeq ($(UPLOADER),bossac)
    USB_RESET         = python $(UTILITIES_PATH)/reset_1200.py
    UPLOADER          = bossac
    UPLOADER_PATH     = $(OTHER_TOOLS_PATH)/bossac/$(BOSSAC_RELEASE)
    UPLOADER_EXEC     = $(UPLOADER_PATH)/bossac
    UPLOADER_PORT     = $(subst /dev/,,$(AVRDUDE_PORT))
    UPLOADER_OPTS     = -i -d --port=$(UPLOADER_PORT) -U $(call PARSE_BOARD,$(BOARD_TAG),upload.native_usb) -i -e -w -v
else
    UPLOADER         = openocd
    UPLOADER_PATH    = $(OTHER_TOOLS_PATH)/openocd/0.9.0-arduino
    UPLOADER_EXEC    = $(UPLOADER_PATH)/bin/openocd
    UPLOADER_OPTS    = -d2 -s $(UPLOADER_PATH)/share/openocd/scripts/
	UPLOADER_OPTS   += -f $(VARIANT_PATH)/$(call PARSE_BOARD,$(BOARD_TAG),build.openocdscript)
    UPLOADER_COMMAND = -c telnet_port disabled; program {{$(TARGET_BIN)}} verify reset 0x00002000; shutdown
    COMMAND_UPLOAD   = $(UPLOADER_EXEC) $(UPLOADER_OPTS) "$(UPLOADER_COMMAND)"
endif

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

# Specific AVRDUDE location and options
#
BOARD    = $(call PARSE_BOARD,$(BOARD_TAG),board)
LDSCRIPT = $(call PARSE_BOARD,$(BOARD_TAG),build.ldscript)

SYSTEM_LIB  = $(call PARSE_BOARD,$(BOARD_TAG),build.variant_system_lib)
SYSTEM_PATH = $(VARIANT_PATH)
SYSTEM_OBJS = $(SYSTEM_PATH)/$(SYSTEM_LIB)


# Two locations for Arduino libraries
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

BUILD_APP_LIB_PATH     = $(APPLICATION_PATH)/libraries

samd165_10    = $(foreach dir,$(BUILD_APP_LIB_PATH),$(patsubst %,$(dir)/%,$(APP_LIBS_LIST)))
samd165_10   += $(foreach dir,$(BUILD_APP_LIB_PATH),$(patsubst %,$(dir)/%/utility,$(APP_LIBS_LIST)))
samd165_10   += $(foreach dir,$(BUILD_APP_LIB_PATH),$(patsubst %,$(dir)/%/src,$(APP_LIBS_LIST)))
samd165_10   += $(foreach dir,$(BUILD_APP_LIB_PATH),$(patsubst %,$(dir)/%/src/arch/$(BUILD_CORE),$(APP_LIBS_LIST)))

BUILD_APP_LIB_CPP_SRC = $(foreach dir,$(samd165_10),$(wildcard $(dir)/*.cpp)) # */
BUILD_APP_LIB_C_SRC   = $(foreach dir,$(samd165_10),$(wildcard $(dir)/*.c)) # */
BUILD_APP_LIB_H_SRC   = $(foreach dir,$(samd165_10),$(wildcard $(dir)/*.h)) # */

BUILD_APP_LIB_OBJS     = $(patsubst $(APPLICATION_PATH)/%.cpp,$(OBJDIR)/%.cpp.o,$(BUILD_APP_LIB_CPP_SRC))
BUILD_APP_LIB_OBJS    += $(patsubst $(APPLICATION_PATH)/%.c,$(OBJDIR)/%.c.o,$(BUILD_APP_LIB_C_SRC))

APP_LIBS_LOCK = 1

CORE_C_SRCS     = $(wildcard $(CORE_LIB_PATH)/*.c $(CORE_LIB_PATH)/*/*.c) # */

samd165_20              = $(filter-out %main.cpp, $(wildcard $(CORE_LIB_PATH)/*.cpp $(CORE_LIB_PATH)/*/*.cpp $(CORE_LIB_PATH)/*/*/*.cpp $(CORE_LIB_PATH)/*/*/*/*.cpp)) # */
CORE_CPP_SRCS     = $(filter-out %/$(EXCLUDE_LIST),$(samd165_20))

CORE_AS_SRCS      = $(wildcard $(CORE_LIB_PATH)/*.S) # */
CORE_AS1_SRCS_OBJ = $(patsubst %.S,%.S.o,$(filter %S, $(CORE_AS_SRCS)))
CORE_AS2_SRCS_OBJ = $(patsubst %.s,%.s.o,$(filter %s, $(CORE_AS_SRCS)))

CORE_OBJ_FILES  += $(CORE_C_SRCS:.c=.c.o) $(CORE_CPP_SRCS:.cpp=.cpp.o) $(CORE_AS1_SRCS_OBJ) $(CORE_AS2_SRCS_OBJ)
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
USB_VENDOR  := $(call PARSE_BOARD,$(BOARD_TAG),build.usb_manufacturer)

USB_FLAGS    = -DUSB_VID=$(USB_VID)
USB_FLAGS   += -DUSB_PID=$(USB_PID)
USB_FLAGS   += -DUSBCON
USB_FLAGS   += -DUSB_MANUFACTURER='$(USB_VENDOR)'
USB_FLAGS   += -DUSB_PRODUCT='$(USB_PRODUCT)'

# Arduino Due serial 1200 reset
#
USB_TOUCH := $(call PARSE_BOARD,$(BOARD_TAG),upload.protocol)
#USB_RESET  = python $(UTILITIES_PATH)/reset_1200.py

    OPTIMISATION   = -Os

#INCLUDE_PATH     = $(APPLICATION_PATH)/hardware/arduino/samd/system/libsam
#INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/arduino/samd/system/libsam/include
#INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/tools/CMSIS/CMSIS/Include/
#INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/tools/CMSIS/Device/ATMEL/
INCLUDE_PATH    += $(CMSIS_PATH)/CMSIS/Include
INCLUDE_PATH    += $(CMSIS_PATH)/Device/ATMEL
INCLUDE_PATH    += $(CORE_LIB_PATH) $(VARIANT_PATH)
INCLUDE_PATH    += $(sort $(dir $(APP_LIB_CPP_SRC) $(APP_LIB_C_SRC) $(APP_LIB_H_SRC)))
INCLUDE_PATH    += $(sort $(dir $(BUILD_APP_LIB_CPP_SRC) $(BUILD_APP_LIB_C_SRC) $(BUILD_APP_LIB_H_SRC)))


# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
CPPFLAGS     = $(OPTIMISATION) $(WARNING_FLAGS)
CPPFLAGS    += -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU)
CPPFLAGS    += -ffunction-sections -fdata-sections -nostdlib
CPPFLAGS    += --param max-inline-insns-single=500
CPPFLAGS    += $(addprefix -D, $(PLATFORM_TAG)) # printf=iprintf
CPPFLAGS    += -mthumb
# $(USB_FLAGS)
CPPFLAGS    += $(addprefix -I, $(INCLUDE_PATH))

# Specific CFLAGS for gcc only
# gcc uses CPPFLAGS and CFLAGS
#
CFLAGS       = -std=gnu11

# Specific CXXFLAGS for g++ only
# g++ uses CPPFLAGS and CXXFLAGS
#
CXXFLAGS     = -std=gnu++11 -fno-rtti -fno-exceptions -fno-threadsafe-statics

# Specific ASFLAGS for gcc assembler only
# gcc assembler uses CPPFLAGS and ASFLAGS
#
ASFLAGS      = -x assembler-with-cpp

# Specific LDFLAGS for linker only
# linker uses CPPFLAGS and LDFLAGS
#
LDFLAGS      = $(OPTIMISATION) $(WARNING_FLAGS) -Wl,--gc-sections -save-temps
LDFLAGS     += -$(MCU_FLAG_NAME)=$(MCU) --specs=nano.specs --specs=nosys.specs
LDFLAGS     += -T $(VARIANT_PATH)/$(LDSCRIPT) -mthumb
LDFLAGS     += -Wl,--cref -Wl,-Map,Builds/embeddedcomputing.map # Output a cross reference table.
LDFLAGS     += -Wl,--check-sections -Wl,--gc-sections
LDFLAGS     += -Wl,--unresolved-symbols=report-all
LDFLAGS     += -Wl,--warn-common -Wl,--warn-section-align
#LDFLAGS     += -Wl,--check-sections -Wl,--gc-sections -Wl,--entry=Reset_Handl er
#LDFLAGS     += -Wl,--unresolved-symbols=report-all
#LDFLAGS     += -Wl,--warn-common -Wl,--warn-section-align -Wl,--warn-unresolved-symbols
#LDFLAGS     += -Wl,--section-start=.text=$(call PARSE_BOARD,$(BOARD_TAG),build.section.start)

# Specific OBJCOPYFLAGS for objcopy only
# objcopy uses OBJCOPYFLAGS only
#
OBJCOPYFLAGS  = -v -Obinary

FIRST_O_IN_A = $$(find . -name pulse_asm.S.o)


# Commands
# ----------------------------------
# Link command
#
#FIRST_O_IN_LD   = $$(find . -name syscalls.c.o)
#FIRST_O_IN_LD   = $(shell find . -name syscalls.c.o)

COMMAND_LINK    = $(CC) -L$(OBJDIR) $(LDFLAGS) $(OUT_PREPOSITION)$@ -L$(OBJDIR) $(LOCAL_OBJS) -Wl,--start-group -lm $(TARGET_A) -Wl,--end-group
# Upload command
#


# Target
#
TARGET_HEXBIN = $(TARGET_BIN)
#TARGET_EEP    = $(OBJDIR)/$(TARGET).hex
