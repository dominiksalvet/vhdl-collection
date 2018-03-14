--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--     This file represents a generic LIFO structure (also known as stack). It
--     is possible to setup it's capacity and stored data's bit width.
--------------------------------------------------------------------------------
-- Notes:
--     1. If both write and read operations are enabled at the same time,
--        nothing will happen.
--     2. The final internal LIFO capacity is equal to 2^g_INDEX_WIDTH only. It
--        is not possible to choose another capacity.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity lifo is
    generic (
        g_INDEX_WIDTH : positive := 2; -- internal index bit width affecting the LIFO capacity
        g_DATA_WIDTH  : positive := 8 -- bit width of stored data
    );
    port (
        i_clk : in std_logic; -- clock signal
        i_rst : in std_logic; -- reset signal
        
        i_we   : in  std_logic; -- write enable (push)
        i_data : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- written data
        o_full : out std_logic; -- full LIFO indicator
        
        i_re    : in  std_logic; -- read enable (pop)
        o_data  : out std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- read data
        o_empty : out std_logic -- empty LIFO indicator
    );
end entity lifo;


architecture rtl of lifo is
    
    -- definition of internal memory type
    type t_mem is array((2 ** g_INDEX_WIDTH) - 1 downto 0) of
        std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    signal r_mem : t_mem; -- accessible internal memory signal
    
    signal r_wr_index : unsigned(g_INDEX_WIDTH - 1 downto 0); -- current write index
    signal w_rd_index : unsigned(g_INDEX_WIDTH - 1 downto 0); -- current read index
    
begin
    
    w_rd_index <= r_wr_index - 1; -- read index is always less by 1 than write index
    
    -- Description:
    --     Internal memory read and write mechanism description.
    mem_access : process (i_clk)
    begin
        if (rising_edge(i_clk)) then -- synchronous reset
            if (i_rst = '1') then
                o_full     <= '0';
                o_empty    <= '1';
                r_wr_index <= to_unsigned(0, r_wr_index'length);
            else
                
                if (i_we = '1' and i_re = '0') then -- write mechanism
                    -- the LIFO is never empty after write and no read
                    o_empty                       <= '0';
                    r_mem(to_integer(r_wr_index)) <= i_data;
                    r_wr_index                    <= r_wr_index + 1;
                    
                    if (r_wr_index = (2 ** g_INDEX_WIDTH) - 1) then -- full LIFO check
                        o_full <= '1';
                    end if;
                end if;
                
                if (i_re = '1' and i_we = '0') then -- read mechanism
                    o_full     <= '0'; -- the LIFO is never full after read and no write
                    o_data     <= r_mem(to_integer(w_rd_index));
                    r_wr_index <= w_rd_index;
                    
                    if (w_rd_index = 0) then -- empty LIFO check
                        o_empty <= '1';
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
