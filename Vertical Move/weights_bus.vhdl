library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.numeric_std.all; 
library work;
use work.pkg.all;

entity weights_bus is 
    Port (  
        clk         : in std_logic; 
        reset       : in std_logic; 
        i_val_W     : in std_logic; 							    --Start Signal
        start_value : in integer;									--Start Value to specify wich value from Rom to work with
        i_xnor      : in integer;									--Start Value to specify wich part of the Vector to work with 
        output      : out array_col_in_CB(column_in_cb-1 downto 0); --Array of (number of the Column in Crossbar) Vectors of the size of number of Xnors in the Crossbar
        o_val       : out std_logic								    --Finish Signal
        ); 

end weights_bus; 
 
architecture rtl of weights_bus is 
 
      signal count    : integer:=0;							      --Counter to determine if we still inside the Range of the Weight Matrix and to specify the adress to the Weight Rom
      signal cnt_xnor : integer;								  --a Value to determine if we still inside the Range of the Weight Vector Size and to specify the part of the Vector to calculate
      signal mem      : array_col_in_CB(column_in_cb-1 downto 0); --an Array Signal to save the Results and then to assign it to the Output Array
      signal temp_add : std_logic_vector(7 downto 0);			  --a Signal used to transfer an Integer to 8 Bits Vector as the Adress of the weight Rom
      signal w        : std_logic_vector(beta_gamma-1 downto 0);  --a Signal to save the output results of the Rom
      signal delay    : std_logic_vector(1 downto 0);			  --delay Signal for One Pulse finish signal
      signal start    : std_logic;								  --first Delay signal
      signal noway    : std_logic;								  --second Delay signal
      signal flag     : std_logic:= '0';						  --Helper Signal for One Pulse Output signal

begin
	
	--Call the Weight Rom
    weights_rom_inst: entity work.weights_rom(rtl)
      port map (
        Clk         => Clk,
        Reset       => Reset,
        add         => temp_add,
        Weights_out => w
      );
		
	  --Integer to Vector
      temp_add <= std_logic_vector(to_unsigned(count,temp_add'length)); 

	  --Process to fill in the bus with the right weights in the right timing 
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
          elsif i_val_W = '1' and count < (start_value + column_in_cb)-1 and noway = '0' and cnt_xnor > 0 then 
            count <= count + 1;
            mem(count mod column_in_cb) <= w(((cnt_xnor*Xnor_in_column)-1) downto ((cnt_xnor-1)*Xnor_in_column));
            start <= '1';
          elsif count = (start_value + column_in_cb)-1 then
            mem(count mod column_in_cb) <= w(((cnt_xnor*Xnor_in_column)-1) downto ((cnt_xnor-1)*Xnor_in_column));
          end if;
        end if;
      end process;
     
	 -- One Pulse Finish Signal
      process (clk) begin
        if rising_edge(clk) then
            if reset = '1' then
              delay <= (others => '0');
              o_val <= '0'; 
            elsif count = (start_value + column_in_cb)-1 then 
              delay <= delay (0) & '1';
              if delay(1) = '1' and flag = '0'  then
                o_val <= delay(1);
                output <= mem;
                flag   <= '1';
              elsif delay(1) = '0' then
                flag   <= '0';
              end if;
              if flag = '1' then
                o_val <= '0';
              end if;
            end if;
        end if;
    end process;

end rtl;
