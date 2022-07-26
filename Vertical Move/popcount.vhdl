library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity popcount is

  port(
    i_val       : in std_logic;						-- Start Signal
    clk         : in std_logic;						
    rst         : in std_logic;						
    stream_i    : in std_logic_vector(63 downto 0);	--input Vector
    o_val       : out std_logic;					--Finish Signal
    stream_o    : out std_logic_vector(13 downto 0)	--output Result (how many ones in the input)
  );
end popcount;

architecture rtl of popcount is

    type ram_type32 is array (31 downto 0) of std_logic_vector(1 downto 0); --Arrays of 32 Elements of 2 Bits Vectors
    signal mem32_i      : ram_type32 := (others => (others => '0'));
    signal mem32_o      : ram_type32 := (others => (others => '0'));

    type ram_type16 is array (15 downto 0) of std_logic_vector(2 downto 0); --Arrays of 16 Elements of 3 Bits Vectors
    signal mem16_i      : ram_type16 := (others => (others => '0'));
    signal mem16_o      : ram_type16 := (others => (others => '0'));

    type ram_type8 is array (7 downto 0) of std_logic_vector(3 downto 0);   --Arrays of 8 Elements of 4 Bits Vectors
    signal mem8_i       : ram_type8 := (others => (others => '0'));
    signal mem8_o       : ram_type8 := (others => (others => '0'));

    type ram_type4 is array (3 downto 0) of std_logic_vector(4 downto 0);	--Arrays of 4 Elements of 5 Bits Vectors
    signal mem4_i       : ram_type4 := (others => (others => '0'));
    signal mem4_o       : ram_type4 := (others => (others => '0'));

    type ram_type2 is array (1 downto 0) of std_logic_vector(5 downto 0);	--Arrays of 2 Elements of 6 Bits Vectors
    signal mem2_i       : ram_type2 := (others => (others => '0'));
    signal mem2_o       : ram_type2 := (others => (others => '0'));

    type ram_type1 is array (0 downto 0) of std_logic_vector(6 downto 0);	--Arrays of 1 Elements of 7 Bits Vectors
    signal mem1_i       : std_logic_vector(6 downto 0);
    signal mem1_o       : std_logic_vector(6 downto 0);

    signal dff_stream   : std_logic_vector(63 downto 0);					--Signal of one vector of 64 Bits for input
    signal P           : std_logic_vector(13 downto 0):=(others => '0');    --Signal to hold the Result
    signal delay_val    : std_logic_vector(8 downto 0):= (others => '0');	--Delay signal

