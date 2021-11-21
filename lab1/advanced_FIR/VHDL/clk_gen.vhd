library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity clk_gen is
  port (CLK: out std_logic;
		  RST_n: out std_logic;
          END_SIM: in  std_logic);
		
end clk_gen;

architecture behavior of clk_gen is

	constant Ts : time := 14 ns;
	signal CLK_s : std_logic;
  
begin 

	process
	
	begin 
	
		if (CLK_s = 'U') then
			CLK_s <= '0';
			
		else
			CLK_s <= not(CLK_s);
			
		end if;
		
		wait for Ts/2;
		
	end process;
	
	CLK <= CLK_s and not(END_SIM);
	
	process
	
	begin
	
		RST_n <= '0';
		wait for 3*Ts;
		RST_n <= '1';
		wait;
		
	end process;

end behavior;
