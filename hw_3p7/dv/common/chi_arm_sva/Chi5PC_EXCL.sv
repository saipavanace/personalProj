//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may 
// only be used by a person authorised under and to the extent permitted 
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file 
// and copies of this file may only be made by a person if such person is 
// permitted to do so under the terms of a subsisting license agreement 
// from ARM Limited.
//
//----------------------------------------------------------------------------
//  Version and Release Control Information:
//
//  File Revision       : 179733
//
//  Date                :  2014-08-27 17:38:07 +0100 (Wed, 27 Aug 2014)
//
//  Release Information : BP066-BU-01000-r0p0-00lac0
//
//------------------------------------------------------------------------------
//  Purpose             :Monitor exclusives
//                          
//----------------------------------------------------------------------------
// CONTENTS
// ========
//  50.  Module: Chi5PC_EXCL
//  77.    1) Verilog Defines
//  80.         - Clock and Reset
// 106.    2)  Exclusive Tracking
// 528.    3)  Exclusive rules
// 533.         - CHI5PC_REC_REQ_EXCL_FAIL
// 547.         - CHI5PC_ERR_RSP_EXCL_FAIL
// 562.         - CHI5PC_ERR_REQ_EXCL_OVFLW
// 575.    4) Clear Verilog Defines
// 583.    5) End of module
//----------------------------------------------------------------------------
`ifndef CHI5PC_OFF

`ifndef CHI5PC_TYPES
  `include "Chi5PC_Chi5_defines.v"
`endif
  `include "Chi5PC_defines.v"



//------------------------------------------------------------------------------
// INDEX: Module: Chi5PC_EXCL
//------------------------------------------------------------------------------
module Chi5PC_EXCL #(NODE_TYPE = Chi5PC_pkg::RNF,
                  REQ_RSVDC_WIDTH = 4,
                  DAT_RSVDC_WIDTH = 4,
                  DAT_FLIT_WIDTH = `CHI5PC_128B_DAT_FLIT_WIDTH,
                  MAX_OS_EXCL = 16,
                  MODE = 1,
                  ErrorOn_SW = 1)
      (Chi5PC_if Chi5_in
     ,input wire SRESETn
     ,input wire SCLK
     ,input wire REQFLITV_
     ,input wire [`CHI5PC_REQ_FLIT_RANGE]REQFLIT_
     ,input wire S_RSPFLITV_
     ,input wire [`CHI5PC_RSP_FLIT_RANGE]S_RSPFLIT_
     ,input wire RDDATFLITV_
     ,input wire [DAT_FLIT_WIDTH-1:0]RDDATFLIT_
     ,input wire RDDAT_Last_
     ,input reg [44:0] S_RSP_Addr_NS
     ,input reg [3:0] S_RSP_Dev_Size
     ,input reg S_RSP_Comp_Wr
     );
  import Chi5PC_pkg::*;
  typedef Chi5_in.Chi5PC_Excl_Info Chi5PC_Excl_Info;

// ---------------------------------------------------------
// INDEX:   1) Verilog Defines
//------------------------------------------------------------------------------

  // INDEX:        - Clock and Reset
  // =====
  // Can be overridden by user for a clock enable.
  //
  `ifdef CHI5_SVA_CLK
  `else
     `define CHI5_SVA_CLK SCLK
  `endif
  //
  `ifdef CHI5_SVA_RSTn
  `else
     `define CHI5_SVA_RSTn SRESETn
  `endif
  // 
  // AUX: Auxiliary Logic
  `ifdef CHI5_AUX_CLK
  `else
     `define CHI5_AUX_CLK SCLK
  `endif
  //
  `ifdef CHI5_AUX_RSTn
  `else
     `define CHI5_AUX_RSTn SRESETn
  `endif
  
