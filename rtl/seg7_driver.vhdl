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
--        significant four bits of i_hex_digits input.
--     3. The input i_hex_digits is not stored anywhere internally to react
--        quickly to the changes on this input.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.seg7_pkg.all;

entity seg7_driver is
    generic (
        g_SEG_ACTIVE_VALUE : std_ulogic := '1'; -- this value will be used for active segments
        g_DIGIT_SEL_VALUE  : std_ulogic := '1'; -- this value will be used for active digits select
        g_DIGIT_COUNT      : positive   := 4 -- total number of controlled digits
    );
    port (
        i_clk : in std_ulogic; -- clock signal
        i_rst : in std_ulogic; -- reset signal
        
        -- input vector, it will be treated as hexadecimal numbers (separated by 4 bits)
        i_hex_digits : in std_ulogic_vector((g_DIGIT_COUNT * 4) - 1 downto 0);
        -- seven segment selector bits
        o_seg7_sel       : out std_ulogic_vector(g_DIGIT_COUNT - 1 downto 0);
        o_seg7_hex_digit : out std_ulogic_vector(6 downto 0) -- current seven segment digit data
    );
end entity seg7_driver;


architecture rtl of seg7_driver is
    signal r_seg7_sel_index : integer range 0 to g_DIGIT_COUNT - 1; -- index of displayed digit
begin
    
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
    
    -- Description:
    --     Propagate changes of digit index and i_hex_digits to the o_seg7_hex_digit output.
    seg7_data_conversion : process (i_hex_digits, r_seg7_sel_index) is
        variable w_sel_hex_data : std_ulogic_vector(3 downto 0);
    begin
        -- window with the converted hexadecimal number
        w_sel_hex_data := i_hex_digits((r_seg7_sel_index * 4) + 3 downto r_seg7_sel_index * 4);
        -- conversion to the seven segment form with eventual negation of active segment value
        o_seg7_hex_digit <= 
            c_SEG7(to_integer(unsigned(w_sel_hex_data))) xnor (6 downto 0 => g_SEG_ACTIVE_VALUE);
    end process seg7_data_conversion;
    
end architecture rtl;
