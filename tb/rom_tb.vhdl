--------------------------------------------------------------------------------
-- Copyright (C) 2018 Dominik Salvet
-- SPDX-License-Identifier: MIT
--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Target:    independent
--------------------------------------------------------------------------------
-- Description:
--     Initializes the ROM memory from the linear_vector.txt file, which matches
--     pattern [address]=address and simulation will verify it with standard
--     sequential reading memory addresses. The simulation uses nibbles as data
--     width (4 bits).
--------------------------------------------------------------------------------
-- Notes:
--     1. The file path defined by g_MEM_IMG_FILENAME is relative to the file
--        where the rom module is defined in.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library vhdl_collection;
use vhdl_collection.util_pkg.all;

use work.rom;


entity rom_tb is
end entity rom_tb;


architecture behavioral of rom_tb is
    
    -- uut generics
    constant g_ADDR_WIDTH : positive := 4;
    constant g_DATA_WIDTH : positive := 4;
    
    constant g_MEM_IMG_FILENAME : string := "../data/mem_img/linear_4_4.txt";
    
    -- uut ports
    signal i_clk : std_ulogic := '0';
    
    signal i_re   : std_ulogic                                   := '0';
    signal i_addr : std_ulogic_vector(g_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal o_data : std_ulogic_vector(g_DATA_WIDTH - 1 downto 0);
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
    -- simulation finished flag to stop the clk_gen process
    shared variable v_sim_finished : boolean := false;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.rom(rtl)
        generic map (
            g_ADDR_WIDTH => g_ADDR_WIDTH,
            g_DATA_WIDTH => g_DATA_WIDTH,
            
            g_MEM_IMG_FILENAME => g_MEM_IMG_FILENAME
        )
        port map (
            i_clk => i_clk,
            
            i_re   => i_re,
            i_addr => i_addr,
            o_data => o_data
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
        
        i_re <= '1';
        -- read every unique address value, one value per each c_CLK_PERIOD from 0 address
        for i in 0 to integer((2 ** g_ADDR_WIDTH) - 1) loop
            i_addr <= std_ulogic_vector(to_unsigned(i, i_addr'length)); -- read memory
            wait for c_CLK_PERIOD; -- wait for i_clk rising edge to read the desired data
            
            -- asserting to verify the ROM module function
            assert (o_data = std_ulogic_vector(to_unsigned(i, o_data'length)))
                report "Expected the data from the " &
                integer'image(to_integer(unsigned(i_addr))) & " address to be equal to """ &
                to_string(std_ulogic_vector(to_unsigned(i, o_data'length))) & """, what matches " &
                "the [address]=address pattern!"
                severity error;
        end loop;
        
        v_sim_finished := true;
        wait;
        
    end process stimulus;
    
end architecture behavioral;
