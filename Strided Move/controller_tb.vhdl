library ieee;
use ieee.std_logic_1164.all;

library work;
use work.pkg.all;

entity controller_tb is
end controller_tb;

architecture tb of controller_tb is

    component controller
        port (clk         : in std_logic;
              reset       : in std_logic;
              finish_all  : out std_logic;
              final_result : out std_logic_vector (column_in_cb-1 downto 0);
              o_val       : out std_logic
              );
    end component;

    signal clk         : std_logic;
    signal reset       : std_logic;
    signal finish_all  : std_logic;
    signal final_result : std_logic_vector (column_in_cb-1 downto 0);
    signal o_val       : std_logic;

    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : controller
    port map (clk         => clk,
              reset       => reset,
              finish_all  => finish_all,
              final_result => final_result,
              o_val       => o_val);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed

        -- Reset generation
        -- EDIT: Check that reset is really your reset signal
        reset <= '1';
        wait for 15 ns;
        reset <= '0';
        wait for 10 ns;

        -- EDIT Add stimuli here
        wait for 0.63 ms ;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;
end tb;
