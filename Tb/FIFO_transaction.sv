package FIFO_transaction_pkg;
	import shared_pkg::*;

	class FIFO_transaction;

		logic [15:0] data_out;
		logic wr_ack, overflow, full, empty, almostfull, almostempty, underflow;

		int RD_EN_ON_DIST, WR_EN_ON_DIST;

		rand logic rst_n, wr_en, rd_en;
		rand logic [15:0] data_in;

		function new(int rd_dist = 30, int wr_dist = 70);
		 	RD_EN_ON_DIST = rd_dist;
		 	WR_EN_ON_DIST = wr_dist;
		endfunction : new

		constraint reset_c {rst_n dist {1 := 98 , 0 := 2};}
		constraint wr_en_c {wr_en dist {1 := WR_EN_ON_DIST , 0 := (100 - WR_EN_ON_DIST)};}
		constraint rd_en_c {rd_en dist {1 := RD_EN_ON_DIST , 0 := (100 - RD_EN_ON_DIST)};}

	endclass : FIFO_transaction
	
endpackage : FIFO_transaction_pkg