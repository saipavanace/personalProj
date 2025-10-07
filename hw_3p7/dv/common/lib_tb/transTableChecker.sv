import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_agent_pkg::*;
/* The transTableChecker module is used for verifying correctness on debug accesses.
 This module is instantiated for every transaction table in the concerto
 system. It takes as inputs apb interface, a two-dimentional array consisting of all
 debuggable contents of the transTable (in proper order). On every debug access sequence,
 it will check the data provided on the apbIf with the data present at the
 proper location in the array and flag an error on mismatch.
 In addition it also takes the transTable ID as an input in order to
 identify relevent debug accesses. Based on this ID, it will then carry out
 correctness checks for the table corresponding to this ID.
 The number of entries in the module and the width of every entry are parameters.
 */

module transTableChecker
#(parameter NUM_ENTRIES = 4, WIDTH = 21)
(apb_if apbIf,
input reg [WIDTH-1:0] dataArray[NUM_ENTRIES],
input reg [7:0] transTableId,
input clk,
input rstn);

////////////////////////////////////////////////////////////////////
//
// Variable Definitions
//
////////////////////////////////////////////////////////////////////
   bit dont_report_error = 0;

// Checker fsm
   logic [2:0] cState, nState;
   localparam [2:0] IDLE = 3'b000,
     SAWDLRW = 3'b001,
     SAWDCRW = 3'b010,
     SAWDARP = 3'b011,
     SAWDDRR = 3'b100;

   logic [19:0] entryId;
   logic [5:0]  wordId;
   logic [31:0] expdData;
   logic [10:0] counter;

   // Master packet fsm
   logic [2:0] colMPkt_cS, colMPkt_nS;
   localparam [2:0] PKT_IDLE = 3'b000,
     PKT_COLLECT_0 = 3'b001,
     PKT_COLLECT_1 = 3'b010,
     PKT_COLLECT_2 = 3'b011,
     PKT_COLLECT_3 = 3'b100;

   logic        mPktAvailable;
   int          mBeats = 0;

   apb_maddr_t    MAddr;
   apb_mcmd_t     MCmd;
   apb_mdata_t    MData;
   //rand           MRespAccept;
   //rand           SCmdAccept;

// Slave packet fsm
   logic [2:0]  colSPkt_cS, colSPkt_nS;
   logic        sPktAvailable;
   int          sBeats = 0;
   apb_sdata_t    SData;
   apb_sresp_t     SResp;

initial begin
    dont_report_error = (($test$plusargs("no_quiesce")) || ($test$plusargs("back_to_back_csr")));
end
////////////////////////////////////////////////////////////////////
//
// Master packet fsm
//
////////////////////////////////////////////////////////////////////
   always@(posedge clk or negedge rstn) begin
      if (~rstn)
        colMPkt_cS <= PKT_IDLE;
      else
        colMPkt_cS <= colMPkt_nS;
   end

   always@(*)
     case(colMPkt_cS)
       PKT_IDLE: begin
          mPktAvailable = 0;
          //`uvm_info("transTableChecker",$sformatf(" MST IDLE"), UVM_LOW);
          if (((apbIf.MCmd == 2) || (apbIf.MCmd == 5)) && (apbIf.SCmdAccept == 1)) begin
             colMPkt_nS = PKT_COLLECT_0;
             mBeats = 1;
             MAddr = apbIf.MAddr;
             MData[7:0] = apbIf.MData;
             MCmd = apbIf.MCmd;
          end else begin
             colMPkt_nS = PKT_IDLE;
             mBeats = 0;
             MAddr = apbIf.MAddr;
             MData = 0;
             MCmd = 0;
          ////`uvm_info("new", $sformatf("Set plusarg_sequence_length from +sequence_length=%b", this.plusarg_sequence_length), UVM_HIGH);
          end
       end
       PKT_COLLECT_0: begin
          //`uvm_info("transTableChecker",$sformatf("MST PKT_COLLECT 0"), UVM_LOW);
          mPktAvailable = 0;
          if (((apbIf.MCmd == 2) || (apbIf.MCmd == 5)) && (apbIf.SCmdAccept == 1)) begin
             colMPkt_nS = PKT_COLLECT_1;
             mBeats = 2;
             MData[15:8] = apbIf.MData;
          end else begin
          colMPkt_nS = PKT_COLLECT_0;
          end
       end
       PKT_COLLECT_1: begin
          //`uvm_info("transTableChecker",$sformatf("MST PKT_COLLECT 1"), UVM_LOW);
          mPktAvailable = 0;
          if (((apbIf.MCmd == 2) || (apbIf.MCmd == 5)) && (apbIf.SCmdAccept == 1)) begin
             colMPkt_nS = PKT_COLLECT_2;
             mBeats = 3;
             MData[23:16] = apbIf.MData;
          end else begin
          colMPkt_nS = PKT_COLLECT_1;
          end
       end
       PKT_COLLECT_2: begin
          //`uvm_info("transTableChecker",$sformatf("MST PKT_COLLECT 2"), UVM_LOW);
          if (((apbIf.MCmd == 2) || (apbIf.MCmd == 5)) && (apbIf.SCmdAccept == 1)) begin
             mPktAvailable = 1;
             colMPkt_nS = PKT_COLLECT_3;
             mBeats = 4;
             MData[31:24] = apbIf.MData;
          end else begin
             mPktAvailable = 0;
             colMPkt_nS = PKT_COLLECT_2;
          end
       end
       PKT_COLLECT_3: begin
          colMPkt_nS = IDLE;
          mBeats = 0;
          mPktAvailable = 0;
          //`uvm_info("transTableChecker",$sformatf(" MST PKT_COLLECT 3"), UVM_LOW);
       end
       default: begin
          colMPkt_nS = IDLE;
          mBeats = 0;
          mPktAvailable = 0;
          MAddr = 0;
          MData = 0;
          MCmd = 0;
          //`uvm_error("transTableChecker","MPkt fsm in UNDEFINED state");
       end
     endcase // case (colMPkt_cS)


