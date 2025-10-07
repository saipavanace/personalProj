module fv_ccp_reset_abstraction #(
   parameter N_WAYS = 4,
   parameter ADDRESS_W = 40,
   parameter CACHE_LINE_OFFSET_W = 6,
   parameter N_TAG_BANKS = 2,
   parameter BNK_W = $clog2(N_TAG_BANKS),
   parameter N_SETS = 1024,
   parameter SET_PER_BANK = N_SETS/N_TAG_BANKS,
   parameter SET_PER_BANK_W = $clog2(SET_PER_BANK),
   parameter TAG_W = ADDRESS_W-(BNK_W+CACHE_LINE_OFFSET_W+SET_PER_BANK_W)
)(
   input clk,
   input reset_n,
   // tag_mem for bank0 and index 0
   input [107:0] tag_mem [0: N_WAYS-1],
   // data_mem for bank0 and index 0
   input [128:0] data_mem [0:15],
   input my_bit,
   input [N_WAYS-1:0] [TAG_W-1:0] my_tag,
   input [N_WAYS-1:0] [TAG_W-1:0] my_state,
   input [N_WAYS-1:0] [TAG_W-1:0] my_shadow_tag,
   input [N_WAYS-1:0] fill_state_pending,
   input [N_WAYS-1:0] fill_data_pending,
   input [N_WAYS-1:0] fill_done_pending,
   input [N_WAYS-1:0] my_shadow_tag_valid
);

reg oor_f;
always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      oor_f <= 1'b1;
   end else begin
      oor_f <= 1'b0;
   end
end

