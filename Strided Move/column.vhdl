library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
 
library work;
use work.pkg.all;
 
entity column is 

  port( 
    i_val_column  : in std_logic;                                   --Start Signal
    data          : in std_logic_vector(Xnor_in_column-1 downto 0); --First Input Vector
    weights       : in std_logic_vector(Xnor_in_column-1 downto 0); --Second Input Vector
    clk           : in std_logic;                                   
    reset         : in std_logic;                                   
    column_out    : out std_logic_vector(13 downto 0);              --Result Output
    o_val_column  : out std_logic                                   --Finish Signal
  ); 
end column; 
 
architecture rtl of column is 

  signal first_dff_data_column      : std_logic_vector(Xnor_in_column-1 downto 0);  --a Signal for a vector from Weight
  signal first_dff_weights_column   : std_logic_vector(Xnor_in_column-1 downto 0);  --a Signal for a vector from Weight
  signal xnor_output                : std_logic_vector(Xnor_in_column-1 downto 0);  --Xnor Result Vector
  signal o_val_xnor                 : std_logic;                                    --Finish Signal
 
  begin 

	  --Assign the Weight Vector to the Weight's Signal
    process(clk) 
      begin 
        if rising_edge(clk)then 
          if reset = '1' then 
            first_dff_weights_column  <= (others => '0'); 
          elsif i_val_column = '1' then 
            first_dff_weights_column  <= weights; 
          end if; 
        end if; 
    end process; 
 
    --Assign the Input Vector to the Input's Signal
    process(clk) 
      begin 
        if rising_edge(clk)then 
          if reset = '1' then 
            first_dff_data_column <= (others => '1'); 
          elsif i_val_column = '1' then 
            first_dff_data_column <= data; 
            end if; 
        end if; 
    end process; 
 
    --finish/Start the XNOR Calculations when The Column gets a Start Signal
    process(clk) 
        begin 
            if rising_edge(clk)then 
              if i_val_column = '1'then 
                o_val_xnor <= '1'; 
              else 
                o_val_xnor <= '0'; 
              end if; 
            end if; 
    end process; 
 
 	   --Calculate the Bitwise Xnor between the two input Vectors/Signals
     xnor_gen0 : for i in 1 to Xnor_in_column generate 
        inst_xnor0 :entity work.cb_xnor(rtl) 
          port map( 
            data    => first_dff_data_column(i-1), 
            weight  => first_dff_weights_column(i-1), 
            output1 => xnor_output(i-1) 
          ); 
     end generate; 
    
     -- Generate many interface circuits as the Same number of Columns in Crossbar
     ic_inst: entity work.ic(rtl) 
     port map ( 
       i_val_ic      => o_val_xnor, 
       ic_input      => xnor_output, 
       clk           => clk, 
       reset         => reset, 
       result        => column_out, 
       o_val_ic      => o_val_column 
     ); 
 
end rtl;