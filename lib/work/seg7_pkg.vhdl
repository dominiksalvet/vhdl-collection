--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     This package contains basic seven segment display utilities.
--------------------------------------------------------------------------------
-- Notes:
--     1. The package assumes hexadecimal radix for conversions.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package seg7_pkg is
    
    type t_MEM is array(0 to 15) of std_ulogic_vector(6 downto 0);
    -- images of all seven segment values representing a hexadecimal number
    -- '1' values stands for an active segment, '0' for an inactive segment
    constant c_SEG7 : t_MEM := (
            --     ABCDEFG (segment mapping)
            0  => "1111110", -- 0
            1  => "0110000", -- 1
            2  => "1101101", -- 2
            3  => "1111001", -- 3
            4  => "0110011", -- 4
            5  => "1011011", -- 5
            6  => "1011111", -- 6
            7  => "1110000", -- 7
            8  => "1111111", -- 8
            9  => "1111011", -- 9
            10 => "1110111", -- A
            11 => "0011111", -- B
            12 => "1001110", -- C
            13 => "0111101", -- D
            14 => "1001111", -- E
            15 => "1000111" -- F
        );
    
end package seg7_pkg;
