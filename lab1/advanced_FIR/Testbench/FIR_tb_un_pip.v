//`timescale 1 ns

module FIR_tb_un_pip ();

	wire [8:0] din_3a;
	wire [8:0] din_3b;
	wire [8:0] din_3c;
	wire vin;
	wire rst_n;
	wire clk;
	wire [98:0] COEFF;
	wire [8:0] dout_3a;
	wire [8:0] dout_3b;
	wire [8:0] dout_3c;
	wire vout;
	wire endsim;
	
	FIR_unfolded DUT(
		.DIN_3A(din_3a),
		.DIN_3B(din_3b),
		.DIN_3C(din_3c),
		.VIN(vin),
		.RST_n(rst_n),
		.CLK(clk),
		.COEFF(COEFF),
		.DOUT_3A(dout_3a),
		.DOUT_3B(dout_3b),
		.DOUT_3C(dout_3c),
		.VOUT(vout)
		);

	data_maker data_maker_inst(
		.CLK(clk),
		.RST_n(rst_n),
		.VOUT(vin),
		.DOUT_A(din_3a),
		.DOUT_B(din_3b),
		.DOUT_C(din_3c),
		.COEFF(COEFF),
		.END_SIM(endsim)
	);
	
	data_sink data_sink_inst(
		.CLK(clk),
		.RST_n(rst_n),
		.VIN(vout),
		.DIN_A(dout_3a),
		.DIN_B(dout_3b),
		.DIN_C(dout_3c)
	);
	
	clk_gen clk_gen_inst(
		.END_SIM(endsim),
		.CLK(clk),
		.RST_n(rst_n)
	);

endmodule
