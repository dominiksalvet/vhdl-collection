--------------------------------------------------------------------------------
-- Copyright (C) 2017-2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     The simulations increments the i_duty value per each PWM period. It also
--     checks o_signal value at critical points - half i_clk period before
--     falling edge of the o_signal signal (should be '1') and half period after
--     (should be '0'). Then, it will change i_duty from 8 to 0 half of i_clk
--     period after the o_signal period begins. This demonstrates the function
--     of internal register and so i_duty is stored and will not change until
--     new beginning of the o_signal period.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

use work.pwm;

entity pwm_tb is
end entity pwm_tb;


architecture behavioral of pwm_tb is
    
    -- uut generics
    constant g_PERIOD : positive := 8; 
    
    -- uut ports
    signal i_clk : std_ulogic := '0';
    signal i_rst : std_ulogic := '0';
    
    signal i_duty   : integer range 0 to g_PERIOD := 0;
    signal o_signal : std_ulogic;
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
    -- simulation finished flag to stop the clk_gen process
    shared variable v_sim_finished : boolean := false;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.pwm(rtl)
        generic map (
            g_PERIOD => g_PERIOD
        )
        port map (
            i_clk => i_clk,
            i_rst => i_rst,
            
            i_duty   => i_duty,
            o_signal => o_signal
        );
    
    clk_gen : process is
    begin
        i_clk <= '0';
        wait for c_CLK_PERIOD / 2;
        i_clk <= '1';
        wait for c_CLK_PERIOD / 2;
        
        if (v_sim_finished) then
            wait;
        end if;
    end process clk_gen;
    
    stimulus : process is
    begin
        
        i_rst <= '1'; -- module initialization
        wait for c_CLK_PERIOD;
        
        i_rst <= '0';
        wait for c_CLK_PERIOD;
        
        -- checks correct value of the first part of the o_signal signal for i_duty=0
        assert (o_signal = '0')
            report "Expected o_signal='0'!"
            severity error;
        wait for (g_PERIOD - 1) * c_CLK_PERIOD; -- pass the section with i_duty=0
        
        -- incrementing i_duty value, one i_duty per o_signal period (as the loop parameters define)
        for i in 0 to (g_PERIOD ** 2) - 1 loop
            
            if (i mod g_PERIOD = 0) then -- new o_signal period
                i_duty <= i_duty + 1;
            end if;
            wait for c_CLK_PERIOD; -- wait to get to individual parts of PWM period
            
            -- half i_clk period before falling edge of the o_signal signal
            if (i mod g_PERIOD = (i_duty - 1) mod (g_PERIOD + 1)) then
                assert (o_signal = '1')
                    report "Expected o_signal='1'!"
                    severity error;
            end if;
            
            -- half i_clk period after falling edge of the o_signal signal
            if (i mod g_PERIOD = i_duty mod (g_PERIOD + 1)) then
                assert (o_signal = '0')
                    report "Expected o_signal='0'!"
                    severity error;
            end if;
            
        end loop;
        -- apply delay for simulate late i_duty change
        wait for c_CLK_PERIOD;
        
        i_duty <= 0; -- i_duty 0 will be accepted after already started o_signal period
        wait for c_CLK_PERIOD; -- wait one i_clk to verify the behavior described above
        
        assert (o_signal = '1') -- o_signal must be '1', i_duty to 0 has been changed too late
            report "Expected o_signal='1'!"
            severity error;
        -- get to the time half period before clk_pwm falling edge
        wait for (g_PERIOD - 2) * c_CLK_PERIOD;
        
        assert (o_signal = '1')
            report "Expected o_signal='1'!"
            severity error;
        -- get to the time half period after clk_pwm falling edge
        wait for c_CLK_PERIOD;
        
        assert (o_signal = '0')
            report "Expected o_signal='0'!"
            severity error;
        
        v_sim_finished := true;
        wait;
        
    end process stimulus;
    
end architecture behavioral;
