//File: concerto_tb_top.sv

<% var ASILB = 0; // (obj.useResiliency & obj.enableUnitDuplication) ? 0 : 1; %>
<% var hier_path_dce_csr          = (!ASILB) ? 'dce_func_unit.u_csr' : 'u_csr'; %>
<% var hier_path_dce_cmux         = (!ASILB) ? 'dce_func_unit.dce_conc_mux' : 'dce_conc_mux'; %>
<% var hier_path_dce_sbcmdreqfifo = (!ASILB) ? 'dce_func_unit.skid_buf_cmd_req_fifo' : 'skid_buf_cmd_req_fifo'; %>
<% var hier_path_dce_sb           = (!ASILB) ? 'dce_func_unit.dce_skid_buffer' : 'dce_skid_buffer'; %>

    //Concerto Top Module instantiation
    //Hooks up respective interfaces to the top
    //TODO: Fix all bus width issues, No hard coded values
<%
   var aiu_useAceQosPort = [];
   var aiu_useAceRegionPort = [];
   var aiu_wAwUser = [];
   var aiu_wWUser = [];
   var aiu_wBUser = [];
   var aiu_wArUser = [];
   var aiu_wRUser = [];
   var aiu_useAceUniquePort = [];

   var dmi_useAceQosPort = [];
   var dmi_useAceRegionPort = [];
   var dmi_wAwUser = [];
   var dmi_wWUser = [];
   var dmi_wBUser = [];
   var dmi_wArUser = [];
   var dmi_wRUser = [];
   var dmi_useAceUniquePort = [];
   
   var dii_useAceQosPort = [];
   var dii_useAceRegionPort = [];
   var dii_wAwUser = [];
   var dii_wWUser = [];
   var dii_wBUser = [];
   var dii_wArUser = [];
   var dii_wRUser = [];
   var dii_useAceUniquePort = [];
   var initiatorAgents        = obj.nAIUs ;
   var clocks = [];
   var clocks_freq = [];
   var aiu_axiInt = [];
   var aiu_NumCores = [];
   const aiu_axiIntLen = [];

   for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
     if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
         aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
         aiu_axiInt[pidx] = new Array(aiu_NumCores[pidx]);
         for(var i=0; i<aiu_NumCores[pidx]; i++) {
            aiu_axiInt[pidx][i] = obj.AiuInfo[pidx].interfaces.axiInt[i];
         }
     } else {
         aiu_NumCores[pidx]    = 1;
         aiu_axiInt[pidx] = new Array(aiu_NumCores[pidx]);
         aiu_axiInt[pidx][0] = obj.AiuInfo[pidx].interfaces.axiInt;
     }
   }

   for(var pidx = 0; pidx < obj.nDMIs; pidx++) {
       if((obj.DmiInfo[pidx].interfaces.axiInt.params.wQos > 0 == 0) && (obj.wPriorityLevel == 0)) { 
           dmi_useAceQosPort.push(0);
       } else {
           dmi_useAceQosPort.push(1);
       }
       dmi_useAceRegionPort.push(obj.DmiInfo[pidx].interfaces.axiInt.params.useRegionPort);
       //TODO FIXME
       //dmi_useAceUniquePort.push();

       dmi_wAwUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wAwUser);
       dmi_wWUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wWUser);
       dmi_wBUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wBUser);
       dmi_wArUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wArUser);
       dmi_wRUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wRUser);
   }
   for(var pidx = 0; pidx < obj.nDIIs; pidx++) {
       if((obj.DiiInfo[pidx].interfaces.axiInt.params.wQos > 0 == 0) && (obj.wPriorityLevel == 0)) { 
           dii_useAceQosPort.push(0);
       } else {
           dii_useAceQosPort.push(1);
       }
       dii_useAceRegionPort.push(obj.DiiInfo[pidx].interfaces.axiInt.params.useRegionPort);
       //TODO FIXME
       //dii_useAceUniquePort.push();

       dii_wAwUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wAwUser);
       dii_wWUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wWUser);
       dii_wBUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wBUser);
       dii_wArUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wArUser);
       dii_wRUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wRUser);
   }
%>		  
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var pidx = 0;
   var ridx = 0;
   var chiaiu_idx = 0;
   var ioaiu_idx = 0;
   var initiatorAgents = obj.AiuInfo.length ;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
       _child_blk[pidx]   = 'chiaiu';
       chiaiu_idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
       _child_blk[pidx]   = 'ioaiu';
       ioaiu_idx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
   }
%>

<%

var pma_en_dmi_blk = 1;
var pma_en_dii_blk = 1;
var pma_en_aiu_blk = 1;
var pma_en_dce_blk = 1;
var pma_en_dve_blk = 1;
var pma_en_all_blk = 1;

for(var pidx = 0; pidx < obj.nDMIs; pidx++) {
    pma_en_dmi_blk &= obj.DmiInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nDIIs; pidx++) {
    pma_en_dii_blk &= obj.DiiInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    pma_en_aiu_blk &= obj.AiuInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nDCEs; pidx++) {
    pma_en_dce_blk &= obj.DceInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nDVEs; pidx++) {
    pma_en_dve_blk &= obj.DveInfo[pidx].usePma;
}
pma_en_all_blk = pma_en_dmi_blk & pma_en_dii_blk & pma_en_aiu_blk & pma_en_dce_blk & pma_en_dve_blk;

for(var clock=0; clock < obj.Clocks.length; clock++) {
   var clk_name = obj.Clocks[clock].name;
   var name_len = clk_name.length;
   var mod_name;
   if(clk_name[name_len-1] == '_') {  // remove if last character is '_'
       mod_name = clk_name.substr(0, name_len-1);
   } else {
       mod_name = clk_name;
   }
   clocks[clock] = mod_name;
   clocks_freq[clock] = obj.Clocks[clock].params.frequency;
}
%>
<% if(obj.useResiliency) { %>
 `include "fsys_fault_injector_checker.sv"
  `include "ph_connectivity_checker.sv"
<% } %>
<% if(obj.testBench=="emu") { %>
//import mgc_vtl_chi_pkg::*;
//`include "/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/sysvlog/mgc_chi_link_pkg.sv"
//import mgc_vtl_chi_link_pkg::*;
//`include "/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/sysvlog/mgc_chi_rn_if.sv"
//To comment in Emulation

//`ifndef ARTERIS_TBX
//`include "/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog/mgc_axi_pkg.sv" //D
//`include "/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog/master/axi_master_if.sv"//D
//`endif

//import mgc_axi_pkg::*;         
//`include "/engr/dev/tools/mentor/Veloce_Transactors_Library_v4.9.0.0/chi_v2/sysvlog/vtl_chi_types.svh"  
//`include "/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/examples/common/print_packets.sv"
import concerto_xrtl_pkg::* ; 
import mgc_resp_pkg::*;

<% } %>

`include "snps_compile.sv"
<% for(var j = 0; j < obj.AiuInfo.length; j++) { 
     if(obj.AiuInfo[j].fnNativeInterface.indexOf('CHI') >= 0) { %>
`ifdef USE_VIP_SNPS_CHI
        `include "<%=_child_blkid[j]%>_connection_wrapper.sv"
`endif
<% } else { %>
`ifdef USE_VIP_SNPS_AXI_MASTERS
  `include "<%=_child_blkid[j]%>_connect_source2target_if.sv"
  import wrapper_pkg_<%=_child_blkid[j]%>::*;
`endif
<% } }%>

`ifdef USE_VIP_SNPS_AXI_SLAVES
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { 
  var ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;%>
  <% if (obj.DiiInfo[pidx].configuration == 0) { %>  					       
  `include "<%=_child_blkid[ridx]%>_connect_source2target_if.sv"
  <% } %>
<% } %>

<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { 
  var ridx = pidx + obj.nAIUs + obj.nDCEs;%>
  `include "<%=_child_blkid[ridx]%>_connect_source2target_slv_if.sv"
<% } %>
`endif

`ifdef USE_VIP_SNPS_APB
<% if(obj.DebugApbInfo.length > 0) { %>
 `include "connection_wrapper_to_svt_apb_if.sv"
<% } %>
`endif

 `ifdef FSYS_COVER_ON 
   `include "fsys_coverage_csr_probe_if.sv"
 `endif

  `ifdef VCS
    `include "clk_if.sv"
    `include "irq_if.sv"
    `include "fault_if.sv"
  `endif // `ifndef VCS
module tb_top();
timeunit 1ns;
timeprecision 1ps;

bit release_sysco_req;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

   `include "snps_import.sv"
    import addr_trans_mgr_pkg::*;
    //import concerto_tests_pkg::*;
 //   import apb_agent_pkg::*;
<% if(obj.testBench=="emu") { %>
`include "ioaiu0_axi_widths.svh"
`include "ioaiu0_axi_types.svh"
  <% } %>
  `ifndef VCS
    `include "clk_if.sv"
    `include "irq_if.sv"
    `include "fault_if.sv"
  `endif // `ifndef VCS
   
`ifdef INCA
    //Concerto Plus args
    `include "concerto_test_list.svh"
`endif
     <% if(obj.testBench=="emu") { %>
           abc abc1;
           mgc_resp mgc_rsp;
     <% } %>
//TODO FIXME: When Meastro supports multiple clocks 
//<%/*  obj.ClockPorts.uniquePorts.forEach(function(b, i, arrray) { */%>
           logic sys_clk; //logic sys_clk<%/*=i*/%>;
           logic dut_clk; //logic dut_clk<%/*=i*/%>;
           logic sys_rstn; //logic sys_rstn<%/*=i*/%>;
           logic soft_rstn; //logic soft_rstn<%/*=i*/%>;
      <% if(obj.testBench=="emu") { %>

         logic concerto_tb_aclk; //logic soft_rstn<%/*=i*/%>;
         logic concerto_tb_aresetn; //logic soft_rstn<%/*=i*/%>;
         logic concerto_tb_aclk_chk; //logic soft_rstn<%/*=i*/%>;
         logic concerto_tb_aresetn_chk; //logic soft_rstn<%/*=i*/%>;

     <% } %>


//<%/*  }); */%>
   <% for(var clock=0; clock < clocks.length; clock++) { %>
     clk_if m_clk_if_<%=clocks[clock]%>();
     logic <%=clocks[clock]%>_clk_sync;
     logic <%=clocks[clock]%>_dut_clk;
     logic <%=clocks[clock]%>_soft_rstn;
     <% } %>

    //Globally declared for visibility
    string msg_idx;

    //Q-channel interface
   <% for(var idx=0; idx<obj.PmaInfo.length; idx++) { %>
    concerto_q_chnl_if m_q_chnl_if_<%=obj.PmaInfo[idx].strRtlNamePrefix%>(sys_clk, sys_rstn);
<% } %>
    uvm_event toggle_clk;
    uvm_event toggle_rstn;
    uvm_event hard_rstn_finished_ev;
    uvm_event hard_rstn_ev;
    uvm_event mission_fault_detected;
    uvm_event latent_fault_detected;
    uvm_event cerr_over_thresh_fault_detected;
    bit func_unit_uncorr_err_inj;
    bit dup_unit_uncorr_err_inj;
    bit both_units_uncorr_err_inj;
   //////////////////////////
   //Interfaces
   //////////////////////////
 `ifdef FSYS_COVER_ON 
   fsys_coverage_csr_probe_if m_fsys_coverage_csr_probe_if();
   initial begin
        uvm_config_db#(virtual fsys_coverage_csr_probe_if)::set(null, "", "m_fsys_coverage_csr_probe_if", m_fsys_coverage_csr_probe_if); 
   end
  `endif
<% var chi_idx=0;
  	var io_idx=0;   
   	for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++){ %>
           //Connectivity interleaving interfaces
           <%=_child_blkid[pidx]%>_connectivity_if <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if();

    <% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %> 
          <%=_child_blkid[pidx]%>_event_if #(.IF_MASTER(1)) m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_sender_master();
            
    <% } %>
     
    <% if (obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false) { %>
        <%=_child_blkid[pidx]%>_event_if #(.IF_MASTER(0)) m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_receiver_slave();
            
    <% } %>
           <%for (var i=0; i<aiu_NumCores[pidx]; i++) { %>
           <%=_child_blkid[pidx]%>_stall_if <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>_sb_stall_if();
           <% } %>
		<%if(obj.AiuInfo[pidx].fnNativeInterface.indexOf('CHI') >= 0) { %>
        	<%=_child_blkid[pidx]%>_chi_if  m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(<%=obj.AiuInfo[pidx].nativeClk%>dut_clk, <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn); //chi_inhouse_if
<% if(obj.testBench=="emu") { %>

        <%=_child_blkid[pidx]%>_chi_emu_if  m_chi_emu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(<%=obj.AiuInfo[pidx].nativeClk%>dut_clk, <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn);
         
        mgc_chi_rn_if mgc_chi_rn_if_<%=chi_idx%> (); // mgc_rn_if is created outside loop
 
       <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') {%>
         <%  var chi_version = 0;%>
       <%} else if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B') {%>
         <%  var chi_version = 1;%>
      <%} else if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-C') {%>
           <% var chi_version = 2; %>
      <%} else if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-D') {%>    
           <% var chi_version = 3; %>
       <%} else if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E'){%>
           <% var chi_version = 4; %>
        <%}%>
      defparam mgc_chi_rn_if_<%=chi_idx%>.CHI_NODE_ID_WIDTH     = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID%>;
      defparam mgc_chi_rn_if_<%=chi_idx%>.CHI_REQ_ADDR_WIDTH    = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.wAddr%>;
      defparam mgc_chi_rn_if_<%=chi_idx%>.CHI_DATA_WIDTH        = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.wData%>;
      defparam mgc_chi_rn_if_<%=chi_idx%>.CHI_RSVDC_EN          = 0; // <%=obj.AiuInfo[pidx].interfaces.chiInt.params.REQ_RSVDC%>;
      defparam mgc_chi_rn_if_<%=chi_idx%>.CHI_RSVDC_WIDTH       = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.REQ_RSVDC%>;
      defparam mgc_chi_rn_if_<%=chi_idx%>.CHI_RSVDC_EN_DATA     = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.DAT_RSVDC%>;
      defparam mgc_chi_rn_if_<%=chi_idx%>.CHI_RSVDC_WIDTH_DATA  = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.DAT_RSVDC%>;
      defparam mgc_chi_rn_if_<%=chi_idx%>.CHI_DATA_CHECK_EN     = 1; //WDATACHECK_VALID;
      defparam mgc_chi_rn_if_<%=chi_idx%>.CHI_POISON_EN         = 1; //WPOSION_VALID;
      defparam mgc_chi_rn_if_<%=chi_idx%>.CHI_VERSION           =  <%=chi_version%>;
 <% } %>


	    //event_if #(.IF_MASTER(1)) m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_sender_master();
	    //event_if #(.IF_MASTER(0)) m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_receiver_slave();
	    //    initial begin 
	    //    	uvm_config_db#(virtual event_if)::set(null, "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_env_cfg_TODO_TMP", "m_event_if_sender_master",m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_sender_master); 
	    //    	uvm_config_db#(virtual event_if)::set(null, "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_env_cfg_TODO_TMP", "m_event_if_receiver_slave",m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_receiver_slave); 
	    //end 

        irq_if m_irq_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>();
			event_out_if m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(<%=obj.AiuInfo[pidx].nativeClk%>dut_clk, <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn);
			<%if (obj.AiuInfo[pidx].interfaces.userPlaceInt._SKIP_ == false || (typeof obj.AiuInfo[pidx].interfaces.memoryInt !== 'undefined')) { %>
        		chiaiu<%=chi_idx%>_generic_if m_generic_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(<%=obj.AiuInfo[pidx].nativeClk%>dut_clk, <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn);
			<%}%>
			<% chi_idx++; %>
		<%}else { %>
		<% for(var n=0; n<aiu_NumCores[pidx]; n++) { %>
                <% if(obj.testBench!="emu") { %>
            //NAVEEN - Event interface is per unit of Ioaiu and not per core
	    /*event_if #(.IF_MASTER(1)) m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sender_master();
	    event_if #(.IF_MASTER(0)) m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_receiver_slave();
        initial begin 
	  		uvm_config_db#(virtual event_if)::set(null, "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_env_cfg_TODO_TMP[<%=n%>]", "m_event_if_sender_master",m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sender_master); 
	  		uvm_config_db#(virtual event_if)::set(null, "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_env_cfg_TODO_TMP[<%=n%>]", "m_event_if_receiver_slave",m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_receiver_slave); 
	    end*/ 
      //`uvm_info("concerto_tb_top", $psprintf("owo:<%=obj.AiuInfo[pidx].orderedWriteObservation%> wdata:<%=obj.AiuInfo[pidx].wData%> pidx:<%=pidx%>"), UVM_LOW);
        	<%=_child_blkid[pidx]%>_axi_if  ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>(<%=obj.AiuInfo[pidx].nativeClk%>dut_clk, <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn); //axi_inhouse_if
    <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B') && obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E') { %>
      //Instantiate probe intf
<%=_child_blkid[pidx]%>_probe_if  u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>(<%=obj.AiuInfo[pidx].unitClk[0]%>dut_clk, <%=obj.AiuInfo[pidx].unitClk[0]%>soft_rstn);	
			<%}%>
                uvm_event ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>,  ioaiu_clk_negedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>;
                initial begin
                    //CONC-11856 TMP force arvmid in ioaiu to 0 till we get MAES-6334 
                    <% if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || (obj.AiuInfo[pidx].fnNativeInterface == "ACE5")) { %>
                    //force dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.arvmidext[3:0]= 4'h0;
                    <%}%> 
                    ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%> = new("ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>");
                    ioaiu_clk_negedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%> = new("ioaiu_clk_negedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>");
                    uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                      .inst_name( "" ),
                      .field_name( "ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>" ),
                      .value(ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>));
                    uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                      .inst_name( "" ),
                      .field_name( "ioaiu_clk_negedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>" ),
                      .value(ioaiu_clk_negedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>));
                end
                always @ (posedge <%=obj.AiuInfo[pidx].nativeClk%>dut_clk) begin
                    ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.trigger();
                end
                always @ (negedge <%=obj.AiuInfo[pidx].nativeClk%>dut_clk) begin
                    ioaiu_clk_negedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.trigger();
                end
                <% } %>
                <% } %>
                <% if(obj.testBench=="emu") { %>
		<% for(var n=0; n<aiu_NumCores[pidx]; n++) { %>
                <%=_child_blkid[pidx]%>_axi_if  ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>(concerto_tb_aclk, concerto_tb_aresetn); //Added D
                <% } %>
                <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE' || obj.AiuInfo[pidx].fnNativeInterface == "ACE5") { %>
                    mgc_axi_master_if mgc_ace_m_if_<%=_child_blkid[pidx]%>();
                    <%=_child_blkid[pidx]%>_ace_emu_if  m_ace_emu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(<%=obj.AiuInfo[pidx].nativeClk%>dut_clk, <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn);
                         // mgc_axi_master_if mgc_ace_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>();
                         /* mgc_axi_master_if mgc_ace_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(); */
                <% } else if((obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE") || (obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" )){ %>
                    mgc_axi_master_if mgc_acelite_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>();
                    <%=_child_blkid[pidx]%>_ace_emu_if  m_ace_emu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(<%=obj.AiuInfo[pidx].nativeClk%>dut_clk, <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn);
             
               <% } else if (!((obj.AiuInfo[pidx].fnNativeInterface == "ACE")|| (obj.AiuInfo[pidx].fnNativeInterface == "ACE5")||(obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE")||(obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" )||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')))  { %>
                   <% if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) { %>
                       <% aiu_axiIntLen[pidx] = obj.AiuInfo[pidx].interfaces.axiInt.length; %>
                       <% for (var i=0; i<aiu_axiIntLen[pidx]; i++) { %>
                          mgc_axi_master_if mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>();
                          <%=_child_blkid[pidx]%>_ace_emu_if  m_ace_emu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>(<%=obj.AiuInfo[pidx].nativeClk%>dut_clk, <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn);
					   <% } %>
				  <% } else { %>
                       mgc_axi_master_if mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>();
                       <%=_child_blkid[pidx]%>_ace_emu_if  m_ace_emu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(<%=obj.AiuInfo[pidx].nativeClk%>dut_clk, <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn);
				  <% } %>
               <% } %>
               <% } %>

			irq_if m_irq_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>();
                       <% if (obj.testBench != "emu" ){ %>
		<%if((obj.AiuInfo[pidx].fnNativeInterface.indexOf('ACE') >= 0) || (obj.AiuInfo[pidx].fnNativeInterface.indexOf('ACE5') >= 0) || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4" || obj.AiuInfo[pidx].fnNativeInterface == "AXI5") && obj.AiuInfo[pidx].useCache == 1)) {%>
        		event_out_if m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(<%=obj.AiuInfo[pidx].nativeClk%>dut_clk, <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn);
			<%}%>
			<% if (obj.AiuInfo[pidx].interfaces.userPlaceInt._SKIP_ == false || (typeof obj.AiuInfo[pidx].interfaces.memoryInt !== 'undefined')) { %>
        		ioaiu<%=io_idx%>_generic_if m_generic_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(<%=obj.AiuInfo[pidx].nativeClk%>dut_clk, <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn);
			<%}%>
			<%}%>
			<% io_idx++; %>
		<%}%>
	<%}%>
