module fv_ccp_evict_intf #(
   parameter N_SETS = 1024,
   parameter SET_W = $clog2(N_SETS),
   parameter N_TAG_BANKS = 2,
   parameter DATA_W = 129,
   parameter BYTE_EN_W = ((DATA_W-1)/8),
   parameter BIT_PNT = $clog2(DATA_W-1),
   parameter BNK_W = $clog2(N_TAG_BANKS),
   parameter ADDRESS_W = 40,
   parameter BURST_LEN_W = 2,
   parameter BURST_LEN = (2**BURST_LEN_W),
   parameter N_WAYS =4,
   parameter WAY_POINTER_W = $clog2(N_WAYS),
   parameter OUT_FIFO_DEPTH = 24,
   parameter EVICT_QUEUE_DEPTH = 4
)(
   input clk,
   input reset_n,
   input ctrl_op_read_data_p2,
   input ctrl_op_write_data_p2,
   input ctrl_op_port_sel_p2,
   input ctrl_op_bypass_p2,
   input ctrl_op_allocate_p2,
   input [BURST_LEN_W-1:0] ctrl_op_burst_len_p2,
   input cache_valid_p2,
   input cache_evict_valid_p2,
   input [ADDRESS_W-1:0] cache_evict_address_p2,
   input cache_nack_uce_p2,
   input cache_nack_p2,
   input cache_nack_ce_p2,
   input cache_nack_no_allocate_p2,
   input cache_evict_valid,
   input [DATA_W-1:0] cache_evict_data,
   input [(DATA_W/8)-1:0] cache_evict_byteen,
   input cache_evict_last,
   input cache_evict_cancel,
   input ctrl_evict_ready,
   
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
   input [BURST_LEN_W-1:0] symbolic_beat,
   input [DATA_W+BURST_LEN_W+16:0] write_data_queue_data_out,
   input write_flag,
   input [(7+2*(BURST_LEN_W))-1:0] p2_stage_command_fifo_data_out
);

wire cache_evict_ready = ctrl_evict_ready;

reg [7:0] evict_counter;
wire evict_with_burst_len_beats = 
   ((!ctrl_op_read_data_p2 & !ctrl_op_write_data_p2 & ctrl_op_port_sel_p2 & 
     ctrl_op_bypass_p2) ||
    (!ctrl_op_read_data_p2 & ctrl_op_write_data_p2 & ctrl_op_port_sel_p2 & 
     ctrl_op_bypass_p2) ||
    (cache_evict_valid_p2 & ctrl_op_read_data_p2 & !ctrl_op_write_data_p2 &
     ctrl_op_port_sel_p2 & ctrl_op_bypass_p2) ||
    (!cache_evict_valid_p2 & ctrl_op_read_data_p2 & !ctrl_op_write_data_p2 &
     ctrl_op_port_sel_p2 & !ctrl_op_bypass_p2));

wire evict_with_all_beats = (cache_evict_valid_p2 & ctrl_op_read_data_p2 &
   ((!ctrl_op_write_data_p2 & !ctrl_op_bypass_p2) ||
    (!ctrl_op_write_data_p2 & !ctrl_op_port_sel_p2 & ctrl_op_bypass_p2) ||
    (!ctrl_op_write_data_p2 & ctrl_op_port_sel_p2 & ctrl_op_bypass_p2) ||
    (ctrl_op_write_data_p2 & !ctrl_op_bypass_p2)));

