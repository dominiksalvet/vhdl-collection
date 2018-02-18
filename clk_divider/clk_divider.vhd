-------------------------------------------------------------------------------
-- Standard:    VHDL-1993
-- Platform:    independent
-- Dependecies: none
-------------------------------------------------------------------------------
-- Description:
--     This source file represents a generic implementation of a clock divider.
--     It supports to dynamically change frequency divisor, including 1 value.
-------------------------------------------------------------------------------
-- Comments:
--     1. Period of output clk_out starts with '1' value, followed by '0'.
--     2. When it is not possible to perform clock frequency division without
--        a remainder, the clk_out will have '1' value one clk period shorter
--        than '0' value per clk_out period.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity clk_divider is
    generic (
        FREQ_DIV_MAX_VALUE : positive -- maximum available frequency divisor value
    );
    port (
        clk : in std_logic; -- input clock signal
        rst : in std_logic; -- reset signal
        
        -- freq_div: clk frequency is divided by value of this number, clk_out=clk/freq_div
        freq_div : in  positive range 1 to FREQ_DIV_MAX_VALUE;
        clk_out  : out std_logic -- final output clock
    );
end entity clk_divider;


architecture rtl of clk_divider is
    
    signal use_direct_clk : std_logic;
    
    signal divided_clk : std_logic;
    
begin
    
    clk_out <= clk when use_direct_clk = '1' else divided_clk;
    
    -- Inputs:  clk, freq_div
    -- Outputs: use_direct_clk
    -- Purpose: Check for the input when the frequency division by 1 is required.
    direct_clk_checking : process (clk)
    begin
        if (rising_edge(clk)) then
            if (freq_div = 1) then
                use_direct_clk <= '1';
            else
                use_direct_clk <= '0';
            end if;
        end if;
    end process direct_clk_checking;
    
    -- Inputs:  clk, rst, freq_div
    -- Outputs: clk_out
    -- Purpose: Perform clk requency division by counting and create the final clk_out signal.
    divide_clk_freq : process (clk)
        -- freq_div_reg: register to store internally freq_div value in a time
        variable freq_div_reg : positive range 1 to FREQ_DIV_MAX_VALUE;
        variable clk_counter  : positive range 1 to FREQ_DIV_MAX_VALUE; -- internal clk counter
    begin
        if (rising_edge(clk)) then
            -- need to reset the clk_counter and begin the new clk_out period
            if (rst = '1' or clk_counter = freq_div_reg) then
                divided_clk  <= '1';
                freq_div_reg := freq_div;
                clk_counter  := 1;
            else
                
                if (clk_counter = (freq_div_reg / 2)) then -- half of the clk_out period
                    divided_clk <= '0';
                end if;
                
                clk_counter := clk_counter + 1; -- counting clk rising edges
                
            end if;
        end if;
    end process divide_clk_freq;
    
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
