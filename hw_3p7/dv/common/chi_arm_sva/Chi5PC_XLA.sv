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
//  File Revision       : 177740
//
//  Date                :  2014-07-25 15:21:23 +0100 (Fri, 25 Jul 2014)
//
//  Release Information : BP066-BU-01000-r0p0-00lac0
//
//------------------------------------------------------------------------------
//  Purpose             :Tracks and checks LINK activation 
//                          
//----------------------------------------------------------------------------
// CONTENTS
// ========
//  112.  Module: Chi5PC_XLA
//  163.    1) Parameters
//  167.    2) Verilog Defines
//  170.         - Clock and Reset
//  196.    3)  Logic
//  508.    4)  Link state transaction checks
//  511.         - CHI5PC_ERR_LNK_SM_RX_RESET
//  523.         - CHI5PC_ERR_LNK_SM_TX_RESET
//  535.         - CHI5PC_ERR_LNK_SM_TXSTOP
//  547.         - CHI5PC_ERR_LNK_SM_RXSTOP
//  560.         - CHI5PC_ERR_LNK_SM_TXACT
//  572.         - CHI5PC_ERR_LNK_SM_RXACT
//  584.         - CHI5PC_ERR_LNK_SM_TXRUN
//  596.         - CHI5PC_ERR_LNK_SM_RXRUN
//  608.         - CHI5PC_ERR_LNK_SM_TXDEACT
//  619.         - CHI5PC_ERR_LNK_SM_RXDEACT
//  631.         - Banned output races
//  634.         - CHI5PC_ERR_LNK_RXRUN_PLUS
//  647.         - CHI5PC_ERR_LNK_RXSTOP_PLUS
//  660.         - CHI5PC_ERR_LNK_TXDEACT_PLUS
//  673.         - CHI5PC_ERR_LNK_TXACT_PLUS
//  685.         - Asynch input races
//  688.         - CHI5PC_ERR_LNK_TXRUN_PLUS
//  701.         - CHI5PC_ERR_LNK_TXSTOP_PLUS
//  714.         - CHI5PC_ERR_LNK_RXDEACT_PLUS
//  727.         - CHI5PC_ERR_LNK_RXACT_PLUS
//  739.         - Exit from Race state
//  742.         - CHI5PC_ERR_LNK_RXDEACT_RACE_EXIT
//  754.         - CHI5PC_ERR_LNK_RXSTOP_RACE_EXIT
//  766.         - CHI5PC_ERR_LNK_RXACT_RACE_EXIT
//  778.         - CHI5PC_ERR_LNK_RXRUN_RACE_EXIT
//  789.         - CHI5PC_ERR_LNK_TXDEACT_RACE_EXIT
//  801.         - CHI5PC_ERR_LNK_TXSTOP_RACE_EXIT
//  813.         - CHI5PC_ERR_LNK_TXACT_RACE_EXIT
//  825.         - CHI5PC_ERR_LNK_TXRUN_RACE_EXIT
//  837.    5)  State to Flit and credit issue checks 
//  840.         - CHI5PC_ERR_LNK_STOP_TXREQLCRDV
//  852.         - CHI5PC_ERR_LNK_STOP_RXREQLCRDV
//  864.         - CHI5PC_ERR_LNK_STOP_TXRSPLCRDV
//  876.         - CHI5PC_ERR_LNK_STOP_RXRSPLCRDV
//  888.         - CHI5PC_ERR_LNK_STOP_TXSNPLCRDV
//  900.         - CHI5PC_ERR_LNK_STOP_RXSNPLCRDV
//  912.         - CHI5PC_ERR_LNK_STOP_TXDATLCRDV
//  924.         - CHI5PC_ERR_LNK_STOP_RXDATLCRDV
//  936.         - CHI5PC_ERR_LNK_ACT_RXREQLCRDV
//  948.         - CHI5PC_ERR_LNK_ACT_RXRSPLCRDV
//  960.         - CHI5PC_ERR_LNK_ACT_RXSNPLCRDV
//  972.         - CHI5PC_ERR_LNK_ACT_RXDATLCRDV
//  984.         - CHI5PC_ERR_LNK_STOP_TXREQFLITV
//  996.         - CHI5PC_ERR_LNK_STOP_RXREQFLITV
// 1009.         - CHI5PC_ERR_LNK_STOP_TXRSPFLITV
// 1021.         - CHI5PC_ERR_LNK_STOP_RXRSPFLITV
// 1033.         - CHI5PC_ERR_LNK_STOP_TXSNPFLITV
// 1045.         - CHI5PC_ERR_LNK_STOP_RXSNPFLITV
// 1057.         - CHI5PC_ERR_LNK_STOP_TXDATFLITV
// 1069.         - CHI5PC_ERR_LNK_STOP_RXDATFLITV
// 1081.         - CHI5PC_ERR_LNK_ACT_TXREQFLITV
// 1093.         - CHI5PC_ERR_LNK_ACT_RXREQFLITV
// 1105.         - CHI5PC_ERR_LNK_ACT_TXRSPFLITV
// 1117.         - CHI5PC_ERR_LNK_ACT_RXRSPFLITV
// 1129.         - CHI5PC_ERR_LNK_ACT_TXSNPFLITV
// 1141.         - CHI5PC_ERR_LNK_ACT_RXSNPFLITV
// 1153.         - CHI5PC_ERR_LNK_ACT_TXDATFLITV
// 1165.         - CHI5PC_ERR_LNK_ACT_RXDATFLITV
// 1177.         - CHI5PC_ERR_LNK_DEACT_REQLCRDV
// 1190.         - CHI5PC_ERR_LNK_DEACT_RXRSPLCRDV
// 1203.         - CHI5PC_ERR_LNK_DEACT_RXSNPLCRDV
// 1216.         - CHI5PC_ERR_LNK_DEACT_RXDATLCRDV
// 1231.    6)  End of simulation checks
// 1239.         - CHI5PC_ERR_EOS_LNK_TX
// 1248.         - CHI5PC_ERR_EOS_LNK_RX
// 1259.    7) Clear Verilog Defines
// 1268.    8) End of module
//----------------------------------------------------------------------------
`ifndef CHI5PC_OFF

`ifndef CHI5PC_TYPES
  `include "Chi5PC_Chi5_defines.v"
`endif
`include "Chi5PC_defines.v"


//------------------------------------------------------------------------------
// INDEX: Module: Chi5PC_XLA
//------------------------------------------------------------------------------
module Chi5PC_XLA #(REQ_RSVDC_WIDTH = 4,
                DAT_RSVDC_WIDTH = 4,
                DAT_FLIT_WIDTH = `CHI5PC_128B_DAT_FLIT_WIDTH,
                PCMODE = Chi5PC_pkg::LOCAL,
                MAXLLCREDITS_IN_RXDEACTIVATE = 16)
      (Chi5PC_if Chi5_in
     ,input wire SRESETn
     ,input wire SCLK
     ,input wire TXLINKACTIVEREQ_
     ,input wire TXLINKACTIVEACK_
     ,input wire TXREQFLITV_
     ,input wire [`CHI5PC_REQ_FLIT_RANGE] TXREQFLIT_
     ,input wire TXREQLCRDV_
     ,input wire TXRSPFLITV_
     ,input wire [`CHI5PC_RSP_FLIT_RANGE] TXRSPFLIT_
     ,input wire TXRSPLCRDV_
     ,input wire TXDATFLITV_
     ,input wire [DAT_FLIT_WIDTH-1:0] TXDATFLIT_
     ,input wire TXDATLCRDV_
     ,input wire TXSNPFLITV_
     ,input wire [`CHI5PC_SNP_FLIT_RANGE] TXSNPFLIT_
     ,input wire TXSNPLCRDV_
     ,input wire TXREQFLITPEND_
     ,input wire TXRSPFLITPEND_
     ,input wire TXDATFLITPEND_
     ,input wire TXSNPFLITPEND_
     ,input wire TXSACTIVE_
     ,input wire RXLINKACTIVEREQ_
     ,input wire RXLINKACTIVEACK_
     ,input wire RXREQFLITV_
     ,input wire [`CHI5PC_REQ_FLIT_RANGE] RXREQFLIT_
     ,input wire RXREQLCRDV_
     ,input wire RXRSPFLITV_
     ,input wire [`CHI5PC_RSP_FLIT_RANGE] RXRSPFLIT_
     ,input wire RXRSPLCRDV_
     ,input wire RXDATFLITV_
     ,input wire [DAT_FLIT_WIDTH-1:0] RXDATFLIT_
     ,input wire RXDATLCRDV_
     ,input wire RXSNPFLITV_
     ,input wire [`CHI5PC_SNP_FLIT_RANGE] RXSNPFLIT_
     ,input wire RXSNPLCRDV_
     ,input wire RXREQFLITPEND_
     ,input wire RXRSPFLITPEND_
     ,input wire RXDATFLITPEND_
     ,input wire RXSNPFLITPEND_
     ,input wire RXSACTIVE_
     
     );
  import Chi5PC_pkg::*;
