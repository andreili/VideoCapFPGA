module CDC_path
(
	input		wire		i_signal,
	input		wire		i_clk1,
	input		wire		i_clk2,
	output	wire		o_signal_reg_clk1,
	output	wire		o_signal
);

	reg r_tmp0, r_tmp1, r_tmp2, r_tmp3;

	always @(posedge i_clk1)
	begin
		r_tmp0 <= i_signal;
	end

	always @(posedge i_clk2)
	begin
		r_tmp1 <= r_tmp0;
		r_tmp2 <= r_tmp1;
	end

	always @(posedge i_clk1)
	begin
		r_tmp3 <= r_tmp2;
	end

	assign o_signal_reg_clk1 = r_tmp0;
	assign o_signal = r_tmp3;

endmodule
