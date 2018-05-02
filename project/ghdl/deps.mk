# test benches
$(BUILD_DIR)/clk_divider_tb.o: $(BUILD_DIR)/string_pkg.o
$(BUILD_DIR)/fifo_tb.o: $(BUILD_DIR)/string_pkg.o
$(BUILD_DIR)/lifo_tb.o: $(BUILD_DIR)/string_pkg.o
$(BUILD_DIR)/mem_copier_tb.o: $(BUILD_DIR)/string_pkg.o $(BUILD_DIR)/rom.o $(BUILD_DIR)/ram.o
$(BUILD_DIR)/piso_tb.o: $(BUILD_DIR)/string_pkg.o
$(BUILD_DIR)/ram_tb.o: $(BUILD_DIR)/string_pkg.o
$(BUILD_DIR)/rom_tb.o: $(BUILD_DIR)/string_pkg.o
$(BUILD_DIR)/seg7_driver_tb.o: $(BUILD_DIR)/string_pkg.o $(BUILD_DIR)/seg7_pkg.o
$(BUILD_DIR)/sipo_tb.o: $(BUILD_DIR)/string_pkg.o

# RTL descriptions
$(BUILD_DIR)/piso.o: $(BUILD_DIR)/verif_pkg.o
$(BUILD_DIR)/ram.o: $(BUILD_DIR)/verif_pkg.o
$(BUILD_DIR)/rom.o: $(BUILD_DIR)/verif_pkg.o
$(BUILD_DIR)/seg7_driver.o: $(BUILD_DIR)/seg7_pkg.o
$(BUILD_DIR)/sipo.o: $(BUILD_DIR)/verif_pkg.o