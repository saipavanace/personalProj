///////////////////////////////////
/// USE IN CASE OF EMULATION SIMULATION 
///////////////////////////////////
<%
let numChiAiu = 0; // Number of CHI AIUs
let numACEAiu = 0; // Number of ACE AIUs
let numIoAiu = 0; // Number of IO AIUs
let numCAiu = 0; // Number of Coherent AIUs
let numNCAiu = 0; // Number of Non-Coherent AIUs
let chiaiu0;  // strRtlNamePrefix of chiaiu0
let aceaiu0;  // strRtlNamePrefix of aceaiu0
let numAiuRpns = 0;   //Total AIU RPN's
let idxIoAiuWithPC = 0; // To get valid index of NCAIU with ProxyCache
let numDmiWithSMC = 0; // Number of DMIs with SystemMemoryCache
let idxDmiWithSMC = 0; // To get valid index of DMI with SystemMemoryCache
let numDmiWithSP = 0; // Number of DMIs with ScratchPad memory
let idxDmiWithSP = 0; // To get valid index of DMIs with ScratchPad memory
let numDmiWithWP = 0; // Number of DMIs with WayPartitioning
let idxDmiWithWP = 0; // To get valid index of DMIs with WayPartitioning
let found_csr_access_chiaiu=0;
let found_csr_access_ioaiu=0;
let csrAccess_ioaiu=0;
let csrAccess_chiaiu=0;
let aiu_rpn = [];
let aiu_NumCores = [];

for(let pidx = 0; pidx < obj.AiuInfo.length; pidx++) { 
  if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
      aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
      aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn[0];
  } else {
      aiu_NumCores[pidx]    = 1;
      aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn;
  }
}

