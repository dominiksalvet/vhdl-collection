--------------------------------------------------------------------------------
-- Description:
--     The test bench first fulls up all the FIFO internal memory defined by
--     INDEX_WIDTH, which is set to 2, so internal capacity is 4 items. Then it
--     will test the full indicator and read all the items. Then it will verify
--     all the read data and empty indicator at the end.
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fifo; -- fifo.vhd


entity fifo_tb is
end entity fifo_tb;


architecture behavior of fifo_tb is
    
    -- uut generics
    constant INDEX_WIDTH : positive := 2;
    constant DATA_WIDTH  : positive := 8;
    
    -- uut ports
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    
    signal we      : std_logic                                 := '0';
    signal data_in : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    signal full    : std_logic;
    
    signal re       : std_logic := '0';
    signal data_out : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal empty    : std_logic;
    
    -- clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.fifo(rtl)
        generic map (
            INDEX_WIDTH => INDEX_WIDTH,
            DATA_WIDTH  => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            we      => we,
            data_in => data_in,
            full    => full,
            
            re       => re,
            data_out => data_out,
            empty    => empty
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
        
        rst <= '1';
        wait for CLK_PERIOD; -- intitialize the uut
        
        rst <= '0';
        we  <= '1'; -- write process start
        wait for CLK_PERIOD;
        
        data_in <= std_logic_vector(unsigned(data_in) + 1);
        wait for CLK_PERIOD;
        
        data_in <= std_logic_vector(unsigned(data_in) + 1);
        wait for CLK_PERIOD;
        
        data_in <= std_logic_vector(unsigned(data_in) + 1);
        wait for CLK_PERIOD;
        
        assert (full = '1')
            report "The full indicator should have '1' value!" severity error;
        
        we <= '0';
        re <= '1';
        wait for CLK_PERIOD;
        
        for i in 0 to 2 loop
            assert (data_out = std_logic_vector(to_unsigned(i, DATA_WIDTH)))
                report "Invalid value has been read from the FIFO!" severity error;
            wait for CLK_PERIOD;
        end loop;
        
        assert (data_out = std_logic_vector(to_unsigned(3, DATA_WIDTH)))
            report "Invalid value has been read from the FIFO!" severity error;
        assert (empty = '1')
            report "The empty indicator should have '1' value!" severity error;
        
        re <= '0';
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
