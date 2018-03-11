--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--     This file represents a generic LIFO structure (also known as stack). It
--     is possible to setup it's capacity and stored data's bit width.
--------------------------------------------------------------------------------
-- Notes:
--     1. If both write and read operations are enabled simultaneously, nothing
--        will happen.
--     2. The final internal LIFO capacity is equal to 2^INDEX_WIDTH only. It is
--        not possible to choose another capacity.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity lifo is
    generic (
        INDEX_WIDTH : positive := 8;
        DATA_WIDTH  : positive := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        we      : in  std_logic;
        data_in : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        full    : out std_logic;
        
        re       : in  std_logic;
        data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        empty    : out std_logic
    );
end entity lifo;


architecture rtl of lifo is
    
    type mem_t is array((2 ** INDEX_WIDTH) - 1 downto 0) of
        std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal mem : mem_t;
    
    signal wr_index : unsigned(INDEX_WIDTH - 1 downto 0);
    signal rd_index : unsigned(INDEX_WIDTH - 1 downto 0);
    
begin
    
    rd_index <= wr_index - 1;
    
    mem_access : process (clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                full     <= '0';
                empty    <= '1';
                wr_index <= (others => '0');
            else
                
                if (we = '1' and re = '0') then
                    empty                     <= '0';
                    mem(to_integer(wr_index)) <= data_in;
                    wr_index                  <= wr_index + 1;
                    
                    if (wr_index = (2 ** INDEX_WIDTH) - 1) then
                        full <= '1';
                    end if;
                end if;
                
                if (re = '1' and we = '0') then
                    full     <= '0';
                    data_out <= mem(to_integer(rd_index));
                    wr_index <= rd_index;
                    
                    if (rd_index = 0) then
                        empty <= '1';
                    end if;
                end if;
                
            end if;
        end if;
    end process mem_access;
    
end architecture rtl;


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
