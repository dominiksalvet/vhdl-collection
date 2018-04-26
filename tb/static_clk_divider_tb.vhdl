--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Description:
--     Uses g_FREQ_DIV with value 5 to see that o_clk period is 5 times longer
--     than the original one of i_clk. Also value '1' is assigned for 2 i_clk
--     period while value '0' is assigned for 3 i_clk period.
--------------------------------------------------------------------------------
-- Notes:
--     1. The simulation tests only c_PERIOD_COUNT_TO_TEST o_clk periods.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

use work.static_clk_divider;


entity static_clk_divider_tb is
end entity static_clk_divider_tb;


architecture behavioral of static_clk_divider_tb is
    
    -- uut generics
    constant g_FREQ_DIV : integer range 2 to integer'high := 5; 
    
    -- uut ports
    signal i_clk : std_ulogic := '0';
    signal i_rst : std_ulogic := '0';
    signal o_clk : std_ulogic;
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
    constant c_PERIOD_COUNT_TO_TEST : positive := 10;
    
    -- simulation finished flag to stop the clk_gen process
    shared variable v_sim_finished : boolean := false;
    
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
        wait for c_CLK_PERIOD;
        
        i_rst <= '0';
        wait;
        
    end process stimulus;
    
    verification : process is
    begin
        
        for i in 1 to c_PERIOD_COUNT_TO_TEST loop
            wait for c_CLK_PERIOD;
            
            assert (o_clk = '1') -- the first part of the output clock period
                report "Expected o_clk='1'!"
                severity error;
            wait for (g_FREQ_DIV / 2) * c_CLK_PERIOD;
            
            assert (o_clk = '0') -- the second part of the output clock period
                report "Expected o_clk='0'!"
                severity error;
            wait for ((g_FREQ_DIV - 1) / 2) * c_CLK_PERIOD;
        end loop;
        
        v_sim_finished := true;
        wait;
        
    end process verification;
    
end architecture behavioral;
