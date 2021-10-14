`timescale 1 ps / 1 ps

module pll_cfg
(
	input		wire			i_clk,
	input		wire			i_reset_n,
	input		wire[4:0]	i_addr,
	input		wire[7:0]	i_data_wr,
	input		wire			i_select,
	input		wire			i_wr_req,
	output	wire[7:0]	o_data_wr,
	input		wire			i_clk_raw,
	output	wire			o_clk,
	output	wire			o_clk2
);

	wire[157:0]	w_config;
	wire			w_start_update;

	pll_regs u_regs
	(
		.i_clk				(i_clk),
		.i_reset_n			(i_reset_n),
		.i_addr				(i_addr),
		.i_data_wr			(i_data_wr),
		.i_select			(i_select),
		.i_wr_req			(i_wr_req),
		.o_data_wr			(o_data_wr),
		.o_config			(w_config),
		.o_start_update	(w_start_update)
	);
	reg[157:0] r_enable_tmp =
	{
		 1'b0,	// end
		12'b111111111111,
		 7'b1111111,
		18'b111111111111111111,
		18'b111111111111111111, 3'b000,
		18'b111111111111111111, 2'b00,
		18'b111111111111111111, 2'b00,
		18'b111111111111111111, 2'b00,
		18'b111111111111111111, 2'b00,
		18'b111111111111111111,
		 1'b0		// start
	};
	
	reg[157:0]	r_data;
	reg[157:0]	r_enable;
	reg			r_busy;
	reg[7:0]		r_cnt;
	reg			r_pll_reset, r_update;
	
	always @(posedge i_clk)
	begin
		if (i_reset_n == 1'b0)
		begin
			r_busy <= 1'b0;
			r_pll_reset <= 1'b0;
			r_update <= 1'b0;
			r_data <= 0;
			r_enable <= 0;
		end
			else if ((r_busy == 1'b0) && (w_start_update == 1'b1))
		begin
			r_busy <= 1'b1;
			r_data <= w_config;
			r_enable <= r_enable_tmp;
			r_cnt <= 8'b0;
		end
			else if (r_cnt < 8'd157)
		begin
			r_data <= { 1'b0, r_data[157:1] };
			r_enable <= { 1'b0, r_enable[157:1] };
			r_cnt <= r_cnt + 1'b1;
		end
			else if (r_cnt < 8'd162)
		begin
			r_cnt <= r_cnt + 1'b1;
			if (r_cnt == 8'd157)
			begin
				r_update <= 1'b1;
			end
				else if (r_cnt == 8'd159)
			begin
				r_update <= 1'b0;
			end
				else if (r_cnt == 8'd160)
			begin
				r_pll_reset <= 1'b1;
			end
				else if (r_cnt == 8'd161)
			begin
				r_pll_reset <= 1'b0;
				r_busy <= 1'b0;
			end
		end
	end
	
	pll_vo u_pll_vo
	(
		.areset			(r_pll_reset),
		.configupdate	(r_update),
		.inclk0			(i_clk_raw),
		.scanclk			(i_clk),
		.scanclkena		(r_enable[0]),
		.scandata		(r_data[0]),
		.c0				(o_clk),
		.c1				(o_clk2),
		.locked			(),
		.scandataout	(),
		.scandone		()
	);

endmodule