`ifdef USE_VIP_SNPS_CHI
    <% var chi_idx=0;
       var io_idx=0;
       for(var pidx = 0; pidx < initiatorAgents; pidx++) { %>
    <%  if(_child_blk[pidx].match('chiaiu')) { %>
	<% chi_idx++; %>
    <% } %>
    <% } %>

<%  if(chiaiu_idx>0) { %>
logic  svt_chi_if_clk [<%=chi_idx %> - 1:0] ;
logic  svt_chi_if_rstn [<%=chi_idx %> - 1:0] ;
<% } %>

    <% var chi_idx=0;
       var io_idx=0;
       for(var pidx = 0; pidx < initiatorAgents; pidx++) { %>
    <%  if(_child_blk[pidx].match('chiaiu')) { %>
        assign  svt_chi_if_clk[<%=chi_idx %>]  = <%=obj.AiuInfo[pidx].nativeClk%>dut_clk;
        assign  svt_chi_if_rstn[<%=chi_idx %>] = <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn; 
	<% chi_idx++; %>
    <% } %>
    <% } %>


 //CHI
<%  if(chiaiu_idx>0) { %>
 svt_chi_if m_svt_chi_if(
                         .rn_clk (svt_chi_if_clk),
                         .rn_resetn(svt_chi_if_rstn)
                        );
<% } %>
`endif

 svt_axi_if m_svt_axi_if(); //axi_vip_if


