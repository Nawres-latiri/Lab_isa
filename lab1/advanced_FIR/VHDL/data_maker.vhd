library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

entity data_maker is  
  port (CLK: in std_logic;	
		  RST_n: in std_logic;
		  VOUT: out std_logic;
		  DOUT_A: out std_logic_vector(8 downto 0);
		  DOUT_B: out std_logic_vector(8 downto 0);
		  DOUT_C: out std_logic_vector(8 downto 0);
		  COEFF: out std_logic_vector(98 downto 0);
		  END_SIM: out std_logic);
end data_maker;

architecture beh of data_maker is

	constant t: time := 0.5 ns;				
	constant N: integer := 9;
	
	signal sEndSim: std_logic;
	signal END_SIM_i: std_logic_vector(0 to 10);  	
	signal not_valid: std_logic;
	
begin  

						  -- coefficients --
	COEFF( 8 downto 0) <= std_logic_vector(to_signed(-1, N));
	COEFF( 17 downto 9) <= std_logic_vector(to_signed(-4, N));
	COEFF( 26 downto 18) <= std_logic_vector(to_signed(-7, N));
	COEFF( 35 downto 27) <= std_logic_vector(to_signed(16, N));
	COEFF( 44 downto 36) <= std_logic_vector(to_signed(70, N));
	COEFF( 53 downto 45) <= std_logic_vector(to_signed(101, N));
	COEFF( 62 downto 54) <= std_logic_vector(to_signed(70, N));
	COEFF( 71 downto 63) <= std_logic_vector(to_signed(16, N));
	COEFF( 80 downto 72) <= std_logic_vector(to_signed(-7, N));
	COEFF( 89 downto 81) <= std_logic_vector(to_signed(-4, N));	
	COEFF( 98 downto 90) <= std_logic_vector(to_signed(-1, N));	

	process (CLK, RST_n)
	
		file file_in : text open READ_MODE is "samples.txt";
		variable line_in : line;
		variable x,y,z : integer;
		variable cnt: integer:= 0;

		begin
		
			if RST_n = '0' then   
				DOUT_A <= (others => '0') after t;
				DOUT_B <= (others => '0') after t;
				DOUT_C <= (others => '0') after t;				
				VOUT <= '0' after t;
				sEndSim <= '0' after t;
				not_valid <= '1' after t;
				
			elsif CLK'event and CLK = '1' then
				
				cnt := cnt + 1;
				
				if (cnt = 50) then	--(25)
					not_valid <= '0';
					
				end if;				
				
				if (cnt = 60) then
					not_valid <= '1';
					
				end if;

				if not_valid ='1' then
				
					if not endfile(file_in) then
						readline(file_in, line_in);
						read(line_in, x);
						DOUT_A <=  conv_std_logic_vector(x, N) after t;
						VOUT <= '1' after t;
						sEndSim <= '0' after t;
						
					else
						VOUT <= '0' after t;        
						sEndSim <= '1' after t;
						
					end if;
					
					if not endfile(file_in) then
						readline(file_in, line_in);
						read(line_in, y);
						DOUT_B <=  conv_std_logic_vector(y, N) after t;
						VOUT <= '1' after t;
						sEndSim <= '0' after t;
						
					else
						VOUT <= '0' after t;        
						sEndSim <= '1' after t;
						
					end if;
					
					if not endfile(file_in) then
						readline(file_in, line_in);
						read(line_in, z);
						DOUT_C <=  conv_std_logic_vector(z, N) after t;
						VOUT <= '1' after t;
						sEndSim <= '0' after t;
						
					else
						VOUT <= '0' after t;        
						sEndSim <= '1' after t;
						
					end if;
					
				else 
					VOUT <= '0' after t;
					
				end if;
			end if;
		end process;
	
	process (CLK, RST_n)
	
		begin
		
			if RST_n = '0' then 
				END_SIM_i <= (others => '0') after t;
				
			elsif CLK'event and CLK = '1' then 
				END_SIM_i(0) <= sEndSim after t;
				END_SIM_i(1 to 10) <= END_SIM_i(0 to 9) after t;
				
			end if;
	end process;
	
	END_SIM <= END_SIM_i(10);  
	
	
	
end beh;
