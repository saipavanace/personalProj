module fv_ccp_rdrsp_intf #(
   parameter N_SETS = 1024,
   parameter SET_W = $clog2(N_SETS),
   parameter N_TAG_BANKS = 2,
   parameter DATA_W = 129,
   parameter BYTE_EN_W = ((DATA_W-1)/8),
   parameter BNK_W = $clog2(N_TAG_BANKS),
   parameter BIT_PNT = $clog2(DATA_W-1),
   parameter ADDRESS_W = 40,
   parameter BURST_LEN_W = 2,
   parameter N_WAYS =4,
   parameter WAY_POINTER_W = $clog2(N_WAYS),
   parameter OUT_FIFO_DEPTH = 24, 
   parameter RDRSP_QUEUE_DEPTH = 4
)(
   input clk,
   input reset_n,
   input ctrl_op_read_data_p2,
   input ctrl_op_write_data_p2,
   input ctrl_op_port_sel_p2,
   input ctrl_op_bypass_p2,
   input [BURST_LEN_W-1:0] ctrl_op_burst_len_p2,
   input ctrl_op_allocate_p2,
   input cache_valid_p2,
   input cache_evict_valid_p2,
   input cache_nack_uce_p2,
   input cache_nack_p2,
   input cache_nack_ce_p2,
   input cache_nack_no_allocate_p2,
   input cache_rdrsp_valid,
   input [DATA_W-1:0] cache_rdrsp_data,
   input [BYTE_EN_W-1:0] cache_rdrsp_byteen,
   input cache_rdrsp_last,
   input cache_rdrsp_cancel,
   input ctrl_rdrsp_ready,
   
   input ctrl_wr_valid,
   input [DATA_W-1:0] ctrl_wr_data,
   input ctrl_wr_last,
   input [BYTE_EN_W-1:0] ctrl_wr_byte_en,
   input [BURST_LEN_W-1:0] ctrl_wr_beat_num,
   input cache_wr_ready,

   input [BURST_LEN_W+3:0] wr_queue_data_out,
   input [BURST_LEN_W:0] write_through_beat_num,
   input [BIT_PNT-1:0] my_bit_in_beat,
   input my_bit,
   input [ADDRESS_W-1:6] symbolic_tag,
   input [ADDRESS_W-1:0] ctrl_op_address_p2,
   input write_flag,
   input [DATA_W+BURST_LEN_W+16:0] write_data_queue_data_out,
   input [(7+2*(BURST_LEN_W))-1:0] p2_stage_command_fifo_data_out
);

wire cache_rdrsp_ready = ctrl_rdrsp_ready;

reg [7:0] rdrsp_counter;
wire rdrsp_with_burst_len_beats = 
   ((!ctrl_op_write_data_p2 && !ctrl_op_port_sel_p2 && ctrl_op_bypass_p2) ||
    (!ctrl_op_read_data_p2 && ctrl_op_write_data_p2 &&
     !ctrl_op_port_sel_p2 && ctrl_op_bypass_p2) ||
    (!cache_evict_valid_p2 && ctrl_op_read_data_p2 && !ctrl_op_write_data_p2
     && !ctrl_op_port_sel_p2 && !ctrl_op_bypass_p2));

wire real_cache_rdrsp = (cache_rdrsp_valid & cache_rdrsp_ready);

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      rdrsp_counter <= 'd0;
   end else begin
      if (real_cache_rdrsp) begin
         if (rdrsp_with_burst_len_beats) begin
            rdrsp_counter <= rdrsp_counter + ctrl_op_burst_len_p2;
         end else begin
           rdrsp_counter <= rdrsp_counter -'d1;
         end
      end else begin
         if (rdrsp_with_burst_len_beats) begin
            rdrsp_counter <= rdrsp_counter + ctrl_op_burst_len_p2 + 'd1;
         end 
      end
   end
end

