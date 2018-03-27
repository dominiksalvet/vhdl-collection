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
use ieee.numeric_std.all;


entity ser_to_par is
    generic (
        g_DATA_WIDTH : positive range 2 to natural'high := 4
    );
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        
        i_data     : in  std_logic;
        o_data_ack : out std_logic;
        o_data     : out std_logic_vector(g_DATA_WIDTH - 1 downto 0)
    );
end entity ser_to_par;


architecture rtl of ser_to_par is
    -- output buffers
    signal b_o_data : std_logic_vector(g_DATA_WIDTH - 1 downto 0);
begin
    
    o_data <= b_o_data;
    
    shift_and_ack : process (i_clk) is
        variable r_bits_count : natural range 0 to g_DATA_WIDTH - 1;
    begin
        if (rising_edge(i_clk)) then
            o_data_ack <= '0';
            b_o_data   <= b_o_data(b_o_data'left - 1 downto 0) & i_data;
            
            if (i_rst = '1') then
                r_bits_count := 0;
            else
                if (r_bits_count = g_DATA_WIDTH - 1) then
                    o_data_ack   <= '1';
                    r_bits_count := 0;
                else
                    r_bits_count := r_bits_count + 1;
                end if;
            end if;
        end if;
    end process shift_and_ack;
    
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
