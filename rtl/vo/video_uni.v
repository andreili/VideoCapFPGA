module video_uni
(
	input		wire			i_clk,
	input		wire[11:0]	i_x_full_size,
	input		wire[11:0]	i_y_full_size,
	input		wire[11:0]	i_x_win_size,
	input		wire[11:0]	i_y_win_size,
	input		wire[11:0]	i_x,
	input		wire[11:0]	i_y,
	input		wire			i_line_end,
	input		wire[11:0]	i_vdata,
	output	wire[8:0]	o_line_idx,
	output	wire[8:0]	o_column,
	output	wire[7:0]	o_r,
	output	wire[7:0]	o_g,
	output	wire[7:0]	o_b
);

	localparam[11:0]	SCREEN_RES_X_NORM = 12'd384;
	localparam[11:0]	SCREEN_RES_X_WIDE = 12'd512;
	localparam[11:0]	SCREEN_RES_Y		= 12'd256;

	wire[11:0]	w_x_size = i_x_win_size;
	wire[11:0]	w_y_size = i_y_win_size;

	wire		w_x_is_double = ({ w_x_size, 1'b0 } <= { 1'b0, i_x_full_size }) ? 1'b1 : 1'b0;
	wire		w_y_is_double = ({ w_y_size, 1'b0 } <= { 1'b0, i_y_full_size }) ? 1'b1 : 1'b0;

	wire[11:0]	w_x = w_x_is_double ? { 1'b0, i_x[11:1] } : i_x;
	wire[11:0]	w_y = w_y_is_double ? { 1'b0, i_y[11:1] } : i_y;
	wire[11:0]	w_x_active = w_x_is_double ? { 1'b0, i_x_full_size[11:1] } : i_x_full_size;
	wire[11:0]	w_y_active = w_y_is_double ? { 1'b0, i_y_full_size[11:1] } : i_y_full_size;

	wire[11:0]	w_x_border2 = w_x_active - w_x_size;
	wire[11:0]	w_x_border = { 1'b0, w_x_border2[11:1] };
	wire[11:0]	w_y_border2 = w_y_active - w_y_size;
	wire[11:0]	w_y_border = { 1'b0, w_y_border2[11:1] };

	wire[11:0]	w_x_actual = w_x - w_x_border;
	wire[11:0]	w_y_actual = w_y - w_y_border;

	reg[11:0]	r_y;
	reg[11:0]	r_x;
	//reg[11:0]	r_x_pre;
	//reg			r_x_is_active, r_y_is_active;
	
	wire			w_x_is_active = (r_x < w_x_size);
	wire			w_y_is_active = (r_y < w_y_size);
	wire			w_is_active = w_x_is_active & w_y_is_active;
	reg			r_is_active;

	always @(posedge i_clk)
	begin
		r_x <= w_x_actual;
		//r_x_pre <= w_x_actual + 3'd7;
		//r_x_is_active <= w_x_is_active;
		//r_y_is_active <= w_y_is_active;
		if (i_line_end == 1'b1)
		begin
			r_y <= w_y_actual;
		end
		r_is_active <= w_is_active;
	end

	assign o_line_idx = r_y[8:0];
	assign o_column = r_x[8:0];

	assign o_r = r_is_active ? { {2{i_vdata[11]}},  {2{i_vdata[10]}},  {2{i_vdata[9]}},  {2{i_vdata[8]}} } : 8'b0;
	assign o_g = r_is_active ? { {2{i_vdata[7]}},   {2{i_vdata[6]}},   {2{i_vdata[5]}},  {2{i_vdata[4]}} } : 8'b0;
	assign o_b = r_is_active ? { {2{i_vdata[3]}},   {2{i_vdata[2]}},   {2{i_vdata[1]}},  {2{i_vdata[0]}} } : 8'b0;

endmodule