no_rdrsp_valid_if_rdrsp_counter_zero: assert property(
   @(posedge clk) disable iff(!reset_n)
   (rdrsp_counter == 'd0)
   |->
   !cache_rdrsp_valid
);

// rdrsp_data_rd_only: 1 -> data due to read only
wire rdrsp_data_rd_only = 
   (!cache_evict_valid_p2 &&
    ctrl_op_read_data_p2 && 
    !ctrl_op_write_data_p2 && 
    !ctrl_op_bypass_p2 &&
    !ctrl_op_port_sel_p2);

// rdrsp_data_wr_through: 1 -> data due to write through 
wire rdrsp_data_wr_through = 
   (!ctrl_op_read_data_p2 && 
    ctrl_op_write_data_p2 && 
    ctrl_op_bypass_p2 &&
    !ctrl_op_port_sel_p2);

// rdrsp_data_bypass data due to bypass only
wire rdrsp_data_bypass = (!ctrl_op_port_sel_p2 &&
   ((ctrl_op_read_data_p2 & ctrl_op_bypass_p2 & !ctrl_op_write_data_p2 & 
    cache_evict_valid_p2) ||
    (!ctrl_op_read_data_p2 & !ctrl_op_write_data_p2 & ctrl_op_bypass_p2)));

wire no_nack = 
   (!cache_nack_p2 & !cache_nack_uce_p2 &
    !(cache_nack_no_allocate_p2 & ctrl_op_allocate_p2) & !cache_nack_ce_p2);

reg [BURST_LEN_W+3:0] p2_stage_command_fifo_rdrsp_data_out;

reg [BURST_LEN_W-1:0] rdrsp_data_beat_cnt;

assign rdrsp_data_last_beat = (cache_rdrsp_valid && ctrl_rdrsp_ready && 
   (rdrsp_data_beat_cnt == p2_stage_command_fifo_rdrsp_data_out[BURST_LEN_W+3:4]));

// command_rdrsp_data: data input for rdrsp_command_fifo 
// 0th bit -> (1 -> bypass; 0 -> non_bypass)
// 1st bit -> transaction deals with symbolic_tag or not
reg [1:0] command_rdrsp_data;
always @(*) begin
   command_rdrsp_data = 'd0;
   if (!ctrl_op_port_sel_p2 & ctrl_op_bypass_p2 & !ctrl_op_write_data_p2 &
       cache_valid_p2) begin
      command_rdrsp_data = {(ctrl_op_address_p2[ADDRESS_W-1:6] == symbolic_tag), 1'b1};
   end else if (!ctrl_op_read_data_p2 & ctrl_op_write_data_p2 &
                !ctrl_op_port_sel_p2 & ctrl_op_bypass_p2 &
                cache_valid_p2) begin
      command_rdrsp_data = {(ctrl_op_address_p2[ADDRESS_W-1:6] == symbolic_tag), 1'b0};
   end else if (!cache_evict_valid_p2 & ctrl_op_read_data_p2 & 
                !ctrl_op_write_data_p2 & !ctrl_op_port_sel_p2 &
                !ctrl_op_bypass_p2 & 
                cache_valid_p2) begin
      command_rdrsp_data = {(ctrl_op_address_p2[ADDRESS_W-1:6] == symbolic_tag), 1'b0};
   end
end

// p2_stage_command_rdrsp_fifo_push: whenever a ouput transaction is expected at 
// rdrsp port
reg p2_stage_command_fifo_rdrsp_full;
reg p2_stage_command_fifo_rdrsp_empty;
wire p2_stage_command_rdrsp_fifo_push = 
   (cache_valid_p2 & !cache_nack_ce_p2 & !cache_nack_uce_p2 & !cache_nack_p2 & 
    !(cache_nack_no_allocate_p2 & ctrl_op_allocate_p2) &
    ((!cache_evict_valid_p2 & ctrl_op_read_data_p2 & !ctrl_op_write_data_p2 & 
      !ctrl_op_port_sel_p2 & !ctrl_op_bypass_p2) || 
     (!ctrl_op_read_data_p2 & ctrl_op_write_data_p2 & !ctrl_op_port_sel_p2 &
      ctrl_op_bypass_p2)||
     (!ctrl_op_write_data_p2 & !ctrl_op_port_sel_p2 & ctrl_op_bypass_p2)));

wire [BURST_LEN_W+3:0] p2_stage_command_fifo_rdrsp_data_in = 
   {ctrl_op_burst_len_p2, rdrsp_data_wr_through, 
    rdrsp_data_rd_only, command_rdrsp_data};
wire p2_stage_command_fifo_rdrsp_rd_req = 
   ((!p2_stage_command_fifo_rdrsp_empty|p2_stage_command_rdrsp_fifo_push) & 
    cache_rdrsp_valid & cache_rdrsp_ready & rdrsp_data_last_beat & 
    !cache_rdrsp_cancel);  

// Instantiation of fifo for p2 stage command to track my address at rdrsp
fv_ccp_double_wr_port_queue #(
   .QUEUE_DEPTH(OUT_FIFO_DEPTH),
   .MEM_W(BURST_LEN_W+4)
)fv_ccp_p2_stage_command_rdrsp_queue(
   .clk(clk),
   .reset_n(reset_n),
   .push_1(p2_stage_command_rdrsp_fifo_push),
   .data_in_1(p2_stage_command_fifo_rdrsp_data_in),
   .push_2(0),
   .data_in_2('d0),
   .sample_bit(),
   .pop(p2_stage_command_fifo_rdrsp_rd_req),
   .data_out(p2_stage_command_fifo_rdrsp_data_out),
   .full(p2_stage_command_fifo_rdrsp_full),
   .empty(p2_stage_command_fifo_rdrsp_empty)
);

// Checker: if fifo is empty then no rdrsp valid
cache2ctrl_rdrsp_commamd_fifo_empty_thn_no_rdrsp_valid: assert property(
   @(posedge clk) disable iff(!reset_n)
   p2_stage_command_fifo_rdrsp_empty 
   |->
   !cache_rdrsp_valid
);

// Checker: if valid and no ready thn in next cycle valid should hold
cache2ctrl_valid_and_no_rdy_thn_rdrsp_valid_holds_value: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_rdrsp_valid && !ctrl_rdrsp_ready)
   |-> ##1
   cache_rdrsp_valid
);

// Checker: if valid and no ready thn in next cycle rdrsp parameter should hold
cache2ctrl_valid_and_no_rdy_thn_rdrsp_param_holds_value: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_rdrsp_valid && !ctrl_rdrsp_ready)
   |-> ##1
   ((cache_rdrsp_last == $past(cache_rdrsp_last)) &&
    (cache_rdrsp_byteen == $past(cache_rdrsp_byteen)) &&
    (cache_rdrsp_data == $past(cache_rdrsp_data)) &&
    (cache_rdrsp_cancel == $past(cache_rdrsp_cancel)))
);

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      rdrsp_data_beat_cnt <= 'd0;
   end else if (rdrsp_data_last_beat && cache_rdrsp_valid && 
                ctrl_rdrsp_ready) begin
      rdrsp_data_beat_cnt <= 'd0;
   end else begin
      if (cache_rdrsp_valid & ctrl_rdrsp_ready) begin 
         rdrsp_data_beat_cnt <= rdrsp_data_beat_cnt + 'd1;
      end
   end
