--------------------------------------------------------------------------------
-- Copyright (C) 2016-2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     Generic implementation of multiple seven segment displays driver.
--------------------------------------------------------------------------------
-- Notes:
--     1. This implementation uses o_seg7_sel signal to select active digit/s
--        and so it is meant to perform fast switching between the digits. Then
--        the final refresh frequency of all the display is equal to i_clk
--        frequency divided by number of unique digits.
--     2. The least significant bit of o_seg7_sel output meets the least
--        significant four bits of i_data input.
--     3. The input i_data is not stored anywhere internally to quickly react to
--        the changes on this input.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

use work.hex_to_seg7;


entity seg7_driver is
    generic (
        g_SEG_ACTIVE_VALUE : std_ulogic := '1'; -- this value will be used for active segments
        g_DIGIT_SEL_VALUE  : std_ulogic := '1'; -- this value will be used for active digits select
        g_DIGIT_COUNT      : positive   := 4 -- total number of controlled digits
    );
    port (
        i_clk : in std_ulogic; -- clock signal
        i_rst : in std_ulogic; -- reset signal
        
        -- input data vector, will be treated as hexadecimal numbers (separated by 4 bits)
        i_data : in std_ulogic_vector((g_DIGIT_COUNT * 4) - 1 downto 0);
        -- seven segment select bits
        o_seg7_sel  : out std_ulogic_vector(g_DIGIT_COUNT - 1 downto 0);
        o_seg7_data : out std_ulogic_vector(6 downto 0) -- actual seven segment digit data
    );
end entity seg7_driver;


architecture rtl of seg7_driver is
    
    -- hex_to_seg7_0 ports
    signal hts_i_hex_data  : std_ulogic_vector(3 downto 0);
    
    signal r_seg7_sel_index : integer range 0 to g_DIGIT_COUNT - 1; -- index of displayed digit
    
begin
    
    -- instantiation of hex_to_seg7 for conversion hexadecimal form to seven segment form
    hex_to_seg7_0 : entity work.hex_to_seg7(rtl)
        generic map (
            g_SEG_ACTIVE_VALUE => g_SEG_ACTIVE_VALUE
        )
        port map (
            i_hex_data  => hts_i_hex_data,
            o_seg7_data => o_seg7_data
        );
    
    -- window with the converted hexadecimal number
    hts_i_hex_data <= i_data((r_seg7_sel_index * 4) + 3 downto r_seg7_sel_index * 4);
    
    -- Description:
    --     Compute next index of the seven segment digits.
    compute_next_index : process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            if (i_rst = '1') then
                r_seg7_sel_index <= 0;
            else
                
                if (r_seg7_sel_index = g_DIGIT_COUNT - 1) then
                    r_seg7_sel_index <= 0;
                else
                    r_seg7_sel_index <= r_seg7_sel_index + 1;
                end if;
                
            end if;
        end if;
    end process compute_next_index;
    
    -- Description:
    --     Propagate changes of digit index to the o_seg7_sel output.
    seg7_sel_switch : process (r_seg7_sel_index) is
    begin
        o_seg7_sel                   <= (others => not g_DIGIT_SEL_VALUE);
        o_seg7_sel(r_seg7_sel_index) <= g_DIGIT_SEL_VALUE;
    end process seg7_sel_switch;
    
end architecture rtl;