<% var mk = 0; var jk = 0; for(var j = 0; j < obj.AiuInfo.length; j++) { 
     if(obj.AiuInfo[j].fnNativeInterface.indexOf('CHI') >= 0) { %>
`ifdef USE_VIP_SNPS_CHI

            <%=_child_blkid[j]%>_connection_wrapper m_wrapper_chi_inst<%=j%>(m_chi_if_<%=obj.AiuInfo[j].strRtlNamePrefix%>, m_svt_chi_if.rn_if[<%=jk%>]);
           <%if((obj.AiuInfo[j].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[j].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[j].fnNativeInterface == 'CHI-E')) { %>
           initial begin
           // CONC-8094
             //force m_chi_if_<%=obj.AiuInfo[j].strRtlNamePrefix%>.sysco_req = 0;
             //wait(release_sysco_req==1);
             //release m_chi_if_<%=obj.AiuInfo[j].strRtlNamePrefix%>.sysco_req;
           end 
       <% jk = jk+1;%>
`endif
           <% } %>
<% } else { %>
        // Urvish - Not sure of aiu_NumCores parameter - maybe multiport related. Keeping legacy feature active i.e. aiu_NumCores[pidx]==1 
        // for aiu_NumCores[j]>1, need to update
	<% for(var n=0; n<aiu_NumCores[j]; n++) { %>
`ifdef USE_VIP_SNPS_AXI_MASTERS
        <%=_child_blkid[j]%>_connect_source2target_mst_if            m_wrapper_axi_inst<%=mk%>(m_svt_axi_if.master_if[<%=mk%>], ioaiu_if_<%=obj.AiuInfo[j].strRtlNamePrefix%>_<%=n%>); //wrapper(axi_vip_if, axi_inhouse_if)
        
<% let computedAxiInt; %>
       //clk
         assign m_svt_axi_if.master_if[<%=mk%>].aclk = <%=obj.AiuInfo[j].nativeClk%>dut_clk;
       //rst
         assign m_svt_axi_if.master_if[<%=mk%>].aresetn = <%=obj.AiuInfo[j].nativeClk%>soft_rstn;
         initial  begin
           m_svt_axi_if.set_master_common_clock_mode(0,<%=mk%>);
         end
          <%if(Array.isArray(obj.AiuInfo[j].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[j].interfaces.axiInt[0];
          }else{
               computedAxiInt = obj.AiuInfo[j].interfaces.axiInt;
          }%>
          <% if(((obj.AiuInfo[j].fnNativeInterface=="AXI5") || (obj.AiuInfo[j].fnNativeInterface=="ACELITE-E") ||(obj.AiuInfo[j].fnNativeInterface=="ACE5"))&& (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) { %>
          wire [7:0] <%=obj.AiuInfo[j].strRtlNamePrefix%>_async_adapter_err; 
         assign <%=obj.AiuInfo[j].strRtlNamePrefix%>_async_adapter_err = {m_wrapper_axi_inst<%=mk%>.async_adapter_err_snp_chnl , m_wrapper_axi_inst<%=mk%>.async_adapter_err};
          <% } %>
`endif
       <% mk = mk+1;%>
        <% } %>
 
<% } }%>
         assign m_svt_axi_if.common_aclk = <%=obj.AiuInfo[0].nativeClk%>dut_clk;
         uvm_event svt_axi_common_aclk_posedge_e,  svt_axi_common_aclk_negedge_e;        
         initial begin
            svt_axi_common_aclk_posedge_e = new("svt_axi_common_aclk_posedge_e");
            svt_axi_common_aclk_negedge_e = new("svt_axi_common_aclk_negedge_e");
            uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "svt_axi_common_aclk_posedge_e" ),
                                  .value(svt_axi_common_aclk_posedge_e));
            uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "svt_axi_common_aclk_negedge_e" ),
                                  .value(svt_axi_common_aclk_negedge_e));
         end

         always @(posedge m_svt_axi_if.common_aclk) begin
           svt_axi_common_aclk_posedge_e.trigger();
         end
         always @(posedge m_svt_axi_if.common_aclk) begin
           svt_axi_common_aclk_negedge_e.trigger();
         end

    <% var axi_slv_idx = 0;%>
    <% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { 
        var ridx = pidx + obj.nAIUs + obj.nDCEs;%>
	    //event_if m_event_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>();
        <%=_child_blkid[ridx]%>_stall_if <%=obj.DmiInfo[pidx].strRtlNamePrefix%>_sb_stall_if();
        dmi<%=pidx%>_axi_if  m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>(<%=obj.DmiInfo[pidx].unitClk[0]%>dut_clk, <%=obj.DmiInfo[pidx].unitClk[0]%>soft_rstn);
	irq_if m_irq_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>();
    
 <% if(obj.testBench=="emu"){ %>
        dmi<%=pidx%>_tt_if m_tt_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>(); //Added DH 
 
      <%}%>
<% if (obj.DmiInfo[pidx].interfaces.userPlaceInt._SKIP_ == false || (typeof obj.DmiInfo[pidx].interfaces.memoryInt !== 'undefined')) { %>
        dmi<%=pidx%>_generic_if m_generic_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>(<%=obj.DmiInfo[pidx].unitClk[0]%>dut_clk, <%=obj.DmiInfo[pidx].unitClk[0]%>soft_rstn);
<% } %>
`ifdef USE_VIP_SNPS_AXI_SLAVES
        <%=_child_blkid[ridx]%>_connect_source2target_slv_if            m_wrapper_axi_inst_<%=_child_blkid[ridx]%>( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>,  m_svt_axi_if.slave_if[<%=axi_slv_idx%>]); //wrapper(axi_vip_if, axi_inhouse_if)
        assign m_svt_axi_if.slave_if[<%=axi_slv_idx%>].aclk = <%=obj.DmiInfo[pidx].unitClk[0]%>dut_clk;
        assign m_svt_axi_if.slave_if[<%=axi_slv_idx%>].aresetn  = <%=obj.DmiInfo[pidx].unitClk[0]%>soft_rstn;
        initial  begin
          m_svt_axi_if.set_slave_common_clock_mode(0,<%=axi_slv_idx%>);
        end
        <% axi_slv_idx = axi_slv_idx + 1;%>
  
`endif // `ifdef USE_VIP_SNPS_AXI_SLAVES
    <% } %>
    <%for (let idx=0; idx < obj.nCHIs; idx++) {%>
        chi_aiu_dut_probe_if chiaiu<%=idx%>_probe_vif(<%=obj.AiuInfo[idx].unitClk[0]%>dut_clk, <%=obj.AiuInfo[idx].unitClk[0]%>soft_rstn);
    <%}%>

    <% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { 
        var ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;%>
	    //event_if m_event_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>();
        <%=_child_blkid[ridx]%>_stall_if <%=obj.DiiInfo[pidx].strRtlNamePrefix%>_sb_stall_if();
    <% if (obj.DiiInfo[pidx].configuration == 0) { %>  					       
        dii<%=pidx%>_axi_if      m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>(<%=obj.DiiInfo[pidx].unitClk[0]%>dut_clk, <%=obj.DiiInfo[pidx].unitClk[0]%>soft_rstn);
        dii<%=pidx%>_dii_rtl_if  m_rtl_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>(<%=obj.DiiInfo[pidx].unitClk[0]%>dut_clk, <%=obj.DiiInfo[pidx].unitClk[0]%>soft_rstn);
	irq_if m_irq_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>();
<% if (obj.DiiInfo[pidx].interfaces.userPlaceInt._SKIP_ == false || (typeof obj.DiiInfo[pidx].interfaces.memoryInt !== 'undefined')) { %>
        dii<%=pidx%>_generic_if  m_generic_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>(<%=obj.DiiInfo[pidx].unitClk[0]%>dut_clk, <%=obj.DiiInfo[pidx].unitClk[0]%>soft_rstn);
<% } %>
`ifdef USE_VIP_SNPS_AXI_SLAVES
        <%=_child_blkid[ridx]%>_connect_source2target_slv_if            m_wrapper_axi_inst_<%=_child_blkid[ridx]%>(m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>, m_svt_axi_if.slave_if[<%=axi_slv_idx%>]); //wrapper(axi_vip_if, axi_inhouse_if)
        assign m_svt_axi_if.slave_if[<%=axi_slv_idx%>].aclk = <%=obj.DiiInfo[pidx].unitClk[0]%>dut_clk;
        assign m_svt_axi_if.slave_if[<%=axi_slv_idx%>].aresetn  = <%=obj.DiiInfo[pidx].unitClk[0]%>soft_rstn;
        initial  begin
          m_svt_axi_if.set_slave_common_clock_mode(0,<%=axi_slv_idx%>);
        end
        <% axi_slv_idx = axi_slv_idx + 1;%>
`endif // `ifdef USE_VIP_SNPS_AXI_SLAVES

    <% } else { %> 
	irq_if m_irq_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>();
    <% } } %>
    <% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { 
        var ridx = pidx + obj.nAIUs; %>
        <%=_child_blkid[ridx]%>_stall_if <%=obj.DceInfo[pidx].strRtlNamePrefix%>_sb_stall_if();
        dce<%=pidx%>_probe_if  dce<%=pidx%>_probe_vif(<%=obj.DceInfo[pidx].unitClk[0]%>dut_clk, <%=obj.DceInfo[pidx].unitClk[0]%>soft_rstn);
	irq_if m_irq_if_<%=obj.DceInfo[pidx].strRtlNamePrefix%>();
<% if (typeof obj.DceInfo[pidx].interfaces.memoryInt !== 'undefined') { %>
        dce<%=pidx%>_generic_if  m_generic_<%=obj.DceInfo[pidx].strRtlNamePrefix%>(<%=obj.DceInfo[pidx].unitClk[0]%>dut_clk, <%=obj.DceInfo[pidx].unitClk[0]%>soft_rstn);
<% } %>
    <% } %>
    

    <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { 
        var ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs; %>
        <%=_child_blkid[ridx]%>_stall_if <%=obj.DveInfo[pidx].strRtlNamePrefix%>_sb_stall_if();
        dve<%=pidx%>_apb_if  dve<%=pidx%>_m_apb_if(<%=obj.DveInfo[pidx].unitClk[0]%>dut_clk, <%=obj.DveInfo[pidx].unitClk[0]%>soft_rstn);
        assign dve<%=pidx%>_m_apb_if.IS_IF_A_MONITOR=1;
	irq_if m_irq_if_<%=obj.DveInfo[pidx].strRtlNamePrefix%>();
<% if (typeof obj.DveInfo[pidx].interfaces.memoryInt !== 'undefined') { %>
        dve<%=pidx%>_generic_if  m_generic_<%=obj.DveInfo[pidx].strRtlNamePrefix%>(<%=obj.DveInfo[pidx].unitClk[0]%>dut_clk, <%=obj.DveInfo[pidx].unitClk[0]%>soft_rstn);
<% } %>
        dve<%=pidx%>_clock_counter_if m_<%=obj.DveInfo[pidx].strRtlNamePrefix%>_clock_counter_if(<%=obj.DveInfo[pidx].unitClk[0]%>dut_clk, <%=obj.DveInfo[pidx].unitClk[0]%>soft_rstn);
    <% } %>

    // FIXME - assuming all apb interfaces are the same size, use definition from ioaiu_apb_if
    <% if(obj.useResiliency == 1) { %>
        apb_debug_apb_if   m_apb_fsc(<%=obj.FscInfo.unitClk[0]%>dut_clk, soft_rstn);
        fault_if        m_master_fsc();
 <% // extract interface name  
var itf_dbg_pin_name ="itf_not_found";
var obj_debug_itf = obj.ariaObj.PortList.find(item => item.rtlSignal === "ncore_en_debug_bist_pin");
if (obj_debug_itf !== undefined) { 
     itf_dbg_pin_name = obj_debug_itf.dvSignal.split('.',1); // "m_pin_if_fsc.pin" => extract first part "m_pin_if_fsc" 
      }
// end extract interface name %>
        bist_if         <%=itf_dbg_pin_name%>();

    <% } %>
    <% if(obj.DebugApbInfo.length > 0) { %>
       apb_debug_apb_if  m_apb_debug_ncore_debug_atu(<%=obj.DebugApbInfo[0].unitClk[0]%>dut_clk, soft_rstn);
`ifdef USE_VIP_SNPS_APB   
        svt_apb_if m_svt_apb_if();
        assign m_svt_apb_if.pclk = <%=obj.DebugApbInfo[0].unitClk[0]%>dut_clk;
        assign m_svt_apb_if.presetn = soft_rstn;
        connection_wrapper_to_svt_apb_if m_connection_wrapper_to_svt_apb_if (m_apb_debug_ncore_debug_atu, m_svt_apb_if);
//`else
//        apb_debug_apb_if  m_apb_debug_ncore_debug_atu(<%=obj.DebugApbInfo[0].unitClk[0]%>dut_clk, soft_rstn);
`endif
    <% } %>

<% if((obj.INHOUSE_APB_VIP !== undefined) && (obj.FULL_SYS_TB !== undefined)) { %>
<%  if((obj.fullProject.concerto.user.misc.csrAccess.protocol == "APB") && ((obj.INHOUSE_APB_VIP !== undefined) || (obj.INHOUSE_OCP_VIP !== undefined))) { %>
  assign apb_if.clk = <%=obj.ClockPorts.cstiPorts%>;
  assign apb_if.rst_n = <%=obj.ResetPorts.cstiPorts%>;
<% } %>
<% } %>			

// [Priyanshu] strProjectName is fsys_config1 in json file, so chanaged the if condition
<% if(obj.testBench=="fsys"){ %> 
<% if (obj.useRtlPrefix == 1) { %>
    <%=obj.strProjectName%>_gen_wrapper dut (
<% } else { %>
     gen_wrapper dut (
<% }
   for(var port=0; port<obj.ariaObj.PortList.length; port++) { %>
                .<%=obj.ariaObj.PortList[port].rtlSignal%>  (<%=obj.ariaObj.PortList[port].dvSignal%>) <% if(port < (obj.ariaObj.PortList.length-1)) {%>,<%}%>
   <% } %>
   );
   <% } %>
<% if(obj.testBench=="emu"){ %>
<% var chi_idx=0;
   var io_idx=0;   
   for(var pidx = 0; pidx < initiatorAgents; pidx++) { %>


<%   if(_child_blk[pidx].match('chiaiu')) { %>
       assign   m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_dat_flit = ncore_hdl_top.m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_dat_flit; 
       assign   m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_dat_flitv = ncore_hdl_top.m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_dat_flitv;
       assign   m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_rsp_flitv = ncore_hdl_top.m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_rsp_flitv;
       assign   m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_rsp_flit = ncore_hdl_top.m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_rsp_flit;
       assign   m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_snp_flit = ncore_hdl_top.m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_snp_flit;
       assign   m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_snp_flitv = ncore_hdl_top.m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_snp_flitv;
       assign   m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_link_active_ack = ncore_hdl_top.m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_link_active_ack;
       assign   m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_link_active_req = ncore_hdl_top.m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_link_active_req;
<%   } %>
<% } %>
<% } %>
<% if(obj.testBench=="emu") { %>
         
         // chi_v2_parameters_parametrised
         
    <% var idx=0; obj.AiuInfo.forEach(function(e, pidx, array) {%>
    <%       if((e.fnNativeInterface == 'CHI-A')||(e.fnNativeInterface == 'CHI-B')||(e.fnNativeInterface == 'CHI-E')) {%>
     
    <% idx++ } %>
    <%} )%>

initial 
     begin
         abc1 = new();
         abc1.set_myvif(ncore_hdl_top.concerto_phys_if);  // Handle to interface at hdl side
         mgc_rsp = new();
         mgc_rsp.set_vif(ncore_hdl_top.mgc_resp_if);  // Handle to interface at hdl side
         //$display("Before CHECK");
        // mgc_rsp.getXactorResp;  // Handle to interface at hdl side
         //$display("CHECK");
         $dumpon;
         $dumpfile("wavedump.vcd");
         $dumpvar(2,tb_top);
         // Bind chi-b parametrised
         <% var idx=0; obj.AiuInfo.forEach(function(e, pidx, array) {%>
         <%       if((e.fnNativeInterface == 'CHI-A')||(e.fnNativeInterface == 'CHI-B')||(e.fnNativeInterface == 'CHI-E')) {%>
                      mgc_chi_rn_if_<%=idx%>.init("ncore_hdl_top.mstr_chi_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>");
         <%  idx++      } %>
           <%} )%>

 // Turn on/off debug Parametrised
         <% var idx=0; obj.AiuInfo.forEach(function(e, pidx, array) {%>
         <% if((e.fnNativeInterface == 'CHI-A')||(e.fnNativeInterface == 'CHI-B')||(e.fnNativeInterface == 'CHI-E')) {%>
               mgc_chi_rn_if_<%=idx%>.set_cfg_debug(0);
    <% idx++ } %>
         <%   }) %>
<% var idx=0; obj.AiuInfo.forEach(function(e, pidx, array){%>
         <% if(e.fnNativeInterface == 'ACE') { %>
         
           //   mgc_ace_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.init("ncore_hdl_top.mstr_axi_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>");  
               mgc_ace_m_if_<%=_child_blkid[pidx]%>.init("ncore_hdl_top.mstr_axi_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"); //Added DH 29-11 
         
         <% } else if((e.fnNativeInterface == "ACE-LITE") || (e.fnNativeInterface == "ACELITE-E" )){ %>
         
                mgc_acelite_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.init("ncore_hdl_top.mstr_axi_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>");  
         
         <% } else if (!((e.fnNativeInterface == "ACE")||(e.fnNativeInterface == "ACE-LITE")||(e.fnNativeInterface == "ACELITE-E" )||(e.fnNativeInterface == 'CHI-A')||(e.fnNativeInterface == 'CHI-B')||(e.fnNativeInterface == 'CHI-E')))  { %>
         
                   <% if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) { %>
                       <% aiu_axiIntLen[pidx] = obj.AiuInfo[pidx].interfaces.axiInt.length; %>
                       <% for (var i=0; i<aiu_axiIntLen[pidx]; i++) { %>
                           mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.init("ncore_hdl_top.mstr_axi_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>");
					   <% } %>
				  <% } else { %>
				  mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.init("ncore_hdl_top.mstr_axi_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>");
				  <% } %>
         <% } %>
         <% }) %>
     // Turn on/off debug parametrised
         <% var idx=0; obj.AiuInfo.forEach(function(e, pidx, array) {%>
         <% if(e.fnNativeInterface == 'ACE') { %>
         
              //  mgc_ace_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.set_cfg_debug(0);
               mgc_ace_m_if_<%=_child_blkid[pidx]%>.set_cfg_debug(0);                            // Added DH 29-11
         
         <% } else if((e.fnNativeInterface == "ACE-LITE") || (e.fnNativeInterface == "ACELITE-E" )) { %>
         
              mgc_acelite_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.set_cfg_debug(0);
         
         <% } else if (!((e.fnNativeInterface == "ACE")||(e.fnNativeInterface == "ACE-LITE")||(e.fnNativeInterface == "ACELITE-E" )||(e.fnNativeInterface == 'CHI-A')||(e.fnNativeInterface == 'CHI-B')||(e.fnNativeInterface == 'CHI-E')))  { %>
         
                   <% if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) { %>
                       <% aiu_axiIntLen[pidx] = obj.AiuInfo[pidx].interfaces.axiInt.length; %>
                       <% for (var i=0; i<aiu_axiIntLen[pidx]; i++) { %>
                           mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.set_cfg_debug(0);
					   <% } %>
				  <% } else { %>
                      mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.set_cfg_debug(0);
				  <% } %>
         
         <% } %>
         
         <% }) %>

  //$display($time,"===========================================================");  
         
    //assign source id parameterised
         <% var idx=0; obj.AiuInfo.forEach(function(e, pidx, array) {%>
         
            <% if(e.fnNativeInterfacce == 'CHI-A' || e.fnNativeInterface == 'CHI-B'||(e.fnNativeInterface == 'CHI-E')) {%>
                 mgc_chi_rn_if_<%=idx%>.set_cfg_rn_src_id (<%=idx%>); 
               <% idx++ } %>
           <%} )%>
         
           //$display($time,"TB_TOP: before_wait for Reset OK");
            // Wait for Reset CHI Parametrised
         <% var idx=0; obj.AiuInfo.forEach(function(e, pidx, array) {%>
         
        <% if((e.fnNativeInterface == 'CHI-A')||(e.fnNativeInterface == 'CHI-B')||(e.fnNativeInterface == 'CHI-E'))  {%>
           mgc_chi_rn_if_<%=idx%>.wait_for_reset();
           //$display($time,"TB_TOP : wait for Reset OK_<%=idx%>");
         <% idx++ } %>
         <%} )%>
         
         
         
         <% var idx=0; obj.AiuInfo.forEach(function(e, pidx, array){%>
         <% if(e.fnNativeInterface == 'ACE') { %>
         
               //  mgc_ace_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.wait_for_reset();
               mgc_ace_m_if_<%=_child_blkid[pidx]%>.wait_for_reset();
             //$display("SPACE_<%=_child_blkid[pidx]%>");
         
         <% } else if((e.fnNativeInterface == "ACE-LITE") || (e.fnNativeInterface == "ACELITE-E" )) { %>
         
              mgc_acelite_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.wait_for_reset();
         
         <% } else if (!((e.fnNativeInterface == "ACE")||(e.fnNativeInterface == "ACE-LITE")||(e.fnNativeInterface == "ACELITE-E" )||(e.fnNativeInterface == 'CHI-A')||(e.fnNativeInterface == 'CHI-B')||(e.fnNativeInterface == 'CHI-E')))  { %>
         
                   <% if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) { %>
                       <% aiu_axiIntLen[pidx] = obj.AiuInfo[pidx].interfaces.axiInt.length; %>
                       <% for (var i=0; i<aiu_axiIntLen[pidx]; i++) { %>
                           mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.wait_for_reset();
					   <% } %>
				  <% } else { %>
                      mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.wait_for_reset();
				  <% } %>
         
         <% } %>
         
         <% }) %> 
   
        mgc_ace_m_if_ioaiu0.wait_for_clk(10);	
         
          // mgc_ace_m_if_<%=_child_blkid[pidx]%>.wait_for_clk(10);
         <% var idx=0; obj.AiuInfo.forEach(function(e, pidx, array) {%>
         <% if(e.fnNativeInterface == 'ACE') { %>
         
         // mgc_ace_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.wait_for_clk(10);
          mgc_ace_m_if_<%=_child_blkid[pidx]%>.wait_for_clk(10);
             //$display("CLOCK_<%=_child_blkid[pidx]%>");
         
         <% } else if((e.fnNativeInterface == "ACE-LITE") || (e.fnNativeInterface == "ACELITE-E" )) { %>
         
          mgc_acelite_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.wait_for_clk(10);
         
         <% } else if (!((e.fnNativeInterface == "ACE")||(e.fnNativeInterface == "ACE-LITE")||(e.fnNativeInterface == "ACELITE-E" )||(e.fnNativeInterface == 'CHI-A')||(e.fnNativeInterface == 'CHI-B')||(e.fnNativeInterface == 'CHI-E')))  { %>
         
                   <% if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) { %>
                       <% aiu_axiIntLen[pidx] = obj.AiuInfo[pidx].interfaces.axiInt.length; %>
                       <% for (var i=0; i<aiu_axiIntLen[pidx]; i++) { %>
                           mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.wait_for_clk(10);
					   <% } %>
				  <% } else { %>
                      mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.wait_for_clk(10);
				  <% } %>
         
         <% } %>
         
         <%   }) %>

 end//initial

<% } %>
<%
var attvec_width = 0;

obj.DceInfo.forEach(function(bundle) {
    if (bundle.nAttCtrlEntries > attvec_width) {
		attvec_width = bundle.nAttCtrlEntries;
	}
});
%>
<% if (obj.testBench != "emu" ) { %> 
//////////////////////////////////////////
//Assignement stall_if interface for ioaiu
/////////////////////////////////////////
<% for(var pidx = 0; pidx < initiatorAgents; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')&& (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
	<% for(var n=0; n<aiu_NumCores[pidx]; n++) { %>
            <% var OCN=obj.AiuInfo[pidx].cmpInfo.nOttCtrlEntries/aiu_NumCores[pidx]%>
	    <%if(obj.AiuInfo[pidx].hierPath && obj.AiuInfo[pidx].hierPath !== ''){%>
                <%if(obj.AiuInfo[pidx].orderedWriteObservation == true){%>
    	        assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.snp_req_vld   = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.w_snp_req_valid & 
                                                                                                     tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.n_snp_req_ready;
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.snp_req_addr = {tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.w_snp_req_security,
											             tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.w_snp_req_addr};
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.snp_req_match = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.snp_req_match[<%=OCN-1%>:0];
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_owned_st  = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_owned[<%=OCN-1%>:0];
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_oldest_st = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_oldest[<%=OCN-1%>:0];
                <% } %>
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_entries   = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_val[<%=OCN-1%>:0];
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.TransActv= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.t_pma_busy;
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_security= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_security[<%=OCN-1%>:0];
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_prot= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_pr[<%=OCN-1%>:0];
            <% } else {%>
                <%if(obj.AiuInfo[pidx].orderedWriteObservation == true){%>
    	        assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.snp_req_vld   = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.w_snp_req_valid & 
                                                                                                     tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.n_snp_req_ready;
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.snp_req_addr = {tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.w_snp_req_security,
											             tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.w_snp_req_addr};
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.snp_req_match = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.snp_req_match[<%=OCN-1%>:0];
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_owned_st  = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_owned[<%=OCN-1%>:0];
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_oldest_st = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_oldest[<%=OCN-1%>:0];
                <% } %>
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_entries   = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_val[<%=OCN-1%>:0];
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.TransActv= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.t_pma_busy;
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_security= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_security[<%=OCN-1%>:0];
                assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_prot= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_pr[<%=OCN-1%>:0];
            <% } %>
            <%for(var j = 0; j < OCN; j++){%>
	        <%if(obj.AiuInfo[pidx].hierPath && obj.AiuInfo[pidx].hierPath !== ''){%>
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_address[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_addr[<%=j%>];
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_id[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_id[<%=j%>];
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_user[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_user[<%=j%>];
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_write[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_write[<%=j%>];
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_evict[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.t_oc_evict[<%=j%>];
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_qos[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_qos[<%=j%>];
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_cache[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_cache[<%=j%>];
                <% } else {%>
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_address[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_addr[<%=j%>];
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_id[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_id[<%=j%>];
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_user[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_user[<%=j%>];
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_write[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_write[<%=j%>];
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_evict[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.t_oc_evict[<%=j%>];
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_qos[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_qos[<%=j%>];
                    assign u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>.ott_cache[<%=j%>]= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core<%=n%>.ioaiu_control.q_oc_cache[<%=j%>];
                <% } %>
            <% } %>
        <% } %>
    <% } %>
<% } %>


<% var io_idx=0;   
for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) {%>
    <%if(obj.AiuInfo[pidx].hierPath && obj.AiuInfo[pidx].hierPath !== ''){%>
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.clk      =   <%=obj.AiuInfo[pidx].nativeClk%>dut_clk;
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.rst_n    =   <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn;
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.ott_busy = 0;
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.AiuDce_connectivity_vec = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.uSysIdInt_dce_connectivity;
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.AiuDmi_connectivity_vec = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.uSysIdInt_dmi_connectivity;
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.AiuDii_connectivity_vec = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.uSysIdInt_dii_connectivity;
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.AiuConnectedDceFunitId = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.uSysIdInt_connected_dce_connectivity;
        <% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %> 
            assign m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_sender_master.clk = <%=obj.AiuInfo[pidx].nativeClk%>dut_clk;
            assign m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_sender_master.rst_n = <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn;
        <% } %>
         
        <% if (obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false) { %>
            assign m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_receiver_slave.clk = <%=obj.AiuInfo[pidx].nativeClk%>dut_clk;
            assign m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_receiver_slave.rst_n = <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn;
        <% } %>        
            
        <%for (var n=0; n<aiu_NumCores[pidx]; n++) { %>


            assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.clk = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.clk_clk;
            assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.master_cnt_enable = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.trigger_trigger;
            assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.rst_n = soft_rstn; // To be updated
            // SMI TX
            <%for (var i = 0; i < obj.AiuInfo[pidx].smiPortParams.tx.length; i++) { %>
                assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.smi_tx<%=i%>_valid = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.<%=obj.AiuInfo[pidx].interfaces.smiTxInt[i].name %>ndp_msg_valid ;       
                assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.smi_tx<%=i%>_ready = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.<%=obj.AiuInfo[pidx].interfaces.smiTxInt[i].name %>ndp_msg_ready  ;      
            <% } %>
            // SMI RX
            <%for (var i = 0; i < obj.AiuInfo[pidx].smiPortParams.rx.length; i++) { %>
                assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.smi_rx<%=i%>_valid = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.<%=obj.AiuInfo[pidx].interfaces.smiRxInt[i].name%>ndp_msg_valid;
                assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.smi_rx<%=i%>_ready = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.<%=obj.AiuInfo[pidx].interfaces.smiRxInt[i].name%>ndp_msg_ready;
            <% } %>
        <% } io_idx++; %>
    <% } else { %>
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.clk      =   <%=obj.AiuInfo[pidx].nativeClk%>dut_clk;
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.rst_n    =   <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn;
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.ott_busy = 0;
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.AiuDce_connectivity_vec = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_uSysIdInt_dce_connectivity;
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.AiuDmi_connectivity_vec = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_uSysIdInt_dmi_connectivity;
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.AiuDii_connectivity_vec = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_uSysIdInt_dii_connectivity;
        assign  <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if.AiuConnectedDceFunitId = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_uSysIdInt_connected_dce_connectivity;
        <% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %> 
            assign m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_sender_master.clk = <%=obj.AiuInfo[pidx].nativeClk%>dut_clk;
            assign m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_sender_master.rst_n = <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn;
        <% } %>
         
        <% if (obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false) { %>
            assign m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_receiver_slave.clk = <%=obj.AiuInfo[pidx].nativeClk%>dut_clk;
            assign m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_receiver_slave.rst_n = <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn;
        <% } %>        
            
        <%for (var n=0; n<aiu_NumCores[pidx]; n++) { %>

<%if(obj.AiuInfo[pidx].hierPath && obj.AiuInfo[pidx].hierPath !== ''){%>
            assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.clk = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.clk_clk;
            assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.master_cnt_enable = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.trigger_trigger;
            assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.rst_n = soft_rstn; // To be updated
            // SMI TX
            <%for (var i = 0; i < obj.AiuInfo[pidx].smiPortParams.tx.length; i++) { %>
                assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.smi_tx<%=i%>_valid = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.<%=obj.AiuInfo[pidx].interfaces.smiTxInt[i].name %>ndp_msg_valid ;       
                assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.smi_tx<%=i%>_ready = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.<%=obj.AiuInfo[pidx].interfaces.smiTxInt[i].name %>ndp_msg_ready  ;      
            <% } %>
            // SMI RX
            <%for (var i = 0; i < obj.AiuInfo[pidx].smiPortParams.rx.length; i++) { %>
                assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.smi_rx<%=i%>_valid = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.<%=obj.AiuInfo[pidx].interfaces.smiRxInt[i].name%>ndp_msg_valid;
                assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.smi_rx<%=i%>_ready = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.<%=obj.AiuInfo[pidx].interfaces.smiRxInt[i].name%>ndp_msg_ready;
            <% } %>
<% } else {%>
            assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.clk = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.clk_clk;
            assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.master_cnt_enable = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.trigger_trigger;
            assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.rst_n = soft_rstn; // To be updated
            // SMI TX
            <%for (var i = 0; i < obj.AiuInfo[pidx].smiPortParams.tx.length; i++) { %>
                assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.smi_tx<%=i%>_valid = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.<%=obj.AiuInfo[pidx].interfaces.smiTxInt[i].name %>ndp_msg_valid ;       
                assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.smi_tx<%=i%>_ready = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.<%=obj.AiuInfo[pidx].interfaces.smiTxInt[i].name %>ndp_msg_ready  ;      
            <% } %>
            // SMI RX
            <%for (var i = 0; i < obj.AiuInfo[pidx].smiPortParams.rx.length; i++) { %>
                assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.smi_rx<%=i%>_valid = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.<%=obj.AiuInfo[pidx].interfaces.smiRxInt[i].name%>ndp_msg_valid;
                assign <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=n%>_sb_stall_if.smi_rx<%=i%>_ready = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.<%=obj.AiuInfo[pidx].interfaces.smiRxInt[i].name%>ndp_msg_ready;
            <% } %>
<% } %>
        <% } io_idx++; %>
    <% } %>	    
<% } %>

<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
// stall_if use by perf monitor

<%if(obj.DmiInfo[pidx].hierPath && obj.DmiInfo[pidx].hierPath !== ''){%>
     assign <%=obj.DmiInfo[pidx].strRtlNamePrefix%>_sb_stall_if.master_cnt_enable = tb_top.dut.<%=obj.DmiInfo[pidx].instancePath%>.trigger_trigger;
     assign <%=obj.DmiInfo[pidx].strRtlNamePrefix%>_sb_stall_if.clk = tb_top.dut.<%=obj.DmiInfo[pidx].instancePath%>.clk_clk;
<%}else{%>
     assign <%=obj.DmiInfo[pidx].strRtlNamePrefix%>_sb_stall_if.master_cnt_enable = tb_top.dut.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.trigger_trigger;
     assign <%=obj.DmiInfo[pidx].strRtlNamePrefix%>_sb_stall_if.clk = tb_top.dut.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.clk_clk;
<%}%>
assign <%=obj.DmiInfo[pidx].strRtlNamePrefix%>_sb_stall_if.rst_n = soft_rstn; 
<%}%>
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
<%if(obj.DiiInfo[pidx].hierPath && obj.DiiInfo[pidx].hierPath !== ''){%>
// stall_if use by perf monitor
assign <%=obj.DiiInfo[pidx].strRtlNamePrefix%>_sb_stall_if.master_cnt_enable = tb_top.dut.<%=obj.DiiInfo[pidx].instancePath%>.trigger_trigger;
assign <%=obj.DiiInfo[pidx].strRtlNamePrefix%>_sb_stall_if.clk = tb_top.dut.<%=obj.DiiInfo[pidx].instancePath%>.clk_clk;
assign <%=obj.DiiInfo[pidx].strRtlNamePrefix%>_sb_stall_if.rst_n = soft_rstn; 
// DII event_if 
<% if (obj.DiiInfo[pidx].configuration == 0) { %>  
assign m_rtl_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.event_in_ack = tb_top.dut.<%=obj.DiiInfo[pidx].instancePath%>.u_dii_unit.u_sys_evt_coh_concerto.event_in_ack; 
assign m_rtl_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.event_in_req = tb_top.dut.<%=obj.DiiInfo[pidx].instancePath%>.u_dii_unit.u_sys_evt_coh_concerto.event_in_req;
<%}%>
<% } else {%>
// stall_if use by perf monitor
assign <%=obj.DiiInfo[pidx].strRtlNamePrefix%>_sb_stall_if.master_cnt_enable = tb_top.dut.<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.trigger_trigger;
assign <%=obj.DiiInfo[pidx].strRtlNamePrefix%>_sb_stall_if.clk = tb_top.dut.<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.clk_clk;
assign <%=obj.DiiInfo[pidx].strRtlNamePrefix%>_sb_stall_if.rst_n = soft_rstn; 
// DII event_if 
<% if (obj.DiiInfo[pidx].configuration == 0) { %>  
assign m_rtl_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.event_in_ack = tb_top.dut.<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.u_dii_unit.u_sys_evt_coh_concerto.event_in_ack; 
assign m_rtl_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.event_in_req = tb_top.dut.<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.u_dii_unit.u_sys_evt_coh_concerto.event_in_req;
<%}%>
<% } %>
<%}%>
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
// stall_if use by perf monitor
<%if(obj.DceInfo[pidx].hierPath && obj.DceInfo[pidx].hierPath !== ''){%>
     assign <%=obj.DceInfo[pidx].strRtlNamePrefix%>_sb_stall_if.master_cnt_enable = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.trigger_trigger;
     assign <%=obj.DceInfo[pidx].strRtlNamePrefix%>_sb_stall_if.clk = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.clk_clk;
<%}else{%>
     assign <%=obj.DceInfo[pidx].strRtlNamePrefix%>_sb_stall_if.master_cnt_enable = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.trigger_trigger;
     assign <%=obj.DceInfo[pidx].strRtlNamePrefix%>_sb_stall_if.clk = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.clk_clk;
<%}%>
assign <%=obj.DceInfo[pidx].strRtlNamePrefix%>_sb_stall_if.rst_n = soft_rstn; 
//these RTL signals need to be probed for QOS testing
<%if(obj.DceInfo[pidx].hierPath && obj.DceInfo[pidx].hierPath !== ''){%>

  <%
  var ASILB  = 0; // (obj.useResiliency & obj.DceInfo[pidx].ResilienceInfo.enableUnitDuplication) ? 0 : 1;
  var hier_path_dce_csr  = '';
  var hier_path_dce_cmux  = '';
  var hier_path_dce_sbcmdreqfifo  = '';
  var hier_path_dce_sb  = '';
  if (!ASILB) {
    hier_path_dce_csr = 'dce_func_unit.u_csr';
    hier_path_dce_cmux = 'dce_func_unit.dce_conc_mux';
    hier_path_dce_sbcmdreqfifo = 'dce_func_unit.skid_buf_cmd_req_fifo';
    hier_path_dce_sb = 'dce_func_unit.dce_skid_buffer';
  } else {
    hier_path_dce_csr = 'u_csr';
    hier_path_dce_cmux = 'dce_conc_mux';
    hier_path_dce_sbcmdreqfifo = 'skid_buf_cmd_req_fifo';
    hier_path_dce_sb = 'dce_skid_buffer';
  }
  %>

assign dce<%=pidx%>_probe_vif.sb_cmdrsp_vld    = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sb%>.f0_cmd_rsp_valid;
assign dce<%=pidx%>_probe_vif.sb_cmdrsp_rdy    = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sb%>.f0_cmd_rsp_ready;
assign dce<%=pidx%>_probe_vif.sb_cmdrsp_tgtid  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sb%>.f0_cmd_rsp_target_id;
assign dce<%=pidx%>_probe_vif.sb_cmdrsp_rmsgid = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sb%>.f0_cmd_rsp_r_message_id;

//RTL signals to update Snoop enable registers in DCE
assign dce<%=pidx%>_probe_vif.sb_sysrsp_vld    = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_cmux%>.sys_rsp_tx_valid;
assign dce<%=pidx%>_probe_vif.sb_sysrsp_rdy    = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_cmux%>.sys_rsp_tx_ready;
assign dce<%=pidx%>_probe_vif.sb_sysrsp_tgtid  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_cmux%>.sys_rsp_tx_target_id;

//RTL signals needed to grab output of conc_mux for QOS testing in DCE -CONC-7215
//due to cmdreq backpressure, SMI_Time != CMux_Time
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_vld  	  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_cmux%>.cmd_req_valid;
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_rdy  	  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_cmux%>.cmd_req_ready;
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_addr 	  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_cmux%>.cmd_req_addr;
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_ns      = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_cmux%>.cmd_req_ns;
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_iid  	  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_cmux%>.cmd_req_initiator_id;
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_cm_type = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_cmux%>.cmd_req_cm_type;
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_msg_id  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_cmux%>.cmd_req_message_id;

assign dce<%=pidx%>_probe_vif.arb_cmdreq_vld  	  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_valid;
assign dce<%=pidx%>_probe_vif.arb_cmdreq_rdy  	  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_ready;
assign dce<%=pidx%>_probe_vif.arb_cmdreq_addr 	  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_addr;
assign dce<%=pidx%>_probe_vif.arb_cmdreq_ns      = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_ns;
assign dce<%=pidx%>_probe_vif.arb_cmdreq_iid  	  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_initiator_id;
assign dce<%=pidx%>_probe_vif.arb_cmdreq_cm_type = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_cm_type;
assign dce<%=pidx%>_probe_vif.arb_cmdreq_msg_id  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_message_id;
`ifndef VCS
if (addrMgrConst::get_highest_qos() != 0) begin
assign dce<%=pidx%>_probe_vif.sb_starv_mode	   = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.starv_mode;
end
`else // `ifndef VCS
<%if(obj.DceInfo[pidx].QosInfo && (obj.DceInfo[pidx].QosInfo.qosMap.length > 0)){%>
assign dce<%=pidx%>_probe_vif.sb_starv_mode	   = (addrMgrConst::get_highest_qos() != 0) ? tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.starv_mode : dce<%=pidx%>_probe_vif.sb_starv_mode;
<% } %>
`endif // `ifndef VCS ... `else ... 

//cmd req interface (dce_dm_0.v)
assign dce<%=pidx%>_probe_vif.cmd_req_vld           = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_req_valid_i; 
assign dce<%=pidx%>_probe_vif.cmd_req_rdy           = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_req_ready_o; 
assign dce<%=pidx%>_probe_vif.cmd_req_addr          = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_req_addr_i; 
assign dce<%=pidx%>_probe_vif.cmd_req_ns            = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_req_ns_i; 
assign dce<%=pidx%>_probe_vif.cmd_req_type          = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_req_type_i;
assign dce<%=pidx%>_probe_vif.cmd_req_iid           = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_req_iid_i;
assign dce<%=pidx%>_probe_vif.cmd_req_sid           = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_req_sid_i;
assign dce<%=pidx%>_probe_vif.cmd_req_att_vec       = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_req_att_vec_i;
assign dce<%=pidx%>_probe_vif.cmd_req_wakeup        = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_req_wakeup_i;
assign dce<%=pidx%>_probe_vif.cmd_req_msg_id        = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_sbcmdreqfifo%>.pop_message_id;
assign dce<%=pidx%>_probe_vif.cmd_req1_busy_vec     = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_req1_busy_vec_i;
assign dce<%=pidx%>_probe_vif.cmd_req1_filter_num   = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_req1_filter_num_o;
assign dce<%=pidx%>_probe_vif.cmd_req1_alloc        = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_req1_alloc_i;
assign dce<%=pidx%>_probe_vif.cmd_req1_cancel       = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_req1_cancel_i;

//upd req interface (dce_dm_0.v)
assign dce<%=pidx%>_probe_vif.upd_req_vld         = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_upd_req_valid_i;
assign dce<%=pidx%>_probe_vif.upd_req_rdy         = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_upd_req_ready_o;
assign dce<%=pidx%>_probe_vif.upd_req_addr        = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_upd_req_addr_i;
assign dce<%=pidx%>_probe_vif.upd_req_ns          = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_upd_req_ns_i;
assign dce<%=pidx%>_probe_vif.upd_req_iid         = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_upd_req_iid_i;
assign dce<%=pidx%>_probe_vif.upd_req_status 	  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_upd_status_o;
assign dce<%=pidx%>_probe_vif.upd_req_status_vld  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_upd_status_valid_o;

//dir rsp interface
assign dce<%=pidx%>_probe_vif.cmd_rsp_rdy         = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_rsp_ready_i;
assign dce<%=pidx%>_probe_vif.cmd_rsp_vld         = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_rsp_valid_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_att_vec     = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_rsp_att_vec_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_way_vec     = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_rsp_way_vec_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_owner_val   = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_rsp_owner_val_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_owner_num   = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_rsp_owner_num_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_sharer_vec  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_rsp_sharer_vec_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_wr_required = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_rsp_wr_required_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_error	  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_cmd_rsp_error_o;
  
//recall interface
assign dce<%=pidx%>_probe_vif.recall_vld          = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_recall_valid_o;
assign dce<%=pidx%>_probe_vif.recall_rdy          = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_recall_ready_i;
assign dce<%=pidx%>_probe_vif.recall_addr         = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_recall_addr_o;
assign dce<%=pidx%>_probe_vif.recall_ns           = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_recall_ns_o;
assign dce<%=pidx%>_probe_vif.recall_sharer_vec   = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_recall_sharer_vec_o;
assign dce<%=pidx%>_probe_vif.recall_owner_val    = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_recall_owner_val_o;
assign dce<%=pidx%>_probe_vif.recall_owner_num    = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_recall_owner_num_o;
assign dce<%=pidx%>_probe_vif.recall_att_vec      = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_tm.att_recall_alloc;
  
//write interface
assign dce<%=pidx%>_probe_vif.write_rdy           = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_write_ready_o;
assign dce<%=pidx%>_probe_vif.write_vld           = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_write_valid_i;
assign dce<%=pidx%>_probe_vif.write_addr          = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_write_addr_i;
assign dce<%=pidx%>_probe_vif.write_ns            = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_write_ns_i;
assign dce<%=pidx%>_probe_vif.write_way_vec       = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_write_way_vec_i;
assign dce<%=pidx%>_probe_vif.write_owner_val     = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_write_owner_val_i;
assign dce<%=pidx%>_probe_vif.write_owner_num     = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_write_owner_num_i;
assign dce<%=pidx%>_probe_vif.write_sharer_vec    = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_write_sharer_vec_i;
assign dce<%=pidx%>_probe_vif.write_change_vec    = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_write_change_vec_i;

//retry interface
assign dce<%=pidx%>_probe_vif.retry_rdy         = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_rtr_ready_i;
assign dce<%=pidx%>_probe_vif.retry_vld         = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_rtr_valid_o;
assign dce<%=pidx%>_probe_vif.retry_att_vec     = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_rtr_att_vec_o;
assign dce<%=pidx%>_probe_vif.retry_filter_vec  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_rtr_filter_vec_o;
assign dce<%=pidx%>_probe_vif.retry_way_mask    = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.dm_rtr_way_mask_o;

//used for assertions/coverproperties.
assign dce<%=pidx%>_probe_vif.dm_mem_init       = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.t_init_valid;
assign dce<%=pidx%>_probe_vif.dm_flush          = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_dm.q_flush;

assign dce<%=pidx%>_probe_vif.event_in_req 	= tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.event_in_req;
assign dce<%=pidx%>_probe_vif.event_in_ack 	= tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.event_in_ack;
assign dce<%=pidx%>_probe_vif.event_err_valid 	= tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.csr_sys_evt_sender_err_vld;
assign dce<%=pidx%>_probe_vif.store_pass   	= tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_tm.dm_rsp_exmon_store_pass;
assign dce<%=pidx%>_probe_vif.prot_timeout_val 	= tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.u_sys_evt_coh_concerto.csr_protocol_timeout_value;
assign dce<%=pidx%>_probe_vif.prot_timeout_err 	= tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_evt_sender.protocol_timeout;

// Event Error signals

assign dce<%=pidx%>_probe_vif.timeout_threshold        = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_csr%>.DCEUTOCR_TimeOutThreshold_out;
assign dce<%=pidx%>_probe_vif.uedr_timeout_err_det_en  = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_csr%>.DCEUUEDR_TimeoutErrDetEn_out ;
assign dce<%=pidx%>_probe_vif.uesr_errvld              = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_csr%>.DCEUUESR_ErrVld_out ;
assign dce<%=pidx%>_probe_vif.uesr_err_type            = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_csr%>.DCEUUESR_ErrType_out ;
assign dce<%=pidx%>_probe_vif.uesr_err_info            = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_csr%>.DCEUUESR_ErrInfo_out ;
assign dce<%=pidx%>_probe_vif.ueir_timeout_irq_en      = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.<%=hier_path_dce_csr%>.DCEUUEIR_TimeoutErrIntEn_out ;
assign dce<%=pidx%>_probe_vif.IRQ_UC                   = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.irq_uc ;

<% for (var i = 0; i < obj.DceInfo[pidx].nAttCtrlEntries; i++) { %>
   assign dce<%=pidx%>_probe_vif.attvld_vec[<%=i%>] = tb_top.dut.<%=obj.DceInfo[pidx].instancePath%>.dce_func_unit.dce_tm.ATT_ENTRIES[<%=i%>].att_entry.att_entry_addr_comp_valid;
<% } %>

<%}else{%> //Non Grouping config

  <%
  var ASILB  = 0; // (obj.useResiliency & obj.DceInfo[pidx].ResilienceInfo.enableUnitDuplication) ? 0 : 1;
  var hier_path_dce_csr  = '';
  var hier_path_dce_cmux  = '';
  var hier_path_dce_sbcmdreqfifo  = '';
  var hier_path_dce_sb  = '';
  if (!ASILB) {
    hier_path_dce_csr = 'dce_func_unit.u_csr';
    hier_path_dce_cmux = 'dce_func_unit.dce_conc_mux';
    hier_path_dce_sbcmdreqfifo = 'dce_func_unit.skid_buf_cmd_req_fifo';
    hier_path_dce_sb = 'dce_func_unit.dce_skid_buffer';
  } else {
    hier_path_dce_csr = 'u_csr';
    hier_path_dce_cmux = 'dce_conc_mux';
    hier_path_dce_sbcmdreqfifo = 'skid_buf_cmd_req_fifo';
    hier_path_dce_sb = 'dce_skid_buffer';
  }
  %>

assign dce<%=pidx%>_probe_vif.sb_cmdrsp_vld    = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sb%>.f0_cmd_rsp_valid;
assign dce<%=pidx%>_probe_vif.sb_cmdrsp_rdy    = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sb%>.f0_cmd_rsp_ready;
assign dce<%=pidx%>_probe_vif.sb_cmdrsp_tgtid  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sb%>.f0_cmd_rsp_target_id;
assign dce<%=pidx%>_probe_vif.sb_cmdrsp_rmsgid = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sb%>.f0_cmd_rsp_r_message_id;

//RTL signals to update Snoop enable registers in DCE
assign dce<%=pidx%>_probe_vif.sb_sysrsp_vld    = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_cmux%>.sys_rsp_tx_valid;
assign dce<%=pidx%>_probe_vif.sb_sysrsp_rdy    = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_cmux%>.sys_rsp_tx_ready;
assign dce<%=pidx%>_probe_vif.sb_sysrsp_tgtid  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_cmux%>.sys_rsp_tx_target_id;

//RTL signals needed to grab output of conc_mux for QOS testing in DCE -CONC-7215
//due to cmdreq backpressure, SMI_Time != CMux_Time
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_vld  	  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_cmux%>.cmd_req_valid;
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_rdy  	  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_cmux%>.cmd_req_ready;
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_addr 	  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_cmux%>.cmd_req_addr;
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_ns      = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_cmux%>.cmd_req_ns;
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_iid  	  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_cmux%>.cmd_req_initiator_id;
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_cm_type = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_cmux%>.cmd_req_cm_type;
assign dce<%=pidx%>_probe_vif.cmux_cmdreq_msg_id  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_cmux%>.cmd_req_message_id;

assign dce<%=pidx%>_probe_vif.arb_cmdreq_vld  	  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_valid;
assign dce<%=pidx%>_probe_vif.arb_cmdreq_rdy  	  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_ready;
assign dce<%=pidx%>_probe_vif.arb_cmdreq_addr 	  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_addr;
assign dce<%=pidx%>_probe_vif.arb_cmdreq_ns       = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_ns;
assign dce<%=pidx%>_probe_vif.arb_cmdreq_iid  	  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_initiator_id;
assign dce<%=pidx%>_probe_vif.arb_cmdreq_cm_type = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_cm_type;
assign dce<%=pidx%>_probe_vif.arb_cmdreq_msg_id  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_message_id;
`ifndef VCS
if (addrMgrConst::get_highest_qos() != 0) begin
assign dce<%=pidx%>_probe_vif.sb_starv_mode	   = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.starv_mode;
end
`else // `ifndef VCS
<%if(obj.DceInfo[pidx].QosInfo && (obj.DceInfo[pidx].QosInfo.qosMap.length > 0)){%>
assign dce<%=pidx%>_probe_vif.sb_starv_mode	   = (addrMgrConst::get_highest_qos() != 0) ? tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sb%>.cmd_skid_buffer.starv_mode : dce<%=pidx%>_probe_vif.sb_starv_mode;
<% } %>
`endif // `ifndef VCS ... `else ... 

//cmd req interface (dce_dm_0.v)
assign dce<%=pidx%>_probe_vif.cmd_req_vld           = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_req_valid_i; 
assign dce<%=pidx%>_probe_vif.cmd_req_rdy           = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_req_ready_o; 
assign dce<%=pidx%>_probe_vif.cmd_req_addr          = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_req_addr_i; 
assign dce<%=pidx%>_probe_vif.cmd_req_ns            = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_req_ns_i; 
assign dce<%=pidx%>_probe_vif.cmd_req_type          = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_req_type_i;
assign dce<%=pidx%>_probe_vif.cmd_req_iid           = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_req_iid_i;
assign dce<%=pidx%>_probe_vif.cmd_req_sid           = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_req_sid_i;
assign dce<%=pidx%>_probe_vif.cmd_req_att_vec       = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_req_att_vec_i;
assign dce<%=pidx%>_probe_vif.cmd_req_wakeup        = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_req_wakeup_i;
assign dce<%=pidx%>_probe_vif.cmd_req_msg_id        = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_sbcmdreqfifo%>.pop_message_id;
assign dce<%=pidx%>_probe_vif.cmd_req1_busy_vec     = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_req1_busy_vec_i;
assign dce<%=pidx%>_probe_vif.cmd_req1_filter_num   = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_req1_filter_num_o;
assign dce<%=pidx%>_probe_vif.cmd_req1_alloc        = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_req1_alloc_i;
assign dce<%=pidx%>_probe_vif.cmd_req1_cancel       = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_req1_cancel_i;

//upd req interface (dce_dm_0.v)
assign dce<%=pidx%>_probe_vif.upd_req_vld         = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_upd_req_valid_i;
assign dce<%=pidx%>_probe_vif.upd_req_rdy         = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_upd_req_ready_o;
assign dce<%=pidx%>_probe_vif.upd_req_addr        = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_upd_req_addr_i;
assign dce<%=pidx%>_probe_vif.upd_req_ns          = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_upd_req_ns_i;
assign dce<%=pidx%>_probe_vif.upd_req_iid         = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_upd_req_iid_i;
assign dce<%=pidx%>_probe_vif.upd_req_status 	  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_upd_status_o;
assign dce<%=pidx%>_probe_vif.upd_req_status_vld  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_upd_status_valid_o;

//dir rsp interface
assign dce<%=pidx%>_probe_vif.cmd_rsp_rdy         = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_rsp_ready_i;
assign dce<%=pidx%>_probe_vif.cmd_rsp_vld         = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_rsp_valid_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_att_vec     = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_rsp_att_vec_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_way_vec     = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_rsp_way_vec_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_owner_val   = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_rsp_owner_val_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_owner_num   = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_rsp_owner_num_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_sharer_vec  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_rsp_sharer_vec_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_wr_required = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_rsp_wr_required_o;
assign dce<%=pidx%>_probe_vif.cmd_rsp_error	  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_cmd_rsp_error_o;
  
//recall interface
assign dce<%=pidx%>_probe_vif.recall_vld          = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_recall_valid_o;
assign dce<%=pidx%>_probe_vif.recall_rdy          = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_recall_ready_i;
assign dce<%=pidx%>_probe_vif.recall_addr         = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_recall_addr_o;
assign dce<%=pidx%>_probe_vif.recall_ns           = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_recall_ns_o;
assign dce<%=pidx%>_probe_vif.recall_sharer_vec   = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_recall_sharer_vec_o;
assign dce<%=pidx%>_probe_vif.recall_owner_val    = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_recall_owner_val_o;
assign dce<%=pidx%>_probe_vif.recall_owner_num    = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_recall_owner_num_o;
assign dce<%=pidx%>_probe_vif.recall_att_vec      = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_tm.att_recall_alloc;
  
//write interface
assign dce<%=pidx%>_probe_vif.write_rdy           = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_write_ready_o;
assign dce<%=pidx%>_probe_vif.write_vld           = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_write_valid_i;
assign dce<%=pidx%>_probe_vif.write_addr          = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_write_addr_i;
assign dce<%=pidx%>_probe_vif.write_ns            = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_write_ns_i;
assign dce<%=pidx%>_probe_vif.write_way_vec       = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_write_way_vec_i;
assign dce<%=pidx%>_probe_vif.write_owner_val     = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_write_owner_val_i;
assign dce<%=pidx%>_probe_vif.write_owner_num     = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_write_owner_num_i;
assign dce<%=pidx%>_probe_vif.write_sharer_vec    = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_write_sharer_vec_i;
assign dce<%=pidx%>_probe_vif.write_change_vec    = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_write_change_vec_i;

//retry interface
assign dce<%=pidx%>_probe_vif.retry_rdy         = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_rtr_ready_i;
assign dce<%=pidx%>_probe_vif.retry_vld         = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_rtr_valid_o;
assign dce<%=pidx%>_probe_vif.retry_att_vec     = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_rtr_att_vec_o;
assign dce<%=pidx%>_probe_vif.retry_filter_vec  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_rtr_filter_vec_o;
assign dce<%=pidx%>_probe_vif.retry_way_mask    = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.dm_rtr_way_mask_o;

//used for assertions/coverproperties.
assign dce<%=pidx%>_probe_vif.dm_mem_init       = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.t_init_valid;
assign dce<%=pidx%>_probe_vif.dm_flush          = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_dm.q_flush;

assign dce<%=pidx%>_probe_vif.event_in_req 	= tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.event_in_req;
assign dce<%=pidx%>_probe_vif.event_in_ack 	= tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.event_in_ack;
assign dce<%=pidx%>_probe_vif.event_err_valid 	= tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.csr_sys_evt_sender_err_vld;
assign dce<%=pidx%>_probe_vif.store_pass   	= tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_tm.dm_rsp_exmon_store_pass;
assign dce<%=pidx%>_probe_vif.prot_timeout_val 	= tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.u_sys_evt_coh_concerto.csr_protocol_timeout_value;
assign dce<%=pidx%>_probe_vif.prot_timeout_err 	= tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_evt_sender.protocol_timeout;

// Event Error signals

assign dce<%=pidx%>_probe_vif.timeout_threshold        = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_csr%>.DCEUTOCR_TimeOutThreshold_out;
assign dce<%=pidx%>_probe_vif.uedr_timeout_err_det_en  = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_csr%>.DCEUUEDR_TimeoutErrDetEn_out ;
assign dce<%=pidx%>_probe_vif.uesr_errvld              = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_csr%>.DCEUUESR_ErrVld_out ;
assign dce<%=pidx%>_probe_vif.uesr_err_type            = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_csr%>.DCEUUESR_ErrType_out ;
assign dce<%=pidx%>_probe_vif.uesr_err_info            = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_csr%>.DCEUUESR_ErrInfo_out ;
assign dce<%=pidx%>_probe_vif.ueir_timeout_irq_en      = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.<%=hier_path_dce_csr%>.DCEUUEIR_TimeoutErrIntEn_out ;
assign dce<%=pidx%>_probe_vif.IRQ_UC                   = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.irq_uc ;

<% for (var i = 0; i < obj.DceInfo[pidx].nAttCtrlEntries; i++) { %>
   assign dce<%=pidx%>_probe_vif.attvld_vec[<%=i%>] = tb_top.dut.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.dce_func_unit.dce_tm.ATT_ENTRIES[<%=i%>].att_entry.att_entry_addr_comp_valid;
<% } %>
<% } %> // End Non grouping configs
<% } %>

`ifdef CHI_SUBSYS 
    <%for(let i=0; i< obj.nCHIs; i++) {%>
        assign chiaiu<%=i%>_probe_vif.str_req_vld = tb_top.dut.caiu<%=i%>.smi_rx0_ndp_msg_valid;
        assign chiaiu<%=i%>_probe_vif.str_req_rdy = tb_top.dut.caiu<%=i%>.smi_rx0_ndp_msg_ready;
        assign chiaiu<%=i%>_probe_vif.valid_str_req = tb_top.dut.caiu<%=i%>.smi_rx0_ndp_msg_valid && tb_top.dut.caiu<%=i%>.smi_rx0_ndp_msg_ready && tb_top.dut.caiu<%=i%>.clk_clk;

        assign chiaiu<%=i%>_probe_vif.dtr_req_rx_vld = tb_top.dut.caiu<%=i%>.smi_rx2_ndp_msg_valid;
        assign chiaiu<%=i%>_probe_vif.dtr_req_rx_rdy = tb_top.dut.caiu<%=i%>.smi_rx2_ndp_msg_ready;
        assign chiaiu<%=i%>_probe_vif.valid_dtr_rx_req = tb_top.dut.caiu<%=i%>.smi_rx2_ndp_msg_valid && tb_top.dut.caiu<%=i%>.smi_rx2_ndp_msg_ready && tb_top.dut.caiu<%=i%>.clk_clk;
    <%}%>
`endif

<%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { %>
<%if(obj.AiuInfo[pidx].hierPath && obj.AiuInfo[pidx].hierPath !== ''){%>
    <%if(obj.AiuInfo[pidx].fnNativeInterface == "ACE"  || obj.AiuInfo[pidx].fnNativeInterface == "ACE5"|| ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4" || obj.AiuInfo[pidx].fnNativeInterface == "AXI5") && obj.AiuInfo[pidx].useCache == 1)){%>
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.event_receiver_enable    = ~tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUTCR_EventDisable_out;
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.timeout_threshold 		= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUTOCR_TimeOutThreshold_out[30:0];
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uedr_timeout_err_det_en 	= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUUEDR_TimeoutErrDetEn_out;
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uesr_errvld 				= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core0.XAIUUESR_ErrVld_out;
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uesr_err_type 			= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUUESR_ErrType_out[3:0];
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uesr_err_info 			= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUUESR_ErrInfo_out[15:0];
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ueir_timeout_irq_en 		= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUUEIR_TimeoutErrIntEn_out;
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.sysco_attach              = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUTCR_SysCoAttach_out;
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.IRQ_UC 					= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>_irq_uc;
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.idle_or_done             = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.ioaiu_core_wrapper.ioaiu_core0.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_evt_receiver.next_state_is_IDLE_or_DONE;
	<%}else if(obj.AiuInfo[pidx].fnNativeInterface == "CHI-A" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E"){%>
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.event_receiver_enable    = ~tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.unit.chi_aiu_csr.CAIUTCR_EventDisable_out; 
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.timeout_threshold 		= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.unit.chi_aiu_csr.CAIUTOCR_TimeOutThreshold_out[30:0];
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uedr_timeout_err_det_en 	= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.unit.chi_aiu_csr.CAIUUEDR_TimeoutErrDetEn_out;
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uesr_errvld 				= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.unit.chi_aiu_csr.CAIUUESR_ErrVld_out;
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uesr_err_type 			= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.unit.chi_aiu_csr.CAIUUESR_ErrType_out[3:0];
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uesr_err_info 			= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.unit.chi_aiu_csr.CAIUUESR_ErrInfo_out[15:0];
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ueir_timeout_irq_en 		= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.unit.chi_aiu_csr.CAIUUEIR_TimeOutErrIntEn_out;
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.sysco_attach 		        = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.unit.chi_aiu_csr.CAIUTAR_SysCoAttached_out;
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.sysco_connecting          = !tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.unit.co_state_disabled; 
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.IRQ_UC 					= tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>_irq_uc;
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.idle_or_done             = tb_top.dut.<%=obj.AiuInfo[pidx].instancePath%>.unit.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_evt_receiver.next_state_is_IDLE_or_DONE;
    <%}%>

<% } else {%>
    <%if(obj.AiuInfo[pidx].fnNativeInterface == "ACE"  || obj.AiuInfo[pidx].fnNativeInterface == "ACE5"|| ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4" || obj.AiuInfo[pidx].fnNativeInterface == "AXI5") && obj.AiuInfo[pidx].useCache == 1)){%>
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.event_receiver_enable    = ~tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUTCR_EventDisable_out;
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.timeout_threshold 		= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUTOCR_TimeOutThreshold_out[30:0];
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uedr_timeout_err_det_en 	= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUUEDR_TimeoutErrDetEn_out;
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uesr_errvld 				= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.XAIUUESR_ErrVld_out;
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uesr_err_type 			= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUUESR_ErrType_out[3:0];
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uesr_err_info 			= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUUESR_ErrInfo_out[15:0];
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ueir_timeout_irq_en 		= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUUEIR_TimeoutErrIntEn_out;
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.sysco_attach              = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUTCR_SysCoAttach_out;
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.IRQ_UC 					= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_irq_uc;
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.idle_or_done             = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_evt_receiver.next_state_is_IDLE_or_DONE;
	<%}else if(obj.AiuInfo[pidx].fnNativeInterface == "CHI-A" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E"){%>
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.event_receiver_enable    = ~tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUTCR_EventDisable_out; 
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.timeout_threshold 		= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUTOCR_TimeOutThreshold_out[30:0];
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uedr_timeout_err_det_en 	= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUUEDR_TimeoutErrDetEn_out;
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uesr_errvld 				= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUUESR_ErrVld_out;
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uesr_err_type 			= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUUESR_ErrType_out[3:0];
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.uesr_err_info 			= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUUESR_ErrInfo_out[15:0];
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ueir_timeout_irq_en 		= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUUEIR_TimeOutErrIntEn_out;
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.sysco_attach 		        = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUTAR_SysCoAttached_out;
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.sysco_connecting          = !tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.unit.co_state_disabled; 
    	assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.IRQ_UC 					= tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_irq_uc;
        assign m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.idle_or_done             = tb_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.unit.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_evt_receiver.next_state_is_IDLE_or_DONE;
    <%}%>
<% } %>
<%}%>

<%for(var chi_idx = 0; chi_idx < obj.nCHIs; chi_idx++) {%>
<%if(obj.ChiaiuInfo[chi_idx].hierPath && obj.ChiaiuInfo[chi_idx].hierPath !== ''){%>
    <%if(obj.ChiaiuInfo[chi_idx].interfaces.chiInt.params.checkType != "NONE") {%>
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.index = <%=chi_idx%>;
    <%if(obj.AiuInfo[chi_idx].useResiliency == 1) {%>
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.mission_fault = tb_top.dut.<%=obj.AiuInfo[chi_idx].instancePath%>.fault_mission_fault;
    <%}%>
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_info = tb_top.dut.<%=obj.AiuInfo[chi_idx].instancePath%>.unit.chi_aiu_csr.CAIUUESR_ErrInfo_out[15:0];
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_type = tb_top.dut.<%=obj.AiuInfo[chi_idx].instancePath%>.unit.chi_aiu_csr.CAIUUESR_ErrType_out[3:0];
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_valid = tb_top.dut.<%=obj.AiuInfo[chi_idx].instancePath%>.unit.chi_aiu_csr.CAIUUESR_ErrVld_out;
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_det_en = tb_top.dut.<%=obj.AiuInfo[chi_idx].instancePath%>.unit.chi_aiu_csr.CAIUUEDR_IntfCheckErrDetEn_out;
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_int_en = tb_top.dut.<%=obj.AiuInfo[chi_idx].instancePath%>.unit.chi_aiu_csr.CAIUUEIR_IntfCheckErrIntEn_out;
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.IRQ_UC = tb_top.dut.<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>_irq_uc;
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_info_alias = tb_top.dut.<%=obj.AiuInfo[chi_idx].instancePath%>.unit.chi_aiu_csr.CAIUUESAR_ErrInfo_out[15:0];
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_type_alias = tb_top.dut.<%=obj.AiuInfo[chi_idx].instancePath%>.unit.chi_aiu_csr.CAIUUESAR_ErrType_out[3:0];
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_valid_alias = tb_top.dut.<%=obj.AiuInfo[chi_idx].instancePath%>.unit.chi_aiu_csr.CAIUUESAR_ErrVld_out;
    <%}%>
<% } else {%>
    <%if(obj.ChiaiuInfo[chi_idx].interfaces.chiInt.params.checkType != "NONE") {%>
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.index = <%=chi_idx%>;
    <%if(obj.AiuInfo[chi_idx].useResiliency == 1) {%>
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.mission_fault = tb_top.dut.<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.fault_mission_fault;
    <%}%>
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_info = tb_top.dut.<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUUESR_ErrInfo_out[15:0];
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_type = tb_top.dut.<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUUESR_ErrType_out[3:0];
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_valid = tb_top.dut.<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUUESR_ErrVld_out;
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_det_en = tb_top.dut.<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUUEDR_IntfCheckErrDetEn_out;
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_int_en = tb_top.dut.<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUUEIR_IntfCheckErrIntEn_out;
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.IRQ_UC = tb_top.dut.<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>_irq_uc;
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_info_alias = tb_top.dut.<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUUESAR_ErrInfo_out[15:0];
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_type_alias = tb_top.dut.<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUUESAR_ErrType_out[3:0];
        assign m_chi_if_<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.err_valid_alias = tb_top.dut.<%=obj.AiuInfo[chi_idx].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUUESAR_ErrVld_out;
    <%}%>
<% } %>
<%}%>


// Setting event_out_if signals for SysReq events verificaiton
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
<%if(obj.DveInfo[pidx].hierPath && obj.DveInfo[pidx].hierPath !== ''){%>
  // stall_if use by perf monitor
  assign <%=obj.DveInfo[pidx].strRtlNamePrefix%>_sb_stall_if.master_cnt_enable = tb_top.dut.<%=obj.DveInfo[pidx].instancePath%>.trigger_trigger;
  assign <%=obj.DveInfo[pidx].strRtlNamePrefix%>_sb_stall_if.clk = tb_top.dut.<%=obj.DveInfo[pidx].instancePath%>.clk_clk;
  assign <%=obj.DveInfo[pidx].strRtlNamePrefix%>_sb_stall_if.rst_n = soft_rstn; 
  //APB control if *****************************************
  assign  dve<%=pidx%>_m_apb_if.paddr   =	tb_top.dut.<%=obj.DveInfo[pidx].instancePath%>.apb_paddr;
  assign  dve<%=pidx%>_m_apb_if.pwrite  =	tb_top.dut.<%=obj.DveInfo[pidx].instancePath%>.apb_pwrite;
  assign  dve<%=pidx%>_m_apb_if.psel    =	tb_top.dut.<%=obj.DveInfo[pidx].instancePath%>.apb_psel;
  assign  dve<%=pidx%>_m_apb_if.penable =	tb_top.dut.<%=obj.DveInfo[pidx].instancePath%>.apb_penable;
  assign  dve<%=pidx%>_m_apb_if.prdata  =	tb_top.dut.<%=obj.DveInfo[pidx].instancePath%>.apb_prdata;
  assign  dve<%=pidx%>_m_apb_if.pwdata  =	tb_top.dut.<%=obj.DveInfo[pidx].instancePath%>.apb_pwdata;
  assign  dve<%=pidx%>_m_apb_if.pready  =	tb_top.dut.<%=obj.DveInfo[pidx].instancePath%>.apb_pready;
  assign  dve<%=pidx%>_m_apb_if.pslverr =	tb_top.dut.<%=obj.DveInfo[pidx].instancePath%>.apb_pslverr;

<% } else {%>
  // stall_if use by perf monitor
  assign <%=obj.DveInfo[pidx].strRtlNamePrefix%>_sb_stall_if.master_cnt_enable = tb_top.dut.<%=obj.DveInfo[pidx].strRtlNamePrefix%>.trigger_trigger;
  assign <%=obj.DveInfo[pidx].strRtlNamePrefix%>_sb_stall_if.clk = tb_top.dut.<%=obj.DveInfo[pidx].strRtlNamePrefix%>.clk_clk;
  assign <%=obj.DveInfo[pidx].strRtlNamePrefix%>_sb_stall_if.rst_n = soft_rstn; 
  //APB control if *****************************************
  assign  dve<%=pidx%>_m_apb_if.paddr   =	tb_top.dut.<%=obj.DveInfo[pidx].strRtlNamePrefix%>.apb_paddr;
  assign  dve<%=pidx%>_m_apb_if.pwrite  =	tb_top.dut.<%=obj.DveInfo[pidx].strRtlNamePrefix%>.apb_pwrite;
  assign  dve<%=pidx%>_m_apb_if.psel    =	tb_top.dut.<%=obj.DveInfo[pidx].strRtlNamePrefix%>.apb_psel;
  assign  dve<%=pidx%>_m_apb_if.penable =	tb_top.dut.<%=obj.DveInfo[pidx].strRtlNamePrefix%>.apb_penable;
  assign  dve<%=pidx%>_m_apb_if.prdata  =	tb_top.dut.<%=obj.DveInfo[pidx].strRtlNamePrefix%>.apb_prdata;
  assign  dve<%=pidx%>_m_apb_if.pwdata  =	tb_top.dut.<%=obj.DveInfo[pidx].strRtlNamePrefix%>.apb_pwdata;
  assign  dve<%=pidx%>_m_apb_if.pready  =	tb_top.dut.<%=obj.DveInfo[pidx].strRtlNamePrefix%>.apb_pready;
  assign  dve<%=pidx%>_m_apb_if.pslverr =	tb_top.dut.<%=obj.DveInfo[pidx].strRtlNamePrefix%>.apb_pslverr;
<% } %>
<% } %>

    <% if(obj.useResiliency == 1) { %>
    //tb_top.dut.fsc.bist_caiu0_bist_next_ack
    //tb_top.dut.fsc.fault_caiu0_mission_fault
    <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
        assign         fault_injector_checker.fault_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.clk=tb_top.dut.fsc.clk_clk;
        assign         fault_injector_checker.fault_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.mission_fault=tb_top.dut.fsc.fault_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_mission_fault;
        assign         fault_injector_checker.fault_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.latent_fault=tb_top.dut.fsc.fault_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_latent_fault;
        assign         fault_injector_checker.fault_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.cerr_over_thres_fault=tb_top.dut.fsc.fault_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_cerr_over_thres_fault;
        assign         fault_injector_checker.bist_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.clk= tb_top.dut.fsc.clk_clk;
        assign         fault_injector_checker.bist_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.bist_next_ack= tb_top.dut.fsc.bist_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_bist_next_ack;
        assign         fault_injector_checker.bist_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.bist_next= tb_top.dut.fsc.bist_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_bist_next;
    <% } %>

    <% for(pidx = 0; pidx < obj.nDCEs; pidx++) { %>
        assign         fault_injector_checker.fault_<%=obj.DceInfo[pidx].strRtlNamePrefix%>.clk=tb_top.dut.fsc.clk_clk;
        assign         fault_injector_checker.fault_<%=obj.DceInfo[pidx].strRtlNamePrefix%>.mission_fault=tb_top.dut.fsc.fault_<%=obj.DceInfo[pidx].strRtlNamePrefix%>_mission_fault;
        assign         fault_injector_checker.fault_<%=obj.DceInfo[pidx].strRtlNamePrefix%>.latent_fault=tb_top.dut.fsc.fault_<%=obj.DceInfo[pidx].strRtlNamePrefix%>_latent_fault;
        assign         fault_injector_checker.fault_<%=obj.DceInfo[pidx].strRtlNamePrefix%>.cerr_over_thres_fault=tb_top.dut.fsc.fault_<%=obj.DceInfo[pidx].strRtlNamePrefix%>_cerr_over_thres_fault;
        assign         fault_injector_checker.bist_<%=obj.DceInfo[pidx].strRtlNamePrefix%>.clk= tb_top.dut.fsc.clk_clk;
        assign         fault_injector_checker.bist_<%=obj.DceInfo[pidx].strRtlNamePrefix%>.bist_next_ack= tb_top.dut.fsc.bist_<%=obj.DceInfo[pidx].strRtlNamePrefix%>_bist_next_ack;
        assign         fault_injector_checker.bist_<%=obj.DceInfo[pidx].strRtlNamePrefix%>.bist_next= tb_top.dut.fsc.bist_<%=obj.DceInfo[pidx].strRtlNamePrefix%>_bist_next;
    <% } %>

    <% for(pidx =  0; pidx < obj.nDMIs; pidx++) { %>
        assign         fault_injector_checker.fault_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.clk=tb_top.dut.fsc.clk_clk;
        assign         fault_injector_checker.fault_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.mission_fault=tb_top.dut.fsc.fault_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>_mission_fault;
        assign         fault_injector_checker.fault_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.latent_fault=tb_top.dut.fsc.fault_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>_latent_fault;
        assign         fault_injector_checker.fault_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.cerr_over_thres_fault=tb_top.dut.fsc.fault_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>_cerr_over_thres_fault;
        assign         fault_injector_checker.bist_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.clk= tb_top.dut.fsc.clk_clk;
        assign         fault_injector_checker.bist_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.bist_next_ack= tb_top.dut.fsc.bist_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>_bist_next_ack;
        assign         fault_injector_checker.bist_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.bist_next= tb_top.dut.fsc.bist_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>_bist_next;
    <% } %>

    <% for(pidx = 0; pidx < obj.nDIIs; pidx++) { %>
        assign         fault_injector_checker.fault_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.clk=tb_top.dut.fsc.clk_clk;
        assign         fault_injector_checker.fault_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.mission_fault=tb_top.dut.fsc.fault_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>_mission_fault;
        assign         fault_injector_checker.fault_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.latent_fault=tb_top.dut.fsc.fault_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>_latent_fault;
        assign         fault_injector_checker.fault_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.cerr_over_thres_fault=tb_top.dut.fsc.fault_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>_cerr_over_thres_fault;
        assign         fault_injector_checker.bist_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.clk= tb_top.dut.fsc.clk_clk;
        assign         fault_injector_checker.bist_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.bist_next_ack= tb_top.dut.fsc.bist_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>_bist_next_ack;
        assign         fault_injector_checker.bist_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.bist_next= tb_top.dut.fsc.bist_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>_bist_next;
    <% } %>

    <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
        assign         fault_injector_checker.fault_<%=obj.DveInfo[pidx].strRtlNamePrefix%>.clk=tb_top.dut.fsc.clk_clk;
        assign         fault_injector_checker.fault_<%=obj.DveInfo[pidx].strRtlNamePrefix%>.mission_fault=tb_top.dut.fsc.fault_<%=obj.DveInfo[pidx].strRtlNamePrefix%>_mission_fault;
        assign         fault_injector_checker.fault_<%=obj.DveInfo[pidx].strRtlNamePrefix%>.latent_fault=tb_top.dut.fsc.fault_<%=obj.DveInfo[pidx].strRtlNamePrefix%>_latent_fault;
        assign         fault_injector_checker.fault_<%=obj.DveInfo[pidx].strRtlNamePrefix%>.cerr_over_thres_fault=tb_top.dut.fsc.fault_<%=obj.DveInfo[pidx].strRtlNamePrefix%>_cerr_over_thres_fault;
        assign         fault_injector_checker.bist_<%=obj.DveInfo[pidx].strRtlNamePrefix%>.clk= tb_top.dut.fsc.clk_clk;
        assign         fault_injector_checker.bist_<%=obj.DveInfo[pidx].strRtlNamePrefix%>.bist_next_ack= tb_top.dut.fsc.bist_<%=obj.DveInfo[pidx].strRtlNamePrefix%>_bist_next_ack;
        assign         fault_injector_checker.bist_<%=obj.DveInfo[pidx].strRtlNamePrefix%>.bist_next= tb_top.dut.fsc.bist_<%=obj.DveInfo[pidx].strRtlNamePrefix%>_bist_next;
    <% } %>
    <% } %>

<% } %>

<% if(obj.FULL_SYS_TB) { %>
<%     var uclk = [];
       var urst = [];

       obj.ClockPorts.uniquePorts.forEach(function(c) {
           uclk.push(c.sig2);
       });

       obj.ResetPorts.uniquePorts.forEach(function(c) {
           urst.push(c.sig2);
       });
%>
//   dmi_probe_harness DmiProbe ();
<% } else { %>
    //DMI Probe Interface
//    dmi_probe_harness DmiProbe (dut_clk, soft_rstn);
<% } %>

     smi_harness u_smi_harness(dut_clk, soft_rstn);

    //Initialization of time format
    //Passing virtual interface handles to UVM world
    initial begin
   automatic int indx = 0;
<% if (obj.testBench != "emu" ) { %>   
 ///////////////////////////////////////////////////
    //Seeting stall_if interface for ioaiu to config_db
    ///////////////////////////////////////////////////
    <% var io_idx=0;    %>
    <% for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { %>
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
        <%for (var i=0; i<aiu_NumCores[pidx]; i++) { %>        
          uvm_config_db#(virtual <%=_child_blkid[pidx]%>_stall_if)::set(null, "", "<%=_child_blkid[pidx]%>_<%=i%>_m_top_stall_if",       <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>_sb_stall_if); 
        <% } %>
      <% } else {%>
        <% for (var i=0; i<aiu_NumCores[pidx]; i++) { %>        
          uvm_config_db#(virtual <%=_child_blkid[pidx]%>_stall_if)::set(null, "", "<%=_child_blkid[pidx]%>_0_m_top_stall_if_<%=i%>",       <%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>_sb_stall_if); 
        <% } %>
      <% } %>
    <% } %>
    <%
    var pidx;
    var ridx;
    for( pidx = 0; pidx < obj.nDCEs; pidx++) {
        ridx = pidx + obj.nAIUs; %>
        uvm_config_db#(virtual <%=_child_blkid[ridx]%>_stall_if)::set(null, "", "<%=_child_blkid[ridx]%>_m_top_stall_if",       <%=obj.DceInfo[pidx].strRtlNamePrefix%>_sb_stall_if); 
    <%}
    for(pidx =  0; pidx < obj.nDMIs; pidx++) {
        ridx = pidx + obj.nAIUs + obj.nDCEs;%>
        uvm_config_db#(virtual <%=_child_blkid[ridx]%>_stall_if)::set(null, "", "<%=_child_blkid[ridx]%>_m_top_stall_if",       <%=obj.DmiInfo[pidx].strRtlNamePrefix%>_sb_stall_if); 
    <%}
    for(pidx = 0; pidx < obj.nDIIs; pidx++) {
        ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;%>
        uvm_config_db#(virtual <%=_child_blkid[ridx]%>_stall_if)::set(null, "", "<%=_child_blkid[ridx]%>_m_top_stall_if",       <%=obj.DiiInfo[pidx].strRtlNamePrefix%>_sb_stall_if); 
    <%}
    for(pidx = 0; pidx < obj.nDVEs; pidx++) {
        ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs; %>
        uvm_config_db#(virtual <%=_child_blkid[ridx]%>_stall_if)::set(null, "", "<%=_child_blkid[ridx]%>_m_top_stall_if",       <%=obj.DveInfo[pidx].strRtlNamePrefix%>_sb_stall_if); 
    <%}%>
    <%}%>
 
//Setting up Inhouse BFM Interface is active bit 
    <% var io_idx=0;
       for(var pidx = 0; pidx < initiatorAgents; pidx++) { %>
    <%  if(_child_blk[pidx].match('ioaiu')) { %>
	<% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
    `ifdef USE_VIP_SNPS_AXI_MASTERS
            ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.IS_ACTIVE = 0;
    `else
            ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.IS_ACTIVE = 1;
    `endif // `ifdef USE_VIP_SNPS_AXI_MASTERS
            ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.IS_IF_A_SLAVE = 0;
            <% } io_idx++; %>
    <% } %>
    <% } %>
    <% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
    `ifdef USE_VIP_SNPS_AXI_SLAVES
            m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.IS_ACTIVE = 0;
    `else
            m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.IS_ACTIVE = 1;
    `endif // `ifdef USE_VIP_SNPS_AXI_SLAVES
    <% } %>
    <% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
    <% if (obj.DiiInfo[pidx].configuration == 0) { %>  					       
    `ifdef USE_VIP_SNPS_AXI_SLAVES
            m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.IS_ACTIVE = 0;
    `else
            m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.IS_ACTIVE = 1;
    `endif // `ifdef USE_VIP_SNPS_AXI_SLAVES
    <% } } %>
