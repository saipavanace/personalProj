
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
//  File Revision       : 179045
//
//  Date                :  2014-08-20 14:24:28 +0100 (Wed, 20 Aug 2014)
//
//  Release Information : BP066-BU-01000-r0p0-00lac0
//
//------------------------------------------------------------------------------
//  Purpose             :Tracks flits on SNP_/RSP/DATA.
//                          
//----------------------------------------------------------------------------
// CONTENTS
// ========
//  129.  Module: Chi5PC_SnoopTrace
//  169.    1) Parameters
//  177.    2) Verilog Defines
//  180.         - Clock and Reset
//  207.    3)  Transaction Tracking
//  784.    4)  SNP Channel Checks
//  787.         - CHI5PC_ERR_SNP_OPCD_S
//  807.         - CHI5PC_ERR_SNP_OPCD_DVM
//  826.         - CHI5PC_ERR_SNP_OVFLW
//  840.         - CHI5PC_ERR_SNP_X
//  851.         - CHI5PC_ERR_SNP_RSVD_OPCODE
//  873.         - CHI5PC_ERR_SNP_RSVD_DVM_MTYPE
//  885.         - CHI5PC_ERR_SNP_RSVD_DVM_S2S1
//  898.         - CHI5PC_ERR_SNP_RSVD_DVM_SECURE
//  911.         - CHI5PC_ERR_SNP_CTL_SNPDVMOP
//  923.         - CHI5PC_ERR_SNP_CTL_LINKFLIT
//  935.         - CHI5PC_ERR_SNP_TXNID_UNQ
//  947.         - CHI5PC_ERR_SNP_SYNC_UNQ
//  959.         - CHI5PC_ERR_SNP_ADDR_UNQ
//  973.         - CHI5PC_ERR_SNP_DVM_TLBI_GUEST_NS
// 1038.         - CHI5PC_ERR_SNP_DVM_TLBI_GUEST_S
// 1082.         - CHI5PC_ERR_SNP_DVM_TLBI_HYP_NS
// 1112.         - CHI5PC_ERR_SNP_DVM_TLBI_EL3_S
// 1142.         - CHI5PC_ERR_SNP_DVM_TLBI_GUEST_HYP_BOTH
// 1157.         - CHI5PC_ERR_SNP_DVM_TLBI_NS_S_BOTH: 
// 1172.         - CHI5PC_ERR_SNP_DVM_TLBI_HYP_S
// 1188.         - CHI5PC_ERR_SNP_DVM_TLBI_EL3_NS
// 1206.         - CHI5PC_ERR_SNP_DVM_BPI
// 1232.         - CHI5PC_ERR_SNP_DVM_PICI
// 1287.         - CHI5PC_ERR_SNP_DVM_VICI
// 1342.         - CHI5PC_ERR_SNP_DVM_SYNC
// 1361.         - CHI5PC_ERR_SNP_DVM_PARTNUM
// 1375.    5)  DAT Channel Checks
// 1379.         - CHI5PC_ERR_DAT_RESP_SS
// 1401.         - CHI5PC_ERR_DAT_RESP_SC
// 1423.         - CHI5PC_ERR_DAT_RESP_SO
// 1447.         - CHI5PC_ERR_DAT_RESP_SU
// 1466.         - CHI5PC_ERR_DAT_RESP_SCS
// 1485.         - CHI5PC_ERR_DAT_RESP_SCI
// 1502.         - CHI5PC_ERR_DAT_RESPERR_SNOOP
// 1515.         - CHI5PC_ERR_DAT_RSVD_RESP_SNOOP
// 1530.         - CHI5PC_ERR_DAT_SNPMAKEINVALID
// 1543.         - CHI5PC_ERR_DAT_SNPRESP_UNIFORM
// 1555.         - CHI5PC_ERR_DAT_RESP_SNPDVMOP
// 1567.         - CHI5PC_ERR_DAT_SNPWRAPORDER
// 1581.         - CHI5PC_ERR_DAT_SNPCCID
// 1593.         - CHI5PC_ERR_DAT_CTL_SNPRESPDATA
// 1607.         - CHI5PC_ERR_DAT_SNP_HAZARD_RD
// 1619.         - CHI5PC_ERR_DAT_RSP_FOR_SNOOP
// 1631.         - CHI5PC_ERR_DAT_CONST_OPCODE_SNPDAT
// 1644.         - CHI5PC_ERR_DAT_CONST_DBID_SNOOP
// 1659.    6)  RSP Channel Checks
// 1663.         - CHI5PC_ERR_RSP_RESP_SS
// 1680.         - CHI5PC_ERR_RSP_RESP_SC
// 1697.         - CHI5PC_ERR_RSP_RESP_SO
// 1715.         - CHI5PC_ERR_RSP_RESP_SU
// 1731.         - CHI5PC_ERR_RSP_RESP_SCS
// 1749.         - CHI5PC_ERR_RSP_RESP_SCI
// 1765.         - CHI5PC_ERR_RSP_RESP_SMI
// 1781.         - CHI5PC_ERR_RSP_RESP_SDVM
// 1797.         - CHI5PC_ERR_RSP_RESPERR_SNOOP
// 1810.         - CHI5PC_ERR_RSP_RSVD_RESP_SNOOP
// 1824.         - CHI5PC_ERR_RSP_CTL_SNPRESP
// 1838.         - CHI5PC_ERR_RSP_SNPDVM_RESP
// 1850.         - CHI5PC_ERR_RSP_HAZARD_SNP
// 1863.         - CHI5PC_ERR_RSP_DAT_FOR_SNOOP1
// 1876.         - CHI5PC_ERR_RSP_DAT_FOR_SNOOP2
// 1889.         - CHI5PC_ERR_RSP_SNOOP_PD
// 1903.    7)  REQ Channel Checks
// 1906.         - CHI5PC_ERR_REQ_SNPATTR
// 1922.    8)  SACTIVE check
// 1926.         - CHI5PC_ERR_LNK_TXSACTIVE_SNP_TX
// 1938.         - CHI5PC_ERR_LNK_TXSACTIVE_SNP_RX
// 1958.    9)  Snoop EOS Checking
// 1961.         - CHI5PC_ERR_EOS_SNOOP 
// 1972.    10) Clear Verilog Defines
// 1981.    11) End of module
// 1987. 
// 1988.  End of File
//----------------------------------------------------------------------------

