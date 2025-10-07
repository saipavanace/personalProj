
////////////////////////////////////////////////////////////////////////////////
//
// concerto_env_snps 
<% if (1 == 0) { %>
// Author: Satya Prakash
<% } %>
//
////////////////////////////////////////////////////////////////////////////////


<%
//Embedded javascript code to figure number of blocks
   var _child_blkid      = [];
   var _child_blk        = [];
   var pma_en_dmi_blk = 1;
   var pma_en_dii_blk = 1;
   var pma_en_aiu_blk = 1;
   var pma_en_dce_blk = 1;
   var pma_en_dve_blk = 1;
   var pma_en_at_least_1_blk = 0;
   var pma_en_all_blk = 1;
   var pidx              = 0;
   var ridx              = 0;
   var qidx              = 0;
   var idx               = 0;
   var j                 = 0;
   var num_chi_aiu_tx_if = 0;
   var num_io_aiu_tx_if  = 0;
   var num_dmi_tx_if     = 0;
   var num_dii_tx_if     = 0;
   var num_dce_tx_if     = 0;
   var num_dve_tx_if     = 0;
   var num_chi_aiu_rx_if = 0;
   var num_io_aiu_rx_if  = 0;
   var num_dmi_rx_if     = 0;
   var num_dii_rx_if     = 0;
   var num_dce_rx_if     = 0;
   var num_dve_rx_if     = 0;
   var initiatorAgents   = obj.AiuInfo.length ;
   var numChiAiu         = 0;
   var numCAiu           = 0;
   var numNCAiu          = 0;
   var numIoAiu          = 0;
   var aiu_NumCores = [];
   var found_csr_access_chiaiu=0;
   var found_csr_access_ioaiu=0;
   var csrAccess_ioaiu;
   var csrAccess_chiaiu;
var numACEAiu = 0; // Number of ACE AIUs
var numBootIoAiu = 0; // Number of NCAIUs can participate in Boot
var chiaiu0;  // strRtlNamePrefix of chiaiu0
var aceaiu0;  // strRtlNamePrefix of aceaiu0
var ncaiu0;   // strRtlNamePrefix of aceaiu0
var idxIoAiuWithPC = obj.nAIUs; // To get valid index of NCAIU with ProxyCache. Initialize to nAIUs
var noBootIoAiu = 1;
const BootIoAiu = [];
const aiuName = [];
   for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
     if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
         aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
     } else {
         aiu_NumCores[pidx]    = 1;
     }
   }
   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       num_chi_aiu_tx_if = obj.AiuInfo[pidx].smiPortParams.tx.length;
       num_chi_aiu_rx_if = obj.AiuInfo[pidx].smiPortParams.rx.length;
       numChiAiu = numChiAiu + 1;
       idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + qidx;
       _child_blk[pidx]   = 'ioaiu';
       num_io_aiu_tx_if = obj.AiuInfo[pidx].smiPortParams.tx.length;
       num_io_aiu_rx_if = obj.AiuInfo[pidx].smiPortParams.rx.length;
       numIoAiu = numIoAiu + 1;
       qidx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
       num_dce_tx_if = obj.DceInfo[pidx].smiPortParams.tx.length;
       num_dce_rx_if = obj.DceInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
       num_dmi_tx_if = obj.DmiInfo[pidx].smiPortParams.tx.length;
       num_dmi_rx_if = obj.DmiInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
       num_dii_tx_if = obj.DiiInfo[pidx].smiPortParams.tx.length;
       num_dii_rx_if = obj.DiiInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
       num_dve_tx_if = obj.DveInfo[pidx].smiPortParams.tx.length;
       num_dve_rx_if = obj.DveInfo[pidx].smiPortParams.rx.length;
   }

