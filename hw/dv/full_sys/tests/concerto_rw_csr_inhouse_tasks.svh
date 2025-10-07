///////////////////////////////////////////////////////////
//                                                        //
//Description: external tasks for legacy tasks ncore      //
//                                                        //
//                                                        //
//File     : concerto_rw_csr_inhouse_tasks.sv                       //
//Author   : Cyrille LUDWIG                               //
////////////////////////////////////////////////////////////
<%
let numChiAiu = 0; // Number of CHI AIUs
let numACEAiu = 0; // Number of ACE AIUs
let numIoAiu = 0; // Number of IO AIUs
let numCAiu = 0; // Number of Coherent AIUs
let numNCAiu = 0; // Number of Non-Coherent AIUs
let numBootIoAiu = 0; // Number of NCAIUs can participate in Boot
let chiaiu0;  // strRtlNamePrefix of chiaiu0
let aceaiu0;  // strRtlNamePrefix of aceaiu0
let ncaiu0;   // strRtlNamePrefix of aceaiu0
let idxIoAiuWithPC = obj.nAIUs; // To get valid index of NCAIU with ProxyCache. Initialize to nAIUs
let numDmiWithSMC = 0; // Number of DMIs with SystemMemoryCache
let idxDmiWithSMC = 0; // To get valid index of DMI with SystemMemoryCache
let numDmiWithSP = 0; // Number of DMIs with ScratchPad memory
let idxDmiWithSP = 0; // To get valid index of DMIs with ScratchPad memory
let numDmiWithWP = 0; // Number of DMIs with WayPartitioning
let idxDmiWithWP = 0; // To get valid index of DMIs with WayPartitioning
let noBootIoAiu = 1;
const BootIoAiu = [];
let found_csr_access_chiaiu=0;
let found_csr_access_ioaiu=0;
let csrAccess_ioaiu;
let csrAccess_chiaiu;
const aiu_axiInt = [];
const dmi_width= [];
let AiuCore;
let initiatorAgents   = obj.AiuInfo.length ;
const aiu_NumCores = [];
const aiu_rpn = [];
const aiuName = [];

   const _blkid = [];
   const _blkportsid =[];
   const _blk   = [{}];
   let _idx = 0;
   let aiu_idx = 0;
   let nAIUs_mpu =0; 
   
   for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
      if(!Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       _blk[_idx]   = obj.AiuInfo[pidx];
       _blkid[_idx] = 'aiu' + aiu_idx;
       _blkportsid[_idx] = 0;
       nAIUs_mpu++;
       aiu_idx++;
       _idx++;
       } else {
       for (let port_idx = 0; port_idx < obj.AiuInfo[pidx].nNativeInterfacePorts; port_idx++) {
        _blk[_idx]   = obj.AiuInfo[pidx];
        _blkid[_idx] = 'aiu' + aiu_idx ;
        _blkportsid[_idx] = port_idx;
        _idx++;
        nAIUs_mpu++;
        }
        aiu_idx++;
       }
   }

 for(let pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn[0];
   } else {
       aiu_NumCores[pidx]    = 1;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn;
   }
 }

