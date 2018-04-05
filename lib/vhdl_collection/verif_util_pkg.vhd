--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--     This package contains basic verification utility functions.
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


package verif_util_pkg is
    
    -- Description:
    --     The function returns true only when the input signal p_SIGNAL has '0' or '1' value, false
    --     is returned otherwise. The function is not intended to be synthesized.
    function contains_01 (
            p_SIGNAL : std_logic -- input standard logic signal
        ) return boolean;
    
    -- Description:
    --     The function returns true only when all the scalar components of the input vector
    --     p_VECTOR have '0' or '1' value, false is returned otherwise. The function is not intended
    --     to be synthesized.
    function contains_01 (
            p_VECTOR : std_logic_vector -- input standard logic vector
        ) return boolean;
    
end package verif_util_pkg;


package body verif_util_pkg is
    
    function contains_01 (
            p_SIGNAL : std_logic
        ) return boolean is
    begin
        return p_SIGNAL = '0' or p_SIGNAL = '1';
    end function contains_01;
    
    function contains_01 (
            p_VECTOR : std_logic_vector
        ) return boolean is
    begin
        for i in p_VECTOR'range loop -- check every scalar component of the vector
            if (not contains_01(p_VECTOR(i))) then
                return false;
            end if;
        end loop;
        return true;
    end function contains_01;
    
end package body verif_util_pkg;


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
