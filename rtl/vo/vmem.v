module vmem
(
	input		wire			i_clk_mem,
	input		wire			i_clk_vo,
	input		wire			i_vdata_valid,
	input		wire			i_vdata_reset,
	input		wire[11:0]	i_vdata,
	input		wire[8:0]	i_column,
	output	wire[11:0]	o_vdata
);

	reg[8:0]		r_wr_cnt;

	always @(posedge i_clk_mem)
	begin
		if (i_vdata_reset == 1'b1)
			r_wr_cnt <= 7'b0;
		else if (i_vdata_valid == 1'b1)
			r_wr_cnt <= r_wr_cnt + 1'b1;
	end

	altsyncram
	u_vram
	(
		.address_a			(r_wr_cnt),
		.address_b			(i_column),
		.clock0				(i_clk_mem),
		.clock1				(i_clk_vo),
		.data_a				(i_vdata),
		.wren_a				(i_vdata_valid),
		.q_b					(o_vdata),
		.aclr0				(1'b0),
		.aclr1				(1'b0),
		.addressstall_a	(1'b0),
		.addressstall_b	(1'b0),
		.byteena_a			(1'b1),
		.byteena_b			(1'b1),
		.clocken0			(1'b1),
		.clocken1			(1'b1),
		.clocken2			(1'b1),
		.clocken3			(1'b1),
		.data_b				({12{1'b1}}),
		.eccstatus			(),
		.q_a					(),
		.rden_a				(1'b1),
		.rden_b				(1'b1),
		.wren_b				(1'b0));
	defparam
		u_vram.address_aclr_b = "NONE",
		u_vram.address_reg_b = "CLOCK1",
		u_vram.clock_enable_input_a = "BYPASS",
		u_vram.clock_enable_input_b = "BYPASS",
		u_vram.clock_enable_output_b = "BYPASS",
		u_vram.intended_device_family = "Cyclone IV E",
		u_vram.lpm_type = "altsyncram",
		u_vram.numwords_a = 512,
		u_vram.numwords_b = 512,
		u_vram.operation_mode = "DUAL_PORT",
		u_vram.outdata_aclr_b = "NONE",
		u_vram.outdata_reg_b = "CLOCK1",
		u_vram.power_up_uninitialized = "FALSE",
		u_vram.widthad_a = 9,
		u_vram.widthad_b = 9,
		u_vram.width_a = 12,
		u_vram.width_b = 12,
		u_vram.width_byteena_a = 1;

endmodule
