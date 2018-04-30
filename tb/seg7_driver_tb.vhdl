--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     Simulation represents an example where the message "CAFE" will be
--     displayed. The seven segment display, which shows "E", has the lowest
--     index and so it is selected by "0001" value on o_seg7_sel output signal
--     (eventually "1110"). After 8*c_CLK_PERIOD, the message will be changed to
--     the "FACE".
--------------------------------------------------------------------------------
-- Notes:
--     1. Do not change g_DIGIT_COUNT unless you know about fatal impact on the
--        simulation progress.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

use work.string_pkg.all;
use work.seg7_pkg.all;
use work.seg7_driver;

entity seg7_driver_tb is
end entity seg7_driver_tb;


architecture behavioral of seg7_driver_tb is
    
    -- uut generics
    constant g_SEG_ACTIVE_VALUE : std_ulogic := '1';
    constant g_DIGIT_SEL_VALUE  : std_ulogic := '1';
    constant g_DIGIT_COUNT      : positive   := 4;
    
    -- uut ports
    signal i_clk : std_ulogic := '0';
    signal i_rst : std_ulogic := '0';
    
    signal i_data      : std_ulogic_vector((g_DIGIT_COUNT * 4) - 1 downto 0) := (others => '0');
    signal o_seg7_sel  : std_ulogic_vector(g_DIGIT_COUNT - 1 downto 0);
    signal o_seg7_data : std_ulogic_vector(6 downto 0);
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
    -- simulation finished flag to stop the clk_gen process
    shared variable v_sim_finished : boolean := false;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.seg7_driver(rtl)
        generic map (
            g_SEG_ACTIVE_VALUE => g_SEG_ACTIVE_VALUE,
            g_DIGIT_SEL_VALUE  => g_DIGIT_SEL_VALUE,
            g_DIGIT_COUNT      => g_DIGIT_COUNT
        )
        port map (
            i_clk => i_clk,
            i_rst => i_rst,
            
            i_data      => i_data,
            o_seg7_sel  => o_seg7_sel,
            o_seg7_data => o_seg7_data
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
    
    stim : process is
    begin
        
        i_rst  <= '1'; -- initialize the module
        i_data <= x"CAFE";
        wait for c_CLK_PERIOD;
        
        i_rst <= '0';
        wait for 7 * c_CLK_PERIOD;
        
        i_data <= x"FACE";
        wait;
        
    end process stim;
    
    verif : process is
    begin
        
        wait for c_CLK_PERIOD;
        
        ---- THE "CAFE" MESSAGE
        
        assert (o_seg7_data = (c_SEG7(16#E#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)))
            report "Expected o_seg7_data=""" &
            to_string(c_SEG7(16#E#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)) & """!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_seg7_data = (c_SEG7(16#F#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)))
            report "Expected o_seg7_data=""" &
            to_string(c_SEG7(16#F#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)) & """!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_seg7_data = (c_SEG7(16#A#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)))
            report "Expected o_seg7_data=""" &
            to_string(c_SEG7(16#A#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)) & """!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_seg7_data = (c_SEG7(16#C#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)))
            report "Expected o_seg7_data=""" &
            to_string(c_SEG7(16#C#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)) & """!"
            severity error;
        wait for 5 * c_CLK_PERIOD; -- need to wait 9*c_CLK_PERIOD until the "FACE" message starts
        
        ---- THE "FACE" MESSAGE
        
        assert (o_seg7_data = (c_SEG7(16#E#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)))
            report "Expected o_seg7_data=""" &
            to_string(c_SEG7(16#E#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)) & """!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_seg7_data = (c_SEG7(16#C#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)))
            report "Expected o_seg7_data=""" &
            to_string(c_SEG7(16#C#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)) & """!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_seg7_data = (c_SEG7(16#A#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)))
            report "Expected o_seg7_data=""" &
            to_string(c_SEG7(16#A#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)) & """!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_seg7_data = (c_SEG7(16#F#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)))
            report "Expected o_seg7_data=""" &
            to_string(c_SEG7(16#F#) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE)) & """!"
            severity error;
        
        v_sim_finished := true;
        wait;
        
    end process verif;
    
end architecture behavioral;
