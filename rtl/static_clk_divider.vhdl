--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     This source file represents a generic implementation of a clock divider
--     with a fixed frequency divisor.
--------------------------------------------------------------------------------
-- Notes:
--     1. Period of output o_clk starts with '1' value, followed by '0'.
--     2. When the g_FREQ_DIV is set as an odd number, the o_clk will have '1'
--        value one i_clk period shorter than '0' value per o_clk period.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity static_clk_divider is
    generic (
        -- frequency divisor, <o_clk_freq>=<i_clk_freq>/g_FREQ_DIV
        g_FREQ_DIV : integer range 2 to integer'high := 5
    );
    port (
        i_clk : in  std_ulogic; -- input clock signal
        i_rst : in  std_ulogic; -- reset signal
        o_clk : out std_ulogic -- final output clock
    );
end entity static_clk_divider;


architecture rtl of static_clk_divider is
begin
    
    -- Description:
    --     Perform i_clk frequency division by counting and create the final o_clk signal.
    divide_i_clk_freq : process (i_clk) is
        variable r_i_clk_counter : integer range 1 to g_FREQ_DIV; -- internal i_clk counter
    begin
        if (rising_edge(i_clk)) then
            -- need to reset the r_i_clk_counter and begin the new o_clk period
            if (i_rst = '1' or r_i_clk_counter = g_FREQ_DIV) then
                o_clk           <= '1';
                r_i_clk_counter := 1;
            else
                
                if (r_i_clk_counter = (g_FREQ_DIV / 2)) then -- half of the o_clk period
                    o_clk <= '0';
                end if;
                
                r_i_clk_counter := r_i_clk_counter + 1; -- counting i_clk rising edges
                
            end if;
        end if;
    end process divide_i_clk_freq;
    
end architecture rtl;
