module VideoCap
(
	input		wire			clk,
	//
	input		wire			btn,
	output	wire[2:0]	led,
	// configuration FLASH
	output	wire			FLASH_ASDO,
	output	wire			FLASH_CSO,
	output	wire			FLASH_DCLK,
	input		wire			FLASH_DATA0,
	// SDRAM
	inout		wire[15:0]	SDRAM_DQ,
	output	wire[12:0]	SDRAM_A,
	output	wire[1:0]	SDRAM_BS,
	output	wire			SDRAM_CSn,
	output	wire			SDRAM_CKE,
	output	wire			SDRAM_CLK,
	output	wire			SDRAM_LDQM,
	output	wire			SDRAM_UDQM,
	output	wire			SDRAM_WEn,
	output	wire			SDRAM_CASn,
	output	wire			SDRAM_RASn,
	// video output
	output	wire[7:0]	VO_R,
	output	wire[7:0]	VO_G,
	output	wire[7:0]	VO_B,
	output	wire			VO_HS,
	output	wire			VO_VS,
	output	wire			VO_CLK,
	output	wire			VO_DE,
	// SPI interface to MCU
	input		wire			SPI_SCK,
	output	wire			SPI_SO,
	input		wire			SPI_SI,
	input		wire			SPI_CSn,
	// video input
	input		wire[3:0]	VI_R,
	input		wire[3:0]	VI_G,
	input		wire[3:0]	VI_B,
	input		wire			VI_I,
	input		wire			VI_HS,
	input		wire			VI_VS,
	input		wire			VI_CLK
);

