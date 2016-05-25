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
# Last update: Jan 11, 2016 release 4.1.5



# Energia CC3200 EMT specifics
# ----------------------------------
#
APPLICATION_PATH := $(ENERGIA_PATH)
ENERGIA_RELEASE  := $(shell tail -c2 $(APPLICATION_PATH)/lib/version.txt)
ARDUINO_RELEASE  := $(shell head -c4 $(APPLICATION_PATH)/lib/version.txt | tail -c3)

ifeq ($(shell if [[ '$(ENERGIA_RELEASE)' -ge '17' ]] ; then echo 1 ; else echo 0 ; fi ),0)
    WARNING_MESSAGE = Energia 17 or later is required.
endif

PLATFORM         := Energia
BUILD_CORE       := cc3200emt
PLATFORM_TAG      = ENERGIA=$(ENERGIA_RELEASE) ARDUINO=$(ARDUINO_RELEASE) EMBEDXCODE=$(RELEASE_NOW) $(filter __%__ ,$(GCC_PREPROCESSOR_DEFINITIONS)) ENERGIA_MT
MULTI_INO         := 1

UPLOADER          = cc3200serial
UPLOADER_PATH = $(APPLICATION_PATH)/hardware/tools
ifneq ($(wildcard $(UPLOADER_PATH)/lm4f/bin/serial),)
    UPLOADER_EXEC      = $(UPLOADER_PATH)/lm4f/bin/serial
else
    UPLOADER_EXEC      = $(UPLOADER_PATH)/lm4f/bin/cc3200prog
endif
UPLOADER_OPTS =

# StellarPad requires a specific command
#
UPLOADER_COMMAND = prog

APP_TOOLS_PATH  := $(APPLICATION_PATH)/hardware/tools/lm4f/bin
#CORE_LIB_PATH    := $(APPLICATION_PATH)/hardware/cc3200emt/cores/cc3200emt
CORES_PATH      := $(APPLICATION_PATH)/hardware/cc3200emt/cores/cc3200emt
APP_LIB_PATH    := $(APPLICATION_PATH)/hardware/cc3200emt/libraries
BOARDS_TXT      := $(APPLICATION_PATH)/hardware/cc3200emt/boards.txt

#CORE_LIBS_LIST   := #
#BUILD_CORE_LIBS_LIST := #

#BUILD_CORE_LIB_PATH  = $(APPLICATION_PATH)/hardware/cc3200emt/cores/cc3200emt/driverlib
#BUILD_CORE_LIBS_LIST = $(subst .h,,$(subst $(BUILD_CORE_LIB_PATH)/,,$(wildcard $(BUILD_CORE_LIB_PATH)/*.h))) # */

#BUILD_CORE_C_SRCS    = $(wildcard $(BUILD_CORE_LIB_PATH)/*.c) # */

#BUILD_CORE_CPP_SRCS = $(filter-out %program.cpp %main.cpp,$(wildcard $(BUILD_CORE_LIB_PATH)/*.cpp)) # */

#BUILD_CORE_OBJ_FILES  = $(BUILD_CORE_C_SRCS:.c=.c.o) $(BUILD_CORE_CPP_SRCS:.cpp=.cpp.o)
#BUILD_CORE_OBJS       = $(patsubst $(BUILD_CORE_LIB_PATH)/%,$(OBJDIR)/%,$(BUILD_CORE_OBJ_FILES))


# Sketchbook/Libraries path
# wildcard required for ~ management
# ?ibraries required for libraries and Libraries
#
ifeq ($(USER_LIBRARY_DIR)/Energia/preferences.txt,)
    $(error Error: run Energia once and define the sketchbook path)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    SKETCHBOOK_DIR = $(shell grep sketchbook.path $(wildcard ~/Library/Energia/preferences.txt) | cut -d = -f 2)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    $(error Error: sketchbook path not found)
endif

USER_LIB_PATH  = $(wildcard $(SKETCHBOOK_DIR)/?ibraries)


# Rules for making a c++ file from the main sketch (.pde)
#
PDEHEADER      = \\\#include \"Energia.h\"  


# Tool-chain names
#
CC      = $(APP_TOOLS_PATH)/arm-none-eabi-gcc
CXX     = $(APP_TOOLS_PATH)/arm-none-eabi-g++
AR      = $(APP_TOOLS_PATH)/arm-none-eabi-ar
OBJDUMP = $(APP_TOOLS_PATH)/arm-none-eabi-objdump
OBJCOPY = $(APP_TOOLS_PATH)/arm-none-eabi-objcopy
SIZE    = $(APP_TOOLS_PATH)/arm-none-eabi-size
NM      = $(APP_TOOLS_PATH)/arm-none-eabi-nm


BOARD            = $(call PARSE_BOARD,$(BOARD_TAG),board)
VARIANT          = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
VARIANT_PATH     = $(APPLICATION_PATH)/hardware/cc3200emt/variants/$(VARIANT)
CORE_A           = $(CORES_PATH)/driverlib/libdriverlib.a
#LDSCRIPT         = $(VARIANT_PATH)/linker.cmd
LDSCRIPT         = $(APPLICATION_PATH)/hardware/emt/ti/runtime/wiring/cc3200/linker.cmd


    OPTIMISATION   = -Os

MCU_FLAG_NAME    = mcpu
MCU              = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)
F_CPU            = $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)

