//=======================================================================
// COPYRIGHT (C)  2012-2016 SYNOPSYS INC.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//
//-----------------------------------------------------------------------

/**
 * Abstract:
 * Class cust_svt_amba_system_configuration is a testbench defined class and
 * basically used to encapsulate all the configuration information.  It extends
 * AMBA system configuration and sets the appropriate fields within:
 * - AMBA System configuration class
 * - CHI System configuration class which is contained within AMBA system configuration
 */
`ifndef GUARD_CUST_SVT_AMBA_SYSTEM_CONFIGURATION_SV
`define GUARD_CUST_SVT_AMBA_SYSTEM_CONFIGURATION_SV

<%
var DVMV8_4=(obj.DveInfo[0].DVMVersionSupport==132)?1:0;
var DVMV8_1=(obj.DveInfo[0].DVMVersionSupport==129)?1:0;
var DVMV8_0=(obj.DveInfo[0].DVMVersionSupport==128)?1:0;
%>
<% if (obj.testBench == "chi_aiu") {
  var chiA_present;

  if(obj.AiuInfo[obj.Id].fnNativeInterface == "CHI-A") {
      chiA_present = 1;
     // throw "ERROR - NCORE3.6 does not support CHI-A native interface in CHIAIU."
  }

} else if (obj.testBench == "fsys" || obj.testBench == "io_aiu") {
var chiA_present;
var ioaiuIndexNum = 0;
var chiaiuIndexNum  = 0;
var ArrayIndex = 0;
var rtlInstName = [];
var rtlModule   = [];
var numAiuRpns = 0;   //Total AIU RPN's
var atomic_txns_en = 0;

for(i = 0; i < obj.nAIUs; i++) {
 if((obj.AiuInfo[i].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[i].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[i].fnNativeInterface == 'CHI-E')) {
  if(obj.AiuInfo[i].fnNativeInterface == "CHI-A") {
      chiA_present = 1;
     // throw "ERROR - NCORE3.6 does not support CHI-A native interface in CHIAIU."
  }
  rtlInstName[i] = 'chiaiu' + chiaiuIndexNum;
  rtlModule[i]   = 'chiaiu';
  chiaiuIndexNum++;
 } else {
  if ((obj.AiuInfo[i].fnNativeInterface == 'ACELITE-E')  || ((obj.AiuInfo[i].fnNativeInterface == 'AXI5') && (obj.AiuInfo[i].interfaces.axiInt.params.atomicTransactions==true))) {
    atomic_txns_en = 1;
  }
  rtlInstName[i] = 'ioaiu' + ioaiuIndexNum;
  rtlModule[i]   = 'ioaiu';
  ioaiuIndexNum++;
 }
    if(obj.AiuInfo[i].nNativeInterfacePorts) {
       numAiuRpns += obj.AiuInfo[i].nNativeInterfacePorts;
    } else {
       numAiuRpns++;
    }
}
  ioaiuIndexNum = numAiuRpns - chiaiuIndexNum ;
for(i = 0; i < obj.nDCEs; i++) {
  ArrayIndex = i + obj.nAIUs;
  rtlInstName[ArrayIndex] = 'dce' + i;
  rtlModule[ArrayIndex]   = 'dce';
}
for(i =  0; i < obj.nDMIs; i++) {
  ArrayIndex = i + obj.nAIUs + obj.nDCEs;
  rtlInstName[ArrayIndex] = 'dmi' + i;
  rtlModule[ArrayIndex]   = 'dmi';
}
for(i = 0; i < obj.nDIIs; i++) {
  ArrayIndex = i + obj.nAIUs + obj.nDCEs + obj.nDMIs;
  rtlInstName[ArrayIndex] = 'dii' + i;
  rtlModule[ArrayIndex]   = 'dii';
}
for(i = 0; i < obj.nDVEs; i++) {
  ArrayIndex = i + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
  rtlInstName[ArrayIndex] = 'dve' + i;
  rtlModule[ArrayIndex]   = 'dve';
}
var nRNFchiaiu = chiaiuIndexNum;
var nRNIioaiu  = ioaiuIndexNum;
var nSNIdii    = obj.nDCEs;
var nSNFdmi    = obj.nDMIs;
//=========ACE CONFIGURATION============
  var pidx = 0;
  var idx = 0;
  var ace_master = 0;
  var ace_slave = 0;
const aiu_axiIntLen = [];

  for(pidx = 0; pidx < obj.nAIUs; pidx++) { 
    if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI5')||(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')) {
    if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
        aiu_axiIntLen[idx] = obj.AiuInfo[pidx].interfaces.axiInt.length;
        for (var i=0; i<aiu_axiIntLen[idx]; i++) {
      if(obj.AiuInfo[pidx].interfaces.axiInt[i].direction == 'slave') { ace_master++;}
        }}else {
        aiu_axiIntLen[idx] = 1;
      if(obj.AiuInfo[pidx].interfaces.axiInt.direction == 'slave') { ace_master++;}
        }
      if(obj.AiuInfo[pidx].interfaces.axiInt.direction == 'master') { ace_slave++;}
idx++;}}

  var pidx = 0;
  for(var pidx = 0; pidx < obj.nDIIs; pidx++) { 
    if (obj.DiiInfo[pidx].configuration == 0) {   					      
      if(obj.DiiInfo[pidx].interfaces.axiInt.direction == 'master') { ace_slave++;}
 }}

  var pidx = 0;
  for(var pidx = 0; pidx < obj.nDMIs; pidx++) { 
      if(obj.DmiInfo[pidx].interfaces.axiInt.direction == 'master') { ace_slave++;}
 }%>

 <%if(obj.testBench == "io_aiu"){%>
`define NUM_ACE_MASTERS 1
<%}else{%>
`define NUM_ACE_MASTERS <%=ace_master%>
 <%}%>
`ifdef USE_VIP_SNPS_AXI_SLAVES
`define NUM_ACE_SLAVES  <%=ace_slave%>
`else // `ifdef USE_VIP_SNPS_AXI_SLAVES
`define NUM_ACE_SLAVES 0 
`endif // `ifdef USE_VIP_SNPS_AXI_SLAVES ... `else
<%}%>

<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var pidx = 0;
   var chiaiu_idx = 0;
   var initiatorAgents = obj.AiuInfo.length ;
%>

   <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
       <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       <% _child_blkid[pidx] = 'chiaiu' + chiaiu_idx; %>
       <% _child_blk[pidx]   = 'chiaiu'; %>
       <% if (obj.testBench == "fsys") { %>
       //import <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_svt_chi_node_params_pkg::*;
       <% } else { %>
         <% if (chiaiu_idx<1 && obj.testBench == "chi_aiu") { %>
         import <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_svt_chi_node_params_pkg::*;
         <% } %>
       <% } %>
       <% chiaiu_idx++; %>
     <% } %>
   <% } %>

import addr_trans_mgr_pkg::*;
<% if(obj.testBench == "fsys" || obj.testBench == "io_aiu") { %>
import svt_axi_item_helper_pkg::*;
<% } %>
class cust_svt_amba_system_configuration extends svt_amba_system_configuration;

  //properties
  bit DVMV8_4 = <%=DVMV8_4%>;
  bit DVMV8_1 = <%=DVMV8_1%>;
  bit DVMV8_0 = <%=DVMV8_0%>;
  // #Stimulus.FSYS.DVM_v8
  // #Stimulus.FSYS.DVM_v81
  // #Stimulus.FSYS.DVM_v84
  int io_subsys_master_ports_array[];
  int io_subsys_innershareable_master_ports_array[];
  int io_subsys_outershareable_master_ports_array[];
  bit io_subsys_innershareable_domain_created[], io_subsys_nonshareable_domain_created[],io_subsys_outershareable_domain_created[]; 
  bit chi_aiu_non_snoopable_domain_created;
  bit chi_aiu_inner_snoopable_domain_created; 
  bit ace_non_snoopable_domain_created;
  bit ace_inner_snoopable_domain_created; 
  bit enable_domain_based_addr_gen=1;
  addrMgrConst::sys_addr_csr_t csrq[$];
  addrMgrConst::sys_addr_csr_t slave_cfg_csrq[$];
  addrMgrConst::ncore_unit_type_t slave_cfg_nintrlv_type[$];
  ncore_memory_map m_mem; 
  addr_trans_mgr_pkg::addr_trans_mgr m_addr_mgr = addr_trans_mgr::get_instance();
  int dcount; //global domain count used by fsys
  int           chi_aiu_max_interleave;
  bit [1:0] boot_sysco_st;
  bit  en_excl_txn;
  bit enable_hn_programming = $urandom_range(1,0);
  bit k_chiaiu_access_boot_region = 0;
  bit k_ioaiu_access_boot_region = 0;

  //Utility macro
  `svt_xvm_object_utils (cust_svt_amba_system_configuration)
  
  int reduce_mem_size=64;

  function new (string name="cust_svt_amba_system_configuration");
    super.new(name);
    if($value$plusargs("k_chiaiu_access_boot_region=%b",k_chiaiu_access_boot_region)) begin
      `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: k_chiaiu_access_boot_region=%0d",k_chiaiu_access_boot_region),UVM_NONE)
    end
    if($value$plusargs("k_ioaiu_access_boot_region=%b",k_ioaiu_access_boot_region)) begin
      `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: k_ioaiu_access_boot_region=%0d",k_ioaiu_access_boot_region),UVM_NONE)
    end
    if ($value$plusargs("reduce_addr_area=%d",reduce_mem_size)) begin
                if (reduce_mem_size==1) reduce_mem_size=64;
                `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: reduce_addr_area:%0dcacheline size:%0dB", reduce_mem_size,(reduce_mem_size<< <%=obj.wCacheLineOffset%>)),UVM_NONE)
     end
  endfunction
 
  /*
   * Utility method in the testbench to initialize the configuration of AMBA
   * System ENV, and underlying CHI System ENV.
   */
  extern function void set_amba_sys_config(bit has_axi_vip_snps=0,bit has_apb_vip_snps=0, bit has_chi_vip_snps=0);

  /** 
   * Utility method in the testbench to set the CHI System configuration parameters 
   */
  extern function void set_chi_system_configuration(svt_chi_system_configuration chi_sys_cfg);
<% if (obj.testBench == "fsys" || obj.testBench == "io_aiu") { %>
  extern function void set_axi_system_configuration(svt_axi_system_configuration axi_sys_cfg);
  <% if (obj.DebugApbInfo.length > 0) { %>
     extern function void set_apb_system_configuration(svt_apb_system_configuration apb_sys_cfg);
  <% } %>
<% } %>
  
<% if (obj.testBench == "fsys") { %>
 extern function void configure_system_address_map(string protocol_type, svt_chi_system_configuration chi_sys_cfg, svt_axi_system_configuration axi_sys_cfg);
<% } %>
endclass
// =============================================================================

//------------------------------------------------------------------------------
function void cust_svt_amba_system_configuration::set_amba_sys_config(bit has_axi_vip_snps=0,bit has_apb_vip_snps=0, bit has_chi_vip_snps=0);

  /**
   * svt_amba_system_configuration::create_sub_cfgs allows user to allocate
   * system configurations for AXI, AHB, APB and CHI System Envs.
   * Prototype of the method is:
   * void create_sub_cfgs (int num_axi_systems, int num_ahb_systems, int num_apb_systems,int num_chi_systems ) 
   * Here, we are allocating one CHI System configuration within the AMBA System
   * configuration, as we are creating one CHI System ENV within AMBA System Env.
   */
<% var chi_system = 0; if(chiaiuIndexNum>0) { %>
<%   chi_system = 1; %>
<% } %>
<%var apb_system = 0; if(obj.DebugApbInfo.length > 0){%>
<%apb_system = 1; %>
<%}%>

<% if (obj.testBench == "fsys") { %>
  //create_sub_cfgs(1, 0, <%=apb_system%>, <%=chi_system%>);
  if (has_axi_vip_snps || has_apb_vip_snps || has_chi_vip_snps) create_sub_cfgs(has_axi_vip_snps, 0, has_apb_vip_snps, <%=(chiaiuIndexNum>0)?1:0%>?has_chi_vip_snps:0);
<% } else { %>
  <%if(obj.testBench == "io_aiu"){%>
  has_axi_vip_snps = 1;
  create_sub_cfgs(has_axi_vip_snps,0,0,0);
 <%} else {%>
   has_chi_vip_snps = 1;
  create_sub_cfgs(0,0,0,has_chi_vip_snps);
  <%}%>
<% } %>

if (has_chi_vip_snps) begin:_has_chi
`ifndef SVT_AMBA_EXCLUDE_AXI_IN_CHI_SYS_ENV
  /**
   * Allocates the RN and SN node configurations before a user sets the parameters.
   * This function is to be called if (and before) the user sets the configuration
   * parameters by setting each parameter individually and not by randomizing the
   * system configuration. 
   * Prototype of the method is:
   * void create_sub_cfgs(int num_chi_rn = 1, int num_chi_sn = 1, int num_chi_ic_rn = 0, int num_chi_ic_sn = 0, int num_axi_masters = 1, int num_axi_slaves = 1, int num_axi_ic_master_ports = 0, int num_axi_ic_slave_ports = 0);
   */
  //this.chi_sys_cfg[0].create_sub_cfgs(1,1,0,0,0,0,0,0);
<% if ((obj.testBench == "chi_aiu") || ((obj.testBench == "fsys") && (chiaiuIndexNum>0))) { %>
  this.chi_sys_cfg[0].create_sub_cfgs(`SVT_CHI_MAX_NUM_RNS,`SVT_CHI_MAX_NUM_SNS,0,0,0,0,0,0);
<% } %>
`else
  /**
   * Allocates the RN and SN node configurations before a user sets the parameters.
   * This function is to be called if (and before) the user sets the configuration
   * parameters by setting each parameter individually and not by randomizing the
   * system configuration. 
   * Prototype of the method is:
   * void create_sub_cfgs(int num_chi_rn = 1, int num_chi_sn = 1, int num_chi_ic_rn = 0, int num_chi_ic_sn = 0);
   */
  //this.chi_sys_cfg[0].create_sub_cfgs(1,1,0,0);
