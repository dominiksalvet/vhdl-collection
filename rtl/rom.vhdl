--------------------------------------------------------------------------------
-- Copyright (C) 2016-2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Platform:  independent
--------------------------------------------------------------------------------
-- Description:
--     Generic implementation of a single port synchronous ROM memory with
--     initialization from a file or a linear initialization where memory
--     content is [address]=address.
--------------------------------------------------------------------------------
-- Notes:
--     1. Since there is a read enable signal, o_data output will be implemented
--        as a register.
--     2. The module can be implemented as a block memory, if the target
--        platform and used synthesizer support it.
--     3. If it is required to use a linear initialization, set the
--        g_MEM_IMG_FILENAME generic to "".
--     4. If the initialization from a file will be used, the file must contain
--        only ASCII "0" and "1" characters, each line's length must be equal to
--        set g_DATA_WIDTH and file must have 2**g_ADDR_WIDTH lines.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library vhdl_collection;
use vhdl_collection.util_pkg.all;


entity rom is
    generic (
        g_ADDR_WIDTH : positive := 4; -- bit width of ROM address bus
        g_DATA_WIDTH : positive := 4; -- bit width of ROM data bus
        
        -- relative path of memory image file
        g_MEM_IMG_FILENAME : string := "../data/mem_img/linear_4_4.txt"
    );
    port (
        i_clk : in std_ulogic; -- clock signal
        
        i_re   : in  std_ulogic; -- read enable
        i_addr : in  std_ulogic_vector(g_ADDR_WIDTH - 1 downto 0); -- address bus
        o_data : out std_ulogic_vector(g_DATA_WIDTH - 1 downto 0) -- output data bus
    );
end entity rom;


architecture rtl of rom is
    
    -- definition of the used memory type
    type t_MEM is array(0 to integer((2 ** g_ADDR_WIDTH) - 1)) of
        std_ulogic_vector(g_DATA_WIDTH - 1 downto 0);
    
    -- Description:
    --     Creates the memory image based on the module's generics.
    impure function create_mem_img return t_MEM is -- returns memory image
        file v_file     : text; -- file pointer
        variable v_line : line; -- read line
        
        variable v_mem        : t_MEM; -- memory image
        variable v_bit_vector : bit_vector(g_DATA_WIDTH - 1 downto 0); -- auxiliary vector for read
    begin
        
        if (g_MEM_IMG_FILENAME'length = 0) then -- linear initialization
            for i in t_MEM'range loop
                v_mem(i) := std_ulogic_vector(to_unsigned(i, g_DATA_WIDTH)); -- [address]=address
            end loop;
            report "The memory has been linearly initialized.";
        else -- initialization from a file
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
        end if;
        
        return v_mem;
    end function create_mem_img;
    
begin
    
    -- Description:
    --     Memory read mechanism description.
    mem_read : process (i_clk) is
        -- accessible memory identifier
        constant c_MEM : t_MEM := create_mem_img; -- calling the memory initialization
        -- it is also possible to change to a direct initialization, as shown commented below:
        -- constant c_MEM : t_MEM := (
        --         others => (others => 'U')
        --     );
    begin
        if (rising_edge(i_clk)) then
            if (i_re = '1') then
                o_data <= c_MEM(to_integer(unsigned(i_addr)));
            end if;
        end if;
    end process mem_read;
    
    -- rtl_synthesis off
    input_prevention : process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            if (i_re = '1') then -- read means that address must be defined
                assert (contains_01(i_addr))
                    report "Undefined i_addr when reading from the memory!"
                    severity failure;
            end if;
        end if;
    end process input_prevention;
    -- rtl_synthesis on
    
end architecture rtl;
