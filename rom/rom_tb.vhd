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
use vhdl_collection.verif_util_pkg.all; -- verif_util_pkg.vhd

use work.rom; -- rom.vhd


entity rom_tb is
end entity rom_tb;


architecture behavior of rom_tb is
    
    -- uut generics
    constant g_ADDR_WIDTH : positive := 4;
    constant g_DATA_WIDTH : positive := 4;
    
    constant g_MEM_IMG_FILENAME : string := "mem_img/linear_4_4.txt";
    
    -- uut ports
    signal i_clk : std_logic := '0';
    
    signal i_re   : std_logic                                   := '0';
    signal i_addr : std_logic_vector(g_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal o_data : std_logic_vector(g_DATA_WIDTH - 1 downto 0);
    
    -- clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
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
    
    i_clk <= not i_clk after c_CLK_PERIOD / 2; -- setup i_clk as periodic signal
    
    stimulus : process is
    begin
        
        i_re <= '1';
        -- read every unique address value, one value per each c_CLK_PERIOD from 0 address
        for i in 0 to (2 ** g_ADDR_WIDTH) - 1 loop
            i_addr <= std_logic_vector(to_unsigned(i, i_addr'length)); -- read memory
            wait for c_CLK_PERIOD; -- wait for i_clk rising edge to read the desired data
            
            -- asserting to verify the ROM module function
            assert (o_data = std_logic_vector(to_unsigned(i, o_data'length)))
                report "Expected the data from the " &
                integer'image(to_integer(unsigned(i_addr))) & " address to be equal to """ &
                to_string(std_logic_vector(to_unsigned(i, o_data'length))) & """, what matches " &
                "the [address]=address pattern!"
                severity error;
        end loop;
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
