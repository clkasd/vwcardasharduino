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
# Last update: Dec 28, 2015 release 4.1.4

#ifneq ($(shell grep 1.5 $(ARDUINO_PATH)/lib/version.txt),)
#    WARNING_MESSAGE = Arduino 1.0.x is replaced by Arduino 1.6.1 or 1.7.x.
#endif

INFO_MESSAGE = Built with ArduinoORG SAM 1.7.7 

# ArduinoORG 1.7.7 SAM specifics
# ----------------------------------
#
PLATFORM         := Arduino
BUILD_CORE       := sam
PLATFORM_TAG      = ARDUINO=$(ARDUINO_RELEASE) ARDUINO_ARCH_SAM EMBEDXCODE=$(RELEASE_NOW) ARDUINO_$(BOARD_NAME) $(filter __%__ ,$(GCC_PREPROCESSOR_DEFINITIONS))
APPLICATION_PATH := $(ARDUINO_ORG_PATH)
#PLATFORM_VERSION := 1.6.1

HARDWARE_PATH     = $(APPLICATION_PATH)/hardware/arduino/sam
#TOOL_CHAIN_PATH   = $(ARDUINO_PATH)/hardware/tools/avr
OTHER_TOOLS_PATH  = $(ARDUINO_ORG_PATH)/hardware/tools/avr

# New GCC for ARM tool-suite
#
ifeq ($(wildcard $(APPLICATION_PATH)/hardware/tools/g++_arm_none_eabi),)
    TOOL_CHAIN_PATH  := $(APPLICATION_PATH)/hardware/tools/gcc-arm-none-eabi-4.8.3-2014q1
    APP_TOOLS_PATH   := $(TOOL_CHAIN_PATH)/bin
else
    TOOL_CHAIN_PATH  := $(APPLICATION_PATH)/hardware/tools/g++_arm_none_eabi
    APP_TOOLS_PATH   := $(TOOL_CHAIN_PATH)/bin
endif

CORE_LIB_PATH    := $(HARDWARE_PATH)/cores/arduino
APP_LIB_PATH     := $(HARDWARE_PATH)/libraries
BOARDS_TXT       := $(HARDWARE_PATH)/boards.txt
BOARD_NAME        = $(call PARSE_BOARD,$(BOARD_TAG),build.board)

FIRST_O_IN_A     = $$(find . -name variant.cpp.o)
#FIRST_O_IN_A     = $(filter %/variant.cpp.o,$(BUILD_CORE_OBJS))

VARIANT             = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
VARIANT_PATH        = $(HARDWARE_PATH)/variants/$(VARIANT)
VARIANT_CPP_SRCS    = $(wildcard $(VARIANT_PATH)/*.cpp) # */  $(VARIANT_PATH)/*/*.cpp #*/
VARIANT_OBJ_FILES   = $(VARIANT_CPP_SRCS:.cpp=.cpp.o)
#VARIANT_OBJS      = $(patsubst $(VARIANT_PATH)/%,$(OBJDIR)/%,$(VARIANT_OBJ_FILES))
VARIANT_OBJS        = $(patsubst $(APPLICATION_PATH)/%,$(OBJDIR)/%,$(VARIANT_OBJ_FILES))


# 
# Uploader bossac 
# Tested by Mike Roberts 
#
UPLOADER          = bossac
UPLOADER_PATH     = $(APPLICATION_PATH)/hardware/tools
UPLOADER_EXEC     = $(UPLOADER_PATH)/bossac
UPLOADER_PORT     = $(subst /dev/,,$(AVRDUDE_PORT))
UPLOADER_OPTS     = -i -d --port=$(UPLOADER_PORT) -U $(call PARSE_BOARD,$(BOARD_TAG),upload.native_usb) -e -w -v -b

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
AVRDUDE_COM_OPTS  = -D -p$(MCU) -C$(AVRDUDE_CONF)

BOARD    = $(call PARSE_BOARD,$(BOARD_TAG),board)
LDSCRIPT = $(call PARSE_BOARD,$(BOARD_TAG),build.ldscript)

SYSTEM_LIB  = $(call PARSE_BOARD,$(BOARD_TAG),build.variant_system_lib)
SYSTEM_PATH = $(VARIANT_PATH)
SYSTEM_OBJS = $(SYSTEM_PATH)/$(SYSTEM_LIB)


# Two locations for Arduino libraries
#
APP_LIB_PATH     = $(APPLICATION_PATH)/libraries
APP_LIB_PATH    += $(APPLICATION_PATH)/hardware/arduino/$(BUILD_CORE)/libraries

a1500    = $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%,$(APP_LIBS_LIST)))
a1500   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/utility,$(APP_LIBS_LIST)))
a1500   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src,$(APP_LIBS_LIST)))
a1500   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src/arch/$(BUILD_CORE),$(APP_LIBS_LIST)))
a1500   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src/$(BUILD_CORE),$(APP_LIBS_LIST)))

