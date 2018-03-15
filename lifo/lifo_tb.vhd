--------------------------------------------------------------------------------
-- Description:
--     The test bench first fills up all the LIFO internal memory defined by
--     g_INDEX_WIDTH, which is set to 2, so internal capacity is 4 items. Then
--     it will test the o_full indicator and read all the items. Then it will
--     verify all the read data and the o_empty indicator at the end.
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lifo; -- lifo.vhd


entity lifo_tb is
end entity lifo_tb;


architecture behavior of lifo_tb is
    
    -- uut generics
    constant g_INDEX_WIDTH : positive := 2;
    constant g_DATA_WIDTH  : positive := 8;
    
    -- uut ports
    signal i_clk : std_logic := '0';
    signal i_rst : std_logic := '0';
    
    signal i_we   : std_logic                                   := '0';
    signal i_data : std_logic_vector(g_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal o_full : std_logic;
    
    signal i_re    : std_logic := '0';
    signal o_data  : std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    signal o_empty : std_logic;
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.lifo(rtl)
        generic map (
            g_INDEX_WIDTH => g_INDEX_WIDTH,
            g_DATA_WIDTH  => g_DATA_WIDTH
        )
        port map (
            i_clk => i_clk,
            i_rst => i_rst,
            
            i_we   => i_we,
            i_data => i_data,
            o_full => o_full,
            
            i_re    => i_re,
            o_data  => o_data,
            o_empty => o_empty
        ); 
    
    i_clk <= not i_clk after c_CLK_PERIOD / 2; -- setup i_clk as periodic signal
    
    stimulus : process is
    begin
        
        i_rst <= '1';
        wait for c_CLK_PERIOD; -- initialize the uut
        
        i_rst <= '0';
        i_we  <= '1'; -- write process start
        wait for c_CLK_PERIOD;
        
        for i in 1 to 3 loop
            i_data <= std_logic_vector(to_unsigned(i, i_data'length));
            wait for c_CLK_PERIOD;
        end loop;
        
        assert (o_full = '1')
            report "The o_full indicator should have '1' value!" severity error;
        
        i_we <= '0';
        i_re <= '1';
        wait for c_CLK_PERIOD;
        
        for i in 3 downto 0 loop -- LIFO structure needs downto loop to verify data
            assert (o_data = std_logic_vector(to_unsigned(i, o_data'length)))
                report "Invalid value has been read from the LIFO!" severity error;
            if (i /= 0) then
                wait for c_CLK_PERIOD;
            end if;
        end loop;
        
        assert (o_empty = '1')
            report "The o_empty indicator should have '1' value!" severity error;
        
        i_we <= '1';
        wait for c_CLK_PERIOD;
        
        assert (o_empty = '0')
            report "The o_empty indicator should have '0' value, because write and read " &
            "at the same time must lead to write!" severity error;
        
        i_we <= '0';
        i_re <= '0';
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
