`define nassert(expr) assert property (@(posedge clk) disable iff(!reset_n) (expr)) 
`define ncover(expr) cover property (@(posedge clk) disable iff(!reset_n) (expr)) 
module fv_ccp_tag_bank_model #(
   parameter N_SETS = 1024,
   parameter SET_W = $clog2(N_SETS),
   parameter N_TAG_BANKS = 2,
   parameter BNK_W = $clog2(N_TAG_BANKS),
   parameter SET_PER_BANK = N_SETS/N_TAG_BANKS,
   parameter SET_PER_BANK_W = $clog2(SET_PER_BANK),
   parameter N_WAYS =2,
   parameter WAY_POINTER_W = $clog2(N_WAYS),
   parameter MAX_TAG_BANKS_W = 4,
   parameter TAG_PER_WAY_DATA_W = 25
) (
   input clk,
   input reset_n,
   input [SET_PER_BANK_W-1:0] my_set,
   input [MAX_TAG_BANKS_W-1:0] my_bnk,
   input [N_TAG_BANKS-1:0] tag_mem_chip_en,
   input [N_TAG_BANKS-1:0] tag_mem_write_en,
   input [(N_TAG_BANKS*N_WAYS)-1:0] tag_mem_write_en_mask,
   input [(N_TAG_BANKS*SET_PER_BANK_W)-1:0] tag_mem_address,
   input [(N_TAG_BANKS*N_WAYS*TAG_PER_WAY_DATA_W)-1:0] tag_mem_data_in,
   input [(N_TAG_BANKS*N_WAYS*TAG_PER_WAY_DATA_W)-1:0] tag_mem_data_out,
   output reg [(N_WAYS*TAG_PER_WAY_DATA_W)-1:0] my_set_bnk_mem
);

wire my_bnk_chip_en = tag_mem_chip_en[my_bnk];
wire my_bnk_write_en = tag_mem_write_en[my_bnk];
wire [N_WAYS-1:0] my_bnk_write_en_mask = 
   tag_mem_write_en_mask[(N_WAYS*my_bnk) +: N_WAYS];
wire [SET_PER_BANK_W-1:0] my_bnk_address = 
   tag_mem_address[(SET_PER_BANK_W*my_bnk) +: SET_PER_BANK_W];
wire [(N_WAYS*TAG_PER_WAY_DATA_W)-1:0] my_bnk_data_in =
   tag_mem_data_in[(N_WAYS*TAG_PER_WAY_DATA_W*my_bnk) +: (N_WAYS*TAG_PER_WAY_DATA_W)];
wire [(N_WAYS*TAG_PER_WAY_DATA_W)-1:0] my_bnk_data_out =
   tag_mem_data_out[(N_WAYS*TAG_PER_WAY_DATA_W*my_bnk) +: (N_WAYS*TAG_PER_WAY_DATA_W)];


reg [(N_WAYS*TAG_PER_WAY_DATA_W)-1:0] my_set_bnk_data_in;
always @(*) begin
   my_set_bnk_data_in = my_set_bnk_mem;
   for (int i=0; i<N_WAYS; i++) begin
      if(my_bnk_write_en_mask[i])
         my_set_bnk_data_in[(TAG_PER_WAY_DATA_W*i) +: TAG_PER_WAY_DATA_W] =
            my_bnk_data_in[(TAG_PER_WAY_DATA_W*i) +: TAG_PER_WAY_DATA_W];
   end
end

reg output_holds_my_set;
always @(posedge clk or negedge reset_n) begin
   if(!reset_n) begin
      my_set_bnk_mem <= 'd0;
      output_holds_my_set <= 1'b0;
   end
   else begin
      if(my_bnk_chip_en && my_bnk_write_en && (my_bnk_address == my_set)) begin
         my_set_bnk_mem <= my_set_bnk_data_in;
       end

      if(my_bnk_chip_en && !my_bnk_write_en) begin
         output_holds_my_set <= (my_bnk_address == my_set);
      end else begin
         output_holds_my_set <= 0;
      end
   end
end

asrt_tag_mem_sends_correct_data_for_my_set_bnk: assert property(
   @(posedge clk) disable iff(!reset_n)
   output_holds_my_set
   |->
   (my_bnk_data_out == my_set_bnk_mem)
);

endmodule
