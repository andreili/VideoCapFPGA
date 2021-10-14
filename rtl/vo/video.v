module video
(
	input		wire			i_clk,
	input		wire			i_clk_mem,
	input		wire			i_reset_n,
	// internal bus
	input		wire			i_clk_bus,
	input		wire[4:0]	i_addr,
	input		wire[7:0]	i_data_wr,
	input		wire			i_select,
	input		wire			i_wr_req,
	output	wire[7:0]	o_data_wr,
	//
	output	wire[8:0]	o_line_idx,
	output	wire			o_line_end,
	output	wire			o_frame_end,
	input		wire			i_vdata_valid,
	input		wire			i_vdata_reset,
	input		wire[11:0]	i_vdata,
	// from v-cap
	input		wire[11:0]	i_x_win_size,
	input		wire[11:0]	i_y_win_size,
	// video output
	output	wire[7:0]	o_r,
	output	wire[7:0]	o_g,
	output	wire[7:0]	o_b,
	output	wire			o_hs,
	output	wire			o_vs,
	output	wire			o_de
);

	wire[8:0]	w_column;
	wire[11:0]	w_vdata;

	vmem u_vmem
	(
		.i_clk_mem		(i_clk_mem),
		.i_clk_vo		(i_clk),
		.i_vdata_valid	(i_vdata_valid),
		.i_vdata_reset	(i_vdata_reset),
		.i_vdata			(i_vdata),
		.i_column		(w_column),
		.o_vdata			(w_vdata)
	);

	wire[11:0]	w_h_active;
	wire[11:0]	w_h_sync_start;
	wire[11:0]	w_h_sync_end;
	wire[11:0]	w_h_blank;
	wire[11:0]	w_v_active;
	wire[11:0]	w_v_sync_start;
	wire[11:0]	w_v_sync_end;
	wire[11:0]	w_v_blank;
	wire			w_video_active;
	wire			w_hdmi_active;
	wire			w_vga_active;
	wire			w_v_sync_pos;
	wire			w_h_sync_pos;
	wire[11:0]	w_x_win_size;
	wire[11:0]	w_y_win_size;

	vctrl_regs u_vregs
	(
		.i_clk			(i_clk_bus),
		.i_reset_n		(i_reset_n),
		.i_addr			(i_addr[4:0]),
		.i_data_wr		(i_data_wr),
		.i_select		(i_select),
		.i_wr_req		(i_wr_req),
		.o_data_wr		(o_data_wr),
		.o_h_active		(w_h_active),
		.o_h_sync_start(w_h_sync_start),
		.o_h_sync_end	(w_h_sync_end),
		.o_h_blank		(w_h_blank),
		.o_h_sync_pol	(w_h_sync_pos),
		.o_v_active		(w_v_active),
		.o_v_sync_start(w_v_sync_start),
		.o_v_sync_end	(w_v_sync_end),
		.o_v_blank		(w_v_blank),
		.o_v_sync_pol	(w_v_sync_pos),
		.o_video_active(w_video_active),
		.o_hdmi_active	(),
		.o_vga_active	()
	);

	wire			w_h_line_end, w_h_is_active;
	wire[11:0]	w_x;

	sync_gen u_sync_h
	(
		.i_clk			(i_clk),
		.i_clk_en		(1'b1 & w_video_active),
		.i_active		(w_h_active),
		.i_sync_start	(w_h_sync_start),
		.i_sync_end		(w_h_sync_end),
		.i_blank			(w_h_blank),
		.i_sync_pol		(w_h_sync_pos),
		.o_val			(w_x),
		.o_sync			(o_hs),
		.o_line_end		(w_h_line_end),
		.o_is_active	(w_h_is_active)
	);

	wire			w_v_line_end, w_v_is_active;
	wire[11:0]	w_y;

	sync_gen u_sync_v
	(
		.i_clk			(i_clk),
		.i_clk_en		(w_h_line_end & w_video_active),
		.i_active		(w_v_active),
		.i_sync_start	(w_v_sync_start),
		.i_sync_end		(w_v_sync_end),
		.i_blank			(w_v_blank),
		.i_sync_pol		(w_v_sync_pos),
		.o_val			(w_y),
		.o_sync			(o_vs),
		.o_line_end		(w_v_line_end),
		.o_is_active	(w_v_is_active)
	);

	video_uni u_uni
	(
		.i_clk			(i_clk),
		.i_x_full_size	(w_h_active),
		.i_y_full_size	(w_v_active),
		.i_x_win_size	(i_x_win_size),
		.i_y_win_size	(i_y_win_size),
		.i_x				(w_x),
		.i_y				(w_y),
		.i_line_end		(w_h_line_end),
		.i_vdata			(w_vdata),
		.o_line_idx		(o_line_idx),
		.o_column		(w_column),
		.o_r				(o_r),
		.o_g				(o_g),
		.o_b				(o_b)
	);

	assign o_line_end = !w_h_is_active;
	assign o_frame_end = w_v_line_end;
	assign o_de = w_h_is_active & w_v_is_active;

endmodule
