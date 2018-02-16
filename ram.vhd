-------------------------------------------------------------------------------
-- Standard:    VHDL-1993
-- Platform:    any
-- Dependecies: none
-------------------------------------------------------------------------------
-- Description:
--     Generic implementation of single port sychronous RW type RAM memory.
-------------------------------------------------------------------------------
-- Comments:
--     1. Since there is a read enable signal, data_out output will be
--        implemented as register.
--     2. The module can be implemented as block memory, if the target platfrom
--        supports it.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ram is
    generic (
        ADDR_WIDTH : positive; -- bit width of ram address bus
        DATA_WIDTH : positive -- bit width of ram data bus
    );
    port (
        clk : in std_logic; -- clock signal
        
        we       : in  std_logic; -- write enable
        re       : in  std_logic; -- read enable
        addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0); -- address bus
        data_in  : in  std_logic_vector(DATA_WIDTH - 1 downto 0); -- input data bus
        data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0) -- output data bus
    );
end entity ram;


architecture rtl of ram is
    
    -- memory_t: definition of memory type
    type memory_t is array((2 ** ADDR_WIDTH) - 1 downto 0) of
        std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal memory : memory_t; -- accessible memory signal
    
begin
    
    -- Inputs:  clk, re, addr, memory, we
    -- Outputs: data_out, memory
    -- Purpose: Memory read and write mechanism description.
    memory_read_write : process (clk)
    begin
        if (rising_edge(clk)) then
            
            if (re = '1') then -- read from the memory
                data_out <= memory(to_integer(unsigned(addr)));
            end if;
            
            if (we = '1') then -- write to the memory
                memory(to_integer(unsigned(addr))) <= data_in;
            end if;
            
        end if;
    end process memory_read_write;
    
end architecture rtl;


-------------------------------------------------------------------------------
-- MIT License
--
-- Copyright (c) 2016-2018 Dominik Salvet
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.
-------------------------------------------------------------------------------
