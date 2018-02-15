-------------------------------------------------------------------------------
-- Standard:    VHDL-1993
-- Platform:    any
-- Dependecies: none
-------------------------------------------------------------------------------
-- Description:
--     This source file represents a generic implementation of a clock divider.
-------------------------------------------------------------------------------
-- Comments:
--     1. Each clk_out period, clk_div is stored internally and changes on this
--        input are not propaged anywhere until the next clk_out period.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity clk_divider is
    generic (
        ONE_CLK_MODE  : boolean; -- when true, clk_out has '1' value only for one clock signal
        COUNTER_WIDTH : positive -- bit widht of an internal clock counter
    ); 
    port (
        clk : in std_logic; -- input clock signal
        rst : in std_logic; -- reset signal
        
        -- clock is divided by value of this signal
        clk_div : in  std_logic_vector(COUNTER_WIDTH - 1 downto 0);
        clk_out : out std_logic -- final output clock
    );
end entity clk_divider;


architecture rtl of clk_divider is
    
    signal counter : std_logic_vector(COUNTER_WIDTH - 1 downto 0); -- internal clock counter
    
    signal clk_reg : std_logic; -- clk_out buffer
    
begin
    
    clk_out <= clk_reg;
    
    -- Inputs:  clk, rst, clk_div, counter, clk_reg
    -- Outputs: counter, clk_reg
    -- Purpose: Implementation of the clk signal counter. The counter uses decrementing.
    count_clk : process (clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                counter <= clk_div;
                clk_reg <= '0';
            else
                
                if (counter = (COUNTER_WIDTH - 1 downto 0 => '0')) then -- decreased to 0
                    counter <= clk_div; -- a new value is assigned to the counter
                    if (ONE_CLK_MODE) then
                        clk_reg <= '1';
                    else
                        clk_reg <= not clk_reg;
                    end if;
                else -- perform one counting step
                    counter <= std_logic_vector(unsigned(counter) - 1);
                    if (ONE_CLK_MODE) then
                        clk_reg <= '0';
                    end if;
                end if;
                
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
