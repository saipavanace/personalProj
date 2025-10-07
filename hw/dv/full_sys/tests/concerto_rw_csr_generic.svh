///////////////////////////////////////////////////////////
//                                                        //
//Description: external tasks for legacy tasks ncore      //
//                                                        //
//                                                        //
//File     : concerto_rw_csr_generic.sv                       //
//Author   : Cyrille LUDWIG                               //
////////////////////////////////////////////////////////////
<%

var chiA_present=0;
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

%>


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// Will be override by concerto_rw_csr_inhouse_tasks or concerto_rw_csr_snps_tasks
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
class concerto_rw_csr_generic extends uvm_component;

   `uvm_component_utils(concerto_rw_csr_generic)

   bit k_decode_err_illegal_acc_format_test_unsupported_size;
   bit ioaiu_csr_ns_access;

   //constructor
   extern function new(string name = "concerto_rw_csr_generic", uvm_component parent = null);
     // TASKS
    <% var chi_idx=0;%>
    <% for(var idx = 0;  idx < obj.nAIUs; idx++) {%> 
    <% if (obj.AiuInfo[idx].fnNativeInterface.match('CHI')) { %>
//   CLU TMP COMPILE FIX CONC-11383  if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
    virtual task write_chk_chi<%=chi_idx%>(input  chiaiu<%=chi_idx%>_chi_bfm_types_pkg::addr_width_t addr, bit[31:0] data, bit check=0, bit nonblocking=0);endtask
    virtual task write_csr_chi<%=chi_idx%>(input  chiaiu<%=chi_idx%>_chi_bfm_types_pkg::addr_width_t addr, bit[31:0] data, bit nonblocking=0);endtask
    virtual task read_csr_chi<%=chi_idx%>(input   chiaiu<%=chi_idx%>_chi_bfm_types_pkg::addr_width_t  addr, output bit[31:0] data);endtask
    virtual task read_csr_ral_chi<%=chi_idx%>(uvm_reg_field field, output uvm_reg_data_t fieldVal);endtask
    //task to set xNRSAR valid field for all AIU
    virtual task set_aiu_nrsar_reg_chi<%=chi_idx%>(); endtask
    <% chi_idx++;} }%>

 <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
//   CLU TMP COMPILE FIX CONC-11383  if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
    virtual task write_chk<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data, bit check=0, bit nonblocking=0);endtask
    virtual task write_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data, bit nonblocking=0); endtask
    virtual task read_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, output bit[31:0] data); endtask
    virtual task read_csr_ral<%=qidx%>(uvm_reg_field field, output uvm_reg_data_t fieldVal);endtask
    //task to set xNRSAR valid field for all AIU
    virtual task set_aiu_nrsar_reg<%=qidx%>(); endtask
    <% //} 
    qidx++; }
    } %>
endclass: concerto_rw_csr_generic


function concerto_rw_csr_generic::new(string name = "concerto_rw_csr_generic", uvm_component parent = null);

  super.new(name,parent);
    
endfunction: new