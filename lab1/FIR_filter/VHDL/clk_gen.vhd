library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- used to generate the clock and reset signal 
entity clk_gen is
  port (
    END_SIM : in  std_logic;
    CLK     : out std_logic;
    RST_n   : out std_logic);
end clk_gen;

architecture behavior of clk_gen is

	constant Ts : time := 14 ns; --after the synthesis Tmin=3.31ns
	
	signal CLK_s : std_logic;
  
begin 

	process
	begin  -- process
		if (CLK_s = 'U') then
			CLK_s <= '0';
		else
			CLK_s <= not(CLK_s);
		end if;
		wait for Ts/2;
	end process;
	
	CLK <= CLK_s and not(END_SIM);
	
	process
	begin  -- process
		RST_n <= '0';
		wait for 3*Ts;
		RST_n <= '1';
		wait;
	end process;

end behavior;
