library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use ieee.numeric_std.all; 
library work;
use work.pkg.all;
 
entity controller is 

    Port (  
        clk          : in std_logic; 								
        reset        : in std_logic; 	
        finish_all   : out std_logic; 							  --Finish Signal to tell that all Calculations are done
        final_result : out std_logic_vector(0 to column_in_cb-1); --Final Results from 0 to column to be similer to the Python Program Results  
        o_val        : out std_logic							  --Finish Signal to tell that here is a valid Result
        ); 
    end controller; 
 
architecture rtl of controller is 

    signal cnt_w          : integer:=0;								    --Counter to specify which Weigts set are being Calculated 
    signal cnt_d          : integer:=0;								    --Counter to specify which Input Vector is being Calculated 
    signal cnt_xnor       : integer;								    --Counter to specify which part of the Vector is being Calculated 
    signal d_64           : std_logic_vector(Xnor_in_column-1 downto 0);--one vector from input as the number of Xnors in one column 
    signal mem_w          : array_col_in_CB(column_in_cb-1 downto 0);   --array to save Weights as the number of columns 
    signal mem_w_col      : array_col_in_CB(column_in_cb-1 downto 0);   --arrray to save number of columns weights vectors as the number of Xnors in one column 
    signal mem_d          : array_col_in_CB(0 downto 0); 				-- one vector from input as the number of Xnors in one column 
    signal mem_T          : threshold_array(column_in_cb-1 downto 0);   --array to save Threshold as the number of columns of 32 vectors
    signal is_empty       : std_logic:= '0'; 							--Finish Signal to tell that all Calculations are done
    signal o_val_cb       : std_logic;   							    --Finish Signal for the Crossbar
    signal reset_read     : std_logic; 								    --reset Signal for the Crossbar
    signal i_val_vm       : std_logic; 									--Start Signal for the Vertical Move 
    signal start          : std_logic; 									--Start Signal
    signal reset_roms     : std_logic;								    --reset Signal for the Roms
    signal avctiv_rom     : std_logic;								    --Start Signal to trigger the Roms
    signal weights_loaded : std_logic;									--Finish Signal for Weight Bus that tell if the Weights are loaded
    signal reset_acc_comp : std_logic;									--reset Signal for the Accumulator and Comparator
    signal o_val_vm       : std_logic;									--Finish Signal for the Vertical Move

	attribute dont_touch : string;
	--preserve the Hierachy of instance vm_inst
	attribute dont_touch of vm_inst : label is "true";

begin 
 
  --Call the Weights Bus
  weights_bus_inst: entity work.weights_bus(rtl)
      port map (
        clk          => clk,
        reset        => reset_roms,
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
          reset        => reset_roms,
          i_val_T      => avctiv_rom,
          start_value  => cnt_w,
          output       => mem_T,
          o_val        => open
        );
 
	--Main Controller that controll the Data Flows   
    process(clk) 
    begin 
        if(rising_edge(clk)) and is_empty /= '1' then 
            if(reset='1') then  
                    cnt_xnor       <= beta_gamma/Xnor_in_column; 
                    reset_read     <= '1';
                    reset_roms     <= '1'; 
                    reset_acc_comp <= '1';
                    avctiv_rom     <= '1';
                    d_64           <= (others => '0'); 
                    mem_w_col      <= (others => (others => '0')); 
                     
          elsif ( cnt_xnor > 0 ) then 
            reset_roms     <= '0'; 
            reset_read     <= '0';
            reset_acc_comp <= '0';
            start          <= '0';

              if weights_loaded = '1' and o_val_cb = '0' then  
                start <= '1';
                d_64  <= mem_d(0);
  
                L2: for var2 in 0 to column_in_cb-1 loop 
                    mem_w_col(var2) <= mem_w(var2) ; 
                end loop; 

                 elsif o_val_cb = '1' then 
                    reset_roms <= '1';
                    reset_read <= '1';
                    cnt_xnor   <= cnt_xnor - 1 ; 
              end if;   
            
          elsif (cnt_xnor = 0 ) and o_val_vm = '1' and cnt_d < delta-1 then
            reset_acc_comp <= '1';
            cnt_d          <= cnt_d + 1 ; 
            cnt_xnor       <= beta_gamma/Xnor_in_column; 

          elsif (cnt_xnor = 0 ) and o_val_vm = '1' and cnt_d = delta-1 and cnt_w < alpha-column_in_cb then
            reset_acc_comp <= '1';
            cnt_w          <= cnt_w + column_in_cb;
            cnt_d          <= 0;
            cnt_xnor       <= beta_gamma/Xnor_in_column;
          end if; 
        end if; 
    end process; 


	--Process to calculates when all Calculations are done
    process(clk) 
    begin 
      if rising_edge(clk) then 
           if cnt_w = alpha - column_in_cb and cnt_d = delta-1 and cnt_xnor = 0 and o_val_vm = '1' then 
              is_empty <= '1';
           end if; 
           finish_all  <= is_empty; 
       end if; 
    end process; 

	--Start Vertical Move when Start is active
    process(clk) 
    begin 
        if rising_edge(clk)then 
              if start = '1' then
                i_val_vm <= '1'; 
              else 
                i_val_vm <= '0'; 
              end if; 
            end if;
    end process; 

  --Call the Vertical Move Component
  vm_inst: entity work.VM
    port map (
      i_val_vm       => i_val_vm,
      data           => d_64,
      weights        => mem_w_col,
      threshold      => mem_T,
      clk            => clk,
      reset_cb       => reset_read,
      reset_acc_comp => reset_acc_comp,
      o_val_cb       => o_val_cb,
      VM_result      => final_result,
      o_val_vm       => o_val_vm
    );

	--Assign the Finish Signal to the Finish Value
    o_val <= o_val_vm;

end rtl;
