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


entity pwm is
    generic (
        PERIOD : positive := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        duty    : in  natural range 0 to PERIOD;
        pwm_out : out std_logic
    );
end entity pwm;


architecture rtl of pwm is
begin
    
    pwm_sampling : process (clk)
        variable duty_reg : natural range 0 to PERIOD;
        variable counter  : natural range 0 to PERIOD;
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                counter := PERIOD;
                pwm_out <= '0';
            else
                
                if (counter < PERIOD) then
                    if (counter < duty_reg) then
                        pwm_out <= '1';
                    else
                        pwm_out <= '0';
                    end if;
                    counter := counter + 1;
                else
                    if (duty = 0) then
                        pwm_out <= '0';
                    else
                        pwm_out <= '1';
                    end if;
                    duty_reg := duty;
                    counter  := 1;
                end if;
                
            end if;
        end if;
    end process pwm_sampling;
    
end architecture rtl;


--------------------------------------------------------------------------------
-- MIT License
--
-- Copyright (c) 2017-2018 Dominik Salvet
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
