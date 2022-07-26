library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity cb_dff is
   generic(
      W : integer:=2 -- Size of the Input and Output Vectors
   );
    port(
        d :  in std_logic_vector(W-1 downto 0);	--Input Vector
        rst : in std_logic;
        clk : in std_logic;
        q   : out std_logic_vector(W-1 downto 0)--Output Vector
    );
end cb_dff;

architecture rtl of cb_dff is

begin
	--FlipFlop
    process(clk,rst)begin
        if rst = '1'then
            q <= (others=>'0');
        elsif rising_edge(clk)then
            q <= d;
        end if;
    end process;

end rtl;
