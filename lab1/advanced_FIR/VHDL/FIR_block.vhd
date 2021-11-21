library ieee;
use ieee.std_logic_1164.all;
use work.fir_adv_package.all;


entity FIR_block is
	port(
        CLK			: in std_logic;                     	-- clock signal
        RST_n		: in std_logic; 
		DATA_IN		: in mult_in;							-- inputs vectors 
		enable_line1: in std_logic;                     	-- enable signal for pipeline stage 1
		enable_line2: in std_logic;                     	-- enable signal for pipeline stage 2
		enable_line3: in std_logic;                     	-- enable signal for pipeline stage 3
		enable_line4: in std_logic;                     	-- enable signal for pipeline stage 
		COEFF			: in std_logic_vector(98 downto 0);	-- coefficent
		DATA_OUT	: out std_logic_vector(8 downto 0) 	-- output data
	);
end entity FIR_block;

architecture behavior of FIR_block is

	component REG is
		Generic (N: positive:= 1 );									
		Port(CLK		: In	std_logic;							
				RST_n	: In	std_logic;		
                D		: In	std_logic_vector(N-1 downto 0);		--	data input
				Q		: Out	std_logic_vector(N-1 downto 0);		--	data output
				EN		: In 	std_logic);							--	enable active high					
	end component REG;
	
	component MULT is 
		generic (N:  integer := 9);									--	number of bits
		Port (	A:	IN	std_logic_vector(N-1 downto 0); 			--	data input 1
				B:	IN	std_logic_vector(N-1 downto 0);				--	data input 2
				M:	OUT	std_logic_vector(N downto 0)				--	multiplication's result
			);							
	end component MULT; 
	
	component ADDER is 
		generic (N:  integer := 9);									--	number of bits
		Port (	A:	In	std_logic_vector(N-1 downto 0); 			--	data input 1
				B:	In	std_logic_vector(N-1 downto 0);				--	data input 2
				S:	Out	std_logic_vector(N-1 downto 0)				--	sum's result
			);							
	end component ADDER; 
	
	component MUX_4to1 is
	Generic (N: integer:= 1);	--number of bits
	Port (	DATA0, DATA1, DATA2, DATA3	: In	std_logic_vector(N-1 downto 0);		
			SEL					: In	std_logic_vector(1 downto 0);		
			Y					: Out	std_logic_vector(N-1 downto 0));	
	end component MUX_4to1;
	
	signal mult_to_reg		: wire_net;								
	signal reg_to_adder		: wire_net;                            
	signal reg_to_reg_1		: wire_net;                             
	signal reg_to_reg_2		: wire_net;                       
	signal reg_to_reg_3		: std_logic_vector(9 downto 0);        
	signal add_to_adder		: wire_adder;                         
	signal sel_signal 		: std_logic_vector(1 downto 0);	
	
	BEGIN
		
		network_generation: for x in 0 to 10 generate			
			instance_mult	: MULT
			GENERIC MAP ( N => 9 )
			PORT MAP(A => DATA_IN(x), B => COEFF(8+(9*x) downto 9*x), M => mult_to_reg(x)) ;
		end generate network_generation;

		

		pipe_generation_1a: for x in 0 to 3 generate
			reg_pipe03	: REG
			GENERIC MAP ( N => 10 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D => mult_to_reg(x), Q => reg_to_adder(x), EN => enable_line1) ;
		end generate pipe_generation_1a;

		pipe_generation_1b: for x in 4 to 10 generate
			reg_pipe410	: REG
			GENERIC MAP ( N => 10 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D => mult_to_reg(x), Q => reg_to_reg_1(x), EN => enable_line1) ;
		end generate pipe_generation_1b;
		
		pipe_generation_2a: for x in 4 to 6 generate
			reg_pipe46	: REG
			GENERIC MAP ( N => 10 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D => reg_to_reg_1(x), Q => reg_to_adder(x), EN => enable_line2) ;
		end generate pipe_generation_2a;

		pipe_generation_2b: for x in 7 to 10 generate
			reg_pipe710	: REG
			GENERIC MAP ( N => 10 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D => reg_to_reg_1(x), Q => reg_to_reg_2(x), EN => enable_line2 ) ;
		end generate pipe_generation_2b;

		pipe_generation_3a: for x in 7 to 9 generate
			reg_pipe79	: REG
			GENERIC MAP ( N => 10 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D => reg_to_reg_2(x), Q => reg_to_adder(x), EN => enable_line3) ;
		end generate pipe_generation_3a;

		reg_pipe10_1	: REG
			GENERIC MAP ( N => 10 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D => reg_to_reg_2(10), Q => reg_to_reg_3, EN => enable_line3) ;

		reg_pipe10_2	: REG
			GENERIC MAP ( N => 10 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D => reg_to_reg_3, Q => reg_to_adder(10), EN => enable_line4) ;

		
		add_to_adder(0) <= reg_to_adder(0);
		
		
		first_chain_adder: for x in 1 to 3 generate
			add_one_to_three	: ADDER
			GENERIC MAP ( N => 10)
			PORT MAP(A => add_to_adder(x-1), B => reg_to_adder(x), S => add_to_adder(x) ) ;
		end generate first_chain_adder;
		
		
		reg_between_1	: REG
			GENERIC MAP ( N => 10 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D => add_to_adder(3), Q => add_to_adder(4), EN => enable_line2) ;
		
		
		second_chain_adder: for x in 4 to 6 generate
			add_four_to_six	: ADDER
			GENERIC MAP ( N => 10 )
			PORT MAP(A => add_to_adder(x), B => reg_to_adder(x), S => add_to_adder(x+1) ) ;
		end generate second_chain_adder;
		
		
		reg_between_2	: REG
			GENERIC MAP ( N => 10 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D => add_to_adder(7), Q => add_to_adder(8), EN => enable_line3) ;
		
		
		third_chain_adder: for x in 7 to 9 generate
			add_seven_to_nine	: ADDER
			GENERIC MAP ( N => 10 )
			PORT MAP(A => add_to_adder(x+1), B => reg_to_adder(x), S => add_to_adder(x+2) ) ;
		end generate third_chain_adder;
		
		
		reg_between_3	: REG
			GENERIC MAP ( N => 10 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D => add_to_adder(11), Q => add_to_adder(12), EN => enable_line4) ;			
		
		
		add_ten	: ADDER
			GENERIC MAP ( N => 10 )
			PORT MAP(A => add_to_adder(12), B => reg_to_adder(10), S => add_to_adder(13) ) ;
		
		 
		sel_signal <= (add_to_adder(13)(9) & add_to_adder(13)(8));
		 
		
		saturation_stage: MUX_4to1 
			Generic map(N => 9)
			Port map (DATA0=> add_to_adder(13)(8 downto 0), DATA1=>"011111111",
						DATA2=> "100000000", DATA3=> add_to_adder(13)(8 downto 0), 
						SEL => sel_signal ,Y =>DATA_OUT	);

end architecture behavior;
