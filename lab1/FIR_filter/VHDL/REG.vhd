library IEEE;
use IEEE.std_logic_1164.all; 

entity REG is
	Generic (N: integer := 9 );									
	Port(CLK : In	std_logic; --clock
            RST_n	: In	std_logic;
            D : In	std_logic_vector(N-1 downto 0);		--	data input
			Q : Out	std_logic_vector(N-1 downto 0);		--	data output
			EN	: In 	std_logic);					   --	in the structure-->control VIN
	
end entity REG;

architecture behavior of REG is	

begin
	REGIS: process(CLK)			
	
	begin
		if CLK'event and CLK = '1' then 
		
			if RST_n='0' then		
				Q<=(others=>'0');
				
			elsif EN='1' then	
				Q <= D; 
				
			end if;
	    end if;
	end process;
	
end behavior;
