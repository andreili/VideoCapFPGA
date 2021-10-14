module sync_gen
(
	input		wire			i_clk,
	input		wire			i_clk_en,
	// parameters
	input		wire[11:0]	i_active,
	input		wire[11:0]	i_sync_start,
	input		wire[11:0]	i_sync_end,
	input		wire[11:0]	i_blank,
	input		wire			i_sync_pol,
	//
	output	wire[11:0]	o_val,
	output	wire			o_sync,
	output	wire			o_line_end,
	output	wire			o_is_active
);

	reg[11:0]	r_cnt;
	reg			r_line_end;
	reg			r_is_active;

	always @(posedge i_clk)
	begin
		if (i_clk_en == 1'b1)
		begin
			if (r_cnt == i_blank)
			begin
				r_cnt <= 0;
			end
				else
			begin
				r_cnt <= r_cnt + 1'b1;
			end
		end
	end

	always @(posedge i_clk)
	begin
		if (i_clk_en == 1'b1)
		begin
			if (r_cnt == i_sync_start)
				o_sync <= i_sync_pol;
			else if (r_cnt == i_sync_end)
				o_sync <= ~i_sync_pol;
		end
	end

	always @(posedge i_clk)
	begin
		if (i_clk_en == 1'b1)
		begin
			if (r_cnt == 0)
				r_is_active <= 1'b1;
			else if (r_cnt == i_active)
			begin
				r_line_end <= 1'b1;
				r_is_active <= 1'b0;
			end
			else
				r_line_end <= 1'b0;
		end
	end
	
	assign o_line_end = r_line_end;
	assign o_is_active = r_is_active;
	assign o_val = r_cnt;

endmodule
