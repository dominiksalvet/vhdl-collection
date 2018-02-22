--------------------------------------------------------------------------------
-- Standard:    VHDL-1993
-- Platform:    independent
-- Dependecies: rom.vhd
--------------------------------------------------------------------------------
-- Description:
--     A test bench of the rom entity with the rtl architecture.
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity rom_tb is
end entity rom_tb;


architecture behavior of rom_tb is
    
    -- rom generics
    constant ADDR_WIDTH : positive := 4;
    constant DATA_WIDTH : positive := 8;
    
    constant INIT_DATA      : std_logic_vector := "00001001000010000000011100000110";
    constant INIT_BASE_ADDR : natural          := 6;
    
    -- rom ports
    signal clk : std_logic := '0';
    
    signal re       : std_logic                                 := '0';
    signal addr     : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal data_out : std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    -- clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.rom(rtl)
        generic map (
            ADDR_WIDTH     => ADDR_WIDTH,
            DATA_WIDTH     => DATA_WIDTH,
            INIT_DATA      => INIT_DATA,
            INIT_BASE_ADDR => INIT_BASE_ADDR
        )
        port map (
            clk => clk,
            
            re       => re,
            addr     => addr,
            data_out => data_out
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

