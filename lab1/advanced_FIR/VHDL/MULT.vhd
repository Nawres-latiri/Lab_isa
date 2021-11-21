library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity MULT is 
	generic (N: integer := 9 );
	port (A:	in	std_logic_vector(N-1 downto 0);
			B:	in	std_logic_vector(N-1 downto 0);
			M: out std_logic_vector(N downto 0));							
end MULT; 

architecture behavior of MULT is

signal mul:	std_logic_vector(2*N-1 downto 0);

begin

	mul <= A*B;
	M <= mul(2*N-1 downto N-1);	-- select N+1 bit (MSB)

end behavior;