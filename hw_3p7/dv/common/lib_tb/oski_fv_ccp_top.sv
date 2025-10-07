/*******************************************************************************
 * OSKI TECHNOLOGY CONFIDENTIAL 
 * Copyright (c) 2017 Oski Technology, All Rights Reserved.
 ******************************************************************************/

// ===========================================================================//
//                              Module Description                            //
// ===========================================================================//
// Top level CCP FV testbench file:
// 1. Contains Bind statement
// 2. Instantiates: fv_ccp_fill_intf, fv_ccp_fill_cons
// ===========================================================================//

<% if(((obj.testBench == "cbi") &&  (obj.isBridgeInterface && obj.useIoCache)) || (obj.testBench == "dmi" && obj.useCmc)) {%>


<%  if(obj.testBench == "cbi") { %>
    <% if (obj.BridgeAiuInfo[0].NativeInfo.IoCacheInfo.CacheInfo.IoTagErrorInfo.fnErrDetectCorrect == "NONE" && obj.isBridgeInterface && obj.useIoCache ) {%> 
   `define CCP_FV_ECC_DISABLED 
   <%}%>
<% } else { %>
   <%  if(obj.DmiInfo[0].ccpParams.DataErrInfo == "NONE") { %>
   `define CCP_FV_ECC_DISABLED 
   <%}%>
<% } %>

    <% if(obj.fnReplPolType == "RANDOM") {%>
   `define CCP_FV_NRU_POLICY 0
   `define CCP_FV_NRU_BIT_IN_TAG_MEM 0
   <%}else{%>
   `define CCP_FV_NRU_POLICY 1
   `define CCP_FV_NRU_BIT_IN_TAG_MEM 1
   <%}%>
    
    <% if(obj.nWays==1){%>
   `define CCP_FV_NUM_WAY_IS_1 
   <%}%>

   `define CCP_FV_NUM_SETS <%=obj.nSets%>
   `define CCP_FV_NUM_WAYS <%=obj.nWays%>
   `define CCP_FV_NUM_TAG_BANKS <%=obj.nTagBanks%>
   `define CCP_FV_NUM_DATA_BANKS <%=obj.nDataBanks%>
   `define CCP_FV_CACHE_STATE_W 2
   `define CCP_FV_DATA_WIDTH <%=obj.wXData + 1 %>
   `define CCP_FV_ADDR_WIDTH <%=obj.wSfiAddr%>
   `define CCP_FV_BURST_LEN_WIDTH <%=Math.log2(Math.pow(2,obj.wCacheLineOffset)*8/obj.wXData)%>
<% if( obj.testBench == "dmi") {%>
   `define CCP_FV_TABLE_ENTRIES <%=obj.nRttCtrlEntries%>
<% } else { %>
   `define CCP_FV_TABLE_ENTRIES <%=obj.nOttCtrlEntries%>
<% } %>
   
    <% if (obj.wSecurityAttribute > 0) { %>
   `define CCP_FV_SECURITY_BIT 1
   <%}else{%>
   `define CCP_FV_SECURITY_BIT 0
   <%}%>

<%
//Copied from Memgen by Muffadal on 07/12/2017. 
//Ensure this is always consistent with memgen

/************************************************************
 * Returns the number of bits required for error encoding.
 *
 * @arg {string} fnErrDetectCorrect - error encoding type.
 * @arg {Number} width - data width before encoding.
 * @return {Number} - The number of bits required for the error code.
 */
function getErrorEncodingWidth(fnErrDetectCorrect, width, blockWidths) {
    //u.log("EncodingWidth ... "+fnErrDetectCorrect+", "+width);
    var errWidth = 0;
    var resolution;

    if (fnErrDetectCorrect === 'PARITYENTRY') {
        errWidth = 1;
    } else if (fnErrDetectCorrect === 'PARITY16BITS') {
        errWidth = Math.ceil(width / 16);
    } else if (fnErrDetectCorrect === 'PARITY8BITS') {
        errWidth = Math.ceil(width / 8);
    } else if (fnErrDetectCorrect === 'SECDED') {
        if (width === 1) {
            errWidth = 3;
        } else if (width === 2) {
            errWidth = 4;
        } else {
            errWidth = Math.ceil(Math.log2(width + Math.ceil(Math.log2(width)) + 1)) + 1;
        }
        if (width <= 2) {
            throw new Error('SECDED Entry is not supported if data width <= 2.: ');
        }
    } else if (fnErrDetectCorrect === 'SECDED64BITS') {
        resolution = 64;
    } else if (fnErrDetectCorrect === 'SECDED128BITS') {
        resolution = 128;
    }

    var numInst;
    var wInstData;
    var inst;
    if (fnErrDetectCorrect === 'SECDED64BITS' ||
        fnErrDetectCorrect === 'SECDED128BITS') {
        if (blockWidths) {
            numInst = blockWidths.length;
            for (inst = 0; inst < numInst; inst++) {
                wInstData = blockWidths[inst];
                if (wInstData === 1) {
                    errWidth += 3;
                } else if (wInstData === 2) {
                    errWidth += 4;
                } else {
                    errWidth += Math.ceil(Math.log2(wInstData + Math.ceil(Math.log2(wInstData)) + 1)) + 1;
                }
            }
        } else {
            numInst = Math.ceil(width / resolution);
            for (inst = 0; inst < numInst; inst++) {
                if ((resolution * (inst + 1)) > width) {
                    wInstData = width % resolution;
                } else {
                    wInstData = resolution;
                }
                if (wInstData === 1) {
                    errWidth += 3;
                } else if (wInstData === 2) {
                    errWidth += 4;
                } else {
                    errWidth += Math.ceil(Math.log2(wInstData + Math.ceil(Math.log2(wInstData)) + 1)) + 1;
                }
            }
        }
    }

    return errWidth;
}

/************************************************************
 * Returns a vector of block widths that are as close as possible
 *
 * @arg {string} fnErrDetectCorrect - error encoding type.
 * @arg {Number} width - data width before encoding.
 * @arg {Number} extraBits - extra number of bits to be added to the first element
 * @return [{Number1},{Number2}...] - The vector of block widths.
 */
function getEvenBlockWidths(fnErrDetectCorrect, width, extraBits) {
    var idealNumBlock;
    if (fnErrDetectCorrect === 'SECDED64BITS') {
        idealNumBlock = Math.ceil(width / 64);
    } else if (fnErrDetectCorrect === 'SECDED128BITS') {
        idealNumBlock = Math.ceil(width / 128);
    } else {
        idealNumBlock = 1;
    }

    var evenBlockWidths = [];
    var tempWidth = width;

    for (var i = 0; i < idealNumBlock; i++) {

        if (fnErrDetectCorrect === 'SECDED64BITS') {
            if (i === 0) {
                if (tempWidth < 64) {
                    evenBlockWidths[i] = tempWidth + extraBits;
                } else {
                    evenBlockWidths[i] = 64 + extraBits;
                }
            } else {
                if (tempWidth < 64) {
                    evenBlockWidths[i] = tempWidth;
                } else {
                    evenBlockWidths[i] = 64;
                }
            }
            tempWidth = tempWidth - 64;
        } else if (fnErrDetectCorrect === 'SECDED128BITS') {
            if (i === 0) {
                if (tempWidth < 128) {
                    evenBlockWidths[i] = tempWidth + extraBits;
                } else {
                    evenBlockWidths[i] = 128 + extraBits;
                }
            } else {
                if (tempWidth < 128) {
                    evenBlockWidths[i] = tempWidth;
                } else {
                    evenBlockWidths[i] = 128;
                }
            }
            tempWidth = tempWidth - 128;
        } else {
            if (i === 0) {
                evenBlockWidths[i] = tempWidth + extraBits;
            } else {
                evenBlockWidths[i] = tempWidth;
            }
            tempWidth = 0;
        }

    }

    return evenBlockWidths;
}
    var wCompBits=0;
    if(obj.Block == "aiu" && obj.nAius > 1) {
    wCompBits =   this.log2ceil( Math.pow(2,obj.BridgeAiuInfo[obj.Id - obj.nAIUs].AiuSelectInfo.PriSubDiagAddrBits.length) / obj.nAius );
    }else if(obj.Block == "dmi" && obj.nDmis >1) {
    wCompBits =   this.log2ceil( Math.pow(2,obj.DmiInfo[obj.Id].DmiSelectInfo.PriSubDiagAddrBits.length) / obj.nDmis );
    }

    var dataWidth =  ( 
                        (obj.wSfiAddr         - 
                        obj.wCacheLineOffset  -
                        Math.log2(obj.nSets)) + 
                        ((obj.wSecurityAttribute > 0 ? 1 : 0) + 
                        2  +
                        (((obj.fnReplPolType == "NRU") && (obj.nReplPolMemPorts==1) && (obj.nWays > 1)) ? 1 : 0) +
                        wCompBits 
                        )  
                    );

    var blockWidths;
    if ((obj.fnErrDetectCorrect === 'SECDED64BITS') || (obj.fnErrDetectCorrect === 'SECDED128BITS')) {
        blockWidths = getEvenBlockWidths(obj.fnErrDetectCorrect, dataWidth, 0);
    } else {
        blockWidths = [dataWidth];
    }

    var tagPlusEccWidth = dataWidth + getErrorEncodingWidth( obj.fnErrDetectCorrect,dataWidth,blockWidths); 

    //console.log("Error value : %d", getErrorEncodingWidth(obj.fnErrDetectCorrect,dataWidth, blockWidths)); 

%>
   `define CCP_FV_TAG_PER_WAY_DATA_WIDTH <%=tagPlusEccWidth%>
   `define CCP_FV_TAG_ERR_BIT 6
   `define CCP_FV_TAG_ERR_INDEX_BIT 5
   `define CCP_FV_DATA_ERR_BIT 9

<%}else{%>
    //Default Value
   `define CCP_FV_ECC_DISABLED 
   `define CCP_FV_NRU_BIT_IN_TAG_MEM 1
   `define CCP_FV_NRU_POLICY 1
   `define CCP_FV_NUM_SETS 16
   `define CCP_FV_NUM_WAYS 4
   `define CCP_FV_NUM_TAG_BANKS 1
   `define CCP_FV_NUM_DATA_BANKS 1
   `define CCP_FV_CACHE_STATE_W 2
   `define CCP_FV_DATA_WIDTH 65
   `define CCP_FV_ADDR_WIDTH 32
   `define CCP_FV_BURST_LEN_WIDTH 2
   `define CCP_FV_TABLE_ENTRIES 64
   `define CCP_FV_SECURITY_BIT 1
   `define CCP_FV_TAG_PER_WAY_DATA_WIDTH 26
   `define CCP_FV_TAG_ERR_BIT 0
   `define CCP_FV_TAG_ERR_INDEX_BIT 0
   `define CCP_FV_DATA_ERR_BIT 9
<%}%>

module fv_ccp_top #(
   parameter N_SETS                       = `CCP_FV_NUM_SETS, // 1024,
   parameter SET_W                        = $clog2(N_SETS),
   parameter N_WAYS                       = `CCP_FV_NUM_WAYS, // 2,
   `ifndef CCP_FV_NUM_WAY_IS_1
      parameter WAY_POINTER_W             = $clog2(N_WAYS),
   `else
      // Over-write to a width of 1
      parameter WAY_POINTER_W             = 1,
   `endif
   parameter N_TAG_BANKS                  = `CCP_FV_NUM_TAG_BANKS, // 2,
   parameter BNK_W                        = $clog2(N_TAG_BANKS),
   parameter N_DATA_BANKS                 = `CCP_FV_NUM_DATA_BANKS, // 1,
   parameter SET_PER_BANK                 = N_SETS/N_TAG_BANKS,
   parameter SET_PER_BANK_W               = $clog2(SET_PER_BANK),
   parameter CACHE_LINE_OFFSET_W          = 6,
   parameter CACHE_STATE_W                = `CCP_FV_CACHE_STATE_W, // 2,
   parameter DATA_W                       = `CCP_FV_DATA_WIDTH, // 129,
   parameter ADDRESS_W                    = `CCP_FV_ADDR_WIDTH, // 32,
   parameter TAG_W                        = ADDRESS_W-(BNK_W+CACHE_LINE_OFFSET_W+SET_PER_BANK_W),
   parameter BURST_LEN_W                  = `CCP_FV_BURST_LEN_WIDTH, //2,
   parameter MAX_BEAT_IN_BURST            = (1 << BURST_LEN_W),
   parameter TABLE_ENTRIES                = `CCP_FV_TABLE_ENTRIES, // 64,
   parameter TABLE_ENTRIES_W              = $clog2(TABLE_ENTRIES),
   parameter SYM_BIT_W                    = $clog2((2**BURST_LEN_W)*(DATA_W-1)),
   parameter BIT_PNT                      = $clog2(DATA_W-1),
   parameter BYTE_EN_W                    = ((DATA_W-1)/8),
   // TODO: Why ERR_BIT - what is ERR_BIT
   parameter ERR_BIT                      = `CCP_FV_TAG_ERR_BIT, // 6,
   parameter SECURITY_BIT                 = `CCP_FV_SECURITY_BIT, // 1,
   parameter BEATS_PER_WAY                = MAX_BEAT_IN_BURST,
   parameter DATA_ERR_BIT                 = `CCP_FV_DATA_ERR_BIT, // 9
   parameter MAX_TAG_BANKS                = 4,
   parameter MAX_TAG_BANKS_W              = $clog2(MAX_TAG_BANKS),
   parameter NRU_IN_TAG_MEM               = `CCP_FV_NRU_BIT_IN_TAG_MEM,
   parameter TAG_PER_WAY_DATA_W           = `CCP_FV_TAG_PER_WAY_DATA_WIDTH,
   parameter NRU_POLICY_EN                = `CCP_FV_NRU_POLICY
)(
    input clk,
    input reset_n,
    input [N_TAG_BANKS-1:0] ctrl_op_valid_p0,
    input [ADDRESS_W-1:0] ctrl_op_address_p0,
    input ctrl_op_security_p0,
    input ctrl_op_cancel_p2, //TODO: Get it removed
    input ctrl_op_allocate_p2,
    input ctrl_op_read_data_p2,
    input ctrl_op_write_data_p2,
    input ctrl_op_port_sel_p2,
    input ctrl_op_bypass_p2,
    input ctrl_op_rp_update_p2,
    input ctrl_op_tag_state_update_p2,
    input [CACHE_STATE_W-1:0] ctrl_op_state_p2,
    input [BURST_LEN_W-1:0] ctrl_op_burst_len_p2,
    input ctrl_op_setway_debug_p2,
    input [N_WAYS-1:0] ctrl_op_ways_busy_vec_p2,
    input [N_WAYS-1:0] ctrl_op_ways_stale_vec_p2,
    input ctrl_wr_valid,
    input [DATA_W-1:0] ctrl_wr_data,
    input [BYTE_EN_W-1:0] ctrl_wr_byte_en,
    input [BURST_LEN_W-1:0] ctrl_wr_beat_num,
    input ctrl_wr_last,
    input ctrl_fill_data_valid,
    input [DATA_W-1:0] ctrl_fill_data,
    input [TABLE_ENTRIES_W-1:0] ctrl_fill_data_id,
    input [ADDRESS_W-1:0] ctrl_fill_data_address,
`ifndef CCP_FV_NUM_WAY_IS_1
    input [WAY_POINTER_W-1:0] ctrl_fill_data_way_num,
`endif
    input [BURST_LEN_W-1:0] ctrl_fill_data_beat_num,
    input ctrl_fill_valid,
    input [ADDRESS_W-1:0] ctrl_fill_address,
`ifndef CCP_FV_NUM_WAY_IS_1
    input [WAY_POINTER_W-1:0] ctrl_fill_way_num,
`endif
    input [CACHE_STATE_W-1:0] ctrl_fill_state,
    input ctrl_fill_security,
    input cache_evict_ready,
    input cache_rdrsp_ready,
    input CorrErrDetectEn,
    input UnCorrErrDetectEn,
    input reinit,
    input [3:0] maint_req_opcode,
    input [31:0] maint_req_data,
    input [31:0] maint_req_way,
    input [19:0] maint_req_entry,
    input [5:0] maint_req_word,
    input maint_req_array_sel,
    input [N_TAG_BANKS-1:0] cache_op_ready_p0,
    input [N_WAYS-1:0] cache_alloc_way_vec_p2,
    input [N_WAYS-1:0] cache_hit_way_vec_p2,
    input cache_valid_p2,
    input [CACHE_STATE_W-1:0] cache_current_state_p2,
    input cache_evict_valid_p2,
    input [ADDRESS_W-1:0] cache_evict_address_p2,
    input cache_evict_security_p2,
    input [CACHE_STATE_W-1:0] cache_evict_state_p2,
    input cache_nack_uce_p2,
    input cache_nack_p2,
    input cache_nack_ce_p2,
    input cache_nack_no_allocate_p2,
    input cache_wr_ready,
    input cache_fill_data_ready,
    input cache_fill_ready,
    input cache_fill_done,
    input [TABLE_ENTRIES_W-1:0] cache_fill_done_id,
    input cache_evict_valid,
    input [DATA_W-1:0] cache_evict_data,
    input [BYTE_EN_W-1:0] cache_evict_byteen,
    input cache_evict_last,
    input cache_evict_cancel,
    input cache_rdrsp_valid,
    input [DATA_W-1:0] cache_rdrsp_data,
    input [BYTE_EN_W-1:0] cache_rdrsp_byteen,
    input cache_rdrsp_last,
    input cache_rdrsp_cancel,
    input init_done,
    input maint_active,
    input [31:0] maint_read_data,
    input maint_read_data_en,
    input correctible_error_valid,
    input [3:0] correctible_error_type,
    input [7:0] correctible_error_info,
    input [19:0] correctible_error_entry,
    input [5:0] correctible_error_way,
    input [5:0] correctible_error_word,
    input correctible_error_double_error,
    input [11:0] correctible_error_addr_hi,
    input uncorrectible_error_valid,
    input [3:0] uncorrectible_error_type,
    input [7:0] uncorrectible_error_info,
    input [19:0] uncorrectible_error_entry,
    input [5:0] uncorrectible_error_way,
    input [5:0] uncorrectible_error_word,
    input uncorrectible_error_double_error,
    input [11:0] uncorrectible_error_addr_hi,

    input wr_only_bypass_valid,
    input wr_only_bypass,
    input wr_only_bypass_port,
    input write_control_fifo_ready,

    input datapipe_ctrl_op_valid,
`ifndef CCP_FV_NUM_WAY_IS_1
    input [(WAY_POINTER_W+4):0] datapipe_ctrl_op_data,
`else
    input [4:0] datapipe_ctrl_op_data,
`endif
    input datapipe_ctrl_op_ready,

    input rdrsp_port_valid1,
    input [N_DATA_BANKS:0] rdrsp_port_control1,
    input rdrsp_port_ready1,

    input rdrsp_port_valid0,
    input [N_DATA_BANKS:0] rdrsp_port_control0,
    input rdrsp_port_ready0,

    input evict_port_valid1,
    input [N_DATA_BANKS:0] evict_port_control1,
    input evict_port_ready1,

    input evict_port_valid0,
    input [N_DATA_BANKS:0] evict_port_control0,
    input evict_port_ready0,

    input [ADDRESS_W-1:0] rtl_ctrl_op_address_p2,
    input tagpipe_maint_read_data_en,
    input [31:0] tagpipe_maint_read_data,
    input datapipe_maint_read_data_en,
    input [31:0] datapipe_maint_read_data,
`ifndef CCP_FV_NUM_WAY_IS_1
    input [WAY_POINTER_W-1:0] random_counter,
`endif
    input [N_TAG_BANKS-1:0] tag_mem_chip_en,
    input [N_TAG_BANKS-1:0] tag_mem_write_en,
    input [(N_TAG_BANKS*N_WAYS)-1:0] tag_mem_write_en_mask,
    input [(N_TAG_BANKS*SET_PER_BANK_W)-1:0] tag_mem_address,
    input [(N_TAG_BANKS*N_WAYS*TAG_PER_WAY_DATA_W)-1:0] tag_mem_data_in,
    input [(N_TAG_BANKS*N_WAYS*TAG_PER_WAY_DATA_W)-1:0] tag_mem_data_out
);

`define nassert(expr) assert property (@(posedge clk) disable iff(!reset_n) (expr)) 
`define ncover(expr) cover property (@(posedge clk) disable iff(!reset_n) (expr)) 

// If there is only one 1 way, then there are no ports named 
// as ctrl_fill_way_num and ctrl_fill_data_way_num. Due to this,
// declare them as wires here, and assign them to 0
`ifdef CCP_FV_NUM_WAY_IS_1
wire [WAY_POINTER_W-1:0] ctrl_fill_way_num = 'b0;
wire [WAY_POINTER_W-1:0] ctrl_fill_data_way_num = 'b0;
`endif

reg oor_f;
always @(posedge clk or negedge reset_n) begin
   if(!reset_n)
      oor_f <= 1'b1;
   else
      oor_f <= 1'b0;
end

wire maint_read_unqual = 
   (maint_req_opcode == 4'b1100);
wire maint_write_unqual = 
   (maint_req_opcode == 4'b1110);
wire maint_recall_unqual =
   (maint_req_opcode == 4'b0101);

reg [WAY_POINTER_W-1:0] cache_alloc_way_p2;
reg [WAY_POINTER_W-1:0] cache_hit_way_p2;

always @(*) begin
   cache_alloc_way_p2 = 'b0;
   cache_hit_way_p2 = 'b0;
   for (int i=0; i<N_WAYS; i++) begin
      if(cache_alloc_way_vec_p2[i])
         cache_alloc_way_p2 = i;

      if(cache_hit_way_vec_p2[i])
         cache_hit_way_p2 = i;
   end
end

// restrict reint
`ifdef FORMAL
   restr_reinit_0: assert property(
      @(posedge clk) disable iff(!reset_n)
      reinit == 1'b0
   );
`endif

/*
restr_addr_and_maint_wr: `nassert(
   (ctrl_op_address_p0[
       (ADDRESS_W-1):
       (CACHE_LINE_OFFSET_W+SET_W+4)] == 'd0) &&
   (maint_req_data[
       31:
       (ERR_BIT+NRU_IN_TAG_MEM+CACHE_STATE_W+4)] == 'd0)
);
*/

wire [SET_PER_BANK_W-1:0] my_set;
wire [MAX_TAG_BANKS_W-1:0] my_bnk;

`ifdef FORMAL
   symbolic_variables_are_stable: `nassert(
      ##1 ((my_set == $past(my_set)) &&
           (my_bnk == $past(my_bnk)))
   );
   
   symbolic_variables_tag_legal_value: `nassert(
      (my_bnk < N_TAG_BANKS) &&
      (my_set < SET_PER_BANK)
   );

`endif

`ifndef CCP_FV_NUM_WAY_IS_1

   `ifdef FORMAL
      restr_random_counter_less_than_N_WAYS: `nassert(
         (random_counter < N_WAYS)
      );
   `endif

`endif

// CorrErrDetectEn and UnCorrErrDetectEn remain high
`ifdef FORMAL
   cfg2cache_CorrErr_remains_high: assert property(
      @(posedge clk) disable iff(!reset_n)
      ##1 (CorrErrDetectEn == $past(CorrErrDetectEn))
   );
`endif

`ifdef FORMAL
   cfg2cache_UnCorrErr_remains_high: assert property(
      @(posedge clk) disable iff(!reset_n)
      ##1 (UnCorrErrDetectEn == $past(UnCorrErrDetectEn))
   );
`endif

// ctrl_op_valid_p0 must br onehot0
ctrl2cache_op_valid_onehot0: assert property(
   @(posedge clk) disable iff(!reset_n)
   $onehot0(ctrl_op_valid_p0)
);

wire [SET_PER_BANK_W-1:0] op_p0_set;
wire [MAX_TAG_BANKS_W-1:0] op_p0_bnk;
wire [TAG_W-1:0] op_p0_tag;
fv_ccp_tagpipe_gen_index #(
   .N_SETS(N_SETS),
   .N_TAG_BANKS(N_TAG_BANKS),
   .ADDRESS_W(ADDRESS_W),
   .BNK_W(BNK_W),
   .TAG_W(TAG_W),
   .CACHE_LINE_OFFSET_W(CACHE_LINE_OFFSET_W),
   .MAX_TAG_BANKS(MAX_TAG_BANKS)
)fv_ccp_gen_index(
   .address_in(ctrl_op_address_p0),
   .bnk_num(op_p0_bnk),
   .set(op_p0_set),
   .tag(op_p0_tag)
);

// If ctrl_op_valid_p0[0] is asserted, then op_p0_bnk should be 0, else it
// should be 1
wire [N_TAG_BANKS-1:0] op_p0_bnk_vec = (1 << op_p0_bnk);

ctrl2cache_addr_bnk_matches_valid_bit: assert property(
   @(posedge clk) disable iff(!reset_n)
   |ctrl_op_valid_p0
   |->
   (ctrl_op_valid_p0 == op_p0_bnk_vec)
);

wire illegal_controls_p2 = 
    //Commented out by Muffadal on 06/26/2017 since this is 
    // legal for NCBU and confirmed with Parimal.
   /*(!ctrl_op_read_data_p2 && !ctrl_op_write_data_p2 && 
    ctrl_op_port_sel_p2 && !ctrl_op_bypass_p2) ||*/
   (!cache_evict_valid_p2 &&
    ctrl_op_read_data_p2 && !ctrl_op_write_data_p2 &&
    ctrl_op_bypass_p2) ||
   (!cache_evict_valid_p2 &&
    ctrl_op_read_data_p2 && ctrl_op_write_data_p2 &&
    !ctrl_op_bypass_p2) ||
   (cache_evict_valid_p2 &&
    ctrl_op_read_data_p2 && ctrl_op_write_data_p2 &&
    !ctrl_op_port_sel_p2 && ctrl_op_bypass_p2) ||
   (cache_evict_valid_p2 &&
    ctrl_op_read_data_p2 && ctrl_op_write_data_p2 &&
    ctrl_op_port_sel_p2 && ctrl_op_bypass_p2) ||
   (!cache_evict_valid_p2 && ctrl_op_read_data_p2 && ctrl_op_write_data_p2 &&
    !ctrl_op_port_sel_p2 && ctrl_op_bypass_p2) ||
   (!cache_evict_valid_p2 && ctrl_op_read_data_p2 && ctrl_op_write_data_p2 &&
    ctrl_op_port_sel_p2 && ctrl_op_bypass_p2);

// Constraints: Illegal scenerio at p2 stage not possible
ctrl2cache_no_illegal_controls_in_p2: assert property(
   @(posedge clk) disable iff (!reset_n)
   cache_valid_p2
   |->
   !illegal_controls_p2
);

// TODO -- cache_evict_valid_p2 is don't care in true-hit upgrade case
// If write is issued at the time of evict, ctrl_op_burst_len_p2
// burst length should be maximum
ctrl2cache_evict_and_write_then_burst_length_all: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_valid_p2 && ctrl_op_write_data_p2 && cache_evict_valid_p2)
   |->
   (ctrl_op_burst_len_p2 == {BURST_LEN_W{1'b1}})
);

// Constraint that no assertion of ctrl_op_tag_state_update_p2 if any nack 
// signal is asserted
ctrl2cache_op_tag_stat_update_never_at_nack: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_nack_uce_p2 ||
    cache_nack_p2 ||
    cache_nack_ce_p2 ||
    (ctrl_op_allocate_p2 && cache_nack_no_allocate_p2))
   |->
   !(ctrl_op_tag_state_update_p2 || ctrl_op_rp_update_p2)
);

// ctrl_op_tag_state_update_p2 can not be asserted if no cache_valid_p2
ctrl2cache_update_0_if_no_cache_valid: assert property(
   @(posedge clk) disable iff(!reset_n)
   !cache_valid_p2
   |->
   !(ctrl_op_tag_state_update_p2 || ctrl_op_rp_update_p2)
);

ctrl2cache_rp_update_only_on_hit: assert property(
   @(posedge clk) disable iff(!reset_n)
   !(cache_valid_p2 && (cache_current_state_p2 != 'd0))
   |->
   !ctrl_op_rp_update_p2
);

// Modelling for cache_valid_p2
reg cache_valid_p3;
reg cache_valid_p4;
always @(posedge clk or negedge reset_n) begin
   if (!reset_n) begin
      cache_valid_p3 <= 'd0;
      cache_valid_p4 <= 'd0;
   end else begin
      cache_valid_p3 <= cache_valid_p2;
      cache_valid_p4 <= cache_valid_p3;
   end
end

reg cache_nack_ce_p3;
reg cache_nack_ce_p4;
always @(posedge clk or negedge reset_n) begin
   if(!reset_n) begin 
      cache_nack_ce_p3 <= 'd0;
      cache_nack_ce_p4 <= 'd0;
   end else begin
      if (cache_valid_p2 && cache_nack_ce_p2) begin
         cache_nack_ce_p3 <= 1'b1;
      end else begin
         cache_nack_ce_p3 <= 'd0;
      end

      if (cache_valid_p3 && cache_nack_ce_p3) begin
         cache_nack_ce_p4 <= 1'b1;
      end else begin
         cache_nack_ce_p4 <= 'd0;
      end
   end
end

wire trn_mov_to_p1 = 
   (|(ctrl_op_valid_p0 & cache_op_ready_p0) &&
   !cache_nack_ce_p2 && !cache_nack_ce_p3);

wire trn_mov_to_p2 =
   !cache_nack_ce_p2 && !cache_nack_ce_p3;
   
wire trn_mov_to_p3 =
   !cache_nack_ce_p4 && !cache_nack_ce_p3;
   
reg [ADDRESS_W-1:0] ctrl_op_address_p1;
reg [ADDRESS_W-1:0] ctrl_op_address_p2;
reg ctrl_op_security_p1;
reg ctrl_op_security_p2;
always @(posedge clk) begin
   if(trn_mov_to_p1) begin
      ctrl_op_address_p1 <= ctrl_op_address_p0;
      ctrl_op_security_p1 <= ctrl_op_security_p0;
   end

   if(trn_mov_to_p2) begin
      ctrl_op_address_p2 <= ctrl_op_address_p1;
      ctrl_op_security_p2 <= ctrl_op_security_p1;
   end
      
end

reg trn_in_p1;
reg trn_in_p2;
always @(posedge clk or negedge reset_n) begin
   if(!reset_n) begin
      trn_in_p1 <= 'd0;
      trn_in_p2 <= 'd0;
   end
   else begin
      if(trn_mov_to_p1)
         trn_in_p1 <= |(ctrl_op_valid_p0 & cache_op_ready_p0);
      else if(trn_mov_to_p2)
         trn_in_p1 <= 1'b0;

      if(trn_mov_to_p2 && !cache_nack_ce_p4)
         trn_in_p2 <= trn_in_p1;
      else if(trn_mov_to_p3)
         trn_in_p2 <= 1'b0;
   end
end

wire cache_valid_p2_expected = 
   ((trn_in_p2 && !cache_nack_ce_p3) ||
    (cache_valid_p4 && cache_nack_ce_p4));

// cache_valid_p2 must be as expected
cache2ctrl_cache_valid_p2_matches_expected: assert property(
   @(posedge clk) disable iff(!reset_n)
   (cache_valid_p2 == cache_valid_p2_expected)
);

cov_cache_nack_ce_p2: cover property(
  @(posedge clk) disable iff(!reset_n)
  cache_nack_ce_p2
);

wire ctrl_fill_data_valid_first_beat;
wire ctrl_fill_data_valid_last_beat;
fv_ccp_fill_intf
   #(.N_WAYS(N_WAYS),
     .WAY_POINTER_W(WAY_POINTER_W),
     .CACHE_STATE_W(CACHE_STATE_W),
     .DATA_W(DATA_W),
     .ADDRESS_W(ADDRESS_W),
     .SECURITY_BIT(SECURITY_BIT),
     .BURST_LEN_W(BURST_LEN_W),
     .MAX_BEAT_IN_BURST(MAX_BEAT_IN_BURST),
     .TABLE_ENTRIES(TABLE_ENTRIES),
     .TABLE_ENTRIES_W(TABLE_ENTRIES_W)
    ) fv_ccp_fill_intf (
   .clk(clk),
   .reset_n(reset_n),
   .ctrl_fill_valid(ctrl_fill_valid),
   .ctrl_fill_address(ctrl_fill_address),
   .ctrl_fill_way_num(ctrl_fill_way_num),
   .ctrl_fill_state(ctrl_fill_state),
   .ctrl_fill_security(ctrl_fill_security),
   .cache_fill_ready(cache_fill_ready),
   .ctrl_fill_data_valid(ctrl_fill_data_valid),
   .ctrl_fill_data(ctrl_fill_data),
   .ctrl_fill_data_id(ctrl_fill_data_id),
   .ctrl_fill_data_address(ctrl_fill_data_address),
   .ctrl_fill_data_way_num(ctrl_fill_data_way_num),
   .ctrl_fill_data_beat_num(ctrl_fill_data_beat_num),
   .cache_fill_data_ready(cache_fill_data_ready),
   .cache_fill_done(cache_fill_done),
   .cache_fill_done_id(cache_fill_done_id),
   .ctrl_fill_data_valid_first_beat(ctrl_fill_data_valid_first_beat),
   .ctrl_fill_data_valid_last_beat(ctrl_fill_data_valid_last_beat)
);

`ifdef FORMAL
   fv_ccp_fill_cons 
      #(.N_SETS(N_SETS),
        .SET_W(SET_W),
        .N_TAG_BANKS(N_TAG_BANKS),
        .BNK_W(BNK_W),
        .SET_PER_BANK(SET_PER_BANK),
        .SET_PER_BANK_W(SET_PER_BANK_W),
        .N_WAYS(N_WAYS),
        .WAY_POINTER_W(WAY_POINTER_W),
        .DATA_W(DATA_W),
        .ADDRESS_W(ADDRESS_W),
        .CACHE_LINE_OFFSET_W(CACHE_LINE_OFFSET_W),
        .TAG_W(TAG_W),
        .CACHE_STATE_W(CACHE_STATE_W),
        .BURST_LEN_W(BURST_LEN_W),
        .SECURITY_BIT(SECURITY_BIT),
        .TABLE_ENTRIES(TABLE_ENTRIES),
        .TABLE_ENTRIES_W(TABLE_ENTRIES_W),
        .ERR_BIT(ERR_BIT),
        .MAX_TAG_BANKS(MAX_TAG_BANKS),
        .NRU_IN_TAG_MEM(NRU_IN_TAG_MEM),
        .TAG_PER_WAY_DATA_W(TAG_PER_WAY_DATA_W),
        .NRU_POLICY_EN(NRU_POLICY_EN)
       ) fv_ccp_fill_cons (
      .clk(clk),
      .reset_n(reset_n),
      .oor_f(oor_f),
      .my_set(my_set),
      .my_bnk(my_bnk),
      .ctrl_op_address_p2(ctrl_op_address_p2),
      .ctrl_op_security_p2(ctrl_op_security_p2),
      .cache_valid_p2(cache_valid_p2),
      .ctrl_op_allocate_p2(ctrl_op_allocate_p2),
      .cache_nack_uce_p2(cache_nack_uce_p2),
      .cache_nack_p2(cache_nack_p2),
      .cache_nack_ce_p2(cache_nack_ce_p2),
      .cache_nack_no_allocate_p2(cache_nack_no_allocate_p2),
      .ctrl_op_read_data_p2(ctrl_op_read_data_p2),
      .ctrl_op_write_data_p2(ctrl_op_write_data_p2),
      .ctrl_op_tag_state_update_p2(ctrl_op_tag_state_update_p2),
      .ctrl_op_rp_update_p2(ctrl_op_rp_update_p2),
      .ctrl_op_state_p2(ctrl_op_state_p2),
      .ctrl_op_setway_debug_p2(ctrl_op_setway_debug_p2),
      .ctrl_op_ways_busy_vec_p2(ctrl_op_ways_busy_vec_p2),
      .ctrl_op_ways_stale_vec_p2(ctrl_op_ways_stale_vec_p2),
      .cache_alloc_way_vec_p2(cache_alloc_way_vec_p2),
      .cache_hit_way_vec_p2(cache_hit_way_vec_p2),
      .cache_alloc_way_p2(cache_alloc_way_p2),
      .cache_hit_way_p2(cache_hit_way_p2),
      .ctrl_fill_valid(ctrl_fill_valid),
      .ctrl_fill_address(ctrl_fill_address),
      .ctrl_fill_way_num(ctrl_fill_way_num),
      .ctrl_fill_state(ctrl_fill_state),
      .ctrl_fill_security(ctrl_fill_security),
      .cache_fill_ready(cache_fill_ready),
      .ctrl_fill_data_valid(ctrl_fill_data_valid),
      .ctrl_fill_data(ctrl_fill_data),
      .ctrl_fill_data_id(ctrl_fill_data_id),
      .ctrl_fill_data_address(ctrl_fill_data_address),
      .ctrl_fill_data_way_num(ctrl_fill_data_way_num),
      .ctrl_fill_data_beat_num(ctrl_fill_data_beat_num),
      .cache_fill_data_ready(cache_fill_data_ready),
      .cache_fill_done(cache_fill_done),
      .cache_fill_done_id(cache_fill_done_id),
      .ctrl_fill_data_valid_first_beat(ctrl_fill_data_valid_first_beat),
      .ctrl_fill_data_valid_last_beat(ctrl_fill_data_valid_last_beat),
      .maint_req_opcode(maint_req_opcode),
      .maint_req_data(maint_req_data),
      .maint_req_way(maint_req_way),
      .maint_req_entry(maint_req_entry),
      .maint_req_word(maint_req_word),
      .maint_req_array_sel(maint_req_array_sel),
      .maint_read_data(maint_read_data),
   
      .cache_current_state_p2(cache_current_state_p2),
      .cache_evict_valid_p2(cache_evict_valid_p2),
      .cache_evict_address_p2(cache_evict_address_p2),
      .cache_evict_security_p2(cache_evict_security_p2),
      .cache_evict_state_p2(cache_evict_state_p2),
   
      .tag_mem_chip_en(tag_mem_chip_en),
      .tag_mem_write_en(tag_mem_write_en),
      .tag_mem_write_en_mask(tag_mem_write_en_mask),
      .tag_mem_address(tag_mem_address),
      .tag_mem_data_in(tag_mem_data_in),
      .tag_mem_data_out(tag_mem_data_out)
   );
   
`else

generate 
   for (genvar i=0; i<N_TAG_BANKS; i++) begin: bnk
      for (genvar j=0; j<SET_PER_BANK; j++) begin: set
         fv_ccp_fill_cons 
            #(.N_SETS(N_SETS),
              .SET_W(SET_W),
              .N_TAG_BANKS(N_TAG_BANKS),
              .BNK_W(BNK_W),
              .SET_PER_BANK(SET_PER_BANK),
              .SET_PER_BANK_W(SET_PER_BANK_W),
              .N_WAYS(N_WAYS),
              .WAY_POINTER_W(WAY_POINTER_W),
              .DATA_W(DATA_W),
              .ADDRESS_W(ADDRESS_W),
              .CACHE_LINE_OFFSET_W(CACHE_LINE_OFFSET_W),
              .TAG_W(TAG_W),
              .CACHE_STATE_W(CACHE_STATE_W),
              .BURST_LEN_W(BURST_LEN_W),
              .SECURITY_BIT(SECURITY_BIT),
              .TABLE_ENTRIES(TABLE_ENTRIES),
              .TABLE_ENTRIES_W(TABLE_ENTRIES_W),
              .ERR_BIT(ERR_BIT),
              .MAX_TAG_BANKS(MAX_TAG_BANKS),
              .NRU_IN_TAG_MEM(NRU_IN_TAG_MEM),
              .TAG_PER_WAY_DATA_W(TAG_PER_WAY_DATA_W),
              .NRU_POLICY_EN(NRU_POLICY_EN)
             ) fv_ccp_fill_cons (
            .clk(clk),
            .reset_n(reset_n),
            .oor_f(oor_f),
            .my_set(j[SET_PER_BANK_W-1:0]),
            .my_bnk(i[MAX_TAG_BANKS_W-1:0]),
            .ctrl_op_address_p2(ctrl_op_address_p2),
            .ctrl_op_security_p2(ctrl_op_security_p2),
            .cache_valid_p2(cache_valid_p2),
            .ctrl_op_allocate_p2(ctrl_op_allocate_p2),
            .cache_nack_uce_p2(cache_nack_uce_p2),
            .cache_nack_p2(cache_nack_p2),
            .cache_nack_ce_p2(cache_nack_ce_p2),
            .cache_nack_no_allocate_p2(cache_nack_no_allocate_p2),
            .ctrl_op_read_data_p2(ctrl_op_read_data_p2),
            .ctrl_op_write_data_p2(ctrl_op_write_data_p2),
            .ctrl_op_tag_state_update_p2(ctrl_op_tag_state_update_p2),
            .ctrl_op_rp_update_p2(ctrl_op_rp_update_p2),
            .ctrl_op_state_p2(ctrl_op_state_p2),
            .ctrl_op_setway_debug_p2(ctrl_op_setway_debug_p2),
            .ctrl_op_ways_busy_vec_p2(ctrl_op_ways_busy_vec_p2),
            .ctrl_op_ways_stale_vec_p2(ctrl_op_ways_stale_vec_p2),
            .cache_alloc_way_vec_p2(cache_alloc_way_vec_p2),
            .cache_hit_way_vec_p2(cache_hit_way_vec_p2),
            .cache_alloc_way_p2(cache_alloc_way_p2),
            .cache_hit_way_p2(cache_hit_way_p2),
            .ctrl_fill_valid(ctrl_fill_valid),
            .ctrl_fill_address(ctrl_fill_address),
            .ctrl_fill_way_num(ctrl_fill_way_num),
            .ctrl_fill_state(ctrl_fill_state),
            .ctrl_fill_security(ctrl_fill_security),
            .cache_fill_ready(cache_fill_ready),
            .ctrl_fill_data_valid(ctrl_fill_data_valid),
            .ctrl_fill_data(ctrl_fill_data),
            .ctrl_fill_data_id(ctrl_fill_data_id),
            .ctrl_fill_data_address(ctrl_fill_data_address),
            .ctrl_fill_data_way_num(ctrl_fill_data_way_num),
            .ctrl_fill_data_beat_num(ctrl_fill_data_beat_num),
            .cache_fill_data_ready(cache_fill_data_ready),
            .cache_fill_done(cache_fill_done),
            .cache_fill_done_id(cache_fill_done_id),
            .ctrl_fill_data_valid_first_beat(ctrl_fill_data_valid_first_beat),
            .ctrl_fill_data_valid_last_beat(ctrl_fill_data_valid_last_beat),
            .maint_req_opcode(maint_req_opcode),
            .maint_req_data(maint_req_data),
            .maint_req_way(maint_req_way),
            .maint_req_entry(maint_req_entry),
            .maint_req_word(maint_req_word),
            .maint_req_array_sel(maint_req_array_sel),
            .maint_read_data(maint_read_data),
         
            .cache_current_state_p2(cache_current_state_p2),
            .cache_evict_valid_p2(cache_evict_valid_p2),
            .cache_evict_address_p2(cache_evict_address_p2),
            .cache_evict_security_p2(cache_evict_security_p2),
            .cache_evict_state_p2(cache_evict_state_p2),
         
            .tag_mem_chip_en(tag_mem_chip_en),
            .tag_mem_write_en(tag_mem_write_en),
            .tag_mem_write_en_mask(tag_mem_write_en_mask),
            .tag_mem_address(tag_mem_address),
            .tag_mem_data_in(tag_mem_data_in),
            .tag_mem_data_out(tag_mem_data_out)
         );
     end
  end
      
endgenerate
`endif

// Maint related constraints
// Maint imply no other control
ctrl2cache_maint_imply_all_ctrl_sigs_0: `nassert(
   ctrl_op_setway_debug_p2
   |->
   (!ctrl_op_allocate_p2 &&
    !ctrl_op_read_data_p2 &&
    !ctrl_op_write_data_p2 &&
    //!ctrl_op_rp_update_p2 &&
    //!ctrl_op_tag_state_update_p2 &&
    !ctrl_op_bypass_p2)
);

// TODO: Parimal had indicated read too --
ctrl2cache_maint_non_recall_imply_rp_tag_update_zero: `nassert(
   (ctrl_op_setway_debug_p2 && 
    !(maint_recall_unqual && !maint_req_array_sel))
   |->
   (!ctrl_op_rp_update_p2 && !ctrl_op_tag_state_update_p2)
);

ctrl2cache_maint_imply_no_ctrl_op_in_this_cycle: `nassert(
   ctrl_op_setway_debug_p2
   |->
   (ctrl_op_valid_p0 == 'b0)
);

reg [N_TAG_BANKS-1:0] ctrl_op_valid_p0_d1;
always @(posedge clk) begin
   ctrl_op_valid_p0_d1 <= ctrl_op_valid_p0;
end

ctrl2cache_maint_op_valid_imply_no_maint_in_next_cycle: `nassert(
   (ctrl_op_valid_p0_d1 != 'd0)
   |->
   !ctrl_op_setway_debug_p2
);

ctrl2cache_maint_never_wo_cache_valid: `nassert(
   !cache_valid_p2
   |->
   !ctrl_op_setway_debug_p2
);

ctrl2cache_maint_never_at_nack: `nassert(
   (//cache_nack_uce_p2 ||
    cache_nack_p2 //||
    //cache_nack_ce_p2 ||
    //cache_nack_no_allocate_p2
   ) 
   |->
   !ctrl_op_setway_debug_p2
);

/*
ctrl2cache_maint_never_when_already_active: `nassert(
   maint_active_state
   |->
   !ctrl_op_setway_debug_p2
);

ctrl2cache_maint_active_then_maint_param_holds: assert property(
   @(posedge clk) disable iff(!reset_n)
   maint_active_state
   |->
   ((maint_req_word == $past(maint_req_word)) &&
    (maint_req_way == $past(maint_req_way)) &&
    (maint_req_array_sel == $past(maint_req_array_sel)) &&
    (maint_req_opcode == $past(maint_req_opcode)) &&
    (maint_req_data == $past(maint_req_data)))
);
*/

ctrl2cache_maint_burst_len_0: assert property(
   @(posedge clk) disable iff(!reset_n)
   ctrl_op_setway_debug_p2
   |->
   (ctrl_op_burst_len_p2 == 'd0)
);


ctrl2cache_maint_opcode_legal_tag: `nassert(
   (ctrl_op_setway_debug_p2 && !maint_req_array_sel)
   |->
   (maint_read_unqual || maint_write_unqual || maint_recall_unqual)
);

ctrl2cache_maint_opcode_legal_data: `nassert(
   (ctrl_op_setway_debug_p2 && maint_req_array_sel)
   |->
   (maint_read_unqual || maint_write_unqual)
);

// Tag - specific
// Heavyweight -- 
// If there is tag or nru update in previous cycle, don't issue maint
reg ctrl_tag_mem_wr_p3;
always @(posedge clk or negedge reset_n) begin
   if(!reset_n)
      ctrl_tag_mem_wr_p3 <= 1'b0;
   else if(cache_valid_p2 && !cache_nack_ce_p2)
      ctrl_tag_mem_wr_p3 <= 
         (ctrl_op_tag_state_update_p2 || ctrl_op_rp_update_p2);
   else if(!(cache_nack_ce_p2 || cache_nack_ce_p3))
      ctrl_tag_mem_wr_p3 <= 1'b0;
end

ctrl2cache_maint_tag_never_if_update_pending: `nassert(
   ctrl_tag_mem_wr_p3
   |->
   !(ctrl_op_setway_debug_p2 && !maint_req_array_sel)
);

ctrl2cache_maint_req_way_for_tag_is_legal: `nassert(
   (ctrl_op_setway_debug_p2 && !maint_req_array_sel)
   |->
   (maint_req_way < N_WAYS)
);

ctrl2cache_maint_req_word_for_tag_is_legal: `nassert(
   (ctrl_op_setway_debug_p2 && !maint_req_array_sel)
   |->
   (maint_req_word < 4)
);

// TODO:
ctrl2cache_maint_recall_state_if_updated_set_to_0: `nassert(
   (ctrl_op_setway_debug_p2 && !maint_req_array_sel && 
    maint_recall_unqual && ctrl_op_tag_state_update_p2)
   |->
   (ctrl_op_state_p2 == 'd0)
);

/*
ctrl2cache_maint_recall_state_update_only_if_current_state_nz: `nassert(
   (ctrl_op_setway_debug_p2 && !maint_req_array_sel &&
    maint_recall_unqual && (cache_current_state_p2 == 'b0))
   |->
   !(ctrl_op_tag_state_update_p2 || ctrl_op_rp_update_p2)
);
*/

asrt_never_ce_uce_at_maint_data: `nassert(
   (ctrl_op_setway_debug_p2 && maint_req_array_sel)
   |->
   !(cache_nack_ce_p2 || cache_nack_uce_p2)
);

asrt_never_ce_at_maint_tag_except_recall: `nassert(
   (ctrl_op_setway_debug_p2 && !maint_req_array_sel &&
    !maint_recall_unqual)
   |->
   !(cache_nack_ce_p2 || cache_nack_uce_p2)
);

asrt_maint_read_data_en: `nassert(
   maint_read_data_en 
   ==
   (tagpipe_maint_read_data_en || datapipe_maint_read_data_en)
);

asrt_tagpipe_maint_read_data_en: `nassert(
   tagpipe_maint_read_data_en
   ==
   (ctrl_op_setway_debug_p2 && !maint_req_array_sel &&
    maint_read_unqual)
);

// Note: Checkers for word = 0 are in fv_ccp_fill_cons level
asrt_tagpipe_maint_read_data_0_when_word_nz: `nassert(
   (tagpipe_maint_read_data_en && (maint_req_word != 'd0))
   |->
   (maint_read_data == 'b0)
);

asrt_cache_valid_0_imply_ce_uce_0: `nassert(
   !cache_valid_p2
   |->
   !(cache_nack_uce_p2 || cache_nack_ce_p2)
);
   
// Note: below property holds true if ce occurred, but not for uce.
// Due to this, antecedent only has ce 
asrt_cache_nack_ce_imply_both_0_in_next: `nassert(
   (cache_nack_ce_p2)
   |-> ##1
   !(cache_nack_uce_p2 || cache_nack_ce_p2) 
);

asrt_cache_nack_ce_imply_both_0_in_next_to_next_cycle: `nassert(
   (cache_nack_ce_p2)
   |-> ##2
   !(cache_nack_uce_p2 || cache_nack_ce_p2) 
);

// TODO: checkers on datapipe op valid and datapipe word
endmodule

