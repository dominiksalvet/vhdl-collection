--------------------------------------------------------------------------------
-- Compliant: IEEE Std 1076-1993
-- Platform:  independent
--------------------------------------------------------------------------------
-- Description:
--     A generic implementation of a PWM module. The i_duty/g_PERIOD represents
--     what part of pwn_out period will have '1' value. Obviously using i_duty=0
--     will produce only value '0' on the o_signal.
--------------------------------------------------------------------------------
-- Notes:
--     1. The PWM module uses internal register to keep value of i_duty in
--        a time, the module then works only with this value.
--     2. Changes of the i_duty input are propagated to the internal register
--        only at the beginning of the o_signal period.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity pwm is
    generic (
        g_PERIOD : positive := 8 -- o_signal period, it is equal to <i_clk_period>*g_PERIOD
    );
    port (
        i_clk : in std_ulogic; -- clock signal
        i_rst : in std_ulogic; -- reset signal
        
        -- describes how values '1' and '0' are divided in the o_signal period
        i_duty   : in  integer range 0 to g_PERIOD;
        o_signal : out std_ulogic -- final PWM signal
    );
end entity pwm;


architecture rtl of pwm is
begin
    
    -- Description:
    --     Create final PWM signal.
    pwm_sampling : process (i_clk) is
        variable r_duty    : integer range 0 to g_PERIOD; -- internal register of the i_duty input
        variable r_counter : integer range 1 to g_PERIOD; -- o_signal period counter
    begin
        if (rising_edge(i_clk)) then
            if (i_rst = '1') then -- initialization
                -- use the value in a way it will automatically start a new PWM period
                r_counter := g_PERIOD;
                o_signal  <= '0';
            else
                
                if (r_counter < g_PERIOD) then -- perform a counting step
                    if (r_counter < r_duty) then
                        o_signal <= '1';
                    else
                        o_signal <= '0';
                    end if;
                    r_counter := r_counter + 1;
                else -- start a new o_signal period
                    if (i_duty = 0) then
                        o_signal <= '0';
                    else
                        o_signal <= '1';
                    end if;
                    r_duty    := i_duty; -- store a i_duty value for this period
                    r_counter := 1; -- reset the counter
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