for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt[0];
        AiuCore = 'ioaiu_core0';
    } else {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt;
        AiuCore = 'ioaiu_core0';
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
// Assuming CHI AIU will appear first in AiuInfo in top.level.dv.json before IO-AIUs
let chi_idx=0;
let io_idx=0;
for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-B")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) 
       { 
       if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
       if(obj.AiuInfo[pidx].fnCsrAccess == 1) {
         if (found_csr_access_chiaiu == 0) {
          csrAccess_chiaiu = chi_idx;
          found_csr_access_chiaiu = 1;
         }
       }
       numChiAiu++ ; numCAiu++ ; 
       chi_idx++;
       }
    else
       { numIoAiu++ ; 
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].fnNativeInterface == "ACE5") { 
             if(numACEAiu == 0) { aceaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
	     numCAiu++; numACEAiu++; 
         } else {
             if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
                 if (numNCAiu == 0) { ncaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix + "_0"; }
             } else {
                 if (numNCAiu == 0) { ncaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
             }
             numNCAiu++ ;
         }
//         if(obj.AiuInfo[pidx].useCache) idxIoAiuWithPC = numNCAiu;
         if(obj.AiuInfo[pidx].useCache) {
             idxIoAiuWithPC = pidx;
             if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
                 aiuName[pidx]  = obj.AiuInfo[pidx].strRtlNamePrefix + "_0";
             } else {
                 aiuName[pidx]  = obj.AiuInfo[pidx].strRtlNamePrefix;
            }
         }
         if(obj.AiuInfo[pidx].fnCsrAccess == 1) {
            if (found_csr_access_ioaiu == 0) {
	       csrAccess_ioaiu = io_idx;
	       found_csr_access_ioaiu = 1;
            }
	    BootIoAiu[numBootIoAiu] = io_idx;
            numBootIoAiu++;
	    noBootIoAiu = 0;
         }
         io_idx++;
       }
}
%>
// agent DEBUG
<%for(let pidx = 0; pidx < nAIUs_mpu; pidx++) {   %>
//  idx=<%=pidx%> : <%=_blkid[pidx]%>  port:<%=_blkportsid[pidx]%> 
<% } %>

//File: concerto_fullsys_test.svh

<%  if((obj.INHOUSE_OCP_VIP)) { %>
import ocp_agent_pkg::*;
<%  } %>

<%
const ioCacheEn = [];
const aiuNativeInf = [];
const dvmEn = [];
const dvmCmpEn = [];
const interlvAiu = [];
let cacheId;
const idSnoopFilterSlice = [];
const hntEn = [];
let hntEnVal;

//const agent_num = [];
//let current_agt_num = 0;
let count = -1 ;
let logical_id = -1;
const AgtIdToCacheId = [];
const aiuBundleIndex = [];
let nChiAgents = 0;
let nACEAgents = 0;


if (obj.nAIUs > 0) {
obj.AiuInfo.forEach(function(bundle, indx, array) {
    if(bundle.useCache) {
        ioCacheEn.push(1);
    } else {
        ioCacheEn.push(0);
    }
     aiuNativeInf.push(bundle.fnNativeInterface);

     if(bundle.nAius > 1) { // interleaved Aius?
       interlvAiu.push(1);
       //current_agt_num += 2;
     } else {
       interlvAiu.push(0);
       //current_agt_num += 1;
     }

     if((bundle.cmpInfo.nDvmSnpInFlight > 0)|(bundle.cmpInfo.nDvmMsgInFlight > 0)) {
       dvmEn.push(1);
     } else {
       dvmEn.push(0);
     }

     if((bundle.cmpInfo.nDvmCmpInFlight > 0)) {
       dvmCmpEn.push(1);
     } else {
       dvmCmpEn.push(0);
     }

     if(bundle.fnNativeInterface === "ACE" || bundle.fnNativeInterface === "ACE5" ||bundle.fnNativeInterface === "CHI-A" || bundle.fnNativeInterface === "CHI-B" || bundle.fnNativeInterface === "CHI-E") { // interleaved Aius?
       obj.SnoopFilterInfo.forEach(function(snpinfo, snp_indx, array) {
          if (snpinfo.SnoopFilterAssignment.includes(bundle.FUnitId))
            idSnoopFilterSlice.push(snp_indx);
       });
     }

     if(bundle.fnNativeInterface === "ACE" || bundle.fnNativeInterface === "ACE5" ||bundle.fnNativeInterface === "ACE-LITE" || bundle.fnNativeInterface === "ACELITE-E") {
       nACEAgents = nACEAgents + 1;
     }

     if(bundle.fnNativeInterface === "CHI-A" || bundle.fnNativeInterface === "CHI-B" || bundle.fnNativeInterface === "CHI-E") {
        nChiAgents = nChiAgents + 1;
     }
});
}
   let bundle_index = -1;
   
