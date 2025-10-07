////////////////////////////////////////////////////////////
//                                                        //
//Description: provides credits number to each AIU        //
//             agents.                                    //
//                                                        //
//File:        concerto_legacy_emu_tasks_pkg.sv              //
//                                                        //
////////////////////////////////////////////////////////////
<%

let numChiAiu = 0; // Number of CHI AIUs
let numACEAiu = 0; // Number of ACE AIUs
let numIoAiu = 0; // Number of IO AIUs
let numIoAiu_mpu =0;//Number of IO AIUS including mpu cores
let numCAiu = 0; // Number of Coherent AIUs
let numNCAiu = 0; // Number of Non-Coherent AIUs
let found_csr_access_ioaiu =0;
let found_csr_access_chi =0;
let csrAccess_ioaiu;
let csrAccess_chiaiu;
let idxIoAiuWithPC = obj.nAIUs; // To get valid index of NCAIU with ProxyCache. Initialize to nAIUs
let numDmiWithSMC = 0; // Number of DMIs with SystemMemoryCache
let idxDmiWithSMC = 0; // To get valid index of DMI with SystemMemoryCache
let numDmiWithSP = 0; // Number of DMIs with ScratchPad memory
let idxDmiWithSP = 0; // To get valid index of DMIs with ScratchPad memory
let numDmiWithWP = 0; // Number of DMIs with WayPartitioning
let idxDmiWithWP = 0; // To get valid index of DMIs with WayPartitioning
let initiatorAgents   = obj.AiuInfo.length ;
let aiu_NumCores = [];
let numAiuRpns = 0;   //Total AIU RPN's
let chiaiu0;  // strRtlNamePrefix of chiaiu0
let ioaiu0;  // strRtlNamePrefix of chiaiu0
let aceaiu0;  // strRtlNamePrefix of aceaiu0
let _blkid = [];
let _blktype = [];
let _blksuffix = [];
let _blk   = [];
let pidx = 0;
let ridx = 0;
let chiaiu_idx = 0;
let ioaiu_idx = 0;
const aiu_axiInt = [];
const aiu_axiIntLen = [];
const aiu_axiInt2 = [];
let aiu_rpn = [];
for(pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn[0];
   } else {
       aiu_NumCores[pidx]    = 1;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn;
   }
 }
for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       _blk[pidx]   = obj.AiuInfo[pidx];
       if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) {
       _blkid[pidx] = 'chiaiu' + chiaiu_idx;
       _blksuffix[pidx] = "_0";
       _blktype[pidx]   = 'chiaiu';
       chiaiu_idx++;
       } else {
       _blkid[pidx] = 'ioaiu' + ioaiu_idx;
       _blksuffix[pidx] = "_0";
       _blktype[pidx]   = 'ioaiu';
       ioaiu_idx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _blkid[ridx] = 'dce' + pidx;
       _blktype[ridx]   = 'dce';
       _blksuffix[ridx] = "";
       _blk[ridx]   = obj.DceInfo[pidx];
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _blkid[ridx] = 'dmi' + pidx;
       _blktype[ridx]   = 'dmi';
       _blksuffix[ridx] = "";
       _blk[ridx]   = obj.DmiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _blkid[ridx] = 'dii' + pidx;
       _blk[ridx]   = 'dii';
       _blksuffix[ridx] = "";
       _blk[ridx]   = obj.DiiInfo[pidx];
   }
   
   var nALLs = ridx+1; 

for(pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
   } else {
       aiu_NumCores[pidx]    = 1;
   }
 }

for(pidx = 0; pidx < obj.nAIUs; pidx++) {
    if( obj.AiuInfo[pidx].fnNativeInterface == "CHI-A" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" ||
        obj.AiuInfo[pidx].fnNativeInterface == "CHI-C" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-D" ||
        obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")
    {
    // CLU TMP COMPILE FIX CONC-11383    if ((found_csr_access_chi==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_chi_idx = numChiAiu;
            csrAccess_chiaiu = numChiAiu;
            found_csr_access_chi = 1;
    //        }
        if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
        numChiAiu = numChiAiu + 1;numCAiu++ ; 
    } else {
      
    // CLU TMP COMPILE FIX CONC-11383    if ((found_csr_access_ioaiu==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_io_idx = numIoAiu;
            csrAccess_ioaiu = numIoAiu;
            found_csr_access_ioaiu = 1;
    //        }
    if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       numIoAiu_mpu    += obj.AiuInfo[pidx].interfaces.axiInt.length;
    } else {
       numIoAiu_mpu++;
    }            
        numIoAiu = numIoAiu + 1;

         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { 
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
for(pidx = 0; pidx < obj.nAIUs; pidx++) {
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


for(pidx = 0; pidx < obj.nDMIs; pidx++) {
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
var regPrefixName = function() {
                                if (obj.BlockId.charAt(0)=="d")
                                    {return obj.BlockId.match(/[a-z]+/i)[0].toUpperCase();} //dmi,dii,dce,dve => DMI,DII,DVE 
                                if ((obj[obj.AgentInfoName][obj.Id].fnNativeInterface == 'CHI-A')||(obj[obj.AgentInfoName][obj.Id].fnNativeInterface == 'CHI-B')) 
                                    {return "CAIU";}
                                return "XAIU"; // by default
                                };
%>

<%function generateRegPath(regName) {
    if(obj.DutInfo.nNativeInterfacePorts > 1) {
        return 'm_regs.'+obj.DutInfo.strRtlNamePrefix+'_0.'+regName;
    } else {
        return 'm_regs.'+obj.DutInfo.strRtlNamePrefix+'.'+regName;
    }
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
                            if(item.fnNativeInterface === "CHI-A" || item.fnNativeInterface === "CHI-B") {
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
                            if(!(item.fnNativeInterface === "CHI-A" || item.fnNativeInterface === "CHI-B")) {
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


let Dvm_NUnitIds = [] ;
for (const o of obj.AiuInfo) {
    if(o.cmpInfo.nDvmSnpInFlight > 0) {
        Dvm_NUnitIds.push(o.nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}

var SnoopEn = 0;
   for(let i in Dvm_NUnitIds) {
      SnoopEn |= 1 << Dvm_NUnitIds[i];
   }

%>

typedef class concerto_base_test; // PARENT

class concerto_legacy_emu_tasks extends uvm_component;

  `uvm_component_utils(concerto_legacy_emu_tasks)

   concerto_base_test  base_test;

parameter VALID_MAX_CREDIT_VALUE = 31;

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

int act_cmd_skid_buf_size[string][];//array to hold act. values of skid buffer size of each DMI/DCE/DII. act_cmd_skid_buf_size[DMI/DCE/DII][skid_buf_size] 
int act_mrd_skid_buf_size[string][];
int act_cmd_skid_buf_arb[string][];//array to hold act. values of skid buffer arb of each DMI/DCE/DII. act_cmd_skid_buf_arb[DMI/DCE/DII][skid_buf_size] 
int act_mrd_skid_buf_arb[string][];
int exp_cmd_skid_buf_size[string][];//array to hold act. values of skid buffer size of each DMI/DCE/DII. exp_cmd_skid_buf_size[DMI/DCE/DII][skid_buf_size] 
int exp_mrd_skid_buf_size[string][];
int exp_cmd_skid_buf_arb[string][];//array to hold act. values of skid buffer arb of each DMI/DCE/DII. exp_cmd_skid_buf_arb[DMI/DCE/DII][skid_buf_size] 
int exp_mrd_skid_buf_arb[string][];
int temp_dii_buf_size;
bit en_credit_alloc =1;//TODO dont forget should be 1
//set env 
concerto_test_cfg test_cfg;  
concerto_env_pkg::concerto_env_cfg m_concerto_env_cfg;  
concerto_env_pkg::concerto_env     m_concerto_env;
//set credit variable
concerto_test_cfg::t_aCredit aCredit_Cmd;
concerto_test_cfg::t_aCredit aCredit_Mrd;
 
concerto_args      m_args;

// plusarg management
string     chiaiu_en_str[];
string     ioaiu_en_str[];
string     chiaiu_en_arg;
string     ioaiu_en_arg;
bit [<%=numChiAiu%>-1:0]t_chiaiu_en;
bit [<%=numIoAiu%>-1:0]t_ioaiu_en;
int chiaiu_en[int];
int ioaiu_en[int];

// some info from JSON
int numChiAiu=<%=numChiAiu%>;
int numIoAiu=<%=numIoAiu%>;
int active_numChiAiu=0;
int active_numIoAiu=0;
int numCmdCCR;
int numMrdCCR;
// System Census 
bit [7:0] nAIUs; // Max 128
bit [5:0] nDCEs; // Max 32
bit [5:0] nDMIs; // Max 32
bit [5:0] nDIIs; // Max 32 or nDIIs
bit       nDVEs; // Max 1
string block[3];

//boot selection 
bit boot_from_ioaiu=1;  // !!!! ONLY BOOT IOAIU !!! CHI not supported!!!!

//rpn page selection 
bit [7:0] rpn;
bit [7:0] cur_rpn;
//connectivity check 
bit en_connectivity_cmd_check;
bit en_connectivity_mrd_check;
int AiuIds[];
int DceIds[];
int DmiIds[];
int DiiIds[];
int csrAccess_ioaiu=0;
int csrAccess_chiaiu=0;
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

static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();

<% var cidx=0;
var ioidx=0;
for(pidx=0; pidx<obj.nAIUs; pidx++) {
if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')) { 
if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache))) { %>
    static uvm_event ev_sysco_fsm_state_change_<%=obj.AiuInfo[pidx].FUnitId%> = ev_pool.get("ev_sysco_fsm_state_change_<%=obj.AiuInfo[pidx].FUnitId%>");
<% } ioidx++; }
else { %>
    static uvm_event ev_toggle_sysco_chiaiu<%=cidx%> = ev_pool.get("ev_toggle_sysco_chiaiu<%=cidx%>");
<% cidx++; }
} %>
  // use in case of legacy boot
  <% if (numChiAiu) {%> 
`ifdef USE_VIP_SNPS_CHI //existing flow will not run when USE_VIP_SNPS set
   chi_subsys_pkg::chi_subsys_vseq         m_snps_chi0_vseq;
   chi_aiu_unit_args_pkg::chi_aiu_unit_args m_chi0_args;
`endif
   <% } %>
//constructor
  extern function new(string s = "concerto_legacy_emu_tasks", uvm_component parent=null);
  extern virtual function void build_phase(uvm_phase  phase);

//functions
  extern virtual task exec_inhouse_boot_seq(uvm_phase phase);
  extern function uvm_reg_data_t mask_data(int lsb, int msb);
  extern function void parse_str(output string out[], input byte separator, input string in);
  extern function void credit_alloc(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);//this function compute the amount of credit to allocate to each aiu
  extern function void credit_printer(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);//this function compute the amount of credit to allocate to each aiu
  extern function void set_crdt_cfg();// function to get concerto_env.cfg.tCreditXXX must be by DB
  extern function void get_crdt_cfg(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);// function to get concerto_env.cfg.tCreditXXX must be by DB
  <% for(let idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
  if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) {
// CLU TMP COMPILE FIX CONC-11383     if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
  extern  task boot_sw_crdt<%=qidx%>();
    // fucntion to overwrite credit 
  extern task overwrite_credit<%=qidx%>(int credit);
  `ifdef VCS
  extern task check_csr<%=qidx%>();//this function will check skid buffer size 
  `else
  extern function void check_csr<%=qidx%>();//this function will check skid buffer size 
  `endif
  extern task set_csr_crdt<%=qidx%>(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);// function to get concerto_env.cfg.tCreditXXX must be by DB
  extern function void crdt_adapter<%=qidx%>(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);// this function adapt credit format from fsys to block format and update block SB 
  extern function void crdt_ioaiu_adapter<%=qidx%>(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);
  extern task read_csr_<%=qidx%>(uvm_reg_field field, output uvm_reg_data_t fieldVal);
  extern task write_csr_<%=qidx%>(uvm_reg_field field, uvm_reg_data_t wr_data);
  extern task write_chk<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data, bit check=0, bit nonblocking=0);
  extern task write_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data,bit nonblocking=0);
  extern task read_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, output bit[31:0]data);
  ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer  m_ioaiu_vseqr<%=qidx%>[<%=aiu_NumCores[idx]%>];
 
  extern virtual task ioaiu_boot_seq<%=qidx%>(bit [31:0] agent_ids_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$], bit [31:0] wayvec_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$], bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[], int sp_ways[], int sp_size[], int aiu_qos_threshold[int], int dce_qos_threshold[int], int dmi_qos_threshold[int], int dmi_qos_rsved);

    <% //} 
    qidx++; }
    } %>
  
  bit en_rw_csr_from_ioaiu=1'b1;    

  uvm_domain       m_concerto_domain;
     
endclass: concerto_legacy_emu_tasks



function concerto_legacy_emu_tasks::new(string s = "concerto_legacy_emu_tasks", uvm_component parent = null);
  super.new(s,parent);


endfunction: new

function void concerto_legacy_emu_tasks::build_phase(uvm_phase phase);

    if(!$value$plusargs("dmiusmc_policy=%d",dmiusmc_policy))begin
       dmiusmc_policy = 0;
    end

    if(!$value$plusargs("update_cmd_disable=%d",update_cmd_disable))begin
       update_cmd_disable = 0;
    end

 if(!$value$plusargs("dce_qos_threshold=%s", dce_qos_threshold_arg)) begin
    <% for(pidx = 0 ; pidx < obj.nDCEs; pidx++) { %>
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
    <% for(pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
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

    if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", m_concerto_env_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end  
    if(!(uvm_config_db #(concerto_env)::get(uvm_root::get(), "", "m_env", m_concerto_env)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env object in UVM DB");
    end 
    if(!(uvm_config_db #(concerto_test_cfg)::get(uvm_root::get(), "", "test_cfg", test_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_test_cfg object in UVM DB");
    end 
     
    base_test = concerto_base_test'(this.get_parent());

    
endfunction : build_phase

function void concerto_legacy_emu_tasks::set_crdt_cfg();
  test_cfg.aCredit_Cmd = aCredit_Cmd;
  test_cfg.aCredit_Mrd = aCredit_Mrd;

endfunction: set_crdt_cfg

function void concerto_legacy_emu_tasks::get_crdt_cfg(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);

     foreach(AiuIds[i]) begin
           foreach(DceIds[j]) begin 
            aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[j]] = test_cfg.aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[j]];
          end
          foreach(DmiIds[k]) begin 
            aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[k]] = test_cfg.aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[k]];
          end
          foreach(DiiIds[p]) begin 
            aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[p]] = test_cfg.aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[p]];
          end                  
    end 
    foreach(DceIds[i]) begin
      foreach(DmiIds[p]) begin
        aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]= test_cfg.aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]];
      end
    end

endfunction: get_crdt_cfg



 <% for(let idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
  if (!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) {
// CLU TMP COMPILE FIX CONC-11383     if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
task concerto_legacy_emu_tasks::overwrite_credit<%=qidx%>(int credit);
bit [31:0] data;
string temp_string="";
uvm_reg_data_t fieldVal;
int aiu_NumCores[int];
int j;
int cnt_core;
ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;	

addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE ;
    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
      for(int x=0;x<numCmdCCR;x++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUCCR0.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUCCR0.get_offset()<%}%>;
        addr[11:0] = addr[11:0] + (x*4);
        //read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("set_credit sw_credit_mgr", $sformatf("overwriting credit by %0d credit ",credit), UVM_LOW)
        data[4:0]   = credit;
        data[12:8]  = credit;
        data[20:16] = credit;
        data[31:24] = 8'hE0;
        write_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
      end
      rpn++;

    end // for (int i=0; i<nAIUs; i++)		
endtask: overwrite_credit<%=qidx%>

function void concerto_legacy_emu_tasks::crdt_adapter<%=qidx%>(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);
//
string dce_credit_msg="";
int new_dce_credits;

//concerto_legacy_emu_tasks::get_crdt_cfg();


<% for(pidx = 0; pidx < obj.nDCEs; pidx++) { %>
      for(int x=0;x<numMrdCCR;x++) begin
        $sformat(dce_credit_msg, "dce%0d_dmi%0d_nMrdInFlight", DceIds[<%=pidx%>], DmiIds[x]);
        //new_dce_credits=m_concerto_env_cfg.aCredit_Mrd[DceIds[<%=pidx%>]]["DMI"][DmiIds[x]];
        new_dce_credits=aCredit_Mrd[DceIds[<%=pidx%>]]["DMI"][DmiIds[x]];
        if(m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.has_scoreboard)begin
          m_concerto_env.inhouse.m_dce<%=pidx%>_env.m_dce_scb.m_credits.scm_credit(dce_credit_msg, new_dce_credits);
        end
      end
<% } %>

// call ioaiu adapter
  if($test$plusargs("scm_use_ioaiu_adapter")) begin
    concerto_legacy_emu_tasks::crdt_ioaiu_adapter<%=qidx%>(AiuIds,DmiIds,DceIds,DiiIds);
  end
endfunction: crdt_adapter<%=qidx%>

function void concerto_legacy_emu_tasks::crdt_ioaiu_adapter<%=qidx%>(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);
//

//concerto_legacy_emu_tasks::get_crdt_cfg();
  <% for(ioaiu_idx = 0, pidx = 0 ; pidx < obj.nAIUs; pidx++) { 
     if(!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { 
      for(var core_idx=0; core_idx<aiu_NumCores[pidx]; core_idx++) { %>
        foreach(DceIds[j]) begin 
          if(m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].has_scoreboard)begin
            m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].dceCreditLimit[DceIds[j]]=int'(aCredit_Cmd[AiuIds[<%=ioaiu_idx%>]]["DCE"][DceIds[j]]);
          end 
        end
    

        foreach(DmiIds[k]) begin          
          if(m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].has_scoreboard)begin
            m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].dmiCreditLimit[DmiIds[k]]=int'(aCredit_Cmd[AiuIds[<%=ioaiu_idx%>]]["DMI"][DmiIds[k]]);
          end
        end

       foreach(DiiIds[p]) begin 
        if(m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].has_scoreboard)begin
          m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=core_idx%>].diiCreditLimit[DiiIds[p]]=int'(aCredit_Cmd[AiuIds[<%=ioaiu_idx%>]]["DII"][DiiIds[p]]);
        end
       end
<% } 
 ioaiu_idx++; }
 } %> 




endfunction: crdt_ioaiu_adapter<%=qidx%>




task concerto_legacy_emu_tasks::set_csr_crdt<%=qidx%>(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);
///
bit [31:0] data;
string temp_string="";
uvm_reg_data_t fieldVal;
int aiu_NumCores[int];
int j;
int cnt_core;
ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;	

