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



# Microduino 1.6.x AVR specifics
# ----------------------------------
#
PLATFORM         := Microduino
BUILD_CORE       := avr
PLATFORM_TAG      = ARDUINO=10605 MICRODUINO EMBEDXCODE=$(RELEASE_NOW) ARDUINO_AVR_PRO ARDUINO_ARCH_AVR
APPLICATION_PATH := $(MICRODUINO_PATH)

APP_TOOLS_PATH   := $(APPLICATION_PATH)/hardware/tools/avr/bin
CORE_LIB_PATH    := $(APPLICATION_PATH)/hardware/Microduino/avr/cores/arduino
APP_LIB_PATH     := $(APPLICATION_PATH)/libraries
BOARDS_TXT       := $(APPLICATION_PATH)/hardware/Microduino/avr/boards.txt


# Sketchbook/Libraries path
# wildcard required for ~ management
#
ifeq ($(USER_LIBRARY_DIR)/Arduino15/preferences.txt,)
    $(error Error: run Microduino or Arduino once and define the sketchbook path)
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
CC      = $(APP_TOOLS_PATH)/avr-gcc
CXX     = $(APP_TOOLS_PATH)/avr-g++
AR      = $(APP_TOOLS_PATH)/avr-ar
OBJDUMP = $(APP_TOOLS_PATH)/avr-objdump
OBJCOPY = $(APP_TOOLS_PATH)/avr-objcopy
SIZE    = $(APP_TOOLS_PATH)/avr-size
NM      = $(APP_TOOLS_PATH)/avr-nm

# Specific AVRDUDE location and options
#
AVRDUDE_COM_OPTS  = -D -p$(MCU) -C$(AVRDUDE_CONF)


# Complicated menu system for Arduino 1.5
# Another example of Arduino's quick and dirty job
#
BOARD_TAGS_LIST   = $(BOARD_TAG) $(BOARD_TAG1) $(BOARD_TAG2)

SEARCH_FOR  = $(strip $(foreach t,$(1),$(call PARSE_BOARD,$(t),$(2))))

ifeq ($(BOARD_NAME),)
    BOARD_NAME          := $(call SEARCH_FOR,$(BOARD_TAGS_LIST),name)
endif

# MCU options
#
MCU_FLAG_NAME           := mmcu
ifeq ($(MCU),)
    MCU                 := $(call SEARCH_FOR,$(BOARD_TAGS_LIST),build.mcu)
endif

ifeq ($(F_CPU),)
    F_CPU               := $(call SEARCH_FOR,$(BOARD_TAGS_LIST),build.f_cpu)
endif

ifeq ($(MAX_FLASH_SIZE),)
    MAX_FLASH_SIZE      := $(call SEARCH_FOR,$(BOARD_TAGS_LIST),upload.maximum_size)
endif

ifeq ($(AVRDUDE_BAUDRATE),)
    AVRDUDE_BAUDRATE    := $(call SEARCH_FOR,$(BOARD_TAGS_LIST),upload.speed)
endif

ifeq ($(AVRDUDE_PROGRAMMER),)
    AVRDUDE_PROGRAMMER  := $(call SEARCH_FOR,$(BOARD_TAGS_LIST),upload.protocol)
endif

ifeq ($(VARIANT),)
    VARIANT             := $(call SEARCH_FOR,$(BOARD_TAGS_LIST),build.variant)
endif


