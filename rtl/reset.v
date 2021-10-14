`timescale 1 ps / 1 ps

module reset
#(
	parameter	WIDTH = 3
)
(
	input		wire		i_clk,
	input		wire		i_reset_in_n,
	output	wire		o_reset_out_n
);

	reg[(WIDTH-1):0]	r_cnt;
	
	always @(posedge i_clk)
	begin
		if (i_reset_in_n == 1'b0)
		begin
			r_cnt <= {WIDTH{1'b0}};
		end
			else if (r_cnt[WIDTH - 1] == 1'b0)
		begin
			r_cnt <= r_cnt + 1'b1;
		end
	end
	
	assign o_reset_out_n = r_cnt[WIDTH - 1];

endmodule