<% if ((obj.testBench == "chi_aiu") || ((obj.testBench == "fsys") && (chiaiuIndexNum>0))) { %>
  this.chi_sys_cfg[0].create_sub_cfgs(`SVT_CHI_MAX_NUM_RNS,`SVT_CHI_MAX_NUM_SNS,0,0);
<% } %>
`endif
  

<% if ((obj.testBench == "chi_aiu") || ((obj.testBench == "fsys") && (chiaiuIndexNum>0))) { %>
  /* Configure the number of CHI Home Nodes in the CHI System ENV. 
   * The number of Home Nodes in a CCN-504 Cache Coherant Network
   * is 8. So, this is configured to 8. 
   * */
    // this.chi_sys_cfg[0].num_hn = enable_hn_programming ? `SVT_CHI_MAX_NUM_RNS : 0; // In Ncore Each RN is connected to a single HN and so we have as many HNs as we have RNs
    this.chi_sys_cfg[0].num_hn = `SVT_CHI_MAX_NUM_RNS; // In Ncore Each RN is connected to a single HN and so we have as many HNs as we have RNs
    /* Configure the number of CHI Request Nodes in the CHI System ENV. */
    this.chi_sys_cfg[0].num_rn = `SVT_CHI_MAX_NUM_RNS;
    /* Configure the number of CHI Slave Nodes in the CHI System ENV. */
    this.chi_sys_cfg[0].num_sn = `SVT_CHI_MAX_NUM_SNS;

    <%if (obj.testBench == "chi_aiu") {%>
        this.chi_sys_cfg[0].set_hn_node_id({<%=obj.Id%>});
        this.chi_sys_cfg[0].set_hn_stash_enable({1});
        this.chi_sys_cfg[0].set_hn_stash_data_pull_enable({1});
        this.chi_sys_cfg[0].set_hn_interface_type({svt_chi_address_configuration::HN_F});
    <%}else{%>
        this.chi_sys_cfg[0].set_hn_node_id({<%=obj.ChiaiuInfo[0].FUnitId%>
            <%for(let i=1; i< obj.nCHIs; i++){%>
                ,<%=obj.ChiaiuInfo[i].FUnitId%>
            <%}%>
        });
        this.chi_sys_cfg[0].set_hn_stash_enable({1
            <%for(let i=1; i< obj.nCHIs; i++){%>
                ,1
            <%}%>
        });
        this.chi_sys_cfg[0].set_hn_stash_data_pull_enable({1
            <%for(let i=1; i< obj.nCHIs; i++){%>
                ,1
            <%}%>
        });

        /** Program the HN interface types for each of the HN indices */
        this.chi_sys_cfg[0].set_hn_interface_type({
            svt_chi_address_configuration::HN_F
            <%for(let i=1; i< obj.nCHIs; i++){%>
                ,svt_chi_address_configuration::HN_F
            <%}%>
        });
    <%}%>
    this.chi_sys_cfg[0].misc_node_id = <%=obj.DveInfo[0].FUnitId%>;
  
  /* Set the CHI System configuration parameters. */
  set_chi_system_configuration(this.chi_sys_cfg[0]);
<% } %>
end:_has_chi
  <% if (obj.testBench == "fsys" || obj.testBench == "io_aiu") { %>
  if (has_axi_vip_snps) begin:_has_axi
  set_axi_system_configuration(this.axi_sys_cfg[0]);
  end:_has_axi
     <%if(obj.DebugApbInfo.length > 0){%>
     //set APB configuration
  if (has_apb_vip_snps) begin:_has_apb
         set_apb_system_configuration(this.apb_sys_cfg[0]);
  end:_has_apb
     <%}%>
  <% } %>
endfunction
//=============================================================================

//------------------------------------------------------------------------------
function void cust_svt_amba_system_configuration::set_chi_system_configuration(svt_chi_system_configuration chi_sys_cfg);
  //csrq = addrMgrConst::get_all_gpra();
  int nonsnoopable[],innersnoopable[],outersnoopable[],snoopable[];
  bit [63:0] start_addr;
  bit [63:0] end_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] k_unmapped_add_access_wgt_snps;
  bit [63:0] domain_size;
  int non_snoopable_domain_id;
  int inner_snoopable_domain_id;
  int domain_type_cnt;
  int wt_chi_data_flit_with_poison;
  bit chi_rn_node_zero_delay_enable = 0;
  bit chi_rn_node_delay_enable = 0;
  bit dmi_region_created = 0;
  bit dii_region_created = 0;
  longint mid_addr;
  longint s; // start addr
  longint e; // end addr
  longint d; // size of addr chunk
  int nTotalSlaves = <%=(obj.DmiInfo.length + obj.DiiInfo.length - 1)%>; // -1 is to ignore sysdii
  int nCoherentSlaves = 0;
  int nNonCoherentSlaves = 0;

  bit streaming_order_en;
    bit chi_snps_fcov_en;
    int domain_id = 0;
    int domain_count = 0;
    int dmi_domain = 0;
    bit svt_chi_ll_protocol_checks_enable=1;
    bit svt_chi_pl_protocol_checks_enable=1;
    int fnmem_region_idx;
    int slave_id;
    bit assoc_slave_id[int];
    bit svt_chi_delay_en;
    bit dont_divide_nonsnoopable_region_among_CHIs;

 
        if(!$value$plusargs("dont_divide_nonsnoopable_region_among_CHIs=%b",dont_divide_nonsnoopable_region_among_CHIs)) begin
            dont_divide_nonsnoopable_region_among_CHIs = 0;
        end
        if($value$plusargs("svt_chi_delay_en=%b",svt_chi_delay_en)) begin
          `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: svt_chi_delay_en=%0d",svt_chi_delay_en),UVM_NONE)
        end
        if($value$plusargs("svt_chi_ll_protocol_checks_enable=%b",svt_chi_ll_protocol_checks_enable)) begin
          `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: svt_chi_ll_protocol_checks_enable=%0d",svt_chi_ll_protocol_checks_enable),UVM_NONE)
        end
        if($value$plusargs("svt_chi_pl_protocol_checks_enable=%b",svt_chi_pl_protocol_checks_enable)) begin
          `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: svt_chi_pl_protocol_checks_enable=%0d",svt_chi_pl_protocol_checks_enable),UVM_NONE)
        end
        if($value$plusargs("SYNPS_CHI_RN_NODE_ZERO_DELAY_EN=%b",chi_rn_node_zero_delay_enable)) begin
          `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: chi_rn_node_zero_delay_enable=%0d",chi_rn_node_zero_delay_enable),UVM_NONE)
        end
        if($value$plusargs("SYNPS_CHI_RN_NODE_DELAY_EN=%b",chi_rn_node_delay_enable)) begin
          `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: chi_rn_node_delay_enable=%0d",chi_rn_node_delay_enable),UVM_NONE)
        end
        if(chi_rn_node_delay_enable) begin
          chi_rn_node_zero_delay_enable = 0;
        end
        if(!$value$plusargs("chi_snps_fcov_en=%0b", chi_snps_fcov_en)) begin
            chi_snps_fcov_en = 0;
        end

        csrq = {};
        csrq = addrMgrConst::get_all_gpra();
        
        foreach (csrq[i]) begin
          `uvm_info(get_name(),
              $psprintf("unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d",
                  csrq[i].unit.name(), csrq[i].mig_nunitid,
                  csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),
              UVM_NONE) 
        end

        foreach (addrMgrConst::memregions_info[region]) begin
            if (!(addrMgrConst::is_dii_addr(addrMgrConst::memregions_info[region].start_addr) ||
                (addrMgrConst::is_dmi_addr(addrMgrConst::memregions_info[region].start_addr) && addrMgrConst::get_addr_gprar_nc(addrMgrConst::memregions_info[region].start_addr)))) begin
                
                slave_id = addrMgrConst::map_addr2dmi_or_dii(addrMgrConst::memregions_info[region].start_addr,fnmem_region_idx);

                if(!assoc_slave_id.exists(slave_id)) begin
                    assoc_slave_id[slave_id] = 1;
                    nCoherentSlaves++;
                end
            end
        end

        nNonCoherentSlaves = nTotalSlaves - nCoherentSlaves;

        // chi_sys_cfg.set_hn_addr_range(2, `TB_START_ADDR_HN_I, `TB_END_ADDR_HN_I);

        <%if (obj.testBench == "fsys") { %>
            if(k_chiaiu_access_boot_region) begin : _k_chiaiu_access_boot_region
                    chi_sys_cfg.create_new_domain(0, svt_chi_system_domain_item::NONSNOOPABLE, {0});
                    if ($test$plusargs("reduce_addr_area")) // reduce number of addr to allow more snoop
                        chi_sys_cfg.set_addr_for_domain(0, addrMgrConst::BOOT_REGION_BASE, (addrMgrConst::BOOT_REGION_BASE + (reduce_mem_size<< 6)));
                    else
                        chi_sys_cfg.set_addr_for_domain(0, addrMgrConst::BOOT_REGION_BASE, (addrMgrConst::BOOT_REGION_BASE + addrMgrConst::BOOT_REGION_SIZE-1));
            end : _k_chiaiu_access_boot_region else begin : _else_k_chiaiu_access_boot_region 
            if(nNonCoherentSlaves > 0) begin
                for(int i=0; i< <%=obj.nCHIs%>; i++) begin
                    chi_sys_cfg.create_new_domain(i, svt_chi_system_domain_item::NONSNOOPABLE, {i});
                    domain_count++;
                    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: Creating DII domain with id=%0d", i),UVM_NONE)
                end
            end
            if(nCoherentSlaves > 0) begin
                chi_sys_cfg.create_new_domain(domain_count, svt_chi_system_domain_item::INNERSNOOPABLE, {0
                    <%for(let i=1; i< obj.nCHIs; i++){%>
                        , <%=i%>
                    <%}%>
                });
                `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: Creating DMI domain with id=%0d", domain_count),UVM_NONE)
            end
        
            foreach (addrMgrConst::memregions_info[region]) begin
                if (addrMgrConst::is_dii_addr(addrMgrConst::memregions_info[region].start_addr) ||
                    (addrMgrConst::is_dmi_addr(addrMgrConst::memregions_info[region].start_addr) && addrMgrConst::get_addr_gprar_nc(addrMgrConst::memregions_info[region].start_addr))) begin
                    
                    s = addrMgrConst::memregions_info[region].start_addr;
                    if ($test$plusargs("reduce_addr_area")) begin // reduce number of addr to allow more snoop
                    e = addrMgrConst::memregions_info[region].start_addr + (reduce_mem_size<< <%=obj.wCacheLineOffset%>) ;
                    end else begin
                    e = addrMgrConst::memregions_info[region].end_addr;
                    end
                    if ($test$plusargs("unmapped_addr_access")) begin // create dummy space address to check unmapped addr
                      e = e + 1000; // add 1000 address not set in the GPRAR register
                    end 
                    d = ((e - s)/((dont_divide_nonsnoopable_region_among_CHIs==0)?<%=obj.nCHIs%>:1)) + 1;
                    
                    // domains for each CHI already created above. Just add the new addresses to those domains
                    for(int i=0; i<((dont_divide_nonsnoopable_region_among_CHIs==0)?<%=obj.nCHIs%>:1); i++) begin
                        chi_sys_cfg.set_addr_for_domain(i, (s + i*d) , (s + d*(i+1) - 1));
                        `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: Added address to DII domain with id=%0d", i),UVM_NONE)
                    end
                    if ($test$plusargs("reduce_addr_area")) begin // add some snoopable area  to allow CMO to DII
                        chi_sys_cfg.set_addr_for_domain(domain_count, e+ (1<<<%=obj.wCacheLineOffset%>) , e+(1<<<%=obj.wCacheLineOffset%>)+(reduce_mem_size<< 6));
                    end 
                    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: Adding DII address for all CHIs"),UVM_NONE)
                end else begin
                    if ($test$plusargs("reduce_addr_area")) begin // reduce number of addr to allow more snoop
                      chi_sys_cfg.set_addr_for_domain(domain_count, addrMgrConst::memregions_info[region].start_addr, addrMgrConst::memregions_info[region].start_addr+(reduce_mem_size<< <%=obj.wCacheLineOffset%>));
                      if (addrMgrConst::memregions_info[region].start_addr+(reduce_mem_size<< <%=obj.wCacheLineOffset%>) < addrMgrConst::memregions_info[region].end_addr-(reduce_mem_size<< <%=obj.wCacheLineOffset%>)) begin:_avoid_overlap
                         chi_sys_cfg.set_addr_for_domain(domain_count, addrMgrConst::memregions_info[region].end_addr-(reduce_mem_size<< <%=obj.wCacheLineOffset%>), addrMgrConst::memregions_info[region].end_addr);
                      end:_avoid_overlap
                    end else begin 
                    chi_sys_cfg.set_addr_for_domain(domain_count, addrMgrConst::memregions_info[region].start_addr, addrMgrConst::memregions_info[region].end_addr);
                    end
                    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: Setting address for DMI domain (id=%0d)", domain_count),UVM_NONE)
                    if ($test$plusargs("unmapped_addr_access")) begin // create dummy space address to check unmapped addr
                       chi_sys_cfg.set_addr_for_domain(domain_count,addrMgrConst::memregions_info[region].end_addr,addrMgrConst::memregions_info[region].end_addr+1000);
                       `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: Setting dummy address in DMI domain (id=%0d)", domain_count),UVM_NONE)
                    end
                end
            end
            begin:_nrs_addr_area
               int chi_csr_nbr;
               if (!$value$plusargs("chi_csr_nbr=%d",chi_csr_nbr)) begin 
                   chi_csr_nbr=0;
               end else begin // if chi_csr_nbr doesn't exist use CHI0
                   if (!(chi_csr_nbr inside { 0 <%for(let i=1; i< obj.nCHIs; i++){%> , <%=i%><%}%>})) chi_csr_nbr=0;
               end
               chi_sys_cfg.set_addr_for_domain(chi_csr_nbr, addrMgrConst::NRS_REGION_BASE, addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE-1);
            end:_nrs_addr_area
            `uvm_info(get_name(),$psprintf("All addr programming complete"),UVM_NONE)
    end : _else_k_chiaiu_access_boot_region 
        <%}%>
        <%if (obj.testBench == "chi_aiu") { %>
            foreach (csrq[i]) begin
                if(csrq[i].unit == addrMgrConst::DII && chi_aiu_non_snoopable_domain_created==0) begin
                    non_snoopable_domain_id = domain_type_cnt;
                    chi_sys_cfg.create_new_domain(domain_type_cnt, svt_chi_system_domain_item::NONSNOOPABLE, {0});
                    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: Creating NONSNOOPABLE domain with domain_id %0d",non_snoopable_domain_id),UVM_NONE)
                    chi_aiu_non_snoopable_domain_created = 1;
                    domain_type_cnt = domain_type_cnt + 1;
                end
                if(csrq[i].unit == addrMgrConst::DMI && chi_aiu_inner_snoopable_domain_created==0) begin
                    inner_snoopable_domain_id = domain_type_cnt;
                    chi_sys_cfg.create_new_domain(domain_type_cnt, svt_chi_system_domain_item::INNERSNOOPABLE, {0});
                    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: Creating INNERSNOOPABLE domain with domain_id %0d",inner_snoopable_domain_id),UVM_NONE)
                    chi_aiu_inner_snoopable_domain_created = 1;
                    domain_type_cnt = domain_type_cnt + 1;
                end
                start_addr = {csrq[i].upp_addr, csrq[i].low_addr} << 12;
                if(csrq[i].unit == addrMgrConst::DII) begin
                    domain_size = (1 << (csrq[i].size+12));
                    end_addr = start_addr + domain_size - 1;
                    chi_sys_cfg.set_addr_for_domain(non_snoopable_domain_id, start_addr, end_addr);
                    addrMgrConst::dii_memory_domain_start_addr.push_back(start_addr);
                    addrMgrConst::dii_memory_domain_end_addr.push_back(end_addr);
                    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: set_addr_for_domain NONSNOOPABLE domain_id %0d",non_snoopable_domain_id),UVM_NONE)
                end
                if(csrq[i].unit == addrMgrConst::DMI) begin
                    //domain_size = (1 << (csrq[i].size+12)+$clog2(addrMgrConst::nmig));
                    domain_size = (1 << (csrq[i].size+12)+$clog2(addrMgrConst::intrlvgrp_vector[addrMgrConst::picked_dmi_igs][csrq[i].mig_nunitid]));
                    end_addr = start_addr + domain_size - 1;
                    chi_sys_cfg.set_addr_for_domain(inner_snoopable_domain_id, start_addr, end_addr);
                    addrMgrConst::dmi_memory_domain_start_addr.push_back(start_addr);
                    addrMgrConst::dmi_memory_domain_end_addr.push_back(end_addr);
                    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: set_addr_for_domain INNERSNOOPABLE  domain_id %0d",inner_snoopable_domain_id),UVM_NONE)
                end
            end
        <%}%>

<%
//Embedded javascript code to figure number of blocks
   var pidx = 0;
   var chiaiu_idx = 0;
   var initiatorAgents = obj.AiuInfo.length ;
%>

  `ifdef SVT_CHI_PA_FSDB_ENABLE
    chi_sys_cfg.enable_xml_gen = 1;
    chi_sys_cfg.pa_format_type = svt_xml_writer::FSDB;
  `endif

    chi_sys_cfg.system_monitor_enable = 0;
    `ifdef CHI_SUBSYS
        chi_sys_cfg.memattr_propagation_checks_enable  = 1;
        chi_sys_cfg.expect_snpuniquestash_for_stashonceunique_xact = 1;
        chi_sys_cfg.expect_snpunique_for_stashonceunique_xact = 1;
        chi_sys_cfg.expect_snpshared_for_stashonceshared_xact = 1;
    `endif
    <% for(chiaiu_idx = 0; chiaiu_idx < obj.nCHIs; chiaiu_idx++) { %>
        <% if ((chiaiu_idx<1 && obj.testBench == "chi_aiu") || (obj.testBench == "fsys")) { %>

            <% if(obj.ChiaiuInfo[chiaiu_idx].fnNativeInterface == 'CHI-B') { %>
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].chi_spec_revision = svt_chi_node_configuration::ISSUE_B;
            <% } %>

            <% if(obj.ChiaiuInfo[chiaiu_idx].fnNativeInterface == 'CHI-E') { %>
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].chi_spec_revision = svt_chi_node_configuration::ISSUE_E;
            <% } %>

            // <%if(obj.AiuInfo[chiaiu_idx].fnNativeInterface == 'CHI-E'){%>
            //     // chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].cleansharedpersistsep_xact_enable= 1;
            // <%}%>
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].dvm_version_support = (DVMV8_4==1) ? svt_chi_node_configuration::DVM_v8_4 : 
                                                                        (DVMV8_1==1) ? svt_chi_node_configuration::DVM_v8_1 : svt_chi_node_configuration::DVM_v8_0;
            if ($test$plusargs("use_dvm_addr")) begin
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].dvm_sync_transmission_policy = svt_chi_node_configuration::DO_NOT_WAIT_FOR_NON_SYNC_TO_COMPLETE;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].allow_dvm_sync_without_prior_non_sync = 1;
            end

            if($test$plusargs("dvm_debug")) begin	
              if($test$plusargs("dvm84")) begin	
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].dvm_version_support =svt_chi_node_configuration::DVM_v8_4 ; 
              end else if ($test$plusargs("dvm81")) begin
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].dvm_version_support =svt_chi_node_configuration::DVM_v8_1 ; 
              end else begin
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].dvm_version_support =svt_chi_node_configuration::DVM_v8_0 ; 
              end 
            end
            if(chi_rn_node_delay_enable) begin
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].delays_enable = 1;
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].prot_layer_delays_enable = 1;
            end
            if ($value$plusargs("en_excl_txn=%d",en_excl_txn)) begin
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].exclusive_access_enable = en_excl_txn;
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].allow_exclusive_store_without_exclusive_load = 1;
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].allow_exclusive_store_on_exclusive_monitor_reset = 1;
            end else begin
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].exclusive_access_enable = 1;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].partial_cache_line_states_enable  = 1;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].allow_exclusive_store_without_exclusive_load = 1;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].allow_exclusive_store_on_exclusive_monitor_reset = 1;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].other_initial_cache_state_enable = 1;


                    // switches to allow back-to-back transactions
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].num_outstanding_xact = 15;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].rx_rsp_vc_flit_buffer_size = 15;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].rx_dat_vc_flit_buffer_size = 15;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].rx_snp_vc_flit_buffer_size = 15;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].rx_req_vc_flit_buffer_size = 15;
            end

            if ($test$plusargs("en_extra_feture")) begin
	   	chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].auto_read_seq_enable = 1;
           	chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].allow_dvm_sync_without_prior_non_sync = 1;
           	chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].allow_multiple_dvm_sync_oustanding_xacts = 1;
           	chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].multiple_req_sources_within_rn_node = 1;
            end

            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].allow_multiple_non_coherent_excl_read_from_same_lp = 1;

            if($test$plusargs("chi_rn_excl_dis")) begin	 // Adding this additional plusarg because using +en_excl_txn=1 is causing ioaiu to generate CLNUNQ because in io_mstr_seq_cfg, it is made to use testplusarg 
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].exclusive_access_enable = 1;
            end

            //CONC-8094
            if ($test$plusargs("wrong_sysrsp_target_id")) begin
	        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].block_all_transactions_until_coherency_enabled = 0;
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].num_outstanding_xact = 50;
            end

            <% if((obj.ChiaiuInfo[chiaiu_idx].fnNativeInterface == 'CHI-E')) { %>
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].cleansharedpersistsep_xact_enable = 1;
            <%}%>

            <% if((obj.ChiaiuInfo[chiaiu_idx].fnNativeInterface == 'CHI-E')) { %>
                if ($value$plusargs("streaming_order_enable=%d", streaming_order_en)) begin
                    //#Stimulus.CHI.v3.6.OWO_NCBUWrDataCompAck
                    //#Check.CHI.v3.6.OWO_with_error
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].streaming_ordered_writeunique_enable = streaming_order_en;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].streaming_ordered_writenosnp_enable = streaming_order_en;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].streaming_ordered_combined_writeunique_cmo_enable = streaming_order_en;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].streaming_ordered_combined_writenosnp_cmo_enable = streaming_order_en;
                end
            <%}%>

            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].sysco_interface_enable  = 1;
	    <% if (obj.testBench == "fsys") {%>
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].block_all_transactions_until_coherency_enabled = 0;
            <%} else {%>
                if ($value$plusargs("boot_sysco_st=%d",boot_sysco_st) || $test$plusargs("k_toggle_sysco") || $test$plusargs("chi_aiu_qchannel_reset_test")) begin
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].block_all_transactions_until_coherency_enabled = 0;
                end else if (!$test$plusargs("wrong_sysrsp_target_id")) begin
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].block_all_transactions_until_coherency_enabled = 1;
                end
            <%}%>
	    
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].syscoreq_assertion_min_delay = 600;
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].syscoreq_assertion_max_delay = 1000;
            if ($test$plusargs("SNPrsp_time_out_test")) begin
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].prot_layer_delays_enable = 1;
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].delays_enable = 1;
            end else begin
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].prot_layer_delays_enable = 0;
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].delays_enable = 0;
            end
            if($value$plusargs("max_interleave=%d",chi_aiu_max_interleave)) begin
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].read_data_interleave_depth = chi_aiu_max_interleave;
            end
            if ($test$plusargs("unmapped_add_enabled")) begin
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].enable_domain_based_addr_gen = 0;
                `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: domain based addr gen is not enabled"),UVM_NONE)
            end else begin
                if ($value$plusargs("k_enable_domain_based_addr_gen=%d",enable_domain_based_addr_gen)) begin
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].enable_domain_based_addr_gen = enable_domain_based_addr_gen;
                    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: domain based addr gen is %0s",enable_domain_based_addr_gen?"enabled":"disabled"),UVM_NONE)
                end
                else begin
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].enable_domain_based_addr_gen = enable_domain_based_addr_gen;
                    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: domain based addr gen is enabled",),UVM_NONE)
                end
            end
            `ifdef SVT_CHI_POISON_WIDTH_ENABLE
            if($value$plusargs("wt_chi_data_flit_with_poison=%d",wt_chi_data_flit_with_poison)) begin
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].poison_enable = 1;
            end else begin
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].poison_enable = 0;
            end
            `endif // `ifdef SVT_CHI_POISON_WIDTH_ENABLE
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].enable_secure_nonsecure_address_space = 1;
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].update_cache_for_prot_type = 1;
            // #Check.CHI.v3.6.CBusy
            // #Check.CHI.v3.6.TagOp
            // #Check.CHI.v3.6.SACTIVE.OTT_STT_BUSY
            // #Check.CHI.v3.6.OWO_with_other_writes
            // #Check.CHI.v3.6.PGroupID
            // #Check.CHI.v3.6.OWO
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].ll_protocol_checks_enable = svt_chi_ll_protocol_checks_enable;
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].pl_protocol_checks_enable = svt_chi_pl_protocol_checks_enable;
            // #Cover.CHI.v3.6.WrNoSnpZero
            // #Cover.CHI.v3.6.WrUnqZero
            // #Cover.CHI.v3.6.WriteBackFullCleanShPerSep
            // #Cover.CHI.v3.6.CBusy
            // #Cover.CHI.v3.6.WrBkFullClnInv
            // #Cover.CHI.v3.6.WriteCleanFullCleanSh
            // #Cover.CHI.v3.6.WriteCleanFullCleanShPerSep
            // #Cover.CHI.v3.7.WriteEvictOrEvict.ReqFlit
            // #Cover.CHI.v3.6.TagOp
            // #Cover.CHI.v3.6.Unsupported_Opcode
            // #Cover.CHI.v3.6.commands_with_errors
            // #Cover.CHI.v3.7.WriteEvictOrEvict.Error
            // #Cover.CHI.v3.6.expCompAck_wrNoSnpFull
            // #Cover.CHI.v3.6.expCompAck_wrNoSnpPtl
            // #Cover.CHI.v3.6.SACTIVE
            // #Cover.CHI.v3.6.TXNID
            // #Cover.CHI.v3.6.RdPrfrUnq
            // #Cover.CHI.v3.6.RdPrfrUnq_excl
            // #Cover.CHI.v3.6.OWO
            // #Cover.CHI.v3.6.MkRdUnq
            // #Cover.CHI.v3.6.MkRdUnq_excl
            // #Cover.CHI.v3.6.NCBWrDataCompAck
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].transaction_coverage_enable=chi_snps_fcov_en;
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].debug_port_enable = 1;

            if ($test$plusargs("chi_intf_b2b")) begin
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].prot_layer_delays_enable = 1;
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].delays_enable = 1;
            end
            /** Set the interface type. */
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].chi_interface_type = svt_chi_node_configuration::RN_F;

            /** Set the node type. */
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].chi_node_type = svt_chi_node_configuration::RN;

            /** Set unique node id for each node */
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].node_id = <%=obj.ChiaiuInfo[chiaiu_idx].FUnitId%>;

            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].snp_dvmop_sync_response_policy = svt_chi_node_configuration::DO_NOT_WAIT_FOR_OUTSTANDING_DVM_NON_SYNC_TO_COMPLETE;

            /* Set the width of the valid bits in the Address field within request and snoop VC Flit. */
            <% if (chiaiu_idx<1 && obj.testBench == "chi_aiu") { %>
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].wysiwyg_enable       = 1;

                /** Set the width of Data field within Data VC Flit. */
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].flit_data_width = <%=obj.ChiaiuInfo[chiaiu_idx].strRtlNamePrefix%>_svt_chi_node_params_pkg::SVT_CHI_NODE_WDATA;

                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].addr_width = <%=obj.ChiaiuInfo[chiaiu_idx].strRtlNamePrefix%>_svt_chi_node_params_pkg::SVT_CHI_NODE_WADDR;
            <% } %>
            <% if (obj.testBench == "fsys") { %>
                /** Set the width of Data field within Data VC Flit. */
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].wysiwyg_enable       = 0;
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].flit_data_width = chiaiu<%=chiaiu_idx%>_chi_agent_pkg::WDATA;

                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].addr_width      = chiaiu<%=chiaiu_idx%>_chi_agent_pkg::WADDR;

                `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: From Pkg<%=chiaiu_idx%> WDATA = %0d, WADDR = %0d, WSRCID=%0d",chiaiu<%=chiaiu_idx%>_chi_agent_pkg::WDATA, chiaiu<%=chiaiu_idx%>_chi_agent_pkg::WADDR, chiaiu<%=chiaiu_idx%>_chi_agent_pkg::WSRCID ),UVM_NONE)
            <% } %>

            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].node_id_width = <%=obj.ChiaiuInfo[chiaiu_idx].interfaces.chiInt.params.SrcID%>; //<%=obj.ChiaiuInfo[chiaiu_idx].strRtlNamePrefix%>_svt_chi_node_params_pkg::SVT_CHI_NODE_WSRCID;

            <% if(obj.ChiaiuInfo[chiaiu_idx].fnNativeInterface == 'CHI-A') { %>
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].chi_spec_revision = svt_chi_node_configuration::ISSUE_A;
            <% } %>
            
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].req_flit_rsvdc_width = <%=(obj.ChiaiuInfo[chiaiu_idx].interfaces.chiInt.params.REQ_RSVDC>0)?obj.ChiaiuInfo[chiaiu_idx].interfaces.chiInt.params.REQ_RSVDC:0%>;
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].dat_flit_rsvdc_width = 0;
        
            /** Enable transaction level coverage */
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].transaction_coverage_enable = chi_snps_fcov_en;
            
            /** Enable XML generation for Protocol Analyzer. */
            `ifdef PA_ENABLE
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].enable_xact_xml_gen = 1;
                chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].enable_fsm_xml_gen  = 1;
                chi_sys_cfg.pa_format_type = svt_xml_writer::FSDB;
            `endif
            
            /** Set mode */
            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].is_active = 1;
            //$display("AMBA_SYSTEM_CONFIGURATION, DEBUG: active");
            //chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].is_active = 0;
            //$display("AMBA_SYSTEM_CONFIGURATION, DEBUG: passive");

            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].dvm_enable = 1; //!enable_hn_programming;
            `ifdef SVT_CHI_ISSUE_B_ENABLE
                if(chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].chi_spec_revision == svt_chi_node_configuration::ISSUE_B) begin
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].atomic_transactions_enable = 1;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].cache_stashing_enable = 1;
                    /** Fix as per CONC-8819 for stash targets */
                    foreach(addrMgrConst::stash_nids[stash_nids_len]) begin
                        if(addrMgrConst::stash_nids[stash_nids_len]!=<%=obj.ChiaiuInfo[chiaiu_idx].nUnitId%>) begin
                            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].valid_stash_tgt_id = new[chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].valid_stash_tgt_id.size()+1] (chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].valid_stash_tgt_id);
                            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].valid_stash_tgt_id[chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].valid_stash_tgt_id.size()-1] = addrMgrConst::stash_nids[stash_nids_len];
                        end
                    end
                end
            `endif
            `ifdef SVT_CHI_ISSUE_E_ENABLE
                if(chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].chi_spec_revision == svt_chi_node_configuration::ISSUE_E) begin
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].atomic_transactions_enable = 1;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].cache_stashing_enable = 1;
                    /** Fix as per CONC-8819 for stash targets */
                    foreach(addrMgrConst::stash_nids[stash_nids_len]) begin
                        if(addrMgrConst::stash_nids[stash_nids_len]!=<%=obj.ChiaiuInfo[chiaiu_idx].nUnitId%>) begin
                            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].valid_stash_tgt_id = new[chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].valid_stash_tgt_id.size()+1] (chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].valid_stash_tgt_id);
                            chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].valid_stash_tgt_id[chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].valid_stash_tgt_id.size()-1] = addrMgrConst::stash_nids[stash_nids_len];
                        end
                    end
                end
            `endif
                      if ($test$plusargs("sync")) begin
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].dvm_sync_transmission_policy = svt_chi_node_configuration::WAIT_FOR_ALL_NON_SYNC_TO_COMPLETE;
                      end else begin
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].dvm_sync_transmission_policy = svt_chi_node_configuration::DO_NOT_WAIT_FOR_NON_SYNC_TO_COMPLETE;
                      end
                      // SVT_CHI_MAX_NUM_OUTSTANDING_XACT
                      if ($test$plusargs("snp_sync")) begin
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].snp_dvmop_sync_response_policy = svt_chi_node_configuration::WAIT_FOR_ALL_OUTSTANDING_DVM_NON_SYNC_TO_COMPLETE;
                      end else begin
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].snp_dvmop_sync_response_policy = svt_chi_node_configuration::DO_NOT_WAIT_FOR_OUTSTANDING_DVM_NON_SYNC_TO_COMPLETE;
                      end

            <% if (obj.testBench == "fsys") { %>
                if ($test$plusargs("use_dvm")) begin
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].dvm_sync_transmission_policy = svt_chi_node_configuration::DO_NOT_WAIT_FOR_NON_SYNC_TO_COMPLETE;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].allow_dvm_sync_without_prior_non_sync = 1;
                end
                if (svt_chi_delay_en==1) begin
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].delays_enable = 1;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].prot_layer_delays_enable = 1;
                    chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].cfg_lcrd_delays_enable = 1;
                end else begin
                    //std::randomize(chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].delays_enable) with {chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].delays_enable dist { 0:=95, 1:=5};};
                    //std::randomize(chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].prot_layer_delays_enable) with {chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].prot_layer_delays_enable dist { 0:=95, 1:=5};};
                    //std::randomize(chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].cfg_lcrd_delays_enable ) with {chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].cfg_lcrd_delays_enable dist { 0:=295, 1:=5};};
                    //`ifdef CHI_SUBSYS
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].delays_enable = 1'b0;
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].prot_layer_delays_enable = 1'b0;
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].cfg_lcrd_delays_enable = 1'b0;
                    //`endif
                end
            <%}%>

            if($test$plusargs("perf_test") || $test$plusargs("dii_backpressure_test")) begin
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].delays_enable               = 1'b0;
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].prot_layer_delays_enable    = 1'b0;
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].cfg_lcrd_delays_enable      = 1'b0;

                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].num_outstanding_xact        = <%=obj.ChiaiuInfo[chiaiu_idx].cmpInfo.nOttCtrlEntries%>;
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].num_outstanding_snoop_xact  = <%=obj.ChiaiuInfo[chiaiu_idx].cmpInfo.nSnpInFlight%>;

                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].rx_req_vc_flit_buffer_size  = 16;
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].rx_rsp_vc_flit_buffer_size  = 16;
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].rx_dat_vc_flit_buffer_size  = 16;
                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].rx_snp_vc_flit_buffer_size  = 16;

                        chi_sys_cfg.rn_cfg[<%=chiaiu_idx%>].single_outstanding_per_txn_id = svt_chi_node_configuration::MODIFY_SAME_TXN_ID;
                        
            end
        <%}%>
    <%}%>
    <% if(chiaiu_idx>1 && obj.testBench == "fsys") { %>
        if(chi_sys_cfg.rn_cfg.size()>0) begin
            foreach(chi_sys_cfg.rn_cfg[i]) begin
                `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: chi_sys_cfg.rn_cfg[%0d]",i),UVM_NONE)
                chi_sys_cfg.rn_cfg[i].print();
            end
        end
   <%}%>
endfunction
//=============================================================================



<% if (obj.testBench == "fsys" || obj.testBench == "io_aiu") { %>
function void cust_svt_amba_system_configuration::set_axi_system_configuration(svt_axi_system_configuration axi_sys_cfg);
    bit axi_sys_enable_domain_based_addr_gen;
    int io_subsys_nonshareable_domain_id,io_subsys_nonshareable_dmi_domain_id;
    bit io_subsys_nonshareable_domain_id_fixed;
    int io_subsys_outershareable_domain_id;
    int io_subsys_innershareable_domain_id;
    int io_subsys_innershareable_domain_create;
    int io_subsys_outershareable_domain_create; 


    int inner_domain_masters_0[],non_shareable_master_0[];
    bit [63:0] start_addr;
    bit [63:0] end_addr;
    bit  set_domain;
    bit [63:0] domain_size;
     bit [63:0] adress_range [$];
    bit mem_regions_overlap;
    bit non, innr;
  int nonsnoopable[],innersnoopable[],outersnoopable[],snoopable[];
  addrMgrConst::intq noncoh_regionsq;
  addrMgrConst::intq coh_regionsq;
  addrMgrConst::intq iocoh_regionsq;
  addr_trans_mgr    m_addr_mgr;
  ncore_memory_map m_map;
  int non_snoopable_domain_id;
  int inner_snoopable_domain_id;
  int domain_type_cnt;
  int slave_cnt;
  int dmi_slave_domain_created[$];
  int dii_slave_domain_created[$];
  bit push_unit_id;
  bit slave_domian_match_found;
  int dmi_start_nunitid;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] low_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] upp_addr;
  int port_interleaving_enable[$];
  int port_interleaving_size[$];
  int port_interleaving_group_id[$];
  int port_interleaving_index[$];
  bit dont_use_separate_rd_wr_chan_id_width = <%=atomic_txns_en%>; // CONC-12085 : If one of AIU is ACELITE-E with atomic, this condition apply, otherwise Synopsys vip fails.
    bit axi_snps_master_fcov_en;
    bit axi_snps_slave_fcov_en;
    bit svt_ace_auto_gen_dvm_complete_enable=1;
    bit io_mstr_exclusive_access_enable;
    int val_dii_read_data_reordering_depth ;
    int val_dii_write_resp_reordering_depth ;
    int val_dmi_read_data_reordering_depth ;
    int val_dmi_write_resp_reordering_depth ;
    int axi_wdata_watchdog_timeout;
    int axi_awaddr_watchdog_timeout;
    int axi_bresp_watchdog_timeout;
    int axi_rready_watchdog_timeout;
    int axi_bready_watchdog_timeout;
    bit disable_axi_watchdog_timeout;
   m_addr_mgr = addr_trans_mgr::get_instance();
   m_addr_mgr.gen_memory_map();
   axi_sys_cfg.dvm_version = (DVMV8_4==1) ? svt_axi_system_configuration::DVMV8_4 : 
                             (DVMV8_1==1) ? svt_axi_system_configuration::DVMV8_1 : svt_axi_system_configuration::DVMV8;


  axi_sys_cfg.awready_watchdog_timeout                                                                                         ='d0;
  axi_sys_cfg.arready_watchdog_timeout                                                                                         ='d0;
  axi_sys_cfg.rdata_watchdog_timeout                                                                                           ='d0;
  if(!$value$plusargs("disable_axi_watchdog_timeout=%0d", disable_axi_watchdog_timeout)) begin
      disable_axi_watchdog_timeout  = 0;
  end
  if(!$value$plusargs("axi_wdata_watchdog_timeout=%0d", axi_wdata_watchdog_timeout)) begin
      axi_sys_cfg.wdata_watchdog_timeout                                                                                           =(disable_axi_watchdog_timeout==1)?'d0:'d1024000;
  end else begin
      axi_sys_cfg.wdata_watchdog_timeout                                                                                           =(disable_axi_watchdog_timeout==1)?'d0:axi_wdata_watchdog_timeout;
  end
  if(!$value$plusargs("axi_awaddr_watchdog_timeout=%0d", axi_awaddr_watchdog_timeout)) begin
      axi_sys_cfg.awaddr_watchdog_timeout                                                                                          =(disable_axi_watchdog_timeout==1)?'d0:'d1024000;
  end else begin
      axi_sys_cfg.awaddr_watchdog_timeout                                                                                          =(disable_axi_watchdog_timeout==1)?'d0:axi_awaddr_watchdog_timeout;
  end
  void'($value$plusargs("axi_sys_enable_domain_based_addr_gen=%0b",axi_sys_enable_domain_based_addr_gen));
  if((!$value$plusargs("axi_bresp_watchdog_timeout=%0d", axi_bresp_watchdog_timeout)) || (!($test$plusargs("disable_bresp_watchdog_timeout")))) begin
      axi_sys_cfg.bresp_watchdog_timeout                                                                                       =(disable_axi_watchdog_timeout==1)?'d0:'d1024000;
  end else begin
      axi_sys_cfg.bresp_watchdog_timeout                                                                                       =(($test$plusargs("disable_bresp_watchdog_timeout")) ||(disable_axi_watchdog_timeout==1))?'d0:axi_bresp_watchdog_timeout;
  end
    if (!$value$plusargs("axi_snps_master_fcov_en=%0b", axi_snps_master_fcov_en)) begin
        axi_snps_master_fcov_en = 0;
    end
    if (!$value$plusargs("axi_snps_slave_fcov_en=%0b", axi_snps_slave_fcov_en)) begin
        axi_snps_slave_fcov_en = 0;
    end
 
        csrq = {};
        slave_cfg_csrq = {};
        csrq = addrMgrConst::get_all_gpra();
        m_mem = m_addr_mgr.get_memory_map_instance;

  m_map = m_addr_mgr.get_memory_map_instance(); 
  noncoh_regionsq = m_map.get_noncoh_mem_regions();
  iocoh_regionsq = m_map.get_iocoh_mem_regions();
  coh_regionsq = m_map.get_coh_mem_regions();

     /*   foreach (csrq[i]) begin
          `uvm_info(get_name(),
              $psprintf("unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d",
                  csrq[i].unit.name(), csrq[i].mig_nunitid,
                  csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),
              UVM_NONE) 
        end

        foreach (csrq[i]) begin
          if(csrq[i].unit == addrMgrConst::DII && ace_non_snoopable_domain_created==0) begin
            non_snoopable_domain_id = domain_type_cnt;
            axi_sys_cfg.create_new_domain(domain_type_cnt, svt_axi_system_domain_item::NONSHAREABLE, {0});
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: Creating NONSNOOPABLE domain with domain_id %0d",non_snoopable_domain_id),UVM_NONE)
            ace_non_snoopable_domain_created = 1;
            domain_type_cnt = domain_type_cnt + 1;
          end
          if(csrq[i].unit == addrMgrConst::DMI && ace_inner_snoopable_domain_created==0) begin
            inner_snoopable_domain_id = domain_type_cnt;
      	    if($test$plusargs("en_outershareable_range")) begin	
            axi_sys_cfg.create_new_domain(domain_type_cnt, svt_axi_system_domain_item::OUTERSHAREABLE, {0});
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: Creating INNERSNOOPABLE domain with domain_id %0d",non_snoopable_domain_id),UVM_NONE)
            end else begin
            axi_sys_cfg.create_new_domain(domain_type_cnt, svt_axi_system_domain_item::INNERSHAREABLE, {0});
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: Creating INNERSNOOPABLE domain with domain_id %0d",non_snoopable_domain_id),UVM_NONE)
            end 
            ace_inner_snoopable_domain_created = 1;
            domain_type_cnt = domain_type_cnt + 1;
          end
          start_addr = {csrq[i].upp_addr, csrq[i].low_addr} << 12;
          if(csrq[i].unit == addrMgrConst::DII) begin
            domain_size = (1 << (csrq[i].size+12));
            end_addr = start_addr + domain_size - 1;
            axi_sys_cfg.set_addr_for_domain(non_snoopable_domain_id, start_addr, end_addr);
            addrMgrConst::dii_memory_domain_start_addr.push_back(start_addr);
            addrMgrConst::dii_memory_domain_end_addr.push_back(end_addr);
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: set_addr_for_domain NONSNOOPABLE domain_id %0d start_addr 0x%h end_addr 0x%h domain_size 'd%0d",non_snoopable_domain_id,start_addr,end_addr,domain_size),UVM_NONE)
          end
          if(csrq[i].unit == addrMgrConst::DMI) begin
            //domain_size = (1 << (csrq[i].size+12)+$clog2(addrMgrConst::nmig));
            domain_size = (1 << (csrq[i].size+12)+$clog2(addrMgrConst::intrlvgrp_vector[addrMgrConst::picked_dmi_igs][csrq[i].mig_nunitid]));
            end_addr = start_addr + domain_size - 1;
            axi_sys_cfg.set_addr_for_domain(inner_snoopable_domain_id, start_addr, end_addr);
            addrMgrConst::dmi_memory_domain_start_addr.push_back(start_addr);
            addrMgrConst::dmi_memory_domain_end_addr.push_back(end_addr);
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: set_addr_for_domain INNERSNOOPABLE  domain_id %0d start_addr 0x%h end_addr 0x%h domain_size 'd%0d nmig %0d",inner_snoopable_domain_id,start_addr,end_addr,domain_size,addrMgrConst::nmig),UVM_NONE)
          end
        end
*/
//=========BASIC_AXI_CFG===================================
    axi_sys_cfg.num_masters = `NUM_ACE_MASTERS;
    axi_sys_cfg.num_slaves  = `NUM_ACE_SLAVES;
    axi_sys_cfg.create_sub_cfgs(`NUM_ACE_MASTERS,`NUM_ACE_SLAVES,0,0); //todo:add dmi,dii axi for slaves 
    axi_sys_cfg.bus_inactivity_timeout = 0;
    //axi_sys_cfg.use_interconnect = 0;
    if ($test$plusargs("en_system_chkrs")) begin 
      axi_sys_cfg.system_monitor_enable = 1;
      axi_sys_cfg.posted_write_xacts_enable = 0;
      axi_sys_cfg.master_slave_xact_data_integrity_check_enable = 1;
    end else begin 
      axi_sys_cfg.system_monitor_enable = 0;
    end
    axi_sys_cfg.common_clock_mode = 0;
    if(!$value$plusargs("axi_rready_watchdog_timeout=%0d", axi_rready_watchdog_timeout)) begin
        axi_sys_cfg.rready_watchdog_timeout = (disable_axi_watchdog_timeout==1)?'d0:(`SVT_AXI_MAX_AXI3_GENERIC_DELAY + 2000);
    end else begin
        axi_sys_cfg.rready_watchdog_timeout = (disable_axi_watchdog_timeout==1)?'d0:axi_rready_watchdog_timeout;
    end
    if(!$value$plusargs("axi_bready_watchdog_timeout=%0d", axi_bready_watchdog_timeout)) begin
        axi_sys_cfg.bready_watchdog_timeout = (disable_axi_watchdog_timeout==1)?'d0:(`SVT_AXI_MAX_AXI3_GENERIC_DELAY + 2000);
    end else begin
        axi_sys_cfg.bready_watchdog_timeout = (disable_axi_watchdog_timeout==1)?'d0:axi_bready_watchdog_timeout;
    end
//=========ADDRESS_SPACE==============================
    //stimulus

`ifdef USE_VIP_SNPS_AXI_SLAVES
    //reg booting seq
    //axi_sys_cfg.set_addr_range(-1, addrMgrConst::NRS_REGION_BASE, (addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE-1) );    //<------CSR (DII SYS)
    //axi_sys_cfg.set_addr_range(-1, addrMgrConst::BOOT_REGION_BASE, (addrMgrConst::BOOT_REGION_BASE + addrMgrConst::BOOT_REGION_SIZE-1) ); //<------BOOT
  foreach (m_mem.nintrlv_grps[i]) begin
     slave_cfg_csrq = addrMgrConst::get_memregions_assoc_ig(i);
     foreach (slave_cfg_csrq[j]) begin
	low_addr = (slave_cfg_csrq[j].low_addr<<12) | (slave_cfg_csrq[j].upp_addr << 44);
	upp_addr = low_addr + m_mem.nintrlv_grps[i]*(1<<(slave_cfg_csrq[j].size+12)) - 1;
	if(slave_cfg_csrq[j].unit == addrMgrConst::DMI) begin
           for(int unit=0; unit<m_mem.nintrlv_grps[i]; unit=unit+1) begin
              //$sformat(s, "%s %0d", s, dmi_start_nunitid+unit);
              if(dmi_slave_domain_created.size == 0)  begin
                 dmi_slave_domain_created.push_back(dmi_start_nunitid+unit);
                 push_unit_id = 1;
              end
              else begin
                foreach(dmi_slave_domain_created[y]) begin
                  if(((dmi_start_nunitid+unit)== dmi_slave_domain_created[y]) && (slave_domian_match_found==0)) begin
                    slave_domian_match_found = 1; 
                    slave_cnt = slave_cnt - 1;
                    push_unit_id = 0;
                  end
                  else if(((dmi_start_nunitid+unit)!= dmi_slave_domain_created[y]) && (slave_domian_match_found==0)) begin
                    push_unit_id=1;
                  end
                end
                slave_domian_match_found = 0;
              end
              if(push_unit_id) begin
              int ig = slave_cfg_csrq[j].mig_nunitid;
              int nDmis_per_ig = addrMgrConst::intrlvgrp_vector[addrMgrConst::picked_dmi_igs][ig];

                if(m_mem.nintrlv_grps[i]>1 && unit>0) begin
                    port_interleaving_enable.push_back(1);
                    port_interleaving_group_id.push_back(port_interleaving_group_id[port_interleaving_group_id.size - 1]);
                    port_interleaving_size.push_back(1<<(addrMgrConst::dmi_sel_bits[addrMgrConst::picked_dmi_if[nDmis_per_ig]][nDmis_per_ig].pri_bits[addrMgrConst::dmi_sel_bits[addrMgrConst::picked_dmi_if[nDmis_per_ig]][nDmis_per_ig].pri_bits.size() -1]));
                    port_interleaving_index.push_back(unit);
                    `uvm_info("Checking in if",$sformatf("value of id = %0p and index = %0p",port_interleaving_group_id,port_interleaving_index),UVM_NONE)
                end
                else if(m_mem.nintrlv_grps[i]>1 && unit==0) begin
                    port_interleaving_enable.push_back(1);
                    port_interleaving_group_id.push_back(port_interleaving_group_id.size);
                    port_interleaving_size.push_back(1<<(addrMgrConst::dmi_sel_bits[addrMgrConst::picked_dmi_if[nDmis_per_ig]][nDmis_per_ig].pri_bits[addrMgrConst::dmi_sel_bits[addrMgrConst::picked_dmi_if[nDmis_per_ig]][nDmis_per_ig].pri_bits.size() -1]));
                    port_interleaving_index.push_back(unit);
                    `uvm_info("Checking in else",$sformatf("value of id = %0p and index = %0p",port_interleaving_group_id,port_interleaving_index),UVM_NONE)
                end
                else begin
                  port_interleaving_enable.push_back(0);
                end
                dmi_slave_domain_created.push_back(dmi_start_nunitid+unit);
                push_unit_id = 0;
              end
              axi_sys_cfg.set_addr_range(dmi_start_nunitid+unit,low_addr,upp_addr); //<------BOOT
              //axi_sys_cfg.set_addr_range(slave_cnt,low_addr,upp_addr); //<------BOOT
              `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration-set_addr_range:: i %0d j %0d nintrlv_grps[%0d] %0d Unit name %0s Unit Id %0d (%0d + %0d) slave_cnt %0d %0d start_addr 0x%h end_addr 0x%h slave_domian_match_found %0d",i,j,i,m_mem.nintrlv_grps[i],slave_cfg_csrq[j].unit.name(),dmi_start_nunitid+unit,dmi_start_nunitid,unit,slave_cnt,dmi_start_nunitid+unit,low_addr,upp_addr,slave_domian_match_found),UVM_NONE)
              slave_cnt = slave_cnt + 1;
	   end //for
           //dmi_start_nunitid = dmi_start_nunitid + m_mem.nintrlv_grps[i];
	end // if (slave_cfg_csrq[j].unit == addrMgrConst::DMI)
	else begin
           //port_interleaving_enable.push_back(0);
           //$sformat(s, "%s %s %0d           |", s, slave_cfg_csrq[j].unit.name(), slave_cfg_csrq[j].mig_nunitid);
           if(dii_slave_domain_created.size == 0)  dii_slave_domain_created.push_back(slave_cfg_csrq[j].mig_nunitid);
           else begin
             foreach(dii_slave_domain_created[t]) begin
               if(((slave_cfg_csrq[j].mig_nunitid)== dii_slave_domain_created[t]) && (slave_domian_match_found==0)) begin
                 push_unit_id = 0;
                 slave_domian_match_found = 1; 
                 slave_cnt = slave_cnt - 1;
               end
               else if(((slave_cfg_csrq[j].mig_nunitid)== dii_slave_domain_created[t])) begin
                 push_unit_id = 1;
               end
             end
             if(push_unit_id) begin
               dii_slave_domain_created.push_back(slave_cfg_csrq[j].mig_nunitid);
               push_unit_id = 0;
             end
             slave_domian_match_found = 0;
           end
           //axi_sys_cfg.set_addr_range(slave_cnt,low_addr,upp_addr); //<------BOOT
           axi_sys_cfg.set_addr_range(<%=obj.nDMIs%> + slave_cfg_csrq[j].mig_nunitid,low_addr,upp_addr); //<------BOOT
           `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration-set_addr_range:: i %0d j %0d Unit name %0s Unit Id %0d slave_cnt %0d %0d start_addr 0x%h end_addr 0x%h slave_domian_match_found %0d",i,j,slave_cfg_csrq[j].unit.name(),slave_cfg_csrq[j].mig_nunitid,slave_cnt,<%=obj.nDMIs%> + slave_cfg_csrq[j].mig_nunitid,low_addr,upp_addr,slave_domian_match_found),UVM_NONE)
           slave_cnt = slave_cnt + 1;
        end // else: !if(slave_cfg_csrq[j].unit == addrMgrConst::DMI)
     end // foreach (slave_cfg_csrq[j])
     if(m_mem.nintrlv_type[i] == addrMgrConst::DMI) begin
        dmi_start_nunitid = dmi_start_nunitid + m_mem.nintrlv_grps[i];
     end
  end // foreach (m_mem.nintrlv_grps[i])
  <% if (obj.AiuInfo[1].BootInfo.regionHut == 0) { %>
  //$sformat(s, "%s %s %0d           |", s, "DMI", <%=obj.AiuInfo[0].BootInfo.regionHui%>);
  axi_sys_cfg.set_addr_range(<%=obj.AiuInfo[0].BootInfo.regionHui%>, addrMgrConst::BOOT_REGION_BASE, (addrMgrConst::BOOT_REGION_BASE + addrMgrConst::BOOT_REGION_SIZE-1) ); //<------BOOT
  <% } else { %>
  //$sformat(s, "%s %s %0d           |", s, "DII", <%=obj.AiuInfo[0].BootInfo.regionHui%>);
  axi_sys_cfg.set_addr_range(<%=obj.AiuInfo[0].BootInfo.regionHui +  obj.nDMIs%>, addrMgrConst::BOOT_REGION_BASE, (addrMgrConst::BOOT_REGION_BASE + addrMgrConst::BOOT_REGION_SIZE-1) ); //<------BOOT
  <% } %>

`endif // `ifdef USE_VIP_SNPS_AXI_SLAVES

//=========SET_ACE_CONFIG=============================
<%
  var pidx = 0;
  var axiaiu_idx = 0;

  for(pidx = 0; pidx < obj.nAIUs; pidx++) { 
    if(((obj.AiuInfo[pidx].fnNativeInterface == 'AXI5')||(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')) ) {
if(obj.AiuInfo[pidx].nNativeInterfacePorts>1){for (var i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) { if(obj.AiuInfo[pidx].interfaces.axiInt[i].direction == 'slave'){
      if ((obj.testBench == "io_aiu" && axiaiu_idx<1 && obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId)||(obj.testBench == "fsys")) { 


      if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' ) || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI5' )){%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::AXI4;
<%if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI5' ){%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].ace_version = svt_axi_port_configuration::ACE_VERSION_2_0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].atomic_transactions_enable = <%=(obj.AiuInfo[pidx].interfaces.axiInt.params.atomicTransactions==true)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].use_separate_rd_wr_chan_id_width = 0;
<%}%>
<%if(obj.AiuInfo[pidx].interfaces.axiInt[i].params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].ace_version = svt_axi_port_configuration::ACE_VERSION_2_0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].check_type                   = svt_axi_port_configuration::ODD_PARITY_BYTE_ALL;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].trace_tag_enable                   = 1;
<%}%>
<%}%>
<%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5')) {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].ace_version = svt_axi_port_configuration::ACE_VERSION_2_0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::AXI_ACE;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].enable_multi_cacheline_ace_wu_ro_xacts = 1;
<%if(obj.AiuInfo[pidx].interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].check_type                   = svt_axi_port_configuration::ODD_PARITY_BYTE_ALL;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].trace_tag_enable                   = 0;
<%}%>
<%}%>
<%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' ) {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::ACE_LITE;<%}%>
<%if(obj.AiuInfo[pidx].interfaces.axiInt[i].params.eAc==1) {%>
    `ifdef VIP_SNPS_INCL_SNP_CHNL_FOR_ACELITE_DVM // Test should drive only dvm (DVM sender) & Synopsys vip will respond to SnpDVM through snoop channel if only if we configure ACELITE as ACELITE-E. Need to experiment whether this works or not.
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].ace_version = svt_axi_port_configuration::ACE_VERSION_2_0;
    `endif
<%}%>
<%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::ACE_LITE;//need to check if ACE_LITE_E is there in svt_axi_port_configuration
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].ace_version = svt_axi_port_configuration::ACE_VERSION_2_0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].atomic_transactions_enable   = 0; //<%=(obj.AiuInfo[pidx].interfaces.axiInt.params.eAtomic>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cache_stashing_enable = 1;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].deallocating_xacts_enable = 1;
<%if(obj.AiuInfo[pidx].interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].check_type                   = svt_axi_port_configuration::ODD_PARITY_BYTE_ALL;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].trace_tag_enable                   = 1;
<%}%>

