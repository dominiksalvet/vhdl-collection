--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--------------------------------------------------------------------------------
-- Notes:
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity piso is
    generic (
        g_DATA_WIDTH : positive range 2 to natural'high := 4;
        g_LSB_FIRST  : boolean                          := true
    );
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        
        i_start : in  std_logic;
        i_data  : in  std_logic_vector(g_DATA_WIDTH - 1 downto 0);
        o_rdy   : out std_logic;
        
        o_data_start : out std_logic;
        o_data       : out std_logic
    );
end entity piso;


architecture rtl of piso is
    signal r_transmitting : std_logic;
    signal r_shifter      : std_logic_vector(g_DATA_WIDTH - 1 downto 0);
begin
    
    o_rdy <= not r_transmitting;
    
    assign_lsb : if (g_LSB_FIRST) generate
        o_data <= r_shifter(r_shifter'right);
    end generate assign_lsb;
    assign_msb : if (not g_LSB_FIRST) generate
        o_data <= r_shifter(r_shifter'left);
    end generate assign_msb;
    
    conversion_step : process (i_clk) is
        variable r_bit_counter : positive range 1 to g_DATA_WIDTH - 1;
    begin
        if (rising_edge(i_clk)) then
            o_data_start <= '0';
            
            if (i_rst = '1') then
                r_transmitting <= '0';
            else
                
                if (r_transmitting = '0') then
                    if (i_start = '1') then
                        o_data_start   <= '1';
                        r_transmitting <= '1';
                        r_shifter      <= i_data;
                        r_bit_counter  := 1;
                    end if;
                else
                    if (g_LSB_FIRST) then
                        r_shifter <= '-' & r_shifter(r_shifter'left downto 1);
                    else
                        r_shifter <= r_shifter(r_shifter'left - 1 downto 0) & '-';
                    end if;
                    
                    if (r_bit_counter = g_DATA_WIDTH - 1) then
                        r_transmitting <= '0';
                    end if;
                    r_bit_counter := r_bit_counter + 1;
                end if;
                
            end if;
            
        end if;
    end process conversion_step;
    
end architecture rtl;


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
