<%
//Embedded javascript code to figure number of blocks
   var _child_blkid      = [];
   var _child_blk        = [];
   var pidx              = 0;
   var ridx              = 0;
   var qidx              = 0;
   var idx               = 0;
   var j                 = 0;
   var num_chi_aiu_tx_if = 0;
   var num_io_aiu_tx_if  = 0;
   var num_dmi_tx_if     = 0;
   var num_dii_tx_if     = 0;
   var num_dce_tx_if     = 0;
   var num_dve_tx_if     = 0;
   var num_chi_aiu_rx_if = 0;
   var num_io_aiu_rx_if  = 0;
   var num_dmi_rx_if     = 0;
   var num_dii_rx_if     = 0;
   var num_dce_rx_if     = 0;
   var num_dve_rx_if     = 0;
   var initiatorAgents   = obj.AiuInfo.length ;
   var numChiAiu         = 0;
   var numIoAiu          = 0;
   var aiu_NumCores = [];

   for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
     if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
         aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
     } else {
         aiu_NumCores[pidx]    = 1;
     }
   }
   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       num_chi_aiu_tx_if = obj.AiuInfo[pidx].smiPortParams.tx.length;
       num_chi_aiu_rx_if = obj.AiuInfo[pidx].smiPortParams.rx.length;
       numChiAiu = numChiAiu + 1;
       idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + qidx;
       _child_blk[pidx]   = 'ioaiu';
       num_io_aiu_tx_if = obj.AiuInfo[pidx].smiPortParams.tx.length;
       num_io_aiu_rx_if = obj.AiuInfo[pidx].smiPortParams.rx.length;
       numIoAiu = numIoAiu + 1;
       qidx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
       num_dce_tx_if = obj.DceInfo[pidx].smiPortParams.tx.length;
       num_dce_rx_if = obj.DceInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
       num_dmi_tx_if = obj.DmiInfo[pidx].smiPortParams.tx.length;
       num_dmi_rx_if = obj.DmiInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
       num_dii_tx_if = obj.DiiInfo[pidx].smiPortParams.tx.length;
       num_dii_rx_if = obj.DiiInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
       num_dve_tx_if = obj.DveInfo[pidx].smiPortParams.tx.length;
       num_dve_rx_if = obj.DveInfo[pidx].smiPortParams.rx.length;
   }
%>

typedef enum int {
      CMD_REQ = 1,
      STR_REQ = 2,
      RBR_REQ = 3,
      RBR_RSP = 4,
      DTW_REQ = 5,
      DTR_REQ = 6,
      SNP_REQ = 7,
      SNP_RESP = 8,
      MRD_REQ = 9
   } smi_msgs_t;

