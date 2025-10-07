//============================================================
// Reset Synchronization module for coherent blocks
//============================================================

`timescale <%=obj.timescale%>
module reset_synchronizer (clk, reset_n, test_mode, reset_sync);
   input clk;
   input reset_n;
   input test_mode;
   output reg reset_sync;

   reg        reset_reg0;
   reg        reset_reg1;
`ifdef TEST_RESETS
   reg        reset_reg2;
   integer    randnum;

   initial begin
      randnum = $urandom_range(1, 100);
   end
`endif

   always @(posedge clk or negedge reset_n) begin
      if (~reset_n) begin
         reset_reg0 <= 1'b0;
         reset_reg1 <= 1'b0;
`ifdef TEST_RESETS
         reset_reg2 <= 1'b0;
`endif
      end else begin
         reset_reg0 <= 1'b1;
         reset_reg1 <= reset_reg0;
`ifdef TEST_RESETS
         reset_reg2 <= reset_reg1;
`endif
      end
   end

   always @(*) begin
      reset_sync = reset_reg1;

`ifdef TEST_RESETS
      if (randnum <= 33) begin
         reset_sync = reset_reg0;
      end
      else if (randnum <= 66) begin
         reset_sync = reset_reg2;
      end
`endif
   end

endmodule // reset_synchronizer

