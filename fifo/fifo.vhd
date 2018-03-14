--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--     This file represents a generic FIFO structure (also known as queue). It
--     is possible to setup it's capacity and stored data's bit width. It is
--     possible to write and read at the same time, see "Notes".
--------------------------------------------------------------------------------
-- Notes:
--     1. The final internal FIFO capacity is equal to 2^g_INDEX_WIDTH only. It
--        is not possible to choose another capacity.
--     2. The FIFO module is implemented as memory with separated indexes for
--        write and read operations.
--     3. If the FIFO is empty, write and read operations can't be performed at
--        the same time. Otherwise the output data will be undefined and input
--        data will be lost. Nevertheless, it is still possible to use FIFO next
--        time like it should be used - it does not require to perform reset
--        after a violation of this access rule.
--     4. If the FIFO is full, write and read operation can be performed at the
--        same time.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fifo is
    generic (
        g_INDEX_WIDTH : positive := 2; -- internal index bit width affecting the FIFO capacity
        g_DATA_WIDTH  : positive := 8 -- bit width of stored data
    );
    port (
        i_clk : in std_logic; -- clock signal
        i_rst : in std_logic; -- reset signal
        
        i_we   : in  std_logic; -- write enable (enqueue)
        i_data : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- written data
        o_full : out std_logic; -- full FIFO indicator
        
        i_re    : in  std_logic; -- read enable (dequeue)
        o_data  : out std_logic_vector(g_DATA_WIDTH - 1 downto 0); -- read data
        o_empty : out std_logic -- empty FIFO indicator
    );
end entity fifo;


architecture rtl of fifo is
    
    -- definition of internal memory type
    type t_mem is array((2 ** g_INDEX_WIDTH) - 1 downto 0) of
        std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    signal r_mem : t_mem; -- accessible internal memory signal
    
    signal r_wr_index : unsigned(g_INDEX_WIDTH - 1 downto 0); -- current write index
    signal r_rd_index : unsigned(g_INDEX_WIDTH - 1 downto 0); -- current read index
    
begin
    
    -- Description:
    --     Internal memory read and write mechanism description.
    mem_access : process (i_clk) is
    begin
        if (rising_edge(i_clk)) then
            if (i_rst = '1') then -- synchronous reset
                o_full     <= '0';
                o_empty    <= '1';
                r_wr_index <= to_unsigned(0, r_wr_index'length);
                r_rd_index <= to_unsigned(0, r_rd_index'length);
            else
                
                if (i_we = '1') then -- write enable
                    r_mem(to_integer(r_wr_index)) <= i_data;
                    r_wr_index                    <= r_wr_index + 1;
                    
                    if (i_re = '0') then
                        o_empty <= '0'; -- the FIFO is never empty after write and no read
                        if (r_wr_index + 1 = r_rd_index) then -- full FIFO check
                            o_full <= '1';
                        end if;
                    end if;
                end if;
                
                if (i_re = '1') then -- read enable
                    o_data     <= r_mem(to_integer(r_rd_index));
                    r_rd_index <= r_rd_index + 1;
                    
                    if (i_we = '0') then
                        o_full <= '0'; -- the FIFO is never full after read and no write
                        if (r_rd_index + 1 = r_wr_index) then -- empty FIFO check
                            o_empty <= '1';
                        end if;
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
