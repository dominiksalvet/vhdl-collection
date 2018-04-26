--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library vhdl_collection;
use vhdl_collection.util_pkg.all;

library math;
use math.seg7_pkg.all;

use work.hex_to_seg7;


entity hex_to_seg7_tb is
end entity hex_to_seg7_tb;


architecture behavioral of hex_to_seg7_tb is
    
    -- uut generics
    constant g_SEG_ACTIVE_VALUE : std_ulogic := '1';
    
    -- uut ports
    signal i_hex_data  : std_ulogic_vector(3 downto 0) := (others => '0');
    signal o_seg7_data : std_ulogic_vector(6 downto 0);
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
    -- simulation finished flag to stop the clk_gen process
    shared variable v_sim_finished : boolean := false;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.hex_to_seg7(rtl)
        generic map (
            g_SEG_ACTIVE_VALUE => g_SEG_ACTIVE_VALUE
        )
        port map (
            i_hex_data  => i_hex_data,
            o_seg7_data => o_seg7_data
        );
    
    stimulus : process is
    begin
        wait;
    end process stimulus;
    
end architecture behavioral;
