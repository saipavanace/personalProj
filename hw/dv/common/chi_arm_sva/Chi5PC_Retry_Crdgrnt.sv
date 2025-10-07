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
//  File Revision       : 179045
//
//  Date                :  2014-08-20 14:24:28 +0100 (Wed, 20 Aug 2014)
//
//  Release Information : BP066-BU-01000-r0p0-00lac0
//
//------------------------------------------------------------------------------
//  Purpose             :Monitors RetryAck & PCrdGrant activity
//                          
//----------------------------------------------------------------------------
// CONTENTS
// ========
//  67.  Module: Chi5PC_Retry_Crdgrnt 
//  89.    1) Parameters
//  97.    2) Verilog Defines
// 100.         - Clock and Reset
// 127.    3)  Retry tracking
// 575.         - CHI5PC_ERR_RSP_PCRDGRANT_SPECULATIVE
// 613.    4) Clear Verilog Defines
// 622.    5) End of module
// 627.  Module: Cam_next
// 694.  Module: Cam_shift 
// 751.  Module: Cam_count 
// 787.  Module: Cam_compare 
// 825. 
// 826.  End of File
//----------------------------------------------------------------------------


`ifndef CHI5PC_OFF



//------------------------------------------------------------------------------
// CHI5 Standard Defines
//------------------------------------------------------------------------------



`ifndef CHI5PC_FLIT_DEFINES_SVH
  `include "Chi5PC_Chi5_flit_defines.svh"
`endif
`ifndef CHI5PC_CHI5_DEFINES_V
  `include "Chi5PC_Chi5_defines.v"
`endif
`include "Chi5PC_defines.v"



