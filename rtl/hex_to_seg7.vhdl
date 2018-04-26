--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     Converter from hexadecimal data to seven segment data. It is possible to
--     choose an active level of o_seg7_data.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library math;
use math.seg7_pkg.all;


entity hex_to_seg7 is
    generic (
        g_SEG_ACTIVE_VALUE : std_ulogic := '1' -- this value will be used for active segments
    );
    port (
        i_hex_data  : in  std_ulogic_vector(3 downto 0); -- 4-bit data as encoded hexadecimal number
        o_seg7_data : out std_ulogic_vector(6 downto 0) -- 7-bit segment data, bit per each segment
    );
end entity hex_to_seg7;


architecture rtl of hex_to_seg7 is
    signal w_seg7_data : std_ulogic_vector(6 downto 0); -- raw converted seven segment data
begin
    
    -- select an active value of o_seg7_data
    o_seg7_data <= (w_seg7_data xnor (6 downto 0 => g_SEG_ACTIVE_VALUE));
    
    -- hexadecimal to seven segment conversion implementation
    with i_hex_data select w_seg7_data <= 
        c_SEG7_0        when "0000",
        c_SEG7_1        when "0001",
        c_SEG7_2        when "0010",
        c_SEG7_3        when "0011",
        c_SEG7_4        when "0100",
        c_SEG7_5        when "0101",
        c_SEG7_6        when "0110",
        c_SEG7_7        when "0111",
        c_SEG7_8        when "1000",
        c_SEG7_9        when "1001",
        c_SEG7_A        when "1010",
        c_SEG7_B        when "1011",
        c_SEG7_C        when "1100",
        c_SEG7_D        when "1101",
        c_SEG7_E        when "1110",
        c_SEG7_F        when "1111",
        (others => 'X') when others;
    
end architecture rtl;
