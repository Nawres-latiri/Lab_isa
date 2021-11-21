library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

-- Element used to perform addition between two signal 
entity ADDER is 
	Generic (N: integer := 9 );							
	Port (A:	In	std_logic_vector(N-1 downto 0);
			B:	In	std_logic_vector(N-1 downto 0);
			S:	Out	std_logic_vector(N-1 downto 0));							
end ADDER; 

architecture behavior of ADDER is

	begin
		S <= A + B;
		
end behavior;