--------------------------------------------------------------------------------
-- Description:
--     The test bench sends every possible bit combination to the i_data input,
--     beginning from the 0 value in binary form. Then it test the serialized
--     output on the o_data signal. It also tests values of o_rdy and
--     o_data_start indicators.
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vhdl_collection;
use vhdl_collection.verif_util_pkg.all; -- verif_util_pkg.vhd

use work.piso; -- piso.vhd


entity piso_tb is
end entity piso_tb;


architecture behavior of piso_tb is
    
    -- uut generics
    constant g_DATA_WIDTH : integer range 2 to integer'high := 4;
    constant g_LSB_FIRST  : boolean                         := true;
    
    -- uut ports
    signal i_clk : std_logic := '0';
    signal i_rst : std_logic := '0';
    
    signal i_start : std_logic                                   := '0';
    signal i_data  : std_logic_vector(g_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal o_rdy   : std_logic;
    
    signal o_data_start : std_logic;
    signal o_data       : std_logic;
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.piso(rtl)
        generic map (
            g_DATA_WIDTH => g_DATA_WIDTH,
            g_LSB_FIRST  => g_LSB_FIRST
        )
        port map (
            i_clk => i_clk,
            i_rst => i_rst,
            
            i_start => i_start,
            i_data  => i_data,
            o_rdy   => o_rdy,
            
            o_data_start => o_data_start,
            o_data       => o_data
        ); 
    
    i_clk <= not i_clk after c_CLK_PERIOD / 2; -- setup i_clk as periodic signal
    
    stimulus : process is
    begin
        
        i_rst <= '1';
        wait for c_CLK_PERIOD;
        
        i_rst <= '0';
        wait for c_CLK_PERIOD;
        
        i_start <= '1';
        for i in 0 to (2 ** i_data'length) - 1 loop -- loop through all the combinations
            i_data <= std_logic_vector(to_unsigned(i, i_data'length));
            if (g_LSB_FIRST) then -- least significant bit is the first one
                for j in 0 to g_DATA_WIDTH - 1 loop
                    wait for c_CLK_PERIOD;
                    assert (o_data = i_data(j)) -- output data bit must be equal to the indexed one
                        report "Expected o_data='" & to_character(i_data(j)) & "', this bit of " &
                        "the serialized data should be equal to the according bit of the " &
                        "parallel input data!"
                        severity error;
                    if (j = 0) then
                        assert (o_data_start = '1') -- serial data start indicator check
                            report "Expected o_data_start='1'!"
                            severity error;
                    end if;
                    if (j = g_DATA_WIDTH - 1) then
                        assert (o_rdy = '1') -- the data should be ready now
                            report "Expected o_rdy='1'!"
                            severity error;
                    end if;
                end loop;
            else -- most significant bit is the first one
                for j in g_DATA_WIDTH - 1 downto 0 loop
                    wait for c_CLK_PERIOD;
                    assert (o_data = i_data(j)) -- output data bit must be equal to the indexed one
                        report "Expected o_data='" & to_character(i_data(j)) & "', this bit of " &
                        "the serialized data should be equal to the according bit of the " &
                        "parallel input data!"
                        severity error;
                    if (j = g_DATA_WIDTH - 1) then
                        assert (o_data_start = '1') -- serial data start indicator check
                            report "Expected o_data_start='1'!"
                            severity error;
                    end if;
                    if (j = 0) then
                        assert (o_rdy = '1') -- the data should be ready now
                            report "Expected o_rdy='1'!"
                            severity error;
                    end if;
                end loop;
            end if;
        end loop;
        i_start <= '0';
        wait for c_CLK_PERIOD;
        
        assert (o_rdy = '1')
            report "Expected o_rdy='1'!"
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
