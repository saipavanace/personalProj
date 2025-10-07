/*******************************************************************************
 * OSKI TECHNOLOGY CONFIDENTIAL 
 * Copyright (c) 2017 Oski Technology, All Rights Reserved.
 ******************************************************************************/

// ===========================================================================//
//                              Module Description                            //
// ===========================================================================//
// Per set-way file
// 1. Contains both checkers and constraints on P0/P2 stage with controller
// 2. Instantiates: fv_ccp_tagpipe_gen_index, fv_ccp_tag_bank_model and
//    fv_tag_mem_reset_abstraction
// ===========================================================================//

module fv_ccp_fill_cons #(
   parameter N_SETS = 1024,
   parameter SET_W = $clog2(N_SETS),
   parameter N_TAG_BANKS = 2,
   parameter BNK_W = $clog2(N_TAG_BANKS),
   parameter SET_PER_BANK = N_SETS/N_TAG_BANKS,
   parameter SET_PER_BANK_W = $clog2(SET_PER_BANK),
   parameter N_WAYS =2,
   parameter WAY_POINTER_W = $clog2(N_WAYS),
   parameter DATA_W = 129,
   parameter ADDRESS_W = 32,
   parameter CACHE_LINE_OFFSET_W = 6,
   parameter TAG_W = ADDRESS_W-(BNK_W+CACHE_LINE_OFFSET_W+SET_PER_BANK_W),
   parameter CACHE_STATE_W = 2,
   parameter BURST_LEN_W = 2,
   parameter SECURITY_BIT = 1,
   parameter TABLE_ENTRIES = 64,
   parameter TABLE_ENTRIES_W = $clog2(TABLE_ENTRIES),
   parameter ERR_BIT = 1,
   parameter MAX_TAG_BANKS = 4,
   parameter MAX_TAG_BANKS_W = $clog2(MAX_TAG_BANKS),
   parameter NRU_IN_TAG_MEM = 1,
   parameter TAG_PER_WAY_DATA_W = 25,
   parameter NRU_POLICY_EN = 0
) (
   input clk,
   input reset_n,
   input oor_f,
   input [SET_PER_BANK_W-1:0] my_set,
   input [MAX_TAG_BANKS_W-1:0] my_bnk,
   input [ADDRESS_W-1:0] ctrl_op_address_p2,
   input ctrl_op_security_p2,

   input cache_valid_p2,
   input ctrl_op_allocate_p2,
   input cache_nack_uce_p2,
   input cache_nack_p2,
   input cache_nack_ce_p2,
   input cache_nack_no_allocate_p2,
   input ctrl_op_read_data_p2,
   input ctrl_op_write_data_p2,
   input ctrl_op_tag_state_update_p2,
   input [CACHE_STATE_W-1:0] ctrl_op_state_p2,
   input ctrl_op_rp_update_p2,
   input ctrl_op_setway_debug_p2,
   input [N_WAYS-1:0] ctrl_op_ways_busy_vec_p2,
   input [N_WAYS-1:0] ctrl_op_ways_stale_vec_p2,

   input [N_WAYS-1:0] cache_alloc_way_vec_p2,
   input [N_WAYS-1:0] cache_hit_way_vec_p2,
   input [WAY_POINTER_W-1:0] cache_alloc_way_p2,
   input [WAY_POINTER_W-1:0] cache_hit_way_p2,

   input ctrl_fill_valid,
   input [ADDRESS_W-1:0] ctrl_fill_address,
   input [WAY_POINTER_W-1:0] ctrl_fill_way_num,
   input [CACHE_STATE_W-1:0] ctrl_fill_state,
   input ctrl_fill_security,
   input cache_fill_ready,

   input ctrl_fill_data_valid,
   input [DATA_W-1:0] ctrl_fill_data,
   input [TABLE_ENTRIES_W-1:0] ctrl_fill_data_id,
   input [ADDRESS_W-1:0] ctrl_fill_data_address,
   input [WAY_POINTER_W-1:0] ctrl_fill_data_way_num,
   input [BURST_LEN_W-1:0] ctrl_fill_data_beat_num,
   input cache_fill_data_ready,
   input cache_fill_done,
   input [TABLE_ENTRIES_W-1:0] cache_fill_done_id,

   input wire ctrl_fill_data_valid_first_beat,
   input wire ctrl_fill_data_valid_last_beat,
   input [3:0] maint_req_opcode,
   input [31:0] maint_req_data,
   input [31:0] maint_req_way,
   input [19:0] maint_req_entry,
   input [5:0] maint_req_word,
   input maint_req_array_sel,
   input [31:0] maint_read_data,

   input [CACHE_STATE_W-1:0] cache_current_state_p2,
   input cache_evict_valid_p2,
   input [ADDRESS_W-1:0] cache_evict_address_p2,
   input cache_evict_security_p2,
   input [CACHE_STATE_W-1:0] cache_evict_state_p2,

   input [N_TAG_BANKS-1:0] tag_mem_chip_en,
   input [N_TAG_BANKS-1:0] tag_mem_write_en,
   input [(N_TAG_BANKS*SET_PER_BANK_W)-1:0] tag_mem_address,
   input [(N_TAG_BANKS*N_WAYS)-1:0] tag_mem_write_en_mask,
   input [(N_TAG_BANKS*N_WAYS*TAG_PER_WAY_DATA_W)-1:0] tag_mem_data_in,
   input [(N_TAG_BANKS*N_WAYS*TAG_PER_WAY_DATA_W)-1:0] tag_mem_data_out
);

localparam TAG_FINAL_W = TAG_W + SECURITY_BIT;