end

// Checker: cache_rdrsp_last should be equal to rdrsp_data_last_beat
cache2ctrl_rdrsp_last_beat_as_expected: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_rdrsp_valid && ctrl_rdrsp_ready)
   |->
   (cache_rdrsp_last == rdrsp_data_last_beat)
);

// Checker: if rdrsp due to rd only or wr_through bypass then byteen all 1
cache2ctrl_if_rd_only_or_wr_thru_thn_byteen_allone: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_rdrsp_valid & (p2_stage_command_fifo_rdrsp_data_out[2] | 
    p2_stage_command_fifo_rdrsp_data_out[3]))
   |->
   (&cache_rdrsp_byteen)
);
// TODO TO write checker when only bypass data
// then from wr_byte_en

reg rdrsp_bypass_data_fifo_empty;
reg rdrsp_bypass_data_fifo_full;
wire rdrsp_bypass_data_fifo_push = 
   (ctrl_wr_valid & cache_wr_ready & wr_queue_data_out[0] & 
    !wr_queue_data_out[4]);
wire [DATA_W+BYTE_EN_W:0] rdrsp_bypass_fifo_data_in = 
   {ctrl_wr_data, ctrl_wr_byte_en, ctrl_wr_last};
wire rdrsp_bypass_data_fifo_rd_req = 
   ((!rdrsp_bypass_data_fifo_empty|rdrsp_bypass_data_fifo_push) & 
    ctrl_rdrsp_ready & cache_rdrsp_valid &
    p2_stage_command_fifo_rdrsp_data_out[0] &
   (!rdrsp_bypass_data_fifo_empty | rdrsp_bypass_data_fifo_push));
