--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--     Generic implementation of a single port synchronous RW type RAM memory
--     with optional initialization from a file.
--------------------------------------------------------------------------------
-- Notes:
--     1. Since there is a read enable signal, o_data output will be implemented
--        as register.
--     2. The module can be implemented as a block memory, if the target
--        platform supports it.
--     3. Optionally it is possible to initialize RAM from a file. The
--        g_MEM_IMG_FILENAME generic defines the relative path to the file.
--        This file must contain only ASCII "0" and "1" characters, each line's
--        length must be equal to set g_DATA_WIDTH and file must have
--        2**g_ADDR_WIDTH lines.
--     4. If initialization from a file will not be used, the "" value must be
--        assigned to the g_MEM_IMG_FILENAME generic.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library vhdl_collection;
use vhdl_collection.verif_util_pkg.all; -- verif_util_pkg.vhd


entity ram is
    generic (
        g_ADDR_WIDTH : positive := 4; -- bit width of RAM address bus
        g_DATA_WIDTH : positive := 8; -- bit width of RAM data bus
        
        -- optional relative path of memory image file
        g_MEM_IMG_FILENAME : string := "mem_img/linear_4_8.txt"
    );
    port (
        i_clk : in std_logic; -- clock signal
        
        i_we   : in  std_logic; -- write enable
        i_re   : in  std_logic; -- read enable
        i_addr : in  std_logic_vector(g_ADDR_WIDTH - 1 downto 0); -- address bus
        i_data : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- input data bus
        o_data : out std_logic_vector(g_DATA_WIDTH - 1 downto 0) -- output data bus
    );
end entity ram;


architecture rtl of ram is
    
    -- output buffers
    signal b_data : std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    
    -- definition of memory type
    type t_MEM is array(0 to (2 ** g_ADDR_WIDTH) - 1) of
        std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    
    -- Description:
    --     Creates the memory image by loading it from the defined file.
    impure function create_mem_img return t_MEM is -- returns memory image
        file v_file     : text; -- file pointer
        variable v_line : line; -- read line
        
        variable v_mem        : t_MEM; -- memory image
        variable v_bit_vector : bit_vector(g_DATA_WIDTH - 1 downto 0); -- auxiliary vector for read
    begin
        if (g_MEM_IMG_FILENAME'length = 0) then
            report "The memory has been left uninitialized.";
            return v_mem;
        end if;
        
        report "The memory is about being initialized from a file.";
        file_open(v_file, g_MEM_IMG_FILENAME, read_mode);
        
        for i in t_MEM'range loop
            readline(v_file, v_line);
            -- read function from std.textio package does not work with std_logic_vector
            read(v_line, v_bit_vector);
            v_mem(i) := to_stdlogicvector(v_bit_vector); -- cast to std_logic_vector
        end loop;
        
        file_close(v_file);
        report "The initialization from a file has been successful."; 
        
        return v_mem;
    end function create_mem_img;
    
    signal r_mem : t_MEM := create_mem_img; -- accessible memory signal
    
begin
    
    o_data <= b_data;
    
    -- Description:
    --     Memory read and write mechanism description.
    mem_read_write : process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            
            if (i_re = '1') then -- read from the memory
                b_data <= r_mem(to_integer(unsigned(i_addr)));
            end if;
            
            if (i_we = '1') then -- write to the memory
                r_mem(to_integer(unsigned(i_addr))) <= i_data;
            end if;
            
        end if;
    end process mem_read_write;
    
    -- rtl_synthesis off
    input_prevention : process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            
            if (i_we = '1' or i_re = '1') then -- read or write means that address must be defined
                assert (contains_01(i_addr))
                    report "Undefined i_addr when reading from or writing to the memory!"
                    severity failure;
            end if;
            
            if (i_we = '1') then -- write also means that input data must be defined
                assert (contains_01(i_data))
                    report "Undefined i_data when writing to the memory!"
                    severity failure;
            end if;
            
        end if;
    end process input_prevention;
    
    output_prevention : process (b_data) is
    begin
        if (now > 0 ps) then -- the prevention must start after the simulation initialization
            assert (contains_01(b_data))
                report "Undefined o_data when reading from the memory."
                severity warning;
        end if;
    end process output_prevention;
    -- rtl_synthesis on
    
end architecture rtl;


--------------------------------------------------------------------------------
-- MIT License
--
-- Copyright (c) 2016-2018 Dominik Salvet
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
