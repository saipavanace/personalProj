////////////////////////////////////////////////////////////////////////////////
//
// Author       : Muffadal
// Purpose      : CHI-AIU scoreboard
// Revision     :
//
// [ Browse code using this sections ]
//
// [ Notes ]
// Section1 : Scoreboard top
// Section2 : CHI Write function
// Section3 : SMI Write function
// Section4 : SFI Dtr,Str,Dtw,Cmd process functions
// Section5 : Utility function
// Section6 : Q-Channle Write function
//
////////////////////////////////////////////////////////////////////////////////
<%
var DVMV8_4=(obj.DveInfo[0].DVMVersionSupport==132)?1:0;
var DVMV8_1=(obj.DveInfo[0].DVMVersionSupport==129)?1:0;
var DVMV8_0=(obj.DveInfo[0].DVMVersionSupport==128)?1:0;
%>

import uvm_pkg::*;
import sv_assert_pkg::*;
`include "uvm_macros.svh"

`uvm_analysis_imp_decl ( _smi_port         )
`uvm_analysis_imp_decl ( _chi_req_port     )
`uvm_analysis_imp_decl ( _chi_wdata_port   )
`uvm_analysis_imp_decl ( _chi_srsp_port    )
`uvm_analysis_imp_decl ( _chi_crsp_port    )
`uvm_analysis_imp_decl ( _chi_rdata_port   )
`uvm_analysis_imp_decl ( _chi_snpaddr_port )
`uvm_analysis_imp_decl ( _chi_sysco_port )
`uvm_analysis_imp_decl ( _q_chnl_port      )//Q-channel port

////////////////////////////////////////////////////////////////////////////////
// Section1:  Scoreboard top
//
//
////////////////////////////////////////////////////////////////////////////////

class chi_aiu_scb extends uvm_scoreboard;
    `uvm_component_param_utils(chi_aiu_scb)
    // perf monitor stall Interface
    virtual <%=obj.BlockId%>_stall_if sb_stall_if;
    ////

    //CHI Ports
    uvm_analysis_imp_chi_req_port     #(
      chi_req_seq_item, chi_aiu_scb) chi_req_port;
    uvm_analysis_imp_chi_wdata_port   #(
      chi_dat_seq_item, chi_aiu_scb) chi_wdata_port;
    uvm_analysis_imp_chi_srsp_port    #(
      chi_rsp_seq_item, chi_aiu_scb) chi_srsp_port;
    uvm_analysis_imp_chi_crsp_port    #(
      chi_rsp_seq_item, chi_aiu_scb) chi_crsp_port;
    uvm_analysis_imp_chi_rdata_port   #(
      chi_dat_seq_item, chi_aiu_scb) chi_rdata_port;
    uvm_analysis_imp_chi_snpaddr_port #(
      chi_snp_seq_item, chi_aiu_scb) chi_snpaddr_port;
    uvm_analysis_imp_chi_sysco_port #(
      chi_base_seq_item, chi_aiu_scb) chi_sysco_port;

    //SMI Port
    uvm_analysis_imp_smi_port #(smi_seq_item, chi_aiu_scb) smi_port;

    //Q-Channel Port
    uvm_analysis_imp_q_chnl_port #(q_chnl_seq_item , chi_aiu_scb) q_chnl_port;

 //parameter  cmd_to_cmdreq_latency           = 3;
   parameter  cmd_to_cmdreq_latency           = 5;
 //parameter  strreq_to_chi_rsp_latency       = 3;
   parameter  strreq_to_chi_rsp_latency       = 4;
 //parameter  dtrreq_to_chi_data_latency      = 2;
   parameter  dtrreq_to_chi_data_latency      = 3;
   parameter  chi_data_to_dtwreq_latency      = 6;
   parameter  chi_data_to_dtrReq_latency      = 6;
   parameter  snpreq_to_chi_snoop_latency     = 3;
   parameter  chi_rsp_to_snprsp_latency       = 3;

    //Queues
    chi_aiu_scb_txn m_ott_q[$];
    //sysco_q
    chi_aiu_scb_txn m_sysco_q[$], m_sysco_timeout_q[$];
    smi_seq_item m_sysreq_q[$];
    smi_seq_item m_exp_sysrsp_q[$];
    int m_sys_req_cnt;
    chi_sysco_state_t m_sysco_st = DISABLED;

    smi_seq_item exp_event_msg_sys_rsp_pkt[$];
    bit          exp_event_msg_sys_rsp_empty[$];
    bit          boundary_start_addr;
    bit          boundary_end_addr;
    bit          boundary_one_byte_before_start_addr;
    bit          boundary_one_byte_after_end_addr;
    // smi_seq_item rcvd_event_msg_sys_req_pkt[$];
    //SysReq Events queues
    // smi_seq_item  rcvd_sys_req_ev_pkt_q[$];
    // smi_seq_item  exp_sys_rsp_ev_pkt_q[$];
    // int timeout_source_id;
    // int sys_rsp_timeout_detected;
    //event e_queue_delete;

    typedef struct packed { smi_src_id_bit_t src_id;
                            smi_msg_id_bit_t msg_id;
                          }unique_id;
    unique_id dtr_targ_err_msg_id[$];
    unique_id snp_targ_err_msg_id[$];
    unique_id str_targ_err_msg_id[$];
    smi_msg_id_bit_t cmd_rsp_targ_err_rmsg_id[smi_msg_id_bit_t];
    smi_msg_id_bit_t str_req_corsp_cmd_rsp_rmsg_id[smi_msg_id_bit_t];
    smi_msg_id_bit_t str_req_msg_id_corsp_str_rmsg_id[smi_msg_id_bit_t];
    smi_msg_id_bit_t cmd_rsp_rmsg_id_corsp_str_msg_id[smi_msg_id_bit_t];
    smi_msg_id_bit_t str_req_msg_id_for_cmd_rsp_targ_err[smi_msg_id_bit_t];
    int STRreq_aiu_txn_ids_cmstatus_with_data_err[int]; 
    int STRreq_aiu_txn_ids_cmstatus_with_non_data_err[int]; 
    int DTRreq_aiu_txn_ids_cmstatus_with_data_err[int]; 
    int DTRreq_aiu_txn_ids_cmstatus_with_non_data_err[int]; 
    int CMDrsp_aiu_txn_ids_with_cmstatus_with_err[int]; 
    int CMDrsp_aiu_txn_ids_with_cmstatus_with_err_other_val[int]; 
    int DTRrsp_aiu_txn_ids_with_cmstatus_with_err[int]; 
    int DTRrsp_aiu_txn_ids_with_cmstatus_with_err_other_val[int]; 
    int DTWrsp_aiu_txn_ids_with_cmstatus_with_err[int];
    int DTWrsp_aiu_txn_ids_with_cmstatus_with_err_other_val[int];
    int dtw_rsp_targ_err_aiu_txn_id[int];
    int dtr_rsp_targ_err_aiu_txn_id[int];
    int dbad_dtr_req[int];
    chi_dat_poison_t poison_q[int][$];
    chi_addr_t csr_addr_decode_err_addr_q[$];
    smi_addr_t dvm_snp_req_addr_q[$], dvm_snp_req_addr_dup_q[$];
    smi_addr_t dvm_snp_req_addr_sync_q[$], dvm_snp_req_addr_sync_dup_q[$];
    smi_addr_t dvm_snp_req_addr_nonsync_q[$], dvm_snp_req_addr_nonsync_dup_q[$];
    bit csr_addr_decode_err_cmd_type_q[$];
    bit [2:0] csr_addr_decode_err_type_q[$];
    bit [2:0] dec_err_type;
    chi_txnid_t csr_addr_decode_err_msg_id_q[$];
    int dword_width_diff__smi_chi_data = wSmiDPdata/WDATA;
    int no_of_dword__chi_data = ((WDATA/64)*WSMIDPDBADPERDW);
    int dword_width_diff__chi_smi_data = WDATA/wSmiDPdata;
    int dce_credit_zero;
    int dmi_credit_zero;
    int dii_credit_zero;
    int k_snp_rsp_non_data_err_wgt;
    int sys_msg_id_timeout[$];
    int sys_msgid_timeout;
    bit one_dvm_sync_enable = ($test$plusargs("k_one_dvm_sync_disable")) ? 1'b0 : 1'b1;

    int rd_total_flits = 0;
    int wr_total_flits = 0;
    real t_bw_start_time = 0;
    real t_rd_bw_start_time = 0, t_rd_bw_end_time = 0;
    real t_wr_bw_start_time = 0, t_wr_bw_end_time_wdata = 0, t_wr_bw_end_time_crsp = 0;


    time t_chicmd_to_smicmdreq_min='1;
    time t_chicmd_to_smicmdreq_avg;
    int  chicmd_to_smicmdreq_min_t = 0;
    int  is_chicmd_to_smicmdreq_min_unknown;

    time t_chirsp_to_smicmdrsp_min='1;
    time t_chirsp_to_smicmdrsp_avg;
    int  chirsp_to_smicmdrsp_min_t = 0;
    int  is_chirsp_to_smicmdrsp_min_unknown;

    time t_chiwdat_to_smidat_min='1;
    time t_chiwdat_to_smidat_avg;
    int  chiwdat_to_smidat_min_t = 0;
    int  is_chiwdat_to_smidat_min_unknown;

    time t_smisnp_to_chisnp_min='1;
    time t_smisnp_to_chisnp_avg;
    int  smisnp_to_chisnp_min_t = 0;
    int  is_smisnp_to_chisnp_min_unknown;

    time t_smirsp_to_chirsp_min='1;
    time t_smirsp_to_chirsp_avg;
    int  smirsp_to_chirsp_min_t = 0;
    int  is_smirsp_to_chirsp_min_unknown;

    time t_smidat_to_chirdat_min='1;
    time t_smidat_to_chirdat_avg;
    int  smidat_to_chirdat_min_t = 0;
    int  is_smidat_to_chirdat_min_unknown;


    time t_chidat_to_dtrreq_min='1;
    time t_chidat_to_dtrreq_avg;
    int  chidat_to_dtrreq_min_t = 0;
    int  is_chidat_to_dtrreq_min_unknown;

    time t_chirsp_to_snprsp_min='1;
    time t_chirsp_to_snprsp_avg;
    int  chirsp_to_snprsp_min_t = 0;
    int  is_chirsp_to_snprsp_min_unknown;

    int outstanding_stsh_snoops;
    int max_stash_snoops = <%=obj.AiuInfo[obj.Id].cmpInfo.nStshSnpInFlight%>;

    // BEGIN PERF_MONITOR
    const int    max_ott = <%=obj.AiuInfo[obj.Id].cmpInfo.nOttCtrlEntries%>;
    event evt_ott;
    int   ott_skid_size;
    int   real_ott_size;
    event evt_del_ott;

    int   curr_wdata_interleave_cnt = 0;
    int   qos_starv_count = 0;

    // SMI error injection statistics
    int  res_smi_corr_err   = 0;
    int  num_smi_corr_err   = 0;
    int  num_smi_uncorr_err = 0;
    int  num_smi_parity_err = 0;  // also uncorrectable

    realtime res_smi_pkt_time_old, res_smi_pkt_time_new;
    int res_mod_dp_corr_error;
    bit res_is_pre_err_pkt;

    bit is_resend_correct_target_id = $test$plusargs("resend_correct_target_id") ? 1'b1 : 1'b0;

    `ifndef FSYS_COVER_ON
    //Coverage instance
    chi_aiu_coverage cov;
    `elsif CHI_SUBSYS_COVER_ON
    //Coverage instance
    chi_aiu_coverage cov;
    `endif
    int m_req_aiu_id;
    event e_queue_change;
    static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_snp_rsp_err = ev_pool.get("ev_snp_rsp_err");
    uvm_event ev_csr_test_time_out_CMDrsp_STRreq = ev_pool.get("ev_csr_test_time_out_CMDrsp_STRreq");
    uvm_event ev_csr_test_time_out_SNPrsp = ev_pool.get("ev_csr_test_time_out_SNPrsp");
    uvm_event ev_csr_test_time_out_SYSrsp = ev_pool.get("ev_csr_test_time_out_SYSrsp");
    uvm_event ev_csr_sysco_<%=obj.BlockId%> = ev_pool.get("ev_csr_sysco_<%=obj.BlockId%>");
    uvm_event ev_crd_cov_<%=obj.BlockId%> = ev_pool.get("ev_crd_cov_<%=obj.BlockId%>");
    <% if(obj.testBench == "fsys") { %>
    //fullsys test uncorrectable error test when addresses with NS=1 that hit a NSX=0 region should be terminated with decerr
    //event to sync with concerto_fullsys_test and end simulation when DECERR is received
    uvm_event kill_uncorr_grar_nsx_test = ev_pool.get("kill_uncorr_grar_nsx_test");
    //fullsys test uncorrectable error when assigned zero crdit to CHIAIU
    //event to sync with concerto_fullsys_test and end simulation when DECERR is received
    uvm_event kill_chiaiu_uncorr_test = ev_pool.get("kill_chiaiu_uncorr_test");
    <% } %>
    //uvm_event kill_coherency_test = ev_pool.get("kill_coherency_test");
    uvm_event all_txn_done_ev = ev_pool.get("all_txn_done_ev");
    bit   en_sb_objections = 1;
    int chi_aiu_uid = 0;
    int tb_txnid = 0;

    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
    //static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    static uvm_event csr_init_done = ev_pool.get("csr_init_done");
    bit    start_sb;
   <%}%>

   <% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu"|| obj.testBench == "cust_tb") { %>
   <%=obj.instanceName%>_concerto_register_map_pkg::ral_sys_ncore m_regs;
   <%} else if(obj.testBench=="fsys" || obj.testBench=="emu") {%>
     concerto_register_map_pkg::ral_sys_ncore      m_regs;
   <%}%>

   uvm_reg my_register;
   uvm_reg_data_t mirrored_value; 
   uvm_reg_data_t write_value =32'hFFFF_FFFF;
   uvm_status_e status;

    <%if (obj.testBench != "fsys" && obj.testBench != "emu"){ %>
    virtual chi_aiu_dut_probe_if u_dut_probe_vif;
    <% } %>

    <%  if (obj.useResiliency && obj.testBench != "fsys" && obj.testBench != "emu") { %>
    virtual chi_aiu_csr_probe_if u_csr_probe_vif;
    <% } %>

    trace_trigger_utils m_trace_trigger;

    <%if(obj.testBench == "fsys"){ %>
    TRIG_TCTRLR_t tctrlr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    TRIG_TBALR_t  tbalr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    TRIG_TBAHR_t  tbahr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    TRIG_TOPCR0_t topcr0[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    TRIG_TOPCR1_t topcr1[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    TRIG_TUBR_t   tubr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    TRIG_TUBMR_t  tubmr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    <% } else { %>
    static TRIG_TCTRLR_t tctrlr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    static TRIG_TBALR_t  tbalr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    static TRIG_TBAHR_t  tbahr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    static TRIG_TOPCR0_t topcr0[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    static TRIG_TOPCR1_t topcr1[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    static TRIG_TUBR_t   tubr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    static TRIG_TUBMR_t  tubmr[<%=obj.AiuInfo[obj.Id].nTraceRegisters%>];
    <% } %>

    static uvm_event csr_trace_debug_done = ev_pool.get("csr_trace_debug_done");

    <%if(obj.COVER_ON){%>
        sysreq_pkt_t    sysreq_pkt;
    <%}%>

    //Address Manager handle
    addr_trans_mgr m_addr_mgr;

	//Connectivity Interface
    virtual <%=obj.BlockId%>_connectivity_if connectivity_if;

    uvm_objection objection;
    //Constructor
    function new(string name="chi_aiu_scb", uvm_component parent=null);
        super.new(name,parent);
        `ifndef FSYS_COVER_ON
        cov = new();
    	`elsif CHI_SUBSYS_COVER_ON
        cov = new();
        `endif
        m_trace_trigger = new();
        //write default value of native trace en to 1 incase the register is not programmed.
        <% for(var i=0; i<obj.AiuInfo[obj.Id].nTraceRegisters; i++) {%>
        tctrlr[<%=i%>] = 'h1;
        m_trace_trigger.TCTRLR_write_reg(<%=i%>,tctrlr[<%=i%>]);
        <%}%>
        m_trace_trigger.print_trigger_sets_reg_values();

        m_addr_mgr = addr_trans_mgr::get_instance();

        if (!uvm_config_db#(virtual <%=obj.BlockId%>_connectivity_if)::get(null, "", "<%=obj.BlockId%>_connectivity_if", connectivity_if)) begin
            `uvm_fatal("Connectivity interface error", "virtual interface must be set for connectivity_if");
        end

    endfunction

    //Build phase
    function void build_phase(uvm_phase phase);
        m_req_aiu_id            = <%= obj.AiuInfo[obj.Id].nUnitId %>;
        //CHI Ports
        chi_req_port            = new("chi_req_port"     , this);
        chi_wdata_port          = new("chi_wdata_port"   , this);
        chi_srsp_port           = new("chi_srsp_port"    , this);
        chi_crsp_port           = new("chi_crsp_port"    , this);
        chi_rdata_port          = new("chi_rdata_port"   , this);
        chi_snpaddr_port        = new("chi_snpaddr_port" , this);
        chi_sysco_port          = new("chi_sysco_port"   , this);
        //SMI Port
        smi_port                = new("smi_port", this);
        //Q-Channel Port
        q_chnl_port             = new("q_chnl_port", this);
        chi_aiu_uid		= {m_req_aiu_id[7:0], chi_aiu_uid[23:0]};

        if ($test$plusargs("disable_sb_objection")) begin
          en_sb_objections = 0;
        end

    endfunction

    //check phase
    extern function void check_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void report_phase(uvm_phase phase);

    //Write Function for CHI port
    extern function void write_chi_req_port     ( const ref chi_req_seq_item m_pkt  ) ;
    extern function void write_chi_wdata_port   ( const ref chi_dat_seq_item m_pkt ) ;
    extern function void write_chi_srsp_port    ( const ref chi_rsp_seq_item m_pkt  ) ;
    extern function void write_chi_crsp_port    ( const ref chi_rsp_seq_item m_pkt  ) ;
    extern function void write_chi_rdata_port   ( const ref chi_dat_seq_item m_pkt ) ;
    extern function void write_chi_snpaddr_port ( const ref chi_snp_seq_item m_pkt  ) ;
    extern function void write_chi_sysco_port   ( const ref chi_base_seq_item m_pkt ) ;

    //Write Function for SMI port
    extern function void write_smi_port ( const ref smi_seq_item m_pkt);

    //Write Function for Q-Channel port
    extern function void write_q_chnl_port ( q_chnl_seq_item m_pkt);

    //SMI Request processing function
    extern function void process_cmd_req     ( const ref smi_seq_item m_pkt ) ;
    extern function void process_snp_dtr_req ( const ref smi_seq_item m_pkt ) ;
    extern function void process_dtw_req     ( const ref smi_seq_item m_pkt ) ;
    extern function void process_snp_req     ( const ref smi_seq_item m_pkt ) ;
    extern function void process_str_req     ( const ref smi_seq_item m_pkt ) ;
    extern function void process_dtr_req     ( const ref smi_seq_item m_pkt ) ;
    extern function void process_sys_req     ( const ref smi_seq_item m_pkt ) ;

    //SMI Response processing function
    extern function void process_cmd_rsp     ( const ref smi_seq_item m_pkt ) ;
    extern function void process_snp_dtr_rsp ( const ref smi_seq_item m_pkt ) ;
    extern function void process_dtw_rsp     ( const ref smi_seq_item m_pkt ) ;
    extern function void process_snp_rsp     ( const ref smi_seq_item m_pkt ) ;
    extern function void process_str_rsp     ( const ref smi_seq_item m_pkt ) ;
    extern function void process_dtr_rsp     ( const ref smi_seq_item m_pkt ) ;
    extern function void process_cmp_rsp     ( const ref smi_seq_item m_pkt ) ;
    extern function void process_sys_rsp     ( const ref smi_seq_item m_pkt ) ;

    extern function void process_snp_resp_data(int ott_idx, chi_dat_seq_item m_pkt);
    extern function void process_csr_sysco();
    extern function void setup_x_sysco_pkt(const ref chi_base_seq_item m_pkt, input bit is_SyscoNintf = 1);
    extern function void check_compdata_resp_field_value (const ref chi_aiu_scb_txn pkt);
    extern function void check_dtr_msg_types(const ref chi_aiu_scb_txn pkt);
    extern function void check_dbid_uniqueness(const ref chi_rsp_dbid_t dbid);
    extern function void check_snp_dtr_msg_types(const ref chi_aiu_scb_txn pkt);
    //extern function void check_dtw_msg_types(const ref chi_aiu_scb_txn pkt);

    extern function void update4sysco_snp_req(ref chi_aiu_scb_txn pkt, input bit is_chi_pkt=0, is_dvm_part2=0);
    extern function chi_sysco_state_t get_cur_sysco_state();
    extern function void update_snp_req_addr_q(const ref chi_aiu_scb_txn pkt, ref smi_addr_t snp_req_addr_q[$], input string name="");
    //Utility Function
    extern function void delete_ott_entry(int index);//,eAIUPktTypes e_reason);
    extern function void print_me(int idx=0);
    extern function void print_ott_info();
    extern function void print_sysco_q();
    extern function bit check_msgid_reuse(const ref smi_seq_item m_packet);

    virtual function void pre_abort();
        `uvm_info(`LABEL, $psprintf("Total number of transactions in this run: %0d. Num of pending transactions: %0d", chi_aiu_uid - {m_req_aiu_id[7:0], 24'd0}, m_ott_q.size()), UVM_NONE)
        print_ott_info();
        extract_phase(null);
    endfunction : pre_abort

endclass


////////////////////////////////////////////////////////////////////////////////
// Section2: CHI Write functions
//
//
////////////////////////////////////////////////////////////////////////////////


//******************************************************************************
// Function : write_chi_req_port
// Purpose  :
//
//******************************************************************************
function void chi_aiu_scb::write_chi_req_port(const ref chi_req_seq_item m_pkt);
    int              find_q[$];
    string           spkt;
    chi_aiu_scb_txn  m_scb_pkt;

    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        if(start_sb)begin
    <%}%>
    
        `ifndef FSYS_COVER_ON
            foreach(addrMgrConst::memregion_boundaries[idx]) begin
               if (m_pkt.addr == addrMgrConst::memregion_boundaries[idx].start_addr[addrMgrConst::ADDR_WIDTH - 1 : 0] ) begin
                  boundary_start_addr = 1;
                  uvm_config_db#(int)::set(null,"*","boundary_start_addr",boundary_start_addr);
               end else if (m_pkt.addr == (addrMgrConst::memregion_boundaries[idx].end_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]-1)) begin
                  boundary_end_addr = 1;
                  uvm_config_db#(int)::set(null,"*","boundary_end_addr",boundary_end_addr);
               end else if (m_pkt.addr == (addrMgrConst::memregion_boundaries[idx].start_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]-1)) begin
                  boundary_one_byte_before_start_addr = 1;
                  uvm_config_db#(int)::set(null,"*","boundary_one_byte_before_start_addr",boundary_one_byte_before_start_addr);
               end else if (m_pkt.addr == (addrMgrConst::memregion_boundaries[idx].end_addr[addrMgrConst::ADDR_WIDTH - 1 : 0])) begin
                  boundary_one_byte_after_end_addr = 1;
                  uvm_config_db#(int)::set(null,"*","boundary_one_byte_after_end_addr",boundary_one_byte_after_end_addr);
               end
               cov.collect_boundary_addr();
            end
            cov.collect_chi_req_flit(m_pkt);
            cov.collect_cmd_type_x_connectivity(m_pkt,connectivity_if.AiuDce_connectivity_vec,connectivity_if.AiuDmi_connectivity_vec,connectivity_if.AiuDii_connectivity_vec);
    	`elsif CHI_SUBSYS_COVER_ON
            foreach(addrMgrConst::memregion_boundaries[idx]) begin
               if (m_pkt.addr == addrMgrConst::memregion_boundaries[idx].start_addr[addrMgrConst::ADDR_WIDTH - 1 : 0] ) begin
                  boundary_start_addr = 1;
                  uvm_config_db#(int)::set(null,"*","boundary_start_addr",boundary_start_addr);
               end else if (m_pkt.addr == (addrMgrConst::memregion_boundaries[idx].end_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]-1)) begin
                  boundary_end_addr = 1;
                  uvm_config_db#(int)::set(null,"*","boundary_end_addr",boundary_end_addr);
               end else if (m_pkt.addr == (addrMgrConst::memregion_boundaries[idx].start_addr[addrMgrConst::ADDR_WIDTH - 1 : 0]-1)) begin
                  boundary_one_byte_before_start_addr = 1;
                  uvm_config_db#(int)::set(null,"*","boundary_one_byte_before_start_addr",boundary_one_byte_before_start_addr);
               end else if (m_pkt.addr == (addrMgrConst::memregion_boundaries[idx].end_addr[addrMgrConst::ADDR_WIDTH - 1 : 0])) begin
                  boundary_one_byte_after_end_addr = 1;
                  uvm_config_db#(int)::set(null,"*","boundary_one_byte_after_end_addr",boundary_one_byte_after_end_addr);
               end
               cov.collect_boundary_addr();
            end
            cov.collect_chi_req_flit(m_pkt);
            cov.collect_cmd_type_x_connectivity(m_pkt,connectivity_if.AiuDce_connectivity_vec,connectivity_if.AiuDmi_connectivity_vec,connectivity_if.AiuDii_connectivity_vec);
        `endif
        m_scb_pkt = new(,m_req_aiu_id);
        tb_txnid++;
        `uvm_info(`LABEL, $psprintf("TB_TXNID:%0d Inbound CHI_REQ_PKT: %0s", tb_txnid, m_pkt.convert2string()), UVM_MEDIUM)
        `uvm_info(`LABEL, $psprintf("write_chi_req_port. Pkt=%0s", m_pkt.convert2string()), UVM_LOW)
        find_q = m_ott_q.find_index with(item.m_chi_req_pkt !== null
                                        && item.m_chi_req_pkt.txnid == m_pkt.txnid);


        foreach (m_ott_q[txn]) begin
          if(m_ott_q[txn].m_chi_req_pkt != null) begin
            if(m_ott_q[txn].m_chi_req_pkt.addr[addrMgrConst::ADDR_WIDTH - 1 :<%=obj.wCacheLineOffset%>] == m_pkt.addr[addrMgrConst::ADDR_WIDTH - 1 :<%=obj.wCacheLineOffset%>])begin

              if(m_ott_q[txn].m_chi_req_pkt.opcode inside {WRITENOSNPPTL,WRITENOSNPFULL,READNOSNP} &&
                 m_pkt.opcode inside {WRITENOSNPPTL,WRITENOSNPFULL,READNOSNP} ) begin // Non-coherent command
                if (m_ott_q[txn].m_chi_req_pkt.lpid == m_pkt.lpid) begin
                  sb_stall_if.perf_count_events["Address_Collisions"].push_back(1); 
                  break; 
                end
              end else if ((!(m_ott_q[txn].m_chi_req_pkt.opcode inside {WRITENOSNPPTL,WRITENOSNPFULL,READNOSNP})) && (!(m_pkt.opcode inside {WRITENOSNPPTL,WRITENOSNPFULL,READNOSNP}))) begin //Coherent command
                  sb_stall_if.perf_count_events["Address_Collisions"].push_back(1); 
                  break; 
              end

            end
          end
        end

        // TXNID can repeat if only STR_RSP and/or CMD_RSP and/or DTR_RSP is pending or SRESP on CHI
        for (int idx = find_q.size()-1; idx >= 0; idx--) begin
            if (m_ott_q[find_q[idx]].chi_exp inside {'h0, 'h4, 'h1}) begin
                //&& m_ott_q[find_q[idx]].smi_exp inside {'h0, 'h8, 'h20, 'h28, 'h2, 'hA, 'h22, 'h2A, 'h4, 'h6, 'hE, 'h2e, 'h24, 'h26, 'hC, 'h2C}) begin
                find_q.delete(idx);
            end else if (m_ott_q[find_q[idx]].chi_exp == 'h5 && m_ott_q[find_q[idx]].dbid_val) begin //if WRDATA and COMPACK is remaining for a write transaction, the txnid can repeat
                find_q.delete(idx);
            end
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %> 
                else if (m_ott_q[find_q[idx]].m_chi_req_pkt.opcode == PREFETCHTARGET) begin
                    if (($test$plusargs("pick_boundary_addr") && addr_trans_mgr::check_unmapped_add(m_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || ($test$plusargs("unmapped_add_access") && addr_trans_mgr::check_unmapped_add(m_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || $test$plusargs("user_addr_for_csr") || ($test$plusargs("non_secure_access_test") && (!addrMgrConst::get_addr_gprar_nsx(m_pkt.addr)) && (m_pkt.ns == 'h1)) || (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && addrMgrConst::check_addr_crd_zero(m_pkt.addr,m_pkt.snpattr))) begin 
                        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : write_chi_req_port: Added a Multiple address hit OR Unmapped address txn with opcode: %0s", chi_aiu_uid, m_pkt.opcode.name()), UVM_LOW)
                        delete_ott_entry(find_q[idx]);
                    end
                    find_q.delete(idx);
                end
	        <% } %>							       
        end

        <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            if (m_pkt.opcode == PREFETCHTARGET) begin
                find_q.delete();
            end
        <% } %>

        if(find_q.size() == 0) begin
            if (m_pkt.opcode == REQLCRDRETURN) begin
                `uvm_info(`LABEL, $psprintf("write_chi_req_port: Added a Request txn with TxnId : %0h, opcode: %0s", m_pkt.txnid, m_pkt.opcode.name()), UVM_LOW)
                return;
            end 
            if (t_bw_start_time == 0) t_bw_start_time = $realtime;
            m_scb_pkt.setup_chi_req_pkt(m_pkt);
            //if($test$plusargs("user_addr_for_csr") || $test$plusargs("unmapped_add_access")) begin //There is no way to get configure address region map in GPR register so using plusharg
            if(($test$plusargs("pick_boundary_addr") && addr_trans_mgr::check_unmapped_add(m_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || $test$plusargs("user_addr_for_csr") || ($test$plusargs("unmapped_add_access") && addr_trans_mgr::check_unmapped_add(m_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || ($test$plusargs("non_secure_access_test") && (!addrMgrConst::get_addr_gprar_nsx(m_pkt.addr)) && (m_pkt.ns == 'h1)) || (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && m_scb_pkt.is_crd_zero_err == 1) || (($test$plusargs("illegal_csr_access_rd") && ((m_pkt.addr inside {[addrMgrConst::NRS_REGION_BASE : (addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE)]}))))) begin //There is no way to get configure address region map in GPR register so using plusharg
              //#Check.CHIAIU.v3.Error.decodeerr
              //#Check.CHIAIU.v3.Error.multipleaddr
              csr_addr_decode_err_addr_q.push_back(m_pkt.addr);
              csr_addr_decode_err_msg_id_q.push_back(m_pkt.txnid);
              csr_addr_decode_err_type_q.push_back(dec_err_type);

              if (m_pkt.opcode inside {write_ops}) begin 
                csr_addr_decode_err_cmd_type_q.push_back(1'b1);
              end else begin
                csr_addr_decode_err_cmd_type_q.push_back(1'b0);
              end 
            end
            // #Check.CHI.v3.6.Unsupported_Opcode
            if (m_pkt.opcode inside {unsupported_ops} ||
                $test$plusargs("user_addr_for_csr") ||
                (($test$plusargs("pick_boundary_addr") && addr_trans_mgr::check_unmapped_add(m_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || $test$plusargs("unmapped_add_access") && addr_trans_mgr::check_unmapped_add(m_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || ($test$plusargs("non_secure_access_test") && (!addrMgrConst::get_addr_gprar_nsx(m_pkt.addr)) && (m_pkt.ns == 'h1)) || (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (m_scb_pkt.is_crd_zero_err))) begin  //#Check.CHIAIU.v3.Error.unsuppoertedtxn
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : write_chi_req_port: Added a unsupported Request OR Mulitple address hit/Unmapped address txn with opcode: %0s", chi_aiu_uid, m_pkt.opcode.name()), UVM_LOW)
                <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
                if (m_pkt.opcode == PREFETCHTARGET) begin
                    return;
                end
	        <% } %>
            end
            m_scb_pkt.tb_txnid = tb_txnid;
            m_scb_pkt.chi_aiu_uid = chi_aiu_uid++;
            //sb_stall_if.perf_count_events["Active_OTT_entries"].push_back(m_ott_q.size());
            m_ott_q.push_back(m_scb_pkt);->evt_ott;
            
            find_q = {} ;
            find_q = m_ott_q.find_index with( item.isDVM == 1 &&
                                              ( item.smi_exp[`CMD_REQ_OUT] == 1 || item.smi_exp[`CMD_RSP_IN]  == 1 ||
                                                item.smi_exp[`STR_REQ_IN]  == 1 || item.smi_exp[`DTW_REQ_OUT] == 1 ||
                                                item.smi_exp[`DTW_RSP_IN]  == 1 || item.smi_exp[`CMP_RSP_IN]  == 1
                                              )
                                            );
            //#Check.CHI.v3.6.DVM.prior_non_sync_comp_needed
            if( m_scb_pkt.isDVMSync) begin
              if(find_q.size() > 0) begin
                if ($test$plusargs("sync")) begin
                  $display("Start of printing new CHI REQ received");
                  print_me(m_ott_q.size()-1);
                  $display("Start of printing DVM NON SYNC OTT element not finished");
                  foreach(find_q[idx]) begin
                    print_me(find_q[idx]);
                  end
                  `uvm_error(`LABEL_ERROR, $psprintf("CHI DVM Request Sync message received but some DVM NON-Sync does not receive COMP"))
                end else begin
                  `uvm_warning(`LABEL_ERROR, $psprintf("CHI DVM Request Sync message received but some DVM NON-Sync does not receive COMP"))
                end
              end
            end

            if (en_sb_objections) ->e_queue_change;
            spkt = {"CHIAIU_UID:%0d : write_chi_req_port: Added a CHI Request txn: %0s, CMD_REQ_OUT = %0h"};
            `uvm_info(`LABEL, $psprintf(spkt, m_scb_pkt.chi_aiu_uid, m_pkt.convert2string(), m_scb_pkt.smi_exp[`CMD_REQ_OUT]), UVM_LOW)
        end else begin
            //print_ott_info();
            spkt = {"Found a Request txn with same TxnId : %0h"};
            `uvm_error(`LABEL_ERROR, $psprintf(spkt, m_pkt.txnid))
        end
    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        end
    <%}%>
    

endfunction



//******************************************************************************
// Function : write_chi_wdata_port
// Purpose  :
//
//******************************************************************************
function void chi_aiu_scb::write_chi_wdata_port(const ref chi_dat_seq_item m_pkt);
    int              find_q[$];
    string           spkt;
    chi_dat_seq_item    exp_dat_pkt;
    bit              ott_deleted = 0;
    int              new_wdata_interleave_cnt = 0;

    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        if(start_sb) begin
    <%}%>
    

    find_q = {};
    `ifndef FSYS_COVER_ON
    cov.collect_chi_wdata_datlcrdreturn(m_pkt);
    `elsif CHI_SUBSYS_COVER_ON
    cov.collect_chi_wdata_datlcrdreturn(m_pkt);
    `endif
    find_q = m_ott_q.find_index with(
                ((item.m_chi_crsp_pkt !== null && item.m_chi_crsp_pkt.dbid == m_pkt.txnid && item.chi_exp[`WRITE_DATA_IN] == 1 && (!(m_pkt.opcode inside {SNPRESPDATA, SNPRESPDATAPTL, SNPRESPDATAFWDED})) )
                  || (item.m_chi_snp_addr_pkt !== null && item.m_chi_snp_addr_pkt.txnid == m_pkt.txnid && item.chi_exp[`CHI_SRESP] == 1 && item.exp_chi_srsp_pkt !== null && item.exp_chi_srsp_pkt.opcode == SNPRESP && m_pkt.opcode inside {SNPRESPDATA, SNPRESPDATAPTL, SNPRESPDATAFWDED}))
             );

    if(find_q.size() == 1) begin
        `uvm_info(`LABEL, $psprintf("TB_TXNID:%0d, Inbound CHI_DATA_PKT (WDATA): %0s", m_ott_q[find_q[0]].tb_txnid, m_pkt.convert2string()), UVM_MEDIUM)

        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a CHI wdata packet. Matching it with the expected CHI packet: %0s", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)

        //BW calculation: write
        if (wr_total_flits == 0) t_wr_bw_start_time = $realtime;
        t_wr_bw_end_time_wdata = $realtime;
        wr_total_flits++;

        if (m_pkt.opcode == SNPRESPDATA
            || m_pkt.opcode == SNPRESPDATAPTL
            || m_pkt.opcode == 'h6) begin //0x6=SnpRespDataFwded
            process_snp_resp_data(find_q[0], m_pkt);
            if((m_ott_q[find_q[0]].m_chi_snp_addr_pkt != null) && (m_ott_q[find_q[0]].m_chi_snp_addr_pkt.txnid == m_pkt.txnid)) begin
             `ifndef FSYS_COVER_ON
              cov.collect_snp_req_snprespdata(m_ott_q[find_q[0]]);
    	      `elsif CHI_SUBSYS_COVER_ON
              cov.collect_snp_req_snprespdata(m_ott_q[find_q[0]]);
              `endif
            end
            ev_csr_test_time_out_SNPrsp.trigger(m_ott_q[find_q[0]].m_snp_req_pkt);
        end else begin
            //not supported in Ncore TODO: WRITEDATA can be sent out of order, find a matching packet based on dataid
            exp_dat_pkt = m_ott_q[find_q[0]].exp_chi_write_data_pkt.pop_front();

            m_ott_q[find_q[0]].setup_chi_wdata_pkt(m_pkt);
            if ((m_ott_q[find_q[0]].m_chi_crsp_pkt !== null) && (m_ott_q[find_q[0]].m_chi_crsp_pkt.dbid == m_pkt.txnid) && ((m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops}))) begin
                `ifndef FSYS_COVER_ON
                     cov.collect_atomic_load_req_resp(m_ott_q[find_q[0]]);
    	      	`elsif CHI_SUBSYS_COVER_ON
                     cov.collect_atomic_load_req_resp(m_ott_q[find_q[0]]);
                `endif
            end
            //Done now TODO: These are WIP checks
            //if (!(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops}) && !$test$plusargs("unmapped_add_access"))
            if ((!(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops})) && ((!($test$plusargs("unmapped_add_access"))) || ($test$plusargs("unmapped_add_access") && (!(addr_trans_mgr::check_unmapped_add(m_ott_q[find_q[0]].m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type))))) && ($test$plusargs("pick_boundary_addr") && (!(addr_trans_mgr::check_unmapped_add(m_ott_q[find_q[0]].m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)))) && ((!($test$plusargs("non_secure_access_test"))) || ($test$plusargs("non_secure_access_test") && (m_ott_q[find_q[0]].isNSset == 0))) && ((!($test$plusargs("zero_nonzero_crd_test"))) || (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (m_ott_q[find_q[0]].is_crd_zero_err == 0))))
                check_compdata_resp_field_value(m_ott_q[find_q[0]]);
        end

        foreach (m_ott_q[i]) begin
            if (((m_ott_q[i].num_of_rdata_flit_max_exp != m_ott_q[i].num_of_rdata_flit_exp) &&
                 (m_ott_q[i].num_of_rdata_flit_exp == 1) &&
                 ((m_ott_q[i].exp_chi_srsp_pkt !== null) && (m_ott_q[i].exp_chi_srsp_pkt.opcode == SNPRESP)) &&
                 (m_ott_q[i].chi_exp[`CHI_SRESP] == 1) &&
                 ((m_ott_q[i].m_chi_snp_addr_pkt !== null) && (m_ott_q[i].m_chi_snp_addr_pkt.txnid != m_pkt.txnid))) ||
                ((m_ott_q[i].num_of_rdata_flit_max_exp != m_ott_q[i].num_of_rdata_flit_exp) &&
                 (m_ott_q[i].num_of_rdata_flit_exp > 1) &&
                 ((m_ott_q[i].exp_chi_srsp_pkt !== null) && (m_ott_q[i].exp_chi_srsp_pkt.opcode == SNPRESP)) &&
                 (m_ott_q[i].chi_exp[`CHI_SRESP] == 1)) ||
                (((m_ott_q[i].num_of_wdata_flit_max_exp - m_ott_q[i].num_of_wdata_flit_exp) == 1) &&
                 (m_ott_q[i].chi_exp[`WRITE_DATA_IN] == 1) &&
                 (m_ott_q[i].num_of_wdata_flit_exp != 0) &&
                 ((m_ott_q[i].m_chi_crsp_pkt !== null) && (m_ott_q[i].m_chi_crsp_pkt.dbid != m_pkt.txnid))) ||
                (((m_ott_q[i].num_of_wdata_flit_max_exp - m_ott_q[i].num_of_wdata_flit_exp) > 1) &&
                 (m_ott_q[i].chi_exp[`WRITE_DATA_IN] == 1) &&
                 (m_ott_q[i].num_of_wdata_flit_exp != 0))
                ) begin
                new_wdata_interleave_cnt++;
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : new_wdata_interleave_cnt = %0d", m_ott_q[i].chi_aiu_uid, new_wdata_interleave_cnt),UVM_DEBUG)
            end
        end
        if (curr_wdata_interleave_cnt != new_wdata_interleave_cnt) begin
            if (new_wdata_interleave_cnt > curr_wdata_interleave_cnt) begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : wdata_interleave event add new_intlv_cnt = %0d curr_intlv_cnt = %0d", m_ott_q[find_q[0]].chi_aiu_uid, new_wdata_interleave_cnt, curr_wdata_interleave_cnt),UVM_DEBUG)
            end
            else begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : wdata_interleave event del = %0d curr_intlv_cnt = %0d", m_ott_q[find_q[0]].chi_aiu_uid, new_wdata_interleave_cnt, curr_wdata_interleave_cnt),UVM_DEBUG)
            end
            curr_wdata_interleave_cnt = new_wdata_interleave_cnt;
            sb_stall_if.perf_count_events["Interleaved_Data"].push_back(curr_wdata_interleave_cnt);
        end
        
	if( m_ott_q[find_q[0]].m_chi_req_pkt !== null && (!(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {DVMOP})) &&
	    ((($test$plusargs("pick_boundary_addr") || $test$plusargs("unmapped_add_access")) && addr_trans_mgr::check_unmapped_add(m_ott_q[find_q[0]].m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) ||
	    ($test$plusargs("user_addr_for_csr")) || ($test$plusargs("non_secure_access_test") && m_ott_q[find_q[0]].isNSset == 1) ||
	    (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && m_ott_q[find_q[0]].is_crd_zero_err == 1))) begin
	
            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : smi_exp: 'b%0b chi_exp: 'b%0b command: %s", m_ott_q[find_q[0]].chi_aiu_uid, m_ott_q[find_q[0]].smi_exp, m_ott_q[find_q[0]].chi_exp, m_ott_q[find_q[0]].m_chi_req_pkt.opcode), UVM_LOW)
            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : smi_rcvd: 'b%0b chi_rcvd: 'b%0b command: %s", m_ott_q[find_q[0]].chi_aiu_uid, m_ott_q[find_q[0]].smi_rcvd, m_ott_q[find_q[0]].chi_rcvd, m_ott_q[find_q[0]].m_chi_req_pkt.opcode), UVM_LOW)

            //if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {write_ops}) begin
            if ((m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {write_bk, WRITEUNIQUEPTL, WRITEUNIQUEFULL}) ||
                (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {WRITENOSNPPTL, WRITENOSNPFULL} && m_ott_q[find_q[0]].m_chi_req_pkt.memattr[0] && (!m_ott_q[find_q[0]].m_chi_req_pkt.excl)) ||
                (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {atomic_dtls_ops})
               ) begin //CONC-6413 This should be the correct condition.
                if (m_ott_q[find_q[0]].smi_exp == 0 && m_ott_q[find_q[0]].chi_exp == 0) begin
                    `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : command done.", m_ott_q[find_q[0]].chi_aiu_uid), UVM_LOW)
                    `ifndef FSYS_COVER_ON
			cov.collect_chi_wdata_flit(m_ott_q[find_q[0]]);
    	      	    `elsif CHI_SUBSYS_COVER_ON
			cov.collect_chi_wdata_flit(m_ott_q[find_q[0]]);
                    `endif
                    ott_deleted = 1;
                    delete_ott_entry(find_q[0]); //#Check.CHIAIU.v3.4.Connectivity.ChiHandshake
                end
            end
        end
    end else begin
        `uvm_info(`LABEL_ERROR, $psprintf("%s",m_pkt.convert2string()),UVM_NONE)
        //print_ott_info();
        foreach (find_q[idx])
            print_me(find_q[idx]);
        spkt = {"Couldn't match WDATA txn to any pending txn"};
        if (m_pkt.txnid == 0 && $test$plusargs("link_ctrl_test")) begin
            `uvm_info("DEBUG", $psprintf("%0s. # of matches: 0x%0h", spkt, find_q.size()), UVM_NONE)
        end
        else begin
            if (!($test$plusargs("gpra_secure_uncorr_err"))) begin
                `uvm_error(`LABEL_ERROR, $psprintf("%0s. # of matches: 0x%0h", spkt, find_q.size()))
            end
        end
    end

    if((find_q.size() != 0) && (ott_deleted == 0)) begin
        `ifndef FSYS_COVER_ON
	    cov.collect_chi_wdata_flit(m_ott_q[find_q[0]]);
  	`elsif CHI_SUBSYS_COVER_ON
	    cov.collect_chi_wdata_flit(m_ott_q[find_q[0]]);
        `endif
    end
    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        end
    <%}%>

endfunction


function void chi_aiu_scb::process_snp_resp_data(int ott_idx, chi_dat_seq_item m_pkt);
    m_ott_q[ott_idx].setup_chi_snp_rsp_data(m_pkt);
    <%if(obj.testBench == "emu"){ %>
   if ($test$plusargs("SNPrsp_with_data_error") && m_pkt.resperr == 2'b10) begin
      ev_snp_rsp_err.trigger(m_ott_q[ott_idx]);
    end
    <%}%>
endfunction : process_snp_resp_data


//******************************************************************************
// Function : write_chi_srsp_port
// Purpose  :
//
//******************************************************************************
function void chi_aiu_scb::write_chi_srsp_port(const ref chi_rsp_seq_item m_pkt) ;
    int              find_q[$], find_q1[$];
    string           spkt;
    bit              dvm_ordering_err;

    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        if(start_sb) begin
    <%}%>
    


    find_q = {};
    //find_q = m_ott_q.find_index with(
    //            ((item.m_chi_snp_addr_pkt !== null
    //                && item.m_chi_snp_addr_pkt.txnid == m_pkt.txnid)
    //            || (item.m_chi_req_pkt !== null
    //                && (!item.m_chi_req_pkt.opcode inside {read_ops})
    //                && item.m_chi_crsp_pkt !== null
    //                && item.m_chi_crsp_pkt.dbid == m_pkt.txnid)
    //            || (item.m_chi_req_pkt !== null
    //                && item.m_chi_read_data_pkt.size() !== 0
    //                && item.m_chi_read_data_pkt[0].dbid == m_pkt.txnid)
    //            || (item.m_chi_req_pkt !== null
    //                && item.m_chi_req_pkt.txnid == m_pkt.txnid))
    //            && item.chi_exp[`CHI_SRESP] == 1
    //         );
    //foreach (m_ott_q[idx]) begin
    //    if (m_ott_q[idx].m_chi_snp_addr_pkt !== null)
    //    `uvm_info("NEHA", $psprintf("CHIAIU_UID:%0d : CHI SNP txnid: 0x%0h", m_ott_q[idx].chi_aiu_uid, m_ott_q[idx].m_chi_snp_addr_pkt.txnid), UVM_NONE)
    //end
    find_q = m_ott_q.find_index with(
                    ((item.m_chi_snp_addr_pkt !== null
                        && item.m_chi_srsp_pkt == null
                        && item.snp_rsp_rcvd != 1
                        && item.exp_chi_srsp_pkt !== null && item.exp_chi_srsp_pkt.opcode == SNPRESP
                        && item.m_chi_snp_addr_pkt.txnid == m_pkt.txnid
                        && m_pkt.opcode == SNPRESP)
                    || (item.m_chi_snp_addr_pkt !== null
                        && item.dbid_val
                        && item.snp_rsp_rcvd == 1
                        && item.exp_chi_srsp_pkt !== null && item.exp_chi_srsp_pkt.opcode == COMPACK
                        && m_pkt.opcode != SNPRESP
                        //&& m_pkt.opcode == COMPACK
                        && item.dbid == m_pkt.txnid)
                    || (item.m_chi_req_pkt !== null
                        && item.dbid_val == 1
                        && item.dbid == m_pkt.txnid
                        && m_pkt.opcode != SNPRESP))
                    && item.chi_exp[`CHI_SRESP] == 1
                    );

    if(find_q.size() == 1) begin
        `uvm_info(`LABEL, $psprintf("TB_TXNID:%0d, Inbound CHI_RSP_PKT (SRSP): %0s", m_ott_q[find_q[0]].tb_txnid, m_pkt.convert2string()), UVM_MEDIUM)
     //#Check.CHI.v3.6.DVM.outstanding_snp_dvm_non_sync_prior_snp_rsp
     if (m_ott_q[find_q[0]].isSnoopDVMSync ) begin
        find_q1 = {};
        find_q1 = m_ott_q.find_index with(
                (item.isDVM == 1)
                );

        dvm_ordering_err  = 0;
        foreach (find_q1[idx]) begin
            m_ott_q[find_q1[idx]].m_chi_req_pkt.convert2string();
          if ( m_ott_q[find_q1[idx]].t_chi_req_rcvd < $time) begin
            m_ott_q[find_q1[idx]].m_chi_req_pkt.convert2string();
            dvm_ordering_err = 1;
          end 
        end

        if(dvm_ordering_err) begin
          if ($test$plusargs("snp_sync")) begin
            `uvm_error(`LABEL_ERROR, $psprintf("SnpResp only sent after all DVM related operations are complete in the core"))
          end else begin
            `uvm_warning(`LABEL_ERROR, $psprintf("SnpResp only sent after all DVM related operations are complete in the core"))
          end
        end    

      end 
        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a CHI SRESP packet, matching it with expected packet:%0s.", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)
        m_ott_q[find_q[0]].exp_chi_srsp_pkt.dbid = m_pkt.dbid;
        m_ott_q[find_q[0]].exp_chi_srsp_pkt.qos = m_pkt.qos;
        m_ott_q[find_q[0]].exp_chi_srsp_pkt.datapull = m_pkt.datapull;
        m_ott_q[find_q[0]].exp_chi_srsp_pkt.fwdstate = m_pkt.fwdstate;
        m_ott_q[find_q[0]].exp_chi_srsp_pkt.pcrdtype = m_pkt.pcrdtype;
        m_ott_q[find_q[0]].exp_chi_srsp_pkt.tracetag = m_pkt.tracetag;
        m_ott_q[find_q[0]].exp_chi_srsp_pkt.resp = m_pkt.resp;

        <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
            if (m_ott_q[find_q[0]].m_chi_req_pkt !== null && m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {
                    STASHONCESEPSHARED, STASHONCESEPUNIQUE, combined_wr_unsupp_ops
                } && (m_pkt.opcode == COMPACK)
                )
            begin
                m_ott_q[find_q[0]].exp_chi_srsp_pkt.txnid = m_ott_q[find_q[0]].dbid;
            end
        <%}%>
        if (m_pkt.opcode == COMPACK) begin
            m_ott_q[find_q[0]].compack_seen = 1;
        end

     <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
          if ( k_snp_rsp_non_data_err_wgt == 0) begin // Not already set by affectation
            void'($value$plusargs("SNPrsp_with_non_data_error=%d",k_snp_rsp_non_data_err_wgt));
          end
          if (k_snp_rsp_non_data_err_wgt != 0 && (m_pkt.opcode == SNPRESP) && ((m_pkt.resperr == 'h3))) begin
              m_ott_q[find_q[0]].exp_chi_srsp_pkt.resperr = m_pkt.resperr;
              m_ott_q[find_q[0]].k_snp_rsp_non_data_err_wgt = k_snp_rsp_non_data_err_wgt;
          end else if ((k_snp_rsp_non_data_err_wgt != 0 && (m_pkt.opcode == SNPRESP) && ((m_pkt.resperr == 'h0))))begin
              m_ott_q[find_q[0]].exp_chi_srsp_pkt.resperr = m_pkt.resperr;
              m_ott_q[find_q[0]].k_snp_rsp_non_data_err_wgt = k_snp_rsp_non_data_err_wgt;
          end
     <%}%>    
        if($test$plusargs("SNPrsp_with_non_data_error")
           && m_pkt.resperr == 2'b11)/*1-non_data error*/
        begin
          m_ott_q[find_q[0]].exp_chi_srsp_pkt.resperr = 2'b11;
         <%if(obj.testBench == "emu"){ %>
           ev_snp_rsp_err.trigger(m_ott_q[find_q[0]]);
         <%}%>
        end
       if ((m_ott_q[find_q[0]].m_chi_snp_addr_pkt !== null)  && (m_ott_q[find_q[0]].m_chi_srsp_pkt == null) && (m_ott_q[find_q[0]].m_chi_snp_addr_pkt.txnid == m_pkt.txnid) && (m_ott_q[find_q[0]].exp_chi_srsp_pkt !== null) && (m_ott_q[find_q[0]].exp_chi_srsp_pkt.opcode == SNPRESP) && (m_pkt.opcode == SNPRESP)) begin
            `ifndef FSYS_COVER_ON
                cov.collect_snp_req_snpresp(m_ott_q[find_q[0]]);
  	    `elsif CHI_SUBSYS_COVER_ON
                cov.collect_snp_req_snpresp(m_ott_q[find_q[0]]);
            `endif
       end
          if (m_ott_q[find_q[0]].m_chi_req_pkt !== null && (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {dataless_ops, write_ops})) begin
            m_ott_q[find_q[0]].exp_chi_srsp_pkt.txnid = m_ott_q[find_q[0]].dbid;
        end
        if (m_ott_q[find_q[0]].snp_rsp_rcvd)
            m_ott_q[find_q[0]].exp_chi_srsp_pkt.txnid = m_ott_q[find_q[0]].dbid;
        
        <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
            if (m_ott_q[find_q[0]].m_chi_req_pkt != null) begin
                if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode == MAKEREADUNIQUE) begin
                    if (m_ott_q[find_q[0]].m_chi_req_pkt.excl && !m_ott_q[find_q[0]].mkrdunq_part1_complete) begin
                        if (m_ott_q[find_q[0]].m_str_req_pkt.smi_cmstatus_exok) begin
                            m_ott_q[find_q[0]].exp_chi_srsp_pkt.txnid = m_ott_q[find_q[0]].m_chi_crsp_pkt.dbid;
                        end else begin
                            m_ott_q[find_q[0]].exp_chi_srsp_pkt.txnid = m_ott_q[find_q[0]].m_chi_read_data_pkt[0].dbid;
                        end
                    end else begin
                        m_ott_q[find_q[0]].exp_chi_srsp_pkt.txnid = m_ott_q[find_q[0]].m_chi_read_data_pkt[0].dbid;
                    end
                end
            end
        <%}%>
        //#Check.CHI.v3.6.DVM.SNP_RSP_DVM_legal
        if (!m_ott_q[find_q[0]].exp_chi_srsp_pkt.compare(m_pkt)) begin
            print_me(find_q[0]);
            `uvm_error(`LABEL_ERROR, $psprintf("CHI srsp packet mismatch. Expected:\n%0s\nActual:\n%0s",m_ott_q[find_q[0]].exp_chi_srsp_pkt.convert2string(), m_pkt.convert2string()))
        end
        m_ott_q[find_q[0]].setup_chi_srsp_pkt(m_pkt);
        if (m_ott_q[find_q[0]].smi_exp[`SNP_DTR_REQ] == 1 && m_pkt.resperr == 2'b10) begin
          m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err = 1'b1;
          m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err_payload = 7'b000_0011;
        end
        if (m_ott_q[find_q[0]].smi_exp[`SNP_DTR_REQ] == 1 && m_pkt.resperr == 2'b11) begin
          m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err = 1'b1;
          m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err_payload = 7'b000_0100;
        end
        if (m_ott_q[find_q[0]].smi_exp == 0 && m_ott_q[find_q[0]].chi_exp == 0)
            delete_ott_entry(find_q[0]);
<% if(obj.testBench == 'chi_aiu' || obj.testBench == "fsys") { %>
      `ifdef VCS
        if(m_ott_q[find_q[0]]!=null)begin
      `endif
<%  } %> 
        if((m_ott_q[find_q[0]].chi_aiu_uid inside {STRreq_aiu_txn_ids_cmstatus_with_data_err} || m_ott_q[find_q[0]].chi_aiu_uid inside {STRreq_aiu_txn_ids_cmstatus_with_non_data_err}) && 
          ((m_ott_q[find_q[0]].smi_exp == 0 || m_ott_q[find_q[0]].smi_exp=='h80) && m_ott_q[find_q[0]].chi_exp == 0))
        begin
	    m_ott_q[find_q[0]].smi_exp = '0; 
	    m_ott_q[find_q[0]].chi_exp = '0;
            delete_ott_entry(find_q[0]);
        end
<% if(obj.testBench == 'chi_aiu' || obj.testBench == "fsys") { %>
      `ifdef VCS
       end
      `endif
<%  } %> 
    end else begin
        `uvm_info(`LABEL, $psprintf("%s",m_pkt.convert2string()),UVM_NONE)
        //print_ott_info();
        foreach (find_q[idx])
            print_me(find_q[idx]);
        spkt = {"Couldn't match SRSP txn to any pending txn"};
        if ( (m_pkt.txnid == 0 && $test$plusargs("link_ctrl_test"))
           ) begin
            `uvm_info("DEBUG", $psprintf("%0s. # of matches: 0x%0h", spkt, find_q.size()), UVM_NONE)
        end
        else begin
            if (!($test$plusargs("gpra_secure_uncorr_err"))) begin
                `uvm_error(`LABEL_ERROR, $psprintf("%0s. # of matches: 0x%0h PKT:%s", spkt, find_q.size(), m_pkt.convert2string()))
            end
        end
    end

    `ifndef FSYS_COVER_ON
	cov.collect_chi_srsp_flit(m_pkt);
    `elsif CHI_SUBSYS_COVER_ON
	cov.collect_chi_srsp_flit(m_pkt);
    `endif

    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        end
    <%}%>
    

endfunction

//******************************************************************************
// Function : write_chi_crsp_port
// Purpose  :
//
//******************************************************************************
function void chi_aiu_scb::write_chi_crsp_port(const ref chi_rsp_seq_item m_pkt) ;
    int              find_q[$];
    string           spkt;
    chi_rsp_opcode_enum_t  exp_opcode;
    bit              crsp_recvd_for_err_cmstatus;

    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        if(start_sb)begin
    <%}%>
    

    find_q = {};
    find_q = m_ott_q.find_index with(
                (item.m_chi_req_pkt !== null
                    && item.m_chi_req_pkt.txnid == m_pkt.txnid)
                && item.chi_exp[`CHI_CRESP] == 1
             );


    if(find_q.size() == 1) begin
        `uvm_info(`LABEL, $psprintf("TB_TXNID:%0d, Outbound CHI_RSP_PKT (CRSP): %0s", m_ott_q[find_q[0]].tb_txnid, m_pkt.convert2string()), UVM_MEDIUM)

        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a CHI CRESP packet: %0s.", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)
        if ((m_ott_q[find_q[0]].chi_aiu_uid inside {STRreq_aiu_txn_ids_cmstatus_with_data_err} || m_ott_q[find_q[0]].strreq_cmstatus_err_seen == 1) && (!(m_pkt.opcode inside {READRECEIPT, DBIDRESP}))) begin
            if (m_pkt.resperr !== 2'b10) begin
                `uvm_error(`LABEL_ERROR,$sformatf("Received CHI CRESP with wrong resperr = %0h for STRreq CMStatus with data Error, resperr should be 2'b10", m_pkt.resperr))
            end
            if (!(m_pkt.opcode inside {COMPDBIDRESP, COMP<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>, COMPCMO, COMPPERSIST<%}%>})) begin
		<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                `uvm_error(`LABEL_ERROR,$sformatf("CHI Pkt should be either COMPDBIDRESP or COMP or COMPCMO or COMPPERSIST, opcode = %s",m_pkt.opcode))
		<% } else { %>
                `uvm_error(`LABEL_ERROR,$sformatf("CHI Pkt should be either COMPDBIDRESP or COMP, opcode = %s",m_pkt.opcode))
		<%}%>
            end

	    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %> 
		if(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {combined_wr_c_ops}) begin
		    m_ott_q[find_q[0]].strreq_cmstatus_err_seen = 1;
		end
	   <%}%>

            STRreq_aiu_txn_ids_cmstatus_with_data_err.delete(m_ott_q[find_q[0]].chi_aiu_uid);
            m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 2'b10;
            crsp_recvd_for_err_cmstatus = 1'b1;
        end else if ((m_ott_q[find_q[0]].chi_aiu_uid inside {STRreq_aiu_txn_ids_cmstatus_with_non_data_err} || m_ott_q[find_q[0]].strreq_cmstatus_non_data_err_seen == 1) && (!(m_pkt.opcode inside {READRECEIPT, DBIDRESP}))) begin
            if (m_pkt.resperr !== 2'b11) begin
                `uvm_error(`LABEL_ERROR,$sformatf("Received CHI CRESP with wrong resperr = %0h for STRreq CMStatus with non data Error, resperr should be 2'b11", m_pkt.resperr))
            end
            if (!(m_pkt.opcode inside {COMPDBIDRESP, COMP<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>, COMPCMO, COMPPERSIST<%}%>})) begin
		<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                `uvm_error(`LABEL_ERROR,$sformatf("CHI Pkt should be either COMPDBIDRESP or COMP or COMPCMO or COMPPERSIST, opcode = %s",m_pkt.opcode))
		<% } else { %>
                `uvm_error(`LABEL_ERROR,$sformatf("CHI Pkt should be either COMPDBIDRESP or COMP, opcode = %s",m_pkt.opcode))
		<%}%>
            end

	    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %> 
		if(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {combined_wr_c_ops}) begin
		    m_ott_q[find_q[0]].strreq_cmstatus_non_data_err_seen = 1;
		end
	   <%}%>

            STRreq_aiu_txn_ids_cmstatus_with_non_data_err.delete(m_ott_q[find_q[0]].chi_aiu_uid);
            m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 2'b11;
            crsp_recvd_for_err_cmstatus = 1'b1;
        end

        if (m_ott_q[find_q[0]].chi_aiu_uid inside {CMDrsp_aiu_txn_ids_with_cmstatus_with_err}) begin
            if (m_pkt.resperr !== 2'b10) begin
                `uvm_error(`LABEL_ERROR,$sformatf("Received CHI CRESP with wrong resperr = %0h for CMDrsp CMStatus with data Error, resperr should be 2'b10", m_pkt.resperr))
            end
            if (!(m_pkt.opcode inside {COMPDBIDRESP, COMP})) begin
                `uvm_error(`LABEL_ERROR,$sformatf("CHI Pkt should be either COMPDBIDRESP or COMP, opcode = %s",m_pkt.opcode))
            end
            CMDrsp_aiu_txn_ids_with_cmstatus_with_err.delete(m_ott_q[find_q[0]].chi_aiu_uid);
            m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 2'b10;
            crsp_recvd_for_err_cmstatus = 1'b1;
        end else if (m_ott_q[find_q[0]].chi_aiu_uid inside {CMDrsp_aiu_txn_ids_with_cmstatus_with_err_other_val}) begin
            if (m_pkt.resperr !== 2'b11) begin
                `uvm_error(`LABEL_ERROR,$sformatf("Received CHI CRESP with wrong resperr = %0h for CMDsp CMStatus with non data Error, resperr should be 2'b11", m_pkt.resperr))
            end
            if (!(m_pkt.opcode inside {COMPDBIDRESP, COMP})) begin
                `uvm_error(`LABEL_ERROR,$sformatf("CHI Pkt should be either COMPDBIDRESP or COMP, opcode = %s",m_pkt.opcode))
            end
            CMDrsp_aiu_txn_ids_with_cmstatus_with_err_other_val.delete(m_ott_q[find_q[0]].chi_aiu_uid);
            m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 2'b11;
            crsp_recvd_for_err_cmstatus = 1'b1;
        end

        if (m_ott_q[find_q[0]].chi_aiu_uid inside {DTRrsp_aiu_txn_ids_with_cmstatus_with_err}) begin
            if (m_pkt.resperr !== 2'b10) begin
                `uvm_error(`LABEL_ERROR,$sformatf("Received CHI CRESP with wrong resperr = %0h for DTRrsp CMStatus with data Error, resperr should be 2'b10", m_pkt.resperr))
            end
            if (!(m_pkt.opcode inside {COMPDBIDRESP, COMP})) begin
                `uvm_error(`LABEL_ERROR,$sformatf("CHI Pkt should be either COMPDBIDRESP or COMP, opcode = %s",m_pkt.opcode))
            end
            DTRrsp_aiu_txn_ids_with_cmstatus_with_err.delete(m_ott_q[find_q[0]].chi_aiu_uid);
            m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 2'b10;
            crsp_recvd_for_err_cmstatus = 1'b1;
        end else if (m_ott_q[find_q[0]].chi_aiu_uid inside {DTRrsp_aiu_txn_ids_with_cmstatus_with_err_other_val}) begin
            if (m_pkt.resperr !== 2'b11) begin
                `uvm_error(`LABEL_ERROR,$sformatf("Received CHI CRESP with wrong resperr = %0h for DTRrsp CMStatus with non data Error, resperr should be 2'b11", m_pkt.resperr))
            end
            if (!(m_pkt.opcode inside {COMPDBIDRESP, COMP})) begin
                `uvm_error(`LABEL_ERROR,$sformatf("CHI Pkt should be either COMPDBIDRESP or COMP, opcode = %s",m_pkt.opcode))
            end
            DTRrsp_aiu_txn_ids_with_cmstatus_with_err_other_val.delete(m_ott_q[find_q[0]].chi_aiu_uid);
            m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 2'b11;
            crsp_recvd_for_err_cmstatus = 1'b1;
        end

        if ((m_ott_q[find_q[0]].chi_aiu_uid inside {DTWrsp_aiu_txn_ids_with_cmstatus_with_err} || m_ott_q[find_q[0]].dtwrsp_cmstatus_data_err_seen == 1)<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %> && (!(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {WRITEUNIQUEZERO}))<%}%>) begin
            if (m_pkt.resperr !== 2'b10) begin
                `uvm_error(`LABEL_ERROR,$sformatf("Received CHI CRESP with wrong resperr = %0h for DTWrsp CMStatus with data Error, resperr should be 2'b10", m_pkt.resperr))
            end
            if (!(m_pkt.opcode inside {COMPDBIDRESP, COMP<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>, COMPCMO, COMPPERSIST<%}%>})) begin
		<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                `uvm_error(`LABEL_ERROR,$sformatf("CHI Pkt should be either COMPDBIDRESP or COMP or COMPCMO or COMPPERSIST, opcode = %s",m_pkt.opcode))
		<% } else { %>
                `uvm_error(`LABEL_ERROR,$sformatf("CHI Pkt should be either COMPDBIDRESP or COMP, opcode = %s",m_pkt.opcode))
		<%}%>
            end 

	   <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %> 
		if(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {combined_wr_nc_ops}) begin
		    m_ott_q[find_q[0]].dtwrsp_cmstatus_data_err_seen = 1;
		end
	   <%}%>

            DTWrsp_aiu_txn_ids_with_cmstatus_with_err.delete(m_ott_q[find_q[0]].chi_aiu_uid);
            m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 2'b10;
        end else if ((m_ott_q[find_q[0]].chi_aiu_uid inside {DTWrsp_aiu_txn_ids_with_cmstatus_with_err_other_val} || m_ott_q[find_q[0]].dtwrsp_cmstatus_non_data_err_seen == 1)<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %> && (!(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {WRITEUNIQUEZERO}))<%}%>) begin
            if (m_pkt.resperr !== 2'b11) begin
                `uvm_error(`LABEL_ERROR,$sformatf("Received CHI CRESP with wrong resperr = %0h for DTWrsp CMStatus with non data Error, resperr should be 2'b11", m_pkt.resperr))
            end
            if (!(m_pkt.opcode inside {COMPDBIDRESP, COMP<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>, COMPCMO, COMPPERSIST<%}%>})) begin
		<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                `uvm_error(`LABEL_ERROR,$sformatf("CHI Pkt should be either COMPDBIDRESP or COMP or COMPCMO or COMPPERSIST, opcode = %s",m_pkt.opcode))
		<% } else { %>
                `uvm_error(`LABEL_ERROR,$sformatf("CHI Pkt should be either COMPDBIDRESP or COMP, opcode = %s",m_pkt.opcode))
		<%}%>
            end

	   <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %> 
		if(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {combined_wr_nc_ops}) begin
		    m_ott_q[find_q[0]].dtwrsp_cmstatus_non_data_err_seen = 1;
		end
	   <%}%>

            DTWrsp_aiu_txn_ids_with_cmstatus_with_err_other_val.delete(m_ott_q[find_q[0]].chi_aiu_uid);
            m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 2'b11;
        end

	if ((($test$plusargs("chiaiu_zero_credit") && m_pkt.resperr == 2'b11) || m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {unsupported_ops} ||
	    ((!(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {DVMOP})) && 
	    (($test$plusargs("non_secure_access_test") && m_ott_q[find_q[0]].isNSset == 1) ||
	    (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && m_ott_q[find_q[0]].is_crd_zero_err == 1) ||
	    (($test$plusargs("pick_boundary_addr") || $test$plusargs("unmapped_add_access")) && addr_trans_mgr::check_unmapped_add(m_ott_q[find_q[0]].m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || ($test$plusargs("user_addr_for_csr"))))) && (!(m_pkt.opcode inside {READRECEIPT, DBIDRESP}))) begin

            m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 2'b11;
            if (m_pkt.resperr !== 2'b11) begin
                `uvm_error(`LABEL_ERROR, $psprintf("RESPErr field for Unsupported transaction 2'b11, while RTL value is: 3'b%3b", m_pkt.resperr))
            end
            if(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {unsupported_ops})  //#Check.CHIAIU.v3.Error.unsuppoertedtxn
            begin
                m_ott_q[find_q[0]].smi_exp = 0;
                m_ott_q[find_q[0]].chi_exp = 0;
            	delete_ott_entry(find_q[0]);
                return;
            end
        end

        <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {dataless_ops}
        <% } else { %>
            if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {dataless_ops, STASHONCEUNIQUE, STASHONCESHARED}
        <% } %>
                && (m_pkt.opcode == COMP || m_pkt.opcode == COMPPERSIST)) begin
                    if (m_pkt.resp !== 3'b000 
                        && m_pkt.resp !== 3'b010
                        && m_pkt.resp !== 3'b001) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("RESP field for dataless operation's COMP flit should be 3'b000/010/001, while RTL value is: 3'b%3b", m_pkt.resp))
                    end
                m_ott_q[find_q[0]].exp_chi_crsp_pkt.resp = m_pkt.resp;
        end
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
                if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {WRITEBACKPTL, WRITEBACKFULL, WRITECLEANFULL, WRITEEVICTFULL}
        <% } else { %>
                if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {write_bk, atomic_dtls_ops}
        <% } %>
            && m_ott_q[find_q[0]].exp_chi_crsp_pkt.opcode == COMPDBIDRESP
            && m_pkt.opcode !== COMPDBIDRESP) begin
            print_me(find_q[0]);
            `uvm_error(`LABEL_ERROR, $psprintf("COPYBACK transactions should send a combined CompDBIDResp, while we received: %0s", m_pkt.opcode.name))
        end

        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops, write_ops}
                //&& m_ott_q[find_q[0]].smi_rcvd[`STR_REQ_IN] != 1 && !$test$plusargs("unmapped_add_access")) begin
                && m_ott_q[find_q[0]].smi_rcvd[`STR_REQ_IN] != 1 && (!$test$plusargs("non_secure_access_test") || (($test$plusargs("non_secure_access_test") && (m_ott_q[find_q[0]].isNSset == 0)))) && (!$test$plusargs("unmapped_add_access") || ($test$plusargs("unmapped_add_access") && !addr_trans_mgr::check_unmapped_add(m_ott_q[find_q[0]].m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type))) && ($test$plusargs("pick_boundary_addr") && !addr_trans_mgr::check_unmapped_add(m_ott_q[find_q[0]].m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) && (!$test$plusargs("user_addr_for_csr")) && (!$test$plusargs("zero_nonzero_crd_test") || ((($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (m_ott_q[find_q[0]].is_crd_zero_err == 0)))) ) begin
                print_me(find_q[0]);
                `uvm_error(`LABEL_ERROR, $psprintf("For any write or atomic ops, STRreq must receive first before responding to CHI processor: %0s", m_pkt.opcode.name))
            end
        <% } %>
        //#Check.CHI.v3.6.DVM.RSP_DBIDRESP_check
        if (m_pkt.opcode inside {COMPDBIDRESP, DBIDRESP}) begin
            m_ott_q[find_q[0]].dbid = m_pkt.dbid;
            m_ott_q[find_q[0]].dbid_val = 1;
        end
        if (m_pkt.opcode == COMP
            && m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {dataless_ops<%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>, MAKEREADUNIQUE<%}%>}
            && m_ott_q[find_q[0]].m_chi_req_pkt.expcompack == 1
            ) begin
            m_ott_q[find_q[0]].dbid = m_pkt.dbid;
            m_ott_q[find_q[0]].dbid_val = 1;
        end
        m_ott_q[find_q[0]].exp_chi_crsp_pkt.dbid = m_pkt.dbid;
        exp_opcode = m_ott_q[find_q[0]].exp_chi_crsp_pkt.opcode;
        if (m_ott_q[find_q[0]].exp_chi_crsp_pkt.opcode == COMPDBIDRESP) begin
            m_ott_q[find_q[0]].exp_chi_crsp_pkt.opcode = m_pkt.opcode;
        end
        if ($test$plusargs("unmapped_add_access") && addr_trans_mgr::check_unmapped_add(m_ott_q[find_q[0]].m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type) || (($test$plusargs("non_secure_access_test") && (m_ott_q[find_q[0]].isNSset == 1))) || ($test$plusargs("pick_boundary_addr") && addr_trans_mgr::check_unmapped_add(m_ott_q[find_q[0]].m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || ((($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && (m_ott_q[find_q[0]].is_crd_zero_err == 1)))) begin
            m_ott_q[find_q[0]].exp_chi_crsp_pkt.opcode = m_pkt.opcode;
        end
        if(m_pkt.opcode inside {READRECEIPT, DBIDRESP} && m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {READNOSNP, WRITENOSNPFULL, WRITENOSNPPTL} &&  m_ott_q[find_q[0]].m_chi_req_pkt.excl) begin
		    m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = m_pkt.resperr; //no check per Khaleel until COMP
        end

        <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
        if(m_pkt.opcode inside {COMP} && m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {WRITENOSNPFULL, WRITENOSNPPTL,WRITENOSNPPTL_CLEANSHARED, WRITENOSNPPTL_CLEANINV,WRITENOSNPPTL_CLEANSHAREDPERSISTSEP} &&  m_ott_q[find_q[0]].m_chi_req_pkt.excl) begin
        <%} else {%>
        if(m_pkt.opcode inside {COMP} && m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {WRITENOSNPFULL, WRITENOSNPPTL} &&  m_ott_q[find_q[0]].m_chi_req_pkt.excl) begin

        <%}%>
                    if (m_ott_q[find_q[0]].m_dtw_rsp_pkt != null) begin
		        m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = (m_ott_q[find_q[0]].m_dtw_rsp_pkt.smi_cmstatus_err && (m_ott_q[find_q[0]].m_dtw_rsp_pkt.smi_cmstatus != 'h83)) ? 2'b11 : ((m_ott_q[find_q[0]].m_dtw_rsp_pkt.smi_cmstatus_err && (m_ott_q[find_q[0]].m_dtw_rsp_pkt.smi_cmstatus == 'h83)) ? 2'b10 : (m_ott_q[find_q[0]].m_dtw_rsp_pkt.smi_cmstatus_exok ? 2'b01 : 2'b00));
                    end
        end

        if (m_ott_q[find_q[0]].chi_aiu_uid inside {STRreq_aiu_txn_ids_cmstatus_with_data_err,STRreq_aiu_txn_ids_cmstatus_with_non_data_err} && (m_pkt.opcode inside {READRECEIPT, DBIDRESP}) && (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {WRITEUNIQUEFULL, WRITEUNIQUEPTL<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>, WRITEUNIQUEZERO<% } %>})) begin
		    m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 'h0; 
        end

        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
        if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {dataless_ops} && (m_ott_q[find_q[0]].dataless_req_on_dii == 1)) begin
        <% } else { %>
        if ((m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {dataless_ops, STASHONCEUNIQUE, STASHONCESHARED}) && (m_ott_q[find_q[0]].dataless_req_on_dii == 1) && (m_ott_q[find_q[0]].m_chi_req_pkt.snpattr == 'h1)) begin
	    <% } %>
		    m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 'h3; 
        end

        //#Check.CHI.v3.6.DVM.RSP_resperr_check
        if ((m_ott_q[find_q[0]].m_chi_req_pkt.opcode == DVMOP) && (m_pkt.opcode == COMP)) begin
            if (m_ott_q[find_q[0]].exp_cmp_rsp_pkt.smi_cmstatus == 'h84) begin
		        m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 'h3; 
            end
        end

        <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
            if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {
                    STASHONCESEPSHARED, STASHONCESEPUNIQUE, combined_wr_unsupp_ops
                } && (m_pkt.opcode == COMP)
                )
            begin
		        m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 'h3;
		        m_ott_q[find_q[0]].exp_chi_crsp_pkt.tracetag = m_ott_q[find_q[0]].m_chi_req_pkt.tracetag;
            end

        <%}%>

        if (m_pkt.opcode == COMP || m_pkt.opcode == COMPPERSIST ) begin
            if ($test$plusargs("gpra_secure_uncorr_err") && (!addrMgrConst::get_addr_gprar_nsx(m_ott_q[find_q[0]].m_chi_req_pkt.addr)) && (m_ott_q[find_q[0]].m_chi_req_pkt.ns == 'h1)) begin
                m_ott_q[find_q[0]].exp_chi_crsp_pkt.resperr = 'h3;
            end
        end
        //#Check.CHI.v3.6.DVM.RSP_COMP_check
        //#Check.CHI.v3.6.DVM.RSP_DBIDRESP_check
        if (!m_ott_q[find_q[0]].exp_chi_crsp_pkt.compare(m_pkt)) begin
            print_me(find_q[0]);
            `uvm_error(`LABEL_ERROR, $psprintf("CHI crsp packet mismatch. Expected:\n%0s\nActual:\n%0s",m_ott_q[find_q[0]].exp_chi_crsp_pkt.convert2string(), m_pkt.convert2string()))
        end
        //Check the DBID value is unique for all responses.
        if (m_pkt.opcode inside {COMPDBIDRESP, DBIDRESP}) begin
            if (!(($test$plusargs("user_addr_for_csr") || $test$plusargs("unmapped_add_access") || $test$plusargs("non_secure_access_test") || $test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit") || $test$plusargs("pick_boundary_addr")) && m_ott_q[0].m_str_req_pkt == null)) begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : dbid_uniqueness check performed for, DBID: %0h", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.dbid), UVM_LOW)
                check_dbid_uniqueness(m_pkt.dbid);
            end
            else
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : dbid_uniqueness check skipped for, DBID: %0h", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.dbid), UVM_NONE)
        end
        m_ott_q[find_q[0]].exp_chi_crsp_pkt.opcode = exp_opcode;
        m_ott_q[find_q[0]].setup_chi_crsp_pkt(m_pkt);

        //#Check.CHI.v3.6.DVM.RSP_COMP_check
        if (m_pkt.opcode == COMP
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
                && m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {dataless_ops, write_ops, DVMOP}
            <% } else { %>
                && m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {dataless_ops, write_ops, DVMOP, STASHONCEUNIQUE, STASHONCESHARED}
            <% } %>
            && m_ott_q[find_q[0]].m_chi_req_pkt != null
            && m_ott_q[find_q[0]].m_chi_req_pkt.expcompack == 0
            ) begin

                //BW calculation: write
                if (m_pkt.opcode == COMP && m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {write_ops}) t_wr_bw_end_time_crsp = $realtime;

                if ($test$plusargs("unmapped_add_access") || $test$plusargs("user_addr_for_csr") || $test$plusargs("strreq_cmstatus_with_error") || $test$plusargs("non_secure_access_test") || $test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit") || $test$plusargs("pick_boundary_addr")) begin
                    //#Check.CHIAIU.v3.Error.errinatomic
                    //#Check.CHIAIU.v3.Error.strcmstatuserror
                    `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : smi_exp: 'b%0b chi_exp: 'b%0b command: %s", m_ott_q[find_q[0]].chi_aiu_uid, m_ott_q[find_q[0]].smi_exp, m_ott_q[find_q[0]].chi_exp, m_ott_q[find_q[0]].m_chi_req_pkt.opcode), UVM_LOW)
                    `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : smi_rcvd: 'b%0b chi_rcvd: 'b%0b command: %s", m_ott_q[find_q[0]].chi_aiu_uid, m_ott_q[find_q[0]].smi_rcvd, m_ott_q[find_q[0]].chi_rcvd, m_ott_q[find_q[0]].m_chi_req_pkt.opcode), UVM_LOW)

                    if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {WRITENOSNPPTL,WRITENOSNPFULL} ||
                        m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {atomic_dtls_ops}
                       ) begin
                            if (m_ott_q[find_q[0]].chi_rcvd[`WRITE_DATA_IN] != 1)
                                `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : Comp sent out before receiving WriteData packet", m_ott_q[find_q[0]].chi_aiu_uid))
                    end
                end

        	if (m_ott_q[find_q[0]].smi_exp == 0 && m_ott_q[find_q[0]].chi_exp == 0)
            		delete_ott_entry(find_q[0]);
        end

        //Fix for CONC-12790 and CONC-12901
        if((m_ott_q[find_q[0]] != null) && (m_ott_q[find_q[0]].m_chi_req_pkt != null))begin
            if(((m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {write_ops}) && (m_pkt.opcode inside {COMP}) && (m_ott_q[find_q[0]].m_chi_req_pkt.expcompack == 1))
            <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
	        || ((m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {CLEANSHAREDPERSISTSEP}) && (m_pkt.opcode inside {COMPPERSIST}) && (m_ott_q[find_q[0]].m_chi_req_pkt.expcompack == 0))
          || ((m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {WRITENOSNPZERO}) && m_pkt.resperr == 2'b11)
            <%}%>
                ) begin
                if ((m_ott_q[find_q[0]].smi_exp == 0) && (m_ott_q[find_q[0]].chi_exp == 0)) begin
                    delete_ott_entry(find_q[0]);
	        end
            end
        end

        <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>              
        if(m_ott_q[find_q[0]]!=null)begin
	    	if ((m_ott_q[find_q[0]].smi_exp == 0) && (m_ott_q[find_q[0]].chi_exp == 0) && (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {combined_wr_nc_ops, combined_wr_c_ops})) begin
            		delete_ott_entry(find_q[0]);
		end
              end
        <% } %>
        if (m_pkt.opcode == READRECEIPT && m_ott_q[find_q[0]].smi_exp == 0 && m_ott_q[find_q[0]].chi_exp == 0) begin
            		delete_ott_entry(find_q[0]);
        end
    end else begin
        <% if((obj.testBench == "fsys")) { %>
            //this part is used for fsysy NRSAR test when NRSAR is disabled to gen decerr
            if($test$plusargs("gpra_secure_uncorr_err") && m_pkt.resperr == 2'b11) begin
                //#Stimulus.FSYS.address_dec_error.illegal_non_secure_txn
                `uvm_info(`LABEL, $sformatf("expected decerr received for secure access error test rresp=%0d",m_pkt.resperr), UVM_LOW);
                kill_uncorr_grar_nsx_test.trigger(null);
	 		    return;
            end else begin 
        <% } %>  
        `uvm_info(`LABEL, $psprintf("%s",m_pkt.convert2string()),UVM_NONE)
        spkt = {"Couldn't match CRSP txn to any pending txn"};
        if (m_pkt.txnid == 0 && ($test$plusargs("link_ctrl_test") || $test$plusargs("chiaiu_zero_credit") || $test$plusargs("gpra_secure_uncorr_err") )) begin
            `uvm_info("DEBUG", $psprintf("%0s. # of matches: 0x%0h", spkt, find_q.size()), UVM_NONE)
        end
        else begin
          if ((!($test$plusargs("chiaiu_zero_credit")) && !($test$plusargs("gpra_secure_uncorr_err"))) ) begin
            //when zero credit test is enabled we expect to receive a decerr and end the simulation
            `uvm_error(`LABEL_ERROR, $psprintf("%0s PKT:%0s # of matches: 0x%0h", spkt, m_pkt.convert2string(), find_q.size()))
          end
        end
        <%if(obj.testBench == "fsys"){ %>
            end
        <%}%>
    end
    `ifndef FSYS_COVER_ON
        cov.collect_chi_crsp_flit(m_pkt);
    `elsif CHI_SUBSYS_COVER_ON
        cov.collect_chi_crsp_flit(m_pkt);
    `endif

    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        end
    <%}%>

endfunction

//******************************************************************************
// Function : write_chi_rdata_port
// Purpose  :
//
//******************************************************************************
function void chi_aiu_scb::write_chi_rdata_port(const ref chi_dat_seq_item m_pkt);
    int              find_q[$];
    int              temp_q[$];
    string           spkt;
    chi_aiu_scb_txn  m_scb_pkt;
    chi_dat_seq_item exp_dat_pkt;

    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        if(start_sb)begin
    <%}%>
    
    find_q = {};
    temp_q = {};
    find_q = m_ott_q.find_index with(
                ((item.m_chi_snp_addr_pkt !== null
                  && item.dbid_val == 1
                  && ((item.dbid == m_pkt.txnid) || (item.dbid_updated && item.dbid == m_pkt.dbid))
                  )
                || (item.m_chi_snp_addr_pkt !== null
                  && item.m_chi_srsp_pkt !== null
                  && item.m_chi_srsp_pkt.resperr == 0
                  && (((!(item.rcvd_compack)) && item.m_chi_srsp_pkt.dbid == m_pkt.txnid) || (item.rcvd_compack && item.m_chi_srsp_pkt.txnid == m_pkt.dbid)))
                || (item.m_chi_req_pkt !== null
                  && item.m_chi_req_pkt.txnid == m_pkt.txnid
                //   && ((m_pkt.dbid <= (max_ott-max_stash_snoops)) || (m_pkt.dbid > max_ott)) // FIXME: this is a VIP issue - Check how to fix
                ))
                && item.chi_exp[`COMP_DATA_OUT] == 1
             );
    

        // if (find_q.size() > 1) begin
        //     // temp_q = m_ott_q.find_index with(
        //     //     ( item.m_chi_req_pkt !== null && item.m_chi_req_pkt.txnid == m_pkt.txnid )
        //     //     && item.chi_exp[`COMP_DATA_OUT] == 1
        //     //  );
        //     //  find_q.delete(temp_q[0]);
        //     $display(" find_q size:%0d//////////////////////", find_q.size());
        //     $display("TXNID : %0d", m_pkt.txnid);
        //     $display("DBID : %0d", m_pkt.dbid);
        //     foreach(find_q[i]) begin
        //         $display("Has snp_addr_pkt? : %0s", m_ott_q[find_q[i]].m_chi_snp_addr_pkt == null ? "NO" : "YES");
        //         $display("Has chi_srsp_pkt? : %0s", m_ott_q[find_q[i]].m_chi_srsp_pkt == null ? "NO" : "YES");
        //         $display("Has chi_req_pkt? : %0s", m_ott_q[find_q[i]].m_chi_req_pkt == null ? "NO" : "YES");
        //         $display("COMP_DATA_OUT? : %0d", m_ott_q[find_q[i]].chi_exp[`COMP_DATA_OUT]);
        //         if (m_ott_q[find_q[i]].m_chi_srsp_pkt != null) begin
        //             $display("srsp dbid:%0d", m_ott_q[find_q[i]].m_chi_srsp_pkt.dbid);
        //             $display("srsp txnid:%0d", m_ott_q[find_q[i]].m_chi_srsp_pkt.txnid);
        //         end
        //         if (m_ott_q[find_q[i]].m_chi_req_pkt != null) begin
        //             $display("req_pkt txnid:%0d", m_ott_q[find_q[i]].m_chi_req_pkt.txnid);
        //         end
        //         $display("CHIAIU_UID : %0d", m_ott_q[find_q[i]].chi_aiu_uid);
        //         $display("DBID val : %0d", m_ott_q[find_q[i]].dbid_val);
        //         $display("DBID : %0d", m_ott_q[find_q[i]].dbid);
        //     end
        // end

    if(find_q.size() == 1) begin
        `uvm_info(`LABEL, $psprintf("TB_TXNID:%0d, Outbound CHI_DATA_PKT (RDATA): %0s", m_ott_q[find_q[0]].tb_txnid, m_pkt.convert2string()), UVM_MEDIUM)

        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a CHI rdata packet: %0s. Matching it with the expected packet.", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)

        //BW calculation: read
        if (rd_total_flits == 0) t_rd_bw_start_time = $realtime;
        t_rd_bw_end_time = $realtime;
        rd_total_flits++;

        //Not supported in Ncore. TODO: COMPDATA can be sent out of order, find a matching packet based on dataid
        exp_dat_pkt = m_ott_q[find_q[0]].exp_chi_read_data_pkt.pop_front();
        
        //m_ott_q[find_q[0]].dbid = m_pkt.dbid;
        //m_ott_q[find_q[0]].dbid_val = 1;

        //Certain fields cannot be predicted, copy over those fileds from RTL packet to suppress errors
        //Certain fields have multiple possible values, copy over those fields and later on add checks for them.
        exp_dat_pkt.dbid = m_pkt.dbid;
        exp_dat_pkt.data = m_pkt.data;
        exp_dat_pkt.be = m_pkt.be;
        exp_dat_pkt.rsvdc = m_pkt.rsvdc;
        // check_compdata_resp_field_value() function does the actual checking
        exp_dat_pkt.resp = m_pkt.resp;
        exp_dat_pkt.resperr = m_pkt.resperr;
        poison_q[m_ott_q[find_q[0]].chi_aiu_uid].push_back(m_pkt.poison);
        //if (m_ott_q[find_q[0]].m_chi_req_pkt !== null && (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {unsupported_ops} || $test$plusargs("unmapped_add_access") || $test$plusargs("user_addr_for_csr"))) begin
	if ((m_ott_q[find_q[0]].m_chi_req_pkt !== null && (!(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {DVMOP})) && 
	    (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {unsupported_ops} || ($test$plusargs("user_addr_for_csr") ||
	    ($test$plusargs("non_secure_access_test") && m_ott_q[find_q[0]].isNSset == 1) ||
	    (($test$plusargs("zero_nonzero_crd_test") || $test$plusargs("chiaiu_zero_credit")) && m_ott_q[find_q[0]].is_crd_zero_err == 1) || 	
	    (($test$plusargs("pick_boundary_addr") || $test$plusargs("unmapped_add_access")) && addr_trans_mgr::check_unmapped_add(m_ott_q[find_q[0]].m_chi_req_pkt.addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type))))) ||
	    ($test$plusargs("unmapped_add_access") && m_ott_q[find_q[0]].m_snp_req_pkt != null && addr_trans_mgr::check_unmapped_add(m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type))) begin
		if (m_pkt.be !== '0) begin
           	    `uvm_error(`LABEL_ERROR, $psprintf("Exp BE field for Unsupported transaction or unmapped address access or address hitting multiple address region 0, while RTL value is: %0b", m_pkt.be))
        	end
		
		if (m_pkt.resperr !== 2'b11) begin
		    `uvm_error(`LABEL_ERROR, $psprintf("RESPErr field for unmapped address access or address hitting multiple address region 2'b11, while RTL value is: 3'b%3b", m_pkt.resperr))
		end
		
		<% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A' && (obj.AiuInfo[obj.Id].interfaces.chiInt.params.wPoison>0)) { %> 
		exp_dat_pkt.poison = '1;
		if (m_pkt.poison !== '1) begin
		    `uvm_error(`LABEL_ERROR, $psprintf("Exp poison field for unmapped address access or address hitting multiple address region 1, while RTL value is: %0b", m_pkt.poison))
		end
		<% } %>
	end

        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        if (
          ($test$plusargs("unmapped_add_access") ||
          $test$plusargs("user_addr_for_csr") ||
          $test$plusargs("pick_boundary_addr") ||
          $test$plusargs("zero_nonzero_crd_test") || 
	  $test$plusargs("chiaiu_zero_credit") ||
          $test$plusargs("strreq_cmstatus_with_error") ||
          $test$plusargs("non_secure_access_test")) && m_ott_q[find_q[0]].m_chi_req_pkt != null
          ) begin
            if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {atomic_dat_ops}) begin
                //#Check.CHIAIU.v3.Error.errinatomic
                //#Check.CHIAIU.v3.Error.strcmstatuserror
                if (m_ott_q[find_q[0]].chi_rcvd[`WRITE_DATA_IN] != 1)
                    `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : CompData sent out before receiving WriteData packet", m_ott_q[find_q[0]].chi_aiu_uid))
            end
        end
        <%}%>

        if ($test$plusargs("random_dbad_value")|| $test$plusargs("dtrreq_cmstatus_with_error") || $test$plusargs("error_test")||  $test$plusargs("SNPrsp_with_data_error") ) begin
          if (m_ott_q[find_q[0]].chi_aiu_uid inside {dbad_dtr_req} || m_ott_q[find_q[0]].chi_aiu_uid inside {DTRreq_aiu_txn_ids_cmstatus_with_data_err}) begin
            if ($test$plusargs("random_dbad_value") || $test$plusargs("error_test"))begin
                int tmp_idx_val;
                bit tmp_err_val;
                bit[1:0] tmp_exp_val;
                foreach(m_ott_q[find_q[0]].m_dtr_req_pkt.smi_dp_data[i]) begin
                  if((m_ott_q[find_q[0]].m_dtr_req_pkt.smi_dp_data[i] == m_pkt.data) &&
                     (m_ott_q[find_q[0]].m_dtr_req_pkt.smi_dp_dbad[i] != 0) &&
                     (i == (m_ott_q[find_q[0]].num_of_rdata_flit_max_exp - m_ott_q[find_q[0]].num_of_rdata_flit_exp))) begin
                    tmp_err_val = 1;
                    tmp_idx_val = i;
                    break;
                  end
                end
                tmp_exp_val = (m_ott_q[find_q[0]].m_dtr_req_pkt.smi_cmstatus_err && (m_ott_q[find_q[0]].m_dtr_req_pkt.smi_cmstatus != 'h83)) ? 2'b11 : ((tmp_err_val || (m_ott_q[find_q[0]].m_dtr_req_pkt.smi_cmstatus == 'h83)) ? 2'b10 : 2'b00);
                if ((m_ott_q[find_q[0]].m_chi_req_pkt.excl == 1) && (!(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops, READNOSNP}))) begin
                  tmp_exp_val = (m_ott_q[find_q[0]].m_dtr_req_pkt.smi_cmstatus_err && (m_ott_q[find_q[0]].m_dtr_req_pkt.smi_cmstatus != 'h83)) ? 2'b11 : ((tmp_err_val || (m_ott_q[find_q[0]].m_dtr_req_pkt.smi_cmstatus == 'h83)) ? 2'b10 : 2'b01);
                end
                if ((m_ott_q[find_q[0]].m_chi_req_pkt.excl == 1) && (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {READNOSNP})) begin
                  tmp_exp_val = (m_ott_q[find_q[0]].m_dtr_req_pkt.smi_cmstatus_err && (m_ott_q[find_q[0]].m_dtr_req_pkt.smi_cmstatus != 'h83)) ? 2'b11 : ((tmp_err_val || (m_ott_q[find_q[0]].m_dtr_req_pkt.smi_cmstatus == 'h83)) ? 2'b10 : (m_ott_q[find_q[0]].m_dtr_req_pkt.smi_cmstatus_exok ? 2'b01 : 2'b00));
                end
                if((m_pkt.resperr !== tmp_exp_val) && tmp_err_val)
                  `uvm_error(`LABEL_ERROR, $sformatf("resperr != 0x%0h for respective dbad data in DTRreq, Data = %0h Act_resperr=0x%0h, checking for dtr_data[%0d][%0d]=0x%0h", tmp_exp_val, m_pkt.data, m_pkt.resperr, m_ott_q[find_q[0]].chi_aiu_uid, tmp_idx_val, m_ott_q[find_q[0]].m_dtr_req_pkt.smi_dp_data[tmp_idx_val]))
                else
                  `uvm_info(`LABEL, $sformatf("resperr == 0x%0h for respective dbad data in DTRreq, Data = %0h Act_resperr=0x%0h, checking for dtr_data[%0d][%0d]=0x%0h", tmp_exp_val, m_pkt.data, m_pkt.resperr, m_ott_q[find_q[0]].chi_aiu_uid, tmp_idx_val, m_ott_q[find_q[0]].m_dtr_req_pkt.smi_dp_data[tmp_idx_val]), UVM_DEBUG)
            end
            if($test$plusargs("dtrreq_cmstatus_with_error"))begin
              if(m_pkt.resperr !== 2'b10)
                `uvm_error(`LABEL_ERROR,$sformatf("resperr != 2'b10 for data error in cmsattus in DTRreq, Data = %0h ",m_pkt.data))
              if( m_ott_q[find_q[0]].chi_aiu_uid inside {DTRreq_aiu_txn_ids_cmstatus_with_data_err}) m_ott_q[find_q[0]].isErrFlit=1;
            end
          end
          <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A' && (obj.AiuInfo[obj.Id].interfaces.chiInt.params.wPoison>0)) { %>
          exp_dat_pkt.poison = m_pkt.poison;
          <% } %>
        end

        if (m_ott_q[find_q[0]].chi_aiu_uid inside {DTRreq_aiu_txn_ids_cmstatus_with_non_data_err}) begin
          if (m_pkt.resperr !== 2'b11) begin
            `uvm_error(`LABEL_ERROR,$sformatf("Received CHI CRESP with wrong resperr = %0h for DTRreq CMStatus with non data Error, resperr should be 2'b11", m_pkt.resperr))
          end
          DTRreq_aiu_txn_ids_cmstatus_with_non_data_err.delete(m_ott_q[find_q[0]].chi_aiu_uid);
          m_ott_q[find_q[0]].isErrFlit=1;
        end
        //We dont need this check for Ncore3.X designs because DTR type indicates cacheline state, STR is useless from AIU prospective for reads.
        //if (m_ott_q[find_q[0]].m_str_req_pkt == null
        //    && m_ott_q[find_q[0]].m_chi_req_pkt.is_coh_opcode()) begin
        //    print_me(find_q[0]);
        //    `uvm_warning(`LABEL_ERROR, $psprintf("AIU sent a CHI rdata packet before waiting for an STR REQ from SMI interface for a coherent transaction"))
        //end

        if(exp_dat_pkt.dataid  != m_pkt.dataid) begin
            `uvm_error(`LABEL_ERROR, $psprintf("CHI dat packet mismatch %0h. Expected:\n%0s\nActual:\n%0s",(exp_dat_pkt.compare(m_pkt)), exp_dat_pkt.convert2string(), m_pkt.convert2string()))
        end

        if(!exp_dat_pkt.compare(m_pkt) && m_ott_q[find_q[0]].m_dtr_req_pkt!=null ) begin
            print_me(find_q[0]);
            $stacktrace();
            `uvm_error(`LABEL_ERROR, $psprintf("CHI dat packet mismatch. Expected:\n%0s\nActual:\n%0s",exp_dat_pkt.convert2string(), m_pkt.convert2string()))
        end
	    m_ott_q[find_q[0]].setup_chi_rdata_pkt(m_pkt);
        if((m_ott_q[find_q[0]].m_chi_req_pkt != null) && (m_ott_q[find_q[0]].m_chi_req_pkt.txnid == m_pkt.txnid)) begin
           `ifndef FSYS_COVER_ON
                cov.collect_rd_ott_entry(m_ott_q[find_q[0]]);
    	    `elsif CHI_SUBSYS_COVER_ON
                cov.collect_rd_ott_entry(m_ott_q[find_q[0]]);
            `endif
        end

        //DONE now. TODO: These are WIP checks
        if(!m_pkt.resperr[1])check_compdata_resp_field_value(m_ott_q[find_q[0]]);

        if (m_ott_q[find_q[0]].smi_exp == 0 && m_ott_q[find_q[0]].chi_exp == 0)
            delete_ott_entry(find_q[0]);

    end else begin
      <% if(obj.testBench == "fsys") { %>
	    //this part is used for fsysy NRSAR test when NRSAR is disabled to gen decerr
      if($test$plusargs("gpra_secure_uncorr_err") && m_pkt.resperr == 2'b11) begin
        //#Stimulus.FSYS.address_dec_error.illegal_non_secure_txn
        `uvm_info(`LABEL, $sformatf("expected decerr received for secure access error test rresp=%0d",m_pkt.resperr), UVM_LOW);
         kill_uncorr_grar_nsx_test.trigger(null);
	 		    return;
      end else begin        
      <% } %>  

        `uvm_info(`LABEL_ERROR, $psprintf("%s",m_pkt.convert2string()),UVM_NONE)
        //print_ott_info();
        spkt = {"Couldn't match RDATA txn to any pending txn"};
        if ((m_pkt.txnid == 0 && $test$plusargs("link_ctrl_test")) 
             || $test$plusargs("chiaiu_zero_credit") 
             || $test$plusargs("gpra_secure_uncorr_err") 
             ) begin
            `uvm_info("DEBUG", $psprintf("%0s. # of matches: 0x%0h", spkt, find_q.size()), UVM_NONE)
        end
        else begin
          if ((!($test$plusargs("chiaiu_zero_credit")) && !($test$plusargs("gpra_secure_uncorr_err"))) ) begin
            //when zero credit test is enabled we expect to receive a decerr and end the simulation
            `uvm_error(`LABEL_ERROR, $psprintf("%0s : %0s. # of matches: 0x%0h", spkt, m_pkt.convert2string(), find_q.size()))
          end
        end
       <%if(obj.testBench == "fsys"){ %>
        end
      <%}%>
    end

    `ifndef FSYS_COVER_ON
	cov.collect_chi_rdata_flit(m_pkt);
    `elsif CHI_SUBSYS_COVER_ON
	cov.collect_chi_rdata_flit(m_pkt);
    `endif
    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        end
    <%}%>

endfunction


//******************************************************************************
// Function : write_chi_snpaddr_port
// Purpose  :
//
//******************************************************************************
function void chi_aiu_scb::write_chi_snpaddr_port(const ref chi_snp_seq_item m_pkt);
    int              find_q[$], find_dup_q[$];
    int              find_q_dvm[$], find_q_dvm_sync[$];
    string           spkt;
    bit              dvm_part2 = 0;
    chi_snpaddr_t    chi_snp_addr, chi_snp_addr_dup;

    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        if(start_sb)begin
    <%}%>
    

    if ((m_sysco_st == DISABLED) && (m_pkt.opcode != SNPLCRDRETURN)) begin
        `uvm_error(`LABEL_ERROR, $psprintf("Received CHI-snoop when coherency was disabled. m_sysco_st=%0s", m_sysco_st.name))
    end
    if (m_pkt.opcode == SNPDVMOP) begin
        find_q = {};
        //#Check.CHI.v3.6.DVM.SNP_DVM_REQ_legal
        find_q = m_ott_q.find_index with (
                        item.m_chi_snp_addr_pkt !== null
                        && item.m_chi_snp_addr_pkt.txnid == m_pkt.txnid
                        && item.chi_exp[`DVM_PART2_OUT] == 1
                        );

        if(find_q.size() == 1) begin
            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received second part of CHI DVM_SNP: %0s", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)
            update4sysco_snp_req(m_ott_q[find_q[0]], 1, 1);

	    if(m_ott_q[find_q[0]].m_chi_snp_addr_pkt.fwdnid == 0 && m_pkt.fwdnid != 0) begin
        	`uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d : Received second part of CHI DVM_SNP with fwdnid: 0x%0h when range bit is set to 0", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.fwdnid))  
	    end

            m_ott_q[find_q[0]].setup_chi_part_dvm_snp(m_pkt);
            dvm_part2 = 1;
        end

        if (one_dvm_sync_enable && $test$plusargs("dvm_snp_test")) begin
        find_q_dvm = {};
        find_q_dvm = m_ott_q.find_index with (
                            item.m_chi_snp_addr_pkt !== null
                            && (item.m_chi_snp_addr_pkt.opcode == SNPDVMOP)
                        );

        if ((find_q.size() != 1) && (find_q_dvm.size() >= 2)) begin
            foreach(find_q_dvm[i]) begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : pending dvm transactions in flight addr[%0d]=0x%0x", m_ott_q[find_q_dvm[i]].chi_aiu_uid, i, m_ott_q[find_q_dvm[i]].m_chi_snp_addr_pkt.addr), UVM_LOW)
            end
            `uvm_error(`LABEL_ERROR, $psprintf("CHI_DVM_SNP only 2 dvm transactions can be in flight smi_dvm_snp_addr = 0x%0x", m_pkt.addr))
        end

        find_q_dvm_sync = {};
        find_q_dvm_sync = m_ott_q.find_index with (
                            item.m_chi_snp_addr_pkt !== null
                            && (item.m_chi_snp_addr_pkt.opcode == SNPDVMOP)
                            && (item.m_chi_snp_addr_pkt.addr[10:8] == 'b100)
                        );
        if ((find_q.size() != 1) && (find_q_dvm_sync.size() >= 1) && (m_pkt.addr[10:8] == 'b100)) begin
            foreach(find_q_dvm_sync[i]) begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : pending dvm_sync transactions addr[%0d]=0x%0x", m_ott_q[find_q_dvm_sync[i]].chi_aiu_uid, i, m_ott_q[find_q_dvm_sync[i]].m_chi_snp_addr_pkt.addr), UVM_LOW)
            end
            `uvm_error(`LABEL_ERROR, $psprintf("CHI_DVM_SNP already there is above DVM sync operation in progress smi_dvm_snp_addr = 0x%0x", m_pkt.addr))
        end
        end

        if (!one_dvm_sync_enable) begin
            chi_snp_addr = dvm_snp_req_addr_q.pop_front() >> 3;
        end else begin
            if ((!dvm_part2 && (m_pkt.addr[10:8] == 'b100)) || (dvm_part2 && (m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[13:11] == 'b100) && ((m_ott_q[find_q[0]].dvm_part2_smi_addr >> 3) == m_pkt.addr))) begin
                chi_snp_addr = dvm_snp_req_addr_sync_q.pop_front() >> 3;
            end
            else begin
                chi_snp_addr = dvm_snp_req_addr_nonsync_q.pop_front() >> 3;
            end
        end
        //#Check.CHI.v3.6.DVM.SNP_REQ_DVM_order
        if(chi_snp_addr != m_pkt.addr) begin
          if (!one_dvm_sync_enable) begin
              chi_snp_addr_dup = dvm_snp_req_addr_dup_q.pop_front() >> 3;
          end else begin
              if ((!dvm_part2 && (m_pkt.addr[10:8] == 'b100)) || (dvm_part2 && (m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[13:11] == 'b100) && ((m_ott_q[find_q[0]].dvm_part2_smi_addr >> 3) == m_pkt.addr))) begin
                  chi_snp_addr = dvm_snp_req_addr_sync_dup_q.pop_front() >> 3;
              end
              else begin
                  chi_snp_addr = dvm_snp_req_addr_nonsync_dup_q.pop_front() >> 3;
              end
          end
          if(chi_snp_addr  == chi_snp_addr_dup) begin
            repeat(2) begin
                if (!one_dvm_sync_enable) begin
                    chi_snp_addr = dvm_snp_req_addr_q.pop_front() >> 3;
                end else begin
                    if ((!dvm_part2 && (m_pkt.addr[10:8] == 'b100)) || (dvm_part2 && (m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[13:11] == 'b100) && ((m_ott_q[find_q[0]].dvm_part2_smi_addr >> 3) == m_pkt.addr))) begin
                        chi_snp_addr = dvm_snp_req_addr_sync_q.pop_front() >> 3;
                    end
                    else begin
                        chi_snp_addr = dvm_snp_req_addr_nonsync_q.pop_front() >> 3;
                    end
                end
            end
            if(chi_snp_addr != m_pkt.addr) begin
              `uvm_error(`LABEL_ERROR, $psprintf("CHI_DVM_SNP skip_1_order not sent in the same order it was received on smi interface chi_snp_addr = 0x%0x smi_dvm_snp_addr = 0x%0x", m_pkt.addr, chi_snp_addr))
            end else begin
              `uvm_warning(`LABEL, $psprintf("CHI_DVM_SNP skip_1_order sent in the same order it was received on smi interface chi_snp_addr = 0x%0x smi_dvm_snp_addr = 0x%0x", m_pkt.addr, chi_snp_addr))
            end
          end else begin
            if (!one_dvm_sync_enable) begin
              foreach(dvm_snp_req_addr_dup_q[i]) begin
                `uvm_info(`LABEL, $psprintf("dup_q remained addr[%0d]=0x%0x", i, dvm_snp_req_addr_dup_q[i]), UVM_LOW)
              end
              `uvm_error(`LABEL_ERROR, $psprintf("CHI_DVM_SNP dup not sent in the same order it was received on smi interface chi_snp_addr = 0x%0x smi_dvm_snp_addr = 0x%0x, smi_dvm_snp_addr_dup = 0x%0x", m_pkt.addr, chi_snp_addr, chi_snp_addr_dup))
            end else begin
              foreach(dvm_snp_req_addr_sync_dup_q[i]) begin
                `uvm_info(`LABEL, $psprintf("sync_dup_q remained addr[%0d]=0x%0x", i, dvm_snp_req_addr_sync_dup_q[i]), UVM_LOW)
              end
              foreach(dvm_snp_req_addr_nonsync_dup_q[i]) begin
                `uvm_info(`LABEL, $psprintf("nonsync_dup_q remained addr[%0d]=0x%0x", i, dvm_snp_req_addr_nonsync_dup_q[i]), UVM_LOW)
              end
              `uvm_error(`LABEL_ERROR, $psprintf("CHI_DVM_SNP dup not sent in the same order it was received on smi interface chi_snp_addr = 0x%0x smi_dvm_snp_addr = 0x%0x, smi_dvm_snp_addr_dup = 0x%0x", m_pkt.addr, chi_snp_addr, chi_snp_addr_dup))
            end
          end
        end
        else begin
            `uvm_info(`LABEL, $psprintf("CHI_DVM_SNP sent in the same order it was received on smi interface chi_snp_addr = 0x%0x smi_dvm_snp_addr = 0x%0x", m_pkt.addr, chi_snp_addr), UVM_LOW)
        end
    end 
    if (dvm_part2 == 0) begin

        find_q = m_ott_q.find_index with((item.m_snp_req_pkt !== null
                                        && (item.m_snp_req_pkt.smi_addr >> 3) == m_pkt.addr
                                        && ((item.m_snp_req_pkt.smi_ns == m_pkt.ns) || ((item.m_snp_req_pkt.smi_msg_type == SNP_DVM_MSG) && (m_pkt.ns == 0)))
                                        && item.chi_exp[`CHI_SNP_REQ] == 1));
                                     // || (item.m_snp_req_pkt !== null
                                     //   && item.m_snp_req_pkt.smi_msg_type == SNP_DVM_MSG
                                     //   && item.dvm_part2_smi_addr_val && item.dvm_part2_smi_addr == m_pkt.addr
                                     //   && item.chi_exp[`DVM_PART2_OUT]));

        if(find_q.size() == 1) begin
            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a CHI snpaddr packet: %0s. Matching it with the expected packet.", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)
            m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.txnid = m_pkt.txnid;

       <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            if (((m_ott_q[find_q[0]].m_snp_req_pkt.smi_msg_type inside {SNP_CLN_DTR,SNP_NOSDINT,SNP_VLD_DTR,SNP_INV_DTR,SNP_NITCCI,SNP_NITCMI,SNP_NITC}) && (m_ott_q[find_q[0]].m_snp_req_pkt.smi_mpf3_intervention_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>) && (m_ott_q[find_q[0]].m_snp_req_pkt.smi_up[1:0] == 2'b11)) 
|| ((m_ott_q[find_q[0]].m_snp_req_pkt.smi_msg_type inside {SNP_CLN_DTR,SNP_NOSDINT,SNP_VLD_DTR,SNP_INV_DTR,SNP_NITCCI,SNP_NITCMI,SNP_NITC}) && (m_ott_q[find_q[0]].m_snp_req_pkt.smi_up[1:0] == 2'b01))) begin //#Check.CHIAIU.v3.SP.SnpInvDtr 
                 m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.rettosrc = 'h1;
            end else begin
                 m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.rettosrc = 'h0;
            end
       <% } else { %>
                 m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.rettosrc = 'h0;
       <% } %>

            if (m_pkt.opcode inside {stash_snps}) begin
                m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.donotdatapull = m_pkt.donotdatapull;
                m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.donotgotosd = m_pkt.donotgotosd;
            end
<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
                m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.donotdatapull = 0;
                m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.donotgotosd = 0;
<% } %>

            // Do not data pull is removed in CHI-E due to which a stashing snoop is converted to non-stashing snoop when we 
            // reach the total number stashing snoop entries
	    // `ifdef CHI_SUBSYS // Need to fix for the block level
        //     <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
        //         if (m_ott_q[find_q[0]].m_snp_req_pkt.smi_msg_type inside {SNP_INV_STSH, SNP_UNQ_STSH, SNP_STSH_SH, SNP_STSH_UNQ} &&
        //             !m_ott_q[find_q[0]].is_stash_snoop) begin
        //             m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.stashlpidvalid = 'h0;
        //             m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.stashlpid = 'h0;
        //             m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.vmidext  = 'h0;
        //             m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.fwdtxnid = 'h0;
        //             case(m_ott_q[find_q[0]].m_snp_req_pkt.smi_msg_type)
        //                 SNP_INV_STSH : m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.opcode = SNPMAKEINVALID;
        //                 SNP_UNQ_STSH : m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.opcode = SNPUNIQUE;
        //                 SNP_STSH_SH  : m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.opcode = SNPSHARED;
        //                 SNP_STSH_UNQ : m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.opcode = SNPUNIQUE;
        //                 default: `uvm_error(`LABEL_ERROR, $sformatf("Need to see how to handle this snoop : %s", m_ott_q[find_q[0]].m_snp_req_pkt.smi_msg_type))
        //             endcase
        //             if (m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.opcode inside {SNPUNIQUE, SNPCLEANSHARED, SNPCLEANINVALID, SNPMAKEINVALID}) begin
        //                 m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.donotgotosd = 'b1;
        //             end
        //         end
        //     <%}%>
	    // `else 
	    <%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            // #Check.CHI.v3.6.DoNotDataPull
                if ((m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.opcode == SNPMKINVSTASH && m_pkt.opcode == SNPMAKEINVALID) ||
		    (m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.opcode == SNPUNQSTASH && m_pkt.opcode == SNPUNIQUE) ||
    		    (m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.opcode == SNPSTASHSHRD && m_pkt.opcode == SNPSHARED) ||
		    (m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.opcode == SNPSTASHUNQ && m_pkt.opcode == SNPUNIQUE)) begin
                    m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.stashlpidvalid = 'h0;
                    m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.stashlpid = 'h0;
                    m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.vmidext  = 'h0;
                    m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.fwdtxnid = 'h0;
                    case(m_pkt.opcode)
                        SNPMAKEINVALID : m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.opcode = SNPMAKEINVALID;
                        SNPUNIQUE      : m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.opcode = SNPUNIQUE;
                        SNPSHARED      : m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.opcode = SNPSHARED;
                        default: `uvm_error(`LABEL_ERROR, $sformatf("Need to see how to handle this snoop : %s", m_ott_q[find_q[0]].m_snp_req_pkt.smi_msg_type))
                    endcase
                    if (m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.opcode inside {SNPUNIQUE, SNPCLEANSHARED, SNPCLEANINVALID, SNPMAKEINVALID}) begin
                        m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.donotgotosd = 'b1;
                    end
                end
            <%}%>
	    // `endif
            if(!m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.compare(m_pkt)) begin
                print_me(find_q[0]);
                `uvm_error(`LABEL_ERROR, $psprintf("CHI snp packet mismatch. Expected:\n%0s\nActual:\n%0s",m_ott_q[find_q[0]].exp_chi_snp_addr_pkt.convert2string(), m_pkt.convert2string()))
            end
            update4sysco_snp_req(m_ott_q[find_q[0]], 1, 0);
            m_ott_q[find_q[0]].setup_chi_snpaddr_pkt(m_pkt);
        end else begin
            `uvm_info(`LABEL, $psprintf("%s",m_pkt.convert2string()),UVM_NONE)
            //print_ott_info();
            spkt = {"Couldn't match Snoop Request txn to any pending txn"};
            if (m_pkt.txnid == 0 && $test$plusargs("link_ctrl_test")) begin
                `uvm_info("DEBUG", $psprintf(spkt), UVM_NONE)
            end
            else begin
                `uvm_error(`LABEL_ERROR, $psprintf(spkt))
            end
        end
        find_q = {};
        find_q = m_ott_q.find_index with (item.m_chi_req_pkt != null &&
                                          item.m_chi_req_pkt.addr == m_pkt.addr);
        `ifndef FSYS_COVER_ON
    	    if (find_q.size() > 0) 
           	cov.snp_addr_match_chi_req = 1;
            cov.collect_chi_snp_flit(m_pkt);
    	`elsif CHI_SUBSYS_COVER_ON
            if (find_q.size() > 0) 
           	cov.snp_addr_match_chi_req = 1;
           	cov.collect_chi_snp_flit(m_pkt);
        `endif
    end

    find_q = {};
    find_q = m_ott_q.find_index with (item.m_chi_req_pkt != null &&
                                      item.m_chi_req_pkt.addr == m_pkt.addr);
    `ifndef FSYS_COVER_ON
        if (find_q.size() > 0) 
            cov.snp_addr_match_chi_req = 1;
        else 
            cov.snp_addr_match_chi_req = 0;
        cov.collect_chi_snp_flit(m_pkt);
    `elsif CHI_SUBSYS_COVER_ON
        if (find_q.size() > 0) 
            cov.snp_addr_match_chi_req = 1;
        else 
            cov.snp_addr_match_chi_req = 0;
        cov.collect_chi_snp_flit(m_pkt);
    `endif
    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        end
    <%}%>

endfunction

//******************************************************************************
// Function : write_chi_sysco_port
// Purpose  :
//
//******************************************************************************
function void chi_aiu_scb::write_chi_sysco_port(const ref chi_base_seq_item m_pkt);
    <%if(obj.testBench == "fsys"){ %>
        //remove now sysco pin connect before csr_init //if(start_sb)begin
    <%}%>
    `uvm_info(`LABEL, $psprintf("Received a CHI sysco packet with req: 0x%0h. ack:0x%0h.", m_pkt.sysco_req, m_pkt.sysco_ack), UVM_LOW)
    setup_x_sysco_pkt(m_pkt, 1);
    if (en_sb_objections) ->e_queue_change;
    <%if(obj.testBench == "fsys"){ %>
        //remove now sysco pin connect before csr_init //end
    <%}%>
endfunction


////////////////////////////////////////////////////////////////////////////////
// Section3: SFI Write functions
//
//
////////////////////////////////////////////////////////////////////////////////


//******************************************************************************
// Function : write_smi_port
// Purpose  : Main Function for SMI Interface. Used to Route information to
//            to correct function.
//
// 1) CMDreq
// 2) DTWreq
// 3) SnpDTRreq
// 4) UPDreq
//
// 1. SnpReq
// 2. StrReq
// 3. DtrReq
//******************************************************************************
function void chi_aiu_scb::write_smi_port(const ref smi_seq_item m_pkt);
    bit is_uncorr_error_inj;
    smi_seq_item temp_pkt = smi_seq_item::type_id::create("temp_pkt");
    temp_pkt.copy(m_pkt);
    check_msgid_reuse(temp_pkt);
    `uvm_info(`LABEL, $psprintf("Received below SMI packet at CHI SCB: %0s",temp_pkt.convert2string()), UVM_LOW)

    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        if(start_sb)begin
    <%}%>
    
    // get error statistics
    num_smi_corr_err      += m_pkt.ndp_corr_error + m_pkt.hdr_corr_error + m_pkt.dp_corr_error;
    num_smi_uncorr_err    += m_pkt.ndp_uncorr_error + m_pkt.hdr_uncorr_error + m_pkt.dp_uncorr_error;
    num_smi_parity_err    += m_pkt.ndp_parity_error + m_pkt.hdr_parity_error + m_pkt.dp_parity_error;

    if(  (m_pkt.ndp_uncorr_error + m_pkt.hdr_uncorr_error + m_pkt.dp_uncorr_error)
       + (m_pkt.ndp_parity_error + m_pkt.hdr_parity_error + m_pkt.dp_parity_error)
      ) begin
      is_uncorr_error_inj = 1;
    end

<% if(obj.AiuInfo[obj.Id].concParams.hdrParams.wSteering == 0) { %>
    temp_pkt.smi_steer = '0;
<% } %>
   
    if(is_uncorr_error_inj && $test$plusargs("drop_smi_uce_pkt")) begin
      `uvm_info(`LABEL, $psprintf("DBG_RESILIENCY:: Dropping this packet due to UCE"), UVM_LOW)
      return;
    end

      if (temp_pkt.isDtwMsg()) begin
          process_dtw_req(temp_pkt);
      //end else if (temp_pkt.isDtrMsg()) begin
      //    process_snp_dtr_req(temp_pkt);
      end else if (temp_pkt.isCmdMsg()) begin
          process_cmd_req(temp_pkt);
      end else if (temp_pkt.isSnpMsg()) begin
          process_snp_req(temp_pkt);
      end else if (temp_pkt.isStrMsg()) begin
          process_str_req(temp_pkt);
      end else if (temp_pkt.isDtrMsg()) begin
          process_dtr_req(temp_pkt);
      end else if (temp_pkt.isDtwRspMsg()) begin
          process_dtw_rsp(temp_pkt);
      //end else if (temp_pkt.isDtrRspMsg()) begin
      //    process_snp_dtr_rsp(temp_pkt);
      end else if (temp_pkt.isCCmdRspMsg()) begin
          process_cmd_rsp(temp_pkt);
      end else if (temp_pkt.isNcCmdRspMsg()) begin
          process_cmd_rsp(temp_pkt);
      end else if (temp_pkt.isSnpRspMsg()) begin
          process_snp_rsp(temp_pkt);
      end else if (temp_pkt.isStrRspMsg()) begin
          process_str_rsp(temp_pkt);
      end else if (temp_pkt.isDtrRspMsg()) begin
          process_dtr_rsp(temp_pkt);
      end else if (temp_pkt.isCmpRspMsg()) begin
          process_cmp_rsp(temp_pkt);
      end else if (temp_pkt.isSysReqMsg()) begin
          process_sys_req(temp_pkt);
      end else if (temp_pkt.isSysRspMsg()) begin
          process_sys_rsp(temp_pkt);
      end else if (temp_pkt.isDtwDbgReqMsg()) begin
          temp_pkt.print();
          //balajik: TODO add check for DtwDbgReqMsg
      end else if (temp_pkt.isDtwDbgRspMsg()) begin
          temp_pkt.print();
          //balajik: TODO add check for DtwDbgRspMsg
      end else begin
          temp_pkt.print();
          `uvm_error(`LABEL_ERROR, $psprintf("Received a packet on SMI port which is not expected: "))
      end
    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
      // process sysco even if the csr isn't done
      end else if (temp_pkt.isSysReqMsg()) begin
          process_sys_req(temp_pkt);
      end else if (temp_pkt.isSysRspMsg()) begin
          process_sys_rsp(temp_pkt);
      end
    <%}%>
    
endfunction

//******************************************************************************
// Function : check_msgid_reuse
// Purpose  : For same MsgType the transId shouldn't be reused.
//
//******************************************************************************
function bit chi_aiu_scb::check_msgid_reuse(const ref smi_seq_item m_packet);
    int find_q[$];
    string spkt;

    find_q = {};
    //find_q = m_ott_q.find_index with ((
    //            (item.isSFICMDReqSent                  === 1 &&
    //             item.m_cmd_req_pkt.smi_msg_id         === m_packet.smi_msg_id &&
    //             item.isSFICMDRespRcvd                 === 0
    //            ) ||
    //            (item.isSFIDTWReqSent                  === 1 &&
    //             item.m_dtw_req_pkt.smi_msg_id     === m_packet.smi_msg_id &&
    //             item.isSFIDTWRespRcvd                 === 0
    //            ) ||
    //            (item.isSFISNPDTRReqSent               === 1 &&
    //             item.m_snp_dtr_req_pkt.smi_msg_id === m_packet.smi_msg_id &&
    //             item.isSFISNPDTRRespRcvd              === 0
    //            ) ||
    //            (item.isSFIUPDReqSent                  === 1 &&
    //             item.m_upd_req_pkt.smi_msg_id     === m_packet.smi_msg_id &&
    //             item.isSFIUPDRespRcvd                 === 0
    //            )
    //        )
    //           ||
    //        (
    //            (item.isSFISNPReqRcvd              === 1 &&
    //             item.m_snp_req_pkt.smi_msg_id === m_packet.smi_msg_id &&
    //             item.isSFISNPRespSent             === 0
    //            ) ||
    //            (item.isSFISTRReqRcvd              === 1 &&
    //            item.m_str_req_pkt.smi_msg_id  === m_packet.smi_msg_id &&
    //            item.isSFISTRRespSent              === 0
    //            ) ||
    //            (item.isSFIDTRReqRcvd              === 1 &&
    //            item.m_dtr_req_pkt.smi_msg_id  === m_packet.smi_msg_id &&
    //            item.isSFIDTRRespSent              === 0
    //            )
    //        ));
    if(find_q.size()>0) begin
        for(int i = 0; i < find_q.size; i++) begin
            print_me(find_q[i]);
        end
        `uvm_info(`LABEL, $sformatf("%1p", m_packet), UVM_NONE);
        spkt = {"Above SMI request packet seen at CHI->NOC has above",
                " outstanding SMI requests with same MsgId for which  ",
                " responses have not been received"};
        `uvm_error(`LABEL_ERROR,spkt);
        return 0;
    end else begin
        return 1;
    end

endfunction

////////////////////////////////////////////////////////////////////////////////
// Section4 : SFI Dtr,Str,Dtw,Cmd Request process functions
//
//
////////////////////////////////////////////////////////////////////////////////


//******************************************************************************
// Function : process_cmd_req
// Purpose  :
//
// Checks that are needed
// 1. Check home_dmi_id, home_dce_id, req_aiu_id,
// 2. Check CHI to SFI Command mappings
// 3. Check to ensure TransID is unique
// 4. Ensure that SFI priv fields are correct.
// 5. nCmd credit count
// 6. nDvm credit count
//
// Will add coverage related code later.
//******************************************************************************
function void chi_aiu_scb::process_cmd_req(const ref smi_seq_item m_pkt);
    string  spkt;
    int     find_q[$];
    int     qos_q[$];
    int     match_idx=0;
    bit     delete_idx_0=0;
    bit     hut = 0;
    bit [4:0]  hui = 0;
    bit     dmi_hit = 0;
    bit     dii_hit = 0;
    bit     is_prefetch_cmd1 = 0;
    bit     is_prefetch_cmd2 = 0;

    `uvm_info(`LABEL, $sformatf("INSIDE: process_cmd_req addr 0x%x smi_mpf2_flowid_valid = 0x%x smi_mpf2_flowid = 0x%x ns = 0x%x CMD_REQ_OUT = %d", m_pkt.smi_addr, m_pkt.smi_mpf2_flowid_valid, m_pkt.smi_mpf2_flowid, m_pkt.smi_ns, `CMD_REQ_OUT), UVM_MEDIUM)

    find_q = {};
    qos_q = {};
    find_q = m_ott_q.find_index with (
                item.smi_exp[`CMD_REQ_OUT] == 1                       &&
                item.m_chi_req_pkt        !== null                    &&
                item.m_chi_req_pkt.addr[WSMIADDR-1:0]   == m_pkt.smi_addr   &&
                ((item.m_chi_req_pkt.opcode inside {stash_ops} 
                    && item.m_chi_req_pkt.stashnid  == m_pkt.smi_mpf1_stash_nid)
                  || ((!(item.m_chi_req_pkt.opcode inside {stash_ops}))  
                    && (1'b1  == m_pkt.smi_mpf2_flowid_valid)
                <% if(obj.testBench == 'chi_aiu' || obj.testBench == "fsys") { %>
                    && (item.m_chi_req_pkt.lpid[<%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.LPID%>-1:0]  == m_pkt.smi_mpf2_flowid))) &&
                <%  } else {%>
                    && (item.m_chi_req_pkt.lpid[<%=obj.AiuInfo[obj.Id].concParams.cmdReqParams.wMpf2%>-2:0]  == m_pkt.smi_mpf2_flowid))) &&
                <%  } %>
                item.exp_cmd_req_pkt.smi_msg_type == m_pkt.smi_msg_type &&
                item.m_chi_req_pkt.ns     == m_pkt.smi_ns //TODO: check if ns_en is set before using smi_ns
             );

    if (find_q.size() !== 0) begin
        // for (int i = 0; i < find_q[0]; i++) begin
        foreach (m_ott_q[i]) begin
            if (m_ott_q[i].m_chi_req_pkt !== null
                && (m_ott_q[i].m_chi_req_pkt.addr[WSMIADDR-1:0] == m_pkt.smi_addr)
                && (1'b1 == m_pkt.smi_mpf2_flowid_valid)
                && (m_ott_q[i].m_chi_req_pkt.lpid[<%=obj.AiuInfo[obj.Id].interfaces.chiInt.params.LPID%>-1:0] == m_pkt.smi_mpf2_flowid)
                && (m_ott_q[i].m_chi_req_pkt.ns == m_pkt.smi_ns)
                && (m_ott_q[i].m_chi_req_pkt.opcode != DVMOP)
                && (m_pkt.smi_msg_type != CMD_DVM_MSG)
            ) begin
                if (m_ott_q[i].m_str_req_pkt == null && m_ott_q[i].m_cmd_req_pkt != null && m_ott_q[i].m_chi_req_pkt.snpattr && m_pkt.smi_ch) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d matches the current CMD_REQ's address & LPID but it hasn't yet seen STR_REQ. AIU shouldn't have sent CMD_REQ for CHIAIU_UID:%0d before all previous address collision matches have seen STR_REQ", m_ott_q[i].chi_aiu_uid, m_ott_q[find_q[0]].chi_aiu_uid))
                end else begin
                    // non-coherent atomic transaction is added to coherent atomic chain and so there will not be any address dependancy with non-coherent
                    // cmd going to the same address - CONC-12421
                    if (m_ott_q[i].m_str_req_pkt == null &&
                        m_ott_q[i].m_cmd_req_pkt != null && 
                        !m_pkt.smi_ch &&
                        !m_ott_q[i].m_chi_req_pkt.snpattr &&
                        !(m_ott_q[i].m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops}) &&
                        !(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops}) &&
                        !(m_pkt.smi_msg_type inside {CMD_CMP_ATM, CMD_SW_ATM, CMD_RD_ATM, CMD_WR_ATM})
                    ) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("CHIAIU_UID:%0d matches the current CMD_REQ's address & LPID but it hasn't yet seen STR_REQ. AIU shouldn't have sent CMD_REQ for CHIAIU_UID:%0d before all previous address collision matches have seen STR_REQ \n CMD_REQ:%0s", m_ott_q[i].chi_aiu_uid, m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()))
                    end
                end
            end
        end
    end
    // if (find_q.size() > 1) begin
    //     delete_idx_0 = 0;
    //     foreach (find_q[i]) begin
    //         if (i !== 0) begin
    //             if (m_ott_q[find_q[0]].exp_cmd_req_pkt.smi_msg_type !== m_pkt.smi_msg_type
    //                 && m_ott_q[find_q[0]].atomic_coh_part_done == 1
    //                 && m_ott_q[find_q[i]].exp_cmd_req_pkt.smi_msg_type == m_pkt.smi_msg_type) begin
    //                 match_idx = find_q[i];
    //                 find_q.delete();
    //                 find_q.push_back(match_idx);
    //                 break;
    //             end
    //         end else begin
    //             if (m_ott_q[find_q[i]].exp_cmd_req_pkt.smi_msg_type !== m_pkt.smi_msg_type
    //                 && m_ott_q[find_q[i]].atomic_coh_part_done == 1) begin
    //                 delete_idx_0 = 1;
    //                 break;
    //             end
    //         end // if i == 0
    //     end
    //     if (delete_idx_0) begin
    //         find_q.delete(0);
    //     end
    // end

    if(find_q.size() > 0) begin // When multiple matches, go with the first one(which would be the earlier one)
        spkt = {"Found matching txn for the above CMD req pkt"};
        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Found matching txn for the CMD req pkt: %0s.", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)
        m_ott_q[find_q[0]].cmd_req_sent = 1;
        // FIXME: This check is in progress, and-ing with 0 until the check is stable - SAI
        <%if (obj.AiuInfo[obj.Id].fnEnableQos && 0){%> 
            qos_q = m_ott_q.find_index with (
                item.m_chi_req_pkt != null &&
                item.m_chi_req_pkt.qos > m_ott_q[find_q[0]].m_chi_req_pkt.qos &&
                item.t_creation < m_ott_q[find_q[0]].t_creation &&
                item.cmd_req_sent == 0 &&
                item.m_chi_req_pkt.snpattr == m_ott_q[find_q[0]].m_chi_req_pkt.snpattr &&
                item.m_chi_req_pkt.opcode != PREFETCHTARGET &&
                m_ott_q[find_q[0]].m_chi_req_pkt.opcode != PREFETCHTARGET
            );
            if (qos_q.size() > 0) begin
                // is_prefetch_cmd1 = m_ott_q[find_q[0]].m_chi_req_pkt.opcode == PREFETCHTARGET;
                // is_prefetch_cmd2 = m_ott_q[qos_q[0]].m_chi_req_pkt.opcode == PREFETCHTARGET;

                // if (qos_cmd1_snpattr == qos_cmd2_snpattr) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("Qos Order Error. Current txn with CHIAIU_UID:%0d has lower priority than CHIAIU_UID:%0d", m_ott_q[find_q[0]].chi_aiu_uid, m_ott_q[qos_q[0]].chi_aiu_uid))
                // end
            end
        <%}%>
        //#Check.CHI.v3.6.DVM.REQ_receive_order
        if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode == DVMOP) begin
            m_ott_q[find_q[0]].exp_cmd_req_pkt.smi_dest_id = m_pkt.smi_dest_id; //dest_id don't care. Just copy over per Shilpa
            for(int i = 0; i < find_q[0]; i++) begin
                if (!one_dvm_sync_enable) begin
                    if (m_ott_q[i].m_chi_req_pkt !== null
                        && m_ott_q[i].m_chi_req_pkt.opcode == DVMOP
                        && m_ott_q[i].m_cmd_req_pkt == null) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("DVM sent out of order. CHIAIU_UID:%0d received a CMD_REQ, but CHIAIU_UID:%0d is an earlier DVM still pending CMD_REQ", m_ott_q[find_q[0]].chi_aiu_uid, m_ott_q[i].chi_aiu_uid))
                    end
                end else begin
                    if (m_ott_q[i].m_chi_req_pkt !== null
                        && m_ott_q[i].m_chi_req_pkt.opcode == DVMOP
                        && m_ott_q[i].m_chi_req_pkt.addr[13:11] == m_pkt.smi_addr[13:11]
                        && m_ott_q[i].m_cmd_req_pkt == null) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("DVM sent out of order. CHIAIU_UID:%0d received a CMD_REQ, but CHIAIU_UID:%0d is an earlier DVM still pending CMD_REQ", m_ott_q[find_q[0]].chi_aiu_uid, m_ott_q[i].chi_aiu_uid))
                    end
                end
            end
        end
        //copy over the fields that cannot be predicted by SCB
        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : TTRIG_DEBUG:: tracetag = 0x%0x addr = 0x%x, dii_hit = %0b, dmi_hit = %0b, hui = %0d, memattr = 0x%x opcode = 0x%x rsvdc = 0x%x exp_smi_tm = %d", m_ott_q[find_q[0]].chi_aiu_uid, m_ott_q[find_q[0]].m_chi_req_pkt.tracetag, m_ott_q[find_q[0]].m_chi_req_pkt.addr, dii_hit, dmi_hit, hui, m_ott_q[find_q[0]].m_chi_req_pkt.memattr_orig, m_ott_q[find_q[0]].m_chi_req_pkt.opcode, m_ott_q[find_q[0]].m_chi_req_pkt.rsvdc,  m_ott_q[find_q[0]].exp_smi_tm), UVM_HIGH)


        if ($test$plusargs("pick_boundary_addr") && ((find_q.size() > 1) || (find_q.size() == 1))) begin
            for(int i = 0; i < find_q.size(); i++) begin
                if ((m_ott_q[find_q[i]].m_chi_req_pkt !== null) && (m_ott_q[find_q[i]].m_chi_req_pkt.addr[WSMIADDR-1:0] == m_pkt.smi_addr) && (m_ott_q[find_q[i]].smi_exp[`CMD_REQ_OUT] == 1) && (m_ott_q[find_q[i]].m_chi_req_pkt.ns == m_pkt.smi_ns) && (m_pkt.smi_msg_type == m_ott_q[find_q[i]].get_smi_msg_type(m_ott_q[find_q[i]].m_chi_req_pkt.opcode))) begin
                        m_ott_q[find_q[i]].exp_cmd_req_pkt.smi_msg_id = m_pkt.smi_msg_id;
                        m_ott_q[find_q[i]].exp_cmd_req_pkt.smi_targ_ncore_unit_id = m_pkt.smi_targ_ncore_unit_id; //TODO -- dont ignore this value
                        if (m_addr_mgr.get_memregion_info(m_ott_q[find_q[i]].m_chi_req_pkt.addr, hut, hui)) begin
                            dmi_hit = ~hut;
                            dii_hit = hut;
                        end
                        m_ott_q[find_q[i]].exp_smi_tm = m_trace_trigger.gen_expected_traceme(m_ott_q[find_q[i]].m_chi_req_pkt.tracetag,
                                                                                    m_ott_q[find_q[i]].m_chi_req_pkt.addr, //addr
                                                                                    0, //ar
                                                                                    0, //aw
                                                                                    dii_hit, //dii_hit
                                                                                    dmi_hit, //dmi_hit
                                                                                    hui, //hui
                                                                                    m_ott_q[find_q[i]].m_chi_req_pkt.memattr_orig,
                                                                                    m_ott_q[find_q[i]].m_chi_req_pkt.opcode,
                                                                                    m_ott_q[find_q[i]].m_chi_req_pkt.rsvdc,
                                                                                    1'b1, // is_chi is true
                                                                                    m_ott_q[find_q[i]].m_chi_req_pkt.opcode == DVMOP
                                                                                    );
                        m_ott_q[find_q[i]].exp_cmd_req_pkt.smi_tm = m_ott_q[find_q[i]].exp_smi_tm;
                        `ASSERT(m_ott_q[find_q[i]].exp_cmd_req_pkt.compare(m_pkt));
                        m_ott_q[find_q[i]].add_smi_cmd_req(m_pkt);
                        break;
                end  
            end
        end else begin
          //#Check.CHI.v3.6.DVM.REQ_cmd_req_part
            if ((m_ott_q[find_q[0]].m_chi_req_pkt !== null) && (m_ott_q[find_q[0]].m_chi_req_pkt.addr[WSMIADDR-1:0] == m_pkt.smi_addr) && (m_ott_q[find_q[0]].smi_exp[`CMD_REQ_OUT] == 1) && (m_ott_q[find_q[0]].m_chi_req_pkt.ns == m_pkt.smi_ns) && (m_pkt.smi_msg_type == m_ott_q[find_q[0]].get_smi_msg_type(m_ott_q[find_q[0]].m_chi_req_pkt.opcode))) begin
                        m_ott_q[find_q[0]].exp_cmd_req_pkt.smi_msg_id = m_pkt.smi_msg_id;
                        m_ott_q[find_q[0]].exp_cmd_req_pkt.smi_targ_ncore_unit_id = m_pkt.smi_targ_ncore_unit_id; //TODO -- dont ignore this value
                        if (m_addr_mgr.get_memregion_info(m_ott_q[find_q[0]].m_chi_req_pkt.addr, hut, hui)) begin
                            dmi_hit = ~hut;
                            dii_hit = hut;
                        end
                        m_ott_q[find_q[0]].exp_smi_tm = m_trace_trigger.gen_expected_traceme(m_ott_q[find_q[0]].m_chi_req_pkt.tracetag,
                                                                                    m_ott_q[find_q[0]].m_chi_req_pkt.addr, //addr
                                                                                    0, //ar
                                                                                    0, //aw
                                                                                    dii_hit, //dii_hit
                                                                                    dmi_hit, //dmi_hit
                                                                                    hui, //hui
                                                                                    m_ott_q[find_q[0]].m_chi_req_pkt.memattr_orig,
                                                                                    m_ott_q[find_q[0]].m_chi_req_pkt.opcode,
                                                                                    m_ott_q[find_q[0]].m_chi_req_pkt.rsvdc,
                                                                                    1'b1, // is_chi is true
                                                                                    m_ott_q[find_q[0]].m_chi_req_pkt.opcode == DVMOP
                                                                                    );
                        m_ott_q[find_q[0]].exp_cmd_req_pkt.smi_tm = m_ott_q[find_q[0]].exp_smi_tm;
                        `ASSERT(m_ott_q[find_q[0]].exp_cmd_req_pkt.compare(m_pkt));
                        m_ott_q[find_q[0]].add_smi_cmd_req(m_pkt);
            end
        end
        ev_csr_test_time_out_CMDrsp_STRreq.trigger(m_ott_q[find_q[0]].m_chi_req_pkt); //#Check.CHIAIU.v3.Error.timeouterr
    end else begin
        `uvm_info(`LABEL,$sformatf("%s", m_pkt.convert2string()), UVM_NONE)
        spkt = {"Found no matching txn for the CMD req pkt: "};
        `uvm_error(`LABEL_ERROR, $psprintf("%0s%0s # of matches: 0x%0h", spkt, m_pkt.convert2string(), find_q.size()))
    end

endfunction


//******************************************************************************
// Function : process_dtw_req
// Purpose  :
//
// Checks that are needed
//
//******************************************************************************
function void chi_aiu_scb::process_dtw_req(const ref smi_seq_item m_pkt);
    string  spkt;
    bit [2:0]	   l_dwid;
    int     find_q[$];

    `uvm_info(`LABEL, $psprintf("INSIDE: process_dtw_req, RBID: %0h, rmsgid: 0x%0h targ_ncore_unit_id = 0x%0h", m_pkt.smi_rbid, m_pkt.smi_rmsg_id,m_pkt.smi_targ_ncore_unit_id), UVM_LOW)
       //   `uvm_info(`LABEL,$sformatf("process_dtw_req: %s", m_pkt.convert2string()), UVM_NONE)

    find_q = {};
    find_q = m_ott_q.find_index with (
                (item.smi_exp[`DTW_REQ_OUT] == 1
                  && ((item.m_str_req_pkt !== null
                        && item.m_str_req_pkt_2 == null
                        && item.m_str_req_pkt.smi_rbid == m_pkt.smi_rbid
                        && item.exp_dtw_req_pkt.smi_targ_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id)
                        //&& item.m_str_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id) - CONC-5022 DTW doesnt have rmsg_id
                      || (item.m_str_req_pkt_2 !== null
                        && item.m_str_req_pkt_2.smi_rbid == m_pkt.smi_rbid
                        && item.exp_dtw_req_pkt.smi_targ_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id)))
                        //&& item.m_str_req_pkt_2.smi_msg_id == m_pkt.smi_rmsg_id)))
                        //&& item.m_str_req_pkt_2.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id))) //TODO: This should match, but isn't in some cases
                || (item.smi_exp[`SNP_DTW_REQ_OUT] == 1
                  && item.m_snp_req_pkt !== null
    <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
                  && item.m_snp_req_pkt.smi_rbid == m_pkt.smi_rbid
                  && item.exp_snp_dtw_req_pkt.smi_targ_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id) //Fix: CONC-6936 TODO: Check if this condition can be added for CHI_AIU block level tests.
    <%} else { %>
                  && item.m_snp_req_pkt.smi_rbid == m_pkt.smi_rbid)
    <%}%>
                );

    if(find_q.size() == 1) begin
        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a DTW_REQ packet: %0s.", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)
        if (m_ott_q[find_q[0]].m_cmd_req_pkt != null) begin
            if (m_ott_q[find_q[0]].m_str_req_pkt == null) begin
                print_me(find_q[0]);
                `uvm_error(`LABEL_ERROR, $psprintf("DTW message observed for above packet without receiving an STR REQ"))
            end
            if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops}
                && m_ott_q[find_q[0]].m_chi_req_pkt.snpattr == 1
                && m_ott_q[find_q[0]].m_str_req_pkt_2 == null) begin
                print_me(find_q[0]);
                `uvm_error(`LABEL_ERROR, $psprintf("DTW message observed for above atomic packet without receiving the second STR REQ"))
            end
            m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_msg_id = m_pkt.smi_msg_id;
            m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_rmsg_id = m_pkt.smi_rmsg_id;
            if (!(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {stash_ops})) begin
                m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_msg_type = m_pkt.smi_msg_type;
            end
            if (m_ott_q[find_q[0]].m_str_req_pkt.smi_rbid == m_pkt.smi_rbid)
                m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_rbid = m_ott_q[find_q[0]].m_str_req_pkt.smi_rbid;
            if (m_ott_q[find_q[0]].m_str_req_pkt_2 !== null 
                && m_ott_q[find_q[0]].m_str_req_pkt_2.smi_rbid == m_pkt.smi_rbid)
                //&& m_ott_q[find_q[0]].m_str_req_pkt_2.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id) //TODO: This should match, but isn't in some cases
                m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_rbid = m_ott_q[find_q[0]].m_str_req_pkt_2.smi_rbid;
            m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_mpf1_argv = '0; //Per CHI_AIU uArch Table7 m_pkt.smi_mpf1_argv; //FIXME: What should this value be?
            m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_data = m_pkt.smi_dp_data;
            m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_user = m_pkt.smi_dp_user;
            m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_be = m_pkt.smi_dp_be;
           // m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_intfsize = m_ott_q[find_q[0]].m_str_req_pkt.smi_intfsize;
	        m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_dwid = m_pkt.smi_dp_dwid; //new[(64*8/<%=obj.AiuInfo[obj.Id].wData%>)];
            m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_dbad = new[m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_user.size()];

           // *** For NDP protection, any AIU's any NDP message should be OK ***
           <% if (obj.AiuInfo[obj.Id].concParams.cmdReqParams.wMProt > 0) { %>
            m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_protection = new[m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_user.size()];
            foreach(m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_protection[i]) begin
           <% if (obj.AiuInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                 m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_protection[i]= SMI_NDP_PROTECTION_ECC ;
           <% } else if (obj.AiuInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
                 m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_protection[i] = SMI_NDP_PROTECTION_PARITY ;
           <% } else { %>
                 m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_protection[i] = SMI_NDP_PROTECTION_NONE ;
           <% } %>
            end
           <% } %>


            foreach (m_ott_q[find_q[0]].m_chi_write_data_pkt[i]) begin
              for (int dw_i=0 ; dw_i < (wSmiDPdata/64) ; dw_i++) begin
                if (m_ott_q[find_q[0]].m_chi_write_data_pkt[i].poison[dw_i] == 1 && m_ott_q[find_q[0]].m_chi_write_data_pkt[i].be[(dw_i*8)+:8] !== 0) begin
                  m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_dbad[i][dw_i] = 1;
                end else if(m_ott_q[find_q[0]].m_chi_write_data_pkt[i].be[(dw_i*8)+:8] == 0) begin
			m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_dbad[i][dw_i]=m_ott_q[find_q[0]].m_chi_write_data_pkt[i].poison[dw_i];
                end else begin
                  m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_dbad[i][dw_i] = 0;
                end
              end
            end

            foreach (m_ott_q[find_q[0]].m_chi_write_data_pkt[i]) begin
              if (m_ott_q[find_q[0]].m_chi_write_data_pkt[i].resperr === 2'b10 || m_ott_q[find_q[0]].m_chi_write_data_pkt[i].resperr === 2'b11) begin //chi data flit Data/non-data error
                if (WDATA == wSmiDPdata) begin
                  m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_dbad[i] = '1;
                end else if (WDATA > wSmiDPdata) begin //chi data width > smi data width
                  for (int j=0; j<dword_width_diff__chi_smi_data; j++) begin
                    m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_dbad[j+(i*dword_width_diff__chi_smi_data)] = '1;
                  end
                end else if (WDATA < wSmiDPdata) begin //chi data width < smi data width
                  m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_dp_dbad[(i/dword_width_diff__smi_chi_data)] |= {no_of_dword__chi_data{1'b1}} << ((i%dword_width_diff__smi_chi_data)*no_of_dword__chi_data);
                end
              end
              if (m_ott_q[find_q[0]].m_chi_write_data_pkt[0].resperr === 2'b10) begin //chi data flit Data error, AIU indicates error in cmstatus only if 1st beat indicates error other beats error will be indicated in DBAD CONC-6610. //#Check.CHIAIU.v3.Error.dataerr
                m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_cmstatus_err = 1'b1;
                m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_cmstatus_err_payload = 7'b0000011;
              end
              if (m_ott_q[find_q[0]].m_chi_write_data_pkt[0].resperr === 2'b11) begin //chi data flit Non-Data error, AIU indicates error in cmstatus only if 1st beat indicates error other beats error will be indicated in DBAD CONC-6610. //#Check.CHIAIU.v3.Error.nondataerr
                m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_cmstatus_err = 1'b1;
                m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_cmstatus_err_payload = 7'b0000100;
              end
            end

            //m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_tm = m_pkt.smi_tm;
            m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_targ_ncore_unit_id = m_pkt.smi_targ_ncore_unit_id; // TODO
            if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {stash_ops}) begin
                m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_rl[1:0] = 2'b10;
                m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_mpf1_stash_nid =  m_ott_q[find_q[0]].m_str_req_pkt.smi_mpf1_stash_nid;
                m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_mpf2_dtr_msg_id =  m_ott_q[find_q[0]].m_str_req_pkt.smi_mpf2_dtr_msg_id;
            end else begin
                m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_mpf2_dtr_msg_id =  m_ott_q[find_q[0]].m_cmd_req_pkt.smi_msg_id;
            end

            `ASSERT(m_ott_q[find_q[0]].exp_dtw_req_pkt.compare(m_pkt));
            m_ott_q[find_q[0]].add_smi_dtw_req(m_pkt);
            //check_dtw_msg_types(m_ott_q[find_q[0]]);
        end else begin
            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_msg_id = m_pkt.smi_msg_id;
            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_rmsg_id = m_pkt.smi_rmsg_id;
            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_data = m_pkt.smi_dp_data;
            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_mpf1_stash_nid = m_pkt.smi_mpf1_stash_nid;
            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_rbid = m_pkt.smi_rbid;
            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_user = m_pkt.smi_dp_user;
            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_be = m_pkt.smi_dp_be;
            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_dwid = m_pkt.smi_dp_dwid;
            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_dbad = new[m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_user.size()];

            foreach (m_ott_q[find_q[0]].m_chi_read_data_pkt[i]) begin
              for (int dw_i=0 ; dw_i < (wSmiDPdata/64) ; dw_i++) begin
                if (m_ott_q[find_q[0]].m_chi_read_data_pkt[i].poison[dw_i] == 1 && m_ott_q[find_q[0]].m_chi_read_data_pkt[i].be[(dw_i*8)+:8] !== 0) begin
                  m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_dbad[i][dw_i] = 1;
                  //m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err = 1'b1;              //Commented as per CONC-6526
                  //m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err_payload = 7'b0000011;
                end else begin
                  m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_dbad[i][dw_i] = 0;
                end
              end
            end

            if ($test$plusargs("SNPrsp_with_data_error")) begin
              foreach (m_ott_q[find_q[0]].m_chi_snp_data_pkt[i]) begin  //CHI snp rsp data error
                if (m_ott_q[find_q[0]].m_chi_snp_data_pkt[i].resperr === 2'b10) begin 
                  if (WDATA == wSmiDPdata) begin
                    m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_dbad[i] = '1;
                  end else if (WDATA > wSmiDPdata) begin //chi data width > smi data width
                    for (int j=0; j<dword_width_diff__chi_smi_data; j++) begin
                      m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_dbad[j+(i*dword_width_diff__chi_smi_data)] = '1;
                    end
                  end else if (WDATA < wSmiDPdata) begin //chi data width < smi data width
                    m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_dbad[(i/dword_width_diff__smi_chi_data)] |= {no_of_dword__chi_data{1'b1}} << ((i%dword_width_diff__smi_chi_data)*no_of_dword__chi_data);
                  end
                end
                if (m_ott_q[find_q[0]].m_chi_snp_data_pkt[i].resperr === 2'b10) begin //chi data flit Data error
                    <%if (obj.testBench == "chi_aiu") { %>
                        m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err = 1'b1;
                        m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err_payload = 7'b0000011;
                    <% } else { %>
                        if((m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_dbad[0] != 'h0)) begin
                            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err = 1'b1;
                            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err_payload = 7'b0000011;
                        end
                    <% } %>
                end
              end
            end else begin
              foreach (m_ott_q[find_q[0]].m_chi_read_data_pkt[i]) begin
                if (m_ott_q[find_q[0]].m_chi_read_data_pkt[i].resperr === 2'b10 || m_ott_q[find_q[0]].m_chi_read_data_pkt[i].resperr === 2'b11) begin //chi data flit Data/non-data error
                  if (WDATA == wSmiDPdata) begin
                    m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_dbad[i] = '1;
                  end else if (WDATA > wSmiDPdata) begin //chi data width > smi data width
                    for (int j=0; j<dword_width_diff__chi_smi_data; j++) begin
                      m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_dbad[j+(i*dword_width_diff__chi_smi_data)] = '1;
                    end
                  end else if (WDATA < wSmiDPdata) begin //chi data width < smi data width
                    m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_dbad[(i/dword_width_diff__smi_chi_data)] |= {no_of_dword__chi_data{1'b1}} << ((i%dword_width_diff__smi_chi_data)*no_of_dword__chi_data);
                  end
                end
                if (m_ott_q[find_q[0]].m_chi_read_data_pkt[i].resperr === 2'b10) begin //chi data flit Data error
                <%if (obj.testBench == "chi_aiu") { %>
                       m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err = 1'b1;
                       m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err_payload = 7'b0000011;
                <% } else { %>  
                  if((m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_dbad[0] != 'h0)) begin
                       m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err = 1'b1;
                       m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err_payload = 7'b0000011;
                  end
                <% } %>
                end
                if (m_ott_q[find_q[0]].m_chi_read_data_pkt[i].resperr === 2'b11) begin //chi data flit Non-Data error
                  m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err = 1'b1;
                  m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err_payload = 7'b0000100;
                end
              end
            end
            if (m_ott_q[find_q[0]].m_chi_srsp_pkt != null && m_ott_q[find_q[0]].m_chi_srsp_pkt.resperr == 2'b11) begin
              m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err = 1'b1;
              m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err_payload = 7'b0000100;
            end
            if (m_ott_q[find_q[0]].m_chi_srsp_pkt != null && m_ott_q[find_q[0]].m_chi_srsp_pkt.resperr == 2'b10) begin
              m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err = 1'b1;
              m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_cmstatus_err_payload = 7'b0000011;
            end

           // *** For NDP protection, any AIU's any NDP message should be OK ***
           <% if (obj.AiuInfo[obj.Id].concParams.cmdReqParams.wMProt > 0) { %>
            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_protection = new[m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_user.size()];
            foreach(m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_protection[i]) begin
           <% if (obj.AiuInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                 m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_protection[i]= SMI_NDP_PROTECTION_ECC ;
           <% } else if (obj.AiuInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
                 m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_protection[i] = SMI_NDP_PROTECTION_PARITY ;
           <% } else { %>
                 m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_dp_protection[i] = SMI_NDP_PROTECTION_NONE ;
           <% } %>
            end
           <% } %>

            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_targ_ncore_unit_id = m_pkt.smi_targ_ncore_unit_id; //TODO: Should be DMI
            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_mpf2 = m_ott_q[find_q[0]].m_snp_req_pkt.smi_ndp[SNP_REQ_MPF2_MSB:SNP_REQ_MPF2_LSB];
            m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_intfsize = m_ott_q[find_q[0]].m_snp_req_pkt.smi_intfsize;
            if (m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_msg_type inside {DTW_MRG_MRD_UDTY, DTW_MRG_MRD_INV, DTW_MRG_MRD_UCLN, DTW_MRG_MRD_SCLN, DTW_MRG_MRD_SDTY}) begin
                m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_mpf1_dtr_tgt_id = m_ott_q[find_q[0]].m_snp_req_pkt.smi_mpf1_dtr_tgt_id;
                m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_rl[1:0] = 2'b11;
            end else //dont care
                m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.smi_ndp[DTW_REQ_MPF1_MSB:DTW_REQ_MPF1_LSB] = m_pkt.smi_ndp[DTW_REQ_MPF1_MSB:DTW_REQ_MPF1_LSB];
            `ASSERT(m_ott_q[find_q[0]].exp_snp_dtw_req_pkt.compare(m_pkt));
            m_ott_q[find_q[0]].add_smi_snp_dtw_req(m_pkt);
        end
    end else begin
        //print_ott_info();
        `uvm_info(`LABEL,$sformatf("%s -- Missing DTW", m_pkt.convert2string()), UVM_NONE)
        spkt = {"Found no matching txn for the above DTW req pkt"};
        `uvm_error(`LABEL_ERROR, $psprintf("%0s. # of matches: 0x%0h", spkt, find_q.size()))
    end

endfunction

//******************************************************************************
// Function : process_snp_dtr_req
// Purpose  :
//
// Checks that are needed
//
//******************************************************************************
function void chi_aiu_scb::process_snp_dtr_req(const ref smi_seq_item m_pkt);
    string  spkt;
    int     find_q[$];

    //find_q = {};
    //find_q = m_ott_q.find_index with (
    //         );

endfunction


//******************************************************************************
// Function : process_snp_req
// Purpose  :
//
// Checks that are needed
//
//******************************************************************************
function void chi_aiu_scb::process_snp_req(const ref smi_seq_item m_pkt);
    string           spkt;
    int              find_q[$];
    chi_aiu_scb_txn  m_scb_pkt;
    bit             dvm_part2 = 0;
    int find_q_targ_id_err[$];
    int find_q_targ_id_err_1[$];

    find_q_targ_id_err = {};
    find_q_targ_id_err_1 = {};

    //#Check.CHIAIU.sysco.nosnoopdetach
    <%if(obj.testBench == "fsys"){ %>
    if (m_sysco_st == DISABLED) begin
        `uvm_error(`LABEL_ERROR, $psprintf("Received SMI-snoop when coherency was disabled. m_sysco_st=%0s", m_sysco_st.name))
    end
    <% } %>
    
    // #Stimulus.FSYS.connectivity.AIUtoDCE
    if(addr_trans_mgr::check_aiu_is_unconnected(.tgt_unit_id(m_pkt.smi_targ_ncore_unit_id), .src_unit_id(m_pkt.smi_src_ncore_unit_id))) begin
      `uvm_error(`LABEL_ERROR,
      $sformatf("In SNP_REQ, Connectivity between TGT FUnitID %0d and SRC FUnitID %0d should have been optimized and not existing", m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_src_ncore_unit_id))
    end

    if ($test$plusargs("wrong_snpreq_target_id")) begin //#Check.CHIAIU.v3.Error.snpreq
      if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        `ifndef FSYS_COVER_ON
        cov.collect_snp_req_wtgtid(m_pkt);
     	`elsif CHI_SUBSYS_COVER_ON
        cov.collect_snp_req_wtgtid(m_pkt);
        `endif
        `uvm_info(`LABEL,$sformatf("SNPreq targ_id = %0h, src_id = %0h, smi_msg_id = %0h",m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id),UVM_NONE)
        find_q_targ_id_err_1 = snp_targ_err_msg_id.find_index with (item.src_id == m_pkt.smi_src_ncore_unit_id &&
                                                                    item.msg_id == m_pkt.smi_msg_id);
        if (find_q_targ_id_err_1.size() == 1) begin
          snp_targ_err_msg_id[find_q_targ_id_err_1[0]] = '{m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id};
        end else if (find_q_targ_id_err_1.size() == 0) begin
          snp_targ_err_msg_id.push_back( '{m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id} );
        end
      end else begin
        find_q_targ_id_err = snp_targ_err_msg_id.find_index with (item.src_id == m_pkt.smi_src_ncore_unit_id &&
                                                                  item.msg_id == m_pkt.smi_msg_id
                                                                 );

        if (find_q_targ_id_err.size()== 1 && m_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
          snp_targ_err_msg_id.delete(find_q_targ_id_err[0]);
        end
      end
    end
    if(m_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
    if (m_pkt.smi_msg_type == SNP_RECALL) begin
        `uvm_error(`LABEL_ERROR, $psprintf("Received an unexpected type of snoop SNP_RECALL"))
    end else begin
      //#Check.CHI.v3.6.DVM.SNP_REQ_second_part_addr_mpf_field
      //#Check.CHI.v3.6.DVM.SNP_REQ_second_part_other_field
        if (m_pkt.smi_msg_type == SNP_DVM_MSG) begin
          
            find_q = {};
            find_q = m_ott_q.find_index with (
                        item.m_snp_req_pkt !== null
                        && item.m_snp_req_pkt.smi_msg_id == m_pkt.smi_msg_id
                        && item.m_snp_req_pkt.smi_msg_type == SNP_DVM_MSG
                        && item.m_snp_req_pkt.smi_addr[3] == (!m_pkt.smi_addr[3])
                        && item.smi_exp[`DVM_PART2_IN] == 1
                        );

            if(find_q.size() == 1) begin
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received second part of DVM_SNP.", m_ott_q[find_q[0]].chi_aiu_uid), UVM_LOW)
                if(m_pkt.smi_addr[3] != 1'b1) begin
                  `uvm_error(`LABEL_ERROR, $psprintf("SNP_DVM_MSG is received out of order. Here is 1st part of SNP_DVM_MSG: %0s", m_pkt.convert2string()))
                end
                `ifdef USE_VIP_SNPS_CHI
                // TG and TTL fields are inapplicable and must be set to zero in non-range based TLBI operations which are not by VA or IPA.
                // Range, Num, Scale, TG, and TTL fields are inapplicable and must be set to zero in all non-TLBI DVM operations
                  if ( m_pkt.smi_mpf3_num[WSMIMPF3-1:5] != 'b0 ||
                      (m_pkt.smi_mpf3_num !== 0  && m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[13:11] == 'h0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_mpf3_range == 'h0) || // Num field
                      (m_pkt.smi_addr[5:4] !== 0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[13:11] == 'h0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_mpf3_range == 'h0) || // Scale field
                      (m_pkt.smi_addr[7:6] !== 0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[13:11] == 'h0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_mpf3_range == 'h0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[4] != 'b1 )   || // TTL field 
                      (m_pkt.smi_addr[9:8] !== 0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[13:11] == 'h0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_mpf3_range == 'h0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[4] != 'b1 )      // TG field 
                      ) begin
                    `uvm_info(`LABEL_ERROR, $psprintf("Error Check Part 1 : %0h",m_pkt.smi_mpf3_num[WSMIMPF3-1:5] ),UVM_NONE)
                    `uvm_info(`LABEL_ERROR, $psprintf("Error Check Part 2 : %0h", (m_pkt.smi_mpf3_num !== 0  && m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[13:11] == 'h0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_mpf3_range == 'h0)),UVM_NONE)
                    `uvm_info(`LABEL_ERROR, $psprintf("Error Check Part 3 : %0h", (m_pkt.smi_addr[5:4] !== 0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[13:11] == 'h0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_mpf3_range == 'h0)),UVM_NONE)
                    `uvm_info(`LABEL_ERROR, $psprintf("Error Check Part 4 : %0h", (m_pkt.smi_addr[7:6] !== 0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[13:11] == 'h0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_mpf3_range == 'h0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[4] != 'b1 )),UVM_NONE)
                    `uvm_info(`LABEL_ERROR, $psprintf("Error Check Part 5 : %0h", (m_pkt.smi_addr[9:8] !== 0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[13:11] == 'h0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_mpf3_range == 'h0 && m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[4] != 'b1 )),UVM_NONE)
                    `uvm_info(`LABEL_ERROR, $psprintf("SNP_DVM_MSG Part 1 received: %0s", m_ott_q[find_q[0]].m_snp_req_pkt.convert2string()),UVM_NONE)
                    `uvm_error(`LABEL_ERROR, $psprintf("SNP_DVM_MSG Part 2 received does not respect restrictions fied values", m_pkt.convert2string()))
                  end
                `endif

                update4sysco_snp_req(m_ott_q[find_q[0]], 0, 1);
                m_ott_q[find_q[0]].setup_part_dvm_snp(m_pkt);
                dvm_part2 = 1;
                if(m_ott_q[find_q[0]].smi_sysco_state == DISABLED ) begin
                  `uvm_info(`LABEL, $psprintf("SMI_DVM_SNP 2nd part not pushed to dvm_snp_req_addr_q smi_dvm_snp_addr = 0x%0x", m_pkt.smi_addr), UVM_LOW)
                end else begin
                  if (!one_dvm_sync_enable) begin
                    dvm_snp_req_addr_q.push_back(m_pkt.smi_addr);
                  end else begin
                    if ((!dvm_part2 && (m_pkt.smi_addr[13:11] == 'b100)) || (dvm_part2 && (m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[13:11] == 'b100) && (m_ott_q[find_q[0]].dvm_part2_smi_addr == m_pkt.smi_addr))) begin
                        dvm_snp_req_addr_sync_q.push_back(m_pkt.smi_addr);
                    end
                    else begin
                        dvm_snp_req_addr_nonsync_q.push_back(m_pkt.smi_addr);
                    end
                  end
                  `uvm_info(`LABEL, $psprintf("SMI_DVM_SNP 2nd part pushed to dvm_snp_req_addr_q smi_dvm_snp_addr = 0x%0x", m_pkt.smi_addr), UVM_LOW)
                end
                if(m_ott_q[find_q[0]].smi_sysco_state inside {DISCONNECT, CONNECT}) begin
                  if (!one_dvm_sync_enable) begin
                    dvm_snp_req_addr_dup_q.push_back(m_pkt.smi_addr);
                  end else begin
                    if ((!dvm_part2 && (m_pkt.smi_addr[13:11] == 'b100)) || (dvm_part2 && (m_ott_q[find_q[0]].m_snp_req_pkt.smi_addr[13:11] == 'b100) && (m_ott_q[find_q[0]].dvm_part2_smi_addr == m_pkt.smi_addr))) begin
                        dvm_snp_req_addr_sync_dup_q.push_back(m_pkt.smi_addr);
                    end
                    else begin
                        dvm_snp_req_addr_nonsync_dup_q.push_back(m_pkt.smi_addr);
                    end
                  end
                  `uvm_info(`LABEL, $psprintf("SMI_DVM_SNP 2nd part pushed to dvm_snp_req_addr_dup_q smi_dvm_snp_addr = 0x%0x", m_pkt.smi_addr), UVM_LOW)
                end
            end else if(find_q.size() == 0) begin
              if(get_cur_sysco_state == DISABLED ) begin
                `uvm_info(`LABEL, $psprintf("SMI_DVM_SNP 1st part not pushed to dvm_snp_req_addr_q smi_dvm_snp_addr = 0x%0x", m_pkt.smi_addr), UVM_LOW)
              end else begin
                if (!one_dvm_sync_enable) begin
                  dvm_snp_req_addr_q.push_back(m_pkt.smi_addr);
                end else begin
                  if (m_pkt.smi_addr[13:11] == 'b100) begin
                      dvm_snp_req_addr_sync_q.push_back(m_pkt.smi_addr);
                  end
                  else begin
                      dvm_snp_req_addr_nonsync_q.push_back(m_pkt.smi_addr);
                  end
                end
                `uvm_info(`LABEL, $psprintf("SMI_DVM_SNP 1st part pushed to dvm_snp_req_addr_q smi_dvm_snp_addr = 0x%0x", m_pkt.smi_addr), UVM_LOW)
              end
              if(get_cur_sysco_state inside {DISCONNECT, CONNECT}) begin
                if (!one_dvm_sync_enable) begin
                  dvm_snp_req_addr_dup_q.push_back(m_pkt.smi_addr);
                end else begin
                  if (m_pkt.smi_addr[13:11] == 'b100) begin
                      dvm_snp_req_addr_sync_dup_q.push_back(m_pkt.smi_addr);
                  end
                  else begin
                      dvm_snp_req_addr_nonsync_dup_q.push_back(m_pkt.smi_addr);
                  end
                end
                `uvm_info(`LABEL, $psprintf("SMI_DVM_SNP 1st part pushed to dvm_snp_req_addr_dup_q smi_dvm_snp_addr = 0x%0x", m_pkt.smi_addr), UVM_LOW)
              end
              if(m_pkt.smi_addr[3] != 1'b0) begin
                `uvm_error(`LABEL_ERROR, $psprintf("SNP_DVM_MSG is received out of order. Here is 2nd part of SNP_DVM_MSG: %0s", m_pkt.convert2string()))
              end

              `ifdef USE_VIP_SNPS_CHI
                // The Range bit must be zero if either:
                // - DVM_v8.4 is not supported.
                // - The message type is not TLB Invalidate by IPA or VA
              if ( m_pkt.smi_mpf3_range[WSMIMPF3-1:1] != 'b0 ||
                  <% if(!DVMV8_4) {%>
                  m_pkt.smi_mpf3_range != 0 ||
                  <% } %> 
                  (m_pkt.smi_mpf3_range != 0 && (m_pkt.smi_addr[13:11]!='h0 && m_pkt.smi_addr[1] != 'h1) ) ) begin
                  `uvm_error(`LABEL_ERROR, $psprintf("SNP_DVM_MSG Part 1 received does not respect restrictions fied values", m_pkt.convert2string()))
                end
              `endif
            end
        end 

        if (dvm_part2 == 0) begin
            //#Check.CHI.v3.6.DVM.SNP_REQ_first_part_addr_mpf_field
            //#Check.CHI.v3.6.DVM.SNP_REQ_first_part_other_field
            m_scb_pkt = new(,m_req_aiu_id);
            update4sysco_snp_req(m_scb_pkt, 0, 0);
            m_scb_pkt.setup_smi_snoop_req(m_pkt);
            m_scb_pkt.tb_txnid = tb_txnid;
            m_scb_pkt.chi_aiu_uid = chi_aiu_uid++;
            foreach (m_ott_q[idx]) begin
                if (m_ott_q[idx].m_chi_req_pkt !== null
                    && m_ott_q[idx].m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops}
                    && m_ott_q[idx].m_chi_req_pkt.snoopme == 1
                    && m_ott_q[idx].m_chi_req_pkt.addr == m_pkt.smi_addr
                    && m_pkt.smi_msg_type !== SNP_DVM_MSG)
                begin
                    m_ott_q[idx].snp_chi_aiu_uid = m_scb_pkt.chi_aiu_uid;
                    m_ott_q[idx].snp_generated = 1;

                end
            end
	        // FIXME - comment out until CONC-5752 is fixed
            foreach (m_ott_q[idx]) begin
                if (!one_dvm_sync_enable) begin
                    if (m_ott_q[idx].m_snp_req_pkt !== null
                        && m_ott_q[idx].m_snp_req_pkt.smi_addr[WSMIADDR-1:6] == m_pkt.smi_addr[WSMIADDR-1:6]
                        && m_ott_q[idx].m_snp_req_pkt.smi_ns == m_pkt.smi_ns
                        && m_ott_q[idx].m_snp_rsp_pkt == null) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("2nd snoop on same cacheline received: CHIAIU_UID:%0d matches address and ns bit with current snoop: %0s", m_ott_q[idx].chi_aiu_uid, m_pkt.convert2string()))
                    end
                end else begin
                    if (m_ott_q[idx].m_snp_req_pkt !== null
                        && m_ott_q[idx].m_snp_req_pkt.smi_addr[WSMIADDR-1:6] == m_pkt.smi_addr[WSMIADDR-1:6]
                        && m_ott_q[idx].m_snp_req_pkt.smi_ns == m_pkt.smi_ns
                        && m_pkt.smi_msg_type !== SNP_DVM_MSG
                        && m_ott_q[idx].m_snp_req_pkt.smi_msg_type !== SNP_DVM_MSG
                        && m_ott_q[idx].m_snp_rsp_pkt == null) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("2nd snoop on same cacheline received: CHIAIU_UID:%0d matches address and ns bit with current snoop: %0s", m_ott_q[idx].chi_aiu_uid, m_pkt.convert2string()))
                    end
                end
            end

            if (m_pkt.smi_msg_type inside {SNP_INV_STSH, SNP_UNQ_STSH, SNP_STSH_SH, SNP_STSH_UNQ}) begin
                if (outstanding_stsh_snoops == max_stash_snoops) begin
                    m_scb_pkt.is_stash_snoop = 0;
                end else begin
                    outstanding_stsh_snoops++;
                    m_scb_pkt.is_stash_snoop = 1;
                end
            end
            m_ott_q.push_back(m_scb_pkt);//->evt_ott;
            if (en_sb_objections) ->e_queue_change;
            spkt = {"CHIAIU_UID:%0d : process_snp_req: Added a SNP Request txn with TxnId : %0h, addr : %0h"};
            `uvm_info(`LABEL, $psprintf(spkt, m_scb_pkt.chi_aiu_uid, m_pkt.smi_msg_id, m_pkt.smi_addr), UVM_LOW)
        end
    end
    end else begin
      if(!$test$plusargs("wrong_snpreq_target_id"))
        `uvm_error(`LABEL_ERROR, $psprintf("Received a Wrong target ID(0x%0h) SNPreq", m_pkt.smi_targ_ncore_unit_id))
    end
endfunction

//******************************************************************************
// Function : process_str_req
// Purpose  :
//
// Checks that are needed
//
// Will add coverage related code later.
//******************************************************************************
function void chi_aiu_scb::process_str_req(const ref smi_seq_item m_pkt);
    string  spkt;
    int     find_q[$];
    int     find_q_with_targ_id_err[$];
    int     find_q_targ_id_err[$];
    int     find_q_targ_id_err_1[$];

    find_q_targ_id_err = {};
    find_q_targ_id_err_1 = {};

    find_q = {};
    find_q_with_targ_id_err = {};
    find_q = m_ott_q.find_index with (
                item.smi_exp[`STR_REQ_IN] == 1
                && item.m_cmd_req_pkt !== null
                && item.m_cmd_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                && item.m_cmd_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id
               );
    find_q_with_targ_id_err = m_ott_q.find_index with (
                item.smi_exp[`STR_REQ_IN] == 1
                && item.m_cmd_req_pkt !== null
                && item.m_cmd_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
               );
    if ($test$plusargs("wrong_strreq_target_id")) begin  //#Check.CHIAIU.v3.Error.strreq
      if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        `uvm_info(`LABEL,$sformatf("STRreq targ_id = %0h, src_id = %0h, smi_msg_id = %0h",m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id),UVM_NONE)
        `ifndef FSYS_COVER_ON
        cov.collect_str_req_wtgtid(m_pkt);
     	`elsif CHI_SUBSYS_COVER_ON
        cov.collect_str_req_wtgtid(m_pkt);
        `endif
        find_q_targ_id_err_1 = str_targ_err_msg_id.find_index with (item.src_id == m_pkt.smi_src_ncore_unit_id &&
                                                                    item.msg_id == m_pkt.smi_msg_id);
        if (find_q_targ_id_err_1.size() == 1) begin
          str_targ_err_msg_id[find_q_targ_id_err_1[0]] = '{m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id};
        end else if (find_q_targ_id_err_1.size() == 0) begin
          str_targ_err_msg_id.push_back( '{m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id} );
        end
      end else begin
        find_q_targ_id_err = str_targ_err_msg_id.find_index with (item.src_id == m_pkt.smi_src_ncore_unit_id &&
                                                                  item.msg_id == m_pkt.smi_msg_id
                                                                 );

        if (find_q_targ_id_err.size()== 1 && m_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
          str_targ_err_msg_id.delete(find_q_targ_id_err[0]);
        end
      end
    end
    if ($test$plusargs("wrong_cmdrsp_target_id") && !is_resend_correct_target_id) begin //#Check.CHIAIU.v3.Error.cmdrsp
      if (m_ott_q[find_q[0]].smi_rcvd[`CMD_RSP_IN] == 1) begin
        `uvm_info(`LABEL,$sformatf("STRreq corsp to CMDrsp, smi_rmsg_id = %0h",m_pkt.smi_rmsg_id),UVM_NONE)
        if (m_pkt.smi_rmsg_id inside {cmd_rsp_targ_err_rmsg_id}) begin
          cmd_rsp_rmsg_id_corsp_str_msg_id[m_pkt.smi_msg_id] = m_pkt.smi_rmsg_id;
          str_req_corsp_cmd_rsp_rmsg_id[m_pkt.smi_msg_id] = m_pkt.smi_msg_id; 
          cmd_rsp_targ_err_rmsg_id.delete(m_pkt.smi_rmsg_id);
        end
      end else if(m_ott_q[find_q[0]].smi_rcvd[`CMD_RSP_IN] == 0 && m_ott_q[find_q[0]].smi_rcvd[`STR_RSP_OUT] == 0) begin //STRreq received before CMDrsp & STRrsp
        `uvm_info(`LABEL,$sformatf("STRreq corsp to CMDreq, smi_msg_id = %0h",m_pkt.smi_rmsg_id),UVM_NONE)
        cmd_rsp_rmsg_id_corsp_str_msg_id[m_pkt.smi_msg_id] = m_pkt.smi_rmsg_id;
        str_req_msg_id_for_cmd_rsp_targ_err[m_pkt.smi_rmsg_id] = m_pkt.smi_msg_id;
      end
    end

    if(find_q.size() == 1) begin
        if (m_ott_q[find_q[0]].exp_str_req_pkt == null)
            `uvm_error(`LABEL_ERROR, "Received an STR_REQ packet but the expected packet is not generated")

        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a STR_REQ packet: %0s.", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)

        //copy over fields that cannot be predicted
        m_ott_q[find_q[0]].exp_str_req_pkt.smi_msg_id = m_pkt.smi_msg_id;
        m_ott_q[find_q[0]].exp_str_req_pkt.smi_rbid = m_pkt.smi_rbid;
        if (m_ott_q[find_q[0]].exp_dtw_req_pkt!= null)
            m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_rbid = m_pkt.smi_rbid;
        //Is there a way to predict cmstatus, snarf and exok?-- There isn't. StrReq is incoming to AIU, its okay to not predict incoming values.
        if (m_pkt.smi_cmstatus[SMICMSTATUSERRBIT]) begin
          m_ott_q[find_q[0]].exp_str_req_pkt.smi_cmstatus_err = m_pkt.smi_cmstatus[SMICMSTATUSERRBIT];
          m_ott_q[find_q[0]].exp_str_req_pkt.smi_cmstatus_err_payload = m_pkt.smi_cmstatus_err_payload;
        end else begin
          m_ott_q[find_q[0]].exp_str_req_pkt.smi_cmstatus_so    = m_pkt.smi_cmstatus_so;
          m_ott_q[find_q[0]].exp_str_req_pkt.smi_cmstatus_ss    = m_pkt.smi_cmstatus_ss;
          m_ott_q[find_q[0]].exp_str_req_pkt.smi_cmstatus_sd    = m_pkt.smi_cmstatus_sd;
          m_ott_q[find_q[0]].exp_str_req_pkt.smi_cmstatus_st    = m_pkt.smi_cmstatus_st;
          m_ott_q[find_q[0]].exp_str_req_pkt.smi_cmstatus_state = m_pkt.smi_cmstatus_state;
          m_ott_q[find_q[0]].exp_str_req_pkt.smi_cmstatus_snarf = m_pkt.smi_cmstatus_snarf;
          m_ott_q[find_q[0]].exp_str_req_pkt.smi_cmstatus_exok  = m_pkt.smi_cmstatus_exok;
        end
        m_ott_q[find_q[0]].exp_str_req_pkt.smi_intfsize = m_pkt.smi_intfsize;
        m_ott_q[find_q[0]].exp_str_req_pkt.smi_mpf2_dtr_msg_id = m_pkt.smi_mpf2_dtr_msg_id;
        //balajik TODO:: Cannot predict mpf1 and mpf2 for stash operation in fsys tests. Also need to check if mpf1/mpf2 is valid only for write stash operations.
        if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {stash_ops} && !m_pkt.smi_cmstatus_snarf) begin
	    m_ott_q[find_q[0]].exp_str_req_pkt.smi_mpf1 = m_pkt.smi_mpf1;
        end
        <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {stash_ops}) begin
            m_ott_q[find_q[0]].exp_str_req_pkt.smi_mpf1 = m_pkt.smi_mpf1;
            m_ott_q[find_q[0]].exp_str_req_pkt.smi_mpf2 = m_pkt.smi_mpf2;
        end
        <%}%>
        `ASSERT(m_ott_q[find_q[0]].exp_str_req_pkt.compare(m_pkt));
        m_ott_q[find_q[0]].add_smi_str_req(m_pkt);
	if($test$plusargs("zero_nonzero_crd_test") && m_ott_q[find_q[0]].is_crd_zero_err == 1) begin
	    csr_addr_decode_err_addr_q.push_back(m_ott_q[find_q[0]].m_chi_req_pkt.addr);
	end
        if ((m_pkt.smi_cmstatus[7:6] === 2'b10 && m_pkt.smi_cmstatus[5] === 1'b0 && m_pkt.smi_cmstatus[2:0] === 3'b011) || (m_pkt.smi_cmstatus[7:6] === 2'b10 && m_pkt.smi_cmstatus[5] === 1'b1 && m_pkt.smi_cmstatus[2:0] === 3'b110)) begin
          `uvm_info(`LABEL, $sformatf("CHIAIU_UID:%0d : Received STRreq cmstatus with data error, cmstatus = %0h", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.smi_cmstatus),UVM_LOW)
          STRreq_aiu_txn_ids_cmstatus_with_data_err[m_ott_q[find_q[0]].chi_aiu_uid] = m_ott_q[find_q[0]].chi_aiu_uid;
        end else if (m_pkt.smi_cmstatus[7:6] === 2'b10) begin
          `uvm_info(`LABEL, $sformatf("CHIAIU_UID:%0d : Received STRreq cmstatus with non data error, cmstatus = %0h", m_pkt.smi_cmstatus, m_ott_q[find_q[0]].chi_aiu_uid),UVM_LOW)
          STRreq_aiu_txn_ids_cmstatus_with_non_data_err[m_ott_q[find_q[0]].chi_aiu_uid] = m_ott_q[find_q[0]].chi_aiu_uid;
        end
    end else begin
        if (!$test$plusargs("wrong_strreq_target_id")) begin
          //print_ott_info();
          `uvm_info(`LABEL,$sformatf("%s", m_pkt.convert2string()), UVM_NONE)
          spkt = {"Found no matching txn for the above STR req pkt"};
          `uvm_error(`LABEL_ERROR, $psprintf("%0s. STR_REQ: %0s # of matches: 0x%0h", m_pkt.convert2string(), spkt, find_q.size()))
        end else begin
          if(!is_resend_correct_target_id)
            m_ott_q[find_q_with_targ_id_err[0]].add_smi_str_req(m_pkt);
          `uvm_info(`LABEL,$sformatf("Injected Error in, %s", m_pkt.convert2string()), UVM_NONE)
        end
    end

endfunction

//******************************************************************************
// Function : process_dtr_req
// Purpose  :
//
// Checks that are needed
// Will add coverage related code later.
//******************************************************************************
function void chi_aiu_scb::process_dtr_req(const ref smi_seq_item m_pkt);
    string  spkt;
    bit [2:0]	   l_dwid;
    int     find_q[$];
    int find_q_targ_id_err[$];
    int find_q_targ_id_err_1[$];

    // #Stimulus.FSYS.connectivity.AIUtoAIU
    if(addr_trans_mgr::check_aiu_is_unconnected(.tgt_unit_id(m_pkt.smi_targ_ncore_unit_id), .src_unit_id(m_pkt.smi_src_ncore_unit_id))) begin
      `uvm_error(`LABEL_ERROR,
      $sformatf("In DTR_REQ, Connectivity between AIU FUnitID %0d and AIU FUnitID %0d should have been optimized and not existing", m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_src_ncore_unit_id))
    end

    find_q_targ_id_err = {};
    find_q_targ_id_err_1 = {};

    find_q = {};
    find_q = m_ott_q.find_index with (
                    ((item.m_cmd_req_pkt != null
                        && item.m_cmd_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                        && item.smi_exp[`DTR_REQ_IN] == 1
                        && m_pkt.smi_src_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>
                        && m_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)
                    ||(item.smi_exp[`SNP_DTR_REQ] == 1
                        && item.m_snp_req_pkt !== null
                        && item.m_snp_req_pkt.smi_mpf1_dtr_tgt_id == m_pkt.smi_targ_ncore_unit_id
                        && item.m_snp_req_pkt.smi_mpf2_dtr_msg_id == m_pkt.smi_rmsg_id
			&& item.m_snp_req_pkt.smi_mpf1_dtr_tgt_id == m_pkt.smi_targ_ncore_unit_id
                        && item.m_snp_req_pkt.smi_msg_type inside {SNP_CLN_DTR, SNP_NITC, SNP_VLD_DTR, SNP_INV_DTR, SNP_INV_DTW, SNP_INV, SNP_CLN_DTW, SNP_NOSDINT, SNP_NITCCI, SNP_NITCMI}
                        && m_pkt.smi_src_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)
                    ||(item.smi_exp[`SNP_DTR_REQ] == 1
                        && item.m_snp_rsp_pkt !== null
                        && item.m_snp_rsp_pkt.smi_mpf1_dtr_msg_id == m_pkt.smi_rmsg_id //For stashing snoops DTRs
                        && item.m_snp_req_pkt.smi_msg_type inside {SNP_INV_STSH, SNP_UNQ_STSH, SNP_STSH_SH, SNP_STSH_UNQ}
                        && m_pkt.smi_src_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>
                        && m_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)
                    ));
    if ($test$plusargs("wrong_dtrreq_target_id")) begin //#Check.CHIAIU.v3.Error.dtrreq
      if (m_pkt.smi_src_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        `ifndef FSYS_COVER_ON
           cov.collect_dtr_req_wtgtid(m_pkt);
     	`elsif CHI_SUBSYS_COVER_ON
           cov.collect_dtr_req_wtgtid(m_pkt);
        `endif
          `uvm_info(`LABEL,$sformatf("DTRreq targ_id = %0h, src_id = %0h, smi_msg_id = %0h",m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id),UVM_NONE)
          find_q_targ_id_err_1 = dtr_targ_err_msg_id.find_index with (item.src_id == m_pkt.smi_src_ncore_unit_id &&
                                                                      item.msg_id == m_pkt.smi_msg_id);
          if (find_q_targ_id_err_1.size() == 1) begin
            dtr_targ_err_msg_id[find_q_targ_id_err_1[0]] = '{m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id};
          end else if (find_q_targ_id_err_1.size() == 0) begin
            dtr_targ_err_msg_id.push_back( '{m_pkt.smi_src_ncore_unit_id, m_pkt.smi_msg_id} );
          end
        end else begin
          find_q_targ_id_err = dtr_targ_err_msg_id.find_index with (item.src_id == m_pkt.smi_src_ncore_unit_id &&
                                                                    item.msg_id == m_pkt.smi_msg_id
                                                                   );

          if (find_q_targ_id_err.size()== 1 && m_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
            dtr_targ_err_msg_id.delete(find_q_targ_id_err[0]);
          end
        end
      end
    end
    if(find_q.size() == 1) begin

      `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a DTR_REQ packet. Matching it with the expected packet:%0s.", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)
    //   $display(" do we have cmd_req_pkt? : %0d", m_ott_q[find_q[0]].m_cmd_req_pkt == null? 0 : 1);

        if (m_ott_q[find_q[0]].m_cmd_req_pkt != null) begin
            m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_msg_id = m_pkt.smi_msg_id;
            m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_dp_data = m_pkt.smi_dp_data;
            m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_dp_user = m_pkt.smi_dp_user;
            if ($test$plusargs("random_dbad_value") || $test$plusargs("error_test")) begin
               foreach(m_pkt.smi_dp_dbad[i]) begin
                 if (m_pkt.smi_dp_dbad[i] !== 0) begin
                   dbad_dtr_req[m_ott_q[find_q[0]].chi_aiu_uid] = m_ott_q[find_q[0]].chi_aiu_uid;
                 end
               end
               m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_dp_dbad = m_pkt.smi_dp_dbad;
            end
            m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_dp_be = m_pkt.smi_dp_be;
            m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_dp_dwid = m_pkt.smi_dp_dwid; //new[(64*8/<%=obj.AiuInfo[obj.Id].wData%>)];

            m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_rl = m_pkt.smi_rl; //DTR is an incoming packet, can't predict RL
            m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_tm = m_ott_q[find_q[0]].m_cmd_req_pkt.smi_tm; 
            if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {stash_ops}) begin
                m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_targ_ncore_unit_id = m_ott_q[find_q[0]].m_str_req_pkt.smi_mpf1_stash_nid;
                m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_rmsg_id = m_ott_q[find_q[0]].m_str_req_pkt.smi_mpf2_dtr_msg_id;
                m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_rl[1:0] = 2'b10;
            end else begin
                m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_msg_type = m_pkt.smi_msg_type; // is checked in check_dtr_msg_types() function
            end
            <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
            m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_src_ncore_unit_id = m_pkt.smi_src_ncore_unit_id; //balajik TODO: Scoreboard cannot predict src_id for dtr from another AIU.
            <%}%>
            m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_cmstatus = m_pkt.smi_cmstatus;
            if (m_pkt.smi_cmstatus[SMICMSTATUSERRBIT]) begin
              //#Check.CHIAIU.v3.Error.nondataerr
              //#Check.CHIAIU.v3.Error.dataerr
              m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_cmstatus_err = m_pkt.smi_cmstatus[SMICMSTATUSERRBIT];
              m_ott_q[find_q[0]].exp_dtr_req_pkt.smi_cmstatus_err_payload = m_pkt.smi_cmstatus_err_payload;
            end 
            m_ott_q[find_q[0]].exp_dtr_req_pkt.unpack_dp_smi_seq_item();
            `ASSERT(m_ott_q[find_q[0]].exp_dtr_req_pkt.compare(m_pkt));
            m_ott_q[find_q[0]].add_smi_dtr_req(m_pkt);
            if ((m_pkt.smi_cmstatus[7:6] === 2'b10 && m_pkt.smi_cmstatus[5] === 1'b0 && m_pkt.smi_cmstatus[2:0] === 3'b011) || (m_pkt.smi_cmstatus[7:6] === 2'b10 && m_pkt.smi_cmstatus[5] === 1'b1 && m_pkt.smi_cmstatus[2:0] === 3'b110)) begin
              `uvm_info(`LABEL, $sformatf("CHIAIU_UID:%0d : Received DTRreq cmstatus with data error, cmstatus = %0h", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.smi_cmstatus),UVM_LOW)
              DTRreq_aiu_txn_ids_cmstatus_with_data_err[m_ott_q[find_q[0]].chi_aiu_uid] = m_ott_q[find_q[0]].chi_aiu_uid;
            end else if (m_pkt.smi_cmstatus[7:6] === 2'b10) begin
              `uvm_info(`LABEL, $sformatf("CHIAIU_UID:%0d : Received DTRreq cmstatus with non data error, cmstatus = %0h", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.smi_cmstatus),UVM_LOW)
              DTRreq_aiu_txn_ids_cmstatus_with_non_data_err[m_ott_q[find_q[0]].chi_aiu_uid] = m_ott_q[find_q[0]].chi_aiu_uid;
            end
            check_dtr_msg_types(m_ott_q[find_q[0]]);
        end else begin
            m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_msg_id = m_pkt.smi_msg_id;
            // rmsg_id is indirectly checked during matching of pending packet in above find_index() call 
            m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_rmsg_id = m_pkt.smi_rmsg_id; 
            m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_data = m_pkt.smi_dp_data;
            m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_user = m_pkt.smi_dp_user;
            m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_be = m_pkt.smi_dp_be;
            m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_intfsize = m_ott_q[find_q[0]].m_snp_req_pkt.smi_intfsize;
            m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_mpf2 = m_ott_q[find_q[0]].m_snp_req_pkt.smi_ndp[SNP_REQ_MPF2_MSB:SNP_REQ_MPF2_LSB];
            m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_tm = m_pkt.smi_tm;
            m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_src_ncore_unit_id = m_pkt.smi_src_ncore_unit_id; //AIU doesnt know who will send stashing data
	        m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_dwid = m_pkt.smi_dp_dwid; //new[(64*8/<%=obj.AiuInfo[obj.Id].wData%>)];
            m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_dbad = new[m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_user.size()];
            foreach (m_ott_q[find_q[0]].m_chi_read_data_pkt[i]) begin
              for (int dw_i=0 ; dw_i < (wSmiDPdata/64) ; dw_i++) begin
                if (m_ott_q[find_q[0]].m_chi_read_data_pkt[i].poison[dw_i] == 1 && m_ott_q[find_q[0]].m_chi_read_data_pkt[i].be[(dw_i*8)+:8] !== 0) begin
                  m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_dbad[i][dw_i] = 1;
                  //m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err = 1'b1;              //Commented as per CONC-6526
                  //m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err_payload = 7'b0000011;
                end else begin
                  m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_dbad[i][dw_i] = 0;
                end
              end
            end

            if ($test$plusargs("SNPrsp_with_data_error")) begin
              foreach (m_ott_q[find_q[0]].m_chi_snp_data_pkt[i]) begin  //CHI snp rsp data error
                if (m_ott_q[find_q[0]].m_chi_snp_data_pkt[i].resperr === 2'b10) begin 
                  if (WDATA == wSmiDPdata) begin
                    m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_dbad[i] = '1;
                  end else if (WDATA > wSmiDPdata) begin //chi data width > smi data width
                    for (int j=0; j<dword_width_diff__chi_smi_data; j++) begin
                      m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_dbad[j+(i*dword_width_diff__chi_smi_data)] = '1;
                    end
                  end else if (WDATA < wSmiDPdata) begin //chi data width < smi data width
                    m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_dbad[(i/dword_width_diff__smi_chi_data)] |= {no_of_dword__chi_data{1'b1}} << ((i%dword_width_diff__smi_chi_data)*no_of_dword__chi_data);
                  end
                end
                if (m_ott_q[find_q[0]].m_chi_snp_data_pkt[i].resperr === 2'b10) begin //chi data flit Data error
                <%if (obj.testBench == "chi_aiu") { %>
                       m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err = 1'b1;
                       m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err_payload = 7'b0000011;
                <% } else { %>  
                  if((m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_dbad[0] != 'h0)) begin
                       m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err = 1'b1;
                       m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err_payload = 7'b0000011;
                  end
                <% } %>
                end
              end
            end else begin
              foreach (m_ott_q[find_q[0]].m_chi_read_data_pkt[i]) begin
                if (m_ott_q[find_q[0]].m_chi_read_data_pkt[i].resperr === 2'b10 || m_ott_q[find_q[0]].m_chi_read_data_pkt[i].resperr === 2'b11) begin //chi data flit Data/non-data error
                  if (WDATA == wSmiDPdata) begin
                    m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_dbad[i] = '1;
                  end else if (WDATA > wSmiDPdata) begin //chi data width > smi data width
                    for (int j=0; j<dword_width_diff__chi_smi_data; j++) begin
                      m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_dbad[j+(i*dword_width_diff__chi_smi_data)] = '1;
                    end
                  end else if (WDATA < wSmiDPdata) begin //chi data width < smi data width
                    m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_dp_dbad[(i/dword_width_diff__smi_chi_data)] |= {no_of_dword__chi_data{1'b1}} << ((i%dword_width_diff__smi_chi_data)*no_of_dword__chi_data);
                  end
                end
                if (m_ott_q[find_q[0]].m_chi_read_data_pkt[0].resperr === 2'b10) begin //chi data flit Data error, AIU indicates error in cmstatus only if 1st beat indicates error other beats error will be indicated in DBAD CONC-6610.
                  m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err = 1'b1;
                  m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err_payload = 7'b0000011;
                end
                if (m_ott_q[find_q[0]].m_chi_read_data_pkt[0].resperr === 2'b11) begin //chi data flit Non-Data error, AIU indicates error in cmstatus only if 1st beat indicates error other beats error will be indicated in DBAD CONC-6610.
                  m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err = 1'b1;
                  m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err_payload = 7'b0000100;
                end
              end
            end
            if (m_ott_q[find_q[0]].m_chi_srsp_pkt != null && m_ott_q[find_q[0]].m_chi_srsp_pkt.resperr == 2'b11) begin
              m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err = 1'b1;
              m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err_payload = 7'b0000100;
            end
            if (m_ott_q[find_q[0]].m_chi_srsp_pkt != null && m_ott_q[find_q[0]].m_chi_srsp_pkt.resperr == 2'b10) begin
              m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err = 1'b1;
              m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_cmstatus_err_payload = 7'b0000011;
            end
        
            //For stash snoops, DTR type is always DTR_DATA_UNQ_DTY
            if (!(m_ott_q[find_q[0]].m_chi_snp_addr_pkt.opcode inside {stash_snps})) begin
                m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_msg_type = m_pkt.smi_msg_type; // is checked in check_dtr_msg_types() function
            end else begin
                m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_msg_type = m_pkt.smi_msg_type;
                m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_rl = SMI_RL_COHERENCY;
                m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_tm = m_pkt.smi_tm;
            end
            // only call compare for DTRs that are going out of AIU
            if (m_pkt.smi_src_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
                m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.smi_targ_ncore_unit_id = m_ott_q[find_q[0]].m_snp_req_pkt.smi_mpf1_dtr_tgt_id;
                `ASSERT(m_ott_q[find_q[0]].exp_snp_dtr_req_pkt.compare(m_pkt));
            end
            m_ott_q[find_q[0]].add_smi_snp_dtr_req(m_pkt);
            // $display(" added snp_dtr_req? for txnid: %0d", m_ott_q[find_q[0]].chi_aiu_uid);
            check_snp_dtr_msg_types(m_ott_q[find_q[0]]);
        end
    end else begin
        if(!($test$plusargs("wrong_dtrreq_target_id") || $test$plusargs("wrong_snpreq_target_id"))) begin
          //print_ott_info();
          foreach (find_q[idx])
              print_me(find_q[idx]);
          `uvm_info(`LABEL,$sformatf("%s", m_pkt.convert2string()), UVM_NONE)
          spkt = {"Found no matching txn for the above DTR req pkt"};
          `uvm_error(`LABEL_ERROR, $psprintf("%0s. # of matches: 0x%0h", spkt, find_q.size()))
        end else begin
          foreach (find_q[idx])
              print_me(find_q[idx]);
          `uvm_info(`LABEL,$sformatf("Error injected in, %s", m_pkt.convert2string()), UVM_NONE)
        end
    end

endfunction

//******************************************************************************
// Function : process_sys_req
// Purpose  :
//
//******************************************************************************
function void chi_aiu_scb::process_sys_req(const ref smi_seq_item m_pkt);
    string  spkt;
    int     find_q[$];
    smi_sysreq_op_enum_t opcode;

    smi_seq_item  exp_sys_rsp_pkt;
    int           exp_cm_status;
    int           sys_rcvr_busy;
    smi_seq_item  m_scb_pkt;

    `uvm_info(`LABEL, $sformatf("INSIDE: process_sys_req smi_ndp = 0x%x sys_req_op = 0x%x msg_id = 0x%x smi_src_ncore_unit_id = 0x%x", m_pkt.smi_ndp, m_pkt.smi_sysreq_op, m_pkt.smi_msg_id, m_pkt.smi_src_ncore_unit_id), UVM_MEDIUM)

    $cast(opcode, m_pkt.smi_sysreq_op);
    case(opcode)
        SMI_SYSREQ_NOP : begin
          `uvm_error(`LABEL_ERROR, $psprintf("Opcode Not supported in Ncore3.2 for now"))
        end
        SMI_SYSREQ_ATTACH,
        SMI_SYSREQ_DETACH : begin
          //#Check.CHIAIU.sysco.sysreqdetach
          int match_idx;
          spkt = "";
        `ifndef FSYS_COVER_ON
		cov.collect_sysco_req_cmds(m_pkt.smi_src_ncore_unit_id,m_pkt.smi_targ_ncore_unit_id);
     	`elsif CHI_SUBSYS_COVER_ON
		cov.collect_sysco_req_cmds(m_pkt.smi_src_ncore_unit_id,m_pkt.smi_targ_ncore_unit_id);
        `endif
          find_q = m_sysco_q.find_index(item) with (
                          item.m_sysco_st == m_sysco_st
                          && item.smi_exp[`SYS_REQ_OUT] == 1
                          && m_pkt.smi_src_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>
                          && m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>
                          );
          if(find_q.size == 0) begin
            $sformat(spkt, "%0s No matching CHI sysco request found.\n", spkt);
            foreach(m_sysco_q[i]) begin
              if(!m_sysco_q[i].is_SyscoNintf)
                $sformat(spkt, "%0s m_sysco_q[%0d].m_sysco_st=%0s.\n", spkt, i, m_sysco_q[i].m_sysco_st.name);
              else
                $sformat(spkt, "%0s m_sysco_q[%0d]=%0s.\n", spkt, i, m_sysco_q[i].m_chi_sysco_req_pkt.convert2string);
            end
            `uvm_error(`LABEL_ERROR, $psprintf("%0s", spkt))
          end
          else if(find_q.size > 1) begin
            $sformat(spkt, "%0s Multiple(%0d) matching CHI sysco request found.\n", spkt, find_q.size);
            foreach(find_q[i]) begin
              if(!m_sysco_q[find_q[i]].is_SyscoNintf)
                $sformat(spkt, "%0s m_sysco_q[%0d].m_sysco_st=%0s.\n", spkt, find_q[i], m_sysco_q[find_q[i]].m_sysco_st.name);
              else
                $sformat(spkt, "%0s m_sysco_q[%0d]=%0s.\n", spkt, find_q[i], m_sysco_q[find_q[i]].m_chi_sysco_req_pkt.convert2string);
            end
            `uvm_error(`LABEL_ERROR, $psprintf("%0s", spkt))
          end
          else begin
            //#Check.CHIAIU.v3.4.Connectivity.SysReq
            match_idx = find_q[0];
            $sformat(spkt, "Matching CHI sysco request found.\n");
            if(!m_sysco_q[match_idx].is_SyscoNintf)
              $sformat(spkt, "%0s m_sysco_q[%0d].m_sysco_st=%0s.\n", spkt, match_idx, m_sysco_q[match_idx].m_sysco_st.name);
            else
              $sformat(spkt, "%0s m_sysco_q[%0d]=%0s.\n", spkt, match_idx, m_sysco_q[match_idx].m_chi_sysco_req_pkt.convert2string);
            `uvm_info(`LABEL, $psprintf("%0s", spkt), UVM_DEBUG)

            find_q = m_sysco_q[match_idx].exp_sys_req_pkt.find_index(item) with (
                                                        item.smi_targ_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id
                                                        );
            spkt = "";
            if(!find_q.size) begin
              $sformat(spkt, "%0s No matching exp_sys_req_pkt found.\n", spkt);
              `uvm_error(`LABEL_ERROR, $psprintf("%0s", spkt))
            end
            else if(find_q.size > 1) begin
              $sformat(spkt, "%0s Multiple(%0d) matching exp_sys_req_pkt found.\n", spkt, find_q.size);
              foreach(find_q[i]) begin
                $sformat(spkt, "%0s m_sysco_q[%0d].exp_sys_req_pkt[%0d]=%0s.\n", spkt, match_idx, find_q[i], m_sysco_q[match_idx].exp_sys_req_pkt[find_q[i]].convert2string);
              end
              `uvm_error(`LABEL_ERROR, $psprintf("%0s", spkt))
            end
            else begin
              $sformat(spkt, "Matching exp_sys_req_pkt found");
              foreach(find_q[i]) begin
                $sformat(spkt, "%0s m_sysco_q[%0d].exp_sys_req_pkt[%0d]=%0s.\n", spkt, match_idx, find_q[i], m_sysco_q[match_idx].exp_sys_req_pkt[find_q[i]].convert2string);
              end
              `uvm_info(`LABEL, $psprintf("%0s", spkt), UVM_DEBUG)
              m_sysco_q[match_idx].exp_sys_req_pkt[find_q[0]].smi_msg_id = m_pkt.smi_msg_id;
              //#Check.CHIAIU.sysco.sysreqfields
              `ASSERT(m_sysco_q[match_idx].exp_sys_req_pkt[find_q[0]].compare(m_pkt));
              m_sysco_q[match_idx].exp_sys_req_pkt.delete(find_q[0]);
              m_sysco_q[match_idx].add_smi_sys_req(m_pkt);
            end
          end
        end
        SMI_SYSREQ_EVENT : begin
            if ($test$plusargs("wrong_sysreq_target_id")) begin
                if  (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin 
        	    `ifndef FSYS_COVER_ON
		    	cov.collect_sys_req_wtgtid(m_pkt);
     		    `elsif CHI_SUBSYS_COVER_ON
		    	cov.collect_sys_req_wtgtid(m_pkt);
        	    `endif
                    return;
                end
            end
            m_scb_pkt = smi_seq_item::type_id::create("m_scb_pkt");
            m_scb_pkt.smi_transmitter = m_pkt.smi_transmitter;
            m_scb_pkt.smi_msg_id = m_pkt.smi_msg_id;
            m_sysreq_q.push_back(m_scb_pkt);
            exp_sys_rsp_pkt = smi_seq_item::type_id::create("exp_sys_rsp_pkt");
            sb_stall_if.perf_count_events["Noc_event_counter"].push_back(1);

            `uvm_info("<%=obj.strRtlNamePrefix%> SCB", $sformatf("Observed SysReqEvent : %0s , Expected cm_status : %d", m_pkt.convert2string(), exp_cm_status), UVM_HIGH)

            exp_sys_rsp_pkt.construct_sysrsp(
                           .smi_targ_ncore_unit_id (m_pkt.smi_transmitter ? m_pkt.smi_src_ncore_unit_id : m_pkt.smi_targ_ncore_unit_id),
                           .smi_src_ncore_unit_id  (m_pkt.smi_transmitter ? m_pkt.smi_targ_ncore_unit_id : m_pkt.smi_src_ncore_unit_id),
                           .smi_msg_type           (SYS_RSP),
                           .smi_msg_id             ('h0),
                           .smi_msg_tier           ('h0),
                           .smi_steer              ('h0),
                           .smi_msg_pri            ('0),
                           .smi_msg_qos            ('0),
                           .smi_tm                 ('h0),
                           .smi_rmsg_id            (m_pkt.smi_msg_id),
                           .smi_msg_err            ('h0),
                           .smi_cmstatus           (exp_cm_status),
                           .smi_ndp_aux            ('h0)
                        );
            exp_sys_rsp_pkt.smi_transmitter = !m_pkt.smi_transmitter;

            if ($test$plusargs("enable_ev_timeout") && m_pkt.smi_transmitter == 1) begin
              return;
            end
            m_exp_sysrsp_q.push_back(exp_sys_rsp_pkt);
        end
        default : begin
          `uvm_error(`LABEL_ERROR, $sformatf("INSIDE: process_sys_req opcode support not added yet smi_sysreq_op=%0d", m_pkt.smi_sysreq_op))
        end
    endcase 
endfunction : process_sys_req

//******************************************************************************
// Function : process_sys_rsp
// Purpose  :
//
//******************************************************************************
function void chi_aiu_scb::process_sys_rsp(const ref smi_seq_item m_pkt);
    string  spkt;
    int     sysreq_id_q[$];
    int     sysrsp_id_q[$];
    int     find_q[$];
    smi_seq_item  exp_sys_rsp_pkt;
    smi_seq_item  sys_req_pkt;
    int           sys_rsp_q_empty;
    int           sysrsp_timeout;

    `uvm_info(`LABEL, $sformatf("INSIDE: process_sys_rsp rmsg_id = 0x%x cmstatus = %b smi_transmitter = %b opcode:%0d", m_pkt.smi_rmsg_id, m_pkt.smi_cmstatus, m_pkt.smi_transmitter, m_pkt.smi_sysreq_op), UVM_MEDIUM)

    // smi_transmitter = 0 -> sysrsp is going out of CHI
    // smi_transmitter = 1 -> sysrsp is coming into CHI

    if (m_pkt.smi_transmitter) begin
        sysreq_id_q = m_sysreq_q.find_index(item) with (item.smi_msg_id == m_pkt.smi_rmsg_id && item.smi_transmitter == 0);
    end else begin
        sysreq_id_q = m_sysreq_q.find_index(item) with (item.smi_msg_id == m_pkt.smi_rmsg_id && item.smi_transmitter == 1);
    end

    if (sysreq_id_q.size() != 0) begin // SYSRSP packet corresponding to SYSREQ event
        
        exp_sys_rsp_pkt = smi_seq_item::type_id::create("exp_sys_rsp_pkt");
        sysrsp_id_q = m_exp_sysrsp_q.find_index(item) with (item.smi_rmsg_id == m_pkt.smi_rmsg_id && item.smi_transmitter == m_pkt.smi_transmitter);
        if (sysrsp_id_q.size() == 0) begin
            `uvm_error(`LABEL_ERROR, $psprintf("Unexpected Sysrsp"));
        end
        exp_sys_rsp_pkt = m_exp_sysrsp_q[sysrsp_id_q[0]];
        if (m_pkt.smi_transmitter) begin
            exp_sys_rsp_pkt.smi_targ_ncore_unit_id = <%=obj.AiuInfo[obj.Id].FUnitId%>;
            exp_sys_rsp_pkt.smi_src_ncore_unit_id = <%=obj.DveInfo[0].FUnitId%>;
        end else begin
            exp_sys_rsp_pkt.smi_targ_ncore_unit_id = <%=obj.DveInfo[0].FUnitId%>;
            exp_sys_rsp_pkt.smi_src_ncore_unit_id = <%=obj.AiuInfo[obj.Id].FUnitId%>;
        end
        if (m_pkt.smi_cmstatus == 1 || m_pkt.smi_cmstatus == 3) begin 
            exp_sys_rsp_pkt.smi_cmstatus = m_pkt.smi_cmstatus;
        end
        `ASSERT(exp_sys_rsp_pkt.compare(m_pkt));
        m_sysreq_q.delete(sysreq_id_q[0]);
        m_exp_sysrsp_q.delete(sysrsp_id_q[0]);
    end else begin // outgoing from SMI bfm : sysrsp of attach/dettach
        spkt = ""; 
        `uvm_info(`LABEL, $sformatf("INSIDE: received SysCo SysRsp"), UVM_MEDIUM)
        if ($test$plusargs("wrong_sysrsp_target_id")) begin
          if (m_pkt.smi_targ_ncore_unit_id != <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        `ifndef FSYS_COVER_ON
            cov.collect_sys_rsp_wtgtid(m_pkt);
  	`elsif CHI_SUBSYS_COVER_ON
            cov.collect_sys_rsp_wtgtid(m_pkt);
        `endif
            `uvm_info(`LABEL,$sformatf("SYSrsp targ_id = %0h, smi_rmsg_id = %0h",m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_rmsg_id),UVM_NONE)
            return;
          end
        end
        `ifndef FSYS_COVER_ON
		cov.collect_sysco_rsp_cmds(m_pkt.smi_src_ncore_unit_id,m_pkt.smi_targ_ncore_unit_id);
  	`elsif CHI_SUBSYS_COVER_ON
		cov.collect_sysco_rsp_cmds(m_pkt.smi_src_ncore_unit_id,m_pkt.smi_targ_ncore_unit_id);
        `endif
        //#Check.CHIAIU.sysco.sysrspoutstanding
        if(m_sysco_q.size == 0) begin
          $sformat(spkt, "%0s No pending pkt inside m_sysco_q(size=%0d), but received a incoming sys_rsp to AIU.", spkt, m_sysco_q.size);
          `uvm_error(`LABEL_ERROR, $psprintf("%0s", spkt))
        end
        else begin
          int match_idx;
          find_q = m_sysco_q.find_index(item) with (
                          item.m_sysco_st == m_sysco_st
                          && item.smi_exp[`SYS_RSP_IN] == 1
                          && m_pkt.smi_src_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>
                          && m_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>
                          );
          if(find_q.size == 0) begin
            $sformat(spkt, "%0s No matching CHI sysco response found.\n", spkt);
            foreach(m_sysco_q[i]) begin
              if(!m_sysco_q[i].is_SyscoNintf)
                $sformat(spkt, "%0s m_sysco_q[%0d].m_sysco_st=%0s.\n", spkt, i, m_sysco_q[i].m_sysco_st.name);
              else
                $sformat(spkt, "%0s m_sysco_q[%0d]=%0s.\n", spkt, i, m_sysco_q[i].m_chi_sysco_req_pkt.convert2string);
            end
            `uvm_error(`LABEL_ERROR, $psprintf("%0s", spkt))
          end
          else if(find_q.size > 1) begin
            $sformat(spkt, "%0s Multiple(%0d) matching CHI sysco request found.\n", spkt, find_q.size);
            foreach(find_q[i]) begin
              if(!m_sysco_q[find_q[i]].is_SyscoNintf)
                $sformat(spkt, "%0s m_sysco_q[%0d].m_sysco_st=%0s.\n", spkt, find_q[i], m_sysco_q[find_q[i]].m_sysco_st.name);
              else
                $sformat(spkt, "%0s m_sysco_q[%0d]=%0s.\n", spkt, find_q[i], m_sysco_q[find_q[i]].m_chi_sysco_req_pkt.convert2string);
            end
            `uvm_error(`LABEL_ERROR, $psprintf("%0s", spkt))
          end
          else begin
            match_idx = find_q[0];
            $sformat(spkt, "Matching CHI sysco request found.\n");
            if(!m_sysco_q[match_idx].is_SyscoNintf)
              $sformat(spkt, "%0s m_sysco_q[%0d].m_sysco_st=%0s.\n", spkt, match_idx, m_sysco_q[match_idx].m_sysco_st.name);
            else
              $sformat(spkt, "%0s m_sysco_q[%0d]=%0s.\n", spkt, match_idx, m_sysco_q[match_idx].m_chi_sysco_req_pkt.convert2string);
            `uvm_info(`LABEL, $psprintf("%0s", spkt), UVM_DEBUG)

            find_q = m_sysco_q[match_idx].exp_sys_rsp_pkt.find_index(item) with (
                                                         item.smi_src_ncore_unit_id == m_pkt.smi_src_ncore_unit_id
                                                         );
            if(!find_q.size) begin
              $sformat(spkt, "%0s No matching exp_sys_rsp_pkt found.\n", spkt);
              `uvm_error(`LABEL_ERROR, $psprintf("%0s", spkt))
            end
            else if(find_q.size > 1) begin
              $sformat(spkt, "%0s Multiple(%0d) matching exp_sys_rsp_pkt found.\n", spkt, find_q.size);
              foreach(find_q[i]) begin
                $sformat(spkt, "%0s m_sysco_q[%0d].exp_sys_rsp_pkt[%0d]=%0s.\n", spkt, match_idx, find_q[i], m_sysco_q[match_idx].exp_sys_rsp_pkt[find_q[i]].convert2string);
              end
              `uvm_error(`LABEL_ERROR, $psprintf("%0s", spkt))
            end
            else begin
              $sformat(spkt, "Matching exp_sys_rsp_pkt found");
              foreach(find_q[i]) begin
                $sformat(spkt, "%0s m_sysco_q[%0d].exp_sys_rsp_pkt[%0d]=%0s.\n", spkt, match_idx, find_q[i], m_sysco_q[match_idx].exp_sys_rsp_pkt[find_q[i]].convert2string);
              end
              `uvm_info(`LABEL, $psprintf("%0s", spkt), UVM_DEBUG)
              m_sysco_q[match_idx].exp_sys_rsp_pkt[find_q[0]].smi_msg_id = m_pkt.smi_msg_id;
              `ASSERT(m_sysco_q[match_idx].exp_sys_rsp_pkt[find_q[0]].compare(m_pkt));
              m_sysco_q[match_idx].exp_sys_rsp_pkt.delete(find_q[0]);
              m_sysco_q[match_idx].add_smi_sys_rsp(m_pkt);
              if(m_sysco_q[match_idx].smi_rcvd[`SYS_RSP_IN] && !m_sysco_q[match_idx].is_SyscoNintf) begin
                string tmp_spkt;
                bit is_err, is_info, is_chk_1, is_chk_2;
                chi_sysco_state_t m_tmp_st;
                m_tmp_st = m_sysco_q[match_idx].m_sysco_st;
                if(!$test$plusargs("wrong_sysrsp_target_id")) begin : CHK_1
                  if(m_tmp_st inside {DISABLED, ENABLED}) begin
                    is_info = 1;
                    is_chk_1 = 1;
                  end
                  else is_err = 1;
                end else if($test$plusargs("wrong_sysrsp_target_id") && m_sysco_timeout_q.size && (get_cur_sysco_state == DISCONNECT)) begin : CHK_2
                if (m_pkt.smi_targ_ncore_unit_id != <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
                    `ifndef FSYS_COVER_ON
                        cov.collect_sys_rsp_wtgtid(m_pkt);
  		    `elsif CHI_SUBSYS_COVER_ON
                        cov.collect_sys_rsp_wtgtid(m_pkt);
                    `endif
                end
                  if(m_tmp_st inside {DISABLED, ENABLED}) begin
                    is_info = 1;
                    is_chk_2 = 1;
                  end
                  else is_err = 1;
                end
                if(is_info) begin
                  if(is_chk_1) m_sysco_st = m_tmp_st; // here proc/rtl are in different sysco state
                  $sformat(tmp_spkt, "%0s m_sysco_st=%0s.\n", tmp_spkt, m_sysco_st.name);
                  m_sysco_q.delete(match_idx);
                  `uvm_info(`LABEL, $psprintf("Deleted m_sysco_q entry, %0s. Queue size now is %0d, current sysco_req pkt cnt=%0d", tmp_spkt, m_sysco_q.size, m_sys_req_cnt), UVM_LOW)
                  if(is_chk_2) begin
                    chi_base_seq_item m_timeout_old_tb_pkt;
                    m_timeout_old_tb_pkt = chi_base_seq_item::type_id::create("m_timeout_old_tb_pkt");
                    case(m_sysco_timeout_q[0].m_sysco_st)
                      CONNECT : begin
                        m_timeout_old_tb_pkt.sysco_req = 1;
                        m_timeout_old_tb_pkt.sysco_ack = 0;
                      end
                      DISCONNECT : begin
                        m_timeout_old_tb_pkt.sysco_req = 0;
                        m_timeout_old_tb_pkt.sysco_ack = 1;
                      end
                    endcase
                    setup_x_sysco_pkt(m_timeout_old_tb_pkt, m_sysco_timeout_q[0].is_SyscoNintf);
                    `uvm_info(`LABEL, $psprintf("Added back timeout m_sysco_q entry, %0s. state=%0s, Queue size now is %0d, current sysco_req pkt cnt=%0d", m_sysco_q[0].convert2string, m_sysco_st, m_sysco_q.size, m_sys_req_cnt), UVM_LOW)
                  end
                  <% if(obj.testBench != "fsys"){ %>
                  if (en_sb_objections) ->e_queue_change;
                  <% } %>
                end else if(is_err) begin
                  `uvm_error(`LABEL_ERROR, $psprintf("Undefined sysco_state = %0d., size=%0d", m_sysco_st, m_sysco_q.size))
                end
              end
            end
          end
        end
    end

endfunction

//******************************************************************************
// Function : process_cmd_rsp
// Purpose  :
//
// Checks that are needed
//
//******************************************************************************
function void chi_aiu_scb::process_cmd_rsp(const ref smi_seq_item m_pkt);
    string  spkt;
    int     find_q[$];
    int     find_q_with_targ_id_err[$];

    find_q = {};
    find_q_with_targ_id_err = {};
    find_q = m_ott_q.find_index with (
                item.smi_exp[`CMD_RSP_IN] == 1
                && item.m_cmd_req_pkt !== null
                && item.m_cmd_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                && item.m_cmd_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id
                );
    find_q_with_targ_id_err = m_ott_q.find_index with (
                item.smi_exp[`CMD_RSP_IN] == 1
                && item.m_cmd_req_pkt !== null
                && item.m_cmd_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                );
    if ($test$plusargs("wrong_cmdrsp_target_id") && !is_resend_correct_target_id) begin
      if (m_pkt.smi_targ_ncore_unit_id != <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        `ifndef FSYS_COVER_ON
        cov.collect_cmd_rsp_wtgtid(m_pkt);
	`elsif CHI_SUBSYS_COVER_ON
        cov.collect_cmd_rsp_wtgtid(m_pkt);
        `endif
        `uvm_info(`LABEL,$sformatf("CMDrsp targ_id = %0h, smi_rmsg_id = %0h",m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_rmsg_id),UVM_NONE)
        if (m_ott_q[find_q_with_targ_id_err[0]].smi_rcvd[`STR_REQ_IN] == 0) begin
          cmd_rsp_targ_err_rmsg_id[m_pkt.smi_rmsg_id] = m_pkt.smi_rmsg_id;
        end else if (m_ott_q[find_q_with_targ_id_err[0]].smi_rcvd[`STR_REQ_IN] == 1 && m_ott_q[find_q_with_targ_id_err[0]].smi_rcvd[`STR_RSP_OUT] == 0) begin //CMDrsp received after STRreq & before STRrsp
          if (str_req_msg_id_for_cmd_rsp_targ_err.exists(m_pkt.smi_rmsg_id)) begin
            str_req_msg_id_corsp_str_rmsg_id[str_req_msg_id_for_cmd_rsp_targ_err[m_pkt.smi_rmsg_id]] = str_req_msg_id_for_cmd_rsp_targ_err[m_pkt.smi_rmsg_id];
          end    
        end
      end
    end

    if(find_q.size() == 1) begin
        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a CMD_RSP packet:%0s", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)
        m_ott_q[find_q[0]].exp_cmd_rsp_pkt.smi_msg_id=m_pkt.smi_msg_id;  // smi_msg_id is local to cmd_rsp pkt
        m_ott_q[find_q[0]].exp_cmd_rsp_pkt.not_RTL=1;
      <%if (obj.testBench == "fsys") { %>
        if  ((m_ott_q[find_q[0]].exp_dtw_req_pkt != null) && (m_ott_q[find_q[0]].m_chi_write_data_pkt[0] != null) && (m_ott_q[find_q[0]].m_chi_req_pkt.opcode == DVMOP)) begin
            if ((m_ott_q[find_q[0]].m_chi_write_data_pkt[0].resperr === 2'b10) && (m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_cmstatus_err_payload == 7'b0000011) && (m_ott_q[find_q[0]].exp_dtw_req_pkt.smi_cmstatus_err == 1'b1)) begin 
                m_ott_q[find_q[0]].exp_cmd_rsp_pkt.smi_cmstatus_err = 1'b1;
                m_ott_q[find_q[0]].exp_cmd_rsp_pkt.smi_cmstatus_err_payload = 7'b0000011;
            end
        end
       <% } %>
        if ($test$plusargs("mkrdunq_error")) begin
            m_ott_q[find_q[0]].exp_cmd_rsp_pkt.smi_cmstatus = m_pkt.smi_cmstatus;
        end
        `ASSERT(m_ott_q[find_q[0]].exp_cmd_rsp_pkt.compare(m_pkt));
        m_ott_q[find_q[0]].add_smi_cmd_rsp(m_pkt);
        if (m_ott_q[find_q[0]].smi_exp[`CMD_REQ_OUT] !== 0
            && (!(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>, combined_wr_nc_ops, combined_wr_c_ops<% } %>}))) begin
            `uvm_error(`LABEL_ERROR, $psprintf("Received a CMD_RSP without receiving CMD_REQ"))
        end
        if (m_ott_q[find_q[0]].smi_exp == 0 && m_ott_q[find_q[0]].chi_exp == 0)
            delete_ott_entry(find_q[0]);
        if ((m_pkt.smi_cmstatus[7:6] === 2'b10 && m_pkt.smi_cmstatus[5] === 1'b0 && m_pkt.smi_cmstatus[2:0] === 3'b011) || (m_pkt.smi_cmstatus[7:6] === 2'b10 && m_pkt.smi_cmstatus[5] === 1'b1 && m_pkt.smi_cmstatus[2:0] === 3'b110)) begin
          `uvm_info(`LABEL, $sformatf("CHIAIU_UID:%0d : Received CMDrsp cmstatus with data error, cmstatus = %0h", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.smi_cmstatus),UVM_LOW)
          CMDrsp_aiu_txn_ids_with_cmstatus_with_err[m_ott_q[find_q[0]].chi_aiu_uid] = m_ott_q[find_q[0]].chi_aiu_uid;
        end else if (m_pkt.smi_cmstatus[7:6] === 2'b10) begin
          `uvm_info(`LABEL, $sformatf("CHIAIU_UID:%0d : Received CMDrsp cmstatus with non data error, cmstatus = %0h", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.smi_cmstatus),UVM_LOW)
          CMDrsp_aiu_txn_ids_with_cmstatus_with_err_other_val[m_ott_q[find_q[0]].chi_aiu_uid] = m_ott_q[find_q[0]].chi_aiu_uid;
        end
    end else begin
        if (!$test$plusargs("wrong_cmdrsp_target_id")) begin
          //print_ott_info();
          `uvm_info(`LABEL,$sformatf("%s", m_pkt.convert2string()), UVM_NONE)
          spkt = {"Found no matching txn for the above CMD rsp pkt"};
          `uvm_error(`LABEL_ERROR, $psprintf("%0s: %0s # of matches: 0x%0h", spkt, m_pkt.convert2string(), find_q.size()))
        end else begin
          if(!is_resend_correct_target_id)
            m_ott_q[find_q_with_targ_id_err[0]].add_smi_cmd_rsp(m_pkt);
          `uvm_info(`LABEL,$sformatf("Injected error in, %s", m_pkt.convert2string()), UVM_NONE)
        end 
    end

endfunction



//******************************************************************************
// Function : process_snp_dtr_rsp
// Purpose  :
//
// Checks that are needed
//
//******************************************************************************
function void chi_aiu_scb::process_snp_dtr_rsp(const ref smi_seq_item m_pkt);
    string  spkt;
    int     find_q[$];

    find_q = {};
    //find_q = m_ott_q.find_index with (
    //            item.isSFISNPDTRReqNeeded    == 1                &&
    //            item.isSFISNPDTRRespRcvd     == 0                &&
    //           (item.m_snp_dtr_req_pkt.smi_msg_id   ==
    //            m_pkt.smi_msg_id)
    //         );

    //if(find_q.size() == 1) begin
    //    m_ott_q[find_q[0]].add_smi_snp_dtr_rsp(m_pkt);
    //end else begin
    //    `uvm_info(`LABEL,$sformatf("%s", m_pkt.convert2string()), UVM_NONE)
    //    spkt = {"Found no matching txn for the above Snoop DTR rsp pkt"};
    //    `uvm_error(`LABEL_ERROR, spkt)
    //end
endfunction


//******************************************************************************
// Function : process_dtw_rsp
// Purpose  :
//
// Checks that are needed
//
//******************************************************************************
function void chi_aiu_scb::process_dtw_rsp(const ref smi_seq_item m_pkt);
    string  spkt;
    int     find_q[$];
    int     find_q_with_targ_id_err[$];

    find_q = {};
    find_q_with_targ_id_err = {};
    find_q = m_ott_q.find_index with (
                (item.smi_exp[`DTW_RSP_IN] == 1 || item.smi_exp[`SNP_DTW_RSP_IN] == 1)
                && item.m_dtw_req_pkt !== null
                && item.m_dtw_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                && item.m_dtw_req_pkt.smi_targ_ncore_unit_id == m_pkt.smi_src_ncore_unit_id
                && item.m_dtw_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id
                );
    find_q_with_targ_id_err = m_ott_q.find_index with (
                (item.smi_exp[`DTW_RSP_IN] == 1 || item.smi_exp[`SNP_DTW_RSP_IN] == 1)
                && item.m_dtw_req_pkt !== null
                && item.m_dtw_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                && item.m_dtw_req_pkt.smi_targ_ncore_unit_id == m_pkt.smi_src_ncore_unit_id
                );
    if ($test$plusargs("wrong_dtwrsp_target_id") && !is_resend_correct_target_id) begin //#Check.CHIAIU.v3.Error.dtwrsp
      if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        `ifndef FSYS_COVER_ON
        cov.collect_dtw_rsp_wtgtid(m_pkt);
	`elsif CHI_SUBSYS_COVER_ON
        cov.collect_dtw_rsp_wtgtid(m_pkt);
        `endif
        `uvm_info(`LABEL,$sformatf("CHIAIU_UID:%0d : DTWrsp targ_id = %0h", m_ott_q[find_q_with_targ_id_err[0]].chi_aiu_uid, m_pkt.smi_targ_ncore_unit_id),UVM_LOW)
        dtw_rsp_targ_err_aiu_txn_id[m_ott_q[find_q_with_targ_id_err[0]].chi_aiu_uid] = m_ott_q[find_q_with_targ_id_err[0]].chi_aiu_uid;
      end
    end
    if(find_q.size() == 1) begin
        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a DTW_RSP packet: %0s", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)
        m_ott_q[find_q[0]].exp_dtw_rsp_pkt.unpack_dp_smi_seq_item();
        if ($test$plusargs("dtwrsp_cmstatus_with_error") || $test$plusargs("error_test")) begin //#Check.CHIAIU.v3.Error.dtwrspmstatuserror
          if (m_pkt.smi_cmstatus[SMICMSTATUSERRBIT]) begin
            m_ott_q[find_q[0]].exp_dtw_rsp_pkt.smi_cmstatus_err = m_pkt.smi_cmstatus[SMICMSTATUSERRBIT];
            m_ott_q[find_q[0]].exp_dtw_rsp_pkt.smi_cmstatus_err_payload = m_pkt.smi_cmstatus_err_payload;
	    <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            if (m_ott_q[find_q[0]].m_chi_req_pkt !== null) begin
	        if (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {combined_wr_nc_ops, combined_wr_c_ops}) begin
	    	    m_ott_q[find_q[0]].dtwrsp_cmstatus_err_seen = 1;
	        end
	    end
	    <% } %>
          end
        end

        if ($test$plusargs("en_excl_txn")) begin
          if (m_pkt.smi_cmstatus_exok) begin
            m_ott_q[find_q[0]].exp_dtw_rsp_pkt.smi_cmstatus = m_pkt.smi_cmstatus;
          end
        end
        <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
        if (m_ott_q[find_q[0]].m_chi_req_pkt !== null && m_ott_q[find_q[0]].m_chi_req_pkt.excl == 1) begin
            m_ott_q[find_q[0]].exp_dtw_rsp_pkt.smi_cmstatus[0] = m_pkt.smi_cmstatus[0];
        end
        <%}%>
        m_ott_q[find_q[0]].exp_dtw_rsp_pkt.not_RTL=1;
        `ASSERT(m_ott_q[find_q[0]].exp_dtw_rsp_pkt.compare(m_pkt));
        m_ott_q[find_q[0]].add_smi_dtw_rsp(m_pkt);
        if ((m_pkt.smi_cmstatus[7:6] === 2'b10 && m_pkt.smi_cmstatus[5] === 1'b0 && m_pkt.smi_cmstatus[2:0] === 3'b011) || (m_pkt.smi_cmstatus[7:6] === 2'b10 && m_pkt.smi_cmstatus[5] === 1'b1 && m_pkt.smi_cmstatus[2:0] === 3'b110)) begin
          `uvm_info(`LABEL, $sformatf("CHIAIU_UID:%0d : Received DTWrsp cmstatus with data error, cmstatus = %0h", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.smi_cmstatus),UVM_LOW)
          DTWrsp_aiu_txn_ids_with_cmstatus_with_err[m_ott_q[find_q[0]].chi_aiu_uid] = m_ott_q[find_q[0]].chi_aiu_uid;
        end else if (m_pkt.smi_cmstatus[7:6] === 2'b10) begin
          `uvm_info(`LABEL, $sformatf("CHIAIU_UID:%0d : Received DTWrsp cmstatus with non data error, cmstatus = %0h", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.smi_cmstatus),UVM_LOW)
          DTWrsp_aiu_txn_ids_with_cmstatus_with_err_other_val[m_ott_q[find_q[0]].chi_aiu_uid] = m_ott_q[find_q[0]].chi_aiu_uid;
        end
    end else begin
        if (!$test$plusargs("wrong_dtwrsp_target_id")) begin
          //print_ott_info();
          `uvm_info(`LABEL,$sformatf("%s", m_pkt.convert2string()), UVM_NONE)
          spkt = {"Found no matching txn for the above DTW rsp pkt"};
          `uvm_error(`LABEL_ERROR, $psprintf("%0s. # of matches: 0x%0h", spkt, find_q.size()))
        end else begin
          if(!is_resend_correct_target_id)
            m_ott_q[find_q_with_targ_id_err[0]].add_smi_dtw_rsp(m_pkt);
          `uvm_info(`LABEL,$sformatf("Injected error in, %s", m_pkt.convert2string()), UVM_NONE)
        end
    end

endfunction


//******************************************************************************
// Function : process_snp_rsp
// Purpose  :
//
// Checks that are needed
//
//******************************************************************************
function void chi_aiu_scb::process_snp_rsp(const ref smi_seq_item m_pkt);
    string  spkt;
    int     find_q[$];
    int find_q_targ_id_err[$];
   <% if(obj.testBench == 'chi_aiu' || obj.testBench == "fsys") { %>
   `ifdef VCS
    chi_sysco_state_t state; 
   `endif 
   <% } %>

  // #Stimulus.FSYS.connectivity.AIUtoDCE
  if(addr_trans_mgr::check_aiu_is_unconnected(.tgt_unit_id(m_pkt.smi_targ_ncore_unit_id), .src_unit_id(m_pkt.smi_src_ncore_unit_id))) begin
    `uvm_error(`LABEL_ERROR,
    $sformatf("In SNP_RSP, Connectivity between TGT FUnitID %0d and SRC FUnitID %0d should have been optimized and not existing", m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_src_ncore_unit_id))
  end

    find_q = {};
    find_q_targ_id_err = {};

    find_q = m_ott_q.find_index with ((
                <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                (item.smi_exp[`SNP_RSP_OUT] == 1 || (item.smi_exp[`SNP_RSP_OUT] == 0 && (item.m_snp_req_pkt !== null && item.m_snp_req_pkt.smi_msg_type inside {SNP_STSH_SH, SNP_STSH_UNQ}) && item.normal_stsh_snoop != 1))
                <%}else{%>
                item.smi_exp[`SNP_RSP_OUT] == 1
                <%}%>
                && item.m_snp_req_pkt !== null
                && item.m_snp_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                && item.m_snp_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id)
                || (
                $test$plusargs("k_toggle_sysco")
                && item.m_sysco_st != m_sysco_st
                && !item.chi_rcvd[`CHI_SNP_REQ]
                && item.m_snp_req_pkt !== null
                && item.m_snp_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                && item.m_snp_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id)
                );
    if ($test$plusargs("wrong_snpreq_target_id")) begin
      if (m_pkt.smi_src_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        find_q_targ_id_err = snp_targ_err_msg_id.find_index with (item.src_id == m_pkt.smi_targ_ncore_unit_id &&
                                                                  item.msg_id == m_pkt.smi_rmsg_id
                                                                 );
        
        if (find_q_targ_id_err.size() != 0) begin
          `uvm_info(`LABEL,$sformatf("SNPrsp pkt:", m_pkt.convert2string()), UVM_NONE);
          `uvm_error(`LABEL_ERROR,$sformatf("CHI-AIU not dropping SNPreq with msg_id: %0h for wrong targ id",snp_targ_err_msg_id[find_q_targ_id_err[0]].msg_id))
        end
      end
    end

    // if (find_q.size() > 1) begin
    //     $display("smi rmsg_id: %0d \n", m_pkt.smi_rmsg_id);
    //     foreach(find_q[i]) begin
    //         $display("====================================================================");
    //         $display("SNP_RSP_OUT: %0d", m_ott_q[find_q[i]].smi_exp[`SNP_RSP_OUT]);
    //         if (m_ott_q[find_q[i]].m_snp_req_pkt != null) begin
    //             $display("SNP REQ PKT present");
    //             $display("snp_req msg type:%p", m_ott_q[find_q[i]].m_snp_req_pkt.smi_msg_type);
    //             $display("snp_req msg id:%0d", m_ott_q[find_q[i]].m_snp_req_pkt.smi_msg_id);
    //         end
    //         $display("====================================================================");
    //     end
    // end

    if(find_q.size() == 1) begin
        if (m_ott_q[find_q[0]].smi_exp[`SNP_RSP_OUT]) begin
            m_ott_q[find_q[0]].normal_stsh_snoop = 1;
            if(($test$plusargs("k_toggle_sysco"))
            && (m_ott_q[find_q[0]].smi_sysco_state inside {ENABLED})
            && (get_cur_sysco_state inside {DISCONNECT, DISABLED})
            ) begin
            if(!m_ott_q[find_q[0]].chi_rcvd[`CHI_SNP_REQ]) begin
                m_ott_q[find_q[0]].setup4sysco_snp_req(m_sysco_st);
            <% if(obj.testBench == 'chi_aiu' || obj.testBench == "fsys") { %>
                `ifndef VCS
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : DBG_CHK: Seems like SMI_SNP received while in sysco(%0s), but CHI-AIU's STT fetched it during sysco(%0s).", m_ott_q[find_q[0]].chi_aiu_uid, m_ott_q[find_q[0]].smi_sysco_state.name, get_cur_sysco_state.name), UVM_LOW)
                `else // `ifndef VCS
                state=get_cur_sysco_state;
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : DBG_CHK: Seems like SMI_SNP received while in sysco(%0s), but CHI-AIU's STT fetched it during sysco(%0s).", m_ott_q[find_q[0]].chi_aiu_uid, m_ott_q[find_q[0]].smi_sysco_state.name, state), UVM_LOW)
                `endif // `ifndef VCS
                <% } else {%>
                `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : DBG_CHK: Seems like SMI_SNP received while in sysco(%0s), but CHI-AIU's STT fetched it during sysco(%0s).", m_ott_q[find_q[0]].chi_aiu_uid, m_ott_q[find_q[0]].smi_sysco_state.name, get_cur_sysco_state.name), UVM_LOW)
                <% } %>
                m_ott_q[find_q[0]].is_sysco_snp_returned = 1'b1;
                m_ott_q[find_q[0]].chi_exp = 0;
            end
            end
            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a SNP_RSP packet. Matching it with the expected packet:%0s.", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)
            m_ott_q[find_q[0]].exp_snp_rsp_pkt.smi_cmstatus_rv = m_pkt.smi_cmstatus_rv;
            m_ott_q[find_q[0]].exp_snp_rsp_pkt.smi_cmstatus_rs = m_pkt.smi_cmstatus_rs;
            m_ott_q[find_q[0]].exp_snp_rsp_pkt.smi_cmstatus_dc = m_pkt.smi_cmstatus_dc;
            m_ott_q[find_q[0]].exp_snp_rsp_pkt.smi_cmstatus_dt_aiu = m_pkt.smi_cmstatus_dt_aiu;
            m_ott_q[find_q[0]].exp_snp_rsp_pkt.smi_cmstatus_dt_dmi = m_pkt.smi_cmstatus_dt_dmi;
            m_ott_q[find_q[0]].exp_snp_rsp_pkt.smi_cmstatus_snarf = m_pkt.smi_cmstatus_snarf;
            m_ott_q[find_q[0]].exp_snp_rsp_pkt.smi_mpf1_dtr_msg_id = m_pkt.smi_mpf1_dtr_msg_id;
            //commented according to CONC-7444, data errors are not reported in SNP_RSP if reveived in Data Channel
            //#Check.CHIAIU.v3.Error.snpnondataerr
            if (m_ott_q[find_q[0]].m_chi_srsp_pkt != null && m_ott_q[find_q[0]].m_chi_srsp_pkt.resperr == 2'b11) begin
            m_ott_q[find_q[0]].exp_snp_rsp_pkt.smi_cmstatus_err = 1'b1;
            m_ott_q[find_q[0]].exp_snp_rsp_pkt.smi_cmstatus_err_payload = 7'b0000100;
            end
            if(   /*1-non_data_err*/
                ($test$plusargs("SNPrsp_with_non_data_error")
                && m_ott_q[find_q[0]].m_chi_srsp_pkt != null
                && m_ott_q[find_q[0]].m_chi_srsp_pkt.resperr == 2'b11)
            ||((k_snp_rsp_non_data_err_wgt != 0) && (m_ott_q[find_q[0]].m_chi_srsp_pkt != null) && (m_ott_q[find_q[0]].m_chi_srsp_pkt.resperr == 2'b11))
                /*2-data_err*/
            || ($test$plusargs("SNPrsp_with_data_error")
                && m_ott_q[find_q[0]].m_chi_snp_data_pkt.size() != 0
                && m_ott_q[find_q[0]].m_chi_snp_data_pkt[$].resperr == 2'b10)
            )
            begin
            // when respective smi_snp_rsp gets captured, STT will be logged i.e CONC-7431
            //`uvm_info(`LABEL,$sformatf("Triggering csr_event: ev_snp_rsp_err with pkt info as:: %0s", m_ott_q[find_q[0]].m_snp_req_pkt.convert2string()), UVM_NONE)
            ev_snp_rsp_err.trigger(m_ott_q[find_q[0]]);
            end
            //Commented as DATA error is not reported in CHI SRSP flit
            //if (m_ott_q[find_q[0]].m_chi_srsp_pkt != null && m_ott_q[find_q[0]].m_chi_srsp_pkt.resperr == 2'b10) begin
            //  m_ott_q[find_q[0]].exp_snp_rsp_pkt.smi_cmstatus_err = 1'b1;
            //  m_ott_q[find_q[0]].exp_snp_rsp_pkt.smi_cmstatus_err_payload = 7'b0000011;
            //end
            `ASSERT(m_ott_q[find_q[0]].exp_snp_rsp_pkt.compare(m_pkt));
            m_ott_q[find_q[0]].add_smi_snp_rsp(m_pkt);
            if(m_ott_q[find_q[0]].m_snp_req_pkt.smi_msg_type == SNP_DVM_MSG) begin
                if(m_ott_q[find_q[0]].is_sysco_snp_returned) begin
                    if (!one_dvm_sync_enable) begin
                        update_snp_req_addr_q(m_ott_q[find_q[0]], dvm_snp_req_addr_q, "org");
                    end else begin
                        update_snp_req_addr_q(m_ott_q[find_q[0]], dvm_snp_req_addr_sync_q, "org");
                        update_snp_req_addr_q(m_ott_q[find_q[0]], dvm_snp_req_addr_nonsync_q, "org");
                    end
                end
                // dup we are not checking at chi_snp_addr_port
                if (!one_dvm_sync_enable) begin
                    update_snp_req_addr_q(m_ott_q[find_q[0]], dvm_snp_req_addr_dup_q, "dup");
                end else begin
                    update_snp_req_addr_q(m_ott_q[find_q[0]], dvm_snp_req_addr_sync_dup_q, "dup");
                    update_snp_req_addr_q(m_ott_q[find_q[0]], dvm_snp_req_addr_nonsync_dup_q, "dup");
                end
            end
            if (m_ott_q[find_q[0]].smi_exp == 0 && m_ott_q[find_q[0]].chi_exp == 0) begin
                delete_ott_entry(find_q[0]);
            end else begin
                //print_me(find_q[0]);
		//CONC-13490 SNP_DTR_REQ and SNP_DTR_RSP can come after SNP_RSP
                if ((!(m_ott_q[find_q[0]].m_chi_snp_addr_pkt.opcode inside {stash_snps})) && m_ott_q[find_q[0]].smi_exp[`SNP_DTR_REQ] != 1 && m_ott_q[find_q[0]].smi_exp[`SNP_DTR_RSP] != 1)
                    `uvm_error(`LABEL_ERROR, $psprintf("SNP RSP received on SMI interface from AIU but all the expectation flags are not reset: CHI exp: %0h, SMI exp: %0h",m_ott_q[find_q[0]].chi_exp, m_ott_q[find_q[0]].smi_exp))
            end
            <% if(obj.testBench=="emu") { %>
            if ($test$plusargs("SNPrsp_with_data_error") &&
                        m_ott_q[find_q[0]].m_chi_snp_data_pkt.size() != 0 &&  
                        m_ott_q[find_q[0]].m_chi_snp_data_pkt[$].resperr == 2'b10) begin
                            ev_snp_rsp_err.trigger(m_ott_q[find_q[0]]);
                        end
            <% } %>
        end else begin
            m_ott_q[find_q[0]].chi_exp[`CHI_SNP_REQ] = 0;
            m_ott_q[find_q[0]].normal_stsh_snoop = 0;
            `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a SNP_RSP packet. Matching it with the expected packet:%0s.", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)
            if (m_ott_q[find_q[0]].smi_exp == 0 && m_ott_q[find_q[0]].chi_exp == 0) begin
                delete_ott_entry(find_q[0]);
            end else begin
                // $display(" why are we here? :%d", m_ott_q[find_q[0]].chi_exp, m_ott_q[find_q[0]].smi_exp);
                // if (m_ott_q[find_q[0]].m_snp_req_pkt != null) begin
                //     $display(" this should be deleted==========");
                //     $display("snp_req msg type:%p", m_ott_q[find_q[0]].m_snp_req_pkt.smi_msg_type);
                //     $display("snp_req msg id:%0d", m_ott_q[find_q[0]].m_snp_req_pkt.smi_msg_id);
                // end
            end
        end
    end else begin
        // #Check.CHI.v3.6.DVM.received_both_fromCHI_prior_send_snp_rsp
        //print_ott_info();
        `uvm_info(`LABEL,$sformatf("%s", m_pkt.convert2string()), UVM_NONE)
        spkt = {"Found no matching txn for the above SNP rsp pkt"};
        `uvm_error(`LABEL_ERROR, $psprintf("%0s. # of matches: 0x%0h for txn:%0s", spkt, find_q.size(), m_pkt.convert2string()))
    end

endfunction


//******************************************************************************
// Function : process_str_rsp
// Purpose  :
//
// Checks that are needed
//
//******************************************************************************
function void chi_aiu_scb::process_str_rsp(const ref smi_seq_item m_pkt);
    string  spkt;
    int     find_q[$];
    int find_q_targ_id_err[$];
    chi_aiu_scb_txn m_scb_pkt_temp;
    chi_req_seq_item m_req_tmp;
    int prev_txnid;

    find_q = {};
    find_q_targ_id_err = {};
    find_q = m_ott_q.find_index with (
                item.smi_exp[`STR_RSP_OUT] == 1
                && ((item.m_str_req_pkt != null
                      && item.m_str_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                      && item.m_str_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id
                      && (item.str_rsp_1_seen == 0))
                    || (item.m_str_req_pkt_2 != null
                      && item.m_str_req_pkt_2.smi_msg_id == m_pkt.smi_rmsg_id
                      && item.m_str_req_pkt_2.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id))
                );

    if ($test$plusargs("wrong_strreq_target_id") && !is_resend_correct_target_id) begin
      if (m_pkt.smi_src_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        find_q_targ_id_err = str_targ_err_msg_id.find_index with (item.src_id == m_pkt.smi_targ_ncore_unit_id &&
                                                                  item.msg_id == m_pkt.smi_rmsg_id
                                                                 );
        
        if (find_q_targ_id_err.size() != 0) begin
          `uvm_info(`LABEL,$sformatf("STRreq pkt:", m_pkt.convert2string()), UVM_NONE);
          `uvm_error(`LABEL_ERROR,$sformatf("CHI-AIU not dropping STRreq with msg_id: %0h for wrong targ id",str_targ_err_msg_id[find_q_targ_id_err[0]].msg_id))
        end
      end
    end
    if ($test$plusargs("wrong_cmdrsp_target_id") && !is_resend_correct_target_id) begin
      if (m_pkt.smi_rmsg_id inside {str_req_corsp_cmd_rsp_rmsg_id} || m_pkt.smi_rmsg_id inside {str_req_msg_id_corsp_str_rmsg_id}) begin
          m_pkt.convert2string();
	if ((!$test$plusargs("error_in_2nd_part")) && (!$test$plusargs("error_in_cmo_part"))) begin
            `uvm_error(`LABEL_ERROR,$sformatf("CHI-AIU not dropping CMDrsp with msg_id: %0h for wrong targ id",cmd_rsp_rmsg_id_corsp_str_msg_id[m_pkt.smi_rmsg_id]))
            str_req_corsp_cmd_rsp_rmsg_id.delete(m_pkt.smi_rmsg_id);
            str_req_msg_id_corsp_str_rmsg_id.delete(m_pkt.smi_rmsg_id);
	end else if($test$plusargs("error_in_2nd_part") && m_ott_q[find_q[0]].str_rsp_1_seen == 1) begin
            `uvm_error(`LABEL_ERROR,$sformatf("CHI-AIU not dropping CMDrsp with msg_id: %0h for wrong targ id",cmd_rsp_rmsg_id_corsp_str_msg_id[m_pkt.smi_rmsg_id]))
            str_req_corsp_cmd_rsp_rmsg_id.delete(m_pkt.smi_rmsg_id);
            str_req_msg_id_corsp_str_rmsg_id.delete(m_pkt.smi_rmsg_id);
	<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
	end else if($test$plusargs("error_in_cmo_part") && m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {combined_wr_c_ops}) begin
            `uvm_error(`LABEL_ERROR,$sformatf("CHI-AIU not dropping CMDrsp with msg_id: %0h for wrong targ id",cmd_rsp_rmsg_id_corsp_str_msg_id[m_pkt.smi_rmsg_id]))
            str_req_corsp_cmd_rsp_rmsg_id.delete(m_pkt.smi_rmsg_id);
            str_req_msg_id_corsp_str_rmsg_id.delete(m_pkt.smi_rmsg_id);
	<%}%>
	end
      end  
    end

    if(find_q.size() == 1) begin
        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a STR_RSP packet. Matching it with the expected packet.", m_ott_q[find_q[0]].chi_aiu_uid), UVM_LOW)
        //Copy the value here because STR REQ may not have happened when exp STR_RSP was generated
        if ( m_ott_q[find_q[0]].m_str_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id && m_ott_q[find_q[0]].str_rsp_1_seen == 0) begin
            m_ott_q[find_q[0]].exp_str_rsp_pkt.smi_rmsg_id = m_ott_q[find_q[0]].m_str_req_pkt.smi_msg_id;
            m_ott_q[find_q[0]].exp_str_rsp_pkt.smi_msg_id  = m_pkt.smi_msg_id;
            m_ott_q[find_q[0]].exp_str_rsp_pkt.smi_targ_ncore_unit_id = m_ott_q[find_q[0]].m_str_req_pkt.smi_src_ncore_unit_id;
            `ASSERT(m_ott_q[find_q[0]].exp_str_rsp_pkt.compare(m_pkt));
        end else begin
            m_ott_q[find_q[0]].exp_str_rsp_pkt_2.smi_rmsg_id = m_ott_q[find_q[0]].m_str_req_pkt_2.smi_msg_id;
            m_ott_q[find_q[0]].exp_str_rsp_pkt_2.smi_msg_id  = m_pkt.smi_msg_id;
            m_ott_q[find_q[0]].exp_str_rsp_pkt_2.smi_targ_ncore_unit_id = m_ott_q[find_q[0]].m_str_req_pkt_2.smi_src_ncore_unit_id;
            m_ott_q[find_q[0]].exp_str_rsp_pkt_2.smi_tm = m_ott_q[find_q[0]].m_str_req_pkt_2.smi_tm;
            `ASSERT(m_ott_q[find_q[0]].exp_str_rsp_pkt_2.compare(m_pkt));
        end

	if (m_ott_q[find_q[0]].m_chi_req_pkt !== null
            && m_ott_q[find_q[0]].m_chi_req_pkt.expcompack == 1
            && m_ott_q[find_q[0]].chi_exp[`CHI_SRESP] == 1) begin
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                if ((!m_ott_q[find_q[0]].m_str_req_pkt.smi_cmstatus_exok) && ((m_ott_q[find_q[0]].m_chi_req_pkt.opcode == MAKEREADUNIQUE && (!m_ott_q[find_q[0]].mkrdunq_part1_complete)) || (m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {combined_wr_nc_ops} && m_ott_q[find_q[0]].str_rsp_1_seen == 0))) begin

                end else begin
                    `uvm_error(`LABEL_ERROR, $psprintf("Received a STR_RSP without receiving COMPACK"))
                end
            <%}else{%>
                `uvm_error(`LABEL_ERROR, $psprintf("Received a STR_RSP without receiving COMPACK"))
            <%}%>
        end

        m_ott_q[find_q[0]].add_smi_str_rsp(m_pkt);

        if (m_ott_q[find_q[0]].smi_exp[`STR_REQ_IN] !== 0) begin
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
             if ((!(m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {combined_wr_nc_ops, combined_wr_c_ops})) || ((m_ott_q[find_q[0]].m_chi_req_pkt.opcode inside {combined_wr_nc_ops, combined_wr_c_ops}) && (m_ott_q[find_q[0]].wr_cmo_first_part_done == 0)))
            <%}%>
            `uvm_error(`LABEL_ERROR, $psprintf("Received a STR_RSP without receiving STR_REQ"))
        end
        
        if ($test$plusargs("wrong_dtwrsp_target_id") && !is_resend_correct_target_id) begin
          if (m_ott_q[find_q[0]].chi_aiu_uid inside {dtw_rsp_targ_err_aiu_txn_id}) begin
            `uvm_error(`LABEL_ERROR,$sformatf("CHI-AIU not droping DTWrsp for wrong target id with smi_rmsg_id = %0h",m_ott_q[find_q[0]].m_dtw_rsp_pkt.smi_rmsg_id))
          end
        end
        if ($test$plusargs("wrong_dtrrsp_target_id")) begin  //#Check.CHIAIU.v3.Error.dtrrsp
          if (m_ott_q[find_q[0]].chi_aiu_uid inside {dtr_rsp_targ_err_aiu_txn_id}) begin
            `uvm_error(`LABEL_ERROR,$sformatf("CHI-AIU not droping DTRrsp for wrong target id with smi_rmsg_id = %0h",m_ott_q[find_q[0]].m_dtr_rsp_pkt.smi_rmsg_id))
          end
        end
        //#Check.CHI.v3.6.DVM.non_sync_complete
        //#Check.CHI.v3.6.DVM.sync_complete
        if (m_ott_q[find_q[0]].smi_exp == 0 && m_ott_q[find_q[0]].chi_exp == 0) begin
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                if(m_ott_q[find_q[0]].m_chi_req_pkt.opcode == MAKEREADUNIQUE && m_ott_q[find_q[0]].m_chi_req_pkt.excl && !m_ott_q[find_q[0]].m_str_req_pkt.smi_cmstatus_exok && !m_ott_q[find_q[0]].mkrdunq_part1_complete) begin
                    prev_txnid = m_ott_q[find_q[0]].chi_aiu_uid;
                    m_req_tmp = chi_req_seq_item::type_id::create("m_req_tmp");
                    m_req_tmp.copy(m_ott_q[find_q[0]].m_chi_req_pkt);
                    delete_ott_entry(find_q[0]);
                    m_scb_pkt_temp = new(,m_req_aiu_id);
                    m_scb_pkt_temp.chi_aiu_uid = prev_txnid;
                    m_scb_pkt_temp.mkrdunq_part1_complete = 1;
                    m_scb_pkt_temp.setup_chi_req_pkt(m_req_tmp);
                    m_ott_q.push_back(m_scb_pkt_temp);
                end else begin
                    delete_ott_entry(find_q[0]);
                end
            <%}else{%>
                delete_ott_entry(find_q[0]);
            <%}%>
        end
    end else begin
        `uvm_info(`LABEL,$sformatf("%s", m_pkt.convert2string()), UVM_NONE)
        spkt = {"Found no matching txn for the above STR rsp pkt"};
        `uvm_error(`LABEL_ERROR, $psprintf("%0s : %0s # of matches: 0x%0h", spkt, m_pkt.convert2string(), find_q.size()))
    end

endfunction


//******************************************************************************
// Function : process_dtr_rsp
// Purpose  :
//
// Checks that are needed
//
//******************************************************************************
function void chi_aiu_scb::process_dtr_rsp(const ref smi_seq_item m_pkt);
    string  spkt;
    int     find_q[$];
    int     find_q_with_targ_id_err[$];
    int     find_q_targ_id_err[$];

    //#Stimulus.FSYS.connectivity.AIUtoAIU
    if(addr_trans_mgr::check_aiu_is_unconnected(.tgt_unit_id(m_pkt.smi_targ_ncore_unit_id), .src_unit_id(m_pkt.smi_src_ncore_unit_id))) begin
      `uvm_error(`LABEL_ERROR,
      $sformatf("In DTR_RSP, Connectivity between AIU FUnitID %0d and AIU FUnitID %0d should have been optimized and not existing", m_pkt.smi_src_ncore_unit_id, m_pkt.smi_src_ncore_unit_id))
    end

    find_q = {};
    find_q_targ_id_err = {};
    find_q_with_targ_id_err = {};
    find_q = m_ott_q.find_index with (
                (item.smi_exp[`DTR_RSP_OUT] == 1 || item.smi_exp[`SNP_DTR_RSP] == 1)
                && ((item.m_dtr_req_pkt !== null
                    && item.m_dtr_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                    && item.m_dtr_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id
                    && m_pkt.smi_src_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)
                || (item.m_snp_dtr_req_pkt !== null
                    && item.m_snp_dtr_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                    && item.m_snp_dtr_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id
                    && item.m_snp_req_pkt.smi_msg_type inside {SNP_CLN_DTR, SNP_NITC, SNP_VLD_DTR, SNP_INV_DTR, SNP_INV_DTW, SNP_INV, SNP_CLN_DTW, SNP_NOSDINT, SNP_NITCCI, SNP_NITCMI}
                    && m_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)
                || (item.m_chi_snp_addr_pkt !== null
                    && item.m_chi_snp_addr_pkt.opcode inside {stash_snps}
                    && item.m_snp_dtr_req_pkt !== null
                    && item.m_snp_dtr_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                    && item.m_snp_dtr_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id
                    && m_pkt.smi_src_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>))
                );

                // $display("========");
                // $display("ncore src unit id: %0d tagt unit id: %0dand unit id: %0d", m_pkt.smi_src_ncore_unit_id, m_pkt.smi_targ_ncore_unit_id, <%=obj.AiuInfo[obj.Id].FUnitId%>);
                // foreach(m_ott_q[i]) begin
                //     if (m_ott_q[i].m_chi_snp_addr_pkt != null) begin
                //         // $display("%0s", m_ott_q[i].m_chi_snp_addr_pkt.opcode);
                //     end else begin
                //         // $display("why is this null? for txnid: %0d and exp_dtr_rsp:%0d", m_ott_q[i].chi_aiu_uid, m_ott_q[i].smi_exp[`SNP_DTR_RSP]);
                //     end
                //     if (m_ott_q[i].m_snp_dtr_req_pkt == null) begin
                //         $display("snp dtr_req pkt is still null for txnid: %0d", m_ott_q[i].chi_aiu_uid);
                //     end else begin
                //         $display("%0d", m_ott_q[i].m_snp_dtr_req_pkt.smi_src_ncore_unit_id);
                //     end
                // end
    find_q_with_targ_id_err = m_ott_q.find_index with (
                (item.smi_exp[`DTR_RSP_OUT] == 1 || item.smi_exp[`SNP_DTR_RSP] == 1)
                && ((item.m_dtr_req_pkt !== null
                    && item.m_dtr_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                    && item.m_dtr_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id
                    && m_pkt.smi_src_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)
                || (item.m_snp_dtr_req_pkt !== null
                    && item.m_snp_dtr_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                    //&& item.m_snp_dtr_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id // target_id error
                    && item.m_snp_req_pkt.smi_msg_type inside {SNP_CLN_DTR, SNP_NITC, SNP_VLD_DTR, SNP_INV_DTR, SNP_INV_DTW, SNP_INV, SNP_CLN_DTW, SNP_NOSDINT, SNP_NITCCI, SNP_NITCMI}
                    && m_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>)
                || (item.m_chi_snp_addr_pkt !== null
                    && item.m_chi_snp_addr_pkt.opcode inside {stash_snps}
                    && item.m_snp_dtr_req_pkt !== null
                    && item.m_snp_dtr_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id
                    && item.m_snp_dtr_req_pkt.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id
                    && m_pkt.smi_src_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>))
                );
    if ($test$plusargs("wrong_dtrreq_target_id")) begin
      if (m_pkt.smi_src_ncore_unit_id == <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        find_q_targ_id_err = dtr_targ_err_msg_id.find_index with (item.src_id == m_pkt.smi_targ_ncore_unit_id &&
                                                                  item.msg_id == m_pkt.smi_rmsg_id
                                                                 );
        
        if (find_q_targ_id_err.size() != 0) begin
          `uvm_info(`LABEL,$sformatf("DTRrsp pkt:", m_pkt.convert2string()), UVM_NONE);
          `uvm_error(`LABEL_ERROR,$sformatf("CHI-AIU not dropping DTRreq with msg_id: %0h for wrong targ id",dtr_targ_err_msg_id[find_q_targ_id_err[0]].msg_id))
        end
      end
    end
    if ($test$plusargs("wrong_dtrrsp_target_id")) begin //#Check.CHIAIU.v3.Error.dtrrsp
      if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%> && m_ott_q[find_q_with_targ_id_err[0]].smi_exp[`SNP_DTR_RSP] == 1) begin
        `ifndef FSYS_COVER_ON
        cov.collect_dtr_rsp_wtgtid(m_pkt);
	`elsif CHI_SUBSYS_COVER_ON
        cov.collect_dtr_rsp_wtgtid(m_pkt);
        `endif
        `uvm_info(`LABEL,$sformatf("CHIAIU_UID:%0d : DTRrsp targ_id = %0h", m_ott_q[find_q_with_targ_id_err[0]].chi_aiu_uid, m_pkt.smi_targ_ncore_unit_id),UVM_LOW)
        dtr_rsp_targ_err_aiu_txn_id[m_ott_q[find_q_with_targ_id_err[0]].chi_aiu_uid] = m_ott_q[find_q_with_targ_id_err[0]].chi_aiu_uid;
      end
    end
    if(find_q.size() == 1) begin

        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a DTR_RSP packet. Matching it with the expected packet.", m_ott_q[find_q[0]].chi_aiu_uid), UVM_LOW)
    
        m_ott_q[find_q[0]].exp_dtr_rsp_pkt.not_RTL=1;
        <%if (obj.testBench == "fsys") { %>
        m_ott_q[find_q[0]].exp_dtr_rsp_pkt.smi_msg_id = m_pkt.smi_msg_id;
        <% } %>
        `ASSERT(m_ott_q[find_q[0]].exp_dtr_rsp_pkt.compare(m_pkt));
        m_ott_q[find_q[0]].add_smi_dtr_rsp(m_pkt);
        if (m_ott_q[find_q[0]].smi_exp[`DTR_REQ_IN] !== 0
            || m_ott_q[find_q[0]].smi_exp[`SNP_DTR_REQ] !== 0
            ) begin
            `uvm_error(`LABEL_ERROR, $psprintf("Received a DTR_RSP without receiving DTR_REQ"))
        end
        //If str response was already seen, then the message that was only left out was DTR_RSP, delete the entry in that case
        if (m_ott_q[find_q[0]].smi_exp == 0 && m_ott_q[find_q[0]].chi_exp == 0)
            delete_ott_entry(find_q[0]); 
        if ((m_pkt.smi_cmstatus[7:6] === 2'b10 && m_pkt.smi_cmstatus[5] === 1'b0 && m_pkt.smi_cmstatus[2:0] === 3'b011) || (m_pkt.smi_cmstatus[7:6] === 2'b10 && m_pkt.smi_cmstatus[5] === 1'b1 && m_pkt.smi_cmstatus[2:0] === 3'b110)) begin
          `uvm_info(`LABEL, $sformatf("CHIAIU_UID:%0d : Received DTRrsp cmstatus with data error, cmstatus = %0h", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.smi_cmstatus),UVM_LOW)
          DTRrsp_aiu_txn_ids_with_cmstatus_with_err[m_ott_q[find_q[0]].chi_aiu_uid] = m_ott_q[find_q[0]].chi_aiu_uid;
        end else if (m_pkt.smi_cmstatus[7:6] === 2'b10) begin
          `uvm_info(`LABEL, $sformatf("CHIAIU_UID:%0d : Received DTRrsp cmstatus with non data error, cmstatus = %0h", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.smi_cmstatus),UVM_LOW)
          DTRrsp_aiu_txn_ids_with_cmstatus_with_err_other_val[m_ott_q[find_q[0]].chi_aiu_uid] = m_ott_q[find_q[0]].chi_aiu_uid;
        end
    end else begin
        if(!($test$plusargs("wrong_dtrrsp_target_id") || $test$plusargs("wrong_snpreq_target_id"))) begin
          //print_ott_info();
          foreach (find_q[idx])
              print_me(find_q[idx]);
          `uvm_info(`LABEL,$sformatf("%s", m_pkt.convert2string()), UVM_NONE)
          spkt = {"Found no matching txn for the above DTR rsp pkt"};
          `uvm_error(`LABEL_ERROR, $psprintf("%0s. # of matches: 0x%0h PKT:%0s", spkt, find_q.size(), m_pkt.convert2string()))
        end else begin
          if(!is_resend_correct_target_id)
            m_ott_q[find_q_with_targ_id_err[0]].add_smi_dtr_rsp(m_pkt);
          foreach (find_q[idx])
              print_me(find_q[idx]);
          `uvm_info(`LABEL,$sformatf("Injected error in, %s", m_pkt.convert2string()), UVM_NONE)
        end
    end

endfunction

//******************************************************************************
// Function : process_cmp_rsp
// Purpose  :
//
// Checks that are needed
//
//******************************************************************************
function void chi_aiu_scb::process_cmp_rsp(const ref smi_seq_item m_pkt);
    string  spkt;
    int     find_q[$];

    find_q = {};
    find_q = m_ott_q.find_index with (
                (item.smi_exp[`CMP_RSP_IN] == 1)
                && ((item.m_dtw_req_pkt !== null
                    && item.m_dtw_req_pkt.smi_msg_id == m_pkt.smi_rmsg_id))
                );
    if(find_q.size() == 1) begin
        `uvm_info(`LABEL, $psprintf("CHIAIU_UID:%0d : Received a CMP_RSP packet:%0s", m_ott_q[find_q[0]].chi_aiu_uid, m_pkt.convert2string()), UVM_LOW)
        m_ott_q[find_q[0]].exp_cmp_rsp_pkt.smi_msg_id=m_pkt.smi_msg_id;  // smi_msg_id is local to cmd_rsp pkt
      <%if (obj.testBench == "fsys") { %>
        if (($test$plusargs("exp_cmp_rsp_cmstatus_error_in_chi") && $test$plusargs("error_test"))||($test$plusargs("cmprsp_cmstatus_with_error"))) begin
            m_ott_q[find_q[0]].exp_cmp_rsp_pkt.smi_cmstatus = m_pkt.smi_cmstatus;
        end
      <% } else { %>  
        if ($test$plusargs("cmprsp_cmstatus_with_error")) begin
            m_ott_q[find_q[0]].exp_cmp_rsp_pkt.smi_cmstatus = m_pkt.smi_cmstatus;
        end
      <% } %>
        `ASSERT(m_ott_q[find_q[0]].exp_cmp_rsp_pkt.compare(m_pkt));
        m_ott_q[find_q[0]].add_smi_cmp_rsp(m_pkt);
    end else begin
        foreach (find_q[idx])
            print_me(find_q[idx]);
        `uvm_info(`LABEL,$sformatf("%s", m_pkt.convert2string()), UVM_NONE)
        spkt = {"Found no matching txn for the above CMP rsp pkt"};
        `uvm_error(`LABEL_ERROR, $psprintf("%0s. # of matches: 0x%0h", spkt, find_q.size()))
    end

endfunction


////////////////////////////////////////////////////////////////////////////////
// Section5:  Utiltiy Function
//
//
////////////////////////////////////////////////////////////////////////////////

//Function to check if RESP field has valid, allowable values for the given CHI transaction type
function void chi_aiu_scb::check_compdata_resp_field_value(const ref chi_aiu_scb_txn pkt);
    int data_pkt_idx;

    if (pkt.m_chi_req_pkt !== null) begin
        case (pkt.m_chi_req_pkt.opcode)
            READNOSNP:
                begin
                    data_pkt_idx = pkt.m_chi_read_data_pkt.size() - 1;

                    if (pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b000 &&
                        pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b010
                    ) begin
                        `uvm_error (`LABEL_ERROR, $psprintf("COMPDATA RESP field value unexpected for RNS. Expected: 3'b000. Actual: 3'b%03b", pkt.m_chi_read_data_pkt[data_pkt_idx].resp))
                    end
                end
                //#Check.CHI.v3.6.RdPrfrUnq
                // #Check.CHI.v3.6.RdPrfrUnq_excl
                // #Check.CHI.v3.6.RdPrfrUnq_fail_resp
                // #Check.CHI.v3.6.RdPrfrUnq_pass_resp
<% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            READNOTSHAREDDIRTY
            <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            , READPREFERUNIQUE
            , CLEANSHAREDPERSISTSEP
            <%}%>
            :
                begin
                    data_pkt_idx = pkt.m_chi_read_data_pkt.size() - 1;
                    if(pkt.m_chi_read_data_pkt[data_pkt_idx].resp == 3'b111 || pkt.m_chi_read_data_pkt[data_pkt_idx].resp == 3'b000) begin
                        `uvm_error (`LABEL_ERROR, $psprintf("COMPDATA RESP field value unexpected for RDPRFRUNQ. It can not be SD/Inv. Actual: 3'b%03b", pkt.m_chi_read_data_pkt[data_pkt_idx].resp))
                    end
		    end
<% } %>
            <%if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') {%>
            MAKEREADUNIQUE:
                begin
                    data_pkt_idx = pkt.m_chi_read_data_pkt.size() - 1;
                    if (pkt.m_chi_req_pkt.excl) begin
                        if(pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b001 && pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b010 && pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b110) begin
                            `uvm_error (`LABEL_ERROR, $psprintf("COMPDATA RESP field should always be UC, SC or UD_PD. Actual: 3'b%03b", pkt.m_chi_read_data_pkt[data_pkt_idx].resp))
                        end
                    end else begin
                        if(pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b010 && pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b110) begin
                            `uvm_error (`LABEL_ERROR, $psprintf("COMPDATA RESP field value unexpected. It should be either UC or UD_PD. Actual: 3'b%03b", pkt.m_chi_read_data_pkt[data_pkt_idx].resp))
                        end
                    end
                end
            <%}%>
            READCLEAN:
                begin
                    data_pkt_idx = pkt.m_chi_read_data_pkt.size() - 1;
                    if(pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b001 && pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b010) begin
                        `uvm_error (`LABEL_ERROR, $psprintf("COMPDATA RESP field value unexpected for RC. It can not be UD or SD. Actual: 3'b%03b", pkt.m_chi_read_data_pkt[data_pkt_idx].resp))
                    end
                end
            READSHARED:
                begin
                    data_pkt_idx = pkt.m_chi_read_data_pkt.size() - 1;
                    if(pkt.m_chi_read_data_pkt[data_pkt_idx].resp == 3'b000) begin
                        `uvm_error (`LABEL_ERROR, $psprintf("COMPDATA RESP field value unexpected for RS. It can not be I. Actual: 3'b%03b", pkt.m_chi_read_data_pkt[data_pkt_idx].resp))
                    end
                end
            READUNIQUE:
                begin
                    data_pkt_idx = pkt.m_chi_read_data_pkt.size() - 1;
                    if(pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b010 && pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b110) begin
                        `uvm_error (`LABEL_ERROR, $psprintf("COMPDATA RESP field value unexpected for RU. It should be either UC or UD. Actual: 3'b%03b", pkt.m_chi_read_data_pkt[data_pkt_idx].resp))
                    end
                end
<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            READONCE:
<% } else { %>
            READONCE,
            READONCECLEANINVALID,
            READONCEMAKEINVALID:
<% } %>
                begin
                    data_pkt_idx = pkt.m_chi_read_data_pkt.size() - 1;
                    if(pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b010 && pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b000) begin
                        `uvm_error (`LABEL_ERROR, $psprintf("COMPDATA RESP field value unexpected for RO/ROCI, ROMI. It should be either UC or I. Actual: 3'b%03b", pkt.m_chi_read_data_pkt[data_pkt_idx].resp))
                    end
                end
            WRITENOSNPPTL,
            WRITENOSNPFULL,
            WRITEUNIQUEPTL,
            WRITEUNIQUEFULL:
                begin
                    data_pkt_idx = pkt.m_chi_write_data_pkt.size() - 1;
                    if (pkt.m_chi_write_data_pkt[data_pkt_idx].resp !== 3'b000) begin
                        `uvm_error (`LABEL_ERROR, $psprintf("COMPDATA RESP field value unexpected for WNS. Expected: 3'b000. Actual: 3'b%03b", pkt.m_chi_write_data_pkt[data_pkt_idx].resp))
                    end
                end
            WRITEBACKFULL,
            WRITECLEANFULL:
                begin
                    //Do nothing, all resp allowed
                end
            WRITECLEANPTL,
            WRITEBACKPTL:
                begin
                    data_pkt_idx = pkt.m_chi_write_data_pkt.size() - 1;
                    if (pkt.m_chi_write_data_pkt[data_pkt_idx].resp !== 3'b000 
                        && pkt.m_chi_write_data_pkt[data_pkt_idx].resp !== 3'b110) begin
                        `uvm_error (`LABEL_ERROR, $psprintf("CHIAIU_UID:%d : COMPDATA RESP field value unexpected for WBPTL. Expected:3'b000. Actual: 3'b%03b", pkt.chi_aiu_uid, pkt.m_chi_write_data_pkt[data_pkt_idx].resp))
                    end
                end
            WRITEEVICTFULL:
                begin
                    data_pkt_idx = pkt.m_chi_write_data_pkt.size() - 1;
                    //CHI spec 4.5.2
                    if (pkt.m_chi_write_data_pkt[data_pkt_idx].resp !== 3'b010
                        && pkt.m_chi_write_data_pkt[data_pkt_idx].resp !== 3'b001
                        && pkt.m_chi_write_data_pkt[data_pkt_idx].resp !== 3'b000) begin
                        `uvm_error (`LABEL_ERROR, $psprintf("CHIAIU_UID:%d : COMPDATA RESP field value unexpected for WriteEvictFull. Expected: 3'b010/b'b001/3'b000. Actual: 3'b%03b", pkt.chi_aiu_uid, pkt.m_chi_write_data_pkt[data_pkt_idx].resp))
                    end
                end
            DVMOP:
                begin
                    data_pkt_idx = pkt.m_chi_write_data_pkt.size() - 1;
                    if(pkt.m_chi_write_data_pkt[data_pkt_idx].resp !== 3'b000) begin
                        `uvm_error (`LABEL_ERROR, $psprintf("COMPDATA RESP field value unexpected for DVMOP. It should be I. Actual: 3'b%03b", pkt.m_chi_read_data_pkt[data_pkt_idx].resp))
                    end
                end
            default:
                begin
                    //CHI spec table 4-15
                    data_pkt_idx = pkt.m_chi_read_data_pkt.size() - 1;
                    if ((pkt.m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops})
                        && (pkt.m_chi_read_data_pkt[data_pkt_idx].resp !== 3'b000)
                    ) begin
                        `uvm_error (`LABEL_ERROR, $psprintf("COMPDATA RESP field value unexpected for ATOMIC transaction. Expected: 3'b000. Actual: 3'b%03b", pkt.m_chi_read_data_pkt[data_pkt_idx].resp))
                    end
                    if (!(pkt.m_chi_req_pkt.opcode inside {atomic_dat_ops, atomic_dtls_ops}))
                    begin
                        `uvm_error(`LABEL, $psprintf("check_compdata_resp_field_value: Check not implemented OR RESP can be any of the allowed value for this CHI TXN: %0s",pkt.m_chi_req_pkt.opcode.name))
                    end
                end
        endcase
    end

endfunction : check_compdata_resp_field_value


function void chi_aiu_scb::check_snp_dtr_msg_types(const ref chi_aiu_scb_txn pkt);
    case (pkt.m_snp_req_pkt.smi_msg_type)
        SNP_CLN_DTR,
        SNP_VLD_DTR,
        SNP_NITC,
        SNP_NOSDINT:
            begin
                if ( pkt.m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_INV
                    && pkt.m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_CLN
                    && pkt.m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN
                    ) begin
                    //Ncore 3 allows SD when DoNotGoToSD is not set
                    if (pkt.m_chi_snp_addr_pkt.donotgotosd == 0
                    && (pkt.m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_DTY
                        && pkt.m_snp_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_DTY)
                    ) begin
                        `uvm_error(`LABEL_ERROR, $psprintf("DTR message type unexpected for %0s. Expected: SC/UC/I, actual: %0s", eMsgSNP'(pkt.m_snp_req_pkt.smi_msg_type), eMsgDTR'(pkt.m_snp_dtr_req_pkt.smi_msg_type)))
                    end //if DoNotGoToSD
                end // If message types SC/UC/I
            end
        default:
            begin
                `uvm_info(`LABEL, $psprintf("All type of DTRs are allowed for %0s type of snoop", eMsgSNP'(pkt.m_snp_req_pkt.smi_msg_type)), UVM_LOW);
            end
    endcase
endfunction : check_snp_dtr_msg_types

//Function to check if received DTR's smi_msg_type follows the spec allowed values
function void chi_aiu_scb::check_dtr_msg_types(const ref chi_aiu_scb_txn pkt);
    case (pkt.m_cmd_req_pkt.smi_msg_type)
        CMD_RD_NC:
            begin
                if(pkt.m_dtr_req_pkt.smi_msg_type !== DTR_DATA_INV) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("DTR message type unexpected for CMD_RD_NC. Expected: DTR_DATA_INV, actual: %0s", eMsgDTR'(pkt.m_dtr_req_pkt.smi_msg_type)))
                end
            end
        CMD_RD_NITC,
        CMD_RD_NITC_CLN_INV,
        CMD_RD_NITC_MK_INV:
            begin
                if(pkt.m_dtr_req_pkt.smi_msg_type !== DTR_DATA_INV) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("DTR message type unexpected for CMD_RD_NC. Expected: DTR_DATA_INV, actual: %0s", eMsgDTR'(pkt.m_dtr_req_pkt.smi_msg_type)))
                end
            end
        CMD_RD_VLD:
            begin
                if(pkt.m_dtr_req_pkt.smi_msg_type == DTR_DATA_INV) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("DTR message type unexpected for CMD_RD_VLD. Expected: Anything but DTR_DATA_INV, actual: %0s", eMsgDTR'(pkt.m_dtr_req_pkt.smi_msg_type)))
                end
            end
        CMD_RD_CLN:
            begin
                if(pkt.m_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN && pkt.m_dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_CLN) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("DTR message type unexpected for CMD_RD_CLN. Expected: UNQ_CLN or SHR_CLN, actual: %0s", eMsgDTR'(pkt.m_dtr_req_pkt.smi_msg_type)))
                end
            end
        CMD_RD_UNQ:
            begin
                if(pkt.m_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN && pkt.m_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_DTY) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("DTR message type unexpected for CMD_RD_UNQ. Expected: UNQ_CLN or UNQ_DTY, actual: %0s", eMsgDTR'(pkt.m_dtr_req_pkt.smi_msg_type)))
                end
            end
        CMD_RD_NOT_SHD:
            begin
                if(pkt.m_dtr_req_pkt.smi_msg_type == DTR_DATA_SHR_DTY || pkt.m_dtr_req_pkt.smi_msg_type == DTR_DATA_INV) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("DTR message type unexpected for CMD_RD_NOT_SHD. Expected: UC, SC or UD, actual: %0s", eMsgDTR'(pkt.m_dtr_req_pkt.smi_msg_type)))
                end
            end
        CMD_WR_STSH_FULL:
            begin
                if(pkt.m_dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_DTY) begin
                    `uvm_error(`LABEL_ERROR, $psprintf("DTR message type unexpected for CMD_WR_STSH_FULL. Expected: UD, actual: %0s", eMsgDTR'(pkt.m_dtr_req_pkt.smi_msg_type)))
                end
            end
    endcase
endfunction : check_dtr_msg_types


function void chi_aiu_scb::check_dbid_uniqueness(const ref chi_rsp_dbid_t dbid);

    foreach(m_ott_q[idx]) begin
        if (m_ott_q[idx].m_chi_crsp_pkt !== null && m_ott_q[idx].m_str_rsp_pkt == null) begin
            if (m_ott_q[idx].m_chi_crsp_pkt.dbid == dbid
                && (m_ott_q[idx].chi_exp !== 'h0)
               ) begin
                print_me(idx);
                `uvm_error(`LABEL_ERROR, $psprintf("DBID repeated: DBID of currrent CRESP packet matches DBID Value of above printed pending transaction"))
            end
        end
    end // foreach

endfunction : check_dbid_uniqueness

//******************************************************************************
// Function : delete_ott_entry
// Purpose  :
//
//******************************************************************************
function void chi_aiu_scb::delete_ott_entry(int index);// why do we need a reason?, eAIUPktTypes e_reason);
    string spkt;
    string s_reason;

    time tmp0; //chi_cmd to smi_req
    time tmp1; //
    time tmp2;
    time tmp3;
    time tmp4;
    time tmp5;


    time tmp6;
    time tmp7;


    tmp0 = m_ott_q[index].t_smi_cmd_req - m_ott_q[index].t_chi_req_rcvd;
    tmp1 = m_ott_q[index].t_smi_snp_dtr_req - m_ott_q[index].t_chi_snp_rsp ;
    tmp2 = m_ott_q[index].t_smi_dtw_req - m_ott_q[index].t_chi_wdata_rcvd;
    tmp3 = m_ott_q[index].t_chi_snp_req - m_ott_q[index].t_smi_snp_req;
    tmp4 = m_ott_q[index].t_chi_rack_rcvd - m_ott_q[index].t_smi_str_req;
    tmp5 = m_ott_q[index].t_chi_rdata_sent - m_ott_q[index].t_smi_dtr_req;


    tmp6 = m_ott_q[index].t_smi_snp_dtr_req - m_ott_q[index].t_chi_snoop_data_rcvd;
    tmp7 = m_ott_q[index].t_smi_snp_rsp - m_ott_q[index].t_chi_snpresp;

    if(tmp0<t_chicmd_to_smicmdreq_min) t_chicmd_to_smicmdreq_min = tmp0;
    if(tmp1<t_chirsp_to_smicmdrsp_min) t_chirsp_to_smicmdrsp_min = tmp1;
    if(tmp2<t_chiwdat_to_smidat_min)   t_chiwdat_to_smidat_min   = tmp2;
    if(tmp3<t_smisnp_to_chisnp_min)    t_smisnp_to_chisnp_min    = tmp3;
    if(tmp4<t_smirsp_to_chirsp_min)    t_smirsp_to_chirsp_min    = tmp4;
    if(tmp5<t_smidat_to_chirdat_min)   t_smidat_to_chirdat_min   = tmp5;


    if(tmp6<t_chidat_to_dtrreq_min)    t_chidat_to_dtrreq_min    = tmp6;
    if(tmp7<t_chirsp_to_snprsp_min)    t_chirsp_to_snprsp_min    = tmp7;

    
    if($isunknown(tmp0)) is_chicmd_to_smicmdreq_min_unknown = 1;
    else is_chicmd_to_smicmdreq_min_unknown = 0;
    if($isunknown(tmp1)) is_chirsp_to_smicmdrsp_min_unknown = 1;
    else is_chirsp_to_smicmdrsp_min_unknown = 0;
    if($isunknown(tmp2)) is_chiwdat_to_smidat_min_unknown   = 1;
    else is_chiwdat_to_smidat_min_unknown = 0;
    if($isunknown(tmp3)) is_smisnp_to_chisnp_min_unknown    = 1;
    else is_smisnp_to_chisnp_min_unknown = 0;
    if($isunknown(tmp4)) is_smirsp_to_chirsp_min_unknown    = 1;
    else is_smirsp_to_chirsp_min_unknown = 0;
    if($isunknown(tmp5)) is_smidat_to_chirdat_min_unknown   = 1;
    else is_smidat_to_chirdat_min_unknown = 0;
                       
                       
    if($isunknown(tmp6)) is_chidat_to_dtrreq_min_unknown    = 1;
    else is_chidat_to_dtrreq_min_unknown = 0;
    if($isunknown(tmp7)) is_chirsp_to_snprsp_min_unknown    = 1;
    else is_chirsp_to_snprsp_min_unknown = 0;

    if(this.get_report_verbosity_level() > UVM_LOW) begin
        spkt = {"Deleting below OTT entry"};
        `uvm_info(`LABEL, $sformatf(spkt), UVM_NONE);
        print_me(index);
    end
    if(this.get_report_verbosity_level() > UVM_HIGH) begin
        `uvm_info(`LABEL, $sformatf("Remaining OTT entries are:"), UVM_NONE);
        print_ott_info();
    end
    `ifndef FSYS_COVER_ON
        cov.collect_ott_entry(m_ott_q[index]);
    `elsif CHI_SUBSYS_COVER_ON
        cov.collect_ott_entry(m_ott_q[index]);
    `endif
    //sb_stall_if.perf_count_events["Active_OTT_entries"].push_back(m_ott_q.size());
    //#Check.CHIAIU.v3.4.Connectivity.ChiHandshake
    //#Check.CHI.v3.7.MaxSttEntries
    if (m_ott_q[index].m_chi_req_pkt != null) ->evt_del_ott;
    if (m_ott_q[index].is_stash_snoop) begin
        outstanding_stsh_snoops--;
    end
    m_ott_q.delete(index);
    if (en_sb_objections) ->e_queue_change;
    
    <% if(obj.testBench == "fsys") { %>
    if($test$plusargs("chiaiu_zero_credit") && m_ott_q.size() == 0) begin
    	kill_chiaiu_uncorr_test.trigger(null);
	return;          
    end
    <% } %>
endfunction

function void chi_aiu_scb::print_me(int idx=0);
    string msg;
    $sformat(msg, "\nPKT#%0d: %0s",
                        m_ott_q[idx].chi_aiu_uid,
                        (m_ott_q[idx].m_chi_req_pkt != null) ? m_ott_q[idx].m_chi_req_pkt.convert2string() : m_ott_q[idx].m_snp_req_pkt.convert2string());

    if (m_ott_q[idx].dbid_val)
        $sformat(msg, "%s, DBID: 0x%0h",msg, m_ott_q[idx].dbid);

    if (m_ott_q[idx].m_str_req_pkt !== null)
            $sformat(msg, "%s, RBID: 0x%0h",msg, m_ott_q[idx].m_str_req_pkt.smi_rbid);

    if (m_ott_q[idx].snp_generated)
        $sformat(msg, "CHIAIU_UID:%0d : %s SNOOP was generated becasue of snoopme", m_ott_q[idx].snp_chi_aiu_uid, msg);

    $sformat(msg, "%s\nSMI pkts expected: ", msg);

    if (m_ott_q[idx].smi_exp[`CMD_REQ_OUT])
        $sformat(msg, "%s CMD_REQ",msg);
    if (m_ott_q[idx].smi_exp[`CMD_RSP_IN])
        $sformat(msg, "%s, CMD_RSP",msg);
    if (m_ott_q[idx].smi_exp[`STR_REQ_IN])
        $sformat(msg, "%s, STR_REQ",msg);
    if (m_ott_q[idx].smi_exp[`STR_RSP_OUT])
        $sformat(msg, "%s, STR_RSP",msg);
    if (m_ott_q[idx].smi_exp[`DTR_REQ_IN])
        $sformat(msg, "%s, DTR_REQ",msg);
    if (m_ott_q[idx].smi_exp[`DTR_RSP_OUT])
        $sformat(msg, "%s, DTR_RSP",msg);
    if (m_ott_q[idx].smi_exp[`DTW_REQ_OUT])
        $sformat(msg, "%s, DTW_REQ",msg);
    if (m_ott_q[idx].smi_exp[`DTW_RSP_IN])
        $sformat(msg, "%s, DTW_RSP",msg);
    if (m_ott_q[idx].smi_exp[`SNP_DTW_REQ_OUT])
        $sformat(msg, "%s, SNP_DTW_REQ",msg);
    if (m_ott_q[idx].smi_exp[`SNP_DTW_RSP_IN])
        $sformat(msg, "%s, SNP_DTW_RSP",msg);
    if (m_ott_q[idx].smi_exp[`SNP_RSP_OUT])
        $sformat(msg, "%s, SNP_RSP",msg);
    if (m_ott_q[idx].smi_exp[`SNP_DTR_REQ])
        $sformat(msg, "%s, SNP_DTR",msg);
    if (m_ott_q[idx].smi_exp[`SNP_DTR_RSP])
        $sformat(msg, "%s, SNP_DTR_RSP",msg);
    if (m_ott_q[idx].smi_exp[`CMP_RSP_IN])
        $sformat(msg, "%s, CMP_RSP_IN",msg);

    $sformat(msg, "%s\nCHI flits expected: ", msg);

    if (m_ott_q[idx].chi_exp[`WRITE_DATA_IN])
        $sformat(msg, "%s WRITEDATA",msg);
    if (m_ott_q[idx].chi_exp[`CHI_CRESP])
        $sformat(msg, "%s, CRESP",msg);
    if (m_ott_q[idx].chi_exp[`CHI_SRESP])
        $sformat(msg, "%s, SRESP",msg);
    if (m_ott_q[idx].chi_exp[`COMP_DATA_OUT])
        $sformat(msg, "%s, COMPDATA",msg);
    if (m_ott_q[idx].chi_exp[`CHI_SNP_REQ])
        $sformat(msg, "%s, SNP_REQ",msg);

    $sformat(msg, "%s\nSMI pkts received: ", msg);

    if (m_ott_q[idx].smi_rcvd[`CMD_REQ_OUT])
        $sformat(msg, "%s CMD_REQ",msg);
    if (m_ott_q[idx].smi_rcvd[`CMD_RSP_IN])
        $sformat(msg, "%s, CMD_RSP",msg);
    if (m_ott_q[idx].smi_rcvd[`STR_REQ_IN])
        $sformat(msg, "%s, STR_REQ",msg);
    if (m_ott_q[idx].smi_rcvd[`STR_RSP_OUT])
        $sformat(msg, "%s, STR_RSP",msg);
    if (m_ott_q[idx].smi_rcvd[`DTR_REQ_IN])
        $sformat(msg, "%s, DTR_REQ",msg);
    if (m_ott_q[idx].smi_rcvd[`DTR_RSP_OUT])
        $sformat(msg, "%s, DTR_RSP",msg);
    if (m_ott_q[idx].smi_rcvd[`DTW_REQ_OUT])
        $sformat(msg, "%s, DTW_REQ",msg);
    if (m_ott_q[idx].smi_rcvd[`DTW_RSP_IN])
        $sformat(msg, "%s, DTW_RSP",msg);
    if (m_ott_q[idx].smi_rcvd[`SNP_DTW_REQ_OUT])
        $sformat(msg, "%s, SNP_DTW_REQ",msg);
    if (m_ott_q[idx].smi_rcvd[`SNP_DTW_RSP_IN])
        $sformat(msg, "%s, SNP_DTW_RSP",msg);
    if (m_ott_q[idx].smi_rcvd[`SNP_RSP_OUT])
        $sformat(msg, "%s, SNP_RSP",msg);
    if (m_ott_q[idx].smi_rcvd[`SNP_DTR_REQ])
        $sformat(msg, "%s, SNP_DTR",msg);
    if (m_ott_q[idx].smi_rcvd[`SNP_DTR_RSP])
        $sformat(msg, "%s, SNP_DTR_RSP",msg);
    if (m_ott_q[idx].smi_rcvd[`CMP_RSP_IN])
        $sformat(msg, "%s, CMP_RSP_IN",msg);


    $sformat(msg, "%s\nCHI flits received: ", msg);

    if (m_ott_q[idx].chi_rcvd[`WRITE_DATA_IN])
        $sformat(msg, "%s WRITEDATA",msg);
    if (m_ott_q[idx].chi_rcvd[`CHI_CRESP])
        $sformat(msg, "%s, CRESP",msg);
    if (m_ott_q[idx].chi_rcvd[`CHI_SRESP])
        $sformat(msg, "%s, SRESP",msg);
    if (m_ott_q[idx].chi_rcvd[`COMP_DATA_OUT])
        $sformat(msg, "%s, COMPDATA",msg);
    if (m_ott_q[idx].chi_rcvd[`CHI_SNP_REQ])
        $sformat(msg, "%s, SNP_REQ",msg);

    `uvm_info(`LABEL, $psprintf("%0s",msg), UVM_NONE);
endfunction

function void chi_aiu_scb::print_ott_info();
    string msg;
    int    find_q[$];

    foreach(m_ott_q[idx]) begin
        find_q.delete();
        $sformat(msg, "\nPKT#%0d: %0s",
                        m_ott_q[idx].chi_aiu_uid,
                        (m_ott_q[idx].m_chi_req_pkt != null) ? m_ott_q[idx].m_chi_req_pkt.convert2string() : m_ott_q[idx].m_snp_req_pkt.convert2string());

        if (m_ott_q[idx].dbid_val)
            $sformat(msg, "%s, DBID: 0x%0h",msg, m_ott_q[idx].dbid);
        if (m_ott_q[idx].m_str_req_pkt !== null)
            $sformat(msg, "%s, RBID: 0x%0h",msg, m_ott_q[idx].m_str_req_pkt.smi_rbid);
        if (m_ott_q[idx].exp_dtw_req_pkt !== null)
        $sformat(msg, "%s, DTW's targ_ncore_unit_id: 0x%0h",msg, m_ott_q[idx].exp_dtw_req_pkt.smi_targ_ncore_unit_id);

        if (m_ott_q[idx].snp_generated)
            $sformat(msg, "CHIAIU_UID:%0d : %s SNOOP was generated because of snoopme", m_ott_q[idx].snp_chi_aiu_uid, msg);

        $sformat(msg, "%s\nSMI pkts expected: ", msg);
        if (m_ott_q[idx].smi_exp[`CMD_REQ_OUT])
            $sformat(msg, "%s CMD_REQ",msg);
        if (m_ott_q[idx].smi_exp[`CMD_RSP_IN])
            $sformat(msg, "%s, CMD_RSP",msg);
        if (m_ott_q[idx].smi_exp[`STR_REQ_IN])
            $sformat(msg, "%s, STR_REQ",msg);
        if (m_ott_q[idx].smi_exp[`STR_RSP_OUT])
            $sformat(msg, "%s, STR_RSP",msg);
        if (m_ott_q[idx].smi_exp[`DTR_REQ_IN])
            $sformat(msg, "%s, DTR_REQ",msg);
        if (m_ott_q[idx].smi_exp[`DTR_RSP_OUT])
            $sformat(msg, "%s, DTR_RSP",msg);
        if (m_ott_q[idx].smi_exp[`DTW_REQ_OUT])
            $sformat(msg, "%s, DTW_REQ",msg);
        if (m_ott_q[idx].smi_exp[`DTW_RSP_IN])
            $sformat(msg, "%s, DTW_RSP",msg);
        if (m_ott_q[idx].smi_exp[`SNP_DTW_REQ_OUT])
            $sformat(msg, "%s, SNP_DTW_REQ",msg);
        if (m_ott_q[idx].smi_exp[`SNP_DTW_RSP_IN])
            $sformat(msg, "%s, SNP_DTW_RSP",msg);
        if (m_ott_q[idx].smi_exp[`SNP_RSP_OUT])
            $sformat(msg, "%s, SNP_RSP",msg);
        if (m_ott_q[idx].smi_exp[`SNP_DTR_REQ])
            $sformat(msg, "%s, SNP_DTR",msg);
        if (m_ott_q[idx].smi_exp[`SNP_DTR_RSP])
            $sformat(msg, "%s, SNP_DTR_RSP",msg);
    if (m_ott_q[idx].smi_exp[`CMP_RSP_IN])
        $sformat(msg, "%s, CMP_RSP_IN",msg);

        $sformat(msg, "%s\nCHI flits expected: ", msg);

        if (m_ott_q[idx].chi_exp[`WRITE_DATA_IN])
            $sformat(msg, "%s WRITEDATA",msg);
        if (m_ott_q[idx].chi_exp[`CHI_CRESP])
            $sformat(msg, "%s, CRESP(%0h)",msg, m_ott_q[idx].exp_chi_crsp_pkt.opcode.name);
        if (m_ott_q[idx].chi_exp[`CHI_SRESP])
            $sformat(msg, "%s, SRESP",msg);
        if (m_ott_q[idx].chi_exp[`COMP_DATA_OUT])
            $sformat(msg, "%s, COMPDATA",msg);
        if (m_ott_q[idx].chi_exp[`CHI_SNP_REQ])
            $sformat(msg, "%s, SNP_REQ",msg);

        $sformat(msg, "%s\nSMI pkts received: ", msg);

        if (m_ott_q[idx].smi_rcvd[`CMD_REQ_OUT])
            $sformat(msg, "%s CMD_REQ",msg);
        if (m_ott_q[idx].smi_rcvd[`CMD_RSP_IN])
            $sformat(msg, "%s, CMD_RSP",msg);
        if (m_ott_q[idx].smi_rcvd[`STR_REQ_IN])
            $sformat(msg, "%s, STR_REQ",msg);
        if (m_ott_q[idx].smi_rcvd[`STR_RSP_OUT])
            $sformat(msg, "%s, STR_RSP",msg);
        if (m_ott_q[idx].smi_rcvd[`DTR_REQ_IN])
            $sformat(msg, "%s, DTR_REQ",msg);
        if (m_ott_q[idx].smi_rcvd[`DTR_RSP_OUT])
            $sformat(msg, "%s, DTR_RSP",msg);
        if (m_ott_q[idx].smi_rcvd[`DTW_REQ_OUT])
            $sformat(msg, "%s, DTW_REQ",msg);
        if (m_ott_q[idx].smi_rcvd[`DTW_RSP_IN])
            $sformat(msg, "%s, DTW_RSP",msg);
        if (m_ott_q[idx].smi_rcvd[`SNP_DTW_REQ_OUT])
            $sformat(msg, "%s, SNP_DTW_REQ",msg);
        if (m_ott_q[idx].smi_rcvd[`SNP_DTW_RSP_IN])
            $sformat(msg, "%s, SNP_DTW_RSP",msg);
        if (m_ott_q[idx].smi_rcvd[`SNP_RSP_OUT])
            $sformat(msg, "%s, SNP_RSP",msg);
        if (m_ott_q[idx].smi_rcvd[`SNP_DTR_REQ])
            $sformat(msg, "%s, SNP_DTR",msg);
        if (m_ott_q[idx].smi_rcvd[`SNP_DTR_RSP])
            $sformat(msg, "%s, SNP_DTR_RSP",msg);
        if (m_ott_q[idx].smi_rcvd[`CMP_RSP_IN])
            $sformat(msg, "%s, CMP_RSP_IN",msg);


        $sformat(msg, "%s\nCHI flits received: ", msg);

        if (m_ott_q[idx].chi_rcvd[`WRITE_DATA_IN])
            $sformat(msg, "%s WRITEDATA",msg);
        if (m_ott_q[idx].chi_rcvd[`CHI_CRESP])
            $sformat(msg, "%s, CRESP",msg);
        if (m_ott_q[idx].chi_rcvd[`CHI_SRESP])
            $sformat(msg, "%s, SRESP",msg);
        if (m_ott_q[idx].chi_rcvd[`COMP_DATA_OUT])
            $sformat(msg, "%s, COMPDATA",msg);
        if (m_ott_q[idx].chi_rcvd[`CHI_SNP_REQ])
            $sformat(msg, "%s, SNP_REQ",msg);


        if (m_ott_q[idx].snp_generated == 1) begin
            find_q = m_ott_q.find_index with(item.chi_aiu_uid == m_ott_q[idx].snp_chi_aiu_uid);
            if (find_q.size() == 1)
                $sformat(msg, "%s \nSnoop message info:",msg);
        end
        `uvm_info(`LABEL, $psprintf("%0s",msg), UVM_NONE);
        if (find_q.size() == 1)
            print_me(find_q[0]);
    end
    print_sysco_q;
endfunction : print_ott_info

////////////////////////////////////////////////////////////////////////////////
// Section6: Q-Channle Write function
//
//
////////////////////////////////////////////////////////////////////////////////


//******************************************************************************
// Function : write_q_chnl_port
// Purpose  : Main Function for Q-Channel Interface.
//
//
// list of q-channel checks apart from the protocol checks
// 1. If power_down request has been accepted, at that time no outstanding transaction should be there
// 2. QACTIVE/transActv should not be low if there is any transaction pending in CHI
// 3. Power_down request should be accepted if no outstanding transaction is in the CHI
//******************************************************************************
function void chi_aiu_scb::write_q_chnl_port (q_chnl_seq_item m_pkt);
  q_chnl_seq_item m_packet;
  q_chnl_seq_item m_packet_tmp;
  chi_aiu_scb_txn     txn;

  m_packet = new();

  $cast(m_packet_tmp, m_pkt);
  m_packet.copy(m_packet_tmp);

  `uvm_info("Q_Channel_resp_chnl", $sformatf("Entered..."), UVM_HIGH)
  //If power_down request has been accepted, at that time no outstanding transaction should be there
  if(m_packet.QACCEPTn == 'b0 && m_packet.QREQn == 'b0  && m_packet.QACTIVE == 'b0) begin
    `uvm_info("Q_Channel_resp_chnl", $sformatf("Q_Channel : Checking WTT and RTT Queue should be empty when Q Channel Req receives Accept."), UVM_HIGH)
    if (m_ott_q.size != 0) begin
      `uvm_error("<%=obj.BlockId%>:print_m_ott_q", $sformatf("Command queue is not empty when rtl asserted QACCEPTn"))
    end
    else begin
      `uvm_info("<%=obj.BlockId%>:print_m_ott_q", $sformatf("Command queue is empty"), UVM_MEDIUM)
    end
  end

endfunction


function void chi_aiu_scb::check_phase(uvm_phase phase);
    int print_trans = 10;
    int inj_cntl;
    int timeout_uc_err;
    bit targ_id_err;
    bit perfmon_smi_stall ;
    
    $value$plusargs("inj_cntl=%d",inj_cntl);
    uvm_config_db#(int)::get(null,"*","timeout_uc_err",timeout_uc_err);
    uvm_config_db#(bit)::get(null,"*","perfmon_smi_stall",perfmon_smi_stall);
    if($test$plusargs("wrong_cmdrsp_target_id") || $test$plusargs("wrong_dtwrsp_target_id") || $test$plusargs("wrong_dtrrsp_target_id") || $test$plusargs("wrong_snpreq_target_id") || $test$plusargs("wrong_dtrreq_target_id") || $test$plusargs("wrong_strreq_target_id") || ($test$plusargs("wrong_sysrsp_target_id") && ($test$plusargs("check4_attach") || $test$plusargs("check4_detach"))) || $test$plusargs("wrong_DtwDbg_rsp_target_id") || $test$plusargs("wrong_sysreq_target_id")) begin
    	targ_id_err = 1'b1;
    end

    `ifndef FSYS_COVER_ON
	cov.collect_stasting_snoops();
    `elsif CHI_SUBSYS_COVER_ON
	cov.collect_stasting_snoops();
    `endif
    `uvm_info(`LABEL, $psprintf("Total number of transactions in this run: %0d. Num of pending transactions: %0d", chi_aiu_uid - {m_req_aiu_id[7:0], 24'd0}, m_ott_q.size()), UVM_NONE)
    if ($test$plusargs("check_error_test_pending_txn")) begin
      if (m_ott_q.size() == 0) begin
        print_ott_info();
        `uvm_error(`LABEL_ERROR, $psprintf("ott_q size is zero at the end of the test")) 
      end else begin
        `uvm_info(`LABEL,"ott_q has below pending transaction at the end of error test",UVM_NONE)
        print_ott_info();
      end
    end else if (!$test$plusargs("check_error_test_pending_txn") && !$test$plusargs("wrong_sysrsp_target_id") && m_ott_q.size() !== 0) begin
      print_ott_info();
      `uvm_error(`LABEL_ERROR, $psprintf("Scoreboard still has pending transactions at the end of the test"))

      <%if (obj.testBench != "fsys" && obj.testBench != "emu") { %>
      if (u_dut_probe_vif.ott_entry_validvec != 'h0) begin
        `uvm_error(`LABEL_ERROR, $psprintf("DUT not all ott entry_valid is 0 at the end of the test"))
      end

      if (u_dut_probe_vif.stt_entry_validvec != 'h0) begin
        `uvm_error(`LABEL_ERROR, $psprintf("DUT not all stt entry_valid is 0 at the end of the test"))
      end
      <% } %>
    end // if Q not empty
    print_sysco_q;
    if((m_sysco_q.size() !== 0) && (!$test$plusargs("wrong_sysrsp_target_id")))
      `uvm_error(`LABEL_ERROR, $psprintf("Scoreboard still has pending SYS transactions at the end of the test."))

   //#Check.CHIAIU.v3.4.SCM.StartEndOfSim
   //Add checks for End of simulation SCM credit checks.

   if ($test$plusargs("en_cmd_to_cmdreq_latency_chk") && !is_chicmd_to_smicmdreq_min_unknown) begin
         chicmd_to_smicmdreq_min_t = int'(t_chicmd_to_smicmdreq_min/<%=obj.Clocks[0].params.period%>);
    //if ((t_chicmd_to_smicmdreq_min/<%=obj.Clocks[0].params.period%>) != (cmd_to_cmdreq_latency)) begin
      if ((chicmd_to_smicmdreq_min_t) != (cmd_to_cmdreq_latency)) begin
          `uvm_error(`LABEL_ERROR, $psprintf("cmd to cmdreq latency not matching %0h %0h",t_chicmd_to_smicmdreq_min/<%=obj.Clocks[0].params.period%>, cmd_to_cmdreq_latency))
      end
   end


   if ($test$plusargs("en_chi_data_to_dtwreq_latency_chk") && !is_chiwdat_to_smidat_min_unknown) begin
      chiwdat_to_smidat_min_t = int'(t_chiwdat_to_smidat_min/<%=obj.Clocks[0].params.period%>);
    //if ((t_chiwdat_to_smidat_min/<%=obj.Clocks[0].params.period%>) != (chi_data_to_dtwreq_latency)) begin
      if ((chiwdat_to_smidat_min_t) != (chi_data_to_dtwreq_latency)) begin
          `uvm_error(`LABEL_ERROR, $psprintf("chi data to dtwreq latency not matching %0h %0h", t_chiwdat_to_smidat_min/<%=obj.Clocks[0].params.period%>, chi_data_to_dtwreq_latency))
      end
   end

   if ($test$plusargs("en_dtrreq_to_chi_data_latency_chk") && !is_smidat_to_chirdat_min_unknown) begin
      smidat_to_chirdat_min_t = int'(t_smidat_to_chirdat_min/<%=obj.Clocks[0].params.period%>); 
    //if ((t_smidat_to_chirdat_min/<%=obj.Clocks[0].params.period%>) != (dtrreq_to_chi_data_latency)) begin
      if ((smidat_to_chirdat_min_t) != (dtrreq_to_chi_data_latency)) begin
          `uvm_error(`LABEL_ERROR, $psprintf("dtrreq to chi data latency not matching %0h %0h", t_smidat_to_chirdat_min/<%=obj.Clocks[0].params.period%>, dtrreq_to_chi_data_latency))
      end
   end


   if ($test$plusargs("en_snpreq_to_chi_snoop_latency_chk") && !is_smisnp_to_chisnp_min_unknown) begin
      smisnp_to_chisnp_min_t = int'(t_smisnp_to_chisnp_min/<%=obj.Clocks[0].params.period%>);
    //if ((t_smisnp_to_chisnp_min/<%=obj.Clocks[0].params.period%>) != (snpreq_to_chi_snoop_latency)) begin
      if ((smisnp_to_chisnp_min_t) != (snpreq_to_chi_snoop_latency)) begin
          `uvm_error(`LABEL_ERROR, $psprintf("snpreq to chi snoop latency not matching %0h %0h", t_smisnp_to_chisnp_min/<%=obj.Clocks[0].params.period%>, snpreq_to_chi_snoop_latency))
      end
   end

   if ($test$plusargs("en_strreq_to_chi_rsp_latency_chk") && !is_smirsp_to_chirsp_min_unknown) begin
      smirsp_to_chirsp_min_t = int'(t_smirsp_to_chirsp_min/<%=obj.Clocks[0].params.period%>);
    //if ((t_smirsp_to_chirsp_min/<%=obj.Clocks[0].params.period%>) != (strreq_to_chi_rsp_latency)) begin
      if ((smirsp_to_chirsp_min_t) != (strreq_to_chi_rsp_latency)) begin
          `uvm_error(`LABEL_ERROR, $psprintf("strreq to chi rsp latency not matching %0h %0h", t_smirsp_to_chirsp_min/<%=obj.Clocks[0].params.period%>, strreq_to_chi_rsp_latency))
      end
   end

   if ($test$plusargs("en_chi_data_to_dtrReq_latency_chk") && !is_chidat_to_dtrreq_min_unknown) begin
      chidat_to_dtrreq_min_t = int'(t_chidat_to_dtrreq_min/<%=obj.Clocks[0].params.period%>);
    //if ((t_chidat_to_dtrreq_min/<%=obj.Clocks[0].params.period%>) != (chi_data_to_dtrReq_latency)) begin
      if ((chidat_to_dtrreq_min_t) != (chi_data_to_dtrReq_latency)) begin
          `uvm_error(`LABEL_ERROR, $psprintf("chi data to dtrreq latency not matching %0h %0h", t_chidat_to_dtrreq_min/<%=obj.Clocks[0].params.period%>, chi_data_to_dtrReq_latency))
      end
   end

   if ($test$plusargs("en_chi_rsp_to_snprsp_latency_chk") && !is_chirsp_to_snprsp_min_unknown) begin
      chirsp_to_snprsp_min_t = int'(t_chirsp_to_snprsp_min/<%=obj.Clocks[0].params.period%>); 
    //if ((t_chirsp_to_snprsp_min/<%=obj.Clocks[0].params.period%>) != (chi_rsp_to_snprsp_latency)) begin
      if ((chirsp_to_snprsp_min_t) != (chi_rsp_to_snprsp_latency)) begin
          `uvm_error(`LABEL_ERROR, $psprintf("chi rsp to snp rsp latency not matching %0h %0h", t_chirsp_to_snprsp_min/<%=obj.Clocks[0].params.period%>, chi_rsp_to_snprsp_latency))
      end
   end

<%  if (obj.useResiliency && obj.testBench != "fsys" && obj.testBench != "emu") { %>
  if (!(inj_cntl > 1) && !(targ_id_err) && (timeout_uc_err == 0) && num_smi_uncorr_err == 0 && num_smi_parity_err == 0 && !($test$plusargs("uncorr_error_inj_pcnt") || $test$plusargs("parity_error_inj_pcnt") || $test$plusargs("test_unit_duplication")) && (perfmon_smi_stall)) begin
    if (u_csr_probe_vif.fault_mission_fault !== 0) begin
      `uvm_error(get_full_name(),"mission fault should be zero at the end of the test for no error injection")
    end
    if (u_csr_probe_vif.fault_latent_fault !== 0) begin
      `uvm_error(get_full_name(),"latent fault should be zero at the end of the test for no error injection")
    end
  end
<% } %>

endfunction : check_phase

task chi_aiu_scb::run_phase(uvm_phase phase);
    // perf minitor:Bound stall_if Interface
     if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_0_m_top_stall_if", sb_stall_if)) 
     begin
       `uvm_fatal("chi_aiu_scoreboard stall interface error", "virtual interface must be set for stall_if");
     end

    <%if (obj.testBench != "fsys" && obj.testBench != "emu") { %>
    if(!uvm_config_db#(virtual chi_aiu_dut_probe_if )::get(null, get_full_name(), "u_dut_probe_if",u_dut_probe_vif)) begin
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    end
    <% } %>

    <%  if (obj.useResiliency && obj.testBench != "fsys" && obj.testBench != "emu") { %>
    if(!uvm_config_db#(virtual chi_aiu_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif)) begin
       `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    end
    <% } %>

    //super.main_phase(phase); ?? why main_phase()?
   <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
   <% if(obj.testBench == "fsys") { %>
    if ($test$plusargs("en_chiaiu_coherency_via_reg")) begin
      fork
      begin
        process_csr_sysco();
      end
      join_none
    end  
   <% } %>
    csr_init_done.wait_trigger();
    if($test$plusargs("trace_trigger_en")) begin
        csr_trace_debug_done.wait_trigger();
        <% for(var i=0; i<obj.AiuInfo[obj.Id].nTraceRegisters; i++) {%>
        m_trace_trigger.TCTRLR_write_reg(<%=i%>,tctrlr[<%=i%>]);
        m_trace_trigger.TBALR_write_reg(<%=i%>,tbalr[<%=i%>]);
        m_trace_trigger.TBAHR_write_reg(<%=i%>,tbahr[<%=i%>]);
        m_trace_trigger.TOPCR0_write_reg(<%=i%>,topcr0[<%=i%>]);
        m_trace_trigger.TOPCR1_write_reg(<%=i%>,topcr1[<%=i%>]);
        m_trace_trigger.TUBR_write_reg(<%=i%>,tubr[<%=i%>]);
        m_trace_trigger.TUBMR_write_reg(<%=i%>,tubmr[<%=i%>]);
        <%}%>
        m_trace_trigger.print_trigger_sets_reg_values();
    end
    start_sb = 1;
    <%}%>
    objection = phase.get_objection();
    fork
        `ifndef FSYS_COVER_ON
        cov.collect_irq_uc();
    <%if (obj.useResiliency){%>
        cov.cerr_threshold();
    <%}%>
    <%if (obj.DutInfo.interfaces.chiInt.params.checkType !== "NONE") {%>
        cov.ip_error_cov();
    <% } %>
        cov.collect_crd_state();
        cov.collect_size_of_ig();
    	`elsif CHI_SUBSYS_COVER_ON
        cov.collect_irq_uc();
    <%if (obj.useResiliency){%>
        cov.cerr_threshold();
    <%}%>
    <%if (obj.DutInfo.interfaces.chiInt.params.checkType !== "NONE") {%>
        cov.ip_error_cov();
    <% } %>
        cov.collect_crd_state();
        cov.collect_size_of_ig();
        `endif
    join_none

   /* begin //RAL mirrored value
      #3200ns;
      if(m_regs == null) `uvm_info(get_type_name(),"Failed to get m_regs at scoreboard which is null",UVM_LOW)
      else begin
        my_register = m_regs.get_reg_by_name("CAIUUELR0");
        mirrored_value = my_register.get_mirrored_value();
        `uvm_info(get_name(),$sformatf("Mirrored value in scoreboard is %0h",mirrored_value),UVM_LOW)
      end
    end */

    fork
        begin
            forever begin
                int count;
                @(e_queue_change);
                //sb_stall_if.perf_count_events["Active_OTT_entries"].push_back(m_ott_q.size());
                count = objection.get_objection_count(this);
                `uvm_info(`LABEL, $psprintf("Raising/dropping objection: raised obj count: %0d, Q size: %0d", count, (m_ott_q.size() + m_sysco_q.size())), UVM_MEDIUM)
                if ((m_ott_q.size() + m_sysco_q.size()) !== 0) begin
                    phase.raise_objection(this, "Raise objection in run_phase.", (m_ott_q.size() + m_sysco_q.size()));
                end
                phase.drop_objection(this, "Droping objections in run_phase.", count);
            end // forever
        end //fork
	    begin
            forever begin
		        int count;
                @(e_queue_change);
    		    if(m_ott_q.size() == 0) begin
		            #500ns;
		            if(m_ott_q.size() == 0) begin
    		    	    //kill_coherency_test.trigger(null);
    		    	    all_txn_done_ev.trigger(null);
		            end       
    		    end
            end // forever
        end //fork
        begin
            forever begin
                csr_trace_debug_done.wait_trigger();
                <% for(var i=0; i<obj.AiuInfo[obj.Id].nTraceRegisters; i++) {%>
                m_trace_trigger.TCTRLR_write_reg(<%=i%>,tctrlr[<%=i%>]);
                m_trace_trigger.TBALR_write_reg(<%=i%>,tbalr[<%=i%>]);
                m_trace_trigger.TBAHR_write_reg(<%=i%>,tbahr[<%=i%>]);
                m_trace_trigger.TOPCR0_write_reg(<%=i%>,topcr0[<%=i%>]);
                m_trace_trigger.TOPCR1_write_reg(<%=i%>,topcr1[<%=i%>]);
                m_trace_trigger.TUBR_write_reg(<%=i%>,tubr[<%=i%>]);
                m_trace_trigger.TUBMR_write_reg(<%=i%>,tubmr[<%=i%>]);
                <%}%>
                m_trace_trigger.print_trigger_sets_reg_values();
            end // forever
        end //fork
        // BEGIN PERF MONITOR
        begin
          forever begin:updateskidott
             @(evt_ott);
             if (real_ott_size < max_ott) begin
                   real_ott_size++;
                   sb_stall_if.perf_count_events["Active_OTT_entries"].push_back(real_ott_size);
             end else begin
                   ott_skid_size++;
             end
          end:updateskidott
         end
         begin
          forever begin:updateott
             @(evt_del_ott);
              if (real_ott_size) begin
                real_ott_size--;
                sb_stall_if.perf_count_events["Active_OTT_entries"].push_back(real_ott_size);
              end
              if (ott_skid_size) begin
                   ott_skid_size--;
                   real_ott_size++;
                   sb_stall_if.perf_count_events["Active_OTT_entries"].push_back(real_ott_size);
              end
          end:updateott
         end
    	<%if(obj.AiuInfo[obj.Id].cmpInfo.nSnpInFlight + obj.AiuInfo[obj.Id].cmpInfo.nDvmSnpInFlight - 1 > 128) {%>
	begin
          forever begin
             @(u_dut_probe_vif.stt_entry_validvec);
             cov.collect_larger_stt_info(u_dut_probe_vif.stt_entry_validvec, u_dut_probe_vif.stt_skid_buffer_full);
          end
	end
    	<%}%>
        <%if (obj.testBench != "fsys") { %>
        begin
            forever begin
                @(posedge u_dut_probe_vif.starv_mode)
                qos_starv_count++;
                sb_stall_if.perf_count_events["Number_of_QoS_Starvations"].push_back(1);
            end
        end
        <% } %>
    join_none
   <% if(obj.testBench == "fsys") { %>
    if (!$test$plusargs("en_chiaiu_coherency_via_reg")) begin
        process_csr_sysco();
    end  
   <% } else { %>
        process_csr_sysco();
   <% } %>
endtask : run_phase

function void chi_aiu_scb::report_phase(uvm_phase phase);

`uvm_info(get_full_name(), $sformatf("chi cmd to concerto request min latency: %d cycle", t_chicmd_to_smicmdreq_min/<%=obj.Clocks[0].params.period%>), UVM_LOW)
`uvm_info(get_full_name(), $sformatf("chi rsp to concerto rsp min latency: %d cycle", t_chirsp_to_smicmdrsp_min/<%=obj.Clocks[0].params.period%>), UVM_LOW)
`uvm_info(get_full_name(), $sformatf("chi wdata to concerto wdata min latency: %d cycle", t_chiwdat_to_smidat_min/<%=obj.Clocks[0].params.period%> ), UVM_LOW)
`uvm_info(get_full_name(), $sformatf("concerto snoop to chi snoop min latency: %d cycle", t_smisnp_to_chisnp_min/<%=obj.Clocks[0].params.period%>), UVM_LOW)
`uvm_info(get_full_name(), $sformatf("concerto rsp to chi rsp min latency: %d cycle", t_smirsp_to_chirsp_min/<%=obj.Clocks[0].params.period%>), UVM_LOW)
`uvm_info(get_full_name(), $sformatf("concerto rdata to chi rdata min latency: %d cycle", t_smidat_to_chirdat_min/<%=obj.Clocks[0].params.period%>), UVM_LOW)
`uvm_info(get_full_name(), $sformatf("concerto chi data to rdata min latency: %d cycle", t_chidat_to_dtrreq_min/<%=obj.Clocks[0].params.period%>), UVM_LOW)
`uvm_info(get_full_name(), $sformatf("concerto chi rsp to snp rsp min latency: %d cycle", t_chirsp_to_snprsp_min/<%=obj.Clocks[0].params.period%>), UVM_LOW)

if ($test$plusargs("perf_test")) begin
    `uvm_info(get_full_name(), $sformatf("CHI BW calculation summary:"), UVM_NONE)
    `uvm_info(get_full_name(), $sformatf("CHI BW data per flit                      =  %0d bytes ", WDATA/8), UVM_NONE)
    `uvm_info(get_full_name(), $sformatf("CHI BW rd_total_flits                     =  %0d ", rd_total_flits), UVM_LOW)
    `uvm_info(get_full_name(), $sformatf("CHI BW bw_start_time (first req)          =  %.2f ns", t_bw_start_time/1000), UVM_LOW)
    `uvm_info(get_full_name(), $sformatf("CHI BW rd_bw_start_time                   =  %.2f ns", t_rd_bw_start_time/1000), UVM_LOW)
    `uvm_info(get_full_name(), $sformatf("CHI BW rd_bw_end_time                     =  %.2f ns", t_rd_bw_end_time/1000), UVM_LOW)
    `uvm_info(get_full_name(), $sformatf("CHI BW wr_total_flits                     =  %0d ", wr_total_flits), UVM_LOW)
    `uvm_info(get_full_name(), $sformatf("CHI BW wr_bw_start_time                   =  %.2f ns", t_wr_bw_start_time/1000), UVM_LOW)
    `uvm_info(get_full_name(), $sformatf("CHI BW wr_bw_end_time_wdata               =  %.2f ns", t_wr_bw_end_time_wdata/1000), UVM_LOW)
    `uvm_info(get_full_name(), $sformatf("CHI BW wr_bw_end_time_crsp                =  %.2f ns", t_wr_bw_end_time_crsp/1000), UVM_LOW)
    `uvm_info(get_full_name(), $sformatf("CHI BW Read                               =  %.2f GB/sec", (rd_total_flits * (WDATA/8))/((t_rd_bw_end_time - t_bw_start_time)/1000)), UVM_NONE)
    `uvm_info(get_full_name(), $sformatf("CHI BW Read (first rdata to last rdata)   =  %.2f GB/sec", (rd_total_flits * (WDATA/8))/((t_rd_bw_end_time - t_rd_bw_start_time)/1000)), UVM_LOW)
    `uvm_info(get_full_name(), $sformatf("CHI BW Write                              =  %.2f GB/sec", (wr_total_flits * (WDATA/8))/((t_wr_bw_end_time_wdata - t_bw_start_time)/1000)), UVM_NONE)
    `uvm_info(get_full_name(), $sformatf("CHI BW Write (first req to last crsp)     =  %.2f GB/s", (wr_total_flits * (WDATA/8))/((t_wr_bw_end_time_crsp - t_bw_start_time)/1000)), UVM_LOW)
    `uvm_info(get_full_name(), $sformatf("CHI BW Write (first wdata to last wdata)  =  %.2f GB/sec", (wr_total_flits * (WDATA/8))/((t_wr_bw_end_time_wdata - t_wr_bw_start_time)/1000)), UVM_LOW)
   `uvm_info(get_full_name(), $sformatf("CHI BW Write (first wdata to last crsp)   =  %.2f GB/s", (wr_total_flits * (WDATA/8))/((t_wr_bw_end_time_crsp - t_wr_bw_start_time)/1000)), UVM_LOW)

end
endfunction : report_phase

//******************************************************************************
function void chi_aiu_scb::update4sysco_snp_req(ref chi_aiu_scb_txn pkt, input bit is_chi_pkt=0, is_dvm_part2=0);
  bit transition;
  chi_sysco_state_t state = get_cur_sysco_state;
  pkt.set_get_sysco_state("set", state, transition, is_chi_pkt, is_dvm_part2);
endfunction : update4sysco_snp_req
//******************************************************************************
function chi_sysco_state_t chi_aiu_scb::get_cur_sysco_state();
  return this.m_sysco_st;
endfunction : get_cur_sysco_state
//******************************************************************************
function void chi_aiu_scb::update_snp_req_addr_q(const ref chi_aiu_scb_txn pkt, ref smi_addr_t snp_req_addr_q[$], input string name="");
  chi_snpaddr_t chi_snp_addr_tmp;
  int snp_req_addr_find_temp_q[$];

  for(int i=0; i<2; i++) begin
    if(i==0) begin
      snp_req_addr_find_temp_q = snp_req_addr_q.find_index with (item == pkt.m_snp_req_pkt.smi_addr);
    end else if (i==1) begin
      snp_req_addr_find_temp_q = snp_req_addr_q.find_index with (item == pkt.dvm_part2_smi_addr);
    end
    if(snp_req_addr_find_temp_q.size) begin
      chi_snp_addr_tmp = snp_req_addr_q[snp_req_addr_find_temp_q[0]];
      snp_req_addr_q.delete(snp_req_addr_find_temp_q[0]);
      `uvm_info(`LABEL, $psprintf("SMI_DVM_SNP dup %0d part with index(%0d) deleted from snp_req_addr_q(%0s) smi_dvm_snp_addr = 0x%0x, addr>>3=0x%0x as that snoope seems to be returned? smi_sysco_state=%0s, is_sysco_snp_returned=%0d", (i+1), snp_req_addr_find_temp_q[0], name, chi_snp_addr_tmp, chi_snp_addr_tmp>>3, pkt.smi_sysco_state, pkt.is_sysco_snp_returned), UVM_LOW)
    end
  end
endfunction : update_snp_req_addr_q
//******************************************************************************
function void chi_aiu_scb::process_csr_sysco();
    int               find_q[$];
    string            spkt;
    chi_aiu_scb_txn   m_scb_pkt;
    chi_base_seq_item m_pkt;
    uvm_object uvm_obj;
  <%if(obj.testBench == "fsys"){ %>
    if((start_sb && !$test$plusargs("en_chiaiu_coherency_via_reg")) || ($test$plusargs("en_chiaiu_coherency_via_reg")))begin
  <%}%>
    fork
      begin : sysco_csr_request
        forever begin
          #1 ev_csr_sysco_<%=obj.BlockId%>.wait_ptrigger_data(uvm_obj);
          $cast(m_pkt, uvm_obj);
          `uvm_info(`LABEL, $psprintf("Received a CSR sysco packet with req: 0x%0h. ack:0x%0h.", m_pkt.sysco_req, m_pkt.sysco_ack), UVM_LOW)
          setup_x_sysco_pkt(m_pkt, 0);
          <% if(obj.testBench != "fsys"){ %>
          if (en_sb_objections) ->e_queue_change;
          <% } %>
        end
      end
      begin : sysco_timeout
        forever begin
          chi_base_seq_item m_timeout_rtl_pkt;
          #1 ev_csr_test_time_out_SYSrsp.wait_ptrigger_data(uvm_obj);
          `uvm_info(`LABEL, $psprintf("Sysco timeout occured. state=%0s", get_cur_sysco_state), UVM_NONE)
          m_timeout_rtl_pkt = chi_base_seq_item::type_id::create("m_timeout_rtl_pkt");
          print_sysco_q;
          case(get_cur_sysco_state)
            CONNECT : begin
              // RTL will goto ATTACH_ERR state
              `uvm_info(`LABEL, $psprintf("DBG_1: Moving sysco request to timeout queue"), UVM_DEBUG)
              if(m_sysco_q.size) begin
                m_sysco_timeout_q.push_back(m_sysco_q.pop_front());
              end
              // RTL will generate DETACH request on it's own
              m_timeout_rtl_pkt.sysco_req = 0;
              m_timeout_rtl_pkt.sysco_ack = 1; // making ack ON for TB purpose only
              setup_x_sysco_pkt(m_timeout_rtl_pkt, 0);
            end
            DISCONNECT : begin
              // RTL will goto DETACH_ERR state
              `uvm_info(`LABEL, $psprintf("DBG_2: Moving sysco request to timeout queue"), UVM_DEBUG)
              if(m_sysco_q.size) begin
                m_sysco_timeout_q.push_back(m_sysco_q.pop_front());
              end
              m_sysco_st  = DISABLED;
            end
            ENABLED,
            DISABLED : begin
              `uvm_error(`LABEL_ERROR, $psprintf("During stable sysco state(%0s), timeout error occur", get_cur_sysco_state))
            end
            default : begin
              `uvm_warning(`LABEL, $psprintf("Unknown sysco state(%0d)", get_cur_sysco_state))
            end
          endcase
          <% if(obj.testBench != "fsys"){ %>
          if (en_sb_objections) ->e_queue_change;
          <% } %>
        end
      end
    join_none
  <%if(obj.testBench == "fsys"){ %>
    end
  <%}%>
endfunction : process_csr_sysco
//******************************************************************************
function void chi_aiu_scb::setup_x_sysco_pkt(const ref chi_base_seq_item m_pkt, input bit is_SyscoNintf = 1);
    int               find_q[$];
    string            spkt;
    chi_aiu_scb_txn   m_scb_pkt;
    bit               is_new;

    //find_q = m_sysco_q.find_index(item) with (
    //                item.m_chi_sysco_req_pkt != null
    //                item.chi_exp[`CHI_SYSCO_ACK] == 0
    //                && item.m_chi_sysco_req_pkt.sysco_req == m_pkt.sysco_req
    //                && item.m_chi_sysco_req_pkt.sysco_ack == m_pkt.sysco_ack
    //                );

    //if(find_q.size) begin
    if(m_sysco_q.size > 1) begin
      foreach(m_sysco_q[i]) begin
      <% if(obj.testBench == 'chi_aiu' || obj.testBench == "fsys") { %>
      `ifndef VCS
        $sprint(spkt, "%0s Pending request[%0d] is of sysco packet with m_sysco_st=%0d. time:0x%0t \n", spkt, i, m_sysco_q[i].m_sysco_st, m_sysco_q[i].t_chi_sysco_req_rcvd);
      `else // `ifndef VCS
        $psprintf(spkt, "%0s Pending request[%0d] is of sysco packet with m_sysco_st=%0d. time:0x%0t \n", spkt, i, m_sysco_q[i].m_sysco_st, m_sysco_q[i].t_chi_sysco_req_rcvd);
      `endif // `ifndef VCS ... `else ... 
      <% } else {%>
        $sprint(spkt, "%0s Pending request[%0d] is of sysco packet with m_sysco_st=%0d. time:0x%0t \n", spkt, i, m_sysco_q[i].m_sysco_st, m_sysco_q[i].t_chi_sysco_req_rcvd);
      <% } %>
      end
      `uvm_error(`LABEL_ERROR, $psprintf("Multiple(%0d) matches found. %0s", find_q.size, spkt))
    end else begin
      if(m_sysco_q.size == 0) begin
        m_scb_pkt = new(,m_sys_req_cnt++);
        is_new = 1;
      end else begin
        m_scb_pkt = m_sysco_q[0];
      end
      m_scb_pkt.setup_chi_sysco_pkt(m_pkt, is_SyscoNintf);
      m_sysco_st  = m_scb_pkt.m_sysco_st;

      //fill or delete
      if(is_new) begin
        if(m_sysco_st inside {CONNECT, DISCONNECT}) begin
          m_sysco_q.push_back(m_scb_pkt);
        end else begin
          `uvm_error(`LABEL_ERROR, $psprintf("Something went wrong in sampling? size=%0d", find_q.size))
        end
      end
      else if(m_sysco_st inside {DISABLED, ENABLED}) begin
        m_scb_pkt = m_sysco_q.pop_front();
        if(!m_scb_pkt.is_SyscoNintf)
          $sformat(spkt, "%0s m_sysco_st=%0s.\n", spkt, m_scb_pkt.m_sysco_st.name);
        else
          $sformat(spkt, "%0s m_sysco_st=%0s, pkt=%0s\n", spkt, m_scb_pkt.m_sysco_st.name, m_scb_pkt.m_chi_sysco_req_pkt.convert2string);
        `uvm_info(`LABEL, $psprintf("Deleting m_sysco_q entry, %0s. Queue size now is %0d, current sysco_req pkt cnt=%0d", spkt, m_sysco_q.size, m_sys_req_cnt), UVM_LOW)
      end
      else begin
        `uvm_error(`LABEL_ERROR, $psprintf("Undefined sysco_state = %0d.", m_sysco_st))
      end
    end
endfunction : setup_x_sysco_pkt

function void chi_aiu_scb::print_sysco_q();
  if (m_sysco_q.size() !== 0) begin
    string spkt;
    foreach(m_sysco_q[i]) begin
      if(!m_sysco_q[i].is_SyscoNintf)
        $sformat(spkt, "%0s pkt[%0d].m_sysco_st = %0s,\n\t chi_exp = %b\n\t smi_exp = %b\n", spkt, i, m_sysco_q[i].m_sysco_st.name, m_sysco_q[i].chi_exp, m_sysco_q[i].smi_exp);
      else
        $sformat(spkt, "%0s pkt[%0d] = %0s,\n\t chi_exp = %b\n\t smi_exp = %b\n", spkt, i, m_sysco_q[i].m_chi_sysco_req_pkt.convert2string, m_sysco_q[i].chi_exp, m_sysco_q[i].smi_exp);
    end
    `uvm_info(`LABEL, $psprintf("Scoreboard still has pending SYS transactions at the end of the test.\n %0s", spkt), UVM_NONE)
  end else begin
    `uvm_info(`LABEL, $psprintf("Total sysco requests at the current simulation time is %0d", m_sys_req_cnt), UVM_NONE)
  end
endfunction
