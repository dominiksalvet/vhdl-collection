--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Platform:  independent
--------------------------------------------------------------------------------
-- Description:
--     The file represents the description of a Serial-In, Parallel-Out module.
--     It can be set up to operate in LSB-first mode or MSB-first mode.
--------------------------------------------------------------------------------
-- Notes:
--     1. No buffer for parallel data output is used, so it has to be checked
--        the o_data_valid indicator before read.
--     2. For continuous reading the serial input data as a stream, assign '1'
--        to i_data_start. Then the o_data_valid output will have '1' only for
--        one i_clk period.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library vhdl_collection;
use vhdl_collection.util_pkg.all;


entity sipo is
    generic (
        g_DATA_WIDTH : integer range 2 to integer'high := 4; -- output parallelized data width
        -- least significant bit first of the serial input
        g_LSB_FIRST : boolean := true
    );
    port (
        i_clk : in std_ulogic; -- clock signal
        i_rst : in std_ulogic; -- reset signal
        
        i_data_start : in std_ulogic; -- start of the serial input data
        i_data       : in std_ulogic; -- current bit of the serial input data
        
        o_data_valid : out std_ulogic; -- output data validity
        o_data       : out std_ulogic_vector(g_DATA_WIDTH - 1 downto 0) -- output parallelized data
    );
end entity sipo;


architecture rtl of sipo is
    signal r_receiving : boolean; -- receiving indicator
    -- shifter register used for parallelize the serial input data
    signal r_shifter : std_ulogic_vector(g_DATA_WIDTH - 1 downto 0);
begin
    
    o_data <= r_shifter; -- the shifter is directly assigned to the output, see 1. note
    
    -- Description:
    --     Perform one conversion step. Basically it fills the shifter register to parallelize.
    conversion_step : process (i_clk) is
        variable r_received_count : integer range 0 to g_DATA_WIDTH - 1; -- number of received bits
    begin
        if (rising_edge(i_clk)) then
            if (i_rst = '1') then -- initialize the module
                o_data_valid     <= '0';
                r_receiving      <= false;
                r_received_count := 0;
            else
                
                if (i_data_start = '1' or r_receiving) then -- receive one bit
                    o_data_valid <= '0'; -- data are valid as long as not receiving
                    r_receiving  <= true; -- begin the reading the serial input data
                    
                    if (g_LSB_FIRST) then -- first least significant bit
                        r_shifter <= i_data & r_shifter(r_shifter'left downto 1);
                    else -- first most significant bit
                        r_shifter <= r_shifter(r_shifter'left - 1 downto 0) & i_data;
                    end if;
                    
                    if (r_received_count = g_DATA_WIDTH - 1) then -- last received bit
                        o_data_valid     <= '1'; -- data are valid after the receive
                        r_receiving      <= false; -- stop receiving
                        r_received_count := 0; -- reset the received bits count
                    else -- not last received bit
                        r_received_count := r_received_count + 1; -- increment the received count
                    end if;
                end if;
                
            end if;
        end if;
    end process conversion_step;
    
    -- rtl_synthesis off
    input_prevention : process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            
            if (i_data_start = '1' or r_receiving) then -- accept new data to the conversion
                assert (contains_01(i_data))
                    report "Undefined i_data when receiving the serial input bits!"
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
