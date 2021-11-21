library ieee;
use ieee.std_logic_1164.all;

package FIR_adv_package is

	type mult_in is array (10 downto 0) of std_logic_vector(8 downto 0);			
	type wire_net is array (10 downto 0) of std_logic_vector (9 downto 0);
	type wire_adder is array (13 downto 0) of std_logic_vector(9 downto 0);	

	type wire_delay is array (4 downto 0) of std_logic_vector(8 downto 0);			--collection of data delayed 
	type wire_valid_delay is array (4 downto 0) of std_logic;						--collection of all the validation signal delayed
	
end package FIR_adv_package ;
