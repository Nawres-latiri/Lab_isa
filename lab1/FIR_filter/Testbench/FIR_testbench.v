//`timescale 1 ns

module FIR_tb ();

	wire [8:0] din;
	wire vin;
	wire rst_n;
	wire clk;
	wire [98:0] COEFF;
	wire [8:0] dout;
	wire vout;
	wire endsim;
	
	FIR_filter DUT(
		.DIN(din),
		.VIN(vin),
		.RST_n(rst_n),
		.CLK(clk),
		.COEFF(COEFF),
		.DOUT(dout),
		.VOUT(vout)
		);

	data_maker data_maker_inst(
		.CLK(clk),
		.RST_n(rst_n),
		.VOUT(vin),
		.DOUT(din),
		.COEFF(COEFF),
		.END_SIM(endsim)
	);
	
	data_sink data_sink_inst(
		.CLK(clk),
		.RST_n(rst_n),
		.VIN(vout),
		.DIN(dout)
	);
	
	clk_gen clk_gen_inst(
		.END_SIM(endsim),
		.CLK(clk),
		.RST_n(rst_n)
	);

endmodule
   