//------------------------------------------------------------------------------
// INDEX:   2)  Exclusive Tracking
//------------------------------------------------------------------------------ 
//assumptions: 
//monitors are not disarmed on STREX
//Parallel LDEX/STREX from same SRC/LPID are allowed
//only one snoopable plus one nonsnoopable entry is allowed per SRC/LPID
  localparam MAX_OS_EXCL_LOCAL     = (((NODE_TYPE == SNI) || (NODE_TYPE == SNF)) || (((NODE_TYPE == HNF) || (NODE_TYPE == HNI)) && (MODE == 1))) ?  MAX_OS_EXCL : 2*MAX_OS_EXCL;
  localparam LOG2MAX_OS_EXCL_LOCAL       = clogb2(MAX_OS_EXCL_LOCAL);


  Chi5PC_Excl_Info Info [1:MAX_OS_EXCL_LOCAL];
  Chi5PC_Excl_Info Current_RSP_Info;
  Chi5PC_Excl_Info Current_RDDAT_Info;
  Chi5PC_Excl_Info Current_STREX_REQ_Info ;
  Chi5PC_Excl_Info Current_LDEX_REQ_Info ;
  reg        [LOG2MAX_OS_EXCL_LOCAL-1:0]     Info_Index_next;
  reg        [1:MAX_OS_EXCL_LOCAL]     Info_Alloc_vector;
  logic      [1:MAX_OS_EXCL_LOCAL]     LDEX_REQ_match_vector;
  logic      [1:MAX_OS_EXCL_LOCAL]     STREX_REQ_match_vector;
  logic                          STREX_REQ_match;
  logic      [1:MAX_OS_EXCL_LOCAL]     RDDAT_match_vector;
  logic      [1:MAX_OS_EXCL_LOCAL]     S_RSP_match_vector;
  reg                            RDDAT_match;
  reg                            S_RSP_match;
  reg        [LOG2MAX_OS_EXCL_LOCAL:1] LDEX_REQ_Info_Index;
  reg        [LOG2MAX_OS_EXCL_LOCAL:1] STREX_REQ_Info_Index;
  reg        [LOG2MAX_OS_EXCL_LOCAL:1] S_RSP_Info_Index;
  reg        [LOG2MAX_OS_EXCL_LOCAL:1] RDDAT_Info_Index;
  reg                            EXCL_ovflw;
  //avoids race around ovflow assertion
  reg                            EXCL_ovflw_delay1; 
  reg                            STREX_RSP;

  logic [`CHI5PC_REQ_FLIT_MEMATTR_WIDTH-1:0] mem_attr;
  logic [`CHI5PC_MEMATTR_DEVICE_WIDTH-1:0] memattr_device;
  assign mem_attr = REQFLIT_[`CHI5PC_REQ_FLIT_MEMATTR_RANGE];    
  assign memattr_device = mem_attr[`CHI5PC_MEMATTR_DEVICE_RANGE]; 
  logic [`CHI5PC_REQ_FLIT_ADDR_WIDTH-1:0] REQ_ADDR;
  logic payload_match;
  logic [`CHI5PC_REQ_FLIT_ADDR_WIDTH-1:0] req_addr;
  assign req_addr = REQFLIT_[`CHI5PC_REQ_FLIT_ADDR_RANGE];
  logic [63:0] tmp_BE;
  assign tmp_BE = (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) ? 64'h3F : Chi5_in.Expect_BE(req_addr[5:0],memattr_device,REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE]);
  wire LDEX_nonsnoop;
  wire STREX_nonsnoop;
  wire LDEX_snoop;
  wire STREX_snoop;
  assign LDEX_nonsnoop = REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] && 
           (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READNOSNP);
  assign STREX_nonsnoop = REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] && 
           ((REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPPTL) ||
           (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPFULL) );
  assign LDEX_snoop = REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] && 
           ( (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READSHARED) ||
           (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READCLEAN) );
  assign STREX_snoop = REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] && 
           (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANUNIQUE);


  assign REQ_ADDR = REQFLIT_[`CHI5PC_REQ_FLIT_ADDR_RANGE];
  assign payload_match =  STREX_REQ_match && 
         ((Current_STREX_REQ_Info.Size ==  REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE]) || !ErrorOn_SW )&&
          (Current_STREX_REQ_Info.MemAttr ==  REQFLIT_[`CHI5PC_REQ_FLIT_MEMATTR_MSB-1:`CHI5PC_REQ_FLIT_MEMATTR_LSB]) &&  
          //!Current_STREX_REQ_Info.Snoopable && 
          (STREX_snoop ? Current_STREX_REQ_Info.Addr[43:6] ==  REQ_ADDR[43:6] : Current_STREX_REQ_Info.Addr ==  REQ_ADDR) &&
          (Current_STREX_REQ_Info.NS ==  REQFLIT_[`CHI5PC_REQ_FLIT_NS_RANGE]);
  generate
  genvar i;
    for (i = 1; i <= MAX_OS_EXCL_LOCAL; i = i + 1)
    begin : LDEX_REQ_match_gen
      assign LDEX_REQ_match_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn &&  
            (REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE] == Info[i].SrcID)&&
            (REQFLIT_[`CHI5PC_REQ_FLIT_LPID_RANGE] == Info[i].LPID) &&
            (LDEX_snoop || LDEX_nonsnoop) &&
            (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == Info[i].Snoopable);
    end : LDEX_REQ_match_gen
  endgenerate
  assign LDEX_REQ_match = |LDEX_REQ_match_vector;
  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      LDEX_REQ_Info_Index = '0;
    end
    else
    begin
      LDEX_REQ_Info_Index = '0;
      for (int i = 1; i <= MAX_OS_EXCL_LOCAL; i = i + 1)
      begin
        if (LDEX_REQ_match_vector[i])
            LDEX_REQ_Info_Index = i;
      end
    end
  end
  assign Current_LDEX_REQ_Info = |LDEX_REQ_Info_Index ? Info[LDEX_REQ_Info_Index] : 'b0;

  generate
    for (i = 1; i <= MAX_OS_EXCL_LOCAL; i = i + 1)
    begin : STREX_REQ_match_gen //matches on SrcID, LPID and NS
      assign STREX_REQ_match_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn &&  REQFLITV_ && 
            (STREX_snoop || STREX_nonsnoop)  && 
            (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == Info[i].Snoopable) &&
            (REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE] == Info[i].SrcID)&&
            (REQFLIT_[`CHI5PC_REQ_FLIT_LPID_RANGE] == Info[i].LPID);
    end : STREX_REQ_match_gen
  endgenerate
  assign STREX_REQ_match = |STREX_REQ_match_vector;
  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      STREX_REQ_Info_Index = '0;
    end
    else
    begin
      STREX_REQ_Info_Index = '0;
      for (int i = 1; i <= MAX_OS_EXCL_LOCAL; i = i + 1)
      begin
        if (STREX_REQ_match_vector[i])
            STREX_REQ_Info_Index = i;
      end
    end
  end
  assign Current_STREX_REQ_Info = |STREX_REQ_Info_Index ? Info[STREX_REQ_Info_Index] : 'b0;
  
  generate
    for (i = 1; i <= MAX_OS_EXCL_LOCAL; i = i + 1)
    begin : S_RSP_match_gen
      assign S_RSP_match_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn &&  S_RSPFLITV_ &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_RSPLINKFLIT)&&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_SRCID_RANGE] == Info[i].TgtID_rmp)&&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_TGTID_RANGE] == Info[i].SrcID)&&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_TXNID_RANGE] ==  Info[i].TxnID)&& 
          (Info[i].in_STREX || Info[i].in_LDEX);
    end : S_RSP_match_gen
  endgenerate
  assign S_RSP_match = |S_RSP_match_vector;
  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      S_RSP_Info_Index = '0;
    end
    else
    begin
      S_RSP_Info_Index = '0;
      for (int i = 1; i <= MAX_OS_EXCL_LOCAL; i = i + 1)
      begin
        if (S_RSP_match_vector[i])
            S_RSP_Info_Index = i;
      end
    end
  end
  assign Current_RSP_Info = |S_RSP_Info_Index ? Info[S_RSP_Info_Index] : 'b0;
  assign STREX_RSP = |S_RSP_Info_Index ? Info[S_RSP_Info_Index].in_STREX : 1'b0;

  generate
    for (i = 1; i <= MAX_OS_EXCL_LOCAL; i = i + 1)
    begin : RDDAT_match_gen
      assign RDDAT_match_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn &&  RDDATFLITV_ &&
          ((RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA)&&
           (RDDATFLIT_[`CHI5PC_DAT_FLIT_SRCID_RANGE] == Info[i].TgtID_rmp)&&
              (RDDATFLIT_[`CHI5PC_DAT_FLIT_TGTID_RANGE] == Info[i].SrcID)&&
              (RDDATFLIT_[`CHI5PC_DAT_FLIT_TXNID_RANGE] ==  Info[i].TxnID) &&
              Info[i].in_LDEX);
    end : RDDAT_match_gen
  endgenerate
  assign RDDAT_match = |RDDAT_match_vector;
  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      RDDAT_Info_Index = '0;
    end
    else
    begin
      RDDAT_Info_Index = '0;
      for (int i = 1; i <= MAX_OS_EXCL_LOCAL; i = i + 1)
      begin
        if (RDDAT_match_vector[i])
            RDDAT_Info_Index = i;
      end
    end
  end
  assign Current_RDDAT_Info = |RDDAT_Info_Index ? Info[RDDAT_Info_Index] : 'b0;


  always @(negedge Chi5_in.SRESETn or posedge SCLK)
  begin
    if(!Chi5_in.SRESETn)
    begin
        EXCL_ovflw <= 1'b0;
        EXCL_ovflw_delay1 <= 1'b0;
    end 
    else
    begin
      if (&Info_Alloc_vector && (((LDEX_nonsnoop || LDEX_snoop) && ~LDEX_REQ_match ) || (STREX_snoop && ~STREX_REQ_match)))
      begin
        EXCL_ovflw <= 1'b1;
      end
      EXCL_ovflw_delay1 <= EXCL_ovflw;
    end
  end


  logic [63:0] S_RSP_full_BE;
  assign S_RSP_full_BE = Chi5_in.Expect_BE(S_RSP_Addr_NS[6:1],S_RSP_Dev_Size[3],S_RSP_Dev_Size[2:0]);
  always @(negedge Chi5_in.SRESETn or posedge SCLK)
  begin
    if(!Chi5_in.SRESETn)
    begin
      for (int i = 1; i <= MAX_OS_EXCL_LOCAL; i = i + 1)
      begin
        Info[i].Addr <= '0;
        Info[i].SrcID <= '0;
        Info[i].TgtID <= '0;
        Info[i].LDEX_comp <= 1'b0;
        Info_Alloc_vector <= '0;
      end
    end 
    else
    begin
      Info_Alloc_vector <= Info_Alloc_vector ;
      //Response handling moved to the beginning, so that if an entry is being
      //overwritten at the same time as being responded to, the overwriting
      //succeeds

      //interim write only occurs on the write Comp
      if (S_RSPFLITV_ && S_RSP_Comp_Wr)
      begin
        for (int i = 1; i <= MAX_OS_EXCL_LOCAL; i = i + 1)
        begin
          if (Info_Alloc_vector[i] && !S_RSP_match_vector[i])
          begin
              if ((Info[i].Addr[43:6] == S_RSP_Addr_NS[44:7])
                && |(Info[i].Exp_BE & S_RSP_full_BE )
                && (Info[i].NS == S_RSP_Addr_NS[0]) 
                && Info[i].LDEX_comp)
            begin
              Info[i].interim_write <= 1'b1;
            end 
          end
        end
      end
      if (RDDAT_match && RDDATFLITV_ && Info[RDDAT_Info_Index].in_LDEX)
      begin
        Info[RDDAT_Info_Index].LDEX_comp <= 1'b1;
        //record the success of the LDEX
        if (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] == CHI5PC_RESP_OK_EXCL_FAIL)
        begin
          Info[RDDAT_Info_Index].LDEX_fail <= 1'b1;
        end
        //record that the load is complete
        if(RDDAT_Last_)
        begin
          Info[RDDAT_Info_Index].in_LDEX <= 1'b0;
        end
      end
      if (S_RSP_match && S_RSPFLITV_)
      begin
        //rule out the case where this current entry is being overwritten in
        //this cycle
        if (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_RETRYACK)
        begin
          if (Info[S_RSP_Info_Index].in_LDEX)
          begin
            Info[S_RSP_Info_Index].LDEX_comp <= 1'b0;
            Info[S_RSP_Info_Index].LDEX_fail <= 1'b0;
            Info[S_RSP_Info_Index].in_LDEX <= 1'b0;
          end
          else if (Info[S_RSP_Info_Index].in_STREX)
          begin
            Info[S_RSP_Info_Index].in_STREX <= 1'b0;
          end
        end
        if ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) ||
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP))
        begin
          if (Info[S_RSP_Info_Index].in_LDEX)
          begin
            Info[S_RSP_Info_Index].LDEX_comp <= 1'b1;
            Info[S_RSP_Info_Index].in_LDEX <= 1'b0;
          end
          else if (Info[S_RSP_Info_Index].in_STREX)
          begin
            Info[S_RSP_Info_Index].in_STREX <= 1'b0;
          end
          if (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] == CHI5PC_RESP_OK_EXCL_FAIL)
          begin
            if (Info[S_RSP_Info_Index].in_LDEX)
            begin
              Info[S_RSP_Info_Index].LDEX_fail <= 1'b1;
            end
            else if (Info[S_RSP_Info_Index].in_STREX)
            begin
              Info[S_RSP_Info_Index].STREX_fail <= 1'b1;
            end
          end
        end
      end
      if (LDEX_nonsnoop || LDEX_snoop)
      begin
          //need to put the case in where the address is already in from this srcid - just update the entry
        if (LDEX_REQ_match)
        begin
          Info[LDEX_REQ_Info_Index].Snoopable <= (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE]);
          Info[LDEX_REQ_Info_Index].Addr <= LDEX_nonsnoop ? REQ_ADDR : {REQ_ADDR[43:6], 6'b0};
          Info[LDEX_REQ_Info_Index].TxnID <= REQFLIT_[`CHI5PC_REQ_FLIT_TXNID_RANGE];
          Info[LDEX_REQ_Info_Index].Size <= eChi5PCSize'(REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE]);
          Info[LDEX_REQ_Info_Index].Exp_BE <= tmp_BE;
          Info[LDEX_REQ_Info_Index].TgtID_rmp <= Chi5PC_SAM_pkg::SAM_remap(REQFLIT_);
          //not interested in comparing the allocate bit
          Info[LDEX_REQ_Info_Index].MemAttr <= REQFLIT_[`CHI5PC_REQ_FLIT_MEMATTR_MSB-1:`CHI5PC_REQ_FLIT_MEMATTR_LSB];
          Info[LDEX_REQ_Info_Index].SnpAttr <= REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE];
          Info[LDEX_REQ_Info_Index].LikelyShared <= REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE];
          Info[LDEX_REQ_Info_Index].NS <= eChi5PCNS'(REQFLIT_[`CHI5PC_REQ_FLIT_NS_RANGE]);
          Info[LDEX_REQ_Info_Index].in_LDEX <= 1'b1;
          Info[LDEX_REQ_Info_Index].LDEX_fail <= 1'b0;
          Info[LDEX_REQ_Info_Index].LDEX_comp <= 1'b0;
          Info[LDEX_REQ_Info_Index].STREX_fail <= 1'b0;
          Info[LDEX_REQ_Info_Index].in_STREX <= 1'b0;
          Info[LDEX_REQ_Info_Index].interim_write <= 1'b0;
        end
        else if (|Info_Index_next)
        begin
          Info_Alloc_vector[Info_Index_next] <= 1'b1;
          Info[Info_Index_next].Snoopable <= (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE]);
          Info[Info_Index_next].Addr <= LDEX_nonsnoop ? REQ_ADDR : {REQ_ADDR[43:6], 6'b0};
          Info[Info_Index_next].SrcID <= REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE];
          Info[Info_Index_next].TgtID <= REQFLIT_[`CHI5PC_REQ_FLIT_TGTID_RANGE];
          Info[Info_Index_next].TgtID_rmp <= Chi5PC_SAM_pkg::SAM_remap(REQFLIT_);
          Info[Info_Index_next].LPID <= REQFLIT_[`CHI5PC_REQ_FLIT_LPID_RANGE];
          Info[Info_Index_next].TxnID <= REQFLIT_[`CHI5PC_REQ_FLIT_TXNID_RANGE];
          Info[Info_Index_next].Size <= eChi5PCSize'(REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE]);
          Info[Info_Index_next].Exp_BE <= tmp_BE;
          Info[Info_Index_next].MemAttr <= REQFLIT_[`CHI5PC_REQ_FLIT_MEMATTR_MSB-1:`CHI5PC_REQ_FLIT_MEMATTR_LSB];
          Info[Info_Index_next].SnpAttr <= REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE];
          Info[Info_Index_next].LikelyShared <= REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE];
          Info[Info_Index_next].NS <= eChi5PCNS'(REQFLIT_[`CHI5PC_REQ_FLIT_NS_RANGE]);
          Info[Info_Index_next].in_LDEX <= 1'b1;
          Info[Info_Index_next].LDEX_fail <= 1'b0;
          Info[Info_Index_next].LDEX_comp <= 1'b0;
          Info[Info_Index_next].STREX_fail <= 1'b0;
          Info[Info_Index_next].in_STREX <= 1'b0;
          Info[Info_Index_next].interim_write <= 1'b0;
        end
      end
      if ((STREX_snoop || STREX_nonsnoop) && STREX_REQ_match) 
      begin
        Info[STREX_REQ_Info_Index].in_STREX <= 1'b1;
        Info[STREX_REQ_Info_Index].TxnID <= REQFLIT_[`CHI5PC_REQ_FLIT_TXNID_RANGE];
        Info[STREX_REQ_Info_Index].SrcID <= REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE];
        Info[STREX_REQ_Info_Index].TgtID <= REQFLIT_[`CHI5PC_REQ_FLIT_TGTID_RANGE];
        Info[STREX_REQ_Info_Index].TgtID_rmp <= Chi5PC_SAM_pkg::SAM_remap(REQFLIT_);
        if (!payload_match)
        begin
          Info[STREX_REQ_Info_Index].Addr <= LDEX_nonsnoop ? REQ_ADDR : {REQ_ADDR[43:6], 6'b0};
          Info[STREX_REQ_Info_Index].Size <= eChi5PCSize'(REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE]);
          Info[STREX_REQ_Info_Index].Exp_BE <= tmp_BE;
          Info[STREX_REQ_Info_Index].MemAttr <= REQFLIT_[`CHI5PC_REQ_FLIT_MEMATTR_MSB-1:`CHI5PC_REQ_FLIT_MEMATTR_LSB];
          Info[STREX_REQ_Info_Index].SnpAttr <= REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE];
          Info[STREX_REQ_Info_Index].LikelyShared <= REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE];
          Info[STREX_REQ_Info_Index].NS <= eChi5PCNS'(REQFLIT_[`CHI5PC_REQ_FLIT_NS_RANGE]);
          Info[STREX_REQ_Info_Index].in_LDEX <= 1'b0;
          Info[STREX_REQ_Info_Index].LDEX_comp <= 1'b0;//this is the case where there has been no LD  of this payload
          Info[STREX_REQ_Info_Index].LDEX_fail <= 1'b0;
          Info[STREX_REQ_Info_Index].STREX_fail <= 1'b0;
          Info[STREX_REQ_Info_Index].in_STREX <= 1'b1;
          Info[STREX_REQ_Info_Index].interim_write <= 1'b0;
        end
      end
      if ((STREX_snoop || STREX_nonsnoop) && !STREX_REQ_match) 
      begin
        if (|Info_Index_next)
        begin
          Info_Alloc_vector[Info_Index_next] <= 1'b1;
          Info[Info_Index_next].Snoopable <= (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE]);
          Info[Info_Index_next].Addr <= LDEX_nonsnoop ? REQ_ADDR : {REQ_ADDR[43:6], 6'b0};
          Info[Info_Index_next].SrcID <= REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE];
          Info[Info_Index_next].TgtID <= REQFLIT_[`CHI5PC_REQ_FLIT_TGTID_RANGE];
          Info[Info_Index_next].TgtID_rmp <= Chi5PC_SAM_pkg::SAM_remap(REQFLIT_);
          Info[Info_Index_next].LPID <= REQFLIT_[`CHI5PC_REQ_FLIT_LPID_RANGE];
          Info[Info_Index_next].TxnID <= REQFLIT_[`CHI5PC_REQ_FLIT_TXNID_RANGE];
          Info[Info_Index_next].Size <= eChi5PCSize'(REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE]);
          Info[Info_Index_next].Exp_BE <= tmp_BE;
          Info[Info_Index_next].MemAttr <= REQFLIT_[`CHI5PC_REQ_FLIT_MEMATTR_MSB-1:`CHI5PC_REQ_FLIT_MEMATTR_LSB];
          Info[Info_Index_next].SnpAttr <= REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE];
          Info[Info_Index_next].LikelyShared <= REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE];
          Info[Info_Index_next].NS <= eChi5PCNS'(REQFLIT_[`CHI5PC_REQ_FLIT_NS_RANGE]);
          Info[Info_Index_next].in_LDEX <= 1'b0;
          Info[Info_Index_next].LDEX_comp <= 1'b0;//this is the case where there has been no LD at all
          Info[Info_Index_next].LDEX_fail <= 1'b0;
          Info[Info_Index_next].STREX_fail <= 1'b0;
          Info[Info_Index_next].in_STREX <= 1'b1;
          Info[Info_Index_next].interim_write <= 1'b0;
        end
      end
    end
  end
  
  
  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      Info_Index_next = 1;
    end
    else
    begin
      Info_Index_next = 0;
      for (int i = MAX_OS_EXCL_LOCAL; i >= 1; i = i - 1)
      begin
        if (!Info_Alloc_vector[i])
        begin
          Info_Index_next = i;
        end
      end
    end
  end



    