`ifndef CHI5PC_OFF




//------------------------------------------------------------------------------
// CHI5 Standard Defines
//------------------------------------------------------------------------------



`ifndef CHI5PC_TYPES
  `include "Chi5PC_Chi5_defines.v"

`endif
`include "Chi5PC_defines.v"


//------------------------------------------------------------------------------
// INDEX: Module: Chi5PC_SnoopTrace
//------------------------------------------------------------------------------
module Chi5PC_SnoopTrace #(REQ_RSVDC_WIDTH = 4,
                    DAT_RSVDC_WIDTH = 4,
                    DAT_FLIT_WIDTH = `CHI5PC_128B_DAT_FLIT_WIDTH,
                    MAX_OS_SNP = 8,
                    CACHE_LINE_SIZE_BYTES = 512,
                    MODE = 1,
                    numChi5nodes = 4,
                    NODE_TYPE = Chi5PC_pkg::RNF,
                    ErrorOn_SW = 1,
                    PCMODE = Chi5PC_pkg::LOCAL)
      (Chi5PC_if Chi5_in
      , input wire SCLK
      , input wire SRESETn
      , input wire DATFLITV_
      , input wire [DAT_FLIT_WIDTH-1:0] DATFLIT_
      , input wire SNPFLITV_
      , input wire [`CHI5PC_SNP_FLIT_RANGE] SNPFLIT_
      , input wire RSPFLITV_
      , input wire [`CHI5PC_RSP_FLIT_RANGE] RSPFLIT_
      , input wire REQFLITV_
      , input wire [`CHI5PC_REQ_FLIT_RANGE] REQFLIT_
      , input wire SNPLCRDV_
      , input wire SACTIVE_
      , input wire [0:31] BroadcastVector
      , input wire WRDAT_Data_FLITV
      , input wire RDDAT_Data_FLITV
      , input wire S_RSP_Comp_Haz_FLITV
      , output reg DAT_match
      , input reg [43:5] RDDAT_Addr_NS     
      , input reg [43:5] WRDAT_Addr_NS     
      , input reg [43:5] S_RSP_Addr_NS     
      , output reg RSP_match
   );
import Chi5PC_pkg::*;
  typedef Chi5_in.Chi5PC_SNP_Info Chi5PC_SNP_Info;

  
//------------------------------------------------------------------------------
// INDEX:   1) Parameters
//------------------------------------------------------------------------------

  localparam LOG2MAX_OS_SNP       = clogb2(MAX_OS_SNP);
  localparam NODE_TYPE_HAS_MN = ((NODE_TYPE == MN) || (NODE_TYPE == HNI_MN) || (NODE_TYPE == HNF_MN) || (NODE_TYPE == HNF_HNI_MN) );
  localparam NODE_TYPE_HAS_HNI = ((NODE_TYPE == HNI) || (NODE_TYPE == HNI_MN) || (NODE_TYPE == HNF_HNI) || (NODE_TYPE == HNF_HNI_MN) );
  localparam NODE_TYPE_HAS_HNF = ((NODE_TYPE == HNF) || (NODE_TYPE == HNF_MN) || (NODE_TYPE == HNF_HNI) || (NODE_TYPE == HNF_HNI_MN) );
//---------------------------------------------------------------------------
// INDEX:   2) Verilog Defines
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
// INDEX:   3)  Transaction Tracking
//------------------------------------------------------------------------------ 

  Chi5PC_SNP_Info                   Info [1:MAX_OS_SNP];
  wire [1:MAX_OS_SNP]               Info_Pop_vector;
  reg  [1:MAX_OS_SNP]               Info_Alloc_vector;
  reg                               Info_Alloc_active_plus_one;
  reg  [1:MAX_OS_SNP]               Active_Data_vector;
  reg  [1:MAX_OS_SNP]               Credit_Alloc_vector;
  wire [1:MAX_OS_SNP]               ID_CLASH_vector;
  wire [1:MAX_OS_SNP]               DVM_SYNC_CLASH_vector;
  wire [1:MAX_OS_SNP]               ADDR_CLASH_vector;
  wire [1:MAX_OS_SNP]               REQ_Attr_CLASH_vector;
  reg  [LOG2MAX_OS_SNP:0]           Info_Index_next;
  reg  [LOG2MAX_OS_SNP:0]           Credit_Index_next;
  reg  [LOG2MAX_OS_SNP:0]           RSP_Info_Index;
  reg  [LOG2MAX_OS_SNP:0]           DAT_Info_Index;
  reg  [LOG2MAX_OS_SNP:0]           DVMSNP_Info_Index;
  Chi5PC_SNP_Info                   Info_tmp ;
  Chi5PC_SNP_Info                   Current_DAT_Info;
  Chi5PC_SNP_Info                   Current_RSP_Info;
  Chi5PC_SNP_Info                   Current_SNP_Info;
  wire                              RSP_Pop;
  wire                              DAT_Pop;
  reg                               DAT_Last;
  reg  [1:numChi5nodes] next_dat_rcvd;
  reg  [1:numChi5nodes] next_rsp_rcvd;
  wire                              RSPFLITV_matched;
  wire                              DATFLITV_matched;
  wire                              SNPDVM_match;
  wire [6:0]                        DAT_nodeIndex;
  wire [6:0]                        RSP_nodeIndex;
  logic[`CHI5PC_REQ_FLIT_MEMATTR_WIDTH-1:0] REQ_memattr;
  logic[`CHI5PC_REQ_FLIT_SNPATTR_WIDTH-1:0] REQ_snpattr;
  

  assign RSPFLITV_matched = RSPFLITV_ && |RSP_Info_Index;
  assign DATFLITV_matched = DATFLITV_ && |DAT_Info_Index;
  assign DAT_nodeIndex = DATFLITV_ ? Chi5_in.get_nodeIndex(DATFLIT_[`CHI5PC_DAT_FLIT_SRCID_RANGE]) : 'b0;
  assign RSP_nodeIndex = RSPFLITV_ ? Chi5_in.get_nodeIndex(RSPFLIT_[`CHI5PC_RSP_FLIT_SRCID_RANGE]) : 'b0;
  

  assign RSP_Pop = RSPFLITV_matched &&  !(Current_RSP_Info.Expect_RSP ^ next_rsp_rcvd) && ((Current_RSP_Info.OpCode == `CHI5PC_SNPDVMOP) ? &Current_RSP_Info.DVMPart : 1'b1) ;

  eChi5PCDevType SNP_SRCID_NodeType;
  assign SNP_SRCID_NodeType = Chi5_in.get_NodeType(SNPFLIT_[`CHI5PC_SNP_FLIT_SRCID_RANGE]);
  wire SNP_SRCID_NODE_TYPE_HAS_MN;
  wire SNP_SRCID_NODE_TYPE_HAS_HNF;
  wire SNP_SRCID_NODE_TYPE_HAS_HNI;
  assign SNP_SRCID_NODE_TYPE_HAS_MN = Chi5_in.has_MN(SNP_SRCID_NodeType);
  assign SNP_SRCID_NODE_TYPE_HAS_HNF = Chi5_in.has_HNF(SNP_SRCID_NodeType);
  assign SNP_SRCID_NODE_TYPE_HAS_HNI = Chi5_in.has_HNI(SNP_SRCID_NodeType);

  assign DAT_Pop = DATFLITV_matched && DAT_Last && !(Current_DAT_Info.Expect_RSP ^ next_dat_rcvd);
  always_comb
  begin
    Info_tmp.SrcID          = SNPFLIT_[`CHI5PC_SNP_FLIT_SRCID_RANGE];
    Info_tmp.TxnID          = SNPFLIT_[`CHI5PC_SNP_FLIT_TXNID_RANGE];
    Info_tmp.Previous       = Info_Alloc_vector & ~Info_Pop_vector;
    Info_tmp.QoS            = eChi5PCQoS'(SNPFLIT_[`CHI5PC_SNP_FLIT_QOS_RANGE]);
    Info_tmp.OpCode         = eChi5PCSnpOp'(SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE]);
    Info_tmp.Addr           = SNPFLIT_[`CHI5PC_SNP_FLIT_ADDR_MSB-3:`CHI5PC_SNP_FLIT_ADDR_LSB];
    Info_tmp.Addr43_3       = SNPFLIT_[`CHI5PC_SNP_FLIT_ADDR_RANGE];
    Info_tmp.Expect_RSP     = '0;
    Info_tmp.Rcvd_RSP       = '0;
    Info_tmp.RespErr        = '1;
    Info_tmp.Resp           = '1;
    Info_tmp.DATID          = '0;
    Info_tmp.DatOpCode      = eChi5PCDatOp'(`CHI5PC_DATLINKFLIT);
    Info_tmp.DBID           = '0;
    if (Info_tmp.Addr.Partnum)
    begin
      Info_tmp.DVMPart = 2'b10;
    end
    else
    begin
      Info_tmp.DVMPart = 2'b01;
    end
    Info_tmp.NS             = eChi5PCNS'(SNPFLIT_[`CHI5PC_SNP_FLIT_NS_RANGE]);

    //if receiving the snoop only expect a response from this ID
    if ((Chi5_in.NODE_TYPE == eChi5PCDevType'(RNF)) || (Chi5_in.NODE_TYPE == eChi5PCDevType'(RNI)) || (Chi5_in.NODE_TYPE == eChi5PCDevType'(RND)))
    begin
      Info_tmp.Expect_RSP[Chi5_in.this_nodeIndex] = 1'b1;
    end
    else
    begin
      for(int i = 1; i<= 32; i=i+1)
      begin
        if(BroadcastVector[i])
        begin
          Info_tmp.Expect_RSP[Chi5_in.get_nodeIndex(i)] = 1'b1;
        end
      end
    end
  end

  always @(negedge Chi5_in.SRESETn or posedge SCLK)
  begin
    if(!Chi5_in.SRESETn)
    begin
      Info_Alloc_vector <= '0;
      Info_Alloc_active_plus_one <= 1'b0;
      Credit_Alloc_vector <= '0;
      for (int i = 1; i <= MAX_OS_SNP; i = i + 1)
      begin
        Info[i] <= '0;
      end
    end 
    else
    begin
      Info_Alloc_vector <= Info_Alloc_vector &  ~Info_Pop_vector;
      Info_Alloc_active_plus_one <= |Info_Alloc_vector;
      Credit_Alloc_vector <= Credit_Alloc_vector &  ~Info_Pop_vector;
      if (|Info_Pop_vector)

      if(SNPLCRDV_)
      begin
        Credit_Alloc_vector[Credit_Index_next] <= 1'b1;
      end
      if(SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPLINKFLIT))
      begin
        if (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPDVMOP)
        begin
          Info[Info_Index_next].SrcID          <= Info_tmp.SrcID     ;
          Info[Info_Index_next].TxnID          <= Info_tmp.TxnID     ;
          Info[Info_Index_next].Previous       <= Info_tmp.Previous  ;
          Info[Info_Index_next].QoS            <= Info_tmp.QoS       ;
          Info[Info_Index_next].OpCode         <= Info_tmp.OpCode    ;
          Info[Info_Index_next].Expect_RSP     <= Info_tmp.Expect_RSP;
          Info[Info_Index_next].Rcvd_RSP       <= Info_tmp.Rcvd_RSP  ;
          Info[Info_Index_next].RespErr        <= Info_tmp.RespErr   ;
          Info[Info_Index_next].Resp           <= Info_tmp.Resp      ;
          Info[Info_Index_next].DATID          <= Info_tmp.DATID     ;
          Info[Info_Index_next].DatOpCode      <= Info_tmp.DatOpCode ;
          Info[Info_Index_next].DBID           <= Info_tmp.DBID      ;
          Info[Info_Index_next].Addr           <= Info_tmp.Addr      ;
          Info[Info_Index_next].NS             <= Info_tmp.NS        ;
          Info[Info_Index_next].DVMPart        <= 'b0                ;
          Info[Info_Index_next].Addr43_3 <= Info_tmp.Addr43_3;
          Info_Alloc_vector[Info_Index_next] <= 1'b1;
        end
        else 
        begin
          if (SNPDVM_match)
          begin
            if (!Info_tmp.Addr.Partnum)
            begin
              Info[DVMSNP_Info_Index].Addr <= Info_tmp.Addr;
            end
            Info[DVMSNP_Info_Index].DVMPart[Info_tmp.Addr.Partnum] <= 1'b1;
            if (Info_tmp.QoS < Info[DVMSNP_Info_Index].QoS)
            begin
              Info[DVMSNP_Info_Index].QoS <= Info_tmp.QoS;
            end
          end
          else  
          begin
            Info_Alloc_vector[Info_Index_next]   <= 1'b1;
            Info[Info_Index_next].SrcID          <= Info_tmp.SrcID     ;
            Info[Info_Index_next].TxnID          <= Info_tmp.TxnID     ;
            Info[Info_Index_next].Previous       <= Info_tmp.Previous  ;
            Info[Info_Index_next].QoS            <= Info_tmp.QoS       ;
            Info[Info_Index_next].OpCode         <= Info_tmp.OpCode    ;
            Info[Info_Index_next].Expect_RSP     <= Info_tmp.Expect_RSP;
            Info[Info_Index_next].Rcvd_RSP       <= Info_tmp.Rcvd_RSP  ;
            Info[Info_Index_next].RespErr        <= Info_tmp.RespErr   ;
            Info[Info_Index_next].Resp           <= Info_tmp.Resp      ;
            Info[Info_Index_next].DATID          <= Info_tmp.DATID     ;
            Info[Info_Index_next].DatOpCode      <= Info_tmp.DatOpCode ;
            Info[Info_Index_next].DBID           <= Info_tmp.DBID      ;
            Info[Info_Index_next].DVMPart        <= Info_tmp.DVMPart   ;
            Info[Info_Index_next].Addr43_3       <= Info_tmp.Addr43_3  ;
            if (!Info_tmp.Addr.Partnum )
            begin
              Info[Info_Index_next].Addr <= Info_tmp.Addr;
            end
          end
        end
      end
      //capture data event
      if (DATFLITV_matched)
      begin
        //if you are not about to pop Current_DAT_Info
        if (!DAT_Pop)
        begin
          if (~|Info[DAT_Info_Index].DATID)
          begin
            Info[DAT_Info_Index].DatOpCode <= eChi5PCDatOp'(DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE]);
            Info[DAT_Info_Index].DBID <= DATFLIT_[`CHI5PC_DAT_FLIT_DBID_RANGE];
          end

          case (DAT_FLIT_WIDTH)
            `CHI5PC_128B_DAT_FLIT_WIDTH:
            begin
              case (DATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE])
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b00:
                  Info[DAT_Info_Index].DATID[DAT_nodeIndex][0] <= 1'b1;
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b01:
                  Info[DAT_Info_Index].DATID[DAT_nodeIndex][1] <= 1'b1;
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b10:
                  Info[DAT_Info_Index].DATID[DAT_nodeIndex][2] <= 1'b1;
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b11:
                  Info[DAT_Info_Index].DATID[DAT_nodeIndex][3] <= 1'b1;
              endcase;
            end
            `CHI5PC_256B_DAT_FLIT_WIDTH:
            begin
              case (DATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE])
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b00:
                begin
                  Info[DAT_Info_Index].DATID[DAT_nodeIndex][0] <= 1'b1;
                  Info[DAT_Info_Index].DATID[DAT_nodeIndex][1] <= 1'b1;
                end
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b10:
                begin
                  Info[DAT_Info_Index].DATID[DAT_nodeIndex][2] <= 1'b1;
                  Info[DAT_Info_Index].DATID[DAT_nodeIndex][3] <= 1'b1;
                end
              endcase;
            end
            `CHI5PC_512B_DAT_FLIT_WIDTH:
            begin
              case (DATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE])
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b00:
                  Info[DAT_Info_Index].DATID[DAT_nodeIndex] <= 4'b1111;
              endcase;
            end
          endcase;
        end
        if (!DAT_Pop)
        begin
          Info[DAT_Info_Index].Rcvd_RSP <= next_dat_rcvd;
          Info[DAT_Info_Index].Resp[DAT_nodeIndex] <=  DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE];
          Info[DAT_Info_Index].RespErr[DAT_nodeIndex] <=  DATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE];
        end
      end
      if (RSPFLITV_matched)
      begin
        if (!RSP_Pop)
        begin
          Info[RSP_Info_Index].Rcvd_RSP <= next_rsp_rcvd;
          Info[RSP_Info_Index].Resp[RSP_nodeIndex] <=  RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE];
        end
      end
      for (int i = 1; i <= MAX_OS_SNP; i = i + 1)
      begin
        if (Info_Alloc_vector[i])
        begin
          Info[i].Previous <= Info[i].Previous &  ~Info_Pop_vector;
        end
      end
      
    end
  end

    logic [1:numChi5nodes] tmp_rsp_rcvd;
    logic [1:numChi5nodes] tmp_dat_rcvd;
  //match the rsp to an outstanding request with matching Txnid 
  always_comb
  begin
    tmp_rsp_rcvd = '0;
    tmp_dat_rcvd = '0;
    next_rsp_rcvd = '0;
    next_dat_rcvd = '0;
    //response and data to the same snoop at the same time
    if (RSPFLITV_matched && (DATFLITV_matched && DAT_Last) && (RSP_Info_Index == DAT_Info_Index))
    begin
      tmp_rsp_rcvd[RSP_nodeIndex] = 1'b1;
      tmp_dat_rcvd[DAT_nodeIndex] = 1'b1;
    end
    if (RSPFLITV_matched)
    begin
      tmp_rsp_rcvd[RSP_nodeIndex] = 1'b1;
    end
    if (DATFLITV_matched && DAT_Last )
    begin
      tmp_dat_rcvd[DAT_nodeIndex] = 1'b1;
    end
      next_rsp_rcvd = Current_RSP_Info.Rcvd_RSP | tmp_rsp_rcvd;
      next_dat_rcvd = Current_DAT_Info.Rcvd_RSP | tmp_dat_rcvd;
  end 
  //here we are comparing the RSP_addr with the addresses in Info
  //RSP_addr is the addr of the transaction in the Flittrace that is receiving a response on 
  //RXRSP. If this matches an address in the Chi5PC_SnoopTrace Info then snp_match_rsp_addr is
  //output to CHI5PC that there is a match. CHI5PC can now detect that
  //there is a response to a non snoop transaction that overlaps with a snoop
  //transaction
  generate
  genvar l;
    for (l = 1; l <= MAX_OS_SNP; l = l + 1)
    begin : Active_Data_gen
      assign Active_Data_vector[l] = Chi5_in.SRESETn  && Info_Alloc_vector[l] && |Info[l].DATID ;
    end : Active_Data_gen
  endgenerate

  logic [1:MAX_OS_SNP] RSP_match_vector;
  generate
  genvar i;
    for (i = 1; i <= MAX_OS_SNP; i = i + 1)
    begin : RSP_match_gen
      assign RSP_match_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn &&
           ((RSPFLIT_[`CHI5PC_RSP_FLIT_TXNID_RANGE] == Info[i].TxnID)&&
            (RSPFLIT_[`CHI5PC_RSP_FLIT_TGTID_RANGE] ==  Info[i].SrcID) &&
            (RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] ==  `CHI5PC_SNPRESP));
    end : RSP_match_gen
  endgenerate
  assign RSP_match = |RSP_match_vector;



  generate
    for (i = 1; i <= MAX_OS_SNP; i = i + 1)
    begin : ID_CLASH_gen
      assign ID_CLASH_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn && !SNPDVM_match &&
           ((SNPFLIT_[`CHI5PC_SNP_FLIT_TXNID_RANGE] == Info[i].TxnID)&&
            (SNPFLIT_[`CHI5PC_SNP_FLIT_SRCID_RANGE] ==  Info[i].SrcID));
    end : ID_CLASH_gen
  endgenerate

  generate
    for (i = 1; i <= MAX_OS_SNP; i = i + 1)
    begin : DVM_SYNC_CLASH_gen
      assign DVM_SYNC_CLASH_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn &&
           (Info[i].OpCode == `CHI5PC_SNPDVMOP) &&
            (Info[i].Addr.Type == CHI5PC_DVM_SYNC) && 
            (Info[i].DVMPart[0]) && 
            (SNPFLIT_[`CHI5PC_SNP_FLIT_SRCID_RANGE] == Info[i].SrcID);
    end : DVM_SYNC_CLASH_gen
  endgenerate

  generate
    for (i = 1; i <= MAX_OS_SNP; i = i + 1)
    begin : ADDR_CLASH_gen
      assign ADDR_CLASH_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn &&
           (Info[i].OpCode != `CHI5PC_SNPDVMOP) &&
            (Info[i].Addr43_3[43:6] == Info_tmp.Addr43_3[43:6]) && 
            (Info[i].NS == SNPFLIT_[`CHI5PC_SNP_FLIT_NS_RANGE]);
    end : ADDR_CLASH_gen
  endgenerate

  assign REQ_memattr = REQFLIT_[`CHI5PC_REQ_FLIT_MEMATTR_RANGE];
  assign REQ_snpattr = REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE];
  generate
    for (i = 1; i <= MAX_OS_SNP; i = i + 1)
    begin : REQ_Attr_CLASH_gen
      assign REQ_Attr_CLASH_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn &&
                 (Info[i].OpCode != `CHI5PC_SNPDVMOP) &&
                 (Info[i].Addr43_3[43:6] == REQFLIT_[`CHI5PC_REQ_FLIT_ADDR_MSB:`CHI5PC_REQ_FLIT_ADDR_LSB+6]) &&
                 (Info[i].NS == REQFLIT_[`CHI5PC_REQ_FLIT_NS_RANGE]) &&
                 (!REQ_memattr[`CHI5PC_MEMATTR_CACHEABLE_RANGE] ||
                 !REQ_snpattr[`CHI5PC_SNPATTR_SNOOPABLE_RANGE]) ;
    end : REQ_Attr_CLASH_gen
  endgenerate

  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      RSP_Info_Index = '0;
    end
    begin
      RSP_Info_Index = '0;
      if (RSPFLITV_)
      begin
        for (int i = 1; i <= MAX_OS_SNP; i = i + 1)
        begin
          if (RSP_match_vector[i])
          begin

              RSP_Info_Index = i;
          end
        end
      end
    end
  end
  assign Current_RSP_Info = ~RSP_Info_Index ? Info[RSP_Info_Index] : 'b0;
  //match the txdata to an outstanding request with matching tgtid and Txnid 
  logic [1:MAX_OS_SNP] DAT_match_vector;
  generate
    for (i = 1; i <= MAX_OS_SNP; i = i + 1)
    begin : DAT_match_gen
      assign DAT_match_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn &&
             ((DATFLIT_[`CHI5PC_DAT_FLIT_TXNID_RANGE] == Info[i].TxnID) 
              && (DATFLIT_[`CHI5PC_DAT_FLIT_TGTID_RANGE] == Info[i].SrcID)
              && ((DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATA) || (DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] ==`CHI5PC_SNPRESPDATAPTL)));
    end : DAT_match_gen
  endgenerate
  assign DAT_match = |DAT_match_vector;

  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      DAT_Info_Index = '0;
    end
    else
    begin
      DAT_Info_Index = '0;
      if (DATFLITV_)
      begin
        for (int i = 1; i <= MAX_OS_SNP; i = i + 1)
        begin
          if (DAT_match_vector[i])
          begin
              DAT_Info_Index = i;
          end
        end
      end
    end
  end
  assign Current_DAT_Info = ~DAT_Info_Index ? Info[DAT_Info_Index] : 'b0;

  //match the DVMOp to an existing one. 
  logic [1:MAX_OS_SNP] SNPDVM_match_vector;
  generate
    for (i = 1; i <= MAX_OS_SNP; i = i + 1)
    begin : SNPDVM_match_gen
      assign SNPDVM_match_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) &&
           ((SNPFLIT_[`CHI5PC_SNP_FLIT_TXNID_RANGE] == Info[i].TxnID)&&
            (SNPFLIT_[`CHI5PC_SNP_FLIT_SRCID_RANGE] ==  Info[i].SrcID) &&
            (Info[i].OpCode == `CHI5PC_SNPDVMOP));  
    end : SNPDVM_match_gen
  endgenerate
  assign SNPDVM_match = |SNPDVM_match_vector;
  assign Current_SNP_Info = SNPDVM_match ? Info[DVMSNP_Info_Index] : 'b0;

  //vector of snoops that are hazarding with the RDDAT_Addr_NS
  logic [1:MAX_OS_SNP] RDDAT_Addr_NS_haz_vector;
  generate
    for (i = 1; i <= MAX_OS_SNP; i = i + 1)
    begin : RDDAT_Addr_NS_haz_gen
      assign RDDAT_Addr_NS_haz_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn && (Info[i].OpCode != `CHI5PC_SNPDVMOP) &&
           (( RDDAT_Addr_NS == {(Info[i].Addr43_3[43:6]),Info[i].NS} )&&
            (~|Info[i].Rcvd_RSP[Chi5_in.this_nodeIndex] || ~&Info[i].DATID[Chi5_in.this_nodeIndex]));  
    end : RDDAT_Addr_NS_haz_gen
  endgenerate

  //vector of snoops that are hazarding with the WRDAT_Addr_NS
  logic [1:MAX_OS_SNP] WRDAT_Addr_NS_haz_vector;
  generate
    for (i = 1; i <= MAX_OS_SNP; i = i + 1)
    begin : WRDAT_Addr_NS_haz_gen
      assign WRDAT_Addr_NS_haz_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn && (Info[i].OpCode != `CHI5PC_SNPDVMOP) &&
           (( WRDAT_Addr_NS == {(Info[i].Addr43_3[43:6]),Info[i].NS} )&&
            (~|Info[i].Rcvd_RSP[Chi5_in.this_nodeIndex] || ~&Info[i].DATID[Chi5_in.this_nodeIndex]));  
    end : WRDAT_Addr_NS_haz_gen
  endgenerate


  //vector of snoops that are hazarding with the S_RSP_Addr_NS
  logic [1:MAX_OS_SNP] S_RSP_Addr_NS_haz_vector;
  generate
    for (i = 1; i <= MAX_OS_SNP; i = i + 1)
    begin : S_RSP_Addr_NS_haz_gen
      assign S_RSP_Addr_NS_haz_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn && 
           (Info[i].OpCode != `CHI5PC_SNPDVMOP) &&
           (( S_RSP_Addr_NS == {(Info[i].Addr43_3[43:6]),Info[i].NS} )&&
            (~|Info[i].Rcvd_RSP[Chi5_in.this_nodeIndex] || ~&Info[i].DATID[Chi5_in.this_nodeIndex]));  
    end : S_RSP_Addr_NS_haz_gen
  endgenerate



  always_comb
  begin
    if (!Chi5_in.SRESETn || !SNPFLITV_ || SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPDVMOP)
    begin
      DVMSNP_Info_Index = '0;
    end
    else
    begin
      DVMSNP_Info_Index = '0;
      for (int i = 1; i <= MAX_OS_SNP; i = i + 1)
      begin
        if (SNPDVM_match_vector[i])
        begin
            DVMSNP_Info_Index = i;
        end
      end
    end
  end
  //determine the pop_vector
  generate
    for (i = 1; i <= MAX_OS_SNP; i = i + 1)
    begin : Info_Pop_gen
      assign Info_Pop_vector[i] = Info_Alloc_vector[i] && Chi5_in.SRESETn  &&
                                  ((RSP_Pop && RSP_match_vector[i]) ||
                                   (DAT_Pop && DAT_match_vector[i]) );
    end : Info_Pop_gen
  endgenerate
    
  //determine the next available location for the next request
  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      Info_Index_next = 1;
    end
    else
    begin
      Info_Index_next = 1;
      for (int i = MAX_OS_SNP; i >= 1; i = i - 1)
      begin
        if (!Info_Alloc_vector[i] || Info_Pop_vector[i])
          Info_Index_next = i;
      end
    end
  end

  //determine the next available location in the credit vector
  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      Credit_Index_next = 1;
    end
    else
    begin
      Credit_Index_next = 0;
      for (int i = MAX_OS_SNP; i >= 1; i = i - 1)
      begin
        if (!Credit_Alloc_vector[i] )
          Credit_Index_next = i;
      end
    end
  end

  //give a last signal for DATA
  always_comb
  begin
    if (!Chi5_in.SRESETn || !DATFLITV_matched)
    begin
      DAT_Last = 1'b0;
    end
    else
    begin
      DAT_Last = 1'b0;
      case (DAT_FLIT_WIDTH)
        `CHI5PC_128B_DAT_FLIT_WIDTH:
        begin
          case (Current_DAT_Info.DATID[DAT_nodeIndex])
            4'b1110,4'b1101,4'b1011,4'b0111 :
            DAT_Last = 1'b1;
          default: 
            DAT_Last = 1'b0;
          endcase;
        end
        `CHI5PC_256B_DAT_FLIT_WIDTH:
        begin
          case (Current_DAT_Info.DATID[DAT_nodeIndex])
            4'b1100,4'b0011 :
            DAT_Last = 1'b1;
          default: 
            DAT_Last = 1'b0;
          endcase;
        end
        `CHI5PC_512B_DAT_FLIT_WIDTH:
        begin
          DAT_Last = 1'b1;
        end
      endcase;
    end
  end

  always @ (posedge SCLK)
  begin
    if (DATFLITV_matched)
    begin
      assert (DAT_Info_Index); 
    end
    if (RSPFLITV_matched)
    begin
      assert (RSP_Info_Index);
    end
  end
//------------------------------------------------------------------------------
// INDEX:   4)  SNP Channel Checks
//------------------------------------------------------------------------------ 
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_OPCD_S
  // =====
  property CHI5PC_ERR_SNP_OPCD_S; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_}))
       && SNPFLITV_ 
       && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPSHARED ||
           SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPCLEAN ||     
           SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPONCE ||     
           SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPUNIQUE ||     
           SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPCLEANSHARED ||     
           SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPCLEANINVALID ||     
           SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPMAKEINVALID)

      |-> (Chi5_in.NODE_TYPE == eChi5PCDevType'(RNF) && SNP_SRCID_NODE_TYPE_HAS_HNF ) || ((MODE == 1) && NODE_TYPE_HAS_HNF);
  endproperty
  chi5pc_err_snp_opcd_s: assert property (CHI5PC_ERR_SNP_OPCD_S) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_OPCD_S: The permitted communicating node pairs for a non-DVM snoop messages are: ICN(HNF) to RNF." ));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_OPCD_DVM
  // =====
  property CHI5PC_ERR_SNP_OPCD_DVM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_}))
       && SNPFLITV_ 
       && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP)
      |-> ((Chi5_in.NODE_TYPE == eChi5PCDevType'(RNF) 
           ||
          Chi5_in.NODE_TYPE == eChi5PCDevType'(RND)) 
             &&
            SNP_SRCID_NODE_TYPE_HAS_MN)
            ||
            ((MODE == 1) && (NODE_TYPE_HAS_MN))  ;
  endproperty
  chi5pc_err_snp_opcd_dvm: assert property (CHI5PC_ERR_SNP_OPCD_DVM) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_OPCD_DVM: The permitted communicating node pairs for a SnpDVMOp snoop messages are:ICN(MN) to RNF, RND." ));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_OVFLW
  // =====
  property CHI5PC_ERR_SNP_OVFLW; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(SNPFLITV_))
       && SNPFLITV_ && !SNPDVM_match && |SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] 
      |-> ~&Info_Alloc_vector || ((MODE == 0) && |Info_Pop_vector) ;
  endproperty
  chi5pc_err_snp_ovflw: assert property (CHI5PC_ERR_SNP_OVFLW) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_SNP_OVFLW::", string'(MODE == 1 ? " TXSNP: " : " RXSNP: "), "The number of outstanding snoops has exceeded MAX_OS_SNP."});



  // =====
  // INDEX:        - CHI5PC_ERR_SNP_X
  // =====
  property CHI5PC_ERR_SNP_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn &&  SNPFLITV_
      |-> ! $isunknown(SNPFLIT_);
  endproperty
  chi5pc_err_snp_x:  assert property (CHI5PC_ERR_SNP_X) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_SNP_X::", string'(MODE == 1 ? " TXSNP: " : " RXSNP: "), "A value of X is not allowed on SNPFLIT when SNPFLITV is high."});

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_RSVD_OPCODE
  // =====
  property CHI5PC_ERR_SNP_RSVD_OPCODE; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_}))
        && SNPFLITV_
       |-> (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPLINKFLIT ||
            SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPSHARED ||
            SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPCLEAN ||
            SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPONCE ||
            SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPUNIQUE ||
            SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPCLEANSHARED ||
            SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPCLEANINVALID ||
            SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPMAKEINVALID ||
            SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP 
          );

  endproperty
  chi5pc_err_snp_rsvd_opcode: assert property (CHI5PC_ERR_SNP_RSVD_OPCODE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_SNP_RSVD_OPCODE::", string'(MODE == 1 ? " TXSNP: " : " RXSNP: "), "Snoop flit opcode values 0x4, 0x5, 0x6, 0xB, 0xC, 0xE and 0xF are reserved."});
  
  /// =====
  // INDEX:        - CHI5PC_ERR_SNP_RSVD_DVM_MTYPE
  // =====
  property CHI5PC_ERR_SNP_RSVD_DVM_MTYPE;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && !Info_tmp.Addr.Partnum
      |-> (Info_tmp.Addr.Type <= CHI5PC_DVM_SYNC); 
  endproperty
  chi5pc_err_snp_rsvd_dvm_mtype : assert property (CHI5PC_ERR_SNP_RSVD_DVM_MTYPE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_SNP_RSVD_DVM_MTYPE::", string'(MODE == 1 ? " TXSNP: " : " RXSNP: "), "Snoop DVM Message Type field encodings 3'b101, 3'b110 and 3'b111 are reserved."});
   
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_RSVD_DVM_S2S1
  // =====
  property CHI5PC_ERR_SNP_RSVD_DVM_S2S1;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && !Info_tmp.Addr.Partnum
      |-> ~&Info_tmp.Addr.S2S1;
  endproperty
  chi5pc_err_snp_rsvd_dvm_s2s1 : assert property (CHI5PC_ERR_SNP_RSVD_DVM_S2S1) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_SNP_RSVD_DVM_S2S1::", string'(MODE == 1 ? " TXSNP: " : " RXSNP: "), "Snoop DVM Stage2/Stage1 field encoding 2'b11 is reserved."});
   
  
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_RSVD_DVM_SECURE
  // =====
  property CHI5PC_ERR_SNP_RSVD_DVM_SECURE; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_}))
       && SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && !Info_tmp.Addr.Partnum
      |-> Info_tmp.Addr.NS != 2'b01;
  endproperty
  chi5pc_err_snp_rsvd_dvm_secure: assert property (CHI5PC_ERR_SNP_RSVD_DVM_SECURE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_SNP_RSVD_DVM_SECURE::", string'(MODE == 1 ? " TXSNP: " : " RXSNP: "), "Snoop DVM Secure field encoding 2'b01 is reserved."});
  

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_CTL_SNPDVMOP
  // =====
  property CHI5PC_ERR_SNP_CTL_SNPDVMOP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_}))
       && SNPFLITV_ && SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP 
      |-> ~|SNPFLIT_[`CHI5PC_SNP_FLIT_NS_RANGE]; 
  endproperty
  chi5pc_err_snp_ctl_snpdvmop: assert property (CHI5PC_ERR_SNP_CTL_SNPDVMOP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_SNP_CTL_SNPDVMOP::", string'(MODE == 1 ? " TXSNP: " : " RXSNP: "), "Snoop flits with opcode SnpDVMOp must have NS = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_CTL_LINKFLIT
  // =====
  property CHI5PC_ERR_SNP_CTL_LINKFLIT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_}))
       && SNPFLITV_ && SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPLINKFLIT 
      |-> ~|SNPFLIT_[`CHI5PC_SNP_FLIT_TXNID_RANGE];
  endproperty
  chi5pc_err_snp_ctl_linkflit: assert property (CHI5PC_ERR_SNP_CTL_LINKFLIT) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_SNP_CTL_LINKFLIT::", string'(MODE == 1 ? " TXSNP: " : " RXSNP: "), "Snoop flits with opcode SnpLinkFlit must have TxnID = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_TXNID_UNQ
  // =====
  property CHI5PC_ERR_SNP_TXNID_UNQ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_}))
       && SNPFLITV_ && SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPLINKFLIT 
      |-> ~|ID_CLASH_vector;
  endproperty
  chi5pc_err_snp_txnid_unq: assert property (CHI5PC_ERR_SNP_TXNID_UNQ) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_SNP_TXNID_UNQ::", string'(MODE == 1 ? " TXSNP: " : " RXSNP: "), "The TxnID value of a snoop flit must be unique."});

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_SYNC_UNQ
  // =====
  property CHI5PC_ERR_SNP_SYNC_UNQ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_}))
       && SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && (Info_tmp.Addr.Type == CHI5PC_DVM_SYNC) && !Info_tmp.Addr.Partnum
      |-> ~|DVM_SYNC_CLASH_vector;
  endproperty
  chi5pc_err_snp_sync_unq: assert property (CHI5PC_ERR_SNP_SYNC_UNQ) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_SNP_SYNC_UNQ::", string'(MODE == 1 ? " TXSNP: " : " RXSNP: "), "An RN must not receive more than one SYNC DVM at a time."});

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_ADDR_UNQ
  // =====
  property CHI5PC_ERR_SNP_ADDR_UNQ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_}))
       && SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPDVMOP) 
       && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPLINKFLIT)
      |-> ~|ADDR_CLASH_vector;
  endproperty
  chi5pc_err_snp_addr_unq: assert property (CHI5PC_ERR_SNP_ADDR_UNQ) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_SNP_ADDR_UNQ::", string'(MODE == 1 ? " TXSNP: " : " RXSNP: "), "An RN must not receive more than one snoop to a cacheline at the same time."});


  // =====
  // INDEX:        - CHI5PC_ERR_SNP_DVM_TLBI_GUEST_NS
  // =====
  property CHI5PC_ERR_SNP_DVM_TLBI_GUEST_NS;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && 
       (Info_tmp.Addr.Type == CHI5PC_DVM_TLB_INV) && !Info_tmp.Addr.Partnum && 
       (Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_GUESTOS) && 
       (Info_tmp.Addr.NS == CHI5PC_DVM_NS_NONSECURE) 
       |-> (((Info_tmp.Addr.VMID_Valid == 1'b1) &&  //1 
               (Info_tmp.Addr.ASID_Valid == 1'b1) && 
               (Info_tmp.Addr.L == 1'b0) && 
               (Info_tmp.Addr.S2S1 == 2'b00) && 
               (Info_tmp.Addr.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.VMID_Valid == 1'b1) && //2
               (Info_tmp.Addr.ASID_Valid == 1'b1) && 
               (Info_tmp.Addr.L == 1'b1) && 
               (Info_tmp.Addr.S2S1 == 2'b00) && 
               (Info_tmp.Addr.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.VMID_Valid == 1'b1) &&  //3
               (Info_tmp.Addr.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.L == 1'b0) && 
               (Info_tmp.Addr.S2S1 == 2'b00) && 
               (Info_tmp.Addr.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.VMID_Valid == 1'b1) &&  //4
               (Info_tmp.Addr.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.L == 1'b1) && 
               (Info_tmp.Addr.S2S1 == 2'b00) && 
               (Info_tmp.Addr.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.VMID_Valid == 1'b1) &&  //5
               (Info_tmp.Addr.ASID_Valid == 1'b1) && 
               (Info_tmp.Addr.L == 1'b0) && 
               (Info_tmp.Addr.S2S1 == 2'b00) && 
               (Info_tmp.Addr.VA_Valid == 1'b0))
           || ((Info_tmp.Addr.VMID_Valid == 1'b1) &&  //6
               (Info_tmp.Addr.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.L == 1'b0) && 
               (Info_tmp.Addr.S2S1 == 2'b01) && 
               (Info_tmp.Addr.VA_Valid == 1'b0))
           || ((Info_tmp.Addr.VMID_Valid == 1'b1) &&  //7
               (Info_tmp.Addr.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.L == 1'b0) && 
               (Info_tmp.Addr.S2S1 == 2'b00) && 
               (Info_tmp.Addr.VA_Valid == 1'b0))
           || ((Info_tmp.Addr.VMID_Valid == 1'b0) &&  //8
               (Info_tmp.Addr.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.L == 1'b0) && 
               (Info_tmp.Addr.S2S1 == 2'b00) && 
               (Info_tmp.Addr.VA_Valid == 1'b0))
           || ((Info_tmp.Addr.VMID_Valid == 1'b1) &&  //9
               (Info_tmp.Addr.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.L == 1'b0) && 
               (Info_tmp.Addr.S2S1 == 2'b10) && 
               (Info_tmp.Addr.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.VMID_Valid == 1'b1) &&  //10
               (Info_tmp.Addr.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.L == 1'b1) && 
               (Info_tmp.Addr.S2S1 == 2'b10) && 
               (Info_tmp.Addr.VA_Valid == 1'b1)));

  endproperty
  chi5pc_err_snp_dvm_tlbi_guest_ns : assert property (CHI5PC_ERR_SNP_DVM_TLBI_GUEST_NS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_DVM_TLBI_GUEST_NS: Snoop DVM message (TLBI, GuestOS, Non-Secure) detected with an unsupported combined encoding of fields ASID_Valid, VMID_Valid, LEAF, S2-S1 & VA_Valid."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_DVM_TLBI_GUEST_S
  // =====
  property CHI5PC_ERR_SNP_DVM_TLBI_GUEST_S;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && 
       (Info_tmp.Addr.Type == CHI5PC_DVM_TLB_INV) && !Info_tmp.Addr.Partnum && 
       (Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_GUESTOS) &&
       (Info_tmp.Addr.NS == CHI5PC_DVM_NS_SECURE) 
        |-> (((Info_tmp.Addr.VMID_Valid == 1'b0) && //11
               (Info_tmp.Addr.ASID_Valid == 1'b1) && 
               (Info_tmp.Addr.L == 1'b0) && 
               (Info_tmp.Addr.S2S1 == 2'b00) && 
               (Info_tmp.Addr.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.VMID_Valid == 1'b0) && //12 
               (Info_tmp.Addr.ASID_Valid == 1'b1) && 
               (Info_tmp.Addr.L == 1'b1) && 
               (Info_tmp.Addr.S2S1 == 2'b00) && 
               (Info_tmp.Addr.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.VMID_Valid == 1'b0) &&  //13
               (Info_tmp.Addr.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.L == 1'b0) && 
               (Info_tmp.Addr.S2S1 == 2'b00) && 
               (Info_tmp.Addr.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.VMID_Valid == 1'b0) &&  //14
               (Info_tmp.Addr.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.L == 1'b1) && 
               (Info_tmp.Addr.S2S1 == 2'b00) && 
               (Info_tmp.Addr.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.VMID_Valid == 1'b0) &&  //15
               (Info_tmp.Addr.ASID_Valid == 1'b1) && 
               (Info_tmp.Addr.L == 1'b0) && 
               (Info_tmp.Addr.S2S1 == 2'b00) && 
               (Info_tmp.Addr.VA_Valid == 1'b0))
           || ((Info_tmp.Addr.VMID_Valid == 1'b0) &&  //16
               (Info_tmp.Addr.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.L == 1'b0) && 
               (Info_tmp.Addr.S2S1 == 2'b00) && 
               (Info_tmp.Addr.VA_Valid == 1'b0)));
  endproperty
  chi5pc_err_snp_dvm_tlbi_guest_s : assert property (CHI5PC_ERR_SNP_DVM_TLBI_GUEST_S) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_DVM_TLBI_GUEST_S: Snoop DVM message (TLBI, GuestOS, Secure) detected with an unsupported combined encoding of fields ASID_Valid, VMID_Valid, LEAF, S2-S1 & VA_Valid."));
   
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_DVM_TLBI_HYP_NS
  // =====
  property CHI5PC_ERR_SNP_DVM_TLBI_HYP_NS;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && 
       (Info_tmp.Addr.Type == CHI5PC_DVM_TLB_INV) && !Info_tmp.Addr.Partnum &&
       (Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_HYPERVISOR) 
       |-> (Info_tmp.Addr.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (((Info_tmp.Addr.VMID_Valid == 1'b0) &&  //17
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b1))
       || (((Info_tmp.Addr.VMID_Valid == 1'b0) &&  //18
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b1) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b1)))
       || ((Info_tmp.Addr.VMID_Valid == 1'b0) &&  //19
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b0)));

  endproperty
  chi5pc_err_snp_dvm_tlbi_hyp_ns : assert property (CHI5PC_ERR_SNP_DVM_TLBI_HYP_NS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_DVM_TLBI_HYP_NS: Snoop DVM message (TLBI, Hypervisor, Non-Secure) detected with an unsupported combined encoding of fields ASID_Valid, VMID_Valid, LEAF, S2-S1 & VA_Valid."));
   
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_DVM_TLBI_EL3_S
  // =====
  property CHI5PC_ERR_SNP_DVM_TLBI_EL3_S;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && 
       (Info_tmp.Addr.Type == CHI5PC_DVM_TLB_INV) && !Info_tmp.Addr.Partnum &&
       (Info_tmp.Addr.Hyp == 2'b01) 
       |-> (Info_tmp.Addr.NS == CHI5PC_DVM_NS_SECURE) && 
           (((Info_tmp.Addr.VMID_Valid == 1'b0) &&  //20
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b1))
       || ((Info_tmp.Addr.VMID_Valid == 1'b0) &&  //21
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b1) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b1))
       || ((Info_tmp.Addr.VMID_Valid == 1'b0) && //22 
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b0)));

  endproperty
  chi5pc_err_snp_dvm_tlbi_el3_s : assert property (CHI5PC_ERR_SNP_DVM_TLBI_EL3_S) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_DVM_TLBI_EL3_S: Snoop DVM message (TLBI, EL3, Secure) detected with an unsupported combined encoding of fields ASID_Valid, VMID_Valid, LEAF, S2-S1 & VA_Valid."));
   
   // =====
  // INDEX:        - CHI5PC_ERR_SNP_DVM_TLBI_GUEST_HYP_BOTH
  // =====
  property CHI5PC_ERR_SNP_DVM_TLBI_GUEST_HYP_BOTH;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && 
       (Info_tmp.Addr.Type == CHI5PC_DVM_TLB_INV) 
       && !Info_tmp.Addr.Partnum
       |-> Info_tmp.Addr.Hyp != 2'b00;

  endproperty
  chi5pc_err_snp_dvm_tlbi_guest_hyp_both : assert property (CHI5PC_ERR_SNP_DVM_TLBI_GUEST_HYP_BOTH) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_DVM_TLBI_GUEST_HYP_BOTH: Unsupported snoop DVM message (TLBI, Both GuestOS & Hypervisor) detected."));
   
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_DVM_TLBI_NS_S_BOTH: 
  // =====
  property CHI5PC_ERR_SNP_DVM_TLBI_NS_S_BOTH;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && 
       (Info_tmp.Addr.Type == CHI5PC_DVM_TLB_INV) 
       && !Info_tmp.Addr.Partnum
       |-> Info_tmp.Addr.NS  != CHI5PC_DVM_NS_BOTH;

  endproperty
  chi5pc_err_snp_dvm_tlbi_ns_s_both : assert property (CHI5PC_ERR_SNP_DVM_TLBI_NS_S_BOTH) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_DVM_TLBI_NS_S_BOTH: Unsupported snoop DVM message (TLBI, Both Non-Secure & Secure) detected."));
   
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_DVM_TLBI_HYP_S
  // =====
  property CHI5PC_ERR_SNP_DVM_TLBI_HYP_S;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && 
       (Info_tmp.Addr.Type == CHI5PC_DVM_TLB_INV) &&  
       (Info_tmp.Addr.Hyp == 2'b11) 
       && !Info_tmp.Addr.Partnum
       |-> Info_tmp.Addr.NS == CHI5PC_DVM_NS_NONSECURE ;

  endproperty
  chi5pc_err_snp_dvm_tlbi_hyp_s : assert property (CHI5PC_ERR_SNP_DVM_TLBI_HYP_S) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_DVM_TLBI_HYP_S: Unsupported snoop DVM message (TLBI, Hypervisor, Secure) detected."));
   
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_DVM_TLBI_EL3_NS
  // =====
  property CHI5PC_ERR_SNP_DVM_TLBI_EL3_NS;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && 
       (Info_tmp.Addr.Type == CHI5PC_DVM_TLB_INV) &&  
       (Info_tmp.Addr.Hyp == 2'b01) 
       && !Info_tmp.Addr.Partnum
       |-> Info_tmp.Addr.NS == CHI5PC_DVM_NS_SECURE ;

  endproperty
  chi5pc_err_snp_dvm_tlbi_el3_ns : assert property (CHI5PC_ERR_SNP_DVM_TLBI_EL3_NS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_DVM_TLBI_EL3_NS: Unsupported snoop DVM message (TLBI, EL3, Non-Secure) detected."));
   


  // =====
  // INDEX:        - CHI5PC_ERR_SNP_DVM_BPI
  // =====
  property CHI5PC_ERR_SNP_DVM_BPI;
    @(posedge `CHI5_SVA_CLK) 
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && 
       (Info_tmp.Addr.Type == CHI5PC_DVM_BTB_INV) && !Info_tmp.Addr.Partnum 
      |-> ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_BOTH) && 
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_BOTH) && 
           (Info_tmp.Addr.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b0))
       || ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_BOTH) && 
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_BOTH) && 
           (Info_tmp.Addr.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b1));
  endproperty
  chi5pc_err_snp_dvm_bpi : assert property (CHI5PC_ERR_SNP_DVM_BPI) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_DVM_BPI: Snoop DVM message (BPI) detected with an unsupported combined encoding of fields GuestOS_Hypervisor, Security, VMID_Valid, ASID_Valid, LEAF, S2-S1 & VA_Valid."));
    
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_DVM_PICI
  // =====
  property CHI5PC_ERR_SNP_DVM_PICI;
    @(posedge `CHI5_SVA_CLK) 
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && 
       (Info_tmp.Addr.Type == CHI5PC_DVM_IC_PA_INV) && !Info_tmp.Addr.Partnum 
      |-> ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_BOTH) && 
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_SECURE) && 
           (Info_tmp.Addr.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b0))
       || ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_BOTH) && 
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_SECURE) && 
           (Info_tmp.Addr.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b1))
       || ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_BOTH) && 
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_SECURE) && 
           (Info_tmp.Addr.VMID_Valid == 1'b1) && 
           (Info_tmp.Addr.ASID_Valid == 1'b1) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b1))
       || ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_BOTH) && 
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (Info_tmp.Addr.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b0))  
       || ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_BOTH) && 
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (Info_tmp.Addr.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b1))  
       || ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_BOTH) && 
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (Info_tmp.Addr.VMID_Valid == 1'b1) && 
           (Info_tmp.Addr.ASID_Valid == 1'b1) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b1));
  endproperty
  chi5pc_err_snp_dvm_pici : assert property (CHI5PC_ERR_SNP_DVM_PICI) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_DVM_PICI: Snoop DVM message (PICI) detected with an unsupported combined encoding of fields GuestOS_Hypervisor, Security, VMID_Valid, ASID_Valid, LEAF, S2-S1 & VA_Valid."));
    
    
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_DVM_VICI
  // =====
  property CHI5PC_ERR_SNP_DVM_VICI;
    @(posedge `CHI5_SVA_CLK) 
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && 
       (Info_tmp.Addr.Type == CHI5PC_DVM_IC_VA_INV) && !Info_tmp.Addr.Partnum 
      |-> ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_BOTH) &&  //29
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_BOTH) && 
           (Info_tmp.Addr.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b0))
       || ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_BOTH) && //30
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (Info_tmp.Addr.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.ASID_Valid == 1'b0) &&
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b0))
       || ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_GUESTOS) && //31
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_SECURE) && 
           (Info_tmp.Addr.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.ASID_Valid == 1'b1) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b1))  
       || ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_GUESTOS) && //32
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (Info_tmp.Addr.VMID_Valid == 1'b1) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.VA_Valid == 1'b0)) 
       || ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_GUESTOS) && //33
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (Info_tmp.Addr.VMID_Valid == 1'b1) && 
           (Info_tmp.Addr.ASID_Valid == 1'b1) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b1)) 
       || ((Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_HYPERVISOR) && //34
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (Info_tmp.Addr.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b1));//Using ACE definition rather than DVM for v8 draft
  endproperty
  chi5pc_err_snp_dvm_vici : assert property (CHI5PC_ERR_SNP_DVM_VICI) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_DVM_VICI: Snoop DVM message (VICI) detected with an unsupported combined encoding of fields GuestOS_Hypervisor, Security, VMID_Valid, ASID_Valid, LEAF, S2-S1 & VA_Valid."));
    
    
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_DVM_SYNC
  // =====
  property CHI5PC_ERR_SNP_DVM_SYNC;
    @(posedge `CHI5_SVA_CLK) 
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && 
       (Info_tmp.Addr.Type == CHI5PC_DVM_SYNC) && !Info_tmp.Addr.Partnum
      |-> (Info_tmp.Addr.Hyp == CHI5PC_DVM_HYP_BOTH) && 
           (Info_tmp.Addr.NS == CHI5PC_DVM_NS_BOTH) && 
           (Info_tmp.Addr.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.L == 1'b0) && 
           (Info_tmp.Addr.S2S1 == 2'b00) && 
           (Info_tmp.Addr.VA_Valid == 1'b0);
  endproperty
  chi5pc_err_snp_dvm_sync : assert property (CHI5PC_ERR_SNP_DVM_SYNC) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_DVM_SYNC: Snoop DVM message (SYNC) detected with an unsupported combined encoding of fields GuestOS_Hypervisor, Security, VMID_Valid, ASID_Valid, LEAF, S2-S1 & VA_Valid."));
  
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_DVM_PARTNUM
  // =====
  property CHI5PC_ERR_SNP_DVM_PARTNUM;
    @(posedge `CHI5_SVA_CLK) 
    `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_})) &&
       SNPFLITV_ && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPDVMOP) && 
       SNPDVM_match
      |-> !Current_SNP_Info.DVMPart[Info_tmp.Addr.Partnum];
  endproperty
  chi5pc_err_snp_dvm_partnum : assert property (CHI5PC_ERR_SNP_DVM_PARTNUM) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_SNP_DVM_PARTNUM::", string'(MODE == 1 ? " TXSNP: " : " RXSNP: "), "Each part of a SnpDVMOp can only be issued once."});

  
//------------------------------------------------------------------------------
// INDEX:   5)  DAT Channel Checks
//------------------------------------------------------------------------------ 

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_SS
  // =====
  property CHI5PC_ERR_DAT_RESP_SS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
       && DATFLITV_ && DAT_match &&   
          (Current_DAT_Info.OpCode == `CHI5PC_SNPSHARED ) 
          && |DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE]
        |-> ((DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATA) &&
            ((DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_SC) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_SD) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I_PD) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_SC_PD) )) ||
            ((DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATAPTL) &&
            (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I_PD)) ;
  endproperty
  chi5pc_err_dat_resp_ss: assert property (CHI5PC_ERR_DAT_RESP_SS) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_SS::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The Resp field of a SnpShared transaction must be I, SC, SD, I_PD or SC_PD for SnpRespData messages and I_PD for SnpRespDataPtl messages."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_SC
  // =====
  property CHI5PC_ERR_DAT_RESP_SC; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
       && DATFLITV_ &&   DAT_match &&   
          (Current_DAT_Info.OpCode == `CHI5PC_SNPCLEAN ) 
          && |DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE]
        |-> ((DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATA) &&
            ((DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_SC) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_SD) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I_PD) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_SC_PD))) ||
            ((DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATAPTL) &&
            (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I_PD)) ;
  endproperty
  chi5pc_err_dat_resp_sc: assert property (CHI5PC_ERR_DAT_RESP_SC) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_SC::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The Resp field of a SnpClean transaction must be I, SC, SD, I_PD or SC_PD for SnpRespData messages and I_PD for SnpRespDataPtl messages."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_SO
  // =====
  property CHI5PC_ERR_DAT_RESP_SO; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
       && DATFLITV_ && DAT_match &&   
          (Current_DAT_Info.OpCode == `CHI5PC_SNPONCE) 
          && |DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE]
        |-> ((DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATA) &&
            ((DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I) || 
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_SC) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_UC_UD) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_SD) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I_PD) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_SC_PD))) ||
            ((DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATAPTL) &&
            ((DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_UC_UD) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I_PD)));
  endproperty
  chi5pc_err_dat_resp_so: assert property (CHI5PC_ERR_DAT_RESP_SO) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_SO::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The Resp field of a SnpOnce transaction must be I, SC, UC, SD, I_PD or SC_PD for SnpRespData messages and UC or I_PD for SnpRespDataPtl messages."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_SU
  // =====
  property CHI5PC_ERR_DAT_RESP_SU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
       && DATFLITV_ &&  DAT_match &&    
          (Current_DAT_Info.OpCode == `CHI5PC_SNPUNIQUE ) 
          && |DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE]
        |-> ((DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATA) &&
            ((DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I_PD))) ||
            ((DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATAPTL) &&
            (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I_PD));
  endproperty
  chi5pc_err_dat_resp_su: assert property (CHI5PC_ERR_DAT_RESP_SU) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_SU::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The Resp field of a SnpUnique transaction must be I or I_PD for SnpRespData messages and I_PD for SnpRespDataPtl messages."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_SCS
  // =====
  property CHI5PC_ERR_DAT_RESP_SCS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
       && DATFLITV_ &&  DAT_match &&    
          (Current_DAT_Info.OpCode == `CHI5PC_SNPCLEANSHARED ) 
          && |DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE]
        |-> ((DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATA) &&
            ((DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I_PD) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_SC_PD) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_UC_PD))) ||
            ((DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATAPTL) &&
            (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I_PD));
  endproperty
  chi5pc_err_dat_resp_scs: assert property (CHI5PC_ERR_DAT_RESP_SCS) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_SCS::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The Resp field of a SnpCleanShared transaction must be I_PD, SC_PD or UC_PD for SnpRespData messages and I_PD for SnpRespDataPtl messages."});

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_SCI
  // =====
  property CHI5PC_ERR_DAT_RESP_SCI; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
       && DATFLITV_ &&   DAT_match &&   
          (Current_DAT_Info.OpCode == `CHI5PC_SNPCLEANINVALID ) 
          && |DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE]
        |-> ((DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATA) ||
             (DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATAPTL)) &&
            (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == snp_I_PD);
  endproperty
  chi5pc_err_dat_resp_sci: assert property (CHI5PC_ERR_DAT_RESP_SCI) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_SCI::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The Resp field of a SnpCleanInvalid transaction must be I_PD for SnpRespData messages and I_PD for SnpRespDataPtl messages."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESPERR_SNOOP
  // =====
  property CHI5PC_ERR_DAT_RESPERR_SNOOP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
       && DATFLITV_ && DAT_match 
      |->  (DATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] != CHI5PC_EXCL_OK) && (DATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] != CHI5PC_NON_DATA_ERR);
  endproperty
  chi5pc_err_dat_resperr_snoop: assert property (CHI5PC_ERR_DAT_RESPERR_SNOOP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESPERR_SNOOP::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The RespErr field of the SnpRespData* message of a snoop transaction must be OK or DERR."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RSVD_RESP_SNOOP
  // =====
  property CHI5PC_ERR_DAT_RSVD_RESP_SNOOP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
       && DATFLITV_ && ((DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATA) || (DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATAPTL))
       && !DATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_MSB]

      |-> !(DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == 3'b111);
  endproperty
  chi5pc_err_dat_rsvd_resp_snoop: assert property (CHI5PC_ERR_DAT_RSVD_RESP_SNOOP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RSVD_RESP_SNOOP::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "Resp field value 3'b111 in SnpRespData* messages is reserved."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_SNPMAKEINVALID
  // =====
  property CHI5PC_ERR_DAT_SNPMAKEINVALID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DAT_Info_Index}))
       && DATFLITV_  && 
          (Current_DAT_Info.OpCode == `CHI5PC_SNPMAKEINVALID ) 
        |-> ~|DAT_Info_Index;
  endproperty
  chi5pc_err_dat_snpmakeinvalid: assert property (CHI5PC_ERR_DAT_SNPMAKEINVALID) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_SNPMAKEINVALID::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "SnpRespData* messages are not valid for a SnpMakeInvalid transaction."});

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_SNPRESP_UNIFORM
  // =====
  property CHI5PC_ERR_DAT_SNPRESP_UNIFORM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
       && DATFLITV_ && DAT_match &&  |Current_DAT_Info.DATID[DAT_nodeIndex]
      |->  (DATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == Current_DAT_Info.Resp[DAT_nodeIndex]);
  endproperty
  chi5pc_err_dat_snpresp_uniform: assert property (CHI5PC_ERR_DAT_SNPRESP_UNIFORM) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_SNPRESP_UNIFORM::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "SnpRespData* Resp values must be consistent for every data flit of a snoop transaction."});

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_SNPDVMOP
  // =====
  property CHI5PC_ERR_DAT_RESP_SNPDVMOP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
       && DATFLITV_ && DAT_match 
       |->  Current_DAT_Info.OpCode != `CHI5PC_SNPDVMOP;
  endproperty
  chi5pc_err_dat_resp_snpdvmop: assert property (CHI5PC_ERR_DAT_RESP_SNPDVMOP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_SNPDVMOP::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "SnpRespData* messages are not valid for a SnpDVMOp transaction."});

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_SNPWRAPORDER
  // =====
  logic [1:0] Next_snpDATID;
  assign Next_snpDATID = Chi5_in.Next_snpDATID(Current_DAT_Info.DATID[DAT_nodeIndex],Current_DAT_Info.Addr[2:1]) ;
  property CHI5PC_ERR_DAT_SNPWRAPORDER; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
       && DATFLITV_ && DAT_match &&  (MODE == 0) && (PCMODE == LOCAL)
      |-> DATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE] == Next_snpDATID;
  endproperty
  chi5pc_err_dat_snpwraporder: assert property (CHI5PC_ERR_DAT_SNPWRAPORDER) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_SNPWRAPORDER: Snoop data must be sent in Critical-Chunk first wrap-order."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_SNPCCID
  // =====
  property CHI5PC_ERR_DAT_SNPCCID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
       && DATFLITV_ && DAT_match
      |->  (DATFLIT_[`CHI5PC_DAT_FLIT_CCID_RANGE] == Current_DAT_Info.Addr[2:1]);
  endproperty
  chi5pc_err_dat_snpccid: assert property (CHI5PC_ERR_DAT_SNPCCID) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_SNPCCID::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "Snoop data CCID must always correspond to bits 5:4 of the transaction's address."});

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CTL_SNPRESPDATA
  // =====
  property CHI5PC_ERR_DAT_CTL_SNPRESPDATA; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
        && DATFLITV_matched
      |-> ((DATFLIT_[`CHI5PC_DAT_FLIT_DBID_RANGE] == 'b0) || (DATFLIT_[`CHI5PC_DAT_FLIT_DBID_RANGE] == Current_DAT_Info.TxnID));
  endproperty
  chi5pc_err_dat_ctl_snprespdata: assert property (CHI5PC_ERR_DAT_CTL_SNPRESPDATA) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_CTL_SNPRESPDATA::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "Data flits with opcode SnpRespData* must have DBID = 'b0 or the TxnID of the originating request."});



  // =====
  // INDEX:        - CHI5PC_ERR_DAT_SNP_HAZARD_RD
  // =====
  property CHI5PC_ERR_DAT_SNP_HAZARD_RD; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDAT_Data_FLITV,RDDAT_Addr_NS_haz_vector}))
        && RDDAT_Data_FLITV && Chi5_in.NODE_TYPE == eChi5PCDevType'(RNF)
      |-> ~|RDDAT_Addr_NS_haz_vector;
  endproperty
  chi5pc_err_dat_snp_hazard_rd: assert property (CHI5PC_ERR_DAT_SNP_HAZARD_RD) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_SNP_HAZARD_RD: Node type RNF cannot receive read data for an address for which it has an outstanding snoop until after sending the snoop response or last snoop data flit."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RSP_FOR_SNOOP
  // =====
  property CHI5PC_ERR_DAT_RSP_FOR_SNOOP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_matched,Current_DAT_Info}))
        && DATFLITV_matched && NODE_TYPE_HAS_HNF
      |-> ~|Current_DAT_Info.Rcvd_RSP[DAT_nodeIndex];
  endproperty
  chi5pc_err_dat_rsp_for_snoop: assert property (CHI5PC_ERR_DAT_RSP_FOR_SNOOP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RSP_FOR_SNOOP:  HNF must not receive snoop data from a given RNF that has already sent a snoop response."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CONST_OPCODE_SNPDAT
  // =====
  property CHI5PC_ERR_DAT_CONST_OPCODE_SNPDAT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
        && DATFLITV_ && DATFLITV_matched && |Current_DAT_Info.DATID[DAT_nodeIndex]
       |-> DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == Current_DAT_Info.DatOpCode;

  endproperty
  chi5pc_err_dat_const_opcode_snpdat: assert property (CHI5PC_ERR_DAT_CONST_OPCODE_SNPDAT) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_CONST_OPCODE_SNPDAT::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "Opcode field values are required to be constant for all snoop-data flits within a transaction."});

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CONST_DBID_SNOOP
  // =====
  property CHI5PC_ERR_DAT_CONST_DBID_SNOOP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({DATFLITV_,DATFLIT_}))
        && DATFLITV_ && DATFLITV_matched
        && |Current_DAT_Info.DATID[DAT_nodeIndex]
       |-> DATFLIT_[`CHI5PC_DAT_FLIT_DBID_RANGE] == Current_DAT_Info.DBID;

  endproperty
  chi5pc_err_dat_const_dbid_snoop: assert property (CHI5PC_ERR_DAT_CONST_DBID_SNOOP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_CONST_DBID_SNOOP::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "DBID values for SnpRespData* must be consistent for all data beats."});


//------------------------------------------------------------------------------
// INDEX:   6)  RSP Channel Checks
//------------------------------------------------------------------------------ 

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_SS
  // =====
  property CHI5PC_ERR_RSP_RESP_SS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RSPFLITV_,RSPFLIT_}))
       && RSPFLITV_ && RSP_match 
       && (Current_RSP_Info.OpCode == `CHI5PC_SNPSHARED ) 
       && (RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_NON_DATA_ERR)
        |-> (RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESP) &&
            ((RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_I) ||
             (RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_SC));
  endproperty
  chi5pc_err_rsp_resp_ss: assert property (CHI5PC_ERR_RSP_RESP_SS) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_SS::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the SnpResp message of a SnpShared transaction must be I or SC."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_SC
  // =====
  property CHI5PC_ERR_RSP_RESP_SC; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RSPFLITV_,RSPFLIT_}))
       && RSPFLITV_ && RSP_match && 
          (Current_RSP_Info.OpCode == `CHI5PC_SNPCLEAN ) 
       && (RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_NON_DATA_ERR)
        |-> (RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESP) &&
            ((RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_I) ||
             (RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_SC));
  endproperty
  chi5pc_err_rsp_resp_sc: assert property (CHI5PC_ERR_RSP_RESP_SC) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_SC::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the SnpResp message of a SnpClean transaction must be I or SC."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_SO
  // =====
  property CHI5PC_ERR_RSP_RESP_SO; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RSPFLITV_,RSPFLIT_}))
       && RSPFLITV_ && RSP_match && 
          (Current_RSP_Info.OpCode == `CHI5PC_SNPONCE) 
       && (RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_NON_DATA_ERR)
        |-> (RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESP) &&
            ((RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_I) ||
             (RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_SC) ||
             (RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_UC_UD));
  endproperty
  chi5pc_err_rsp_resp_so: assert property (CHI5PC_ERR_RSP_RESP_SO) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_SO::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the SnpResp message of a SnpOnce transaction must be I, SC or UC."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_SU
  // =====
  property CHI5PC_ERR_RSP_RESP_SU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RSPFLITV_,RSPFLIT_}))
       && RSPFLITV_ && RSP_match && 
          (Current_RSP_Info.OpCode == `CHI5PC_SNPUNIQUE ) 
       && (RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_NON_DATA_ERR)
        |-> (RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESP) &&
            (RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_I);
  endproperty
  chi5pc_err_rsp_resp_su: assert property (CHI5PC_ERR_RSP_RESP_SU) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_SU::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the SnpResp message of a SnpUnique transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_SCS
  // =====
  property CHI5PC_ERR_RSP_RESP_SCS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RSPFLITV_,RSPFLIT_}))
       && RSPFLITV_ && RSP_match && 
          (Current_RSP_Info.OpCode == `CHI5PC_SNPCLEANSHARED ) 
       && (RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_NON_DATA_ERR)
        |-> (RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESP) &&
            ((RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_I) ||
             (RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_SC) ||
             (RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_UC_UD));
  endproperty
  chi5pc_err_rsp_resp_scs: assert property (CHI5PC_ERR_RSP_RESP_SCS) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_SCS::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the SnpResp message of a SnpCleanShared transaction must be I, SC or UC."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_SCI
  // =====
  property CHI5PC_ERR_RSP_RESP_SCI; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RSPFLITV_,RSPFLIT_}))
       && RSPFLITV_ && RSP_match && 
          (Current_RSP_Info.OpCode == `CHI5PC_SNPCLEANINVALID ) 
       && (RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_NON_DATA_ERR)
        |-> (RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESP) &&
            (RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_I);
  endproperty
  chi5pc_err_rsp_resp_sci: assert property (CHI5PC_ERR_RSP_RESP_SCI) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_SCI::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the SnpResp message of a SnpCleanInvalid transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_SMI
  // =====
  property CHI5PC_ERR_RSP_RESP_SMI; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RSPFLITV_,RSPFLIT_}))
       && RSPFLITV_ && RSP_match && 
          (Current_RSP_Info.OpCode == `CHI5PC_SNPMAKEINVALID ) 
       && (RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_NON_DATA_ERR)
        |-> (RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESP) &&
            (RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_I);
  endproperty
  chi5pc_err_rsp_resp_smi: assert property (CHI5PC_ERR_RSP_RESP_SMI) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_SMI::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the SnpResp message of a SnpMakeInvalid transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_SDVM
  // =====
  property CHI5PC_ERR_RSP_RESP_SDVM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RSPFLITV_,RSPFLIT_}))
       && RSPFLITV_ && RSP_match && 
          (Current_RSP_Info.OpCode == `CHI5PC_SNPDVMOP)
       && (RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_NON_DATA_ERR)
        |-> (RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESP) &&
            (RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == snp_I);
  endproperty
  chi5pc_err_rsp_resp_sdvm: assert property (CHI5PC_ERR_RSP_RESP_SDVM) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_SDVM::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the SnpResp message of a SnpDVMOp transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESPERR_SNOOP
  // =====
  property CHI5PC_ERR_RSP_RESPERR_SNOOP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RSPFLITV_,RSPFLIT_}))
        && RSPFLITV_ && RSP_match
       |-> ~^RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE];
  endproperty
  chi5pc_err_rsp_resperr_snoop: assert property (CHI5PC_ERR_RSP_RESPERR_SNOOP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESPERR_SNOOP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The RespErr field in the SnpResp message of a snoop transaction must be OK or NDERR."});
    

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RSVD_RESP_SNOOP
  // =====
  property CHI5PC_ERR_RSP_RSVD_RESP_SNOOP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RSPFLITV_,RSPFLIT_}))
       && RSPFLITV_ && (RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESP)
       && !RSPFLIT_[`CHI5PC_DAT_FLIT_RESPERR_MSB]
      |-> !(RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == 3'b111);
  endproperty
  chi5pc_err_rsp_rsvd_resp_snoop: assert property (CHI5PC_ERR_RSP_RSVD_RESP_SNOOP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RSVD_RESP_SNOOP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Resp field value 3'b111 in SnpResp messages is reserved."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_CTL_SNPRESP
  // =====
  property CHI5PC_ERR_RSP_CTL_SNPRESP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RSPFLITV_,RSPFLIT_}))
        && RSPFLITV_matched
      |-> RSPFLIT_[`CHI5PC_RSP_FLIT_PCRDTYPE_RANGE] == 'b0 ;
  endproperty
  chi5pc_err_rsp_ctl_snpresp: assert property (CHI5PC_ERR_RSP_CTL_SNPRESP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_CTL_SNPRESP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Response flits to requests made on the Snoop VC channel must have OpCode SnpResp and PCrdType = 'b0."});


 
  // =====
  // INDEX:        - CHI5PC_ERR_RSP_SNPDVM_RESP
  // =====
  property CHI5PC_ERR_RSP_SNPDVM_RESP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RSPFLITV_,RSPFLIT_}))
       && RSPFLITV_ && (RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESP) && (Current_RSP_Info.OpCode == `CHI5PC_SNPDVMOP) && RSP_match
      |-> &Current_RSP_Info.DVMPart;
  endproperty
  chi5pc_err_rsp_snpdvm_resp: assert property (CHI5PC_ERR_RSP_SNPDVM_RESP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_SNPDVM_RESP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "A response to a SnpDVMOp must not be issued until both parts of the request have been received."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_HAZARD_SNP
  // =====
  property CHI5PC_ERR_RSP_HAZARD_SNP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSP_Comp_Haz_FLITV,S_RSP_Addr_NS_haz_vector}))
        && S_RSP_Comp_Haz_FLITV && Chi5_in.NODE_TYPE == eChi5PCDevType'(RNF)
      |-> ~|S_RSP_Addr_NS_haz_vector;
  endproperty
  chi5pc_err_rsp_hazard_snp: assert property (CHI5PC_ERR_RSP_HAZARD_SNP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_HAZARD_SNP: Node type RNF must not receive a response to a request to an address for which it has an outstanding snoop until after sending the snoop response or all snoop data flits. (Does not include Evict or ReadOnce)."));


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_DAT_FOR_SNOOP1
  // =====
  property CHI5PC_ERR_RSP_DAT_FOR_SNOOP1; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RSPFLITV_matched,DATFLITV_matched,RSP_Info_Index,DAT_Info_Index}))
        && Chi5_in.NODE_TYPE == eChi5PCDevType'(RNF) &&
        RSPFLITV_matched && DATFLITV_matched 
      |-> (RSP_Info_Index != DAT_Info_Index);
  endproperty
  chi5pc_err_rsp_dat_for_snoop1: assert property (CHI5PC_ERR_RSP_DAT_FOR_SNOOP1) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_DAT_FOR_SNOOP1: Node type RNF must not send a response and snoop data for the same snoop request."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_DAT_FOR_SNOOP2
  // =====
  property CHI5PC_ERR_RSP_DAT_FOR_SNOOP2; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_RSP_Info,RSPFLITV_matched}))
        && RSPFLITV_matched 
      |-> ~|Current_RSP_Info.DATID[Chi5_in.this_nodeIndex];
  endproperty
  chi5pc_err_rsp_dat_for_snoop2: assert property (CHI5PC_ERR_RSP_DAT_FOR_SNOOP2) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_DAT_FOR_SNOOP2: Node type RNF must not send a response for a snoop for which it has already sent data."));


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_SNOOP_PD
  // =====
  property CHI5PC_ERR_RSP_SNOOP_PD; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_RSP_Info,RSPFLITV_matched}))
        && Chi5_in.NODE_TYPE == eChi5PCDevType'(RNF) &&
        RSPFLITV_matched  && (RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_NON_DATA_ERR) 
      |-> ~RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_MSB];
  endproperty
  chi5pc_err_rsp_snoop_pd: assert property (CHI5PC_ERR_RSP_SNOOP_PD) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_SNOOP_PD: Node type RNF must not assert PassDirty in a snoop response flit."));


//------------------------------------------------------------------------------
// INDEX:   7)  REQ Channel Checks
//------------------------------------------------------------------------------ 
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_SNPATTR
  // =====
  property CHI5PC_ERR_REQ_SNPATTR; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_}))
       && REQFLITV_
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_DVMOP)
       && ErrorOn_SW
      |-> ~|REQ_Attr_CLASH_vector;
  endproperty
  chi5pc_err_req_snpattr: assert property (CHI5PC_ERR_REQ_SNPATTR) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_SNPATTR::", string'(MODE == 1 ? " RXREQ: " : " TXREQ: "), "All nodes must maintain a consistent view of the attributes of any region of memory. A request has been issued with memory or snoop attributes that differ from an outstanding Snoop request to the same cacheline."});


//------------------------------------------------------------------------------
// INDEX:   8)  SACTIVE check
//------------------------------------------------------------------------------ 
//
   // ====
   // INDEX:        - CHI5PC_ERR_LNK_TXSACTIVE_SNP_TX
   // =====
   property CHI5PC_ERR_LNK_TXSACTIVE_SNP_TX;
     @(posedge `CHI5_SVA_CLK)
        `CHI5_SVA_RSTn && !($isunknown({Info_Alloc_vector,SNPFLITV_,SNPFLIT_}))
        && ((SNPFLITV_ && |SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE]) || |Info_Alloc_vector) && (MODE == 1)
       |->  SACTIVE_;
   endproperty
   chi5pc_err_lnk_txsactive_snp_tx: assert property (CHI5PC_ERR_LNK_TXSACTIVE_SNP_TX) else
     `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXSACTIVE_SNP_TX: TXSACTIVE must be asserted if the protocol layer is active or TXSNPFLITV is high."));

   // =====
   // INDEX:        - CHI5PC_ERR_LNK_TXSACTIVE_SNP_RX
   // =====
   property CHI5PC_ERR_LNK_TXSACTIVE_SNP_RX;
     @(posedge `CHI5_SVA_CLK)
        `CHI5_SVA_RSTn && !($isunknown({Info_Alloc_vector,Active_Data_vector,RSPFLITV_,DATFLITV_}))
        && ((RSPFLITV_ && |RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] && RSP_match) ||
            (DATFLITV_ && |DATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] && DAT_match) ||
            |Active_Data_vector)
             && (MODE == 0)
       |->  SACTIVE_;
   endproperty
   chi5pc_err_lnk_txsactive_snp_rx: assert property (CHI5PC_ERR_LNK_TXSACTIVE_SNP_RX) else
     `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXSACTIVE_SNP_RX: For received snoops, TXSACTIVE must be asserted no later than the first data or response flit."));


final
begin
  `ifndef CHI5PC_EOS_OFF
  $display ("Executing CHI End Of Simulation checks");
//------------------------------------------------------------------------------
// INDEX:   9)  Snoop EOS Checking
//------------------------------------------------------------------------------ 
  // =====
  // INDEX:        - CHI5PC_ERR_EOS_SNOOP 
  // =====
  //property CHI5PC_ERR_EOS_SNOOP;
  if (!($isunknown(Info_Alloc_vector)))
  chi5pc_err_eos_snoop:
    assert (~|Info_Alloc_vector) else 
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_SNOOP: Outstanding snoop transactions at end of simulation."));
  `endif
end

 //------------------------------------------------------------------------------
// INDEX:   10) Clear Verilog Defines
//------------------------------------------------------------------------------
// Clock and Reset
  `undef CHI5_AUX_CLK
  `undef CHI5_AUX_RSTn
  `undef CHI5_SVA_CLK
  `undef CHI5_SVA_RSTn

//------------------------------------------------------------------------------
// INDEX:   11) End of module
//------------------------------------------------------------------------------

endmodule // Chi5PC_SnoopTrace

//------------------------------------------------------------------------------
// INDEX:
// INDEX: End of File
//------------------------------------------------------------------------------
`endif















