--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     Method of testing the module uses increasing i_freq_div to produce output
--     clock with less frequency than original one. Then there is a jump to the
--     fastest frequency and it should be sheen a very slow react (at the end of
--     output clock period).
--------------------------------------------------------------------------------
-- Notes:
--     1. Transition between any two i_freq_div must produce only output clock
--        periods so they are directly defined by i_freq_div and input clock.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library vhdl_collection;
use vhdl_collection.util_pkg.all;

use work.clk_divider;


entity clk_divider_tb is
end entity clk_divider_tb;


architecture behavioral of clk_divider_tb is
    
    -- uut generics
    constant g_FREQ_DIV_MAX_VALUE : positive := 7;
    
    -- uut ports
    signal i_clk : std_ulogic := '0';
    signal i_rst : std_ulogic := '0';
    
    signal i_freq_div : integer range 1 to g_FREQ_DIV_MAX_VALUE := 1;
    signal o_clk      : std_ulogic;
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
    -- simulation finished flag to stop the clk_gen process
    shared variable v_sim_finished : boolean := false;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.clk_divider(rtl)
        generic map (
            g_FREQ_DIV_MAX_VALUE => g_FREQ_DIV_MAX_VALUE
        )
        port map (
            i_clk => i_clk,
            i_rst => i_rst,
            
            i_freq_div => i_freq_div,
            o_clk      => o_clk
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
        
        i_rst <= '1'; -- initialize the module
        wait for 3 * c_CLK_PERIOD;
        
        i_rst <= '0';
        wait for 10 * c_CLK_PERIOD;
        
        i_freq_div <= 2;
        wait for 10 * c_CLK_PERIOD;
        
        i_freq_div <= 3;
        wait for 10 * c_CLK_PERIOD;
        
        i_freq_div <= 4;
        wait for 10 * c_CLK_PERIOD;
        
        i_freq_div <= 7;
        wait for 10 * c_CLK_PERIOD;
        
        -- make an instant transition to very high frequency (react should be delayed)
        i_freq_div <= 1;
        wait for 10 * c_CLK_PERIOD;
        
        i_freq_div <= 4;
        wait;
        
    end process stimulus;
    
    verification : process is
    begin
        
        -- asserting only at critical simulation times
        wait for 4.25 * c_CLK_PERIOD;
        
        assert (o_clk = i_clk)
            report "Expected o_clk='" & to_character(i_clk) & "'!"
            severity error;
        wait for 0.5 * c_CLK_PERIOD;
        
        assert (o_clk = i_clk)
            report "Expected o_clk='" & to_character(i_clk) & "'!"
            severity error;
        wait for 8.5 * c_CLK_PERIOD;
        
        assert (o_clk = '0')
            report "Expected o_clk='0'!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_clk = '1')
            report "Expected o_clk='1'!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_clk = '0')
            report "Expected o_clk='0'!"
            severity error;
        wait for 11 * c_CLK_PERIOD;
        
        assert (o_clk = '0')
            report "Expected o_clk='0'!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_clk = '1')
            report "Expected o_clk='1'!"
            severity error;
        wait for 26 * c_CLK_PERIOD;
        
        assert (o_clk = '1')
            report "Expected o_clk='1'!"
            severity error;
        wait for 3.5 * c_CLK_PERIOD;
        
        assert (o_clk = '0')
            report "Expected o_clk='0'!"
            severity error;
        
        v_sim_finished := true;
        wait;
        
    end process verification;
    
end architecture behavioral;
