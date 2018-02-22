--------------------------------------------------------------------------------
-- Standard:    VHDL-1993
-- Platform:    independent
-- Dependecies: none
--------------------------------------------------------------------------------
-- Description:
--     This VHDL description represents a generic memory copier module. It can
--     operate in wide ways of use. It behaves like a very simple DMA module.
--------------------------------------------------------------------------------
-- Notes:
--     1. The copy_en input must have '1' value for all the time of copying the
--        data.
--     2. The memories must have the same bit width of their data buses.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mem_copier is
    generic (
        SRC_ADDR_WIDTH : positive;
        TAR_ADDR_WIDTH : positive;
        DATA_WIDTH     : positive
        );
    port (
        clk        : in  std_logic;
        copy_en    : in  std_logic; -- in '0' reacts like a reset signal
        copy_cmplt : out std_logic;

        start_src_addr  : in natural range 0 to (2 ** SRC_ADDR_WIDTH) - 1;
        start_tar_addr  : in natural range 0 to (2 ** TAR_ADDR_WIDTH) - 1;
        -- assign copy_addr_count to 0 to program the whole target's address space
        copy_addr_count : in natural range 0 to (2 ** TAR_ADDR_WIDTH) - 1;

        src_data_in : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
        src_addr    : out std_logic_vector(SRC_ADDR_WIDTH - 1 downto 0);

        tar_we       : out std_logic;
        tar_addr     : out std_logic_vector(TAR_ADDR_WIDTH - 1 downto 0);
        tar_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
end entity mem_copier;


architecture rtl of mem_copier is

    signal copy_cmplt_reg : std_logic;

    signal copied_count     : std_logic_vector(SRC_ADDR_WIDTH - 1 downto 0);
    signal copied_count_inc : std_logic_vector(SRC_ADDR_WIDTH - 1 downto 0);

    signal start_src_addr_reg  : natural range 0 to (2 ** SRC_ADDR_WIDTH) - 1;
    signal start_tar_addr_reg  : natural range 0 to (2 ** TAR_ADDR_WIDTH) - 1;
    signal copy_addr_count_reg : natural range 0 to (2 ** TAR_ADDR_WIDTH) - 1;

    signal tar_we_reg : std_logic;

begin

    copy_cmplt <= copy_cmplt_reg;

    copied_count_inc <= std_logic_vector(unsigned(copied_count) + 1);

    src_addr <= std_logic_vector(start_src_addr_reg + unsigned(copied_count_inc));

    tar_we <= tar_we_reg;

    mem_copying : process(clk)
        variable init_state : std_logic;
    begin
        if (rising_edge(clk)) then
            if (copy_en = '0') then
                copy_cmplt_reg <= '0';
                tar_we_reg     <= '0';
                init_state     := '1';
            else

                if (init_state = '1') then
                    copied_count        <= (others => '1');
                    start_src_addr_reg  <= start_src_addr;
                    start_tar_addr_reg  <= start_tar_addr;
                    copy_addr_count_reg <= copy_addr_count;
                    init_state          := '0';
                else
                    tar_addr     <= std_logic_vector(start_tar_addr_reg + unsigned(copied_count));
                    tar_data_out <= src_data_in;

                    copied_count <= copied_count_inc;

                    if (
                        copied_count = (SRC_ADDR_WIDTH - 1 downto 0 => '0') and
                        tar_we_reg = '0' and copy_cmplt_reg = '0'
                        ) then
                        tar_we_reg <= '1';
                    elsif (copied_count = std_logic_vector(to_unsigned(copy_addr_count_reg, SRC_ADDR_WIDTH))) then
                        copy_cmplt_reg <= '1';
                        tar_we_reg     <= '0';
                    end if;
                end if;

            end if;
        end if;
    end process mem_copying;

end architecture rtl;


--------------------------------------------------------------------------------
-- MIT License
--
-- Copyright (c) 2016-2018 Dominik Salvet
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
