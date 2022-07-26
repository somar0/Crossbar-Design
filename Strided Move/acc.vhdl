library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg.all;



entity acc is
    port(
        i_val_acc   : in  std_logic;                      --Start Signal
        reset       : in  std_logic;                      
        clk         : in  std_logic;                      
        i_data      : in  std_logic_vector(13 downto 0);  --Input vector from Crossbar
        o_data      : out std_logic_vector(31 downto 0);  --Output Result
        o_val_acc   : out std_logic                       --Finish Signal
    );  
end acc;

architecture rtl of acc is

    signal count_data          : integer;                                               --Counter to control iterate over the delta Registers 
    signal count_steps         : integer;                                               --Counter to control the Accumulation Steps
    signal count_results       : integer;                                               --Counter to control the Accumulation Calculations
    type acc_temp_result is array (delta-1 downto 0)  of std_logic_vector(13 downto 0); -- Array of delta Elements of 14 Bits Vector to store the temroary results  
    signal o_stream_acc   : acc_temp_result;                                            
    signal temp_val       : std_logic;                                                  --temproary finish Signal

begin

    --Process to iterate over the delta Registers for each Column 
    process(clk)
    begin 
    if rising_edge(clk) then
      if reset = '1' then
        count_data <= 0 ;
      elsif count_data = delta then
        count_data <= 0;
      elsif i_val_acc = '1' then 
          count_data <= count_data + 1 ; 
      end if;
    end if;
    end process;

     --Process to accumlates
    process(clk)
    begin
        if rising_edge(clk) then
          if reset = '1' then
            o_stream_acc <= (others => (others => '0'));
            count_steps  <= 0 ; 
          elsif i_val_acc = '1' then 
                o_stream_acc(count_data) <= std_logic_vector(unsigned(o_stream_acc(count_data)) + unsigned(i_data));
                count_steps <= count_steps + 1 ;
          end if;
        end if;
    end process;

    --Temproary Finish Signal when finshing the Calculations
    process(clk)
    begin
      if rising_edge(clk) then
        if reset = '1' then
          temp_val <= '0';
        elsif count_steps = ((beta_gamma / Xnor_in_column)* delta)then
             temp_val <= '1';
        else 
            temp_val <= '0';
        end if;
      end if;
    end process;

    --Finish Signal when finshing the Calculations and assign the Register value which is the Accumulation Result to the Output after Resize it to 32 Bits
    process(clk)
    begin 
      if rising_edge(clk) then
        if reset = '1' then 
            o_data <= (others => '0');
            o_val_acc    <= '0'; 
            count_results <= 0;
        elsif temp_val = '1' and count_results < delta and count_data = 0  then 
             o_data <=  (31 downto 14 => '0')  & o_stream_acc(count_results) ;
             count_results <= count_results + 1 ;
             o_val_acc <= '1';
        else 
             o_val_acc <= '0';
        end if;
      end if;
    end process;
   
end rtl;
