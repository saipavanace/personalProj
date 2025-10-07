module fv_ccp_write_cons #(
   parameter N_SETS = 1024,
   parameter SET_W = $clog2(N_SETS),
   parameter N_TAG_BANKS = 2,
   parameter CACHE_LINE_OFFSET_W = 6,
   parameter CACHE_STATE_W = 2,
   parameter DATA_W = 129,
   parameter BYTE_EN_W = ((DATA_W-1)/8),
   parameter ADDRESS_W = 40,
   parameter BURST_LEN_W = 2,
   parameter BURST_LEN = (2**BURST_LEN_W),
   parameter N_WAYS =4,
   parameter BNK_W = $clog2(N_TAG_BANKS),
   parameter SET_PER_BANK = N_SETS/N_TAG_BANKS,
   parameter SET_PER_BANK_W = $clog2(SET_PER_BANK),
   parameter TAG_W = ADDRESS_W-(BNK_W+CACHE_LINE_OFFSET_W+SET_PER_BANK_W),
   parameter WAY_POINTER_W = $clog2(N_WAYS)
)(
   input clk,
   input reset_n,
   input [ADDRESS_W-1:0] ctrl_op_address_p2,
   input ctrl_op_allocate_p2,
   input ctrl_op_read_data_p2,
   input ctrl_op_write_data_p2,
   input ctrl_op_port_sel_p2,
   input ctrl_op_bypass_p2,
   input [BURST_LEN_W-1:0] ctrl_op_burst_len_p2,
   input ctrl_op_tag_state_update_p2,
   input [CACHE_STATE_W-1:0] ctrl_op_state_p2,
   input ctrl_wr_valid,
   input [DATA_W-1:0] ctrl_wr_data,
   input [BYTE_EN_W-1:0] ctrl_wr_byte_en,
   input [BURST_LEN_W-1:0] ctrl_wr_beat_num,
   input ctrl_wr_last,
   input cache_valid_p2,
   input [CACHE_STATE_W-1:0] cache_current_state_p2,
   input [WAY_POINTER_W-1:0] cache_way_num_p2,
   input cache_nack_uce_p2,
   input cache_nack_p2,
   input cache_nack_ce_p2,
   input cache_nack_no_allocate_p2,
   input cache_wr_ready,
   input cache_nack_ce_p2_d1,
   input wr_only_bypass_valid,
   input wr_only_bypass,
   input [BNK_W-1:0] my_bnk,
   
   output reg [BURST_LEN_W+3:0] wr_queue_data_out
);
wire my_address = (cache_valid_p2 && (ctrl_op_address_p2[ADDRESS_W-1:6] == 'd0));

// Constraint: if wr_valid and no wr_ready then wr_valid_should hold value
ctrl2cache_wr_valid_and_no_wr_ready_thn_wr_valid_hold_value: assert property(
   @(posedge clk) disable iff(!reset_n)
   (ctrl_wr_valid && !cache_wr_ready)
   |-> ##1
   ctrl_wr_valid
);

// Constraint: if wr_valid and no wr_ready then wr_port parameter 
// should hold value
ctrl2cache_wr_valid_and_no_wr_ready_thn_wr_param_hold_value: assert property(
   @(posedge clk) disable iff(!reset_n)
   (ctrl_wr_valid && !cache_wr_ready)
   |-> ##1
   ((ctrl_wr_data == $past(ctrl_wr_data)) &&
    (ctrl_wr_last == $past(ctrl_wr_last)) &&
    (ctrl_wr_byte_en == $past(ctrl_wr_byte_en)) &&
    (ctrl_wr_beat_num == $past(ctrl_wr_beat_num)))
);

wire [BNK_W-1:0] op_p2_bnk;
wire [TAG_W-1:0] op_p2_tag;
wire [SET_PER_BANK_W-1:0] op_p2_set;
fv_ccp_tagpipe_gen_index #(
   .N_SETS(N_SETS),
   .N_TAG_BANKS(N_TAG_BANKS),
   .ADDRESS_W(ADDRESS_W),
   .BNK_W(BNK_W),
   .CACHE_LINE_OFFSET_W(CACHE_LINE_OFFSET_W)
)fv_ccp_wr_gen_index(
   .address_in(ctrl_op_address_p2),
   .bnk_num(op_p2_bnk),
   .tag(op_p2_tag),
   .set(op_p2_set)
);

wire cache_valid_p2_real =
   (cache_valid_p2 &&
    !cache_nack_uce_p2 &&
    !cache_nack_p2 &&
    (!cache_nack_no_allocate_p2 || !ctrl_op_allocate_p2) &&
    !cache_nack_ce_p2 &&
    !cache_nack_ce_p2_d1);

reg [1:0] ctrl_wr_needed_nack_ce_p3; // 0 bit -> if nack ce 
reg [1:0] ctrl_wr_needed_nack_ce_p4; // 1 bit -> op_write
wire ctrl_wr_needed_valid = 
   cache_valid_p2_real && (ctrl_op_write_data_p2 || ctrl_op_bypass_p2);

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      ctrl_wr_needed_nack_ce_p3 <= 'd0;
      ctrl_wr_needed_nack_ce_p4 <= 'd0;
   end else begin
      ctrl_wr_needed_nack_ce_p4 <= ctrl_wr_needed_nack_ce_p3;
      if (cache_valid_p2 && (ctrl_op_write_data_p2 | ctrl_op_bypass_p2) && 
          !cache_nack_p2 && !cache_nack_no_allocate_p2) begin
         ctrl_wr_needed_nack_ce_p3 <= {ctrl_op_write_data_p2,cache_nack_ce_p2};
      end
   end
end

// Checker: if cache_valid_p2 then wr_only_bypass_valid as expected
// i.e. equal to ctrl_wr_needed
compare_wr_only_bypass_valid_with_expected: assert property(
   @(posedge clk) disable iff(!reset_n)
   (wr_only_bypass_valid == ctrl_wr_needed_valid)
);

// Checker: if cache_valid_p2 then wr_only_bypass as expected
// i.e. equal to ctrl_wr_needed
compare_wr_only_bypass_with_expected: assert property(
   @(posedge clk) disable iff(!reset_n)
   wr_only_bypass_valid
   |->
   (wr_only_bypass == (!ctrl_op_write_data_p2 && ctrl_op_bypass_p2))
);

// if miss, allocate and tag state update with valid state then full beat wr is
// needed
// wr_queue_data_in: 0 bit -> ctrl_op_bypass_p2
// [2:1] -> ctrl_op_burst_len_p2
reg wr_queue_empty;
reg wr_queue_full;

wire wr_ctrl_push = ctrl_wr_needed_valid;
wire wr_op_full_in = 
   ctrl_op_allocate_p2 && 
   (ctrl_op_tag_state_update_p2 && (ctrl_op_state_p2 != 'd0));

wire wr_op_pure_bypass_in = 
   (!ctrl_op_write_data_p2 && ctrl_op_bypass_p2);

wire [BURST_LEN_W+3:0] wr_queue_data_in = 
   {my_address, ctrl_op_port_sel_p2, wr_op_full_in, ctrl_op_burst_len_p2, wr_op_pure_bypass_in};

wire wr_queue_rd_req = (cache_wr_ready & ctrl_wr_valid & ctrl_wr_last);
wire wr_op_full_out = wr_queue_data_out[BURST_LEN_W+1];
wire [BURST_LEN_W-1:0] wr_op_num_beats_out = wr_queue_data_out[BURST_LEN_W:1];
wire wr_op_bypass_out = wr_queue_data_out[0];

ctrl2cache_full_wr_has_max_beats: assert property(
   @(posedge clk) disable iff(!reset_n)
   (ctrl_wr_needed_valid && wr_op_full_in)
   |->
   (ctrl_op_burst_len_p2 == (BURST_LEN - 'd1))
);

wire sample_fifo_output = ctrl_wr_valid;
// Instantiation of fv_ccp_wr_ctrl_queue
fv_ccp_single_wr_port_queue #(
   .WR_QUEUE_DEPTH(4),
   .MEM_W(BURST_LEN_W+4)
)fv_ccp_wr_ctrl_queue(
   .clk(clk),
   .reset_n(reset_n),
   .push(wr_ctrl_push),
   .data_in(wr_queue_data_in),
   .pop(wr_queue_rd_req),
   .sample_fifo_output(sample_fifo_output),
   .data_out(wr_queue_data_out),
   .empty(wr_queue_empty),
   .full(wr_queue_full)
);

// Constraint: if wr queu empty and no wr queue push then no wr_valid
ctrl2cache_wr_queue_empty_and_no_push_thn_no_wr_valid: assert property(
   @(posedge clk) disable iff(!reset_n)
   (wr_queue_empty && !wr_ctrl_push)
   |->
   !ctrl_wr_valid
);

//Constraint: if full_beat_wr_needed (queue_data_out[3]) then full_byte_en
ctrl2cache_full_wr_needed_thn_full_byte_en: assert property(
   @(posedge clk) disable iff(!reset_n)
   (ctrl_wr_valid && wr_op_full_out)
   |->
   (&ctrl_wr_byte_en)
);

// wr_beat_cnt 00 -> 1 beat, 01 -> 2 beats, 10 -> 3 beats, 11 -> 4 beats
// note : only valid when ctrl_wr_valid && cache_wr_ready 
reg [BURST_LEN_W-1:0] wr_beat_cnt;
always @(posedge clk or negedge reset_n) begin
   if (!reset_n) 
      wr_beat_cnt <= 'd0;
   else if(ctrl_wr_valid && cache_wr_ready && ctrl_wr_last)
      wr_beat_cnt <= 'd0;
   else if(ctrl_wr_valid && cache_wr_ready)
      wr_beat_cnt <= wr_beat_cnt + 'd1;
end

// Constraint: if wr_beat_cnt_reaches burst_len_value then wr last must be 
// asserted
// Note : only when full_wr is not needed
ctrl2cache_wr_beat_cnt_equals_burst_len_thn_wr_last: assert property(
   @(posedge clk) disable iff(!reset_n)
   ctrl_wr_valid
   |->
   (ctrl_wr_last == (wr_beat_cnt == wr_op_num_beats_out))
);

// beat_num_arrived to identify which beats has yet aarined in a er transaction
// 0th bit -> 00, 1st beat -> 01, 2nd bit -> 10, 3rd bit -> 11
reg [BURST_LEN-1:0] beat_num_arrived;
always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      beat_num_arrived <= 'd0;
   end else if (ctrl_wr_valid && cache_wr_ready && ctrl_wr_last) begin
      beat_num_arrived <= 'd0;
   end else if (ctrl_wr_valid && cache_wr_ready) begin
      beat_num_arrived[ctrl_wr_beat_num] <= 1'b1;
   end
end

// current_beat_num_vec is vector form of beat num in current trn
//wire [BURST_LEN-1:0] current_beat_num_vec = (ctrl_wr_beat_num << 1);
reg [BURST_LEN-1:0] current_beat_num_vec;
always @(*) begin
   current_beat_num_vec = 'd0;
   if (ctrl_wr_valid && cache_wr_ready) begin
      current_beat_num_vec[ctrl_wr_beat_num] = 1'b1;
   end
end
// Constraint:ctrl_wr_beat_num should not be repeated in a wr_transaction
ctrl2cache_wr_beat_num_not_repeated_in_a_wr_trn: assert property(
   @(posedge clk) disable iff(!reset_n)
   ctrl_wr_valid
   |->
   ((current_beat_num_vec & beat_num_arrived) == 'd0)
);

endmodule
