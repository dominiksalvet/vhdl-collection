--------------------------------------------------------------------------------
-- Description:
--     Uses g_FREQ_DIV with value 5 to see that o_clk period is 5 times longer
--     than the original one of i_clk. Also value '1' is assigned for 2 i_clk
--     period while value '0' is assigned for 3 i_clk period.
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

use work.static_clk_divider; -- static_clk_divider.vhd


entity static_clk_divider_tb is
end entity static_clk_divider_tb;


architecture behavior of static_clk_divider_tb is
    
    -- uut generics
    constant g_FREQ_DIV : positive range 2 to positive'high := 5; 
    
    -- uut ports
    signal i_clk : std_logic := '0';
    signal i_rst : std_logic := '0';
    signal o_clk : std_logic;
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.static_clk_divider(rtl)
        generic map (
            g_FREQ_DIV => g_FREQ_DIV
        )
        port map (
            i_clk => i_clk,
            i_rst => i_rst,
            o_clk => o_clk
        );
    
    i_clk <= not i_clk after c_CLK_PERIOD / 2; -- setup i_clk as periodic signal
    
    stimulus : process is
    begin 
        
        i_rst <= '1'; -- initialize the module
        wait for c_CLK_PERIOD;
        
        i_rst <= '0';
        wait;
        
    end process stimulus;
    
    verification : process is
    begin
        
        wait for c_CLK_PERIOD;
        
        assert (o_clk = '1') -- the first part of the output clock period
            report "Expected inverse o_clk value!" severity error;
        wait for (g_FREQ_DIV / 2) * c_CLK_PERIOD;
        
        assert (o_clk = '0') -- the second part of the output clock period
            report "Expected inverse o_clk value!" severity error;
        wait for ((g_FREQ_DIV - 1) / 2) * c_CLK_PERIOD;
        
    end process verification;
    
end architecture behavior;


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