wire real_cache_evict = (cache_evict_valid & cache_evict_ready);

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      evict_counter <= 'd0;
   end else begin
      if (real_cache_evict) begin
         if (evict_with_burst_len_beats & !evict_with_all_beats) begin
            evict_counter <= evict_counter + ctrl_op_burst_len_p2;
         end else if (!evict_with_burst_len_beats & evict_with_all_beats) begin
            evict_counter <= evict_counter + 'd3;
         end else if (evict_with_burst_len_beats & evict_with_all_beats) begin
            evict_counter <= evict_counter + ctrl_op_burst_len_p2 + 'd4;
         end else if (!evict_with_burst_len_beats & !evict_with_all_beats) begin
             evict_counter <= evict_counter - 'd1;
         end
      end else begin
         if (evict_with_burst_len_beats & !evict_with_all_beats) begin
            evict_counter <= evict_counter + ctrl_op_burst_len_p2 + 'd1;
         end else if (!evict_with_burst_len_beats & evict_with_all_beats) begin
            evict_counter <= evict_counter + 'd4;
         end else if (evict_with_burst_len_beats & evict_with_all_beats) begin
            evict_counter <= evict_counter + ctrl_op_burst_len_p2 + 'd5;
         end 
      end
   end
end

no_evict_valid_if_evict_counter_zero: assert property(
   @(posedge clk) disable iff(!reset_n)
   (evict_counter == 'd0)
   |->
   !cache_evict_valid
);

// evict_data_bypass_only if evict data due to bypass only
wire evict_data_bypass_only = 
   ((!ctrl_op_read_data_p2 & !ctrl_op_write_data_p2 & ctrl_op_port_sel_p2 &
     ctrl_op_bypass_p2) || 
    (cache_evict_valid_p2 & ctrl_op_read_data_p2 & !ctrl_op_write_data_p2 &
     ctrl_op_port_sel_p2 & ctrl_op_bypass_p2));

// evict_data_eviction if evict data due to cache eviction
wire evict_data_eviction = 
   (cache_evict_valid_p2 &&
    ((ctrl_op_read_data_p2 & !ctrl_op_write_data_p2 & !ctrl_op_bypass_p2) ||
     (ctrl_op_read_data_p2 & !ctrl_op_write_data_p2 & !ctrl_op_port_sel_p2 &
      ctrl_op_bypass_p2) ||
     (ctrl_op_read_data_p2 & !ctrl_op_write_data_p2 & ctrl_op_port_sel_p2 &
      ctrl_op_bypass_p2) ||
     (ctrl_op_read_data_p2 & ctrl_op_write_data_p2 & !ctrl_op_bypass_p2)));

wire rd_only = (!cache_evict_valid_p2 && ctrl_op_read_data_p2 &&
   !ctrl_op_write_data_p2 && ctrl_op_port_sel_p2 && !ctrl_op_bypass_p2);

// evict_data_wr_through if evict data is wr through
wire evict_data_wr_through = 
   (!ctrl_op_read_data_p2 & ctrl_op_write_data_p2 &
    ctrl_op_port_sel_p2 & ctrl_op_bypass_p2);

wire bypass_and_evict_data = (cache_evict_valid_p2 & ctrl_op_read_data_p2 & !ctrl_op_write_data_p2 &
     ctrl_op_port_sel_p2 & ctrl_op_bypass_p2);

wire no_nack = 
   (!cache_nack_p2 & !cache_nack_uce_p2 &
    !(cache_nack_no_allocate_p2 & ctrl_op_allocate_p2) & !cache_nack_ce_p2);

reg [BURST_LEN_W+5:0] p2_stage_command_fifo_evict_data_out;
reg [BURST_LEN_W-1:0] evict_data_beat_cnt;

wire [BURST_LEN_W+4:0] evict_command_fifo_data_out = 
   {p2_stage_command_fifo_evict_data_out[5],
    p2_stage_command_fifo_evict_data_out[4],
    p2_stage_command_fifo_evict_data_out[7:6],
    p2_stage_command_fifo_evict_data_out[3],
    p2_stage_command_fifo_evict_data_out[2],
    p2_stage_command_fifo_evict_data_out[0]};

assign evict_data_last_beat = 
   (cache_evict_valid & ctrl_evict_ready & ((((evict_command_fifo_data_out[6]) || 
      (evict_command_fifo_data_out[1]) || 
      ((evict_command_fifo_data_out[0] && !evict_command_fifo_data_out[2]) || 
       (evict_command_fifo_data_out[0] && evict_command_fifo_data_out[2] &&
        evict_command_fifo_data_out[5]))) && 
     (evict_data_beat_cnt == evict_command_fifo_data_out[BURST_LEN_W+2:3])) || 
    ((evict_command_fifo_data_out[2] && !evict_command_fifo_data_out[5]) && 
     (evict_data_beat_cnt == (BURST_LEN-1)))));

// command_evict_data: data input for evict_command_fifo 
// 0th bit -> (1 -> bypass; 0 -> non_bypass)
// 1st bit -> transaction deals with symbolic_tag or not
reg [1:0] command_evict_data;
always @(*) begin
   command_evict_data = 'd0;
   if (cache_valid_p2 & cache_evict_valid_p2 & ctrl_op_read_data_p2 &
   !ctrl_op_write_data_p2 & ctrl_op_port_sel_p2 & ctrl_op_bypass_p2) begin
      command_evict_data = {(cache_evict_address_p2[ADDRESS_W-1:6] ==
      symbolic_tag), 1'b1};   
   end else if (cache_valid_p2 & cache_evict_valid_p2 & ctrl_op_read_data_p2) begin
      command_evict_data = {(cache_evict_address_p2[ADDRESS_W-1:6] ==
      symbolic_tag), 1'b0};
   end else if (ctrl_op_port_sel_p2 & ctrl_op_bypass_p2 & !ctrl_op_write_data_p2
                & !ctrl_op_read_data_p2 & cache_valid_p2) begin
      command_evict_data = {(ctrl_op_address_p2[ADDRESS_W-1:6] == symbolic_tag), 1'b1};
   end else if (!ctrl_op_read_data_p2 & ctrl_op_write_data_p2 &
                ctrl_op_port_sel_p2 & ctrl_op_bypass_p2 &
                cache_valid_p2) begin
      command_evict_data = {(ctrl_op_address_p2[ADDRESS_W-1:6] == symbolic_tag), 1'b0};
   end else if (!cache_evict_valid_p2 & ctrl_op_read_data_p2 & 
                !ctrl_op_write_data_p2 & ctrl_op_port_sel_p2 &
                !ctrl_op_bypass_p2 & cache_valid_p2) begin
      command_evict_data = {(ctrl_op_address_p2[ADDRESS_W-1:6] == symbolic_tag), 1'b0};
   end
end

// p2_stage_command_evict_fifo_push_1: whenever a transaction command with output at
// evict port comes at p2 stage
reg p2_stage_command_fifo_evict_full;
reg p2_stage_command_fifo_evict_empty;
wire p2_stage_command_evict_fifo_push_1 = (cache_valid_p2 & !cache_nack_ce_p2 &
   !cache_nack_uce_p2 & !cache_nack_p2 & 
   !(cache_nack_no_allocate_p2 & ctrl_op_allocate_p2) &
   ((ctrl_op_read_data_p2 & ctrl_op_port_sel_p2) || 
    (ctrl_op_read_data_p2 & cache_evict_valid_p2) ||
    (ctrl_op_write_data_p2 & ctrl_op_bypass_p2 & ctrl_op_port_sel_p2) ||
    (!ctrl_op_write_data_p2 & ctrl_op_port_sel_p2 & ctrl_op_bypass_p2)));

wire [BURST_LEN_W+5:0] p2_stage_command_fifo_evict_data_in_1 = 
   {ctrl_op_burst_len_p2, rd_only, bypass_and_evict_data, evict_data_eviction,
    evict_data_wr_through, command_evict_data};

// p2_stage_command_evict_fifo_push_2: whenever a transaction command with
// two output transactions at evict port 
wire p2_stage_command_evict_fifo_push_2 = 
   (cache_evict_valid_p2 & ctrl_op_read_data_p2 & !ctrl_op_write_data_p2 &
    ctrl_op_port_sel_p2 & ctrl_op_bypass_p2 & cache_valid_p2 & !cache_nack_ce_p2
    & !cache_nack_uce_p2 & !cache_nack_p2 & !(cache_nack_no_allocate_p2 &
    ctrl_op_allocate_p2));
wire [BURST_LEN_W+5:0] p2_stage_command_fifo_evict_data_in_2 = 
   {ctrl_op_burst_len_p2, rd_only, 1'b0, evict_data_eviction, 
    evict_data_wr_through, (cache_evict_address_p2[ADDRESS_W-1:6] ==
    symbolic_tag), 1'b0};
wire p2_stage_command_fifo_evict_rd_req = 
   ((!p2_stage_command_fifo_evict_empty | (p2_stage_command_evict_fifo_push_1|p2_stage_command_evict_fifo_push_2)) & 
    cache_evict_valid & cache_evict_ready & cache_evict_last);  

// Instantiation of fifo for p2 stage command to track my address at evict
fv_ccp_double_wr_port_queue #(
   .QUEUE_DEPTH(OUT_FIFO_DEPTH),
   .MEM_W(8)
)fv_ccp_p2_stage_command_evict_queue(
   .clk(clk),
   .reset_n(reset_n),
   .push_1(p2_stage_command_evict_fifo_push_1),
   .data_in_1(p2_stage_command_fifo_evict_data_in_1),
   .push_2(p2_stage_command_evict_fifo_push_2),
   .data_in_2(p2_stage_command_fifo_evict_data_in_2),
   .sample_bit(),
   .pop(p2_stage_command_fifo_evict_rd_req),
   .data_out(p2_stage_command_fifo_evict_data_out),
   .full(p2_stage_command_fifo_evict_full),
   .empty(p2_stage_command_fifo_evict_empty)
);

// Checker: if fifo is empty then no evict valid
cache2ctrl_evict_commamd_fifo_empty_thn_no_evict_valid: assert property(
   @(posedge clk) disable iff(!reset_n)
   p2_stage_command_fifo_evict_empty 
   |->
   !cache_evict_valid
);

// Checker: if valid and no ready thn in next cycle valid should hold
cache2ctrl_valid_and_no_rdy_thn_evict_valid_holds_value: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_evict_valid && !ctrl_evict_ready)
   |-> ##1
   cache_evict_valid
);

// Checker: if valid and no ready thn in next cycle evict parameter should hold
cache2ctrl_valid_and_no_rdy_thn_evict_param_holds_value: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_evict_valid && !ctrl_evict_ready)
   |-> ##1
   ((cache_evict_last == $past(cache_evict_last)) &&
    (cache_evict_byteen == $past(cache_evict_byteen)) &&
    (cache_evict_data == $past(cache_evict_data)) &&
    (cache_evict_cancel == $past(cache_evict_cancel)))
);

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      evict_data_beat_cnt <= 'd0;
   end else if (evict_data_last_beat && cache_evict_valid && 
                ctrl_evict_ready) begin
       evict_data_beat_cnt <= 'd0;
   end else begin 
      if (cache_evict_valid && ctrl_evict_ready) begin
         evict_data_beat_cnt <= (evict_data_beat_cnt +'d1);
      end
   end
end

// Checker: cache_evict_last should be equal to evict_data_last_beat
cache2ctrl_evict_last_beat_as_expected: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_evict_valid && ctrl_evict_ready && (!p2_stage_command_fifo_evict_empty |
   p2_stage_command_evict_fifo_push_1 |p2_stage_command_evict_fifo_push_2 ))
   |->
   (cache_evict_last == evict_data_last_beat)
);


// Checker: if evict due to eviction and wr through then byteen all 1
cache2ctrl_if_rd_only_or_wr_thru_thn_byteen_allone: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_evict_valid && 
    (evict_command_fifo_data_out[1] | evict_command_fifo_data_out[6] |
     (evict_command_fifo_data_out[2] & !evict_command_fifo_data_out[5])))
   |->
   (&cache_evict_byteen)
);
// TODO TO write checker when only bypass data
// then from wr_byte_en

