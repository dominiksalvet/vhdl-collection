--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     This package contains basic verification functions.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

package verif_pkg is
    
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
    
end package verif_pkg;


package body verif_pkg is
    
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
    
end package body verif_pkg;
