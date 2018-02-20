-------------------------------------------------------------------------------
-- Standard:    VHDL-1993
-- Platform:    independent
-- Dependecies: mem_copier.vhd
-------------------------------------------------------------------------------
-- Description:
--     A test bench of the mem_copier entity with the rtl architecture.
-------------------------------------------------------------------------------
-- Notes:
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity mem_copier_tb is
end entity mem_copier_tb;


architecture behavior of mem_copier_tb is
    
    constant CLK_PERIOD : time := 10 ns; -- clock period definition
    
    -- mem_copier generics
    constant SRC_ADDR_WIDTH : positive := 8;
    constant TAR_ADDR_WIDTH : positive := 8;
    constant DATA_WIDTH     : positive := 8;
    
    -- mem_copier ports
    signal clk        : std_logic := '0';
    signal copy_en    : std_logic := '0';
    signal copy_cmplt : std_logic;
    
    signal start_src_addr  : natural range 0 to (2 ** SRC_ADDR_WIDTH) - 1 := 0;
    signal start_tar_addr  : natural range 0 to (2 ** TAR_ADDR_WIDTH) - 1 := 0;
    signal copy_addr_count : natural range 0 to (2 ** TAR_ADDR_WIDTH) - 1 := 0;
    
    signal src_data_in : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal src_addr    : std_logic_vector(SRC_ADDR_WIDTH - 1 downto 0);
    
    signal tar_we       : std_logic;
    signal tar_addr     : std_logic_vector(TAR_ADDR_WIDTH - 1 downto 0);
    signal tar_data_out : std_logic_vector(DATA_WIDTH - 1 downto 0); 
    
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
            src_addr    => src_addr,
            
            tar_we       => tar_we,
            tar_addr     => tar_addr,
            tar_data_out => tar_data_out
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
        
        wait;
        
    end process stim_proc;
    
    -- Purpose: Control process.
    contr_proc : process
    begin
        
        wait;
        
    end process contr_proc;
    
end architecture behavior;


-------------------------------------------------------------------------------
-- MIT License
--
-- Copyright (c) 2018 Dominik Salvet
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.
-------------------------------------------------------------------------------
