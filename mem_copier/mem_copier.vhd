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
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mem_copier is
    generic (
        SRC_ADDR_WIDTH : positive;
        TAR_ADDR_WIDTH : positive;
        DATA_WIDTH     : positive
    );
    port (
        clk        : in  std_logic;
        copy_en    : in  std_logic; -- in '0' reacts like a reset signal
        copy_cmplt : out std_logic;
        
        start_src_addr : in natural range 0 to (2 ** SRC_ADDR_WIDTH) - 1;
        start_tar_addr : in natural range 0 to (2 ** TAR_ADDR_WIDTH) - 1;
        -- assign copy_addr_count to 0 to program the whole target's address space
        copy_addr_count : in positive range 1 to 2 ** TAR_ADDR_WIDTH;
        
        src_data_in : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        src_re      : out std_logic;
        src_addr    : out std_logic_vector(SRC_ADDR_WIDTH - 1 downto 0);
        
        tar_we       : out std_logic;
        tar_addr     : out std_logic_vector(TAR_ADDR_WIDTH - 1 downto 0);
        tar_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end entity mem_copier;


architecture rtl of mem_copier is
    
    signal src_re_reg   : std_logic;
    signal src_addr_reg : unsigned(SRC_ADDR_WIDTH - 1 downto 0);
    
    signal tar_we_reg   : std_logic;
    signal tar_addr_reg : unsigned(TAR_ADDR_WIDTH - 1 downto 0);
    
    signal steps_left : natural range 0 to (2 ** TAR_ADDR_WIDTH) + 1;
    
begin
    
    src_re <= src_re_reg;
    
    src_addr <= std_logic_vector(src_addr_reg);
    
    tar_we <= tar_we_reg;
    
    tar_addr <= std_logic_vector(tar_addr_reg);
    
    mem_copying : process (clk)
        type state_t is (READ_INIT, READ_WAIT, WRITE_INIT, WRITE);
        variable state : state_t;
    begin
        if (rising_edge(clk)) then
            
            tar_data_out <= src_data_in;
            steps_left   <= steps_left - 1;
            
            if (src_re_reg = '1') then
                if (steps_left = 2) then
                    src_re_reg <= '0';
                end if;
                src_addr_reg <= src_addr_reg + 1;
            end if;
            
            if (tar_we_reg = '1') then
                if (steps_left = 0) then
                    copy_cmplt <= '1';
                    tar_we_reg <= '0';
                end if;
                tar_addr_reg <= tar_addr_reg + 1;
            end if;
            
            if (copy_en = '0') then
                copy_cmplt <= '0';
                src_re_reg <= '0';
                tar_we_reg <= '0';
                state      := READ_INIT;
            else
                case (state) is
                    when READ_INIT => 
                        src_re_reg   <= '1';
                        src_addr_reg <= to_unsigned(start_src_addr, SRC_ADDR_WIDTH);
                        tar_addr_reg <= to_unsigned(start_tar_addr, TAR_ADDR_WIDTH);
                        steps_left   <= copy_addr_count + 1;
                        state        := READ_WAIT;
                    when READ_WAIT => 
                        state := WRITE_INIT;
                    when WRITE_INIT => 
                        tar_we_reg <= '1';
                        state      := WRITE;
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
