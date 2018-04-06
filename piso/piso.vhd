--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
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
use vhdl_collection.util_pkg.all; -- util_pkg.vhd


entity piso is
    generic (
        g_DATA_WIDTH : integer range 2 to integer'high := 4; -- input parallel data width
        -- least significant bit first of the serialized output
        g_LSB_FIRST : boolean := true
    );
    port (
        i_clk : in std_logic; -- clock signal
        i_rst : in std_logic; -- reset signal
        
        i_start : in  std_logic; -- accept the current input parallel data and serialize them
        i_data  : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- the input parallel data
        o_rdy   : out std_logic; -- the module is ready to accept next parallel data
        
        o_data_start : out std_logic; -- start of the serial output data
        o_data       : out std_logic -- current bit of the serial output data
    );
end entity piso;


architecture rtl of piso is
    signal r_transmitting : std_logic; -- transmitting indicator
    -- shifter register used for serializing the parallel input data
    signal r_shifter : std_logic_vector(g_DATA_WIDTH - 1 downto 0);
begin
    
    o_rdy <= not r_transmitting; -- the module is ready when not transmitting
    
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
        -- number of transmitted bits
        variable r_transmitted_count : integer range 1 to g_DATA_WIDTH - 1;
    begin
        if (rising_edge(i_clk)) then
            o_data_start <= '0';
            
            if (i_rst = '1') then -- initialize the module
                r_transmitting <= '0';
            else
                
                if (r_transmitting = '0') then -- if not transmitting
                    if (i_start = '1') then -- if start required
                        o_data_start        <= '1'; -- serial data start
                        r_transmitting      <= '1'; -- set transmitting
                        r_shifter           <= i_data; -- store converted data internally
                        r_transmitted_count := 1; -- one bit is transmitted now
                    end if;
                else
                    if (g_LSB_FIRST) then -- first least significant bit
                        r_shifter <= '-' & r_shifter(r_shifter'left downto 1);
                    else -- first most significant bit
                        r_shifter <= r_shifter(r_shifter'left - 1 downto 0) & '-';
                    end if;
                    
                    if (r_transmitted_count = g_DATA_WIDTH - 1) then -- last transmitted bit
                        r_transmitting <= '0'; -- stop transmitting
                    end if;
                    -- increment the transmitted count
                    r_transmitted_count := r_transmitted_count + 1;
                end if;
                
            end if;
            
        end if;
    end process conversion_step;
    
    -- rtl_synthesis off
    input_prevention : process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            
            if (i_start = '1' and r_transmitting = '0') then -- accept new data to the conversion
                assert (contains_01(i_data))
                    report "Undefined i_data when starting the conversion!"
                    severity failure;
            end if;
            
        end if;
    end process input_prevention;
    -- rtl_synthesis on
    
end architecture rtl;


--------------------------------------------------------------------------------
-- MIT License
--
-- Copyright (c) 2018 Dominik Salvet
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--------------------------------------------------------------------------------
