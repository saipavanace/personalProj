module fv_ccp_evict_address #(
   parameter N_SETS = 1024,
   parameter N_TAG_BANKS = 2,
   parameter SET_PER_BANK = N_SETS/N_TAG_BANKS,
   parameter SET_PER_BANK_W = $clog2(SET_PER_BANK),
   parameter ADDRESS_W = 40,
   parameter CACHE_LINE_OFFSET_W = 6,
   parameter BNK_W = $clog2(N_TAG_BANKS),
   parameter TAG_W = ADDRESS_W-(BNK_W+CACHE_LINE_OFFSET_W+SET_PER_BANK_W),
   parameter SET_END_BIT = SET_PER_BANK_W+CACHE_LINE_OFFSET_W,
   parameter TAG_START_BIT = SET_PER_BANK_W+BNK_W+CACHE_LINE_OFFSET_W+1
)(
   input [ADDRESS_W-1:0] ctrl_op_address_p2,
   input [TAG_W-1:0] tag,
   output reg [ADDRESS_W-1:0] evict_address
);

always @(*) begin
      evict_address[CACHE_LINE_OFFSET_W-1:0] = 
               ctrl_op_address_p2[CACHE_LINE_OFFSET_W-1:0];
      evict_address[SET_END_BIT+1] = 
               ctrl_op_address_p2[SET_END_BIT+1];
      evict_address[SET_END_BIT-1:CACHE_LINE_OFFSET_W] = 
               ctrl_op_address_p2[SET_END_BIT-1:CACHE_LINE_OFFSET_W];
      evict_address[SET_END_BIT] = tag[0];
      evict_address[ADDRESS_W-1:TAG_START_BIT] = tag [TAG_W-1:1];   
end

endmodule
