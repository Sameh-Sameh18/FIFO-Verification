module FIFO_monitor (FIFO_if.MON fifo_if);
	import FIFO_transaction_pkg::*;
	import FIFO_coverage_pkg::*;
	import FIFO_scoreboard_pkg::*;
	import shared_pkg::*;

	FIFO_transaction trans_obj = new();
	FIFO_coverage cov_obj = new();
	FIFO_scoreboard sb_obj = new();

	initial begin
		forever begin
			@(fifo_if.sample_start);

			@(negedge fifo_if.clk);

			trans_obj.data_in 	  = fifo_if.data_in;
			trans_obj.rst_n 	  = fifo_if.rst_n;
			trans_obj.wr_en 	  = fifo_if.wr_en;
			trans_obj.rd_en 	  = fifo_if.rd_en;
			trans_obj.data_out    = fifo_if.data_out;
			trans_obj.wr_ack      = fifo_if.wr_ack;
			trans_obj.full        = fifo_if.full;
			trans_obj.empty       = fifo_if.empty;
			trans_obj.almostfull  = fifo_if.almostfull;
			trans_obj.almostempty = fifo_if.almostempty;
			trans_obj.overflow    = fifo_if.overflow;
			trans_obj.underflow   = fifo_if.underflow;

			fork
				begin
					cov_obj.sample_data(trans_obj);
				end

				begin
					sb_obj.check_data(trans_obj);
				end
			join

			if (test_finished) begin
				$display("Simulation finished. correct_count =%0d error_count =%0d", correct_count, error_count);
				$stop();
			end
		end
	end
	
endmodule : FIFO_monitor