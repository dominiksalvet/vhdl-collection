--------------------------------------------------------------------------------
-- Description:
--     The test bench simulates to copy first 4 bytes from the source memory to
--     the last 4 bytes of the target memory. After verifying that control
--     signals were correct, the whole source memory image is copied to the
--     target memory from it's half addresses to test the modulo function. The
--     data transfering itself now will be verifying.
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_copier; -- mem_copier.vhd

use work.rom; -- rom.vhd
use work.rom_public.all; -- rom_public.vhd

use work.ram; -- ram.vhd


entity mem_copier_tb is
end entity mem_copier_tb;


architecture behavior of mem_copier_tb is
    
    -- uut generics
    constant SRC_ADDR_WIDTH : positive := 4;
    constant TAR_ADDR_WIDTH : positive := 4;
    constant DATA_WIDTH     : positive := 8;
    
    -- uut ports
    signal clk        : std_logic := '0';
    signal copy_en    : std_logic := '0';
    signal copy_cmplt : std_logic;
    
    signal src_start_addr  : natural range 0 to (2 ** SRC_ADDR_WIDTH) - 1 := 0;
    signal tar_start_addr  : natural range 0 to (2 ** TAR_ADDR_WIDTH) - 1 := 0;
    signal copy_addr_count : positive range 1 to 2 ** TAR_ADDR_WIDTH      := 1;
    
    signal src_data_in : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal src_re      : std_logic;
    signal src_addr    : std_logic_vector(SRC_ADDR_WIDTH - 1 downto 0);
    
    signal tar_we       : std_logic;
    signal tar_addr     : std_logic_vector(TAR_ADDR_WIDTH - 1 downto 0);
    signal tar_data_out : std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    -- tar_mem ports
    signal tm_data_out : std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    -- clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.mem_copier(rtl)
        generic map (
            SRC_ADDR_WIDTH => SRC_ADDR_WIDTH,
            TAR_ADDR_WIDTH => TAR_ADDR_WIDTH,
            DATA_WIDTH     => DATA_WIDTH
        )
        port map (
            clk        => clk,
            copy_en    => copy_en,
            copy_cmplt => copy_cmplt,
            
            src_start_addr  => src_start_addr,
            tar_start_addr  => tar_start_addr,
            copy_addr_count => copy_addr_count,
            
            src_data_in => src_data_in,
            src_re      => src_re,
            src_addr    => src_addr,
            
            tar_we       => tar_we,
            tar_addr     => tar_addr,
            tar_data_out => tar_data_out
        );
    
    -- instantiate source memory to copy data from
    src_mem : entity work.rom(rtl)
        generic map (
            ADDR_WIDTH => SRC_ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH,
            
            -- initialize the memory with the address=data pattern
            INIT_DATA       => create_simple_mem_init_data(SRC_ADDR_WIDTH, DATA_WIDTH),
            INIT_START_ADDR => 0
        )
        port map (
            clk => clk,
            
            re       => src_re,
            addr     => src_addr,
            data_out => src_data_in
        );
    
    -- instantiate target memory to copy data to
    tar_mem : entity work.ram(rtl)
        generic map (
            ADDR_WIDTH => TAR_ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            
            we       => tar_we,
            re       => '0', -- it is not required to read the data back
            addr     => tar_addr,
            data_in  => tar_data_out,
            data_out => tm_data_out
        );
    
    -- Purpose: Clock process definition.
    clk_proc : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_proc;
    
    -- Purpose: Stimulus process.
    stim_proc : process
    begin
        
        wait for CLK_PERIOD; -- delay to initialize the uut
        
        copy_en         <= '1';
        tar_start_addr  <= (2 ** TAR_ADDR_WIDTH) - 4; -- the last 4 addresses of the target memory
        copy_addr_count <= 4;
        wait for CLK_PERIOD;
        
        assert (src_re = '1')
            report "Read should have been already started!" severity error;
        wait for CLK_PERIOD;
        
        assert (tar_we = '0')
            report "Data to be written to the target memory are not defined, " &
            "write must not be enabled." severity error;
        wait for CLK_PERIOD;
        
        assert (tar_we = '1')
            report "Write should been already started!" severity error;
        wait for CLK_PERIOD;
        
        assert (src_re = '1')
            report "It is required to read another data!" severity error;
        wait for CLK_PERIOD;
        
        assert (src_re = '0')
            report "All required data are now read, read signal should be '0'!" severity error;
        wait for CLK_PERIOD;
        
        assert (tar_we = '1')
            report "It is required to write one more byte of data!" severity error;
        wait for CLK_PERIOD;
        
        assert (tar_we = '0' and copy_cmplt = '1')
            report "Write now must be done, tar_we signal should '0' " &
            "and copy_cmplt should be '1' to indicate the finished copying!" severity error;
        copy_en <= '0'; -- copying has been done
        wait for CLK_PERIOD;
        
        assert (copy_cmplt = '0')
            report "The copy_cmplt signal must have '0' now!" severity error;
        wait for CLK_PERIOD;
        
        -- copying to all the target's addresses
        src_start_addr  <= (2 ** SRC_ADDR_WIDTH) / 2;
        tar_start_addr  <= (2 ** TAR_ADDR_WIDTH) / 2;
        copy_addr_count <= 2 ** TAR_ADDR_WIDTH;
        copy_en         <= '1';
        wait for 3 * CLK_PERIOD;
        
        for i in 1 to copy_addr_count loop -- one pass per one write/read
            -- the address=data pattern matching
            assert (to_integer(unsigned(tar_addr)) = to_integer(unsigned(tar_data_out)))
                report "Write to the target memory does not match the address=data pattern!"
                severity error;
            wait for CLK_PERIOD;
        end loop;
        
        assert (tar_we = '0' and copy_cmplt = '1')
            report "Write now must be done, tar_we signal should '0' " &
            "and copy_cmplt should be '1' to indicate the finished copying!" severity error;
        copy_en <= '0'; -- copying has been done
        wait for CLK_PERIOD;
        
        -- check status after copying has been done and the module now must be in idle
        assert (copy_cmplt = '0')
            report "The copy_cmplt signal must have '0' now!" severity error;
        assert (src_addr = (others => '0'))
            report "The source memory address must be initialized to vector of '0'!" severity error;
        assert (tar_addr = (others => '0'))
            report "The target memory address must be initialized to vector of '0'!" severity error;
        wait;
        
    end process stim_proc;
    
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
