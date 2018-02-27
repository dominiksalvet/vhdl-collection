library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package rom_public is
    
    function create_simple_mem_init_data (
            addr_width : positive;
            data_width : positive
        ) return std_logic_vector;
    
end package rom_public;


package body rom_public is
    
    -- Purpose: Create initialization data of source memory with format address=data.
    function create_simple_mem_init_data (
            addr_width : positive; -- target memory address bus bit width
            data_width : positive -- target memory data bus bit width
        ) return std_logic_vector is
        -- definition of amount of unique addresses
        constant ADDR_MAX : positive := (2 ** addr_width) - 1;
        -- vector of initialization data
        variable init_data : std_logic_vector(0 to (ADDR_MAX * data_width) + data_width - 1);
    begin
        for i in 0 to ADDR_MAX loop -- creating initialization data image
            init_data(i * data_width to (i * data_width) + data_width - 1) := 
            std_logic_vector(to_unsigned(i, data_width));
        end loop;
        return init_data;
    end function create_simple_mem_init_data;
    
end package body rom_public;


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
