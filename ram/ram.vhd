--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--     Generic implementation of single port sychronous RW type RAM memory.
--------------------------------------------------------------------------------
-- Notes:
--     1. Since there is a read enable signal, o_data output will be implemented
--        as register.
--     2. The module can be implemented as a block memory, if the target
--        platform supports it.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ram is
    generic (
        g_ADDR_WIDTH : positive := 4; -- bit width of RAM address bus
        g_DATA_WIDTH : positive := 8 -- bit width of RAM data bus
    );
    port (
        i_clk : in std_logic; -- clock signal
        
        i_we   : in  std_logic; -- write enable
        i_re   : in  std_logic; -- read enable
        i_addr : in  unsigned(g_ADDR_WIDTH - 1 downto 0); -- address bus
        i_data : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- input data bus
        o_data : out std_logic_vector(g_DATA_WIDTH - 1 downto 0) -- output data bus
    );
end entity ram;


architecture rtl of ram is
    
    -- definition of memory type
    type t_mem is array((2 ** g_ADDR_WIDTH) - 1 downto 0) of
        std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    signal r_mem : t_mem; -- accessible memory signal
    
begin
    
    -- Description:
    --     Memory read and write mechanism description.
    mem_read_write : process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            
            if (i_re = '1') then -- read from the memory
                o_data <= r_mem(to_integer(i_addr));
            end if;
            
            if (i_we = '1') then -- write to the memory
                r_mem(to_integer(i_addr)) <= i_data;
            end if;
            
        end if;
    end process mem_read_write;
    
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
