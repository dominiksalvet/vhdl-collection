--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Platform:  independent
--------------------------------------------------------------------------------
-- Description:
--     Converter from hexadecimal data to seven segment data.
--------------------------------------------------------------------------------
-- Notes:
--     1. If the output o_seg7_data signal is wired to LEDs, it is required to
--        respect the LEDs on/off value and inverse the signal eventually.
--     2. This implementation assumes LED on state as '0' value and LED off
--        state as '1' value.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

use work.hex_to_seg7_public.all;


entity hex_to_seg7 is
    port (
        i_hex_data  : in  std_ulogic_vector(3 downto 0); -- 4-bit data as encoded hexadecimal number
        o_seg7_data : out std_ulogic_vector(6 downto 0) -- 7-bit segment data, bit per each segment
    );
end entity hex_to_seg7;


architecture rtl of hex_to_seg7 is
begin
    
    -- hexadecimal to seven segment conversion implementation
    with i_hex_data select o_seg7_data <= 
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
