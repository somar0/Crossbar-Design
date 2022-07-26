library ieee;
use ieee.std_logic_1164.all;


entity cb_xnor is
    port(
        data    : in std_logic; --First Bit
        weight  : in std_logic; --Second Bit
        output1 : out std_logic --Result
    );
    end cb_xnor;

    architecture rtl of cb_xnor is
	--Create a Signal of one Bit
    signal xnor_o : std_logic;

    begin
        --Calculate logic XNOR between the two Inputs and save the result in a Signal 
        xnor_o  <= data xnor weight;
		--Assign the Value of the Signal to the Output Result
        output1 <= xnor_o;

    end rtl;