obj.AiuInfo.forEach(function(bundle, indx, array) {
  if (bundle.interleavedAgent == 0) {
    bundle_index += 1;
  }
  aiuBundleIndex.push(bundle_index);
});

 let numAiuRpns = 0;   //Total AIU RPN's
for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(obj.AiuInfo[pidx].nNativeInterfacePorts) {
       numAiuRpns += obj.AiuInfo[pidx].nNativeInterfacePorts;
    } else {
       numAiuRpns++;
    }
}
%>
class concerto_rw_csr_inhouse_tasks extends concerto_rw_csr_generic;

   //////////////////
   //UVM Registery
   //////////////////   
   `uvm_component_utils(concerto_rw_csr_inhouse_tasks)

   //////////////////
   //Properties
   //////////////////
   concerto_test_cfg test_cfg;
   concerto_env_cfg m_concerto_env_cfg;  
   concerto_env     m_concerto_env;
   
   bit k_nrsar_test;

 <% let qidx=0; for(let pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
           ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer                   m_ioaiu_vseqr<%=qidx%>[<%=aiu_NumCores[pidx]%>];
      <%  qidx++; } %>
    <% } %>  

   //////////////////
   //Methods
   //////////////////
   
   //constructor
   extern function new(string name = "concerto_rw_csr_inhouse_tasks", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);
   extern function void end_of_elaboration_phase(uvm_phase phase);
  
   //function used by read_csr_ral
   extern function uvm_reg_data_t mask_data(int lsb, int msb);
   
   // TASKS
 <% for(let idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
//   CLU TMP COMPILE FIX CONC-11383  if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
    extern virtual task write_chk<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data, bit check=0, bit nonblocking=0);
    extern virtual task write_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data, bit nonblocking=0);
    extern virtual task read_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, output bit[31:0] data);
    extern virtual task read_csr_ral<%=qidx%>(uvm_reg_field field, output uvm_reg_data_t fieldVal);
    //task to set xNRSAR valid field for all AIU
    extern virtual task set_aiu_nrsar_reg<%=qidx%>();
    <% //} 
    qidx++; }
    } %>
endclass: concerto_rw_csr_inhouse_tasks


function concerto_rw_csr_inhouse_tasks::new(string name = "concerto_rw_csr_inhouse_tasks", uvm_component parent = null);
  super.new(name,parent);
     if(!$value$plusargs("k_nrsar_test=%d",k_nrsar_test))begin
       k_nrsar_test = 0;
    end
endfunction: new
// ////////////////////////////////////////////////////////////////////////////
// #     # #     # #     #         ######  #     #    #     #####  #######
// #     # #     # ##   ##         #     # #     #   # #   #     # #
// #     # #     # # # # #         #     # #     #  #   #  #       #
// #     # #     # #  #  #         ######  ####### #     #  #####  #####
// #     #  #   #  #     #         #       #     # #######       # #
// #     #   # #   #     #         #       #     # #     # #     # #
//  #####     #    #     # ####### #       #     # #     #  #####  #######
////////////////////////////////////////////////////////////////////////////
function void concerto_rw_csr_inhouse_tasks::build_phase(uvm_phase phase);
    
    super.build_phase(phase);
     if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", m_concerto_env_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end   
      if(!(uvm_config_db #(concerto_env)::get(uvm_root::get(), "", "m_env", m_concerto_env)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end  
     if(!(uvm_config_db #(concerto_test_cfg)::get(uvm_root::get(), "", "test_cfg", test_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_test_cfg object in UVM DB");
    end 
endfunction:build_phase

function void concerto_rw_csr_inhouse_tasks::end_of_elaboration_phase(uvm_phase phase);
super.end_of_elaboration_phase(phase);
if(!m_concerto_env_cfg.has_axi_vip_snps) begin : get_all_ioaiu_vseqr_handles
// BEGIN setup virtual_sequencer  
<% let cidx = 0; %>
<% qidx = 0; %>
<% for(let pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
      <% for(let coreidx=0; coreidx<aiu_NumCores[pidx]; coreidx++) { %> 
     if(!(uvm_config_db#(ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>]" ),.value( m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>] ) ))) begin
     `uvm_error(get_name(), "Cannot get m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>]")
     end
      m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>].m_read_addr_chnl_seqr   = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_read_addr_chnl_seqr;
      m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>].m_read_data_chnl_seqr   = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_read_data_chnl_seqr;
      m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>].m_write_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_write_addr_chnl_seqr;
      m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>].m_write_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_write_data_chnl_seqr;
      m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>].m_write_resp_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_write_resp_chnl_seqr;
      <% } %>
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') ||(aiu_axiInt[pidx].params.eAc==1) ){ %>
      <% for(let coreidx=0; coreidx<aiu_NumCores[pidx]; coreidx++) { %> 
      m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>].m_snoop_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_snoop_addr_chnl_seqr;
      m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>].m_snoop_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_snoop_data_chnl_seqr;
      m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>].m_snoop_resp_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_snoop_resp_chnl_seqr;
      <% } %>
      <% } qidx++; } %>
    <% } %>
