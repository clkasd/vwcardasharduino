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
# Last update: Jan 16, 2016 release 4.1.7


include $(MAKEFILE_PATH)/About.mk

# RedBearLan NRF specifics
# ----------------------------------
#
PLATFORM         := RedBearLab
PLATFORM_TAG      = ARDUINO=10605 ARDUINO_RBL_nRF51822 ARDUINO_ARCH_NRF51822 EMBEDXCODE=$(RELEASE_NOW) REDBEARLAB
APPLICATION_PATH := $(REDBEARLAB_NRF_PATH)
PLATFORM_VERSION := nRF51822 $(REDBEARLAB_NRF_RELEASE) for Arduino $(ARDUINO_CC_RELEASE)

HARDWARE_PATH     = $(APPLICATION_PATH)/hardware/nRF51822/$(REDBEARLAB_NRF_RELEASE)
TOOL_CHAIN_PATH   = $(APPLICATION_PATH)/tools/arm-none-eabi-gcc/4.8.3-2014q1
OTHER_TOOLS_PATH  = $(APPLICATION_PATH)/tools/bossac/1.3a-arduino

BUILD_CORE       = avr
BOARDS_TXT      := $(HARDWARE_PATH)/boards.txt
BUILD_CORE       = $(call PARSE_BOARD,$(BOARD_TAG),build.core)

# Uploader
#
UPLOADER             = avrdude
AVRDUDE_PATH        := $(ARDUINO_PATH)/hardware/tools/avr
AVRDUDE_EXEC        := $(AVRDUDE_PATH)/avrdude
AVRDUDE_CONF         = $(HARDWARE_PATH)/avrdude_conf/avrdude.conf
AVRDUDE_COM_OPTS     = -p$(AVRDUDE_MCU) -C$(AVRDUDE_CONF)


APP_TOOLS_PATH   := $(TOOL_CHAIN_PATH)/bin
CORE_LIB_PATH    := $(HARDWARE_PATH)/cores/RBL_nRF51822
APP_LIB_PATH     := $(APPLICATION_PATH)/libraries

BUILD_CORE_LIB_PATH  = $(HARDWARE_PATH)/cores/RBL_nRF51822
BUILD_CORE_LIBS_LIST = $(subst .h,,$(subst $(BUILD_CORE_LIB_PATH)/,,$(wildcard $(BUILD_CORE_LIB_PATH)/*.h))) # */
BUILD_CORE_C_SRCS    = $(wildcard $(BUILD_CORE_LIB_PATH)/*.c) # */

BUILD_CORE_CPP_SRCS  = $(filter-out %program.cpp %main.cpp,$(wildcard $(BUILD_CORE_LIB_PATH)/*.cpp)) # */

BUILD_CORE_OBJ_FILES = $(BUILD_CORE_C_SRCS:.c=.c.o) $(BUILD_CORE_CPP_SRCS:.cpp=.cpp.o)
BUILD_CORE_OBJS      = $(patsubst $(APPLICATION_PATH)/%,$(OBJDIR)/%,$(BUILD_CORE_OBJ_FILES))


# Core files
# Crazy maze of sub-folders
#
CORE_C_SRCS          = $(shell find $(CORE_LIB_PATH) -name \*.c)
p1300                = $(filter-out %main.cpp, $(shell find $(CORE_LIB_PATH) -name \*.cpp))
CORE_CPP_SRCS        = $(filter-out %/$(EXCLUDE_LIST),$(p1300))
CORE_AS1_SRCS        = $(shell find $(CORE_LIB_PATH) -name \*.S)
CORE_AS1_SRCS_OBJ    = $(patsubst %.S,%.S.o,$(filter %.S, $(CORE_AS1_SRCS)))
CORE_AS2_SRCS        = $(shell find $(CORE_LIB_PATH) -name \*.s)
CORE_AS2_SRCS_OBJ    = $(patsubst %.s,%.s.o,$(filter %.s, $(CORE_AS_SRCS)))

CORE_OBJ_FILES       = $(CORE_C_SRCS:.c=.c.o) $(CORE_CPP_SRCS:.cpp=.cpp.o) $(CORE_AS1_SRCS_OBJ) $(CORE_AS2_SRCS_OBJ)
CORE_OBJS            = $(patsubst $(APPLICATION_PATH)/%,$(OBJDIR)/%,$(CORE_OBJ_FILES))

CORE_LIBS_LOCK       = 1

# Two locations for RedBearLabs libraries
#
APP_LIB_PATH     = $(APPLICATION_PATH)/libraries

p1000    = $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%,$(APP_LIBS_LIST)))
p1000   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/utility,$(APP_LIBS_LIST)))
p1000   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src,$(APP_LIBS_LIST)))
p1000   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src/utility,$(APP_LIBS_LIST)))
p1000   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src/arch/$(BUILD_CORE),$(APP_LIBS_LIST)))
p1000   += $(foreach dir,$(APP_LIB_PATH),$(patsubst %,$(dir)/%/src/$(BUILD_CORE),$(APP_LIBS_LIST)))

