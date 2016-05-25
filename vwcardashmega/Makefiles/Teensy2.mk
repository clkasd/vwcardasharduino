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
# Last update: Oct 14, 2015 release 306






# Teensy 2.0 specifics
# ----------------------------------
#
BUILD_CORE       := avr

UPLOADER            = teensy_flash
# New with Teensyduino 1.21
TEENSY_FLASH_PATH   = $(APPLICATION_PATH)/hardware/tools/avr/bin
TEENSY_POST_COMPILE = $(TEENSY_FLASH_PATH)/teensy_post_compile
TEENSY_REBOOT       = $(TEENSY_FLASH_PATH)/teensy_reboot

APP_TOOLS_PATH   := $(APPLICATION_PATH)/hardware/tools/avr/bin
CORE_LIB_PATH    := $(APPLICATION_PATH)/hardware/teensy/avr/cores/teensy
#APP_LIB_PATH     := $(APPLICATION_PATH)/libraries

BUILD_CORE_LIB_PATH  = $(APPLICATION_PATH)/hardware/teensy/avr/cores/teensy
BUILD_CORE_LIBS_LIST = $(subst .h,,$(subst $(BUILD_CORE_LIB_PATH)/,,$(wildcard $(BUILD_CORE_LIB_PATH)/*.h))) # */
BUILD_CORE_C_SRCS    = $(wildcard $(BUILD_CORE_LIB_PATH)/*.c) # */

BUILD_CORE_CPP_SRCS  = $(filter-out %program.cpp %main.cpp,$(wildcard $(BUILD_CORE_LIB_PATH)/*.cpp)) # */

BUILD_CORE_OBJ_FILES = $(BUILD_CORE_C_SRCS:.c=.c.o) $(BUILD_CORE_CPP_SRCS:.cpp=.cpp.o)
BUILD_CORE_OBJS      = $(patsubst $(APPLICATION_PATH)/%,$(OBJDIR)/%,$(BUILD_CORE_OBJ_FILES))


# Sketchbook/Libraries path
# wildcard required for ~ management
# ?ibraries required for libraries and Libraries
#
ifeq ($(USER_LIBRARY_DIR)/Arduino15/preferences.txt,)
    $(error Error: run Teensy once and define the sketchbook path)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    SKETCHBOOK_DIR = $(shell grep sketchbook.path $(wildcard ~/Library/Arduino15/preferences.txt) | cut -d = -f 2)
endif

ifeq ($(wildcard $(SKETCHBOOK_DIR)),)
    $(error Error: sketchbook path not found)
endif

USER_LIB_PATH  = $(wildcard $(SKETCHBOOK_DIR)/?ibraries)


# Rules for making a c++ file from the main sketch (.pde)
#
PDEHEADER      = \\\#include \"WProgram.h\"  


# Tool-chain names
#
CC      = $(APP_TOOLS_PATH)/avr-gcc
CXX     = $(APP_TOOLS_PATH)/avr-g++
AR      = $(APP_TOOLS_PATH)/avr-ar
OBJDUMP = $(APP_TOOLS_PATH)/avr-objdump
OBJCOPY = $(APP_TOOLS_PATH)/avr-objcopy
SIZE    = $(APP_TOOLS_PATH)/avr-size
NM      = $(APP_TOOLS_PATH)/avr-nm


MCU_FLAG_NAME   = mmcu
MCU             = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)

ifndef TEENSY_F_CPU
    TEENSY_F_CPU = 16000000
endif
F_CPU           = $(TEENSY_F_CPU)

ifndef TEENSY_OPTIMISATION
    TEENSY_OPTIMISATION = $(call PARSE_BOARD,$(BOARD_TAG),build.flags.optimize)
endif
OPTIMISATION    = $(TEENSY_OPTIMISATION)


# Flags for gcc, g++ and linker
# ----------------------------------
#
# Common CPPFLAGS for gcc, g++, assembler and linker
#
CPPFLAGS     = $(OPTIMISATION) $(WARNING_FLAGS)
CPPFLAGS    += $(call PARSE_BOARD,$(BOARD_TAG),build.flags.cpu) -DF_CPU=$(F_CPU)
CPPFLAGS    += $(call PARSE_BOARD,$(BOARD_TAG),build.flags.defs)
CPPFLAGS    += $(call PARSE_BOARD,$(BOARD_TAG),build.flags.common)
CPPFLAGS    += $(addprefix -D, $(PLATFORM_TAG)) -DARDUINO_ARCH_AVR
CPPFLAGS    += -I$(CORE_LIB_PATH) -I$(VARIANT_PATH) -I$(OBJDIR)

# Specific CFLAGS for gcc only
# gcc uses CPPFLAGS and CFLAGS
#
CFLAGS       = $(call PARSE_BOARD,$(BOARD_TAG),build.flags.c)

# Specific CXXFLAGS for g++ only
# g++ uses CPPFLAGS and CXXFLAGS
#
CXXFLAGS     = $(call PARSE_BOARD,$(BOARD_TAG),build.flags.cpp)

# Specific ASFLAGS for gcc assembler only
# gcc assembler uses CPPFLAGS and ASFLAGS
#
ASFLAGS      = $(call PARSE_BOARD,$(BOARD_TAG),build.flags.S)

# Specific LDFLAGS for linker only
# linker uses CPPFLAGS and LDFLAGS
#
t101         = $(call PARSE_BOARD,$(BOARD_TAG),build.flags.ld)
t102         = $(subst {build.core.path},$(CORE_LIB_PATH),$(t101))
t103         = $(subst {extra.time.local},$(shell date +%s),$(t102))
LDFLAGS      = $(subst \", ,$(t103))
LDFLAGS     += $(call PARSE_BOARD,$(BOARD_TAG),build.flags.cpu)
LDFLAGS     += $(OPTIMISATION) $(call PARSE_BOARD,$(BOARD_TAG),build.flags.ldspecs)
LDFLAGS     += $(call PARSE_BOARD,$(BOARD_TAG),build.flags.libs)

