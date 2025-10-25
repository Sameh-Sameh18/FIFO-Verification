package FIFO_scoreboard_pkg;
	import FIFO_transaction_pkg::*;
	import shared_pkg::*;
	
	class FIFO_scoreboard;
		
		bit [15:0] data_out_gold;
		bit wr_ack_gold, overflow_gold, full_gold, empty_gold, almostfull_gold, almostempty_gold, underflow_gold;

		logic [15:0] golden_mem [$]; // queue for golden model

		function void check_data (FIFO_transaction obj);
			reference_model(obj);

			// compare data_out only when read happened and no underflow
			if (obj.rd_en && golden_mem.size() >= 0) begin
				if (underflow_gold) begin
					if (!obj.underflow) begin
						$display("ERROR: DUT underflow not asserted when expected");
						error_count++;
					end else 
						correct_count++;
				end else begin
					if (data_out_gold == obj.data_out) 
						correct_count++;
					else begin
						$display("MISMATCH: DUT data out is %0h and expected %0h",obj.data_out,data_out_gold);
						error_count++;
					end
				end
			end 
		endfunction : check_data

		function void reference_model (FIFO_transaction dut_obj);
			wr_ack_gold   = 0;
            overflow_gold = 0;
            underflow_gold = 0;

			if (!dut_obj.rst_n) begin
				golden_mem.delete();
				wr_ack_gold = 0;
				overflow_gold = 0;
            	underflow_gold = 0;
            	data_out_gold = 0;
			end	else begin
				case ({dut_obj.wr_en , dut_obj.rd_en})
					2'b10 : begin
						if(golden_mem.size() < 8) begin
							golden_mem.push_back(dut_obj.data_in);
							wr_ack_gold = 1;
							overflow_gold = 0;
						end else begin
							overflow_gold = 1;
							wr_ack_gold = 0;
						end
					end

					2'b01 : begin
						if (golden_mem.size() > 0) begin
							data_out_gold = golden_mem.pop_front();
							underflow_gold = 0;
						end else begin
							underflow_gold = 1;
						end
					end

					2'b11 : begin
						if (golden_mem.size() == 0) begin
							if(golden_mem.size() < 8) begin
								golden_mem.push_back(dut_obj.data_in);
								wr_ack_gold = 1;
								overflow_gold = 0;
							end else begin
								overflow_gold = 1;
								wr_ack_gold = 0;
							end
						end else if (golden_mem.size() == 8) begin
							if (golden_mem.size() > 0) begin
								data_out_gold = golden_mem.pop_front();
								underflow_gold = 0;
							end else begin
								underflow_gold = 1;
							end
						end else begin
							if (golden_mem.size() > 0)
								data_out_gold = golden_mem.pop_front();

							if (golden_mem.size() < 8) begin
								golden_mem.push_back(dut_obj.data_in);
								wr_ack_gold = 1;
							end
						end
					end
				endcase

				// flag update
				empty_gold = (golden_mem.size() == 0);
				full_gold = (golden_mem.size() == 8);
				almostempty_gold = (golden_mem.size() == 1);
				almostfull_gold = (golden_mem.size() == 7);
			end
		endfunction : reference_model

	endclass : FIFO_scoreboard
	
endpackage : FIFO_scoreboard_pkg