-------------------------------------------------------------------------------
-- Standard:    VHDL-1993
-- Platform:    independent
-- Dependecies: clk_divider.vhd
-------------------------------------------------------------------------------
-- Description:
--     A test bench of the clk_divider entity with the rtl architecture.
-------------------------------------------------------------------------------
-- Comments:
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity clk_divider_tb is
end entity clk_divider_tb;


architecture behavior of clk_divider_tb is
    
    constant CLK_PERIOD : time := 10 ns; -- clock period definition
    
    -- clk_divider signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    
    signal freq_div : positive := 1;
    signal clk_out  : std_logic;
    
begin
    
    -- instantiate the unit under test (uut)
    uut : entity work.clk_divider(rtl)
        generic map (
            FREQ_DIV_MAX_VALUE => 7
        )
        port map (
            clk => clk,
            rst => rst,

            freq_div => freq_div,
            clk_out  => clk_out
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
        wait for 10 * CLK_PERIOD;

        freq_div <= 2;
        wait for 10 * CLK_PERIOD;

        freq_div <= 3;
        wait for 10 * CLK_PERIOD;

        freq_div <= 4;
        wait for 10 * CLK_PERIOD;

        freq_div <= 7;
        wait for 10 * CLK_PERIOD;

        freq_div <= 1;
        wait for 10 * CLK_PERIOD;

        freq_div <= 4;
        wait;
        
    end process stim_proc;
    
end architecture behavior;
