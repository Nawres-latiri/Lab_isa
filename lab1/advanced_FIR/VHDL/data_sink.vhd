library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity data_sink is
  port (CLK: in std_logic;
		  RST_n: in std_logic;
		  VIN: in std_logic;
		  DIN_A: in std_logic_vector(8 downto 0);
		  DIN_B: in std_logic_vector(8 downto 0);
		  DIN_C: in std_logic_vector(8 downto 0));
end data_sink;

architecture behavior of data_sink is

begin

	process (CLK, RST_n)
	
		file results_file : text open WRITE_MODE is "results.txt";
		variable line_out : line;    
		
	begin  
	
		if RST_n = '0' then                 			
			null;
			
		elsif CLK'event and CLK = '1' then
			
			if (VIN = '1') then
				write(line_out, conv_integer(signed(DIN_A)));
				writeline(results_file, line_out);
				write(line_out, conv_integer(signed(DIN_B)));
				writeline(results_file, line_out);
				write(line_out, conv_integer(signed(DIN_C)));
				writeline(results_file, line_out);
				
			end if;
		end if;
	end process;

end behavior;