//------------------------------------------------------------------------------
// INDEX:   1) Parameters
//------------------------------------------------------------------------------
//
// ---------------------------------------------------------
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
// INDEX:   3)  Logic
//------------------------------------------------------------------------------ 
  typedef enum bit [2:0] { 
    XLA_STOP = 3'b000, 
    XLA_STOP_PLUS = 3'b100, 
    XLA_DEACTIVATE = 3'b001, 
    XLA_DEACTIVATE_PLUS = 3'b101, 
    XLA_ACTIVATE = 3'b010, 
    XLA_ACTIVATE_PLUS = 3'b110, 
    XLA_RUN = 3'b011, 
    XLA_RUN_PLUS = 3'b111 
    } XLA_State;

    typedef struct packed {
      XLA_State TXSTATE;
      XLA_State RXSTATE;
      }TX_RX;


  TX_RX Current_State;
  TX_RX Next_State;
  reg first_cycle;
  reg[5:0] TXREQLCRDV_since_deactivate_cnt;
  reg[5:0] TXRSPLCRDV_since_deactivate_cnt;
  reg[5:0] TXDATLCRDV_since_deactivate_cnt;
  reg[5:0] TXSNPLCRDV_since_deactivate_cnt;
  reg[5:0] RXREQLCRDV_since_deactivate_cnt;
  reg[5:0] RXRSPLCRDV_since_deactivate_cnt;
  reg[5:0] RXDATLCRDV_since_deactivate_cnt;
  reg[5:0] RXSNPLCRDV_since_deactivate_cnt;
  always_comb
  begin
    if(!Chi5_in.SRESETn)
    begin
      Next_State = {XLA_STOP,XLA_STOP};
    end
    else
    begin
      Next_State = Current_State;
      case (Current_State)
        {XLA_STOP,XLA_STOP}:
        begin
          if (TXLINKACTIVEREQ_)
          begin
            Next_State.TXSTATE = XLA_ACTIVATE;
          end
          if (RXLINKACTIVEREQ_)
          begin
            Next_State.RXSTATE = XLA_ACTIVATE;
          end
        end
        {XLA_STOP,XLA_ACTIVATE}:
        begin
          case ({TXLINKACTIVEREQ_,RXLINKACTIVEACK_})
            2'b01:
              Next_State = {XLA_STOP,XLA_RUN_PLUS};
            2'b10:
              Next_State = {XLA_ACTIVATE,XLA_ACTIVATE};
            2'b11:
              Next_State = {XLA_ACTIVATE,XLA_RUN};
          endcase
        end
        {XLA_STOP,XLA_RUN_PLUS}:
        begin
          if (TXLINKACTIVEREQ_)
          begin
            Next_State = {XLA_ACTIVATE,XLA_RUN};
          end
        end
        {XLA_ACTIVATE,XLA_STOP}:
        begin
          case ({TXLINKACTIVEACK_,RXLINKACTIVEREQ_})
            2'b10:
              Next_State = {XLA_RUN_PLUS,XLA_STOP};
            2'b01:
              Next_State = {XLA_ACTIVATE,XLA_ACTIVATE};
            2'b11:
              Next_State = {XLA_RUN,XLA_ACTIVATE};
          endcase
        end
        {XLA_ACTIVATE,XLA_ACTIVATE}:
        begin
          if (TXLINKACTIVEACK_)
          begin
            Next_State.TXSTATE = XLA_RUN;
          end
          if (RXLINKACTIVEACK_)
          begin
            Next_State.RXSTATE = XLA_RUN;
          end
        end
        {XLA_ACTIVATE,XLA_RUN}:
        begin
          case ({TXLINKACTIVEACK_,RXLINKACTIVEREQ_})
            2'b00:
              Next_State = {XLA_ACTIVATE,XLA_DEACTIVATE_PLUS};
            2'b10:
              Next_State = {XLA_RUN,XLA_DEACTIVATE};
            2'b11:
              Next_State = {XLA_RUN,XLA_RUN};
          endcase
        end
        {XLA_ACTIVATE,XLA_DEACTIVATE_PLUS}:
        begin
          if (TXLINKACTIVEACK_)
          begin
            Next_State = {XLA_RUN,XLA_DEACTIVATE};
          end
        end
        {XLA_RUN_PLUS,XLA_STOP}:
        begin
          if (RXLINKACTIVEREQ_)
          begin
            Next_State = {XLA_RUN,XLA_ACTIVATE};
          end
        end
        {XLA_RUN,XLA_ACTIVATE}:
        begin
          case ({TXLINKACTIVEREQ_,RXLINKACTIVEACK_})
            2'b00:
              Next_State = {XLA_DEACTIVATE_PLUS,XLA_ACTIVATE};
            2'b01:
              Next_State = {XLA_DEACTIVATE,XLA_RUN};
            2'b11:
              Next_State = {XLA_RUN,XLA_RUN};
          endcase
        end
        {XLA_RUN,XLA_RUN}:
        begin
          if (!TXLINKACTIVEREQ_)
          begin
            Next_State.TXSTATE = XLA_DEACTIVATE;
          end
          if (!RXLINKACTIVEREQ_)
          begin
            Next_State.RXSTATE = XLA_DEACTIVATE;
          end
        end
        {XLA_RUN,XLA_DEACTIVATE}:
        begin
          case ({TXLINKACTIVEREQ_,RXLINKACTIVEACK_})
            2'b00:
              Next_State = {XLA_DEACTIVATE,XLA_STOP};
            2'b10:
              Next_State = {XLA_RUN,XLA_STOP_PLUS};
            2'b01:
              Next_State = {XLA_DEACTIVATE,XLA_DEACTIVATE};
          endcase
        end
        {XLA_RUN,XLA_STOP_PLUS}:
        begin
          if (!TXLINKACTIVEREQ_)
          begin
            Next_State = {XLA_DEACTIVATE,XLA_STOP};
          end
        end
        {XLA_DEACTIVATE_PLUS,XLA_ACTIVATE}:
        begin
          if (RXLINKACTIVEACK_)
          begin
            Next_State = {XLA_DEACTIVATE,XLA_RUN};
          end
        end

        {XLA_DEACTIVATE,XLA_RUN}:
        begin
          case ({TXLINKACTIVEACK_,RXLINKACTIVEREQ_})
            2'b00:
              Next_State = {XLA_STOP,XLA_DEACTIVATE};
            2'b01:
              Next_State = {XLA_STOP_PLUS,XLA_RUN};
            2'b10:
              Next_State = {XLA_DEACTIVATE,XLA_DEACTIVATE};
          endcase
        end
        {XLA_DEACTIVATE,XLA_DEACTIVATE}:
        begin
          if (!TXLINKACTIVEACK_)
          begin
            Next_State.TXSTATE = XLA_STOP;
          end
          if (!RXLINKACTIVEACK_)
          begin
            Next_State.RXSTATE = XLA_STOP;
          end
        end
        {XLA_DEACTIVATE,XLA_STOP}:
        begin
          case ({TXLINKACTIVEACK_,RXLINKACTIVEREQ_})
            2'b00:
              Next_State = {XLA_STOP,XLA_STOP};
            2'b01:
              Next_State = {XLA_STOP,XLA_ACTIVATE};
            2'b11:
              Next_State = {XLA_DEACTIVATE,XLA_ACTIVATE_PLUS};
          endcase
        end
        {XLA_DEACTIVATE,XLA_ACTIVATE_PLUS}:
        begin
          if (!TXLINKACTIVEACK_)
          begin
            Next_State = {XLA_STOP,XLA_ACTIVATE};
          end
        end
        {XLA_STOP_PLUS,XLA_RUN}:
        begin
          if (!RXLINKACTIVEREQ_)
          begin
            Next_State = {XLA_STOP,XLA_DEACTIVATE};
          end
        end
        {XLA_STOP,XLA_DEACTIVATE}:
        begin
          case ({TXLINKACTIVEREQ_,RXLINKACTIVEACK_})
            2'b00:
              Next_State = {XLA_STOP,XLA_STOP};
            2'b10:
              Next_State = {XLA_ACTIVATE,XLA_STOP};
            2'b11:
              Next_State = {XLA_ACTIVATE_PLUS,XLA_DEACTIVATE};
          endcase
        end
        {XLA_ACTIVATE_PLUS,XLA_DEACTIVATE}:
        begin
          if (!RXLINKACTIVEACK_)
          begin
            Next_State = {XLA_ACTIVATE,XLA_STOP};
          end
        end
      endcase
    end
  end
  always @(negedge Chi5_in.SRESETn or posedge SCLK)
  begin
    if(!Chi5_in.SRESETn)
    begin
      Current_State <= {XLA_STOP,XLA_STOP};
    end
    else
    begin
      Current_State <= Next_State;
    end
  end
  always @(negedge Chi5_in.SRESETn or posedge SCLK)
  begin
    if(!Chi5_in.SRESETn)
    begin
      first_cycle <= 1'b1;
    end
    else
    begin
      first_cycle <= 1'b0;
    end
  end
  always @(negedge Chi5_in.SRESETn or posedge SCLK)
  begin
    if(!Chi5_in.SRESETn)
    begin
      TXREQLCRDV_since_deactivate_cnt <= 'b0;
      TXRSPLCRDV_since_deactivate_cnt <= 'b0;
      TXDATLCRDV_since_deactivate_cnt <= 'b0;
      TXSNPLCRDV_since_deactivate_cnt <= 'b0;
    end
    else if (Current_State.TXSTATE != XLA_DEACTIVATE)
    begin
      TXREQLCRDV_since_deactivate_cnt <= 'b0;
      TXRSPLCRDV_since_deactivate_cnt <= 'b0;
      TXDATLCRDV_since_deactivate_cnt <= 'b0;
      TXSNPLCRDV_since_deactivate_cnt <= 'b0;
    end
    else
    begin
      if (TXREQLCRDV_)
        TXREQLCRDV_since_deactivate_cnt <= TXREQLCRDV_since_deactivate_cnt + 1;
      if (TXRSPLCRDV_)
        TXRSPLCRDV_since_deactivate_cnt <= TXRSPLCRDV_since_deactivate_cnt + 1;
      if (TXDATLCRDV_)
        TXDATLCRDV_since_deactivate_cnt <= TXDATLCRDV_since_deactivate_cnt + 1;
      if (TXSNPLCRDV_)
        TXSNPLCRDV_since_deactivate_cnt <= TXSNPLCRDV_since_deactivate_cnt + 1;
    end
  end
  always @(negedge Chi5_in.SRESETn or posedge SCLK)
  begin
    if(!Chi5_in.SRESETn)
    begin
      RXREQLCRDV_since_deactivate_cnt <= 'b0;
      RXRSPLCRDV_since_deactivate_cnt <= 'b0;
      RXDATLCRDV_since_deactivate_cnt <= 'b0;
      RXSNPLCRDV_since_deactivate_cnt <= 'b0;
    end
    else if (Current_State.RXSTATE != XLA_DEACTIVATE)
    begin
      RXREQLCRDV_since_deactivate_cnt <= 'b0;
      RXRSPLCRDV_since_deactivate_cnt <= 'b0;
      RXDATLCRDV_since_deactivate_cnt <= 'b0;
      RXSNPLCRDV_since_deactivate_cnt <= 'b0;
    end
    else
    begin
      if (RXREQLCRDV_)
        RXREQLCRDV_since_deactivate_cnt <= RXREQLCRDV_since_deactivate_cnt + 1;
      if (RXRSPLCRDV_)
        RXRSPLCRDV_since_deactivate_cnt <= RXRSPLCRDV_since_deactivate_cnt + 1;
      if (RXDATLCRDV_)
        RXDATLCRDV_since_deactivate_cnt <= RXDATLCRDV_since_deactivate_cnt + 1;
      if (RXSNPLCRDV_)
        RXSNPLCRDV_since_deactivate_cnt <= RXSNPLCRDV_since_deactivate_cnt + 1;
    end
  end

