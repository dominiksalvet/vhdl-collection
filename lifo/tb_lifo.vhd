--------------------------------------------------------------------------------
-- Description:
--     The test bench first fills up all the LIFO internal memory defined by
--     INDEX_WIDTH, which is set to 2, so internal capacity is 4 items. Then it
--     will test the full indicator and read all the items. Then it will verify
--     all the read data and empty indicator at the end.
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lifo; -- lifo.vhd


entity tb_lifo is
end entity tb_lifo;


architecture behavior of tb_lifo is
    
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
    uut : entity work.lifo(rtl)
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
    
    clk_proc : process is
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_proc;
    
    stim_proc : process is
    begin
        
        rst <= '1';
        wait for CLK_PERIOD; -- intitialize the uut
        
        rst <= '0';
        we  <= '1'; -- write process start
        wait for CLK_PERIOD;
        
        for i in 1 to 3 loop
            data_in <= std_logic_vector(to_unsigned(i, data_in'length));
            wait for CLK_PERIOD;
        end loop;
        
        assert (full = '1')
            report "The full indicator should have '1' value!" severity error;
        
        we <= '0';
        re <= '1';
        wait for CLK_PERIOD;
        
        for i in 3 downto 0 loop -- LIFO structure needs downto loop to verify data
            assert (data_out = std_logic_vector(to_unsigned(i, data_out'length)))
                report "Invalid value has been read from the LIFO!" severity error;
            if (i /= 0) then
                wait for CLK_PERIOD;
            end if;
        end loop;
        
        assert (empty = '1')
            report "The empty indicator should have '1' value!" severity error;
        
        we <= '1';
        wait for CLK_PERIOD;
        
        assert (empty = '1')
            report "The empty indicator should have '1' value, because write and read " &
            "at the same time must have no effect!" severity error;
        
        we <= '0';
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
