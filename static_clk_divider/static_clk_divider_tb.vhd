--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--     Uses FREQ_DIV with value 5 to see that clk_out period is 5 times longer
--     than the original one of clk. Also value '1' is assigned for 2 clk period
--     while value '0' is assigned for 3 clk period.
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

use work.static_clk_divider; -- static_clk_divider.vhd


entity static_clk_divider_tb is
end entity static_clk_divider_tb;


architecture behavior of static_clk_divider_tb is
    
    -- static_clk_divider generics
    constant FREQ_DIV : positive range 2 to positive'high := 5; 
    
    -- static_clk_divider ports
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal clk_out : std_logic;
    
    -- clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.static_clk_divider(rtl)
        generic map (
            FREQ_DIV => FREQ_DIV
        )
        port map (
            clk     => clk,
            rst     => rst,
            clk_out => clk_out
        );
    
    -- Purpose: Clock process definition.
    clk_proc : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_proc;
    
    -- Purpose: Stimulus process.
    stim_proc : process
    begin 
        
        rst <= '1'; -- initialize the module
        wait for CLK_PERIOD;
        
        rst <= '0';
        wait;
        
    end process stim_proc;
    
    -- Purpose: Control process.
    contr_proc : process
    begin
        
        wait for CLK_PERIOD;
        
        assert (clk_out = '1') -- the first part of the output clock period
            report "Expected inverse clk_out value!" severity error;
        wait for (FREQ_DIV / 2) * CLK_PERIOD;
        
        assert (clk_out = '0') -- the second part of the output clock period
            report "Expected inverse clk_out value!" severity error;
        wait for ((FREQ_DIV - 1) / 2) * CLK_PERIOD;
        
    end process contr_proc;
    
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
