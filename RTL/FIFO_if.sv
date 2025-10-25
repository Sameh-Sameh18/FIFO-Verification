interface FIFO_if (clk);

	localparam FIFO_WIDTH = 16, FIFO_DEPTH = 8;

	input bit clk;

	logic [FIFO_WIDTH-1:0] data_in, data_out;
	logic rst_n, wr_en, rd_en, wr_ack, overflow, full, empty, almostfull, almostempty, underflow;

	event sample_start;

	modport DUT (input  data_in, clk, rst_n, wr_en, rd_en, output data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow, import sample_start);
	modport TEST (output data_in,rst_n, wr_en, rd_en, input clk, data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow, import sample_start);
	modport MON (input  data_in, clk, rst_n, wr_en, rd_en, data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow, import sample_start);
		
endinterface : FIFO_if