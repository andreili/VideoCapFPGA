module sdram_ctrl
#(
	parameter	SDRAM_MHZ   			= 133,
	parameter	SDRAM_DATA_W 			= 16,
	parameter	SDRAM_ADDR_W 			= 23,
	parameter	SDRAM_COL_W 			= 9,
	parameter	SDRAM_BANK_W 			= 2,
	parameter  	SDRAM_BANKS          = 2 ** SDRAM_BANK_W,
	parameter   SDRAM_ROW_W          = SDRAM_ADDR_W - SDRAM_COL_W - SDRAM_BANK_W,
	parameter   SDRAM_REFRESH_CNT    = 2 ** SDRAM_ROW_W,
	//parameter   SDRAM_START_DELAY    = (100 * SDRAM_MHZ), // 100uS
	parameter   SDRAM_REFRESH_CYCLES = (64000*SDRAM_MHZ) / SDRAM_REFRESH_CNT-1,
	parameter   SDRAM_READ_LATENCY   = 3,
	parameter   SDRAM_BURST_SIZE	   = 8,
	parameter   SDRAM_BURST_COUNT	   = 64,
	parameter	SDRAM_T_RP				= 3,
	parameter	SDRAM_T_WR				= 4,
	parameter	SDRAM_T_RFC				= 9,
	parameter	SDRAM_T_MRD				= 2,
	parameter	SDRAM_T_RCD				= 3
)
(
	input		wire			i_clk,
	input		wire			i_reset_n,
	inout		wire[(SDRAM_DATA_W-1):0]	io_dq,
	output	wire[(SDRAM_ROW_W-1):0]		o_A,
	output	wire[(SDRAM_BANK_W-1):0]	o_BS,
	output	wire			o_CSn,
	output	wire			o_CKE,
	output	wire			o_LDQM,
	output	wire			o_UDQM,
	output	wire			o_WEn,
	output	wire			o_CASn,
	output	wire			o_RASn,
	input		wire			i_fifo_nempty,
	input		wire[8:0]	i_fifo_line,
	input		wire[15:0]	i_fifo_data,
	output	wire			o_fifo_reset,
	output	wire			o_fifo_next,
	input		wire[8:0]	i_line_idx,
	input		wire			i_line_end,
	output	wire			o_vdata_valid,
	output	wire			o_vdata_reset,
	output	wire[15:0]	o_vdata
);

	localparam CMD_W             = 3;
	localparam CMD_NOP           = 3'b111;
	localparam CMD_ACTIVE        = 3'b011;
	localparam CMD_READ          = 3'b101;
	localparam CMD_WRITE         = 3'b100;
	localparam CMD_TERMINATE     = 3'b110;
	localparam CMD_PRECHARGE     = 3'b010;
	localparam CMD_REFRESH       = 3'b001;
	localparam CMD_LOAD_MODE     = 3'b000;

	localparam MODE_REG          =
	{
		3'b000,
		1'b0,									// write burst mode
		2'b00,								// Operation mode (std)
		3'(SDRAM_READ_LATENCY),			// CAS lat
		1'b0,									// burst type (seq)
		3'(7)//$clog2(SDRAM_BURST_SIZE))	// burst length
	};

	localparam STATE_W           = 5;
	localparam STATE_INIT_PRECH  = 0;
	localparam STATE_INIT_REFR1  = STATE_INIT_PRECH + 1;
	localparam STATE_INIT_REFR2  = STATE_INIT_REFR1 + 1;
	localparam STATE_INIT_LMDR   = STATE_INIT_REFR2 + 1;
	localparam STATE_IDLE        = STATE_INIT_LMDR + 1;
	localparam STATE_ACTIVATE    = STATE_IDLE + 1;
	localparam STATE_PRECH  	  = STATE_ACTIVATE + 1;
	localparam STATE_PRECH_NOP   = STATE_PRECH + 1;
	localparam STATE_REFRESH     = STATE_PRECH_NOP + 1;
	localparam STATE_READ        = STATE_REFRESH + 1;
	localparam STATE_READ_DATA   = STATE_READ + 1;
	localparam STATE_READ_END    = STATE_READ_DATA + 1;
	localparam STATE_WRITE       = STATE_READ_END + 1;
	localparam STATE_WRITE_DATA  = STATE_WRITE + 1;
	localparam STATE_WRITE_END   = STATE_WRITE_DATA + 1;
	localparam STATE_PRECHARGE   = STATE_WRITE_END + 1;

	localparam WAIT_WIDTH		  = 9;
	localparam REFR_WIDTH		  = 12;

	reg[(CMD_W-1):0]			r_cmd;
	reg[(STATE_W-1):0]		r_state;
	reg							r_cke;
	reg							r_dqm;
	reg[(SDRAM_ROW_W-1):0]	r_addr;
	reg[(WAIT_WIDTH-1):0]	r_wait;

	reg[(REFR_WIDTH-1):0]	r_refr_cnt;
	reg							r_refr_reset;
	wire							w_refr_req = ~(|r_refr_cnt);

	always @(posedge i_clk)
	begin
		if ((i_reset_n == 1'b0) || (r_refr_reset == 1'b1))
		begin
			r_refr_cnt <= REFR_WIDTH'(SDRAM_REFRESH_CYCLES - (SDRAM_BURST_COUNT * (SDRAM_BURST_SIZE + 3)));
		end
			else if (w_refr_req == 1'b0)
		begin
			r_refr_cnt <= r_refr_cnt - 1'b1;
		end
	end

	reg							r_line_end;
	reg							r_line_end_prev;
	reg							r_vdata_req;
	wire							w_line_ended = r_line_end & (!r_line_end_prev);
	//reg[7:0]						r_video_line;
	reg							r_fifo_next;
	reg							r_fifo_reset;

	always @(posedge i_clk)
	begin
		r_line_end <= i_line_end;
		r_line_end_prev <= r_line_end;
	end

	always @(posedge i_clk)
	begin
		if (w_line_ended == 1'b1)
			r_vdata_req <= 1'b1;
		else if (r_state == STATE_READ)
			r_vdata_req <= 1'b0;
	end

	always @(posedge i_clk)
	begin
		if (i_reset_n == 1'b0)
		begin
			r_state <= STATE_INIT_PRECH;
			r_cmd <= CMD_NOP;
			r_wait <= { WAIT_WIDTH{1'b0} };
			r_dqm <= 1'b1;
			r_refr_reset <= 1'b0;
			r_fifo_reset <= 1'b0;
			r_fifo_next <= 1'b0;
		end
			else if (r_wait != { WAIT_WIDTH{1'b0} })
		begin
			r_wait <= r_wait - 1'b1;
			r_cmd <= CMD_NOP;
		end
			else
		case (r_state)
		STATE_INIT_PRECH:
			begin
				r_state <= STATE_INIT_REFR1;
				r_cmd <= CMD_PRECHARGE;
				r_addr[10] <= 1'b1;
				r_wait <= WAIT_WIDTH'(SDRAM_T_RP);
			end
		STATE_INIT_REFR1:
			begin
				r_state <= STATE_INIT_REFR2;
				r_cmd <= CMD_REFRESH;
				r_wait <= WAIT_WIDTH'(SDRAM_T_RFC);
			end
		STATE_INIT_REFR2:
			begin
				r_state <= STATE_INIT_LMDR;
				r_cmd <= CMD_REFRESH;
				r_wait <= WAIT_WIDTH'(SDRAM_T_RFC);
			end
		STATE_INIT_LMDR:
			begin
				r_state <= STATE_IDLE;
				r_cmd <= CMD_LOAD_MODE;
				r_addr <= SDRAM_ROW_W'(MODE_REG);
				r_wait <= WAIT_WIDTH'(SDRAM_T_MRD);
			end
		STATE_IDLE:
			begin
				r_cmd <= CMD_NOP;

				if (w_refr_req == 1'b1)
					r_state <= STATE_REFRESH;
				else if (i_fifo_nempty== 1'b1)
				begin
					r_state <= STATE_ACTIVATE;
				end
				else if (r_vdata_req == 1'b1)
				begin
					r_state <= STATE_ACTIVATE;
				end
				r_refr_reset <= 1'b0;
				r_addr <= { SDRAM_ROW_W{1'b0} };
			end
		STATE_ACTIVATE:
			begin
				if (r_vdata_req == 1'b1)
				begin
					r_state <= STATE_READ;
					r_addr[8:0] <= i_line_idx;
					r_addr[11:9] <= 3'b0;
				end
				else
				begin
					r_state <= STATE_WRITE;
					r_addr[8:0] <= i_fifo_line;
					r_addr[11:9] <= 3'b0;
				end
				r_cmd <= CMD_ACTIVE;
				r_wait <= WAIT_WIDTH'(SDRAM_T_RCD);
			end
		STATE_READ:
			begin
				r_state <= STATE_READ_DATA;
				r_cmd <= CMD_READ;
				r_addr[(SDRAM_COL_W-1):0] <= { SDRAM_COL_W{1'b0} };
				r_dqm <= 1'b0;
				r_wait <= WAIT_WIDTH'(SDRAM_READ_LATENCY - 1);
			end
		STATE_READ_DATA:
			begin
				r_state <= STATE_READ_END;
				o_vdata_valid <= 1'b1;
				r_wait <= WAIT_WIDTH'((SDRAM_BURST_COUNT * SDRAM_BURST_SIZE) - 1);
			end
		STATE_READ_END:
			begin
				r_cmd <= CMD_TERMINATE;
				o_vdata_valid <= 1'b0;
				r_state <= STATE_PRECH;
			end
		STATE_WRITE:
			begin
				r_state <= STATE_WRITE_DATA;
				r_cmd <= CMD_WRITE;
				r_dqm <= 1'b0;
				r_addr[(SDRAM_COL_W-1):0] <= { SDRAM_COL_W{1'b0} };
				r_wait <= WAIT_WIDTH'((SDRAM_BURST_COUNT * SDRAM_BURST_SIZE) - 1);
				r_fifo_next <= 1'b1;
			end
		STATE_WRITE_DATA:
			begin
				r_state <= STATE_WRITE_END;
				r_wait <= WAIT_WIDTH'(SDRAM_T_WR - 1);
				r_dqm <= 1'b1;
				r_fifo_reset <= 1'b1;
				r_fifo_next <= 1'b0;
			end
		STATE_WRITE_END:
			begin
				r_state <= STATE_PRECH;
				r_cmd <= CMD_TERMINATE;
				r_fifo_reset <= 1'b0;
			end
		STATE_PRECH:
			begin
				r_state <= STATE_IDLE;
				r_cmd <= CMD_PRECHARGE;
				r_addr[10] <= 1'b1;
				r_wait <= WAIT_WIDTH'(SDRAM_T_RP);
			end
		STATE_REFRESH:
			begin
				r_state <= STATE_IDLE;
				r_cmd <= CMD_REFRESH;
				r_refr_reset <= 1'b1;
				r_wait <= WAIT_WIDTH'(SDRAM_T_RFC);
			end
		endcase
	end
	
	assign o_CKE  = 1'b1;
	assign o_CSn  = 1'b0;
	assign o_RASn = r_cmd[2];
	assign o_CASn = r_cmd[1];
	assign o_WEn  = r_cmd[0];
	assign o_LDQM = r_dqm;
	assign o_UDQM = r_dqm;
	assign o_BS	  = { SDRAM_BANK_W{1'b0} };
	assign o_A	  = r_addr;
	assign o_vdata = io_dq;
	assign o_vdata_reset = r_vdata_req;
	assign o_fifo_reset = r_fifo_reset;
	assign o_fifo_next = r_fifo_next;

	assign io_dq = ((r_state == STATE_WRITE) || (r_state == STATE_WRITE_DATA)) ? i_fifo_data : { SDRAM_DATA_W{1'bZ} };

endmodule