wire maint_read_unqual = 
   (maint_req_opcode == 4'b1100);
wire maint_write_unqual = 
   (maint_req_opcode == 4'b1110);
wire maint_recall_unqual =
   (maint_req_opcode == 4'b0101);

wire true_hit;
wire true_hit_upgrade;
wire [N_WAYS-1:0] cache_way_final_p2 = 
   (true_hit || true_hit_upgrade) ? cache_hit_way_p2 : cache_alloc_way_p2;

wire [SET_PER_BANK_W-1:0] op_p2_set;
wire [MAX_TAG_BANKS_W-1:0] op_p2_bnk;
wire [TAG_W-1:0] op_p2_tag_pre_security;
fv_ccp_tagpipe_gen_index #(
   .N_SETS(N_SETS),
   .N_TAG_BANKS(N_TAG_BANKS),
   .ADDRESS_W(ADDRESS_W),
   .BNK_W(BNK_W),
   .TAG_W(TAG_W),
   .CACHE_LINE_OFFSET_W(CACHE_LINE_OFFSET_W),
   .MAX_TAG_BANKS(MAX_TAG_BANKS)
)fv_ccp_gen_index_op(
   .address_in(ctrl_op_address_p2),
   .bnk_num(op_p2_bnk),
   .set(op_p2_set),
   .tag(op_p2_tag_pre_security)
);

wire [TAG_W+SECURITY_BIT-1:0] op_p2_tag;
generate 
   if(SECURITY_BIT)
      assign op_p2_tag = {ctrl_op_security_p2, op_p2_tag_pre_security};
   else
      assign op_p2_tag = {op_p2_tag_pre_security};
endgenerate

wire my_op_p2_set_bnk = 
   (op_p2_set == my_set) && (op_p2_bnk == my_bnk);

wire [SET_PER_BANK_W-1:0] fill_state_set;
wire [MAX_TAG_BANKS_W-1:0] fill_state_bnk;
wire [TAG_W-1:0] fill_state_tag_pre_security;
fv_ccp_tagpipe_gen_index #(
   .N_SETS(N_SETS),
   .N_TAG_BANKS(N_TAG_BANKS),
   .ADDRESS_W(ADDRESS_W),
   .BNK_W(BNK_W),
   .TAG_W(TAG_W),
   .CACHE_LINE_OFFSET_W(CACHE_LINE_OFFSET_W),
   .MAX_TAG_BANKS(MAX_TAG_BANKS)
)fv_ccp_gen_index_state(
   .address_in(ctrl_fill_address),
   .bnk_num(fill_state_bnk),
   .set(fill_state_set),
   .tag(fill_state_tag_pre_security)
);

wire [TAG_W+SECURITY_BIT-1:0] fill_state_tag;
generate 
   if(SECURITY_BIT)
      assign fill_state_tag = {ctrl_fill_security, fill_state_tag_pre_security};
   else
      assign fill_state_tag = {fill_state_tag_pre_security};
endgenerate

wire my_fill_state_set_bnk = 
   (fill_state_set == my_set) && (fill_state_bnk == my_bnk);

wire [SET_PER_BANK_W-1:0] fill_data_set;
wire [MAX_TAG_BANKS_W-1:0] fill_data_bnk;
wire [TAG_W-1:0] fill_data_tag_pre_security;
fv_ccp_tagpipe_gen_index #(
   .N_SETS(N_SETS),
   .N_TAG_BANKS(N_TAG_BANKS),
   .ADDRESS_W(ADDRESS_W),
   .BNK_W(BNK_W),
   .TAG_W(TAG_W),
   .CACHE_LINE_OFFSET_W(CACHE_LINE_OFFSET_W),
   .MAX_TAG_BANKS(MAX_TAG_BANKS)
)fv_ccp_gen_index_data(
   .address_in(ctrl_fill_data_address),
   .bnk_num(fill_data_bnk),
   .set(fill_data_set),
   .tag(fill_data_tag_pre_security)
);

wire my_fill_data_set_bnk =
   (fill_data_set == my_set) && (fill_data_bnk == my_bnk);

wire my_ctrl_op_allocate_p2 =
   (cache_valid_p2 &&
    ctrl_op_allocate_p2 && 
    !cache_nack_uce_p2 &&
    !cache_nack_p2 &&
    !cache_nack_ce_p2 &&
    !cache_nack_no_allocate_p2 &&
    my_op_p2_set_bnk);

