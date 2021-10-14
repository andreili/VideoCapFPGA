module vctrl_regs
(
	input		wire			i_clk,
	input		wire			i_reset_n,
	input		wire[4:0]	i_addr,
	input		wire[7:0]	i_data_wr,
	input		wire			i_select,
	input		wire			i_wr_req,
	output	wire[7:0]	o_data_wr,
	//
	output	wire[11:0]	o_h_active,
	output	wire[11:0]	o_h_sync_start,
	output	wire[11:0]	o_h_sync_end,
	output	wire[11:0]	o_h_blank,
	output	wire			o_h_sync_pol,
	output	wire[11:0]	o_v_active,
	output	wire[11:0]	o_v_sync_start,
	output	wire[11:0]	o_v_sync_end,
	output	wire[11:0]	o_v_blank,
	output	wire			o_v_sync_pol,
	output	wire			o_video_active,
	output	wire			o_hdmi_active,
	output	wire			o_vga_active
);

	reg[11:0]	r_h_active;
	reg[11:0]	r_h_sync_start;
	reg[11:0]	r_h_sync_end;
	reg[11:0]	r_h_blank;
	reg[11:0]	r_v_active;
	reg[11:0]	r_v_sync_start;
	reg[11:0]	r_v_sync_end;
	reg[11:0]	r_v_blank;
	reg			r_video_active;
	reg			r_hdmi_active;
	reg			r_vga_active;
	reg			r_v_sync_pos;
	reg			r_h_sync_pos;

	always @(posedge i_clk)
	begin
		if (i_reset_n == 1'b0)
		begin
			r_h_active <= 0;
			r_h_sync_start <= 0;
		end
			else if ((i_select == 1'b1) && (i_wr_req == 1'b1))
		begin
			case (i_addr)
				5'h00:
					begin
						r_h_active[7:0] <= i_data_wr;
					end
				5'h01:
					begin
						r_h_active[11:8] <= i_data_wr[3:0];
						r_h_sync_start[3:0] <= i_data_wr[7:4];
					end
				5'h02:
					begin
						r_h_sync_start[11:4] <= i_data_wr;
					end
				5'h03:
					begin
						r_h_sync_end[7:0] <= i_data_wr;
					end
				5'h04:
					begin
						r_h_sync_end[11:8] <= i_data_wr[3:0];
						r_h_blank[3:0] <= i_data_wr[7:4];
					end
				5'h05:
					begin
						r_h_blank[11:4] <= i_data_wr;
					end
				5'h06:
					begin
						r_v_active[7:0] <= i_data_wr;
					end
				5'h07:
					begin
						r_v_active[11:8] <= i_data_wr[3:0];
						r_v_sync_start[3:0] <= i_data_wr[7:4];
					end
				5'h08:
					begin
						r_v_sync_start[11:4] <= i_data_wr;
					end
				5'h09:
					begin
						r_v_sync_end[7:0] <= i_data_wr;
					end
				5'h0a:
					begin
						r_v_sync_end[11:8] <= i_data_wr[3:0];
						r_v_blank[3:0] <= i_data_wr[7:4];
					end
				5'h0b:
					begin
						r_v_blank[11:4] <= i_data_wr;
					end
				5'h0c:
					begin
						r_video_active <= i_data_wr[0];
						r_hdmi_active <= i_data_wr[1];
						r_vga_active <= i_data_wr[2];
						r_v_sync_pos <= i_data_wr[3];
						r_h_sync_pos <= i_data_wr[4];
					end
			endcase
		end
	end
	
	assign o_data_wr =
		(i_addr == 5'h00) ? r_h_active[7:0] :
		(i_addr == 5'h01) ? { r_h_sync_start[3:0], r_h_active[11:8] } :
		(i_addr == 5'h02) ? r_h_sync_start[11:4] :
		(i_addr == 5'h03) ? r_h_sync_end[7:0] :
		(i_addr == 5'h04) ? { r_h_blank[3:0], r_h_sync_end[11:8] } :
		(i_addr == 5'h05) ? r_h_blank[11:4] :
		(i_addr == 5'h06) ? r_v_active[7:0] :
		(i_addr == 5'h07) ? { r_v_sync_start[3:0], r_v_active[11:8] } :
		(i_addr == 5'h08) ? r_v_sync_start[11:4] :
		(i_addr == 5'h09) ? r_v_sync_end[7:0] :
		(i_addr == 5'h0a) ? { r_v_blank[3:0], r_v_sync_end[11:8] } :
		(i_addr == 5'h0b) ? r_v_blank[11:4] :
		(i_addr == 5'h0c) ? { 3'b000, r_h_sync_pos, r_v_sync_pos, r_vga_active, r_hdmi_active, r_video_active } :
		(i_addr == 5'h10) ? { 1'b0, i_reset_n, 6'h1a } :
		8'h00;

	assign o_h_active = r_h_active;
	assign o_h_sync_start = r_h_sync_start;
	assign o_h_sync_end = r_h_sync_end;
	assign o_h_blank = r_h_blank;
	assign o_v_active = r_v_active;
	assign o_v_sync_start = r_v_sync_start;
	assign o_v_sync_end = r_v_sync_end;
	assign o_v_blank = r_v_blank;
	assign o_video_active = r_video_active;
	assign o_hdmi_active = r_hdmi_active;
	assign o_vga_active = r_vga_active;
	assign o_v_sync_pol = r_v_sync_pos;
	assign o_h_sync_pol = r_h_sync_pos;

endmodule
