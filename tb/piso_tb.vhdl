--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     The test bench sends every possible bit combination to the i_data input,
--     beginning from the 0 value in binary form. Then it test the serialized
--     output on the o_data signal. It also tests values of o_rdy and
--     o_data_start indicators.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.string_pkg.all;
use work.piso;

entity piso_tb is
end entity piso_tb;


architecture behavioral of piso_tb is
    
    -- uut generics
    constant g_DATA_WIDTH : integer range 2 to integer'high := 4;
    constant g_LSB_FIRST  : boolean                         := true;
    
    -- uut ports
    signal i_clk : std_ulogic := '0';
    signal i_rst : std_ulogic := '0';
    
    signal i_start : std_ulogic                                   := '0';
    signal i_data  : std_ulogic_vector(g_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal o_rdy   : std_ulogic;
    
    signal o_data_start : std_ulogic;
    signal o_data       : std_ulogic;
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
    -- simulation finished flag to stop the clk_gen process
    shared variable v_sim_finished : boolean := false;
    
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
    
    clk_gen : process is
    begin
        i_clk <= '0';
        wait for c_CLK_PERIOD / 2;
        i_clk <= '1';
        wait for c_CLK_PERIOD / 2;
        
        if (v_sim_finished) then
            wait;
        end if;
    end process clk_gen;
    
    stimulus : process is
    begin
        
        i_rst <= '1';
        wait for c_CLK_PERIOD;
        
        i_rst <= '0';
        wait for c_CLK_PERIOD;
        
        i_start <= '1';
        for i in 0 to integer((2 ** i_data'length) - 1) loop -- loop through all the combinations
            i_data <= std_ulogic_vector(to_unsigned(i, i_data'length));
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
        
        v_sim_finished := true;
        wait;
        
    end process stimulus;
    
end architecture behavioral;
