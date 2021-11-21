library ieee;
use ieee.std_logic_1164.all;
use work.fir_adv_package.all;


entity FIR_unfolded is
	port(
		DIN_3A	: in std_logic_vector(8 downto 0);		-- input data A (3k)
		DIN_3B	: in std_logic_vector(8 downto 0);     -- input data B (3k+1)
		DIN_3C	: in std_logic_vector(8 downto 0);     -- input data C (3k+2)
		VIN		: in std_logic;                         -- validation signal for input
		RST_n	: in std_logic;                         
		CLK		: in std_logic;                         -- clock signal
		COEFF		: in std_logic_vector(98 downto 0);     
		DOUT_3A	: out std_logic_vector(8 downto 0);    -- output data A (3k)
		DOUT_3B	: out std_logic_vector(8 downto 0);    -- output data B (3k+1)
		DOUT_3C	: out std_logic_vector(8 downto 0);    -- output data C (3k+2)
		VOUT	: out std_logic                         -- validation signal for output
	);
end entity FIR_unfolded;

architecture behavior of FIR_unfolded is

	component REG is
		Generic (N: positive:= 9 );									
		Port(CLK		: In	std_logic;						
				RST_n	: In	std_logic;	
               	D		: In	std_logic_vector(N-1 downto 0);		--	data input
				Q		: Out	std_logic_vector(N-1 downto 0);		--	data output
				EN		: In 	std_logic);							
									

	end component REG;

	component FIR_block is
	port(
        CLK			: in std_logic;                     -- clock signal
        RST_n		: in std_logic;                     -- reset signal
		DATA_IN		: in mult_in;						-- inputs vectors 
		enable_line1: in std_logic;                     -- enable signal for pipeline stage 1
		enable_line2: in std_logic;                     -- enable signal for pipeline stage 2
		enable_line3: in std_logic;                     -- enable signal for pipeline stage 3
		enable_line4: in std_logic;                     -- enable signal for pipeline stage 4		
		COEFF			: in std_logic_vector(98 downto 0);                    
		DATA_OUT	: out std_logic_vector(8 downto 0) -- output data
	);
	end component FIR_block;	
	
	
	signal line_1		: mult_in;							
	signal line_2		: mult_in;                      	 
	signal line_3		: mult_in;
	
	
	signal delay_A		: wire_delay;                   	    
	signal delay_B		: wire_delay;                   	    
	signal delay_C		: wire_delay; 
	
	
	signal delay_valid	: wire_valid_delay; 
	
	
	signal outA,outB,outC:std_logic_vector(8 downto 0);                  	    
	
	BEGIN

		-- input registers
		reg_in_A	: REG
		GENERIC MAP ( N => 9 )
		PORT MAP(CLK => CLK, RST_n => RST_n, D => DIN_3A, Q =>delay_A(0) , EN => '1') ;

		reg_in_B	: REG
		GENERIC MAP ( N => 9 )
		PORT MAP(CLK => CLK, RST_n => RST_n, D => DIN_3B, Q =>delay_B(0) , EN => '1') ;
		
		reg_in_C	: REG
		GENERIC MAP ( N => 9 )
		PORT MAP(CLK => CLK, RST_n => RST_n, D => DIN_3C, Q =>delay_C(0) , EN => '1') ;
		
		reg_in_VIN	: REG
		GENERIC MAP ( N => 1 )
		PORT MAP(CLK => CLK, RST_n => RST_n, D(0) => VIN, Q(0) =>delay_valid(0) , EN => '1') ;
		
		
		sequence_reg_vin: for x in 0 to 3 generate			
			reg_d_vin	: REG
			GENERIC MAP ( N => 1 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D(0) => delay_valid(x), Q(0) => delay_valid(x+1), EN => '1') ;
		end generate sequence_reg_vin;
		
		
		sequence_reg_A: for x in 0 to 2 generate			
			reg_d_A	: REG
			GENERIC MAP ( N => 9 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D => delay_A(x), Q => delay_A(x+1), EN => delay_valid(0)) ;
		end generate sequence_reg_A;
		
		
		sequence_reg_B: for x in 0 to 2 generate			
			reg_d_B	: REG
			GENERIC MAP ( N => 9 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D => delay_B(x), Q => delay_B(x+1), EN => delay_valid(0)) ;
		end generate sequence_reg_B;

		
		sequence_reg_C: for x in 0 to 3 generate			
			reg_d_C	: REG
			GENERIC MAP ( N => 9 )
			PORT MAP(CLK => CLK, RST_n => RST_n, D => delay_C(x), Q => delay_C(x+1), EN => delay_valid(0)) ;
		end generate sequence_reg_C;
		
					
			line_1(0)	<= delay_A(0);
			line_1(1)	<= delay_C(1);
			line_1(2)	<= delay_B(1);
			line_1(3)	<= delay_A(1);
			line_1(4)	<= delay_C(2);
			line_1(5)	<= delay_B(2);
			line_1(6)	<= delay_A(2);
			line_1(7)	<= delay_C(3);
			line_1(8)	<= delay_B(3);
			line_1(9)	<= delay_A(3);
			line_1(10) 	<= delay_C(4);
			
			
			line_2(0)	<= delay_B(0);
			line_2(1)	<= delay_A(0);
			line_2(2)	<= delay_C(1);
			line_2(3)	<= delay_B(1);
			line_2(4)	<= delay_A(1);
			line_2(5)	<= delay_C(2);
			line_2(6)	<= delay_B(2);
			line_2(7)	<= delay_A(2);
			line_2(8)	<= delay_C(3);
			line_2(9)	<= delay_B(3);
			line_2(10) 	<= delay_A(3);
		
			line_3(0)	<= delay_C(0);
			line_3(1)	<= delay_B(0);
			line_3(2)	<= delay_A(0);
			line_3(3)	<= delay_C(1);
			line_3(4)	<= delay_B(1);
			line_3(5)	<= delay_A(1);
			line_3(6)	<= delay_C(2);
			line_3(7)	<= delay_B(2);
			line_3(8)	<= delay_A(2);
			line_3(9)	<= delay_C(3);
			line_3(10) 	<= delay_B(3);		
			
		-- generate the three block for the advance filter		
		BLOCK_A_FIR:FIR_block
		PORT MAP(CLK => CLK, RST_n => RST_n, DATA_IN =>	line_1, COEFF =>COEFF ,DATA_OUT => outA,
				enable_line1 =>delay_valid(0), enable_line2 => delay_valid(1), 
				enable_line3 => delay_valid(2), enable_line4 => delay_valid(3));
																										  
		BLOCK_B_FIR:FIR_block                                                                             
		PORT MAP(CLK => CLK, RST_n => RST_n, DATA_IN =>	line_2, COEFF =>COEFF ,DATA_OUT => outB,
				enable_line1 => delay_valid(0), enable_line2 => delay_valid(1), 
				enable_line3 => delay_valid(2), enable_line4 => delay_valid(3));
				
		BLOCK_C_FIR:FIR_block                                                                             
		PORT MAP(CLK => CLK, RST_n => RST_n, DATA_IN => line_3 , COEFF =>COEFF ,DATA_OUT => outC,
				enable_line1 => delay_valid(0), enable_line2 => delay_valid(1), 
				enable_line3 => delay_valid(2), enable_line4 => delay_valid(3));
		
		
		reg_out_A	: REG
		GENERIC MAP ( N => 9 )
		PORT MAP( CLK => CLK, RST_n => RST_n, D => outA, Q =>DOUT_3A , EN => '1') ;

		reg_out_B	: REG
		GENERIC MAP ( N => 9 )
		PORT MAP( CLK => CLK, RST_n => RST_n, D => outB, Q =>DOUT_3B , EN => '1') ;
		
		reg_out_C	: REG
		GENERIC MAP ( N => 9 )
		PORT MAP( CLK => CLK, RST_n => RST_n, D => outC, Q =>DOUT_3C , EN => '1') ;
		
		reg_out_VOUT	: REG
		GENERIC MAP ( N => 1 )
		PORT MAP( CLK => CLK, RST_n => RST_n, D(0) => delay_valid(4), Q(0) =>VOUT , EN => '1') ;
		
		
		
		
end architecture behavior;