<%for(pidx = 0; pidx < obj.nAIUs; pidx++) {%>
  aiu_NumCores[<%=pidx%>] =  <%=aiu_NumCores[pidx]%> ;
<%}%>
addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE ;
    rpn = 0; //chi_rpn;
    j =0;
    cnt_core=1;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
      for(int x=0;x<numCmdCCR;x++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUCCR0.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUCCR0.get_offset()<%}%>;
        addr[11:0] = addr[11:0] + (x*4);
        read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Reading rpn %0d Reg AIUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("programming credit aCredit_Cmd[%0d][DCE][%0d] = %0d ",i, DceIds[x], aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]]), UVM_MEDIUM)
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("programming credit aCredit_Cmd[%0d][DMI][%0d] = %0d ",i, DmiIds[x], aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[x]]), UVM_MEDIUM)
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("programming credit aCredit_Cmd[%0d][DII][%0d] = %0d ",i, DiiIds[x], aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[x]]), UVM_MEDIUM)
        data[4:0]   = aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]];
        data[12:8]  = aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[x]];
        data[20:16] = aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[x]];
        data[31:24] = 8'hE0;
        write_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Writing rpn %0d Reg AIUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Reading rpn %0d Reg AIUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        //check nonconnected register field 
        //#Check.FSYS.RDCCRstate.noconnection
        if (en_connectivity_cmd_check) begin 
          if (aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]] == 0 && data[7:5] != 7) begin 
            `uvm_error("set_csr_crdt check connectivity sw_credit_mgr",$sformatf(" DCE with FuinitId = %0d  is not connected to Aiu with FuinitId = %0d counterstate = %d should be 7 No Connection ",DceIds[x],AiuIds[i],data[7:5]))
          end
          if (aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[x]] == 0 && data[15:13] != 7) begin 
            `uvm_error("set_csr_crdt check connectivity sw_credit_mgr",$sformatf(" DMI with FuinitId = %0d  is not connected to Aiu with FuinitId = %0d counterstate = %d should be 7 No Connection ",DmiIds[x],AiuIds[i],data[15:13]))
          end  
          if (aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[x]] == 0 && data[23:21] != 7) begin 
            `uvm_error("set_csr_crdt check connectivity sw_credit_mgr",$sformatf(" DII with FuinitId = %0d  is not connected to Aiu with FuinitId = %0d counterstate = %d should be 7 No Connection ",DmiIds[x],AiuIds[i],data[23:21]))
          end   
        end    
      end
      rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    cur_rpn = rpn; ;
    for(int i=0; i< <%=obj.nDCEs%>; i++) begin
      for(int x=0;x<numMrdCCR;x++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] =  m_concerto_env.m_regs.dce0.DCEUCCR0.get_offset();
        addr[11:0] = addr[11:0] + (x*4);
        read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Reading rpn %0d Reg DCEUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        data[4:0]   = aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[x]];
        data[15:8]  = 8'hE0;
        data[23:16] = 8'hE0;
        data[31:24] = 8'hE0;
        write_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Writing rpn %0d Reg DCEUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
        `uvm_info("(set_credit sw_credit_mgr", $sformatf("Reading rpn %0d Reg DCEUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
      end
      rpn++;
    end // for (int i=0; i<nDCEs; i++)	
    //concerto_legacy_emu_tasks::set_crdt_cfg();
endtask: set_csr_crdt<%=qidx%>

`ifdef VCS
task concerto_legacy_emu_tasks::check_csr<%=qidx%>();
`else
function void concerto_legacy_emu_tasks::check_csr<%=qidx%>();
`endif
int AiuIds[];
int DceIds[];
int DmiIds[];
int DiiIds[];
bit [7:0] nAIUs; // Max 128
bit [5:0] nDCEs; // Max 32
bit [5:0] nDMIs; // Max 32
bit [5:0] nDIIs; // Max 32 or nDIIs
bit       nDVEs; // Max 1
string block[3];
int aiu_indx = 0;
int dce_indx = 0;
int dmi_indx = 0;
int dii_indx = 0;
//reg variables      
uvm_reg_data_t fieldVal;
bit [31:0] data;

`ifdef VCS
block = '{"DCE", "DMI", "DII"};
`else
block[3] = '{"DCE", "DMI", "DII"};
`endif

for (int i = 0 ; i < $size(block); i++) begin
  act_cmd_skid_buf_size[block[i]]=new[1];
  act_cmd_skid_buf_size[block[i]][0]=0;////Default value First index zero. If nDCE/DII/DMI>1, It will be equal to DCE0/DMI0/DII0 skidbufsize and then skidbufsize of rest of DCEs will be filled in rest of elements
  act_cmd_skid_buf_arb[block[i]]=new[1];
  act_cmd_skid_buf_arb[block[i]][0]=0;////Default value First index zero. If nDCE/DII/DMI>1, It will be equal to DCE0/DMI0/DII0 skidbufarb and then skidbufarb of rest of DCEs will be filled in rest of elements
  exp_cmd_skid_buf_size[block[i]]=new[1];
  exp_cmd_skid_buf_size[block[i]][0]=0;////Default value First index zero. If nDCE/DII/DMI>1, It will be equal to DCE0/DMI0/DII0 skidbufsize and then skidbufsize of rest of DCEs will be filled in rest of elements
  exp_cmd_skid_buf_arb[block[i]]=new[1];
  exp_cmd_skid_buf_arb[block[i]][0]=0;////Default value First index zero. If nDCE/DII/DMI>1, It will be equal to DCE0/DMI0/DII0 skidbufarb and then skidbufarb of rest of DCEs will be filled in rest of elements
  if (block[i]=="DMI") begin
   act_mrd_skid_buf_size[block[i]] = new[1];
   act_mrd_skid_buf_size[block[i]][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufsize and then skidbufsize of rest of DMIs will be filled in rest of elements
   act_mrd_skid_buf_arb[block[i]] = new[1];
   act_mrd_skid_buf_arb[block[i]][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufarb and then skidbufarb of rest of DMIs will be filled in rest of elements
   exp_mrd_skid_buf_size[block[i]] = new[1];
   exp_mrd_skid_buf_size[block[i]][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufsize and then skidbufsize of rest of DMIs will be filled in rest of elements
   exp_mrd_skid_buf_arb[block[i]] = new[1];
   exp_mrd_skid_buf_arb[block[i]][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufarb and then skidbufarb of rest of DMIs will be filled in rest of elements
      
  end

end

  
  read_csr_<%=qidx%>(m_concerto_env.m_regs.get_reg_by_name("GRBUNRRUCR").get_field_by_name("nAIUs"), fieldVal);//data[ 7: 0];
  nAIUs = int'(fieldVal);
  read_csr_<%=qidx%>(m_concerto_env.m_regs.get_reg_by_name("GRBUNRRUCR").get_field_by_name("nDCEs"), fieldVal);//data[ 7: 0];
  nDCEs = int'(fieldVal);
  read_csr_<%=qidx%>(m_concerto_env.m_regs.get_reg_by_name("GRBUNRRUCR").get_field_by_name("nDMIs"), fieldVal);//data[ 7: 0];
  nDMIs = int'(fieldVal);
  read_csr_<%=qidx%>(m_concerto_env.m_regs.get_reg_by_name("GRBUNRRUCR").get_field_by_name("nDIIs"), fieldVal);//data[ 7: 0];
  nDIIs = int'(fieldVal);
  `uvm_info("check_csr",$sformatf("nAIUs:%0d nDCEs:%0d nDMIs:%0d nDIIs:%0d",nAIUs,nDCEs,nDMIs,nDIIs),UVM_NONE)

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

<%var tempidx = 0;%>
<%for(var tempidx = 0; tempidx < obj.nDCEs; tempidx++) {%>
      exp_cmd_skid_buf_size["DCE"][<%=tempidx%>] = <%=obj.DceInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DCE"][<%=tempidx%>]  = <%=obj.DceInfo[tempidx].nCMDSkidBufArb%>;
<%}%>

<%var tempidx = 0;%>
<%for(var tempidx = 0; tempidx < obj.nDMIs; tempidx++) {%>
      exp_cmd_skid_buf_size["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DMI"][<%=tempidx%>]  = <%=obj.DmiInfo[tempidx].nCMDSkidBufArb%>;
      exp_mrd_skid_buf_size["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nMrdSkidBufSize%>;
      exp_mrd_skid_buf_arb["DMI"][<%=tempidx%>]  = <%=obj.DmiInfo[tempidx].nMrdSkidBufArb%>;
<%}%>

<%var tempidx = 0;%>
<%for(var tempidx = 0; tempidx < obj.nDIIs; tempidx++) {%>
      exp_cmd_skid_buf_size["DII"][<%=tempidx%>] = <%=obj.DiiInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DII"][<%=tempidx%>]  = <%=obj.DiiInfo[tempidx].nCMDSkidBufArb%>;
<%}%>
//DCE skid buf size check 
<% for(var pidx_dce = 0; pidx_dce < obj.nDCEs; pidx_dce++) { %>
  dce_indx=<%=pidx_dce%>;
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.DCEUSBSIR.get_field_by_name("SkidBufArb"), fieldVal);
  act_cmd_skid_buf_arb["DCE"][dce_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DCE REG] Reading  DCEUSBSIR SkidBufArb:act_cmd_skid_buf_arb[DCE][%0d]=%0d ",dce_indx,act_cmd_skid_buf_arb["DCE"][dce_indx]), UVM_LOW)
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.DCEUSBSIR.get_field_by_name("SkidBufSize"), fieldVal);
  act_cmd_skid_buf_size["DCE"][dce_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DCE REG] Reading  DCEUSBSIR SkidBufSize:act_cmd_skid_buf_size[DCE][%0d]=%0d ",dce_indx,act_cmd_skid_buf_size["DCE"][dce_indx]), UVM_LOW)
<%}%>

    if(exp_cmd_skid_buf_size["DCE"].size != act_cmd_skid_buf_size["DCE"].size) begin
        `uvm_error("check_csr sw_credit_mgr",$sformatf("[DCE] exp_cmd_skid_buf_size[DCE].size %0d != act_cmd_skid_buf_size[DCE].size %0d",exp_cmd_skid_buf_size["DCE"].size,act_cmd_skid_buf_size["DCE"].size))
    end
    foreach(exp_cmd_skid_buf_size["DCE"][temp]) begin
        if(exp_cmd_skid_buf_size["DCE"][temp]!= act_cmd_skid_buf_size["DCE"][temp]) begin
            `uvm_error("check_csr sw_credit_mgr",$sformatf("[DCE] exp_cmd_skid_buf_size[DCE][%0d] %0d != act_cmd_skid_buf_size[DCE][%0d] %0d",temp,exp_cmd_skid_buf_size["DCE"][temp],temp,act_cmd_skid_buf_size["DCE"][temp]))
        end
        if(exp_cmd_skid_buf_arb["DCE"][temp]!= act_cmd_skid_buf_arb["DCE"][temp]) begin
            `uvm_error("check_csr sw_credit_mgr",$sformatf("[DCE] exp_cmd_skid_buf_arb[DCE][%0d] %0d != act_cmd_skid_buf_arb[DCE][%0d] %0d",temp,exp_cmd_skid_buf_arb["DCE"][temp],temp,act_cmd_skid_buf_arb["DCE"][temp]))
        end
    end
//DMI skid buf chekc
<% for(var pidx_dmi = 0; pidx_dmi < obj.nDMIs; pidx_dmi++) { %>
      dmi_indx=<%=pidx_dmi%>;
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("MRDSBSIR").get_field_by_name("SkidBufArb"), fieldVal);
  act_mrd_skid_buf_arb["DMI"][dmi_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DMI REG] Reading  MRDSBSIR act_mrd_skid_buf_arb[DMI][%0d]=%0d ",dmi_indx,act_mrd_skid_buf_arb["DMI"][dmi_indx]), UVM_LOW)
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("MRDSBSIR").get_field_by_name("SkidBufSize"), fieldVal);
  act_mrd_skid_buf_size["DMI"][dmi_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DMI REG] Reading  MRDSBSIR SkidBufSize:act_mrd_skid_buf_size[DMI][%0d]=%0d ",dmi_indx,act_mrd_skid_buf_size["DMI"][dmi_indx]), UVM_LOW)

  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("CMDSBSIR").get_field_by_name("SkidBufArb"), fieldVal);
  act_cmd_skid_buf_arb["DMI"][dmi_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DMI REG] Reading  CMDSBSIR act_cmd_skid_buf_arb[DMI][%0d]=%0d ",dmi_indx,act_cmd_skid_buf_arb["DMI"][dmi_indx]), UVM_LOW)
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("CMDSBSIR").get_field_by_name("SkidBufSize"), fieldVal);
  act_cmd_skid_buf_size["DMI"][dmi_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DMI REG] Reading  CMDSBSIR SkidBufSize:act_cmd_skid_buf_size[DMI][%0d]=%0d ",dmi_indx,act_cmd_skid_buf_size["DMI"][dmi_indx]), UVM_LOW)
<%}%>
//check
  if(exp_cmd_skid_buf_size["DMI"].size != act_cmd_skid_buf_size["DMI"].size) begin
      `uvm_error("check_csr sw_credit_mgr",$sformatf("[DMI] exp_cmd_skid_buf_size[DMI].size %0d != act_cmd_skid_buf_size[DMI].size %0d",exp_cmd_skid_buf_size["DMI"].size,act_cmd_skid_buf_size["DMI"].size))
  end
  foreach(exp_cmd_skid_buf_size["DMI"][temp]) begin
      if(exp_cmd_skid_buf_size["DMI"][temp]!= act_cmd_skid_buf_size["DMI"][temp]) begin
          `uvm_error("check_csr sw_credit_mgr",$sformatf("[DMI] exp_cmd_skid_buf_size[DMI][%0d] %0d != act_cmd_skid_buf_size[DMI][%0d] %0d",temp,exp_cmd_skid_buf_size["DMI"][temp],temp,act_cmd_skid_buf_size["DMI"][temp]))
      end
      if(exp_cmd_skid_buf_arb["DMI"][temp]!= act_cmd_skid_buf_arb["DMI"][temp]) begin
          `uvm_error("check_csr sw_credit_mgr",$sformatf("[DMI] exp_cmd_skid_buf_arb[DMI][%0d] %0d != act_cmd_skid_buf_arb[DMI][%0d] %0d",temp,exp_cmd_skid_buf_arb["DMI"][temp],temp,act_cmd_skid_buf_arb["DMI"][temp]))
      end
  end
  if(exp_mrd_skid_buf_size["DMI"].size != act_mrd_skid_buf_size["DMI"].size) begin
      `uvm_error("check_csr sw_credit_mgr",$sformatf("[DMI] exp_mrd_skid_buf_size[DMI].size %0d != act_mrd_skid_buf_size[DMI].size %0d",exp_mrd_skid_buf_size["DMI"].size,act_mrd_skid_buf_size["DMI"].size))
  end
  foreach(exp_mrd_skid_buf_size["DMI"][temp]) begin
      if(exp_mrd_skid_buf_size["DMI"][temp]!= act_mrd_skid_buf_size["DMI"][temp]) begin
          `uvm_error("check_csr sw_credit_mgr",$sformatf("[DMI] exp_mrd_skid_buf_size[DMI][%0d] %0d != act_mrd_skid_buf_size[DMI][%0d] %0d",temp,exp_mrd_skid_buf_size["DMI"][temp],temp,act_mrd_skid_buf_size["DMI"][temp]))
      end
      if(exp_mrd_skid_buf_arb["DMI"][temp]!= act_mrd_skid_buf_arb["DMI"][temp]) begin
          `uvm_error("check_csr sw_credit_mgr",$sformatf("[DMI] exp_mrd_skid_buf_arb[DMI][%0d] %0d != act_mrd_skid_buf_arb[DMI][%0d] %0d",temp,exp_mrd_skid_buf_arb["DMI"][temp],temp,act_mrd_skid_buf_arb["DMI"][temp]))
      end
  end
//end //for(int i=0; i<nDMIs; i++)

<% for(var pidx_dii = 0; pidx_dii < obj.nDIIs; pidx_dii++) { %>
    //for(int i=0; i<nDIIs; i++) begin
      dii_indx=<%=pidx_dii%>;
 // read DII skiid buffer sizes
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DiiInfo[pidx_dii].strRtlNamePrefix%>.get_reg_by_name("DIIUSBSIR").get_field_by_name("SkidBufSize"), fieldVal);
  act_cmd_skid_buf_size["DII"][dii_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DII REG] Reading  DIIUSBSIR SkidBufSize:act_cmd_skid_buf_size[DII][%0d]=%0d fieldVal = %0d",dii_indx,act_cmd_skid_buf_size["DII"][dii_indx],fieldVal), UVM_LOW)
  read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DiiInfo[pidx_dii].strRtlNamePrefix%>.get_reg_by_name("DIIUSBSIR").get_field_by_name("SkidBufArb"), fieldVal);
   act_cmd_skid_buf_arb["DII"][dii_indx] = int'(fieldVal);  
  `uvm_info("check_csr sw_credit_mgr", $sformatf("[DII REG] Reading  DIIUSBSIR SkidBufArb:act_cmd_skid_buf_arb[DII][%0d]=%0d fieldVal = %0d",dii_indx,act_cmd_skid_buf_arb["DII"][dii_indx],fieldVal), UVM_LOW)

<%}%>
    if(exp_cmd_skid_buf_size["DII"].size != act_cmd_skid_buf_size["DII"].size) begin
        `uvm_error("check_csr sw_credit_mgr",$sformatf("[DII] exp_cmd_skid_buf_size[DII].size %0d != act_cmd_skid_buf_size[DII].size %0d",exp_cmd_skid_buf_size["DII"].size,act_cmd_skid_buf_size["DII"].size))
    end
    foreach(exp_cmd_skid_buf_size["DII"][temp]) begin
        if(exp_cmd_skid_buf_size["DII"][temp]!= act_cmd_skid_buf_size["DII"][temp]) begin
            `uvm_error("check_csr sw_credit_mgr",$sformatf("[DII] exp_cmd_skid_buf_size[DII][%0d] %0d != act_cmd_skid_buf_size[DII][%0d] %0d",temp,exp_cmd_skid_buf_size["DII"][temp],temp,act_cmd_skid_buf_size["DII"][temp]))
        end
        if(exp_cmd_skid_buf_arb["DII"][temp]!= act_cmd_skid_buf_arb["DII"][temp]) begin
            `uvm_error("check_csr sw_credit_mgr",$sformatf("[DII] exp_cmd_skid_buf_arb[DII][%0d] %0d != act_cmd_skid_buf_arb[DII][%0d] %0d",temp,exp_cmd_skid_buf_arb["DII"][temp],temp,act_cmd_skid_buf_arb["DII"][temp]))
        end
    end
`ifdef VCS
endtask:check_csr<%=qidx%> 
`else
endfunction:check_csr<%=qidx%> 
`endif

task   concerto_legacy_emu_tasks::boot_sw_crdt<%=qidx%>();
int AiuIds[];
int DceIds[];
int DmiIds[];
int DiiIds[];
bit [7:0] nAIUs; // Max 128
bit [5:0] nDCEs; // Max 32
bit [5:0] nDMIs; // Max 32
bit [5:0] nDIIs; // Max 32 or nDIIs
bit       nDVEs; // Max 1
string block[3];
int aiu_indx = 0;
int dce_indx = 0;
int dmi_indx = 0;
int dii_indx = 0;
//ral_sys_ncore       m_regs;
uvm_reg_data_t fieldVal;
bit [31:0] data;
string temp_string="";

  <% for(var i=0; i<aiu_NumCores[idx]; i++) { %> 
 if(!(uvm_config_db#(ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=qidx%>[<%=i%>]" ),.value( m_ioaiu_vseqr<%=qidx%>[<%=i%>] ) ))) begin
 `uvm_error(get_name(), "Cannot get m_ioaiu_vseqr<%=qidx%>[<%=i%>]")
 end
      <%}%>
 `uvm_info("boot_sw_crdt", $sformatf("Start BOOT SW CREDIT"), UVM_LOW)
//concerto_legacy_emu_tasks::set_crdt_cfg();
//concerto_legacy_emu_tasks::get_crdt_cfg();
concerto_legacy_emu_tasks::check_csr<%=qidx%>();


//AIUids DMI DCE DII ids compting

<% for(var pidx_aiu = 0; pidx_aiu < obj.nAIUs; pidx_aiu++) {%>
      //aiu_indx=<%=pidx_aiu%>;
      aiu_indx=0;
<% if(!(obj.AiuInfo[pidx_aiu].fnNativeInterface.match('CHI'))) { %>
      <%if(Array.isArray(obj.AiuInfo[pidx_aiu].interfaces.axiInt)){%>
        <% for(var i=0; i<aiu_NumCores[pidx_aiu]; i++) { %> 
        read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>_<%=i%>.get_reg_by_name("XAIUFUIDR").get_field_by_name("FUnitId"), fieldVal);  
       AiuIds = new[AiuIds.size()+1] (AiuIds);
       AiuIds[AiuIds.size()-1] =  int'(fieldVal); 
       aiu_indx++; 
        <% } %>// foreach cores
      <%} else {%>
        read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.get_reg_by_name("XAIUFUIDR").get_field_by_name("FUnitId"), fieldVal);  
        AiuIds = new[AiuIds.size()+1] (AiuIds);
        AiuIds[AiuIds.size()-1] =  int'(fieldVal); 
        aiu_indx++;
      <%}%>
      <%} else {%>
       read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.get_reg_by_name("CAIUFUIDR").get_field_by_name("FUnitId"), fieldVal);
        AiuIds = new[AiuIds.size()+1] (AiuIds);
       AiuIds[AiuIds.size()-1] =  int'(fieldVal);
       aiu_indx++;
      <%}%>  
	    `uvm_info("boot_sw_crdt", $sformatf("Reg AIU_FUIDR-<%=pidx_aiu%> DATA 0x%0h", int'(fieldVal)), UVM_LOW)
      if(aiu_indx==0) begin temp_string=""; temp_string = $sformatf("%0s AiuIds : \n",temp_string); end
      temp_string = $sformatf("%0s %0d",temp_string,AiuIds[aiu_indx]);
 <% } %>

    `uvm_info("boot_sw_crdt", $sformatf("%0s",temp_string), UVM_LOW)

    <% for(var pidx_dce = 0; pidx_dce < obj.nDCEs; pidx_dce++) { %>
      dce_indx=<%=pidx_dce%>;
      read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.get_reg_by_name("DCEUFUIDR").get_field_by_name("FUnitId"), fieldVal);
	    `uvm_info("boot_sw_crdt", $sformatf("DCE_FUIDR-%0d  DATA 0x%0h",dce_indx,int'(fieldVal)), UVM_LOW)
        DceIds = new[DceIds.size()+1] (DceIds);
        DceIds[DceIds.size()-1] =  int'(fieldVal);
        if(dce_indx==0) begin temp_string=""; temp_string = $sformatf("%0s DceIds : \n",temp_string); end
        temp_string = $sformatf("%0s %0d",temp_string,DceIds[dce_indx]);
 <% } %>			   
    `uvm_info("boot_sw_crdt", $sformatf("%0s",temp_string), UVM_LOW)
<% for(var pidx_dmi = 0; pidx_dmi < obj.nDMIs; pidx_dmi++) { %>
    //for(int i=0; i<nDMIs; i++) begin
      dmi_indx=<%=pidx_dmi%>;
      read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.get_reg_by_name("DMIUFUIDR").get_field_by_name("FUnitId"), fieldVal);
	    `uvm_info("boot_sw_crdt", $sformatf("DMI_FUIDR-%0d  DATA 0x%0h",dmi_indx,int'(fieldVal)), UVM_LOW)      
      DmiIds = new[DmiIds.size()+1] (DmiIds);
      DmiIds[DmiIds.size()-1] =  int'(fieldVal);
      if(dmi_indx==0) begin temp_string=""; temp_string = $sformatf("%0s DmiIds : \n",temp_string); end
      temp_string = $sformatf("%0s %0d",temp_string,DmiIds[dmi_indx]);
    //end // for (int i=0; i<nDMIs; i++)
    <% } %>				   
    `uvm_info("boot_sw_crdt", $sformatf("%0s",temp_string), UVM_LOW)
<% for(var pidx_dii = 0; pidx_dii < obj.nDIIs; pidx_dii++) { %>
    //for(int i=0; i<nDIIs; i++) begin
      dii_indx=<%=pidx_dii%>;
      read_csr_<%=qidx%>(m_concerto_env.m_regs.<%=obj.DiiInfo[pidx_dii].strRtlNamePrefix%>.get_reg_by_name("DIIUFUIDR").get_field_by_name("FUnitId"), fieldVal);
	    `uvm_info("boot_sw_crdt", $sformatf("DII_FUIDR-%0d  DATA 0x%0h",dii_indx,int'(fieldVal)), UVM_LOW)
        DiiIds = new[DiiIds.size()+1] (DiiIds);
        DiiIds[DiiIds.size()-1] =  int'(fieldVal);
        if(dii_indx==0) begin temp_string=""; temp_string = $sformatf("%0s DiiIds : \n",temp_string); end
        temp_string = $sformatf("%0s %0d",temp_string,DiiIds[dii_indx]);
    //end // for (int i=0; i<nDMIs; i++)	
    <% } %>				   
    `uvm_info("boot_sw_crdt", $sformatf("%0s",temp_string), UVM_LOW)
if (en_credit_alloc) begin
  concerto_legacy_emu_tasks::credit_alloc(AiuIds,DmiIds,DceIds,DiiIds);
end else begin 
  concerto_legacy_emu_tasks::get_crdt_cfg(AiuIds,DmiIds,DceIds,DiiIds);
end
concerto_legacy_emu_tasks::credit_printer(AiuIds,DmiIds,DceIds,DiiIds);
concerto_legacy_emu_tasks::set_csr_crdt<%=qidx%>(AiuIds,DmiIds,DceIds,DiiIds);
concerto_legacy_emu_tasks::crdt_adapter<%=qidx%>(AiuIds,DmiIds,DceIds,DiiIds);

`uvm_info("boot_sw_crdt", $sformatf("END BOOT SW CREDIT"), UVM_LOW)
endtask: boot_sw_crdt<%=qidx%>


task concerto_legacy_emu_tasks::write_csr_<%=qidx%>(uvm_reg_field field, uvm_reg_data_t wr_data);
    int lsb, msb;
    uvm_reg_data_t mask;
    uvm_reg_data_t field_rd_data;

    <% if ((obj.testBench != "fsys" ) && (obj.testBench != "emu")) { %>
    field.get_parent().read(status, field_rd_data, .parent(this));
    <% } else {%>
    uvm_reg_addr_t addr;
    bit [31:0] data;
    addr = field.get_parent().get_address(); 
    addr = ncore_config_pkg::ncoreConfigInfo::set_addr_as_per_new_nrs(addr);
    <% if ( numChiAiu > 0){ %>
    if(en_rw_csr_from_ioaiu==0) begin
        //m_chi_csr_vseq.read_csr_<%=qidx%>(chiaiu<%=csrAccess_chi_idx%>_chi_aiu_vseq_pkg::addr_width_t'(addr),data);
        $display("Write csr from chi");
    end else begin
    <% } %>
            read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
    <% if ( numChiAiu > 0){ %>
    end
    <% } %>
    field_rd_data = uvm_reg_data_t'(data);
    <% } %>
    lsb = field.get_lsb_pos();
    msb = lsb + field.get_n_bits() - 1;
    `uvm_info("CSR Ralgen Base Seq", $sformatf("Write %s lsb=%0d msb=%0d", field.get_name(), lsb, msb), UVM_MEDIUM)
    // and with actual field bits 0
    mask = mask_data(lsb, msb);
    mask = ~mask;
    field_rd_data = field_rd_data & mask;
    // shift write data to appropriate position
    wr_data = wr_data << lsb;
    // then or with this data to get value to write
    wr_data = field_rd_data | wr_data;
    <% if ((obj.testBench != "fsys" ) && (obj.testBench != "emu")) { %>
    field.get_parent().write(status, wr_data, .parent(this));
    <% } else {%>
    data=32'(wr_data);
    <% if ( numChiAiu > 0){ %>
    if(en_rw_csr_from_ioaiu==0) begin
        //m_chi_csr_vseq.write_csr_<%=qidx%>(chiaiu<%=csrAccess_chi_idx%>_chi_aiu_vseq_pkg::addr_width_t'(addr),data);
        $display("Write csr from chi");
    end else begin
    <% } %>
            write_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
    <% if ( numChiAiu > 0){ %>
    end
    <% } %>
    <% } %>
endtask : write_csr_<%=qidx%>
//
task concerto_legacy_emu_tasks::read_csr_<%=qidx%>(uvm_reg_field field, output uvm_reg_data_t fieldVal);
    int lsb, msb;
    uvm_reg_data_t mask;
    uvm_reg_data_t field_rd_data;

    <% if ((obj.testBench != "fsys" ) && (obj.testBench != "emu")) { %>
    field.get_parent().read(status, field_rd_data, .parent(this));
    <% } else {%>
    uvm_reg_addr_t addr;
    bit [31:0] data;
    addr = field.get_parent().get_address();  
    addr = ncore_config_pkg::ncoreConfigInfo::set_addr_as_per_new_nrs(addr);
    <% if ( numChiAiu > 0){ %>
    if(en_rw_csr_from_ioaiu==0) begin
        // m_chi_csr_vseq.read_csr_<%=qidx%>(chiaiu<%=csrAccess_chi_idx%>_chi_aiu_vseq_pkg::addr_width_t'(addr),data);
        $display("Write csr from chi");
    end else begin
    <% } %>
            read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
    <% if ( numChiAiu > 0){ %>
    end
    <% } %>
    field_rd_data = uvm_reg_data_t'(data);
    <% } %>
    lsb = field.get_lsb_pos();
    msb = lsb + field.get_n_bits() - 1;
    `uvm_info("CSR Ralgen Base Seq", $sformatf("Read %s lsb=%0d msb=%0d", field.get_name(), lsb, msb), UVM_LOW)
    // AND other bits to 0
    mask = mask_data(lsb, msb);
    field_rd_data = field_rd_data & mask;
    // shift read data by lsb to return field
    fieldVal = field_rd_data >> lsb;
    `uvm_info("CSR Ralgen Base Seq", $sformatf("Read %s lsb=%0d msb=%0d fieldVal=%0d", field.get_name(), lsb, msb,fieldVal), UVM_LOW)
endtask : read_csr_<%=qidx%>

`ifdef USE_VIP_SNPS
task concerto_legacy_emu_tasks::write_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data,bit nonblocking=0);
    fsys_svt_seq_lib::seq_lib_svt_ace_write_sequence m_iowrnosnp_seq<%=qidx%>[<%=aiu_NumCores[idx]%>];
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] wdata;
    int addr_mask;
    int addr_offset;
<% var core = 0; 
     for(var i=0; i<qidx+1; i++) { 
      core= aiu_NumCores[i]+core;  
   }
%>
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
//<%=aiu_NumCores[idx]%>
//<%=core%>
    <% for(var i=0; i<aiu_NumCores[idx]; i++) { %> 
    m_iowrnosnp_seq<%=qidx%>[<%=i%>]   = fsys_svt_seq_lib::seq_lib_svt_ace_write_sequence::type_id::create("m_iowrnosnp_seq<%=qidx%>[<%=i%>]");
    if(nonblocking == 0) begin
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].addr_offset = addr_offset;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].myAddr = addr;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].awid = 0;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].myData[(addr_offset*8)+:32] = data; //128 =32
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].wstrb = 32'hF<<addr_offset;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=core-1+i%>].sequencer);
        //m_iowrnosnp_seq<%=qidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[0].sequencer);
        `uvm_info("(write_csr)seq_lib_svt_ace_write_sequence--1", $sformatf("addr = %0h, addr_mask = %0h, addr_offset = %0h, data = %0h", addr, addr_mask, addr_offset, data), UVM_NONE)
    end else begin
    fork
        begin
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].myAddr = addr;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].awid = 0;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].myData[(addr_offset*8)+:32] = data; //128 = 32
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].wstrb = 32'hF<<addr_offset;
        m_iowrnosnp_seq<%=qidx%>[<%=i%>].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=core-1+i%>].sequencer);
        //m_iowrnosnp_seq<%=qidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[0].sequencer);
       `uvm_info("(write_csr)seq_lib_svt_ace_write_sequence--2", $sformatf("addr = %0h, addr_mask = %0h, addr_offset = %0h, data = %0h", addr, addr_mask, addr_offset, data), UVM_NONE)
        end
    join_none
    end // else: !if(nonblocking == 0)
    <% } %>											   
