library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.pkg.all;

entity ic is
  port(
    i_val_ic   : in std_logic;                                    -- Start Signal
    ic_input   : in std_logic_vector(Xnor_in_column-1 downto 0);  --Input
    clk        : in std_logic;
    reset      : in std_logic;
    result     : out std_logic_vector(13 downto 0);               --Result Output
    o_val_ic   : out std_logic                                    --Finish Signal
  );
end ic;

architecture rtl of ic is

  signal i_val_pop     : std_logic;                     --Start Signal for Popcount
  signal first_ic_ext  : std_logic_vector(63 downto 0); --one vector of 64 Bits because the Input of Popcount is 64 Bits  
  signal delay         : std_logic_vector(3 downto 0);  --Delay Value for Output right Timing

  begin

    --Process to assign the Input to the Signal and extend it when needed
    process(clk)
    begin
      if rising_edge(clk)then
        if reset = '1' then
          first_ic_ext <= (others => '0');
        elsif i_val_ic = '1' then
          if Xnor_in_column = 64 then
            first_ic_ext <= std_logic_vector(ic_input);
          else
            first_ic_ext <= (63 downto Xnor_in_column => '0') & ic_input;
          end if;
        end if;
      end if;
    end process;

   --Start the Popcount Calculation when The Interface circuit gets a Start Signal after a delay 
  process(clk)
  begin
    if rising_edge(clk)then
      if reset = '1' then
        i_val_pop <= '0';
        delay <= (others => '0');
      else
        delay <= delay(2 downto 0) & i_val_ic;
        if(delay(3) = '1')then
          i_val_pop <= '1';
        end if;
      end if;
    end if;
end process;

  --Call the Popcount to calculates how many ones in the input Vectors
  inst_bnn_popcount : entity work.popcount(rtl)
  port map(
      i_val       => i_val_pop,
      clk         => clk,
      rst         => reset,
      stream_i    => first_ic_ext,
      o_val       => o_val_ic,
      stream_o    => result
  );

end rtl;
