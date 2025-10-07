
////////////////////////////////////////////////////////////////////////////////
//
// concerto_env 
<% if (1 == 0) { %>
// Author: Satya Prakash
<% } %>
//
////////////////////////////////////////////////////////////////////////////////

//File: concerto_base_test.svh

<%

var chiA_present=0;
var pma_en_dmi_blk = 1;
var pma_en_dii_blk = 1;
var pma_en_aiu_blk = 1;
var pma_en_dce_blk = 1;
var pma_en_dve_blk = 1;
var pma_en_at_least_1_blk = 0;
var pma_en_all_blk = 1;
var numChiAiu = 0; // Number of CHI AIUs
var numACEAiu = 0; // Number of ACE AIUs
var numIoAiu = 0; // Number of IO AIUs
var numCAiu = 0; // Number of Coherent AIUs
var numNCAiu = 0; // Number of Non-Coherent AIUs
var chiaiu0;  // strRtlNamePrefix of chiaiu0
var ioaiu0;  // strRtlNamePrefix of aceaiu0
var aceaiu0;  // strRtlNamePrefix of aceaiu0
var idxIoAiuWithPC = obj.nAIUs; // To get valid index of NCAIU with ProxyCache. Initialize to nAIUs
var numAiuRpns = 0;   //Total AIU RPN's
var ioAiuWithPC;
var numDmiWithSMC = 0; // Number of DMIs with SystemMemoryCache
var idxDmiWithSMC = 0; // To get valid index of DMI with SystemMemoryCache
var numDmiWithSP = 0; // Number of DMIs with ScratchPad memory
var idxDmiWithSP = 0; // To get valid index of DMIs with ScratchPad memory
var numDmiWithWP = 0; // Number of DMIs with WayPartitioning
var idxDmiWithWP = 0; // To get valid index of DMIs with WayPartitioning
var initiatorAgents   = obj.AiuInfo.length ;
var aiu_NumCores = [];
var aiu_NumPorts =0;
var found_csr_access_chiaiu=0;
var found_csr_access_ioaiu=0;
var csrAccess_ioaiu;
var csrAccess_chiaiu;
var aiu_rpn = [];
const aiu_axiInt = [];
const aiu_axiIntLen = [];
const aiu_axiInt2 = [];
 for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn[0];
   } else {
       aiu_NumCores[pidx]    = 1;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn;
   }
 }
 for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(obj.AiuInfo[pidx].nNativeInterfacePorts) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].nNativeInterfacePorts;
       aiu_NumPorts          += obj.AiuInfo[pidx].nNativeInterfacePorts;
   } else {
       aiu_NumCores[pidx]    = 1;
       aiu_NumPorts++;
   }
 }

for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    aiu_axiInt2[pidx] = [];
    if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
        aiu_axiInt[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt[0];
        aiu_axiIntLen[pidx] = obj.AiuInfo[pidx].interfaces.axiInt.length;
        for (var i=0; i<aiu_axiIntLen[pidx]; i++) {
           aiu_axiInt2[pidx].push(obj.AiuInfo[pidx].interfaces.axiInt[i]);
        }
    } else {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt;
        aiu_axiIntLen[pidx] = 1;
        aiu_axiInt2[pidx].push(obj.AiuInfo[pidx].interfaces.axiInt);
    }
}


for(var pidx = 0; pidx < obj.nDMIs; pidx++) {
    pma_en_dmi_blk &= obj.DmiInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DmiInfo[pidx].usePma;
    if(obj.DmiInfo[pidx].useCmc)
       {
         numDmiWithSMC++;
         idxDmiWithSMC = pidx;
         if(obj.DmiInfo[pidx].ccpParams.useScratchpad)
            {
              numDmiWithSP++;
              idxDmiWithSP = pidx;
            }
         if(obj.DmiInfo[pidx].useWayPartitioning)
            {
              numDmiWithWP++;
              idxDmiWithWP = pidx;
            }
       }
}
for(var pidx = 0; pidx < obj.nDIIs; pidx++) {
    pma_en_dii_blk &= obj.DiiInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DiiInfo[pidx].usePma;
}
// Assuming CHI AIU will appear first in AiuInfo in top.level.dv.json before IO-AIUs
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    pma_en_aiu_blk &= obj.AiuInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.AiuInfo[pidx].usePma;
    if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-B") || (obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) 
       { 
       if(obj.AiuInfo[pidx].fnNativeInterface == "CHI-A") {
           chiA_present=1;
           throw "ERROR - NCORE3.6 does not support CHI-A native interface in CHIAIU."
       }
       if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
      // CLU TMP COMPILE FIX CONC-11383 if(obj.AiuInfo[pidx].fnCsrAccess == 1) {
         if (found_csr_access_chiaiu == 0) {
          csrAccess_chiaiu = numChiAiu;
          found_csr_access_chiaiu = 1;
         }
       //}
       numChiAiu++ ; numCAiu++ ; 
       }
    else
       { 
     // CLU TMP COMPILE FIX CONC-11383  if(obj.AiuInfo[pidx].fnCsrAccess == 1) {
            if (found_csr_access_ioaiu == 0) {
	       csrAccess_ioaiu = numIoAiu;
	       found_csr_access_ioaiu = 1;
            }
     //    }
         numIoAiu++ ; 
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE"||obj.AiuInfo[pidx].fnNativeInterface == "ACE5") { 
            if(numACEAiu == 0) { aceaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; ioaiu0=aceaiu0;}
            numCAiu++; numACEAiu++; 
         } else {
            if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
               if (numNCAiu == 0) { ncaiu0  = obj.AiuInfo[pidx].strRtlNamePrefix + "_0"; ioaiu0=ncaiu0;}
            } else {
               if (numNCAiu == 0) { ncaiu0  = obj.AiuInfo[pidx].strRtlNamePrefix; ioaiu0=ncaiu0;}
            }
            numNCAiu++ ;
         }
//         if(obj.AiuInfo[pidx].useCache) idxIoAiuWithPC = numNCAiu;
         if(obj.AiuInfo[pidx].useCache) {
            idxIoAiuWithPC = numNCAiu-1;
            if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
                ioAiuWithPC  = obj.AiuInfo[pidx].strRtlNamePrefix + "_0";
            } else {
                ioAiuWithPC  = obj.AiuInfo[pidx].strRtlNamePrefix;
            }
         }
       }
    if(obj.AiuInfo[pidx].nNativeInterfacePorts) {
       numAiuRpns += obj.AiuInfo[pidx].nNativeInterfacePorts;
    } else {
       numAiuRpns++;
    }
}
for(var pidx = 0; pidx < obj.nDCEs; pidx++) {
    pma_en_dce_blk &= obj.DceInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DceInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nDVEs; pidx++) {
    pma_en_dve_blk &= obj.DveInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DveInfo[pidx].usePma;
}
pma_en_all_blk = pma_en_dmi_blk & pma_en_dii_blk & pma_en_aiu_blk & pma_en_dce_blk & pma_en_dve_blk;

console.log("pma_en_at_least_1_blk = "+pma_en_at_least_1_blk);
console.log("pma_en_all_blk = "+pma_en_all_blk);

