module stream_cap
#(
	parameter							SCR_SIZE_BIT
)
(
	input		wire						i_pxl_clk,
	input		wire						i_reset_n,
	// internal bus
	input		wire						i_clk_bus,
	input		wire[4:0]				i_addr,
	input		wire[7:0]				i_data_wr,
	input		wire						i_select,
	input		wire						i_wr_req,
	output	wire[7:0]				o_data_wr,
	//
	input		wire[3:0]				i_R,
	input		wire[3:0]				i_G,
	input		wire[3:0]				i_B,
	input		wire						i_I,
	input		wire						i_HS,
	input		wire						i_VS,
	//
	output	wire[11:0]				o_fifo_data,
	output	wire						o_active,
	output	wire						o_active_negedge,
	output	wire[8:0]				o_line,
	//
	output	wire[SCR_SIZE_BIT:0]	o_x_size,
	output	wire[SCR_SIZE_BIT:0]	o_y_size
);

	wire[11:0]	w_x_start, w_x_size, w_y_start, w_y_size;
	wire			w_HS_inv, w_VS_inv;
	wire[2:0]	w_mux_mode;

	vcap_regs u_regs
	(
		.i_clk			(i_clk_bus),
		.i_reset_n		(i_reset_n),
		.i_addr			(i_addr[4:0]),
		.i_data_wr		(i_data_wr),
		.i_select		(i_select),
		.i_wr_req		(i_wr_req),
		.o_data_wr		(o_data_wr),
		//
		.o_x_start		(w_x_start),
		.o_x_size		(w_x_size),
		.o_y_start		(w_y_start),
		.o_y_size		(w_y_size),
		.o_HS_inv		(w_HS_inv),
		.o_VS_inv		(w_VS_inv),
		.o_mux_mode		(w_mux_mode)
	);

	wire		[3:0]		w_R, w_G, w_B;

	assign w_R = (w_mux_mode == 3'd0) ? i_R :
					(w_mux_mode == 3'd1) ? { i_R[0], i_R[0] & i_I, i_R[0], i_R[0] } :
					(w_mux_mode == 3'd2) ? 4'b0 :
					i_R;
	assign w_G = (w_mux_mode == 3'd0) ? i_G :
					(w_mux_mode == 3'd1) ? { i_G[0], i_G[0] & i_I, i_G[0], i_G[0] } :
					(w_mux_mode == 3'd2) ? 4'b0 :
					i_G;
	assign w_B = (w_mux_mode == 3'd0) ? i_B :
					(w_mux_mode == 3'd1) ? { i_B[0], i_B[0] & i_I, i_B[0], i_B[0] } :
					(w_mux_mode == 3'd2) ? 4'b0 :
					i_B;

	reg[3:0]	r_R, r_G, r_B;
	reg		r_HS, r_VS, r_HS_prev, r_VS_prev;

	always @(posedge i_pxl_clk)
	begin
		r_R  <= w_R;
		r_G  <= w_G;
		r_B  <= w_B;
		r_HS <= i_HS ^ w_HS_inv;
		r_VS <= i_VS ^ w_VS_inv;
		r_HS_prev <= r_HS;
		r_VS_prev <= r_VS;
	end

	wire		w_HS_negedge = (!r_HS) & r_HS_prev;
	wire		w_VS_negedge = (!r_VS) & r_VS_prev;

	reg[(SCR_SIZE_BIT-1):0]	r_x_cnt;
	reg[(SCR_SIZE_BIT-1):0]	r_y_cnt;

	always @(posedge i_pxl_clk)
	begin
		if (w_HS_negedge)
			r_x_cnt <= { SCR_SIZE_BIT{1'b0} };
		else
			r_x_cnt <= r_x_cnt + 1'b1;
	end

	always @(posedge i_pxl_clk)
	begin
		if (w_VS_negedge)
			r_y_cnt <= { SCR_SIZE_BIT{1'b0} };
		else if (w_HS_negedge == 1'b1)
			r_y_cnt <= r_y_cnt + 1'b1;
	end

	wire	w_x_active = (r_x_cnt >= w_x_start) && (r_x_cnt <= (w_x_start + w_x_size));
	wire	w_y_active = (r_y_cnt >= w_y_start) && (r_y_cnt <= (w_y_start + w_y_size));
	wire	w_active = w_x_active & w_y_active;
	

	reg 	r_active;
	reg	r_active_prev;
	wire	w_active_negedge = (!r_active) && r_active_prev;
	
	reg[11:0] r_data_pipe0, r_data_pipe1, r_data_pipe2;

	always @(posedge i_pxl_clk)
	begin
		r_active <= w_active;
		r_active_prev <= r_active;
		r_data_pipe0 <= { r_R, r_G, r_B };
		r_data_pipe1 <= r_data_pipe0;
		r_data_pipe2 <= r_data_pipe1;
	end

	wire	r_active_negedge;
	always @(posedge i_pxl_clk)
	begin
		r_active_negedge <= w_active_negedge;
	end

	wire[(SCR_SIZE_BIT-1):0]	w_y_act = (r_y_cnt - w_y_start);
	reg[(SCR_SIZE_BIT-1):0]		r_y_act;

	always @(posedge i_pxl_clk)
	begin
		r_y_act <= w_y_act;
	end

	assign o_x_size = w_x_size;
	assign o_y_size = w_y_size;
	
	assign o_fifo_data = r_data_pipe2;
	assign o_active = r_active;
	assign o_active_negedge = r_active_negedge;
	assign o_line = r_y_act[8:0];

endmodule
