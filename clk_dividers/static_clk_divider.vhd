-------------------------------------------------------------------------------
-- Standard:    VHDL-1993
-- Platform:    any
-- Dependecies: none
-------------------------------------------------------------------------------
-- Description:
--     This source file represents a generic implementation of a clock divider
--     with fixed frequency divisor.
-------------------------------------------------------------------------------
-- Comments:
--     1. Period of output clk_out starts with '1' value, followed by '0'.
--     2. When the FREQ_DIV is set as an odd number, the clk_out will have '1'
--        value one clk period shorter then '0' value per clk_out period.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity static_clk_divider is
    generic (
        FREQ_DIV : positive range 2 to positive'high -- frequency divisor, clk_out=clk/FREQ_DIV
    );
    port (
        clk : in std_logic; -- input clock signal
        rst : in std_logic; -- reset signal
        
        clk_out : out std_logic -- final output clock
    );
end entity static_clk_divider;


architecture rtl of static_clk_divider is
begin
    
    -- Inputs:  clk, rst
    -- Outputs: clk_out
    -- Purpose: Implementation of the clk signal counter. The counter uses an incrementing method.
    count_clk : process (clk)
        variable clk_counter : positive range 1 to FREQ_DIV; -- internal clk counter
    begin
        if (rising_edge(clk)) then
            -- need to reset the clk_counter and begin new clk_out period
            if (rst = '1' or clk_counter = FREQ_DIV) then
                clk_out     <= '1';
                clk_counter := 1;
            else
                
                if (clk_counter = (FREQ_DIV / 2)) then -- half of a clk_out period
                    clk_out <= '0';
                end if;
                
                clk_counter := clk_counter + 1; -- counting
                
            end if;
        end if;
    end process count_clk;
    
end architecture rtl;


-------------------------------------------------------------------------------
-- MIT License
--
-- Copyright (c) 2016-2018 Dominik Salvet
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.
-------------------------------------------------------------------------------