endtask
`else //`ifdef USE_VIP_SNPS
task concerto_legacy_emu_tasks::write_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data,bit nonblocking=0);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrnosnp_seq m_iowrnosnp_seq<%=qidx%>;
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] wdata;
    int addr_mask;
    int addr_offset;
										
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
 <% for(var i=0; i<aiu_NumCores[idx]; i++) { %> 
    if (ncore_config_pkg::ncoreConfigInfo::check_addr_for_core(addr,<%=obj.AiuInfo[idx].FUnitId%>,<%=i%>)) begin:_wr_addr_match_with_core_<%=qidx%>_<%=i%>
    m_iowrnosnp_seq<%=qidx%>   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrnosnp_seq::type_id::create("m_iowrnosnp_seq_csr_<%=obj.BlockId%>");
    m_iowrnosnp_seq<%=qidx%>.m_addr = addr;
    m_iowrnosnp_seq<%=qidx%>.use_awid = 0;
    m_iowrnosnp_seq<%=qidx%>.m_axlen = 0;
    m_iowrnosnp_seq<%=qidx%>.m_size  = 3'b010;
    m_iowrnosnp_seq<%=qidx%>.m_data[(addr_offset*8)+:32] = data;
    m_iowrnosnp_seq<%=qidx%>.m_wstrb = 32'hF<<addr_offset; // Assuming (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8) < 32
    m_iowrnosnp_seq<%=qidx%>.start(m_ioaiu_vseqr<%=qidx%>[<%=i%>]);
    end:_wr_addr_match_with_core_<%=qidx%>_<%=i%>
    <%}%>
endtask : write_csr<%=qidx%>
`endif  //`ifdef USE_VIP_SNPS ... `else

task concerto_legacy_emu_tasks::write_chk<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data, bit check=0, bit nonblocking=0);
    bit [31:0] rdata;
    write_csr<%=qidx%>(addr,data, nonblocking);
    if(check) begin 
       read_csr<%=qidx%>(addr,rdata);
       if(data != rdata) `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Read data error  Addr: 0x%0h , Wdata: 0x%0h , Rdata: 0x%0h", addr, data, rdata))
    end
endtask : write_chk<%=qidx%>

`ifdef USE_VIP_SNPS
task concerto_legacy_emu_tasks::read_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, output bit[31:0] data);
    fsys_svt_seq_lib::seq_lib_svt_ace_read_sequence m_iordnosnp_seq<%=qidx%>[<%=aiu_NumCores[idx]%>];
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] rdata;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_rresp_t rresp;
    int addr_mask;
    int addr_offset;
<% var core = 0; 
     for(var i=0; i<qidx+1; i++) { 
      core= aiu_NumCores[i]+core;  
   }%>
										
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;

    <% for(var i=0; i<aiu_NumCores[idx]; i++) { %> 
    m_iordnosnp_seq<%=qidx%>[<%=i%>]   = fsys_svt_seq_lib::seq_lib_svt_ace_read_sequence::type_id::create("m_iordnosnp_seq<%=qidx%>[<%=i%>]");
    m_iordnosnp_seq<%=qidx%>[<%=i%>].myAddr = addr;
    m_iordnosnp_seq<%=qidx%>[<%=i%>].arid = 0;
    m_iordnosnp_seq<%=qidx%>[<%=i%>].addr_offset = addr_offset;
    if(m_concerto_env.snps.svt==null)
        $display("m_concerto_env.snps.svt is null");
    else if(m_concerto_env.snps.svt.amba_system_env==null)
        $display("m_concerto_env.snps.svt.amba_system_env is null");
    else if(m_concerto_env.snps.svt.amba_system_env.axi_system[0]==null)
        $display("m_concerto_env.snps.svt.amba_system_env.axi_system[0] is null");
    else if(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=core-1+i%>]==null)
        $display("m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=core-1+i%>] is null");
    else if(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=core-1+i%>].sequencer==null)
        $display("m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=core-1+i%>].sequencer is null");
    m_iordnosnp_seq<%=qidx%>[<%=i%>].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=core-1+i%>].sequencer);
    //m_iordnosnp_seq<%=qidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[0].sequencer);
   
    //vip zero rddata chk to be added 
    if(addr_offset==0)   rdata[(addr_offset*8)+:32] =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if(addr_offset==4)   rdata[(addr_offset*8)+:32] =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if(addr_offset==8)   rdata[(addr_offset*8)+:32] =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if(addr_offset=='hc) rdata[(addr_offset*8)+:32] =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if( addr_offset=='h10) rdata[(addr_offset*8)+:32] =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if( addr_offset=='h14) rdata[(addr_offset*8)+:32] =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if( addr_offset=='h18) rdata[(addr_offset*8)+:32] =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0];
    if( addr_offset=='h1c) rdata[(addr_offset*8)+:32] =  m_iordnosnp_seq<%=qidx%>[<%=i%>].tr.data[0]; 
   // rdata[0] =  m_iordnosnp_seq<%=qidx%>.tr.data[0];
    data  = rdata[(addr_offset*8)+:32];
    
    <% } %>											   
    `uvm_info("(read_csr)seq_lib_svt_ace_read_sequence", $sformatf("addr = %0h, addr_mask = %0h, addr_offset = %0h, rdata = 0x%12h, data = 0x%12h", addr, addr_mask, addr_offset, rdata, data), UVM_NONE)
endtask : read_csr<%=qidx%>
`else //`ifdef USE_VIP_SNPS
task concerto_legacy_emu_tasks::read_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, output bit[31:0] data);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_rdnosnp_seq m_iordnosnp_seq<%=qidx%>;
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] rdata;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_rresp_t rresp;
    int addr_mask;
    int addr_offset;
										
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
 
    <% for(var i=0; i<aiu_NumCores[idx]; i++) { %> 
    if (ncore_config_pkg::ncoreConfigInfo::check_addr_for_core(addr,<%=obj.AiuInfo[idx].FUnitId%>,<%=i%>)) begin:_rd_addr_match_with_core_<%=qidx%>_<%=i%>
    m_iordnosnp_seq<%=qidx%>   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_rdnosnp_seq::type_id::create("m_iordnosnp_seq_csr_<%=obj.BlockId%>");
    m_iordnosnp_seq<%=qidx%>.m_addr = addr;
    m_iordnosnp_seq<%=qidx%>.start(m_ioaiu_vseqr<%=qidx%>[<%=i%>]);
   
    rdata = (m_iordnosnp_seq<%=qidx%>.m_seq_item.m_has_data) ? m_iordnosnp_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rdata[0] : 0;
    data = rdata[(addr_offset*8)+:32];
    rresp =  (m_iordnosnp_seq<%=qidx%>.m_seq_item.m_has_data) ? m_iordnosnp_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rresp : 0;
    if(rresp) begin
        `uvm_error("READ_CSR",$sformatf("Resp_err :0x%0h on Read Data",rresp))
    end
    end:_rd_addr_match_with_core_<%=qidx%>_<%=i%>
    <%}%>
endtask : read_csr<%=qidx%>
`endif  //`ifdef USE_VIP_SNPS ... `else
    <% //} 
    qidx++; }
    } %>
