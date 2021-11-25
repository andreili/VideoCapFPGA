module vcap_regs
(
	input		wire			i_clk,
	input		wire			i_reset_n,
	input		wire[4:0]	i_addr,
	input		wire[7:0]	i_data_wr,
	input		wire			i_select,
	input		wire			i_wr_req,
	output	wire[7:0]	o_data_wr,
	//
	output	wire[11:0]	o_x_start,
	output	wire[11:0]	o_x_size,
	output	wire[11:0]	o_y_start,
	output	wire[11:0]	o_y_size,
	output	wire			o_HS_inv,
	output	wire			o_VS_inv,
	output	wire[2:0]	o_mux_mode
);

	reg[11:0]	r_x_start;
	reg[11:0]	r_x_size;
	reg[11:0]	r_y_start;
	reg[11:0]	r_y_size;
	reg			r_HS_inv, r_VS_inv;
	reg[2:0]		r_mux_mode;

	always @(posedge i_clk)
	begin
		if (i_reset_n == 1'b0)
		begin
			r_x_start <= 0;
			r_y_start <= 0;
			r_x_size <= 12'd256;
			r_y_size <= 12'd256;
			r_HS_inv <= 1'b0;
			r_VS_inv <= 1'b0;
			r_mux_mode <= 3'b0;
		end
			else if ((i_select == 1'b1) && (i_wr_req == 1'b1))
		begin
			case (i_addr)
				5'h00:
					begin
						r_x_start[7:0] <= i_data_wr;
					end
				5'h01:
					begin
						r_x_start[11:8] <= i_data_wr[3:0];
						r_x_size[3:0] <= i_data_wr[7:4];
					end
				5'h02:
					begin
						r_x_size[11:4] <= i_data_wr;
					end
				5'h03:
					begin
						r_y_start[7:0] <= i_data_wr;
					end
				5'h04:
					begin
						r_y_start[11:8] <= i_data_wr[3:0];
						r_y_size[3:0] <= i_data_wr[7:4];
					end
				5'h05:
					begin
						r_y_size[11:4] <= i_data_wr;
					end
				5'h06:
					begin
						r_HS_inv <= i_data_wr[0];
						r_VS_inv <= i_data_wr[1];
						r_mux_mode <= i_data_wr[4:2];
					end
			endcase
		end
	end
	
	assign o_data_wr =
		(i_addr == 5'h00) ? r_x_start[7:0] :
		(i_addr == 5'h01) ? { r_x_size[3:0], r_x_start[11:8] } :
		(i_addr == 5'h02) ? r_x_size[11:4] :
		(i_addr == 5'h03) ? r_y_start[7:0] :
		(i_addr == 5'h04) ? { r_y_size[3:0], r_y_start[11:8] } :
		(i_addr == 5'h05) ? r_y_size[11:4] :
		8'h00;

	assign o_x_start = r_x_start;
	assign o_x_size = r_x_size;
	assign o_y_start = r_y_start;
	assign o_y_size = r_y_size;
	assign o_HS_inv = r_HS_inv;
	assign o_VS_inv = r_VS_inv;
	assign o_mux_mode = r_mux_mode;

endmodule
