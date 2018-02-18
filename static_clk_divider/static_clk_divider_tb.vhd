-------------------------------------------------------------------------------
-- Standard:    VHDL-1993
-- Platform:    independent
-- Dependecies: static_clk_divider.vhd
-------------------------------------------------------------------------------
-- Description:
--     A test bench of the static_clk_divider entity with the rtl architecture.
-------------------------------------------------------------------------------
-- Comments:
--     1. Uses FREQ_DIV with value 5 to see that clk_out period is 5 times
--        longer than the original one of clk. Also value '1' is assigned for
--        2 clk period while value '0' is assigned for 3 clk period.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity static_clk_divider_tb is
end static_clk_divider_tb;

architecture behavior of static_clk_divider_tb is
    
    constant CLK_PERIOD : time := 10 ns; -- clock period definition
    
    -- static_clk_divider signals
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal clk_out : std_logic;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.static_clk_divider(rtl)
        generic map (
            FREQ_DIV => 5
        )
        port map (
            clk     => clk,
            rst     => rst,
            clk_out => clk_out
        );
    
    -- Purpose: Clock process definition.
    clk_proc : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_proc;
    
    -- Purpose: Stimulus process.
    stim_proc : process
    begin 

        rst <= '1'; -- initialize the module
        wait for CLK_PERIOD;

        rst <= '0';
        wait;

    end process stim_proc;
    
end architecture behavior;
