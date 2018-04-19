--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Platform:  independent
--------------------------------------------------------------------------------
-- Description:
--     This package contains basic utility functions.
--------------------------------------------------------------------------------
-- Notes:
--     1. Unless stated otherwise, the functions are not intended to be
--        synthesized.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


package util_pkg is
    
    -- Description:
    --     The function returns true only when the input signal p_SIGNAL has '0' or '1' value, false
    --     is returned otherwise.
    function contains_01 (
            p_SIGNAL : std_ulogic -- input standard logic signal
        ) return boolean;
    
    -- Description:
    --     The function returns true only when all the scalar components of the input vector
    --     p_VECTOR have '0' or '1' value, false is returned otherwise.
    function contains_01 (
            p_VECTOR : std_ulogic_vector -- input standard logic vector
        ) return boolean;
    
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
    
end package util_pkg;


package body util_pkg is
    
    function contains_01 (
            p_SIGNAL : std_ulogic
        ) return boolean is
    begin
        return p_SIGNAL = '0' or p_SIGNAL = '1';
    end function contains_01;
    
    function contains_01 (
            p_VECTOR : std_ulogic_vector
        ) return boolean is
    begin
        for i in p_VECTOR'range loop -- check every scalar component of the vector
            if (not contains_01(p_VECTOR(i))) then
                return false;
            end if;
        end loop;

        return true;
    end function contains_01;
    
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
                v_string(i) := to_character(p_VECTOR(i - 1)); -- calling to_character on every bit
            end loop;
        else -- range of p_VECTOR is defined with "downto"
            for i in v_string'range loop
                -- calling to_character on every bit
                v_string(i) := to_character(p_VECTOR(p_VECTOR'high - i + 1));
            end loop;
        end if;
        
        return v_string;
    end function to_string;
    
end package body util_pkg;


--------------------------------------------------------------------------------
-- MIT License
--
-- Copyright (c) 2018 Dominik Salvet
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--------------------------------------------------------------------------------