// END setup virtual_seq  
end : get_all_ioaiu_vseqr_handles
endfunction:end_of_elaboration_phase
/////////////////////////////////////
// #######    #     #####  #    #
//    #      # #   #     # #   #
//    #     #   #  #       #  #
//    #    #     #  #####  ###
//    #    #######       # #  #
//    #    #     # #     # #   #
//    #    #     #  #####  #    #
// /////////////////////////////////////

function uvm_reg_data_t concerto_rw_csr_inhouse_tasks::mask_data(int lsb, int msb);
    uvm_reg_data_t mask_data_val = 0;
    for(int i=0;i<32;i++)begin
        if(i>=lsb &&  i<=msb)begin
            mask_data_val[i] = 1;     
        end
    end
    return mask_data_val;
endfunction:mask_data

<% for(let idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
//   CLU TMP COMPILE FIX CONC-11383     if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>

task concerto_rw_csr_inhouse_tasks::write_chk<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data, bit check=0, bit nonblocking=0);
    bit [31:0] rdata;
    write_csr<%=qidx%>(addr,data, nonblocking);
    if(check) begin 
       read_csr<%=qidx%>(addr,rdata);
       if(!ioaiu_csr_ns_access) begin
         if(data != rdata) `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Read data error  Addr: 0x%0h , Wdata: 0x%0h , Rdata: 0x%0h", addr, data, rdata))
       end
    end
endtask : write_chk<%=qidx%>

task concerto_rw_csr_inhouse_tasks::write_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data, bit nonblocking=0);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrnosnp_seq m_iowrnosnp_seq<%=qidx%>[<%=aiu_NumCores[idx]%>];
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] wdata;
    int addr_mask;
    int addr_offset;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_rresp_t bresp;
										
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
    <% for(let i=0; i<aiu_NumCores[idx]; i++) { %> 
    if (ncoreConfigInfo::check_addr_for_core(addr,<%=obj.AiuInfo[numChiAiu+qidx].FUnitId%>,<%=i%>)) begin:_wr_addr_match_with_core_<%=qidx%>_<%=i%>
     m_iowrnosnp_seq<%=qidx%>[<%=i%>]   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrnosnp_seq::type_id::create("m_iowrnosnp_seq<%=qidx%>[<%=i%>]");
     if(nonblocking == 0) begin
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].core_id = <%=i%>;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].use_awid = 0;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].m_axlen = 0;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].m_addr = addr;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].ioaiu_csr_ns_access = ioaiu_csr_ns_access;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].m_size  = (k_decode_err_illegal_acc_format_test_unsupported_size==0) ? 3'b010 : 3'b100;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].m_data[(addr_offset*8)+:32] = data;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].m_wstrb = 32'hF<<addr_offset; // Assuming (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8) < 32
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].start(m_ioaiu_vseqr<%=qidx%>[<%=i%>]);
     end else begin
     fork
         begin
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].m_addr = addr;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].core_id = <%=i%>;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].use_awid = 0;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].m_axlen = 0;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].ioaiu_csr_ns_access = ioaiu_csr_ns_access;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].m_size  = (k_decode_err_illegal_acc_format_test_unsupported_size==0) ? 3'b010 : 3'b100;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].m_data[(addr_offset*8)+:32] = data;
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].m_wstrb = 32'hF<<addr_offset; // Assuming (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8) < 32
         m_iowrnosnp_seq<%=qidx%>[<%=i%>].start(m_ioaiu_vseqr<%=qidx%>[<%=i%>]);
         end
     join_none
     end // else: !if(nonblocking == 0)	
    bresp =   m_iowrnosnp_seq<%=qidx%>[<%=i%>].m_write_resp_seq.m_seq_item.m_write_resp_pkt.bresp;
    `uvm_info("WRITE_CSR", $sformatf("write_csr<%=qidx%> address 0x%h performed for core <%=i%> (check_addr_for_core) data= 0x:%0h bresp=0x%0h", addr,data, bresp), UVM_MEDIUM)
    if(!ioaiu_csr_ns_access) begin
      if(k_decode_err_illegal_acc_format_test_unsupported_size==0) begin
          if(bresp != 0) begin
              `uvm_error("WRITE_CSR",$sformatf("Resp_err :0x%0h on write access",bresp))
          end
      end else if(k_decode_err_illegal_acc_format_test_unsupported_size) begin
          if(bresp [1:0] == 3) begin
              `uvm_info("WRITE_CSR",$sformatf("Resp_err :0x%0h(DECERR) on write access",bresp),UVM_NONE)
          end else begin
              `uvm_error("WRITE_CSR",$sformatf("Expecting Resp_err :0x3(DECERR) on write access, Actual 0x%0h",bresp[1:0]))
          end
      end
    end else begin
      if(addr[11:0] != 12'h000) begin //XAIUIDR register
       if(bresp[1:0] == 2) begin
            `uvm_info("WRITE_CSR",$sformatf("Bresp_err :0x%0h(SLVERR) on Write access",bresp),UVM_LOW)
       end else begin
            `uvm_error("WRITE_CSR",$sformatf("Expecting Bresp_err :0x2(SLVERR) on Write Access, Actual 0x%0h",bresp[1:0]))
       end
      end
    end
    end:_wr_addr_match_with_core_<%=qidx%>_<%=i%> 
    <% } %>											   
endtask : write_csr<%=qidx%>


task concerto_rw_csr_inhouse_tasks::read_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, output bit[31:0] data);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_rdnosnp_seq m_iordnosnp_seq<%=qidx%>[<%=aiu_NumCores[idx]%>];
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] rdata;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_rresp_t rresp;
    int addr_mask;
    int addr_offset;
										
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
   
    <% for(let i=0; i<aiu_NumCores[idx]; i++) { %> 
    if (ncoreConfigInfo::check_addr_for_core(addr,<%=obj.AiuInfo[numChiAiu+qidx].FUnitId%>,<%=i%>)) begin:_rd_addr_match_with_core_<%=qidx%>_<%=i%>
    m_iordnosnp_seq<%=qidx%>[<%=i%>]   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_rdnosnp_seq::type_id::create("m_iordnosnp_seq<%=qidx%>[<%=i%>]"); 
    m_iordnosnp_seq<%=qidx%>[<%=i%>].m_addr = addr;
    m_iordnosnp_seq<%=qidx%>[<%=i%>].use_arid = 0;
    m_iordnosnp_seq<%=qidx%>[<%=i%>].m_axlen =  0;
    m_iordnosnp_seq<%=qidx%>[<%=i%>].ioaiu_csr_ns_access = ioaiu_csr_ns_access;
    m_iordnosnp_seq<%=qidx%>[<%=i%>].k_decode_err_illegal_acc_format_test_unsupported_size =  k_decode_err_illegal_acc_format_test_unsupported_size;
    m_iordnosnp_seq<%=qidx%>[<%=i%>].core_id =  <%=i%>;
    m_iordnosnp_seq<%=qidx%>[<%=i%>].start(m_ioaiu_vseqr<%=qidx%>[<%=i%>]);
   
    rdata = (m_iordnosnp_seq<%=qidx%>[<%=i%>].m_seq_item.m_has_data) ? m_iordnosnp_seq<%=qidx%>[<%=i%>].m_seq_item.m_read_data_pkt.rdata[0] : 0;
    data = rdata[(addr_offset*8)+:32];
    rresp =  (m_iordnosnp_seq<%=qidx%>[<%=i%>].m_seq_item.m_has_data) ? m_iordnosnp_seq<%=qidx%>[<%=i%>].m_seq_item.m_read_data_pkt.rresp : 0;

    // for nrsar test receiving Resp_err is expected so when k_nrsar_test == 1 this check is disabled
    `uvm_info("READ_CSR", $sformatf("read_csr<%=qidx%> address 0x%h performed for core <%=i%> (check_addr_for_core) data:0x%0h rresp=0x%0h", addr,data,rresp), UVM_MEDIUM)
    if(!ioaiu_csr_ns_access) begin
       if(k_nrsar_test==0  && k_decode_err_illegal_acc_format_test_unsupported_size==0) begin
           if(rresp != 0) begin
               `uvm_error("READ_CSR",$sformatf("Resp_err :0x%0h on Read Data",rresp))
           end
       end else if(k_decode_err_illegal_acc_format_test_unsupported_size) begin
           if(rresp[1:0] == 3) begin
               `uvm_info("READ_CSR",$sformatf("Resp_err :0x%0h(DECERR) on read access",rresp),UVM_LOW)
           end else begin
               `uvm_error("READ_CSR",$sformatf("Expecting Resp_err :0x3(DECERR) on Read Data, Actual 0x%0h",rresp[1:0]))
           end
       end
    end else begin
      if(addr[11:0] != 12'h000) begin //XAIUIDR register
       if(rresp[1:0] == 2) begin
            `uvm_info("READ_CSR",$sformatf("Resp_err :0x%0h(SLVERR) on read access",rresp),UVM_LOW)
       end else begin
            `uvm_error("READ_CSR",$sformatf("Expecting Resp_err :0x2(SLVERR) on Read Data, Actual 0x%0h",rresp[1:0]))
       end
      end
    end

    end:_rd_addr_match_with_core_<%=qidx%>_<%=i%> 
    else   `uvm_info("READ_CSR", $sformatf("read_csr<%=qidx%> address 0x%h ignored for core <%=i%> (check_addr_for_core)", addr), UVM_MEDIUM)
    <% } %>