`ifdef USE_VIP_SNPS_CHI
<%  if(chiaiu_idx>0) { %>
        uvm_config_db#(virtual svt_chi_if)::set(null,"uvm_test_top.m_concerto_env.snps.svt.amba_system_env.chi_system[0]", "vif", m_svt_chi_if);  //SVT CHI
<% } %>
`endif
        uvm_config_db#(virtual svt_axi_if)::set(null,"uvm_test_top.m_concerto_env.snps.svt.amba_system_env.axi_system[0]", "vif", m_svt_axi_if);  //SVT AXI

    <% var chi_idx=0;
       var io_idx=0;
       for(var pidx = 0; pidx < initiatorAgents; pidx++) { %>
    <%  if(_child_blk[pidx].match('chiaiu')) { %>
        uvm_config_db #(virtual <%=_child_blkid[pidx]%>_connectivity_if)::set (null,"","<%=_child_blkid[pidx]%>_connectivity_if",<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if);
        uvm_config_db #(virtual <%=_child_blkid[pidx]%>_chi_if)::set(uvm_root::get(),"","m_chi_if<%=chi_idx%>",m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>);  
    <% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %> 
	    uvm_config_db#(virtual <%=_child_blkid[pidx]%>_event_if #(.IF_MASTER(1)))::set(uvm_root::get(), "", "m_<%=_child_blkid[pidx]%>_event_if_sender_master",m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_sender_master);    
    <% } %> 
    <% if (obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false) { %>
	       uvm_config_db#(virtual <%=_child_blkid[pidx]%>_event_if #(.IF_MASTER(0)))::set(uvm_root::get(), "", "m_<%=_child_blkid[pidx]%>_event_if_receiver_slave",m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_receiver_slave);      
    <% } %>  
 <% if(obj.testBench=="emu") { %>
    uvm_config_db #(virtual <%=_child_blkid[pidx]%>_chi_emu_if)::set(uvm_root::get(),"","m_chi_emu_if<%=chi_idx%>",m_chi_emu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>); 
<% } %>
 <% if (obj.AiuInfo[pidx].interfaces.userPlaceInt._SKIP_ == false) { %>
          uvm_config_db #(virtual <%=_child_blkid[pidx]%>_generic_if)::set(uvm_root::get(),"","m_generic_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>", m_generic_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>);
    <% } %>
	<% chi_idx++; %>
    <% } %>
    <% } %>
    <% for(var pidx = 0; pidx < initiatorAgents; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
	<% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
            uvm_config_db#(bit)::set(uvm_root::get(),"*", "include_coverage", 0);
           uvm_config_db#(virtual <%=_child_blkid[pidx]%>_probe_if)::set(.cntxt( uvm_root::get() ),
                                            .inst_name( "" ),
                                            .field_name( "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_probe_if<%=i%>" ),
                                            .value( u_csr_probe_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%> ));
        
        <% } %>
    <% } %>
    <% if(_child_blk[pidx].match('ioaiu')) { %>
        <% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %> 
	    uvm_config_db#(virtual <%=_child_blkid[pidx]%>_event_if #(.IF_MASTER(1)))::set(uvm_root::get(), "", "m_<%=_child_blkid[pidx]%>_event_if_sender_master",m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_sender_master);    
    <% } %> 
    <% if (obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false) { %>
	       uvm_config_db#(virtual <%=_child_blkid[pidx]%>_event_if #(.IF_MASTER(0)))::set(uvm_root::get(), "", "m_<%=_child_blkid[pidx]%>_event_if_receiver_slave",m_event_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_receiver_slave);      
    <% } %> 
	<% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
        uvm_config_db #(virtual <%=_child_blkid[pidx]%>_axi_if)::set(uvm_root::get(),"","<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_axi_if_<%=i%>",ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>);
        <% } %>
        uvm_config_db #(virtual <%=_child_blkid[pidx]%>_connectivity_if)::set (null,"","<%=_child_blkid[pidx]%>_connectivity_if",<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_connectivity_if);

    <% if (obj.AiuInfo[pidx].interfaces.userPlaceInt._SKIP_ == false) { %>
           uvm_config_db #(virtual <%=_child_blkid[pidx]%>_generic_if)::set(uvm_root::get(),"","m_generic_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>",m_generic_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>);
    <% } %>
 <% if(obj.testBench=="emu"){ %>
        <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
             uvm_config_db #(virtual <%=_child_blkid[pidx]%>_ace_emu_if)::set(uvm_root::get(),"","m_ace_emu_if<%=io_idx%>",m_ace_emu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>);
             uvm_config_db #(virtual mgc_axi_master_if)::set(uvm_root::get(),"","mgc_ace_m_if_<%=_child_blkid[pidx]%>",mgc_ace_m_if_<%=_child_blkid[pidx]%>);  
	    <% } else if((obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE") || (obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" )) { %>
             uvm_config_db #(virtual <%=_child_blkid[pidx]%>_ace_emu_if)::set(uvm_root::get(),"","m_ace_emu_if<%=io_idx%>",m_ace_emu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>);
			 uvm_config_db #(virtual mgc_axi_master_if)::set(uvm_root::get(),"","mgc_acelite_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>",mgc_acelite_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>);
        <% } else if (!((obj.AiuInfo[pidx].fnNativeInterface == "ACE")||(obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE")||(obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" )||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')))  { %>
                   <% if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) { %>
                       <% aiu_axiIntLen[pidx] = obj.AiuInfo[pidx].interfaces.axiInt.length; %>
                       <% for (var i=0; i<aiu_axiIntLen[pidx]; i++) { %>
                           uvm_config_db #(virtual <%=_child_blkid[pidx]%>_ace_emu_if)::set(uvm_root::get(),"","m_ace_emu_if<%=io_idx%>_<%=i%>",m_ace_emu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>);
                           m_ace_emu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.core_id = <%=i%>;
			               uvm_config_db #(virtual mgc_axi_master_if)::set(uvm_root::get(),"","mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>",mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>);
					   <% } %>
				  <% } else { %>
                      uvm_config_db #(virtual <%=_child_blkid[pidx]%>_ace_emu_if)::set(uvm_root::get(),"","m_ace_emu_if<%=io_idx%>",m_ace_emu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>);
                      m_ace_emu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.core_id = 0;
			          uvm_config_db #(virtual mgc_axi_master_if)::set(uvm_root::get(),"","mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>",mgc_axi_m_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>);
				  <% } %>
    <% } %>
            
    <% } %>