////////////////////////////////////////////////////////////////////
//
// Slave packet fsm
//
////////////////////////////////////////////////////////////////////
   always@(posedge clk or negedge rstn) begin
      if (~rstn)
        colSPkt_cS <= PKT_IDLE;
      else
        colSPkt_cS <= colSPkt_nS;
   end

   always@(*)
     case(colSPkt_cS)
       PKT_IDLE: begin
          //`uvm_info("transTableChecker",$sformatf(" SLV IDLE"), UVM_LOW);
          if ((apbIf.SResp == 1) && (apbIf.MRespAccept == 1)) begin
             colSPkt_nS = PKT_COLLECT_0;
             sBeats = 1;
             sPktAvailable = 0;
             SData[7:0] = apbIf.SData;
          end else begin
             colSPkt_nS =  PKT_IDLE;
             sPktAvailable = 0;
             SData = 0;
             sBeats = 0;
          end
       end
       PKT_COLLECT_0: begin
          sPktAvailable = 0;
          if ((apbIf.SResp == 1) && (apbIf.MRespAccept == 1)) begin
             colSPkt_nS = PKT_COLLECT_1;
             sBeats = 2;
             SData[15:8] = (apbIf.SData);
             //`uvm_info("transTableChecker",$sformatf(" SLV PKT_COLLECT 0"), UVM_LOW);
          end else begin
             colSPkt_nS = PKT_COLLECT_0;
          end
       end
       PKT_COLLECT_1: begin
          sPktAvailable = 0;
          if ((apbIf.SResp == 1) && (apbIf.MRespAccept == 1)) begin
             colSPkt_nS = PKT_COLLECT_2;
             sBeats = 3;
             SData[23:16] = (apbIf.SData);
             //`uvm_info("transTableChecker",$sformatf(" SLV PKT_COLLECT 1"), UVM_LOW);
          end else begin
             colSPkt_nS = PKT_COLLECT_1;
          end
       end
       PKT_COLLECT_2: begin
          if ((apbIf.SResp == 1) && (apbIf.MRespAccept == 1)) begin
             colSPkt_nS = PKT_COLLECT_3;
             sBeats = 4;
             SData[31:24] = (apbIf.SData);
             //`uvm_info("transTableChecker",$sformatf(" SLV PKT_COLLECT 2"), UVM_LOW);
          end 
          else begin
             colSPkt_nS = PKT_COLLECT_2;
          end
       end
       PKT_COLLECT_3: begin
          colSPkt_nS = IDLE;
          sBeats  = 0;
          sPktAvailable = 1;
          //`uvm_info("transTableChecker",$sformatf(" SLV PKT_COLLECT 3"), UVM_LOW);
       end
       default: begin
          colSPkt_nS = IDLE;
          sBeats = 0;
          sPktAvailable = 0;
          SData = 0;
          //`uvm_error("transTableChecker","SPkt fsm in UNDEFINED state");
       end
     endcase // case (colSPkt_cS)


