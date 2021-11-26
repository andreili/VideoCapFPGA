module spi_sub
(
	input		wire			i_clk,
	input		wire			i_reset_n,
	// SPI bus
	input		wire			i_spi_cs_n,
	input		wire			i_spi_sck,
	input		wire			i_spi_si,
	output	wire			o_spi_so,
	// shared
	output	wire[4:0]	o_slave_addr,
	output	wire			o_wr_req,
	output	wire[7:0]	o_data_wr,
	// slaves connections
	output	wire			o_slave0_sel,
	input		wire[7:0]	o_stave0_rdata,
	output	wire			o_slave1_sel,
	input		wire[7:0]	o_stave1_rdata,
	output	wire			o_slave2_sel,
	input		wire[7:0]	o_stave2_rdata,
	output	wire			o_slave3_sel,
	input		wire[7:0]	o_stave3_rdata
);

	wire[7:0]	w_data_rd;
	wire[7:0]	w_addr;

	spi_master u_master
	(
		.i_clk			(i_clk),
		.i_reset_n		(i_reset_n),
		.i_spi_cs_n		(i_spi_cs_n),
		.i_spi_sck		(i_spi_sck),
		.i_spi_si		(i_spi_si),
		.o_spi_so		(o_spi_so),
		.o_addr			(w_addr),
		.o_data_wr		(o_data_wr),
		.i_data_rd		(w_data_rd),
		.o_wr_req		(o_wr_req)
	);

	slave_mux u_mux
	(
		.i_addr			(w_addr[6:5]),
		.o_data_wr		(w_data_rd),
		.o_sel0			(o_slave0_sel),
		.i_data_wr0		(o_stave0_rdata),
		.o_sel1			(o_slave1_sel),
		.i_data_wr1		(o_stave1_rdata),
		.o_sel2			(o_slave2_sel),
		.i_data_wr2		(o_stave2_rdata),
		.o_sel3			(o_slave3_sel),
		.i_data_wr3		(o_stave3_rdata)
	);

	assign o_slave_addr = w_addr[4:0];

endmodule
