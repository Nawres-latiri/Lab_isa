library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity ADDER is 
	generic (N: integer := 9 );							
	port (A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			S:	out std_logic_vector(N-1 downto 0));							
end ADDER; 

architecture behavior of ADDER is

	begin
	
		S <= A + B;
		
end behavior;