library ieee;
use ieee.std_logic_1164.all;

entity FIR_filter is
	port(CLK : in std_logic;									-- clock signal
		RST_n	: in std_logic;									-- reset signal active low
		DIN : in std_logic_vector(8 downto 0);				-- input data
		VIN : in std_logic;										-- validation signal
		COEFF : in std_logic_vector(98 downto 0);			-- coefficent of the filter
		DOUT	: out std_logic_vector(8 downto 0);			-- output data
		VOUT	: out std_logic);									-- validation signal, 1 when valid data, 0 otherwise
	
end entity FIR_filter;

architecture behavior of FIR_filter is

	component REG is
		Generic (N: positive:= 1 );											
		Port(	CLK		: In	std_logic;
                RST_n	: In	std_logic;    --active low
                D		: In	std_logic_vector(N-1 downto 0);				--	data input
				Q		: Out	std_logic_vector(N-1 downto 0);				--	data output
				EN		: In 	std_logic);			--active high						
													
	end component REG;		
			
	component MULT is 		
		generic (N:  integer := 9);											
		Port (A:	IN	std_logic_vector(N-1 downto 0); 					--	data input 1
				B:	IN	std_logic_vector(N-1 downto 0);						--	data input 2
				M:	OUT	std_logic_vector(N downto 0)						--	multiplication's result
			);									
	end component MULT; 		
			
	component ADDER is 		
		generic (N:  integer := 9);											
		Port (A:	In	std_logic_vector(N-1 downto 0); 					--	data input 1
				B:	In	std_logic_vector(N-1 downto 0);						--	data input 2
				S:	Out	std_logic_vector(N-1 downto 0)						--	sum's result
			);							
	end component ADDER; 

	component MUX_4to1 is
	Generic (N: integer:= 1);												--number of bits
	Port (DATA0, DATA1, DATA2, DATA3	: In	std_logic_vector(N-1 downto 0);		--data inputs
			SEL					: In	std_logic_vector(1 downto 0);		--selection input
			Y					: Out	std_logic_vector(N-1 downto 0));	--data output
	end component MUX_4to1;
	
	
	type wire_reg is array (10 downto 0) of std_logic_vector(8 downto 0);			--connection between registers
	type wire_mult_add is array (10 downto 0) of std_logic_vector(9 downto 0);		

	signal connection_reg 	: wire_reg;								
	signal mult_to_add		: wire_mult_add;						
	signal add_to_add		: wire_mult_add;						
	signal enable_reg		: std_logic;							
	signal sel_signal		: std_logic_vector(1 downto 0); 		--control the SEL signal of the mux
	signal out_mux			: std_logic_vector(8 downto 0);		
	
	
	
	
	begin
		
		mult0	: MULT
		GENERIC MAP ( N => 9 )
		PORT MAP(A => connection_reg(0), B => COEFF(8 downto 0), M => mult_to_add(0)) ;
		
		
		reg_din	: REG
		GENERIC MAP ( N => 9 )
		PORT MAP(D => DIN, Q => connection_reg(0), EN => '1' , CLK => CLK, RST_n => RST_n ) ;
		
		reg_vin	: REG
		GENERIC MAP ( N => 1 )
		PORT MAP(D(0) => VIN, Q(0) => enable_reg, EN =>'1' , CLK => CLK, RST_n => RST_n ) ;
		
		
		add_to_add(0) <= mult_to_add(0);
		
		--the structure of the filter: the register chain, 10 adders, and the 10 multipliers
		network_generation: for x in 1 to 10 generate
			reg_chain	: REG
			GENERIC MAP ( N => 9 )
			PORT MAP(D => connection_reg(x-1), Q => connection_reg(x), EN => enable_reg , CLK => CLK, RST_n => RST_n ) ;
			
			queue_mult	: MULT
			GENERIC MAP ( N => 9 )
			PORT MAP(A => connection_reg(x), B => COEFF(8+(9*x) downto 9*x), M => mult_to_add(x)) ;
			
			queue_add	: ADDER
			GENERIC MAP ( N => 10 )
			PORT MAP(A => add_to_add(x-1), B => mult_to_add(x), S => add_to_add(x) ) ;
		
		end generate network_generation;

		--control of the mux 
		sel_signal <= ( add_to_add(10)(9) & add_to_add(10)(8));

		
		saturation_stage: MUX_4to1 --test if the value is higher than max or lower than min
			Generic map(N => 9)
			Port map (DATA0=> add_to_add(10)(8 downto 0), DATA1=>"011111111",
						DATA2=> "100000000", DATA3=> add_to_add(10)(8 downto 0), 
						SEL => sel_signal ,Y => out_mux	);
		
		
		reg_dout	: REG
		GENERIC MAP ( N => 9 )
		PORT MAP(D => out_mux, Q => DOUT, EN => enable_reg , CLK => CLK, RST_n => RST_n ) ;
		
		reg_vout	: REG
		GENERIC MAP ( N => 1 )
		PORT MAP(D(0) =>enable_reg, Q(0) => VOUT, EN => '1' , CLK => CLK, RST_n => RST_n ) ;
end architecture behavior;