<%}%>

 if($test$plusargs("same_id")) begin	
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cov_same_id_in_outstanding_xacts                    = 8;
   end
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cov_bins_num_outstanding_snoop_xacts                    = 4;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].is_active                    = 1;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].addr_width                   = <%=obj.AiuInfo[pidx].interfaces.axiInt[i].params.wAddr%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].data_width                   = <%=obj.AiuInfo[pidx].interfaces.axiInt[i].params.wData%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].snoop_data_width             = <%=(obj.AiuInfo[pidx].interfaces.axiInt[i].params.wCdData>0)?obj.AiuInfo[pidx].interfaces.axiInt[i].params.wCdData:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cache_line_size              = 64; //json param? // c3.1.5
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].speculative_read_enable      = 1;
 <%if(obj.AiuInfo[pidx].fnNativeInterface != 'ACELITE-E') {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cache_stashing_enable          = 0;
 <%}%>
    if($value$plusargs("io_mstr_exclusive_access_enable=%0b", io_mstr_exclusive_access_enable))
       axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].exclusive_access_enable = io_mstr_exclusive_access_enable; 
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].barrier_enable                 = 0;
<%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5')|| (obj.AiuInfo[pidx].interfaces.axiInt[i].params.eAc==1)) {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].dvm_enable                     = 1;
    void'($value$plusargs("svt_ace_auto_gen_dvm_complete_enable=%0b",svt_ace_auto_gen_dvm_complete_enable));
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].auto_gen_dvm_complete_enable   = svt_ace_auto_gen_dvm_complete_enable;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cov_same_id_in_dvm_tlbi_outstanding_xacts                    = 8;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cov_bins_dvm_tlbi_num_outstanding_xacts                    = 3;
<% } else { %>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].dvm_enable                     = 0;
<%}%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].trans_ace_num_outstanding_dvm_tlb_invalidate_xacts_with_same_arid_enable = 0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].trans_ace_num_outstanding_dvm_tlb_invalidate_xacts_with_diff_arid_enable = 0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].update_cache_for_prot_type = 1;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].tagged_address_space_attributes_enable            = 0;
    axi_sys_cfg.allow_slaves_with_overlapping_addr         = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].addr_width                   = `SVT_AXI_MAX_ADDR_WIDTH - 1;
<%if(obj.testBench == "fsys") { %>
        if($test$plusargs("def_ready_zero_val_at_ioaiu_native_if")) begin
<%} else {%>
        if($test$plusargs("long_delay_en")) begin
<%}%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].default_bready                = 0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].default_rready                = 0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].default_crready                = 0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].default_acready                = 0;
    end


    //drive idles to LOW_VAL(zero)
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].read_addr_chan_idle_val        = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val        = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].write_addr_chan_idle_val       = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].write_data_chan_idle_val       = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val       = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;

    //drive user signals
  
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].aruser_enable                = <%=(obj.AiuInfo[pidx].interfaces.axiInt[i].params.wArUser>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].awuser_enable                = <%=(obj.AiuInfo[pidx].interfaces.axiInt[i].params.wAwUser>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].ruser_enable                 = <%=(obj.AiuInfo[pidx].interfaces.axiInt[i].params.wRUser>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].wuser_enable                 = <%=(obj.AiuInfo[pidx].interfaces.axiInt[i].params.wWUser>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].buser_enable                 = <%=(obj.AiuInfo[pidx].interfaces.axiInt[i].params.wBUser>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].writeevict_enable            = <%=(obj.AiuInfo[pidx].interfaces.axiInt[i].params.eUnique>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].awunique_enable              = <%=(obj.AiuInfo[pidx].interfaces.axiInt[i].params.eUnique>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].awqos_enable                 = <%=(obj.AiuInfo[pidx].interfaces.axiInt[i].params.wQos>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].arqos_enable                 = <%=(obj.AiuInfo[pidx].interfaces.axiInt[i].params.wQos>0)?1:0%>;
    if(dont_use_separate_rd_wr_chan_id_width) begin
        axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].use_separate_rd_wr_chan_id_width = 0;
        axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].id_width = <%=((obj.AiuInfo[pidx].interfaces.axiInt[i].params.wAwId<obj.AiuInfo[pidx].interfaces.axiInt[i].params.wArId)?obj.AiuInfo[pidx].interfaces.axiInt[i].params.wAwId:obj.AiuInfo[pidx].interfaces.axiInt[i].params.wArId)%>;
    end else begin
        axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].use_separate_rd_wr_chan_id_width = 1;
        axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].write_chan_id_width          = <%=obj.AiuInfo[pidx].interfaces.axiInt[i].params.wAwId%>;
        axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].read_chan_id_width           = <%=obj.AiuInfo[pidx].interfaces.axiInt[i].params.wArId%>;
    end

    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].enable_xml_gen               = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].aruser_enable                = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].awuser_enable                = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].ruser_enable                 = 0;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].wuser_enable                 = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].buser_enable                 = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].writeevict_enable            = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].awunique_enable              = 1;
    axi_sys_cfg.wready_watchdog_timeout                 = 0;

<%axiaiu_idx++;}}}} else {
      if ((obj.testBench == "io_aiu" && axiaiu_idx<1 && obj.AiuInfo[pidx].strRtlNamePrefix==obj.BlockId)||(obj.testBench == "fsys")) { 
      if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' ) || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI5' )){%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::AXI4;
<%if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI5' ){%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].ace_version = svt_axi_port_configuration::ACE_VERSION_2_0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].atomic_transactions_enable = <%=(obj.AiuInfo[pidx].interfaces.axiInt.params.atomicTransactions==true)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].use_separate_rd_wr_chan_id_width = 0;
<%}%>
<%if(obj.AiuInfo[pidx].interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].ace_version = svt_axi_port_configuration::ACE_VERSION_2_0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].check_type                   = svt_axi_port_configuration::ODD_PARITY_BYTE_ALL;
<%}%>
<%}%>
<%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5')) {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].ace_version = svt_axi_port_configuration::ACE_VERSION_2_0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::AXI_ACE;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].enable_multi_cacheline_ace_wu_ro_xacts = 1;
<%if(obj.AiuInfo[pidx].interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].check_type                   = svt_axi_port_configuration::ODD_PARITY_BYTE_ALL;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].trace_tag_enable                   = 0;
<%}%>
    <%}%>
<%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' ) {%>
//abc <%=pidx%> 
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::ACE_LITE;<%}%>
<%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::ACE_LITE;//need to check if ACE_LITE_E is there in svt_axi_port_configuration
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].ace_version = svt_axi_port_configuration::ACE_VERSION_2_0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].atomic_transactions_enable   = 0; // <%=(obj.AiuInfo[pidx].interfaces.axiInt.params.eAtomic>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cache_stashing_enable = 1;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].deallocating_xacts_enable = 1;
<%if(obj.AiuInfo[pidx].interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].check_type                   = svt_axi_port_configuration::ODD_PARITY_BYTE_ALL;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].trace_tag_enable                   = 1;
<%}%>

<%}%>

 if($test$plusargs("same_id")) begin	
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cov_same_id_in_outstanding_xacts                    = 8;
   end
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cov_bins_num_outstanding_snoop_xacts                    = 4;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].is_active                    = 1;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].addr_width                   = <%=obj.AiuInfo[pidx].interfaces.axiInt.params.wAddr%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].data_width                   = <%=obj.AiuInfo[pidx].interfaces.axiInt.params.wData%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].snoop_data_width             = <%=(obj.AiuInfo[pidx].interfaces.axiInt.params.wCdData>0)?obj.AiuInfo[pidx].interfaces.axiInt.params.wCdData:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cache_line_size              = 64; //json param? // c3.1.5
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].speculative_read_enable      = 1;
 <%if(obj.AiuInfo[pidx].fnNativeInterface != 'ACELITE-E') {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cache_stashing_enable          = 0;
 <%}%>
    if($value$plusargs("io_mstr_exclusive_access_enable=%0b", io_mstr_exclusive_access_enable))
       axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].exclusive_access_enable = io_mstr_exclusive_access_enable; 
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].barrier_enable                 = 0;
<%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5')|| (obj.AiuInfo[pidx].interfaces.axiInt.params.eAc==1)) {%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].dvm_enable                     = 1;
    void'($value$plusargs("svt_ace_auto_gen_dvm_complete_enable=%0b",svt_ace_auto_gen_dvm_complete_enable));
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].auto_gen_dvm_complete_enable   = svt_ace_auto_gen_dvm_complete_enable;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cov_same_id_in_dvm_tlbi_outstanding_xacts                    = 8;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].cov_bins_dvm_tlbi_num_outstanding_xacts                    = 3;
<% } else { %>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].dvm_enable                     = 0;
<%}%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].trans_ace_num_outstanding_dvm_tlb_invalidate_xacts_with_same_arid_enable = 0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].trans_ace_num_outstanding_dvm_tlb_invalidate_xacts_with_diff_arid_enable = 0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].update_cache_for_prot_type = 1;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].tagged_address_space_attributes_enable            = 0;
    axi_sys_cfg.allow_slaves_with_overlapping_addr         = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].addr_width                   = `SVT_AXI_MAX_ADDR_WIDTH - 1;