`define SCR_SIZE_BIT 12

	wire w_clk_low, w_clk_sdram, w_clk_sdram90;
	wire w_clk_spi, w_clk_vo;
	wire w_reset_n;

	pll_core u_pll_core
	(
		.inclk0		(clk),
		.c0			(w_clk_sdram),	// 72
		.c1			(w_clk_low), 	// 1
		.c2			(w_clk_sdram90),
		.c3			(w_clk_spi)
	);

	reset
	#(
		.WIDTH				(3)
	)
	u_board_reset
	(
		.i_clk				(w_clk_low),
		.i_reset_in_n		(btn),
		.o_reset_out_n		(w_reset_n)
	);

	wire[6:0]	w_addr;
	wire[7:0]	w_data_wr, w_data_rd;
	wire			w_wr_req;
	wire			w_sel_vctrl, w_sel_pllctrl, w_sel_vcap;
	wire[7:0]	w_data_rd_vctrl, w_data_rd_pll, w_data_rd_vcap;
	wire			w_vclk2;

	spi_master u_master
	(
		.i_clk			(w_clk_spi),
		.i_reset_n		(w_reset_n),
		.i_spi_cs_n		(SPI_CSn),
		.i_spi_sck		(SPI_SCK),
		.i_spi_si		(SPI_SI),
		.o_spi_so		(SPI_SO),
		.o_addr			(w_addr),
		.o_data_wr		(w_data_wr),
		.i_data_rd		(w_data_rd),
		.o_wr_req		(w_wr_req)
	);

	slave_mux u_mux
	(
		.i_addr			(w_addr),
		.o_data_wr		(w_data_rd),
		.o_sel0			(w_sel_vctrl),
		.i_data_wr0		(w_data_rd_vctrl),
		.o_sel1			(w_sel_pllctrl),
		.i_data_wr1		(w_data_rd_pll),
		.o_sel2			(w_sel_vcap),
		.i_data_wr2		(w_data_rd_vcap),
		.o_sel3			(),
		.i_data_wr3		(8'h00)
	);

	pll_cfg u_pll_cfg
	(
		.i_clk			(w_clk_spi),
		.i_reset_n		(w_reset_n),
		.i_addr			(w_addr[4:0]),
		.i_data_wr		(w_data_wr),
		.i_select		(w_sel_pllctrl),
		.i_wr_req		(w_wr_req),
		.o_data_wr		(w_data_rd_pll),
		.i_clk_raw		(clk),
		.o_clk			(w_clk_vo)
	);

	wire			w_wr_fifo_active;
	wire[8:0]	w_wr_fifo_line;
	wire[11:0]	w_wr_fifo_data;
	wire			w_wr_fifo_reset;
	wire			w_wr_fifo_next;
	wire[11:0]	w_x_size, w_y_size;

	stream_cap
	#(
		.SCR_SIZE_BIT		(`SCR_SIZE_BIT)
	)
	u_stream
	(
		.i_pxl_clk			(VI_CLK),
		.i_ram_clk			(w_clk_sdram),
		.i_reset_n			(w_reset_n),
		// internal bus
		.i_clk_bus			(w_clk_spi),
		.i_addr				(w_addr[4:0]),
		.i_data_wr			(w_data_wr),
		.i_select			(w_sel_vcap),
		.i_wr_req			(w_wr_req),
		.o_data_wr			(w_data_rd_vcap),
		//
		.i_R					(VI_R),
		.i_G					(VI_G),
		.i_B					(VI_B),
		.i_I					(VI_I),
		.i_HS					(VI_HS),
		.i_VS					(VI_VS),
		.i_fifo_next		(w_wr_fifo_next),
		.i_fifo_reset		(w_wr_fifo_reset),
		.o_fifo_active		(w_wr_fifo_active),
		.o_fifo_line		(w_wr_fifo_line),
		.o_fifo_data		(w_wr_fifo_data),
		.o_x_size			(w_x_size),
		.o_y_size			(w_y_size)
	);

	wire[15:0]	w_vdata_to_buf;
	wire[8:0]	w_line_idx;
	wire			w_vdata_valid, w_vdata_reset, w_line_end;

	sdram_ctrl
	#(
		.SDRAM_MHZ		(133)
	)
	u_sdram
	(
		.i_clk			(w_clk_sdram),
		.i_reset_n		(w_reset_n),
		.io_dq			(SDRAM_DQ),
		.o_A				(SDRAM_A[11:0]),
		.o_BS				(SDRAM_BS),
		.o_CSn			(SDRAM_CSn),
		.o_CKE			(SDRAM_CKE),
		.o_LDQM			(SDRAM_LDQM),
		.o_UDQM			(SDRAM_UDQM),
		.o_WEn			(SDRAM_WEn),
		.o_CASn			(SDRAM_CASn),
		.o_RASn			(SDRAM_RASn),
		.i_fifo_nempty	(w_wr_fifo_active),
		.i_fifo_line	(w_wr_fifo_line),
		.i_fifo_data	({ 4'b0, w_wr_fifo_data }),
		.o_fifo_reset	(w_wr_fifo_reset),
		.o_fifo_next	(w_wr_fifo_next),
		.i_line_idx		(w_line_idx),
		.i_line_end		(w_line_end),
		.o_vdata_valid	(w_vdata_valid),
		.o_vdata_reset	(w_vdata_reset),
		.o_vdata			(w_vdata_to_buf)
	);

	video u_vo
	(
		.i_clk			(w_clk_vo),
		.i_clk_mem		(w_clk_sdram),
		.i_reset_n		(w_reset_n),
		// internal bus
		.i_clk_bus		(w_clk_spi),
		.i_addr			(w_addr[4:0]),
		.i_data_wr		(w_data_wr),
		.i_select		(w_sel_vctrl),
		.i_wr_req		(w_wr_req),
		.o_data_wr		(w_data_rd_vctrl),
		//
		.o_line_idx		(w_line_idx),
		.o_line_end		(w_line_end),
		.o_frame_end	(),
		.i_vdata_valid	(w_vdata_valid),
		.i_vdata_reset	(w_vdata_reset),
		.i_vdata			(w_vdata_to_buf),
		//
		.i_x_win_size	(w_x_size),
		.i_y_win_size	(w_y_size),
		// video output
		.o_r				(VO_R),
		.o_g				(VO_G),
		.o_b				(VO_B),
		.o_hs				(VO_HS),
		.o_vs				(VO_VS),
		.o_de				(VO_DE)
	);

	assign SDRAM_CLK = w_clk_sdram90;
	assign SDRAM_A[12] = 1'b0;
	assign VO_CLK = w_clk_vo;

endmodule