<% io_idx++; %>
    <% } %>
    <% } %>

   <% if(obj.testBench != "emu"){ %>
 // Put Event Interface in the config db. This is used in the ioaiu_scoreboard
    // Event Out interface can be optional for ACE - Need to change based on the resolution of CONC-8149
    <%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { 
        if(obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].fnNativeInterface == "ACE5" ||
           obj.AiuInfo[pidx].fnNativeInterface == "CHI-A" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E" ||
        ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4" || obj.AiuInfo[pidx].fnNativeInterface == "AXI5") && obj.AiuInfo[pidx].useCache == 1)){%>
        uvm_config_db#(virtual event_out_if)::set(.cntxt( uvm_root::get() ),
                                                .inst_name( "" ),
                                                .field_name( "u_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>" ),
                                                .value( m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%> ));
    <%}}%>
    <% } %>
    <% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
        uvm_config_db #(virtual dmi<%=pidx%>_axi_if)::set(uvm_root::get(), "", "m_dmi<%=pidx%>_axi_slv_if", m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>);
 <% if(obj.testBench=="emu"){ %>
        uvm_config_db #(virtual dmi<%=pidx%>_tt_if)::set(uvm_root::get(), "", "m_dmi<%=pidx%>_tt_if", m_tt_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>) ;
         
    <% } %>
    <% if (obj.DmiInfo[pidx].interfaces.userPlaceInt._SKIP_ == false) { %>
           uvm_config_db #(virtual dmi<%=pidx%>_generic_if)::set(uvm_root::get(),"","m_generic_dmi<%=pidx%>",m_generic_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>);
    <% } %>
    <% } %>
    <% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
    <% if (obj.DiiInfo[pidx].configuration == 0) { %>  					       
        uvm_config_db #(virtual dii<%=pidx%>_axi_if)::set(uvm_root::get(), "", "m_dii<%=pidx%>_axi_slv_if", m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>);
        uvm_config_db #(virtual dii<%=pidx%>_dii_rtl_if)::set(uvm_root::get(), "", "m_dii<%=pidx%>_rtl_if", m_rtl_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>);
    <%  if (obj.DiiInfo[pidx].interfaces.userPlaceInt._SKIP_ == false) { %>
           uvm_config_db #(virtual dii<%=pidx%>_generic_if)::set(uvm_root::get(),"","m_generic_dii<%=pidx%>",m_generic_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>);
    <% } %>
    <% } } %>
    <% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
        uvm_config_db #(virtual dce<%=pidx%>_probe_if)::set(uvm_root::get(), "", "m_dce<%=pidx%>_probe_if", dce<%=pidx%>_probe_vif);
    <% } %>
    <% for(let id = 0; id < obj.nCHIs; id++) { %>
        uvm_config_db #(virtual chi_aiu_dut_probe_if)::set(uvm_root::get(), "", "m_chiaiu<%=id%>_chi_aiu_dut_probe_if", chiaiu<%=id%>_probe_vif);
    <% } %>
    <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
        // Probe interface should be here instead of SMI. SMI interface is created and set in concerto_harness. SMI interface is get in concerto_env_cfg.
        //<% for (var i = 0; i < obj.DveInfo[pidx].nSmiRx; i++) { %>
        //uvm_config_db #(virtual dve<%=pidx%>_smi_if)::set(uvm_root::get(), "", "m_dve<%=pidx%>_smi<%=i%>_tx_port_if", m_dve<%=pidx%>_smi<%=i%>_tx_vif);
        //<% } %>
        //<% for (var i = 0; i < obj.DveInfo[pidx].nSmiTx; i++) { %>
        //uvm_config_db #(virtual dve<%=pidx%>_smi_if)::set(uvm_root::get(), "", "m_dve<%=pidx%>_smi<%=i%>_rx_port_if", m_dve<%=pidx%>_smi<%=i%>_rx_vif);
        //<% } %>

    uvm_config_db#(virtual dve<%=pidx%>_apb_if )::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "dve<%=pidx%>_m_apb_if" ),
                                        .value(dve<%=pidx%>_m_apb_if ));

    uvm_config_db#(virtual dve<%=pidx%>_clock_counter_if )::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "m_dve<%=pidx%>_clock_counter_if" ),
                                        .value(m_<%=obj.DveInfo[pidx].strRtlNamePrefix%>_clock_counter_if ));
    <% } %>

    //uvm_config_db#(virtual event_out_if )::set(null, get_full_name(), "u_event_out_if_ioaiu0",u_event_out_vif));

