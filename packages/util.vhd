--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;


package util is
    
    -- Description:
    --     Create a vector composed of c_COUNT items, each with c_ITEM_WIDTH bit width. It is called
    --     linear vector, because n-th item of the vector holds n value in binary (for n from 0)
    --     when returned. It can be used as simple ROM initialization.
    -- Example:
    --     c_COUNT = 8
    --     c_ITEM_WIDTH = 4
    --     return: "0000" & "0001" & "0010" & "0011" & "0100" & "0101" & "0110" & "0111"
    function create_linear_vector (
            c_COUNT      : positive; -- total number of items (subvectors)
            c_ITEM_WIDTH : positive -- bit width of one item (subvector)
        ) return std_logic_vector; -- final linear vector
     
    impure function create_vector_from_file (
            c_FILENAME   : string;
            c_COUNT      : positive;
            c_ITEM_WIDTH : positive
        ) return std_logic_vector;
    
end package util;


package body util is
    
    function create_linear_vector (
            c_COUNT      : positive;
            c_ITEM_WIDTH : positive
        ) return std_logic_vector is
        -- linear vector
        variable r_linear_vector : unsigned(0 to (c_COUNT * c_ITEM_WIDTH) - 1);
    begin
        for i in 0 to c_COUNT - 1 loop -- creating linear vector
            -- i-th address means i value
            r_linear_vector(i * c_ITEM_WIDTH to ((i + 1) * c_ITEM_WIDTH) - 1) := 
            to_unsigned(i, c_ITEM_WIDTH);
        end loop;
        return std_logic_vector(r_linear_vector);
    end function create_linear_vector;
    
    impure function create_vector_from_file (
            c_FILENAME   : string;
            c_COUNT      : positive;
            c_ITEM_WIDTH : positive
        ) return std_logic_vector is
        
        file c_FILE     : text open read_mode is "../" & c_FILENAME;
        variable r_line : line;
        variable r_string : string(1 to c_ITEM_WIDTH);

        variable r_vector : std_logic_vector(0 to (c_COUNT * c_ITEM_WIDTH) - 1);

    begin
        
        for i in 0 to c_COUNT - 1 loop
            if (not endfile(c_FILE)) then
                readline(c_FILE, r_line);
                read(r_line, r_string);
                for j in 1 to c_ITEM_WIDTH loop
                    if (r_string(j) = '1') then
                        r_vector((i * c_ITEM_WIDTH) + (j - 1)) := '1';
                    elsif (r_string(j) = '0') then
                        r_vector((i * c_ITEM_WIDTH) + (j - 1)) := '0';
                    end if;
                end loop;
            else
                exit;
            end if;
        end loop;
        return r_vector;
        
    end function create_vector_from_file;
    
end package body util;


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
