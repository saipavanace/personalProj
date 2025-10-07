module fv_ccp_tagpipe_gen_index #(
   parameter N_SETS = 1024,
   parameter N_TAG_BANKS = 2,
   parameter BNK_W = $clog2(N_TAG_BANKS),
   parameter SET_PER_BANK = N_SETS/N_TAG_BANKS,
   parameter SET_PER_BANK_W = $clog2(SET_PER_BANK),
   parameter ADDRESS_W = 32,
   parameter CACHE_LINE_OFFSET_W = 6,
   parameter TAG_W = ADDRESS_W-(BNK_W+CACHE_LINE_OFFSET_W+SET_PER_BANK_W),
   parameter SET_END_BIT = SET_PER_BANK_W+CACHE_LINE_OFFSET_W,
   parameter TAG_START_BIT = SET_PER_BANK_W+BNK_W+CACHE_LINE_OFFSET_W,
   parameter MAX_TAG_BANKS = 4,
   parameter MAX_TAG_BANKS_W = $clog2(MAX_TAG_BANKS)
)(
   input [ADDRESS_W-1:0] address_in,
   output reg [MAX_TAG_BANKS_W-1:0] bnk_num,
   output reg [TAG_W-1:0] tag,
   output reg [SET_PER_BANK_W-1:0] set
);

import <%=obj.BlockId%>_env_pkg::*;
import addr_trans_mgr_pkg::*;

bit [$clog2(N_SETS)-1:0]  ccp_index;
int cnt;

wire [ADDRESS_W-1:0] addr_in = address_in;
reg [SET_PER_BANK_W+BNK_W-1:0] index_out;


always @(*) begin
    
    <% if((obj.testBench == "cbi") && (obj.isBridgeInterface && obj.useIoCache) ) {%>
       ccp_index = addrMgrConst::get_cache_set_select_index(addr_in,<%=obj.SlvId%>);

        <% if(obj.nTagBanks>1){%>
        cnt = 0;
        for(int i=0; i<$size(ccp_index); i++) begin
            if(i != <%=obj.BridgeAiuInfo[0].NativeInfo.IoCacheInfo.CacheInfo.TagBankSelBits[0]%>) begin 
                set[cnt] = ccp_index[i]; 
                cnt++;
            end
        end

        bnk_num = ccp_index[<%=obj.BridgeAiuInfo[0].NativeInfo.IoCacheInfo.CacheInfo.TagBankSelBits[0]%>];
        <%}else{%>
        set = ccp_index;
        bnk_num = 'd0;
        <%}%>
    
    
    <%} else if((obj.testBench == "dmi") && (obj.useCmc) ) {%>
    
       ccp_index = addrMgrConst::get_cache_set_select_index(addr_in,<%=obj.SlvId%>);

        <% if(obj.nTagBanks>1){%>
        cnt = 0;
        for(int i=0; i<$size(ccp_index); i++) begin
            if(i != <%=obj.DmiInfo[0].ccpParams.TagBankSelBits[0]%>) begin 
                set[cnt] = ccp_index[i]; 
                cnt++;
            end
        end

        bnk_num = ccp_index[<%=obj.DmiInfo[0].ccpParams.TagBankSelBits[0]%>];
        <%}else{%>
        set = ccp_index;
        bnk_num = 'd0;
        <%}%>
    
    <%}else{%>
    set = 'd0;
    bnk_num = 'd0;
    <%}%>
    
    <% if(((obj.testBench == "cbi") && obj.isBridgeInterface && obj.useIoCache) || (obj.testBench == "dmi")){%>
    tag = addrMgrConst::get_tag_bits(addr_in,<%=obj.SlvId%>);
    <%}%>
end




endmodule
