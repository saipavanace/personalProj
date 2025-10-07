module fv_ccp_double_wr_port_queue #(
   parameter QUEUE_DEPTH = 4,
   parameter PNT_W = $clog2(QUEUE_DEPTH),
   parameter MEM_W = 4
)(
   input clk,
   input reset_n,
   input push_1,
   input [MEM_W-1:0] data_in_1,
   input push_2,
   input [MEM_W-1:0] data_in_2,
   input sample_bit,
   input pop,
   output reg [MEM_W-1:0] data_out,
   output reg empty,
   output reg full
);

reg [MEM_W-1:0] mem [0:QUEUE_DEPTH-1];
reg [PNT_W-1:0] wr_pnt;
reg [PNT_W-1:0] rd_pnt;

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      wr_pnt <= 'd0;
      rd_pnt <= 'd0;
   end else begin
      if (push_1 & !push_2 & !(empty & pop)) begin
         mem[wr_pnt] <= data_in_1;
         if (wr_pnt < (QUEUE_DEPTH-1)) begin
            wr_pnt <= wr_pnt+1;
         end else begin
            wr_pnt <= 'd0;
         end
      end else if (push_2 & !push_1 & !(empty & pop)) begin
         mem[wr_pnt] <= data_in_2;
         if (wr_pnt < (QUEUE_DEPTH-1)) begin
            wr_pnt <= wr_pnt+1;
         end else begin
            wr_pnt <= 'd0;
         end
      end else if (push_1 & push_2 & !(empty & pop)) begin
         mem[wr_pnt] <= data_in_1;
         if (wr_pnt == (QUEUE_DEPTH - 1)) begin
            mem[0] <= data_in_2;
            wr_pnt <= 'd1;
         end else begin
            mem[wr_pnt+1] <= data_in_2;
            if (wr_pnt == (QUEUE_DEPTH - 2)) begin
               wr_pnt <= 'd0;
            end else begin
               wr_pnt <= wr_pnt + 2;
            end
         end
      end else if (push_1 & push_2 & empty & pop) begin
         mem[wr_pnt] <= data_in_2;
         if (wr_pnt < (QUEUE_DEPTH-1)) begin
            wr_pnt <= wr_pnt+1;
         end else begin
            wr_pnt <= 'd0;
         end
      end

//      if (pop/* & !empty*/) begin
      if (pop & !empty) begin
         if (rd_pnt < QUEUE_DEPTH-1) begin
            rd_pnt <= rd_pnt+1;
         end else begin
            rd_pnt <= 'd0;
         end
      end
   end
end

wire [MEM_W-1:0] data_from_mem = mem[rd_pnt];

always @(*) begin
   data_out = 'd0;
   if (!empty) begin
      data_out = data_from_mem;
   end else if (empty & push_1 & !push_2) begin
      data_out = data_in_1;
   end else if (empty & push_2 & !push_1) begin
      data_out = data_in_2;
   end else if (empty & push_1 & push_2) begin
      data_out = data_in_1;
   end
end

reg roll_over_flag;

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      roll_over_flag <= 1'b0;
   end else begin
      if ((wr_pnt == (QUEUE_DEPTH-1)) && (push_1 | push_2)) begin
         roll_over_flag <= 1'b1;
      end else 
      if ((rd_pnt == (QUEUE_DEPTH-1)) && pop) begin
         roll_over_flag <= 1'b0;
      end  
   end
end

assign full = (roll_over_flag) ? (wr_pnt == rd_pnt) : 1'b0;
assign empty = (roll_over_flag) ?  1'b0 : (wr_pnt == rd_pnt);

cache2ctrl_full_and_no_pop_thn_no_push: assert property(
   @(posedge clk) disable iff (!reset_n) 
   (full && !pop) 
   |->
   !(push_1 | push_2)
);

cache2ctrl_empty_and_no_push_thn_no_pop: assert property(
   @(posedge clk) disable iff (!reset_n) 
   (empty && !(push_1 | push_2)) 
   |->
   !pop
);

cache2ctrl_empty_and_no_push_thn_no_sample_bit: assert property(
   @(posedge clk) disable iff (!reset_n) 
   (empty && !(push_1 | push_2))
   |->
   !sample_bit
);


endmodule
