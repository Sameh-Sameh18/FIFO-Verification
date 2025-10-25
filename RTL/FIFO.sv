////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO (FIFO_if.DUT fifo_if);

parameter FIFO_WIDTH = 16, FIFO_DEPTH = 8;
 
localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
	if (!fifo_if.rst_n) begin
		wr_ptr <= 0;
		fifo_if.wr_ack <= 0;
		fifo_if.overflow <= 0;
	end else if (fifo_if.wr_en && count < FIFO_DEPTH) begin
		mem[wr_ptr] <= fifo_if.data_in;
		fifo_if.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end else begin 
		fifo_if.wr_ack <= 0; 
		if (fifo_if.full && fifo_if.wr_en)
			fifo_if.overflow <= 1;
		else
			fifo_if.overflow <= 0;
	end
end

always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
	if (!fifo_if.rst_n) begin
		rd_ptr <= 0;
		fifo_if.data_out <= 0;
		fifo_if.underflow <= 0;
	end else if (fifo_if.rd_en && count != 0) begin
		fifo_if.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end else begin
		if (fifo_if.empty && fifo_if.rd_en)
			fifo_if.underflow <= 1;
		else
			fifo_if.underflow <= 0;
	end
end

always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
	if (!fifo_if.rst_n) begin
		count <= 0;
	end else begin
		if	( ({fifo_if.wr_en, fifo_if.rd_en} == 2'b10) && !fifo_if.full) 
			count <= count + 1;
		else if ( ({fifo_if.wr_en, fifo_if.rd_en} == 2'b01) && !fifo_if.empty)
			count <= count - 1;
		else if ( ({fifo_if.wr_en, fifo_if.rd_en} == 2'b11)) begin
			if (fifo_if.empty)
				count <= count + 1;
			else if (fifo_if.full)
				count <= count - 1;
		end
	end
end

assign fifo_if.full = (count == FIFO_DEPTH)? 1 : 0;
assign fifo_if.empty = (count == 0)? 1 : 0;
assign fifo_if.almostfull = (count == FIFO_DEPTH-1)? 1 : 0; 
assign fifo_if.almostempty = (count == 1)? 1 : 0;

`ifdef SIM
	// Reset
	always_comb begin
		if (!fifo_if.rst_n)
			reset_sva : assert final ((count == 0) && (rd_ptr == 0) && (wr_ptr == 0) && (fifo_if.overflow == 0) && (fifo_if.underflow == 0) && (fifo_if.data_out == 0) && (fifo_if.wr_ack == 0));
	end

	// Write Acknowledge
	property wr_ack;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) (fifo_if.wr_en && count < FIFO_DEPTH) |=> (fifo_if.wr_ack);
	endproperty

	// Overflow Detection
	property overflow;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) (fifo_if.wr_en && count == FIFO_DEPTH) |=> (fifo_if.overflow);
	endproperty

	// Underflow Detection
	property underflow;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) (fifo_if.rd_en && count == 0) |=> (fifo_if.underflow);
	endproperty

	// Empty Flag Assert
	property empty;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) (count == 0) |-> (fifo_if.empty);
	endproperty

	// Full Flag Assert
	property full;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) (count == FIFO_DEPTH) |-> (fifo_if.full);
	endproperty

	// Almost Full Flag Assert
	property almostfull;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) (count == FIFO_DEPTH-1) |-> (fifo_if.almostfull);
	endproperty

	// Almost Empty Flag Assert
	property almostempty;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) (count == 1) |-> (fifo_if.almostempty);
	endproperty

	// Pointer Write Wraparound
	property W_wrapping;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) (fifo_if.wr_en && wr_ptr == FIFO_DEPTH-1 && count < FIFO_DEPTH) |=> (wr_ptr == 0);
	endproperty

	// Pointer Read Wraparound
	property R_wrapping;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) (fifo_if.rd_en && rd_ptr == FIFO_DEPTH-1 && count > 0) |=> (rd_ptr == 0);
	endproperty

	// Threshold
	property threshold;
		@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) (wr_ptr < FIFO_DEPTH) && (rd_ptr < FIFO_DEPTH) && (count <= FIFO_DEPTH);
	endproperty

	assert property (wr_ack);      // Write Acknowledge
	assert property (overflow);    // Overflow Detection
	assert property (underflow);   // Underflow Detection
	assert property (empty);       // Empty Flag Assert
	assert property (full);        // Full Flag Assert
	assert property (almostfull);  // Almost Full Flag Assert
	assert property (almostempty); // Almost Empty Flag Assert
	assert property (W_wrapping);  // Pointer Write Wraparound
	assert property (R_wrapping);  // Pointer Read Wraparound
	assert property (threshold);   // Threshold

	cover property (wr_ack);       // Write Acknowledge
	cover property (overflow);     // Overflow Detection
	cover property (underflow);    // Underflow Detection
	cover property (empty);        // Empty Flag Assert
	cover property (full);         // Full Flag Assert
	cover property (almostfull);   // Almost Full Flag Assert
	cover property (almostempty);  // Almost Empty Flag Assert
	cover property (W_wrapping);   // Pointer Write Wraparound
	cover property (R_wrapping);   // Pointer Read Wraparound
	cover property (threshold);    // Threshold

`endif

endmodule