## Complicated menu system for Arduino 1.5
## Another example of Arduino's quick and dirty job
##
#BOARD_NAME       := $(call PARSE_BOARD,$(BOARD_TAG),name)
#ifeq ($(BOARD_NAME),)
#    BOARD_NAME     := $(call PARSE_BOARD,$(BOARD_TAG1),name)
#    ifeq ($(BOARD_NAME),)
#        BOARD_NAME   := $(call PARSE_BOARD,$(BOARD_TAG2),name)
#    endif
#endif
#
#ifeq ($(MCU),)
#    MCU         := $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)
#    ifeq ($(MCU),)
#        MCU       := $(call PARSE_BOARD,$(BOARD_TAG1),build.mcu)
#        ifeq ($(MCU),)
#            MCU     := $(call PARSE_BOARD,$(BOARD_TAG2),build.mcu)
#        endif
#    endif
#endif
#
#ifeq ($(F_CPU),)
#    F_CPU       := $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)
#    ifeq ($(F_CPU),)
#        F_CPU     := $(call PARSE_BOARD,$(BOARD_TAG1),build.f_cpu)
#        ifeq ($(F_CPU),)
#            F_CPU   := $(call PARSE_BOARD,$(BOARD_TAG2),build.f_cpu)
#        endif
#    endif
#endif
#
#ifeq ($(MAX_FLASH_SIZE),)
#    MAX_FLASH_SIZE       := $(call PARSE_BOARD,$(BOARD_TAG),upload.maximum_size)
#    ifeq ($(MAX_FLASH_SIZE),)
#        MAX_FLASH_SIZE     := $(call PARSE_BOARD,$(BOARD_TAG1),upload.maximum_size)
#        ifeq ($(MAX_FLASH_SIZE),)
#            MAX_FLASH_SIZE   := $(call PARSE_BOARD,$(BOARD_TAG2),upload.maximum_size)
#        endif
#    endif
#endif
#
#ifeq ($(AVRDUDE_BAUDRATE),)
#    AVRDUDE_BAUDRATE        := $(call PARSE_BOARD,$(BOARD_TAG),upload.speed)
#    ifeq ($(AVRDUDE_BAUDRATE),)
#        AVRDUDE_BAUDRATE      := $(call PARSE_BOARD,$(BOARD_TAG1),upload.speed)
#        ifeq ($(AVRDUDE_BAUDRATE),)
#            AVRDUDE_BAUDRATE    := $(call PARSE_BOARD,$(BOARD_TAG2),upload.speed)
#        endif
#    endif
#endif
#
#ifeq ($(AVRDUDE_PROGRAMMER),)
#    AVRDUDE_PROGRAMMER      := $(call PARSE_BOARD,$(BOARD_TAG),upload.protocol)
#    ifeq ($(AVRDUDE_PROGRAMMER),)
#        AVRDUDE_PROGRAMMER    := $(call PARSE_BOARD,$(BOARD_TAG1),upload.protocol)
#        ifeq ($(AVRDUDE_PROGRAMMER),)
#            AVRDUDE_PROGRAMMER  := $(call PARSE_BOARD,$(BOARD_TAG2),upload.protocol)
#        endif
#    endif
#endif
#
##BOARD        = $(call PARSE_BOARD,$(BOARD_TAG),board)
###LDSCRIPT     = $(call PARSE_BOARD,$(BOARD_TAG),ldscript)
##VARIANT      = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
#VARIANT      = $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
#ifeq ($(VARIANT),)
#    VARIANT      = $(call PARSE_BOARD,$(BOARD_TAG1),build.variant)
#    ifeq ($(VARIANT),)
#        VARIANT  = $(call PARSE_BOARD,$(BOARD_TAG2),build.variant)
#    endif
#endif

VARIANT_PATH = $(APPLICATION_PATH)/hardware/Microduino/avr/variants/$(VARIANT)

MCU_FLAG_NAME  = mmcu
EXTRA_LDFLAGS  = -lm
EXTRA_CPPFLAGS = -fno-threadsafe-statics -MMD -I$(VARIANT_PATH) $(addprefix -D, $(PLATFORM_TAG))

# Leonardo USB PID VID
#
USB_TOUCH := $(call PARSE_BOARD,$(BOARD_TAG),upload.protocol)
USB_VID   := $(call PARSE_BOARD,$(BOARD_TAG),build.vid)
USB_PID   := $(call PARSE_BOARD,$(BOARD_TAG),build.pid)

ifneq ($(USB_PID),)
    USB_FLAGS += -DUSB_PID=$(USB_PID)
else
    USB_FLAGS += -DUSB_PID=null
endif

ifneq ($(USB_VID),)
    USB_FLAGS += -DUSB_VID=$(USB_VID)
else
    USB_FLAGS += -DUSB_VID=null
endif

# Serial 1200 reset
#
ifeq ($(USB_TOUCH),avr109)
    USB_RESET  = python $(UTILITIES_PATH)/reset_1200.py
endif