<%if(obj.testBench == "fsys") { %>
        if($test$plusargs("def_ready_zero_val_at_ioaiu_native_if")) begin
<%} else {%>
        if($test$plusargs("long_delay_en")) begin
<%}%>
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].default_bready                = 0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].default_rready                = 0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].default_crready                = 0;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].default_acready                = 0;
end


    //drive idles to LOW_VAL(zero)
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].read_addr_chan_idle_val        = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val        = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].write_addr_chan_idle_val       = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].write_data_chan_idle_val       = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val       = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL;

    //drive user signals
  
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].num_cache_lines              = 256;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].dvm_enable                   = 0;
   

    if((axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].axi_interface_type == svt_axi_port_configuration::ACE_LITE) || (axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].axi_interface_type == svt_axi_port_configuration::AXI_ACE)) begin
        axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].nonshareable_xact_address_range_in_systemshareable_mode = svt_axi_port_configuration::NONSHAREABLE_XACT_ADDR_WITHIN_NON_SHAREABLE_ADDR_RANGE;
    end
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].aruser_enable                = <%=(obj.AiuInfo[pidx].interfaces.axiInt.params.wArUser>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].awuser_enable                = <%=(obj.AiuInfo[pidx].interfaces.axiInt.params.wAwUser>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].ruser_enable                 = <%=(obj.AiuInfo[pidx].interfaces.axiInt.params.wRUser>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].wuser_enable                 = <%=(obj.AiuInfo[pidx].interfaces.axiInt.params.wWUser>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].buser_enable                 = <%=(obj.AiuInfo[pidx].interfaces.axiInt.params.wBUser>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].writeevict_enable            = <%=(obj.AiuInfo[pidx].interfaces.axiInt.params.eUnique>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].awunique_enable              = <%=(obj.AiuInfo[pidx].interfaces.axiInt.params.eUnique>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].awqos_enable                 = <%=(obj.AiuInfo[pidx].interfaces.axiInt.params.wQos>0)?1:0%>;
    axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].arqos_enable                 = <%=(obj.AiuInfo[pidx].interfaces.axiInt.params.wQos>0)?1:0%>;
    if(dont_use_separate_rd_wr_chan_id_width) begin
        axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].use_separate_rd_wr_chan_id_width = 0;
        axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].id_width = <%=((obj.AiuInfo[pidx].interfaces.axiInt.params.wAwId<obj.AiuInfo[pidx].interfaces.axiInt.params.wArId)?obj.AiuInfo[pidx].interfaces.axiInt.params.wAwId:obj.AiuInfo[pidx].interfaces.axiInt.params.wArId)%>;
    end else begin
        axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].use_separate_rd_wr_chan_id_width = 1;
        axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].write_chan_id_width          = <%=obj.AiuInfo[pidx].interfaces.axiInt.params.wAwId%>;
        axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].read_chan_id_width           = <%=obj.AiuInfo[pidx].interfaces.axiInt.params.wArId%>;
    end

    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].enable_xml_gen               = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].aruser_enable                = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].awuser_enable                = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].ruser_enable                 = 0;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].wuser_enable                 = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].buser_enable                 = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].writeevict_enable            = 1;
    //axi_sys_cfg.master_cfg[<%=axiaiu_idx%>].awunique_enable              = 1;
    axi_sys_cfg.wready_watchdog_timeout                 = 0;

