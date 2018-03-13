--------------------------------------------------------------------------------
-- Description:
--     Initialize the ROM memory with data that match pattern address=data and
--     the simulation will verify it with standard sequential reading memory
--     addresses.
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rom_public.all; -- rom_public.vhd
use work.rom; -- rom.vhd


entity rom_tb is
end entity rom_tb;


architecture behavior of rom_tb is
    
    -- uut generics
    constant ADDR_WIDTH : positive := 4;
    constant DATA_WIDTH : positive := 8;
    
    constant INIT_DATA : std_logic_vector := 
        create_simple_mem_init_data(ADDR_WIDTH, DATA_WIDTH);
    constant INIT_START_ADDR : natural := 0;
    
    -- uut ports
    signal clk : std_logic := '0';
    
    signal re       : std_logic                         := '0';
    signal addr     : unsigned(ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal data_out : std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    -- clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.rom(rtl)
        generic map (
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH,
            
            INIT_DATA       => INIT_DATA,
            INIT_START_ADDR => INIT_START_ADDR
        )
        port map (
            clk => clk,
            
            re       => re,
            addr     => addr,
            data_out => data_out
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
        
        re <= '1';
        -- read every unique address value, one value per each CLK_PERIOD from 0 address
        for i in 0 to (2 ** ADDR_WIDTH) - 1 loop
            addr <= to_unsigned(i, addr'length); -- read memory
            wait for CLK_PERIOD; -- wait for clk rising edge to read the desired data
            
            -- asserting to verify the ROM module function
            assert (data_out = std_logic_vector(to_unsigned(i, data_out'length)))
                report "The read data does not match pattern address = data!" severity error;
        end loop;
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
