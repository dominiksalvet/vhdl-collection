--------------------------------------------------------------------------------
-- Standard:    VHDL-1993
-- Platform:    independent
-- Dependecies: pwm.vhd
--------------------------------------------------------------------------------
-- Description:
--     A test bench of the pwm entity with the rtl architecture.
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity pwm_tb is
end entity pwm_tb;


architecture behavior of pwm_tb is
    
    constant CLK_PERIOD : time := 10 ns; -- clock period definition
    
    -- pwm generics
    constant PERIOD : positive := 8; 
    
    -- pwm ports
    signal clk : std_logic;
    signal rst : std_logic;
    
    signal duty    : natural range 0 to PERIOD;
    signal pwm_out : std_logic;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.pwm
        generic map (
            PERIOD => PERIOD
        )
        port map (
            clk => clk,
            rst => rst,

            duty    => duty,
            pwm_out => pwm_out
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

        wait;
        
    end process stim_proc;
    
    -- Purpose: Control process.
    contr_proc : process
    begin
    
        wait;
        
    end process contr_proc;
    
end architecture behavior;


--------------------------------------------------------------------------------
-- MIT License
--
-- Copyright (c) 2017-2018 Dominik Salvet
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