reg evict_bypass_data_fifo_empty;
reg evict_bypass_data_fifo_full;
wire evict_bypass_data_fifo_push = 
   (ctrl_wr_valid & cache_wr_ready & wr_queue_data_out[0] & 
    wr_queue_data_out[4]);
wire [DATA_W+BYTE_EN_W:0] evict_bypass_fifo_data_in = 
   {ctrl_wr_data, ctrl_wr_byte_en, ctrl_wr_last};
wire evict_bypass_data_fifo_rd_req =
   ((!evict_bypass_data_fifo_empty|evict_bypass_data_fifo_push) &
   ctrl_evict_ready & cache_evict_valid &
   (!evict_bypass_data_fifo_empty | evict_bypass_data_fifo_push) &
    ((evict_command_fifo_data_out[0] & !evict_command_fifo_data_out[2]) ||
     (evict_command_fifo_data_out[0] && evict_command_fifo_data_out[2] &&
      evict_command_fifo_data_out[5])));
reg [DATA_W+BYTE_EN_W:0] evict_bypass_fifo_data_out;

// Instantiation of fifo for information at wr_port
fv_ccp_double_wr_port_queue #(
   .QUEUE_DEPTH(4),
   .MEM_W(DATA_W+BYTE_EN_W+1)
)fv_ccp_evict_bypass_data_queue(
   .clk(clk),
   .reset_n(reset_n),
   .push_1(evict_bypass_data_fifo_push),
   .data_in_1(evict_bypass_fifo_data_in),
   .push_2(0),
   .data_in_2('d0),
   .sample_bit(),
   .pop(evict_bypass_data_fifo_rd_req),
   .data_out(evict_bypass_fifo_data_out),
   .full(evict_bypass_data_fifo_full),
   .empty(evict_bypass_data_fifo_empty)
);

if_bypass_only_then_byteen_as_wr_byte_en: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_evict_valid & evict_bypass_data_fifo_rd_req)
   |->
   (cache_evict_byteen == evict_bypass_fifo_data_out[BYTE_EN_W:1])
);

