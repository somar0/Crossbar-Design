library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg.all;

entity CB is 
  port( 
    i_val_CB      : in std_logic; 									--Start Signal 
    data          : in std_logic_vector(Xnor_in_column-1 downto 0); --First Input Vector
    weights       : in array_col_in_CB (column_in_cb-1 downto 0);   --Second Input Vector
    clk           : in std_logic; 
    reset         : in std_logic; 
    result        : out ram_pop; 									--Array of Popcount Results					
    o_val_CB      : out std_logic									--Finish Signal
  ); 
end CB; 
 
architecture rtl of CB is 
 
  signal first_dff_data_CB      : std_logic_vector(Xnor_in_column-1 downto 0); --one vector from input as the number of Xnors in one column 
  signal first_dff_weights_CB   : array_col_in_CB(column_in_cb-1 downto 0);    --arrray of number of columns to save weights vectors as the number of Xnors in one column 
  signal i_val_column           : std_logic;							       --Start Signal for all Columns
  signal o_val_column           : std_logic_vector(column_in_cb-1 downto 0);   --Finish Signals for all Column
  signal flag                   : std_logic:='0';							   --Helper Signal for One Pulse Output signal

  begin 
  
  -- Initialize Weights Vectors as '0' and Input Vectors as '1' to have
  -- the Result Vectors when Reset is high to Zero because of Xnor 
  
	--Assign the Array of Weights Vectors to the Weight's Signal
    process(clk) 
      begin 
        if rising_edge(clk)then 
          if reset = '1' then 
            first_dff_weights_CB  <= (others => (others => '0'));
          elsif i_val_CB = '1'then 
            first_dff_weights_CB  <= weights; 
          end if; 
        end if; 
    end process; 
 
	--Assign the Input Vector to the Input's Signal
    process(clk) 
      begin 
        if rising_edge(clk)then 
          if reset = '1' then 
            first_dff_data_CB <= (others => '1');
          elsif i_val_CB = '1' then 
            first_dff_data_CB <= data; 
            end if; 
        end if; 
    end process; 

  --Start the Column Calculations when The Crossbar gets a Start Signal 
  process(clk) 
  begin 
      if rising_edge(clk)then 
            if i_val_CB = '1' then
              i_val_column <= '1'; 
            else 
              i_val_column <= '0'; 
            end if; 
      end if;
  end process; 
 
	-- Generate many Columns as the Same number of Columns in Crossbar 
    gen_col: for i in 1 to column_in_cb generate 
    column_inst: entity work.column(rtl) 
      port map ( 
        i_val_column => i_val_column, 
        data         => first_dff_data_CB, 
        weights      => first_dff_weights_CB(i-1),
        clk          => clk, 
        reset        => reset, 
        column_out   => result(i-1), 
        o_val_column => o_val_column(i-1)
      ); 
    end generate; 

  --Process for One Pulse Finish Signal
  process (clk) begin
    if rising_edge(clk) then
        if reset = '1' then
          o_val_CB <= '0'; 
        elsif o_val_column(0) = '1' and flag = '0' then
          o_val_CB <= o_val_column(0);
          flag   <= '1';
        elsif o_val_column(0) = '0' then
          flag   <= '0';
        end if;
        if flag = '1' then
          o_val_CB <= '0';
        end if;
    end if;
  end process;
 
end rtl;