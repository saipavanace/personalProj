/*******************************************************************************
 * OSKI TECHNOLOGY CONFIDENTIAL 
 * Copyright (c) 2017 Oski Technology, All Rights Reserved.
 ******************************************************************************/

// ===========================================================================//
//                              Module Description                            //
// ===========================================================================//
// Contains interface properties on fill interface
// ===========================================================================//

module fv_ccp_fill_intf #(
   parameter N_WAYS =2,
   parameter WAY_POINTER_W = $clog2(N_WAYS),
   parameter CACHE_STATE_W = 2,
   parameter DATA_W = 129,
   parameter ADDRESS_W = 32,
   parameter SECURITY_BIT = 1,
   parameter BURST_LEN_W = 2,
   parameter MAX_BEAT_IN_BURST = (1 << BURST_LEN_W),
   parameter TABLE_ENTRIES = 64,
   parameter TABLE_ENTRIES_W = $clog2(TABLE_ENTRIES)
) (
   input clk,
   input reset_n,
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

   output wire ctrl_fill_data_valid_first_beat,
   output wire ctrl_fill_data_valid_last_beat
);

// If fill_valid is high and cache_fill_ready is low, valid should be
// stable
ctrl2cache_fill_valid_stable_during_handshake: assert property(
   @(posedge clk) disable iff(!reset_n)
   (ctrl_fill_valid && !cache_fill_ready)
   |-> ##1
   ctrl_fill_valid
);

// If fill_valid is high and cache_fill_ready is low, all fill state 
// parameter should be stable
ctrl2cache_fill_state_params_stable_during_handshake: assert property(
   @(posedge clk) disable iff(!reset_n)
   (ctrl_fill_valid && !cache_fill_ready)
   |-> ##1
   ((ctrl_fill_address == $past(ctrl_fill_address)) &&
    (ctrl_fill_security == $past(ctrl_fill_security)) &&
    (ctrl_fill_way_num == $past(ctrl_fill_way_num)) &&
    (ctrl_fill_state == $past(ctrl_fill_state)))
);

generate 
   if(SECURITY_BIT != 0) begin: sec
      ctrl2cache_fill_security_stable_during_handshake: assert property(
         @(posedge clk) disable iff(!reset_n)
         (ctrl_fill_valid && !cache_fill_ready) 
         |-> ##1
         (ctrl_fill_security == $past(ctrl_fill_security))
      );
   end
endgenerate