function uvm_reg_data_t concerto_legacy_emu_tasks::mask_data(int lsb, int msb);
    uvm_reg_data_t mask_data_val = 0;
    for(int i=0;i<32;i++)begin
        if(i>=lsb &&  i<=msb)begin
            mask_data_val[i] = 1;     
        end
    end
    return mask_data_val;
  endfunction:mask_data
function void concerto_legacy_emu_tasks::parse_str(output string out [], input byte separator, input string in);
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

function void concerto_legacy_emu_tasks::credit_alloc(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);
string temp_string="";
int numAuis_dce = AiuIds.size();
int numAuis_dmi = AiuIds.size();
int numAuis_dii = AiuIds.size();
int numDces     = DceIds.size();
int findDce[$];
int findDmi[$];
int findDii[$];
int findDce_mrd[$];
int dce_con_idx;
int rand_crdt_en;
int credit_in_use;//used for max credit test computing 
int max_dce_crd;//will take max dce cmd credit calculted for dce to correctely handel random mrd credit
int used_dce_crdt[<%=obj.nDCEs%>];//used to respect constraint:the total number of credit hsould not exceed the buffer size
int used_dmi_crdt[<%=obj.nDMIs%>];//used to respect constraint:the total number of credit hsould not exceed the buffer size
int used_dii_crdt[<%=obj.nDIIs%>];//used to respect constraint:the total number of credit hsould not exceed the buffer size
int used_mrd_crdt[<%=obj.nDMIs%>];//used to respect constraint:the total number of credit hsould not exceed the buffer size

if(!$value$plusargs("rand_crdt_en=%d", rand_crdt_en)) begin 
  rand_crdt_en = 0;
end 
foreach (used_mrd_crdt[i]) begin
   used_mrd_crdt[i] = 0 ;
end 

if(!$value$plusargs("chiaiu_en=%s", chiaiu_en_arg)) begin
    <% chiaiu_idx=0; for(pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if(obj.AiuInfo[pidx].fnNativeInterface.match('CHI')) { %>
       chiaiu_en[<%=chiaiu_idx%>] = 1;
       <% chiaiu_idx++; } %>
    <% } %>
    end
    else begin
       parse_str(chiaiu_en_str, "n", chiaiu_en_arg);
       foreach (chiaiu_en_str[i]) begin
	  chiaiu_en[chiaiu_en_str[i].atoi()] = 1;
       end
    end
   
    if(!$value$plusargs("ioaiu_en=%s", ioaiu_en_arg)) begin
    <% ioaiu_idx=0; for(pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
       ioaiu_en[<%=ioaiu_idx%>] = 1;
       <% ioaiu_idx++; } %>
    <% } %>
    end
    else begin
       parse_str(ioaiu_en_str, "n", ioaiu_en_arg);
       foreach (ioaiu_en_str[i]) begin
	  ioaiu_en[ioaiu_en_str[i].atoi()] = 1;
       end
    end

    foreach(chiaiu_en[i]) begin
      t_chiaiu_en[i]= chiaiu_en[i];
       `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("chiaiu_en[%0d] = %0d", i, chiaiu_en[i]), UVM_MEDIUM)
    end
    foreach(ioaiu_en[i]) begin
      t_ioaiu_en[i]= ioaiu_en[i];
       `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("ioaiu_en[%0d] = %0d", i, ioaiu_en[i]), UVM_MEDIUM)
    end

    foreach(t_chiaiu_en[i]) begin
       `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("t_chiaiu_en[%0d] = %0d", i, t_chiaiu_en[i]), UVM_LOW)

    end
    foreach(t_ioaiu_en[i]) begin
       `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("t_ioaiu_en[%0d] = %0d", i, t_ioaiu_en[i]), UVM_LOW)
  
    end


active_numChiAiu = $countones(t_chiaiu_en);
active_numIoAiu = $countones(t_ioaiu_en);
numChiAiu = active_numChiAiu;
numIoAiu  = active_numIoAiu;


`uvm_info("credit_alloc-sw_credit_mgr", $sformatf("t_ioaiu_en =%0d active_numChiAiu = %0d active_numIoAiu =%0d numChiAiu = %0d numIoAiu = %0d" ,t_ioaiu_en, active_numChiAiu, active_numIoAiu,numChiAiu,numIoAiu), UVM_LOW)

temp_string="";
    foreach(AiuIds[i]) begin
    int tempCmdCCR=0;
      foreach(DceIds[x]) begin
        findDce = ncore_config_pkg::ncoreConfigInfo::aiu_connected_dce_ids[AiuIds[i]].ConnectedfUnitIds.find(i) with (i==DceIds[x]);
          if (findDce.size() == 0) begin
            //when Dceid is not connected decrease the number of AIU and attribute O credits 
	          //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist_conn
            numAuis_dce--;aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]] = 0;
            en_connectivity_cmd_check = 1;
            `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("AiuIds[%0d] = %0d is not connected to DceIds[%0d] = %0d" ,i,AiuIds[i],x,DceIds[x] ), UVM_LOW)
          end  else begin
            if (rand_crdt_en==1) begin // random credit is enabled
		        //#Stimulus.FSYS.v3.4.sw_credit_manager.rand_credit
              aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]] = ($urandom_range(2,(act_cmd_skid_buf_size["DCE"][x]-used_dce_crdt[DceIds[x]])) > VALID_MAX_CREDIT_VALUE/2) ? (VALID_MAX_CREDIT_VALUE/numAuis_dce) : ($urandom_range(2,(act_cmd_skid_buf_size["DCE"][x]-used_dce_crdt[DceIds[x]]))); 
              used_dce_crdt[DceIds[x]]                 =  used_dce_crdt[DceIds[x]] + int'(aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]]) ;
            end else begin
	          //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist
              aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]] = ((act_cmd_skid_buf_size["DCE"][x]/AiuIds.size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DCE"][x]/AiuIds.size());
            end 

            if(int'(aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]]) < 2) begin
                aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]] = 2;
            end
 
            //calculating of max dce credit allowed
            if(aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]] > max_dce_crd) begin
              max_dce_crd = int'(aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]]);
            end
          end
         `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("aCredit_Cmd[%0d][DCE][%0d] = %0d act_cmd_skid_buf_size[DCE][%0d] = %0d" ,AiuIds[i],DceIds[x],aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]],x,act_cmd_skid_buf_size["DCE"][x]), UVM_LOW)
        tempCmdCCR = tempCmdCCR + 1;
        temp_string = $sformatf("%0saCredit_Cmd[%0d][DCE][%0d] %0d\n",temp_string,AiuIds[i],DceIds[x],aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[x]]);

      end

      numCmdCCR = tempCmdCCR;
      tempCmdCCR=0;
      foreach(DmiIds[y]) begin
          findDmi = ncore_config_pkg::ncoreConfigInfo::aiu_connected_dmi_ids[AiuIds[i]].ConnectedfUnitIds.find(i) with (i==DmiIds[y]);
          if (findDmi.size() == 0) begin
            //when Dmiid is not connected decrease the number of AIU and attribute O credits 
	          //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist_conn
            numAuis_dmi--;aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]] = 0;
            en_connectivity_cmd_check = 1;
            `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("AiuIds[%0d] = %0d is not connected to DmiIds[%0d] = %0d" ,i,AiuIds[i],y,DmiIds[y] ), UVM_LOW)
          end else begin
            if (rand_crdt_en) begin // random credit is enabled
	          //#Stimulus.FSYS.v3.4.sw_credit_manager.rand_credit
            aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]] = ($urandom_range(2,(act_cmd_skid_buf_size["DMI"][y]-used_dmi_crdt[DmiIds[y]])) > VALID_MAX_CREDIT_VALUE) ? (VALID_MAX_CREDIT_VALUE/numAuis_dmi) : ($urandom_range(2,(act_cmd_skid_buf_size["DMI"][y]-used_dmi_crdt[DmiIds[y]])))  ;
            used_dmi_crdt[DmiIds[y]]                 =  used_dmi_crdt[DmiIds[y]] + int'(aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]]) ;
            end else begin
            //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist
            aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]] = ((act_cmd_skid_buf_size["DMI"][y]/AiuIds.size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DMI"][y]/AiuIds.size());
            end 
            if(int'(aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]]) < 2) begin
              aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]] = 2;
            end

         end

        tempCmdCCR = tempCmdCCR + 1;
        temp_string = $sformatf("%0saCredit_Cmd[%0d][DMI][%0d] %0d\n",temp_string,AiuIds[i],DmiIds[y],aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[y]]);
      end

      if(tempCmdCCR>numCmdCCR) numCmdCCR = tempCmdCCR;
      tempCmdCCR=0;
      foreach(DiiIds[z]) begin
              findDii = ncore_config_pkg::ncoreConfigInfo::aiu_connected_dii_ids[AiuIds[i]].ConnectedfUnitIds.find(i) with (i==DiiIds[z]);
              if (findDii.size() == 0) begin
                //when Diiid is not connected decrease the number of AIU and attribute 0 credits 
              numAuis_dii--;aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]] = 0;
              en_connectivity_cmd_check = 1;
              `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("AiuIds[%0d] = %0d is not connected to DiiIds[%0d] = %0d" ,i,AiuIds[i],z,DiiIds[z] ), UVM_LOW)
              end else begin
                //if(z<(DiiIds.size()-1)) begin
                  if (rand_crdt_en==1) begin  // random credit is enabled
                  aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]] = ($urandom_range(2,(act_cmd_skid_buf_size["DII"][z]-used_dii_crdt[DiiIds[z]])) >  VALID_MAX_CREDIT_VALUE/2) ? (VALID_MAX_CREDIT_VALUE/numAuis_dii) : ($urandom_range(2,(act_cmd_skid_buf_size["DII"][z]-used_dii_crdt[DiiIds[z]])));  
                  used_dii_crdt[DiiIds[z]]                = used_dii_crdt[DiiIds[z]] + int'(aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]]);               
                  end else begin
                  aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]] = ((act_cmd_skid_buf_size["DII"][z]/AiuIds.size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DII"][z]/AiuIds.size());
                  end 
                  if(int'(aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]]) < 2) begin
                  aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]] = 2;
                  end
             end

        tempCmdCCR = tempCmdCCR + 1;
        temp_string = $sformatf("%0saCredit_Cmd[%0d][DII][%0d] %0d\n",temp_string,AiuIds[i],DiiIds[z],aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[z]]);
      end

      if(tempCmdCCR>numCmdCCR) numCmdCCR = tempCmdCCR;
    end

    foreach(DceIds[i]) begin
      foreach(DmiIds[p]) begin    
        dce_con_idx = DceIds[i]- <%=obj.nAIUs%> ;
        findDce_mrd = ncore_config_pkg::ncoreConfigInfo::dce_connected_dmi_ids[dce_con_idx].ConnectedfUnitIds.find(i) with (i==DmiIds[p]);
        if (findDce_mrd.size() == 0) begin
	      //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist_conn
          numDces--; aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = 0;
          en_connectivity_mrd_check = 1;
          `uvm_info("credit_alloc-sw_credit_mgr", $sformatf("DceIds[%0d] = %0d is not connected to DmiIds[%0d] = %0d dce_con_idx = %0d"  ,i,DceIds[i],p,DmiIds[p],dce_con_idx ), UVM_LOW)
        end else begin
          if (rand_crdt_en==1) begin
          //#Stimulus.FSYS.v3.4.sw_credit_manager.rand_credit
          //aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = ($urandom_range(max_dce_crd,act_mrd_skid_buf_size["DMI"][p]) < 1) ? 1 : ($urandom_range(max_dce_crd,act_mrd_skid_buf_size["DMI"][p]));   
          aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]  = ($urandom_range(1,(act_mrd_skid_buf_size["DMI"][p]- used_mrd_crdt[p])/2) > (act_mrd_skid_buf_size["DMI"][p]-used_mrd_crdt[p])/2) ? (act_mrd_skid_buf_size["DMI"][p]/numDces) : ($urandom_range(1,(act_mrd_skid_buf_size["DMI"][p]-used_mrd_crdt[p])/2)); 
          used_mrd_crdt[p]    = used_mrd_crdt[p] + aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] ;     
          end else begin
	        //#Stimulus.FSYS.v3.4.sw_credit_manager.equal_dist
          aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = ((act_mrd_skid_buf_size["DMI"][p]/numDces) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_mrd_skid_buf_size["DMI"][p]/numDces);
          end 
          if(int'(aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]) < 1) begin
            aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = 1;
          end           
        end
        if($test$plusargs("decerr_crdt_mrd_zero_crdt")|| ($test$plusargs("ioaiu_zero_credit"))) begin
	      //#Stimulus.FSYS.address_dec_error.zero_credit.DCE_DMI
          //assign À credit to all agent to check if RTL send a Decode error
          aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] = 0;
        end
        if(i<1) numMrdCCR = numMrdCCR+1;
       temp_string = $sformatf("%0saCredit_Mrd[%0d][DMI][%0d] %0d\n",temp_string,DceIds[i],DmiIds[p],aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]] );       
      end
    end
if(!$test$plusargs("max_crdt_test")) begin
end else begin
    <% ioaiu_idx=0; for(pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
    <% if(ioaiu_idx == 0){ %>
    foreach(ioaiu_en[i]) begin
      if (ioaiu_en[i]==1) begin
      credit_in_use = credit_in_use + aCredit_Cmd[AiuIds[<%=pidx+1%>]]["DMI"][DmiIds[1]];
      end 
    end
    aCredit_Cmd[AiuIds[<%=pidx%>]]["DMI"][DmiIds[1]]= VALID_MAX_CREDIT_VALUE-credit_in_use;//"-credit_in_use" to avoid allocate all credit to ioaiu 0
    `uvm_info("credit_alloc-sw_credit_mgr max credit testing", $sformatf("aCredit_Cmd[%0d][DMI][%0d]",AiuIds[<%=pidx%>],DmiIds[1],aCredit_Cmd[AiuIds[<%=pidx%>]]["DMI"][DmiIds[0]] ), UVM_LOW)
    <% } %>
       <% ioaiu_idx++; } %>
    <% } %>
end 
//assign zero credit to ioaiu 
if($test$plusargs("ioaiu_zero_credit") || $test$plusargs("chiaiu_zero_credit") )begin
    en_connectivity_cmd_check=0;//disable connectevity check for error testing
       foreach(AiuIds[i]) begin
         if(i != (<%=numChiAiu%>)) begin//not 0 credit for ioaiu0 to be able to boot
           //#Stimulus.FSYS.address_dec_error.zero_credit.AIU_DCE
          foreach(DceIds[j]) begin 
            aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[j]] = 0;
          end
          //#Stimulus.FSYS.address_dec_error.zero_credit.AIU_DMI
          foreach(DmiIds[k]) begin 
            aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[k]] = 0;
          end
          foreach(DiiIds[p]) begin 
            aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[p]] = 0;
          end 
         end                 
    end 

end 
//assign À credit to all agent to check if RTL send a Decode error
if($test$plusargs("decerr_crdt_test")) begin
     foreach(AiuIds[i]) begin
           //#Stimulus.FSYS.address_dec_error.zero_credit.AIU_DCE
           foreach(DceIds[j]) begin 
            aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[j]] = 0;
          end
          //#Stimulus.FSYS.address_dec_error.zero_credit.AIU_DMI
          foreach(DmiIds[k]) begin 
            aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[k]] = 0;
          end
          foreach(DiiIds[p]) begin 
            aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[p]] = 0;
          end                  
    end 
end 
    `uvm_info("credit_alloc-sw_credit_mgr",$sformatf("numMrdCCR %0d numCmdCCR %0d  active_numChiAiu %0d active_numIoAiu %0d",numMrdCCR,numCmdCCR,active_numChiAiu,active_numIoAiu),UVM_NONE)
        
        $display("SOFTWARE CREDIT CMD TABLE:\n");
        $display("-------------------------------------------------------------------------------------------------------");
        $display("|      AIU(FunitId)        |      Target(FunitId)      |       Credit        |    Connectivity          |");
        $display("-------------------------------------------------------------------------------------------------------");
foreach(AiuIds[i]) begin
      foreach(DceIds[j]) begin 
        $display("|        AIU%0d(%0d)       |       DCE%0d(%0d)         |         %0d          |                         |",i,AiuIds[i],j,DceIds[j],aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[j]]);   
      end
      foreach(DmiIds[k]) begin 
        $display("|         AIU%0d(%0d)      |       DMI%0d(%0d)         |         %0d          |                         |",i,AiuIds[i],k,DmiIds[k],aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[k]]);
      end
      foreach(DiiIds[p]) begin 
        $display("|         AIU%0d(%0d)      |       DII%0d(%0d)         |         %0d          |                         |",i,AiuIds[i],p,DiiIds[p],aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[p]]);
      end                  
end 
        $display("SOFTWARE CREDIT MRD TABLE:\n");
        $display("-------------------------------------------------------------------------------------------------------");
        $display("|      DCE(FunitId)        |      DMI(FunitId)         |       Credit         |    Connectivity         |");
        $display("-------------------------------------------------------------------------------------------------------");
foreach(DceIds[i]) begin
  foreach(DmiIds[p]) begin
        $display("|         DCE%0d(%0d)      |       DMI%0d(%0d)         |         %0d          |                         |",i,DceIds[i],p,DmiIds[p],aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]);
  end