<%axiaiu_idx++;}}}}%>
   <% if(axiaiu_idx>1 && obj.testBench == "fsys") { %>
   if(axi_sys_cfg.master_cfg.size()>0) begin
     foreach(axi_sys_cfg.master_cfg[i]) begin
         //`uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: axi_sys_cfg.master_cfg[%0d]",i),UVM_NONE)
         //axi_sys_cfg.master_cfg[i].print();
     end
   end
   <% } %>
   `ifdef IO_UNITS_CNT_NON_ZERO 
    foreach(addrMgrConst::io_subsys_nativeif_a[i]) begin
      axi_sys_cfg.master_cfg[i].enable_domain_based_addr_gen = axi_sys_enable_domain_based_addr_gen;
			`ifdef DIRECTED_TEST_FOR_DII
      axi_sys_cfg.master_cfg[i].num_outstanding_xact = 1000;
			`else
      axi_sys_cfg.master_cfg[i].num_outstanding_xact = 128;
			`endif
      axi_sys_cfg.master_cfg[i].cov_num_outstanding_xacts_range_enable                     = 1;
      axi_sys_cfg.master_cfg[i].cov_bins_num_outstanding_xacts = 'd10; 
      axi_sys_cfg.master_cfg[i].cov_bins_dvm_tlbi_num_outstanding_xacts  = addrMgrConst::num_outstanding_xacts[i];
      axi_sys_cfg.master_cfg[i].tagged_address_space_attributes_enable = 1;
      if(axi_sys_cfg.master_cfg[i].ace_version == svt_axi_port_configuration::ACE_VERSION_2_0)begin
      axi_sys_cfg.master_cfg[i].enable_mpam = svt_axi_port_configuration::MPAM_9_1;
      end
      if (addrMgrConst::io_subsys_nativeif_a[i] == "ACELITE-E") begin 
        axi_sys_cfg.master_cfg[i].atomic_transactions_enable = addrMgrConst::io_subsys_atomic_enable_a[i];
        axi_sys_cfg.master_cfg[i].use_separate_rd_wr_chan_id_width = 0;
        axi_sys_cfg.master_cfg[i].id_width = addrMgrConst::AXID_WIDTH;
      end
      if ($test$plusargs("en_excl_txn")) begin 
        axi_sys_cfg.master_cfg[i].exclusive_access_enable  = 1;
        axi_sys_cfg.master_cfg[i].max_num_exclusive_access = 0;
        axi_sys_cfg.master_cfg[i].exclusive_monitor_enable = 0;
        
      end
    axi_sys_cfg.master_cfg[i].state_coverage_enable                  = axi_snps_master_fcov_en;
    axi_sys_cfg.master_cfg[i].transaction_coverage_enable            = axi_snps_master_fcov_en;
    axi_sys_cfg.master_cfg[i].protocol_checks_coverage_enable        = axi_snps_master_fcov_en;
    axi_sys_cfg.master_cfg[i].protocol_check_stats_enable           = axi_snps_master_fcov_en;
    axi_sys_cfg.master_cfg[i].toggle_coverage_enable                 = axi_snps_master_fcov_en;
    axi_sys_cfg.master_cfg[i].valid_ready_dependency_coverage_enable = axi_snps_master_fcov_en;
    end
    `endif

`ifdef USE_VIP_SNPS_AXI_SLAVES

<%
  var pidx = 0;
  var axiaiu_idx = 0;
  for(pidx = 0; pidx < obj.nDMIs; pidx++) { 
    if(((obj.DmiInfo[pidx].fnNativeInterface == 'AXI4')||(obj.DmiInfo[pidx].fnNativeInterface == 'ACE')||(obj.DmiInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.DmiInfo[pidx].fnNativeInterface == 'ACELITE-E')) && obj.DmiInfo[pidx].interfaces.axiInt.direction == 'master' && obj.testBench == "fsys") {
      if(obj.DmiInfo[pidx].fnNativeInterface == 'AXI4') {%>
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::AXI4;<%}%>
<%if(obj.DmiInfo[pidx].fnNativeInterface == 'ACE') {%>
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::AXI_ACE;<%}%>
<%if(obj.DmiInfo[pidx].fnNativeInterface == 'ACE-LITE') {%>
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::ACE_LITE;<%}%>
<%if(obj.DmiInfo[pidx].fnNativeInterface == 'ACELITE-E') {%>
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::ACE_LITE;//need to check if ACE_LITE_E is there in svt_axi_port_configuration<%}%>
 if($test$plusargs("SYNPS_AXI_SLV_DMI_RANDMIZE_REORDERING")) begin
     if(!$value$plusargs("val_dmi_read_data_reordering_depth=%0d",val_dmi_read_data_reordering_depth)) 
         val_dmi_read_data_reordering_depth = $urandom_range(`SVT_AXI_MAX_READ_DATA_REORDERING_DEPTH,2);
     if(!$value$plusargs("val_dmi_write_resp_reordering_depth=%0d",val_dmi_write_resp_reordering_depth)) 
         val_dmi_write_resp_reordering_depth = $urandom_range(`SVT_AXI_MAX_WRITE_RESP_REORDERING_DEPTH,2);
     axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].reordering_algorithm = svt_axi_port_configuration::RANDOM;
     axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_reordering_depth = val_dmi_read_data_reordering_depth;
     axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_reordering_depth = val_dmi_write_resp_reordering_depth;
 end
 if($test$plusargs("excl_txn_en")) begin	
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].exclusive_access_enable                = 1;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].max_num_exclusive_access                = 0;
 end
 if($test$plusargs("en_exclusive_txn")) begin	
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].exclusive_access_enable                = 1;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].max_num_exclusive_access                = 0;
 end

    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].is_active                    = 1;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].addr_width                   = <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wAddr%>;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].data_width                   = <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wData%>;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].snoop_data_width             = 1024;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].cache_line_size              = <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wData%>;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].cache_stashing_enable          = 0;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].barrier_enable                 = 0;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].dvm_enable                     = 0;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_awready                = $urandom();
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_wready                 = $urandom(); 
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_arready                = $urandom();
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].tagged_address_space_attributes_enable            = 1;
<%if(obj.testBench == "fsys") { %>
        if($test$plusargs("def_ready_zero_val_at_target_native_if")) begin
<%} else {%>
        if($test$plusargs("long_delay_en")) begin
<%}%>
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_awready                = 0;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_wready                 = 0; 
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_arready                = 0;
    end else if($test$plusargs("def_ready_one_val_at_target_native_if")) begin
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_awready                = 1;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_wready                 = 1; 
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_arready                = 1;
    end


    randcase
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL ;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_HIGH_VAL;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_PREV_VAL;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_X_VAL   ;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_Z_VAL   ;
    3:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_RAND_VAL;
    endcase
    randcase
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL ;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_HIGH_VAL;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_PREV_VAL;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_X_VAL   ;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_Z_VAL   ;
    3:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_RAND_VAL;
    endcase

    if($value$plusargs("SYNPS_AXI_SLV_ZERO_DELAY_EN=%0b",axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].zero_delay_enable)) begin
      `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration - Setting zero_delay_enable %0d",axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].zero_delay_enable),UVM_NONE)
    end
    else begin
      axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].zero_delay_enable              = 0;
    end

    //drive user signals
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].aruser_enable                = <%=(obj.DmiInfo[pidx].interfaces.axiInt.params.wArUser>0)?1:0%>;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].awuser_enable                = <%=(obj.DmiInfo[pidx].interfaces.axiInt.params.wAwUser>0)?1:0%>;
    if((axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].aruser_enable==1) || (axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].awuser_enable==1)) begin
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].addr_user_width              = <%=(obj.DmiInfo[pidx].interfaces.axiInt.params.wAwUser>obj.DmiInfo[pidx].interfaces.axiInt.params.wArUser)?obj.DmiInfo[pidx].interfaces.axiInt.params.wAwUser:obj.DmiInfo[pidx].interfaces.axiInt.params.wArUser%>;
    end
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].ruser_enable                 = <%=(obj.DmiInfo[pidx].interfaces.axiInt.params.wRUser>0)?1:0%>;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].wuser_enable                 = <%=(obj.DmiInfo[pidx].interfaces.axiInt.params.wWUser>0)?1:0%>;
    if((axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].ruser_enable==1) || (axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].wuser_enable==1)) begin
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].data_user_width              = <%=(obj.DmiInfo[pidx].interfaces.axiInt.params.wRUser>obj.DmiInfo[pidx].interfaces.axiInt.params.wWUser)?obj.DmiInfo[pidx].interfaces.axiInt.params.wRUser:obj.DmiInfo[pidx].interfaces.axiInt.params.wWUser%>;
    end
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].buser_enable                 = <%=(obj.DmiInfo[pidx].interfaces.axiInt.params.wBUser>0)?1:0%>;
    if(axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].buser_enable==1) begin
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].resp_user_width              = <%=(obj.DmiInfo[pidx].interfaces.axiInt.params.wBUser>0)?obj.DmiInfo[pidx].interfaces.axiInt.params.wBUser:0%>;
    end
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].awqos_enable                 = <%=(obj.DmiInfo[pidx].interfaces.axiInt.params.wQos>0)?1:0%>;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].arqos_enable                 = <%=(obj.DmiInfo[pidx].interfaces.axiInt.params.wQos>0)?1:0%>;

    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].num_cache_lines              = 256;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].dvm_enable                   = 0;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].connect_to_axi_system_monitor = 0;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].port_interleaving_enable = port_interleaving_enable.pop_front;
    if(axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].port_interleaving_enable == 1) begin
      axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].port_interleaving_group_id = port_interleaving_group_id.pop_front;
      axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].port_interleaving_size = port_interleaving_size.pop_front;
      axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].port_interleaving_index = port_interleaving_index.pop_front;
    end
    if(dont_use_separate_rd_wr_chan_id_width) begin
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].use_separate_rd_wr_chan_id_width = 0;
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].id_width = <%=((obj.DmiInfo[pidx].interfaces.axiInt.params.wAwId<obj.DmiInfo[pidx].interfaces.axiInt.params.wArId)?obj.DmiInfo[pidx].interfaces.axiInt.params.wArId:obj.DmiInfo[pidx].interfaces.axiInt.params.wAwId)%>;
    end else begin
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].use_separate_rd_wr_chan_id_width = 1;
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_chan_id_width          = <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wAwId%>;
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_chan_id_width           = <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wArId%>;
    end
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].enable_xml_gen               = 1;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].transaction_coverage_enable  = axi_snps_slave_fcov_en;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].aruser_enable                = 1;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].awuser_enable                = 1;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].ruser_enable                 = 0;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].wuser_enable                 = 1;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].buser_enable                 = 1;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].writeevict_enable            = 1;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].awunique_enable              = 1;
    //check missing items
    //this.master_cfg[0].speculative_read_enable      = 1;

<%axiaiu_idx++;}}%>

<%
  var pidx = 0;
  for(pidx = 0; pidx < obj.nDIIs; pidx++) { 
    if(((obj.DiiInfo[pidx].fnNativeInterface == 'AXI4')||(obj.DiiInfo[pidx].fnNativeInterface == 'ACE')||(obj.DiiInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.DiiInfo[pidx].fnNativeInterface == 'ACELITE-E')) && obj.DiiInfo[pidx].interfaces.axiInt.direction == 'master' && obj.testBench == "fsys" && obj.DiiInfo[pidx].configuration == 0) {
      if(obj.DiiInfo[pidx].fnNativeInterface == 'AXI4') {%>
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::AXI4;<%}%>
<%if(obj.DiiInfo[pidx].fnNativeInterface == 'ACE') {%>
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::AXI_ACE;<%}%>
<%if(obj.DiiInfo[pidx].fnNativeInterface == 'ACE-LITE') {%>
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::ACE_LITE;<%}%>
<%if(obj.DiiInfo[pidx].fnNativeInterface == 'ACELITE-E') {%>
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].axi_interface_type           = svt_axi_port_configuration::ACE_LITE;//need to check if ACE_LITE_E is there in svt_axi_port_configuration<%}%>
    //if($test$plusargs("SYNPS_AXI_SLV_DII_RANDMIZE_REORDERING") || (($urandom_range(20,10)%9)==0)) begin
    if($test$plusargs("SYNPS_AXI_SLV_DII_RANDMIZE_REORDERING")) begin
        if(!$value$plusargs("val_dii_read_data_reordering_depth=%0d",val_dii_read_data_reordering_depth)) 
            val_dii_read_data_reordering_depth = $urandom_range(`SVT_AXI_MAX_READ_DATA_REORDERING_DEPTH,2);
        if(!$value$plusargs("val_dii_write_resp_reordering_depth=%0d",val_dii_write_resp_reordering_depth)) 
            val_dii_write_resp_reordering_depth = $urandom_range(`SVT_AXI_MAX_WRITE_RESP_REORDERING_DEPTH,2);
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].reordering_algorithm = svt_axi_port_configuration::RANDOM;
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_reordering_depth = val_dii_read_data_reordering_depth;
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_reordering_depth = val_dii_write_resp_reordering_depth;
    end

 if($test$plusargs("excl_txn_en")) begin	
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].exclusive_access_enable                = 1;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].max_num_exclusive_access                = 0;
end
 if($test$plusargs("en_exclusive_txn")) begin	
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].exclusive_access_enable                = 1;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].max_num_exclusive_access                = 0;
end

    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].is_active                    = 1;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].addr_width                   = <%=obj.DiiInfo[pidx].interfaces.axiInt.params.wAddr%>;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].data_width                   = <%=obj.DiiInfo[pidx].interfaces.axiInt.params.wData%>;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].snoop_data_width             = 1024;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].cache_line_size              = <%=obj.DiiInfo[pidx].interfaces.axiInt.params.wData%>;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].cache_stashing_enable          = 0;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].barrier_enable                 = 0;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].dvm_enable                     = 0;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_awready                = $urandom();
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_wready                 = $urandom(); 
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_arready                = $urandom();
		axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].tagged_address_space_attributes_enable            = 1;

<%if(obj.testBench == "fsys") { %>
        if($test$plusargs("def_ready_zero_val_at_target_native_if")) begin
<%} else {%>
        if($test$plusargs("long_delay_en")) begin
<%}%>
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_awready                = 0;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_wready                 = 0; 
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_arready                = 0;
    end else if($test$plusargs("def_ready_one_val_at_target_native_if")) begin
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_awready                = 1;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_wready                 = 1; 
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].default_arready                = 1;
    end

    randcase
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL ;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_HIGH_VAL;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_PREV_VAL;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_X_VAL   ;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_Z_VAL   ;
    3:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_resp_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_RAND_VAL;
    endcase
    randcase
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_LOW_VAL ;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_HIGH_VAL;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_PREV_VAL;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_X_VAL   ;
    1:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_Z_VAL   ;
    3:axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_data_chan_idle_val = svt_axi_port_configuration::INACTIVE_CHAN_RAND_VAL;
    endcase

    if($value$plusargs("SYNPS_AXI_SLV_ZERO_DELAY_EN=%0b",axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].zero_delay_enable)) begin
      `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration - Setting zero_delay_enable %0d",axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].zero_delay_enable),UVM_NONE)
    end
    else begin
      axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].zero_delay_enable              = 0;
    end

    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].aruser_enable                = <%=(obj.DiiInfo[pidx].interfaces.axiInt.params.wArUser>0)?1:0%>;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].awuser_enable                = <%=(obj.DiiInfo[pidx].interfaces.axiInt.params.wAwUser>0)?1:0%>;
    if((axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].aruser_enable==1) || (axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].awuser_enable==1)) begin
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].addr_user_width              = <%=(obj.DiiInfo[pidx].interfaces.axiInt.params.wAwUser>obj.DiiInfo[pidx].interfaces.axiInt.params.wArUser)?obj.DiiInfo[pidx].interfaces.axiInt.params.wAwUser:obj.DiiInfo[pidx].interfaces.axiInt.params.wArUser%>;
    end
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].ruser_enable                 = <%=(obj.DiiInfo[pidx].interfaces.axiInt.params.wRUser>0)?1:0%>;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].wuser_enable                 = <%=(obj.DiiInfo[pidx].interfaces.axiInt.params.wWUser>0)?1:0%>;
    if((axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].ruser_enable==1) || (axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].wuser_enable==1)) begin
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].data_user_width              = <%=(obj.DiiInfo[pidx].interfaces.axiInt.params.wRUser>obj.DiiInfo[pidx].interfaces.axiInt.params.wWUser)?obj.DiiInfo[pidx].interfaces.axiInt.params.wRUser:obj.DiiInfo[pidx].interfaces.axiInt.params.wWUser%>;
    end
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].buser_enable                 = <%=(obj.DiiInfo[pidx].interfaces.axiInt.params.wBUser>0)?1:0%>;
    if(axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].buser_enable==1) begin
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].resp_user_width              = <%=(obj.DiiInfo[pidx].interfaces.axiInt.params.wBUser>0)?obj.DiiInfo[pidx].interfaces.axiInt.params.wBUser:0%>;
    end
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].awqos_enable                 = <%=(obj.DiiInfo[pidx].interfaces.axiInt.params.wQos>0)?1:0%>;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].arqos_enable                 = <%=(obj.DiiInfo[pidx].interfaces.axiInt.params.wQos>0)?1:0%>;

    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].connect_to_axi_system_monitor = 0;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].port_interleaving_enable = port_interleaving_enable.pop_front;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].port_interleaving_enable = 0;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].num_cache_lines              = 256;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].dvm_enable                   = 0;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].enable_xml_gen               = 1;
    axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].transaction_coverage_enable  = axi_snps_slave_fcov_en;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].aruser_enable                = 1;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].awuser_enable                = 1;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].ruser_enable                 = 0;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].wuser_enable                 = 1;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].buser_enable                 = 1;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].writeevict_enable            = 1;
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].awunique_enable              = 1;
    if(dont_use_separate_rd_wr_chan_id_width) begin
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].use_separate_rd_wr_chan_id_width = 0;
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].id_width = <%=((obj.DiiInfo[pidx].interfaces.axiInt.params.wAwId<obj.DiiInfo[pidx].interfaces.axiInt.params.wArId)?obj.DiiInfo[pidx].interfaces.axiInt.params.wArId:obj.DiiInfo[pidx].interfaces.axiInt.params.wAwId)%>;
    end else begin
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].use_separate_rd_wr_chan_id_width = 1;
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].write_chan_id_width          = <%=obj.DiiInfo[pidx].interfaces.axiInt.params.wAwId%>;
        axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].read_chan_id_width           = <%=obj.DiiInfo[pidx].interfaces.axiInt.params.wArId%>;
    end
    //axi_sys_cfg.slave_cfg[<%=axiaiu_idx%>].id_width = <%=obj.DiiInfo[pidx].interfaces.axiInt.params.wAwId%>;