reg [DATA_W+BYTE_EN_W:0] rdrsp_bypass_fifo_data_out;

// Instantiation of fifo for information at wr_port
fv_ccp_double_wr_port_queue #(
   .QUEUE_DEPTH(4),
   .MEM_W(DATA_W+BYTE_EN_W+1)
)fv_ccp_rdrsp_bypass_data_queue(
   .clk(clk),
   .reset_n(reset_n),
   .push_1(rdrsp_bypass_data_fifo_push),
   .data_in_1(rdrsp_bypass_fifo_data_in),
   .push_2(0),
   .data_in_2('d0),
   .sample_bit(),
   .pop(rdrsp_bypass_data_fifo_rd_req),
   .data_out(rdrsp_bypass_fifo_data_out),
   .full(rdrsp_bypass_data_fifo_full),
   .empty(rdrsp_bypass_data_fifo_empty)
);

if_bypass_only_then_rdrsp_byteen_as_wr_byte_en: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_rdrsp_valid & rdrsp_bypass_data_fifo_rd_req)
   |->
   (cache_rdrsp_byteen == rdrsp_bypass_fifo_data_out[BYTE_EN_W:1])
);

if_bypass_only_then_rdrsp_last_as_wr_last: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_rdrsp_valid & rdrsp_bypass_data_fifo_rd_req)
   |->
   (cache_rdrsp_last == rdrsp_bypass_fifo_data_out[0])
);

if_bypass_only_then_rdrsp_data_as_wr_data: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_rdrsp_valid & rdrsp_bypass_data_fifo_rd_req)
   |->
   (cache_rdrsp_data == rdrsp_bypass_fifo_data_out[DATA_W+BYTE_EN_W:BYTE_EN_W+1])
);

reg my_bit_has_written;
always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      my_bit_has_written <= 'd0;
   end else if (write_flag & !write_data_queue_data_out[0]) begin 
      my_bit_has_written <= 1'b1;
   end else if (write_data_queue_data_out[0]) begin
      my_bit_has_written <= 1'b0;
   end
end

wire rdrsp_nonbypass_data_fifo_push = 
  ((!p2_stage_command_fifo_data_out[1] & p2_stage_command_fifo_data_out[2] & 
    !p2_stage_command_fifo_data_out[3] & p2_stage_command_fifo_data_out[4] &
    (write_flag | (write_data_queue_data_out[0] & !my_bit_has_written))) || 
   (!p2_stage_command_fifo_data_out[0] & p2_stage_command_fifo_data_out[1] &
    !p2_stage_command_fifo_data_out[2] & !p2_stage_command_fifo_data_out[3] &
    !p2_stage_command_fifo_data_out[4]));