APP_LIB_CPP_SRC = $(foreach dir,$(p1000),$(wildcard $(dir)/*.cpp)) # */
APP_LIB_C_SRC   = $(foreach dir,$(p1000),$(wildcard $(dir)/*.c)) # */
APP_LIB_S_SRC   = $(foreach dir,$(p1000),$(wildcard $(dir)/*.S)) # */
APP_LIB_H_SRC   = $(foreach dir,$(p1000),$(wildcard $(dir)/*.h)) # */

APP_LIB_OBJS     = $(patsubst $(APPLICATION_PATH)/%.cpp,$(OBJDIR)/%.cpp.o,$(APP_LIB_CPP_SRC))
APP_LIB_OBJS    += $(patsubst $(APPLICATION_PATH)/%.c,$(OBJDIR)/%.c.o,$(APP_LIB_C_SRC))

BUILD_APP_LIBS_LIST = $(subst $(BUILD_APP_LIB_PATH)/, ,$(APP_LIB_CPP_SRC))

BUILD_APP_LIB_PATH    = $(HARDWARE_PATH)/libraries

p1100    = $(foreach dir,$(BUILD_APP_LIB_PATH),$(patsubst %,$(dir)/%,$(APP_LIBS_LIST)))
p1100   += $(foreach dir,$(BUILD_APP_LIB_PATH),$(patsubst %,$(dir)/%/utility,$(APP_LIBS_LIST)))
p1100   += $(foreach dir,$(BUILD_APP_LIB_PATH),$(patsubst %,$(dir)/%/src,$(APP_LIBS_LIST)))
p1100   += $(foreach dir,$(BUILD_APP_LIB_PATH),$(patsubst %,$(dir)/%/src/utility,$(APP_LIBS_LIST)))
p1100   += $(foreach dir,$(BUILD_APP_LIB_PATH),$(patsubst %,$(dir)/%/src/arch/$(BUILD_CORE),$(APP_LIBS_LIST)))

BUILD_APP_LIB_CPP_SRC = $(foreach dir,$(p1100),$(wildcard $(dir)/*.cpp)) # */
BUILD_APP_LIB_C_SRC   = $(foreach dir,$(p1100),$(wildcard $(dir)/*.c)) # */
BUILD_APP_LIB_S_SRC   = $(foreach dir,$(p1100),$(wildcard $(dir)/*.S)) # */
BUILD_APP_LIB_H_SRC   = $(foreach dir,$(p1100),$(wildcard $(dir)/*.h)) # */

BUILD_APP_LIB_OBJS     = $(patsubst $(HARDWARE_PATH)/%.cpp,$(OBJDIR)/%.cpp.o,$(BUILD_APP_LIB_CPP_SRC))
BUILD_APP_LIB_OBJS    += $(patsubst $(HARDWARE_PATH)/%.c,$(OBJDIR)/%.c.o,$(BUILD_APP_LIB_C_SRC))

BUILD_APP_LIBS_LIST = $(subst $(BUILD_APP_LIB_PATH)/, ,$(BUILD_APP_LIB_CPP_SRC))

APP_LIBS_LOCK = 1


# Sketchbook/Libraries path
# wildcard required for ~ management
# ?ibraries required for libraries and Libraries
#
ifeq ($(USER_LIBRARY_DIR)/Arduino15/preferences.txt,)
    $(error Error: run Arduino once and define the sketchbook path)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    SKETCHBOOK_DIR = $(shell grep sketchbook.path $(wildcard ~/Library/Arduino15/preferences.txt) | cut -d = -f 2)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    $(error Error: sketchbook path not found)
endif

USER_LIB_PATH   = $(wildcard $(SKETCHBOOK_DIR)/?ibraries)

VARIANT         = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
VARIANT_PATH    = $(HARDWARE_PATH)/variants/$(VARIANT)
LDSCRIPT_PATH   = $(VARIANT_PATH)
LDSCRIPT        = $(VARIANT_PATH)/$(call PARSE_BOARD,$(BOARD_TAG),build.ldscript)

# Rules for making a c++ file from the main sketch (.pde)
#
PDEHEADER      = \\\#include \"WProgram.h\"  


# Tool-chain names
#
CC      = $(APP_TOOLS_PATH)/arm-none-eabi-gcc
CXX     = $(APP_TOOLS_PATH)/arm-none-eabi-g++
AR      = $(APP_TOOLS_PATH)/arm-none-eabi-ar
OBJDUMP = $(APP_TOOLS_PATH)/arm-none-eabi-objdump
OBJCOPY = $(APP_TOOLS_PATH)/arm-none-eabi-objcopy
SIZE    = $(APP_TOOLS_PATH)/arm-none-eabi-size
NM      = $(APP_TOOLS_PATH)/arm-none-eabi-nm


MCU_FLAG_NAME    = mcpu
MCU              = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)
F_CPU            = $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)
OPTIMISATION     = -Os

INCLUDE_PATH     = $(CORE_LIB_PATH) $(APP_LIB_PATH) $(VARIANT_PATH) $(HARDWARE_PATH)
INCLUDE_PATH    += $(sort $(dir $(APP_LIB_CPP_SRC) $(APP_LIB_C_SRC) $(APP_LIB_H_SRC)))
INCLUDE_PATH    += $(sort $(dir $(BUILD_APP_LIB_CPP_SRC) $(BUILD_APP_LIB_C_SRC) $(BUILD_APP_LIB_H_SRC)))
INCLUDE_PATH    += $(OBJDIR)

p1200            = $(call PARSE_BOARD,$(BOARD_TAG),build.ble_api_include)
p1200           += $(call PARSE_BOARD,$(BOARD_TAG),build.nRF51822_api_include)
p1200           += $(call PARSE_BOARD,$(BOARD_TAG),build.mbed_api_include)
p1210            = $(shell echo $(p1200) | sed 's/-I{runtime.platform.path}//g')
p1220            = $(addprefix $(HARDWARE_PATH),$(p1210))

INCLUDE_PATH    += $(p1220)

D_FLAGS         = BLE_STACK_SUPPORT_REQD DEBUG_NRF_USER NRF51
D_FLAGS        += TARGET_NRF51822 TARGET_M0 TARGET_CORTEX_M
D_FLAGS        += TARGET_NORDIC TARGET_NRF51822_MKIT TARGET_MCU_NRF51822
D_FLAGS        += TOOLCHAIN_GCC_ARM TOOLCHAIN_GCC __CORTEX_M0 ARM_MATH_CM0
D_FLAGS        += MBED_BUILD_TIMESTAMP=$(shell date +%s) __MBED__=1


# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
CPPFLAGS     = -g $(OPTIMISATION) $(WARNING_FLAGS)  # -w
CPPFLAGS    += -fno-common -fmessage-length=0 -Wall
CPPFLAGS    += -fno-exceptions -ffunction-sections -fdata-sections
CPPFLAGS    += -fomit-frame-pointer -nostdlib
CPPFLAGS    += --param max-inline-insns-single=500 -fno-rtti -mthumb
CPPFLAGS    += -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU)
#CPPFLAGS    += $(call PARSE_BOARD,$(BOARD_TAG),build.board)
#CPPFLAGS    += $(call PARSE_BOARD,$(BOARD_TAG),build.flags.common)
CPPFLAGS    += $(addprefix -D, $(PLATFORM_TAG) $(D_FLAGS))
CPPFLAGS    += $(addprefix -I, $(INCLUDE_PATH))

# Specific CFLAGS for gcc only
# gcc uses CPPFLAGS and CFLAGS
#
CFLAGS       = -std=gnu99

# Specific CXXFLAGS for g++ only
# g++ uses CPPFLAGS and CXXFLAGS
#
CXXFLAGS     = -std=gnu++98

# Specific ASFLAGS for gcc assembler only
# gcc assembler uses CPPFLAGS and ASFLAGS
#
ASFLAGS      = -x assembler-with-cpp

# Specific LDFLAGS for linker only
# linker uses CPPFLAGS and LDFLAGS
#
LDFLAGS      = -w $(OPTIMISATION)
LDFLAGS     += -mthumb -Wl,--gc-sections --specs=nano.specs -Wl,--wrap,main
LDFLAGS     += -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU)
LDFLAGS     += -T $(LDSCRIPT)
#LDFLAGS     += $(OPTIMISATION) $(call PARSE_BOARD,$(BOARD_TAG),build.flags.ldspecs)
#LDFLAGS     += $(call PARSE_BOARD,$(BOARD_TAG),build.flags.libs) --verbose

# Specific OBJCOPYFLAGS for objcopy only
# objcopy uses OBJCOPYFLAGS only
#
OBJCOPYFLAGS  = -v -Obinary

# Target
#
TARGET_HEXBIN = $(TARGET_BIN)

# Serial 1200 reset
#
USB_TOUCH := $(call PARSE_BOARD,$(BOARD_TAG),upload.use_1200bps_touch)
ifeq ($(USB_TOUCH),true)
    USB_RESET  = python $(UTILITIES_PATH)/reset_1200.py
endif


# Commands
# ----------------------------------
# Link command
#
COMMAND_LINK    = $(CXX) $(LDFLAGS) -L$(OBJDIR) -Wl,--start-group $(LOCAL_OBJS) $(TARGET_A) $(LIBRARY_A) -Wl,--end-group $(OUT_PREPOSITION)$@ -lstdc++ -lsupc++ -lm -lc -lgcc -lnosys

#COMMAND_UPLOAD  = $(AVRDUDE_EXEC) $(AVRDUDE_COM_OPTS) $(AVRDUDE_OPTS) -P$(USED_SERIAL_PORT) -Uflash:w:$(TARGET_HEX):i
