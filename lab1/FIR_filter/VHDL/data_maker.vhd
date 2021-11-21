library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;


entity data_maker is  
  port (CLK     : in  std_logic;						-- clock signal
    RST_n   : in  std_logic;                        -- reset signal active low, asynchronous
    VOUT    : out std_logic;                        -- validation signal
    DOUT    : out std_logic_vector(8 downto 0);    
	 COEFF		: out std_logic_vector(98 downto 0);   -- coefficent pass to the filter
    END_SIM : out std_logic);                       -- notify the end of simulation
end data_maker;

architecture beh of data_maker is

	constant tco 	: time := 0.5 ns;				
	constant N		: integer:= 9;					-- filter has a parallelism of 9 bits
	
	signal sEndSim 	: std_logic;
	signal END_SIM_i: std_logic_vector(0 to 10);  	
	signal not_valid: std_logic;
begin  

	-- assign the value to the coefficients
	COEFF( 8 downto 0)<= std_logic_vector(to_signed(-1, N));
	COEFF( 17 downto 9)<= std_logic_vector(to_signed(-4, N));
	COEFF( 26 downto 18)<= std_logic_vector(to_signed(-7, N));
	COEFF( 35 downto 27)<= std_logic_vector(to_signed(16, N));
	COEFF( 44 downto 36)<= std_logic_vector(to_signed(70, N));
	COEFF( 53 downto 45)<= std_logic_vector(to_signed(101, N));
	COEFF( 62 downto 54)<= std_logic_vector(to_signed(70, N));
	COEFF( 71 downto 63)<= std_logic_vector(to_signed(16, N));
	COEFF( 80 downto 72)<= std_logic_vector(to_signed(-7, N));
	COEFF( 89 downto 81)<= std_logic_vector(to_signed(-4, N));	
	COEFF( 98 downto 90)<= std_logic_vector(to_signed(-1, N));	

	-- this process manage the data generation and control the valid signal
	process (CLK, RST_n)
		file fp_in : text open READ_MODE is "samples.txt";  
		variable line_in : line;
		variable x : integer;
		variable cc: integer:=0;          --clock cycle

		begin  -- process
			if RST_n = '0' then                 	-- asynchronous reset (active low)
				DOUT <= (others => '0') after tco;      
				VOUT <= '0' after tco;
				sEndSim <= '0' after tco;
				not_valid <= '1' after tco;
				
			elsif CLK'event and CLK = '1' then  			-- rising clock edge
				
				cc := cc+1;						-- count the  number of clock cycle
				if (cc = 25) then	
					not_valid <= '0';			
				end if;				
				if (cc = 30) then				
					not_valid <= '1';
				end if;

				if not_valid ='1' then
				
					if not endfile(fp_in) then
						readline(fp_in, line_in);
						read(line_in, x);
						DOUT <=  conv_std_logic_vector(x, N) after tco;
						VOUT <= '1' after tco;
						sEndSim <= '0' after tco;
						
					else
						VOUT <= '0' after tco;        
						sEndSim <= '1' after tco;
						
					end if;
				else 
					VOUT <= '0' after tco;
				end if;
			end if;
		end process;
	
	
	process (CLK, RST_n) --manage the time for setting the end of simulation
		begin  -- process
			if RST_n = '0' then                 			-- asynchronous reset (active low)
				END_SIM_i <= (others => '0') after tco;
			elsif CLK'event and CLK = '1' then  					-- rising clock edge
				END_SIM_i(0) <= sEndSim after tco;
				END_SIM_i(1 to 10) <= END_SIM_i(0 to 9) after tco;
			end if;
	end process;
	END_SIM <= END_SIM_i(10);  
	
	
	
end beh;