for(let pidx = 0; pidx < obj.nDMIs; pidx++) {
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
for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-B")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) 
       { 
         if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
         if(obj.AiuInfo[pidx].fnCsrAccess == 1) {
           if (found_csr_access_chiaiu == 0) {
            csrAccess_chiaiu = numChiAiu;
            found_csr_access_chiaiu = 1;
           }
         }
          numChiAiu++ ; numCAiu++ ; 
       }
    else
       { 
         if(obj.AiuInfo[pidx].fnCsrAccess == 1) {
            if (found_csr_access_ioaiu == 0) {
	       csrAccess_ioaiu = numIoAiu;
	       found_csr_access_ioaiu = 1;
            }
         }
         numIoAiu++ ; 
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { 
             if(numACEAiu == 0) { aceaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
             numCAiu++; numACEAiu++; 
         } else  {
             if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
                 if (numNCAiu == 0) { ncaiu0  = obj.AiuInfo[pidx].strRtlNamePrefix + "_0"; }
             } else {
                 if (numNCAiu == 0) { ncaiu0  = obj.AiuInfo[pidx].strRtlNamePrefix; }
             }
             numNCAiu++ ;
         }
         if(obj.AiuInfo[pidx].useCache) {
             idxIoAiuWithPC = pidx + 1;
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

// For registers's fields value
function getRegField(register,field) {

    const reg = obj.AiuInfo[obj.Id].csr.spaceBlock[0].registers.find(reg => reg.name == register);
    var reg_field = reg.fields.find(find_field => find_field.name === field);

    return (reg_field);
}

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
                            if(item.fnNativeInterface === "CHI-A" || item.fnNativeInterface === "CHI-B"|| item.fnNativeInterface === "CHI-E") {
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

const Dvm_NUnitIds = [] ;
for (const o of obj.AiuInfo) {
    if(o.cmpInfo.nDvmSnpInFlight > 0) {
        Dvm_NUnitIds.push(o.nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}

let SnoopEn = 0;
   for(let i in Dvm_NUnitIds) {
      SnoopEn |= 1 << Dvm_NUnitIds[i]; 
   }

let chi_bfm_types_pkg_prefix = "";
if(obj.testBench == "fsys") {
    chi_bfm_types_pkg_prefix = "chiaiu0";
} else {
    chi_bfm_types_pkg_prefix = obj.BlockId;
}
%>

import  <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::*;
import  svt_chi_item_helper_pkg::*;
import  chi_ss_helper_pkg::*;

class chi_subsys_vseq extends uvm_sequence;
    `uvm_object_param_utils(chi_subsys_vseq)
    parameter VALID_MAX_CREDIT_VALUE = 31;
    svt_chi_rn_transaction_sequencer rn_xact_seqr;
    svt_chi_rn_snoop_transaction_sequencer rn_snp_xact_seqr;
    svt_chi_protocol_service_sequencer prot_svc_seqr;
    svt_chi_status shared_status;
    uvm_event_pool ev_pool_sysco = uvm_event_pool::get_global_pool();
    uvm_event ev = ev_pool.get("ev");
    uvm_event ev_toggle_sysco_<%=obj.BlockId%> = ev_pool_sysco.get("ev_toggle_sysco_<%=obj.BlockId%>");
    uvm_event val_change_k_decode_err_illegal_acc_format_test_unsupported_size = ev_pool_sysco.get("val_change_k_decode_err_illegal_acc_format_test_unsupported_size");
    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] all_dmi_dii_start_addr[int][$]; 
    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] all_dii_start_addr[int][$]; 
    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] all_dmi_start_addr[int][$]; 
    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] temp_addr; 
    bit k_decode_err_illegal_acc_format_test_unsupported_size;

    svt_chi_protocol_service_coherency_exit_sequence coherency_exit_seq;
    svt_chi_protocol_service_coherency_entry_sequence coherency_entry_seq;
    chi_subsys_pkg::chi_subsys_base_seq random_seq;
    int vip_snps_seq_length = 5;

    string uname;
    //Unit args
    chi_aiu_unit_args m_args;
    string seq_name = "chi_subsys_vseq";
    string done_event_name = "done_snps_chi_aiu_vseq";
    int num_txn_sent=0;
    semaphore s_txdat = new(1);
  
    static bit copyback_seq;
    static bit rd_shared_state_seq;
    static bit rd_exclusive_seq;
    static bit coh_concurrent;
    static bit atomic_cfg_45;
    int chi_num_trans;
    int k_access_boot_region;
    bit k_directed_test;
    bit k_directed_test_alloc;
    int boot_coh_access;

    bit user_qos;
    int user_xact_type;
    int aiu_qos;													   
    svt_chi_common_transaction::xact_type_enum xact_type = svt_chi_common_transaction::READNOSNP;
    bit wait_for_coherency_enable = 1;

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
    bit [<%=numChiAiu%>-1:0]t_chiaiu_en;
    bit [<%=numIoAiu%>-1:0]t_ioaiu_en;
    int numChiAiu=<%=numChiAiu%>;
    int numIoAiu=<%=numIoAiu%>;
    int active_numChiAiu=0;
    int active_numIoAiu=0;
    int csrAccess_ioaiu=0;
    int csrAccess_chiaiu=0;
    bit [31:0]sys_reg_exp_data_val[string][];
    bit [31:0]sys_reg_exp_data_mask[string][];
    //DMIUSMCAPR policy testting
    int dmiusmc_policy = 0;
    int dmiusmc_policy_rand = 0;
    int update_cmd_disable = 0; // should be 0 or 1

    //Delay helper handles
    cnstr_random_delay m_txreq_dly;
    cnstr_random_delay m_txrsp_dly;
    cnstr_random_delay m_txdat_dly;

    static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    static uvm_event ev_seq_done;
    <% if(obj.testBench == "fsys") { %>
    uvm_event ev_sim_done;
    ral_sys_ncore  m_regs;
    <% } %>

    function new(string s = "chi_subsys_vseq");
        super.new(s);

        uname = $psprintf("chi_subsys_vseq");
        m_txreq_dly = new("m_txreq_dly");
        m_txrsp_dly = new("m_txrsp_dly");
        m_txdat_dly = new("m_txdat_dly");

        k_access_boot_region = 0; 
        user_qos = 0;
        user_xact_type = 0;
    endfunction: new
    function void set_unit_args(const ref chi_aiu_unit_args args);
        m_args = args;

        m_txreq_dly.set_divisor(m_args.k_txreq_hld_dly.get_value());
        m_txreq_dly.set_range(m_args.k_txreq_dly_min.get_value(), m_args.k_txreq_dly_max.get_value());
        m_txrsp_dly.set_divisor(m_args.k_txrsp_hld_dly.get_value());
        m_txrsp_dly.set_range(m_args.k_txrsp_dly_min.get_value(), m_args.k_txrsp_dly_max.get_value());
        m_txdat_dly.set_divisor(m_args.k_txdat_hld_dly.get_value());
        m_txdat_dly.set_range(m_args.k_txdat_dly_min.get_value(), m_args.k_txdat_dly_max.get_value());
    endfunction: set_unit_args

        function void set_seq_name(string s);
            seq_name = s;
        endfunction: set_seq_name

        function void set_done_event_name(string s);
            done_event_name = s;
        endfunction: set_done_event_name


        task construct_coherency_exit_snps();
            `uvm_info(get_name(), "Start in_the_seq_svt_chi_coherency_exit_sequence", UVM_NONE)
                coherency_exit_seq = new();
            `uvm_info(get_name(), "Start in_the_seq_svt_chi_coherency_exit_sequence_1", UVM_NONE)
                coherency_exit_seq.randomize();
            `uvm_info(get_name(), "Start in_the_seq_svt_chi_coherency_exit_sequence_2", UVM_NONE)
                coherency_exit_seq.start(prot_svc_seqr);
            `uvm_info(get_name(), "Done in_the_seq_svt_chi_coherency_exit_sequence", UVM_NONE)
        endtask: construct_coherency_exit_snps

        task construct_coherency_entry_snps();
            `uvm_info(get_name(), "Start svt_chi_coherency_entry_sequence", UVM_NONE)
            wait (shared_status.sysco_interface_state == svt_chi_status::COHERENCY_DISABLED_STATE);
            coherency_entry_seq = new();
            coherency_entry_seq.randomize();
            coherency_entry_seq.start(prot_svc_seqr);
            `uvm_info(get_name(), "Done svt_chi_coherency_entry_sequence", UVM_NONE)
            `uvm_info(get_name(), "Done svt_chi_coherency_entry_sequence_1", UVM_NONE)
        endtask: construct_coherency_entry_snps 
    
    task body();

        int txnid;
        uvm_object uvm_obj;
            <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::addr_width_t boot_addr;
        <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::chi_bfm_opcode_type_t  atomic_ops[] = { <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_LD_CMD,  <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_ST_CMD,  <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_SW_CMD,  <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::ATOMIC_CM_CMD};
        
        //newperf test  
        int duty_cycle; // duty_cycle = nbr of cycle of seq of transaction ex: WRRR => duty_cycle=4
        int nbr_write_coh_in_duty_cycle;
        int nbr_write_noncoh_in_duty_cycle;
        realtime delay_chi<%=obj.AiuInfo[obj.Id].nUnitId%>_req;  // add delay between 2 req ex: delay_chi0_req=200ns to allow the measure on the latency		

        if(!$value$plusargs("chi<%=obj.AiuInfo[obj.Id].nUnitId%>_duty_cycle=%d", duty_cycle)) begin
                duty_cycle = 0;
            end
        nbr_write_coh_in_duty_cycle = duty_cycle*m_args.k_wr_cohunq_pct.get_value()/100;
        nbr_write_noncoh_in_duty_cycle = duty_cycle*m_args.k_wr_noncoh_pct.get_value()/100;

        if (!$value$plusargs("boot_coh_access=%d",boot_coh_access)) begin
            boot_coh_access = 0;
        end

        `uvm_info("CHIAIU<%=obj.AiuInfo[obj.Id].nUnitId%> SEQ", $sformatf("Creating ev_seq_done with name %s", done_event_name), UVM_NONE)
        ev_seq_done = ev_pool.get(done_event_name);
        <% if(obj.testBench == "fsys") { %>
        ev_sim_done = ev_pool.get("sim_done");
        <% } %>
        
        `uvm_info(uname, "Start CHI AIU VSEQ", UVM_MEDIUM)

            // no need to call them here for full system
            // These tasks are called in concerto test body for full system
            // no need to call them here for full system
        //Initiate link and txs sequence
        `uvm_info(uname, "construct Link seq", UVM_MEDIUM)
        <% if(obj.testBench == "fsys") { %>
        if(wait_for_coherency_enable) begin
            wait (shared_status.sysco_interface_state == svt_chi_status::COHERENCY_ENABLED_STATE);
        end
        <% } %>

        `uvm_info(uname, "Start CHI AIU TRAFFIC", UVM_MEDIUM)
            //Pop CHI request channel flit from the chi_container 
            //and forward them to Seqr
            begin:t2_th
                
                uvm_event txns_constructed;
                
                txns_constructed = new("txns_constructed"); 

                `uvm_info(get_name(), 
                $psprintf("ntxns: %0d", m_args.k_num_requests.get_value()),
                UVM_MEDIUM)

                fork
                    begin
                        `uvm_info(get_name(),$psprintf("Starting CHI subsys random sequence"),UVM_NONE)
                        chi_num_trans = m_args.k_num_requests.get_value();
                        
                        random_seq = chi_subsys_pkg::chi_subsys_base_seq::type_id::create("random_seq");
                        random_seq.sequence_length = chi_num_trans;
                        random_seq.m_args = m_args;
                        random_seq.start(rn_xact_seqr);
                        txns_constructed.trigger(null);
            
                        `uvm_info(get_name(),$psprintf("Ending CHI subsys random sequence"),UVM_NONE)
                    end // fork branch
                                                            
                    begin: t2_inner_t2_th
                        txns_constructed.wait_ptrigger();
                        ev_seq_done.trigger(null);
                    end: t2_inner_t2_th

                // wait for top level test to signal all sequences done
                //     <% if(obj.testBench == "fsys") { %>
                // begin: wait_sim_done
                //     ev_sim_done.wait_trigger();
                // `uvm_info("CHIAIU<%obj.AiuInfo[obj.Id].nUnitId%> SEQ", "Received simulation done", UVM_NONE)
                //     end: wait_sim_done
                //     <% } %>
            
                join
            end  : t2_th
        
        `uvm_info(uname, "Stop CHI AIU VSEQ", UVM_MEDIUM)

    endtask: body


<%  if(obj.testBench!="chi_aiu") { %>
task write_memory(input   <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::addr_width_t addr, input bit[511:0] data,input int size);
int wr_data_cancel = m_args.k_writedatacancel_pct.get_value();
    int addr_mask;
    int addr_offset;			

    // FIXME - need to look at wSmiDPdata for data width
    //addr_mask = wSmiDPdata/8 - 1;				   
    //addr_offset = addr & addr_mask
    begin

    chi_subsys_pkg::chi_subsys_directed_seq svt_seq;
    svt_seq = chi_subsys_pkg::chi_subsys_directed_seq::type_id::create("svt_seq");
    `uvm_info(get_name(),$psprintf("Starting write_memory, addr 0x%16h data 0x%8h",addr,data),UVM_NONE)
    //write_key.get();
    svt_seq.sequence_length = 1;
    svt_seq.directed_addr_mailbox.put(addr);
    svt_seq.directed_data_mailbox.put(data);
    svt_seq.randomize_with_directed_data = 1;
    svt_seq.use_directed_addr = 1;
    svt_seq.use_directed_snp_attr = 0;
    svt_seq.use_directed_mem_attr = 0;
    svt_seq.use_directed_non_secure_access = 1;
    svt_seq.directed_is_non_secure_access_mailbox.put(0);
    svt_seq.use_directed_allocate_in_cache = 0;
    svt_seq.use_directed_data_size = 0;
    //svt_seq.use_directed_byte_enable = 0;
    svt_seq.size=size;
    svt_seq.write_coh=0;
    svt_seq.readnosnp_wt = 0;
    svt_seq.writenosnpfull_wt = 0;
    svt_seq.writenosnpptl_wt = 1;
    svt_seq.blocking_mode = 1;
    svt_seq.start(rn_xact_seqr) ;
    //write_key.put();
    end
endtask : write_memory

task write_memory_coh(input   <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::addr_width_t addr, input bit[511:0] data,input int size);
int wr_data_cancel = m_args.k_writedatacancel_pct.get_value();
    int addr_mask;
    int addr_offset;			

    // FIXME - need to look at wSmiDPdata for data width
    //addr_mask = wSmiDPdata/8 - 1;				   
    //addr_offset = addr & addr_mask

    svt_chi_rn_coherent_transaction_base_sequence svt_seq;
    svt_seq = svt_chi_rn_coherent_transaction_base_sequence::type_id::create("svt_seq");

    `uvm_info(get_name(),$psprintf("Starting write_memory_coh, addr 0x%16h data 0x%8h",addr,data),UVM_NONE)
    svt_seq.direct_addr_timeout=100000;
    svt_seq.sequence_length = 1;
    svt_seq.use_directed_addr = 1;
    svt_seq.directed_addr_mailbox.put(addr);
    svt_seq.use_directed_data = 1;
    svt_seq.directed_data_mailbox.put(data);
    svt_seq.use_directed_snp_attr = 0;
    svt_seq.use_directed_mem_attr = 0;
    svt_seq.use_directed_non_secure_access = 1;
    svt_seq.directed_is_non_secure_access_mailbox.put(0);
    svt_seq.use_directed_allocate_in_cache = 0;
    svt_seq.use_directed_data_size = 0;
    svt_seq.use_directed_byte_enable = 0;
    //svt_seq.size=size;
    //svt_seq.write_coh=1;
    svt_seq.readnosnp_wt = 0;
    svt_seq.writenosnpfull_wt = 0;
    svt_seq.writenosnpptl_wt = 0;
    svt_seq.writeuniqueptl_wt=1;
    svt_seq.writeuniquefull_wt=1;
    svt_seq.blocking_mode = 1;
    svt_seq.start(rn_xact_seqr) ;
    `uvm_info(get_name(),$psprintf("Starting write_memory_coh, addr 0x%16h data 0x%8h",addr,data),UVM_NONE)
endtask : write_memory_coh

task read_memory(input   <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::addr_width_t addr, output bit[511:0] data, input int size, input int width);
begin
    chi_subsys_pkg::chi_subsys_read_directed_seq svt_seq;
    svt_seq = chi_subsys_pkg::chi_subsys_read_directed_seq::type_id::create("svt_seq");
    `uvm_info(get_name(),$psprintf("Starting read_memory, addr 0x%16h",addr),UVM_NONE)
    //read_key.get();
    svt_seq.sequence_length = 1;
    svt_seq.enable_outstanding = 0;
    //svt_seq.seq_xact_type = svt_chi_transaction::READNOSNP;
    svt_seq.rd_coh=0;
    svt_seq.size=size;
    svt_seq.min_addr = addr;
    svt_seq.max_addr = addr;
    svt_seq.hn_addr_rand_type = svt_chi_rn_transaction_base_sequence::DIRECTED_ADDR_RANGE_RAND_TYPE;
    svt_seq.by_pass_read_data_check = 1;
    svt_seq.use_seq_is_non_secure_access = 1;
    svt_seq.seq_is_non_secure_access = 0;
    svt_seq.start(rn_xact_seqr) ;
    data = svt_seq.read_tran.data;
    //read_key.put();
    end

endtask : read_memory

task read_memory_coh(input   <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::addr_width_t addr, output bit[511:0] data, input int size, input int width);
    chi_subsys_pkg::chi_subsys_read_directed_seq svt_seq;
    svt_seq = chi_subsys_pkg::chi_subsys_read_directed_seq::type_id::create("svt_seq");
    `uvm_info(get_name(),$psprintf("Starting read_memory_coh, addr 0x%16h",addr),UVM_NONE)
    svt_seq.sequence_length = 1;
    svt_seq.enable_outstanding = 0;
    //svt_seq.seq_xact_type = svt_chi_transaction::READNOSNP;
    svt_seq.rd_coh=1;
    svt_seq.size=size;
    svt_seq.min_addr = addr;
    svt_seq.max_addr = addr;
    svt_seq.hn_addr_rand_type = svt_chi_rn_transaction_base_sequence::DIRECTED_ADDR_RANGE_RAND_TYPE;
    svt_seq.by_pass_read_data_check = 1;
    svt_seq.use_seq_is_non_secure_access = 1;
    svt_seq.seq_is_non_secure_access = 0;
    svt_seq.start(rn_xact_seqr) ;
    data = svt_seq.read_tran.data;

endtask : read_memory_coh

task chi_trace_capture_program(input bit[31:0] trace_capture_queue[$]);
    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::addr_width_t addr;
    bit [31:0] write_data;
    bit [7:0] rpn;
    bit [7:0] aiu_rpn;
    bit [7:0] dce_rpn;
    bit [7:0] dmi_rpn;
    bit [7:0] dii_rpn;

    int queue_idx = 0;

    svt_chi_item_helper::dis_addr_range_constraint = 1;
    // set csrBaseAddr
    addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE;
    aiu_rpn = 0;
    dce_rpn = aiu_rpn + <%=obj.nAIUs%>;
    dmi_rpn = dce_rpn + <%=obj.nDCEs%>;
    dii_rpn = dmi_rpn + <%=obj.nDMIs%>;
   
         // program CCTRLR for AIUs					   
        addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUCCTRLR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUCCTRLR.get_offset()<%}%>;
        write_data = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUCCTRLR.get_reset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUCCTRLR.get_reset()<%}%>;
    
    <% for(let unit = 0; unit < obj.nAIUs; unit++) { %>
        write_data[7:0] = trace_capture_queue[queue_idx];
        if(write_data[7:0] > 0) begin
           addr[19:12] = aiu_rpn + <%=unit%>;
           `uvm_info("chi_trace_capture_program", $sformatf("Writing AIU<%=unit%>.XAIUCCTRLR = 0x%0h", write_data), UVM_MEDIUM)
           write_csr(addr, write_data);
        end
        queue_idx++;
    <% } %>   
    
    <% if(obj.nDMIs > 0) { %>
        // program CCTRLR for DMIs					   
        addr[11:0] = m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.DMICCTRLR.get_offset();
        write_data = m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.DMICCTRLR.get_reset() & 32'hFFFF_FF00;
    
    <% for(let unit = 0; unit < obj.nDMIs; unit++) { %>
        write_data[7:0] = trace_capture_queue[queue_idx];
        if(write_data[7:0] > 0) begin
           addr[19:12] = dmi_rpn + <%=unit%>;
           `uvm_info("chi_trace_capture_en", $sformatf("Writing DMI<%=unit%>.DMICCTRLR = 0x%0h", write_data), UVM_MEDIUM)
           write_csr(addr, write_data);
        end
        queue_idx++;
    <% } } %>   
    
    <% if(obj.nDIIs > 1) { %>
        // program CCTRLR for DIIs					   
        addr[11:0] = m_regs.<%=obj.DiiInfo[0].strRtlNamePrefix%>.DIICCTRLR.get_offset();
        write_data = m_regs.<%=obj.DiiInfo[0].strRtlNamePrefix%>.DIICCTRLR.get_reset() & 32'hFFFF_FF00;
    
    <% for(let unit = 0; unit < obj.nDIIs; unit++) { %>
        write_data[7:0] = trace_capture_queue[queue_idx];
        if(write_data[7:0] > 0) begin
           addr[19:12] = dii_rpn + <%=unit%>;
           `uvm_info("chi_trace_capture_en", $sformatf("Writing DII<%=unit%>.DIICCTRLR = 0x%0h", write_data), UVM_MEDIUM)
           write_csr(addr, write_data);
        end
        queue_idx++;
    <% } } %> 
    svt_chi_item_helper::dis_addr_range_constraint = 0;
endtask : chi_trace_capture_program

task enum_boot_seq(bit [31:0] agent_ids_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$], bit [31:0] wayvec_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$], bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[], int sp_ways[], int sp_size[], int aiu_qos_threshold[int], int dce_qos_threshold[int], int dmi_qos_threshold[int]
);

    // For CHI CSR Seq
    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::addr_width_t addr;
    bit [31:0] data;
    bit [31:0] infor;
    // For Initiator CHI
    bit [7:0] chi_rpn; // Assuming expected value to be 0
    bit [3:0] chi_nrri; // Assuming expected value to be 0
    // System Census 
    bit [7:0] nAIUs; // Max 128
    bit [5:0] nDCEs; // Max 32
    bit [5:0] nDMIs; // Max 32
    bit [5:0] nDIIs; // Max 32 or nDIIs
    bit       nDVEs; // Max 1
    // For interleaving
    bit [4:1] AMIGS;
    // Addr_Mgr
    ncoreConfigInfo::sys_addr_csr_t csrq[$];
    bit [7:0] rpn;
    bit [7:0] cur_rpn;
    bit k_csr_access_only;
    int qos_threshold;
    bit [<%=obj.wSysAddr-1%>:0] ScPadBaseAddr;
    bit ScPadEn;
    bit [31:0] transorder_mode;
    bit sys_event_disable;
    string temp_string="";
    bit t_boot_from_ioaiu=0;
    int chiaiu_timeout_val;
    int ioaiu_timeout_val;
    int this_chiaiu_intf=<%=obj.Id%>;
    int find_this_chiaiu_intf=0;
    bit AIUUEDR_DecErrDetEn;
   
    if (!$value$plusargs("chiaiu_timeout_val=%d",chiaiu_timeout_val)) begin
        chiaiu_timeout_val= 2000;
    end

    if (!$value$plusargs("k_decode_err_illegal_acc_format_test_unsupported_size=%d",k_decode_err_illegal_acc_format_test_unsupported_size)) begin
        k_decode_err_illegal_acc_format_test_unsupported_size = 0;
    end
    act_cmd_skid_buf_size["DCE"] = new[1];
    act_cmd_skid_buf_size["DCE"][0] = 0; //Default value First index zero. If nDCE>1, It will be equal to DCE0 skidbufsize and then skidbufsize of rest of DCEs will be filled in rest of elements
    act_cmd_skid_buf_arb["DCE"] = new[1];
    act_cmd_skid_buf_arb["DCE"][0] = 0; //Default value First index zero. If nDCE>1, It will be equal to DCE0 skidbufarb and then skidbufarb of rest of DCEs will be filled in rest of elements
    act_cmd_skid_buf_size["DMI"] = new[1];
    act_cmd_skid_buf_size["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufsize and then skidbufsize of rest of DMIs will be filled in rest of elements
    act_cmd_skid_buf_arb["DMI"] = new[1];
    act_cmd_skid_buf_arb["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufarb and then skidbufsize of rest of DMIs will be filled in rest of elements
    act_mrd_skid_buf_size["DMI"] = new[1];
    act_mrd_skid_buf_size["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufsize and then skidbufsize of rest of DMIs will be filled in rest of elements
    act_mrd_skid_buf_arb["DMI"] = new[1];
    act_mrd_skid_buf_arb["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufarb and then skidbufarb of rest of DMIs will be filled in rest of elements
    act_cmd_skid_buf_size["DII"] = new[1];
    act_cmd_skid_buf_size["DII"][0] = 0; //Default value First index zero. If nDII>1, It will be equal to DII0 skidbufsize and then skidbufsize of rest of DIIs will be filled in rest of elements
    act_cmd_skid_buf_arb["DII"] = new[1];
    act_cmd_skid_buf_arb["DII"][0] = 0; //Default value First index zero. If nDII>1, It will be equal to DII0 skidbufarb and then skidbufarb of rest of DIIs will be filled in rest of elements

    exp_cmd_skid_buf_size["DCE"] = new[1];
    exp_cmd_skid_buf_size["DCE"][0] = 0; //Default value First index zero. If nDCE>1, It will be equal to DCE0 skidbufsize and then skidbufsize of rest of DCEs will be filled in rest of elements
    exp_cmd_skid_buf_arb["DCE"] = new[1];
    exp_cmd_skid_buf_arb["DCE"][0] = 0; //Default value First index zero. If nDCE>1, It will be equal to DCE0 skidbufarb and then skidbufarb of rest of DCEs will be filled in rest of elements
    exp_cmd_skid_buf_size["DMI"] = new[1];
    exp_cmd_skid_buf_size["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufsize and then skidbufsize of rest of DMIs will be filled in rest of elements
    exp_cmd_skid_buf_arb["DMI"] = new[1];
    exp_cmd_skid_buf_arb["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufarb and then skidbufsize of rest of DMIs will be filled in rest of elements
    exp_mrd_skid_buf_size["DMI"] = new[1];
    exp_mrd_skid_buf_size["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufsize and then skidbufsize of rest of DMIs will be filled in rest of elements
    exp_mrd_skid_buf_arb["DMI"] = new[1];
    exp_mrd_skid_buf_arb["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufarb and then skidbufarb of rest of DMIs will be filled in rest of elements
    exp_cmd_skid_buf_size["DII"] = new[1];
    exp_cmd_skid_buf_size["DII"][0] = 0; //Default value First index zero. If nDII>1, It will be equal to DII0 skidbufsize and then skidbufsize of rest of DIIs will be filled in rest of elements
    exp_cmd_skid_buf_arb["DII"] = new[1];
    exp_cmd_skid_buf_arb["DII"][0] = 0; //Default value First index zero. If nDII>1, It will be equal to DII0 skidbufarb and then skidbufarb of rest of DIIs will be filled in rest of elements
    
    

    if(!$value$plusargs("dmiusmc_policy=%d",dmiusmc_policy))begin
       dmiusmc_policy = 0;
    end

    if(!$value$plusargs("update_cmd_disable=%d",update_cmd_disable))begin
       update_cmd_disable = 0;
    end
    if(!$value$plusargs("k_csr_access_only=%d",k_csr_access_only))begin
       k_csr_access_only = 0;
    end
		
    if(!$value$plusargs("sys_event_disable=%d", sys_event_disable)) begin
        sys_event_disable = 0;
    end

    // setting csrBaseAddress
    svt_chi_item_helper::dis_addr_range_constraint = 1;

    addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE ;

    // #Check.FSYS.csr.NSRbaseAddr
    if(ncore_config_pkg::ncoreConfigInfo::program_nrs_base) begin
      `uvm_info("CHIAIU_ENUM_BOOT_SEQ",$psprintf("Running test concerto_nrs_reg_test ..."),UVM_LOW)
      for(int i=0; i<<%=numAiuRpns%>; i++) begin
        if(find_this_chiaiu_intf==this_chiaiu_intf) begin
            //addr = ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i];
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ",$psprintf("Assigning NRSBASE to %h",ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i]),UVM_LOW)
            addr[19:12]=i;// Register Page Number
            addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.NRSBAR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUNRSBAR.get_offset()<%}%>;
            read_csr(addr,data);
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ",$sformatf("Reading NRSBAR ADDR 0x%0h DATA 0x%0h", addr, data),UVM_LOW)
            if(ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE[51:20]==data)
              `uvm_info("CHIAIU_ENUM_BOOT_SEQ",$sformatf("Checking NRSBAR ADDR 0x%0h EXP-DATA 0x%0h ACT-DATA 0x%0h", addr, ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE[51:20], data),UVM_LOW)
            else
              `uvm_error("CHIAIU_ENUM_BOOT_SEQ",$sformatf("Checking NRSBAR ADDR 0x%0h EXP-DATA 0x%0h ACT-DATA 0x%0h. Found Mismatch!",  addr, ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE[51:20], data))

            addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.NRSBHR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUNRSBHR.get_offset()<%}%>;
            data = ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i][51:20]; 
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ",$sformatf("Writing NRSBHR ADDR 0x%0h DATA 0x%0h",  addr, data),UVM_LOW)
            write_csr(addr,data);

            do begin
                addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.NRSBLR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUNRSBLR.get_offset()<%}%>;
                read_csr(addr,data);
                `uvm_info("CHIAIU_ENUM_BOOT_SEQ",$sformatf("Reading NRSBLR ADDR 0x%0h DATA 0x%0h",  addr, data),UVM_LOW)
            end
            while(data[31]==0);
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ",$sformatf("NRSBLR.BALoaded is set"),UVM_LOW)
            #10ns;
            addr = ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i];
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ",$sformatf("Changing NRS_REGION_BASE from 0x%h to 0x%h",ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE,ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i]),UVM_LOW)
            ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE = ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i];
        end // if(find_this_chiaiu_intf==this_chiaiu_intf) begin
        if(ncore_config_pkg::ncoreConfigInfo::get_native_interface(i) inside {ncore_config_pkg::ncoreConfigInfo::CHI_A_AIU,ncore_config_pkg::ncoreConfigInfo::CHI_B_AIU}) begin
          find_this_chiaiu_intf = find_this_chiaiu_intf + 1;
          `uvm_info("CHIAIU_ENUM_BOOT_SEQ",$psprintf("RPN %0d is tied to %0s %0d %0d",i,ncore_config_pkg::ncoreConfigInfo::get_native_interface(i).name(),find_this_chiaiu_intf,this_chiaiu_intf),UVM_LOW)
        end
      end // for(int i=0; i<<%=numAiuRpns%>; i++) begin
    end // if(ncore_config_pkg::ncoreConfigInfo::program_nrs_base) begin

    if(k_csr_access_only==1 && k_decode_err_illegal_acc_format_test_unsupported_size) begin
    rpn = 0; //chi_rpn;
        k_decode_err_illegal_acc_format_test_unsupported_size = 0;
        for(int i=0; i<<%=numAiuRpns%>; i++) begin
            data = 0;
            addr[19:12]=rpn;// Register Page Number
            addr[11:0] = m_regs.<%=chiaiu0%>.CAIUUEDR.get_offset(); // 12'h<%=getIoOffset("CAIUUEDR")%>;
            AIUUEDR_DecErrDetEn = 0;
            write_chk(addr,data,k_csr_access_only);
            rpn++;
        end
        k_decode_err_illegal_acc_format_test_unsupported_size = 1;
    end

    // TODO: Assuming(1) the Reset value of NRSBAR = 0x0 and (2)this Boot_seq will work on 1st Chi-BFM
    // (1) Read USIDR 
    rpn = 8'hFF; // sys global rpn;
    addr[19:12] = rpn;
    addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUIDR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUIDR.get_offset()<%}%>;
    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Reading USIDR (0x%0h)", addr), UVM_LOW)
    if (k_decode_err_illegal_acc_format_test_unsupported_size) begin
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Checking illegal_acc_format_test_unsupported_size for read access"), UVM_NONE)
        read_csr(addr,data);
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Done Checking illegal_acc_format_test_unsupported_size for read access"), UVM_NONE)
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Continue regular flow of csr sequence, read access should not return DECERR response. Setting k_decode_err_illegal_acc_format_test_unsupported_size to 0"), UVM_NONE)
        k_decode_err_illegal_acc_format_test_unsupported_size = 0;
        val_change_k_decode_err_illegal_acc_format_test_unsupported_size.trigger(null);
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Triggering uvm_event val_change_k_decode_err_illegal_acc_format_test_unsupported_size"), UVM_MEDIUM)
         addr[19:12]=<%=aiu_rpn[obj.Id]%>;// Register Page Number
         addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUUESR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUUESR.get_offset()<%}%>;
        read_csr(addr,data);
        if(data[0]==0) begin
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0(=No Error is logged). That is expected"), UVM_MEDIUM)
        end else begin
            if(AIUUEDR_DecErrDetEn==0) begin
                `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 1. That is not expected(=No Error is logged)"))
            end else begin
                data[0]=1;
                `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing AIUUESR.ErrVld to clear the error"), UVM_MEDIUM)
                write_csr(addr,data);
                read_csr(addr,data);
                if(data[0]==0)
                    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0, meaning Error is cleared. That is expected"), UVM_MEDIUM)
                else
                    `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 1, meaning Error is not cleared. Expected value=0x0",data[0]))

            end
        end
             
    end
    rpn = 8'hFF; // sys global rpn;
    addr[19:12] = rpn;
    addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUIDR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUIDR.get_offset()<%}%>;
    read_csr(addr,data);
    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("USIDR (0x%0h) = 0x%0h", addr, data), UVM_LOW)
    if(data[31]) begin // valid
        chi_rpn  = data[ 7:0];
        chi_nrri = data[11:8];
	`uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("USIDR.RPN=%0d, USIDR.NRRI=%0d", chi_rpn, chi_nrri), UVM_LOW)
    end else begin
        `uvm_error("CHIAIU_ENUM_BOOT_SEQ","Valid bit not asserted in USIDR register of Initiating CHI-AIU")
    end

    // (2) Read NRRUCR
    addr[11:0] = m_regs.sys_global_register_blk.GRBUNRRUCR.get_offset();
    data = 0;
    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Reading NRRUCR (0x%0h)", addr), UVM_LOW)
    read_csr(addr,data);
    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("NRRUCR (0x%0h) = 0x%0h", addr, data), UVM_LOW)
    if(!($test$plusargs("chi_csr_ns_access"))) begin
      if(data == 0) begin
          `uvm_error("CHIAIU_ENUM_BOOT_SEQ","NRRUCR register is 0")
      end
    end
    nAIUs = data[ 7: 0];
    nDCEs = data[13: 8];
    nDMIs = data[19:14];
    nDIIs = data[25:20];
    nDVEs = data[26:26];
    `uvm_info("CHIAIU_ENUM_BOOT_SEQ",$sformatf("nAIUs:%0d nDCEs:%0d nDMIs:%0d nDIIs:%0d nDVEs:%0d",nAIUs,nDCEs,nDMIs,nDIIs,nDVEs),UVM_NONE)

    if(k_csr_access_only==1) begin
        // #Check.FSYS.csr.Check.pre-v3.4.GRBUCSSFIDR
        sys_reg_exp_data_val["GRBUCSSFIDR"]  = new[<%=obj.SnoopFilterInfo.length%>];
        sys_reg_exp_data_mask["GRBUCSSFIDR"] = new[<%=obj.SnoopFilterInfo.length%>];
        <%for(let tempidx = 0; tempidx < obj.SnoopFilterInfo.length; tempidx++) {%>
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>][19:0]  = <%=obj.SnoopFilterInfo[tempidx].nSets%> -1;
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>][25:20] = <%=obj.SnoopFilterInfo[tempidx].nWays%> -1;
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>][28:26] = <%=(obj.SnoopFilterInfo[tempidx].nVictimEntries>0) ? 7 : 3%>;
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>][31:29] = 0;

            sys_reg_exp_data_mask["GRBUCSSFIDR"][<%=tempidx%>][31:0] = 32'hFFFF_FFFF;
            sys_reg_exp_data_mask["GRBUCSSFIDR"][<%=tempidx%>][28:26] = 3'h0;
            addr[11:0] = m_regs.sys_global_register_blk.GRBUCSSFIDR<%=tempidx%>.get_offset() /*+ (<%=tempidx%> * 4)*/;
            data = 0;
            read_csr(addr,data);
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Reading GRBUCSSFIDR<%=tempidx%>(0x%0h)= 0x%0h",addr,data), UVM_NONE)
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>] = sys_reg_exp_data_mask["GRBUCSSFIDR"][<%=tempidx%>] & sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>];
            data = sys_reg_exp_data_mask["GRBUCSSFIDR"][<%=tempidx%>] & data; 
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("GRBUCSSFIDR<%=tempidx%>(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>]), UVM_NONE)
            if(!($test$plusargs("chi_csr_ns_access"))) begin
              if(data != sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>]) begin
                `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("GRBUCSSFIDR<%=tempidx%>(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>]))
              end
            end
        <%}%>

        // #Check.FSYS.csr.Check.pre-v3.4.GRBUNRRIR
        sys_reg_exp_data_val["GRBUNRRIR"]  = new[1];
        sys_reg_exp_data_mask["GRBUNRRIR"] = new[1];
        sys_reg_exp_data_val["GRBUNRRIR"][0][3:0]   = 0;
        sys_reg_exp_data_val["GRBUNRRIR"][0][15:4]  = 0;
        sys_reg_exp_data_val["GRBUNRRIR"][0][19:16] = 0;
        sys_reg_exp_data_val["GRBUNRRIR"][0][31:20] = 0;

        sys_reg_exp_data_mask["GRBUNRRIR"][0][31:0] = 32'hFFFF_FFFF;

        addr[11:0] = m_regs.sys_global_register_blk.GRBUNRRIR.get_offset();
        data = 0;
        read_csr(addr,data);
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Reading GRBUNRRIR(0x%0h)= 0x%0h",addr,data), UVM_NONE)
        sys_reg_exp_data_val["GRBUNRRIR"][0] = sys_reg_exp_data_mask["GRBUNRRIR"][0] & sys_reg_exp_data_val["GRBUNRRIR"][0];
        data = sys_reg_exp_data_mask["GRBUNRRIR"][0] & data; 
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("GRBUNRRIR(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNRRIR"][0]), UVM_NONE)
        if(!($test$plusargs("chi_csr_ns_access"))) begin
          if(data != sys_reg_exp_data_val["GRBUNRRIR"][0]) begin
            `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("GRBUNRRIR(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNRRIR"][0]))
          end
        end

        // #Check.FSYS.csr.Check.pre-v3.4.GRBUENGIDR
        sys_reg_exp_data_val["GRBUENGIDR"]  = new[1];
        sys_reg_exp_data_mask["GRBUENGIDR"] = new[1];
        sys_reg_exp_data_val["GRBUENGIDR"][0][31:0] = <%=obj.AiuInfo[0].engVerId%>;

        sys_reg_exp_data_mask["GRBUENGIDR"][0][31:0] = 32'hFFFF_FFFF;

        addr[11:0] = m_regs.sys_global_register_blk.GRBUENGIDR.get_offset();
        data = 0;
        read_csr(addr,data);
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Reading GRBUENGIDR(0x%0h)= 0x%0h",addr,data), UVM_NONE)
        sys_reg_exp_data_val["GRBUENGIDR"][0] = sys_reg_exp_data_mask["GRBUENGIDR"][0] & sys_reg_exp_data_val["GRBUENGIDR"][0];
        data = sys_reg_exp_data_mask["GRBUENGIDR"][0] & data; 
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("GRBUENGIDR(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUENGIDR"][0]), UVM_NONE)
        if(!($test$plusargs("chi_csr_ns_access"))) begin
          if(data != sys_reg_exp_data_val["GRBUENGIDR"][0]) begin
            `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("GRBUENGIDR(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUENGIDR"][0]))
          end
        end

        // #Check.FSYS.csr.Check.pre-v3.4.GRBUNRRUCR
        sys_reg_exp_data_val["GRBUNRRUCR"]  = new[1];
        sys_reg_exp_data_mask["GRBUNRRUCR"] = new[1];
        sys_reg_exp_data_val["GRBUNRRUCR"][0][7:0]  =<%=obj.AiuInfo.length%>;
        sys_reg_exp_data_val["GRBUNRRUCR"][0][13:8] =<%=obj.DceInfo.length%>;
        sys_reg_exp_data_val["GRBUNRRUCR"][0][19:14]=<%=obj.DmiInfo.length%>;
        sys_reg_exp_data_val["GRBUNRRUCR"][0][25:20]=<%=obj.DiiInfo.length%>;
        sys_reg_exp_data_val["GRBUNRRUCR"][0][31:26]=<%=obj.DveInfo.length%>;

        sys_reg_exp_data_mask["GRBUNRRUCR"][0][31:0] = 32'hFFFF_FFFF;

        addr[11:0] = m_regs.sys_global_register_blk.GRBUNRRUCR.get_offset();
        data = 0;
        read_csr(addr,data);
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Reading GRBUNRRUCR(0x%0h)= 0x%0h",addr,data), UVM_NONE)
        sys_reg_exp_data_val["GRBUNRRUCR"][0] = sys_reg_exp_data_mask["GRBUNRRUCR"][0] & sys_reg_exp_data_val["GRBUNRRUCR"][0];
        data = sys_reg_exp_data_mask["GRBUNRRUCR"][0] & data; 
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("GRBUNRRUCR(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNRRUCR"][0]), UVM_NONE)
        if(!($test$plusargs("chi_csr_ns_access"))) begin
          if(data != sys_reg_exp_data_val["GRBUNRRUCR"][0]) begin
            `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("GRBUNRRUCR(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNRRUCR"][0]))
          end
        end
        // #Check.FSYS.csr.Check.pre-v3.4.GRBUNSIDR
        sys_reg_exp_data_val["GRBUNSIDR"]  = new[1];
        sys_reg_exp_data_mask["GRBUNSIDR"] = new[1];
        sys_reg_exp_data_val["GRBUNSIDR"][0][15:0]  = <%=obj.AiuInfo[0].implVerId%> ; //12'h340;
        sys_reg_exp_data_val["GRBUNSIDR"][0][19:16] = <%=obj.DceInfo[0].wCacheLineOffset%> - 5;
        sys_reg_exp_data_val["GRBUNSIDR"][0][27:20] = <%=obj.SnoopFilterInfo.length%> - 1;

        sys_reg_exp_data_mask["GRBUNSIDR"][0][31:0] = 32'hFFFF_FFFF;

        addr[11:0] = m_regs.sys_global_register_blk.GRBUNSIDR.get_offset();
        data = 0;
        read_csr(addr,data);
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Reading GRBUNSIDR(0x%0h)= 0x%0h",addr,data), UVM_NONE)
        sys_reg_exp_data_val["GRBUNSIDR"][0] = sys_reg_exp_data_mask["GRBUNSIDR"][0] & sys_reg_exp_data_val["GRBUNSIDR"][0];
        data = sys_reg_exp_data_mask["GRBUNSIDR"][0] & data; 
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("GRBUNSIDR(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNSIDR"][0]), UVM_NONE)
        if(!($test$plusargs("chi_csr_ns_access"))) begin
          if(data != sys_reg_exp_data_val["GRBUNSIDR"][0]) begin
            `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("GRBUNSIDR(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNSIDR"][0]))
          end
        end
    end

    if(nDCEs>0) begin
      act_cmd_skid_buf_size["DCE"] = new[nDCEs];
      act_cmd_skid_buf_arb["DCE"] = new[nDCEs];
      exp_cmd_skid_buf_size["DCE"] = new[nDCEs];
      exp_cmd_skid_buf_arb["DCE"] = new[nDCEs];
    end

    if(nDMIs>0) begin
      act_cmd_skid_buf_size["DMI"] = new[nDMIs];
      act_mrd_skid_buf_size["DMI"] = new[nDMIs];
      act_cmd_skid_buf_arb["DMI"] = new[nDMIs];
      act_mrd_skid_buf_arb["DMI"] = new[nDMIs];
      exp_cmd_skid_buf_size["DMI"] = new[nDMIs];
      exp_mrd_skid_buf_size["DMI"] = new[nDMIs];
      exp_cmd_skid_buf_arb["DMI"] = new[nDMIs];
      exp_mrd_skid_buf_arb["DMI"] = new[nDMIs];
    end

    if(nDIIs>0) begin
      act_cmd_skid_buf_size["DII"] = new[nDIIs];
      act_cmd_skid_buf_arb["DII"] = new[nDIIs];
      exp_cmd_skid_buf_size["DII"] = new[nDIIs];
      exp_cmd_skid_buf_arb["DII"] = new[nDIIs];
    end

