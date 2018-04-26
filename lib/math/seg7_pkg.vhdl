--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


package seg7_pkg is
    
    -- images of all seven segment representing a hexadecimal number
    -- the vectors are mapped to the segments in the following order: ABCDEFG
    -- '1' stands for an active segment, '0' for an inactive segment
    constant c_SEG7_0 : std_ulogic_vector(6 downto 0) := "1111110";
    constant c_SEG7_1 : std_ulogic_vector(6 downto 0) := "0110000";
    constant c_SEG7_2 : std_ulogic_vector(6 downto 0) := "1101101";
    constant c_SEG7_3 : std_ulogic_vector(6 downto 0) := "1111001";
    constant c_SEG7_4 : std_ulogic_vector(6 downto 0) := "0110011";
    constant c_SEG7_5 : std_ulogic_vector(6 downto 0) := "1011011";
    constant c_SEG7_6 : std_ulogic_vector(6 downto 0) := "1011111";
    constant c_SEG7_7 : std_ulogic_vector(6 downto 0) := "1110000";
    constant c_SEG7_8 : std_ulogic_vector(6 downto 0) := "1111111";
    constant c_SEG7_9 : std_ulogic_vector(6 downto 0) := "1111011";
    constant c_SEG7_A : std_ulogic_vector(6 downto 0) := "1110111";
    constant c_SEG7_B : std_ulogic_vector(6 downto 0) := "0011111";
    constant c_SEG7_C : std_ulogic_vector(6 downto 0) := "1001110";
    constant c_SEG7_D : std_ulogic_vector(6 downto 0) := "0111101";
    constant c_SEG7_E : std_ulogic_vector(6 downto 0) := "1001111";
    constant c_SEG7_F : std_ulogic_vector(6 downto 0) := "1000111";
    
end package seg7_pkg;