reg unique_tag_in_my_tag;
always @(*) begin
   unique_tag_in_my_tag = 1'b1;
   for (integer i=0; i< N_WAYS-1; i++) begin 
      for (integer j=i+1; j < N_WAYS; j++) begin
         if ((my_tag[i] == my_tag[j]) && (my_state[j] != 'd0) && 
             (my_state[i] != 'd0)) begin
            unique_tag_in_my_tag = 1'b0;
         end
      end
   end
end

// tag must be unique in my_tag 
oor_tag_unique_in_my_tag: assert property(
   @(posedge clk) disable iff (!reset_n) 
   oor_f
   |->
   unique_tag_in_my_tag
);

r_oor_tag_unique_in_my_tag: assert property(
   @(posedge clk) disable iff (!reset_n) 
   !oor_f
   |->
   unique_tag_in_my_tag
);
/*
reg unique_tag_in_my_shadow_tag;
always @(*) begin
   unique_tag_in_my_shadow_tag = 1'b1;
   for (integer i=0; i< N_WAYS-1; i++) begin 
      for (integer j=i+1; j < N_WAYS; j++) begin
         if ((my_shadow_tag[i] == my_shadow_tag[j]) && 
             (my_shadow_tag_valid[j]) &&
             (my_shadow_tag_valid[i])) begin
            unique_tag_in_my_shadow_tag = 1'b0;
         end
      end
   end
end

// tag must be unique in my_shadow_tag 
oor_tag_unique_in_my_shadow_tag: assert property(
   @(posedge clk) disable iff (!reset_n) 
   oor_f
   |->
   unique_tag_in_my_shadow_tag
);

r_oor_tag_unique_in_my_shadow_tag: assert property(
   @(posedge clk) disable iff (!reset_n) 
   !oor_f
   |->
   unique_tag_in_my_shadow_tag
);
*/
reg [N_WAYS-1:0] mem_not_same_as_tag_and_state;
always @(*) begin
   mem_not_same_as_tag_and_state = 'd0;
   for (integer i=0; i< N_WAYS-1; i++) begin
      for (integer j=i+1; j < N_WAYS; j++) begin
         if ((my_state[i] != 'd0) && 
             (tag_mem[i][(27*j)+:27] != {1'b1, my_tag[i], my_state[i]})) begin
            mem_not_same_as_tag_and_state[i] = 1'b1;
         end
      end
   end
end

// Out of constraint mem should be in accordance with my_tag and my_state
oor_mem_same_as_my_tag_and_my_state: assert property(
   @(posedge clk) disable iff (!reset_n) 
   oor_f
   |->
   !(|mem_not_same_as_tag_and_state)
);

r_oor_mem_same_as_my_tag_and_my_state: assert property(
   @(posedge clk) disable iff (!reset_n) 
   !oor_f
   |->
   !(|mem_not_same_as_tag_and_state)
);
/*
// shadow_tag_in_my_tag: if tag value in shadow_tag and my_tag are equal
reg [N_WAYS-1:0] shadow_tag_in_my_tag;
always @(*) begin
   shadow_tag_in_tag = ~fill_state_pending;
   for (integer i=0; i< N_WAYS; i++) begin
      for (integer j=0; j< N_WAYS; j++) begin
         if ((my_shadow_tag[i] == my_tag[j]) && (my_state[j] != 'd0)) begin
            shadow_tag_in_tag[i] = 1'b1;
         end
      end
   end
end

// Way for which state is pending cannot have same tag value in my_tag as well
// as my_shadow_tag
oor_fill_state_pending_way_tag_absent_in_my_tag: assert property(
   @(posedge clk) disable iff (!reset_n) 
   (oor_f)
   |->
   (shadow_tag_in_tag == ~fill_state_pending)
);

r_oor_fill_state_pending_way_tag_absent_in_my_tag: assert property(
   @(posedge clk) disable iff (!reset_n) 
   !oor_f
   |->
   (shadow_tag_in_tag == ~fill_state_pending)
);

// fill_data_pending and fill_done_pending can not be high for a way num
oor_data_and_done_pending_cannot_be_high_for_same_way: assert property(
   @(posedge clk) disable iff (!reset_n) 
   (oor_f)
   |->
   ((fill_done_pending & fill_data_pending) == 'd0)
);

r_oor_data_and_done_pending_cannot_be_high_for_same_way: assert property(
   @(posedge clk) disable iff (!reset_n) 
   !oor_f
   |->
   ((fill_done_pending & fill_data_pending) == 'd0)
);

wire [N_WAYS-1:0] only_done_or_data_pending = 
   ((fill_done_pending | fill_data_pending) & ~fill_state_pending);

reg [N_WAYS-1:0] state_invld;
always @(*) begin
   state_invld = 'd0;
   for (integer i=0; i< N_WAYS; i++) begin 
      if (only_done_or_data_pending[i] && (my_state[i] == 'd0)) begin
        state_invld[i] = 1'b1;
      end
   end
end

// Ways for which state is not pending but data or done are pending must have
// valid state
oor_valid_state_for_ways_with_only_done_or_data_pending: assert property(
   @(posedge clk) disable iff (!reset_n) 
   (oor_f)
   |->
   (state_invld == 'd0)
);

r_oor_valid_state_for_ways_with_only_done_or_data_pending: assert property(
   @(posedge clk) disable iff (!reset_n) 
   !oor_f
   |->
   (state_invld == 'd0)
);

reg [N_WAYS-1:0] tag_and_shadow_tag_not_equal;
always @(*) begin
   tag_and_shadow_tag_not_equal = 'd0;
   for (integer i=0; i< N_WAYS; i++) begin
      if (only_done_or_data_pending[i] && (my_tag[i] != my_shadow_tag[i])) begin
         tag_and_shadow_tag_not_equal[i] = 1'b1;
      end
   end
end

// If only data or done is pending for a way then tag value in my_tag and
// my_shadow_tag for that way must be equal
oor_tag_and_shadowtag_equal_ifonly_data_or_done_pending: assert property(
   @(posedge clk) disable iff (!reset_n) 
   oor_f
   |->
   (tag_and_shadow_tag_not_equal == 'd0)
);

r_oor_tag_and_shadowtag_equal_ifonly_data_or_done_pending: assert property(
   @(posedge clk) disable iff (!reset_n) 
   !oor_f
   |->
   (tag_and_shadow_tag_not_equal == 'd0)
);
*/
reg mem_bit;
always @(*) begin
   mem_bit = 'd0;
   for (integer i=0; i< N_WAYS-1; i++) begin
      if ((my_state[i] != 'd0) && (my_tag[i] == 'd0)) begin
         mem_bit = mem[4*i][0]; 
      end
   end
end

oor_mem_bit_same_as_my_bit: assert property(
   @(posedge clk) disable iff (!reset_n) 
   oor_f
   |->
   (mem_bit == my_bit)
);

r_oor_mem_bit_same_as_my_bit: assert property(
   @(posedge clk) disable iff (!reset_n) 
   !oor_f
   |->
   (mem_bit == my_bit)
);

endmodule
