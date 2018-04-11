################################################################################
#  Notes:
#      1. This makefile is intended to be used with GHDL compiler using LLVM
#         code generator.
#      2. The mcode generator is not generally supported, but it is likely to
#         work. In that case, however, it will always rebuild everything from
#         scratch.
################################################################################

# system configuration
MKDIR_P = mkdir -p

# directory definitions
SRC_DIR = ./src
SIM_DIR = ./sim
BUILD_DIR = ./build

# VHDL compiler configuration
VHDLC = ghdl
VHDLC_FLAGS = --ieee=standard --std=93 --workdir=$(BUILD_DIR) -P$(BUILD_DIR)

# waveform viewer configuration
VCD_VIEWER = gtkwave

# VHDL files configuration
VHDL_EXT = .vhdl
VHDL_LIB_DIR = ../lib

# TARGET

$(BUILD_DIR)/clk_divider_tb: $(BUILD_DIR)/clk_divider_tb.o
	@$(MKDIR_P) $(BUILD_DIR)
	$(VHDLC) -e $(VHDLC_FLAGS) -o $@ clk_divider_tb

$(BUILD_DIR)/clk_divider_tb.o: $(SIM_DIR)/clk_divider_tb$(VHDL_EXT) $(BUILD_DIR)/util_pkg.o $(BUILD_DIR)/clk_divider.o
	@$(MKDIR_P) $(BUILD_DIR)
	$(VHDLC) -a $(VHDLC_FLAGS) $<

# DEPENDENCIES

$(BUILD_DIR)/util_pkg.o: $(VHDL_LIB_DIR)/vhdl_collection/util_pkg$(VHDL_EXT)
	@$(MKDIR_P) $(BUILD_DIR)
	$(VHDLC) -a $(VHDLC_FLAGS) --work=vhdl_collection $<

$(BUILD_DIR)/clk_divider.o: $(SRC_DIR)/clk_divider$(VHDL_EXT)
	@$(MKDIR_P) $(BUILD_DIR)
	$(VHDLC) -a $(VHDLC_FLAGS) $<

# CUSTOM TARGETS

.PHONY: run view clean

run: $(BUILD_DIR)/clk_divider_tb
	cd $(BUILD_DIR); $(VHDLC) -r --ieee=standard --std=93 clk_divider_tb

view: $(BUILD_DIR)/clk_divider_tb
	cd $(BUILD_DIR); $(VHDLC) -r --ieee=standard --std=93 clk_divider_tb --vcd=clk_divider_tb.vcd
	$(VCD_VIEWER) $(BUILD_DIR)/clk_divider_tb.vcd

clean:
	rm -r $(BUILD_DIR)

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
