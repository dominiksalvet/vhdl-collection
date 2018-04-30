--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     The package contains conversion functions for VHDL predefined data types
--     and data types included in the std_logic_1164 package.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

package conv_pkg is
    
    -- Description:
    --     Returns the std_ulogic parameter's character representation.
    function to_character (
            p_SIGNAL : std_ulogic -- input standard logic signal
        ) return character; -- final character
    
    -- Description:
    --     Returns the std_ulogic_vector parameter's string representation. It always respects the
    --     vector's range definition.
    function to_string (
            p_VECTOR : std_ulogic_vector -- input standard logic vector
        ) return string; -- final string
    
end package conv_pkg;


package body conv_pkg is
    
    function to_character (
            p_SIGNAL : std_ulogic
        ) return character is
        variable v_character : character; -- final character
    begin
        case (p_SIGNAL) is -- convert the std_ulogic to the character
            when 'U' => 
                v_character := 'U';
            when 'X' => 
                v_character := 'X';
            when '0' => 
                v_character := '0';
            when '1' => 
                v_character := '1';
            when 'Z' => 
                v_character := 'Z';
            when 'W' => 
                v_character := 'W';
            when 'L' => 
                v_character := 'L';
            when 'H' => 
                v_character := 'H';
            when '-' => 
                v_character := '-';
        end case;

        return v_character;
    end function to_character;
    
    function to_string (
            p_VECTOR : std_ulogic_vector
        ) return string is
        -- as a range it can't be used p_VECTOR'range as it allows one of the boundaries to be 0
        variable v_string : string(p_VECTOR'low + 1 to p_VECTOR'high + 1); -- final string
    begin
        if (p_VECTOR'ascending) then -- range of p_VECTOR is defined with "to"
            for i in v_string'range loop
                v_string(i) := to_character(p_VECTOR(i - 1)); -- calling to_character for every bit
            end loop;
        else -- range of p_VECTOR is defined with "downto"
            for i in v_string'range loop
                -- calling to_character for every bit
                v_string(i) := to_character(p_VECTOR(p_VECTOR'high - i + 1));
            end loop;
        end if;
        
        return v_string;
    end function to_string;
    
end package body conv_pkg;
