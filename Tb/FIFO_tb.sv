module FIFO_tb (FIFO_if.TEST fifo_if);
	import shared_pkg::*;
	import FIFO_transaction_pkg::*;

	FIFO_transaction trans_obj = new();

	task assert_reset();
		fifo_if.rst_n = 0;
		@(negedge fifo_if.clk);
		-> fifo_if.sample_start;
		fifo_if.rst_n = 1;
	endtask : assert_reset

	task write_check();
		fifo_if.wr_en = 1;
		fifo_if.rd_en = 0;
		fifo_if.data_in = $random();
		@(negedge fifo_if.clk);
		-> fifo_if.sample_start;
		fifo_if.wr_en = 0;
	endtask : write_check

	task read_check();
		fifo_if.rd_en = 1;
		@(negedge fifo_if.clk);
		-> fifo_if.sample_start;
		fifo_if.rd_en = 0;
	endtask : read_check

	task write_read_check();
		fifo_if.wr_en = 1;
		fifo_if.rd_en = 1;
		fifo_if.data_in = $random();
		@(negedge fifo_if.clk);
		-> fifo_if.sample_start;
		fifo_if.wr_en = 0;
		fifo_if.rd_en = 0;
	endtask : write_read_check

	initial begin
		assert_reset();

		repeat(10) write_check();

		repeat(10) read_check();

		repeat(10) write_read_check();

		repeat(200) begin
			assert(trans_obj.randomize());

			// drive the signals
			fifo_if.rd_en   = trans_obj.rd_en;
			fifo_if.wr_en   = trans_obj.wr_en;
			fifo_if.rst_n   = trans_obj.rst_n;
			fifo_if.data_in = trans_obj.data_in;

			@(negedge fifo_if.clk);
			-> fifo_if.sample_start;
		end

		test_finished = 1;
		@(negedge fifo_if.clk);
		-> fifo_if.sample_start;
	end
endmodule : FIFO_tb