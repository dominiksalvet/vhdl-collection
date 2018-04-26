--------------------------------------------------------------------------------
-- Copyright (C) 2016-2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
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
use vhdl_collection.util_pkg.all;


entity ram is
    generic (
        g_ADDR_WIDTH : positive := 4; -- bit width of RAM address bus
        g_DATA_WIDTH : positive := 8; -- bit width of RAM data bus
        
        -- optional relative path of memory image file
        g_MEM_IMG_FILENAME : string := "../data/mem_img/linear_4_8.txt"
    );
    port (
        i_clk : in std_ulogic; -- clock signal
        
        i_we   : in  std_ulogic; -- write enable
        i_re   : in  std_ulogic; -- read enable
        i_addr : in  std_ulogic_vector(g_ADDR_WIDTH - 1 downto 0); -- address bus
        i_data : in  std_ulogic_vector(g_DATA_WIDTH - 1 downto 0); -- input data bus
        o_data : out std_ulogic_vector(g_DATA_WIDTH - 1 downto 0) -- output data bus
    );
end entity ram;


architecture rtl of ram is
    
    -- simulation start time used in output prevention
    constant c_SIM_START_TIME : time := 0 ns;
    
    -- output buffers
    signal b_data : std_ulogic_vector(g_DATA_WIDTH - 1 downto 0);
    
    -- definition of memory type
    type t_MEM is array(0 to integer((2 ** g_ADDR_WIDTH) - 1)) of
        std_ulogic_vector(g_DATA_WIDTH - 1 downto 0);
    
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
            -- read function from std.textio package does not work with std_ulogic_vector
            read(v_line, v_bit_vector);
            v_mem(i) := to_stdulogicvector(v_bit_vector); -- cast to std_ulogic_vector
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
        -- the prevention must start after the simulation initialization
        if (now > c_SIM_START_TIME) then
            assert (contains_01(b_data))
                report "Undefined o_data when reading from the memory."
                severity warning;
        end if;
    end process output_prevention;
    -- rtl_synthesis on
    
end architecture rtl;
