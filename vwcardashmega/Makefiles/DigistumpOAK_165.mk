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
# Last update: Feb 02, 2016 release 4.2.2



include $(MAKEFILE_PATH)/About.mk

# Digistump Oak specifics
# ----------------------------------
#
PLATFORM         := Digistump
PLATFORM_TAG      = ARDUINO=10605 ARDUINO_ARCH_OAK EMBEDXCODE=$(RELEASE_NOW) OAK
APPLICATION_PATH := $(DIGISTUMP_OAK_PATH)
PLATFORM_VERSION := $(DIGISTUMP_OAK_RELEASE) for Arduino $(ARDUINO_CC_RELEASE)

HARDWARE_PATH     = $(APPLICATION_PATH)/hardware/oak/$(DIGISTUMP_OAK_RELEASE)
TOOL_CHAIN_PATH   = $(APPLICATION_PATH)/tools/xtensa-lx106-elf-gcc/$(OAK_EXTENSA_RELEASE)
OTHER_TOOLS_PATH  = $(APPLICATION_PATH)/tools

BUILD_CORE       = oak
BOARDS_TXT      := $(HARDWARE_PATH)/boards.txt
BUILD_CORE       = $(call PARSE_BOARD,$(BOARD_TAG),build.core)
BUILD_BOARD      = ARDUINO_$(call PARSE_BOARD,$(BOARD_TAG),build.board)

ESP_POST_COMPILE   = $(APPLICATION_PATH)/tools/esptool/$(OAK_ESPTOOLS_RELEASE)/esptool
BOOTLOADER_ELF     = $(HARDWARE_PATH)/bootloaders/eboot/eboot.elf

# Complicated menu system for Arduino 1.5
# Another example of Arduino's quick and dirty job
#
BOARD_TAGS_LIST   = $(BOARD_TAG) $(BOARD_TAG1) $(BOARD_TAG2)

SEARCH_FOR  = $(strip $(foreach t,$(1),$(call PARSE_BOARD,$(t),$(2))))

# flash_size is defined twice for nodemcu and nodemcuv2, take first
#
BUILD_FLASH_SIZE   = $(firstword $(call SEARCH_FOR,$(BOARD_TAGS_LIST),build.flash_size))
BUILD_FLASH_FREQ   = $(call SEARCH_FOR,$(BOARD_TAGS_LIST),build.flash_freq)

# Uploader
# ~/Library/Arduino15/packages/digistump/tools/oakcli/0.9.1/oak
UPLOADER_PATH       = $(OTHER_TOOLS_PATH)/oakcli/$(OAK_OAKCLI_RELEASE)
UPLOADER_EXEC       = $(UPLOADER_PATH)/oak
UPLOADER_OPTS       =

APP_TOOLS_PATH      := $(TOOL_CHAIN_PATH)/bin
CORE_LIB_PATH       := $(HARDWARE_PATH)/cores/oak

# Take assembler file as first
#
APP_LIB_PATH        := $(HARDWARE_PATH)/libraries
CORE_AS_SRCS         = $(wildcard $(CORE_LIB_PATH)/*.S) # */
esp001               = $(patsubst %.S,%.S.o,$(filter %S, $(CORE_AS_SRCS)))
FIRST_O_IN_A         = $(patsubst $(APPLICATION_PATH)/%,$(OBJDIR)/%,$(esp001))

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

USER_LIB_PATH  = $(wildcard $(SKETCHBOOK_DIR)/?ibraries)

VARIANT      = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
VARIANT_PATH = $(HARDWARE_PATH)/variants/$(VARIANT)

VARIANT_CPP_SRCS  = $(wildcard $(VARIANT_PATH)/*.cpp) # */
VARIANT_OBJ_FILES = $(VARIANT_CPP_SRCS:.cpp=.cpp.o)
VARIANT_OBJS      = $(patsubst $(APPLICATION_PATH)/%,$(OBJDIR)/%,$(VARIANT_OBJ_FILES))

# Rules for making a c++ file from the main sketch (.pde)
#
PDEHEADER      = \\\#include \"WProgram.h\"  


# Tool-chain names
#
CC      = $(APP_TOOLS_PATH)/xtensa-lx106-elf-gcc
CXX     = $(APP_TOOLS_PATH)/xtensa-lx106-elf-g++
AR      = $(APP_TOOLS_PATH)/xtensa-lx106-elf-ar
OBJDUMP = $(APP_TOOLS_PATH)/xtensa-lx106-elf-objdump
OBJCOPY = $(APP_TOOLS_PATH)/xtensa-lx106-elf-objcopy
SIZE    = $(APP_TOOLS_PATH)/xtensa-lx106-elf-size
NM      = $(APP_TOOLS_PATH)/xtensa-lx106-elf-nm

MCU_FLAG_NAME    = # mmcu
MCU              = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)
F_CPU            = $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)
OPTIMISATION     = -Os -g

