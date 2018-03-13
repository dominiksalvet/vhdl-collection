--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--     Generic implementation of single port sychronous ROM memory with an
--     initialization option.
--------------------------------------------------------------------------------
-- Notes:
--     1. Since there is a read enable signal, data_out output will be
--        implemented as a register.
--     2. The module can be implemented as a block memory, if the target
--        platform and used synthesizer support it.
--     3. The initialization data vector will be sampled from the left to memory
--        addresses based on DATA_WIDTH from address defined by INIT_START_ADDR.
--        So the data on the INIT_START_ADDR match the leftmost part of
--        DATA_WIDTH length of the INIT_DATA vector.
--     4. The amount of initialized memory addresses depends on the INIT_DATA
--        vector length itself. When the initialization should exceed the memory
--        maximal address, the modulo function with value of maximal address
--        will be applied to calculate the final address.
--     5. When length of INIT_DATA modulo DATA_WIDTH is not equal 0, then the
--        last initialized memory address will be left uninitialized.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rom_public.all; -- rom_public.vhd


entity rom is
    generic (
        ADDR_WIDTH : positive := 4; -- bit width of ROM address bus
        DATA_WIDTH : positive := 8; -- bit width of ROM data bus
        
        -- initialization data vector
        INIT_DATA : std_logic_vector := create_simple_mem_init_data(4, 8);
        -- start address of the initialized data in the memory
        INIT_START_ADDR : natural := 0
    );
    port (
        clk : in std_logic; -- clock signal
        
        re       : in  std_logic; -- read enable
        addr     : in  unsigned(ADDR_WIDTH - 1 downto 0); -- address bus
        data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0) -- output data bus
    );
end entity rom;


architecture rtl of rom is
    
    -- amount of unique addresses
    constant ADDR_COUNT : positive := 2 ** ADDR_WIDTH;
    
    -- definition of the memory type
    type mem_t is array(ADDR_COUNT - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    -- Description:
    --     Initialize memory by sampling the INIT_DATA vector to memory data width.
    function mem_init return mem_t is
        variable mem : mem_t; -- memory to be initialized
    begin
        -- loop through all the data to initialize memory
        for i in 0 to (INIT_DATA'length / DATA_WIDTH) - 1 loop
            -- modulo write address and data sampling from original vector implementation
            mem((INIT_START_ADDR + i) mod ADDR_COUNT) := 
            INIT_DATA(i * DATA_WIDTH to ((i + 1) * DATA_WIDTH) - 1);
        end loop;
        return mem;
    end function mem_init;
    
    -- accessible memory signal, calling the memory initialization
    signal mem : mem_t := mem_init;
    -- also possible to change to a custom initialization, as shown below in a comment section:
    -- signal mem : mem_t := (
    --     others => (others => 'U')
    --     );
    
begin
    
    -- Description:
    --     Memory read mechanism description.
    mem_read : process (clk) is
    begin
        if (rising_edge(clk)) then
            if (re = '1') then
                data_out <= mem(to_integer(addr));
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
