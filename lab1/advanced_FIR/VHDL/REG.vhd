library ieee;
use ieee.std_logic_1164.all; 

entity REG is
	generic (N: integer := 9 );									
	port (CLK: in	std_logic;
			RST_n: in	std_logic;	
			D: in std_logic_vector(N-1 downto 0);
			Q: out std_logic_vector(N-1 downto 0);
			EN: in std_logic);				
end entity REG;

architecture behavior of REG is	

begin

	REGIS: process(CLK)
	
	begin
	
		if CLK'event and CLK = '1' then 
		
			if RST_n='0' then		
				Q <= (others=>'0');
				
			elsif EN = '1' then	
				Q <= D; 
				
			end if;
	    end if;
		 
	end process;
	
end behavior;