INCLUDE_PATH     = $(HARDWARE_PATH)/tools/sdk/include
INCLUDE_PATH    += $(CORE_LIB_PATH)
INCLUDE_PATH    += $(VARIANT_PATH)

LDSCRIPT = $(call SEARCH_FOR,$(BOARD_TAGS_LIST),build.flash_ld)

# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
CPPFLAGS     = $(OPTIMISATION) $(WARNING_FLAGS)
CPPFLAGS    += -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__
CPPFLAGS    += -mlongcalls -mtext-section-literals -falign-functions=4 -MMD
CPPFLAGS    += -ffunction-sections -fdata-sections
CPPFLAGS    += -DF_CPU=$(F_CPU)
CPPFLAGS    += $(addprefix -D, $(PLATFORM_TAG) $(BUILD_BOARD))
CPPFLAGS    += $(addprefix -I, $(INCLUDE_PATH))

# Specific CFLAGS for gcc only
# gcc uses CPPFLAGS and CFLAGS
#
CFLAGS       = -Wpointer-arith -Wno-implicit-function-declaration -Wl,-EL -fno-inline-functions -nostdlib -std=gnu99
# was -std=c99

# Specific CXXFLAGS for g++ only
# g++ uses CPPFLAGS and CXXFLAGS
#
CXXFLAGS     = -fno-exceptions -fno-rtti -std=c++11

# Specific ASFLAGS for gcc assembler only
# gcc assembler uses CPPFLAGS and ASFLAGS
#
ASFLAGS      = -x assembler-with-cpp

# Specific LDFLAGS and L_FLAGS for linker only
# linker uses CPPFLAGS and LDFLAGS
#
LDFLAGS      = $(OPTIMISATION) $(WARNING_FLAGS)
#-Wl,--gc-sections
LDFLAGS     += -nostdlib -Wl,--no-check-sections -u call_user_start -u Cache_Read_Enable_New -Wl,-static
LDFLAGS     += -L$(HARDWARE_PATH)/tools/sdk/lib
LDFLAGS     += -L$(HARDWARE_PATH)/tools/sdk/ld
LDFLAGS     += -T $(LDSCRIPT)
LDFLAGS     += -Wl,--gc-sections -Wl,-wrap,system_restart_local -Wl,-wrap,register_chipv6_phy

L_FLAGS      = -lm -lgcc -lhal -lphy -lnet80211 -llwip -lwpa -lmain -lpp -lsmartconfig -lwps -lcrypto -laxtls


# Specific OBJCOPYFLAGS for objcopy only
# objcopy uses OBJCOPYFLAGS only
#
OBJCOPYFLAGS  = $(call PARSE_BOARD,$(BOARD_TAG),build.flash_mode)

# Target
#
TARGET_HEXBIN = $(TARGET_BIN)


# Commands
# ----------------------------------
# Link command
#
COMMAND_LINK    = $(CC) $(LDFLAGS) $(OUT_PREPOSITION)$@ -Wl,--start-group $(LOCAL_OBJS) $(TARGET_A) $(L_FLAGS) -Wl,--end-group -LBuilds

COMMAND_COPY    = $(OTHER_TOOLS_PATH)/esptool2/$(OAK_ESPTOOLS_RELEASE)/esptool2 -quiet -bin -boot2 -4096 -iromchksum $(TARGET_ELF) $(TARGET_BIN) .text .data .rodata

COMMAND_UPLOAD  = $(UPLOADER_EXEC) $(TARGET_BIN) $(UPLOADER_OPTS)