`ifdef FSYS_SCB_COVER_ON
////////////////////////////////////////////////////////////////////////////////
//
// Class: FSYS SCB's covereage class
//
////////////////////////////////////////////////////////////////////////////////
class fsys_txn_path_coverage;

   smi_msgs_t  msg;
   bit aiu; // 1 = ioaiu, 0 = chiaiu

   /////////////////////////////////////////////////////////////////////////////////////
   //
   // Covergroup: IOAIU transaction flow covergroup
   //
   /////////////////////////////////////////////////////////////////////////////////////
   covergroup TXN_PATH;
      option.auto_bin_max = 10000;
      //transaction_path_wr_1 : coverpoint msg
      //{
      //   //bins WR_WITH_SNP_DTW_1[] = (CMD_REQ=>SNP_REQ, RBR_REQ, STR_REQ=>STR_REQ, SNP_REQ, RBR_REQ, SNP_RESP, DTW_REQ=>RBR_REQ, DTW_REQ, SNP_RESP, STR_REQ=>SNP_RESP, STR_REQ, DTW_REQ=>DTW_REQ);
      //}
      transaction_paths : coverpoint msg
      {
         // These bins were added based on all_cmd fsys test observations.
         //Prefetch txn flow
         bins TXN_PATH_1[] = (CMD_REQ=>STR_REQ);
         bins TXN_PATH_2[] = (CMD_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ);
         bins TXN_PATH_3[] = (CMD_REQ=>STR_REQ=>DTW_REQ);
         bins TXN_PATH_4[] = (CMD_REQ=>STR_REQ=>DTR_REQ);
         bins TXN_PATH_5[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>RBR_RSP);
         // TODO: How to write bin where we can mention STR_REQ is last expected transition
         bins TXN_PATH_6[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ); 
         bins TXN_PATH_7[] = (CMD_REQ=>SNP_REQ=>RBR_REQ=>SNP_RESP=>STR_REQ); 
         bins TXN_PATH_8[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>RBR_RSP=>SNP_RESP=>STR_REQ);
         //COV_EXCL: Okay to exclude because other variation is hit
         //bins TXN_PATH_9[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>SNP_RESP=>RBR_RSP=>STR_REQ);
         //Write stash decline txn flow
         bins TXN_PATH_10[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>DTW_REQ=>RBR_RSP);
         bins TXN_PATH_11[] = (CMD_REQ=>SNP_REQ=>RBR_REQ=>SNP_RESP=>STR_REQ=>DTW_REQ);
         //Invalidate txn flow
         bins TXN_PATH_12[] = (CMD_REQ=>SNP_REQ=>SNP_RESP=>MRD_REQ=>STR_REQ);
         bins TXN_PATH_13[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>MRD_REQ=>RBR_RSP=>STR_REQ);
         //COV_EXCL: Okay to exclude because other variation is hit
         //bins TXN_PATH_14[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>MRD_REQ=>STR_REQ=>RBR_RSP=>DTR_REQ);
         bins TXN_PATH_15[] = (CMD_REQ=>SNP_REQ=>RBR_REQ=>SNP_RESP=>STR_REQ=>MRD_REQ=>DTR_REQ);
         //COV_EXCL: Okay to exclude because other variation is hit
         //bins TXN_PATH_16[] = (CMD_REQ=>SNP_REQ=>RBR_REQ=>SNP_RESP=>MRD_REQ=>STR_REQ=>DTR_REQ);
         bins TXN_PATH_17[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>MRD_REQ=>RBR_RSP=>DTR_REQ);
         bins TXN_PATH_18[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>MRD_REQ=>DTR_REQ=>RBR_RSP);
         bins TXN_PATH_19[] = (CMD_REQ=>SNP_REQ=>RBR_REQ=>SNP_RESP=>STR_REQ=>MRD_REQ=>RBR_RSP=>DTR_REQ);
         bins TXN_PATH_20[] = (CMD_REQ=>SNP_REQ=>RBR_REQ=>SNP_RESP=>STR_REQ=>MRD_REQ=>DTR_REQ);
         bins TXN_PATH_21[] = (CMD_REQ=>SNP_REQ=>RBR_REQ=>SNP_RESP=>STR_REQ=>MRD_REQ=>DTR_REQ=>RBR_RSP);
         //COV_EXCL: Okay to exclude because other variation is hit
         //bins TXN_PATH_22[] = (CMD_REQ=>SNP_REQ=>SNP_RESP=>RBR_REQ=>STR_REQ=>SNP_REQ=>SNP_RESP=>MRD_REQ=>RBR_RSP=>DTR_REQ);
         bins TXN_PATH_23[] = (CMD_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>MRD_REQ=>RBR_RSP=>DTR_REQ);
         bins TXN_PATH_24[] = (CMD_REQ=> STR_REQ=>CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>MRD_REQ=>DTR_REQ);
         //These bins were added from NCore sysArch diagrams.
         //non-coh atomic
         bins TXN_PATH_25[] = (CMD_REQ=>STR_REQ=>DTW_REQ=>DTR_REQ);
         //Read with snoop data
         bins TXN_PATH_26[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTR_REQ=>SNP_RESP=>STR_REQ=>RBR_RSP);
         bins TXN_PATH_27[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTR_REQ=>SNP_RESP=>STR_REQ);
         bins TXN_PATH_28[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>DTR_REQ=>STR_REQ=>RBR_RSP);
         bins TXN_PATH_29[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>DTR_REQ=>STR_REQ);
         //Read with DMI data & Read with no snoops
         bins TXN_PATH_30[] = (CMD_REQ=>MRD_REQ=>STR_REQ=>DTR_REQ);
         bins TXN_PATH_31[] = (CMD_REQ=>STR_REQ=>MRD_REQ=>DTR_REQ);
         //Read clean with snoop data
         bins TXN_PATH_32[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTR_REQ=>DTW_REQ=>RBR_RSP=>SNP_RESP=>STR_REQ);
         //Clean with dirty snoop data
         bins TXN_PATH_33[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>RBR_RSP=>SNP_RESP=>MRD_REQ=>STR_REQ);
         //Read when owner in unique partial state
         //COV_EXCL: Okay to exclude because other variation is hit
         //bins TXN_PATH_34[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>RBR_RSP=>SNP_RESP=>DTR_REQ=>STR_REQ);
         bins TXN_PATH_35[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>RBR_RSP=>SNP_RESP=>STR_REQ=>DTR_REQ);
         //COV_EXCL: Okay to exclude because other variation is hit
         //bins TXN_PATH_36[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>SNP_RESP=>RBR_RSP=>DTR_REQ=>STR_REQ);
         //COV_EXCL: Okay to exclude because other variation is hit
         //bins TXN_PATH_37[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>SNP_RESP=>RBR_RSP=>STR_REQ=>DTR_REQ);
         //Write unique transaction flow
         bins TXN_PATH_38[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>SNP_RESP=>STR_REQ=>DTW_REQ=>RBR_RSP);
         bins TXN_PATH_39[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>SNP_RESP=>STR_REQ=>DTW_REQ);
         //CHI coherent write txn flow
         bins TXN_PATH_40[] = (CMD_REQ=>RBR_REQ=>STR_REQ=>DTW_REQ);
         //ACE writeback txn flow
         //TODO: Add UpdReq
         //Coherent atomic
         bins TXN_PATH_41[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>RBR_RSP=>SNP_RESP=>STR_REQ=>CMD_REQ=>STR_REQ=>DTW_REQ=>DTR_REQ);
         bins TXN_PATH_42[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>RBR_RSP=>SNP_RESP=>STR_REQ=>CMD_REQ=>STR_REQ=>DTW_REQ);
         //Write stash full accept txn flow
         bins TXN_PATH_43[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>DTR_REQ);
         //Write stash partial accept flow - TODO: RBR_REQ could occur later, after first SNP_RSP: CONC-13156
         bins TXN_PATH_44[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>SNP_RESP=>STR_REQ=>DTW_REQ=>RBR_RSP=>DTR_REQ);
         bins TXN_PATH_44_1[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>DTW_REQ=>RBR_RSP=>DTR_REQ);
         //Read stash declide flow
         bins TXN_PATH_45[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ);
         //Read stash target not identified
         bins TXN_PATH_46[] = (CMD_REQ=>MRD_REQ=>STR_REQ);
         //Read stash accept flow - TODO: RBR_REQ could occur later, after first SNP_RSP: CONC-13227
         //While CONC-13227 is open and waiting for Arch response, updating bin according to observed TXN path from a test run
         //[FSYS_TXN_PATH] FSYS_UID:618 NCore Transaction Path: CMD_REQ ->  SNP_REQ ->  SNP_RESP ->  STR_REQ ->  RBR_REQ ->  SNP_REQ ->  DTW_REQ ->  RBR_RSP ->  SNP_RESP ->  MRD_REQ ->  DTR_REQ.
         bins TXN_PATH_47[] = (CMD_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>RBR_RSP=>SNP_RESP=>MRD_REQ=>DTR_REQ);
         //bins TXN_PATH_47[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>SNP_REQ=>DTW_REQ=>SNP_RESP=>MRD_REQ=>DTR_REQ);
         //Read stash accept - only stash target snoop
         bins TXN_PATH_48[] = (CMD_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>MRD_REQ=>DTR_REQ);
         //IOAIUp write transaction flow
         bins TXN_PATH_49[] = (CMD_REQ=>STR_REQ=>SNP_REQ=>SNP_RESP=>CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>CMD_REQ=>STR_REQ=>DTW_REQ);
         bins TXN_PATH_50[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>CMD_REQ=>STR_REQ=>DTW_REQ);
         bins TXN_PATH_51[] = (CMD_REQ=>STR_REQ=>CMD_REQ=>STR_REQ=>DTW_REQ);
         bins TXN_PATH_52[] = (CMD_REQ=>RBR_REQ=>SNP_REQ=>SNP_RESP=>STR_REQ=>RBR_RSP=>SNP_REQ=>SNP_RESP=>CMD_REQ=>RBR_REQ=>SNP_REQ=>DTW_REQ=>RBR_RSP=>SNP_RESP=>STR_REQ=>CMD_REQ=>STR_REQ=>DTW_REQ);
      }
      single_transition : coverpoint msg
      {
         bins transition_from_CMD_REQ[] = (CMD_REQ => STR_REQ, RBR_REQ, SNP_REQ);
         bins transition_from_STR_REQ[] = (STR_REQ => CMD_REQ, RBR_REQ, RBR_RSP, DTW_REQ, DTR_REQ);
         bins transition_from_RBR_REQ[] = (RBR_REQ => STR_REQ, DTW_REQ, DTR_REQ, SNP_REQ, SNP_RESP);
         bins transition_from_RBR_RSP[] = (RBR_RSP => CMD_REQ, STR_REQ, DTR_REQ, SNP_RESP);
         bins transition_from_DTW_REQ[] = (DTW_REQ => CMD_REQ, RBR_RSP, DTR_REQ, SNP_RESP);
         bins transition_from_DTR_REQ[] = (DTR_REQ => CMD_REQ, STR_REQ, RBR_RSP, DTW_REQ, SNP_RESP);
         bins transition_from_SNP_REQ[] = (SNP_REQ => RBR_REQ, DTW_REQ, DTR_REQ, SNP_RESP);
         bins transition_from_SNP_RESP[] = (SNP_RESP => STR_REQ, RBR_RSP, DTR_REQ);
      }
   endgroup
   covergroup transaction_count;
      num_trans : coverpoint aiu
      {
         bins ioaiu_trans = {1};
         bins chiaiu_trans = {0};
      }
   endgroup

    function new(); 
       `uvm_info("fsys_txn_path_coverage::new",$psprintf(""),UVM_LOW)
       TXN_PATH = new();
       transaction_count = new();
    endfunction:new

   /////////////////////////////////////////////////////////////////////////////////////
   //
   // Function: sample_txn
   // Description : Goes through msg_order_q and calls sample on TXN_PATH covergroup
   //
   /////////////////////////////////////////////////////////////////////////////////////
    function sample_txn(input smi_msgs_t msg_order_q[$], bit aiu);
       int size = msg_order_q.size();
       for (int idx=0; idx < size; idx++) begin
          msg = msg_order_q[idx];
          TXN_PATH.sample();
       end // for loop
       this.aiu = aiu;
       transaction_count.sample();
    endfunction : sample_txn
endclass : fsys_txn_path_coverage

`endif // `ifdef FSYS_SCB_COVER_ON              

