module pll_regs
(
	input		wire			i_clk,
	input		wire			i_reset_n,
	input		wire[4:0]	i_addr,
	input		wire[7:0]	i_data_wr,
	input		wire			i_select,
	input		wire			i_wr_req,
	output	wire[7:0]	o_data_wr,
	output	wire[157:0]	o_config,
	output	wire			o_start_update
);

	reg[1:0]		r_lfc;
	reg[4:0]		r_lfr;
	reg			r_vco;
	reg[1:0]		r_cp;
	reg			r_n_odd, r_n_bp;
	reg			r_m_odd, r_m_bp;
	reg			r_c0_odd, r_c0_bp;
	reg			r_c1_odd, r_c1_bp;
	reg			r_c2_odd, r_c2_bp;
	reg			r_c3_odd, r_c3_bp;
	reg			r_c4_odd, r_c4_bp;
	reg[7:0]		r_n_high, r_n_low;
	reg[7:0]		r_m_high, r_m_low;
	reg[7:0]		r_c0_high, r_c0_low;
	reg[7:0]		r_c1_high, r_c1_low;
	reg[7:0]		r_c2_high, r_c2_low;
	reg[7:0]		r_c3_high, r_c3_low;
	reg[7:0]		r_c4_high, r_c4_low;
	reg			r_config_update;

	always @(posedge i_clk)
	begin
		if (i_reset_n == 1'b0)
		begin
			r_lfc <= 2'b00;
			r_lfr <= 5'b11011;
			r_vco <= 1'b0;
			r_cp <= 2'b01;
			r_n_odd <= 1'b0;
			r_n_bp  <= 1'b1;
			r_m_odd <= 1'b0;
			r_m_bp  <= 1'b0;
			r_c0_odd <= 1'b1;
			r_c0_bp  <= 1'b0;
			r_c1_odd <= 1'b0;
			r_c1_bp  <= 1'b0;
			r_c2_odd <= 1'b0;
			r_c2_bp  <= 1'b1;
			r_c3_odd <= 1'b0;
			r_c3_bp  <= 1'b1;
			r_c4_odd <= 1'b0;
			r_c4_bp  <= 1'b1;
			r_n_high  <= 8'h00;
			r_n_low   <= 8'h00;
			r_m_high  <= 8'h07;
			r_m_low   <= 8'h07;
			r_c0_high <= 8'h04;
			r_c0_low  <= 8'h03;
			r_c1_high <= 8'h01;
			r_c1_low  <= 8'h01;
			r_c2_high <= 8'h00;
			r_c2_low  <= 8'h00;
			r_c3_high <= 8'h00;
			r_c3_low  <= 8'h00;
			r_c4_high <= 8'h00;
			r_c4_low  <= 8'h00;
		end
			else if ((i_select == 1'b1) && (i_wr_req == 1'b1))
		begin
			case (i_addr)
				5'h00:
					begin
						r_lfc <= i_data_wr[1:0];
						r_lfr <= i_data_wr[6:2];
						r_vco <= i_data_wr[7];
					end
				5'h01:
					begin
						r_cp <= i_data_wr[1:0];
						r_n_odd <= i_data_wr[2];
						r_n_bp <= i_data_wr[3];
						r_m_odd <= i_data_wr[4];
						r_m_bp <= i_data_wr[5];
						r_c0_odd <= i_data_wr[6];
						r_c0_bp <= i_data_wr[7];
					end
				5'h02:
					begin
						r_c1_odd <= i_data_wr[0];
						r_c1_bp  <= i_data_wr[1];
						r_c2_odd <= i_data_wr[2];
						r_c2_bp  <= i_data_wr[3];
						r_c3_odd <= i_data_wr[4];
						r_c3_bp  <= i_data_wr[5];
						r_c4_odd <= i_data_wr[6];
						r_c4_bp  <= i_data_wr[7];
					end
				5'h03: r_n_high <= i_data_wr;
				5'h04: r_n_low <= i_data_wr;
				5'h05: r_m_high <= i_data_wr;
				5'h06: r_m_low <= i_data_wr;
				5'h07: r_c0_high <= i_data_wr;
				5'h08: r_c0_low <= i_data_wr;
				5'h09: r_c1_high <= i_data_wr;
				5'h0a: r_c1_low <= i_data_wr;
				5'h0b: r_c2_high <= i_data_wr;
				5'h0c: r_c2_low <= i_data_wr;
				5'h0d: r_c3_high <= i_data_wr;
				5'h0e: r_c3_low <= i_data_wr;
				5'h0f: r_c4_high <= i_data_wr;
				5'h10: r_c4_low <= i_data_wr;
			endcase
		end
	end

	always @(posedge i_clk)
	begin
		r_config_update <= (i_select & i_wr_req & (i_addr == 5'h11));
	end
	
	assign o_data_wr =
		(i_addr == 5'h00) ? { r_vco, r_lfr, r_lfc } :
		(i_addr == 5'h01) ? { r_c0_bp, r_c0_odd, r_m_bp, r_m_odd, r_n_bp, r_n_odd, r_cp } :
		(i_addr == 5'h02) ? { r_c4_bp, r_c4_odd, r_c3_bp, r_c3_odd, r_c2_bp, r_c2_odd, r_c1_bp, r_c1_odd } :
		(i_addr == 5'h03) ? r_n_high :
		(i_addr == 5'h04) ? r_n_low :
		(i_addr == 5'h05) ? r_m_high :
		(i_addr == 5'h06) ? r_m_low :
		(i_addr == 5'h07) ? r_c0_high :
		(i_addr == 5'h08) ? r_c0_low :
		(i_addr == 5'h09) ? r_c1_high :
		(i_addr == 5'h0a) ? r_c1_low :
		(i_addr == 5'h0b) ? r_c2_high :
		(i_addr == 5'h0c) ? r_c2_low :
		(i_addr == 5'h0d) ? r_c3_high :
		(i_addr == 5'h0e) ? r_c3_low :
		(i_addr == 5'h0f) ? r_c4_high :
		(i_addr == 5'h10) ? r_c4_low :
		8'h00;
	
	assign o_start_update = r_config_update;
	assign o_config = {
		1'b0,			// padding
		2'b00,		// reserved
		r_lfc,
		r_lfr,
		r_vco,
		5'b00000,	// reserved
		1'b0, r_cp,
		r_n_bp, r_n_high, r_n_odd, r_n_low,
		r_m_bp, r_m_high, r_m_odd, r_m_low,
		3'b000,		// padding
		r_c0_bp, r_c0_high, r_c0_odd, r_c0_low,
		2'b00,		// padding
		r_c1_bp, r_c1_high, r_c1_odd, r_c1_low,
		2'b00,		// padding
		r_c2_bp, r_c2_high, r_c2_odd, r_c2_low,
		2'b00,		// padding
		r_c3_bp, r_c3_high, r_c3_odd, r_c3_low,
		2'b00,		// padding
		r_c4_bp, r_c4_high, r_c4_odd, r_c4_low,
		1'b0,			// padding
		1'b0			// start
	};

endmodule
