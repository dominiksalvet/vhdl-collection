--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     The test bench sends every possible bit combination to the i_data input
--     in serial representation, beginning from the 0 value in binary form. Then
--     it test the parallelized output on the o_data signal. It also tests
--     behavior of the o_data_valid indicator.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vhdl_collection;
use vhdl_collection.util_pkg.all;

use work.sipo;


entity sipo_tb is
end entity sipo_tb;


architecture behavioral of sipo_tb is
    
    -- uut generics
    constant g_DATA_WIDTH : integer range 2 to integer'high := 4;
    constant g_LSB_FIRST  : boolean                         := true; 
    
    -- uut ports
    signal i_clk : std_ulogic := '0';
    signal i_rst : std_ulogic := '0';
    
    signal i_data_start : std_ulogic := '0';
    signal i_data       : std_ulogic := '0';
    
    signal o_data_valid : std_ulogic;
    signal o_data       : std_ulogic_vector(g_DATA_WIDTH - 1 downto 0);
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
    -- simulation finished flag to stop the clk_gen process
    shared variable v_sim_finished : boolean := false;
    
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
        variable v_vector : std_ulogic_vector(g_DATA_WIDTH - 1 downto 0);
    begin
        
        i_rst <= '1';
        wait for c_CLK_PERIOD;
        
        i_rst <= '0';
        wait for c_CLK_PERIOD;
        
        i_data_start <= '1';
        for i in 0 to (2 ** o_data'length) - 1 loop -- loop through all the combinations
            if (g_LSB_FIRST) then -- least significant bit is the first one
                for j in 0 to g_DATA_WIDTH - 1 loop -- serial data receiving
                    v_vector := std_ulogic_vector(to_unsigned(i, v_vector'length));
                    i_data   <= v_vector(j);
                    wait for c_CLK_PERIOD;
                end loop;
            else -- most significant bit is the first one
                for j in g_DATA_WIDTH - 1 downto 0 loop -- serial data receiving
                    v_vector := std_ulogic_vector(to_unsigned(i, v_vector'length));
                    i_data   <= v_vector(j);
                    wait for c_CLK_PERIOD;
                end loop;
            end if;
            
            assert (o_data_valid = '1') -- the data must be valid after the previous sequence
                report "Expected o_data_valid='1'!"
                severity error;
            -- the parallelized data must be equal to the input serial data
            assert (o_data = std_ulogic_vector(to_unsigned(i, o_data'length)))
                report "Expected o_data=""" &
                to_string(std_ulogic_vector(to_unsigned(i, o_data'length))) & """, parallelized " &
                "output data are not equal to the previous serial data!"
                severity error;
        end loop;
        i_data_start <= '0';
        wait for c_CLK_PERIOD;
        
        assert (o_data_valid = '1')
            report "Expected o_data_valid='1'!"
            severity error;
        
        v_sim_finished := true;
        wait;
        
    end process stimulus;
    
end architecture behavioral;
