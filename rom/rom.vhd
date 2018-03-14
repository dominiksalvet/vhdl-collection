--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--     Generic implementation of single port sychronous ROM memory with an
--     initialization option.
--------------------------------------------------------------------------------
-- Notes:
--     1. Since there is a read enable signal, o_data output will be implemented
--        as a register.
--     2. The module can be implemented as a block memory, if the target
--        platform and used synthesizer support it.
--     3. The initialization data vector will be sampled from the left to memory
--        addresses based on g_DATA_WIDTH from address defined by
--        g_INIT_START_ADDR. So the data on the g_INIT_START_ADDR match the
--        leftmost part of g_DATA_WIDTH length of the g_INIT_VECTOR vector.
--     4. The amount of initialized memory addresses depends on the
--        g_INIT_VECTOR vector length itself. When the initialization should
--        exceed the memory maximal address, the modulo function with value of
--        maximal address will be applied to calculate the final address.
--     5. When length of g_INIT_VECTOR modulo g_DATA_WIDTH is not equal 0, then
--        the last initialized memory address will be left uninitialized.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.util.all; -- util.vhd


entity rom is
    generic (
        g_ADDR_WIDTH : positive := 4; -- bit width of ROM address bus
        g_DATA_WIDTH : positive := 4; -- bit width of ROM data bus
        
        -- initialization data vector
        g_INIT_VECTOR : std_logic_vector := create_linear_vector(2 ** 4, 4);
        -- start address of the initialized data in the memory
        g_INIT_START_ADDR : natural := 0
    );
    port (
        i_clk : in std_logic; -- clock signal
        
        i_re   : in  std_logic; -- read enable
        i_addr : in  unsigned(g_ADDR_WIDTH - 1 downto 0); -- address bus
        o_data : out std_logic_vector(g_DATA_WIDTH - 1 downto 0) -- output data bus
    );
end entity rom;


architecture rtl of rom is
    
    -- amount of unique addresses
    constant c_ADDR_COUNT : positive := 2 ** g_ADDR_WIDTH;
    
    -- definition of the memory type
    type t_mem is array(c_ADDR_COUNT - 1 downto 0) of std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    
    -- Description:
    --     Initialize memory by sampling the g_INIT_VECTOR vector to memory data width.
    function init_mem return t_mem is
        variable r_mem : t_mem; -- memory to be initialized
    begin
        -- loop through all the data to initialize memory
        for i in 0 to (g_INIT_VECTOR'length / g_DATA_WIDTH) - 1 loop
            -- modulo write address and data sampling from original vector implementation
            r_mem((g_INIT_START_ADDR + i) mod c_ADDR_COUNT) := 
            g_INIT_VECTOR(i * g_DATA_WIDTH to ((i + 1) * g_DATA_WIDTH) - 1);
        end loop;
        return r_mem;
    end function init_mem;
    
    -- accessible memory signal, calling the memory initialization
    signal r_mem : t_mem := init_mem;
    -- also possible to change to a direct initialization, as shown below in a comment section:
    -- signal r_mem : t_mem := (
    --     others => (others => 'U')
    --     );
    
begin
    
    -- Description:
    --     Memory read mechanism description.
    mem_read : process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            if (i_re = '1') then
                o_data <= r_mem(to_integer(i_addr));
            end if;
        end if;
    end process mem_read;
    
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