<% if(obj.FULL_SYS_TB) { %>
<%  if((obj.fullProject.concerto.user.misc.csrAccess.protocol == "APB") && (obj.FULL_SYS_TB !== undefined) && ((obj.INHOUSE_APB_VIP !== undefined) || (obj.INHOUSE_OCP_VIP !== undefined))) { %>
    uvm_config_db#(virtual apb_if )::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "apb_if" ),
                                        .value(apb_if ));

<%  } %>
<% } %>
<% if(obj.PmaInfo.length > 0) {
   for(var i=0; i<obj.PmaInfo.length; i++) { %>
    uvm_config_db#(virtual concerto_q_chnl_if )::set(.cntxt( uvm_root::get()),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if_<%=obj.PmaInfo[i].strRtlNamePrefix%>" ),
                                        .value(m_q_chnl_if_<%=obj.PmaInfo[i].strRtlNamePrefix%>));
<% } } %>
// FIXME - assuming all apb interfaces are the same size, use definition from ioaiu_apb_if
<% if(obj.useResiliency == 1) { %>
    if ($test$plusargs("func_unit_uncorr_err_inj") || $test$plusargs("dup_unit_uncorr_err_inj")) begin
        $value$plusargs("func_unit_uncorr_err_inj=%d",func_unit_uncorr_err_inj);
        $value$plusargs("dup_unit_uncorr_err_inj=%d",dup_unit_uncorr_err_inj);
        if(func_unit_uncorr_err_inj && dup_unit_uncorr_err_inj)  both_units_uncorr_err_inj = 1;
    end else begin
        func_unit_uncorr_err_inj = 1;
    end
    uvm_config_db#(virtual apb_debug_apb_if )::set(.cntxt( uvm_root::get()),
                                    .inst_name( "" ),
                                    .field_name( "m_apb_fsc" ),
                                    .value(m_apb_fsc));

   mission_fault_detected = new("mission_fault_detected");
   uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "mission_fault_detected" ),
                                  .value(mission_fault_detected));
   latent_fault_detected = new("latent_fault_detected");
   uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "latent_fault_detected" ),
                                  .value(latent_fault_detected));
   cerr_over_thresh_fault_detected = new("cerr_over_thresh_fault_detected");
   uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "cerr_over_thresh_fault_detected" ),
                                  .value(cerr_over_thresh_fault_detected));
<% } %>
<% if(obj.DebugApbInfo.length > 0) { %>
  `ifdef USE_VIP_SNPS_APB
     uvm_config_db#(virtual svt_apb_if)::set(.cntxt(null),
                                               .inst_name( "uvm_test_top.m_concerto_env.snps.svt.amba_system_env.apb_system[0]" ),
                                               .field_name( "vif" ),
                                               .value(m_svt_apb_if));
 `endif      
       uvm_config_db#(virtual apb_debug_apb_if )::set(.cntxt( uvm_root::get()),
                                                .inst_name( "" ),
                                                .field_name( "m_apb_debug_ncore_debug_atu" ),
                                                .value(m_apb_debug_ncore_debug_atu));
<% } %>
   toggle_clk = new("toggle_clk");
   uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "toggle_clk" ),
                                  .value(toggle_clk));
   toggle_rstn = new("toggle_rstn");
   uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "toggle_rstn" ),
                                  .value(toggle_rstn));

   hard_rstn_ev = new("hard_rstn_ev");
   uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "hard_rstn_ev" ),
                                  .value(hard_rstn_ev));

   hard_rstn_finished_ev = new("hard_rstn_finished_ev");
   uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "hard_rstn_finished_ev" ),
                                  .value(hard_rstn_finished_ev));


end //initial

//Assignments of Resp from mgc_resp_pkg HVL-HDL
// Local Registers Declaration
 <% if (obj.testBench == "emu" ){ %>

   <% io_idx = 0; obj.AiuInfo.forEach(function(bundle, idx) { %>

    <% if(_child_blk[pidx].match('ioaiu')) { %>


logic [WARID-1:0]    ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rid         ;
logic [WXDATA-1:0]   ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rdata       ;
logic [CRRESP-1:0]   ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rresp       ;
logic                ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rlast       ;
logic  [WRUSER-1:0]  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_ruser       ;
  
// ACE-LITE-E signals
logic  [WRPOISON-1:0]  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rpoison         ;
logic  [WRDATACHK-1:0] ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rdatachk       ;
logic  [WRLOOP-1:0]    ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rloop           ;
logic  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rtrace          ;
logic  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rvalid          ;
logic  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rready          ;
  
// AXI ACE Extension of Read Data Channel
    
 logic ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rack       ;

 logic                ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bid       ; 
 logic [CBRESP-1:0]   ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bresp     ; 
 logic                ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bvalid   ; 
 logic [WBUSER-1:0]   ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_buser     ; 
 logic       ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bready    ; 
 logic       ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wack      ; 
 logic       ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_awready   ;
 logic       ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_arready   ;
 logic       ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wready    ; 


  /// Write Data channel
 logic [WXDATA-1:0]   ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wdata       ;
 logic                ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wvalid   ; 
	<% io_idx++; %>
    <% } %>
    <% }) %>


initial begin

forever begin
var static pidx = 0;

<% if(_child_blk[pidx].match('ioaiu')) { %>
mgc_ace_m_if_<%=_child_blkid[pidx]%>.wait_for_clk(1);

      mgc_rsp.getXactorResp ;


 
    <% } %>

 <% io_idx = 0; obj.AiuInfo.forEach(function(bundle, idx){ %>

    <% if(_child_blk[pidx].match('ioaiu')) { %>


  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rid    =  mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rid     ;
  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rdata  =  mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rdata   ;
  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rresp  =  mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rresp   ;
  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rlast  =  mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rlast   ;
  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_ruser  =  mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_ruser   ;
  
// ACE-LITE-E signals
   ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rpoison   = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rpoison     ;
   ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rdatachk  = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rdatachk    ;
   ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rloop     = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rloop       ;
   ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rtrace    = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rtrace      ;
   ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rvalid    = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rvalid      ;
   ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rready    = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rready      ;
  
// AXI ACE Extension of Read Data Channel
    
      ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rack     = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rack        ; 
      ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bid      = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bid         ;  
      ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bresp    = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bresp       ;
      ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bvalid   = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bvalid      ;
      ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_buser    = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_buser       ;
      ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bready   = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bready      ;
      ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wack     = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wack        ;
      ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_awready  = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_awready     ;
      ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_arready  = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_arready     ;
      //ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_arready  = 1     ;
      ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wready   = mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wready      ;


     ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wdata   =    mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wdata      ;
     ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wvalid  =    mgc_rsp.ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wvalid     ; 


 //$display($time, "TB_TOP Interface::ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rdata  %h",ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rdata);
 //$display($time, "TB_TOP Interface::ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wdata  %h",ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wdata);

 
	<% io_idx++; %>
    <% } %>
    <% }) %>

end
end
 <% io_idx = 0; obj.AiuInfo.forEach(function(bundle, idx){ %>

    <% if(_child_blk[pidx].match('ioaiu')) { %>

		<% for(var n=0; n<aiu_NumCores[pidx]; n++) { %>
 //-----------------------------------------------------------------------
  // AXI Interface Read Response Channel Signals
  //-----------------------------------------------------------------------
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.rid       =  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rid     ;
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.rdata     =  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rdata   ;
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.rresp     =  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rresp   ;
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.rlast     =  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rlast   ;
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.ruser     =  ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_ruser   ;
  
// ACE-LITE-E signals
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.rpoison   = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rpoison      ;
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.rdatachk  = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rdatachk     ;
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.rloop     = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rloop        ;
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.rtrace    = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rtrace       ;
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.rvalid    = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rvalid       ;
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.rready    = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rready       ;
  
// AXI ACE Extension of Read Data Channel
    
  <% if(obj.AiuInfo[idx].fnNativeInterface == "ACE" || obj.AiuInfo[idx].fnNativeInterface == "ACE5") { %>
      assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.rack      = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rack ;
      assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.wack      = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wack ;
  <% } %>

  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.bid       = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bid; 
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.bresp     = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bresp; 
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.bvalid    = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bvalid; 
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.buser     = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_buser; 
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.bready    = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bready ;
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.awready   = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_awready ;
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.arready   = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_arready ;
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.wready    = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wready ;

  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.wdata     = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wdata ; 
  assign ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=n%>.wvalid    = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wvalid; 

//-------------------------------- EMU ASSIGN----------------

//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.rid          = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rid     ;
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.rdata        = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rdata   ;
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.rresp        = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rresp   ;
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.rlast        = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rlast   ;
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.ruser        = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_ruser   ;
//  
//// ACE-LITE-E signals
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.rpoison      = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rpoison      ;
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.rdatachk     = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rdatachk     ;
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.rloop        = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rloop        ;
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.rtrace       = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rtrace       ;
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.rvalid       = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rvalid       ;
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.rready       = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rready       ;
//  
//// AXI ACE Extension of Read Data Channel
//    
//  <% if(obj.AiuInfo[idx].fnNativeInterface == "ACE") { %>
//    assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.rack         = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_rack ;
//    assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.wack         = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wack ;
//  <% } %>
//
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.bid          = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bid; 
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.bresp        = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bresp; 
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.bvalid       = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bvalid; 
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.buser        = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_buser; 
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.bready       = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_bready ;
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.awready      = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_awready ;
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.arready      = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_arready ;
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.wready       = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wready ;
//
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.wdata        = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wdata ; 
//  assign m_ace_emu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>.wvalid       = ioaiu_if_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_wvalid; 
 

 
	<% io_idx++; %>
    <% } %>
    <% } %>
    <% }) %>

 
    <% } %> 