<%axiaiu_idx++;}}%>
   <% if(axiaiu_idx>1 && obj.testBench == "fsys") { %>
   if(axi_sys_cfg.slave_cfg.size()>0) begin
     foreach(axi_sys_cfg.slave_cfg[i]) begin
         `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: axi_sys_cfg.slave_cfg[%0d]",i),UVM_NONE)
         axi_sys_cfg.slave_cfg[i].print();
     end
   end
   <% } %>
`endif // `ifdef USE_VIP_SNPS_AXI_SLAVES

//`ifdef IO_SUBSYS_SNPS
      if(axi_sys_enable_domain_based_addr_gen) begin
            io_subsys_master_ports_array = new[`NUM_ACE_MASTERS];
            for(int temp_idx=0; temp_idx<io_subsys_master_ports_array.size();temp_idx=temp_idx+1) begin
                io_subsys_master_ports_array[temp_idx] = temp_idx;
                if((axi_sys_cfg.master_cfg[temp_idx].axi_interface_type==svt_axi_port_configuration::ACE_LITE) 
                || (axi_sys_cfg.master_cfg[temp_idx].axi_interface_type==svt_axi_port_configuration::AXI_ACE)
                || (axi_sys_cfg.master_cfg[temp_idx].axi_interface_type==svt_axi_port_configuration::AXI4)) begin
                    io_subsys_innershareable_master_ports_array = new[io_subsys_innershareable_master_ports_array.size()+1] (io_subsys_innershareable_master_ports_array);
                    io_subsys_outershareable_master_ports_array = new[io_subsys_outershareable_master_ports_array.size()+1] (io_subsys_outershareable_master_ports_array);
                    io_subsys_innershareable_master_ports_array[io_subsys_innershareable_master_ports_array.size() - 1] = temp_idx;
                    if(temp_idx == (io_subsys_master_ports_array.size()-1))
                    io_subsys_outershareable_master_ports_array[io_subsys_outershareable_master_ports_array.size() - 1] = 0;
                    else      
                    io_subsys_outershareable_master_ports_array[io_subsys_outershareable_master_ports_array.size() - 1] = temp_idx+1;
                end
            end
            io_subsys_nonshareable_domain_created = new[io_subsys_innershareable_master_ports_array.size()];
            io_subsys_innershareable_domain_created = new[io_subsys_innershareable_master_ports_array.size()];
            io_subsys_outershareable_domain_created = new[io_subsys_innershareable_master_ports_array.size()];
            
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::io_subsys_master_ports_array.size:%0d io_subsys_innershareable_master_ports_array.size:%0d io_subsys_innershareable_master_ports_array:%0p io_subsys_nonshareable_domain_created.size:%0d", io_subsys_master_ports_array.size(), io_subsys_innershareable_master_ports_array.size(), io_subsys_innershareable_master_ports_array, io_subsys_nonshareable_domain_created.size()),UVM_NONE)

            foreach (csrq[i]) begin
                if((csrq[i].unit == addrMgrConst::DII) || (csrq[i].unit == addrMgrConst::DMI && csrq[i].nc==1)) begin
                    start_addr = {csrq[i].upp_addr, csrq[i].low_addr} << 12;
                    foreach(io_subsys_nonshareable_domain_created[x]) begin
                        io_subsys_nonshareable_domain_id =x;
                        if(io_subsys_nonshareable_domain_created[x]==0) begin
                           axi_sys_cfg.create_new_domain(x, svt_axi_system_domain_item::NONSHAREABLE, {io_subsys_innershareable_master_ports_array[x]});
                           
                           io_subsys_nonshareable_domain_created[x] = 1;
                           `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: Creating NONSHAREABLE domain with domain_id %0d",io_subsys_nonshareable_domain_id+x),UVM_LOW)
                        end
                        if(csrq[i].unit == addrMgrConst::DMI && csrq[i].nc==1)
                            domain_size = (1 << (csrq[i].size+12)+$clog2(addrMgrConst::intrlvgrp_vector[addrMgrConst::picked_dmi_igs][csrq[i].mig_nunitid]));
                        else
                            domain_size = (1 << (csrq[i].size+12));
                        end_addr = start_addr + (domain_size/io_subsys_innershareable_master_ports_array.size()) - 1;
                        axi_sys_cfg.set_addr_for_domain(io_subsys_nonshareable_domain_id, start_addr, end_addr);
                        `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: domain_id %0d NONSHAREABLE(%0s) start_addr :0x%0h end_addr:0x%0h for masters:{%0p}",io_subsys_nonshareable_domain_id,(csrq[i].unit == addrMgrConst::DMI)?"DMI":"DII",start_addr,end_addr, io_subsys_innershareable_master_ports_array[x]),UVM_LOW)
                        start_addr = end_addr + 1;
                    end
                end
                else if(csrq[i].unit == addrMgrConst::DMI && csrq[i].nc==0) begin
                    start_addr = {csrq[i].upp_addr, csrq[i].low_addr} << 12;
                       if(!set_domain )begin 
                          if(!io_subsys_innershareable_domain_create)begin 
                              io_subsys_innershareable_domain_id = io_subsys_nonshareable_domain_created.size()+1; 
                              axi_sys_cfg.create_new_domain(io_subsys_innershareable_domain_id, svt_axi_system_domain_item::INNERSHAREABLE, {io_subsys_innershareable_master_ports_array});
                              io_subsys_innershareable_domain_create +=1;
                          end
                          set_domain +=1; 
                          domain_size = (1 << (csrq[i].size+12)+$clog2(addrMgrConst::intrlvgrp_vector[addrMgrConst::picked_dmi_igs][csrq[i].mig_nunitid]));
                          end_addr = start_addr + domain_size - 1; 
                          `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: domain_id %0d INNERSHAREABLE(%0s) start_addr 'h%h end_addr 'h%h for masters:{%0p}",io_subsys_innershareable_domain_id,(csrq[i].unit == addrMgrConst::DMI)?"DMI":"DII",start_addr,end_addr, io_subsys_innershareable_master_ports_array),UVM_LOW)
                          axi_sys_cfg.set_addr_for_domain(io_subsys_innershareable_domain_id, start_addr, end_addr); 
                       end
                       else if(set_domain == 1)begin
                            set_domain += 1;
                            if(!io_subsys_outershareable_domain_create)begin
                            io_subsys_outershareable_domain_id =io_subsys_innershareable_domain_id+1;
                            axi_sys_cfg.create_new_domain(io_subsys_outershareable_domain_id, svt_axi_system_domain_item::OUTERSHAREABLE, {io_subsys_outershareable_master_ports_array});
                            io_subsys_outershareable_domain_create +=1;
                            end
                            domain_size = (1 << (csrq[i].size+12)+$clog2(addrMgrConst::intrlvgrp_vector[addrMgrConst::picked_dmi_igs][csrq[i].mig_nunitid]));
                            end_addr = start_addr + domain_size - 1;
                            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: domain_id %0d OUTERSHAREABLE(%0s) start_addr 'h%h end_addr 'h%h for masters:{%0p}",io_subsys_outershareable_domain_id,(csrq[i].unit == addrMgrConst::DMI)?"DMI":"DII",start_addr,end_addr, io_subsys_outershareable_master_ports_array),UVM_LOW)
                            axi_sys_cfg.set_addr_for_domain(io_subsys_outershareable_domain_id,start_addr, end_addr);
                       end
                 end
 
               start_addr = {csrq[i].upp_addr, csrq[i].low_addr} << 12;
                
//                if(csrq[i].unit == addrMgrConst::DII) begin
//                    domain_size = (1 << (csrq[i].size+12));
//                    end_addr = start_addr + domain_size - 1;
//                    addrMgrConst::dii_memory_domain_start_addr.push_back(start_addr);
//                    addrMgrConst::dii_memory_domain_end_addr.push_back(end_addr);
//                    svt_axi_item_helper::all_dmi_dii_addr_range_start_addr.push_back(start_addr);
//                    svt_axi_item_helper::all_dmi_dii_addr_range_end_addr.push_back(end_addr);
//                end
//                else if(csrq[i].unit == addrMgrConst::DMI) begin
//                    domain_size = (1 << (csrq[i].size+12)+$clog2(addrMgrConst::intrlvgrp_vector[addrMgrConst::picked_dmi_igs][csrq[i].mig_nunitid]));
//                    end_addr = start_addr + domain_size - 1;
//                    addrMgrConst::dmi_memory_domain_start_addr.push_back(start_addr);
//                    addrMgrConst::dmi_memory_domain_end_addr.push_back(end_addr);
//                    svt_axi_item_helper::all_dmi_dii_addr_range_start_addr.push_back(start_addr);
//                    svt_axi_item_helper::all_dmi_dii_addr_range_end_addr.push_back(end_addr);
//                    
//                    if (csrq[i].nc == 0) begin 
//                      addrMgrConst::dmi_memory_coh_domain_start_addr.push_back(start_addr);
//                      addrMgrConst::dmi_memory_coh_domain_end_addr.push_back(end_addr);
//                    end else begin 
//                      addrMgrConst::dmi_memory_noncoh_domain_start_addr.push_back(start_addr);
//                      addrMgrConst::dmi_memory_noncoh_domain_end_addr.push_back(end_addr);
//                    end
//                end
            end
    end // if(k_ace_sys_enable_domain_based_addr_gen)            
    else begin
            foreach (csrq[i]) begin
                start_addr = {csrq[i].upp_addr, csrq[i].low_addr} << 12;
                if(csrq[i].unit == addrMgrConst::DII) begin
                    domain_size = (1 << (csrq[i].size+12));
                    end_addr = start_addr + domain_size - 1;
                    //addrMgrConst::dii_memory_domain_start_addr.push_back(start_addr);
                    //addrMgrConst::dii_memory_domain_end_addr.push_back(end_addr);
                    svt_axi_item_helper::all_dmi_dii_addr_range_start_addr.push_back(start_addr);
                    svt_axi_item_helper::all_dmi_dii_addr_range_end_addr.push_back(end_addr);
                    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: dii[%0d] start_addr 'h%h end_addr 'h%h",addrMgrConst::dii_memory_domain_start_addr.size()-1,start_addr,end_addr),UVM_NONE)
                end
                if(csrq[i].unit == addrMgrConst::DMI) begin
                    //domain_size = (1 << (csrq[i].size+12)+$clog2(addrMgrConst::nmig));
                    domain_size = (1 << (csrq[i].size+12)+$clog2(addrMgrConst::intrlvgrp_vector[addrMgrConst::picked_dmi_igs][csrq[i].mig_nunitid]));
                    end_addr = start_addr + domain_size - 1;
                    //addrMgrConst::dmi_memory_domain_start_addr.push_back(start_addr);
                    //addrMgrConst::dmi_memory_domain_end_addr.push_back(end_addr);
                    svt_axi_item_helper::all_dmi_dii_addr_range_start_addr.push_back(start_addr);
                    svt_axi_item_helper::all_dmi_dii_addr_range_end_addr.push_back(end_addr);
                    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: dmi[%0d] start_addr 'h%h end_addr 'h%h",addrMgrConst::dmi_memory_domain_start_addr.size()-1,start_addr,end_addr),UVM_NONE)
                end
            end
    end

    foreach (addrMgrConst::dmi_memory_coh_domain_start_addr[i]) begin 
      //`uvm_info(get_name(),$psprintf("coh_address_region i:%0d start_addr:0x%0h end_addr:0x%0h",i, addrMgrConst::dmi_memory_coh_domain_start_addr[i], addrMgrConst::dmi_memory_coh_domain_end_addr[i]), UVM_LOW)
    end 

    if (axi_sys_cfg.master_cfg.size() != `NUM_IOAIU_SVT_MASTERS) begin 
        `uvm_error(get_name(),$psprintf("axi_sys_cfg.master_cfg.size:%0d NUM_IOAIU_SVT_MASTERS:%0d should match", axi_sys_cfg.master_cfg.size(), `NUM_IOAIU_SVT_MASTERS))
    end

   `ifdef IO_UNITS_CNT_NON_ZERO 
   if(axi_sys_cfg.master_cfg.size()>0) begin
     foreach(axi_sys_cfg.master_cfg[i]) begin
         axi_sys_cfg.master_cfg[i].set_port_name(addrMgrConst::io_subsys_instname_a[i]);
         `uvm_info(get_name(),$psprintf("POST_DOMAIN_BASED_ADDR_GEN::cust_svt_amba_system_configuration:: axi_sys_cfg.master_cfg[%0d] with port_name:%0s",i, addrMgrConst::io_subsys_instname_a[i]),UVM_NONE)
         axi_sys_cfg.master_cfg[i].print();
     end
   end
 `endif
endfunction //set_axi_system_configuration
<% } %>

// =============================================================================
<% if (obj.testBench == "fsys" ||  obj.testBench == "io_aiu") { %>
<%if(obj.DebugApbInfo.length > 0){%>

function void cust_svt_amba_system_configuration::set_apb_system_configuration(svt_apb_system_configuration apb_sys_cfg);
    bit apb_snps_fcov_en;

    if(!$value$plusargs("apb_snps_fcov_en=%0b", apb_snps_fcov_en)) begin
        apb_snps_fcov_en=0;
    end

    apb_sys_cfg.create_sub_cfgs(1); 
    //apb_sys_cfg.slave_addr_allocation_enable = 1;
    apb_sys_cfg.wait_for_reset_enable = 1;
    apb_sys_cfg.disable_x_check_of_presetn = 0;
    apb_sys_cfg.disable_x_check_of_pclk = 0;
    `ifndef VCS
        $cast(apb_sys_cfg.paddr_width, <%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wAddr%>);
        $cast(apb_sys_cfg.pdata_width, <%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wData%>);
    `else
        apb_sys_cfg.paddr_width = <%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wAddr%>;
        apb_sys_cfg.pdata_width = <%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wData%>;
    `endif
    apb_sys_cfg.apb3_enable = 0;
    apb_sys_cfg.apb4_enable = 1;
    apb_sys_cfg.num_slaves = 1;
    //apb_sys_cfg.apb5_enable = 0;
      /** Master setup */
    apb_sys_cfg.is_active = 1;
    apb_sys_cfg.enable_xml_gen = 1;
    apb_sys_cfg.slave_cfg[0].enable_xml_gen = 1;
    apb_sys_cfg.slave_cfg[0].is_active = 0;

    /** Enable UVM APB Ral Adapter */
    apb_sys_cfg.uvm_reg_enable = 1;

    apb_sys_cfg.transaction_coverage_enable = apb_snps_fcov_en;
    apb_sys_cfg.slave_cfg[0].transaction_coverage_enable = apb_snps_fcov_en;
    apb_sys_cfg.protocol_checks_coverage_enable = apb_snps_fcov_en;
    apb_sys_cfg.slave_cfg[0].protocol_checks_coverage_enable = apb_snps_fcov_en;

endfunction:set_apb_system_configuration

<% } %>
<% } %>

//=============================================================================
<% if (obj.testBench == "fsys") { %>
function void cust_svt_amba_system_configuration::configure_system_address_map(string protocol_type, svt_chi_system_configuration chi_sys_cfg, svt_axi_system_configuration axi_sys_cfg);
<%
  var rnArr;
  if(nRNIioaiu == 1 ) rnArr = '0';
  if(nRNIioaiu == 2 ) rnArr = '0,1';
  if(nRNIioaiu == 3 ) rnArr = '0,1,2';
  if(nRNIioaiu == 4 ) rnArr = '0,1,2,3';
  if(nRNIioaiu == 5 ) rnArr = '0,1,2,3,4';
  if(nRNIioaiu == 6 ) rnArr = '0,1,2,3,4,5';
  if(nRNIioaiu == 7 ) rnArr = '0,1,2,3,4,5,6';
  if(nRNIioaiu == 8 ) rnArr = '0,1,2,3,4,5,6,7';
  if(nRNIioaiu == 9 ) rnArr = '0,1,2,3,4,5,6,7,8';
  if(nRNIioaiu == 10) rnArr = '0,1,2,3,4,5,6,7,8,9';
  if(nRNIioaiu == 11) rnArr = '0,1,2,3,4,5,6,7,8,9,10';
  if(nRNIioaiu == 12) rnArr = '0,1,2,3,4,5,6,7,8,9,10,11';
  if(nRNIioaiu == 13) rnArr = '0,1,2,3,4,5,6,7,8,9,10,11,12';
  if(nRNIioaiu == 14) rnArr = '0,1,2,3,4,5,6,7,8,9,10,11,12,13';
  if(nRNIioaiu == 15) rnArr = '0,1,2,3,4,5,6,7,8,9,10,11,12,13,14';
%>
  //csrq = addrMgrConst::get_all_gpra();
  int nonsnoopable[],innersnoopable[],outersnoopable[],snoopable[];
  bit [63:0] start_addr;
  bit [63:0] end_addr;
  bit [63:0] domain_size;
  //44
  int master_ports[] = new [<%=ioaiuIndexNum %>];
  bit [63:0] rn_dii_start_addr[] = new[<%=numAiuRpns%>];
  bit [63:0] rn_dii_end_addr[]   = new[<%=numAiuRpns%>];
  bit [63:0] rn_dmi_start_addr[] = new[<%=numAiuRpns%>];
  bit [63:0] rn_dmi_end_addr[]   = new[<%=numAiuRpns%>];
  //48
  bit [63:0] rn_dii_low_addr[] = new[<%=numAiuRpns%>];
  bit [63:0] rn_dii_upp_addr[] = new[<%=numAiuRpns%>];
  bit [63:0] rn_dmi_low_addr[] = new[<%=numAiuRpns%>];
  bit [63:0] rn_dmi_upp_addr[] = new[<%=numAiuRpns%>];

  bit [63:0] rn_increment;
  bit set_nonsnp[] = new[<%=numAiuRpns%>];
  bit set_innsnp[] = new[<%=numAiuRpns%>];
  bit onetime_dii_creation=0;
  bit onetime_dmi_creation=0;
  //48
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] low_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] upp_addr;
  int dmi_grps[$];
  int dii_grps[$];
  int nintrlv_grps[$];
  int dmi_ig_id;
  addrMgrConst::ncore_unit_type_t nintrlv_type[$];

 bit [63:0] start_addr_noncoh;
  bit [63:0] end_addr_noncoh;
  addrMgrConst::intq noncoh_regionsq;
  ncore_memory_map m_map;

   m_addr_mgr = addr_trans_mgr::get_instance();
   m_addr_mgr.gen_memory_map();
  m_map = m_addr_mgr.get_memory_map_instance(); 
  noncoh_regionsq = m_map.get_noncoh_mem_regions();

 csrq = addrMgrConst::get_all_gpra();
 foreach (csrq[i]) begin
   `uvm_info(get_name(), $psprintf("unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d", csrq[i].unit.name(), csrq[i].mig_nunitid, csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size), UVM_NONE) 
                   end

if(protocol_type == "CHI") begin //{
<% if (obj.AiuInfo[0].fnNativeInterface == 'CHI-A') { %>
        foreach (csrq[i]) begin

          start_addr = csrq[i].low_addr << 12;
          domain_size = (1 << (csrq[i].size+12));
          end_addr = start_addr + domain_size - 1;

          rn_increment = domain_size/<%=chiaiuIndexNum%>;
          `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::1a: {0x%12h 0x%12h} domain_size=%0d rn_increment=%0d",  end_addr, start_addr, domain_size, rn_increment),UVM_NONE)
 
          if(csrq[i].unit == addrMgrConst::DII && onetime_dii_creation == 0) begin //{

           for(int k=0; k< <%=chiaiuIndexNum%>; k++) begin
             if(k==0) begin //1st
             rn_dii_start_addr[0] = start_addr;
             rn_dii_end_addr[0]   = rn_dii_start_addr[0] +  rn_increment - 1;
             `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}", protocol_type, rn_dii_end_addr[0], rn_dii_start_addr[0]),UVM_NONE)
             end else if(k== <%=chiaiuIndexNum-1%>) begin //last
             rn_dii_start_addr[<%=chiaiuIndexNum-1%>] = rn_dii_end_addr[<%=chiaiuIndexNum-2%>] +  1;
             rn_dii_end_addr[<%=chiaiuIndexNum-1%>]   = end_addr;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dii_end_addr[<%=chiaiuIndexNum-1%>], rn_dii_start_addr[<%=chiaiuIndexNum-1%>]),UVM_NONE)
             end else begin //middle
             rn_dii_start_addr[k] = rn_dii_end_addr[k-1] + 1;
             rn_dii_end_addr[k]   = rn_dii_start_addr[k] + rn_increment - 1;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dii_end_addr[k], rn_dii_start_addr[k]),UVM_NONE)
             end
           end
            
            <%for(rn=0; rn< chiaiuIndexNum; rn++) { %>
            if(set_nonsnp[<%=rn%>] == 0) begin
              chi_sys_cfg.create_new_domain(dcount+<%=rn%>, svt_chi_system_domain_item::NONSNOOPABLE, {<%=rn%>});
              chi_sys_cfg.set_addr_for_domain(dcount+<%=rn%>, rn_dii_start_addr[<%=rn%>], rn_dii_end_addr[<%=rn%>]);
              addrMgrConst::dii_memory_domain_start_addr.push_back(rn_dii_start_addr[<%=rn%>]);
              addrMgrConst::dii_memory_domain_end_addr.push_back(rn_dii_end_addr[<%=rn%>]);
             `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s:: Creating (RN:<%=rn%>) %s NONSNOOPABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[i].unit.name(), dcount+<%=rn%>, rn_dii_end_addr[<%=rn%>], rn_dii_start_addr[<%=rn%>]),UVM_NONE)
            end
            <% } %>
            dcount = dcount+ <%=rn%> + 1;
            set_nonsnp[<%=rn%>] = 1;
            onetime_dii_creation = 1;
          end //}


          if(csrq[i].unit == addrMgrConst::DMI && onetime_dmi_creation == 0) begin //{

           for(int k=0; k< <%=chiaiuIndexNum%>; k++) begin
             if(k==0) begin //1st
             rn_dmi_start_addr[0] = start_addr;
             rn_dmi_end_addr[0]   = rn_dmi_start_addr[0] +  rn_increment - 1;
             `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}", protocol_type, rn_dmi_end_addr[0], rn_dmi_start_addr[0]),UVM_NONE)
             end else if(k== <%=chiaiuIndexNum-1%>) begin //last
             rn_dmi_start_addr[<%=chiaiuIndexNum-1%>] = rn_dmi_end_addr[<%=chiaiuIndexNum-2%>] +  1;
             rn_dmi_end_addr[<%=chiaiuIndexNum-1%>]   = end_addr;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dmi_end_addr[<%=chiaiuIndexNum-1%>], rn_dmi_start_addr[<%=chiaiuIndexNum-1%>]),UVM_NONE)
             end else begin //middle
             rn_dmi_start_addr[k] = rn_dmi_end_addr[k-1] + 1;
             rn_dmi_end_addr[k]   = rn_dmi_start_addr[k] + rn_increment - 1;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dmi_end_addr[k], rn_dmi_start_addr[k]),UVM_NONE)
             end
           end

            <%for(rn=0; rn< chiaiuIndexNum; rn++) { %>
            if(set_innsnp[<%=rn%>] == 0) begin
              chi_sys_cfg.create_new_domain(dcount+<%=rn%>, svt_chi_system_domain_item::INNERSNOOPABLE, {<%=rn%>});
              chi_sys_cfg.set_addr_for_domain(dcount+<%=rn%>, rn_dmi_start_addr[<%=rn%>], rn_dmi_end_addr[<%=rn%>]);
              addrMgrConst::dmi_memory_domain_start_addr.push_back(rn_dmi_start_addr[<%=rn%>]);
              addrMgrConst::dmi_memory_domain_end_addr.push_back(rn_dmi_end_addr[<%=rn%>]);
             `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:<%=rn%>) %s INNERSNOOPABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[i].unit.name(), dcount+<%=rn%>, rn_dmi_end_addr[<%=rn%>], rn_dmi_start_addr[<%=rn%>]),UVM_NONE)
            end
            <% } %>
            dcount = dcount + <%=rn%> + 1;
            set_innsnp[<%=rn%>] = 1;
            onetime_dmi_creation = 1;
          end //}

        end //foreach (csrq[i])

<% } else if (obj.AiuInfo[0].fnNativeInterface == 'CHI-B' || obj.AiuInfo[0].fnNativeInterface == 'CHI-E') { %>
//SCHEME2 (48)


 foreach(noncoh_regionsq[indx]) begin
        if(indx==0)m_addr_mgr.get_mem_region_bounds(noncoh_regionsq[indx], start_addr_noncoh, end_addr_noncoh);
end

    //Based on intrlvgrp_vector ...Push into dmi_grps,dii_grps
    //dmi_ig_id = $urandom_range(0, $size(addrMgrConst::intrlvgrp_vector)-1 );
  //dmi_ig_id = 1;
  dmi_ig_id = m_mem.dmi_ig_id;
  foreach (addrMgrConst::intrlvgrp_vector[dmi_ig_id][idx]) 
    dmi_grps.push_back(addrMgrConst::intrlvgrp_vector[dmi_ig_id][idx]);
  for (int i = 0; i < addrMgrConst::NUM_DIIS-1; ++i)
    dii_grps.push_back(1);

  //Based on dmi_grps,dii_grps ..Append regions into nintrlv_grps queue
  foreach (dmi_grps[i]) begin
    nintrlv_grps.push_back(dmi_grps[i]);
    nintrlv_type.push_back(addrMgrConst::DMI);
  end
  foreach (dii_grps[i]) begin
    nintrlv_grps.push_back(dii_grps[i]);
    nintrlv_type.push_back(addrMgrConst::DII);
  end
 

 `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: ADDR MGR Local dmi_ig_id=%d",  dmi_ig_id),UVM_NONE)

 foreach (nintrlv_grps[i]) begin
     csrq = addrMgrConst::get_memregions_assoc_ig(i);
     foreach (csrq[j]) begin
       low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
       upp_addr = low_addr + nintrlv_grps[i]*(1<<(csrq[j].size+12)) - 1;
       domain_size = upp_addr - low_addr +1; 

       rn_increment = domain_size/<%=chiaiuIndexNum%>;
       `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h} domain_size=%0d rn_increment=%0d",  protocol_type, upp_addr, low_addr, domain_size, rn_increment),UVM_NONE)


          if(csrq[j].unit == addrMgrConst::DII && onetime_dii_creation == 0) begin //{

           for(int k=0; k< <%=chiaiuIndexNum%>; k++) begin
             if(k==0) begin //1st
             rn_dii_low_addr[0] = low_addr;
             rn_dii_upp_addr[0]   = rn_dii_low_addr[0] +  rn_increment - 1;
             `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}", protocol_type, rn_dii_upp_addr[0], rn_dii_low_addr[0]),UVM_NONE)
             end else if(k== <%=chiaiuIndexNum-1%>) begin //last
             rn_dii_low_addr[<%=chiaiuIndexNum-1%>] = rn_dii_upp_addr[<%=chiaiuIndexNum-2%>] +  1;
             rn_dii_upp_addr[<%=chiaiuIndexNum-1%>]   = upp_addr;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dii_upp_addr[<%=chiaiuIndexNum-1%>], rn_dii_low_addr[<%=chiaiuIndexNum-1%>]),UVM_NONE)
             end else begin //middle
             rn_dii_low_addr[k] = rn_dii_upp_addr[k-1] + 1;
             rn_dii_upp_addr[k]   = rn_dii_low_addr[k] + rn_increment - 1;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dii_upp_addr[k], rn_dii_low_addr[k]),UVM_NONE)
             end
           end
            
            <%for(rn=0; rn< chiaiuIndexNum; rn++) { %>
            if(set_nonsnp[<%=rn%>] == 0) begin
              chi_sys_cfg.create_new_domain(dcount+<%=rn%>, svt_chi_system_domain_item::NONSNOOPABLE, {<%=rn%>});
              chi_sys_cfg.set_addr_for_domain(dcount+<%=rn%>, rn_dii_low_addr[<%=rn%>], rn_dii_upp_addr[<%=rn%>]);
              addrMgrConst::dii_memory_domain_start_addr.push_back(rn_dii_low_addr[<%=rn%>]);
              addrMgrConst::dii_memory_domain_end_addr.push_back(rn_dii_upp_addr[<%=rn%>]);
              `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:<%=rn%>) %s NONSNOOPABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[j].unit.name(), dcount+<%=rn%>, rn_dii_upp_addr[<%=rn%>], rn_dii_low_addr[<%=rn%>]),UVM_NONE)
            end
            <% } %>
            dcount = dcount+ <%=rn%> + 1;
            set_nonsnp[<%=rn%>] = 1;
            onetime_dii_creation = 1;
          end //}


          if(csrq[j].unit == addrMgrConst::DMI && onetime_dmi_creation == 0) begin //{

           for(int k=0; k< <%=chiaiuIndexNum%>; k++) begin
             if(k==0) begin //1st
             rn_dmi_low_addr[0] = low_addr;
             rn_dmi_upp_addr[0]   = rn_dmi_low_addr[0] +  rn_increment - 1;
             `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}", protocol_type, rn_dmi_upp_addr[0], rn_dmi_low_addr[0]),UVM_NONE)
             end else if(k== <%=chiaiuIndexNum-1%>) begin //last
             rn_dmi_low_addr[<%=chiaiuIndexNum-1%>] = rn_dmi_upp_addr[<%=chiaiuIndexNum-2%>] +  1;
             rn_dmi_upp_addr[<%=chiaiuIndexNum-1%>]   = upp_addr;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dmi_upp_addr[<%=chiaiuIndexNum-1%>], rn_dmi_low_addr[<%=chiaiuIndexNum-1%>]),UVM_NONE)
             end else begin //middle
             rn_dmi_low_addr[k] = rn_dmi_upp_addr[k-1] + 1;
             rn_dmi_upp_addr[k]   = rn_dmi_low_addr[k] + rn_increment - 1;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dmi_upp_addr[k], rn_dmi_low_addr[k]),UVM_NONE)
             end
           end

            <%for(rn=0; rn< chiaiuIndexNum; rn++) { %>
            if(set_innsnp[<%=rn%>] == 0) begin
              chi_sys_cfg.create_new_domain(dcount+<%=rn%>, svt_chi_system_domain_item::INNERSNOOPABLE, {<%=rn%>});
              chi_sys_cfg.set_addr_for_domain(dcount+<%=rn%>, rn_dmi_low_addr[<%=rn%>], rn_dmi_upp_addr[<%=rn%>]);
              addrMgrConst::dmi_memory_domain_start_addr.push_back(rn_dmi_low_addr[<%=rn%>]);
              addrMgrConst::dmi_memory_domain_end_addr.push_back(rn_dmi_upp_addr[<%=rn%>]);
              `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:<%=rn%>) %s INNERSNOOPABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[j].unit.name(), dcount+<%=rn%>, rn_dmi_upp_addr[<%=rn%>], rn_dmi_low_addr[<%=rn%>]),UVM_NONE)
            end
            <% } %>
            dcount = dcount + <%=rn%> + 1;
            set_innsnp[<%=rn%>] = 1;
            onetime_dmi_creation = 1;
          end //}

  end // foreach (csrq[j])
 end // foreach (nintrlv_grps[i])
<% } %>
end //} protocol=="CHI"


if(protocol_type == "ACE") begin //{
<% if (obj.AiuInfo[0].fnNativeInterface == 'CHI-A' || obj.AiuInfo[0].fnNativeInterface == 'ACE' || obj.AiuInfo[0].fnNativeInterface == 'AXI4') { %>
//BLKLEVEL SCHEME1 (44)

	foreach(master_ports[i])begin
          master_ports[i]=i;
        end

 foreach(noncoh_regionsq[indx]) begin
        if(indx==0)m_addr_mgr.get_mem_region_bounds(noncoh_regionsq[indx], start_addr_noncoh, end_addr_noncoh);
  end
        for(int i=0; i<csrq.size(); i++) begin

          start_addr = (csrq[i].low_addr<<12) | (csrq[i].upp_addr << 44);
       if(start_addr==start_addr_noncoh)begin
         i++;
          start_addr = (csrq[i].low_addr<<12) | (csrq[i].upp_addr << 44);
       end
          domain_size = (1 << (csrq[i].size+12));
          end_addr = start_addr + domain_size - 1;

          rn_increment = domain_size/<%=ioaiuIndexNum%>;
          `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::1a: {0x%12h 0x%12h} domain_size=%0d rn_increment=%0d",  end_addr, start_addr, domain_size, rn_increment),UVM_NONE)
 
          if(csrq[i].unit == addrMgrConst::DII && onetime_dii_creation == 0) begin //{

           for(int k=0; k< <%=ioaiuIndexNum%>; k++) begin
             if(k==0) begin //1st
             rn_dii_start_addr[0] = start_addr;
             rn_dii_end_addr[0]   = rn_dii_start_addr[0] +  rn_increment - 1;
             `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}", protocol_type, rn_dii_end_addr[0], rn_dii_start_addr[0]),UVM_NONE)
             end else if(k== <%=ioaiuIndexNum-1%>) begin //last
             rn_dii_start_addr[<%=ioaiuIndexNum-1%>] = rn_dii_end_addr[<%=ioaiuIndexNum-2%>] +  1;
             rn_dii_end_addr[<%=ioaiuIndexNum-1%>]   = end_addr;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dii_end_addr[<%=ioaiuIndexNum-1%>], rn_dii_start_addr[<%=ioaiuIndexNum-1%>]),UVM_NONE)
             end else begin //middle
             rn_dii_start_addr[k] = rn_dii_end_addr[k-1] + 1;
             rn_dii_end_addr[k]   = rn_dii_start_addr[k] + rn_increment - 1;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dii_end_addr[k], rn_dii_start_addr[k]),UVM_NONE)
             end
           end
            
            <%for(rn=0; rn< ioaiuIndexNum; rn++) { %>
            if(set_nonsnp[<%=rn%>] == 0) begin
              axi_sys_cfg.create_new_domain(dcount+<%=rn%>, svt_axi_system_domain_item::NONSHAREABLE, {<%=rn%>});
              axi_sys_cfg.set_addr_for_domain(dcount+<%=rn%>, rn_dii_start_addr[<%=rn%>], rn_dii_end_addr[<%=rn%>]);
             `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s:: Creating (RN:<%=rn%>) %s NONSHAREABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[i].unit.name(), dcount+<%=rn%>, rn_dii_end_addr[<%=rn%>], rn_dii_start_addr[<%=rn%>]),UVM_NONE)
            end
            <% } %>
            dcount = dcount+ <%=rn%> + 1;
            set_nonsnp[<%=rn%>] = 1;
            onetime_dii_creation = 1;
          end //}


          if(csrq[i].unit == addrMgrConst::DMI && onetime_dmi_creation == 0) begin //{

           for(int k=0; k< <%=ioaiuIndexNum%>; k++) begin
             if(k==0) begin //1st
             rn_dmi_start_addr[0] = start_addr;
             rn_dmi_end_addr[0]   = rn_dmi_start_addr[0] +  rn_increment - 1;
             `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}", protocol_type, rn_dmi_end_addr[0], rn_dmi_start_addr[0]),UVM_NONE)
             end else if(k== <%=ioaiuIndexNum-1%>) begin //last
             rn_dmi_start_addr[<%=ioaiuIndexNum-1%>] = rn_dmi_end_addr[<%=ioaiuIndexNum-2%>] +  1;
             rn_dmi_end_addr[<%=ioaiuIndexNum-1%>]   = end_addr;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dmi_end_addr[<%=ioaiuIndexNum-1%>], rn_dmi_start_addr[<%=ioaiuIndexNum-1%>]),UVM_NONE)
             end else begin //middle
             rn_dmi_start_addr[k] = rn_dmi_end_addr[k-1] + 1;
             rn_dmi_end_addr[k]   = rn_dmi_start_addr[k] + rn_increment - 1;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dmi_end_addr[k], rn_dmi_start_addr[k]),UVM_NONE)
             end
           end


      	    if($test$plusargs("same_innershareable_range")) begin	
       		if(set_innsnp[0] == 0) begin
      	          if($test$plusargs("en_outershareable_range")) begin	
                   	    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:0) %s OUTERSHAREABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[i].unit.name(), dcount, end_addr,start_addr),UVM_NONE)
                    	    axi_sys_cfg.create_new_domain(dcount, svt_axi_system_domain_item::OUTERSHAREABLE,master_ports);
                  end else begin
                   	    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:0) %s INNERSHAREABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[i].unit.name(), dcount, end_addr,start_addr),UVM_NONE)
                    	    axi_sys_cfg.create_new_domain(dcount, svt_axi_system_domain_item::INNERSHAREABLE,master_ports);
                  end
              	    axi_sys_cfg.set_addr_for_domain(dcount, start_addr, end_addr);
             	    //`uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:0) %s INNERSHAREABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[i].unit.name(), dcount, end_addr,start_addr),UVM_NONE)
            	end
            	dcount = dcount + 0 + 1;
            	set_innsnp[0] = 1;
	    end else begin    
		<%for(rn=0; rn< ioaiuIndexNum; rn++) { %>
            	    if(set_innsnp[<%=rn%>] == 0) begin
      	          if($test$plusargs("en_outershareable_range")) begin	
                	`uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:<%=rn%>) %s OUTERSHAREABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[i].unit.name(), dcount+<%=rn%>, rn_dmi_end_addr[<%=rn%>], rn_dmi_start_addr[<%=rn%>]),UVM_NONE)
              	    	axi_sys_cfg.create_new_domain(dcount+<%=rn%>, svt_axi_system_domain_item::OUTERSHAREABLE, {<%=rn%>});
                  end else begin
                	`uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:<%=rn%>) %s INNERSHAREABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[i].unit.name(), dcount+<%=rn%>, rn_dmi_end_addr[<%=rn%>], rn_dmi_start_addr[<%=rn%>]),UVM_NONE)
              	    	axi_sys_cfg.create_new_domain(dcount+<%=rn%>, svt_axi_system_domain_item::INNERSHAREABLE, {<%=rn%>});
                  end
              		axi_sys_cfg.set_addr_for_domain(dcount+<%=rn%>, rn_dmi_start_addr[<%=rn%>], rn_dmi_end_addr[<%=rn%>]);
             		//`uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:<%=rn%>) %s INNERSHAREABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[i].unit.name(), dcount+<%=rn%>, rn_dmi_end_addr[<%=rn%>], rn_dmi_start_addr[<%=rn%>]),UVM_NONE)
            	    end
           	<% } %>
            	dcount = dcount + <%=rn%> + 1;
            	set_innsnp[<%=rn%>] = 1;
	    end
            onetime_dmi_creation = 1;
          end //}

        end //foreach (csrq[i])