<%for(let tempidx = 0; tempidx < obj.nDCEs; tempidx++) {%>
      exp_cmd_skid_buf_size["DCE"][<%=tempidx%>] = <%=obj.DceInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DCE"][<%=tempidx%>] = <%=obj.DceInfo[tempidx].nCMDSkidBufArb%>;
<%}%>

<%for(let tempidx = 0; tempidx < obj.nDMIs; tempidx++) {%>
      exp_cmd_skid_buf_size["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nCMDSkidBufArb%>;
      exp_mrd_skid_buf_size["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nMrdSkidBufSize%>;
      exp_mrd_skid_buf_arb["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nMrdSkidBufArb%>;
<%}%>

<%for(let tempidx = 0; tempidx < obj.nDIIs; tempidx++) {%>
      exp_cmd_skid_buf_size["DII"][<%=tempidx%>] = <%=obj.DiiInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DII"][<%=tempidx%>] = <%=obj.DiiInfo[tempidx].nCMDSkidBufArb%>;
<%}%>
    // (3) Configure all the General Purpose registers
    csrq = ncoreConfigInfo::get_all_gpra();
    rpn = 0; //chi_rpn;
    cur_rpn = rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number
        if(ncoreConfigInfo::picked_dmi_igs > 0) begin
           addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUAMIGR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUAMIGR.get_offset()<%}%>;
           data[0] = 1;
           data[4:1] = ncoreConfigInfo::picked_dmi_igs;
           data[31:5] = 0;
           write_chk(addr,data,k_csr_access_only);
	end
        foreach (csrq[ig]) begin

           //GPRBLR : 12'b01XX XXXX 0100 ; addr[11:0] = {2'b01,ig[5:0],4'h4};
           addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUGPRBLR0.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUGPRBLR0.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUGPRBLR0")%>;=12'h<%=getIoOffset("XAIUGPRBLR0")%>;
           addr[9:4] = ig[5:0];
           data[31:0] = csrq[ig].low_addr;
	   `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s low_addr 0x%0h GPRBLR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].low_addr, addr, data), UVM_LOW)
    <% if(obj.testBench == "fsys") { %>
           temp_addr[43:12] = csrq[ig].low_addr;
    <% } %>
//`ifdef DECODE_ERR_TEST
           if (!$value$plusargs("k_decode_err_illegal_acc_format_test_unsupported_size=%d",k_decode_err_illegal_acc_format_test_unsupported_size)) begin
               k_decode_err_illegal_acc_format_test_unsupported_size = 0;
           end
           if (k_decode_err_illegal_acc_format_test_unsupported_size) begin
               `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Checking illegal_acc_format_test_unsupported_size for write access"), UVM_NONE)
               k_decode_err_illegal_acc_format_test_unsupported_size = 1;
               val_change_k_decode_err_illegal_acc_format_test_unsupported_size.trigger(null);
               write_csr(addr,data);
               `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Done Checking illegal_acc_format_test_unsupported_size for write access"), UVM_NONE)
               `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Continue regular flow of csr sequence, write access should not return DECERR response. Setting k_decode_err_illegal_acc_format_test_unsupported_size to 0"), UVM_NONE)
               k_decode_err_illegal_acc_format_test_unsupported_size = 0;
               val_change_k_decode_err_illegal_acc_format_test_unsupported_size.trigger(null);
               `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Triggering uvm_event val_change_k_decode_err_illegal_acc_format_test_unsupported_size"), UVM_MEDIUM)
               `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Checking XAIUUESR.ErrVld."), UVM_MEDIUM)
                addr[19:12]=<%=aiu_rpn[obj.Id]%>;// Register Page Number
                addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUUESR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUUESR.get_offset()<%}%>;
               read_csr(addr,data);
               if(data[0]==0) begin 
                   `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0(=No Error is logged). That is expected"), UVM_MEDIUM)
               end
               else begin
                   if(AIUUEDR_DecErrDetEn==0) begin
                       `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 1. That is not expected(=No Error is logged)"))
                   end else begin
                       data[0]=1;
                       `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing AIUUESR.ErrVld to clear the error"), UVM_MEDIUM)
                       write_csr(addr,data);
                       read_csr(addr,data);
                       if(data[0]==0)
                           `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0, meaning Error is cleared. That is expected"), UVM_MEDIUM)
                       else
                           `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 1, meaning Error is not cleared. Expected value=0x0",data[0]))

                   end
               end
               `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Enabling XAIUUEDR.DecErrDetEn"), UVM_MEDIUM)
                addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUUEDR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUUEDR.get_offset()<%}%>;
               data=0;
               data[3] = 1;
               AIUUEDR_DecErrDetEn = 1;
               write_chk(addr,data,k_csr_access_only);
           end
           addr[19:12]=rpn;// Register Page Number
           addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUGPRBLR0.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUGPRBLR0.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUGPRBLR0")%>;=12'h<%=getIoOffset("XAIUGPRBLR0")%>;
           addr[9:4] = ig[5:0];
           data[31:0] = csrq[ig].low_addr;
           write_chk(addr,data,k_csr_access_only);

           addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUGPRBHR0.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUGPRBHR0.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUGPRBHR0")%>;=12'h<%=getIoOffset("XAIUGPRBHR0")%>;
           addr[9:4] = ig[5:0];
           data[31:0] = csrq[ig].upp_addr;
	   `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s upp_addr 0x%0h GPRHLR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].upp_addr, addr, data), UVM_LOW)
        <% if(obj.testBench == "fsys") { %>
            temp_addr[ncoreConfigInfo::W_SEC_ADDR-1:ncoreConfigInfo::W_SEC_ADDR-9] = csrq[ig].upp_addr;
            all_dmi_dii_start_addr[rpn].push_back(temp_addr);
            if(csrq[ig].unit.name=="DII") begin
                all_dii_start_addr[rpn].push_back(temp_addr);
            end else begin
                all_dmi_start_addr[rpn].push_back(temp_addr);
            end
        <% } %>
           write_chk(addr,data,k_csr_access_only);

           //Write to GPR register sets with appropriate values.
           //GPRAR : 12'b01XX XXXX 0000 ; addr[11:0] = {2'b01,ig[5:0],4'h0};
           addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUGPRAR0.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUGPRAR0.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUGPRAR0")%>;=12'h<%=getIoOffset("XAIUGPRAR0")%>;
           addr[9:4] = ig[5:0];
           data =0; // Reset value
           data[31]    = 1; // Valid
           data[30]    = (csrq[ig].unit == ncoreConfigInfo::DII ? 1 : 0); // Home Unit Type
	<% if((obj.AiuInfo[obj.Id].fnNativeInterface == "CHI-A")||(obj.AiuInfo[obj.Id].fnNativeInterface == "CHI-B")||(obj.AiuInfo[obj.Id].fnNativeInterface == "CHI-E")) { %>
           data[<%=getRegField("CAIUGPRAR0","Size").bitOffset+getRegField("CAIUGPRAR0","Size").bitWidth-1%>:<%=getRegField("CAIUGPRAR0","Size").bitOffset%>] = csrq[ig].size; // interleave group member size(2^(size+12) bytes)
	<%} else {%>
           data[<%=getRegField("XAIUGPRAR0","Size").bitOffset+getRegField("XAIUGPRAR0","Size").bitWidth-1%>:<%=getRegField("XAIUGPRAR0","Size").bitOffset%>] = csrq[ig].size; // interleave group member size(2^(size+12) bytes)
        <% } %>
           data[13:9]  = csrq[ig].mig_nunitid;
           data[4:1]   = csrq[ig].order;//bit0(Hazard bit) is deprecated; CONC-11405
           if ($test$plusargs("random_gpra_nsx")) begin
            data[7:6]   = csrq[ig].nsx;// randomize GPRAR.NS filed NSX[0] = NS :NS=0 Only secure transactions NS=1 All transactions are accepted
           end else begin
            data[7:6]   = 'h1;  
           end           
           begin:_gprar_nc // if GPRAR.NC field exist, write it
            uvm_reg gprar;
            uvm_reg  xaiupctcr ;
            <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::addr_width_t xaiupctcr_addr_offset;
            <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::addr_width_t xaiupctcr_recompute_addr = addr; // get the base address + rpn;
            //gprar= m_regs.default_map.get_reg_by_offset(addr);
            gprar= m_regs.default_map.get_reg_by_offset({ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE_COPY[51:20],addr[19:0]});
            xaiupctcr= m_regs.get_reg_by_name("XAIUPCTCR"); // get the first register just to get the offset
            if (xaiupctcr) begin :_unless_one_pctcr
                xaiupctcr_addr_offset = xaiupctcr.get_offset();// get lower address =register offset
                xaiupctcr_recompute_addr[11:0] = xaiupctcr_addr_offset[11:0];  // apply base address + rpn +  register offset
                //xaiupctcr = m_regs.default_map.get_reg_by_offset(xaiupctcr_recompute_addr);
                xaiupctcr = m_regs.default_map.get_reg_by_offset({ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE_COPY[51:20],xaiupctcr_recompute_addr[19:0]});
                if (xaiupctcr && xaiupctcr.get_field_by_name("LookupEn")) begin: _field_exist   // last check with "Lookup_en" field exit => useCache
                  if (gprar.get_field_by_name("NC")) data[5] = csrq[ig].nc;
                end:_field_exist else begin:_no_field
                  if (gprar.get_field_by_name("NC")) data[5] =1;  // if no useCache => AXI4 without proxycache => assert GPRAR.NCmode=1 by default
                end:_no_field
            end:_unless_one_pctcr else begin: _no_pctcr
               if (gprar.get_field_by_name("NC")) data[5] =1;  // if no useCache => AXI4 without proxycache => assert GPRAR.NCmode=1 by default
            end:_no_pctcr
           end:_gprar_nc
	   `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s size %0d order 0x%0h  noncoherent:%0h GPRAR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].size, csrq[ig].order,csrq[ig].nc, addr, data), UVM_LOW)
           write_chk(addr,data,k_csr_access_only);
	end // foreach (csrq[ig])

        rpn++;
    end

    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        if (!$value$plusargs("k_decode_err_illegal_acc_format_test_unsupported_size=%d",k_decode_err_illegal_acc_format_test_unsupported_size)) begin
            k_decode_err_illegal_acc_format_test_unsupported_size = 0;
        end
        if (k_decode_err_illegal_acc_format_test_unsupported_size) begin
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Checking illegal_acc_format_test_unsupported_size for read access"), UVM_NONE)
            k_decode_err_illegal_acc_format_test_unsupported_size = 1;
            val_change_k_decode_err_illegal_acc_format_test_unsupported_size.trigger(null);
            read_csr(addr,data);
            k_decode_err_illegal_acc_format_test_unsupported_size = 0;
            val_change_k_decode_err_illegal_acc_format_test_unsupported_size.trigger(null);
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Triggering uvm_event val_change_k_decode_err_illegal_acc_format_test_unsupported_size"), UVM_MEDIUM)
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Checking XAIUUESR.ErrVld."), UVM_MEDIUM)
             addr[19:12]=<%=aiu_rpn[obj.Id]%>;// Register Page Number
             addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUUESR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUUESR.get_offset()<%}%>;
            read_csr(addr,data);
            if(data[0]==1)  begin
                `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 1(=Error is logged). That is expected"), UVM_MEDIUM)
                if(data[7:4]==7)
                    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrType is found 7(=Decode Error). That is expected"), UVM_MEDIUM)
                else
                    `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrType=0x%0x. Expected value=0x7(=Decode Error)",data[7:4]))

                if(data[15:12]==2)
                    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrInfo is found 2(=Illegal DII access type). That is expected"), UVM_MEDIUM)
                else
                    `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrInfo=0x%0x. Expected value=0x2(=Illegal DII access type)",data[15:12]))

                if(data[17:16]==0)
                    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.CommandType is found 0(=read). That is expected"), UVM_MEDIUM)
                else
                    `uvm_warning("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.CommandType=0x%0x. Expected value=0x0(=read)",data[17:16]))

            end
            else begin
                `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0. That is not expected(=Error is logged)"))
            end
            data[0]=1;
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing AIUUESR.ErrVld to clear the error"), UVM_MEDIUM)
            write_csr(addr,data);
            read_csr(addr,data);
            if(data[0]==0)
                `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0, meaning Error is cleared. That is expected"), UVM_MEDIUM)
            else
                `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 1, meaning Error is not cleared. Expected value=0x0",data[0]))
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Done Checking illegal_acc_format_test_unsupported_size for read access"), UVM_NONE)


            k_decode_err_illegal_acc_format_test_unsupported_size = 1;
            val_change_k_decode_err_illegal_acc_format_test_unsupported_size.trigger(null);
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Checking illegal_acc_format_test_unsupported_size for write access"), UVM_NONE)
            write_csr(addr,data);
            k_decode_err_illegal_acc_format_test_unsupported_size = 0;
            val_change_k_decode_err_illegal_acc_format_test_unsupported_size.trigger(null);
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Triggering uvm_event val_change_k_decode_err_illegal_acc_format_test_unsupported_size"), UVM_MEDIUM)
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Checking XAIUUESR.ErrVld."), UVM_MEDIUM)
             addr[19:12]=<%=aiu_rpn[obj.Id]%>;// Register Page Number
             addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUUESR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUUESR.get_offset()<%}%>;
            read_csr(addr,data);
            if(data[0]==1)  begin
                `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 1(=Error is logged). That is expected"), UVM_MEDIUM)
                if(data[7:4]==7)
                    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrType is found 7(=Decode Error). That is expected"), UVM_MEDIUM)
                else
                    `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrType=0x%0x. Expected value=0x7(=Decode Error)",data[7:4]))

                if(data[15:12]==2)
                    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrInfo is found 2(=Illegal DII access type). That is expected"), UVM_MEDIUM)
                else
                    `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrInfo=0x%0x. Expected value=0x2(=Illegal DII access type)",data[15:12]))


                if(data[17:16]==1)
                    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.CommandType is found 1(=write). That is expected"), UVM_MEDIUM)
                else
                    `uvm_warning("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.CommandType=0x%0x. Expected value=0x0(=write)",data[17:16]))

            end
            else begin
                `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0. That is not expected(=Error is logged)"))
            end
            data[0]=1;
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing AIUUESR.ErrVld to clear the error"), UVM_MEDIUM)
            write_csr(addr,data);
            read_csr(addr,data);
            if(data[0]==0)
                `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0, meaning Error is cleared. That is expected"), UVM_MEDIUM)
            else
                `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 1, meaning Error is not cleared. Expected value=0x0",data[0]))

            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Done Checking illegal_acc_format_test_unsupported_size for write access"), UVM_NONE)
            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Continue regular flow of csr sequence"), UVM_NONE)
        end
//`endif // `ifdef DECODE_ERR_TEST
        //Unit Type: 0b000=Coherent Agent Interface Unit (CAIU), 0b001=Non-Coherent Agent Interface Unit (NCAIU), 0b010 - Non-coherent Agent Interface Unit with Proxy Cache (NCAIU)
        //Unit Sub-Types: for CAIU 0b000=ACE, 0b001=CHI-A, 0b010=CHI-B, 0b011-0b111:Reserved; for NCAIU 0b000=AXI, 0b001=ACE-Lite, 0b010=ACE-Lite-E, 0b011-0b111=Reserved
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        read_csr(addr,infor); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        if(infor[19:16] > 4'h2) begin
          if(!($test$plusargs("chi_csr_ns_access"))) begin
           `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Improper UnitType for AIU%0d : %0d", i, infor[19:16]))
          end
        end 
        else if(infor[19:16] == 4'h1 || infor[19:16] == 4'h2) begin // NCAIU
           // CREDIT and CONTROL registers
           if(infor[19:16] == 4'h2) begin // NCAIU without proxycache
              // Enable Error detection to enable error correction feature by default
              //XAIUCECR : 12'b0001 0100 0000
	      <% if(numNCAiu > 0) { %>
              addr[11:0] = m_regs.<%=ncaiu0%>.XAIUCECR.get_offset(); // 12'h<%=getIoOffset("XAIUCECR")%>;
              data=32'h1; // data[0]:ErrDetEn
	      `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Waiting aiu %0d XAIUCECR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              write_chk(addr,data,k_csr_access_only);
              <% } %>
	   end // else: !if(data[15:12] == 4'h1)			   
	end // if (data[15:12] == 4'h1 || data[15:12] == 4'h2)
  
           // Enable Error detection to enable error correction feature by default
           //XAIUUEDR : 12'b0001 0000 0000
           addr[11:0] = 'h0;
           addr[11:0] = m_regs.<%=chiaiu0%>.CAIUUEDR.get_offset(); // 12'h<%=getIoOffset("CAIUUEDR")%>;
           if (addr[11:0]) begin
              data=32'h0; // data[3]:DecErrDetEn
              read_csr(addr,data);
              data=data | 32'h8; // data[3]:DecErrDetEn
	            `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing aiu%0d xAIUUEDR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              write_chk(addr,data,k_csr_access_only);
           end

        if(infor[19:16] > 4'h2) begin //UST
           //`uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Improper Unit Sub-Types for AIU%0d : %0d", i, infor[19:16]),UVM_NONE)
          if(!($test$plusargs("chi_csr_ns_access"))) begin
           `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Improper Unit Sub-Types for AIU%0d : %0d", i, infor[19:16]))
          end
        end

 	<% if ((numNCAiu > 0)) { %>
         //infor[19:16] == xAIUINFOR.UT = 0(coh)||1(noncoh)||2(noncoh with proxy cache)
         //infor[18:16] == xAIUINFOR.UST = 0(ace)||1(chiA)||2(chib)  0(AXI)||1(ACE-LITE)||2(ACE-LITE-E)
       if(infor[19:16] == 1 || infor[19:16] == 2)  begin:_transorder  // Program XAIUTCR.TransOrderMode for NCAIU
            if(!$value$plusargs("ace_transorder_mode=%d", transorder_mode)) begin
              randcase
                10:    transorder_mode= 3;  // 2: Pcie_order 3:strict request order
                90:    transorder_mode= 2; 
              endcase
            end
         addr[11:0] = m_regs.<%=ncaiu0%>.XAIUTCR.get_offset();
	       data = (transorder_mode << m_regs.<%=ncaiu0%>.XAIUTCR.TransOrderModeRd.get_lsb_pos()) | (transorder_mode << m_regs.<%=ncaiu0%>.XAIUTCR.TransOrderModeWr.get_lsb_pos());
	       data = data | (1 << m_regs.<%=ncaiu0%>.XAIUTCR.EventDisable.get_lsb_pos());
	      `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Programming rpn %0d XAIUTCR.TransOrderMode to %0d ", rpn, transorder_mode), UVM_NONE)
	       write_chk(addr,data,k_csr_access_only);
	    end:_transorder
 <% } %>

        <% if(numChiAiu > 0) { %>
        if((infor[19:16] == 0) && (infor[18:16] < 3) && (infor[19:16] > 0))  begin  // Enable SysEvent for CHI-AIU
           addr[11:0] = m_regs.<%=chiaiu0%>.CAIUTCR.get_offset();
	   data = sys_event_disable << m_regs.<%=chiaiu0%>.CAIUTCR.EventDisable.get_lsb_pos();

	   data = data | (0 << m_regs.<%=chiaiu0%>.CAIUTCR.SysCoDisable.get_lsb_pos());
	   write_chk(addr,data,k_csr_access_only);

           addr[11:0] = m_regs.<%=chiaiu0%>.CAIUTOCR.get_offset();
	   data = chiaiu_timeout_val;
	   write_chk(addr,data,k_csr_access_only);
        end
        <% } %>

        <% if(obj.AiuInfo[0].fnEnableQos == 1) { %>
	if($test$plusargs("aiu_qos_threshold")) begin
            // Program QOS Event Threshold
            addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUQOSCR.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUQOSCR.get_offset()<%}%>;
	    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Programming rpn %0d CAIUQOSCR.EventThreshold to aiu_qos_threshold[%0d]=%0d ", rpn, rpn, aiu_qos_threshold[rpn]), UVM_LOW)
            write_chk(addr, aiu_qos_threshold[rpn], k_csr_access_only);
        end
	else if($value$plusargs("qos_threshold=%d", qos_threshold)) begin
            // Program QOS Event Threshold
            addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUQOSCR.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUQOSCR.get_offset()<%}%>;
            write_chk(addr, qos_threshold, k_csr_access_only);
        end
        <% } %>

        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        read_csr(addr,infor); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        if(infor[19:16] == 4'h2) begin // NCAIU
	      `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Initializing SMC Tag Memory for rpn %0d ", rpn), UVM_LOW)
              //USMCMCR0 : 12'b0000 0101 1000 ; addr[11:0]=12'h58;
              addr[11:0] = <%if(idxIoAiuWithPC) {%>m_regs.<%=ioAiuWithPC%>.XAIUPCMCR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMCR")%>;
              data = 32'h0; // data[21:16] : Tag_0/Data_1 memory array; data[3:0]: CacheMntOp :  Initialize all Entries
              write_chk(addr,data,k_csr_access_only);
             
              begin: _XAIUPCTCR_setup_rpn
               int ccp_allocen;
               int ccp_lookupen ;
               if(!($value$plusargs("ccp_lookupen=%0d",ccp_lookupen))) begin
                  ccp_lookupen  = 1;
              end
              if(!($value$plusargs("ccp_allocen=%0d",ccp_allocen))) begin
               ccp_allocen  = 1;
               end
              addr[11:0] = <%if(idxIoAiuWithPC) {%>m_regs.<%=ioAiuWithPC%>.XAIUPCTCR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMCR")%>;
              data = 32'h0; // data[0]: lookupen & data[1]: allocen
              data[0]=ccp_lookupen;
              data[1]=ccp_allocen;
              //#Cover.FSYS.PROXY.UpdateDis 
             <% if (obj.initiatorGroups.length > 1) { %>
             update_cmd_disable = 1;// if connectivity feature disable update channel in the proxy cache%>
             <%}%>
              data[2]  = update_cmd_disable; //UpdateDis
              write_chk(addr,data,k_csr_access_only);
              end:_XAIUPCTCR_setup_rpn
              // Wait for Initialization to start
              //end while (!data[0]); // data[0] : Maintanance Operation Active 
	end // if (data[15:12] == 4'h2)

        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   
				   
    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        read_csr(addr,data); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        if(data[19:16] == 4'h2) begin // NCAIU with proxycache
              // Wait for SMC Tag Mem Initialization to complete
	      `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Waiting for initializing PC Tag Memory for rpn %0d to complete", rpn), UVM_LOW)
              addr[11:0] = <%if(idxIoAiuWithPC) {%>m_regs.<%=ioAiuWithPC%>.XAIUPCMAR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMAR")%>;
              do begin
                 read_csr(addr,data);
              end while (data[0]); // data[0] : Maintanance Operation Active 
	end // if (data[15:12] == 4'h1 || data[15:12] == 4'h2)
        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        read_csr(addr,data); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        if(data[19:16] == 4'h2) begin // NCAIU with proxycache
              // Initialize data memory Array
	      `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Initializing PC Data Memory for rpn %0d ", rpn), UVM_LOW)
              //USMCMCR0 : 12'b0000 0101 1000 ; addr[11:0]=12'h58;
              addr[11:0] = <%if(idxIoAiuWithPC) {%>m_regs.<%=ioAiuWithPC%>.XAIUPCMCR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMCR")%>;
              data = 32'h10000; // data[21:16] : Tag_0/Data_1 memory array; data[3:0]: CacheMntOp :  Initialize all Entries
              write_chk(addr,data,k_csr_access_only);

              // Wait for Initialization to start
              //USMCMAR0 : 12'b0000 0101 1100 ; addr[11:0]=12'h5C;
	      //`uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Waiting for initializing PC Data Memory for rpn %0d to start", rpn), UVM_LOW)
              //addr[11:0] = <%if(idxIoAiuWithPC) {%>m_regs.ncaiu<%=idxIoAiuWithPC-1%>.XAIUPCMAR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMAR")%>;
              //do begin
              //   read_csr(addr,data);
              //end while (!data[0]); // data[0] : Maintanance Operation Active 
	end // if (data[15:12] == 4'h1 || data[15:12] == 4'h2)
        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        read_csr(addr,data); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        if(data[19:16] == 4'h2) begin // NCAIU with proxycache
              // Wait for Initialization to complete
	      `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Waiting for initializing PC Data Memory for rpn %0d to complete", rpn), UVM_LOW)
              addr[11:0] = <%if(idxIoAiuWithPC) {%>m_regs.<%=ioAiuWithPC%>.XAIUPCMAR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMAR")%>;
              do begin
                 read_csr(addr,data);
              end while (data[0]); // data[0] : Maintanance Operation Active 
	end // if (data[15:12] == 4'h1 || data[15:12] == 4'h2)
        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    // (4) Initialize DCEs (All General Purpose Region Registers, can be murged to above step-3 if CONC-5599 is resolved)
    //rpn = nAIUs;
    cur_rpn = rpn;
    for(int i=0; i<nDCEs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(k_csr_access_only == 1) begin
           // Wait for any activity to complete
           //DCEUSFMAR : 12'b0010 0100 0100 ; addr[11:0]=12'h244;
           addr[11:0] = m_regs.dce0.DCEUSFMAR.get_offset(); // 12'h<%=getDceOffset("DCEUSFMAR")%>;
           do begin
              read_csr(addr,data);
           end while (data[0]); // data[0] : Maintanance Operation Active 

           // Initialize Snoop Filter Memory(By default initially this is done as reset value is 0)
           //DCEUSFMCR: 12'b0010 0100 0000 ; addr[11:0]=12'h240;
           addr[11:0] = m_regs.dce0.DCEUSFMCR.get_offset(); // 12'h<%=getDceOffset("DCEUSFMCR")%>;
           data = 32'h1; // data[0] Toggle the bit to start snoop filter initialization, setting 1 resets the initialization counter
           write_chk(addr,data,k_csr_access_only);
           data = 32'h0; // data[0] Toggle the bit to start snoop filter initialization, setting 0 will start using counter
           write_chk(addr,data,k_csr_access_only);

           //DCEUSFMAR : 12'b0010 0100 0100 ; addr[11:0]=12'h244;
           addr[11:0] = m_regs.dce0.DCEUSFMAR.get_offset(); // 12'h<%=getDceOffset("DCEUSFMAR")%>;
           // Wait for any activity to start
           //`uvm_info("CHIAIU_ENUM_BOOT_SEQ",$psprintf("Waiting for SnoopFiler initialization to start"),UVM_LOW) 
           //do begin
           //   read_csr(addr,data);
           //end while (!data[0]); // data[0] : Maintanance Operation Active 
           // Wait for any activity to complete
           `uvm_info("CHIAIU_ENUM_BOOT_SEQ",$psprintf("Waiting for SnoopFilter initialization to complete"),UVM_LOW) 
           do begin
              read_csr(addr,data);
           end while (data[0]); // data[0] : Maintanance Operation Active 

           //DCEUINFOR : 12'b1111 1111 1000 ; addr[11:0]=12'hFF8;
           addr[11:0] = m_regs.dce0.DCEUINFOR.get_offset(); // 12'h<%=getDceOffset("DCEUINFOR")%>;
           read_csr(addr,data);
           if(data[19:16] != 4'h8) begin // UT/Unit Type: should be 4'b1000 for DCE
             if(!($test$plusargs("chi_csr_ns_access"))) begin
              `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("DCE%0d Information register Unit type unexpected: Exp:%0h Act:%0h", i, 4'h8,data[19:16]))
             end
           end
        end // CSR CHECK
          
          // Enable Error detection to enable error correction feature by default
           //XAIUUEDR : 12'b0001 0000 0000
           addr[11:0] = m_regs.dce0.DCEUUEDR.get_offset(); 
           data=32'h0; // data[3]:DecErrDetEn
           read_csr(addr,data);
           data=data | 32'h8; // data[3]:DecErrDetEn
	         `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing DCE%0d DCEUUEDR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
           write_chk(addr,data,k_csr_access_only);

        foreach (csrq[ig]) begin
           //Write to GPR register sets with appropriate values.
           //GPRBLR : 12'b01XX XXXX 0100 ; addr[11:0] = {2'b01,ig[5:0],4'h4};
           addr[11:0] = m_regs.dce0.DCEUGPRBLR0.get_offset(); // 12'h<%=getDceOffset("DCEUGPRBLR0")%>;
           addr[9:4]=ig[5:0];
           data[31:0] = csrq[ig].low_addr;
	   `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s low_addr 0x%0h GPRBLR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].low_addr, addr, data), UVM_LOW)
           write_chk(addr,data,k_csr_access_only);

           //GPRBHR : 12'b01XX XXXX 1000 ; addr[11:0] = {2'b01,ig[5:0],4'h8};
           addr[11:0] = m_regs.dce0.DCEUGPRBHR0.get_offset(); // 12'h<%=getDceOffset("DCEUGPRBHR0")%>;
           addr[9:4]=ig[5:0];
           //data =0;
           //data[7:0] = csrq[ig].upp_addr;
           data[31:0] = csrq[ig].upp_addr;
	   `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s upp_addr 0x%0h GPRHLR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].upp_addr, addr, data), UVM_LOW)
           write_chk(addr,data,k_csr_access_only);

           //GPRAR : 12'b01XX XXXX 0000 ; addr[11:0] = {2'b01,ig[5:0],4'h0};
           addr[11:0] = m_regs.dce0.DCEUGPRAR0.get_offset(); // 12'h<%=getDceOffset("DCEUGPRAR0")%>;
           addr[9:4]=ig[5:0];
           data =0; // Reset value
           data[31]    = 1; // Valid
           data[30]    = (csrq[ig].unit == ncore_config_pkg::ncoreConfigInfo::DII ? 1 : 0); // Home Unit Type
	<% if((obj.AiuInfo[obj.Id].fnNativeInterface == "CHI-A")||(obj.AiuInfo[obj.Id].fnNativeInterface == "CHI-B")||(obj.AiuInfo[obj.Id].fnNativeInterface == "CHI-E")) { %>
           data[<%=getRegField("CAIUGPRAR0","Size").bitOffset+getRegField("CAIUGPRAR0","Size").bitWidth-1%>:<%=getRegField("CAIUGPRAR0","Size").bitOffset%>] = csrq[ig].size; // interleave group member size(2^(size+12) bytes)
	<%} else {%>
           data[<%=getRegField("XAIUGPRAR0","Size").bitOffset+getRegField("XAIUGPRAR0","Size").bitWidth-1%>:<%=getRegField("XAIUGPRAR0","Size").bitOffset%>] = csrq[ig].size; // interleave group member size(2^(size+12) bytes)
        <% } %>
           data[13:9]  = csrq[ig].mig_nunitid;
           data[2:0]   = 0; // TODO Need to assign proper value
	   `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s size %0d GPRAR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].size, addr, data), UVM_LOW)
           write_chk(addr,data,k_csr_access_only);
        end

        addr[11:0] = m_regs.dce0.DCEUAMIGR.get_offset(); // 12'h<%=getDceOffset("DCEUAMIGR")%>; addr[11:0] = 12'h3c0; 
        data = 32'h0; data[4:0]={ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs,1'b1};
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing dce %0d DCEUAMIGR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
        write_chk(addr,data,k_csr_access_only);

        // Enable VB recovery on wr/up; TODO : Temporary Enabled through Register; later will be enabled by default (No register)
        // TODO: Disable for now. Enable later
        addr[11:0] = m_regs.dce0.DCEUEDR0.get_offset(); // 12'h<%=getDceOffset("DCEUEDR0")%>; addr[11:0] = 12'hA00; 
        read_csr(addr,data);
        write_chk(addr,data | (0<<10),k_csr_access_only);

        // Enable Error detection to enable error correction feature by default
        //DCEUCECR : 12'b0001 0100 0000
        addr[11:0] = m_regs.dce0.DCEUCECR.get_offset(); // 12'h<%=getDceOffset("DCEUCECR")%>;
        data=32'h1; // data[0]:ErrDetEn
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing dce %0d DCEUCECR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
        write_chk(addr,data,k_csr_access_only);
            
        <% if (obj.DceInfo[0].fnEnableQos == 1) { %> 
	if($test$plusargs("dce_qos_threshold")) begin
            // Program QOS Event Threshold
            addr[11:0] = m_regs.dce0.DCEUQOSCR0.get_offset(); 
	    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Programming rpn %0d DCEQOSCR0.EventThreshold to dce_qos_threshold[%0d]=%0d ", rpn, rpn-<%=obj.nAIUs%>, dce_qos_threshold[rpn-<%=obj.nAIUs%>]), UVM_LOW)
            write_chk(addr, dce_qos_threshold[rpn-<%=obj.nAIUs%>], k_csr_access_only);
        end
	else if($value$plusargs("qos_threshold=%d", qos_threshold)) begin
            // Program QOS Event Threshold
            addr[11:0] = m_regs.dce0.DCEUQOSCR0.get_offset(); 
            write_chk(addr, qos_threshold, k_csr_access_only);
        end
        <% } %>

        if($test$plusargs("sysco_disable")) begin
        addr[11:0] = m_regs.dce0.DCEUSER0.get_offset();
        //data = <%=SnoopEn%>; //FIXME : FFFFFFFFF
	data = 32'hFFFF_FFFF;
        write_csr(addr,data);

	<%if(obj.DceInfo[0].nAius > 32) { %>
	addr[11:0] = m_regs.dce0.DCEUSER1.get_offset();
	data = 32'hFFFF_FFFF;
	write_csr(addr, data);
    	<%}%>

	<%if(obj.DceInfo[0].nAius > 64) { %>
	addr[11:0] = m_regs.dce0.DCEUSER2.get_offset();
	data = 32'hFFFF_FFFF;
	write_csr(addr, data);
    	<%}%>
        end
				   
        addr[11:0] = m_regs.dce0.DCEUTCR.get_offset();
	data = sys_event_disable << m_regs.dce0.DCEUTCR.EventDisable.get_lsb_pos();
	write_chk(addr,data,k_csr_access_only);

        addr[11:0] = m_regs.dce0.DCEUSBSIR.get_offset(); 
        read_csr(addr,data);
	`uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("[DCE REG] Reading rpn %0d DCEUSBSIR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        if(data[31]==1) begin
          act_cmd_skid_buf_size["DCE"][i]=data[25:16];
          act_cmd_skid_buf_arb["DCE"][i]=data[8:0];
        end else begin
          if(!($test$plusargs("chi_csr_ns_access"))) begin
           `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DCE REG] Valid bit not asserted in DCEUSBSIR-%0d ADDR 0x%0h DATA 0x%0h", i, addr, data))
          end
        end
        rpn++;
    end

    //#Check.CHIAIU.v3.4.SCM.AssertIllegalCreditLimit
  if(!($test$plusargs("chi_csr_ns_access"))) begin
    if(exp_cmd_skid_buf_size["DCE"].size != act_cmd_skid_buf_size["DCE"].size) begin
        `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DCE] exp_cmd_skid_buf_size[DCE].size %0d != act_cmd_skid_buf_size[DCE].size %0d",exp_cmd_skid_buf_size["DCE"].size,act_cmd_skid_buf_size["DCE"].size))
    end
    foreach(exp_cmd_skid_buf_size["DCE"][temp]) begin
        if(exp_cmd_skid_buf_size["DCE"][temp]!= act_cmd_skid_buf_size["DCE"][temp]) begin
            `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DCE] exp_cmd_skid_buf_size[DCE][%0d] %0d != act_cmd_skid_buf_size[DCE][%0d] %0d",temp,exp_cmd_skid_buf_size["DCE"][temp],temp,act_cmd_skid_buf_size["DCE"][temp]))
        end
        if(exp_cmd_skid_buf_arb["DCE"][temp]!= act_cmd_skid_buf_arb["DCE"][temp]) begin
            `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DCE] exp_cmd_skid_buf_arb[DCE][%0d] %0d != act_cmd_skid_buf_arb[DCE][%0d] %0d",temp,exp_cmd_skid_buf_arb["DCE"][temp],temp,act_cmd_skid_buf_arb["DCE"][temp]))
        end
    end
  end
    // (5) Initialize DMIs
    //rpn = nAIUs + nDCEs;
    cur_rpn = rpn;
    for(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) begin  
           // Configure Scratchpad memories
           if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcsp[i]) begin  
	      ScPadEn = (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i] && !($test$plusargs("all_ways_for_cache"))) ? 32'h1 : 32'h0;
              ScPadBaseAddr = k_sp_base_addr[i] >> <%=obj.wCacheLineOffset%>;

              //DMIUSMCSPBR0 : 12'b0011 0011 0000
              addr[11:0] = <%if(numDmiWithSP){%>m_regs.<%=obj.DmiInfo[idxDmiWithSP].strRtlNamePrefix%>.DMIUSMCSPBR0.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCSPBR0")%>;
              data= ScPadBaseAddr[31:0];
              `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCSPBR0 (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              write_chk(addr,data,k_csr_access_only);

              if(ncore_config_pkg::ncoreConfigInfo::WCACHE_OFFSET > 32) begin
                 //DMIUSMCSPBR1 : 12'b0011 0011 0100
                 addr[11:0] = <%if(numDmiWithSP){%>m_regs.<%=obj.DmiInfo[idxDmiWithSP].strRtlNamePrefix%>.DMIUSMCSPBR1.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCSPBR1")%>;
                 data= ScPadBaseAddr >> 32 ; // ScPadBaseAddrHi
                 `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCSPBR1 (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
                 write_chk(addr,data,k_csr_access_only);
              end

              //DMIUSMCSPCR0 : 12'b0011 0011 1000
              addr[11:0] = <%if(numDmiWithSP){%>m_regs.<%=obj.DmiInfo[idxDmiWithSP].strRtlNamePrefix%>.DMIUSMCSPCR0.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCSPCR0")%>;
	      data     = 'h0;
	      data[0]  = (sp_ways[i] > 0) ?ScPadEn:0;
              data[6:1]= sp_ways[i] - 1 ; // NumScPadWays=ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]-1 ,
              `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCSPCR0 (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              write_chk(addr,data,k_csr_access_only);

              //DMIUSMCSPCR1 : 12'b0011 0011 1100
              addr[11:0] = <%if(numDmiWithSP){%>m_regs.<%=obj.DmiInfo[idxDmiWithSP].strRtlNamePrefix%>.DMIUSMCSPCR1.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCSPCR1")%>;
              data= sp_size[i] - 1; // Scratchpad size in number of cachelines.
              `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCSPCR1 (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              write_chk(addr,data,k_csr_access_only);

           end

           // Configure policies
           //DMIUSMCTCR : 12'b0011 0000 0000
           addr[11:0] = <%if(numDmiWithSMC){%>m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCTCR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCTCR")%>;
	   if($test$plusargs("dmi_alloc_dis")) begin
              data=32'h1; // data[1]:AllocEn , data[0]:LookupEn
	   end else begin
              data=32'h3; // data[1]:AllocEn , data[0]:LookupEn
           end
           `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCTCR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
           write_chk(addr,data,k_csr_access_only);
 
           //DMIUSMCAPR : 12'b0011 0000 1000
           addr[11:0] = <%if(numDmiWithSMC){%>m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCAPR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCAPR")%>;
           //#Check.FSYS.SMC.TOFAllocDisable
           //#Check.FSYS.SMC.ClnWrAllocDisable
           //#Check.FSYS.SMC.DtyWrAllocDisable
           //#Check.FSYS.SMC.RdAllocDisable
           //#Check.FSYS.SMC.WrAllocDisable 
           // by defautl data = 0 ,when dmiusmc_policy test is enabled dmiusmc_policy reg field will be set to 1
           if($test$plusargs("dmiusmc_policy_chiaiu_test")) begin
            data = dmiusmc_policy_rand; // data[4]:WrAllocDisable , data[3]:RdAllocDisable , data[2]:DtyWrAllocDisable , data[1]:ClnWrAllocDisable , data[0]:TOFAllocDisable
           end else begin
            data = dmiusmc_policy; // data[4]:WrAllocDisable , data[3]:RdAllocDisable , data[2]:DtyWrAllocDisable , data[1]:ClnWrAllocDisable , data[0]:TOFAllocDisable
           end
           `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCAPR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
           write_chk(addr,data,k_csr_access_only);
 
           // Configure way partitioning // TODO what if SP and Way partitioning both are enabled together
           if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcwp[i]) begin  
              if ($test$plusargs("no_way_partitioning")) begin
                 for( int j=0;j<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];j++) begin
                    //DMIUSMCWPCR0 : 12'b0011 0100 0000
                    addr[11:0] = <%if(numDmiWithWP){%>m_regs.<%=obj.DmiInfo[idxDmiWithWP].strRtlNamePrefix%>.DMIUSMCWPCR00.get_offset()+ (j*8) <%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCWPCR00")%>;
                    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCWPCR0%0d (0x%0h) = 0x%0h", i, j, addr, j), UVM_LOW)
                    write_chk(addr,j,k_csr_access_only);
                 end
              end else begin
                //bit [31:0] agent_ids_assigned_q[$];
                //int shared_ways_per_user;
                for( int j=0;j<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];j++) begin
                   bit [31:0] agent_id;
                   agent_id = agent_ids_assigned_q[i][j];
                   //DMIUSMCWPCR0 : 12'b0011 0100 0000
                   addr[11:0] = <%if(numDmiWithWP){%>m_regs.<%=obj.DmiInfo[idxDmiWithWP].strRtlNamePrefix%>.DMIUSMCWPCR00.get_offset()+ (j*8) <%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCWPCR00")%>;
                   `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCWPCR0%0d (0x%0h) = 0x%0h", i, j, addr, agent_id), UVM_LOW)
                   write_chk(addr,agent_id,k_csr_access_only);

                   `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("dmi %0d way-part reg no %0d vld %0b id %0h", i, j, agent_id[31], agent_id[30:0]), UVM_LOW)

                   data = wayvec_assigned_q[i][j];
                   //DMIUSMCWPCR1 : 12'b0011 0100 0100
                   addr[11:0] = <%if(numDmiWithWP){%>m_regs.<%=obj.DmiInfo[idxDmiWithWP].strRtlNamePrefix%>.DMIUSMCWPCR10.get_offset()+ (j*8) <%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCWPCR10")%>;
                   write_chk(addr,data,k_csr_access_only);
                   `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("dmi %0d way-part reg no %0d way %0b", i, j, data), UVM_LOW)
                end
              end // if ($test$plusargs("no_way_partitioning")) begin
           end

           if(k_csr_access_only) begin
              //DMIUSMCIFR : 12'b1111 1111 1000
              addr[11:0] = <%if(numDmiWithSMC){%>m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCIFR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCIFR")%>;
              read_csr(addr,data);
              if((data[19: 0] == (ncore_config_pkg::ncoreConfigInfo::dmi_CmcSet[i] ? ncore_config_pkg::ncoreConfigInfo::dmi_CmcSet[i]-1 : 0 )) && // Data[19:0] NumSet
                 (data[25:20] == (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i] ? ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]-1 : 0 )) && // Data[25:20] NumWay
                 (data[26:26] == (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcsp[i])) && // Data[26:26] SP: ScratchPad Support Exist
                 (data[27:27] == (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcwp[i])) && // Data[27:27] WP: Way Partitioning Support Exist
                 (data[31:28] == (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i] ? ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i]-1 : 0 )) // Data[31:28] NumWayPartitionig Registers
                ) begin
                 `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Read dmi %0d DMIUSMCIFR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              end else begin
                if(!($test$plusargs("chi_csr_ns_access"))) begin
                 `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Read dmi %0d DMIUSMCIFR (0x%0h) = 0x%0h, Sets/Ways mismatch", i, addr, data))
                end
              end

              //DMIUINFOR : 12'b1111 1111 1100
              addr[11:0] = <%if(numDmiWithSMC){%>m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUINFOR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUINFOR")%>;
              read_csr(addr,data);
              if((data[19:16] == 'h9) && // Data[15:12] UT=DMI ('h9) unit type
                 (data[24  ] == ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) && // Data[13] SMC System Memory Cache present
                 (data[25  ] == ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[i]) && // Data[12] AE  Atomic Engine present
                 (data[31  ] == 'b1) // Data[31] Valid
                ) begin
                 `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Read dmi %0d DMIUINFOR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              end else begin
                if(!($test$plusargs("chi_csr_ns_access"))) begin
                 `uvm_error("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Read dmi %0d DMIUINFOR (0x%0h) = 0x%0h, UniteType/AtomicEngine/SMC/Valid mismatch", i, addr, data))
                end
              end
           end
        end

        // Enable Error detection to enable error correction feature by default
        //DMIUCECR : 12'b0001 0100 0000
        addr[11:0] = m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUCECR.get_offset(); // 12'h<%=getDmiOffset("DMIUCECR")%>;
        data=32'h1; // data[0]:ErrDetEn
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUCECR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
        write_chk(addr,data,k_csr_access_only);
            
        <% if (obj.DmiInfo[0].fnEnableQos == 1) { %> 
	if($test$plusargs("dmi_qos_threshold")) begin
            // Program QOS Event Threshold
            addr[11:0] = m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUQOSCR0.get_offset(); 
	    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("Programming rpn %0d DMIQOSCR0.EventThreshold to dmi_qos_threshold[%0d]=%0d ", rpn, rpn-<%=obj.nAIUs%>-<%=obj.nDCEs%>, dmi_qos_threshold[rpn-<%=obj.nAIUs%>-<%=obj.nDCEs%>]), UVM_LOW)
            write_chk(addr, dmi_qos_threshold[rpn-<%=obj.nAIUs%>-<%=obj.nDCEs%>], k_csr_access_only);
        end
	else if($value$plusargs("qos_threshold=%d", qos_threshold)) begin
            // Program QOS Event Threshold
            addr[11:0] = m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUQOSCR0.get_offset(); 
            write_chk(addr, qos_threshold, k_csr_access_only);
        end
        <% } %>
        rpn++;
    end

    rpn = cur_rpn;
    for(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) begin  
           // Initialize tag memory Array
           //DMIUSMCMCR : 12'b0011 0001 0000
           addr[11:0] = <%if(numDmiWithSMC){%>m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCMCR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCMCR")%>;
           data = 32'h0; // data[21:16] : Tag_0/Data_1 memory array; data[3:0]: CacheMntOp :  Initialize all Entries
           write_chk(addr,data,k_csr_access_only);

	end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i])
        rpn++;
    end			   

    rpn = cur_rpn;
    for(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) begin  
           // Wait for Tag Mem Initialization to complete
           //DMIUSMCMAR : 12'b0011 0001 0100
           addr[11:0] = <%if(numDmiWithSMC){%>m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCMAR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCMAR")%>;
           do begin
              read_csr(addr,data);
           end while (data[0]); // data[0] : Maintanance Operation Active 
           
	end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i])
        rpn++;
    end			   

    rpn = cur_rpn;
    for(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) begin  
           // Initialize data memory Array
           //DMIUSMCMCR : 12'b0011 0001 0000
           addr[11:0] = <%if(numDmiWithSMC){%>m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCMCR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCMCR")%>;
           data = 32'h10000; // data[21:16] : Tag_0/Data_1 memory array; data[3:0]: CacheMntOp :  Initialize all Entries
           write_chk(addr,data,k_csr_access_only);
	end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i])
        rpn++;
    end			   

    rpn = cur_rpn;
    for(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) begin  
           // Wait for Data Mem Initialization to complete
           //DMIUSMCMAR : 12'b0011 0001 0100
           addr[11:0] = <%if(numDmiWithSMC){%>m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCMAR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCMAR")%>;
           do begin
              read_csr(addr,data);
           end while (data[0]); // data[0] : Maintanance Operation Active 
	end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i])

        addr[11:0] = m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.MRDSBSIR.get_offset(); 
        read_csr(addr,data);
	`uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("[DMI REG] Reading rpn %0d MRDSBSIR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        if(data[31]==1) begin
          act_mrd_skid_buf_size["DMI"][i]=data[25:16];
          act_mrd_skid_buf_arb["DMI"][i]=data[8:0];
        end else begin
          if(!($test$plusargs("chi_csr_ns_access"))) begin
          `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI REG] Valid bit not asserted in MRDSBSIR-%0d ADDR 0x%0h DATA 0x%0h", i, addr, data))
          end
        end

        addr[11:0] = m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.CMDSBSIR.get_offset(); 
        read_csr(addr,data);
	`uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d CMDSBSIR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        if(data[31]==1) begin
          act_cmd_skid_buf_size["DMI"][i]=data[25:16];
          act_cmd_skid_buf_arb["DMI"][i]=data[8:0];
        end else begin
          if(!($test$plusargs("chi_csr_ns_access"))) begin
           `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI REG] Valid bit not asserted in CMDSBSIR-%0d ADDR 0x%0h DATA 0x%0h", i, addr, data))
          end
        end

        rpn++;
    end			   

    //#Check.CHIAIU.v3.4.SCM.AssertIllegalCreditLimit
  if(!($test$plusargs("chi_csr_ns_access"))) begin
    if(exp_cmd_skid_buf_size["DMI"].size != act_cmd_skid_buf_size["DMI"].size) begin
        `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI] exp_cmd_skid_buf_size[DMI].size %0d != act_cmd_skid_buf_size[DMI].size %0d",exp_cmd_skid_buf_size["DMI"].size,act_cmd_skid_buf_size["DMI"].size))
    end
    foreach(exp_cmd_skid_buf_size["DMI"][temp]) begin
        if(exp_cmd_skid_buf_size["DMI"][temp]!= act_cmd_skid_buf_size["DMI"][temp]) begin
            `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI] exp_cmd_skid_buf_size[DMI][%0d] %0d != act_cmd_skid_buf_size[DMI][%0d] %0d",temp,exp_cmd_skid_buf_size["DMI"][temp],temp,act_cmd_skid_buf_size["DMI"][temp]))
        end
        if(exp_cmd_skid_buf_arb["DMI"][temp]!= act_cmd_skid_buf_arb["DMI"][temp]) begin
            `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI] exp_cmd_skid_buf_arb[DMI][%0d] %0d != act_cmd_skid_buf_arb[DMI][%0d] %0d",temp,exp_cmd_skid_buf_arb["DMI"][temp],temp,act_cmd_skid_buf_arb["DMI"][temp]))
        end
    end

    if(exp_mrd_skid_buf_size["DMI"].size != act_mrd_skid_buf_size["DMI"].size) begin
        `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI] exp_mrd_skid_buf_size[DMI].size %0d != act_mrd_skid_buf_size[DMI].size %0d",exp_mrd_skid_buf_size["DMI"].size,act_mrd_skid_buf_size["DMI"].size))
    end
    foreach(exp_mrd_skid_buf_size["DMI"][temp]) begin
        if(exp_mrd_skid_buf_size["DMI"][temp]!= act_mrd_skid_buf_size["DMI"][temp]) begin
            `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI] exp_mrd_skid_buf_size[DMI][%0d] %0d != act_mrd_skid_buf_size[DMI][%0d] %0d",temp,exp_mrd_skid_buf_size["DMI"][temp],temp,act_mrd_skid_buf_size["DMI"][temp]))
        end
        if(exp_mrd_skid_buf_arb["DMI"][temp]!= act_mrd_skid_buf_arb["DMI"][temp]) begin
            `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI] exp_mrd_skid_buf_arb[DMI][%0d] %0d != act_mrd_skid_buf_arb[DMI][%0d] %0d",temp,exp_mrd_skid_buf_arb["DMI"][temp],temp,act_mrd_skid_buf_arb["DMI"][temp]))
        end
    end
  end
    cur_rpn = rpn;
    for(int i=0; i<nDIIs; i++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = m_regs.<%=obj.DiiInfo[0].strRtlNamePrefix%>.DIIUSBSIR.get_offset(); 
        read_csr(addr,data);
	`uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("[DII REG] Reading rpn %0d CMDSBSIR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        if(data[31]==1) begin
          act_cmd_skid_buf_size["DII"][i]=data[25:16];
          act_cmd_skid_buf_arb["DII"][i]=data[8:0];
        end else begin
          if(!($test$plusargs("chi_csr_ns_access"))) begin
          `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DII REG] Valid bit not asserted in CMDSBSIR-%0d ADDR 0x%0h DATA 0x%0h", i, addr, data))
          end
        end

        rpn++;
    end

    //#Check.CHIAIU.v3.4.SCM.AssertIllegalCreditLimit
    if(!($test$plusargs("chi_csr_ns_access"))) begin
      if(exp_cmd_skid_buf_size["DII"].size != act_cmd_skid_buf_size["DII"].size) begin
          `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DII] exp_cmd_skid_buf_size[DII].size %0d != act_cmd_skid_buf_size[DII].size %0d",exp_cmd_skid_buf_size["DII"].size,act_cmd_skid_buf_size["DII"].size))
      end
      foreach(exp_cmd_skid_buf_size["DII"][temp]) begin
          if(exp_cmd_skid_buf_size["DII"][temp]!= act_cmd_skid_buf_size["DII"][temp]) begin
              `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DII] exp_cmd_skid_buf_size[DII][%0d] %0d != act_cmd_skid_buf_size[DII][%0d] %0d",temp,exp_cmd_skid_buf_size["DII"][temp],temp,act_cmd_skid_buf_size["DII"][temp]))
          end
          if(exp_cmd_skid_buf_arb["DII"][temp]!= act_cmd_skid_buf_arb["DII"][temp]) begin
              `uvm_error("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DII] exp_cmd_skid_buf_arb[DII][%0d] %0d != act_cmd_skid_buf_arb[DII][%0d] %0d",temp,exp_cmd_skid_buf_arb["DII"][temp],temp,act_cmd_skid_buf_arb["DII"][temp]))
          end
      end
    end

    // program DVE SnpsEnb
    //rpn += nDIIs;
    if($test$plusargs("sysco_disable")) begin
        for(int i=0; i<nDVEs; i++) begin
            addr[19:12]=rpn;// Register Page Number
            addr[11:0] = m_regs.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVEUSER0.get_offset();
            data = <%=SnoopEn%>;
            write_chk(addr,data,k_csr_access_only);
            rpn++;
        end
    end

if( ! k_csr_access_only) begin  // Keep default Credit limit values to access sys_dii from all AIUs
//Configure credit limit for AIUs and DCEs                                  
    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUFUIDR.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUFUIDR.get_offset()<%}%>; ;
        read_csr(addr,data);
	`uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg AIU_FUIDR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        AiuIds = new[AiuIds.size()+1] (AiuIds);
        AiuIds[AiuIds.size()-1] =  data[15:0];
        if(i==0) begin temp_string=""; temp_string = $sformatf("%0s AiuIds : \n",temp_string); end
        temp_string = $sformatf("%0s %0d",temp_string,AiuIds[i]);
        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   
    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("%0s",temp_string), UVM_LOW)

    cur_rpn = rpn;
    for(int i=0; i<nDCEs; i++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = m_regs.dce0.DCEUFUIDR.get_offset();
        read_csr(addr,data);
	`uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg DCE_FUIDR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        DceIds = new[DceIds.size()+1] (DceIds);
        DceIds[DceIds.size()-1] =  data[15:0];
        if(i==0) begin temp_string=""; temp_string = $sformatf("%0s DceIds : \n",temp_string); end
        temp_string = $sformatf("%0s %0d",temp_string,DceIds[i]);
        rpn++;
    end // for (int i=0; i<nDCEs; i++)				   
    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("%0s",temp_string), UVM_LOW)

    cur_rpn = rpn;
    for(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUFUIDR.get_offset();
        read_csr(addr,data);
	`uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg DMI_FUIDR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        DmiIds = new[DmiIds.size()+1] (DmiIds);
        DmiIds[DmiIds.size()-1] =  data[15:0];
        if(i==0) begin temp_string=""; temp_string = $sformatf("%0s DmiIds : \n",temp_string); end
        temp_string = $sformatf("%0s %0d",temp_string,DmiIds[i]);
        rpn++;
    end // for (int i=0; i<nDMIs; i++)				   
    `uvm_info("CHIAIU_ENUM_BOOT_SEQ", $sformatf("%0s",temp_string), UVM_LOW)

    cur_rpn = rpn;
    for(int i=0; i<nDIIs; i++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = m_regs.<%=obj.DiiInfo[0].strRtlNamePrefix%>.DIIUFUIDR.get_offset();
        read_csr(addr,data);
	`uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg DII_FUIDR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        DiiIds = new[DiiIds.size()+1] (DiiIds);
        DiiIds[DiiIds.size()-1] =  data[15:0];
        if(i==0) begin temp_string=""; temp_string = $sformatf("%0s DiiIds : \n",temp_string); end
        temp_string = $sformatf("%0s %0d",temp_string,DiiIds[i]);
        rpn++;
    end // for (int i=0; i<nDMIs; i++)				   
    `uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("%0s",temp_string), UVM_LOW)

    foreach(t_chiaiu_en[i]) begin
       `uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("t_chiaiu_en[%0d] = %0d", i, t_chiaiu_en[i]), UVM_MEDIUM)
    end
    
    active_numChiAiu = $countones(t_chiaiu_en);
    numChiAiu = active_numChiAiu;

    temp_string="";
    foreach(AiuIds[i]) begin
    int tempCmdCCR=0;
      foreach(DceIds[x]) begin
          aCredit_Cmd[AiuIds[i]][DceIds[x]] = ((act_cmd_skid_buf_size["DCE"][x]/AiuIds.size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DCE"][x]/AiuIds.size());

        tempCmdCCR = tempCmdCCR + 1;
        temp_string = $sformatf("%0saCredit_Cmd[%0d][%0d] %0d\n",temp_string,AiuIds[i],DceIds[x],aCredit_Cmd[AiuIds[i]][DceIds[x]]);

      end

      numCmdCCR = tempCmdCCR;
      tempCmdCCR=0;
      foreach(DmiIds[y]) begin
        
          aCredit_Cmd[AiuIds[i]][DmiIds[y]] = ((act_cmd_skid_buf_size["DMI"][y]/AiuIds.size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DMI"][y]/AiuIds.size());

        tempCmdCCR = tempCmdCCR + 1;
        temp_string = $sformatf("%0saCredit_Cmd[%0d][%0d] %0d\n",temp_string,AiuIds[i],DmiIds[y],aCredit_Cmd[AiuIds[i]][DmiIds[y]]);
      end

      if(tempCmdCCR>numCmdCCR) numCmdCCR = tempCmdCCR;
      tempCmdCCR=0;
      foreach(DiiIds[z]) begin
        if(z<(DiiIds.size()-1)) begin
            
              aCredit_Cmd[AiuIds[i]][DiiIds[z]] = ((act_cmd_skid_buf_size["DII"][z]/AiuIds.size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DII"][z]/AiuIds.size());
        end else begin
           
                //Dividing sys_dii credits between first chiaiu and first ioaiu
            <% if(numIoAiu>0) {%>
            if(i==(<%=numChiAiu%>+<%=csrAccess_ioaiu%>))  aCredit_Cmd[AiuIds[i]][DiiIds[z]] = ((act_cmd_skid_buf_size["DII"][z]/2) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DII"][z]/2);
            <% } %>
            <% if(numChiAiu>0) {%>
            if(i==<%=csrAccess_chiaiu%>) aCredit_Cmd[AiuIds[i]][DiiIds[z]] = ((act_cmd_skid_buf_size["DII"][z]/2) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DII"][z]/2);
            <% } %>
        end

        tempCmdCCR = tempCmdCCR + 1;
        temp_string = $sformatf("%0saCredit_Cmd[%0d][%0d] %0d\n",temp_string,AiuIds[i],DiiIds[z],aCredit_Cmd[AiuIds[i]][DiiIds[z]]);
      end

      if(tempCmdCCR>numCmdCCR) numCmdCCR = tempCmdCCR;
    end

    foreach(DceIds[i]) begin
      foreach(DmiIds[p]) begin
        aCredit_Mrd[DceIds[i]][DmiIds[p]] = ((act_mrd_skid_buf_size["DMI"][p]/DceIds.size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_mrd_skid_buf_size["DMI"][p]/DceIds.size());
        if(i<1) numMrdCCR = numMrdCCR+1;
      end
        //temp_string = $sformatf("%0saCredit_Mrd[%0d][%0d] %0d\n",temp_string,DceIds[i],DmiIds[p],aCredit_Mrd[DceIds[i]][DmiIds[p]]);
      //numMrdCCR = (numMrdCCR%4==0)?(numMrdCCR/4):((numMrdCCR/4)+1);
    end

    `uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("numMrdCCR %0d numCmdCCR %0d active_numChiAiu %0d active_numIoAiu %0d",numMrdCCR,numCmdCCR,active_numChiAiu,active_numIoAiu),UVM_NONE)
    `uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt",$sformatf("%0s",temp_string),UVM_NONE)

    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
      for(int x=0;x<numCmdCCR;x++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUCCR0.get_offset()<%} else {%>m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUCCR0.get_offset()<%}%>; ;
        addr[11:0] = addr[11:0] + (x*4);
        read_csr(addr,data);
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg AIUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        data[4:0]   = aCredit_Cmd[AiuIds[i]][DceIds[x]];
        data[12:8]  = aCredit_Cmd[AiuIds[i]][DmiIds[x]];
        data[20:16] = aCredit_Cmd[AiuIds[i]][DiiIds[x]];
        data[31:24] = 8'hE0;
        write_csr(addr,data);
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("Writing rpn %0d Reg AIUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        read_csr(addr,data);
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg AIUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
      end
      rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    cur_rpn = rpn; ;
    for(int i=0; i<nDCEs; i++) begin
      for(int x=0;x<numMrdCCR;x++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] =  m_regs.dce0.DCEUCCR0.get_offset();
        addr[11:0] = addr[11:0] + (x*4);
        read_csr(addr,data);
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg DCEUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        data[4:0]   = aCredit_Mrd[DceIds[i]][DmiIds[x]];
        data[15:8]  = 8'hE0;
        data[23:16] = 8'hE0;
        data[31:24] = 8'hE0;
        write_csr(addr,data);
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("Writing rpn %0d Reg DCEUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        read_csr(addr,data);
        `uvm_info("CHIAIU_ENUM_BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg DCEUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
      end
      rpn++;
    end // for (int i=0; i<nDCEs; i++)
end
    // svt_chi_item_helper::dis_addr_range_constraint = 0;
    svt_chi_item_helper::en_ncore_sys_mem_addr_range_cnstr();
`uvm_info("CHIAIU_ENUM_BOOT_SEQ",$sformatf("Leaving Boot Sequence"),UVM_NONE)
#600ns;
svt_chi_item_helper::disable_boot_addr();
endtask:enum_boot_seq

task write_chk(input <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::addr_width_t addr, bit[31:0] data, bit check=0);
    bit [31:0] rdata;
    write_csr(addr,data);
    if(check) begin
        read_csr(addr,rdata);
        if(!($test$plusargs("chi_csr_ns_access"))) begin
          if(data != rdata) begin
	    `uvm_error("write_chk", $sformatf("Read data error  Addr: 0x%0h , Wdata: 0x%0h , Rdata: 0x%0h", addr, data, rdata))
          end
        end
    end
endtask : write_chk

task write_csr(input   <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::addr_width_t addr, bit[31:0] data);
    chi_subsys_pkg::chi_subsys_noncoh_seq svt_reg_seq;
    bit directed_is_non_secure_access;
    svt_reg_seq = chi_subsys_pkg::chi_subsys_noncoh_seq::type_id::create("svt_reg_seq");
    `uvm_info(get_name(),$psprintf("Starting write_csr, addr 0x%16h data 0x%8h",addr,data),UVM_NONE)
    svt_reg_seq.sequence_length = 1;
    svt_reg_seq.directed_data_mailbox.put(data);
    svt_reg_seq.randomize_with_directed_data = 1;
    svt_reg_seq.use_directed_addr = 1;
    svt_reg_seq.directed_addr_mailbox.put(addr);
    svt_reg_seq.use_directed_snp_attr = 0;
    svt_reg_seq.use_directed_mem_attr = 0;
    svt_reg_seq.use_directed_allocate_in_cache = 0;
    svt_reg_seq.use_directed_data_size = 0;
    svt_reg_seq.use_directed_byte_enable = 0;
    svt_reg_seq.readnosnp_wt = 0;
    svt_reg_seq.writenosnpfull_wt = 0;
    svt_reg_seq.writenosnpptl_wt = 1;
    svt_reg_seq.blocking_mode = 1;
    svt_reg_seq.use_directed_non_secure_access = 1;
    directed_is_non_secure_access = ($test$plusargs("chi_csr_ns_access")) ? 1 : 0;;
    svt_reg_seq.directed_is_non_secure_access_mailbox.put(directed_is_non_secure_access);
    svt_reg_seq.seq_mem_attr_is_early_wr_ack_allowed = 0;
    svt_reg_seq.seq_mem_attr_mem_type = 1;
    svt_reg_seq.seq_order_type = svt_chi_transaction::REQ_EP_ORDERING_REQUIRED;
    svt_reg_seq.k_decode_err_illegal_acc_format_test_unsupported_size = k_decode_err_illegal_acc_format_test_unsupported_size;
    svt_reg_seq.start(rn_xact_seqr) ;
    `uvm_info(get_name(),$psprintf("Ending write_csr"),UVM_NONE)
    //`uvm_info(get_name(),$psprintf("Rresp_Error on RSP Channel : %0x",svt_reg_seq.rn_xact.response_resp_err_status),UVM_MEDIUM)
endtask : write_csr

task read_csr(input   <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::addr_width_t addr, output bit[31:0] data);
    chi_subsys_pkg::chi_subsys_rd_txn_directed_seq svt_reg_seq;
    <%=chi_bfm_types_pkg_prefix%>_chi_bfm_types_pkg::addr_width_t aiuidr_addr;

    svt_reg_seq = chi_subsys_pkg::chi_subsys_rd_txn_directed_seq::type_id::create("svt_reg_seq");
    `uvm_info(get_name(),$psprintf("Starting read_csr, addr 0x%16h",addr),UVM_NONE)
    svt_reg_seq.sequence_length = 1;
    svt_reg_seq.enable_outstanding = 0;
    svt_reg_seq.seq_xact_type = svt_chi_transaction::READNOSNP;
    svt_reg_seq.min_addr = addr;
    svt_reg_seq.max_addr = addr;
    svt_reg_seq.hn_addr_rand_type = svt_chi_rn_transaction_base_sequence::DIRECTED_ADDR_RANGE_RAND_TYPE;
    svt_reg_seq.by_pass_read_data_check = 1;
    svt_reg_seq.use_seq_is_non_secure_access = 1;
    svt_reg_seq.seq_is_non_secure_access = ($test$plusargs("chi_csr_ns_access")) ? 1 : 0;;
    svt_reg_seq.seq_mem_attr_is_early_wr_ack_allowed = 0;
    svt_reg_seq.seq_mem_attr_mem_type = 1;
    svt_reg_seq.seq_order_type = svt_chi_transaction::REQ_EP_ORDERING_REQUIRED;
    svt_reg_seq.k_decode_err_illegal_acc_format_test_unsupported_size = k_decode_err_illegal_acc_format_test_unsupported_size;
    svt_reg_seq.start(rn_xact_seqr) ;
    data = svt_reg_seq.read_tran.data;
    aiuidr_addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUIDR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUIDR.get_offset()<%}%>;
    if($test$plusargs("chi_csr_ns_access")) begin
      if(addr[11:0] != aiuidr_addr[11:0]) begin
         if(svt_reg_seq.read_tran.data_resp_err_status[0] != svt_chi_transaction::DATA_ERROR) begin
            `uvm_error(get_name(),$psprintf("Expecting a DATA_ERROR Rresp_err, Received  %0p", svt_reg_seq.read_tran.data_resp_err_status))
         end
      end
    end

    `uvm_info(get_name(),$psprintf("Ending read_csr, addr 0x%16h data 0x%8h",addr,data),UVM_NONE)
endtask : read_csr

<% } %>
endclass: chi_subsys_vseq