bit [<%=clocks.length-1%>:0] enable;
<% for(var clock=0; clock < clocks.length; clock++) { %>
initial enable[<%=clock%>] = 1'b1;
<% var clockName = clocks[clock] + "_dut_clk";
   var pma;
   for(pma=0; pma < obj.PmaInfo.length; pma++) {
     unitClk = obj.PmaInfo[pma].unitClk + "dut_clk";
     if(clockName.match(unitClk)) {
       //console.log("matching PMA " + pma + " with unitClk " +  obj.PmaInfo[pma].unitClk);
       if(obj.PmaInfo[pma].interfaces.clkInt.params.blkClkGateOn == 1) {
%>
// matched clock <%=clockName%> with pma <%=unitClk%>
always @(negedge sys_clk) begin
   enable[<%=clock%>] = !(~m_q_chnl_if_<%=obj.PmaInfo[pma].strRtlNamePrefix%>.QREQn &&
                         ~m_q_chnl_if_<%=obj.PmaInfo[pma].strRtlNamePrefix%>.QACCEPTn);
end
<%
       }
       break;
     }
   }
%>

assign <%=clocks[clock]%>_dut_clk = enable[<%=clock%>] ? m_clk_if_<%=clocks[clock]%>.clk : 0 ;

<% if(obj.testBench=="emu") { %>
assign <%=clocks[clock]%>_dut_clk_emu = enable[<%=clock%>] ? concerto_tb_aclk : 0 ;
<% } %>
<% } %>
assign dut_clk = (|enable) ? sys_clk : 0;

<% if(obj.testBench=="emu") { %>
assign dut_clk_emu = (|enable) ? concerto_tb_aclk : 0;
<% } %>

bit soft_rstn_en=1;
always @(posedge sys_clk) begin
    toggle_rstn.wait_trigger();
    @(negedge sys_clk);
    $display("triggered reset event @time: %0t",$time);
    soft_rstn_en = ~soft_rstn_en;
end

 <% if (obj.testBench != "emu" ) { %>
int 	reset_time = 50;
initial begin
    hard_rstn_ev.wait_trigger();
    $display("triggered hard reset event @time: %0t",$time);
<% for(var clock=0; clock < clocks.length; clock++) { %>
    force m_clk_if_<%=clocks[clock]%>.reset_n = 0;
<% } %>
    #(reset_time*1ns);
<% for(var clock=0; clock < clocks.length; clock++) { %>
    release m_clk_if_<%=clocks[clock]%>.reset_n;						      
<% } %>
    @(posedge sys_clk);
    @(negedge sys_clk);
    hard_rstn_finished_ev.trigger();
end

    <% } %>
<% if(obj.useResiliency) { %>
always @(posedge m_master_fsc.mission_fault) begin
    mission_fault_detected.trigger();
    $display("triggered mission_fault_detected @time: %0t",$time);
end
always @(negedge m_master_fsc.mission_fault) begin
    mission_fault_detected.reset();
    $display("Released mission_fault_detected @time: %0t",$time);
end
always @(posedge m_master_fsc.latent_fault) begin
    latent_fault_detected.trigger();
    $display("triggered latent_fault_detected @time: %0t",$time);
end
always @(negedge m_master_fsc.latent_fault) begin
    latent_fault_detected.reset();
    $display("Released latent_fault_detected @time: %0t",$time);
end
always @(posedge m_master_fsc.cerr_over_thres_fault) begin
    cerr_over_thresh_fault_detected.trigger();
    $display("triggered cerr_over_thresh_fault_detected @time: %0t",$time);
end
always @(negedge m_master_fsc.cerr_over_thres_fault) begin
    cerr_over_thresh_fault_detected.reset();
    $display("Released cerr_over_thresh_fault_detected @time: %0t",$time);
end
initial begin
    if($test$plusargs("disable_bist"))begin
        <%=itf_dbg_pin_name%>.pin = 1'b0;
    end else begin
        <%=itf_dbg_pin_name%>.pin = 1'b1;
    end
end
initial begin
    uvm_config_db#(virtual fault_if)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "m_master_fsc" ),
                                  .value(m_master_fsc));
end
<% } %>

<% for(var clock=0; clock < clocks.length; clock++) { %>
assign <%=clocks[clock]%>_soft_rstn = soft_rstn_en ? m_clk_if_<%=clocks[clock]%>.reset_n : 0 ;
<% if(obj.testBench=="emu") { %>
assign <%=clocks[clock]%>_soft_rstn_emu = soft_rstn_en ? concerto_tb_aresetn : 0 ;
<% } %>
<% } %>
assign soft_rstn = soft_rstn_en ? sys_rstn : 0;

 always@(~<%=obj.AiuInfo[0].nativeClk%>soft_rstn)
 $assertoff(0, tb_top); 
<% if(obj.testBench=="emu") { %>
assign soft_rstn_emu = soft_rstn_en ? concerto_tb_aresetn : 0;
<% } %>
//Test call
initial begin
    $timeformat(-9,0,"ns",0);
    `ifdef DUMP_ON
        if($test$plusargs("en_dump")) begin
            <%  if(obj.SYS_CDNS_ACE_VIP) { %>
                $shm_open("waves.shm");
                $shm_probe("AS");
            <%  } else { %>
               <% if(obj.testBench !=="emu") { %>
               `ifdef VCS // TO-DO : CONC-11829
                 $vcdpluson;
                 $vcdplusmemon;
                if($test$plusargs("solvnet_dump")) begin
                 $vcdplusoff(tb_top.dut); //Does not dump signal value
                end
               `endif
            <%  } %>
            <%  } %>
        end
    `endif
    run_test();
    $finish;
end
<% var hier_path_dut = ['tb_top.dut']; %>
<% if(obj.useResiliency) { %>
 fsys_fault_injector_checker fault_injector_checker(<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.clk_clk, soft_rstn);
  ph_connectivity_checker ph_connec_chk(dut_clk, soft_rstn);
//  initial begin
//    uvm_config_db#(event)::set(.cntxt(null),
//                               .inst_name( "*" ),
//                               .field_name( "kill_test" ),
//                               .value(placeholder_connec_chk.kill_test));
//  end

<% } %>
   <% if(obj.testBench !=="emu") { %>
   mem_wrapper_connectivity_checker memwrpr_check (dut_clk, soft_rstn);
   <%  } %>

<% if(obj.FULL_SYS_TB) { %>

    <% obj.ClockPorts.uniquePorts.forEach(function(e) {
            /*Random numbers bewtween 1 to 10 */
            var timeDelay = Math.floor(Math.random() * (10 - 2)) + 1; %>
            initial begin
                int t = $urandom_range(5, 50);
                <%=e.sig2%>  <= 1'b0;
                forever
                    #t <%=e.sig2%> <= ~<%=e.sig2%>;
            end
        <% }
    ); %>

    <% obj.ResetPorts.uniquePorts.forEach(function(e, i, array) { %>
            initial begin
                <%=e.sig2%>  <= 1'b0;
                repeat(2) @(posedge <%=obj.ClockPorts.uniquePorts[i].sig2%>);

                <%=e.sig2%>  <= 1'b0;
                repeat(10) @(posedge <%=obj.ClockPorts.uniquePorts[i].sig2%>);
                <%=e.sig2%>  <= 1'b1;
                repeat(2) @(posedge <%=obj.ClockPorts.uniquePorts[i].sig2%>);
            end

        <% }
    ); %>

<% } else { %>
//-----------------------------------------------------------------------------
// Generate clocks and reset
//-----------------------------------------------------------------------------
`ifndef ARTERIS_TBX
<% var slowest_clk_idx = 0; %>
<% for(var clock=0; clock < obj.Clocks.length; clock++) { %>
clk_rst_gen <%=clocks[clock]%>_gen(.clk_fr(m_clk_if_<%=clocks[clock]%>.clk), .clk_tb(<%=clocks[clock]%>_clk_sync), .rst(m_clk_if_<%=clocks[clock]%>.reset_n));
defparam <%=clocks[clock]%>_gen.CLK_PERIOD = <%=obj.Clocks[clock].params.period%>;
<% if (obj.Clocks[slowest_clk_idx].params.period < obj.Clocks[clock].params.period) { slowest_clk_idx = clock; } %>
<% } %>
`endif 

    // Use first customer defined clock as sys_clk. Customer needs to confirm to this
    assign sys_clk  = m_clk_if_<%=clocks[slowest_clk_idx]%>.clk;
    assign sys_rstn = m_clk_if_<%=clocks[slowest_clk_idx]%>.reset_n;

<% if(obj.testBench =="emu") { %>

  assign sys_clk_emu  = concerto_tb_aclk;
  assign sys_rstn_emu= concerto_tb_aresetn;
  assign concerto_tb_aclk_emu = concerto_tb_aclk_chk;
  assign concerto_tb_aresetn_emu = concerto_tb_aresetn_chk; 
     

clock_n_reset clk_n_reset_gen (.tb_aclk(concerto_tb_aclk_chk) , .tb_aresetn(concerto_tb_aresetn_chk) );


<% }%>

<% }%>
            
//
//Zero Time memory initialization forces
// Valid only if 
<% if (obj.testBench != "emu" ) { %>
initial begin
    if($test$plusargs("conc_6222")) begin
<%if(obj.AiuInfo[0].hierPath && obj.AiuInfo[0].hierPath !== ''){%>
        force  tb_top.dut.<%=obj.AiuInfo[0].instancePath%>.apb_pslverr = 1;
<% } else {%>
        force  tb_top.dut.<%=obj.AiuInfo[0].strRtlNamePrefix%>.apb_pslverr = 1;
<% } %>
    end
end
<% }%>
task assert_error(input string verbose, input string msg);

    //repeat (2) 
    //    @(posedge sys_clk);

    if(verbose == "FATAL") begin 
        `uvm_fatal("ASSERT_ERROR", msg); 
    end else begin 
        `uvm_error("ASSERT_ERROR", msg); 
    end
