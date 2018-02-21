--------------------------------------------------------------------------------
-- Standard:    VHDL-1993
-- Platform:    independent
-- Dependecies: none
--------------------------------------------------------------------------------
-- Description:
--     Generic implementation of single port sychronous ROM memory.
--------------------------------------------------------------------------------
-- Notes:
--     1. Since there is a read enable signal, data_out output will be
--        implemented as register.
--     2. The module can be implemented as block memory, if the target platfrom
--        supports it.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rom is
    generic (
        ADDR_WIDTH : positive; -- bit width of rom address bus
        DATA_WIDTH : positive -- bit width of rom data bus
    );
    port (
        clk : in std_logic; -- clock signal
        
        re       : in  std_logic; -- read enable
        addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0); -- address bus
        data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0) -- output data bus
    );
end entity rom;


architecture rtl of rom is
    
    -- definition of memory type
    type memory_t is array((2 ** ADDR_WIDTH) - 1 downto 0) of
        std_logic_vector(DATA_WIDTH - 1 downto 0);
    -- accessible memory signal, rom initialization
    signal memory : memory_t := (
        others => (others => 'U')
        );
    
begin
    
    -- Inputs:  clk, re, addr, memory
    -- Outputs: data_out
    -- Purpose: Memory read mechanism description.
    memory_read : process (clk)
    begin
        if (rising_edge(clk)) then
            if (re = '1') then
                data_out <= memory(to_integer(unsigned(addr)));
            end if;
        end if;
    end process memory_read;
    
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