ctrl2cache_fill_state_nz: assert property(
   @(posedge clk) disable iff(!reset_n)
   ctrl_fill_valid
   |->
   (ctrl_fill_state != 'd0)
);

// If fill_data_valid is high and cache_fill_data_ready is low, valid should be
// stable
ctrl2cache_fill_data_valid_stable_during_handshake: assert property(
   @(posedge clk) disable iff(!reset_n)
   (ctrl_fill_data_valid && !cache_fill_data_ready)
   |-> ##1
   ctrl_fill_data_valid
);

// If fill_data_valid is high and cache_fill_data_ready is low, all fill data
// parameter should be stable
ctrl2cache_fill_data_params_stable_during_handshake: assert property(
   @(posedge clk) disable iff(!reset_n)
   (ctrl_fill_data_valid && !cache_fill_data_ready)
   |-> ##1
   ((ctrl_fill_data == $past(ctrl_fill_data)) &&
    (ctrl_fill_data_id == $past(ctrl_fill_data_id)) &&
    (ctrl_fill_data_address == $past(ctrl_fill_data_address)) &&
    (ctrl_fill_data_way_num == $past(ctrl_fill_data_way_num)) &&
    (ctrl_fill_data_beat_num == $past(ctrl_fill_data_beat_num)))
);

// fill beats to represent number of beats arrived for a fill_id 
reg [BURST_LEN_W-1:0] fill_beats;
always @(posedge clk or negedge reset_n) begin
   if(!reset_n)
      fill_beats <= 'd0;
   else if(ctrl_fill_data_valid && cache_fill_data_ready && 
           (fill_beats == (MAX_BEAT_IN_BURST-1)))
      fill_beats <= 'd0;
   else if(ctrl_fill_data_valid && cache_fill_data_ready)
      fill_beats <= fill_beats + 'd1;
end

assign ctrl_fill_data_valid_first_beat = 
   ctrl_fill_data_valid &&
   (fill_beats == 'b0);

wire first_beat = (fill_beats == 'b0);

assign ctrl_fill_data_valid_last_beat = 
   ctrl_fill_data_valid &&
   (fill_beats == (MAX_BEAT_IN_BURST-1));

// current_fill_data_id to represent the id of ongoing fill
// current_fill_data_address to represent the address of ongoing fill
// current_fill_data_way_num  to represent the way_num of ongoing fill
reg [TABLE_ENTRIES_W-1:0] current_fill_data_id;
reg [ADDRESS_W-1:0] current_fill_data_address;
reg [WAY_POINTER_W-1:0] current_fill_data_way_num;
always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      current_fill_data_id <= 'd0;
      current_fill_data_address <= 'd0;
      current_fill_data_way_num <= 'd0;
   end else if (ctrl_fill_data_valid && cache_fill_data_ready && first_beat) begin
      current_fill_data_id <= ctrl_fill_data_id;
      current_fill_data_address <= ctrl_fill_data_address;
      current_fill_data_way_num <= ctrl_fill_data_way_num;
   end 
end

// Constraint that for a single fill i.e. till the last beat of a fill is not
// asserted, fill_id, fill_address and fill_way_num should hold their values
ctrl2cache_fill_data_params_constant_throgh_out_beats: assert property(
   @(posedge clk) disable iff(!reset_n)
   (ctrl_fill_data_valid && !first_beat)
   |->
   ((ctrl_fill_data_id == current_fill_data_id) &&
    (ctrl_fill_data_address == current_fill_data_address) &&
    (ctrl_fill_data_way_num == current_fill_data_way_num))
);

// current_fill_data_beat_num to represent the number of beat asserted for which
// fill is happening
reg [BURST_LEN_W-1:0] current_fill_data_beat_num;
always @(posedge clk) begin
   if (cache_fill_data_ready && ctrl_fill_data_valid) begin
      current_fill_data_beat_num <= ctrl_fill_data_beat_num;
   end
end

// current_fill_data_beat_num_p1 to represent the next beat number to the
// current beat number
wire [BURST_LEN_W-1:0] current_fill_data_beat_num_p1 = 
   current_fill_data_beat_num + 'd1;

// Constraint that for a fill_id beat number should be consecutive where as
// first beat can random
ctrl2cache_beat_num_always_oneplus: assert property(
   @(posedge clk) disable iff(!reset_n)
   (ctrl_fill_data_valid && !first_beat)
   |-> 
   (ctrl_fill_data_beat_num == current_fill_data_beat_num_p1)
);

// fill_id_busy_vec to represent the id's busy in pending fill operations
reg [TABLE_ENTRIES-1:0] fill_id_busy_vec;
// set_fill_id_busy to represent if a new fill operation is started
wire set_fill_id_busy = 
   ctrl_fill_data_valid && cache_fill_data_ready && first_beat;

// set_fill_id_busy_vec to represent the fill_id for new fill operation asserted
wire [TABLE_ENTRIES-1:0] set_fill_id_busy_vec = 
   (set_fill_id_busy << ctrl_fill_data_id);
// clr_fill_id_busy_vec to represent the fill_id for which a fill done is
// asserted and no longer in use
wire [TABLE_ENTRIES-1:0] clr_fill_id_busy_vec = 
   (cache_fill_done << cache_fill_done_id);

// next_fill_id_busy_vec to represent the fill id's about to be busy in next
// cycle
wire [TABLE_ENTRIES-1:0] next_fill_id_busy_vec = 
   (fill_id_busy_vec & ~clr_fill_id_busy_vec) | set_fill_id_busy_vec;

always @(posedge clk or negedge reset_n) begin
   if(!reset_n)
      fill_id_busy_vec <= 'd0;
   else
      fill_id_busy_vec <= next_fill_id_busy_vec;
end

// Constraint that a already pending fill_id can not be assigned for an another
// fill
ctrl2cache_busy_fill_id_never_used_on_first_beat: assert property(
   @(posedge clk) disable iff(!reset_n)
   set_fill_id_busy
   |->
   ((fill_id_busy_vec & set_fill_id_busy_vec) == 'b0)
);

// Constraint that a already cleared fill_id can not be asserted for
// ctrl_fill_id_done 
cache2ctrl_never_clr_fill_id_which_is_not_busy: assert property(
   @(posedge clk) disable iff(!reset_n)
   cache_fill_done
   |->
   ((~fill_id_busy_vec & clr_fill_id_busy_vec) == 'b0)
);

endmodule