// For DMI registers's offset value
function getDmiOffset(register) {
    var found=0;
    var offset=0; 
    obj.DmiInfo.forEach(function regOffsetFindSB(item,i){
                            if(!found){
                               const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                               if(reg != undefined) {
                                  found = 1;
                                  offset = reg.addressOffset;
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For CHI registers's offset value
function getChiOffset(register) {
    var found=0;
    var offset=0; 
    obj.AiuInfo.forEach(function regOffsetFindSB(item,i){
                            if(item.fnNativeInterface === "CHI-A" || item.fnNativeInterface === "CHI-B" || item.fnNativeInterface === "CHI-E") {
                               if(!found){
                                  const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                                  if(reg != undefined) {
                                     found = 1;
                                     offset = reg.addressOffset;
                                  }
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For IOAIU registers's offset value
function getIoOffset(register) {
    var found=0;
    var offset=0; 
    obj.AiuInfo.forEach(function regOffsetFindSB(item,i){
                            if(!(item.fnNativeInterface === "CHI-A" || item.fnNativeInterface === "CHI-B" || item.fnNativeInterface === "CHI-E")) {
                               if(!found){
                                  const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                                  if(reg != undefined) {
                                     found = 1;
                                     offset = reg.addressOffset;
                                  }
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For DCE registers's offset value
function getDceOffset(register) {
    var found=0;
    var offset=0; 
    obj.DceInfo.forEach(function regOffsetFindSB(item,i){
                            if(!found){
                               const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                               if(reg != undefined) {
                                  found = 1;
                                  offset = reg.addressOffset;
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For DVE registers's offset value
function getDveOffset(register) {
    var found=0;
    var offset=0; 
    obj.DveInfo.forEach(function regOffsetFindSB(item,i){
                            if(!found){
                               const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                               if(reg != undefined) {
                                  found = 1;
                                  offset = reg.addressOffset;
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

obj.Dvm_NUnitIds = [] ;
for (i in obj.AiuInfo) {
    if(obj.AiuInfo[i].cmpInfo.nDvmSnpInFlight > 0) {
        obj.Dvm_NUnitIds.push(obj.AiuInfo[i].nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}

var SnoopEn;
   SnoopEn = 0;
   for(i in obj.Dvm_NUnitIds) {
      SnoopEn |= 1 << obj.Dvm_NUnitIds[i]; 
   }
%>
<% if(obj.testBench == 'fsys') { %>
 `ifdef VCS 
// Add for UVM-1.2 compatibility
class fsys_report_server extends uvm_default_report_server;

   function new(string name = "fsys_report_server");
    super.new();
   endfunction
 
   virtual function void report_summarize(UVM_FILE file = 0);
   uvm_report_server svr;
    string id;
    string name;
    string output_str;
    string q[$],q2[$];
    int m_max_quit_count,m_quit_count;
    int m_severity_count[uvm_severity];
    int m_id_count[string];
    bit enable_report_id_count_summary =1 ;
    uvm_severity q1[$];

    svr = uvm_report_server::get_server();
    m_max_quit_count = get_max_quit_count();
    m_quit_count = get_quit_count();

    svr.get_id_set(q2);
    foreach(q2[s])
      m_id_count[q2[s]] = svr.get_id_count(q2[s]);

    svr.get_severity_set(q1);
    foreach(q1[s])
      m_severity_count[q1[s]] = svr.get_severity_count(q1[s]);


    uvm_report_catcher::summarize();
    q.push_back("\n--- UVM Report Summary ---\n\n");

    if(m_max_quit_count != 0) begin
      if ( m_quit_count >= m_max_quit_count )
        q.push_back("Quit count reached!\n");
      q.push_back($sformatf("Quit count : %5d of %5d\n",m_quit_count, m_max_quit_count));
    end

    q.push_back("** Report counts by severity\n");
    foreach(m_severity_count[s]) begin
      q.push_back($sformatf("%s :%5d\n", s.name(), m_severity_count[s]));
    end

    if (enable_report_id_count_summary) begin
      q.push_back("** Report counts by id\n");
      foreach(m_id_count[id])
        q.push_back($sformatf("[%s] %5d\n", id, m_id_count[id]));
    end

    `uvm_info("UVM/REPORT/SERVER",`UVM_STRING_QUEUE_STREAMING_PACK(q),UVM_NONE)

  endfunction


endclass
`endif 
<% }  %>
//`ifdef IO_SUBSYS_SNPS
    typedef     concerto_legacy_boot_tasks_snps;
//`endif // `ifdef IO_SUBSYS_SNPS
class concerto_base_test extends uvm_test;

    //////////////////
    //Properties
    //////////////////

    bit chiA_present = <%=chiA_present%>;
    static string inst_name="";
    concerto_test_cfg test_cfg;
    //Handle to config object for Concerto Environment Config
    concerto_env_cfg m_concerto_env_cfg;
<% if(obj.testBench=="emu") { %>
    virtual mgc_resp_intf mgc_resp_if ;
<%}%>

    parameter VALID_MAX_CREDIT_VALUE = 31;
    `ifndef VCS
    virtual reset_if m_reset_vif;
    `endif // `ifndef VCS

    //Handle to Concerto Environment
  
    concerto_env         m_concerto_env;
    regmodel_warning_catcher catcher_regmodel;
    snps_vip_catcher         catcher_snps_vip;
    

     concerto_legacy_emu_tasks emu_boot_tsk;
//`ifdef IO_SUBSYS_SNPS
     concerto_legacy_boot_tasks_snps legacy_boot_tsk_snps;
//`endif // `ifdef IO_SUBSYS_SNPS
    
    concerto_rw_csr_generic rw_tsks; // will be override

     // handle concerto boot tasks
    concerto_boot_tasks conc_boot_tsk;
    // Handle sw credit manager 
    concerto_sw_credit_mgr  m_concerto_sw_credit_mgr;
    // FSC tasks
    concerto_fsc_tasks conc_fsc_tsk;
    concerto_secded_parity_err_tasks conc_secded_parity_err_tsk;

    concerto_args      m_args;

    addr_trans_mgr   addr_mgr;
    ncore_memory_map m_mem; 

    `ifdef CHI_SUBSYS
        <% for(let id = 0; id < obj.nCHIs; id++) { %>
            virtual chi_aiu_dut_probe_if m_chi<%=id%>_probe_vif;
        <%}%>
    `endif

  // BEGIN SLAVE_SEQ
    <% var axi_slv_idx=0; %>
    <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
        // SNPS SLAVE SEQ
        axi_slave_mem_response_sequence m_axi_slave_mem_response_sequence_dmi<%=axi_slv_idx%>;
        // INHOUSE SLAVE SEQ
        dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_read_seq   m_axi_slv_rd_seq_dmi<%=pidx%>;
        dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_write_seq  m_axi_slv_wr_seq_dmi<%=pidx%>;
        <% axi_slv_idx  = axi_slv_idx + 1; %>
    <% } %>

    <% for(var pidx = 0 ; pidx < obj.nDIIs; pidx++) { %>
	<% if(obj.DiiInfo[pidx].configuration == 0) { %>
        // SNPS SLAVE SEQ
        axi_slave_mem_response_sequence m_axi_slave_mem_response_sequence_dii<%=axi_slv_idx%>;
        // INHOUSE SLAVE SEQ
        dii<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_read_seq   m_axi_slv_rd_seq_dii<%=pidx%>;
        dii<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_write_seq  m_axi_slv_wr_seq_dii<%=pidx%>;
        <% axi_slv_idx  = axi_slv_idx + 1; %>
        <% } %>
    <% } %>
  // END SLAVE_SEQ

    int 	aiu_qos_threshold[int];
    int 	dce_qos_threshold[int];
    int 	dmi_qos_threshold[int];
    int 	dmi_qos_rsved;  // qos threshold reserved for high priority
    //DMIUSMCAPR policy testting
    int dmiusmc_policy = 0;
    int dmiusmc_policy_rand = 0;
    bit dmi_nallocen_rand;
    bit dmi_nlooken_rand;
    //XAIUPCTCR disables sending update commands for evictions
    int update_cmd_disable = 0; // should be 0 or 1

    string      aiu_qos_threshold_str[];
    string      aiu_qos_threshold_arg;
    string      dce_qos_threshold_str[];
    string      dce_qos_threshold_arg;
    string      dmi_qos_threshold_str[];
    string      dmi_qos_threshold_arg;
   
    //timeout
    longint m_timeout_ns;

    longint sim_timeout_ms;
  
    /** reginit event **/ 
    uvm_event         reginit_done;

    /** disable initilization ***/
    bit reg_bitbash_rst_test;
    //NRSAR test 
    bit k_nrsar_test;

    // #Stimulus.FSYS.address_dec_error.illegalCSRaccess.ioaiu
    bit k_decode_err_illegal_acc_format_test_unsupported_size;
   
    addr_trans_mgr  m_addr_mgr;

    uvm_event toggle_rstn;
    uvm_event hard_rstn_ev;
    uvm_event hard_rstn_finished_ev;

    static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();
    static uvm_event csr_init_done = ev_pool.get("csr_init_done");
    static uvm_event ev_sim_done   = ev_pool.get("sim_done");
    static uvm_event val_change_k_decode_err_illegal_acc_format_test_unsupported_size = ev_pool.get("val_change_k_decode_err_illegal_acc_format_test_unsupported_size");
    uvm_event                    svt_axi_common_aclk_posedge_e;

<% var cidx=0;
var ioidx=0;
for(pidx=0; pidx<obj.nAIUs; pidx++) {
if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { 
if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || (obj.AiuInfo[pidx].fnNativeInterface == "ACE5")|| ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache)) || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI5") && (obj.AiuInfo[pidx].useCache)) ||((obj.AiuInfo[pidx].fnNativeInterface == "AXI5") && (obj.AiuInfo[pidx].orderedWriteObservation == true)) || ((obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E") && (obj.AiuInfo[pidx].orderedWriteObservation == true)) ||((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].orderedWriteObservation == true)) || ((obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE") && (obj.AiuInfo[pidx].orderedWriteObservation == true))) { %>
    static uvm_event ev_sysco_fsm_state_change_<%=obj.AiuInfo[pidx].FUnitId%> = ev_pool.get("ev_sysco_fsm_state_change_<%=obj.AiuInfo[pidx].FUnitId%>");
<% } ioidx++; }
else { %>
    static uvm_event ev_toggle_sysco_chiaiu<%=cidx%> = ev_pool.get("ev_toggle_sysco_chiaiu<%=cidx%>");
<% cidx++; }
} %>

int act_cmd_skid_buf_size[string][];//array to hold act. values of skid buffer size of each DMI/DCE/DII. act_cmd_skid_buf_size[DMI/DCE/DII][skid_buf_size] 
int act_mrd_skid_buf_size[string][];
int act_cmd_skid_buf_arb[string][];//array to hold act. values of skid buffer arb of each DMI/DCE/DII. act_cmd_skid_buf_arb[DMI/DCE/DII][skid_buf_size] 
int act_mrd_skid_buf_arb[string][];
int exp_cmd_skid_buf_size[string][];//array to hold act. values of skid buffer size of each DMI/DCE/DII. exp_cmd_skid_buf_size[DMI/DCE/DII][skid_buf_size] 
int exp_mrd_skid_buf_size[string][];
int exp_cmd_skid_buf_arb[string][];//array to hold act. values of skid buffer arb of each DMI/DCE/DII. exp_cmd_skid_buf_arb[DMI/DCE/DII][skid_buf_size] 
int exp_mrd_skid_buf_arb[string][];
bit [($clog2(VALID_MAX_CREDIT_VALUE)) - 1:0] aCredit_Cmd[int][int];//array to associate each aiu to DMI/DCE/DII credit aCredit[Aiuid][Dmiid/Dceid/Diiid]
bit [($clog2(VALID_MAX_CREDIT_VALUE)) - 1:0] aCredit_Mrd[int][int];//array to associate each dce to DMI credit aCredit[Dceid][Dmiid]
int numCmdCCR;
int numMrdCCR;
int AiuIds[];
int DceIds[];
int DmiIds[];
int DiiIds[];
int chiaiu_en[int];
int ioaiu_en[int];
int numChiAiu=<%=numChiAiu%>;
int numIoAiu=<%=numIoAiu%>;
int active_numChiAiu=0;
int active_numIoAiu=0;
int csrAccess_ioaiu=0;
int csrAccess_chiaiu=0;
bit [<%=numChiAiu%>-1:0]t_chiaiu_en;
bit [<%=numIoAiu%>-1:0]t_ioaiu_en;
bit [31:0]sys_reg_exp_data_val[string][];
bit [31:0]sys_reg_exp_data_mask[string][];

int aiu_dmi_connect[];
int aiu_dii_connect[];
int aiu_dce_connect[];
int dce_dmi_connect[];
int dce_connected[];
int dmi_connected[];
int dce_dmi_connected[];
int dii_connected[];

bit disable_bist; // pin to disable bist,trace&debug & apb_csr

bit detect_dmi_atomicDecErr;
<% if(obj.useResiliency == 1) { %>
virtual fault_if m_master_fsc;
<% } %>

    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_base_test)

    //////////////////
    //Methods
    //////////////////
    extern function new(string name = "concerto_base_test", uvm_component parent = null);
    extern static function concerto_base_test get_instance();
    extern virtual function void build_phase(uvm_phase  phase);
    extern function void assign_args();
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);
    extern virtual function void check_phase(uvm_phase phase);
    extern function void heartbeat(uvm_phase phase);
    extern function void set_inactivity_period(int timeout);
    extern function void set_sim_timeout(int timeout);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual task configure_ncore_register_using_legacy_boot_task();
    extern virtual function void pre_abort();
    extern virtual task ncore_reset();
    virtual task post_reset_hook(uvm_phase phase); endtask // Extended test can override
    
    extern function void parse_str(output string out[], input byte separator, input string in);
endclass: concerto_base_test

//////////////////
//Calling Method: Child Class
//Description: Constructor
//Arguments:   UVM Default
//Return type: N/A
//////////////////
function concerto_base_test::new(string name = "concerto_base_test", uvm_component parent = null);
    super.new(name, parent);
    m_addr_mgr = addr_trans_mgr::get_instance();
    if(chiA_present)
        `uvm_error(get_name(),"NCORE3.6 does not support CHI-A native interface in CHIAIU. Hence, Killing the test")
    if(inst_name=="")
      inst_name=name;
endfunction: new

function concerto_base_test concerto_base_test::get_instance();
concerto_base_test base_test;
uvm_root top;
  top = uvm_root::get();
  if(top.get_child(inst_name)==null)
    $display("concerto_base_test, could not find handle of base_test %0s",inst_name);
  else
    $cast(base_test,top.get_child(inst_name));
  return base_test;

endfunction:get_instance

//////////////////
//Calling Method: UVM Factory
//Description: Build phase
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_base_test::build_phase(uvm_phase phase);
     uvm_factory factory = uvm_factory::get();
     `uvm_info("Build", "Entered Build Phase", UVM_LOW);
    
    if(!$value$plusargs("disable_bist=%d",disable_bist)) disable_bist=0;

    super.build_phase(phase);

    if(!$value$plusargs("k_nrsar_test=%d",k_nrsar_test))begin
       k_nrsar_test = 0;
    end
 if(!$value$plusargs("aiu_qos_threshold=%s", aiu_qos_threshold_arg)) begin
    <% for(var pidx = 0 ; pidx < aiu_NumPorts; pidx++) { %>
       aiu_qos_threshold[<%=pidx%>] = 64;
    <% } %>
    end
    else begin
       parse_str(aiu_qos_threshold_str, "n", aiu_qos_threshold_arg);
       foreach (aiu_qos_threshold_str[i]) begin
	  aiu_qos_threshold[i] = aiu_qos_threshold_str[i].atoi();
       end
    end
 
    if(!$value$plusargs("dce_qos_threshold=%s", dce_qos_threshold_arg)) begin
    <% for(var pidx = 0 ; pidx < obj.nDCEs; pidx++) { %>
       dce_qos_threshold[<%=pidx%>] = 64;
    <% } %>
    end
    else begin
       parse_str(dce_qos_threshold_str, "n", dce_qos_threshold_arg);
       foreach (dce_qos_threshold_str[i]) begin
	  dce_qos_threshold[i] = dce_qos_threshold_str[i].atoi();
       end
    end
 
    if(!$value$plusargs("dmi_qos_threshold=%s", dmi_qos_threshold_arg)) begin
    <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
       dmi_qos_threshold[<%=pidx%>] = 64;
    <% } %>
    end
    else begin
       parse_str(dmi_qos_threshold_str, "n", dmi_qos_threshold_arg);
       foreach (dmi_qos_threshold_str[i]) begin
	  dmi_qos_threshold[i] = dmi_qos_threshold_str[i].atoi();
       end
    end

    if(!$value$plusargs("dmi_qos_rsved=%h", dmi_qos_rsved)) begin
       dmi_qos_rsved = 'h80000101; // 8 QOS threshold val / 1 RTT & WTT reserved for high priority
    end

    addr_mgr = addr_trans_mgr::get_instance();
    addr_mgr.gen_memory_map();
    m_mem = addr_mgr.get_memory_map_instance();

    //Construct Concerto Environment Config Object
    m_concerto_env_cfg = concerto_env_cfg::type_id::create("m_concerto_env_cfg");
    uvm_config_db #(concerto_env_cfg)::set(uvm_root::get(), "", "m_cfg", m_concerto_env_cfg);
    m_concerto_env = concerto_env::type_id::create("m_concerto_env", this);
    uvm_config_db #(concerto_env)::set(uvm_root::get(), "", "m_env", m_concerto_env);
      // add demote RAL warning
     catcher_regmodel = new("catcher_regmodel");
     catcher_snps_vip = new("catcher_snps_vip");
     uvm_report_cb::add(null, catcher_regmodel);
     uvm_report_cb::add(null, catcher_snps_vip);
    //Construct Concerto Test Config Object
    test_cfg = concerto_test_cfg::type_id::create("test_cfg");
    uvm_config_db #(concerto_test_cfg)::set(uvm_root::get(), "", "test_cfg", test_cfg);

    m_concerto_env_cfg.m_mem_checker_cfg = mem_checker_cfg::type_id::create("mem_checker_cfg");
    uvm_config_db #(mem_checker_cfg)::set(uvm_root::get(), "", "m_mem_checker_cfg", m_concerto_env_cfg.m_mem_checker_cfg);

    
    if (m_concerto_env_cfg.use_rw_csr_snps) begin
      concerto_rw_csr_generic::type_id::set_type_override(concerto_rw_csr_snps_tasks::get_type() );
    end else begin
      concerto_rw_csr_generic::type_id::set_type_override(concerto_rw_csr_inhouse_tasks::get_type() );
    end
    rw_tsks = concerto_rw_csr_generic::type_id::create("concerto_rw_csr_tasks",this); // override

    //Process all command line args
    m_args = new();
 // if (!uvm_config_db#(virtual reset_if)::get(.cntxt( this ),
 //                                          .inst_name( "" ),
 //                                          .field_name( "reset_vif" ),
 //                                          .value( m_reset_vif ))) begin
 //   `uvm_error("concerto_base_test", "reset_vif not found")
 // end
 // 

    if ($test$plusargs("use_emu_tsk")) begin
    emu_boot_tsk = concerto_legacy_emu_tasks::type_id::create("emu_boot_tsk",this);
    emu_boot_tsk.m_args=m_args; 
    end else begin 

//`ifdef IO_SUBSYS_SNPS
    // Construct component to preserve legacy boot using synopsys
    if (test_cfg.use_new_csr==0) begin:_build_legacy_boot_tsk_snps
      legacy_boot_tsk_snps= concerto_legacy_boot_tasks_snps::type_id::create("legacy_boot_tsk_snps",this);
      uvm_config_db #(concerto_legacy_boot_tasks_snps)::set(uvm_root::get(), "", "legacy_boot_tsk_snps", legacy_boot_tsk_snps);
    end : _build_legacy_boot_tsk_snps
//`endif // `ifdef IO_SUBSYS_SNPS

    //Construct sw credit manager object Config Object 
    m_concerto_sw_credit_mgr = concerto_sw_credit_mgr::type_id::create("m_concerto_sw_credit_mgr",this);
    uvm_config_db #(concerto_sw_credit_mgr)::set(uvm_root::get(), "", "m_concerto_sw_credit_mgr", m_concerto_sw_credit_mgr);
    
    conc_boot_tsk = concerto_boot_tasks::type_id::create("conc_boot_tsk",this);
    conc_fsc_tsk = concerto_fsc_tasks::type_id::create("conc_fsc_tsk",this);
    conc_secded_parity_err_tsk = concerto_secded_parity_err_tasks::type_id::create("conc_secded_parity_err_tsk",this);
    end

   
    <% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
        if (!uvm_config_db #(virtual dce<%=pidx%>_probe_if)::get(
        .cntxt(this),
        .inst_name(""),
        .field_name("m_dce<%=pidx%>_probe_if"),
        .value(m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.m_probe_vif))) begin
        `uvm_fatal(get_name(), "unable to find probe vif in configuration db")
        end
    <%}%>
    `ifdef CHI_SUBSYS
        <% for(let id = 0; id < obj.nCHIs; id++) { %>
            if (!uvm_config_db #(virtual chi_aiu_dut_probe_if)::get(
            .cntxt(this),
            .inst_name(""),
            .field_name("m_chiaiu<%=id%>_chi_aiu_dut_probe_if"),
            .value(m_chi<%=id%>_probe_vif))) begin
                `uvm_fatal(get_name(), "unable to find probe chi vif in configuration db")
            end
        <%}%>
    `endif

    <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
    if (!uvm_config_db #(virtual dve<%=pidx%>_clock_counter_if)::get(
       .cntxt(this),
       .inst_name(""),
       .field_name("m_dve<%=pidx%>_clock_counter_if"),
       .value(m_concerto_env_cfg.m_dve<%=pidx%>_env_cfg.m_clock_counter_vif))) begin

       `uvm_fatal(get_name(), "Unable to find dve<%=pidx%>_clock_counter_vif in configuration db")
    end
    <% } %>

    assign_args(); 

     if (m_concerto_env_cfg.has_axi_slv_vip_snps) begin:_build_axi_slv_aclk
          svt_axi_common_aclk_posedge_e = new("svt_axi_common_aclk_posedge_e");
         if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                         .inst_name(""),
                                         .field_name( "svt_axi_common_aclk_posedge_e" ),
                                         .value( svt_axi_common_aclk_posedge_e ))) begin
            `uvm_error(get_name(), "Event svt_axi_common_aclk_posedge_e is not found")
         end
     end:_build_axi_slv_aclk

if( m_concerto_env_cfg.has_axi_slv_vip_snps) begin:_build_axi_slv_vip_seq
    <% var axi_slv_idx  = 0; %>
    <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
        m_axi_slave_mem_response_sequence_dmi<%=axi_slv_idx%> =  axi_slave_mem_response_sequence::type_id::create("m_axi_slave_mem_response_sequence_dmi<%=axi_slv_idx%>");
        <% axi_slv_idx  = axi_slv_idx + 1; %>
    <% } %>
    
    <% for(var pidx = 0 ; pidx < obj.nDIIs; pidx++) { %>
        <% if(obj.DiiInfo[pidx].configuration == 0) { %>
        m_axi_slave_mem_response_sequence_dii<%=axi_slv_idx%> =  axi_slave_mem_response_sequence::type_id::create("m_axi_slave_mem_response_sequence_dii<%=axi_slv_idx%>");
        <% axi_slv_idx  = axi_slv_idx + 1; %>
        <% } %>
    <% } %>
end:_build_axi_slv_vip_seq

    set_inactivity_period(m_args.k_timeout);
    set_sim_timeout(m_args.k_sim_timeout);
    

<% if(obj.PmaInfo.length > 0) { %>
<% } %>



    toggle_rstn = new("toggle_rstn");
    if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                    .inst_name(""),
                                    .field_name( "toggle_rstn" ),
                                    .value( toggle_rstn ))) begin
       `uvm_error("BASE_TEST", "Event toggle_rstn is not found")
    end

    //hard_rstn_ev = new("hard_rstn_ev");
    if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                    .inst_name(""),
                                    .field_name( "hard_rstn_ev" ),
                                    .value( hard_rstn_ev ))) begin
       `uvm_error("BASE_TEST", "Event hard_rstn_ev is not found")
                                    end

    // hard_rstn_finished_ev = new("hard_rstn_finished_ev");
    if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                    .inst_name(""),
                                    .field_name( "hard_rstn_finished_ev" ),
                                    .value( hard_rstn_finished_ev ))) begin
       `uvm_error("BASE_TEST", "Event hard_rstn_finished_ev is not found")   
    end

<% if(obj.useResiliency == 1) { %>
    if(!uvm_config_db#(virtual fault_if)::get( .cntxt(null),
                                  .inst_name( "" ),
                                  .field_name( "m_master_fsc" ),
                                  .value(m_master_fsc))) begin
        `uvm_error("BASE_TEST", "m_master_fsc Interface of type fault_if is not found")
    end
<% } %>

if($test$plusargs("k_decode_err_illegal_acc_format_test_unsupported_size")) begin
    //val_change_k_decode_err_illegal_acc_format_test_unsupported_size = new("val_change_k_decode_err_illegal_acc_format_test_unsupported_size");
end 
if (!m_concerto_env_cfg.has_axi_slv_vip_snps) begin
  <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
     if($test$plusargs("perf_test") || $test$plusargs("no_delay")) begin
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_slow_agent = 0;
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_burst_pct.set_value(100);
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_burst_pct.set_value(100);
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_addr_chnl_burst_pct.set_value(100);
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_data_chnl_burst_pct.set_value(100);
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_resp_chnl_burst_pct.set_value(100);
    end
      <% } %>

  <% for(var pidx = 0 ; pidx < obj.nDIIs; pidx++) { %>
      if($test$plusargs("perf_test") || $test$plusargs("no_delay")) begin
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_slow_agent = 0;
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_burst_pct.set_value(100);
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_burst_pct.set_value(100);
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_addr_chnl_burst_pct.set_value(100);
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_data_chnl_burst_pct.set_value(100);
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_resp_chnl_burst_pct.set_value(100);
    end 
  <% } %>
   <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
     if( $test$plusargs("long_delay")) begin
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_burst_pct.set_value(2);
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_burst_pct.set_value(2);
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_addr_chnl_burst_pct.set_value(2);
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_data_chnl_burst_pct.set_value(2);
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_resp_chnl_burst_pct.set_value(2);
       //min-max delay
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_delay_min.set_value(1000);
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_delay_max.set_value(1500);
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_delay_min.set_value(1000);
       m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_delay_max.set_value(1500);
    end
      <% } %>

  <% for(var pidx = 0 ; pidx < obj.nDIIs; pidx++) { %>
      if( $test$plusargs("long_delay")) begin
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_burst_pct.set_value(2);
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_burst_pct.set_value(2);
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_addr_chnl_burst_pct.set_value(2);
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_data_chnl_burst_pct.set_value(2);
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_write_resp_chnl_burst_pct.set_value(2);
       //min-max delay
        m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_delay_min.set_value(1000);
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_addr_chnl_delay_max.set_value(1500);
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_delay_min.set_value(1000);
       m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_chnl_delay_max.set_value(1500);
    end 
  <% } %>
end
    `uvm_info("Build", "Exited Build Phase", UVM_LOW)
endfunction: build_phase

//////////////////
//Calling Method: UVM Factory
//Description: start of simulatioin
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_base_test::start_of_simulation_phase(uvm_phase phase);
    int qos_threshold;
  <% if(obj.testBench == 'fsys') { %>
  `ifdef VCS 
  fsys_report_server my_server = new();
   `endif
  <% } %>
    uvm_phase run_phase;
    super.start_of_simulation_phase(phase);
    //SANJEEV
    test_cfg.init_cfg();
    <% if(obj.testBench == 'fsys') { %>
  `ifdef VCS 
    uvm_report_server::set_server( my_server );
  `endif
  <% } %>

// BEGIN setup virtual_sequencer  
<% var cidx = 0; %>
<% var qidx = 0; %>
<% for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
      if(m_args.ioaiu_scb_en) begin
         <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %> 
         m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_scb.tctrlr[0].native_trace_en = 1;  // FIXME - need to take in flags and set more settings
         <% } %>
      end
      <%  qidx++; } %>
      <% } %>
// END setup virtual_seq  

    heartbeat(phase);
    //Setting Drain time
`ifndef VCS    
    run_phase  = uvm_run_phase::get();
    run_phase.phase_done.set_drain_time(this, 5*1us);
`endif

//setting verbosity level for components
 //  m_concerto_env.inhouse.m_dve0_env.set_report_verbosity_level_hier(UVM_NONE);
 //  m_concerto_env.inhouse.m_dmi0_env.set_report_verbosity_level_hier(UVM_NONE);
 //  m_concerto_env.inhouse.m_dii0_env.set_report_verbosity_level_hier(UVM_NONE);
 //  m_concerto_env.inhouse.m_ioaiu3_env.set_report_verbosity_level_hier(UVM_NONE);
 //  m_concerto_env.inhouse.m_ioaiu4_env.set_report_verbosity_level_hier(UVM_NONE);
 //  m_concerto_env.inhouse.m_ioaiu5_env.set_report_verbosity_level_hier(UVM_NONE);
 //  m_concerto_env.inhouse.m_ioaiu6_env.set_report_verbosity_level_hier(UVM_NONE);


endfunction: start_of_simulation_phase

//////////////////
//Calling Method: start_of_simulation_phase
//Description: Timeout functioinality
//Arguments:   phase
//Return type: Void
//////////////////
function void concerto_base_test::heartbeat(uvm_phase phase);
    uvm_callbacks_objection cb;
    uvm_heartbeat hb;
    uvm_event e;
    uvm_component comp_q[$];
    timeout_catcher catcher;
    uvm_phase run_phase;

    e = new("e");
    run_phase = phase.find_by_name("run", 0);
    catcher = timeout_catcher::type_id::create("catcher", this);
    catcher.phase      = run_phase;
    catcher.m_reporter = m_concerto_env.m_reporter;
    uvm_report_cb::add(null, catcher);
    
    if(!$cast(cb, run_phase.get_objection()))
        `uvm_fatal("Run", "run phase objection type isn't of type uvm_callbacks_objection. you need to define UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE!");

    hb = new("activity_heartbeat", this, cb);
    uvm_top.find_all("*", comp_q, this);

    hb.set_mode(UVM_ANY_ACTIVE);
    hb.set_heartbeat(e, comp_q);
   
    //foreach(comp_q[idx])begin
    //  `uvm_info("heatbeat",$sformatf("comp_q =%s",comp_q[idx].get_full_name()),UVM_NONE);
    //end
   
    //If AIU scoreboard is disabled use hard coded dealy
    if(m_args.chiaiu_scb_en) begin
        fork begin
            forever begin
                #(m_timeout_ns * 1ns) e.trigger();
            end
        end
        join_none 
    end else begin

        fork begin
             #(sim_timeout_ms*1ms);
             `uvm_fatal("HBFAIL", "Timeout mechanism");
        end
        join_none
    end
endfunction: heartbeat

//////////////////
//Calling Method: build_phase() or extnded tests
//Description: Set inactivity timeout period
//Arguments:   timeout in nanosec (int)
//Return type: Void
//////////////////
function void concerto_base_test::set_inactivity_period(int timeout);
    m_timeout_ns = timeout;
endfunction: set_inactivity_period

function void concerto_base_test::set_sim_timeout(int timeout);
    sim_timeout_ms = timeout;
endfunction: set_sim_timeout

function void concerto_base_test::check_phase(uvm_phase phase);
<% if(obj.useResiliency == 1) { %>
  if(test_cfg.end_of_sim_fault_check) begin
// For FSC tests, don't exclude these checks since test clears the faults with bist sequence.
      if (m_master_fsc.mission_fault!== 0) begin
          `uvm_error(get_full_name(),"mission_fault should be zero at end of test for no error injection")
      end
      if (m_master_fsc.latent_fault!== 0) begin
          `uvm_error(get_full_name(),"latent_fault should be zero at end of test for no error injection")
      end
      if (m_master_fsc.cerr_over_thres_fault!== 0) begin
          `uvm_error(get_full_name(),"cerr_over_thres_fault should be zero at end of test for no error injection")
      end
  end
<% } %>
endfunction: check_phase

//////////////////
//Calling Method: UVM Factory
//Description: report phase, calls report method to display EOT results
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_base_test::report_phase(uvm_phase phase);
    `uvm_info("report_phase", "Entered...", UVM_LOW)
    m_concerto_env.m_reporter.report_results();
    m_concerto_env.m_reporter.print_status();
endfunction : report_phase

//////////////////
//Calling Method: UVM Factory
//Description: assign configuration values that are passed from command line
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_base_test::assign_args();
 //  $display("force reset values = %d", m_args.force_reset_values);
 //  m_reset_vif.force_values = m_args.force_reset_values;

<% var cidx = 0; %>
<% var qidx = 0; %>
<% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
        m_concerto_env_cfg.m_chiaiu<%=cidx%>_env_cfg.has_scoreboard                                             = m_args.chiaiu_scb_en;
        <% cidx++; %>
    <%} else { %>
     <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
        m_concerto_env_cfg.m_ioaiu<%=qidx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_num_read_req                       = m_args.aiu<%=pidx%>_k_num_read_req;
        m_concerto_env_cfg.m_ioaiu<%=qidx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_num_write_req                      = m_args.aiu<%=pidx%>_k_num_write_req;
        m_concerto_env_cfg.m_ioaiu<%=qidx%>_env_cfg[<%=i%>].has_scoreboard                                              = m_args.ioaiu_scb_en;
      <% }%>  
        <% qidx++; %>
    <% } %>
<% } %>

<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
    m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.has_scoreboard = m_args.dmi_scb_en;
    m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_interleave_dis.set_value(1);
<% } %>
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
    m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.has_scoreboard = m_args.dii_scb_en;
    m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_interleave_dis.set_value(1);
<% } %>
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
    m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.has_scoreboard  = m_args.dce_scb_en;
    m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.en_dm_dbg(m_args.dce_dm_dbg_en);
<% } %>
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
    m_concerto_env_cfg.m_dve<%=pidx%>_env_cfg.has_sb         = m_args.dve_scb_en;
<% } %>
endfunction: assign_args

function void concerto_base_test::pre_abort();
    `uvm_info("concerto_base_test", $psprintf("chi_container_pkg pre_abort"), UVM_NONE)
    <% var cidx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
           if (!m_concerto_env_cfg.has_chi_vip_snps) m_concerto_env.inhouse.m_chi<%=cidx%>_container.print_pending_txns();
	   <%  cidx++;   %>
      <% } %>
    <% } %>
endfunction : pre_abort

task concerto_base_test::ncore_reset();
   `uvm_info("BASE_TEST", "START RESET_PHASE", UVM_LOW)
    hard_rstn_ev.trigger();
   `uvm_info("BASE_TEST", "WAIT ASYNC RESET", UVM_LOW)
    hard_rstn_finished_ev.wait_trigger();
   `uvm_info("BASE_TEST", "END RESET_PHASE", UVM_LOW)
endtask

task concerto_base_test::run_phase(uvm_phase phase);
   uvm_status_e status;
   uvm_objection obj;
   phase.raise_objection(this, "concerto_fullsys_test_run_phase");

`ifdef VCS    
    obj = phase.get_objection();
    obj.set_drain_time(this, 5*1us);
`endif    
    addr_mgr.get_connectivity_if();

if (!m_concerto_env_cfg.has_axi_slv_vip_snps) begin:_launch_inhouse_slv_seq 
 // BEGIN SLAVE_SEQ
  <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
    m_axi_slv_rd_seq_dmi<%=pidx%> = dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_read_seq::type_id::create("m_axi_slv_rd_seq_dmi");
    m_axi_slv_wr_seq_dmi<%=pidx%> = dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_write_seq::type_id::create("m_axi_slv_wr_seq_dmi");

    m_axi_slv_rd_seq_dmi<%=pidx%>.m_read_addr_chnl_seqr  = m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_axi_slave_agent.m_read_addr_chnl_seqr;
    m_axi_slv_rd_seq_dmi<%=pidx%>.m_read_data_chnl_seqr  = m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_axi_slave_agent.m_read_data_chnl_seqr;
    m_axi_slv_rd_seq_dmi<%=pidx%>.m_memory_model         = m_concerto_env.inhouse.m_axi_slv_memory_model_dmi<%=pidx%>;
    m_axi_slv_rd_seq_dmi<%=pidx%>.prob_ace_rd_resp_error = m_args.dmi<%=pidx%>_prob_ace_slave_rd_resp_error;
    m_axi_slv_wr_seq_dmi<%=pidx%>.m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_axi_slave_agent.m_write_addr_chnl_seqr;
    m_axi_slv_wr_seq_dmi<%=pidx%>.m_write_data_chnl_seqr = m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_axi_slave_agent.m_write_data_chnl_seqr;
    m_axi_slv_wr_seq_dmi<%=pidx%>.m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_axi_slave_agent.m_write_resp_chnl_seqr;
    m_axi_slv_wr_seq_dmi<%=pidx%>.m_memory_model         = m_concerto_env.inhouse.m_axi_slv_memory_model_dmi<%=pidx%>;
    m_axi_slv_wr_seq_dmi<%=pidx%>.prob_ace_wr_resp_error = m_args.dmi<%=pidx%>_prob_ace_slave_wr_resp_error;

      <% } %>

  <% for(var pidx = 0 ; pidx < obj.nDIIs; pidx++) { %>
    <% if(obj.DiiInfo[pidx].configuration == 0) { %>
    m_axi_slv_rd_seq_dii<%=pidx%> = dii<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_read_seq::type_id::create("m_axi_slv_rd_seq_dii");
    m_axi_slv_wr_seq_dii<%=pidx%> = dii<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_write_seq::type_id::create("m_axi_slv_wr_seq_dii");

    m_axi_slv_rd_seq_dii<%=pidx%>.m_read_addr_chnl_seqr  = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_read_addr_chnl_seqr;
    m_axi_slv_rd_seq_dii<%=pidx%>.m_read_data_chnl_seqr  = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_read_data_chnl_seqr;
    m_axi_slv_rd_seq_dii<%=pidx%>.m_memory_model         = m_concerto_env.inhouse.m_axi_slv_memory_model_dii<%=pidx%>;
    m_axi_slv_rd_seq_dii<%=pidx%>.prob_ace_rd_resp_error = m_args.dii<%=pidx%>_prob_ace_slave_rd_resp_error;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_write_addr_chnl_seqr;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_write_data_chnl_seqr = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_write_data_chnl_seqr;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_write_resp_chnl_seqr;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_memory_model         = m_concerto_env.inhouse.m_axi_slv_memory_model_dii<%=pidx%>;
    m_axi_slv_wr_seq_dii<%=pidx%>.prob_ace_wr_resp_error = m_args.dii<%=pidx%>_prob_ace_slave_wr_resp_error;
    <% } %>
  <% } %>

    fork
  <% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
        m_axi_slv_rd_seq_dmi<%=pidx%>.start(null);
        m_axi_slv_wr_seq_dmi<%=pidx%>.start(null);
  <% } %>
  <% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
    <% if(obj.DiiInfo[pidx].configuration == 0) { %>
        m_axi_slv_rd_seq_dii<%=pidx%>.start(null);
        m_axi_slv_wr_seq_dii<%=pidx%>.start(null);
    <% } %>
  <% } %>
    join_none
end:_launch_inhouse_slv_seq else begin:_launch_snps_vip_seq
  <% var axi_slv_idx=0; %>
  <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
    m_axi_slave_mem_response_sequence_dmi<%=axi_slv_idx%>.prob_ace_rd_resp_error = m_args.dmi<%=pidx%>_prob_ace_slave_rd_resp_error;
    m_axi_slave_mem_response_sequence_dmi<%=axi_slv_idx%>.prob_ace_wr_resp_error = m_args.dmi<%=pidx%>_prob_ace_slave_wr_resp_error;
    fork
    m_axi_slave_mem_response_sequence_dmi<%=axi_slv_idx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].slave[<%=axi_slv_idx%>].sequencer);
    join_none
    <% axi_slv_idx  = axi_slv_idx + 1; %>
  <% } %>
  <% for(var pidx = 0 ; pidx < obj.nDIIs; pidx++) { %>
    <% if(obj.DiiInfo[pidx].configuration == 0) { %>
    m_axi_slave_mem_response_sequence_dii<%=axi_slv_idx%>.prob_ace_rd_resp_error = m_args.dii<%=pidx%>_prob_ace_slave_rd_resp_error;
    m_axi_slave_mem_response_sequence_dii<%=axi_slv_idx%>.prob_ace_wr_resp_error = m_args.dii<%=pidx%>_prob_ace_slave_wr_resp_error;
    fork
    m_axi_slave_mem_response_sequence_dii<%=axi_slv_idx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].slave[<%=axi_slv_idx%>].sequencer);
    join_none
    <% axi_slv_idx  = axi_slv_idx + 1; %>
 <%}}%>
end:_launch_snps_vip_seq
 // END SLAVE_SEQ

 // Reset
 ncore_reset();

 post_reset_hook(phase);

 // Configure
 if(test_cfg.disable_boot_tasks==0 && test_cfg.use_new_csr==1) begin // APB boot
     conc_boot_tsk.ncore_configure();

     // SW credit configuration
     m_concerto_sw_credit_mgr.ncore_configure_sw_credits(); 

     // trigger csr_init_done to unit scoreboards
     csr_init_done.trigger(null);
     svt_axi_item_helper::disable_boot_addr(); //Needed for constraint c_no_nrs_addr_after_boot in io_subsys_axi_master_transaction.svh to indicate ncore configuration is finished
 end else if(test_cfg.disable_boot_tasks==0 && test_cfg.use_new_csr==0) begin // Configure ncore register using legacy boot task 
     configure_ncore_register_using_legacy_boot_task();

     // trigger csr_init_done to unit scoreboards
     csr_init_done.trigger(null);
     svt_axi_item_helper::disable_boot_addr(); //Needed for constraint c_no_nrs_addr_after_boot in io_subsys_axi_master_transaction.svh to indicate ncore configuration is finished
 end // if(test_cfg.use_new_csr==0) begin
 phase.drop_objection(this, "concerto_base_test_run_phase");
endtask:run_phase

task concerto_base_test::configure_ncore_register_using_legacy_boot_task(); 
    bit [31:0] agent_ids_assigned_q[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS][$];
    bit [31:0] wayvec_assigned_q[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS][$];
    int sp_ways[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
    int sp_size[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];

    bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
    bit [31:0] agent_id,way_vec,way_full_chk;
    int shared_ways_per_user;
    int way_for_atomic=0;

    int idxq[$];

    addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t csrq[$];
    csrq = addr_trans_mgr_pkg::addrMgrConst::get_all_gpra();
  `uvm_info("FULLSYS_TEST", "START configure_ncore_register_using_legacy_boot_task", UVM_LOW)
    if(test_cfg.use_new_csr==0) begin // Configure ncore register using legacy boot task 
        for(int i=0; i<addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS; i++) begin
        int max_way_partitioning;
           if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[i]) begin  
              way_for_atomic = $urandom_range(0,addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]-1);
           end
           if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_cmcwp[i]) begin  
              way_full_chk = 0;
              for(int k=0; k<<%=obj.nAIUs%>;k++) begin
                 agent_ids_assigned_q[i].push_back(k);  
              end
              agent_ids_assigned_q[i].shuffle();  
             max_way_partitioning = (addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i] > <%=obj.nAIUs%>) ? <%=obj.nAIUs%> : addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];
             for( int j=0;j<max_way_partitioning /*addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i]*/;j++) begin
                 if ($test$plusargs("all_way_partitioning")) begin
                    if((j==0)&&(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[j]==0)) begin 
                       agent_id = 32'h8000_0000 |  agent_ids_assigned_q[i][j]; agent_ids_assigned_q[i][j] = agent_id; end
                    else     begin agent_id = 32'h0000_0000 |  agent_ids_assigned_q[i][j]; agent_ids_assigned_q[i][j] = agent_id; end
                 end else begin
                    randcase
                      10 : begin agent_id = 32'h0000_0000 | agent_ids_assigned_q[i][j]; agent_ids_assigned_q[i][j] = agent_id; end
                      90 : begin agent_id = 32'h8000_0000 | agent_ids_assigned_q[i][j]; agent_ids_assigned_q[i][j] = agent_id; end
                    endcase
                 end

                 case(i) <%for(var sidx = 0; sidx < obj.nDMIs; sidx++) {%>
                    <%=sidx%> : begin <% if(obj.DmiInfo[sidx].useWayPartitioning && obj.DmiInfo[sidx].useCmc) {%>
                                     if(m_args.dmi_scb_en) begin
                                        m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.way_partition_vld[j] = agent_id[31]; m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.way_partition_reg_id[j] = agent_id[30:0];
                                        if ($test$plusargs("no_way_partitioning")) m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.way_partition_vld[j]=0;
                                        end
                                    <%}%>end
            <%}%>endcase

              end // for Waypart Registers
              if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[i]==0) begin
                 shared_ways_per_user = addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]/addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];
              end else begin
                 shared_ways_per_user = (addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]-1)/addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];
              end
              for( int j=0;j<addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];j++) begin
                  if ($test$plusargs("all_way_partitioning")&&(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[j]==0)) begin
                     way_vec = ((1<<addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i])-1);
                  end else begin
                     way_vec = ((1<<$urandom_range(1,shared_ways_per_user)) - 1) << (shared_ways_per_user)*j;
                  end
                  if ($test$plusargs("no_way_partitioning")) way_vec=0;
            	      `uvm_info("TEST PRE_CONFIGURE_PHASE", $sformatf("For DMI%0d reg%0d with wayvec :%0b",i,j,way_vec), UVM_LOW)
                  wayvec_assigned_q[i].push_back(way_vec);
                  way_full_chk |=way_vec;
                  `uvm_info("TEST PRE_CONFIGURE_PHASE", $sformatf("For DMI%0d reg%0d with wayfull:%0b num ways in DMI:%0d",i,j,way_full_chk,addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]), UVM_LOW)
              end

              for( int j=0;j<addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];j++) begin
                  `uvm_info("TEST PRE_CONFIGURE_PHASE", $sformatf("For DMI%0d reg%0d with wayfull:%0b count ones:%0d",i,j,way_full_chk,$countones(way_full_chk)), UVM_LOW)
                  way_vec = wayvec_assigned_q[i].pop_front;
                  if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[i] && $countones(way_full_chk)>=addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]) begin  
                     way_vec[way_for_atomic] = 1'b0;
                     `uvm_info("TEST PRE_CONFIGURE_PHASE", $sformatf("For DMI%0d with AtomicEngine way:%0d/%0d is unallocated, so that atomic txn can allocate",i,way_for_atomic,addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]), UVM_LOW)
                     `uvm_info("TEST PRE_CONFIGURE_PHASE", $sformatf("For DMI%0d reg%0d with wayvec :%0b",i,j,way_vec), UVM_LOW)
                  end
                  wayvec_assigned_q[i].push_back(way_vec);

                  case(i) <%for(var sidx = 0; sidx < obj.nDMIs; sidx++) {%>
                     <%=sidx%> : begin <% if(obj.DmiInfo[sidx].useWayPartitioning && obj.DmiInfo[sidx].useCmc) {%>
                                      if(m_args.dmi_scb_en) begin
                                         m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.way_partition_reg_way[j] = way_vec;
                                      end
                                      <%}%>end
             <%}%>endcase
              end
           end // if (addr_trans_mgr_pkg::addrMgrConst::dmis_with_cmcwp[i])

           // Configure Scratchpad memories
           if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_cmcsp[i]) begin  
              // Enabling and configuring Scratchpad using force
              if ($test$plusargs("all_ways_for_sp")) begin
                  sp_ways[i] = addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i];
              end else if ($test$plusargs("all_ways_for_cache")) begin
                  sp_ways[i] = 0;
              end else begin
                  randcase
                      //15 : sp_ways[i] = 0;
                      30 : sp_ways[i] = addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i];
                      30 : sp_ways[i] = (addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]/2);
                      40 : sp_ways[i] = $urandom_range(1,(addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]-1));
                  endcase
              end
 
              idxq = csrq.find_index(x) with (  (x.unit.name == "DMI") && (x.mig_nunitid == addr_trans_mgr_pkg::addrMgrConst::dmi_intrlvgrp[addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs][i]) );
              if(idxq.size() == 0) begin
                  `uvm_error("EXEC_INHOUSE_BOOT_SEQ", $sformatf("DMI%0d Interleaving group %0d not found", i, addr_trans_mgr_pkg::addrMgrConst::dmi_intrlvgrp[addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs][i]))
                  end
              k_sp_base_addr[i] = {csrq[idxq[0]].upp_addr,csrq[idxq[0]].low_addr,12'h0}; 

              sp_size[i] = addr_trans_mgr_pkg::addrMgrConst::dmi_CmcSet[i] * sp_ways[i];
              k_sp_base_addr[i] = $urandom_range(0, k_sp_base_addr[i] - (sp_size[i] << <%=obj.wCacheLineOffset%>) - 1);
              k_sp_base_addr[i] = k_sp_base_addr[i] >> ($clog2(addr_trans_mgr_pkg::addrMgrConst::dmi_CmcSet[i]*addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i])+<%=obj.wCacheLineOffset%>);
              k_sp_base_addr[i] = k_sp_base_addr[i] << ($clog2(addr_trans_mgr_pkg::addrMgrConst::dmi_CmcSet[i]*addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i])+<%=obj.wCacheLineOffset%>);

              <% if((obj.useCmc) && (numDmiWithSP > 0)) { %>
              if(m_args.dmi_scb_en) begin 
                  case(i) <%for(var sidx = 0; sidx < obj.nDMIs; sidx++) { if(obj.DmiInfo[sidx].ccpParams.useScratchpad==1) {%>
                     <%=sidx%> : 
                        if(sp_ways[<%=sidx%>] > 0) begin
                           m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.sp_enabled     = (addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[<%=sidx%>]) ? 32'h1 : 32'h0;
                           m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.lower_sp_addr  = k_sp_base_addr[<%=sidx%>];
                           m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.sp_ways        = sp_ways[<%=sidx%>];
                           m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.create_SP_q();
            	    end
                    <% } } %>
                  endcase
              end
              <% } %>
           end // if (addr_trans_mgr_pkg::addrMgrConst::dmis_with_cmcsp[i])
        end // for(int i=0; i<addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS; i++) begin  