begin

	--Assign the input to the Signal
    process(clk)begin
        if rising_edge(clk)then
          if rst = '1' then
            dff_stream <= "1010101010101010101010101010101010101010101010101010101010101010";
          elsif ((i_val = '1') and ((stream_i(0) = '0') or (stream_i(0) = '1' ))) then
                dff_stream <= stream_i;
          end if;
        end if;
    end process;

	-- Generate 32 Adders to add two 32 single Bits (even Bits and odd Bits) together and then register them as 2 Bits Vectors with Flipflop  
    gen_add_1_2 : for i in 0 to 31 generate
        inst_adder_1_2:  entity work.cb_adder(rtl)
            generic map(W_i => 1,
                        W_o => 2)
            port map(
                a(0) => dff_stream(i*2),
                b(0) => dff_stream(i*2+1),
                y => mem32_i(i)
            );
       inst_dff_2 : entity work.cb_dff(rtl)
       generic map(W => 2)
        port map(
            d => mem32_i(i),
            rst => rst,
            clk => clk,
            q => mem32_o(i)
        );
    end generate;

	-- Generate 16 Adders to add two vectors of 2 Bits together and then register them as 3 Bits Vectors with Flipflop
    gen_add_2_3 : for i in 0 to 15 generate
        inst_adder_2_3 :  entity work.cb_adder(rtl)
            generic map(W_i => 2,
                        W_o => 3)
            port map(
                a => mem32_o(i*2),
                b => mem32_o(i*2 +1),
                y => mem16_i(i)
            );
        inst_dff_3 : entity work.cb_dff(rtl)
        generic map(W => 3)
        port map(
            d => mem16_i(i),
            rst => rst,
            clk => clk,
            q => mem16_o(i)
        );
    end generate;

	-- Generate 8 Adders to add two vectors of 3 Bits together and then register them as 4 Bits Vectors with Flipflop
    gen_add_3_4 : for i in 0 to 7 generate
        inst_adder_3_4 : entity work.cb_adder(rtl)
            generic map(W_i => 3,
                        W_o => 4)
            port map(
                a => mem16_o(i*2),
                b => mem16_o(i*2+1),
                y => mem8_i(i)
            );
        inst_dff_4 : entity work.cb_dff(rtl)
        generic map(W => 4)
        port map(
            d => mem8_i(i),
            rst => rst,
            clk => clk,
            q => mem8_o(i)
        );
    end generate;

	-- Generate 4 Adders to add two vectors of 4 Bits together and then register them as 5 Bits Vectors with Flipflop
    gen_add_4_5 : for i in 0 to 3 generate
        inst_adder_4_5 : entity work.cb_adder(rtl)
            generic map (W_i => 4,
                         W_o => 5)
            port map(
                a => mem8_o(i*2),
                b => mem8_o(i*2+1),
                y => mem4_i(i)
            );
        inst_dff_5 : entity work.cb_dff(rtl)
        generic map(W => 5)
        port map(
            d => mem4_i(i),
            rst => rst,
            clk => clk,
            q => mem4_o(i)
        );
    end generate;

	-- Generate 2 Adders to add two vectors of 5 Bits together and then register them as 6 Bits Vectors with Flipflop
    gen_add_5_6 : for i in 0 to 1 generate
        inst_adder_5_6 : entity work.cb_adder(rtl)
            generic map(W_i => 5,
                        W_o => 6)
            port map(
                a => mem4_o(i*2),
                b => mem4_o(i*2+1),
                y => mem2_i(i)
            );
        inst_dff_6 : entity work.cb_dff(rtl)
        generic map(W => 6)
        port map(
            d => mem2_i(i),
            rst => rst,
            clk => clk,
            q => mem2_o(i)
        );
    end generate;

	-- Generate 1 Adders to add two vectors of 6 Bits together and then register them as 7 Bits Vectors with Flipflop
    inst_adder_6_7 : entity work.cb_adder(rtl)
        generic map(W_i => 6,
                    W_o => 7)
        port map(
            a => mem2_o(0),
            b => mem2_o(1),
            y => mem1_i
        );
    inst_dff_7 : entity work.cb_dff(rtl)
        generic map(W => 7)
        port map(
            d => mem1_i,
            rst => rst,
            clk => clk,
            q => mem1_o
        );
-------------------------------------------
	 --Extend the 7 Bits Vector to 14 Bits Vector
     process(mem1_o)begin
       P <= "0000000" & mem1_o(6 downto 0) ;
    end process;

	--Calculate the Finish Signal with help of delay Signal 
     process(clk)
        begin
            if rising_edge(clk)then
                if rst = '1'then
                  delay_val <= (others => '0');
                  o_val <= '0';
                else
                  delay_val <= delay_val(7 downto 0) & i_val;
                  if(delay_val(7) = '1')then
                    o_val <= '1';
                  else
                    o_val <= '0';
                  end if;
                end if;
            end if;
     end process;

	 --Assign The results Vector to the Output  
     process(clk)
        begin
            if rising_edge(clk) then
              if rst = '1'then
                  stream_o <= (others => '0');
              elsif delay_val(7) = '1' then
                stream_o <= P;
              end if;
            end if;
     end process;

end rtl;