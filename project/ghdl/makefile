#-------------------------------------------------------------------------------
# Copyright (C) 2018 Dominik Salvet
# SPDX-License-Identifier: MIT
#-------------------------------------------------------------------------------
# Notes:
#     1. This makefile is intended to be used with GHDL compiler using a LLVM
#        code generator. An mcode generator is not generally supported, but it
#        is likely to work. In that case, however, it would always rebuild
#        everything from scratch.
#-------------------------------------------------------------------------------

## ENVIRONMENT

SHELL := /bin/sh
SED := sed
MKDIR := mkdir
RM_RF := rm -rf

## PROJECT

# expected VHDL file extension
VHDL_EXT := .vhdl

# expected test bench architecture name
TB_ARCH := behavioral

# directory definitions
BUILD_DIR := build
LIB_DIR := ../../lib
RTL_DIR := ../../rtl
TB_DIR := ../../tb

## OTHERS

# VHDL compiler
VHDLC := ghdl

VHDLC_FLAGS_GENERAL := --std=93 --ieee=standard --warn-library --warn-reserved --warn-parenthesis
VHDLC_FLAGS := --workdir=$(BUILD_DIR) -P$(BUILD_DIR) $(VHDLC_FLAGS_GENERAL)
VHDLC_FLAGS_LOCAL := --workdir=. -P. $(VHDLC_FLAGS_GENERAL)

VHDLC_SIM_FLAGS := --assert-level=failure --ieee-asserts=enable

# VCD file viewer
VCD_VIEWER := gtkwave


SRC := $(wildcard $(LIB_DIR)/*/*$(VHDL_EXT)) $(wildcard $(RTL_DIR)/*$(VHDL_EXT)) $(wildcard $(TB_DIR)/*$(VHDL_EXT))
DEPS := $(addprefix $(BUILD_DIR)/,$(notdir $(SRC:$(VHDL_EXT)=.d)))


## RULES

.PHONY: clean
#.SECONDARY:
#.SECONDARY: $(BUILD_DIR)/%.o $(DEP_DIR)/%.d

$(BUILD_DIR):
	$(MKDIR) $@

# executables
$(BUILD_DIR)/%-$(TB_ARCH): $(BUILD_DIR)/%.o | $(BUILD_DIR)
	$(VHDLC) -e $(VHDLC_FLAGS) -o $@ $* $(TB_ARCH)

# test benches
$(BUILD_DIR)/%_tb.o: $(TB_DIR)/%_tb$(VHDL_EXT) $(BUILD_DIR)/%.o | $(BUILD_DIR)
	$(VHDLC) -a $(VHDLC_FLAGS) $<

# RTL descriptions
$(BUILD_DIR)/%.o: $(RTL_DIR)/%$(VHDL_EXT) | $(BUILD_DIR)
	$(VHDLC) -a $(VHDLC_FLAGS) $<

# libraries
# automatically assign package to a library defined by directory that it is placed in
$(BUILD_DIR)/%_pkg.o: $(LIB_DIR)/*/%_pkg$(VHDL_EXT) | $(BUILD_DIR)
	$(VHDLC) -a --work=$(lastword $(subst /, ,$(dir $<))) $(VHDLC_FLAGS) $<

clean:
	$(RM_RF) $(BUILD_DIR)


## DEPENDENCIES

$(BUILD_DIR)/%_tb.d: $(TB_DIR)/%_tb$(VHDL_EXT) | $(BUILD_DIR)
	./vhdldepend.sh $< '$$(BUILD_DIR)/' > $@

$(BUILD_DIR)/%.d: $(RTL_DIR)/%$(VHDL_EXT) | $(BUILD_DIR)
	./vhdldepend.sh $< '$$(BUILD_DIR)/' > $@

-include $(DEPS)
