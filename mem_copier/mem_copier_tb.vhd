--------------------------------------------------------------------------------
-- Description:
--     The test bench simulates to copy first 4 bytes from the source memory to
--     the last 4 bytes of the target memory. After verifying that control
--     signals were correct, the whole source memory image is copied to the
--     target memory from it's half addresses to test the modulo function. The
--     data transferring itself now will be verifying.
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vhdl_collection;
use vhdl_collection.verif_util_pkg.all; -- verif_util_pkg.vhd

use work.mem_copier; -- mem_copier.vhd

use work.rom; -- rom.vhd

use work.ram; -- ram.vhd


entity mem_copier_tb is
end entity mem_copier_tb;


architecture behavior of mem_copier_tb is
    
    -- uut generics
    constant g_SRC_ADDR_WIDTH : positive := 4;
    constant g_TAR_ADDR_WIDTH : positive := 4;
    constant g_DATA_WIDTH     : positive := 8;
    
    -- uut ports
    signal i_clk       : std_logic := '0';
    signal i_copy_en   : std_logic := '0';
    signal o_copy_done : std_logic;
    
    signal i_src_start_addr  : unsigned(g_SRC_ADDR_WIDTH - 1 downto 0)  := (others => '0');
    signal i_tar_start_addr  : unsigned(g_TAR_ADDR_WIDTH - 1 downto 0)  := (others => '0');
    signal i_copy_addr_count : integer range 1 to 2 ** g_TAR_ADDR_WIDTH := 1;
    
    signal i_src_data : std_logic_vector(g_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal o_src_re   : std_logic;
    signal o_src_addr : unsigned(g_SRC_ADDR_WIDTH - 1 downto 0);
    
    signal o_tar_we   : std_logic;
    signal o_tar_addr : unsigned(g_TAR_ADDR_WIDTH - 1 downto 0);
    signal o_tar_data : std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.mem_copier(rtl)
        generic map (
            g_SRC_ADDR_WIDTH => g_SRC_ADDR_WIDTH,
            g_TAR_ADDR_WIDTH => g_TAR_ADDR_WIDTH,
            g_DATA_WIDTH     => g_DATA_WIDTH
        )
        port map (
            i_clk       => i_clk,
            i_copy_en   => i_copy_en,
            o_copy_done => o_copy_done,
            
            i_src_start_addr  => i_src_start_addr,
            i_tar_start_addr  => i_tar_start_addr,
            i_copy_addr_count => i_copy_addr_count,
            
            i_src_data => i_src_data,
            o_src_re   => o_src_re,
            o_src_addr => o_src_addr,
            
            o_tar_we   => o_tar_we,
            o_tar_addr => o_tar_addr,
            o_tar_data => o_tar_data
        );
    
    -- instantiate source memory to copy data from
    src_mem : entity work.rom(rtl)
        generic map (
            g_ADDR_WIDTH => g_SRC_ADDR_WIDTH,
            g_DATA_WIDTH => g_DATA_WIDTH,
            
            g_MEM_IMG_FILENAME => "" -- initialize the memory with the [address]=address pattern
        )
        port map (
            i_clk => i_clk,
            
            i_re   => o_src_re,
            i_addr => std_logic_vector(o_src_addr),
            o_data => i_src_data
        );
    
    -- instantiate target memory to copy data to
    tar_mem : entity work.ram(rtl)
        generic map (
            g_ADDR_WIDTH => g_TAR_ADDR_WIDTH,
            g_DATA_WIDTH => g_DATA_WIDTH,
            
            g_MEM_IMG_FILENAME => "" -- no previous initialization
        )
        port map (
            i_clk => i_clk,
            
            i_we   => o_tar_we,
            i_re   => '0', -- it is not required to read the data back
            i_addr => std_logic_vector(o_tar_addr),
            i_data => o_tar_data,
            o_data => open
        );
    
    i_clk <= not i_clk after c_CLK_PERIOD / 2; -- setup i_clk as periodic signal
    
    stimulus : process is
    begin
        
        wait for c_CLK_PERIOD; -- delay to initialize the uut
        
        -- COPY THE FIRST 4 BYTES
        
        i_copy_en <= '1';
        -- the last 4 addresses of the target memory
        i_tar_start_addr  <= to_unsigned((2 ** g_TAR_ADDR_WIDTH) - 4, i_tar_start_addr'length);
        i_copy_addr_count <= 4;
        wait for c_CLK_PERIOD;
        
        assert (o_src_re = '1')
            report "Expected o_src_re='1', read should have been already started!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_tar_we = '0')
            report "Expected o_tar_we='0', data being written to the target memory are not " &
            "defined, write must not be enabled!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_tar_we = '1')
            report "Expected o_tar_we='1'!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_src_re = '1')
            report "Expected o_src_re='1', it is required to read another data!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_src_re = '0')
            report "Expected o_src_re='0', all required data are now read!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_tar_we = '1')
            report "Expected o_tar_we='1', it is required to write one more byte of data!"
            severity error;
        wait for c_CLK_PERIOD;
        
        assert (o_tar_we = '0' and o_copy_done = '1')
            report "Expected o_tar_we='0' and o_copy_done='1', now the write must be done!"
            severity error;
        i_copy_en <= '0'; -- copying has been done
        wait for c_CLK_PERIOD;
        
        assert (o_copy_done = '0')
            report "Expected o_copy_done='0'!"
            severity error;
        wait for c_CLK_PERIOD;
        
        -- COPY THE ENTIRE SOURCE MEMORY
        
        -- copying to all the target's addresses, it begins from the half address
        i_src_start_addr  <= to_unsigned((2 ** g_SRC_ADDR_WIDTH) / 2, i_src_start_addr'length);
        i_tar_start_addr  <= to_unsigned((2 ** g_TAR_ADDR_WIDTH) / 2, i_tar_start_addr'length);
        i_copy_addr_count <= 2 ** g_TAR_ADDR_WIDTH;
        i_copy_en         <= '1';
        wait for 3 * c_CLK_PERIOD;
        
        for i in 1 to i_copy_addr_count loop -- one pass per one write/read
            -- the [address]=address pattern matching
            assert (to_integer(o_tar_addr) = to_integer(unsigned(o_tar_data)))
                report "Expected the data being written to the " &
                integer'image(to_integer(o_tar_addr)) & " address to be equal to """ &
                to_string(o_tar_data) & """, what matches the [address]=address pattern!"
                severity error;
            wait for c_CLK_PERIOD;
        end loop;
        
        assert (o_tar_we = '0' and o_copy_done = '1')
            report "Expected o_tar_we='0' and o_copy_done='1', now the write must be done!"
            severity error;
        i_copy_en <= '0'; -- copying has been done
        wait for c_CLK_PERIOD;
        
        -- check status after copying has been done and the module now must be in idle
        assert (o_copy_done = '0')
            report "Expected o_copy_done='0'!"
            severity error;
        assert (o_src_addr = (o_src_addr'range => '0'))
            report "Expected o_src_addr=""" & to_string((o_src_addr'range => '0')) & """!"
            severity error;
        assert (o_tar_addr = (o_tar_addr'range => '0'))
            report "Expected o_tar_addr=""" & to_string((o_tar_addr'range => '0')) & """!"
            severity error;
        wait;
        
    end process stimulus;
    
end architecture behavior;


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
