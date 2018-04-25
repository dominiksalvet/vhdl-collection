################################################################################
#  Notes:
#      1. This makefile is intended to be used with GHDL compiler using LLVM
#         code generator, the mcode generator is not generally supported, but it
#         is likely to work. In that case, however, it will always rebuild
#         everything from scratch.
################################################################################

## ENVIRONMENT CONFIGURATION

SHELL := /bin/sh
MKDIR_P := mkdir -p

## PROJECT CONFIGURATION

# default entity architectures
SIM_ARCH := behavioral

# directory definitions
SRC_DIR ?= src
LIB_DIR ?=
SIM_DIR ?= sim
BUILD_DIR ?= build

## GENERAL CONFIGURATION

# VHDL compiler
VHDLC := ghdl

VHDLC_FLAGS_GENERAL := --std=93 --ieee=standard --warn-library --warn-reserved --warn-parenthesis
VHDLC_FLAGS := --workdir=$(BUILD_DIR) -P$(BUILD_DIR) $(VHDLC_FLAGS_GENERAL)
VHDLC_FLAGS_LOCAL := --workdir=. -P. $(VHDLC_FLAGS_GENERAL)

VHDLC_SIM_FLAGS := --assert-level=failure --ieee-asserts=enable

# VCD file viewer
VCD_VIEWER ?= gtkwave

## TARGET

$(BUILD_DIR)/pwm_tb-$(SIM_ARCH): $(BUILD_DIR)/pwm_tb.o
	@$(MKDIR_P) $(dir $@)
	$(VHDLC) -e $(VHDLC_FLAGS) -o $@ pwm_tb $(SIM_ARCH)

## DEPENDENCIES

$(BUILD_DIR)/pwm_tb.o: $(SIM_DIR)/pwm_tb.vhdl $(BUILD_DIR)/pwm.o
	@$(MKDIR_P) $(dir $@)
	$(VHDLC) -a $(VHDLC_FLAGS) $<

$(BUILD_DIR)/pwm.o: $(SRC_DIR)/pwm.vhdl
	@$(MKDIR_P) $(dir $@)
	$(VHDLC) -a $(VHDLC_FLAGS) $<

## CUSTOM TARGETS

.PHONY: module run view clean

module: $(BUILD_DIR)/pwm.o

run: $(BUILD_DIR)/pwm_tb-$(SIM_ARCH)
	cd $(BUILD_DIR) && $(VHDLC) -r $(VHDLC_FLAGS_LOCAL) pwm_tb $(SIM_ARCH) $(VHDLC_SIM_FLAGS)

view: $(BUILD_DIR)/pwm_tb-$(SIM_ARCH)
	cd $(BUILD_DIR) && $(VHDLC) -r $(VHDLC_FLAGS_LOCAL) pwm_tb $(SIM_ARCH) $(VHDLC_SIM_FLAGS) --vcd=pwm_tb.vcd
	$(VCD_VIEWER) $(BUILD_DIR)/pwm_tb.vcd

clean:
	rm -rf $(BUILD_DIR)

################################################################################
#  MIT License
#
#  Copyright (c) 2018 Dominik Salvet
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.
################################################################################
