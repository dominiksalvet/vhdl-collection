--------------------------------------------------------------------------------
-- Description:
--     The simulations increments the duty value per each PWM period. It also
--     checks pwm_out value at critical points - half clk period before falling
--     edge of the pwm_out signal (should be '1') and half period after (should
--     be '0'). Then, it will change duty from 8 to 0 half of clk period after
--     the pwm_out period begins. This demonstrates the function of internal
--     register and so duty is stored and will not change until new beginning
--     of the pwm_out period.
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

use work.pwm; -- pwm.vhd


entity pwm_tb is
end entity pwm_tb;


architecture behavior of pwm_tb is
    
    -- uut generics
    constant PERIOD : positive := 8; 
    
    -- uut ports
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    
    signal duty    : natural range 0 to PERIOD := 0;
    signal pwm_out : std_logic;
    
    -- clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
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
    
    clk_proc : process is
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_proc;
    
    stim_proc : process is
    begin
        
        rst <= '1'; -- module initialization
        wait for CLK_PERIOD;
        
        rst <= '0';
        wait for CLK_PERIOD;
        
        -- checks correct value of the first part of the pwm_out signal for duty=0
        assert (pwm_out = '0')
            report "Inverse pwm_out value expected!" severity error;
        wait for (PERIOD - 1) * CLK_PERIOD; -- pass the section with duty=0
        
        -- incrementing duty value, one duty per pwm_out period (as the loop parameters define)
        for i in 0 to (PERIOD ** 2) - 1 loop
            
            if (i mod PERIOD = 0) then -- new pwm_out period
                duty <= duty + 1;
            end if;
            wait for CLK_PERIOD; -- wait to get to individual parts of PWM period
            
            -- half clk period before falling edge of the pwm_out signal
            if (i mod PERIOD = (duty - 1) mod (PERIOD + 1)) then
                assert (pwm_out = '1')
                    report "Inverse pwm_out value expected!" severity error;
                -- half clk period after falling edge of the pwm_out signal
            elsif (i mod PERIOD = duty mod (PERIOD + 1)) then
                assert (pwm_out = '0')
                    report "Inverse pwm_out value expected!" severity error;
            end if;
            
        end loop;
        -- apply delay for simulate late duty change
        wait for CLK_PERIOD;
        
        duty <= 0; -- duty 0 will be accepted after already started pwm_out period
        wait for CLK_PERIOD; -- wait one clk to verify the behavior described above
        
        assert (pwm_out = '1') -- pwm_out must be '1', duty to 0 has been changed too late
            report "Inverse pwm_out value expected!" severity error;
        -- get to the time half period before clk_pwm falling edge
        wait for (PERIOD - 2) * CLK_PERIOD;
        
        assert (pwm_out = '1')
            report "Inverse pwm_out value expected!" severity error;
        -- get to the time half period after clk_pwm falling edge
        wait for CLK_PERIOD;
        
        assert (pwm_out = '0')
            report "Inverse pwm_out value expected!" severity error;
        wait;
        
    end process stim_proc;
    
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
