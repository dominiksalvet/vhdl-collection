--------------------------------------------------------------------------------
-- Description:
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

use work.sipo; -- sipo.vhd


entity sipo_tb is
end entity sipo_tb;


architecture behavior of sipo_tb is
    
    -- uut generics
    constant g_DATA_WIDTH : positive range 2 to natural'high := 4;
    constant g_LSB_FIRST  : boolean                          := true; 
    
    -- uut ports
    signal i_clk : std_logic := '0';
    signal i_rst : std_logic := '0';
    
    signal i_data_start : std_logic := '0';
    signal i_data       : std_logic := '0';
    
    signal o_data_valid : std_logic;
    signal o_data       : std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.sipo(rtl)
        generic map (
            g_DATA_WIDTH => g_DATA_WIDTH,
            g_LSB_FIRST  => g_LSB_FIRST
        )
        port map (
            i_clk => i_clk,
            i_rst => i_rst,
            
            i_data_start => i_data_start,
            i_data       => i_data,
            
            o_data_valid => o_data_valid,
            o_data       => o_data
        ); 
    
    i_clk <= not i_clk after c_CLK_PERIOD / 2; -- setup i_clk as periodic signal
    
    stimulus : process is
    begin
        
        i_rst <= '1';
        wait for c_CLK_PERIOD;
        
        i_rst        <= '0';
        i_data_start <= '1';
        i_data       <= '1';
        wait for c_CLK_PERIOD;
        
        i_data_start <= '0';
        wait for 3 * c_CLK_PERIOD;
        
        i_data_start <= '1';
        i_data       <= '0';
        wait for c_CLK_PERIOD;
        
        i_data_start <= '0';
        wait;
        
    end process stimulus;
    
    verification : process is
    begin
        wait;
    end process verification;
    
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