//------------------------------------------------------------------------------
// INDEX: Module: Chi5PC_Retry_Crdgrnt 
//------------------------------------------------------------------------------
module Chi5PC_Retry_Crdgrnt #(REQ_RSVDC_WIDTH = 4,
                   DAT_RSVDC_WIDTH = 4,
                   DAT_FLIT_WIDTH = `CHI5PC_128B_DAT_FLIT_WIDTH, 
                   MAX_OS_REQ = 8, 
                   numChi5nodes = 7,
                   MODE = 1
                 )
      (Chi5PC_if Chi5_in
     ,input wire SRESETn
     ,input wire SCLK
     ,input wire REQFLITV_
     ,input wire [`CHI5PC_REQ_FLIT_RANGE] REQFLIT_
     ,input wire RDDATFLITV_
     ,input wire [DAT_FLIT_WIDTH-1:0] RDDATFLIT_
     ,input wire S_RSPFLITV_
     ,input wire [`CHI5PC_RSP_FLIT_RANGE] S_RSPFLIT_
   );
  import Chi5PC_pkg::*;
  
//------------------------------------------------------------------------------
// INDEX:   1) Parameters
//------------------------------------------------------------------------------
  localparam MAX_OS_TX = MAX_OS_REQ;
  localparam LOG2MAX_OS_TX       = clogb2(MAX_OS_TX);
  localparam X2_MAX_OS_TX       =  MAX_OS_TX * 2;
  localparam LOG2_X2_MAX_OS_TX       = clogb2(X2_MAX_OS_TX);

//---------------------------------------------------------------------------
// INDEX:   2) Verilog Defines
//------------------------------------------------------------------------------

  // INDEX:        - Clock and Reset
  // =====
  // Can be overridden by user for a clock enable.
  
  `ifdef CHI5_SVA_CLK
  `else
     `define CHI5_SVA_CLK SCLK
  `endif
  
  `ifdef CHI5_SVA_RSTn
  `else
     `define CHI5_SVA_RSTn SRESETn
  `endif
  
  // AUX: Auxiliary Logic
  `ifdef CHI5_AUX_CLK
  `else
     `define CHI5_AUX_CLK SCLK
  `endif
  
  `ifdef CHI5_AUX_RSTn
  `else
     `define CHI5_AUX_RSTn SRESETn
  `endif
  

//----------------------------------------------------------------------------
// INDEX:   3)  Retry tracking
//------------------------------------------------------------------------------ 
  logic [6:0] req_tgt;
  logic [6:0] req_src;
  logic [6:0] rsp_tgt;
  logic [6:0] rsp_src;
  logic [6:0] rddat_tgt;
  logic [6:0] rddat_src;
  logic       pcrdgrant;
  logic       retryack;
  assign pcrdgrant = S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] ==  `CHI5PC_PCRDGRANT;
  assign retryack = S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] ==  `CHI5PC_RETRYACK;
  assign req_tgt = REQFLITV_ ? Chi5_in.get_nodeIndex(Chi5PC_SAM_pkg::SAM_remap(REQFLIT_)) : 'b0 ;
  assign req_src = REQFLITV_ ? Chi5_in.get_nodeIndex(REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE]) : 'b0 ;
  
  assign rddat_tgt = RDDATFLITV_ ? Chi5_in.get_nodeIndex(RDDATFLIT_[`CHI5PC_DAT_FLIT_TGTID_RANGE]) : 'b0;
  assign rddat_src = RDDATFLITV_ ? Chi5_in.get_nodeIndex(RDDATFLIT_[`CHI5PC_DAT_FLIT_SRCID_RANGE]) : 'b0;
  assign rsp_src = S_RSPFLITV_ ? Chi5_in.get_nodeIndex(S_RSPFLIT_[`CHI5PC_RSP_FLIT_SRCID_RANGE]) : 'b0;
  assign rsp_tgt = S_RSPFLITV_ ? Chi5_in.get_nodeIndex(S_RSPFLIT_[`CHI5PC_RSP_FLIT_TGTID_RANGE]) : 'b0;

  Chi5PC_Ret_Crdgnt_Info           Info [1:X2_MAX_OS_TX];
  Chi5PC_Ret_Crdgnt_Info           Info_next_pre_shift [1:X2_MAX_OS_TX];
  Chi5PC_Ret_Crdgnt_Info           Info_next_post_shift [1:X2_MAX_OS_TX];
  reg        [1:X2_MAX_OS_TX + 3]  Info_Pop_vector;
  reg        [1:X2_MAX_OS_TX]      Info_Alloc_vector;
  reg        [1:X2_MAX_OS_TX]      Info_Alloc_vector_next;
  reg        [1:X2_MAX_OS_TX]      Info_Alloc_vector_next_pre_shift;
  reg        [1:X2_MAX_OS_TX]      Info_Alloc_vector_next_post_shift;
  reg        [1:0]                 Info_Shift_vector[0:X2_MAX_OS_TX] ;
  reg        [1:X2_MAX_OS_TX]      S_RSP_Crd_match_vector;
  reg        [1:X2_MAX_OS_TX]      S_RSP_match_vector;
  reg        [1:X2_MAX_OS_TX]      RDDAT_match_vector;
  reg        [1:X2_MAX_OS_TX]     Crdgrnt_retry_ERR_vector_xy[1:numChi5nodes];
  reg        [1:numChi5nodes]      Crdgrnt_retry_ERR_vector_x;
  reg        [LOG2_X2_MAX_OS_TX:0] Info_Index_max;
  reg        [LOG2_X2_MAX_OS_TX:0] Info_Index_next;
  reg        [LOG2_X2_MAX_OS_TX:0] S_RSP_Info_Index;
  reg        [LOG2_X2_MAX_OS_TX:0] S_RSP_Crd_match_Info_Index;
  reg        [LOG2_X2_MAX_OS_TX:0] RDDAT_Info_Index;

  reg        [1:X2_MAX_OS_TX]                      req_without_retry[1:numChi5nodes]  ;
  reg        [LOG2_X2_MAX_OS_TX:0] num_reqs_without_retry[1:numChi5nodes][1:X2_MAX_OS_TX]  ;
  reg        [1:X2_MAX_OS_TX]      crd [1:numChi5nodes]  ;
  reg        [LOG2_X2_MAX_OS_TX:0] num_crds_src[1:numChi5nodes][1:X2_MAX_OS_TX]  ;

  reg                              REQ_PUSH;
  reg                              RDDAT_Pop;
  reg                              S_RSP_Pop;
  reg                              Retry_Pop;
  reg                              PcrdGrnt_Pop;
  reg                              PCRDGRNT_PUSH;

  Chi5PC_Ret_Crdgnt_Info           Info_tmp;

  assign Info_tmp.Ref_ID         =  MODE == 1 ? req_tgt : req_src;
  assign Info_tmp.TxnID          = REQFLIT_[`CHI5PC_REQ_FLIT_TXNID_RANGE];
  assign Info_tmp.Retried        = 1'b0;
  assign Info_tmp.OpCode         = eChi5PCReqOp'(REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE]);
  assign Info_tmp.PCrdType       = 'b0;
  assign Info_tmp.PCrdGrnt       = 'b0;

//match the rsp to an outstanding request with matching Txnid 
  generate
  genvar an;
    for (an = 1; an <= X2_MAX_OS_TX; an = an + 1)
    begin : S_RSP_match_gen
      assign S_RSP_match_vector[an] = Info_Alloc_vector[an] && Chi5_in.SRESETn  &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_TXNID_RANGE] == Info[an].TxnID) && 
            !Info[an].Retried &&
            (((MODE == 1) && (rsp_src ==  Info[an].Ref_ID)) || ((MODE == 0) && (rsp_tgt ==  Info[an].Ref_ID))) &&
             !Info[an].PCrdGrnt &&
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] !=  `CHI5PC_PCRDGRANT) &&
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] !=  `CHI5PC_RSPLINKFLIT) &&
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] !=  `CHI5PC_SNPRESP);
    end : S_RSP_match_gen
  endgenerate

  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      S_RSP_Info_Index = '0;
    end
    else
    begin
      S_RSP_Info_Index = '0;
      for (int i = 1; i <= X2_MAX_OS_TX; i = i + 1)
      begin
        if (S_RSP_match_vector[i])
        begin
            S_RSP_Info_Index = i;
        end
      end
    end
  end

//match the retry to an outstanding credit grant or vice versa 
  generate
    for (an = 1; an <= X2_MAX_OS_TX; an = an + 1)
    begin : S_RSP_Crd_match_gen
      assign S_RSP_Crd_match_vector[an] = 
        Info_Alloc_vector[an] && 
        (S_RSPFLIT_[`CHI5PC_RSP_FLIT_PCRDTYPE_RANGE] ==  Info[an].PCrdType) &&
        ((MODE == 1) && (rsp_src ==  Info[an].Ref_ID) || ((MODE == 0) && (rsp_tgt ==  Info[an].Ref_ID))) &&
        (((pcrdgrant) && Info[an].Retried && !Info[an].PCrdGrnt) ||
        ((retryack) && Info[an].PCrdGrnt && (S_RSP_Info_Index < an)));
    end
  endgenerate

  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      S_RSP_Crd_match_Info_Index = '0;
    end
    else
    begin
      S_RSP_Crd_match_Info_Index = '0;
      for (int i = X2_MAX_OS_TX; i >= 1; i = i - 1)
      begin
        if (S_RSP_Crd_match_vector[i])
        begin
            S_RSP_Crd_match_Info_Index = i;
        end
      end
    end
  end

  always_comb
  begin
    Info_Pop_vector = 'b0;
    Retry_Pop = 1'b0;
    PcrdGrnt_Pop = 1'b0;
    S_RSP_Pop = 1'b0;
    RDDAT_Pop = 1'b0;
    PCRDGRNT_PUSH = 1'b0;
    if (S_RSPFLITV_ )
    begin
      if (|S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] &&  
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_RETRYACK ) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_PCRDGRANT ))
      begin
        S_RSP_Pop = 1'b1;
        Info_Pop_vector[S_RSP_Info_Index] = 1'b1;
      end
    end
    if (S_RSPFLITV_ && |S_RSP_Crd_match_vector)
    begin
      if (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_RETRYACK )
      begin
        Retry_Pop = 1'b1;
        Info_Pop_vector[S_RSP_Info_Index] = 1'b1;
        Info_Pop_vector[S_RSP_Crd_match_Info_Index] = 1'b1;
      end
      if (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_PCRDGRANT) 
      begin
        PcrdGrnt_Pop = 1'b1;
        Info_Pop_vector[S_RSP_Crd_match_Info_Index] = 1'b1;
      end
    end
    if (S_RSPFLITV_ && ~|S_RSP_Crd_match_vector && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_PCRDGRANT))
    begin
      PCRDGRNT_PUSH = 1'b1;
    end
    if (RDDATFLITV_ && (RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_DATLINKFLIT) && |RDDAT_match_vector)
    begin
      Info_Pop_vector[RDDAT_Info_Index] = 1'b1;
      RDDAT_Pop = 1'b1;
    end
  end

  generate
  genvar ar;
    for (ar = 1; ar <= X2_MAX_OS_TX; ar = ar + 1)
    begin : RDDAT_match_gen
      assign RDDAT_match_vector[ar] = Info_Alloc_vector[ar] && Chi5_in.SRESETn  &&
          ((RDDATFLIT_[`CHI5PC_DAT_FLIT_TXNID_RANGE] == Info[ar].TxnID) 
            && !Info[ar].Retried
            && !Info[ar].PCrdGrnt
            && (((MODE == 1) && (rddat_src ==  Info[ar].Ref_ID)) || ((MODE == 0) && (rddat_tgt ==  Info[ar].Ref_ID))) 
               && (RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA));
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
      for (int i = 1; i <= X2_MAX_OS_TX; i = i + 1)
      begin
        if (RDDAT_match_vector[i])
            RDDAT_Info_Index = i;
      end
    end
  end


  //determine the next available location for the next request
  logic Info_Index_next_found;
  always@ (Info_Alloc_vector)
  begin
    if (!Chi5_in.SRESETn)
    begin
      Info_Index_max = 1;
      Info_Index_next = 1;
    end
    else
    begin
      Info_Index_max = 1;
      Info_Index_next = 1;
      for (int i = X2_MAX_OS_TX; i >= 1; i = i - 1)
      begin
        if (!Info_Alloc_vector[i] )
        begin
            Info_Index_next = i;
        end
      end
    end
  end


  assign Info_Shift_vector[0] = 2'b00;                                   
  generate
  genvar i;
    begin : Info_Shift_vector_gen
      for (i = 1; i <= X2_MAX_OS_TX; i = i + 1)
      begin
        always@(Info_Pop_vector)
        begin
          if (~|Info_Pop_vector)
          begin
            Info_Shift_vector[i] = 2'b00;
          end
          else
          begin
            if (!Info_Pop_vector[i + Info_Shift_vector[i-1] ])
            begin
              Info_Shift_vector[i] = Info_Shift_vector[i-1];
            end
            else
            if (!Info_Pop_vector[i + Info_Shift_vector[i-1] + 1])
            begin
              Info_Shift_vector[i]  = Info_Shift_vector[i-1] + 1;
            end
            else
            if (!Info_Pop_vector[i + Info_Shift_vector[i-1] + 2])
            begin
              Info_Shift_vector[i] = Info_Shift_vector[i-1] + 2;
            end
            else
            if (!Info_Pop_vector[i + Info_Shift_vector[i-1] + 3])
            begin
              Info_Shift_vector[i] = Info_Shift_vector[i-1] + 3;
            end
            else
            begin
              Info_Shift_vector[i] = 2'b00;
            end
          end
        end
      end
    end: Info_Shift_vector_gen
  endgenerate

  //tracking of number of outstanding requests without retry
  generate
  genvar ix;
  genvar iy;
    for (ix = 1; ix <= numChi5nodes; ix = ix + 1)
    begin: num_reqs_ix_gen
      for (iy = 1; iy <= X2_MAX_OS_TX; iy = iy + 1)
      begin : num_reqs_iy_gen
        assign req_without_retry[ix][iy] = Chi5_in.SRESETn && !Info_next_post_shift[iy].PCrdGrnt && (Info_next_post_shift[iy].Ref_ID == ix) && ~Info_next_post_shift[iy].Retried;
      end
    end
  endgenerate
  generate
    for (ix = 1; ix <= numChi5nodes; ix = ix + 1)
    begin: Cam_req_count_ix_gen
        Cam_counter #(.X2_MAX_OS_TX(X2_MAX_OS_TX),.LOG2_X2_MAX_OS_TX(LOG2_X2_MAX_OS_TX))
        u_Cam_counter(
          .Cam (req_without_retry[ix])
          ,.Cam_count (num_reqs_without_retry[ix])
          );
    end
  endgenerate
  generate
    for (ix = 1; ix <= numChi5nodes; ix = ix + 1)
    begin : crd_ix_gen
      for (iy = 1; iy <= X2_MAX_OS_TX; iy = iy + 1)
      begin : crd_ixy_gen
          assign crd[ix][iy] =  Chi5_in.SRESETn && Info_next_post_shift[iy].PCrdGrnt && (Info_next_post_shift[iy].Ref_ID == ix) ;
        end
      end
  endgenerate
  generate
    for (ix = 1; ix <= numChi5nodes; ix = ix + 1)
    begin: Cam_crd_count_ix_gen
        Cam_counter #(.X2_MAX_OS_TX(X2_MAX_OS_TX),.LOG2_X2_MAX_OS_TX(LOG2_X2_MAX_OS_TX))
        u_Cam_counter(
          .Cam (crd[ix])
          ,.Cam_count (num_crds_src[ix])
          );
    end
  endgenerate
  assign REQ_PUSH = REQFLITV_ && |REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] 
                    && REQFLIT_[`CHI5PC_REQ_FLIT_DYNPCRD_RANGE]
                    && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_PCRDRETURN);
  assign RETRY_UPDATE = S_RSPFLITV_ && |S_RSP_Info_Index && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_RETRYACK && !Retry_Pop;


  generate
   genvar g;
     for (g = 1; g <= X2_MAX_OS_TX; g = g + 1)
     begin : Cam_next_gen
       Cam_next #(.i(g), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH),  .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .LOG2_X2_MAX_OS_TX(LOG2_X2_MAX_OS_TX), .MODE(MODE) )
         u_Cam_next     (.Chi5_in (Chi5_in)
                        ,.REQFLITV_ (REQFLITV_)
                        ,.REQFLIT_ (REQFLIT_)
                        ,.RDDATFLITV_ (RDDATFLITV_)
                        ,.RDDATFLIT_ (RDDATFLIT_)
                        ,.S_RSPFLITV_ (S_RSPFLITV_)
                        ,.S_RSPFLIT_ (S_RSPFLIT_)
                        ,.REQ_PUSH (REQ_PUSH)
                        ,.PCRDGRNT_PUSH (PCRDGRNT_PUSH)
                        ,.RETRY_UPDATE (RETRY_UPDATE)
                        ,.PcrdGrnt_Pop (PcrdGrnt_Pop)
                        ,.Retry_Pop (Retry_Pop)
                        ,.S_RSP_match (S_RSP_match_vector[g])
                        ,.rsp_ID (MODE == 1 ? rsp_src : rsp_tgt)
                        ,.S_RSP_Info_Index (S_RSP_Info_Index)
                        ,.Info_Index_next (Info_Index_next)
                        ,.Info_tmp (Info_tmp)
                        ,.Info_in (Info[g])
                        ,.Info_Alloc_in (Info_Alloc_vector[g])
                        ,.Info_out (Info_next_pre_shift[g])
                        ,.Info_Alloc_out (Info_Alloc_vector_next_pre_shift[g]));

    end
  endgenerate
  //Perform the shift
  generate
   genvar k;
     for (k = 1; k <= X2_MAX_OS_TX; k = k + 1)
     begin : Cam_shift_gen
       if (k == X2_MAX_OS_TX)
       begin
         Cam_shift //#(.i(k))
          u_Cam_shift(.Chi5_in (Chi5_in)
          ,.Info_Shift_vector_k(Info_Shift_vector[k]) 
          ,.Info_next_pre_shift_0(Info_next_pre_shift[k])
          ,.Info_next_pre_shift_1(25'b0)
          ,.Info_next_pre_shift_2(25'b0)
          ,.Info_next_pre_shift_3(25'b0)
          ,.Info_Alloc_vector_next_pre_shift_0(Info_Alloc_vector_next_pre_shift[k])
          ,.Info_Alloc_vector_next_pre_shift_1('0)
          ,.Info_Alloc_vector_next_pre_shift_2('0)
          ,.Info_Alloc_vector_next_pre_shift_3('0)
          ,.Info_next_post_shift (Info_next_post_shift[k])
          ,.Info_Alloc_vector_next_post_shift (Info_Alloc_vector_next_post_shift[k]));
       end
       else
       if (k == X2_MAX_OS_TX-1)
       begin
         Cam_shift //#(.i(k))
          u_Cam_shift(.Chi5_in (Chi5_in)
          ,.Info_Shift_vector_k(Info_Shift_vector[k]) 
          ,.Info_next_pre_shift_0(Info_next_pre_shift[k])
          ,.Info_next_pre_shift_1(Info_next_pre_shift[k+1])
          ,.Info_next_pre_shift_2(25'b0)
          ,.Info_next_pre_shift_3(25'b0)
          ,.Info_Alloc_vector_next_pre_shift_0(Info_Alloc_vector_next_pre_shift[k])
          ,.Info_Alloc_vector_next_pre_shift_1(Info_Alloc_vector_next_pre_shift[k+1])
          ,.Info_Alloc_vector_next_pre_shift_2('0)
          ,.Info_Alloc_vector_next_pre_shift_3('0)
          ,.Info_next_post_shift (Info_next_post_shift[k])
          ,.Info_Alloc_vector_next_post_shift (Info_Alloc_vector_next_post_shift[k]));
       end
       else
       if (k == X2_MAX_OS_TX-2)
       begin
         Cam_shift// #(.i(k))
          u_Cam_shift(.Chi5_in (Chi5_in)
          ,.Info_Shift_vector_k(Info_Shift_vector[k]) 
          ,.Info_next_pre_shift_0(Info_next_pre_shift[k])
          ,.Info_next_pre_shift_1(Info_next_pre_shift[k+1])
          ,.Info_next_pre_shift_2(Info_next_pre_shift[k+2])
          ,.Info_next_pre_shift_3(25'b0)
          ,.Info_Alloc_vector_next_pre_shift_0(Info_Alloc_vector_next_pre_shift[k])
          ,.Info_Alloc_vector_next_pre_shift_1(Info_Alloc_vector_next_pre_shift[k+1])
          ,.Info_Alloc_vector_next_pre_shift_2(Info_Alloc_vector_next_pre_shift[k+2])
          ,.Info_Alloc_vector_next_pre_shift_3('0)
          ,.Info_next_post_shift (Info_next_post_shift[k])
          ,.Info_Alloc_vector_next_post_shift (Info_Alloc_vector_next_post_shift[k]));
       end
       else
       begin
         Cam_shift //#(.i(k))
          u_Cam_shift(.Chi5_in (Chi5_in)
          ,.Info_Shift_vector_k(Info_Shift_vector[k]) 
          ,.Info_next_pre_shift_0(Info_next_pre_shift[k])
          ,.Info_next_pre_shift_1(Info_next_pre_shift[k+1])
          ,.Info_next_pre_shift_2(Info_next_pre_shift[k+2])
          ,.Info_next_pre_shift_3(Info_next_pre_shift[k+3])
          ,.Info_Alloc_vector_next_pre_shift_0(Info_Alloc_vector_next_pre_shift[k])
          ,.Info_Alloc_vector_next_pre_shift_1(Info_Alloc_vector_next_pre_shift[k+1])
          ,.Info_Alloc_vector_next_pre_shift_2(Info_Alloc_vector_next_pre_shift[k+2])
          ,.Info_Alloc_vector_next_pre_shift_3(Info_Alloc_vector_next_pre_shift[k+3])
          ,.Info_next_post_shift (Info_next_post_shift[k])
          ,.Info_Alloc_vector_next_post_shift (Info_Alloc_vector_next_post_shift[k]));
       end

    end
  endgenerate
  generate
  genvar j;
    for (j = 1; j <= X2_MAX_OS_TX; j = j+1)
    begin : Info_gen
      always @(negedge Chi5_in.SRESETn or posedge SCLK)
      begin
        if(!Chi5_in.SRESETn)
        begin
          Info_Alloc_vector[j]  <= 'b0;
          Info[j] <= '0;
          Info[j].OpCode <= eChi5PCReqOp'(`CHI5PC_REQLINKFLIT);
          Info[j].Retried <= 1'b0;
          Info[j].TxnID <= 'b0;
          Info[j].Ref_ID <= 'b0;
          Info[j].PCrdGrnt <= 'b0;
          Info[j].PCrdType <= 'b0;
        end 
        else
        begin
          Info[j] <= Info_next_post_shift[j];
          Info_Alloc_vector[j] <= Info_Alloc_vector_next_post_shift[j];
        end
      end
    end
  endgenerate



  // =====
  // INDEX:        - CHI5PC_ERR_RSP_PCRDGRANT_SPECULATIVE
  // =====
  generate
  genvar gx;
  genvar gy;
    for (gx = 1; gx <= numChi5nodes; gx = gx + 1)
    begin : Cam_compare_gx_gen
      for (gy = 1; gy <= X2_MAX_OS_TX; gy = gy + 1)
      begin : Cam_compare_gxy_gen
        always_comb
        begin
          Crdgrnt_retry_ERR_vector_xy[gx][gy] = 1'b0;
          if (|crd[gx] && Info_Alloc_vector_next_post_shift[gy]) //enable to prevent comparison if there are no outstanding PCrdgrants
          begin
            if(num_reqs_without_retry[gx][gy] < num_crds_src[gx][gy])
            begin
              Crdgrnt_retry_ERR_vector_xy[gx][gy] = 1'b1;
            end
          end
        end
      end
    end
  endgenerate
  generate
    for (gx = 1; gx <= numChi5nodes; gx = gx + 1)
    begin : ERR_speculative_gen
      assign Crdgrnt_retry_ERR_vector_x[gx] = |Crdgrnt_retry_ERR_vector_xy[gx];
    end
  endgenerate
  property CHI5PC_ERR_RSP_PCRDGRANT_SPECULATIVE1; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && (RDDATFLITV_ || REQFLITV_ ||  S_RSPFLITV_)
         |-> ~|Crdgrnt_retry_ERR_vector_x;
  endproperty
  chi5pc_err_rsp_pcrdgrant_speculative1: assert property (CHI5PC_ERR_RSP_PCRDGRANT_SPECULATIVE1) else 
          `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_PCRDGRANT_SPECULATIVE1::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "A node must not issue PCrdGrant speculatively. The number of committed transactions (that have received a non-retry response or data) plus the number of retries indicated by RetryAck/PCrdGrant must not exceed the number of requests."});

//------------------------------------------------------------------------------
// INDEX:   4) Clear Verilog Defines
//------------------------------------------------------------------------------
// Clock and Reset
  `undef CHI5_AUX_CLK
  `undef CHI5_AUX_RSTn
  `undef CHI5_SVA_CLK
  `undef CHI5_SVA_RSTn

//------------------------------------------------------------------------------
// INDEX:   5) End of module
//------------------------------------------------------------------------------

endmodule // Chi5PC_Retry_Crdgrnt 
//------------------------------------------------------------------------------
// INDEX: Module: Cam_next
//------------------------------------------------------------------------------
//Selects the next value for the CAM
module Cam_next #(i = 16, REQ_RSVDC_WIDTH = 4, DAT_RSVDC_WIDTH = 4, DAT_FLIT_WIDTH  = `CHI5PC_128B_DAT_FLIT_WIDTH,  LOG2_X2_MAX_OS_TX = 5, MODE = 1)
  (Chi5PC_if Chi5_in
  ,input wire REQFLITV_
  ,input wire [`CHI5PC_REQ_FLIT_RANGE] REQFLIT_
  ,input wire RDDATFLITV_
  ,input wire [DAT_FLIT_WIDTH-1:0] RDDATFLIT_
  ,input wire S_RSPFLITV_
  ,input wire [`CHI5PC_RSP_FLIT_RANGE] S_RSPFLIT_
  ,input wire REQ_PUSH
  ,input wire PCRDGRNT_PUSH
  ,input wire RETRY_UPDATE
  ,input wire PcrdGrnt_Pop
  ,input wire Retry_Pop
  ,input wire S_RSP_match
  ,input wire [6:0] rsp_ID
  ,input [LOG2_X2_MAX_OS_TX:0] S_RSP_Info_Index
  ,input [LOG2_X2_MAX_OS_TX:0] Info_Index_next
  ,input Chi5PC_pkg::Chi5PC_Ret_Crdgnt_Info Info_tmp
  ,input Chi5PC_pkg::Chi5PC_Ret_Crdgnt_Info Info_in
  ,input wire Info_Alloc_in
  ,output Chi5PC_pkg::Chi5PC_Ret_Crdgnt_Info Info_out
  ,output reg Info_Alloc_out);

  import Chi5PC_pkg::*;
  Chi5PC_pkg::Chi5PC_Ret_Crdgnt_Info Info_out_o;
  assign Info_out = Info_out_o;

  always_comb
  begin
    if(!Chi5_in.SRESETn)
    begin
      Info_Alloc_out = 1'b0; 
      Info_out_o = '0; 
    end 
    else
    begin
      Info_Alloc_out = Info_Alloc_in;
      Info_out_o = Info_in;
      //do not push a LinkFlit
      if(REQ_PUSH && (i == (Info_Index_next + PCRDGRNT_PUSH)))
      begin
        Info_out_o = Info_tmp;
        Info_Alloc_out = 1'b1;
      end
      //capture responses
      if (S_RSPFLITV_ && |S_RSP_Info_Index && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_RETRYACK) && !Retry_Pop && (i == S_RSP_Info_Index ))
      begin
        Info_out_o.Retried = 1'b1;
        Info_out_o.PCrdType = S_RSPFLIT_[`CHI5PC_RSP_FLIT_PCRDTYPE_RANGE];
      end
      if (S_RSPFLITV_  && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_PCRDGRANT && !PcrdGrnt_Pop && (i == Info_Index_next))
      begin
        Info_out_o.OpCode = eChi5PCReqOp'(`CHI5PC_REQLINKFLIT);
        Info_out_o.PCrdGrnt = 1'b1;
        Info_out_o.PCrdType = S_RSPFLIT_[`CHI5PC_RSP_FLIT_PCRDTYPE_RANGE];
        Info_out_o.Ref_ID = rsp_ID;
        Info_out_o.TxnID = 'b0;
        Info_out_o.Retried = 'b0;
        Info_Alloc_out = 1'b1;
      end
    end
  end
endmodule
//------------------------------------------------------------------------------
// INDEX: Module: Cam_shift 
//------------------------------------------------------------------------------
//Shifts the Cam 
module Cam_shift //#(k = X2_MAX_OS_TX)
  (Chi5PC_if Chi5_in
  ,input wire [1:0]             Info_Shift_vector_k 
  ,input Chi5PC_pkg::Chi5PC_Ret_Crdgnt_Info Info_next_pre_shift_0
  ,input Chi5PC_pkg::Chi5PC_Ret_Crdgnt_Info Info_next_pre_shift_1
  ,input Chi5PC_pkg::Chi5PC_Ret_Crdgnt_Info Info_next_pre_shift_2
  ,input Chi5PC_pkg::Chi5PC_Ret_Crdgnt_Info Info_next_pre_shift_3
  ,input wire Info_Alloc_vector_next_pre_shift_0
  ,input wire Info_Alloc_vector_next_pre_shift_1
  ,input wire Info_Alloc_vector_next_pre_shift_2
  ,input wire Info_Alloc_vector_next_pre_shift_3
  ,output Chi5PC_pkg::Chi5PC_Ret_Crdgnt_Info Info_next_post_shift
  ,output reg Info_Alloc_vector_next_post_shift);

  import Chi5PC_pkg::*;
  Chi5PC_pkg::Chi5PC_Ret_Crdgnt_Info Info_out_o;
  Chi5PC_pkg::Chi5PC_Ret_Crdgnt_Info Info_next_post_shift_o;
  assign Info_next_post_shift = Info_next_post_shift_o;

  always_comb
  begin
    if(!Chi5_in.SRESETn)
    begin
      Info_Alloc_vector_next_post_shift = 1'b0; 
      Info_next_post_shift_o = '0; 
    end
    else
    begin
      case (Info_Shift_vector_k)
        2'b01 :
        begin
            Info_next_post_shift_o = Info_next_pre_shift_1;
            Info_Alloc_vector_next_post_shift = Info_Alloc_vector_next_pre_shift_1;
        end
        2'b10 :
        begin
            Info_next_post_shift_o = Info_next_pre_shift_2;
            Info_Alloc_vector_next_post_shift = Info_Alloc_vector_next_pre_shift_2;
        end
        2'b11 :
        begin
            Info_next_post_shift_o = Info_next_pre_shift_3;
            Info_Alloc_vector_next_post_shift = Info_Alloc_vector_next_pre_shift_3;
        end
        default :
        begin
          Info_next_post_shift_o = Info_next_pre_shift_0;
          Info_Alloc_vector_next_post_shift = Info_Alloc_vector_next_pre_shift_0;
        end
      endcase
    end
  end
endmodule
//------------------------------------------------------------------------------
// INDEX: Module: Cam_count 
//------------------------------------------------------------------------------
//counts the Cam contents
module Cam_counter #(X2_MAX_OS_TX = 16, LOG2_X2_MAX_OS_TX = 5)
  (
  input [1:X2_MAX_OS_TX]              Cam 
  ,output reg [LOG2_X2_MAX_OS_TX:0] Cam_count[1:X2_MAX_OS_TX]
  );


  always_comb
  begin
    if (~|Cam)
    begin
      for (int i = 1; i<=X2_MAX_OS_TX; i++ )
      begin
        Cam_count[i] = 'b0;
      end
    end
    else
    begin
      for (int i = 1; i<=X2_MAX_OS_TX; i++ )
      begin
        if (i == 1)
        begin
          Cam_count[i] = Cam[i];
        end
        else
        begin
          Cam_count[i] = Cam[i] + Cam_count[i-1];
        end
      end
    end
  end
endmodule
//------------------------------------------------------------------------------
// INDEX: Module: Cam_compare 
//------------------------------------------------------------------------------
  module Info_Shift
  (input wire SRESETn,
    input [1:4] Info_pop_element,
    input wire [1:0] Info_Shift_element_minus1,
    output reg [1:0] Info_Shift_element_out
  );
  always_comb
  begin
    if (!SRESETn)
    begin
      Info_Shift_element_out = 'b0;
    end 
    else
    if (!Info_pop_element[1+Info_Shift_element_minus1])
    begin
      Info_Shift_element_out = Info_Shift_element_minus1;
    end
    else
    if (!Info_pop_element[1+Info_Shift_element_minus1] + 1)
    begin
      Info_Shift_element_out = Info_Shift_element_minus1 + 1; 
    end
    else
    if (!Info_pop_element[1+Info_Shift_element_minus1] + 2)
    begin
      Info_Shift_element_out = Info_Shift_element_minus1 + 2; 
    end
    else
    if (!Info_pop_element[1+Info_Shift_element_minus1] + 3)
    begin
      Info_Shift_element_out = Info_Shift_element_minus1 + 3; 
    end
  end
endmodule

//------------------------------------------------------------------------------
// INDEX:
// INDEX: End of File
//------------------------------------------------------------------------------

`endif