//------------------------------------------------------------------------------
// INDEX:   3)  Exclusive rules
//------------------------------------------------------------------------------ 


  // =====
  // INDEX:        - CHI5PC_REC_REQ_EXCL_FAIL
  // =====
  property CHI5PC_REC_REQ_EXCL_FAIL; 
    @(posedge `CHI5_SVA_CLK) disable iff (EXCL_ovflw)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_} ))
       && REQFLITV_  && (STREX_snoop || STREX_nonsnoop) && payload_match && STREX_REQ_match
       |-> !(Current_STREX_REQ_Info.LDEX_fail && Current_STREX_REQ_Info.LDEX_comp);
  endproperty
  chi5pc_rec_req_excl_fail: assert property (CHI5PC_REC_REQ_EXCL_FAIL) else 
    `ARM_CHI5_PC_MSG_WARN({"CHI5PC_REC_REQ_EXCL_FAIL::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "It is recommended that an Exclusive Store transaction is not performed to a location that does not support exclusive accesses."});



  // =====
  // INDEX:        - CHI5PC_ERR_RSP_EXCL_FAIL
  // =====
  property CHI5PC_ERR_RSP_EXCL_FAIL; 
    @(posedge `CHI5_SVA_CLK) disable iff (EXCL_ovflw)
       `CHI5_SVA_RSTn && !($isunknown({S_RSP_match,S_RSPFLIT_,Current_RSP_Info }))
       &&  S_RSP_match && (Current_RSP_Info.interim_write || Current_RSP_Info.LDEX_fail  || Current_RSP_Info.STREX_fail || !Current_RSP_Info.LDEX_comp)&&
       ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) ||
       (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP)) && !Current_RSP_Info.Snoopable 
      |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_EXCL_OK;
  endproperty
  chi5pc_err_rsp_excl_fail: assert property (CHI5PC_ERR_RSP_EXCL_FAIL) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_EXCL_FAIL::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "An EXOKAY response should not be given to a non-snoopable STREX for a monitor entry that has been overwritten or the previous corresponding LDEX or STREX received a Normal OKAY response, or there was no corresponding LDEX."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_EXCL_OVFLW
  // =====
  property CHI5PC_ERR_REQ_EXCL_OVFLW; 
    @(posedge `CHI5_SVA_CLK)   disable iff (EXCL_ovflw_delay1)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,Info_Alloc_vector,LDEX_nonsnoop} ))
       && (LDEX_nonsnoop || LDEX_snoop || STREX_snoop) && &Info_Alloc_vector 
      |-> LDEX_REQ_match || STREX_REQ_match;
  endproperty
  chi5pc_err_req_excl_ovflw: assert property (CHI5PC_ERR_REQ_EXCL_OVFLW) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_EXCL_OVFLW::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "The Exclusive monitor in the protocol checker has overflowed. MAX_OS_EXCL has been exceeded. Increase MAX_OS_EXCL. Some Exclusive checks are now disabled from this point forward."});


//------------------------------------------------------------------------------
// INDEX:   4) Clear Verilog Defines
//------------------------------------------------------------------------------
  `undef CHI5_AUX_CLK
  `undef CHI5_AUX_RSTn
  `undef CHI5_SVA_CLK
  `undef CHI5_SVA_RSTn

//------------------------------------------------------------------------------
// INDEX:   5) End of module
//------------------------------------------------------------------------------

endmodule //Chi5PC_EXCL

`endif
