library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.pkg.all;



entity acc is
    port(
        i_val_acc   : in std_logic;						--Start Signal
        reset       : in std_logic;						
        clk         : in std_logic;						
        i_data      : in std_logic_vector(13 downto 0);	--Input vector from Crossbar
        o_data      : out std_logic_vector(31 downto 0);--Output Result
        o_val_acc   : out std_logic						--Finish Signal
    );
end acc;

architecture rtl of acc is

    signal o_acc : std_logic_vector(31 downto 0); 	--Register to store the Results of Accumulation Calculations 
    signal count : integer;							--Counter that count how many times has been added and controls the Accumulation Process

begin
   
    --Process to resize inputs data and accumlates
    process(clk)
        begin
        if rising_edge(clk) then
            if reset = '1' then 
                count <= 0;
                o_acc <= (others => '0');
            elsif count < (beta_gamma/Xnor_in_column) and i_val_acc = '1' then
                    o_acc <= std_logic_vector(unsigned(o_acc) + unsigned((31 downto 14 => '0')  & unsigned(i_data)));
                    count <= count + 1 ;
            end if;
        end if;
    end process;

	--Finish Signal when finshing the Calculations
    process(clk)
    begin
        if rising_edge(clk) then
        if reset = '1'then
            o_val_acc <= '0';
        elsif count = (beta_gamma/Xnor_in_column)  then
            o_val_acc <= '1';
        else 
            o_val_acc <= '0';
        end if;
        end if;
    end process;

    --Assign the Register value which is the Accumulation Result to the Output  
    process(clk)
        begin
            if rising_edge(clk) then
              if reset = '1'then
                  o_data <= (others => '0');
              else
                  o_data <= o_acc;
              end if;
            end if;
    end process;
    
end rtl;
