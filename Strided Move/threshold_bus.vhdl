library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.numeric_std.all; 

library work;
use work.pkg.all;

entity threshold_bus is 

    Port (  
        clk         : in std_logic; 
        reset       : in std_logic; 
        i_val_T     : in std_logic;                                 --Start Signal
        start_value : in integer;                                   --Start Value to specify wich value from Rom to work with
        output      : out threshold_array(column_in_cb-1 downto 0); --Array of (number of the Column in Crossbar) Vectors of the size of 32 Bits
        o_val       : out std_logic                                 --Finish Signal
        ); 
    end threshold_bus; 
 
architecture rtl of threshold_bus is 
 
      signal count    : integer:=0;								  --Counter to determine if we still inside the Range of the Threshold Matrix and to specify the adress to the Threshold Rom
      signal mem      : threshold_array(column_in_cb-1 downto 0); --an Array Signal to save the Results and then to assign it to the Output Array
      signal temp_add : std_logic_vector(7 downto 0);			  --a Signal used to transfer an Integer to 8 Bits Vector as the Adress of the Threshold Rom
      signal T        : std_logic_vector(31 downto 0);			  --a Signal to save the output results of the Rom
      signal delay    : std_logic_vector(1 downto 0);			  --delay Signal for finsh signal
      signal start    : std_logic;								  --first Delay signal
      signal noway    : std_logic;								  --second Delay signal

begin

    --Call the Threshold Rom
    threshold_rom_inst: entity work.threshold_rom(rtl)
      port map (
        Clk         => Clk,
        Reset       => Reset,
        add         => temp_add,
        Threshold_out => T
      );
  
      --Integer to Vector
      temp_add <= std_logic_vector(to_unsigned(count,temp_add'length)); 

      --Process to fill in the bus with the right Threshold in the right timing
      process (clk) 
      begin
        if rising_edge(clk) then 
          if reset = '1' then 
            noway <= '1';
            start <= '0';
          elsif noway = '1' then 
            count <= start_value;
           start <= '1';
            noway <= '0';
          elsif start = '1' then 
            noway <= '0';
            start <= '0';
          elsif i_val_T = '1' and count < (start_value + column_in_cb)-1 and noway = '0' then 
            count <= count + 1;
            mem(count mod column_in_cb) <= T;
            start <= '1';
          elsif count = (start_value + column_in_cb)-1 then
            mem(count mod column_in_cb) <= T;
          
          end if;
        end if;
      end process;

      --Process to calculate the delayed finsh Signal and to assign the output
      process(clk)
      begin 
      if rising_edge(clk) then
        if reset = '1' then
          delay <= (others => '0');
          o_val <= '0';
          output <= mem;
        elsif count = (start_value + column_in_cb)-1 then
          delay <= delay (0) & '1';
          if delay(1) = '1' then 
            o_val <= '1'; 
            output <= mem;
          end if;
        end if;
      end if;
      end process;
     
end rtl;
