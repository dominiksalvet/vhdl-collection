--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--     This VHDL description represents a generic memory copier module. It can
--     operate in wide ways of use. It behaves like a simple DMA module with
--     two separated memory busses.
--------------------------------------------------------------------------------
-- Notes:
--     1. The copy_en input must have '1' value for all the time of copying the
--        data as the '0' value behaves like synchronous reset signal.
--     2. To reach the highest maximal clk frequency, the module uses internal
--        buffer for read data, so there is 2 clk delay until read data actually
--        write to the target memory.
--     3. The src_re and tar_we signals have '1' value only for necessary time.
--     4. When an address of one of the memories should exceed the maximal
--        memory address, the modulo function with value of maximal address of
--        the memory will be applied to calculate the final address.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mem_copier is
    generic (
        SRC_ADDR_WIDTH : positive := 4; -- bit width of source memory address bus
        TAR_ADDR_WIDTH : positive := 4; -- bit width of target memory address bus
        DATA_WIDTH     : positive := 8 -- bit width of data of both memories
    );
    port (
        clk : in std_logic; -- clock signal
        -- use '1' to start the copying, the '0' value on this signal behaves like synchronous reset
        copy_en : in std_logic;
        -- when copying is done, '1' is hold on this signal until reset is performed
        copy_cmplt : out std_logic;
        
        -- start address to read from the source memory
        src_start_addr : in unsigned(SRC_ADDR_WIDTH - 1 downto 0);
        -- start address to write to the target memory
        tar_start_addr : in unsigned(TAR_ADDR_WIDTH - 1 downto 0);
        -- number of addresses to copy
        copy_addr_count : in positive range 1 to 2 ** TAR_ADDR_WIDTH;
        
        -- signals for the source memory (which will be read from)
        src_data_in : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        src_re      : out std_logic;
        src_addr    : out unsigned(SRC_ADDR_WIDTH - 1 downto 0);
        
        -- signals for the target memory (which will be written to)
        tar_we       : out std_logic;
        tar_addr     : out unsigned(TAR_ADDR_WIDTH - 1 downto 0);
        tar_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity mem_copier;


architecture rtl of mem_copier is
    
    -- buffers for the source memory signals
    signal src_re_reg   : std_logic;
    signal src_addr_reg : unsigned(SRC_ADDR_WIDTH - 1 downto 0);
    
    -- buffers for the target memory signals
    signal tar_we_reg   : std_logic;
    signal tar_addr_reg : unsigned(TAR_ADDR_WIDTH - 1 downto 0);
    
begin
    
    src_re <= src_re_reg;
    
    src_addr <= src_addr_reg;
    
    tar_we <= tar_we_reg;
    
    tar_addr <= tar_addr_reg;
    
    -- Description:
    --     Performs memory copying by using internal buffer to speed up the process.
    mem_copying : process (clk) is
        -- definition of state of the process to describe individual stages
        type state_t is (READ_INIT, READ_WAIT, WRITE_INIT, WRITE);
        variable state : state_t; -- declaration of the state variable
        -- number of steps left to complete the required copying (number of clk rising edges)
        variable steps_left : natural range 0 to (2 ** TAR_ADDR_WIDTH) + 1;
    begin
        if (rising_edge(clk)) then
            
            if (src_re_reg = '1') then -- read has been performed at previous clk rising edge
                -- 2 steps left only when writing it is required to be completed
                if (steps_left = 2) then
                    src_re_reg <= '0'; -- disable read the source memory
                end if;
                src_addr_reg <= src_addr_reg + 1; -- increment source memory address
            end if;
            
            if (tar_we_reg = '1') then -- write has been performed at previous clk rising edge
                if (steps_left = 0) then -- all the copying process is now completed
                    copy_cmplt <= '1'; -- copy complete indicate
                    tar_we_reg <= '0'; -- disable write to the target memory
                end if;
                tar_addr_reg <= tar_addr_reg + 1; -- increment target memory address
            end if;
            
            tar_data_out <= src_data_in; -- move data from source memory bus to target memory bus
            steps_left   := steps_left - 1; -- decrement steps left
            
            if (copy_en = '0') then -- synchronous reset clause, module initialization
                copy_cmplt   <= '0';
                src_re_reg   <= '0';
                src_addr_reg <= (others => '0');
                tar_we_reg   <= '0';
                tar_addr_reg <= (others => '0');
                -- after the synchronous reset, the process will continue in state READ_INIT
                state := READ_INIT;
            else
                case (state) is -- state transitions and driving control signals
                    when READ_INIT => -- initialize the read process, store parameters
                        src_re_reg <= '1';
                        -- store memory start address to be independent of the inputs
                        src_addr_reg <= src_start_addr;
                        tar_addr_reg <= tar_start_addr;
                        -- total steps must assume the first memory read delay
                        steps_left := copy_addr_count + 1;
                        state      := READ_WAIT;
                    when READ_WAIT => -- wait for the first read to fill a pipeline
                        state := WRITE_INIT;
                    when WRITE_INIT => -- perform the first write to the target memory
                        tar_we_reg <= '1';
                        state      := WRITE; -- unlock forcing tar_we_reg signal to '1'
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
