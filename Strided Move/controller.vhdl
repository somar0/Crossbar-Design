library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.numeric_std.all; 
library work;
use work.pkg.all;
 
entity controller is 

    Port (  
        clk          : in std_logic; 
        reset        : in std_logic; 
        finish_all   : out std_logic;                              --Finish Signal to tell that all Calculations are done
        final_result : out std_logic_vector(0 to column_in_cb-1);  --Final Results from 0 to column to be similer to the Python Program Results 
        o_val        : out std_logic                               --Finish Signal to tell that here is a valid Result
        ); 
    end controller; 
 
architecture rtl of controller is 

    signal cnt_w          : integer:=0;                                 --Counter to specify which Weigts set are being Calculated  
    signal cnt_d          : integer:=0;                                 --Counter to specify which Input Vector is being Calculated 
    signal cnt_xnor       : integer;                                    --Counter to specify which part of the Vector is being Calculated
    signal d_64           : std_logic_vector(Xnor_in_column-1 downto 0);--one vector from input as the number of Xnors in one column  
    signal mem_w          : array_col_in_CB(column_in_cb-1 downto 0);   --array to save Weights as the number of columns  
    signal mem_w_col      : array_col_in_CB(column_in_cb-1 downto 0);   --arrray to save number of columns weights vectors as the number of Xnors in one column
    signal mem_d          : std_logic_vector(Xnor_in_column-1 downto 0);-- one vector from input as the number of Xnors in one column
    signal mem_T          : threshold_array(column_in_cb-1 downto 0);   --array to save Threshold as the number of columns of 32 vectors
    signal o_val_cb       : std_logic;                                  --Finish Signal for the Crossbar
    signal reset_cb       : std_logic;                                  --reset Signal for the Crossbar
    signal i_val_sm       : std_logic;                                  --Start Signal for the Strided Move
    signal start          : std_logic;                                  --Start Signal
    signal reset_roms     : std_logic;                                  --reset Signal for the Input Rom
    signal avctiv_rom     : std_logic;									--Start Signal to trigger the Roms
    signal weights_loaded : std_logic;									--Finish Signal for Weight Bus that tell if the Weights are loaded
    signal reset_acc_comp : std_logic;									--reset Signal for the Accumulator and Comparator
    signal o_val_sm       : std_logic;								    --Finish Signal for the Strided Move
    signal reset_w        : std_logic;                                  --reset Signal for the Weight Rom
    signal delay          : std_logic_vector(1 downto 0);               --Delay Signal
    signal counter        : integer:=0;                                 --Counter to control Input Vectors

	attribute dont_touch : string;
	--preserve the Hierachy of instance sm_inst
	attribute dont_touch of sm_inst : label is "true";

begin 
 
  --Call the Weights Bus
  weights_bus_inst: entity work.weights_bus(rtl)
      port map (
        clk          => clk,
        reset        => reset_w,
        i_val_W      => avctiv_rom,
        start_value  => cnt_w,
        i_xnor       => cnt_xnor, 
        output       => mem_w,
        o_val        => weights_loaded
      );

    --Call the Input/Data Bus
    data_bus_inst: entity work.data_bus(rtl)
    port map (
      clk          => clk,
      reset        => reset_roms,
      i_val_D      => avctiv_rom,
      start_value  => cnt_d,
      i_xnor       => cnt_xnor, 
      output       => mem_d
    );

        --Call the Threshold Bus
        threshold_bus_inst: entity work.threshold_bus(rtl)
        port map (
          clk          => clk,
          reset        => reset_w,
          i_val_T      => avctiv_rom,
          start_value  => cnt_w,
          output       => mem_T,
          o_val        => open
        );
 
    --Main Controller that controll the Data Flows
    process(clk)
    begin
      if rising_edge(clk) then 
        if reset = '1' then 
            cnt_xnor       <= beta_gamma/Xnor_in_column; 
            reset_cb       <= '1';
            reset_roms     <= '1'; 
            reset_w        <= '1';
            reset_acc_comp <= '1';
            avctiv_rom     <= '1';
            d_64           <= (others => '0'); 
            mem_w_col      <= (others => (others => '0')); 
        
        elsif cnt_d < delta and counter < delta then 
                reset_cb     <= '0';
                reset_roms     <= '0';
                reset_w        <= '0'; 
                start          <= '0';

                if weights_loaded = '1' and o_val_cb = '0'  then 
                  d_64      <= mem_d;
                  mem_w_col <= mem_w; 
                  start     <= '1';
                  reset_roms <= '0';
                  reset_acc_comp <= '0';

                elsif o_val_cb = '1' then 
                  cnt_d      <= cnt_d + 1;
                  reset_roms <= '0';
                  reset_cb   <= '1';
                end if;
        
        elsif cnt_d = delta and cnt_xnor > 0 then 

            reset_cb     <= '1';
            reset_roms   <= '1'; 
            reset_w      <= '1';

            if weights_loaded = '0' then 
               cnt_xnor       <= cnt_xnor - 1 ; 
               cnt_d          <= 0;
            end if;
        
        elsif (cnt_xnor = 0 ) and cnt_w < alpha-column_in_cb then
            reset_cb       <= '1';
            reset_roms     <= '1'; 
            reset_w        <= '1';
            reset_acc_comp <= '1';
            cnt_w          <= cnt_w + column_in_cb;
            cnt_xnor       <= beta_gamma/Xnor_in_column;

        end if;
      end if;
    end process;
  
    --Process to calculates when all Calculations are done
    process(clk) 
    begin 
      if rising_edge(clk) then 
        if reset = '1' then 
          finish_all <= '0';
        elsif cnt_w = alpha - column_in_cb and cnt_d = 0 and cnt_xnor = 0 and o_val_sm = '0' then 
          finish_all <= '1';
        end if; 
       end if; 
    end process; 

    --Start Strided Move when Start is active after Delay
    process(clk)
    begin
        if rising_edge(clk)then
            if reset = '1'then
              delay <= (others => '0');
              i_val_sm <= '0';
            else
              delay <= delay(0 downto 0) & start;
              if(delay(1) = '1')then
                i_val_sm <= '1';
              else
              i_val_sm <= '0';
              end if;
            end if;
        end if;
 end process;

  --Call the Strided Move Component             
  sm_inst: entity work.SM(rtl)
    port map (
      i_val_sm       => i_val_sm,
      data           => d_64,
      weights        => mem_w_col,
      threshold      => mem_T,
      clk            => clk,
      reset_cb       => reset_cb,
      reset_acc_comp => reset_acc_comp,
      o_val_cb       => o_val_cb,
      SM_result      => final_result,
      o_val_sm       => o_val_sm
    );

  --Assign the Finish Signal to the Finish Value
  o_val <= o_val_sm ;

  --Process to controll the Input
  process(clk)
  begin
    if reset_acc_comp = '1' then 
      counter <= 0;
    elsif o_val_sm = '1' then
      counter <= counter + 1 ;
    end if;
  end process;

end rtl;