SUB_PATH         = $(sort $(dir $(wildcard $(1)/*/))) # */

# Order matters!
#
INCLUDE_PATH     = $(APPLICATION_PATH)/hardware/tools/lm4f/include
INCLUDE_PATH    += $(call SUB_PATH,$(APPLICATION_PATH)/hardware/common)

INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/emt/xdc/cfg
INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/emt
INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/emt/ti/runtime/wiring/cc3200
INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/emt/ti/runtime/wiring/

INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/cc3200emt/cores/cc3200emt/
INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/cc3200emt/cores/cc3200emt/avr/
INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/cc3200emt/cores/cc3200emt/inc/
#INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/cc3200emt/cores/cc3200emt/inc/CMSIS
INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/cc3200emt/cores/cc3200emt/driverlib/

INCLUDE_PATH    += $(call SUB_PATH,$(CORES_PATH))
INCLUDE_PATH    += $(call SUB_PATH,$(VARIANT_PATH))

## INCLUDE_PATH     = $(call SUB_PATH,$(CORES_PATH))
## INCLUDE_PATH    += $(call SUB_PATH,$(VARIANT_PATH))
## INCLUDE_PATH    += $(call SUB_PATH,$(APPLICATION_PATH)/hardware/common)
## INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/tools/lm4f/include
## INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/cc3200emt/cores/cc3200emt/inc
## #INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/cc3200emt/cores/cc3200emt/inc/CMSIS
## #INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/cc3200emt/variants/$(call PARSE_BOARD,$(BOARD_TAG),build.hardware)
## INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/emt/xdc/cfg
## INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/emt
## INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/emt/ti/runtime/wiring/cc3200
## INCLUDE_PATH    += $(APPLICATION_PATH)/hardware/emt/ti/runtime/wiring/

INCLUDE_LIBS     = $(APPLICATION_PATH)/hardware/common
INCLUDE_LIBS    += $(APPLICATION_PATH)/hardware/tools/lm4f/lib
#INCLUDE_LIBS    += $(APPLICATION_PATH)/hardware/cc3200emt/variants/$(call PARSE_BOARD,$(BOARD_TAG),build.hardware)
INCLUDE_LIBS    += $(APPLICATION_PATH)/hardware/common/libs
INCLUDE_LIBS    += $(APPLICATION_PATH)/hardware/emt/ti/runtime/wiring/cc3200
INCLUDE_LIBS    += $(APPLICATION_PATH)/hardware/emt/ti/runtime/wiring/cc3200/variants/CC3200_LAUNCHXL
INCLUDE_LIBS    += $(APPLICATION_PATH)/hardware/emt


# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
CPPFLAGS     = $(OPTIMISATION) $(WARNING_FLAGS)
#CPPFLAGS    += @$(APPLICATION_PATH)/hardware/cc3200emt/targets/MSP_EXP432P401R/compiler.opt
#>>> VARIANT MSP_EXP432P401R
#>>> VARIANT_PATH /Applications/IDE/Energia.app/Contents/Resources/Java/hardware/cc3200emt/variants/MSP_EXP432P401R
#@"/Applications/IDE/Energia.app/Contents/Resources/Java/hardware/emt/ti/runtime/wiring/cc3200emt/compiler.opt"
CPPFLAGS    += @$(APPLICATION_PATH)/hardware/emt/ti/runtime/wiring/cc3200/compiler.opt
#CPPFLAGS    += @$(VARIANT_PATH)/compiler.opt
CPPFLAGS    += $(addprefix -I, $(INCLUDE_PATH))
CPPFLAGS    += $(addprefix -D, $(PLATFORM_TAG))
CPPFLAGS    += -DF_CPU=$(F_CPU) -D$(call PARSE_BOARD,$(BOARD_TAG),build.hardware)
CPPFLAGS    += -DBOARD_$(call PARSE_BOARD,$(BOARD_TAG),build.hardware)
CPPFLAGS    += $(addprefix -D, TARGET_IS_CC3200 xdc__nolocalstring=1 SL_PLATFORM_MULTI_THREADED)
CPPFLAGS    += -ffunction-sections -fdata-sections -mfloat-abi=soft -mcpu=cortex-m4 -march=armv7e-m

# Specific CFLAGS for gcc only
# gcc uses CPPFLAGS and CFLAGS
#
CFLAGS       = #

# Specific CXXFLAGS for g++ only
# g++ uses CPPFLAGS and CXXFLAGS
#
CXXFLAGS    = -fno-exceptions -fno-rtti

# Specific ASFLAGS for gcc assembler only
# gcc assembler uses CPPFLAGS and ASFLAGS
#
ASFLAGS      = --asm_extension=S

# Specific LDFLAGS for linker only
# linker uses CPPFLAGS and LDFLAGS
#
LDFLAGS      = $(OPTIMISATION) $(WARNING_FLAGS) $(addprefix -D, $(PLATFORM_TAG))
LDFLAGS     += -Wl,-T $(LDSCRIPT) $(CORE_A) $(addprefix -L, $(INCLUDE_LIBS))
LDFLAGS     += -mcpu=cortex-m4 -march=armv7e-m
#LDFLAGS     += @$(APPLICATION_PATH)/hardware/cc3200emt/variants/$(VARIANT)/compiler.opt
LDFLAGS     += @$(APPLICATION_PATH)/hardware/emt/ti/runtime/wiring/cc3200/compiler.opt
LDFLAGS     += -nostartfiles -Wl,--no-wchar-size-warning -Wl,-static -Wl,--gc-sections
LDFLAGS     += $(CORES_PATH)/driverlib/libdriverlib.a
LDFLAGS     += -lstdc++ -lgcc -lc -lm -lnosys

# Specific OBJCOPYFLAGS for objcopy only
# objcopy uses OBJCOPYFLAGS only
#
OBJCOPYFLAGS  = -v -Obinary

# Target
#
TARGET_HEXBIN = $(TARGET_BIN)


# Commands
# ----------------------------------
#
COMMAND_LINK = $(CC) $(OUT_PREPOSITION)$@ $(LOCAL_OBJS) $(TARGET_A) $(LDFLAGS)
