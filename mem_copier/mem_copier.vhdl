--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Platform:  independent
--------------------------------------------------------------------------------
-- Description:
--     This VHDL description represents a generic memory copier module. It can
--     operate in wide ways of use. It behaves like a simple DMA module with two
--     separated memory buses.
--------------------------------------------------------------------------------
-- Notes:
--     1. The i_copy_en input must have '1' value for all the time of copying
--        the data as the '0' value behaves like synchronous reset signal.
--     2. To reach the highest maximal i_clk frequency, the module uses internal
--        buffer for read data, so there is 2 i_clk delay until read data
--        actually write to the target memory.
--     3. The o_src_re and o_tar_we signals have '1' value only for necessary
--        time.
--     4. When an address of one of the memories should exceed the maximal
--        memory address, the modulo function with value of maximal address of
--        the memory will be applied to calculate the final address.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mem_copier is
    generic (
        g_SRC_ADDR_WIDTH : positive := 4; -- bit width of source memory address bus
        g_TAR_ADDR_WIDTH : positive := 4; -- bit width of target memory address bus
        g_DATA_WIDTH     : positive := 8 -- bit width of data of both memories
    );
    port (
        i_clk : in std_ulogic; -- clock signal
        -- use '1' to start the copying, the '0' value behaves like synchronous reset
        i_copy_en : in std_ulogic;
        -- when copying is done, '1' is hold on this signal until reset is performed
        o_copy_done : out std_ulogic;
        
        -- start address to read from the source memory
        i_src_start_addr : in std_ulogic_vector(g_SRC_ADDR_WIDTH - 1 downto 0);
        -- start address to write to the target memory
        i_tar_start_addr : in std_ulogic_vector(g_TAR_ADDR_WIDTH - 1 downto 0);
        -- number of addresses to copy
        i_copy_addr_count : in integer range 1 to 2 ** g_TAR_ADDR_WIDTH;
        
        -- signals for the source memory (which will be read from)
        i_src_data : in  std_ulogic_vector(g_DATA_WIDTH - 1 downto 0);
        o_src_re   : out std_ulogic;
        o_src_addr : out std_ulogic_vector(g_SRC_ADDR_WIDTH - 1 downto 0);
        
        -- signals for the target memory (which will be written to)
        o_tar_we   : out std_ulogic;
        o_tar_addr : out std_ulogic_vector(g_TAR_ADDR_WIDTH - 1 downto 0);
        o_tar_data : out std_ulogic_vector(g_DATA_WIDTH - 1 downto 0)
    );
end entity mem_copier;


architecture rtl of mem_copier is
    
    -- buffers for the source memory signals
    signal b_src_re   : std_ulogic;
    signal b_src_addr : unsigned(g_SRC_ADDR_WIDTH - 1 downto 0);
    
    -- buffers for the target memory signals
    signal b_tar_we   : std_ulogic;
    signal b_tar_addr : unsigned(g_TAR_ADDR_WIDTH - 1 downto 0);
    
begin
    
    o_src_re <= b_src_re;
    
    o_src_addr <= std_ulogic_vector(b_src_addr);
    
    o_tar_we <= b_tar_we;
    
    o_tar_addr <= std_ulogic_vector(b_tar_addr);
    
    -- Description:
    --     Performs memory copying by using internal buffer to speed up the process.
    mem_copying : process (i_clk) is
        -- definition of state of the process to describe individual stages
        type t_STATE is (READ_INIT, READ_WAIT, WRITE_INIT, WRITING);
        variable r_state : t_STATE; -- declaration of the state variable
        -- number of steps left to complete the required copying (number of i_clk rising edges)
        variable r_steps_left : integer range 0 to (2 ** g_TAR_ADDR_WIDTH) + 1;
    begin
        if (rising_edge(i_clk)) then
            
            if (b_src_re = '1') then -- read has been performed at previous i_clk rising edge
                -- 2 steps left only when writing it is required to be completed
                if (r_steps_left = 2) then
                    b_src_re <= '0'; -- disable read the source memory
                end if;
                b_src_addr <= b_src_addr + 1; -- increment source memory address
            end if;
            
            if (b_tar_we = '1') then -- write has been performed at previous i_clk rising edge
                if (r_steps_left = 0) then -- all the copying process is now completed
                    o_copy_done <= '1'; -- copy complete indicate
                    b_tar_we    <= '0'; -- disable write to the target memory
                end if;
                b_tar_addr <= b_tar_addr + 1; -- increment target memory address
            end if;
            
            o_tar_data   <= i_src_data; -- move data from source memory bus to target memory bus
            r_steps_left := r_steps_left - 1; -- decrement steps left
            
            if (i_copy_en = '0') then -- synchronous reset clause, module initialization
                o_copy_done <= '0';
                b_src_re    <= '0';
                b_src_addr  <= (others => '0');
                b_tar_we    <= '0';
                b_tar_addr  <= (others => '0');
                -- after the synchronous reset, the process will continue in state READ_INIT
                r_state := READ_INIT;
            else
                case (r_state) is -- the state transitions and driving control signals
                    when READ_INIT => -- initialize the read process, store parameters
                        b_src_re <= '1';
                        -- store memory start address to be independent of the inputs
                        b_src_addr <= unsigned(i_src_start_addr);
                        b_tar_addr <= unsigned(i_tar_start_addr);
                        -- total steps must assume the first memory read delay
                        r_steps_left := i_copy_addr_count + 1;
                        r_state      := READ_WAIT;
                    when READ_WAIT => -- wait for the first read to fill a pipeline
                        r_state := WRITE_INIT;
                    when WRITE_INIT => -- perform the first write to the target memory
                        b_tar_we <= '1';
                        r_state  := WRITING; -- unlock forcing b_tar_we signal to '1'
                    when others => null;
                end case;
            end if;
            
        end if;
    end process mem_copying;
    
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
