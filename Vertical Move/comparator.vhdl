library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.pkg.all;

entity comparator is
    port(
            clk         : in std_logic;
            reset       : in std_logic;
            i_val_comp  : in std_logic;						--Start Signal
            a           : in std_logic_vector(31 downto 0); --First Value from Accumulator
            b           : in std_logic_vector(31 downto 0); --Second Value from Treshold
            a_comp_b    : out std_logic;                    --Comparation Result
            o_val_comp  : out std_logic					    --Finish Signal
    );
    end comparator;

architecture rtl of comparator is
  
  signal flag     : std_logic:='0'; --Helper Signal for One Pulse Output signal
  
  begin

	--Compare a the Result of the Accumulator with b the Threshold
    process (clk) begin
        if rising_edge(clk) then
          if reset = '1' then 
            a_comp_b <= '0';
          elsif i_val_comp = '1' then
              if (a >= b) then
                  a_comp_b <= '1';
              else
                  a_comp_b <= '0';
              end if;
          end if;
        end if;
    end process;

  --Process for One Pulse Finish Signal
    process (clk) begin
      if rising_edge(clk) then
          if reset = '1' then
            o_val_comp <= '0'; 
          elsif i_val_comp = '1' and flag = '0' then
            o_val_comp <= '1';
            flag   <= '1';
          elsif i_val_comp = '0' then
            flag   <= '0';
          end if;
          if flag = '1' then
            o_val_comp <= '0';
          end if;
      end if;
  end process;

end rtl;