//------------------------------------------------------------------------------
// INDEX:   4)  Link state transaction checks
//------------------------------------------------------------------------------ 
  // =====
  // INDEX:        - CHI5PC_ERR_LNK_SM_TXSTOP
  // =====
  property CHI5PC_ERR_LNK_SM_TXSTOP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,TXLINKACTIVEACK_}))
       && ((Current_State.TXSTATE == XLA_STOP) || (Current_State.TXSTATE == XLA_STOP_PLUS))
      |->  !TXLINKACTIVEACK_;
  endproperty
  chi5pc_err_lnk_sm_txstop: assert property (CHI5PC_ERR_LNK_SM_TXSTOP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_SM_TXSTOP: TXLINKACTIVEACK must not be asserted when the transmit link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_SM_RXSTOP
  // =====
  property CHI5PC_ERR_LNK_SM_RXSTOP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,RXLINKACTIVEACK_}))
       && ((Current_State.RXSTATE == XLA_STOP) || (Current_State.RXSTATE == XLA_STOP_PLUS)) 
      |->  !RXLINKACTIVEACK_;
  endproperty
  chi5pc_err_lnk_sm_rxstop: assert property (CHI5PC_ERR_LNK_SM_RXSTOP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_SM_RXSTOP: RXLINKACTIVEACK must not be asserted when the receive link is in the XLA_STOP state."));


  // =====
  // INDEX:        - CHI5PC_ERR_LNK_SM_TXACT
  // =====
  property CHI5PC_ERR_LNK_SM_TXACT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,TXLINKACTIVEREQ_}))
       && ((Current_State.TXSTATE == XLA_ACTIVATE) || (Current_State.TXSTATE == XLA_ACTIVATE_PLUS))
      |->  TXLINKACTIVEREQ_ ;
  endproperty
  chi5pc_err_lnk_sm_txact: assert property (CHI5PC_ERR_LNK_SM_TXACT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_SM_TXACT: TXLINKACTIVEREQ must not be deasserted when the transmit link is in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_SM_RXACT
  // =====
  property CHI5PC_ERR_LNK_SM_RXACT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,RXLINKACTIVEREQ_}))
       && ((Current_State.RXSTATE == XLA_ACTIVATE) || (Current_State.RXSTATE == XLA_ACTIVATE_PLUS))
      |->  RXLINKACTIVEREQ_ ;
  endproperty
  chi5pc_err_lnk_sm_rxact: assert property (CHI5PC_ERR_LNK_SM_RXACT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_SM_RXACT: RXLINKACTIVEREQ must not be deasserted when the receive link is in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_SM_TXRUN
  // =====
  property CHI5PC_ERR_LNK_SM_TXRUN; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,TXLINKACTIVEACK_}))
       && ((Current_State.TXSTATE == XLA_RUN) || (Current_State.TXSTATE == XLA_RUN_PLUS))
      |->  TXLINKACTIVEACK_ ;
  endproperty
  chi5pc_err_lnk_sm_txrun: assert property (CHI5PC_ERR_LNK_SM_TXRUN) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_SM_TXRUN: TXLINKACTIVEACK must not be deasserted when the transmit link is in the XLA_RUN state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_SM_RXRUN
  // =====
  property CHI5PC_ERR_LNK_SM_RXRUN; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,RXLINKACTIVEACK_}))
       && ((Current_State.RXSTATE == XLA_RUN) || (Current_State.RXSTATE == XLA_RUN_PLUS))
      |->  RXLINKACTIVEACK_ ;
  endproperty
  chi5pc_err_lnk_sm_rxrun: assert property (CHI5PC_ERR_LNK_SM_RXRUN) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_SM_RXRUN: RXLINKACTIVEACK must not be deasserted when the receive link is in the XLA_RUN state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_SM_TXDEACT
  // =====
  property CHI5PC_ERR_LNK_SM_TXDEACT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,TXLINKACTIVEREQ_}))
       && ((Current_State.TXSTATE == XLA_DEACTIVATE) || (Current_State.TXSTATE == XLA_DEACTIVATE_PLUS))
      |->  !TXLINKACTIVEREQ_;
  endproperty
  chi5pc_err_lnk_sm_txdeact: assert property (CHI5PC_ERR_LNK_SM_TXDEACT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_SM_TXDEACT: TXLINKACTIVEREQ must not be asserted when the transmit link is in the XLA_DEACTIVATE state."));
  // =====
  // INDEX:        - CHI5PC_ERR_LNK_SM_RXDEACT
  // =====
  property CHI5PC_ERR_LNK_SM_RXDEACT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,RXLINKACTIVEREQ_}))
       && ((Current_State.RXSTATE == XLA_DEACTIVATE) || (Current_State.RXSTATE == XLA_DEACTIVATE_PLUS))
      |->  !RXLINKACTIVEREQ_;
  endproperty
  chi5pc_err_lnk_sm_rxdeact: assert property (CHI5PC_ERR_LNK_SM_RXDEACT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_SM_RXDEACT: RXLINKACTIVEREQ must not be asserted when the receive link is in the XLA_DEACTIVATE state."));

  //=========================================================================
  // INDEX:        - Banned output races
  //=========================================================================
  // =====
  // INDEX:        - CHI5PC_ERR_LNK_RXRUN_PLUS
  // =====
  // Banned output race to TXSTOP/RXRUN_PLUS+
  property CHI5PC_ERR_LNK_RXRUN_PLUS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_STOP,XLA_ACTIVATE})  && !TXLINKACTIVEREQ_ && ((PCMODE == LOCAL) || (PCMODE == NORACE))
      |->  !RXLINKACTIVEACK_ ;
  endproperty
  chi5pc_err_lnk_rxrun_plus: assert property (CHI5PC_ERR_LNK_RXRUN_PLUS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_RXRUN_PLUS: RXLINKACTIVEACK must not be asserted if its local transmit link remains in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_RXSTOP_PLUS
  // =====
  // Banned output race to RXSTOP/RxStop+
  property CHI5PC_ERR_LNK_RXSTOP_PLUS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_RUN,XLA_DEACTIVATE})  && TXLINKACTIVEREQ_ && ((PCMODE == LOCAL) || (PCMODE == NORACE))
      |->  RXLINKACTIVEACK_ ;
  endproperty
  chi5pc_err_lnk_rxstop_plus: assert property (CHI5PC_ERR_LNK_RXSTOP_PLUS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_RXSTOP_PLUS: RXLINKACTIVEACK must not be deasserted if its local transmit link remains in the XLA_RUN state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXDEACT_PLUS
  // =====
  // Banned output race to TxDeact+/RxAct
  property CHI5PC_ERR_LNK_TXDEACT_PLUS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_RUN,XLA_ACTIVATE})  && !RXLINKACTIVEACK_ && ((PCMODE == LOCAL) || (PCMODE == NORACE))
      |->  TXLINKACTIVEREQ_ ;
  endproperty
  chi5pc_err_lnk_txdeact_plus: assert property (CHI5PC_ERR_LNK_TXDEACT_PLUS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXDEACT_PLUS: TXLINKACTIVEREQ must not be deasserted if its local receive link remains in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXACT_PLUS
  // =====
  // Banned output race to TXACT+/RxDeact
  property CHI5PC_ERR_LNK_TXACT_PLUS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_STOP,XLA_DEACTIVATE})  && RXLINKACTIVEACK_ && ((PCMODE == LOCAL) || (PCMODE == NORACE))
      |->  !TXLINKACTIVEREQ_ ;
  endproperty
  chi5pc_err_lnk_txact_plus: assert property (CHI5PC_ERR_LNK_TXACT_PLUS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXACT_PLUS:  TXLINKACTIVEREQ must not be asserted if its local receive link remains in the XLA_DEACTIVATE state."));
  //=========================================================================
  // INDEX:        - Asynch input races
  //=========================================================================
  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXRUN_PLUS
  // =====
  // Asynch input race to RXSTOP/TXRUN_PLUS+
  property CHI5PC_ERR_LNK_TXRUN_PLUS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_ACTIVATE,XLA_STOP})  && !RXLINKACTIVEREQ_ && ((PCMODE == MIRROR) || (PCMODE == NORACE))
      |->  !TXLINKACTIVEACK_ ;
  endproperty
  chi5pc_err_lnk_txrun_plus: assert property (CHI5PC_ERR_LNK_TXRUN_PLUS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXRUN_PLUS: TXLINKACTIVEACK must not be asserted if its local receive link remains in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXSTOP_PLUS
  // =====
  // Asynch input race to TXSTOP/TXSTOP+
  property CHI5PC_ERR_LNK_TXSTOP_PLUS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_DEACTIVATE,XLA_RUN})  && RXLINKACTIVEREQ_ && ((PCMODE == MIRROR) || (PCMODE == NORACE))
      |->  TXLINKACTIVEACK_ ;
  endproperty
  chi5pc_err_lnk_txstop_plus: assert property (CHI5PC_ERR_LNK_TXSTOP_PLUS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXSTOP_PLUS: TXLINKACTIVEACK must not be deasserted if its local receive link remains in the XLA_RUN state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_RXDEACT_PLUS
  // =====
  // Asynch input race to RXDeact+/TXACT
  property CHI5PC_ERR_LNK_RXDEACT_PLUS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_ACTIVATE,XLA_RUN})  && !TXLINKACTIVEACK_ && ((PCMODE == MIRROR) || (PCMODE == NORACE))
      |->  RXLINKACTIVEREQ_ ;
  endproperty
  chi5pc_err_lnk_rxdeact_plus: assert property (CHI5PC_ERR_LNK_RXDEACT_PLUS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_RXDEACT_PLUS: RXLINKACTIVEREQ must not be deasserted if its local transmit link remains in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_RXACT_PLUS
  // =====
  // Asynch input race to RXACT+/TXDEACT
  property CHI5PC_ERR_LNK_RXACT_PLUS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_DEACTIVATE,XLA_STOP})  && TXLINKACTIVEACK_ && ((PCMODE == MIRROR) || (PCMODE == NORACE))
      |->  !RXLINKACTIVEREQ_ ;
  endproperty
  chi5pc_err_lnk_rxact_plus: assert property (CHI5PC_ERR_LNK_RXACT_PLUS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_RXACT_PLUS: RXLINKACTIVEREQ must not be asserted if its local transmit link remains in the XLA_DEACTIVATE state."));
  //=========================================================================
  // INDEX:        - Exit from Race state
  //=========================================================================
  // =====
  // INDEX:        - CHI5PC_ERR_LNK_RXDEACT_RACE_EXIT
  // =====
  property CHI5PC_ERR_LNK_RXDEACT_RACE_EXIT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_STOP,XLA_RUN_PLUS})
      |->  RXLINKACTIVEREQ_ ;
  endproperty
  chi5pc_err_lnk_rxdeact_race_exit: assert property (CHI5PC_ERR_LNK_RXDEACT_RACE_EXIT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_RXDEACT_RACE_EXIT: Receive link state must not pass the XLA_RUN state while the local transmit link state remains in the XLA_STOP state."));
  
  // =====
  // INDEX:        - CHI5PC_ERR_LNK_RXSTOP_RACE_EXIT
  // =====
  property CHI5PC_ERR_LNK_RXSTOP_RACE_EXIT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_ACTIVATE,XLA_DEACTIVATE_PLUS})
      |->  RXLINKACTIVEACK_ ;
  endproperty
  chi5pc_err_lnk_rxstop_race_exit: assert property (CHI5PC_ERR_LNK_RXSTOP_RACE_EXIT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_RXSTOP_RACE_EXIT: Receive link state must not pass the XLA_DEACTIVATE state while the local transmit link state remains in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_RXACT_RACE_EXIT
  // =====
  property CHI5PC_ERR_LNK_RXACT_RACE_EXIT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_RUN,XLA_STOP_PLUS}) 
      |->  !RXLINKACTIVEREQ_ ;
  endproperty
  chi5pc_err_lnk_rxact_race_exit: assert property (CHI5PC_ERR_LNK_RXACT_RACE_EXIT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_RXACT_RACE_EXIT: Receive link state must not pass the XLA_STOP state while the local transmit link state remains in the XLA_RUN state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_RXRUN_RACE_EXIT
  // =====
  property CHI5PC_ERR_LNK_RXRUN_RACE_EXIT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_DEACTIVATE,XLA_ACTIVATE_PLUS} )
      |->  !RXLINKACTIVEACK_ ;
  endproperty
  chi5pc_err_lnk_rxrun_race_exit: assert property (CHI5PC_ERR_LNK_RXRUN_RACE_EXIT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_RXRUN_RACE_EXIT: Receive link state must not pass the XLA_ACTIVATE state while the local transmit link state remains in the XLA_DEACTIVATE state."));
  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXDEACT_RACE_EXIT
  // =====
  property CHI5PC_ERR_LNK_TXDEACT_RACE_EXIT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_RUN_PLUS,XLA_STOP})
      |->  TXLINKACTIVEREQ_ ;
  endproperty
  chi5pc_err_lnk_txdeact_race_exit: assert property (CHI5PC_ERR_LNK_TXDEACT_RACE_EXIT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXDEACT_RACE_EXIT: Transmit link state must not pass the XLA_RUN state while the local receive link state remains in the XLA_STOP state."));
  
  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXSTOP_RACE_EXIT
  // =====
  property CHI5PC_ERR_LNK_TXSTOP_RACE_EXIT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_DEACTIVATE_PLUS,XLA_ACTIVATE})
      |->  TXLINKACTIVEACK_ ;
  endproperty
  chi5pc_err_lnk_txstop_race_exit: assert property (CHI5PC_ERR_LNK_TXSTOP_RACE_EXIT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXSTOP_RACE_EXIT: Transmit link state must not pass the XLA_DEACTIVATE state while the local receive link state remains in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXACT_RACE_EXIT
  // =====
  property CHI5PC_ERR_LNK_TXACT_RACE_EXIT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_STOP_PLUS,XLA_RUN} )
      |->  !TXLINKACTIVEREQ_ ;
  endproperty
  chi5pc_err_lnk_txact_race_exit: assert property (CHI5PC_ERR_LNK_TXACT_RACE_EXIT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXACT_RACE_EXIT: Transmit link state must not pass the XLA_STOP state while the local receive link state remains in the XLA_RUN state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXRUN_RACE_EXIT
  // =====
  property CHI5PC_ERR_LNK_TXRUN_RACE_EXIT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Current_State))
       && (Current_State == {XLA_ACTIVATE_PLUS,XLA_DEACTIVATE} )
      |->  !TXLINKACTIVEACK_ ;
  endproperty
  chi5pc_err_lnk_txrun_race_exit: assert property (CHI5PC_ERR_LNK_TXRUN_RACE_EXIT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXRUN_RACE_EXIT: Transmit link state must not pass the XLA_ACTIVATE state while the local receive link state remains in the XLA_DEACTIVATE state."));
    
//------------------------------------------------------------------------------
// INDEX:   5)  State to Flit and credit issue checks 
//------------------------------------------------------------------------------ 
  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_TXREQLCRDV
  // =====
  property CHI5PC_ERR_LNK_STOP_TXREQLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,TXREQLCRDV_}))
       && ((Current_State.TXSTATE == XLA_STOP) || (Current_State.TXSTATE == XLA_STOP_PLUS))
      |-> !TXREQLCRDV_;
  endproperty
  chi5pc_err_lnk_stop_txreqlcrdv: assert property (CHI5PC_ERR_LNK_STOP_TXREQLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_TXREQLCRDV: TXREQLCRDV must not be asserted when the transmit link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_RXREQLCRDV
  // =====
  property CHI5PC_ERR_LNK_STOP_RXREQLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,RXREQLCRDV_}))
       && ((Current_State.RXSTATE == XLA_STOP) || (Current_State.RXSTATE == XLA_STOP_PLUS))
      |-> !RXREQLCRDV_;
  endproperty
  chi5pc_err_lnk_stop_rxreqlcrdv: assert property (CHI5PC_ERR_LNK_STOP_RXREQLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_RXREQLCRDV: RXREQLCRDV must not be asserted when the receive link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_TXRSPLCRDV
  // =====
  property CHI5PC_ERR_LNK_STOP_TXRSPLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,TXRSPLCRDV_}))
       && ((Current_State.TXSTATE == XLA_STOP) || (Current_State.TXSTATE == XLA_STOP_PLUS))
      |-> !TXRSPLCRDV_;
  endproperty
  chi5pc_err_lnk_stop_txrsplcrdv: assert property (CHI5PC_ERR_LNK_STOP_TXRSPLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_TXRSPLCRDV: TXRSPLCRDV must not be asserted when the transmit link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_RXRSPLCRDV
  // =====
  property CHI5PC_ERR_LNK_STOP_RXRSPLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,RXRSPLCRDV_}))
       && ((Current_State.RXSTATE == XLA_STOP) || (Current_State.RXSTATE == XLA_STOP_PLUS))
      |-> !RXRSPLCRDV_;
  endproperty
  chi5pc_err_lnk_stop_rxrsplcrdv: assert property (CHI5PC_ERR_LNK_STOP_RXRSPLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_RXRSPLCRDV: RXRSPLCRDV must not be asserted when the receive link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_TXSNPLCRDV
  // =====
  property CHI5PC_ERR_LNK_STOP_TXSNPLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.TXSTATE,TXSNPLCRDV_}))
       && ((Current_State.TXSTATE == XLA_STOP) || (Current_State.TXSTATE == XLA_STOP_PLUS))
      |-> !TXSNPLCRDV_ ;
  endproperty
  chi5pc_err_lnk_stop_txsnplcrdv: assert property (CHI5PC_ERR_LNK_STOP_TXSNPLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_TXSNPLCRDV: TXSNPLCRDV must not be asserted when the transmit link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_RXSNPLCRDV
  // =====
  property CHI5PC_ERR_LNK_STOP_RXSNPLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.RXSTATE,RXSNPLCRDV_}))
       && ((Current_State.RXSTATE == XLA_STOP) || (Current_State.RXSTATE == XLA_STOP_PLUS))
      |-> !RXSNPLCRDV_ ;
  endproperty
  chi5pc_err_lnk_stop_rxsnplcrdv: assert property (CHI5PC_ERR_LNK_STOP_RXSNPLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_RXSNPLCRDV: RXSNPLCRDV must not be asserted when the receive link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_TXDATLCRDV
  // =====
  property CHI5PC_ERR_LNK_STOP_TXDATLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.TXSTATE,TXDATLCRDV_}))
       && ((Current_State.TXSTATE == XLA_STOP) || (Current_State.TXSTATE == XLA_STOP_PLUS))
      |-> !TXDATLCRDV_ ;
  endproperty
  chi5pc_err_lnk_stop_txdatlcrdv: assert property (CHI5PC_ERR_LNK_STOP_TXDATLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_TXDATLCRDV: TXDATLCRDV must not be asserted when the transmit link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_RXDATLCRDV
  // =====
  property CHI5PC_ERR_LNK_STOP_RXDATLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.RXSTATE,RXDATLCRDV_}))
       && ((Current_State.RXSTATE == XLA_STOP) || (Current_State.RXSTATE == XLA_STOP_PLUS))
      |-> !RXDATLCRDV_ ;
  endproperty
  chi5pc_err_lnk_stop_rxdatlcrdv: assert property (CHI5PC_ERR_LNK_STOP_RXDATLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_RXDATLCRDV: RXDATLCRDV must not be asserted when the receive link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_ACT_RXREQLCRDV
  // =====
  property CHI5PC_ERR_LNK_ACT_RXREQLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,RXREQLCRDV_}))
       && ((Current_State.RXSTATE == XLA_ACTIVATE) || (Current_State.RXSTATE == XLA_ACTIVATE_PLUS))&& (Next_State.RXSTATE != XLA_RUN) && ((PCMODE == LOCAL) || (PCMODE == NORACE))
      |->  !RXREQLCRDV_ ;
  endproperty
  chi5pc_err_lnk_act_rxreqlcrdv: assert property (CHI5PC_ERR_LNK_ACT_RXREQLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_ACT_RXREQLCRDV: RXREQLCRDV must not be asserted when the receive link is in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_ACT_RXRSPLCRDV
  // =====
  property CHI5PC_ERR_LNK_ACT_RXRSPLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,RXRSPLCRDV_}))
       && ((Current_State.RXSTATE == XLA_ACTIVATE) || (Current_State.RXSTATE == XLA_ACTIVATE_PLUS))  && (Next_State.RXSTATE != XLA_RUN) && ((PCMODE == LOCAL) || (PCMODE == NORACE))
      |->  !RXRSPLCRDV_ ;
  endproperty
  chi5pc_err_lnk_act_rxrsplcrdv: assert property (CHI5PC_ERR_LNK_ACT_RXRSPLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_ACT_RXRSPLCRDV: RXRSPLCRDV must not be asserted when the receive link is in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_ACT_RXSNPLCRDV
  // =====
  property CHI5PC_ERR_LNK_ACT_RXSNPLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,RXSNPLCRDV_}))
       &&  ((Current_State.RXSTATE == XLA_ACTIVATE) || (Current_State.RXSTATE == XLA_ACTIVATE_PLUS)) && (Next_State.RXSTATE != XLA_RUN) && ((PCMODE == LOCAL) || (PCMODE == NORACE))
      |->  !RXSNPLCRDV_ ;
  endproperty
  chi5pc_err_lnk_act_rxsnplcrdv: assert property (CHI5PC_ERR_LNK_ACT_RXSNPLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_ACT_RXSNPLCRDV: RXSNPLCRDV must not be asserted when the receive link is in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_ACT_RXDATLCRDV
  // =====
  property CHI5PC_ERR_LNK_ACT_RXDATLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,RXDATLCRDV_}))
       && ((Current_State.RXSTATE == XLA_ACTIVATE) || (Current_State.RXSTATE == XLA_ACTIVATE_PLUS))  && (Next_State.RXSTATE != XLA_RUN) && ((PCMODE == LOCAL) || (PCMODE == NORACE))
      |->  !RXDATLCRDV_;
  endproperty
  chi5pc_err_lnk_act_rxdatlcrdv: assert property (CHI5PC_ERR_LNK_ACT_RXDATLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_ACT_RXDATLCRDV: RXDATLCRDV must not be asserted when the receive link is in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_TXREQFLITV
  // =====
  property CHI5PC_ERR_LNK_STOP_TXREQFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.TXSTATE,TXREQFLITV_})) 
       && ((Current_State.TXSTATE == XLA_STOP) || (Current_State.TXSTATE == XLA_STOP_PLUS))
      |->  !TXREQFLITV_;
  endproperty
  chi5pc_err_lnk_stop_txreqflitv: assert property (CHI5PC_ERR_LNK_STOP_TXREQFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_TXREQFLITV: TXREQFLITV must not be asserted when the transmit link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_RXREQFLITV
  // =====
  property CHI5PC_ERR_LNK_STOP_RXREQFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.RXSTATE,RXREQFLITV_}))
       && ((Current_State.RXSTATE == XLA_STOP) || (Current_State.RXSTATE == XLA_STOP_PLUS))
      |->  !RXREQFLITV_;
  endproperty
  chi5pc_err_lnk_stop_rxreqflitv: assert property (CHI5PC_ERR_LNK_STOP_RXREQFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_RXREQFLITV: RXREQFLITV must not be asserted when the receive link is in the XLA_STOP state."));


  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_TXRSPFLITV
  // =====
  property CHI5PC_ERR_LNK_STOP_TXRSPFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.TXSTATE,TXRSPFLITV_}))
       && ((Current_State.TXSTATE == XLA_STOP) || (Current_State.TXSTATE == XLA_STOP_PLUS)) && |TXRSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] 
      |->  !TXRSPFLITV_;
  endproperty
  chi5pc_err_lnk_stop_txrspflitv: assert property (CHI5PC_ERR_LNK_STOP_TXRSPFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_TXRSPFLITV: TXRSPFLITV must not be asserted when the transmit link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_RXRSPFLITV
  // =====
  property CHI5PC_ERR_LNK_STOP_RXRSPFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.RXSTATE,RXRSPFLITV_}))
       && ((Current_State.RXSTATE == XLA_STOP) || (Current_State.RXSTATE == XLA_STOP_PLUS)) && |RXRSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE]
      |->  !RXRSPFLITV_;
  endproperty
  chi5pc_err_lnk_stop_rxrspflitv: assert property (CHI5PC_ERR_LNK_STOP_RXRSPFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_RXRSPFLITV: RXRSPFLITV must not be asserted when the receive link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_TXSNPFLITV
  // =====
  property CHI5PC_ERR_LNK_STOP_TXSNPFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.TXSTATE,TXSNPFLITV_}))
       && ((Current_State.TXSTATE == XLA_STOP) || (Current_State.TXSTATE == XLA_STOP_PLUS))  && |TXSNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] 
      |->  !TXSNPFLITV_;
  endproperty
  chi5pc_err_lnk_stop_txsnpflitv: assert property (CHI5PC_ERR_LNK_STOP_TXSNPFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_TXSNPFLITV: TXSNPFLITV must not be asserted when the transmit link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_RXSNPFLITV
  // =====
  property CHI5PC_ERR_LNK_STOP_RXSNPFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.RXSTATE,RXSNPFLITV_}))
       && ((Current_State.RXSTATE == XLA_STOP) || (Current_State.RXSTATE == XLA_STOP_PLUS)) 
      |->  !RXSNPFLITV_;
  endproperty
  chi5pc_err_lnk_stop_rxsnpflitv: assert property (CHI5PC_ERR_LNK_STOP_RXSNPFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_RXSNPFLITV: RXSNPFLITV must not be asserted when the receive link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_TXDATFLITV
  // =====
  property CHI5PC_ERR_LNK_STOP_TXDATFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.TXSTATE,TXDATFLITV_}))
       && ((Current_State.TXSTATE == XLA_STOP) || (Current_State.TXSTATE == XLA_STOP_PLUS)) && |TXDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE]
      |->  !TXDATFLITV_;
  endproperty
  chi5pc_err_lnk_stop_txdatflitv: assert property (CHI5PC_ERR_LNK_STOP_TXDATFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_TXDATFLITV: TXDATFLITV must not be asserted when the transmit link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_STOP_RXDATFLITV
  // =====
  property CHI5PC_ERR_LNK_STOP_RXDATFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.RXSTATE,RXDATFLITV_}))
       && ((Current_State.RXSTATE == XLA_STOP) || (Current_State.RXSTATE == XLA_STOP_PLUS)) && |RXDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE]
      |->  !RXDATFLITV_;
  endproperty
  chi5pc_err_lnk_stop_rxdatflitv: assert property (CHI5PC_ERR_LNK_STOP_RXDATFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_STOP_RXDATFLITV: RXDATFLITV must not be asserted when the receive link is in the XLA_STOP state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_ACT_TXREQFLITV
  // =====
  property CHI5PC_ERR_LNK_ACT_TXREQFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,TXREQFLITV_}))
       && ((Current_State.TXSTATE == XLA_ACTIVATE) || (Current_State.TXSTATE == XLA_ACTIVATE_PLUS))
      |-> !TXREQFLITV_ ;
  endproperty
  chi5pc_err_lnk_act_txreqflitv: assert property (CHI5PC_ERR_LNK_ACT_TXREQFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_ACT_TXREQFLITV: TXREQFLITV must not be asserted when the transmit link is in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_ACT_RXREQFLITV
  // =====
  property CHI5PC_ERR_LNK_ACT_RXREQFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State,RXREQFLITV_}))
       && ((Current_State.RXSTATE == XLA_ACTIVATE) || (Current_State.RXSTATE == XLA_ACTIVATE_PLUS))
      |-> !RXREQFLITV_ ;
  endproperty
  chi5pc_err_lnk_act_rxreqflitv: assert property (CHI5PC_ERR_LNK_ACT_RXREQFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_ACT_RXREQFLITV: RXREQFLITV must not be asserted when the receive link is in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_ACT_TXRSPFLITV
  // =====
  property CHI5PC_ERR_LNK_ACT_TXRSPFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.TXSTATE,TXRSPFLITV_}))
       && ((Current_State.TXSTATE == XLA_ACTIVATE) || (Current_State.TXSTATE == XLA_ACTIVATE_PLUS))
      |-> !TXRSPFLITV_ ;
  endproperty
  chi5pc_err_lnk_act_txrspflitv: assert property (CHI5PC_ERR_LNK_ACT_TXRSPFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_ACT_TXRSPFLITV: TXRSPFLITV must not be asserted when the transmit link is in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_ACT_RXRSPFLITV
  // =====
  property CHI5PC_ERR_LNK_ACT_RXRSPFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.RXSTATE,RXRSPFLITV_}))
       && ((Current_State.RXSTATE == XLA_ACTIVATE) || (Current_State.RXSTATE == XLA_ACTIVATE_PLUS))
      |-> !RXRSPFLITV_ ;
  endproperty
  chi5pc_err_lnk_act_rxrspflitv: assert property (CHI5PC_ERR_LNK_ACT_RXRSPFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_ACT_RXRSPFLITV: RXRSPFLITV must not be asserted when the receive link is in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_ACT_TXSNPFLITV
  // =====
  property CHI5PC_ERR_LNK_ACT_TXSNPFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.TXSTATE,TXSNPFLITV_}))
       && ((Current_State.TXSTATE == XLA_ACTIVATE) || (Current_State.TXSTATE == XLA_ACTIVATE_PLUS))
      |-> !TXSNPFLITV_ ;
  endproperty
  chi5pc_err_lnk_act_txsnpflitv: assert property (CHI5PC_ERR_LNK_ACT_TXSNPFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_ACT_TXSNPFLITV: TXSNPFLITV must not be asserted when the transmit link is in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_ACT_RXSNPFLITV
  // =====
  property CHI5PC_ERR_LNK_ACT_RXSNPFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.RXSTATE,RXSNPFLITV_}))
       && ((Current_State.RXSTATE == XLA_ACTIVATE) || (Current_State.RXSTATE == XLA_ACTIVATE_PLUS))
      |-> !RXSNPFLITV_ ;
  endproperty
  chi5pc_err_lnk_act_rxsnpflitv: assert property (CHI5PC_ERR_LNK_ACT_RXSNPFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_ACT_RXSNPFLITV: RXSNPFLITV must not be asserted when the receive link is in the XLA_ACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_ACT_TXDATFLITV
  // =====
  property CHI5PC_ERR_LNK_ACT_TXDATFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.TXSTATE,TXDATFLITV_}))
       && ((Current_State.TXSTATE == XLA_ACTIVATE) || (Current_State.TXSTATE == XLA_ACTIVATE_PLUS))
      |-> !TXDATFLITV_ ;
  endproperty
  chi5pc_err_lnk_act_txdatflitv: assert property (CHI5PC_ERR_LNK_ACT_TXDATFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_ACT_TXDATFLITV: TXDATFLITV must not be asserted when the transmit link is in the XLA_ACTIVATE state."));
  
  // =====
  // INDEX:        - CHI5PC_ERR_LNK_ACT_RXDATFLITV
  // =====
  property CHI5PC_ERR_LNK_ACT_RXDATFLITV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.RXSTATE,RXDATFLITV_}))
       && ((Current_State.RXSTATE == XLA_ACTIVATE) || (Current_State.RXSTATE == XLA_ACTIVATE_PLUS))
      |-> !RXDATFLITV_ ;
  endproperty
  chi5pc_err_lnk_act_rxdatflitv: assert property (CHI5PC_ERR_LNK_ACT_RXDATFLITV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_ACT_RXDATFLITV: RXDATFLITV must not be asserted when the receive link is in the XLA_ACTIVATE state."));
  
  // =====
  // INDEX:        - CHI5PC_ERR_LNK_DEACT_REQLCRDV
  // =====
  property CHI5PC_ERR_LNK_DEACT_RXREQLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.RXSTATE,RXREQLCRDV_}))
       && ((Current_State.RXSTATE == XLA_DEACTIVATE) || (Current_State.RXSTATE == XLA_DEACTIVATE_PLUS)) 
       &&  (RXREQLCRDV_since_deactivate_cnt == MAXLLCREDITS_IN_RXDEACTIVATE)
      |->  !RXREQLCRDV_;
  endproperty
  chi5pc_err_lnk_deact_rxreqlcrdv: assert property (CHI5PC_ERR_LNK_DEACT_RXREQLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_DEACT_RXREQLCRDV: Maximum number of allowed RXREQLCRDV have been asserted on the receive link in the XLA_DEACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_DEACT_RXRSPLCRDV
  // =====
  property CHI5PC_ERR_LNK_DEACT_RXRSPLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.RXSTATE,RXRSPLCRDV_}))
       && ((Current_State.RXSTATE == XLA_DEACTIVATE) || (Current_State.RXSTATE == XLA_DEACTIVATE_PLUS)) 
       &&  (RXRSPLCRDV_since_deactivate_cnt == MAXLLCREDITS_IN_RXDEACTIVATE)
      |->  !RXRSPLCRDV_;
  endproperty
  chi5pc_err_lnk_deact_rxrsplcrdv: assert property (CHI5PC_ERR_LNK_DEACT_RXRSPLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_DEACT_RXRSPLCRDV: Maximum number of allowed RXRSPLCRDV have been asserted on the receive link in the XLA_DEACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_DEACT_RXSNPLCRDV
  // =====
  property CHI5PC_ERR_LNK_DEACT_RXSNPLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.RXSTATE,RXSNPLCRDV_}))
       && ((Current_State.RXSTATE == XLA_DEACTIVATE) || (Current_State.RXSTATE == XLA_DEACTIVATE_PLUS)) 
       &&  (RXSNPLCRDV_since_deactivate_cnt == MAXLLCREDITS_IN_RXDEACTIVATE)
      |->  !RXSNPLCRDV_;
  endproperty
  chi5pc_err_lnk_deact_rxsnplcrdv: assert property (CHI5PC_ERR_LNK_DEACT_RXSNPLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_DEACT_RXSNPLCRDV: Maximum number of allowed RXSNPLCRDV have been asserted on the receive link in the XLA_DEACTIVATE state."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_DEACT_RXDATLCRDV
  // =====
  property CHI5PC_ERR_LNK_DEACT_RXDATLCRDV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Current_State.RXSTATE,RXDATLCRDV_}))
       && ((Current_State.RXSTATE == XLA_DEACTIVATE) || (Current_State.RXSTATE == XLA_DEACTIVATE_PLUS)) 
       &&  (RXDATLCRDV_since_deactivate_cnt == MAXLLCREDITS_IN_RXDEACTIVATE)
      |->  !RXDATLCRDV_;
  endproperty
  chi5pc_err_lnk_deact_rxdatlcrdv: assert property (CHI5PC_ERR_LNK_DEACT_RXDATLCRDV) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_DEACT_RXDATLCRDV: Maximum number of allowed RXDATLCRDV have been asserted on the receive link in the XLA_DEACTIVATE state."));


