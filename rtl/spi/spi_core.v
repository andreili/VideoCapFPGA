`timescale 1 ps / 1 ps

module spi_core
(
	input		wire			i_clk,
	input		wire			i_reset_n,
	// SPI bus
	input		wire			i_spi_cs_n,
	input		wire			i_spi_sck,
	input		wire			i_spi_si,
	output	wire			o_spi_so,
	//
	input		wire[7:0]	i_wr_data,
	output	wire[7:0]	o_rd_data,
	output	wire			o_last_bit
);

	reg r_spi_cs_n, r_spi_sck, r_spi_si;
	
	always @(posedge i_clk)
	begin
		r_spi_cs_n <= i_spi_cs_n;
		r_spi_sck <= i_spi_sck;
		r_spi_si <= i_spi_si;
	end

	reg r_spi_sck_prev;

	always @(posedge i_clk)
		r_spi_sck_prev <= r_spi_sck;

	wire w_sck_rise =   r_spi_sck  & (!r_spi_sck_prev);
	wire w_sck_fall = (!r_spi_sck) &   r_spi_sck_prev;

	reg[2:0]	r_bit_cnt;
	reg[7:0] r_dr_in, r_dr_out;
	wire w_reset = (i_reset_n == 1'b0) || (r_spi_cs_n == 1'b1);
	wire w_last_bit = (r_bit_cnt == 3'b111) & w_sck_fall;

	always @(posedge i_clk)
	begin
		if (w_reset)
		begin
			r_bit_cnt <= 3'b000;
		end
			else if (w_sck_rise == 1'b1)
		begin
			//r_dr_in <= { r_spi_si, r_dr_in[7:1] };
			r_dr_in <= { r_dr_in[6:0], r_spi_si };
		end
			else if (w_sck_fall == 1'b1)
		begin
			r_bit_cnt <= r_bit_cnt + 1'b1;
			if (w_last_bit)
			begin
				r_dr_out <= i_wr_data;
			end
				else
			begin
				//r_dr_out <= { 1'b0, r_dr_out[7:1] };
				r_dr_out <= { r_dr_out[6:0], 1'b0 };
			end
		end
	end
	
	//assign o_spi_so = r_dr_out[0];
	assign o_spi_so = r_dr_out[7];
	assign o_rd_data = r_dr_in;
	assign o_last_bit = w_last_bit;

endmodule