<% } else if (obj.AiuInfo[0].fnNativeInterface == 'CHI-B' || obj.AiuInfo[0].fnNativeInterface == 'CHI-E') { %>
//SCHEME2 (48)

	foreach(master_ports[i])begin
          master_ports[i]=i;
        end
    //Based on intrlvgrp_vector ...Push into dmi_grps,dii_grps
    //dmi_ig_id = $urandom_range(0, $size(addrMgrConst::intrlvgrp_vector)-1 );
  //dmi_ig_id = 1;
  dmi_ig_id = m_mem.dmi_ig_id;
  foreach (addrMgrConst::intrlvgrp_vector[dmi_ig_id][idx]) 
    dmi_grps.push_back(addrMgrConst::intrlvgrp_vector[dmi_ig_id][idx]);
  for (int i = 0; i < addrMgrConst::NUM_DIIS-1; ++i)
    dii_grps.push_back(1);

  //Based on dmi_grps,dii_grps ..Append regions into nintrlv_grps queue
  foreach (dmi_grps[i]) begin
    nintrlv_grps.push_back(dmi_grps[i]);
    nintrlv_type.push_back(addrMgrConst::DMI);
  end
  foreach (dii_grps[i]) begin
    nintrlv_grps.push_back(dii_grps[i]);
    nintrlv_type.push_back(addrMgrConst::DII);
  end
 

 foreach(noncoh_regionsq[indx]) begin
        if(indx==0)m_addr_mgr.get_mem_region_bounds(noncoh_regionsq[indx], start_addr_noncoh, end_addr_noncoh);
end


 `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration:: ADDR MGR Local dmi_ig_id=%d",  dmi_ig_id),UVM_NONE)

 foreach (nintrlv_grps[i])
 if(i < addrMgrConst::intrlvgrp_if.size)
 begin
     csrq = addrMgrConst::get_memregions_assoc_ig(i);
     for(int j=0; j<csrq.size(); j=j+1) begin
       low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
       if(low_addr==start_addr_noncoh)begin
         j++;
       low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
       end
       upp_addr = low_addr + nintrlv_grps[i]*(1<<(csrq[j].size+12)) - 1;
       domain_size = upp_addr - low_addr +1; 

       rn_increment = domain_size/<%=ioaiuIndexNum%>;
       `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h} domain_size=%0d rn_increment=%0d",  protocol_type, upp_addr, low_addr, domain_size, rn_increment),UVM_NONE)


          if(csrq[j].unit == addrMgrConst::DII && onetime_dii_creation == 0) begin //{

           for(int k=0; k< <%=ioaiuIndexNum%>; k++) begin
             if(k==0) begin //1st
             rn_dii_low_addr[0] = low_addr;
             rn_dii_upp_addr[0]   = rn_dii_low_addr[0] +  rn_increment - 1;
             `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}", protocol_type, rn_dii_upp_addr[0], rn_dii_low_addr[0]),UVM_NONE)
             end else if(k== <%=ioaiuIndexNum-1%>) begin //last
             rn_dii_low_addr[<%=ioaiuIndexNum-1%>] = rn_dii_upp_addr[<%=ioaiuIndexNum-2%>] +  1;
             rn_dii_upp_addr[<%=ioaiuIndexNum-1%>]   = upp_addr;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dii_upp_addr[<%=ioaiuIndexNum-1%>], rn_dii_low_addr[<%=ioaiuIndexNum-1%>]),UVM_NONE)
             end else begin //middle
             rn_dii_low_addr[k] = rn_dii_upp_addr[k-1] + 1;
             rn_dii_upp_addr[k]   = rn_dii_low_addr[k] + rn_increment - 1;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dii_upp_addr[k], rn_dii_low_addr[k]),UVM_NONE)
             end
           end
            
            <%for(rn=0; rn< ioaiuIndexNum; rn++) { %>
            if(set_nonsnp[<%=rn%>] == 0) begin
              axi_sys_cfg.create_new_domain(dcount+<%=rn%>, svt_axi_system_domain_item::NONSHAREABLE, {<%=rn%>});
              axi_sys_cfg.set_addr_for_domain(dcount+<%=rn%>, rn_dii_low_addr[<%=rn%>], rn_dii_upp_addr[<%=rn%>]);
              `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:<%=rn%>) %s NONSHAREABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[j].unit.name(), dcount+<%=rn%>, rn_dii_upp_addr[<%=rn%>], rn_dii_low_addr[<%=rn%>]),UVM_NONE)
            end
            <% } %>
            dcount = dcount+ <%=rn%> + 1;
            set_nonsnp[<%=rn%>] = 1;
            onetime_dii_creation = 1;
          end //}


          if(csrq[j].unit == addrMgrConst::DMI && onetime_dmi_creation == 0) begin //{

           for(int k=0; k< <%=ioaiuIndexNum%>; k++) begin
             if(k==0) begin //1st
             rn_dmi_low_addr[0] = low_addr;
             rn_dmi_upp_addr[0]   = rn_dmi_low_addr[0] +  rn_increment - 1;
             `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}", protocol_type, rn_dmi_upp_addr[0], rn_dmi_low_addr[0]),UVM_NONE)
             end else if(k== <%=ioaiuIndexNum-1%>) begin //last
             rn_dmi_low_addr[<%=ioaiuIndexNum-1%>] = rn_dmi_upp_addr[<%=ioaiuIndexNum-2%>] +  1;
             rn_dmi_upp_addr[<%=ioaiuIndexNum-1%>]   = upp_addr;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dmi_upp_addr[<%=ioaiuIndexNum-1%>], rn_dmi_low_addr[<%=ioaiuIndexNum-1%>]),UVM_NONE)
             end else begin //middle
             rn_dmi_low_addr[k] = rn_dmi_upp_addr[k-1] + 1;
             rn_dmi_upp_addr[k]   = rn_dmi_low_addr[k] + rn_increment - 1;
            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: {0x%12h 0x%12h}",  protocol_type, rn_dmi_upp_addr[k], rn_dmi_low_addr[k]),UVM_NONE)
             end
           end

      	    if($test$plusargs("same_innershareable_range")) begin	
		if(set_innsnp[0] == 0) begin
      	          if($test$plusargs("en_outershareable_range")) begin	
             	    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:0) %s OUTERSHAREABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[i].unit.name(), dcount, low_addr,upp_addr),UVM_NONE)
              	    axi_sys_cfg.create_new_domain(dcount, svt_axi_system_domain_item::OUTERSHAREABLE,master_ports);
                  end else begin
             	    `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:0) %s INNERSHAREABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[i].unit.name(), dcount, low_addr,upp_addr),UVM_NONE)
              	    axi_sys_cfg.create_new_domain(dcount, svt_axi_system_domain_item::INNERSHAREABLE,master_ports);
                  end
              	  axi_sys_cfg.set_addr_for_domain(dcount, low_addr, upp_addr);
            	end
            	dcount = dcount + 0 + 1;
            	set_innsnp[0] = 1;
	    end else begin
            	<%for(rn=0; rn< ioaiuIndexNum; rn++) { %>
            	    if(set_innsnp[<%=rn%>] == 0) begin
      	              if($test$plusargs("en_outershareable_range")) begin	
              	            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:<%=rn%>) %s OUTERSHAREABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[j].unit.name(), dcount+<%=rn%>, rn_dmi_upp_addr[<%=rn%>], rn_dmi_low_addr[<%=rn%>]),UVM_NONE)
              	            axi_sys_cfg.create_new_domain(dcount+<%=rn%>, svt_axi_system_domain_item::OUTERSHAREABLE, {<%=rn%>});
                      end else begin
              	            `uvm_info(get_name(),$psprintf("cust_svt_amba_system_configuration::%s: Creating (RN:<%=rn%>) %s INNERSHAREABLE (%0d) {0x%12h 0x%12h}",  protocol_type, csrq[j].unit.name(), dcount+<%=rn%>, rn_dmi_upp_addr[<%=rn%>], rn_dmi_low_addr[<%=rn%>]),UVM_NONE)
              	            axi_sys_cfg.create_new_domain(dcount+<%=rn%>, svt_axi_system_domain_item::INNERSHAREABLE, {<%=rn%>});
                      end
              	      axi_sys_cfg.set_addr_for_domain(dcount+<%=rn%>, rn_dmi_low_addr[<%=rn%>], rn_dmi_upp_addr[<%=rn%>]);
           	    end
            	<% } %>
            	dcount = dcount + <%=rn%> + 1;
            	set_innsnp[<%=rn%>] = 1;
	    end
            onetime_dmi_creation = 1;
          end //}

  end // foreach (csrq[j])
 end // foreach (nintrlv_grps[i])
<% } %>
end //} protocol=="ACE"

endfunction //configure_system_address_map

class reg2chi_adapter extends uvm_reg_adapter;

  svt_chi_rn_transaction chi_trans;
  svt_chi_node_configuration p_cfg;

  `uvm_object_utils_begin(reg2chi_adapter)
    `uvm_field_object(chi_trans, UVM_ALL_ON);
    `uvm_field_object(p_cfg,     UVM_ALL_ON);
  `uvm_object_utils_end


  function new(string name = "reg2chi_adapter");
    super.new(name);
    supports_byte_enable = 1;
    provides_responses = 1;
    `uvm_info("reg2chi_adapter", "Constructed", UVM_LOW);
  endfunction


   // Convert a UVM REG transaction into an CHI transaction
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    `uvm_info("reg2chi_adapter", "Entered reg2bus...", UVM_LOW);
    `uvm_info("reg2chi_adapter", $sformatf("n_bits = %0d", rw.n_bits), UVM_LOW);
    if (rw.n_bits > p_cfg.flit_data_width)
      `uvm_fatal("reg2chi_adapter", "Transfer requested with a data width greater than the configured system data width. Please reconfigure the system with the appropriate data width or reduce the data size");
    if(p_cfg.wysiwyg_enable == 1)
      `uvm_fatal("reg2chi_adapter", "reg2bus: unsupported wysiwyg_enable setting. the adapter only supports wysiwyg_enable=0"); 

    chi_trans = svt_chi_rn_transaction::type_id::create("chi_trans");
    if(rw.kind == UVM_READ) 
      chi_trans.xact_type=svt_chi_transaction::READNOSNP;
    else begin 
      chi_trans.xact_type=svt_chi_transaction::WRITENOSNPPTL;
      chi_trans.data = rw.data;
      `uvm_info("reg2chi_adapter" , $sformatf("chi_trans.data = %0h (WRITE)", chi_trans.data), UVM_LOW);  
      chi_trans.exp_comp_ack = 0; 
    end 
    chi_trans.addr         = rw.addr;
    chi_trans.cfg = p_cfg; 
    if(rw.n_bits == 32) begin 
      chi_trans.data_size = svt_chi_rn_transaction::SIZE_4BYTE;
    chi_trans.byte_enable = 4'hf; 
    end  
    else if(rw.n_bits == 64) begin 
      chi_trans.data_size = svt_chi_rn_transaction::SIZE_8BYTE;
      chi_trans.byte_enable = 8'hff; 
    end   
    else 
      `uvm_fatal("reg2chi_adapter", "reg2bus: unsupported size of register. Only 32-bit and 64-bit register access are supported");
    chi_trans.is_likely_shared = 1'b0;
    chi_trans.snp_attr_is_snoopable = 1'b0;
    chi_trans.order_type = svt_chi_transaction::REQ_EP_ORDERING_REQUIRED;
    chi_trans.mem_attr_is_early_wr_ack_allowed = 1'b0;
    chi_trans.mem_attr_mem_type = svt_chi_transaction::DEVICE;

    `uvm_info("reg2chi_adapter", "Exiting reg2bus...", UVM_LOW);

    return chi_trans;

  endfunction : reg2bus


  // Turn an CHI transaction into a UVM REG transaction
  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    svt_chi_rn_transaction bus_trans;
    `uvm_info("reg2chi_adapter", "Entering bus2reg...", UVM_LOW);

    if (!$cast(bus_trans,bus_item)) begin
      `uvm_fatal("NOT_CHI_TYPE", "reg2chi_adapter::bus2reg: Provided bus_item is not of the correct type")
      return;
    end

    if (bus_trans!= null) begin
      rw.data = bus_trans.data ;
      rw.addr = bus_trans.addr; 
      if (rw.kind == UVM_READ) begin
        `uvm_info("reg2chi_adapter" , $sformatf("bus_trans.data = %0h (READ)", bus_trans.data), UVM_LOW);
      end
      
	  if (bus_trans.response_resp_err_status== svt_chi_transaction::NORMAL_OKAY)
        rw.status = UVM_IS_OK;
      else
        rw.status  = UVM_NOT_OK;
      foreach(bus_trans.data_resp_err_status[i]) begin
        if(bus_trans.data_resp_err_status[i] != svt_chi_transaction::NORMAL_OKAY) begin
          rw.status  = UVM_NOT_OK;
          break;
        end 
      end 
    end
    else
      rw.status  = UVM_NOT_OK;

    `uvm_info("reg2chi_adapter", "Exiting bus2reg...", UVM_LOW);
  endfunction

endclass

class reg2axi_adapter extends uvm_reg_adapter;

  /** The svt_axi_master_reg_transaction is extended from  the svt_axi_transaction class, with additional constraints required for uvm reg */
  svt_axi_master_reg_transaction axi_reg_trans;

  /** The svt_axi_port_configuration ,which is passed from the Master Agent */
  svt_axi_port_configuration p_cfg=new("p_cfg");

// UVM Field Macros
// ****************************************************************************
  `uvm_object_param_utils_begin(reg2axi_adapter)
    `uvm_field_object(axi_reg_trans, UVM_ALL_ON);
    `uvm_field_object(p_cfg,     UVM_ALL_ON);
  `uvm_object_utils_end
  //----------------------------------------------------------------------------
  /**
  * CONSTUCTOR: Create a new transaction instance, passing the appropriate argument
  * values to the parent class.
  *
  * @param name Instance name of the transaction
  */

  // -----------------------------------------------------------------------------
  function new(string name= "reg2axi_adapter");
    super.new(name);
    supports_byte_enable = 1;
    provides_responses = 1;
    `svt_amba_debug("new", "Reg Model Constructed  .... ");
  endfunction

  // -----------------------------------------------------------------------------
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    bit [`SVT_AXI_TRANSACTION_BURST_SIZE_64:0] burst_size_e;
    bit [`SVT_AXI_WSTRB_WIDTH - 1 :0] wstrb = '0;
  
    axi_reg_trans = svt_axi_master_reg_transaction::type_id::create("axi_reg_trans");
    axi_reg_trans.port_cfg = p_cfg;
  
    if (rw.n_bits > p_cfg.data_width)
      `svt_fatal("reg2bus", "Transfer requested with a data width greater than the configured system data width. Please reconfigure the system with the appropriate data width or reduce the data size");
     `svt_amba_debug("reg2bus", $sformatf("n_bits data = %b log_base_2 n_bits", rw.n_bits));
  
     // Turn the TR burst size into an AXI one (smallest burst is 8bit)
     burst_size_e = $clog2(rw.n_bits) - $clog2(8);
     if (! axi_reg_trans.randomize() with {
       if ((p_cfg.axi_interface_type == svt_axi_port_configuration::AXI3)|| (p_cfg.axi_interface_type == svt_axi_port_configuration::AXI4)|| (p_cfg.axi_interface_type == svt_axi_port_configuration::AXI4_LITE)) {
         axi_reg_trans.xact_type == ((rw.kind == UVM_WRITE) ? svt_axi_master_reg_transaction::WRITE : svt_axi_master_reg_transaction::READ);
  	   }
       else if ((p_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE)|| (p_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE)) {
  	   axi_reg_trans.xact_type == svt_axi_transaction::COHERENT;
   	   axi_reg_trans.coherent_xact_type == ((rw.kind == UVM_READ) ? svt_axi_master_transaction::READNOSNOOP : svt_axi_master_transaction::WRITENOSNOOP);
  	 }
         axi_reg_trans.addr == rw.addr;
         axi_reg_trans.burst_length == 1;
         axi_reg_trans.burst_type == svt_axi_transaction::INCR;
         axi_reg_trans.burst_size == burst_size_e;
        }) begin
        `svt_fatal("reg2bus", " Transaction randomization failed");
     end
  
    if (rw.kind == UVM_WRITE) begin
      axi_reg_trans.data[0] = rw.data;
      if (burst_size_e > 0) begin
        for(int i = 0; i < (2**burst_size_e); i++)
          wstrb[i] = 1'h1;
        end
      else begin
          wstrb[0] = 1'h1;
      end
      axi_reg_trans.wstrb[0] = wstrb;
    end
    else if (rw.kind == UVM_READ) begin
      axi_reg_trans.rresp     = new[axi_reg_trans.burst_length];
    end
  
    return axi_reg_trans;
  endfunction : reg2bus

  // -----------------------------------------------------------------------------
  function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    svt_axi_master_transaction bus_trans;
    if (!$cast(bus_trans,bus_item)) begin
       `svt_fatal("bus2reg", "bus2reg: Provided bus_item is not of the correct type");
      return;
    end
  
    if (bus_trans!= null) begin
      rw.addr = bus_trans.addr;
      rw.data = bus_trans.data[0] ;
      if (bus_trans.xact_type == svt_axi_master_reg_transaction::READ) begin
        rw.kind = UVM_READ;	    
        `svt_amba_debug("bus2reg" , $sformatf("bus_trans.data = %0h (READ)", bus_trans.data[0]));
        if (bus_trans.rresp[0] == svt_axi_transaction::OKAY)
          rw.status = UVM_IS_OK;
        else
          rw.status  = UVM_NOT_OK;
      end 
      else begin
        if (bus_trans.xact_type == svt_axi_master_reg_transaction::WRITE) begin
          rw.kind = UVM_WRITE;
          if (bus_trans.bresp == svt_axi_transaction::OKAY)
            rw.status = UVM_IS_OK;
          else
            rw.status  = UVM_NOT_OK;
        end
      end
    end
    else
      rw.status  = UVM_NOT_OK;
  endfunction

endclass : reg2axi_adapter

<% } %>
`endif // GUARD_CUST_SVT_AMBA_SYSTEM_CONFIGURATION_SV
