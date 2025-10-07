typedef struct{
	bit[1:0] sysreq_event_opcode;
	bit event_receiver_enable;
	bit sysreq_event;
	bit [7:0] cm_status;
	bit timeout_err_det_en;
	bit timeout_err_int_en;
	bit [3:0] uesr_err_type;
	bit err_valid;
	bit irq_uc;
	int timeout_threshold;
}sysreq_pkt_t;   // This is temporary - Can be deleted after sysreq events feature delivery
<%
//logicaId (CPU unit IDs ace L1 cache per CPU assumption)
let nLogicalIds = 0;
let logicalIds = [];
let selectBits = [];
let agentSelectBitValue = [];
let logicalId2AgentIdMap = [];
let wSelectBits = [];
let wEndpoint = [];
let agentsAxiAddr = [];
let agentsSfiAddr = [];
let maxAxiAddrWidth = 0;
let minAxiAddrWidth = 1024;
let maxAxiDataWidth = 0;
let minAxiDataWidth = 1024;
let agentInfType = [];
let stashEnable  = [];
let maxProcs       = [];

//Various agent ID's w.r.t bundles in configParams
let aiuIds = [];
let dceIds = [];
let dveIds = [];
let dmiIds = [];
let diiIds = [];
let aiuNIds = [];
let dceNIds = [];
let dveNIds = [];
let dmiNIds = [];
let diiNIds = [];
let dmiUseAtomic = [];//atomic feature in each DMIs
let stashNids = [];


obj.AiuInfo.forEach(function(bundle, indx) {
    aiuIds.push(indx);
    aiuNIds.push(bundle.nUnitId);
});

obj.DceInfo.forEach(function(bundle, indx) {
    dceIds.push(aiuIds.length + indx);
    dceNIds.push(bundle.nUnitId);
});

obj.DmiInfo.forEach(function(bundle, indx) {
    dmiIds.push(aiuIds.length + dceIds.length + indx);
    dmiNIds.push(bundle.nUnitId);
});

obj.DiiInfo.forEach(function(bundle, indx) {
   	 diiIds.push( aiuIds.length + dceIds.length + dmiIds.length + indx);
   	 diiNIds.push(bundle.nUnitId);
});

obj.DveInfo.forEach(function(bundle, indx) {
    dveIds.push(aiuIds.length + dceIds.length + dmiIds.length + diiIds.length + indx);
});

obj.DmiInfo.forEach(function(bundle, indx) {
    dmiUseAtomic.push(bundle.useAtomic); //useAtomic is ordered per NUnitID
});

obj.DutInfo.chiAiuIds.forEach(function(bundle, indx) {
    stashNids.push(obj.DutInfo.chiAiuIds[indx]);
});

function funitids() {
  var arr = [];



  obj.AiuInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });

  
  obj.DceInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });
  
  obj.DmiInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });
  
  obj.DiiInfo.forEach(function(bundle, indx) {
       		arr.push(bundle.FUnitId);
  });

  obj.DveInfo.forEach(function(bundle, indx) {
      arr.push(bundle.FUnitId);
  });

  return arr;
};

//TODO FIXME
var prtAbstract = function(b, s, l1, l2) {
  var tt = 0;
  var lg = 0;
  var nPorts = 1; //tied to 1 until we understand the implementation
  b.forEach(function(p, indx) {
    tt += 1;
    l1[lg] = [];
    l2[lg] = [];

    if (nPorts === 1) {
      l1[lg].push(s + indx);
      l2[lg].push(0);
    } else {
      for (var i = 0; i < nPorts; i++) {
        l1[lg].push(s + indx + i);
        l2[lg].push(i);
      }
    }
    lg++;
  });

  return tt;
};

//**************************************************************
//CONC-1022 
//Do not sort. element[0] of bits array is the LSB
//Example: Consider AIU port select bits 
// APF: 12,11 
//JSON: 11, 12 (reversed)
//Actual RTL must  make sure to capture GUI intent
// 12 11
// 0  0   AIU0
// 0  1   AIU1
// 1  0   AIU2
// 1  1   AIU3
//*************************************************************

var nLogaius = 0;
var nLogaiuQ = [];
var nLogaiuP = [];

var nLogdces = 0;
var nLogdceQ = [];
var nLogdceP = [];

var nLogdves = 0;
var nLogdveQ = [];
var nLogdveP = [];

var nLogdmis = 0;
var nLogdmiQ = [];
var nLogdmiP = [];

var nLogdiis = 0;
var nLogdiiQ = [];
var nLogdiiP = [];

var aiuBid = 0;
var dceBid = aiuIds.length;
var dmiBid = aiuIds.length + dceIds.length;
var diiBid = aiuIds.length + dceIds.length + dmiIds.length;
var dveBid = aiuIds.length + dceIds.length + dmiIds.length + diiIds.length;

const wTxnId = obj.AiuInfo[obj.Id].interfaces.chiInt.params.TxnID;

const getOneHotString = (index) => {
    let s = '';
    for (let i=0; i<wTxnId; i+=1) {
        s = (i == index) ? ('1'+s) : ('0'+s);
    };
    return s;
};

var DVMV8_4=(obj.DveInfo[0].DVMVersionSupport==132)?1:0;
var DVMV8_1=(obj.DveInfo[0].DVMVersionSupport==129)?1:0;
var DVMV8_0=(obj.DveInfo[0].DVMVersionSupport==128)?1:0;

%> 
class chi_aiu_coverage;
    // REQ flit fields
    bit                      lcrdv;
    chi_addr_t               addr;
    chi_qos_t                qos   ;
    chi_tgtid_t              tgtid ;
    chi_srcid_t              srcid  ;
    chi_txnid_t              txnid  ;
    chi_req_likelyshared_t   likelyshared   ;
    chi_req_pcrdtype_t       pcrdtype       ;
    chi_req_allowretry_t     allowretry     ;	//NOT SUPPORTED BY NCore
    bit                      allocate;
    bit                      cacheable;
    bit                      mem_type;
    bit                      ewa;
    bit		             snpattr        ;
    chi_lpid_t               lpid           ;
 // chi_req_returnnid_t      returnnid      ;	//ReturnNID and ReturnTxnID is inapplicable from Requester to Home and must be set to zero in all requests.                                   // chi_req_returntxnid_t    returntxnid    ;  //CHI-B SPEC (2.6 Transaction Identifier Fields, Pg No 73/368)
    chi_req_stashnid_t       stashnid       ;
    chi_req_stashnidvalid_t  stashnidvalid  ;
    chi_lpid_t               stashlpid      ;
    chi_lpidvalid_t          stashlpidvalid ;
    chi_req_endian_t         endian         ;
    chi_req_seq_item         req_txn_q[$];
    chi_snp_seq_item         snp_txn_q[$];
    chi_req_size_t           size;
    chi_req_expcompack_t     expcompack;
    chi_req_snoopme_t        snoopme;
    chi_req_excl_t           excl;
    chi_req_order_t          order;
    chi_tracetag_t           tracetag;
    // SNP flit fields
    chi_snp_donotgotosd_t    donotgotosd;
    chi_snp_donotdatapull_t  donotdatapull;
    int                      num_stashing_snps;
    int                      num_donotdatapull_asserted;
    bit [3:0]                stsh_snoops_with_donotdatapull;
    sysreq_pkt_t 		     sysreq_pkt;
    chi_aiu_scb_txn          scb_txn_item;
    chi_ns_t                 ns;
    chi_req_opcode_enum_t    req_opcode;
    chi_req_opcode_enum_t    chi_commands;
    chi_req_opcode_enum_t    rd_req_opcode;
    chi_req_opcode_enum_t    atomic_req_opcode;
    chi_req_opcode_enum_t    req_type;
    chi_dat_opcode_enum_t    rdata_opcode;
    chi_dat_opcode_enum_t    wdata_opcode;
    chi_dat_opcode_enum_t    atomic_wdata_opcode;
    chi_rsp_opcode_enum_t    srsp_opcode;
    chi_rsp_opcode_enum_t    crsp_opcode;
    chi_snp_opcode_enum_t    snp_opcode;
    chi_sysco_state_t        smi_sysco_state, chi_sysco_state;
    chi_sysco_state_t        smi_dvm_part2_sysco_state, chi_dvm_part2_sysco_state;
    bit                      isSnoop,isDVMSnoop, is_sysco_snp_returned;
    bit                      is_addr_boot_csr;
    int                normal_stsh_snoop;
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_crd_cov_<%=obj.BlockId%> = ev_pool.get("ev_crd_cov_<%=obj.BlockId%>");
    uvm_event ev_cerr_thres_<%=obj.BlockId%> = ev_pool.get("ev_cerr_thres_<%=obj.BlockId%>");
    uvm_event ev_ip_err_<%=obj.BlockId%> = ev_pool.get("ev_ip_err_<%=obj.BlockId%>");
    uvm_event boundary_addr_cov_<%=obj.BlockId%> = ev_pool.get("boundary_addr_cov_<%=obj.BlockId%>");


    chi_rsp_opcode_enum_t    crsp_dbid_opcode;
    chi_rsp_opcode_enum_t    crsp_comp_opcode;
    chi_req_opcode_enum_t    wr_req_opcode;
    bit [1:0] rd_data_resperr;
    bit [1:0] rd_cresp_resperr;
    bit [1:0] rd_sresp_resperr;
    chi_rsp_opcode_enum_t    rd_crsp_opcode;
    chi_rsp_opcode_enum_t    rd_srsp_opcode;
    chi_req_opcode_enum_t    rd_opcode;
    chi_req_opcode_enum_t    read_req_opcode;


    bit [1:0] dataless_sresp_resperr;
    bit [1:0] dataless_cresp_resperr;
    chi_req_opcode_enum_t    dataless_req_opcode;
    chi_rsp_opcode_enum_t    dataless_srsp_opcode;
    chi_rsp_opcode_enum_t    dataless_crsp_opcode;

    bit [1:0] write_sresp_resperr;
    bit [1:0] write_cresp_resperr;
    bit [1:0] write_prev_cresp_resperr;
    bit [1:0] write_data_resperr;
    chi_req_opcode_enum_t    write_req_opcode;
    chi_rsp_opcode_enum_t    write_srsp_opcode;
    chi_rsp_opcode_enum_t    write_crsp_opcode;
    chi_rsp_opcode_enum_t    write_prev_crsp_opcode;

    bit [1:0] atomic_cresp_resperr;
    bit [1:0] atomic_data_resperr;
    bit [1:0] atomic_compdata_resperr;
    chi_req_opcode_enum_t    atomic_type_opcode;
    chi_req_opcode_enum_t    atomic_load_type_opcode;
    chi_dat_opcode_enum_t    atomic_compdata_opcode;
    chi_rsp_opcode_enum_t    atomic_crsp_opcode;


    bit [1:0] dvmop_comp_resperr;
    bit [1:0] dvmop_dbid_resperr;
    bit [1:0] dvmop_ncbwrdata_resperr;
    chi_rsp_opcode_enum_t    dvmop_crsp_opcode;
    chi_rsp_opcode_enum_t    dvmop_prev_crsp_opcode;
    chi_req_opcode_enum_t    dvmop_opcode;
    chi_dat_opcode_enum_t    dvm_wdata_opcode;


    bit [1:0] snpresp_resperr;
    bit [1:0] snprespdata_resperr;
    chi_snp_opcode_enum_t    snp_type_opcode;
    chi_snp_opcode_enum_t    snoop_type_opcode;
    chi_dat_opcode_enum_t    snprespdata_opcode;
    chi_rsp_opcode_enum_t    snpresp_opcode;

    bit [WRESP-1:0]          compdata_resp;
    bit [WRESP-1:0]          atomic_compdata_resp;
    bit [WRESP-1:0]          wrcopyback_resp;
    bit [WRESP-1:0]          noncopyback_resp;
    bit [WRESP-1:0]          ncbwrcompack_resp;
    bit [WRESP-1:0]          atomic_noncopyback_resp;
    bit [WRESP-1:0]          snp_resp;
    bit [WRESP-1:0]          chi_snp_resp;
    bit [WRESP-1:0]          chi_snp_data_resp;
    bit [WRESP-1:0]          chi_snp_dataptl_resp;
    bit [WRESP-1:0]          dataless_cresp_resp;
    bit [WRESP-1:0]          atomic_cresp_resp;
    //bit [WRESP-1:0]          cresp_opcode;
    chi_rsp_opcode_enum_t    cresp_opcode;
    chi_rsp_opcode_enum_t    prev_cresp_opcode;
    chi_rsp_opcode_enum_t    prev_atomic_cresp_opcode;
    chi_rsp_opcode_enum_t    atomic_cresp_opcode;
    smi_msg_type_bit_t       snp_req_type;
    smi_cmstatus_rv_t        snp_rsp_rv;
    smi_cmstatus_rs_t        snp_rsp_rs;
    smi_cmstatus_dc_t        snp_rsp_dc;
    smi_cmstatus_dt_aiu_t    snp_rsp_dt_aiu;
    smi_cmstatus_dt_dmi_t    snp_rsp_dt_dmi ;
    smi_cmstatus_snarf_t     snp_rsp_snarf ;
    bit [5:0]                rv_rs_dc_dt_snf;
    bit [6:0]                creditv_dly;
    bit [5:0]                snp_req_rsp_dly;
    bit [11:0]               chi_cmd_req_latency;
    bit [9:0]                chi_snp_req_latency;
    bit [4:0]                chi_cmd_req_dly;
    bit [8:0]                chi_snp_req_dly;
    bit                      snp_addr_match_chi_req;
    bit                      size_1_byte_align;
    bit                      size_2_byte_align;
    bit                      size_4_byte_align;
    bit                      size_8_byte_align;
    bit                      size_16_byte_align;
    bit                      size_32_byte_align;
    bit                      error_test;
    time                     t_chi_snp_rcvd;
    time                     t_chi_req_flitv[$];


    smi_msg_type_bit_t       snp_type;
    bit [1:0]                smi_up;
    bit                      mpf3_match;
    bit                      rettosrc;
    chi_req_opcode_enum_t    rd_req_ns_opcode;
    bit                      rd_req_ns;
    bit                      rd_nsx;
    bit                      rd_err;

    chi_req_opcode_enum_t    dataless_req_ns_opcode;
    bit                      dataless_req_ns;
    bit                      dataless_nsx;
    bit                      dataless_err;


    chi_req_opcode_enum_t    wr_req_ns_opcode;
    bit                      wr_req_ns;
    bit                      wr_nsx;
    bit                      wr_err;


    chi_req_opcode_enum_t    atomic_ld_req_ns_opcode;
    bit                      atomic_ld_req_ns;
    bit                      atomic_ld_nsx;
    bit                      atomic_ld_err;

    chi_req_opcode_enum_t    atomic_st_ns_opcode;
    bit                      atomic_st_ns;
    bit                      atomic_st_nsx;
    bit                      atomic_st_err;

    <% for(var i = 0; i < obj.nDCEs; i++) { %>
    bit [5:0] DCE_CCR<%=i%>_Val;
    bit [2:0] DCE_CCR<%=i%>_state;
    <% } %>

    <% for(var i = 0; i < obj.nDMIs; i++) { %>
    bit [5:0] DMI_CCR<%=i%>_Val;
    bit [2:0] DMI_CCR<%=i%>_state;
    <% } %>

    <% for(var i = 0; i < obj.nDIIs; i++) { %>
    bit [5:0] DII_CCR<%=i%>_Val;
    bit [2:0] DII_CCR<%=i%>_state;
    <% } %>

    bit [5:0] cov_dce_csr_val;
    bit [5:0] cov_dmi_csr_val;
    bit [5:0] cov_dii_csr_val;

   <% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
    int size_gpra<%=i%>;
    int gpra<%=i%>_sizeofig;
   <% } %>

    int gpra_sizeofig_1;
    int gpra_sizeofig_2;
    int gpra_sizeofig_4;
    int gpra_sizeofig_8;
    int gpra_sizeofig_16;

    bit isdtr_req; 
    bit isstr_req; 
    bit isdtw_rsp; 
    bit boundary_start_addr; 
    bit boundary_end_addr; 
    bit one_byte_before_start_addr; 
    bit one_byte_after_end_addr; 
    int gpra_size; 
    bit [7:0] dtr_cmst; 
    bit [7:0] str_cmst; 
    bit [7:0] dtw_rsp_cmst; 


    bit isstr_wtgtid; 
    bit isdtr_wtgtid; 
    bit issysreq_wtgtid; 
    bit issnpreq_wtgtid; 
    bit iscmdrsp_wtgtid; 
    bit isdtrrsp_wtgtid; 
    bit isdtwrsp_wtgtid; 
    bit issysrsp_wtgtid; 
    bit isdtwdbgrsp_wtgtid; 

    bit [3:0] errtype_code; 
    bit [3:0] dec_err_type; 
    bit [3:0] transport_err_type; 
    bit [3:0] sysevt_err_type; 
    bit [3:0] sysco_err_type; 
    bit [3:0] soft_prog_err_type; 
    bit <%=obj.BlockId%>_corr_err_over_thres_fault;
    int <%=obj.BlockId%>_corr_err_threshold;
    int <%=obj.BlockId%>_corr_err_counter;
    bit <%=obj.BlockId%>_ip_err_err_det_en;
    bit <%=obj.BlockId%>_ip_err_err_int_en;
    int <%=obj.BlockId%>_ip_err_err_info;
    int <%=obj.BlockId%>_ip_err_err_type;
    bit <%=obj.BlockId%>_ip_err_err_valid;
    bit <%=obj.BlockId%>_ip_err_mission_fault;
    bit <%=obj.BlockId%>_ip_err_IRQ_UC;

    int num_snp_req_in_stt;
    bit skid_buffer_full;

    //connectivity vectors
    AiuDce_connectivity_vec_type AiuDce_connectivity_vec;
    AiuDmi_connectivity_vec_type AiuDmi_connectivity_vec;
    AiuDii_connectivity_vec_type AiuDii_connectivity_vec;

	//Target_id, Source_id
	smi_ncore_unit_id_bit_t target_id,source_id;
    
	bit irq_uc; 
    chi_ns_t                 req_ns;

    enum {cmdReq_cmdRsp_strReq_strRsp_dtrReq_dtrRsp, // read txn
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
          cmdReq_cmdRsp_dtrReq_dtrRsp_strReq_strRsp,
          cmdReq_cmdRsp_dtrReq_strReq_dtrRsp_strRsp,
          cmdReq_cmdRsp_dtrReq_strReq_strRsp_dtrRsp,
          cmdReq_dtrReq_cmdRsp_dtrRsp_strReq_strRsp,
          cmdReq_dtrReq_cmdRsp_strReq_strRsp_dtrRsp,
          cmdReq_dtrReq_cmdRsp_strReq_dtrRsp_strRsp,
          cmdReq_dtrReq_strReq_cmdRsp_strRsp_dtrRsp,
          cmdReq_dtrReq_strReq_cmdRsp_dtrRsp_strRsp,
          cmdReq_dtrReq_strReq_strRsp_cmdRsp_dtrRsp,
          cmdReq_dtrReq_strReq_dtrRsp_cmdRsp_strRsp,
          cmdReq_dtrReq_strReq_strRsp_dtrRsp_cmdRsp,
          cmdReq_dtrReq_strReq_dtrRsp_strRsp_cmdRsp,
          cmdReq_cmdRsp_strReq_strRsp_dtwReq_dtwRsp,
          cmdReq_cmdRsp_strReq_dtwReq_dtwRsp_strRsp, // write txn
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
          snpReq_dtwReq_dtrReq_dtwrsp_dtrrsp_snprsp, // snoop txn
          snpReq_dtwReq_dtrReq_dtwrsp_snprsp_dtrrsp,
          snpReq_dtwReq_dtrReq_dtrrsp_dtwrsp_snprsp,
          snpReq_dtwReq_dtrReq_dtrrsp_snprsp_dtwrsp,
          snpReq_dtwReq_dtrReq_snprsp_dtrrsp_dtwrsp,
          snpReq_dtwReq_dtrReq_snprsp_dtwrsp_dtrrsp,
          snpReq_dtrReq_dtwReq_dtwrsp_dtrrsp_snprsp,
          snpReq_dtrReq_dtwReq_dtwrsp_snprsp_dtrrsp,
          snpReq_dtrReq_dtwReq_dtrrsp_dtwrsp_snprsp,
          snpReq_dtrReq_dtwReq_dtrrsp_snprsp_dtwrsp,
          snpReq_dtrReq_dtwReq_snprsp_dtrrsp_dtwrsp,
          snpReq_dtrReq_dtwReq_snprsp_dtwrsp_dtrrsp,
          snpReq_dtwReq_dtwrsp_snprsp,
          snpReq_dtwReq_snprsp_dtwrsp,
          snpReq_dtrReq_dtrrsp_snprsp,
          snpReq_dtrReq_snprsp_dtrrsp} smi_msg_seq;

///////////////////////////////////////////////////////////////////////////////////
// COVERPOINTS ON SMI INTERFACE
///////////////////////////////////////////////////////////////////////////////////
    covergroup concerto_messages;
        seq_of_transitions: coverpoint smi_msg_seq {
          //bins cp_cmdReq_cmdRsp_strReq_strRsp_dtrReq_dtrRsp = {0};  // strRsp is can't come before dtrReq
            bins cp_cmdReq_cmdRsp_strReq_dtrReq_dtrRsp_strRsp = {1};
          //bins cp_cmdReq_cmdRsp_strReq_dtrReq_strRsp_dtrRsp = {2}; // // strRsp is can't come before dtrRsp
          //bins cp_cmdReq_strReq_cmdRsp_strRsp_dtrReq_dtrRsp = {3};
          //bins cp_cmdReq_strReq_cmdRsp_dtrReq_strRsp_dtrRsp = {4};
            bins cp_cmdReq_strReq_cmdRsp_dtrReq_dtrRsp_strRsp = {5};
          //bins cp_cmdReq_strReq_dtrReq_cmdRsp_strRsp_dtrRsp = {6};
            bins cp_cmdReq_strReq_dtrReq_cmdRsp_dtrRsp_strRsp = {7};
          //bins cp_cmdReq_strReq_dtrReq_strRsp_cmdRsp_dtrRsp = {8};
          //bins cp_cmdReq_strReq_dtrReq_strRsp_dtrRsp_cmdRsp = {9};  // strRsp can't come before cmdRsp and dtrRsp
            bins cp_cmdReq_strReq_dtrReq_dtrRsp_cmdRsp_strRsp = {10};
          //bins cp_cmdReq_strReq_dtrReq_dtrRsp_strRsp_cmdRsp = {11};
            bins cp_cmdReq_cmdRsp_dtrReq_dtrRsp_strReq_strRsp = {12};
            bins cp_cmdReq_cmdRsp_dtrReq_strReq_dtrRsp_strRsp = {13};
          //bins cp_cmdReq_cmdRsp_dtrReq_strReq_strRsp_dtrRsp = {14};
            bins cp_cmdReq_dtrReq_cmdRsp_dtrRsp_strReq_strRsp = {15};
          //bins cp_cmdReq_dtrReq_cmdRsp_strReq_strRsp_dtrRsp = {16};
            bins cp_cmdReq_dtrReq_cmdRsp_strReq_dtrRsp_strRsp = {17};
          //bins cp_cmdReq_dtrReq_strReq_cmdRsp_strRsp_dtrRsp = {18};
            bins cp_cmdReq_dtrReq_strReq_cmdRsp_dtrRsp_strRsp = {19};
          //bins cp_cmdReq_dtrReq_strReq_strRsp_cmdRsp_dtrRsp = {20};
            bins cp_cmdReq_dtrReq_strReq_dtrRsp_cmdRsp_strRsp = {21};
          //bins cp_cmdReq_dtrReq_strReq_strRsp_dtrRsp_cmdRsp = {22};
          //bins cp_cmdReq_dtrReq_strReq_dtrRsp_strRsp_cmdRsp = {23};
          //bins cp_cmdReq_cmdRsp_strReq_strRsp_dtwReq_dtwRsp = {24};
            bins cp_cmdReq_cmdRsp_strReq_dtwReq_dtwRsp_strRsp = {25};
          //bins cp_cmdReq_cmdRsp_strReq_dtwReq_strRsp_dtwRsp = {26};
          //bins cp_cmdReq_strReq_cmdRsp_strRsp_dtwReq_dtwRsp = {27};
          //bins cp_cmdReq_strReq_cmdRsp_dtwReq_strRsp_dtwRsp = {28};
            bins cp_cmdReq_strReq_cmdRsp_dtwReq_dtwRsp_strRsp = {29};
          //bins cp_cmdReq_strReq_dtwReq_cmdRsp_strRsp_dtwRsp = {30};
            bins cp_cmdReq_strReq_dtwReq_cmdRsp_dtwRsp_strRsp = {31};
          //bins cp_cmdReq_strReq_dtwReq_strRsp_cmdRsp_dtwRsp = {32};
          //bins cp_cmdReq_strReq_dtwReq_strRsp_dtwRsp_cmdRsp = {33};
            bins cp_cmdReq_strReq_dtwReq_dtwRsp_cmdRsp_strRsp = {34};
          //bins cp_cmdReq_strReq_dtwReq_dtwRsp_strRsp_cmdRsp = {35};
            ignore_bins cp_snpReq_dtwReq_dtrReq_dtwrsp_dtrrsp_snprsp = {36};
            ignore_bins cp_snpReq_dtwReq_dtrReq_dtwrsp_snprsp_dtrrsp = {37};
            ignore_bins cp_snpReq_dtwReq_dtrReq_dtrrsp_dtwrsp_snprsp = {38};
          //bins cp_snpReq_dtwReq_dtrReq_dtrrsp_snprsp_dtwrsp = {39};
          //bins cp_snpReq_dtwReq_dtrReq_snprsp_dtrrsp_dtwrsp = {40};
          //bins cp_snpReq_dtwReq_dtrReq_snprsp_dtwrsp_dtrrsp = {41};
         // bins cp_snpReq_dtrReq_dtwReq_dtwrsp_dtrrsp_snprsp = {42};  // dtr_req befor dtw_req not possible
         // bins cp_snpReq_dtrReq_dtwReq_dtwrsp_snprsp_dtrrsp = {43};
         // bins cp_snpReq_dtrReq_dtwReq_dtrrsp_dtwrsp_snprsp = {44};
          //bins cp_snpReq_dtrReq_dtwReq_dtrrsp_snprsp_dtwrsp = {45};
          //bins cp_snpReq_dtrReq_dtwReq_snprsp_dtrrsp_dtwrsp = {46};
          //bins cp_snpReq_dtrReq_dtwReq_snprsp_dtwrsp_dtrrsp = {47};
            bins cp_snpReq_dtwReq_dtwrsp_snprsp = {48};
          //bins cp_snpReq_dtwReq_snprsp_dtwrsp = {49}; 
            bins cp_snpReq_dtrReq_dtrrsp_snprsp = {50}; 
            bins cp_snpReq_dtrReq_snprsp_dtrrsp = {51}; 
        }
    endgroup
    covergroup smi_snp_resp;
        snp_req: coverpoint snp_req_type {
          bins snp_cln_dtr       = {SNP_CLN_DTR};
          bins snp_nitc          = {SNP_NITC};
          bins snp_vld_dtr       = {SNP_VLD_DTR};
          bins snp_inv_dtr       = {SNP_INV_DTR};
          bins snp_inv_dtw       = {SNP_INV_DTW};
          bins snp_inv           = {SNP_INV};
          bins snp_cln_dtw       = {SNP_CLN_DTW};
          ignore_bins snp_recall = {SNP_RECALL};
          <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
          bins snp_nosdint       = {SNP_NOSDINT};
          bins snp_inv_stsh      = {SNP_INV_STSH};
          bins snp_unq_stsh      = {SNP_UNQ_STSH};
          bins snp_stsh_sh       = {SNP_STSH_SH};
          bins snp_stsh_unq      = {SNP_STSH_UNQ};
          <% } %>
          bins snp_dvm_msg       = {SNP_DVM_MSG};
          bins snp_nitcci        = {SNP_NITCCI};
          bins snp_nitcmi        = {SNP_NITCMI};
        }
        snprsp_rv :coverpoint snp_rsp_rv;
        snprsp_rs :coverpoint snp_rsp_rs;
        snprsp_dc :coverpoint snp_rsp_dc;
        snprsp_dt_aiu :coverpoint snp_rsp_dt_aiu; 
        snprsp_dt_dmi :coverpoint snp_rsp_dt_dmi;

        cross snp_req, snprsp_rv {
           ignore_bins SNP_RECALL_RV         = binsof(snp_req) intersect {SNP_RECALL} && binsof(snprsp_rv) intersect {1'b0,1'b1};
           ignore_bins SNP_DVM_RV            = binsof(snp_req) intersect {SNP_DVM_MSG} && binsof(snprsp_rv) intersect {1'b0,1'b1};

     <%if(obj.testBench != "fsys"){ %>
       <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
           ignore_bins SNP_UNQ_STSH_RV         = binsof(snp_req) intersect {SNP_UNQ_STSH} && binsof(snprsp_rv) intersect {1'b1};
           ignore_bins SNP_INV_STSH_RV         = binsof(snp_req) intersect {SNP_INV_STSH} && binsof(snprsp_rv) intersect {1'b1};
       <% } %>
           ignore_bins SNP_INV_DTR_RV          = binsof(snp_req) intersect {SNP_INV_DTR} && binsof(snprsp_rv) intersect {1'b1};
           ignore_bins SNP_INV_DTW_RV          = binsof(snp_req) intersect {SNP_INV_DTW} && binsof(snprsp_rv) intersect {1'b1};
           ignore_bins SNP_INV_RV              = binsof(snp_req) intersect {SNP_INV} && binsof(snprsp_rv) intersect {1'b1};
           ignore_bins SNP_NITCCI_RV           = binsof(snp_req) intersect {SNP_NITCCI} && binsof(snprsp_rv) intersect {1'b1};
           ignore_bins SNP_NITCMI_RV           = binsof(snp_req) intersect {SNP_NITCMI} && binsof(snprsp_rv) intersect {1'b1};
      <% } %>
                                 }

        cross snp_req, snprsp_rs  {
           ignore_bins SNP_RECALL_RS         = binsof(snp_req) intersect {SNP_RECALL} && binsof(snprsp_rs) intersect {1'b0,1'b1};
           ignore_bins SNP_DVM_RS            = binsof(snp_req) intersect {SNP_DVM_MSG} && binsof(snprsp_rs) intersect {1'b0,1'b1};


     <%if(obj.testBench != "fsys"){ %>
       <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
           ignore_bins SNP_UNQ_STSH_RS         = binsof(snp_req) intersect {SNP_UNQ_STSH} && binsof(snprsp_rs) intersect {1'b1};
           ignore_bins SNP_INV_STSH_RS         = binsof(snp_req) intersect {SNP_INV_STSH} && binsof(snprsp_rs) intersect {1'b1};
       <% } %>
           ignore_bins SNP_INV_DTR_RS          = binsof(snp_req) intersect {SNP_INV_DTR} && binsof(snprsp_rs) intersect {1'b1};
           ignore_bins SNP_INV_DTW_RS          = binsof(snp_req) intersect {SNP_INV_DTW} && binsof(snprsp_rs) intersect {1'b1};
           ignore_bins SNP_INV_RS              = binsof(snp_req) intersect {SNP_INV} && binsof(snprsp_rs) intersect {1'b1};
           ignore_bins SNP_NITCCI_RS           = binsof(snp_req) intersect {SNP_NITCCI} && binsof(snprsp_rs) intersect {1'b1};
           ignore_bins SNP_NITCMI_RS           = binsof(snp_req) intersect {SNP_NITCMI} && binsof(snprsp_rs) intersect {1'b1};
      <% } %>
        }


        cross snp_req, snprsp_dc {
             ignore_bins SNP_RECALL_DC         = binsof(snp_req) intersect {SNP_RECALL} && binsof(snprsp_dc) intersect {1'b0,1'b1};
             ignore_bins SNP_DVM_DC            = binsof(snp_req) intersect {SNP_DVM_MSG} && binsof(snprsp_dc) intersect {1'b0,1'b1};


     <%if(obj.testBench != "fsys"){ %>
          <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
             ignore_bins SNP_STSH_UNQ_DC       = binsof(snp_req) intersect {SNP_STSH_UNQ} && binsof(snprsp_dc) intersect {1'b1};
             ignore_bins SNP_STSH_SH_DC        = binsof(snp_req) intersect {SNP_STSH_SH} && binsof(snprsp_dc) intersect {1'b1};
             ignore_bins SNP_INV_STSH_DC       = binsof(snp_req) intersect {SNP_INV_STSH} && binsof(snprsp_dc) intersect {1'b1};
          <% } %>
             ignore_bins SNP_INV_DC            = binsof(snp_req) intersect {SNP_INV} && binsof(snprsp_dc) intersect {1'b1};

             illegal_bins SNP_NITCCI_DC            = binsof(snp_req) intersect {SNP_NITCCI} && binsof(snprsp_dc) intersect {1'b1};
             illegal_bins SNP_NITCMI_DC            = binsof(snp_req) intersect {SNP_NITCMI} && binsof(snprsp_dc) intersect {1'b1};
             illegal_bins SNP_NITC_DC              = binsof(snp_req) intersect {SNP_NITC} && binsof(snprsp_dc) intersect {1'b1};
             illegal_bins SNP_UNQ_STSH_DC          = binsof(snp_req) intersect {SNP_UNQ_STSH} && binsof(snprsp_dc) intersect {1'b1};
             illegal_bins SNP_CLN_DTW_DC           = binsof(snp_req) intersect {SNP_CLN_DTW} && binsof(snprsp_dc) intersect {1'b1};
             illegal_bins SNP_INV_DTW_DC           = binsof(snp_req) intersect {SNP_INV_DTW} && binsof(snprsp_dc) intersect {1'b1};
     <% } %>
              }

       cross snp_req, snprsp_dt_aiu {
             ignore_bins SNP_RECALL_DT_AIU       = binsof(snp_req) intersect {SNP_RECALL} && binsof(snprsp_dt_aiu) intersect {1'b0,1'b1};
             ignore_bins SNP_DVM_DT_AIU          = binsof(snp_req) intersect {SNP_DVM_MSG} && binsof(snprsp_dt_aiu) intersect {1'b0,1'b1};

     <%if(obj.testBench != "fsys"){ %>
          <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
             ignore_bins SNP_STSH_UNQ_DT_AIU        = binsof(snp_req) intersect {SNP_STSH_UNQ} && binsof(snprsp_dt_aiu) intersect {1'b1};
             ignore_bins SNP_INV_STSH_DT_AIU        = binsof(snp_req) intersect {SNP_INV_STSH} && binsof(snprsp_dt_aiu) intersect {1'b1};
	  <% } %>
     <% } %>
       }


        cross snp_req, snprsp_dt_dmi  {
             ignore_bins SNP_RECALL_DT_DMI       = binsof(snp_req) intersect {SNP_RECALL} && binsof(snprsp_dt_dmi) intersect {1'b0,1'b1};
             ignore_bins SNP_DVM_DT_DMI          = binsof(snp_req) intersect {SNP_DVM_MSG} && binsof(snprsp_dt_dmi) intersect {1'b0,1'b1};

     <%if(obj.testBench != "fsys"){ %>
          <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
             ignore_bins SNP_INV_STSH_DT_DMI      = binsof(snp_req) intersect {SNP_INV_STSH} && binsof(snprsp_dt_dmi) intersect {1'b1};
          <% } %>
             ignore_bins SNP_INV_DT_DMI           = binsof(snp_req) intersect {SNP_INV} && binsof(snprsp_dt_dmi) intersect {1'b1};
     <% } %>

       }
    endgroup

///////////////////////////////////////////////////////////////////////////////////
// COVERPOINTS ON CHI INTERFACE
///////////////////////////////////////////////////////////////////////////////////
    covergroup chi_req_port;
        chi_req_opcode: coverpoint req_opcode {
            bins REQLCRDRETURN        = {7'h00};
            bins READSHARED           = {7'h01};
            bins READCLEAN            = {7'h02};
            bins READONCE             = {7'h03};
            bins READNOSNP            = {7'h04};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            bins PCRDRETURN           = {7'h05};
            <% } %>
            ignore_bins RSVD_6        = {7'h06}; // TODO: make it illegal later(unsupported_txn)
            bins READUNIQUE           = {7'h07};
            bins CLEANSHARED          = {7'h08};
            bins CLEANINVALID         = {7'h09};
            bins MAKEINVALID          = {7'h0A};
            bins CLEANUNIQUE          = {7'h0B};
            bins MAKEUNIQUE           = {7'h0C};
            bins EVICT                = {7'h0D};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            ignore_bins EOBARRIER     = {7'h0E};
            ignore_bins ECBARRIER     = {7'h0F};
            <% } %>
            ignore_bins RSVD_10_13    = {[7'h10 : 7'h13]}; // TODO: make it illegal later(unsupported_txn)
            bins DVMOP                = {7'h14};
            bins WRITEEVICTFULL       = {7'h15};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            bins WRITECLEANPTL        = {7'h16};
            <% } %>
            bins WRITECLEANFULL       = {7'h17};
            bins WRITEUNIQUEPTL       = {7'h18};
            bins WRITEUNIQUEFULL      = {7'h19};
            bins WRITEBACKPTL         = {7'h1A};
            bins WRITEBACKFULL        = {7'h1B};
            bins WRITENOSNPPTL        = {7'h1C};
            bins WRITENOSNPFULL       = {7'h1D};
            ignore_bins RSVD_1E_1F    = {[7'h1E : 7'h1F]}; // TODO: make it illegal later(unsupported_txn)
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins WRITEUNIQUEFULLSTASH = {7'h20};
            ignore_bins WRITEUNIQUEPTLSTASH  = {7'h21};
            bins STASHONCESHARED      = {7'h22};
            bins STASHONCEUNIQUE      = {7'h23};
            bins READONCECLEANINVALID = {7'h24};
            bins READONCEMAKEINVALID  = {7'h25};
            bins READNOTSHAREDDIRTY   = {7'h26};
            bins CLEANSHAREDPERSIST   = {7'h27};
            bins ATOMICSTORE_STADD    = {7'h28};
            bins ATOMICSTORE_STCLR    = {7'h29};
            bins ATOMICSTORE_STEOR    = {7'h2A};
            bins ATOMICSTORE_STSET    = {7'h2B};
            bins ATOMICSTORE_STSMAX   = {7'h2C};
            bins ATOMICSTORE_STMIN    = {7'h2D};
            bins ATOMICSTORE_STUSMAX  = {7'h2E};
            bins ATOMICSTORE_STUMIN   = {7'h2F};
            bins ATOMICLOAD_LDADD     = {7'h30};
            bins ATOMICLOAD_LDCLR     = {7'h31};
            bins ATOMICLOAD_LDEOR     = {7'h32};
            bins ATOMICLOAD_LDSET     = {7'h33};
            bins ATOMICLOAD_LDSMAX    = {7'h34};
            bins ATOMICLOAD_LDMIN     = {7'h35};
            bins ATOMICLOAD_LDUSMAX   = {7'h36};
            bins ATOMICLOAD_LDUMIN    = {7'h37};
            bins ATOMICSWAP           = {7'h38};
            bins ATOMICCOMPARE        = {7'h39};
            bins PREFETCHTARGET       = {7'h3A};
            ignore_bins RSVD_3B_3F    = {[7'h3B : 7'h3F]}; // TODO: make it illegal later(unsupported_txn)
          <% } %>
        }
        chi_req_to_crd_delay: coverpoint creditv_dly iff (lcrdv);
        chi_cmd_req_delay: coverpoint chi_cmd_req_dly;
        chi_req_addr: coverpoint addr;
        
        cov_dvm_op_type:          coverpoint addr[13:11]  {ignore_bins op_type_reserved = {[3'b101:3'b111]};option.weight = 0;option.goal = 0;}
        cov_dvm_va_val:           coverpoint addr[4]      {option.weight = 0;option.goal = 0;}
        cov_dvm_vmid_val:         coverpoint addr[5]      {option.weight = 0;option.goal = 0;}
        cov_dvm_asid_val:         coverpoint addr[6]      {option.weight = 0;option.goal = 0;}
        cov_dvm_vi_val:           coverpoint addr[6:5]    {option.weight = 0;option.goal = 0;}
        cov_dvm_security:         coverpoint addr[8:7]    {<%if(!DVMV8_4){%>ignore_bins security_reserved = {2'b01};<%}%> option.weight = 0;option.goal = 0;}
        cov_dvm_exception_level:  coverpoint addr[10:9]   {option.weight = 0;option.goal = 0;}
        cov_dvm_staged_inv:       coverpoint addr[39:38]  {ignore_bins staged_reserved = {2'b11}; option.weight = 0;option.goal = 0;}
        cov_dvm_leaf_entry_inv:   coverpoint addr[40]     {option.weight = 0;option.goal = 0;}

        `ifdef USE_VIP_SNPS_CHI
        //#Cover.CHI.v3.6.DVM.all_msg_type

        cov_dvm_operation_type: cross chi_req_opcode, cov_dvm_op_type {
          bins DVMOP_TLBI			           	= binsof(chi_req_opcode) intersect {7'h14} && binsof (cov_dvm_op_type) intersect {3'b000};  
          bins DVMOP_BPI			           	= binsof(chi_req_opcode) intersect {7'h14} && binsof (cov_dvm_op_type) intersect {3'b001};  
          bins DVMOP_PICI			           	= binsof(chi_req_opcode) intersect {7'h14} && binsof (cov_dvm_op_type) intersect {3'b010};  
          bins DVMOP_VICI			           	= binsof(chi_req_opcode) intersect {7'h14} && binsof (cov_dvm_op_type) intersect {3'b011};  
          bins DVMOP_SYNC			           	= binsof(chi_req_opcode) intersect {7'h14} && binsof (cov_dvm_op_type) intersect {3'b100};  
          illegal_bins DVMOP_Reserved     = binsof(chi_req_opcode) intersect {7'h14} && binsof (cov_dvm_op_type) intersect {[3'b101:3'b111]};  
          option.cross_auto_bin_max = 0;
        }	

        //#Cover.CHI.v3.6.DVM.all_sub_op_msg_type
        cov_dvm_all_sub_operation: cross chi_req_opcode, cov_dvm_op_type,cov_dvm_exception_level,cov_dvm_security, cov_dvm_asid_val,cov_dvm_vmid_val,cov_dvm_leaf_entry_inv,cov_dvm_staged_inv,cov_dvm_va_val{
          bins Secure_TLB_1   = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          bins Secure_TLB_2   = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins Secure_TLB_3   = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins Secure_TLB_4   = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          bins Secure_TLB_5   = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins Secure_TLB_6   = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Secure_Guest_OS_1    = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                      binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                      binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                      binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b01} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Secure_Guest_OS_2    = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                      binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                      binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                      binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Secure_Guest_OS_3    = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                      binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                      binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                      binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Secure_Guest_OS_4    = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                      binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                      binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                      binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Secure_Guest_OS_5    = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                      binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                      binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                      binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Secure_Guest_OS_6    = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                      binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                      binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                      binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Secure_Guest_OS_7    = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                      binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                      binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                      binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b10} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Secure_Guest_OS_8    = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                      binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                      binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                      binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b10} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Secure_Guest_OS_9    = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                      binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                      binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                      binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins non_secure_ipa_1     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                      binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b01}  && 
                                      binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                      binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b10} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins non_secure_ipa_2     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                      binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b01}  && 
                                      binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                      binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b10} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins Non_Secure_TLB_Inv_1  	= binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                     	  binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                     	  binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                     	  binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ; 

          bins Non_Secure_TLB_Inv_2  	= binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                     	  binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                     	  binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                     	  binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b01} && binsof (cov_dvm_va_val) intersect {1'b0} ; 

          bins Non_Secure_TLB_Inv_3  	= binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                     	  binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                     	  binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                     	  binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ; 

          bins Non_Secure_TLB_Inv_4  	= binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                     	  binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                     	  binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                     	  binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;

          bins Non_Secure_TLB_Inv_5  	= binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                     	  binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                     	  binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                     	  binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ; 

          bins Non_Secure_TLB_Inv_6  	= binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                     	  binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                     	  binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                     	  binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ; 

          bins Non_Secure_TLB_Inv_7  	= binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                     	  binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                     	  binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                     	  binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ; 

          bins Non_Secure_TLB_Inv_8  	= binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                     	  binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                     	  binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                     	  binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ; 

          bins Non_Secure_TLB_Inv_9  	= binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                     	  binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                     	  binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                     	  binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b10} && binsof (cov_dvm_va_val) intersect {1'b1} ; 

          bins Non_Secure_TLB_Inv_10 	= binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                     	  binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                     	  binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                     	  binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b10} && binsof (cov_dvm_va_val) intersect {1'b1} ; 

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Hypervisior_secure_TLB_Inv_1      = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Hypervisior_secure_TLB_Inv_2      = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Hypervisior_secure_TLB_Inv_3      = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Hypervisior_secure_TLB_Inv_4      = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Hypervisior_secure_TLB_Inv_5     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins Hypervisior_secure_TLB_Inv_6      = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          bins Hypervisior_nonsecure_TLB_Inv_1 = binsof(chi_req_opcode)     intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          bins Hypervisior_nonsecure_TLB_Inv_2 = binsof(chi_req_opcode)     intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins Hypervisior_nonsecure_TLB_Inv_3 = binsof(chi_req_opcode)     intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  
        //RFRF DVMV8_1 and above
          <%if(DVMV8_0){%><%='illegal_'%><%}%>bins Hypervisior_nonsecure_TLB_Inv_4 = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          <%if(DVMV8_0){%><%='illegal_'%><%}%>bins Hypervisior_nonsecure_TLB_Inv_5 = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(DVMV8_0){%><%='illegal_'%><%}%>bins Hypervisior_nonsecure_TLB_Inv_6 = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins EL3_TLB_Inv_1              = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b01}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins EL3_TLB_Inv_2              = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b01}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b1}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins EL3_TLB_Inv_3              = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b000} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b01}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          bins BPI_all                    = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b001} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b00}  && binsof (cov_dvm_security)    intersect {2'b00}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          bins BPI_by_VA                  = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b001} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b00}  && binsof (cov_dvm_security)    intersect {2'b00}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins PICI_1                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b010} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b00}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          bins PICI_2                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b010} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b00}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins PICI_3                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b010} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b00}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins PICI_4                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b010} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b00}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          bins PICI_5                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b010} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b00}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins PICI_6                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b010} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b00}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins VICI_1                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b011} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b00}  && binsof (cov_dvm_security)    intersect {2'b00}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          bins VICI_2                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b011} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b00}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          bins VICI_3                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b011} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  
        //RFRF DVMV8_4
          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins VICI_4                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b011} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  
        //RFRF DVMV8_4
          <%if(!DVMV8_4){%><%='illegal_'%><%}%>bins VICI_5                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b011} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b10}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins VICI_6                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b011} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  

          bins VICI_7                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b011} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b10}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b1}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins VICI_8                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b011} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          <%if(DVMV8_0){%><%='illegal_'%><%}%>bins VICI_9                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b011} &&
                                            binsof(cov_dvm_exception_level) intersect {2'b11}  && binsof (cov_dvm_security)    intersect {2'b11}  && 
                                            binsof(cov_dvm_asid_val)        intersect {1'b1}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                            binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b1} ;  

          bins SYNC                     = binsof(chi_req_opcode)          intersect {7'h14}  && binsof (cov_dvm_op_type)     intersect {3'b100} &&
                                          binsof(cov_dvm_exception_level) intersect {2'b00}  && binsof (cov_dvm_security)    intersect {2'b00}  && 
                                          binsof(cov_dvm_asid_val)        intersect {1'b0}   && binsof (cov_dvm_vmid_val)    intersect {1'b0}   && 
                                          binsof(cov_dvm_leaf_entry_inv)  intersect {1'b0}   && binsof (cov_dvm_staged_inv)  intersect {2'b00} && binsof (cov_dvm_va_val) intersect {1'b0} ;  
          option.cross_auto_bin_max = 0;
        }	
        `endif

        chi_req_qos: coverpoint qos;
        chi_req_tgtid: coverpoint tgtid {
            bins all_zeros = {<%=wTxnId%>'h0};
            <%for (let i=0; i<wTxnId-1; i+=1){%>
                bins range_<%=i%> = {<%=wTxnId%>'b<%=getOneHotString(i)%>};
            <%}%>
            bins all_ones = {<%=wTxnId%>'b<%for(let i=0; i<wTxnId-1; i++){%>1<%}%>};
	    }

        chi_req_srcid: coverpoint srcid {

  		bins srcid  =	{<%=obj.Id%>};
  	}
        chi_req_txnid: coverpoint txnid;
        chi_req_likelyshared: coverpoint likelyshared;
//      chi_req_pcrdtype: coverpoint pcrdtype;
        chi_req_allowretry: coverpoint allowretry;
        chi_req_allocate: coverpoint allocate;
        chi_req_cacheable: coverpoint cacheable;
	chi_req_ns : coverpoint req_ns;
        chi_req_mem_type: coverpoint mem_type;
        chi_req_ewa: coverpoint ewa;
        chi_req_snpattr: coverpoint snpattr;
        chi_req_lpid: coverpoint lpid {
		
		bins range_0    = {0};
		bins range_1    = {[1:4]};
		bins range_2    = {[5:8]};
		bins range_3    = {[9:12]};
		bins range_4    = {[13:16]};
		bins range_5    = {[17:20]};
		bins range_6    = {[21:24]};
		bins range_7    = {[25:28]};
		bins range_8    = {[29:31]};

	}

      //chi_req_returnnid:           coverpoint   returnnid      ;
      //chi_req_returntxnid:         coverpoint   returntxnid    ;
	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        chi_req_stashnid:            coverpoint   stashnid       {
              <% for(var i = 0; i < aiuIds.length; i++) { %>
                   <%if ((i !== obj.AiuInfo[obj.Id].nUnitId)) {%> 
                            bins range_<%=i%> = {<%=i%>} ;
                   <% } else { %>
                            ignore_bins range_<%=i%> = {<%=i%>} ;
                     <% } %>
              <% } %>
        }
          <% } %>

	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        chi_req_stashnidvalid:       coverpoint   stashnidvalid  {
		bins stashnidvalid_0 = {1'b0};
		bins stashnidvalid_1 = {1'b1};
	}
          <% } %>

	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        chi_req_stashlpid:           coverpoint   stashlpid     {
		
		bins range_0    = {0};
		bins range_1    = {[1:4]};
		bins range_2    = {[5:8]};
		bins range_3    = {[9:12]};
		bins range_4    = {[13:16]};
		bins range_5    = {[17:20]};
		bins range_6    = {[21:24]};
		bins range_7    = {[25:28]};
		bins range_8    = {[29:31]};
           }

          <% } %>
	

	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
           chi_req_stashlpidvalid:      coverpoint   stashlpidvalid {
		bins stashlpidvalid_0 = {1'b0};
		bins stashlpidvalid_1 = {1'b1};

	    }
          <% } %>

	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        chi_req_endian: coverpoint   endian {
          	ignore_bins endian_1 = {1'b1};
	    }
          <% } %>

        chi_req_size: coverpoint size {
          illegal_bins RSVD_7 = {3'h7};
        }
        chi_req_expcompack: coverpoint expcompack;
        chi_req_excl: coverpoint excl;
        chi_req_order: coverpoint order {
          //Applicable in Read request from HN-F to SN-F only.  Reserved in all other cases.
            bins NO_ORDER     	= {2'h0};
            illegal_bins RSVD_1 = {2'h1};
            bins REQUEST_ORDER	= {2'h2};
            bins ENDPOINT_ORDER = {2'h3};
          <%if(obj.AiuInfo[obj.Id].nDiis <= 1){%>
            ignore_bins ORDER_3  = {2'h3};
          <% } %>
        }
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        chi_req_snoopme: coverpoint snoopme;
        chi_req_tracetag: coverpoint tracetag;
        snoopeme_cross_ATOMICSTORE_STADD  : coverpoint snoopme iff (req_opcode == {7'h28});
        snoopeme_cross_ATOMICSTORE_STCLR  : coverpoint snoopme iff (req_opcode == {7'h29});
        snoopeme_cross_ATOMICSTORE_STEOR  : coverpoint snoopme iff (req_opcode == {7'h2A});
        snoopeme_cross_ATOMICSTORE_STSET  : coverpoint snoopme iff (req_opcode == {7'h2B});
        snoopeme_cross_ATOMICSTORE_STSMAX : coverpoint snoopme iff (req_opcode == {7'h2C});
        snoopeme_cross_ATOMICSTORE_STMIN  : coverpoint snoopme iff (req_opcode == {7'h2D});
        snoopeme_cross_ATOMICSTORE_STUSMAX: coverpoint snoopme iff (req_opcode == {7'h2E});
        snoopeme_cross_ATOMICSTORE_STUMIN : coverpoint snoopme iff (req_opcode == {7'h2F});
        snoopeme_cross_ATOMICLOAD_LDADD   : coverpoint snoopme iff (req_opcode == {7'h30});
        snoopeme_cross_ATOMICLOAD_LDCLR   : coverpoint snoopme iff (req_opcode == {7'h31});
        snoopeme_cross_ATOMICLOAD_LDEOR   : coverpoint snoopme iff (req_opcode == {7'h32});
        snoopeme_cross_ATOMICLOAD_LDSET   : coverpoint snoopme iff (req_opcode == {7'h33});
        snoopeme_cross_ATOMICLOAD_LDSMAX  : coverpoint snoopme iff (req_opcode == {7'h34});
        snoopeme_cross_ATOMICLOAD_LDMIN   : coverpoint snoopme iff (req_opcode == {7'h35});
        snoopeme_cross_ATOMICLOAD_LDUSMAX : coverpoint snoopme iff (req_opcode == {7'h36});
        snoopeme_cross_ATOMICLOAD_LDUMIN  : coverpoint snoopme iff (req_opcode == {7'h37});
        snoopeme_cross_ATOMICSWAP         : coverpoint snoopme iff (req_opcode == {7'h38});
        snoopeme_cross_ATOMICCOMPARE      : coverpoint snoopme iff (req_opcode == {7'h39});
        <% } %>
        chi_req_opcode_cross_size: cross chi_req_opcode, chi_req_size {
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins ignore_atomic_cmp = binsof(chi_req_opcode) intersect {7'h39} &&
                                            binsof(chi_req_size) intersect {0,6};
            ignore_bins ignore_atomic_load_store_swap = binsof(chi_req_opcode) intersect {[7'h28:7'h38]} &&
                                                        binsof(chi_req_size) intersect {4,5,6};
            <% } %>


            illegal_bins READSHARED_SIZE            = binsof(chi_req_opcode) intersect {7'h1} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins READCLEAN_SIZE             = binsof(chi_req_opcode) intersect {7'h2} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins READONCE_SIZE              = binsof(chi_req_opcode) intersect {7'h3} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins READUNIQUE_SIZE            = binsof(chi_req_opcode) intersect {7'h7} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins CLEANSHARED_SIZE           = binsof(chi_req_opcode) intersect {7'h8} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins CLEANINVALID_SIZE          = binsof(chi_req_opcode) intersect {7'h9} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins MAKEINVALID_SIZE           = binsof(chi_req_opcode) intersect {7'hA} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins CLEANUNIQUE_SIZE           = binsof(chi_req_opcode) intersect {7'hB} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins MAKEUNIQUE_SIZE            = binsof(chi_req_opcode) intersect {7'hC} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins EVICT_SIZE                 = binsof(chi_req_opcode) intersect {7'hD} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins WRITENOSNPFULL_SIZE        = binsof(chi_req_opcode) intersect {7'h1D} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins WRITEEVICTFULL_SIZE        = binsof(chi_req_opcode) intersect {7'h15} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins WRITECLEANFULL_SIZE        = binsof(chi_req_opcode) intersect {7'h17} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins WRITEBACKPTL_SIZE          = binsof(chi_req_opcode) intersect {7'h1A} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            //ignore_bins WRITEBACKPTL_SIZE         = binsof(chi_req_opcode) intersect {7'h1A} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins WRITEBACKFULL_SIZE         = binsof(chi_req_opcode) intersect {7'h1B} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins WRITEUNIQUEFULL_SIZE       = binsof(chi_req_opcode) intersect {7'h19} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins DVMOP_SIZE                 = binsof(chi_req_opcode) intersect {7'h14} && binsof(chi_req_size) intersect {3'h0,3'h1,3'h2,3'h4,3'h5,3'h6};

            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins READNOTSHAREDDIRTY_SIZE    = binsof(chi_req_opcode) intersect {7'h26} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins CLEANSHAREDPERSIST_SIZE    = binsof(chi_req_opcode) intersect {7'h27} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins READONCECLEANINVALID_SIZE  = binsof(chi_req_opcode) intersect {7'h24} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins READONCEMAKEINVALID_SIZE   = binsof(chi_req_opcode) intersect {7'h25} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            ignore_bins WRITEUNIQUEFULLSTASH_SIZE   = binsof(chi_req_opcode) intersect {7'h20} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins STASHONCESHARED_SIZE       = binsof(chi_req_opcode) intersect {7'h22} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            illegal_bins STASHONCEUNIQUE_SIZE       = binsof(chi_req_opcode) intersect {7'h23} && binsof(chi_req_size) intersect {[3'h0:3'h5]};
            <% } %>


            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            illegal_bins WRITECLEANPTL_SIZE        = binsof(chi_req_opcode) intersect {7'h16} && binsof (chi_req_size) intersect {[3'h0:3'h5]};
            <% } %>


        }
        chi_req_opcode_cross_expcompack: cross chi_req_opcode, chi_req_expcompack {

         <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins ATOMIC_LOAD_EXCOMPACK          = binsof(chi_req_opcode) intersect {[7'h30:7'h37]} && binsof (chi_req_expcompack) intersect {1'b1};
            illegal_bins ATOMIC_STORE_EXCOMPACK         = binsof(chi_req_opcode) intersect {[7'h28:7'h2F]} && binsof (chi_req_expcompack) intersect {1'b1};
            illegal_bins ATOMIC_SWAP_EXCOMPACK          = binsof(chi_req_opcode) intersect {7'h38} && binsof (chi_req_expcompack) intersect {1'b1};
            illegal_bins ATOMIC_COMPARE_EXCOMPACK       = binsof(chi_req_opcode) intersect {7'h39} && binsof (chi_req_expcompack) intersect {1'b1};
            illegal_bins STASHONCESHARED_EXCOMPACK      = binsof(chi_req_opcode) intersect {7'h22} && binsof (chi_req_expcompack) intersect {1'b1};
            illegal_bins STASHONCEUNIQUE_EXCOMPACK      = binsof(chi_req_opcode) intersect {7'h23} && binsof (chi_req_expcompack) intersect {1'b1};
            illegal_bins CLEANSHAREDPERSIST_EXCOMPACK   = binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_expcompack) intersect {1'b1};
            illegal_bins PREFETCHTARGET_EXCOMPACK       = binsof(chi_req_opcode) intersect {7'h3A} && binsof (chi_req_expcompack) intersect {1'b1};

         <% } %>

            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            illegal_bins WRITECLEANPTL_EXCOMPACK        = binsof(chi_req_opcode) intersect {7'h16} && binsof (chi_req_expcompack) intersect {1'b1};
            <% } %>

            //illegal_bins EVICT_EXCOMPACK            = binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_expcompack) intersect {1'b1};
            ignore_bins EVICT_EXCOMPACK            = binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_expcompack) intersect {1'b1};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-E') { %>
                illegal_bins WRITENOSNPPTL_EXCOMPACK    = binsof(chi_req_opcode) intersect {7'h1C} && binsof (chi_req_expcompack) intersect {1'b1};
                illegal_bins WRITENOSNPFULL_EXCOMPACK   = binsof(chi_req_opcode) intersect {7'h1D} && binsof (chi_req_expcompack) intersect {1'b1};
            <%}%>
            illegal_bins WRITEEVICTFULL_EXCOMPACK   = binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_expcompack) intersect {1'b1};
            illegal_bins WRITECLEANFULL_EXCOMPACK   = binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_expcompack) intersect {1'b1};
            illegal_bins WRITEBACKPTL_EXCOMPACK     = binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_expcompack) intersect {1'b1};
            illegal_bins WRITEBACKFULL_EXCOMPACK    = binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_expcompack) intersect {1'b1};


            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins CLEANSHARED_EXCOMPACK    = binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_expcompack) intersect {1'b1};
            illegal_bins CLEANINVALID_EXCOMPACK   = binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_expcompack) intersect {1'b1};
            illegal_bins MAKEINVALID_EXCOMPACK    = binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_expcompack) intersect {1'b1};
            <% } %>

            illegal_bins DVMOP_EXCOMPACK          = binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_expcompack) intersect {1'b1};
            illegal_bins READSHARED_EXCOMPACK     = binsof(chi_req_opcode) intersect {7'h01} && binsof (chi_req_expcompack) intersect {1'b0};
            illegal_bins READCLEAN_EXCOMPACK      = binsof(chi_req_opcode) intersect {7'h02} && binsof (chi_req_expcompack) intersect {1'b0};
            illegal_bins READUNIQUE_EXCOMPACK     = binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_expcompack) intersect {1'b0};
            illegal_bins CLEANUNIQUE_EXCOMPACK    = binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_expcompack) intersect {1'b0};
            illegal_bins MAKEUNIQUE_EXCOMPACK     = binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_expcompack) intersect {1'b0};

            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins READNOTSHAREDDIRTY_EXCOMPACK     = binsof(chi_req_opcode) intersect {7'h26} && binsof (chi_req_expcompack) intersect {1'b0};
            <% } %>

        }

	chi_req_opcode_cross_likelyshared: cross chi_req_opcode, chi_req_likelyshared {

	 <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
		illegal_bins WRITECLEANPTL_LIKELYSHARED      			= binsof(chi_req_opcode) intersect {7'h16} && binsof (chi_req_likelyshared) intersect {1'b1};
	 <% } %>
 
	 <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
		illegal_bins READONCEMAKEINVALID_LIKELYSHARED    		= binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins READONCECLEANINVALID_LIKELYSHARED   		= binsof(chi_req_opcode) intersect {7'h24} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins CLEANSHAREDPERSIST_LIKELYSHARED     		= binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins ATOMIC_SWAP_LIKELYSHARED            		= binsof(chi_req_opcode) intersect {7'h38} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins ATOMIC_COMPARE_LIKELYSHARED         		= binsof(chi_req_opcode) intersect {7'h39} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins ATOMIC_STORE_LIKELYSHARED           		= binsof(chi_req_opcode) intersect {[7'h28:7'h2F]} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins ATOMIC_LOAD_LIKELYSHARED			 	= binsof(chi_req_opcode) intersect {[7'h30:7'h37]} && binsof (chi_req_likelyshared) intersect {1'b1};
	<% } %>

		illegal_bins WRITEBACKPTL_LIKELYSHARED           		= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins WRITENOSNPFULL_LIKELYSHARED         		= binsof(chi_req_opcode) intersect {7'h1D} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins WRITENOSNPPTL_LIKELYSHARED      			= binsof(chi_req_opcode) intersect {7'h1C} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins EVICT_LIKELYSHARED                  		= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins MAKEUNIQUE_LIKELYSHARED             		= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins CLEANUNIQUE_LIKELYSHARED            		= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins MAKEINVALID_LIKELYSHARED            		= binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins CLEANINVALID_LIKELYSHARED           		= binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins CLEANSHARED_LIKELYSHARED            		= binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins READUNIQUE_LIKELYSHARED             		= binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins READONCE_LIKELYSHARED               		= binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins READNOSNOOP_LIKELYSHARED            		= binsof(chi_req_opcode) intersect {7'h04} && binsof (chi_req_likelyshared) intersect {1'b1};
		illegal_bins DVMOP_LIKELYSHARED                  		= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_likelyshared) intersect {1'b1};
	}
	
	chi_req_opcode_cross_allocate: cross chi_req_opcode, chi_req_allocate {

	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
		illegal_bins READONCEMAKEINVALID_ALLOCATE        		= binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_allocate) intersect {1'b1};
		illegal_bins WRITEEVICTFULL_ALLOCATE			 	= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_allocate) intersect {1'b0};		
	<% } %>				
		
		illegal_bins EVICT_ALLOCATE		            		= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_allocate) intersect {1'b1};
		illegal_bins DVMOP_ALLOCATE                      		= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_allocate) intersect {1'b1};
	}
	
	chi_req_opcode_cross_cacheable: cross chi_req_opcode, chi_req_cacheable {	

	 <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
		illegal_bins WRITECLEANPTL_CACHEABLE 		    		= binsof(chi_req_opcode) intersect {7'h16} && binsof (chi_req_cacheable) intersect {1'h0};
 	<% } %>	
 
 	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
		illegal_bins STASHONCESHARED_CACHEABLE				= binsof(chi_req_opcode) intersect {7'h22} && binsof (chi_req_cacheable) intersect {1'h0};
        	illegal_bins STASHONCEUNIQUE_CACHEABLE				= binsof(chi_req_opcode) intersect {7'h23} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins READONCEMAKEINVALID_CACHEABLE      		= binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins READONCECLEANINVALID_CACHEABLE     		= binsof(chi_req_opcode) intersect {7'h24} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins READNOSD_CACHEABLE  			    	= binsof(chi_req_opcode) intersect {7'h26} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins WRITEUNIQUEFULLSTATSH_CACHEABLE			= binsof(chi_req_opcode) intersect {7'h20} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins WRITEUNIQUEPTLSTATSH_CACHEABLE			= binsof(chi_req_opcode) intersect {7'h21} && binsof (chi_req_cacheable) intersect {1'h0};
 	<% } %>
		
		illegal_bins WRITEUNIQUEFULL_CACHEABLE				= binsof(chi_req_opcode) intersect {7'h19} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins WRITEUNIQUEPTL_CACHEABLE				= binsof(chi_req_opcode) intersect {7'h18} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins WRITEBACKFULL_CACHEABLE				= binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins WRITEBACKPTL_CACHEABLE				= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins WRITECLEANFULL_CACHEABLE	 			= binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins WRITEEVICTFULL_CACHEABLE	 			= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins EVICT_CACHEABLE	 		  		= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins MAKEUNIQUE_CACHEABLE	 			= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins CLEANUNIQUE_CACHEABLE	 			= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins READUNIQUE_CACHEABLE  			   	= binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins READONCE_CACHEABLE  				= binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins READCLEAN_CACHEABLE  			    	= binsof(chi_req_opcode) intersect {7'h02} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins READSHARED_CACHEABLE  			  	= binsof(chi_req_opcode) intersect {7'h01} && binsof (chi_req_cacheable) intersect {1'h0};
		illegal_bins DVMOP_CACHEABLE                    		= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_cacheable) intersect {1'h1};

	}
	
	chi_req_opcode_cross_mem_type: cross chi_req_opcode, chi_req_mem_type {

        <%if(obj.AiuInfo[obj.Id].nDiis > 1){%>
 	<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
		illegal_bins WRITECLEANPTL_DEVICE 				= binsof(chi_req_opcode) intersect {7'h16} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins MAKEINVALID_DEVICE               			= binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins CLEANINVALID_DEVICE              			= binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins CLEANSHARED_DEVICE                			= binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_mem_type) intersect {1'h1};
	 <% } %>	
       <% } %>	
 
  	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
		illegal_bins STASHONCESHARED_DEVICE				= binsof(chi_req_opcode) intersect {7'h22} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins STASHONCEUNIQUE_DEVICE				= binsof(chi_req_opcode) intersect {7'h23} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins READONCEMAKEINVALID_DEVICE     	 		= binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins READONCECLEANINVALID_DEVICE     	 		= binsof(chi_req_opcode) intersect {7'h24} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins READNOSD_DEVICE  		    	 		= binsof(chi_req_opcode) intersect {7'h26} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins WRITEUNIQUEFULLSTATSH_DEVICE	 		= binsof(chi_req_opcode) intersect {7'h20} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins WRITEUNIQUEPTLSTATSH_DEVICE 			= binsof(chi_req_opcode) intersect {7'h21} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins  PREFETCHTARGET_DEVICE                    	 	= binsof(chi_req_opcode) intersect {7'h3A} && binsof (chi_req_mem_type) intersect {1'h1};		
 	<% } %>
		
		illegal_bins WRITEUNIQUEFULL_DEVICE		 		= binsof(chi_req_opcode) intersect {7'h19} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins WRITEUNIQUEPTL_DEVICE	 			= binsof(chi_req_opcode) intersect {7'h18} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins WRITEBACKFULL_DEVICE		 		= binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins WRITEBACKPTL_DEVICE	 			= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins WRITECLEANFULL_DEVICE	  	 		= binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins WRITEEVICTFULL_DEVICE	 	 		= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins EVICT_DEVICE 		 	 		= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins MAKEUNIQUE_DEVICE	 		 		= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins CLEANUNIQUE_DEVICE			 		= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins READUNIQUE_DEVICE  		     		= binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins READONCE_DEVICE  		   	 		= binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins READCLEAN_DEVICE  		    	 		= binsof(chi_req_opcode) intersect {7'h02} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins READSHARED_DEVICE  		     		= binsof(chi_req_opcode) intersect {7'h01} && binsof (chi_req_mem_type) intersect {1'h1};
		illegal_bins DVMOP_DEVICE                    	 		= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_mem_type) intersect {1'h1};		
        
        <%if(obj.AiuInfo[obj.Id].nDiis <2){%>
	<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
		ignore_bins WRITECLEANPTL_DEVICE 				= binsof(chi_req_opcode) intersect {7'h16} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins MAKEINVALID_DEVICE               			= binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins CLEANINVALID_DEVICE              			= binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins CLEANSHARED_DEVICE                			= binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_mem_type) intersect {1'h1};
	 <% } %>	
 
  	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
		ignore_bins ATOMICSTORE_STADD_DEVICE				= binsof(chi_req_opcode) intersect {7'h28} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICSTORE_STCLR_DEVICE				= binsof(chi_req_opcode) intersect {7'h29} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICSTORE_STEOR_DEVICE     	 		= binsof(chi_req_opcode) intersect {7'h2A} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICSTORE_STSET_DEVICE     	 		= binsof(chi_req_opcode) intersect {7'h2B} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICSTORE_STSMAX_DEVICE  		    	 	= binsof(chi_req_opcode) intersect {7'h2C} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICSTORE_STUMIN_DEVICE	 		        = binsof(chi_req_opcode) intersect {7'h2F} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICSTORE_STUSMAX_DEVICE	 		        = binsof(chi_req_opcode) intersect {7'h2E} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICSTORE_STMIN_DEVICE 			        = binsof(chi_req_opcode) intersect {7'h2D} && binsof (chi_req_mem_type) intersect {1'h1};

		ignore_bins ATOMICLOAD_LDADD_DEVICE 			        = binsof(chi_req_opcode) intersect {7'h30} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICLOAD_LDCLR_DEVICE 			        = binsof(chi_req_opcode) intersect {7'h31} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICLOAD_LDEOR_DEVICE 			        = binsof(chi_req_opcode) intersect {7'h32} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICLOAD_LDSET_DEVICE 			        = binsof(chi_req_opcode) intersect {7'h33} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICLOAD_LDSMAX_DEVICE 			        = binsof(chi_req_opcode) intersect {7'h34} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICLOAD_LDUMIN_DEVICE 			        = binsof(chi_req_opcode) intersect {7'h37} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICLOAD_LDUSMAX_DEVICE 			        = binsof(chi_req_opcode) intersect {7'h36} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICLOAD_LDMIN_DEVICE 			        = binsof(chi_req_opcode) intersect {7'h35} && binsof (chi_req_mem_type) intersect {1'h1};

		ignore_bins ATOMICSWAP_DEVICE 			                = binsof(chi_req_opcode) intersect {7'h38} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins ATOMICCOMPARE_DEVICE 			        = binsof(chi_req_opcode) intersect {7'h39} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins READNOSNP_DEVICE 			                = binsof(chi_req_opcode) intersect {7'h04} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins WRITENOSNPFULL_DEVICE 			        = binsof(chi_req_opcode) intersect {7'h1D} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins WRITENOSNPPTL_DEVICE 			        = binsof(chi_req_opcode) intersect {7'h1C} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins MAKEINVALID_DEVICE 		                	= binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins CLEANSHARED_DEVICE 		                	= binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins CLEANINVALID_DEVICE 		         	= binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins CLEANSHAREDPERSIST_DEVICE 		         	= binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_mem_type) intersect {1'h1};
		ignore_bins REQLCRDRETURN_DEVICE 		         	= binsof(chi_req_opcode) intersect {7'h00} && binsof (chi_req_mem_type) intersect {1'h1};
 	<% } %>

        <% } %>
		
	}	
	
	chi_req_opcode_cross_ewa: cross chi_req_opcode, chi_req_ewa {

	<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
		illegal_bins WRITECLEANPTL_EWA  				= binsof(chi_req_opcode) intersect {7'h16} && binsof (chi_req_ewa) intersect {1'h0};
	<% } %>
 
	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
		illegal_bins STASHONCESHARED_EWA				= binsof(chi_req_opcode) intersect {7'h22} && binsof (chi_req_ewa) intersect {1'h0};
        	illegal_bins STASHONCEUNIQUE_EWA				= binsof(chi_req_opcode) intersect {7'h23} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins READONCEMAKEINVALID_EWA     			= binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins READONCECLEANINVALID_EWA     			= binsof(chi_req_opcode) intersect {7'h24} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins READNOSD_EWA  		  			= binsof(chi_req_opcode) intersect {7'h26} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins WRITEUNIQUEFULLSTATSH_EWA				= binsof(chi_req_opcode) intersect {7'h20} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins WRITEUNIQUEPTLSTATSH_EWA				= binsof(chi_req_opcode) intersect {7'h21} && binsof (chi_req_ewa) intersect {1'h0};
	    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-E') { %>
		illegal_bins CLEANSHAREDPERSIST_EWA            			= binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_ewa) intersect {1'h0};
            <%}%>
	<% } %>		

		//illegal_bins WRITEUNIQUEFULL_EWA				= binsof(chi_req_opcode) intersect {7'h19} && binsof (chi_req_ewa) intersect {1'h0};
		ignore_bins WRITEUNIQUEFULL_EWA					= binsof(chi_req_opcode) intersect {7'h19} && binsof (chi_req_ewa) intersect {1'h0};
		//illegal_bins WRITEUNIQUEPTL_EWA				= binsof(chi_req_opcode) intersect {7'h18} && binsof (chi_req_ewa) intersect {1'h0};
		ignore_bins WRITEUNIQUEPTL_EWA					= binsof(chi_req_opcode) intersect {7'h18} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins WRITEBACKFULL_EWA					= binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins WRITEBACKPTL_EWA					= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins WRITECLEANFULL_EWA	 				= binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins WRITEEVICTFULL_EWA	 				= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins EVICT_EWA	 		  			= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins MAKEUNIQUE_EWA	 				= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins CLEANUNIQUE_EWA	 				= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_ewa) intersect {1'h0};
	    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-E') { %>
		illegal_bins MAKEINVALID_EWA               			= binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins CLEANINVALID_EWA              			= binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_ewa) intersect {1'h0};
            	illegal_bins CLEANSHARED_EWA                			= binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_ewa) intersect {1'h0};
            <%}%>
		illegal_bins READUNIQUE_EWA  			    		= binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins READONCE_EWA  			    		= binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins READCLEAN_EWA  			    		= binsof(chi_req_opcode) intersect {7'h02} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins READSHARED_EWA  			    		= binsof(chi_req_opcode) intersect {7'h01} && binsof (chi_req_ewa) intersect {1'h0};
		illegal_bins DVMOP_EWA                    			= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_ewa) intersect {1'h1};
	
	}	
	
	chi_req_opcode_cross_snpattr: cross chi_req_opcode, chi_req_snpattr {

 	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>

		illegal_bins STASHONCESHARED_SNPATTR			 	= binsof(chi_req_opcode) intersect {7'h22} && binsof (chi_req_snpattr) intersect {1'h0};
        	illegal_bins STASHONCEUNIQUE_SNPATTR	 	 		= binsof(chi_req_opcode) intersect {7'h23} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins WRITEUNIQUEFULL_SNPATTR		 		= binsof(chi_req_opcode) intersect {7'h19} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins WRITEUNIQUEPTL_SNPATTR	 			= binsof(chi_req_opcode) intersect {7'h18} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins WRITEUNIQUEFULLSTATSH_SNPATTR 			= binsof(chi_req_opcode) intersect {7'h20} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins WRITEUNIQUEPTLSTATSH_SNPATTR			= binsof(chi_req_opcode) intersect {7'h21} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins WRITEBACKFULL_SNPATTR				= binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins WRITEBACKPTL_SNPATTR				= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins WRITECLEANFULL_SNPATTR	 			= binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins WRITEEVICTFULL_SNPATTR	 			= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins EVICT_SNPATTR  					= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins MAKEUNIQUE_SNPATTR					= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins CLEANUNIQUE_SNPATTR				= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins READONCEMAKEINVALID_SNPATTR	 		= binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins READONCECLEANINVALID_SNPATTR	 		= binsof(chi_req_opcode) intersect {7'h24} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins READNOSD_SNPATTR	  		   		= binsof(chi_req_opcode) intersect {7'h26} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins READUNIQUE_SNPATTR	  				= binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins READONCE_SNPATTR	  				= binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins READCLEAN_SNPATTR	  				= binsof(chi_req_opcode) intersect {7'h02} && binsof (chi_req_snpattr) intersect {1'h0};
		illegal_bins READSHARED_SNPATTR	  				= binsof(chi_req_opcode) intersect {7'h01} && binsof (chi_req_snpattr) intersect {1'h0};
		
 	<% } %>

 	<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
		ignore_bins EVICT_SNPATTR  					= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_snpattr) intersect {1'h0};
		ignore_bins MAKEUNIQUE_SNPATTR					= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_snpattr) intersect {1'h0};
		ignore_bins CLEANUNIQUE_SNPATTR				        = binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_snpattr) intersect {1'h0};
 	<% } %>
		illegal_bins WRITENOSNOOPFULL_SNPATTR	 			= binsof(chi_req_opcode) intersect {7'h1D} && binsof (chi_req_snpattr) intersect {1'h1};
		illegal_bins WRITENOSNOOPPTL_SNPATTR	 			= binsof(chi_req_opcode) intersect {7'h1C} && binsof (chi_req_snpattr) intersect {1'h1};
		illegal_bins DVMOP_SNPATTR               			= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_snpattr) intersect {1'h1};
		illegal_bins READNOSNOOP_SNPATTR            			= binsof(chi_req_opcode) intersect {7'h04} && binsof (chi_req_snpattr) intersect {1'h1};
		ignore_bins  MAKEINVALID_SNPATTR	                        = binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_snpattr) intersect {1'h0};
		ignore_bins  CLEANINVALID_SNPATTR	         		= binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_snpattr) intersect {1'h0};
		ignore_bins  CLEANSHARED_SNPATTR	         	        = binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_snpattr) intersect {1'h0};
		
	}
	
	chi_req_opcode_cross_order: cross chi_req_opcode, chi_req_order {

		illegal_bins WRITEBACKFULL_ORDER				= binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_order) intersect {2'h3};
		illegal_bins WRITEBACKPTL_OREDR					= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_order) intersect {2'h3};
		illegal_bins WRITECLEANFULL_ORDER	 			= binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_order) intersect {2'h3};
		illegal_bins WRITEEVICTFULL_ORDER	 			= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_order) intersect {2'h3};
		illegal_bins EVICT_ORDER  					= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_order) intersect {2'h3};
		illegal_bins MAKEUNIQUE_ORDER					= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_order) intersect {2'h3};
		illegal_bins CLEANUNIQUE_ORDER					= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_order) intersect {2'h3};
		illegal_bins MAKEINVALID_ORDER			             	= binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_order) intersect {2'h2,2'h3};
		illegal_bins CLEANINVALID_ORDER				        = binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_order) intersect {2'h2,2'h3};
		illegal_bins CLEANSHARED_ORDER			         	= binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_order) intersect {2'h2,2'h3};
		illegal_bins READUNIQUE_ORDER			  		= binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_order) intersect {2'h3};
		illegal_bins READONCE_ORDER				  	= binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_order) intersect {2'h1};
		illegal_bins READCLEAN_ORDER			  		= binsof(chi_req_opcode) intersect {7'h02} && binsof (chi_req_order) intersect {2'h3};
		illegal_bins READSHARED_ORDER			  		= binsof(chi_req_opcode) intersect {7'h01} && binsof (chi_req_order) intersect {2'h3};
		illegal_bins DVMOP_ORDER			               	= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_order) intersect {2'h3};
		
 	<% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
		illegal_bins WRITECLEANPTL_ORDER  			 	= binsof(chi_req_opcode) intersect {7'h16} && binsof (chi_req_order) intersect {[2'h1:2'h3]};
 	<% } %>
 
 	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
		illegal_bins STASHONCESHARED_ORDER				= binsof(chi_req_opcode) intersect {7'h22} && binsof (chi_req_order) intersect {2'h3};
		illegal_bins STASHONCEUNIQUE_ORDER	 	 		= binsof(chi_req_opcode) intersect {7'h23} && binsof (chi_req_order) intersect {2'h3};
		illegal_bins READNOSD_ORDER					= binsof(chi_req_opcode) intersect {7'h26} && binsof (chi_req_order) intersect {2'h3};
		illegal_bins CLEANSHAREDPERSIST_ORDER		 		= binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_order) intersect {2'h2,2'h3};

  	<% } %>
 
	}

	chi_req_opcode_cross_ns: cross chi_req_opcode, chi_req_ns {
		
		illegal_bins DVMOP_NS				           	= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_ns) intersect {1'h1};	
		//ignore_bins DVMOP_NS				           	= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_ns) intersect {1'h1};	
	}
	
	
/*	chi_req_opcode_snoopme: cross chi_req_opcode, chi_req_snoopme {
		
		illegal_bins DVMOP_SNOOPME			               	= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_snoopme) intersect {1'h1};	
	}
	
	chi_req_opcode_cross_returnnid: cross chi_req_opcode, chi_req_returnnid {

	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>

		illegal_bins DVMOP_RETURNNID			               	= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_returnnid) intersect {1'h1};
		//illegal_bins READSHARED_RETURNNID			  	= binsof(chi_req_opcode) intersect {7'h01} && binsof (chi_req_returnnid) intersect {1'h1};
		ignore_bins READSHARED_RETURNNID			  	= binsof(chi_req_opcode) intersect {7'h01} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins READCLEAN_RETURNNID			  	= binsof(chi_req_opcode) intersect {7'h02} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins READONCE_RETURNNID				  	= binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins READUNIQUE_RETURNNID			  	= binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins READNOSD_RETURNNID				  	= binsof(chi_req_opcode) intersect {7'h26} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins CLEANSHARED_RETURNNID			       	= binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_returnnid) intersect {1'h1};
		//illegal_bins CLEANSHAREDPERSIST_RETURNNID		 	= binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_returnnid) intersect {1'h1};
		ignore_bins CLEANSHAREDPERSIST_RETURNNID		 	= binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_returnnid) intersect {1'h1};
		//illegal_bins CLEANINVALID_RETURNNID			        = binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_returnnid) intersect {1'h1};
		ignore_bins CLEANINVALID_RETURNNID			        = binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_returnnid) intersect {1'h1};
		//illegal_bins MAKEINVALID_RETURNNID		                = binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_returnnid) intersect {1'h1};
		ignore_bins MAKEINVALID_RETURNNID		                = binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins READONCEMAKEINVALID_RETURNNID     			= binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins READONCECLEANINVALID_RETURNNID     		= binsof(chi_req_opcode) intersect {7'h24} && binsof (chi_req_returnnid) intersect {1'h1};
		//illegal_bins CLEANUNIQUE_RETURNNID				= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_returnnid) intersect {1'h1};
		ignore_bins CLEANUNIQUE_RETURNNID				= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins MAKEUNIQUE_RETURNNID				= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins EVICT_RETURNNID  					= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_returnnid) intersect {1'h1};
		//illegal_bins WRITENOSNOOPFULL_RETURNNID	 		= binsof(chi_req_opcode) intersect {7'h1D} && binsof (chi_req_returnnid) intersect {1'h1};
		ignore_bins WRITENOSNOOPFULL_RETURNNID	 			= binsof(chi_req_opcode) intersect {7'h1D} && binsof (chi_req_returnnid) intersect {1'h1};
		//illegal_bins WRITENOSNOOPPTL_RETURNNID	 		= binsof(chi_req_opcode) intersect {7'h1C} && binsof (chi_req_returnnid) intersect {1'h1};
		ignore_bins WRITENOSNOOPPTL_RETURNNID	 			= binsof(chi_req_opcode) intersect {7'h1C} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins WRITECLEANFULL_RETURNNID	 			= binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins WRITEEVICTFULL_RETURNNID	 			= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins WRITEBACKFULL_RETURNNID				= binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins WRITEBACKPTL_RETURNNID				= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins WRITEUNIQUEFULL_RETURNNID		 		= binsof(chi_req_opcode) intersect {7'h19} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins WRITEUNIQUEPTL_RETURNNID	 			= binsof(chi_req_opcode) intersect {7'h18} && binsof (chi_req_returnnid) intersect {1'h1};
		//illegal_bins ATOMIC_SWAP_RETURNNID            		= binsof(chi_req_opcode) intersect {7'h38} && binsof (chi_req_returnnid) intersect {1'h1};
		ignore_bins ATOMIC_SWAP_RETURNNID            			= binsof(chi_req_opcode) intersect {7'h38} && binsof (chi_req_returnnid) intersect {1'h1};
		//illegal_bins ATOMIC_COMPARE_RETURNNID         		= binsof(chi_req_opcode) intersect {7'h39} && binsof (chi_req_returnnid) intersect {1'h1};
		ignore_bins ATOMIC_COMPARE_RETURNNID         			= binsof(chi_req_opcode) intersect {7'h39} && binsof (chi_req_returnnid) intersect {1'h1};
		illegal_bins ATOMIC_STORE_RETURNNID           			= binsof(chi_req_opcode) intersect {[7'h28:7'h2F]} && binsof (chi_req_returnnid) intersect {1'h1};
		//illegal_bins ATOMIC_LOAD_RETURNNID			 	= binsof(chi_req_opcode) intersect {[7'h30:7'h37]} && binsof (chi_req_returnnid) intersect {1'h1};
		ignore_bins ATOMIC_LOAD_RETURNNID			 	= binsof(chi_req_opcode) intersect {[7'h30:7'h37]} && binsof (chi_req_returnnid) intersect {1'h1};
		
 	<% } %>
 
	}*/

	
	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>

	chi_req_opcode_cross_stashnid: cross chi_req_opcode, chi_req_stashnid  {

		illegal_bins DVMOP_STASHNID			               	= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_stashnid) intersect{[1:(<%=aiuIds.length%>-1)]};
		illegal_bins READSHARED_STASHNID			  	= binsof(chi_req_opcode) intersect {7'h01} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins READCLEAN_STASHNID			  		= binsof(chi_req_opcode) intersect {7'h02} && binsof (chi_req_stashnid) intersect{[1:(<%=aiuIds.length%>-1)]};
		illegal_bins READONCE_STASHNID				  	= binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins READUNIQUE_STASHNID			  	= binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins READNOSD_STASHNID				  	= binsof(chi_req_opcode) intersect {7'h26} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins CLEANSHARED_STASHNID			       	= binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins CLEANSHAREDPERSIST_STASHNID	 		= binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_stashnid) intersect{[1:(<%=aiuIds.length%>-1)]} ;
		illegal_bins CLEANINVALID_STASHNID			        = binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins MAKEINVALID_STASHNID        		        = binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins READONCEMAKEINVALID_STASHNID     			= binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins READONCECLEANINVALID_STASHNID     			= binsof(chi_req_opcode) intersect {7'h24} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins CLEANUNIQUE_STASHNID				= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins MAKEUNIQUE_STASHNID				= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins EVICT_STASHNID  					= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins WRITENOSNOOPFULL_STASHNID	 			= binsof(chi_req_opcode) intersect {7'h1D} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins WRITENOSNOOPPTL_STASHNID	 			= binsof(chi_req_opcode) intersect {7'h1C} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins WRITECLEANFULL_STASHNID	 			= binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins WRITEEVICTFULL_STASHNID	 			= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins WRITEBACKFULL_STASHNID				= binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins WRITEBACKPTL_STASHNID				= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins WRITEUNIQUEFULL_STASHNID		 		= binsof(chi_req_opcode) intersect {7'h19} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins WRITEUNIQUEPTL_STASHNID	 			= binsof(chi_req_opcode) intersect {7'h18} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins ATOMIC_SWAP_STASHNID            			= binsof(chi_req_opcode) intersect {7'h38} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins ATOMIC_COMPARE_STASHNID         			= binsof(chi_req_opcode) intersect {7'h39} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins ATOMIC_STORE_STASHNID           			= binsof(chi_req_opcode) intersect {[7'h28:7'h2F]} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins ATOMIC_LOAD_STASHNID			 	= binsof(chi_req_opcode) intersect {[7'h30:7'h37]} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		illegal_bins PREFETCHTARGET_STASHNID		 		= binsof(chi_req_opcode) intersect {7'h3A} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		ignore_bins READNOSNOOP_STASHNID	   		        = binsof(chi_req_opcode) intersect {7'h04} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
		ignore_bins REQLCRDRETURN_STASHNID	   		        = binsof(chi_req_opcode) intersect {7'h00} && binsof (chi_req_stashnid) intersect {[1:(<%=aiuIds.length%>-1)]};
 
		}
 	<% } %>
 
	
	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
	chi_req_opcode_cross_stashnidvalid: cross chi_req_opcode, chi_req_stashnidvalid {

	
		illegal_bins DVMOP_STASHNIDVALID			        = binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins READNOSNOOP_STASHNIDVALID  		       	= binsof(chi_req_opcode) intersect {7'h04} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins READSHARED_STASHNIDVALID			  	= binsof(chi_req_opcode) intersect {7'h01} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins READCLEAN_STASHNIDVALID			  	= binsof(chi_req_opcode) intersect {7'h02} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins READONCE_STASHNIDVALID				= binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins READUNIQUE_STASHNIDVALID				= binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins READNOSD_STASHNIDVALID		  	 	= binsof(chi_req_opcode) intersect {7'h26} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins CLEANSHARED_STASHNIDVALID			       	= binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins CLEANSHAREDPERSIST_STASHNIDVALID			= binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins CLEANINVALID_STASHNIDVALID		   		= binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins MAKEINVALID_STASHNIDVALID			        = binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins READONCEMAKEINVALID_STASHNIDVALID     		= binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins READONCECLEANINVALID_STASHNIDVALID     		= binsof(chi_req_opcode) intersect {7'h24} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins CLEANUNIQUE_STASHNIDVALID				= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins MAKEUNIQUE_STASHNIDVALID				= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins EVICT_STASHNIDVALID  				= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins WRITENOSNOOPFULL_STASHNIDVALID	 		= binsof(chi_req_opcode) intersect {7'h1D} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins WRITENOSNOOPPTL_STASHNIDVALID	 		= binsof(chi_req_opcode) intersect {7'h1C} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins WRITECLEANFULL_STASHNIDVALID	 		= binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins WRITEEVICTFULL_STASHNIDVALID	 		= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins WRITEBACKFULL_STASHNIDVALID			= binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins WRITEBACKPTL_STASHNIDVALID				= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins WRITEUNIQUEFULL_STASHNIDVALID		 	= binsof(chi_req_opcode) intersect {7'h19} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		illegal_bins WRITEUNIQUEPTL_STASHNIDVALID	 		= binsof(chi_req_opcode) intersect {7'h18} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		ignore_bins PREFETCHTARGET_STASHNIDVALID	 		= binsof(chi_req_opcode) intersect {7'h3A} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		ignore_bins REQLCRDRETURN_STASHNIDVALID	   		        = binsof(chi_req_opcode) intersect {7'h00} && binsof (chi_req_stashnidvalid) intersect {1'h1};
		ignore_bins ATOMIC_COMPARE_STASHNIDVALID 		        = binsof(chi_req_opcode) intersect {7'h39} && binsof (chi_req_stashnidvalid) intersect {[1'h0:1'h1]};
		ignore_bins ATOMIC_SWAP_STASHNIDVALID	 		        = binsof(chi_req_opcode) intersect {7'h38} && binsof (chi_req_stashnidvalid) intersect {[1'h0:1'h1]};
          	ignore_bins ATOMIC_LOAD_STASHNIDVALID 				= binsof(chi_req_opcode) intersect {[7'h30:7'h37]} && binsof (chi_req_stashnidvalid) intersect {[1'h0:1'h1]};
          	ignore_bins ATOMIC_STORE_STASHNIDVALID 				= binsof(chi_req_opcode) intersect {[7'h28:7'h2F]} && binsof (chi_req_stashnidvalid) intersect {[1'h0:1'h1]};
	
		}
 	<% } %>
		

	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
	chi_req_opcode_cross_endian: cross chi_req_opcode, chi_req_endian {

	
		illegal_bins DVMOP_ENDIAN			            	= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins READNOSNOOP_ENDIAN  		       		= binsof(chi_req_opcode) intersect {7'h04} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins READSHARED_ENDIAN			  		= binsof(chi_req_opcode) intersect {7'h01} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins READCLEAN_ENDIAN			  		= binsof(chi_req_opcode) intersect {7'h02} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins READONCE_ENDIAN				  	= binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins READUNIQUE_ENDIAN			  		= binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins READNOSD_ENDIAN				  	= binsof(chi_req_opcode) intersect {7'h26} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins CLEANSHARED_ENDIAN			       		= binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins CLEANSHAREDPERSIST_ENDIAN				= binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins CLEANINVALID_ENDIAN				= binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins MAKEINVALID_ENDIAN			        	= binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins READONCEMAKEINVALID_ENDIAN     			= binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins READONCECLEANINVALID_ENDIAN     			= binsof(chi_req_opcode) intersect {7'h24} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins CLEANUNIQUE_ENDIAN					= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins MAKEUNIQUE_ENDIAN					= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins EVICT_ENDIAN  					= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins WRITENOSNOOPFULL_ENDIAN	 			= binsof(chi_req_opcode) intersect {7'h1D} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins WRITENOSNOOPPTL_ENDIAN	 			= binsof(chi_req_opcode) intersect {7'h1C} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins WRITECLEANFULL_ENDIAN	 			= binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins WRITEEVICTFULL_ENDIAN	 			= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins WRITEBACKFULL_ENDIAN			    	= binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins WRITEBACKPTL_ENDIAN				= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins WRITEUNIQUEFULL_ENDIAN		 		= binsof(chi_req_opcode) intersect {7'h19} && binsof (chi_req_endian) intersect {1'h1};
		illegal_bins WRITEUNIQUEPTL_ENDIAN	 			= binsof(chi_req_opcode) intersect {7'h18} && binsof (chi_req_endian) intersect {1'h1};
	
		}
 	<% } %>
		
/*	chi_req_opcode_cross_returntxnid: cross chi_req_opcode, chi_req_returntxnid {

	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
	
		illegal_bins DVMOP_RETURNTXNID			           	= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins READCLEAN_RETURNTXNID				= binsof(chi_req_opcode) intersect {7'h02} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins READONCE_RETURNTXNID				= binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins READUNIQUE_RETURNTXNID		  		= binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins READNOSD_RETURNTXNID				= binsof(chi_req_opcode) intersect {7'h26} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins CLEANSHARED_RETURNTXNID		 		= binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_returntxnid) intersect {1'h1};
		//illegal_bins CLEANSHAREDPERSIST_RETURNTXNID			= binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_returntxnid) intersect {1'h1};
		ignore_bins CLEANSHAREDPERSIST_RETURNTXNID			= binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_returntxnid) intersect {1'h1};
		//illegal_bins CLEANINVALID_RETURNTXNID				= binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_returntxnid) intersect {1'h1};
		ignore_bins CLEANINVALID_RETURNTXNID				= binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_returntxnid) intersect {1'h1};
		//illegal_bins MAKEINVALID_RETURNTXNID	        		= binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_returntxnid) intersect {1'h1};
		ignore_bins MAKEINVALID_RETURNTXNID	        		= binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins READONCEMAKEINVALID_RETURNTXNID   			= binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins READONCECLEANINVALID_RETURNTXNID  			= binsof(chi_req_opcode) intersect {7'h24} && binsof (chi_req_returntxnid) intersect {1'h1};
		//illegal_bins CLEANUNIQUE_RETURNTXNID				= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_returntxnid) intersect {1'h1};
		ignore_bins CLEANUNIQUE_RETURNTXNID				= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins MAKEUNIQUE_RETURNTXNID				= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins EVICT_RETURNTXNID  				= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_returntxnid) intersect {1'h1};
		//illegal_bins WRITENOSNOOPFULL_RETURNTXNID	 		= binsof(chi_req_opcode) intersect {7'h1D} && binsof (chi_req_returntxnid) intersect {1'h1};
		ignore_bins WRITENOSNOOPFULL_RETURNTXNID	 		= binsof(chi_req_opcode) intersect {7'h1D} && binsof (chi_req_returntxnid) intersect {1'h1};
		//illegal_bins WRITENOSNOOPPTL_RETURNTXNID	 	   	= binsof(chi_req_opcode) intersect {7'h1C} && binsof (chi_req_returntxnid) intersect {1'h1};
		ignore_bins WRITENOSNOOPPTL_RETURNTXNID	 	   		= binsof(chi_req_opcode) intersect {7'h1C} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins WRITECLEANFULL_RETURNTXNID	 			= binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins WRITEEVICTFULL_RETURNTXNID	 			= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins WRITEBACKFULL_RETURNTXNID			   	= binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins WRITEBACKPTL_RETURNTXNID				= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins WRITEUNIQUEFULL_RETURNTXNID		 	= binsof(chi_req_opcode) intersect {7'h19} && binsof (chi_req_returntxnid) intersect {1'h1};
		illegal_bins WRITEUNIQUEPTL_RETURNTXNID	 			= binsof(chi_req_opcode) intersect {7'h18} && binsof (chi_req_returntxnid) intersect {1'h1};
	
	
 	<% } %>
		}
		
*/

	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
	chi_req_opcode_cross_stashlpidvalid: cross chi_req_opcode, chi_req_stashlpidvalid {

	
		illegal_bins DVMOP_STASHLPIDVALID			        = binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins READCLEAN_STASHLPIDVALID				= binsof(chi_req_opcode) intersect {7'h02} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins READONCE_STASHLPIDVALID				= binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins READUNIQUE_STASHLPIDVALID			  	= binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins READNOSD_STASHLPIDVALID				= binsof(chi_req_opcode) intersect {7'h26} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins CLEANSHARED_STASHLPIDVALID		 		= binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins CLEANSHAREDPERSIST_STASHLPIDVALID			= binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins CLEANINVALID_STASHLPIDVALID			= binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins MAKEINVALID_STASHLPIDVALID	        		= binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins READONCEMAKEINVALID_STASHLPIDVALID   		= binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins READONCECLEANINVALID_STASHLPIDVALID  		= binsof(chi_req_opcode) intersect {7'h24} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins CLEANUNIQUE_STASHLPIDVALID				= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins MAKEUNIQUE_STASHLPIDVALID				= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins EVICT_STASHLPIDVALID  				= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins WRITENOSNOOPFULL_STASHLPIDVALID	 		= binsof(chi_req_opcode) intersect {7'h1D} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins WRITENOSNOOPPTL_STASHLPIDVALID	 	    	= binsof(chi_req_opcode) intersect {7'h1C} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins WRITECLEANFULL_STASHLPIDVALID	 		= binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins WRITEEVICTFULL_STASHLPIDVALID	 		= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins WRITEBACKFULL_STASHLPIDVALID			= binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins WRITEBACKPTL_STASHLPIDVALID			= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins WRITEUNIQUEFULL_STASHLPIDVALID		 	= binsof(chi_req_opcode) intersect {7'h19} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins WRITEUNIQUEPTL_STASHLPIDVALID	 		= binsof(chi_req_opcode) intersect {7'h18} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
            	illegal_bins ATOMIC_LOAD_STASHLPIDVALID          		= binsof(chi_req_opcode) intersect {[7'h30:7'h37]} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
            	illegal_bins ATOMIC_STORE_STASHLPIDVALID         		= binsof(chi_req_opcode) intersect {[7'h28:7'h2F]} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
            	illegal_bins ATOMIC_SWAP_STASHLPIDVALID          		= binsof(chi_req_opcode) intersect {7'h38} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
           	illegal_bins ATOMIC_COMPARE_STASHLPIDVALID       		= binsof(chi_req_opcode) intersect {7'h39} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		illegal_bins PREFETCHTARGET_STASHLPIDVALID	 		= binsof(chi_req_opcode) intersect {7'h3A} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		ignore_bins READNOSNP_STASHLPIDVALID			  	= binsof(chi_req_opcode) intersect {7'h04} && binsof (chi_req_stashlpidvalid) intersect {[1'h0:1'h1]};
		ignore_bins REQLCRDRETURN_STASHLPIDVALID   		        = binsof(chi_req_opcode) intersect {7'h00} && binsof (chi_req_stashlpidvalid) intersect {1'h1};
		ignore_bins READSHARED_STASHLPIDVALID			  	= binsof(chi_req_opcode) intersect {7'h01} && binsof (chi_req_stashlpidvalid) intersect {[1'h0:1'h1]};
		
		}
 	<% } %>
		
	<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
	chi_req_opcode_cross_stashlpid: cross chi_req_opcode, chi_req_stashlpid {
	
		illegal_bins DVMOP_STASHLPID			           	= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]};  
		illegal_bins READCLEAN_STASHLPID		  		= binsof(chi_req_opcode) intersect {7'h02} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins READONCE_STASHLPID					= binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins READUNIQUE_STASHLPID				= binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins READNOSD_STASHLPID					= binsof(chi_req_opcode) intersect {7'h26} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins CLEANSHARED_STASHLPID		 		= binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins CLEANSHAREDPERSIST_STASHLPID			= binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins CLEANINVALID_STASHLPID			    	= binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins MAKEINVALID_STASHLPID	        		= binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins READONCEMAKEINVALID_STASHLPID   			= binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins READONCECLEANINVALID_STASHLPID  			= binsof(chi_req_opcode) intersect {7'h24} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins CLEANUNIQUE_STASHLPID				= binsof(chi_req_opcode) intersect {7'h0B} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins MAKEUNIQUE_STASHLPID				= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins EVICT_STASHLPID  					= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins WRITENOSNOOPFULL_STASHLPID	 			= binsof(chi_req_opcode) intersect {7'h1D} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins WRITENOSNOOPPTL_STASHLPID	 	    		= binsof(chi_req_opcode) intersect {7'h1C} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins WRITECLEANFULL_STASHLPID	 			= binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins WRITEEVICTFULL_STASHLPID	 			= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins WRITEBACKFULL_STASHLPID			   	= binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; 
		illegal_bins WRITEBACKPTL_STASHLPID				= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]};
		illegal_bins WRITEUNIQUEFULL_STASHLPID		 		= binsof(chi_req_opcode) intersect {7'h19} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]};
		illegal_bins WRITEUNIQUEPTL_STASHLPID	 			= binsof(chi_req_opcode) intersect {7'h18} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]};
            	illegal_bins ATOMIC_LOAD_STASHLPID          			= binsof(chi_req_opcode) intersect {[7'h30:7'h37]} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]};
            	illegal_bins ATOMIC_STORE_STASHLPID         			= binsof(chi_req_opcode) intersect {[7'h28:7'h2F]} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]};
            	illegal_bins ATOMIC_SWAP_STASHLPID         			= binsof(chi_req_opcode) intersect {7'h38} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]};
           	illegal_bins ATOMIC_COMPARE_STASHLPID       			= binsof(chi_req_opcode) intersect {7'h39} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]};
		illegal_bins PREFETCHTARGET_STASHLPID 		 		= binsof(chi_req_opcode) intersect {7'h3A} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]};
		ignore_bins REQLCRDRETURN_STASHLPID	   		        = binsof(chi_req_opcode) intersect {7'h00} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]};
		ignore_bins READNOSNP_STASHLPID 			  	= binsof(chi_req_opcode) intersect {7'h04} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]};
		ignore_bins READSHARED_STASHLPID 			  	= binsof(chi_req_opcode) intersect {7'h01} && binsof (chi_req_stashlpid) intersect {[8'h1:8'h31]}; //will analyze it in 3.6
		
		}	
 	<% } %>

        chi_req_opcode_cross_excl: cross chi_req_opcode, chi_req_excl {
            illegal_bins READONCE_EXCL                  = binsof(chi_req_opcode) intersect {7'h03} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins READUNIQUE_EXCL                = binsof(chi_req_opcode) intersect {7'h07} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins CLEANSHARED_EXCL               = binsof(chi_req_opcode) intersect {7'h08} && binsof (chi_req_excl) intersect {1'h1};

            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins CLEANSHAREDPERSIST_EXCL        = binsof(chi_req_opcode) intersect {7'h27} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins READONCECLEANINVALID_EXCL      = binsof(chi_req_opcode) intersect {7'h24} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins READONCEMAKEINVALID_EXCL       = binsof(chi_req_opcode) intersect {7'h25} && binsof (chi_req_excl) intersect {1'h1};
            <% } %>

            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            illegal_bins WRITECLEANPTL_EXCL        	= binsof(chi_req_opcode) intersect {7'h16} && binsof (chi_req_excl) intersect {1'h1};
            <% } %>
            illegal_bins CLEANINVALID_EXCL       	= binsof(chi_req_opcode) intersect {7'h09} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins MAKEINVALID_EXCL        	= binsof(chi_req_opcode) intersect {7'h0A} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins MAKEUNIQUE_EXCL             	= binsof(chi_req_opcode) intersect {7'h0C} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins EVICT_EXCL                  	= binsof(chi_req_opcode) intersect {7'h0D} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins WRITEEVICTFULL_EXCL         	= binsof(chi_req_opcode) intersect {7'h15} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins WRITECLEANFULL_EXCL         	= binsof(chi_req_opcode) intersect {7'h17} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins WRITEBACKPTL_EXCL           	= binsof(chi_req_opcode) intersect {7'h1A} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins WRITEBACKFULL_EXCL          	= binsof(chi_req_opcode) intersect {7'h1B} && binsof (chi_req_excl) intersect {1'h1};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins WRITEUNIQUEFULLSTASH_EXCL   	= binsof(chi_req_opcode) intersect {7'h20} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins WRITEUNIQUEPTLSTASH_EXCL    	= binsof(chi_req_opcode) intersect {7'h21} && binsof (chi_req_excl) intersect {1'h1};
            <% } %>
            illegal_bins WRITEUNIQUEFULL_EXCL        	= binsof(chi_req_opcode) intersect {7'h19} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins WRITEUNIQUEPTL_EXCL         	= binsof(chi_req_opcode) intersect {7'h18} && binsof (chi_req_excl) intersect {1'h1};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins STASHONCESHARED_EXCL        	= binsof(chi_req_opcode) intersect {7'h22} && binsof (chi_req_excl) intersect {1'h1};
            illegal_bins STASHONCEUNIQUE_EXCL        	= binsof(chi_req_opcode) intersect {7'h23} && binsof (chi_req_excl) intersect {1'h1};
            <% } %>
            illegal_bins DVMOP_EXCL                  	= binsof(chi_req_opcode) intersect {7'h14} && binsof (chi_req_excl) intersect {1'h1};

}

     //   chi_req_opcode_cross_returnnid: cross chi_req_opcode, chi_req_returnnid;
     //   chi_req_opcode_cross_returntxnid: cross chi_req_opcode, chi_req_returntxnid;
     //   chi_req_opcode_cross_stashnid: cross chi_req_opcode, chi_req_stashnid;
     //   chi_req_opcode_cross_stashnidvalid: cross chi_req_opcode, chi_req_stashnidvalid;
     //   chi_req_opcode_cross_stashlpid: cross chi_req_opcode, chi_req_stashlpid;
     //   chi_req_opcode_cross_stashlpidvalid: cross chi_req_opcode, chi_req_stashlpidvalid;


    endgroup

    covergroup chi_wdata_port;
        chi_wdata_opcode: coverpoint wdata_opcode {
            bins DATALCRDRETURN            = {4'h0};
            bins SNPRESPDATA               = {4'h1};
            bins COPYBACKWRDATA            = {4'h2};
            bins NONCOPYBACKWRDATA         = {4'h3};
            illegal_bins COMPDATA          = {4'h4};
            bins SNPRESPDATAPTL            = {4'h5};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins SNPRESPDATAFWDED   = {4'h6};
            bins WRDATACANCEL              = {4'h7};
            <% } %>
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            bins NCBWRDATACOMPACK  	   = {4'hC};
            <% } %>

        }
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        req_type_for_wrdatacancel: coverpoint req_opcode {
            bins WRITEUNIQUEPTL       		= {7'h18} iff (wdata_opcode == {4'h7});
            bins WRITENOSNPPTL        		= {7'h1C} iff (wdata_opcode == {4'h7});
            ignore_bins WRITEUNIQUEPTLSTASH  	= {7'h21} iff (wdata_opcode == {4'h7});
        }
        <% } %>
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            req_type_for_ncbwrdatacompack: coverpoint req_opcode {
                bins WRITENOSNPPTL          = {7'h1C} iff (wdata_opcode == {4'hC});
                bins WRITENOSNPFULL         = {7'h1D} iff (wdata_opcode == {4'hC});
                bins WRITEUNIQUEPTL         = {7'h18} iff (wdata_opcode == {4'hC});
                bins WRITEUNIQUEPTLSTASH    = {7'h21} iff (wdata_opcode == {4'hC});
                bins WRITEUNIQUEFULL        = {7'h19} iff (wdata_opcode == {4'hC});
                bins WRITEUNIQUEFULLSTASH   = {7'h20} iff (wdata_opcode == {4'hC});
            }
        <% } %>



    endgroup

    covergroup chi_rdata_port;
        opcode: coverpoint rdata_opcode {
            bins DATALCRDRETURN            = {4'h0};
            illegal_bins SNPRESPDATA       = {4'h1};
            illegal_bins COPYBACKWRDATA    = {4'h2};
            illegal_bins NONCOPYBACKWRDATA = {4'h3};
            bins COMPDATA                  = {4'h4};
            illegal_bins SNPRESPDATAPTL    = {4'h5};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins SNPRESPDATAFWDED  = {4'h6};
            illegal_bins WRDATACANCEL      = {4'h7};
            <% } %>
        }
    endgroup

    covergroup chi_srsp_port;
        chi_srsp_opcode: coverpoint srsp_opcode {
            bins RESPLCRDRETURN         = {5'h0};
            bins SNPRESP                = {5'h1};
            bins COMPACK                = {5'h2};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            illegal_bins RETRYACK       = {5'h3};
            <% } %>
            illegal_bins COMP           = {5'h4};
            illegal_bins COMPDBIDRESP   = {5'h5};
            illegal_bins DBIDRESP       = {5'h6};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            illegal_bins PCRDGRANT      = {5'h7};
            <% } %>
            illegal_bins READRECEIPT    = {5'h8};

        }
    endgroup

  <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    covergroup atomic_addr_size_alignment;
      cp_atomic_req :  coverpoint req_opcode {
            bins ATOMICSTORE_STADD    = {7'h28};
            bins ATOMICSTORE_STCLR    = {7'h29};
            bins ATOMICSTORE_STEOR    = {7'h2A};
            bins ATOMICSTORE_STSET    = {7'h2B};
            bins ATOMICSTORE_STSMAX   = {7'h2C};
            bins ATOMICSTORE_STMIN    = {7'h2D};
            bins ATOMICSTORE_STUSMAX  = {7'h2E};
            bins ATOMICSTORE_STUMIN   = {7'h2F};
            bins ATOMICLOAD_LDADD     = {7'h30};
            bins ATOMICLOAD_LDCLR     = {7'h31};
            bins ATOMICLOAD_LDEOR     = {7'h32};
            bins ATOMICLOAD_LDSET     = {7'h33};
            bins ATOMICLOAD_LDSMAX    = {7'h34};
            bins ATOMICLOAD_LDMIN     = {7'h35};
            bins ATOMICLOAD_LDUSMAX   = {7'h36};
            bins ATOMICLOAD_LDUMIN    = {7'h37};
            bins ATOMICSWAP           = {7'h38};
            //bins ATOMICCOMPARE        = {7'h39};

        }

      cp_atomic_compare_req :  coverpoint req_opcode {
            bins ATOMICCOMPARE        = {7'h39};
       }

   //     cp_atomic_size_1_byte_alignment:  coverpoint size_1_byte_align {
   //              bins size_1_byte = {'h1};
   //     }

   //     cp_atomic_size_2_byte_alignment:  coverpoint size_2_byte_align {
   //              bins size_2_byte = {'h1};
   //     }

   //     cp_atomic_size_4_byte_alignment:  coverpoint size_4_byte_align {
   //              bins size_4_byte = {'h1};
   //     }

   //     cp_atomic_size_8_byte_alignment:  coverpoint size_8_byte_align {
   //              bins size_8_byte = {'h1};
   //     }

   //     cp_atomic_size_16_byte_alignment:  coverpoint size_16_byte_align {
   //              bins size_16_byte = {'h1};
   //     }

   //     cp_atomic_size_32_byte_alignment:  coverpoint size_32_byte_align {
   //              bins size_32_byte = {'h1};
   //     }
        

       cp_atomic_size_0 : coverpoint size {
         bins size_0        =    {3'h0};
         }

       cp_atomic_size_1 : coverpoint size {
         bins size_1        =    {3'h1};
         }
       cp_atomic_size_2 : coverpoint size {
         bins size_2        =    {3'h2};
         }

       cp_atomic_size_3 : coverpoint size {
         bins size_3         =    {3'h3};
         }

       cp_atomic_size_4 : coverpoint size {
         bins size_4         =    {3'h4};
         }

       cp_atomic_size_5 : coverpoint size {
         bins size_5        =    {3'h5};
         }

       cp_size_0_addr_alignment : coverpoint addr[4:0] {
         bins size_0_addr_0 =    {5'h0};
         bins size_0_addr_1 =    {5'h1};
         bins size_0_addr_2 =    {5'h2};
         bins size_0_addr_3 =    {5'h3};
         bins size_0_addr_4 =    {5'h4};
         bins size_0_addr_5 =    {5'h5};
         bins size_0_addr_6 =    {5'h6};
         bins size_0_addr_7 =    {5'h7};
         bins size_0_addr_8 =    {5'h8};
         bins size_0_addr_9 =    {5'h9};
         bins size_0_addr_A =    {5'hA};
         bins size_0_addr_B =    {5'hB};
         bins size_0_addr_C =    {5'hC};
         bins size_0_addr_D =    {5'hD};
         bins size_0_addr_E =    {5'hE};
         bins size_0_addr_F =    {5'hF};

         <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.wData == 256) { %>
         bins size_0_addr_10 =    {5'h10};
         bins size_0_addr_11 =    {5'h11};
         bins size_0_addr_12 =    {5'h12};
         bins size_0_addr_13 =    {5'h13};
         bins size_0_addr_14 =    {5'h14};
         bins size_0_addr_15 =    {5'h15};
         bins size_0_addr_16 =    {5'h16};
         bins size_0_addr_17 =    {5'h17};
         bins size_0_addr_18 =    {5'h18};
         bins size_0_addr_19 =    {5'h19};
         bins size_0_addr_1A =    {5'h1A};
         bins size_0_addr_1B =    {5'h1B};
         bins size_0_addr_1C =    {5'h1C};
         bins size_0_addr_1D =    {5'h1D};
         bins size_0_addr_1E =    {5'h1E};
         bins size_0_addr_1F =    {5'h1F};
         <% } %>

        }

       cp_size_1_addr_alignment : coverpoint addr[4:0] {
         bins size_1_addr_0 =    {5'h0};
         bins size_1_addr_2 =    {5'h2};
         bins size_1_addr_4 =    {5'h4};
         bins size_1_addr_6 =    {5'h6};
         bins size_1_addr_8 =    {5'h8};
         bins size_1_addr_A =    {5'hA};
         bins size_1_addr_C =    {5'hC};
         bins size_1_addr_E =    {5'hE};

         <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.wData == 256) { %>
         bins size_1_addr_10 =    {5'h10};
         bins size_1_addr_12 =    {5'h12};
         bins size_1_addr_14 =    {5'h14};
         bins size_1_addr_16 =    {5'h16};
         bins size_1_addr_18 =    {5'h18};
         bins size_1_addr_1A =    {5'h1A};
         bins size_1_addr_1C =    {5'h1C};
         bins size_1_addr_1E =    {5'h1E};
         <% } %>


        }

       cp_size_2_addr_alignment : coverpoint addr[4:0] {
         bins size_2_addr_0 =    {5'h0};
         bins size_2_addr_4 =    {5'h4};
         bins size_2_addr_8 =    {5'h8};
         bins size_2_addr_C =    {5'hC};

         <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.wData == 256) { %>
         bins size_2_addr_10 =   {5'h10};
         bins size_2_addr_14 =   {5'h14};
         bins size_2_addr_18 =   {5'h18};
         bins size_2_addr_1C =   {5'h1C};
         <% } %>

        }

       cp_size_3_addr_alignment : coverpoint addr[4:0] {
         bins size_3_addr_0 =    {5'h0};
         bins size_3_addr_8 =    {5'h8};

         <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.wData == 256) { %>
         bins size_3_addr_10 =   {5'h10};
         bins size_3_addr_18 =   {5'h18};
         <% } %>
        }

         cp_size_4_addr_alignment : coverpoint addr[4:0] {
         bins size_4_addr_0 =    {5'h0};

         <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.wData == 256) { %>
         bins size_4_addr_10 =    {5'h10};
         <% } %>

        }

         cp_size_5_addr_alignment : coverpoint addr[4:0] {
            bins size_5_addr_0 =    {5'h0};
        }

                                

        //cp_atomic_req_cross_size_2_alignment  : cross cp_atomic_req, cp_atomic_size_2_byte_alignment ;
        //cp_atomic_req_cross_size_4_alignment  : cross cp_atomic_req, cp_atomic_size_4_byte_alignment ;
        //cp_atomic_req_cross_size_8_alignment  : cross cp_atomic_req, cp_atomic_size_8_byte_alignment ;
        cp_atomic_req_cross_size_0_alignment  : cross cp_atomic_req,cp_atomic_size_0,cp_size_0_addr_alignment ;
        cp_atomic_req_cross_size_1_alignment  : cross cp_atomic_req,cp_atomic_size_1,cp_size_1_addr_alignment ;
        cp_atomic_req_cross_size_2_alignment  : cross cp_atomic_req,cp_atomic_size_2,cp_size_2_addr_alignment ;
        cp_atomic_req_cross_size_3_alignment  : cross cp_atomic_req,cp_atomic_size_3,cp_size_3_addr_alignment ;
      //  cp_atomic_req_cross_size_4_alignment  : cross cp_atomic_req,cp_atomic_size_4,cp_size_4_addr_alignment ;

        cp_atomic_compare_req_cross_size_1_alignment  : cross cp_atomic_compare_req,cp_atomic_size_1,cp_size_1_addr_alignment ;
        cp_atomic_compare_req_cross_size_2_alignment  : cross cp_atomic_compare_req,cp_atomic_size_2,cp_size_2_addr_alignment ;
        cp_atomic_compare_req_cross_size_3_alignment  : cross cp_atomic_compare_req,cp_atomic_size_3,cp_size_3_addr_alignment ;
        cp_atomic_compare_req_cross_size_4_alignment  : cross cp_atomic_compare_req,cp_atomic_size_4,cp_size_4_addr_alignment ;
        cp_atomic_compare_req_cross_size_5_alignment  : cross cp_atomic_compare_req,cp_atomic_size_5,cp_size_5_addr_alignment ;
       // cp_atomic_compare_req_cross_size_32_alignment : cross cp_atomic_compare_req, cp_atomic_size_32_byte_alignment ;
    endgroup

<% } %>


    covergroup chi_crsp_port;
        chi_crsp_opcode: coverpoint crsp_opcode {
            bins RESPLCRDRETURN         = {5'h0};
            illegal_bins SNPRESP        = {5'h1};
            illegal_bins COMPACK        = {5'h2};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            bins RETRYACK               = {5'h3};
            <% } %>
            bins COMP                   = {5'h4};
            bins COMPDBIDRESP           = {5'h5};
            bins DBIDRESP               = {5'h6};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            bins PCRDGRANT              = {5'h7};
            <% } %>
            bins READRECEIPT            = {5'h8};
        }
    endgroup

    covergroup chi_snp_port;
        chi_snp_opcode: coverpoint snp_opcode {
            bins SNPLCRDRETURN   = {5'h0};
            bins SNPSHARED       = {5'h1};
            bins SNPCLEAN        = {5'h2};
            bins SNPONCE         = {5'h3};
           <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins SNPNSHDTY       = {5'h4};
            bins SNPUNQSTASH     = {5'h5};
            bins SNPMKINVSTASH   = {5'h6};
            <% } %>
            bins SNPUNIQUE       = {5'h7};
            bins SNPCLEANSHARED  = {5'h8};
            bins SNPCLEANINVALID = {5'h9};
            bins SNPMAKEINVALID  = {5'hA};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins SNPSTASHUNQ     = {5'hB};
            bins SNPSTASHSHRD    = {5'hC};
            <% } %>
            bins SNPDVMOP        = {5'hD};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins SNPSHRFWD       = {5'h11};
            ignore_bins SNPCLNFWD       = {5'h12};
            ignore_bins SNPONCEFWD      = {5'h13};
            ignore_bins SNPNOTSDFWD     = {5'h14};
            ignore_bins SNPUNQFWD       = {5'h17};
            <% } %>
        }

        snp_req_delay: coverpoint chi_snp_req_dly 
{
                bins range_0     = {[0:31]};
		bins range_1     = {[32:63]};
		bins range_2     = {[64:95]};
		bins range_3     = {[96:127]};
		bins range_4     = {[128:159]};
		bins range_5     = {[160:191]};
		bins range_6     = {[192:223]};
		bins range_7     = {[224:255]};
		bins range_8     = {[256:287]};
                bins range_9     = {[288:319]};
		bins range_10    = {[320:351]};
		bins range_11    = {[352:383]};
		bins range_12    = {[384:415]};
		bins range_13    = {[416:447]};
		bins range_14    = {[448:479]};
		bins range_15    = {[480:511]};
}
 
        snp_addr_match_pending_chi_req: coverpoint snp_addr_match_chi_req;
        <%if(obj.testBench != "fsys"){ %>
        opcode_cross_ns: cross ns, chi_snp_opcode {
          illegal_bins SNPDVMOP_NS        = binsof (chi_snp_opcode) intersect {5'hD} && binsof (ns) intersect {1'b1};
          ignore_bins SNPLCRDRETURN_NS    = binsof (chi_snp_opcode) intersect {5'h0} && binsof (ns) intersect {1'b1};

        }
        <% } %>



        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        opcode_cross_donotgotosd: cross donotgotosd, chi_snp_opcode
        {
          illegal_bins SNP_OPCODE_DONOTGOTOSD_7        	= binsof (chi_snp_opcode) intersect {5'h7} && binsof (donotgotosd) intersect {1'b0};
          illegal_bins SNP_OPCODE_DONOTGOTOSD_8        	= binsof (chi_snp_opcode) intersect {5'h8} && binsof (donotgotosd) intersect {1'b0}; //check this
          illegal_bins SNP_OPCODE_DONOTGOTOSD_9        	= binsof (chi_snp_opcode) intersect {5'h9} && binsof (donotgotosd) intersect {1'b0};//check this
          illegal_bins SNP_OPCODE_DONOTGOTOSD_A        	= binsof (chi_snp_opcode) intersect {5'hA} && binsof (donotgotosd) intersect {1'b0}; // check this
          illegal_bins SNP_OPCODE_DONOTGOTOSD_17       	= binsof (chi_snp_opcode) intersect {5'h17} && binsof (donotgotosd) intersect {1'b0};
          illegal_bins SNP_OPCODE_DONOTGOTOSD_D        	= binsof (chi_snp_opcode) intersect {5'hD} && binsof (donotgotosd) intersect {1'b1};

          ignore_bins SNP_OPCODE_DONOTGOTOSD_5        	= binsof (chi_snp_opcode) intersect {5'h5} && binsof (donotgotosd) intersect {1'b0,1'b1};
          ignore_bins SNP_OPCODE_DONOTGOTOSD_6        	= binsof (chi_snp_opcode) intersect {5'h6} && binsof (donotgotosd) intersect {1'b0,1'b1};
          ignore_bins SNP_OPCODE_DONOTGOTOSD_B        	= binsof (chi_snp_opcode) intersect {5'hB} && binsof (donotgotosd) intersect {1'b0,1'b1};
          ignore_bins SNP_OPCODE_DONOTGOTOSD_C        	= binsof (chi_snp_opcode) intersect {5'hC} && binsof (donotgotosd) intersect {1'b0,1'b1};

          ignore_bins SNP_OPCODE_DONOTGOTOSD_0        	= binsof (chi_snp_opcode) intersect {5'h0} && binsof (donotgotosd) intersect {1'b1};
          ignore_bins SNP_OPCODE_DONOTGOTOSD_1        	= binsof (chi_snp_opcode) intersect {5'h1} && binsof (donotgotosd) intersect {1'b1};
          ignore_bins SNP_OPCODE_DONOTGOTOSD_2        	= binsof (chi_snp_opcode) intersect {5'h2} && binsof (donotgotosd) intersect {1'b1};
          ignore_bins SNP_OPCODE_DONOTGOTOSD_3        	= binsof (chi_snp_opcode) intersect {5'h3} && binsof (donotgotosd) intersect {1'b1};
          ignore_bins SNP_OPCODE_DONOTGOTOSD_4        	= binsof (chi_snp_opcode) intersect {5'h4} && binsof (donotgotosd) intersect {1'b1};

        }


        opcode_cross_donotdatapull: cross donotdatapull, chi_snp_opcode {

          ignore_bins SNP_OPCODE_DONOTDATAPULL        = binsof (chi_snp_opcode) intersect {5'h1,5'h2,5'h3,5'h4,5'h7,5'h8,5'h9,5'hA,5'h11,5'h12,5'h13,5'h14,5'h17} && binsof (donotdatapull) intersect {1'b0,1'b1};
          illegal_bins SNP_OPCODE_DONOTDATAPULL_1     = binsof (chi_snp_opcode) intersect {5'hD} && binsof (donotdatapull) intersect {1'b1};
          ignore_bins SNP_OPCODE_DONOTDATAPULL_0      = binsof (chi_snp_opcode) intersect {5'h0} && binsof (donotdatapull) intersect {1'b1};

        }
        <% } %>
    endgroup

    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    covergroup stashing_snoops;
        donotdatapull_asserted:coverpoint stsh_snoops_with_donotdatapull;
    endgroup
    <% } %>

    covergroup chi_rd_req_err_resp_cg; //#Cover.CHIAIU.Error.Concerto.v3.0.decerr //#Cover.CHIAIU.Error.Concerto.v3.0.dataerr

      cp_rd_req_type: coverpoint rd_opcode {
            bins READNOSNP                  = {7'h04};
            bins READONCE                   = {7'h03};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins READNOTSHAREDDIRTY         = {7'h26}; 
            bins READONCECLEANINVALID       = {7'h24};
            bins READONCEMAKEINVALID        = {7'h25};
        <% } %>
            bins READSHARED                 = {7'h01};
            bins READCLEAN                  = {7'h02};
            bins READUNIQUE                 = {7'h07}; 
      }


      cp_rd_data_opcode: coverpoint rdata_opcode {
           bins COMPDATA            = {'h4};
       }


       cp_rd_data_resperr   : coverpoint rd_data_resperr {
           bins RESPERR_OK            = {4'h0};
           bins RESPERR_EXOK          = {4'h1};
           bins RESPERR_DERR          = {4'h2};
           bins RESPERR_NDERR         = {4'h3};
      }

       /*cp_rd_cresp_resperr   : coverpoint rd_cresp_resperr {
           bins RESPERR_OK            = {'h0};
           bins RESPERR_EXOK          = {'h1};
           bins RESPERR_DERR          = {'h2};
           bins RESPERR_NDERR         = {'h3};
      }*/


       rd_req_cross_resperr : cross cp_rd_req_type, cp_rd_data_opcode, cp_rd_data_resperr  {
        illegal_bins RDONCE_RESPERR                 =  binsof (cp_rd_req_type) intersect {7'h3} && binsof (cp_rd_data_resperr) intersect {2'h1};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        illegal_bins READONCECLEANINVALID_RESPERR   =  binsof (cp_rd_req_type) intersect {7'h24} && binsof (cp_rd_data_resperr) intersect {2'h1};
        illegal_bins READONCEMAKEINVALID_RESPERR    =  binsof (cp_rd_req_type) intersect {7'h25} && binsof (cp_rd_data_resperr) intersect {2'h1};
        <% } %>
        illegal_bins READUNIQUE_RESPERR             =  binsof (cp_rd_req_type) intersect {7'h07} && binsof (cp_rd_data_resperr) intersect {2'h1};
       }

    endgroup


    covergroup chi_rd_req_cresp_err_resp_cg; //#Cover.CHIAIU.Error.Concerto.v3.0.decerr

      cp_rd_req_type: coverpoint rd_opcode {
            bins READNOSNP                  = {7'h04};
            bins READONCE                   = {7'h03};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
           ignore_bins READNOTSHAREDDIRTY   = {7'h26}; 
           bins READONCECLEANINVALID        = {7'h24};
           bins READONCEMAKEINVALID         = {7'h25};
        <% } %>
           ignore_bins READSHARED           = {7'h01};
           ignore_bins READCLEAN            = {7'h02};
           ignore_bins READUNIQUE           = {7'h07}; 
      }


      cp_rd_cresp: coverpoint rd_crsp_opcode {
           bins READRECEIPT            = {5'h8};
       }


       cp_rd_cresp_resperr   : coverpoint rd_cresp_resperr {
           bins RESPERR_OK            = {2'h0};
           bins RESPERR_EXOK          = {2'h1};
           bins RESPERR_DERR          = {2'h2};
           bins RESPERR_NDERR         = {2'h3};
       }

       rd_req_cross_cresp : cross cp_rd_req_type, cp_rd_cresp, cp_rd_cresp_resperr  {
        illegal_bins READNOSNP_CRESP_RESPERR                 =  binsof (cp_rd_req_type) intersect {7'h4} && binsof (cp_rd_cresp_resperr) intersect {2'h1,2'h2,2'h3};
        illegal_bins READONCE_CRESP_RESPERR                  =  binsof (cp_rd_req_type) intersect {7'h3} && binsof (cp_rd_cresp_resperr) intersect {2'h1,2'h2,2'h3};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        illegal_bins READONCECLEANINVALID_CRESP_RESPERR      =  binsof (cp_rd_req_type) intersect {7'h24} && binsof (cp_rd_cresp_resperr) intersect {2'h1,2'h2,2'h3};
        illegal_bins READONCEMAKEINVALID_CRESP_RESPERR       =  binsof (cp_rd_req_type) intersect {7'h25} && binsof (cp_rd_cresp_resperr) intersect {2'h1,2'h2,2'h3};
        <% } %>
       }

    endgroup

    covergroup chi_rd_req_sresp_err_resp_cg; //#Cover.CHIAIU.Error.Concerto.v3.0.decerr


      cp_rd_req_type: coverpoint read_req_opcode {
            bins READNOSNP                  = {7'h04};
            bins READONCE                   = {7'h03};
        <% if(obj.AiuInfo[obj.Id].fnNativeInter7face != 'CHI-A') { %>
           bins READNOTSHAREDDIRTY          = {7'h26}; 
           bins READONCECLEANINVALID        = {7'h24};
           bins READONCEMAKEINVALID         = {7'h25};
        <% } %>
           bins READSHARED                  = {7'h01};
           bins READCLEAN                   = {7'h02};
           bins READUNIQUE                  = {7'h07}; 
      }

      cp_rd_sresp: coverpoint rd_srsp_opcode {
           bins COMPACK            = {5'h2};
       }

       cp_rd_sresp_resperr   : coverpoint rd_sresp_resperr {
           bins RESPERR_OK                    = {2'h0};
           illegal_bins RESPERR_EXOK          = {2'h1};
           illegal_bins RESPERR_DERR          = {2'h2};
           illegal_bins RESPERR_NDERR         = {2'h3};
       }

       rd_req_cross_sresp : cross cp_rd_req_type, cp_rd_sresp, cp_rd_sresp_resperr  {
        illegal_bins READNOSNP_SRESP_RESPERR                 =  binsof (cp_rd_req_type) intersect {7'h4} && binsof (cp_rd_sresp_resperr) intersect {2'h1,2'h2,2'h3};
        illegal_bins READONCE_SRESP_RESPERR                  =  binsof (cp_rd_req_type) intersect {7'h3} && binsof (cp_rd_sresp_resperr) intersect {2'h1,2'h2,2'h3};
        illegal_bins READSHARED_SRESP_RESPERR                =  binsof (cp_rd_req_type) intersect {7'h1} && binsof (cp_rd_sresp_resperr) intersect {2'h1,2'h2,2'h3};
        illegal_bins READCLEAN_SRESP_RESPERR                 =  binsof (cp_rd_req_type) intersect {7'h2} && binsof (cp_rd_sresp_resperr) intersect {2'h1,2'h2,2'h3};
        illegal_bins READUNIQUE_SRESP_RESPERR                =  binsof (cp_rd_req_type) intersect {7'h7} && binsof (cp_rd_sresp_resperr) intersect {2'h1,2'h2,2'h3};


        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        illegal_bins READONCECLEANINVALID_SRESP_RESPERR      =  binsof (cp_rd_req_type) intersect {7'h24} && binsof (cp_rd_sresp_resperr) intersect {2'h1,2'h2,2'h3};
        illegal_bins READONCEMAKEINVALID_SRESP_RESPERR       =  binsof (cp_rd_req_type) intersect {7'h25} && binsof (cp_rd_sresp_resperr) intersect {2'h1,2'h2,2'h3};
        illegal_bins READNOTSHAREDDIRTY_SRESP_RESPERR        =  binsof (cp_rd_req_type) intersect {7'h26} && binsof (cp_rd_sresp_resperr) intersect {2'h1,2'h2,2'h3};
        <% } %>

       }
    endgroup


    covergroup chi_dataless_req_err_resp_cg;

         cp_chi_dataless_req_type: coverpoint dataless_req_opcode {
            bins CLEANUNIQUE                  = {7'h0B};
            bins MAKEUNIQUE                   = {7'h0C}; 
            bins EVICT                        = {7'h0D};
            bins CLEANSHARED                  = {7'h08};
            bins CLEANINVALID                 = {7'h09};
            bins MAKEINVALID                  = {7'h0A};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins CLEANSHAREDPERSIST           = {7'h27};
            bins STASHONCEUNIQUE              = {7'h23}; 
            bins STASHONCESHARED              = {7'h22};
        <% } %>
          }

      cp_dataless_sresp: coverpoint dataless_srsp_opcode {
           bins COMPACK            = {5'h2};
       }

       cp_dataless_sresp_resperr   : coverpoint dataless_sresp_resperr {
           bins RESPERR_OK                    = {2'h0};
           illegal_bins RESPERR_EXOK          = {2'h1};
           illegal_bins RESPERR_DERR          = {2'h2};
           illegal_bins RESPERR_NDERR         = {2'h3};
       }


      cp_dataless_cresp: coverpoint dataless_crsp_opcode {
           bins COMP            = {5'h4};
       }

       cp_dataless_cresp_resperr   : coverpoint dataless_cresp_resperr {
           bins RESPERR_OK                  = {2'h0};
           bins RESPERR_EXOK                = {2'h1};
         //bins RESPERR_DERR                = {2'h2};
           ignore_bins RESPERR_DERR         = {2'h2}; // Ncore Error Arch spec sec-1.7
           bins RESPERR_NDERR               = {2'h3};
       }


       dataless_req_cross_sresp : cross cp_chi_dataless_req_type, cp_dataless_sresp, cp_dataless_sresp_resperr  {
        illegal_bins CLEANUNIQUE_SRESP_RESPERR                 =  binsof (cp_chi_dataless_req_type) intersect {7'hB} && binsof (cp_dataless_sresp_resperr) intersect {2'b01,2'b10,2'b11};
        illegal_bins MAKEUNIQUE_SRESP_RESPERR                  =  binsof (cp_chi_dataless_req_type) intersect {7'hC} && binsof (cp_dataless_sresp_resperr) intersect {2'b01,2'b10,2'b11};
        ignore_bins DATALESS_REQ                               =  binsof (cp_chi_dataless_req_type) intersect {7'hD,7'h8,7'h9,7'hA} && binsof (cp_dataless_sresp_resperr) intersect {2'h1,2'h2,2'h3};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        ignore_bins DATALESS_REQ_CHI_B                              =  binsof (cp_chi_dataless_req_type) intersect {'h22,'h23,'h27} && binsof (cp_dataless_sresp_resperr) intersect {2'h1,2'h2,2'h3};
        <% } %>
       }


       dataless_req_cross_cresp : cross cp_chi_dataless_req_type, cp_dataless_cresp, cp_dataless_cresp_resperr  {
        illegal_bins MAKEUNIQUE_CRESP_RESPERR                  =  binsof (cp_chi_dataless_req_type) intersect {7'hC} && binsof (cp_dataless_cresp_resperr) intersect {2'h1};
        illegal_bins CLEANSHARED_CRESP_RESPERR                 =  binsof (cp_chi_dataless_req_type) intersect {7'h8} && binsof (cp_dataless_cresp_resperr) intersect {2'h1};
        illegal_bins CLEANINVALID_CRESP_RESPERR                =  binsof (cp_chi_dataless_req_type) intersect {7'h9} && binsof (cp_dataless_cresp_resperr) intersect {2'h1};
        illegal_bins MAKEINVALID_CRESP_RESPERR                 =  binsof (cp_chi_dataless_req_type) intersect {7'hA} && binsof (cp_dataless_cresp_resperr) intersect {2'h1};
        illegal_bins EVICT_CRESP_EXOK_RESPERR                  =  binsof (cp_chi_dataless_req_type) intersect {7'hD} && binsof (cp_dataless_cresp_resperr) intersect {2'h1};
        ignore_bins EVICT_CRESP_DERR_RESPERR                   =  binsof (cp_chi_dataless_req_type) intersect {7'hD} && binsof (cp_dataless_cresp_resperr) intersect {2'h2};
        //illegal_bins EVICT_CRESP_RESPERR                     =  binsof (cp_chi_dataless_req_type) intersect {7'hD} && binsof (cp_dataless_cresp_resperr) intersect {2'h1,2'h2};//CONC-9598

        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
        illegal_bins CLEANSHAREDPERSIST_CRESP_RESPERR            =  binsof (cp_chi_dataless_req_type) intersect {7'h27} && binsof (cp_dataless_cresp_resperr) intersect {2'h1};
        illegal_bins STASHONCEUNIQUE_CRESP_RESPERR               =  binsof (cp_chi_dataless_req_type) intersect {7'h23} && binsof (cp_dataless_cresp_resperr) intersect {2'h1};
        illegal_bins STASHONCESHARED_CRESP_RESPERR               =  binsof (cp_chi_dataless_req_type) intersect {7'h22} && binsof (cp_dataless_cresp_resperr) intersect {2'h1};
        <% } %>
       }


    endgroup

    covergroup chi_write_req_err_resp_cg; //#Cover.CHIAIU.Error.Concerto.v3.0.dataerr

      cp_write_req_type: coverpoint write_req_opcode {
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            bins WRITECLEANPTL       	      = {7'h16};
            <% } %>
            bins WRITENOSNPPTL                = {7'h1C}; 
            bins WRITENOSNPFULL               = {7'h1D}; 
            bins WRITEUNIQUEPTL               = {7'h18}; 
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins WRITEUNIQUEPTLSTASH   = {7'h21};
            <% } %>
            bins WRITEUNIQUEFULL              = {7'h19};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins WRITEUNIQUEFULLSTASH  = {7'h20};
            <% } %>
            bins WRITEBACKFULL                = {7'h1B};
            bins WRITEBACKPTL                 = {7'h1A};
            bins WRITECLEANFULL               = {7'h17};
            bins WRITEEVICTFULL               = {7'h15};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            bins WRITENOSNPFULL_CLEANSHARED         	= {7'h50};
            bins WRITENOSNPFULL_CLEANINVALID            = {7'h51};
            bins WRITENOSNPFULL_CLEANSHAREDPERSISTSEP   = {7'h52};
            bins WRITEBACKFULL_CLEANSHARED              = {7'h58};
            bins WRITEBACKFULL_CLEANINVALID             = {7'h59};
            bins WRITEBACKFULL_CLEANSHAREDPERSISTSEP    = {7'h5A};
            bins WRITECLEANFULL_CLEANSHARED             = {7'h5C};
            bins WRITECLEANFULL_CLEANSHAREDPERSISTSEP   = {7'h5E};
            bins WRITEEVICTOREVICT               	= {7'h42};
            <% } %>
          }


      cp_write_sresp: coverpoint write_srsp_opcode {
           bins COMPACK            = {5'h2};
       }


       cp_write_sresp_resperr   : coverpoint write_sresp_resperr {
           bins SRESP_RESPERR_OK                    = {2'h0};
           illegal_bins SRESP_RESPERR_EXOK          = {2'h1};
           illegal_bins SRESP_RESPERR_DERR          = {2'h2};
           illegal_bins SRESP_RESPERR_NDERR         = {2'h3};
       }

       cp_write_cresp_resperr   : coverpoint write_cresp_resperr {
           bins CRESP_RESPERR_OK            = {2'h0};
           bins CRESP_RESPERR_EXOK          = {2'h1};
           bins CRESP_RESPERR_DERR          = {2'h2};
           bins CRESP_RESPERR_NDERR         = {2'h3};
       }

       cp_write_prev_cresp_resperr   : coverpoint write_prev_cresp_resperr {
           bins CRESP_RESPERR_OK                    = {2'h0};
           illegal_bins CRESP_RESPERR_EXOK          = {2'h1};
           illegal_bins CRESP_RESPERR_DERR          = {2'h2};
           illegal_bins CRESP_RESPERR_NDERR         = {2'h3};
       }

       cp_write_data_resperr   : coverpoint write_data_resperr {
           bins DATA_RESPERR_OK               = {2'h0};
         //ignore_bins DATA_RESPERR_EXOK      = {2'h1}; // need to check further
           illegal_bins DATA_RESPERR_EXOK     = {2'h1};
           bins DATA_RESPERR_DERR             = {2'h2};
           illegal_bins DATA_RESPERR_NDERR    = {2'h3}; 
         //ignore_bins DATA_RESPERR_NDERR     = {2'h3}; // need to check further
       }
     
      cp_write_comp_cresp: coverpoint write_crsp_opcode {
          bins COMP                   = {5'h4};
       }

      cp_write_dbid_cresp: coverpoint write_prev_crsp_opcode {
          bins DBIDRESP               = {5'h6};
       }

      cp_write_compdbid_cresp: coverpoint write_crsp_opcode {
          bins COMPDBIDRESP           = {5'h5};
       }


       write_req_cross_sresp : cross cp_write_req_type, cp_write_sresp, cp_write_sresp_resperr  {
        illegal_bins WRITEUNIQUEPTL_SRESP_RESPERR                 =  binsof (cp_write_req_type) intersect {7'h18} && binsof (cp_write_sresp_resperr) intersect {2'h1,2'h2,2'h3};
        illegal_bins WRITEUNIQUEFULL_SRESP_RESPERR                =  binsof (cp_write_req_type) intersect {7'h19} && binsof (cp_write_sresp_resperr) intersect {2'h1,2'h2,2'h3};
 
        ignore_bins WR_REQ_SRESP_RESPERR                          =  binsof (cp_write_req_type) intersect {7'h16,7'h1C,7'h1D,7'h1B,7'h1A,7'h17,7'h15};

       }

       //write_req_cross_dbid_cresp : cross cp_write_req_type, cp_write_dbid_cresp, cp_write_cresp_resperr  {
       write_req_cross_dbid_cresp : cross cp_write_req_type, cp_write_dbid_cresp, cp_write_prev_cresp_resperr  {
        illegal_bins WRITENOSNPPTL_DBID_RESPERR                 =  binsof (cp_write_req_type) intersect {7'h1C} && binsof (cp_write_prev_cresp_resperr) intersect {2'h1,2'h2,2'h3};
        illegal_bins WRITENOSNPFULL_DBID_RESPERR                =  binsof (cp_write_req_type) intersect {7'h1D} && binsof (cp_write_prev_cresp_resperr) intersect {2'h1,2'h2,2'h3};
        illegal_bins WRITEUNIQUEFULL_DBID_RESPERR               =  binsof (cp_write_req_type) intersect {7'h19} && binsof (cp_write_prev_cresp_resperr) intersect {2'h1,2'h2,2'h3};
        illegal_bins WRITEUNIQUEPTL_DBID_RESPERR                =  binsof (cp_write_req_type) intersect {7'h18} && binsof (cp_write_prev_cresp_resperr) intersect {2'h1,2'h2,2'h3};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
        illegal_bins WRITEEVICTOREVICT_DBID_RESPERR             =  binsof (cp_write_req_type) intersect {7'h42};
        <% } %>

        ignore_bins WR_REQ_DBID_RESPERR                         =  binsof (cp_write_req_type) intersect {7'h16,7'h1B,7'h1A,7'h17,7'h15};

       }

       write_req_cross_comp_cresp : cross cp_write_req_type, cp_write_comp_cresp, cp_write_cresp_resperr  {
        illegal_bins WRITEUNIQUEFULL_COMP_RESPERR               =  binsof (cp_write_req_type) intersect {7'h19} && binsof (cp_write_cresp_resperr) intersect {2'h1};
        illegal_bins WRITEUNIQUEPTL_COMP_RESPERR                =  binsof (cp_write_req_type) intersect {7'h18} && binsof (cp_write_cresp_resperr) intersect {2'h1};

        ignore_bins WR_REQ_COMP_RESPERR                         =  binsof (cp_write_req_type) intersect {7'h16,7'h1B,7'h1A,7'h17,7'h15};


        ignore_bins WRITEUNIQUEPTL_COMPDBID_DERR_RESPERR        =  binsof (cp_write_req_type) intersect {7'h18} && binsof (cp_write_cresp_resperr) intersect {2'h2}; //ncore err arch spec-1.7
        ignore_bins WRITEUNIQUEFULL_COMPDBID_DERR_RESPERR       =  binsof (cp_write_req_type) intersect {7'h19} && binsof (cp_write_cresp_resperr) intersect {2'h2};
       }

       write_req_cross_compdbid_cresp : cross cp_write_req_type, cp_write_compdbid_cresp, cp_write_cresp_resperr  {
        illegal_bins WRITEUNIQUEFULL_COMPDBID_RESPERR           =  binsof (cp_write_req_type) intersect {7'h19} && binsof (cp_write_cresp_resperr) intersect {2'h1};
        illegal_bins WRITEUNIQUEPTL_COMPDBID_RESPERR            =  binsof (cp_write_req_type) intersect {7'h18} && binsof (cp_write_cresp_resperr) intersect {2'h1};
        illegal_bins WRITEBACKPTL_COMPDBID_RESPERR              =  binsof (cp_write_req_type) intersect {7'h1B} && binsof (cp_write_cresp_resperr) intersect {2'h1};
        illegal_bins WRITEBACKFULL_COMPDBID_RESPERR             =  binsof (cp_write_req_type) intersect {7'h1A} && binsof (cp_write_cresp_resperr) intersect {2'h1};
        illegal_bins WRITECLEANFULL_COMPDBID_RESPERR            =  binsof (cp_write_req_type) intersect {7'h17} && binsof (cp_write_cresp_resperr) intersect {2'h1};
        illegal_bins WRITEEVICTFULL_COMPDBID_RESPERR            =  binsof (cp_write_req_type) intersect {7'h15} && binsof (cp_write_cresp_resperr) intersect {2'h1};

        ignore_bins WRITEEVICTFULL_COMPDBID_DERR_RESPERR        =  binsof (cp_write_req_type) intersect {7'h15} && binsof (cp_write_cresp_resperr) intersect {2'h2};// ncore err arch spec-1.7
        ignore_bins WRITECLEANFULL_COMPDBID_DERR_RESPERR        =  binsof (cp_write_req_type) intersect {7'h17} && binsof (cp_write_cresp_resperr) intersect {2'h2};
        ignore_bins WRITEBACKPTL_COMPDBID_DERR_RESPERR          =  binsof (cp_write_req_type) intersect {7'h1A} && binsof (cp_write_cresp_resperr) intersect {2'h2};
        ignore_bins WRITEBACKFULL_COMPDBID_DERR_RESPERR         =  binsof (cp_write_req_type) intersect {7'h1B} && binsof (cp_write_cresp_resperr) intersect {2'h2};

      //illegal_bins WRITE_NOSNP_UNQ_COMPDBID_RESPERR           =  binsof (cp_write_req_type) intersect {7'h1C,7'h1D,7'h18,7'h19}; // need to check further
        ignore_bins WRITE_NOSNP_UNQ_COMPDBID_RESPERR            =  binsof (cp_write_req_type) intersect {7'h1C,7'h1D,7'h18,7'h19};

        <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
        illegal_bins WRITECLEANPTL_COMPDBID_RESPERR             =  binsof (cp_write_req_type) intersect {7'h16} && binsof (cp_write_cresp_resperr) intersect {2'h1};
        ignore_bins WRITECLEANPTL_COMPDBID_RESPERR_DERR         =  binsof (cp_write_req_type) intersect {7'h16} && binsof (cp_write_cresp_resperr) intersect {2'h2};//data error on str_req is not supported in block level
        <% } %>
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
        illegal_bins WRITEEVICTOREVICT_COMPDBID_RESPERR         =  binsof (cp_write_req_type) intersect {7'h42};
        <% } %>

       }

       write_req_cross_data_resperr : cross cp_write_req_type, cp_write_data_resperr  {
        illegal_bins WRITEUNIQUEFULL_DATA_RESPERR           =  binsof (cp_write_req_type) intersect {7'h19} && binsof (cp_write_data_resperr) intersect {2'h1,2'h3};
        illegal_bins WRITEUNIQUEPTL_DATA_RESPERR            =  binsof (cp_write_req_type) intersect {7'h18} && binsof (cp_write_data_resperr) intersect {2'h1,2'h3};
        illegal_bins WRITEBACKPTL_DATA_RESPERR              =  binsof (cp_write_req_type) intersect {7'h1B} && binsof (cp_write_data_resperr) intersect {2'h1,2'h3};
        illegal_bins WRITEBACKFULL_DATA_RESPERR             =  binsof (cp_write_req_type) intersect {7'h1A} && binsof (cp_write_data_resperr) intersect {2'h1,2'h3};
        illegal_bins WRITECLEANFULL_DATA_RESPERR            =  binsof (cp_write_req_type) intersect {7'h17} && binsof (cp_write_data_resperr) intersect {2'h1,2'h3};
        illegal_bins WRITEEVICTFULL_DATA_RESPERR            =  binsof (cp_write_req_type) intersect {7'h15} && binsof (cp_write_data_resperr) intersect {2'h1,2'h3};

        <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
        illegal_bins WRITECLEANPTL_DATA_RESPERR             =  binsof (cp_write_req_type) intersect {7'h16} && binsof (cp_write_data_resperr) intersect {2'h1,2'h3};
        <% } %>
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
        ignore_bins WRITEEVICTOREVICT_DATA_RESPERR         =  binsof (cp_write_req_type) intersect {7'h42};
        <% } %>
       }

    endgroup

  <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    covergroup chi_atomic_req_err_resp_cg;

         cp_chi_atomic_store_type_req :  coverpoint atomic_type_opcode {
            bins ATOMICSTORE_STADD    = {7'h28};
            bins ATOMICSTORE_STCLR    = {7'h29};
            bins ATOMICSTORE_STEOR    = {7'h2A};
            bins ATOMICSTORE_STSET    = {7'h2B};
            bins ATOMICSTORE_STSMAX   = {7'h2C};
            bins ATOMICSTORE_STMIN    = {7'h2D};
            bins ATOMICSTORE_STUSMAX  = {7'h2E};
            bins ATOMICSTORE_STUMIN   = {7'h2F};

        }


         cp_chi_atomic_load_swap_cmpr_type_req :  coverpoint atomic_type_opcode {
            bins ATOMICLOAD_LDADD     = {7'h30};
            bins ATOMICLOAD_LDCLR     = {7'h31};
            bins ATOMICLOAD_LDEOR     = {7'h32};
            bins ATOMICLOAD_LDSET     = {7'h33};
            bins ATOMICLOAD_LDSMAX    = {7'h34};
            bins ATOMICLOAD_LDMIN     = {7'h35};
            bins ATOMICLOAD_LDUSMAX   = {7'h36};
            bins ATOMICLOAD_LDUMIN    = {7'h37};
            bins ATOMICSWAP           = {7'h38};
            bins ATOMICCOMPARE        = {7'h39};

         }


     /* cp_atomic_comp_cresp: coverpoint atomic_crsp_opcode {
          ignore_bins COMP                   = {5'h4};
       }*/

      cp_atomic_dbid_cresp: coverpoint atomic_crsp_opcode {
          bins DBIDRESP               = {5'h6};
       }

      cp_atomic_compdbid_cresp: coverpoint atomic_crsp_opcode {
          bins COMPDBIDRESP           = {5'h5};
       }

       cp_atomic_data_resperr   : coverpoint atomic_data_resperr {
           bins DATA_RESPERR_OK                    = {2'h0};
         //ignore_bins DATA_RESPERR_EXOK           = {2'h1}; //need to check further
           illegal_bins DATA_RESPERR_EXOK          = {2'h1}; 
           bins DATA_RESPERR_DERR                  = {2'h2};
           illegal_bins DATA_RESPERR_NDERR         = {2'h3};
         //ignore_bins DATA_RESPERR_NDERR          = {2'h3}; //need to check further
       }

       cp_atomic_cresp_resperr   : coverpoint atomic_cresp_resperr {
           bins CRESP_RESPERR_OK                     = {2'h0};
           illegal_bins CRESP_RESPERR_EXOK           = {2'h1};
           ignore_bins CRESP_RESPERR_DERR            = {2'h2}; // Ncore Error Arch spec sec-1.7
         //bins CRESP_RESPERR_DERR                   = {2'h2}; 
           bins CRESP_RESPERR_NDERR                  = {2'h3};
       }

       /*atomic_store_req_cross_dbid_cresp : cross cp_chi_atomic_store_type_req, cp_atomic_dbid_cresp, cp_atomic_cresp_resperr  {
        illegal_bins ATOMIC_ST_DBID_RESPERR                 =  binsof (cp_chi_atomic_store_type_req) intersect {[7'h28:7'h2F]} && binsof (cp_atomic_cresp_resperr) intersect {2'h1,2'h2,2'h3};
       }*/

       atomic_load_req_cross_dbid_cresp : cross cp_chi_atomic_load_swap_cmpr_type_req, cp_atomic_dbid_cresp, cp_atomic_cresp_resperr  {
        illegal_bins ATOMIC_LD_DBID_RESPERR                 =  binsof (cp_chi_atomic_load_swap_cmpr_type_req) intersect {[7'h30:7'h39]} && binsof (cp_atomic_cresp_resperr) intersect {2'h1,2'h2,2'h3};
       }

      /* atomic_store_req_cross_comp_cresp : cross cp_chi_atomic_store_type_req, cp_atomic_comp_cresp, cp_atomic_cresp_resperr  {
        illegal_bins ATOMIC_ST_COMP_RESPERR                 =  binsof (cp_chi_atomic_store_type_req) intersect {[7'h28:7'h2F]} && binsof (cp_atomic_cresp_resperr) intersect {2'h1};
       }*/

      /* atomic_load_req_cross_comp_cresp : cross cp_chi_atomic_load_swap_cmpr_type_req, cp_atomic_comp_cresp, cp_atomic_cresp_resperr  {
        illegal_bins ATOMIC_LD_COMP_RESPERR                 =  binsof (cp_chi_atomic_load_swap_cmpr_type_req) intersect {[7'h30:7'h39]} && binsof (cp_atomic_cresp_resperr) intersect {2'h1};
       }*/


       atomic_store_req_cross_compdbid_cresp : cross cp_chi_atomic_store_type_req, cp_atomic_compdbid_cresp, cp_atomic_cresp_resperr  {
        illegal_bins ATOMIC_ST_COMPDBID_RESPERR                 =  binsof (cp_chi_atomic_store_type_req) intersect {[7'h28:7'h2F]} && binsof (cp_atomic_cresp_resperr) intersect {2'h1};
       }

       atomic_store_req_cross_data_resperr : cross cp_chi_atomic_store_type_req, cp_atomic_data_resperr  {
        illegal_bins ATOMIC_ST_DATA_RESPERR                 =  binsof (cp_chi_atomic_store_type_req) intersect {[7'h28:7'h2F]} && binsof (cp_atomic_data_resperr) intersect {2'h1,2'h3};
       }

       atomic_load_req_cross_data_resperr : cross cp_chi_atomic_load_swap_cmpr_type_req, cp_atomic_data_resperr  {
        illegal_bins ATOMIC_LD_DATA_RESPERR                 =  binsof (cp_chi_atomic_load_swap_cmpr_type_req) intersect {[7'h30:7'h39]} && binsof (cp_atomic_data_resperr) intersect {2'h1,2'h3};
       }
    endgroup
 <% } %>

 <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    covergroup chi_atomic_req_compdata_err_resp_cg;

         cp_chi_atomic_load_swap_cmpr_type_req :  coverpoint atomic_load_type_opcode {
            bins ATOMICLOAD_LDADD     = {7'h30};
            bins ATOMICLOAD_LDCLR     = {7'h31};
            bins ATOMICLOAD_LDEOR     = {7'h32};
            bins ATOMICLOAD_LDSET     = {7'h33};
            bins ATOMICLOAD_LDSMAX    = {7'h34};
            bins ATOMICLOAD_LDMIN     = {7'h35};
            bins ATOMICLOAD_LDUSMAX   = {7'h36};
            bins ATOMICLOAD_LDUMIN    = {7'h37};
            bins ATOMICSWAP           = {7'h38};
            bins ATOMICCOMPARE        = {7'h39};

         }

         cp_chi_compdata_resp: coverpoint atomic_compdata_opcode {
            bins COMPDATA             = {5'h4};
         }

         cp_atomic_compdata_resperr   : coverpoint atomic_compdata_resperr {
           bins COMP_DATA_RESPERR_OK              = {2'h0};
           illegal_bins COMP_DATA_RESPERR_EXOK    = {2'h1};
           bins COMP_DATA_RESPERR_DERR            = {2'h2};
           bins COMP_DATA_RESPERR_NDERR           = {2'h3};
         }


       atomic_load_req_cross_compdata_resperr : cross cp_chi_atomic_load_swap_cmpr_type_req, cp_chi_compdata_resp, cp_atomic_compdata_resperr  {
          illegal_bins ATOMIC_LD_COMPDATA_RESPERR                 =  binsof (cp_chi_atomic_load_swap_cmpr_type_req) intersect {[7'h30:7'h39]} && binsof (cp_atomic_compdata_resperr) intersect {2'h1};
       }
    endgroup
 <% } %>



    covergroup chi_dvmop_req_err_resp_cg;

         cp_chi_dvmop_req :  coverpoint dvmop_opcode {
            bins DVMOP                = {7'h14};
         }

         cp_dvmop_comp_resperr   : coverpoint dvmop_comp_resperr {
           bins DVMOP_COMP_RESPERR_OK              	 = {2'h0};
           illegal_bins DVMOP_COMP_RESPERR_EXOK     	 = {2'h1};
           ignore_bins DVMOP_COMP_RESPERR_DERR      	 = {2'h2};
           bins DVMOP_COMP_RESPERR_NDERR            	 = {2'h3};
         }

         cp_dvmop_dbid_resperr   : coverpoint dvmop_dbid_resperr {
           bins DVMOP_DBID_RESPERR_OK            	= {2'h0};
           illegal_bins DVMOP_DBID_RESPERR_EXOK         = {2'h1};
           illegal_bins DVMOP_DBID_RESPERR_DERR         = {2'h2};
           illegal_bins DVMOP_DBID_RESPERR_NDERR        = {2'h3};
         }

      <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
         cp_dvmop_ncbwrdata_resperr   : coverpoint dvmop_ncbwrdata_resperr {
           bins DVMOP_NCBWRDATA_RESPERR_OK                = {2'h0};
           illegal_bins DVMOP_NCBWRDATA_RESPERR_EXOK      = {2'h1}; 
         //ignore_bins DVMOP_NCBWRDATA_RESPERR_EXOK       = {2'h1}; // need to check further 
           bins DVMOP_NCBWRDATA_RESPERR_DERR              = {2'h2};
           illegal_bins DVMOP_NCBWRDATA_RESPERR_NDERR     = {2'h3};
         //ignore_bins DVMOP_NCBWRDATA_RESPERR_NDERR      = {2'h3}; // need to check further
         }
      <% } else { %>
         cp_dvmop_ncbwrdata_resperr   : coverpoint dvmop_ncbwrdata_resperr {
           bins DVMOP_NCBWRDATA_RESPERR_OK                = {2'h0};
           illegal_bins DVMOP_NCBWRDATA_RESPERR_EXOK      = {2'h1};
         //ignore_bins DVMOP_NCBWRDATA_RESPERR_EXOK       = {2'h1}; // need to check further
           illegal_bins DVMOP_NCBWRDATA_RESPERR_DERR      = {2'h2};
           illegal_bins DVMOP_NCBWRDATA_RESPERR_NDERR     = {2'h3};
         //ignore_bins DVMOP_NCBWRDATA_RESPERR_NDERR      = {2'h3}; // need to check further
         }
      <% } %>

        cp_wdata_ncb_opcode: coverpoint dvm_wdata_opcode {
            bins NONCOPYBACKWRDATA         = {5'h3};
        }

         cp_dvmop_comp_cresp: coverpoint dvmop_crsp_opcode {
             bins COMP                   = {5'h4};
         }

         cp_dvmop_dbid_cresp: coverpoint dvmop_prev_crsp_opcode {
             bins DBIDRESP               = {5'h6};
         }

      <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
         dvmop_req_cross_comp_cresp : cross cp_chi_dvmop_req, cp_dvmop_comp_cresp, cp_dvmop_comp_resperr  {
          illegal_bins DVMOP_COMP_RESPERR                 =  binsof (cp_chi_dvmop_req) intersect {7'h14} && binsof (cp_dvmop_comp_resperr) intersect {2'h1};
         }
      <% } else { %>
         dvmop_req_cross_comp_cresp : cross cp_chi_dvmop_req, cp_dvmop_comp_cresp, cp_dvmop_comp_resperr  {
          illegal_bins DVMOP_COMP_EXOK_RESPERR            =  binsof (cp_chi_dvmop_req) intersect {7'h14} && binsof (cp_dvmop_comp_resperr) intersect {2'h1};
          ignore_bins DVMOP_COMP_DERR_RESPERR             =  binsof (cp_chi_dvmop_req) intersect {7'h14} && binsof (cp_dvmop_comp_resperr) intersect {2'h2};
          //illegal_bins DVMOP_COMP_DERR_RESPERR          =  binsof (cp_chi_dvmop_req) intersect {7'h14} && binsof (cp_dvmop_comp_resperr) intersect {2'h2}; //CONC-9570
         }
      <% } %>

         dvmop_req_cross_dbid_cresp : cross cp_chi_dvmop_req, cp_dvmop_dbid_cresp, cp_dvmop_dbid_resperr  {
          illegal_bins DVMOP_DBID_RESPERR                 =  binsof (cp_chi_dvmop_req) intersect {7'h14} && binsof (cp_dvmop_dbid_resperr) intersect {2'h1,2'h2,2'h3};
         }

      <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
         dvmop_req_cross_ncbdata_resperr : cross cp_chi_dvmop_req, cp_wdata_ncb_opcode, cp_dvmop_ncbwrdata_resperr  {
          illegal_bins DVMOP_WDATA_NCB_RESPERR                 =  binsof (cp_chi_dvmop_req) intersect {7'h14} && binsof (cp_dvmop_ncbwrdata_resperr) intersect {2'h1, 2'h3};
         }
     <% } else { %>
         dvmop_req_cross_ncbdata_resperr : cross cp_chi_dvmop_req, cp_wdata_ncb_opcode, cp_dvmop_ncbwrdata_resperr  {
          illegal_bins DVMOP_WDATA_NCB_RESPERR                 =  binsof (cp_chi_dvmop_req) intersect {7'h14} && binsof (cp_dvmop_ncbwrdata_resperr) intersect {2'h1,2'h2,2'h3};
         }
     <% } %>


    endgroup

    covergroup chi_snp_req_err_snpresp_cg;

         cp_chi_snp_req :  coverpoint snp_type_opcode {
            bins SNPSHARED              = {5'h1};
            bins SNPCLEAN               = {5'h2};
            bins SNPONCE                = {5'h3};
            bins SNPUNIQUE              = {5'h7};
            bins SNPCLEANSHARED         = {5'h8};
            bins SNPCLEANINVALID        = {5'h9};
            bins SNPMAKEINVALID         = {5'hA};
            bins SNPDVMOP        	= {5'hD};


           <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins SNPNSHDTY       = {5'h4};
            bins SNPUNQSTASH     = {5'h5};
            bins SNPMKINVSTASH   = {5'h6};
            bins SNPSTASHUNQ     = {5'hB};
            bins SNPSTASHSHRD    = {5'hC};
          <% } %>
         }

         cp_snpresp_resperr   : coverpoint snpresp_resperr {
           bins SNPRESP_RESPERR_OK              = {2'h0};
           illegal_bins SNPRESP_RESPERR_EXOK    = {2'h1};
           illegal_bins SNPRESP_RESPERR_DERR    = {2'h2};
           bins SNPRESP_RESPERR_NDERR           = {2'h3};
         }


        cp_snpresp_opcode: coverpoint snpresp_opcode {
            bins SNPRESP        = {5'h1};
        }


         snpreq_cross_snpresp_resperr : cross cp_chi_snp_req, cp_snpresp_opcode, cp_snpresp_resperr  {
          illegal_bins SNPONCE_SNPRESP_RESPERR                 =  binsof (cp_chi_snp_req) intersect {5'h3} && binsof (cp_snpresp_resperr) intersect {2'h1,2'h2};
          illegal_bins SNPCLEAN_SNPRESP_RESPERR                =  binsof (cp_chi_snp_req) intersect {5'h2} && binsof (cp_snpresp_resperr) intersect {2'h1,2'h2};
          illegal_bins SNPSHARED_SNPRESP_RESPERR               =  binsof (cp_chi_snp_req) intersect {5'h1} && binsof (cp_snpresp_resperr) intersect {2'h1,2'h2};
          illegal_bins SNPUNIQUE_SNPRESP_RESPERR               =  binsof (cp_chi_snp_req) intersect {5'h7} && binsof (cp_snpresp_resperr) intersect {2'h1,2'h2};
          illegal_bins SNPCLEANSHARED_SNPRESP_RESPERR          =  binsof (cp_chi_snp_req) intersect {5'h8} && binsof (cp_snpresp_resperr) intersect {2'h1,2'h2};
          illegal_bins SNPCLEANINVALID_SNPRESP_RESPERR         =  binsof (cp_chi_snp_req) intersect {5'h9} && binsof (cp_snpresp_resperr) intersect {2'h1,2'h2};
          illegal_bins SNPMAKEINVALID_SNPRESP_RESPERR          =  binsof (cp_chi_snp_req) intersect {5'hA} && binsof (cp_snpresp_resperr) intersect {2'h1,2'h2};
          illegal_bins SNPDVMOP_SNPRESP_RESPERR                =  binsof (cp_chi_snp_req) intersect {5'hD} && binsof (cp_snpresp_resperr) intersect {2'h1,2'h2};


         <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
          illegal_bins SNPUNQSTASH_SNPRESP_RESPERR             =  binsof (cp_chi_snp_req) intersect {5'h5} && binsof (cp_snpresp_resperr) intersect {2'h1,2'h2};
          illegal_bins SNPNSHDTY_SNPRESP_RESPERR               =  binsof (cp_chi_snp_req) intersect {5'h4} && binsof (cp_snpresp_resperr) intersect {2'h1,2'h2};
          illegal_bins SNPSTASHUNQ_SNPRESP_RESPERR             =  binsof (cp_chi_snp_req) intersect {5'hB} && binsof (cp_snpresp_resperr) intersect {2'h1,2'h2};
          illegal_bins SNPSTASHSHRD_SNPRESP_RESPERR            =  binsof (cp_chi_snp_req) intersect {5'hC} && binsof (cp_snpresp_resperr) intersect {2'h1,2'h2};
          illegal_bins SNPMKINVSTASH_SNPRESP_RESPERR           =  binsof (cp_chi_snp_req) intersect {5'h6} && binsof (cp_snpresp_resperr) intersect {2'h1,2'h2};
         <% } %>

         }

    endgroup

    covergroup chi_snp_req_err_snprespdata_cg;

         cp_chi_snp_req :  coverpoint snoop_type_opcode {
            bins SNPSHARED              = {5'h1};
            bins SNPCLEAN               = {5'h2};
            bins SNPONCE                = {5'h3};
            bins SNPUNIQUE              = {5'h7};
            bins SNPCLEANSHARED         = {5'h8};
            bins SNPCLEANINVALID        = {5'h9};

           <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins SNPNSHDTY       = {5'h4};
            bins SNPUNQSTASH     = {5'h5};
           <% } %>

         }

         cp_snprespdata_resperr   : coverpoint snprespdata_resperr {
           bins SNPRESPDATA_RESPERR_OK                = {2'h0};
           illegal_bins SNPRESPDATA_RESPERR_EXOK      = {2'h1};
           bins SNPRESPDATA_RESPERR_DERR              = {2'h2};
           illegal_bins SNPRESPDATA_RESPERR_NDERR     = {2'h3};
         }

        cp_snprespdata_opcode: coverpoint snprespdata_opcode {
            bins SNPRESPDATA         = {4'h1};
        }


         snpreq_cross_snprespdata_resperr : cross cp_chi_snp_req, cp_snprespdata_opcode, cp_snprespdata_resperr  {
          illegal_bins SNPONCE_SNPRESPDATA_RESPERR                 =  binsof (cp_chi_snp_req) intersect {5'h3} && binsof (cp_snprespdata_resperr) intersect {2'h1,2'h3};
          illegal_bins SNPCLEAN_SNPRESPDATA_RESPERR                =  binsof (cp_chi_snp_req) intersect {5'h2} && binsof (cp_snprespdata_resperr) intersect {2'h1,2'h3};
          illegal_bins SNPSHARED_SNPRESPDATA_RESPERR               =  binsof (cp_chi_snp_req) intersect {5'h1} && binsof (cp_snprespdata_resperr) intersect {2'h1,2'h3};
          illegal_bins SNPUNIQUE_SNPRESPDATA_RESPERR               =  binsof (cp_chi_snp_req) intersect {5'h7} && binsof (cp_snprespdata_resperr) intersect {2'h1,2'h3};
          illegal_bins SNPCLEANSHARED_SNPRESPDATA_RESPERR          =  binsof (cp_chi_snp_req) intersect {5'h8} && binsof (cp_snprespdata_resperr) intersect {2'h1,2'h3};
          illegal_bins SNPCLEANINVALID_SNPRESPDATA_RESPERR         =  binsof (cp_chi_snp_req) intersect {5'h9} && binsof (cp_snprespdata_resperr) intersect {2'h1,2'h3};

         <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
          illegal_bins SNPUNQSTASH_SNPRESPDATA_RESPERR             =  binsof (cp_chi_snp_req) intersect {5'h5} && binsof (cp_snprespdata_resperr) intersect {2'h1,2'h3};
          illegal_bins SNPNSHDTY_SNPRESPDATA_RESPERR               =  binsof (cp_chi_snp_req) intersect {5'h4} && binsof (cp_snprespdata_resperr) intersect {2'h1,2'h3};
         <% } %>

         }

    endgroup


    covergroup chi_wr_req_resp;

      cp_check_wr_req_type: coverpoint req_opcode {
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            bins WRITECLEANPTL        	      = {7'h16};
            <% } %>
            bins WRITENOSNPPTL                = {7'h1C}; 
            bins WRITENOSNPFULL               = {7'h1D}; 
            bins WRITEUNIQUEPTL               = {7'h18}; 
           <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins WRITEUNIQUEPTLSTASH   = {7'h21};
            ignore_bins WRITEUNIQUEFULLSTASH  = {7'h20};
            <% } %>
            bins WRITEUNIQUEFULL              = {7'h19};
            bins WRITEBACKFULL                = {7'h1B};
            bins WRITEBACKPTL                 = {7'h1A};
            bins WRITECLEANFULL               = {7'h17};
            bins WRITEEVICTFULL               = {7'h15};
          }


      cp_check_wr_cresp: coverpoint cresp_opcode {
            bins COMP                   = {5'h4};
            bins COMPDBIDRESP           = {5'h5};
            ignore_bins DBIDRESP        = {5'h6};
        }


        cp_wr_comp_cresp: coverpoint cresp_opcode {
            bins COMP                   = {5'h4};
        }

        cp_wr_compdbid_cresp: coverpoint cresp_opcode {
            bins COMPDBIDRESP           = {5'h5};
        }

       /* cp_wr_dbid_cresp: coverpoint cresp_opcode {
            bins DBIDRESP               = {5'h6};
        }*/


        cp_prev_wr_dbid_cresp: coverpoint prev_cresp_opcode {
            bins DBIDRESP               = {5'h6};
        }

        cp_check_wrcopyback_resp: coverpoint wrcopyback_resp {
          bins CopyBackWrData_I          = {3'h0};
          bins CopyBackWrData_SC         = {3'h1};
          bins CopyBackWrData_UC         = {3'h2};
          bins CopyBackWrData_UD_PD      = {3'h6};
          bins CopyBackWrData_SD_PD      = {3'h7};
        }

        cp_check_noncopyback_resp: coverpoint noncopyback_resp {
          bins NonCopyBackWrData_I          = {3'h0};
        }
        cp_check_noncopybackcombined_resp: coverpoint ncbwrcompack_resp {
          bins NCBWrDataCompAck_I           = {3'h0};
        }

        cp_check_wdata_opcode: coverpoint wdata_opcode {
           ignore_bins DATALCRDRETURN            = {4'h0};
           ignore_bins SNPRESPDATA               = {4'h1};
           bins COPYBACKWRDATA                   = {4'h2};
           bins NONCOPYBACKWRDATA                = {4'h3};
           ignore_bins SNPRESPDATAPTL            = {4'h5};
           illegal_bins COMPDATA                 = {4'h4};
          <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
           ignore_bins SNPRESPDATAFWDED          = {4'h6};
           bins WRDATACANCEL                     = {4'h7};
          <% } %>
          <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
           bins NCBWRDATACOMPACK                 = {4'hC};
          <% } %>
        }

        check_wr_req_type_cross_wr_copyback_resp: cross cp_check_wr_req_type, cp_check_wdata_opcode, cp_check_wrcopyback_resp, cp_check_wr_cresp{
          //ignore_bins IGNR_WR_NO_SNP_UNQ            =  binsof (cp_check_wr_req_type) intersect {'h1C,'h1D,'h18,'h21,'h19,'h20} && binsof (cp_check_wdata_opcode) intersect {'h00,'h01,'h03,'h05,'h07} && binsof (cp_check_wrcopyback_resp) intersect {'h00,'h01,'h02,'h06,'h07} && binsof (cp_check_wr_cresp) intersect {'h04,'h06} ;
          //ignore_bins IGNR_WR_BACK_RESP_1           =       binsof (cp_check_wr_req_type) intersect {'h1A}  && binsof (cp_check_wrcopyback_resp) intersect {'h01,'h02,'h07}  ;
          //ignore_bins IGNR_WR_BACK_RESP_2           =       binsof (cp_check_wr_req_type) intersect {'h15}  && binsof (cp_check_wrcopyback_resp) intersect {'h06,'h07}  ;
          //ignore_bins IGNR_WR_DAT_OPCODE            =       binsof (cp_check_wdata_opcode) intersect {'h00,'h01,'h03,'h05,'h07};
          //ignore_bins IGNR_WR_CRESP                 =       binsof (cp_check_wr_cresp) intersect {'h04,'h06};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
          ignore_bins IGNR_WR_REQ_CMD                 =       binsof (cp_check_wr_req_type) intersect {7'h1C,7'h1D,7'h18,7'h21,7'h19,7'h20};
          <% } else { %>
          ignore_bins IGNR_WR_REQ_CMD                 =       binsof (cp_check_wr_req_type) intersect {7'h1C,7'h1D,7'h18,7'h19};
          <% } %>
          ignore_bins IGNR_WR_DAT_OPCODE              =       binsof (cp_check_wdata_opcode) intersect {4'h0,4'h1,4'h3,4'h5,4'h7};
          <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
          illegal_bins WRCLEANPTL_RESP                =       binsof (cp_check_wr_req_type) intersect {7'h16}  && binsof (cp_check_wrcopyback_resp) intersect {3'h1,3'h2,3'h7}  ;
          illegal_bins WRCLEANPTL_CRESP               =       binsof (cp_check_wr_req_type) intersect {7'h16}  && binsof (cp_check_wr_cresp) intersect {5'h4,5'h6};
          //illegal_bins WRITEEVICTFULL_CRESP           =       binsof (cp_check_wr_req_type) intersect {'h15}  && binsof (cp_check_wr_cresp) intersect {'h05,'h06};
          <% } %>
          illegal_bins WRBACKPTL_RESP                 =       binsof (cp_check_wr_req_type) intersect {7'h1A}  && binsof (cp_check_wrcopyback_resp) intersect {3'h1,3'h2,3'h7}  ;
          illegal_bins WRBACKEVICTFULL_RESP           =       binsof (cp_check_wr_req_type) intersect {7'h15}  && binsof (cp_check_wrcopyback_resp) intersect {3'h6,3'h7}  ;
          illegal_bins WR_REQ_DAT_OPCODE              =       binsof (cp_check_wr_req_type) intersect {7'h15,7'h17,7'h1A,7'h1B} && binsof (cp_check_wdata_opcode) intersect {4'h0,4'h1,4'h3,4'h5,4'h7};

          illegal_bins WRITECLEANFULL_CRESP           =       binsof (cp_check_wr_req_type) intersect {7'h17} && binsof (cp_check_wr_cresp) intersect {5'h4,5'h6};
          illegal_bins WRITEBACKPTL_CRESP             =       binsof (cp_check_wr_req_type) intersect {7'h1A} && binsof (cp_check_wr_cresp) intersect {5'h4,5'h6};
          illegal_bins WRITEBACKFULL_CRESP            =       binsof (cp_check_wr_req_type) intersect {7'h1B} && binsof (cp_check_wr_cresp) intersect {5'h4,5'h6};
          illegal_bins WRITEEVICTFULL_CRESP           =       binsof (cp_check_wr_req_type) intersect {7'h15} && binsof (cp_check_wr_cresp) intersect {5'h4,5'h6};

        }

       wr_req_x_noncopyback_comp_plus_dbid_cresp: cross cp_check_wr_req_type, cp_check_wdata_opcode, cp_check_noncopyback_resp, cp_wr_comp_cresp, cp_prev_wr_dbid_cresp {
          ignore_bins NON_CPBCK_WR_DAT_OPCODE         =  binsof (cp_check_wdata_opcode) intersect {4'h0,4'h1,4'h2,4'h5};
          ignore_bins WR_REQ_CMD                      =  binsof (cp_check_wr_req_type) intersect {7'h15,7'h17,7'h1A,7'h1B};
          illegal_bins WR_NO_SNP_UNQ_PTL_WDATA        =  binsof (cp_check_wr_req_type) intersect {7'h1C,7'h18} && binsof (cp_check_wdata_opcode) intersect {4'h0,4'h1,4'h2,4'h5};
          illegal_bins WR_NO_SNP_FULL_WDATA           =  binsof (cp_check_wr_req_type) intersect {7'h1D} && binsof (cp_check_wdata_opcode) intersect {4'h0,4'h1,4'h2,4'h5,4'h7};
          illegal_bins WR_UNQ_FULL_WDATA              =  binsof (cp_check_wr_req_type) intersect {7'h19} && binsof (cp_check_wdata_opcode) intersect {4'h0,4'h1,4'h2,4'h5,4'h7};
          illegal_bins WRCLEANPTL_WDATA               =  binsof (cp_check_wr_req_type) intersect {7'h16} && binsof (cp_prev_wr_dbid_cresp) intersect {5'h6}  ;
        }

    endgroup


    covergroup chi_rd_req_resp;
         cp_chi_rd_req_type: coverpoint rd_req_opcode {
            bins READCLEAN                  = {7'h02};
            bins READSHARED                 = {7'h01};
            bins READUNIQUE                 = {7'h07}; 
            bins READNOSNP                  = {7'h04};
            bins READONCE                   = {7'h03};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins READNOTSHAREDDIRTY         = {7'h26}; 
            bins READONCECLEANINVALID       = {7'h24};
            bins READONCEMAKEINVALID        = {7'h25};
        <% } %>
          }
          cp_chi_compdata_resp: coverpoint compdata_resp {
            bins COMPDATA_I          = {3'h0};
            bins COMPDATA_SC         = {3'h1};
            bins COMPDATA_UC         = {3'h2};
            bins COMPDATA_UD_PD      = {3'h6};
            bins COMPDATA_SD_PD      = {3'h7};
        //  ignore_bins UNUSED_3_5   = {3'h3 : 3'h5]};
         // ignore_bins UNUSED_7_ALL = {[3'h7 : $]};
        }
        rd_req_type_cross_compdata_resp: cross cp_chi_rd_req_type, cp_chi_compdata_resp {

        <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
          illegal_bins READONCE_COMPDATA                 =  binsof (cp_chi_rd_req_type) intersect {7'h03} && binsof (cp_chi_compdata_resp) intersect {3'h1,3'h2,3'h6,3'h7};
          illegal_bins READNOSNP_COMPDATA                =  binsof (cp_chi_rd_req_type) intersect {7'h04} && binsof (cp_chi_compdata_resp) intersect {3'h1,3'h2,3'h6,3'h7};
          <% } else { %>
          //illegal_bins READONCE_COMPDATA                 =  binsof (cp_chi_rd_req_type) intersect {7'h03} && binsof (cp_chi_compdata_resp) intersect {3'h1,3'h6,3'h7};
          //illegal_bins READNOSNP_COMPDATA                =  binsof (cp_chi_rd_req_type) intersect {7'h04} && binsof (cp_chi_compdata_resp) intersect {3'h1,3'h6,3'h7};
          illegal_bins READONCE_COMPDATA                 =  binsof (cp_chi_rd_req_type) intersect {7'h03} && binsof (cp_chi_compdata_resp) intersect {3'h1,3'h2,3'h6,3'h7};
          illegal_bins READNOSNP_COMPDATA                =  binsof (cp_chi_rd_req_type) intersect {7'h04} && binsof (cp_chi_compdata_resp) intersect {3'h1,3'h2,3'h6,3'h7};
          //ignore_bins READNOSNP_COMPDATA                =  binsof (cp_chi_rd_req_type) intersect {7'h04} && binsof (cp_chi_compdata_resp) intersect {3'h1,3'h6,3'h7};
          <% } %>

        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
          //illegal_bins READONCECLEANINVALID_COMPDATA     =  binsof (cp_chi_rd_req_type) intersect {7'h24} && binsof (cp_chi_compdata_resp) intersect {'h1,'h6,'h7};
          //illegal_bins READONCEMAKEINVALID_COMPDATA      =  binsof (cp_chi_rd_req_type) intersect {7'h25} && binsof (cp_chi_compdata_resp) intersect {'h01,'h06,'h7};
          illegal_bins READONCECLEANINVALID_COMPDATA     =  binsof (cp_chi_rd_req_type) intersect {7'h24} && binsof (cp_chi_compdata_resp) intersect {3'h1,3'h2,3'h6,3'h7};
          illegal_bins READONCEMAKEINVALID_COMPDATA      =  binsof (cp_chi_rd_req_type) intersect {7'h25} && binsof (cp_chi_compdata_resp) intersect {3'h1,3'h2,3'h6,3'h7};
          illegal_bins READNOTSHAREDDIRTY_COMPDATA       =  binsof (cp_chi_rd_req_type) intersect {7'h26} && binsof (cp_chi_compdata_resp) intersect {3'h0,3'h7};
        <% } %>

          illegal_bins READCLEAN_COMPDATA                =  binsof (cp_chi_rd_req_type) intersect {7'h02} && binsof (cp_chi_compdata_resp) intersect {3'h0,3'h6,3'h7};
          illegal_bins READSHARED_COMPDATA               =  binsof (cp_chi_rd_req_type) intersect {7'h01} && binsof (cp_chi_compdata_resp) intersect {3'h0};
          illegal_bins READUNIQUE_COMPDATA               =  binsof (cp_chi_rd_req_type) intersect {7'h07} && binsof (cp_chi_compdata_resp) intersect {3'h0,3'h1,3'h7};
        }
    endgroup

    covergroup chi_dataless_req_resp;
         cp_chi_dataless_req_type: coverpoint dataless_req_opcode {
            bins CLEANUNIQUE                  = {7'h0B};
            bins MAKEUNIQUE                   = {7'h0C}; 
            bins EVICT                        = {7'h0D};
            bins CLEANSHARED                  = {7'h08};
            bins CLEANINVALID                 = {7'h09};
            bins MAKEINVALID                  = {7'h0A};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins CLEANSHAREDPERSIST           = {7'h27};
            bins STASHONCEUNIQUE              = {7'h23}; 
            bins STASHONCESHARED              = {7'h22};
        <% } %>
          }

      cp_chi_dataless_cresp: coverpoint dataless_crsp_opcode {
            bins COMP                           = {5'h4};
            illegal_bins COMPDBIDRESP           = {5'h5};
            illegal_bins DBIDRESP               = {5'h6};
          }


       cp_chi_dataless_resp: coverpoint dataless_cresp_resp {
          bins COMP_I              = {3'h0};
          ignore_bins COMP_SC      = {3'h1};
          bins COMP_UC             = {3'h2};
          ignore_bins UNUSED_3_ALL = {[3'h3 : $]};
        }

        dataless_req_type_cross_comp_resp: cross cp_chi_dataless_req_type, cp_chi_dataless_cresp, cp_chi_dataless_resp {
          illegal_bins CLEANUNIQUE_CRESP                  =  binsof (cp_chi_dataless_req_type) intersect {7'h0B} && binsof (cp_chi_dataless_cresp) intersect {5'h5,5'h6};
          illegal_bins MAKEUNIQUE_CRESP                   =  binsof (cp_chi_dataless_req_type) intersect {7'h0C} && binsof (cp_chi_dataless_cresp) intersect {5'h5,5'h6};
          illegal_bins EVICT_CRESP                        =  binsof (cp_chi_dataless_req_type) intersect {7'h0D} && binsof (cp_chi_dataless_cresp) intersect {5'h5,5'h6};
          illegal_bins CLEANSHARED_CRESP                  =  binsof (cp_chi_dataless_req_type) intersect {7'h08} && binsof (cp_chi_dataless_cresp) intersect {5'h5,5'h6};
          illegal_bins CLEANINVALID_CRESP                 =  binsof (cp_chi_dataless_req_type) intersect {7'h09} && binsof (cp_chi_dataless_cresp) intersect {5'h5,5'h6};
          illegal_bins MAKEINVALID_CRESP                  =  binsof (cp_chi_dataless_req_type) intersect {7'h0A} && binsof (cp_chi_dataless_cresp) intersect {5'h5,5'h6};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
          illegal_bins CLEANSHAREDPERSIST_CRESP           =  binsof (cp_chi_dataless_req_type) intersect {7'h27} && binsof (cp_chi_dataless_cresp) intersect {5'h5,5'h6};
          illegal_bins STASHONCEUNIQUE_CRESP              =  binsof (cp_chi_dataless_req_type) intersect {7'h23} && binsof (cp_chi_dataless_cresp) intersect {5'h5,5'h6};
          illegal_bins STASHONCESHARED_CRESP              =  binsof (cp_chi_dataless_req_type) intersect {7'h22} && binsof (cp_chi_dataless_cresp) intersect {5'h5,5'h6};
        <% } %>


          illegal_bins CLEANINVALID_CRESP_RESP                 =  binsof (cp_chi_dataless_req_type) intersect {7'h09} && binsof (cp_chi_dataless_resp) intersect {3'h1,3'h2};
          illegal_bins MAKEINVALID_CRESP_RESP                  =  binsof (cp_chi_dataless_req_type) intersect {7'h0A} && binsof (cp_chi_dataless_resp) intersect {3'h1,3'h2};
          illegal_bins EVICT_CRESP_RESP                        =  binsof (cp_chi_dataless_req_type) intersect {7'h0D} && binsof (cp_chi_dataless_resp) intersect {3'h1,3'h2};
          illegal_bins CLEANUNIQUE_CRESP_RESP                  =  binsof (cp_chi_dataless_req_type) intersect {7'h0B} && binsof (cp_chi_dataless_resp) intersect {3'h0,3'h1};
          illegal_bins MAKEUNIQUE_CRESP_RESP                   =  binsof (cp_chi_dataless_req_type) intersect {7'h0C} && binsof (cp_chi_dataless_resp) intersect {3'h0,3'h1};
          illegal_bins CLEANSHARED_CRESP_RESP                  =  binsof (cp_chi_dataless_req_type) intersect {7'h08} && binsof (cp_chi_dataless_resp) intersect {3'h1,3'h2};
        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
          illegal_bins STASHONCESHARED_CRESP_RESP              =  binsof (cp_chi_dataless_req_type) intersect {7'h22} && binsof (cp_chi_dataless_resp) intersect {3'h1,3'h2};
          illegal_bins STASHONCEUNIQUE_CRESP_RESP              =  binsof (cp_chi_dataless_req_type) intersect {7'h23} && binsof (cp_chi_dataless_resp) intersect {3'h1,3'h2};
          illegal_bins CLEANSHAREDPERSIST_CRESP_RESP           =  binsof (cp_chi_dataless_req_type) intersect {7'h27} && binsof (cp_chi_dataless_resp) intersect {3'h1,3'h2};
        <% } %>

        }
    endgroup

        <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
       covergroup chi_atomic_req_resp;
         cp_chi_atomic_store_req :  coverpoint atomic_req_opcode {
            bins ATOMICSTORE_STADD    = {7'h28};
            bins ATOMICSTORE_STCLR    = {7'h29};
            bins ATOMICSTORE_STEOR    = {7'h2A};
            bins ATOMICSTORE_STSET    = {7'h2B};
            bins ATOMICSTORE_STSMAX   = {7'h2C};
            bins ATOMICSTORE_STMIN    = {7'h2D};
            bins ATOMICSTORE_STUSMAX  = {7'h2E};
            bins ATOMICSTORE_STUMIN   = {7'h2F};

        }


         cp_chi_atomic_load_swap_cmpr_req :  coverpoint atomic_req_opcode {
            bins ATOMICLOAD_LDADD     = {7'h30};
            bins ATOMICLOAD_LDCLR     = {7'h31};
            bins ATOMICLOAD_LDEOR     = {7'h32};
            bins ATOMICLOAD_LDSET     = {7'h33};
            bins ATOMICLOAD_LDSMAX    = {7'h34};
            bins ATOMICLOAD_LDMIN     = {7'h35};
            bins ATOMICLOAD_LDUSMAX   = {7'h36};
            bins ATOMICLOAD_LDUMIN    = {7'h37};
            bins ATOMICSWAP           = {7'h38};
            bins ATOMICCOMPARE        = {7'h39};

         }

        cp_chi_atomic_wdata_opcode: coverpoint atomic_wdata_opcode {
            ignore_bins DATALCRDRETURN            = {4'h0};
            ignore_bins SNPRESPDATA               = {4'h1};
            ignore_bins COPYBACKWRDATA            = {4'h2};
            bins NONCOPYBACKWRDATA         	  = {4'h3};
            illegal_bins COMPDATA          	  = {4'h4};
            ignore_bins SNPRESPDATAPTL            = {4'h5};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins SNPRESPDATAFWDED          = {4'h6};
            ignore_bins WRDATACANCEL              = {4'h7};
            <% } %>
        }
        cp_chi_atomic_noncopyback_resp: coverpoint atomic_noncopyback_resp {
          bins NonCopyBackWrData_I          = {3'h0};
        }

        cp_chi_atomic_comp_resp: coverpoint atomic_cresp_resp {
          bins COMP_I                     = {3'h0};
          ignore_bins COMP_SC             = {3'h1};
          ignore_bins COMP_UC             = {3'h2};
          ignore_bins UNUSED_3_ALL 	  = {[3'h3 : $]};
        }


        cp_chi_atomic_wr_cresp: coverpoint atomic_cresp_opcode {
            illegal_bins COMP           = {5'h4};
            bins COMPDBIDRESP           = {5'h5};
            bins DBIDRESP               = {5'h6};
        }


        cp_chi_atomic_compdata_resp: coverpoint atomic_compdata_resp {
          bins COMPDATA_I          	  = {3'h0};
          ignore_bins COMPDATA_SC         = {3'h1};
          ignore_bins COMPDATA_UC         = {3'h2};
          ignore_bins COMPDATA_UD_PD      = {3'h6};
          ignore_bins COMPDATA_SD_PD      = {3'h7};
        //ignore_bins UNUSED_3_5   	  = {[3'h3 : 3'h5]};
        //ignore_bins UNUSED_7_ALL 	  = {[3'h7 : $]};
        }

       /* cp_atomic_st_req_x_dbid_plus_comp_resp: cross cp_chi_atomic_store_req, cp_chi_atomic_noncopyback_resp, cp_chi_atomic_wdata_opcode, cp_prev_atomic_dbid_cresp, cp_chi_atomic_comp_resp{
          illegal_bins ATOMIC_ST_REQ_WDAT_OPCODE        =  binsof (cp_chi_atomic_store_req) && binsof (cp_chi_atomic_wdata_opcode) intersect {4'h0,4'h1,4'h2,4'h5,4'h7};
          illegal_bins ATOMIC_ST_COMP_RESP              =  binsof (cp_chi_atomic_store_req) intersect {[7'h28 : 7'h2F]} && binsof (cp_chi_atomic_comp_resp) intersect {3'h1,3'h2};
         }*/

        cp_atomic_st_req_x_compdbid_resp: cross cp_chi_atomic_store_req, cp_chi_atomic_noncopyback_resp, cp_chi_atomic_wdata_opcode, cp_chi_atomic_wr_cresp {
          illegal_bins ATOMIC_ST_REQ_WDAT_OPCODE        =  binsof (cp_chi_atomic_store_req) && binsof (cp_chi_atomic_wdata_opcode) intersect {4'h0,4'h1,4'h2,4'h5,4'h7};
          illegal_bins ATOMIC_ST_CRESP_RESP             =  binsof (cp_chi_atomic_store_req) intersect {[7'h28 : 7'h2F]} && binsof (cp_chi_atomic_wr_cresp) intersect {5'h4,5'h6};
         }

        cp_atomic_ld_swap_cmpr_req_cross_resp: cross cp_chi_atomic_load_swap_cmpr_req, cp_chi_atomic_wdata_opcode, cp_chi_atomic_compdata_resp, cp_chi_atomic_wr_cresp{
          illegal_bins ATOMIC_LD_REQ_WDAT_OPCODE        =  binsof (cp_chi_atomic_load_swap_cmpr_req) && binsof (cp_chi_atomic_wdata_opcode) intersect {4'h0,4'h1,4'h2,4'h5,4'h7};
          illegal_bins ATOMIC_LD_REQ_COMPDATA_RESP      =  binsof (cp_chi_atomic_load_swap_cmpr_req) intersect {[7'h30 : 7'h39]} && binsof (cp_chi_atomic_wr_cresp) intersect {5'h4,5'h5};
          illegal_bins ATOMIC_LD_REQ_COMPDATA_RESP_1    =  binsof (cp_chi_atomic_load_swap_cmpr_req) intersect {[7'h30 : 7'h39]} && binsof (cp_chi_atomic_compdata_resp) intersect {3'h1,3'h2,3'h6,3'h7};
         }
           endgroup
        <% } %>

       covergroup chi_snp_req_resp;
        cp_chi_snp_opcode: coverpoint snp_opcode {
          <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
          ignore_bins SNPNSHDTY       = {5'h4};
          ignore_bins SNPUNQSTASH     = {5'h5};
          ignore_bins SNPMKINVSTASH   = {5'h6};
          ignore_bins SNPSTASHUNQ     = {5'hB};
          ignore_bins SNPSTASHSHRD    = {5'hC};
          <% } %>
           <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins SNPNSHDTY       = {5'h4};
            bins SNPUNQSTASH     = {5'h5};
          //bins SNPMKINVSTASH   = {5'h6};
            <% } %>
            bins SNPSHARED              = {5'h1};
            bins SNPCLEAN               = {5'h2};
            bins SNPONCE                = {5'h3};
            bins SNPUNIQUE              = {5'h7};
            bins SNPCLEANSHARED         = {5'h8};
            bins SNPCLEANINVALID        = {5'h9};
          //bins SNPMAKEINVALID         = {5'hA};
           <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins SNPSHRFWD       = {5'h11};
            ignore_bins SNPCLNFWD       = {5'h12};
            ignore_bins SNPONCEFWD      = {5'h13};
            ignore_bins SNPNOTSDFWD     = {5'h14};
            ignore_bins SNPUNQFWD       = {5'h17};
           <% } %>
        }

        cp_chi_snp_makeivalid_stash_opcode: coverpoint snp_opcode {
            bins SNPMAKEINVALID         = {5'hA};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins SNPMKINVSTASH   = {5'h6};
            bins SNPSTASHUNQ     = {5'hB};
            bins SNPSTASHSHRD    = {5'hC};
            <% } %>
        }

        cp_chi_snpresp: coverpoint chi_snp_resp {
          bins SnpResp_I              = {3'h0};
          bins SnpResp_SC             = {3'h1};
          bins SnpResp_UC             = {3'h2};
        //bins SnpResp_UD             = {3'h2};
         <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
          illegal_bins SnpResp_SD             = {3'h3};
         <% } else {%>
          bins SnpResp_SD             = {3'h3};
         <% } %>

        }

     /*   cp_chi_cmstatus_resp: coverpoint rv_rs_dc_dt_snf {
          bins SnpResp_I_Read         = {'h01};
          bins SnpResp_SC_Read        = {'h31};
          bins SnpResp_UC_or_SD_Read  = {'h21};
        //bins SnpResp_SD_Read        = {'h03};
        }*/



        cp_snp_req_type_cross_snp_resp: cross cp_chi_snp_opcode, cp_chi_snpresp {
           illegal_bins SNPONCE_SNPRESP                 =  binsof (cp_chi_snp_opcode) intersect {5'h3} && binsof (cp_chi_snpresp) intersect {3'h3};
           illegal_bins SNPSHARED_SNPRESP               =  binsof (cp_chi_snp_opcode) intersect {5'h1} && binsof (cp_chi_snpresp) intersect {3'h2,3'h3};
           illegal_bins SNPCLEAN_SNPRESP                =  binsof (cp_chi_snp_opcode) intersect {5'h2} && binsof (cp_chi_snpresp) intersect {3'h2,3'h3};
           illegal_bins SNPUNIQUE_SNPRESP               =  binsof (cp_chi_snp_opcode) intersect {5'h7} && binsof (cp_chi_snpresp) intersect {3'h1,3'h2,3'h3};
           illegal_bins SNPCLEANSHARED_SNPRESP          =  binsof (cp_chi_snp_opcode) intersect {5'h8} && binsof (cp_chi_snpresp) intersect {3'h3};
           illegal_bins SNPCLEANINVALID_SNPRESP         =  binsof (cp_chi_snp_opcode) intersect {5'h9} && binsof (cp_chi_snpresp) intersect {3'h1,3'h2,3'h3};


           illegal_bins SNPNSHDTY_SNPRESP               =  binsof (cp_chi_snp_opcode) intersect {5'h4} && binsof (cp_chi_snpresp) intersect {3'h2,3'h3};
           illegal_bins SNPUNQSTASH_SNPRESP             =  binsof (cp_chi_snp_opcode) intersect {5'h5} && binsof (cp_chi_snpresp) intersect {3'h1,3'h2,3'h3};
          // ignore_bins SNPSTASHUNQ_SNPRESP            =  binsof (cp_chi_snp_opcode) intersect {5'hB} && binsof (cp_chi_snpresp) intersect {3'h1,3'h2,3'h3};
          // ignore_bins SNPSTASHSHRD_SNPRESP           =  binsof (cp_chi_snp_opcode) intersect {5'hC} && binsof (cp_chi_snpresp) intersect {3'h1,3'h2,3'h3};
        }

        cp_snpmakeivld_stash_req_cross_snp_resp: cross cp_chi_snp_makeivalid_stash_opcode, cp_chi_snpresp {
           illegal_bins SNPMKINVSTASH_SNPRESP     =  binsof (cp_chi_snp_makeivalid_stash_opcode) intersect {5'h6} && binsof (cp_chi_snpresp) intersect {3'h1,3'h2,3'h3};
           illegal_bins SNPMAKEINVALID_SNPRESP    =  binsof (cp_chi_snp_makeivalid_stash_opcode) intersect {5'hA} && binsof (cp_chi_snpresp) intersect {3'h1,3'h2,3'h3};
        }
       endgroup


       covergroup chi_snp_req_snprespdataptl;
        cp_chi_snoop_opcode: coverpoint snp_opcode {
          <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
          ignore_bins SNPNSHDTY       = {5'h4};
          ignore_bins SNPUNQSTASH     = {5'h5};
          ignore_bins SNPMKINVSTASH   = {5'h6};
          ignore_bins SNPSTASHUNQ     = {5'hB};
          ignore_bins SNPSTASHSHRD    = {5'hC};
          <% } %>
           <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins SNPNSHDTY       = {5'h4};
            bins SNPUNQSTASH     = {5'h5};
          //bins SNPMKINVSTASH   = {5'h6};
            <% } %>
            bins SNPSHARED              = {5'h1};
            bins SNPCLEAN               = {5'h2};
            bins SNPONCE                = {5'h3};
            bins SNPUNIQUE              = {5'h7};
            bins SNPCLEANSHARED         = {5'h8};
            bins SNPCLEANINVALID        = {5'h9};
          //bins SNPMAKEINVALID         = {5'hA};
           <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins SNPSHRFWD       = {5'h11};
            ignore_bins SNPCLNFWD       = {5'h12};
            ignore_bins SNPONCEFWD      = {5'h13};
            ignore_bins SNPNOTSDFWD     = {5'h14};
            ignore_bins SNPUNQFWD       = {5'h17};
           <% } %>
        }

        cp_chi_snpdataptl_resp: coverpoint chi_snp_dataptl_resp {
          bins SnpRespDataPtl_I_PD              = {3'h4};
          bins SnpRespDataPtl_UD                = {3'h2};
        }

            
        cp_snp_req_type_cross_snpdataptl_resp: cross cp_chi_snoop_opcode, cp_chi_snpdataptl_resp {
        illegal_bins SNPSHARED_SNPRESPDATAPTL               =  binsof (cp_chi_snoop_opcode) intersect {5'h1} && binsof (cp_chi_snpdataptl_resp) intersect {3'h2};
        illegal_bins SNPCLEAN_SNPRESPDATAPTL                =  binsof (cp_chi_snoop_opcode) intersect {5'h2} && binsof (cp_chi_snpdataptl_resp) intersect {3'h2};
        illegal_bins SNPUNIQUE_SNPRESPDATAPTL               =  binsof (cp_chi_snoop_opcode) intersect {5'h7} && binsof (cp_chi_snpdataptl_resp) intersect {3'h2};
        illegal_bins SNPCLEANSHARED_SNPRESPDATAPTL          =  binsof (cp_chi_snoop_opcode) intersect {5'h8} && binsof (cp_chi_snpdataptl_resp) intersect {3'h2};
        illegal_bins SNPCLEANINVALID_SNPRESPDATAPTL         =  binsof (cp_chi_snoop_opcode) intersect {5'h9} && binsof (cp_chi_snpdataptl_resp) intersect {3'h2};


        illegal_bins SNPNSHDTY_SNPRESPDATAPTL               =  binsof (cp_chi_snoop_opcode) intersect {5'h4} && binsof (cp_chi_snpdataptl_resp) intersect {3'h2};
        illegal_bins SNPUNQSTASH_SNPRESPDATAPTL             =  binsof (cp_chi_snoop_opcode) intersect {5'h5} && binsof (cp_chi_snpdataptl_resp) intersect {3'h2};
        }

       endgroup


covergroup chi_snp_req_snprespdata;
        cp_chi_snpreq_opcode: coverpoint snp_opcode {
          <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
          ignore_bins SNPNSHDTY       = {5'h4};
          ignore_bins SNPUNQSTASH     = {5'h5};
          ignore_bins SNPMKINVSTASH   = {5'h6};
          ignore_bins SNPSTASHUNQ     = {5'hB};
          ignore_bins SNPSTASHSHRD    = {5'hC};
          <% } %>
           <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins SNPNSHDTY       = {5'h4};
            bins SNPUNQSTASH     = {5'h5};
          //bins SNPMKINVSTASH   = {5'h6};
            <% } %>
            bins SNPSHARED              = {5'h1};
            bins SNPCLEAN               = {5'h2};
            bins SNPONCE                = {5'h3};
            bins SNPUNIQUE              = {5'h7};
            bins SNPCLEANSHARED         = {5'h8};
            bins SNPCLEANINVALID        = {5'h9};
          //bins SNPMAKEINVALID         = {5'hA};
           <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins SNPSHRFWD       = {5'h11};
            ignore_bins SNPCLNFWD       = {5'h12};
            ignore_bins SNPONCEFWD      = {5'h13};
            ignore_bins SNPNOTSDFWD     = {5'h14};
            ignore_bins SNPUNQFWD       = {5'h17};
            <% } %>
        }


        cp_chi_snpdata_resp: coverpoint chi_snp_data_resp {
          bins SnpRespData_I              = {3'h0};
          bins SnpRespData_SC             = {3'h1};
          bins SnpRespData_UC_OR_UD       = {3'h2};
          bins SnpRespData_SD             = {3'h3};
          bins SnpRespData_I_PD           = {3'h4};
          bins SnpRespData_SC_PD          = {3'h5};
          bins SnpRespData_UC_PD          = {3'h6};

        }

        cp_snp_req_type_cross_snp_data_resp: cross cp_chi_snpreq_opcode, cp_chi_snpdata_resp {
          illegal_bins SNPONCE_SNPRESPDATA                  =  binsof (cp_chi_snpreq_opcode) intersect {5'h3} && binsof (cp_chi_snpdata_resp) intersect {3'h6};
          illegal_bins SNPSHARED_SNPRESPDATA                =  binsof (cp_chi_snpreq_opcode) intersect {5'h1} && binsof (cp_chi_snpdata_resp) intersect {3'h2,3'h6};
          illegal_bins SNPCLEAN_SNPRESPDATA                 =  binsof (cp_chi_snpreq_opcode) intersect {5'h2} && binsof (cp_chi_snpdata_resp) intersect {3'h2,3'h6};
          illegal_bins SNPUNIQUE_SNPRESPDATA                =  binsof (cp_chi_snpreq_opcode) intersect {5'h7} && binsof (cp_chi_snpdata_resp) intersect {3'h1,3'h2,3'h3,3'h5,3'h6};
          illegal_bins SNPCLEANSHARED_SNPRESPDATA           =  binsof (cp_chi_snpreq_opcode) intersect {5'h8} && binsof (cp_chi_snpdata_resp) intersect {3'h0,3'h1,3'h2,3'h3};
          illegal_bins SNPCLEANINVALID_SNPRESPDATA          =  binsof (cp_chi_snpreq_opcode) intersect {5'h9} && binsof (cp_chi_snpdata_resp) intersect {3'h0,3'h1,3'h2,3'h3,3'h5,3'h6};

          illegal_bins SNPNSHDTY_SNPRESPDATA                =  binsof (cp_chi_snpreq_opcode) intersect {5'h4} && binsof (cp_chi_snpdata_resp) intersect {3'h2,3'h6};
          illegal_bins SNPUNQSTASH_SNPRESPDATA              =  binsof (cp_chi_snpreq_opcode) intersect {5'h5} && binsof (cp_chi_snpdata_resp) intersect {3'h1,3'h2,3'h3,3'h5,3'h6};
        }
            

       endgroup


    covergroup req_cross_resp;
        chi_snp_rsp_delay: coverpoint snp_req_rsp_dly;
	chi_cmd_req_processed: coverpoint chi_cmd_req_latency {
                bins range_0     = {0};
		bins range_1     = {[129  :256]};
		bins range_2     = {[257  :512]};
		bins range_3     = {[513  :768]};
		bins range_4     = {[769  :1024]};
		bins range_5     = {[1025 :1280]};
		bins range_6     = {[1281 :1536]};
		bins range_7     = {[1537 :1792]};
		bins range_8     = {[1793 :2048]};
		bins range_9     = {[2049 :2304]};
		bins range_10    = {[2305 :2560]};
		bins range_11    = {[2561 :2816]};
		bins range_12    = {[2817 :3072]};
		bins range_13    = {[3073 :3328]};
		bins range_14    = {[3329 :3584]};
		bins range_15    = {[3585 :3840]};
		bins range_16    = {[3841 :4095]};
	
        }

        chi_snp_req_processed: coverpoint chi_snp_req_latency {
                bins range_0    = {0};
		bins range_1    = {[1:128]};
		bins range_2    = {[129:256]};
		bins range_3    = {[257:384]};
		bins range_4    = {[385:512]};
		bins range_5    = {[513:640]};
		bins range_6    = {[641:768]};
		bins range_7    = {[769:896]};
		bins range_8    = {[897:1023]};
	
        }
    endgroup

    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    covergroup chi_smi_sysco_states;
        option.name         = "SYSCO coverage at CHI-block level";
        option.comment      = "This coverage samples the sysco_state for incoming snoops from the TB perspective when the Txn sampled \
                               at SMI/CHI interface from respective monitor. RTL may had consume Txn during different sysco_state";
        option.per_instance = 1;
        option.goal         = 100;

        cp_smi_sysco_state: coverpoint smi_sysco_state{
          bins DISABLED   = {DISABLED  };
          bins CONNECT    = {CONNECT   };
          bins ENABLED    = {ENABLED   };
          bins DISCONNECT = {DISCONNECT};
        }
        cp_smi_dvm_part2_sysco_state: coverpoint smi_dvm_part2_sysco_state iff (isDVMSnoop){
          bins DISABLED   = {DISABLED  };
          bins CONNECT    = {CONNECT   };
          bins ENABLED    = {ENABLED   };
          bins DISCONNECT = {DISCONNECT};
        }
        cp_chi_sysco_state: coverpoint chi_sysco_state iff (!is_sysco_snp_returned && normal_stsh_snoop){
          illegal_bins DISABLED   = {DISABLED  };
          bins         CONNECT    = {CONNECT   }; // RTL will/won't? ignore_bins?
          bins         ENABLED    = {ENABLED   };
          bins         DISCONNECT = {DISCONNECT};
        }
        cp_chi_dvm_part2_sysco_state: coverpoint chi_dvm_part2_sysco_state iff (!is_sysco_snp_returned && isDVMSnoop){
          illegal_bins DISABLED   = {DISABLED  };
          bins         CONNECT    = {CONNECT   }; // RTL will/won't? ignore_bins?
          bins         ENABLED    = {ENABLED   };
          bins         DISCONNECT = {DISCONNECT};
        }
        cp_is_sysco_snp_returned: coverpoint is_sysco_snp_returned{
          bins RETURNED   = {1};
          bins PASSED_ON  = {0};
        }
        // normal smi_snoop
        Xcp_smi_snp1_vs_return: cross cp_smi_sysco_state, cp_is_sysco_snp_returned iff (!isDVMSnoop){
          // Spec says No
          illegal_bins ENABLED_x_RETURNED     = binsof (cp_smi_sysco_state) intersect {ENABLED}    && binsof (cp_is_sysco_snp_returned) intersect {1};
          illegal_bins DISABLED_x_PASSED_ON   = binsof (cp_smi_sysco_state) intersect {DISABLED}   && binsof (cp_is_sysco_snp_returned) intersect {0};
        }
        // normal chi_snoop
        Xcp_chi_snp1_vs_return: cross cp_chi_sysco_state, cp_is_sysco_snp_returned iff (!isDVMSnoop && normal_stsh_snoop){
          // Spec says No
          illegal_bins ENABLED_x_RETURNED     = binsof (cp_chi_sysco_state) intersect {ENABLED}    && binsof (cp_is_sysco_snp_returned) intersect {1};
          illegal_bins DISABLED_x_PASSED_ON   = binsof (cp_chi_sysco_state) intersect {DISABLED}   && binsof (cp_is_sysco_snp_returned) intersect {0};
        }
        // normal smi_chi_snoop
        Xcp_smi_snp1_vs_chi_snp1: cross cp_smi_sysco_state, cp_chi_sysco_state iff (!isDVMSnoop && !is_sysco_snp_returned && normal_stsh_snoop){
          illegal_bins ENABLED_x_DISABLED     = binsof (cp_smi_sysco_state) intersect {ENABLED, CONNECT, DISCONNECT}    && binsof (cp_chi_sysco_state) intersect {DISABLED};
        }
        Xcp_smi_dvm_part2_vs_return: cross cp_smi_dvm_part2_sysco_state, cp_is_sysco_snp_returned iff (isDVMSnoop){
          // Spec says No, but 2nd part can depends on the behaviour from the 1st part so not making them illegal from SMI side
          // illegal/ignore bins?
          illegal_bins ENABLED_x_RETURNED      = binsof (cp_smi_dvm_part2_sysco_state) intersect {ENABLED}    && binsof (cp_is_sysco_snp_returned) intersect {1};
          illegal_bins DISABLED_x_PASSED_ON    = binsof (cp_smi_dvm_part2_sysco_state) intersect {DISABLED}   && binsof (cp_is_sysco_snp_returned) intersect {0};
        }
        Xcp_smi_snp1_vs_snp2_sysco_state: cross cp_smi_sysco_state, cp_smi_dvm_part2_sysco_state iff (isDVMSnoop){
          bins ENABLED_x_ENABLED              = binsof (cp_smi_sysco_state) intersect {ENABLED}    && binsof (cp_smi_dvm_part2_sysco_state) intersect {ENABLED};
          bins ENABLED_x_DISCONNECT           = binsof (cp_smi_sysco_state) intersect {ENABLED}    && binsof (cp_smi_dvm_part2_sysco_state) intersect {DISCONNECT};
          bins DISABLED_x_DISABLED            = binsof (cp_smi_sysco_state) intersect {DISABLED}   && binsof (cp_smi_dvm_part2_sysco_state) intersect {DISABLED};
          bins DISABLED_x_CONNECT             = binsof (cp_smi_sysco_state) intersect {DISABLED}   && binsof (cp_smi_dvm_part2_sysco_state) intersect {CONNECT};
          bins CONNECT_x_CONNECT              = binsof (cp_smi_sysco_state) intersect {CONNECT}    && binsof (cp_smi_dvm_part2_sysco_state) intersect {CONNECT};
          bins CONNECT_x_ENABLED              = binsof (cp_smi_sysco_state) intersect {CONNECT}    && binsof (cp_smi_dvm_part2_sysco_state) intersect {ENABLED};
          bins DISCONNECT_x_DISCONNECT        = binsof (cp_smi_sysco_state) intersect {DISCONNECT} && binsof (cp_smi_dvm_part2_sysco_state) intersect {DISCONNECT};
          bins DISCONNECT_x_DISABLED          = binsof (cp_smi_sysco_state) intersect {DISCONNECT} && binsof (cp_smi_dvm_part2_sysco_state) intersect {DISABLED};

          // Not likely to follow by RTL , ignore or illegal?
          ignore_bins IGNR_ENABLED            = binsof (cp_smi_sysco_state) intersect {ENABLED}    && binsof (cp_smi_dvm_part2_sysco_state) intersect {DISABLED, CONNECT};
          ignore_bins IGNR_DISABLED           = binsof (cp_smi_sysco_state) intersect {DISABLED}   && binsof (cp_smi_dvm_part2_sysco_state) intersect {ENABLED, DISCONNECT};
          ignore_bins IGNR_CONNECT            = binsof (cp_smi_sysco_state) intersect {CONNECT}    && binsof (cp_smi_dvm_part2_sysco_state) intersect {DISABLED, DISCONNECT};
          ignore_bins IGNR_DISCONNECT         = binsof (cp_smi_sysco_state) intersect {DISCONNECT} && binsof (cp_smi_dvm_part2_sysco_state) intersect {CONNECT, ENABLED};
        }
        Xcp_chi_snp1_vs_snp2_sysco_state: cross cp_chi_sysco_state, cp_chi_dvm_part2_sysco_state iff (isDVMSnoop){
          bins ENABLED_x_ENABLED              = binsof (cp_chi_sysco_state) intersect {ENABLED}    && binsof (cp_chi_dvm_part2_sysco_state) intersect {ENABLED};
          bins ENABLED_x_DISCONNECT           = binsof (cp_chi_sysco_state) intersect {ENABLED}    && binsof (cp_chi_dvm_part2_sysco_state) intersect {DISABLED};
          bins DISCONNECT_x_DISCONNECT        = binsof (cp_chi_sysco_state) intersect {DISCONNECT} && binsof (cp_chi_dvm_part2_sysco_state) intersect {DISCONNECT};
          bins CONNECT_x_CONNECT              = binsof (cp_chi_sysco_state) intersect {CONNECT}    && binsof (cp_chi_dvm_part2_sysco_state) intersect {CONNECT};
          bins CONNECT_x_ENABLED              = binsof (cp_chi_sysco_state) intersect {CONNECT}    && binsof (cp_chi_dvm_part2_sysco_state) intersect {ENABLED};
          bins DISABLED_x_DISABLED            = binsof (cp_chi_sysco_state) intersect {DISABLED}   && binsof (cp_chi_dvm_part2_sysco_state) intersect {DISABLED};

          // Spec says No
          illegal_bins IGNR_CONNECT           = binsof (cp_chi_sysco_state) intersect {CONNECT}    && binsof (cp_chi_dvm_part2_sysco_state) intersect {DISCONNECT, DISABLED};
          illegal_bins IGNR_ENABLED           = binsof (cp_chi_sysco_state) intersect {ENABLED}    && binsof (cp_chi_dvm_part2_sysco_state) intersect {CONNECT, DISABLED};
          illegal_bins IGNR_DISCONNECT        = binsof (cp_chi_sysco_state) intersect {DISCONNECT} && binsof (cp_chi_dvm_part2_sysco_state) intersect {CONNECT, ENABLED, DISABLED};
        }
    endgroup
    <% } %>

    covergroup sys_req_events_cg;
			option.per_instance 		= 1;
                        //#Cover.CHIAIU.EvMsg.Concerto.v3.0.opcodeCHI
			cp_sysreq_event_opcode 		: coverpoint sysreq_pkt.sysreq_event_opcode{
				option.weight			= 0;
				bins event_opcode  		= {3};
			}
                        //#Cover.CHIAIU.EvMsg.Concerto.v3.0.cover.ValidTimeoutsCHI
			cp_timeout_threshold   		: coverpoint sysreq_pkt.timeout_threshold{
				option.weight			= 0;
				bins valid_bins[]  		= {[1:3]};
			}
                        //#Cover.CHIAIU.EvMsg.Concerto.v3.0.cover.sysReq.EventEnableCHI
			cp_event_receiver_enable	: coverpoint sysreq_pkt.event_receiver_enable{
				option.weight			= 0;
				bins enable				= {1};
			}
                        //#Cover.CHIAIU.EvMsg.Concerto.v3.0.cover.sysReq.EventDisableCHI
			cp_event_receiver_disable	: coverpoint sysreq_pkt.event_receiver_enable{
				bins dis				= {0};
			}
			cp_sysreq_event				: coverpoint sysreq_pkt.sysreq_event{
				option.weight			= 0;
				bins sysreq_received	= {1};
			}
                        //#Cover.CHIAIU.EvMsg.Concerto.v3.0.cover.valid_cmstatusCHI
			cp_sysrsp_event_cmstatus	: coverpoint sysreq_pkt.cm_status{
				option.weight			= 0;
				bins good_operation		= {3};
				bins unit_busy			= {1};
			}
      cp_sysrsp_event_cmstatus_dis: coverpoint sysreq_pkt.cm_status{
				bins receiving_disable	= {0};
			}
                        //#Cover.CHIAIU.EvMsg.Concerto.v3.0.cover.TimeoutErrEnableCHI
                        //#Cover.CHIAIU.EvMsg.Concerto.v3.0.cover.TimeoutDisableCHI
			cp_timeout_err_det_en		: coverpoint sysreq_pkt.timeout_err_det_en{
				bins timeout_enable		= {1};
				bins timeout_disable	= {0};
			}
      cp_sysrsp_cmstatus_timeout : coverpoint sysreq_pkt.cm_status iff(sysreq_pkt.timeout_err_det_en == 1){
        bins timeout_cmstatus = {8'h40};
      }
                        //#Cover.CHIAIU.EvMsg.Concerto.v3.0.cover.TimeoutInterruptEnableCHI
			cp_timeout_err_int_en		: coverpoint sysreq_pkt.timeout_err_int_en{
				bins timeout_int_en		= {1};
				bins timeout_int_dis		= {0};
			}
			cp_uc_int_occurred			: coverpoint sysreq_pkt.irq_uc iff(sysreq_pkt.timeout_err_int_en == 1){
				bins irq_occurred		= {1};
				bins no_irq			= {0};
			}
			cp_err_valid				: coverpoint sysreq_pkt.err_valid{
				bins valid			= {1};
				bins invalid			= {0};
			}
                        //#Cover.CHIAIU.EvMsg.Concerto.v3.0.cover.TimeoutErrorAndInterruptCHI
			cp_uesr_err_type			: coverpoint sysreq_pkt.uesr_err_type iff(sysreq_pkt.err_valid == 1 && sysreq_pkt.timeout_err_det_en == 1){
				bins uesr_err_type		= {'hA};
			}
                        //#Cover.CHIAIU.EvMsg.Concerto.v3.0.maxBufferDepthCHI
                        //#Cover.CHIAIU.EvMsg.Concerto.v3.0.cover.TimeoutCHI
			cross_all_sysreq_operations : cross cp_sysreq_event_opcode, cp_timeout_threshold, cp_event_receiver_enable, cp_sysreq_event, cp_sysrsp_event_cmstatus;
		endgroup : sys_req_events_cg

                covergroup snp_up_mpf3_rettosrc_cg; // #Cover.CHIAIU.v3.4.SP.SnpRettosrcbin
                   cp_snp_type: coverpoint snp_type {
                     bins snp_cln_dtr       = {SNP_CLN_DTR};
                     bins snp_nitc          = {SNP_NITC};
                     bins snp_vld_dtr       = {SNP_VLD_DTR};
                     bins snp_inv_dtr       = {SNP_INV_DTR};
                     bins snp_inv_dtw       = {SNP_INV_DTW};
                     bins snp_inv           = {SNP_INV};
                     bins snp_cln_dtw       = {SNP_CLN_DTW};
                     ignore_bins snp_recall = {SNP_RECALL};
                     <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
                     bins snp_nosdint       = {SNP_NOSDINT};
                     bins snp_inv_stsh      = {SNP_INV_STSH};
                     bins snp_unq_stsh      = {SNP_UNQ_STSH};
                     bins snp_stsh_sh       = {SNP_STSH_SH};
                     bins snp_stsh_unq      = {SNP_STSH_UNQ};
                     <% } %>
                     bins snp_dvm_msg       = {SNP_DVM_MSG};
                     bins snp_nitcci        = {SNP_NITCCI};
                     bins snp_nitcmi        = {SNP_NITCMI};
                   }

                   cp_snp_up : coverpoint smi_up {
                     ignore_bins smi_up_0        = {0}; //Reserved
                     bins smi_up_1               = {1};
                     ignore_bins smi_up_2        = {2}; //Reserved 
                     bins smi_up_3               = {3};
                   }

                   cp_snp_mpf3_match : coverpoint mpf3_match {
                     bins mpf3_mis_match       = {0};
                     bins mpf3_match           = {1};
                   }

               <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
                   cp_rettosrc : coverpoint rettosrc {
                     bins rettosrc_0           = {0};
                     bins rettosrc_1           = {1};
                   }
               <% } %>

               <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
		   cross_snp_x_up_mpf3_rettosrc : cross cp_snp_type, cp_snp_up, cp_snp_mpf3_match, cp_rettosrc {
                   illegal_bins SNP_CLN_DTR_MPF3_RETTOSRC_0            = binsof(cp_snp_type) intersect {SNP_CLN_DTR} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h1} && binsof (cp_rettosrc) intersect {1'h0};
                   illegal_bins SNP_NOSDINT_MPF3_RETTOSRC_0            = binsof(cp_snp_type) intersect {SNP_NOSDINT} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h1} && binsof (cp_rettosrc) intersect {1'h0};
                   illegal_bins SNP_VLD_DTR_DTR_MPF3_RETTOSRC_0        = binsof(cp_snp_type) intersect {SNP_VLD_DTR} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h1} && binsof (cp_rettosrc) intersect {1'h0};
                   illegal_bins SNP_INV_DTR_DTR_MPF3_RETTOSRC_0        = binsof(cp_snp_type) intersect {SNP_INV_DTR} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h1} && binsof (cp_rettosrc) intersect {1'h0};
                   illegal_bins SNP_NITCCI_MPF3_RETTOSRC_0             = binsof(cp_snp_type) intersect {SNP_NITCCI} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h1} && binsof (cp_rettosrc) intersect {1'h0};
                   illegal_bins SNP_NITCMI_MPF3_RETTOSRC_0             = binsof(cp_snp_type) intersect {SNP_NITCMI} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h1} && binsof (cp_rettosrc) intersect {1'h0};
                   illegal_bins SNP_NITC_MPF3_RETTOSRC_0               = binsof(cp_snp_type) intersect {SNP_NITC} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h1} && binsof (cp_rettosrc) intersect {1'h0};


                   illegal_bins SNP_CLN_DTR_MPF3_RETTOSRC_1            = binsof(cp_snp_type) intersect {SNP_CLN_DTR} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_NOSDINT_MPF3_RETTOSRC_1            = binsof(cp_snp_type) intersect {SNP_NOSDINT} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_VLD_DTR_DTR_MPF3_RETTOSRC_1        = binsof(cp_snp_type) intersect {SNP_VLD_DTR} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_INV_DTR_DTR_MPF3_RETTOSRC_1        = binsof(cp_snp_type) intersect {SNP_INV_DTR} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_NITCCI_MPF3_RETTOSRC_1             = binsof(cp_snp_type) intersect {SNP_NITCCI} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_NITCMI_MPF3_RETTOSRC_1             = binsof(cp_snp_type) intersect {SNP_NITCMI} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_NITC_MPF3_RETTOSRC_1               = binsof(cp_snp_type) intersect {SNP_NITC} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                  
                   illegal_bins SNP_CLN_DTR_UP_1_RETTOSRC_0            = binsof(cp_snp_type) intersect {SNP_CLN_DTR} && binsof(cp_snp_up) intersect {2'h1} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h0};
                   illegal_bins SNP_NOSDINT_UP_1_RETTOSRC_0            = binsof(cp_snp_type) intersect {SNP_NOSDINT} && binsof(cp_snp_up) intersect {2'h1} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h0};
                   illegal_bins SNP_VLD_DTR_DTR_UP_1_RETTOSRC_0        = binsof(cp_snp_type) intersect {SNP_VLD_DTR} && binsof(cp_snp_up) intersect {2'h1} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h0};
                   illegal_bins SNP_INV_DTR_DTR_UP_1_RETTOSRC_0        = binsof(cp_snp_type) intersect {SNP_INV_DTR} && binsof(cp_snp_up) intersect {2'h1} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h0};
                   illegal_bins SNP_NITCCI_UP_1_RETTOSRC_0             = binsof(cp_snp_type) intersect {SNP_NITCCI} && binsof(cp_snp_up) intersect {2'h1} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h0};
                   illegal_bins SNP_NITCMI_UP_1_RETTOSRC_0             = binsof(cp_snp_type) intersect {SNP_NITCMI} && binsof(cp_snp_up) intersect {2'h1} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h0};
                   illegal_bins SNP_NITC_UP_1_RETTOSRC_0               = binsof(cp_snp_type) intersect {SNP_NITC} && binsof(cp_snp_up) intersect {2'h1} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h0};

                   illegal_bins SNP_CLN_DTR_UP_0_RETTOSRC_1            = binsof(cp_snp_type) intersect {SNP_CLN_DTR} && binsof(cp_snp_up) intersect {2'h0} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_NOSDINT_UP_0_RETTOSRC_1            = binsof(cp_snp_type) intersect {SNP_NOSDINT} && binsof(cp_snp_up) intersect {2'h0} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_VLD_DTR_DTR_UP_0_RETTOSRC_1        = binsof(cp_snp_type) intersect {SNP_VLD_DTR} && binsof(cp_snp_up) intersect {2'h0} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_INV_DTR_DTR_UP_0_RETTOSRC_1        = binsof(cp_snp_type) intersect {SNP_INV_DTR} && binsof(cp_snp_up) intersect {2'h0} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_NITCCI_UP_0_RETTOSRC_1             = binsof(cp_snp_type) intersect {SNP_NITCCI} && binsof(cp_snp_up) intersect {2'h0} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_NITCMI_UP_0_RETTOSRC_1             = binsof(cp_snp_type) intersect {SNP_NITCMI} && binsof(cp_snp_up) intersect {2'h0} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_NITC_UP_0_RETTOSRC_1               = binsof(cp_snp_type) intersect {SNP_NITC} && binsof(cp_snp_up) intersect {2'h0} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};

                   illegal_bins SNP_INV_DTW_UP_RETTOSRC_1               = binsof(cp_snp_type) intersect {SNP_INV_DTW} && binsof(cp_snp_up) intersect {2'h0,2'h1,2'h2,2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_CLN_DTW_UP_RETTOSRC_1               = binsof(cp_snp_type) intersect {SNP_CLN_DTW} && binsof(cp_snp_up) intersect {2'h0,2'h1,2'h2,2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_INV_UP_RETTOSRC_1                   = binsof(cp_snp_type) intersect {SNP_INV} && binsof(cp_snp_up) intersect {2'h0,2'h1,2'h2,2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
                   illegal_bins SNP_UNQ_STSH_UP_RETTOSRC_1              = binsof(cp_snp_type) intersect {SNP_UNQ_STSH} && binsof(cp_snp_up) intersect {2'h0,2'h1,2'h2,2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_STSH_UNQ_UP_RETTOSRC_1              = binsof(cp_snp_type) intersect {SNP_STSH_UNQ} && binsof(cp_snp_up) intersect {2'h0,2'h1,2'h2,2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_STSH_SH_UP_RETTOSRC_1               = binsof(cp_snp_type) intersect {SNP_STSH_SH} && binsof(cp_snp_up) intersect {2'h0,2'h1,2'h2,2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   <% } %>

                   illegal_bins SNP_DVM_MSG_UP_RETTOSRC_1               = binsof(cp_snp_type) intersect {SNP_DVM_MSG} && binsof(cp_snp_up) intersect {2'h0,2'h1,2'h2,2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_RECALL_UP_RETTOSRC_1                = binsof(cp_snp_type) intersect {SNP_RECALL} && binsof(cp_snp_up) intersect {2'h0,2'h1,2'h2,2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};
                   illegal_bins SNP_INV_STSH_UP_RETTOSRC_1              = binsof(cp_snp_type) intersect {SNP_INV_STSH} && binsof(cp_snp_up) intersect {2'h0,2'h1,2'h2,2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0,1'h1} && binsof (cp_rettosrc) intersect {1'h1};

                   ignore_bins SNP_NITC_MPF3_0_RETTOSRC_1               = binsof(cp_snp_type) intersect {SNP_NITC} && binsof(cp_snp_up) intersect {2'h1} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                   ignore_bins SNP_CLN_DTR_MPF3_0_RETTOSRC_1            = binsof(cp_snp_type) intersect {SNP_CLN_DTR} && binsof(cp_snp_up) intersect {2'h1} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                   ignore_bins SNP_VLD_DTR_MPF3_0_RETTOSRC_1            = binsof(cp_snp_type) intersect {SNP_VLD_DTR} && binsof(cp_snp_up) intersect {2'h1} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                   ignore_bins SNP_NOSDINT_MPF3_0_RETTOSRC_1            = binsof(cp_snp_type) intersect {SNP_NOSDINT} && binsof(cp_snp_up) intersect {2'h1} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};

                   ignore_bins SNP_NITC_MPF3_0_RETTOSRC_1_UP_3               = binsof(cp_snp_type) intersect {SNP_NITC} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                   ignore_bins SNP_CLN_DTR_MPF3_0_RETTOSRC_1_UP_3            = binsof(cp_snp_type) intersect {SNP_CLN_DTR} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                   ignore_bins SNP_VLD_DTR_MPF3_0_RETTOSRC_1_UP_3            = binsof(cp_snp_type) intersect {SNP_VLD_DTR} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                   ignore_bins SNP_NOSDINT_MPF3_0_RETTOSRC_1_UP_3            = binsof(cp_snp_type) intersect {SNP_NOSDINT} && binsof(cp_snp_up) intersect {'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h1};
                   ignore_bins SNP_DVM_MSG                              = binsof(cp_snp_type) intersect {SNP_DVM_MSG};

// sys_bfm will always generate MPF3 match for following transactions
                   ignore_bins SNP_NITC_MPF3_0_RETTOSRC_0_UP_3               = binsof(cp_snp_type) intersect {SNP_NITC} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h0};
                   ignore_bins SNP_CLN_DTR_MPF3_0_RETTOSRC_0_UP_3            = binsof(cp_snp_type) intersect {SNP_CLN_DTR} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h0};
                   ignore_bins SNP_VLD_DTR_MPF3_0_RETTOSRC_0_UP_3            = binsof(cp_snp_type) intersect {SNP_VLD_DTR} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h0};
                   ignore_bins SNP_NOSDINT_MPF3_0_RETTOSRC_0_UP_3            = binsof(cp_snp_type) intersect {SNP_NOSDINT} && binsof(cp_snp_up) intersect {2'h3} && binsof (cp_snp_mpf3_match) intersect {1'h0} && binsof (cp_rettosrc) intersect {1'h0};
                   }
	       <% } %>
                endgroup : snp_up_mpf3_rettosrc_cg

    covergroup security_rd_cg;        // #Cover.CHIAIU.v3.4.Security.SecureNonSecurebin

        cp_chi_rd_req_opcode: coverpoint rd_req_ns_opcode {
            bins READSHARED           = {7'h01};
            bins READCLEAN            = {7'h02};
            bins READONCE             = {7'h03};
            bins READNOSNP            = {7'h04};
            bins READUNIQUE           = {7'h07};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins READONCECLEANINVALID = {7'h24};
            bins READONCEMAKEINVALID  = {7'h25};
            bins READNOTSHAREDDIRTY   = {7'h26};
          <% } %>
        }

        cp_req_ns: coverpoint rd_req_ns {
            bins NS_0           = {1'h0};
            bins NS_1           = {1'h1};
        }

        cp_rd_nsx: coverpoint rd_nsx {
            bins NSX_0           = {1'h0};
            bins NSX_1           = {1'h1};
        }
        cp_rd_err: coverpoint rd_err {
            bins RD_NO_ERR           = {1'h0};
            bins RD_DEC_ERR          = {1'h1};
        }

        cross_read_nsx_decerr_no_err: cross cp_chi_rd_req_opcode, cp_req_ns, cp_rd_nsx, cp_rd_err iff (is_addr_boot_csr == 0) {
            illegal_bins READSHARED_NSX1_DECERR            = binsof(cp_chi_rd_req_opcode) intersect {7'h01} && binsof(cp_req_ns) intersect {1'h0, 1'h1} && binsof (cp_rd_nsx) intersect {1'h1} && binsof (cp_rd_err) intersect {1'h1};
            illegal_bins READCLEAN_NSX1_DECERR             = binsof(cp_chi_rd_req_opcode) intersect {7'h02} && binsof(cp_req_ns) intersect {1'h0, 1'h1} && binsof (cp_rd_nsx) intersect {1'h1} && binsof (cp_rd_err) intersect {1'h1};
            illegal_bins READONCE_NSX1_DECERR              = binsof(cp_chi_rd_req_opcode) intersect {7'h03} && binsof(cp_req_ns) intersect {1'h0, 1'h1} && binsof (cp_rd_nsx) intersect {1'h1} && binsof (cp_rd_err) intersect {1'h1};
            illegal_bins READNOSNP_NSX1_DECERR             = binsof(cp_chi_rd_req_opcode) intersect {7'h04} && binsof(cp_req_ns) intersect {1'h0, 1'h1} && binsof (cp_rd_nsx) intersect {1'h1} && binsof (cp_rd_err) intersect {1'h1};
            illegal_bins READUNIQUE_NSX1_DECERR            = binsof(cp_chi_rd_req_opcode) intersect {7'h07} && binsof(cp_req_ns) intersect {1'h0, 1'h1} && binsof (cp_rd_nsx) intersect {1'h1} && binsof (cp_rd_err) intersect {1'h1};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins READONCECLEANINVALID_NSX1_DECERR          = binsof(cp_chi_rd_req_opcode) intersect {7'h24} && binsof(cp_req_ns) intersect {1'h0, 1'h1} && binsof (cp_rd_nsx) intersect {1'h1} && binsof (cp_rd_err) intersect {1'h1};
            illegal_bins READONCEMAKEINVALID_NSX1_DECERR           = binsof(cp_chi_rd_req_opcode) intersect {7'h25} && binsof(cp_req_ns) intersect {1'h0, 1'h1} && binsof (cp_rd_nsx) intersect {1'h1} && binsof (cp_rd_err) intersect {1'h1};
            illegal_bins READNOTSHAREDDIRTY_NSX1_DECERR            = binsof(cp_chi_rd_req_opcode) intersect {7'h26} && binsof(cp_req_ns) intersect {1'h0, 1'h1} && binsof (cp_rd_nsx) intersect {1'h1} && binsof (cp_rd_err) intersect {1'h1};
          <% } %>

            illegal_bins READSHARED_NSX0_NOERR            = binsof(cp_chi_rd_req_opcode) intersect {7'h01} && binsof(cp_req_ns) intersect {1'h1} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h0};
            illegal_bins READCLEAN_NSX0_NOERR             = binsof(cp_chi_rd_req_opcode) intersect {7'h02} && binsof(cp_req_ns) intersect {1'h1} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h0};
            illegal_bins READONCE_NSX0_NOERR              = binsof(cp_chi_rd_req_opcode) intersect {7'h03} && binsof(cp_req_ns) intersect {1'h1} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h0};
            illegal_bins READNOSNP_NSX0_NOERR             = binsof(cp_chi_rd_req_opcode) intersect {7'h04} && binsof(cp_req_ns) intersect {1'h1} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h0};
            illegal_bins READUNIQUE_NSX0_NOERR            = binsof(cp_chi_rd_req_opcode) intersect {7'h07} && binsof(cp_req_ns) intersect {1'h1} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h0};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins READONCECLEANINVALID_NSX0_NOERR          = binsof(cp_chi_rd_req_opcode) intersect {7'h24} && binsof(cp_req_ns) intersect {1'h1} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h0};
            illegal_bins READONCEMAKEINVALID_NSX0_NOERR           = binsof(cp_chi_rd_req_opcode) intersect {7'h25} && binsof(cp_req_ns) intersect {1'h1} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h0};
            illegal_bins READNOTSHAREDDIRTY_NSX0_NOERR            = binsof(cp_chi_rd_req_opcode) intersect {7'h26} && binsof(cp_req_ns) intersect {1'h1} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h0};
          <% } %>

            illegal_bins READSHARED_NS0_NSX0_DECERR            = binsof(cp_chi_rd_req_opcode) intersect {7'h01} && binsof(cp_req_ns) intersect {1'h0} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h1};
            illegal_bins READCLEAN_NS0_NSX0_DECERR             = binsof(cp_chi_rd_req_opcode) intersect {7'h02} && binsof(cp_req_ns) intersect {1'h0} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h1};
            illegal_bins READONCE_NS0_NSX0_DECERR              = binsof(cp_chi_rd_req_opcode) intersect {7'h03} && binsof(cp_req_ns) intersect {1'h0} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h1};
            illegal_bins READNOSNP_NS0_NSX0_DECERR             = binsof(cp_chi_rd_req_opcode) intersect {7'h04} && binsof(cp_req_ns) intersect {1'h0} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h1};
            illegal_bins READUNIQUE_NS0_NSX0_DECERR            = binsof(cp_chi_rd_req_opcode) intersect {7'h07} && binsof(cp_req_ns) intersect {1'h0} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h1};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins READONCECLEANINVALID_NS0_NSX0_DECERR          = binsof(cp_chi_rd_req_opcode) intersect {7'h24} && binsof(cp_req_ns) intersect {1'h0} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h1};
            illegal_bins READONCEMAKEINVALID_NS0_NSX0_DECERR           = binsof(cp_chi_rd_req_opcode) intersect {7'h25} && binsof(cp_req_ns) intersect {1'h0} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h1};
            illegal_bins READNOTSHAREDDIRTY_NS0_NSX0_DECERR            = binsof(cp_chi_rd_req_opcode) intersect {7'h26} && binsof(cp_req_ns) intersect {1'h0} && binsof (cp_rd_nsx) intersect {1'h0} && binsof (cp_rd_err) intersect {1'h1};
          <% } %>
        }


    endgroup : security_rd_cg

    covergroup security_dataless_cg;

        cp_chi_dataless_req_opcode: coverpoint dataless_req_ns_opcode {
            bins CLEANSHARED          = {7'h08};
            bins CLEANINVALID         = {7'h09};
            bins MAKEINVALID          = {7'h0A};
            bins CLEANUNIQUE          = {7'h0B};
            bins MAKEUNIQUE           = {7'h0C};
            bins EVICT                = {7'h0D};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            bins STASHONCESHARED      = {7'h22};
            bins CLEANSHAREDPERSIST   = {7'h27};
            bins STASHONCEUNIQUE      = {7'h23};
          <% } %>
        }


        cp_dataless_ns: coverpoint dataless_req_ns {
            bins NS_0           = {1'h0};
            bins NS_1           = {1'h1};
        }

        cp_dataless_nsx: coverpoint dataless_nsx {
            bins NSX_0           = {1'h0};
            bins NSX_1           = {1'h1};
        }

        cp_dataless_err: coverpoint dataless_err {
            bins DT_NO_ERR           = {1'h0};
            bins DT_DEC_ERR          = {1'h1};
        }

        cross_dataless_nsx_decerr_noerr : cross cp_chi_dataless_req_opcode, cp_dataless_ns, cp_dataless_nsx, cp_dataless_err{
            illegal_bins CLEANSHARED_NSX1_DECERR             = binsof(cp_chi_dataless_req_opcode) intersect {7'h08} && binsof(cp_dataless_ns) intersect {1'h0, 1'h1} && binsof (cp_dataless_nsx) intersect {1'h1} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins CLEANINVALID_NSX1_DECERR            = binsof(cp_chi_dataless_req_opcode) intersect {7'h09} && binsof(cp_dataless_ns) intersect {1'h0, 1'h1} && binsof (cp_dataless_nsx) intersect {1'h1} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins MAKEINVALID_NSX1_DECERR             = binsof(cp_chi_dataless_req_opcode) intersect {7'h0A} && binsof(cp_dataless_ns) intersect {1'h0, 1'h1} && binsof (cp_dataless_nsx) intersect {1'h1} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins CLEANUNIQUE_NSX1_DECERR             = binsof(cp_chi_dataless_req_opcode) intersect {7'h0B} && binsof(cp_dataless_ns) intersect {1'h0, 1'h1} && binsof (cp_dataless_nsx) intersect {1'h1} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins MAKEUNIQUE_NSX1_DECERR              = binsof(cp_chi_dataless_req_opcode) intersect {7'h0C} && binsof(cp_dataless_ns) intersect {1'h0, 1'h1} && binsof (cp_dataless_nsx) intersect {1'h1} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins EVICT_NSX1_DECERR                   = binsof(cp_chi_dataless_req_opcode) intersect {7'h0D} && binsof(cp_dataless_ns) intersect {1'h0, 1'h1} && binsof (cp_dataless_nsx) intersect {1'h1} && binsof (cp_dataless_err) intersect {1'h1};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins STASHONCESHARED_NSX1_DECERR         = binsof(cp_chi_dataless_req_opcode) intersect {7'h22} && binsof(cp_dataless_ns) intersect {1'h0, 1'h1} && binsof (cp_dataless_nsx) intersect {1'h1} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins CLEANSHAREDPERSIST_NSX1_DECERR      = binsof(cp_chi_dataless_req_opcode) intersect {7'h27} && binsof(cp_dataless_ns) intersect {1'h0, 1'h1} && binsof (cp_dataless_nsx) intersect {1'h1} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins STASHONCEUNIQUE_NSX1_DECERR         = binsof(cp_chi_dataless_req_opcode) intersect {7'h23} && binsof(cp_dataless_ns) intersect {1'h0, 1'h1} && binsof (cp_dataless_nsx) intersect {1'h1} && binsof (cp_dataless_err) intersect {1'h1};
          <% } %>


            illegal_bins CLEANSHARED_NSX0_NOERR             = binsof(cp_chi_dataless_req_opcode) intersect {7'h08} && binsof(cp_dataless_ns) intersect {1'h1} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h0};
            illegal_bins CLEANINVALID_NSX0_NOERR            = binsof(cp_chi_dataless_req_opcode) intersect {7'h09} && binsof(cp_dataless_ns) intersect {1'h1} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h0};
            illegal_bins MAKEINVALID_NSX0_NOERR             = binsof(cp_chi_dataless_req_opcode) intersect {7'h0A} && binsof(cp_dataless_ns) intersect {1'h1} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h0};
            illegal_bins CLEANUNIQUE_NSX0_NOERR             = binsof(cp_chi_dataless_req_opcode) intersect {7'h0B} && binsof(cp_dataless_ns) intersect {1'h1} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h0};
            illegal_bins MAKEUNIQUE_NSX0_NOERR              = binsof(cp_chi_dataless_req_opcode) intersect {7'h0C} && binsof(cp_dataless_ns) intersect {1'h1} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h0};
            illegal_bins EVICT_NSX0_NOERR                   = binsof(cp_chi_dataless_req_opcode) intersect {7'h0D} && binsof(cp_dataless_ns) intersect {1'h1} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h0};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins STASHONCESHARED_NSX0_NOERR         = binsof(cp_chi_dataless_req_opcode) intersect {7'h22} && binsof(cp_dataless_ns) intersect {1'h1} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h0};
            illegal_bins CLEANSHAREDPERSIST_NSX0_NOERR      = binsof(cp_chi_dataless_req_opcode) intersect {7'h27} && binsof(cp_dataless_ns) intersect {1'h1} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h0};
            illegal_bins STASHONCEUNIQUE_NSX0_NOERR         = binsof(cp_chi_dataless_req_opcode) intersect {7'h23} && binsof(cp_dataless_ns) intersect {1'h1} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h0};
          <% } %>


            illegal_bins CLEANSHARED_NS0_NSX0_DECERR             = binsof(cp_chi_dataless_req_opcode) intersect {7'h08} && binsof(cp_dataless_ns) intersect {1'h0} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins CLEANINVALID_NS0_NSX0_DECERR            = binsof(cp_chi_dataless_req_opcode) intersect {7'h09} && binsof(cp_dataless_ns) intersect {1'h0} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins MAKEINVALID_NS0_NSX0_DECERR             = binsof(cp_chi_dataless_req_opcode) intersect {7'h0A} && binsof(cp_dataless_ns) intersect {1'h0} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins CLEANUNIQUE_NS0_NSX0_DECERR             = binsof(cp_chi_dataless_req_opcode) intersect {7'h0B} && binsof(cp_dataless_ns) intersect {1'h0} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins MAKEUNIQUE_NS0_NSX0_DECERR              = binsof(cp_chi_dataless_req_opcode) intersect {7'h0C} && binsof(cp_dataless_ns) intersect {1'h0} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins EVICT_NS0_NSX0_DECERR                   = binsof(cp_chi_dataless_req_opcode) intersect {7'h0D} && binsof(cp_dataless_ns) intersect {1'h0} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h1};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            illegal_bins STASHONCESHARED_NS0_NSX0_DECERR         = binsof(cp_chi_dataless_req_opcode) intersect {7'h22} && binsof(cp_dataless_ns) intersect {1'h0} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins CLEANSHAREDPERSIST_NS0_NSX0_DECERR      = binsof(cp_chi_dataless_req_opcode) intersect {7'h27} && binsof(cp_dataless_ns) intersect {1'h0} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h1};
            illegal_bins STASHONCEUNIQUE_NS0_NSX0_DECERR         = binsof(cp_chi_dataless_req_opcode) intersect {7'h23} && binsof(cp_dataless_ns) intersect {1'h0} && binsof (cp_dataless_nsx) intersect {1'h0} && binsof (cp_dataless_err) intersect {1'h1};
          <% } %>


        }

    endgroup : security_dataless_cg

    covergroup security_wr_cg;

        cp_chi_wr_req_opcode: coverpoint wr_req_ns_opcode {
            bins WRITEEVICTFULL       = {7'h15};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            bins WRITECLEANPTL        = {7'h16};
            <% } %>
            bins WRITECLEANFULL       = {7'h17};
            bins WRITEUNIQUEPTL       = {7'h18};
            bins WRITEUNIQUEFULL      = {7'h19};
            bins WRITEBACKPTL         = {7'h1A};
            bins WRITEBACKFULL        = {7'h1B};
            bins WRITENOSNPPTL        = {7'h1C};
            bins WRITENOSNPFULL       = {7'h1D};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            bins WRITENOSNPFULL_CLEANSHARED         	= {7'h50};
            bins WRITENOSNPFULL_CLEANINVALID            = {7'h51};
            bins WRITENOSNPFULL_CLEANSHAREDPERSISTSEP   = {7'h52};
            bins WRITEBACKFULL_CLEANSHARED              = {7'h58};
            bins WRITEBACKFULL_CLEANINVALID             = {7'h59};
            bins WRITEBACKFULL_CLEANSHAREDPERSISTSEP    = {7'h5A};
            bins WRITECLEANFULL_CLEANSHARED             = {7'h5C};
            bins WRITECLEANFULL_CLEANSHAREDPERSISTSEP   = {7'h5E};
            bins WRITEEVICTOREVICT               	= {7'h42};
            <% } %>
        }

        cp_wr_ns: coverpoint wr_req_ns {
            bins NS_0           = {1'h0};
            bins NS_1           = {1'h1};
        }

        cp_wr_nsx: coverpoint wr_nsx {
            bins NSX_0           = {1'h0};
            bins NSX_1           = {1'h1};
        }

        cp_wr_err: coverpoint wr_err {
            bins WR_NO_ERR           = {1'h0};
            bins WR_DEC_ERR          = {1'h1};
        }

        cross_wr_nsx_decerr_noerr : cross cp_chi_wr_req_opcode, cp_wr_ns, cp_wr_nsx, cp_wr_err {
            illegal_bins WRITEEVICTFULL_NSX1_DECERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h15} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITECLEANFULL_NSX1_DECERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h17} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEUNIQUEPTL_NSX1_DECERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h18} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEUNIQUEFULL_NSX1_DECERR            = binsof(cp_chi_wr_req_opcode) intersect {7'h19} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEBACKPTL_NSX1_DECERR               = binsof(cp_chi_wr_req_opcode) intersect {7'h1A} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEBACKFULL_NSX1_DECERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h1B} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITENOSNPPTL_NSX1_DECERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h1C} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITENOSNPFULL_NSX1_DECERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h1D} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            illegal_bins WRITECLEANPTL_NSX1_DECERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h16} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            <% } %>
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            illegal_bins WRITENOSNPFULL_CLEANSHARED_NSX1_DECERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h50} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITENOSNPFULL_CLEANINVALID_NSX1_DECERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h51} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITENOSNPFULL_CLEANSHAREDPERSISTSEP_NSX1_DECERR    = binsof(cp_chi_wr_req_opcode) intersect {7'h52} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEBACKFULL_CLEANSHARED_NSX1_DECERR               = binsof(cp_chi_wr_req_opcode) intersect {7'h58} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEBACKFULL_CLEANINVALID_NSX1_DECERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h59} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEBACKFULL_CLEANSHAREDPERSISTSEP_NSX1_DECERR     = binsof(cp_chi_wr_req_opcode) intersect {7'h5A} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITECLEANFULL_CLEANSHARED_NSX1_DECERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h5C} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITECLEANFULL_CLEANSHAREDPERSISTSEP_NSX1_DECERR    = binsof(cp_chi_wr_req_opcode) intersect {7'h5E} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEEVICTOREVICT_NSX1_DECERR                       = binsof(cp_chi_wr_req_opcode) intersect {7'h42} && binsof(cp_wr_ns) intersect {1'h0, 1'h1} && binsof (cp_wr_nsx) intersect {1'h1} && binsof (cp_wr_err) intersect {1'h1};
            <% } %>

            illegal_bins WRITEEVICTFULL_NSX0_NOERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h15} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITECLEANFULL_NSX0_NOERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h17} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITEUNIQUEPTL_NSX0_NOERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h18} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITEUNIQUEFULL_NSX0_NOERR            = binsof(cp_chi_wr_req_opcode) intersect {7'h19} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITEBACKPTL_NSX0_NOERR               = binsof(cp_chi_wr_req_opcode) intersect {7'h1A} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITEBACKFULL_NSX0_NOERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h1B} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITENOSNPPTL_NSX0_NOERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h1C} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITENOSNPFULL_NSX0_NOERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h1D} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            illegal_bins WRITECLEANPTL_NSX0_NOERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h16} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            <% } %>
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            illegal_bins WRITENOSNPFULL_CLEANSHARED_NSX0_NOERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h50} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITENOSNPFULL_CLEANINVALID_NSX0_NOERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h51} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITENOSNPFULL_CLEANSHAREDPERSISTSEP_NSX0_NOERR    = binsof(cp_chi_wr_req_opcode) intersect {7'h52} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITEBACKFULL_CLEANSHARED_NSX0_NOERR               = binsof(cp_chi_wr_req_opcode) intersect {7'h58} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITEBACKFULL_CLEANINVALID_NSX0_NOERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h59} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITEBACKFULL_CLEANSHAREDPERSISTSEP_NSX0_NOERR     = binsof(cp_chi_wr_req_opcode) intersect {7'h5A} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITECLEANFULL_CLEANSHARED_NSX0_NOERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h5C} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITECLEANFULL_CLEANSHAREDPERSISTSEP_NSX0_NOERR    = binsof(cp_chi_wr_req_opcode) intersect {7'h5E} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            illegal_bins WRITEEVICTOREVICT_NSX0_NOERR                       = binsof(cp_chi_wr_req_opcode) intersect {7'h42} && binsof(cp_wr_ns) intersect {1'h1} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h0};
            <% } %>

            illegal_bins WRITEEVICTFULL_NS0_NSX0_DECERR            = binsof(cp_chi_wr_req_opcode) intersect {7'h15} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITECLEANFULL_NS0_NSX0_DECERR            = binsof(cp_chi_wr_req_opcode) intersect {7'h17} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEUNIQUEPTL_NS0_NSX0_DECERR            = binsof(cp_chi_wr_req_opcode) intersect {7'h18} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEUNIQUEFULL_NS0_NSX0_DECERR           = binsof(cp_chi_wr_req_opcode) intersect {7'h19} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEBACKPTL_NS0_NSX0_DECERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h1A} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEBACKFULL_NS0_NSX0_DECERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h1B} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITENOSNPPTL_NS0_NSX0_DECERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h1C} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITENOSNPFULL_NS0_NSX0_DECERR            = binsof(cp_chi_wr_req_opcode) intersect {7'h1D} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            illegal_bins WRITECLEANPTL_NS0_NSX0_DECERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h16} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            <% } %>
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            illegal_bins WRITENOSNPFULL_CLEANSHARED_NS0_NSX0_DECERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h50} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITENOSNPFULL_CLEANINVALID_NS0_NSX0_DECERR            = binsof(cp_chi_wr_req_opcode) intersect {7'h51} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITENOSNPFULL_CLEANSHAREDPERSISTSEP_NS0_NSX0_DECERR   = binsof(cp_chi_wr_req_opcode) intersect {7'h52} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEBACKFULL_CLEANSHARED_NS0_NSX0_DECERR              = binsof(cp_chi_wr_req_opcode) intersect {7'h58} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEBACKFULL_CLEANINVALID_NS0_NSX0_DECERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h59} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEBACKFULL_CLEANSHAREDPERSISTSEP_NS0_NSX0_DECERR    = binsof(cp_chi_wr_req_opcode) intersect {7'h5A} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITECLEANFULL_CLEANSHARED_NS0_NSX0_DECERR             = binsof(cp_chi_wr_req_opcode) intersect {7'h5C} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITECLEANFULL_CLEANSHAREDPERSISTSEP_NS0_NSX0_DECERR   = binsof(cp_chi_wr_req_opcode) intersect {7'h5E} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            illegal_bins WRITEEVICTOREVICT_NS0_NSX0_DECERR                      = binsof(cp_chi_wr_req_opcode) intersect {7'h42} && binsof(cp_wr_ns) intersect {1'h0} && binsof (cp_wr_nsx) intersect {1'h0} && binsof (cp_wr_err) intersect {1'h1};
            <% } %>
        }

    endgroup : security_wr_cg

   <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    covergroup security_atomic_ld_cg;

        cp_chi_atomic_ld_opcode: coverpoint atomic_ld_req_ns_opcode {
                bins ATOMICLOAD_LDADD     = {7'h30};
                bins ATOMICLOAD_LDCLR     = {7'h31};
                bins ATOMICLOAD_LDEOR     = {7'h32};
                bins ATOMICLOAD_LDSET     = {7'h33};
                bins ATOMICLOAD_LDSMAX    = {7'h34};
                bins ATOMICLOAD_LDMIN     = {7'h35};
                bins ATOMICLOAD_LDUSMAX   = {7'h36};
                bins ATOMICLOAD_LDUMIN    = {7'h37};
                bins ATOMICSWAP           = {7'h38};
                bins ATOMICCOMPARE        = {7'h39};
        }

        cp_atomic_ld_ns: coverpoint atomic_ld_req_ns {
            bins NS_0           = {1'h0};
            bins NS_1           = {1'h1};
        }

        cp_atomic_ld_nsx: coverpoint atomic_ld_nsx {
            bins NSX_0           = {1'h0};
            bins NSX_1           = {1'h1};
        }

        cp_atomic_ld_err: coverpoint atomic_ld_err {
            bins ATOMIC_LD_NO_ERR           = {1'h0};
            bins ATOMIC_LD_DEC_ERR          = {1'h1};
        }

        cross_atomic_ld_nsx_decerr_noerr : cross cp_chi_atomic_ld_opcode, cp_atomic_ld_ns, cp_atomic_ld_nsx, cp_atomic_ld_err {
            illegal_bins ATOMICLOAD_LDADD_NSX1_DECERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h30} && binsof(cp_atomic_ld_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h1} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDCLR_NSX1_DECERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h31} && binsof(cp_atomic_ld_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h1} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDEOR_NSX1_DECERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h32} && binsof(cp_atomic_ld_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h1} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDSET_NSX1_DECERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h33} && binsof(cp_atomic_ld_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h1} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDSMAX_DECERR                 = binsof(cp_chi_atomic_ld_opcode) intersect {7'h34} && binsof(cp_atomic_ld_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h1} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDMIN_DECERR                  = binsof(cp_chi_atomic_ld_opcode) intersect {7'h35} && binsof(cp_atomic_ld_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h1} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDUSMAX_DECERR                = binsof(cp_chi_atomic_ld_opcode) intersect {7'h36} && binsof(cp_atomic_ld_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h1} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDUMIN_DECERR                 = binsof(cp_chi_atomic_ld_opcode) intersect {7'h37} && binsof(cp_atomic_ld_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h1} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICSWAP_DECERR                        = binsof(cp_chi_atomic_ld_opcode) intersect {7'h38} && binsof(cp_atomic_ld_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h1} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICCOMPARE_DECERR                     = binsof(cp_chi_atomic_ld_opcode) intersect {7'h39} && binsof(cp_atomic_ld_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h1} && binsof (cp_atomic_ld_err) intersect {1'h1};


            illegal_bins ATOMICLOAD_LDADD_NSX0_NOERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h30} && binsof(cp_atomic_ld_ns) intersect {1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h0};
            illegal_bins ATOMICLOAD_LDCLR_NSX0_NOERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h31} && binsof(cp_atomic_ld_ns) intersect {1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h0};
            illegal_bins ATOMICLOAD_LDEOR_NSX0_NOERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h32} && binsof(cp_atomic_ld_ns) intersect {1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h0};
            illegal_bins ATOMICLOAD_LDSET_NSX0_NOERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h33} && binsof(cp_atomic_ld_ns) intersect {1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h0};
            illegal_bins ATOMICLOAD_LDSMAX_NSX0_NOERR            = binsof(cp_chi_atomic_ld_opcode) intersect {7'h34} && binsof(cp_atomic_ld_ns) intersect {1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h0};
            illegal_bins ATOMICLOAD_LDMIN_NSX0_NOERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h35} && binsof(cp_atomic_ld_ns) intersect {1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h0};
            illegal_bins ATOMICLOAD_LDUSMAX_NSX0_NOERR           = binsof(cp_chi_atomic_ld_opcode) intersect {7'h36} && binsof(cp_atomic_ld_ns) intersect {1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h0};
            illegal_bins ATOMICLOAD_LDUMIN_NSX0_NOERR            = binsof(cp_chi_atomic_ld_opcode) intersect {7'h37} && binsof(cp_atomic_ld_ns) intersect {1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h0};
            illegal_bins ATOMICSWAP_NSX0_NOERR                   = binsof(cp_chi_atomic_ld_opcode) intersect {7'h38} && binsof(cp_atomic_ld_ns) intersect {1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h0};
            illegal_bins ATOMICCOMPARE_NSX0_NOERR                = binsof(cp_chi_atomic_ld_opcode) intersect {7'h39} && binsof(cp_atomic_ld_ns) intersect {1'h1} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h0};


            illegal_bins ATOMICLOAD_LDADD_NS0_NSX0_DECERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h30} && binsof(cp_atomic_ld_ns) intersect {1'h0} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDCLR_NS0_NSX0_DECERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h31} && binsof(cp_atomic_ld_ns) intersect {1'h0} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDEOR_NS0_NSX0_DECERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h32} && binsof(cp_atomic_ld_ns) intersect {1'h0} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDSET_NS0_NSX0_DECERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h33} && binsof(cp_atomic_ld_ns) intersect {1'h0} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDSMAX_NS0_NSX0_DECERR            = binsof(cp_chi_atomic_ld_opcode) intersect {7'h34} && binsof(cp_atomic_ld_ns) intersect {1'h0} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDMIN_NS0_NSX0_DECERR             = binsof(cp_chi_atomic_ld_opcode) intersect {7'h35} && binsof(cp_atomic_ld_ns) intersect {1'h0} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDUSMAX_NS0_NSX0_DECERR           = binsof(cp_chi_atomic_ld_opcode) intersect {7'h36} && binsof(cp_atomic_ld_ns) intersect {1'h0} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICLOAD_LDUMIN_NS0_NSX0_DECERR            = binsof(cp_chi_atomic_ld_opcode) intersect {7'h37} && binsof(cp_atomic_ld_ns) intersect {1'h0} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICSWAP_NS0_NSX0_DECERR                   = binsof(cp_chi_atomic_ld_opcode) intersect {7'h38} && binsof(cp_atomic_ld_ns) intersect {1'h0} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h1};
            illegal_bins ATOMICCOMPARE_NS0_NSX0_DECERR                = binsof(cp_chi_atomic_ld_opcode) intersect {7'h39} && binsof(cp_atomic_ld_ns) intersect {1'h0} && binsof (cp_atomic_ld_nsx) intersect {1'h0} && binsof (cp_atomic_ld_err) intersect {1'h1};


         }
    endgroup : security_atomic_ld_cg


    covergroup security_atomic_st_cg;
            cp_chi_atomic_st_opcode: coverpoint atomic_st_ns_opcode {
                bins ATOMICSTORE_STADD    = {7'h28};
                bins ATOMICSTORE_STCLR    = {7'h29};
                bins ATOMICSTORE_STEOR    = {7'h2A};
                bins ATOMICSTORE_STSET    = {7'h2B};
                bins ATOMICSTORE_STSMAX   = {7'h2C};
                bins ATOMICSTORE_STMIN    = {7'h2D};
                bins ATOMICSTORE_STUSMAX  = {7'h2E};
                bins ATOMICSTORE_STUMIN   = {7'h2F};
            }

        cp_atomic_st_ns: coverpoint atomic_st_ns {
            bins NS_0           = {1'h0};
            bins NS_1           = {1'h1};
        }

        cp_atomic_st_nsx: coverpoint atomic_st_nsx {
            bins NSX_0           = {1'h0};
            bins NSX_1           = {1'h1};
        }

        cp_atomic_st_err: coverpoint atomic_st_err {
            bins ATOMIC_ST_NO_ERR           = {1'h0};
            bins ATOMIC_ST_DEC_ERR          = {1'h1};
        }

        cross_atomic_st_nsx_decerr_noerr : cross cp_chi_atomic_st_opcode, cp_atomic_st_ns, cp_atomic_st_nsx, cp_atomic_st_err {
            illegal_bins ATOMICSTORE_STADD_NSX1_DECERR             = binsof(cp_chi_atomic_st_opcode) intersect {7'h28} && binsof(cp_atomic_st_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h1} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STCLR_NSX1_DECERR             = binsof(cp_chi_atomic_st_opcode) intersect {7'h29} && binsof(cp_atomic_st_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h1} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STEOR_NSX1_DECERR             = binsof(cp_chi_atomic_st_opcode) intersect {7'h2A} && binsof(cp_atomic_st_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h1} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STSET_NSX1_DECERR             = binsof(cp_chi_atomic_st_opcode) intersect {7'h2B} && binsof(cp_atomic_st_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h1} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STSMAX_NSX1_DECERR            = binsof(cp_chi_atomic_st_opcode) intersect {7'h2C} && binsof(cp_atomic_st_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h1} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STMIN_NSX1_DECERR             = binsof(cp_chi_atomic_st_opcode) intersect {7'h2D} && binsof(cp_atomic_st_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h1} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STUSMAX_NSX1_DECERR           = binsof(cp_chi_atomic_st_opcode) intersect {7'h2E} && binsof(cp_atomic_st_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h1} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STUMIN_NSX1_DECERR            = binsof(cp_chi_atomic_st_opcode) intersect {7'h2F} && binsof(cp_atomic_st_ns) intersect {1'h0, 1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h1} && binsof (cp_atomic_st_err) intersect {1'h1};


            illegal_bins ATOMICSTORE_STADD_NSX0_NOERR              = binsof(cp_chi_atomic_st_opcode) intersect {7'h28} && binsof(cp_atomic_st_ns) intersect {1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h0};
            illegal_bins ATOMICSTORE_STCLR_NSX0_NOERR              = binsof(cp_chi_atomic_st_opcode) intersect {7'h29} && binsof(cp_atomic_st_ns) intersect {1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h0};
            illegal_bins ATOMICSTORE_STEOR_NSX0_NOERR              = binsof(cp_chi_atomic_st_opcode) intersect {7'h2A} && binsof(cp_atomic_st_ns) intersect {1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h0};
            illegal_bins ATOMICSTORE_STSET_NSX0_NOERR              = binsof(cp_chi_atomic_st_opcode) intersect {7'h2B} && binsof(cp_atomic_st_ns) intersect {1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h0};
            illegal_bins ATOMICSTORE_STSMAX_NSX0_NOERR             = binsof(cp_chi_atomic_st_opcode) intersect {7'h2C} && binsof(cp_atomic_st_ns) intersect {1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h0};
            illegal_bins ATOMICSTORE_STMIN_NSX0_NOERR              = binsof(cp_chi_atomic_st_opcode) intersect {7'h2D} && binsof(cp_atomic_st_ns) intersect {1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h0};
            illegal_bins ATOMICSTORE_STUSMAX_NSX0_NOERR            = binsof(cp_chi_atomic_st_opcode) intersect {7'h2E} && binsof(cp_atomic_st_ns) intersect {1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h0};
            illegal_bins ATOMICSTORE_STUMIN_NSX0_NOERR             = binsof(cp_chi_atomic_st_opcode) intersect {7'h2F} && binsof(cp_atomic_st_ns) intersect {1'h1} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h0};

            illegal_bins ATOMICSTORE_STADD_NS0_NSX0_DECERR             = binsof(cp_chi_atomic_st_opcode) intersect {7'h28} && binsof(cp_atomic_st_ns) intersect {1'h0} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STCLR_NS0_NSX0_DECERR             = binsof(cp_chi_atomic_st_opcode) intersect {7'h29} && binsof(cp_atomic_st_ns) intersect {1'h0} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STEOR_NS0_NSX0_DECERR             = binsof(cp_chi_atomic_st_opcode) intersect {7'h2A} && binsof(cp_atomic_st_ns) intersect {1'h0} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STSET_NS0_NSX0_DECERR             = binsof(cp_chi_atomic_st_opcode) intersect {7'h2B} && binsof(cp_atomic_st_ns) intersect {1'h0} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STSMAX_NS0_NSX0_DECERR            = binsof(cp_chi_atomic_st_opcode) intersect {7'h2C} && binsof(cp_atomic_st_ns) intersect {1'h0} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STMIN_NS0_NSX0_DECERR             = binsof(cp_chi_atomic_st_opcode) intersect {7'h2D} && binsof(cp_atomic_st_ns) intersect {1'h0} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STUSMAX_NS0_NSX0_DECERR           = binsof(cp_chi_atomic_st_opcode) intersect {7'h2E} && binsof(cp_atomic_st_ns) intersect {1'h0} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h1};
            illegal_bins ATOMICSTORE_STUMIN_NS0_NSX0_DECERR            = binsof(cp_chi_atomic_st_opcode) intersect {7'h2F} && binsof(cp_atomic_st_ns) intersect {1'h0} && binsof (cp_atomic_st_nsx) intersect {1'h0} && binsof (cp_atomic_st_err) intersect {1'h1};

        }
    endgroup : security_atomic_st_cg

   <% } %>

    covergroup chi_crd_cg;

       // #Cover.CHIAIU.v3.4.SCM.CreditLimitBin
        <% for(var i = 0; i < obj.nDCEs; i++) { %>
        cp_dce_ccr<%=i%>: coverpoint DCE_CCR<%=i%>_Val {
            bins dce_ccr_val_0           = {5'd0};
            bins dce_ccr_val_1           = {5'd1};
            bins dce_ccr_val_2           = {5'd2};
            bins dce_ccr_val_3           = {5'd3};
            bins dce_ccr_val_4           = {5'd4};
            bins dce_ccr_val_5           = {5'd5};
            bins dce_ccr_val_6           = {5'd6};
            bins dce_ccr_val_7           = {5'd7};
            bins dce_ccr_val_8           = {5'd8};
            bins dce_ccr_val_9           = {5'd9};
            bins dce_ccr_val_10          = {5'd10};
            bins dce_ccr_val_11          = {5'd11};
            bins dce_ccr_val_12          = {5'd12};
            bins dce_ccr_val_13          = {5'd13};
            bins dce_ccr_val_14          = {5'd14};
            bins dce_ccr_val_15          = {5'd15};
            bins dce_ccr_val_16          = {5'd16};
            bins dce_ccr_val_17          = {5'd17};
            bins dce_ccr_val_18          = {5'd18};
            bins dce_ccr_val_19          = {5'd19};
            bins dce_ccr_val_20          = {5'd20};
            bins dce_ccr_val_21          = {5'd21};
            bins dce_ccr_val_22          = {5'd22};
            bins dce_ccr_val_23          = {5'd23};
            bins dce_ccr_val_24          = {5'd24};
            bins dce_ccr_val_25          = {5'd25};
            bins dce_ccr_val_26          = {5'd26};
            bins dce_ccr_val_27          = {5'd27};
            bins dce_ccr_val_28          = {5'd28};
            bins dce_ccr_val_29          = {5'd29};
            bins dce_ccr_val_30          = {5'd30};
            bins dce_ccr_val_31          = {5'd31};
        }
        <% } %>

        <% for(var i = 0; i < obj.nDMIs; i++) { %>
        cp_dmi_ccr<%=i%>: coverpoint DMI_CCR<%=i%>_Val {
            bins dmi_ccr_val_0           = {5'd0};
            bins dmi_ccr_val_1           = {5'd1};
            bins dmi_ccr_val_2           = {5'd2};
            bins dmi_ccr_val_3           = {5'd3};
            bins dmi_ccr_val_4           = {5'd4};
            bins dmi_ccr_val_5           = {5'd5};
            bins dmi_ccr_val_6           = {5'd6};
            bins dmi_ccr_val_7           = {5'd7};
            bins dmi_ccr_val_8           = {5'd8};
            bins dmi_ccr_val_9           = {5'd9};
            bins dmi_ccr_val_10          = {5'd10};
            bins dmi_ccr_val_11          = {5'd11};
            bins dmi_ccr_val_12          = {5'd12};
            bins dmi_ccr_val_13          = {5'd13};
            bins dmi_ccr_val_14          = {5'd14};
            bins dmi_ccr_val_15          = {5'd15};
            bins dmi_ccr_val_16          = {5'd16};
            bins dmi_ccr_val_17          = {5'd17};
            bins dmi_ccr_val_18          = {5'd18};
            bins dmi_ccr_val_19          = {5'd19};
            bins dmi_ccr_val_20          = {5'd20};
            bins dmi_ccr_val_21          = {5'd21};
            bins dmi_ccr_val_22          = {5'd22};
            bins dmi_ccr_val_23          = {5'd23};
            bins dmi_ccr_val_24          = {5'd24};
            bins dmi_ccr_val_25          = {5'd25};
            bins dmi_ccr_val_26          = {5'd26};
            bins dmi_ccr_val_27          = {5'd27};
            bins dmi_ccr_val_28          = {5'd28};
            bins dmi_ccr_val_29          = {5'd29};
            bins dmi_ccr_val_30          = {5'd30};
            bins dmi_ccr_val_31          = {5'd31};
        }
        <% } %>

        <% for(var i = 0; i < obj.nDIIs; i++) { %>
        cp_dii_ccr<%=i%>: coverpoint DII_CCR<%=i%>_Val {
            bins dii_ccr_val_0           = {5'd0};
            bins dii_ccr_val_1           = {5'd1};
            bins dii_ccr_val_2           = {5'd2};
            bins dii_ccr_val_3           = {5'd3};
            bins dii_ccr_val_4           = {5'd4};
            bins dii_ccr_val_5           = {5'd5};
            bins dii_ccr_val_6           = {5'd6};
            bins dii_ccr_val_7           = {5'd7};
            bins dii_ccr_val_8           = {5'd8};
            bins dii_ccr_val_9           = {5'd9};
            bins dii_ccr_val_10          = {5'd10};
            bins dii_ccr_val_11          = {5'd11};
            bins dii_ccr_val_12          = {5'd12};
            bins dii_ccr_val_13          = {5'd13};
            bins dii_ccr_val_14          = {5'd14};
            bins dii_ccr_val_15          = {5'd15};
            bins dii_ccr_val_16          = {5'd16};
            bins dii_ccr_val_17          = {5'd17};
            bins dii_ccr_val_18          = {5'd18};
            bins dii_ccr_val_19          = {5'd19};
            bins dii_ccr_val_20          = {5'd20};
            bins dii_ccr_val_21          = {5'd21};
            bins dii_ccr_val_22          = {5'd22};
            bins dii_ccr_val_23          = {5'd23};
            bins dii_ccr_val_24          = {5'd24};
            bins dii_ccr_val_25          = {5'd25};
            bins dii_ccr_val_26          = {5'd26};
            bins dii_ccr_val_27          = {5'd27};
            bins dii_ccr_val_28          = {5'd28};
            bins dii_ccr_val_29          = {5'd29};
            bins dii_ccr_val_30          = {5'd30};
            bins dii_ccr_val_31          = {5'd31};
        }
        <% } %>

        // #Check.CHIAIU.v3.4.SCM.CounterState
        // #Cover.CHIAIU.v3.4.SCM.CounterStateBin
        <% for(var i = 0; i < obj.nDCEs; i++) { %>
        cp_dce_ccr_state<%=i%>: coverpoint DCE_CCR<%=i%>_state {
            bins dce_ccr_normal          = {3'd0};
            bins dce_ccr_empty           = {3'd1};
            bins dce_ccr_negative        = {3'd2};
            bins dce_ccr_full            = {3'd4};
            bins dce_ccr_ng_emty         = (3'd2 => 3'd1);
            bins dce_ccr_emty_nrml       = (3'd1 => 3'd0);
            bins dce_ccr_nrml_fl         = (3'd0 => 3'd4);
	    illegal_bins dce_ccr_fl_ng   = (3'd4 => 3'd2);
        }
        <% } %>

        <% for(var i = 0; i < obj.nDMIs; i++) { %>
        cp_dmi_ccr_state<%=i%>: coverpoint DMI_CCR<%=i%>_state {
            bins dmi_ccr_normal          = {3'd0};
            bins dmi_ccr_empty           = {3'd1};
            bins dmi_ccr_negative        = {3'd2};
            bins dmi_ccr_full            = {3'd4};
            bins dmi_ccr_ng_emty         = (3'd2 => 3'd1);
            bins dmi_ccr_emty_nrml       = (3'd1 => 3'd0);
            bins dmi_ccr_nrml_fl         = (3'd0 => 3'd4);
	    illegal_bins dmi_ccr_fl_ng   = (3'd4 => 3'd2);
        }
        <% } %>

        <% for(var i = 0; i < obj.nDIIs; i++) { %>
        cp_dii_ccr_state<%=i%>: coverpoint DII_CCR<%=i%>_state {
            bins dii_ccr_normal          = {3'd0};
            bins dii_ccr_empty           = {3'd1};
            bins dii_ccr_negative        = {3'd2};
            bins dii_ccr_full            = {3'd4};
            bins dii_ccr_ng_emty         = (3'd2 => 3'd1);
            bins dii_ccr_emty_nrml       = (3'd1 => 3'd0);
            bins dii_ccr_nrml_fl         = (3'd0 => 3'd4);
	    illegal_bins dii_ccr_fl_ng   = (3'd4 => 3'd2);
        }
        <% } %>

    endgroup : chi_crd_cg

    covergroup smi_req_cmstatus; //#Cover.CHIAIU.Error.Concerto.v3.0.smireqcmst
       
        cp_dtr_req: coverpoint  isdtr_req {
            bins cp_dtrreq = {1'h1};
        }

        cp_str_req: coverpoint  isstr_req {
            bins cp_strreq = {1'h1};
        }

        cp_dtw_rsp: coverpoint  isdtw_rsp {
            bins cp_dtwrsp = {1'h1};
        }

        cp_dtr_cmst: coverpoint  dtr_cmst {
          //  bins cp_dtr_cmst_82 = {8'h82};
            bins cp_dtr_cmst_83 = {8'h03};
            bins cp_dtr_cmst_84 = {8'h04};
        }

        cp_str_cmst: coverpoint  str_cmst {
           // bins cp_str_cmst_82 = {8'h82};
            bins cp_str_cmst_83   = {8'h03};
            bins cp_str_cmst_84   = {8'h04};
        }

        cp_dtwrsp_cmst: coverpoint  dtw_rsp_cmst {
           // bins cp_dtw_rsp_cmst_82 = {8'h82};
            bins cp_dtw_rsp_cmst_83 = {8'h03};
            bins cp_dtw_rsp_cmst_84 = {8'h04};
        }

        cp_dtr_req_x_cmst : cross cp_dtr_req, cp_dtr_cmst;
        cp_str_req_x_cmst : cross cp_str_req, cp_str_cmst;
        cp_dtw_rsp_x_cmst : cross cp_dtw_rsp, cp_dtwrsp_cmst;

    endgroup : smi_req_cmstatus;

    covergroup smi_req_wrong_id; //#Cover.CHIAIU.Error.Concerto.v3.0.smireqirquc
        cp_str_req: coverpoint  isstr_wtgtid {
            bins cp_w_tgtid_strreq = {1'h1};
        }

        cp_dtr_req: coverpoint  isdtr_wtgtid {
            bins cp_w_tgtid_dtrreq = {1'h1};
        }

        cp_sys_req: coverpoint  issysreq_wtgtid {
            bins cp_w_tgtid_sysreq = {1'h1};
        }

        cp_snp_req: coverpoint  issnpreq_wtgtid {
            bins cp_w_tgtid_snpreq = {1'h1};
        }

        cp_cmd_rsp: coverpoint  iscmdrsp_wtgtid {
            bins cp_w_tgtid_cmd_rsp = {1'h1};
        }

        cp_dtr_rsp: coverpoint  isdtrrsp_wtgtid {
            bins cp_w_tgtid_dtr_rsp = {1'h1};
        }

        cp_dtw_rsp: coverpoint  isdtwrsp_wtgtid {
            bins cp_w_tgtid_dtw_rsp = {1'h1};
        }

        cp_sys_rsp: coverpoint  issysrsp_wtgtid {
            bins cp_w_tgtid_sys_rsp = {'h1};
        }

//        cp_dtwdbg_rsp: coverpoint  isdtwdbgrsp_wtgtid {
//            bins cp_w_tgtid_dtwdbg_rsp = {1'h1};
//        }

        cp_chi_irq_uc: coverpoint  irq_uc {
            bins cp_irq_uc = {1'h1};
        }
        str_req_x_irq_uc :cross cp_str_req,cp_chi_irq_uc;
        dtr_req_x_irq_uc :cross cp_dtr_req,cp_chi_irq_uc;
        sys_req_x_irq_uc :cross cp_sys_req,cp_chi_irq_uc;
        snp_req_x_irq_uc :cross cp_snp_req,cp_chi_irq_uc;
        cmd_rsp_x_irq_uc :cross cp_cmd_rsp,cp_chi_irq_uc;
        dtr_rsp_x_irq_uc :cross cp_dtr_rsp,cp_chi_irq_uc;
        dtw_rsp_x_irq_uc :cross cp_dtw_rsp,cp_chi_irq_uc;
        sys_rsp_x_irq_uc :cross cp_sys_rsp,cp_chi_irq_uc;
//        dtwdbg_rsp_x_irq_uc :coverpoint cp_dtwdbg_rsp,cp_chi_irq_uc;

    endgroup : smi_req_wrong_id;

    covergroup chi_cmnds_irqc; //#Cover.CHIAIU.Error.Concerto.v3.0.smireqirquc	
        cp_chi_cmnds: coverpoint chi_commands {
            bins REQLCRDRETURN        = {7'h00};
            bins READSHARED           = {7'h01};
            bins READCLEAN            = {7'h02};
            bins READONCE             = {7'h03};
            bins READNOSNP            = {7'h04};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            bins PCRDRETURN           = {7'h05};
            <% } %>
            ignore_bins RSVD_6        = {7'h06}; // TODO: make it illegal later(unsupported_txn)
            bins READUNIQUE           = {7'h07};
            bins CLEANSHARED          = {7'h08};
            bins CLEANINVALID         = {7'h09};
            bins MAKEINVALID          = {7'h0A};
            bins CLEANUNIQUE          = {7'h0B};
            bins MAKEUNIQUE           = {7'h0C};
            bins EVICT                = {7'h0D};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            ignore_bins EOBARRIER     = {7'h0E};
            ignore_bins ECBARRIER     = {7'h0F};
            <% } %>
            ignore_bins RSVD_10_13    = {[7'h10 : 7'h13]}; // TODO: make it illegal later(unsupported_txn)
            bins DVMOP                = {7'h14};
            bins WRITEEVICTFULL       = {7'h15};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            bins WRITECLEANPTL        = {7'h16};
            <% } %>
            bins WRITECLEANFULL       = {7'h17};
            bins WRITEUNIQUEPTL       = {7'h18};
            bins WRITEUNIQUEFULL      = {7'h19};
            bins WRITEBACKPTL         = {7'h1A};
            bins WRITEBACKFULL        = {7'h1B};
            bins WRITENOSNPPTL        = {7'h1C};
            bins WRITENOSNPFULL       = {7'h1D};
            ignore_bins RSVD_1E_1F    = {[7'h1E : 7'h1F]}; // TODO: make it illegal later(unsupported_txn)
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins WRITEUNIQUEFULLSTASH = {7'h20};
            ignore_bins WRITEUNIQUEPTLSTASH  = {7'h21};
            bins STASHONCESHARED      = {7'h22};
            bins STASHONCEUNIQUE      = {7'h23};
            bins READONCECLEANINVALID = {7'h24};
            bins READONCEMAKEINVALID  = {7'h25};
            bins READNOTSHAREDDIRTY   = {7'h26};
            bins CLEANSHAREDPERSIST   = {7'h27};
            bins ATOMICSTORE_STADD    = {7'h28};
            bins ATOMICSTORE_STCLR    = {7'h29};
            bins ATOMICSTORE_STEOR    = {7'h2A};
            bins ATOMICSTORE_STSET    = {7'h2B};
            bins ATOMICSTORE_STSMAX   = {7'h2C};
            bins ATOMICSTORE_STMIN    = {7'h2D};
            bins ATOMICSTORE_STUSMAX  = {7'h2E};
            bins ATOMICSTORE_STUMIN   = {7'h2F};
            bins ATOMICLOAD_LDADD     = {7'h30};
            bins ATOMICLOAD_LDCLR     = {7'h31};
            bins ATOMICLOAD_LDEOR     = {7'h32};
            bins ATOMICLOAD_LDSET     = {7'h33};
            bins ATOMICLOAD_LDSMAX    = {7'h34};
            bins ATOMICLOAD_LDMIN     = {7'h35};
            bins ATOMICLOAD_LDUSMAX   = {7'h36};
            bins ATOMICLOAD_LDUMIN    = {7'h37};
            bins ATOMICSWAP           = {7'h38};
            bins ATOMICCOMPARE        = {7'h39};
            bins PREFETCHTARGET       = {7'h3A};
            ignore_bins RSVD_3B_3F    = {[7'h3B : 7'h3F]}; // TODO: make it illegal later(unsupported_txn)
          <% } %>
        }
    endgroup : chi_cmnds_irqc;


    covergroup uncorr_errtype_errcode; //#Cover.CHIAIU.Error.Concerto.v3.0.errtype
             
        cp_errtype_code: coverpoint  errtype_code {
           ignore_bins cp_data_corr_err       = {4'h0};
           ignore_bins cp_cache_corr_err      = {4'h1};
           ignore_bins cp_wr_rsp_err          = {4'h2};
           ignore_bins cp_rd_rsp_err          = {4'h3};
           bins cp_snp_rsp_err        	      = {4'h4};
           bins cp_dec_err             	      = {4'h7};
           bins cp_sysevent_err               = {4'hA};
           bins cp_sysco_err                  = {4'hB};
           bins cp_soft_progr_err             = {4'hC};
        }

        cp_dec_err_type: coverpoint  dec_err_type {
            bins cp_no_addr_hit               = {4'h0};
            bins cp_multiple_addr_hit         = {4'h1};
            bins cp_illegal_csr               = {4'h2};
            bins cp_illegal_dii               = {4'h3};
            bins cp_illegal_security_access   = {4'h4};
        }

        cp_transport_err_type: coverpoint  transport_err_type {
            bins wrong_tgt_id                 = {1'h0};
        }

        cp_sys_evt_err_type: coverpoint  sysevt_err_type {
            bins timeout_err_msg              = {1'h0};
            bins timeout_err_intf             = {1'h1};
        }

        cp_sysco_evt_err_type: coverpoint  sysco_err_type {
            bins sysco_timeout_err_msg        = {1'h0};
        }

        cp_soft_prog_err_type: coverpoint  soft_prog_err_type {
            bins cp_atomic_txn                = {4'h0};
            bins cp_no_crds_confg             = {4'h1};
            bins cp_unconn_dmi                = {4'h2};
            bins cp_unconn_dii                = {4'h3};
            bins cp_unconn_dce                = {4'h5};
        }

    endgroup : uncorr_errtype_errcode

<% if (obj.useResiliency) { %>
    covergroup correctable_error_threshold;

       cp_corr_err_threshold : coverpoint <%=obj.BlockId%>_corr_err_threshold {
  	bins cp_corr_err_threshold  	= {[8'h2:8'hff]}; 
       }

       cp_corr_err_over_thres_fault : coverpoint <%=obj.BlockId%>_corr_err_over_thres_fault {
   	bins cp_cerr_over_thres_fault_zero 	= {1'b0};
  	bins cp_cerr_over_thres_fault_one	= {1'b1};
       }

       cp_corr_err_counter: coverpoint <%=obj.BlockId%>_corr_err_counter {
  	bins cp_counter_0	= {9'h0};
   	bins cp_counter_1  	= {9'h1}; 
   	bins cp_counter_2  	= {9'h2}; 
  	bins cp_counter_3  	= {9'h3}; 
  	bins cp_counter_4  	= {[9'h4:9'h1ff]}; 
       }

    endgroup
<%}%>
<%if (obj.interfaces.chiInt.params.checkType !== "NONE") {%>
// #Cover.CHI.v3.7.InterfaceParity.Error
    covergroup interface_parity_error;

       	cp_err_det_en : coverpoint <%=obj.BlockId%>_ip_err_err_det_en {
	    bins err_det_en_not_asserted	= {1'b0};
	    bins err_det_en_asserted		= {1'b1};
	}

       	cp_err_int_en : coverpoint <%=obj.BlockId%>_ip_err_err_int_en {
	    bins err_int_en_not_asserted	= {1'b0};
	    bins err_int_en_asserted		= {1'b1};
	}

       	cp_err_type : coverpoint <%=obj.BlockId%>_ip_err_err_type {
  	    bins ip_error  	= {'hD}; 
       	}

       	cp_err_info : coverpoint <%=obj.BlockId%>_ip_err_err_info {
  	    bins SRSP_channel  		= {'hD}; 
  	    bins SNP_channel  		= {'hC}; 
  	    bins RDATA_channel  	= {'hB}; 
  	    bins WDATA_channel  	= {'hA}; 
  	    bins CRSP_channel  		= {'h9}; 
  	    bins REQ_channel  		= {'h8}; 
  	    bins COMMON_channel  	= {'hF}; 
  	    bins SYSCO_channel  	= {'hE}; 
       	}

       	cp_err_valid : coverpoint <%=obj.BlockId%>_ip_err_err_valid {
	    bins err_valid_asserted	= {1'b1};
	}

       	cp_IRQ_UC : coverpoint <%=obj.BlockId%>_ip_err_IRQ_UC {
	    bins IRQ_UC_not_asserted	= {1'b0};
	    bins IRQ_UC_asserted	= {1'b1};
	}

       	cp_mission_fault: coverpoint <%=obj.BlockId%>_ip_err_mission_fault {
	    bins mission_fault_asserted	= {1'b1};
	} 

	cross_err_det_int_type_info_valid_IRQ_fault: cross cp_err_det_en, cp_err_int_en, cp_err_type, cp_err_info, cp_err_valid, cp_IRQ_UC, cp_mission_fault {
	    ignore_bins err_int_IRQ_UC            		= binsof(cp_err_int_en) intersect {0} && binsof(cp_IRQ_UC) intersect {1};
	    ignore_bins err_det_err_type_err_valid_IRQ_UC	= binsof(cp_err_det_en) intersect {0} && binsof(cp_err_type) && binsof(cp_err_info) && binsof(cp_err_valid) && binsof(cp_IRQ_UC) intersect {1};
	}

    endgroup
<%}%>

    covergroup Connectivity_cov;
	    cp_hexAiuDcevec: coverpoint AiuDce_connectivity_vec {
		    <% for(var i = 0; i < (2**obj.nDCEs); i++) {%>
			       bins vec_value_<%=i%>  = {'d<%=i%>};
			<%}%>
		}

	    cp_hexAiuDmivec: coverpoint AiuDmi_connectivity_vec {
		    <% for(var j = 0; j < (2**obj.nDMIs); j++) {%>
			       bins vec_value_<%=j%>  = {'d<%=j%>};
			<%}%>
		}

	    cp_hexAiuDiivec: coverpoint AiuDii_connectivity_vec {
		    <% for(var k = 0; k < (2**obj.nDIIs); k++) {%>
			       bins vec_value_<%=k%>  = {'d<%=k%>};
			<%}%>
		}

        cp_chi_req_opcode: coverpoint req_opcode {
            bins REQLCRDRETURN        = {7'h00};
            bins READSHARED           = {7'h01};
            bins READCLEAN            = {7'h02};
            bins READONCE             = {7'h03};
            bins READNOSNP            = {7'h04};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            bins PCRDRETURN           = {7'h05};
            <% } %>
            ignore_bins RSVD_6        = {7'h06}; // TODO: make it illegal later(unsupported_txn)
            bins READUNIQUE           = {7'h07};
            bins CLEANSHARED          = {7'h08};
            bins CLEANINVALID         = {7'h09};
            bins MAKEINVALID          = {7'h0A};
            bins CLEANUNIQUE          = {7'h0B};
            bins MAKEUNIQUE           = {7'h0C};
            bins EVICT                = {7'h0D};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            ignore_bins EOBARRIER     = {7'h0E};
            ignore_bins ECBARRIER     = {7'h0F};
            <% } %>
            ignore_bins RSVD_10_13    = {[7'h10 : 7'h13]}; // TODO: make it illegal later(unsupported_txn)
            bins DVMOP                = {7'h14};
            bins WRITEEVICTFULL       = {7'h15};
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            bins WRITECLEANPTL        = {7'h16};
            <% } %>
            bins WRITECLEANFULL       = {7'h17};
            bins WRITEUNIQUEPTL       = {7'h18};
            bins WRITEUNIQUEFULL      = {7'h19};
            bins WRITEBACKPTL         = {7'h1A};
            bins WRITEBACKFULL        = {7'h1B};
            bins WRITENOSNPPTL        = {7'h1C};
            bins WRITENOSNPFULL       = {7'h1D};
            ignore_bins RSVD_1E_1F    = {[7'h1E : 7'h1F]}; // TODO: make it illegal later(unsupported_txn)
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            ignore_bins WRITEUNIQUEFULLSTASH = {7'h20};
            ignore_bins WRITEUNIQUEPTLSTASH  = {7'h21};
            bins STASHONCESHARED      = {7'h22};
            bins STASHONCEUNIQUE      = {7'h23};
            bins READONCECLEANINVALID = {7'h24};
            bins READONCEMAKEINVALID  = {7'h25};
            bins READNOTSHAREDDIRTY   = {7'h26};
            bins CLEANSHAREDPERSIST   = {7'h27};
            bins ATOMICSTORE_STADD    = {7'h28};
            bins ATOMICSTORE_STCLR    = {7'h29};
            bins ATOMICSTORE_STEOR    = {7'h2A};
            bins ATOMICSTORE_STSET    = {7'h2B};
            bins ATOMICSTORE_STSMAX   = {7'h2C};
            bins ATOMICSTORE_STMIN    = {7'h2D};
            bins ATOMICSTORE_STUSMAX  = {7'h2E};
            bins ATOMICSTORE_STUMIN   = {7'h2F};
            bins ATOMICLOAD_LDADD     = {7'h30};
            bins ATOMICLOAD_LDCLR     = {7'h31};
            bins ATOMICLOAD_LDEOR     = {7'h32};
            bins ATOMICLOAD_LDSET     = {7'h33};
            bins ATOMICLOAD_LDSMAX    = {7'h34};
            bins ATOMICLOAD_LDMIN     = {7'h35};
            bins ATOMICLOAD_LDUSMAX   = {7'h36};
            bins ATOMICLOAD_LDUMIN    = {7'h37};
            bins ATOMICSWAP           = {7'h38};
            bins ATOMICCOMPARE        = {7'h39};
            bins PREFETCHTARGET       = {7'h3A};
            ignore_bins RSVD_3B_3F    = {[7'h3B : 7'h3F]}; // TODO: make it illegal later(unsupported_txn)
          <% } %>
        }
        
		cross_cp_chi_req_opcode_x_cp_hexAiuDcevec: cross cp_chi_req_opcode, cp_hexAiuDcevec {
		    ignore_bins READNOSNP_UNCONNECTED_DCE            = binsof(cp_chi_req_opcode) intersect {7'h04} && binsof(cp_hexAiuDcevec);
		    ignore_bins WRITENOSNPPTL_UNCONNECTED_DCE        = binsof(cp_chi_req_opcode) intersect {7'h1C} && binsof(cp_hexAiuDcevec);
		    ignore_bins WRITENOSNPFULL_UNCONNECTED_DCE       = binsof(cp_chi_req_opcode) intersect {7'h1D} && binsof(cp_hexAiuDcevec);
        ignore_bins REQLCRDRETURN_UNCONNECTED_DCE        = binsof(cp_chi_req_opcode) intersect {7'h00} && binsof(cp_hexAiuDcevec);
        ignore_bins DVMOP_UNCONNECTED_DCE                = binsof(cp_chi_req_opcode) intersect {7'h14} && binsof(cp_hexAiuDcevec);
			<% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
		    ignore_bins PREFETCHTARGET_UNCONNECTED_DCE       = binsof(cp_chi_req_opcode) intersect {7'h3A} && binsof(cp_hexAiuDcevec);
        <% } %>
      }

		cross_cp_chi_req_opcode_x_cp_hexAiuDmivec: cross cp_chi_req_opcode, cp_hexAiuDmivec{ 
      ignore_bins REQLCRDRETURN_UNCONNECTED_DMI        = binsof(cp_chi_req_opcode) intersect {7'h00} && binsof(cp_hexAiuDmivec);
      ignore_bins DVMOP_UNCONNECTED_DMI                = binsof(cp_chi_req_opcode) intersect {7'h14} && binsof(cp_hexAiuDmivec);
      <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
      ignore_bins PREFETCHTARGET_UNCONNECTED_DMI       = binsof(cp_chi_req_opcode) intersect {7'h3A} && binsof(cp_hexAiuDmivec);
      <% } %>
    }

		cross_cp_chi_req_opcode_x_cp_hexAiuDiivec: cross cp_chi_req_opcode, cp_hexAiuDiivec {
		   ignore_bins REQLCRDRETURN_UNCONNECTED_DII        = binsof(cp_chi_req_opcode) intersect {7'h00} && binsof(cp_hexAiuDiivec);
       ignore_bins DVMOP_UNCONNECTED_DII                = binsof(cp_chi_req_opcode) intersect {7'h14} && binsof(cp_hexAiuDiivec);
       <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
       ignore_bins PREFETCHTARGET_UNCONNECTED_DII       = binsof(cp_chi_req_opcode) intersect {7'h3A} && binsof(cp_hexAiuDiivec);
       <% } %>
       ignore_bins READSHARED_UNCONNECTED_DII           = binsof(cp_chi_req_opcode) intersect {7'h01} && binsof(cp_hexAiuDiivec);
		   ignore_bins READCLEAN_UNCONNECTED_DII            = binsof(cp_chi_req_opcode) intersect {7'h02} && binsof(cp_hexAiuDiivec);
		   ignore_bins READONCE_UNCONNECTED_DII             = binsof(cp_chi_req_opcode) intersect {7'h03} && binsof(cp_hexAiuDiivec);
		   ignore_bins PCRDRETURN_UNCONNECTED_DII           = binsof(cp_chi_req_opcode) intersect {7'h05} && binsof(cp_hexAiuDiivec);
		   ignore_bins READUNIQUE_UNCONNECTED_DII           = binsof(cp_chi_req_opcode) intersect {7'h07} && binsof(cp_hexAiuDiivec);
		   ignore_bins CLEANUNIQUE_UNCONNECTED_DII          = binsof(cp_chi_req_opcode) intersect {7'h0B} && binsof(cp_hexAiuDiivec);
		   ignore_bins MAKEUNIQUE_UNCONNECTED_DII           = binsof(cp_chi_req_opcode) intersect {7'h0C} && binsof(cp_hexAiuDiivec);
		   ignore_bins EVICT_UNCONNECTED_DII                = binsof(cp_chi_req_opcode) intersect {7'h0D} && binsof(cp_hexAiuDiivec);
		   ignore_bins WRITEUNIQUEPTL_UNCONNECTED_DII       = binsof(cp_chi_req_opcode) intersect {7'h18} && binsof(cp_hexAiuDiivec);
		   ignore_bins WRITEUNIQUEFULL_UNCONNECTED_DII      = binsof(cp_chi_req_opcode) intersect {7'h19} && binsof(cp_hexAiuDiivec);
           <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
		   ignore_bins STASHONCESHARED_UNCONNECTED_DII      = binsof(cp_chi_req_opcode) intersect {7'h22} && binsof(cp_hexAiuDiivec);
		   ignore_bins STASHONCEUNIQUE_UNCONNECTED_DII      = binsof(cp_chi_req_opcode) intersect {7'h23} && binsof(cp_hexAiuDiivec);
		   ignore_bins READONCECLEANINVALID_UNCONNECTED_DII = binsof(cp_chi_req_opcode) intersect {7'h24} && binsof(cp_hexAiuDiivec);
		   ignore_bins READONCEMAKEINVALID_UNCONNECTED_DII  = binsof(cp_chi_req_opcode) intersect {7'h25} && binsof(cp_hexAiuDiivec);
		   ignore_bins READNOTSHAREDDIRTY_UNCONNECTED_DII   = binsof(cp_chi_req_opcode) intersect {7'h26} && binsof(cp_hexAiuDiivec);
            <% } %>
		}

	endgroup : Connectivity_cov 

	covergroup sysco_req_commands;

    cp_dce_target_ids: coverpoint target_id {  
		   <% for(var i = 0; i < obj.AiuInfo[obj.Id].hexAiuConnectedDceFunitId.length; i++) { %>
				  bins DCE_CONNECTED_<%=i%> = {'d<%=obj.AiuInfo[obj.Id].hexAiuConnectedDceFunitId[i]%>};
		   <% } %>
    }
    
    cp_dve_target_ids: coverpoint target_id {
      <% for(var i = 0; i < obj.DveInfo.length; i++) { %>
         bins DVE_ID<%=i%> = {'d<%=obj.DveInfo[i].FUnitId%>};
      <% } %>
   }

		cp_aiu_source_ids: coverpoint source_id {
		   bins AIU_ID<%=obj.Id%> = {'d<%=obj.AiuInfo[obj.Id].FUnitId%>};
		}
		
		cp_illegal_sysco_req_rsp: cross cp_aiu_source_ids,cp_dce_target_ids {
		<% for(var j = 0; j < obj.DceInfo.length; j++) { %>
		     <% if (!obj.AiuInfo[obj.Id].hexAiuConnectedDceFunitId.includes(obj.DceInfo[j].FUnitId)) { %>  
		          illegal_bins AIU<%=obj.Id%>_UNCONNECTED_DCE<%=j%> = binsof(cp_aiu_source_ids) intersect {'d<%=obj.Id%>} && binsof(cp_dce_target_ids) intersect {'d<%=obj.DceInfo[j].FUnitId%>} ;
		     <% } %>
		<% } %>
		}
	endgroup : sysco_req_commands 

	covergroup sysco_rsp_commands;

    cp_dce_source_ids: coverpoint source_id {
		   <% for(var i = 0; i < obj.AiuInfo[obj.Id].hexAiuConnectedDceFunitId.length; i++) { %>
				  bins DCE_CONNECTED_<%=i%> = {'d<%=obj.AiuInfo[obj.Id].hexAiuConnectedDceFunitId[i]%>};
		   <% } %>
    }
    
    cp_dve_source_ids: coverpoint source_id {
		   
      <% for(var i = 0; i < obj.DveInfo.length; i++) { %>
         bins DVE_ID<%=i%> = {'d<%=obj.DveInfo[i].FUnitId%>};
      <% } %>
    }

		cp_aiu_target_ids: coverpoint target_id {

		   bins AIU_ID<%=obj.Id%> = {'d<%=obj.AiuInfo[obj.Id].FUnitId%>};
		}
		
		cp_illegal_sysco_rsp: cross cp_dce_source_ids,cp_aiu_target_ids {
		    
		   <% for(var j = 0; j < obj.DceInfo.length; j++) { %>
		        <% if (!obj.AiuInfo[obj.Id].hexAiuConnectedDceFunitId.includes(obj.DceInfo[j].FUnitId)) { %>  
		             illegal_bins DCE<%=j%>_UNCONNECTED_AIU<%=obj.Id%> = binsof(cp_dce_source_ids) intersect {'d<%=obj.DceInfo[j].FUnitId%>} && binsof(cp_aiu_target_ids) intersect {'d<%=obj.Id%>} ;
		        <% } %>
		   <% } %>
		}
	endgroup : sysco_rsp_commands 

	covergroup addr_boundary_cg;

        cp_boundary_start_addr: coverpoint  boundary_start_addr {
            bins boundary_start_addr = {1'h1};
        }

        cp_boundary_end_addr: coverpoint  boundary_end_addr {
            bins boundary_end_addr = {1'h1};
        }

        cp_one_byte_before_start_addr: coverpoint  one_byte_before_start_addr {
            bins boundary_end_addr = {1'h1};
        }

        cp_one_byte_after_end_addr: coverpoint  one_byte_after_end_addr {
            bins one_byte_after_end_addr = {1'h1};
        }

        <% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
        cp_size_gpra<%=i%>: coverpoint size_gpra<%=i%> {
            bins gpra<%=i%>_0           = {5'd0};
            bins gpra<%=i%>_1           = {5'd1};
            bins gpra<%=i%>_2           = {5'd2};
            bins gpra<%=i%>_3           = {5'd3};
            bins gpra<%=i%>_4           = {5'd4};
            bins gpra<%=i%>_5           = {5'd5};
            bins gpra<%=i%>_6           = {5'd6};
            bins gpra<%=i%>_7           = {5'd7};
            bins gpra<%=i%>_8           = {5'd8};
            bins gpra<%=i%>_9           = {5'd9};
            bins gpra<%=i%>_10          = {5'd10};
            bins gpra<%=i%>_11          = {5'd11};
            bins gpra<%=i%>_12          = {5'd12};
            bins gpra<%=i%>_13          = {5'd13};
            bins gpra<%=i%>_14          = {5'd14};
            bins gpra<%=i%>_15          = {5'd15};
            bins gpra<%=i%>_16          = {5'd16};
            bins gpra<%=i%>_17          = {5'd17};
            bins gpra<%=i%>_18          = {5'd18};
            bins gpra<%=i%>_19          = {5'd19};
            bins gpra<%=i%>_20          = {5'd20};
            bins gpra<%=i%>_21          = {5'd21};
            bins gpra<%=i%>_22          = {5'd22};
            bins gpra<%=i%>_23          = {5'd23};
            bins gpra<%=i%>_24          = {5'd24};
            bins gpra<%=i%>_25          = {5'd25};
            bins gpra<%=i%>_26          = {5'd26};
            bins gpra<%=i%>_27          = {5'd27};
            bins gpra<%=i%>_28          = {5'd28};
            bins gpra<%=i%>_29          = {5'd29};
            bins gpra<%=i%>_30          = {5'd30};
            bins gpra<%=i%>_31          = {5'd31};
        }
        <% } %>


        cp_size_ig_1: coverpoint gpra_sizeofig_1 {
            bins sizeofig_1          = {1'd1};
        }

        cp_size_ig_2: coverpoint gpra_sizeofig_2 {
            bins sizeofig_2          = {1'd1};
        }

        cp_size_ig_4: coverpoint gpra_sizeofig_4 {
            bins sizeofig_4          = {1'd1};
        }

        cp_size_ig_8: coverpoint gpra_sizeofig_8 {
            bins sizeofig_8          = {1};
        }

        cp_size_ig_16: coverpoint gpra_sizeofig_16 {
            bins sizeofig_16          = {1};
        }

        <% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
              size_x_sizeig_gpra<%=i%>_16: cross cp_size_gpra<%=i%>, cp_size_ig_16;
              size_x_sizeig_gpra<%=i%>_8 : cross cp_size_gpra<%=i%>, cp_size_ig_8;
              size_x_sizeig_gpra<%=i%>_4: cross cp_size_gpra<%=i%>, cp_size_ig_4;
              size_x_sizeig_gpra<%=i%>_2: cross cp_size_gpra<%=i%>, cp_size_ig_2;
              size_x_sizeig_gpra<%=i%>_1: cross cp_size_gpra<%=i%>, cp_size_ig_1;
        <%}%>

	endgroup : addr_boundary_cg 

<%if(obj.AiuInfo[obj.Id].cmpInfo.nSnpInFlight + obj.AiuInfo[obj.Id].cmpInfo.nDvmSnpInFlight - 1 > 128) {%>
	// #Cover.CHI.v3.7.MaxSttEntries.Full
	covergroup larger_stt_cg;

        cp_num_snp_req_in_stt: coverpoint  num_snp_req_in_stt {
        <% for(var i = 0; i < 127; i = i+8) { %>
            bins range_<%=i%>    = {[<%=i%>:<%=i+7%>]};
        <%}%>
        }
        cp_skid_buffer_full: coverpoint skid_buffer_full {
            bins empty         = {0};
            bins full          = {1};
        }

	endgroup : larger_stt_cg 
<%}%>

    extern function void collect_connectivity_all_comb(AiuDce_connectivity_vec_type AiuDce_vec,AiuDmi_connectivity_vec_type AiuDmi_vec,AiuDii_connectivity_vec_type AiuDii_vec);
    extern function void collect_cmd_type_x_connectivity(chi_req_seq_item txn,AiuDce_connectivity_vec_type AiuDce_vec,AiuDmi_connectivity_vec_type AiuDmi_vec,AiuDii_connectivity_vec_type AiuDii_vec);
	extern function void collect_sysco_req_cmds(smi_ncore_unit_id_bit_t src_id,smi_ncore_unit_id_bit_t tgt_id);
	extern function void collect_sysco_rsp_cmds(smi_ncore_unit_id_bit_t src_id,smi_ncore_unit_id_bit_t tgt_id);
    extern function void collect_chi_req_flit(chi_req_seq_item txn);
    extern function void collect_chi_wdata_flit(chi_aiu_scb_txn scb_txn_item);
    extern function void collect_chi_wdata_datlcrdreturn(chi_dat_seq_item chi_cov_write_data_pkt);
    extern function void collect_chi_rdata_flit(chi_dat_seq_item txn);
    extern function void collect_chi_srsp_flit(chi_rsp_seq_item txn);
    extern function void collect_chi_crsp_flit(chi_rsp_seq_item txn);
    extern function void collect_chi_snp_flit(chi_snp_seq_item txn);
    extern function void collect_ott_entry(chi_aiu_scb_txn scb_txn_item);
    extern function void collect_rd_ott_entry(chi_aiu_scb_txn scb_txn_item);
    extern function void collect_snp_req_snprespdata(chi_aiu_scb_txn scb_txn_item);
    extern function void collect_snp_req_snpresp(chi_aiu_scb_txn scb_txn_item);
    extern function void collect_atomic_load_req_resp(chi_aiu_scb_txn scb_txn_item);
    extern function void collect_sys_req_events(sysreq_pkt_t txn);
    extern function void collect_stasting_snoops();
    extern function void collect_chi_wr_req_cresp(chi_aiu_scb_txn scb_txn_item, chi_rsp_seq_item crsp_pkt);
    extern function void collect_ccr_val();
    extern function void collect_str_req_wtgtid(smi_seq_item m_pkt);
    extern function void collect_dtr_req_wtgtid(smi_seq_item m_pkt);
    extern function void collect_sys_req_wtgtid(smi_seq_item m_pkt);
    extern function void collect_snp_req_wtgtid(smi_seq_item m_pkt);
    extern function void collect_cmd_rsp_wtgtid(smi_seq_item m_pkt);
    extern function void collect_dtr_rsp_wtgtid(smi_seq_item m_pkt);
    extern function void collect_dtw_rsp_wtgtid(smi_seq_item m_pkt);
    extern function void collect_sys_rsp_wtgtid(smi_seq_item m_pkt);
    extern function void collect_dtwdbg_rsp_wtgtid(smi_seq_item m_pkt);
    extern function void collect_errtype_errcode();
    extern task collect_irq_uc();
    extern task collect_crd_state();
    extern function void collect_boundary_addr();
    extern function void collect_gpra_size();
    extern task collect_size_of_ig();
<%if(obj.AiuInfo[obj.Id].cmpInfo.nSnpInFlight + obj.AiuInfo[obj.Id].cmpInfo.nDvmSnpInFlight - 1 > 128) {%>
    extern function void collect_larger_stt_info(logic [127:0] stt_entry_validvec, logic stt_skid_buffer_full);
<%}%>
<% if (obj.useResiliency) { %>
    extern task cerr_threshold();
<%}%>
<%if (obj.interfaces.chiInt.params.checkType !== "NONE") {%>
    extern task ip_error_cov();
<%}%>
    
    extern function new();
endclass // chi_aiu_coverage

function void chi_aiu_coverage::collect_connectivity_all_comb(AiuDce_connectivity_vec_type AiuDce_vec,AiuDmi_connectivity_vec_type AiuDmi_vec,AiuDii_connectivity_vec_type AiuDii_vec);
    AiuDce_connectivity_vec = AiuDce_vec;
    AiuDmi_connectivity_vec = AiuDmi_vec;
    AiuDii_connectivity_vec = AiuDii_vec;
    Connectivity_cov.sample();
endfunction

function void chi_aiu_coverage::collect_cmd_type_x_connectivity(chi_req_seq_item txn,AiuDce_connectivity_vec_type AiuDce_vec,AiuDmi_connectivity_vec_type AiuDmi_vec,AiuDii_connectivity_vec_type AiuDii_vec);
    req_opcode         	= txn.opcode;
    AiuDce_connectivity_vec = AiuDce_vec;
    AiuDmi_connectivity_vec = AiuDmi_vec;
    AiuDii_connectivity_vec = AiuDii_vec;
    Connectivity_cov.sample();
endfunction

function void chi_aiu_coverage::collect_sysco_req_cmds(smi_ncore_unit_id_bit_t src_id,smi_ncore_unit_id_bit_t tgt_id);
     source_id = src_id;
     target_id = tgt_id;
     sysco_req_commands.sample();
endfunction

function void chi_aiu_coverage::collect_sysco_rsp_cmds(smi_ncore_unit_id_bit_t src_id,smi_ncore_unit_id_bit_t tgt_id);
     source_id = src_id;
     target_id = tgt_id;
     sysco_rsp_commands.sample();
endfunction

function void chi_aiu_coverage::collect_chi_req_flit(chi_req_seq_item txn);
    req_opcode         	= txn.opcode;
    addr               	= txn.addr;
    size               	= txn.size;
    expcompack         	= txn.expcompack;
    snoopme            	= txn.snoopme;
    excl               	= txn.excl;
    order              	= txn.order;
    tracetag           	= txn.tracetag;
    lcrdv              	= txn.lcrdv;
    qos                	= txn.qos;
    tgtid              	= txn.tgtid;
    srcid              	= txn.srcid;
    txnid              	= txn.txnid;
    likelyshared        = txn.likelyshared;
    pcrdtype           	= txn.pcrdtype;
    allowretry         	= txn.allowretry;
    ewa      	 	= txn.memattr[0];
    mem_type		= txn.memattr[1];
    cacheable          	= txn.memattr[2];
    allocate         	= txn.memattr[3];
    snpattr      	= txn.snpattr;
    lpid      		= txn.lpid;
  //returnnid      	= txn.returnnid;
  //returntxnid      	= txn.returntxnid;
    stashnid      	= txn.stashnid;
    stashnidvalid      	= txn.stashnidvalid;
    stashlpid      	= txn.stashlpid;
    stashlpidvalid      = txn.stashlpidvalid;
    endian      	= txn.endian;
    req_ns              = txn.ns;
    size_1_byte_align = 1'h0;
    size_2_byte_align = 1'h0;
    size_4_byte_align = 1'h0;
    size_8_byte_align = 1'h0;
    size_16_byte_align = 1'h0;
    size_32_byte_align = 1'h0;

    if (txn.lcrdv) begin
        // cycles required by AIU to release credit
        creditv_dly = ($time - t_chi_req_flitv[0])/10ns;
        chi_cmd_req_dly = ($time - t_chi_req_flitv[$])/10ns;
        t_chi_req_flitv = {}; // delete all items
    end

  // if (addr%size == 0) begin
  //      atomic_addr_size_alignment.sample();
  // end

        req_txn_q.push_back(txn);
<% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    if (req_opcode inside {[7'h28:7'h2F]} ) begin
        atomic_addr_size_alignment.sample();
    end else if (req_opcode inside {[7'h30:7'h39]}) begin
        atomic_addr_size_alignment.sample();
    end
<% } %>

    // delay btw 2 back to back chi cmd reqs
    chi_cmd_req_dly = ($time - t_chi_req_flitv[$])/10ns;
    t_chi_req_flitv.push_back($time);
    chi_req_port.sample();
endfunction // collect_chi_req_seq_item

function void chi_aiu_coverage::collect_chi_wdata_datlcrdreturn(chi_dat_seq_item chi_cov_write_data_pkt);
      if (chi_cov_write_data_pkt.opcode == 4'h0) begin
            wdata_opcode = chi_cov_write_data_pkt.opcode;
            chi_wdata_port.sample();
      end
endfunction // collect_chi_wdata_datlcrdreturn

function void chi_aiu_coverage::collect_chi_wdata_flit(chi_aiu_scb_txn scb_txn_item);
    if (scb_txn_item.chi_rcvd[`CHI_REQ])
        req_opcode = scb_txn_item.m_chi_req_pkt.opcode;
    if (scb_txn_item.chi_rcvd[`WRITE_DATA_IN]) begin
        foreach(scb_txn_item.m_chi_write_data_pkt[i]) begin
            wdata_opcode = scb_txn_item.m_chi_write_data_pkt[i].opcode;
            chi_wdata_port.sample();
        end
    end else if(scb_txn_item.chi_rcvd[`CHI_SNP_REQ]) begin
        foreach(scb_txn_item.m_chi_snp_data_pkt[i]) begin
            wdata_opcode = scb_txn_item.m_chi_snp_data_pkt[i].opcode;
            chi_wdata_port.sample();
        end
    end
endfunction // collect_chi_wdata_flit

function void chi_aiu_coverage::collect_chi_wr_req_cresp(chi_aiu_scb_txn scb_txn_item, chi_rsp_seq_item crsp_pkt);

   if (crsp_pkt.opcode == DBIDRESP) begin
       crsp_dbid_opcode = crsp_pkt.opcode;
       wr_req_opcode = scb_txn_item.m_chi_req_pkt.opcode;
   end else if (crsp_pkt.opcode == COMP) begin
       crsp_comp_opcode = crsp_pkt.opcode;
       wr_req_opcode = scb_txn_item.m_chi_req_pkt.opcode;
   end

endfunction // collect_chi_wr_req_cresp
function void chi_aiu_coverage::collect_chi_rdata_flit(chi_dat_seq_item txn);
    rdata_opcode = txn.opcode;
    chi_rdata_port.sample();
endfunction // collect_chi_rdata_seq_item

function void chi_aiu_coverage::collect_chi_srsp_flit(chi_rsp_seq_item txn);
    srsp_opcode = txn.opcode;
    chi_srsp_port.sample();
endfunction // collect_chi_srsp_seq_item

function void chi_aiu_coverage::collect_chi_crsp_flit(chi_rsp_seq_item txn);
    crsp_opcode = txn.opcode;
    chi_crsp_port.sample();
endfunction // collect_chi_crsp_seq_item

function void chi_aiu_coverage::collect_chi_snp_flit(chi_snp_seq_item txn);
   // donotgotosd = 'h0;
   // donotdatapull = 'h0;
    int num_addr_match;
    int              cmd_snp_match[$];
    snp_opcode = txn.opcode;
    ns = txn.ns;
    donotgotosd = txn.donotgotosd;
    donotdatapull = txn.donotdatapull;
    snp_addr_match_chi_req = 1'b0;

   if (req_txn_q.size() > 0) begin
      cmd_snp_match = req_txn_q.find_index with(item.addr[WADDR-1 : 3] == txn.addr);
      num_addr_match = cmd_snp_match.size();
   end

   if (num_addr_match > 0) begin
       snp_addr_match_chi_req = 1'b1;
   end

    if (snp_opcode == SNPSTASHUNQ || snp_opcode == SNPSTASHSHRD ||
        snp_opcode == SNPUNQSTASH || snp_opcode == SNPMKINVSTASH) begin
        num_stashing_snps++;
        if (donotdatapull)
            num_donotdatapull_asserted++;
    end
    // delay btw 2 back to back chi snp reqs
    chi_snp_req_dly = ($time - t_chi_snp_rcvd)/10ns;
    t_chi_snp_rcvd = $time;
    chi_snp_port.sample();
endfunction // collect_chi_snp_flit

function void chi_aiu_coverage::collect_stasting_snoops();
    stsh_snoops_with_donotdatapull = (num_donotdatapull_asserted*100)/num_stashing_snps;
    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    stashing_snoops.sample();
    <% } %>
endfunction // collect_stasting_snoops

function void chi_aiu_coverage::collect_ccr_val();

           <%for (var j=0; j< obj.nDCEs; j++){%> 
           uvm_config_db#(int)::get(null,"*","check_dce_credit_limit_<%=j%>",cov_dce_csr_val);
           DCE_CCR<%=j%>_Val = cov_dce_csr_val; 
           <%}%>

           <%for (var j=0; j< obj.nDMIs; j++){%> 
           uvm_config_db#(int)::get(null,"*","check_dmi_credit_limit_<%=j%>",cov_dmi_csr_val);
           DMI_CCR<%=j%>_Val = cov_dmi_csr_val; 
           <%}%>

           <%for (var j=0; j< obj.nDIIs; j++){%> 
           uvm_config_db#(int)::get(null,"*","check_dii_credit_limit_<%=j%>",cov_dii_csr_val);
           DII_CCR<%=j%>_Val = cov_dii_csr_val; 
           <%}%>

           chi_crd_cg.sample();
endfunction // collect_ccr_val

function void chi_aiu_coverage::collect_boundary_addr();
           uvm_config_db#(int)::get(null,"*","boundary_start_addr",boundary_start_addr);
           uvm_config_db#(int)::get(null,"*","boundary_end_addr",boundary_end_addr);
           uvm_config_db#(int)::get(null,"*","boundary_one_byte_before_start_addr",one_byte_before_start_addr);
           uvm_config_db#(int)::get(null,"*","boundary_one_byte_after_end_addr",one_byte_after_end_addr);
           addr_boundary_cg.sample();
endfunction // collect_boundary_addr

function void chi_aiu_coverage::collect_gpra_size();
   <% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
           uvm_config_db#(int)::get(null,"*","gpra_size<%=i%>",gpra_size);
           size_gpra<%=i%> = gpra_size;
   <% } %>
           addr_boundary_cg.sample();
endfunction // collect_gpra_size

task chi_aiu_coverage::collect_size_of_ig();
            while(1)
              begin
                boundary_addr_cov_<%=obj.BlockId%>.wait_trigger();
                <% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
                  uvm_config_db#(int)::get(null,"*","gpra<%=i%>_sizeofig",gpra<%=i%>_sizeofig);
                  if (gpra<%=i%>_sizeofig  == 16) begin
                     gpra_sizeofig_16  = 1;
                  end else if (gpra<%=i%>_sizeofig  == 8) begin
                     gpra_sizeofig_8  = 1;
                  end else if (gpra<%=i%>_sizeofig  == 4) begin
                     gpra_sizeofig_4  = 1;
                  end else if (gpra<%=i%>_sizeofig  == 2) begin
                     gpra_sizeofig_2  = 1;
                  end else if (gpra<%=i%>_sizeofig  == 1) begin
                     gpra_sizeofig_1  = 1;
                  end
                   
                <%}%>
                addr_boundary_cg.sample();
                 #1;
              end
endtask // collect_size_of_ig

<%if(obj.AiuInfo[obj.Id].cmpInfo.nSnpInFlight + obj.AiuInfo[obj.Id].cmpInfo.nDvmSnpInFlight - 1 > 128) {%>
function void chi_aiu_coverage::collect_larger_stt_info(logic [127:0] stt_entry_validvec, logic stt_skid_buffer_full);

	num_snp_req_in_stt = $countones(stt_entry_validvec[127:0]);
	skid_buffer_full = stt_skid_buffer_full;

        larger_stt_cg.sample();

endfunction // collect_larger_stt_info
<%}%>

<% if (obj.useResiliency) { %>
task chi_aiu_coverage::cerr_threshold();
            while(1)
              begin
                ev_cerr_thres_<%=obj.BlockId%>.wait_ptrigger();
           	uvm_config_db#(int)::get(null,"*","<%=obj.BlockId%>_corr_err_threshold",<%=obj.BlockId%>_corr_err_threshold);
           	uvm_config_db#(int)::get(null,"*","<%=obj.BlockId%>_corr_err_over_thres_fault",<%=obj.BlockId%>_corr_err_over_thres_fault);
           	uvm_config_db#(int)::get(null,"*","<%=obj.BlockId%>_corr_err_counter",<%=obj.BlockId%>_corr_err_counter);

           	correctable_error_threshold.sample();
                 #1;
              end
endtask // cerr_threshold
<%}%>

<%if (obj.interfaces.chiInt.params.checkType !== "NONE") {%>
task chi_aiu_coverage::ip_error_cov();
            while(1)
              begin
                ev_ip_err_<%=obj.BlockId%>.wait_ptrigger();
           	uvm_config_db#(bit)::get(null,"*","<%=obj.BlockId%>_ip_err_err_det_en",<%=obj.BlockId%>_ip_err_err_det_en);
           	uvm_config_db#(bit)::get(null,"*","<%=obj.BlockId%>_ip_err_err_int_en",<%=obj.BlockId%>_ip_err_err_int_en);
           	uvm_config_db#(int)::get(null,"*","<%=obj.BlockId%>_ip_err_err_info",<%=obj.BlockId%>_ip_err_err_info);
           	uvm_config_db#(int)::get(null,"*","<%=obj.BlockId%>_ip_err_err_type",<%=obj.BlockId%>_ip_err_err_type);
           	uvm_config_db#(bit)::get(null,"*","<%=obj.BlockId%>_ip_err_err_valid",<%=obj.BlockId%>_ip_err_err_valid);
           	uvm_config_db#(bit)::get(null,"*","<%=obj.BlockId%>_ip_err_mission_fault",<%=obj.BlockId%>_ip_err_mission_fault);
           	uvm_config_db#(bit)::get(null,"*","<%=obj.BlockId%>_ip_err_IRQ_UC",<%=obj.BlockId%>_ip_err_IRQ_UC);

           	interface_parity_error.sample();
                 #1;
              end
endtask // ip_error_cov
<%}%>

function void chi_aiu_coverage::collect_errtype_errcode();

           uvm_config_db#(int)::get(null,"*","chi_errtype_code",errtype_code);
           uvm_config_db#(int)::get(null,"*","chi_dec_err_type",dec_err_type);
           uvm_config_db#(int)::get(null,"*","chi_transport_err_type",transport_err_type);
           uvm_config_db#(int)::get(null,"*","chi_sysevt_err_type",sysevt_err_type);
           uvm_config_db#(int)::get(null,"*","chi_sysco_err_type",sysco_err_type);
           uvm_config_db#(int)::get(null,"*","chi_soft_prog_err_type",soft_prog_err_type);

           uncorr_errtype_errcode.sample();
endfunction // collect_errtype_errcode

task chi_aiu_coverage::collect_irq_uc();
            while(1)
                begin
                     uvm_config_db#(int)::get(null,"*","chi_irq_uc",irq_uc); //for coverage
                     if (irq_uc == 1) begin
                          smi_req_wrong_id.sample();
                     end
                    #5;
                end
endtask // collect_irq_uc

task chi_aiu_coverage::collect_crd_state();
            while(1)
                begin
          	ev_crd_cov_<%=obj.BlockId%>.wait_ptrigger();
                <%for (var j=0; j< obj.nDCEs; j++){%> 
                uvm_config_db#(int)::get(null,"*","check_dce_crd_state_<%=j%>",DCE_CCR<%=j%>_state);
                 <%}%>

                <%for (var j=0; j< obj.nDMIs; j++){%> 
                uvm_config_db#(int)::get(null,"*","check_dmi_crd_state_<%=j%>",DMI_CCR<%=j%>_state);
                <%}%>

                <%for (var j=0; j< obj.nDIIs; j++){%> 
                uvm_config_db#(int)::get(null,"*","check_dii_crd_state_<%=j%>",DII_CCR<%=j%>_state);
                <%}%>
                chi_crd_cg.sample();
                 #1;
                end
endtask // collect_crd_state

function void chi_aiu_coverage::collect_str_req_wtgtid(smi_seq_item m_pkt);

    isstr_wtgtid = 0;
    if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        isstr_wtgtid = 1;
    end
    smi_req_wrong_id.sample();

endfunction // collect_str_req_wtgtid

function void chi_aiu_coverage::collect_dtr_req_wtgtid(smi_seq_item m_pkt);


    isdtr_wtgtid = 0;
    if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        isdtr_wtgtid = 1;
    end
    smi_req_wrong_id.sample();

endfunction // collect_dtr_req_wtgtid

function void chi_aiu_coverage::collect_sys_req_wtgtid(smi_seq_item m_pkt);


    issysreq_wtgtid = 0;
    if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        issysreq_wtgtid = 1;
    end
    smi_req_wrong_id.sample();

endfunction // collect_sys_req_wtgtid

function void chi_aiu_coverage::collect_snp_req_wtgtid(smi_seq_item m_pkt);


    issnpreq_wtgtid = 0;
    if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        issnpreq_wtgtid = 1;
    end
    smi_req_wrong_id.sample();

endfunction // collect_snp_req_wtgtid

function void chi_aiu_coverage::collect_cmd_rsp_wtgtid(smi_seq_item m_pkt);


    iscmdrsp_wtgtid = 0;
    if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        iscmdrsp_wtgtid = 1;
    end
    smi_req_wrong_id.sample();

endfunction // collect_cmd_rsp_wtgtid

function void chi_aiu_coverage::collect_dtr_rsp_wtgtid(smi_seq_item m_pkt);


    isdtrrsp_wtgtid = 0;
    if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        isdtrrsp_wtgtid = 1;
    end
    smi_req_wrong_id.sample();

endfunction // collect_dtr_rsp_wtgtid

function void chi_aiu_coverage::collect_dtw_rsp_wtgtid(smi_seq_item m_pkt);


    isdtwrsp_wtgtid = 0;
    if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
        isdtwrsp_wtgtid = 1;
    end
    smi_req_wrong_id.sample();

endfunction // collect_dtw_rsp_wtgtid

function void chi_aiu_coverage::collect_sys_rsp_wtgtid(smi_seq_item m_pkt);


    issysrsp_wtgtid = 0;
    if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
	issysrsp_wtgtid = 1;
    end
    smi_req_wrong_id.sample();

endfunction // collect_sys_rsp_wtgtid

function void chi_aiu_coverage::collect_dtwdbg_rsp_wtgtid(smi_seq_item m_pkt);


    isdtwdbgrsp_wtgtid = 0;
    if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.AiuInfo[obj.Id].FUnitId%>) begin
	isdtwrsp_wtgtid = 1;
    end
    smi_req_wrong_id.sample();

endfunction // collect_dtwdbg_rsp_wtgtid

function void chi_aiu_coverage::collect_sys_req_events(sysreq_pkt_t txn);
    sysreq_pkt = txn;
    sys_req_events_cg.sample();
endfunction : collect_sys_req_events

function void chi_aiu_coverage::collect_rd_ott_entry(chi_aiu_scb_txn scb_txn_item);
    error_test = 1'b0;
    rd_req_opcode = scb_txn_item.m_chi_req_pkt.opcode;
    rd_opcode = scb_txn_item.m_chi_req_pkt.opcode;
    read_req_opcode = scb_txn_item.m_chi_req_pkt.opcode;
   // atomic_req_opcode = scb_txn_item.m_chi_req_pkt.opcode;
    foreach (scb_txn_item.m_chi_read_data_pkt[i]) begin
       compdata_resp = scb_txn_item.m_chi_read_data_pkt[i].resp;
       rd_data_resperr = scb_txn_item.m_chi_read_data_pkt[i].resperr;
       rdata_opcode = scb_txn_item.m_chi_read_data_pkt[i].opcode;
         //if (($test$plusargs("user_addr_for_csr") || $test$plusargs("unmapped_add_access") || $test$plusargs("strreq_cmstatus_with_error") ) && (rd_req_opcode == READSHARED) ) begin
       <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
         if ((rd_data_resperr > 1) && (compdata_resp == 3'h0) && ((rd_req_opcode == READSHARED) || (rd_req_opcode == READNOTSHAREDDIRTY) || (rd_req_opcode == READUNIQUE) || (rd_req_opcode == READCLEAN))) begin
       <% } else { %>
         if ((rd_data_resperr > 1) && (compdata_resp == 3'h0) && ((rd_req_opcode == READSHARED) || (rd_req_opcode == READUNIQUE) || (rd_req_opcode == READCLEAN))) begin
       <% } %>
              error_test = 1'b1;
         end
          if (error_test == 0) begin
              chi_rd_req_resp.sample();
          end
              chi_rd_req_err_resp_cg.sample();
    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
         if ((scb_txn_item.m_chi_req_pkt.opcode inside {atomic_dtls_ops, atomic_dat_ops})) begin
              //atomic_cresp_resp = scb_txn_item.m_chi_crsp_pkt.resp;
              //atomic_cresp_opcode = scb_txn_item.m_chi_crsp_pkt.opcode;
              //atomic_compdata_resp = scb_txn_item.m_chi_read_data_pkt[i].resp;
              //chi_atomic_req_resp.sample();
         end
    <% } %>
    end
endfunction // collect_rd_ott_entry

function void chi_aiu_coverage::collect_snp_req_snprespdata(chi_aiu_scb_txn scb_txn_item);
    foreach (scb_txn_item.m_chi_snp_data_pkt[i]) begin
       snp_opcode = scb_txn_item.m_chi_snp_addr_pkt.opcode;
       snoop_type_opcode = scb_txn_item.m_chi_snp_addr_pkt.opcode;
       if (scb_txn_item.m_chi_snp_data_pkt[i].opcode == SNPRESPDATA) begin
           chi_snp_data_resp = scb_txn_item.m_chi_snp_data_pkt[i].resp;

           snprespdata_opcode = scb_txn_item.m_chi_snp_data_pkt[i].opcode;
           snprespdata_resperr = scb_txn_item.m_chi_snp_data_pkt[i].resperr;

           chi_snp_req_snprespdata.sample();
           chi_snp_req_err_snprespdata_cg.sample();
       end else if (scb_txn_item.m_chi_snp_data_pkt[i].opcode == SNPRESPDATAPTL) begin
           chi_snp_dataptl_resp = scb_txn_item.m_chi_snp_data_pkt[i].resp; 
           chi_snp_req_snprespdataptl.sample();
       end
    end
endfunction // collect_snp_req_snprespdata


function void chi_aiu_coverage::collect_snp_req_snpresp(chi_aiu_scb_txn scb_txn_item);
    snp_opcode = scb_txn_item.m_chi_snp_addr_pkt.opcode ;
    chi_snp_resp = scb_txn_item.exp_chi_srsp_pkt.resp; 

    snp_type_opcode = scb_txn_item.m_chi_snp_addr_pkt.opcode ;
    snpresp_opcode = scb_txn_item.exp_chi_srsp_pkt.opcode; 
    snpresp_resperr = scb_txn_item.exp_chi_srsp_pkt.resperr; 

    chi_snp_req_resp.sample();
    chi_snp_req_err_snpresp_cg.sample();
endfunction // collect_snp_req_snpresp


function void chi_aiu_coverage::collect_atomic_load_req_resp(chi_aiu_scb_txn scb_txn_item);
     foreach (scb_txn_item.m_chi_write_data_pkt[i]) begin
        // atomic_wdata_opcode = scb_txn_item.m_chi_write_data_pkt[i].opcode; 
         //atomic_req_opcode = scb_txn_item.m_chi_req_pkt.opcode; 
       //  atomic_noncopyback_resp = scb_txn_item.m_chi_write_data_pkt[i].resp; //updated
     end
endfunction // collect_atomic_load_req_resp


function void chi_aiu_coverage::collect_ott_entry(chi_aiu_scb_txn scb_txn_item);
    time t_cmdReq, t_dtrReq, t_strReq, t_dtwReq, t_snpReq;
    time t_cmdRsp, t_dtrRsp, t_strRsp, t_dtwRsp, t_snpRsp;
    time t_SnpdtrReq, t_SnpdtrRsp, t_SnpdtwReq, t_SnpdtwRsp;
    bit chiaiu_txn_rd, chiaiu_txn_wr, chiaiu_txn_snp;
    // Cycles required for CHI request to compelete
    chi_cmd_req_latency = ($time - scb_txn_item.t_chi_req_rcvd)/10ns;
    chi_snp_req_latency = ($time - scb_txn_item.t_chi_snp_req)/10ns;


    collect_ccr_val();
    collect_errtype_errcode();
    collect_gpra_size();

    // CHI snp req to rsp delay
    if (scb_txn_item.m_chi_read_data_pkt.size() > 0)
        snp_req_rsp_dly = (scb_txn_item.t_chi_snp_rsp - scb_txn_item.t_chi_snp_req)/10ns;
    // SMI snp_rsp for reqs
    if (scb_txn_item.smi_rcvd[`SNP_REQ_IN]) begin
        snp_req_type = scb_txn_item.m_snp_req_pkt.smi_msg_type;
        snp_type     = scb_txn_item.m_snp_req_pkt.smi_msg_type;
        smi_up       = scb_txn_item.m_snp_req_pkt.smi_up;
        mpf3_match   = scb_txn_item.is_mpf3_match; 

    end
  <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    if (scb_txn_item.chi_rcvd[`CHI_SNP_REQ]) begin
        rettosrc     = scb_txn_item.m_chi_snp_addr_pkt.rettosrc; 
    end
  <% } %>

    if (scb_txn_item.m_chi_snp_addr_pkt != null) begin
          if ((scb_txn_item.m_snp_req_pkt.smi_addr >> 3) == (scb_txn_item.m_chi_snp_addr_pkt.addr)) begin
               snp_up_mpf3_rettosrc_cg.sample();
          end
    end

    if (scb_txn_item.smi_rcvd[`SNP_RSP_OUT] && scb_txn_item.m_snp_rsp_pkt !== null) begin
        snp_rsp_rv     = scb_txn_item.m_snp_rsp_pkt.smi_cmstatus_rv;
        snp_rsp_rs     = scb_txn_item.m_snp_rsp_pkt.smi_cmstatus_rs;
        snp_rsp_dc     = scb_txn_item.m_snp_rsp_pkt.smi_cmstatus_dc;
        snp_rsp_dt_aiu = scb_txn_item.m_snp_rsp_pkt.smi_cmstatus_dt_aiu;
        snp_rsp_dt_dmi = scb_txn_item.m_snp_rsp_pkt.smi_cmstatus_dt_dmi;
        snp_rsp_snarf = scb_txn_item.m_snp_rsp_pkt.smi_cmstatus_snarf;
        rv_rs_dc_dt_snf = {snp_rsp_rv,snp_rsp_rs,snp_rsp_dc,snp_rsp_dt_aiu,snp_rsp_dt_dmi,snp_rsp_snarf};
    end
    smi_snp_resp.sample();
    // collect timing of smi req and rsp
    if (scb_txn_item.smi_rcvd[`CMD_REQ_OUT]) begin
        t_cmdReq = scb_txn_item.t_smi_cmd_req;
    end
    if (scb_txn_item.smi_rcvd[`CMD_RSP_IN]) begin
        t_cmdRsp = scb_txn_item.t_smi_cmd_rsp;
    end
    if (scb_txn_item.smi_rcvd[`STR_REQ_IN]) begin
        t_strReq = scb_txn_item.t_smi_str_req;
        isstr_req = 1;
        str_cmst = scb_txn_item.m_str_req_pkt.smi_cmstatus_err_payload; 

    end

    if (scb_txn_item.smi_rcvd[`STR_RSP_OUT]) begin
        t_strRsp = scb_txn_item.t_smi_str_rsp;
    end
    if (scb_txn_item.smi_rcvd[`DTR_REQ_IN]) begin
        t_dtrReq = scb_txn_item.t_smi_dtr_req;
        isdtr_req = 1;
        dtr_cmst = scb_txn_item.m_dtr_req_pkt.smi_cmstatus_err_payload; 
     
         
    end
    if (scb_txn_item.smi_rcvd[`DTR_RSP_OUT]) begin
        t_dtrRsp = scb_txn_item.t_smi_dtr_rsp;
        chiaiu_txn_rd = 1;
    end
    if (scb_txn_item.smi_rcvd[`DTW_REQ_OUT]) begin
        t_dtwReq = scb_txn_item.t_smi_dtw_req;
    end
    if (scb_txn_item.smi_rcvd[`DTW_RSP_IN]) begin
        t_dtwRsp = scb_txn_item.t_smi_dtw_rsp;
        chiaiu_txn_wr = 1;
        isdtw_rsp = 1;
        dtw_rsp_cmst = scb_txn_item.m_dtw_rsp_pkt.smi_cmstatus_err_payload; 
    end
    if (scb_txn_item.smi_rcvd[`SNP_REQ_IN]) begin
        t_snpReq = scb_txn_item.t_smi_snp_req;
        chiaiu_txn_snp = 1;
    end
    if (scb_txn_item.smi_rcvd[`SNP_RSP_OUT]) begin
        t_snpRsp = scb_txn_item.t_smi_snp_rsp;
    end
    if (scb_txn_item.smi_rcvd[`SNP_DTR_REQ]) begin
        t_SnpdtrReq = scb_txn_item.t_smi_snp_dtr_req;
    end
    if (scb_txn_item.smi_rcvd[`SNP_DTR_RSP]) begin
        t_SnpdtrRsp = scb_txn_item.t_smi_snp_dtr_rsp;
    end
    if (scb_txn_item.smi_rcvd[`SNP_DTW_REQ_OUT]) begin
        t_SnpdtwReq = scb_txn_item.t_smi_snp_dtw_req;
    end
    if (scb_txn_item.smi_rcvd[`SNP_DTW_RSP_IN]) begin
        t_SnpdtwRsp = scb_txn_item.t_smi_snp_dtw_rsp;
    end
    // valid seq in txn state machine
    // read txns
    if (chiaiu_txn_rd) begin
        if (t_cmdRsp < t_strReq && t_strRsp < t_dtrReq)                                                  $cast(smi_msg_seq , {cmdReq_cmdRsp_strReq_strRsp_dtrReq_dtrRsp});
        if (t_cmdRsp < t_strReq && t_strReq < t_dtrReq && t_dtrReq < t_dtrRsp && t_dtrRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_cmdRsp_strReq_dtrReq_dtrRsp_strRsp});
        if (t_cmdRsp < t_strReq && t_strReq < t_dtrReq && t_dtrReq < t_strRsp && t_strRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_cmdRsp_strReq_dtrReq_strRsp_dtrRsp});
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtrReq)                           $cast(smi_msg_seq , {cmdReq_strReq_cmdRsp_strRsp_dtrReq_dtrRsp});
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_dtrReq && t_dtrReq < t_strRsp && t_strRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_strReq_cmdRsp_dtrReq_strRsp_dtrRsp});
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_dtrReq && t_dtrReq < t_dtrRsp && t_dtrRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_strReq_cmdRsp_dtrReq_dtrRsp_strRsp});
        if (t_strReq < t_dtrReq && t_dtrReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtrReq_cmdRsp_strRsp_dtrRsp});
        if (t_strReq < t_dtrReq && t_dtrReq < t_cmdRsp && t_cmdRsp < t_dtrRsp && t_dtrRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtrReq_cmdRsp_dtrRsp_strRsp});
        if (t_strReq < t_dtrReq && t_dtrReq < t_strRsp && t_strRsp < t_cmdRsp && t_cmdRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtrReq_strRsp_cmdRsp_dtrRsp});
        if (t_strReq < t_dtrReq && t_dtrReq < t_strRsp && t_strRsp < t_dtrRsp && t_dtrRsp < t_cmdRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtrReq_strRsp_dtrRsp_cmdRsp});
        if (t_strReq < t_dtrReq && t_dtrReq < t_dtrRsp && t_dtrRsp < t_cmdRsp && t_cmdRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtrReq_dtrRsp_cmdRsp_strRsp});
        if (t_strReq < t_dtrReq && t_dtrReq < t_dtrRsp && t_dtrRsp < t_strRsp && t_strRsp < t_cmdRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtrReq_dtrRsp_strRsp_cmdRsp});
        if (t_cmdRsp < t_dtrReq && t_dtrRsp < t_strReq)                                                  $cast(smi_msg_seq , {cmdReq_cmdRsp_dtrReq_dtrRsp_strReq_strRsp});
        if (t_cmdRsp < t_dtrReq && t_dtrReq < t_strReq && t_strReq < t_strRsp && t_strRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_cmdRsp_dtrReq_strReq_strRsp_dtrRsp});
        if (t_cmdRsp < t_dtrReq && t_dtrReq < t_strReq && t_strReq < t_dtrRsp && t_dtrRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_cmdRsp_dtrReq_strReq_dtrRsp_strRsp});
        if (t_dtrReq < t_cmdRsp && t_cmdRsp < t_dtrRsp && t_dtrRsp < t_strReq)                           $cast(smi_msg_seq , {cmdReq_dtrReq_cmdRsp_dtrRsp_strReq_strRsp});
        if (t_dtrReq < t_cmdRsp && t_cmdRsp < t_strReq && t_strReq < t_dtrRsp && t_dtrRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_cmdRsp_strReq_dtrRsp_strRsp});
        if (t_dtrReq < t_cmdRsp && t_cmdRsp < t_strReq && t_strReq < t_strRsp && t_strRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_cmdRsp_strReq_strRsp_dtrRsp});
        if (t_dtrReq < t_strReq && t_strReq < t_cmdRsp && t_cmdRsp < t_dtrRsp && t_dtrRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_strReq_cmdRsp_dtrRsp_strRsp});
        if (t_dtrReq < t_strReq && t_strReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_strReq_cmdRsp_strRsp_dtrRsp});
        if (t_dtrReq < t_strReq && t_strReq < t_dtrRsp && t_dtrRsp < t_cmdRsp && t_cmdRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_strReq_dtrRsp_cmdRsp_strRsp});
        if (t_dtrReq < t_strReq && t_strReq < t_dtrRsp && t_dtrRsp < t_strRsp && t_strRsp < t_cmdRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_strReq_dtrRsp_strRsp_cmdRsp});
        if (t_dtrReq < t_strReq && t_strReq < t_strRsp && t_strRsp < t_cmdRsp && t_cmdRsp < t_dtrRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_strReq_strRsp_cmdRsp_dtrRsp});
        if (t_dtrReq < t_strReq && t_strReq < t_strRsp && t_strRsp < t_dtrRsp && t_dtrRsp < t_cmdRsp)    $cast(smi_msg_seq , {cmdReq_dtrReq_strReq_strRsp_dtrRsp_cmdRsp});
    end
    // write txns
    if (chiaiu_txn_wr) begin
        if (t_cmdRsp < t_strReq && t_strRsp < t_dtwReq)                                                  $cast(smi_msg_seq , {cmdReq_cmdRsp_strReq_strRsp_dtwReq_dtwRsp});
        if (t_cmdRsp < t_strReq && t_strReq < t_dtwReq && t_dtwReq < t_dtwRsp && t_dtwRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_cmdRsp_strReq_dtwReq_dtwRsp_strRsp});
        if (t_cmdRsp < t_strReq && t_strReq < t_dtwReq && t_dtwReq < t_strRsp && t_strRsp < t_dtwRsp)    $cast(smi_msg_seq , {cmdReq_cmdRsp_strReq_dtwReq_strRsp_dtwRsp});
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtwReq)                           $cast(smi_msg_seq , {cmdReq_strReq_cmdRsp_strRsp_dtwReq_dtwRsp});
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_dtwReq && t_dtwReq < t_strRsp && t_strRsp < t_dtwRsp)    $cast(smi_msg_seq , {cmdReq_strReq_cmdRsp_dtwReq_strRsp_dtwRsp});
        if (t_strReq < t_cmdRsp && t_cmdRsp < t_dtwReq && t_dtwReq < t_dtwRsp && t_dtwRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_strReq_cmdRsp_dtwReq_dtwRsp_strRsp});
        if (t_strReq < t_dtwReq && t_dtwReq < t_cmdRsp && t_cmdRsp < t_strRsp && t_strRsp < t_dtwRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtwReq_cmdRsp_strRsp_dtwRsp});
        if (t_strReq < t_dtwReq && t_dtwReq < t_cmdRsp && t_cmdRsp < t_dtwRsp && t_dtwRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtwReq_cmdRsp_dtwRsp_strRsp});
        if (t_strReq < t_dtwReq && t_dtwReq < t_strRsp && t_strRsp < t_cmdRsp && t_cmdRsp < t_dtwRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtwReq_strRsp_cmdRsp_dtwRsp});
        if (t_strReq < t_dtwReq && t_dtwReq < t_strRsp && t_strRsp < t_dtwRsp && t_dtwRsp < t_cmdRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtwReq_strRsp_dtwRsp_cmdRsp});
        if (t_strReq < t_dtwReq && t_dtwReq < t_dtwRsp && t_dtwRsp < t_cmdRsp && t_cmdRsp < t_strRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtwReq_dtwRsp_cmdRsp_strRsp});
        if (t_strReq < t_dtwReq && t_dtwReq < t_dtwRsp && t_dtwRsp < t_strRsp && t_strRsp < t_cmdRsp)    $cast(smi_msg_seq , {cmdReq_strReq_dtwReq_dtwRsp_strRsp_cmdRsp});
    end
    // Snoop txns
    if (chiaiu_txn_snp) begin
       if (t_SnpdtwReq < t_SnpdtrReq && t_SnpdtwRsp < t_SnpdtrRsp && t_SnpdtrRsp < t_snpRsp   ) $cast(smi_msg_seq , {snpReq_dtwReq_dtrReq_dtwrsp_dtrrsp_snprsp}); 
       if (t_SnpdtwReq < t_SnpdtrReq && t_SnpdtwRsp < t_snpRsp    && t_snpRsp    < t_SnpdtrRsp) $cast(smi_msg_seq , {snpReq_dtwReq_dtrReq_dtwrsp_snprsp_dtrrsp});
       if (t_SnpdtwReq < t_SnpdtrReq && t_SnpdtrRsp < t_SnpdtwRsp && t_SnpdtwRsp < t_snpRsp   ) $cast(smi_msg_seq , {snpReq_dtwReq_dtrReq_dtrrsp_dtwrsp_snprsp});
       if (t_SnpdtwReq < t_SnpdtrReq && t_SnpdtrRsp < t_snpRsp    && t_snpRsp    < t_SnpdtwRsp) $cast(smi_msg_seq , {snpReq_dtwReq_dtrReq_dtrrsp_snprsp_dtwrsp});
       if (t_SnpdtwReq < t_SnpdtrReq && t_snpRsp    < t_SnpdtrRsp && t_SnpdtrRsp < t_SnpdtwRsp) $cast(smi_msg_seq , {snpReq_dtwReq_dtrReq_snprsp_dtrrsp_dtwrsp});
       if (t_SnpdtwReq < t_SnpdtrReq && t_snpRsp    < t_SnpdtwRsp && t_SnpdtwRsp < t_SnpdtrRsp) $cast(smi_msg_seq , {snpReq_dtwReq_dtrReq_snprsp_dtwrsp_dtrrsp});
       if (t_SnpdtrReq < t_SnpdtwReq && t_SnpdtwRsp < t_SnpdtrRsp && t_SnpdtrRsp < t_snpRsp   ) $cast(smi_msg_seq , {snpReq_dtrReq_dtwReq_dtwrsp_dtrrsp_snprsp});
       if (t_SnpdtrReq < t_SnpdtwReq && t_SnpdtwRsp < t_snpRsp    && t_snpRsp    < t_SnpdtrRsp) $cast(smi_msg_seq , {snpReq_dtrReq_dtwReq_dtwrsp_snprsp_dtrrsp});
       if (t_SnpdtrReq < t_SnpdtwReq && t_SnpdtrRsp < t_SnpdtwRsp && t_SnpdtwRsp < t_snpRsp   ) $cast(smi_msg_seq , {snpReq_dtrReq_dtwReq_dtrrsp_dtwrsp_snprsp});
       if (t_SnpdtrReq < t_SnpdtwReq && t_SnpdtrRsp < t_snpRsp    && t_snpRsp    < t_SnpdtwRsp) $cast(smi_msg_seq , {snpReq_dtrReq_dtwReq_dtrrsp_snprsp_dtwrsp});
       if (t_SnpdtrReq < t_SnpdtwReq && t_snpRsp    < t_SnpdtrRsp && t_SnpdtrRsp < t_SnpdtwRsp) $cast(smi_msg_seq , {snpReq_dtrReq_dtwReq_snprsp_dtrrsp_dtwrsp});
       if (t_SnpdtrReq < t_SnpdtwReq && t_snpRsp    < t_SnpdtwRsp && t_SnpdtwRsp < t_SnpdtrRsp) $cast(smi_msg_seq , {snpReq_dtrReq_dtwReq_snprsp_dtwrsp_dtrrsp});
       if (t_SnpdtwReq < t_SnpdtwRsp && t_SnpdtwRsp < t_snpRsp   )    $cast(smi_msg_seq , {snpReq_dtwReq_dtwrsp_snprsp});
       if (t_SnpdtwReq < t_snpRsp    && t_snpRsp    < t_SnpdtwRsp)    $cast(smi_msg_seq , {snpReq_dtwReq_snprsp_dtwrsp});
       if (t_SnpdtrReq < t_SnpdtrRsp && t_SnpdtrRsp < t_snpRsp   )    $cast(smi_msg_seq , {snpReq_dtrReq_dtrrsp_snprsp});
       if (t_SnpdtrReq < t_snpRsp    && t_snpRsp    < t_SnpdtrRsp)    $cast(smi_msg_seq , {snpReq_dtrReq_snprsp_dtrrsp});
    end
    concerto_messages.sample();
    smi_req_cmstatus.sample();

    // Cross between Req type and COMPDATA resp
    if (scb_txn_item.chi_rcvd[`CHI_REQ]) begin

          if ((scb_txn_item.m_chi_req_pkt.addr inside {[ncoreConfigInfo::NRS_REGION_BASE : (ncoreConfigInfo::NRS_REGION_BASE + ncoreConfigInfo::NRS_REGION_SIZE)]}) || (scb_txn_item.m_chi_req_pkt.addr inside {[ncoreConfigInfo::BOOT_REGION_BASE : (ncoreConfigInfo::BOOT_REGION_BASE + ncoreConfigInfo::BOOT_REGION_SIZE)]})) begin
               is_addr_boot_csr = 1;
          end else begin
               is_addr_boot_csr = 0;
          end

        req_opcode = scb_txn_item.m_chi_req_pkt.opcode;
        atomic_req_opcode = scb_txn_item.m_chi_req_pkt.opcode;
        dataless_req_opcode = scb_txn_item.m_chi_req_pkt.opcode;
        write_req_opcode = scb_txn_item.m_chi_req_pkt.opcode;
        atomic_type_opcode = scb_txn_item.m_chi_req_pkt.opcode;
        atomic_load_type_opcode = scb_txn_item.m_chi_req_pkt.opcode;
        dvmop_opcode = scb_txn_item.m_chi_req_pkt.opcode;

       // rd_req_opcode = scb_txn_item.m_chi_req_pkt.opcode;

        rd_req_ns_opcode = scb_txn_item.m_chi_req_pkt.opcode;
        rd_req_ns        = scb_txn_item.m_chi_req_pkt.ns;
        rd_nsx           = scb_txn_item.NS_NSX;

        dataless_req_ns_opcode = scb_txn_item.m_chi_req_pkt.opcode;
        dataless_req_ns        = scb_txn_item.m_chi_req_pkt.ns;
        dataless_nsx           = scb_txn_item.NS_NSX;

        wr_req_ns_opcode       = scb_txn_item.m_chi_req_pkt.opcode;
        wr_req_ns              = scb_txn_item.m_chi_req_pkt.ns;
        wr_nsx                 = scb_txn_item.NS_NSX;

        atomic_ld_req_ns_opcode   = scb_txn_item.m_chi_req_pkt.opcode;
        atomic_ld_req_ns          = scb_txn_item.m_chi_req_pkt.ns;
        atomic_ld_nsx             = scb_txn_item.NS_NSX;

        atomic_st_ns_opcode       = scb_txn_item.m_chi_req_pkt.opcode;
        atomic_st_ns              = scb_txn_item.m_chi_req_pkt.ns;
        atomic_st_nsx             = scb_txn_item.NS_NSX;
    end
    if (scb_txn_item.chi_rcvd[`WRITE_DATA_IN]) begin
        // if (scb_txn_item.chi_rcvd[`CHI_REQ]) req_opcode = scb_txn_item.m_chi_req_pkt.opcode; // updated
        //compdata_resp = scb_txn_item.m_chi_write_data_pkt[$].resp;
       // wrcopyback_resp = scb_txn_item.m_chi_write_data_pkt[$].resp; //updated
       // noncopyback_resp = scb_txn_item.m_chi_write_data_pkt[$].resp; //updated
        foreach(scb_txn_item.m_chi_write_data_pkt[i]) begin
           //if (scb_txn_item.m_chi_write_data_pkt[i].opcode == COMPDATA) begin
           //if (scb_txn_item.m_chi_write_data_pkt[i].opcode == (COPYBACKWRDATA || NONCOPYBACKWRDATA || WRDATACANCEL)) begin
                wrcopyback_resp = scb_txn_item.m_chi_write_data_pkt[i].resp; //updated
                noncopyback_resp = scb_txn_item.m_chi_write_data_pkt[i].resp; //updated
                wdata_opcode = scb_txn_item.m_chi_write_data_pkt[i].opcode; 


                //write_data_resperr      = scb_txn_item.m_chi_write_data_pkt[i].resperr; //updated

                //chi_write_req_err_resp_cg.sample();

              if ((atomic_req_opcode inside {atomic_dtls_ops, atomic_dat_ops})) begin
                atomic_wdata_opcode = scb_txn_item.m_chi_write_data_pkt[i].opcode; 
                atomic_noncopyback_resp = scb_txn_item.m_chi_write_data_pkt[i].resp; //updated
              end
                req_cross_resp.sample();
          // end
        end
    end


    if (scb_txn_item.chi_rcvd[`READ_DATA_IN]) begin
       // compdata_resp = scb_txn_item.m_chi_read_data_pkt[$].resp;
        foreach(scb_txn_item.m_chi_read_data_pkt[i]) begin
            if (scb_txn_item.m_chi_read_data_pkt[i].opcode == COMPDATA) begin
               // compdata_resp = scb_txn_item.m_chi_read_data_pkt[i].resp;
              if ((atomic_req_opcode inside {atomic_dtls_ops, atomic_dat_ops})) begin
                  atomic_compdata_resp    = scb_txn_item.m_chi_read_data_pkt[i].resp;
                  atomic_compdata_opcode         = scb_txn_item.m_chi_read_data_pkt[i].opcode;
                  atomic_compdata_resperr = scb_txn_item.m_chi_read_data_pkt[i].resperr;
              end
                req_cross_resp.sample();
            <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
                chi_atomic_req_compdata_err_resp_cg.sample();
            <% } %>

           if (scb_txn_item.chi_rcvd[`CHI_REQ]) begin
               if (scb_txn_item.m_chi_req_pkt.opcode inside {read_ops}) begin
                   if (scb_txn_item.m_chi_read_data_pkt[i].resperr == 2'h3 && (rd_nsx == 0) && (rd_req_ns ==  1))  begin
                        rd_err = 1;
                   end else begin
                        rd_err = 0;
                   end
                   security_rd_cg.sample();
               end

          <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
               if (scb_txn_item.m_chi_req_pkt.opcode inside {atomic_dat_ops}) begin
                   if (scb_txn_item.m_chi_read_data_pkt[i].resperr == 2'h3 && (atomic_ld_nsx == 0) && (atomic_ld_req_ns == 1) ) begin
                        atomic_ld_err = 1;
                   end else begin
                        atomic_ld_err = 0;
                   end
                   security_atomic_ld_cg.sample();
               end
          <% } %>
            end
        end
       end
    end
    // Cross between Req type and COMP resp
    if (scb_txn_item.m_chi_crsp_pkt !== null) begin
              rd_cresp_resperr = scb_txn_item.m_chi_crsp_pkt.resperr;
              rd_crsp_opcode   = scb_txn_item.m_chi_crsp_pkt.opcode;
              rd_opcode        = scb_txn_item.m_chi_req_pkt.opcode;
              chi_rd_req_cresp_err_resp_cg.sample();

        if (scb_txn_item.m_chi_crsp_pkt.opcode == COMPDBIDRESP || scb_txn_item.m_chi_crsp_pkt.opcode ==DBIDRESP || scb_txn_item.m_chi_crsp_pkt.opcode == COMP) begin
              cresp_opcode      = scb_txn_item.m_chi_crsp_pkt.opcode;
              prev_cresp_opcode = scb_txn_item.prev_chi_crsp_pkt.opcode;

              dataless_cresp_resp        = scb_txn_item.m_chi_crsp_pkt.resp;
              dataless_crsp_opcode       = scb_txn_item.m_chi_crsp_pkt.opcode;
              dataless_cresp_resperr     = scb_txn_item.m_chi_crsp_pkt.resperr;

              write_crsp_opcode           = scb_txn_item.m_chi_crsp_pkt.opcode;
              write_prev_crsp_opcode      = scb_txn_item.prev_chi_crsp_pkt.opcode;
              write_cresp_resperr         = scb_txn_item.m_chi_crsp_pkt.resperr;
              write_prev_cresp_resperr    = scb_txn_item.prev_chi_crsp_pkt.resperr;

              atomic_crsp_opcode     = scb_txn_item.m_chi_crsp_pkt.opcode;
              atomic_cresp_resperr   = scb_txn_item.m_chi_crsp_pkt.resperr;


              dvmop_crsp_opcode          = scb_txn_item.curr_dvmop_chi_crsp_pkt.opcode;
              dvmop_comp_resperr         = scb_txn_item.curr_dvmop_chi_crsp_pkt.resperr;

              dvmop_prev_crsp_opcode     = scb_txn_item.prev_dvmop_chi_crsp_pkt.opcode;
              dvmop_dbid_resperr         = scb_txn_item.prev_dvmop_chi_crsp_pkt.resperr;


              if(scb_txn_item.m_chi_crsp_pkt.opcode == COMP && (scb_txn_item.chi_rcvd[`CHI_REQ])) begin
              <% if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
                  if (scb_txn_item.m_chi_req_pkt.opcode inside {dataless_ops}) begin
              <% } else { %>
                  if (scb_txn_item.m_chi_req_pkt.opcode inside {dataless_ops, STASHONCEUNIQUE, STASHONCESHARED}) begin
              <% } %>
                     if (scb_txn_item.m_chi_crsp_pkt.resperr == 2'h3 && (dataless_nsx == 0) && (dataless_req_ns == 1)) begin
                          dataless_err = 1;
                     end else begin
                          dataless_err = 0;
                     end
                    security_dataless_cg.sample();
                  end

                  if (scb_txn_item.m_chi_req_pkt.opcode inside {write_ops}) begin
                     if (scb_txn_item.m_chi_crsp_pkt.resperr == 2'h3 && (wr_nsx== 0) && (wr_req_ns == 1)) begin
                          wr_err = 1;
                     end else begin
                          wr_err = 0;
                     end
                    security_wr_cg.sample();
                  end
              end

              if(scb_txn_item.m_chi_crsp_pkt.opcode == COMPDBIDRESP && (scb_txn_item.chi_rcvd[`CHI_REQ])) begin
                  if (scb_txn_item.m_chi_req_pkt.opcode inside {write_ops}) begin
                     if (scb_txn_item.m_chi_crsp_pkt.resperr == 2'h3 && (wr_nsx== 0) && (wr_req_ns == 1)) begin
                          wr_err = 1;
                     end else begin
                          wr_err = 0;
                     end
                    security_wr_cg.sample();
                  end

                <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
                     if (scb_txn_item.m_chi_req_pkt.opcode inside {atomic_dtls_ops}) begin
                         if (scb_txn_item.m_chi_crsp_pkt.resperr == 2'h3 && (atomic_st_nsx == 0) && (atomic_st_ns == 1)) begin
                              atomic_st_err = 1;
                         end else begin
                              atomic_st_err = 0;
                         end
                         security_atomic_st_cg.sample();
                     end
                <% } %>

              end



        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
        if (dataless_req_opcode inside {dataless_ops}) begin
        <% } else { %>
        if (dataless_req_opcode inside {dataless_ops, STASHONCEUNIQUE, STASHONCESHARED}) begin
	<% } %>
              chi_dataless_req_err_resp_cg.sample();
              chi_dataless_req_resp.sample();
        end

              req_cross_resp.sample();


              if (write_req_opcode inside {write_ops}) begin
                  chi_write_req_err_resp_cg.sample();
              end

              chi_wr_req_resp.sample();

              if (dvmop_opcode inside {DVMOP}) begin
                 chi_dvmop_req_err_resp_cg.sample();
              end


    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
              if ((atomic_req_opcode inside {atomic_dtls_ops, atomic_dat_ops})) begin
                chi_atomic_req_err_resp_cg.sample();
                if (scb_txn_item.m_chi_crsp_pkt.opcode == COMP) begin
                 atomic_cresp_resp = scb_txn_item.m_chi_crsp_pkt.resp;
                end
                 atomic_cresp_opcode      = scb_txn_item.m_chi_crsp_pkt.opcode;
                 prev_atomic_cresp_opcode = scb_txn_item.prev_chi_crsp_pkt.opcode;
                 chi_atomic_req_resp.sample();
              end
    <% } %>
        end
    end

    if (scb_txn_item.chi_rcvd[`WRITE_DATA_IN]) begin
        foreach(scb_txn_item.m_chi_write_data_pkt[i]) begin
                write_data_resperr      = scb_txn_item.m_chi_write_data_pkt[i].resperr; //updated
                atomic_data_resperr     = scb_txn_item.m_chi_write_data_pkt[i].resperr; //updated
                dvm_wdata_opcode        = scb_txn_item.m_chi_write_data_pkt[i].opcode; 
                dvmop_ncbwrdata_resperr = scb_txn_item.m_chi_write_data_pkt[i].resperr; //updated
                if (write_req_opcode inside {write_ops}) begin
                   chi_write_req_err_resp_cg.sample();
                end
                if (dvmop_opcode inside {DVMOP}) begin
                 chi_dvmop_req_err_resp_cg.sample();
                end
              <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
                if ((atomic_req_opcode inside {atomic_dtls_ops, atomic_dat_ops})) begin
                   chi_atomic_req_err_resp_cg.sample();
                end
              <% } %>

        end
    end

    if (scb_txn_item.m_chi_srsp_pkt !== null) begin
        if (scb_txn_item.m_chi_srsp_pkt.opcode == COMPACK) begin
              //rd_opcode        = scb_txn_item.m_chi_req_pkt.opcode;
              rd_srsp_opcode   = scb_txn_item.m_chi_srsp_pkt.opcode;
              rd_sresp_resperr = scb_txn_item.m_chi_srsp_pkt.resperr;

              dataless_srsp_opcode   = scb_txn_item.m_chi_srsp_pkt.opcode;
              dataless_sresp_resperr = scb_txn_item.m_chi_srsp_pkt.resperr;


              write_srsp_opcode   = scb_txn_item.m_chi_srsp_pkt.opcode;
              write_sresp_resperr = scb_txn_item.m_chi_srsp_pkt.resperr;


              chi_rd_req_sresp_err_resp_cg.sample();
              <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
              if (dataless_req_opcode inside {dataless_ops}) begin
              <% } else { %>
              if (dataless_req_opcode inside {dataless_ops, STASHONCEUNIQUE, STASHONCESHARED}) begin
	      <% } %>
                  chi_dataless_req_err_resp_cg.sample();
              end
              if (write_req_opcode inside {write_ops}) begin
                  chi_write_req_err_resp_cg.sample();
              end
        end
    end


    // Cross between SNPRESP/SNPRESPDATA resp (srsp & rdata) and snp req and snp resp opcode
    if (scb_txn_item.chi_rcvd[`CHI_SNP_REQ])
        snp_opcode = scb_txn_item.m_chi_snp_addr_pkt.opcode;
    if (scb_txn_item.m_chi_srsp_pkt !== null) begin
        srsp_opcode = scb_txn_item.m_chi_srsp_pkt.opcode;
        if (scb_txn_item.m_chi_srsp_pkt.opcode == SNPRESP) begin
           // snp_resp = scb_txn_item.m_chi_srsp_pkt.resp;
           // chi_snp_req_resp.sample();
        end
    end
    else if (scb_txn_item.m_chi_read_data_pkt.size() !== 0) begin
        foreach(scb_txn_item.m_chi_read_data_pkt[i]) begin
            rdata_opcode = scb_txn_item.m_chi_read_data_pkt[i].opcode;
            if (scb_txn_item.m_chi_read_data_pkt[i].opcode == SNPRESPDATA) begin
              //  snp_resp = scb_txn_item.m_chi_read_data_pkt[i].resp;
              //  chi_snp_data_resp = scb_txn_item.m_chi_read_data_pkt[i].resp;
            end else if (scb_txn_item.m_chi_read_data_pkt[i].opcode == SNPRESPDATAPTL) begin
               // snp_resp = scb_txn_item.m_chi_read_data_pkt[i].resp;
              //  chi_snp_dataptl_resp = scb_txn_item.m_chi_read_data_pkt[i].resp; 
            end 
                req_cross_resp.sample();
               // chi_snp_req_snprespdata.sample();
        end
    end
 //   req_cross_resp.sample();

    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    // sysco coverage variables
    smi_sysco_state = scb_txn_item.smi_sysco_state;
    chi_sysco_state = scb_txn_item.chi_sysco_state;
    smi_dvm_part2_sysco_state = scb_txn_item.smi_dvm_part2_sysco_state;
    chi_dvm_part2_sysco_state = scb_txn_item.chi_dvm_part2_sysco_state;
    isSnoop = scb_txn_item.isSnoop;
    isDVMSnoop = scb_txn_item.isDVMSnoop;
    is_sysco_snp_returned = scb_txn_item.is_sysco_snp_returned;
    normal_stsh_snoop = scb_txn_item.normal_stsh_snoop;

    if(isSnoop)
      chi_smi_sysco_states.sample();
    <% } %>
endfunction // collect_ott_entry

function chi_aiu_coverage::new();
    chi_wdata_port = new();
    chi_rdata_port = new();
	Connectivity_cov = new();
	sysco_req_commands = new();
	sysco_rsp_commands = new();
    chi_req_port = new();
    chi_crsp_port = new();
    chi_srsp_port = new();
    chi_crd_cg = new();
    uncorr_errtype_errcode = new();
    <% if (obj.useResiliency) { %>
    correctable_error_threshold = new();
    <% } %>
    <%if (obj.interfaces.chiInt.params.checkType !== "NONE") {%>
    interface_parity_error = new();
    <% } %>
    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    atomic_addr_size_alignment = new();
    <% } %>
    chi_snp_port = new();
    req_cross_resp = new();
    chi_snp_req_resp = new();
    chi_snp_req_snprespdata = new();
    chi_snp_req_snprespdataptl = new();
    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    chi_atomic_req_resp = new();
    <% } %>
    chi_dataless_req_resp = new();
    chi_wr_req_resp = new();
    chi_rd_req_resp = new();
    concerto_messages = new();
    smi_req_cmstatus = new();
    smi_req_wrong_id = new();
    smi_snp_resp = new();
    sys_req_events_cg = new();


    chi_rd_req_err_resp_cg = new();
    chi_rd_req_cresp_err_resp_cg = new();
    chi_rd_req_sresp_err_resp_cg = new();
    chi_dataless_req_err_resp_cg = new();
    chi_write_req_err_resp_cg = new();
  <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    chi_atomic_req_compdata_err_resp_cg = new();
    chi_atomic_req_err_resp_cg = new();
  <% } %>
    chi_dvmop_req_err_resp_cg = new();
    chi_snp_req_err_snpresp_cg = new();
    chi_snp_req_err_snprespdata_cg = new();
    snp_up_mpf3_rettosrc_cg = new();
    security_rd_cg = new();
    security_dataless_cg = new();
    security_wr_cg = new();
    addr_boundary_cg = new();
<%if(obj.AiuInfo[obj.Id].cmpInfo.nSnpInFlight + obj.AiuInfo[obj.Id].cmpInfo.nDvmSnpInFlight - 1 > 128) {%>
    larger_stt_cg = new();
<%}%>


    <% if(obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
    stashing_snoops = new();
    chi_smi_sysco_states = new();
    security_atomic_st_cg = new();
    security_atomic_ld_cg = new();
    <% } %>
endfunction // new