////////////////////////////////////////////////////////////////////
//
// Checker fsm
//
////////////////////////////////////////////////////////////////////
   always@(posedge clk or negedge rstn) begin
      if (~rstn)
        cState <= IDLE;
      else
        cState <= nState;
   end

   always@(posedge clk or negedge rstn) begin
      if (~rstn)
        counter <= 100;
      else begin
         if ((cState == SAWDARP) && (nState == IDLE)) begin
            counter <= counter - 1;
         end
         else if ((cState == SAWDARP) && (nState == SAWDDRR)) begin
            counter <=100;
         end
      end
   end

   always@(posedge clk or negedge rstn) begin
      if (counter === 0) begin
       if (dont_report_error == 0) begin
         `uvm_error("transTableChecker",$sformatf("Timedout polling DAR! DAR[0]:0x%0x sDAR[1]:0x%0x", SData[0], SData[1]));
       end
      end
   end

   always@(*)
     case(cState)
       IDLE: begin
             //`uvm_info("transTableChecker",$sformatf("IDLE"), UVM_LOW);
          if((mPktAvailable == 1) && (MCmd === 5) && (MData[25:20] === transTableId) && (MAddr[11:0] === (12'h3c2<<2))) begin // write to DLR
             //`uvm_info("transTableChecker",$sformatf("CHKR IDLE JUMP"), UVM_LOW);
             nState = SAWDLRW;
             entryId = (MData[19:0]);
             wordId = (MData[31:26]);
             //expdData = dataArray[entryId][wordId];
          end
          else begin
             nState = IDLE;
          end
       end
       SAWDLRW: begin
          if((mPktAvailable == 1) && (MCmd === 5) && (MData[3:0] === 0) && (MAddr[11:0] === (12'h3c0 << 2))) begin // write to DCR
             //`uvm_info("transTableChecker",$sformatf(" CHKR SAWDLRW JUMP"), UVM_LOW);
             nState = SAWDCRW;
          end
          else begin
             nState = SAWDLRW;
          end
       end
       SAWDCRW: begin
          //expdData = dataArray[entryId][32*wordId+7:32*wordId];
          //expdData = (expdData>>(wordId*8) && 32'hff);
          if((mPktAvailable == 1) && (MCmd === 2) && (MAddr[11:0] === (12'h3c1)<<2)) begin
             //`uvm_info("transTableChecker",$sformatf(" CHKR SAWDCRW JUMP"), UVM_LOW);
             nState = SAWDARP;
             expdData = (dataArray[entryId]>>(wordId*32));
             `uvm_info("transTableChecker",$sformatf(" entryId:0x%0x wordId:0x%0x dataArray_entry0x%0x expdData:0x%0x ", entryId, wordId,  dataArray[entryId], expdData), UVM_LOW);
          end
          else begin
             nState = SAWDCRW;
          end
       end
       SAWDARP: begin
          if((sPktAvailable == 1) && (SData[0] === 0) && (SData[1] === 0)) begin
             //`uvm_info("transTableChecker",$sformatf(" CHKR SAWDARP JUMP"), UVM_LOW);
             nState = SAWDDRR;
          end
          else if((sPktAvailable == 1) && (SData[0] === 0) && (SData[1] === 1)) begin
             //`uvm_info("transTableChecker",$sformatf(" CHKR SAWDARP JUMP"), UVM_LOW);
             nState = IDLE;
          end
          else begin
             nState = SAWDARP;
          end
       end
       SAWDDRR: begin
          if((sPktAvailable == 1)) begin
             nState = IDLE;
             `uvm_info("transTableChecker",$sformatf("transTableId=0x%0x entry=0x%0x word=0x%0x", transTableId, entryId, wordId), UVM_LOW);
             if (SData !== expdData) begin
              if (dont_report_error == 0) begin
                `uvm_error("transTableChecker",$sformatf("Data Mismatch! expd:0x%0x saw:0x%0x at transTableId=0x%0x entry=0x%0x word=0x%0x", expdData, SData, transTableId, entryId, wordId));
              end
                //`uvm_info("transTableChecker",$sformatf("Data Mismatch! expd:0x%0x saw:0x%0x at transTableId=0x%0x entry=0x%0x word=0x%0x", expdData, SData, transTableId, entryId, wordId), UVM_LOW);
                ////`uvm_info("transTableChecker",$sformatf("Data Mismatch! expd:0x%0x saw:0x%0x", expdData, SData), UVM_LOW);
             end
             else
               begin
                  `uvm_info("transTableChecker",$sformatf("Data Match! expd:0x%0x saw:0x%0x", expdData, SData), UVM_LOW);
               end
          end // if ((sPktAvailable == 1))
          else begin
             nState = SAWDDRR;
          end // else: !if((sPktAvailable == 1))
       end // case: SAWDDRR
       default: begin
          nState = IDLE;
          //`uvm_error("transTableChecker","Checker fsm in UNDEFINED state");
       end
     endcase // case (cState)
   // Identify write to the *DOLR
   // Identify write the *DOCR
   // Poll the *DOAR for completion
   // Read the *DODR for data

endmodule :transTableChecker