//
//------------------------------------------------------------------------------ 
// INDEX:   6)  End of simulation checks
//------------------------------------------------------------------------------ 

final
begin
  `ifndef CHI5PC_EOS_OFF
  $display ("Executing CHI5 End Of Simulation transaction Link activation checks");
  // =====
  // INDEX:        - CHI5PC_ERR_EOS_LNK_TX
  // =====
  //property CHI5PC_ERR_EOS_LNK_TX;
  if (!($isunknown({Current_State, TXLINKACTIVEREQ_})))
  chi5pc_err_eos_lnk_tx:
    assert ((Current_State.TXSTATE == XLA_STOP) && !TXLINKACTIVEREQ_) else
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_LNK_TX: Transmit link still active at end of simulation."));

  // =====
  // INDEX:        - CHI5PC_ERR_EOS_LNK_RX
  // =====
  //property CHI5PC_ERR_EOS_LNK_RX;
  if (!($isunknown({Current_State, RXLINKACTIVEREQ_})))
  chi5pc_err_eos_lnk_rx:
    assert ((Current_State.RXSTATE == XLA_STOP) && !RXLINKACTIVEREQ_) else
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_LNK_RX: Receive link still active at end of simulation."));
  `endif
end

//------------------------------------------------------------------------------
// INDEX:   7) Clear Verilog Defines
//------------------------------------------------------------------------------
// Clock and Reset
  `undef CHI5_AUX_CLK
  `undef CHI5_AUX_RSTn
  `undef CHI5_SVA_CLK
  `undef CHI5_SVA_RSTn

//------------------------------------------------------------------------------
// INDEX:   8) End of module
//------------------------------------------------------------------------------

endmodule // Chi5PC_XLA 

//------------------------------------------------------------------------------
`endif
