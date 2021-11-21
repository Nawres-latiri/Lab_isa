library ieee; 
use ieee.std_logic_1164.all; 
use IEEE.std_logic_signed.all;
use ieee.numeric_std.all;

entity MULT is 
	Generic (N: integer := 9 );
	Port (A:	IN	std_logic_vector(N-1 downto 0);
			B:	IN	std_logic_vector(N-1 downto 0);
			M:	OUT	std_logic_vector(N downto 0));							
end MULT; 

architecture behavior of MULT is

signal p	:	std_logic_vector(2*N-1 downto 0);

begin

	p 	<= 	A*B; --product result
	M 	<= 	p(2*N-1 downto N-1);	-- N+1 bit

end behavior;