endtask : read_csr<%=qidx%>



task concerto_rw_csr_inhouse_tasks::read_csr_ral<%=qidx%>(uvm_reg_field field, output uvm_reg_data_t fieldVal);
    int lsb, msb;
    uvm_reg_data_t mask;
    uvm_reg_data_t field_rd_data;
    <% if ((obj.testBench != "fsys" ) && (obj.testBench != "emu")) { %>
    field.get_parent().read(status, field_rd_data, .parent(this));
    <% } else {%>
    uvm_reg_addr_t addr;
    bit [31:0] data;
    addr = field.get_parent().get_address();  
    `uvm_info("CSR Ralgen Base Seq", $sformatf("read_csr_ral<%=qidx%>  address 0x%h", addr), UVM_LOW)
            read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
   
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
endtask : read_csr_ral<%=qidx%>

task concerto_rw_csr_inhouse_tasks::set_aiu_nrsar_reg<%=qidx%>();
//#Check.FSYS.csr.access
// iteratte 3 times ,iter 0 enbale NRSAR iter 1 disable NRSAR iter 2 enable NRSAR
bit [31:0] data;
uvm_reg_data_t fieldVal;
bit was_enabled=0;
ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;	

addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE ;
repeat(3)begin // iteratte 3 times ,iter 0 enbale NRSAR iter 1 disable NRSAR iter 2 enable NRSAR
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        if (i != <%=numChiAiu%> )begin //jump ioaiu0
            addr[19:12]=i;// Register Page Number
            addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUNRSAR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUNRSAR.get_offset()<%}%>;
            //read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
            if (was_enabled) begin 
                data[0]   = 0;
                `uvm_info("set_aiu_nrsar_reg", $sformatf("writing data = %0d on NRSAR reg",data[0]), UVM_LOW)
            end else begin  
                data[0]   = 1; 
                `uvm_info("set_aiu_nrsar_reg", $sformatf("writing data = %0d on NRSAR reg ",data[0]), UVM_LOW)
            end
            write_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
            #10ns;
            read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
            `uvm_info("set_aiu_nrsar_reg", $sformatf("reading  NRSAR reg NSAR = %0d",data[0]), UVM_LOW)
        end 
    end 
     //Each ioaui read it ouwn Funit id and expecting Decerro when NRSAR is disabled
        <% for(let ioaiu_idx = 0,pidx_aiu = 0; pidx_aiu < obj.nAIUs; pidx_aiu++) {%>
        <% if((obj.AiuInfo[pidx_aiu].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx_aiu].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx_aiu].fnNativeInterface != 'CHI-E')){ %>
        <% //CLU TMP COMPILE FIX CONC-11383 if(obj.AiuInfo[pidx_aiu].fnCsrAccess == 1) { %>
        <% if(Array.isArray(obj.AiuInfo[pidx_aiu].interfaces.axiInt)){%>
        //<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>_0 doing only core0 because read_csr task will then parse all cores
        `uvm_info("set_aiu_nrsar_reg", $sformatf("will read XAIUFUIDR<%=ioaiu_idx%>  using ioaiu<%=ioaiu_idx%>"), UVM_LOW)
         read_csr_ral<%=ioaiu_idx%>(m_concerto_env.m_regs.<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>_0.get_reg_by_name("XAIUFUIDR").get_field_by_name("FUnitId"), fieldVal);
        `uvm_info("set_aiu_nrsar_reg", $sformatf("reading  XAIUFUIDR<%=ioaiu_idx%>  using ioaiu<%=ioaiu_idx%>  FUnitId = %0d",fieldVal), UVM_LOW)
        
      <%} else {%>
      `uvm_info("set_aiu_nrsar_reg", $sformatf("will read XAIUFUIDR<%=ioaiu_idx%>  using ioaiu<%=ioaiu_idx%>  "), UVM_LOW)
       read_csr_ral<%=ioaiu_idx%>(m_concerto_env.m_regs.<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.get_reg_by_name("XAIUFUIDR").get_field_by_name("FUnitId"), fieldVal);
      `uvm_info("set_aiu_nrsar_reg", $sformatf("reading  XAIUFUIDR<%=ioaiu_idx%>  using ioaiu<%=ioaiu_idx%>  FUnitId = %0d",fieldVal), UVM_LOW) 

        <%}%>
        <%//}%>
        <% ioaiu_idx++; }%>
        <%}%>
        #10ns;
    if (was_enabled) begin
        was_enabled = 0;
    end else begin
        was_enabled = 1;
    end
end
        	
endtask : set_aiu_nrsar_reg<%=qidx%>

<% //}
qidx++; }
} %>
