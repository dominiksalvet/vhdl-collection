--------------------------------------------------------------------------------
-- Standard: VHDL-1993
-- Platform: independent
--------------------------------------------------------------------------------
-- Description:
--     A generic implementation of a PWM module. The duty/PERIOD represents what
--     part of pwn_out period will have '1' value. Obviously using duty=0 will
--     produce only value '0' on the pwm_out.
--------------------------------------------------------------------------------
-- Notes:
--     1. The PWM module uses internal register to keep value of duty in a time,
--        the module then work only with this value.
--     2. Changes of the duty input are propagated to the internal register only
--        at the beginning of the pwm_out period.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity pwm is
    generic (
        PERIOD : positive -- pwm_out period, it is equal to <clk_period>*PERIOD
    );
    port (
        clk : in std_logic; -- clock signal
        rst : in std_logic; -- reset signal
        
        -- describes how values '1' and '0' are divided in the pwm_out period
        duty    : in  natural range 0 to PERIOD;
        pwm_out : out std_logic -- final PWM signal
    );
end entity pwm;


architecture rtl of pwm is
begin
    
    -- Description:
    --     Create final PWM signal.
    pwm_sampling : process (clk) is
        variable duty_reg : natural range 0 to PERIOD; -- internal register of the duty input
        variable counter  : positive range 1 to PERIOD; -- pwm_out period counter
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then -- initialization
                counter := PERIOD; -- use the value so it will automatically start a new PWM period
                pwm_out <= '0';
            else
                
                if (counter < PERIOD) then -- perform a counting step
                    if (counter < duty_reg) then
                        pwm_out <= '1';
                    else
                        pwm_out <= '0';
                    end if;
                    counter := counter + 1;
                else -- start a new pwm_out period
                    if (duty = 0) then
                        pwm_out <= '0';
                    else
                        pwm_out <= '1';
                    end if;
                    duty_reg := duty; -- store a duty value for this period
                    counter  := 1; -- reset the counter
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
