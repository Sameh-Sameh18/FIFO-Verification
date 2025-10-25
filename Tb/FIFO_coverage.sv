package FIFO_coverage_pkg;
	import FIFO_transaction_pkg::*;

	class FIFO_coverage;

		FIFO_transaction F_cvg_txn;

		covergroup cg;
			wr_en_cp : coverpoint F_cvg_txn.wr_en {
				bins wr_0 = {0};
				bins wr_1 = {1};
			}

			rd_en_cp : coverpoint F_cvg_txn.rd_en {
				bins rd_0 = {0};
				bins rd_1 = {1};
			}

			reset_cp : coverpoint F_cvg_txn.rst_n {
				bins rst_0 = {0};
				bins rst_1 = {1};
			}

			// flag cover points
			full_F_cp : coverpoint F_cvg_txn.full {
				bins full_0 = {0};
				bins full_1 = {1};
			}

			empty_F_cp : coverpoint F_cvg_txn.empty {
				bins empty_0 = {0};
				bins empty_1 = {1};
			}

			almostfull_F_cp : coverpoint F_cvg_txn.almostfull {
				bins almostfull_0 = {0};
				bins almostfull_1 = {1};
			}

			almostempty_F_cp : coverpoint F_cvg_txn.almostempty {
				bins almostempty_0 = {0};
				bins almostempty_1 = {1};
			}

			overflow_F_cp : coverpoint F_cvg_txn.overflow {
				bins overflow_0 = {0};
				bins overflow_1 = {1};
			}

			underflow_F_cp : coverpoint F_cvg_txn.underflow {
				bins underflow_0 = {0};
				bins underflow_1 = {1};
			}

			wr_ack_F_cp : coverpoint F_cvg_txn.wr_ack {
				bins wr_ack_0 = {0};
				bins wr_ack_1 = {1};
			}

			// cross coverage
			x_wr_rd_full  : cross wr_en_cp , rd_en_cp , full_F_cp {ignore_bins x = binsof(rd_en_cp.rd_1) && binsof(full_F_cp.full_1);}
			x_wr_rd_empty : cross wr_en_cp , rd_en_cp , empty_F_cp {ignore_bins x = binsof(wr_en_cp.wr_1) && binsof(empty_F_cp.empty_1);}
			x_wr_rd_af    : cross wr_en_cp , rd_en_cp , almostfull_F_cp;
			x_wr_rd_ae    : cross wr_en_cp , rd_en_cp , almostempty_F_cp;
			x_wr_rd_of    : cross wr_en_cp , rd_en_cp , overflow_F_cp {ignore_bins x = binsof(wr_en_cp.wr_0) && binsof(overflow_F_cp.overflow_1);}
			x_wr_rd_uf    : cross wr_en_cp , rd_en_cp , underflow_F_cp {ignore_bins x = binsof(rd_en_cp.rd_0) && binsof(underflow_F_cp.underflow_1);}
			x_wr_rd_ack   : cross wr_en_cp , rd_en_cp , wr_ack_F_cp {ignore_bins x = binsof(wr_en_cp.wr_0) && binsof(wr_ack_F_cp.wr_ack_1);}

		endgroup : cg

		function new();
			cg = new();
		endfunction : new

		function void sample_data (FIFO_transaction F_txn);
			F_cvg_txn = F_txn;
			cg.sample();
		endfunction : sample_data

	endclass : FIFO_coverage
	
endpackage : FIFO_coverage_pkg