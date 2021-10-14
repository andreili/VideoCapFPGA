`timescale 1 ps / 1 ps

module spi_master
(
	input		wire			i_clk,
	input		wire			i_reset_n,
	// SPI bus
	input		wire			i_spi_cs_n,
	input		wire			i_spi_sck,
	input		wire			i_spi_si,
	output	wire			o_spi_so,
	//
	output	wire[6:0]	o_addr,
	output	wire[7:0]	o_data_wr,
	input		wire[7:0]	i_data_rd,
	output	wire			o_wr_req
);

	wire			w_last_bit;
	wire[7:0]	w_data_from_spi;
	
	spi_core u_core
	(
		.i_clk			(i_clk),
		.i_reset_n		(i_reset_n),
		.i_spi_cs_n		(i_spi_cs_n),
		.i_spi_sck		(i_spi_sck),
		.i_spi_si		(i_spi_si),
		.o_spi_so		(o_spi_so),
		.i_wr_data		(i_data_rd),
		.o_rd_data		(w_data_from_spi),
		.o_last_bit		(w_last_bit)
	);

	reg[1:0]	r_state;
	reg[7:0]	r_addr_raw;
	reg[7:0]	r_size;
	
	wire[7:0]w_data_size = (w_data_from_spi - 1'b1);
	wire		w_is_write = r_addr_raw[7];
	
	localparam STATE_WAIT_ADDR = 0;
	localparam STATE_WAIT_SIZE = 1;
	localparam STATE_FETCH_DATA = 2;

	wire	w_write_req = (w_is_write & w_last_bit & (r_state == STATE_FETCH_DATA));
	
	always @(negedge i_reset_n or posedge i_clk)
	begin
		if (i_reset_n == 1'b0)
		begin
			r_state <= STATE_WAIT_ADDR;
			r_addr_raw <= 8'h00;
		end
			else if (i_spi_cs_n == 1'b1)
		begin
			r_state <= STATE_WAIT_ADDR;
			r_addr_raw <= 8'h00;
		end
			else if (w_last_bit == 1'b1)
		begin
			case (r_state)
			STATE_WAIT_ADDR:
				begin
					r_addr_raw <= w_data_from_spi;
					r_state <= STATE_WAIT_SIZE;
				end
			STATE_WAIT_SIZE:
				begin
					r_size <= w_data_size;
					r_state <= STATE_FETCH_DATA;
					if (!w_is_write)
					begin
						r_addr_raw[6:0] <= r_addr_raw[6:0] + 1'b1;
					end
				end
			STATE_FETCH_DATA:
				begin
					if (r_size == 8'h00)
					begin
						r_state <= STATE_WAIT_ADDR;
					end
					if ((w_write_req == 1'b1) || (!w_is_write))
					begin
						r_size <= r_size - 1'b1;
						r_addr_raw[6:0] <= r_addr_raw[6:0] + 1'b1;
					end
				end
			endcase
		end
	end

	assign o_addr = r_addr_raw[6:0];
	assign o_data_wr = w_data_from_spi;
	assign o_wr_req = w_write_req;

endmodule
