--------------------------------------------------------------------------------
-- Description:
--     The test bench simulates to copy first 4 bytes from the source memory to
--     the last 4 bytes of the target memory. After verify that the data were
--     correctly written, the whole source memory image is copied to the target
--     memory.
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
    
    signal start_src_addr  : natural range 0 to (2 ** SRC_ADDR_WIDTH) - 1 := 0;
    signal start_tar_addr  : natural range 0 to (2 ** TAR_ADDR_WIDTH) - 1 := 0;
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
            
            start_src_addr  => start_src_addr,
            start_tar_addr  => start_tar_addr,
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
            
            INIT_DATA       => create_simple_mem_init_data(SRC_ADDR_WIDTH, DATA_WIDTH),
            INIT_START_ADDR => 0
        )
        port map (
            clk => clk,
            
            re       => '1',
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
            re       => '1',
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
        
        -- serves as initialize the module as '0' value of copy_en behaves like that
        wait for CLK_PERIOD;
        
        copy_en         <= '1';
        start_tar_addr  <= (2 ** TAR_ADDR_WIDTH) - 4;
        copy_addr_count <= 4;
        wait until copy_cmplt = '1';
        wait for CLK_PERIOD;
        
        copy_en <= '0';
        wait;
        
    end process stim_proc;
    
    -- Purpose: Control process.
    contr_proc : process
    begin
        
        wait;
        
    end process contr_proc;
    
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