// when last beat transaction for an output evict transaction for my address
// and non bypass case
wire rdrsp_nonbypass_data_fifo_rd_req = 
   (cache_rdrsp_valid & ctrl_rdrsp_ready & cache_rdrsp_last &
    (p2_stage_command_fifo_rdrsp_data_out[1:0] == 2'b10));

reg no_new_my_transaction;
always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      no_new_my_transaction <= 'd0; 
   end else if (cache_rdrsp_last & cache_rdrsp_valid & ctrl_rdrsp_ready &
                !rdrsp_nonbypass_data_fifo_rd_req) begin
      no_new_my_transaction <= 1'b1;
   end else if (rdrsp_nonbypass_data_fifo_rd_req) begin
      no_new_my_transaction <= 1'b0;
   end
end

// rdrsp_nobypass_data: data input to evict_data_fifo
// 0th bit if my_bit to be expected at rdrsp port
// [2:1] -> at what beat number my_bit is expected
// 3rd bit -> my_bit
reg [BURST_LEN_W+1:0] rdrsp_nobypass_data;
always @(*) begin
   rdrsp_nobypass_data = 'd0;
   if (!p2_stage_command_fifo_data_out[1] & 
       p2_stage_command_fifo_data_out[2] & 
       !p2_stage_command_fifo_data_out[3] & 
       p2_stage_command_fifo_data_out[4]) begin
      rdrsp_nobypass_data = {my_bit, write_through_beat_num};
   end else if (!p2_stage_command_fifo_data_out[0] & 
                p2_stage_command_fifo_data_out[1] & 
                !p2_stage_command_fifo_data_out[2] &
                !p2_stage_command_fifo_data_out[3] & 
                !p2_stage_command_fifo_data_out[4]) begin
      rdrsp_nobypass_data = {my_bit,p2_stage_command_fifo_data_out[9:7]};
   end
end

wire [BURST_LEN_W+1:0] rdrsp_nonbypass_data_fifo_data_in = rdrsp_nobypass_data;
reg [BURST_LEN_W+1:0] rdrsp_nonbypass_fifo_data_out;
reg rdrsp_nonbypass_data_fifo_full;
reg rdrsp_nonbypass_data_fifo_empty;

// Instantiation of fifo for data into evict port for non bypass case
fv_ccp_double_wr_port_queue #(
   .QUEUE_DEPTH(OUT_FIFO_DEPTH),
   .MEM_W(BURST_LEN_W+2)
)fv_ccp_rdrsp_nonbypass_data_queue(
   .clk(clk),
   .reset_n(reset_n),
   .push_1(rdrsp_nonbypass_data_fifo_push),
   .data_in_1(rdrsp_nonbypass_data_fifo_data_in),
   .push_2(0),
   .data_in_2('d0),
   .sample_bit(),
   .pop(rdrsp_nonbypass_data_fifo_rd_req),
   .data_out(rdrsp_nonbypass_fifo_data_out),
   .full(rdrsp_nonbypass_data_fifo_full),
   .empty(rdrsp_nonbypass_data_fifo_empty)
);

// rdrsp_data_out_cnt: counter for number of output data beats at rdrsp port for
// a transaction
reg [BURST_LEN_W-1:0] rdrsp_data_out_cnt;

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      rdrsp_data_out_cnt <= 'd0;
   end else if (cache_rdrsp_valid & ctrl_rdrsp_ready & cache_rdrsp_last) begin
      rdrsp_data_out_cnt <= 'd0;
   end else if (cache_rdrsp_valid & ctrl_rdrsp_ready) begin
      rdrsp_data_out_cnt <= rdrsp_data_out_cnt + 'd1;
   end
end

// If rdrsp_valid and rdrsp_ready and my_bit valid and symbolic_tag transaction
// and rdrsp data beat number same as my_bit beat number than rdrsp_data
// comparision
if_nonbypass_and_my_bit_legal_rdrsp_data_match: assert property(
   @(posedge clk) disable iff(!reset_n)
   ((p2_stage_command_fifo_rdrsp_data_out[1:0] == 2'b10) & cache_rdrsp_valid & 
    ctrl_rdrsp_ready & rdrsp_nonbypass_fifo_data_out[0] &
    (rdrsp_nonbypass_fifo_data_out[2:1] == rdrsp_data_out_cnt) &
    !no_new_my_transaction)
   |->
   (cache_rdrsp_data[my_bit_in_beat] == rdrsp_nonbypass_fifo_data_out[3])
);

endmodule