end
        $display("------------------------------------------------------------------------------------------------------");  


    `uvm_info("credit_alloc-sw_credit_mgr",$sformatf("%0s",temp_string),UVM_MEDIUM)
   endfunction :credit_alloc

function void concerto_legacy_emu_tasks::credit_printer(int AiuIds[],int DmiIds[],int DceIds[],int DiiIds[]);

        $display("SOFTWARE CREDIT CMD TABLE:\n");
        $display("-------------------------------------------------------------------------------------------------------");
        $display("|      AIU(FunitId)        |      Target(FunitId)      |       Credit        |    Connectivity          |");
        $display("-------------------------------------------------------------------------------------------------------");
foreach(AiuIds[i]) begin
      foreach(DceIds[j]) begin 
        $display("|        AIU%0d(%0d)       |       DCE%0d(%0d)         |         %0d          |                         |",i,AiuIds[i],j,DceIds[j],aCredit_Cmd[AiuIds[i]]["DCE"][DceIds[j]]);   
      end
      foreach(DmiIds[k]) begin 
        $display("|         AIU%0d(%0d)      |       DMI%0d(%0d)         |         %0d          |                         |",i,AiuIds[i],k,DmiIds[k],aCredit_Cmd[AiuIds[i]]["DMI"][DmiIds[k]]);
      end
      foreach(DiiIds[p]) begin 
        $display("|         AIU%0d(%0d)      |       DII%0d(%0d)         |         %0d          |                         |",i,AiuIds[i],p,DiiIds[p],aCredit_Cmd[AiuIds[i]]["DII"][DiiIds[p]]);
      end                  
end 
        $display("SOFTWARE CREDIT MRD TABLE:\n");
        $display("-------------------------------------------------------------------------------------------------------");
        $display("|      DCE(FunitId)        |      DMI(FunitId)         |       Credit         |    Connectivity         |");
        $display("-------------------------------------------------------------------------------------------------------");
foreach(DceIds[i]) begin
  foreach(DmiIds[p]) begin
        $display("|         DCE%0d(%0d)      |       DMI%0d(%0d)         |         %0d          |                         |",i,DceIds[i],p,DmiIds[p],aCredit_Mrd[DceIds[i]]["DMI"][DmiIds[p]]);
  end
end
        $display("------------------------------------------------------------------------------------------------------");  

endfunction :credit_printer

task concerto_legacy_emu_tasks::exec_inhouse_boot_seq(uvm_phase phase);
// Randomize and set configuration in DMI scoreboard
    bit [31:0] agent_id,way_vec,way_full_chk;
    bit [31:0] agent_ids_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$];
    bit [31:0] wayvec_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$];
    int shared_ways_per_user;
    int way_for_atomic=0;

    int sp_ways[] = new[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS];
    int sp_size[] = new[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS];
    bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[] = new[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS];
    int idxq[$];
    string dce_credit_msg="";
    int new_dce_credits;
    
    ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];
    csrq = ncore_config_pkg::ncoreConfigInfo::get_all_gpra();
 
  if($test$plusargs("dmiusmc_policy_chiaiu_test")) begin
      std::randomize(dmiusmc_policy_rand) with {dmiusmc_policy_rand dist { 1:=0, 2:=50, 4:=50, 8:=0, 16:=0};};// RdAllocDisable, WrAllocDisable have a direct tests
    end
 <% for(pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
 <% if(obj.DmiInfo[pidx].useCmc) { %>
    if(m_args.dmi_scb_en) begin  
      if(dmiusmc_policy_rand==2) begin
       m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.ClnWrAllocDisable = 1;
      end		
      if(dmiusmc_policy_rand==4) begin
       m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.DtyWrAllocDisable = 1;
      end
      if($test$plusargs("dmi_rdalloc_dis")) begin
       m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.RdAllocDisable = 1;
      end		
      if($test$plusargs("dmi_wralloc_dis")) begin
       m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.WrAllocDisable = 1;
      end	
       m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.lookup_en = 1;				  
       if($test$plusargs("dmi_alloc_dis")) begin
          m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.alloc_en = 0;
       end else begin
          m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.alloc_en = 1;
       end
       if($test$plusargs("rand_alloc_lookup")) begin
          m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.alloc_en  = dmi_nallocen_rand ;
          m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.lookup_en = dmi_nlooken_rand ;
       end
    end	  
    <% } %>						  
    <% } %>						  

    for(int i=0; i<ncore_config_pkg::ncoreConfigInfo::NUM_DMIS; i++) begin
    int max_way_partitioning;
       if(ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[i]) begin  
          way_for_atomic = $urandom_range(0,ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]-1);
       end
       if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcwp[i]) begin  
          way_full_chk = 0;
          for(int k=0; k<<%=obj.nAIUs%>;k++) begin
             agent_ids_assigned_q[i].push_back(k);  
          end
          agent_ids_assigned_q[i].shuffle();  
         max_way_partitioning = (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i] > <%=obj.nAIUs%>) ? <%=obj.nAIUs%> : ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];
         for( int j=0;j<max_way_partitioning /*ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i]*/;j++) begin
             if ($test$plusargs("all_way_partitioning")) begin
                if((j==0)&&(ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[j]==0)) begin 
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
          if(ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[i]==0) begin
             shared_ways_per_user = ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]/ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];
          end else begin
             shared_ways_per_user = (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]-1)/ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];
          end
          for( int j=0;j<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];j++) begin
              if ($test$plusargs("all_way_partitioning")&&(ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[j]==0)) begin
                 way_vec = ((1<<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i])-1);
              end else begin
                 way_vec = ((1<<$urandom_range(1,shared_ways_per_user)) - 1) << (shared_ways_per_user)*j;
              end
              if ($test$plusargs("no_way_partitioning")) way_vec=0;
		      `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayvec :%0b",i,j,way_vec), UVM_LOW)
              wayvec_assigned_q[i].push_back(way_vec);
              way_full_chk |=way_vec;
              `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayfull:%0b num ways in DMI:%0d",i,j,way_full_chk,ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]), UVM_LOW)
          end

          for( int j=0;j<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];j++) begin
              `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayfull:%0b count ones:%0d",i,j,way_full_chk,$countones(way_full_chk)), UVM_LOW)
              way_vec = wayvec_assigned_q[i].pop_front;
              if(ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[i] && $countones(way_full_chk)>=ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]) begin  
                 way_vec[way_for_atomic] = 1'b0;
                 `uvm_info("TEST_MAIN", $sformatf("For DMI%0d with AtomicEngine way:%0d/%0d is unallocated, so that atomic txn can allocate",i,way_for_atomic,ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]), UVM_LOW)
                 `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayvec :%0b",i,j,way_vec), UVM_LOW)
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
       end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcwp[i])

       // Configure Scratchpad memories
       if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcsp[i]) begin  
          // Enabling and configuring Scratchpad using force
          if ($test$plusargs("all_ways_for_sp")) begin
              sp_ways[i] = ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i];
          end else if ($test$plusargs("all_ways_for_cache")) begin
              sp_ways[i] = 0;
          end else begin
              randcase
                  //15 : sp_ways[i] = 0;
                  30 : sp_ways[i] = ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i];
                  30 : sp_ways[i] = (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]/2);
                  40 : sp_ways[i] = $urandom_range(1,(ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]-1));
              endcase
          end
 
          idxq = csrq.find_index(x) with (  (x.unit.name == "DMI") && (x.mig_nunitid == ncore_config_pkg::ncoreConfigInfo::dmi_intrlvgrp[ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs][i]) );
          if(idxq.size() == 0) begin
              `uvm_error("EXEC_INHOUSE_BOOT_SEQ", $sformatf("DMI%0d Interleaving group %0d not found", i, ncore_config_pkg::ncoreConfigInfo::dmi_intrlvgrp[ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs][i]))
              end
          k_sp_base_addr[i] = {csrq[idxq[0]].upp_addr,csrq[idxq[0]].low_addr,12'h0}; 

          sp_size[i] = ncore_config_pkg::ncoreConfigInfo::dmi_CmcSet[i] * sp_ways[i];
          k_sp_base_addr[i] = $urandom_range(0, k_sp_base_addr[i] - (sp_size[i] << <%=obj.wCacheLineOffset%>) - 1);
          k_sp_base_addr[i] = k_sp_base_addr[i] >> ($clog2(ncore_config_pkg::ncoreConfigInfo::dmi_CmcSet[i]*ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i])+<%=obj.wCacheLineOffset%>);
          k_sp_base_addr[i] = k_sp_base_addr[i] << ($clog2(ncore_config_pkg::ncoreConfigInfo::dmi_CmcSet[i]*ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i])+<%=obj.wCacheLineOffset%>);

          <% if((obj.useCmc) && (numDmiWithSP > 0)) { %>
	  if(m_args.dmi_scb_en) begin 
              case(i) <%for(var sidx = 0; sidx < obj.nDMIs; sidx++) { if(obj.DmiInfo[sidx].ccpParams.useScratchpad==1) {%>
                 <%=sidx%> : 
                    if(sp_ways[<%=sidx%>] > 0) begin
                       m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.sp_enabled     = (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[<%=sidx%>]) ? 32'h1 : 32'h0;
                       m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.lower_sp_addr  = k_sp_base_addr[<%=sidx%>];
                       m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.sp_ways        = sp_ways[<%=sidx%>];
                       m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.create_SP_q();
		    end
                <% } } %>
              endcase
	  end
          <% } %>
       end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcsp[i])
    end // for nDMIs

//==================================================
<% if (found_csr_access_ioaiu > 0) { %>
    if(boot_from_ioaiu == 1) begin
       `uvm_info("TEST_MAIN", "Start IOAIU<%=csrAccess_ioaiu%> boot_seq", UVM_NONE)
       `ifdef USE_STL_TRACE //register configurations by stl file
       if($test$plusargs("disable_stl_csr"))
       ioaiu_boot_seq<%=csrAccess_ioaiu%>(agent_ids_assigned_q,wayvec_assigned_q, k_sp_base_addr, sp_ways, sp_size, aiu_qos_threshold, dce_qos_threshold, dmi_qos_threshold,dmi_qos_rsved); 
       else stl_csr_write();
       `else   
       csrAccess_ioaiu = <%=csrAccess_ioaiu%>;
       ioaiu_boot_seq<%=csrAccess_ioaiu%>(agent_ids_assigned_q,wayvec_assigned_q, k_sp_base_addr, sp_ways, sp_size, aiu_qos_threshold, dce_qos_threshold, dmi_qos_threshold,dmi_qos_rsved); 
       `endif //`ifdef USE_STL_TRACE 
    end 
<% } else { %>
`ifdef USE_VIP_SNPS_CHI //existing flow will not run when USE_VIP_SNPS set
  `uvm_info("TEST_MAIN", "Start CHIAIU0 enum_boot_seq", UVM_NONE)
  m_snps_chi0_vseq = chi_subsys_pkg::chi_subsys_vseq::type_id::create("m_chi<%=idx%>_seq");
  m_snps_chi0_vseq.set_seq_name("m_chi<%=idx%>_seq");
  m_snps_chi0_vseq.set_done_event_name("done_svt_chi_rn_seq_h<%=idx%>");
  m_snps_chi0_vseq.rn_xact_seqr    =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[0].rn_xact_seqr;  
  m_snps_chi0_vseq.shared_status =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[0].shared_status;  
  m_snps_chi0_vseq.chi_num_trans =  10;  
  m_snps_chi0_vseq.m_regs = m_concerto_env.m_regs;
  // Due to STATIC m_chi0_args must create a dummy one.
  m_chi0_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create("chi0_aiu_unit_args0");
  m_chi0_args.k_num_requests.set_value(10);
  m_chi0_args.k_coh_addr_pct.set_value(50);
  m_chi0_args.k_noncoh_addr_pct.set_value(50);
  m_chi0_args.k_device_type_mem_pct.set_value(50);
  m_chi0_args.k_new_addr_pct.set_value(50);
  m_snps_chi0_vseq.set_unit_args(m_chi0_args);
  m_snps_chi0_vseq.m_regs = m_concerto_env.m_regs;
  m_snps_chi0_vseq.enum_boot_seq(agent_ids_assigned_q,wayvec_assigned_q, k_sp_base_addr, sp_ways, sp_size, aiu_qos_threshold, dce_qos_threshold, dmi_qos_threshold);                        
`endif //`ifndef USE_VIP_SNPS ... else
<% }%>

