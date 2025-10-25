module FIFO_top ();

	parameter FIFO_WIDTH = 16 , FIFO_DEPTH = 8;

	bit clk;

	initial begin
		forever #5 clk = ~clk;
	end

	// instantiate
	FIFO_if fifo_if (clk);

	FIFO DUT (fifo_if);
	FIFO_monitor MON (fifo_if);
	FIFO_tb TEST (fifo_if);


endmodule : FIFO_top