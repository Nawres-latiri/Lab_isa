library ieee;
use ieee.std_logic_1164.all;

entity MUX_4to1 is
	Generic (N: integer:= 1);
	Port (DATA0, DATA1, DATA2, DATA3: in std_logic_vector(N-1 downto 0);
			SEL: in std_logic_vector(1 downto 0);	
			Y: out std_logic_vector(N-1 downto 0));
end entity MUX_4to1;

architecture behavior of MUX_4to1 is

begin

	with SEL select Y<=
	
		DATA0 when "00",
		DATA1 when "01",
		DATA2 when "10",
		DATA3 when others; --just case "11"
	
end architecture behavior;