endtask: assert_error
`ifdef ERROR_EN

//Inject Directed Uncorrectible Errors
//initial begin: errors_inj_blk
//    concerto_error_inj_helper m_err_helper;
//    //Construct the error injection object and forward it to concerto_system_error_test
//    m_err_helper = concerto_error_inj_helper::type_id::create("m_err_helper");
//    uvm_config_db #(concerto_error_inj_helper)::set(
//        .cntxt(uvm_root::get()),
//        .inst_name(""),
//        .field_name("m_err_helper"),
//        .value(m_err_helper));
//
//   // forever begin
//   //     error_info_type_s m_error_info;
//
//   //     m_err_helper.get_error_type_info(m_error_info);
//   //     `uvm_info("concerto_tb_top", $psprintf("Injecting error info: %s",
//   //         m_err_helper.err_type_conv2str(m_error_info)), UVM_LOW)
//   // end
//
//end: errors_inj_blk


//Force errors and if single_bit_error_inj plusarg is defined
//then correctible errors are injected 
initial begin: error_test_blk
    string fnErrDetectCorrect0, fnErrDetectCorrect1, fnErrDetectCorrect2;

    //Forcing errors enable signals if OCP driver is not instantiated
<%  if(!((obj.SYS_SNPS_OCP_VIP) || (obj.INHOUSE_OCP_VIP) || (obj.INHOUSE_APB_VIP))) { %>
    //Dmi Forces
    fork
<%      obj.DmiInfo.forEach(function(bundle, indx, array) { %>
        begin
            @(posedge `DMI<%=indx%>.reset_n);
            @(posedge `DMI<%=indx%>.clk);

            force `DMI<%=indx%>.csr_reg.o_CMIUCECR_ErrDetEn = 1;
            force `DMI<%=indx%>.csr_reg.o_CMIUUECR_ErrDetEn = 1;
            force `DMI<%=indx%>.csr_reg.o_CMIUCECR_ErrDetEn_en = 1;
            force `DMI<%=indx%>.csr_reg.o_CMIUUECR_ErrDetEn_en = 1;

            force `DMI<%=indx%>.csr_reg.o_CMIUCECR_ErrIntEn = 1;
            force `DMI<%=indx%>.csr_reg.o_CMIUUECR_ErrIntEn = 1;
            force `DMI<%=indx%>.csr_reg.o_CMIUCECR_ErrIntEn_en = 1;
            force `DMI<%=indx%>.csr_reg.o_CMIUUECR_ErrIntEn_en = 1;

            @(posedge `DMI<%=indx%>.clk);
            release `DMI<%=indx%>.csr_reg.o_CMIUCECR_ErrDetEn;
            release `DMI<%=indx%>.csr_reg.o_CMIUUECR_ErrDetEn;
            release `DMI<%=indx%>.csr_reg.o_CMIUCECR_ErrDetEn_en;
            release `DMI<%=indx%>.csr_reg.o_CMIUUECR_ErrDetEn_en;

            release `DMI<%=indx%>.csr_reg.o_CMIUCECR_ErrIntEn;
            release `DMI<%=indx%>.csr_reg.o_CMIUUECR_ErrIntEn;
            release `DMI<%=indx%>.csr_reg.o_CMIUCECR_ErrIntEn_en;
            release `DMI<%=indx%>.csr_reg.o_CMIUUECR_ErrIntEn_en;
            <% if(obj.useResiliency) { %>
               <% if(obj.FULL_SYS_TB) { %>
                 repeat(<%=obj.DmiInfo[indx].ResilienceInfo.nResiliencyDelay%>-1)  @(posedge <%=obj.ClockPorts.dmiPorts[indx]%>);
               <% } else { %>
                 repeat(<%=obj.DmiInfo[indx].ResilienceInfo.nResiliencyDelay%>-1)  @ (posedge dut_clk);
               <% } %>
                force `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUCECR_ErrDetEn = 1;
                force `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUUECR_ErrDetEn = 1;
                force `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUCECR_ErrDetEn_en = 1;
                force `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUUECR_ErrDetEn_en = 1;

                force `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUCECR_ErrIntEn = 1;
                force `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUUECR_ErrIntEn = 1;
                force `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUCECR_ErrIntEn_en = 1;
                force `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUUECR_ErrIntEn_en = 1;
                @(posedge `DMI<%=indx%>.clk);
                release `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUCECR_ErrDetEn;
                release `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUUECR_ErrDetEn;
                release `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUCECR_ErrDetEn_en;
                release `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUUECR_ErrDetEn_en;

                release `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUCECR_ErrIntEn;
                release `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUUECR_ErrIntEn;
                release `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUCECR_ErrIntEn_en;
                release `DMI<%=indx%>_wrapper.dmi_checker.dmi.csr_reg.o_CMIUUECR_ErrIntEn_en;
<%          } %>
        end
<%      }); %>
    join
<%  } %>

    if($test$plusargs("single_bit_error_inj")) begin
<% obj.DmiInfo.forEach(function(bundle, indx, array) { %>
<%      if(bundle.cmpInfo.useMemRspIntrlv) { %>
            fnErrDetectCorrect0 = "<%=bundle.fnErrDetectCorrect%>";
            if((fnErrDetectCorrect0 == "SECDED")         || 
               (fnErrDetectCorrect0 == "SECDED64BITS")   || 
               (fnErrDetectCorrect0 == "SECDED128BITS")) begin

                `DMI<%=indx%>_wrapper.rtt_data.internal_mem_inst.inject_errors(10,0,0);
            end
<%      } %>
<%      if(bundle.useCmc) { %>
            fnErrDetectCorrect1 = "<%=bundle.ccpParams.TagErrInfo%>";
            if((fnErrDetectCorrect1 == "SECDED")         || 
               (fnErrDetectCorrect1 == "SECDED64BITS")   || 
               (fnErrDetectCorrect1 == "SECDED128BITS")) begin

<%          for(var tagIdx = 0; tagIdx < bundle.ccpParams.nTagBanks; tagIdx++) { %>
                `DMI<%=indx%>_wrapper.cmc_tag<%=tagIdx%>.internal_mem_inst.inject_errors(10,0,0);
<%          } %>
            end

            fnErrDetectCorrect2 = "<%=bundle.ccpParams.DataErrInfo%>";
            if((fnErrDetectCorrect2 == "SECDED")         || 
               (fnErrDetectCorrect2 == "SECDED64BITS")   || 
               (fnErrDetectCorrect2 == "SECDED128BITS")) begin

<%          for(var datIdx = 0; datIdx < bundle.ccpParams.nDataBanks; datIdx++) { %>
                `DMI<%=indx%>_wrapper.cmc_data<%=datIdx%>.internal_mem_inst.inject_errors(10,0,0);
<%          } %>
            end
<%      } %>
<%    }); %>

    end
end: error_test_blk

`endif
// Cover property to check whether interrupt have been asserted for each unit
/*
<% for (var pidx = 0; pidx < obj.nAIUs; pidx++) { %>

    IRQ_C_AgentAiu<%=pidx%>: cover property ( @ (posedge `AIU<%=pidx%>.clk) disable iff (~`AIU<%=pidx%>.reset_n) ( `AIU<%=pidx%>.IRQ_c == 1'b1 ) ) `uvm_info("", $sformatf("Detect Correctable Interrupt for Agent AIU<%=pidx%>"), UVM_HIGH);
    IRQ_UC_AgentAiu<%=pidx%>: cover property ( @ (posedge `AIU<%=pidx%>.clk) disable iff (~`AIU<%=pidx%>.reset_n) ( `AIU<%=pidx%>.IRQ_uc == 1'b1 ) ) `uvm_info("", $sformatf("Detect Uncorrectable Interrupt for Agent AIU<%=pidx%>"), UVM_HIGH);

<% } %>


<% for (var pidx = 0; pidx < obj.nDCEs; pidx++) { %>

    <% if (pidx == 0) { %>
        //IRQ_C_Dce<%=pidx%>: cover property ( @ (posedge `DCE<%=pidx%>.clk) disable iff (~`DCE<%=pidx%>.reset_n) ( `DCE<%=pidx%>.dce0_correctible_error_irq.in_data == 1'b1 ) ) `uvm_info("", $sformatf("Detect Correctable Interrupt for DCE<%=pidx%>"), UVM_HIGH);
        //IRQ_UC_Dce<%=pidx%>: cover property ( @ (posedge `DCE<%=pidx%>.clk) disable iff (~`DCE<%=pidx%>.reset_n) ( `DCE<%=pidx%>.dce0_uncorrectible_error_irq.in_data == 1'b1 ) ) `uvm_info("", $sformatf("Detect Uncorrectable Interrupt for DCE<%=pidx%>"), UVM_HIGH);
    <% } else { %>
        IRQ_C_Dce<%=pidx%>: cover property ( @ (posedge `DCE<%=pidx%>.clk) disable iff (~`DCE<%=pidx%>.reset_n) ( `DCE<%=pidx%>.correctible_error_irq == 1'b1 ) ) `uvm_info("", $sformatf("Detect Correctable Interrupt for DCE<%=pidx%>"), UVM_HIGH);
        IRQ_UC_Dce<%=pidx%>: cover property ( @ (posedge `DCE<%=pidx%>.clk) disable iff (~`DCE<%=pidx%>.reset_n) ( `DCE<%=pidx%>.uncorrectible_error_irq == 1'b1 ) ) `uvm_info("", $sformatf("Detect Uncorrectable Interrupt for DCE<%=pidx%>"), UVM_HIGH);
    <% } %>


<% } %>
*/
<% if(obj.testBench!="emu") { %>
ncore_probe_module trace_ncore();
<%}%>

   // ARM AXI Assertions
`ifdef  ASSERT_ON
`ifndef ASSERT_OFF
    <% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
wire #1 dmi<%=pidx%>_clk = <%=obj.DmiInfo[pidx].unitClk[0]%>dut_clk; // add delay to avoid delta time issue
dmi<%=pidx%>_Axi4PC_ace #(.ADDR_WIDTH(<%=obj.DmiInfo[pidx].interfaces.axiInt.params.wAddr%>),
	     .WID_WIDTH( <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wAwId%>),
	     .RID_WIDTH( <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wArId%>),
	     .AWUSER_WIDTH( <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wAwUser%>),
	     .WUSER_WIDTH( <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wWUser%>),
	     .BUSER_WIDTH( <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wBUser%>),
	     .ARUSER_WIDTH( <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wArUser%>),
	     .RUSER_WIDTH( <%=obj.DmiInfo[pidx].interfaces.axiInt.params.wRUser%>),
	     .DATA_WIDTH(<%=obj.DmiInfo[pidx].interfaces.axiInt.params.wData%>))
   m_axi4_arm_sva_<%=obj.DmiInfo[pidx].strRtlNamePrefix%> (
   // Global Signals
   .ACLK                     ( dmi<%=pidx%>clk) ,
   .ARESETn                  ( soft_rstn                          ) ,
   // Write Address Channel
   .AWID                     ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.awid                ) ,
   .AWADDR                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.awaddr              ) ,
   .AWLEN                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.awlen               ) ,
   .AWSIZE                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.awsize              ) ,
   .AWBURST                  ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.awburst             ) ,
   .AWLOCK                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.awlock              ) ,
   .AWCACHE                  ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.awcache             ) ,
   .AWPROT                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.awprot              ) ,
   <% if(obj.DmiInfo[pidx].interfaces.axiInt.params.wAwUser > 0) { %>
   .AWUSER                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.awuser              ) ,
   <% } %>
   <% if(obj.DmiInfo[pidx].interfaces.axiInt.params.wQos > 0) { %>
   .AWQOS                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.awqos               ) ,
   <% } %>
   <% if(obj.DmiInfo[pidx].interfaces.axiInt.params.wRegion > 0) { %>
   .AWREGION                 ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.awregion            ) ,
   <% } %>
   .AWVALID                  ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.awvalid             ) ,
   .AWREADY                  ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.awready             ) ,
   // Write Channel
   .WDATA                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.wdata               ) ,
   .WSTRB                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.wstrb               ) ,
   <% if(obj.DmiInfo[pidx].interfaces.axiInt.params.wWUser > 0) { %>
   .WUSER                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.wuser               ) ,
   <% } %>
   .WLAST                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.wlast               ) ,
   .WVALID                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.wvalid              ) ,
   .WREADY                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.wready              ) ,
   // Write Response Channel
   .BID                      ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.bid                 ) ,
   .BRESP                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.bresp               ) ,
   <% if(obj.DmiInfo[pidx].interfaces.axiInt.params.wBUser > 0) { %>
   .BUSER                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.buser               ) ,
   <% } %>
   .BVALID                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.bvalid              ) ,
   .BREADY                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.bready              ) ,
   // Read Address Channel
   .ARID                     ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.arid                ) ,
   .ARADDR                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.araddr              ) ,
   <% if(obj.DmiInfo[pidx].interfaces.axiInt.params.wRegion > 0) { %>
   .ARREGION                 ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.arregion            ) ,
   <% } %>
   .ARLEN                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.arlen               ) ,
   .ARSIZE                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.arsize              ) ,
   .ARBURST                  ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.arburst             ) ,
   .ARLOCK                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.arlock              ) ,
   .ARCACHE                  ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.arcache             ) ,
   .ARPROT                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.arprot              ) ,
   <% if(obj.DmiInfo[pidx].interfaces.axiInt.params.wArUser > 0) { %>
   .ARUSER                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.aruser              ) ,
   <% } %>
   <% if(obj.DmiInfo[pidx].interfaces.axiInt.params.wQos > 0) { %>
   .ARQOS                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.arqos               ) ,
   <% } %>
   .ARVALID                  ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.arvalid             ) ,
   .ARREADY                  ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.arready             ) ,
   //  Read Channel
   .RID                      ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.rid                 ) ,
   .RLAST                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.rlast               ) ,
   .RDATA                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.rdata               ) ,
   .RRESP                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.rresp               ) ,
   <% if(obj.DmiInfo[pidx].interfaces.axiInt.params.wRUser > 0) { %>
   .RUSER                    ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.ruser               ) ,
   <% } %>
   .RVALID                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.rvalid              ) ,
   .RREADY                   ( m_axi_slv_if_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.rready              ) ,
   // Low Power Interface
   .CACTIVE                  ( 1'b1                              ) ,
   .CSYSREQ                  ( 1'b1                              ) ,
   .CSYSACK                  ( 1'b1                              )
) ;
<% } %>
    <% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
    <% if (obj.DiiInfo[pidx].configuration == 0) { %>  					       
wire #1 dii<%=pidx%>_clk = <%=obj.DiiInfo[pidx].unitClk[0]%>dut_clk; // add delay to avoid delta time issue
dii<%=pidx%>_Axi4PC_ace #(.ADDR_WIDTH(<%=obj.DiiInfo[pidx].interfaces.axiInt.params.wAddr%>),
	     .WID_WIDTH( <%=obj.DiiInfo[pidx].interfaces.axiInt.params.wAwId%>),
	     .RID_WIDTH( <%=obj.DiiInfo[pidx].interfaces.axiInt.params.wArId%>),
	     .AWUSER_WIDTH( <%=obj.DiiInfo[pidx].interfaces.axiInt.params.wAwUser%>),
	     .WUSER_WIDTH( <%=obj.DiiInfo[pidx].interfaces.axiInt.params.wWUser%>),
	     .BUSER_WIDTH( <%=obj.DiiInfo[pidx].interfaces.axiInt.params.wBUser%>),
	     .ARUSER_WIDTH( <%=obj.DiiInfo[pidx].interfaces.axiInt.params.wArUser%>),
	     .RUSER_WIDTH( <%=obj.DiiInfo[pidx].interfaces.axiInt.params.wRUser%>),
	     .DATA_WIDTH(<%=obj.DiiInfo[pidx].interfaces.axiInt.params.wData%>))
   m_axi4_arm_sva_<%=obj.DiiInfo[pidx].strRtlNamePrefix%> (
   // Global Signals
   .ACLK                     ( dii<%=pidx%>_clk) ,
   .ARESETn                  ( soft_rstn                          ) ,
   // Write Address Channel
   .AWID                     ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.awid                ) ,
   .AWADDR                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.awaddr              ) ,
   .AWLEN                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.awlen               ) ,
   .AWSIZE                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.awsize              ) ,
   .AWBURST                  ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.awburst             ) ,
   .AWLOCK                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.awlock              ) ,
   .AWCACHE                  ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.awcache             ) ,
   .AWPROT                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.awprot              ) ,
   <% if(obj.DiiInfo[pidx].interfaces.axiInt.params.wAwUser > 0) { %>
   .AWUSER                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.awuser              ) ,
   <% } %>
   <% if(obj.DiiInfo[pidx].interfaces.axiInt.params.wQos > 0) { %>
   .AWQOS                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.awqos               ) ,
   <% } %>
   <% if(obj.DiiInfo[pidx].interfaces.axiInt.params.wRegion > 0) { %>
   .AWREGION                 ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.awregion            ) ,
   <% } %>
   .AWVALID                  ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.awvalid             ) ,
   .AWREADY                  ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.awready             ) ,
   // Write Channel
   .WDATA                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.wdata               ) ,
   .WSTRB                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.wstrb               ) ,
   <% if(obj.DiiInfo[pidx].interfaces.axiInt.params.wWUser > 0) { %>
   .WUSER                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.wuser               ) ,
   <% } %>
   .WLAST                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.wlast               ) ,
   .WVALID                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.wvalid              ) ,
   .WREADY                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.wready              ) ,
   // Write Response Channel
   .BID                      ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.bid                 ) ,
   .BRESP                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.bresp               ) ,
   <% if(obj.DiiInfo[pidx].interfaces.axiInt.params.wBUser > 0) { %>
   .BUSER                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.buser               ) ,
   <% } %>
   .BVALID                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.bvalid              ) ,
   .BREADY                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.bready              ) ,
   // Read Address Channel
   .ARID                     ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.arid                ) ,
   .ARADDR                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.araddr              ) ,
   <% if(obj.DiiInfo[pidx].interfaces.axiInt.params.wRegion > 0) { %>
   .ARREGION                 ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.arregion            ) ,
   <% } %>
   .ARLEN                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.arlen               ) ,
   .ARSIZE                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.arsize              ) ,
   .ARBURST                  ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.arburst             ) ,
   .ARLOCK                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.arlock              ) ,
   .ARCACHE                  ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.arcache             ) ,
   .ARPROT                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.arprot              ) ,
   <% if(obj.DiiInfo[pidx].interfaces.axiInt.params.wArUser > 0) { %>
   .ARUSER                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.aruser              ) ,
   <% } %>
   <% if(obj.DiiInfo[pidx].interfaces.axiInt.params.wQos > 0) { %>
   .ARQOS                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.arqos               ) ,
   <% } %>
   .ARVALID                  ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.arvalid             ) ,
   .ARREADY                  ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.arready             ) ,
   //  Read Channel
   .RID                      ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.rid                 ) ,
   .RLAST                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.rlast               ) ,
   .RDATA                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.rdata               ) ,
   .RRESP                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.rresp               ) ,
   <% if(obj.DiiInfo[pidx].interfaces.axiInt.params.wRUser > 0) { %>
   .RUSER                    ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.ruser               ) ,
   <% } %>
   .RVALID                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.rvalid              ) ,
   .RREADY                   ( m_axi_slv_if_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.rready              ) ,
   // Low Power Interface
   .CACTIVE                  ( 1'b1                              ) ,
   .CSYSREQ                  ( 1'b1                              ) ,
   .CSYSACK                  ( 1'b1                              )
) ;
<% } } %>

<% var chi_idx=0;
   var io_idx=0;   
   for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
     if(_child_blk[pidx].match('chiaiu')) { %>
/*
Chi5PC_if #(.MAX_OS_REQ(32),
  .MAX_OS_SNP(16),
  .MAX_OS_EXCL(8),
  .numChi5nodes(6),
  .nodeIdQ('{0,1,2,4,8,16}),
  .NODE_ID(2)
//  .NODE_TYPE(Chi5PC_pkg::RNF),
//  .devQ('{Chi5PC_pkg::HNF, // 0
//          Chi5PC_pkg::SNF, // 1
//          Chi5PC_pkg::SNI, // 2
//          Chi5PC_pkg::SNF, // 4
//          Chi5PC_pkg::SNI, // 8
//          Chi5PC_pkg::HNI}), // 16
//  .DAT_FLIT_WIDTH(Chi5PC_pkg::CHI5PC_DAT_128B)
) CHI5PCInt_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(
  .SRESETn(soft_rstn),
  .TXLINKACTIVEREQ(m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_link_active_req),
  .TXLINKACTIVEACK(m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_link_active_ack),

  .TXREQFLITPEND  (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_req_flit_pend  ),
  .TXREQFLITV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_req_flitv      ),
  .TXREQFLIT      (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_req_flit       ),
  .TXREQLCRDV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_req_lcrdv      ),

  .TXRSPFLITPEND  (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_rsp_flit_pend  ),
  .TXRSPFLITV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_rsp_flitv      ),
  .TXRSPFLIT      (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_rsp_flit       ),
  .TXRSPLCRDV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_rsp_lcrdv      ),

  .TXDATFLITPEND  (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_dat_flit_pend  ),
  .TXDATFLITV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_dat_flitv      ),
  .TXDATFLIT      (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_dat_flit       ),
  .TXDATLCRDV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_dat_lcrdv      ),

  //.TXSNPFLITV   (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_snp_flit_pend  ),
  //.TXSNPFLIT    (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_snp_flitv      ),
  //.TXSNPLCRDV   (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_snp_flit       ),
  //.TXSNPFLITPEND(m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_snp_lcrdv      ),

  .RXLINKACTIVEREQ(m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_link_active_req),
  .RXLINKACTIVEACK(m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_link_active_ack),

  .RXREQFLITPEND  (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_req_flit_pend  ),
  .RXREQFLITV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_req_flitv      ),
  .RXREQFLIT      (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_req_flit       ),
  .RXREQLCRDV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_req_lcrdv      ),

  .RXRSPFLITPEND  (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_rsp_flit_pend  ),
  .RXRSPFLITV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_rsp_flitv      ),
  .RXRSPFLIT      (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_rsp_flit       ),
  .RXRSPLCRDV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_rsp_lcrdv      ),

  .RXDATFLITPEND  (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_dat_flit_pend  ),
  .RXDATFLITV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_dat_flitv      ),
  .RXDATFLIT      (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_dat_flit       ),
  .RXDATLCRDV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_dat_lcrdv      ),

  .RXSNPFLITPEND  (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_snp_flit_pend  ),
  .RXSNPFLITV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_snp_flitv      ),
  .RXSNPFLIT      (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_snp_flit       ),
  .RXSNPLCRDV     (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_snp_lcrdv      ),

  .TXSACTIVE      (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.tx_s_active       ),
  .RXSACTIVE      (m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.rx_s_active       ) //FIXME: Missing signal in AIU RTL m_chi_vif.rx_s_active) //CHI protocol section 13.7.3
  //.RXSACTIVE      (0) //FIXME: Missing signal in AIU RTL m_chi_vif.rx_s_active) //CHI protocol section 13.7.3
);
Chi5PC #(
  .ErrorOn_SW(1),
  .RecommendOn(1),
  .RecommendOn_Haz(1),
  .MAX_OS_REQ(32),
  .MAX_OS_EXCL(8),
  .MAX_OS_SNP(16),
  .NODE_ID(2),
  .CRDGRANT_BEFORE_RETRY(1),
  .MAXLLCREDITS(16),
  .DAT_FLIT_WIDTH(128)
) u_Chi5PC_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(
  .Chi5_in (CHI5PCInt_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>),
  .SCLK (chi_clk)
);*/
	<% chi_idx++;
     } else if(_child_blk[pidx].match('ioaiu')) { 
        if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')) { %>
<% for (var i=0; i<aiu_NumCores[pidx]; i++) { %>
wire #1 ioaiu<%=pidx%>_<%=i%>_clk = <%=obj.AiuInfo[pidx].unitClk[0]%>dut_clk; // add delay to avoid delta time issue
<% if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') { %>
ioaiu<%=io_idx%>_Axi4PC_ace #(
<% } else { %>
ioaiu<%=io_idx%>_AceLitePC #(
<% } %>
             .ADDR_WIDTH(<%=aiu_axiInt[pidx][0].params.wAddr%>),
	     .WID_WIDTH( <%=aiu_axiInt[pidx][0].params.wAwId%>),
	     .RID_WIDTH( <%=aiu_axiInt[pidx][0].params.wArId%>),
	     .AWUSER_WIDTH( <%=aiu_axiInt[pidx][0].params.wAwUser%>),
	     .WUSER_WIDTH( <%=aiu_axiInt[pidx][0].params.wWUser%>),
	     .BUSER_WIDTH( <%=aiu_axiInt[pidx][0].params.wBUser%>),
	     .ARUSER_WIDTH( <%=aiu_axiInt[pidx][0].params.wArUser%>),
	     .RUSER_WIDTH( <%=aiu_axiInt[pidx][0].params.wRUser%>),
	     .DATA_WIDTH(<%=aiu_axiInt[pidx][0].params.wData%>)
           ) m_axi_arm_sva_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>   (
   // Global Signals
   .ACLK                     ( ioaiu<%=pidx%>_<%=i%>_clk) ,
   .ARESETn                  ( <%=obj.AiuInfo[pidx].nativeClk%>soft_rstn) ,

   // Write Address Channel
   .AWID                     ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awid     ) ,
   .AWADDR                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awaddr   ) ,
   .AWLEN                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awlen    ) ,
   .AWSIZE                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awsize   ) ,
   .AWBURST                  ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awburst  ) ,
   .AWLOCK                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awlock   ) ,
   .AWCACHE                  ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awcache  ) ,
   .AWPROT                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awprot   ) ,
<%if(aiu_axiInt[pidx][0].params.wAwUser > 0) {%>
   .AWUSER                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awuser            ) ,
<% } else { %>
   .AWUSER                   ( 'h0            ) ,
<% } %>
<%if (aiu_axiInt[pidx][0].params.wQos > 0) {%>
   .AWQOS                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awqos             ) ,
<% } else { %>
   .AWQOS                    ( 'h0            ) ,
<% } %>
<%if(aiu_axiInt[pidx][0].params.wRegion > 0) {%>
   .AWREGION                 ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awregion          ) ,
<% } else { %>
   .AWREGION                 ( 'h0            ) ,
<% } %>
   .AWVALID                  ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awvalid  ) ,
   .AWREADY                  ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awready  ) ,
   <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { %>
   .AWSNOOP                  ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awsnoop  ) ,
   .AWDOMAIN                 ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awdomain ) ,
   .AWBAR                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.awbar    ) ,
   <%} %>
   // Write Channel
   .WDATA                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.wdata    ) ,
   .WSTRB                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.wstrb    ) ,
<%if(aiu_axiInt[pidx][0].params.wWUser > 0) {%>
   .WUSER                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.wuser    ) ,
<% } else { %>
   .WUSER                    ( 'h0            ) ,
<% } %>
   .WLAST                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.wlast    ) ,
   .WVALID                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.wvalid   ) ,
   .WREADY                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.wready   ) ,

   // Write Response Channel
   .BID                      ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.bid      ) ,
   .BRESP                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.bresp    ) ,
<%if(aiu_axiInt[pidx][0].params.wBUser > 0) {%>
   .BUSER                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.buser    ) ,
<% } else { %>
   .BUSER                    ( 'h0            ) ,
<% } %>
   .BVALID                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.bvalid   ) ,
   .BREADY                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.bready   ) ,

   // Read Address Channel
   .ARID                     ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arid     ) ,
   .ARADDR                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.araddr   ) ,
   .ARLEN                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arlen    ) ,
   .ARSIZE                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arsize   ) ,
   .ARBURST                  ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arburst  ) ,
   .ARLOCK                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arlock   ) ,
   .ARCACHE                  ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arcache  ) ,
   .ARPROT                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arprot   ) ,
   .ARVMID                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arvmidext) ,
<%if(aiu_axiInt[pidx][0].params.wArUser > 0) {%>
   .ARUSER                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.aruser               ) ,
<% } else { %>
   .ARUSER                    ( 'h0            ) ,
<% } %>
<%if(aiu_axiInt[pidx][0].params.wQos > 0) {%>
   .ARQOS                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arqos                ) ,
<% } else { %>
   .ARQOS                    ( 'h0            ) ,
<% } %>
<%if(aiu_axiInt[pidx][0].params.wRegion > 0) {%>
   .ARREGION                 ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arregion             ) ,
<% } else { %>
   .ARREGION                    ( 'h0            ) ,
<% } %>
   .ARVALID                  ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arvalid  ) ,
   .ARREADY                  ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arready  ) ,
   <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { %>
   .ARSNOOP                  ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arsnoop  ) ,
   .ARDOMAIN                 ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.ardomain ) ,
   .ARBAR                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.arbar    ) ,
   <%} %>
   //  Read Channel
   .RID                      ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.rid      ) ,
   .RLAST                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.rlast    ) ,
   .RDATA                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.rdata    ) ,
   .RRESP                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.rresp    ) ,
<%if(aiu_axiInt[pidx][0].params.wRUser > 0) {%>
   .RUSER                    ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.ruser    ) ,
<% } else { %>
   .RUSER                    ( 'h0            ) ,
<% } %>
   .RVALID                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.rvalid   ) ,
   .RREADY                   ( ioaiu_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>.rready   ) ,
   // Low Power Interface
   .CACTIVE                  ( 1'b1                      ) ,
   .CSYSREQ                  ( 1'b1                      ) ,
   .CSYSACK                  ( 1'b1                      )
) ;
  <% } %>
  <% } io_idx++;
     }   
   } %>


`endif //ASSERT_OFF
`endif //ASSERT_ON
<% if(obj.testBench =="emu") { %>
initial
   begin 
      //$display($time, "Calling Response signals");
<%         if(obj.BlockId=="ioaiu") { %>

    forever begin
   
       mgc_ace_m_if_<%=_child_blkid[pidx]%>.wait_for_clk(1);
       mgc_rsp.getXactorResp;  // Handle to interface at hdl side
    end
<%  } %>
  end

<%  } %>


endmodule: tb_top

<% if(obj.testBench=="emu") { %>
module clock_n_reset( output bit tb_aclk , output bit tb_aresetn ); //pragma attribute clock_reset partition_module_xrtl

  // clock and reset generator module need to 
  // marked with tbx clkgen pragma 
  
  //tbx clkgen
  initial begin
    tb_aclk = 0;
    forever #50 tb_aclk = ~tb_aclk;
  end

  //tbx clkgen
  initial begin
    tb_aresetn = 0;
    #500 tb_aresetn = 1;
  end
endmodule

<% } %>