#5us; // Need to wait for pending transactions to complete e.g. DTRRsp
endtask: exec_inhouse_boot_seq


 <% for(let idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
     if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
// CLU TMP COMPILE FIX CONC-11383     if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
task concerto_legacy_emu_tasks::ioaiu_boot_seq<%=qidx%>(bit [31:0] agent_ids_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$], bit [31:0] wayvec_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$], bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[], int sp_ways[], int sp_size[], int aiu_qos_threshold[int], int dce_qos_threshold[int], int dmi_qos_threshold[int], int dmi_qos_rsved
);
    // For IOAIU CSR Seq
    ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;
    bit [31:0] data;
    bit [31:0] infor;
    // For Initiator IOAIU
    bit [7:0] ioaiu_rpn; // Assuming expected value to be 0
    bit [3:0] ioaiu_nrri; // Assuming expected value to be 0
    // System Census 
    bit [7:0] nAIUs; // Max 128
    bit [5:0] nDCEs; // Max 32
    bit [5:0] nDMIs; // Max 32
    bit [5:0] nDIIs; // Max 32 or nDIIs
    bit       nDVEs; // Max 1
    // For interleaving
    bit [4:1] AMIGS;
    // Addr_Mgr
    ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];
    bit [7:0] rpn;
    bit [7:0] cur_rpn;
    int qos_threshold;
    bit [<%=obj.wSysAddr-1%>:0] ScPadBaseAddr;
    bit ScPadEn;
    bit [31:0] transorder_mode;
    bit k_csr_access_only;
    bit nonblocking;								   
    bit sys_event_disable;
    string temp_string="";
    bit t_boot_from_ioaiu=1;
    int chiaiu_timeout_val;
    int ioaiu_timeout_val;
    string dce_credit_msg="";
    int new_dce_credits;
    int this_ioaiu_intf= <%=aiu_rpn[idx]%>; //<%=obj.AiuInfo[idx].rpn%>;  //<%=qidx%>;
    int find_this_ioaiu_intf=0;
    bit ccp_allocen;
    bit ccp_lookupen ;
    bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] temp_addr; 
    bit AIUUEDR_DecErrDetEn;

    if (!$value$plusargs("chiaiu_timeout_val=%d",chiaiu_timeout_val)) begin
        chiaiu_timeout_val= 2000;
    end
    if (!$value$plusargs("ioaiu_timeout_val=%d",ioaiu_timeout_val)) begin
        ioaiu_timeout_val= 2000;
    end											   
    if(!($value$plusargs("ccp_lookupen=%0d",ccp_lookupen))) begin
        ccp_lookupen  = 1;
    end
    if(!($value$plusargs("ccp_allocen=%0d",ccp_allocen))) begin
        ccp_allocen  = 1;
    end
   

    act_cmd_skid_buf_size["DCE"] = new[1];
    act_cmd_skid_buf_size["DCE"][0] = 0; //Default value First index zero. If nDCE>1, It will be equal to DCE0 skidbufsize and then skidbufsize of rest of DCEs will be filled in rest of elements
    act_cmd_skid_buf_arb["DCE"] = new[1];
    act_cmd_skid_buf_arb["DCE"][0] = 0; //Default value First index zero. If nDCE>1, It will be equal to DCE0 skidbufarb and then skidbufarb of rest of DCEs will be filled in rest of elements
    act_cmd_skid_buf_size["DMI"] = new[1];
    act_cmd_skid_buf_size["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufsize and then skidbufsize of rest of DMIs will be filled in rest of elements
    act_cmd_skid_buf_arb["DMI"] = new[1];
    act_cmd_skid_buf_arb["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufarb and then skidbufarb of rest of DMIs will be filled in rest of elements
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

    if(!$value$plusargs("k_csr_access_only=%d",k_csr_access_only))begin
       k_csr_access_only = 0;
    end

    if(!$value$plusargs("sys_event_disable=%d", sys_event_disable)) begin
        sys_event_disable = 0;
    end
    // set csrBaseAddr													
    addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE ; //  addr = {<%=obj.AiuInfo[idx].CsrInfo.csrBaseAddress.replace("0x","'h")%>, 8'hFF, 12'h000}; 

// #Check.FSYS.csr.NRSbaseAddr
    if(ncore_config_pkg::ncoreConfigInfo::program_nrs_base) begin
      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$psprintf("Running test concerto_nrs_reg_test ..."),UVM_LOW)
      for(int i=0; i<<%=numAiuRpns%>; i++) begin
        if(find_this_ioaiu_intf==this_ioaiu_intf) begin
            //addr = ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i];
            `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$psprintf("Assigning NRSBASE to %h",ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i]),UVM_LOW)
            addr[19:12]=this_ioaiu_intf;// Register Page Number
            addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.NRSBAR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUNRSBAR.get_offset()<%}%>;
            read_csr<%=qidx%>(addr,data);
            `uvm_info("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("Reading NRSBAR ADDR 0x%0h DATA 0x%0h", addr, data),UVM_LOW)
            if(ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE[51:20]==data)
              `uvm_info("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("Checking NRSBAR ADDR 0x%0h EXP-DATA 0x%0h ACT-DATA 0x%0h", addr, ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE[51:20], data),UVM_LOW)
            else
              `uvm_error("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("Checking NRSBAR ADDR 0x%0h EXP-DATA 0x%0h ACT-DATA 0x%0h. Found Mismatch!",  addr, ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE[51:20], data))

            addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.NRSBHR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUNRSBHR.get_offset()<%}%>;
            data = ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i][51:20]; 
            `uvm_info("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("Writing NRSBHR ADDR 0x%0h DATA 0x%0h",  addr, data),UVM_LOW)
            write_csr<%=qidx%>(addr,data,  nonblocking);

            do begin
                addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.NRSBLR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUNRSBLR.get_offset()<%}%>;
                read_csr<%=qidx%>(addr,data);
                `uvm_info("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("Reading NRSBLR ADDR 0x%0h DATA 0x%0h",  addr, data),UVM_LOW)
            end
            while(data[31]==0);
            `uvm_info("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("NRSBLR.BALoaded is set"),UVM_LOW)
            #10ns;
            addr = ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i];
            `uvm_info("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("Changing NRS_REGION_BASE from 0x%h to 0x%h",ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE,ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i]),UVM_LOW)
            ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE = ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i];
        end // if(find_this_ioaiu_intf==this_ioaiu_intf) begin
        find_this_ioaiu_intf = find_this_ioaiu_intf + 1;
        //if(ncore_config_pkg::ncoreConfigInfo::get_native_interface(i) inside {ncore_config_pkg::ncoreConfigInfo::ACE_AIU,ncore_config_pkg::ncoreConfigInfo::ACE_LITE_AIU,ncore_config_pkg::ncoreConfigInfo::AXI_AIU,ncore_config_pkg::ncoreConfigInfo::IO_CACHE_AIU,ncore_config_pkg::ncoreConfigInfo::ACE_LITE_E_AIU}) begin
        //  find_this_ioaiu_intf = find_this_ioaiu_intf + 1;
        //  `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$psprintf("RPN %0d is tied to %0s %0d %0d",i,ncore_config_pkg::ncoreConfigInfo::get_native_interface(i).name(),find_this_ioaiu_intf,this_ioaiu_intf),UVM_LOW)
        //end
      end // for(int i=0; i<<%=numAiuRpns%>; i++) begin
    end // if(ncore_config_pkg::ncoreConfigInfo::program_nrs_base) begin

    // TODO: Assuming(1) the Reset value of NRSBAR = 0x0 and (2)this Boot_seq will work on 1st Chi-BFM
    // (1) Read USIDR 
    addr[19:0] = 20'hFF000;   
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading USIDR (0x%0h)", addr), UVM_LOW)
    
    addr[19:0] = 20'hFF000;   
    read_csr<%=qidx%>(addr,data);
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("USIDR = 0x%0h", data), UVM_LOW)
    if(data[31]) begin // valid
        ioaiu_rpn  = data[ 7:0];
        ioaiu_nrri = data[11:8];
	`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("USIDR.RPN=%0d, USIDR.NRRI=%0d", ioaiu_rpn, ioaiu_nrri), UVM_LOW)
    end else begin
        `uvm_error("IOAIU<%=qidx%>BOOT_SEQ","Valid bit not asserted in USIDR register of Initiating IOAIU-AIU")
    end
    // (2) Read NRRUCR
    addr[11:0] = m_concerto_env.m_regs.sys_global_register_blk.GRBUNRRUCR.get_offset();
    data = 0;
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading NRRUCR (0x%0h)", addr), UVM_LOW)
    read_csr<%=qidx%>(addr,data);
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("NRRUCR = 0x%0h", data), UVM_LOW)
    if(data == 0) begin
        `uvm_error("IOAIU<%=qidx%>BOOT_SEQ","NRRUCR register is 0")
    end

    nAIUs = data[ 7: 0];
    nDCEs = data[13: 8];
    nDMIs = data[19:14];
    nDIIs = data[25:20];
    nDVEs = data[26:26];
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$sformatf("nAIUs:%0d nDCEs:%0d nDMIs:%0d nDIIs:%0d nDVEs:%0d",nAIUs,nDCEs,nDMIs,nDIIs,nDVEs),UVM_NONE)

    if(k_csr_access_only==1) begin
        sys_reg_exp_data_val["GRBUCSSFIDR"]  = new[<%=obj.SnoopFilterInfo.length%>];
        sys_reg_exp_data_mask["GRBUCSSFIDR"] = new[<%=obj.SnoopFilterInfo.length%>];
        <%for(var tempidx = 0; tempidx < obj.SnoopFilterInfo.length; tempidx++) {%>
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>][19:0]  = <%=obj.SnoopFilterInfo[tempidx].nSets%> -1;
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>][25:20] = <%=obj.SnoopFilterInfo[tempidx].nWays%> -1;
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>][28:26] = <%=(obj.SnoopFilterInfo[tempidx].nVictimEntries>0) ? 7 : 3%>;
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>][31:29] = 0;

            sys_reg_exp_data_mask["GRBUCSSFIDR"][<%=tempidx%>][31:0] = 32'hFFFF_FFFF;
            sys_reg_exp_data_mask["GRBUCSSFIDR"][<%=tempidx%>][28:26] = 3'h0;
            addr[11:0] = m_concerto_env.m_regs.sys_global_register_blk.GRBUCSSFIDR<%=tempidx%>.get_offset() /*+ (<%=tempidx%> * 4)*/;
            data = 0;
            read_csr<%=qidx%>(addr,data);
            `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading GRBUCSSFIDR<%=tempidx%>(0x%0h)= 0x%0h",addr,data), UVM_NONE)
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>] = sys_reg_exp_data_mask["GRBUCSSFIDR"][<%=tempidx%>] & sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>];
            data = sys_reg_exp_data_mask["GRBUCSSFIDR"][<%=tempidx%>] & data; 
            `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUCSSFIDR<%=tempidx%>(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>]), UVM_NONE)
            // #Check.FSYS.csr.Check.GRBUCSSFIDR
            if(data != sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>]) begin
              `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUCSSFIDR<%=tempidx%>(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>]))
            end
        <%}%>

        sys_reg_exp_data_val["GRBUNRRIR"]  = new[1];
        sys_reg_exp_data_mask["GRBUNRRIR"] = new[1];
        sys_reg_exp_data_val["GRBUNRRIR"][0][3:0]   = 0;
        sys_reg_exp_data_val["GRBUNRRIR"][0][15:4]  = 0;
        sys_reg_exp_data_val["GRBUNRRIR"][0][19:16] = 0;
        sys_reg_exp_data_val["GRBUNRRIR"][0][31:20] = 0;

        sys_reg_exp_data_mask["GRBUNRRIR"][0][31:0] = 32'hFFFF_FFFF;

        addr[11:0] = m_concerto_env.m_regs.sys_global_register_blk.GRBUNRRIR.get_offset();
        data = 0;
        read_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading GRBUNRRIR(0x%0h)= 0x%0h",addr,data), UVM_NONE)
        sys_reg_exp_data_val["GRBUNRRIR"][0] = sys_reg_exp_data_mask["GRBUNRRIR"][0] & sys_reg_exp_data_val["GRBUNRRIR"][0];
        data = sys_reg_exp_data_mask["GRBUNRRIR"][0] & data; 
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUNRRIR(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNRRIR"][0]), UVM_NONE)
        // #Check.FSYS.csr.Check.GRBUNRRIR
        if(data != sys_reg_exp_data_val["GRBUNRRIR"][0]) begin
          `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUNRRIR(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNRRIR"][0]))
        end

        sys_reg_exp_data_val["GRBUENGIDR"]  = new[1];
        sys_reg_exp_data_mask["GRBUENGIDR"] = new[1];
        sys_reg_exp_data_val["GRBUENGIDR"][0][31:0] = <%=obj.AiuInfo[0].engVerId%>;

        sys_reg_exp_data_mask["GRBUENGIDR"][0][31:0] = 32'hFFFF_FFFF;

        addr[11:0] = m_concerto_env.m_regs.sys_global_register_blk.GRBUENGIDR.get_offset();
        data = 0;
        read_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading GRBUENGIDR(0x%0h)= 0x%0h",addr,data), UVM_NONE)
        sys_reg_exp_data_val["GRBUENGIDR"][0] = sys_reg_exp_data_mask["GRBUENGIDR"][0] & sys_reg_exp_data_val["GRBUENGIDR"][0];
        data = sys_reg_exp_data_mask["GRBUENGIDR"][0] & data; 
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUENGIDR(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUENGIDR"][0]), UVM_NONE)
        // #Check.FSYS.csr.Check.GRBUENGIDR
        if(data != sys_reg_exp_data_val["GRBUENGIDR"][0]) begin
          `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUENGIDR(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUENGIDR"][0]))
        end

        sys_reg_exp_data_val["GRBUNRRUCR"]  = new[1];
        sys_reg_exp_data_mask["GRBUNRRUCR"] = new[1];
        sys_reg_exp_data_val["GRBUNRRUCR"][0][7:0]  =<%=obj.AiuInfo.length%>;
        sys_reg_exp_data_val["GRBUNRRUCR"][0][13:8] =<%=obj.DceInfo.length%>;
        sys_reg_exp_data_val["GRBUNRRUCR"][0][19:14]=<%=obj.DmiInfo.length%>;
        sys_reg_exp_data_val["GRBUNRRUCR"][0][25:20]=<%=obj.DiiInfo.length%>;
        sys_reg_exp_data_val["GRBUNRRUCR"][0][31:26]=<%=obj.DveInfo.length%>;

        sys_reg_exp_data_mask["GRBUNRRUCR"][0][31:0] = 32'hFFFF_FFFF;

        addr[11:0] = m_concerto_env.m_regs.sys_global_register_blk.GRBUNRRUCR.get_offset();
        data = 0;
        read_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading GRBUNRRUCR(0x%0h)= 0x%0h",addr,data), UVM_NONE)
        sys_reg_exp_data_val["GRBUNRRUCR"][0] = sys_reg_exp_data_mask["GRBUNRRUCR"][0] & sys_reg_exp_data_val["GRBUNRRUCR"][0];
        data = sys_reg_exp_data_mask["GRBUNRRUCR"][0] & data; 
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUNRRUCR(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNRRUCR"][0]), UVM_NONE)
        // #Check.FSYS.csr.Check.GRBUNRRUCR
        if(data != sys_reg_exp_data_val["GRBUNRRUCR"][0]) begin
          `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUNRRUCR(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNRRUCR"][0]))
        end

        sys_reg_exp_data_val["GRBUNSIDR"]  = new[1];
        sys_reg_exp_data_mask["GRBUNSIDR"] = new[1];
        sys_reg_exp_data_val["GRBUNSIDR"][0][11:0]  = <%=obj.AiuInfo[0].implVerId%>; //12'h340;
        sys_reg_exp_data_val["GRBUNSIDR"][0][15:12] = <%=obj.DceInfo[0].wCacheLineOffset%> - 5;
        sys_reg_exp_data_val["GRBUNSIDR"][0][31:16] = <%=obj.SnoopFilterInfo.length%> - 1;

        sys_reg_exp_data_mask["GRBUNSIDR"][0][31:0] = 32'hFFFF_FFFF;

        addr[11:0] = m_concerto_env.m_regs.sys_global_register_blk.GRBUNSIDR.get_offset();
        data = 0;
        read_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading GRBUNSIDR(0x%0h)= 0x%0h",addr,data), UVM_NONE)
        sys_reg_exp_data_val["GRBUNSIDR"][0] = sys_reg_exp_data_mask["GRBUNSIDR"][0] & sys_reg_exp_data_val["GRBUNSIDR"][0];
        data = sys_reg_exp_data_mask["GRBUNSIDR"][0] & data; 
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUNSIDR(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNSIDR"][0]), UVM_NONE)
        // #Check.FSYS.csr.Check.GRBUNSIDR
        if(data != sys_reg_exp_data_val["GRBUNSIDR"][0]) begin
          `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUNSIDR(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNSIDR"][0]))
        end
    end

    if(nDCEs>0) begin
      act_cmd_skid_buf_size["DCE"] = new[nDCEs];
      act_cmd_skid_buf_arb["DCE"] = new[nDCEs];
      exp_cmd_skid_buf_size["DCE"] = new[nDCEs];
      exp_cmd_skid_buf_arb["DCE"] = new[nDCEs];
      dce_connected = new[nDCEs];
      dce_dmi_connected = new[nDCEs];
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
      dmi_connected = new[nDMIs];
    end

    if(nDIIs>0) begin
      act_cmd_skid_buf_size["DII"] = new[nDIIs];
      act_cmd_skid_buf_arb["DII"] = new[nDIIs];
      exp_cmd_skid_buf_size["DII"] = new[nDIIs];
      exp_cmd_skid_buf_arb["DII"] = new[nDIIs];
      dii_connected = new[nDIIs];
    end

      aiu_dce_connect = new[nAIUs];
      aiu_dmi_connect = new[nAIUs];
      aiu_dii_connect = new[nAIUs];
      dce_dmi_connect = new[nDCEs];
    
<%var tempidx = 0;%>
<%for(var tempidx = 0; tempidx < obj.nDCEs; tempidx++) {%>
      exp_cmd_skid_buf_size["DCE"][<%=tempidx%>] = <%=obj.DceInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DCE"][<%=tempidx%>] = <%=obj.DceInfo[tempidx].nCMDSkidBufArb%>;
<%}%>

<%var tempidx = 0;%>
<%for(var tempidx = 0; tempidx < obj.nDMIs; tempidx++) {%>
      exp_cmd_skid_buf_size["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nCMDSkidBufArb%>;
      exp_mrd_skid_buf_size["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nMrdSkidBufSize%>;
      exp_mrd_skid_buf_arb["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nMrdSkidBufArb%>;
<%}%>

<%var tempidx = 0;%>
<%for(var tempidx = 0; tempidx < obj.nDIIs; tempidx++) {%>
      exp_cmd_skid_buf_size["DII"][<%=tempidx%>] = <%=obj.DiiInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DII"][<%=tempidx%>] = <%=obj.DiiInfo[tempidx].nCMDSkidBufArb%>;
<%}%>

<%var tempidx = 0;%>
<% for(var tempidx = 0; tempidx < obj.nAIUs; tempidx++) {%>
    aiu_dmi_connect[<%=tempidx%>] = 'h<%=obj.AiuInfo[tempidx].hexAiuDmiVec%>;
    aiu_dii_connect[<%=tempidx%>] = 'h<%=obj.AiuInfo[tempidx].hexAiuDiiVec%>;
    aiu_dce_connect[<%=tempidx%>] = 'h<%=obj.AiuInfo[tempidx].hexAiuDceVec%>;
<%}%>

   for(int k = 0; k < <%=obj.nAIUs%>; k++)begin
     for(int j=0;j<nDCEs;j++)begin
       if(aiu_dce_connect[k][((nDCEs-1)-j)]) dce_connected[j]++;
     end
     for(int j=0;j<nDMIs;j++)begin
       if(aiu_dmi_connect[k][((nDMIs-1)-j)]) dmi_connected[j]++;
     end
     for(int j=0;j<nDIIs;j++)begin
       if(aiu_dii_connect[k][((nDIIs-1)-j)]) dii_connected[j]++;
     end
   end


    // (3) Configure all the General Purpose registers
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ","Configuring GPRs", UVM_LOW)
    csrq = ncore_config_pkg::ncoreConfigInfo::get_all_gpra();

    foreach (csrq[i]) begin
      `uvm_info(get_name(),
          $psprintf("csrq[memregion_id:%0d] --> unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d", i,
              csrq[i].unit.name(), csrq[i].mig_nunitid,
              csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),
          UVM_LOW) 
    end

    rpn = 0; //ioaiu_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number
        if(ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs > 0) begin
           addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUAMIGR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUAMIGR.get_offset()<%}%>;
           data[0] = 1;
           data[4:1] = ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs;
           data[31:5] = 0;
           write_chk<%=qidx%>(addr,data, k_csr_access_only, nonblocking);
	end
        foreach (csrq[ig]) begin
           //Write to GPR register sets with appropriate values.
           //GPRBLR : 12'b01XX XXXX 0100 ; addr[11:0] = {2'b01,ig[5:0],4'h4};
           addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUGPRBLR0.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUGPRBLR0.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUGPRBLR0")%>;=12'h<%=getIoOffset("XAIUGPRBLR0")%>;
           addr[9:4] = ig[5:0];
           data[31:0] = csrq[ig].low_addr;
	   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s low_addr 0x%0h GPRBLR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].low_addr, addr, data), UVM_LOW)
           addr[19:12]=rpn;// Register Page Number
           write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
           //GPRBHR : 12'b01XX XXXX 1000 ; addr[11:0] = {2'b01,ig[5:0],4'h8};
           addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUGPRBHR0.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUGPRBHR0.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUGPRBHR0")%>;=12'h<%=getIoOffset("XAIUGPRBHR0")%>;
           addr[9:4] = ig[5:0];
           //data =0;
           //data[7:0] = csrq[ig].upp_addr;
           data[31:0] = csrq[ig].upp_addr;
	   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s upp_addr 0x%0h GPRHLR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].upp_addr, addr, data), UVM_LOW)
           write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

           //GPRAR : 12'b01XX XXXX 0000 ; addr[11:0] = {2'b01,ig[5:0],4'h0};
           addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUGPRAR0.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUGPRAR0.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUGPRAR0")%>;=12'h<%=getIoOffset("XAIUGPRAR0")%>;
           addr[9:4] = ig[5:0];
           data =0; // Reset value
           data[31]    = 1; // Valid
           data[30]    = (csrq[ig].unit == ncore_config_pkg::ncoreConfigInfo::DII ? 1 : 0); // Home Unit Type
           data[25:20] = csrq[ig].size; // interleave group member size(2^(size+12) bytes)
           data[13:9]  = csrq[ig].mig_nunitid;
           if ($test$plusargs("random_gpra_nsx")) begin
            data[7:6]   = csrq[ig].nsx;// randomize GPRAR.NS filed NSX[0] = NS :NS=0 Only secure transactions NS=1 All transactions are accepted
           end 
           else if ($test$plusargs("gpra_secure_uncorr_err")) begin
             //#Stimulus.FSYS.address_dec_error.illegal_non_secure_txn
             data[7:6]   = 'h0;  
           end 
           else begin
             data[7:6]   = 'h1;  
           end
           begin:_gprar_nc // if GPRAR.NC field exist, write it
            //#Stimulus.FSYS.dii_noncoh_txn  
            //#Stimulus.FSYS.GPRAR.NC_zero
            //#Stimulus.FSYS.GPRAR.NC_one
            uvm_reg gprar;
            uvm_reg  xaiupctcr ;
            ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t xaiupctcr_addr_offset;
            ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t xaiupctcr_recompute_addr = addr; // get the base address + rpn;
            //gprar= m_concerto_env.m_regs.default_map.get_reg_by_offset(addr);
            gprar= m_concerto_env.m_regs.default_map.get_reg_by_offset({ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE_COPY[51:20],addr[19:0]});
            xaiupctcr= m_concerto_env.m_regs.get_reg_by_name("XAIUPCTCR"); // get the first register just to get the offset
            if (xaiupctcr) begin :_unless_one_pctcr //useCache
                xaiupctcr_addr_offset = xaiupctcr.get_offset(); // get lower address =register offset
                xaiupctcr_recompute_addr[11:0] = xaiupctcr_addr_offset[11:0];  // apply base address + rpn +  register offset
                //xaiupctcr = m_concerto_env.m_regs.default_map.get_reg_by_offset(xaiupctcr_recompute_addr);
                xaiupctcr = m_concerto_env.m_regs.default_map.get_reg_by_offset({ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE_COPY[51:20],xaiupctcr_recompute_addr[19:0]});
                if (xaiupctcr && xaiupctcr.get_field_by_name("LookupEn")) begin: _field_exist   // last check with "Lookup_en" field exit => useCache
                   data[5] = csrq[ig].nc ;
                end:_field_exist else begin:_no_field
                    if (gprar.get_field_by_name("NC")) data[5] = csrq[ig].nc; // ($test$plusargs("coherent_dii")) ? csrq[ig].nc :1;  // if no useCache => AXI4 without proxycache => assert GPRAR.NCmode=1 by default
                end:_no_field
            end:_unless_one_pctcr else begin: _no_pctcr // no useCache
                if (gprar.get_field_by_name("NC")) data[5] =  csrq[ig].nc; // ($test$plusargs("coherent_dii")) ? csrq[ig].nc :1;  // if no useCache => AXI4 without proxycache => assert GPRAR.NCmode=1 by default
            end:_no_pctcr
           end:_gprar_nc
           data[4:1]   = csrq[ig].order;//bit0(Hazard bit) is deprecated; CONC-11405
	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s size %0d order 0x%0h NC:%0h GPRAR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].size, csrq[ig].order, csrq[ig].nc,addr, data), UVM_LOW)
           write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
        end
        
        rpn++;
    end

    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        read_csr<%=qidx%>(addr,infor); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        //Unit Type: 0b000=Coherent Agent Interface Unit (CAIU), 0b001=Non-Coherent Agent Interface Unit (NCAIU), 0b010 - Non-coherent Agent Interface Unit with Proxy Cache (NCAIU)
        //Unit Sub-Types: for CAIU 0b000=ACE, 0b001=CHI-A, 0b010=CHI-B, 0b011-0b111:Reserved; for NCAIU 0b000=AXI, 0b001=ACE-Lite, 0b010=ACE-Lite-E, 0b011-0b111=Reserved
        if(infor[19:16] > 4'h2) begin //UST
           //`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Improper Unit Sub-Types for AIU%0d : %0d", i, infor[19:16]),UVM_NONE)
           `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Improper Unit Sub-Types for AIU%0d : %0d", i, infor[19:16]))
        end
           // Enable Error detection to enable error correction feature by default
           //XAIUUEDR : 12'b0001 0000 0000
           addr[11:0] = 'h0;
           <% if(numChiAiu > 0) { %>
                 addr[11:0] = m_concerto_env.m_regs.<%=chiaiu0%>.CAIUUEDR.get_offset(); // 12'h<%=getIoOffset("CAIUUEDR")%>;
            <% } else { %>
                 addr[11:0] = m_concerto_env.m_regs.<%=ioaiu0%>.XAIUUEDR.get_offset(); // 12'h<%=getIoOffset("XAIUUEDR")%>;
            <% } %>
           if (addr[11:0]) begin
              data=32'h0; // data[3]:DecErrDetEn
              read_csr<%=qidx%>(addr,data);
              data=data | 32'h8; // data[3]:DecErrDetEn
	          `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing aiu%0d xAIUUEDR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              write_chk<%=qidx%>(addr,data,k_csr_access_only);
           end

        if(infor[19:16] > 0) begin // NCAIU  
           if (infor[19:16] == 2) begin:_setup_ccp_ioc<%=qidx%> // INFOR = 2= NCAIU with Proxycache
           // XAIUPCTCR offset
            <%
              // first find XAIUPCTCR
              var XAIUPCTCR;  
              obj.AiuInfo.every( agent => {
                XAIUPCTCR = agent.csr.spaceBlock[0].registers.find(register => register.name === 'XAIUPCTCR');
               if (XAIUPCTCR) return false; // if not null found! => stop every fction
               return true;
              });
              if (XAIUPCTCR) { //if XAIUPCTCR exist
               var lookupen = XAIUPCTCR.fields.find(field => field.name === 'LookupEn');
               var allocen = XAIUPCTCR.fields.find(field => field.name === 'AllocEn');
               var UpdateDis = XAIUPCTCR.fields.find(field => field.name === 'UpdateDis');
            %>
            addr[11:0] = <%=XAIUPCTCR.addressOffset%>; // XAIUPCTCR OFFSET // ADDR[11:0] OFFSET always the same foreach AIU
            data=32'h0;
            // legacy lookupen & allocen =1 TODO randomize
            if($test$plusargs("rand_alloc_lookup")) begin
                //#Stimulus.FSYS.PxC.noallocen_rand           
                data[<%=lookupen.bitOffset%>]   = $urandom_range(0,1);  //lookupen
                data[<%=allocen.bitOffset%>]    = $urandom_range(0,1); //allocen            
            end else begin
                data[<%=lookupen.bitOffset%>]   = ccp_lookupen; //lookupen
                data[<%=allocen.bitOffset%>]    = ccp_allocen; //allocen
            end 
            //#Cover.FSYS.PROXY.UpdateDis 
            <% if (obj.initiatorGroups.length > 1) { %>
            update_cmd_disable = 1;// if connectivity feature disable update channel in the proxy cache
            <%}%>
            data[<%=UpdateDis.bitOffset%>]  = update_cmd_disable; //UpdateDis
	        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn:%0d aiu:%0d XAIUPCTCR (0x%0h) = 0x%0h",rpn,i, addr, data), UVM_LOW)
            write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
            <% } // if XAIUPCTCR exist %>
           end:_setup_ccp_ioc<%=qidx%>

	end // if (data[19:16] == 4'h1 || data[19:16] == 4'h2)

     <% if (numNCAiu > 0) { %>
         //infor[19:16] == xAIUINFOR.UT = 0(coh)||1(noncoh)||2(noncoh with proxy cache)
         //infor[22:20] == xAIUINFOR.UST = 0(ace)||1(chiA)||2(chib)  0(AXI)||1(ACE-LITE)||2(ACE-LITE-E)
           if(infor[22:20] == 1 || infor[19:16] == 2)  begin:_transorder  // Program XAIUTCR.TransOrderMode for NCAIU
                if(!$value$plusargs("ace_transorder_mode=%d", transorder_mode)) begin
                    randcase
                        10:    transorder_mode= 3;  // 2: Pcie_order 3:strict request order
                        90:    transorder_mode= 2; 
                    endcase
                  end
           addr[11:0] = m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTCR.get_offset();
	       data = (transorder_mode << m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTCR.TransOrderModeRd.get_lsb_pos()) | (transorder_mode << m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTCR.TransOrderModeWr.get_lsb_pos());
	       data = data | (1 << m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTCR.EventDisable.get_lsb_pos());
	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Programming rpn %0d XAIUTCR.TransOrderMode to %0d ", rpn, transorder_mode), UVM_NONE)
	       write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
	    end:_transorder
        <% } %>

        <% if(numChiAiu > 0) { %>
        if((infor[19:16] == 0) && (infor[19:16] < 3) && (infor[19:16] > 0))  begin  // Enable SysEvent for CHI-AIU
           addr[11:0] = m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTCR.get_offset();
	   data = sys_event_disable << m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTCR.EventDisable.get_lsb_pos();

	   data = data | (0 << m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTCR.SysCoDisable.get_lsb_pos());
	   write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

           addr[11:0] = m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTOCR.get_offset();
	   data = chiaiu_timeout_val;
	   write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
        end
        <% } %>

        <% if(obj.AiuInfo[0].fnEnableQos == 1) { %>
        if($value$plusargs("qos_threshold=%d", qos_threshold)) begin
            // Program QOS Event Threshold
            addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUQOSCR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUQOSCR.get_offset()<%}%>;
            write_chk<%=qidx%>(addr, qos_threshold, k_csr_access_only, nonblocking);
        end
        if($test$plusargs("aiu_qos_threshold")) begin
            addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUQOSCR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUQOSCR.get_offset()<%}%>;
	    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Programming rpn %0d XAIUQOSCR.EventThreshold to aiu_qos_threshold[%0d]=%0d ", rpn, rpn, aiu_qos_threshold[rpn]), UVM_LOW)
            write_chk<%=qidx%>(addr, aiu_qos_threshold[rpn], k_csr_access_only, nonblocking);
	end
        <% } %>

        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        read_csr<%=qidx%>(addr,infor); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        if(infor[19:16] == 4'h2) begin // NCAIU
              // Enable Error detection to enable error correction feature by default
              //XAIUCECR : 12'b0001 0100 0000
	      <% if(numNCAiu > 0) { %>
              addr[11:0] = m_concerto_env.m_regs.<%=ncaiu0%>.XAIUCECR.get_offset(); // 12'h<%=getIoOffset("XAIUCECR")%>;
              data=32'h1; // data[0]:ErrDetEn
	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Waiting aiu %0d XAIUCECR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
              <% } %>

	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Initializing SMC Tag Memory for rpn %0d ", rpn), UVM_LOW)
              //USMCMCR0 : 12'b0000 0101 1000 ; addr[11:0]=12'h58;
              addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=ioAiuWithPC%>.XAIUPCMCR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMCR")%>;
              data = 32'h0; // data[21:16] : Tag_0/Data_1 memory array; data[3:0]: CacheMntOp :  Initialize all Entries
              write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);

              // Wait for Initialization to start
              //USMCMAR0 : 12'b0000 0101 1100 ; addr[11:0]=12'h5C;
	      //`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Waiting for initializing PC Tag Memory for rpn %0d to start", rpn), UVM_LOW)
              //addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=ioAiuWithPC%>.XAIUPCMAR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMAR")%>;
              //do begin
              //   read_csr<%=qidx%>(addr,data);
              //end while (!data[0]); // data[0] : Maintanance Operation Active 

	end // if (data[19:16] == 4'h2)
       rpn++;
    end // for (int i=0; i<nAIUs; i++)				   
				   
    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        read_csr<%=qidx%>(addr,data); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        if(data[19:16] == 4'h2) begin // NCAIU with proxycache
              // Wait for SMC Tag Mem Initialization to complete
	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Waiting for initializing PC Tag Memory for rpn %0d to complete", rpn), UVM_LOW)
              addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=ioAiuWithPC%>.XAIUPCMAR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMAR")%>;
              do begin
                 read_csr<%=qidx%>(addr,data);
              end while (data[0]); // data[0] : Maintanance Operation Active 
	end // if (data[19:16] == 4'h1 || data[19:16] == 4'h2)
        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        read_csr<%=qidx%>(addr,data); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        if(data[19:16] == 4'h2) begin // NCAIU with proxycache
              // Initialize data memory Array
	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Initializing PC Data Memory for rpn %0d ", rpn), UVM_LOW)
              //USMCMCR0 : 12'b0000 0101 1000 ; addr[11:0]=12'h58;
              addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=ioAiuWithPC%>.XAIUPCMCR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMCR")%>;
              data = 32'h10000; // data[21:16] : Tag_0/Data_1 memory array; data[3:0]: CacheMntOp :  Initialize all Entries
              write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);

              // Wait for Initialization to start
              //USMCMAR0 : 12'b0000 0101 1100 ; addr[11:0]=12'h5C;
	      //`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Waiting for initializing PC Data Memory for rpn %0d to start", rpn), UVM_LOW)
              //addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=ioAiuWithPC%>.XAIUPCMAR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMAR")%>;
              //do begin
              //   read_csr<%=qidx%>(addr,data);
              //end while (!data[0]); // data[0] : Maintanance Operation Active 
	end // if (data[19:16] == 4'h1 || data[19:16] == 4'h2)
        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        read_csr<%=qidx%>(addr,data); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        if(data[19:16] == 4'h2) begin // NCAIU with proxycache
              // Wait for Initialization to complete
	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Waiting for initializing PC Data Memory for rpn %0d to complete", rpn), UVM_LOW)
              addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=ioAiuWithPC%>.XAIUPCMAR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMAR")%>;
              do begin
                 read_csr<%=qidx%>(addr,data);
              end while (data[0]); // data[0] : Maintanance Operation Active 
	end // if (data[15:12] == 4'h1 || data[15:12] == 4'h2)
        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    // (4) Initialize DCEs
    //rpn = nAIUs;
    for(int i=0; i<nDCEs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(k_csr_access_only == 1) begin
           // Wait for any activity to complete
           //DCEUSFMAR : 12'b0010 0100 0100 ; addr[11:0]=12'h244;
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSFMAR.get_offset(); // 12'h<%=getDceOffset("DCEUSFMAR")%>;
           do begin
              read_csr<%=qidx%>(addr,data);
           end while (data[0]); // data[0] : Maintanance Operation Active 

           // Initialize Snoop Filter Memory(By default initially this is done as reset value is 0)
           //DCEUSFMCR: 12'b0010 0100 0000 ; addr[11:0]=12'h240;
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSFMCR.get_offset(); // 12'h<%=getDceOffset("DCEUSFMCR")%>;
           data = 32'h1; // data[0] Toggle the bit to start snoop filter initialization, setting 1 resets the initialization counter
           write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);
           data = 32'h0; // data[0] Toggle the bit to start snoop filter initialization, setting 0 will start using counter
           write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);

           //DCEUSFMAR : 12'b0010 0100 0100 ; addr[11:0]=12'h244;
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSFMAR.get_offset(); // 12'h<%=getDceOffset("DCEUSFMAR")%>;
           // Wait for any activity to start
           //`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$psprintf("Waiting for SnoopFiler initialization to start"),UVM_LOW) 
           //do begin
           //   read_csr<%=qidx%>(addr,data);
           //end while (!data[0]); // data[0] : Maintanance Operation Active 
           // Wait for any activity to complete
           `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$psprintf("Waiting for SnoopFiler initialization to complete"),UVM_LOW) 
           do begin
              read_csr<%=qidx%>(addr,data);
           end while (data[0]); // data[0] : Maintanance Operation Active 

           //DCEUINFOR : 12'b1111 1111 1000 ; addr[11:0]=12'hFF8;
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUINFOR.get_offset(); // 12'h<%=getDceOffset("DCEUINFOR")%>;
           read_csr<%=qidx%>(addr,data);
           if(data[19:16] != 4'h8) begin // UT/Unit Type: should be 4'b1000 for DCE
              `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("DCE%0d Information register Unit type unexpected: Exp:%0h Act:%0h", i, 4'h8,data[19:16]))
           end
        end  //CHECK CSR
        
           // Enable Error detection to enable error correction feature by default
           //XAIUUEDR : 12'b0001 0000 0000
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUUEDR.get_offset(); 
           data=32'h0; // data[3]:DecErrDetEn
           read_csr<%=qidx%>(addr,data);
           data=data | 32'h8; // data[3]:DecErrDetEn
	         `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing DCE%0d DCEUUEDR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
           write_chk<%=qidx%>(addr,data,k_csr_access_only);

        foreach (csrq[ig]) begin
           //Write to GPR register sets with appropriate values.
           //GPRBLR : 12'b01XX XXXX 0100 ; addr[11:0] = {2'b01,ig[5:0],4'h4};
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUGPRBLR0.get_offset(); // 12'h<%=getDceOffset("DCEUGPRBLR0")%>;
           addr[9:4]=ig[5:0];
           data[31:0] = csrq[ig].low_addr;
	   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s low_addr 0x%0h GPRBLR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].low_addr, addr, data), UVM_LOW)
           write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

           //GPRBHR : 12'b01XX XXXX 1000 ; addr[11:0] = {2'b01,ig[5:0],4'h8};
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUGPRBHR0.get_offset(); // 12'h<%=getDceOffset("DCEUGPRBHR0")%>;
           addr[9:4]=ig[5:0];
           //data =0;
           //data[7:0] = csrq[ig].upp_addr;
           data[31:0] = csrq[ig].upp_addr;
	   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s upp_addr 0x%0h GPRHLR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].upp_addr, addr, data), UVM_LOW)
           write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

           //GPRAR : 12'b01XX XXXX 0000 ; addr[11:0] = {2'b01,ig[5:0],4'h0};
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUGPRAR0.get_offset(); // 12'h<%=getDceOffset("DCEUGPRAR0")%>;
           addr[9:4]=ig[5:0];
           data =0; // Reset value
           data[31]    = 1; // Valid
           data[30]    = (csrq[ig].unit == ncore_config_pkg::ncoreConfigInfo::DII ? 1 : 0); // Home Unit Type
           data[25:20] = csrq[ig].size; // interleave group member size(2^(size+12) bytes)
           data[13:9]  = csrq[ig].mig_nunitid;
           data[4:1]   = csrq[ig].order;//bit0(Hazard bit) is deprecated; CONC-11405
	   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s size %0d GPRAR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].size, addr, data), UVM_LOW)
           write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
        end

        addr[11:0] = m_concerto_env.m_regs.dce0.DCEUAMIGR.get_offset(); // 12'h<%=getDceOffset("DCEUAMIGR")%>; addr[11:0] = 12'h3c0; 
        data = 32'h0; data[4:0]={ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs,1'b1};
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dce %0d DCEUAMIGR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
        write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

        // Enable VB recovery on wr/up; TODO : Temporary Enabled through Register; later will be enabled by default (No register)
        // TODO: Disable for now. Enable later
        addr[11:0] = m_concerto_env.m_regs.dce0.DCEUEDR0.get_offset(); // 12'h<%=getDceOffset("DCEUEDR0")%>; addr[11:0] = 12'hA00; 
        read_csr<%=qidx%>(addr,data);
        write_chk<%=qidx%>(addr,data | (0<<10),k_csr_access_only, nonblocking);

        // Enable Error detection to enable error correction feature by default
        //DCEUCECR : 12'b0001 0100 0000
        addr[11:0] = m_concerto_env.m_regs.dce0.DCEUCECR.get_offset(); // 12'h<%=getDceOffset("DCEUCECR")%>;
        data=32'h1; // data[0]:ErrDetEn
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dce %0d DCEUCECR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
        write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
            
        <% if (obj.DceInfo[0].fnEnableQos == 1) { %> 
        if($value$plusargs("qos_threshold=%d", qos_threshold)) begin
            // Program QOS Event Threshold
            addr[11:0] = m_concerto_env.m_regs.dce0.DCEUQOSCR0.get_offset(); // 12'h<%=getDceOffset("DCEUEDR0")%>; addr[11:0] = 12'hA00; 
            write_chk<%=qidx%>(addr, qos_threshold, k_csr_access_only, nonblocking);
        end
        if($test$plusargs("dce_qos_threshold")) begin
            addr[11:0] = m_concerto_env.m_regs.dce0.DCEUQOSCR0.get_offset(); // 12'h<%=getDceOffset("DCEUEDR0")%>; addr[11:0] = 12'hA00; 
	    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Programming rpn %0d DCEQOSCR0.EventThreshold to dce_qos_threshold[%0d]=%0d ", rpn, rpn-<%=obj.nAIUs%>, dce_qos_threshold[rpn-<%=obj.nAIUs%>]), UVM_LOW)
            write_chk<%=qidx%>(addr, dce_qos_threshold[rpn-<%=obj.nAIUs%>], k_csr_access_only, nonblocking);
        end
        <% } %>

        if($test$plusargs("sysco_disable")) begin
        addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSER0.get_offset();
        //data = <%=SnoopEn%>;  //FFFFFFF - FIXME
        data = 32'hFFFF_FFFF;
        write_csr<%=qidx%>(addr,data, nonblocking);

	<%if(obj.DceInfo[0].nAius > 32) { %>
	addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSER1.get_offset();
	data = 32'hFFFF_FFFF;
	write_csr<%=qidx%>(addr, data, nonblocking);
    	<%}%>

	<%if(obj.DceInfo[0].nAius > 64) { %>
	addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSER2.get_offset();
	data = 32'hFFFF_FFFF;
	write_csr<%=qidx%>(addr, data, nonblocking);
    	<%}%>
        end

        addr[11:0] = m_concerto_env.m_regs.dce0.DCEUTCR.get_offset();
	data = sys_event_disable << m_concerto_env.m_regs.dce0.DCEUTCR.EventDisable.get_lsb_pos();
	write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

        addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSBSIR.get_offset(); 
        read_csr<%=qidx%>(addr,data);
	`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ-sw_credit_mgmt", $sformatf("[DCE REG] Reading rpn %0d DCEUSBSIR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        if(data[31]==1) begin
          act_cmd_skid_buf_size["DCE"][i]=data[25:16];
          act_cmd_skid_buf_arb["DCE"][i]=data[7:0];
        end else begin
          `uvm_error("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("[DCE REG] Valid bit not asserted in DCEUSBSIR-%0d ADDR 0x%0h DATA 0x%0h", i, addr, data))
        end
        rpn++;
    end

    if(exp_cmd_skid_buf_size["DCE"].size != act_cmd_skid_buf_size["DCE"].size) begin
        `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DCE] exp_cmd_skid_buf_size[DCE].size %0d != act_cmd_skid_buf_size[DCE].size %0d",exp_cmd_skid_buf_size["DCE"].size,act_cmd_skid_buf_size["DCE"].size))
    end
    foreach(exp_cmd_skid_buf_size["DCE"][temp]) begin
        if(exp_cmd_skid_buf_size["DCE"][temp]!= act_cmd_skid_buf_size["DCE"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DCE] exp_cmd_skid_buf_size[DCE][%0d] %0d != act_cmd_skid_buf_size[DCE][%0d] %0d",temp,exp_cmd_skid_buf_size["DCE"][temp],temp,act_cmd_skid_buf_size["DCE"][temp]))
        end
        if(exp_cmd_skid_buf_arb["DCE"][temp]!= act_cmd_skid_buf_arb["DCE"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DCE] exp_cmd_skid_buf_arb[DCE][%0d] %0d != act_cmd_skid_buf_arb[DCE][%0d] %0d",temp,exp_cmd_skid_buf_arb["DCE"][temp],temp,act_cmd_skid_buf_arb["DCE"][temp]))
        end
    end

    // (5) Initialize DMIs ( dmi*_DMIUSMCTCR)
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
              addr[11:0] = <%if(numDmiWithSP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSP].strRtlNamePrefix%>.DMIUSMCSPBR0.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCSPBR0")%>;
              data= ScPadBaseAddr[31:0];
              `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCSPBR0 (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

              if(ncore_config_pkg::ncoreConfigInfo::WCACHE_OFFSET > 32) begin
                 //DMIUSMCSPBR1 : 12'b0011 0011 0100
                 addr[11:0] = <%if(numDmiWithSP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSP].strRtlNamePrefix%>.DMIUSMCSPBR1.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCSPBR1")%>;
                 data= ScPadBaseAddr >> 32 ; // ScPadBaseAddrHi
                 `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCSPBR1 (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
                 write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
              end

              //DMIUSMCSPCR0 : 12'b0011 0011 1000
              addr[11:0] = <%if(numDmiWithSP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSP].strRtlNamePrefix%>.DMIUSMCSPCR0.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCSPCR0")%>;
	      data = 'h0;
              data[0]   = ScPadEn; // data[0] = (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]) ? ScPadEn : 0
              data[6:1] = sp_ways[i]-1; // NumScPadWays=ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]-1 ,
              `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCSPCR0 (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

              //DMIUSMCSPCR1 : 12'b0011 0011 1100
              addr[11:0] = <%if(numDmiWithSP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSP].strRtlNamePrefix%>.DMIUSMCSPCR1.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCSPCR1")%>;
              data= sp_size[i]-1; // Scratchpad size in number of cachelines.
              `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCSPCR1 (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
           end

           // Configure policies
           //DMIUSMCTCR : 12'b0011 0000 0000
           addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCTCR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCTCR")%>;
           if($test$plusargs("dmi_alloc_dis")) begin
              data=32'h1; // data[1]:AllocEn , data[0]:LookupEn
           end else begin
              data=32'h3; // data[1]:AllocEn , data[0]:LookupEn
           end
           if($test$plusargs("rand_alloc_lookup")) begin
            //#Stimuls.FSYS.SMC.noallocen_rand
              data[1]  = dmi_nallocen_rand ;
              data[0]  = dmi_nlooken_rand ;
            end

           `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCTCR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
           write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
 
           //DMIUSMCAPR : 12'b0011 0000 1000
           addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCAPR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCAPR")%>;
           //#Check.FSYS.SMC.TOFAllocDisable
           //#Check.FSYS.SMC.ClnWrAllocDisable
           //#Check.FSYS.SMC.DtyWrAllocDisable
           //#Check.FSYS.SMC.RdAllocDisable
           //#Check.FSYS.SMC.WrAllocDisable 
           // by defautl data = 0 ,when dmiusmc_policy test is enabled dmiusmc_policy reg field will be set to 1
           if($test$plusargs("dmiusmc_policy_test")) begin
            data = dmiusmc_policy_rand; // data[4]:WrAllocDisable , data[3]:RdAllocDisable , data[2]:DtyWrAllocDisable , data[1]:ClnWrAllocDisable , data[0]:TOFAllocDisable
           end else begin
            data = dmiusmc_policy; // data[4]:WrAllocDisable , data[3]:RdAllocDisable , data[2]:DtyWrAllocDisable , data[1]:ClnWrAllocDisable , data[0]:TOFAllocDisable
           end 
           `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCAPR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
           write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
 
           // Configure way partitioning // TODO what if SP and Way partitioning both are enabled together
           if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcwp[i]) begin  
              if ($test$plusargs("no_way_partitioning")) begin
                 for( int j=0;j<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];j++) begin
                    //DMIUSMCWPCR0 : 12'b0011 0100 0000
                    addr[11:0] = <%if(numDmiWithWP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithWP].strRtlNamePrefix%>.DMIUSMCWPCR00.get_offset()+ (j*8) <%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCWPCR00")%>;
                    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCWPCR0%0d (0x%0h) = 0x%0h", i, j, addr, j), UVM_LOW)
                    write_chk<%=qidx%>(addr,j,k_csr_access_only, nonblocking);
                 end
              end else begin
                //bit [31:0] agent_ids_assigned_q[$];
                //int shared_ways_per_user;
                for( int j=0;j<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];j++) begin
                   bit [31:0] agent_id;
                   agent_id = agent_ids_assigned_q[i][j];
                   //DMIUSMCWPCR0 : 12'b0011 0100 0000
                   addr[11:0] = <%if(numDmiWithWP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithWP].strRtlNamePrefix%>.DMIUSMCWPCR00.get_offset()+ (j*8) <%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCWPCR00")%>;
                   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCWPCR0%0d (0x%0h) = 0x%0h", i, j, addr, agent_id), UVM_LOW)
                   write_chk<%=qidx%>(addr,agent_id,k_csr_access_only, nonblocking);

                   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("dmi %0d way-part reg no %0d vld %0b id %0h", i, j, agent_id[31], agent_id[30:0]), UVM_LOW)

                   data = wayvec_assigned_q[i][j];
                   //DMIUSMCWPCR1 : 12'b0011 0100 0100
                   addr[11:0] = <%if(numDmiWithWP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithWP].strRtlNamePrefix%>.DMIUSMCWPCR10.get_offset()+ (j*8) <%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCWPCR10")%>;
                   write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
                   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("dmi %0d way-part reg no %0d way %0b", i, j, data), UVM_LOW)
                end
              end // if ($test$plusargs("no_way_partitioning")) begin
           end

           if(k_csr_access_only) begin
              //DMIUSMCIFR : 12'b1111 1111 1000
              addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCIFR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCIFR")%>;
              read_csr<%=qidx%>(addr,data);
              if((data[19: 0] == (ncore_config_pkg::ncoreConfigInfo::dmi_CmcSet[i] ? ncore_config_pkg::ncoreConfigInfo::dmi_CmcSet[i]-1 : 0 )) && // Data[19:0] NumSet
                 (data[25:20] == (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i] ? ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]-1 : 0 )) && // Data[25:20] NumWay
                 (data[26:26] == (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcsp[i])) && // Data[26:26] SP: ScratchPad Support Exist
                 (data[27:27] == (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcwp[i])) && // Data[27:27] WP: Way Partitioning Support Exist
                 (data[31:28] == (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i] ? ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i]-1 : 0 )) // Data[31:28] NumWayPartitionig Registers
                ) begin
                 `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Read dmi %0d DMIUSMCIFR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              end else begin
                 `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Read dmi %0d DMIUSMCIFR (0x%0h) = 0x%0h, Sets/Ways mismatch", i, addr, data))
              end

              //DMIUINFOR : 12'b1111 1111 1100
              addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUINFOR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUINFOR")%>;
              read_csr<%=qidx%>(addr,data);
              if((data[19:16] == 'h9) && // Data[19:16] UT=DMI ('h9) unit type
                 (data[20  ] == ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) && // Data[13] SMC System Memory Cache present
                 (data[21  ] == ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[i]) && // Data[12] AE  Atomic Engine present
                 (data[31  ] == 'b1) // Data[31] Valid
                ) begin
                 `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Read dmi %0d DMIUINFOR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              end else begin
                 `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Read dmi %0d DMIUINFOR (0x%0h) = 0x%0h, UniteType/AtomicEngine/SMC/Valid mismatch", i, addr, data))
              end
           end
        end
        // Enable Error detection to enable error correction feature by default
        //DMIUCECR : 12'b0001 0100 0000
        addr[11:0] = m_concerto_env.m_regs.<%=DmiInfo[0].strRtlNamePrefix%>.DMIUCECR.get_offset(); // 12'h<%=getDmiOffset("DMIUCECR")%>;
        data=32'h1; // data[0]:ErrDetEn
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUCECR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
        write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
            
        <% if (obj.DmiInfo[0].fnEnableQos == 1) { %> 
 
        if($value$plusargs("qos_threshold=%d", qos_threshold)) begin
            // Program QOS Event Threshold
            addr[11:0] = m_concerto_env.m_regs.<%=DmiInfo[0].strRtlNamePrefix%>.DMIUQOSCR0.get_offset(); 
            write_chk<%=qidx%>(addr, qos_threshold, k_csr_access_only, nonblocking);
        end
        if($test$plusargs("dmi_qos_threshold")) begin
            // Program QOS Event Threshold
            addr[11:0] = m_concerto_env.m_regs.<%=DmiInfo[0].strRtlNamePrefix%>.DMIUQOSCR0.get_offset(); 
	    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Programming rpn %0d DMIQOSCR0.EventThreshold to dmi_qos_threshold[%0d]=%0d ", rpn, rpn-<%=obj.nAIUs%>-<%=obj.nDCEs%>, dmi_qos_threshold[rpn-<%=obj.nAIUs%>-<%=obj.nDCEs%>]), UVM_LOW)
            write_chk<%=qidx%>(addr, dmi_qos_threshold[rpn-<%=obj.nAIUs%>-<%=obj.nDCEs%>], k_csr_access_only, nonblocking);
        end
       
         if($test$plusargs("dmi_qos_rsved")) begin
            // Program QOS Event Threshold
            addr[11:0] = m_concerto_env.m_regs.<%=DmiInfo[0].strRtlNamePrefix%>.DMIUTQOSCR0.get_offset(); 
	    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Programming rpn %0d DMITQOSCR0 to dmi_qos_rsved[%0d]=%0d ", rpn, rpn-<%=obj.nAIUs%>-<%=obj.nDCEs%>, dmi_qos_rsved), UVM_LOW)
            write_chk<%=qidx%>(addr, dmi_qos_rsved, k_csr_access_only, nonblocking);
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
           addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCMCR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCMCR")%>;
           data = 32'h0; // data[21:16] : Tag_0/Data_1 memory array; data[3:0]: CacheMntOp :  Initialize all Entries
           write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);

	end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i])
        rpn++;
    end			   

    rpn = cur_rpn;
    for(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) begin  
           // Wait for Tag Mem Initialization to complete
           //DMIUSMCMAR : 12'b0011 0001 0100
           addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCMAR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCMAR")%>;
           do begin
              read_csr<%=qidx%>(addr,data);
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
           addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCMCR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCMCR")%>;
           data = 32'h10000; // data[21:16] : Tag_0/Data_1 memory array; data[3:0]: CacheMntOp :  Initialize all Entries
           write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);
	end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i])
        rpn++;
    end			   

    rpn = cur_rpn;
    for(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) begin  
           // Wait for Data Mem Initialization to complete
           //DMIUSMCMAR : 12'b0011 0001 0100
           addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCMAR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCMAR")%>;
           do begin
              read_csr<%=qidx%>(addr,data);
           end while (data[0]); // data[0] : Maintanance Operation Active 
	end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i])

        addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.MRDSBSIR.get_offset(); 
        read_csr<%=qidx%>(addr,data);
	`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ-sw_credit_mgmt", $sformatf("[DMI REG] Reading rpn %0d MRDSBSIR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        if(data[31]==1) begin
          act_mrd_skid_buf_size["DMI"][i]=data[25:16];
          act_mrd_skid_buf_arb["DMI"][i]=data[7:0];
        end else begin
          `uvm_error("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI REG] Valid bit not asserted in MRDSBSIR-%0d ADDR 0x%0h DATA 0x%0h", i, addr, data))
        end

        addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.CMDSBSIR.get_offset(); 
        read_csr<%=qidx%>(addr,data);
	`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ-sw_credit_mgmt", $sformatf("[DMI REG] Reading rpn %0d CMDSBSIR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        if(data[31]==1) begin
          act_cmd_skid_buf_size["DMI"][i]=data[25:16];
          act_cmd_skid_buf_arb["DMI"][i]=data[7:0];
        end else begin
          `uvm_error("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI REG] Valid bit not asserted in CMDSBSIR-%0d ADDR 0x%0h DATA 0x%0h", i, addr, data))
        end

        rpn++;
    end			   

    if(exp_cmd_skid_buf_size["DMI"].size != act_cmd_skid_buf_size["DMI"].size) begin
        `uvm_error("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI] exp_cmd_skid_buf_size[DMI].size %0d != act_cmd_skid_buf_size[DMI].size %0d",exp_cmd_skid_buf_size["DMI"].size,act_cmd_skid_buf_size["DMI"].size))
    end
    foreach(exp_cmd_skid_buf_size["DMI"][temp]) begin
        if(exp_cmd_skid_buf_size["DMI"][temp]!= act_cmd_skid_buf_size["DMI"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI] exp_cmd_skid_buf_size[DMI][%0d] %0d != act_cmd_skid_buf_size[DMI][%0d] %0d",temp,exp_cmd_skid_buf_size["DMI"][temp],temp,act_cmd_skid_buf_size["DMI"][temp]))
        end
        if(exp_cmd_skid_buf_arb["DMI"][temp]!= act_cmd_skid_buf_arb["DMI"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI] exp_cmd_skid_buf_arb[DMI][%0d] %0d != act_cmd_skid_buf_arb[DMI][%0d] %0d",temp,exp_cmd_skid_buf_arb["DMI"][temp],temp,act_cmd_skid_buf_arb["DMI"][temp]))
        end
    end

    if(exp_mrd_skid_buf_size["DMI"].size != act_mrd_skid_buf_size["DMI"].size) begin
        `uvm_error("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("[DMI] exp_mrd_skid_buf_size[DMI].size %0d != act_mrd_skid_buf_size[DMI].size %0d",exp_mrd_skid_buf_size["DMI"].size,act_mrd_skid_buf_size["DMI"].size))
    end
    foreach(exp_mrd_skid_buf_size["DMI"][temp]) begin
        if(exp_mrd_skid_buf_size["DMI"][temp]!= act_mrd_skid_buf_size["DMI"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("[DMI] exp_mrd_skid_buf_size[DMI][%0d] %0d != act_mrd_skid_buf_size[DMI][%0d] %0d",temp,exp_mrd_skid_buf_size["DMI"][temp],temp,act_mrd_skid_buf_size["DMI"][temp]))
        end
        if(exp_mrd_skid_buf_arb["DMI"][temp]!= act_mrd_skid_buf_arb["DMI"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("[DMI] exp_mrd_skid_buf_arb[DMI][%0d] %0d != act_mrd_skid_buf_arb[DMI][%0d] %0d",temp,exp_mrd_skid_buf_arb["DMI"][temp],temp,act_mrd_skid_buf_arb["DMI"][temp]))
        end
    end

    cur_rpn = rpn;
    for(int i=0; i<nDIIs; i++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DiiInfo[0].strRtlNamePrefix%>.DIIUSBSIR.get_offset(); 
        read_csr<%=qidx%>(addr,data);
	`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("[DII REG] Reading rpn %0d CMDSBSIR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        if(data[31]==1) begin
          act_cmd_skid_buf_size["DII"][i]=data[25:16];
          act_cmd_skid_buf_arb["DII"][i]=data[7:0];
        end else begin
          `uvm_error("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("[DII REG] Valid bit not asserted in CMDSBSIR-%0d ADDR 0x%0h DATA 0x%0h", i, addr, data))
        end

        rpn++;
    end

    if(exp_cmd_skid_buf_size["DII"].size != act_cmd_skid_buf_size["DII"].size) begin
        `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ",$sformatf("[DII] exp_cmd_skid_buf_size[DII].size %0d != act_cmd_skid_buf_size[DII].size %0d",exp_cmd_skid_buf_size["DII"].size,act_cmd_skid_buf_size["DII"].size))
    end
    foreach(exp_cmd_skid_buf_size["DII"][temp]) begin
        if(exp_cmd_skid_buf_size["DII"][temp]!= act_cmd_skid_buf_size["DII"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ",$sformatf("[DII] exp_cmd_skid_buf_size[DII][%0d] %0d != act_cmd_skid_buf_size[DII][%0d] %0d",temp,exp_cmd_skid_buf_size["DII"][temp],temp,act_cmd_skid_buf_size["DII"][temp]))
        end
        if(exp_cmd_skid_buf_arb["DII"][temp]!= act_cmd_skid_buf_arb["DII"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ",$sformatf("[DII] exp_cmd_skid_buf_arb[DII][%0d] %0d != act_cmd_skid_buf_arb[DII][%0d] %0d",temp,exp_cmd_skid_buf_arb["DII"][temp],temp,act_cmd_skid_buf_arb["DII"][temp]))
        end
    end

    // program DVE SnpsEnb
    // rpn += nDIIs;
    if($test$plusargs("sysco_disable")) begin
        for(int i=0; i<nDVEs; i++) begin
            addr[19:12]=rpn;// Register Page Number
            addr[11:0] = m_concerto_env.m_regs.dve0.DVEUSER0.get_offset();
            data = <%=SnoopEn%>;
            write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);
         `ifdef USE_VIP_SNPS
            //CONC-9313
            addr[11:0] = m_concerto_env.m_regs.dve0.DVEUENGDBR.get_offset();
            data = 1;
            write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);
         `endif
            rpn++;
        end
    end	   
    //CONC-9313
   `ifdef USE_VIP_SNPS
    else begin
       for(int i=0; i<nDVEs; i++) begin
           addr[19:12]=rpn;// Register Page Number
           addr[11:0] = m_concerto_env.m_regs.dve0.DVEUENGDBR.get_offset();
           data = 1;
           write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);
           rpn++;
       end
    end	   
   `endif

<% var ioidx=0;
for(pidx=0; pidx<obj.nAIUs; pidx++) {
if((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")  || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || (obj.AiuInfo[pidx].fnNativeInterface == "AXI4")) {
    if(Array.isArray(obj.AiuInfo[pidx].rpn)) {
       rpn_val = obj.AiuInfo[pidx].rpn[0];
    } else {
       rpn_val = obj.AiuInfo[pidx].rpn;
    } %>
    addr[19:12] = <%=rpn_val%>;
    addr[11:0] = m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUTOCR.get_offset();
    data = ioaiu_timeout_val;
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d XAIUTOCR (0x%0h) = 0x%0h", <%=pidx%>, addr, data), UVM_LOW)
    write_csr<%=qidx%>(addr,data, 0);
     
<% } } %>

if(!$test$plusargs("sysco_disable")) begin
    // Setup SysCo Attach for IOAIUs
<% var ioidx=0;
for(pidx=0; pidx<obj.nAIUs; pidx++) {
if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache))) {
    if(Array.isArray(obj.AiuInfo[pidx].rpn)) {
       rpn_val = obj.AiuInfo[pidx].rpn[0];
    } else {
       rpn_val = obj.AiuInfo[pidx].rpn;
    } %>
    addr[19:12] = <%=rpn_val%>;
    addr[11:0] = m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUTCR.get_offset();
    read_csr<%=qidx%>(addr, data);
    data = data | (1 << m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUTCR.SysCoAttach.get_lsb_pos());
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d XAIUTCR.SysCoAttach (0x%0h) = 0x%0h", <%=pidx%>, addr, data), UVM_LOW)
    write_csr<%=qidx%>(addr,data, 0);
     
<% } } %>

// poll for SysCo Attached state
<% var ioidx=0;
for(pidx=0; pidx<obj.nAIUs; pidx++) {
if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache))) {
    if(Array.isArray(obj.AiuInfo[pidx].rpn)) {
       rpn_val = obj.AiuInfo[pidx].rpn[0];
    } else {
       rpn_val = obj.AiuInfo[pidx].rpn;
    } %>
    addr[19:12] = <%=rpn_val%>;
    addr[11:0] = m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUTAR.get_offset();
    do begin
       read_csr<%=qidx%>(addr, data);
       data = (data >> m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUTAR.SysCoAttached.get_lsb_pos()) & 1;
    end while(data == 0);
    <% if(obj.testBench!="emu") { %>
    // Let the ioaiu_scoreboard know we're now in ATTACHED state, see CONC-10924
    // Test should only be on ATTACHED but many fsys legacy files unduly set the the FSM in CONNECT as an equivalent state
    // Should be corrected in all files ideally but would be rather intrusive, due to multiport configs etc. TODO
    // Only core 0 should be considered as it's the AIU reference in multiport configs
    if(m_args.ioaiu_scb_en) begin
        if (!m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state inside {ioaiu<%=ioidx%>_env_pkg::CONNECT, ioaiu<%=ioidx%>_env_pkg::ATTACHED}) begin 
            m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state = ioaiu<%=ioidx%>_env_pkg::ATTACHED; 
            ev_sysco_fsm_state_change_<%=obj.AiuInfo[pidx].FUnitId%>.trigger();
            end
        else begin
        	`uvm_warning("IOAIU<%=qidx%>BOOT_SEQ", $psprintf("ioaiu<%=ioidx%> sysco_fsm_state already in %s state at ATTACH time", m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state.name()))
        	// `uvm_error("IOAIU<%=qidx%>BOOT_SEQ", $psprintf("ioaiu<%=ioidx%> sysco_fsm_state already in %s state at ATTACH time", m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state.name()))
	    end
    end
    <% } %>
<% } 
     if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))){ioidx++;}
} %>
end
    `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("using sw credit manager class"), UVM_LOW)
     boot_sw_crdt<%=qidx%>();

    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$sformatf("Leaving Boot Sequence"),UVM_NONE)
endtask: ioaiu_boot_seq<%=qidx%>

<% //}
qidx++; }
} %>