assign my_fill_needed =
   (true_hit) ? 
      my_ctrl_op_allocate_p2 :
      (my_ctrl_op_allocate_p2 &&
       (!ctrl_op_tag_state_update_p2 || (ctrl_op_state_p2 == 'd0)));

reg [N_WAYS-1:0] fill_state_pending;
reg [N_WAYS-1:0] fill_data_pending;

wire set_fill_state_pending = my_fill_needed;
wire [WAY_POINTER_W-1:0] set_fill_way = cache_way_final_p2;

wire [N_WAYS-1:0] set_fill_state_pending_vec = 
   (set_fill_state_pending << set_fill_way);

wire clr_fill_state_pending =
   (ctrl_fill_valid && cache_fill_ready) && my_fill_state_set_bnk;

wire [N_WAYS-1:0] clr_fill_state_pending_vec =
   (clr_fill_state_pending << ctrl_fill_way_num);

wire [N_WAYS-1:0] next_fill_state_pending =
   ((fill_state_pending & ~clr_fill_state_pending_vec) | 
    set_fill_state_pending_vec);

wire set_fill_data_pending = set_fill_state_pending;

wire [N_WAYS-1:0] set_fill_data_pending_vec = 
   (set_fill_data_pending << set_fill_way);

// clr_fill_data_pending to represent that fill_data opeartion has started 
wire clr_fill_data_pending =
   ctrl_fill_data_valid && 
   cache_fill_data_ready &&
   ctrl_fill_data_valid_last_beat &&
   my_fill_data_set_bnk;

// clr_fill_data_pending_vec to represent the way for which fill has started
wire [N_WAYS-1:0] clr_fill_data_pending_vec = 
   (clr_fill_data_pending << ctrl_fill_data_way_num);

// next_fill_data_pending to represent the ways for which fill_data is about
// to be pending in next cycle
wire [N_WAYS-1:0] next_fill_data_pending =
   ((fill_data_pending & ~clr_fill_data_pending_vec) | 
    set_fill_data_pending_vec);

always @(posedge clk or negedge reset_n) begin
   if(!reset_n) begin
      fill_state_pending <= 'd0;
      fill_data_pending <= 'd0;
   end
   else begin
      fill_state_pending <= next_fill_state_pending; 
      fill_data_pending <= next_fill_data_pending;
   end
end

wire [N_WAYS-1:0] ctrl_fill_way_num_vec = 
   (1'b1 << ctrl_fill_way_num);

// Constraint: ctrl_fill_way_num can not be without state pending
ctrl2cache_ctrl_fill_way_num_from_state_pending: assert property(
   @(posedge clk) disable iff (!reset_n)
   (ctrl_fill_valid && my_fill_state_set_bnk)
   |->
   ((ctrl_fill_way_num_vec & ~fill_state_pending) == 'd0)
);

wire [N_WAYS-1:0] ctrl_fill_data_way_num_vec = 
   (1'b1 << ctrl_fill_data_way_num);

// Constraint: ctrl_fill_way_num can not be without state pending
ctrl2cache_ctrl_fill_data_way_num_from_data_pending: assert property(
   @(posedge clk) disable iff (!reset_n)
   (ctrl_fill_data_valid && my_fill_data_set_bnk)
   |->
   ((ctrl_fill_data_way_num_vec & ~fill_data_pending) == 'd0)
);

// fill_done_pending to represent that a cache fill done is pending for a busy
// fill_id
// fill_done_id_pending to represent that a cache fill done_id is pending for a
// busy fill_id
reg [N_WAYS-1:0] fill_done_pending;
reg [(TABLE_ENTRIES_W*N_WAYS)-1:0] fill_done_id_pending;

// set_fill_done_pending to represent that a fill done is pending for my_set
wire set_fill_done_pending = clr_fill_data_pending;

// set_fill_done_pending_vec the way and id for which fill_done is pending 
wire [N_WAYS-1:0] set_fill_done_pending_vec =
   (set_fill_done_pending << ctrl_fill_data_way_num);

always @(posedge clk) begin
   if(set_fill_done_pending) begin
      fill_done_id_pending[(ctrl_fill_data_way_num*TABLE_ENTRIES_W)+:
                           TABLE_ENTRIES_W] <= ctrl_fill_data_id;
   end
end

// clr_fill_done_pending_vec to represent the way and fill_id  for which
// fill_done_id has asserted
reg [N_WAYS-1:0] clr_fill_done_pending_vec;
always @(*) begin
   clr_fill_done_pending_vec = 'd0;
   if(cache_fill_done) begin
      for (int i=0; i<N_WAYS; i++) begin
         if(fill_done_pending[i] && 
            (fill_done_id_pending[(i*TABLE_ENTRIES_W)+:TABLE_ENTRIES_W] == 
             cache_fill_done_id)) begin
            clr_fill_done_pending_vec[i] = 1'b1;
         end
      end
   end
end

// next_fill_done_pending to represent the ways for which fill_done_id is about
// to be pending in next cycle
wire [N_WAYS-1:0] next_fill_done_pending =
   ((fill_done_pending & ~clr_fill_done_pending_vec) |
    set_fill_done_pending_vec);

always @(posedge clk or negedge reset_n) begin
   if(!reset_n) begin
      fill_done_pending <= 'd0;
   end
   else begin
      fill_done_pending <= next_fill_done_pending; 
   end
end

// Checker that way and id for which pending is set should not be already used
// in any other fill or fill done pending
chk_no_same_way_set_if_state_already_pending: assert property(
   @(posedge clk) disable iff (!reset_n)
   ((set_fill_state_pending_vec & fill_state_pending) == 'd0)
);

chk_no_same_way_set_if_data_already_pending: assert property(
   @(posedge clk) disable iff (!reset_n)
   ((set_fill_data_pending_vec & fill_data_pending) == 'd0)
);

chk_no_same_way_set_if_done_already_pending: assert property(
   @(posedge clk) disable iff (!reset_n)
   ((set_fill_done_pending_vec & fill_done_pending) == 'd0)
);

// Checker that way and id for which clear is set should not be already cleared
chk_no_same_way_clr_if_state_already_cleared: assert property(
   @(posedge clk) disable iff (!reset_n)
   ((~fill_state_pending & clr_fill_state_pending_vec) == 'd0)
);

chk_no_same_way_clr_if_data_already_cleared: assert property(
   @(posedge clk) disable iff (!reset_n)
   ((~fill_data_pending & clr_fill_data_pending_vec) == 'd0)
);

chk_no_same_way_clr_if_done_already_cleared: assert property(
   @(posedge clk) disable iff (!reset_n)
   ((~fill_done_pending & clr_fill_done_pending_vec) == 'd0)
);

reg [(N_WAYS*TAG_FINAL_W)-1:0] my_shadow_tag;
reg [(N_WAYS*CACHE_STATE_W)-1:0] my_state;
reg [(N_WAYS*TAG_FINAL_W)-1:0] my_tag;
reg [TAG_FINAL_W-1:0] maint_tag;
reg [CACHE_STATE_W-1:0] maint_state;
reg maint_nru;
reg [N_WAYS-1:0] fill_despite_hit;

always @(*) begin
   maint_tag = 'd0;
   maint_state = 'd0;
   maint_nru = 'd0;
   if (maint_req_word == 'd0) begin
      maint_tag = 
         maint_req_data[(ERR_BIT+NRU_IN_TAG_MEM+CACHE_STATE_W)+:TAG_FINAL_W];
      maint_state = 
         maint_req_data[(ERR_BIT+NRU_IN_TAG_MEM) +: CACHE_STATE_W];
      // Valid only if NRU_IN_TAG_MEM is 1
      maint_nru = 
         (NRU_IN_TAG_MEM == 'd1) &&
         maint_req_data[ERR_BIT];
   end
end

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      my_tag <= 'd0;
      my_state <= 'd0;
      fill_despite_hit <= 'd0;
   end else begin
      if (my_fill_needed) begin
         my_shadow_tag[(TAG_FINAL_W*cache_way_final_p2)+:TAG_FINAL_W] <= op_p2_tag;
         fill_despite_hit[cache_way_final_p2] <= true_hit;
      end

      if (ctrl_op_allocate_p2 && ctrl_op_tag_state_update_p2 && 
         my_op_p2_set_bnk) begin
         my_tag[(TAG_FINAL_W*cache_way_final_p2)+:TAG_FINAL_W] <= op_p2_tag;
      end
      
      if (ctrl_op_tag_state_update_p2 && my_op_p2_set_bnk) begin
         if (ctrl_op_allocate_p2 && 
             !(ctrl_op_setway_debug_p2 && maint_recall_unqual)) begin
             my_state[(CACHE_STATE_W*cache_way_final_p2)+:CACHE_STATE_W] <=
             ctrl_op_state_p2;
         end 
         else if(!(ctrl_op_setway_debug_p2 && maint_recall_unqual)) begin
            my_state[(CACHE_STATE_W*cache_way_final_p2)+:CACHE_STATE_W] <= ctrl_op_state_p2;
         end
         else begin
            my_state[(CACHE_STATE_W*maint_req_way)+:CACHE_STATE_W] <= ctrl_op_state_p2;
         end
      end

      if (clr_fill_state_pending) begin
         my_tag[(TAG_FINAL_W*ctrl_fill_way_num)+:TAG_FINAL_W] <= 
            fill_state_tag;
         my_state[(CACHE_STATE_W*ctrl_fill_way_num)+:CACHE_STATE_W] <= 
            ctrl_fill_state;
      end

      if (!maint_req_array_sel && (maint_req_opcode == 4'b1110) &&
          ctrl_op_setway_debug_p2 && cache_valid_p2 && my_op_p2_set_bnk &&
          (maint_req_word == 'd0)) begin
         my_state[(CACHE_STATE_W*maint_req_way)+:CACHE_STATE_W] <= maint_state;
         my_tag[(TAG_FINAL_W*maint_req_way)+:TAG_FINAL_W] <= maint_tag;
      end
   end
end

// constraint: ctrl_fill_way address as per my_shadow_tag entries
ctrl2cache_ctrl_fill_way_address_from_my_shadow_tag: assert property(
   @(posedge clk) disable iff (!reset_n)
   (ctrl_fill_valid && my_fill_state_set_bnk)
   |->
   (fill_state_tag == my_shadow_tag[(TAG_FINAL_W*ctrl_fill_way_num)+:TAG_FINAL_W])
);

// my_shadow_tag_valid to show valid shadow entry for way numbers
wire [N_WAYS-1:0] my_shadow_tag_valid = 
   //fill_state_pending;
   (fill_state_pending | fill_data_pending | fill_done_pending);

// my_busy_vec_in_current_cycle: ways pending included the one which got 
// pending in current cycle 
wire [N_WAYS-1:0] my_busy_vec =
   (my_shadow_tag_valid/* | set_fill_state_pending_vec*/);

ctrl2cache_ways_busy_vec_as_per_pending_and_set_pending_ways: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_valid_p2 && my_op_p2_set_bnk)
   |->
   (ctrl_op_ways_busy_vec_p2 == 
    my_shadow_tag_valid)
);

ctrl2cache_ways_stale_vec_as_per_true_misses: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_valid_p2 && my_op_p2_set_bnk)
   |->
   (ctrl_op_ways_stale_vec_p2 == 
    (my_shadow_tag_valid & ~fill_despite_hit))
);

// my_current_state to show crrent cache state
// my_cache_way_num to show way number for a hit where tag is present
reg [N_WAYS-1:0] my_hit_vec_in_tag;
reg [N_WAYS-1:0] my_hit_vec_in_shadow_tag;
reg [N_WAYS-1:0] maint_hit_vec_in_tag;
reg [N_WAYS-1:0] maint_hit_vec_in_shadow_tag;

always @(*) begin
   my_hit_vec_in_tag = 'd0;
   my_hit_vec_in_shadow_tag = 'd0;
   maint_hit_vec_in_tag = 'd0;
   maint_hit_vec_in_shadow_tag = 'd0;
   for (int i=0; i<N_WAYS; i++) begin
      if((op_p2_tag == my_tag[(TAG_FINAL_W*i)+:TAG_FINAL_W]) && 
         (my_state[(CACHE_STATE_W*i)+:CACHE_STATE_W] != 'd0) &&
         my_op_p2_set_bnk) begin
         my_hit_vec_in_tag[i] = 1'b1;
      end
      if((op_p2_tag == my_shadow_tag[(TAG_FINAL_W*i)+:TAG_FINAL_W]) && my_shadow_tag_valid[i] &&
         (op_p2_set == my_set) && (op_p2_bnk == my_bnk)) begin
         my_hit_vec_in_shadow_tag[i] = 1'b1;
      end

      if((maint_tag == my_tag[(TAG_FINAL_W*i)+:TAG_FINAL_W]) &&
         (my_state[(CACHE_STATE_W*i)+:CACHE_STATE_W] != 'd0) &&
          my_op_p2_set_bnk) begin
         maint_hit_vec_in_tag[i] = 1'b1;
      end

      if((maint_tag == my_shadow_tag[(TAG_FINAL_W*i)+:TAG_FINAL_W]) && my_shadow_tag_valid[i] &&
         my_op_p2_set_bnk) begin
         maint_hit_vec_in_shadow_tag[i] = 1'b1;
      end
   end
end

wire [N_WAYS-1:0] true_miss_vec = 
   ~my_hit_vec_in_tag & ~my_hit_vec_in_shadow_tag;
wire [N_WAYS-1:0] true_hit_vec =
   my_hit_vec_in_tag & ~my_shadow_tag_valid;
wire [N_WAYS-1:0] false_miss_vec =
   (~my_hit_vec_in_tag & my_hit_vec_in_shadow_tag & ~fill_despite_hit) |
   (my_hit_vec_in_tag & my_hit_vec_in_shadow_tag & ~fill_state_pending & ~fill_despite_hit);
wire [N_WAYS-1:0] false_hit_vec = 
   my_hit_vec_in_tag & my_shadow_tag_valid & ~my_hit_vec_in_shadow_tag & 
   ~fill_despite_hit;
wire [N_WAYS-1:0] false_miss_special_vec = 
   ~my_hit_vec_in_tag & my_hit_vec_in_shadow_tag & fill_despite_hit;
wire [N_WAYS-1:0] true_hit_upgrade_vec = 
   my_hit_vec_in_tag & my_hit_vec_in_shadow_tag & fill_despite_hit;
wire [N_WAYS-1:0] bad_state_1_vec =
   my_hit_vec_in_tag & my_shadow_tag_valid & ~my_hit_vec_in_shadow_tag &
   fill_despite_hit;
wire [N_WAYS-1:0] bad_state_2_vec = 
   my_hit_vec_in_tag & my_hit_vec_in_shadow_tag & fill_state_pending & ~fill_despite_hit;


asrt_bad_state_1_never: `nassert(
   cache_valid_p2
   |->
   (bad_state_1_vec == 'b0)
);

asrt_bad_state_2_never: `nassert(
   cache_valid_p2
   |->
   (bad_state_2_vec == 'b0)
);

// Other bad criterion across ways:
// 1. (true hit | hit in shadow) 
wire [N_WAYS-1:0] true_hit_OR_shadow_hit_vec = 
   true_hit_vec | my_hit_vec_in_shadow_tag;

asrt_true_hit_OR_shadow_hit_vec: `nassert(
   cache_valid_p2
   |->
   $onehot0(true_hit_OR_shadow_hit_vec)
);

wire [N_WAYS-1:0] false_hit_or_true_miss_vec = 
   false_hit_vec | true_miss_vec;

wire true_miss = &true_miss_vec;

// It is true hit if true_hit_vec is 1 at some position, and 
// false_hit_or_true_miss_vec is 1 at remaining positions
assign true_hit = 
   |true_hit_vec && 
   // TODO: Note: true_hit_vec and false_hit_or_true_miss_vec can't be 1
   // at same position (TODO: Prove it)
   ((false_hit_or_true_miss_vec | true_hit_vec) == {N_WAYS{1'b1}});
assign true_hit_upgrade =
   |true_hit_upgrade_vec &&
   // TODO: Note: true_hit_upgrade_vec and false_hit_or_true_miss_vec can't be 1
   // at same position (TODO: Prove it)
   ((false_hit_or_true_miss_vec | true_hit_upgrade_vec) == {N_WAYS{1'b1}});
wire false_miss =
   |false_miss_vec &&
   ((false_hit_or_true_miss_vec | false_miss_vec) == {N_WAYS{1'b1}});
wire false_miss_special =
   |false_miss_special_vec &&
   ((false_hit_or_true_miss_vec | false_miss_special_vec) == {N_WAYS{1'b1}});

// Ignoring above and bad combinations, rest is false hit

// Never issue allocate when if: true_hit_upgrade OR false_miss OR 
// false_miss_special is 1
// Constraints on allocate, tag state update, read/write
// 1. Allocate:
//    Allocate is 0 for true_hit_upgrade OR false_miss OR false_miss_special
//    Note: It can be 1 for true hit and true miss
// 2. tag state update
//    Is 0 at false_miss or false_miss_special
//    Can be 1 at true miss iff allocate is 1 
//      -- Is 0 at true miss if allocate is 0
//    Can be 1 at true hit
//    In case of true_hit_upgrade - can be 1 iff corresponding fill is still pending
wire allocate_0_condition = 
   true_hit_upgrade || false_miss || false_miss_special;
ctrl2cache_allocate_0_conds: `nassert(
   (cache_valid_p2 && allocate_0_condition)
   |->
   !ctrl_op_allocate_p2
);

wire tag_update_0_condition = 
   false_miss || false_miss_special;
ctrl2cache_tag_update_0_conds: `nassert(
   (cache_valid_p2 && tag_update_0_condition)
   |->
   !ctrl_op_tag_state_update_p2
);

ctrl2cache_tag_update_0_at_true_miss_if_no_allocate: `nassert(
   (cache_valid_p2 && true_miss && !ctrl_op_allocate_p2 && my_op_p2_set_bnk)
   |->
   !ctrl_op_tag_state_update_p2
);

wire false_hit = 
   !true_miss && !true_hit && !true_hit_upgrade && 
   !false_miss && !false_miss_special;

ctrl2cache_tag_update_0_at_false_hit_if_no_allocate: `nassert(
   (cache_valid_p2 && false_hit && !ctrl_op_allocate_p2)
   |->
   !ctrl_op_tag_state_update_p2
);

ctrl2cache_tag_update_0_at_true_hit_allocate_OC: `nassert(
   (cache_valid_p2 && true_hit && ctrl_op_allocate_p2)
   |->
   !ctrl_op_tag_state_update_p2
);

// If a way is under true hit upgrade, then snoop and fill can't happen
// together
ctrl2cache_tag_update_and_fill_never_together_for_true_hit_upgrade: `nassert(
   (cache_valid_p2 && true_hit_upgrade && my_op_p2_set_bnk &&
    ctrl_op_tag_state_update_p2 &&
    ctrl_fill_valid && my_fill_state_set_bnk)
   |->
   (cache_way_final_p2 != ctrl_fill_way_num)
);

ctrl2cache_rp_update_and_fill_never_together_for_true_hit_upgrade: `nassert(
   (cache_valid_p2 && true_hit_upgrade && my_op_p2_set_bnk &&
    ctrl_op_rp_update_p2 &&
    ctrl_fill_valid && my_fill_state_set_bnk)
   |->
   (cache_way_final_p2 != ctrl_fill_way_num)
);

// Checkers on various ports
//|    output reg [1:0] cache_op_ready_p0, -- Need FP
//|    output reg [1:0] cache_alloc_way_vec_p2, - DONE
//|    output reg [1:0] cache_hit_way_vec_p2, - DONE
//|    output reg cache_valid_p2, -- DONE
//|    output reg [1:0] cache_current_state_p2, -- DONE
//|    output reg cache_evict_valid_p2, -- DONE
//|    output reg [31:0] cache_evict_address_p2, -- DONE
//|    output reg cache_evict_security_p2, -- DONE
//|    output reg [1:0] cache_evict_state_p2, -- DONE
//|    output reg cache_nack_uce_p2,
//|    output reg cache_nack_p2,
//|    output reg cache_nack_ce_p2,
//|    output reg cache_nack_no_allocate_p2, -- DONE
//|    output reg cache_fill_ready, -- Need FP
//|    output reg correctible_error_valid,
//|    output reg [19:0] correctible_error_entry,
//|    output reg [5:0] correctible_error_way,
//|    output reg correctible_error_word,
//|    output reg correctible_error_double_error,
//|    output reg uncorrectible_error_valid,
//|    output reg [19:0] uncorrectible_error_entry,
//|    output reg [5:0] uncorrectible_error_way,
//|    output reg uncorrectible_error_double_error,
//|    output reg datapipe_ctrl_op_valid,
//|    output reg [5:0] datapipe_ctrl_op_data,
//|    output reg wr_only_bypass,
//|    output reg wr_only_bypass_port,
//|    output reg wr_only_bypass_valid,
//|    output reg [31:0] ctrl_op_address_p2,
//|    output reg evict_port_valid0,
//|    output reg [1:0] evict_port_control0,
//|    output reg rdrsp_port_valid0,
//|    output reg [1:0] rdrsp_port_control0,
//|    output reg evict_port_valid1,
//|    output reg [1:0] evict_port_control1,
//|    output reg rdrsp_port_valid1,
//|    output reg [1:0] rdrsp_port_control1,
//|    output reg init_done,
//|    output reg maint_active,
//|    output reg [31:0] maint_read_data,
//|    output reg maint_read_data_en,
//|    output reg tag_mem0_reinit,
//|    output reg [8:0] tag_mem0_address, --- Not needed
//|    output reg tag_mem0_chip_en, --- Not needed
//|    output reg tag_mem0_write_en, --- Not needed
//|    output reg [1:0] tag_mem0_write_en_mask, --- Not needed
//|    output reg [49:0] tag_mem0_data_in, --- Not needed
//|    output reg tag_mem1_reinit,
//|    output reg [8:0] tag_mem1_address --- Not needed,
//|    output reg tag_mem1_chip_en, --- Not needed
//|    output reg tag_mem1_write_en, --- Not needed
//|    output reg [1:0] tag_mem1_write_en_mask, --- Not needed
//|    output reg [49:0] tag_mem1_data_in --- Not needed

reg [CACHE_STATE_W-1:0] my_hit_state;
reg [N_WAYS-1:0] empty_way_vec;
always @(*) begin
   my_hit_state = 'd0;
   empty_way_vec = 'd0;
   for (int i=0; i<N_WAYS; i++) begin
      if(my_state[(CACHE_STATE_W*i)+:CACHE_STATE_W] == 'd0)
         empty_way_vec[i] = 'd1;

      if(true_hit_vec[i] || true_hit_upgrade_vec[i])
         my_hit_state = my_state[(CACHE_STATE_W*i)+:CACHE_STATE_W];
   end
end

asrt_cache_current_state_p2_true_hit_or_true_hit_upgrade_no_maint: `nassert(
   (cache_valid_p2 && my_op_p2_set_bnk && 
    !ctrl_op_setway_debug_p2 &&
    (true_hit || true_hit_upgrade))
   |->
   (cache_current_state_p2 == my_hit_state)
);

asrt_cache_current_state_p2_others_no_maint: `nassert(
   (cache_valid_p2 && my_op_p2_set_bnk && 
    !ctrl_op_setway_debug_p2 &&
    !(true_hit || true_hit_upgrade))
   |->
   (cache_current_state_p2 == 'b0)
);

asrt_cache_current_state_p2_at_maint_non_recall: `nassert(
   (cache_valid_p2 && my_op_p2_set_bnk && 
    ctrl_op_setway_debug_p2 && !maint_recall_unqual)
   |->
   (cache_current_state_p2 == 'b0)
);

wire [CACHE_STATE_W-1:0] maint_recall_state_expected = 
   my_state[(CACHE_STATE_W*maint_req_way)+:CACHE_STATE_W];

asrt_cache_current_state_p2_at_maint_recall: `nassert(
   (cache_valid_p2 && my_op_p2_set_bnk && 
    ctrl_op_setway_debug_p2 && maint_recall_unqual)
   |->
   (cache_current_state_p2 == maint_recall_state_expected)
);

// Note: There are following checkers on cache_alloc_way_vec_p2
// 1. cache_alloc_way_vec_p2 should be onehot0
// 2. An already allocated way on which fill is pending should not be
//    reallocated - this is covered by:
//    chk_no_same_way_set_if_state_already_pending
// 3. Correctness aspect (as per replacement policy) would be checked by
//    LRU policy checker
// 4. If a way is free, then it should be allocated first (i.e. no eviction
//    should happen). This is covered by following two checkers:
//   a. asrt_cache_evict_valid_p2_0_if_empty_ways
//   b. asrt_evict_iff_allocated_way_has_valid_state_for_real_alloc
asrt_cache_alloc_way_vec_p2_is_onehot0: `nassert(
   (cache_valid_p2 && my_op_p2_set_bnk)
   |->
   $onehot0(cache_alloc_way_vec_p2)
);

asrt_cache_hit_way_vec_p2_is_onehot0: `nassert(
   (cache_valid_p2 && my_op_p2_set_bnk)
   |->
   $onehot0(cache_hit_way_vec_p2)
);

asrt_cache_hit_way_vec_is_true_hit_or_upgrade_vec: `nassert(
   (cache_valid_p2 && my_op_p2_set_bnk)
   |->
   (cache_hit_way_vec_p2 ==
    (true_hit_vec | true_hit_upgrade_vec))
);

asrt_cache_nack_no_allocate_p2_matches_shadow_valid_AND: `nassert(
   (cache_valid_p2 && my_op_p2_set_bnk)
   |->
   (cache_nack_no_allocate_p2 == (&my_shadow_tag_valid))
);

// Make sure that cache_nack_no_allocate_p2 would never be asserted
// for true hit case
asrt_cache_nack_no_allocate_p2_0_for_allocate_during_true_hit: `nassert(
   (cache_valid_p2 && my_op_p2_set_bnk && true_hit && ctrl_op_allocate_p2)
   |->
   !cache_nack_no_allocate_p2
);

//|    output reg cache_evict_valid_p2,
//|    output reg [31:0] cache_evict_address_p2,
//|    output reg cache_evict_security_p2,
//|    output reg [1:0] cache_evict_state_p2,

asrt_cache_evict_valid_p2_0_if_no_cache_valid: `nassert(
   !cache_valid_p2
   |->
   !cache_evict_valid_p2
);

asrt_cache_evict_valid_p2_0_if_no_allocate: `nassert(
   !ctrl_op_allocate_p2
   |->
   !cache_evict_valid_p2
);

asrt_cache_evict_valid_p2_0_if_empty_ways: `nassert(
   (cache_valid_p2 && my_op_p2_set_bnk && ctrl_op_allocate_p2 &&
    |(empty_way_vec & ~my_shadow_tag_valid))
   |->
   !cache_evict_valid_p2 
);

wire [CACHE_STATE_W-1:0] orig_state_in_alloc_way =
   my_state[(CACHE_STATE_W*cache_alloc_way_p2) +: CACHE_STATE_W];
asrt_evict_iff_allocated_way_has_valid_state_for_real_alloc: `nassert(
   (cache_valid_p2 && my_op_p2_set_bnk && !true_hit && my_ctrl_op_allocate_p2)
   |->
   ((|orig_state_in_alloc_way) == cache_evict_valid_p2)
);

wire [SET_PER_BANK_W-1:0] evict_p2_set;
wire [MAX_TAG_BANKS_W-1:0] evict_p2_bnk;
wire [TAG_W-1:0] evict_p2_tag_pre_security;
fv_ccp_tagpipe_gen_index #(
   .N_SETS(N_SETS),
   .N_TAG_BANKS(N_TAG_BANKS),
   .ADDRESS_W(ADDRESS_W),
   .BNK_W(BNK_W),
   .TAG_W(TAG_W),
   .CACHE_LINE_OFFSET_W(CACHE_LINE_OFFSET_W),
   .MAX_TAG_BANKS(MAX_TAG_BANKS)
)fv_ccp_gen_index_evict(
   .address_in(cache_evict_address_p2),
   .bnk_num(evict_p2_bnk),
   .set(evict_p2_set),
   .tag(evict_p2_tag_pre_security)
);

wire [TAG_W+SECURITY_BIT-1:0] evict_p2_tag;
generate 
   if(SECURITY_BIT)
      assign evict_p2_tag = 
         {cache_evict_security_p2, evict_p2_tag_pre_security};
   else
      assign evict_p2_tag = {evict_p2_tag_pre_security};
endgenerate

wire my_evict_set_bnk = 
   (evict_p2_set == my_set) && (evict_p2_bnk == my_bnk);

// Following checkers hold true even for true hit case (even though 
// cache_evict_valid_p2 may be asserted incorrectly)
asrt_cache_evict_set_bnk_matches_expected: `nassert(
   cache_evict_valid_p2
   |->
   (my_evict_set_bnk == my_op_p2_set_bnk)
);

asrt_cache_evict_tag_matches_expected: `nassert(
   (cache_evict_valid_p2 && my_op_p2_set_bnk)
   |->
   (evict_p2_tag == my_tag[(TAG_FINAL_W*cache_alloc_way_p2)+:TAG_FINAL_W])
);

asrt_cache_evict_state_as_per_alloc_way: `nassert(
   (cache_evict_valid_p2 && my_op_p2_set_bnk)
   |->
   (cache_evict_state_p2 == 
    my_state[(CACHE_STATE_W*cache_alloc_way_p2)+:CACHE_STATE_W])
);

// Maint tag write should never hit on shadow
wire [N_WAYS-1:0] maint_req_way_vec = (1 << maint_req_way);
ctrl2cache_maint_write_never_on_valid_shadow: `nassert(
   (ctrl_op_setway_debug_p2 && !maint_req_array_sel && 
    my_op_p2_set_bnk && maint_write_unqual)
   |->
   ((my_shadow_tag_valid & maint_req_way_vec) == 'd0)
);

ctrl2cache_maint_write_never_creates_multihit: `nassert(
   (ctrl_op_setway_debug_p2 && !maint_req_array_sel && 
    my_op_p2_set_bnk && maint_write_unqual && 
    (maint_state != 'd0) && |maint_hit_vec_in_tag)
   |->
   (maint_req_way_vec == maint_hit_vec_in_tag)
);

ctrl2cache_maint_write_never_hits_in_shadow: `nassert(
   (ctrl_op_setway_debug_p2 && !maint_req_array_sel && 
    my_op_p2_set_bnk && maint_write_unqual)
   |->
   (maint_hit_vec_in_shadow_tag == 'd0)
);

ctrl2cache_maint_recall_and_tag_update_never_on_shadow: `nassert(
   (ctrl_op_setway_debug_p2 && !maint_req_array_sel && 
    my_op_p2_set_bnk && maint_recall_unqual &&
    (ctrl_op_tag_state_update_p2 || ctrl_op_rp_update_p2))
   |->
   (my_shadow_tag_valid[maint_req_way] == 1'b0)
);

wire [TAG_FINAL_W-1:0] maint_read_data_tag_expected = 
   my_tag[(TAG_FINAL_W*maint_req_way)+:TAG_FINAL_W];
wire [CACHE_STATE_W-1:0] maint_read_data_state_expected =
   my_state[(CACHE_STATE_W*maint_req_way)+:CACHE_STATE_W];

asrt_maint_rd_for_word_zero_state_part: `nassert(
   (ctrl_op_setway_debug_p2 && !maint_req_array_sel &&
    my_op_p2_set_bnk && maint_read_unqual &&
    (maint_req_word == 'd0))
   |->
   (maint_read_data[(ERR_BIT+NRU_IN_TAG_MEM)+:CACHE_STATE_W] == 
    maint_read_data_state_expected)
);

// Compare tag if state is non-zero
asrt_maint_rd_for_word_zero_tag_part: `nassert(
   (ctrl_op_setway_debug_p2 && !maint_req_array_sel &&
    my_op_p2_set_bnk && maint_read_unqual &&
    (maint_req_word == 'd0) &&
    (maint_read_data_state_expected != 'b0))
   |->
   (maint_read_data[31:CACHE_STATE_W+ERR_BIT+NRU_IN_TAG_MEM] ==
    maint_read_data_tag_expected)
);

wire [(N_WAYS*TAG_PER_WAY_DATA_W)-1:0] my_set_bnk_mem;
fv_ccp_tag_bank_model #(
   .N_SETS(N_SETS),
   .SET_W(SET_W),
   .N_TAG_BANKS(N_TAG_BANKS),
   .BNK_W(BNK_W),
   .SET_PER_BANK(SET_PER_BANK),
   .SET_PER_BANK_W(SET_PER_BANK_W),
   .N_WAYS(N_WAYS),
   .WAY_POINTER_W(WAY_POINTER_W),
   .MAX_TAG_BANKS_W(MAX_TAG_BANKS_W),
   .TAG_PER_WAY_DATA_W(TAG_PER_WAY_DATA_W)
) fv_ccp_tag_bank_model (
   .clk(clk),
   .reset_n(reset_n),
   .my_set(my_set),
   .my_bnk(my_bnk),
   .tag_mem_chip_en(tag_mem_chip_en),
   .tag_mem_write_en(tag_mem_write_en),
   .tag_mem_write_en_mask(tag_mem_write_en_mask),
   .tag_mem_address(tag_mem_address),
   .tag_mem_data_in(tag_mem_data_in),
   .tag_mem_data_out(tag_mem_data_out),
   .my_set_bnk_mem(my_set_bnk_mem)
);

`ifdef FORMAL
   fv_tag_mem_reset_abstraction #(
      .N_WAYS(N_WAYS),
      .TAG_PER_WAY_DATA_W(TAG_PER_WAY_DATA_W),
      .TAG_FINAL_W(TAG_FINAL_W),
      .CACHE_STATE_W(CACHE_STATE_W),
      .ERR_BIT(ERR_BIT),
      .NRU_IN_TAG_MEM(NRU_IN_TAG_MEM)
   ) fv_tag_mem_reset_abstraction (
      .clk(clk),
      .reset_n(reset_n),
      .oor_f(oor_f),
      .my_set_bnk_mem(my_set_bnk_mem),
      .my_tag(my_tag),
      .my_state(my_state)
   );
`endif

endmodule