if_bypass_only_then_evict_last_as_wr_last: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_evict_valid & evict_bypass_data_fifo_rd_req)
   |->
   (cache_evict_last == evict_bypass_fifo_data_out[0])
);

if_bypass_only_then_evict_data_as_wr_data: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_evict_valid & evict_bypass_data_fifo_rd_req)
   |->
   (cache_evict_data == evict_bypass_fifo_data_out[DATA_W+BYTE_EN_W:BYTE_EN_W+1])
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

wire evict_nonbypass_data_fifo_push = 
   ((!p2_stage_command_fifo_data_out[1] & p2_stage_command_fifo_data_out[2] & 
     p2_stage_command_fifo_data_out[3] & p2_stage_command_fifo_data_out[4] & 
     (write_flag | (write_data_queue_data_out[0] & !my_bit_has_written))) ||
    (p2_stage_command_fifo_data_out[0] & p2_stage_command_fifo_data_out[1]) ||
    (!p2_stage_command_fifo_data_out[0] & p2_stage_command_fifo_data_out[1] &
     !p2_stage_command_fifo_data_out[2] & p2_stage_command_fifo_data_out[3] &
     !p2_stage_command_fifo_data_out[4]));

// when last beat transaction for an output evict transaction for my address
// and non bypass case
wire evict_nonbypass_data_fifo_rd_req = 
   (cache_evict_valid & ctrl_evict_ready & cache_evict_last &
    (p2_stage_command_fifo_evict_data_out[1:0] == 2'b10));

reg no_new_my_transaction;
always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      no_new_my_transaction <= 'd0; 
   end else if (cache_evict_last & cache_evict_valid & ctrl_evict_ready &
                !evict_nonbypass_data_fifo_rd_req) begin
      no_new_my_transaction <= 1'b1;
   end else if (evict_nonbypass_data_fifo_rd_req) begin
      no_new_my_transaction <= 1'b0;
   end
end

// evict_nobypass_data: data input to evict_data_fifo
// 0th bit if my_bit to be expected at evict port
// [2:1] -> at what beat number my_bit is expected
// 3rd bit -> my_bit
reg [BURST_LEN_W+1:0] evict_nobypass_data;
always @(*) begin
   evict_nobypass_data = 'd0;
   if (!p2_stage_command_fifo_data_out[1] & 
       p2_stage_command_fifo_data_out[2] & 
       p2_stage_command_fifo_data_out[3] & 
       p2_stage_command_fifo_data_out[4]) begin
      evict_nobypass_data = {my_bit, write_through_beat_num};
   end else if (p2_stage_command_fifo_data_out[0] &
                p2_stage_command_fifo_data_out[1]) begin
      evict_nobypass_data = {my_bit, symbolic_beat, 1'b1};
   end else if (!p2_stage_command_fifo_data_out[0] & 
                p2_stage_command_fifo_data_out[1] & 
                !p2_stage_command_fifo_data_out[2] &
                p2_stage_command_fifo_data_out[3] & 
                !p2_stage_command_fifo_data_out[4]) begin
      evict_nobypass_data = {my_bit,p2_stage_command_fifo_data_out[9:7]};
   end
end

wire [BURST_LEN_W+1:0] evict_nonbypass_data_fifo_data_in = evict_nobypass_data;
reg [BURST_LEN_W+1:0] evict_nonbypass_fifo_data_out;
reg evict_nonbypass_data_fifo_full;
reg evict_nonbypass_data_fifo_empty;

// Instantiation of fifo for data into evict port for non bypass case
fv_ccp_double_wr_port_queue #(
   .QUEUE_DEPTH(OUT_FIFO_DEPTH),
   .MEM_W(BURST_LEN_W+2)
)fv_ccp_evict_nonbypass_data_queue(
   .clk(clk),
   .reset_n(reset_n),
   .push_1(evict_nonbypass_data_fifo_push),
   .data_in_1(evict_nonbypass_data_fifo_data_in),
   .push_2(0),
   .data_in_2('d0),
   .sample_bit(),
   .pop(evict_nonbypass_data_fifo_rd_req),
   .data_out(evict_nonbypass_fifo_data_out),
   .full(evict_nonbypass_data_fifo_full),
   .empty(evict_nonbypass_data_fifo_empty)
);

// evict_data_out_cnt: counter for number of output data beats at evict port for
// a transaction
reg [BURST_LEN_W-1:0] evict_data_out_cnt;

always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      evict_data_out_cnt <= 'd0;
   end else if (cache_evict_valid & ctrl_evict_ready & cache_evict_last) begin
      evict_data_out_cnt <= 'd0;
   end else if (cache_evict_valid & ctrl_evict_ready) begin
      evict_data_out_cnt <= evict_data_out_cnt + 'd1;
   end
end

// If evict_valid and evict_ready and my_bit valid and symbolic_tag transaction
// and evict data beat number same as my_bit beat number than evict_data
// comparision
if_nonbypass_and_my_bit_legal_evict_data_match: assert property(
   @(posedge clk) disable iff(!reset_n)
   ((p2_stage_command_fifo_evict_data_out[1:0] == 2'b10) & cache_evict_valid & 
    ctrl_evict_ready & evict_nonbypass_fifo_data_out[0] &
    (evict_nonbypass_fifo_data_out[2:1] == evict_data_out_cnt) &
    !no_new_my_transaction)
   |->
   (cache_evict_data[my_bit_in_beat] == evict_nonbypass_fifo_data_out[3])
);

endmodule
