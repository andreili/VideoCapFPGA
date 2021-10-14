module vcap
#(
	parameter							SCR_SIZE_BIT,
	parameter							SDRAM_MHZ
)
(
	input		wire						i_reset_n,
	input		wire						i_pxl_clk,
	input		wire						i_ram_clk,
	input		wire						i_vo_clk,
	input		wire[3:0]				i_R,
	input		wire[3:0]				i_G,
	input		wire[3:0]				i_B,
	input		wire						i_I,
	input		wire						i_HS,
	input		wire						i_VS,
	input		wire						i_HS_inv,
	input		wire						i_VS_inv,
	input		wire[2:0]				i_mux_mode,
	input		wire[SCR_SIZE_BIT:0]	i_x_start,
	input		wire[SCR_SIZE_BIT:0]	i_x_size,
	input		wire[SCR_SIZE_BIT:0]	i_y_start,
	input		wire[SCR_SIZE_BIT:0]	i_y_size,
//
	inout		wire[15:0]				io_dq,
	output	wire[12:0]				o_A,
	output	wire[1:0]				o_BS,
	output	wire						o_CSn,
	output	wire						o_CKE,
	output	wire						o_LDQM,
	output	wire						o_UDQM,
	output	wire						o_WEn,
	output	wire						o_CASn,
	output	wire						o_RASn,

	output	wire[7:0]				o_R,
	output	wire[7:0]				o_G,
	output	wire[7:0]				o_B,
	output	wire						o_HS,
	output	wire						o_VS,
	output	wire						o_DE
);

endmodule
