library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.numeric_std.all; 
library work;
use work.pkg.all;

entity SM is
  port (
    i_val_sm        : in  std_logic;                                    --Start Signal
    data            : in  std_logic_vector(Xnor_in_column -1 downto 0); --Input Vector
    weights         : in  array_col_in_CB (column_in_cb -1 downto 0);   --Array of Weights Vectors
    threshold       : in  threshold_array(column_in_cb -1 downto 0);    --Array of Threshold Vectors
    clk             : in  std_logic;
    reset_cb        : in  std_logic;                                    --Reset Signal for the Crossbar
    reset_acc_comp  : in  std_logic;                                    --Reset Signal for Accumulator and Comparator
    o_val_cb        : out std_logic;                                    --Finish Signal for the Crossbar
    SM_result       : out std_logic_vector(0 to column_in_cb-1);        --Results Vector Output
    o_val_sm        : out std_logic                                     --Finish Signal for Strided Move
  ) ;
end SM ; 

architecture rtl of SM is

    type ram_acc is array (column_in_cb-1 downto 0)  of std_logic_vector(31 downto 0); --arrray of number of columns to save Results from Accumulator
    signal o_tmp_res_acc   : ram_acc:= (others => (others => '0'));
    signal pop_result      : ram_pop;                                                  --Array of Crossbar Results Vectors
    signal o_val_acc       : std_logic_vector(column_in_cb-1 downto 0);                --Finish Signals of Accumulator
    signal o_val_comp      : std_logic_vector(column_in_cb-1 downto 0);                --Finish Signals of Comparator
    signal o_temp_val_cb   : std_logic;                                                --temproary Finish Signals of Crossbar

begin
  
    --Call the Crossbar
    cb_inst: entity work.cb(rtl) 
    port map ( 
      i_val_cb      => i_val_sm, 
      data          => data,
      weights       => weights,
      clk           => clk, 
      reset         => reset_cb, 
      result        => pop_result, 
      o_val_cb      => o_temp_val_cb 
    ); 

      -- Generate many Accumulators and Comparators as the Same number of Columns in Crossbar
      gen_acc_comp: for i in 1 to column_in_cb generate 

      acc_inst: entity work.acc(rtl)
      port map (
        i_val_acc => o_temp_val_cb,
        reset     => reset_acc_comp,
        clk       => clk,
        i_data    => pop_result(i-1),
        o_data    => o_tmp_res_acc(i-1),
        o_val_acc => o_val_acc(i-1)
      );

      comparator_inst: entity work.comparator(rtl)
      port map (
          clk        => clk,
          reset      => reset_acc_comp,
          i_val_comp => o_val_acc(i-1),
          a          => o_tmp_res_acc(i-1),
          b          => threshold(i-1),
          a_comp_b   => SM_result(i-1),
          o_val_comp => o_val_comp(i-1)
        );

      end generate; 

      --Assign the Finish Signals to the output Finish Values
      o_val_cb <= o_temp_val_cb;
      o_val_sm <= o_val_comp(0);

end architecture ;