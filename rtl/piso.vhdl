--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Platform:  independent
--------------------------------------------------------------------------------
-- Description:
--     The file represents the description of a Parallel-In, Serial-Out module.
--     It can be set up to operate in LSB-first mode or MSB-first mode.
--------------------------------------------------------------------------------
-- Notes:
--     1. The parallel input data are stored in the internal buffer and the
--        conversion is performed on this data.
--     2. For continuous reading the parallel input data, assign '1' to the
--        i_start input. Then the data will be read after each '1' value on the
--        o_rdy output.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library vhdl_collection;
use vhdl_collection.util_pkg.all;


entity piso is
    generic (
        g_DATA_WIDTH : integer range 2 to integer'high := 4; -- input parallel data width
        -- least significant bit first of the serialized output
        g_LSB_FIRST : boolean := true
    );
    port (
        i_clk : in std_ulogic; -- clock signal
        i_rst : in std_ulogic; -- reset signal
        
        i_start : in  std_ulogic; -- accept the current input parallel data and serialize them
        i_data  : in  std_ulogic_vector(g_DATA_WIDTH - 1 downto 0); -- the input parallel data
        o_rdy   : out std_ulogic; -- the module is ready to accept next parallel data
        
        o_data_start : out std_ulogic; -- start of the serial output data
        o_data       : out std_ulogic -- current bit of the serial output data
    );
end entity piso;


architecture rtl of piso is
    -- shifter register used for serializing the parallel input data
    signal r_shifter : std_ulogic_vector(g_DATA_WIDTH - 1 downto 0);
    -- number of transmitted bits (0 value stands for not transmitting state)
    signal r_transmitted_count : integer range 0 to g_DATA_WIDTH - 1;
begin
    
    o_rdy <= '1' when r_transmitted_count = 0 else '0'; -- the module is ready when not transmitting
    
    -- least/most significant bit assign generating
    assign_lsb : if (g_LSB_FIRST) generate
        o_data <= r_shifter(r_shifter'right);
    end generate assign_lsb;
    assign_msb : if (not g_LSB_FIRST) generate
        o_data <= r_shifter(r_shifter'left);
    end generate assign_msb;
    
    -- Description:
    --     Perform one conversion step. It works with the shifter register to serialize the input.
    conversion_step : process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            o_data_start <= '0';
            
            if (i_rst = '1') then -- initialize the module
                r_transmitted_count <= 0;
            else
                
                if (r_transmitted_count = 0) then -- if not transmitting
                    if (i_start = '1') then -- if start required
                        o_data_start        <= '1'; -- serial data start
                        r_shifter           <= i_data; -- store converted data internally
                        r_transmitted_count <= r_transmitted_count + 1; -- start the transmitting
                    end if;
                else -- if transmitting
                    if (g_LSB_FIRST) then -- first least significant bit
                        r_shifter <= '-' & r_shifter(r_shifter'left downto 1);
                    else -- first most significant bit
                        r_shifter <= r_shifter(r_shifter'left - 1 downto 0) & '-';
                    end if;
                    
                    if (r_transmitted_count = g_DATA_WIDTH - 1) then -- last transmitted bit
                        r_transmitted_count <= 0; -- stop transmitting
                    else
                        -- increment the transmitted count
                        r_transmitted_count <= r_transmitted_count + 1;
                    end if;
                end if;
                
            end if;
            
        end if;
    end process conversion_step;
    
    -- rtl_synthesis off
    input_prevention : process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            
            if (i_start = '1' and r_transmitted_count = 0) then -- accept new data to the conversion
                assert (contains_01(i_data))
                    report "Undefined i_data when starting the conversion!"
                    severity failure;
            end if;
            
        end if;
    end process input_prevention;
    -- rtl_synthesis on
    
end architecture rtl;