var chi_idx=0;
var io_idx=0;
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    pma_en_aiu_blk &= obj.AiuInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.AiuInfo[pidx].usePma;
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
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE" ||obj.AiuInfo[pidx].fnNativeInterface == "ACE5") { 
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
typedef class concerto_env;
class concerto_env_snps extends uvm_env;

    //////////////////////////////////
    //UVM Registery
    //////////////////////////////////        
    `uvm_component_utils(concerto_env_snps)
  
    //////////////////////////////////
    //Concerto env config handle
    reg2chi_adapter                                reg2chi;
    reg2axi_adapter                                reg2axi;
   
    concerto_env parent;
    concerto_env_cfg m_cfg;
    svt_amba_env_class_pkg::svt_amba_env   svt;

    chi_coh_bringup_virtual_seqr coh_vseqr;

    //////////////////////////////////
    extern function new(string name = "concerto_env_snps", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void end_of_elaboration_phase(uvm_phase phase);

    <% if(numChiAiu > 0) { %>
    extern virtual function void init_coh_vseqr();
    <% } %>
    
endclass:concerto_env_snps
////////////////////////////////////////
// Constructing the concerto_env_snps
///////////////////////////////////////
function concerto_env_snps::new(string name = "concerto_env_snps", uvm_component parent = null);
  super.new(name,parent);
endfunction
// ////////////////////////////////////////////////////////////////////////////
// #     # #     # #     #         ######  #     #    #     #####  #######
// #     # #     # ##   ##         #     # #     #   # #   #     # #
// #     # #     # # # # #         #     # #     #  #   #  #       #
// #     # #     # #  #  #         ######  ####### #     #  #####  #####
// #     #  #   #  #     #         #       #     # #######       # #
// #     #   # #   #     #         #       #     # #     # #     # #
//  #####     #    #     # ####### #       #     # #     #  #####  #######
////////////////////////////////////////////////////////////////////////////
function void concerto_env_snps::build_phase(uvm_phase phase);
    
    <% if (numChiAiu) { %>
    reg2chi = reg2chi_adapter::type_id::create("reg2chi");
    <% }%>
    
    <% if (numIoAiu) { %>
    reg2axi = reg2axi_adapter::type_id::create("reg2axi");
    <% }%>
    parent = concerto_env'(this.get_parent()); 

     //`uvm_info("Connect", "Entered Concerto Environment build Phase", UVM_LOW);
    if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", m_cfg)))
        `uvm_fatal("Missing Config Obj", "Could not find concerto_env_cfg object in UVM DB");

    svt = svt_amba_env_class_pkg::svt_amba_env::type_id::create("svt", this);
    //Create the AMBA Cfg and apply the Ncore VIP config from concerto_env_cfg
    uvm_config_db#(svt_amba_env_class_pkg::svt_amba_env)::set(uvm_root::get(), "", "svt", svt);
    uvm_config_db#(uvm_reg_block)::set(this, "svt.amba_system_env.apb_system[0].master", "apb_regmodel", parent.m_regs);
    
 // BEGIN SLAVE   
<% var axi_slv_idx=0; %>
 if (m_cfg.has_axi_slv_vip_snps) begin:_build_axi_slv_vip
<% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
       m_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.active = UVM_PASSIVE;
    <% axi_slv_idx  = axi_slv_idx + 1; %>
<% } %>
 
 <% for(var pidx = 0 ; pidx < obj.nDIIs; pidx++) { %>
<%    if (obj.DiiInfo[pidx].configuration == 0) { %>
        m_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.active = UVM_PASSIVE;
      <% axi_slv_idx  = axi_slv_idx + 1; %>
    <% } %>
<% } %>
 end:_build_axi_slv_vip
//END SLAVE  

  coh_vseqr = chi_coh_bringup_virtual_seqr::type_id::create("coh_vseqr", this);

endfunction:build_phase

function void concerto_env_snps::end_of_elaboration_phase (uvm_phase phase);
     bit k_csr_access_only;
    
     if(!$value$plusargs("k_csr_access_only=%d",k_csr_access_only))begin
       k_csr_access_only = 0;
    end 
    
    if (m_cfg.has_axi_vip_snps && k_csr_access_only) begin:_axi
    <% if (numIoAiu && found_csr_access_ioaiu) { %>
    reg2axi.p_cfg = m_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[<%=csrAccess_ioaiu%>]; // Set the register config to be the same as the rn[0]
    parent.m_regs.default_map.set_sequencer(svt.amba_system_env.axi_system[0].master[<%=csrAccess_ioaiu%>].sequencer, reg2axi);
    <% }%>
    end:_axi
    if (m_cfg.has_chi_vip_snps && k_csr_access_only) begin:_chi
    <% if (numChiAiu && found_csr_access_chiaiu) { %>
    reg2chi.p_cfg = m_cfg.svt_cfg.chi_sys_cfg[0].rn_cfg[<%=csrAccess_chiaiu%>]; // Set the register config to be the same as the rn[0]
    parent.m_regs.default_map.set_sequencer(svt.amba_system_env.chi_system[0].rn[<%=csrAccess_chiaiu%>].rn_xact_seqr,reg2chi);
    <% }%>
    parent.m_regs.default_map.set_auto_predict(0);
    end:_chi

//DEMOTE some messages to be able to use UVM_FULL
// avoid pass messages UVM_INFO:
// "uvm_test_top.m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[0].link [register_pass:link:signal validity:signal_valid_txlinkactiveack_check] ...
// ...Description: TXLINKACTIVEACK must not be X/Z, Reference: ARM-IHI0050A: 12, ARM-IHI0050B: 13, ARM-IHI0050E.b: 14"

<% var jk = 0; for(var j = 0; j < obj.AiuInfo.length; j++) { 
     if(obj.AiuInfo[j].fnNativeInterface.indexOf('CHI') >= 0) { %>
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxsactive_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txlinkactiveack_check.default_pass_effect=`SVT_IGNORE_EFFECT; 
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxlinkactivereq_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txreqlcrdv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxrspflitpend_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxrspflitv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txdatlcrdv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxdatflitpend_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxdatflitv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txrsplcrdv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxsnpflitv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxsnpflitpend_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txlinkactivereq_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxlinkactiveack_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txsactive_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txreqflitpend_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txreqflitv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxreqflitpend_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxreqflitv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxreqlcrdv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxrsplcrdv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txrspflitpend_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txrspflitv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txdatflitpend_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txdatflitv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxdatlcrdv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxsnplcrdv_check.default_pass_effect=`SVT_IGNORE_EFFECT;
 `ifdef SVT_CHI_INTERFACE_PARITY_ENABLE
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxsactivechk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txlinkactiveackchk_check.default_pass_effect=`SVT_IGNORE_EFFECT; 
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxlinkactivereqchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txreqlcrdvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxrspflitpendchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxrspflitvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txdatlcrdvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxdatflitpendchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxdatflitvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txrsplcrdvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxxsnpflitpendchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxsnpflitvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_syscoackchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxsnpflitpendchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txlinkactivereqchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxlinkactiveackchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txrspflitpendchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txrspflitvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txdatflitpendchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txdatflitvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txreqflitpendchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txreqflitvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxrsplcrdvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxdatlcrdvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txsactivechk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxreqlcrdvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxreqflitvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxreqflitchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txrspflitchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxdatflitchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txdatflitchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_txreqflitchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxsnpflitchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxrspflitchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxreqflitpendchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_rxsnplcrdvchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
      //svt.amba_system_env.chi_system[0].rn[<%=jk%>].link.common.link_err_check.signal_valid_syscoreqchk_check.default_pass_effect=`SVT_IGNORE_EFFECT;
 `endif
       <% jk = jk+1;%>
  <%}%>
<%}%>

  <% if(numChiAiu > 0) { %>
  init_coh_vseqr();
  <% } %>

endfunction:end_of_elaboration_phase

<% if(numChiAiu > 0) { %>
//SANJEEV: Init Coherency Link up and initialization VSEQR
function void concerto_env_snps::init_coh_vseqr();

  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
      `uvm_info(get_name(), "USE_VIP_SNPS Initialise coh_vseqr.link_up_seqr<%=idx%>", UVM_LOW)
       coh_vseqr.link_up_seqr<%=idx%> = parent.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].link_svc_seqr ;
      <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
      `uvm_info(get_name(), "USE_VIP_SNPS INIT coh_vseqr.event_seqr<%=idx%> ", UVM_LOW)
       coh_vseqr.event_seqr<%=idx%> = parent.inhouse.m_chiaiu<%=idx%>_env.m_event_agent.m_sequencer;
      <% } %> 
    <% idx++; %>
    <%} %>
  <% } %>

  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
      `uvm_info(get_name(), "USE_VIP_SNPS INIT coh_vseqr.coh_entry_seqr<%=idx%>", UVM_NONE)
      coh_vseqr.coh_entry_seqr<%=idx%> = parent.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].prot_svc_seqr;
    <% idx++; %>
    <%} %>
  <% } %>

  <% var idx=0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
      <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
        coh_vseqr.node_cfg<%=idx%> = m_cfg.svt_cfg.chi_sys_cfg[0].rn_cfg[<%=idx%>];
      <% } %>
    <% idx++; %>
    <%} %>
    <%} %>

  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
      `uvm_info(get_name(), "USE_VIP_SNPS INIT coh_vseqr.rn_xact_seqr<%=idx%>", UVM_NONE)
      coh_vseqr.rn_xact_seqr<%=idx%> = parent.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr;
      coh_vseqr.rn_cache<%=idx%> = parent.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_cache;
    <% idx++; %>
    <%} %>
  <% } %>

  coh_vseqr.svt_chi_system_vseqr = parent.snps.svt.amba_system_env.chi_system[0].virt_seqr;
  coh_vseqr.m_concerto_env = parent;

endfunction: init_coh_vseqr
<% } %>

   
