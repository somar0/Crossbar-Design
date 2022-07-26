library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package pkg is 

constant alpha              : integer := 64; -- Number of Neuron in Weight Matrix
constant beta_gamma         : integer := 576;-- Number of Weights in one Neuron in Weight Matrix
constant delta              : integer := 196;-- Number Column in Input Matrix
constant column_in_cb       : integer := 64; -- Number Column in Crossbar Design
constant Xnor_in_column     : integer := 64; -- Number Xnors in each column in Crossbar Design

type array_col_in_CB is array (natural range <>) of std_logic_vector(Xnor_in_column-1 downto 0);
type threshold_array is array (natural range <>) of std_logic_vector(31 downto 0);
type ram_pop is array (column_in_cb-1 downto 0)  of std_logic_vector(13 downto 0);

end pkg;   
