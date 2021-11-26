module slave_mux
(
	input		wire[1:0]	i_addr,
	output	wire[7:0]	o_data_wr,
	output	wire			o_sel0,
	input		wire[7:0]	i_data_wr0,
	output	wire			o_sel1,
	input		wire[7:0]	i_data_wr1,
	output	wire			o_sel2,
	input		wire[7:0]	i_data_wr2,
	output	wire			o_sel3,
	input		wire[7:0]	i_data_wr3
);
	
	assign o_data_wr =
		(i_addr == 2'b00) ? i_data_wr0 :
		(i_addr == 2'b01) ? i_data_wr1 :
		(i_addr == 2'b10) ? i_data_wr2 :
		i_data_wr3;

	assign o_sel0 = (i_addr == 2'b00);
	assign o_sel1 = (i_addr == 2'b01);
	assign o_sel2 = (i_addr == 2'b10);
	assign o_sel3 = (i_addr == 2'b11);

endmodule