APP_LIB_CPP_SRC = $(foreach dir,$(a1500),$(wildcard $(dir)/*.cpp)) # */
APP_LIB_C_SRC   = $(foreach dir,$(a1500),$(wildcard $(dir)/*.c)) # */
APP_LIB_H_SRC   = $(foreach dir,$(a1500),$(wildcard $(dir)/*.h)) # */

APP_LIB_OBJS     = $(patsubst $(APPLICATION_PATH)/%.cpp,$(OBJDIR)/%.cpp.o,$(APP_LIB_CPP_SRC))
APP_LIB_OBJS    += $(patsubst $(APPLICATION_PATH)/%.c,$(OBJDIR)/%.c.o,$(APP_LIB_C_SRC))

APP_LIBS_LOCK = 1

# MCU options
#
MCU_FLAG_NAME    = mcpu
MCU              = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)
F_CPU            = $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)

# Arduino Due USB PID VID
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
USB_TOUCH := $(call PARSE_BOARD,$(BOARD_TAG),upload.protocol)
USB_RESET  = python $(UTILITIES_PATH)/reset_1200.py


INCLUDE_PATH    = $(CORE_LIB_PATH) $(APP_LIB_PATH) $(VARIANT_PATH)
INCLUDE_PATH   += $(sort $(dir $(APP_LIB_CPP_SRC) $(APP_LIB_C_SRC) $(APP_LIB_H_SRC)))
INCLUDE_PATH   += $(sort $(dir $(BUILD_APP_LIB_CPP_SRC) $(BUILD_APP_LIB_C_SRC)))
INCLUDE_PATH   += $(HARDWARE_PATH)/system
INCLUDE_PATH   += $(HARDWARE_PATH)/system/libsam
#INCLUDE_PATH   += $(HARDWARE_PATH)/system/libsam/include
INCLUDE_PATH   += $(HARDWARE_PATH)/system/CMSIS/CMSIS/Include/
INCLUDE_PATH   += $(HARDWARE_PATH)/system/CMSIS/Device/ATMEL/


# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
CPPFLAGS     = $(OPTIMISATION) $(WARNING_FLAGS)
CPPFLAGS    += -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU)
CPPFLAGS    += -ffunction-sections -fdata-sections -nostdlib -mthumb
CPPFLAGS    += --param max-inline-insns-single=500
CPPFLAGS    += $(addprefix -D, printf=iprintf $(PLATFORM_TAG))
CPPFLAGS    += $(addprefix -I, $(INCLUDE_PATH))

# Specific CFLAGS for gcc only
# gcc uses CPPFLAGS and CFLAGS
#
CFLAGS       =

# Specific CXXFLAGS for g++ only
# g++ uses CPPFLAGS and CXXFLAGS
#
CXXFLAGS     = -fno-rtti -fno-exceptions

# Specific ASFLAGS for gcc assembler only
# gcc assembler uses CPPFLAGS and ASFLAGS
#
ASFLAGS      = -x assembler-with-cpp

# Specific LDFLAGS for linker only
# linker uses CPPFLAGS and LDFLAGS
#
LDFLAGS      = $(OPTIMISATION) $(WARNING_FLAGS)
LDFLAGS     += -$(MCU_FLAG_NAME)=$(MCU)
LDFLAGS     += -T $(VARIANT_PATH)/$(LDSCRIPT) -mthumb
LDFLAGS     += -Wl,-Map,Builds/embeddedcomputing.map $(VARIANT_OBJS)
LDFLAGS     += -lgcc -mthumb -Wl,--cref -Wl,--check-sections -Wl,--gc-sections
LDFLAGS     += -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align
LDFLAGS     += -Wl,--warn-unresolved-symbols -Wl,--entry=Reset_Handler
#LDFLAGS     += -lm -Wl,--gc-sections,-u,main

# Specific OBJCOPYFLAGS for objcopy only
# objcopy uses OBJCOPYFLAGS only
#
OBJCOPYFLAGS  = -v -Obinary


# Commands
# ----------------------------------
# Link command
#
FIRST_O_IN_LD   = $$(find . -name syscalls_sam3.c.o)
COMMAND_LINK    = $(CXX) $(LDFLAGS) $(OUT_PREPOSITION)$@ -L$(OBJDIR) -Wl,--start-group $(FIRST_O_IN_LD) $(SYSTEM_OBJS) $(LOCAL_OBJS) $(TARGET_A) -Wl,--end-group -lm -lgcc

# Upload command
#
COMMAND_UPLOAD  = $(UPLOADER_EXEC) $(UPLOADER_OPTS) $(TARGET_BIN) -R


# Target
#
TARGET_HEXBIN = $(TARGET_BIN)
TARGET_EEP    = $(OBJDIR)/$(TARGET).hex
