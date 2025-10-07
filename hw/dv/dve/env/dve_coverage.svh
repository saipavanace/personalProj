covergroup dve_SnpsEnb_cg with function sample(bit SnpsEnb_b); 


  cp_SnpsEnb : coverpoint SnpsEnb_b {

    bins SnpsEnb_en = {1};

  }

endgroup : dve_SnpsEnb_cg

<% // some trace memories don't have error injection functions
  var tacc_ecc = 0;
  //console.log(obj.DveInfo[0].MemoryGeneration.traceMem);
  if(obj.DveInfo[0].assertOn == 1) {
     for(var i = 0; i < obj.DveInfo[0].MemoryGeneration.traceMem.length; i++) {
        var name = obj.DveInfo[0].MemoryGeneration.traceMem[i].rtlPrefixString;
        var type = obj.DveInfo[0].MemoryGeneration.traceMem[i].MemType;
        if(type == "NONE") { 
          tacc_ecc = 1;
        }
     }
  }
%>


<% 
let Dvm_NUnitIds = [] ;
for (const o of obj.AiuInfo) {
    if(o.cmpInfo.nDvmSnpInFlight > 0) {
        Dvm_NUnitIds.push(o.nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}

var dvmUnitId_Size0;
var dvmUnitId_Size1;
var dvmUnitId_Size2;
var dvmUnitId_Size3;
dvmUnitId_Size0 = 0;
dvmUnitId_Size1 = 0;
dvmUnitId_Size2 = 0;
dvmUnitId_Size3 = 0;
for(i in Dvm_NUnitIds) {
   if(Dvm_NUnitIds[i] > 95) { dvmUnitId_Size3=dvmUnitId_Size3+1; }
   else if(Dvm_NUnitIds[i] > 63) { dvmUnitId_Size2=dvmUnitId_Size2+1; }
   else if(Dvm_NUnitIds[i] > 31) { dvmUnitId_Size1=dvmUnitId_Size1+1; }
   else {  dvmUnitId_Size0=dvmUnitId_Size0+1; }
}

var dvm_agent = Dvm_NUnitIds.length  
%>
class dve_coverage;
    smi_msg_type_bit_t smi_msg_type;
    bit                rd_after_rd;
    bit                rd_after_wr;
    bit                wr_after_rd;
    bit                wr_after_wr;
    bit                cm_after_wr;
    bit                wr_after_cm;
    bit                cm_after_rd;
    bit                rd_after_cm;
    bit                smi_addr_match;
    bit                prev_msg_rd = 0;
    bit                prev_msg_wr = 0;
    bit                prev_msg_cm = 0;
    bit                cmeRspRcvd;
    bit                treRspRcvd;
    int cmd_i = 0 ;
    int dtw_i = 0 ;
    bit                snpreq_active;
    bit                snpreq_order;
    bit                snpreq_order_sync_op;
    bit                snpreq_1_2_same_agt;
    bit                snprsp_order;
    bit                credit_alloc;
    bit                credit_dealloc;
    bit                cmprsp_gen;
    bit                STTID_max_range;
    bit                STTID_snp_msg_id;
    bit [6:0]          snprsp_first_err;
    smi_ncore_unit_id_bit_t endpoint_id;
    //bit [3:0] beat_num; //NOTE: max beats supported (in AXI) are 16 (as discussed with Eric)
    time t_cmdReq, t_cmdRsp;
    time t_strReq, t_strRsp;
    time t_dtwReq, t_dtwRsp;
    enum {order_req0, order_req1, order_req_ep, order_wr_obs} order_request_type;
    bit order_ep = 0;
    bit ep_bndy_top_new = 0;
    bit ep_bndy_top_old = 0;
    bit ep_bndy_bottom_new = 0;
    bit ep_bndy_bottom_old = 0;
    enum {r_r, r_w, w_r, w_w, r_c, c_r, w_c, c_w} access_seq;
    enum {Cmd, CmdRsp, Str, StrRsp, Dtw, DtwRsp, DtwDbg, DtwDbgRsp, Snp, SnpRsp,CmpRsp} concerto_msg_class;
    enum {cmdReq_cmdRsp_strReq_strRsp_dtrReq_dtrRsp,
          cmdReq_cmdRsp_strReq_dtrReq_dtrRsp_strRsp,
          cmdReq_cmdRsp_strReq_dtrReq_strRsp_dtrRsp,
          cmdReq_strReq_cmdRsp_strRsp_dtrReq_dtrRsp,
          cmdReq_strReq_cmdRsp_dtrReq_strRsp_dtrRsp,
          cmdReq_strReq_cmdRsp_dtrReq_dtrRsp_strRsp,
          cmdReq_strReq_dtrReq_cmdRsp_strRsp_dtrRsp,
          cmdReq_strReq_dtrReq_cmdRsp_dtrRsp_strRsp,
          cmdReq_strReq_dtrReq_strRsp_cmdRsp_dtrRsp,
          cmdReq_strReq_dtrReq_strRsp_dtrRsp_cmdRsp,
          cmdReq_strReq_dtrReq_dtrRsp_cmdRsp_strRsp,
          cmdReq_strReq_dtrReq_dtrRsp_strRsp_cmdRsp,
          cmdReq_cmdRsp_strReq_strRsp_dtwReq_dtwRsp,
          cmdReq_cmdRsp_strReq_dtwReq_dtwRsp_strRsp,
          cmdReq_cmdRsp_strReq_dtwReq_strRsp_dtwRsp,
          cmdReq_strReq_cmdRsp_strRsp_dtwReq_dtwRsp,
          cmdReq_strReq_cmdRsp_dtwReq_strRsp_dtwRsp,
          cmdReq_strReq_cmdRsp_dtwReq_dtwRsp_strRsp,
          cmdReq_strReq_dtwReq_cmdRsp_strRsp_dtwRsp,
          cmdReq_strReq_dtwReq_cmdRsp_dtwRsp_strRsp,
          cmdReq_strReq_dtwReq_strRsp_cmdRsp_dtwRsp,
          cmdReq_strReq_dtwReq_strRsp_dtwRsp_cmdRsp,
          cmdReq_strReq_dtwReq_dtwRsp_cmdRsp_strRsp,
          cmdReq_strReq_dtwReq_dtwRsp_strRsp_cmdRsp,
          dtwDbgReq_dtwDbgRsp
          } dve_txn_states;
    enum {cmdReq_with_dtwReq,
          cmdReq_with_dtrReq,
          cmdReq_with_dtwRsq,
          cmdReq_with_dtrRsq,
          cmdReq_with_strRsq,
          cmdReq_with_cmdRsq,
          cmdReq_with_strReq,
          strReq_with_dtwReq,
          strReq_with_dtrReq,
          strReq_with_dtwRsp,
          strReq_with_dtrRsp,
          strReq_with_strRsp,
          strReq_with_cmdRsp,
          dtrReq_with_dtwRsp,
          dtrReq_with_dtrRsp,
          dtrReq_with_strRsp,
          dtrReq_with_cmdRsp,
          dtrReq_with_dtwReq,
          dtwReq_with_dtwRsp,
          dtwReq_with_dtrRsp,
          dtwReq_with_strRsp,
          dtwReq_with_cmdRsp,
          dtwRsp_with_dtrRsp,
          dtwRsp_with_strRsp,
          cmdRsp_with_dtrRsp,
          cmdRsp_with_strRsp} two_msg_in_same_cycle;
    enum {strReq_with_dtrReq_same_txn,
          strReq_with_cmdRsp_same_txn,
          strReq_with_dtrRsp_same_txn,
          dtrReq_with_cmdRsp_same_txn,
          dtrReq_with_strRsp_same_txn,
          dtwReq_with_cmdRsp_same_txn,
          cmdRsp_with_dtrRsp_same_txn,
          cmdRsp_with_strRsp_same_txn,
          strRsp_with_dtwRsp_same_txn} two_msg_same_txn_same_cycle;
    enum {strReq_treRsp, dtrReq_treRsp} treRsp_positions;
    enum {strReq_cmeRsp, dtrReq_cmeRsp, cmdReq_cmeRsp, dtwReq_cmeRsp} cmeRsp_positions;
    // DtwDbg buffer state
    bit empty, full, circular, dropping;
    /// DtwDbg timestamp info
    bit [31:0] timestamp, prev_timestamp;
    bit timestamp_rollover;
    bit [7:0] correction;
<% if(tacc_ecc) { %>
    // DtwDbg ECC errors
    bit correctible, uncorrectible;
<% } %>
    // DtwDbg buffer clearing
    //bit buffer_cleared;
    enum int {RBID_state_idle,same_RBID,not_same_RBID}   RBID_state;
    enum int {smi_req_idle,cmdReq_dtwReq,dtwReq_cmdReq}  smi_req_positions;
    enum int {strRq_idle_state,strRq_with_correct_allocated_STTID_and_RBID,strRq_with_wrong_allocated_STTID_and_RBID} strRq_gen;
    enum int {CmdReq_idle,CmdReq_Sync,CmdReq_NoSync} CmdReq_type;
    enum bit {idle_dvmOps_same_test,mix_noSync_Sync} dvmOps_in_same_test;
    enum int {idle_dvmRq_order,dvmRq_in_order,dvmRq_out_of_order} dvmRq_order;
    enum bit {idle_DVM_bypass,DVM_NonSync_bypass_DVM_sync} DVM_bypass;
/////////////////////////////////// Error handling coverage //////////////////////
  enum int {idle,no_snoop,CMprsp_error} drop_bad_dvm_msg;
  enum int {idle_drop,drop_cmdreq_trspt_err,drop_dtwreq_trspt_err,drop_snprsp_trspt_err} drop_transport_error_dvm_msg;
  enum int {drop_trans_state_idle,trans_droped,trans_not_droped}   wrong_target_id;
typedef enum {cmstatus_no_err,cmstatus_err,cmstatus_idle} msg_cmstatus;
msg_cmstatus cmdReq_cmstatus,cmdRsp_cmstatus,dtwReq_cmstatus,dtwRsp_cmstatus,snpReq_cmstatus,snpRsp_cmstatus,sysReq_cmstatus;

   typedef enum {sysreq_idle, sysreq_active} dve_sysreq_pkt;
   dve_sysreq_pkt SysReqAttach_from_attached, SysReqAttach_from_detached, SysReqDetach_from_attached, SysReqDetach_from_detached, SysReqAttach_while_active, SysReqDetach_while_active;

covergroup msg_cmstatus_error;

  cmdReq_cmstatus_cp : coverpoint cmdReq_cmstatus {
    bins        cmstatus_no_err_cp = {cmstatus_no_err};
    bins        cmstatus_err_cp    = {cmstatus_err};
    ignore_bins cmstatus_idle      = {cmstatus_idle};
  }

  cmdRsp_cmstatus_cp : coverpoint cmdRsp_cmstatus {
    bins        cmstatus_no_err_cp = {cmstatus_no_err};
    bins        cmstatus_err_cp    = {cmstatus_err};
    ignore_bins cmstatus_idle      = {cmstatus_idle};

  }
    dtwReq_cmstatus_cp : coverpoint dtwReq_cmstatus {
    bins        cmstatus_no_err_cp = {cmstatus_no_err};
    bins        cmstatus_err_cp    = {cmstatus_err};
    ignore_bins cmstatus_idle      = {cmstatus_idle};

  }

  snpRsp_cmstatus_cp : coverpoint snpRsp_cmstatus {
    bins        cmstatus_no_err_cp = {cmstatus_no_err};
    bins        cmstatus_err_cp    = {cmstatus_err};
    ignore_bins cmstatus_idle      = {cmstatus_idle};
  }

  dtwRsp_cmstatus_cp : coverpoint dtwRsp_cmstatus {
    bins          cmstatus_no_err_cp = {cmstatus_no_err};
    illegal_bins  cmstatus_err_cp    = {cmstatus_err};
    ignore_bins   cmstatus_idle      = {cmstatus_idle};
  }

  snpReq_cmstatus_cp : coverpoint snpReq_cmstatus {
    bins          cmstatus_no_err_cp = {cmstatus_no_err};
    illegal_bins  cmstatus_err_cp    = {cmstatus_err};
    ignore_bins   cmstatus_idle      = {cmstatus_idle};
  }

  sysReq_cmstatus_cp : coverpoint sysReq_cmstatus {
    bins        cmstatus_no_err_cp = {cmstatus_no_err};
    bins        cmstatus_err_cp    = {cmstatus_err};
    ignore_bins cmstatus_idle      = {cmstatus_idle};
  }

  endgroup
  
covergroup dve_sysreq;

  // #Cover.DVE.SysCo.AttachRedundant
  SysReqAttach_from_attached_cp : coverpoint SysReqAttach_from_attached {
    ignore_bins sysreq_active_cp = {sysreq_active};
    ignore_bins sysreq_idle      = {sysreq_idle};
  }

  // #Cover.DVE.SysCo.Attach
  SysReqAttach_from_detached_cp : coverpoint SysReqAttach_from_detached {
    bins        sysreq_active_cp = {sysreq_active};
    ignore_bins sysreq_idle      = {sysreq_idle};
  }

  // #Cover.DVE.SysCo.Detach
  SysReqDetach_from_attached_cp : coverpoint SysReqDetach_from_attached {
    bins        sysreq_active_cp = {sysreq_active};
    ignore_bins sysreq_idle      = {sysreq_idle};
  }

  // #Cover.DVE.SysCo.DetachRedundant
  SysReqDetach_from_detached_cp : coverpoint SysReqDetach_from_detached {
    ignore_bins sysreq_active_cp = {sysreq_active};
    ignore_bins sysreq_idle      = {sysreq_idle};
  }

  // #Cover.DVE.SysCo.AttachPending
  SysReqAttach_while_active_cp : coverpoint SysReqAttach_while_active {
    bins        sysreq_active_cp = {sysreq_active};
    ignore_bins sysreq_idle      = {sysreq_idle};
  }

  // #Cover.DVE.SysCo.DetachPending
  SysReqDetach_while_active_cp : coverpoint SysReqDetach_while_active {
    bins        sysreq_active_cp = {sysreq_active};
    ignore_bins sysreq_idle      = {sysreq_idle};
  }

  endgroup


covergroup drop_dtw_msg;


    drop_dtw_msg_cp : coverpoint drop_bad_dvm_msg {
    bins no_snoop_bins        = {no_snoop};
    bins CMprsp_error_bins    = {CMprsp_error};
    ignore_bins idle_bins     ={idle};

  }
  endgroup

  covergroup drop_transport_err_dvm_msg_cg;
    drop_transport_err_dvm_msg_cg_cp : coverpoint drop_transport_error_dvm_msg {
    bins drop_cmdreq_trspt_err_bins        = {drop_cmdreq_trspt_err};  
    bins drop_dtwreq_trspt_err_bins        = {drop_dtwreq_trspt_err};
    bins drop_snprsp_trspt_err_bins        = {drop_snprsp_trspt_err};
    ignore_bins idle_drop_bins     ={idle_drop};
  }
  endgroup

  covergroup wrong_target_id_cg;


    wrong_target_id_cp : coverpoint wrong_target_id {
    bins         trans_droped_bins       = {trans_droped};
    illegal_bins trans_not_droped_bins   = {trans_not_droped};
    ignore_bins  idle_bins               ={drop_trans_state_idle};

  }

  endgroup

  covergroup SNPrsp_first_error_cg;
    //only first received error in SNPrsp is captured
    SNPrsp_first_error_cp : coverpoint snprsp_first_err {
    // these bins correspond to stimulus in dve_cntr::construct_snp_rsp_pkt()
    bins   snprsp_first_err_bins[]     = {7'h02, 7'h03, 7'h04, 7'h05, 7'h06, 7'h07, 7'h20, 7'h25, 7'h26};
  }

  endgroup


//////////////////////////////////////////////////////////////////////////////////
// COVERPOINTS ON CONCERTO MESSAGES
///////////////////////////////////////////////////////////////////////////////////
covergroup snoop_manager;

  snpreq_to_actif_agent: coverpoint snpreq_active {
     bins snpreq_active_bins   =  {1};
  }

  snpreq_send_order: coverpoint snpreq_order {
    //the 2xSnpReq are sent in order
     bins snpreq_order_bins   =  {1};
  }

  snpreq_send_order_sync_op: coverpoint snpreq_order_sync_op {
    //SnpReq is sent with respect to the received CmdReq for Sync Op
     bins snpreq_order_sync_op_bins   =  {1};
  }

  snpreq_1_2_to_same_agent: coverpoint snpreq_1_2_same_agt {
     bins snpreq_1_2_same_agt_bins   =  {1};
  }

 snoop_credit_alloc: coverpoint credit_alloc {
     bins credit_alloc_bins   =  {1};
  }

 snoop_credit_dealloc: coverpoint credit_dealloc {
     bins credit_dealloc_bins   =  {1};
  }

 //snoop_credit_alloc_dealloc: cross snoop_credit_alloc,snoop_credit_dealloc;



  cmprsp_genneration: coverpoint cmprsp_gen {
     bins cmprsp_gen_bins   =  {1};
  }

  sttid_max_range: coverpoint STTID_max_range {
     bins STTID_max_range_bins   =  {1};
  }

  sttid_snp_msg_id: coverpoint STTID_snp_msg_id {
     bins STTID_snp_msg_id_bins   =  {1};
  }
  

endgroup:snoop_manager

    covergroup concerto_messages;
        
        // #Cover.DII.Concerto.valid_sequence
        seq_of_transitions: coverpoint dve_txn_states {
            bins cp_cmdReq_cmdRsp_strReq_strRsp_dtrReq_dtrRsp = {0};
            bins cp_cmdReq_cmdRsp_strReq_dtrReq_dtrRsp_strRsp = {1};
            bins cp_cmdReq_cmdRsp_strReq_dtrReq_strRsp_dtrRsp = {2};
            bins cp_cmdReq_strReq_cmdRsp_strRsp_dtrReq_dtrRsp = {3};
            bins cp_cmdReq_strReq_cmdRsp_dtrReq_strRsp_dtrRsp = {4};
            bins cp_cmdReq_strReq_cmdRsp_dtrReq_dtrRsp_strRsp = {5};
            bins cp_cmdReq_strReq_dtrReq_cmdRsp_strRsp_dtrRsp = {6};
            bins cp_cmdReq_strReq_dtrReq_cmdRsp_dtrRsp_strRsp = {7};
            bins cp_cmdReq_strReq_dtrReq_strRsp_cmdRsp_dtrRsp = {8};
            bins cp_cmdReq_strReq_dtrReq_strRsp_dtrRsp_cmdRsp = {9};
            bins cp_cmdReq_strReq_dtrReq_dtrRsp_cmdRsp_strRsp = {10};
            bins cp_cmdReq_strReq_dtrReq_dtrRsp_strRsp_cmdRsp = {11};
            bins cp_cmdReq_cmdRsp_strReq_strRsp_dtwReq_dtwRsp = {12};
            bins cp_cmdReq_cmdRsp_strReq_dtwReq_dtwRsp_strRsp = {13};
            bins cp_cmdReq_cmdRsp_strReq_dtwReq_strRsp_dtwRsp = {14};
            bins cp_cmdReq_strReq_cmdRsp_strRsp_dtwReq_dtwRsp = {15};
            bins cp_cmdReq_strReq_cmdRsp_dtwReq_strRsp_dtwRsp = {16};
            bins cp_cmdReq_strReq_cmdRsp_dtwReq_dtwRsp_strRsp = {17};
            bins cp_cmdReq_strReq_dtwReq_cmdRsp_strRsp_dtwRsp = {18};
            bins cp_cmdReq_strReq_dtwReq_cmdRsp_dtwRsp_strRsp = {19};
            bins cp_cmdReq_strReq_dtwReq_strRsp_cmdRsp_dtwRsp = {20};
            bins cp_cmdReq_strReq_dtwReq_strRsp_dtwRsp_cmdRsp = {21};
            bins cp_cmdReq_strReq_dtwReq_dtwRsp_cmdRsp_strRsp = {22};
            bins cp_cmdReq_strReq_dtwReq_dtwRsp_strRsp_cmdRsp = {23};
            bins cp_dtwDbgReq_dtwDbgRsp = {24};
        }
        // #CoverTime.DII.concerto.each_two_msg_same_cycle
        // Review once updated in testplan
        each_two_msg_during_same_cycle: coverpoint two_msg_in_same_cycle {
            bins cp_cmdReq_with_dtwReq = {0};
            bins cp_cmdReq_with_dtrReq = {1};
            bins cp_cmdReq_with_dtwRsp = {2};
            bins cp_cmdReq_with_dtrRsp = {3};
            bins cp_cmdReq_with_strRsp = {4};
            bins cp_cmdReq_with_cmdRsp = {5};
            bins cp_cmdReq_with_strReq = {6};
            bins cp_strReq_with_dtwReq = {7};
            bins cp_strReq_with_dtrReq = {8};
            bins cp_strReq_with_dtwRsp = {9};
            bins cp_strReq_with_dtrRsp = {10};
            bins cp_strReq_with_strRsp = {11};
            bins cp_strReq_with_cmdRsp = {12};
            bins cp_dtrReq_with_dtwRsp = {13};
            bins cp_dtrReq_with_dtrRsp = {14};
            bins cp_dtrReq_with_strRsp = {15};
            bins cp_dtrReq_with_cmdRsp = {16};
            bins cp_dtrReq_with_dtwReq = {17};
            bins cp_dtwReq_with_dtwRsp = {18};
            bins cp_dtwReq_with_dtrRsp = {19};
            bins cp_dtwReq_with_strRsp = {20};
            bins cp_dtwReq_with_cmdRsp = {21};
            bins cp_dtwRsp_with_dtrRsp = {22};
            bins cp_dtwRsp_with_strRsp = {23};
            bins cp_cmdRsp_with_dtrRsp = {24};
            bins cp_cmdRsp_with_strRsp = {25};
        }
        // #CoverTime.DII.concerto.each_two_msg_same_txn_same_cycle
        each_two_msg_same_txn_same_cycle: coverpoint two_msg_same_txn_same_cycle {
            bins cp_strReq_with_dtrReq_same_txn = {0};
            bins cp_strReq_with_cmdRsp_same_txn = {1};
            bins cp_strReq_with_dtrRsp_same_txn = {2};
            bins cp_dtrReq_with_cmdRsp_same_txn = {3};
            bins cp_dtrReq_with_strRsp_same_txn = {4};
            bins cp_dtwReq_with_cmdRsp_same_txn = {5};
            bins cp_cmdRsp_with_dtrRsp_same_txn = {6};
            bins cp_cmdRsp_with_strRsp_same_txn = {7};
            bins cp_strRsp_with_dtwRsp_same_txn = {8};
        }
        // #Cover.DII.concerto.treRsp_each_position
        treRsp_at_each_position: coverpoint treRsp_positions iff (treRspRcvd) {
            bins treRsp_after_dtrReq = {dtrReq_treRsp};
            bins treRsp_after_strReq = {strReq_treRsp};
        }
        // #Cover.DII.concerto.cmeRsp_each_position
        cmeRsp_at_each_position: coverpoint cmeRsp_positions iff (cmeRspRcvd) {
            bins cmeRsp_after_strReq = {strReq_cmeRsp};
            bins cmeRsp_after_dtrReq = {dtrReq_cmeRsp};
            bins cmeRsp_after_dtwReq = {dtwReq_cmeRsp};
            bins cmeRsp_after_cmdReq = {cmdReq_cmeRsp};
        }
    endgroup

    covergroup smi_cmd_seq;
        // #Cover.DII.concerto.all_msg_class
        all_concerto_msg_class: coverpoint concerto_msg_class {
            bins cp_Cmd      = {Cmd};
            bins cp_NcCmdRsp = {CmdRsp};
            bins cp_Str      = {Str};
            bins cp_StrRsp   = {StrRsp};
            bins cp_Dtw      = {Dtw};
            bins cp_DtwRsp   = {DtwRsp};
            bins cp_Snp      = {Snp};
            bins cp_SnpRsp   = {SnpRsp};
            bins cp_CmpRsp   = {CmpRsp};
        }

        smi_req_order : coverpoint smi_req_positions {
          illegal_bins cp_dtwReq_cmdReq = {dtwReq_cmdReq};
          bins cp_cmdReq_dtwReq = {cmdReq_dtwReq};
          ignore_bins cp_idle = {smi_req_idle};
        }
        

    endgroup

covergroup debug_buffer_state;
  // #Cover.DVE.TACC.RFull
  // #Cover.DVE.TACC.LFull
  buffer_full: coverpoint full {
    bins lfull[] = (1=>0);
    bins rfull[] = (0=>1);
  }
  // #Cover.DVE.TACC.REmpty
  // #Cover.DVE.TACC.LEmpty
  buffer_empty: coverpoint empty {
    // We know lempty happens at beginning-of-test, and also that we are bad at observing it.
    // In randoms, often it will happen before we complete first read-out, and directed tests
    // don't have coverage enabled. The testplan therefore doesn't call for coverage of this bin.
    ignore_bins lempty[] = (1=>0);
    bins rempty[] = (0=>1);
  }
  // #Cover.DVE.TACC.Circ
  buffer_circular: coverpoint circular {
    bins was_circular[] = {[0:1]};
  }
  // #Cover.DVE.TACC.Drop
  buffer_dropping: coverpoint dropping {
    bins was_dropping[] = {[0:1]};
  }
  // We cannot safely clear in randoms, and we can't
  // report coverage in directed, so this coverpoint
  // will never hit. Don't use it.
  //buffer_cleared: coverpoint buffer_cleared {
  //  bins was_cleared[] = {1};
  //}
  circ_full: cross buffer_circular, buffer_full;
  circ_empty: cross buffer_circular, buffer_empty;
  circ_dropped: cross buffer_circular, buffer_dropping;
  //circ_clear: cross buffer_circular, buffer_cleared;
endgroup: debug_buffer_state

covergroup debug_timestamp;
  // #Cover.DVE.TACC.TsRoll
  rollover: coverpoint timestamp_rollover {
    bins ts_roll[] = {[0:1]};
  }

  // #Cover.DVE.TACC.TsCorr
  correction: coverpoint correction {
    bins positive = {[8'h81:8'hfe]};
    bins negative = {[8'h01:8'h7e]};
    bins positive_saturated = {8'hff};
    bins negative_saturated = {8'h7f};
    bins zero = {8'h0, 8'h80}; // not sure 8'h80 can actually occur: it is negative zero
  }
endgroup: debug_timestamp

<% if(tacc_ecc) { %>
covergroup debug_ecc;
  // #Cover.DVE.TACC.ECCSingle
  ecc_sing: coverpoint correctible {
    bins seen[] = {1};
  }

  // #Cover.DVE.TACC.ECCDouble
  ecc_doub: coverpoint uncorrectible {
    bins seen[] = {1};
  }
endgroup: debug_ecc
<% } %>

    covergroup dve_input_manager;
    
    cp_RBID_state : coverpoint RBID_state {

      ignore_bins  RBID_state_idle_bins       = {RBID_state_idle};   
      illegal_bins not_same_RBID_bins         = {not_same_RBID};
      bins         same_RBID_bins             = {same_RBID};

    }

    cp_StrRq_gen : coverpoint strRq_gen {

      ignore_bins  cp_strRq_idle_state                                  = {strRq_idle_state};   
      illegal_bins cp_strRq_with_wrong_allocated_STTID_and_RBID         = {strRq_with_wrong_allocated_STTID_and_RBID};
      bins         cp_strRq_with_correct_allocated_STTID_and_RBID       = {strRq_with_correct_allocated_STTID_and_RBID};

    }
    
    cp_CmdReq_type : coverpoint CmdReq_type {

      ignore_bins  cp_CmdReq_idle     = {CmdReq_idle};   
      bins         cp_CmdReq_Sync     = {CmdReq_Sync};
      bins         cp_CmdReq_NoSync   = {CmdReq_NoSync};

    }

    
    cp_dvmRq_order : coverpoint dvmRq_order {

      ignore_bins  cp_idle_dvmRq_order    = {idle_dvmRq_order};   
      illegal_bins cp_dvmRq_out_of_order  = {dvmRq_out_of_order};
      bins         cp_dvmRq_in_order      = {dvmRq_in_order};

    }

    cp_DVM_bypass : coverpoint DVM_bypass {

      ignore_bins  cp_idle_DVM_bypass              = {idle_DVM_bypass};   
      bins         cp_DVM_NonSync_bypass_DVM_sync  = {DVM_NonSync_bypass_DVM_sync};

    }
    endgroup : dve_input_manager

    
    

    covergroup dve_dvmOps_type;
      cp_dvmOps_in_same_test : coverpoint dvmOps_in_same_test {

        ignore_bins  cp_idle_dvmOps_same_test      = {idle_dvmOps_same_test};   
        bins         cp_mix_noSync_Sync            = {mix_noSync_Sync};
      }
    
    endgroup : dve_dvmOps_type

    extern function void collect_smi_seq(smi_seq_item txn);
    extern function void collect_dve_debug_txn(dve_debug_txn txn);
    extern function void collect_dve_ecc(bit correctible, bit uncorrectible);
    extern function void collect_dve_input_manager(int RBID_state,int strRq_gen,int CmdReq_type,int dvmRq_order,bit DVM_bypass);
    extern function void collect_dve_dvmOps_type(bit sync, bit no_sync);
    extern function new();
    extern function void collect_snoop_manager (int snpreq_active ,int snpreq_order ,int snpreq_order_sync_op,int snpreq_1_2_same_agt ,int credit_dealloc ,int credit_alloc,int STTID_max_range,int STTID_snp_msg_id);
    extern function void collect_cmprsp(int cmprsp_gen);
    extern function void collect_drop_dtw_msg (int drop_bad_dvm_msg);
    extern function void collect_drop_transport_error_dvm_msg (int drop_transport_error_dvm_msg);
    extern function void collect_wrong_target_id (int wrong_target_id);
    extern function void collect_SNPrsp_first_error (int snprsp_first_err);
    extern function void collect_msg_cmstatus_error (int cmdReq_cmstatus,int cmdRsp_cmstatus,int dtwReq_cmstatus,int dtwRsp_cmstatus,int snpReq_cmstatus,int snpRsp_cmstatus,int sysReq_cmstatus);
    extern function void collect_dve_sysreq (int SysReqAttach_from_attached,int SysReqAttach_from_detached,int SysReqDetach_from_attached,int SysReqDetach_from_detached,int SysReqAttach_while_active,int SysReqDetach_while_active);
endclass: dve_coverage

function void dve_coverage::collect_smi_seq(smi_seq_item txn);

    int m_tmp_addr_match_q[$];
    bit is_cmd_req,is_dtw_req; 
    smi_seq_item msg;
    msg = new();
  
    msg.copy(txn);
    if (msg.isCmdMsg()) begin
        concerto_msg_class = Cmd;
        t_cmdReq = msg.t_smi_ndp_valid;
    end
    else if (msg.isNcCmdRspMsg())
      concerto_msg_class = CmdRsp;
    else if (msg.isStrMsg())
      concerto_msg_class = Str;
    else if (msg.isStrRspMsg())
      concerto_msg_class = StrRsp;
    else if (msg.isSnpMsg())
      concerto_msg_class = Snp;
    else if (msg.isSnpRspMsg())
      concerto_msg_class = SnpRsp;
    else if (msg.isDtwMsg()) begin
      concerto_msg_class = Dtw;
      t_dtwReq = msg.t_smi_ndp_valid;
      is_dtw_req = 1;
    end
    else if (msg.isDtwRspMsg())
      concerto_msg_class = DtwRsp;
    else if (msg.isDtwDbgReqMsg())
      concerto_msg_class = DtwDbg;
    else if (msg.isDtwDbgRspMsg())
      concerto_msg_class = DtwDbgRsp;
    else if(msg.isCmpRspMsg()) 
      concerto_msg_class = CmpRsp;

    if (is_dtw_req) begin
      if (t_cmdReq <= t_dtwReq)  smi_req_positions = cmdReq_dtwReq;
      else                      smi_req_positions =  dtwReq_cmdReq;
    end
   smi_cmd_seq.sample();
  endfunction : collect_smi_seq

function void dve_coverage::collect_dve_debug_txn(dve_debug_txn txn);
  this.dropping = txn.dropping;
  this.circular = txn.circular;
  this.full = txn.full;
  this.empty = txn.empty;
  //this.buffer_cleared = txn.cleared;
  debug_buffer_state.sample();
  if(!txn.empty) begin
    this.prev_timestamp = this.timestamp;
    this.timestamp = txn.timestamp;
    this.timestamp_rollover = this.prev_timestamp[31] & ~this.timestamp[31];
    this.correction = txn.correction;
    debug_timestamp.sample();
  end
endfunction: collect_dve_debug_txn

function void dve_coverage::collect_dve_ecc(bit correctible, bit uncorrectible);
<% if(tacc_ecc) { %>
  this.correctible = correctible;
  this.uncorrectible = uncorrectible;
  debug_ecc.sample();
<% } %>
endfunction: collect_dve_ecc

// #Cover.DVE.DVM.Credits
function void dve_coverage::collect_snoop_manager (int snpreq_active ,int snpreq_order ,int snpreq_order_sync_op,int snpreq_1_2_same_agt ,int credit_dealloc ,int credit_alloc,int STTID_max_range,int STTID_snp_msg_id);
  this.snpreq_active = snpreq_active ;
  this.snpreq_order  = snpreq_order;
  this.snpreq_order_sync_op  = snpreq_order_sync_op;
  this.snpreq_1_2_same_agt = snpreq_1_2_same_agt;
  this.credit_dealloc = credit_dealloc ;
  this.credit_alloc = credit_alloc ;
  this.STTID_max_range  = STTID_max_range;
  this.STTID_snp_msg_id = STTID_snp_msg_id;
  snoop_manager.sample();
endfunction: collect_snoop_manager

function void dve_coverage::collect_cmprsp(int cmprsp_gen);
  this.cmprsp_gen  = cmprsp_gen;
  snoop_manager.sample();
endfunction: collect_cmprsp

function dve_coverage::new();
    smi_cmd_seq = new();
    debug_buffer_state = new();
    debug_timestamp = new();
<% if(tacc_ecc) { %>
    debug_ecc = new();
<% } %>
    dve_input_manager = new();
    snoop_manager = new();
    dve_dvmOps_type =new();
    drop_dtw_msg = new();
    wrong_target_id_cg = new();
    SNPrsp_first_error_cg = new();
    msg_cmstatus_error = new();
    dve_sysreq = new();
    drop_transport_err_dvm_msg_cg = new();
endfunction // new



function void dve_coverage::collect_drop_dtw_msg (int drop_bad_dvm_msg);
  $cast(this.drop_bad_dvm_msg,drop_bad_dvm_msg);
  drop_dtw_msg.sample();
endfunction:collect_drop_dtw_msg

function void dve_coverage::collect_drop_transport_error_dvm_msg (int drop_transport_error_dvm_msg);
  $cast(this.drop_transport_error_dvm_msg,drop_transport_error_dvm_msg);
  drop_transport_err_dvm_msg_cg.sample();
endfunction:collect_drop_transport_error_dvm_msg

function void dve_coverage::collect_wrong_target_id (int wrong_target_id);
  $cast(this.wrong_target_id,wrong_target_id);
  wrong_target_id_cg.sample();
endfunction:collect_wrong_target_id

function void dve_coverage::collect_SNPrsp_first_error (int snprsp_first_err);
  this.snprsp_first_err = snprsp_first_err;
  SNPrsp_first_error_cg.sample();
endfunction:collect_SNPrsp_first_error


function void dve_coverage::collect_dve_input_manager(int RBID_state,int strRq_gen,int CmdReq_type,int dvmRq_order, bit DVM_bypass);
  $cast(this.RBID_state,RBID_state);
  $cast(this.strRq_gen,strRq_gen);
  $cast(this.CmdReq_type,CmdReq_type);
  $cast(this.dvmRq_order, dvmRq_order);
  $cast(this.DVM_bypass, DVM_bypass);
  dve_input_manager.sample();
endfunction: collect_dve_input_manager
 
// #Cover.DVE.DVM.Types
function void dve_coverage::collect_dve_dvmOps_type(bit sync, bit no_sync);
  if (sync && no_sync) dvmOps_in_same_test = mix_noSync_Sync;
  dve_dvmOps_type.sample();
endfunction: collect_dve_dvmOps_type

function void dve_coverage::collect_msg_cmstatus_error(int cmdReq_cmstatus,int cmdRsp_cmstatus,int dtwReq_cmstatus,int dtwRsp_cmstatus,int snpReq_cmstatus,int snpRsp_cmstatus,int sysReq_cmstatus);
  $cast(this.cmdReq_cmstatus, cmdReq_cmstatus);
  $cast(this.cmdRsp_cmstatus, cmdRsp_cmstatus);
  $cast(this.dtwReq_cmstatus, dtwReq_cmstatus);
  $cast(this.dtwRsp_cmstatus, dtwRsp_cmstatus);
  $cast(this.snpReq_cmstatus, snpReq_cmstatus);
  $cast(this.snpRsp_cmstatus, snpRsp_cmstatus);
  $cast(this.sysReq_cmstatus, sysReq_cmstatus);
  msg_cmstatus_error.sample();
endfunction: collect_msg_cmstatus_error

function void dve_coverage::collect_dve_sysreq(int SysReqAttach_from_attached, int SysReqAttach_from_detached, int SysReqDetach_from_attached, int SysReqDetach_from_detached, int SysReqAttach_while_active, int SysReqDetach_while_active);
  $cast(this.SysReqAttach_from_attached, SysReqAttach_from_attached);
  $cast(this.SysReqAttach_from_detached, SysReqAttach_from_detached);
  $cast(this.SysReqDetach_from_attached, SysReqDetach_from_attached);
  $cast(this.SysReqDetach_from_detached, SysReqDetach_from_detached);
  $cast(this.SysReqAttach_while_active, SysReqAttach_while_active);
  $cast(this.SysReqDetach_while_active, SysReqDetach_while_active);
  dve_sysreq.sample();
endfunction: collect_dve_sysreq

class dve_coverage_reg;
 
  bit [31:0] SnpsEnb_user0 ;
  int dvmUnitId [<%=Dvm_NUnitIds.length%>];
  <% if (dvm_agent <= 32) { %>
  dve_SnpsEnb_cg SnpsEnb_cg_user0[<%=dvm_agent%>];
  int dvmUnitId0 [<%=dvmUnitId_Size0%>];
  <% } %>

  <% if ((dvm_agent > 32) && (dvm_agent <= 64)) { %>
  bit [31:0] SnpsEnb_user1 ;
  dve_SnpsEnb_cg SnpsEnb_cg_user0[32];
  dve_SnpsEnb_cg SnpsEnb_cg_user1[<%=dvm_agent%> - 32];
  int dvmUnitId0 [<%=dvmUnitId_Size0%>];
  int dvmUnitId1 [<%=dvmUnitId_Size1%>];
  <% } %>
  <% if ((dvm_agent > 64) && (dvm_agent <= 96)) { %>
  bit [31:0] SnpsEnb_user1 ;
  bit [31:0] SnpsEnb_user2 ;
  dve_SnpsEnb_cg SnpsEnb_cg_user0[32];
  dve_SnpsEnb_cg SnpsEnb_cg_user1[32];
  dve_SnpsEnb_cg SnpsEnb_cg_user2[<%=dvm_agent%> - 64];
  int dvmUnitId0 [<%=dvmUnitId_Size0%>];
  int dvmUnitId1 [<%=dvmUnitId_Size1%>];
  int dvmUnitId2 [<%=dvmUnitId_Size2%>];
  <% } %>
  <% if (dvm_agent > 96) { %>
  bit [31:0] SnpsEnb_user1 ;
  bit [31:0] SnpsEnb_user2 ;
  bit [31:0] SnpsEnb_user3 ;
  dve_SnpsEnb_cg SnpsEnb_cg_user0[32];
  dve_SnpsEnb_cg SnpsEnb_cg_user1[32];
  dve_SnpsEnb_cg SnpsEnb_cg_user2[32];
  dve_SnpsEnb_cg SnpsEnb_cg_user3[<%=dvm_agent%> - 96];
  int dvmUnitId0 [<%=dvmUnitId_Size0%>];
  int dvmUnitId1 [<%=dvmUnitId_Size1%>];
  int dvmUnitId2 [<%=dvmUnitId_Size2%>];
  int dvmUnitId3 [<%=dvmUnitId_Size3%>];
  <% } %>
  
  

  extern function void collect_dve_static_config(int SnpsEnb_reg[4]);
  extern function new();


endclass: dve_coverage_reg




function dve_coverage_reg::new();

  <% for(i in Dvm_NUnitIds) { %>
  dvmUnitId[<%=i%>] = <%=Dvm_NUnitIds[i]%>;
  <% } %>

  <% if (dvm_agent <= 32) { %>
  for (int i=0;i< <%=dvm_agent%> ;i++) begin

    SnpsEnb_cg_user0[i] = new();

  end

  for (int i=0;i< <%=dvmUnitId_Size0%> ;i++) begin

    dvmUnitId0[i] = dvmUnitId[i];

  end

  <% } %>
  //////////////////////////////////////////////////////////
  <% if ((dvm_agent > 32) && (dvm_agent <= 64)) { %>
  for (int i=0;i<32;i++) begin

    SnpsEnb_cg_user0[i] = new();

  end
  for (int i=0;i<(<%=dvm_agent%> - 32);i++) begin

    SnpsEnb_cg_user1[i] = new();

  end


  for (int i=0;i< <%=dvmUnitId_Size0%> ;i++) begin

    dvmUnitId0[i] = dvmUnitId[i];

  end


  for (int i=0;i< <%=dvmUnitId_Size1%> ;i++) begin

    dvmUnitId1[i] = dvmUnitId[i+<%=dvmUnitId_Size0%>];

  end
  <% } %>

  ////////////////////////////////////////////////////
  <% if ((dvm_agent > 64) && (dvm_agent <= 96)) { %>
  for (int i=0;i<32;i++) begin

    SnpsEnb_cg_user0[i] = new();

  end
  for (int i=0;i< 32;i++) begin

    SnpsEnb_cg_user1[i] = new();

  end

  for (int i=0;i<(<%=dvm_agent%> - 64);i++) begin

    SnpsEnb_cg_user2[i] = new();

  end

  for (int i=0;i< <%=dvmUnitId_Size0%> ;i++) begin

    dvmUnitId0[i] = dvmUnitId[i];

  end


  for (int i=0;i< <%=dvmUnitId_Size1%> ;i++) begin

    dvmUnitId1[i] = dvmUnitId[i+<%=dvmUnitId_Size0%>];

  end

  for (int i=0;i< <%=dvmUnitId_Size2%> ;i++) begin

    dvmUnitId2[i] = dvmUnitId[i+<%=dvmUnitId_Size0%>+<%=dvmUnitId_Size1%>];

  end

  <% } %>
  /////////////////////////////////////////////////////////
  <% if (dvm_agent > 96) { %>
  for (int i=0;i<32;i++) begin

    SnpsEnb_cg_user0[i] = new();

  end
  for (int i=0;i< 32;i++) begin

    SnpsEnb_cg_user1[i] = new();

  end

  for (int i=0;i<32;i++) begin

    SnpsEnb_cg_user2[i] = new();

  end

  for (int i=0;i<(<%=dvm_agent%> - 96);i++) begin

    SnpsEnb_cg_user3[i] = new();

  end

  for (int i=0;i< <%=dvmUnitId_Size0%> ;i++) begin

    dvmUnitId0[i] = dvmUnitId[i];

  end


  for (int i=0;i< <%=dvmUnitId_Size1%> ;i++) begin

    dvmUnitId1[i] = dvmUnitId[i+<%=dvmUnitId_Size0%>];

  end

  for (int i=0;i< <%=dvmUnitId_Size2%> ;i++) begin

    dvmUnitId2[i] = dvmUnitId[i+<%=dvmUnitId_Size0%>+<%=dvmUnitId_Size1%>];

  end

  for (int i=0;i< <%=dvmUnitId_Size3%> ;i++) begin

    dvmUnitId3[i] = dvmUnitId[i+<%=dvmUnitId_Size0%>+<%=dvmUnitId_Size1%>+<%=dvmUnitId_Size2%>];

  end

  <% } %>
  

endfunction // new




function void dve_coverage_reg::collect_dve_static_config(int SnpsEnb_reg[4]);


  <% if (dvm_agent <= 32) { %>
  for (int i=0;i< <%=dvm_agent%> ;i++) begin
    
    SnpsEnb_user0[i] = SnpsEnb_reg[0][dvmUnitId0[i]];
    SnpsEnb_cg_user0[i].sample(SnpsEnb_user0[i]);

  end
  <% } %>

////////////////////////////////////////////////////////
<% if ((dvm_agent > 32) && (dvm_agent <= 64)) { %>
for (int i=0;i<32;i++) begin

  SnpsEnb_user0[i] = SnpsEnb_reg[0][dvmUnitId0[i]];
  SnpsEnb_cg_user0[i].sample(SnpsEnb_user0[i]);

end

for (int i=0;i<(<%=dvm_agent%> - 32);i++) begin

  SnpsEnb_user1[i] = SnpsEnb_reg[1][dvmUnitId1[i]-32];
  SnpsEnb_cg_user1[i].sample(SnpsEnb_user1[i]);

end
<% } %>
//////////////////////////////////////////////////////
<% if ((dvm_agent > 64) && (dvm_agent <= 96 )) { %>
for (int i=0;i<32;i++) begin

  SnpsEnb_user0[i] = SnpsEnb_reg[0][dvmUnitId0[i]];
  SnpsEnb_cg_user0[i].sample(SnpsEnb_user0[i]);

end

for (int i=0;i< 32 ;i++) begin

  SnpsEnb_user1[i] = SnpsEnb_reg[1][dvmUnitId1[i]-32];
  SnpsEnb_cg_user1[i].sample(SnpsEnb_user1[i]);

end
for (int i=0;i<(<%=dvm_agent%> - 64);i++) begin

  SnpsEnb_user2[i] = SnpsEnb_reg[2][dvmUnitId2[i]-64];
  SnpsEnb_cg_user2[i].sample(SnpsEnb_user2[i]);

end
<% } %>
////////////////////////////////////////////////////////
<% if (dvm_agent > 96) { %>
for (int i=0;i<32;i++) begin

  SnpsEnb_user0[i] = SnpsEnb_reg[0][dvmUnitId0[i]];
  SnpsEnb_cg_user0[i].sample(SnpsEnb_user0[i]);

end

for (int i=0;i< 32 ;i++) begin

  SnpsEnb_user1[i] = SnpsEnb_reg[1][dvmUnitId1[i]-32];
  SnpsEnb_cg_user1[i].sample(SnpsEnb_user1[i]);

end
for (int i=0;i< 32 ;i++) begin

  SnpsEnb_user2[i] = SnpsEnb_reg[2][dvmUnitId2[i]-64];
  SnpsEnb_cg_user2[i].sample(SnpsEnb_user2[i]);

end
for (int i=0;i<(<%=dvm_agent%> - 96);i++) begin

  SnpsEnb_user3[i] = SnpsEnb_reg[3][dvmUnitId2[i]-96];
  SnpsEnb_cg_user3[i].sample(SnpsEnb_user3[i]);

end
<% } %>

endfunction: collect_dve_static_config