<% if (found_csr_access_ioaiu > 0) { %>
     legacy_boot_tsk_snps.ioaiu_boot_seq<%=csrAccess_ioaiu%>(agent_ids_assigned_q,wayvec_assigned_q, k_sp_base_addr, sp_ways, sp_size); 
       m_concerto_sw_credit_mgr.m_regs = m_concerto_env.m_regs;    
       `uvm_info(this.get_full_name(),$sformatf("Launch Software_Credit Sequence"),UVM_LOW)
       // sw credit manager set credit 
       `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("using sw credit manager class"), UVM_LOW)
       if($test$plusargs("use_custom_credit")) begin
          m_concerto_sw_credit_mgr.en_credit_alloc = 0; 
          m_concerto_sw_credit_mgr.set_custom_credit();
       end // $test$plusargs("use_custom_credit")
       m_concerto_sw_credit_mgr.boot_sw_crdt();
      `uvm_info(this.get_full_name(),$sformatf("Leaving Software_Credit Sequence"),UVM_LOW)
<% } else { %>
      `uvm_error(this.get_full_name(),$sformatf("ioaiu_boot_seq(ncore reg space configuration) can not be run on IOAIU since all IOAIU has fnCsrAccess==0. Try ncore reg space configuration with APB or CHI."))
<% } %>
    end // if(test_cfg.use_new_csr==0) begin

  `uvm_info("FULLSYS_TEST", "END configure_ncore_register_using_legacy_boot_task", UVM_LOW)
endtask:configure_ncore_register_using_legacy_boot_task

function void concerto_base_test::parse_str(output string out [], input byte separator, input string in);
   int index [$]; // queue of indices (begin, end) of characters between separator

   if((in.tolower() != "none") && (in.tolower() != "null")) begin
      foreach(in[i]) begin // find separator
         if (in[i]==separator) begin
            index.push_back(i-1); // index of byte before separator
            index.push_back(i+1); // index of byte after separator
         end
      end
      index.push_front(0); // begin index of 1st group of characters
      index.push_back(in.len()-1); // last index of last group of characters

      out = new[index.size()/2];

      // grep characters between separator
      foreach (out[i]) begin
         out[i] = in.substr(index[2*i],index[2*i+1]);
      end
   end // if ((in.tolower() != "none") || (in.tolower() != "null"))

endfunction : parse_str


