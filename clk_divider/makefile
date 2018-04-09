GHDL = ghdl
GHDL_FLAGS = --std=93

clk_divider_tb: clk_divider_tb.o 
	$(GHDL) -e $(GHDL_FLAGS) clk_divider_tb

clk_divider_tb.o: clk_divider_tb.vhdl util_pkg.o clk_divider.o
	$(GHDL) -a $(GHDL_FLAGS) clk_divider_tb.vhdl

util_pkg.o: ../lib/vhdl_collection/util_pkg.vhdl
	$(GHDL) -a $(GHDL_FLAGS) --work=vhdl_collection ../lib/vhdl_collection/util_pkg.vhdl

clk_divider.o: clk_divider.vhdl
	$(GHDL) -a $(GHDL_FLAGS) clk_divider.vhdl

run: clk_divider_tb
	$(GHDL) -r $(GHDL_FLAGS) clk_divider_tb

graph: clk_divider_tb
	$(GHDL) -r $(GHDL_FLAGS) clk_divider_tb --vcd=clk_divider_tb.vcd
	gtkwave clk_divider_tb.vcd

clean:
	rm -f *.o *.cf *.vcd clk_divider_tb