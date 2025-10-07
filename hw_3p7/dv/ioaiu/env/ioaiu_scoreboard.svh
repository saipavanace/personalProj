//                                                                           // 
// File         :   ioaiu_scoreboard.sv                                      //
// Author       :   David Clarino                                            //
// Description  :   IOAIU scoreboard with support for CCP.                   //
//                                                                           //
// Revision     :                                                            //
//                                   
///////////////////////////////////////////////////////////////////////////////

/*! 
 *  \file       ioaiu_scoreboard.sv
 *  \brief      Scoreboard
 *  \details    IOAIU block level scoreboard with support for CCP
 *  \author     David Clarino
 *  \author     Hema Sajja
 *  \version    
 *  \date       2021
 *  \copyright  Arteris IP.
 */

`ifndef QUESTA
    timeunit 1ps;
    timeprecision 1ps;
`endif
<%
if (obj.useCache) {
    // CCP Tag and Data Array width
    var wDataNoProt = obj.AiuInfo[obj.Id].ccpParams.wData + 1 ; // 1bit of poison
    var wCacheline  = obj.AiuInfo[obj.Id].ccpParams.wAddr - obj.AiuInfo[obj.Id].ccpParams.wCacheLineOffset;
    var wTag        = wCacheline - obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length;
                     // Only add when replacement policy is NRU
    var wRP        = (((obj.AiuInfo[obj.Id].ccpParams.nWays > 1) && (obj.AiuInfo[obj.Id].ccpParams.RepPolicy !== 'RANDOM') && (obj.AiuInfo[obj.Id].ccpParams.nRPPorts === 1)) ? 1 : 0);
    var wTagNoProt  = wTag + obj.AiuInfo[obj.Id].ccpParams.wSecurity // TagWidth
                    + obj.AiuInfo[obj.Id].ccpParams.wStateBits // State
                    + wRP;
    var wDataProt = (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo == "PARITYENTRY" ? 1 : (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo == "SECDED" ? (Math.ceil(Math.log2(wDataNoProt + Math.ceil(Math.log2(wDataNoProt)) + 1)) + 1):0));
    var wTagProt = (obj.AiuInfo[obj.Id].ccpParams.TagErrInfo == "PARITYENTRY" ? 1 : (obj.AiuInfo[obj.Id].ccpParams.TagErrInfo == "SECDED" ? (Math.ceil(Math.log2(wTagNoProt + Math.ceil(Math.log2(wTagNoProt)) + 1)) + 1):0));

    var wDataArrayEntry = wDataNoProt + wDataProt;
    var wTagArrayEntry = wTagNoProt + wTagProt;
}

var aiu_axiInt;

if(obj.interfaces.axiInt.length > 1) {
   aiu_axiInt = obj.interfaces.axiInt[0];
} else {
   aiu_axiInt = obj.interfaces.axiInt;
}

var DVM_intf = {"ACE":"ace"};
if (obj.eAc == 1 && obj.fnNativeInterface == "ACELITE-E") DVM_intf["ACELITE-E"]="ace5_lite";
%>
<%function generateRegPath(regName, core_id) {
    if(obj.nNativeInterfacePorts > 1) {
        return 'm_regs.'+obj.strRtlNamePrefix+'_' + core_id + '.'+regName;
    } else {
        return 'm_regs.'+obj.strRtlNamePrefix+'.'+regName;
    }
}%>
typedef ace_command_types_enum_t q_of_ace_cmd_types_t[$];
typedef enum {CmdReq,
              CmdRsp,
	          CmpRsp,
              SnpReq, 
              SnpRsp, 
              SnpDtrRsp,
              DtrReq,
              DtrRsp,
              DtwReq,
              DtwRsp,
              StrReq,  
              StrRsp,  
              MntOp_Upd_Dis,
              UpdReq,
              UpdRsp,
              SnpDtwRsp,
              AceWrReq,
              AceWrData,
              AceWrRsp,
              NCWrReq,
              NCWrRsp,
              NCRdData,
              AceSnpReq,
              AceSnpRsp,
              AceSnpData,
              AceRdReq,
              AceRdData,
              IOCData,
              SfiAiuToNocReq, 
              SfiAiuToNocRsp, 
              SfiNocToAiuReq, 
              SfiNocToAiuRsp, 
              Hang,
              MultiAceRdData, 
              MultiAceWrResp,
              IOCacheEvict,
              SenderEventReq,
              RecieverEventReq,
              MntOp_IOCacheEvict
          } eSMIPktTypes;

`uvm_analysis_imp_decl(_event_sender_chnl)
`uvm_analysis_imp_decl(_event_reciever_chnl)
`uvm_analysis_imp_decl(_ncbu_read_addr_chnl)
`uvm_analysis_imp_decl(_ncbu_write_addr_chnl)
`uvm_analysis_imp_decl(_ncbu_read_data_chnl)
`uvm_analysis_imp_decl(_ncbu_read_data_chnl_every_beat)
`uvm_analysis_imp_decl(_ncbu_read_data_advance_copy_chnl)
`uvm_analysis_imp_decl(_ncbu_write_data_chnl)
`uvm_analysis_imp_decl(_ncbu_write_resp_chnl)
`uvm_analysis_imp_decl(_ncbu_write_resp_advance_copy_chnl)
`uvm_analysis_imp_decl(_rtl_probe_chnl)
`uvm_analysis_imp_decl(_ottvec_probe_chnl)
`uvm_analysis_imp_decl(_owo_chnl)
`uvm_analysis_imp_decl(_cycle_tracker_probe_chnl)
`uvm_analysis_imp_decl(_bypass_probe_chnl)
<% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.fnNativeInterface === "ACELITE-E" || obj.fnNativeInterface === "ACE-LITE") && aiu_axiInt.params.eAc==1)){ %>
    `uvm_analysis_imp_decl(_ace_snoop_addr_chnl)
    `uvm_analysis_imp_decl(_ace_snoop_resp_chnl)
    `uvm_analysis_imp_decl(_ace_snoop_data_chnl)
<% } %>

`uvm_analysis_imp_decl( _ncbu_ccp_wr_data_chnl   )
`uvm_analysis_imp_decl( _ncbu_ccp_ctrl_chnl      )
`uvm_analysis_imp_decl( _ncbu_ccp_fill_ctrl_chnl )
`uvm_analysis_imp_decl( _ncbu_ccp_fill_data_chnl )
`uvm_analysis_imp_decl( _ncbu_ccp_rd_rsp_chnl    )
`uvm_analysis_imp_decl( _ncbu_ccp_evict_chnl     )
`uvm_analysis_imp_decl(_ncbu_ccp_rtl_chnl)
`uvm_analysis_imp_decl(_ioaiu_smi_port)
`uvm_analysis_imp_decl(_ioaiu_smi_every_beat_port)
`uvm_analysis_imp_decl( _apb_chnl )

//Q-channel port
`uvm_analysis_imp_decl(_q_chnl)

//-----------------------------------------------------------------------
//
// NCBU Performance Benchmark
//
//----------------------------------------------------------------------- 

parameter NCBU_LRDREQTOCMDREQ           = 1;
parameter NCBU_LRDSTRDTRREQTOACERDRSP   = 1;
parameter NCBU_LRDRACTOSTRRSP           = 2;
parameter NCBU_LWRLNUNQWRREQTOCMDREQ    = 3;
parameter NCBU_LWRDATASTRREQTODTWREQ    = 7;
parameter NCBU_LWRLNUNQDTWRSPTOBRESP    = 2;
parameter NCBU_LWRLNUNQWACKTOSTRRSP     = 0;

parameter NCBU_RDBW                     = WXDATA/8;
parameter NCBU_WRLNUNQBW                = WXDATA/8;

//-----------------------------------------------------------------------
//
// NCBU Scoreboard
//
//----------------------------------------------------------------------- 

//----------------------------------------------------------------------- 
// Notes:
// 1) When an error starts with "SCB Error", then this error is most likely
//    a scoreboard TB error
//----------------------------------------------------------------------- 

//----------------------------------------------------------------------- 
// TODO list:
// 3)  Errors
// 7)  Txn timeout checks 
// 18) Add check to make sure RResp[3:2] is 2'b0 for non coherent accesses.
// 22) Add QOS checks(CSAS): 1) AIU should send QOS value on SMI transaction priority level
//                           2) AIU should make sure it sends the highest QOS value on the SMI qos side band signals
//                           3) SMI Hurry = 0
//----------------------------------------------------------------------- 

<%
    var aiuid, sfid, sftype, sftftype;
    var wrevict = 0;
    if(obj.Id < obj.AiuInfo.length) {
        aiuid  = obj.Id;
        var ifType = obj.AiuInfo[aiuid].fnNativeInterface;
        if (((ifType === "ACE-LITE") || (ifType === "AXI4") || (ifType === "AXI5") || (ifType === "ACELITE-E") || (ifType === "ACE") || (ifType === "ACE5")) && !obj.useCache) {
            sftype   = "UNDEFINED";
            sftftype = "UNDEFINED";
            wrevict  = 0;
        } else {
            sfid     = obj.sfid;
            sftype   = obj.SnoopFilterInfo[sfid].fnFilterType;

            if(sftype != "NULL"){
                sftftype = obj.SnoopFilterInfo[sfid].fnFilterType;
            }
            wrevict  = obj.useWriteEvict;
        }		    
    }
%> 

typedef class ioaiu_scoreboard;
typedef int ott_entries[$];
typedef struct {
    bit                                                 isDVMMsg;
    bit                                                 isDVMComplete;
    bit                                                 isMultiPartDVM;
    bit                                                 is1stPartDVM;
    bit                                                 is2ndPartDVM;
    bit                                                 isDVMCrRspRcvd;
    int                                                 tb_txnid;
} ACSNOOP_struct_t;

typedef struct {
    int id;
    int ott_id;
    time alloc_time;
    bit starving;
    bit overflow;
    int address;
    int security; //FIXME is int enough? sai
    bit cmd_req_sent;
} ott_pkt_t;

parameter N_CCP_WAYS = <%=obj.nWays%>;
class ioaiu_scoreboard extends uvm_scoreboard;

    // Interfaces
    virtual <%=obj.BlockId%>_stall_if sb_stall_if;
    parameter CACHELINE_SIZE    = ((SYS_nSysCacheline*8)/wSmiDPdata);
	parameter NUM_BEATS_CACHELINE = <%=((Math.pow(2,obj.wCacheLineOffset) * 8) / obj.wData)%>;
    parameter DATA_WIDTH        = <%=obj.wData%>;

    ioaiu_scb_txn   m_ott_q[$];
    ioaiu_scb_txn   m_ott_q_cmpl[$];
    ioaiu_scb_txn   m_pkt_isAtomic[$];
    ioaiu_scb_txn   m_ott_q_fatal_err[$];
    ioaiu_scb_txn   m_ott_q_tag_err[$];
    ioaiu_scb_txn   m_ott_q_dtr_cmstatus_err[$];
    ioaiu_scb_txn   m_mntop_q[$];
    bit [<%=obj.nOttCtrlEntries%>-1 : 0] ott_entries_valid;
    bit [<%=obj.nOttCtrlEntries%>-1 : 0] prev_ott_entries_valid;
    bit [<%=obj.nOttCtrlEntries%>-1 : 0] ottvld_vec_prev;
    bit [<%=obj.nOttCtrlEntries%>-1 : 0] ott_oldest_st;
    bit [<%=obj.nOttCtrlEntries%>-1 : 0] ott_owned_st;
    bit             starvation_mode;
    int             starv_counter;
    ott_pkt_t       ott_id_q[int];
    ott_pkt_t       prev_cmd;
    int             txn_count;    //FIXME: try merging both counts this and below line - SAI
    int             tb_txn_count;
    int             current_id = -1;
    int             prev_rid = -1;
    int             prev_rid0 = -1;
    int             prev_rlast;
    int             curr_interleave_cnt = 0;
    int             m_num_dvm_snp_sync_cr_resp;
    int             m_num_dvm_snp_compl;
    bit             read_complete[int];   
    bit             sys_req_count;
    bit             ioaiu_cov_dis=1; // added switch to enable/disable ioaiu coverage in io_subsys_snps testbench by default its disable
    dvm_msgType_enum_t dvm_opType;
    longint unsigned cycle_counter;
    longint unsigned largest_ott_alloc_cycles = 0;

    bit owo = <%if (obj.orderedWriteObservation == true) {%> 1 <%} else {%> 0 <%}%>;
    bit owo_512b = <%if ((obj.orderedWriteObservation == true) && (obj.AiuInfo[obj.Id].wData == 512)) {%> 1 <%} else {%> 0 <%}%>;
    bit [1:0]       timeout_err_cmd_type;      
    bit[<%=obj.AiuInfo[obj.Id].ccpParams.wAddr%> -1:0]    sv_ovt_timeout_addr;
    bit[11:0]					          sv_ovt_timeout_id;
    bit[<%=obj.AiuInfo[obj.Id].ccpParams.wAddr%> -1:0]    eviction_addr;
    bit[11:0]                                             evict_id;
    bit                                                   eviction_security;
    bit	   sv_ovt_timeout_security;	
    bit    ovt_flag =1;
    bit    check_bypass_flag =0;
    longint  bypass_cycle_counter =0;
    bit      bypass_bank_q[$];
    int    ott_no; 
    bit [N_CCP_WAYS-1:0] plru_valid_ways, plru_victim_way;
    bit [N_CCP_WAYS-2:0] plru_curr_state=0, plru_nxt_state;
    virtual event_out_if u_event_out_vif;

    typedef struct {
        int max_beats_in_cacheline;
        int current_beat;
        int arid;
        int read_complete;
    } read_pkt_info_t;
    read_pkt_info_t read_packets[$];

    int dptr_ind[$], err_ind[$];
    bit[63:0] err_id, err_addr;
    bit [127:0] err_id_addr_q[$];
    bit ott_err_detected;

    <% if(obj.testBench =="io_aiu") {%>
    <%for( var i=0;i< (obj.nOttDataBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
    bit [DATA_WIDTH -1:0] error_data<%=i%>; 
    bit [31:0] single_error_count<%=i%>;
    bit [31:0] double_error_count<%=i%>;
    <%}%>
    <%}%>

    bit [DATA_WIDTH -1:0] error_data_q[$];
    bit [DATA_WIDTH -1:0] error_data_bit;
    bit [2:0] csr_addr_decode_err_type_q[$];
    bit [2:0] dec_err_type;
    int core_id;

    <%if(obj.useCache) { %>
        ccpCacheLine  m_ncbu_cache_q[$];
        <%if(obj.AiuInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
        bit [N_WAY-2:0] plru_state[int];
        <%}%>
    <%}%>

    //AIUCfg_t   m_aiu_cfg;
    smi_src_id_bit_t m_req_aiu_id;
    uvm_printer      m_printer;

    // Outstanding ACE data queues 
    ace_snoop_data_pkt_t  m_oasd_q[$];
    ace_write_data_pkt_t  m_owo_native_oawd_q[$];
    ace_write_data_pkt_t  m_owo_native_oawd_tmp_q[$]; //just to check num beats received
    ace_write_data_pkt_t  m_oawd_q[$];
    axi4_write_data_pkt_t m_oancd_q[$];

    //SysReq Events queues
    smi_seq_item m_sysreq_q[$];
    smi_seq_item m_exp_sysrsp_q[$];
    //helper members
    int timeout_source_id = -1;

    // UVM comparer object
    uvm_comparer m_uvm_comparer;

    eSysCoFSM m_sysco_fsm_state;
    eSysCoFSM m_sysco_fsm_state_prev;

    //Start bandwidth calculation
    bit   m_start_bw_calculations; 
    int   m_bw_read_start               =  0;
    int   m_bw_write_start              =  0;
    int   m_bw_read_counter             =  0;
    int   m_bw_write_counter            =  0;
    int   m_bw_read_counter_prv_print   =  0;
    int   m_bw_write_counter_prv_print  =  0;
    time  t_read_bw_start_calc_time;
    time  t_write_bw_start_calc_time;
    time  t_read_bw_start_time;
    time  t_write_bw_start_time;
    time  t_timeperiod;
    int  m_bw_number_of_read_transactions;
    int  m_bw_number_of_read_hits;
    int  m_bw_number_of_write_transactions;
    int  m_bw_number_of_write_hits;
    
    uvm_cmdline_processor clp;

    //Traffic Monitor counters
    int  numReadHits;
    int  numReadMiss;
    int  numReadEvicts;
    int  evict_counter,cache_q_size;
    int  numWriteHits;
    int  numWriteHitUpgrade;
    int  numWriteMiss;
    int  numWriteMissPtl;
    int  numWriteMissFull;
    int  numWriteEvicts;
    int  numSnoopHit;
    int  numSnoopMiss;
    int  numSnoopHitEvict;
    int  numSnoopHitOtt;
    //Coverage collision tracking
    int   awaddr_active[int];
    int   awid_active[int];
    int   araddr_active[int];
    int   arid_active[int];
   
    // SMI error injection statistics
    int  res_smi_corr_err   = 0;
    int  num_smi_corr_err   = 0;
    int  num_smi_uncorr_err = 0;
    int  num_smi_parity_err = 0;  // also uncorrectable

    int ioaiu_cctrlr_phase  = 0;  // Trace debug Regs

    int ccp_index_q [$];

    realtime res_smi_pkt_time_old, res_smi_pkt_time_new;
    int res_mod_dp_corr_error;
    bit res_is_pre_err_pkt;

    uvm_objection objection;
    event kill_test;
    bit [2:0] inj_cntl;
    // CSR interface handle
    <%if((obj.useResiliency || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") && ((obj.testBench != "fsys") && (obj.testBench != "emu") && (obj.testBench != "emu_t")) || obj.testBench =="io_aiu") { %>
        virtual <%=obj.BlockId%>_probe_if u_csr_probe_vif[<%=obj.DutInfo.nNativeInterfacePorts%>]; 
    <%}%> 
    // To Handle Uncorrectable Error injection in OTT memory
    string k_csr_seq = "";
    // 0 : Error Not occured expecting one of the below type error
    // 1 : Corruption in : w_odf_rdata -> (DTW Req will be affected) : one of the beat will have DBAD, if 1st Beat has DBAD CMSTATUS-> 0x83
    // 2 : Corruption in : w_odr_rdata -> (RData will be affected) : One of the RResp should be SLVERR; change to 5,6 after wards
    // 3 : Corruption in : w_odw_rdata -> (CCP write data will be affected) : Poison bit set for one of the beat in CCP wr Data
    // 4 : Corruption in : w_odm_rdata -> (CCP fill data will be affected) : Poison bit set for one of the beat in CCP fill; use 8 for fill byteEn
    // F : Default value; No error expected
    bit[3:0] uncorr_OTT_Data_Err_effect=4'hF;  // test Name :csr_uuedr_MemErrDetEn_uncorr_OTT_Data ;
    
    bit[1:0] uncorr_CCP_Tag_Err_effect=2'h3;  // test Name: csr_uuedr_MemErrDetEn_uncorr_CCP_Tag;
    bit[63:0] uncorr_CCP_Tag_Err_cacheline_addr_w_sec = -1;  // test Name: csr_uuedr_MemErrDetEn_uncorr_CCP_Tag;
    int en_sys_event_hds_timeout;
    //Coverage bits

    bit prev_rd_hit;
    bit prev_rd_miss;
    axi_arid_t prev_rd_axid;
    bit prev_wr_hit;
    bit prev_wr_miss;
    axi_awid_t prev_wr_axid;

    // NCBU CSR bits
    bit alloc_ptl_rd_miss  = 1;
    bit alloc_ptl_wr_miss  = 1;
    bit alloc_full_rd_miss = 1;
    bit alloc_full_wr_miss = 1;
    bit iocache_lookup_en  = 1;
    int mntEvictIndex; 
    int mntEvictWay; 
    int mntWord;
    int mntOpType; 
    bit mntOpArrId; 
    bit mnt_PcSecAttr; 
    axi_axaddr_t  mntEvictAddr; 
    int mntEvictRange;
    //CONC-7152 //int mntRdDataWord; // Data resulting from debugRead
    int mntDataWord; // Data to be used for debugWrite
    //CONC-7813
    bit native_trace_CONC_7813 = 1; //native trace resp should always set when req set

    <% if(obj.useCache) {%>
    //save the prev ccp packet for coverage
    ccp_ctrl_pkt_t prev_ctrl_pkt;
    <%}%>
    
        // XAIUPCTCR bits
    bit csr_ccp_lookupen=0;  // reset value is 0
    bit csr_ccp_allocen=0;   // reset value is 0
    bit csr_ccp_updatedis=0; //reset value is 0. 

    bit csr_use_eviction_qos = 0; //reset value
    int csr_eviction_qos = 'hf; //reset value

     //NCBU Error Logging bits
    longint strreq_addr_err_logged;
    int dtrreq_err_set_logged;
    int dtrreq_err_way_logged;
    string dtr_err_logged="null";
    string str_err_logged="null";

    axi_axaddr_t m_ccp_addr_p2;
    bit m_security_p2;
    bit m_ccp_p1_done;
    typedef struct packed { smi_ncore_unit_id_bit_t src_id;
                            smi_msg_id_bit_t msg_id;
                          }unique_id;
    smi_msg_id_bit_t dtw_rsp_rmsg_id_targ_id_err[smi_msg_id_bit_t];
    smi_msg_id_bit_t dtr_rsp_rmsg_id_targ_id_err[smi_msg_id_bit_t];
    smi_msg_id_bit_t ccmd_rsp_rmsg_id_targ_id_err[smi_msg_id_bit_t];
    smi_msg_id_bit_t nccmd_rsp_rmsg_id_targ_id_err[smi_msg_id_bit_t];
    unique_id snp_req_msg_id_targ_id_err[$];
    unique_id dtr_req_msg_id_targ_id_err[$];
    unique_id str_req_msg_id_targ_id_err[$];
    smi_addr_t csr_addr_decode_err_addr_q[$];
    bit [WAXID-1:0] csr_addr_decode_err_msg_id_q[$];
    bit [WAXID-1:0] csr_addr_decode_err_msg_rsp_id_q[$];
    bit csr_addr_decode_err_cmd_type_q[$];
    bit en_or_chk;
    TransOrderMode_e transOrderMode_wr, transOrderMode_rd;
    int OttRdPool, OttWrPool;
    int transOrderMode_tmp;
    bit EventDis_rd;
    bit dvm_resp_order;
    TRIG_TCTRLR_t    tctrlr[<%=obj.nTraceRegisters%>];
    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
        typedef struct {
            smi_addr_security_t m_addr;
            ace_command_types_enum_t m_cmdtype;
            axi_axdomain_t m_axdomain;
        } ACE_cmd_addr_t;
        ACE_cmd_addr_t ace_cmd_addr_q[$];
    <%}%>

    // For coverage
    typedef struct {
        time t_pkt;
        string pkt_name;
    } pkt_order_t; 

    `uvm_component_param_utils(ioaiu_scoreboard)
   
    <% if(obj.testBench=="fsys" || obj.testBench =="io_aiu"){ %>
     <% if( obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
    uvm_analysis_imp_event_sender_chnl                        #(<%=obj.BlockId%>_event_agent_pkg::event_pkt  , ioaiu_scoreboard) event_sender_port;
        <%}%>
     <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false ) { %>
    uvm_analysis_imp_event_reciever_chnl                      #(<%=obj.BlockId%>_event_agent_pkg::event_pkt  , ioaiu_scoreboard) event_reciever_port;
        <%}%>
        <%}%>
    uvm_analysis_imp_ncbu_read_addr_chnl                 #(axi4_read_addr_pkt_t  , ioaiu_scoreboard)  read_addr_port;
    uvm_analysis_imp_ncbu_write_addr_chnl                #(axi4_write_addr_pkt_t , ioaiu_scoreboard)  write_addr_port;
    uvm_analysis_imp_ncbu_read_data_chnl                 #(axi4_read_data_pkt_t  , ioaiu_scoreboard)  read_data_port;
    uvm_analysis_imp_ncbu_read_data_chnl_every_beat      #(axi4_read_data_pkt_t  , ioaiu_scoreboard)  read_data_port_every_beat;
    uvm_analysis_imp_ncbu_read_data_advance_copy_chnl    #(axi4_read_data_pkt_t  , ioaiu_scoreboard)  read_data_advance_copy_port;
    uvm_analysis_imp_ncbu_write_data_chnl                #(axi4_write_data_pkt_t , ioaiu_scoreboard)  write_data_port;
    uvm_analysis_imp_ncbu_write_resp_chnl                #(axi4_write_resp_pkt_t , ioaiu_scoreboard)  write_resp_port;
    uvm_analysis_imp_ncbu_write_resp_advance_copy_chnl   #(axi4_write_resp_pkt_t , ioaiu_scoreboard)  write_resp_advance_copy_port;
    //RTL probing ports
    uvm_analysis_imp_rtl_probe_chnl                      #(ioaiu_probe_txn, ioaiu_scoreboard)         probe_rtl_port;
    uvm_analysis_imp_ottvec_probe_chnl                   #(ioaiu_probe_txn, ioaiu_scoreboard)         probe_ottvec_port;
    uvm_analysis_imp_owo_chnl                            #(ioaiu_probe_txn, ioaiu_scoreboard)         probe_owo_port;
    uvm_analysis_imp_cycle_tracker_probe_chnl            #(cycle_tracker_s, ioaiu_scoreboard)         probe_cycle_tracker_port;
    uvm_analysis_imp_bypass_probe_chnl                   #(ioaiu_probe_txn, ioaiu_scoreboard)         probe_bypass_port;

    <% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.fnNativeInterface === "ACELITE-E" || obj.fnNativeInterface === "ACE-LITE") && aiu_axiInt.params.eAc==1)){%>
        uvm_analysis_imp_ace_snoop_addr_chnl                #(ace_snoop_addr_pkt_t, ioaiu_scoreboard)   snoop_addr_port;
        uvm_analysis_imp_ace_snoop_resp_chnl                #(ace_snoop_resp_pkt_t, ioaiu_scoreboard)   snoop_resp_port;
        uvm_analysis_imp_ace_snoop_data_chnl                #(ace_snoop_data_pkt_t, ioaiu_scoreboard)   snoop_data_port;
    <%}%>
    uvm_analysis_imp_q_chnl #(q_chnl_seq_item , ioaiu_scoreboard) analysis_q_chnl_port;

    <% if(obj.useCache) {%>
        uvm_analysis_imp_ncbu_ccp_wr_data_chnl   # ( ccp_wr_data_pkt_t  , ioaiu_scoreboard) ncbu_ccp_wr_data_port;
        uvm_analysis_imp_ncbu_ccp_ctrl_chnl      # ( ccp_ctrl_pkt_t     , ioaiu_scoreboard) ncbu_ccp_ctrl_port;
        uvm_analysis_imp_ncbu_ccp_fill_ctrl_chnl # ( ccp_fillctrl_pkt_t , ioaiu_scoreboard) ncbu_ccp_fill_ctrl_port;
        uvm_analysis_imp_ncbu_ccp_fill_data_chnl # ( ccp_filldata_pkt_t , ioaiu_scoreboard) ncbu_ccp_fill_data_port;
        uvm_analysis_imp_ncbu_ccp_rd_rsp_chnl    # ( ccp_rd_rsp_pkt_t   , ioaiu_scoreboard) ncbu_ccp_rd_rsp_port;
        uvm_analysis_imp_ncbu_ccp_evict_chnl     # ( ccp_evict_pkt_t    , ioaiu_scoreboard) ncbu_ccp_evict_port;
    <%}%>
    uvm_analysis_imp_apb_chnl #(apb_pkt_t, ioaiu_scoreboard) analysis_apb_port;
    `declare_check(CmdReqMatchesOttIdOfOutstTxn)
    uvm_analysis_imp_ioaiu_smi_port                   #(smi_seq_item, ioaiu_scoreboard)           ioaiu_smi_port;
    uvm_analysis_imp_ioaiu_smi_every_beat_port        #(smi_seq_item, ioaiu_scoreboard)           ioaiu_smi_every_beat_port;
    // Events
    event e_queue_add;
    event e_queue_delete;
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_snoop_rsp_err = ev_pool.get("ev_snoop_rsp_err");
    uvm_event ev_snoop_rsp_err_dvm = ev_pool.get("ev_snoop_rsp_err_dvm");
    uvm_event m_dvm_completed = ev_pool.get("dvm_complete_event");
    `ifdef USE_VIP_SNPS
        uvm_event ev_snoop_rsp = ev_pool.get("ev_snoop_rsp");
    `endif
    <%for(let i=0; i<obj.nNativeInterfacePorts; i++) {%>
    uvm_event ev_ar_req_<%=i%> = ev_pool.get("ev_ar_req_<%=i%>");
    uvm_event ev_aw_req_<%=i%> = ev_pool.get("ev_aw_req_<%=i%>");
    <% } %>
    <% if(obj.testBench == "fsys" || obj.testBench == "emu") { %>
    //fullsys test uncorrectable error whenassigned zero crdit to ioaiu
    //event to sync with concerto_fullsys_test and end simulation when DECERR is received
    uvm_event kill_uncorr_test = ev_pool.get("kill_uncorr_test");
    //fullsys test uncorrectable error test when addresses with NS=1 that hit a NSX=0 region should be terminated with decerr
    //event to sync with concerto_fullsys_test and end simulation when DECERR is received
    //#Check.IOAIU.NS
    uvm_event kill_uncorr_grar_nsx_test = ev_pool.get("kill_uncorr_grar_nsx_test");
    <% } %>
    uvm_event ev_ccp_eviction_time_out_test = ev_pool.get("ev_ccp_eviction_time_out_test");
    uvm_event ev_sysco_fsm_state_change = ev_pool.get("ev_sysco_fsm_state_change_<%=obj.FUnitId%>");
    uvm_event ev_sysco_all_sys_rsp_received = ev_pool.get("ev_sysco_all_sys_rsp_received_<%=obj.FUnitId%>");
    uvm_event ev_sysco_all_sys_req_sent = ev_pool.get("ev_sysco_all_sys_req_sent_<%=obj.FUnitId%>");
    <% if(obj.testBench == "fsys") { %>
    uvm_event val_change_k_decode_err_illegal_acc_format_test_unsupported_size = ev_pool.get("val_change_k_decode_err_illegal_acc_format_test_unsupported_size");
    ioaiu_scb_txn m_scb_txn;
    <% } %>

    // Supporting variables to count OTT entries for performance monitor verification
    const int               max_ott = <%=obj.AiuInfo[obj.Id].cmpInfo.nOttCtrlEntries%>;
    int                     real_ott_size;
    event                   ev_ott;
    event                   ev_ott_del;
    ioaiu_scb_txn snoop_rsp_err_info[$];
    int                     count_ott_entry=1;

    virtual <%=obj.BlockId%>_axi_cmdreq_id_if axi_cmdreq_id_vif;
    /*<%if(obj.testBench == "fsys"|| obj.testBench == "emu") { %>
        concerto_register_map_pkg::ral_sys_ncore m_regs;
    <%}else{%>
        ral_sys_ncore m_regs;
    <%}%>  */

    <%if((obj.INHOUSE_APB_VIP) && (obj.testBench == "io_aiu") && 
        ((obj.instanceName) ? (obj.BlockId == obj.instanceName) :
        (obj.ioaiuId==0))) { %>
        <%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore m_regs;  
    <% } else if(obj.testBench == 'fsys' || obj.testBench =='emu'){%>
        concerto_register_map_pkg::ral_sys_ncore m_regs;
    <% } %> 
 
    // Stimulus knobs set up that can check if all packets are finished
    int k_num_snoops;
    int k_num_writes;
    int k_num_reads;
    int k_num_sets;
    int k_num_evictions;
    int nunCachline;
    
    // Counters for number of snoops, writes and reads
    int num_SenderEvt       = 0;
    int num_RecieverEvt     = 0;
    int num_snoops          = 0;
    int num_writes          = 0;
    int num_reads           = 0;
    int num_hit_reads       = 0;
    int num_miss_reads      = 0;
    int num_hit_writes      = 0;
    int num_miss_writes     = 0;
    //Counter for write txn 
    int num_wrbk            = 0;
    int num_wrcln           = 0;
    int num_wrevct          = 0;
    int num_evict           = 0;
    int num_wrlnunq         = 0;
    int num_wrnosnp         = 0;
    int num_wrunq           = 0;
    int num_atmld           = 0;
    int num_atmstr          = 0;
    int num_atmcompare      = 0; 
    int num_atmswap         = 0;
    int num_wrunqptlstash   = 0;
    int num_wrunqfullstash  = 0;
    int num_stashonceshared = 0; 
    int num_stashonceunq    = 0; 
    

    //Count for read txn 
    int num_rdnosnp         = 0;
    int num_rdonce          = 0;
    int num_rdshrd          = 0;
    int num_rdcln           = 0;
    int num_rdnotshrddir    = 0;
    int num_rdunq           = 0;
    int num_clnunq          = 0;
    int num_mkunq           = 0;
    int num_clnshrd         = 0;
    int num_clninvl         = 0;
    int num_mkinvl          = 0;
    int num_dvmmsg          = 0;
    int num_dvmcmpl         = 0;
    int num_clnshardpersist = 0;
    int num_rdoncemakeinvld = 0;
    int num_rdonceclinvld   = 0;

    //count for snoop txn
    int num_snp_inv      = 0;
    int num_snp_cln_dtr  = 0;  
    int num_snp_vld_dtr  = 0; 
    int num_snp_inv_dtr  = 0;
    int num_snp_cln_dtw  = 0;
    int num_snp_inv_dtw  = 0;
    int num_snp_nitc     = 0; 
    int num_snp_nitcci   = 0;
    int num_snp_nitcmi   = 0;
    int num_snp_nosdint  = 0;
    int num_snp_inv_stsh = 0;
    int num_snp_unq_stsh = 0;
    int num_snp_stsh_sh  = 0;
    int num_snp_stsh_unq = 0;
    int num_snp_dvm_msg  = 0;
     

    //nPendingTrans check
    int nPendingTransCounter = 0;

    // To Track multiline transactions
    int multiline_tracking_id = 1;

    // DVM capable AIUs
    int num_dvm_capable_aius = 0;

    // AIU double bit errors enabled
    bit aiu_double_bit_errors_enabled = 0;
   
    // Mirrored value for RAL
    uvm_reg_data_t mirrored_value;
    uvm_reg  my_register;

    // AIU no detEn
    bit aiu_nodetEn_err_inj = 0;

    bit hasErr = 0;
    bit is_multi_part_dvm = 0;   
    int multipart_dvmnonsync_count;   
    int singlepart_dvmnonsync_count;   
    int singlepart_dvmsync_count;   

    <% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.fnNativeInterface === "ACELITE-E" || obj.fnNativeInterface === "ACE-LITE") && aiu_axiInt.params.eAc==1) ||(obj.orderedWriteObservation == true)) { %>
        ACSNOOP_struct_t ACSNOOP_q[$];
        smi_msg_id_bit_t dvmSnpReqMsgId_q[$];
    <%}%>
    // Performance counters
    time                                    t_min_read_transaction;
    time                                    t_max_read_transaction;
    time                                    t_avg_read_transaction;
    time                                    t_min_write_transaction;
    time                                    t_max_write_transaction;
    time                                    t_avg_write_transaction;
    time                                    t_min_snoop_transaction;
    time                                    t_max_snoop_transaction;
    time                                    t_avg_snoop_transaction;
    time                                    t_min_ace_read_to_cmd_req_transaction;
    time                                    t_max_ace_read_to_cmd_req_transaction;
    time                                    t_avg_ace_read_to_cmd_req_transaction;
    time                                    t_min_ace_write_to_cmd_req_transaction;
    time                                    t_max_ace_write_to_cmd_req_transaction;
    time                                    t_avg_ace_write_to_cmd_req_transaction;
    time                                    t_ace_write_data_str_req_to_dtw_reqf_transaction;
    time                                    t_min_smi_to_axi_transaction;
    time                                    t_max_smi_to_axi_transaction;
    time                                    t_avg_smi_to_axi_transaction;
    time                                    t_min_snoop_to_resp_transaction;
    time                                    t_max_snoop_to_resp_transaction;
    time                                    t_avg_snoop_to_resp_transaction;
    time                                    t_min_sfi_snoop_to_ace_snoop_transaction;
    time                                    t_max_sfi_snoop_to_ace_snoop_transaction;
    time                                    t_avg_sfi_snoop_to_ace_snoop_transaction;
    time                                    t_str_req_dtr_req_to_ace_read_rsp_transaction;
    time                                    t_rack_to_str_rsp_transaction;
    time                                    t_ace_write_data_str_req_to_dtw_req_transaction;
    time                                    t_dtw_rsp_to_brsp_transaction;
    time                                    t_wack_to_str_rsp_transaction;
    time                                    t_ace_write_req_write_data_to_dtw_req_transaction;
    time                                    t_dtw_rsp_to_upd_req_transaction;
    time                                    t_upd_rsp_to_brsp_transaction;
    // For IO cache
    time                                    t_min_read_hit_transaction;
    time                                    t_max_read_hit_transaction;
    time                                    t_min_read_miss_transaction;
    time                                    t_max_read_miss_transaction;
    time                                    t_avg_read_hit_transaction;
    time                                    t_avg_read_miss_transaction;
    time                                    t_min_write_hit_transaction;
    time                                    t_max_write_hit_transaction;
    time                                    t_min_write_miss_transaction;
    time                                    t_max_write_miss_transaction;
    time                                    t_avg_write_hit_transaction;
    time                                    t_avg_write_miss_transaction;
    axi_axaddr_t                            m_min_read_hit_addr;
    time                                    t_min_read_hit_start_time;
    axi_axaddr_t                            m_min_read_miss_addr;
    time                                    t_min_read_miss_start_time;
    axi_axaddr_t                            m_min_write_hit_addr;
    time                                    t_min_write_hit_start_time;
    axi_axaddr_t                            m_min_write_miss_addr;
    time                                    t_min_write_miss_start_time;
    axi_axaddr_t                            m_min_read_addr;
    time                                    t_min_read_start_time;
    time                                    t_read_start_time;
    time                                    t_last_read_complete_time;
    time                                    t_read_throughput;
    axi_axaddr_t                            m_min_write_addr;
    time                                    t_min_write_start_time;
    time                                    t_write_start_time;
    time                                    t_last_write_complete_time;
    time                                    t_write_throughput;
    axi_axaddr_t                            m_min_snoop_addr;
    time                                    t_min_snoop_start_time;
    axi_axaddr_t                            m_min_ace_read_to_cmd_req_addr;
    axi_axaddr_t                            m_min_smi_to_axi_addr;
    axi_axaddr_t                            m_min_snoop_to_resp_addr;
    time                                    t_min_ace_read_to_cmd_req_start_time;
    axi_axaddr_t                            m_min_ace_write_to_cmd_req_addr;
    time                                    t_min_smi_to_axi_start_time;
    time                                    t_min_snoop_to_resp_start_time;
    time                                    t_min_ace_write_to_cmd_req_start_time;
    axi_axaddr_t                            m_min_sfi_snoop_to_ace_snoop_addr;
    time                                    t_min_sfi_snoop_to_ace_snoop_start_time;
    extern function void set_sleeping(ioaiu_scb_txn scb_txn);
    extern function void wake_sleeping(ioaiu_scb_txn scb_txn);
    <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
            ioaiu_coverage                          cov;
        `endif
    <% } else if(obj.IO_SUBSYS_SNPS) { %> 
            ioaiu_coverage                          cov;
    <%}%>
    extern function void write_q_chnl             (q_chnl_seq_item m_pkt) ;
    extern function void write_apb_chnl      ( apb_pkt_t            m_pkt  ) ;

    extern function bit  req_data_crosses_cacheline_midpoint(input bit[63:0] start_addr, input int unsigned size);
    extern function void owo_set_expect_for_wb(int ott_idx); 
    extern function void update_owo_wr_state_on_clnunq_strreq(int ott_idx);
    extern function void update_owo_wr_state_on_coh_wb_cmdreq_sent(int ott_idx);
    extern function void owo_update_on_snp_req(int snp_ott_idx, int coh_wr_ott_idx, output bit snp_release);
    extern function void owo_unblock_snp_on_wb_dtwrsp(int ott_idx);
    <% if(obj.useCache){ %>
        extern function void write_ncbu_ccp_wr_data_chnl   ( ccp_wr_data_pkt_t m_pkt   ) ;
        extern function void write_ncbu_ccp_ctrl_chnl      ( ccp_ctrl_pkt_t m_pkt      ) ;
        extern function void write_ncbu_ccp_fill_ctrl_chnl ( ccp_fillctrl_pkt_t  m_pkt ) ;
        extern function void write_ncbu_ccp_fill_data_chnl ( ccp_filldata_pkt_t m_pkt  ) ;
        extern function void write_ncbu_ccp_rd_rsp_chnl    ( ccp_rd_rsp_pkt_t m_pkt    ) ;
        extern function void write_ncbu_ccp_evict_chnl     ( ccp_evict_pkt_t m_pkt     ) ;

        extern function void      set_word_tag_array  (int set, int way, bit[5:0] word, bit[31:0] worddata);
        extern function void      set_word_data_array (int set, int way, bit[5:0] word, bit[31:0] worddata);
        extern function bit[31:0] get_word_tag_array  (int set, int way, bit[5:0] word);
        extern function bit[31:0] get_word_data_array (int set, int way, bit[5:0] word);
        extern function bit[<%=wTag-1%>:0] get_tag_from_cacheline (bit[<%=wCacheline-1%>:0] cacheline);
        extern function bit[<%=wCacheline-1%>:0] get_cacheline_from_tag (bit[<%=wTag-1%>:0] tag, bit[<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length-1%>:0] index);
           extern function void check_address_ordering(int ottq_idx);

        extern function void convert_dtr_to_fill_data( 
                        input int                  ott_index,
                        output ccp_ctrlfill_data_t fill_data[],
                        output int                 fill_data_beats[],
                        output ccp_data_poision_t  fill_data_poison[]
                        );

        extern function void convert_agent_data_to_ccp_data( 
                        input axi_xdata_t agent_wr_hit_data[],
                        input axi_axaddr_t addr,
                        input int                                     ott_index,
                        output ccp_ctrlwr_data_t         ccp_data[],
                        output int                       ccp_data_beat[]
                        );


        extern function void merge_write_data(
                        input int                  ott_index,
                        output ccp_ctrlfill_data_t ccp_data[],
                        output ccp_ctrlfilldata_byten_t ccp_byten[],
                        output int                 ccp_data_beat[],
                        output ccp_data_poision_t  ccp_data_poison[]
                        );

        extern function axi_axaddr_t shift_addr(
                        input axi_axaddr_t in_addr
                        );
        extern function void get_bitmask(
                        input ccp_ctrlfilldata_byten_t byten[],
                        output ccp_ctrlfill_data_t bitmask[]
                        );

        extern function int onehot_to_binay(bit [N_WAY-1:0] in_word);

        extern function void check_sfi_snoop_resp(int ott_index);
        extern function ccp_cachestate_enum_t return_cacheline_state(axi_axaddr_t m_addr, bit m_security);    
        extern function void add_cacheline(int ott_index);
        extern function void update_cacheline_state(int ott_index, string s = "");
        extern function void check_cacheline_state(ccp_ctrl_pkt_t m_pkt);
        extern function void check_ccp_ctrl(ccp_ctrl_pkt_t m_pkt, int ott_index);
        extern function bit[N_CCP_WAYS-1:0] get_allocated_ways_vec(ccp_ctrl_pkt_t m_pkt);
        extern function void set_cacheline_way(ioaiu_scb_txn scb_txn);
        extern function void delete_cacheline(int ott_index,bit isSnoop);
        extern function bit  hasActiveMntOp();
        extern function void store_write_hit_data( input int ott_index);
        extern function void read_cacheline_data( input int ott_index);
        extern function void evict_cacheline_data( ioaiu_scb_txn pkt,
                        output ccp_ctrlwr_data_t         ccp_data[]);
        extern function ccp_ctrlop_waybusy_vec_t get_pending_ways(int ccp_index);
        extern function bit has_sleeping_ways(int ccp_index);
        <% if(obj.COVER_ON) {%>
            extern function void sample_coverage(int ott_index);
        <%}%>
   
        enum  bit [1:0]  {B2B_RD_HIT_NOAXID_DEP, B2B_RD_HIT_AXID_DEP, B2B_RD_MISS_NOAXID_DEP, B2B_RD_MISS_AXID_DEP} b2bRdHits;
        enum  bit [1:0]  {B2B_WR_HIT_NOAXID_DEP, B2B_WR_HIT_AXID_DEP, B2B_WR_MISS_NOAXID_DEP, B2B_WR_MISS_AXID_DEP} b2bWrHits;

        covergroup B2B_RD_HITS;
            coverpoint b2bRdHits; 
        endgroup

        covergroup B2B_WR_HITS;
            coverpoint b2bWrHits; 
        endgroup
    <%}%>
        extern function void processApbReq(apb_pkt_t apb_entry);
    <%if(obj.COVER_ON){%>
        sysreq_pkt_t    sysreq_pkt;
    <%}%>

    extern function void split_read_data_packet_multiline_txn(int ott_idx, ace_read_data_pkt_t m_pkt);
    extern function void delete_txn(int ott_idx);
    extern function void check_address_core_id(bit[WAXADDR-1:0] addr);
    extern function void process_sysco_fsm_state_change(bit error=0);    
    extern function void process_sys_req(smi_seq_item m_pkt);    
    extern function void process_sys_rsp(smi_seq_item m_pkt);    
    extern function void process_cmd_req(smi_seq_item m_pkt);    
    extern function void check_credits(smi_seq_item m_pkt);
    extern function void check_response_ordering(int ottq_idx);
    extern function void process_cmp_rsp(smi_seq_item m_pkt);    
    extern function void process_upd_req(smi_seq_item m_pkt);    
    extern function void process_dtw_req(smi_seq_item m_pkt);    
    extern function void process_dtr_req(smi_seq_item m_pkt);    
    extern function void process_snp_req(smi_seq_item m_pkt);
    extern function void process_str_req(smi_seq_item m_pkt);
    extern function void process_ccmd_rsp(smi_seq_item m_pkt);
    extern function void process_nccmd_rsp(smi_seq_item m_pkt);
    extern function void process_upd_rsp(smi_seq_item m_pkt);
    extern function void process_dtr_rsp(smi_seq_item m_pkt);
    extern function void process_dtw_rsp(smi_seq_item m_pkt);
    extern function void process_snp_rsp(smi_seq_item m_pkt);
    extern function void process_str_rsp(smi_seq_item m_pkt);
    extern function void process_snp_dtr_req(smi_seq_item m_pkt);
    extern function bit matchSmiId(smi_seq_item pktA, smi_seq_item pktB);
    extern function void check_axid_ordering(int idx);
    extern function void owo_check_axid_ordering_cmdreq(int idx);
    extern function void owo_check_axid_ordering_dtwreq(int idx);
    extern function void check_oldest_axid_in_ott_q(int idx);
    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.fnNativeInterface === "ACELITE-E" || obj.fnNativeInterface === "ACE-LITE") && aiu_axiInt.params.eAc==1)) { %>
        extern function void write_ace_snoop_addr_chnl(ace_snoop_addr_pkt_t m_pkt);
        extern function void write_ace_snoop_resp_chnl(ace_snoop_resp_pkt_t m_pkt);
        extern function void write_ace_snoop_data_chnl(ace_snoop_data_pkt_t m_pkt);
    <%}%>
    extern virtual function void update_resiliency_ce_cnt(const ref smi_seq_item m_item);
    extern function bit check_id(int m_tmp_qA[$]);
    //----------------------------------------------------------------------- 
    // Constructor
    //----------------------------------------------------------------------- 
    
    function new(string name = "ioaiu_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        $timeformat(-9, 2, " ns", 10);
        m_uvm_comparer = new();
        m_uvm_comparer.policy = UVM_DEEP;
        m_uvm_comparer.verbosity = UVM_NONE;
        clp = uvm_cmdline_processor::get_inst();
        `ifndef FSYS_COVER_ON
        `inst_check(CmdReqMatchesOttIdOfOutstTxn)
        `endif
        if ($test$plusargs("double_bit_error_test") || $test$plusargs("double_bit_err_task") || $test$plusargs("aiu_noerrdetEn") /* || $test$plusargs("iocache_double_bit_data_error_test")*/) begin
            aiu_double_bit_errors_enabled = 1;
        end
        else begin
            aiu_double_bit_errors_enabled = 0;
        end
        if ($test$plusargs("aiu_noerrdetEn") ) begin
            aiu_nodetEn_err_inj = 1;
        end
        else begin
            aiu_nodetEn_err_inj = 0;
        end

        <% if(obj.useCache && obj.COVER_ON) {%>
            B2B_RD_HITS = new();
            B2B_WR_HITS = new();
        <%}%>

        // event timeout  
        if (! $value$plusargs("en_sys_event_hds_timeout=%d", en_sys_event_hds_timeout)) begin
           en_sys_event_hds_timeout = 0;
        end
        // To Handle Uncorrectable Error injection in OTT memory
        if (! $value$plusargs("k_csr_seq=%s", k_csr_seq)) begin
           k_csr_seq = "";
        end
        if($test$plusargs("ccp_double_bit_direct_ott_error_test") && (k_csr_seq ==="ioaiu_csr_uuedr_MemErrDetEn_seq" || k_csr_seq ==="ioaiu_csr_uueir_MemErrInt_seq" || k_csr_seq ==="ioaiu_csr_uuecr_sw_write_seq" || k_csr_seq ==="ioaiu_csr_elr_seq")) begin
           `uvm_info("new", "Expecting error as uncorr error injected in OTT data Memory",UVM_NONE)
           uncorr_OTT_Data_Err_effect = 0; // Error Expected, Check this signal default value above
        end
        if($test$plusargs("ccp_double_bit_direct_tag_error_test") && (k_csr_seq ==="ioaiu_csr_uuedr_MemErrDetEn_seq" || k_csr_seq ==="ioaiu_csr_uueir_MemErrInt_seq" || k_csr_seq ==="ioaiu_csr_uuecr_sw_write_seq")) begin
           `uvm_info("new", "Expecting error as uncorr error injected in CCP Tag Memory",UVM_NONE)
           uncorr_CCP_Tag_Err_effect = 0; // Error Expected, Check this signal default value above
        end

		//Out of reset, default state is IDLE.
    	m_sysco_fsm_state = IDLE;
    	m_sysco_fsm_state_prev = IDLE;

        <% if(obj.useCache) {%>
        prev_ctrl_pkt = new();
        <%}%>

        OttRdPool=0;
        OttWrPool=0;

        m_num_dvm_snp_sync_cr_resp = 0;
        m_num_dvm_snp_compl = 0;
        $value$plusargs("ioaiu_cov_dis=%d", ioaiu_cov_dis);

        ott_owned_st = 0;
        ott_oldest_st = 0;
    endfunction : new

    //-----------------------------------------------------------------------
    // UVM Phases
    //----------------------------------------------------------------------- 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_req_aiu_id                 = <%= obj.FUnitId%>;
        read_addr_port               = new("read_addr_port", this);
    <% if(obj.testBench=="fsys" || obj.testBench =="io_aiu"){ %>
        <% if( obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
        event_sender_port                   =new("event_sender_port",this);
        <%}%>
        <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false ) { %>
        event_reciever_port                   =new("event_reciever_port",this);
        <%}%>
    <%}%>
        read_data_port               = new("read_data_port", this);
        read_data_port_every_beat    = new("read_data_port_every_beat", this);
        read_data_advance_copy_port  = new("read_data_advance_copy_port", this);
        write_addr_port              = new("write_addr_port", this);
        write_resp_port              = new("write_resp_port", this);
        write_resp_advance_copy_port = new("write_resp_advance_copy_port", this);
        write_data_port              = new("write_data_port", this);
        probe_rtl_port               = new("probe_rtl_port", this);
        probe_ottvec_port            = new("probe_ottvec_port", this);
        probe_owo_port               = new("probe_owo_port", this);
        probe_bypass_port            = new("probe_bypass_port", this);
        probe_cycle_tracker_port     = new("probe_cycle_tracker_port", this);
        <% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.fnNativeInterface === "ACELITE-E" || obj.fnNativeInterface === "ACE-LITE") && aiu_axiInt.params.eAc==1)) { %>
            snoop_addr_port              = new("snoop_addr_port", this);
            snoop_resp_port              = new("snoop_resp_port", this);
            snoop_data_port              = new("snoop_data_port", this);
        <%}%>
        analysis_q_chnl_port = new("analysis_q_chnl_port",this);

        <% if(obj.useCache) {%>
            ncbu_ccp_wr_data_port   = new("ncbu_ccp_wr_data_port", this);
            ncbu_ccp_ctrl_port      = new("ncbu_ccp_ctrl_port", this);
            ncbu_ccp_fill_ctrl_port = new("ncbu_ccp_fill_ctrl_port",this);
            ncbu_ccp_fill_data_port = new("ncbu_ccp_fill_data_port",this);
            ncbu_ccp_rd_rsp_port    = new("ncbu_ccp_rd_rsp_port",this);
            ncbu_ccp_evict_port     = new("ncbu_ccp_evict_port",this);
        <%}%>
                analysis_apb_port = new("analysis_apb_port",this) ;

        ioaiu_smi_port            = new("ioaiu_smi_port", this);
        ioaiu_smi_every_beat_port = new("ioaiu_smi_every_beat_port", this);
        <% if(obj.COVER_ON) { %>
           `ifndef FSYS_COVER_ON
            cov = new();
            cov.scb = this;
        	`endif
        <% } else if(obj.IO_SUBSYS_SNPS) { %> 
            if (ioaiu_cov_dis==0) begin
            cov = new();
            cov.scb = this;
            end
        <% } %>
        if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", "en_or_chk", en_or_chk)) begin
            en_or_chk = 0;
        end

        if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", "dvm_resp_order", dvm_resp_order)) begin
            dvm_resp_order = 1; //default is with DVM resp order
        end
        //if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", "transOrderMode_wr", transOrderMode_tmp)) begin
        	
        	<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
				transOrderMode_wr = strictReqMode;
            <%} else {%>
				transOrderMode_wr = pcieOrderMode;
            <%}%>
				
        //end 
        //else begin
        //    $cast(transOrderMode_wr, transOrderMode_tmp);
        //end

        if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", "transOrderMode_rd", transOrderMode_tmp)) begin
        	
        	<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
				transOrderMode_rd = strictReqMode;
            <%} else {%>
				transOrderMode_rd = pcieOrderMode;
            <%}%>

        end else begin
            $cast(transOrderMode_rd, transOrderMode_tmp);
        end

        foreach(tctrlr[idx]) begin
            if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", $sformatf("tctrlr_%0d",idx), tctrlr[idx])) begin
                <%if(aiu_axiInt.params.eTrace > 0){%>
                    tctrlr[idx] = 32'h1;
                <%}else{%>
                    tctrlr[idx] = 32'h0;
                <%}%>
            end
        end
    endfunction : build_phase

    <%if(obj.useCache) { %> 
        virtual function void connect_phase(uvm_phase phase);
            `uvm_info("connect_phase", "Entered connect_phase in ioaiu_scoreboard",UVM_LOW)
            super.connect_phase(phase);
        endfunction
    <%}%>

    task run_phase(uvm_phase phase);
        //TODO: Add Txn timeout check
        bit done;
        int repeat_for_ott_events;
        
        <% if ((obj.useResiliency) && ((obj.testBench != "fsys") && (obj.testBench != "emu") && (obj.testBench != "emu_t"))) { %>
            bit test_unit_duplication_uecc;
        <%}%>
        // Bound 
        <%if((obj.testBench !== "fsys") && (obj.testBench != "emu") && (obj.testBench != "emu_t")){%>
            if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_0_m_top_stall_if_0", sb_stall_if)) begin
                `uvm_fatal("Ioaiu_scoreboard stall interface error", "virtual interface must be set for stall_if");
            end
        <%} else {%>
            if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", $psprintf("<%=obj.BlockId%>_0_m_top_stall_if_%0d",core_id), sb_stall_if)) begin
                `uvm_fatal("Ioaiu_scoreboard stall interface error", "virtual interface must be set for stall_if");
            end
        <%}%>
        done = 0;
        super.main_phase(phase);
        if (! $value$plusargs("inj_cntl=%d", inj_cntl)) begin
           inj_cntl = 0;
        end
        <%if((obj.useResiliency || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") && ((obj.testBench != "fsys") && (obj.testBench != "emu") && (obj.testBench != "emu_t")) || obj.testBench =="io_aiu") { %>
            if(!uvm_config_db#(virtual <%=obj.BlockId%>_probe_if )::get(null, get_full_name(), $sformatf("u_csr_probe_if%0d",core_id),u_csr_probe_vif[core_id])) begin
                `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
            end
        <%}%>

        <%if(obj.AiuInfo[obj.Id].fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.AiuInfo[obj.Id].fnNativeInterface == "AXI4" || obj.AiuInfo[obj.Id].fnNativeInterface == "AXI5") && obj.AiuInfo[obj.Id].useCache)){%>
            if(!uvm_config_db#(virtual event_out_if )::get(null, get_full_name(), "u_event_out_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>",u_event_out_vif)) begin
                `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
            end
        <%}%>

        objection = phase.get_objection();
        fork
            begin
                forever begin
                	ev_sysco_fsm_state_change.wait_trigger();
                    process_sysco_fsm_state_change();
                end
            end
             begin //RAL mirrored value
             #800ns;
              if(m_regs == null) begin
                `uvm_info(get_type_name(),"m_regs at sb is null",UVM_LOW);
              end
              my_register = m_regs.get_reg_by_name("XAIUUELR0");
             mirrored_value = my_register.get_mirrored_value();
            `uvm_info("SB",$sformatf("The mirrored value in SB of XAIUUELR0 is %0h",mirrored_value),UVM_LOW)
             end 
    <%if(obj.testBench == "fsys") { %>
            begin
                if ($test$plusargs("k_decode_err_illegal_acc_format_test_unsupported_size")) begin
                    forever begin
                    	val_change_k_decode_err_illegal_acc_format_test_unsupported_size.wait_trigger();
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Unblocking uvm_event wait_trigger.val_change_k_decode_err_illegal_acc_format_test_unsupported_size"), UVM_MEDIUM)
                        m_scb_txn.k_decode_err_illegal_acc_format_test_unsupported_size = ~m_scb_txn.k_decode_err_illegal_acc_format_test_unsupported_size;
                    end
                end
            end
    <%}%>   
            begin
              <% if(obj.COVER_ON) { %>
                  `ifndef FSYS_COVER_ON
                  cov.collect_connectivity();
                  `endif 
              <%}%>       
            end
            //begin
            //    <% if(obj.COVER_ON) { %>
            //        `ifndef FSYS_COVER_ON
            //        cov.collect_ccr_state();
            //        `endif 
            //    <%}%>       
            //end

            <%if(obj.testBench =="io_aiu"){%>
                forever begin
                    @(posedge u_csr_probe_vif[core_id].clk);
                    cov.collect_ccr_state(core_id);
                end
            <%}%>
            //begin //for 0 credits at run_phase
            //    <% if(obj.COVER_ON) { %>
            //        `ifndef FSYS_COVER_ON
            //        cov.collect_ccr_val(core_id, );
            //        `endif 
            //    <%}%>       
            //end
  
              <%if((obj.testBench =="io_aiu") && (obj.useResiliency)){%>
                forever begin
                  @(posedge u_csr_probe_vif[core_id].clk);
                  if (u_csr_probe_vif[core_id].fault_mission_fault == 1) begin
                    <% if(obj.COVER_ON) { %>
                      `ifndef FSYS_COVER_ON
                        cov.collect_mission_fault_causes(1,u_csr_probe_vif[core_id].transport_det_en,u_csr_probe_vif[core_id].time_out_det_en,u_csr_probe_vif[core_id].prot_err_det_en,u_csr_probe_vif[core_id].mem_err_det_en);
                      `endif 
                    <%}%> 
                  end 
                end 
              <%}%>
 
  
            <%if(obj.assertOn && obj.testBench =="io_aiu"){%>
                <%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") && ((obj.testBench != "fsys") && (obj.testBench != "emu")) && (obj.testBench != "emu_t")) {%>
                    begin
                        forever begin //CONC-8515
                            @(posedge u_csr_probe_vif[core_id].clk);
                            <%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) {%>
				 <% if(obj.testBench =="io_aiu") {%>
                                <%for( var i=0;i< (obj.nOttDataBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
                                if((u_csr_probe_vif[core_id].single_error_count<%=i%> > single_error_count<%=i%> || u_csr_probe_vif[core_id].double_error_count<%=i%> > double_error_count<%=i%>) && u_csr_probe_vif[core_id].error_data<%=i%> !=0) begin
			        error_data<%=i%> = u_csr_probe_vif[core_id].error_data<%=i%>[DATA_WIDTH -1:0];
                                error_data_q.push_back({error_data<%=i%>});
                                single_error_count<%=i%> ++;
                                double_error_count<%=i%> ++;
                                end
                                <%}%>
				<%}%>

                                if(u_csr_probe_vif[core_id].sngl_nxt == 1 && u_csr_probe_vif[core_id].chip_en == 1 && u_csr_probe_vif[core_id].wr_en == 0) begin
                                    dptr_ind = u_csr_probe_vif[core_id].oc_dptr.find_last_index(x) with (x == u_csr_probe_vif[core_id].mem_err_index);
                                    err_id = u_csr_probe_vif[core_id].oc_id[dptr_ind[0]];
                                    err_addr = u_csr_probe_vif[core_id].oc_addr[dptr_ind[0]];
                                    err_id_addr_q.push_back({err_id,err_addr});
                                end
                           <%} else{%>
			     <% if(obj.testBench =="io_aiu") {%>
    			    <%for( var i=0;i< (obj.nOttDataBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
                            if(u_csr_probe_vif[core_id].double_error_count<%=i%> > double_error_count<%=i%>) begin
                                @(posedge u_csr_probe_vif[core_id].clk);
                                error_data<%=i%> = u_csr_probe_vif[core_id].error_data<%=i%>[DATA_WIDTH -1:0];
                                error_data_q.push_back({error_data<%=i%>});
                                double_error_count<%=i%> ++;
                            end
                            <%}%>
			    <%}%>
                            if(u_csr_probe_vif[core_id].dbl_nxt == 1 && u_csr_probe_vif[core_id].chip_en == 1 && u_csr_probe_vif[core_id].wr_en == 0) begin
                                dptr_ind = u_csr_probe_vif[core_id].oc_dptr.find_last_index(x) with (x == u_csr_probe_vif[core_id].mem_err_index);
                                err_id = u_csr_probe_vif[core_id].oc_id[dptr_ind[0]];
                                err_addr = u_csr_probe_vif[core_id].oc_addr[dptr_ind[0]];
                                err_id_addr_q.push_back({err_id,err_addr});
                            end
                          <%}%>
                        end
                    end
                <%}%>
            <%}%>

	<%if(obj.testBench =="io_aiu"){%>
	forever
	fork
	<%for(let i=0; i< obj.DutInfo.nNativeInterfacePorts; i+=1) {%>
	begin
		if(core_id == <%=i%>) begin
      		@(posedge u_csr_probe_vif[<%=i%>].clk); 
                	ott_no = $size(u_csr_probe_vif[<%=i%>].oc_ovt<%=i%>);
		for(int j= 0; j <= ott_no; j++) begin
			if (u_csr_probe_vif[<%=i%>].oc_ovt<%=i%>[j] && u_csr_probe_vif[<%=i%>].oc_val<%=i%>[j] && ovt_flag == 1)
	      		begin
			sv_ovt_timeout_addr = u_csr_probe_vif[<%=i%>].oc_addr<%=i%>[j];
                        sv_ovt_timeout_id = u_csr_probe_vif[<%=i%>].oc_id<%=i%>[j];
                        sv_ovt_timeout_security =  u_csr_probe_vif[<%=i%>].oc_security<%=i%>[j];
			`uvm_info(" Address @ sv_ovt_timeout ", $sformatf("address = %0p",u_csr_probe_vif[<%=i%>].oc_addr<%=i%>[j]),UVM_LOW)
			ovt_flag =0;
			break;
	        	end
	        end
	        end

	end
	<%}%>
	join
	<%}%>

            begin
                forever begin
                    @e_queue_add;
		            if(!hasErr) begin
                        txn_count++;
                        phase.raise_objection(this, $sformatf("Raising objection : %0d", txn_count));
                        //`uvm_info($sformatf("%m"), $sformatf("Raising objection:%0d", txn_count), UVM_LOW)
                    end
                end
            end
            begin
                forever begin
                    `uvm_info($sformatf("%m"), $sformatf("Before e_queue_delete event trigger ottq_size:%0d", m_ott_q.size()), UVM_LOW)
                    //if (m_ott_q.size() > 0)
                    //    m_ott_q[0].print_me(0,0,0,1);
                    @e_queue_delete;
                    `uvm_info($sformatf("%m"), $sformatf("After e_queue_delete event trigger ottq_size:%0d", m_ott_q.size()), UVM_LOW)
                    // Incase a queue add and delete happen in the same cycle, the objection should be raised before the below equation is evaluated
                    #0;

                    if (m_ott_q.size() == 0 && m_oasd_q.size() == 0 && m_oawd_q.size() == 0 && m_oancd_q.size() == 0 && (m_sysreq_q.size() == 0 || $test$plusargs("event_sys_rsp_timeout_error"))/*&& m_oawa.size() === 0 && m_oara_q.size() === 0*/ || hasErr) begin

                        int count = objection.get_objection_count(this);
                        `uvm_info($sformatf("%m"), $sformatf("Dropping all objections:%0d", count), UVM_LOW)
                        for (int i = 0; i < count; i++) begin
                            phase.drop_objection(this, $sformatf("Dropping objection:%0d", i));
                        end
                    end 
                end
            end
        join_none 
        <% if ((obj.useResiliency) && ((obj.testBench != "fsys") && (obj.testBench != "emu") && (obj.testBench != "emu_t"))) { %>
            if ($test$plusargs("expect_mission_fault")) begin
                fork
                    if(!$test$plusargs("test_unit_duplication")) begin
                        begin
                            forever begin
                                #(100*1ns);
                                if (u_csr_probe_vif[core_id].fault_mission_fault == 0) begin
                                    @u_csr_probe_vif[core_id].fault_mission_fault;
                                end
                                #(500*1ns);  // make sure enough time elapsed so we can ensure the errored request is dropped
                                `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
                                -> kill_test;   // otherwise the test will hang and timeout
                                `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_NONE)
                                phase.jump(uvm_report_phase::get());
                            end
                        end
                    end else begin
                        begin
                            forever begin
                                #(100*1ns);
                                uvm_config_db#(bit)::wait_modified(this, "", "test_unit_duplication_uecc");
                                `uvm_info(get_name(), "modified value of test_unit_duplication_uecc", UVM_LOW)
                                uvm_config_db#(bit)::get(this, "", "test_unit_duplication_uecc", test_unit_duplication_uecc);
                                if(test_unit_duplication_uecc) begin
                                    if(u_csr_probe_vif[core_id].fault_mission_fault == 0) begin
                                        @u_csr_probe_vif[core_id].fault_mission_fault;
                                    end
                                    #(500*1ns);  // make sure enough time elapsed so we can ensure the errored request is dropped
                                    `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_NONE)
                                    -> kill_test;   // otherwise the test will hang and timeout
                                    `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_NONE)
                                    phase.jump(uvm_report_phase::get());
                                end
                            end
                        end
                    end
                join_none
            end
        <%}%>
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        <% if ((obj.useResiliency) && ((obj.testBench != "fsys") && (obj.testBench != "emu") && (obj.testBench != "emu_t"))) { %>
            if($test$plusargs("expect_mission_fault")) begin
                if (u_csr_probe_vif[core_id].fault_mission_fault == 0) begin
                    `uvm_error({"fault_injector_checker_",get_name()}
                    , $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}
                    , u_csr_probe_vif[core_id].fault_mission_fault))
                end else begin
                    `uvm_info(get_name()
                    , $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"}
                    , u_csr_probe_vif[core_id].fault_mission_fault)
                    , UVM_LOW)
                end
            end
        <%}%>

        //#Cover.IOAIU.UESR.ErrType_ErrInfo
       <% if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON 
	cov.collect_uncorrectable_error(core_id);
        `endif
        <%}%> 

                uvm_report_info("AIU TB", $sformatf("-------------------UPD Req count is %d--------------------", ioaiu_scb_txn::upd_req_counter), UVM_NONE);
                `uvm_info("AIU TB", $sformatf("largest_ott_allocation cycles in this sim was %0d cycles", largest_ott_alloc_cycles), UVM_LOW);
    endfunction: report_phase

    function void end_of_simulation_phase(uvm_phase phase);
        if (!hasErr && (m_ott_q.size() > 0)) begin
            check_queues();
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("AIU SCB OutstTxn or/and OASD/OAWD/OANCD queues are not empty at end of simulation hasERR:$0d",hasErr), UVM_NONE);
            <%if(obj.useCache) { %>
                uvm_report_info("AIU TB", $sformatf("-------------------Current Cache State--------------------"), UVM_NONE);
                for(int i=0;i<m_ncbu_cache_q.size;i++) begin
                    m_ncbu_cache_q[i].print();		       
                end
            <%}%>
        end
    endfunction // report_phase
   
    <%if(obj.SCB_UNIT === undefined){%>   
        function void check_phase(uvm_phase phase);
            string arg_value; 
            string spkt;
            bit    perform_eos_num_of_req_check;
            real    m_read_bw_number;
            real    m_write_bw_number;
            clp.get_arg_value("+UVM_TESTNAME=", arg_value);
            if ((arg_value == "concerto_inhouse_ace_test" || arg_value == "bring_up_test") && !$test$plusargs("wrong_updrsp_target_id") && !$test$plusargs("wrong_cmdrsp_target_id") && !$test$plusargs("wrong_strreq_target_id") && $test$plusargs("wrong_sysrsp_target_id") && !("wrong_dtwrsp_target_id")) begin
                perform_eos_num_of_req_check = 1;
            end else begin
                perform_eos_num_of_req_check = 0;
            end
            if (!uncorr_OTT_Data_Err_effect && !($test$plusargs("ccp_double_bit_direct_ott_error_test") && (k_csr_seq ==="ioaiu_csr_uuedr_MemErrDetEn_seq" || k_csr_seq ==="ioaiu_csr_uueir_MemErrInt_seq" || k_csr_seq ==="ioaiu_csr_uuecr_sw_write_seq" || k_csr_seq ==="ioaiu_csr_elr_seq"))) begin
                print_queues();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("OTT Data Error injection status :%0d , should be non zero at the end of the test", uncorr_OTT_Data_Err_effect),UVM_NONE);
            end
            <% if(obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITY") { %>
            if (!uncorr_CCP_Tag_Err_effect && ($test$plusargs("ccp_double_bit_direct_tag_error_test") && (k_csr_seq ==="ioaiu_csr_uuedr_MemErrDetEn_seq" || k_csr_seq ==="ioaiu_csr_uueir_MemErrInt_seq" || k_csr_seq ==="ioaiu_csr_uuecr_sw_write_seq"))) begin
                print_queues();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("CCP Tag Error injection status :%0d , should be non zero at the end of the test", uncorr_CCP_Tag_Err_effect),UVM_NONE);
            end
           <% } %>

            //TODO: Ajit fix this, update to`uvm_info, and numSnoops should
            //not be printed if the interface will never get Snoops.
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("numReads=%0d numWrites=%0d numSnoops=%0d",num_reads,num_writes,num_snoops), UVM_LOW);

	    <% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
	    	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("ACE sumation_all_write_txn_counters=%0d  numWrNoSnp:%0d numWrUnq:%0d numWrLnUn:%0d numWrCln:%0d numWrBck:%0d numEvict:%0d numWrEvict:%0d",num_wrnosnp+num_wrunq+num_wrlnunq+num_wrcln+num_wrbk+num_wrevct+num_evict+num_atmld+num_atmcompare+num_atmswap+num_atmstr,num_wrnosnp,num_wrunq,num_wrlnunq,num_wrcln,num_wrbk,num_evict,num_wrevct) ,UVM_NONE);
	    	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("ACE sumation_all_read_txn_counters:%0d numRdNoSnp:%0d numRdOnce:%0d numRdShrd:%0d numRdCln:%0d numRdNotShrdDrty:%0d numRdUnq:%0d numClnUnq:%0d numMkUnq:%0d numClnShrd:%0d numClnInvld:%0d numMkInvld:%0d numDvmMsg:%0d numDvmCmp:%0d multipart_dvmnonsync_count:%d singlepart_dvmsync_count:%0d singlepart_dvmnonsync_count:%0d",num_rdnosnp+num_rdonce+num_rdshrd+num_rdcln+num_rdnotshrddir+num_rdunq+num_clnunq+num_mkunq+num_clnshrd+num_clninvl+num_mkinvl+num_dvmmsg+num_dvmcmpl,num_rdnosnp,num_rdonce,num_rdshrd,num_rdcln,num_rdnotshrddir,num_rdunq,num_clnunq,num_mkunq,num_clnshrd,num_clninvl,num_mkinvl,num_dvmmsg,num_dvmcmpl,multipart_dvmnonsync_count,singlepart_dvmsync_count,singlepart_dvmnonsync_count) ,UVM_NONE);
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("ACE sumation_all_snoop_txn_counters=%0d  numSnpInv:%0d numSnpClnDtr:%0d numSnpVldDtr:%0d numSnpInvDtr:%0d numSnpClnDtw:%0d numSnpInvDtw:%0d numSnpNitc:%0d numSnpNitcCI:%0d numSnpNitcMI:%0d numSnpNoSDInt:%0d numSnpInvStsh:%0d numSnpUnqStsh:%0d numSnpStshSh:%0d numSnpStshUnq:%0d numSnpDvmMsg:%0d",num_snp_inv+num_snp_cln_dtr+num_snp_vld_dtr+num_snp_inv_dtr+num_snp_cln_dtw+num_snp_inv_dtw+num_snp_nitc+num_snp_nitcci+num_snp_nitcmi+num_snp_nosdint+num_snp_inv_stsh+num_snp_unq_stsh+num_snp_stsh_sh+num_snp_stsh_unq+num_snp_dvm_msg,num_snp_inv,num_snp_cln_dtr,num_snp_vld_dtr,num_snp_inv_dtr,num_snp_cln_dtw,num_snp_inv_dtw,num_snp_nitc,num_snp_nitcci,num_snp_nitcmi,num_snp_nosdint,num_snp_inv_stsh,num_snp_unq_stsh,num_snp_stsh_sh,num_snp_stsh_unq,num_snp_dvm_msg),UVM_NONE);             

            <% } %>
            <% if(obj.fnNativeInterface == "ACE-LITE") {%>
 		uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("ACE-LITE sumation_all_write_txn_counters=%0d  numWrNoSnp:%0d numWrUnq:%0d numWrLnUn:%0d",num_wrnosnp+num_wrunq+num_wrlnunq,num_wrnosnp,num_wrunq,num_wrlnunq) ,UVM_NONE);
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("ACE-LITE sumation_all_read_txn_counters:%0d numRdNoSnp:%0d numRdOnce:%0d numClnShrd:%0d numClnInvld:%0d numMkInvld:%0d",num_rdnosnp+num_rdonce+num_clnshrd+num_clninvl+num_mkinvl,num_rdnosnp,num_rdonce,num_clnshrd,num_clninvl,num_mkinvl) ,UVM_NONE);
	    <% } %>
	    <% if(obj.fnNativeInterface == "ACELITE-E") {%>
		uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("ACELITE-E sumation_all_write_txn_counters=%0d  numWrNoSnp:%0d numWrUnq:%0d numWrLnUn:%0d numAtmLd:%0d numAtmComp:%0d AtmSwp:%0d numAtmStr:%0d numWrUnqPtlStash:%0d numWrUnqFullStash:%0d numStashOnceShared:%0d num_StashOnceUnq:%0d",num_wrnosnp+num_wrunq+num_wrlnunq+num_atmld+num_atmcompare+num_atmswap+num_atmstr+num_wrunqptlstash+num_wrunqfullstash+num_stashonceshared+num_stashonceunq,num_wrnosnp,num_wrunq,num_wrlnunq,num_atmld,num_atmcompare,num_atmswap,num_atmstr,num_wrunqptlstash,num_wrunqfullstash,num_stashonceshared,num_stashonceunq) ,UVM_NONE);
 		uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("ACELITE-E sumation_all_read_txn_counters:%0d numRdNoSnp:%0d numRdOnce:%0d numClnShrd:%0d numClnInvld:%0d numMkInvld:%0d numDvmMsg:%0d numDvmCmp:%0d numCleanSharedPersist:%0d numRdOnceMakeInvld:%0d numRdOnceClnInvld:%0d ",num_rdnosnp+num_rdonce+num_clnshrd+num_clninvl+num_mkinvl+num_dvmmsg+num_dvmcmpl+num_clnshardpersist+num_rdoncemakeinvld+num_rdonceclinvld,num_rdnosnp,num_rdonce,num_clnshrd,num_clninvl,num_mkinvl,num_dvmmsg,num_dvmcmpl,num_clnshardpersist,num_rdoncemakeinvld,num_rdonceclinvld) ,UVM_NONE);
              uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("ACELITE-E sumation_all_snoop_txn_counters=%0d  numSnpDvmMsg:%0d",num_snp_dvm_msg,num_snp_dvm_msg),UVM_NONE);
	    <% } %>
             
           <%if(obj.useCache) { %>   
          // #Check.Evict.Count
           if(evict_counter != cache_q_size && k_csr_seq == "ioaiu_csr_flush_all_seq") begin
           `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("The number of evictions %0d must be equal to the cache size %0d for mntop",evict_counter,cache_q_size))
           end
          <%}%>
            <%if(obj.fnNativeInterface == "AXI5"){%> 
		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("AXI5 numWriteChnlTxns:%0d numWrNoSnp:%0d numWrUnq:%0d numAtmLd:%0d numAtmStr:%0d numAtmComp:%0d AtmSwp:%0d",num_wrnosnp+num_wrunq+num_atmld+num_atmstr+num_atmcompare+num_atmswap, num_wrnosnp,num_wrunq,num_atmld,num_atmstr, num_atmcompare,num_atmswap) ,UVM_NONE);
		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("AXI5 numReadChnlTxns:%0d numRdNoSnp:%0d numRdOnce:%0d",num_rdnosnp+num_rdonce,num_rdnosnp,num_rdonce) ,UVM_NONE);
            <% } %>
            
            <%if (obj.fnNativeInterface == "AXI4")  {%> 
		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("AXI4 numWriteTxns:%0d numWrNoSnp:%0d numWrUnq:%0d ",num_wrnosnp+num_wrunq,num_wrnosnp,num_wrunq) ,UVM_NONE);
		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("AXI4 numReadTxns:%0d numRdNoSnp:%0d numRdOnce:%0d",num_rdnosnp+num_rdonce,num_rdnosnp,num_rdonce) ,UVM_NONE);
            <% } %>
            

            <%if (obj.useCache)  {%> 
                if ($test$plusargs("ioc_fill_seq"))begin
                 if ((k_num_reads+k_num_writes) != nunCachline) 
                   uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Number of transaction mismatches exp:%0d and act:%0d",nunCachline,k_num_reads+k_num_writes), UVM_NONE);
                 
               end
               if ($test$plusargs("stream_of_read_hits"))begin
                 if ((k_num_reads+k_num_writes) != numReadHits) 
                   uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Number of readhit should be equals to (read + write) exp:%0d and act:%0d",numReadHits,k_num_reads+k_num_writes), UVM_NONE);
               end
     
            <% } %>
             
            <%if(obj.useCache || obj.orderedWriteObservation == true || obj.eAc){%> 
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("numSnps:%0d  numSnpInv:%0d numSnpClnDtr:%0d numSnpVldDtr:%0d numSnpInvDtr:%0d numSnpClnDtw:%0d numSnpInvDtw:%0d numSnpNitc:%0d numSnpNitcCI:%0d numSnpNitcMI:%0d numSnpNoSDInt:%0d numSnpInvStsh:%0d numSnpUnqStsh:%0d numSnpStshSh:%0d numSnpStshUnq:%0d numSnpDvmMsg:%0d",num_snp_inv+num_snp_cln_dtr+num_snp_vld_dtr+num_snp_inv_dtr+num_snp_cln_dtw+num_snp_inv_dtw+num_snp_nitc+num_snp_nitcci+num_snp_nitcmi+num_snp_nosdint+num_snp_inv_stsh+num_snp_unq_stsh+num_snp_stsh_sh+num_snp_stsh_unq+num_snp_dvm_msg,num_snp_inv,num_snp_cln_dtr,num_snp_vld_dtr,num_snp_inv_dtr,num_snp_cln_dtw,num_snp_inv_dtw,num_snp_nitc,num_snp_nitcci,num_snp_nitcmi,num_snp_nosdint,num_snp_inv_stsh,num_snp_unq_stsh,num_snp_stsh_sh,num_snp_stsh_unq,num_snp_dvm_msg),UVM_NONE);
            <% } %>
            <%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache){%> 
                spkt= { "numReadHits:%0d,numReadMiss:%0d,numReadEvicts:%0d",
                        " numWriteHits:%0d,numWriteMiss:%0d,numWriteMissPtl:%0d,",
                        " numWriteMissFull:%0d,numWriteEvicts:%0d",
                        " numSnoopHit:%0d, numSnoopMiss:%0d, numSnoopHitEvict:%0d,",
                        " numSnoopHitOtt:%0d "};
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$psprintf(spkt,numReadHits,numReadMiss,
                                numReadEvicts,numWriteHits,numWriteMiss,numWriteMissPtl,numWriteMissFull,
                                numWriteEvicts,numSnoopHit,numSnoopMiss,numSnoopHitEvict,numSnoopHitOtt),
                                UVM_NONE);
               /*                 uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("================================================"), UVM_NONE);
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("================================================"), UVM_NONE);
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("NCBU%0d Latency numbers", m_req_aiu_id), UVM_NONE);
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("================================================"), UVM_NONE);
                uvm_report_info("", $sformatf("Min IO$ Read Hit Latency (in cycles): %0d", int'(t_min_read_hit_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Max IO$ Read Hit Latency (in cycles): %0d", int'(t_max_read_hit_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Avg IO$ Read Hit Latency (in cycles): %0d", int'(t_avg_read_hit_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Min IO$ Read Hit Latency start time: %0t address: 0x%0x", t_min_read_hit_start_time, m_min_read_hit_addr), UVM_NONE);
                uvm_report_info("", $sformatf("Min IO$ Read Miss Latency (in cycles): %0d", int'(t_min_read_miss_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Max IO$ Read Miss Latency (in cycles): %0d", int'(t_max_read_miss_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Avg IO$ Read Miss Latency (in cycles): %0d", int'(t_avg_read_miss_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Min IO$ Read Miss Latency start time: %0t address: 0x%0x", t_min_read_miss_start_time, m_min_read_miss_addr), UVM_NONE);
                uvm_report_info("", $sformatf("Min IO$ Ace Read to CmdReq Latency (in cycles): %0d", int'(t_min_ace_read_to_cmd_req_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Max IO$ Ace Read to CmdReq Latency (in cycles): %0d", int'(t_max_ace_read_to_cmd_req_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Avg IO$ Ace Read to CmdReq Latency (in cycles): %0d", int'(t_avg_ace_read_to_cmd_req_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Min IO$ Ace Read to CmdReq Latency start time: %0t address: 0x%0x", t_min_ace_read_to_cmd_req_start_time, m_min_ace_read_to_cmd_req_addr), UVM_NONE);
                uvm_report_info("", $sformatf("Min IO$ Write Hit Latency (in cycles): %0d", int'(t_min_write_hit_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Max IO$ Write Hit Latency (in cycles): %0d", int'(t_max_write_hit_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Avg IO$ Write Hit Latency (in cycles): %0d", int'(t_avg_write_hit_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Min IO$ Write Hit Latency start time: %0t address: 0x%0x", t_min_write_hit_start_time, m_min_write_hit_addr), UVM_NONE);
                uvm_report_info("", $sformatf("Min IO$ Write Miss Latency (in cycles): %0d", int'(t_min_write_miss_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Max IO$ Write Miss Latency (in cycles): %0d", int'(t_max_write_miss_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Avg IO$ Write Miss Latency (in cycles): %0d", int'(t_avg_write_miss_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Min IO$ Write Miss Latency start time: %0t address: 0x%0x", t_min_write_miss_start_time, m_min_write_miss_addr), UVM_NONE);
                uvm_report_info("", $sformatf("Min IO$ Ace Write to CmdReq Latency (in cycles): %0d", int'(t_min_ace_write_to_cmd_req_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Max IO$ Ace Write to CmdReq Latency (in cycles): %0d", int'(t_max_ace_write_to_cmd_req_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Avg IO$ Ace Write to CmdReq Latency (in cycles): %0d", int'(t_avg_ace_write_to_cmd_req_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Avg IO$ Ace Write to DtwReq Latency (in cycles): %0d", int'(t_ace_write_data_str_req_to_dtw_reqf_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Min IO$ Ace Write to CmdReq Latency start time: %0t address: 0x%0x", t_min_ace_write_to_cmd_req_start_time, m_min_ace_write_to_cmd_req_addr), UVM_NONE);
                uvm_report_info("", $sformatf("Min Snoop Latency (in cycles): %0d", int'(t_min_snoop_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Max Snoop Latency (in cycles): %0d", int'(t_max_snoop_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Avg Snoop Latency (in cycles): %0d", int'(t_avg_snoop_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Min Snoop Latency start time: %0t address: 0x%0x", t_min_snoop_start_time, m_min_snoop_addr), UVM_NONE);
                uvm_report_info("", $sformatf("Min SMI to AXI Latency (in cycles): %0d", int'(t_min_smi_to_axi_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Max SMI to AXI Latency (in cycles): %0d", int'(t_max_smi_to_axi_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Avg SMI to AXI Latency (in cycles): %0d", int'(t_avg_smi_to_axi_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Min SMI to AXI Latency start time: %0t address: 0x%0x", t_min_smi_to_axi_start_time, m_min_smi_to_axi_addr), UVM_NONE);
                uvm_report_info("", $sformatf("Min Snoop to Resp Latency (in cycles): %0d", int'(t_min_snoop_to_resp_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Max Snoop to Resp Latency (in cycles): %0d", int'(t_max_snoop_to_resp_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Avg Snoop to Resp Latency (in cycles): %0d", int'(t_avg_snoop_to_resp_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
                uvm_report_info("", $sformatf("Min Snoop to Resp Latency start time: %0t address: 0x%0x", t_min_snoop_to_resp_start_time, m_min_snoop_to_resp_addr), UVM_NONE);
               */
            <%}else{%>
                `ifndef BLK_SNPS_ACE_VIP
                    `ifndef SYS_SNPS_ACE_VIP
                        `ifndef PSEUDO_SYS_TB        
                        `endif
                        // #Check.AIU.NoPktsSentFail 
                        // #Check.IOC.NoPktsSentFail 
                        if (perform_eos_num_of_req_check) begin
                            // For PSYS, num_reads could be less than k_num_reads. This can happen when there are a lot of DVMCMPL since those do not get counted as a num_read
                            if (num_reads < k_num_reads-20) begin
                                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Knob k_num_reads mismatches actual number of reads sent at end of simulation (reads Sent: %0d Knob: %0d)", num_reads, k_num_reads), UVM_NONE);
                            end
                            if (num_writes < k_num_writes) begin
                                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Knob k_num_writes mismatches actual number of writes sent at end of simulation (writes Sent: %0d Knob: %0d)", num_writes, k_num_writes), UVM_NONE);
                            end
                        end
                    `endif
                `endif
            <%}%>      
          /*  
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("================================================"), UVM_NONE);
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("NCBU%0d Latency numbers", m_req_aiu_id), UVM_NONE);
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("================================================"), UVM_NONE);
            uvm_report_info("", $sformatf("Min Read Latency (in cycles): %0d", int'(t_min_read_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Max Read Latency (in cycles): %0d", int'(t_max_read_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Avg Read Latency (in cycles): %0d", int'(t_avg_read_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Min Read Latency start time: %0t address: 0x%0x", t_min_read_start_time, m_min_read_addr), UVM_NONE);
            uvm_report_info("", $sformatf("Min Ace Read to CmdReq Latency (in cycles): %0d", int'(t_min_ace_read_to_cmd_req_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Max Ace Read to CmdReq Latency (in cycles): %0d", int'(t_max_ace_read_to_cmd_req_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Avg Ace Read to CmdReq Latency (in cycles): %0d", int'(t_avg_ace_read_to_cmd_req_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Min Ace Read to CmdReq Latency start time: %0t address: 0x%0x", t_min_ace_read_to_cmd_req_start_time, m_min_ace_read_to_cmd_req_addr), UVM_NONE);
            uvm_report_info("", $sformatf("Min Write Latency (in cycles): %0d", int'(t_min_write_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Max Write Latency (in cycles): %0d", int'(t_max_write_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Avg Write Latency (in cycles): %0d", int'(t_avg_write_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Min Write Latency start time: %0t address: 0x%0x", t_min_write_start_time, m_min_write_addr), UVM_NONE);
            uvm_report_info("", $sformatf("Min Ace Write to CmdReq Latency (in cycles): %0d", int'(t_min_ace_write_to_cmd_req_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Max Ace Write to CmdReq Latency (in cycles): %0d", int'(t_max_ace_write_to_cmd_req_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Avg Ace Write to CmdReq Latency (in cycles): %0d", int'(t_avg_ace_write_to_cmd_req_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Min Ace Write to CmdReq Latency start time: %0t address: 0x%0x", t_min_ace_write_to_cmd_req_start_time, m_min_ace_write_to_cmd_req_addr), UVM_NONE);
            uvm_report_info("", $sformatf("Min SMI to AXI Latency (in cycles): %0d", int'(t_min_smi_to_axi_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Max SMI to AXI Latency (in cycles): %0d", int'(t_max_smi_to_axi_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Avg SMI to AXI Latency (in cycles): %0d", int'(t_avg_smi_to_axi_transaction)/<%=obj.clkPeriodPs%>), UVM_NONE);
            uvm_report_info("", $sformatf("Min SMI to AXI Latency start time: %0t address: 0x%0x", t_min_smi_to_axi_start_time, m_min_smi_to_axi_addr), UVM_NONE);
          */  
            t_read_throughput    = (t_last_read_complete_time - t_read_start_time)/num_reads;
            t_write_throughput   = (t_last_write_complete_time - t_write_start_time)/num_writes;
            m_read_bw_number     = (real'(m_bw_read_counter * WXDATA/8) / real'(t_last_read_complete_time - t_read_bw_start_calc_time)); 
            m_write_bw_number    = (real'(m_bw_write_counter * WXDATA/8) / real'(t_last_write_complete_time - t_write_bw_start_calc_time)); 
        
            if ($test$plusargs("performance_test") || $test$plusargs("perf_test")) begin
                `uvm_info(get_full_name(), $sformatf("Read BW Start Time:%0t End Time:%0t Period:%0t Counter:%0d ",t_read_bw_start_calc_time, t_last_read_complete_time, t_timeperiod, m_bw_read_counter),UVM_NONE);
                uvm_report_info(get_full_name(), $sformatf("Read BW throughput   (in cycles): %0d", int'(t_read_throughput)/10000), UVM_NONE);
                uvm_report_info(get_full_name(), $sformatf("Read BW              (GB/s)     : %.2f", real'(m_read_bw_number*1000)), UVM_NONE);
                `uvm_info(get_full_name(), $sformatf("Write BW Start Time:%0t End Time:%0t Period:%0t Counter:%0d ",t_write_bw_start_calc_time, t_last_write_complete_time, t_timeperiod, m_bw_write_counter),UVM_NONE);
                uvm_report_info(get_full_name(), $sformatf("write BW throughput  (in cycles): %0d", int'(t_write_throughput)/10000), UVM_NONE);
                uvm_report_info(get_full_name(), $sformatf("Write BW             (GB/s)     : %.2f", real'(m_write_bw_number*1000)), UVM_NONE);
                uvm_report_info(get_full_name(), $sformatf("Write(wb)      throughput (in cycles): %0d", int'(t_write_throughput)/10000), UVM_NONE);
                if ($test$plusargs("read_latency_test")) begin
                    uvm_report_info("", $sformatf("Latency :ACERdreq to CmdReq                 (in cycles): %0d", int'(t_avg_ace_read_to_cmd_req_transaction)/10000), UVM_NONE);
                    uvm_report_info("", $sformatf("Latency :STRReq + DTRReq to ACE Rd Resp     (in cycles): %0d", int'(t_str_req_dtr_req_to_ace_read_rsp_transaction)/10000), UVM_NONE);
                    uvm_report_info("", $sformatf("Latency :RACK to STRRsp                     (in cycles): %0d", int'(t_rack_to_str_rsp_transaction)/10000), UVM_NONE);
                end
                if ($test$plusargs("wrlnUnq_latency_test")) begin
                    uvm_report_info("", $sformatf("Latency :ACE Wr Req to CmdReq               (in cycles): %0d", int'(t_avg_ace_write_to_cmd_req_transaction)/10000), UVM_NONE);
                    uvm_report_info("", $sformatf("Latency :ACE Wr Data+STRReq to DTWReq       (in cycles): %0d", int'(t_ace_write_data_str_req_to_dtw_reqf_transaction)/10000), UVM_NONE);
                    uvm_report_info("", $sformatf("Latency :DTWRsp to BResp                    (in cycles): %0d", int'(t_dtw_rsp_to_brsp_transaction)/10000), UVM_NONE);
                    uvm_report_info("", $sformatf("Latency :WACK to STRResp                    (in cycles): %0d", int'(t_wack_to_str_rsp_transaction)/10000), UVM_NONE);
                end

                if ($test$plusargs("wb_latency_test")) begin
                    uvm_report_info("", $sformatf("Latency :ACE Wr Req+ACE Wr Data to DTWReq   (in cycles): %0d", int'(t_ace_write_req_write_data_to_dtw_req_transaction)/10000), UVM_NONE);
                    uvm_report_info("", $sformatf("Latency :DTWRsp to UPDReq                   (in cycles): %0d", int'(t_dtw_rsp_to_upd_req_transaction)/10000), UVM_NONE);
                    uvm_report_info("", $sformatf("Latency :UPDRsp to BResp                    (in cycles): %0d", int'(t_upd_rsp_to_brsp_transaction)/10000), UVM_NONE);
                end
                if ($test$plusargs("read_bw_test")) begin
                    if (m_read_bw_number  != NCBU_RDBW) begin
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Read BW mismatches expected :%0d actual :%0d ",NCBU_RDBW,m_read_bw_number));
                    end
                end
                if ($test$plusargs("write_bw_test") && !$test$plusargs("wrlnUnq_latency_test")) begin
                    if (m_write_bw_number  != NCBU_WRLNUNQBW) begin
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Write BW mismatches expected :%0d actual :%0d ",NCBU_WRLNUNQBW,m_write_bw_number));
                    end
                end
                if ($test$plusargs("read_latency_test")) begin
                    if ((int'(t_avg_ace_read_to_cmd_req_transaction)/10000)  != NCBU_LRDREQTOCMDREQ) begin
                        uvm_report_error($sformatf("AIU%0d SCB", m_req_aiu_id), $sformatf("latency ace_read_to_cmd_req mismatches expected :%0d actual :%0d",NCBU_LRDREQTOCMDREQ,int'(t_avg_ace_read_to_cmd_req_transaction)/10000), UVM_NONE);
                    end
                    if ((int'(t_str_req_dtr_req_to_ace_read_rsp_transaction)/10000)  != NCBU_LRDSTRDTRREQTOACERDRSP) begin
                        uvm_report_error($sformatf("AIU%0d SCB", m_req_aiu_id), $sformatf("latency str_req_dtr_req_to_ace_read_rsp mismatches expected :%0d actual :%d",NCBU_LRDSTRDTRREQTOACERDRSP,int'(t_str_req_dtr_req_to_ace_read_rsp_transaction)/10000), UVM_NONE);
                    end
                    if ((int'(t_rack_to_str_rsp_transaction)/10000)  != NCBU_LRDRACTOSTRRSP ) begin
                        uvm_report_error($sformatf("AIU%0d SCB", m_req_aiu_id), $sformatf("latency rack_to_str_rsp_transaction mismatches expected :%0d actual :%0d",NCBU_LRDRACTOSTRRSP,int'(t_rack_to_str_rsp_transaction)/10000), UVM_NONE);
                    end
                end
                if ($test$plusargs("wrlnUnq_latency_test")) begin
                    if ((int'(t_avg_ace_write_to_cmd_req_transaction)/10000)  != NCBU_LWRLNUNQWRREQTOCMDREQ) begin
                        uvm_report_error($sformatf("AIU%0d SCB", m_req_aiu_id), $sformatf("latency ace_write_to_cmd_req mismatches expected :%0d actual :%0d",NCBU_LWRLNUNQWRREQTOCMDREQ,int'(t_avg_ace_write_to_cmd_req_transaction)/10000), UVM_NONE);
                    end
                    if ((int'(t_ace_write_data_str_req_to_dtw_req_transaction)/10000)  != NCBU_LRDSTRDTRREQTOACERDRSP) begin
                        uvm_report_error($sformatf("AIU%0d SCB", m_req_aiu_id), $sformatf("latency ace_write_data_str_req_to_dtw_req mismatches expected :%0d actual :%d",NCBU_LWRDATASTRREQTODTWREQ,int'(t_ace_write_data_str_req_to_dtw_req_transaction)/10000), UVM_NONE);
                    end
                    if ((int'(t_dtw_rsp_to_brsp_transaction)/10000)  != NCBU_LWRLNUNQDTWRSPTOBRESP ) begin
                        uvm_report_error($sformatf("AIU%0d SCB", m_req_aiu_id), $sformatf("latency dtw_rsp_to_brsp mismatches expected :%0d actual :%0d",NCBU_LWRLNUNQDTWRSPTOBRESP,int'(t_dtw_rsp_to_brsp_transaction)/10000), UVM_NONE);
                    end
                    if ((int'(t_wack_to_str_rsp_transaction)/10000)  != NCBU_LWRLNUNQWACKTOSTRRSP ) begin
                        uvm_report_error($sformatf("AIU%0d SCB", m_req_aiu_id), $sformatf("latency wack_to_str_rsp mismatches expected :%0d actual :%0d",NCBU_LWRLNUNQWACKTOSTRRSP,int'(t_wack_to_str_rsp_transaction)/10000), UVM_NONE);
                    end
                end
            end
        
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("================================================"), UVM_NONE);
            if (!hasErr && (m_ott_q.size() > 0 || m_oasd_q.size() > 0 || m_oawd_q.size() > 0 || m_oancd_q.size() > 0 || m_mntop_q.size()>0)) begin
                check_queues();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("AIU SCB OutstTxn or/and OASD/OAWD/OANCD queues are not empty at end of simulation"), UVM_NONE);
            end else begin
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("PASS: No Pending Transactions in AIU Scoreboard"), UVM_NONE);
            end

            //Check that all SysReq Events had an associated SysRsp
            if(m_sysreq_q.size() != 0 && !$test$plusargs("event_sys_rsp_timeout_error") && !hasErr)begin
                `uvm_info(`LABEL,$sformatf("Below Sys Req Transactions are still pending"), UVM_NONE)
                foreach(m_sysreq_q[sys_req_pkt]) begin
                    `uvm_info(`LABEL,$sformatf("%s", m_sysreq_q[sys_req_pkt].convert2string()), UVM_NONE)
                end
                `uvm_error(`LABEL_ERROR, $sformatf("=====Above packets are still Pending ====="))
            end
        endfunction
    <%}%>
    <%if(obj.SCB_UNIT === undefined){%>
        function bit check_queues();
          //#Check.IOAIU.EOT.OttqEmpty
            if (!hasErr && (m_ott_q.size() > 0 || m_oasd_q.size() > 0 || m_oawd_q.size() > 0 || m_oancd_q.size() > 0 || m_mntop_q.size()>0)) begin
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("AIU SCB OutstTxn or/and OASD/OAWD/OANCD queues are not empty at end of simulation"), UVM_NONE);
                print_queues();
                return(1'b1);
                <% if (obj.Block === "psys") { %>
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Potential SYSTEM HANG! Please debug"), UVM_NONE);
                <% } %>
            end else begin
                return(1'b0);
            end
        endfunction : check_queues
    <%}%>
    //----------------------------------------------------------------------- 
    // SYSReq event  
    //----------------------------------------------------------------------- 
    <% if(obj.testBench=="fsys" || obj.testBench =="io_aiu"){ %>
     <% if( obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
    function void write_event_sender_chnl(<%=obj.BlockId%>_event_agent_pkg::event_pkt sys_event);
       int queue_size;
       int x = 0;
       bit sysrsp_id_q[$];
       int m_tmp_q[$];
       ioaiu_scb_txn         m_scb_txn;
    
        if(sys_event.req==1 && sys_event.prev_req==0) begin
            m_scb_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen,csr_ccp_updatedis, , core_id);
       	    tb_txn_count++;
            m_scb_txn.setup_sys_evt_req(sys_event);
	    m_scb_txn.tb_txnid = tb_txn_count;
	    m_scb_txn.core_id = core_id;
            m_ott_q.push_back(m_scb_txn);
         `uvm_info("IOAIU_SCB_Event", $psprintf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> :Received below EVENT REQ on event Sender interface:%0s",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,sys_event.convert2string()) ,UVM_LOW);
        end
        if(sys_event.ack==1 && sys_event.prev_ack==0) begin
            m_tmp_q={};
            m_tmp_q = m_ott_q.find_index with ( item.isSenderSysRspRcvd == 1 && item.isSenderEventAckNeeded == 1 );
            if(m_tmp_q.size()==0 ) begin
               m_tmp_q = m_ott_q.find_index with ( item.isSenderSysRspRcvd == 0 && item.isSenderEventAckNeeded == 1 );
               if($test$plusargs("event_sys_rsp_timeout_error") && m_tmp_q.size() != 0) begin
                 m_ott_q[m_tmp_q[0]].setup_evt_ack(sys_event);
                 if(m_ott_q[m_tmp_q[0]].isComplete()) begin
                      delete_ott_entry(m_tmp_q[0], SenderEventReq);
                 end
               end
               else
               `uvm_error("<%=obj.strRtlNamePrefix%> SCB_ERROR", $sformatf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> SysRsp not found in OTT  Received below Sender EVENT packet at IOAIU SCB: %0s",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,sys_event.convert2string()))
            end else begin
                m_ott_q[m_tmp_q[0]].setup_evt_ack(sys_event);
                if(m_ott_q[m_tmp_q[0]].isComplete()) begin
                      delete_ott_entry(m_tmp_q[0], SenderEventReq);
                end        
            end
        end    
    endfunction : write_event_sender_chnl
        <%}%>
     <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false ) { %>

    function void write_event_reciever_chnl(<%=obj.BlockId%>_event_agent_pkg::event_pkt sys_event);
       int m_tmp_q[$];
        if(sys_event.req==1 && sys_event.ack==1) begin
        // setup event request
               `uvm_info("IOAIU_SCB_Event", $psprintf("DISP1 <%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> :Received below EVENT REQ on event Reciever interface:%0s",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,sys_event.convert2string()) ,UVM_LOW);
            m_tmp_q={};
            m_tmp_q = m_ott_q.find_index with ( item.isRecieverSysReqRcvd == 1 && item.isRecieverEventReqNeeded == 1 );
            if(m_tmp_q.size()==0) begin
               `uvm_error("<%=obj.strRtlNamePrefix%> SCB_ERROR", $sformatf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%>: SysReq not found in OTT  Received below Reciever EVENT packet at IOAIU SCB: %0s",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,sys_event.convert2string()))
            end else if(m_tmp_q.size()>1) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB_ERROR", $sformatf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> SysReq found multiple entries in OTT Reciever EVENT packet at IOAIU SCB",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>))
            end else begin
                m_ott_q[m_tmp_q[0]].setup_rcv_evt_req(sys_event);
               `uvm_info("IOAIU_SCB_Event", $psprintf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> :Received below EVENT REQ on event Reciever interface:%0s",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,sys_event.convert2string()) ,UVM_LOW);
            end        
        // end   
        //if(sys_event.ack==1 ) begin

        // setup event ack
            m_tmp_q={};
            m_tmp_q = m_ott_q.find_index with ( item.isRecieverEventReqSent == 1 && item.isRecieverEventAckNeeded == 1 );
            if(m_tmp_q.size()==0) begin
               `uvm_error("<%=obj.strRtlNamePrefix%> SCB_ERROR", $sformatf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%>: Event Req not found in OTT  Received below Reciever EVENT packet at IOAIU SCB: %0s",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,sys_event.convert2string()))
            end else if(m_tmp_q.size()>1) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB_ERROR", $sformatf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Event Req found multiple entries in OTT Reciever EVENT packet at IOAIU SCB",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>))
            end else begin
                m_ott_q[m_tmp_q[0]].setup_rcv_evt_ack(sys_event);
               `uvm_info("IOAIU_SCB_Event", $psprintf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> :Received below EVENT ACK on event Reciever interface:%0s",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,sys_event.convert2string()) ,UVM_LOW);
            end
        end  
    endfunction : write_event_reciever_chnl
        <%}%>
        <%}%>
    //----------------------------------------------------------------------- 
    // ACE Read Address Channel
    //----------------------------------------------------------------------- 
    function void write_ncbu_read_addr_chnl(axi4_read_addr_pkt_t m_pkt);
        int                 m_prot_ott_q[$];
        int                 m_tmp_q[$];
        int                 m_tmp_qA[$];
        int                 m_tmp_q1[$];
        ace_read_addr_pkt_t m_packet;
        ace_read_addr_pkt_t m_owo_pkt;
        ace_read_addr_pkt_t m_packet_tmp;
        ioaiu_scb_txn         m_scb_txn;
        ioaiu_scb_txn         m_search_id_q[$];
        read_pkt_info_t     rd_info;
        int  fnmem_region_idx,dest_id;
        bit rd_req_data_crosses_32B_boundary = 0;

        m_packet_tmp = new();
        m_packet = new();
        $cast(m_packet_tmp, m_pkt);
        m_packet.copy(m_packet_tmp);
        
        if (owo == 1 && m_packet.arsnoop != 'h0) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIUp does not expect <%=obj.fnNativeInterface%>_WrReq:%0s", m_packet.sprint_pkt()));
        end
		
        if((m_packet.arbar[0] == 0) && ((m_packet.ardomain == 2'b01) || (m_packet.ardomain == 2'b10)) && ((m_packet.arsnoop == 'b1110)) && (m_packet.araddr == '0)) begin //This is  DVM CMPL on AR Channel (hand shake for DVMSYNC SNoop)
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Received below <%=obj.fnNativeInterface%>_RdReq DVMCMPL packet on AR channel: %0s", m_packet.convert2string()), UVM_LOW)

      	    m_tmp_q = {};
      	    m_tmp_q = m_ott_q.find_index with ( item.matchACEReadAddr(m_packet) );
      	    
      	    if(m_tmp_q.size() == 0) begin
            	if(!(hasErr || $test$plusargs("inject_smi_uncorr_error")))
	            	uvm_report_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR",$sformatf("Cannot find matching pkt for ACEReadAddr %s",m_packet.sprint_pkt()),UVM_NONE,"ACEReadAddrNoMatch");
      	    end
      	    else begin
		    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d Received below <%=obj.fnNativeInterface%>_RdReq DVMCMPL packet on AR channel:%0s", m_ott_q[m_tmp_q[0]].tb_txnid, m_packet.sprint_pkt()), UVM_LOW)
	 	    	m_ott_q[m_tmp_q[0]].setup_ace_dvm_cmp_read_addr(m_packet);
             	
             	if((m_ott_q[m_tmp_q[0]].txn_type == "DVMSYNC") &&
                	m_ott_q[m_tmp_q[0]].smi_flags["ACEReadAddr"]) begin
                		m_num_dvm_snp_compl++;
                		uvm_report_info("IOAIU_SCB_<%=obj.BlockId%>",$sformatf("Received DVM COMPLETE for DVM SNP SYNC, m_num_dvm_snp_compl = %0d", m_num_dvm_snp_compl),UVM_DEBUG);
                        m_dvm_completed.trigger();
            	end
      	    end
            //FIXME - Kavish Speak to Hema on how to handle DVMCMPL on AR Channel
            return;
        end else 
            tb_txn_count++;

         if ($test$plusargs("eviction_seq") || $test$plusargs("ioc_stream_of_alloc_ops_some_sets_seq")  || $test$plusargs("ioc_stream_of_alloc_ops_some_sets_seq_new")) begin
	 <%if(obj.useCache){%>
           if(!(addrMgrConst::get_set_index(m_packet.araddr,<%=obj.FUnitId%>) inside {ccp_index_q}))begin 
             ccp_index_q.push_back(addrMgrConst::get_set_index(m_packet.araddr,<%=obj.FUnitId%>));
             if(ccp_index_q.size() > k_num_sets)            
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("TB Error: Indexq.size should be equal to k_num_sets:%0d act:%0d", k_num_sets,  ccp_index_q.size()));
           end
 <%}%>
 
          end
        
        if($test$plusargs("perf_test")) begin
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below <%=obj.fnNativeInterface%>_RdReq:%0s", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt()) ,UVM_NONE);
        end else begin
            if (owo && (<%=obj.AiuInfo[obj.Id].wData%> == 512)) begin
    	        void'($cast(m_owo_pkt, m_packet.clone()));
                rd_req_data_crosses_32B_boundary = req_data_crosses_cacheline_midpoint(m_owo_pkt.araddr, (1 << m_owo_pkt.arsize));
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received <%=obj.fnNativeInterface%>_RdReq:%0s cc:%0d", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt(), cycle_counter) ,UVM_LOW);
                if (m_packet.arsize == 6) begin 
                    m_packet.arsize = 5;
                    m_packet.arlen = (m_owo_pkt.araddr[5] == 1) ? ((m_owo_pkt.arlen+1)*2) - 2 : ((m_owo_pkt.arlen + 1)*2) - 1; 
                end 
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Post data-width adapter(axi_shim) <%=obj.fnNativeInterface%>_RdReq:%0s", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt()) ,UVM_LOW);
            end else begin  
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received <%=obj.fnNativeInterface%>_RdReq:%0s cc:%0d", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt(), cycle_counter) ,UVM_LOW);
            end
        end

        if (!($test$plusargs("csr_access_via_nativeintf")))
		check_address_core_id(m_packet.araddr);
        
        rd_info.max_beats_in_cacheline = SYS_nSysCacheline/(<%=obj.AiuInfo[obj.Id].wData%>/8);
        rd_info.current_beat = (m_packet.araddr % SYS_nSysCacheline)/(<%=obj.AiuInfo[obj.Id].wData%>/8);
        rd_info.arid = m_packet.arid;
        rd_info.read_complete = 0;

        read_packets.push_back(rd_info);

        if(({ m_packet.ardomain, m_packet.arsnoop} == 'b01_1111) ||
            ({ m_packet.ardomain, m_packet.arsnoop} == 'b10_1111)) begin //DVMMSG
            if(m_packet.araddr[0] == 0 || (m_packet.araddr[0] == 1 && is_multi_part_dvm==1)) begin
                //two part DVM, recieved 2nd part
                if(is_multi_part_dvm == 1) begin
		            m_tmp_q = {};
                    m_tmp_q = m_ott_q.find_index with (
						    item.m_ace_cmd_type == DVMMSG &&
						    item.isACEReadAddressDVMNeeded &&
						    !item.isACEReadAddressDVMRecd
						    );
                    if(m_tmp_q.size() > 1)
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Multi DVM found multiple outstanding multi part 1 DVMs"));
                    else if(m_tmp_q.size() == 0)
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Did Not Find matching Multi Part 1 DVM Req"));
                    else
                        m_scb_txn = m_ott_q[m_tmp_q[0]];
                    
                    m_scb_txn.setup_ace_multi_part_dvm_read_req(m_packet);
                    <%if (Object.keys(DVM_intf).includes(obj.fnNativeInterface)) {%>
                    `ifndef FSYS_COVER_ON
                        cov.araddr = m_packet.araddr;
                        cov.DVM_master_part2_<%=DVM_intf[obj.fnNativeInterface]%>.sample();
                        //$display("KDB00 cvg part2 sample araddr=%0h", cov.araddr);
                    `endif
                    <% if(obj.IO_SUBSYS_SNPS) { %> 
                        if (ioaiu_cov_dis==0) begin
                        cov.araddr = m_packet.araddr;
                        cov.DVM_master_part2_<%=DVM_intf[obj.fnNativeInterface]%>.sample();
                        end
                       <% } %>

                    <%}%>

                    is_multi_part_dvm = 0;
                    multipart_dvmnonsync_count++;
                    return;
	            end else begin  //single part DVM
                    is_multi_part_dvm = 0;
                    if(m_packet.araddr[14:12] ==3'b100) begin
                         singlepart_dvmsync_count++;
                    end else begin
                         singlepart_dvmnonsync_count++;
                    end
                    <%if (Object.keys(DVM_intf).includes(obj.fnNativeInterface)) {%>
                    `ifndef FSYS_COVER_ON
                        cov.araddr = m_packet.araddr;
                        $cast(dvm_opType,  cov.araddr[14:12]);
                        cov.DVM_master_part1_<%=DVM_intf[obj.fnNativeInterface]%>.sample();
                        //$display("KDB00 cvg sample araddr=%0h, DVM_OP_Type=%s", cov.araddr, dvm_opType);
                    `endif
                     <% if(obj.IO_SUBSYS_SNPS) { %> 
                        if (ioaiu_cov_dis==0) begin
                           cov.araddr = m_packet.araddr;
                           $cast(dvm_opType, cov.araddr[14:12]);
                           cov.DVM_master_part1_<%=DVM_intf[obj.fnNativeInterface]%>.sample();
                        end
                       <% } %>
                    <%}%>
                end
            end else begin //two part DVM, received 1st part
                if(is_multi_part_dvm) begin
	                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Two DVM Msgs interleaved with each other! AR pkt: %s", m_pkt.sprint_pkt()),UVM_NONE);
                end else begin
                    is_multi_part_dvm = 1;
                    <%if (Object.keys(DVM_intf).includes(obj.fnNativeInterface)) {%>
                    `ifndef FSYS_COVER_ON
                        cov.araddr = m_packet.araddr;
                        $cast(dvm_opType,cov.araddr[14:12]);
                        cov.DVM_master_part1_<%=DVM_intf[obj.fnNativeInterface]%>.sample();
                        //$display("KDB00 cvg sample araddr=%0h, DVM_OP_Type=%s", cov.araddr, dvm_opType);
                    `endif
                    <% if(obj.IO_SUBSYS_SNPS) { %> 
                        if (ioaiu_cov_dis==0) begin
                          cov.araddr = m_packet.araddr;
                          $cast(dvm_opType,cov.araddr[14:12]);
                          cov.DVM_master_part1_<%=DVM_intf[obj.fnNativeInterface]%>.sample();
                        end
                       <% } %>
                    <%}%>
                end
	        end

            //check outstanding DVM SYNC
            if(m_packet.araddr[14:12] == 3'b100) begin
		        m_tmp_q = {};
                m_tmp_q = m_ott_q.find_index with (
						item.m_ace_cmd_type == DVMMSG &&
						item.isDVMSync &&
					        !item.isACESnoopReqSent
						);
                if(m_tmp_q.size() != 0) begin
	                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("TB ERROR: there is more than one outstanding DVM SYNC MSG"), UVM_NONE);
                    foreach(m_tmp_q[idx])
                        m_ott_q[m_tmp_q[idx]].print_me(0,1);
	                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("TB ERROR: there is more than one outstanding DVM SYNC MSG"));
                end
            end
        end else if(is_multi_part_dvm) begin
	        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Non DVM Msg interleaved with DVM! AR pkt: %s", m_pkt.sprint_pkt()),UVM_NONE);
        end
        
            <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
		//CONC-9697 In ACE, we should not hit any outstanding CMOs to the same address. If we did, fix BFM.		
		m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with ((item.isRead == 1) &&
        								   (item.m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] === m_packet.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]) &&
        								  <% if (obj.wSecurityAttribute > 0) { %>
                                           (item.m_ace_read_addr_pkt.arprot[1] === m_packet.arprot[1]) &&
                                           <% } %>
   										   (item.m_ace_cmd_type inside {CLNSHRD, CLNINVL, MKINVL, CLNSHRDPERSIST}) && 
										   (item.isACEReadDataSent == 0));

		if (m_tmp_q.size() > 0 && (m_packet.arcmdtype != RDNOSNP))
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Above read request seen on nativeInterface when there is an outstanding CMO to the same address at OutstTxn #%0d", m_tmp_q[0]), UVM_NONE);
 <%}%>

        m_scb_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen,csr_ccp_updatedis, m_packet.araddr, core_id);
        m_scb_txn.m_regs = this.m_regs;
		m_scb_txn.transOrderMode_rd = transOrderMode_rd;
		m_scb_txn.transOrderMode_wr = transOrderMode_wr;
                if (owo && (<%=obj.AiuInfo[obj.Id].wData%> == 512)) begin
                    void'($cast(m_scb_txn.m_owo_native_rd_addr_pkt, m_owo_pkt.clone()));
                end
        m_scb_txn.setup_ace_read_req(m_packet, cycle_counter);
        if (m_scb_txn.m_ace_cmd_type inside {CLNUNQ, MKUNQ, CLNSHRD, CLNSHRDPERSIST, CLNINVL, MKINVL}) 
          timeout_err_cmd_type = 2'b10;
        else 
          timeout_err_cmd_type = 2'b00;


 
	    dest_id = m_scb_txn.isDVM ? DVE_FUNIT_IDS[0] : addrMgrConst::map_addr2dmi_or_dii(m_packet.araddr,fnmem_region_idx);
            
        if(m_scb_txn.mem_regions_overlap || ($test$plusargs("unmapped_add_access") && ((dest_id == -1 && fnmem_region_idx == -1) ))) begin //There is no way to get configure address region map in GPR register so using plusharg
           if(addr_trans_mgr::check_unmapped_add(m_packet.araddr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) begin
            csr_addr_decode_err_addr_q.push_back(m_packet.araddr);
            csr_addr_decode_err_msg_id_q.push_back(m_packet.arid);
            csr_addr_decode_err_type_q.push_back(dec_err_type);
            csr_addr_decode_err_cmd_type_q.push_back(1'b0);
           end
           else begin
            csr_addr_decode_err_addr_q.push_back(m_packet.araddr);
            csr_addr_decode_err_msg_id_q.push_back(m_packet.arid);
            csr_addr_decode_err_cmd_type_q.push_back(1'b0);
           end
        end
        if(m_scb_txn.illegalNSAccess ||m_scb_txn.illDIIAccess  || m_scb_txn.illegalCSRAccess ) begin
         csr_addr_decode_err_addr_q.push_back(m_packet.araddr);
            csr_addr_decode_err_msg_id_q.push_back(m_packet.arid);
            csr_addr_decode_err_cmd_type_q.push_back(1'b0);
        end
        if($test$plusargs("no_credit_check")) begin
            csr_addr_decode_err_addr_q.push_back(m_packet.araddr);
            csr_addr_decode_err_msg_id_q.push_back(m_packet.arid);
            csr_addr_decode_err_type_q.push_back(3'b111); //NO credit access
            csr_addr_decode_err_cmd_type_q.push_back(1'b0);
        end
        if ($test$plusargs("unmapped_add_access")) begin
        case (core_id) 
<%for(let i=0; i<obj.nNativeInterfacePorts; i++) {%>
          <%=i%> :  ev_ar_req_<%=i%>.trigger();
<%}%>
        endcase
        end
        set_sleeping(m_scb_txn);
        <%if(obj.useCache){%>
            if (csr_ccp_lookupen) set_cacheline_way(m_scb_txn);
        <%}%>
        <% if(obj.COVER_ON) { %>
            `ifndef FSYS_COVER_ON
            cov.collect_axi_araddr(m_scb_txn, core_id);
            `endif
        <% } else if(obj.IO_SUBSYS_SNPS) { %> 
            if (ioaiu_cov_dis==0) begin
            cov.collect_axi_araddr(m_scb_txn, core_id);
            end
        <%}%>       

        <%if ((obj.fnNativeInterface != "AXI4") && (obj.fnNativeInterface != "AXI5"))  {%> 
            if($test$plusargs("performance_test") || $test$plusargs("perf_test")) begin
                if(m_bw_read_start == 0) begin
                    t_read_bw_start_calc_time = $time;
                    m_bw_read_start = 1;
                end
                m_bw_read_counter = m_bw_read_counter + m_packet.arlen + 1;
            end
        <%}%>
        m_prot_ott_q = {};
        m_prot_ott_q = m_ott_q.find_index with(item.isRead                             === 1 &&
                                           item.m_ace_read_addr_pkt.araddr             === m_packet.araddr &&
                                           item.m_ace_read_addr_pkt.arprot[1]          !== m_packet.arprot[1]); 
      
        if(m_prot_ott_q.size>0) begin 
            m_scb_txn.ott_addr_diffsecurity_bit = 1;
        end else begin
            m_scb_txn.ott_addr_diffsecurity_bit = 0;
        end
        m_prot_ott_q.delete;
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with ((item.isRead                    === 1 )    &&
                                            item.isACEReadAddressRecd      === 1      &&
                                            (item.isMultiAccess            === 1 ?
                                             item.isMultiLineMaster        === 1 : 1) &&
                                            ((item.isACEReadDataSent       === 0      &&
                                              item.isACEReadDataSentNoRack === 0))    &&
                                           (item.isACEReadAddressRecd      === 1 ?
                                            item.m_ace_read_addr_pkt.arid  === m_packet.arid : 0)
                                         );
       
        if (m_tmp_q.size > 0) begin
            m_scb_txn.isAceCmdReqBlocked = 1; 
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Adding AxId Blocking to Read Addr:0x%0x and ID:0x%0x", m_scb_txn.m_ace_read_addr_pkt.araddr,m_scb_txn.m_ace_read_addr_pkt.arid),UVM_LOW)

        end
        // Check to make sure that axsize <= data bus width
        if (!$test$plusargs("k_decode_err_illegal_acc_format_test_unsupported_size")) begin:_check_illegal_size
        case (axi_axsize_enum_t'(m_scb_txn.m_ace_read_addr_pkt.arsize))
            AXI1B : begin
                if (WXDATA < 1 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_read_addr_pkt.arsize)), UVM_NONE);
                end
            end
            AXI2B : begin
                if (WXDATA < 2 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_read_addr_pkt.arsize)), UVM_NONE);
                end
            end
            AXI4B : begin
                if (WXDATA < 4 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_read_addr_pkt.arsize)), UVM_NONE);
                end
            end
            AXI8B : begin
                if (WXDATA < 8 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_read_addr_pkt.arsize)), UVM_NONE);
                end
            end
            AXI16B : begin
                if (WXDATA < 16 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_read_addr_pkt.arsize)), UVM_NONE);
                end
            end
            AXI32B : begin
                if (WXDATA < 32 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_read_addr_pkt.arsize)), UVM_NONE);
                end
            end
            AXI64B : begin
                if (WXDATA < 64 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_read_addr_pkt.arsize)), UVM_NONE);
                end
            end
            AXI128B : begin
                if (WXDATA < 128 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_read_addr_pkt.arsize)), UVM_NONE);
                end
            end
        endcase
        end:_check_illegal_size
        <%if(obj.COVER_ON) { %>
            if(araddr_active[m_packet.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]]) begin
                `ifndef FSYS_COVER_ON
                cov.araddr_collision = 1;
                `endif
                `ifndef FSYS_COVER_ON
                    case(core_id)
                        <%for(let i=0; i< obj.nNativeInterfacePorts; i+=1){%>
                            <%=i%> : begin
                                cov.axi_araddr_collisions_core<%=i%>.sample();
                            end
                        <%}%>
                    endcase
                `endif
                `ifndef FSYS_COVER_ON
                cov.araddr_collision = 0;
                `endif
                araddr_active[m_packet.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]]++;
            end else begin
                araddr_active[m_packet.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]] = 1;
            end
            if(awaddr_active[m_packet.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]]) begin
                `ifndef FSYS_COVER_ON
                cov.axaddr_collision = 1;
                `endif
                `ifndef FSYS_COVER_ON
                    case(core_id)
                        <%for(let i=0; i< obj.nNativeInterfacePorts; i+=1){%>
                            <%=i%> : begin
                                cov.axi_awaraddr_collisions_core<%=i%>.sample();
                            end
                        <%}%>
                    endcase
                `endif
                `ifndef FSYS_COVER_ON
                cov.axaddr_collision = 0;
                `endif
            end
            if(arid_active[m_packet.arid]) begin
                `ifndef FSYS_COVER_ON
                cov.arid_collision = 1;
                `endif
                `ifndef FSYS_COVER_ON
                    case(core_id)
                        <%for(let i=0; i< obj.nNativeInterfacePorts; i+=1){%>
                            <%=i%> : begin
                                cov.axi_arid_collisions_core<%=i%>.sample();
                            end
                        <%}%>
                    endcase
                `endif
                `ifndef FSYS_COVER_ON
                cov.arid_collision = 0;
                `endif
                arid_active[m_packet.arid]++;
            end else begin
                arid_active[m_packet.arid] = 1;
            end
            if(awid_active[m_packet.arid]) begin
                `ifndef FSYS_COVER_ON
                cov.axid_collision = 1;
                `endif
                `ifndef FSYS_COVER_ON
                    case(core_id)
                        <%for(let i=0; i< obj.nNativeInterfacePorts; i+=1){%>
                            <%=i%> : begin
                                cov.axi_aridawid_collisions_core<%=i%>.sample();
                            end
                        <%}%>
                    endcase
                `endif
                `ifndef FSYS_COVER_ON
                cov.axid_collision = 0;
                `endif
            end
        <%}%>		     

       /* foreach (m_ott_q[ii]) begin
            if(m_ott_q[ii].m_ace_write_addr_pkt != null )begin
	     	if(m_ott_q[ii].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q[ii].m_ace_write_addr_pkt.awprot[1] == m_scb_txn.m_ace_read_addr_pkt.arprot[1] && m_ott_q[ii].m_ott_status != DEALLOCATED) begin
                                   sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                    break;
                end
            end
            if(m_ott_q[ii].m_ace_read_addr_pkt != null )begin
            	if(m_ott_q[ii].m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q[ii].m_ace_read_addr_pkt.arprot[1] == m_scb_txn.m_ace_read_addr_pkt.arprot[1] && m_ott_q[ii].m_ott_status != DEALLOCATED) begin  
                    sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                    break;
                end
            end
        end
    
      foreach (m_ott_q_cmpl[ii]) begin
      if(m_ott_q_cmpl[ii].m_ace_write_addr_pkt != null )begin
	     	if(m_ott_q_cmpl[ii].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q_cmpl[ii].m_ace_write_addr_pkt.awprot[1] == m_scb_txn.m_ace_read_addr_pkt.arprot[1] && m_ott_q_cmpl[ii].m_ott_status != DEALLOCATED) begin
                                   sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                    break;
                end
            end
            if(m_ott_q_cmpl[ii].m_ace_read_addr_pkt != null )begin
            	if(m_ott_q_cmpl[ii].m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q_cmpl[ii].m_ace_read_addr_pkt.arprot[1] == m_scb_txn.m_ace_read_addr_pkt.arprot[1] && m_ott_q_cmpl[ii].m_ott_status != DEALLOCATED) begin  
                    sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                    break;
                end
            end

      end */
        m_scb_txn.tb_txnid = tb_txn_count;
        m_scb_txn.core_id = core_id;
        m_ott_q.push_back(m_scb_txn);
        ->e_queue_add;
        if (m_scb_txn.isMultiAccess) begin
          	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Multiline_RdReq_Order_0: %s",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_scb_txn.m_ace_read_addr_pkt.sprint_pkt()), UVM_LOW);
            check_address_core_id(m_scb_txn.m_ace_read_addr_pkt.araddr);
            m_ott_q[$].m_multiline_tracking_id = multiline_tracking_id;
            for (int i = 1; i < m_scb_txn.total_cacheline_count; i++) begin
                ioaiu_scb_txn m_multi_line_scb_txn;
                m_multi_line_scb_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen, csr_ccp_updatedis);
				m_multi_line_scb_txn.transOrderMode_rd = transOrderMode_rd;
				m_multi_line_scb_txn.transOrderMode_wr = transOrderMode_wr;
                                if (owo_512b == 1) void'($cast(m_multi_line_scb_txn.m_owo_native_rd_addr_pkt,  m_owo_pkt.clone()));
                m_multi_line_scb_txn.setup_ace_read_multiline_txn(m_scb_txn.m_multiline_starting_read_addr_pkt, i, m_scb_txn.total_cacheline_count, multiline_tracking_id);
                m_multi_line_scb_txn.isSleeping = m_scb_txn.isSleeping;
                <%if(obj.useCache) {%>
                     if (csr_ccp_lookupen) set_cacheline_way(m_multi_line_scb_txn);
                <% } %>
                m_multi_line_scb_txn.isAceCmdReqBlocked = m_scb_txn.isAceCmdReqBlocked;

		tb_txn_count++;
          	`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Multiline_RdReq_Order_%0d: %s", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_multi_line_scb_txn.multiline_order, m_multi_line_scb_txn.m_ace_read_addr_pkt.sprint_pkt()), UVM_LOW);
                check_address_core_id(m_multi_line_scb_txn.m_ace_read_addr_pkt.araddr);
                
                if (m_multi_line_scb_txn.m_ace_read_addr_pkt.araddr[WAXADDR-1:12] != m_scb_txn.m_ace_read_addr_pkt.araddr[WAXADDR-1:12]) begin 
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Multiline_RdReq_Order_%0d: 4K boundary violated start_addr:0x%0h split_addr:0x%0h",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_multi_line_scb_txn.multiline_order, m_scb_txn.m_ace_read_addr_pkt.araddr, m_multi_line_scb_txn.m_ace_read_addr_pkt.araddr));
                end

               /* foreach (m_ott_q[ii]) begin
                    if(m_ott_q[ii].m_ace_write_addr_pkt != null )begin
                    	if(m_ott_q[ii].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q[ii].m_ace_write_addr_pkt.awprot[1] == m_scb_txn.m_ace_read_addr_pkt.arprot[1]) begin
                        
                            sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                            break;
                        end
                    end
                    if(m_ott_q[ii].m_ace_read_addr_pkt != null )begin
                    	if(m_ott_q[ii].m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q[ii].m_ace_read_addr_pkt.arprot[1] == m_scb_txn.m_ace_read_addr_pkt.arprot[1]) begin
                        
                            sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                            break;
                        end
                    end
                end

              foreach (m_ott_q_cmpl[ii]) begin
                  if(m_ott_q_cmpl[ii].m_ace_write_addr_pkt != null )begin
                    	if(m_ott_q_cmpl[ii].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q_cmpl[ii].m_ace_write_addr_pkt.awprot[1] == m_scb_txn.m_ace_read_addr_pkt.arprot[1]) begin
                        
                            sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                            break;
                        end
                    end
                    if(m_ott_q_cmpl[ii].m_ace_read_addr_pkt != null )begin
                    	if(m_ott_q_cmpl[ii].m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q_cmpl[ii].m_ace_read_addr_pkt.arprot[1] == m_scb_txn.m_ace_read_addr_pkt.arprot[1]) begin
                        
                            sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                            break;
                        end
                    end
                end
*/

				m_multi_line_scb_txn.natv_intf_cc = cycle_counter;
				m_multi_line_scb_txn.tb_txnid = tb_txn_count;
				m_multi_line_scb_txn.core_id = core_id;
                m_ott_q.push_back(m_multi_line_scb_txn);
            end
            
            multiline_tracking_id++;
            // Sanity check to make sure all multiline packets are setup correctly
            m_tmp_q = {};
            m_tmp_q = m_ott_q.find_index with (item.m_multiline_tracking_id === (multiline_tracking_id - 1));
            if (m_tmp_q.size !== m_scb_txn.total_cacheline_count) begin
                m_scb_txn.print_me(0,1);
                print_queues();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf ("TB Error: Could not correctly count number of OutstTxn packets for this multiline read for address 0x%0x id 0x%0x (Expected:%0d Actual:%0d)", m_scb_txn.m_ace_read_addr_pkt.araddr, multiline_tracking_id-1, m_scb_txn.total_cacheline_count, m_tmp_q.size()), UVM_NONE);
            end
        end
        
//	`uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("[ACE-TRACE] [cmd: %15s (----)] [wid: 0x%04h] [len: %6d] [addr: 0x%16h]", "READ", m_pkt.arid, m_pkt.arlen, m_pkt.araddr));
     endfunction : write_ncbu_read_addr_chnl

    //----------------------------------------------------------------------- 
    // ACE Write Address Channel
    //----------------------------------------------------------------------- 
    
    function void write_ncbu_write_addr_chnl(axi4_write_addr_pkt_t m_pkt);
        int                  m_tmp_q[$];
        int                  m_tmp_q1[$];
        int                  m_tmp_qA[$];
        ace_write_addr_pkt_t m_packet;
        ace_write_addr_pkt_t m_packet_tmp;
        ace_write_addr_pkt_t m_owo_pkt ;
        ioaiu_scb_txn          m_scb_txn;
        ioaiu_scb_txn          m_search_id_q[$];
        bit                   done;
        int  fnmem_region_idx,dest_id;
        read_pkt_info_t       wr_info;
        
        ace_write_data_pkt_t  m_ace_write_data_pkt;
        ace_write_data_pkt_t  pop_agent_data_pkt;

        m_packet_tmp = new();
        m_packet = new();
        $cast(m_packet_tmp, m_pkt);
        m_packet.copy(m_packet_tmp);

        if ((owo == 1) && !(m_packet.awsnoop inside {'h0, 'h1})) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIUp does not expect below <%=obj.fnNativeInterface%>_WrReq:%0s", m_packet.sprint_pkt()));
        end

        m_scb_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen,csr_ccp_updatedis,m_packet.awaddr, core_id);
       	tb_txn_count++;
        //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("%0s Received below <%=obj.fnNativeInterface%>_WrReq:%0s", get_tb_txnid_str(), m_packet.sprint_pkt()) ,UVM_LOW);

        if ($test$plusargs("eviction_seq") || $test$plusargs("ioc_stream_of_alloc_ops_some_sets_seq") || $test$plusargs("ioc_stream_of_alloc_ops_some_sets_seq_new")) begin
         <%if(obj.useCache){%>
           if(!(addrMgrConst::get_set_index(m_packet.awaddr,<%=obj.FUnitId%>) inside {ccp_index_q}))begin 
             ccp_index_q.push_back(addrMgrConst::get_set_index(m_packet.awaddr,<%=obj.FUnitId%>));
             if(ccp_index_q.size() > k_num_sets)            
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("TB Error: Index should be equal to k_num_sets %0d act:%0d",ccp_index_q[0],addrMgrConst::get_set_index(m_packet.awaddr,<%=obj.FUnitId%>)));
           end
        <%}%> 
        		 
        end

         if($test$plusargs("perf_test")) begin
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below <%=obj.fnNativeInterface%>_WrReq:%0s",  tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt()) ,UVM_NONE);
        end else begin
            if (owo && (<%=obj.AiuInfo[obj.Id].wData%> == 512)) begin
    	        void'($cast(m_owo_pkt, m_packet.clone()));
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received <%=obj.fnNativeInterface%>_WrReq:%0s", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt()) ,UVM_LOW);
                //dont update the native pkt for <=32B transfer
                if (m_owo_pkt.awsize == 6) begin 
                    m_packet.awsize = 5;
                    m_packet.awlen = (m_owo_pkt.awaddr[5] == 1) ? ((m_owo_pkt.awlen+1)*2) - 2 : ((m_owo_pkt.awlen + 1)*2) - 1; end  
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Post data-width adapter(axi_shim) <%=obj.fnNativeInterface%>_WrReq:%0s", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt()) ,UVM_LOW);
            end  else begin 
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received <%=obj.fnNativeInterface%>_WrReq:%0s",  tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt()) ,UVM_LOW);
            end
        end

        if (!($test$plusargs("csr_access_via_nativeintf")))
		check_address_core_id(m_packet.awaddr);
         timeout_err_cmd_type = 'b01;
        //detect case in CONC-6714
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with (item.isRead                  === 1 &&
                                           item.isSMICMDReqNeeded &&
                                           !item.isSMICMDReqSent &&
                                           item.m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] === m_packet.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] &&
                                           <% if (obj.wSecurityAttribute > 0) { %>
                                           item.m_ace_read_addr_pkt.arprot[1] === m_packet.awprot[1]
                                           <% } %>
                                       );
        if((m_tmp_q.size != 0) && (m_packet.awsnoop inside {'b0010, 'b0011, 'b0100, 'b0101})) begin
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("hit the case CONC-6714.m_pakecet:%s", m_packet.sprint_pkt()),UVM_NONE);
            m_ott_q[m_tmp_q[0]].print_me();
        end
        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
		//CONC-9697 In ACE, we should not hit any outstanding CMOs to the same address. If we did, fix BFM.
		m_tmp_q = {};
                m_tmp_q = m_ott_q.find_index with ((item.isRead == 1) &&
        								   (item.m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] === m_packet.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]) &&
        								  <% if (obj.wSecurityAttribute > 0) { %>
                                           (item.m_ace_read_addr_pkt.arprot[1] === m_packet.awprot[1]) &&
                                           <% } %>
   										   (item.m_ace_cmd_type inside {CLNSHRD, CLNINVL, MKINVL, CLNSHRDPERSIST}) && 
										   (item.isACEReadDataSent == 0));

        if ((m_tmp_q.size() > 0) && (m_packet.print_snoop_type != "WRNOSNP") && !hasErr)
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Above write request seen on nativeInterface when there is an outstanding CMO to the same address at OutstTxn #%0d", m_tmp_q[0]), UVM_NONE);
		
        <%}%>

		m_scb_txn.transOrderMode_rd = transOrderMode_rd;
		m_scb_txn.transOrderMode_wr = transOrderMode_wr;
                if (owo && (<%=obj.AiuInfo[obj.Id].wData%> == 512)) begin
                    void'($cast(m_scb_txn.m_owo_native_wr_addr_pkt, m_owo_pkt.clone()));
                end
                m_scb_txn.setup_ace_write_req(m_packet, cycle_counter);

                //Rd Response interleaved for atomic txn
                <%if (obj.fnNativeInterface == "ACELITE-E") {%>
                 m_tmp_qA = {};
                 m_tmp_qA = m_ott_q.find_index with (item.isAtomic      === 1                           && 
                                              item.m_ace_cmd_type inside {ATMLD,ATMCOMPARE, ATMSWAP}    &&
                                              item.m_ace_write_addr_pkt.awid === m_packet.awid          &&
                                              item.m_ace_write_addr_pkt.awaddr === m_packet.awaddr);

                 if (m_tmp_qA.size() > 0)begin
                 wr_info.max_beats_in_cacheline = SYS_nSysCacheline/(<%=obj.wData%>/8);
                 wr_info.current_beat = (m_packet.awaddr % SYS_nSysCacheline)/(<%=obj.wData%>/8);
                 wr_info.arid = m_packet.awid;
                 wr_info.read_complete = 0;
                read_packets.push_back(wr_info);
                end 
               <%}%>
 
	    dest_id = addrMgrConst::map_addr2dmi_or_dii(m_packet.awaddr,fnmem_region_idx);
        if(m_scb_txn.mem_regions_overlap || ($test$plusargs("unmapped_add_access") && ((dest_id == -1 && fnmem_region_idx == -1) ))) begin //There is no way to get configure address region map in GPR register so using plusharg
          if(addr_trans_mgr::check_unmapped_add(m_packet.awaddr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) begin
          csr_addr_decode_err_addr_q.push_back(m_packet.awaddr);
          csr_addr_decode_err_msg_id_q.push_back(m_packet.awid);
           csr_addr_decode_err_type_q.push_back(dec_err_type);
          csr_addr_decode_err_cmd_type_q.push_back(1'b1);
         end
         else begin
          csr_addr_decode_err_addr_q.push_back(m_packet.awaddr);
          csr_addr_decode_err_msg_id_q.push_back(m_packet.awid);
          csr_addr_decode_err_cmd_type_q.push_back(1'b1);
         end
        end
        if(m_scb_txn.illegalNSAccess || m_scb_txn.illDIIAccess || m_scb_txn.illegalCSRAccess) begin
          csr_addr_decode_err_addr_q.push_back(m_packet.awaddr);
          csr_addr_decode_err_msg_id_q.push_back(m_packet.awid);
          csr_addr_decode_err_cmd_type_q.push_back(1'b1);

        end
        if($test$plusargs("no_credit_check")) begin
            csr_addr_decode_err_addr_q.push_back(m_packet.awaddr);
            csr_addr_decode_err_msg_id_q.push_back(m_packet.awid);
            csr_addr_decode_err_type_q.push_back(3'b111); //NO credit access
            csr_addr_decode_err_cmd_type_q.push_back(1'b1);
        end
        if ($test$plusargs("unmapped_add_access")) begin
        case (core_id) 
<%for(let i=0; i<obj.nNativeInterfacePorts; i++) {%>
          <%=i%> :  ev_aw_req_<%=i%>.trigger();
<%}%>
        endcase
        end
        <%if(obj.useCache) {%>
            if (csr_ccp_lookupen && csr_ccp_allocen) set_cacheline_way(m_scb_txn);
        <%}%>		     
	    set_sleeping(m_scb_txn);
       
        <%if(obj.COVER_ON) { %>
            `ifndef FSYS_COVER_ON
                cov.collect_axi_awaddr(m_scb_txn, core_id);
                cov.collect_data_integrity_awaddr(m_scb_txn, core_id);
            `endif	     
        <% } %>
        <%if ((obj.fnNativeInterface != "AXI4") && (obj.fnNativeInterface != "AXI5"))  {%> 
            if($test$plusargs("performance_test") || $test$plusargs("perf_test")) begin
                if(m_bw_write_start == 0) begin
                    t_write_bw_start_calc_time = $time;
                    m_bw_write_start = 1;
                end
            m_bw_write_counter = m_bw_write_counter + m_packet.awlen + 1;
            end
        <%}%>				

        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with ((item.isWrite                  === 1 ||
                                            item.isUpdate                 === 1 ) &&
                                           item.isACEWriteAddressRecd     === 1 &&
                                            (item.isMultiAccess           === 1 ?
                                             item.isMultiLineMaster       === 1 :
                                             1)                                &&    
                                           item.isACEWriteRespSent        === 0 &&
                                           item.isACEWriteRespSentNoWack  === 0 &&
                                           item.m_ace_write_addr_pkt.awid === m_packet.awid
                                       );
        
        if (m_tmp_q.size > 0) begin
            m_scb_txn.isAceCmdReqBlocked = 1; 
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Adding AxId Blocking to Write Addr:0x%0x and ID:0x%0x", m_scb_txn.m_ace_write_addr_pkt.awaddr,m_scb_txn.m_ace_write_addr_pkt.awid),UVM_LOW)
        end
        
        // Check to make sure that axsize <= data bus width
          if (!$test$plusargs("k_decode_err_illegal_acc_format_test_unsupported_size")) begin:_check_illegal_size
          case (axi_axsize_enum_t'(m_scb_txn.m_ace_write_addr_pkt.awsize))
            AXI1B : begin
                if (WXDATA < 1 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_write_addr_pkt.awsize)), UVM_NONE);
                end
            end
            AXI2B : begin
                if (WXDATA < 2 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_write_addr_pkt.awsize)), UVM_NONE);
                end
            end
            AXI4B : begin
                if (WXDATA < 4 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_write_addr_pkt.awsize)), UVM_NONE);
                end
            end
            AXI8B : begin
                if (WXDATA < 8 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_write_addr_pkt.awsize)), UVM_NONE);
                end
            end
            AXI16B : begin
                if (WXDATA < 16 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_write_addr_pkt.awsize)), UVM_NONE);
                end
            end
            AXI32B : begin
                if (WXDATA < 32 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_write_addr_pkt.awsize)), UVM_NONE);
                end
            end
            AXI64B : begin
                if (WXDATA < 64 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_write_addr_pkt.awsize)), UVM_NONE);
                end
            end
            AXI128B : begin
                if (WXDATA < 128 * 8) begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE data bus width (0x%0x) is less than axsize (%0p)", WXDATA, axi_axsize_enum_t'(m_scb_txn.m_ace_write_addr_pkt.awsize)), UVM_NONE);
                end
            end
        endcase
        end:_check_illegal_size
      
        <%if(obj.COVER_ON) { %>
            if(awaddr_active[m_packet.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]]) begin
                `ifndef FSYS_COVER_ON
                    cov.awaddr_collision = 1;
                `endif
                `ifndef FSYS_COVER_ON
                    case(core_id)
                        <%for(let i=0; i< obj.nNativeInterfacePorts; i+=1){%>
                            <%=i%> : begin
                                cov.axi_awaddr_collisions_core<%=i%>.sample();
                            end
                        <%}%>
                    endcase
                `endif
                `ifndef FSYS_COVER_ON
                    cov.awaddr_collision = 0;
                `endif
                awaddr_active[m_packet.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]]++;
            end
            else begin
                awaddr_active[m_packet.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]] = 1;
            end
            if(araddr_active[m_packet.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]]) begin
                `ifndef FSYS_COVER_ON
                cov.axaddr_collision = 1;
                `endif
                `ifndef FSYS_COVER_ON
                    case(core_id)
                        <%for(let i=0; i< obj.nNativeInterfacePorts; i+=1){%>
                            <%=i%> : begin
                                cov.axi_awaraddr_collisions_core<%=i%>.sample();
                            end
                        <%}%>
                    endcase
                `endif
                `ifndef FSYS_COVER_ON
                cov.axaddr_collision = 0;
                `endif
            end
            if(awid_active[m_packet.awid]) begin
                `ifndef FSYS_COVER_ON
                cov.awid_collision = 1;
                `endif
                `ifndef FSYS_COVER_ON
                    case(core_id)
                        <%for(let i=0; i< obj.nNativeInterfacePorts; i+=1){%>
                            <%=i%> : begin
                                cov.axi_awid_collisions_core<%=i%>.sample();
                            end
                        <%}%>
                    endcase
                `endif
                `ifndef FSYS_COVER_ON
                cov.awid_collision = 0;
                `endif
                awid_active[m_packet.awid]++;
            end
            else begin
                awid_active[m_packet.awid] = 1;
            end
            if(arid_active[m_packet.awid]) begin
                `ifndef FSYS_COVER_ON
                cov.axid_collision = 1;
                `endif
                `ifndef FSYS_COVER_ON
                    case(core_id)
                        <%for(let i=0; i< obj.nNativeInterfacePorts; i+=1){%>
                            <%=i%> : begin
                                cov.axi_arid_collisions_core<%=i%>.sample();
                            end
                        <%}%>
                    endcase
                `endif
                `ifndef FSYS_COVER_ON
                cov.axid_collision = 0;
                `endif
            end
        <%}%>		     
     /*   foreach (m_ott_q[ii]) begin
            if(m_ott_q[ii].m_ace_write_addr_pkt != null )begin
	    	if(m_ott_q[ii].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q[ii].m_ace_write_addr_pkt.awprot[1] == m_scb_txn.m_ace_write_addr_pkt.awprot[1] && m_ott_q[ii].m_ott_status != DEALLOCATED) begin
                    sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                    break;
                end
            end
            if(m_ott_q[ii].m_ace_read_addr_pkt != null )begin
	    	if(m_ott_q[ii].m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q[ii].m_ace_read_addr_pkt.arprot[1] == m_scb_txn.m_ace_write_addr_pkt.awprot[1] && m_ott_q[ii].m_ott_status != DEALLOCATED ) begin
                    sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                    break;
                end
            end
        end
   foreach (m_ott_q_cmpl[ii]) begin
       if(m_ott_q_cmpl[ii].m_ace_write_addr_pkt != null )begin
	    	if(m_ott_q_cmpl[ii].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q_cmpl[ii].m_ace_write_addr_pkt.awprot[1] == m_scb_txn.m_ace_write_addr_pkt.awprot[1] && m_ott_q_cmpl[ii].m_ott_status != DEALLOCATED) begin
                    sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                    break;
                end
            end
            if(m_ott_q_cmpl[ii].m_ace_read_addr_pkt != null )begin
	    	if(m_ott_q_cmpl[ii].m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q_cmpl[ii].m_ace_read_addr_pkt.arprot[1] == m_scb_txn.m_ace_write_addr_pkt.awprot[1] && m_ott_q_cmpl[ii].m_ott_status != DEALLOCATED ) begin
                    sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                    break;
                end
            end
        end
*/

        m_scb_txn.tb_txnid = tb_txn_count;
        m_scb_txn.core_id = core_id;
        m_ott_q.push_back(m_scb_txn);
        if(m_scb_txn.isAtomic) m_pkt_isAtomic.push_back(m_scb_txn);
        if (m_scb_txn.isMultiAccess) begin
                //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> total_split_count:%d",  tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_scb_txn.total_cacheline_count), UVM_LOW);
          	`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Multiline_WrReq_Order_0: %s", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_scb_txn.m_ace_write_addr_pkt.sprint_pkt()), UVM_LOW);
            check_address_core_id(m_scb_txn.m_ace_write_addr_pkt.awaddr);
            m_ott_q[$].m_multiline_tracking_id = multiline_tracking_id;
            for (int i = 1; i < m_scb_txn.total_cacheline_count; i++) begin
                ioaiu_scb_txn m_multi_line_scb_txn;
                m_multi_line_scb_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen, csr_ccp_updatedis);
				m_multi_line_scb_txn.transOrderMode_rd = transOrderMode_rd;
				m_multi_line_scb_txn.transOrderMode_wr = transOrderMode_wr;
                                if (owo_512b == 1) void'($cast(m_multi_line_scb_txn.m_owo_native_wr_addr_pkt,  m_owo_pkt.clone()));
                m_multi_line_scb_txn.setup_ace_write_multiline_txn(m_scb_txn.m_multiline_starting_write_addr_pkt, i, m_scb_txn.total_cacheline_count, multiline_tracking_id);
	            m_multi_line_scb_txn.isSleeping = m_scb_txn.isSleeping;
	       
                <%if(obj.useCache) {%>
                     if (csr_ccp_lookupen && csr_ccp_allocen) set_cacheline_way(m_multi_line_scb_txn);
                <%}%>		     
                m_multi_line_scb_txn.isAceCmdReqBlocked = m_scb_txn.isAceCmdReqBlocked;

     /*           foreach (m_ott_q[ii]) begin
                    if(m_ott_q[ii].m_ace_write_addr_pkt != null )begin
                    	if(m_ott_q[ii].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q[ii].m_ace_write_addr_pkt.awprot[1] == m_scb_txn.m_ace_write_addr_pkt.awprot[1] ) begin
                            sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                            break;
                        end
                    end
                    if(m_ott_q[ii].m_ace_read_addr_pkt != null )begin
			if(m_ott_q[ii].m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q[ii].m_ace_read_addr_pkt.arprot[1] == m_scb_txn.m_ace_write_addr_pkt.awprot[1] ) begin                        
                            sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                            break;
                        end
                    end
                end
                foreach (m_ott_q_cmpl[ii]) begin
                    if(m_ott_q_cmpl[ii].m_ace_write_addr_pkt != null )begin
                    	if(m_ott_q_cmpl[ii].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q_cmpl[ii].m_ace_write_addr_pkt.awprot[1] == m_scb_txn.m_ace_write_addr_pkt.awprot[1] ) begin
                            sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                            break;
                        end
                    end
                    if(m_ott_q_cmpl[ii].m_ace_read_addr_pkt != null )begin
			if(m_ott_q_cmpl[ii].m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_scb_txn.m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && m_ott_q_cmpl[ii].m_ace_read_addr_pkt.arprot[1] == m_scb_txn.m_ace_write_addr_pkt.awprot[1] ) begin                        
                            sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
                            break;
                        end
                    end
                end */


				tb_txn_count++;
          		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Multiline_WrReq_Order_%0d: %s", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_multi_line_scb_txn.multiline_order, m_multi_line_scb_txn.m_ace_write_addr_pkt.sprint_pkt()), UVM_LOW);
                        check_address_core_id(m_multi_line_scb_txn.m_ace_write_addr_pkt.awaddr);
 
                if (m_multi_line_scb_txn.m_ace_write_addr_pkt.awaddr[WAXADDR-1:12] != m_scb_txn.m_ace_write_addr_pkt.awaddr[WAXADDR-1:12]) begin 
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Multiline_WrReq_Order_%0d: 4K boundary violated start_addr:0x%0h split_addr:0x%0h",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_multi_line_scb_txn.multiline_order, m_scb_txn.m_ace_read_addr_pkt.araddr, m_multi_line_scb_txn.m_ace_read_addr_pkt.araddr));
                end

				m_multi_line_scb_txn.natv_intf_cc = cycle_counter;
				m_multi_line_scb_txn.tb_txnid = tb_txn_count;
				m_multi_line_scb_txn.core_id = core_id;
                m_ott_q.push_back(m_multi_line_scb_txn);
            end
            multiline_tracking_id++;
            // Sanity check to make sure all multiline packets are setup correctly
            m_tmp_q = {};
            m_tmp_q = m_ott_q.find_index with (item.m_multiline_tracking_id === (multiline_tracking_id - 1));
            if (m_tmp_q.size !== m_scb_txn.total_cacheline_count) begin
                m_scb_txn.print_me();
                print_queues();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf ("TB Error: Could not correctly count number of OutstTxn packets for this multiline write for address 0x%0x id 0x%0x (Expected:%0d Actual:%0d)", m_scb_txn.m_ace_write_addr_pkt.awaddr, multiline_tracking_id-1, m_scb_txn.total_cacheline_count, m_tmp_q.size()), UVM_NONE);
            end
        end

       // do begin
       //     m_tmp_q = {};
       //     m_tmp_q = m_ott_q.find_index with ((item.isWrite              === 1  ||
       //                                         item.isUpdate             === 1) &&
       //                                        item.isACEWriteAddressRecd === 1  &&
       //                                        item.isACEWriteDataNeeded  === 1  &&
       //                                        item.isACEWriteDataRecd    === 0
       //                                    );

       //     if ((m_tmp_q.size !== 0) && (m_oawd_q.size()>0)) begin
       //         m_tmp_q[0] = find_oldest_entry_in_ott_q(m_tmp_q);
       //         if(m_oawd_q.size() >= (m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen+1)) begin 
       //             m_ace_write_data_pkt       = new();
       //             m_ace_write_data_pkt.wdata = new[(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen+1)];
       //             m_ace_write_data_pkt.wstrb = new[(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen+1)];
       //             for(int i=0; i<(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen+1);i++) begin 
       //                 pop_agent_data_pkt            = m_oawd_q.pop_front();
       //                 m_ace_write_data_pkt.wdata[i] = pop_agent_data_pkt.wdata[0];
       //                 m_ace_write_data_pkt.wstrb[i] = pop_agent_data_pkt.wstrb[0];
       //             end

       //             m_ott_q[m_tmp_q[0]].setup_ace_write_data(m_ace_write_data_pkt);
       //         end else begin
       //             done = 1'b1;
       //         end
       //     end else begin 
       //         done = 1'b1;
       //     end
       // end while(!done);

        do begin
            int i;
            int match_idxq[$];
            ace_write_data_pkt_t pop_data_pkt, push_data_pkt;
            m_tmp_q = {};
            m_tmp_q = m_ott_q.find_index with ((item.isWrite              === 1  ||
                                                item.isUpdate             === 1) &&
                                               item.isACEWriteAddressRecd === 1  &&
                                               item.isACEWriteDataNeeded  === 1  &&
                                               item.isACEWriteDataRecd    === 0
                                           );
            
            if (m_tmp_q.size() > 0) begin: _wr_req_
                if (owo_512b) begin: _512b_owo_  
                    if (m_owo_native_oawd_tmp_q.size() > 0) begin : _native_beats_recd_chk_ 
                        match_idxq = m_owo_native_oawd_tmp_q.find_first_index with  (item.wlast == 1);
                        if (match_idxq.size() == 1) begin 
                            foreach (m_owo_native_oawd_tmp_q[i])
                                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("idx:%0d NativeWrData_Before_del:%0s",i, m_owo_native_oawd_tmp_q[i].sprint_pkt()) ,UVM_LOW);
                            if (!m_ott_q[m_tmp_q[0]].isMultiAccess || m_ott_q[m_tmp_q[0]].isMultiLineMaster) begin //ok to check once for every native txn
                               if ((m_ott_q[m_tmp_q[0]].m_owo_native_wr_addr_pkt.awlen + 1) != (match_idxq[0]+1)) begin
                                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("IOAIU_UID:%0d Mismatch in native_awlen:%0d and  native_wr_data_beats:%0d received", m_ott_q[m_tmp_q[0]].tb_txnid, m_ott_q[m_tmp_q[0]].m_owo_native_wr_addr_pkt.awlen, match_idxq[0]+1));
                               end 
                            
                               i = 0;
                               while (i <= match_idxq[0]) begin 
                                  void'(m_owo_native_oawd_tmp_q.pop_front());
                                  i++;
                               end 
                            end
                            
                            foreach (m_owo_native_oawd_tmp_q[i])
                                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("idx:%0d NativeWrData_After_del:%0s",i, m_owo_native_oawd_tmp_q[i].sprint_pkt()) ,UVM_LOW);
                        end
                    end:_native_beats_recd_chk_
              
                    //converting 512b data packets into 256b data packets 
                    if (m_owo_native_oawd_q.size() > 0) begin 
                        pop_data_pkt = m_owo_native_oawd_q.pop_front();
                        if (m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen == 0) begin 
                            push_data_pkt = new();
                            push_data_pkt.wstrb = new[1];
                            push_data_pkt.wdata = new[1];
                            if (m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awaddr[WLOGXDATA-1:0] < 32) begin 
                                push_data_pkt.wstrb[0] = pop_data_pkt.wstrb[0][(WXDATA/(8*2))-1:0];
                                push_data_pkt.wdata[0] = pop_data_pkt.wdata[0][(WXDATA/2)-1:0]; 
                            end else begin
                                push_data_pkt.wstrb[0] = pop_data_pkt.wstrb[0][(WXDATA/8)-1:(WXDATA/(8*2))];
                                push_data_pkt.wdata[0] = pop_data_pkt.wdata[0][(WXDATA-1):WXDATA/2]; 
                            end
                            `uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG", $psprintf("UID:%0d len:%0d WrData:%0s",  m_ott_q[m_tmp_q[0]].tb_txnid, m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen, push_data_pkt.sprint_pkt()) ,UVM_LOW);
                            m_oawd_q.push_back(push_data_pkt);
                        end else begin 
                            push_data_pkt = new();
                            push_data_pkt.wstrb = new[1];
                            push_data_pkt.wdata = new[1];
                            push_data_pkt.wstrb[0] = pop_data_pkt.wstrb[0][(WXDATA/(8*2))-1:0];
                            push_data_pkt.wdata[0] = pop_data_pkt.wdata[0][(WXDATA/2)-1:0]; 
                            `uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG", $psprintf("UID:%0d len:%0d lower_half WrData:%0s",  m_ott_q[m_tmp_q[0]].tb_txnid, m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen, push_data_pkt.sprint_pkt()) ,UVM_LOW);
                            m_oawd_q.push_back(push_data_pkt);
                            push_data_pkt = new();
                            push_data_pkt.wstrb = new[1];
                            push_data_pkt.wdata = new[1];
                            push_data_pkt.wstrb[0] = pop_data_pkt.wstrb[0][(WXDATA/8)-1:(WXDATA/(8*2))];
                            push_data_pkt.wdata[0] = pop_data_pkt.wdata[0][(WXDATA-1):WXDATA/2]; 
                            `uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG", $psprintf("UID:%0d len:%0d upper_half WrData:%0s",  m_ott_q[m_tmp_q[0]].tb_txnid, m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen, push_data_pkt.sprint_pkt()) ,UVM_LOW);
                            m_oawd_q.push_back(push_data_pkt);
                        end
                    end
                end : _512b_owo_ 

                if(m_oawd_q.size() >= (m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen+1)) begin 
                    m_ace_write_data_pkt       = new();
                    m_ace_write_data_pkt.wdata = new[(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen+1)];
                    m_ace_write_data_pkt.wstrb = new[(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen+1)];
                    for(int i=0; i<(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen+1);i++) begin 
                        pop_agent_data_pkt            = m_oawd_q.pop_front();
                        m_ace_write_data_pkt.wdata[i] = pop_agent_data_pkt.wdata[0];
                        m_ace_write_data_pkt.wstrb[i] = pop_agent_data_pkt.wstrb[0];
                    end
										//CONC-17918
										//for unaligned start addr, vip might randomly drive all byte strbs 0 , so the check can be ignored for 1st data beat
										if($test$plusargs("ptl_wstrb") && m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awcmdtype inside {WRNOSNP,WRUNQ,WRBK,WRCLN})begin
											foreach (m_ace_write_data_pkt.wstrb[i]) begin
												if (i && m_ace_write_data_pkt.wstrb[i] inside {0,((1 << (1 << (m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awsize))) - 1)}) begin
													`uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $sformatf("IOAIU_UID:%0d WrData expected to have partial strbs", m_ott_q[m_tmp_q[0]].tb_txnid));
												end
											end									
										end
                    m_ott_q[m_tmp_q[0]].setup_ace_write_data(m_ace_write_data_pkt);
                end else begin
                    done = 1'b1;
                end
            end: _wr_req_ 
            else begin 
                done = 1'b1;
            end
        end while(!done);
        //CONC-12072 Following code marks all mutliline orders of the same multiline_id as DECERR if any one of them has DECERR.
        //This is particularly for connectivity scenarios, where for interleaved DMI, one of them is connected & other is not
        //So different multline_order txns either go to connected dmi_acess or unconnected dmi_access
        //When this happens, the BRESP of all mutliline_orders should be marked DECERR
        if (m_scb_txn.isMultiAccess) begin
            int m_tmp_qE[$];
            bit set_dec_err = 0;
            int multiline_tracking_id_tmp = m_scb_txn.m_multiline_tracking_id;
            int total_cacheline_count_tmp = m_scb_txn.total_cacheline_count;
            m_tmp_qE = {};
            m_tmp_qE = m_ott_q.find_index with (item.isMultiAccess           === 1 &&
            item.m_multiline_tracking_id === multiline_tracking_id_tmp);
            //total_cacheline_count_tmp & m_tmp_qE.size should be same
            for (int i = 0; i < m_tmp_qE.size(); i++) begin
                int index;
                index = m_tmp_qE[i];
                if (m_ott_q[m_tmp_qE[i]].m_axi_resp_expected[0] === DECERR) begin
                    //mark this multiline_tracking_id as ERR
                    set_dec_err = 1;
                end
            end
            if (set_dec_err) begin
                for (int i = 0; i < m_tmp_qE.size(); i++) begin
                    m_ott_q[m_tmp_qE[i]].m_axi_resp_expected[0] = DECERR;
                    m_ott_q[m_tmp_qE[i]].tagged_decerr = 1;
                end
            end
        end
    endfunction : write_ncbu_write_addr_chnl

    //----------------------------------------------------------------------- 
    // ACE Read Data Channel
    //-----------------------------------------------------------------------  
    
    function void write_ncbu_read_data_chnl(axi4_read_data_pkt_t m_pkt);
        ace_read_data_pkt_t   m_packet;
        ace_read_data_pkt_t   m_packet_tmp;
        int                   m_tmp_q[$];
       axi_rresp_t tmp_rresp; 
        if(hasErr)
	  		return;

    	void'($cast(m_packet, m_pkt.clone()));
       	
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with (
					    item.match_ReadDataRespToAtomicTxn(m_packet) || 
        				    item.match_ReadDataRespToDvmMsg(m_packet) ||
        				    item.match_ReadDataRespToDvmCmpl(m_packet) ||
        				    item.match_ReadDataRespToRead(m_packet) ||
        				    item.match_ReadDataRespToErrorScenarios(m_packet)
                                          );

        if(m_ott_q[m_tmp_q[0]].illegalNSAccess || (m_ott_q[m_tmp_q[0]].illDIIAccess==1) || m_ott_q[m_tmp_q[0]].illegalCSRAccess) begin
        csr_addr_decode_err_msg_rsp_id_q.push_back(m_packet.rid);
        case (core_id) 
<%for(let i=0; i<obj.nNativeInterfacePorts; i++) {%>
          <%=i%> :  ev_ar_req_<%=i%>.trigger();
<%}%>
        endcase
        end

        if (m_tmp_q.size == 0) begin
        	`uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("Received below <%=obj.fnNativeInterface%>_RdData/RResp:%0s", m_packet.sprint_pkt()) ,UVM_LOW);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Cannot find a corresponding transaction for the above <%=obj.fnNativeInterface%> read data packet"), UVM_NONE);
        end
        else if (m_tmp_q.size > 1) begin
                foreach (m_tmp_q[i])
        	    `uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG", $psprintf("Received below <%=obj.fnNativeInterface%>_RdData/RResp multiple match IOAIU_UID:%0d isDVM:%0b arid:0x%0h isACEReadDataSentNoRack:%0d", m_ott_q[m_tmp_q[i]].tb_txnid, m_ott_q[m_tmp_q[i]].isDVM, m_ott_q[m_tmp_q[i]].m_ace_read_addr_pkt.arid, m_ott_q[m_tmp_q[i]].isACEReadDataSentNoRack),UVM_LOW);
        	m_tmp_q[0] = find_oldest_read_in_ott_q(m_tmp_q);
        end
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below <%=obj.fnNativeInterface%>_RdData/RResp:%0s",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt()) ,UVM_LOW);
	
        check_response_ordering(m_tmp_q[0]);
       
	if (m_ott_q[m_tmp_q[0]].isMultiAccess) begin: _multiline_
            if (owo_512b) begin 
                if (m_packet.rdata.size() !== m_ott_q[m_tmp_q[0]].m_owo_native_rd_addr_pkt.arlen + 1) begin 
               `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("UID:%0d For a multi-line read packet, rdata size does not match arlen size (Expected:%0d Actual:%0d)", m_ott_q[m_tmp_q[0]].tb_txnid, m_ott_q[m_tmp_q[0]].m_owo_native_rd_addr_pkt.arlen+1, m_packet.rdata.size()));
                end
            end
            else if (m_packet.rdata.size() !== m_ott_q[m_tmp_q[0]].m_multiline_starting_read_addr_pkt.arlen + 1) begin
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("UID:%0d For a multi-line read packet, rdata size does not match arlen size (Expected:%0d Actual:%0d)", m_ott_q[m_tmp_q[0]].tb_txnid, m_ott_q[m_tmp_q[0]].m_multiline_starting_read_addr_pkt.arlen+1, m_packet.rdata.size()));
            end 
       	    split_read_data_packet_multiline_txn(m_tmp_q[0], m_packet);
	
        end: _multiline_ 
        else begin 

              /*  <%if(obj.assertOn){%>
                <%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") && ((obj.testBench != "fsys") && (obj.testBench != "emu") && (obj.testBench != "emu_t"))) {%>
                  err_ind = err_id_addr_q.find_index(x) with (x[127:64] == m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arid && x[63:0] == m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.araddr);
                  if(err_ind.size() == 1)
                  m_ott_q[m_tmp_q[0]].predict_ott_data_error =1;                 
                 <%}%>
		<%}%> */

                foreach (error_data_q[j]) begin 
                foreach (m_packet.rdata[i]) begin
                error_data_bit = error_data_q[j] ^ m_packet.rdata[i]; //xor with orignal data for peridciting bit changes.
                if($countbits(error_data_bit, '1) <= 2) begin         //counting flip bit for single bit or double bit error injection 
                m_ott_q[m_tmp_q[0]].error_data_q.push_back({m_packet.rdata[i]});
               	m_ott_q[m_tmp_q[0]].predict_ott_data_error =1;
                error_data_q.delete(j);
                end
	       	end
	        end
                

        	m_ott_q[m_tmp_q[0]].setup_ace_read_data(m_packet);
        end
            
        //#Check.IOAIU.ACE.R.RTRACE
        //#Check.IOAIU.RTRACE
        <%if(aiu_axiInt.params.eTrace > 0) { %>
            uvm_config_db#(int)::get(null, "*", "ioaiu_cctrlr_phase", ioaiu_cctrlr_phase);

            if(m_ott_q[m_tmp_q[0]].isACEReadAddressRecd && ( (m_ott_q[m_tmp_q[0]].isACEReadAddressDVMRecd && m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt2 != null) ? m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt2.artrace:m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.artrace) && (m_ott_q[m_tmp_q[0]].tctrlr[0].native_trace_en || native_trace_CONC_7813)) begin
                if(m_packet.rtrace != 1) begin
                    // For Trace Debug Regs altered in middle of simulation for CONC-8404
                    if (!($test$plusargs("ioaiu_cctrlr_mod") && (ioaiu_cctrlr_phase==1 || ioaiu_cctrlr_phase==2))) begin
                            m_ott_q[m_tmp_q[0]].print_me();
                            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response RTrace is wrong(Txn#%0d). Expected value is 1. Real value is: %0b. ARTrace: %0b. tctrlr[0].native_trace_en: %0b", m_tmp_q[0], m_packet.rtrace, m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.artrace, m_ott_q[m_tmp_q[0]].tctrlr[0].native_trace_en), UVM_NONE);
                    end
                end
            end
            else if(m_ott_q[m_tmp_q[0]].isACEWriteAddressRecd && m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awtrace && (m_ott_q[m_tmp_q[0]].tctrlr[0].native_trace_en || native_trace_CONC_7813)) begin
                if(m_packet.rtrace != 1) begin
                    // For Trace Debug Regs altered in middle of simulation for CONC-8404
                    if (!($test$plusargs("ioaiu_cctrlr_mod") && (ioaiu_cctrlr_phase==1 || ioaiu_cctrlr_phase==2))) begin
                        m_ott_q[m_tmp_q[0]].print_me();
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response RTrace is wrong(Txn#%0d). Expected value is 1. Real value is: %0b. AWTrace: %0b. tctrlr[0].native_trace_en: %0b", m_tmp_q[0], m_packet.rtrace, m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awtrace, m_ott_q[m_tmp_q[0]].tctrlr[0].native_trace_en), UVM_NONE);
                    end
                end
            end
            else begin
                if(m_packet.rtrace != 0) begin
                    // For Trace Debug Regs altered in middle of simulation for CONC-8404
                    if (!($test$plusargs("ioaiu_cctrlr_mod") && (ioaiu_cctrlr_phase==1 || ioaiu_cctrlr_phase==2))) begin
                        m_ott_q[m_tmp_q[0]].print_me();
                        if(m_ott_q[m_tmp_q[0]].isACEReadAddressRecd) begin
                            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response RTrace is wrong(Txn#%0d). Expected value is 0. Real value is: %0b. ARTrace: %0b. tctrlr[0].native_trace_en: %0b", m_tmp_q[0], m_packet.rtrace, m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.artrace, m_ott_q[m_tmp_q[0]].tctrlr[0].native_trace_en), UVM_NONE);
                        end if(m_ott_q[m_tmp_q[0]].isACEWriteAddressRecd) begin
                            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data response RTrace is wrong(Txn#%0d). Expected value is 0. Real value is: %0b. AWTrace: %0b. tctrlr[0].native_trace_en: %0b", m_tmp_q[0], m_packet.rtrace, m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awtrace, m_ott_q[m_tmp_q[0]].tctrlr[0].native_trace_en), UVM_NONE);
                        end
                    end
                end 
            end

        <% if(obj.COVER_ON) { %>
        	`ifndef FSYS_COVER_ON
                if(m_ott_q[m_tmp_q[0]].tctrlr[0].native_trace_en) 
                cov.collect_trace_cap(m_ott_q[m_tmp_q[0]]);
                `endif
                <% } %>
	    <%}%>

        //=== All coverage related code goes here ====//

 
        <%if(obj.COVER_ON) { %>
        	<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" ||obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACELITE-E"||obj.fnNativeInterface == "AXI4"||obj.fnNativeInterface == "AXI5") { %>
            	`ifndef FSYS_COVER_ON
            	cov.collect_axi_rresp(m_packet, m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt, core_id);
            	`endif
        	<%}%>
             `ifndef FSYS_COVER_ON
             cov.collect_dec_err_rresp(m_ott_q[m_tmp_q[0]] ,m_packet,  core_id);
             foreach (m_packet.rresp_per_beat[i]) begin
               tmp_rresp =  tmp_rresp | (m_packet.rresp_per_beat[i]); 
             end
             cov.collect_slv_err_rresp(m_ott_q[m_tmp_q[0]] ,tmp_rresp,  core_id);
             //#Cover.IOAIU.IllegaIOpToDII.DECERR
            if(m_ott_q[m_tmp_q[0]].illDIIAccess)
             cov.collect_ill_op_rsnoop(m_ott_q[m_tmp_q[0]] ,m_packet,m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt, core_id);
             `endif
            if(m_ott_q[m_tmp_q[0]].isRead) begin
            	araddr_active[m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]]--;
               	if(araddr_active[m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]] == 0) begin
                	araddr_active.delete(m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]); 
               	end
               	arid_active[m_packet.rid]--;
               	if(arid_active[m_packet.rid] == 0) begin
                  	arid_active.delete(m_packet.rid); 
               end
            end
        <%}%>
        
             if(m_ott_q[m_tmp_q[0]].m_ace_cmd_type == DVMMSG &&
                m_ott_q[m_tmp_q[0]].isDVMMultiPart &&
                !m_ott_q[m_tmp_q[0]].isACEReadDataSentNoRack) begin
                m_ott_q[m_tmp_q[0]].isACEReadDataDVMMultiPartSentNoRack = 0;
            end else begin

                m_ott_q[m_tmp_q[0]].isACEReadDataSentNoRack = 0;
                if(m_ott_q[m_tmp_q[0]].m_ace_cmd_type == DVMCMPL) begin
                    m_ott_q[m_tmp_q[0]].smi_exp_flags["ACEReadDataAck"] = 0;
                    m_ott_q[m_tmp_q[0]].smi_flags["ACEReadDataAck"] = 1;
                end
            end
      if (m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt != null) begin 
        case (m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arcmdtype)
          RDNOSNP         : num_rdnosnp++;
          RDONCE          : num_rdonce++;
          RDSHRD          : num_rdshrd++;        
          RDCLN           : num_rdcln++;         
          RDNOTSHRDDIR    : num_rdnotshrddir++;
          RDUNQ           : num_rdunq++;         
          CLNUNQ          : num_clnunq++;        
          MKUNQ           : num_mkunq++;        
          CLNSHRD         : num_clnshrd++;       
          CLNINVL         : num_clninvl++;       
          MKINVL          : num_mkinvl++;
          DVMCMPL         : num_dvmcmpl++;       
          DVMMSG          : num_dvmmsg++;        
          CLNSHRDPERSIST  : num_clnshardpersist ++; 
          RDONCEMAKEINVLD : num_rdoncemakeinvld++;
          RDONCECLNINVLD  : num_rdonceclinvld ++;
          default : begin 
            `uvm_warning("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("Did't match any read txn arcmdtype=%0s",m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arcmdtype))
          end  
        endcase
        num_reads++;
      end
 
        delete_txn(m_tmp_q[0]);

    endfunction : write_ncbu_read_data_chnl

    function void write_ncbu_read_data_advance_copy_chnl(axi4_read_data_pkt_t m_pkt);
        ace_read_data_pkt_t m_packet;
        ace_read_data_pkt_t m_packet_tmp;
       
        int                 m_tmp_q[$];
        int                 m_tmp_qDVM[$];
        bit                 m_check_fail;
        string 		    s;
        int idx;
        if(hasErr)
	        return;
        m_packet_tmp = new();
        m_packet = new();
        $cast(m_packet_tmp, m_pkt);
        m_packet.copy(m_packet_tmp);
        //uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Got_RDATA advance %s", m_packet.sprint_pkt()),UVM_LOW);       
        
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with (((item.m_ace_read_addr_pkt != null)? item.m_ace_read_addr_pkt.arid == m_packet.rid:0)&&
                                           (item.isDVMMultiPart ? 
                                           (item.isACEReadDataSent ? 
                                           (!item.isACEReadDataDVMMultiPartSent && !item.isACEReadDataDVMMultiPartSentNoRack) : 1) 
                                           : (!item.isACEReadDataSent && !item.isACEReadDataSentNoRack)));
        if(m_tmp_q.size()>0)begin
          if(m_tmp_q.size()==1)
          idx = m_tmp_q[0]; 
          else
          idx=find_oldest_read_in_ott_q(m_tmp_q);
          if(m_ott_q[idx].matchACEReadData(m_packet))begin
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d Received nativeInterface:<%=obj.fnNativeInterface%> packet on RRESP(read_data_chnl) channel in advance copy:%0s", m_ott_q[idx].tb_txnid,m_packet.sprint_pkt()), UVM_LOW)
            m_ott_q[idx].setup_ace_dvm_cmp_resp(m_packet);
            //FIXME - Kavish speak to Hema on deleting the ott-entry or not & early return from the function
            //delete_ott_entry(m_tmp_q[0],"DVMCmpReadData");
            return; 
          end
        end
            
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with ((item.isAtomic                              === 1 &&
					    item.isACEWriteAddressRecd                 === 1 &&
					    (item.m_ace_write_addr_pkt.awid == m_packet.rid) &&
					    ((item.isSMICMDReqNeeded) ? item.isSMICMDReqSent : 1) &&
					    ((item.isSMIDTRReqNeeded) ? item.isSMIDTRReqRecd : 1) &&
					    ((item.isACEReadDataNeeded) ? !item.isACEReadDataSent : 1) && item.isACEReadDataNeeded) ||
					   (item.isRead && (item.m_ace_cmd_type == DVMMSG) &&
					    item.isSMIDTWRespRecd &&
                                            (item.isDVMMultiPart ? (item.isACEReadDataSent ? (!item.isACEReadDataDVMMultiPartSent && !item.isACEReadDataDVMMultiPartSentNoRack) : 1) : (!item.isACEReadDataSent && !item.isACEReadDataSentNoRack)) &&
					    (item.m_ace_read_addr_pkt.arid == m_packet.rid)) || 
					   (item.isRead === 1   && item.isSnoop                               === 0   &&
					    (item.m_ace_cmd_type != DVMMSG) &&
                                            item.isACEReadAddressRecd                  === 1   &&
                                            (item.isMultiAccess                        === 1 ?
                                             item.isMultiLineMaster                    === 1 :
                                             1)                                               &&    
                                            ((item.isACEReadDataSent                   === 0   &&
                                              item.isACEReadDataSentNoRack             === 0)  
                                             ) &&
                                            (( <%if(obj.useCache) { %> 
                                                  ((item.csr_ccp_lookupen && item.csr_ccp_allocen)?(item.isIoCacheTagPipelineSeen == 1 || (item.isCCPCancelSeen == 1 )):1) && //considering ccp tag error although CCPCancelSeen, CONC-7613
                                              <%}%>
                                              (
                                               (item.isSMICMDReqNeeded                 === 0   || 
                                                 (item.isSMICMDReqSent                 === 1   &&
                                                 ((item.isSMIDTRReqNeeded              === 1 &&
                                                   (item.isSMIDTRReqRecd               === 1 ||
                                                    item.m_ace_read_addr_pkt.arlen     < SYS_nSysCacheline*8/WXDATA)) ||
                                                  item.isSMIDTRReqNeeded               === 0  ||
                                                  item.isDVMSync                       === 1))))) ||
                                               item.illegalNSAccess      			   === 1  ||
					       item.illegalCSRAccess				   === 1  || 
                                               item.addrNotInMemRegion                 === 1  ||
			                       item.mem_regions_overlap                === 1  ||
                                               (item.illDIIAccess                  === 1  &&
												((item.isMultiAccess) ? item.isMultiLineMaster : 1))
                                           ) &&
                                            item.m_ace_read_addr_pkt.arid              === m_packet.rid)  ||
                                            (item.isSnoop                              === 1   &&
					                        (item.m_ace_cmd_type != DVMMSG)                   &&
                                             item.isRead                               === 0   &&
                                             item.isAceCmdReqBlocked                   === 0   &&
                                             item.isACEReadAddressRecd                 === 1   &&
                                             item.isACEReadDataSent                    === 0   &&
                                             item.isACEReadDataSentNoRack              === 0   &&
                                             ((item.isDVMSync                          === 1  && 
                                               item.isACEReadAddressRecd               === 1) ? 
                                              item.m_ace_read_addr_pkt.arid            === m_packet.rid :
                                              0
                                             ) &&    
                                             item.isDVMSync                            === 1   &&
                                             item.isACESnoopReqSent                    === 1   &&
					                            !item.isStrRspEligibleForIssue())  
                                               
                                       );
         <% if((obj.testBench == "fsys") && (obj.testBench != "emu") && (obj.testBench != "emu_t")) { %>
         if($test$plusargs("ioaiu_zero_credit") && m_packet.rresp == 2'b11) begin
            
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("expected decerr received for zero credit uncorr test bresp=%0d",m_packet.rresp), UVM_LOW);
            
            hasErr = 1;
	 		->e_queue_delete;
            kill_uncorr_test.trigger(null);
	 		return;
            
        end         
	//this part is used for fsysy NRSAR test when NRSAR is disabled to gen decerr
        if($test$plusargs("k_nrsar_test") && m_packet.rresp == 2'b11) begin
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("expected decerr received for nrsar_test rresp=%0d",m_packet.rresp), UVM_LOW);
            //kill_uncorr_test.trigger(null);
            hasErr = 1;
	 		->e_queue_delete;
	 		return;
        end 
        else if ($test$plusargs("gpra_secure_uncorr_err") && m_packet.rresp == 2'b11) begin
            //#Stimulus.FSYS.address_dec_error.illegal_non_secure_txn
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("expected decerr received for secure nsx uncorr test rresp=%0d",m_packet.rresp), UVM_LOW);
            hasErr = 1;
	 		->e_queue_delete;
            kill_uncorr_grar_nsx_test.trigger(null);
	 		return;
        end        
        <% } %>       
        
        if (m_tmp_q.size === 0) begin                               
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_packet.sprint_pkt()), UVM_NONE);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Cannot find a corresponding transaction for the above ACE read data packet in advance copy"), UVM_NONE);
        end
        else begin
            if (m_tmp_q.size > 1) begin
                m_tmp_q[0] = find_oldest_read_in_ott_q(m_tmp_q);
            end

           `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Got_RDATA advance addr:0x%0h ns:%0b %s", m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_ott_q[m_tmp_q[0]].m_sfi_addr, m_ott_q[m_tmp_q[0]].m_security, m_packet.sprint_pkt()),UVM_LOW);       
           
           if(m_ott_q[m_tmp_q[0]].m_ace_cmd_type == DVMMSG &&
                m_ott_q[m_tmp_q[0]].isDVMMultiPart &&
                !m_ott_q[m_tmp_q[0]].isACEReadDataSentNoRack) begin
                m_ott_q[m_tmp_q[0]].isACEReadDataDVMMultiPartSentNoRack = 1;
            end else begin

                m_ott_q[m_tmp_q[0]].isACEReadDataSentNoRack = 1;
            end
            //DVM Order check
            if(m_ott_q[m_tmp_q[0]].m_ace_cmd_type == DVMMSG && dvm_resp_order) begin
                m_tmp_qDVM = {};
                m_tmp_qDVM = m_ott_q.find_index with (item.m_ace_cmd_type == DVMMSG &&
                                                      (item.isDVMMultiPart ? item.isACEReadDataDVMMultiPartSentNoRack : item.isACEReadDataSentNoRack) &&
                                                      item.t_creation < m_ott_q[m_tmp_q[0]].t_creation);
                if(m_tmp_qDVM.size > 0) begin
		            `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Found DVM Order Violation in RRESP! RTL sends DVMMSG RRESP(Txn #%0d) before finishes previous DVM operations(Txn #%0d)",m_tmp_q[0], m_tmp_qDVM[0]),UVM_NONE);
                    foreach(m_tmp_qDVM[idx])
                        m_ott_q[m_tmp_qDVM[idx]].print_me();
		            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Found DVM Order Violation in RRESP!"));
                end
            end
        end
        // Unblocking blocked ACE Cmd Entry due to AxID match
        // Excluding the unblocking if we have just received first part of a 
        // multi-part DVM message
        unblock_axid_read(m_packet.rid);

        <%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache){%> 
            // Bandwidth calculation start
            if(!m_ott_q[m_tmp_q[0]].addrNotInMemRegion) begin
                if (m_start_bw_calculations && m_bw_read_counter == 0) begin
                    t_read_bw_start_time        = $time;
                    t_read_bw_start_calc_time   = $time;
                    //`uvm_info("BW Calculations", $sformatf("Starting Read BW calculations now"), UVM_NONE);
                end
                m_bw_number_of_read_transactions++;
                if (m_ott_q[m_tmp_q[0]].is_ccp_hit) begin
                    m_bw_number_of_read_hits++;
                end
                if (m_start_bw_calculations) begin
                    m_bw_read_counter += m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arlen + 1;
                    if ((m_bw_read_counter - 1000) > m_bw_read_counter_prv_print) begin 
                        real m_read_bw_number       = (((m_bw_read_counter - m_bw_read_counter_prv_print) * WXDATA/8 * 10**9) / (($time - t_read_bw_start_time) / t_timeperiod)); 
                        int m_read_ioc_hit_perc    = m_bw_number_of_read_hits * 100 / m_bw_number_of_read_transactions;
                        `uvm_info("BW Calculations", $sformatf("READ: Number of beats = %0d Start time = %0t Current time = %0t total transactions till now %0d IOC Hit %0d(perc) Number of hits %0d Number of reads %0d Time Period %0t BW Number %0E (Bytes/s)", (m_bw_read_counter - m_bw_read_counter_prv_print), t_read_bw_start_time, $time, m_bw_read_counter, m_read_ioc_hit_perc, m_bw_number_of_read_hits, m_bw_number_of_read_transactions, t_timeperiod, m_read_bw_number), UVM_NONE); 
                        m_bw_read_counter_prv_print = m_bw_read_counter;
                        t_read_bw_start_time = $time;
                        m_bw_number_of_read_transactions = 0;
                        m_bw_number_of_read_hits         = 0;
                    end
                end
            end
        <%}%>
    endfunction : write_ncbu_read_data_advance_copy_chnl

    function void write_ncbu_read_data_chnl_every_beat(axi4_read_data_pkt_t m_pkt);
        ace_read_data_pkt_t   m_packet;
        ace_read_data_pkt_t   m_packet_tmp;
        int                   m_tmp_q[$];
        int                   m_tmp_qO[$];
        int                   m_tmp_q1[$];
        axi_bresp_enum_t      m_tmp_resp;
        int                   temp_cur[$];
        int                   temp_prev[$];
        
        m_packet_tmp = new();
        m_packet = new();
        $cast(m_packet_tmp, m_pkt);
        m_packet.copy(m_packet_tmp);

    	void'($cast(m_packet, m_pkt.clone()));

        if (owo_512b)
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB DBG", $sformatf("%s", m_packet.sprint_pkt()), UVM_NONE);

            if (!$test$plusargs("error_test")) begin
                // Increment the beat since we saw one
                temp_cur = read_packets.find_index with (item.arid == m_packet.rid);
                m_tmp_q1 = {};
                m_tmp_q1 = m_pkt_isAtomic.find_index with (item.isSMIDTRRespSent == 1 && item.isAtomic==1 && item.m_ace_write_addr_pkt.awid==m_packet.rid &&(item.m_ace_cmd_type != ATMSTR) );
                //`uvm_info("INTERLEAVE",$sformatf("temp_cur.size=%0d, m_tmp_q1.size=%0d",temp_cur.size,m_tmp_q1.size),UVM_HIGH)
 
                if(temp_cur.size() !=0 && m_tmp_q1.size() == 0) begin
                
                read_packets[temp_cur[0]].current_beat++;
                if (read_packets[temp_cur[0]].current_beat == read_packets[temp_cur[0]].max_beats_in_cacheline) read_packets[temp_cur[0]].current_beat = 0;
                
                // Check if current response is the last beat
                //#Check.IOAIU.ReadInterleave
                if(m_packet.rlast) begin
                    //data interleave on last beat
                    if(m_packet.rid != prev_rid0 ) begin
		      curr_interleave_cnt = curr_interleave_cnt+1;
		      `uvm_info ("INTERLEAVE",$sformatf("interleaving_rid :%0h and curr_interleave_cnt:%0h",prev_rid0,curr_interleave_cnt),UVM_HIGH);
		      sb_stall_if.perf_count_events["Interleaved_Data"].push_back(curr_interleave_cnt);
		    end
                    // if it is last beat, no need of checks. Remove it from the queue
                    read_packets.delete(temp_cur[0]);
                    prev_rid = -1;
                  prev_rlast = 1;
                end else begin
                    // rid changed while the previous rid is not the last beat
			if ((m_packet.rid != prev_rid0) && (!prev_rlast)) begin
				curr_interleave_cnt = curr_interleave_cnt+1;
				`uvm_info ("INTERLEAVE",$sformatf("interleaving_rid : %0h and curr_interleave_cnt : %0h", prev_rid0, curr_interleave_cnt),UVM_HIGH);
				sb_stall_if.perf_count_events["Interleaved_Data"].push_back(curr_interleave_cnt);
			end 
		    prev_rlast = 0;
		    prev_rid0 = m_packet.rid;
                    if (m_packet.rid != prev_rid && prev_rid != -1) begin
                        temp_prev = read_packets.find_first_index(item) with (item.arid == prev_rid);
                        
                        // Invalid interleaving as we did not reach the cacheline boundary
                        if (read_packets[temp_prev[0]].current_beat != 0) begin
                            // #Check.IOAIU.cache_interleave
                            `uvm_error("<%=obj.BlockId%> Interleave Error", $sformatf("Rd Response interleaved between cacheline boundary for rid : 0x%0h", prev_rid));
                        end
                        <%if(obj.fnDisableRdInterleave){%>
                            // #Check.IOAIU.rd_interleave_disable
                            `uvm_error("<%=obj.BlockId%> Interleave Error", $sformatf("Rd Response interleaved when interleaving is disabled for rid : %0d", prev_rid));
                        <%} else {%>
                            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Read response Interleaved but not within a cacheline") ,UVM_HIGH);
                            <%if(obj.nNativeInterfacePorts == 1 && obj.testBench == 'io_aiu'){%>
                                cov.rd_interleaved();
                                // #Cover.IOAIU.multiCacheline
                                cov.sample_rd_interleaved();
                            <%}%>
                        <%}%>
                    end
                   end
                   if (!m_packet.rlast) prev_rid = m_packet.rid;
                end
                if(m_tmp_q1.size != 0 && m_packet.rlast == 1) begin
                        m_pkt_isAtomic.delete(m_tmp_q1[0]);
                        m_tmp_q1.delete();
                end 
                end
     
    endfunction

    //----------------------------------------------------------------------- 
    // ACE Write Data Channel
    //----------------------------------------------------------------------- 

    function void write_ncbu_write_data_chnl(axi4_write_data_pkt_t m_pkt);
        ace_write_data_pkt_t m_packet;
        ace_write_data_pkt_t m_packet_tmp;
        ace_write_data_pkt_t m_ace_write_data_pkt;
        ace_write_data_pkt_t m_owo_native_wr_data_pkt;
        ace_write_data_pkt_t pop_agent_data_pkt;
        ace_write_data_pkt_t pop_data_pkt, push_data_pkt;
        int                  m_tmp_q[$];
        int                  m_tmp_qA[$];
        int native_awlen;

        m_packet_tmp = new();
        m_packet = new();
        $cast(m_packet_tmp, m_pkt);
        m_packet.copy(m_packet_tmp);
       	
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with ((item.isWrite              === 1  ||
                                            item.isUpdate             === 1) &&
                                           item.isACEWriteAddressRecd === 1  &&
                                           item.isACEWriteDataNeeded  === 1  &&
                                           item.isACEWriteDataRecd    === 0 
                                       );

        if (m_tmp_q.size === 0) begin
            //It is possible to receive the write_data packet before the write_addr packet. 
            if (owo_512b) begin
       	    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below <%=obj.fnNativeInterface%>_NativeWrData:%0s"<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt()) ,UVM_LOW);
                m_owo_native_oawd_q.push_back(m_packet);
                m_owo_native_oawd_tmp_q.push_back(m_packet);
            end else begin
       	    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below <%=obj.fnNativeInterface%>_WrData:%0s"<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt()) ,UVM_LOW);
                m_oawd_q.push_back(m_packet);
                ->e_queue_add;
            end
        end
        // Finding the oldest write transaction for which this write data is a match
        else begin
            m_tmp_q[0] = find_oldest_entry_in_ott_q(m_tmp_q);
           
            if (owo_512b) begin
                m_owo_native_oawd_q.push_back(m_packet);
                m_owo_native_oawd_tmp_q.push_back(m_packet);
                if (m_packet.wlast && ((m_ott_q[m_tmp_q[0]].m_owo_native_wr_addr_pkt.awlen + 1) != m_owo_native_oawd_tmp_q.size())) 
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("IOAIU_UID:%0d Mismatch in native_awlen:%0d and  native_wr_data_beats:%0d received", m_ott_q[m_tmp_q[0]].tb_txnid, m_ott_q[m_tmp_q[0]].m_owo_native_wr_addr_pkt.awlen, m_owo_native_oawd_tmp_q.size()));
                if (m_packet.wlast)
                    m_owo_native_oawd_tmp_q.delete();
            end else begin 
                m_oawd_q.push_back(m_packet);
                if (m_packet.wlast && ((m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen + 1) != m_oawd_q.size()))
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("IOAIU_UID:%0d Mismatch in native_awlen:%0d and  number_of_wr_data_beats:%0d received", m_ott_q[m_tmp_q[0]].tb_txnid, native_awlen, m_oawd_q.size()));
            end 

            if (owo_512b) begin     
       		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below <%=obj.fnNativeInterface%>_NativeWrData:%0s",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt()) ,UVM_LOW);
                pop_data_pkt = m_owo_native_oawd_q.pop_front();
                if (m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen == 0) begin 
                    push_data_pkt = new();
                    push_data_pkt.wstrb = new[1];
                    push_data_pkt.wdata = new[1];
                    if (m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awaddr[WLOGXDATA-1:0] < 32) begin 
                        push_data_pkt.wstrb[0] = pop_data_pkt.wstrb[0][(WXDATA/(8*2))-1:0];
                        push_data_pkt.wdata[0] = pop_data_pkt.wdata[0][(WXDATA/2)-1:0]; 
                    end else begin
                        push_data_pkt.wstrb[0] = pop_data_pkt.wstrb[0][(WXDATA/8)-1:(WXDATA/(8*2))];
                         push_data_pkt.wdata[0] = pop_data_pkt.wdata[0][(WXDATA-1):WXDATA/2]; 
                    end
       		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Post axi_shim(data-width adapter) <%=obj.fnNativeInterface%>_WrData:%0s",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, push_data_pkt.sprint_pkt()) ,UVM_LOW);
                    m_oawd_q.push_back(push_data_pkt);
                end else begin 
                    push_data_pkt = new();
                    push_data_pkt.wstrb = new[1];
                    push_data_pkt.wdata = new[1];
                    push_data_pkt.wstrb[0] = pop_data_pkt.wstrb[0][(WXDATA/(8*2))-1:0];
                    push_data_pkt.wdata[0] = pop_data_pkt.wdata[0][(WXDATA/2)-1:0]; 
       		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%>  Post axi_shim(data-width adapter) <%=obj.fnNativeInterface%>_WrData:%0s",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, push_data_pkt.sprint_pkt()) ,UVM_LOW);
                    m_oawd_q.push_back(push_data_pkt);
                    push_data_pkt = new();
                    push_data_pkt.wstrb = new[1];
                    push_data_pkt.wdata = new[1];
                    push_data_pkt.wstrb[0] = pop_data_pkt.wstrb[0][(WXDATA/8)-1:(WXDATA/(8*2))];
                    push_data_pkt.wdata[0] = pop_data_pkt.wdata[0][(WXDATA-1):WXDATA/2]; 
       		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Post axi_shim(data-width adapter) <%=obj.fnNativeInterface%>_WrData:%0s",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, push_data_pkt.sprint_pkt()) ,UVM_LOW);
                    m_oawd_q.push_back(push_data_pkt);
                end
            end 
            else begin 
       		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below <%=obj.fnNativeInterface%>_WrData:%0s",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt()) ,UVM_LOW);
            end
           
           // foreach (m_oawd_q[i]) begin
           //     `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("idx:%0d WrData:%0s",i, m_oawd_q[i].sprint_pkt()) ,UVM_LOW);
           // end
            if(m_oawd_q.size() == (m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen+1)) begin 
                m_ace_write_data_pkt       = new();
                m_ace_write_data_pkt.wdata = new[(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen+1)];
                m_ace_write_data_pkt.wstrb = new[(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen+1)];
                for(int i=0; i<(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen+1);i++) begin 
                    pop_agent_data_pkt            = m_oawd_q.pop_front();
                    m_ace_write_data_pkt.wdata[i] = pop_agent_data_pkt.wdata[0];
                    m_ace_write_data_pkt.wstrb[i] = pop_agent_data_pkt.wstrb[0];
                end
								//CONC-17918
							 //for unaligned start addr, vip might randomly drive all byte strbs 0 , so the check can be ignored for 1st data beat
								if($test$plusargs("ptl_wstrb") && m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awcmdtype inside {WRNOSNP,WRUNQ})begin
									foreach (m_ace_write_data_pkt.wstrb[i]) begin
										if (i && m_ace_write_data_pkt.wstrb[i] inside {0,((1 << (1 << (m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awsize))) - 1)}) begin
											`uvm_error("<%=obj.strRtlNamePrefix%>SCB TXN ERROR", $sformatf("IOAIU_UID:%0d WrData expected to have partial strbs", m_ott_q[m_tmp_q[0]].tb_txnid));
										end
									end									
								end
                m_ott_q[m_tmp_q[0]].setup_ace_write_data(m_ace_write_data_pkt);
            end 
        end
    endfunction : write_ncbu_write_data_chnl

    //----------------------------------------------------------------------- 
    // ACE Write Response Channel
    //----------------------------------------------------------------------- 

    function void write_ncbu_write_resp_chnl(axi4_write_resp_pkt_t m_pkt);
        ace_write_resp_pkt_t m_packet;
        ace_write_resp_pkt_t m_packet_tmp;
        bit                  m_check_fail;
        int                  m_tmp_q[$], m_err_txnq[$];
        int                  m_tmp_qA[$];
        int                  m_tmp_qO[$];
    	  axi_bresp_enum_t act_bresp;
        bit cmdstatus_multiline0,cmdstatus_multiline1;

        m_packet_tmp = new();
        m_packet     = new();
        $cast(m_packet_tmp, m_pkt);
        m_packet.copy(m_packet_tmp);
        num_writes++;
        if(hasErr)
       return;
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with ((((item.isWrite                  === 1  || item.isUpdate === 1)                 &&
                                             item.isACEWriteAddressRecd      === 1                                          &&
                                             ((item.isACEWriteDataNeeded) ? item.isACEWriteDataRecd === 1 : 1)              &&
                                             item.isACEWriteRespSent         === 0                                          &&
                                        	 item.isACEWriteRespSentNoWack   === 1                                          &&
                                             ((
                                              <%if(obj.useCache) { %> 
                                               ((item.csr_ccp_lookupen && item.csr_ccp_allocen)? (item.isIoCacheTagPipelineSeen        === 1):1) &&
                                              <% } %>
                                               (item.isSMICMDReqNeeded        === 0 ||   
                                               (item.isSMICMDReqSent         === 1 &&
                                               (item.isSMISTRReqRecd         === 1 ||
                                                item.isSMISTRReqNotNeeded    === 1) &&   
                                                ((item.isSMIDTWReqNeeded     === 1 &&
                                                  item.isSMIDTWReqSent       === 1 &&
                                                  item.isSMIDTWRespRecd      === 1) ||
                                                  item.isSMIDTWReqNeeded     === 0)))) ||
                                              item.addrNotInMemRegion        === 1  ||
                                              item.mem_regions_overlap       === 1  ||
                                              item.dtrreq_cmstatus_err       === 1  ||
                                              item.dtwrsp_cmstatus_err       === 1  ||
                                              item.hasFatlErr       		 === 1  ||
                                              item.tagged_decerr       		 === 1  ||
                                              item.illegalNSAccess      	 === 1  ||
					      item.illegalCSRAccess		 === 1	||
                                              item.illDIIAccess         === 1) &&
											 ((item.isMultiAccess) ? item.isMultiLineMaster : 1))
                                              ) &&
                                              item.isAceCmdReqBlocked        === 0 &&
                                              item.m_ace_write_addr_pkt.awid === m_packet.bid);

		//HS 09-09-22 move all error cases to here eventually
		if (m_tmp_q.size() == 0) begin
			m_err_txnq = {};
			m_err_txnq = m_ott_q.find_index with (
													(item.isWrite || item.isUpdate) &&
													 item.isACEWriteAddressRecd &&
													 item.isACEWriteDataRecd &&
													!item.isACEWriteRespSent &&
													 item.isACEWriteRespSentNoWack &&
													(item.m_ace_write_addr_pkt.awid === m_packet.bid) &&
													(item.addrNotInMemRegion        === 1  ||
                                             								 item.mem_regions_overlap       === 1  ||
                                             								 item.dtrreq_cmstatus_err       === 1  ||
                                              								 item.dtwrsp_cmstatus_err       === 1  ||
                                              								 item.hasFatlErr       		=== 1  ||
                                              								 item.illegalNSAccess      	=== 1  ||
													 item.illegalCSRAccess		=== 1  ||
                                              								item.illDIIAccess         === 1) &&  
													((item.isMultiAccess) ? item.isMultiLineMaster : 1));
		end

        if(m_ott_q[m_tmp_q[0]].illegalNSAccess ||  m_ott_q[m_tmp_q[0]].illegalCSRAccess || m_ott_q[m_tmp_q[0]].illDIIAccess) begin
        csr_addr_decode_err_msg_rsp_id_q.push_back(m_packet.bid);
        case (core_id) 
<%for(let i=0; i<obj.nNativeInterfacePorts; i++) {%>
          <%=i%> :  ev_aw_req_<%=i%>.trigger();
<%}%>
        endcase
	end

        if (m_tmp_q.size() == 0 && m_err_txnq.size() == 0) begin
        	`uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("Received below <%=obj.fnNativeInterface%>_WrResp:%0s", m_packet.sprint_pkt()) ,UVM_NONE);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Found no corresponding write address channel transactions for the above ACE write response packet"), UVM_NONE);   
		end else if (m_tmp_q.size() == 0) begin 
			m_tmp_q = m_err_txnq;
		end
            
        
                m_check_fail = 0;
                if(transOrderMode_wr inside {strictReqMode, pcieOrderMode}) begin
            		m_check_fail = 1;
                end
                // Confirm that CmdReq of subsequent requests were sent after this request was complete (DtwRsp sent)
                if (m_check_fail) begin
                    int index = find_oldest_entry_in_ott_q(m_tmp_q);
                    time t_finish_time;
                    if(m_ott_q[index].m_ace_write_addr_pkt.awcache[3:1] == 0) begin
                        if (m_ott_q[index].isSMIDTWReqNeeded) begin
                            t_finish_time = m_ott_q[index].t_sfi_str_req;
                        end
                        else begin
                            t_finish_time = m_ott_q[index].t_sfi_str_req;
                        end
                    end else begin
                        if (m_ott_q[index].gpra_order.policy == 2'b11 &&
                            m_ott_q[index].isSMIDTWReqNeeded) begin
                            t_finish_time = m_ott_q[index].t_sfi_str_req;
                        end
                        else begin
                            t_finish_time = m_ott_q[index].t_sfi_str_req;
                        end
                    end
                    if (t_finish_time === 0) begin
                        m_ott_q[index].print_me(0,1);
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Above packet was not finished but write response was still sent"), UVM_NONE);
                    end
                    else begin
                        for (int i = 0; i < m_tmp_q.size; i++) begin
                            if (m_tmp_q[i] === index) begin
                                continue;
                            end
                            else begin
                                if ((m_ott_q[m_tmp_q[i]].t_sfi_cmd_req <= t_finish_time) &&
                                    (m_ott_q[m_tmp_q[i]].transOrderMode == pcieOrderMode && m_ott_q[m_tmp_q[i]].gpra_order.writeID == 0)) begin
                                    m_ott_q[index].print_me();
                                    m_ott_q[m_tmp_q[i]].print_me();
									//#Check.IOAIU.BResp.OrderingCheck
                                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Above newer write request for which write resp is also expected started before the oldest write request completed"), UVM_NONE);   
                                end
                            end
                        end
                    end
                end
                m_tmp_q[0] = find_oldest_entry_in_ott_q(m_tmp_q);
               `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below <%=obj.fnNativeInterface%>_WrResp:%0s",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt()) ,UVM_LOW);
              if (m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt != null) begin 
                case (m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awcmdtype) 
                  WRNOSNP         : num_wrnosnp++; 
                  WRUNQ           : num_wrunq++;  
                  WRLNUNQ         : num_wrlnunq++;
                  WRCLN           : num_wrcln++; 
                  WRBK            : num_wrbk++;
                  WREVCT          : num_wrevct++;
                  EVCT            : num_evict++;
                  ATMLD           : num_atmld++;
                  ATMCOMPARE      : num_atmcompare++;
                  ATMSWAP         : num_atmswap++; 
                  ATMSTR          : num_atmstr++; 
                  WRUNQPTLSTASH   : num_wrunqptlstash++;                 
                  WRUNQFULLSTASH  : num_wrunqfullstash++;
                  STASHONCESHARED : num_stashonceshared++;
                  STASHONCEUNQ    : num_stashonceunq++;   
                  default : begin 
                    `uvm_warning("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("Did't match any write txn awcmdtype=%0s",m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awcmdtype))
                  end 
                endcase 
              end 
            <%if(obj.COVER_ON) { %>
                awaddr_active[m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]]--;
                if(awaddr_active[m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]] == 0) begin
                awaddr_active.delete(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]); 
                end
                awid_active[m_packet.bid]--;
                if(awid_active[m_packet.bid] == 0) begin
                awid_active.delete(m_packet.bid); 
                end
                <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" ||obj.fnNativeInterface == "ACE-LITE"||obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") { %>
                    `ifndef FSYS_COVER_ON
                    cov.collect_axi_bresp(m_packet, m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt, core_id);
                    `endif
                <%}%>
                     `ifndef FSYS_COVER_ON
                     cov.collect_dec_err_bresp(m_ott_q[m_tmp_q[0]],m_packet,core_id);
                     cov.collect_slv_err_bresp(m_ott_q[m_tmp_q[0]],m_packet,core_id);
                     //#Cover.IOAIU.IllegaIOpToDII.DECERR
                     if(m_ott_q[m_tmp_q[0]].illDIIAccess)
                     cov.collect_ill_op_wsnoop(m_ott_q[m_tmp_q[0]],m_packet, m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt,core_id);
                    `endif
            <%}%>
            //if (!(addrMgrConst::get_addr_memorder(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awaddr) == 'b101xx)) begin// relaxed order=2 & writeID=1 =>unorder
            check_oldest_axid_in_ott_q(m_tmp_q[0]);
            //end
            m_ott_q[m_tmp_q[0]].setup_ace_write_resp(m_packet);
	
	    check_response_ordering(m_tmp_q[0]);
           //#Check.IOAIU.ACE.B.BTRACE
           //#Check.IOAIU.BTRACE
            <%if(aiu_axiInt.params.eTrace > 0){%>
                if(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awtrace && (m_ott_q[m_tmp_q[0]].tctrlr[0].native_trace_en || native_trace_CONC_7813)) begin
                    if(m_ott_q[m_tmp_q[0]].m_ace_write_resp_pkt.btrace != 1) begin
                    // For Trace Debug Regs altered in middle of simulation for CONC-8404
                    if (!($test$plusargs("ioaiu_cctrlr_mod") && (ioaiu_cctrlr_phase==1 || ioaiu_cctrlr_phase==2))) begin
                            m_ott_q[m_tmp_q[0]].print_me(0,1);
                            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE B response BTrace is wrong(Txn#%0d). Expected value is 1. Real value is: %0b. AWTrace: %0b. tctrlr[0].native_trace_en: %0b", m_tmp_q[0], m_ott_q[m_tmp_q[0]].m_ace_write_resp_pkt.btrace, m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awtrace, m_ott_q[m_tmp_q[0]].tctrlr[0].native_trace_en), UVM_NONE);
                    end
                    end
                end
                else begin
                    if(m_ott_q[m_tmp_q[0]].m_ace_write_resp_pkt.btrace != 0) begin
                    // For Trace Debug Regs altered in middle of simulation for CONC-8404
                    if (!($test$plusargs("ioaiu_cctrlr_mod") && (ioaiu_cctrlr_phase==1 || ioaiu_cctrlr_phase==2))) begin
                            m_ott_q[m_tmp_q[0]].print_me(0,1);
                            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE B response BTrace is wrong(Txn#%0d). Expected value is 0. Real value is: %0b. AWTrace: %0b. tctrlr[0].native_trace_en: %0b", m_tmp_q[0], m_ott_q[m_tmp_q[0]].m_ace_write_resp_pkt.btrace, m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awtrace, m_ott_q[m_tmp_q[0]].tctrlr[0].native_trace_en), UVM_NONE);
                    end
                    end 
                end
        <% if(obj.COVER_ON) { %>
                `ifndef FSYS_COVER_ON
                if(m_ott_q[m_tmp_q[0]].tctrlr[0].native_trace_en)
                cov.collect_trace_cap(m_ott_q[m_tmp_q[0]]);
                `endif
        <% } %>
            <%}%>
	        //Removed old redundant exclusive bresp check.
            if (m_ott_q[m_tmp_q[0]].isACEWriteDataRecd === 0 && m_ott_q[m_tmp_q[0]].isACEWriteDataNeeded === 1) begin
                m_ott_q[m_tmp_q[0]].print_me(0,1);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE write response sent for a packet for which ACE write data has not yet been received"), UVM_NONE);   
            end
            // #Check.AIU.UncorrectibleError.OutgoingDTWreqFromEmbeddedMemoryWithErrorCausesBRESPError
            if (m_ott_q[m_tmp_q[0]].m_ace_write_resp_pkt.bresp !== m_ott_q[m_tmp_q[0]].m_axi_resp_expected[0] && !m_ott_q[m_tmp_q[0]].isMultiAccess && (m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlock == NORMAL) && (!m_ott_q[m_tmp_q[0]].isAtomic || m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awcmdtype == ATMSTR)) begin //CONC-16994
                // Allowing AIU double bit errors to have bresp = slverr
                if ((m_ott_q[m_tmp_q[0]].m_axi_resp_expected[0] === OKAY && aiu_double_bit_errors_enabled && m_ott_q[m_tmp_q[0]].m_ace_write_resp_pkt.bresp === SLVERR)||($test$plusargs("dtrreq_cmstatus_with_error") && m_ott_q[m_tmp_q[0]].isAtomic)) begin
                end
                else begin
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE write response bresp field sent the wrong bresp message (Expected:%0d Actual:%0d)", m_ott_q[m_tmp_q[0]].m_axi_resp_expected[0], m_ott_q[m_tmp_q[0]].m_ace_write_resp_pkt.bresp), UVM_NONE);   
                end
            end
            if (m_ott_q[m_tmp_q[0]].isMultiAccess) begin
                int multiline_tracking_id_tmp = m_ott_q[m_tmp_q[0]].m_multiline_tracking_id;
                int total_cacheline_count_tmp = m_ott_q[m_tmp_q[0]].total_cacheline_count;
                int m_tmp_qA[$];
                int m_tmp_qA_1[$];
                bit slv_err_in_multi_line_bresp;
                int error_occurred_at_multiline_order;

                m_tmp_qA_1 = {};
                m_tmp_qA_1 = m_ott_q.find_index with (item.isWrite && item.isMultiAccess && item.m_multiline_tracking_id === multiline_tracking_id_tmp);
                foreach(m_tmp_qA_1[i]) begin
                    if (m_ott_q[m_tmp_qA_1[i]].m_axi_resp_expected[0] === SLVERR || m_ott_q[m_tmp_qA_1[i]].m_axi_resp_expected[0] === DECERR) begin
                        slv_err_in_multi_line_bresp = 1;
                        error_occurred_at_multiline_order = m_ott_q[m_tmp_qA_1[i]].multiline_order;
                        break;
                    end
                end

                if (slv_err_in_multi_line_bresp) begin
                    for (int i = 0; i < total_cacheline_count_tmp; i++) begin
                        int index = -1;
                        m_tmp_qA = {};
                        m_tmp_qA = m_ott_q.find_index with (item.isWrite                 === 1 &&
                                item.isMultiAccess           === 1 &&
                                                            item.m_multiline_tracking_id === multiline_tracking_id_tmp
                                                        );
                        foreach (m_tmp_qA[j]) begin
                            if (m_ott_q[m_tmp_qA[j]].multiline_order === i) begin
                                index = m_tmp_qA[j];
                                break;
                            end 
                        end
                        if(index == -1)
                            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("multiline not found"),UVM_NONE);
                        m_ott_q[index].setup_ace_write_resp(m_packet);

                        if (m_ott_q[index].multiline_ready_to_delete && !(m_ott_q[index].isSMISTRReqRecd && !m_ott_q[index].isSMISTRRespSent) <%if(obj.useCache) { %> && !(m_ott_q[index].is_ccp_hit && !m_ott_q[index].isIoCacheDataPipelineSeen) <% } %>) begin
                            m_ott_q_dtr_cmstatus_err.push_back(m_ott_q[index]);
                            delete_ott_entry(index, MultiAceWrResp);
                        end
                        else begin
                            m_ott_q[index].multiline_ready_to_delete = 1;
                            if (m_ott_q[index].multiline_order > error_occurred_at_multiline_order && 
                                !(m_ott_q[index].isSMISTRReqRecd && !m_ott_q[index].isSMISTRRespSent) 
                                <%if(obj.useCache) { %> && !(m_ott_q[index].is_ccp_hit && !m_ott_q[index].isIoCacheDataPipelineSeen && !m_ott_q[index].dtrreq_cmstatus_err && !m_ott_q[index].dtwrsp_cmstatus_err) <% } %>) begin
                                    //m_ott_q[index].print_me();
                                    m_ott_q_dtr_cmstatus_err.push_back(m_ott_q[index]);
                                    delete_ott_entry(index, MultiAceWrResp);
                                <%if(obj.useCache){%>
                                    end else if (!(m_ott_q[index].isSMISTRReqRecd && !m_ott_q[index].isSMISTRRespSent)) begin
                                        m_ott_q_tag_err.push_back(m_ott_q[index]);
                                        delete_ott_entry(index, MultiAceWrResp);
                                <%}%>
                            end else if (m_ott_q[index].hasFatlErr && !(m_ott_q[index].isSMISTRReqRecd && !m_ott_q[index].isSMISTRRespSent)) begin
                                m_ott_q_fatal_err.push_back(m_ott_q[index]);
                                delete_ott_entry(index, MultiAceWrResp);
                            end else if (m_ott_q[index].addrNotInMemRegion) begin
                                delete_ott_entry(index, MultiAceWrResp);
                            end else if (m_ott_q[index].illegalNSAccess  || m_ott_q[index].illegalCSRAccess ||  m_ott_q[index].illDIIAccess ) begin
                                delete_ott_entry(index, MultiAceWrResp);
							end
                        end
                    end//for (int i = 0; i < total_cacheline_count_tmp; i++) begin
                    return;
				end//if (slv_err_in_multi_line_bresp)
            end//if (m_ott_q[m_tmp_q[0]].isMultiAccess)
            else if (m_ott_q[m_tmp_q[0]].m_axi_resp_expected[0] === SLVERR || m_ott_q[m_tmp_q[0]].m_axi_resp_expected[0] === DECERR) begin
                if (!(m_ott_q[m_tmp_q[0]].isSMISTRReqRecd && !m_ott_q[m_tmp_q[0]].isSMISTRRespSent)) begin
                    m_ott_q_dtr_cmstatus_err.push_back(m_ott_q[m_tmp_q[0]]);
                    delete_ott_entry(m_tmp_q[0], AceWrRsp);
                    return;
                end
            end
            
            if (m_ott_q[m_tmp_q[0]].dtrreq_cmstatus_err) begin
                if (m_ott_q[m_tmp_q[0]].isMultiAccess) begin
                    int m_tmp_qA[$];
                    int multiline_tracking_id_tmp = m_ott_q[m_tmp_q[0]].m_multiline_tracking_id;
                    int total_cacheline_count_tmp = m_ott_q[m_tmp_q[0]].total_cacheline_count;
                    for (int i = 0; i < total_cacheline_count_tmp; i++) begin
                        int index;
                        m_tmp_qA = {};
                        m_tmp_qA = m_ott_q.find_index with (item.isMultiAccess           === 1 &&
                        item.m_multiline_tracking_id === multiline_tracking_id_tmp);
                        index = m_tmp_qA[0];
                        m_ott_q_dtr_cmstatus_err.push_back(m_ott_q[index]);
                        delete_ott_entry(index, AceWrRsp);
                    end
                    return;
                end
                else begin
                    if (!(m_ott_q[m_tmp_q[0]].isSMISTRReqRecd && !m_ott_q[m_tmp_q[0]].isSMISTRRespSent)) begin
                      delete_ott_entry(m_tmp_q[0], AceWrRsp);
                      return;
                    end
                end
            end
            else if (m_ott_q[m_tmp_q[0]].addrNotInMemRegion && m_ott_q[m_tmp_q[0]].addrInCSRRegion || m_ott_q[m_tmp_q[0]].mem_regions_overlap || m_ott_q[m_tmp_q[0]].tagged_decerr) begin
                delete_ott_entry(m_tmp_q[0], AceWrRsp);
                return;
            end
            // CONC-2292 - In case STRResp went ahead of WrRsp
            else if ((m_ott_q[m_tmp_q[0]].isSMISTRReqNotNeeded || m_ott_q[m_tmp_q[0]].isSMISTRRespSent) && (!m_ott_q[m_tmp_q[0]].isSMICMDReqSent || m_ott_q[m_tmp_q[0]].isSMICMDRespRecd) && !m_ott_q[m_tmp_q[0]].isMultiAccess && (m_ott_q[m_tmp_q[0]].isFillReqd ? (m_ott_q[m_tmp_q[0]].isFillDataRcvd && m_ott_q[m_tmp_q[0]].isFillCtrlRcvd):1)) begin
                delete_ott_entry(m_tmp_q[0], AceWrRsp);
            end
            else if (m_ott_q[m_tmp_q[0]].isUpdate &&
                     m_ott_q[m_tmp_q[0]].m_ace_cmd_type == EVCT) begin
                delete_ott_entry(m_tmp_q[0], AceWrRsp);
                return;
            end
            
			else begin

                if (m_ott_q[m_tmp_q[0]].isMultiAccess) begin
                    int m_tmp_qA[$];
                    bit first_err_captured;
                    time t_last_dtw_rsp, t_last_str_req;
                    bit error_occured_in_1st_txn;
                    int multiline_tracking_id_tmp = m_ott_q[m_tmp_q[0]].m_multiline_tracking_id;
                    int total_cacheline_count_tmp = m_ott_q[m_tmp_q[0]].total_cacheline_count;
                    bit[1:0] m_axi_final_error_expected = OKAY;
                    m_tmp_qA = {};
                    m_tmp_qA = m_ott_q.find_index with (item.isMultiAccess           === 1 &&
                                                        item.m_multiline_tracking_id === multiline_tracking_id_tmp &&
                                                        ( 
                                                            <%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %> 
                                                                ((csr_ccp_lookupen && csr_ccp_allocen)? ( // ccp_enable 
								    (item.isIoCacheTagPipelineSeen === 0 && item.hasFatlErr == 0) ||
                                                                        (
                                                                        ( 
                                                                         (item.hasFatlErr === 0) && 
                                                                          (item.m_iocache_allocate === 0 && 
                                                                            item.is_ccp_hit === 0)
                                                                ))) : 1) //ccp_disable
			                             					    &&
                                                                  ((item.isSMISTRReqNotNeeded === 0 &&
                                                                    item.isSMISTRReqRecd      === 0)  ||
                                                                  (item.isSMIDTWReqNeeded     === 1 && 
                                                                   item.isSMIDTWRespRecd      === 0))
                                                                  //||  
                                                            <% } else { %>
                                                                (item.isSMISTRReqNotNeeded  === 0 && 
                                                                 item.isSMISTRReqRecd       === 0) ||
                                                                (item.isSMIDTWReqNeeded     === 1 && 
                                                                 item.isSMIDTWRespRecd      === 0) //|| 
                                                            <% } %>
                                                     ));
                    if (m_tmp_qA.size() > 0) begin
                        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("ACE multiline writes not completed and write response still sent (%0d not completed)", m_tmp_qA.size()), UVM_NONE);
                        foreach (m_tmp_qA[i]) begin
                            m_ott_q[m_tmp_qA[i]].print_me(0,1,0,0);
                        end
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Multiline write response sent even though certain individual writes have not completed"), UVM_NONE); 
                    end
                    // Unblocking blocked ACE Cmd Entry due to AxID match
                    //unblock_axid_write(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awid);
                    // Deleting OutstTxn entries that have finished
                    for (int i = 0; i < total_cacheline_count_tmp; i++) begin
                        int index = -1;
                        m_tmp_qA = {};
                        m_tmp_qA = m_ott_q.find_index with (item.isWrite                   === 1 &&
							    item.isMultiAccess             === 1 &&
                                                            item.m_multiline_tracking_id   === multiline_tracking_id_tmp );
                        foreach (m_tmp_qA[j]) begin
                            if (m_ott_q[m_tmp_qA[j]].multiline_order === i) begin
                                index = m_tmp_qA[j];
                                break;
                            end
                        end                                
		                if(index == -1)
		                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("multiline not found"),UVM_NONE);

                        m_ott_q[index].setup_ace_write_resp(m_packet);
                        if( m_ott_q[index].m_ace_write_addr_pkt.awlock == EXCLUSIVE && m_ott_q[index].isMultiAccess==1 && !(m_ott_q[index].m_ace_write_resp_pkt.bresp[1:0] inside {DECERR,SLVERR}))
                        begin
                            if(m_ott_q[index].multiline_order==0) begin
                              uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Multiline order %0d Expected Bresp %0p",m_ott_q[index].multiline_order,m_ott_q[index].m_ace_write_resp_pkt.bresp), UVM_DEBUG);
                            end  
                            if(m_ott_q[index].multiline_order==1) begin
                              uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Multiline order %0d Expected Bresp %0p",m_ott_q[index].multiline_order,m_ott_q[index].m_ace_write_resp_pkt.bresp), UVM_DEBUG);
                            end  
                            act_bresp=axi_bresp_enum_t'(m_ott_q[index].m_ace_write_resp_pkt.bresp[1:0]);
                            //CONC-16243 temp hack
                            if(m_ott_q[index].multiline_order==0 && m_ott_q[index].m_dtw_rsp_pkt != null) begin
                               cmdstatus_multiline0=m_ott_q[index].m_dtw_rsp_pkt.smi_cmstatus_exok; 
                            end
                            //CONC-16243 temp hack
                            if(m_ott_q[index].multiline_order==1 && m_ott_q[index].m_dtw_rsp_pkt != null) begin
                               cmdstatus_multiline1=m_ott_q[index].m_dtw_rsp_pkt.smi_cmstatus_exok; 
                            end
                            if(cmdstatus_multiline0 ==1 && cmdstatus_multiline1==1) m_axi_final_error_expected= EXOKAY;
                            else m_axi_final_error_expected=OKAY;
                            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> BResp  Expected:%0p Actual:%0p", m_ott_q[index].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_axi_final_error_expected, act_bresp), UVM_HIGH);
                        end
                        //Capturing The first error is acceptable for Ncore 3.0, Ideally DECERR have higher priorit which will be implemented in future version, CONC-6857
                        if (m_ott_q[index].m_axi_resp_expected[0] !== OKAY && first_err_captured == 0) begin //capturing fist dtw_rsp/str_req which is having error
                           t_last_dtw_rsp = m_ott_q[index].t_sfi_dtw_rsp;
                           t_last_str_req = m_ott_q[index].t_sfi_str_req;
                           m_axi_final_error_expected = m_ott_q[index].m_axi_resp_expected[0];
                           first_err_captured = 1;
                        end
                        if (m_ott_q[index].isSMIDTWRespRecd && m_ott_q[index].m_dtw_rsp_pkt.smi_cmstatus_err === 1) begin
                           if (t_last_dtw_rsp > m_ott_q[index].t_sfi_dtw_rsp) begin // capturing the oldest dtw_rsp which is having error in cmstatus
                             t_last_dtw_rsp = m_ott_q[index].t_sfi_dtw_rsp;
                             m_axi_final_error_expected = m_ott_q[index].m_axi_resp_expected[0];
                           end
                        end
                        if (m_ott_q[index].isSMISTRReqRecd && m_ott_q[index].m_str_req_pkt.smi_cmstatus_err === 1) begin
                           if (t_last_str_req > m_ott_q[index].t_sfi_str_req) begin // capturing the oldest str_req which is having error in cmstatus
                             t_last_str_req = m_ott_q[index].t_sfi_str_req;
                             m_axi_final_error_expected = m_ott_q[index].m_axi_resp_expected[0];
                           end
                        end
                        //CONC-16243 temp hack
                        if (m_ott_q[index].isMultiLineMaster <% if (obj.useCache){%> && !(m_ott_q[index].is_ccp_hit && m_ott_q[index].m_ace_write_addr_pkt.awlock == EXCLUSIVE) <%}%>) begin
                            if (m_ott_q[index].m_ace_write_resp_pkt.bresp !== m_axi_final_error_expected && !aiu_double_bit_errors_enabled) begin
                                m_ott_q[index].print_me(0,1);
                                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE write response bresp field sent the wrong bresp message for a multiline write(Expected:%0d Actual:%0d)", m_axi_final_error_expected, m_ott_q[index].m_ace_write_resp_pkt.bresp), UVM_NONE);   
                            end
                        end
                        if (m_ott_q[index].multiline_ready_to_delete) begin
                            m_ott_q_dtr_cmstatus_err.push_back(m_ott_q[index]);
                            delete_ott_entry(index, MultiAceWrResp);
                        end
                        else begin
                            m_ott_q[index].multiline_ready_to_delete = 1;
                        end
                    end //for (int i = 0; i < total_cacheline_count_tmp; i++) begin
                end //isMultiAccess
                else begin //notMultiAccess
                    delete_ott_entry(m_tmp_q[0], AceWrRsp);
                end 
            end //else
    endfunction : write_ncbu_write_resp_chnl

    function void write_ncbu_write_resp_advance_copy_chnl(axi4_write_resp_pkt_t m_pkt);
        ace_write_resp_pkt_t m_packet;
        ace_write_resp_pkt_t m_packet_tmp;
        int                  m_tmp_q[$];
        bit                  m_check_fail;
        if(hasErr)
	        return;
        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("advance copy:%0d ACEWrResp: %s", hasErr, m_pkt.sprint_pkt()), UVM_LOW);
        m_packet_tmp = new();
        m_packet = new();
        $cast(m_packet_tmp, m_pkt);
        m_packet.copy(m_packet_tmp);
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with ((((item.isWrite                   === 1 || item.isUpdate                  === 1) &&
                                              (item.isACEWriteAddressRecd ? (item.m_ace_write_addr_pkt.awid === m_packet.bid ): 0) && 
                                              (item.isACEWriteDataNeeded ? (item.isACEWriteDataRecd == 1): 1) &&
                                              (item.isSMIUPDReqNeeded ? (item.isSMIUPDRespRecd == 1) : 1) &&
                                             item.isACEWriteRespSent         === 0 &&
                                             item.isACEWriteRespSentNoWack   === 0 &&
                                             ((
                                              <%if(obj.useCache) { %> 
                                               (item.csr_ccp_lookupen ? item.isIoCacheTagPipelineSeen : 1) &&
                                              <% } %>
                                               (item.isSMICMDReqNeeded       === 0 ||  
                                                (item.isSMICMDReqSent        === 1 &&
                                                (item.isSMISTRReqRecd        === 1 ||
                                                 item.isSMISTRReqNotNeeded    === 1) &&   
                                                 ((item.isSMIDTWReqNeeded    === 1 &&
                                                   item.isSMIDTWReqSent      === 1 &&
                                                   item.isSMIDTWRespRecd     === 1) ||
                                                   item.isSMIDTWReqNeeded    === 0)))) ||
                                               item.addrNotInMemRegion       === 1  ||
                                               item.mem_regions_overlap      === 1  ||
                                               item.dtrreq_cmstatus_err      === 1  ||
                                               item.hasFatlErr      === 1  ||
                                               item.dtwrsp_cmstatus_err      === 1  ||
                                               item.tagged_decerr      === 1  ||
                                               item.illegalNSAccess      === 1  ||
					       item.illegalCSRAccess     === 1  ||
					      (item.illDIIAccess                  === 1 )) &&
                                              ((item.isMultiAccess) ? item.isMultiLineMaster : 1)) &&
                                              item.isAceCmdReqBlocked        === 0));
       
        <% if((obj.testBench == "fsys") && (obj.testBench != "emu") && (obj.testBench != "emu_t")) { %>
        if($test$plusargs("ioaiu_zero_credit") && m_packet.bresp == 2'b11) begin
            
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("expected decerr received for zero credit uncorr test bresp=%0d",m_packet.bresp), UVM_LOW);
            
            hasErr = 1;
	 		->e_queue_delete;
            kill_uncorr_test.trigger(null);
	 		return;
            
        end 
        else if ($test$plusargs("gpra_secure_uncorr_err") && m_packet.bresp == 2'b11) begin
            //#Stimulus.FSYS.address_dec_error.illegal_non_secure_txn
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("expected decerr received for secure nsx uncorr test bresp=%0d",m_packet.bresp), UVM_LOW);
            hasErr = 1;
	 		->e_queue_delete;
            kill_uncorr_grar_nsx_test.trigger(null);
	 		return;
        end
        <% } %>
        if (m_tmp_q.size === 0) begin            
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_packet.sprint_pkt()), UVM_NONE);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Found no corresponding write address channel transactions for the above ACE write response packet in advance copy"), UVM_NONE);   
        end
        else begin
            if (m_tmp_q.size > 1) begin
                m_tmp_q[0] = find_oldest_entry_in_ott_q(m_tmp_q);
            end
            m_ott_q[m_tmp_q[0]].isACEWriteRespSentNoWack = 1;
        end
        //checker for ACE Memory update command
        if(m_ott_q[m_tmp_q[0]].isUpdate) begin
            if(m_ott_q[m_tmp_q[0]].isSMIUPDReqNeeded && !m_ott_q[m_tmp_q[0]].isSMIUPDRespRecd) begin
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_packet.sprint_pkt()), UVM_NONE);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU sends write resp back to ACE agent before receives UPD Resp for command type %p", m_ott_q[m_tmp_q[0]].m_ace_cmd_type), UVM_NONE);
            end
        end
        // Unblocking blocked ACE Cmd Entry due to AxID match
        unblock_axid_write(m_packet.bid);
        <%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %> 
            // Bandwidth calculation start
            if(!m_ott_q[m_tmp_q[0]].addrNotInMemRegion) begin
                if (m_start_bw_calculations && (m_bw_write_counter == 0)) begin
                    t_write_bw_start_time       = $time;
                    t_write_bw_start_calc_time  = $time;
                end
                m_bw_number_of_write_transactions++;
                if (m_ott_q[m_tmp_q[0]].is_ccp_hit) begin
                    m_bw_number_of_write_hits++;
                end

                if (m_start_bw_calculations) begin
                    m_bw_write_counter += m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlen + 1;
                    if ((m_bw_write_counter - 1000) > m_bw_write_counter_prv_print) begin 
                        real m_write_bw_number       = (((m_bw_write_counter - m_bw_write_counter_prv_print) * WXDATA/8 * 10**9) / (($time - t_write_bw_start_time) / t_timeperiod)); 
                        int m_write_ioc_hit_perc    = m_bw_number_of_write_hits * 100 / m_bw_number_of_write_transactions;
                        `uvm_info("BW Calculations", $sformatf("WRITE: Number of beats = %0d Start time = %0t Current time = %0t total transactions till now %0d IOC Hit %0d(perc) Number of hits %0d Number of writes %0d Time Period %0t BW Number %0E (Bytes/sec)", (m_bw_write_counter - m_bw_write_counter_prv_print), t_write_bw_start_time, $time, m_bw_write_counter, m_write_ioc_hit_perc, m_bw_number_of_write_hits, m_bw_number_of_write_transactions, t_timeperiod, m_write_bw_number), UVM_NONE); 
                        m_bw_write_counter_prv_print = m_bw_write_counter;
                        t_write_bw_start_time = $time;
                        m_bw_number_of_write_transactions = 0;
                        m_bw_number_of_write_hits         = 0;
                    end
                end
            end
        <%}%>
    endfunction : write_ncbu_write_resp_advance_copy_chnl
    //----------------------------------------------------------------------
    // OTTVect Probe Port
    // CONC-9778 CONC-9721
    //----------------------------------------------------------------------

    function print_ott(ioaiu_probe_txn m_txn,int i); 
       foreach(m_ott_q[k]) begin
            if(m_ott_q[k].m_sfi_addr== m_txn.ott_address[i] && m_ott_q[k].isRead)
            begin
           `uvm_info("OTT_DEBUG_INFO ::SCB", $psprintf(" #%0h, m_sfi_addr: %0h | ott_address: %0h   m_id: %0d | ott_id: %0d   m_security: %0d | ott_security: %0d   m_user:%0d | ott_user: %0d,<%if(obj.AiuInfo[obj.Id].fnEnableQos) { %> m_qos:%0d | ott_qos : %0d<% } %> isRead: %0d  ott_write: %0d ott_evict %0d  m_ott_status: %0s", i, m_ott_q[k].m_sfi_addr, m_txn.ott_address[i], m_ott_q[k].m_id, m_txn.ott_id[i], m_ott_q[k].m_security, m_txn.ott_security[i], m_ott_q[k].m_user, m_txn.ott_user[i],<%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>m_ott_q[k].m_axi_qos,m_txn.ott_qos[i],<% } %>m_ott_q[k].isRead, m_txn.ott_write[i],m_txn.ott_evict[i], m_ott_q[k].m_ott_status), UVM_LOW);
           end

           if(m_ott_q[k].m_sfi_addr== m_txn.ott_address[i] && m_ott_q[k].isWrite)
           begin
           `uvm_info("OTT_DEBUG_INFO ::SCB", $psprintf(" #%0h, m_sfi_addr: %0h | ott_address: %0h   m_id: %0d | ott_id: %0d   m_security: %0d | ott_security: %0d   m_user:%0d | ott_user: %0d,<%if(obj.AiuInfo[obj.Id].fnEnableQos) { %> m_qos:%0d | ott_qos : %0d<% } %> isWrite: %0d ott_write: %0d ott_evict %0d m_ott_status: %0s", i, m_ott_q[k].m_sfi_addr, m_txn.ott_address[i], m_ott_q[k].m_id, m_txn.ott_id[i], m_ott_q[k].m_security, m_txn.ott_security[i], m_ott_q[k].m_user, m_txn.ott_user[i],<%if(obj.AiuInfo[obj.Id].fnEnableQos) { %>m_ott_q[k].m_axi_qos,m_txn.ott_qos[i],<% } %>m_ott_q[k].isWrite, m_txn.ott_write[i],m_txn.ott_evict[i], m_ott_q[k].m_ott_status), UVM_LOW);
           end

           if(m_ott_q[k].m_sfi_addr== m_txn.ott_address[i] && m_ott_q[k].isIoCacheEvict)
           begin
           `uvm_info("OTT_DEBUG_INFO ::SCB", $psprintf(" #%0h,isIoCacheEvict %0d  ott_write: %0d ott_evict %0d m_ott_status: %0s ",i, m_ott_q[k].isIoCacheEvict,m_txn.ott_write[i],m_txn.ott_evict[i], m_ott_q[k].m_ott_status), UVM_LOW);
           end
        end
    endfunction
    
    function void write_owo_chnl(ioaiu_probe_txn m_txn); 
        int snp_ott_idx, coh_wr_ott_idx;
        int ott_idxq[$], snp_ott_idxq[$], coh_wr_ott_idxq[$];
        bit snp_coh_wr_match = 0;
	bit snp_release = 1;
	bit final_snp_release = 1;

        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("fn:write_owo_chnl nOtt:<%=obj.nOttCtrlEntries%> snp_req_match_vec:'b%0b (0x%0h) ott_owned_st:'b%0b(0x%0h) ott_oldest_st:'b%0b(0x%0h)", m_txn.snp_req_match,m_txn.snp_req_match,  m_txn.ott_owned_st,m_txn.ott_owned_st,  m_txn.ott_oldest_st,m_txn.ott_oldest_st), UVM_LOW);

        //Check oldest
        //Check owned
        if(hasErr)
	    return; 
        if (m_txn.ott_owned_st != ott_owned_st) begin
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("fn:write_owo_chnl curr_ott_owned_st:'b%0b(0x%0h) from prev_ott_owned_st:'b%0b(0x%0h)", m_txn.ott_owned_st, m_txn.ott_owned_st,ott_owned_st, ott_owned_st), UVM_LOW);
            foreach (m_txn.ott_owned_st[i]) begin 
                if (!ott_owned_st[i] && m_txn.ott_owned_st[i]) begin
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("fn:write_owo_chnl ott_owned_st for OTT_ID:%0d makes a 0 -> 1 transition ", i), UVM_LOW);
                    ott_idxq = m_ott_q.find_index with (item.m_ott_status == ALLOCATED && item.m_ott_id == i);
                    if (ott_idxq.size() == 1) begin 
                        if (m_ott_q[ott_idxq[0]].isWrite && m_ott_q[ott_idxq[0]].isCoherent) begin 
                            if (m_ott_q[ott_idxq[0]].isSMISTRReqRecd ) begin 
                                if (m_txn.ott_oldest_st[i] == 1) begin
                                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("fn:write_owo_chnl UID:%0d owo_wr_state INV -> UCE -> UDP", m_ott_q[ott_idxq[0]].tb_txnid), UVM_LOW);
                                    m_ott_q[ott_idxq[0]].m_owo_wr_state = UDP;
                                    owo_set_expect_for_wb(ott_idxq[0]);
                                end else begin 
                                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("fn:write_owo_chnl UID:%0d owo_wr_state INV -> UCE", m_ott_q[ott_idxq[0]].tb_txnid), UVM_LOW);
                                    m_ott_q[ott_idxq[0]].m_owo_wr_state = UCE;
                                end
                            end 
                            else begin
                                 if (!(m_ott_q[ott_idxq[0]].illegalNSAccess  || m_ott_q[ott_idxq[0]].illegalCSRAccess ||  m_ott_q[ott_idxq[0]].illDIIAccess || m_ott_q[ott_idxq[0]].addrNotInMemRegion || m_ott_q[ott_idxq[0]].mem_regions_overlap || m_ott_q[ott_idxq[0]].hasFatlErr)) begin
                                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("UID:%0d fn:write_owo_chnl RTL asserts owned_st for OTT_ID:%0d incorrectly when STRReq is not yet received", m_ott_q[ott_idxq[0]].tb_txnid, m_ott_q[ott_idxq[0]].m_ott_id));
                                 end
                            end
                        end
                    end else begin 
                        if (!(m_ott_q[ott_idxq[0]].illegalNSAccess  || m_ott_q[ott_idxq[0]].illegalCSRAccess ||  m_ott_q[ott_idxq[0]].illDIIAccess || m_ott_q[ott_idxq[0]].addrNotInMemRegion || m_ott_q[ott_idxq[0]].mem_regions_overlap)) begin
                        `uvm_error("<%=obj.strrtlnameprefix%> SCB", $psprintf("fn:write_owo_chnl Cannot find a match in ott for OTT:%0d", i));
                        end
                    end
                end
            end
        end
        
        if (m_txn.ott_oldest_st != ott_oldest_st) begin
            `uvm_info("<%=obj.strrtlnameprefix%> SCB", $psprintf("fn:write_owo_chnl curr_ott_oldest_st:'b%0b(0x%0h) from prev_ott_oldest_st:'b%0b(0x%0h)", m_txn.ott_oldest_st, m_txn.ott_oldest_st,ott_oldest_st, ott_oldest_st), UVM_LOW);
            foreach (m_txn.ott_oldest_st[i]) begin 
                if (!ott_oldest_st[i] && m_txn.ott_oldest_st[i]) begin
                    `uvm_info("<%=obj.strrtlnameprefix%> SCB", $psprintf("fn:write_owo_chnl ott_oldest_st for OTT_ID:%0d makes a 0 -> 1 transition ", i), UVM_LOW);
                    ott_idxq = m_ott_q.find_index with (item.m_ott_status == ALLOCATED && item.m_ott_id == i);
                    if (ott_idxq.size() == 1) begin 
                        if (m_ott_q[ott_idxq[0]].isWrite && m_ott_q[ott_idxq[0]].isCoherent && m_ott_q[ott_idxq[0]].m_owo_wr_state == UCE ) begin 
                            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("fn:write_owo_chnl UID:%0d (OTT_ID:%0d) owo_wr_state UCE -> UDP", m_ott_q[ott_idxq[0]].tb_txnid, i), UVM_LOW);
                            m_ott_q[ott_idxq[0]].m_owo_wr_state = UDP;
                            owo_set_expect_for_wb(ott_idxq[0]);
                        end
                    end else begin 
                        if (!(m_ott_q[ott_idxq[0]].illegalNSAccess  || m_ott_q[ott_idxq[0]].illegalCSRAccess ||  m_ott_q[ott_idxq[0]].illDIIAccess || m_ott_q[ott_idxq[0]].addrNotInMemRegion || m_ott_q[ott_idxq[0]].mem_regions_overlap || m_ott_q[ott_idxq[0]].hasFatlErr)) begin
                        `uvm_error("<%=obj.strrtlnameprefix%> SCB", $psprintf("fn:write_owo_chnl Cannot find a match in ott for OTT:%0d", i));
                        end
                    end
                end
            end
        end


        
        ott_owned_st  = m_txn.ott_owned_st;
        ott_oldest_st = m_txn.ott_oldest_st;
        
        if (m_txn.snp_req_vld == 0) begin 
            return;
        end 
        
	foreach (m_txn.snp_req_match[i]) begin 
            if(m_txn.snp_req_match[i] == 1) begin 
                coh_wr_ott_idxq = m_ott_q.find_index with (item.isWrite && 
                                                          item.isCoherent &&
                                                          item.m_ott_status == ALLOCATED &&
                                                          item.m_ott_id == i);
               
                if(coh_wr_ott_idxq.size() > 1) begin 
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("fn:write_owo_chnl SMI SNPreq is not expected to cacheline match multiple (total:%0d - ott_idx:%0p) coh wr in OTT", coh_wr_ott_idxq.size(), coh_wr_ott_idxq));
                end else if (coh_wr_ott_idxq.size() == 1) begin 
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("fn:write_owo_chnl snp_req_match seen for UID:%0d (OTT_ID:%0d)", m_ott_q[coh_wr_ott_idxq[0]].tb_txnid, i), UVM_LOW);
                    coh_wr_ott_idx = coh_wr_ott_idxq[0];
                    
                    snp_ott_idxq = m_ott_q.find_last_index with (item.isSnoop == 1 &&
                                                                !item.isSMISNPRespSent &&
                                                                 item.m_snp_req_pkt.smi_ns == m_ott_q[coh_wr_ott_idx].m_ace_write_addr_pkt.awprot[1] &&
                                      item.m_snp_req_pkt.smi_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_ott_q[coh_wr_ott_idx].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]);
                    
                    if (snp_ott_idxq.size() != 1) begin 
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("fn:write_owo_chnl RTL snp_req_match pointing to OTT_ID:%0d might be incorrect since there is no cacheline match SMI SNPreq found", i));
                    end else begin 
                        snp_ott_idx = snp_ott_idxq[0];
                    end
                    snp_coh_wr_match = 1;
                    owo_update_on_snp_req(snp_ott_idx, coh_wr_ott_idx, snp_release);
		    final_snp_release = final_snp_release & snp_release;
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("fn:write_owo_chnl UID:%0d says snp_release:%0b final_snp_release:%0d", m_ott_q[coh_wr_ott_idx].tb_txnid, snp_release, final_snp_release), UVM_LOW);
                end else begin 
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("fn:write_owo_chnl snp_req_match seen for OTT_ID:%0d but ignore since it is not a Coherent Write", i), UVM_LOW);
                end
            end
        end
        
        if (snp_coh_wr_match == 0 || final_snp_release == 1) begin 
            snp_ott_idxq = m_ott_q.find_last_index with (item.isSnoop && 
							!item.isSMISNPRespSent && 
							(item.m_sfi_addr == m_txn.snp_req_addr[WSMIADDR-1:0]) && 
							(item.m_security == m_txn.snp_req_addr[WSMIADDR])); 
            if (snp_ott_idxq.size() == 0) begin
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("fn:write_owo_chnl SMI SNPreq should be there else we should not be seeing a snp_req_vld"));
            end else begin
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG", $psprintf("fn:write_owo_chnl UID:%0d SMISNPRespNeeded is set since snp_coh_wr_match:%0d final_snp_release:%0d", m_ott_q[snp_ott_idxq[0]].tb_txnid, snp_coh_wr_match, final_snp_release), UVM_LOW);
                m_ott_q[snp_ott_idxq[0]].isSMISNPRespNeeded = 1;
            end
        end
    endfunction: write_owo_chnl

       function void write_ottvec_probe_chnl(ioaiu_probe_txn m_txn); 
    int maxRead, maxWrite;
    int nOtt = (<%=obj.nOttCtrlEntries%>/<%=obj.nNativeInterfacePorts%>);
    int ott_alloc_q[$],ott_dealloc_q[$],ott_dealloc_cmpl_q[$];
    bit [<%=obj.nOttCtrlEntries%> - 1:0] ott_w_read;
    bit [<%=obj.nOttCtrlEntries%> - 1:0] ott_w_write;
    bit [<%=obj.nOttCtrlEntries%> - 1:0] ott_w_evict;

    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("fn:write_ottvec_probe_chnl nOtt:%0d ott entries:'b%0b, previous ott entries:'b%0b", nOtt, m_txn.ottvld_vec,ottvld_vec_prev), UVM_LOW);
    
    foreach(m_txn.ottvld_vec[i]) begin
        ott_w_read[i]  = m_txn.ottvld_vec[i] &  ~m_txn.ott_write[i] & ~m_txn.ott_evict[i];
        ott_w_write[i] = m_txn.ottvld_vec[i] &   m_txn.ott_write[i] & ~m_txn.ott_evict[i];
        ott_w_evict[i] = m_txn.ottvld_vec[i] &   m_txn.ott_evict[i];
    end

    //`uvm_info("<%=obj.strrtlnameprefix%> SCB", $psprintf("fn:write_ottvec_probe_chnl ott_w_read:'b%0b, ott_w_write:'b%0b ott_w_evict:'b%0b", ott_w_read, ott_w_write, ott_w_evict), UVM_LOW);

    case (OttWrPool)  
        'b00 : maxRead = nOtt - 3;
        'b01 : maxRead = nOtt - $ceil(nOtt/6.0);
        'b10 : maxRead = nOtt - $ceil(nOtt/3.0);
        'b11 : maxRead = nOtt - $ceil(nOtt/2.0);
    endcase
    
    case (OttRdPool) 
        'b00 : maxWrite = nOtt - 1;
        'b01 : maxWrite = nOtt - $ceil(nOtt/6.0);
        'b10 : maxWrite = nOtt - $ceil(nOtt/3.0);
        'b11 : maxWrite = nOtt - $ceil(nOtt/2.0);
    endcase
    
    //`uvm_info("<%=obj.strrtlnameprefix%> scb", $psprintf("fn:write_ottvec_probe_chnl OttWrPool:'b%0b OttRdPool:'b%0b maxRead:%0d maxWrite:%0d", OttWrPool, OttRdPool, maxRead, maxWrite), UVM_LOW);
    
    if ($countones(ott_w_read) > maxRead) begin 
        `uvm_error("<%=obj.strrtlnameprefix%> scb", $psprintf("fn:write_ottvec_probe_chnl numOtt_w_Reads:%0d is greater than the maximum allowed maxRead:%0d OttWrPool:'b%0b", $countones(ott_w_read), maxRead, OttWrPool));
    end else begin 
        //`uvm_info("<%=obj.strrtlnameprefix%> scb", $psprintf("fn:write_ottvec_probe_chnl maxRead:%0d numOtt_w_Reads:%0d", maxRead, $countones(ott_w_read)), UVM_LOW);
    end

    if ($countones(ott_w_write) > maxWrite) begin 
        `uvm_error("<%=obj.strrtlnameprefix%> scb", $psprintf("fn:write_ottvec_probe_chnl numOtt_w_Writes:%0d is greater than the maximum allowed maxWrite:%0d OttRdPool:'b%0b", $countones(ott_w_write), maxWrite, OttRdPool));
    end else begin 
        //`uvm_info("<%=obj.strrtlnameprefix%> scb", $psprintf("fn:write_ottvec_probe_chnl maxWrite:%0d numOtt_w_Write:%0d", maxWrite, $countones(ott_w_write)), UVM_LOW);
    end

       foreach(m_txn.ottvld_vec[i]) begin

	if(m_txn.ottvld_vec[i] == 0 && ottvld_vec_prev[i] == 1) begin  // OTT entry is de-allocated 
           ott_dealloc_q = m_ott_q.find_index with ( item.m_ott_id == i && 
                                              <%if(obj.wSecurityAttribute > 0){%>                                             
            			              (item.m_security == m_txn.ott_security[i]) && <% } %>
            				      item.m_ott_status == ALLOCATED  
                                                );

           
           if(ott_dealloc_q.size()==1) begin
               m_ott_q[ott_dealloc_q[0]].m_ott_status  = DEALLOCATED;
               m_ott_q[ott_dealloc_q[0]].t_ott_dealloc = $realtime; 
               m_ott_q[ott_dealloc_q[0]].m_ott_id      = i;
              //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("#%0h DEALLOC :: OTT trans allocated for %0d, address is %0p ott_id %0d status %0p time %0d",i, m_ott_q[ott_dealloc_q[0]].m_ott_id, m_txn.ott_address[i],m_txn.ott_id[i],m_ott_q[ott_dealloc_q[0]].m_ott_status,m_ott_q[ott_dealloc_q[0]].t_ott_dealloc), UVM_LOW);
           end else if(ott_dealloc_q.size()==0)begin 
               ott_dealloc_cmpl_q=m_ott_q_cmpl.find_index with (item.m_ott_id == i&& item.m_ott_status == ALLOCATED );
               if(ott_dealloc_cmpl_q.size()==1) begin
                 // `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("#%0h DEALLOC :: OTT trans deallocated from ott_cmpl queue id for %0d, address is %0p at time %0d",i, m_ott_q_cmpl[ott_dealloc_cmpl_q[0]].m_ott_id, m_txn.ott_address[i], m_ott_q_cmpl[ott_dealloc_cmpl_q[0]].t_ott_dealloc), UVM_LOW);
                  m_ott_q_cmpl.delete(ott_dealloc_cmpl_q[0]);
               end else begin
                print_ott(m_txn,i);
                //we can't add check- eviction from clean state is silent eviction ,m_ott_q evict txn is deleted at the same cycle when its created. But rtl creating ott_entry and deallocating after some cycles.Iin this scenario we won't find match  
                // `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("#%0h Found 0 matches of ott dealloc entries : %0h ott_id :%0h",i,m_txn.ott_address[i],i))
                 end
           end
        end


        if(m_txn.ottvld_vec[i] == 1 && ottvld_vec_prev[i] == 0) begin  // OTT entry is allocated
           ott_alloc_q = m_ott_q.find_first_index with ((((item.isRead===1)?item.isACEReadAddressRecd===1 : item.isACEWriteAddressRecd===1) &&
                                              item.m_sfi_addr == m_txn.ott_address[i] && 
            				      item.m_id == m_txn.ott_id[i] && 
                                              <%if(obj.wSecurityAttribute > 0){%>                                             
            			              (item.m_security == m_txn.ott_security[i]) && 
                                              ((item.isRead && !m_txn.ott_write[i] && !m_txn.ott_evict[i])?(item.m_ace_read_addr_pkt.arprot[0] === m_txn.ott_prot[i]) :(((item.isWrite || item.isUpdate ) && m_txn.ott_write[i] && !m_txn.ott_evict[i]) ? (item.m_ace_write_addr_pkt.awprot[0] === m_txn.ott_prot[i]) : 0)) && <% } %>
                                              <%if(aiu_axiInt.params.wArUser>0 || aiu_axiInt.params.wAwUser>0){%> (item.m_user == m_txn.ott_user[i]) && <%}%> 
                                              <%if(obj.AiuInfo[obj.Id].fnEnableQos) { %> (item.m_axi_qos == m_txn.ott_qos[i]) && <% } %>
                                              item.m_axcache == m_txn.ott_cache[i] &&
            				      item.m_ott_status == INACTIVE)||
                                              ((item.isIoCacheEvict )? (   
                                              <%if(obj.wSecurityAttribute > 0){%>                                             
            			              (item.m_security == m_txn.ott_security[i]) && <% } %> 
                                              <%if(obj.AiuInfo[obj.Id].fnEnableQos) { %> ((csr_use_eviction_qos ? csr_eviction_qos : item.m_axi_qos) == m_txn.ott_qos[i]) && <% } %>
                                               item.m_sfi_addr == m_txn.ott_address[i] &&  item.m_ott_status == INACTIVE && !m_txn.ott_write[i] && m_txn.ott_evict[i]) :0)                                  );

            foreach(m_ott_q[ii]) begin 
          if(m_ott_q[ott_alloc_q[0]].m_sfi_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_ott_q[ii].m_sfi_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)]  <%if(obj.wSecurityAttribute > 0){%>&& m_ott_q[ott_alloc_q[0]].m_security == m_ott_q[ii].m_security<%}%> &&  m_ott_q[ii].m_ott_status == ALLOCATED)begin
	  sb_stall_if.perf_count_events["Address_Collisions"].push_back(1);
          break;
          end
          end

 
				     
           if(ott_alloc_q.size()==1) begin
              m_ott_q[ott_alloc_q[0]].m_ott_status = ALLOCATED;
              m_ott_q[ott_alloc_q[0]].t_ott_alloc  = $realtime; 
              m_ott_q[ott_alloc_q[0]].ott_alloc_cc  = cycle_counter; 
              m_ott_q[ott_alloc_q[0]].m_ott_id     = i;
              `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("UID:%0d OTT_ID:%0d allocated for address:%0p ott_status %0p time %0d",m_ott_q[ott_alloc_q[0]].tb_txnid, i, m_txn.ott_address[i], m_ott_q[ott_alloc_q[0]].m_ott_status, m_ott_q[ott_alloc_q[0]].t_ott_alloc), UVM_LOW);
              //if ((<%=obj.nOttCtrlEntries%> >= 64) && ((m_ott_q[ott_alloc_q[0]].ott_alloc_cc - m_ott_q[ott_alloc_q[0]].natv_intf_cc) > 1000)) begin 
if ((m_ott_q[ott_alloc_q[0]].isWrite && $test$plusargs("seq_single_write_multi_read")) || (m_ott_q[ott_alloc_q[0]].isRead && $test$plusargs("seq_single_read_multi_write"))) begin
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("UID:%0d OTT_ID:%0d allocated for address:0x%0h ott_status %0p time %0d, natv_intf_cc:%0d, ott_alloc_cc:%0d, cycles_to_allocate_ott:%0d",m_ott_q[ott_alloc_q[0]].tb_txnid, i, m_txn.ott_address[i], m_ott_q[ott_alloc_q[0]].m_ott_status, m_ott_q[ott_alloc_q[0]].t_ott_alloc, m_ott_q[ott_alloc_q[0]].natv_intf_cc, m_ott_q[ott_alloc_q[0]].ott_alloc_cc, (m_ott_q[ott_alloc_q[0]].ott_alloc_cc - m_ott_q[ott_alloc_q[0]].natv_intf_cc)), UVM_NONE);
                if ((m_ott_q[ott_alloc_q[0]].ott_alloc_cc - m_ott_q[ott_alloc_q[0]].natv_intf_cc) > 200) begin 
	                `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> takes %0d cycles(more than 200) to allocate an OTT_ID:%0d natv_intf_cc:%0d ott_alloc_cc:%0d",m_ott_q[ott_alloc_q[0]].tb_txnid <%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, (m_ott_q[ott_alloc_q[0]].ott_alloc_cc - m_ott_q[ott_alloc_q[0]].natv_intf_cc), i, m_ott_q[ott_alloc_q[0]].natv_intf_cc, m_ott_q[ott_alloc_q[0]].ott_alloc_cc))
                end        
              end             
           end else if(ott_alloc_q.size()==0) begin
                print_ott(m_txn,i);
                //we can't add check- eviction from clean state is silent eviction ,m_ott_q evict txn is deleted at the same cycle when its created. But rtl creating ott_entry and deallocating after some cycles.Iin this scenario we won't find match  
              //`uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("#%0h Found %0d matches of ott alloc entries : %0h ott_id :%0h time %0d",i,ott_alloc_q.size(),m_txn.ott_address[i],m_txn.ott_id[i],m_ott_q[ott_alloc_q[0]].t_ott_alloc))  
           end   
        end
        
    end
        ottvld_vec_prev=m_txn.ottvld_vec;
    
    endfunction : write_ottvec_probe_chnl

    function void write_bypass_probe_chnl(ioaiu_probe_txn txn_tracker);
     <%if(obj.useCache  && obj.testBench =="io_aiu"){%>
      bypass_bank_q.push_back(<%for( var i=0;i<obj.nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%> txn_tracker.bypass_bank<%=i%> | <%}%>0);

      if(check_bypass_flag==1) begin
        bypass_cycle_counter = txn_tracker.cycle_counter; 
        check_bypass_flag=0;
       //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("bypass_bank_q %0p",bypass_bank_q), UVM_LOW)
      end
      
      if((bypass_cycle_counter == txn_tracker.cycle_counter -1) && bypass_bank_q[0] &&  bypass_cycle_counter !=0)
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("txn_tracker.bypass_bank0=%0d,txn_tracker.bypass_bank1=%0d",txn_tracker.bypass_bank0,txn_tracker.bypass_bank1)) 
      if(bypass_bank_q.size() == 2) begin
      bypass_bank_q.pop_front();
      end
    <%}%>
    endfunction: write_bypass_probe_chnl

    function void write_cycle_tracker_probe_chnl(cycle_tracker_s cycle_tracker);

        //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("CYCLE_TRACKER: time:%0t cycle_count:%0d", cycle_tracker.m_time, cycle_tracker.m_cycle_count), UVM_LOW)
        cycle_counter = cycle_tracker.m_cycle_count;
    endfunction: write_cycle_tracker_probe_chnl
    //----------------------------------------------------------------------


    // RTL Probe Port
    //
    //----------------------------------------------------------------------
    function void write_rtl_probe_chnl(ioaiu_probe_txn m_txn);
        int isAlloc=0;
        int isDeAlloc=0;

        // check for all OTT entries if any valid bit went from 0 to 1 which corresponds to OTT allocation
        foreach(m_txn.ott_entries[i]) begin
            ott_pkt_t ott_entry;
            if(m_txn.ott_entries[i] == 1 && prev_ott_entries_valid[i] == 0) begin  // OTT entry is allocated
                isAlloc++;
                ott_entry.id = i;
                ott_entry.alloc_time = $realtime;
                ott_entry.address = m_txn.ott_address[i];
                ott_entry.security = m_txn.ott_security[i];
                ott_entry.ott_id = m_txn.ott_id[i];
                ott_id_q[i] = ott_entry;
            end else if(m_txn.ott_entries[i] == 0 && prev_ott_entries_valid[i] == 1) begin // OTT entry is de-allocated
                isDeAlloc++;
                ott_id_q.delete(i);
            end
        end
        //#Check.IOAIU.NoStarvation_ThresholdZero
        starvation_mode = m_txn.starvation;
        starv_counter = m_txn.starv_counter;

        // if global counter reaches threshold, mark OTT entries as either overflow or starved
        if(m_txn.gc_threshold_reached) begin
            foreach(ott_id_q[i]) begin
                if(ott_id_q[i].overflow) begin
                    ott_id_q[i].starving = 1;
                end else begin
                    ott_id_q[i].overflow = 1;
                end
                // if cmd req is already sent, the entry does not participate in starvation
                if(ott_id_q[i].cmd_req_sent) begin
                    ott_id_q[i].overflow = 0;
                    ott_id_q[i].starving = 0;
                end
            end
        end

        if(isDeAlloc > 0 || isAlloc > 0) begin
            real_ott_size = real_ott_size + (isAlloc - isDeAlloc);
            sb_stall_if.perf_count_events["Active_OTT_entries"].push_back(real_ott_size);
        end

        isAlloc = 0;
        isDeAlloc = 0;
        prev_ott_entries_valid = m_txn.ott_entries;
    endfunction

    //--------------------------------------------------------------
    //SMI Every Beat Port
    //CONC-11435 We need to get 1st beat of DTRreq as soon as it arrives if it has an address-error since it is used by RTL immediately to predict allocation of the rest of parts of multiline in case of Partial Writes.
    //--------------------------------------------------------------

    function void write_ioaiu_smi_every_beat_port(smi_seq_item m_pkt);
       int		m_tmp_qA[$];
       int              m_tmp_qE[$];
       
       if(!m_pkt.smi_cmstatus_err_payload inside{7'b000_0011, 7'b000_0100})
       return;

       m_tmp_qA = m_ott_q.find_index with (item.matchDtrToTxn(m_pkt));
       m_tmp_qE = {};
       if(m_tmp_qA.size() == 1) begin
       if(m_ott_q[m_tmp_qA[0]].isWrite)begin
       int multiline_tracking_id_tmp = m_ott_q[m_tmp_qA[0]].m_multiline_tracking_id;
       int total_cacheline_count_tmp = m_ott_q[m_tmp_qA[0]].total_cacheline_count;
       m_tmp_qE = {};
       m_tmp_qE = m_ott_q.find_index with (item.isMultiAccess           === 1 &&
                                           item.m_multiline_tracking_id === multiline_tracking_id_tmp);
       if(m_pkt.smi_cmstatus_err_payload inside{7'b000_0011, 7'b000_0100}) begin
	   for (int i = 0; i < m_tmp_qE.size(); i++) begin 
           m_ott_q[m_tmp_qE[i]].dtrreq_cmstatus_err_expcted = 1;
           end
       end
       end
       end

    endfunction :write_ioaiu_smi_every_beat_port

    //----------------------------------------------------------------------- 
    // SMI Port
    // This Function handles both request and response on all SMI ports
    //----------------------------------------------------------------------- 
	function void write_ioaiu_smi_port(smi_seq_item m_pkt);
        string cmd_type;
    	smi_seq_item this_packet;
      	int m_tmp_qA[$];
      	this_packet = smi_seq_item::type_id::create();
      	this_packet.copy(m_pkt);

        <% if(obj.COVER_ON) { %>
            `ifndef FSYS_COVER_ON
            cov.collect_ioaiu_smi_port(m_pkt);
            `endif
        <% } %>  

    	if(hasErr)
			return;

		if	(((this_packet.smi_src_id >> <%=obj.wFPortId%>) !== <%=(obj.FUnitId)%>) &&
	 		((this_packet.smi_targ_id >> <%=obj.wFPortId%>) !== <%=(obj.FUnitId)%>)) begin
			`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Received below SMI packet at IOAIU SCB: %0s", m_pkt.convert2string()), UVM_LOW)
	 		//uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Deleting queues because of wrong targ_id"), UVM_LOW);
	 		hasErr = 1;
	 		->e_queue_delete;
	 		return;
		end else begin 
			//TODO 4-11-22:retire this line eventually, once this line is printed in all process_*_req functions
			if (!this_packet.isCmdMsg() &&
				!this_packet.isCCmdRspMsg() &&
				!this_packet.isStrMsg() &&
				!this_packet.isStrRspMsg() &&
				!(this_packet.isDtrMsg() && (this_packet.smi_src_ncore_unit_id != <%=obj.FUnitId%>)) &&
				!this_packet.isDtrRspMsg() &&
				!this_packet.isSnpMsg() &&
				!this_packet.isSnpRspMsg() &&
                                !this_packet.isSysReqMsg() &&
                                !this_packet.isSysRspMsg)
				`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Received below SMI packet at IOAIU SCB: %0s", m_pkt.convert2string()), UVM_LOW)
		end

      	// get error statistics
      	if(m_pkt.ndp_corr_error || m_pkt.hdr_corr_error || m_pkt.dp_corr_error) begin
        	update_resiliency_ce_cnt(m_pkt);
      	end
      	num_smi_corr_err      += m_pkt.ndp_corr_error + m_pkt.hdr_corr_error + m_pkt.dp_corr_error;
      	num_smi_uncorr_err    += m_pkt.ndp_uncorr_error + m_pkt.hdr_uncorr_error + m_pkt.dp_uncorr_error;
      	num_smi_parity_err    += m_pkt.ndp_parity_error + m_pkt.hdr_uncorr_error + m_pkt.dp_parity_error;

       	m_tmp_qA = {};


       	if(this_packet.isDtwMsg()) begin
	    	process_dtw_req(this_packet);
            cmd_type = "DTW_MSG";
       	end
       	else if(this_packet.isDtrMsg()) begin
	   		if((this_packet.smi_src_id >> <%=obj.wFPortId%>) === <%=(obj.FUnitId)%>) begin
	     		process_snp_dtr_req(this_packet);
                cmd_type = "SNP_DTR_REQ";
            end
	   		else begin
	     		process_dtr_req(this_packet);	 
                cmd_type = "DTR_REQ";
            end
       	end
       	else if(this_packet.isCmdMsg()) begin
	    	process_cmd_req(this_packet);
            cmd_type = "CMD_REQ";
       	end
       	else if(this_packet.isUpdMsg()) begin
	    	process_upd_req(this_packet);	 
            cmd_type = "UPD_REQ";
       	end
       	else if(this_packet.isSnpMsg()) begin
	    	process_snp_req(this_packet);
            cmd_type = "SNP_REQ";
      	end
       	else if(this_packet.isStrMsg()) begin
	    	process_str_req(this_packet);
            cmd_type = "STR_REQ";
       	end
       	else if(this_packet.isCCmdRspMsg()) begin
	    	process_ccmd_rsp(this_packet);
            cmd_type = "CMD_RSP";
       	end
       	else if(this_packet.isNcCmdRspMsg()) begin
	   		process_nccmd_rsp(this_packet);
            cmd_type = "NC_CMD_RSP";
       	end
       	else if(this_packet.isDtrRspMsg()) begin
	  		process_dtr_rsp(this_packet);
            cmd_type = "DTR_RSP";
       	end
       	else if(this_packet.isDtwRspMsg()) begin
	    	process_dtw_rsp(this_packet);
            cmd_type = "DTW_RSP";
       	end
       	else if(this_packet.isCmpRspMsg()) begin
	    	process_cmp_rsp(this_packet);
            cmd_type = "CMPL_RSP";
       	end
       	else if(this_packet.isUpdRspMsg()) begin
	    	process_upd_rsp(this_packet);
            cmd_type = "UPD_RSP";
       	end
       	else if(this_packet.isSnpRspMsg()) begin
	    	process_snp_rsp(this_packet);
            //#Check.IOAIU.Snoop
            cmd_type = "SNP_RSP";
       	end
       	else if(this_packet.isStrRspMsg()) begin
			process_str_rsp(this_packet);
            cmd_type = "STR_RSP";
		end
		else if (this_packet.isSysReqMsg()) begin 
            process_sys_req(this_packet);
            cmd_type = "SYS_REQ";
	    end 
		else if (this_packet.isSysRspMsg()) begin
	       `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("[SMI-TRACE] [cmd: %15s (0x%02h)] [src: 0x%04h] [tgt: 0x%04h] [msgId: 0x%08h] [addr: 0x%16h] {sysreqop: %1d}", "SYS_RSP (pre)", m_pkt.smi_msg_type, m_pkt.smi_src_id, m_pkt.smi_targ_id, m_pkt.smi_msg_id, m_pkt.smi_addr, m_pkt.smi_sysreq_op), UVM_DEBUG);
	    	process_sys_rsp(this_packet);
            cmd_type = "SYS_RSP";
        end else if (this_packet.isDtwDbgReqMsg()) begin
          //TODO add check for DtwDbgReqMsg
        end else if (this_packet.isDtwDbgRspMsg()) begin
          //TODO add check for DtwDbgRspMsg
		end else begin
                    if (!$test$plusargs("inject_smi_uncorr_error"))
			uvm_report_error(`LABEL_ERROR, $sformatf("Unexpected SMI packet observed \n %0s", this_packet.convert2string()), UVM_NONE);				  
		end
	   `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("[SMI-TRACE] [cmd: %15s (0x%02h)] [src: 0x%04h] [tgt: 0x%04h] [msgId: 0x%08h] [addr: 0x%16h] {sysreqop: %1d}", cmd_type, m_pkt.smi_msg_type, m_pkt.smi_src_id, m_pkt.smi_targ_id, m_pkt.smi_msg_id, m_pkt.smi_addr, m_pkt.smi_sysreq_op), UVM_DEBUG);
   endfunction : write_ioaiu_smi_port
	
    //----------------------------------------------------------------------- 
    //
    // Functions that check protocol correctness
    //
    //----------------------------------------------------------------------- 

    //----------------------------------------------------------------------- 
    // Checking ACE snoop response based on the rules below
    // RO ReadOnce
    // RC ReadClean
    // RN ReadNotSharedDirty
    // RS ReadShared
    // RU ReadUnique
    // CI CleanInvalid
    // MI MakeInvalid
    // CS CleanShared.
    // E Expected response
    // P Permitted response
    // No Response not permitted.
    //Table C3-23 Response meanings and transactions for which they are valid
    //CRRESP[3:2,0] [4] Snoop transaction
    //   IS PD DT WU RO RC RN RS RU CI MI CS Response meaning
    //   0  0  0  0  E  E  E  E  E  E  E  E  Line was invalid or has been invalidated.
    //   0  0  0  1  P  P  P  P  P  E  E  E  Line was unique but has been invalidated.
    //   0  0  1  x  P  P  P  P  E  P  P  P  Passing clean data before invalidating.
    //   x  1  0  x  No No No No No No No No Cannot assert PassDirty with DataTransfer low.
    //   0  1  1  x  P  E  E  P  E  E  P  P  Passing dirty data before invalidating.
    //   1  0  0  x  P  P  P  P  No No No E  Line is valid and clean but not being passed.
    //   1  0  1  x  E  E  E  E  No No No P  Passing clean data and keeping copy.
    //   1  1  1  x  P  E  E  E  No No No E  Passing dirty data and keeping copy.

    //The following responses are illegal:
    // IsShared, CRRESP[3] = 1 for:
    //   ReadUnique
    //   CleanInvalid
    //   MakeInvalid.
    // PassDirty, CRRESP[2] = 1, and DataTransfer, CRRESP[0] = 0, for any transaction
    //----------------------------------------------------------------------- 
     function void check_ace_snoop_resp(ioaiu_scb_txn m_pkt);
         if (m_pkt.m_ace_snoop_resp_pkt.crresp[CCRRESPPASSDIRTYBIT] === 1 &&
             m_pkt.m_ace_snoop_resp_pkt.crresp[CCRRESPDATXFERBIT] === 0
         ) begin
             m_pkt.print_me();
             uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Above snoop response has PD = 1 and DXFER = 0, which is illegal as per ACE protocol"), UVM_NONE);
         end
         if ((m_pkt.m_ace_snoop_addr_pkt.acsnoop === ACE_READ_UNIQUE ||
              m_pkt.m_ace_snoop_addr_pkt.acsnoop === ACE_CLEAN_INVALID ||
              m_pkt.m_ace_snoop_addr_pkt.acsnoop === ACE_MAKE_INVALID
             ) &&
             m_pkt.m_ace_snoop_resp_pkt.crresp[CCRRESPISSHAREDBIT] === 1
         ) begin
             m_pkt.print_me();
             uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Above snoop response has IS = 1 and snoop type is either RDUNQ or CLNINVL or MKINVL, which is illegal as per ACE protocol"), UVM_NONE);
         end
     
        if (m_pkt.m_ace_snoop_resp_pkt.crresp[CCRRESPERRBIT] == 1 && m_pkt.m_ace_snoop_addr_pkt.acsnoop === ACE_DVM_CMPL) begin
             m_pkt.print_me();
             uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Above snoop response has Error = 1 for snooptype=DVMCMPL, which is illegal as per ACE protocol. Check ARM IHI 0022E C12.3.4 Transaction response"), UVM_NONE);
          end
     endfunction : check_ace_snoop_resp

    //----------------------------------------------------------------------- 
    // Function to set no_pending_cmd_req
    //----------------------------------------------------------------------- 
    function void set_no_pending_cmd_req(ioaiu_scb_txn tmp_txn);
	int m_tmp_qA[$],m_tmp_qB[$];

    // Logic to incorporate the DtrReq and StrReq as per CONC-6939 comment, here we will reach if no_pending_cmd_req = 0 by default, due to pending entries of CmdReq - CmdRsp
    if(tmp_txn.isRead) begin
        //find entry that has same arid() and targtId, and there is no CmdRsp recived for the CmdReq
        m_tmp_qA = m_ott_q.find_index with (item.isSMICMDReqSent && item.isRead && (!item.isSMICMDRespRecd || (item.isSMICMDRespRecd && (item.t_sfi_cmd_rsp == $time))) &&
                                           (axi_cmdreq_id_vif.axi_cmdreq_id_ar[item.m_cmd_req_pkt.smi_msg_id] == axi_cmdreq_id_vif.axi_cmdreq_id_ar[tmp_txn.m_cmd_req_pkt.smi_msg_id]) && 
                                           (item.m_ace_read_addr_pkt.arid== tmp_txn.m_ace_read_addr_pkt.arid) &&
                                           (item.m_cmd_req_pkt.smi_targ_id == tmp_txn.m_cmd_req_pkt.smi_targ_id) && 
                                           ((!item.isSMISTRReqRecd || (item.isSMISTRReqRecd && (item.t_sfi_str_req==$time))) && (item.isSMIDTRReqNeeded ? (!item.isSMIDTRReqRecd || (item.isSMIDTRReqRecd && item.t_sfi_dtr_req == $time)) : 1)) // StrReq and DtrReq none of them arrived
                          );
        if(m_tmp_qA.size()) begin
            foreach(m_tmp_qA[i]) begin
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("set_no_pending_cmd_req: Matching OTT entry RD :%0d ",i), UVM_DEBUG);
                m_ott_q[m_tmp_qA[i]].print_me();
            end
            if(m_tmp_qA.size() == 1)
	       tmp_txn.no_pending_cmd_req = 1;
        end else begin
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Found no OutstTxn that has CmdRsp pending for corresponding CmdReq, check the latest CmdReq"), UVM_NONE);
        end

    end else if(tmp_txn.isWrite) begin
        m_tmp_qA = m_ott_q.find_index with (item.isSMICMDReqSent && item.isWrite && (!item.isSMICMDRespRecd || (item.isSMICMDRespRecd && (item.t_sfi_cmd_rsp == $time))) &&
                                           (axi_cmdreq_id_vif.axi_cmdreq_id_ar[item.m_cmd_req_pkt.smi_msg_id] == axi_cmdreq_id_vif.axi_cmdreq_id_ar[tmp_txn.m_cmd_req_pkt.smi_msg_id]) && 
                                           (item.m_ace_write_addr_pkt.awid== tmp_txn.m_ace_write_addr_pkt.awid) &&
                                           (item.m_cmd_req_pkt.smi_targ_id == tmp_txn.m_cmd_req_pkt.smi_targ_id) && 
                                           ((!item.isSMISTRReqRecd || (item.isSMISTRReqRecd && (item.t_sfi_str_req==$time)))&& (item.isSMIDTRReqNeeded ? (!item.isSMIDTRReqRecd || (item.isSMIDTRReqRecd && item.t_sfi_dtr_req == $time)) : 1)) // StrReq and DtrReq none of them arrived
                          );
        if(m_tmp_qA.size()) begin
            foreach(m_tmp_qA[i]) begin
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("set_no_pending_cmd_req: Matching OTT entry WR :%0d ",i), UVM_DEBUG);
                m_ott_q[m_tmp_qA[i]].print_me();
            end
            if(m_tmp_qA.size() == 1)
	       tmp_txn.no_pending_cmd_req = 1;
        end else begin
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Found no OutstTxn that has CmdRsp pending for corresponding CmdReq, check the latest CmdReq"), UVM_NONE);
        end

    end

    endfunction // set_no_pending_cmd_req
    //----------------------------------------------------------------------- 
    // Function to find oldest entry in ott_q with certain criteria 
    //----------------------------------------------------------------------- 

    function int find_oldest_entry_in_ott_q(int m_tmp_q[$]);
        time t_tmp_time;
        int  m_tmp_indx;
    
        t_tmp_time = m_ott_q[m_tmp_q[0]].t_creation;
        m_tmp_indx = m_tmp_q[0];
        // Search for oldest ace address for which this is the data 
        for (int i = 1; i < m_tmp_q.size(); i++) begin
            if (t_tmp_time > m_ott_q[m_tmp_q[i]].t_creation) begin
                t_tmp_time = m_ott_q[m_tmp_q[i]].t_creation;
                m_tmp_indx = m_tmp_q[i];
            end
            // Sanity check below
            else if (t_tmp_time === m_ott_q[m_tmp_q[i]].t_creation) begin
                m_ott_q[m_tmp_indx].print_me();
                m_ott_q[i].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: OutstTxn #%0d and OutstTxn #%0d cannot have both sent ACE requests at the same time",m_tmp_indx,i), UVM_NONE);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Above two transactions cannot have both sent ACE requests at the same time"), UVM_NONE);
            end
        end
        return m_tmp_indx;
    endfunction : find_oldest_entry_in_ott_q

    function int find_entry_with_cmdreq_id_in_ott_q(int m_tmp_q[$], smi_seq_item m_pkt );
        int  m_tmp_indx;
        eMsgCMD cmd_type;

        $cast(cmd_type, m_pkt.smi_msg_type);
        foreach(m_tmp_q[indx]) begin
            //uvm_report_info("<%=obj.strRtlNamePrefix%> SCB DBG", $sformatf("OutstTxn #%0d get_axid:0x%0h", m_tmp_q[indx], axi_cmdreq_id_vif.get_axid(m_pkt.smi_msg_id)), UVM_LOW);
    	    case(cmd_type)
                eCmdRdUnq,eCmdRdNC,eCmdRdNITC,eCmdRdVld,eCmdRdCln,eCmdRdNShD, eCmdMkInv,eCmdMkUnq,eCmdClnInv,eCmdClnVld, eCmdClnUnq, eCmdClnShdPer, eCmdRdNITCClnInv, eCmdRdNITCMkInv: begin
                 if(m_ott_q[m_tmp_q[indx]].m_ott_status == ALLOCATED && m_ott_q[m_tmp_q[indx]].m_ott_id == m_pkt.smi_msg_id[WSMIMSGID-1-<%=Math.log2(obj.nNativeInterfacePorts)%>:0]) begin //CONC-12079
                 
                        if((transOrderMode_rd == pcieOrderMode && m_ott_q[m_tmp_q[indx]].gpra_order.readID == 0) ||
                            transOrderMode_rd == strictReqMode) begin
                            int m_oldest_indx;
                            m_oldest_indx = find_oldest_entry_in_ott_q(m_tmp_q);
                            //CONC-9647 Below check is updated to only look at arid dependency. Same arid, transactions should go out on SMI in the same order of arrival at nativeInterface.
							if (m_ott_q[m_oldest_indx].isRead) begin
								if ((m_tmp_q[indx] != m_oldest_indx) && (m_ott_q[m_tmp_q[indx]].m_ace_read_addr_pkt.arid == m_ott_q[m_oldest_indx].m_ace_read_addr_pkt.arid)) begin
									//#Check.IOAIU.CMDreq.Read_OrderingCheck
									uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: RTL doesn't match the Outgoing pkt to the oldest ARID(transOrderMode:%s). RTL maps to the Txn #%0d, but TB expects to map to OutstTxn #%0d. CmdReq:%s",transOrderMode_rd.name(), m_tmp_q[indx], m_oldest_indx, m_pkt.convert2string), UVM_NONE);
								end
							end
                        end
                         return m_tmp_q[indx];
                     end
                end
                eCmdWrUnqFull,eCmdWrUnqPtl,eCmdWrNCPtl,eCmdWrNCFull,eCmdWrStshFull,eCmdWrStshPtl,eCmdLdCchShd,eCmdLdCchUnq,eCmdRdAtm,eCmdWrAtm,eCmdCompAtm,eCmdSwAtm : begin

                 if(m_ott_q[m_tmp_q[indx]].m_ott_status == ALLOCATED && m_ott_q[m_tmp_q[indx]].m_ott_id == m_pkt.smi_msg_id[WSMIMSGID-1-<%=Math.log2(obj.nNativeInterfacePorts)%>:0]) begin //CONC-12079

                        if((transOrderMode_wr == pcieOrderMode && m_ott_q[m_tmp_q[indx]].gpra_order.writeID == 0) || 
                            transOrderMode_wr == strictReqMode) begin
                            int m_oldest_indx;
                            m_oldest_indx = find_oldest_entry_in_ott_q(m_tmp_q);
                            //CONC-9647 Below check is updated to only look at awid dependency. Same awid, transactions should go out on SMI in the same order of arrival at nativeInterface.
							if (m_ott_q[m_oldest_indx].isWrite) begin
								if ((m_tmp_q[indx] != m_oldest_indx) && (m_ott_q[m_tmp_q[indx]].m_ace_write_addr_pkt.awid == m_ott_q[m_oldest_indx].m_ace_write_addr_pkt.awid)) begin
                                         if(!(m_ott_q[m_oldest_indx].dtrreq_cmstatus_err || m_ott_q[m_oldest_indx].hasFatlErr || m_ott_q[m_oldest_indx].dtwrsp_cmstatus_err))begin
									//#Check.IOAIU.CMDreq.Write_OrderingCheck
									uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: RTL doesn't match the Outgoing pkt to the oldest AWID(transOrderMode:%s). RTL maps to the Txn #%0d, but TB expects to map to OutstTxn #%0d. CmdReq:%s",transOrderMode_wr.name(), m_tmp_q[indx], m_oldest_indx, m_pkt.convert2string), UVM_NONE);
							       end else begin
                         m_ott_q[m_oldest_indx].isSMICMDReqNeeded =0;
                     						end
                     	end

							end 
                        end
                        return m_tmp_q[indx];
                    end//addr_match && awid match
                end//case
                eCmdDvmMsg: return(find_oldest_entry_in_ott_q(m_tmp_q));
            endcase
        end //foreach m_tmp_q[indx]
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("FAILED TXN: %s", m_pkt.convert2string()),UVM_LOW)
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("fn:find_entry_with_cmdreq_id_in_ott_q Did not account for this cmd_type:%0p in this function", cmd_type))
    endfunction : find_entry_with_cmdreq_id_in_ott_q

    function int find_oldest_snoop_in_ott_q(int m_tmp_q[$]);
        time t_tmp_time;
        int  m_tmp_indx;
    
        t_tmp_time = m_ott_q[m_tmp_q[0]].t_ace_snoop_sent;
        m_tmp_indx = m_tmp_q[0];
        // Search for oldest ace address for which this is the data 
        for (int i = 1; i < m_tmp_q.size(); i++) begin
            if (t_tmp_time > m_ott_q[m_tmp_q[i]].t_ace_snoop_sent) begin
                t_tmp_time = m_ott_q[m_tmp_q[i]].t_ace_snoop_sent;
                m_tmp_indx = m_tmp_q[i];
            end
            // Sanity check below
            else if (t_tmp_time === m_ott_q[m_tmp_q[i]].t_ace_snoop_sent) begin
                m_ott_q[m_tmp_indx].print_me();
                m_ott_q[i].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Above two transactions cannot have both sent ACE snoop requests at the same time"), UVM_NONE);
            end
        end
        return m_tmp_indx;
    endfunction : find_oldest_snoop_in_ott_q

    function int find_oldest_read_in_ott_q(int m_tmp_q[$]);
        time t_tmp_time;
        int  m_tmp_indx;
    
        t_tmp_time = m_ott_q[m_tmp_q[0]].t_ace_read_recd;
        m_tmp_indx = m_tmp_q[0];
        // Search for oldest ace address for which this is the data 
        for (int i = 1; i < m_tmp_q.size(); i++) begin
            if (t_tmp_time > m_ott_q[m_tmp_q[i]].t_ace_read_recd) begin
                t_tmp_time = m_ott_q[m_tmp_q[i]].t_ace_read_recd;
                m_tmp_indx = m_tmp_q[i];
            end
            // Sanity check below
            else if (t_tmp_time == m_ott_q[m_tmp_q[i]].t_ace_read_recd) begin
                m_ott_q[m_tmp_indx].print_me();
                m_ott_q[i].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Above two transactions cannot have both sent ACE read requests at the same time"), UVM_NONE);
            end
        end
        return m_tmp_indx;
    endfunction : find_oldest_read_in_ott_q

    function int find_oldest_write_in_ott_q(int m_tmp_q[$]);
        time t_tmp_time;
        int  m_tmp_indx;
    
        t_tmp_time = m_ott_q[m_tmp_q[0]].t_ace_write_recd;
        m_tmp_indx = m_tmp_q[0];
        // Search for oldest ace address for which this is the data 
        for (int i = 1; i < m_tmp_q.size(); i++) begin
            if (t_tmp_time > m_ott_q[m_tmp_q[i]].t_ace_write_recd) begin
                t_tmp_time = m_ott_q[m_tmp_q[i]].t_ace_write_recd;
                m_tmp_indx = m_tmp_q[i];
            end
            // Sanity check below
            else if (t_tmp_time == m_ott_q[m_tmp_q[i]].t_ace_write_recd) begin
                m_ott_q[m_tmp_indx].print_me();
                m_ott_q[i].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Above two transactions cannot have both sent ACE write requests at the same time"), UVM_NONE);
            end
        end
        return m_tmp_indx;
    endfunction : find_oldest_write_in_ott_q

    function int find_newest_read_in_ott_q(int m_tmp_q[$]);
        time t_tmp_time;
        int  m_tmp_indx;
    
        t_tmp_time = m_ott_q[m_tmp_q[0]].t_ace_read_recd;
        m_tmp_indx = m_tmp_q[0];
        // Search for newest ace address for which this is the data 
        for (int i = 1; i < m_tmp_q.size(); i++) begin
            if (t_tmp_time < m_ott_q[m_tmp_q[i]].t_ace_read_recd) begin
                t_tmp_time = m_ott_q[m_tmp_q[i]].t_ace_read_recd;
                m_tmp_indx = m_tmp_q[i];
            end
            // Sanity check below
            else if (t_tmp_time == m_ott_q[m_tmp_q[i]].t_ace_read_recd) begin
                m_ott_q[m_tmp_indx].print_me();
                m_ott_q[i].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Above two transactions cannot have both sent ACE read requests at the same time"), UVM_NONE);
            end
        end
        return m_tmp_indx;
    endfunction : find_newest_read_in_ott_q

    function int find_newest_write_in_ott_q(int m_tmp_q[$]);
        time t_tmp_time;
        int  m_tmp_indx;
    
        t_tmp_time = m_ott_q[m_tmp_q[0]].t_ace_write_recd;
        m_tmp_indx = m_tmp_q[0];
        // Search for newest ace address for which this is the data 
        for (int i = 1; i < m_tmp_q.size(); i++) begin
            if (t_tmp_time < m_ott_q[m_tmp_q[i]].t_ace_write_recd) begin
                t_tmp_time = m_ott_q[m_tmp_q[i]].t_ace_write_recd;
                m_tmp_indx = m_tmp_q[i];
            end
            // Sanity check below
            else if (t_tmp_time == m_ott_q[m_tmp_q[i]].t_ace_write_recd) begin
                m_ott_q[m_tmp_indx].print_me();
                m_ott_q[i].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Above two transactions cannot have both sent ACE write requests at the same time"), UVM_NONE);
            end
        end
        return m_tmp_indx;
    endfunction : find_newest_write_in_ott_q

    function bit find_nearest_same_axid_create_time_in_ott_q(int idx, output time t_creation_time);
        time t_tmp_time;
        int  m_tmp_indx;
        int  m_tmp_q[$];
        bit  is_read;
        
        <% if (obj.useCache) { %>
        if(m_ott_q[idx].isIoCacheEvict) begin
            t_creation_time = -1;
            return 0;
        end
        <% } %>
        is_read = m_ott_q[idx].isACEReadAddressRecd;
        // Search for the nearest OTT indx with the same AWID
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index() with (((is_read &&
                                               item.isACEReadAddressRecd &&
                                               item.m_ace_read_addr_pkt.arid == m_ott_q[idx].m_ace_read_addr_pkt.arid) ||
                                              (!is_read &&
                                               item.isACEWriteAddressRecd &&
                                               item.m_ace_write_addr_pkt.awid == m_ott_q[idx].m_ace_write_addr_pkt.awid)) &&
                                              item.t_creation < m_ott_q[idx].t_creation
                                          );

        if(m_tmp_q.size == 0) begin
            t_creation_time = -1;
            return 0;
        end else begin
            t_tmp_time = m_ott_q[m_tmp_q[0]].t_creation;
            m_tmp_indx = m_tmp_q[0];
            for (int i = 1; i < m_tmp_q.size(); i++) begin
                if (t_tmp_time < m_ott_q[m_tmp_q[i]].t_creation) begin
                    t_tmp_time = m_ott_q[m_tmp_q[i]].t_creation;
                    m_tmp_indx = m_tmp_q[i];
                end
                // Sanity check below
                else if (t_tmp_time == m_ott_q[m_tmp_q[i]].t_creation) begin
                    m_ott_q[m_tmp_indx].print_me();
                    m_ott_q[i].print_me();
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Above two transactions cannot have the same write requests received time"), UVM_NONE);
                end
            end
            t_creation_time = t_tmp_time;
            return 1;
        end
    endfunction : find_nearest_same_axid_create_time_in_ott_q

    function int find_oldest_ioc_in_ott_q(int m_tmp_q[$]);
        time t_tmp_time;
        int  m_tmp_indx;
    
        t_tmp_time = m_ott_q[m_tmp_q[0]].t_io_cache_pkt;
        m_tmp_indx = m_tmp_q[0];
        // Search for oldest ace address for which this is the data 
        for (int i = 1; i < m_tmp_q.size(); i++) begin
            if (t_tmp_time > m_ott_q[m_tmp_q[i]].t_io_cache_pkt) begin
                t_tmp_time = m_ott_q[m_tmp_q[i]].t_io_cache_pkt;
                m_tmp_indx = m_tmp_q[i];
            end
            // Sanity check below
            else if (t_tmp_time == m_ott_q[m_tmp_q[i]].t_io_cache_pkt) begin
                m_ott_q[m_tmp_indx].print_me();
                m_ott_q[i].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Above two transactions cannot have both sent ACE IOC requests at the same time"), UVM_NONE);
            end
        end
        return m_tmp_indx;
    endfunction : find_oldest_ioc_in_ott_q

    function int find_oldest_ccp_in_ott_q(int m_tmp_q[$]);
        time t_tmp_time;
        int  m_tmp_indx;
    
        t_tmp_time = m_ott_q[m_tmp_q[0]].t_ccp_ctrl_creation;
        m_tmp_indx = m_tmp_q[0];
        // Search for oldest ace address for which this is the data 
        for (int i = 1; i < m_tmp_q.size(); i++) begin
            if (t_tmp_time > m_ott_q[m_tmp_q[i]].t_ccp_ctrl_creation) begin
                t_tmp_time = m_ott_q[m_tmp_q[i]].t_ccp_ctrl_creation;
                m_tmp_indx = m_tmp_q[i];
            end
            // Sanity check below
            else if (t_tmp_time == m_ott_q[m_tmp_q[i]].t_ccp_ctrl_creation) begin
                m_ott_q[m_tmp_indx].print_me();
                m_ott_q[i].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Above two transactions cannot have both sent ACE IOC requests at the same time"), UVM_NONE);
            end
        end
        return m_tmp_indx;
    endfunction : find_oldest_ccp_in_ott_q

    function int find_oldest_ccp_lookup_q(int m_tmp_q[$]);
        time t_tmp_time;
        int  m_tmp_indx;
    
        t_tmp_time = m_ott_q[m_tmp_q[0]].t_ccp_last_lookup;
        m_tmp_indx = m_tmp_q[0];
        // Search for oldest ace address for which this is the data 
        for (int i = 1; i < m_tmp_q.size(); i++) begin
            if (t_tmp_time > m_ott_q[m_tmp_q[i]].t_ccp_last_lookup) begin
                t_tmp_time = m_ott_q[m_tmp_q[i]].t_ccp_last_lookup;
                m_tmp_indx = m_tmp_q[i];
            end
            // Sanity check below
            else if (t_tmp_time == m_ott_q[m_tmp_q[i]].t_ccp_last_lookup) begin
                m_ott_q[m_tmp_indx].print_me();
                m_ott_q[i].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Above two transactions cannot have both sent ACE IOC requests at the same time"), UVM_NONE);
            end
        end
        return m_tmp_indx;
    endfunction : find_oldest_ccp_lookup_q


    function int find_oldest_ac_in_ott_q(int m_tmp_q[$]);
        time t_tmp_time;
        int  m_tmp_indx;

        t_tmp_time = m_ott_q[m_tmp_q[0]].t_ace_snoop_sent;
        m_tmp_indx = m_tmp_q[0];
        // Search for oldest ace snoop address for which this is snoop
        // response
        for (int i = 1; i < m_tmp_q.size(); i++) begin
            if (t_tmp_time > m_ott_q[m_tmp_q[i]].t_ace_snoop_sent) begin
                t_tmp_time = m_ott_q[m_tmp_q[i]].t_ace_snoop_sent;
                m_tmp_indx = m_tmp_q[i];
            end
            // Sanity check below
            else if (t_tmp_time == m_ott_q[m_tmp_q[i]].t_ace_snoop_sent) begin
                m_ott_q[m_tmp_indx].print_me();
                m_ott_q[i].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Above two transactions cannot have both sent ACE snoop address requests at the same time"), UVM_NONE);
            end
        end
        return m_tmp_indx;
    endfunction : find_oldest_ac_in_ott_q

    function int find_oldest_ace_snp_req(int m_tmp_q[$]);
							
        time t_tmp_time = 0;
        int  m_tmp_index = -1;
        if(m_ott_q[m_tmp_q[0]].smi_exp_flags["ACESnpRspDvm1"]) begin
	        if(m_ott_q[m_tmp_q[0]].smi_flags["ACESnpReqDvm1"]) begin
                t_tmp_time = m_ott_q[m_tmp_q[0]].smi_act_time["ACESnpReqDvm1"];
   	            m_tmp_index = m_tmp_q[0];
            end
        end
        else if(m_ott_q[m_tmp_q[0]].smi_exp_flags["ACESnpRspDvm2"]) begin
	        if(m_ott_q[m_tmp_q[0]].smi_flags["ACESnpReqDvm2"]) begin
                t_tmp_time = m_ott_q[m_tmp_q[0]].smi_act_time["ACESnpReqDvm2"];
   	            m_tmp_index = m_tmp_q[0];
            end
        end
        else if(m_ott_q[m_tmp_q[0]].t_ace_snoop_sent) begin
            t_tmp_time = m_ott_q[m_tmp_q[0]].t_ace_snoop_sent;
            m_tmp_index = m_tmp_q[0];
        end
        for(int i = 1; i < m_tmp_q.size(); i++) begin					
            if(m_ott_q[m_tmp_q[i]].smi_exp_flags["ACESnpRspDvm1"]) begin
                if(m_ott_q[m_tmp_q[i]].smi_act_time["ACESnpReqDvm1"] < t_tmp_time) begin
                    t_tmp_time = m_ott_q[m_tmp_q[i]].smi_act_time["ACESnpReqDvm1"];
   	                m_tmp_index = m_tmp_q[i];
                end
            end
            else if(m_ott_q[m_tmp_q[i]].smi_exp_flags["ACESnpRspDvm2"]) begin
	            if(m_ott_q[m_tmp_q[i]].smi_act_time["ACESnpReqDvm2"] < t_tmp_time) begin
                    t_tmp_time = m_ott_q[m_tmp_q[i]].smi_act_time["ACESnpReqDvm2"];
   	                m_tmp_index = m_tmp_q[i];
                end
            end
            else if(m_ott_q[m_tmp_q[0]].t_ace_snoop_sent) begin
                if (m_ott_q[m_tmp_q[i]].t_ace_snoop_sent < t_tmp_time) begin
                    t_tmp_time = m_ott_q[m_tmp_q[i]].t_ace_snoop_sent;
                    m_tmp_index = m_tmp_q[i];
                end
            end
        end
 
        if(m_tmp_index == -1) begin
	        uvm_report_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR",$sformatf("Did not find oldest index!"),UVM_NONE);
        end
        
        return m_tmp_index;
	    
   endfunction								    


    //----------------------------------------------------------------------- 
    // Function to unblock oldest Axid for read
    //----------------------------------------------------------------------- 

    function void unblock_axid_read(axi_arid_t rid);
        int m_tmp_q[$];
        ioaiu_scb_txn m_search_id_q[$];
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with (item.isRead                   === 1  &&
                                           item.m_ace_read_addr_pkt.arid === rid &&
                                           item.isACEReadAddressRecd       === 1 &&
                                           item.isAceCmdReqBlocked         == 1  &&
                                           (item.isMultiAccess            === 1 ?
                                            item.isMultiLineMaster        === 1 :
                                            1)                                 
                                       );

        if (m_tmp_q.size() == 1) begin
            if (m_ott_q[m_tmp_q[0]].isMultiAccess) begin
                int m_tmp_qA[$];
                m_tmp_qA = {};
                m_tmp_qA = m_ott_q.find_index with (item.isMultiAccess == 1 &&
                item.m_multiline_tracking_id == m_ott_q[m_tmp_q[0]].m_multiline_tracking_id);
                foreach (m_tmp_qA[i]) begin
                    m_ott_q[m_tmp_qA[i]].isAceCmdReqBlocked  = 0;
                    m_ott_q[m_tmp_qA[i]].wasAceCmdReqBlocked = 1;
                end                                  
            end                                  
            else begin
                `uvm_info("MUFFADAL", $psprintf("Removing AxId Blocking to Addr:%0h and ID:%0h", 
                m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.araddr,m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arid),UVM_MEDIUM)
                m_ott_q[m_tmp_q[0]].isAceCmdReqBlocked  = 0;
                m_ott_q[m_tmp_q[0]].wasAceCmdReqBlocked = 1;
            end
        end
        // Finding oldest entry if there are multiple blocked entries
        else if (m_tmp_q.size() > 1) begin
            m_tmp_q[0] = find_oldest_read_in_ott_q(m_tmp_q);
            if (m_ott_q[m_tmp_q[0]].isMultiAccess) begin
                int m_tmp_qA[$];
                m_tmp_qA = {};
                m_tmp_qA = m_ott_q.find_index with (item.isMultiAccess == 1 &&
                item.m_multiline_tracking_id == m_ott_q[m_tmp_q[0]].m_multiline_tracking_id);
                foreach (m_tmp_qA[i]) begin
                    m_ott_q[m_tmp_qA[i]].isAceCmdReqBlocked  = 0;
                    m_ott_q[m_tmp_qA[i]].wasAceCmdReqBlocked = 1;
                end                                  
            end                                  
            else begin
                m_ott_q[m_tmp_q[0]].isAceCmdReqBlocked  = 0;
                m_ott_q[m_tmp_q[0]].wasAceCmdReqBlocked = 1;
            end
        end 
        
    endfunction : unblock_axid_read

    //----------------------------------------------------------------------- 
    // Function to unblock oldest Axid for write 
    //----------------------------------------------------------------------- 

    function void unblock_axid_write(axi_awid_t bid);
        int m_tmp_q[$];
        ioaiu_scb_txn m_search_id_q[$];
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with ((item.isWrite                   === 1 ||
                                            item.isUpdate                  === 1) &&
                                           item.isACEWriteAddressRecd      === 1 &&
                                           item.isAceCmdReqBlocked         === 1 &&
                                            (item.isMultiAccess            === 1 ?
                                             item.isMultiLineMaster        === 1 :
                                             1)                                 &&    
                                           item.m_ace_write_addr_pkt.awid  === bid
                                        );
        if (m_tmp_q.size() == 1) begin
            if (m_ott_q[m_tmp_q[0]].isMultiAccess) begin
                int m_tmp_qA[$];
                m_tmp_qA = {};
                m_tmp_qA = m_ott_q.find_index with (item.isMultiAccess == 1 &&
                                                    item.m_multiline_tracking_id == m_ott_q[m_tmp_q[0]].m_multiline_tracking_id);
                foreach (m_tmp_qA[i]) begin
                    m_ott_q[m_tmp_qA[i]].isAceCmdReqBlocked  = 0;
                    m_ott_q[m_tmp_qA[i]].wasAceCmdReqBlocked = 1;
                end                                  
            end                                  
            else begin
                m_ott_q[m_tmp_q[0]].isAceCmdReqBlocked  = 0;
                m_ott_q[m_tmp_q[0]].wasAceCmdReqBlocked = 1;
                `uvm_info("MUFFADAL", $psprintf("Removing AxID Blocking to Addr:%0h and ID:%0h", 
                m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awaddr,m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awid),UVM_MEDIUM)
            end
        end
        // Finding oldest entry if there are multiple blocked entries
        else if (m_tmp_q.size() > 1)  begin
            m_tmp_q[0] = find_oldest_entry_in_ott_q(m_tmp_q);
            if (m_ott_q[m_tmp_q[0]].isMultiAccess) begin
                int m_tmp_qA[$];
                m_tmp_qA = {};
                m_tmp_qA = m_ott_q.find_index with (item.isMultiAccess == 1 &&
                                                    item.m_multiline_tracking_id == m_ott_q[m_tmp_q[0]].m_multiline_tracking_id);
                foreach (m_tmp_qA[i]) begin
                    m_ott_q[m_tmp_qA[i]].isAceCmdReqBlocked  = 0;
                    m_ott_q[m_tmp_qA[i]].wasAceCmdReqBlocked = 1;
                end                                  
            end                                  
            else begin
                m_ott_q[m_tmp_q[0]].isAceCmdReqBlocked  = 0;
                m_ott_q[m_tmp_q[0]].wasAceCmdReqBlocked = 0;
            end
        end 
    endfunction : unblock_axid_write

    //----------------------------------------------------------------------- 
    // Function to delete OTT entry
    //----------------------------------------------------------------------- 

    function void delete_ott_entry(int index, eSMIPktTypes e_reason);
        string s_reason;
        pkt_order_t m_pkt_order[$];
        pkt_order_t m_tmp_pkt;
        int tmp_index_q[$];
        int unsigned ott_alloc_cycles;

        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Attempting to delete OTT entry after %s isComplete:%0d", e_reason.name(), m_ott_q[index].isComplete()), UVM_LOW); 

	if(m_ott_q[index].isComplete()) begin

        case (e_reason)
            CmdReq         : s_reason = "cmd request";
            CmdRsp         : s_reason = "cmd response";
            SnpReq         : s_reason = "snoop request";
            SnpRsp         : s_reason = "snoop response";
            SnpDtrRsp      : s_reason = "snoop dtr response";
            DtrReq         : s_reason = "dtr request";
            DtrRsp         : s_reason = "dtr response";
            DtwReq         : s_reason = "dtw request";
            DtwRsp         : s_reason = "dtw response";
            StrReq         : s_reason = "str request";
            StrRsp         : s_reason = "str response";
            MntOp_Upd_Dis  : s_reason = "upd request_disable";
            UpdReq         : s_reason = "upd request";
            UpdRsp         : s_reason = "upd response";
            SnpDtwRsp      : s_reason = "snoop dtw response";
            AceWrRsp       : s_reason = "ACE write response";
            NCWrRsp        : s_reason = "ACE NC write response";
            NCRdData       : s_reason = "ACE NC read data";
            AceSnpRsp      : s_reason = "ACE snoop response";
            AceSnpData     : s_reason = "ACE snoop data";
            AceRdData      : s_reason = "ACE read data";
            IOCData        : s_reason = "IO$ snoop data";
            Hang           : s_reason = "OTT hang due to error";
            MultiAceRdData : s_reason = "Multi-line ACE read data";
            MultiAceWrResp : s_reason = "Multi-line ACE write resp";
            IOCacheEvict   : s_reason = "Proxy Cache Silent Eviction";
            SenderEventReq : s_reason = "Sender Event Request";
            RecieverEventReq : s_reason = "Reciever Event Request";
        endcase
        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Deleting below OTT entry after %s", s_reason), UVM_LOW); 
        if (m_ott_q[index].isRead || m_ott_q[index].isWrite) begin
          `uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG", $sformatf("UID:%0d OTT_ID:%0d alloc_cycles:%0d", m_ott_q[index].tb_txnid, m_ott_q[index].m_ott_id, m_ott_q[index].ott_alloc_cc - m_ott_q[index].natv_intf_cc), UVM_NONE);
          ott_alloc_cycles = m_ott_q[index].ott_alloc_cc - m_ott_q[index].natv_intf_cc;
          if(ott_alloc_cycles > largest_ott_alloc_cycles)
            largest_ott_alloc_cycles = ott_alloc_cycles; 
        end
        if (this.get_report_verbosity_level() > UVM_NONE) begin
            m_ott_q[index].print_me(0,0,1,0);
        end
        //if ((m_ott_q[index].m_ace_cmd_type == WRUNQPTLSTASH) && 
        //    (m_ott_q[index].m_cmd_req_pkt.smi_mpf1_stash_valid == 1) &&
        //    (m_ott_q[index].m_cmd_req_pkt.smi_mpf1_stash_nid   == 'h0) &&
        //    (m_ott_q[index].m_str_req_pkt.smi_cmstatus_snarf == 1))
        //`uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Error out due to write partial stash")); 

        <%if(obj.useCache) { %> 
        if (m_ott_q[index].isRead && m_ott_q[index].addrNotInMemRegion === 0) begin
            if (m_ott_q[index].is_ccp_hit) begin
                numReadHits++;
                sb_stall_if.perf_count_events["Cache_read_hit"].push_back(1); //TODO: HS investigate why incrementing here does not work
                //`uvm_info("DEBUG_CACHE_HIT_SB_READ",$sformatf("isRead=%0d write_hit=%0d",m_ott_q[index].isRead,sb_stall_if.perf_count_events["Cache_read_hit"].size()),UVM_LOW)

                t_last_read_complete_time  = m_ott_q[index].t_ace_read_data_sent;
                if (t_min_read_hit_transaction == 0ns) begin
                    t_min_read_hit_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_min_read_hit_start_time  = m_ott_q[index].t_creation;
                    m_min_read_hit_addr        = m_ott_q[index].m_ace_read_addr_pkt.araddr;
                    t_max_read_hit_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_avg_read_hit_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                end
                else begin
                    if (t_min_read_hit_transaction > m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                        t_min_read_hit_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                        t_min_read_hit_start_time  = m_ott_q[index].t_creation;
                        m_min_read_hit_addr        = m_ott_q[index].m_ace_read_addr_pkt.araddr;
                    end
                    if (t_max_read_hit_transaction < m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                        t_max_read_hit_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    end
                end
                t_avg_read_hit_transaction = (t_avg_read_hit_transaction * (numReadHits - 1) + m_ott_q[index].t_latest_update - m_ott_q[index].t_creation)/numReadHits;
            end
            else begin
                numReadMiss++;
                sb_stall_if.perf_count_events["Cache_read_miss"].push_back(1);
                //`uvm_info("DEBUG_CACHE_HIT_SB_READ_MISS",$sformatf("numReadMiss=%0d",numReadMiss),UVM_LOW)
                t_last_read_complete_time  = m_ott_q[index].t_ace_read_data_sent;
                if (t_min_read_miss_transaction == 0ns) begin
                    t_min_ace_read_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd;
                    t_max_ace_read_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd;
                    t_avg_ace_read_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd;
                    t_min_ace_read_to_cmd_req_start_time  = m_ott_q[index].t_creation;
                    t_min_smi_to_axi_transaction = m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req;
                    t_min_smi_to_axi_start_time  = m_ott_q[index].t_creation;
                    m_min_smi_to_axi_addr        = m_ott_q[index].m_ace_read_addr_pkt.araddr;
                    t_min_read_miss_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_min_read_miss_start_time  = m_ott_q[index].t_creation;
                    m_min_read_miss_addr        = m_ott_q[index].m_ace_read_addr_pkt.araddr;
                    t_max_read_miss_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_avg_read_miss_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    //REVIEW_PENDING
                    t_min_smi_to_axi_transaction = m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req;
                    t_max_smi_to_axi_transaction = m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req;
                    t_avg_smi_to_axi_transaction = m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req;  //Till this
                end
                else begin
                    if (t_min_read_miss_transaction > m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                        t_min_read_miss_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                        t_min_read_miss_start_time  = m_ott_q[index].t_creation;
                        m_min_read_miss_addr        = m_ott_q[index].m_ace_read_addr_pkt.araddr;
                    end
                    if (t_max_read_miss_transaction < m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                        t_max_read_miss_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    end
                    t_avg_read_miss_transaction = (t_avg_read_miss_transaction * (numReadMiss - 1) + m_ott_q[index].t_latest_update - m_ott_q[index].t_creation)/numReadMiss;

                    if (t_min_ace_read_to_cmd_req_transaction > m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd) begin
                        t_min_ace_read_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd;
                        t_min_ace_read_to_cmd_req_start_time  = m_ott_q[index].t_creation;
                        m_min_ace_read_to_cmd_req_addr        = m_ott_q[index].m_ace_read_addr_pkt.araddr;
                    end
                    if (t_max_ace_read_to_cmd_req_transaction < m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd) begin
                        t_max_ace_read_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd;
                    end
                    t_avg_ace_read_to_cmd_req_transaction = (t_avg_ace_read_to_cmd_req_transaction * (numReadMiss - 1) + m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd)/numReadMiss;
                    //REVIEW_PENDING
                    if (t_min_smi_to_axi_transaction > m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req) begin
                        t_min_smi_to_axi_transaction = m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req;
                        t_min_smi_to_axi_start_time  = m_ott_q[index].t_creation;
                        m_min_smi_to_axi_addr        = m_ott_q[index].m_ace_read_addr_pkt.araddr;
                    end
                    if (t_max_smi_to_axi_transaction < m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req) begin
                        t_max_smi_to_axi_transaction = m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req;
                    end
                    t_avg_smi_to_axi_transaction = (t_avg_smi_to_axi_transaction * (numReadMiss - 1) + m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req)/numReadMiss;   //Till this

                    if(m_ott_q[index].m_iocache_allocate && m_ott_q[index].m_ccp_ctrl_pkt.evictvld) begin
                        numReadEvicts++;
                        sb_stall_if.perf_count_events["Cache_eviction"].push_back(1);
                    end
                end
                
                m_pkt_order = {};
                if (m_ott_q[index].isACEReadAddressRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_read_recd;
                    m_tmp_pkt.pkt_name = "ACERD";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isACEReadDataSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_read_data_sent;
                    m_tmp_pkt.pkt_name = "ACERDDATA";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMICMDReqSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_cmd_req;
                    m_tmp_pkt.pkt_name = "CMDREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMICMDRespRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_cmd_rsp;
                    m_tmp_pkt.pkt_name = "CMDRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMISTRReqRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_str_req;
                    m_tmp_pkt.pkt_name = "STRREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMISTRRespSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_str_rsp;
                    m_tmp_pkt.pkt_name = "STRRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMIDTRReqRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_req;
                    m_tmp_pkt.pkt_name = "ONEDTRREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMIDTRRespSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_rsp;
                    m_tmp_pkt.pkt_name = "ONEDTRRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMIDTWReqSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_req;
                    m_tmp_pkt.pkt_name = "DTWREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMIDTWRespRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_rsp;
                    m_tmp_pkt.pkt_name = "DTWRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
            end
        end
        if (m_ott_q[index].isWrite && m_ott_q[index].addrNotInMemRegion === 0) begin
            if (m_ott_q[index].is_ccp_hit) begin
                numWriteHits++;
                sb_stall_if.perf_count_events["Cache_write_hit"].push_back(1);
                //`uvm_info("DEBUG_CACHE_HIT_SB_WRITE",$sformatf("isWrite=%0d write_hit=%0d",m_ott_q[index].isWrite,sb_stall_if.perf_count_events["Cache_write_hit"].size()),UVM_LOW)
                t_last_write_complete_time  = m_ott_q[index].t_ace_write_resp_sent;
                if (t_min_write_hit_transaction == 0ns) begin
                    t_min_write_hit_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_min_write_hit_start_time  = m_ott_q[index].t_creation;
                    m_min_write_hit_addr        = m_ott_q[index].m_ace_write_addr_pkt.awaddr;
                    t_max_write_hit_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_avg_write_hit_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                end
                else begin
                    if (t_min_write_hit_transaction > m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                        t_min_write_hit_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                        t_min_write_hit_start_time  = m_ott_q[index].t_creation;
                        m_min_write_hit_addr        = m_ott_q[index].m_ace_write_addr_pkt.awaddr;
                    end
                    if (t_max_write_hit_transaction < m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                        t_max_write_hit_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    end
                end
                t_avg_write_hit_transaction = (t_avg_write_hit_transaction * (numWriteHits - 1) + m_ott_q[index].t_latest_update - m_ott_q[index].t_creation)/numWriteHits;
            end
            else begin
                if(m_ott_q[index].is_write_hit_upgrade) begin
                    numWriteHitUpgrade++;
                end 
                    numWriteMiss++;
                    sb_stall_if.perf_count_events["Cache_write_miss"].push_back(1);
                   // `uvm_info("DEBUG_CACHE_HIT_SB_WRITE_MISS",$sformatf("numReadMiss=%0d",numReadMiss),UVM_LOW)

                t_last_write_complete_time  = m_ott_q[index].t_ace_write_resp_sent;
                if (t_min_write_miss_transaction == 0ns) begin
                    t_min_ace_write_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd;
                    t_max_ace_write_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd;
                    t_avg_ace_write_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd;
                    t_min_write_miss_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_min_write_miss_start_time  = m_ott_q[index].t_creation;
                    m_min_write_miss_addr        = m_ott_q[index].m_ace_write_addr_pkt.awaddr;
                    t_max_write_miss_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_avg_write_miss_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                end
                else begin
                    if (t_min_write_miss_transaction > m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                        t_min_write_miss_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                        t_min_write_miss_start_time  = m_ott_q[index].t_creation;
                        m_min_write_miss_addr        = m_ott_q[index].m_ace_write_addr_pkt.awaddr;
                    end
                    if (t_max_write_miss_transaction < m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                        t_max_write_miss_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    end

                end
                t_avg_write_miss_transaction = (t_avg_write_miss_transaction * (numWriteMiss - 1) + m_ott_q[index].t_latest_update - m_ott_q[index].t_creation)/numWriteMiss;

                if (t_min_ace_write_to_cmd_req_transaction > m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd) begin
                    t_min_ace_write_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd;
                    t_min_ace_write_to_cmd_req_start_time  = m_ott_q[index].t_creation;
                    m_min_ace_write_to_cmd_req_addr        = m_ott_q[index].m_ace_write_addr_pkt.awaddr;
                end
                if (t_max_ace_write_to_cmd_req_transaction < m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd) begin
                    t_max_ace_write_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd;
                end
                t_avg_ace_write_to_cmd_req_transaction = (t_avg_ace_write_to_cmd_req_transaction * (numWriteMiss - 1) + m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd)/numWriteMiss;
                if(m_ott_q[index].m_iocache_allocate) begin
                    m_pkt_order = {};
                    if (m_ott_q[index].isACEWriteAddressRecd) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_write_recd;
                        m_tmp_pkt.pkt_name = "ACERD";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isACEWriteRespSent) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_write_resp_sent;
                        m_tmp_pkt.pkt_name = "ACERDDATA";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMICMDReqSent) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_cmd_req;
                        m_tmp_pkt.pkt_name = "CMDREQ";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMICMDRespRecd) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_cmd_rsp;
                        m_tmp_pkt.pkt_name = "CMDRSP";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMISTRReqRecd) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_str_req;
                        m_tmp_pkt.pkt_name = "STRREQ";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMISTRRespSent) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_str_rsp;
                        m_tmp_pkt.pkt_name = "STRRSP";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMIDTRReqRecd) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_req;
                        m_tmp_pkt.pkt_name = "ONEDTRREQ";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMIDTRRespSent) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_rsp;
                        m_tmp_pkt.pkt_name = "ONEDTRRSP";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMIDTWReqSent) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_req;
                        m_tmp_pkt.pkt_name = "DTWREQ";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMIDTWRespRecd) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_rsp;
                        m_tmp_pkt.pkt_name = "DTWRSP";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                end else begin
                    m_pkt_order = {};
                    if (m_ott_q[index].isACEWriteAddressRecd) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_write_recd;
                        m_tmp_pkt.pkt_name = "ACEWR";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isACEWriteDataRecd) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_write_data_recd;
                        m_tmp_pkt.pkt_name = "ACEWRDATA";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isACEWriteRespSent) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_write_resp_sent;
                        m_tmp_pkt.pkt_name = "ACEWRRSP";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMICMDReqSent) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_cmd_req;
                        m_tmp_pkt.pkt_name = "CMDREQ";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMICMDRespRecd) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_cmd_rsp;
                        m_tmp_pkt.pkt_name = "CMDRSP";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMISTRReqRecd) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_str_req;
                        m_tmp_pkt.pkt_name = "STRREQ";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMISTRRespSent) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_str_rsp;
                        m_tmp_pkt.pkt_name = "STRRSP";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMIDTRReqRecd) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_req;
                        m_tmp_pkt.pkt_name = "ONEDTRREQ";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMIDTRRespSent) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_rsp;
                        m_tmp_pkt.pkt_name = "ONEDTRRSP";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMIDTWReqSent) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_req;
                        m_tmp_pkt.pkt_name = "DTWREQ";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMIDTWRespRecd) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_rsp;
                        m_tmp_pkt.pkt_name = "DTWRSP";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMIUPDReqSent) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_upd_req;
                        m_tmp_pkt.pkt_name = "UPDREQ";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                    if (m_ott_q[index].isSMIUPDRespRecd) begin
                        m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_upd_rsp;
                        m_tmp_pkt.pkt_name = "UPDRSP";
                        m_pkt_order.push_back(m_tmp_pkt);
                    end 
                end
            end
            if(m_ott_q[index].isPartialWrite) begin
                numWriteMissPtl++;
            end else begin
                numWriteMissFull++;
            end

            if(m_ott_q[index].m_iocache_allocate && m_ott_q[index].m_ccp_ctrl_pkt.evictvld) begin
                numWriteEvicts++;
                sb_stall_if.perf_count_events["Cache_eviction"].push_back(1);
            end
        end
        if (m_ott_q[index].isSnoop && m_ott_q[index].addrNotInMemRegion === 0) begin
            if (t_min_snoop_transaction == 0ns) begin
                t_min_snoop_transaction                  = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                t_min_snoop_start_time                   = m_ott_q[index].t_creation;
                m_min_snoop_addr                         = m_ott_q[index].m_snp_req_pkt.smi_addr;
                t_max_snoop_transaction                  = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                t_avg_snoop_transaction                  = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                //REVIEW_PENDING
                t_min_snoop_to_resp_transaction = m_ott_q[index].t_sfi_snp_rsp - m_ott_q[index].t_sfi_snp_req;
                t_max_snoop_to_resp_transaction = m_ott_q[index].t_sfi_snp_rsp - m_ott_q[index].t_sfi_snp_req;
                t_avg_snoop_to_resp_transaction = m_ott_q[index].t_sfi_snp_rsp - m_ott_q[index].t_sfi_snp_req; //Till this
            end
            else begin
                if (t_min_snoop_transaction > m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                    t_min_snoop_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_min_snoop_start_time  = m_ott_q[index].t_creation;
                    //m_min_snoop_addr        = m_ott_q[index].m_snp_req_pkt.smi_addr;
                end
                if (t_max_snoop_transaction < m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                    t_max_snoop_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                end
                t_avg_snoop_transaction = (t_avg_snoop_transaction * (num_snoops - 1) + m_ott_q[index].t_latest_update - m_ott_q[index].t_creation)/num_snoops;
                //REVIEW_PENDING
                if (t_min_snoop_to_resp_transaction > m_ott_q[index].t_sfi_snp_rsp - m_ott_q[index].t_sfi_snp_req) begin
                    t_min_snoop_to_resp_transaction = m_ott_q[index].t_sfi_snp_rsp - m_ott_q[index].t_sfi_snp_req;
                    t_min_snoop_to_resp_start_time  = m_ott_q[index].t_creation;
                    m_min_snoop_to_resp_addr        = m_ott_q[index].m_snp_req_pkt.smi_addr;
                end
                if (t_max_snoop_to_resp_transaction < m_ott_q[index].t_sfi_snp_rsp - m_ott_q[index].t_sfi_snp_req) begin
                    t_max_snoop_to_resp_transaction = m_ott_q[index].t_sfi_snp_rsp - m_ott_q[index].t_sfi_snp_req;
                end
                t_avg_snoop_to_resp_transaction = (t_avg_snoop_to_resp_transaction * (numReadMiss - 1) + m_ott_q[index].t_sfi_snp_rsp - m_ott_q[index].t_sfi_snp_req)/numReadMiss;  //Till this
            end
            //REVIEW_PENDING
            m_pkt_order = {};
            if (m_ott_q[index].isSMISNPReqRecd) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_snp_req;
                m_tmp_pkt.pkt_name = "SNPREQ";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
            if (m_ott_q[index].isSMISNPRespSent) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_snp_rsp;
                m_tmp_pkt.pkt_name = "SNPRSP";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
            if (m_ott_q[index].isSMISNPDTRReqSent) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_req;
                m_tmp_pkt.pkt_name = "DTRREQ";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
            if (m_ott_q[index].isSMISNPDTRRespRecd) begin
		m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_rsp;
                m_tmp_pkt.pkt_name = "DTRRSP";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
            if (m_ott_q[index].isSMIDTWReqSent) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_req;
                m_tmp_pkt.pkt_name = "DTWREQ";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
            if (m_ott_q[index].isSMIDTWRespRecd) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_rsp;
                m_tmp_pkt.pkt_name = "DTWRSP";
                m_pkt_order.push_back(m_tmp_pkt);
            end 

            if(m_ott_q[index].is_ccp_hit) begin
                numSnoopHit++;
                sb_stall_if.perf_count_events["Cache_snoop_hit"].push_back(1);
            end else begin
                numSnoopMiss++;
                sb_stall_if.perf_count_events["Cache_snoop_miss"].push_back(1);
            end
        end
<% } else { %>
        if (m_ott_q[index].isRead) begin
            t_last_read_complete_time                     = m_ott_q[index].t_ace_read_data_sent;
            if (m_ott_q[index].isCoherent === 1) begin
                if (t_min_read_transaction == 0ns) begin
                    t_min_read_transaction                = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_min_read_start_time                 = m_ott_q[index].t_creation;
                    m_min_read_addr                       = m_ott_q[index].m_ace_read_addr_pkt.araddr;
                    t_max_read_transaction                = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_avg_read_transaction                = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_min_ace_read_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd;
                    t_min_ace_read_to_cmd_req_start_time  = m_ott_q[index].t_creation;
                    t_max_ace_read_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd;
                    t_avg_ace_read_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd;
                    t_read_start_time                     = m_ott_q[index].t_creation;
                    //t_last_read_complete_time             = m_ott_q[index].t_ace_read_data_sent;
                    //REVIEW_PENDING
                    t_min_smi_to_axi_transaction = m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req;
                    t_max_smi_to_axi_transaction = m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req;
                    t_avg_smi_to_axi_transaction = m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req;  //Till this
                    if ($test$plusargs("performance_test")) begin
                        if ($test$plusargs("read_latency_test")) begin
	                    //DCTODO PERFCHK
                            if(m_ott_q[index].t_sfi_str_req >= m_ott_q[index].t_sfi_dtr_req*1000) begin 
                                t_str_req_dtr_req_to_ace_read_rsp_transaction   = m_ott_q[index].m_ace_read_data_pkt.t_pkt_seen_on_intf*1000 - m_ott_q[index].t_sfi_str_req;
                            end else begin
                                t_str_req_dtr_req_to_ace_read_rsp_transaction   = m_ott_q[index].m_ace_read_data_pkt.t_pkt_seen_on_intf*1000 - m_ott_q[index].t_sfi_dtr_req*1000;
                            end 
                            t_rack_to_str_rsp_transaction                    = m_ott_q[index].t_sfi_str_rsp -  m_ott_q[index].t_ace_read_data_sent;
                        end 
                    end 
                end
                else begin
                    //t_last_read_complete_time                        = m_ott_q[index].t_ace_read_data_sent;
                    if (t_min_read_transaction > m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                        t_min_read_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                        t_min_read_start_time                 = m_ott_q[index].t_creation;
                        m_min_read_addr                       = m_ott_q[index].m_ace_read_addr_pkt.araddr;
                    end
                    if (t_max_read_transaction < m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                        t_max_read_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    end
                    t_avg_read_transaction = (t_avg_read_transaction * (num_reads - 1) + m_ott_q[index].t_latest_update - m_ott_q[index].t_creation)/num_reads;
                    if (t_min_ace_read_to_cmd_req_transaction > m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd) begin
                        t_min_ace_read_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd;
                        t_min_ace_read_to_cmd_req_start_time  = m_ott_q[index].t_creation;
                        m_min_ace_read_to_cmd_req_addr        = m_ott_q[index].m_ace_read_addr_pkt.araddr;
                    end
                    if (t_max_ace_read_to_cmd_req_transaction < m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd) begin
                        t_max_ace_read_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd;
                    end
                    t_avg_ace_read_to_cmd_req_transaction = (t_avg_ace_read_to_cmd_req_transaction * (num_reads - 1) + m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_read_recd)/num_reads;
                    //REVIEW_PENDING
                    if (t_min_smi_to_axi_transaction > m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req) begin
                        t_min_smi_to_axi_transaction = m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req;
                        t_min_smi_to_axi_start_time  = m_ott_q[index].t_creation;
                        m_min_smi_to_axi_addr        = m_ott_q[index].m_ace_read_addr_pkt.araddr;
                    end
                    if (t_max_smi_to_axi_transaction < m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req) begin
                        t_max_smi_to_axi_transaction = m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req;
                    end
                    t_avg_smi_to_axi_transaction = (t_avg_smi_to_axi_transaction * (num_reads - 1) + m_ott_q[index].t_ace_read_data_sent - m_ott_q[index].t_sfi_dtr_req)/num_reads;  //Till this
                end
                m_pkt_order = {};
                if (m_ott_q[index].isACEReadAddressRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_read_recd;
                    m_tmp_pkt.pkt_name = "ACERD";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isACEReadDataSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_read_data_sent;
                    m_tmp_pkt.pkt_name = "ACERDDATA";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMICMDReqSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_cmd_req;
                    m_tmp_pkt.pkt_name = "CMDREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMICMDRespRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_cmd_rsp;
                    m_tmp_pkt.pkt_name = "CMDRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMISTRReqRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_str_req;
                    m_tmp_pkt.pkt_name = "STRREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMISTRRespSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_str_rsp;
                    m_tmp_pkt.pkt_name = "STRRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMIDTRReqRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_req;
                    m_tmp_pkt.pkt_name = "ONEDTRREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMIDTRRespSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_rsp;
                    m_tmp_pkt.pkt_name = "ONEDTRRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 

                 if (m_ott_q[index].isSMIDTWReqSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_req;
                    m_tmp_pkt.pkt_name = "DTWREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMIDTWRespRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_rsp;
                    m_tmp_pkt.pkt_name = "DTWRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
            end
        end
        if (m_ott_q[index].isWrite || m_ott_q[index].isUpdate) begin
            t_last_write_complete_time                     = m_ott_q[index].t_ace_write_resp_sent;
            if (m_ott_q[index].isCoherent === 1) begin
                if (t_min_write_transaction == 0ns) begin
                    t_min_write_transaction                = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_min_write_start_time                 = m_ott_q[index].t_creation;
                    m_min_write_addr                       = m_ott_q[index].m_ace_write_addr_pkt.awaddr;
                    t_max_write_transaction                = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_avg_write_transaction                = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_min_ace_write_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd;
                    t_max_ace_write_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd;
                    t_avg_ace_write_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd;

                    if ($test$plusargs("performance_test")) begin
                        if($test$plusargs("wrlnUnq_latency_test")) begin
                            if(m_ott_q[index].t_sfi_str_req >= m_ott_q[index].t_ace_write_data_recd) begin
                                t_ace_write_data_str_req_to_dtw_req_transaction   = m_ott_q[index].t_sfi_dtw_req_perbeat[0]*1000 -  m_ott_q[index].t_sfi_str_req;
                            end else begin
                                t_ace_write_data_str_req_to_dtw_req_transaction   = m_ott_q[index].t_sfi_dtw_req_perbeat[0]*1000 -  m_ott_q[index].t_ace_write_data_recd;
                            end
                        end
                        t_dtw_rsp_to_brsp_transaction                       = m_ott_q[index].m_ace_write_resp_pkt.t_pkt_seen_on_intf*1000 - m_ott_q[index].t_sfi_dtw_rsp;
                        t_wack_to_str_rsp_transaction                       = m_ott_q[index].t_sfi_str_rsp - m_ott_q[index].t_ace_write_resp_sent;

                        if($test$plusargs("wb_latency_test")) begin
                            if(m_ott_q[index].t_ace_write_recd >= m_ott_q[index].t_ace_write_data_recd) begin
                                t_ace_write_req_write_data_to_dtw_req_transaction   = m_ott_q[index].t_sfi_dtw_req_perbeat[0]*1000 - m_ott_q[index].t_ace_write_recd;
                            end else begin
                                t_ace_write_req_write_data_to_dtw_req_transaction   = m_ott_q[index].t_sfi_dtw_req_perbeat[0]*1000 - m_ott_q[index].t_ace_write_data_recd;
                            end
                            t_dtw_rsp_to_upd_req_transaction                    = m_ott_q[index].t_sfi_upd_req - m_ott_q[index].t_sfi_dtw_rsp;
                            t_upd_rsp_to_brsp_transaction                       = m_ott_q[index].m_ace_write_resp_pkt.t_pkt_seen_on_intf*1000 - m_ott_q[index].t_sfi_upd_rsp ;
                        end

                        t_write_start_time                                  = m_ott_q[index].t_creation;
                        //t_last_write_complete_time                          = m_ott_q[index].t_ace_write_resp_sent;

                    end
                end
                else begin
                    if (t_min_write_transaction > m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                        t_min_write_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                        t_min_write_start_time                 = m_ott_q[index].t_creation;
                        m_min_write_addr                       = m_ott_q[index].m_ace_write_addr_pkt.awaddr;
                    end
                    if (t_max_write_transaction < m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                        t_max_write_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    end
                    t_avg_write_transaction = (t_avg_write_transaction * (num_writes - 1) + m_ott_q[index].t_latest_update - m_ott_q[index].t_creation)/num_writes;
                    if (t_min_ace_write_to_cmd_req_transaction > m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd) begin
                        t_min_ace_write_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd;
                        t_min_ace_write_to_cmd_req_start_time  = m_ott_q[index].t_creation;
                        m_min_ace_write_to_cmd_req_addr        = m_ott_q[index].m_ace_write_addr_pkt.awaddr;
                    end
                    if (t_max_ace_write_to_cmd_req_transaction < m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd) begin
                        t_max_ace_write_to_cmd_req_transaction = m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd;
                    end
                    t_avg_ace_write_to_cmd_req_transaction = (t_avg_ace_write_to_cmd_req_transaction * (num_writes - 1) + m_ott_q[index].t_sfi_cmd_req - m_ott_q[index].t_ace_write_recd)/num_writes;


                    //t_last_write_complete_time                          = m_ott_q[index].t_ace_write_resp_sent;
                end
                m_pkt_order = {};
                if (m_ott_q[index].isACEWriteAddressRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_write_recd;
                    m_tmp_pkt.pkt_name = "ACEWR";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isACEWriteDataRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_write_data_recd;
                    m_tmp_pkt.pkt_name = "ACEWRDATA";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isACEWriteRespSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_write_resp_sent;
                    m_tmp_pkt.pkt_name = "ACEWRRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMICMDReqSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_cmd_req;
                    m_tmp_pkt.pkt_name = "CMDREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMICMDRespRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_cmd_rsp;
                    m_tmp_pkt.pkt_name = "CMDRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMISTRReqRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_str_req;
                    m_tmp_pkt.pkt_name = "STRREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMISTRRespSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_str_rsp;
                    m_tmp_pkt.pkt_name = "STRRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMIDTRReqRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_req;
                    m_tmp_pkt.pkt_name = "ONEDTRREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMIDTRRespSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_rsp;
                    m_tmp_pkt.pkt_name = "ONEDTRRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMIDTWReqSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_req;
                    m_tmp_pkt.pkt_name = "DTWREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMIDTWRespRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_rsp;
                    m_tmp_pkt.pkt_name = "DTWRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMIUPDReqSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_upd_req;
                    m_tmp_pkt.pkt_name = "UPDREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSMIUPDRespRecd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_upd_rsp;
                    m_tmp_pkt.pkt_name = "UPDRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
            end
        end
        if (m_ott_q[index].isSenderEventReq) begin
            num_SenderEvt++;
                m_pkt_order = {};
                if (m_ott_q[index].isSenderSysReqNeeded) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_evt_req;
                    m_tmp_pkt.pkt_name = "SENDER_EVTREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSenderSysReqSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_sys_req;
                    m_tmp_pkt.pkt_name = "SENDER_SYSREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSenderSysRspRcvd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_sys_rsp;
                    m_tmp_pkt.pkt_name = "SENDER_SYSRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isSenderEventAckRcvd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_evt_ack;
                    m_tmp_pkt.pkt_name = "SENDER_EVTACK";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
        end
        if (m_ott_q[index].isRecieverSysReqRcvd) begin
            num_RecieverEvt++;
                m_pkt_order = {};
                if (m_ott_q[index].isRecieverEventReqNeeded || m_ott_q[index].isRecieverSysReqRcvd) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_sys_req_rcv;
                    m_tmp_pkt.pkt_name = "RECIEVER_SYSREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isRecieverEventReqSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_evt_req_rcv;
                    m_tmp_pkt.pkt_name = "RECIEVER_EVTREQ";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isRecieverEventAckSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_evt_ack_rcv;
                    m_tmp_pkt.pkt_name = "RECIEVER_EVTACK";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
                if (m_ott_q[index].isRecieverSysRspSent) begin
                    m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_sys_rsp_rcv;
                    m_tmp_pkt.pkt_name = "RECIEVER_SYSRSP";
                    m_pkt_order.push_back(m_tmp_pkt);
                end 
        end
        if (m_ott_q[index].isSnoop) begin
            if (t_min_snoop_transaction == 0ns) begin
                t_min_snoop_transaction                  = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                t_min_snoop_start_time                   = m_ott_q[index].t_creation;
                //m_min_snoop_addr                         = m_ott_q[index].m_ace_snoop_addr_pkt.acaddr;
                t_max_snoop_transaction                  = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                t_avg_snoop_transaction                  = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                t_min_sfi_snoop_to_ace_snoop_transaction = m_ott_q[index].t_ace_snoop_sent - m_ott_q[index].t_sfi_snp_req;
                t_max_sfi_snoop_to_ace_snoop_transaction = m_ott_q[index].t_ace_snoop_sent - m_ott_q[index].t_sfi_snp_req;
                t_avg_sfi_snoop_to_ace_snoop_transaction = m_ott_q[index].t_ace_snoop_sent - m_ott_q[index].t_sfi_snp_req;
            end
            else begin
                if (t_min_snoop_transaction > m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                    t_min_snoop_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                    t_min_snoop_start_time  = m_ott_q[index].t_creation;
                   // m_min_snoop_addr        = m_ott_q[index].m_ace_snoop_addr_pkt.acaddr;
                end
                if (t_max_snoop_transaction < m_ott_q[index].t_latest_update - m_ott_q[index].t_creation) begin
                    t_max_snoop_transaction = m_ott_q[index].t_latest_update - m_ott_q[index].t_creation;
                end
                t_avg_snoop_transaction = (t_avg_snoop_transaction * (num_snoops - 1) + m_ott_q[index].t_latest_update - m_ott_q[index].t_creation)/num_snoops;
                if (t_min_sfi_snoop_to_ace_snoop_transaction > m_ott_q[index].t_ace_snoop_sent - m_ott_q[index].t_sfi_snp_req) begin
                    t_min_sfi_snoop_to_ace_snoop_transaction = m_ott_q[index].t_ace_snoop_sent - m_ott_q[index].t_sfi_snp_req;
                    t_min_sfi_snoop_to_ace_snoop_start_time  = m_ott_q[index].t_creation;
                    m_min_sfi_snoop_to_ace_snoop_addr        = m_ott_q[index].m_ace_snoop_addr_pkt.acaddr;
                end
                if (t_max_sfi_snoop_to_ace_snoop_transaction < m_ott_q[index].t_ace_snoop_sent - m_ott_q[index].t_sfi_snp_req) begin
                    t_max_sfi_snoop_to_ace_snoop_transaction = m_ott_q[index].t_ace_snoop_sent - m_ott_q[index].t_sfi_snp_req;
                end
                t_avg_sfi_snoop_to_ace_snoop_transaction = (t_avg_sfi_snoop_to_ace_snoop_transaction * (num_snoops - 1) + m_ott_q[index].t_ace_snoop_sent - m_ott_q[index].t_sfi_snp_req)/num_snoops;
            end
            m_pkt_order = {};
            if (m_ott_q[index].isACESnoopReqSent) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_snoop_sent;
                m_tmp_pkt.pkt_name = "ACESNP";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
            if (m_ott_q[index].isACESnoopRespRecd) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_snoop_resp_recd;
                m_tmp_pkt.pkt_name = "ACESNPRSP";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
            if (m_ott_q[index].isACESnoopDataRecd) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_ace_snoop_data_recd;
                m_tmp_pkt.pkt_name = "ACESNPDATA";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
            if (m_ott_q[index].isSMISNPReqRecd) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_snp_req;
                m_tmp_pkt.pkt_name = "SNPREQ";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
            if (m_ott_q[index].isSMISNPRespSent) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_snp_rsp;
                m_tmp_pkt.pkt_name = "SNPRSP";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
            if (m_ott_q[index].isSMISNPDTRReqSent) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_req;
                m_tmp_pkt.pkt_name = "DTRREQ";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
            if (m_ott_q[index].isSMISNPDTRRespRecd) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtr_rsp;
                m_tmp_pkt.pkt_name = "DTRRSP";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
            if (m_ott_q[index].isSMIDTWReqSent) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_req;
                m_tmp_pkt.pkt_name = "DTWREQ";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
            if (m_ott_q[index].isSMIDTWRespRecd) begin
                m_tmp_pkt.t_pkt    = m_ott_q[index].t_sfi_dtw_rsp;
                m_tmp_pkt.pkt_name = "DTWRSP";
                m_pkt_order.push_back(m_tmp_pkt);
            end 
        end
       
<% } %>      

        if (m_pkt_order.size > 0) begin
            m_pkt_order.sort(x) with (x.t_pkt);
            m_ott_q[index].orderOfPkts = m_pkt_order[0].pkt_name;
            for (int i = 1; i < m_pkt_order.size(); i++) begin
                m_ott_q[index].orderOfPkts = {m_ott_q[index].orderOfPkts, "_", m_pkt_order[i].pkt_name};
            end
        end
        <%if(obj.COVER_ON) { %>
            `ifndef FSYS_COVER_ON
            if(!$test$plusargs("inject_smi_uncorr_error"))begin
            cov.collect_scb_txn(m_ott_q[index], core_id);
            end
            `endif
             <%if(obj.IO_SUBSYS_SNPS) { %> 
            if (ioaiu_cov_dis==0) begin
            cov.collect_scb_txn(m_ott_q[index], core_id);
            end
        <% } %>
<%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.useCache)) { %>
            `ifndef FSYS_COVER_ON
            cov.collect_shar_prom_ownr_txfr(m_ott_q[index], core_id);
            `endif
             <%if(obj.IO_SUBSYS_SNPS) { %> 
            if (ioaiu_cov_dis==0) begin
            cov.collect_shar_prom_ownr_txfr(m_ott_q[index], core_id);
            end
        <% } %>
<% } %>
        <% } %>
        <%if(obj.IO_SUBSYS_SNPS) { %> 
            if (ioaiu_cov_dis==0) begin
            cov.collect_scb_txn(m_ott_q[index], core_id);
            end
        <% } %>
        if(m_ott_q[index].m_ott_status==ALLOCATED) begin
           m_ott_q_cmpl.push_back(m_ott_q[index]);
        end

  <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>

         tmp_index_q= {};
         tmp_index_q = ace_cmd_addr_q.find_index() with ( ( item.m_addr[WAXADDR-1:0] == m_ott_q[index].m_sfi_addr[WAXADDR-1:0]) &&
                                                            item.m_cmdtype == m_ott_q[index].m_ace_cmd_type && 
                                                            (( m_ott_q[index].isRead ==1 && item.m_axdomain == m_ott_q[index].m_ace_read_addr_pkt.ardomain &&  
                                                               <% if (obj.wSecurityAttribute > 0) { %>
                                                                    (item.m_addr[WAXADDR] === m_ott_q[index].m_ace_read_addr_pkt.arprot[1])
                                                               <% } else {%>
                                                                    (item.m_addr[WAXADDR] === 0)
                                                               <%}%>
                                                             ) ||
                                                             ( m_ott_q[index].isRead ==0 && item.m_axdomain == m_ott_q[index].m_ace_write_addr_pkt.awdomain &&                                                                 <% if (obj.wSecurityAttribute > 0) { %>
                                                                    (item.m_addr[WAXADDR] === m_ott_q[index].m_ace_write_addr_pkt.awprot[1])
                                                               <% } else {%>
                                                                    (item.m_addr[WAXADDR] === 0)
                                                               <%}%>
                                                             )
                                                            )
                                                        );
         if(tmp_index_q.size() > 0) begin
         ace_cmd_addr_q.delete(tmp_index_q[0]); 
         end 
         <%}%>        
        m_ott_q.delete(index);
        ->e_queue_delete;
	end


    endfunction : delete_ott_entry

    //----------------------------------------------------------------------- 
    // Function to print queues
    //----------------------------------------------------------------------- 

    function void print_queues();
        if (m_ott_q.size() > 0) begin
            `uvm_info($sformatf("NCBU%0d SCB - IOAIU PENDING TXNS", m_req_aiu_id), $sformatf("Printing %0d OutstTxn queue entries:", m_ott_q.size()), UVM_NONE);
        end
        foreach(m_ott_q[i]) begin
	    uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("OutstTxn #%0d", i), UVM_NONE);
            m_ott_q[i].print_me(1);
        end
        if (m_oasd_q.size() > 0) begin
            uvm_report_info($sformatf("NCBU%0d SCB - IOAIU PENDING TXNS", m_req_aiu_id), $sformatf("Printing OASD queue entries:"), UVM_NONE);
        end
        foreach(m_oasd_q[i]) begin
            uvm_report_info($sformatf("NCBU%0d SCB - IOAIU PENDING TXNS", m_req_aiu_id), $sformatf("%s", m_oasd_q[i].sprint_pkt()), UVM_NONE);
        end
        if (m_oawd_q.size() > 0) begin
            uvm_report_info($sformatf("NCBU%0d SCB - IOAIU PENDING TXNS", m_req_aiu_id), $sformatf("Printing OAWD queue entries:"), UVM_NONE);
        end
        foreach(m_oawd_q[i]) begin
            uvm_report_info($sformatf("NCBU%0d SCB - IOAIU PENDING TXNS", m_req_aiu_id), $sformatf("%s", m_oawd_q[i].sprint_pkt()), UVM_NONE);
        end
        if (m_oancd_q.size() > 0) begin
            uvm_report_info($sformatf("NCBU%0d SCB - IOAIU PENDING TXNS", m_req_aiu_id), $sformatf("Printing OANCD queue entries:"), UVM_NONE);
        end
        foreach(m_oancd_q[i]) begin
            uvm_report_info($sformatf("NCBU%0d SCB - IOAIU PENDING TXNS", m_req_aiu_id), $sformatf("%s", m_oancd_q[i].sprint_pkt()), UVM_NONE);
        end


        if (m_mntop_q.size() > 0) begin
            uvm_report_info($sformatf("NCBU%0d SCB - IOAIU PENDING TXNS", m_req_aiu_id), $sformatf("Printing MntOp queue entries:"), UVM_NONE);
            
            foreach(m_mntop_q[i]) begin
	        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("MntOp #%0d", i), UVM_NONE);
                m_mntop_q[i].print_me(1);
            end
        end
        <%if(obj.useCache) { %>
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("-------------------Current Cache State--------------------"), UVM_NONE);
            for(int i=0;i<m_ncbu_cache_q.size;i++) begin
		m_ncbu_cache_q[i].print();		       
	    end

	<% }%>		     
    //	axi_cmdreq_id_vif.print_cmdreq_id_ar();
	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Printing axi_cmdreq_id_vif.axi_cmdreq_id_ar"),UVM_MEDIUM);
        foreach(axi_cmdreq_id_vif.axi_cmdreq_id_ar[i]) begin
	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("AxID:0x%0h SmiMsgId:0x%0h",axi_cmdreq_id_vif.axi_cmdreq_id_ar[i],i),UVM_MEDIUM);
	end

    endfunction : print_queues

    //#Check.IOAIU.DVMSnooper.SyncDVM
    task evaluate_dvm_completion();
        forever begin
            m_dvm_completed.wait_trigger();
            #1; // CONC-11411: waiting for delta cycle to let the dvm complete and cresp to settle before evaluation
            if(m_num_dvm_snp_compl > m_num_dvm_snp_sync_cr_resp) begin
	           `uvm_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR", $psprintf("DVM Complete (%1d) sent before CRResp (%1d) for DVM SYNC", m_num_dvm_snp_compl, m_num_dvm_snp_sync_cr_resp));
            end
            else begin
	           `uvm_info("IOAIU_SCB_<%=obj.BlockId%>", $psprintf("DVM Complete (%1d) in sync with CRResp (%1d) for DVM SYNC", m_num_dvm_snp_compl, m_num_dvm_snp_sync_cr_resp), UVM_NONE);
            end
        end
    endtask: evaluate_dvm_completion

    //----------------------------------------------------------------------- 
    // Function to check DVM CmdReq message fields 
    //----------------------------------------------------------------------- 
endclass : ioaiu_scoreboard

    //=========================================================================
    // Function: write_ccp_sp_output_chnl 
    // Purpose: 
    // 
    // 
    //=========================================================================
    function void ioaiu_scoreboard::write_apb_chnl(apb_pkt_t m_pkt);
        apb_pkt_t m_packet;
        m_packet = new();
        m_packet.copy(m_pkt);
                //#Check.IOAIU.CoreErrors
            <%if(obj.nNativeInterfacePorts > 1){ %>
		if (m_pkt.paddr[WPADDR-1:WPADDR-<%=Math.log2(obj.nNativeInterfacePorts)%>] != core_id) begin 
            <% } else {%>
		if (m_pkt.paddr[WPADDR-1:WPADDR-1] != core_id) begin 
            <%}%>
        	  //`uvm_info("IO-AIU Scoreboard", $psprintf("Drop since Apb packet does not belong to this core: %0s core_id %0d apb_addr lsb %0d",m_pkt.sprint_pkt(),core_id ,m_pkt.paddr[WPADDR-1:WPADDR-2]),UVM_LOW)
		end else begin 
        	processApbReq(m_packet);
		end 
    endfunction

    //------------------------------------------------------------------------------
    // process the APB channel packet
    //------------------------------------------------------------------------------
    function void ioaiu_scoreboard::processApbReq (apb_pkt_t apb_entry);
        string spkt;
        ioaiu_scb_txn m_mntop_pkt;
        int m_mnt_index;					     
        bit[31:0] mask = 32'hFFFF_FFFF;
        bit[31:0] calc_addr_mlr0, calc_addr_mlr1, calc_addr_mdr, calc_addr_mcr, calc_addr_tcr, calc_addr_cr, calc_addr_pctcr, calc_addr_qoscr; //Extract address from XAIUPCM* register per core id

       <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
       `ifdef VCS
        <% if(obj.useCache) {%>
        bit[63:0] XAIUPCMLR0_addr ;
        bit[63:0] XAIUPCMLR1_addr ;
        bit[63:0] XAIUPCMDR_addr  ;
        bit[63:0] XAIUPCMCR_addr  ;
        bit[63:0] XAIUPCTCR_addr  ;
        bit[63:0] XAIUQOSCR_addr  ;
       <% } %>
        bit[63:0] XAIUTCR_addr ;
        bit[63:0] XAIUCR_addr ;
       `endif // `ifdef VCS 
       <% } %>

       <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
       `ifdef VCS
        case(core_id)
        <%for (let i=0; i<obj.nNativeInterfacePorts; i++) {%>
        <%=i%> : begin
        <% if(obj.useCache) {%>
         XAIUPCMLR0_addr = <%=generateRegPath('XAIUPCMLR0.get_address()', i)%>;
         XAIUPCMLR1_addr = <%=generateRegPath('XAIUPCMLR1.get_address()', i)%>;
         XAIUPCMDR_addr  = <%=generateRegPath('XAIUPCMDR.get_address()', i)%>;
         XAIUPCMCR_addr  = <%=generateRegPath('XAIUPCMCR.get_address()', i)%>;
         XAIUPCTCR_addr  = <%=generateRegPath('XAIUPCTCR.get_address()', i)%>;
         XAIUQOSCR_addr  = <%=generateRegPath('XAIUQOSCR.get_address()', i)%>;
       <% } %>
         XAIUTCR_addr    = <%=generateRegPath('XAIUTCR.get_address()', i)%>;
         XAIUCR_addr     = <%=generateRegPath('XAIUCR.get_address()', i)%>;
        end
       <% } %>
        endcase
       `endif // `ifdef VCS 
       <% } %>
        `uvm_info("IO-AIU Scoreboard", $psprintf("Got_ApbReqPkt: %s",apb_entry.sprint_pkt() ),UVM_FULL)

        case(core_id)
            <%for (let i=0; i<obj.nNativeInterfacePorts; i++) {%>
            <%=i%> : begin
            	<% if(obj.useCache) {%>
               <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
               `ifndef VCS
                calc_addr_mlr0 	= <%=generateRegPath('XAIUPCMLR0.get_address()[11:0]', i)%> + (<%=i%>*4096);
                calc_addr_mlr1 	= <%=generateRegPath('XAIUPCMLR1.get_address()[11:0]', i)%> + (<%=i%>*4096);
                calc_addr_mdr 	= <%=generateRegPath('XAIUPCMDR.get_address()[11:0]', i)%> + (<%=i%>*4096);
                calc_addr_mcr 	= <%=generateRegPath('XAIUPCMCR.get_address()[11:0]', i)%> + (<%=i%>*4096);
                calc_addr_pctcr = <%=generateRegPath('XAIUPCTCR.get_address()[11:0]', i)%> + (<%=i%>*4096);
                calc_addr_qoscr = <%=generateRegPath('XAIUQOSCR.get_address()[11:0]', i)%> + (<%=i%>*4096);
               `else
                calc_addr_mlr0 	= XAIUPCMLR0_addr[11:0] + (<%=i%>*4096);
                calc_addr_mlr1 	= XAIUPCMLR1_addr[11:0] + (<%=i%>*4096);
                calc_addr_mdr 	= XAIUPCMDR_addr[11:0] + (<%=i%>*4096);
                calc_addr_mcr 	= XAIUPCMCR_addr[11:0] + (<%=i%>*4096);
                calc_addr_pctcr = XAIUPCTCR_addr[11:0] + (<%=i%>*4096);
                calc_addr_qoscr = XAIUQOSCR_addr[11:0] + (<%=i%>*4096);
               `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                calc_addr_mlr0 	= <%=generateRegPath('XAIUPCMLR0.get_address()[11:0]', i)%> + (<%=i%>*4096);
                calc_addr_mlr1 	= <%=generateRegPath('XAIUPCMLR1.get_address()[11:0]', i)%> + (<%=i%>*4096);
                calc_addr_mdr 	= <%=generateRegPath('XAIUPCMDR.get_address()[11:0]', i)%> + (<%=i%>*4096);
                calc_addr_mcr 	= <%=generateRegPath('XAIUPCMCR.get_address()[11:0]', i)%> + (<%=i%>*4096);
                calc_addr_pctcr = <%=generateRegPath('XAIUPCTCR.get_address()[11:0]', i)%> + (<%=i%>*4096);
               <% } %>
            	<%}%>
               <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
               `ifndef VCS
                calc_addr_tcr = <%=generateRegPath('XAIUTCR.get_address()[11:0]', i)%> + (<%=i%>*4096);
                calc_addr_cr  = <%=generateRegPath('XAIUCR.get_address()[11:0]', i)%> + (<%=i%>*4096);
               `else
                calc_addr_tcr = XAIUTCR_addr[11:0] + (<%=i%>*4096);
                calc_addr_cr  = XAIUCR_addr[11:0] + (<%=i%>*4096);
               `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                calc_addr_tcr = <%=generateRegPath('XAIUTCR.get_address()[11:0]', i)%> + (<%=i%>*4096);
               <% } %>
                end
            <%}%>
        endcase
        
        if(apb_entry.pwrite && apb_entry.paddr == calc_addr_tcr) begin  //USMCMLR00
            // XAIUTCR: Transaction control register
                <%var XAIUTCR = obj.AiuInfo[obj.Id].csr.spaceBlock[0].registers.find(register => register.name === 'XAIUTCR');
                var transordermode_rd = XAIUTCR.fields.find(field => field.name === 'TransOrderModeRd'); // enable CCP
                var transordermode_wr = XAIUTCR.fields.find(field => field.name === 'TransOrderModeWr'); // allocation in CCP enable
                var eventdis_rd       = XAIUTCR.fields.find(field => field.name === 'EventDisable'); // disable sys event  
                %>
				$cast(transOrderMode_wr, apb_entry.pwdata[<%=transordermode_wr.bitOffset+transordermode_wr.bitWidth-1%>:<%=transordermode_wr.bitOffset%>]);
				$cast(transOrderMode_rd, apb_entry.pwdata[<%=transordermode_rd.bitOffset+transordermode_rd.bitWidth-1%>:<%=transordermode_rd.bitOffset%>]);
				$cast(EventDis_rd, apb_entry.pwdata[<%=eventdis_rd.bitOffset+eventdis_rd.bitWidth-1%>:<%=eventdis_rd.bitOffset%>]);
        		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("C%0d For nativeInterface:<%=obj.fnNativeInterface%> Got_ApbReqPkt, transOrderMode_wr:%0s transOrderMode_rd:%0s EventDis_rd:%0d", core_id, transOrderMode_wr, transOrderMode_rd,EventDis_rd), UVM_LOW)

        end 
        if(apb_entry.pwrite && apb_entry.paddr == calc_addr_cr) begin  //USMCMLR00
            // XAIUCR: Transaction control register
                <%var XAIUCR = obj.AiuInfo[obj.Id].csr.spaceBlock[0].registers.find(register => register.name === 'XAIUCR');
                var ott_rd_pool = XAIUCR.fields.find(field => field.name === 'RD'); 
                var ott_wr_pool = XAIUCR.fields.find(field => field.name === 'WR'); 
                %>
	    
            $cast(OttRdPool, apb_entry.pwdata[<%=ott_rd_pool.bitOffset+ott_rd_pool.bitWidth-1%>:<%=ott_rd_pool.bitOffset%>]);
	    $cast(OttWrPool, apb_entry.pwdata[<%=ott_wr_pool.bitOffset+ott_wr_pool.bitWidth-1%>:<%=ott_wr_pool.bitOffset%>]);
            
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("C%0d For nativeInterface:<%=obj.fnNativeInterface%> Got_ApbReqPkt, OttRdPool:0x%0h OttWrPool:0x%0h", core_id, OttRdPool, OttWrPool), UVM_LOW)
        end 

		
        <% if(obj.useCache) {%>
		else if(apb_entry.pwrite && apb_entry.paddr == calc_addr_mlr0/*'h60*/) begin  //USMCMLR00
        `uvm_info("IO-AIU Scoreboard", $psprintf("paddr:%0h, calc_addr_mlr0:%0h, calc_addr_mlr1:%0h, mntEvictIndex=%0h  mntEvictRange=%0h", apb_entry.paddr, calc_addr_mlr0, calc_addr_mlr1, (((1<<<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length%>)-1) & apb_entry.pwdata[19:0]),  apb_entry.pwdata[31:16]),UVM_HIGH)

            mntEvictIndex = ((1<<<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length%>)-1) & apb_entry.pwdata[19:0];
            mntEvictWay   = apb_entry.pwdata[25:20];
            mntWord       = apb_entry.pwdata[31:26];
            mntEvictAddr  = apb_entry.pwdata << $clog2(SYS_nSysCacheline);

        end else if (apb_entry.pwrite && apb_entry.paddr == calc_addr_qoscr) begin

              <%var XAIUQOSCR = obj.AiuInfo[obj.Id].csr.spaceBlock[0].registers.find(register => register.name === 'XAIUQOSCR');
                var useEvictionQoS  = XAIUQOSCR.fields.find(field => field.name === 'useEvictionQoS');
                var EvictionQoS     = XAIUQOSCR.fields.find(field => field.name === 'EvictionQoS'); 
              %>
                
                csr_use_eviction_qos  = apb_entry.pwdata[<%=useEvictionQoS.bitOffset%>];
                csr_eviction_qos      = apb_entry.pwdata[<%=(EvictionQoS.bitOffset+EvictionQoS.bitWidth-1)%> : <%=EvictionQoS.bitOffset%>];
        
            `uvm_info("IO-AIU Scoreboard", $psprintf("Got_ApbReqPkt, useEvictionQoS:%0b EvictionQoS:0x%0h", csr_use_eviction_qos, csr_eviction_qos),UVM_LOW)

        end else if(apb_entry.pwrite && apb_entry.paddr == calc_addr_pctcr) begin// XAIUPCTCR OFFSET 
                // XAIUPCTCR: CCP control register
                <%var XAIUPCTCR = obj.AiuInfo[obj.Id].csr.spaceBlock[0].registers.find(register => register.name === 'XAIUPCTCR');
                var lookupen  = XAIUPCTCR.fields.find(field => field.name === 'LookupEn');  // enable CCP
                var allocen   = XAIUPCTCR.fields.find(field => field.name === 'AllocEn');   // allocation in CCP enable
                var updatedis = XAIUPCTCR.fields.find(field => field.name === 'UpdateDis'); // enable CCP
                %>
                
                csr_ccp_lookupen  = apb_entry.pwdata[<%=lookupen.bitOffset%>];
                csr_ccp_allocen   = apb_entry.pwdata[<%=allocen.bitOffset%>];
                csr_ccp_updatedis = apb_entry.pwdata[<%=updatedis.bitOffset%>];
        
        		`uvm_info("IO-AIU Scoreboard", $psprintf("Got_ApbReqPkt, UpdateDis:%0b LookupEn:%0b AllocEn:%0b", csr_ccp_updatedis, csr_ccp_lookupen, csr_ccp_allocen),UVM_LOW)

              <%if(obj.COVER_ON) { %>
                  `ifndef FSYS_COVER_ON
                  <%if(obj.useCache) { %>
                    cov.collect_ccp_control_reg(csr_ccp_lookupen, csr_ccp_allocen, csr_ccp_updatedis, core_id);
                  <% } %>
                  `endif
              <% } %>

	    end else if(apb_entry.pwrite && apb_entry.paddr == calc_addr_mlr1/*'h64*/) begin //USMCMLR10
           <% if((obj.Widths.Concerto.Ndp.Body.wAddr-obj.wCacheLineOffset) > 32) {%> 
            mntEvictAddr  = {apb_entry.pwdata[15:0],mntEvictAddr[37:0]}; <%}%>
            mntEvictRange = apb_entry.pwdata[31:16];
        end else if(apb_entry.paddr == calc_addr_mdr/*'h68*/) begin  //
            if(apb_entry.pwrite) mntDataWord   = apb_entry.pwdata;
            else  begin
                if(mntOpArrId) begin
                   mask &= ((mntWord & ((1<< <%=(5-Math.log2(512/obj.AiuInfo[obj.Id].ccpParams.wData))%>)-1)  ) == <%=Math.ceil(wDataArrayEntry/32)-1%> ) ? ((32'h1 << <%=(wDataArrayEntry%32)%>)-32'h1): 
                          (((mntWord & ((1<< <%=(5-Math.log2(512/obj.AiuInfo[obj.Id].ccpParams.wData))%>)-1)  ) == 0) ? ((32'h1 << <%=(32-wDataProt)%>)-32'h1)<< <%=wDataProt%> :  mask); // Mask 1 bit as SCB unable to calculate ECC
                end else begin
                <% if (Math.ceil(wTagArrayEntry/32)-1) { %> 
                   mask &= (mntWord == <%=Math.ceil(wTagArrayEntry/32)-1%> ) ? ((32'h1 << <%=(wTagArrayEntry%32)%>)-32'h1): 
                          ((mntWord == 0) ? ((32'h1 << <%=(32-wTagProt-1)%>)-32'h1)<< <%=wTagProt+1%> :mask); // Compare only Tag+State, skip RP and ECC
                <% } else if (wTagArrayEntry == 32) { %>
                   mask &= ((32'h1 << <%=(32 - wTagProt - wRP)%>)-32'h1) << <%=wTagProt+wRP%>; // Compare only Tag+State, skip RP and ECC
                <% } else { %>
                   mask &= ((32'h1 << <%=((wTagArrayEntry - wTagProt - wRP)%32)%>)-32'h1) << <%=wTagProt+wRP%>; // Compare only Tag+State, skip RP and ECC
                <% } %>
                end
                //#Cover.IOAIU.CCPCtrlPkt.EvictWay
                if(!mntOpArrId) begin // TagArray
                    if((mntOpType == 'hC)&&((get_word_tag_array(mntEvictIndex, mntEvictWay, mntWord) & mask) !== (apb_entry.prdata & mask))) begin // DebugRd on TagArray
	                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Got MntOpRddata:0x%0x Exp: 0x%0x mask: 0x%0x",apb_entry.prdata,get_word_tag_array(mntEvictIndex, mntEvictWay, mntWord),mask),UVM_NONE);
	                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Got MntOpRddata:0x%0x Exp: 0x%0x mask: 0x%0x",apb_entry.prdata,get_word_tag_array(mntEvictIndex, mntEvictWay, mntWord),mask),UVM_NONE);
                    end
                end else begin // DataArray
                    if((mntOpType == 'hC)&&((get_word_data_array(mntEvictIndex, mntEvictWay, mntWord) & mask) !== (apb_entry.prdata & mask))) begin // DebugRd on DataArray
                        bit[5:0] wordMatch=0;
                        for(bit[5:0] i =0;i< <%=Math.ceil(wDataArrayEntry/32)%>;i++)
                            if((get_word_data_array(mntEvictIndex, mntEvictWay, {i[1:0],mntWord[2:0]}) & mask) == (apb_entry.prdata & mask)) begin
                               wordMatch = {i[1:0],mntWord[2:0]};
                               break;
                            end
	                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Got MntOpRddata:0x%0x Exp: 0x%0x mask: 0x%0x word:%0x wordMatch:%0x",apb_entry.prdata,get_word_data_array(mntEvictIndex, mntEvictWay, mntWord),mask,mntWord,wordMatch),UVM_NONE);
	                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Got MntOpRddata:0x%0x Exp: 0x%0x mask: 0x%0x (mntEvictIndex:0x%0x mntEvictWay:0x%0x mntWord:0x%0x wordMatch:%0x)",apb_entry.prdata,get_word_data_array(mntEvictIndex, mntEvictWay, mntWord),mask,mntEvictIndex, mntEvictWay, mntWord, wordMatch),UVM_NONE);
                    end
                end
            end
        end else if (apb_entry.pwrite && apb_entry.paddr == calc_addr_mcr/*'h58*/) begin  //USMCMCR0 Reg
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Got_ApbReqPkt Maintenance Control register : %s",apb_entry.sprint_pkt() ),UVM_LOW)

            if(hasActiveMntOp() || (m_mntop_q.size() > 0)) begin
	            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Got MntOp while another MntOp(s) {Nos of MntOp(s)=%0d} is active! %s",m_mntop_q.size(),apb_entry.sprint_pkt()),UVM_NONE);
	            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Got MntOp while another MntOp is active!"),UVM_NONE);
            end
            mntOpType = apb_entry.pwdata[3:0];
            mnt_PcSecAttr = apb_entry.pwdata[22];
            mntOpArrId = apb_entry.pwdata[16];
            if (mntOpType == 'h6) begin
               m_mntop_pkt                  = new(,m_req_aiu_id);
               m_mntop_pkt.isMntOp          = 1;
               m_mntop_pkt.mntop_addr       = mntEvictAddr;
               m_mntop_pkt.mntop_security   = mnt_PcSecAttr;
               m_mntop_pkt.m_mntop_cmd_type = MNTOP_FLUSH_BY_ADDR;
               m_mntop_pkt.t_creation       = $time;
               m_mntop_pkt.t_latest_update  = $time;
               m_mntop_q.push_back(m_mntop_pkt);
               ->e_queue_add;    

               spkt = {"FlushAddr:%0h MntOpType:%0d, Security:%0d"};
               `uvm_info("GOT_MNT_OP_BY_ADDR", $psprintf(spkt,mntEvictAddr,mntOpType,mnt_PcSecAttr),UVM_MEDIUM)
            end else if(mntOpType == 'h7) begin
                spkt = {"FlushAddr:%0h MntOpType:%0d, Security:%0d, Range: %d"};
                `uvm_info("GOT_MNT_OP_BY_ADDR_RANGE", $psprintf(spkt,mntEvictAddr,mntOpType,mnt_PcSecAttr,
                           mntEvictRange),UVM_NONE)
                if(mntEvictRange == 0)  mntEvictRange = 17'h1_0000;
                for (int i=0; i<mntEvictRange; i++) begin
                    m_mntop_pkt                  = new(,m_req_aiu_id);
                    m_mntop_pkt.isMntOp          = 1;
                    m_mntop_pkt.mntop_addr       = mntEvictAddr;
                    m_mntop_pkt.mntop_security   = mnt_PcSecAttr;
                    m_mntop_pkt.m_mntop_cmd_type = MNTOP_FLUSH_BY_ADDR_RANGE;
                    m_mntop_pkt.t_creation       = $time;
                    m_mntop_pkt.t_latest_update  = $time;
                    m_mntop_q.push_back(m_mntop_pkt);
                    ->e_queue_add;				     
                    mntEvictAddr = mntEvictAddr + 64;

                end
    
            end else if(mntOpType == 'h8) begin
                for (int i=0; i<mntEvictRange; i++) begin
                    m_mntop_pkt = new(,m_req_aiu_id);
                    m_mntop_pkt.isMntOp = 1;
                    m_mntop_pkt.mntop_index = mntEvictIndex;
                    m_mntop_pkt.mntop_way   = mntEvictWay;
                    m_mntop_pkt.m_mntop_cmd_type = MNTOP_FLUSH_BY_INDEX_RANGE;
                    m_mntop_pkt.t_creation     = $time;
                    m_mntop_pkt.t_latest_update = $time;
                    m_mntop_q.push_back(m_mntop_pkt);
                    ->e_queue_add;
		            mntEvictWay  = mntEvictWay  + 1'b1;
    
                    if (mntEvictWay == <%=obj.nWays%>) begin
                        mntEvictWay   = 0;
                        mntEvictIndex = mntEvictIndex + 1;
                    end
    
                    if (mntEvictIndex == <%=(obj.AiuInfo[obj.Id].ccpParams.nSets/obj.nNativeInterfacePorts)%>) begin
                        mntEvictIndex = 0;
                    end
    
                end
    
                spkt = {"FlushIndex:%0h FlushWay:%0h MntOpType:%0h, Range:%0h"};
                `uvm_info("GOT_MNT_OP_BY_INDEX_RANGE", $psprintf(spkt,mntEvictIndex,mntEvictWay,mntOpType,
                           mntEvictRange),UVM_MEDIUM)
            end else if (mntOpType == 'h5) begin
                m_mntop_pkt = new(,m_req_aiu_id);
                m_mntop_pkt.isMntOp = 1;
                m_mntop_pkt.mntop_index = mntEvictIndex;
                m_mntop_pkt.mntop_way   = mntEvictWay;
                m_mntop_pkt.m_mntop_cmd_type = MNTOP_FLUSH_BY_INDEX;
                m_mntop_pkt.t_creation     = $time;
                m_mntop_pkt.t_latest_update = $time;
                m_mntop_q.push_back(m_mntop_pkt);
                ->e_queue_add;
                spkt = {"FlushIndex:%0d FlushWay:%0d MntOpType:%0d"};
                `uvm_info("GOT_FLUSH_BY_INDEX", $psprintf(spkt,mntEvictIndex,mntEvictWay,mntOpType),UVM_MEDIUM)
                if(this.get_report_verbosity_level() >= UVM_MEDIUM) begin
                    m_mntop_pkt.print_me();
                end

            end else if (mntOpType == 'hC) begin 
                m_mntop_pkt = new(,m_req_aiu_id);
                m_mntop_pkt.isMntOp = 1;
                m_mntop_pkt.mntop_index = mntEvictIndex;
                m_mntop_pkt.mntop_way   = mntEvictWay;
                m_mntop_pkt.mntop_word  = mntWord;
                m_mntop_pkt.mntop_ArrayId = mntOpArrId;
                m_mntop_pkt.m_mntop_cmd_type = MNTOP_DEBUG_READ;
                m_mntop_pkt.t_creation     = $time;
                m_mntop_pkt.t_latest_update = $time;
                m_mntop_q.push_back(m_mntop_pkt);
                ->e_queue_add;
                spkt = {"ReadIndex:%0d ReadWay:%0d ReadWord:%0d MntOpType:%0d"};
                `uvm_info("GOT_DEBUG_READ", $psprintf(spkt,mntEvictIndex,mntEvictWay,mntWord,mntOpType),UVM_MEDIUM)
                if(this.get_report_verbosity_level() >= UVM_MEDIUM) begin
                    m_mntop_pkt.print_me();
                end
                            
            end else if (mntOpType == 'hE) begin
                m_mntop_pkt = new(,m_req_aiu_id);
                m_mntop_pkt.isMntOp = 1;
                m_mntop_pkt.mntop_index = mntEvictIndex;
                m_mntop_pkt.mntop_way   = mntEvictWay;
                m_mntop_pkt.mntop_word  = mntWord;
                m_mntop_pkt.mntop_ArrayId = mntOpArrId;
                m_mntop_pkt.mntop_Dataword  = mntDataWord;
                m_mntop_pkt.m_mntop_cmd_type = MNTOP_DEBUG_WRITE;
                m_mntop_pkt.t_creation     = $time;
                m_mntop_pkt.t_latest_update = $time;
                m_mntop_q.push_back(m_mntop_pkt);
                ->e_queue_add;
                spkt = {"WriteIndex:%0d WriteWay:%0d WriteWord:%0d MntOpType:%0d"};
                `uvm_info("GOT_DEBUG_WRITE", $psprintf(spkt,mntEvictIndex,mntEvictWay,mntWord,mntOpType),UVM_MEDIUM)
                if(this.get_report_verbosity_level() >= UVM_MEDIUM) begin
                    m_mntop_pkt.print_me();
                end
                if(!mntOpArrId) begin // TagArray
                    if (!$test$plusargs("disable_mnt_op_set_word_tag_and_data_methods")) begin
                        set_word_tag_array(mntEvictIndex, mntEvictWay, mntWord, mntDataWord); // DebugWr on TagArray
                    end
                end else begin // DataArray
                    if (!$test$plusargs("disable_mnt_op_set_word_tag_and_data_methods")) begin
                        set_word_data_array(mntEvictIndex, mntEvictWay, mntWord, mntDataWord); // DebugWr on DataArray
                    end
                end
            end else if(mntOpType == 'h4) begin
                for(int i=0; i < <%=(obj.AiuInfo[obj.Id].ccpParams.nSets/obj.nNativeInterfacePorts)%>; i++) begin
                    for(int m=0; m< <%=obj.nWays%>; m++) begin
                        m_mntop_pkt = new(,m_req_aiu_id);
                        m_mntop_pkt.isMntOp = 1;
                        m_mntop_pkt.mntop_index = mntEvictIndex+i & ((1<<<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length%>)-1);
                        m_mntop_pkt.mntop_way   = m;
                        m_mntop_pkt.m_mntop_cmd_type = MNTOP_FLUSH_ALL;
                        m_mntop_pkt.t_creation     = $time;
                        m_mntop_pkt.t_latest_update = $time;
                        m_mntop_q.push_back(m_mntop_pkt);
                        ->e_queue_add;
                    end
                end
                cache_q_size =  m_ncbu_cache_q.size();
                spkt = {"MntOp Flush All operation programmed"};
                `uvm_info("GOT_MNT_OP_FLUSH_ALL",spkt,UVM_NONE)
            end 
         end
    <%}%>

    endfunction // processApbReq

//----------------------------------------------------------------------- 
// Q Channel
//----------------------------------------------------------------------- 
function void ioaiu_scoreboard::write_q_chnl(q_chnl_seq_item m_pkt);
  q_chnl_seq_item m_packet;
  q_chnl_seq_item m_packet_tmp;
  ioaiu_scb_txn     txn;
  m_packet = new();

  $cast(m_packet_tmp, m_pkt);
  m_packet.copy(m_packet_tmp);

  `uvm_info("Q_Channel_resp_chnl", $sformatf("Entered..."), UVM_HIGH)
  //If power_down request has been accepted, at that time no outstanding transaction should be there
  if(m_packet.QACCEPTn == 'b0 && m_packet.QREQn == 'b0 && m_packet.QACTIVE == 'b0) begin
    `uvm_info("Q_Channel_resp_chnl", $sformatf("Q_Channel : Checking WTT and RTT Queue should be empty when Q Channel Req receives Accept."), UVM_HIGH)
    if (m_ott_q.size != 0) begin
      `uvm_error("<%=obj.BlockId%>:print_m_ott_q", $sformatf("Command queue is not empty when rtl asserted QACCEPTn"))
    end
    else begin
      `uvm_info("<%=obj.BlockId%>:print_m_ott_q", $sformatf("Command queue is empty"), UVM_MEDIUM)
    end
  end
endfunction : write_q_chnl



////////////////////////////////////////////////////////////////////////////////
//                                                                            
//          CCP related write function
//                                                                            
// 
//
// 
////////////////////////////////////////////////////////////////////////////////

<% if(obj.useCache){ %>
    
//=========================================================================
// Function: write_ncbu_ccp_wr_data_chnl 
// Purpose: 
// 
// 
//=========================================================================
function void ioaiu_scoreboard::write_ncbu_ccp_wr_data_chnl(ccp_wr_data_pkt_t m_pkt);
    ccp_wr_data_pkt_t  cpy_pkt;
    ccp_wr_data_pkt_t  cpy_pkt_tmp;
    int                 m_tmp_q[$];
    int                 m_tmp_q_fatal_err[$];
    int                 m_tmp_q_tag_err[$];
    string              spkt;
    int                 m_ccp_index;
    ccp_ctrlwr_data_t   ccp_wr_hit_data[];
    int                 ccp_wr_hit_beat[];
    if(hasErr)
     return;
    cpy_pkt       = new();
    $cast(cpy_pkt_tmp,m_pkt); 
    cpy_pkt.copy(cpy_pkt_tmp);
    prev_ctrl_pkt.posedge_count=0;
    //#Check.IOAIU.CCP.NoWrDataBeforeSTRReq
    //#Check.IOAIU.CCP.WrDataExpected		     
    //#Check.IOAIU.CCPCtrlPkt.WrData
    m_tmp_q = {}; 
    m_tmp_q = m_ott_q.find_index() with (((item.isIoCacheTagPipelineSeen) ?
					    ((item.m_ccp_ctrl_pkt.wr_data === 1) &&
					     (item.m_ccp_ctrl_pkt.lookup_p2 === 0) &&
					     (item.isWriteHitFull() ||
              			             (!item.isCoherent && item.is_ccp_hit) ||
					     ((item.m_ccp_ctrl_pkt.write_miss_allocate === 1)
					        &&
					      (item.isPartialWrite === 0) &&
					      (item.isFillCtrlRcvd === 0)))):
					  0)        &&
                                        item.isIoCacheDataPipelineSeen == 0   &&
                                        item.isCCPWriteHitDataRcvd     == 0   &&
                                        item.isWrite                   == 1 
					 );
    if(m_tmp_q.size() >= 1) begin							   
//    if(m_tmp_q.size()==1) begin
      if(m_tmp_q.size()>1)
	m_tmp_q[0] = find_oldest_ccp_lookup_q(m_tmp_q);
    
        m_ott_q[m_tmp_q[0]].setup_io_cache_write_data(cpy_pkt);


        //Check the fill data
        convert_agent_data_to_ccp_data(m_ott_q[m_tmp_q[0]].m_ace_write_data_pkt.wdata,
                                 m_ott_q[m_tmp_q[0]].m_sfi_addr,m_tmp_q[0],
                                 ccp_wr_hit_data, ccp_wr_hit_beat);
        //#Check.IOAIU.CCP.WrDataData
        if(cpy_pkt.data.size()>0) begin
            if(aiu_double_bit_errors_enabled) begin
                foreach (ccp_wr_hit_data[i]) begin
                    if ((ccp_wr_hit_data[i] !== cpy_pkt.data[i]) && (cpy_pkt.poison[i]==0)) begin
                        m_ott_q[m_tmp_q[0]].print_me(0,1);
                        spkt = {"(Beat:0x%0x Agent wSmiDPdata:0x%0x Fill:0x%0x Poison:0x%0d) OutstTxn #%0d"};
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$psprintf(spkt,i,cpy_pkt.data[i],ccp_wr_hit_data[i], cpy_pkt.poison[i],m_tmp_q[0]),UVM_NONE)
                        spkt = $sformatf("Incorrect write-hit data");
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
                    end
                end

                foreach (ccp_wr_hit_beat[i]) begin
                    if (ccp_wr_hit_beat[i] !== cpy_pkt.beatn[i]) begin
                        m_ott_q[m_tmp_q[0]].print_me(0,1);
                        spkt = {"(Got Beat:0x%0x but Exp Beat:0x%0x OutstTxn #%0d"};
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$psprintf(spkt,cpy_pkt.beatn[i],ccp_wr_hit_beat[i],m_tmp_q[0]),UVM_NONE)
                        spkt = {"Incorrect write-hit beat"};
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
                    end
                end

            end else begin
                //#Check.IOAIU.CCPCtrlPkt.WrDataPoison
                foreach (ccp_wr_hit_data[i]) begin
                    if ((ccp_wr_hit_data[i] !== cpy_pkt.data[i]) && (cpy_pkt.poison[i] !== 0)) begin
                        // This could result due to uncorr error injection in OTT also, so taking care below
                        if(!uncorr_OTT_Data_Err_effect) begin // uncorr_OTT_Data_Err_effect = 0 : Error is expected
                            uncorr_OTT_Data_Err_effect = 3 ;// Corruption in : w_odw_rdata -> (CCP write data will be affected) : Poison bit set for one of the beat in CCP wr Data
                        end else begin
                            m_ott_q[m_tmp_q[0]].print_me(0,1);
                            spkt = {"(Beat:0x%0x Agent wSmiDPdata:0x%0x Fill:0x%0x OutstTxn #%0d"};
                            `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$psprintf(spkt,i,cpy_pkt.data[i],ccp_wr_hit_data[i],m_tmp_q[0]),UVM_NONE)
                            spkt = {"(Got Poison:0x%0x but Exp Poison:0x%0x"};
                            `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$psprintf(spkt,cpy_pkt.poison[i],1),UVM_NONE)
                            spkt = {"Incorrect write-hit data and poison bit. Poison bit shouldn't",
                                    " be asserted for a write-hit txn."};
                            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
                        end
                    end else begin
                    if (ccp_wr_hit_data[i] !== cpy_pkt.data[i] && !m_ott_q[m_tmp_q[0]].hasFatlErr) begin // Not checking ccp data when str_req.cmstatus indicates error CONC-7622
                        m_ott_q[m_tmp_q[0]].print_me(0,1);
                        spkt = {"(Beat:0x%0x Agent wSmiDPdata:0x%0x Fill:0x%0x OutstTxn #%0d"};
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$psprintf(spkt,i,cpy_pkt.data[i],ccp_wr_hit_data[i],m_tmp_q[0]),UVM_NONE)
                        spkt = {"Incorrect write-hit data"};
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
                    end
                    if (cpy_pkt.poison[i] !== 0) begin
                        m_ott_q[m_tmp_q[0]].print_me(0,1);
                        spkt = {"(Got Poison:0x%0x but Exp Poison:0x%0x"};
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$psprintf(spkt,cpy_pkt.poison[i],0),UVM_NONE)
                        spkt = {"Incorrect write-hit poison bit. Poison bit shouldn't",
                                " be asserted for a write-hit txn."};
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
                    end
                    end
                end
                
                //#Check.IOAIU.CCPCtrlPkt.WrDataByteEn
                foreach (ccp_wr_hit_beat[i]) begin
                    if (ccp_wr_hit_beat[i] !== cpy_pkt.beatn[i]) begin
                        m_ott_q[m_tmp_q[0]].print_me(0,1);
                        spkt = {"(Got Beat:0x%0x but Exp Beat:0x%0x OutstTxn #%0d"};
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$psprintf(spkt,cpy_pkt.beatn[i],ccp_wr_hit_beat[i],m_tmp_q[0]),UVM_NONE)
                        spkt = {"Incorrect write-hit beat"};
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
                    end
                end
            end
        end else begin
            spkt = {"Monitor crapped out recieved fill data will null size."};
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end
	//CONC-4311						   
	if ((m_ott_q[m_tmp_q[0]].m_ccp_ctrl_pkt.write_miss_allocate === 1) &&
	    (m_ott_q[m_tmp_q[0]].isPartialWrite === 0) &&
	    (m_ott_q[m_tmp_q[0]].isFillCtrlRcvd === 0)) begin
	   m_ott_q[m_tmp_q[0]].isFillReqd = 0;
	end
							   
        if (m_ott_q[m_tmp_q[0]].isWrite && 
           ((m_ott_q[m_tmp_q[0]].is_ccp_hit === 1) || (m_ott_q[m_tmp_q[0]].is_write_hit_upgrade && !m_ott_q[m_tmp_q[0]].isPartialWrite)) &&
           ((m_ott_q[m_tmp_q[0]].isACEWriteRespSent === 1) ||
            (m_ott_q[m_tmp_q[0]].isMultiAccess && !m_ott_q[m_tmp_q[0]].isMultiLineMaster ? m_ott_q[m_tmp_q[0]].multiline_ready_to_delete:0))
           &&
           (m_ott_q[m_tmp_q[0]].isMultiAccess ? m_ott_q[m_tmp_q[0]].multiline_ready_to_delete:1)
        ) begin
            delete_ott_entry(m_tmp_q[0], IOCData);
        end else begin
            if(m_ott_q[m_tmp_q[0]].isMultiAccess &&  !m_ott_q[m_tmp_q[0]].multiline_ready_to_delete) begin
                m_ott_q[m_tmp_q[0]].multiline_ready_to_delete = 1;
            end
        end
    end else begin
        m_tmp_q_fatal_err = {}; 
        m_tmp_q_tag_err = {}; 
        if (m_ott_q_fatal_err.size() > 0 || m_ott_q_tag_err.size() > 0) begin
          m_tmp_q_fatal_err = m_ott_q_fatal_err.find_index() with (((item.isIoCacheTagPipelineSeen) ?
              				                       ((item.m_ccp_ctrl_pkt.wr_data === 1) &&
              				                       (item.m_ccp_ctrl_pkt.lookup_p2 === 0) &&
              				                       (item.isWriteHitFull() ||
              				                       ((item.m_ccp_ctrl_pkt.write_miss_allocate === 1)
              				                       &&
              				                       (item.isPartialWrite === 0) &&
              				                       (item.isFillCtrlRcvd === 0)))): 0)          &&
//                                                                item.isIoCacheTagPipelineSeen  == 1   &&
                                                                  item.isIoCacheDataPipelineSeen == 0   &&
                                                                  item.isCCPWriteHitDataRcvd     == 0   &&
                                                                  item.isWrite                   == 1   //&&
//                                                                item.is_ccp_hit                == 1 || 
					                       );
          m_tmp_q_tag_err = m_ott_q_tag_err.find_index() with (((item.isIoCacheTagPipelineSeen) ?
              				                       ((item.m_ccp_ctrl_pkt.wr_data === 1) &&
              				                       (item.m_ccp_ctrl_pkt.lookup_p2 === 0) &&
              				                       (item.isWriteHitFull() ||
              				                       ((item.m_ccp_ctrl_pkt.write_miss_allocate === 1)
              				                       &&
              				                       (item.isPartialWrite === 0) &&
              				                       (item.isFillCtrlRcvd === 0)))): 0)          &&
//                                                                item.isIoCacheTagPipelineSeen  == 1   &&
                                                                  item.isIoCacheDataPipelineSeen == 0   &&
                                                                  item.isCCPWriteHitDataRcvd     == 0   &&
                                                                  item.isWrite                   == 1   //&&
//                                                                item.is_ccp_hit                == 1 || 
					                       );

          if(m_tmp_q_fatal_err.size()>1) begin
            m_tmp_q_fatal_err[0] = find_oldest_ccp_lookup_q(m_tmp_q_fatal_err);
            m_ott_q_fatal_err[m_tmp_q_fatal_err[0]].setup_io_cache_write_data(cpy_pkt); // To make sure ccp write hit data pkt receves only once in case of str_req.cmstatus error occurs and after deleting OTT entry.
            return;
          end else if(m_tmp_q_fatal_err.size() == 1) begin 
            m_ott_q_fatal_err[m_tmp_q_fatal_err[0]].setup_io_cache_write_data(cpy_pkt); // To make sure ccp write hit data pkt receves only once in case of str_req.cmstatus error occurs and after deleting OTT entry.
            return;
          end
          if(m_tmp_q_tag_err.size()>1) begin
            m_tmp_q_tag_err[0] = find_oldest_ccp_lookup_q(m_tmp_q_tag_err);
            m_ott_q_tag_err[m_tmp_q_tag_err[0]].setup_io_cache_write_data(cpy_pkt); // To make sure ccp write hit data pkt receves only once in case of str_req.cmstatus error occurs and after deleting OTT entry.
            return;
          end else if(m_tmp_q_tag_err.size() == 1) begin 
            m_ott_q_tag_err[m_tmp_q_tag_err[0]].setup_io_cache_write_data(cpy_pkt); // To make sure ccp write hit data pkt receves only once in case of str_req.cmstatus error occurs and after deleting OTT entry.
            return;
          end
        end
        //#Check.IOAIU.CCPCtrlPkt.MatchingTxn
        if (m_tmp_q_fatal_err.size() == 0) begin
          spkt = "Cannot find any matching pkt for the incoming ccp write hit data pkt";
	  `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s %s",spkt,cpy_pkt.sprint_pkt()),UVM_NONE)
          `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end
    end

endfunction:write_ncbu_ccp_wr_data_chnl


//=========================================================================
// Function: write_ncbu_ccp_ctrl_chnl 
// Purpose: 
// 
// 
// Notes :
//       There are many corner cases that arise due to STR,DTR,DTW request
//       seen by the NCBU checker earlier than the DUT.
//=========================================================================
function void ioaiu_scoreboard::write_ncbu_ccp_ctrl_chnl(ccp_ctrl_pkt_t m_pkt);
    
    axi_axaddr_t m_ccp_addr;
    ccp_ctrl_pkt_t             cpy_pkt;
    ccp_ctrl_pkt_t             cpy_pkt_tmp;
    ioaiu_scb_txn              m_scb_txn;
    ioaiu_scb_txn              m_ccp_ctrl_p1_pkt;
    ioaiu_scb_txn              temp_mntop_pkt;
    int                        m_tmp_q[$],m_tmp_qA[$];
    int                        m_find_q[$];
    int                        m_search_q[$];
    int                        m_search_pending_way_q[$];
    int                        m_sleep_q[$];
    int                        found_index;
    int                        txn_index;
    string                     spkt,s;
    int                        m_ccp_index,m_mnt_index;
    bit                        check_fail;
    time                       start_time;
    ccp_ctrlop_waybusy_vec_t  exp_pending_vec,exp_set_pending_bits,act_set_pending_bits;
    ccp_ctrlop_waystale_vec_t  way_stale_vec;
    ccp_cache_hit_wayn_t       true_hit_way_vec;

    bit                        dec_fake_hit;
    int                        burst_length;
    bit tb_read_hit;
    bit tb_read_miss_allocate;
    bit tb_write_hit;
    bit tb_write_miss_allocate;
    bit tb_snoop_hit;
    bit tb_write_hit_upgrade;
    int dec_hit_way_num;
    bit [N_CCP_WAYS-1:0] hitway_vec;

    ccp_ctrlwr_data_t   ccp_wr_hit_data[];
    int                 ccp_wr_hit_beat[];
    int offset = SYS_wSysCacheline;
    if(hasErr)
     	return;

    //Copy the pkt locally
    cpy_pkt       = new();
    $cast(cpy_pkt_tmp,m_pkt); 
    cpy_pkt.copy(cpy_pkt_tmp);

    //Calculate Tag and Index
    m_ccp_addr   = shift_addr(cpy_pkt.addr);
    m_ccp_index = addrMgrConst::get_set_index(cpy_pkt.addr,<%=obj.FUnitId%>);
    
    if (cpy_pkt.nackuce) begin
        uncorr_CCP_Tag_Err_effect = 1;
	uncorr_CCP_Tag_Err_cacheline_addr_w_sec = {cpy_pkt.security, m_ccp_addr};
    end

    //Match the CCP packet with outstanding ACE agent pkt
    //#Check.IOAIU.CCPCtrlPkt.MatchingTxn
    if(cpy_pkt.isRead && !cpy_pkt.isMntOp) begin
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index() with (
					    item.m_id                 	  == m_pkt.pt_id      &&
                                            item.ccp_addr                 == m_ccp_addr       &&
                                            item.ccp_index                == m_ccp_index      &&
                                            item.m_security               == cpy_pkt.security &&
                                            item.isAddrBlocked            == 0                &&
                                            item.isCCPCancelSeen          == 0                &&
 					    ((item.isIoCacheTagPipelineNeeded) ? item.isIoCacheTagPipelineSeen == 0 : 0)       &&
                                            item.isRead                   == 1                
                                            );
            
      
         <% if(obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED"){%>
         if (cpy_pkt.nackce == 0 && $test$plusargs("always_inject_corr_error")) begin
            check_bypass_flag=1;
          end
         <%}%>
        if(!cpy_pkt.nack && (m_tmp_q.size()==0) && m_pkt.t_pt_err == 0) begin
            spkt = $sformatf("Case Rd: Cannot find any matching pkt for the incoming ccp ctrl pkt %s", cpy_pkt.sprint_pkt());
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end
    end else if(cpy_pkt.isRead_Wakeup && !cpy_pkt.isMntOp) begin
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index() with (
					    item.m_id                     == m_pkt.pt_id      &&
                                            item.ccp_addr                 == m_ccp_addr       &&
                                            item.ccp_index                == m_ccp_index      &&
                                            item.m_security               == cpy_pkt.security &&
                                            ((item.isIoCacheTagPipelineSeen) ?
				            ((item.m_ccp_ctrl_pkt.lookup_p2 === 1) && (item.m_ccp_ctrl_pkt.cancel  || item.m_ccp_ctrl_pkt.read_hit) && (item.isFillReqd === 0)):
					    ((item.isAddrBlocked          == 1)               &&
                                            (item.isCCPCancelSeen         == 1)))             &&
                                            item.isRead                   == 1                
                                            );
        if(!cpy_pkt.nack && (m_tmp_q.size()==0) && m_pkt.t_pt_err == 0) begin
            spkt = $sformatf("Case Rd_Wakeup: Cannot find any matching pkt for the incoming ccp ctrl pkt %s",cpy_pkt.sprint_pkt());
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end
    end else if (cpy_pkt.isWrite && !cpy_pkt.isMntOp) begin
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index() with (
					                        item.m_id                     == m_pkt.pt_id      &&
                                            item.ccp_addr                 == m_ccp_addr       &&
                                            item.ccp_index                == m_ccp_index      &&
                                            item.m_security               == cpy_pkt.security &&
                                            item.m_sfi_addr               == cpy_pkt.addr     &&
                                            !item.isACEWriteRespSent                          &&
                                            item.isAddrBlocked            == 0                &&
                                            item.isCCPCancelSeen          == 0                &&
 											((item.isIoCacheTagPipelineNeeded) ? item.isIoCacheTagPipelineSeen == 0 : 0)     &&
                                            ((item.isWrite && item.isACEWriteDataNeeded) ? item.isACEWriteDataRecd == 1 : 1) &&
                                            item.isWrite                  == 1                
                                            );
        if(!cpy_pkt.nack && (m_tmp_q.size()==0) && m_pkt.t_pt_err == 0) begin           
            spkt = $sformatf("Case Wr: Cannot find any matching pkt for the incoming ccp ctrl pkt %s",cpy_pkt.sprint_pkt());
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end
    end else if (cpy_pkt.isWrite_Wakeup && !cpy_pkt.isMntOp) begin
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index() with (
					    item.m_id                     == m_pkt.pt_id      &&
                                            item.ccp_addr                 == m_ccp_addr       &&
                                            item.ccp_index                == m_ccp_index      &&
                                            item.m_sfi_addr               == cpy_pkt.addr     &&
                                            !item.isACEWriteRespSent                          &&
                                            item.m_security               == cpy_pkt.security &&
					    ((item.isIoCacheTagPipelineSeen) ? (item.m_ccp_ctrl_pkt.lookup_p2 === 1 && (item.m_ccp_ctrl_pkt.cancel || item.m_ccp_ctrl_pkt.write_hit)) : ((item.isAddrBlocked            == 1) && (item.isCCPCancelSeen          == 1))) &&
                                            ((item.isWrite && item.isACEWriteDataNeeded) ? item.isACEWriteDataRecd == 1 : 1) &&
                                            item.isWrite                   == 1                
                                            );
        if(!cpy_pkt.nack && (m_tmp_q.size()==0) && m_pkt.t_pt_err == 0) begin
            spkt = $sformatf("Case Wr_Wakeup: Cannot find any matching pkt for the incoming ccp ctrl pkt %s",cpy_pkt.sprint_pkt());
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end
    end else  if (cpy_pkt.isSnoop && !cpy_pkt.isMntOp) begin
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index() with (
                                            item.ccp_addr                 == m_ccp_addr       &&
                                            item.ccp_index                == m_ccp_index      &&
                                            item.m_id                     == cpy_pkt.pt_id    &&
                                            item.m_security               == cpy_pkt.security &&
                                            item.isAddrBlocked            == 0                &&
					    ((item.isIoCacheTagPipelineNeeded) ? item.isIoCacheTagPipelineSeen == 0 : 0)       &&
                                            item.isSnoop                   == 1                
                                            );
        if(!cpy_pkt.nack && (m_tmp_q.size()==0) && m_pkt.t_pt_err == 0) begin
            spkt = $sformatf("Case Snp: Cannot find any matching pkt for the incoming ccp ctrl pkt for Snoop m_ccp_index %0d m_ccp_addr:0x%0h %s",m_ccp_index, m_ccp_addr,cpy_pkt.sprint_pkt());
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end        
    end
    
    if(m_tmp_q.size()>1) begin
	`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Found multiple matches below"),UVM_LOW)
        foreach (m_tmp_q[i]) begin 
	    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> ",m_ott_q[m_tmp_q[i]].tb_txnid <%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>),UVM_LOW)
        end
       if((cpy_pkt.isWrite_Wakeup || cpy_pkt.isWrite) && !cpy_pkt.isMntOp)begin
         foreach(m_tmp_q[j])begin
       	      if(!(m_ott_q[m_tmp_q[j]].dtrreq_cmstatus_err || m_ott_q[m_tmp_q[j]].hasFatlErr || m_ott_q[m_tmp_q[j]].dtwrsp_cmstatus_err))begin
       	      m_tmp_q[0]=m_tmp_q[j];
       	      break;
       	      end
          end
       end 
    end
    if(m_tmp_q.size()>0) begin
	`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Got_CCPCtrlPkt: %s", m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,cpy_pkt.sprint_pkt() ),UVM_LOW)

        //#Check.IOAIU.CCPCtrlPkt.Bypass 
        if (cpy_pkt.bypass == 1)
             `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("ccp_top.ctrl_op_bypass_p2 should never be asserted for proxyCache in IOAIU"))
        
        //m_search_q is pending 
        m_search_q = {};
        m_search_q = m_ott_q.find_index() with (!item.hasFatlErr && !item.dtrreq_cmstatus_err && !($test$plusargs("unmapped_add_access") && addr_trans_mgr::check_unmapped_add(item.ccp_addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) &&
                                                !($test$plusargs("no_credit_check")) &&
                                                !(item.illegalNSAccess) &&
						!(item.illegalCSRAccess) &&
						!(item.illDIIAccess) &&
					        item.ccp_addr == m_ccp_addr                                &&
                                                item.ccp_index == m_ccp_index                                  &&
                                                item.m_security == cpy_pkt.security                            &&
                                                (
                                                (((item.isIoCacheTagPipelineSeen == 1) ?
						(item.m_ccp_ctrl_pkt.pt_id === cpy_pkt.pt_id) : 0) &&
                                                    (
                                                        item.noAllocateNotFinished() ||
                                                        item.allocateNotFinished() ||
                                                        item.evictNotFinished() || 
                                                        item.hitNotFinished()
                                                    )
                                                ) 
                                            ));
        //Ensure way is protected while fill in progress
        m_search_pending_way_q = {};
        if(!cpy_pkt.nacknoalloc) begin
            m_search_pending_way_q = m_ott_q.find_index() with (!item.hasFatlErr && !(item.isWrite && item.dtrreq_cmstatus_err) && !(item.illegalNSAccess)&& !(item.illegalCSRAccess) && !(item.illDIIAccess) && item.isIoCacheTagPipelineSeen && 
                                                            (item.ccp_index == m_ccp_index) &&
                                                            (((item.m_iocache_allocate && !item.is_write_hit_upgrade) 
                                                            && item.isFillReqd && (item.m_ccp_ctrl_pkt.wayn == 
                                                            ((cpy_pkt.write_hit_upgrade|cpy_pkt.read_hit)? onehot_to_binay(cpy_pkt.hitwayn) : cpy_pkt.wayn)) ? 
                                                            ((item.isFillCtrlRcvd == 0) || (item.isFillDataRcvd==0)): 0) ||
                                                            (((item.m_iocache_allocate && item.is_write_hit_upgrade) 
                                                            && item.isFillReqd && (onehot_to_binay(item.m_ccp_ctrl_pkt.hitwayn) == 
                                                            (cpy_pkt.write_hit_upgrade? onehot_to_binay(cpy_pkt.hitwayn) : cpy_pkt.wayn))) ? 
                                                            ((item.isFillCtrlRcvd == 0) || (item.isFillDataRcvd==0)): 0)
                                                            ));
        end        
        //Check Address collison 
        //#Check.IOAIU.CCP.Currstate
	if(!m_ott_q[m_tmp_q[0]].isSnoop) begin
	    if(!cpy_pkt.lookup_p2 && !cpy_pkt.nackuce  && !cpy_pkt.nack && !cpy_pkt.cancel) begin
		check_cacheline_state(cpy_pkt);
                //CONC-11439
                if(cpy_pkt.currstate !=IX && ((m_ott_q[m_tmp_q[0]].isWrite &&m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awlock == EXCLUSIVE) || (m_ott_q[m_tmp_q[0]].isRead &&m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arlock == EXCLUSIVE)))begin
                     m_ott_q[m_tmp_q[0]].print_me(0,1,0,0);
                    //CONC-16243 temp hack
                    `uvm_warning("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d Noncoherent Exclusive txns should never hit to proxy cache: ccp_state %0s",m_ott_q[m_tmp_q[0]].tb_txnid, cpy_pkt.currstate.name()))
                end
		update_cacheline_state(m_tmp_q[0]);
	    end
	    check_ccp_ctrl(cpy_pkt,m_tmp_q[0]);
	end	       


        if(!cpy_pkt.isSnoop) begin: _not_snoop
            //`uvm_info("ncaiu0 SCB DBG", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> searchq.size:%0d search_pendingq.size:%0d nack:%0b cancel:%0b", m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_search_q.size(), m_search_pending_way_q.size(), cpy_pkt.nack, cpy_pkt.cancel), UVM_LOW)
    	    if( ((m_search_q.size()>0) || (m_search_pending_way_q.size()>0)) && (cpy_pkt.nack || cpy_pkt.cancel)) begin
        	//m_ott_q[m_search_q[0]].print_me();
                //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Adding Addr Blocking for Addr:%0h and Security:%0h",m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_ott_q[m_tmp_q[0]].m_sfi_addr,m_ott_q[m_tmp_q[0]].m_security),UVM_LOW)
                m_ott_q[m_tmp_q[0]].isAddrBlocked = 1'b1;
                m_ott_q[m_tmp_q[0]].t_addr_block_start_time = $time;
                m_ott_q[m_tmp_q[0]].isCCPCancelSeen = 1'b1;

            end else begin // !( ((m_search_q.size()>0) || (m_search_pending_way_q.size()>0)) && (cpy_pkt.nack || cpy_pkt.cancel))
                if( (m_search_q.size() == 0) && (m_search_pending_way_q.size() == 0)  && (cpy_pkt.nack || cpy_pkt.cancel))  begin
            	    //m_ott_q[m_search_q[0]].print_me();
                    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Adding Addr Blocking for Addr:%0h and Security:%0h",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_ott_q[m_tmp_q[0]].m_sfi_addr,m_ott_q[m_tmp_q[0]].m_security),UVM_LOW)
                    m_ott_q[m_tmp_q[0]].isAddrBlocked = 1'b1;
                    m_ott_q[m_tmp_q[0]].t_addr_block_start_time = $time;
                    m_ott_q[m_tmp_q[0]].isCCPCancelSeen = 1'b1;
                end else if(((m_search_q.size()>0) || (m_search_pending_way_q.size()>0)) && 
            			((cpy_pkt.nack==0) || (cpy_pkt.cancel==0))
            			//&& !((uncorr_CCP_Tag_Err_effect == 1) && (uncorr_CCP_Tag_Err_cacheline_addr_w_sec == {cpy_pkt.security, m_ccp_addr})) //saw a uce on Tag on this cacheline before
                ) begin

                    if(m_search_pending_way_q.size()>0) begin
                        txn_index = m_search_pending_way_q[0];
                        m_ott_q[m_search_pending_way_q[0]].print_me(0,1);
                    end else begin
                        txn_index = m_search_q[0];
                        m_ott_q[m_search_q[0]].print_me(0,1);
                    end
                    spkt = $sformatf("TB expected this OutstTxn #%0d to be cancelled. Due to dependency not met for the above txn OutstTxn #%0d (allocateNotFinished:%0h noAllocateNotFinished:%0h hitNotFinished:%0h evictNotFinished:%0h) from %0s for packet %s", m_tmp_q[0], txn_index,m_ott_q[txn_index].allocateNotFinished(),m_ott_q[txn_index].noAllocateNotFinished(), m_ott_q[txn_index].hitNotFinished(), m_ott_q[txn_index].evictNotFinished(),(m_search_pending_way_q.size() > 0) ? "m_search_pending_way_q" : "m_search_q", cpy_pkt.sprint_pkt());
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf(spkt),UVM_NONE)	
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("TB expected this txn to be cancelled. Due to dependency not met for the above txn"))

                end else if((m_search_q.size()==0) && !cpy_pkt.cancel && !cpy_pkt.nack && !cpy_pkt.t_pt_err) begin
                    if(cpy_pkt.isRead || cpy_pkt.isWrite) begin

                        m_sleep_q = {};
                        //HS: A txn had a cancelled CCP lkp but that txn wont
                        //reply if it detected an error. Hence we guard to
                        //make sure there txns we are matching against are
                        //nonErr txns
                        m_sleep_q = m_ott_q.find_index() with (
                                                            item.ccp_addr                 == m_ccp_addr       &&
                                                            item.ccp_index                == m_ccp_index      &&
                                                            item.m_security               == cpy_pkt.security &&
                                                            item.m_id                     == cpy_pkt.pt_id    &&
                                                            item.isAddrBlocked            == 1                &&
                                                            item.isIoCacheTagPipelineSeen == 0                &&
                                                            item.hasFatlErr               == 0                &&
                                                            item.dtwrsp_cmstatus_err      == 0                &&
                                                            item.dtrreq_cmstatus_err      == 0   
                                                            );


                        if(m_sleep_q.size()>0 ) begin
                            m_ott_q[m_sleep_q[0]].print_me(0,1);
			    spkt = $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> DV expects this txn to be cancelled due to older txn IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> not yet completing CCP lookup",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_ott_q[m_sleep_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>);
                            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf(spkt))
                        end
                    end //(cpy_pkt.isRead || cpy_pkt.isWrite)
                end//((m_search_q.size()==0) && !cpy_pkt.cancel && !cpy_pkt.nack && !cpy_pkt.t_pt_err)
	    end//!( ((m_search_q.size()>0) || (m_search_pending_way_q.size()>0)) && (cpy_pkt.nack || cpy_pkt.cancel))

            if((!cpy_pkt.nack && !cpy_pkt.cancel) && m_ott_q[m_tmp_q[0]].isAddrBlocked  && (m_search_q.size()==0)) begin
                m_ott_q[m_tmp_q[0]].isAddrBlocked = 1'b0;
                m_ott_q[m_tmp_q[0]].t_addr_block_end_time = $time;
                //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf(IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Removing Addr Blocking for Addr:%0h and Security:%0h",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_ott_q[m_tmp_q[0]].m_sfi_addr,m_ott_q[m_tmp_q[0]].m_security),UVM_LOW)
            end
	end: _not_snoop
	else begin: _is_snoop
	    if(cpy_pkt.state === IX && cpy_pkt.tagstateup && !cpy_pkt.cancel) begin
	        m_tmp_qA = {};
	        m_tmp_qA = m_ott_q.find_index() with (
						  item.ccp_addr == m_ott_q[m_tmp_q[0]].ccp_addr &&
						  item.m_security == cpy_pkt.security 			&&
						  item.isSMICMDReqNeeded                        &&
						  item.isSMICMDReqSent                          &&
						  item.isSMISTRReqRecd                          &&
						  item.allocateNotFinished());
	    
	        if(m_tmp_qA.size() > 0) begin
		    spkt = $sformatf("TB expected this SNP CCP Ctrl Pkt to be cancelled for OutstTxn #%0d. Due to dependency not met for the above txn OutstTxn %0d (SNP cannot invalidate cacheline that will be allocated once STRReq returns) for packet %s", m_tmp_q[0], m_tmp_qA[0],cpy_pkt.sprint_pkt());
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf(spkt),UVM_NONE)							   
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("TB expected this txn to be cancelled. SNP cannot invalidate cacheline that will be allocated once STRReq"))
	        end
	    end
					  
	end: _is_snoop
	       
        if(cpy_pkt.cancel) begin
            m_ott_q[m_tmp_q[0]].isCCPCancelSeen = 1'b1;
        end

        if (cpy_pkt.nackuce) begin
            m_ott_q[m_tmp_q[0]].m_io_cache_only_data_err_found = 0;
        end
        
        if( (m_ott_q[m_tmp_q[0]].t_ccp_ctrl_creation === start_time) ) begin
            m_ott_q[m_tmp_q[0]].t_ccp_ctrl_creation = $time;
        end

        m_ott_q[m_tmp_q[0]].t_ccp_last_lookup = $time;

        if( !cpy_pkt.cancel && 
            (!cpy_pkt.nack || cpy_pkt.nackuce) && 
            !(m_ott_q[m_tmp_q[0]].mem_regions_overlap) &&
            !(m_ott_q[m_tmp_q[0]].illegalNSAccess) &&
	    !(m_ott_q[m_tmp_q[0]].illegalCSRAccess) &&
            !(m_ott_q[m_tmp_q[0]].illDIIAccess) &&
            !(m_ott_q[m_tmp_q[0]].addrNotInMemRegion)
        	//&& !((uncorr_CCP_Tag_Err_effect == 1) && (uncorr_CCP_Tag_Err_cacheline_addr_w_sec == {cpy_pkt.security, m_ccp_addr})) //saw a uce on Tag on this cacheline before
        ) begin
            if(m_ott_q[m_tmp_q[0]].isAddrBlocked && !cpy_pkt.nack) begin
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("CCPCtrlPkt: %s",cpy_pkt.sprint_pkt() ),UVM_LOW)
                spkt = {"Got a valid CCP lookup but as per TB this txn is still blocked due to Addr Collison"};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
            end

	    exp_pending_vec = get_pending_ways(m_ccp_index);       
            //#Check.IOAIU.CCPCtrlPkt.BusyVec
	    //#Check.IOAIU.CCP.PendingWays
        //#Cover.IOAIU.CCPCtrlPkt.AllocMissWay
            if((((exp_pending_vec ^ cpy_pkt.waypbusy_vec) & exp_pending_vec) == '0) && !cpy_pkt.stale_vec_flag && !cpy_pkt.read_hit && !cpy_pkt.isSnoop && !cpy_pkt.write_hit_upgrade && !cpy_pkt.write_hit) begin
		if(((exp_pending_vec ^ cpy_pkt.waypbusy_vec) & cpy_pkt.waypbusy_vec) != '0) begin
		       if(!has_sleeping_ways(m_ccp_index)) begin
                           spkt = {"Pending Way vector mismatch: RTL sets bits for index with no sleeping transactions Index:0x%0h Exp:%b and Got:%b"};
                           `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf(spkt,m_ccp_index,exp_pending_vec, cpy_pkt.waypbusy_vec))
		       end
		end else if((cpy_pkt.alloc && (exp_pending_vec == '0) && (cpy_pkt.waypbusy_vec != '0)) && !cpy_pkt.read_hit && !cpy_pkt.isSnoop && !cpy_pkt.write_hit_upgrade && !cpy_pkt.write_hit) begin
                       spkt = {"Pending Way vector mismatch RTL sets bits for index with no busy transactions Exp:%b and Got:%b ccp_index:0x%0h %s"};
                       `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf(spkt,exp_pending_vec, cpy_pkt.waypbusy_vec,m_ccp_index,cpy_pkt.sprint_pkt()))
		end
	    end else if((((exp_pending_vec ^ cpy_pkt.waypbusy_vec) & exp_pending_vec) != '0) && !cpy_pkt.stale_vec_flag && !cpy_pkt.read_hit && !cpy_pkt.isSnoop && !cpy_pkt.write_hit_upgrade && !cpy_pkt.write_hit) begin
                spkt = $sformatf("Pending Way vector mismatch: RTL does not set bits for busy ways for OutstTxn #%0d index:0x%0h Exp:%b and Got:%b",m_tmp_q[0],m_ott_q[m_tmp_q[0]].ccp_index,exp_pending_vec, cpy_pkt.waypbusy_vec);
//		`uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s "       
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
//                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf(spkt,m_tmp_q[0],exp_pending_vec, cpy_pkt.waypbusy_vec))
            end else if((cpy_pkt.alloc && (exp_pending_vec == '0) && (cpy_pkt.waypbusy_vec != '0)) && !cpy_pkt.stale_vec_flag && !cpy_pkt.read_hit && !cpy_pkt.isSnoop && !cpy_pkt.write_hit_upgrade && !cpy_pkt.write_hit) begin
                spkt = {"Pending Way vector mismatch: RTL sets bits for index with no busy transactions Index: %0d  Exp:%b and Got:%b ccp_index:0x%0d %s"};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf(spkt,m_ccp_index,exp_pending_vec, cpy_pkt.waypbusy_vec,m_ccp_index,cpy_pkt.sprint_pkt()))
            end
             
            //Check whether it is a fake-hit
            dec_fake_hit = (|(~cpy_pkt.waypbusy_vec & cpy_pkt.hitwayn));

            if(!dec_fake_hit &&
	       (cpy_pkt.lookup_p2 === 0)) begin
                //Set the fake hit flag
                m_ott_q[m_tmp_q[0]].isFakeHit = 1'b1;
                //m_ott_q[m_tmp_q[0]].print_me();
                //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> GOT FAKE HIT exp_pending_vec:0x%0h rtl_busy_vec:0x%0h",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,m_ott_q[m_tmp_q[0]].core_id<%}%>, exp_pending_vec, cpy_pkt.waypbusy_vec),UVM_LOW)
            end 

            //#Check.IOAIU.CCPCtrlPkt.ErrorScenario
	    if ((m_ott_q[m_tmp_q[0]].illegalNSAccess  || 
                m_ott_q[m_tmp_q[0]].illegalCSRAccess  || 
                m_ott_q[m_tmp_q[0]].illDIIAccess ) &&
		(cpy_pkt.alloc || cpy_pkt.tagstateup || cpy_pkt.rp_update)) begin
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB TXN ERROR", $psprintf("IllegalNSAccess scenario: CCP lookup should have all of these set to 0 since it is a null lookup - alloc:%0d tagstateup:%0d rp_update:%0d", cpy_pkt.alloc, cpy_pkt.tagstateup, cpy_pkt.rp_update))
	    end

            if(m_ott_q[m_tmp_q[0]].isRead) begin: _is_Read
                //Setup cache_hit miss

                if((cpy_pkt.currstate != IX) && !m_ott_q[m_tmp_q[0]].isFakeHit && !cpy_pkt.nacknoalloc 
                    && !cpy_pkt.nackuce && iocache_lookup_en ) begin
                    m_ott_q[m_tmp_q[0]].is_ccp_hit = 1'b1;
                end else begin
                    m_ott_q[m_tmp_q[0]].is_ccp_hit = 1'b0;
                end

                //Setup the allocate bit 
		//#Check.IOAIU.CCP.Alloc
                //#Check.IOAIU.CCPCtrlPkt.Allocate
                if(cpy_pkt.nacknoalloc || cpy_pkt.nackuce  || m_ott_q[m_tmp_q[0]].illegalNSAccess || m_ott_q[m_tmp_q[0]].illegalCSRAccess || m_ott_q[m_tmp_q[0]].illDIIAccess || m_ott_q[m_tmp_q[0]].addrNotInMemRegion) begin
                    m_ott_q[m_tmp_q[0]].m_iocache_allocate       = 1'b0;
                end else begin
                    if(!m_ott_q[m_tmp_q[0]].is_ccp_hit && csr_ccp_lookupen && csr_ccp_allocen
                        && m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arcache[2]
                        && !(m_ott_q[m_tmp_q[0]].isPartialRead && addrMgrConst::get_addr_gprar_nc(m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.araddr)) //A partial NC read is converted to no allocate
                      ) begin
                        m_ott_q[m_tmp_q[0]].m_iocache_allocate = 1  ;
                    end else begin
                        m_ott_q[m_tmp_q[0]].m_iocache_allocate = 0  ;
                    end
                end

		if ($test$plusargs("disable_allocating_reads") && cpy_pkt.alloc == 1) begin 
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> allocating reads are disabled in this test and yet see an allocating read", m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>))
				end 
		
                m_ott_q[m_tmp_q[0]].setup_io_cache_read(cpy_pkt);

		wake_sleeping(m_ott_q[m_tmp_q[0]]);

                //#Check.IOAIU.CCPCtrlPkt.Allocate
                //#Check.IOAIU.Alloc
                if(  !(cpy_pkt.lookup_p2 || cpy_pkt.nackuce) ) begin  //CONC-12079 CONC-12228
		    if (cpy_pkt.alloc != m_ott_q[m_tmp_q[0]].m_iocache_allocate) begin
                    		`uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> CCPCtrlPkt Alloc bit mismatch for Read Exp:%0d Act:%0d for OutstTxn #%0d",  m_ott_q[m_tmp_q[0]].tb_txnid,core_id, m_ott_q[m_tmp_q[0]].m_iocache_allocate, cpy_pkt.alloc, m_tmp_q[0]))
                    	end
                end
           
                //Read the cache model
                if(m_ott_q[m_tmp_q[0]].is_ccp_hit) begin
                    read_cacheline_data(m_tmp_q[0]);
                end

            end: _is_Read 
            else if(m_ott_q[m_tmp_q[0]].isWrite) begin: _is_Write

	        m_ott_q[m_tmp_q[0]].is_ccp_hit = 1'b0;
		m_ott_q[m_tmp_q[0]].is_write_hit_upgrade = 1'b0;
		m_ott_q[m_tmp_q[0]].is_write_hit_upgrade_with_fetch = 1'b0;

		if (!m_ott_q[m_tmp_q[0]].isFakeHit && !cpy_pkt.nacknoalloc && !cpy_pkt.nackuce) begin
		    if(m_ott_q[m_tmp_q[0]].isCoherent) begin: _is_Coherent 
		        if (cpy_pkt.currstate inside {UC, UD})
			    m_ott_q[m_tmp_q[0]].is_ccp_hit = 1'b1;
			if (cpy_pkt.currstate inside {SC, SD})
		    	    m_ott_q[m_tmp_q[0]].is_write_hit_upgrade_with_fetch = 1'b1;
			if (cpy_pkt.currstate inside {SC, SD, UC})
	    		    m_ott_q[m_tmp_q[0]].is_write_hit_upgrade = 1'b1;
		    end : _is_Coherent 
		    else begin: _is_non_Coherent 
		        if (cpy_pkt.currstate inside {UC, UD, SC, SD})
			    m_ott_q[m_tmp_q[0]].is_ccp_hit = 1'b1;
			if (cpy_pkt.currstate inside {UC, SC, SD})
	    	            m_ott_q[m_tmp_q[0]].is_write_hit_upgrade = 1'b1;
		    end: _is_non_Coherent
		end

                //Check the tag update values
                //#Check.IOAIU.CCPCtrlPkt.TagStateUp_State
                if(m_ott_q[m_tmp_q[0]].is_ccp_hit &&
		   cpy_pkt.tagstateup             &&
		   !((cpy_pkt.currstate ==  SC &&
		      cpy_pkt.state ==  UD) ||
		     (cpy_pkt.currstate ==  SD &&
		      cpy_pkt.state ==  UD) ||
		     (cpy_pkt.currstate ==  UC && 
		      cpy_pkt.state ==  UD) ||
		     (cpy_pkt.currstate ==  IX && 
		      cpy_pkt.state ==  UD) )) begin
		    spkt = $sformatf("For MOESI cache a write-hit to OutstTxn #%0d %s cacheline should not upgrade to %s",m_tmp_q[0], cpy_pkt.currstate.name(), cpy_pkt.state.name());
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", spkt)
                end
       			
                //Setup the allocate bit 
                if(cpy_pkt.nacknoalloc || cpy_pkt.nackuce || !iocache_lookup_en || m_ott_q[m_tmp_q[0]].illDIIAccess || m_ott_q[m_tmp_q[0]].illegalNSAccess ||  m_ott_q[m_tmp_q[0]].illegalCSRAccess  || m_ott_q[m_tmp_q[0]].addrNotInMemRegion) begin
                    m_ott_q[m_tmp_q[0]].m_iocache_allocate       = 1'b0;
                end else begin
                    if(!m_ott_q[m_tmp_q[0]].is_ccp_hit && csr_ccp_lookupen && csr_ccp_allocen 
		        && (m_ott_q[m_tmp_q[0]].is_write_hit_upgrade != 1) 
		        && m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awcache[3]
                        && !(m_ott_q[m_tmp_q[0]].isPartialWrite && addrMgrConst::get_addr_gprar_nc(cpy_pkt.addr))//  Partial NC write converted no allocate on miss
			) begin
                        m_ott_q[m_tmp_q[0]].m_iocache_allocate = 1  ;
                    end else begin
                        m_ott_q[m_tmp_q[0]].m_iocache_allocate = 0  ;
                    end
                end
                
                //#Check.IOAIU.CCPCtrlPkt.Allocate
                if(!(cpy_pkt.lookup_p2 ||  cpy_pkt.nackuce)) begin //CONC-12079
		    			if (cpy_pkt.alloc != m_ott_q[m_tmp_q[0]].m_iocache_allocate && !m_ott_q[m_tmp_q[0]].hasFatlErr && !m_ott_q[m_tmp_q[0]].dtrreq_cmstatus_err && !m_ott_q[m_tmp_q[0]].dtwrsp_cmstatus_err) begin
                    		`uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> CCPCtrlPkt Alloc bit mismatch for Write Exp:%0d Act:%0d %0s",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_ott_q[m_tmp_q[0]].m_iocache_allocate, cpy_pkt.alloc, cpy_pkt.sprint_pkt()))
                    	end
                end

		if ($test$plusargs("disable_allocating_reads") && cpy_pkt.alloc == 1) begin 
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> allocating writes are disabled in this test and yet see an allocating write", m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>))
				end 

                m_ott_q[m_tmp_q[0]].setup_io_cache_write(cpy_pkt);
	        
                wake_sleeping(m_ott_q[m_tmp_q[0]]);
                
                //Read the cache model
		if(!m_ott_q[m_tmp_q[0]].isPartialWrite &&
		   (m_ott_q[m_tmp_q[0]].m_ccp_ctrl_pkt.tagstateup == 1) &&
		   (m_ott_q[m_tmp_q[0]].m_ccp_ctrl_pkt.currstate == IX) &&
		   (m_ott_q[m_tmp_q[0]].m_ccp_ctrl_pkt.state != IX)) begin
		    add_cacheline(m_tmp_q[0]);
		end 

		if(((m_ott_q[m_tmp_q[0]].isWriteHitFull()) || m_ott_q[m_tmp_q[0]].is_ccp_hit) && !cpy_pkt.lookup_p2 && cpy_pkt.wr_data) begin
                    //Update the cache model
                    store_write_hit_data(m_tmp_q[0]);
                end else if((cpy_pkt.currstate === SD) && cpy_pkt.wr_data && (m_ott_q[m_tmp_q[0]].isWriteHitFull() || m_ott_q[m_tmp_q[0]].is_ccp_hit) && (m_ott_q[m_tmp_q[0]].isSMISTRReqRecd === 0)) begin
		    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> IOAIU cannot write or update cacheline for currstate:SD state until STRReq comes back", m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>));
		end
            end: _is_Write
            else if(m_ott_q[m_tmp_q[0]].isSnoop) begin: _is_Snoop
                //Setup CCP fake hit 
                //CCP cache hit  is fake if the cache lookup hits a way that is pending; 
                //the exception to this rule is Write Hit Upgrade. External logic to CCP 
                //needs to detect and handle   fake hit
                m_search_q = {};
                m_search_q = m_ott_q.find_index() with (
                                                    item.ccp_addr == m_ccp_addr         &&
                                                    item.ccp_index == m_ccp_index       &&
                                                    item.m_security == cpy_pkt.security &&
                                                    item.isIoCacheTagPipelineSeen == 1  &&
                                                    ( (item.isIoCacheEvict ==1) &&
                                                      ((item.isSMIUPDReqNeeded==1 ? item.isSMIUPDRespRecd == 0 : 0)  || 
                                                      (item.isSMIDTWReqNeeded==1 ? item.isSMIDTWRespRecd == 0 : 0))
                                                    ) 
                                                );

                //Ensure way is protected while fill in progress
                m_search_pending_way_q = {};
                m_search_pending_way_q = m_ott_q.find_index() with (item.isIoCacheTagPipelineSeen && 
                                                                    !item.hasFatlErr &&
								    !item.dtrreq_cmstatus_err &&
                                                                    (item.ccp_index == m_ccp_index) &&
                                                                    (((item.m_iocache_allocate && (item.is_write_hit_upgrade==0)) 
                                                                    && item.isFillReqd ) ? 
                                                                    ((item.isFillCtrlRcvd == 0) || (item.isFillDataRcvd==0)): 0) 
                                                                    );
                exp_pending_vec = '0;
                if(m_search_pending_way_q.size()>0) begin
                    foreach(m_search_pending_way_q[i]) begin
                        exp_pending_vec[m_ott_q[m_search_pending_way_q[i]].m_ccp_ctrl_pkt.wayn] = 1;
                    end
                end 
                
                //#Cover.IOAIU.CCPCtrlPkt.HitWay
                //#Check.IOAIU.CCPCtrlPkt.BusyVec
                dec_fake_hit = |(~exp_pending_vec & cpy_pkt.hitwayn);

                //If a snoop hit evict treat it as miss
                if(m_search_q.size() > 0) begin
                    m_ott_q[m_tmp_q[0]].isSnpHitEvict = 1'b1;
		    //uvm_report_info("HS_DBG",$sformatf("Snp OutstTxn #%0d hits Evict OutstTxn #%0d for addr:0x%0h",m_tmp_q[0],m_search_q[0],m_ott_q[m_tmp_q[0]].m_sfi_addr),UVM_LOW);
                    numSnoopHitEvict++;
                    sb_stall_if.perf_count_events["Cache_eviction"].push_back(1);
                end else begin
                //If a snoop hits a pending way that is waiting to fill treat it as miss
                //Only for write-hit upgrade it should be treated as a hit
                    if(!dec_fake_hit) begin
                        m_ott_q[m_tmp_q[0]].is_ccp_hit = 1'b0;
                        numSnoopHitOtt++;
                    end else if (dec_fake_hit) begin
                        if(!cpy_pkt.nackuce && (cpy_pkt.currstate != IX) && iocache_lookup_en) begin
                            m_ott_q[m_tmp_q[0]].is_ccp_hit  = 1'b1;
                        end else begin
                            m_ott_q[m_tmp_q[0]].is_ccp_hit = 1'b0;
                        end
                    end else begin
                        spkt = {"Found multiple pending txn for Addr:0x%0x", 
                               " while processing a snoop txn"};
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf(spkt, m_ccp_addr))
                    end
                end
		
                if(!m_ott_q[m_tmp_q[0]].isSnpHitEvict && !cpy_pkt.nackuce) begin
		   check_cacheline_state(cpy_pkt);
		   update_cacheline_state(m_tmp_q[0]);
		end
		       
                m_ott_q[m_tmp_q[0]].setup_io_cache_snoop(cpy_pkt);
                //Read the cache model
                if(m_ott_q[m_tmp_q[0]].is_ccp_hit) begin
                    read_cacheline_data(m_tmp_q[0]);
                end
		
                if(!m_ott_q[m_tmp_q[0]].isSnpHitEvict) begin
		   //uvm_report_info("<%=obj.strRtlNamePrefix%> HS_DBG",$sformatf("IOAIU_UID:%0d check_ccp_ctrl", m_ott_q[m_tmp_q[0]].tb_txnid),UVM_NONE);
		   check_ccp_ctrl(cpy_pkt,m_tmp_q[0]);
               end else begin 
		   //uvm_report_info("<%=obj.strRtlNamePrefix%> HS_DBG",$sformatf("IOAIU_UID:%0d check_ccp_ctrl skipped since isSnpHitEvict asserted", m_ott_q[m_tmp_q[0]].tb_txnid),UVM_NONE);
               end 
		       
                //For snoop that invalidate the cacheline remove the address from cache model
                if(~cpy_pkt.nackuce && cpy_pkt.tagstateup && (cpy_pkt.state == IX)) begin
                    delete_cacheline(m_tmp_q[0],1);
                end

                if(cpy_pkt.nackuce && cpy_pkt.tagstateup) begin
                    spkt = {"Tagstate update signal shouldn't be", 
                           " set while nackuce is asserted"};
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf(spkt))
                end

            end: _is_Snoop
            
            if(cpy_pkt.evictvld   ) begin: _is_Evict
                m_scb_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen, csr_ccp_updatedis, ,core_id);
                m_scb_txn.t_ccp_last_lookup = $time;
                m_scb_txn.csr_use_eviction_qos = this.csr_use_eviction_qos; 
                m_scb_txn.csr_eviction_qos = this.csr_eviction_qos; 
		if(m_ott_q[m_tmp_q[0]].isRead)  begin    
                     m_scb_txn.setup_io_cache_evict(cpy_pkt, m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arqos, .read_addr_pkt(m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt) );
                     m_scb_txn.m_id = m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arid;

		end else begin
                     m_scb_txn.setup_io_cache_evict(cpy_pkt,m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awqos, .write_addr_pkt(m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt));
                     m_scb_txn.m_id = m_ott_q[m_tmp_q[0]].m_ace_write_addr_pkt.awid;
                end

		<%if(obj.useCache) {%>
	            if (csr_ccp_lookupen && csr_ccp_allocen) set_cacheline_way(m_scb_txn);
		<% } %>		      
                
        	if(m_scb_txn.isIoCacheEvictNeeded) begin
                    evict_cacheline_data(m_scb_txn, m_scb_txn.m_ccp_exp_data);
                    tb_txn_count++;
        	    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> CCP Eviction Predicted", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>), UVM_LOW)
                    m_scb_txn.natv_intf_cc = cycle_counter;
                    m_scb_txn.tb_txnid = tb_txn_count;
                    m_scb_txn.core_id = core_id;
                    m_ott_q.push_back(m_scb_txn);
		    ->e_queue_add;		     
                end
                delete_cacheline(m_tmp_q[0],0);
                
                if ((csr_ccp_updatedis || !m_ott_q[$].isCoherent) && (cpy_pkt.evictstate inside {UC, SC}))
		    delete_ott_entry(m_ott_q.size()-1, IOCacheEvict); 
            end: _is_Evict

            //Check read/write hit/miss logic is in sync with RTL 
            if(m_ott_q[m_tmp_q[0]].isRead) begin: _is_Read_
                tb_read_miss_allocate = m_ott_q[m_tmp_q[0]].m_iocache_allocate;
                tb_read_hit           = m_ott_q[m_tmp_q[0]].is_ccp_hit;
                if(~cpy_pkt.nackuce && (tb_read_hit != cpy_pkt.read_hit)) begin
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
                    spkt = {"TB/RTL read hit mismatch for the above txn",
                            " Exp:%0d and Got:%0d for OutstTxn #%0d"};
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt, tb_read_hit, cpy_pkt.read_hit,m_tmp_q[0]))
                end

                if(~cpy_pkt.nackuce && (tb_read_miss_allocate != cpy_pkt.read_miss_allocate) && this.csr_ccp_allocen && this.csr_ccp_lookupen
	        && !(m_ott_q[m_tmp_q[0]].isPartialRead && addrMgrConst::get_addr_gprar_nc(cpy_pkt.addr))//  case Ncmode: Partial allocate converted no allocate on miss
		) begin
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
                    spkt = {"TB/RTL read miss allocate mismatch for the above txn",
                            " Exp:%0d and Got:%0d for OutstTxn #%0d"};
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt,tb_read_miss_allocate,cpy_pkt.read_miss_allocate,m_tmp_q[0]))
                end
                
                //#Check.IOAIU.CCPCtrlPkt.RdData
                if(~cpy_pkt.nackuce && ~cpy_pkt.lookup_p2 && (tb_read_hit && !cpy_pkt.rd_data)) begin
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
                    spkt = $sformatf("For a read-hit NCBU should assert the read_data signal on the CCP if for OutstTxn #%0d Exp:%0d and Got:%0d",m_tmp_q[0],tb_read_hit,cpy_pkt.rd_data);
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", spkt)
                end
            end: _is_Read_
            else if (m_ott_q[m_tmp_q[0]].isWrite) begin: _is_Write_
                tb_write_miss_allocate = (m_ott_q[m_tmp_q[0]].m_iocache_allocate && 
                                          !m_ott_q[m_tmp_q[0]].is_write_hit_upgrade) ;
                tb_write_hit           = m_ott_q[m_tmp_q[0]].is_ccp_hit;
                tb_write_hit_upgrade   = m_ott_q[m_tmp_q[0]].is_write_hit_upgrade;

                if(~cpy_pkt.nackuce && (tb_write_hit != cpy_pkt.write_hit)) begin
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
                    spkt = $sformatf("TB/RTL write hit mismatch for the above txn OutstTxn #%0d Exp:%0d and Got:%0d", m_tmp_q[0], tb_write_hit, cpy_pkt.write_hit);
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", spkt)
                end

                if(~cpy_pkt.nackuce && !cpy_pkt.lookup_p2 && (tb_write_miss_allocate != cpy_pkt.write_miss_allocate) && this.csr_ccp_allocen && this.csr_ccp_lookupen
	          && !(m_ott_q[m_tmp_q[0]].isPartialWrite && addrMgrConst::get_addr_gprar_nc(cpy_pkt.addr)) && !(m_ott_q[m_tmp_q[0]].hasFatlErr) && !(m_ott_q[m_tmp_q[0]].dtrreq_cmstatus_err) && !(m_ott_q[m_tmp_q[0]].dtrreq_cmstatus_err_expcted) && !(m_ott_q[m_tmp_q[0]].dtwrsp_cmstatus_err)
//  case Ncmode: Partial allocate converted no allocate on miss //CONC-11171
						
						) begin
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
                    spkt = {"TB/RTL write miss allocate mismatch for the above txn",
                            " Exp:%0d and Got:%0d"};
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt,tb_write_miss_allocate, cpy_pkt.write_miss_allocate))
                end

                if(~cpy_pkt.nackuce && (tb_write_hit_upgrade != cpy_pkt.write_hit_upgrade)) begin
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
                    spkt = $sformatf("TB/RTL write hit upgrade mismatch for the OutstTxn #%0d Exp:%0d and Got:%0d", m_tmp_q[0],tb_write_hit_upgrade, cpy_pkt.write_hit_upgrade);
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", spkt)
                end
            end: _is_Write_
            else if(m_ott_q[m_tmp_q[0]].isSnoop) begin: _is_Snoop_
                tb_snoop_hit = m_ott_q[m_tmp_q[0]].is_ccp_hit ;
                
                if(~cpy_pkt.nackuce && (tb_snoop_hit != cpy_pkt.snoop_hit) && !m_ott_q[m_tmp_q[0]].isSnpHitEvict) begin
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
                    spkt = {"TB/RTL snoop hit mismatch for the above txn",
                            " Exp:%0d and Got:%0d"};
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt,tb_snoop_hit,cpy_pkt.snoop_hit ))
                end

                //#Check.IOAIU.CCPCtrlPkt.RdData
                if( ~cpy_pkt.nackuce && tb_snoop_hit && (m_ott_q[m_tmp_q[0]].isSMISNPDTRReqNeeded || 
                    m_ott_q[m_tmp_q[0]].isSMIDTWReqNeeded) && !cpy_pkt.rd_data ) begin
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
                    spkt = {"For a snoop-hit  that requires DTR/DTW NCBU should assert the read_data signal",
                            " on the CCP if Exp:%0d and Got:%0d"};
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt,tb_snoop_hit,cpy_pkt.rd_data))
                end
                if(~cpy_pkt.nackuce && (tb_snoop_hit == 0) && cpy_pkt.tagstateup) begin
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
                    spkt = {"For a snoop-miss tag state update signal",
                            " shouldn't be asserted"};
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", spkt)
                end
            end: _is_Snoop_

	    /*if (m_ott_q[m_tmp_q[0]].addrNotInMemRegion == 0) begin
                if (m_ott_q[m_tmp_q[0]].is_ccp_hit) begin
		    if (m_ott_q[m_tmp_q[0]].isRead)
            	        sb_stall_if.perf_count_events["Cache_read_hit"].push_back(1);
		    //if (m_ott_q[m_tmp_q[0]].isWrite)
            	    //	sb_stall_if.perf_count_events["Cache_write_hit"].push_back(1);
		end else begin
		    if (m_ott_q[m_tmp_q[0]].isRead)
            	        sb_stall_if.perf_count_events["Cache_read_miss"].push_back(1);
		    if (m_ott_q[m_tmp_q[0]].isWrite)
            	        sb_stall_if.perf_count_events["Cache_write_miss"].push_back(1);
            	end
            end*/
            <% if(obj.COVER_ON) {%>
            sample_coverage(m_tmp_q[0]);
            <%}%>
        end
            if (m_ott_q[m_tmp_q[0]].isWrite && m_ott_q[m_tmp_q[0]].isMultiAccess && cpy_pkt.nackuce) begin
	       int m_tmp_qB[$];
               int total_cacheline_count_tmp;
               int multiline_tracking_id_tmp = m_ott_q[m_tmp_q[0]].m_multiline_tracking_id;


               m_tmp_qB = m_ott_q.find_index with (//item.isWrite                 === m_ott_q[m_tmp_q[0]].isWrite &&
						   //item.isRead                  === m_ott_q[m_tmp_q[0]].isRead &&
						   item.isSnoop                 === m_ott_q[m_tmp_q[0]].isSnoop &&
						   item.isMultiAccess           === 1 &&
                                                   item.m_multiline_tracking_id === multiline_tracking_id_tmp
                                                  );
            end
		     end else begin // if (m_tmp_q.size()>0)
		     
        if(cpy_pkt.isMntOp && !cpy_pkt.nack && !cpy_pkt.cancel) begin
			tb_txn_count++;
			`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Got_CCPCtrlPkt: %s mntOpType:0x%0h entry:0x%0h mntway:0x%0h",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,cpy_pkt.sprint_pkt(), mntOpType,cpy_pkt.entry, cpy_pkt.mntwayn),UVM_LOW)
                 evict_counter++;
            //Flush All operation
            if((mntOpType == 'h7) || (mntOpType == 'h8) || (mntOpType == 'h4) || (mntOpType == 'h5) || (mntOpType == 'h6) || (mntOpType == 'hC) || (mntOpType == 'hE)) begin
                if(m_mntop_q.size()>0) begin
                    if(m_mntop_q.size()>1) begin
                        int m_mntop_idx_q[$];
                        // Add search method for isCancel case, as they will retry after some time, making it out of order
                        m_mntop_idx_q = m_mntop_q.find_index() with (
                                                                    ((mntOpType == 'h6) || (mntOpType == 'h7)) ? ((cpy_pkt.addr == item.mntop_addr) && (cpy_pkt.security == item.mntop_security)) : 
                                                                                                                 ((cpy_pkt.entry == item.mntop_index) && (cpy_pkt.mntwayn == item.mntop_way))
                                                                    );
						`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> m_mntop_idx_q.size:%0d",  tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_mntop_idx_q.size()),UVM_LOW)
                        if(m_mntop_idx_q.size()) begin
                            temp_mntop_pkt = m_mntop_q[m_mntop_idx_q[0]];
                            m_mntop_q.delete(m_mntop_idx_q[0]);
                            m_mntop_q.push_front(temp_mntop_pkt);
                        end
                    end
                    temp_mntop_pkt = m_mntop_q.pop_front();
		    ->e_queue_delete;
                    temp_mntop_pkt.t_latest_update = $time;
                end else begin
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("Received an unexpected MntOp txn MntOpType:%0d",mntOpType))
                end

                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB INFO",$sformatf("Maint Op mntOpType:%0h %0s", mntOpType, temp_mntop_pkt.m_mntop_cmd_type.name()),UVM_LOW);
		temp_mntop_pkt.print_me();

                <%if(obj.AiuInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
                    if (m_pkt.rp_update == 1) begin 
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("rp_update incorrectly asserted for a MaintenanceOp refer CONC-12875 for details"))
                    end
                <%}%>
		     
                if(cpy_pkt.nackuce == 0) begin
                    //#Check.IOAIU.CCPCtrlPkt.SetWayDebug
                    // SetWay Debug P2 check
                    if((mntOpType != 'h6) && (mntOpType != 'h7) && (mntOpType != 'h0) && ~cpy_pkt.setway_debug) begin 
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("Expected the ctrlop_setway_debug to be set for MntOp txn :%0h",mntOpType))
                    end

                    if(((mntOpType == 'h6) || (mntOpType == 'h7) ) && cpy_pkt.setway_debug) begin
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("For Flush by Addr/ Flush All ctrlop_setway_debug shouldn't be set"))
                    end

                    if(((mntOpType == 'h6) || (mntOpType == 'h7)) && (cpy_pkt.currstate != IX) && (!cpy_pkt.tagstateup || (cpy_pkt.state != IX))) begin
                        spkt = {"Expected the tagstateup signal to be set and/or state signal to be set to IX"};
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", spkt)
                    end

                    // curr_state == IX -> tagstateup = 0
                    // curr_state != IX -> tagstateup = 1 and state=IX
                    if(((mntOpType == 'h6) || (mntOpType == 'h7) || (mntOpType == 'h4) || (mntOpType == 'h5) || (mntOpType == 'h8)|| (mntOpType == 'h4)) && (cpy_pkt.currstate == IX) && (cpy_pkt.tagstateup)) begin
                        spkt = {"Expected the tagstateup signal to be zero as Current state signal is set to IX"};
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", spkt)
                    end
                    if(((mntOpType == 'h6) || (mntOpType == 'h7) || (mntOpType == 'h4) || (mntOpType == 'h5) || (mntOpType == 'h8)|| (mntOpType == 'h4)) && (cpy_pkt.currstate != IX) && (!cpy_pkt.tagstateup || (cpy_pkt.state != IX))) begin
                        spkt = {"Expected the tagstateup signal to be set and/or state signal to be set to IX"};
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", spkt)
                    end

//DCDEBUG                    if((mntOpType == 'h6) && ((cpy_pkt.addr != (temp_mntop_pkt.mntop_addr<<offset)) || (cpy_pkt.security != mnt_PcSecAttr))) begin
                    if(((mntOpType == 'h6) || (mntOpType == 'h7)) && ((cpy_pkt.addr != (temp_mntop_pkt.mntop_addr)) || (cpy_pkt.security != mnt_PcSecAttr))) begin
                        spkt = {"Expected MntOp to perform a flush for Exp Addr:%0h but Got Addr:%0h", 
                                " Exp Security:%0d and Got Security:%0d"};
//DCDEBUG                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt, (temp_mntop_pkt.mntop_addr<<offset), cpy_pkt.addr, ))
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt, (temp_mntop_pkt.mntop_addr), cpy_pkt.addr, 
                                    mnt_PcSecAttr, cpy_pkt.security))
                    end

                    // Check Set-Way
                    if(((mntOpType == 'h5) || (mntOpType == 'h8) || (mntOpType == 'h4) || (mntOpType == 'hC) || (mntOpType == 'hE)) && ((cpy_pkt.entry != (temp_mntop_pkt.mntop_index)) || (cpy_pkt.mntwayn != temp_mntop_pkt.mntop_way))) begin
                        spkt = {"Expected MntOp to have Exp Set/Index:0x%0x but Got Set/Index:0x%0x", 
                                " Exp Way:0x%0x and Got Way:0x%0x"};
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt, (temp_mntop_pkt.mntop_index), cpy_pkt.entry, 
                                    temp_mntop_pkt.mntop_way, cpy_pkt.mntwayn))
                    end
                    if(((mntOpType == 'hC) || (mntOpType == 'hE)) && (cpy_pkt.arraysel!=temp_mntop_pkt.mntop_ArrayId || cpy_pkt.word!=temp_mntop_pkt.mntop_word)) begin
                        spkt = {"Expected ArrySel:0x%x and Word:0x%0x for MntOp DebugRd/DebugWr, Act: ArraySel:0x%0x Word:0x%0x"};
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf(spkt,temp_mntop_pkt.mntop_ArrayId,temp_mntop_pkt.mntop_word,cpy_pkt.arraysel,cpy_pkt.word))
                    end
                    
                    // Check Opcode
                    if(cpy_pkt.opcode !== mntOpType && cpy_pkt.opcode!= 'h5 && cpy_pkt.opcode!= 'h6) begin
                        spkt = {"Expected the MntOp:0x%0x , but Act MntOp:0x%0x "};
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf(spkt,mntOpType,cpy_pkt.opcode))
                    end

                    // Check Wrdata/reqdata
                    if((mntOpType == 'hE) && (cpy_pkt.reqdata !== temp_mntop_pkt.mntop_Dataword)) begin
                        spkt = {"Expected Mnt_ReqData = 0x%0x but got 0x%0x"};
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf(spkt,temp_mntop_pkt.mntop_Dataword,cpy_pkt.reqdata))
                    end

		    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Maint Evict for address 0x%0x MntOpType:0x%0h", cpy_pkt.addr, mntOpType), UVM_LOW);
                    
                    m_scb_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen, csr_ccp_updatedis);

                    //uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Maint Evict for address 0x%0x MntOpType:0x%0h", cpy_pkt.addr, mntOpType), UVM_LOW);

            	    m_scb_txn.tb_txnid = tb_txn_count;
		    m_scb_txn.core_id = core_id;
                    m_scb_txn.t_ccp_last_lookup    = $time;
                    m_scb_txn.csr_use_eviction_qos = this.csr_use_eviction_qos; 
                    m_scb_txn.csr_eviction_qos     = this.csr_eviction_qos; 

                    cpy_pkt.evictstate  = cpy_pkt.currstate;
                    if ((mntOpType == 'h6) || (mntOpType == 'h7))begin
                        cpy_pkt.evictaddr       = cpy_pkt.addr;
                        cpy_pkt.evictsecurity   = cpy_pkt.security;
                    end
                    if (!((mntOpType == 'hC) || (mntOpType == 'hE))) begin
                      m_scb_txn.setup_io_cache_evict(cpy_pkt);
                    end 

                    m_find_q = {};
                    if( (mntOpType == 'h8) || (mntOpType == 'h5) || (mntOpType == 'h4)) begin
                        m_find_q = m_ncbu_cache_q.find_index() with (
                                                            item.Index  == temp_mntop_pkt.mntop_index    &&
                                                            item.way    == temp_mntop_pkt.mntop_way    
                                                            );
                    end else if ((mntOpType == 'h6) || (mntOpType == 'h7))begin
                        m_find_q = m_ncbu_cache_q.find_index() with (
                                                            item.tag  == (cpy_pkt.addr>>offset)   &&
                                                            item.Index  == m_scb_txn.ccp_index    &&
                                                            item.security  == cpy_pkt.security
                                                            );
                    end

                    if(m_find_q.size()>0) begin
                        if(m_scb_txn.isIoCacheEvictNeeded) begin
                            
                            evict_cacheline_data(m_scb_txn, m_scb_txn.m_ccp_exp_data);

                            //#Check.IOAIU.CCPCtrlPkt.RdData
                            if(m_scb_txn.isSMIDTWReqNeeded && ~cpy_pkt.rd_data) begin
                                spkt = {"For MntOp Evict expected the ctrlop_read_data_p2", 
                                        " signal to be set"};
                                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt))
                            end else if(~m_scb_txn.isSMIDTWReqNeeded && cpy_pkt.rd_data) begin
                                spkt = {"For MntOp Evict where no DTW req is reqd ",
                                        " expected the ctrlop_read_data_p2", 
                                        " signal to be not-set"};
                                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt))
                            end

                            if(m_scb_txn.isSMIDTWReqNeeded && ~cpy_pkt.rsp_evict_sel) begin
                                spkt = {"For MntOp Evict expected the ctrlop_port_sel_p2", 
                                        " signal to be set"};
                                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt))
                            end

                        end 
							
			m_ott_q.push_back(m_scb_txn);
		        ->e_queue_add;
                        
                        if ((csr_ccp_updatedis || !m_ott_q[$].isCoherent) && (cpy_pkt.evictstate inside {UC, SC}))
		            delete_ott_entry(m_ott_q.size()-1, MntOp_IOCacheEvict); 
                    end 
                    
                    if( (mntOpType == 'h8) || (mntOpType == 'h5) || (mntOpType == 'h4)) begin
                        if(m_find_q.size()>0) begin
                            cpy_pkt.addr = cpy_pkt.evictaddr;
                            cpy_pkt.security = cpy_pkt.evictsecurity;
		                    check_cacheline_state(cpy_pkt);
                            `uvm_info("<%=obj.strRtlNamePrefix%> SCB","Deleting cacheline from cache model: MaintOp",UVM_LOW)
                            m_ncbu_cache_q[m_find_q[0]].print();
                            m_ncbu_cache_q.delete(m_find_q[0]);
                           // if (csr_ccp_updatedis == 1 && (cpy_pkt.evictstate inside {UC, SC})) begin 
                           //    `uvm_info("ncaiu0 SCB","Deleting OTT entries for SC/UC Silent Evictions: MaintOp",UVM_LOW)
                           //    delete_ott_entry(m_ott_q.size()-1, MntOp_Upd_Dis);
		           // end 
                        end
		        else begin
		        end
		     
                    end else if ((mntOpType == 'h6) || (mntOpType == 'h7))begin
                        if(m_find_q.size()>0) begin
		            check_cacheline_state(cpy_pkt);
                            `uvm_info("<%=obj.strRtlNamePrefix%> SCB","Deleting cacheline from cache model",UVM_LOW)
                            m_ncbu_cache_q[m_find_q[0]].print();
                            m_ncbu_cache_q.delete(m_find_q[0]);
                            if (csr_ccp_updatedis == 1 && (cpy_pkt.evictstate inside {UC, SC})) begin 
                               `uvm_info("ncaiu0 SCB","Deleting OTT entries for SC/UC Silent Evictions: MaintOp",UVM_LOW)
                               delete_ott_entry(m_ott_q.size()-1, MntOp_Upd_Dis);
		            end 
                        end 
                    end
                end
            end
	    else if(cpy_pkt.isMntOp) begin
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("CCPCtrl MntOp did not match with any existing MntOp! MntOpType:0x%0d%s",mntOpType,cpy_pkt.sprint_pkt()),UVM_NONE);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR","CCPCtrl MntOp did not match with any existing MntOp!",UVM_NONE);
            end
	     
        end


        if(!cpy_pkt.isMntOp && !cpy_pkt.isRead && !cpy_pkt.isWrite &&
           !cpy_pkt.isSnoop && !cpy_pkt.isRead_Wakeup && !cpy_pkt.isWrite_Wakeup &&
           !cpy_pkt.nack 
           ) begin

           //Ensure no control signal are asserted when there is no valid txn.
           // Tb is unable to determine whether it is a Read/Write/Snoop or MntOp

            if(cpy_pkt.tagstateup) begin
                spkt = { "ctrlop_tagstateup signal should not be asserted for a txn", 
                         " whose valid is not asserted i.e isRead,isWrite,isSnoop or ", 
                         " isMntOp is not asserted "};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt))
            end

            if(cpy_pkt.rp_update) begin
                spkt = { "ctrlop_rp_update signal should not be asserted for a txn", 
                         " whose valid is not asserted i.e isRead,isWrite,isSnoop or ", 
                         " isMntOp is not asserted "};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt))
            end

            if(cpy_pkt.rd_data) begin
                spkt = { "ctrlop_rd_data signal should not be asserted for a txn", 
                         " whose valid is not asserted i.e isRead,isWrite,isSnoop or ", 
                         " isMntOp is not asserted "};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt))
            end

            if(cpy_pkt.wr_data) begin
                spkt = { "ctrlop_wr_data signal should not be asserted for a txn", 
                         " whose valid is not asserted i.e isRead,isWrite,isSnoop or ", 
                         " isMntOp is not asserted "};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt))
            end

            if(cpy_pkt.alloc) begin
                spkt = { "ctrlop_alloc signal should not be asserted for a txn", 
                         " whose valid is not asserted i.e isRead,isWrite,isSnoop or ", 
                         " isMntOp is not asserted "};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt))
            end

        end
    end

    //Ensure tag is never updated for this condition
    //#Check.IOAIU.CCPCtrlPkt.TagStateUpdate
    if(cpy_pkt.nack || cpy_pkt.cancel || cpy_pkt.nackuce) begin
        if(cpy_pkt.tagstateup) begin
            spkt = { "ctrlop_tagstateup signal should not be asserted for a txn", 
                     " whose valid is not asserted i.e isRead,isWrite,isSnoop or ", 
                     " isMntOp is not asserted "};
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt))
        end
    end

    //** For coverage

      if (cpy_pkt.posedge_count == prev_ctrl_pkt.posedge_count + 1 && cpy_pkt.alloc == 1 && prev_ctrl_pkt.alloc == 1) begin 
        if (cpy_pkt.addr          == prev_ctrl_pkt.addr &&
            cpy_pkt.security      == prev_ctrl_pkt.security) begin
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Hit b2b CCP pkts to same address"),UVM_LOW)
            cpy_pkt.b2b_same_addr = 1;
        end else if ((addrMgrConst::get_set_index(cpy_pkt.addr,<%=obj.FUnitId%>) == addrMgrConst::get_set_index(prev_ctrl_pkt.addr,<%=obj.FUnitId%>)) &&
            (cpy_pkt.addr != prev_ctrl_pkt.addr || cpy_pkt.security == prev_ctrl_pkt.security)) begin 
            cpy_pkt.b2b_same_index = 1;
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Hit b2b CCP pkts to same index"),UVM_LOW)
        end
    end
    
    prev_ctrl_pkt.copy(cpy_pkt);


<% if(obj.COVER_ON && obj.useCache) { %>
     `ifndef FSYS_COVER_ON
     cov.collect_ncbu_ccp_ctrl_chnl_bnk(cpy_pkt, WCCPBANKBIT, <%=obj.nWays%>, core_id);
     `endif
<% } %>  

endfunction:write_ncbu_ccp_ctrl_chnl


//=========================================================================
// Function: write_ncbu_ccp_fill_ctrl_chnl 
// Purpose: 
// 
// 
//=========================================================================
function void ioaiu_scoreboard::write_ncbu_ccp_fill_ctrl_chnl(ccp_fillctrl_pkt_t  m_pkt);
    axi_axaddr_t m_ccp_addr;
    ccp_fillctrl_pkt_t    cpy_pkt;
    ccp_fillctrl_pkt_t    cpy_pkt_tmp;
    int             m_tmp_q[$];
    int             m_tmp_q1[$];
    string          spkt,s;
    int             m_ccp_index;
    if(hasErr)
     return;

    cpy_pkt       = new();
    $cast(cpy_pkt_tmp,m_pkt); 
    cpy_pkt.copy(cpy_pkt_tmp);

<% if(obj.COVER_ON && obj.useCache) { %>
    `ifndef FSYS_COVER_ON
    cov.collect_ncbu_ccp_fill_ctrl_chnl(m_pkt, <%=obj.nWays%>, core_id);
    `endif
<% } %>  


    //Calculate Tag and Index
    m_ccp_addr   = shift_addr(cpy_pkt.addr);
    m_ccp_index = addrMgrConst::get_set_index(cpy_pkt.addr,<%=obj.FUnitId%>);

    //#Check.IOAIU.CCP.FillExpected
    m_tmp_q = {}; 
    m_tmp_q = m_ott_q.find_index() with (item.ccp_addr                == m_ccp_addr        &&
                                        item.ccp_index                == m_ccp_index      &&
                                        item.m_security               == cpy_pkt.security &&
                                        item.isAddrBlocked            == 0                &&
                                        item.isFillCtrlRcvd           == 0                &&
                                        item.isFillReqd               == 1                &&
                                        item.isIoCacheTagPipelineSeen == 1);
      //CONC-16603 seems like RTL is inconsistent here and it is ok since Err scenario- you may or may not get a Fill* (Ctrl & Data) if that txn is tagged with a dtrreq_cmstatus_err. So checks need to be more abstract.
      if (m_tmp_q.size() > 1) begin
      for (int i = 0; i < m_tmp_q.size(); i++) begin  // No i++ here, will be handled inside
        if (m_ott_q[m_tmp_q[i]].dtrreq_cmstatus_err) begin
            m_tmp_q.delete(i);  // Delete the element at index i
        end 
      end
     end



     //#Check.IOAIU.CCP.FillProtocolCheck
    if(m_tmp_q.size()==1) begin
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Got_CCPFillCtrlPkt: %s", m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,cpy_pkt.sprint_pkt()),UVM_LOW)
        //Clear the Pending bit
        m_ott_q[m_tmp_q[0]].isFillCtrlRcvd = 1'b1;
	if(!hasErr)	     
	     m_ott_q[m_tmp_q[0]].setup_io_cache_fill_ctrl(cpy_pkt);

        <% if(obj.useCache) { %>
        if(m_ott_q[m_tmp_q[0]].isSMISTRReqAddrErr && str_err_logged == "null" ) begin
            strreq_addr_err_logged =  m_ott_q[m_tmp_q[0]].m_sfi_addr;
            str_err_logged = "true";
        end

        <%}%>

        //Add the cacheline to NCBU cache

        if(!m_ott_q[m_tmp_q[0]].isSMISTRReqAddrErr      &&
           !m_ott_q[m_tmp_q[0]].isSMISTRReqDataErr      &&
           !m_ott_q[m_tmp_q[0]].isSMISTRReqTransportErr &&
           !m_ott_q[m_tmp_q[0]].isSMICMDRespErr         &&
           !m_ott_q[m_tmp_q[0]].isSMIDTRReqDtrDatVisErr &&
           !m_ott_q[m_tmp_q[0]].isSMIDTWrspErr          &&
	   !hasErr                                         ) begin
            add_cacheline(m_tmp_q[0]);
        end else begin
            if(m_ott_q[m_tmp_q[0]].isSMISTRReqAddrErr      ||
               m_ott_q[m_tmp_q[0]].isSMISTRReqDataErr      ||
               m_ott_q[m_tmp_q[0]].isSMISTRReqTransportErr ||
               m_ott_q[m_tmp_q[0]].isSMICMDRespErr         ||
               m_ott_q[m_tmp_q[0]].isSMIDTRReqDtrDatVisErr ||
               m_ott_q[m_tmp_q[0]].isSMIDTWrspErr) begin

                m_tmp_q1 = {};
                m_tmp_q1 = m_ncbu_cache_q.find_index() with (
                                                    item.tag     == m_ott_q[m_tmp_q[0]].ccp_addr     &&
                                                    item.Index    == m_ott_q[m_tmp_q[0]].ccp_index    &&
                                                    item.security == m_ott_q[m_tmp_q[0]].m_security   
                                                    );


                if(m_tmp_q1.size()>0) begin
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB","Deleting cacheline from cache model",UVM_LOW)
//                    m_ncbu_cache_q[m_tmp_q1[0]].print();

                    m_ncbu_cache_q.delete(m_tmp_q1[0]);
                end
            end

        end

        //Delete the OutstTxn entrie if it received CMDrsp error
        if (m_ott_q[m_tmp_q[0]].isSMICMDRespErr &&
            (m_ott_q[m_tmp_q[0]].isWrite && (m_ott_q[m_tmp_q[0]].isACEWriteRespSent === 1) ||
            (m_ott_q[m_tmp_q[0]].isRead && (m_ott_q[m_tmp_q[0]].isACEReadDataSent=== 1))) && 
            (((m_ott_q[m_tmp_q[0]].isMultiAccess) ? 
             m_ott_q[m_tmp_q[0]].multiline_ready_to_delete:0) || !m_ott_q[m_tmp_q[0]].isMultiAccess)
        ) begin
            delete_ott_entry(m_tmp_q[0], IOCData);
        end else begin
            if( m_ott_q[m_tmp_q[0]].isSMICMDRespErr && m_ott_q[m_tmp_q[0]].isMultiAccess && !m_ott_q[m_tmp_q[0]].multiline_ready_to_delete) begin
                m_ott_q[m_tmp_q[0]].multiline_ready_to_delete = 1;
            end

            //This is the NC full write case, that missed in cache, so Fill to update to UD, no SMI Activity.
 			if (m_ott_q[m_tmp_q[0]].isMultiAccess && !m_ott_q[m_tmp_q[0]].multiline_ready_to_delete && !m_ott_q[m_tmp_q[0]].isSMICMDReqNeeded) begin
                m_ott_q[m_tmp_q[0]].multiline_ready_to_delete = 1;
			end
        end
        
    end else if(m_tmp_q.size()>1) begin
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("Got_CCPFillCtrlPkt: %s", cpy_pkt.sprint_pkt()),UVM_LOW)
		s="";						   
        foreach(m_tmp_q[i]) begin
	    s = $sformatf("%s,%0d",s,m_tmp_q[i]);				   
            m_ott_q[m_tmp_q[i]].print_me(0,1);
        end
        spkt = "Found multiple Fill pending for this txn.";
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s, OutStTxn#'s:%s",spkt,s),UVM_NONE)
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s,%s",spkt,m_pkt.sprint_pkt()))

    end else begin
        spkt = "Cannot find any matching pkt for the incoming ccp fill pkt";
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s,%s",spkt,m_pkt.sprint_pkt()),UVM_NONE)
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
	end

endfunction: write_ncbu_ccp_fill_ctrl_chnl

//=========================================================================
// Function: write_ncbu_ccp_fill_data_chnl 
// Purpose: 
// 
// 
//=========================================================================
function void ioaiu_scoreboard::write_ncbu_ccp_fill_data_chnl(ccp_filldata_pkt_t m_pkt);
    axi_axaddr_t m_ccp_addr;
    ccp_filldata_pkt_t  cpy_pkt;
    ccp_filldata_pkt_t  cpy_pkt_tmp;
    int                 m_tmp_q[$];
    int                 m_tmp_qA[$];
    int                 m_tmp_q1[$];
    string              spkt,s;
    int                 m_ccp_index;
    ccp_ctrlfill_data_t fill_data[],fill_bitmask[];
    ccp_ctrlfilldata_byten_t fill_byten[];
    int                 fill_data_beats[];
    ccp_data_poision_t  fill_data_poison[];
    ccp_ctrlfilldata_byten_t all1s = '1;
    ccp_ctrlfilldata_byten_t exp_byten;
    bit	exp_fill_data_poisoned;
    bit act_fill_data_poisoned;

    if(hasErr)
     return;

    cpy_pkt       = new();
    $cast(cpy_pkt_tmp,m_pkt); 
    cpy_pkt.copy(cpy_pkt_tmp);

    //Calculate Tag and Index
    m_ccp_addr   = shift_addr(cpy_pkt.addr);
    m_ccp_index = addrMgrConst::get_set_index(cpy_pkt.addr,<%=obj.FUnitId%>);

    m_tmp_q = {}; 
    m_tmp_q = m_ott_q.find_index() with (item.ccp_addr                 == m_ccp_addr  &&
                                        item.ccp_index                == m_ccp_index  &&
                                        item.ccp_way                  == cpy_pkt.wayn &&
                                        item.isAddrBlocked            == 0            &&
                                        item.isIoCacheTagPipelineSeen == 1            &&
                                        (item.m_iocache_allocate      == 1 || item.is_write_hit_upgrade)                   &&
                                        item.isFillReqd               == 1            &&
                                        item.isFillDataReqd           == 1            &&
                                        item.isFillDataRcvd           == 0);
     //CONC-16603 seems like RTL is inconsistent here and it is ok since Err scenario- you may or may not get a Fill* (Ctrl & Data) if that txn is tagged with a dtrreq_cmstatus_err. So checks need to be more abstract.
    if (m_tmp_q.size() > 1) begin
    for (int i = 0; i < m_tmp_q.size(); i++) begin  // No i++ here, will be handled inside
        if (m_ott_q[m_tmp_q[i]].dtrreq_cmstatus_err) begin
            m_tmp_q.delete(i);  // Delete the element at index i
        end 
   end
   end
    if(m_tmp_q.size()==1) begin
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Got_CCPFillDataPkt: %s", m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, cpy_pkt.sprint_pkt() ),UVM_LOW)
        //Clear the Pending bit
        m_ott_q[m_tmp_q[0]].isFillDataRcvd = 1'b1;
        m_ott_q[m_tmp_q[0]].isFillDoneEarlyRcvd = 1'b1; //DCTODO RTLCHK check why this was there
        m_ott_q[m_tmp_q[0]].setup_io_cache_fill_data(cpy_pkt);

        
        
        <% if(obj.useCache) { %>
        if(m_ott_q[m_tmp_q[0]].isSMIDTRReqErr && (dtr_err_logged == "null")) begin
            dtrreq_err_set_logged = m_ott_q[m_tmp_q[0]].ccp_index;
            dtrreq_err_way_logged = m_ott_q[m_tmp_q[0]].ccp_way;
            dtr_err_logged            = "true";
        end

        <%}%>


        //Check the fill data only if there is no error on STRreq
        //#Check.IOAIU.CCP.FillDataMatch
        if(!m_ott_q[m_tmp_q[0]].isSMISTRReqAddrErr      &&
           !m_ott_q[m_tmp_q[0]].isSMISTRReqDataErr      &&
           !m_ott_q[m_tmp_q[0]].isSMISTRReqTransportErr &&
           !m_ott_q[m_tmp_q[0]].isSMICMDRespErr         &&
           !m_ott_q[m_tmp_q[0]].isSMIDTRReqDtrDatVisErr &&
           !m_ott_q[m_tmp_q[0]].isSMIDTWrspErr          &&
	   !hasErr
           ) begin
	    //#Check.IOAIU.CCP.FillDataMergeWrData		     
            if(m_ott_q[m_tmp_q[0]].isRead) begin
                convert_dtr_to_fill_data(m_tmp_q[0],fill_data,fill_data_beats,fill_data_poison);
            end else if(m_ott_q[m_tmp_q[0]].isWrite) begin
                merge_write_data(m_tmp_q[0],fill_data,fill_byten,fill_data_beats,fill_data_poison); 
            end
            //#Check.IOAIU.CCPFillData.ByteEn
            if(m_ott_q[m_tmp_q[0]].isWrite && m_ott_q[m_tmp_q[0]].is_write_hit_upgrade) begin
		foreach(fill_byten[i]) begin
		   exp_byten = (m_ott_q[m_tmp_q[0]].dropDtrData) ? fill_byten[i]: all1s;
		   if((cpy_pkt.byten[i] ^ exp_byten) != 0) begin
                       if(!uncorr_OTT_Data_Err_effect) begin
                           // This could result due to uncorr error injection in OTT also, so taking care below
                           uncorr_OTT_Data_Err_effect = 8;// Corruption in : w_odm_rdata -> (CCP fill data will be affected) : Poison bit set for one of the beat in CCP fill
                       end else begin
		           `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Fill Byte Enables are incorrect!!! Exp[%0d]:%0h Fill[%0d]:%0h for OutstTxn #%0d exp_byten:%p act_byten:%p",i,exp_byten,i,cpy_pkt.byten[i],m_tmp_q[0],exp_byten,fill_byten))
                       end
		   end
		end
       
	    end
	
            //#Check.IOAIU.CCPFillData.Poison
            if(cpy_pkt.data.size()>0) begin
				get_bitmask(fill_byten,fill_bitmask);   
				//CONC-9134 
                                // #Check.IOAIU.DTRreq.CMStatusAddrErr.FillAllBeatsPoisoned 
				//If expected fill_data_poison indicates at least one beat poison, it is ok to mark some or whole line poison by RTL --loose check.
				foreach (fill_data_poison[i]) begin
					if (fill_data_poison[i] == 1) 
						exp_fill_data_poisoned = 1;
					if (cpy_pkt.poison[i] == 1) 
						act_fill_data_poisoned = 1;
				end
				//Below check is for poison checks due to bad data on DTRreq
 				if((!aiu_double_bit_errors_enabled) && (exp_fill_data_poisoned != act_fill_data_poisoned) && !m_ott_q[m_tmp_q[0]].ignore_poisoned) begin
                	m_ott_q[m_tmp_q[0]].print_me(0,1);
 					`uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("Fill_Data_Poison mismatch Exp:%0d Act:%0d", exp_fill_data_poisoned, act_fill_data_poisoned))
                end

                //#Check.IOAIU.CCPFillData.Data
                foreach (fill_data[i]) begin
                    if((cpy_pkt.poison[i] == 1) && (!uncorr_OTT_Data_Err_effect || uncorr_OTT_Data_Err_effect == 4'h8)) begin
                        // This could result due to uncorr error injection in OTT also, so taking care below
                        uncorr_OTT_Data_Err_effect = 4 ;// Corruption in : w_odm_rdata -> (CCP fill data will be affected) : Poison bit set for one of the beat in CCP fill
                    end else begin
                        if ((cpy_pkt.poison[i] == 0) && !(((fill_data[i] & fill_bitmask[i]) ^ (cpy_pkt.data[i] & fill_bitmask[i])) == 0)) begin
                            m_ott_q[m_tmp_q[0]].print_me(0,1);
                            spkt = {"(beat:0x%0x Exp:0x%0x Got:0x%0x"};
                            `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$psprintf(spkt,i,fill_data[i],cpy_pkt.data[i]),UVM_NONE)
                            spkt = {"Incorrect fill data"};
                            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
                        end
                    end
                end
		
                //#Check.IOAIU.CCPFillData.BeatNum    
                foreach (fill_data_beats[i]) begin
                    if (((fill_data_beats[i] ^ cpy_pkt.beatn[i]) & cpy_pkt.byten[i]) !== 0) begin
                        m_ott_q[m_tmp_q[0]].print_me(0,1);
                        spkt = {"(Got Beat:0x%0x but Exp Beat:0x%0x ByteN"};
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$psprintf(spkt,cpy_pkt.beatn[i],fill_data_beats[i],cpy_pkt.byten[i]),UVM_NONE)
                        spkt = {"Incorrect fill beat order"};
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
                    end
                end
                
            end else begin
                spkt = {"Monitor crapped out recieved fill data will null size."};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
            end
         end
    end else if(m_tmp_q.size()>1) begin
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Got_CCPFillDataPkt: %s", cpy_pkt.sprint_pkt() ),UVM_LOW)
	s = "";	       
        foreach(m_tmp_q[i]) begin
	    s = $sformatf("%s,%0d",s,m_tmp_q[i]);
            m_ott_q[m_tmp_q[i]].print_me();
        end
        spkt = "Found multiple txn matching the CCP Fill Data Pkt.";
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s, OutStTxn#'s:%s",spkt,s),UVM_NONE)
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end else begin
        spkt = $sformatf("Cannot find any matching pkt for the incoming ccp fill data pkt %s wayn %0d index:%0d",cpy_pkt.sprint_pkt(),cpy_pkt.wayn,m_ccp_index);
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end

endfunction



//=========================================================================
// Function: write_ncbu_ccp_rd_rsp_chnl 
// Purpose: 
// 
// 
//=========================================================================
function void ioaiu_scoreboard::write_ncbu_ccp_rd_rsp_chnl(ccp_rd_rsp_pkt_t m_pkt);
    ccp_rd_rsp_pkt_t  cpy_pkt;
    ccp_rd_rsp_pkt_t  cpy_pkt_tmp;
    int               m_tmp_q[$];
    int               m_tmp_q1[$];
    string            spkt;
    int               m_ccp_index;
    axi_bresp_enum_t m_tmp_resp;
    if(hasErr)
     return;

    cpy_pkt       = new();
    $cast(cpy_pkt_tmp,m_pkt); 
    cpy_pkt.copy(cpy_pkt_tmp);

    m_tmp_q = {}; 
    //#Check.CCP.RdDataExpected
    m_tmp_q = m_ott_q.find_index() with (
//                                        item.isIoCacheTagPipelineSeen  == 1   &&
					((item.isIoCacheTagPipelineSeen) ?
					 (item.m_ccp_ctrl_pkt.lookup_p2 === 0) : 0) &&
                                        item.isIoCacheDataPipelineSeen == 0   &&
                                        item.isRead                    == 1   &&
                                        item.isCCPReadHitDataRcvd      == 0   &&
                                        item.is_ccp_hit                == 1  
                                        );

    if(m_tmp_q.size()==1) begin
        if(m_ott_q[m_tmp_q[0]].isRead) begin
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Got_CCPReadRspPkt: %s",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, cpy_pkt.sprint_pkt() ),UVM_LOW)
            m_ott_q[m_tmp_q[0]].setup_io_cache_read_data(cpy_pkt);
        end else begin
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Got_CCPReadRspPkt: %s",cpy_pkt.sprint_pkt() ), UVM_NONE)
            spkt = {"TB issue cannot determine Cmd type for processing ",
                    " a pkt on CCP read rsp channel"};
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end
        
        //Check the CCP data with cache model data
        if(m_ott_q[m_tmp_q[0]].m_ccp_exp_data.size()>0) begin
            if( m_ott_q[m_tmp_q[0]].m_ccp_exp_data.size() !== 
                m_ott_q[m_tmp_q[0]].m_ccp_rd_rsp_pkt.data.size() ) begin

                spkt = {"Read-Hit data size mismatch Exp:%0d but ",
                        " Got:%0d"};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf(spkt, m_ott_q[m_tmp_q[0]].m_ccp_exp_data.size(),
                            m_ott_q[m_tmp_q[0]].m_ccp_rd_rsp_pkt.data.size()))
            end

            foreach (m_ott_q[m_tmp_q[0]].m_ccp_exp_data[i]) begin
                if ((m_ott_q[m_tmp_q[0]].m_ccp_exp_data[i] !== 
                     m_ott_q[m_tmp_q[0]].m_ccp_rd_rsp_pkt.data[i]) && 
                     !m_ott_q[m_tmp_q[0]].m_ccp_rd_rsp_pkt.poison[i]
                   ) begin
                    
                    m_ott_q[m_tmp_q[0]].m_ccp_cacheline.print();
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
                    spkt = {"(Exp RDATA:0x%0x Got RDATA:0x%0x)"};
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$psprintf(spkt,m_ott_q[m_tmp_q[0]].m_ccp_exp_data[i],
                                m_ott_q[m_tmp_q[0]].m_ccp_rd_rsp_pkt.data[i]),UVM_NONE)
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Incorrect read-hit data from CCP for OutstTxn #%0d",m_tmp_q[0]))
                end
            end
        end else begin
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Got_CCPReadRspPkt: %s",cpy_pkt.sprint_pkt() ), UVM_NONE)
            spkt = {"TB issue couldn't find the read-hit data from ",
                    " the cache model"};
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end

        //Setup the Agent Read resp
        if (m_ott_q[m_tmp_q[0]].isMultiAccess && !m_ott_q[m_tmp_q[0]].isACEReadDataSent 
            && m_ott_q[m_tmp_q[0]].isRead && m_ott_q[m_tmp_q[0]].is_ccp_hit) begin

            if((m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arlen + 1) != 
                m_ott_q[m_tmp_q[0]].m_io_cache_data.size() ) begin
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Got_CCPReadRspPkt: %s",cpy_pkt.sprint_pkt() ), UVM_NONE)
                m_ott_q[m_tmp_q[0]].print_me();
                spkt = {"Read-hit data size mismatch Exp:%0d  ",
                        " but Got:%0d "};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf(spkt,(m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arlen + 1),
                            m_ott_q[m_tmp_q[0]].m_io_cache_data.size()))
                
            end
            m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt       = new(); 
            m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt.rdata = new [m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arlen + 1];
            if (!m_ott_q[m_tmp_q[0]].isMultiLineMaster) begin
                m_ott_q[m_tmp_q[0]].isACEReadDataSent         = 1;
                m_ott_q[m_tmp_q[0]].isACEReadDataSentNoRack   = 1;
                m_ott_q[m_tmp_q[0]].t_ace_read_data_sent      = $time;
            end
            for (int i = 0; i < m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arlen+1; i++) begin
                m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt.rdata[i] = m_ott_q[m_tmp_q[0]].m_io_cache_data[i];
                m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt.rresp_per_beat[i][1:0] = m_ott_q[m_tmp_q[0]].m_axi_resp_expected[i];
            end
        end

        //If it is MultiLine Master and agent response is sent
        //or for non-multi-line txn if an agent response is sent do the data checking.

        // If its a IO cache hit, check data
        if (m_ott_q[m_tmp_q[0]].addrNotInMemRegion === 0) begin
            if (((!m_ott_q[m_tmp_q[0]].isMultiAccess) && m_ott_q[m_tmp_q[0]].is_ccp_hit 
                  && m_ott_q[m_tmp_q[0]].isCCPReadHitDataRcvd && 
                  m_ott_q[m_tmp_q[0]].isACEReadDataSent) ||
                (m_ott_q[m_tmp_q[0]].isMultiAccess && m_ott_q[m_tmp_q[0]].isMultiLineMaster && 
                 m_ott_q[m_tmp_q[0]].is_ccp_hit && m_ott_q[m_tmp_q[0]].isCCPReadHitDataRcvd && 
                  m_ott_q[m_tmp_q[0]].isACEReadDataSent)
                ) begin     
                if (m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt.rdata.size() !== int'(m_ott_q[m_tmp_q[0]].m_io_cache_data.size()) && !aiu_nodetEn_err_inj /* && !aiu_double_bit_errors_enabled*/) begin
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Got_CCPReadRspPkt: %s",cpy_pkt.sprint_pkt() ), UVM_NONE)
                    m_ott_q[m_tmp_q[0]].print_me();
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE read data is not the same as data received from SMI DTR (ACE:%s SMI:%p)",  m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt.sprint_pkt(), m_ott_q[m_tmp_q[0]].m_io_cache_data), UVM_NONE);
                end
                    foreach (m_ott_q[m_tmp_q[0]].m_io_cache_data[i]) begin
                        if (m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt.rdata[i] !== m_ott_q[m_tmp_q[0]].m_io_cache_data[i] && !m_ott_q[m_tmp_q[0]].m_io_cache_dat_err[i]) begin
                            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Got_CCPReadRspPkt: %s",cpy_pkt.sprint_pkt() ), UVM_NONE)
                            m_ott_q[m_tmp_q[0]].print_me();
                            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing ACE Read data packet for IO cache hit has wrong read data (Expected:0x%0x Actual: 0x%0x beat:0x%0x)", m_ott_q[m_tmp_q[0]].m_io_cache_data[i], m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt.rdata[i],i), UVM_NONE);
                        end
                    end
                foreach (m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt.rresp_per_beat[i]) begin
                    m_tmp_resp = axi_bresp_enum_t'(m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt.rresp_per_beat[i][1:0]);
                    if ((m_ott_q[m_tmp_q[0]].m_axi_resp_expected[i] !== m_tmp_resp) &&  !aiu_double_bit_errors_enabled) begin
                            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Got_CCPReadRspPkt: %s",cpy_pkt.sprint_pkt() ), UVM_NONE)
                            m_ott_q[m_tmp_q[0]].print_me();
                            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("1 ACE read data rresp field returned an %s message which is not expected", m_tmp_resp.name()), UVM_NONE);   
                    end
                end
            end
        end


        if ( m_ott_q[m_tmp_q[0]].isRead && 
             (m_ott_q[m_tmp_q[0]].is_ccp_hit === 1) &&
             (m_ott_q[m_tmp_q[0]].isACEReadDataSent === 1) &&
             (m_ott_q[m_tmp_q[0]].isMultiAccess ? m_ott_q[m_tmp_q[0]].multiline_ready_to_delete:1)
        ) begin
            delete_ott_entry(m_tmp_q[0], IOCData);
        end else begin
            if(m_ott_q[m_tmp_q[0]].isMultiAccess &&  !m_ott_q[m_tmp_q[0]].multiline_ready_to_delete) begin
                m_ott_q[m_tmp_q[0]].multiline_ready_to_delete = 1;
            end
        end


    end else if (m_tmp_q.size()>1) begin
        m_tmp_q[0] = find_oldest_ccp_lookup_q(m_tmp_q);

        if(m_ott_q[m_tmp_q[0]].isRead) begin
            m_ott_q[m_tmp_q[0]].setup_io_cache_read_data(cpy_pkt);
        end else begin
            spkt = {"TB issue cannot determine Cmd type for processing ",
                    " a pkt on CCP read rsp channel"};
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end

        //Check the CCP data with cache model data
        if(m_ott_q[m_tmp_q[0]].m_ccp_exp_data.size()>0) begin
            if( m_ott_q[m_tmp_q[0]].m_ccp_exp_data.size() !== 
                m_ott_q[m_tmp_q[0]].m_ccp_rd_rsp_pkt.data.size() ) begin

                spkt = {"Read-Hit data size mismatch Exp:%0d but ",
                        " Got:%0d"};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf(spkt, m_ott_q[m_tmp_q[0]].m_ccp_exp_data.size(),
                            m_ott_q[m_tmp_q[0]].m_ccp_rd_rsp_pkt.data.size()))
            end
            
            //#Check.IOAIU.CCPReadRsp.Data
            foreach (m_ott_q[m_tmp_q[0]].m_ccp_exp_data[i]) begin
                if ((m_ott_q[m_tmp_q[0]].m_ccp_exp_data[i] !== 
                     m_ott_q[m_tmp_q[0]].m_ccp_rd_rsp_pkt.data[i]) && 
                     !m_ott_q[m_tmp_q[0]].m_ccp_rd_rsp_pkt.poison[i]
                   ) begin
                    
                    m_ott_q[m_tmp_q[0]].m_ccp_cacheline.print();
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
                    spkt = {"(Exp RDATA:0x%0x Got RDATA:0x%0x)"};
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$psprintf(spkt,m_ott_q[m_tmp_q[0]].m_ccp_exp_data[i],
                                m_ott_q[m_tmp_q[0]].m_ccp_rd_rsp_pkt.data[i]),UVM_NONE)
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Incorrect read-hit data from CCP for OutstTxn #%0d",m_tmp_q[0]))
                end
            end
        end else begin
            spkt = {"TB issue couldn't find the read-hit data from ",
                    " the cache model"};
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end


        //Setup the Agent Read resp
        if (m_ott_q[m_tmp_q[0]].isMultiAccess && !m_ott_q[m_tmp_q[0]].isACEReadDataSent 
            && m_ott_q[m_tmp_q[0]].isRead && m_ott_q[m_tmp_q[0]].is_ccp_hit) begin

            if((m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arlen + 1) != 
                m_ott_q[m_tmp_q[0]].m_io_cache_data.size() ) begin
                m_ott_q[m_tmp_q[0]].print_me();
                spkt = {"Read-hit data size mismatch Exp:%0d  ",
                        " but Got:%0d "};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf(spkt,(m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arlen + 1),
                            m_ott_q[m_tmp_q[0]].m_io_cache_data.size()))
                
            end

            m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt       = new(); 
            m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt.rdata = new [m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arlen + 1];
            if (!m_ott_q[m_tmp_q[0]].isMultiLineMaster) begin
                m_ott_q[m_tmp_q[0]].isACEReadDataSent         = 1;
                m_ott_q[m_tmp_q[0]].isACEReadDataSentNoRack   = 1;
                m_ott_q[m_tmp_q[0]].t_ace_read_data_sent      = $time;
            end
            for (int i = 0; i < m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.arlen+1; i++) begin
                m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt.rdata[i] = m_ott_q[m_tmp_q[0]].m_io_cache_data[i];
                m_ott_q[m_tmp_q[0]].m_ace_read_data_pkt.rresp_per_beat[i][1:0] = m_ott_q[m_tmp_q[0]].m_axi_resp_expected[i];
            end
        end

        if ( m_ott_q[m_tmp_q[0]].isRead && 
             (m_ott_q[m_tmp_q[0]].is_ccp_hit === 1) &&
             (m_ott_q[m_tmp_q[0]].isACEReadDataSent === 1) &&
             (m_ott_q[m_tmp_q[0]].isMultiAccess ? m_ott_q[m_tmp_q[0]].multiline_ready_to_delete:1)
        ) begin
            delete_ott_entry(m_tmp_q[0], IOCData);
        end else begin
            if(m_ott_q[m_tmp_q[0]].isMultiAccess &&  !m_ott_q[m_tmp_q[0]].multiline_ready_to_delete) begin
                m_ott_q[m_tmp_q[0]].multiline_ready_to_delete = 1;
            end
        end

    end else begin
        spkt = {"Cannot find any matching txn for the ccp read resp chnl: %s", cpy_pkt.sprint_pkt()};
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end

endfunction:write_ncbu_ccp_rd_rsp_chnl

//=========================================================================
// Function: write_ncbu_ccp_evict_chnl 
// Purpose: 
// 
// 
//=========================================================================
function void ioaiu_scoreboard::write_ncbu_ccp_evict_chnl(ccp_evict_pkt_t m_pkt);
    ccp_evict_pkt_t     cpy_pkt;
    ccp_evict_pkt_t     cpy_pkt_tmp;
    int                 m_tmp_q[$];
    int                 m_tmp_q1[$];
    string              spkt;
    int                 m_ccp_index;
    if(hasErr)
     return;

    cpy_pkt       = new();
    $cast(cpy_pkt_tmp,m_pkt); 
    cpy_pkt.copy(cpy_pkt_tmp);

<% if(obj.COVER_ON && obj.useCache) { %>
    `ifndef FSYS_COVER_ON
    cov.collect_ncbu_ccp_evict_chnl(m_pkt, core_id);
    `endif
<% } %>  

    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Got_CCPEvictPkt: %s",cpy_pkt.sprint_pkt() ),UVM_MEDIUM)
    //#Check.IOAIU.CCP.EvictExpected
    m_tmp_q = {}; 
    m_tmp_q = m_ott_q.find_index() with (
                                        item.isIoCacheTagPipelineSeen  == 1   &&
                                        item.isIoCacheDataPipelineSeen == 0   &&
                                        ((item.isIoCacheEvictDataRcvd   == 0   &&
                                        item.is_ccp_hit                == 0   &&
                                        item.isIoCacheEvictNeeded      == 1   &&
                                        item.isSMIDTWReqNeeded         == 1   && 
                                        item.isSMIDTWReqSent           == 0   && 
                                        item.isIoCacheEvict            == 1)  ||
                                        (item.isSnoop                  == 1   &&
                                         item.isAddrBlocked            == 0   &&
                                         item.is_ccp_hit               == 1   &&
                                         (item.isSMISNPDTRReqNeeded    == 1   ||
                                          item.isSMIDTWReqNeeded       == 1)))
                                        );

    if(m_tmp_q.size()==1) begin
        if (m_ott_q[m_tmp_q[0]].isSnoop) begin
            m_ott_q[m_tmp_q[0]].setup_io_cache_snoop_data(cpy_pkt);
        end else if(m_ott_q[m_tmp_q[0]].isIoCacheEvict) begin
            m_ott_q[m_tmp_q[0]].setup_io_cache_evict_data(cpy_pkt);
        end else begin
            spkt = {"TB issue cannot determine Cmd type for processing ",
                    " a pkt on CCP read rsp channel"};
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end

        eviction_addr = m_ott_q[m_tmp_q[0]].m_sfi_addr;
        evict_id      = m_ott_q[m_tmp_q[0]].m_id;
        eviction_security  = m_ott_q[m_tmp_q[0]].m_security;

        //Check the CCP data with cache model data
        if(m_ott_q[m_tmp_q[0]].m_ccp_exp_data.size()>0) begin
            if( m_ott_q[m_tmp_q[0]].m_ccp_exp_data.size() !== 
                m_ott_q[m_tmp_q[0]].m_io_cache_data.size() ) begin

                spkt = {"Snoop/Evict data size mismatch Exp:%0d but ",
                        " Got:%0d"};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf(spkt,m_ott_q[m_tmp_q[0]].m_ccp_exp_data.size(),
                            m_ott_q[m_tmp_q[0]].m_io_cache_data.size()))
            end
		     //#Check.IOAIU.CCP.EvictData
            foreach (m_ott_q[m_tmp_q[0]].m_ccp_exp_data[i]) begin
                if ((m_ott_q[m_tmp_q[0]].m_ccp_exp_data[i] !== 
                     m_ott_q[m_tmp_q[0]].m_io_cache_data[i])  &&
                     !cpy_pkt.poison[i] && !$test$plusargs("address_error_test_data")
                   ) begin
                    m_ott_q[m_tmp_q[0]].m_ccp_cacheline.print();
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
//                    spkt = {"(Exp DATA:0x%0x Got DATA:0x%0x)"};
//                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$psprintf(spkt,m_ott_q[m_tmp_q[0]].m_ccp_exp_data[i],
//                                m_ott_q[m_tmp_q[0]].m_io_cache_data[i]),UVM_NONE)
                    spkt = $sformatf("Incorrect snoop/evict data from CCP for OutstTxn#%0d (Exp DATA:0x%0x Got DATA:0x%0x)",m_tmp_q[0],m_ott_q[m_tmp_q[0]].m_ccp_exp_data[i],m_ott_q[m_tmp_q[0]].m_io_cache_data[i]);
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
                end
            end
        end else begin
            spkt = {"TB issue couldn't find the read-hit data from ",
                    " the cache model"};
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end

    end else if(m_tmp_q.size()>1) begin
        m_tmp_q[0] = find_oldest_ccp_lookup_q(m_tmp_q);

        if (m_ott_q[m_tmp_q[0]].isSnoop) begin
            m_ott_q[m_tmp_q[0]].setup_io_cache_snoop_data(cpy_pkt);
        end else if(m_ott_q[m_tmp_q[0]].isIoCacheEvict) begin
            m_ott_q[m_tmp_q[0]].setup_io_cache_evict_data(cpy_pkt);
        end else begin
            spkt = {"TB issue cannot determine Cmd type for processing ",
                    " a pkt on CCP snoop/evict rsp channel"};
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end
        
        //Check the CCP data with cache model data
        if(m_ott_q[m_tmp_q[0]].m_ccp_exp_data.size()>0) begin
            if( m_ott_q[m_tmp_q[0]].m_ccp_exp_data.size() !== 
                m_ott_q[m_tmp_q[0]].m_io_cache_data.size() ) begin

                spkt = {"Snoop/Evict data size mismatch Exp:%0d but ",
                        " Got:%0d"};
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf(spkt, m_ott_q[m_tmp_q[0]].m_ccp_exp_data.size(),
                            m_ott_q[m_tmp_q[0]].m_io_cache_data.size()))
            end

            foreach (m_ott_q[m_tmp_q[0]].m_ccp_exp_data[i]) begin
                if ((m_ott_q[m_tmp_q[0]].m_ccp_exp_data[i] !== 
                     m_ott_q[m_tmp_q[0]].m_io_cache_data[i]) && 
                    !cpy_pkt.poison[i]
                   ) begin
                    
                    m_ott_q[m_tmp_q[0]].m_ccp_cacheline.print();
                    m_ott_q[m_tmp_q[0]].print_me(0,1);
                    spkt = $sformatf("Incorrect snoop/evict data from CCP for OutstTxn#%0d (Exp DATA:0x%0x Got DATA:0x%0x)",m_tmp_q[0],m_ott_q[m_tmp_q[0]].m_ccp_exp_data[i],m_ott_q[m_tmp_q[0]].m_io_cache_data[i]);
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)

                end
            end
        end else begin
            spkt = {"TB issue couldn't find the snoop/evict data from ",
                    " the cache model"};
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end

    end else begin
        spkt = $sformatf("Cannot find any matching pkt for the incoming ccp evict data pkt %s",cpy_pkt.sprint_pkt());
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end


endfunction

//=========================================================================
// Function: convert_dtr_to_fill_data 
// Purpose: 
// 
// 
// Spoke to Boon on 11/28/2016 and according to him he will always write
// to CCP in DTR order
//=========================================================================
function void ioaiu_scoreboard::convert_dtr_to_fill_data( 
                        input int                 ott_index,
                        output ccp_ctrlfill_data_t fill_data[],
                        output int                 fill_data_beats[],
                        output ccp_data_poision_t  fill_data_poison[]
                        );


    smi_dp_data_bit_t dtr_req_data[];
    axi_axaddr_t addr;


    bit [$clog2(CACHELINE_SIZE)-1:0] beat_offset;
    string spkt;

    dtr_req_data = m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_dp_data;
    addr         = m_ott_q[ott_index].m_sfi_addr;
    
    beat_offset = addr[SYS_wSysCacheline-1:WLOGXDATA];

    if(dtr_req_data.size()>0) begin
        fill_data        = new[dtr_req_data.size()];
        fill_data_beats  = new[dtr_req_data.size()];
        fill_data_poison = new[dtr_req_data.size()];

       err_ind = err_id_addr_q.find_index(x) with (x[127:64] == m_ott_q[ott_index].m_ace_read_addr_pkt.arid && x[63:0] == m_ott_q[ott_index].m_ace_read_addr_pkt.araddr);
        if(err_ind.size() == 1)
        ott_err_detected = 1;
      

        for(int i=0; i<dtr_req_data.size();i++) begin
            fill_data[i]       = dtr_req_data[i];
            fill_data_beats[i] = beat_offset;

            if (m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_dp_be[i] !== '1 
            	|| m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_cmstatus inside {8'h83,8'h84} 
            	|| (|m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_dp_dbad[i]) == 1'b1
            	|| (m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_cmstatus_err && m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_cmstatus_err_payload == 3)
            	|| (m_ott_q[ott_index].dtrreq_cmstatus_err && m_ott_q[ott_index].m_dtr_req_pkt.smi_cmstatus_err_payload == 3)
                || (ott_err_detected)
            	) begin
                //#Check.IOAIU.DTRreq.CMStatusAddrErr.FillAllBeatsPoisoned
                fill_data_poison[i] = 1'b1;
            end else begin
                fill_data_poison[i] = 1'b0;
            end
             //#Check.IOAIU.OTTUnCorrectableErr.ReadMiss_FillDataPoison
             //#Check.IOAIU.ACE.DTRreq.ErrorPropogation
             <%if(obj.assertOn && obj.testBench =="io_aiu"){%>
 	     <%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) { %> 
             if($test$plusargs("write_address_error_test_ott"))
             fill_data_poison[i] = 1'b1;
             <% } %>
             <% if(obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITY") { %> 
             if($test$plusargs("ccp_sram_addr_data_error_test"))
             fill_data_poison[i] = 1'b1;
             <% } %>
             <% } %>


            beat_offset = beat_offset + 1;
            ott_err_detected = 0;
        end
    end else begin
        spkt = {"In function convert_dtr_to_fill_data input data size is null can't convert",
                " dtr packet to fill data packet"};
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end

endfunction


//=========================================================================
// Function: convert_agent_data_to_ccp_data 
// Purpose: 
// 
// 
//=========================================================================
function void ioaiu_scoreboard::convert_agent_data_to_ccp_data( 
                        input axi_xdata_t    agent_wr_hit_data[],
                        input axi_axaddr_t   addr,
                        input int                                       ott_index,
                        output ccp_ctrlwr_data_t                        ccp_data[],
                        output int                                      ccp_data_beat[]
                        );


    bit [$clog2(CACHELINE_SIZE)-1:0] beat_offset;
    string spkt;
    int no_of_bytes;
    int burst_length;
    longint m_lower_wrapped_boundary;
    longint m_upper_wrapped_boundary;
    longint m_start_addr;


    parameter LINE_INDEX_LOW  = $clog2(DATA_WIDTH/8);
    parameter LINE_INDEX_HIGH = LINE_INDEX_LOW + $clog2(CACHELINE_SIZE) - 1;
    
    beat_offset = addr[SYS_wSysCacheline-1:WLOGXDATA];

    if(agent_wr_hit_data.size()>0) begin
        ccp_data      = new[agent_wr_hit_data.size()];
        ccp_data_beat = new[agent_wr_hit_data.size()];

        no_of_bytes               = (DATA_WIDTH/8);
        burst_length              = m_ott_q[ott_index].m_ace_write_addr_pkt.awlen+1;

        m_start_addr             = ((addr/(DATA_WIDTH/8)) * (DATA_WIDTH/8));
        m_lower_wrapped_boundary = ((addr/(no_of_bytes * burst_length)) * (no_of_bytes*burst_length)); 
        m_upper_wrapped_boundary = m_lower_wrapped_boundary + (no_of_bytes * burst_length); 

        for(int i=0; i<agent_wr_hit_data.size();i++) begin

            if((m_ott_q[ott_index].m_ace_write_addr_pkt.awburst == 'h2) && (m_start_addr >= m_upper_wrapped_boundary) 
                && ~m_ott_q[ott_index].isMultiAccess) begin
                beat_offset = m_lower_wrapped_boundary[LINE_INDEX_HIGH:LINE_INDEX_LOW];
            end 

            if((m_ott_q[ott_index].m_ace_write_addr_pkt.awburst == 'h2) && (m_start_addr >= m_upper_wrapped_boundary) ) begin
                m_start_addr = m_lower_wrapped_boundary;
            end else begin
                m_start_addr = m_start_addr + no_of_bytes;
            end

            ccp_data[i]      = agent_wr_hit_data[i];
            ccp_data_beat[i] = beat_offset;
            beat_offset      = beat_offset + 1'b1;
        end
    end else begin
        spkt = {"In function convert_agent_data_to_ccp_data input data size is null can't convert",
                " dtr packet to fill data packet"};
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end

endfunction

//=========================================================================
// Function: merge_write_data 
// Purpose: 
// 
// 
//=========================================================================
function void ioaiu_scoreboard::merge_write_data(
                        input int                 ott_index,
                        output ccp_ctrlfill_data_t ccp_data[],
                        output ccp_ctrlfilldata_byten_t ccp_byten[],
                        output int                 ccp_data_beat[],
                        output ccp_data_poision_t  ccp_data_poison[]
                        );

    ccp_ctrlfilldata_byten_t exp_byten[];
    axi_xdata_t          cpy_sfi_data[];
    smi_dp_dbad_t        cpy_sfi_dbad[];
    axi_xdata_t          exp_data[];
    bit                  exp_dbad[];
    axi_axaddr_t         addr;
    int m_tmp_q[$];
    bit [$clog2(CACHELINE_SIZE)-1:0] data_beat;
    bit [$clog2(CACHELINE_SIZE)-1:0] sfi_data_beat;
    int no_of_bytes;
    int burst_length;
    string sprint_pkt;
    longint m_lower_wrapped_boundary;
    longint m_upper_wrapped_boundary;
    longint m_start_addr;
    int data_size;
    int updated_beat_num[];
    bit ccp_fill_data_poisoned = 0;


    parameter LINE_INDEX_LOW  = $clog2(DATA_WIDTH/8);
    parameter LINE_INDEX_HIGH = LINE_INDEX_LOW + $clog2(CACHELINE_SIZE) - 1;
    no_of_bytes               = (DATA_WIDTH/8);
    burst_length              = m_ott_q[ott_index].m_ace_write_addr_pkt.awlen+1;

    addr                      = m_ott_q[ott_index].m_sfi_addr;

    if(m_ott_q[ott_index].isPartialWrite) begin                                    
        data_size                 = m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_dp_data.size();
    end else begin
        data_size                 = m_ott_q[ott_index].m_ace_write_data_pkt.wdata.size();
    end

    //For a wrap the SMI data will be returned in critical beat
    //first so i need to store the data correctly.
    sfi_data_beat        = addr[LINE_INDEX_HIGH:LINE_INDEX_LOW];
    cpy_sfi_data         = new[data_size];
    cpy_sfi_dbad         = new[data_size];
    exp_byten            = new[data_size];
    exp_dbad             = new[data_size];
    updated_beat_num     = new[data_size];
    foreach(updated_beat_num[i]) updated_beat_num[i] = 0;// reseting
    
    if(m_ott_q[ott_index].isPartialWrite) begin                                    
        for(int i=0; i<data_size;i++) begin
            cpy_sfi_data[sfi_data_beat] = m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_dp_data[i];
            cpy_sfi_dbad[sfi_data_beat] = m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_dp_dbad[i];
            sfi_data_beat               = sfi_data_beat + 1'b1;
        end
    end
    
    if(!m_ott_q[ott_index].dropDtrData) begin
        exp_data  = cpy_sfi_data;
        for(int i=0; i<data_size;i++) begin
	    exp_dbad[i]  = |cpy_sfi_dbad[i];
        end
    end else begin
	m_tmp_q = {};
        m_tmp_q = m_ncbu_cache_q.find_index() with (
                    item.tag   == m_ott_q[ott_index].ccp_addr     &&
                    item.Index  == m_ott_q[ott_index].ccp_index     &&
                    item.security == m_ott_q[ott_index].m_security);
	
        if(m_tmp_q.size() == 0) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> fn:merge_write_data dropDtrData=1 i.e SD->SD/SD->SC when DTRreq arrived, how can it miss in the cache-model", m_ott_q[ott_index].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,m_ott_q[ott_index].core_id<%}%>));
	end
	else begin
	    exp_data = m_ncbu_cache_q[m_tmp_q[0]].data;		   
            exp_dbad = m_ncbu_cache_q[m_tmp_q[0]].dataErrorPerBeat;
	end
    end
			   					   
    //Caclulate the Wrap address based on the AXI spec
    m_start_addr             = ((addr/(DATA_WIDTH/8)) * (DATA_WIDTH/8));
    m_lower_wrapped_boundary = ((addr/(no_of_bytes * burst_length)) * (no_of_bytes*burst_length)); 
    m_upper_wrapped_boundary = m_lower_wrapped_boundary + (no_of_bytes * burst_length); 
    

    //Update the cacheline data
    data_beat = addr[LINE_INDEX_HIGH:LINE_INDEX_LOW];

    
    for(int i=0; i<burst_length;i++) begin
        if((m_ott_q[ott_index].m_ace_write_addr_pkt.awburst == 'h2) && (m_start_addr >= m_upper_wrapped_boundary) 
            && ~m_ott_q[ott_index].isMultiAccess ) begin
            data_beat = m_lower_wrapped_boundary[LINE_INDEX_HIGH:LINE_INDEX_LOW];
        end 
   
        if((m_ott_q[ott_index].m_ace_write_addr_pkt.awburst == 'h2) && (m_start_addr >= m_upper_wrapped_boundary) ) begin
            m_start_addr = m_lower_wrapped_boundary;
        end else begin
            m_start_addr = m_start_addr + no_of_bytes;
        end

        //`uvm_info("MUFFADAL",$psprintf("BEAT:%0d and Start Addr:%0h",data_beat,m_start_addr),UVM_MEDIUM)
        updated_beat_num[data_beat] = 1;
        for(int index_bit=0; index_bit<no_of_bytes;index_bit++) begin
            if(m_ott_q[ott_index].m_ace_write_data_pkt.wstrb[i][index_bit] == 1'b1) begin
                exp_byten[data_beat][index_bit] = 1'b1;
                exp_data[data_beat][(8*index_bit) +: 8] = 
                m_ott_q[ott_index].m_ace_write_data_pkt.wdata[i][(8*index_bit) +: 8];
            end else begin
                updated_beat_num[data_beat] = 0;
            end
        end

        if (m_ott_q[ott_index].m_ace_write_data_pkt.wstrb[i] == '1 || |m_ott_q[ott_index].m_ace_write_data_pkt.wstrb[i] == '0) begin
           exp_dbad[data_beat] = 1'b0; 
        end

        data_beat = data_beat +  1'b1;
        
    end
    
    ccp_data           = new[data_size];
    ccp_byten          = new[data_size];
    ccp_data_beat      = new[data_size];
    ccp_data_poison    = new[data_size];
    sfi_data_beat = addr[LINE_INDEX_HIGH:LINE_INDEX_LOW];

    for(int i=0; i<data_size;i++) begin
        ccp_data[i]         = exp_data[sfi_data_beat];
        ccp_data_poison[i]  = exp_dbad[sfi_data_beat];
        ccp_byten[i]        = exp_byten[sfi_data_beat];
        ccp_data_beat[i]    = sfi_data_beat;
        
		uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Adding cacheline 0x%0h ccp_addr 0x%0h",m_ott_q[ott_index].m_sfi_addr,m_ott_q[ott_index].ccp_addr),UVM_MEDIUM);

        if(m_ott_q[ott_index].isPartialWrite) begin 
      
            if((|m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_dp_dbad[i] == 0) && exp_dbad[sfi_data_beat] == 1) begin
            ccp_data_poison[i]  = 1'b0;
            ccp_fill_data_poisoned = 0;
            end                                   

            if((|m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_dp_dbad[i] == 1) && ((m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_dp_data[i] == m_ott_q[ott_index].wr_ccp_data[i] && (|m_ott_q[ott_index].m_ace_write_data_pkt.wstrb[i] =='0)) || (m_ott_q[ott_index].m_ace_write_data_pkt.wdata[i] != m_ott_q[ott_index].wr_ccp_data[i] && |m_ott_q[ott_index].m_ace_write_data_pkt.wstrb[i] !='0))) begin                
		ccp_data_poison[i]  = 1'b1;
                ccp_fill_data_poisoned = 1;
            end

            
           if(|m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_dp_be[i]=='0)  
           m_ott_q[ott_index].ignore_poisoned =1 ;
        end
        sfi_data_beat       = sfi_data_beat + 1'b1;
    end
       
	//CONC-9134
        //#Check.IOAIU.OTTUnCorrectableErr.WriteHit_WrDataPoison
	//It is okay to mark the whole CL as poisoned if only one beat of either source of merge data is poisoned
	if (m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt != null) begin 
		if (ccp_fill_data_poisoned && m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_cmstatus inside {8'h84}) begin 
			foreach(ccp_data_poison[i]) ccp_data_poison[i] = 1; 
		end
       if((m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_cmstatus == 8'h83) && m_ott_q[ott_index].m_ace_write_data_pkt.wdata[0] != m_ott_q[ott_index].wr_ccp_data[0]) begin
          	ccp_data_poison[0]  = 1'b1;
                ccp_fill_data_poisoned = 1;
       end
                <%if(obj.assertOn && obj.testBench =="io_aiu"){%>
 		<%if((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) { %> 
                if($test$plusargs("write_address_error_test_ott"))
                foreach(ccp_data_poison[i]) ccp_data_poison[i] = 1;
                 <% } %>
                <% if(obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITY") { %> 
                if($test$plusargs("ccp_sram_addr_data_error_test"))
                foreach(ccp_data_poison[i]) ccp_data_poison[i] = 1;
                <% } %>
                <% } %>

		if (m_ott_q[ott_index].m_dtr_req_for_dtw_hndbk_pkt.smi_cmstatus inside {8'h84})//Trying to match RTL behavior
			 foreach(ccp_data_poison[i]) ccp_data_poison[i] = 1;

	end
endfunction: merge_write_data


function void ioaiu_scoreboard::get_bitmask(input ccp_ctrlfilldata_byten_t byten[],
					    output ccp_ctrlfill_data_t bitmask[]
					    );
    bitmask = new[byten.size()];
    for(int i=0; i < byten.size();i++) begin
        for(int index_bit=0; index_bit<WXDATA;index_bit++) begin
            if(byten[i][index_bit] == 1'b1) begin
                bitmask[i][(8*index_bit) +: 8] = 8'hff;
            end
        end
    end
endfunction : get_bitmask
		       

function axi_axaddr_t ioaiu_scoreboard::shift_addr(input axi_axaddr_t in_addr);
    axi_axaddr_t out_addr;
    out_addr = in_addr[WAXADDR - 1:SYS_wSysCacheline];
    return out_addr;
endfunction


function int ioaiu_scoreboard::onehot_to_binay(bit [N_WAY-1:0] in_word);
    int position;
    
    position = -1;
    for(int i=0; i<$size(in_word); i++) begin
        if(in_word[i] == 1) begin
            position = i;
            break;
        end
    end

    return position;

endfunction

function void ioaiu_scoreboard::set_cacheline_way(ioaiu_scb_txn scb_txn);
    int m_tmp_q[$];
    m_tmp_q = {};
    m_tmp_q = m_ncbu_cache_q.find_index() with (
                                        item.tag   == scb_txn.ccp_addr     &&
                                        item.Index  == scb_txn.ccp_index     &&
                                        item.security == scb_txn.m_security   
                                        );
    if((m_tmp_q.size()>0)) begin
	scb_txn.ccp_way = m_ncbu_cache_q[m_tmp_q[0]].way; 
    end
endfunction

function ccp_cachestate_enum_t ioaiu_scoreboard::return_cacheline_state(axi_axaddr_t m_addr, bit m_security);
    int m_tmp_q[$];
    m_tmp_q = {};
    m_tmp_q = m_ncbu_cache_q.find_index() with (item.tag == m_addr && item.security == m_security);
    if (m_tmp_q.size == 0) begin
        return IX;
    end else begin
//	m_ncbu_cache_q[m_tmp_q[0]].print();
        return m_ncbu_cache_q[m_tmp_q[0]].state;
    end 
endfunction : return_cacheline_state
function void ioaiu_scoreboard::check_ccp_ctrl(ccp_ctrl_pkt_t m_pkt, int ott_index);
    int m_tmp_q[$];
    bit [N_CCP_WAYS-1:0] allocated_way_vec;

    <%if(obj.AiuInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>

        if (m_pkt.rp_update == 1) begin 
            allocated_way_vec = get_allocated_ways_vec(m_pkt);
            plru_valid_ways = (|(~m_pkt.waypbusy_vec & ~allocated_way_vec)) ? ~m_pkt.waypbusy_vec & ~allocated_way_vec : ~m_pkt.waypbusy_vec & allocated_way_vec; 

            if (plru_state.exists(m_pkt.setindex) == 0)
                plru_state[m_pkt.setindex] = 0;
            plru_curr_state = plru_state[m_pkt.setindex];

            if (m_pkt.alloc == 1 && m_pkt.currstate == IX) begin:_alloc_cache_miss_

                //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("PLRU:setIndex:0x%0h allocated_way_vec:0b%0b busy_vec:0b%0b plru_valid_ways:0b%0b", m_pkt.setindex, allocated_way_vec, m_pkt.waypbusy_vec, plru_valid_ways), UVM_LOW)
                void'(<%=obj.BlockId%>_ccp_agent_pkg::ccp_plru_predictor(plru_valid_ways,0,plru_curr_state,plru_victim_way,plru_nxt_state));
                
                //#Check.IOAIU.CCPCtrlPkt.plruAllocWay
                if (onehot_to_binay(plru_victim_way) != m_pkt.wayn && !($test$plusargs("plru_single_bit_direct_error_test") || $test$plusargs("plru_double_bit_direct_error_test") || $test$plusargs("plru_address_error_test") )) begin 
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("PLRU:alloc_way mismatch Expected:%0d Actual:%0d (setIndex:0x%0h plru_valid_ways:0x%0h plru_curr_state:0x%0h plru_victim_way:0x%0h plru_nxt_state:0x%0h)", onehot_to_binay(plru_victim_way), m_pkt.wayn, m_pkt.setindex, plru_valid_ways, plru_curr_state, plru_victim_way, plru_nxt_state))
                end else begin 
                    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("PLRU: alloc_way matched Expected:%0d Actual:%0d (setIndex:0x%0h plru_valid_ways:0x%0h plru_curr_state:0x%0h plru_victim_way:0x%0h plru_nxt_state:0x%0h)", onehot_to_binay(plru_victim_way), m_pkt.wayn, m_pkt.setindex, plru_valid_ways, plru_curr_state, plru_victim_way, plru_nxt_state), UVM_LOW)
                end
            end: _alloc_cache_miss_
            else if (m_pkt.currstate != IX) begin: _cache_hit_
                void'(<%=obj.BlockId%>_ccp_agent_pkg::ccp_plru_predictor(plru_valid_ways,m_pkt.hitwayn, plru_curr_state, plru_victim_way, plru_nxt_state));
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("PLRU:updated in case of cache-hit (setIndex:0x%0h hitwayn:'b%0b plru_curr_state:0x%0h plru_nxt_state:0x%0h)", m_pkt.setindex, m_pkt.hitwayn, plru_curr_state, plru_nxt_state), UVM_LOW)
            end: _cache_hit_
            
            else begin 
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("PLRU:rp_update asserted but txn is neither a cache-hit nor allocating miss"))
            end 
            plru_state[m_pkt.setindex] = plru_nxt_state;
        end 
    <%}%>

    m_tmp_q = {};
    m_tmp_q = m_ncbu_cache_q.find_index() with (
                                        item.tag   == m_ott_q[ott_index].ccp_addr     &&
                                        item.Index  == m_ott_q[ott_index].ccp_index     &&
                                        item.security == m_ott_q[ott_index].m_security   
                                        );
    if(m_tmp_q.size > 0)		       
       m_ott_q[ott_index].checkExpCcpCtrl(m_pkt,m_ncbu_cache_q[m_tmp_q[0]],$sformatf("OutstTxn #%0d",ott_index));
    else
       m_ott_q[ott_index].checkExpCcpCtrl(m_pkt,null,$sformatf("OutstTxn #%0d",ott_index));		       
endfunction : check_ccp_ctrl
		       

function void ioaiu_scoreboard::check_cacheline_state(ccp_ctrl_pkt_t m_pkt);
    if( !m_pkt.nackuce && !m_pkt.nack && (m_pkt.currstate !== return_cacheline_state(shift_addr(m_pkt.addr),m_pkt.security))) begin
	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Above CCP Ctrl Pkt had incorrect currstate for addr:0x%0h security:0x%0h. Exp:%s Act:%s",m_pkt.addr,m_pkt.security,return_cacheline_state(shift_addr(m_pkt.addr),m_pkt.security).name(),m_pkt.currstate.name()),UVM_NONE);
	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s",m_pkt.sprint_pkt()),UVM_NONE);
	uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Above CCP Ctrl Pkt had incorrect currstate"),UVM_NONE);
    end
endfunction // check_cacheline_state
		       
function void ioaiu_scoreboard::update_cacheline_state(int ott_index, string s = "");
    ccp_cachestate_enum_t prev_state;		       
    int m_tmp_q[$];
    m_tmp_q = {};
    m_tmp_q = m_ncbu_cache_q.find_index() with (
                                        item.tag   == m_ott_q[ott_index].ccp_addr     &&
                                        item.Index  == m_ott_q[ott_index].ccp_index     &&
                                        item.security == m_ott_q[ott_index].m_security   
                                        );

   if(m_tmp_q.size > 0) begin
	prev_state = m_ncbu_cache_q[m_tmp_q[0]].state;
	//only do stuff if cacheline is actually there	       
	if(m_ott_q[ott_index].isSnoop) begin
	    case(m_ott_q[ott_index].m_snp_req_pkt.smi_msg_type)
	       SNP_CLN_DTR,SNP_NOSDINT : begin
		  case(m_ncbu_cache_q[m_tmp_q[0]].state)
		       UC : begin
		          m_ncbu_cache_q[m_tmp_q[0]].state = SC;
		          m_ott_q[ott_index].hasTagUpdate = 1;
		       end
		       UD : begin
		          m_ncbu_cache_q[m_tmp_q[0]].state = SD;
		          m_ott_q[ott_index].hasTagUpdate = 1;
		       end
		  endcase // case (m_ncbu_cache_q[m_tmp_q[0]].state)
	       end
	       SNP_VLD_DTR : begin // Sharer Prom Update
		  case(m_ncbu_cache_q[m_tmp_q[0]].state)
		       UC : begin
		          m_ncbu_cache_q[m_tmp_q[0]].state = SC;
		          m_ott_q[ott_index].hasTagUpdate = 1;
		       end
		       UD : begin
		          m_ncbu_cache_q[m_tmp_q[0]].state = SC;
		          m_ott_q[ott_index].hasTagUpdate = 1;
		       end
		       SD : begin
		          m_ncbu_cache_q[m_tmp_q[0]].state = SC;
		          m_ott_q[ott_index].hasTagUpdate = 1;
		       end
		  endcase // case (m_ncbu_cache_q[m_tmp_q[0]].state)
	       end
	       SNP_STSH_SH : begin
		  case(m_ncbu_cache_q[m_tmp_q[0]].state)
		       UC : begin
		          m_ncbu_cache_q[m_tmp_q[0]].state = SC;
		          m_ott_q[ott_index].hasTagUpdate = 1;
		       end
		       UD : begin
		          m_ncbu_cache_q[m_tmp_q[0]].state = SD;
		          m_ott_q[ott_index].hasTagUpdate = 1;
		       end
		  endcase // case (m_ncbu_cache_q[m_tmp_q[0]].state)
	       end
	       SNP_CLN_DTW : begin
		  case(m_ncbu_cache_q[m_tmp_q[0]].state)
		       SD : begin
		          m_ncbu_cache_q[m_tmp_q[0]].state = SC;
		          m_ott_q[ott_index].hasTagUpdate = 1;
		       end
		       UD : begin
		          m_ncbu_cache_q[m_tmp_q[0]].state = UC;
		          m_ott_q[ott_index].hasTagUpdate = 1;
		       end
		  endcase // case (m_ncbu_cache_q[m_tmp_q[0]].state)
	       end
	       SNP_INV_DTW,SNP_INV_DTR,SNP_NITCCI,SNP_NITCMI,SNP_INV,SNP_STSH_UNQ,SNP_UNQ_STSH,SNP_INV_STSH : begin
		  m_ncbu_cache_q[m_tmp_q[0]].state = IX;
		  m_ott_q[ott_index].hasTagUpdate = 1;
	       end
	       default: begin
		  m_ott_q[ott_index].hasTagUpdate = 0;
	       end
	    endcase // case (m_ott_q[ott_index].m_snp_req_pkt.smi_msg_type)
	end
	else if(m_ott_q[ott_index].isWrite) begin
	    if(!m_ott_q[ott_index].isFillReqd) begin
			if (m_ott_q[ott_index].isCoherent) begin :_is_Coherent
				case(m_ncbu_cache_q[m_tmp_q[0]].state)
				   UC : begin
					   m_ott_q[ott_index].hasTagUpdate = 1;
					   m_ncbu_cache_q[m_tmp_q[0]].state = UD;
				   end
				endcase
			end : _is_Coherent
			else begin : _is_not_Coherent
				case(m_ncbu_cache_q[m_tmp_q[0]].state)
				   UC,SC,SD : begin
					   m_ott_q[ott_index].hasTagUpdate = 1;
					   m_ncbu_cache_q[m_tmp_q[0]].state = UD;
				   end
				endcase
			end: _is_not_Coherent
 	    end
	    else begin
			if(m_ott_q[ott_index].isFillCtrlRcvd && !m_ott_q[ott_index].isFillDataReqd) begin
		    	m_ncbu_cache_q[m_tmp_q[0]].state = UD;
			end
	    end
	       
	end
	else if(m_ott_q[ott_index].isRead) begin
	  if(m_ott_q[ott_index].isSMIAllDTRReqRecd && m_ott_q[ott_index].isFillReqd) begin	       
	    case(m_ott_q[ott_index].m_dtr_req_pkt.smi_msg_type)
		DTR_DATA_SHR_CLN : begin
		       m_ncbu_cache_q[m_tmp_q[0]].state = SC;
		end
		DTR_DATA_SHR_DTY : begin
		       m_ncbu_cache_q[m_tmp_q[0]].state = SD;
		end
		DTR_DATA_UNQ_CLN : begin
		       m_ncbu_cache_q[m_tmp_q[0]].state = UC;
		end
       		DTR_DATA_UNQ_DTY : begin
		       m_ncbu_cache_q[m_tmp_q[0]].state = UD;
		end
	    endcase
	   end	       
	end
	else if(m_ott_q[ott_index].isIoCacheEvict) begin
	end
	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Transitioning addr:0x%0h security:%0d from %s to %s OutstTxn#%0d %s",  m_ott_q[ott_index].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,m_ott_q[ott_index].core_id<%}%>, m_ncbu_cache_q[m_tmp_q[0]].addr,m_ncbu_cache_q[m_tmp_q[0]].security,prev_state.name(),m_ncbu_cache_q[m_tmp_q[0]].state.name(),ott_index,s),UVM_LOW);
   end
endfunction // update_cacheline_state
	       
function void ioaiu_scoreboard::add_cacheline(int ott_index);
    ccpCacheLine m_cache_pkt;
    int m_tmp_q[$];
    string spkt;
    ccp_ctrlfill_data_t fill_data[];
    ccp_ctrlfill_data_t prev_data;
    int                 fill_data_beats[];
    ccp_data_poision_t  fill_data_poison[];
    ccp_ctrlfilldata_byten_t fill_byten[];    

    m_tmp_q = {};
    m_tmp_q = m_ncbu_cache_q.find_index() with (
                                        item.tag   == m_ott_q[ott_index].ccp_addr     &&
                                        item.Index  == m_ott_q[ott_index].ccp_index     &&
                                        item.security == m_ott_q[ott_index].m_security   
                                        );

    if((m_tmp_q.size()>0) && !m_ott_q[ott_index].is_write_hit_upgrade ) begin
        m_ncbu_cache_q[m_tmp_q[0]].print();
        spkt = {"NCBU cache found same address being written twice ",
                " to same CCP Index. "};
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end
   

    if(m_tmp_q.size()==0) begin
	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Adding cacheline 0x%0h ccp_addr 0x%0h",m_ott_q[ott_index].m_sfi_addr,m_ott_q[ott_index].ccp_addr),UVM_MEDIUM);
        m_cache_pkt            = new;
        m_cache_pkt.addr       = m_ott_q[ott_index].m_sfi_addr;
	if(m_ott_q[ott_index].m_ccp_fillctrl_pkt_t !== null)
	   m_cache_pkt.state      = m_ott_q[ott_index].m_ccp_fillctrl_pkt_t.state;
	else	       
	   m_cache_pkt.state      = m_ott_q[ott_index].m_ccp_ctrl_pkt.state;
        m_cache_pkt.Index      = m_ott_q[ott_index].ccp_index;
        m_cache_pkt.way        = m_ott_q[ott_index].ccp_way;
        m_cache_pkt.tag        = m_ott_q[ott_index].ccp_addr;
        m_cache_pkt.security   = m_ott_q[ott_index].m_security;
        m_cache_pkt.t_creation = $time;

        if(m_ott_q[ott_index].isRead && !hasErr) begin
            convert_dtr_to_fill_data(ott_index,fill_data,fill_data_beats,fill_data_poison);
        end else if(m_ott_q[ott_index].isWrite) begin
            merge_write_data(ott_index,fill_data,fill_byten,fill_data_beats,fill_data_poison); 
        end

        if(fill_data.size() != fill_data_beats.size()) begin
            spkt = {"Fill Data and Data Beat array size mismatch Fill Data:%0d",
                    " and Fill Beat:%0d"};
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt,fill_data.size(), 
                        fill_data_beats.size()))
        end

        m_cache_pkt.data             = new[fill_data.size()];
        m_cache_pkt.dataErrorPerBeat = new[fill_data.size()];
        foreach(fill_data_beats[i]) begin
            m_cache_pkt.data[fill_data_beats[i]]             = fill_data[i];
            m_cache_pkt.dataErrorPerBeat[fill_data_beats[i]] = fill_data_poison[i];
        end
        m_ncbu_cache_q.push_back(m_cache_pkt);
       nunCachline ++;

        `uvm_info("<%=obj.strRtlNamePrefix%> SCB","Adding cacheline from cache model",UVM_LOW)
    end else if((m_tmp_q.size()>0) && m_ott_q[ott_index].is_write_hit_upgrade) begin
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Updating cacheline Addr:0x%0h from cache model",m_ott_q[ott_index].m_sfi_addr),UVM_LOW)
        merge_write_data(ott_index,fill_data,fill_byten,fill_data_beats,fill_data_poison); 

        if(fill_data.size() != fill_data_beats.size()) begin
            spkt = {"Fill Data and Data Beat array size mismatch Fill Data:%0d",
                    " and Fill Beat:%0d"};
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf(spkt,fill_data.size(), 
                        fill_data_beats.size()))
        end

        foreach(fill_data_beats[i]) begin
	    prev_data = m_ncbu_cache_q[m_tmp_q[0]].data[fill_data_beats[i]];
            m_ncbu_cache_q[m_tmp_q[0]].data[fill_data_beats[i]]             = fill_data[i];
            m_ncbu_cache_q[m_tmp_q[0]].dataErrorPerBeat[fill_data_beats[i]] = fill_data_poison[i];
        end
        m_ncbu_cache_q[m_tmp_q[0]].state = UD;
        m_ncbu_cache_q[m_tmp_q[0]].t_last_update = $time;
    end

endfunction


function bit ioaiu_scoreboard::hasActiveMntOp();
   int m_tmp_q[$];
   m_tmp_q = {};	     
   m_tmp_q = m_ott_q.find_index() with (item.isIoCacheEvict && item.m_ccp_ctrl_pkt.isMntOp &&
					!(((item.isSMICMDReqNeeded)  ? !item.isSMISTRRespSent && item.isSMISTRReqRecd && item.isSMICMDRespRecd     : 1)   &&
					((item.isSMIUPDReqNeeded)    ? item.isSMIUPDRespRecd     : 1)         &&
					((item.isSMIDTWReqNeeded)    ? item.isSMIDTWRespRecd  : 1)));
   return (m_tmp_q.size() > 0) ? 1 : 0;		     
endfunction : hasActiveMntOp
		     
function void ioaiu_scoreboard::delete_cacheline(int ott_index, bit isSnoop);
    int m_tmp_q[$];
    string spkt;
    axi_axaddr_t  m_evict_addr; 
    int m_evict_index;
    if(isSnoop) begin
        m_tmp_q = {};
        m_tmp_q = m_ncbu_cache_q.find_index() with (
                                            item.tag     == m_ott_q[ott_index].ccp_addr     &&
                                            item.Index    == m_ott_q[ott_index].ccp_index    &&
                                            item.security == m_ott_q[ott_index].m_security   
                                            );
    end else begin
        m_evict_addr = shift_addr(m_ott_q[ott_index].m_ccp_ctrl_pkt.evictaddr);  
        m_evict_index = addrMgrConst::get_set_index(m_ott_q[ott_index].m_ccp_ctrl_pkt.evictaddr,<%=obj.FUnitId%>);
//        m_evict_index = 0;        
        m_tmp_q = {};
        m_tmp_q = m_ncbu_cache_q.find_index() with (
                                            item.tag     == m_evict_addr     &&
                                            item.Index    == m_evict_index    &&
                                            item.security == m_ott_q[ott_index].m_ccp_ctrl_pkt.evictsecurity   
                                            );
    end

    if(m_tmp_q.size()>0) begin
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Deleting cacheline delete_cacheline 0x%0h from cache model",m_ncbu_cache_q[m_tmp_q[0]].addr),UVM_MEDIUM)
        //m_ncbu_cache_q[m_tmp_q[0]].print();
        m_ncbu_cache_q.delete(m_tmp_q[0]);
    end else begin
        m_ott_q[ott_index].print_me();
        spkt = "TB Error found no matching cacheline in the NCBU cache model";
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s for OutstTxn %0d",spkt,ott_index),UVM_NONE) 
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end

endfunction


function void ioaiu_scoreboard::store_write_hit_data(int ott_index);


    bit [$clog2(CACHELINE_SIZE)-1:0] beat_offset;
    string spkt;
    int no_of_bytes;
    int burst_length;
    longint m_lower_wrapped_boundary;
    longint m_upper_wrapped_boundary;
    longint m_start_addr;
    int m_tmp_q[$];
    axi_axaddr_t         addr;

    parameter LINE_INDEX_LOW  = $clog2(DATA_WIDTH/8);
    parameter LINE_INDEX_HIGH = LINE_INDEX_LOW + $clog2(CACHELINE_SIZE) - 1;
    

    m_tmp_q = {};
    m_tmp_q = m_ncbu_cache_q.find_index() with (
                                        item.tag     == m_ott_q[ott_index].ccp_addr     &&
                                        item.Index   == m_ott_q[ott_index].ccp_index    &&
                                        item.security == m_ott_q[ott_index].m_security   
                                        );


    if(m_tmp_q.size()==1) begin
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Writing hit data to cacheline %0x from cache model",m_ott_q[ott_index].m_sfi_addr),UVM_LOW)
//        m_ncbu_cache_q[m_tmp_q[0]].print();

        if(m_ott_q[ott_index].m_ace_write_data_pkt.wdata.size()>0) begin
            addr                      = m_ott_q[ott_index].m_sfi_addr;
            no_of_bytes               = (DATA_WIDTH/8);
            burst_length              = m_ott_q[ott_index].m_ace_write_addr_pkt.awlen+1;

            beat_offset = addr[SYS_wSysCacheline-1:WLOGXDATA];
            m_start_addr             = ((addr/(DATA_WIDTH/8)) * (DATA_WIDTH/8));
            m_lower_wrapped_boundary = ((addr/(no_of_bytes * burst_length)) * (no_of_bytes*burst_length)); 
            m_upper_wrapped_boundary = m_lower_wrapped_boundary + (no_of_bytes * burst_length); 

            for(int i=0; i<m_ott_q[ott_index].m_ace_write_data_pkt.wdata.size();i++) begin

                if((m_ott_q[ott_index].m_ace_write_addr_pkt.awburst == 'h2) && (m_start_addr >= m_upper_wrapped_boundary) 
                    && ~m_ott_q[ott_index].isMultiAccess) begin
                    beat_offset = m_lower_wrapped_boundary[LINE_INDEX_HIGH:LINE_INDEX_LOW];
                end 

                if((m_ott_q[ott_index].m_ace_write_addr_pkt.awburst == 'h2) && (m_start_addr >= m_upper_wrapped_boundary) ) begin
                    m_start_addr = m_lower_wrapped_boundary;
                end else begin
                    m_start_addr = m_start_addr + no_of_bytes;
                end

                for(int index_bit=0; index_bit<no_of_bytes;index_bit++) begin
                    if(m_ott_q[ott_index].m_ace_write_data_pkt.wstrb[i][index_bit] == 1'b1) begin
                        m_ncbu_cache_q[m_tmp_q[0]].data[beat_offset][(8*index_bit) +: 8] = 
                        m_ott_q[ott_index].m_ace_write_data_pkt.wdata[i][(8*index_bit) +: 8];
                    end
                end
                beat_offset      = beat_offset + 1'b1;

            end
        end else begin
            spkt = {"In function convert_agent_data_to_ccp_data input data size is null can't convert",
                    " dtr packet to fill data packet"};
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
        end

        m_ncbu_cache_q[m_tmp_q[0]].t_last_update = $time;
    end else if(m_tmp_q.size()>1) begin
        foreach(m_tmp_q[i]) begin
            m_ncbu_cache_q[m_tmp_q[i]].print();
        end
        spkt = {"TB Error found multiple cacheline with same address in ",
                " NCBU cache model while performing write-hit data write "};
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end else begin
        m_ott_q[ott_index].print_me();
        spkt = {"TB Error found no matching cacheline in the",
                " NCBU cache model while performing write-hit "};
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end


endfunction



function void ioaiu_scoreboard::read_cacheline_data(int ott_index);
<%  var beatsInACacheline = (Math.pow(2,obj.wCacheLineOffset) * 8) / obj.wData;
    var dwsInABeat        = obj.wData / 64;
    var dwsInACacheline   = (Math.pow(2,obj.wCacheLineOffset) * 8) / 64;
    var beatsIntfsize     = obj.wData/64;
%>
    int m_tmp_q[$];
    string spkt;
    bit [$clog2(CACHELINE_SIZE)-1:0] beat_offset;
    longint dw[<%=dwsInACacheline%>];
    longint rdw[<%=dwsInACacheline%>];
    int smi_intfsize;
    int dw_offset, dw_offset_aligned;

    m_tmp_q = {};
    m_tmp_q = m_ncbu_cache_q.find_index() with (
                                        item.tag     == m_ott_q[ott_index].ccp_addr     &&
                                        item.Index   == m_ott_q[ott_index].ccp_index    &&
                                        item.security == m_ott_q[ott_index].m_security   
                                        );

    if(m_tmp_q.size()==1) begin
        m_ott_q[ott_index].m_ccp_cacheline = new;
        m_ott_q[ott_index].m_ccp_cacheline.copy(m_ncbu_cache_q[m_tmp_q[0]]);
        m_ott_q[ott_index].m_ccp_exp_data      = new[m_ott_q[ott_index].m_ccp_ctrl_pkt.burstln+1];
    
        if(m_ott_q[ott_index].isSnoop) begin
            smi_intfsize = m_ott_q[ott_index].m_snp_req_pkt.smi_intfsize;
        end else begin
            smi_intfsize = $clog2(<%=beatsIntfsize%>);
        end

        dw_offset = m_ott_q[ott_index].m_sfi_addr[SYS_wSysCacheline-1:3];
        if(<%=beatsIntfsize%> < (2**smi_intfsize)) begin
            dw_offset_aligned   = dw_offset/(2**smi_intfsize) * (2**smi_intfsize);
        end else begin
            dw_offset_aligned = dw_offset/(<%=beatsIntfsize%>) * (<%=beatsIntfsize%>);
        end

<% for(var i = 0; i < beatsInACacheline; i++) {
    for(var j = 0; j < dwsInABeat; j++) { %>
	dw[<%=((i * dwsInABeat) + j)%>] = m_ncbu_cache_q[m_tmp_q[0]].data[<%=i%>][<%=((64 * (j + 1)) -1)%>:<%=(64 * j)%>];
    <% }
} %>
        for(int i = 0; i < <%=dwsInACacheline%>; i++) begin
            rdw[i] = dw[(i+dw_offset_aligned)%<%=dwsInACacheline%>];
        end
    <% for(var i = 0; i < beatsInACacheline; i++) {
	 var s = 'm_ott_q[ott_index].m_ccp_exp_data[' + i + '] = {'
	 for(var j = dwsInABeat - 1; j >= 0; j--) {
	   s += 'rdw[' + ((i * dwsInABeat) + j) + ']' + ((j == 0) ? '' : ',');
	 }
	 s += '};'; %>
	 <%=s%>
 <% } %>
    end else if(m_tmp_q.size()>1) begin
        foreach(m_tmp_q[i]) begin
            m_ncbu_cache_q[m_tmp_q[i]].print();
        end
        spkt = {"TB Error found multiple same address in ",
                " NCBU cache model while performing read-hit data read "};
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end else begin
        foreach(m_ncbu_cache_q[i]) begin
	    uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("ncbu #%0d addr 0x%0h",i,m_ncbu_cache_q[i].tag << 6),UVM_NONE);
	    uvm_report_info(`LABEL_ERROR,$sformatf("ncbu #%0d addr 0x%0h",i,m_ncbu_cache_q[i].tag << 6),UVM_NONE);
            m_ncbu_cache_q[i].print();
        end
        m_ott_q[ott_index].print_me();
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("TB did not find Addr 0x%0h in NCBU cache model!",m_ott_q[ott_index].m_sfi_addr),UVM_NONE)
        spkt = {"TB Error found no matching cacheline in the",
                " NCBU cache model while performing read-hit "};
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end

endfunction

//#Check.IOAIU.CCPCtrlPkt.Eviction
//#Check.IOAIU.CCPEvict.Data
function void ioaiu_scoreboard::evict_cacheline_data(ioaiu_scb_txn pkt,
                        output ccp_ctrlwr_data_t         ccp_data[]
);

    int m_tmp_q[$];
    string spkt;
    bit [$clog2(CACHELINE_SIZE)-1:0] beat_offset;

    m_tmp_q = {};
    m_tmp_q = m_ncbu_cache_q.find_index() with (
                                        item.tag     == pkt.ccp_addr     &&
                                        item.Index   == pkt.ccp_index    &&
                                        item.security == pkt.m_security   
                                        );

    if(m_tmp_q.size()==1) begin
        //`uvm_info("<%=obj.strRtlNamePrefix%> SCB","Deleting cacheline from cache model",UVM_LOW)
        //m_ncbu_cache_q[m_tmp_q[0]].print();
        ccp_data      = new[CACHELINE_SIZE];
        pkt.m_ccp_cacheline = new;
        pkt.m_ccp_cacheline.copy(m_ncbu_cache_q[m_tmp_q[0]]);
    
        for(int i=0; i< ccp_data.size();i++) begin
            ccp_data[i] = m_ncbu_cache_q[m_tmp_q[0]].data[i];
        end
    end else if(m_tmp_q.size()>1) begin
        foreach(m_tmp_q[i]) begin
            m_ncbu_cache_q[m_tmp_q[i]].print();
        end
        spkt = {"TB Error found multiple same address in ",
                " NCBU cache model while performing read-hit data read "};
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end else begin
        foreach(m_ncbu_cache_q[i]) begin
	    uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("ncbu #%0d addr 0x%0h",i,m_ncbu_cache_q[i].tag << 6),UVM_NONE);
            m_ncbu_cache_q[i].print();
        end
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("TB did not find Addr 0x%0h in NCBU cache model!",pkt.m_sfi_addr),UVM_NONE)
        pkt.print_me();
        spkt = {"TB Error found no matching cacheline in the",
                " NCBU cache model while performing eviction "};
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
    end

endfunction


<% if(obj.COVER_ON) {%>
function void ioaiu_scoreboard::sample_coverage(int ott_index);
    int m_tmp_q[$];

    if(m_ott_q[ott_index].isRead) begin
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index() with (item.isRead && 
                                                (item.m_ace_read_addr_pkt.arid == m_ott_q[ott_index].m_ace_read_addr_pkt.arid) && 
                                                item.isIoCacheTagPipelineSeen &&
                                                item.isSMICMDReqSent &&
                                                !item.isACEReadDataSent);

        if(prev_rd_hit && m_ott_q[ott_index].is_ccp_hit) begin
            if(m_tmp_q.size()>0) begin
                b2bRdHits = B2B_RD_HIT_AXID_DEP;
                B2B_RD_HITS.sample();
            end else begin
                b2bRdHits = B2B_RD_HIT_NOAXID_DEP;
                B2B_RD_HITS.sample();
            end
        end else if(prev_rd_miss && !m_ott_q[ott_index].is_ccp_hit && 
                    m_ott_q[ott_index].m_iocache_allocate) begin
            if(m_tmp_q.size()>0) begin
                b2bRdHits = B2B_RD_MISS_AXID_DEP;
                B2B_RD_HITS.sample();
            end else begin
                b2bRdHits = B2B_RD_MISS_NOAXID_DEP;
                B2B_RD_HITS.sample();
            end
        end

        if(m_ott_q[ott_index].is_ccp_hit)  begin
            prev_rd_hit  = 1;
            prev_rd_miss = 0;
        end else begin 
            prev_rd_miss = 1;
            prev_rd_hit  = 0;
        end
        prev_rd_axid = m_ott_q[ott_index].m_ace_read_addr_pkt.arid;
        prev_wr_hit  = 0;
        prev_wr_miss = 0;
    end else if (m_ott_q[ott_index].isWrite) begin
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index() with (item.isWrite && 
                                            (item.m_ace_write_addr_pkt.awid == m_ott_q[ott_index].m_ace_write_addr_pkt.awid) && 
                                            item.isIoCacheTagPipelineSeen &&
                                            item.isSMICMDReqSent &&
                                            !item.isACEWriteRespSent);



        if(prev_wr_hit && m_ott_q[ott_index].is_ccp_hit) begin
            if(m_tmp_q.size()>0) begin
                b2bWrHits = B2B_WR_HIT_AXID_DEP;
                B2B_WR_HITS.sample();
            end else begin
                b2bWrHits = B2B_WR_HIT_NOAXID_DEP;
                B2B_WR_HITS.sample();
            end
        end else if(prev_wr_miss && !m_ott_q[ott_index].is_ccp_hit) begin
            if(m_tmp_q.size()>0) begin
                b2bWrHits = B2B_WR_MISS_AXID_DEP;
                B2B_WR_HITS.sample();
            end else begin
                b2bWrHits = B2B_WR_MISS_NOAXID_DEP;
                B2B_WR_HITS.sample();
            end
        end

        if(m_ott_q[ott_index].is_ccp_hit)  begin
            prev_wr_hit  = 1;
            prev_wr_miss = 0;
        end else begin 
            prev_wr_miss = 1;
            prev_wr_hit  = 0;
        end
        prev_wr_axid = m_ott_q[ott_index].m_ace_write_addr_pkt.awid;
        prev_rd_hit  = 0;
        prev_rd_miss = 0;
    end


endfunction
<%}%>

//=========================================================================
// Function: check_sfi_snoop_resp
// Purpose: 
// 
//=========================================================================

function void ioaiu_scoreboard::check_sfi_snoop_resp(int ott_index);
	bit [5:0] exp_snp_result;
	string spkt,state_name;
	eMsgSNP snp_type;
	bit RV = m_ott_q[ott_index].m_snp_rsp_pkt.smi_cmstatus_rv;
	bit RS = m_ott_q[ott_index].m_snp_rsp_pkt.smi_cmstatus_rs;
	bit DC = m_ott_q[ott_index].m_snp_rsp_pkt.smi_cmstatus_dc;
	bit DT_1 = m_ott_q[ott_index].m_snp_rsp_pkt.smi_cmstatus_dt_aiu;
	bit DT_0 = m_ott_q[ott_index].m_snp_rsp_pkt.smi_cmstatus_dt_dmi;
	bit [WSMINCOREUNITID-1:0] snp_req_mpf3 = m_ott_q[ott_index].m_snp_req_pkt.smi_mpf3_intervention_unit_id;
	bit [WSMIUP-1:0] snp_req_up = m_ott_q[ott_index].m_snp_req_pkt.smi_up;
	bit up_match = 0;
	if((snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION) || (snp_req_up == SMI_UP_PRESENCE)) begin
		up_match = 1;
	end
	if(m_ott_q[ott_index].isIoCacheTagPipelineNeeded == 0) begin
	     exp_snp_result = 5'b0;				     
	end				     
	else begin				     
        case(m_ott_q[ott_index].m_snp_req_pkt.smi_msg_type) //Sharer Prom update
	    SNP_CLN_DTR : begin
		case(m_ott_q[ott_index].m_ccp_ctrl_pkt.currstate)
		   IX : exp_snp_result = 5'b0;
		   SC : begin 
				if((snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION) || (snp_req_up == SMI_UP_PRESENCE))
					exp_snp_result = 5'b11010;
				else
					exp_snp_result = 5'b11000;
			end
		   SD : exp_snp_result = 5'b10010;
		   UC : exp_snp_result = 5'b11010;
		   UD : exp_snp_result = 5'b10010;
		endcase
	    end
	    SNP_NOSDINT : begin
		case(m_ott_q[ott_index].m_ccp_ctrl_pkt.currstate)
		   IX : exp_snp_result = 5'b00000;
		   SC : begin 
				if((snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION) || (snp_req_up == SMI_UP_PRESENCE))
					exp_snp_result = 5'b11010;
				else
					exp_snp_result = 5'b11000;
			end
		   SD : exp_snp_result = 5'b10010;
		   UC : exp_snp_result = 5'b11010;
		   UD : exp_snp_result = 5'b10010;
		endcase
	    end
	    SNP_VLD_DTR : begin
		case(m_ott_q[ott_index].m_ccp_ctrl_pkt.currstate)
		   IX : exp_snp_result = 5'b00000;
		   SC : begin 
				if((snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION) || (snp_req_up == SMI_UP_PRESENCE))
					exp_snp_result = 5'b11010;
				else
					exp_snp_result = 5'b11000;
			end
		   SD : exp_snp_result = 5'b11110;
		   UC : exp_snp_result = 5'b11110;
		   UD : exp_snp_result = 5'b11110;
		endcase
	    end
	    SNP_INV_DTR : begin
		case(m_ott_q[ott_index].m_ccp_ctrl_pkt.currstate)
		   IX : exp_snp_result = 5'b00000;
		   SC : begin 
				if(snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION)
					exp_snp_result = 5'b00001;
				else if(snp_req_up == SMI_UP_PRESENCE)
					exp_snp_result = 5'b00110;
				else
					exp_snp_result = 5'b00000;
			end
		   SD : begin 
				if(snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION)
					exp_snp_result = 5'b00001;
				else if(snp_req_up == SMI_UP_PRESENCE)
					exp_snp_result = 5'b00110;
				else
					exp_snp_result = 5'b00000;
			end
		   UC : exp_snp_result = 5'b00110;
		   UD : exp_snp_result = 5'b00110;
		endcase
	    end
	    SNP_NITC : begin
		case(m_ott_q[ott_index].m_ccp_ctrl_pkt.currstate)
		   IX : exp_snp_result = 5'b00000;
		   SC : begin 
				if((snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION) || (snp_req_up == SMI_UP_PRESENCE))
					exp_snp_result = 5'b11010;
				else
					exp_snp_result = 5'b11000;
			end
		   SD : exp_snp_result = 5'b10010;
		   UC : exp_snp_result = 5'b10010;
		   UD : exp_snp_result = 5'b10010;
		endcase
	    end
	    SNP_NITCCI : begin
		case(m_ott_q[ott_index].m_ccp_ctrl_pkt.currstate)
		   IX : exp_snp_result = 5'b00000;
		   SC : begin 
				if((snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION) || (snp_req_up == SMI_UP_PRESENCE))
					exp_snp_result = 5'b00010;
				else
					exp_snp_result = 5'b00000;
			end
		   SD : exp_snp_result = 5'b00011;
		   UC : exp_snp_result = 5'b00010;
		   UD : exp_snp_result = 5'b00011;
		endcase
	    end
	    SNP_NITCMI : begin
		case(m_ott_q[ott_index].m_ccp_ctrl_pkt.currstate)
		   IX : exp_snp_result = 5'b00000;
		   SC : begin 
				if((snp_req_mpf3 == <%=obj.FUnitId%> && snp_req_up == SMI_UP_PERMISSION) || (snp_req_up == SMI_UP_PRESENCE))
					exp_snp_result = 5'b00010;
				else
					exp_snp_result = 5'b00000;
			end
		   SD : exp_snp_result = 5'b00010;
		   UC : exp_snp_result = 5'b00010;
		   UD : exp_snp_result = 5'b00010;
		endcase
	    end
	    SNP_STSH_SH : begin
		case(m_ott_q[ott_index].m_ccp_ctrl_pkt.currstate)
		   IX : exp_snp_result = 5'b00000;
		   SC : exp_snp_result = 5'b11000;
		   SD : exp_snp_result = 5'b10001;
		   UC : exp_snp_result = 5'b11000;
		   UD : exp_snp_result = 5'b10001;
		endcase
	    end
	    SNP_CLN_DTW : begin
		case(m_ott_q[ott_index].m_ccp_ctrl_pkt.currstate)
		   IX : exp_snp_result = 5'b00000;
		   SC : exp_snp_result = 5'b11000;
		   SD : exp_snp_result = 5'b11001;
		   UC : exp_snp_result = 5'b10000;
		   UD : exp_snp_result = 5'b10001;
		endcase
	    end
	    SNP_INV_DTW,SNP_STSH_UNQ,SNP_UNQ_STSH : begin
		case(m_ott_q[ott_index].m_ccp_ctrl_pkt.currstate)
		   IX : exp_snp_result = 5'b00000;
		   SC : exp_snp_result = 5'b00000;
		   SD : exp_snp_result = 5'b00001;
		   UC : exp_snp_result = 5'b00000;
		   UD : exp_snp_result = 5'b00001;
		endcase
	    end
	    SNP_INV,SNP_INV_STSH : begin
		case(m_ott_q[ott_index].m_ccp_ctrl_pkt.currstate)
		   IX : exp_snp_result = 5'b00000;
		   SC : exp_snp_result = 5'b00000;
		   SD : exp_snp_result = 5'b00000;
		   UC : exp_snp_result = 5'b00000;
		   UD : exp_snp_result = 5'b00000;
		endcase
	    end
	endcase
	end				     
        if(m_ott_q[ott_index].m_snp_addr_err_expected) exp_snp_result = 5'b00010; //(Address Error)
	if({RV,RS,DC,DT_1,DT_0} != exp_snp_result) begin
	   state_name = (m_ott_q[ott_index].isIoCacheTagPipelineNeeded) ? m_ott_q[ott_index].m_ccp_ctrl_pkt.currstate.name() : "IX";
	   $cast(snp_type,m_ott_q[ott_index].m_snp_req_pkt.smi_msg_type);
	   spkt = "AIU sent SNPrsp with wrong RV,RS,DC,DT fields";
	   `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s for SnpType:%s OutstTxn:%0d,state:%s, act:{RV=%0b,RS=%0b,DC=%0b,DT[1]=%0b,DT[0]=%0b} exp:%0b",spkt,snp_type.name(),ott_index,state_name,RV,RS,DC,DT_1,DT_0,exp_snp_result),UVM_NONE)
	   `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",spkt)
	end
        m_ott_q[ott_index].checkExpSnpRsp(exp_snp_result);// Generate expected SnpRsp and use compare method
 endfunction
<% } %>

function void ioaiu_scoreboard::process_sysco_fsm_state_change(bit error=0);
    ioaiu_scb_txn m_scb_txn;
    int outstanding_snpq[$], outstanding_attach_seqq[$],  outstanding_detach_seqq[$];
    string spkt;

    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("fn:process_sysco_fsm_state_change: %0p --> %0p", m_sysco_fsm_state_prev, m_sysco_fsm_state), UVM_LOW)

    case(m_sysco_fsm_state)
    IDLE: 
        begin
    	    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", ("IDLE"), UVM_HIGH)
	     outstanding_snpq = m_ott_q.find_index(item) with (item.isSnoop);
	     if (outstanding_snpq.size() > 0) begin 
	     foreach (outstanding_snpq[i])
	        spkt = $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%>", m_ott_q[outstanding_snpq[i]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,m_ott_q[outstanding_snpq[i]].core_id<%}%>);
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Core <%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> is in DETACHED/IDLE state but outstanding snoops present %0s"<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, spkt));
	     end
             //if (error == 1 && $test$plusargs("enable_attach_error")) begin 
	     //   m_sysco_fsm_state_prev = IDLE;
	     //   m_sysco_fsm_state = CONNECT;
	     //   process_sysco_fsm_state_change();
             //end
                    
	end
	
    CONNECT: 
	begin
	    tb_txn_count++;
    	    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received request to attach agent to coherency domain. sysco_fsm_state:CONNECT", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>) , UVM_LOW)
	    if (core_id == 0) begin 
                m_scb_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen, csr_ccp_updatedis, , core_id);
        	m_scb_txn.setup_sysco(m_sysco_fsm_state); 
		m_scb_txn.tb_txnid = tb_txn_count;
	        m_scb_txn.core_id = core_id;
                m_ott_q.push_back(m_scb_txn);
                ->e_queue_add;
	    end //core_id=0
	end
		
    ATTACHED: 
	begin
    	    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", ("ATTACHED"), UVM_HIGH)
	end
    
    DETACH: 
	begin
	    tb_txn_count++;
            if (error==1) begin 
    	        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Transitioned from ATTACH_ERROR to DETACH", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>) , UVM_LOW)
            end else begin  
    		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received request to detach agent from coherency domain. sysco_fsm_state:DETACH",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>) , UVM_LOW)
            end
	    if (core_id == 0) begin 
		m_scb_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen, csr_ccp_updatedis, ,core_id);
		m_scb_txn.setup_sysco(m_sysco_fsm_state); 
		m_scb_txn.tb_txnid = tb_txn_count;
		m_scb_txn.core_id = core_id;
                if (error == 1) m_scb_txn.isSysCoAttachErr = 1;
		m_ott_q.push_back(m_scb_txn);
		->e_queue_add;
	    end //core_id=0
	end
        
    ATTACH_ERROR: 
        begin
    	    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Received sysco_fsm_state:ATTACH_ERROR that will initiate a detach sequence") , UVM_LOW)
            if(!$test$plusargs("enable_attach_error")) begin
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB", ("ATTACH-ERROR"))
            end else begin
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("C%0d ATTACH_ERROR triggered", core_id), UVM_LOW)
		if (core_id == 0) begin
		    outstanding_attach_seqq = {};
		    outstanding_attach_seqq = m_ott_q.find_index(item) with (item.isSysCoAttachSeq == 1);
				
                    //For timeout error, we need to remove the older ATTACH seq txn since we would never get the SYSrsp
                    //For SYSrsp error, the ATTACH seq is deleted when SYSrsp with Error was received, so need not be taken care of here.
                    if ($test$plusargs("timeout_attach_sys_rsp_error")) begin
                        if (outstanding_attach_seqq.size() == 0) begin
                            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("C%0d has no outstanding attach_seq on sysco_fsm_state:ATTACH_ERROR", core_id));
                        end else if (outstanding_attach_seqq.size() > 1) begin
                            foreach (outstanding_attach_seqq[i])
                                spkt = $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%>", m_ott_q[outstanding_attach_seqq[i]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>);
                            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("C%0d has multiple outstanding attach_seq %0s", core_id, spkt));
                        end else begin 
                            m_ott_q[outstanding_attach_seqq[0]].print_me(0,0,1,0);
                            m_ott_q.delete(outstanding_attach_seqq[0]);
                            ->e_queue_delete;
                        end
                    end
                    //m_scb_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen, csr_ccp_updatedis, ,core_id);
                    //m_scb_txn.setup_sysco(m_sysco_fsm_state); 
                    //			m_scb_txn.tb_txnid = tb_txn_count;
                    //			m_scb_txn.core_id = core_id;
                    //m_ott_q.push_back(m_scb_txn);
                    	//->e_queue_add;
		end//core_id=0
                m_sysco_fsm_state = DETACH;
                m_sysco_fsm_state_prev = ATTACH_ERROR;
                process_sysco_fsm_state_change(1);
            end
	end
    
    DETACH_ERROR: 
	begin
            if(!$test$plusargs("enable_detach_error") && !$test$plusargs("enable_attach_error")) begin
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB", ("DETACH-ERROR"))
            end else begin 

                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("C%0d DETACH_ERROR triggered", core_id), UVM_LOW)
		if (core_id == 0) begin
		    outstanding_detach_seqq = {};
		    outstanding_detach_seqq = m_ott_q.find_index(item) with (item.isSysCoDetachSeq == 1);
				
                    //For timeout error, we need to remove the older DETACH seq txn since we would never get the SYSrsp
                    //For SYSrsp error, the DETACH seq is deleted when SYSrsp with Error was received, so need not be taken care of here.
                    if ($test$plusargs("timeout_detach_sys_rsp_error")) begin
                        if (outstanding_detach_seqq.size() == 0) begin
                            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("C%0d has no outstanding detach_seq on sysco_fsm_state:DETACH_ERROR", core_id));
                        end else if (outstanding_detach_seqq.size() > 1) begin
                            foreach (outstanding_detach_seqq[i])
                                spkt = $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%>", m_ott_q[outstanding_detach_seqq[i]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>);
                            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("C%0d has multiple outstanding detach_seq %0s", core_id, spkt));
                        end else begin 
                            m_ott_q[outstanding_detach_seqq[0]].print_me(0,0,1,0);
                            m_ott_q.delete(outstanding_detach_seqq[0]);
                            ->e_queue_delete;
                        end
                    end
                    //m_scb_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen, csr_ccp_updatedis, ,core_id);
                    //m_scb_txn.setup_sysco(m_sysco_fsm_state); 
                    //			m_scb_txn.tb_txnid = tb_txn_count;
                    //			m_scb_txn.core_id = core_id;
                    //m_ott_q.push_back(m_scb_txn);
                    	//->e_queue_add;
		end//core_id=0
                m_sysco_fsm_state = IDLE;
                m_sysco_fsm_state_prev = DETACH_ERROR;
                process_sysco_fsm_state_change(1);
            end


        end
    
    default:
        begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Illegal SysCo FSM state :%0p" , m_sysco_fsm_state));
	end
    
    endcase

    m_sysco_fsm_state_prev = m_sysco_fsm_state;

endfunction // process_sysco_fsm_state_change

/*! \fn process_sys_req(smi_seq_item m_pkt);
 *  \brief This function is called whenever the SMI observes a sys req type packet on the SMI
 *  \param m_pkt of type smi_seq_item.
 */
function void ioaiu_scoreboard::process_sys_req(smi_seq_item m_pkt);
   	int	m_tmp_q[$];                 ///< 
    smi_sysreq_op_enum_t opcode;    ///< opcode within the sys req type packet - Legal values as of today are 0,1,2,3
    int find_q[$];                  ///< FIXME : Enter Description
    string spkt;                    ///< FIXME : Enter Description

    smi_seq_item  exp_sys_rsp_pkt;  ///< Hold expected sys rsp packet in response to the received sys req packet
    int           exp_cm_status;    ///< Holds the expected cm_status based on the received sys req packet
    smi_seq_item  m_scb_pkt;
       ioaiu_scb_txn         m_scb_txn;

    $cast(opcode, m_pkt.smi_sysreq_op);

    case(opcode)
        SMI_SYSREQ_NOP : begin
          `uvm_error(`LABEL_ERROR, $psprintf("Opcode Not supported in Ncore3.2 for now"))
        end
        SMI_SYSREQ_ATTACH,
        SMI_SYSREQ_DETACH : begin
			//check to make sure there are no prior outstanding SysReq.Attach outstanding in the ott_q, when we receive a new SysReq.Detach and vice versa
			//check needs to be disabled for attach/detach error tests, 
            m_tmp_q = {};
            m_tmp_q = m_ott_q.find_index with ((opcode == SMI_SYSREQ_DETACH && item.isSysCoAttachSeq == 1) || (opcode == SMI_SYSREQ_ATTACH && item.isSysCoDetachSeq == 1));

            if (m_tmp_q.size() != 0 && !$test$plusargs("enable_attach_error") && !$test$plusargs("enable_detach_error")) begin 
				foreach(m_tmp_q[i]) begin 
					m_ott_q[m_tmp_q[i]].print_me(0,1);
				end
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SysCo Spec Violation - SysReq seen on SMI interface when there are prior outstanding SysReqs"));
            end

			//check to make sure we are in the correct sysco fsm state, and scb is expecting a SysReq(Attach/Detach), when we receive a new SysReq(Attach/Detach)
            m_tmp_q = {};
            m_tmp_q = m_ott_q.find_index with ( (   ((m_sysco_fsm_state == CONNECT) && (item.isSysCoAttachSeq == 1))       ||
                                                    ((m_sysco_fsm_state == DETACH || m_sysco_fsm_state == ATTACH_ERROR) && (item.isSysCoDetachSeq == 1))        )   &&
                                                    (item.nSMISysReqExpd > 0) && (item.nSMISysReqSent < item.nSMISysReqExpd));

            // if(!$test$plusargs("sysreq_event")) begin
                if (m_tmp_q.size() == 0) begin 
		    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Received below SMI SYS_REQ packet at IOAIU SCB: %0s", m_pkt.convert2string()), UVM_LOW)
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Unexpected SysReq sent on SMI interface"));
                end else if (m_tmp_q.size() > 1) begin 
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("More than one match in OTT for SysReq sent on SMI interface"));
                end else begin 
		    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below SMI SYS_REQ packet at IOAIU SCB: %0s",  m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_pkt.convert2string()), UVM_LOW)
                    m_ott_q[m_tmp_q[0]].check_sysreq(m_pkt);
                    if ((m_ott_q[m_tmp_q[0]].nSMISysReqExpd == m_ott_q[m_tmp_q[0]].nSMISysReqSent)) begin
                        ev_sysco_all_sys_req_sent.trigger();
                    end
                end
            // end
        end
        SMI_SYSREQ_EVENT : begin
            m_scb_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen,csr_ccp_updatedis,,core_id);
            m_scb_pkt = smi_seq_item::type_id::create("m_scb_pkt");
            m_scb_pkt.smi_transmitter = m_pkt.smi_transmitter;
            m_scb_pkt.smi_msg_id = m_pkt.smi_msg_id;
            <% if(obj.testBench=="fsys" || obj.testBench =="io_aiu"){ %>
            <% if( obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
            if(m_pkt.smi_src_ncore_unit_id == <%=obj.FUnitId%>) begin
                m_tmp_q = {};
                m_tmp_q = m_ott_q.find_index with ( (item.isSenderSysReqNeeded ==1 &&  item.isSenderSysReqSent==0)  &&
                                                (item.exp_sender_sys_req_pkt.smi_msg_id == m_pkt.smi_msg_id) 
                                               );

                if(m_tmp_q.size()==0) begin
                   if(en_sys_event_hds_timeout==1) begin //CONC-14097 event timeout
                      tb_txn_count++;
                      m_scb_txn.setup_sys_evt_rsp(m_pkt);
	              m_scb_txn.isSenderSysReqNeeded = 1;
	              m_scb_txn.isSenderSysReqSent = 1;
	              m_scb_txn.isSenderEventReq = 1;
	              m_scb_txn.tb_txnid = tb_txn_count;
	              m_scb_txn.core_id = core_id;
                      m_ott_q.push_back(m_scb_txn);
                   end
                   else
                   `uvm_error("<%=obj.strRtlNamePrefix%> SCB_ERROR", $sformatf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Sender SysReq not found in OTT smi_sysreq_op=%0d Received below SMI SYS_REQ EVENT packet at IOAIU SCB: %0s",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_pkt.smi_sysreq_op,m_pkt.convert2string()))
                end 
                else if(m_tmp_q.size()>1) begin
                   `uvm_error("<%=obj.strRtlNamePrefix%> SCB_ERROR", $sformatf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Sender SysReq found multiple entries in OTT smi_sysreq_op=%0d Received below SMI SYS_REQ EVENT packet at IOAIU SCB: %0s",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_pkt.smi_sysreq_op,m_pkt.convert2string()))
                end else begin
                  m_ott_q[m_tmp_q[0]].check_sys_evt_req(m_pkt); 
                 m_ott_q[m_tmp_q[0]].setup_sys_evt_rsp(m_pkt);
                end 
            end   
           <%}%>
           if(m_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
       	       tb_txn_count++;
               m_scb_txn.setup_rcv_sys_req(m_pkt);
               m_scb_txn.setup_exp_rcv_sys_rsp(m_pkt);
               if(EventDis_rd==1 ) begin
                  m_scb_txn.isRecieverSysRspNeeded = 1;
                  m_scb_txn.isRecieverEventReqNeeded = 0;
                  m_scb_txn.isRecieverEventAckNeeded=0;
               end
	       m_scb_txn.tb_txnid = tb_txn_count;
	       m_scb_txn.core_id = core_id;
               m_ott_q.push_back(m_scb_txn);
                  `uvm_info("IOAIU_SCB_Event", $psprintf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> :Received below SYS_REQ on event Reciever interface",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>) ,UVM_LOW);
           end   
        <%}%>
           sb_stall_if.perf_count_events["Noc_event_counter"].push_back(1);  
           `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Received below %0s SMI SYS_REQ EVENT packet at IOAIU SCB: %0s", (m_pkt.smi_src_ncore_unit_id == <%=obj.FUnitId%>) ? "Outgoing" : "Incoming", m_pkt.convert2string()), UVM_LOW)
        end
        default : begin
          `uvm_error(`LABEL_ERROR, $sformatf("INSIDE: process_sys_req opcode support not added yet smi_sysreq_op=%0d", m_pkt.smi_sysreq_op))
        end
    endcase
endfunction // process_sys_req

/*! \fn process_sys_rsp(smi_seq_item m_pkt);
 *  \brief This function is called whenever the SMI observes a sys rsp type packet on the SMI
 *  \param m_pkt of type smi_seq_item.
 */
function void ioaiu_scoreboard::process_sys_rsp(smi_seq_item m_pkt);

    int	m_tmp_q[$], outstanding_snpq[$];
    string spkt;

    int     sysreq_id_q[$];
    int     sysrsp_id_q[$];
    int     find_q[$];
    smi_seq_item  sys_req_pkt;
    int     idx[$];
    m_tmp_q = {};
    idx = {};

    //SMI BFM is the transmitter of the SysRsp packet (in the case of sysReq coherence)
    //SysCo FSM implies a maximum of 2 transactions : One for Attach and for Detach
    // If more than one txn is returned means sys req for detach where sent before finishing previous SysCo FSM state.
    m_tmp_q = m_ott_q.find_index with ( (((item.isSysCoAttachSeq == 1) || (item.isSysCoDetachSeq == 1)) &&
                                        (item.nSMISysReqSent > 0) && (item.nSMISysReqSent > item.nSMISysRspRcvd)) 
                                        <% if( obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %> ||(item.isSenderEventAckNeeded == 1 && m_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)<%}%> 
                                        <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == true) { %> || (item.isRecieverEventReqNeeded==0 && item.isRecieverSysRspNeeded==1 && m_pkt.smi_src_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)  <%}%>
                                        <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false) { %> || ( item.isRecieverSysRspNeeded==1 && ((item.isRecieverEventAckSent==0 && (EventDis_rd==1 )) || item.isRecieverEventAckSent==1) && m_pkt.smi_src_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)  <%}%>
                                        );


    if (m_tmp_q.size() == 0) begin 
       `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("<%=obj.BlockId%>:IOAIU_UID:%0d:Received below SMI SYS_RSP packet at IOAIU SCB: %0s",core_id, m_pkt.convert2string()));
    end else if(m_tmp_q.size() > 1) begin 
       `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("<%=obj.BlockId%>:IOAIU_UID:%0d:More than one match in OTT  SMI SYS_RSP packet at IOAIU SCB: %0s",core_id, m_pkt.convert2string()));
    end else begin 
       //SYsco Attach/Detach sysResp
      if(m_ott_q[m_tmp_q[0]].isSysCoAttachSeq==1 || m_ott_q[m_tmp_q[0]].isSysCoDetachSeq==1) begin 
          `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below SMI SYS_RSP COHERENCE packet at IOAIU SCB: %0s", m_ott_q[m_tmp_q[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)
          outstanding_snpq = m_ott_q.find_index(item) with (item.isSnoop && (item.m_snp_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_src_ncore_unit_id));
          if (outstanding_snpq.size() > 0) begin 
               spkt = "IOAIU_UID: ";
               foreach (outstanding_snpq[i])
                  spkt = $psprintf("%s%0d, ", spkt, m_ott_q[outstanding_snpq[i]].tb_txnid);
               if(m_ott_q[m_tmp_q[0]].isSysCoAttachSeq == 1) begin
                  `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SMI SYS_RSP to attach received with outstanding snoops present from that agent DCE/DVE %0s", spkt));
               end
               else begin
                  `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SMI SYS_RSP to detach received with outstanding snoops present from that agent DCE/DVE %0s", spkt));
               end
          end
          m_ott_q[m_tmp_q[0]].check_sysrsp(m_pkt);
          if ((m_ott_q[m_tmp_q[0]].nSMISysReqExpd == m_ott_q[m_tmp_q[0]].nSMISysReqSent) && (m_ott_q[m_tmp_q[0]].nSMISysReqSent == m_ott_q[m_tmp_q[0]].nSMISysRspRcvd)) begin
           		
               //Detach sequence initiated due to Attach-Error is done,so
               //transition to IDLE with error passed. With error=1
               //passed, attempt to CONNECT is made again since
               //SysCoAttach is still 1
               if (m_ott_q[m_tmp_q[0]].isSysCoDetachSeq && m_ott_q[m_tmp_q[0]].isSysCoAttachErr) begin 
                   m_sysco_fsm_state = IDLE;
                   process_sysco_fsm_state_change(1);
               end

               m_ott_q[m_tmp_q[0]].print_me(0,0,1,0);
               m_ott_q.delete(m_tmp_q[0]);
               ev_sysco_all_sys_rsp_received.trigger();
               ->e_queue_delete;
           end
       //Sender Sys Event sysResp
      end else if (m_ott_q[m_tmp_q[0]].isSenderEventAckNeeded==1) begin
         <% if(obj.testBench=="fsys" || obj.testBench =="io_aiu"){ %>
         <% if( obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
         if(m_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below Incoming SMI SYS_RSP EVENT packet at IOAIU SCB: %0s",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_pkt.convert2string()), UVM_LOW) 
             <%if(obj.AiuInfo[obj.Id].fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.AiuInfo[obj.Id].fnNativeInterface == "AXI4" || obj.AiuInfo[obj.Id].fnNativeInterface == "AXI5") && obj.AiuInfo[obj.Id].useCache)){%>
              if (u_event_out_vif.sys_reciever_timeout && u_event_out_vif.event_receiver_enable) begin
                  m_ott_q[m_tmp_q[0]].exp_sender_sys_rsp_pkt.smi_cmstatus = 'h40;
              end
              <%}%>
              if (m_pkt.smi_cmstatus == 1 || m_pkt.smi_cmstatus == 3) begin 
                  m_ott_q[m_tmp_q[0]].exp_sender_sys_rsp_pkt.smi_cmstatus = m_pkt.smi_cmstatus;
              end
              m_ott_q[m_tmp_q[0]].check_sys_evt_rsp(m_pkt);
          end
         <%}%> <%}%>
       //Reciever Sys Event sysResp
       end else if(<% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == true) { %> ( m_ott_q[m_tmp_q[0]].isRecieverSysRspNeeded==1) <% } else {%> ((m_ott_q[m_tmp_q[0]].isRecieverEventAckSent==1 || (m_ott_q[m_tmp_q[0]].isRecieverEventAckSent==0 && (EventDis_rd==1 ))) && m_ott_q[m_tmp_q[0]].isRecieverSysRspNeeded==1) <%}%>) begin
         if(m_pkt.smi_src_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
              if (u_event_out_vif.sys_reciever_timeout && u_event_out_vif.event_receiver_enable) begin
                 m_ott_q[m_tmp_q[0]].exp_reciever_sys_rsp_pkt.smi_cmstatus = 'h40;
              end
              if (m_pkt.smi_cmstatus == 1 || m_pkt.smi_cmstatus == 3) begin 
                  m_ott_q[m_tmp_q[0]].exp_reciever_sys_rsp_pkt.smi_cmstatus = m_pkt.smi_cmstatus;
              end
              `uvm_info("IOAIU_SCB_Event", $psprintf("<%=obj.BlockId%>:IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> :Received below SYS_RSP on event Reciever interface",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>) ,UVM_LOW);
              m_ott_q[m_tmp_q[0]].check_sys_rcv_sys_rsp(m_pkt);
              if(m_ott_q[m_tmp_q[0]].isComplete()) begin
                  delete_ott_entry(m_tmp_q[0], RecieverEventReq);
              end 
         end   
       end   
   end   
endfunction // process_sys_rsp

//----------------------------------------------------------------------- 
// Credit checks
// The total number of outstanding transactions (CmdReqSent && !CmdRspRcvd) sent to a DMI/DII/DCE target, do not exceed the Credits allocated for that target.
//-----------------------------------------------------------------------
//#Check.IOAIU.v3.4.SCM.CreditLimit
function void ioaiu_scoreboard::check_credits(smi_seq_item m_pkt);    
    int         m_tmp_qA[$];
    ioaiu_env_config env_cfg;
    <%for(let i=0; i<obj.nNativeInterfacePorts; i++) {%>
    if (core_id == <%=i%>) begin
    <%if((obj.testBench != "fsys" ) && (obj.testBench != "emu") && (obj.testBench != "emu_t")){ %>
      if (!uvm_config_db#(ioaiu_env_config)::get(null, "uvm_test_top.mp_env.m_env[<%=i%>]", "ioaiu_env_config", env_cfg))
    <%} else {%>
      if (!uvm_config_db#(ioaiu_env_config)::get(null, "uvm_test_top.m_concerto_env.m_<%=obj.BlockId%>_env.m_env[<%=i%>]", "ioaiu_env_config", env_cfg))
    <%}%>
        `uvm_fatal("<%=obj.strRtlNamePrefix%> SCB", $sformatf("uvm_config_db get ioaiu_env_config failed"))
    end
    <%}%>
    // #Cover.IOAIU.DCECreditsBufferFull
    // #Check.IOAIU.DCECreditsInterleaving
    // #Cover.IOAIU.DIICreditsBufferFull
    // #Check.IOAIU.DIICreditsInterleaving
    // #Cover.IOAIU.DMICreditsBufferFull
    // #Check.IOAIU.DMICreditsInterleaving
    // #Check.IOAIU.MaxDCECredits
    // #Check.IOAIU.MaxDIICredits
    // #Check.IOAIU.MaxDMICredits

            <%for (var i = 0; i < obj.nDCEs; i++) {%> 
            if (m_pkt.smi_targ_ncore_unit_id inside { addrMgrConst::dce_ids[<%=i%>] }) begin
                m_tmp_qA = {};
                m_tmp_qA = m_ott_q.find_index with (item.isSMICMDReqSent  === 1 &&
                    item.isSMICMDRespRecd === 0 &&
                    item.isDVM            === 0 &&
                    addrMgrConst::agentid_assoc2funitid(item.m_cmd_req_pkt.smi_targ_ncore_unit_id) === <%=i%> &&
                    addrMgrConst::get_unit_type(item.m_cmd_req_pkt.smi_targ_ncore_unit_id) == addrMgrConst::DCE);
                
                if(m_tmp_qA.size > 0) begin
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("For DCE %0d, CmdReq outstanding is %0d, TotalCredits=%0d", <%=i%>, m_tmp_qA.size, env_cfg.dceCreditLimit[<%=i%>]),UVM_DEBUG)
                end

                if (m_tmp_qA.size > env_cfg.dceCreditLimit[<%=i%>]) begin 
                    print_queues();
                    foreach(m_tmp_qA[i]) begin 
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("i:%0d, index:%0d isSMICMDReqSent:%0d isSMICMDRespRecd:%0d isDVM:%0d targ_ncore_unit_id:%0d isCoherent:%0d",i, m_tmp_qA[i], m_ott_q[m_tmp_qA[i]].isSMICMDReqSent,m_ott_q[m_tmp_qA[i]].isSMICMDRespRecd,m_ott_q[m_tmp_qA[i]].isDVM,m_ott_q[m_tmp_qA[i]].m_cmd_req_pkt.smi_targ_ncore_unit_id, m_ott_q[m_tmp_qA[i]].isCoherent),UVM_NONE)
                        m_ott_q[m_tmp_qA[i]].print_me();
                    end
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Received m_pkt when negative state : %0s",m_pkt.convert2string()),UVM_NONE)
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("NCBU has more CmdReq outstanding that MaxCreditPerDCE for DCE %0d (Requests outstanding:%0d MaxCreditPerDCE:%0d)", <%=i%>, m_tmp_qA.size(), env_cfg.dceCreditLimit[<%=i%>], ));   
                end else begin
                // print_queues();
                    foreach(m_tmp_qA[i]) begin 
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("i:%0d, index:%0d isSMICMDReqSent:%0d isSMICMDRespRecd:%0d isDVM:%0d targ_ncore_unit_id:%0d isCoherent:%0d",i, m_tmp_qA[i], m_ott_q[m_tmp_qA[i]].isSMICMDReqSent,m_ott_q[m_tmp_qA[i]].isSMICMDRespRecd,m_ott_q[m_tmp_qA[i]].isDVM,m_ott_q[m_tmp_qA[i]].m_cmd_req_pkt.smi_targ_ncore_unit_id, m_ott_q[m_tmp_qA[i]].isCoherent),UVM_DEBUG)
                    //  m_ott_q[m_tmp_qA[i]].print_me();
                    end
                end
            end
            <%}%>

            <%for (var i = 0; i < obj.nDMIs; i++) {%> 
            if (m_pkt.smi_targ_ncore_unit_id inside { addrMgrConst::dmi_ids[<%=i%>] }) begin
                m_tmp_qA = {};
                m_tmp_qA = m_ott_q.find_index with (item.isSMICMDReqSent  === 1 &&
                    item.isSMICMDRespRecd === 0 &&
                    item.isDVM            === 0 &&
                    addrMgrConst::agentid_assoc2funitid(item.m_cmd_req_pkt.smi_targ_ncore_unit_id) === <%=i%> &&
                    addrMgrConst::get_unit_type(item.m_cmd_req_pkt.smi_targ_ncore_unit_id) == addrMgrConst::DMI);
                
                if(m_tmp_qA.size > 0) begin
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("For DMI %0d, CmdReq outstanding is %0d, TotalCredits=%0d", <%=i%>, m_tmp_qA.size, env_cfg.dmiCreditLimit[<%=i%>]),UVM_DEBUG)
                end

                if (m_tmp_qA.size > env_cfg.dmiCreditLimit[<%=i%>]) begin 
                    print_queues();
                    foreach(m_tmp_qA[i]) begin 
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("i:%0d, index:%0d isSMICMDReqSent:%0d isSMICMDRespRecd:%0d isDVM:%0d targ_ncore_unit_id:%0d isCoherent:%0d",i, m_tmp_qA[i], m_ott_q[m_tmp_qA[i]].isSMICMDReqSent,m_ott_q[m_tmp_qA[i]].isSMICMDRespRecd,m_ott_q[m_tmp_qA[i]].isDVM, m_ott_q[m_tmp_qA[i]].m_cmd_req_pkt.smi_targ_ncore_unit_id, m_ott_q[m_tmp_qA[i]].isCoherent),UVM_NONE)
                        m_ott_q[m_tmp_qA[i]].print_me();
                    end
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("NCBU has more CmdReq outstanding than MaxCreditPerDMI for DMI %0d (Requests outstanding:%0d MaxCreditPerDMI:%0d)", <%=i%>, m_tmp_qA.size(), env_cfg.dmiCreditLimit[<%=i%>]));   
                end else begin
                   // print_queues();
                    foreach(m_tmp_qA[i]) begin 
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("i:%0d, index:%0d isSMICMDReqSent:%0d isSMICMDRespRecd:%0d isDVM:%0d targ_ncore_unit_id:%0d isCoherent:%0d",i, m_tmp_qA[i], m_ott_q[m_tmp_qA[i]].isSMICMDReqSent,m_ott_q[m_tmp_qA[i]].isSMICMDRespRecd,m_ott_q[m_tmp_qA[i]].isDVM, m_ott_q[m_tmp_qA[i]].m_cmd_req_pkt.smi_targ_ncore_unit_id, m_ott_q[m_tmp_qA[i]].isCoherent),UVM_DEBUG)
                      //  m_ott_q[m_tmp_qA[i]].print_me();
                    end
                end
            end
            <%}%>

            <%for (var i = 0; i < obj.nDIIs; i++) {%> 
            if (m_pkt.smi_targ_ncore_unit_id inside { addrMgrConst::dii_ids[<%=i%>] }) begin
                m_tmp_qA = {};
                m_tmp_qA = m_ott_q.find_index with (item.isSMICMDReqSent  === 1 &&
                    item.isSMICMDRespRecd === 0 &&
                    item.isDVM            === 0 &&
                    addrMgrConst::agentid_assoc2funitid(item.m_cmd_req_pkt.smi_targ_ncore_unit_id) === <%=i%> &&
                    addrMgrConst::get_unit_type(item.m_cmd_req_pkt.smi_targ_ncore_unit_id) == addrMgrConst::DII);

                if(m_tmp_qA.size > 0) begin
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("For DII %0d, CmdReq outstanding is %0d, TotalCredits=%0d", <%=i%>, m_tmp_qA.size, env_cfg.diiCreditLimit[<%=i%>]),UVM_DEBUG)
                end

                if (m_tmp_qA.size > env_cfg.diiCreditLimit[<%=i%>]) begin 
                    print_queues();
                    foreach(m_tmp_qA[i]) begin 
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("i:%0d, index:%0d isSMICMDReqSent:%0d isSMICMDRespRecd:%0d isDVM:%0d targ_ncore_unit_id:%0d isCoherent:%0d",i, m_tmp_qA[i], m_ott_q[m_tmp_qA[i]].isSMICMDReqSent,m_ott_q[m_tmp_qA[i]].isSMICMDRespRecd,m_ott_q[m_tmp_qA[i]].isDVM, m_ott_q[m_tmp_qA[i]].m_cmd_req_pkt.smi_targ_ncore_unit_id, m_ott_q[m_tmp_qA[i]].isCoherent),UVM_NONE)
                        m_ott_q[m_tmp_qA[i]].print_me();
                    end
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("NCBU has more CmdReq outstanding that MaxCreditPerDII for DII %0d (Requests outstanding:%0d MaxCreditPerDII:%0d)", <%=i%>, m_tmp_qA.size(), env_cfg.diiCreditLimit[<%=i%>]));   
                end else begin
                   // print_queues();
                    foreach(m_tmp_qA[i]) begin 
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("i:%0d, index:%0d isSMICMDReqSent:%0d isSMICMDRespRecd:%0d isDVM:%0d targ_ncore_unit_id:%0d isCoherent:%0d",i, m_tmp_qA[i], m_ott_q[m_tmp_qA[i]].isSMICMDReqSent,m_ott_q[m_tmp_qA[i]].isSMICMDRespRecd,m_ott_q[m_tmp_qA[i]].isDVM, m_ott_q[m_tmp_qA[i]].m_cmd_req_pkt.smi_targ_ncore_unit_id, m_ott_q[m_tmp_qA[i]].isCoherent),UVM_DEBUG)
                       // m_ott_q[m_tmp_qA[i]].print_me();
                    end
                end
            end
            <%}%>

endfunction //  check_credits

//----------------------------------------------------------------------- 
// SMI Cmd Request Packet
//----------------------------------------------------------------------- 

// #Check.AIU.CMDReqFields

function void ioaiu_scoreboard::process_cmd_req(smi_seq_item m_pkt);
    int         m_tmp_qA[$];
    int         m_tmp_qB[$];
    int         m_tmp_qDVM[$];
    int         m_tmp_qCov[$];
    bit         is_wstrb_1;
    string      reason;
    eMsgCMD     cmd_type;
    int index;


	if(hasErr)
	    return;
    //#Check.IOAIU.CoherentDIIAccess_Write
    //#Check.IOAIU.CoherentDIIAccess_Read
    //#Check.IOAIU.NonCohFullRead
    //#Check.IOAIU.NonCohFullWrite
    //#Check.IOAIU.NonCohPtlRead
    //#Check.IOAIU.NonCohPtlWrite
    //#Check.IOAIU.Read
    //#Check.IOAIU.Write
    m_tmp_qA = {};
    m_tmp_qA = m_ott_q.find_index with (((item.isRead                                     === 1 ||
                                            item.isWrite                                   === 1 ||
                                            item.isUpdate                                  === 1 ||
                                            item.isIoCacheEvict                            === 1) &&
                                            item.isSMICMDReqSent                            === 1 &&
                                            item.m_cmd_req_pkt.smi_unq_identifier === m_pkt.smi_unq_identifier) &&
                                            (item.isSMIDTWReqNeeded==1 ? item.isACEWriteDataRecd == 1 : 1));

    // Its possible that STRResp is waiting to be sent for previous transaction
    // with same req aiu trans id and a CmdReq is sent 
    //#Check.IOAIU.CMDreq_type           
    if (m_tmp_qA.size > 0) begin                                   
        bit flag = 0;
        for (int i = 0; i < m_tmp_qA.size; i++) begin
            if (m_ott_q[m_tmp_qA[i]].isRead) begin
                if ((//DCTODO AXICHK m_ott_q[m_tmp_qA[i]].isACEReadDataSent === 0 ||
                        (!m_ott_q[m_tmp_qA[i]].isStrRspEligibleForIssue()) &&
                    (m_ott_q[m_tmp_qA[i]].isSMIDTWReqNeeded === 1 &&
                        m_ott_q[m_tmp_qA[i]].isSMIDTWRespRecd  === 0) ||
                    (m_ott_q[m_tmp_qA[i]].isSMIDTRReqNeeded   === 1 &&
                        (m_ott_q[m_tmp_qA[i]].isSMIAllDTRReqRecd === 0 &&
                        !(m_ott_q[m_tmp_qA[i]].isDVMSync))) ||
                    m_ott_q[m_tmp_qA[i]].isSMICMDRespRecd === 0)
                ) begin
                    flag = 1;
                end
            end else if (m_ott_q[m_tmp_qA[i]].isWrite) begin
                if (//(m_ott_q[m_tmp_qA[i]].isACEWriteRespSent === 0 ) && 
                        ((!m_ott_q[m_tmp_qA[i]].isStrRspEligibleForIssue()) &&
                        (!(m_ott_q[m_tmp_qA[i]].isMultiAccess 
                    && !m_ott_q[m_tmp_qA[i]].isMultiLineMaster 
                    && m_ott_q[m_tmp_qA[i]].m_axi_resp_expected[0] === DECERR))) && 
                        !m_ott_q[m_tmp_qA[i]].is2ndSMICMDReqNeeded) begin
                    flag = 1;
                end
            end
            else if (m_ott_q[m_tmp_qA[i]].isUpdate) begin
                <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                    if(!(m_ott_q[m_tmp_qA[i]].isStrRspEligibleForIssue()&&m_ott_q[m_tmp_qA[i]].isSMIUPDReqNeeded ? m_ott_q[m_tmp_qA[i]].isSMIUPDRespRecd : 1))
                        flag = 1;
                <%}else{%>
                    flag = 1;
                <%}%>
            end else if (m_ott_q[m_tmp_qA[i]].isIoCacheEvict) begin
                flag = 1;
            end
        end
        `ifndef FSYS_COVER_ON
        `sample_check(CmdReqMatchesOttIdOfOutstTxn,"<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Outgoing SMI command request has a matching smi_msg_id that matches previously sent SMI command/update request with same fields (MsgId %0d) %s", m_pkt.smi_msg_id, m_pkt.convert2string()),"",(flag==1),1)
        `endif
        if (flag) begin
            for (int i = 0; i < m_tmp_qA.size; i++) begin
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("OutstTxn #%0d",i), UVM_NONE);
                m_ott_q[m_tmp_qA[i]].print_me();
            end
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%1p", m_pkt), UVM_NONE);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing SMI command request has a matching smi_msg_id that matches previously sent SMI command/update request with same fields (MsgId %0d) %s", m_pkt.smi_msg_id, m_pkt.convert2string()), UVM_NONE); //DCTODO IDCHK
        end
    end
	
    m_tmp_qA = {};
    m_tmp_qA = m_ott_q.find_index with (item.matchCmdToTxn(m_pkt) && item.m_ott_status == ALLOCATED);
   

    if (m_tmp_qA.size === 0) begin 
        if ($test$plusargs("inject_smi_uncorr_error")) begin
        return;
        end                                      
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Cannot find a corresponding transaction for this CmdReq packet %s", m_pkt.convert2string()));
    end else begin
            <% if ( obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                ACE_cmd_addr_t ace_cmd_addr_tmp;
            <%}%>
            bit                  flag;
            m_tmp_qB = m_tmp_qA;

            if (m_tmp_qA.size > 1) begin
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("%p", m_pkt), UVM_MEDIUM);
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Found multiple corresponding ACE transactions for the above CmdReq packet"), UVM_LOW);

                    m_tmp_qA[0] = find_entry_with_cmdreq_id_in_ott_q(m_tmp_qA, m_pkt);
                    m_tmp_qB[0] = find_oldest_entry_in_ott_q(m_tmp_qB);
            end

    		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received SMI CMD_REQ packet at IOAIU SCB: %0s", m_ott_q[m_tmp_qA[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_pkt.convert2string()), UVM_LOW)
            index = m_tmp_qA[0];
            if (owo && m_ott_q[index].isCoherent && !m_ott_q[index].isRead && m_ott_q[index].isSMICMDReqSent) begin 
              if (ott_owned_st[m_ott_q[index].m_ott_id] == 0) begin 
                `uvm_warning("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received 2nd CMDreq packet but owned st was not asserted for OTT_ID:%0d", m_ott_q[index].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_ott_q[index].m_ott_id))
              end 
            end
            //CONC-13788 DVMs are strictly ordered on SMI.
             if(m_pkt.smi_msg_type == eCmdDvmMsg ) begin: _dvm_
                m_tmp_qDVM = {};
                m_tmp_qDVM = m_ott_q.find_index with (  item.m_ace_cmd_type == DVMMSG &&
                                                        !item.isSMICMDReqSent &&
                                                        item.t_creation < m_ott_q[m_tmp_qA[0]].t_creation);
                
                if(m_tmp_qDVM.size > 0) begin
                    //#Check.IOAIU.DVMOrdering.CMdReqsOrdering
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Found DVM Order Violation in CmdReq! RTL sends DVM CMDreq(IOAIU_UID:%0d) before previous DVM(IOAIU_UID:%0d) is sent on SMI CMDreq", m_ott_q[m_tmp_qA[0]].tb_txnid, m_ott_q[m_tmp_qDVM[0]].tb_txnid));
                end

                m_tmp_qDVM = {};
                m_tmp_qDVM = m_ott_q.find_index with (  item.m_ace_cmd_type == DVMMSG &&
                                                        item.isSMICMDReqSent && 
                                                        !item.isSMIDTWRespRecd &&
                                                        item.t_creation < m_ott_q[m_tmp_qA[0]].t_creation);
                if(m_tmp_qDVM.size > 0) begin
                    //#Check.IOAIU.DVMOrdering.OldDTWRsp->NewCmdReq
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Found DVM Order Violation in CmdReq! RTL sends DVM CMDreq(IOAIU_UID:%0d) before previous DVM(IOAIU_UID:%0d) that sent SMI CMDreq got DTWrsp", m_ott_q[m_tmp_qA[0]].tb_txnid, m_ott_q[m_tmp_qDVM[0]].tb_txnid));
                end
            end: _dvm_


	<% if(obj.useCache) { %> 
	    //CONC-9674 Check addr hazard only for proxyCache configuration
            //#Check.IOAIU.SMI.CMDReq.Address
                if(!m_ott_q[m_tmp_qA[0]].isUpdate) begin
                    int m_tmp_qOrder[$];
                    m_tmp_qOrder = {};
                    m_tmp_qOrder = m_ott_q.find_index with (item.isSMICMDReqSent                            === 1 &&
                                                            item.isSMISTRReqRecd                            === 0 &&
                                                            //item.gpra_order.hazard                          === 1 &&
                                                            (m_ott_q[m_tmp_qA[0]].isWrite ? 1 : !item.isUpdate)   &&
                                                            <% if (obj.wSecurityAttribute > 0) { %>
                                                                item.m_cmd_req_pkt.smi_ns === m_pkt.smi_ns &&
                                                            <% } %>
                                                            item.m_cmd_req_pkt.smi_addr[WSMIADDR-1:$clog2(SYS_nSysCacheline)] === m_pkt.smi_addr[WSMIADDR-1:$clog2(SYS_nSysCacheline)]);
                    //should not have address collision
                    if (m_tmp_qOrder.size > 0) begin
                    	//#Check.IOAIU.CMDreq.Read_OrderingCheck
                    	//#Check.IOAIU.CMDreq.Write_OrderingCheck
                        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%1p", m_pkt), UVM_NONE);
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing SMI command request(#%0d) has a smi_addr(0x%0x) that matches previously sent SMI command request(#%0d) (addr collision violation) %s", m_tmp_qA[0], m_pkt.smi_addr, m_tmp_qOrder[0], m_pkt.convert2string()), UVM_NONE);
                    end
                end else begin //Updates - (EVCT/WREVCT/WRCLN/WRBK)
                    int m_tmp_qOrder[$];
                    m_tmp_qOrder = {};
                    m_tmp_qOrder = m_ott_q.find_index with (item.isSMICMDReqSent                            === 1 &&
                                                            item.isSMISTRReqRecd                            === 0 &&
                                                            //item.gpra_order.hazard                          === 1 &&
                                                            !item.isRead                                          &&
                                                            <% if (obj.wSecurityAttribute > 0) { %>
                                                                item.m_cmd_req_pkt.smi_ns === m_pkt.smi_ns &&
                                                            <%}%>
                                                            item.m_cmd_req_pkt.smi_addr[WSMIADDR-1:$clog2(SYS_nSysCacheline)] === m_pkt.smi_addr[WSMIADDR-1:$clog2(SYS_nSysCacheline)]);
                    //should not have address collision
                    if (m_tmp_qOrder.size > 0) begin
                    	//#Check.IOAIU.CMDreq.Update_OrderingCheck
                        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%1p", m_pkt), UVM_NONE);
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing SMI command request(#%0d, memory update command) has a smi_addr(0x%0x) that matches previously sent SMI Write command request(#%0d) (addr collision violation) %s", m_tmp_qA[0], m_pkt.smi_addr, m_tmp_qOrder[0], m_pkt.convert2string()), UVM_NONE);
                    end
                end
				<% } %> 
            // #Check.AIU.CMDReqCreditChecks
            // #Check.IOAIU.v3.4.SCM.StartEndOfSim
            // Check to make sure nCmdInFlight is being obeyed
                <% if((obj.testBench != "fsys") && (obj.testBench != "emu") && (obj.testBench != "emu_t")) { %>
                if(k_csr_seq !== "ioaiu_csr_credit_adjustment_seq") 
                    check_credits(m_pkt);
                <%}%>
    
	            //#Cov.IOAIU.Concerto.QosOrder
                m_ott_q[m_tmp_qA[0]].setup_cmd_req(m_pkt);
                //#Check.IOAIU.AXI.Ordering
                if (m_ott_q[m_tmp_qA[0]].m_axi_resp_expected[0] !== DECERR && m_ott_q[m_tmp_qA[0]].m_axi_resp_expected[0] !== SLVERR) begin
                   if (owo && m_ott_q[m_tmp_qA[0]].isWrite)
		    	owo_check_axid_ordering_cmdreq(m_tmp_qA[0]);
		   else
	                check_axid_ordering(m_tmp_qA[0]);
                end



                  <%if(obj.useCache) { %> 
                 check_address_ordering(m_tmp_qA[0]);
                <%}%>
                

                <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
                    ace_cmd_addr_tmp.m_addr = {
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            m_pkt.smi_ns,
                                        <% } %>
                                            m_pkt.smi_addr
                                          };
                    ace_cmd_addr_tmp.m_cmdtype = m_ott_q[m_tmp_qA[0]].m_ace_cmd_type;
                    if(m_ott_q[m_tmp_qA[0]].isRead)
                        ace_cmd_addr_tmp.m_axdomain = m_ott_q[m_tmp_qA[0]].m_ace_read_addr_pkt.ardomain;
                    else
                        ace_cmd_addr_tmp.m_axdomain = m_ott_q[m_tmp_qA[0]].m_ace_write_addr_pkt.awdomain;
                    ace_cmd_addr_q.push_back(ace_cmd_addr_tmp);
                <%}%>
	            <%if(obj.fnQosEnable) { %>
		            //#Check.IOAIU.Concerto.QosOrder
		            if((m_ott_q[m_tmp_qB[0]].t_creation < m_ott_q[m_tmp_qA[0]].t_creation) && (m_ott_q[m_tmp_qB[0]].higherPriorityThan(m_ott_q[m_tmp_qA[0]]))) begin
		                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Found QoS Order Violation! OutstTxn #%0d to go before OutstTxn #%0d",m_tmp_qB[0],m_tmp_qA[0]),UVM_NONE);
		                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Found QoS Order Violation!"),UVM_NONE);
		            end
                <%}%>
                //#Cover.IOAIU.Starvation.EachCore_EventStatusCount
                //#Cover.IOAIU.Starvation.EachCore_EventStatus
                //#Check.IOAIU.Starvation.EventStatusCount
                foreach(m_ott_q[idx]) begin
                    if((m_ott_q[idx].t_creation < m_ott_q[m_tmp_qA[0]].t_creation) && (m_ott_q[m_tmp_qA[0]].higherPriorityThan(m_ott_q[idx]))) begin
                        // sb_stall_if.perf_count_events["Number_of_QoS_Starvations"].push_back(1);
                        break;
                    end
                end
                //set_no_pending_cmd_req(m_ott_q[m_tmp_qA[0]]);
                if(m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] != m_ott_q[m_tmp_qA[0]].home_dce_unit_id) begin
                    if(m_ott_q[m_tmp_qA[0]].isRead) begin
                        if(axi_cmdreq_id_vif.pending_cmd_req_ar["RD"][axi_cmdreq_id_vif.axi_cmdreq_id_ar[m_pkt.smi_msg_id]][m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID]] == 0)
                        begin
                            m_ott_q[m_tmp_qA[0]].no_pending_cmd_req = 1;
                            //end else begin  // It may happen that CmdRsp is pending, although DtrReq and StrReq might have arrived, so use updated logic of set_no_pending_cmd_req
                            //    set_no_pending_cmd_req(m_ott_q[m_tmp_qA[0]]);
                        end
                        //$display($time," Rd [%0x] [%0x] :%0x",axi_cmdreq_id_vif.axi_cmdreq_id_ar[m_pkt.smi_msg_id],m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID],(axi_cmdreq_id_vif.pending_cmd_req_ar["RD"][axi_cmdreq_id_vif.axi_cmdreq_id_ar[m_pkt.smi_msg_id]][m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID]]));
                    end else begin
                        if(axi_cmdreq_id_vif.pending_cmd_req_ar["WR"][axi_cmdreq_id_vif.axi_cmdreq_id_ar[m_pkt.smi_msg_id]][m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID]] == 0)
                        begin
                            m_ott_q[m_tmp_qA[0]].no_pending_cmd_req = 1;
                            //end else begin // It may happen that CmdRsp is pending, although DtrReq and StrReq might have arrived, so use updated logic of set_no_pending_cmd_req
                            //    set_no_pending_cmd_req(m_ott_q[m_tmp_qA[0]]);
                        end
                        //$display($time," Wr [%0x] [%0x] :%0x",axi_cmdreq_id_vif.axi_cmdreq_id_ar[m_pkt.smi_msg_id],m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID],(axi_cmdreq_id_vif.pending_cmd_req_ar["WR"][axi_cmdreq_id_vif.axi_cmdreq_id_ar[m_pkt.smi_msg_id]][m_pkt.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID]]));
                    end
                end else begin
                    m_ott_q[m_tmp_qA[0]].no_pending_cmd_req = 1;
                end
                                 
                <%if(obj.useCache) { // case AXI4 with proxy cache %>
				if (!addrMgrConst::get_addr_gprar_nc(m_ott_q[m_tmp_qA[0]].m_cmd_req_pkt.smi_addr)) begin:_coh_mode // if nc bit in GPRA registeris is asserted
                    if (m_ott_q[m_tmp_qA[0]].m_iocache_allocate === 1 && m_ott_q[m_tmp_qA[0]].isRead === 1) begin
                            if (!m_ott_q[m_tmp_qA[0]].matchCmdType(eCmdRdVld)) begin
                                m_ott_q[m_tmp_qA[0]].print_me();
			                    $cast(cmd_type, m_ott_q[m_tmp_qA[0]].m_cmd_req_pkt.smi_msg_type);			
                                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("For a IO cache allocate read, SMI CmdReq should be CmdRdVld, but its not (smi_msg_type:%s)", cmd_type.name()), UVM_NONE);
                            end
                    end else if ((m_ott_q[m_tmp_qA[0]].isWriteHitFull() || m_ott_q[m_tmp_qA[0]].isWriteHit() || m_ott_q[m_tmp_qA[0]].m_iocache_allocate === 1) && m_ott_q[m_tmp_qA[0]].isWrite === 1) 
                    begin
                        //else if (m_ott_q[m_tmp_qA[0]].isWriteHit()) begin
                        if(m_ott_q[m_tmp_qA[0]].isMultiAccess) begin
                            if(m_ott_q[m_tmp_qA[0]].isPartialWrite)
                                is_wstrb_1 = 0;
                            else
                                is_wstrb_1 = 1;
                        end else begin
                            // Full cacheline
                            is_wstrb_1 = 1;
                            foreach (m_ott_q[m_tmp_qA[0]].m_ace_write_data_pkt.wstrb[i]) begin
                                if (m_ott_q[m_tmp_qA[0]].m_ace_write_data_pkt.wstrb[i] !== '1) begin
                                    is_wstrb_1 = 0;
                                    break;
                                end 
                            end
                        end
                            if (m_ott_q[m_tmp_qA[0]].m_ace_write_addr_pkt.awlen === ((SYS_nSysCacheline*8/wSmiDPdata) - 1) && is_wstrb_1) begin
		                        $cast(cmd_type,m_ott_q[m_tmp_qA[0]].m_cmd_req_pkt.smi_msg_type);
                                if (!m_ott_q[m_tmp_qA[0]].matchCmdType(eCmdMkUnq)) begin
                                    uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("For a IO cache allocate full cacheline write, SMI CmdReq should be CmdMkUnq, but its not (SMI:%0p) for OutstTxn #%0d",cmd_type.name(),m_tmp_qA[0]), UVM_NONE);
                                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("For a IO cache allocate full cacheline write, SMI CmdReq should be CmdMkUnq, but its not (SMI:%0p)",cmd_type.name()), UVM_NONE);
                                end
                            end else begin
		                        $cast(cmd_type,m_ott_q[m_tmp_qA[0]].m_cmd_req_pkt.smi_msg_type);
                                if (!m_ott_q[m_tmp_qA[0]].matchCmdType(eCmdRdUnq)) begin
                                    m_ott_q[m_tmp_qA[0]].print_me();
                                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("For a IO cache allocate partial cacheline write, SMI CmdReq should be CmdRdUnq, but its not (SMI:%0p)", cmd_type.name()), UVM_NONE);
                                end
                            end
                    end else if (m_ott_q[m_tmp_qA[0]].m_iocache_allocate === 0 && m_ott_q[m_tmp_qA[0]].isWrite === 1) begin
                        if(m_ott_q[m_tmp_qA[0]].isMultiAccess) begin
                            // Full cacheline
                            is_wstrb_1 = 1;
                            foreach (m_ott_q[m_tmp_qA[0]].m_ace_write_data_pkt.wstrb[i]) begin
                                if (m_ott_q[m_tmp_qA[0]].m_ace_write_data_pkt.wstrb[i] !== '1) begin
                                    is_wstrb_1 = 0;
                                    break;
                                end 
                            end
                        end else begin
                            // Full cacheline
                            is_wstrb_1 = 1;
                            foreach (m_ott_q[m_tmp_qA[0]].m_ace_write_data_pkt.wstrb[i]) begin
                                if (m_ott_q[m_tmp_qA[0]].m_ace_write_data_pkt.wstrb[i] !== '1) begin
                                    is_wstrb_1 = 0;
                                    break;
                                end 
                            end
                        end
                        // Full cacheline
                        if (m_ott_q[m_tmp_qA[0]].m_ace_write_addr_pkt.awlen === ((SYS_nSysCacheline*8/wSmiDPdata) - 1) && is_wstrb_1) begin
                            if (!m_ott_q[m_tmp_qA[0]].m_cmd_req_pkt.smi_msg_type == eCmdWrUnqFull) begin
                                m_ott_q[m_tmp_qA[0]].print_me();
                                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("For a IO cache non-allocate full cacheline write, SMI CmdReq should be CmdWrUnqFull, but its not (SMI:%0p)", m_ott_q[m_tmp_qA[0]].getCmdType()), UVM_NONE);
                            end
                        end else begin
                            if (m_ott_q[m_tmp_qA[0]].m_cmd_req_pkt.smi_msg_type !== eCmdWrUnqPtl && m_ott_q[m_tmp_qA[0]].m_cmd_req_pkt.smi_msg_type != eCmdWrNCPtl) begin
                                m_ott_q[m_tmp_qA[0]].print_me();
                                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("For a OutstTxn #%0d IO cache allocate partial cacheline write, SMI CmdReq should be CmdWrUnqPtl, but its not (SMI:%0p)", m_tmp_qA[0], m_ott_q[m_tmp_qA[0]].getCmdType()), UVM_NONE);
                            end
                        end
                    end else if(m_ott_q[m_tmp_qA[0]].isIoCacheEvict) begin		       
                        if (!m_ott_q[m_tmp_qA[0]].matchCmdType(eCmdWrNCFull)) begin
                            m_ott_q[m_tmp_qA[0]].print_me();
                            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("For a IO cache evict OutstTxn #%0d, SMI CmdReq should be CmdWrNCFull, but its not (SMI:%0p)", m_tmp_qA[0], m_ott_q[m_tmp_qA[0]].m_cmd_req_pkt.smi_msg_type), UVM_NONE);
                        end
                    end	
                    end:_coh_mode
                    <%} // useCache %>
                      
                <%if((obj.fnNativeInterface === "ACE-LITE") || (obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE") || (obj.fnNativeInterface == "ACE5") ) { // case !AXI4%>
                
                if (m_ott_q[m_tmp_qA[0]].matchNativeTxnTypeToSMICmdType()) begin
                    flag = 1;								
                end									
                if (flag === 0) begin
                    m_ott_q[m_tmp_qA[0]].print_me();
                    //#Check.IOAIU.SMI.CMDReq.CMType
                    $cast(cmd_type,m_ott_q[m_tmp_qA[0]].m_cmd_req_pkt.smi_msg_type);
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Transaction has mismatched SMI command request message type and for OutstTxn #%0d for %s ace address axsnoop type (SMI:%0s ACE:%0s)", m_tmp_qA[0],m_ott_q[m_tmp_qA[0]].isRead ? "read" : "write", cmd_type.name(), m_ott_q[m_tmp_qA[0]].m_ace_cmd_type), UVM_NONE);
                end
            <%}%>
            end // else: !if(m_tmp_qA.size === 0)
            // Check to make sure CMDReq is sent with correct Req AIU ID 
             
            // Check to make sure ace lock bit is correctly sent in CmdReq
            <%if(!((obj.fnNativeInterface === "AXI4") || (obj.fnNativeInterface === "AXI5"))) { %> 
                if (m_ott_q[m_tmp_qA[0]].isRead) begin
                    if (!m_ott_q[m_tmp_qA[0]].matchAceLock()) begin 
                        m_ott_q[m_tmp_qA[0]].print_me();
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Lock bit mismatch for OutstTxn #%0d between ACE and SMI CmdReq (Ace:%0d SMI:%0d)",m_tmp_qA[0],m_ott_q[m_tmp_qA[0]].m_ace_read_addr_pkt.arlock,  m_ott_q[m_tmp_qA[0]].getAceLock()), UVM_NONE);
                    end
                end
            <%}%>
            
           
        // QOS starvation related code
        if(starvation_mode) begin
            // m_pkt.smi_msg_id
            prev_cmd = ott_id_q[m_pkt.smi_msg_id];
        end
        ott_id_q[m_pkt.smi_msg_id].overflow = 0;
        ott_id_q[m_pkt.smi_msg_id].cmd_req_sent = 1;

        if (owo && m_ott_q[m_tmp_qA[0]].isWrite && m_ott_q[m_tmp_qA[0]].isCoherent && m_ott_q[m_tmp_qA[0]].is2ndSMICMDReqSent) begin 
           update_owo_wr_state_on_coh_wb_cmdreq_sent(m_tmp_qA[0]); 
        end

    endfunction // process_cmd_req
   
    //----------------------------------------------------------------------- 
    // Process SMI Data Write Request Packet
    //----------------------------------------------------------------------- 

    // #Check.AIU.DTWReqFields



function void ioaiu_scoreboard::process_dtw_req(smi_seq_item m_pkt);
    int                   m_tmp_qA[$];
    dp_dwid_t             exp_dwid;
    bit                   uncorr_err;
    int                   dest_id;
    int                   fnmem_region_idx;
    bit                   is_dii;
    string s = "";
    smi_seq_item          dtwreq_pkt;
    int                   num_valid_beats;
    m_tmp_qA = {};
	
    m_tmp_qA = m_ott_q.find_index with (item.matchDtwToTxn(m_pkt));
    if (m_tmp_qA.size > 1) begin                                   
        for (int i = 0; i < m_tmp_qA.size; i++) begin
	    s = $sformatf("%s,%0d",s,m_tmp_qA[i]);
            m_ott_q[m_tmp_qA[i]].print_me();
        end
        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s MsgType:%p", m_pkt.convert2string(),m_pkt.smi_msg_type), UVM_NONE);
        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Outgoing DTWreq has multiple matching write/snoop packets to which it can be a match %s",s), UVM_NONE);
        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing DTWreq has multiple matching write/snoop packets to which it can be a match"), UVM_NONE);
    end
    else if (m_tmp_qA.size === 0) begin                                   
        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", "DTW_ERROR!", UVM_NONE);
        for (int i = 0; i < m_ott_q.size; i++) begin
	    if(m_ott_q[i].isWrite && m_ott_q[i].isSMICMDReqSent && m_ott_q[i].isACEWriteDataRecd && m_ott_q[i].isSMIDTRReqNeeded) begin
	        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("OutstTxn # %0d",i), UVM_NONE);
                m_ott_q[i].print_me();
	    end
        end
        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Outgoing DTWreq has no matching write/snoop/read packets for which it can be a match TransactionID:0x%0h RBID:0x%0h %s", m_pkt.smi_msg_id, m_pkt.smi_rbid, m_pkt.convert2string()), UVM_NONE);
        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing DTWreq has no matching write/snoop/read packets for which it can be a match"), UVM_NONE);
    end
    else begin             
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received DTW_REQ packet at IOAIU SCB: %0s",m_ott_q[m_tmp_qA[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)
	
	<%if(obj.COVER_ON) { %> 
         `ifndef FSYS_COVER_ON
         //#Cover.IOAIU.DTWreq.CMStatusError.DBad
        cov.collect_dtw_req_cmstatus_err(m_ott_q[m_tmp_qA[0]],m_pkt,core_id);
         `endif 
          <%}%>

        m_ott_q[m_tmp_qA[0]].add_dtw_req(m_pkt,$sformatf("OuststTxn#%0d",m_tmp_qA[0]));
        
       if(owo && !m_ott_q[m_tmp_qA[0]].isSnoop) begin
            owo_check_axid_ordering_dtwreq(m_tmp_qA[0]);
       end
        
        //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> num_valid_beats:%0d",m_ott_q[m_tmp_qA[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,num_valid_beats), UVM_LOW)
    end
                

endfunction : process_dtw_req

//----------------------------------------------------------------------- 
// SMI Data Reply Request Packet (Incoming DTR)
//----------------------------------------------------------------------- 

// #Check.AIU.DTRReqFields

function void ioaiu_scoreboard::process_dtr_req(smi_seq_item m_pkt);
	int		m_tmp_qA[$];
	int		tmp_q_target_id_err[$];
	int 	find_q_targ_id_err[$];
    int 	find_q_targ_id_err_1[$];
	bit 	isDtrReqErr;
	string 	s;    

    <% if(obj.testBench == "fsys" || obj.testBench == "emu") { %>
    if(addr_trans_mgr::check_aiu_is_unconnected(.tgt_unit_id(m_pkt.smi_targ_ncore_unit_id), .src_unit_id(m_pkt.smi_src_ncore_unit_id))) begin
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",
        $sformatf("In DTR_REQ, Connectivity between AIU FUnitID %0d and AIU FUnitID %0d should have been optimized and not existing", m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_src_ncore_unit_id))
    end
    <% } %>
  
    find_q_targ_id_err = {};
    find_q_targ_id_err_1 = {};

    m_tmp_qA = {};
    tmp_q_target_id_err = {};
    m_tmp_qA = m_ott_q.find_index with (item.matchDtrToTxn(m_pkt));
        
	if ($test$plusargs("wrong_dtrreq_target_id")) begin
    	tmp_q_target_id_err = m_ott_q.find_index with (
			!item.isSMISTRRespSent &&
            (item.isRead ||
			 item.isAtomic                                    	
			 <%if(obj.useCache) { %> 
            || ((csr_ccp_lookupen)? (item.isWrite && item.isIoCacheTagPipelineSeen  && (item.m_iocache_allocate  || item.isWriteHit())) : 0)
            <% } %>)
            && item.isSMICMDReqSent                   
            && item.isSMIDTRReqNeeded                      
            && !item.isSMIAllDTRReqRecd                     
			&& (item.m_cmd_req_pkt.smi_conc_msg_class === m_pkt.smi_conc_rmsg_class) 
			&& (item.m_cmd_req_pkt.smi_msg_id === m_pkt.smi_rmsg_id) 
			&& !item.isDVMSync 
            && ((item.isSMICMDRespRecd && !item.isSMICMDRespErr) || !item.isSMICMDRespRecd));
	end
        
    if (m_tmp_qA.size === 0 && tmp_q_target_id_err.size() == 0) begin
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%1p", m_pkt), UVM_NONE);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Above incoming DTR request does not have a matching read request %s",m_pkt.convert2string()), UVM_NONE);
    end
    else begin
        if ($test$plusargs("wrong_dtrreq_target_id")) begin
        	if (m_pkt.smi_targ_ncore_unit_id !== <%= obj.FUnitId%>) begin
            	m_tmp_qA = tmp_q_target_id_err;
            end
        end
        if (m_tmp_qA.size > 1) begin
        	int count = 0;
            int index = 0;
            foreach (m_tmp_qA[i]) begin
            	if (!(m_ott_q[m_tmp_qA[i]].isSMISTRReqRecd &&
                     ((m_ott_q[m_tmp_qA[i]].isSMIDTRReqNeeded && 
                       m_ott_q[m_tmp_qA[i]].isSMIAllDTRReqRecd) || 
                       !m_ott_q[m_tmp_qA[i]].isSMIDTRReqNeeded) &&
                     m_ott_q[m_tmp_qA[i]].isACEReadDataSent && 
                     !m_ott_q[m_tmp_qA[i]].isSMISTRRespSent)) begin
            		count++;
                    index = m_tmp_qA[i];
                end
            end
            if (count > 1) begin
	        	s = "";
                foreach (m_tmp_qA[i]) begin
	            	s = $sformatf("%s,%0d",s,m_tmp_qA[i]);
                    m_ott_q[m_tmp_qA[i]].print_me();
                end
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%1p", m_pkt), UVM_NONE);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Above incoming DTR request has multiple matching read requests OutstTxn#'s:%s %s",s,m_pkt.convert2string()), UVM_NONE);
            end
            else begin
            	m_tmp_qA[0] = index;
            end
        end //m_tmp_qA.size > 1

        if ($test$plusargs("wrong_dtrreq_target_id")) begin
        	if (m_pkt.smi_targ_ncore_unit_id !== <%= obj.FUnitId%> && m_ott_q[m_tmp_qA[0]].isRead) begin
         		`uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Target id error injected in DTRreq targ_id = %0h, src_id = %0h, smi_msg_id = %0h",m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id),UVM_NONE)
                find_q_targ_id_err_1 = dtr_req_msg_id_targ_id_err.find_index with (item.src_id == m_pkt.smi_src_ncore_unit_id &&
                                                                                   item.msg_id == m_pkt.smi_msg_id);
                if (find_q_targ_id_err_1.size() == 1) begin
                	dtr_req_msg_id_targ_id_err[find_q_targ_id_err_1[0]] = '{m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id};
                end else if (find_q_targ_id_err_1.size() == 0) begin
                	dtr_req_msg_id_targ_id_err.push_back( '{m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id} );
                end
            end else begin
                find_q_targ_id_err = dtr_req_msg_id_targ_id_err.find_index with (item.src_id == m_pkt.smi_src_ncore_unit_id &&
                                                                                 item.msg_id == m_pkt.smi_msg_id
                                                                                );

                if (find_q_targ_id_err.size()== 1 && m_pkt.smi_targ_ncore_unit_id == <%=obj.FUnitId%>) begin
                  	dtr_req_msg_id_targ_id_err.delete(find_q_targ_id_err[0]);
                end
            end
        end //if ($test$plusargs("wrong_dtrreq_target_id")) begin

		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below inbound SMI DTR_REQ packet at IOAIU SCB: %0s",m_ott_q[m_tmp_qA[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)
         <%if(obj.COVER_ON) { %> 
         `ifndef FSYS_COVER_ON
         //#Cover.IOAIU.DTRreq.CMStatusError.DBad
         cov.collect_dtr_req_cmstatus_err(m_ott_q[m_tmp_qA[0]], m_pkt,core_id);
         `endif 
          <%}%> 
         
        m_ott_q[m_tmp_qA[0]].add_dtr_req(m_pkt);
	 	//#Check.IOAIU.CONC.CmStatus
        //For Cmstatus Err in DtrReq
        if ((m_ott_q[m_tmp_qA[0]].isWrite && (m_ott_q[m_tmp_qA[0]].dtrreq_cmstatus_err || ((m_ott_q[m_tmp_qA[0]].dtr_req_dbad_high) && (m_ott_q[m_tmp_qA[0]].isPartialWrite == 0))) && m_ott_q[m_tmp_qA[0]].isMultiAccess) ) begin
        	int m_tmp_qE[$];
            int multiline_tracking_id_tmp = m_ott_q[m_tmp_qA[0]].m_multiline_tracking_id;
            int total_cacheline_count_tmp = m_ott_q[m_tmp_qA[0]].total_cacheline_count;
            m_tmp_qE = {}; 
            m_tmp_qE = m_ott_q.find_index with (item.isMultiAccess           === 1 &&
                                                item.m_multiline_tracking_id === multiline_tracking_id_tmp);
           for (int i = 0; i < m_tmp_qE.size(); i++) begin 
                if(m_tmp_qE[i] > m_tmp_qA[0])
            	m_ott_q[m_tmp_qE[i]].dtrreq_cmstatus_err = 1;
                if(m_pkt.smi_cmstatus_err_payload === 7'b000_0100  ||  m_ott_q[m_tmp_qA[0]].dtrreq_cmstatus_add_err ==1) begin
                 			//#Check.IOAIU.DTRreqCMStatusAddrErr.BRespDECERR
                                        //#Check.IOAIU.DTRreqCMStatusAddrErr.RRespDECERR 
					m_ott_q[m_tmp_qE[i]].m_axi_resp_expected[0] = DECERR;
                	m_ott_q[m_tmp_qE[i]].dtrreq_cmstatus_add_err =1;
				end
				else  begin  
                                        //#Check.IOAIU.DTRreqCMStatusAddrErr.RRespSLVERR
					//#Check.IOAIU.DTRreqCMStatusAddrErr.BRespSLVERR
                                        if(m_ott_q[m_tmp_qE[i]].m_axi_resp_expected[0] != DECERR)
					m_ott_q[m_tmp_qE[i]].m_axi_resp_expected[0] = SLVERR;
                end
            end 
        end

         	<%if(obj.useCache) { %>
        m_ott_q[m_tmp_qA[0]].ccp_state_on_DTRreq = return_cacheline_state(m_ott_q[m_tmp_qA[0]].ccp_addr, m_ott_q[m_tmp_qA[0]].m_security); 
	    			//#Check.IOAIU.CCP.SDPartialFillCase
	    			if(m_ott_q[m_tmp_qA[0]].isFillReqd && m_ott_q[m_tmp_qA[0]].isWrite && ((return_cacheline_state(m_ott_q[m_tmp_qA[0]].ccp_addr, m_ott_q[m_tmp_qA[0]].m_security) === SD) || ((m_ott_q[m_tmp_qA[0]].m_ccp_ctrl_pkt.currstate === SD) && (return_cacheline_state(m_ott_q[m_tmp_qA[0]].ccp_addr, m_ott_q[m_tmp_qA[0]].m_security) === SC))))begin
	         			m_ott_q[m_tmp_qA[0]].dropDtrData    = 1;
	         			m_ott_q[m_tmp_qA[0]].isFillDataReqd = 1;
	         			<%if(obj.COVER_ON) { %>
		    				//#Cov.IOAIU.CCP.SDPartialFillCase
		    				`ifndef FSYS_COVER_ON
		    				cov.sd_hit_partial_upgrade = 1;
		    				`endif
		    				`ifndef FSYS_COVER_ON
                            case(core_id)
                                <%for(let i=0; i< obj.nNativeInterfacePorts; i+=1){%>
                                    <%=i%> : begin
		    				            cov.ccp_sd_partial_upgrade_core<%=i%>.sample();
                                    end
                                <%}%>
                            endcase
		    				`endif
		    				`ifndef FSYS_COVER_ON
		    				cov.sd_hit_partial_upgrade = 0;
		    				`endif
                 		<%}%>
	    			end
	    		update_cacheline_state(m_tmp_qA[0]);
	 		<% } %>
            
            m_ott_q[m_tmp_qA[0]].isSMIAllDTRReqRecd = 1;
              
            if (m_ott_q[m_tmp_qA[0]].isRead) begin
                // Check if ACE read data is correct - for partials, ACE read data might already have been sent 
                // Do this check only for the first DTRReq. Subsequent DTRReqs are checked against the first 
                if (m_ott_q[m_tmp_qA[0]].isACEReadDataSent && 
                	!m_ott_q[m_tmp_qA[0]].isDVM && 
                	!m_ott_q[m_tmp_qA[0]].mem_regions_overlap) begin
                  //#Check.IOAIU.SMI.DtrReq.cmstatus
                    if (!aiu_nodetEn_err_inj &&  m_pkt.smi_cmstatus !==  8'b1000_0011 /* && !aiu_double_bit_errors_enabled*/) begin
                        m_ott_q[m_tmp_qA[0]].compare_smi_axi_data();
                    end
                    <% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                    	m_ott_q[m_tmp_qA[0]].check_rresp_for_ace();
					<%}%>
                end
            end

            // Checking to see if STRReq has been received and comparing against ST of the STRReq
	   //DCTODO DATACHK
            if (m_ott_q[m_tmp_qA[0]].isSMISTRReqRecd === 1) begin
	       if ((m_ott_q[m_tmp_qA[0]].m_dtr_req_pkt != null) /*&& (m_ott_q[m_tmp_qA[0]].m_str_req_pkt.smi_cmstatus_st > 0)*/) begin
                  m_ott_q[m_tmp_qA[0]].isSMIAllDTRReqRecd = 1;
               end
            end
        end      
endfunction : process_dtr_req

//----------------------------------------------------------------------- 
// SMI Snoop Request Packet
//----------------------------------------------------------------------- 


function void ioaiu_scoreboard::process_snp_req(smi_seq_item m_pkt);
    <%if(obj.useCache == 1 || (obj.orderedWriteObservation == true && (obj.fnNativeInterface  == "AXI4" || obj.fnNativeInterface  == "AXI5"))) { %>
        ioaiu_scb_txn m_txn;
        int         m_tmp_qA[$];
        int         m_tmp_qCov[$];
        ace_snoop_addr_pkt_t                  m_ace_snoop_tmp_pkt;
        int find_q_targ_id_err[$];
        int find_q_targ_id_err_1[$];

        find_q_targ_id_err = {};
        find_q_targ_id_err_1 = {};

           
        //#Check.IOAIU.ReadSnoopOverlap
        //#Check.IOAIU.WriteSnoopOverlap
        // Skipping checks on snoops which will just Invalidate or cause a DTW (recall transaction)
        if (m_pkt.smi_msg_type === SNP_CLN_DTR || 
            m_pkt.smi_msg_type === SNP_VLD_DTR || 
            m_pkt.smi_msg_type === SNP_INV_DTR ) begin
            // Adding check to make sure snooping AIU is not same as requesting AIU
            if (m_pkt.smi_src_id === <%=obj.FUnitId%>) begin 
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%1p", m_pkt), UVM_NONE);
                if(!$test$plusargs("inject_smi_uncorr_error"))
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Incoming SMI snoop request's requesting AIU ID is same as the snooping AIU ID %0d", m_req_aiu_id), UVM_NONE);
            end
        end
        //#Check.IOAIU.SMI.SNPReq.target_id
        //#Check.IOAIU.SMI.SNPReq.initiatorID
        if ($test$plusargs("wrong_snpreq_target_id")) begin
            if (m_pkt.smi_targ_ncore_unit_id !== <%= obj.FUnitId%>) begin
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Target id error injected in SNPreq targ_id = %0h, src_id = %0h, smi_msg_id = %0h",m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id),UVM_NONE)
                find_q_targ_id_err_1 = snp_req_msg_id_targ_id_err.find_index with (item.src_id == m_pkt.smi_src_ncore_unit_id &&
                                                                                item.msg_id == m_pkt.smi_msg_id);
                if (find_q_targ_id_err_1.size() == 1) begin
                    snp_req_msg_id_targ_id_err[find_q_targ_id_err_1[0]] = '{m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id};
                end else if (find_q_targ_id_err_1.size() == 0) begin
                    snp_req_msg_id_targ_id_err.push_back( '{m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id} );
                end
            end else begin
                find_q_targ_id_err = snp_req_msg_id_targ_id_err.find_index with (item.src_id == m_pkt.smi_src_ncore_unit_id &&
                                                                             item.msg_id == m_pkt.smi_msg_id);
                if (find_q_targ_id_err.size()== 1 && m_pkt.smi_targ_ncore_unit_id == <%=obj.FUnitId%>) begin
                    snp_req_msg_id_targ_id_err.delete(find_q_targ_id_err[0]);
                end
            end
        end
        <%if(obj.COVER_ON && obj.useCache) { %>
            m_tmp_qA = {};
            m_tmp_qA = m_ott_q.find_index with (item.isIoCacheEvict &&
					    (item.m_ccp_ctrl_pkt.evictaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] === m_pkt.smi_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)]) &&
					    item.m_ccp_ctrl_pkt.evictsecurity === m_pkt.smi_ns);
            if(m_tmp_qA.size() > 0) begin
                //#Cov.IOAIU.SNPReq.SNPReqHitsAddressBeingEvicted
                `ifndef FSYS_COVER_ON
                cov.snoop_hit_evict = 1;
                `endif
                `ifndef FSYS_COVER_ON
                    case(core_id)
                        <%for(let i=0; i< obj.nNativeInterfacePorts; i+=1){%>
                            <%=i%> : begin
                                cov.ccp_snoop_hit_evict_core<%=i%>.sample();
                            end
                        <%}%>
                    endcase
                `endif
                `ifndef FSYS_COVER_ON
                cov.snoop_hit_evict = 0;
                `endif
            end
        <%}%>
        num_snoops++;
        case (m_pkt.smi_msg_type) 
            SNP_INV      : num_snp_inv++;
            SNP_CLN_DTR  : num_snp_cln_dtr++;
            SNP_VLD_DTR  : num_snp_vld_dtr++;
            SNP_INV_DTR  : num_snp_inv_dtr++;
            SNP_CLN_DTW  : num_snp_cln_dtw++;
            SNP_INV_DTW  : num_snp_inv_dtw++;
            SNP_NITC     : num_snp_nitc++;
            SNP_NITCCI   : num_snp_nitcci++;
            SNP_NITCMI   : num_snp_nitcmi++;
            SNP_NOSDINT  : num_snp_nosdint++;
            SNP_INV_STSH : num_snp_inv_stsh++;
            SNP_UNQ_STSH : num_snp_unq_stsh++;
            SNP_STSH_SH  : num_snp_stsh_sh++;
            SNP_STSH_UNQ : num_snp_stsh_unq++;
            SNP_DVM_MSG  : num_snp_dvm_msg++;
            default : begin 
              `uvm_warning("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("Did't match any snoop txn cmdtype=%0s",m_pkt.smi_msg_type))
            end 
        endcase

        tb_txn_count++;
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received SMI SNP_REQ packet at IOAIU SCB: %0s",tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)
	    
        check_address_core_id(m_pkt.smi_addr);
        m_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen, csr_ccp_updatedis);
        m_txn.setup_snp_req(m_pkt);
        <%if(obj.useCache) {%>
        if (csr_ccp_lookupen) set_cacheline_way(m_txn);
        <%}%>
        m_txn.tb_txnid = tb_txn_count;
        m_txn.core_id = core_id;
        m_ott_q.push_back(m_txn);
        ->e_queue_add;

        
        m_tmp_qCov = {};
        m_tmp_qCov = m_ott_q.find_index with (((item.isSMIUPDReqSent) ? item.m_upd_req_pkt.smi_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)] === m_pkt.smi_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)] : 0)&&
                                            item.isSMIUPDReqSent === 1 &&
                                            item.isUpdate === 1
                               );

        // #Check.AIU.NoMoreIncomingSnoopsThanNumberOfSTTEntries
        <% if (!(sftype === "UNDEFINED")) { %> 
            m_tmp_qA = {};
            m_tmp_qA = m_ott_q.find_index with (item.isSnoop          === 1 &&
                                                item.isSMISNPReqRecd  === 1 &&
                                                item.isSMISNPRespSent === 0 &&
                                                item.isDVM            === 0
                                               );
    
            if (m_tmp_qA.size() > <%=obj.nSttCtrlEntries%>) begin
                print_queues();
                if(!$test$plusargs("inject_smi_uncorr_error")) begin
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("AIU received more snoops than number of STT entries (Snoops Received: %0d STT Entries: %0d", m_tmp_qA.size(), <%=obj.nSttCtrlEntries%>), UVM_NONE);
                end
            end                                   
        <%}%>
    <%}%>
    <%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (((obj.nDvmMsgInFlight > 0) || (obj.nDvmSnpInFlight > 0)) && (aiu_axiInt.params.eAc == 1)) || (((obj.fnNativeInterface === "ACE-LITE") || (obj.fnNativeInterface === "ACELITE-E")) && obj.orderedWriteObservation == true)) { %>
        ioaiu_scb_txn m_txn;
        int         m_tmp_qA[$];
        int         m_tmp_qCov[$];
        
        // Skipping checks on snoops which will just Invalidate or cause a DTW (recall transaction)
        if (m_pkt.smi_msg_type === SNP_CLN_DTR || 
            m_pkt.smi_msg_type === SNP_VLD_DTR || 
            m_pkt.smi_msg_type === SNP_INV_DTR 
        ) begin
            // Adding check to make sure snooping AIU is not same as requesting AIU
            if (m_pkt.smi_mpf1_dtr_tgt_id === <%=obj.FUnitId%>) begin 
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%1p", m_pkt), UVM_NONE);
                if(!$test$plusargs("inject_smi_uncorr_error")) begin
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Incoming SMI snoop request's requesting AIU ID is same as the snooping AIU ID %0d", m_pkt.smi_mpf1_dtr_tgt_id), UVM_NONE);
                end
            end
        end
        num_snoops++;
        case (m_pkt.smi_msg_type) 
            SNP_INV      : num_snp_inv++;
            SNP_CLN_DTR  : num_snp_cln_dtr++;
            SNP_VLD_DTR  : num_snp_vld_dtr++;
            SNP_INV_DTR  : num_snp_inv_dtr++;
            SNP_CLN_DTW  : num_snp_cln_dtw++;
            SNP_INV_DTW  : num_snp_inv_dtw++;
            SNP_NITC     : num_snp_nitc++;
            SNP_NITCCI   : num_snp_nitcci++;
            SNP_NITCMI   : num_snp_nitcmi++;
            SNP_NOSDINT  : num_snp_nosdint++;
            SNP_INV_STSH : num_snp_inv_stsh++;
            SNP_UNQ_STSH : num_snp_unq_stsh++;
            SNP_STSH_SH  : num_snp_stsh_sh++;
            SNP_STSH_UNQ : num_snp_stsh_unq++;
            SNP_DVM_MSG  : num_snp_dvm_msg++;
            default : begin 
              `uvm_warning("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("Did't match any snoop txn cmdtype=%0s",m_pkt.smi_msg_type))
            end 
        endcase 

		if(m_pkt.smi_msg_type == SNP_DVM_MSG) begin
            if(m_pkt.smi_mpf3_dvmop_portion == 0) begin: _smi_snpreq1_
                tb_txn_count++;
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d Received below SMI 1st %0s %0s SNP_REQ packet at IOAIU SCB: %0s", tb_txn_count, m_pkt.smi_addr[13:11] == 'b100 ? "DVMSYNC" : "DVM", m_pkt.smi_addr[4] ? "Two-part" : "One-part", m_pkt.convert2string()), UVM_LOW)
                dvmSnpReqMsgId_q.push_back(m_pkt.smi_msg_id);
                m_txn = new(,m_req_aiu_id);
                m_txn.tb_txnid = tb_txn_count;
                
                m_tmp_qA = {};
                //#Check.IOAIU.DVMSnooper.nonSyncDVM
                //#Check.IOAIU.DVMSnooper.SyncDVM
                m_tmp_qA = m_ott_q.find_index with ( item.matchSMISnpReq(m_pkt) );
                if(m_tmp_qA.size() > 0) begin
                    `uvm_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR",$sformatf("Found match for incoming 1st DVM SNPreq:%0s",m_pkt.convert2string()));
                end else begin
                    m_txn.setup_dvm_snp_req(m_pkt);
                    m_ott_q.push_back(m_txn);
                    ->e_queue_add;
                end
            end: _smi_snpreq1_
            else begin: _smi_snpreq2_
                m_tmp_qA = {};
                //#Check.IOAIU.DVMSnooper.nonSyncDVM
                //#Check.IOAIU.DVMSnooper.SyncDVM
                m_tmp_qA = m_ott_q.find_index with ( item.matchSMISnpReq(m_pkt) );
                if(m_tmp_qA.size() == 0) begin
                  if(!$test$plusargs("inject_smi_uncorr_error"))
                    `uvm_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR",$sformatf("Did not find match for incoming 2nd DVM SNPreq:%0s",m_pkt.convert2string()));
                end else begin
                    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d Received below SMI 2nd %0s SNP_REQ packet at IOAIU DVM_SNP SCB: %0s", m_ott_q[m_tmp_qA[0]].tb_txnid, m_ott_q[m_tmp_qA[0]].txn_type ,m_pkt.convert2string()), UVM_LOW)
                    $cast(m_txn,m_ott_q[m_tmp_qA[0]]);
                    //#Check.IOAIU.AXI.CONC.DvmFlow
                    m_txn.setup_dvm_snp_req(m_pkt);
                    end
            end: _smi_snpreq2_	        
            //return;
		end
		else begin
            tb_txn_count++;
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received SMI SNP_REQ packet at IOAIU SCB: %0s", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)
            check_address_core_id(m_pkt.smi_addr);
            m_txn = new(,m_req_aiu_id);
            m_txn.setup_snp_req(m_pkt); 
            m_txn.tb_txnid = tb_txn_count;
            m_txn.core_id = core_id;
            m_ott_q.push_back(m_txn);
            ->e_queue_add;
        end 
        
        m_tmp_qCov = {};
        m_tmp_qCov = m_ott_q.find_index with (((item.isSMIUPDReqSent) ? item.m_upd_req_pkt.smi_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)] === m_pkt.smi_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)] : 0)&&
                                            item.isSMIUPDReqSent === 1 &&
                                            item.isUpdate === 1
                            );
   
        // #Check.AIU.NoMoreIncomingSnoopsThanNumberOfSTTEntries
        <% if (!(sftype === "UNDEFINED")) { %> 
            m_tmp_qA = {};
            m_tmp_qA = m_ott_q.find_index with (item.isSnoop          === 1 &&
                                                item.isSMISNPReqRecd  === 1 &&
                                                item.isSMISNPRespSent === 0 &&
                                                item.isDVM            === 0);
        
            if (m_tmp_qA.size() > <%=obj.nSttCtrlEntries%>) begin
                print_queues();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("AIU received more snoops than number of STT entries (Snoops Received: %0d STT Entries: %0d", m_tmp_qA.size(), <%=obj.nSttCtrlEntries%>), UVM_NONE);
            end                                   
        <%}%>
    <%}%>

    // Verify that the SCB is in the expected state, see CONC-10924
    // Test should only be on ATTACHED but many fsys legacy files unduly set the the FSM in CONNECT as an equivalent state
    // Should be corrected in all files ideally but would be rather intrusive, due to multiport configs etc. TODO
    // Only core 0 should be considered as it's the AIU reference in multiport configs
	if ((!m_sysco_fsm_state inside {DETACH, ATTACHED})) begin 
    	`uvm_error("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received unexpected above snoop request when sysco_fsm_state:%0s",  tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_sysco_fsm_state.name()))
    end

endfunction : process_snp_req

//----------------------------------------------------------------------- 
// SMI State Reply Request Packet
//----------------------------------------------------------------------- 

function void ioaiu_scoreboard::process_str_req(smi_seq_item m_pkt);
        int m_tmp_qA[$],m_tmp_qB[$];
        int m_tmp_qA_err[$];
        int tmp_q_target_id_err[$];
        eMsgCMD cmd_type;
        string str = "";
        int     find_q_targ_id_err[$];
        int     find_q_targ_id_err_1[$];
       <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
       `ifdef VCS
        int     calcStrResult_vcs;
       `endif // `ifdef VCS ... `else ...
       <% } %>

        find_q_targ_id_err = {};
        find_q_targ_id_err_1 = {};
        m_tmp_qA = {};
        m_tmp_qA_err = {};
        tmp_q_target_id_err = {};
        m_tmp_qA = m_ott_q.find_index with ((item.isRead || item.isWrite || item.isUpdate || item.isIoCacheEvict) &&				     
                                            ((item.isSMICMDReqSent &&
                                              !item.isSMISTRReqNotNeeded &&
				              !item.isSMISTRReqRecd &&
                                              !item.isSMISTRRespSent &&
                                              (item.m_cmd_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id) &&
                                              (item.m_cmd_req_pkt.smi_unq_identifier == m_pkt.smi_rsp_unq_identifier)) ||
                                             (item.is2ndSMICMDReqSent &&
                                              item.is2ndSMISTRReqNeeded &&
				              !item.is2ndSMISTRReqRecd &&
                                              !item.is2ndSMISTRRespSent &&
                                              (item.m_2nd_cmd_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id) &&
                                              (item.m_2nd_cmd_req_pkt.smi_unq_identifier === m_pkt.smi_rsp_unq_identifier))
                                           ));
        if (m_ott_q_dtr_cmstatus_err.size() != 0) begin 
        m_tmp_qA_err = m_ott_q_dtr_cmstatus_err.find_index with ((item.isRead                                    === 1 ||
                                             item.isWrite                                   === 1 ||
                                             item.isUpdate                                  === 1 ||
                                             item.isIoCacheEvict                            === 1					     
                                            ) &&
//					    item.isSMISTRRespSent                           === 0 &&
                                            item.isStrRspEligibleForIssue()                 === 0 &&
                                            ((item.isSMICMDReqSent                            === 1 &&
                                              item.isSMISTRReqNotNeeded                       === 0 &&
//		   item.matchTransaction(m_pkt) &&
					      item.isSMISTRRespSent == 0 &&
                                              item.m_cmd_req_pkt.smi_unq_identifier === m_pkt.smi_rsp_unq_identifier) ||
                                             (item.is2ndSMICMDReqSent                   === 1 &&
                                              item.is2ndSMISTRReqNeeded                 === 1 &&
                                              item.is2ndSMISTRRespSent                  === 0 &&
                                              item.m_2nd_cmd_req_pkt.smi_unq_identifier === m_pkt.smi_rsp_unq_identifier))
//                                            item.m_cmd_req_pkt.cmd_req.req_aiu_trans_id === m_pkt.str_req.req_aiu_trans_id &&
//                                            item.m_cmd_req_pkt.cmd_req.req_aiu_id       === m_pkt.str_req.req_aiu_id
                                           );
        end
        if ($test$plusargs("wrong_strreq_target_id")) begin
          tmp_q_target_id_err = m_ott_q.find_index with ((item.isRead                                    === 1 ||
                                             item.isWrite                                   === 1 ||
                                             item.isUpdate                                  === 1 ||
                                             item.isIoCacheEvict                            === 1					     
                                            ) &&
//					    item.isSMISTRRespSent                           === 0 &&
                                            item.isStrRspEligibleForIssue()                 === 0 &&
                                            item.isSMICMDReqSent                            === 1 &&
                                            item.isSMISTRReqNotNeeded                       === 0 &&
//		   item.matchTransaction(m_pkt) &&
					    item.isSMISTRRespSent == 0 &&
                                            item.m_cmd_req_pkt.smi_conc_msg_class === m_pkt.smi_conc_rmsg_class &&
                                            item.m_cmd_req_pkt.smi_msg_id === m_pkt.smi_rmsg_id
//                                            item.m_cmd_req_pkt.cmd_req.req_aiu_trans_id === m_pkt.str_req.req_aiu_trans_id &&
//                                            item.m_cmd_req_pkt.cmd_req.req_aiu_id       === m_pkt.str_req.req_aiu_id
                                           );
        end
//	    `uvm_info("DCDEBUG", $sformatf("STRreq %s",m_pkt.convert2string()), UVM_MEDIUM)
        if (m_tmp_qA.size === 0 && tmp_q_target_id_err.size() == 0) begin
            if (m_tmp_qA_err.size() == 1) begin
              `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("STRreq pkt hit in m_ott_q_dtr_cmstatus_err queue, STRreq: %s",m_pkt.convert2string()),UVM_MEDIUM)
              m_ott_q_dtr_cmstatus_err[m_tmp_qA_err[0]].isSMISTRReqRecd = 1; //to make sure we do not receive duplicate str_req
              return;
            end
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_pkt.convert2string()), UVM_NONE);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Incoming STR request does not match any outstanding requests(req smi_msg_id: 0x%0x)", m_pkt.smi_msg_id), UVM_NONE);//DCTODO DATACHK
        end else if (m_tmp_qA.size() > 1) begin 
            foreach (m_tmp_qA[i]) begin
            end
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Incoming STR request matches multiple outstanding requests:%0d", m_tmp_qA.size()));
        end else begin
            bit is_dtw_data;
            ace_command_types_enum_t m_ace_cmd_type_tmp;
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received STR_REQ packet at IOAIU SCB: %0s",m_ott_q[m_tmp_qA[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)

            if ($test$plusargs("wrong_strreq_target_id")) begin
              if (m_pkt.smi_targ_ncore_unit_id !== <%= obj.FUnitId%>) begin
                m_tmp_qA = tmp_q_target_id_err;
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Target id error injected in STRreq targ_id = %0h, src_id = %0h, smi_msg_id = %0h",m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id),UVM_NONE)
                find_q_targ_id_err_1 = str_req_msg_id_targ_id_err.find_index with (item.src_id == m_pkt.smi_src_ncore_unit_id &&
                                                                                   item.msg_id == m_pkt.smi_msg_id);
                if (find_q_targ_id_err_1.size() == 1) begin
                  str_req_msg_id_targ_id_err[find_q_targ_id_err_1[0]] = '{m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id};
                end else if (find_q_targ_id_err_1.size() == 0) begin
                  str_req_msg_id_targ_id_err.push_back( '{m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id} );
                end
              end else begin
                find_q_targ_id_err = str_req_msg_id_targ_id_err.find_index with (item.src_id == m_pkt.smi_src_ncore_unit_id &&
                                                                                 item.msg_id == m_pkt.smi_msg_id
                                                                                );

                if (find_q_targ_id_err.size()== 1 && m_pkt.smi_targ_ncore_unit_id == <%=obj.FUnitId%>) begin
                  str_req_msg_id_targ_id_err.delete(find_q_targ_id_err[0]);
                end
              end
            end

		<%if(obj.COVER_ON) { %> 
         	`ifndef FSYS_COVER_ON
         	//#Cover.IOAIU.STRreq.CMStatusError.Addr.Data
		if(m_pkt.smi_cmstatus_err === 1)
         	cov.collect_str_req_cmstatus_err(m_ott_q[m_tmp_qA[0]], m_pkt,core_id);
         	`endif 
          	<%}%>

            m_ott_q[m_tmp_qA[0]].add_str_req(m_pkt);
            
           // if (owo && m_ott_q[m_tmp_qA[0]].isWrite && m_ott_q[m_tmp_qA[0]].isCoherent && !m_ott_q[m_tmp_qA[0]].is2ndSMISTRReqRecd) begin 
           //     update_owo_wr_state_on_clnunq_strreq(m_tmp_qA[0]);
           // end

            
            m_ace_cmd_type_tmp = m_ott_q[m_tmp_qA[0]].m_ace_cmd_type;
           
           	//Once a multiline write transaction get a STRreq.CMStatusAddrErr,  tag all the multilines with hasFatlErr 
           	//This does not apply to read transactions, for reads only the transaction with the STRreq.cmstatus.err will have DECERR asserted on those respective beats only.
            if((m_ott_q[m_tmp_qA[0]].isSMISTRReqAddrErr|| m_ott_q[m_tmp_qA[0]].isSMISTRReqDataErr) && m_ott_q[m_tmp_qA[0]].isWrite && m_ott_q[m_tmp_qA[0]].isMultiAccess) begin
	       		int m_tmp_qB[$];
               	int multiline_tracking_id_tmp = m_ott_q[m_tmp_qA[0]].m_multiline_tracking_id;

               	m_tmp_qB = m_ott_q.find_index with( 
               										item.isMultiAccess           === 1 &&
                                                   	item.m_multiline_tracking_id === multiline_tracking_id_tmp
                                                  );

	       		foreach(m_tmp_qB[i]) begin
	          		m_ott_q[m_tmp_qB[i]].hasFatlErr = 1;
                                if(m_pkt.smi_cmstatus_err_payload === 7'b000_0100)begin
	          		//Save only the 1st occurs of error. 
	          		if (m_ott_q[m_tmp_qB[i]].t_strreq_cmstatus_err == 0.00)
				        m_ott_q[m_tmp_qB[i]].t_strreq_cmstatus_err = m_pkt.t_smi_ndp_valid;
                                        //#Check.IOAIU.STRreq.CMStatusErr.NativeInterfaceResp
					foreach (m_ott_q[m_tmp_qB[i]].m_axi_resp_expected[j]) begin
						m_ott_q[m_tmp_qB[i]].m_axi_resp_expected[j] = DECERR;
                                        end
				end
				else if(m_pkt.smi_cmstatus_err_payload === 7'b000_0011)begin
                                         foreach (m_ott_q[m_tmp_qB[i]].m_axi_resp_expected[j]) begin
                                         if(m_ott_q[m_tmp_qB[i]].m_axi_resp_expected[0] != DECERR) begin 
					 m_ott_q[m_tmp_qB[i]].m_axi_resp_expected[j] = SLVERR;
                                         end
					 end
				end
			end
 	    	end
	
<%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %> 
            // For IO cache miss and allocate for a write, the SMI side will act like a RDUNQ
            if ((m_ott_q[m_tmp_qA[0]].is_ccp_hit === 0 &&
                 m_ott_q[m_tmp_qA[0]].m_iocache_allocate === 1 ) ||
                (m_ott_q[m_tmp_qA[0]].is_ccp_hit === 1 &&
                 m_ott_q[m_tmp_qA[0]].m_ccp_ctrl_pkt.currstate !== <%=obj.BlockId + '_ccp_agent_pkg'%>::UD) 
            ) begin
                if (m_ott_q[m_tmp_qA[0]].isWrite === 1) begin
                    if (m_ott_q[m_tmp_qA[0]].isPartialWrite === 0) begin
                        m_ott_q[m_tmp_qA[0]].m_ace_cmd_type_io_cache = CLNUNQ;
                        m_ace_cmd_type_tmp                           = m_ott_q[m_tmp_qA[0]].m_ace_cmd_type_io_cache;
                    end else begin
                        m_ott_q[m_tmp_qA[0]].m_ace_cmd_type_io_cache = RDUNQ;
                        m_ace_cmd_type_tmp                           = m_ott_q[m_tmp_qA[0]].m_ace_cmd_type_io_cache;
                    end
                end
            end

<% } %>
               <% if(obj.testBench == 'io_aiu' || obj.testBench == 'fsys') { %>
               `ifndef VCS
                 if(m_ott_q[m_tmp_qA[0]].calcStrResult()[0] != m_ott_q[m_tmp_qA[0]].m_str_req_pkt.smi_cmstatus_st) begin
               `else
                calcStrResult_vcs=m_ott_q[m_tmp_qA[0]].calcStrResult();
                 if(calcStrResult_vcs[0] != m_ott_q[m_tmp_qA[0]].m_str_req_pkt.smi_cmstatus_st) begin
                `endif // `ifndef VCS ... `else ... 
               <% } else {%>
                 if(m_ott_q[m_tmp_qA[0]].calcStrResult()[0] != m_ott_q[m_tmp_qA[0]].m_str_req_pkt.smi_cmstatus_st) begin
               <% } %>
                    $cast(cmd_type,m_ott_q[m_tmp_qA[0]].m_cmd_req_pkt.smi_msg_type);
        end
            // Checking to see if we have received all DTR requests and there is no mismatch

            if (!m_ott_q[m_tmp_qA[0]].isDVM) begin
                if (m_ott_q[m_tmp_qA[0]].m_dtr_req_pkt !== null) begin
                    
                        m_ott_q[m_tmp_qA[0]].isSMIAllDTRReqRecd = 1;

                    if ((m_ott_q[m_tmp_qA[0]].m_dtr_rsp_pkt !== null) /*&& (m_ott_q[m_tmp_qA[0]].m_str_req_pkt.smi_cmstatus_st > 0)*/) begin
                        m_ott_q[m_tmp_qA[0]].isSMIAllDTRRespSent = 1;
                    end
                end

                // If no data is going to be received, setting DTR packets as such
                if (!m_ott_q[m_tmp_qA[0]].isSMIDTRReqNeeded) begin
                    m_ott_q[m_tmp_qA[0]].isSMIAllDTRReqRecd = 1;
                    m_ott_q[m_tmp_qA[0]].isSMIAllDTRRespSent = 1;
                end
	   
            end // if (!m_ott_q[m_tmp_qA[0]].isDVM)
        end   
endfunction : process_str_req



function void ioaiu_scoreboard::process_cmp_rsp(smi_seq_item m_pkt);
        int m_tmp_qA[$];
        int m_tmp_q_cmdreq[$];
		int index;
        m_tmp_qA = {};
        m_tmp_qA = m_ott_q.find_index with (item.isRead &&
					    item.m_ace_cmd_type == DVMMSG &&
                                            item.isSMIDTWReqSent &&
                                            (item.m_cmd_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id) &&
					    !item.isSMISTRRespSent && !item.isSMICMPRespRecd );
	uvm_report_info("DCDEBUG",$sformatf("Got CMPResp:%s",m_pkt.convert2string()),UVM_HIGH);
	if(m_tmp_qA.size() == 0) begin
	   uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Cannot find match for CMP_RSP!"),UVM_NONE);
	   uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Cannot find match for CMP_RSP!"));
	end
	else if(m_tmp_qA.size() > 1) begin
	   uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("find unexpected multiple match for CMP_RSP! Matched Ott id : #%0d and #%0d. CmpRsp Pkt: %s", m_tmp_qA[0], m_tmp_qA[1], m_pkt.convert2string()),UVM_NONE);
	   uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Cannot find match for CMP_RSP!"));
	end
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received CMP_RSP packet at IOAIU SCB: %0s",m_ott_q[m_tmp_qA[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)

	<%if(obj.COVER_ON) { %> 
         `ifndef FSYS_COVER_ON
	<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
	if(m_pkt.smi_cmstatus_err === 1)
        cov.collect_cmp_cmstatus_err(m_ott_q[m_tmp_qA[0]],m_pkt,core_id); 
	<%}%>
        `endif 
	<%}%>
    
        m_ott_q[m_tmp_qA[0]].add_cmp_resp(m_pkt);
	delete_ott_entry(m_tmp_qA[0],CmpRsp);
endfunction // process_cmp_rsp
	
//DCTODO DATACHK

function void ioaiu_scoreboard::process_ccmd_rsp(smi_seq_item m_pkt);
    int m_tmp_qA[$];
    int m_tmp_q_cmdreq[$];
	int index;
    m_tmp_q_cmdreq = {};

    m_tmp_q_cmdreq = m_ott_q.find_index with (( item.isSMICMDReqSent          === 1 &&
                                                item.isSMICMDRespRecd         === 0 &&
                                                item.isSMISTRRespSent         === 0 &&
                                                item.m_cmd_req_pkt.smi_msg_id === m_pkt.smi_rmsg_id) || 
                                                ( item.is2ndSMICMDReqNeeded     === 1 &&
                                                item.is2ndSMICMDReqSent       === 1 &&
                                                item.is2ndSMICMDRespRecd      === 0 &&
                                                item.isSMICMDRespRecd         === 1 &&
                                                item.m_2nd_cmd_req_pkt.smi_msg_id === m_pkt.smi_rmsg_id));
    if (m_tmp_q_cmdreq.size() == 0) begin
        if (!$test$plusargs("inject_smi_uncorr_error")) begin
    	`uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("Received SMI CMD_RSP packet at IOAIU SCB: %0s", m_pkt.convert2string()), UVM_LOW)
        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Cannot find any CMDReq packets that match the above SMI slave master CC response packet's smi msg id (NOC->AIU). %s", m_pkt.convert2string()), UVM_NONE);
        end
    end else begin
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received SMI CMD_RSP packet at IOAIU SCB: %0s", m_ott_q[m_tmp_q_cmdreq[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)

        if ($test$plusargs("wrong_cmdrsp_target_id")) begin
            if (m_pkt.smi_targ_ncore_unit_id !== <%= obj.FUnitId%>) begin
                ccmd_rsp_rmsg_id_targ_id_err[m_ott_q[m_tmp_q_cmdreq[0]].m_cmd_req_pkt.smi_msg_id] = m_pkt.smi_rmsg_id;
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Target id error injected in CCMDrsp with smi_rmsg_id = 0x%0x",m_pkt.smi_rmsg_id),UVM_MEDIUM)
            end
        end

        <%if(obj.SCB_UNIT === undefined) { %>
            if (m_ott_q[m_tmp_q_cmdreq[0]].t_sfi_cmd_req >= $time) begin
                m_ott_q[m_tmp_q_cmdreq[0]].print_me();
                m_pkt.print(uvm_default_line_printer);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("CmdRsp sent at the same cycle as CmdReq was received. SMI spec does not allow this"), UVM_NONE);
            end
        <%}%>
        index = m_tmp_q_cmdreq[0];
    end

    if (!((m_ott_q[index].isRead === 1 ||
            m_ott_q[index].isWrite === 1 ||
            m_ott_q[index].isIoCacheEvict === 1 	       
            ) &&
            ((m_ott_q[index].isSMICMDReqSent === 1 &&
            m_ott_q[index].isSMICMDRespRecd === 0) ||
            (m_ott_q[index].is2ndSMICMDReqNeeded && 
            m_ott_q[index].is2ndSMICMDReqSent &&
            !m_ott_q[index].is2ndSMICMDRespRecd))
        )) begin
        m_ott_q[index].print_me();
        if (!$test$plusargs("inject_smi_uncorr_error"))
        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("AIU received CC CMD response without rest of the protocol being complete for OutstTxn#%0d %s",index,m_pkt.convert2string()), UVM_NONE);
    end else begin
        m_ott_q[index].add_cmd_resp(m_pkt);

        // CONC-2292
        if ( m_ott_q[index].isSMISTRRespSent &&
            (m_ott_q[index].is2ndSMICMDReqNeeded ? 1 : m_ott_q[index].is2ndSMISTRRespSent) &&
            (m_ott_q[index].isSMIDTRReqNeeded ? m_ott_q[index].isSMIAllDTRRespSent:1) &&
            (m_ott_q[index].isFillReqd ? m_ott_q[index].isFillDataRcvd == 1 :1) &&
            (m_ott_q[index].isMultiAccess ? m_ott_q[index].multiline_ready_to_delete : 1) &&
            (m_ott_q[index].isRead ? m_ott_q[index].isACEReadDataSent == 1 : 1) && 
            (m_ott_q[index].isWrite ? m_ott_q[index].isACEWriteRespSent == 1 : 1) 
        ) begin
            delete_ott_entry(index, CmdRsp);
        end else begin
            if (m_ott_q[index].isMultiAccess && !m_ott_q[index].isSMICMDRespErr && !m_ott_q[index].multiline_ready_to_delete) begin
                if (m_ott_q[index].isSMISTRRespSent && 
                    (m_ott_q[index].isSMIDTRReqNeeded ? m_ott_q[index].isSMIAllDTRRespSent:1) 
                ) begin
                    m_ott_q[index].multiline_ready_to_delete = 1;
                end
            end
        end
    end
endfunction : process_ccmd_rsp

//DCTODO DATACHK

function void ioaiu_scoreboard::process_nccmd_rsp(smi_seq_item m_pkt);
    int m_tmp_qA[$];
    int m_tmp_q_cmdreq[$];
    int index;

    m_tmp_q_cmdreq = {};
    m_tmp_q_cmdreq = m_ott_q.find_index with (( item.isSMICMDReqSent         === 1 &&
                                                item.isSMICMDRespRecd         === 0 &&
						                        item.isSMISTRRespSent         === 0 &&
                                                item.m_cmd_req_pkt.smi_msg_id === m_pkt.smi_rmsg_id) || 
                                              ( item.is2ndSMICMDReqNeeded === 1 &&
                                                item.is2ndSMICMDReqSent   === 1 &&
                                                item.is2ndSMICMDRespRecd  === 0 &&
                                                item.isSMICMDRespRecd     === 1 &&
                                                item.m_2nd_cmd_req_pkt.smi_msg_id === m_pkt.smi_rmsg_id
                                                ));
    if (m_tmp_q_cmdreq.size() == 0) begin
        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Cannot find any CMDReq packets that match the above SMI slave master NC response packet's smi_msg_id %s",m_pkt.convert2string()), UVM_NONE);
	end else begin
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received NCCMD_RSP packet at IOAIU SCB: %0s",m_ott_q[m_tmp_q_cmdreq[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)

        if ($test$plusargs("wrong_cmdrsp_target_id")) begin
            if (m_pkt.smi_targ_ncore_unit_id !== <%= obj.FUnitId%>) begin
                nccmd_rsp_rmsg_id_targ_id_err[m_ott_q[m_tmp_q_cmdreq[0]].m_cmd_req_pkt.smi_msg_id] = m_pkt.smi_rmsg_id;
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Target id error injected in NCCMDrsp with smi_rmsg_id = 0x%0x",m_pkt.smi_rmsg_id),UVM_MEDIUM)
            end
        end

        if (m_ott_q[m_tmp_q_cmdreq[0]].t_sfi_cmd_req >= $time) begin
            m_ott_q[m_tmp_q_cmdreq[0]].print_me();
            m_pkt.print(uvm_default_line_printer);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("CmdRsp sent at the same cycle as CmdReq was received. SMI spec does not allow this"), UVM_NONE);
        end
	    index = m_tmp_q_cmdreq[0];
	end
    
        if (!((m_ott_q[index].isRead === 1 ||
                m_ott_q[index].isWrite === 1 ||
                m_ott_q[index].isUpdate === 1 ||
                m_ott_q[index].isIoCacheEvict === 1
               ) &&
               ((m_ott_q[index].isSMICMDReqSent === 1 &&
                 m_ott_q[index].isSMICMDRespRecd === 0) || 
                (m_ott_q[index].is2ndSMICMDReqNeeded && 
                 m_ott_q[index].is2ndSMICMDReqSent &&
                 !m_ott_q[index].is2ndSMICMDRespRecd))
          )) begin
            m_ott_q[index].print_me();
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("AIU received NC CMD response without rest of the protocol being complete for OutstTxn#%0d %s",index,m_pkt.convert2string()), UVM_NONE);
        end      
        else begin
            m_ott_q[index].add_cmd_resp(m_pkt);

            // CONC-2292
            if ( m_ott_q[index].isSMISTRRespSent &&
                (m_ott_q[index].isSMIDTRReqNeeded ? m_ott_q[index].isSMIAllDTRRespSent:1) &&
                (m_ott_q[index].isFillReqd ? m_ott_q[index].isFillDataRcvd == 1 :1) &&
                (m_ott_q[index].isMultiAccess ? m_ott_q[index].multiline_ready_to_delete : 1) &&
                (m_ott_q[index].isRead ? m_ott_q[index].isACEReadDataSent == 1 : 1) && 
                (m_ott_q[index].isWrite ? m_ott_q[index].isACEWriteRespSent == 1 : 1) 
            ) begin
                delete_ott_entry(index, CmdRsp);
            end
            else begin
                if (m_ott_q[index].isMultiAccess && !m_ott_q[index].isSMICMDRespErr && !m_ott_q[index].multiline_ready_to_delete) begin
                    if (m_ott_q[index].isSMISTRRespSent && 
                       (m_ott_q[index].isSMIDTRReqNeeded ? m_ott_q[index].isSMIAllDTRRespSent:1) 
                    ) begin
                        m_ott_q[index].multiline_ready_to_delete = 1;
                    end
                end
            end

        end
endfunction : process_nccmd_rsp
    //----------------------------------------------------------------------- 
    // SMI Data Reply Response Packet
    //----------------------------------------------------------------------- 


function void ioaiu_scoreboard::process_dtr_rsp(smi_seq_item m_pkt);
        int m_tmp_qA[$];
        int m_tmp_q_dtrreq[$];
        int find_dtr_rsp_dtr_req_targ_id_err[$];
	int index;
//        uvm_report_info("DCDEBUG", $sformatf("DTR_RSP seen %s", m_pkt.convert2string()), UVM_NONE);

        <% if(obj.testBench == "fsys"  || obj.testBench == "emu") { %>
        if(addr_trans_mgr::check_aiu_is_unconnected(.tgt_unit_id(m_pkt.smi_targ_ncore_unit_id), .src_unit_id(m_pkt.smi_src_ncore_unit_id))) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",
            $sformatf("In DTR_RSP, Connectivity between AIU FUnitID %0d and AIU FUnitID %0d should have been optimized and not existing", m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_src_ncore_unit_id))
        end
        <% } %>

        m_tmp_qA= {};
        find_dtr_rsp_dtr_req_targ_id_err = {};
        m_tmp_qA = m_ott_q.find_index with (((item.isSMISNPDTRReqSent || item.isSMIDTRReqRecd) ? 
                                                ((item.m_dtr_req_pkt.smi_unq_identifier == m_pkt.smi_rsp_unq_identifier) && 
                                                 (item.m_dtr_req_pkt.smi_src_ncore_unit_id  == m_pkt.smi_targ_ncore_unit_id) && 
                                                 (item.m_dtr_req_pkt.smi_targ_ncore_unit_id == m_pkt.smi_src_ncore_unit_id)) : 0) &&
                                             ((item.isSMISNPDTRReqSent && !item.isSMISNPDTRRespRecd && (m_pkt.smi_targ_ncore_unit_id == <%=obj.FUnitId%>)) || //Incoming DTRrsp
					      (item.isSMIDTRReqRecd && !item.isSMIAllDTRRespSent && (m_pkt.smi_src_ncore_unit_id == <%=obj.FUnitId%>)) //Outgoing DTRrsp
                                             ) 
                                           );
	m_tmp_q_dtrreq = {};
        for(int i = 0; i < m_tmp_qA.size(); i++) begin
	    if(m_ott_q[m_tmp_qA[i]].m_dtr_req_pkt !== null) begin
	        if(m_ott_q[m_tmp_qA[i]].m_dtr_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id) begin
	            m_tmp_q_dtrreq.push_back(m_tmp_qA[i]);
	        end
	    end
	end
	    
        if (m_tmp_q_dtrreq.size() == 0) begin
            if($test$plusargs("inject_smi_uncorr_error"))begin
            return;
            end else begin
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Cannot find any DTRReq packets that match the above DTRRsp. Information printed below: %s", m_pkt.convert2string()), UVM_NONE);
	end
        end
	else begin
		if (m_pkt.smi_targ_ncore_unit_id == <%= obj.FUnitId%>)
        	`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received inbound DTR_RSP packet at IOAIU SCB: %0s", m_ott_q[m_tmp_q_dtrreq[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_pkt.convert2string()), UVM_LOW)
        else if (m_pkt.smi_src_ncore_unit_id == <%= obj.FUnitId%>)
        	`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received outbound DTR_RSP packet at IOAIU SCB: %0s",m_ott_q[m_tmp_q_dtrreq[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_pkt.convert2string()), UVM_LOW)

            if ($test$plusargs("wrong_dtrrsp_target_id")) begin
              if (m_pkt.smi_targ_ncore_unit_id !== <%= obj.FUnitId%>) begin
                dtr_rsp_rmsg_id_targ_id_err[m_ott_q[m_tmp_q_dtrreq[0]].m_dtr_req_pkt.smi_msg_id] = m_pkt.smi_rmsg_id;
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Target id error injected in DTRrsp with smi_rmsg_id = 0x%0x",m_pkt.smi_rmsg_id),UVM_MEDIUM)
              end
            end

	    // Commented out for CONC-5700
            if (m_ott_q[m_tmp_q_dtrreq[0]].t_sfi_dtr_req >= m_pkt.t_smi_ndp_valid) begin
                uvm_report_info("IOAIU<%=obj.Id%> SCB", $sformatf("DtrRsp sent at the same cycle as DtrReq was received. SMIspec does not allow this DtrRs:%s",m_pkt.convert2string()), UVM_NONE);      
                m_ott_q[m_tmp_q_dtrreq[0]].print_me();
                m_pkt.print(uvm_default_line_printer);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("DtrRsp sent at the same cycle as DtrReq was received. SMIspec does not allow this"), UVM_NONE);
            end
	    index = m_tmp_q_dtrreq[0];
            if ($test$plusargs("wrong_dtrreq_target_id")) begin
              if (m_ott_q[m_tmp_q_dtrreq[0]].isSMIDTRReqRecd) begin
                find_dtr_rsp_dtr_req_targ_id_err = dtr_req_msg_id_targ_id_err.find_index with(item.src_id == m_pkt.smi_targ_ncore_unit_id &&
                                                                                              item.msg_id == m_pkt.smi_rmsg_id
                                                                                             );
                if (find_dtr_rsp_dtr_req_targ_id_err.size() != 0) begin
                  `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("DTRrsp pkt:", m_pkt.convert2string()), UVM_NONE);
                  `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("AIU not droping DTRrsp with smi_msg_id = 0x%0x for wrong target_id", dtr_req_msg_id_targ_id_err[find_dtr_rsp_dtr_req_targ_id_err[0]].msg_id))
                end
              end
            end
	end

        //DTR Resp for a snoop DTR req sent out
        if (m_ott_q[index].isSnoop === 1) begin
            if (!(m_ott_q[index].isSMISNPReqRecd        === 1 &&
                <%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %> 
                    m_ott_q[index].csr_ccp_lookupen &&
                    m_ott_q[index].isIoCacheTagPipelineSeen &&
                    m_ott_q[index].isIoCacheDataPipelineSeen &&
                    m_ott_q[index].is_ccp_hit     &&
                    //m_ott_q[index].is_write_hit_upgrade === 0     &&
                    //m_ott_q[index].m_io_cache_pkt.cacheState === UD &&
                    m_ott_q[index].isSMISNPDTRReqSent === 1 &&
                    m_ott_q[index].isSMISNPDTRRespRecd === 0
                <%} else {%>
                  m_ott_q[index].isACESnoopReqSent      === 1 &&
                  ((m_ott_q[index].isACESnoopRespRecd   === 1 &&
                    m_ott_q[index].isACESnoopDataNeeded === 1 &&
                    m_ott_q[index].isACESnoopDataRecd   === 1 &&
                    m_ott_q[index].isSMISNPDTRReqSent   === 1 &&
                    m_ott_q[index].isSMISNPDTRRespRecd  === 0) ||
                   (m_ott_q[index].isDVMSync            === 1 &&
                    m_ott_q[index].isACEReadAddressRecd === 1 &&
                    m_ott_q[index].isSMISNPDTRReqNeeded === 1 &&
                    m_ott_q[index].isSMISNPDTRRespRecd  === 0))
                <% } %>
                )) begin
                m_ott_q[index].print_me();
                if(!$test$plusargs("inject_smi_uncorr_error"))
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("AIU received DTR response without rest of the protocol being complete"), UVM_NONE);
            end      
            else begin
                m_ott_q[index].add_snp_dtr_resp(m_pkt);
                if (m_ott_q[index].m_dtr_rsp_pkt != null) begin
                    m_ott_q[index].isSMIAllDTRRespSent = 1;
                end
                if ((m_ott_q[index].isSMISNPRespSent  === 1 &&
                     m_ott_q[index].isDVMSync         === 0) ||
                    (m_ott_q[index].isDVMSync         === 1 &&
                     m_ott_q[index].isSMISNPRespSent  === 1 &&
                     m_ott_q[index].isACEReadDataSent === 1)
                ) begin
                    delete_ott_entry(index, SnpDtrRsp);
                end
            end
        end
        else if (m_ott_q[index].isRead === 1) begin
	    
                 m_ott_q[index].add_dtr_resp(m_pkt);
                if (m_ott_q[index].isSMISTRReqRecd === 1) begin
                    // Checking to see if we have received all DTR responses back
                    if ((m_ott_q[index].m_dtr_rsp_pkt != null)) begin
                        m_ott_q[index].isSMIAllDTRRespSent = 1;
                        m_ott_q[index].isSMIDTRRespSent    = 1;
                        if (m_ott_q[index].isSMISTRRespSent === 1 && m_ott_q[index].isSMICMDRespRecd === 1 ) begin
                            if (m_ott_q[index].isMultiAccess && !m_ott_q[index].multiline_ready_to_delete) begin
                                m_ott_q[index].multiline_ready_to_delete = 1;
                            
                                // Unblocking entries with same AxID
                                <%if(!((obj.fnNativeInterface === "AXI4") || (obj.fnNativeInterface === "AXI5"))) { %> 
                                if (m_ott_q[index].isRead && m_ott_q[index].isMultiLineMaster) begin
                                    unblock_axid_read(m_ott_q[index].m_ace_read_addr_pkt.arid);
                                end
                                else if (m_ott_q[index].isWrite && m_ott_q[index].isMultiLineMaster) begin
                                    unblock_axid_write(m_ott_q[index].m_ace_write_addr_pkt.awid);
                                end

                                <% } %>
                            end
                            else begin

                                if((m_ott_q[index].isRead && m_ott_q[index].isACEReadDataSent === 1) ||
                                    (m_ott_q[index].isWrite && m_ott_q[index].isACEWriteRespSent === 1)) begin 
                                    delete_ott_entry(index, DtrRsp);
                                end
                            end
                        end
                    end
                    
               end // if (m_ott_q[index].isSMISTRReqRecd === 1)
	    else begin
               m_ott_q[index].isSMIAllDTRRespSent = 1;
               m_ott_q[index].isSMIDTRRespSent    = 1;
	    end 
        end

        else if (m_ott_q[index].isWrite === 1) begin
            if (!(m_ott_q[index].isACEWriteAddressRecd    === 1   &&
		  <%if(obj.useCache) { %> 
                 ((m_ott_q[index].csr_ccp_lookupen && m_ott_q[index].csr_ccp_allocen)? ( // if ccp_enable
			        	 (m_ott_q[index].isWriteHit()                    || 
                 		  m_ott_q[index].m_iocache_allocate       === 1) &&
                          m_ott_q[index].isIoCacheTagPipelineSeen === 1
				         ):1) // else ccp_disable
				 	   &&
		  <% } %>			 
                  m_ott_q[index].isSMICMDReqSent          === 1   &&
                  ((m_ott_q[index].m_dtr_req_pkt != null) && (m_ott_q[index].m_dtr_rsp_pkt == null))
//                  m_ott_q[index].m_dtr_req_pkt.size > m_ott_q[index].m_dtr_rsp_pkt.size
                )) begin
                m_ott_q[index].print_me();
                if(!$test$plusargs("inject_smi_uncorr_error")) begin
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("AIU received DTR response without rest of the protocol being complete for OutstTxn #%0d", m_ott_q[index]), UVM_NONE);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("AIU received DTR response without rest of the protocol being complete"), UVM_NONE);
               end
            end      
	    else if(m_ott_q[index].isStash) begin
	        m_ott_q[index].add_snp_dtr_resp(m_pkt);
	    end
            else begin
                m_ott_q[index].add_dtr_resp(m_pkt);
                if (m_ott_q[index].isSMISTRReqRecd === 1) begin
                    // Checking to see if we have received all DTR responses back
                    if (/*(m_ott_q[index].m_str_req_pkt.smi_cmstatus_st > 0) &&*/ (m_ott_q[index].m_dtr_rsp_pkt != null)) begin
                        m_ott_q[index].isSMIAllDTRRespSent = 1;
                        m_ott_q[index].isSMIDTRRespSent    = 1;
                        if (m_ott_q[index].isSMISTRRespSent === 1 && m_ott_q[index].isSMICMDRespRecd === 1 ) begin

                            if (m_ott_q[index].isMultiAccess && !m_ott_q[index].multiline_ready_to_delete) begin
                                m_ott_q[index].multiline_ready_to_delete = 1;
                            end
                            else begin

                                if((m_ott_q[index].isRead && m_ott_q[index].isACEReadDataSent === 1) ||
                                    (m_ott_q[index].isWrite && m_ott_q[index].isACEWriteRespSent === 1)) begin 
                                    delete_ott_entry(index, DtrRsp);
                                end
                            end
                        end
                    end
                    
                end
            end
        end
        else begin
            m_ott_q[index].print_me();
            if(!$test$plusargs("inject_smi_uncorr_error"))begin
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: Cannot have a DTR response for a ACE write request"), UVM_NONE);
            end
        end         
endfunction : process_dtr_rsp

//----------------------------------------------------------------------- 
// SMI Data Write Response Packet
//----------------------------------------------------------------------- 

function void ioaiu_scoreboard::process_dtw_rsp(smi_seq_item m_pkt);
	int m_tmp_q[$];
        int m_tmp_q_dtwreq[$];
        int tmp_q_target_id_err[$];
	int index;
	string s;
        tmp_q_target_id_err = {};
        m_tmp_q_dtwreq = m_ott_q.find_index with (item.isSMIDTWReqSent                            === 1 &&
                                                  item.isSMIDTWRespRecd                           === 0 &&
                                                  item.m_dtw_req_pkt.smi_unq_identifier === m_pkt.smi_rsp_unq_identifier
                                                 );
        if ($test$plusargs("wrong_dtwrsp_target_id")) begin
          tmp_q_target_id_err = m_ott_q.find_index with (item.isSMIDTWReqSent                     === 1 &&
                                                  item.isSMIDTWRespRecd                           === 0 &&
                                                  item.m_dtw_req_pkt.smi_conc_msg_class === m_pkt.smi_conc_rmsg_class &&
                                                  item.m_dtw_req_pkt.smi_msg_id === m_pkt.smi_rmsg_id
                                                 );
        end

        if (m_tmp_q_dtwreq.size() == 0 && tmp_q_target_id_err.size() == 0) begin
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Cannot find any DTWReq packets that match the above SMI slave master response packet's trans id (NOC->AIU). %s", m_pkt.convert2string()), UVM_NONE);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Cannot find any DTWReq packets that match the above SMI slave master response packet's trans id (NOC->AIU). Information printed above"), UVM_NONE);
	end
	    else begin
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received DTW_RSP packet at IOAIU SCB: %0s",m_ott_q[m_tmp_q_dtwreq[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)

            if ($test$plusargs("wrong_dtwrsp_target_id")) begin
              if (m_tmp_q_dtwreq.size() == 0 && m_pkt.smi_targ_ncore_unit_id !== <%= obj.FUnitId%>) begin
                m_tmp_q_dtwreq[0] = tmp_q_target_id_err[0];
                dtw_rsp_rmsg_id_targ_id_err[m_ott_q[m_tmp_q_dtwreq[0]].m_dtw_req_pkt.smi_msg_id] = m_pkt.smi_rmsg_id;
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Target id error injected in DTWrsp with smi_rmsg_id = 0x%0x",m_pkt.smi_rmsg_id),UVM_MEDIUM)
              end
            end

            if (m_ott_q[m_tmp_q_dtwreq[0]].t_sfi_dtw_req >= $time) begin
                m_ott_q[m_tmp_q_dtwreq[0]].print_me();
                m_pkt.print(uvm_default_line_printer);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("DtwRsp sent at the same cycle as DtwReq was received. SMIspec does not allow this"), UVM_NONE);
            end
	    index = m_tmp_q_dtwreq[0];
	end

        if (m_ott_q[index].isSnoop === 1) begin
            if (!(m_ott_q[index].isSMISNPReqRecd === 1 &&
                <%if(obj.useCache) { %> 
                 (m_ott_q[index].csr_ccp_lookupen)? ( // if ccp_enable
                    m_ott_q[index].isIoCacheTagPipelineSeen === 1 &&
                    m_ott_q[index].is_ccp_hit 
				  ):0 // else ccp_disable
				&&
                    (m_ott_q[index].m_ccp_ctrl_pkt.currstate === SD ||
                    m_ott_q[index].m_ccp_ctrl_pkt.currstate === UC ||
                    m_ott_q[index].m_ccp_ctrl_pkt.currstate === UD) &&
                <% } else { %>
                  m_ott_q[index].isACESnoopReqSent === 1 &&
                  m_ott_q[index].isACESnoopRespRecd === 1 &&
                  m_ott_q[index].isACESnoopDataNeeded === 1 &&
                  m_ott_q[index].isACESnoopDataRecd === 1 &&
              <% } %>
                  m_ott_q[index].isSMIDTWReqNeeded === 1 &&
                  m_ott_q[index].isSMIDTWReqSent === 1 &&
                  m_ott_q[index].isSMIDTWRespRecd === 0
              )) begin
                m_ott_q[index].print_me();
	        s = "isSnoop AIU received DTW response without rest of the protocol being complete";
	        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("%s for OutstTxn #%0d",s,index), UVM_NONE);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",s);
            end      
            else begin
                 <% if(obj.COVER_ON) { %>
                `ifndef FSYS_COVER_ON
                cov.collect_dtw_cmstatus_err( m_ott_q[index],m_pkt,core_id);
                `endif
                 <% } %>
                m_ott_q[index].add_dtw_resp(m_pkt);
                if (m_ott_q[index].isSMISNPRespSent === 1) begin
                    delete_ott_entry(index, SnpDtwRsp);
                end
            end
        end
        else if (m_ott_q[index].isWrite === 1) begin
            if (!(m_ott_q[index].isACEWriteAddressRecd === 1 &&
                  m_ott_q[index].isACEWriteDataRecd === 1 &&
                  m_ott_q[index].isSMICMDReqSent === 1 &&
                  m_ott_q[index].isSMISTRReqRecd === 1 &&
                  m_ott_q[index].isSMIDTWReqNeeded === 1 &&
                  m_ott_q[index].isSMIDTWReqSent === 1 &&
                  m_ott_q[index].isSMIDTWRespRecd === 0
                )) begin
                m_ott_q[index].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("isWrite AIU received DTW response without rest of the protocol being complete"), UVM_NONE);
            end      
            else begin
                m_ott_q[index].add_dtw_resp(m_pkt);
                if (owo && m_ott_q[index].isWrite && m_ott_q[index].isCoherent) begin 
                    owo_unblock_snp_on_wb_dtwrsp(index);
                end


                <% if(obj.COVER_ON) { %>
                `ifndef FSYS_COVER_ON
                cov.collect_dtw_cmstatus_err( m_ott_q[index],m_pkt,core_id);
                `endif
                 <% } %>
                
           		//Once a multiline write transaction get a DTWrsp.CMStatusErr,  tag all the multilines with dtwrsp_cmstatus_err
           		//This does not apply to read transactions, for reads only the transaction with the DTWrsp.cmstatus.err will have DECERR/SLVERR asserted on those respective beats only.
                if (m_ott_q[index].dtwrsp_cmstatus_err && m_ott_q[index].isWrite && m_ott_q[index].isMultiAccess)begin
                    int m_tmp_qE[$];
                    int multiline_tracking_id_tmp = m_ott_q[index].m_multiline_tracking_id;
                    
                    m_tmp_qE = {};
                    m_tmp_qE = m_ott_q.find_index with (item.isMultiAccess           === 1 &&
                                                        item.m_multiline_tracking_id === multiline_tracking_id_tmp);
                    //Once DTWrsp.CMStatus error is seen on any part of the multiline txn, it is not required that the remaining parts of the multiline send CMDreqs, since the txn will terminate in a error response
                    for (int i = 0; i < m_tmp_qE.size(); i++) begin
                        m_ott_q[m_tmp_qE[i]].dtwrsp_cmstatus_err = 1;
                        owo_unblock_snp_on_wb_dtwrsp(m_tmp_qE[i]);

	          			if (m_ott_q[m_tmp_qE[i]].t_dtwrsp_cmstatus_err == 0.00)
							m_ott_q[m_tmp_qE[i]].t_dtwrsp_cmstatus_err = m_pkt.t_smi_ndp_valid;

                        if(m_ott_q[index].dtwrsp_cmstatus_add_err == 1 || m_pkt.smi_cmstatus_err_payload === 7'b000_0100) begin
							m_ott_q[m_tmp_qE[i]].dtwrsp_cmstatus_add_err =1;
                                //#Check.IOAIU.DTWrspCMStatusAddrErr.BRespDECERR
                        	m_ott_q[m_tmp_qE[i]].m_axi_resp_expected[0] = DECERR;
                        end
							
						//DECERR always has highest precedence
						//if DECERR is not already predicted, check if there is a SLVERR 
						foreach (m_ott_q[m_tmp_qE[i]].m_axi_resp_expected[j]) begin
							if (m_ott_q[m_tmp_qE[i]].m_axi_resp_expected[j] != DECERR) begin
                                                                //#Check.IOAIU.DTWrspCMStatusDataErr.BRespSLVERR
								if (m_ott_q[index].dtwrsp_cmstatus_slv_err == 1) 
									m_ott_q[m_tmp_qE[i]].m_axi_resp_expected[j] = SLVERR;
							end
						end

						//This is taken care of in the isComplete function. 
                        //if (m_ott_q[m_tmp_qE[i]].isSMICMDReqNeeded && !m_ott_q[m_tmp_qE[i]].isSMICMDReqSent)
                        //   m_ott_q[m_tmp_qE[i]].isSMICMDReqNeeded = 0;
                    end
                end
            end
        end
        else if (m_ott_q[index].isUpdate === 1) begin
            if (!(m_ott_q[index].isACEWriteAddressRecd === 1 &&
                  m_ott_q[index].isACEWriteDataRecd === 1 &&
                  m_ott_q[index].isSMICMDReqSent === 1 &&
                  m_ott_q[index].isSMISTRReqRecd === 1 &&
                  m_ott_q[index].isSMIDTWReqNeeded === 1 &&
                  m_ott_q[index].isSMIDTWReqSent === 1 &&
                  m_ott_q[index].isSMIDTWRespRecd === 0
                )) begin
                m_ott_q[index].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("isUpdate AIU received DTW response without rest of the protocol being complete"), UVM_NONE);
            end
            else begin
                 <% if(obj.COVER_ON) { %>
                `ifndef FSYS_COVER_ON
                cov.collect_dtw_cmstatus_err( m_ott_q[index],m_pkt,core_id);
                `endif
                 <% } %>
                m_ott_q[index].add_dtw_resp(m_pkt);
            end
        end
        else if (m_ott_q[index].isRead === 1) begin 
            if (!(m_ott_q[index].isACEReadAddressRecd === 1 &&
                  m_ott_q[index].isSMICMDReqSent === 1 &&
                  m_ott_q[index].isSMISTRReqRecd === 1 &&
                  ((m_ott_q[index].isSMIDTRReqNeeded) ? m_ott_q[index].isSMIDTRReqRecd === 1 : 1) &&
                  m_ott_q[index].isSMIDTWReqNeeded === 1 &&
                  m_ott_q[index].isSMIDTWReqSent === 1 &&
                  m_ott_q[index].isSMIDTWRespRecd === 0
                )) begin
                m_ott_q[index].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("isRead AIU received DTW response without rest of the protocol being complete"), UVM_NONE);
            end      
            else begin
                m_ott_q[index].add_dtw_resp(m_pkt);

            end
        end      
<%if(obj.useCache) { %> 
        else if (m_ott_q[index].isIoCacheEvict === 1) begin
            if (!(m_ott_q[index].isIoCacheTagPipelineSeen === 1 &&
                  m_ott_q[index].isSMIDTWReqNeeded === 1 &&
                  m_ott_q[index].isSMIDTWReqSent === 1 &&
                  m_ott_q[index].isSMIDTWRespRecd === 0
                )) begin
                m_ott_q[index].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("isIoCacheEvict AIU received DTW response without rest of the protocol being complete"), UVM_NONE);
            end      
            else begin
                m_ott_q[index].add_dtw_resp(m_pkt);
		<% if(obj.COVER_ON) { %>
               	`ifndef FSYS_COVER_ON
                cov.collect_dtw_cmstatus_err( m_ott_q[index],m_pkt,core_id);
                `endif
                <% } %>
                if (m_ott_q[index].isSMIUPDReqNeeded === 0) begin
                    delete_ott_entry(index, DtwRsp);
                end
            end
        end
<% } %>
endfunction : process_dtw_rsp

//----------------------------------------------------------------------- 
// SMI Snoop Response Packet
//----------------------------------------------------------------------- 

// #Check.AIU.SNPRspFields

function void ioaiu_scoreboard::process_snp_rsp(smi_seq_item m_pkt);
        int m_tmp_q[$];
        int m_tmp_q_snpreq[$];
        int m_tmp_dvm_q[$];
        int index;
        int find_snp_rsp_snp_req_targ_id_err[$];

        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Received below SMI SNP_RSP packet at IOAIU SCB: %0s", m_pkt.convert2string()), UVM_LOW)
        <% if(obj.eAc == 1) { %>
	//DVM Snoop Resp Capture logic
        m_tmp_dvm_q= {};
        m_tmp_dvm_q = dvmSnpReqMsgId_q.find_index with (item == m_pkt.smi_rmsg_id);
        //$display("KDB00 m_tmp_dvm_q.size=%0d", m_tmp_dvm_q.size());
        if(m_tmp_dvm_q.size() >= 1 && m_pkt.smi_targ_ncore_unit_id == DVE_FUNIT_IDS[0]) begin
            dvmSnpReqMsgId_q.delete(m_tmp_dvm_q[0]);
            //$display("KDB01 deleting m_tmp_dvm_q[0]=%0p", m_tmp_dvm_q[0]);
            m_tmp_q = {};
            m_tmp_q = m_ott_q.find_index with ( item.matchSMISnpRsp(m_pkt) );
            if(m_tmp_q.size() == 0) begin
                if(($test$plusargs("inject_smi_uncorr_error")))
                return;
                uvm_report_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR",$sformatf("Did not find match for SMISnpRsp pkt: %0s",m_pkt.convert2string()),UVM_NONE,"SnpRspNoMatch");
            end else begin
                //$cast(m_ott_q[m_tmp_q[0]],m_ott_q[m_tmp_q[0]]);
                `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d Received below SMI SNP_RSP packet at IOAIU SCB: %0s", m_ott_q[m_tmp_q[0]].tb_txnid, m_pkt.convert2string()), UVM_LOW)
                <%if(obj.COVER_ON) { %> 
                `ifndef FSYS_COVER_ON
                <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                if(m_pkt.smi_cmstatus_err === 1)begin
                    cov.collect_snp_cmstatus_err(m_ott_q[m_tmp_q[0]],m_pkt,0);
                end
                <% } %>
                `endif 
                <%}%>
                m_ott_q[m_tmp_q[0]].setup_smi_dvm_snp_rsp(m_pkt);
                if(m_ott_q[m_tmp_q[0]].m_ace_snoop_resp_pkt1_act) begin:_pkt0Andpkt1  // case 2 snp req => 2 CRRESP but 1 snp_rsp
                    if(m_ott_q[m_tmp_q[0]].m_ace_snoop_resp_pkt0_act.crresp == '0 && m_ott_q[m_tmp_q[0]].m_ace_snoop_resp_pkt1_act.crresp == '0 &&
                        m_pkt.smi_cmstatus != '0) begin
                        uvm_report_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR",$sformatf("pkt1 DVM SnpRsp cmstatus is wrong. Expect: 0, Real: 'b%b. Received SnpResp: %s", m_pkt.smi_cmstatus, m_pkt.convert2string()),UVM_NONE,"SnpRspCmstatusWrong");
                    end
                    if((m_ott_q[m_tmp_q[0]].m_ace_snoop_resp_pkt0_act.crresp == 4'b0010 || m_ott_q[m_tmp_q[0]].m_ace_snoop_resp_pkt1_act.crresp == 4'b0010) &&
                        m_pkt.smi_cmstatus != 8'b1000_0100) begin
                        uvm_report_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR",$sformatf("pkt1 DVM SnpRsp cmstatus is wrong. Expect: 'b1000_0100, Real: 'b%b. Received SnpResp: %s", m_pkt.smi_cmstatus, m_pkt.convert2string()),UVM_NONE,"SnpRspCmstatusWrong");
                    end
                end:_pkt0Andpkt1 else begin:_only_pkt0  //classic case 1snp req => 1 CRRESP => 1 snp_rsp
                    if(m_ott_q[m_tmp_q[0]].m_ace_snoop_resp_pkt0_act.crresp == '0 &&
                       m_pkt.smi_cmstatus != '0) begin
                       uvm_report_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR",$sformatf("pkt0 DVM SnpRsp cmstatus is wrong. Expect: 0, Real: 'b%b. Received SnpResp: %s", m_pkt.smi_cmstatus, m_pkt.convert2string()),UVM_NONE,"SnpRspCmstatusWrong");
                    end
                    if(m_ott_q[m_tmp_q[0]].m_ace_snoop_resp_pkt0_act.crresp == 4'b0010 &&
                       m_pkt.smi_cmstatus != 8'b1000_0100) begin
                       uvm_report_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR",$sformatf("pkt0 DVM SnpRsp cmstatus is wrong. Expect: 'b1000_0100, Real: 'b%b. Received SnpResp: %s", m_pkt.smi_cmstatus, m_pkt.convert2string()),UVM_NONE,"SnpRspCmstatusWrong");
                    end
                end:_only_pkt0
                delete_ott_entry(m_tmp_q[0],SnpRsp);
                return;
            end
        end
        <% } %>

        // Find corresponding SnpReq for SnpRsp
        find_snp_rsp_snp_req_targ_id_err = {};
        m_tmp_q_snpreq = m_ott_q.find_index with (item.isSMISNPReqRecd                            === 1 &&
                                                  item.isSMISNPRespSent                           === 0 &&
                                                  (!owo || item.isSMISNPRespNeeded) &&
                                                  item.m_snp_req_pkt.smi_msg_id === m_pkt.smi_rmsg_id &&
                                                  item.m_snp_req_pkt.smi_src_ncore_unit_id === m_pkt.smi_targ_ncore_unit_id
                                                 );
        if (m_tmp_q_snpreq.size() == 0) begin
            if(!$test$plusargs("inject_smi_uncorr_error"))  
            	`uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Unexpected SNPrsp seen - %s", m_pkt.convert2string()));
	    end else begin
            if (m_ott_q[m_tmp_q_snpreq[0]].t_sfi_snp_req >= $time) begin
                m_ott_q[m_tmp_q_snpreq[0]].print_me();
                m_pkt.print(uvm_default_line_printer);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SnpRsp sent at the same cycle as SnpReq was received. SMIspec does not allow this"), UVM_NONE);
            end
            index = m_tmp_q_snpreq[0];
              <%if(obj.COVER_ON) { %>
        	 <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
			if (!($test$plusargs("snp_req_err_inj"))) begin
               		cov.collect_crresp_cmstatus(m_ott_q[index].m_ace_snoop_resp_pkt.crresp[1:0], m_pkt.smi_cmstatus[2:1],core_id);
			end
        	<%}%>
            <%}%> 
            if ($test$plusargs("wrong_snpreq_target_id")) begin
                if (m_ott_q[m_tmp_q_snpreq[0]].isSMISNPReqRecd) begin
                    find_snp_rsp_snp_req_targ_id_err = snp_req_msg_id_targ_id_err.find_index with(item.src_id == m_pkt.smi_targ_ncore_unit_id &&
                                                                                                item.msg_id == m_pkt.smi_rmsg_id);
                    if (find_snp_rsp_snp_req_targ_id_err.size() != 0) begin
                        `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("SNPrsp pkt:", m_pkt.convert2string()), UVM_NONE);
                        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("AIU not droping SNPrsp with smi_msg_id = 0x%0x for wrong target_id", snp_req_msg_id_targ_id_err[find_snp_rsp_snp_req_targ_id_err[0]].msg_id))
                    end
                end
            end
	    end

		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received SMI SNP_RSP packet at IOAIU SCB: %0s",  m_ott_q[index].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)
        if (
            <%if(obj.useCache) { %>	    
	            m_ott_q[index].isIoCacheTagPipelineNeeded                  === 1 &&
            <%}%>
	        !(m_ott_q[index].isSnoop                                   === 1 &&
            m_ott_q[index].isSMISNPReqRecd                           === 1 &&
            <%if(obj.useCache) { %>
	            (m_ott_q[index].isIoCacheTagPipelineSeen) ? 1 : m_ott_q[index].isCCPCancelSeen &&
                (m_ott_q[index].isSMIDTWReqNeeded                        === 0 ||
                (m_ott_q[index].isSMIDTWReqNeeded                       === 1 &&
                m_ott_q[index].is_ccp_hit                              === 0 ||
                (m_ott_q[index].is_ccp_hit                             === 1 &&
                 m_ott_q[index].m_ccp_ctrl_pkt.currstate               != UD))) &&
            <%}%>
              //CONC-11808
              //((m_ott_q[index].isSMIDTWReqNeeded                       === 1  &&
              // m_ott_q[index].isSMIDTWRespRecd                        === 1) ||
              // m_ott_q[index].isSMIDTWReqNeeded                        === 0) &&
               m_ott_q[index].isSMISNPRespSent                          === 0
              )) 
            begin
                m_ott_q[index].print_me(0,1);
                if(!$test$plusargs("inject_smi_uncorr_error")) begin
                  uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("AIU sent SNP response without rest of the protocol being complete for OutstTxn #%0d %s", index, m_pkt.convert2string()), UVM_NONE);
                end 
            end      
        else begin
            // #Check.AIU.DataCorruption.SNPrspError.FromDTWrsp
            m_ott_q[index].add_snp_resp(m_pkt);
            //#Check.IOAIU.ACE.Snoop.ErrType
            //#Check.IOAIU.ACE.SnpClnDtr 
            //#Check.IOAIU.ACE.SnpInvDtr
            //#Check.IOAIU.ACE.SnpNitcCI
            //#Check.IOAIU.ACE.SnpNitc
            //#Check.IOAIU.ACE.SnpNitcMI
            //#Check.IOAIU.ACE.SnpNoSDInt
            //#Check.IOAIU.ACE.SnpVldDtr

            <%if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5") { %>
                m_ott_q[index].checkSnpResp($sformatf("OutstTxn #%0d",index));
            <%}%>
            <%if(obj.useCache){%> 
                if(m_ott_q[index].isSnpHitEvict) begin
                    m_tmp_q = {};
                    m_tmp_q = m_ott_q.find_index() with (
                                                        item.ccp_addr == m_ott_q[index].ccp_addr         &&
                                                        item.ccp_index == m_ott_q[index].ccp_index       &&
                                                        item.m_security == m_ott_q[index].m_security &&
                                                        item.isIoCacheTagPipelineSeen == 1  &&
                                                        ( (item.isIoCacheEvict ==1) &&
                                                          ((item.isSMIUPDReqNeeded==1 ? item.isSMIUPDRespRecd == 0 : 0)  || 
                                                          (item.isSMIDTWReqNeeded==1 ? item.isSMIDTWRespRecd == 0 : 0))
                                                        ) 
                                                    );
                    if(m_tmp_q.size()>0) begin
                        if(m_ott_q[m_tmp_q[0]].t_creation > m_ott_q[index].t_creation) begin
                            m_ott_q[m_tmp_q[0]].print_me();
                            m_ott_q[index].print_me();
                            `uvm_error("<%=obj.strRtlNamePrefix%> SCB","IOAIU sent snoop response before evict is complete")
                        end
                    end
                end
                
            <%}%>
            // #Check.AIU.SnoopResponseMessages
            // #Check.IOAIU.ProxyCache.SnpClnDtr
            // #Check.IOAIU.ProxyCache.SnpInvDtr
            // #Check.IOAIU.ProxyCache.SnpNitcCI
            // #Check.IOAIU.ProxyCache.SnpNitc
            // #Check.IOAIU.ProxyCache.SnpNitcMI
            // #Check.IOAIU.ProxyCache.SnpNoSDInt
            // #Check.IOAIU.ProxyCache.SnpVldDtr
            <%if(obj.useCache) { %> 
                check_sfi_snoop_resp(index);
            <%}%>

            // Delete Ott_q entry if complete
            <%if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface == "ACE5") { %>
                if(m_ott_q[index].isComplete) begin
                    delete_ott_entry(index, SnpRsp);
// CONC-10816
//                end else begin
//                    m_ott_q[index].print_me(0,1);
//                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("AIU sent SNP response without rest of the protocol being complete for OutstTxn #%0d %s", index, m_pkt.convert2string()), UVM_NONE);
                end
            <%}else{%> 
                if (!(((m_ott_q[index].isACESnoopDataNeeded === 1 &&
                        m_ott_q[index].isACESnoopDataRecd   === 0) ||
                    ((m_ott_q[index].isSMIDTWReqNeeded    === 1 &&
                    m_ott_q[index].isSMIDTWRespRecd     === 0) ||
                    (m_ott_q[index].isSMISNPDTRReqNeeded === 1 &&
                    m_ott_q[index].isSMISNPDTRRespRecd  === 0))) ||
                    (m_ott_q[index].isDVMSync             === 1 &&
                    (m_ott_q[index].isSMIAllDTRRespSent  === 0 ||
                    m_ott_q[index].isACEReadDataSent    === 0)) 
                    <%if(obj.useCache) { %> ||
                        (m_ott_q[index].isSMISNPDTRReqNeeded === 1 &&
                        m_ott_q[index].isSMISNPDTRRespRecd  === 0) ||
                        (m_ott_q[index].is_ccp_hit === 1 &&
                        m_ott_q[index].isIoCacheDataPipelineSeen === 0 &&
                        m_ott_q[index].m_ccp_ctrl_pkt.currstate === UD &&
                        m_ott_q[index].m_snp_req_pkt.smi_msg_type !== eSnpInv &&
                        m_ott_q[index].m_snp_req_pkt.smi_msg_type !== eSnpInvStsh)
                    <%}%>)) 
                begin
                    delete_ott_entry(index, SnpRsp);
                end
            <%}%>
        end
endfunction : process_snp_rsp

//----------------------------------------------------------------------- 
// SMI State Reply Response Packet
//----------------------------------------------------------------------- 

// #Check.AIU.STRRspFields

function void ioaiu_scoreboard::process_str_rsp(smi_seq_item m_pkt);
        bit is_dtw_data;
        bit is_dtw_none;
	    int index;
        int m_tmp_qA[$];

	    int m_tmp_q[$];
        int m_tmp_q_strreq[$];
        smi_msg_id_bit_t find_str_rsp_dtw_rsp_targ_id_err[$];
        smi_msg_id_bit_t find_str_rsp_dtr_rsp_targ_id_err[$];
        smi_msg_id_bit_t find_str_rsp_ccmd_rsp_targ_id_err[$];
        smi_msg_id_bit_t find_str_rsp_nccmd_rsp_targ_id_err[$];
        int find_str_rsp_str_req_targ_id_err[$];
        smi_msg_id_bit_t find_str_rsp_str_req_cmstatus_err[$];
        smi_msg_id_bit_t find_str_rsp_ccmd_rsp_cmstatus_err[$];
        smi_msg_id_bit_t find_str_rsp_nccmd_rsp_cmstatus_err[$];
        smi_msg_id_bit_t find_str_rsp_dtr_rsp_cmstatus_err[$];

        find_str_rsp_dtw_rsp_targ_id_err = {};
        find_str_rsp_dtr_rsp_targ_id_err = {};
        find_str_rsp_ccmd_rsp_targ_id_err = {};
        find_str_rsp_nccmd_rsp_targ_id_err = {};
        find_str_rsp_str_req_targ_id_err = {};
        find_str_rsp_str_req_cmstatus_err = {};
        find_str_rsp_ccmd_rsp_cmstatus_err = {};
        find_str_rsp_nccmd_rsp_cmstatus_err = {};
        find_str_rsp_dtr_rsp_cmstatus_err = {};
        m_tmp_q_strreq = m_ott_q.find_index with ((item.isSMISTRReqRecd                            === 1 &&
                                                   item.isSMISTRRespSent                           === 0 &&
                                                   item.m_str_req_pkt.smi_unq_identifier === m_pkt.smi_rsp_unq_identifier) || 
                                                  (item.is2ndSMISTRReqNeeded    === 1 && 
                                                   item.is2ndSMISTRReqRecd      === 1 && 
                                                   item.is2ndSMISTRRespSent     === 0 &&
                                                   item.m_2nd_str_req_pkt.smi_unq_identifier === m_pkt.smi_rsp_unq_identifier)
                                                 );
        
    	if (m_tmp_q_strreq.size() == 0) begin
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("Received STR_RSP packet at IOAIU SCB: %0s", m_pkt.convert2string()), UVM_LOW)
            if(!$test$plusargs("inject_smi_uncorr_error"))
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Cannot find any STRReq packets that match the above SMI slave master response packet's trans id (NOC->AIU). Information printed above"), UVM_NONE);
	    end else begin
            if (m_ott_q[m_tmp_q_strreq[0]].t_sfi_str_req >= $time) begin
                m_ott_q[m_tmp_q_strreq[0]].print_me();
                m_pkt.print(uvm_default_line_printer);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("StrRsp sent at the same cycle as StrReq was received. SMIspec does not allow this"), UVM_NONE);
            end
	        index = m_tmp_q_strreq[0];
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received STR_RSP packet at IOAIU SCB: %0s", m_ott_q[index].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)


            if ($test$plusargs("wrong_strreq_target_id")) begin
              if (m_ott_q[m_tmp_q_strreq[0]].isSMISTRReqRecd) begin
                find_str_rsp_str_req_targ_id_err = str_req_msg_id_targ_id_err.find_index with(item.src_id == m_pkt.smi_targ_ncore_unit_id &&
                                                                                              item.msg_id == m_pkt.smi_rmsg_id
                                                                                             );
                if (find_str_rsp_str_req_targ_id_err.size() != 0) begin
                  `uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("STRreq pkt:", m_pkt.convert2string()), UVM_NONE);
                  `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("AIU not droping STRrsp with smi_msg_id = 0x%0x for wrong target_id", str_req_msg_id_targ_id_err[find_str_rsp_str_req_targ_id_err[0]].msg_id))
                end
              end
            end
            if ($test$plusargs("wrong_dtwrsp_target_id")) begin
              if (m_ott_q[m_tmp_q_strreq[0]].isSMIDTWRespRecd) begin
                find_str_rsp_dtw_rsp_targ_id_err = dtw_rsp_rmsg_id_targ_id_err.find_index with(item == m_ott_q[index].m_dtw_rsp_pkt.smi_rmsg_id);
                if (find_str_rsp_dtw_rsp_targ_id_err.size() != 0) begin
                  `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("AIU not droping DTWrsp with smi_rmsg_id = 0x%0x for wrong target_id, corresponding DTWreq smi_msg_id = 0x%0x, STRrsp smi_rmsg_id = 0x%0x, and CMDreq smi_msg_id = 0x%0x", dtw_rsp_rmsg_id_targ_id_err[find_str_rsp_dtw_rsp_targ_id_err[0]], find_str_rsp_dtw_rsp_targ_id_err[0], m_pkt.smi_rmsg_id, m_ott_q[index].m_cmd_req_pkt.smi_msg_id))
                end
              end
            end
            if ($test$plusargs("wrong_dtrrsp_target_id")) begin
              if (m_ott_q[m_tmp_q_strreq[0]].isSMISNPDTRRespRecd) begin
                find_str_rsp_dtr_rsp_targ_id_err = dtr_rsp_rmsg_id_targ_id_err.find_index with(item == m_ott_q[index].m_dtr_rsp_pkt.smi_rmsg_id);
                if (find_str_rsp_dtr_rsp_targ_id_err.size() != 0) begin
                  `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("AIU not droping DTRrsp with smi_rmsg_id = 0x%0x for wrong target_id, corresponding DTRreq smi_msg_id = 0x%0x, STRrsp smi_rmsg_id = 0x%0x, and CMDreq smi_msg_id = 0x%0x", dtr_rsp_rmsg_id_targ_id_err[find_str_rsp_dtr_rsp_targ_id_err[0]], find_str_rsp_dtr_rsp_targ_id_err[0], m_pkt.smi_rmsg_id, m_ott_q[index].m_cmd_req_pkt.smi_msg_id))
                end
              end
            end
            if ($test$plusargs("wrong_cmdrsp_target_id")) begin
              if (m_ott_q[m_tmp_q_strreq[0]].isSMICMDRespRecd) begin
                find_str_rsp_ccmd_rsp_targ_id_err = ccmd_rsp_rmsg_id_targ_id_err.find_index with(item == m_ott_q[index].m_cmd_rsp_pkt.smi_rmsg_id);
                if (find_str_rsp_ccmd_rsp_targ_id_err.size() != 0) begin
                  `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("AIU not droping CCMDrsp with smi_rmsg_id = 0x%0x for wrong target_id, corresponding STRrsp smi_rmsg_id = 0x%0x, and CMDreq smi_msg_id = 0x%0x", ccmd_rsp_rmsg_id_targ_id_err[find_str_rsp_ccmd_rsp_targ_id_err[0]], m_pkt.smi_rmsg_id, find_str_rsp_ccmd_rsp_targ_id_err[0]))
                end
              end
              if (m_ott_q[m_tmp_q_strreq[0]].isSMICMDRespRecd) begin
                find_str_rsp_nccmd_rsp_targ_id_err = nccmd_rsp_rmsg_id_targ_id_err.find_index with(item == m_ott_q[index].m_cmd_rsp_pkt.smi_rmsg_id);
                if (find_str_rsp_nccmd_rsp_targ_id_err.size() != 0) begin
                  `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("AIU not droping NCCMDrsp with smi_rmsg_id = 0x%0x for wrong target_id, corresponding STRrsp smi_rmsg_id = 0x%0x, and CMDreq smi_msg_id = 0x%0x", nccmd_rsp_rmsg_id_targ_id_err[find_str_rsp_nccmd_rsp_targ_id_err[0]], m_pkt.smi_rmsg_id, find_str_rsp_ccmd_rsp_targ_id_err[0]))
                end
              end
            end
	end

        if (!m_ott_q[index].isStrRspEligibleForIssue()) begin
	
            m_ott_q[index].print_me();
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d AIU sent STR response without rest of the protocol being complete", m_ott_q[index].tb_txnid), UVM_NONE);
        end
        else begin
            m_ott_q[index].add_str_resp(m_pkt);
	    if((m_ott_q[index].hasFatlErr ) && m_ott_q[index].isMultiAccess && !m_ott_q[index].isMultiLineMaster && m_ott_q[index].multiline_ready_to_delete) begin
               int multiline_tracking_id_tmp = m_ott_q[index].m_multiline_tracking_id;
               int total_cacheline_count_tmp = m_ott_q[index].total_cacheline_count;
               int m_tmp_qA[$];
               `ifdef VCS
               int isWrite_tmp=m_ott_q[index].isWrite;
               int isRead_tmp=m_ott_q[index].isRead;
               `endif
               for (int i = 0; i < total_cacheline_count_tmp; i++) begin
                 int index_1 = -1;
                 m_tmp_qA = {};
                 m_tmp_qA = m_ott_q.find_index with (
                                                     `ifdef VCS
                                                     item.isWrite                 === isWrite_tmp &&
                                                     item.isRead                  === isRead_tmp &&
                                                     `else
                                                     item.isWrite                 === m_ott_q[index].isWrite &&
                                                     item.isRead                  === m_ott_q[index].isRead &&
                                                     `endif
	         				     item.isMultiAccess           === 1 &&
                                                     item.m_multiline_tracking_id === multiline_tracking_id_tmp
                                                    );
                 foreach (m_tmp_qA[j]) begin
                     if (m_ott_q[m_tmp_qA[j]].multiline_order === i) begin
                         index_1 = m_tmp_qA[j];
                         break;
                     end 
                 end
                 if (index_1 != -1 && !(m_ott_q[index_1].isSMISTRReqRecd && !m_ott_q[index_1].isSMISTRRespSent)) begin
                   m_ott_q_fatal_err.push_back(m_ott_q[index_1]);
	           delete_ott_entry(index_1,StrRsp); //deleting remaining OTT entries if incase ccpctrl pkt is pending although AXI resp is received due to str_req.cmstatus error
                 end
               end
               return;
	    end

             if (m_ott_q[index].isDVM) begin

            end
            else begin
                ace_command_types_enum_t m_ace_cmd_type_tmp;
                m_ace_cmd_type_tmp = m_ott_q[index].m_ace_cmd_type;
<%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %> 
                if (m_ott_q[index].m_ace_cmd_type === WRUNQ ||
                    m_ott_q[index].m_ace_cmd_type === WRLNUNQ
                ) begin

                    if ((m_ott_q[index].is_ccp_hit === 0 &&
                         m_ott_q[index].m_iocache_allocate === 1) 
                    ) begin
                        m_ace_cmd_type_tmp = m_ott_q[index].m_ace_cmd_type_io_cache;
                    end
                end
<% } %>

                if (m_ott_q[index].isSMIDTRReqDty) begin
                    m_ott_q[index].m_str_req_pkt.smi_cmstatus_sd = 1;
                 end

                // #Check.AIU.STRrsp.TR=11IsIllegal

            end // else: !if(m_ott_q[index].isDVM)
	

            // CONC-2292

            if ( (m_ott_q[index].isSMICMDRespRecd === 1) &&
                (m_ott_q[index].isSMIDTRReqNeeded ? m_ott_q[index].isSMIAllDTRRespSent == 1 :1) &&
                //CONC-9223 On STRreq.CMStatus.AddressError we still need a Fill packet to invalidate the line. There will not be a FillDataPkt
                (m_ott_q[index].isFillReqd ? (m_ott_q[index].isFillDataRcvd || m_ott_q[index].isSMISTRReqAddrErr || m_ott_q[index].isSMISTRReqDataErr) :1) &&
                (m_ott_q[index].isMultiAccess ? m_ott_q[index].multiline_ready_to_delete == 1 : 1) &&
                (m_ott_q[index].isRead ? m_ott_q[index].isACEReadDataSent == 1 : 1) && 
                (m_ott_q[index].isWrite? m_ott_q[index].isACEWriteRespSent == 1 : 1) &&
				(m_ott_q[index].isIoCacheEvict ? ((csr_ccp_updatedis || !m_ott_q[index].isCoherent) ? 1 : (m_ott_q[index].isSMIUPDRespRecd == 1)) : 1) &&
                (m_ott_q[index].isDVMSync ? m_ott_q[index].isACESnoopReqSent && m_ott_q[index].isACESnoopRespRecd : 1)

            ) begin
                delete_ott_entry(index, StrRsp);
	    end else begin
                if (m_ott_q[index].isMultiAccess && !m_ott_q[index].multiline_ready_to_delete) begin
                    if (m_ott_q[index].isSMISTRRespSent && 
                        m_ott_q[index].isSMICMDRespRecd    === 1 &&
                       (m_ott_q[index].isSMIDTRReqNeeded ? m_ott_q[index].isSMIAllDTRRespSent:1) 
                    ) begin
                        m_ott_q[index].multiline_ready_to_delete = 1;

                        if (m_ott_q[index].isRead && m_ott_q[index].isMultiLineMaster && m_ott_q[index].isACEReadDataSent) begin
                            unblock_axid_read(m_ott_q[index].m_ace_read_addr_pkt.arid);
                        end else if (m_ott_q[index].isWrite && m_ott_q[index].isMultiLineMaster && m_ott_q[index].isACEWriteRespSent) begin
                            unblock_axid_write(m_ott_q[index].m_ace_write_addr_pkt.awid);
                        end
                    end
                end
            end 
	    
        end
						     
endfunction : process_str_rsp
							     
//----------------------------------------------------------------------- 
// SMI Data Reply Request Packet (Outgoing DTR for snoop)
//----------------------------------------------------------------------- 
		     
function void ioaiu_scoreboard::process_snp_dtr_req(smi_seq_item m_pkt);
        int                   m_tmp_qA[$], outstanding_snp_dtrq[$];
        bit                   flag_dp_dbad_found = 0;

        <% if(obj.testBench == "fsys"  || obj.testBench == "emu") { %>
        if(addr_trans_mgr::check_aiu_is_unconnected(.tgt_unit_id(m_pkt.smi_targ_ncore_unit_id), .src_unit_id(m_pkt.smi_src_ncore_unit_id))) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",
            $sformatf("In SNP_DTR_REQ, Connectivity between AIU FUnitID %0d and AIU FUnitID %0d should have been optimized and not existing", m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_src_ncore_unit_id))
        end
        <% } %>
        
        outstanding_snp_dtrq = {};
        outstanding_snp_dtrq = m_ott_q.find_index with (item.isSnoop && 
                                                         item.isSMISNPDTRReqSent &&
                                                         !item.isSMISNPDTRRespRecd &&
                                                         (item.m_dtr_req_pkt.smi_targ_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id) &&
                                                         (item.m_dtr_req_pkt.smi_msg_id == m_pkt.smi_msg_id));

        if (outstanding_snp_dtrq.size() > 0)
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Below DTR request has same message-id as an outstanding dtr_req IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> to the same target -%0s", m_ott_q[outstanding_snp_dtrq[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()));

        m_tmp_qA = {};
        m_tmp_qA = m_ott_q.find_index with (item.matchSnpDtrReq(m_pkt));
        if (m_tmp_qA.size === 0) begin
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Outgoing DTR request does not have a matching request %p", m_pkt.convert2string()), UVM_NONE);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Above outgoing DTR request does not have a matching request"), UVM_NONE);
        end

        // Temporary work around for system BFM bug.
        // Once AIU sends SnpRsp, system BFM can resend a new snoop request with the same {req_aiu_id, req_aiu_trans_id}
        // This wont be possible in a real system because the requesting AIU will also wait for a DTRReq
        // However, since this is possible in the block level, I will just match the DTRReq to the oldest snoop

         else begin

            <% if (obj.testBench === "aiu") {%>
                m_tmp_qA[0] = find_oldest_snoop_in_ott_q(m_tmp_qA);
            <% } %>
        <%if(obj.COVER_ON && (obj.fnNativeInterface == "ACELITE-E" || obj.useCache)) { %>
            //#Cov.IOAIU.SMI.SNPDTRReq.MPF1
            if(m_ott_q[m_tmp_qA[0]].isSnoop) begin
	            `ifndef FSYS_COVER_ON
	            cov.snoop_dtr_req_type = 2;
	            `endif
            end
	        else if(m_ott_q[m_tmp_qA[0]].isWrite) begin
		        `ifndef FSYS_COVER_ON
		        cov.snoop_dtr_req_type = 1;
		        `endif
            end	     
	        `ifndef FSYS_COVER_ON
                case(core_id)
                    <%for(let i=0; i< obj.nNativeInterfacePorts; i+=1){%>
                        <%=i%> : begin
                            cov.ccp_snoop_dtr_req_type_core<%=i%>.sample();
                        end
                    <%}%>
                endcase
	        `endif
        <%}%>
            <% if(obj.useCache) { %>
            if(m_ott_q[m_tmp_qA[0]].csr_ccp_lookupen && m_ott_q[m_tmp_qA[0]].csr_ccp_allocen && m_ott_q[m_tmp_qA[0]].isSMISNPDTRReqNeeded &&  !m_ott_q[m_tmp_qA[0]].isIoCacheDataPipelineSeen ) begin
                m_ott_q[m_tmp_qA[0]].print_me();
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Snoop DTR request issued before ccp data is received for OutstTxn #%0d %s",m_tmp_qA[0], m_pkt.convert2string()), UVM_NONE);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Snoop DTR request issued before ccp data is received for OutstTxn #%0d",m_tmp_qA[0]));
            end
            // CONC-6860 -> Waived off the CMSTATUS as correct DBAD is there
            //// CONC-6721 :  For the error in first beat the cmstatus should be Data Error
            
            <%}%>
            // Checking be
            // #Check.AIU.DataCorruption.OutgoingDTRreqFromCRRESPWithErrorDeassertsByteenable
            foreach (m_pkt.smi_dp_be[i]) begin
                <% if(obj.useCache) { %>
                    if (m_pkt.smi_dp_be[i] !== '1 && m_ott_q[m_tmp_qA[0]].m_smi_data_be[i] === 1) begin
                        m_ott_q[m_tmp_qA[0]].print_me();
                        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_pkt.convert2string()), UVM_NONE);
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("req_be for snoop DtrReq Message with error beat:0x%0x Expected: 0x%0x Actual: 0x%0x", i, '1, m_pkt.smi_dp_be[i]), UVM_NONE);
                    end 
                    if (m_pkt.smi_dp_be[i] !== '0 && m_ott_q[m_tmp_qA[0]].m_smi_data_be[i] === 0) begin
                        m_ott_q[m_tmp_qA[0]].print_me();
                        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_pkt.convert2string()), UVM_NONE);
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("req_be for snoop DtrReq Message with error beat:0x%0x Expected: 0x%0x Actual: 0x%0x", i, '0, m_pkt.smi_dp_be[i]), UVM_NONE);
                    end 
                    if (m_pkt.smi_dp_dbad[i] === '1) begin
                        flag_dp_dbad_found = 1;
                    end 
 
                <% }%>

            end
            <% if(obj.useCache) { %>
            if (flag_dp_dbad_found !== '0 && m_ott_q[m_tmp_qA[0]].m_io_cache_only_data_err_found === 0) begin
                m_ott_q[m_tmp_qA[0]].print_me();
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_pkt.convert2string()), UVM_NONE);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("req_dbad for snoop DtrReq Message with error Expected: 0x%0x But one/more beat(s) had dbad set: 0x%0x",  '0, flag_dp_dbad_found), UVM_NONE);
            end 
            if (flag_dp_dbad_found !== '1 && m_ott_q[m_tmp_qA[0]].m_io_cache_only_data_err_found === 1) begin
                m_ott_q[m_tmp_qA[0]].print_me();
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_pkt.convert2string()), UVM_NONE);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("req_dbad for snoop DtrReq Message with error Expected: 0x%0x But none of the beat had dbad set: 0x%0x",  '1, flag_dp_dbad_found), UVM_NONE);
            end 
            <% } %>
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received SNP_DTR_REQ packet at IOAIU SCB: %0s", m_ott_q[m_tmp_qA[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)
 
            if (!(m_ott_q[m_tmp_qA[0]].isSMISNPReqRecd      === 1 &&
                <% if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %>
                    ((m_ott_q[m_tmp_qA[0]].csr_ccp_lookupen && m_ott_q[m_tmp_qA[0]].csr_ccp_allocen)?( // ccp_enable
					m_ott_q[m_tmp_qA[0]].isIoCacheTagPipelineSeen === 1 &&
                    m_ott_q[m_tmp_qA[0]].is_ccp_hit === 1 &&
                    m_ott_q[m_tmp_qA[0]].is_write_hit_upgrade === 0 
		        	):1) //ccp_disable
					&&
                    //m_ott_q[m_tmp_qA[0]].m_io_cache_pkt.cacheState === UD &&
                <% } else { %>
                  m_ott_q[m_tmp_qA[0]].isACESnoopReqSent    === 1 &&
                  m_ott_q[m_tmp_qA[0]].isACESnoopRespRecd   === 1 &&
                  m_ott_q[m_tmp_qA[0]].isACESnoopDataRecd   === 1 &&
              <% } %>     
                  m_ott_q[m_tmp_qA[0]].isSMISNPDTRReqNeeded === 1 &&
                  m_ott_q[m_tmp_qA[0]].isSMISNPDTRReqSent   === 0 &&
		  m_pkt.isDtrMsg()) &&
                !(m_ott_q[m_tmp_qA[0]].isSMISNPReqRecd      === 1 &&
                  m_ott_q[m_tmp_qA[0]].isACESnoopReqSent    === 1 &&
                  m_ott_q[m_tmp_qA[0]].isACEReadAddressRecd === 1 &&
                  m_ott_q[m_tmp_qA[0]].isSMISNPDTRReqNeeded === 1 &&
                  m_ott_q[m_tmp_qA[0]].isSMISNPDTRReqSent   === 0/* &&
DCTODO WHat's this                  m_pkt.smi_type                === eDtrDvmCmp*/) &&
               !(m_ott_q[m_tmp_qA[0]].isStash      === 1 &&
		  m_ott_q[m_tmp_qA[0]].isSMISTRReqRecd      === 1 &&
                  m_ott_q[m_tmp_qA[0]].isSMISNPDTRReqNeeded === 1 &&
                  m_ott_q[m_tmp_qA[0]].isSMISNPDTRReqSent   === 0)
              ) begin
                m_ott_q[m_tmp_qA[0]].print_me();
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%1p", m_pkt), UVM_NONE);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing AIU->NOC DTR request being sent without rest of the protocol being complete"), UVM_NONE);
            end
            m_ott_q[m_tmp_qA[0]].add_snp_dtr_req(m_pkt);
            <%if(obj.COVER_ON) { %> 
            `ifndef FSYS_COVER_ON
            //#Cover.IOAIU.SNPDTRreq.CMStatus.DataError
             <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || obj.useCache) { %>
              cov.snoop_dtrreq_cmstatus_err = m_pkt.smi_cmstatus_err_payload;
               case(core_id)
               <%for(let i=0; i< obj.nNativeInterfacePorts; i+=1){%>
               <%=i%> : begin
                        cov.snoop_dtrreq_cmstatus_err_covergroup_core<%=i%>.sample();
                        end
               <%}%>
               endcase
               <%}%>
              `endif 
              <%}%> 

            if (m_ott_q[m_tmp_qA[0]].isACESnoopRespRecd && m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt.crresp[CCRRESPERRBIT] === 1) begin
              if (m_pkt.smi_cmstatus !== 8'b1000_0011) begin
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Expected to send cmstatus = 8'b1000_0011 (data error) in DTR_REQ for ACE snoop crresp error, Received smi_cmstatus = %0b",m_pkt.smi_cmstatus))
              end
            end 

                if (m_pkt.smi_dp_data.size !== SYS_nSysCacheline*8/wSmiDPdata) begin
                    uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%s", m_pkt.convert2string()), UVM_NONE);
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing AIU->NOC DTR request has data size not equal to cacheline size/data bus width (Expected: 0x%0x Actual: 0x%0x)", SYS_nSysCacheline*8/wSmiDPdata, m_pkt.smi_dp_data.size), UVM_NONE);
                end
                
                <% if(obj.useCache) { %>
				if (m_ott_q[m_tmp_qA[0]].csr_ccp_lookupen && m_ott_q[m_tmp_qA[0]].csr_ccp_allocen) begin:_ccp_enable
                <%}%>
                <% if( obj.useCache || obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
		m_ott_q[m_tmp_qA[0]].check_snp_dtr_type(m_tmp_qA[0]);
		m_ott_q[m_tmp_qA[0]].check_snp_dtr_attr(m_tmp_qA[0]); // currently check only Qos/Pri and RMsgId
                <%}%>
                <% if(obj.useCache) { %>
		        end:_ccp_enable
                <%}%>

                // Checking DTR offset - hardcoding to 2 since we need to send a 32 bit offset 

<%if(obj.useCache) { %>
		if (m_ott_q[m_tmp_qA[0]].csr_ccp_lookupen && m_ott_q[m_tmp_qA[0]].csr_ccp_allocen) begin:_ccp_enable_cachehit	
                // If its a IO cache hit, check data
                if (!m_ott_q[m_tmp_qA[0]].is_ccp_hit) begin     
                    m_ott_q[m_tmp_qA[0]].print_me();
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing SMI DTR packet being sent even though this was not a IO-$ hit"), UVM_NONE);
                end
                else begin
                    if (m_ott_q[m_tmp_qA[0]].m_dtr_req_pkt.smi_dp_data.size() !== m_ott_q[m_tmp_qA[0]].m_io_cache_data.size()) begin
                        m_ott_q[m_tmp_qA[0]].print_me();
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SMI DTR data size is not the same as data size in IO cache (SMI:%p IO$:%p)",  m_ott_q[m_tmp_qA[0]].m_dtr_req_pkt, m_ott_q[m_tmp_qA[0]].m_io_cache_data), UVM_NONE);
                    end

		    m_ott_q[m_tmp_qA[0]].checkSnpDtrData($sformatf("OutstTxn #%0d",m_tmp_qA[0]));

                end
      end:_ccp_enable_cachehit
<% } else { %>
       m_ott_q[m_tmp_qA[0]].checkSnpDtrData($sformatf("OutstTxn #%0d",m_tmp_qA[0]));

 <% } %> 
             
        end							     
endfunction : process_snp_dtr_req
    
function void ioaiu_scoreboard::process_upd_req(smi_seq_item m_pkt);
	int m_tmp_qA[$];
    int m_tmp_qCov[$];
	string s;
        
    //Update request can only be initiated by ACE IOAIU or proxyCache IOAIU 
	if (!(addrMgrConst::get_native_interface(<%=obj.nUnitId%>) inside {addrMgrConst::ACE_AIU, addrMgrConst::IO_CACHE_AIU})) begin
    	`uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf("Update request is not expected on IOAIU with NativeInterface:<%=obj.fnNativeInterface%>"))
	end

    <% if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache == 1) { %>
		if (csr_ccp_updatedis == 1) begin 
    		`uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf("SMI UPDreq is not expected on IOAIU with NativeInterface:<%=obj.fnNativeInterface%> when XAIUPCTCR.UpdateDis=1"))
		end 
                
    <%}%>
	
    
    //Check to see if there is an outstanding request with same {req_aiu_id, req_aiu_trans_id}
	//#Check.IOAIU.SMI.UPDReq.MatchTXN
    m_tmp_qA = {};
    m_tmp_qA = m_ott_q.find_index with ((((item.isRead                                    === 1 ||
                                               item.isWrite                                   === 1 ||
                                               (item.isIoCacheEvict                           === 1 &&
						item.isSMISTRReqRecd                          === 1 &&
						item.isSMIDTWRespRecd                         === 1)
                                             ) &&
                                              (item.isSMICMDReqSent) ? item.m_cmd_req_pkt.smi_msg_id === m_pkt.smi_msg_id : 0)
                                             ) &&

                                            <%if(!((obj.fnNativeInterface === "AXI4") || (obj.fnNativeInterface === "AXI5"))) { %> 
                                              item.isAceCmdReqBlocked                         === 0 &&
                                             <% } %>
					      !item.isStrRspEligibleForIssue()
                                          );
        // Its possible that STRResp is waiting to be sent for previous transaction
        // with same req aiu trans id and a CmdReq is sent                                  
        if (m_tmp_qA.size > 0) begin                                   
            bit flag = 0;
            for (int i = 0; i < m_tmp_qA.size; i++) begin
                if (m_ott_q[m_tmp_qA[i]].isRead) begin
                    if (m_ott_q[m_tmp_qA[i]].isACEReadDataSent === 0 ||
                        (m_ott_q[m_tmp_qA[i]].isSMIDTWReqNeeded  === 1 &&
                         m_ott_q[m_tmp_qA[i]].isSMIDTWRespRecd === 0) ||
                        (m_ott_q[m_tmp_qA[i]].isSMIDTRReqNeeded  === 1 &&
                         (m_ott_q[m_tmp_qA[i]].isSMIAllDTRReqRecd === 0 &&
                         m_ott_q[m_tmp_qA[i]].isDVMSync          === 0)
                         ) ||
                        m_ott_q[m_tmp_qA[i]].isSMICMDRespRecd === 0) begin
                        flag = 1;
                    end
                end
                else if (m_ott_q[m_tmp_qA[i]].isWrite) begin
                    if (m_ott_q[m_tmp_qA[i]].isACEWriteRespSent === 0) begin
                        flag = 1;
                    end
                end
                else if (m_ott_q[m_tmp_qA[i]].isUpdate) begin
                    flag = 1;
                end
                else if (m_ott_q[m_tmp_qA[i]].isIoCacheEvict) begin
                    if (((m_ott_q[m_tmp_qA[i]].isSMIDTWReqNeeded  === 1 &&
                         m_ott_q[m_tmp_qA[i]].isSMIDTWRespRecd   === 0) ||
                         m_ott_q[m_tmp_qA[i]].isSMISTRReqRecd    === 0) ||
                        m_ott_q[m_tmp_qA[i]].isSMICMDRespRecd === 0) begin
                     flag = 1;
	            end
                end
            end
            if (flag) begin
	        s = "";
                for (int i = 0; i < m_tmp_qA.size; i++) begin
	            s = $sformatf("%s,%0d",s,m_tmp_qA[i]);
                    m_ott_q[m_tmp_qA[i]].print_me();
                end
                if(!$test$plusargs("inject_smi_uncorr_error"))
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing update request has a matching smi_msg_id that matches previously sent command/update request OutstTxn#%s with same fields %s", s,m_pkt.convert2string()), UVM_NONE);
            end
        end
        // #Check.AIU.AnUpdateInvalidMessageIsIssuedForAnUpdateInvalidTransactionAfterTheDTWrspMessageHasBeenReceived
        m_tmp_qA = {};
        m_tmp_qA = m_ott_q.find_index with ((item.isUpdate                    === 1 &&
                                            item.isACEWriteAddressRecd       === 1 &&
                                            //item.isACEWriteDataRecd        === 1 &&
                                            item.isACEWriteRespSent          === 0 &&
//MatchUPDToAW
                                            item.m_ace_write_addr_pkt.awaddr[WAXADDR - 1:$clog2(wSmiDPdata/8)]  === m_pkt.smi_addr[WAXADDR - 1:$clog2(wSmiDPdata/8)] &&
					    item.matchNS(m_pkt)                  &&
                                            ((item.isSMIDTWReqNeeded         === 1 &&
                                              item.isSMIDTWReqSent           === 1 &&
                                              item.isSMIDTWRespRecd          === 1) ||
                                              item.isSMIDTWReqNeeded         === 0) && 
                                            item.isSMIUPDReqNeeded           === 1 &&  
                                            item.isSMIUPDReqSent             === 0 &&

                                            <%  if(!(obj.fnNativeInterface == "AXI5" || obj.fnNativeInterface == "AXI4" ||obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")) { %> 
                                              item.isAceCmdReqBlocked                         === 0 &&
                                             <% } %>

                                            item.isCoherent                  === 1)
<%if((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %> 
                                               ||  ((item.csr_ccp_lookupen)? ( //ccp_enable
                                            item.isIoCacheEvict             === 1 &&
                                            item.matchNS(m_pkt)                  &&
                                             item.isSMIUPDReqNeeded          === 1 &&
                                             item.isSMIUPDReqSent            === 0 &&
					     ((item.isSMICMDReqNeeded) ? 
					      ((item.isSMICMDReqSent) ? item.m_cmd_req_pkt.smi_addr[WAXADDR - 1:SYS_wSysCacheline] === m_pkt.smi_addr[WAXADDR - 1:SYS_wSysCacheline]/*item.m_cmd_req_pkt.smi_msg_id === m_pkt.smi_msg_id */: 0 ) :
                                              (item.m_sfi_addr[WAXADDR - 1:SYS_wSysCacheline] === m_pkt.smi_addr[WAXADDR - 1:SYS_wSysCacheline])) &&
                                            ((item.isSMIDTWReqNeeded         === 1 &&
                                              item.isSMIDTWReqSent           === 1 &&
                                              item.isSMIDTWRespRecd          === 1) ||
                                              item.isSMIDTWReqNeeded         === 0)
									        ):0) // ccp_disable
<% } %>
                                           );
 
        if (m_tmp_qA.size === 0) begin 
            if(!$test$plusargs("inject_smi_uncorr_error"))                              
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Cannot find a corresponding transaction for the following UpdReq packet %s",m_pkt.convert2string()), UVM_NONE);
        end
        else if ((m_tmp_qA.size > 1) &&(!check_id(m_tmp_qA)) ) begin
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Found multiple corresponding ACE transactions for the following UpdReq packet %s",m_pkt.convert2string()), UVM_NONE);
        end
        else begin
            m_ott_q[m_tmp_qA[0]].setup_upd_req(m_pkt);
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received UPD_REQ packet at IOAIU SCB: %0s",m_ott_q[m_tmp_qA[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_pkt.convert2string()), UVM_LOW)

             //#Check.IOAIU.SMI.UPDReq.WritebackTargID
            // Check to make sure UPDReq is going to the right DCE 
            if (!m_ott_q[m_tmp_qA[0]].matchHomeDceUnitId(m_pkt)) begin
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("%1p", m_pkt), UVM_NONE);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing Concert UPDReq is not being sent with the correct DCE ID (Expected: 0x%0x Actual: 0x%0x) for OutstTxn #%0d %s", m_ott_q[m_tmp_qA[0]].home_dce_unit_id, m_pkt.smi_targ_id,m_tmp_qA[0],m_pkt.convert2string()), UVM_NONE);
            end

            // Check to make sure UPDReq is going with the right AIUTransID
            // #Check.AIU.SameOTTEntryOnUpdandDTW
	    //DCTODO SMICHK Is this still needed? According to Nabil 7/23 he's still doing this
            if (m_ott_q[m_tmp_qA[0]].isSMIDTWReqNeeded &&
                m_ott_q[m_tmp_qA[0]].m_upd_req_pkt.smi_msg_id !== m_ott_q[m_tmp_qA[0]].m_cmd_req_pkt.smi_msg_id
            ) begin
                m_ott_q[m_tmp_qA[0]].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing Write Request SMI UPD packet has wrong ReqAIUTransID. (Expected:ReqAIUTransID:0x%0x Actual:ReqAIUTransID:0x%0x)", m_ott_q[m_tmp_qA[0]].m_cmd_req_pkt.smi_msg_id, m_ott_q[m_tmp_qA[0]].m_upd_req_pkt.smi_msg_id), UVM_NONE);
            end

        end
	endfunction : process_upd_req

      function bit ioaiu_scoreboard::check_id(int m_tmp_qA[$]);
          
           for(int i =0; i<(m_tmp_qA.size() - 1); i++)begin
              if((m_ott_q[m_tmp_qA[i]].m_ace_write_addr_pkt.awid) != (m_ott_q[m_tmp_qA[i+1]].m_ace_write_addr_pkt.awid))begin
                  return 0;
              end
           end
           return 1;
      endfunction

    //----------------------------------------------------------------------- 
    //SMI Update Response Packet
    //----------------------------------------------------------------------- 
//DCTODO DATACHK
	
    function void ioaiu_scoreboard::process_upd_rsp(smi_seq_item m_pkt);
        int          m_tmp_q_updreq[$];
        int          index;	    
	string       s = "";
        m_tmp_q_updreq = {};
        m_tmp_q_updreq = m_ott_q.find_index with (item.isSMIUPDReqSent                            === 1 &&
                                                  item.isSMIUPDRespRecd                           === 0 &&
                                                  item.m_upd_req_pkt.smi_unq_identifier === m_pkt.smi_rsp_unq_identifier
                                                 );
        if ( m_tmp_q_updreq.size() === 0) begin
            if(!$test$plusargs("inject_smi_uncorr_error"))begin
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Cannot find any UPDReq packets that match the UPDrsp smi_msg_id (NOC->AIU). %s",m_pkt.convert2string()), UVM_NONE);
        end
	end
	else if(m_tmp_q_updreq.size() === 1) begin
	    index = m_tmp_q_updreq[0];
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received UPD_RSP packet at IOAIU SCB: %0s",  m_ott_q[index].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_pkt.convert2string()), UVM_LOW)

<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %> 
            m_ott_q[index].add_upd_resp(m_pkt);
            if(m_ott_q[index].isComplete()) begin
                delete_ott_entry(index, UpdRsp);
            end
<% } %>
        end
	else begin	    
	    foreach(m_tmp_q_updreq[i]) begin
	       s = $sformatf("%s,%0d",s,m_tmp_q_updreq[i]);
	    end
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("UPDRsp matched multiple TXNs OutstTxn#%s %s",s,m_pkt.convert2string()), UVM_NONE);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("UPDRsp matched multiple TXNs"), UVM_NONE);
	end
<%if(obj.useCache) { %> 
        if (m_ott_q[index].isIoCacheEvict === 1) begin
            if (!(m_ott_q[index].isIoCacheEvict      === 1  &&
                  m_ott_q[index].isSMIUPDReqSent     === 1  &&
                  m_ott_q[index].isSMIUPDRespRecd    === 0  &&
                  ((m_ott_q[index].isSMIDTWReqNeeded === 1  &&
                    m_ott_q[index].isSMIDTWReqSent   === 1  &&
                    m_ott_q[index].isSMIDTWRespRecd  === 1) ||
                   m_ott_q[index].isSMIDTWReqNeeded  === 0)
              )) begin
                m_ott_q[index].print_me();
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("AIU received UPD response without rest of the protocol being complete for OutstTxn#%0d %s",index,m_pkt.convert2string()), UVM_NONE);
            end      
//            else if(m_ott_q[index].isSMISTRReqRecd === 0)begin
//            else if(m_ott_q[index].isComplete())begin
//                delete_ott_entry(index, UpdRsp);
//            end
            else begin
                m_ott_q[index].add_upd_resp(m_pkt);
                if(m_ott_q[index].isComplete()) begin
                   delete_ott_entry(index, UpdRsp);
		end       
            end
        end
<% } %>
	    
    endfunction : process_upd_rsp
   
function void ioaiu_scoreboard::set_sleeping(ioaiu_scb_txn scb_txn);
   int m_search_q[$];	
   m_search_q = {};
   m_search_q = m_ott_q.find_index() with (
	item.m_sfi_addr === scb_txn.m_sfi_addr ||
	((item.isWrite && scb_txn.isWrite) ? item.m_ace_write_addr_pkt.awid == scb_txn.m_ace_write_addr_pkt.awid : 0) ||
	((item.isRead && scb_txn.isRead) ? item.m_ace_read_addr_pkt.arid == scb_txn.m_ace_read_addr_pkt.arid : 0)
   );	
  if(m_search_q.size() > 1)	
	scb_txn.isSleeping = 1;
endfunction : set_sleeping
function void ioaiu_scoreboard::wake_sleeping(ioaiu_scb_txn scb_txn);
   int m_addr_q[$],m_axid_q[$],m_tmp_q[$];	
   m_axid_q = {};
   m_axid_q = m_ott_q.find_index() with (
	((item.isWrite && scb_txn.isWrite) ? item.m_ace_write_addr_pkt.awid == scb_txn.m_ace_write_addr_pkt.awid : 0) ||
	((item.isRead && scb_txn.isRead) ? item.m_ace_read_addr_pkt.arid == scb_txn.m_ace_read_addr_pkt.arid : 0)
   );
   if(m_axid_q.size() > 0) begin
	if(m_axid_q.size() > 1)
	   m_axid_q[0] = find_oldest_entry_in_ott_q(m_axid_q);
	m_ott_q[m_axid_q[0]].isSleeping = 0;
	m_ott_q[m_axid_q[0]].wasSleeping = 1;
	if(m_ott_q[m_axid_q[0]].isMultiAccess) begin
	     for(int i = 0;i<m_ott_q.size();i++) begin
	        if(m_ott_q[i].isMultiAccess                        &&
		   m_ott_q[i].m_multiline_tracking_id === m_ott_q[m_axid_q[0]].m_multiline_tracking_id) begin
	              if(m_ott_q[i].isSleeping != 0) begin
	                 m_ott_q[i].isSleeping = 0;
	                 m_ott_q[i].wasSleeping = 1;	
	              end else begin
	                 m_ott_q[i].wasSleeping = 0;
	              end
	        end
	     end
	end
   end
   m_addr_q = {};
   m_addr_q = m_ott_q.find_index() with (
	(((item.isWrite) ? scb_txn.isWrite : 0) || ((item.isRead) ? scb_txn.isRead : 0)) &&
	item.m_sfi_addr === scb_txn.m_sfi_addr
   );
   if(m_addr_q.size() > 0) begin
	if(m_addr_q.size() > 1)
	   m_addr_q[0] = find_oldest_entry_in_ott_q(m_addr_q);
	m_ott_q[m_addr_q[0]].isSleeping = 0;
	m_ott_q[m_addr_q[0]].wasSleeping = 1;
	if(m_ott_q[m_addr_q[0]].isMultiAccess) begin
	     for(int i = 0;i<m_ott_q.size();i++) begin
	        if(m_ott_q[i].isMultiAccess                        &&
		   m_ott_q[i].m_multiline_tracking_id === m_ott_q[m_addr_q[0]].m_multiline_tracking_id) begin
	              if(m_ott_q[i].isSleeping != 0) begin
	                 m_ott_q[i].isSleeping = 0;
	                 m_ott_q[i].wasSleeping = 1;	
	              end else begin
	                 m_ott_q[i].wasSleeping = 0;
	              end
	        end
	     end
	end
   end
	
   //what happens if sleeping TXN is a snoop? probably will just do this the same...	
endfunction : wake_sleeping
	
	
<%if(obj.useCache) { %>

function bit[N_CCP_WAYS-1:0] ioaiu_scoreboard::get_allocated_ways_vec(ccp_ctrl_pkt_t m_pkt);
    bit [N_CCP_WAYS-1:0] allocated_way_vec = 0;
    int fndq[$];

    fndq = m_ncbu_cache_q.find_index() with (
                                        item.Index  == m_pkt.setindex
                                        );

    //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("fn:get_allocated_ways setIndex:0x%0h fndq.size:%0d", m_pkt.setindex, fndq.size()), UVM_LOW);

    if (fndq.size() > 0) begin 
        foreach(fndq[i]) begin 
            allocated_way_vec = allocated_way_vec | (1 << m_ncbu_cache_q[fndq[i]].way);
        end
    end

    return allocated_way_vec;
endfunction:get_allocated_ways_vec
    
function ccp_ctrlop_waybusy_vec_t ioaiu_scoreboard::get_pending_ways(int ccp_index) ;
     int m_search_q[$];
     ccp_ctrlop_waybusy_vec_t exp_pending_vec;
     //Check the busy vector provided by NCBU to CCP
     string spkt,s;	       
     int dec_hit_way_num = -1;	       
     exp_pending_vec = 0;

     m_search_q = {};
//     m_search_q = m_ott_q.find_index() with (item.ccp_index                == ccp_index                   &&
//                                             ((item.isIoCacheTagPipelineSeen) ? (((item.m_iocache_allocate==1 || item.is_write_hit_upgrade)
//                                               && item.isFillReqd) ? ((item.isFillCtrlRcvd == 0) || (item.isFillDataRcvd==0)): 0) : 0 /*(item.isSleeping == 0) && (item.wasSleeping == 1)*/)
//                                             );
     m_search_q = m_ott_q.find_index() with (
					     (!item.hasFatlErr) /*|| (item.hasFatlErr && item.isMultiAccess))*/ &&
                                             //(!item.dtwrsp_cmstatus_err) &&
                                             !(item.illegalNSAccess) &&
					     !(item.illegalCSRAccess) &&
                                             !(item.illDIIAccess) &&
                                             !(item.dtrreq_cmstatus_err) &&
                                             !($test$plusargs("unmapped_add_access") && addr_trans_mgr::check_unmapped_add(item.ccp_addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) &&
                                             !($test$plusargs("no_credit_check")) &&
                                             item.ccp_index == ccp_index                                  &&
                                             (item.isIoCacheTagPipelineSeen == 1 || 
					      (!item.isIoCacheTagPipelineSeen && item.is_write_hit_upgrade)) &&
                                             (item.addrNotInMemRegion == 1 || (((item.m_iocache_allocate==1 || item.is_write_hit_upgrade) 
                                               && item.isFillReqd) ? ((item.isFillCtrlRcvd == 0) ||
					      ((item.isFillDataReqd) ? (item.isFillDataRcvd==0) : 0)) /*&& !item.isWriteHitFull()*/: 0))
                                             );

    foreach(m_search_q[i]) begin					   
	s = $sformatf("%s,%0d",s,m_search_q[i]);
    end			
    uvm_report_info("<%=obj.strRtlNamePrefix%> SCB",$sformatf("Expected Busy OutstTxn #'s %s",s),UVM_MEDIUM);
    if(m_search_q.size()>0) begin
        foreach(m_search_q[i]) begin
           if(m_ott_q[m_search_q[i]].is_write_hit_upgrade) begin
                 dec_hit_way_num = m_ott_q[m_search_q[i]].ccp_way;
                 if(dec_hit_way_num != -1) begin
                    exp_pending_vec[dec_hit_way_num] = 1;
                 end else begin
                    spkt = {"Found Invalid Hit Way vector while generating ",
                            " the pending vector calculation OutstTxn #%0d HitVec:%0b "};
                    `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$psprintf(spkt,m_search_q[i],m_ott_q[m_search_q[i]].ccp_way))
                 end
            end else begin
                 exp_pending_vec[m_ott_q[m_search_q[i]].ccp_way] = 1;
            end
	end
   end
		       
   return exp_pending_vec;	       
endfunction;
function bit ioaiu_scoreboard::has_sleeping_ways(int ccp_index) ;
     int m_search_q[$];
     //Check the busy vector provided by NCBU to CCP

     m_search_q = {};
     m_search_q = m_ott_q.find_index() with ((!item.hasFatlErr &&
					     item.ccp_index                == ccp_index                   &&
					     ((item.isAddrBlocked == 1) || (item.isSleeping == 1) 
					      ||((item.isSleeping == 0)&& (item.wasSleeping == 1)))) ||
					      (item.hasFatlErr && //this is a case where a transaction shows as busy but has error in STRReq
					      ((item.isSMICMDReqNeeded) ? item.isSMISTRReqRecd && item.m_str_req_pkt.smi_cmstatus_err : 0)) ||
                                             ($test$plusargs("unmapped_add_access") && addr_trans_mgr::check_unmapped_add(item.ccp_addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) ||
                                             ($test$plusargs("no_credit_check")) ||
                                             (item.dtrreq_cmstatus_err) ||
                                             (item.illegalNSAccess) ||
					     (item.illegalCSRAccess) ||
                                             (item.illDIIAccess) 
				                                            );

   return m_search_q.size() > 0;	       
endfunction;

// Purpose : To set word in tag of cache_q for debug_Wr MntOp
function void      ioaiu_scoreboard::set_word_tag_array  (int set, int way, bit[5:0] word, bit[31:0] worddata);
    int m_find_q[$];
    bit[<%=wTagArrayEntry-1%>:0] TagEntry;
<%if(wTagProt){%>    bit[<%=wTagProt-1%>:0] dummy_ecc={<%=wTagProt%>{1'h1}};<%}%> // should be 6:0
    bit[<%=wTag-1%>:0] tag;
    bit dummy_bit;

    m_find_q = m_ncbu_cache_q.find_index() with (
                                        item.Index  == set    &&
                                        item.way    == way    
                                        );
    // Tag is not actually tag, it only removed 6 cachebits, Removing pribits now
    tag = get_tag_from_cacheline(m_ncbu_cache_q[m_find_q[0]].tag);
    if(m_find_q.size() == 1) begin
        TagEntry = { m_ncbu_cache_q[m_find_q[0]].security, tag, m_ncbu_cache_q[m_find_q[0]].state <% if(wRP) {%>, 1'b1<% } if(wTagProt){%>,dummy_ecc<%}%>};
        <% if(Math.ceil(wTagArrayEntry/32)-1) { %>
        if(word == <%=Math.ceil(wTagArrayEntry/32)-1%> ) begin
            TagEntry[(word*32)+:<%=(wTagArrayEntry%32)%>] = worddata[0+:<%=(wTagArrayEntry%32)%>];
        end else <% } %>
            TagEntry[(word*32)+:32] = worddata;
        { m_ncbu_cache_q[m_find_q[0]].security, tag, m_ncbu_cache_q[m_find_q[0]].state <% if(wRP) {%>, dummy_bit<% } if(wTagProt){%>,dummy_ecc<%}%>} = TagEntry;
        m_ncbu_cache_q[m_find_q[0]].tag = get_cacheline_from_tag(tag,m_ncbu_cache_q[m_find_q[0]].Index);
    end else begin
        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("set_word_tag_array : unable to find cacheline in Cache_q"));       
    end
endfunction : set_word_tag_array

// Purpose : To set word in data of cache_q for debug_Wr MntOp
function void      ioaiu_scoreboard::set_word_data_array (int set, int way, bit[5:0] word, bit[31:0] worddata);
    int m_find_q[$];
    bit[<%=wDataArrayEntry-1%>:0] DataEntry;
<%if(wDataProt){%>    bit[<%=wDataProt-1%>:0] dummy_ecc={<%=wDataProt%>{1'h1}};<%}%>
    int beat = word[4:(5-$clog2(<%=(512/obj.AiuInfo[obj.Id].ccpParams.wData)%>))];

    m_find_q = m_ncbu_cache_q.find_index() with (
                                        item.Index  == set    &&
                                        item.way    == way    
                                        );
    if(m_find_q.size() == 1) begin
        DataEntry = {m_ncbu_cache_q[m_find_q[0]].dataErrorPerBeat[beat],    m_ncbu_cache_q[m_find_q[0]].data[beat]<%if(wDataProt){%>,dummy_ecc<%}%>};
        if((word & ((1<< <%=(5-Math.log2(512/obj.AiuInfo[obj.Id].ccpParams.wData))%>)-1) ) == <%=Math.ceil(wDataArrayEntry/32)-1%> ) begin
            DataEntry[((word & ((1<< <%=(5-Math.log2(512/obj.AiuInfo[obj.Id].ccpParams.wData))%>)-1) )*32)+:<%=(wDataArrayEntry%32)%>] = worddata[0+:<%=(wDataArrayEntry%32)%>];
        end else begin
            DataEntry[((word & ((1<< <%=(5-Math.log2(512/obj.AiuInfo[obj.Id].ccpParams.wData))%>)-1) )*32)+:32] = worddata;
        end 
        {m_ncbu_cache_q[m_find_q[0]].dataErrorPerBeat[beat],    m_ncbu_cache_q[m_find_q[0]].data[beat]<%if(wDataProt){%>,dummy_ecc<%}%>} = DataEntry;
    end else begin
        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("set_word_data_array : unable to find cacheline in Cache_q"));       
    end
endfunction : set_word_data_array

// Purpose : To get word from tag of cache_q for debug_Rd MntOp
function bit[31:0] ioaiu_scoreboard::get_word_tag_array  (int set, int way, bit[5:0] word);
    int m_find_q[$];
    bit[<%=wTagArrayEntry-1%>:0] TagEntry;
<%if(wTagProt){%>    bit[<%=wTagProt-1%>:0] dummy_ecc={<%=wTagProt%>{1'h1}};<%}%> // should be 6:0
    bit[<%=wTag-1%>:0] tag;
    bit dummy_bit;
    bit[31:0] worddata ;

    m_find_q = m_ncbu_cache_q.find_index() with (
                                        item.Index  == set    &&
                                        item.way    == way    
                                        );
    // Tag is not actually tag, it only removed 6 cachebits, Removing pribits now
    tag = get_tag_from_cacheline(m_ncbu_cache_q[m_find_q[0]].tag);
    if(m_find_q.size() == 1) begin
        TagEntry = { m_ncbu_cache_q[m_find_q[0]].security, tag, m_ncbu_cache_q[m_find_q[0]].state <% if(wRP) {%>, 1'b1<% } if(wTagProt){%>,dummy_ecc<%}%>};
        <% if(Math.ceil(wTagArrayEntry/32)-1) { %>
        if(word == <%=Math.ceil(wTagArrayEntry/32)-1%> ) begin
            worddata[0+:<%=(wTagArrayEntry%32)%>] = TagEntry[(word*32)+:<%=(wTagArrayEntry%32)%>];
        end else <% } %>
            worddata = TagEntry[(word*32)+:32];
    end else begin
        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("get_word_tag_array : unable to find cacheline in Cache_q"));       
    end
    return worddata;
endfunction : get_word_tag_array

// Purpose : To get word from data of cache_q for debug_Rd MntOp
function bit[31:0] ioaiu_scoreboard::get_word_data_array (int set, int way, bit[5:0] word);
    int m_find_q[$];
    bit[<%=wDataArrayEntry-1%>:0] DataEntry;
<%if(wDataProt){%>    bit[<%=wDataProt-1%>:0] dummy_ecc={<%=wDataProt%>{1'h1}};<%}%>
    int beat = word[4:(5-$clog2(<%=(512/obj.AiuInfo[obj.Id].ccpParams.wData)%>))];
    bit[31:0] worddata ;

    m_find_q = m_ncbu_cache_q.find_index() with (
                                        item.Index  == set    &&
                                        item.way    == way    
                                        );
    if(m_find_q.size() == 1) begin
        DataEntry = {m_ncbu_cache_q[m_find_q[0]].dataErrorPerBeat[beat],    m_ncbu_cache_q[m_find_q[0]].data[beat]<%if(wDataProt){%>,dummy_ecc<%}%>};
        if((word & ((1<< <%=(5-Math.log2(512/obj.AiuInfo[obj.Id].ccpParams.wData))%>)-1) ) == <%=Math.ceil(wDataArrayEntry/32)-1%> ) begin
            worddata[0+:<%=(wDataArrayEntry%32)%>] = DataEntry[((word & ((1<< <%=(5-Math.log2(512/obj.AiuInfo[obj.Id].ccpParams.wData))%>)-1) )*32)+:<%=(wDataArrayEntry%32)%>];
        end else begin
            worddata = DataEntry[((word & ((1<< <%=(5-Math.log2(512/obj.AiuInfo[obj.Id].ccpParams.wData))%>)-1) )*32)+:32];
        end 
    end else begin
        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("get_word_data_array : unable to find cacheline in Cache_q"));       
    end
    return worddata;
endfunction : get_word_data_array

// Purpose : To get Tag from cacheline Addr
function bit[<%=wTag-1%>:0] ioaiu_scoreboard::get_tag_from_cacheline (bit[<%=wCacheline-1%>:0] cacheline);
    bit[<%=wTag-1%>:0] tag; 
    for(int i=0,j=0; i< <%=wCacheline%> ;i++) begin
       if(!(i inside {<% for(var idx=0;idx<obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length;idx++) {%> <%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits[idx]-wCacheLineOffset%><%if(idx<obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length-1){%>,<%}}%>} )) begin
          tag[j] = cacheline[i];
          j++;
       end
    end
    return tag;
endfunction : get_tag_from_cacheline

// Purpose : To get cacheline Addr from Tag and Index
function bit[<%=wCacheline-1%>:0] ioaiu_scoreboard::get_cacheline_from_tag (bit[<%=wTag-1%>:0] tag, bit[<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length-1%>:0] index);
    bit[<%=wCacheline-1%>:0] cacheline; 
    for(int i=0,j=0,k=0; i< <%=wCacheline%> ;i++) begin
       if(i inside {<% for(var idx=0;idx<obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length;idx++) {%> <%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits[idx]-wCacheLineOffset%><%if(idx<obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length-1){%>,<%}}%>} )
          cacheline[i] = index[k++];
       else
          cacheline[i] = tag[j++];
    end
    return cacheline;
endfunction : get_cacheline_from_tag
<% } %>
function bit ioaiu_scoreboard::matchSmiId(smi_seq_item pktA, smi_seq_item pktB);
	     
endfunction

//check if the RESP matches to the oldest AxID
function void ioaiu_scoreboard::check_oldest_axid_in_ott_q(int idx);
    time t_tmp_time;
    int  m_tmp_index;
    int  isRead;
    int  m_tmp_q[$];
    int  m_id;

    isRead = (m_ott_q[idx].isRead || m_ott_q[idx].isDVM) ? 1 : 0;
    t_tmp_time = isRead ? m_ott_q[idx].t_ace_read_recd : m_ott_q[idx].t_ace_write_recd;
    m_id = isRead ? m_ott_q[idx].m_ace_read_addr_pkt.arid : m_ott_q[idx].m_ace_write_addr_pkt.awid;
    m_tmp_index = idx;
    m_tmp_q = {};
    m_tmp_q = m_ott_q.find_index with (((isRead      &&
                                         (item.isRead || item.isDVM) &&
                                         (item.isACEReadDataNeeded ? !item.isACEReadDataSent : 0) &&
                                          item.m_ace_read_addr_pkt.arid == m_id) ||
                                        (!isRead      &&
                                         (item.isWrite || item.isUpdate || item.isAtomic || item.isStash) &&
                                         !item.isACEWriteRespSent &&
                                         item.m_ace_write_addr_pkt.awid == m_id)) &&
                                        (item.isMultiAccess            === 1 ?
                                         item.isMultiLineMaster        === 1 : 1)
                                    );
    // Search for oldest Axid
    if(isRead) begin
        for (int i = 0; i < m_tmp_q.size(); i++) begin
            if (t_tmp_time > m_ott_q[m_tmp_q[i]].t_ace_read_recd) begin
                t_tmp_time = m_ott_q[m_tmp_q[i]].t_ace_read_recd;
                m_tmp_index = m_tmp_q[i];
            end
        end
        if (idx != m_tmp_index) begin
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Below is the failed Txn"), UVM_NONE);
            m_ott_q[m_tmp_index].print_me();
            m_ott_q[idx].print_me();
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: ARID violation. Received RRESP(Txn#%0d) but is not matched to the oldest ARID(Txn#%0d)", idx, m_tmp_index), UVM_NONE);
        end
    end else begin
        for (int i = 0; i < m_tmp_q.size(); i++) begin
            if (t_tmp_time > m_ott_q[m_tmp_q[i]].t_ace_write_recd) begin
                t_tmp_time = m_ott_q[m_tmp_q[i]].t_ace_write_recd;
                m_tmp_index = m_tmp_q[i];
            end
        end
        if (idx != m_tmp_index) begin
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Below is the failed Txn"), UVM_NONE);
            m_ott_q[m_tmp_index].print_me();
            m_ott_q[idx].print_me();
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("SCB Error: AWID violation. Received BRESP(Txn#%0d) but is not matched to the oldest AWID(Txn#%0d)", idx, m_tmp_index), UVM_NONE);
        end
    end
endfunction : check_oldest_axid_in_ott_q

//Refer to IOAIU uArch spec Table 33. DTWReq Ordering Point
//CONC-16962 for Atomics
//#Check.IOAIU.OWO.DTWreqOrdering
function void ioaiu_scoreboard::owo_check_axid_ordering_dtwreq(int idx);
  int currtxn_axid    = m_ott_q[idx].m_id;
  int currtxn_destid    = m_ott_q[idx].dest_id;
  int match_idxq[$];
	
  match_idxq = {};
  match_idxq = m_ott_q.find_index with (   (item.isWrite || item.isAtomic) &&
                                           (item.m_id  == currtxn_axid) &&
                                           !item.hasFatlErr &&
                                           !item.dtwrsp_cmstatus_err &&
		                                       !item.dtrreq_cmstatus_err &&
                                           !item.dtrreq_cmstatus_err_expcted &&
					   !item.addrNotInMemRegion && 
					   !item.addrInCSRRegion  &&
					   !item.mem_regions_overlap &&       
					   !item.tagged_decerr                                                 
                                      );
        
  if ((match_idxq.size() > 0) && (match_idxq[0] < idx) && (m_ott_q[idx].addrInCSRRegion == 0)) begin // CSR accesses dont get in line for ordering
    if (m_ott_q[match_idxq[0]].dest_id == currtxn_destid) begin: _tgt_id_match_
		  if ((addrMgrConst::get_unit_type(currtxn_destid) == addrMgrConst::DMI) && !m_ott_q[match_idxq[0]].isCoherent) begin: _row3_ 	
			  if ((m_ott_q[match_idxq[0]].m_ace_cmd_type inside {ATMLD, ATMCOMPARE, ATMSWAP}) == 1) begin: _prev_txn_is_atm_
			 	  if (!m_ott_q[match_idxq[0]].isSMIDTWRespRecd || !m_ott_q[match_idxq[0]].isSMIDTRReqRecd) begin 
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("IOAIUp DTWreq Ordering Violation - UID:%0d(AxId:0x%0h) prematurely sends a DTWreq when an earlier NonCoh Atomic txn to same Tgt with UID:%0d(AxId:0x%0h) did not complete DTWRespRecd:%0b DTRReqRecd:%0b", m_ott_q[idx].tb_txnid, m_ott_q[idx].m_id, m_ott_q[match_idxq[0]].tb_txnid,  m_ott_q[match_idxq[0]].m_id, m_ott_q[match_idxq[0]].isSMIDTWRespRecd, m_ott_q[match_idxq[0]].isSMIDTRReqRecd));
				  end  
			  end: _prev_txn_is_atm_
        else begin: _prev_txn_is_non_atm_ 
			 	  if (!m_ott_q[match_idxq[0]].isSMIDTWRespRecd) begin 
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("IOAIUp DTWreq Ordering Violation - UID:%0d(AxId:0x%0h) prematurely sends a DTWreq when an earlier NonCoh Write txn to same Tgt with UID:%0d(AxId:0x%0h) did not complete DTWRespRecd:%0b", m_ott_q[idx].tb_txnid, m_ott_q[idx].m_id, m_ott_q[match_idxq[0]].tb_txnid,  m_ott_q[match_idxq[0]].m_id, m_ott_q[match_idxq[0]].isSMIDTWRespRecd));
				  end  
			  end: _prev_txn_is_non_atm_
		  end: _row3_
    end:_tgt_id_match_
    else begin: _tgt_id_no_match_
      if(!m_ott_q[idx].isCoherent || !m_ott_q[match_idxq[0]].isCoherent) begin : _row_5_6_7_
			  if ((m_ott_q[match_idxq[0]].m_ace_cmd_type inside {ATMLD, ATMCOMPARE, ATMSWAP}) == 1) begin: _prev_txn_is_atm
			 	  if (!m_ott_q[match_idxq[0]].isSMIDTWRespRecd || !m_ott_q[match_idxq[0]].isSMIDTRReqRecd) begin 
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("IOAIUp DTWreq Ordering Violation - UID:%0d(AxId:0x%0h) prematurely sends a DTWreq when an earlier NonCoh Atomic txn to different Tgt with UID:%0d(AxId:0x%0h) did not complete DTWRespRecd:%0b DTRReqRecd:%0b", m_ott_q[idx].tb_txnid, m_ott_q[idx].m_id, m_ott_q[match_idxq[0]].tb_txnid,  m_ott_q[match_idxq[0]].m_id, m_ott_q[match_idxq[0]].isSMIDTWRespRecd, m_ott_q[match_idxq[0]].isSMIDTRReqRecd));
				  end  
			  end: _prev_txn_is_atm
        else begin: _prev_txn_is_non_atm 
			 	  if (!m_ott_q[match_idxq[0]].isSMIDTWRespRecd) begin 
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("IOAIUp DTWreq Ordering Violation - UID:%0d(AxId:0x%0h) prematurely sends a DTWreq when an earlier NonCoh Write txn to differnt Tgt with UID:%0d(AxId:0x%0h) did not complete DTWRespRecd:%0b", m_ott_q[idx].tb_txnid, m_ott_q[idx].m_id, m_ott_q[match_idxq[0]].tb_txnid,  m_ott_q[match_idxq[0]].m_id, m_ott_q[match_idxq[0]].isSMIDTWRespRecd));
				  end  
			  end: _prev_txn_is_non_atm
      end: _row_5_6_7_
    end: _tgt_id_no_match_
  end
            
endfunction: owo_check_axid_ordering_dtwreq

//#Check.IOAIU.OWO.WriteBackOrdering
function void ioaiu_scoreboard::owo_check_axid_ordering_cmdreq(int idx);
    int currtxn_axid    = m_ott_q[idx].m_id;
    int match_idxq[$];
    bit bypass_axid_chk_on_cmo = m_ott_q[idx].isCoherent &&
                            m_ott_q[idx].isSMICMDReqSent &&
                            !m_ott_q[idx].is2ndSMICMDReqSent;

    if (bypass_axid_chk_on_cmo)
        return;

    match_idxq = {};
    match_idxq = m_ott_q.find_index with    ((item.isCoherent ? (item.is2ndSMICMDReqNeeded ? !item.is2ndSMICMDReqSent : 0) :
                                                                (item.isSMICMDReqNeeded ? !item.isSMICMDReqSent : 0)) &&
                                                !item.hasFatlErr &&
                                                !item.dtwrsp_cmstatus_err &&
		                                !item.dtrreq_cmstatus_err &&
                                                !item.dtrreq_cmstatus_err_expcted &&                                                 
                                                item.isWrite &&
                                                (item.m_id  == m_ott_q[idx].m_id)
                                               );

    //The goal of IOAIUp is tto allow coherent writes to stream as fast as
    //possible so there is no STRreq ordering requirement there. Rest all
    //scenarios the ordering point is STReq.
    //#Check.IOAIU.AXID.Ordering_OWO
    if ((match_idxq.size() > 0) && (match_idxq[0] < idx) && (m_ott_q[idx].addrInCSRRegion == 0)) begin // CSR accesses dont get in line for ordering
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("IOAIU_UID:%0d(AxId:0x%0h) prematurely sends a CMDreq when an earlier txn with UID:%0d(AxId:0x%0h) with the same AxID hasn't issued CmdReq", m_ott_q[idx].tb_txnid, m_ott_q[idx].m_id, m_ott_q[match_idxq[0]].tb_txnid,  m_ott_q[match_idxq[0]].m_id));
    end else begin
	//`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d passes axid ordering check", m_ott_q[idx].tb_txnid), UVM_LOW);
    end

    match_idxq = {};
    match_idxq = m_ott_q.find_index with    ((item.isCoherent ? (item.is2ndSMICMDReqNeeded ? item.is2ndSMICMDReqSent : 0) :
                                                                (item.isSMICMDReqNeeded ? item.isSMICMDReqSent : 0)) &&
                                                !item.hasFatlErr &&
                                                !item.dtwrsp_cmstatus_err &&
		                                !item.dtrreq_cmstatus_err &&
                                                !item.dtrreq_cmstatus_err_expcted &&                                                 
                                                !item.isSMISTRReqRecd &&
                                                item.isWrite &&
                                                (item.m_id  == m_ott_q[idx].m_id)
                                               );

    if ((match_idxq.size() > 0) && (match_idxq[0] < idx)) begin
        if (!m_ott_q[idx].isCoherent || !m_ott_q[match_idxq[0]].isCoherent) begin 
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d(AxId:0x%0h)  prematurely sends a CMDreq when an earlier txn with UID:%0d(AxId:0x%0h) with the same AxID issued CmdReq did not receive STRreq", m_ott_q[idx].tb_txnid, m_ott_q[idx].m_id, m_ott_q[match_idxq[0]].tb_txnid,  m_ott_q[match_idxq[0]].m_id));
        end
    end
        
endfunction: owo_check_axid_ordering_cmdreq

function void ioaiu_scoreboard::check_axid_ordering(int idx);
 
    //Check AxId collision
    //#check.IOAIU.AXI.Ordering
    
        int m_tmp_qOrder[$];
        int prevTxn_idx;
        int match_idxq[$];
    int tmp_axid = m_ott_q[idx].m_id;
    bit tmp_isWrite = m_ott_q[idx].isWrite;
    bit tmp_isRead = m_ott_q[idx].isRead;
    TransOrderMode_e transOrderMode = tmp_isRead ? transOrderMode_rd : transOrderMode_wr;
    string cmdType = tmp_isRead ? "RD" : "WR";
    //#Check.IOAIU.AXID.Ordering_StrictReqMode
    if(transOrderMode == strictReqMode) begin
        m_tmp_qOrder = {};
        m_tmp_qOrder = m_ott_q.find_index with ((item.isSMICMDReqNeeded ? item.isSMICMDReqSent == 0 : 0) &&
                                                item.t_creation < m_ott_q[idx].t_creation &&
                                                !item.hasFatlErr &&
                                                !item.dtwrsp_cmstatus_err &&
						!item.dtrreq_cmstatus_err &&
                                                !item.dtrreq_cmstatus_err_expcted &&                                                 
                                                ((tmp_isRead  &&
                                                  item.isRead && 
                                                  item.m_ace_read_addr_pkt.arid === tmp_axid) ||
                                                 (tmp_isWrite  &&
                                                  item.isWrite &&
                                                  item.m_ace_write_addr_pkt.awid == tmp_axid))
                                               );
        
        //check to make sure there are no prior reads/writes with the same AXID that have not yet issued a CMDreq and thus break the AXID Ordering
        //If current txn == Read
    	// -- there are no old Reads with same ARID that have not issued a SMI CMDreq
        //If current txn == Write
    	// -- there are no old Writes with same AWID that have not issued a SMI CMDreq
    	
    //#Check.IOAIU.AXID.Ordering_strictReqMode
        if ((m_tmp_qOrder.size > 0) && (m_ott_q[idx].addrInCSRRegion == 0)) begin // CSR accesses dont get in line for ordering
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Below is the failed Txn(#%0d) (CSR: %1d)", idx, m_ott_q[idx].addrInCSRRegion), UVM_NONE);
            m_ott_q[idx].print_me(0, 1);
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Below is the earlier Txn(#%0d) (CSR: %1d) that with the same AxID but hasn't issued CmdReq", m_tmp_qOrder[0], m_ott_q[m_tmp_qOrder[0]].addrInCSRRegion), UVM_NONE);
            m_ott_q[m_tmp_qOrder[0]].print_me(0, 1);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing SMI %s command request has an AxID(0x%0x) that matches earlier Txn(#%0d) hasn't issued CmdReq (AxID collision violation, TransOrderMode:%s)", cmdType, tmp_axid, m_tmp_qOrder[0], transOrderMode.name()), UVM_NONE);
            
           
        end

        m_tmp_qOrder = {};
        m_tmp_qOrder = m_ott_q.find_index with (item.isSMICMDReqSent                            === 1 &&
                                                item.m_cmd_req_pkt.smi_msg_id                   !== m_ott_q[idx].m_cmd_req_pkt.smi_msg_id &&
                                              item.t_creation < m_ott_q[idx].t_creation &&
                                               item.isSMISTRReqRecd                            === 0 &&
                                                ((tmp_isRead  &&
                                                  item.isRead && 
                                                  ((item.isSMIDTRReqNeeded) ? (item.isSMIDTRReqRecd == 0) : 1) &&
                                                  item.m_ace_read_addr_pkt.arid === tmp_axid) ||
                                                 (tmp_isWrite  &&
                                                  item.isWrite &&
                                                  item.m_ace_write_addr_pkt.awid == tmp_axid))
                                               );
        
      //If current txn == Read
    	// -- there are no old Reads with the same ARID that have issued CMDreq but not received both STRreq and DTRreq, if one of them is received it is OK. 
    	//If current txn == Write
    	// -- there are no old Writes with the same AWID that have issued CMDreq but not received STRreq
    	//#Check.IOAIU.AXID.OrderingQualification_StrictReqMode
        if (m_tmp_qOrder.size > 0) begin
uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Below is the failed Txn(#%0d)",idx), UVM_NONE);
            m_ott_q[idx].print_me(0,1);
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Below is the Txn(#%0d) that hasn't reached the qualified event", m_tmp_qOrder[0]), UVM_NONE);
            m_ott_q[m_tmp_qOrder[0]].print_me(0,1);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing SMI %s command request has an AxID(0x%0x) that matches previously sent SMI command request(#%0d) txn hasn't reached the qualified event (AxID collision violation, TransOrderMode:%s)", cmdType, tmp_axid, m_tmp_qOrder[0], transOrderMode.name()), UVM_NONE);
             
        end
    end // (transOrderMode == strictReqMode)

    if(transOrderMode == pcieOrderMode) begin
        time m_nearest_creation_time;
        bit  has_older_txn;
        
        m_tmp_qOrder = m_ott_q.find_index with ((item.isSMICMDReqNeeded ? item.isSMICMDReqSent === 0 : 0) &&
                                                 item.t_creation < m_ott_q[idx].t_creation &&
                                                !item.hasFatlErr &&
                                                !item.dtwrsp_cmstatus_err &&
                                                !item.dtrreq_cmstatus_err &&
                                                !item.dtrreq_cmstatus_err_expcted &&
                                                ((m_ott_q[idx].gpra_order.readID == 0 &&
                                                  tmp_isRead  &&
                                                  item.isRead &&
                                                  item.m_ace_read_addr_pkt.arid === tmp_axid) ||
                                                 (m_ott_q[idx].gpra_order.writeID == 0 &&
                                                  tmp_isWrite  &&
                                                  item.isWrite &&
                                                  item.m_ace_write_addr_pkt.awid == tmp_axid))
                                               );
        
    	//check to make sure there are no prior reads/writes with the same AXID that have not yet issued a CMDreq and thus break the AXID Ordering
        //If current txn == Read && ReadID==0
    	// -- there are no old Reads with same ARID that have not issued a SMI CMDreq
        //If current txn == Write && WriteID==0
    	// -- there are no old Writes with same AWID that have not issued a SMI CMDreq

    	//#Check.IOAIU.AXID.Ordering_pcieOrderMode
        if (m_tmp_qOrder.size > 0) begin
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Below is the failed Txn(#%0d)", idx), UVM_NONE);
            m_ott_q[idx].print_me(0,1);
            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Below is the Txn(#%0d) that hasn't reached the qualified event", m_tmp_qOrder[0]), UVM_NONE);
            m_ott_q[m_tmp_qOrder[0]].print_me(0, 1);
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Outgoing SMI %s command request has an AxID(0x%0x) that matches earlier Txn(#%0d) hasn't issued CmdReq (GPRA.ReadID:%b, GPRA.WriteID:%b) (PCIE ordering(AxCache:0b%b, GPRA OR:0b%b): TransOrderMode:%s)", cmdType, tmp_axid, m_tmp_qOrder[0], m_ott_q[idx].gpra_order.readID, m_ott_q[idx].gpra_order.writeID, m_ott_q[idx].m_axcache, m_ott_q[idx].gpra_order, transOrderMode.name()), UVM_NONE);
            
        end
        //check for qualified event
        m_tmp_qOrder = {};
        m_tmp_qOrder = m_ott_q.find_index with (item.isSMICMDReqSent                            === 1 &&
                                                item.m_cmd_req_pkt.smi_msg_id                   !== m_ott_q[idx].m_cmd_req_pkt.smi_msg_id &&
                                                item.t_creation < m_ott_q[idx].t_creation &&
                                                item.isSMISTRReqRecd                            === 0 && 
                                                ((m_ott_q[idx].gpra_order.readID == 0 &&
                                                  tmp_isRead  &&
                                                  item.isRead &&
                                                  ((item.isSMIDTRReqNeeded) ? (item.isSMIDTRReqRecd == 0) : 1) &&
                                                  item.m_ace_read_addr_pkt.arid === tmp_axid) ||
                                                 (m_ott_q[idx].gpra_order.writeID == 0 &&
                                                  tmp_isWrite  &&
                                                  item.isWrite &&
                                                  item.m_ace_write_addr_pkt.awid == tmp_axid))
                                               );
        
    	//If current txn == Read && ReadID==0
    	// -- there are no old Reads with the same ARID that have issued CMDreq but not received both STRreq and DTRreq, if one of them is received it is OK. 
    	//If current txn == Write && WriteID==0
    	// -- there are no old Writes with the same AWID that have issued CMDreq but not received STRreq
    	//#Check.IOAIU.AXID.OrderingQualification_pcieOrderMode
        if (m_tmp_qOrder.size > 0) begin
            `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d Outgoing SMI CMDreq has an previous AxID dependency txn IOAIU_UID:%0d that hasn't reached the qualified event (GPRA.ReadID:%b, GPRA.WriteID:%b)(PCIE ordering(AxCache:0b%b, GPRA OR:0b%b): TransOrderMode:%s)", m_ott_q[idx].tb_txnid, m_ott_q[m_tmp_qOrder[0]].tb_txnid, m_ott_q[idx].gpra_order.readID, m_ott_q[idx].gpra_order.writeID, m_ott_q[idx].m_axcache, m_ott_q[idx].gpra_order, transOrderMode.name()));
        end
      
        //HS:08-04-25 below check is redundant. above checks covers it. 
        //all Txns in the same ID chain, currTxn=N dependencyTxn=N-1, previousTxns=N-2 and older
        //STRreq of all previousTxn=N-2 or older must be seen if Wr txn. 
        //STRreq || DTRreq of all previousTxn=N-2 or older must be seen if Rd txn. 
        //m_tmp_qOrder = {};
        //m_tmp_qOrder = m_ott_q.find_index with (item.isSMICMDReqSent                            === 1 &&
        //                                        item.m_cmd_req_pkt.smi_msg_id                   !== m_ott_q[idx].m_cmd_req_pkt.smi_msg_id &&
        //                                        item.t_creation < m_ott_q[idx].t_creation &&
        //                                        ((m_ott_q[idx].gpra_order.readID == 0 &&
        //                                          tmp_isRead  &&
        //                                          item.isRead &&
        //                                          item.m_ace_read_addr_pkt.arid === tmp_axid && !item.isSMISTRReqRecd && !item.isSMIDTRReqRecd) ||
        //                                         (m_ott_q[idx].gpra_order.writeID == 0 &&
        //                                          tmp_isWrite  &&
        //                                          item.isWrite &&
        //                                          item.m_ace_write_addr_pkt.awid == tmp_axid && !item.isSMISTRReqRecd))
        //                                       );

        //if (m_tmp_qOrder.size > 1) begin
        //     prevTxn_idx = m_tmp_qOrder[$] - 1;//idx of previousTxn=N-2
        //    `uvm_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d Outgoing SMI CMDreq is issued prematurely when previous transactions IOAIU_UID:%0d that hasn't reached the qualified event ie got STRreq (GPRA.ReadID:%b, GPRA.WriteID:%b)(PCIE ordering(AxCache:0b%b, GPRA Order:0b%b): TransOrderMode:%s)", m_ott_q[idx].tb_txnid, m_ott_q[prevTxn_idx].tb_txnid, m_ott_q[idx].gpra_order.readID, m_ott_q[idx].gpra_order.writeID, m_ott_q[idx].m_axcache, m_ott_q[idx].gpra_order, transOrderMode.name()));
        //end

        //CONC-17582
        //CONC-17792 Bob confirms there is only STRreq dependency and no
        //expectation of prevTxn DTWrsp
        if (tmp_isWrite && 
            m_ott_q[idx].gpra_order.writeID == 0 && 
            m_ott_q[idx].gpra_order.policy == 3 && 
            m_ott_q[idx].m_axcache[1]) begin

          match_idxq = {};
          match_idxq = m_ott_q.find_index with (
                                                  item.isWrite &&
                                                  item.m_ace_write_addr_pkt.awid == tmp_axid && 
                                                  item.t_creation < m_ott_q[idx].t_creation  &&
                                                  item.isSMICMDReqSent                       &&
                                                  item.m_cmd_req_pkt.smi_msg_id !== m_ott_q[idx].m_cmd_req_pkt.smi_msg_id
                                               );

          foreach (match_idxq[i]) begin
            if (!m_ott_q[match_idxq[i]].isSMISTRReqRecd) begin
                `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("IOAIU_UID:%0d Outgoing SMI CMDreq is issued prematurely when previous transaction IOAIU_UID:%0d that hasn't reached the qualified event ie STRreq recd (GPRA.ReadID:%b, GPRA.WriteID:%b)(PCIE ordering(AxCache:0b%b, GPRA OR:0b%b): TransOrderMode:%s)", m_ott_q[idx].tb_txnid, m_ott_q[match_idxq[i]].tb_txnid, m_ott_q[idx].gpra_order.readID, m_ott_q[idx].gpra_order.writeID, m_ott_q[idx].m_axcache, m_ott_q[idx].gpra_order, transOrderMode.name()));
            end else begin
                //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("IOAIU_UID:%0d Outgoing SMI CMDreq is issued correctly after previous transaction IOAIU_UID:%0d that has reached the qualified event ie DTWreq sent && DTWrsp recd (GPRA.ReadID:%b, GPRA.WriteID:%b)(PCIE ordering(AxCache:0b%b, GPRA OR:0b%b): TransOrderMode:%s)", m_ott_q[idx].tb_txnid, m_ott_q[m_tmp_qOrder[0]].tb_txnid, m_ott_q[idx].gpra_order.readID, m_ott_q[idx].gpra_order.writeID, m_ott_q[idx].m_axcache, m_ott_q[idx].gpra_order, transOrderMode.name()), UVM_NONE);
            end
          end
        end 

    end //(transOrderMode == pcieOrderMode) 
endfunction: check_axid_ordering


<% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.fnNativeInterface === "ACELITE-E" || obj.fnNativeInterface === "ACE-LITE") && aiu_axiInt.params.eAc==1)) { %>
function void ioaiu_scoreboard::write_ace_snoop_addr_chnl(ace_snoop_addr_pkt_t m_pkt);
    int                  m_tmp_q[$];
    int                  m_tmp_qA[$];
    int                  m_tmp_qB[$];
    int                  m_tmp_qDVM[$];
    ace_snoop_addr_pkt_t m_packet;
    smi_msg_type_bit_t   m_msg_smi_snp;
    ioaiu_scb_txn         m_scb_txn;
    ACSNOOP_struct_t     AC_DVM_tmp;

	if (hasErr)
		return;

    if(m_pkt.acsnoop == ACE_DVM_MSG) begin
        AC_DVM_tmp.isDVMMsg = 1;
        if (ACSNOOP_q.size() > 0) begin 
            if(ACSNOOP_q[$].isMultiPartDVM &&
               ACSNOOP_q[$].is1stPartDVM) begin
                AC_DVM_tmp.isMultiPartDVM = 1;
                AC_DVM_tmp.is2ndPartDVM   = 1;
                <%if (Object.keys(DVM_intf).includes(obj.fnNativeInterface)) {%>
                `ifndef FSYS_COVER_ON
                    cov.acaddr = m_pkt.acaddr;
                    //dvm_opType = cov.acaddr[14:12];
                    cov.DVM_snooper_part2_<%=DVM_intf[obj.fnNativeInterface]%>.sample();
                    //$display("KDB00 cvg sample part2 acaddr=%0h", cov.acaddr);
                `endif
            <%if(obj.IO_SUBSYS_SNPS) { %> 
           if (ioaiu_cov_dis==0) begin
                       cov.acaddr = m_pkt.acaddr;
                    cov.DVM_snooper_part2_<%=DVM_intf[obj.fnNativeInterface]%>.sample();
           end
            <% } %>
                <%}%>
                //this is 2nd part of the DVM AC SNOOP - sample the covergroup
                //covergroup ac_snoop_2nd_part_of_multipart_dvm
            end 
            else if (!ACSNOOP_q[$].isMultiPartDVM ||
                     ACSNOOP_q[$].is2ndPartDVM) begin
                <%if (Object.keys(DVM_intf).includes(obj.fnNativeInterface)) {%>
                `ifndef FSYS_COVER_ON
                    cov.acaddr = m_pkt.acaddr;
                    $cast(dvm_opType,cov.acaddr[14:12]);
                    cov.DVM_snooper_part1_<%=DVM_intf[obj.fnNativeInterface]%>.sample();
                    //$display("KDB00 cvg sample part1 acaddr=%0h, DVM_OP_Type=%s", cov.acaddr, dvm_opType);
                `endif
                <%if(obj.IO_SUBSYS_SNPS) { %> 
                 if (ioaiu_cov_dis==0) begin
                     cov.acaddr = m_pkt.acaddr;
                    $cast(dvm_opType,cov.acaddr[14:12]);
                     cov.DVM_snooper_part1_<%=DVM_intf[obj.fnNativeInterface]%>.sample();
                 end
                <% } %>
                <%}%>
                if(m_pkt.acaddr[0]) begin         
                    AC_DVM_tmp.isMultiPartDVM = 1;
                    AC_DVM_tmp.is1stPartDVM = 1;
                    //this is 1st part of multi part DVM AC SNOOP - sample the covergroup
                    //covergroup ac_snoop_1st_part_of_multipart_dvm_or_single_part_dvm
                end else begin 
                    AC_DVM_tmp.isMultiPartDVM = 0;
                    //this is single part DVM AC SNOOP - sample the covergroup
                    //covergroup ac_snoop_single_part_dvm
                end
            end
        end else begin 
            <%if (Object.keys(DVM_intf).includes(obj.fnNativeInterface)) {%>
            `ifndef FSYS_COVER_ON
                cov.acaddr = m_pkt.acaddr;
                $cast(dvm_opType,cov.acaddr[14:12]);
                cov.DVM_snooper_part1_<%=DVM_intf[obj.fnNativeInterface]%>.sample();
                //$display("KDB00 cvg sample part1 acaddr=%0h, DVM_OP_Type=%s", cov.acaddr, dvm_opType);
            `endif
              <%if(obj.IO_SUBSYS_SNPS) { %> 
             if (ioaiu_cov_dis==0) begin
                cov.acaddr = m_pkt.acaddr;
                $cast(dvm_opType,cov.acaddr[14:12]);
                cov.DVM_snooper_part1_<%=DVM_intf[obj.fnNativeInterface]%>.sample();
             end
              <% } %>
            <%}%>
            if(m_pkt.acaddr[0]) begin        
                AC_DVM_tmp.isMultiPartDVM = 1;
                AC_DVM_tmp.is1stPartDVM = 1;
                //this is 1st part of the DVM AC SNOOP - sample the covergroup
                //covergroup ac_snoop_1st_part_of_multipart_dvm_or_single_part_dvm
            end else begin 
                AC_DVM_tmp.isMultiPartDVM = 0;
                //this is single part DVM AC SNOOP - sample the covergroup
                //covergroup ac_snoop_single_part_dvm
            end
        end
        ACSNOOP_q.push_back(AC_DVM_tmp);
        //return; // DVM SNP is handled in ioaiu_new_scoreboard
    end 
    else if (m_pkt.acsnoop == ACE_DVM_CMPL) begin
        AC_DVM_tmp.isDVMComplete = 1;
        AC_DVM_tmp.isMultiPartDVM = 0;
        ACSNOOP_q.push_back(AC_DVM_tmp);
    end 
    else begin
        AC_DVM_tmp.isDVMMsg = 0;
        ACSNOOP_q.push_back(AC_DVM_tmp);
    end

    m_packet = new();
    m_packet.copy(m_pkt);

    if (m_packet.acsnoop == ACE_DVM_MSG) begin
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with ( item.matchACESnpReq(m_packet) );
        if(m_tmp_q.size() == 0) begin
            if(!($test$plusargs("wrong_dtrreq_target_id") || $test$plusargs("inject_smi_uncorr_error")))
               uvm_report_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR",$sformatf("Cannot find matching pkt for ACESnpReq %s",m_packet.sprint_pkt()),UVM_NONE);
        end 
        else begin
            $cast(m_scb_txn,m_ott_q[m_tmp_q[0]]);
            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d Received below %0s <%=obj.fnNativeInterface%>_DVMSnpReq: %0s", m_scb_txn.tb_txnid, (m_scb_txn.smi_exp_flags["ACESnpReqDvm1"]?"1st":"2nd"), m_packet.sprint_pkt()), UVM_LOW)
            if(m_scb_txn.smi_exp_flags["ACESnpReqDvm1"]) begin
                for(int idx = 0; idx < m_ott_q.size(); idx++) begin
                    if(idx == m_tmp_q[0]) continue;
                    else begin
                        if( m_ott_q[idx].smi_flags["ACESnpReqDvm1"] && 
                        (m_ott_q[idx].smi_flags["single_part_dvm"] ? 0 : !m_ott_q[idx].smi_flags["ACESnpReqDvm2"]))
                            uvm_report_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR",$sformatf("DVM SnpReq interleaving failure %s",m_packet.sprint_pkt()),UVM_NONE,"ACESnpReqInterleave");
                        if(m_ott_q[idx].smi_exp_flags["ACESnpReqDvm1"] && 
                        m_ott_q[idx].t_creation < m_ott_q[m_tmp_q[0]].t_creation) begin
                            uvm_report_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR",$sformatf("DVM ACE AC SnpReq violates the Age ordering for Txn#%0d. The Txn#%0d DVM AC snoop should send first. The failed AC transaction: %s", m_tmp_q[0], idx, m_packet.sprint_pkt()),UVM_NONE,"ACESnpReqAgeOrdering");
                        end
                    end
                end //for(int idx = 0; idx < m_ott_q.size(); idx++) begin
            end // if(m_scb_txn.smi_exp_flags["ACESnpReqDvm1"]) begin
          
           
            ACSNOOP_q[$].tb_txnid = m_scb_txn.tb_txnid;
            m_scb_txn.setup_ace_dvm_snp_req(m_packet);
            //KDB - Check with Hema, Since the pcket matched, we are returning
            return;
        end //if(m_tmp_q.size() == 0) begin
    end
     
<% if(obj.COVER_ON) { %>
    `ifndef FSYS_COVER_ON
    cov.collect_ace_snoop_addr(m_packet, core_id);
    `endif
     <%if(obj.IO_SUBSYS_SNPS) { %> 
    if (ioaiu_cov_dis==0) begin
    cov.collect_ace_snoop_addr(m_packet, core_id);
    end
     <% } %>
<% } %>       

    //map ACE ACSNOOP to SMI SNP
    `ifdef VCS
    m_scb_txn = new(,m_req_aiu_id,csr_ccp_lookupen,csr_ccp_allocen, csr_ccp_updatedis, ,core_id);
    `endif
    m_msg_smi_snp = m_scb_txn.mapAceSnpToSNPreq(m_packet.acsnoop);

    //check no AC SNP to the same address that has RACK/WACK pending

    m_tmp_qA = {};
    m_tmp_qA = m_ott_q.find_index with ((item.isRead === 1               &&
					 !(item.m_ace_cmd_type inside{DVMMSG,DVMCMPL}) &&
                                         item.m_ace_read_addr_pkt.araddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] === m_packet.acaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && 
                                         <% if (obj.wSecurityAttribute > 0) { %>
                                         item.m_ace_read_addr_pkt.arprot[1] === m_packet.acprot[1] &&
                                         <% } %>
                                         item.isACEReadDataSentNoRack === 1) ||//item.isRead
                                        (item.isWrite === 1 &&
                                         item.m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] === m_packet.acaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && 
                                         <% if (obj.wSecurityAttribute > 0) { %>
                                         item.m_ace_write_addr_pkt.awprot[1] === m_packet.acprot[1] &&
                                         <% } %>
                                         item.isACEWriteRespSentNoWack === 1) //item.isWrite

                                       );
    if(m_tmp_qA.size != 0) begin
    	`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Received below <%=obj.fnNativeInterface%>_SnpReq:%0s", m_packet.sprint_pkt()) ,UVM_LOW);
        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Found %0d pending ACE WR/RD transaction with the same address as ACE snoop packet. Printing them below", m_tmp_qA.size()));
        foreach(m_tmp_qA[idx])
            m_ott_q[m_tmp_qA[idx]].print_me();
        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("There are some outstanding ACE WR/RD traffic with the same address as ACE snoop packet. addr = 0x%h", m_packet.acaddr), UVM_NONE);
    end
    m_tmp_qA = {};
    m_tmp_qA = m_ott_q.find_index with ((item.isSnoop                                 === 1               &&
                                         item.isSMISNPRespSent                        === 0               &&
                                         item.isACESnoopReqSent                       === 0               &&
                                         ((item.m_snp_req_pkt.smi_msg_type  === m_msg_smi_snp)    ||
                                          (item.m_snp_req_pkt.smi_msg_type  === eSnpRecall &&
                                           m_packet.acsnoop                 === ACE_CLEAN_INVALID)||
                                          (item.m_snp_req_pkt.smi_msg_type  === eSnpInvStsh &&
                                           m_packet.acsnoop                 === ACE_MAKE_INVALID) ||
                                           //CONC-7381
                                          /* (item.m_snp_req_pkt.smi_msg_type  === eSnpStshShd && */
                                          /*  m_packet.acsnoop                 === ACE_CLEAN_SHARED) || */
                                          ((item.m_snp_req_pkt.smi_msg_type === eSnpNITCCI ||
                                            item.m_snp_req_pkt.smi_msg_type === eSnpNITCMI ||
                                            item.m_snp_req_pkt.smi_msg_type === eSnpUnqStsh||
                                            item.m_snp_req_pkt.smi_msg_type === eSnpStshShd||
                                            item.m_snp_req_pkt.smi_msg_type === eSnpStshUnq) &&
                                           m_packet.acsnoop                 === ACE_CLEAN_INVALID))      &&
                                         item.m_snp_req_pkt.smi_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)]   === m_packet.acaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] && //TODO: BING check whether acaddr needs to align to cacheline size
                                         <% if (obj.wSecurityAttribute > 0) { %>
                                         item.m_snp_req_pkt.smi_ns === m_packet.acprot[1] &&
                                         <% } %>
                                         item.isDVM                                === 0) //item.isSnoop 
					|| (item.isRead && (item.m_ace_cmd_type == DVMMSG) && item.isDVMSync &&
                                            (m_packet.acsnoop == ACE_DVM_CMPL) &&
                                            (m_packet.acaddr == '0) &&
					    !item.isACESnoopReqSent && item.isSMICMPRespRecd) 
                                        );
    

    if (m_tmp_qA.size === 0) begin
        m_tmp_qB = {};
        m_tmp_qB = m_ott_q.find_index with (item.isSnoop === 1 && item.m_snp_req_pkt.smi_addr === m_packet.acaddr);
        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Found %0d SMI snoop packets with the same address as ACE snoop packet. Printing them below", m_tmp_qB.size()));
        for (int i = 0; i < m_tmp_qB.size(); i++) begin
            m_ott_q[m_tmp_qB[i]].print_me();
        end
        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Cannot find a corresponding transaction for the above ACE snoop packet. %s", m_packet.sprint_pkt()), UVM_NONE);
        if(!$test$plusargs("wrong_dtwrsp_target_id") && !$test$plusargs("wrong_dtrrsp_target_id") && !$test$plusargs("wrong_dtrreq_target_id") && !$test$plusargs("wrong_sysreq_target_id") && !$test$plusargs("wrong_sysrsp_target_id") && !$test$plusargs("wrong_DtwDbg_rsp_target_id") && !$test$plusargs("gpra_secure_uncorr_err") && !$test$plusargs("inject_smi_uncorr_error")) begin
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Cannot find a corresponding transaction for the above ACE snoop packet"), UVM_NONE);
        end
    end
    else if (m_tmp_qA.size > 1) begin
        for (int i = 0; i < m_tmp_qA.size; i++) begin
            m_ott_q[m_tmp_qA[i]].print_me();
        end
        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Found multiple corresponding transactions for the above ACE snoop packet. %s", m_packet.sprint_pkt()), UVM_NONE);
        if(!$test$plusargs("inject_smi_uncorr_error"))
        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Found multiple corresponding transactions for the above ACE snoop packet"), UVM_NONE);
    end
    else begin
       `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below <%=obj.fnNativeInterface%>_SnpReq:%0s", m_ott_q[m_tmp_qA[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_packet.sprint_pkt()) ,UVM_LOW);
        ACSNOOP_q[$].tb_txnid = m_ott_q[m_tmp_qA[0]].tb_txnid;

        //check AC snoop ordering
        if(m_packet.acsnoop != ACE_DVM_CMPL) begin
            // CONC-8911: checking snoop address formatting
            m_ott_q[m_tmp_qA[0]].check_snoop_address(.ac_addr(m_packet.acaddr), .ac_datawidth(<%=obj.wData%>));
            foreach(m_ott_q[idx]) begin
               if(idx == m_tmp_qA[0]) continue;
               else begin
                   if( m_ott_q[idx].isSnoop &&
                       !m_ott_q[idx].isACESnoopReqSent &&
                       m_ott_q[idx].t_creation < m_ott_q[m_tmp_qA[0]].t_creation) begin
                       if (!$test$plusargs("inject_smi_uncorr_error"))
	               uvm_report_error("IOAIU_SCB_<%=obj.BlockId%>_ERROR",$sformatf("ACE AC SnpReq violates the Age ordering for Txn#%0d. The Txn#%0d AC snoop should send first. The failed AC transaction: %s", m_tmp_qA[0], idx, m_packet.sprint_pkt()),UVM_NONE);
                   end
               end
            end
        end
        m_ott_q[m_tmp_qA[0]].setup_ace_snoop_addr(m_packet);
        if(m_ott_q[m_tmp_qA[0]].m_ace_cmd_type == DVMMSG &&
           m_ott_q[m_tmp_qA[0]].isDVMSync) begin
            if(m_packet.acsnoop != 4'b1110) begin
                uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("%s", m_packet.sprint_pkt()), UVM_NONE);
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Expected to receive SNP Complete command for ACE DVM Sync command(Exp acsnoop 4'b1110, real arsnoop 4'b%b", m_packet.acsnoop), UVM_NONE);
            end
            //DVM Order check
            if(dvm_resp_order) begin
                m_tmp_qDVM = {};
                m_tmp_qDVM = m_ott_q.find_index with (item.m_ace_cmd_type == DVMMSG &&
                                                      (item.isDVMMultiPart ? item.isACEReadDataDVMMultiPartSentNoRack : item.isACEReadDataSentNoRack) &&
                                                      item.t_creation < m_ott_q[m_tmp_qA[0]].t_creation);
                if(m_tmp_qDVM.size > 0) begin
	            uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Found DVM Order Violation in AC channel(DVMCMPL)! RTL sends DVMCMPL(coordinate to DVMSYNC)(Txn #%0d) before finishes previous DVM operations(Txn #%0d)",m_tmp_qA[0], m_tmp_qDVM[0]),UVM_NONE);
                    foreach(m_tmp_qDVM[idx])
                        m_ott_q[m_tmp_qDVM[idx]].print_me();
	            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Found DVM Order Violation in AC channel(DVMCMPL)!"),UVM_NONE);
                end
            end
        end
        //if(m_ott_q[m_tmp_qA[0]].m_ace_cmd_type != DVMMSG) begin
        //    m_ott_q[m_tmp_qA[0]].checkACESnpAddr($sformatf("OutstTxn #%0d",m_tmp_qA[0]));
        //end
    end
endfunction:write_ace_snoop_addr_chnl

function void ioaiu_scoreboard::write_ace_snoop_resp_chnl(ace_snoop_resp_pkt_t m_pkt);
    ace_snoop_resp_pkt_t m_packet;
    int                  m_tmp_qA[$];
    int                  oldest_tb_txnid;
    ace_snoop_data_pkt_t m_data_packet;

	if (hasErr)
		return;

    if (ACSNOOP_q.size === 0) begin
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("Received below <%=obj.fnNativeInterface%>_SnpResp:%0s", m_pkt.sprint_pkt()) ,UVM_NONE);
        if(!$test$plusargs("wrong_dtwrsp_target_id") && !$test$plusargs("inject_smi_uncorr_error") && !$test$plusargs("wrong_dtrrsp_target_id") && !$test$plusargs("wrong_dtrreq_target_id") && !$test$plusargs("wrong_sysreq_target_id") && !$test$plusargs("wrong_sysrsp_target_id") && !$test$plusargs("wrong_DtwDbg_rsp_target_id")) begin
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Empty ACSNOOP_q, Cannot find a matching ACE snoop request for above ACE snoop response"), UVM_NONE);
        end
    end
    if(ACSNOOP_q[0].isDVMMsg) begin
        if(!ACSNOOP_q[0].isMultiPartDVM) begin
            oldest_tb_txnid = ACSNOOP_q[0].tb_txnid;
            void'(ACSNOOP_q.pop_front());
        end else begin
            if(ACSNOOP_q[0].is1stPartDVM &&
               ACSNOOP_q[0].isDVMCrRspRcvd) begin
                //Add check for q.size>=2
                void'(ACSNOOP_q.pop_front());
                oldest_tb_txnid = ACSNOOP_q[0].tb_txnid;
                void'(ACSNOOP_q.pop_front()); //delete both 1st and 2nd part DVM
            end else begin
                oldest_tb_txnid = ACSNOOP_q[0].tb_txnid;
                ACSNOOP_q[0].isDVMCrRspRcvd = 1;
            end
        end
        //return;
    end else if (ACSNOOP_q[0].isDVMComplete) begin
        oldest_tb_txnid = ACSNOOP_q[0].tb_txnid;
        void'(ACSNOOP_q.pop_front());
    end else begin
        oldest_tb_txnid = ACSNOOP_q[0].tb_txnid;
        void'(ACSNOOP_q.pop_front());
    end

    m_packet = new();
    m_packet.copy(m_pkt);
    
<% if(obj.COVER_ON) { %>
    `ifndef FSYS_COVER_ON
    cov.collect_ace_snoop_resp(m_pkt, null, core_id);
    `endif
     <%if(obj.IO_SUBSYS_SNPS) { %> 
    if (ioaiu_cov_dis==0) begin
    cov.collect_ace_snoop_resp(m_pkt, null, core_id);
    end
     <% } %>
<% } %>       

    m_tmp_qA = m_ott_q.find_index with (item.tb_txnid == oldest_tb_txnid);
    //oldest_tb_txnid can never be 0 because 0 txn is always SYSREQ cmd and it means no AC Snoop Msg was matched to the pushed pkt in ACSNOOP_q in write_ace_snoop_addr_chnl()
    if (oldest_tb_txnid == 0) begin
        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Cannot find a matching ACE snoop request for ACE snoop response: %s", m_packet.sprint_pkt()), UVM_NONE);
        if(!$test$plusargs("wrong_dtwrsp_target_id") && !$test$plusargs("wrong_dtrrsp_target_id") && !$test$plusargs("wrong_dtrreq_target_id") && !$test$plusargs("wrong_sysreq_target_id") && !$test$plusargs("wrong_sysrsp_target_id") && !$test$plusargs("wrong_DtwDbg_rsp_target_id") && !$test$plusargs("gpra_secure_uncorr_err") && !$test$plusargs("inject_smi_uncorr_error")) begin
            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Cannot find a matching ACE snoop request for above ACE snoop response"), UVM_NONE);
        end
    end
    else if (m_ott_q[m_tmp_qA[0]].smi_exp_flags["ACESnpRspDvm1"]  == 1 || m_ott_q[m_tmp_qA[0]].smi_exp_flags["ACESnpRspDvm2"]  == 1) begin
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below %0s <%=obj.fnNativeInterface%>_DVMSnpResp:%0s", m_ott_q[m_tmp_qA[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, (m_ott_q[m_tmp_qA[0]].smi_flags["ACESnpRspDvm1"]?"2nd":"1st"), m_packet.sprint_pkt()) ,UVM_LOW);
		m_ott_q[m_tmp_qA[0]].setup_ace_dvm_snp_rsp(m_packet);
        if (m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt0_act.crresp[CCRRESPERRBIT] === 1) begin           		
       		snoop_rsp_err_info.push_back(m_ott_q[m_tmp_qA[0]]);
                    ev_snoop_rsp_err_dvm.trigger();
 		    if(m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt0_act.crresp[CCRRESPERRBIT] === 1 && m_ott_q[m_tmp_qA[0]].txn_type == "DVMSYNC") begin
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Above snoop response has Error = 1 for snooptype=DVMSYNC, which is illegal as per ACE protocol. Check ARM IHI 0022E C12.3.4 Transaction response"), UVM_NONE);
  		    end
        end else if (m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt1_act) begin:_pkt1_exist
	        if (m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt1_act.crresp[CCRRESPERRBIT] === 1) begin
                snoop_rsp_err_info.push_back(m_ott_q[m_tmp_qA[0]]);
                    ev_snoop_rsp_err_dvm.trigger();
		        if(m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt1_act.crresp[CCRRESPERRBIT] === 1 && m_ott_q[m_tmp_qA[0]].txn_type == "DVMSYNC") begin
                    uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Above snoop response has Error = 1 for snooptype=DVMSYNC, which is illegal as per ACE protocol. Check ARM IHI 0022E C12.3.4 Transaction response"), UVM_NONE);
  		        end
		    end
		end:_pkt1_exist
     	if ((m_ott_q[m_tmp_qA[0]].txn_type == "DVMSYNC") &&
        	(m_ott_q[m_tmp_qA[0]].smi_flags["single_part_dvm"] ? m_ott_q[m_tmp_qA[0]].smi_flags["ACESnpRspDvm1"]:m_ott_q[m_tmp_qA[0]].smi_flags["ACESnpRspDvm2"])
       		) begin
        	m_num_dvm_snp_sync_cr_resp++;
        	uvm_report_info("IOAIU_SCB_<%=obj.BlockId%>",$sformatf("Received last(single: 1st/multi: 2nd) ACE DVM SNP Rsp for DVM SYNC, m_num_dvm_snp_sync_cr_resp = %0d", m_num_dvm_snp_sync_cr_resp),UVM_DEBUG);
    	end
        <%if(obj.COVER_ON && obj.eAc && ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E"))) { %>
          //FIXME - Kavish - fix the argument category from ioaiu_celite_scb_txn to ioaiu_scb_txn
          //cov.collect_ace_snoop_resp_with_req(null,null, m_ott_q[m_tmp_qA[0]], 0);
          //cov.collect_ace_snoop_resp(null, m_ott_q[m_tmp_qA[0]], 0);
        <% } %>
    end else begin
        //m_tmp_qA[0] = find_oldest_ac_in_ott_q(m_tmp_qA);
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below <%=obj.fnNativeInterface%>_SnpResp:%0s", m_ott_q[m_tmp_qA[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,m_packet.sprint_pkt()) ,UVM_LOW);
        m_ott_q[m_tmp_qA[0]].setup_ace_snoop_resp(m_packet);
        /* uvm_report_info("<%=obj.strRtlNamePrefix%> SCB IN_WB_WC",$sformatf("Received CRRESP:0x%0x which is for ACADDR: 0x%0x", m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt.crresp, m_ott_q[m_tmp_qA[0]].m_ace_snoop_addr_pkt.acaddr), UVM_NONE); */
        if(m_ott_q[m_tmp_qA[0]].m_ace_cmd_type == DVMMSG &&
           m_ott_q[m_tmp_qA[0]].isDVMSync &&
           m_ott_q[m_tmp_qA[0]].isSMISTRRespSent) begin
            delete_ott_entry(m_tmp_qA[0], AceSnpRsp);
            return;
        end
        
        if (m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt.crresp[CCRRESPERRBIT] === 1) begin
          ev_snoop_rsp_err.trigger();
          snoop_rsp_err_info.push_back(m_ott_q[m_tmp_qA[0]]);
        end
        check_ace_snoop_resp(m_ott_q[m_tmp_qA[0]]);
        if (m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt.crresp[CCRRESPDATXFERBIT] === 1) begin
            m_ott_q[m_tmp_qA[0]].isACESnoopDataNeeded = 1;
            if (m_oasd_q.size > 0) begin
                m_data_packet = m_oasd_q.pop_front();
                ->e_queue_delete;
                m_ott_q[m_tmp_qA[0]].setup_ace_snoop_data(m_data_packet);
            end
        end
    end
`ifdef USE_VIP_SNPS
    ev_snoop_rsp.trigger(m_ott_q[m_tmp_qA[0]].m_ace_snoop_addr_pkt);
`endif
<% if(obj.COVER_ON) { %>
    if(m_ott_q[m_tmp_qA[0]].m_ace_snoop_addr_pkt)
      `ifndef FSYS_COVER_ON
      cov.collect_ace_snoop_resp_with_req(m_pkt, m_ott_q[m_tmp_qA[0]].m_ace_snoop_addr_pkt,null, core_id);
      `endif
     <%if(obj.IO_SUBSYS_SNPS) { %> 
    if (ioaiu_cov_dis==0) begin
      cov.collect_ace_snoop_resp_with_req(m_pkt, m_ott_q[m_tmp_qA[0]].m_ace_snoop_addr_pkt,null, core_id);
    end
     <% } %>
<% } %>
        //#Check.IOAIU.CRTRACE
        <%if(aiu_axiInt.params.eTrace > 0) { %>
            uvm_config_db#(int)::get(null, "*", "ioaiu_cctrlr_phase", ioaiu_cctrlr_phase);
	    if (m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt != null)begin
	    	//`uvm_info("IOAIU_SCB_1_0", $psprintf("isACESnoopRespRecd:%0d crtrace:%0d", m_ott_q[m_tmp_qA[0]].isACESnoopRespRecd,m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt.crtrace) ,UVM_NONE);
            end

            if(m_ott_q[m_tmp_qA[0]].isACESnoopRespRecd && m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt.crtrace && (m_ott_q[m_tmp_qA[0]].tctrlr[0].native_trace_en || native_trace_CONC_7813)) begin
		//`uvm_info("IOAIU_SCB_2", $psprintf("isACESnoopRespRecd:%0d crtrace:%0d", m_ott_q[m_tmp_qA[0]].isACESnoopRespRecd,m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt.crtrace) ,UVM_NONE);
                if(m_packet.crtrace != 1 && !$test$plusargs("inject_smi_uncorr_error")) begin
                    if (!($test$plusargs("ioaiu_cctrlr_mod") && (ioaiu_cctrlr_phase==1 || ioaiu_cctrlr_phase==2))) begin
                          m_ott_q[m_tmp_qA[0]].print_me();
                          uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE snoop response CRTrace is wrong(Txn#%0d). Expected value is 1. Real value is: %0b. CRTrace: %0b. tctrlr[0].native_trace_en: %0b", m_tmp_qA[0], m_packet.crtrace, m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt.crtrace, m_ott_q[m_tmp_qA[0]].tctrlr[0].native_trace_en), UVM_NONE);
                    end
                end
            end
            else begin
                if(m_packet.crtrace != 0) begin
		//`uvm_info("IOAIU_SCB_3", $psprintf("isACESnoopRespRecd:%0d crtrace:%0d", m_ott_q[m_tmp_qA[0]].isACESnoopRespRecd,m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt.crtrace) ,UVM_NONE);
                    if (!($test$plusargs("ioaiu_cctrlr_mod") && (ioaiu_cctrlr_phase==1 || ioaiu_cctrlr_phase==2))) begin
                        m_ott_q[m_tmp_qA[0]].print_me();
                        if(m_ott_q[m_tmp_qA[0]].isACESnoopRespRecd && !$test$plusargs("inject_smi_uncorr_error")) begin
                            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE snoop response CRTrace is wrong(Txn#%0d). Expected value is 0. Real value is: %0b. CRTrace: %0b. tctrlr[0].native_trace_en: %0b", m_tmp_qA[0], m_packet.crtrace, m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt.crtrace, m_ott_q[m_tmp_qA[0]].tctrlr[0].native_trace_en), UVM_NONE);
                        end
                    end 
                end
            end

        <% if(obj.COVER_ON) { %>
        	`ifndef FSYS_COVER_ON
                if(m_ott_q[m_tmp_qA[0]].tctrlr[0].native_trace_en) 
                cov.collect_trace_cap(m_ott_q[m_tmp_qA[0]]);
                `endif
                <%if(obj.IO_SUBSYS_SNPS) { %> 
                 if (ioaiu_cov_dis==0) begin
                     if(m_ott_q[m_tmp_qA[0]].tctrlr[0].native_trace_en) 
                     cov.collect_trace_cap(m_ott_q[m_tmp_qA[0]]);
                 end
                <% } %>
                <% } %>
	    <%}%>
    
endfunction:write_ace_snoop_resp_chnl

function void ioaiu_scoreboard::write_ace_snoop_data_chnl(ace_snoop_data_pkt_t m_pkt);
    ace_snoop_data_pkt_t m_packet;
    int                  m_tmp_qA[$];
    int                  m_tmp_qB[$];

	if (hasErr)
		return;

    m_packet = new();
    m_packet.copy(m_pkt);

<% if(obj.COVER_ON) { %>
    `ifndef FSYS_COVER_ON
    cov.collect_ace_snoop_data(m_pkt, core_id);
    `endif
     <%if(obj.IO_SUBSYS_SNPS) { %> 
    if (ioaiu_cov_dis==0) begin
       cov.collect_ace_snoop_data(m_pkt, core_id);
    end
     <% } %>
<% } %>  

    m_tmp_qA = {};
    m_tmp_qA = m_ott_q.find_index with (item.isSnoop              === 1 &&
                                        item.isACESnoopReqSent    === 1 &&
                                        item.isACESnoopRespRecd   === 1 &&
                                        item.isACESnoopDataNeeded === 1 &&
                                        item.isACESnoopDataRecd   === 0
                                       );
    // Below to check if snoop response has not been received yet
    // ACE snoop data raced the ACE snoop response
    if (m_tmp_qA.size === 0) begin
        m_tmp_qB = {};
        // Sanity check to make sure there are outstanding snoops that were sent
        // for which this data could potentially be a match to
        m_tmp_qB = m_ott_q.find_index with (item.isSnoop            === 1 &&
                                            item.isACESnoopReqSent  === 1 &&
                                            item.isACESnoopRespRecd === 0
                                            );
        if (m_tmp_qB.size === 0) begin
			`uvm_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("Received below <%=obj.fnNativeInterface%>_SnpData:%0s", m_packet.sprint_pkt()) ,UVM_NONE);
            if(!$test$plusargs("wrong_dtwrsp_target_id") && !$test$plusargs("wrong_dtrrsp_target_id") && !$test$plusargs("wrong_dtrreq_target_id") && !$test$plusargs("wrong_sysreq_target_id") && !$test$plusargs("wrong_sysrsp_target_id") && !$test$plusargs("wrong_DtwDbg_rsp_target_id")) begin
                uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Above ACE snoop data packet does not match any outstanding ACE snoops"), UVM_NONE);
            end
        end
        // Adding data to oasd_q to await snoop response before matching
        m_oasd_q.push_back(m_packet);
        ->e_queue_add;
    end
    else begin
        m_tmp_qA[0] = find_oldest_ac_in_ott_q(m_tmp_qA);
		`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Received below <%=obj.fnNativeInterface%>_SnpData:%0s", m_ott_q[m_tmp_qA[0]].tb_txnid<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>, m_packet.sprint_pkt()) ,UVM_LOW);
        m_ott_q[m_tmp_qA[0]].setup_ace_snoop_data(m_packet);
        <% if (obj.useCleanDirtyInterface) { %>
            foreach (m_ott_q[m_tmp_qA[0]].m_dirty_byte[i]) begin
                if (m_ott_q[m_tmp_qA[0]].m_dirty_byte[i] != '0) begin
                    if (!m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt.crresp[CCRRESPPASSDIRTYBIT]) begin
                        m_ott_q[m_tmp_qA[0]].print_me();
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("CleanDirtyInterface: DirtyByte is non-zero, but passdirty is not set (DirtyByte: 0x%0x beat:0x%0x)", m_ott_q[m_tmp_qA[0]].m_dirty_byte[i],i), UVM_NONE);
                    end
                end
            end
        <% } %>
    end
    //#Check.IOAIU.CDTRACE
        <%if(aiu_axiInt.params.eTrace > 0) { %>
           uvm_config_db#(int)::get(null, "*", "ioaiu_cctrlr_phase", ioaiu_cctrlr_phase);
	   if (m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt != null)begin
		//`uvm_info("IOAIU_SCB_1_1", $psprintf("isACESnoopRespRecd:%0d crtrace:%0d", m_ott_q[m_tmp_qA[0]].isACESnoopRespRecd,m_ott_q[m_tmp_qA[0]].m_ace_snoop_resp_pkt.crtrace) ,UVM_NONE);
           end

           if(m_ott_q[m_tmp_qA[0]].isACESnoopDataRecd && m_ott_q[m_tmp_qA[0]].m_ace_snoop_data_pkt.cdtrace && (m_ott_q[m_tmp_qA[0]].tctrlr[0].native_trace_en || native_trace_CONC_7813)) begin
		//`uvm_info("IOAIU_SCB_5", $psprintf("isACESnoopDataRecd:%0d cdtrace:%0d", m_ott_q[m_tmp_qA[0]].isACESnoopDataRecd,m_ott_q[m_tmp_qA[0]].m_ace_snoop_data_pkt.cdtrace) ,UVM_NONE);
                if(m_packet.cdtrace != 1) begin
                    if (!($test$plusargs("ioaiu_cctrlr_mod") && (ioaiu_cctrlr_phase==1 || ioaiu_cctrlr_phase==2))) begin
                        m_ott_q[m_tmp_qA[0]].print_me();
                        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE snoop response CDTrace is wrong(Txn#%0d). Expected value is 1. Real value is: %0b. CDTrace: %0b. tctrlr[0].native_trace_en: %0b", m_tmp_qA[0], m_packet.cdtrace, m_ott_q[m_tmp_qA[0]].m_ace_snoop_data_pkt.cdtrace, m_ott_q[m_tmp_qA[0]].tctrlr[0].native_trace_en), UVM_NONE);
                    end
                end
            end
            else begin
                if(m_packet.cdtrace != 0) begin
		//`uvm_info("IOAIU_SCB_6", $psprintf("isACESnoopDataRecd:%0d cdtrace:%0d", m_ott_q[m_tmp_qA[0]].isACESnoopDataRecd,m_ott_q[m_tmp_qA[0]].m_ace_snoop_data_pkt.cdtrace) ,UVM_NONE);
                    if (!($test$plusargs("ioaiu_cctrlr_mod") && (ioaiu_cctrlr_phase==1 || ioaiu_cctrlr_phase==2))) begin
                        m_ott_q[m_tmp_qA[0]].print_me();
                        if(m_ott_q[m_tmp_qA[0]].isACESnoopDataRecd) begin
                            uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("ACE snoop response CDTrace is wrong(Txn#%0d). Expected value is 0. Real value is: %0b. CDTrace: %0b. tctrlr[0].native_trace_en: %0b", m_tmp_qA[0], m_packet.cdtrace, m_ott_q[m_tmp_qA[0]].m_ace_snoop_data_pkt.cdtrace, m_ott_q[m_tmp_qA[0]].tctrlr[0].native_trace_en), UVM_NONE);
                       end
                    end 
                end
            end

        <% if(obj.COVER_ON) { %>
        	`ifndef FSYS_COVER_ON
                if(m_ott_q[m_tmp_qA[0]].tctrlr[0].native_trace_en) 
                cov.collect_trace_cap(m_ott_q[m_tmp_qA[0]]);
                `endif
             <%if(obj.IO_SUBSYS_SNPS) { %> 
                if (ioaiu_cov_dis==0) begin
                    if(m_ott_q[m_tmp_qA[0]].tctrlr[0].native_trace_en) 
                    cov.collect_trace_cap(m_ott_q[m_tmp_qA[0]]);
                end
              <% } %>
                <% } %>
	    <%}%>
endfunction:write_ace_snoop_data_chnl
<% } %>

function void ioaiu_scoreboard::update_resiliency_ce_cnt(const ref smi_seq_item m_item);
<%  if ((obj.useResiliency) && ((obj.testBench != "fsys") && (obj.testBench != "emu") && (obj.testBench != "emu_t"))) { %>
  int tmp_dp_corr_error;
  string func_s = "update_resiliency_ce_cnt";

  `uvm_info({func_s}, $sformatf("time1 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
  res_smi_pkt_time_new = $realtime;
  if(res_smi_pkt_time_new != res_smi_pkt_time_old) begin
    // get error statistics
    if(m_item.ndp_corr_error || m_item.hdr_corr_error || m_item.dp_corr_error_eb) begin
      res_smi_corr_err++;
      if(m_item.dp_corr_error_eb) begin
        res_smi_corr_err = res_smi_corr_err + (m_item.dp_corr_error_eb-1);
        res_mod_dp_corr_error = m_item.dp_corr_error_eb;
        `uvm_info({func_s}, $sformatf("(if/if)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
      end
      res_is_pre_err_pkt = 1'b1;
      `uvm_info({func_s}, $sformatf("new smi_pkt(if). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
    end else begin
      res_is_pre_err_pkt = 1'b0;
    end
    `uvm_info({func_s}, $sformatf("time2 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
  end else begin
    if(res_is_pre_err_pkt) begin
      if(m_item.dp_corr_error_eb) begin
        tmp_dp_corr_error = m_item.dp_corr_error_eb - this.res_mod_dp_corr_error;
        if(tmp_dp_corr_error < 0)
          tmp_dp_corr_error = 1'b0;
        else
          this.res_mod_dp_corr_error = this.res_mod_dp_corr_error + tmp_dp_corr_error;
        `uvm_info({func_s}, $sformatf("(else/if)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
        res_smi_corr_err = res_smi_corr_err + tmp_dp_corr_error;
      end
      `uvm_info({func_s}, $sformatf("new smi_pkt(else/if). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
    end else begin
      if(m_item.ndp_corr_error || m_item.hdr_corr_error || m_item.dp_corr_error_eb) begin
        res_smi_corr_err++;
        if(m_item.dp_corr_error_eb) begin
          res_smi_corr_err = res_smi_corr_err + (m_item.dp_corr_error_eb-1);
          res_mod_dp_corr_error = m_item.dp_corr_error_eb;
          `uvm_info({func_s}, $sformatf("(else/else)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
        end
        res_is_pre_err_pkt = 1'b1;
      end
      `uvm_info({func_s}, $sformatf("new smi_pkt(else/else). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
    end
    `uvm_info({func_s}, $sformatf("time3 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
  end
  res_smi_pkt_time_old = res_smi_pkt_time_new;
  `uvm_info({func_s}, $sformatf("time4 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
<% } %>
endfunction : update_resiliency_ce_cnt

//#Check.IOAIU.Response_Ordering
function void ioaiu_scoreboard::check_response_ordering(int ottq_idx);
	int matchq[$];
	
	if (m_ott_q[ottq_idx].isRead) begin 

		matchq = {};

		//#Check.IOAIU.ReadResponse_OrderingCheck
		//find an older read txn with same arid that has not yet sent back a RResp
		matchq = m_ott_q.find_index(item) with (item.isRead &&
												item.m_id == m_ott_q[ottq_idx].m_id &&
(!item.isMultiAccess || (item.m_multiline_tracking_id != m_ott_q[ottq_idx].m_multiline_tracking_id)) && 
												!item.isACEReadDataSent &&
												item.t_ace_read_recd < m_ott_q[ottq_idx].t_ace_read_recd
											   );

		if (matchq.size() > 0) begin 
			uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Read Response Order Violation! OutstTxn #%0d RResp is issued before an older OutstTxn #%0d with the same ARID", ottq_idx, matchq[0]));
		end

	end else if (m_ott_q[ottq_idx].isWrite) begin 

		matchq = {};

		//#Check.IOAIU.WriteResponse_OrderingCheck
		//find an older write txn with same awid that has not yet sent back a BResp
		matchq = m_ott_q.find_index(item) with (item.isWrite &&
												item.m_id == m_ott_q[ottq_idx].m_id &&
(!item.isMultiAccess || (item.m_multiline_tracking_id != m_ott_q[ottq_idx].m_multiline_tracking_id)) && 
												!item.isACEWriteRespSent &&
												item.t_ace_write_recd < m_ott_q[ottq_idx].t_ace_write_recd
											   );

		if (matchq.size() > 0) begin 
			uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Write Response Order Violation! OutstTxn #%0d BResp is issued before an older OutstTxn #%0d with the same AWID", ottq_idx, matchq[0]));
		end

	end 
	
endfunction : check_response_ordering


<%if(obj.useCache) { %> 
function void ioaiu_scoreboard::check_address_ordering(int ottq_idx);
	int match_idxq[$];

    match_idxq = {};    
    match_idxq = m_ott_q.find_index with (item.isSMICMDReqSent                           == 1 &&
    				          item.isSMISTRReqRecd						 	 == 0 && //CONC-9817 It is ok to use STRreq as a qualifying event
                                          item.m_cmd_req_pkt.smi_msg_id                  != m_ott_q[ottq_idx].m_cmd_req_pkt.smi_msg_id &&
                                          item.m_security                                == m_ott_q[ottq_idx].m_security &&
                                          item.m_sfi_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_ott_q[ottq_idx].m_sfi_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)]
                                         );
	
  //#Check.IOAIU.Address_Ordering							 
	if (match_idxq.size > 0) begin
    	uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Below is the failed Txn(#%0d)", ottq_idx), UVM_NONE);
        m_ott_q[ottq_idx].print_me();
        uvm_report_info("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("Below is the previous Txn(#%0d) with same address that sent CMDreq and not received STRreq", match_idxq[0]), UVM_NONE);
        m_ott_q[match_idxq[0]].print_me();
        uvm_report_error("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Address Ordering Violation! Outgoing SMI command request OutstTxn #%0d has an previous Addr dependency txn OutstTxn #%0d that hasn't reached the qualified event:STRreq", ottq_idx, match_idxq[0]), UVM_NONE);
    end

endfunction : check_address_ordering
<%}%>

function void ioaiu_scoreboard::split_read_data_packet_multiline_txn(int ott_idx, ace_read_data_pkt_t m_pkt);
	int match_idxq[$];
	int multiline_tracking_id = m_ott_q[ott_idx].m_multiline_tracking_id;
	int beat_count = 0;
    ace_read_data_pkt_t m_tmp_pkt = new();

	match_idxq = {};
	match_idxq = m_ott_q.find_index with ((item.isMultiAccess == 1) && (item.m_multiline_tracking_id == multiline_tracking_id));
	
	if (match_idxq.size() != m_ott_q[ott_idx].total_cacheline_count)
    	`uvm_error("<%=obj.BlockId%> SCB ERROR", $sformatf("fn:split_read_data_to_multiline_txn Sanity Check on number of split transactions- matchq_size:%0d, total_cacheline_count:%0d", match_idxq.size(), m_ott_q[ott_idx].total_cacheline_count));

	for (int i = 0; i < match_idxq.size(); i++) begin 
    	int idx = match_idxq[i];
        int num_axi_rd_beats_per_split_txn = (owo_512b) ? 1 : m_ott_q[idx].m_ace_read_addr_pkt.arlen+1;
                        
        m_ott_q[idx].t_ace_read_data_sent = $time;
    	m_tmp_pkt.rdata                     = new[num_axi_rd_beats_per_split_txn];
        m_tmp_pkt.rresp_per_beat            = new[num_axi_rd_beats_per_split_txn];
        m_tmp_pkt.t_rtime                   = new[num_axi_rd_beats_per_split_txn];
        m_tmp_pkt.ruser                     = m_pkt.ruser;
        m_tmp_pkt.pkt_type                  = m_pkt.pkt_type;
        for (int k = 0; k < num_axi_rd_beats_per_split_txn; k++) begin
    	    //`uvm_info("<%=obj.BlockId%> SCB DBG", $sformatf("fn:split_read_data_to_multiline_txn Attaching Actual ReadData Pkt Beat:%0d Data:0x%0h to UID:%0d Beat:%0d", beat_count, m_pkt.rdata[beat_count], m_ott_q[idx].tb_txnid, k), UVM_LOW);

        	m_tmp_pkt.rdata[k]          = m_pkt.rdata[beat_count];
            m_tmp_pkt.rresp_per_beat[k] = m_pkt.rresp_per_beat[beat_count];
        	m_tmp_pkt.t_rtime[k]        = m_pkt.t_rtime[beat_count];

                foreach (error_data_q[i]) begin 
                error_data_bit = error_data_q[i] ^ m_tmp_pkt.rdata[k]; //xor with orignal data for peridciting bit changes.
                if($countbits(error_data_bit, '1) <= 2) begin          //counting flip bit for single bit or double bit error injection.
                m_ott_q[idx].error_data_q.push_back({m_tmp_pkt.rdata[k]});
               	m_ott_q[idx].predict_ott_data_error =1;
                error_data_q.delete(i);
		end
	        end
	
            beat_count++;
    	end
    	
    	check_oldest_axid_in_ott_q(idx);
    	m_ott_q[idx].setup_ace_read_data(m_tmp_pkt);
        m_ott_q[idx].multiline_ready_to_delete = 1;
    end

endfunction : split_read_data_packet_multiline_txn

function void ioaiu_scoreboard::delete_txn(int ott_idx);
	
	int match_idxq[$];

	if (m_ott_q[ott_idx].isMultiAccess) begin 
		match_idxq = {};
		match_idxq = m_ott_q.find_index with (item.isMultiAccess == 1 && item.m_multiline_tracking_id == m_ott_q[ott_idx].m_multiline_tracking_id);
		for(int i = match_idxq.size()-1; i >=0; i--) begin
			delete_ott_entry(match_idxq[i], MultiAceRdData);
		end
	end else begin 
		delete_ott_entry(ott_idx, AceRdData);
	end

endfunction : delete_txn

function void ioaiu_scoreboard::check_address_core_id(bit[WAXADDR-1:0] addr);

	bit [$clog2(<%=obj.nNativeInterfacePorts%>)-1:0] exp_core_id = 0;
	
	<%if(obj.AiuInfo[obj.Id].aNcaiuIntvFunc===undefined || obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits===undefined || !obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits.length){}else{%>
		<%for(var i=0; i<obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits.length; i++){%>
    		exp_core_id[<%=i%>] = addr[<%=obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[i]%>];
		<%}%>
	<%}%>
	
	if (core_id != exp_core_id)
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $psprintf("IOAIU_UID:%0d<%if(obj.nNativeInterfacePorts > 1){ %>:C%0d<%}%> Above received transaction with addr:0x%0h belongs to C%0d instead", tb_txn_count<%if(obj.nNativeInterfacePorts > 1){ %>,core_id<%}%>,  addr, exp_core_id));

endfunction : check_address_core_id

function void ioaiu_scoreboard::owo_set_expect_for_wb(int ott_idx);
    int cohwr_w_same_axid_matchq[$];
    int currtxn_idx_in_matchq =  -1;
    
    cohwr_w_same_axid_matchq = {};
    cohwr_w_same_axid_matchq = m_ott_q.find_index with (item.isWrite == 1 &&
                                                        item.isCoherent == 1 &&   
                                                        item.m_id == m_ott_q[ott_idx].m_id &&
                                                        !(item.dtwrsp_cmstatus_err == 1 && item.isACEWriteRespSent));

    foreach(cohwr_w_same_axid_matchq[i]) begin 
        if (m_ott_q[cohwr_w_same_axid_matchq[i]].tb_txnid == m_ott_q[ott_idx].tb_txnid)
            currtxn_idx_in_matchq = i;
    end 

    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("fn:owo_set_expect_for_wb -- cohwr_w_same_axid_matchq_size:%0d currtxn_idx_in_matchq:%0d", cohwr_w_same_axid_matchq.size(), currtxn_idx_in_matchq), UVM_LOW);
    if (currtxn_idx_in_matchq == -1) begin //implies currtxn has no match - Error out 
        `uvm_error("<%=obj.strRtlNamePrefix%> SCB ERROR", $sformatf("fn:owo_set_expect_for_wb -- cohwr_w_same_axid_matchq_size:%0d currtxn_idx_in_matchq:%0d implies currtxn has no match in cohwr_w_same_axid_matchq", cohwr_w_same_axid_matchq.size(), currtxn_idx_in_matchq));
    end else if (currtxn_idx_in_matchq == 0) begin //implies there are no txns older than this currtxn with same AxID 
    	`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("fn:owo_set_expect_for_wb -- Converting UID:%0d UCE --> UDP and set expect for WB on attaining oldest state since it is the 1st txn with this AxId",m_ott_q[ott_idx].tb_txnid), UVM_LOW);
        m_ott_q[ott_idx].m_owo_wr_state = UDP; 
        m_ott_q[ott_idx].is2ndSMICMDReqNeeded = 1;
    end
    else if (currtxn_idx_in_matchq > 0) begin 
        int idx = currtxn_idx_in_matchq - 1;
    	`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("fn:owo_set_expect_for_wb -- Checking if prev AxId matching txn with UID:%0d has WB Sent",m_ott_q[cohwr_w_same_axid_matchq[idx]].tb_txnid), UVM_LOW);
        if (m_ott_q[cohwr_w_same_axid_matchq[idx]].is2ndSMICMDReqSent == 1 || m_ott_q[cohwr_w_same_axid_matchq[idx]].dtwrsp_cmstatus_err || m_ott_q[cohwr_w_same_axid_matchq[idx]].hasFatlErr || m_ott_q[cohwr_w_same_axid_matchq[idx]].dtrreq_cmstatus_err) begin// previous txn with matching AxId already initiated WB, so current one becomes oldest in AxId chain
    	    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("fn:owo_set_expect_for_wb -- Converting UID:%0d UCE --> UDP and set expect for WB on attaining oldest state as prior AxId matching txn with UID:%0d WB Sent long ago",m_ott_q[ott_idx].tb_txnid, m_ott_q[cohwr_w_same_axid_matchq[idx]].tb_txnid), UVM_LOW);
            m_ott_q[ott_idx].m_owo_wr_state = UDP; 
            m_ott_q[ott_idx].is2ndSMICMDReqNeeded = 1;
        end
    end 
    
endfunction : owo_set_expect_for_wb 

function void ioaiu_scoreboard::update_owo_wr_state_on_clnunq_strreq(int ott_idx);
    int matchq[$];
    int currtxn_idx_in_matchq;
    matchq = {};

    matchq = m_ott_q.find_index with (item.isWrite == 1 &&
                                      item.isCoherent == 1 &&   
                                      item.m_id == m_ott_q[ott_idx].m_id);

        foreach(matchq[i]) begin 
         if (m_ott_q[matchq[i]].tb_txnid == m_ott_q[ott_idx].tb_txnid)
             currtxn_idx_in_matchq = i;
    	//`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("fn:update_owo_wr_state_on_clnunq_strreq matchq_%0d:%0d matching txn UID:%0d",i, matchq[i], m_ott_q[matchq[i]].tb_txnid), UVM_LOW);
        end 
    	`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("fn:update_owo_wr_state_on_clnunq_strreq matchq_size:%0d currtxn_idx_in_matchq:%0d",  matchq.size(), currtxn_idx_in_matchq), UVM_LOW);

 
    if (matchq.size() == 1 || currtxn_idx_in_matchq == 0) begin //implies no matching AXID before this one
    	`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Converting UID:%0d UCE --> UDP on CMO STRreq of UID:%0d",m_ott_q[matchq[0]].tb_txnid, m_ott_q[ott_idx].tb_txnid), UVM_LOW);
        m_ott_q[matchq[0]].m_owo_wr_state = UDP; //oldest in AXID chain
        m_ott_q[matchq[0]].is2ndSMICMDReqNeeded = 1;
    end 
    else if (matchq.size() > 1) begin 
        int idx = currtxn_idx_in_matchq - 1;
    	    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Checking if prev AxId matching txn with UID:%0d has WB Sent",m_ott_q[matchq[idx]].tb_txnid), UVM_LOW);
        if (m_ott_q[matchq[idx]].is2ndSMICMDReqSent == 1) begin// previous txn with matching AxId already initiated WB, so current one becomes oldest in AxId chain
    	    `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Converting UID:%0d UCE --> UDP on CMO STRreq as  prior AxId matching txn with UID:%0d WB Sent",m_ott_q[ott_idx].tb_txnid, m_ott_q[matchq[idx]].tb_txnid), UVM_LOW);
            m_ott_q[ott_idx].m_owo_wr_state = UDP; 
            m_ott_q[ott_idx].is2ndSMICMDReqNeeded = 1;
        end
    end 

endfunction: update_owo_wr_state_on_clnunq_strreq

function void ioaiu_scoreboard::owo_update_on_snp_req(int snp_ott_idx, int coh_wr_ott_idx, output bit snp_release);

    `uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG", $psprintf("fn:owo_update_on_snp_req snp_ott_idx:%0d coh_wr_ott_idx:%0d snp_uid:%0d coh_wr_uid:%0d", snp_ott_idx, coh_wr_ott_idx, m_ott_q[snp_ott_idx].tb_txnid, m_ott_q[coh_wr_ott_idx].tb_txnid), UVM_LOW);
    //CONC-16167
    //matching coherent wr is not the oldest in AxID chain. If in UCE , it
    //means 1st part is done, but it lost ownership due to snoop, in this
    //case SNP responds immediately, and re-set expects for ClnUnq again.
    if(m_ott_q[coh_wr_ott_idx].m_owo_wr_state == UCE)begin
        //m_ott_q[snp_ott_idx].isSMISNPRespNeeded =1;
        snp_release = 1;
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Downgrading UID:%0d UCE --> INV due to matching SNPreq UID:%0d and allow SNPreq to finish", m_ott_q[coh_wr_ott_idx].tb_txnid, m_ott_q[snp_ott_idx].tb_txnid), UVM_LOW);
        m_ott_q[coh_wr_ott_idx].m_owo_wr_state = INV;
        m_ott_q[coh_wr_ott_idx].isSMICMDReqSent = 0;
        m_ott_q[coh_wr_ott_idx].isSMICMDRespRecd = 0;
        m_ott_q[coh_wr_ott_idx].isSMISTRReqRecd = 0;
        m_ott_q[coh_wr_ott_idx].isSMISTRRespSent = 0;
    end
    //coherent wr is oldest in AxID cahin so WB process has officially
    //commenced, hence block the SNPrsp until WB is completed
    else if(m_ott_q[coh_wr_ott_idx].m_owo_wr_state == UDP) begin 
	if (!m_ott_q[coh_wr_ott_idx].isSMIDTWRespRecd && !(m_ott_q[coh_wr_ott_idx].dtrreq_cmstatus_err       === 1  ||m_ott_q[coh_wr_ott_idx].dtwrsp_cmstatus_err       === 1  || m_ott_q[coh_wr_ott_idx].hasFatlErr                  === 1)) begin
        	//m_ott_q[snp_ott_idx].isSMISNPRespNeeded = 0;
        	snp_release = 0;
        	`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("UID:%0d is UDP and DTWrsp not received, hence block SNPreq UID:%0d", m_ott_q[coh_wr_ott_idx].tb_txnid, m_ott_q[snp_ott_idx].tb_txnid), UVM_LOW);
	end else begin 
            //m_ott_q[snp_ott_idx].isSMISNPRespNeeded = 1;
            snp_release = 1;
        	`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("UID:%0d is UDP and DTWrsp not received, hence block SNPreq UID:%0d", m_ott_q[coh_wr_ott_idx].tb_txnid, m_ott_q[snp_ott_idx].tb_txnid), UVM_LOW);
	end
    end
    //ClnUnq is not completed yet, so SNP is effectively ordered before the
    //coherent Wr. Allow the SNPreq to finish
    else if (m_ott_q[coh_wr_ott_idx].m_owo_wr_state == INV) begin
        //m_ott_q[snp_ott_idx].isSMISNPRespNeeded = 1;
        snp_release = 1;
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("UID:%0d is INV hence allow SNPreq UID:%0d to finish", m_ott_q[coh_wr_ott_idx].tb_txnid, m_ott_q[snp_ott_idx].tb_txnid), UVM_LOW);
    end

endfunction: owo_update_on_snp_req

//7.9.4.1.2	Perform Write
//The write performed is equivalent to a WriteBack. If any snoops come into that cacheline, that snoop will be held until the DTWRsp has been seen. At which point the IOAIUp will respond with an invalid state forcing the Snooper to retrieve the updated line from memory. 
//#Check.IOAIU.OWO.UnBlockSnpCondition
function void ioaiu_scoreboard::owo_unblock_snp_on_wb_dtwrsp(int ott_idx);    
  int snp_matchq[$];
  int other_outstanding_wrq[$];
  snp_matchq = {};
  other_outstanding_wrq = {};

  snp_matchq = m_ott_q.find_index with (item.isSMISNPRespNeeded ==0 && 
                                    item.isSMISNPReqRecd ==1   &&
                                    item.m_snp_req_pkt.smi_ns ==  m_ott_q[ott_idx].m_ace_write_addr_pkt.awprot[1]&&
                                    item.m_snp_req_pkt.smi_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)] ==  m_ott_q[ott_idx].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)]
                                   );

  other_outstanding_wrq = m_ott_q.find_index with (item.tb_txnid != m_ott_q[ott_idx].tb_txnid &&
				    item.isWrite &&
				    item.m_owo_wr_state == UDP &&
                                    item.m_ace_write_addr_pkt.awprot[1] ==  m_ott_q[ott_idx].m_ace_write_addr_pkt.awprot[1] &&
                                    item.m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] ==  m_ott_q[ott_idx].m_ace_write_addr_pkt.awaddr[WAXADDR-1:$clog2(SYS_nSysCacheline)] &&
				    !item.isSMIDTWRespRecd && !item.dtwrsp_cmstatus_err);

   if (snp_matchq.size() != 0)
   	`uvm_info("<%=obj.strRtlNamePrefix%> SCB DBG", $sformatf("SNPreq UID:%0d SNPrspNeeded:%0b", m_ott_q[snp_matchq[0]].tb_txnid, m_ott_q[snp_matchq[0]].isSMISNPRespNeeded), UVM_LOW);
   
   if (snp_matchq.size() != 0 && other_outstanding_wrq.size() == 0) begin
        m_ott_q[snp_matchq[0]].isSMISNPRespNeeded = 1;
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("UID:%0d got DTWrsp so unblocking SNPreq UID:%0d", m_ott_q[ott_idx].tb_txnid, m_ott_q[snp_matchq[0]].tb_txnid), UVM_LOW);
   end 
   else if (snp_matchq.size() != 0 && other_outstanding_wrq.size() > 0) begin 
        `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("UID:%0d got DTWrsp but cannot unblock SNPreq(UID:%0d) since there is another write transaction with UID:%0d that should finish", m_ott_q[ott_idx].tb_txnid, m_ott_q[snp_matchq[0]].tb_txnid, m_ott_q[other_outstanding_wrq[0]].tb_txnid), UVM_LOW);
   end
   
endfunction: owo_unblock_snp_on_wb_dtwrsp

//This fn finds the next txn with same axiid that is already in UDP state to
//set WB expectation 2ndSMICMDReqNeeded
function void ioaiu_scoreboard::update_owo_wr_state_on_coh_wb_cmdreq_sent(int ott_idx); 
    int matchq[$];
    int currtxn_tb_txnid = m_ott_q[ott_idx].tb_txnid;
    int currtxn_id = m_ott_q[ott_idx].m_id;
    matchq = {};


    matchq = m_ott_q.find_index with ((item.tb_txnid > currtxn_tb_txnid) &&
                                      (item.m_id == currtxn_id) && 
                                      item.isWrite &&
                                      item.isCoherent
                                     );

   if (matchq.size() > 0) begin
      // if (m_ott_q[matchq[0]].m_owo_wr_state == UCE) begin
      //      `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Converting UID:%0d UCE --> UDP when Writeback CMDreq of UID:%0d is issued", m_ott_q[matchq[0]].tb_txnid, m_ott_q[ott_idx].tb_txnid), UVM_LOW);
      //      m_ott_q[matchq[0]].m_owo_wr_state = UDP;
      //      m_ott_q[matchq[0]].is2ndSMICMDReqNeeded = 1;
      //  end
       if (m_ott_q[matchq[0]].m_owo_wr_state == UDP) begin
            //`uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Converting UID:%0d UCE --> UDP when Writeback CMDreq of UID:%0d is issued", m_ott_q[matchq[0]].tb_txnid, m_ott_q[ott_idx].tb_txnid), UVM_LOW);
            //m_ott_q[matchq[0]].m_owo_wr_state = UDP;
            m_ott_q[matchq[0]].is2ndSMICMDReqNeeded = 1;
       end 
      // else begin 

      // end
    end
endfunction:update_owo_wr_state_on_coh_wb_cmdreq_sent

function bit ioaiu_scoreboard::req_data_crosses_cacheline_midpoint(input bit[63:0] start_addr, input int unsigned size);
    bit [5:0] offset_within_beat;

    offset_within_beat = start_addr[5:0];

    return ((offset_within_beat + size > 32) && (offset_within_beat < 32));

endfunction: req_data_crosses_cacheline_midpoint

