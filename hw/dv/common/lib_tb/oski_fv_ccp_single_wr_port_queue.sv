module fv_ccp_single_wr_port_queue #(
   parameter WR_QUEUE_DEPTH = 4,
   parameter PNT_W = $clog2(WR_QUEUE_DEPTH),
   parameter MEM_W = 4
)(
   input clk,
   input reset_n,
   input push,
   input [MEM_W-1:0] data_in,
   input pop,
   input sample_fifo_output,
   output wire [MEM_W-1:0] data_out,
   output reg empty,
   output reg full
);

reg [MEM_W-1:0] mem [0:WR_QUEUE_DEPTH-1];
reg [PNT_W-1:0] wr_pnt;
reg [PNT_W-1:0] rd_pnt;

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      wr_pnt <= 'd0;
      rd_pnt <= 'd0;
   end else begin
      if (push && !(empty && pop)) begin
         mem[wr_pnt] <= data_in;
         if(wr_pnt == (WR_QUEUE_DEPTH-1))
            wr_pnt <= 'd0;
         else
            wr_pnt <= wr_pnt + 'd1;
      end
      
      if (pop && !empty) begin
         if(rd_pnt == (WR_QUEUE_DEPTH-1))
            rd_pnt <= 'd0;
         else
            rd_pnt <= rd_pnt + 'd1;
      end
   end
end


wire [MEM_W-1:0] data_from_mem = mem[rd_pnt];
assign data_out = 
   empty ? data_in : data_from_mem;

reg roll_over_flag;

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      roll_over_flag <= 1'b0;
   end else begin
      if ((wr_pnt == (WR_QUEUE_DEPTH-1)) && push && !(empty && pop)) begin
         roll_over_flag <= 1'b1;
      end else  
      if ((rd_pnt == (WR_QUEUE_DEPTH-1)) && pop && !empty) begin
         roll_over_flag <= 1'b0;
      end  
   end
end

assign full = (roll_over_flag) ? (wr_pnt == rd_pnt) : 1'b0;
assign empty = (roll_over_flag) ?  1'b0 : (wr_pnt == rd_pnt);

full_and_no_pop_thn_no_push: assert property(
   @(posedge clk) disable iff (!reset_n) 
   (full && !pop)
   |->
   !push
);

empty_and_no_push_thn_no_pop: assert property(
   @(posedge clk) disable iff (!reset_n) 
   (empty && !push)
   |->
   !pop
);

empty_and_no_push_thn_no_sample_bit: assert property(
   @(posedge clk) disable iff (!reset_n) 
   (empty && !push)
   |->
   !sample_fifo_output
);


endmodule


