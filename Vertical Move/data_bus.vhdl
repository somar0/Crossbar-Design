library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.numeric_std.all; 
library work;
use work.pkg.all;

entity data_bus is 

    Port (  
        clk         : in std_logic; 
        reset       : in std_logic; 
        i_val_D     : in std_logic; 				    --Start Signal
        start_value : in integer;					    --Start Value to specify wich value from Rom to work with
        i_xnor      : in integer;						--Start Value to specify wich part of the Vector to work with 
        output      : out array_col_in_CB(0 downto 0)	--Array of one Vector of the size of number of Xnors in the Crossbar
        ); 
    end data_bus; 
 
architecture rtl of data_bus is 
 
    signal count    : integer:=0;							    --Counter to determine if we still inside the Range of the Input Matrix and to specify the adress to the Input Rom
    signal cnt_xnor : integer;									--a Value to determine if we still inside the Range of the Input Vector Size and to specify the part of the Vector to calculate
    signal mem      : array_col_in_CB(0 downto 0); 			    --an Array Signal to save the Results and then to assign it to the Output Array
    signal temp_add : std_logic_vector(7 downto 0);			    --a Signal used to transfer an Integer to 8 Bits Vector as the Adress of the Input Rom
    signal D        : std_logic_vector(beta_gamma-1 downto 0);	--a Signal to save the output results of the Rom
    signal start    : std_logic;							    --first Delay signal
    signal noway    : std_logic;								--second delay signal

begin

	--Call the Input Rom
    data_rom_inst: entity work.data_rom(rtl)
      port map (
        Clk         => Clk,
        Reset       => Reset,
        add         => temp_add,
        data_out    => D
      );
  
	  --Integer to Vector
      temp_add <= std_logic_vector(to_unsigned(count,temp_add'length)); 

	  --Process to fill in the bus with the right data in the right timing 
      process (clk) 
      begin
        if rising_edge(clk) then 
          if reset = '1' then 
            noway <= '1';
            start <= '0';
          elsif noway = '1' then 
            count <= start_value;
            cnt_xnor <= i_xnor;
           start <= '1';
            noway <= '0';
          elsif start = '1' then 
            noway <= '0';
            start <= '0';
          elsif i_val_D = '1' and count < (start_value + column_in_cb)-1 and noway = '0' and cnt_xnor > 0 then 
            mem(0) <= D(((cnt_xnor*Xnor_in_column)-1) downto ((cnt_xnor-1)*Xnor_in_column));
            start <= '1';
          end if;
        end if;
      end process;
	  
	  
	  --assign The results Signal Array to the Output Array 
      output <= mem;
      
end rtl;
