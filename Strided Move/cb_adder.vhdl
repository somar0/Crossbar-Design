library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cb_adder is
  generic(
          W_i : integer:=8; --inputs Vectors Size
          W_o : integer:=8);--output Vector Size
    port(
        a : in std_logic_vector(W_i-1 downto 0); --First Value
        b : in std_logic_vector(W_i-1 downto 0); --Second Value
        y : out std_logic_vector(W_o-1 downto 0) --Result
    );
 end cb_adder;

 architecture rtl of cb_adder is
    --create two Signals as the Size of the Output Vector
    signal slv1 : std_logic_vector(W_o-1 downto 0):=(others => '0');
    signal slv2 : std_logic_vector(W_o-1 downto 0):=(others => '0');

    begin

        --Assign the Signals with Values of the Inputs Vectors
        slv1(W_i - 1 downto 0) <= a;
        slv2(W_i - 1 downto 0) <= b;

        --Add Two Signals and save the Result in the Output 
        y <= std_logic_vector(unsigned(slv1) + unsigned(slv2));
end rtl;
