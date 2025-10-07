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

   for(var pidx = 0; pidx < obj.nDMIs; pidx++) {
       if((obj.DmiInfo[pidx].interfaces.axiInt.params.wQos>0 == 0) && (obj.wPriorityLevel == 0)) { 
           dmi_useAceQosPort.push(0);
       } else {
           dmi_useAceQosPort.push(1);
       }
       dmi_useAceRegionPort.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wRegion>0);
       dmi_wAwUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wAwUser);
       dmi_wWUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wWUser);
       dmi_wBUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wBUser);
       dmi_wArUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wArUser);
       dmi_wRUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wRUser);
   }
   for(var pidx = 0; pidx < obj.nDIIs; pidx++) {
       if((obj.DiiInfo[pidx].interfaces.axiInt.params.wQos>0 == 0) && (obj.wPriorityLevel == 0)) { 
           dii_useAceQosPort.push(0);
       } else {
           dii_useAceQosPort.push(1);
       }
       dii_useAceRegionPort.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wRegion>0);
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
   var chiA = 0;
   var chiB = 0;
   var chiE = 0;
   var node_id_w=7;
   var node_id_idx =[];
   var tgtid_msb =[];
   var srcid_lsb = 0 ;
   var srcid_msb =[];
   var srcid_lsb = 0 ;
   var txnid_lsb = 0 ;
   var txnid_msb = 0 ;
   var retunnid_lsb = 0 ;
   var retunnid_msb =[];
   var reqflit_r_lsb = 0 ;
   var reqflit_r_msb =[];
   var rspflit_r_lsb = 0 ;
   var rspflit_r_msb =[];
   var snpflit_srcid_msb =[];
   var snpflit_txnid_lsb = 0 ;
   var snpflit_txnid_msb = 0 ;
   var snpflit_fwdnid_lsb = 0 ;
   var snpflit_fwdnid_msb =[];
   var snpflit_r_lsb = 0 ;
   var snpflit_r_msb =[];
   var datflit_r_lsb = 0 ;
   var datflit_r_msb =[];
   var data_w_idx =[];
   var data_w=0; 
   var data_rsvdc_w=0; 
   var data_poison = []; 



   for(var idx = 0; idx < obj.AiuInfo.length; idx++){ 
       if((obj.AiuInfo[idx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-E')) {
         node_id_idx[idx] = obj.AiuInfo[idx].interfaces.chiInt.params.SrcID;
         data_w_idx[idx] = obj.AiuInfo[idx].interfaces.chiInt.params.wData;
         if(obj.AiuInfo[idx].interfaces.chiInt.params.NodeID_Width > node_id_w) { 
          node_id_w = obj.AiuInfo[idx].interfaces.chiInt.params.NodeID_Width;
          }
         if(obj.AiuInfo[idx].interfaces.chiInt.params.wData > data_w) { 
          data_w = obj.AiuInfo[idx].interfaces.chiInt.params.wData;
          }
         if(obj.AiuInfo[idx].interfaces.chiInt.params.DAT_RSVDC > data_rsvdc_w) { 
          data_rsvdc_w = obj.AiuInfo[idx].interfaces.chiInt.params.DAT_RSVDC;
          }
	 if( obj.AiuInfo[idx].interfaces.chiInt.params.enPoison == true){
		 data_poison[idx]     = 1; 
	 } else {
		data_poison[idx]     = 0; 
	 } 
        }
        else {
          node_id_idx[idx]=0;
          data_w_idx[idx]=0;
        }
     }
	 srcid_lsb = 4+node_id_w; 
         txnid_lsb = 4+2*(node_id_w) ;
         reqflit_r_lsb = 4+3*(node_id_w)+8 ;
         rspflit_r_lsb = 4+2*(node_id_w) ;
         snpflit_txnid_lsb = 4+node_id_w ;
         snpflit_txnid_msb = 4+node_id_w+8-1 ;
         snpflit_fwdnid_lsb = snpflit_txnid_msb+1 ;
         snpflit_r_lsb = 4+2*(node_id_w)+8 ;
   for(var idx = 0; idx < obj.AiuInfo.length; idx++){ 
       if((obj.AiuInfo[idx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-E')) {
         if(obj.AiuInfo[idx].fnNativeInterface == 'CHI-E'){
         txnid_msb = txnid_lsb + 12 -1 ;
         }else{
         txnid_msb = txnid_lsb + 8 -1 ;
         }
         retunnid_lsb = txnid_msb + 1    ;
	 tgtid_msb[idx] = 4+node_id_idx[idx]-1; 
	 srcid_msb[idx] = srcid_lsb+node_id_idx[idx]-1; 
	 retunnid_msb[idx] = retunnid_lsb+node_id_idx[idx]-1; 
	 reqflit_r_msb[idx] = obj.AiuInfo[idx].interfaces.chiInt.params.wReqflit+3*(node_id_w - node_id_idx[idx])-1; 
	 rspflit_r_msb[idx] = obj.AiuInfo[idx].interfaces.chiInt.params.wRspflit+2*(node_id_w - node_id_idx[idx])-1; 
	 snpflit_srcid_msb[idx] = 4+node_id_idx[idx]-1; 
	 snpflit_fwdnid_msb[idx] = snpflit_fwdnid_lsb+node_id_idx[idx]-1; 
	 snpflit_r_msb[idx] = obj.AiuInfo[idx].interfaces.chiInt.params.wSnpflit+2*(node_id_w - node_id_idx[idx])-1; 
        }
        else {
	 tgtid_msb[idx] = 0 ; 
	 srcid_msb[idx] =  0 ; 
	 retunnid_msb[idx] = 0 ; 
	 reqflit_r_msb[idx] = 0 ; 
	 rspflit_r_msb[idx] = 0 ; 
	 snpflit_srcid_msb[idx] = 0 ; 
	 snpflit_fwdnid_msb[idx] = 0 ; 
	 snpflit_r_msb[idx] = 0 ; 
        }
     }

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
        if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A'){
          chiA++;  
         }
        if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B'){
          chiB++;  
         }
        if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E'){
          chiE++;  
         }
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


`include "ncore_tb_pkg.sv"
 <% if(obj.useResiliency == 1){ %>
`include "ncore_fsys_fault_injector_checker.sv"
`include "ncore_fault_if.sv"
 <%}%>
`include "ncore_IRQ_if.sv"

module tb_top();

  timeunit 1ns;
  timeprecision 1ps;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import DenaliSvCdn_axi::*;
  import DenaliSvCdn_apb::*;
  import CdnSvVip::*;
  import DenaliSvMem::*;
  import DenaliSvChi::*;
  import cdnChiUvm::*;
  import cdnAxiUvm::*;

  // Import the addr Mgr
  import ncore_tb_pkg::*;

<%for(pidx = 0; pidx < obj.nCHIs; pidx++) {%>
  <%if(obj.AiuInfo[pidx].interfaces.chiInt.params.checkType != "NONE" ){%>
  parameter int WREQFLIT<%=pidx%> = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.wReqflit%>;
  parameter int WDATFLIT<%=pidx%> = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.wDatflit%>;
  parameter int WRSPFLIT<%=pidx%> = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.wRspflit%>;
  parameter int WSNPFLIT<%=pidx%> = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.wSnpflit%>;
  <%}%>
<%}%>

//Clock and reset 
  logic dut_clk; 
  logic sys_clk; 
  logic sys_rstn; 
  logic soft_rstn;

<%for(pidx = 0; pidx < obj.nCHIs; pidx++) {%>
  <%if(obj.AiuInfo[pidx].interfaces.chiInt.params.checkType != "NONE" ){%>
  logic [((WREQFLIT<%=pidx%>/8)+(WREQFLIT<%=pidx%>%8 != 0))-1 : 0]    chi<%=pidx%>_rx_req_flit_chk;
  logic [((WRSPFLIT<%=pidx%>/8)+(WRSPFLIT<%=pidx%>%8 != 0))-1 : 0]    chi<%=pidx%>_rx_rsp_flit_chk;
  logic [((WDATFLIT<%=pidx%>/8)+(WDATFLIT<%=pidx%>%8 != 0))-1 : 0]    chi<%=pidx%>_rx_dat_flit_chk;
  <%}else{%>
    // why are we here?
  <%}%>
<%}%>

<% if(obj.useResiliency == 1){ %>
  fault_if  m_fsc_master_fault();
  uvm_event mission_fault_detected;
<%}%>
  <%for(var pidx = 0; pidx < initiatorAgents; pidx++) { %>
    IRQ_if m_irq_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_if();
  <%}%>
  <%for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
    IRQ_if m_irq_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>_if();
  <%}%>
  <%for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
    IRQ_if m_irq_<%=obj.DceInfo[pidx].strRtlNamePrefix%>_if();
  <%}%>
  <%for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
    IRQ_if m_irq_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>_if();
  <%}%>
  <%for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
    IRQ_if m_irq_<%=obj.DveInfo[pidx].strRtlNamePrefix%>_if();
  <%}%>
  <% for(var clock=0; clock < clocks.length; clock++) { %>
    clk_if m_clk_if_<%=clocks[clock]%>();
    logic <%=obj.Clocks[clock].name%>clk; 
    logic <%=obj.Clocks[clock].name%>clk_sync; 
    logic <%=obj.Clocks[clock].name%>reset_n;
    assign <%=obj.Clocks[clock].name%>clk  = m_clk_if_<%=clocks[clock]%>.clk;
    assign <%=obj.Clocks[clock].name%>reset_n = m_clk_if_<%=clocks[clock]%>.reset_n;
    assign <%=obj.Clocks[clock].name%>test_en = m_clk_if_<%=clocks[clock]%>.test_en;
  <% } %>

   //Interfaces instantiation
<% var chi_idx=0;%>
<% var axiidx=0;%>


<% var idx=0; obj.AiuInfo.forEach(function(bundle,pidx) { %>
<%   if(bundle.fnNativeInterface === 'ACE' || bundle.fnNativeInterface === "ACE-LITE" || bundle.fnNativeInterface === 'AXI4' || bundle.fnNativeInterface === "ACELITE-E" || bundle.fnNativeInterface === 'AXI5' || bundle.fnNativeInterface === 'ACE5'  ) {   
     var userMax = Math.max(bundle.interfaces.axiInt[0].params.wAwUser, 
                              bundle.interfaces.axiInt[0].params.wArUser,
                              bundle.interfaces.axiInt[0].params.wWUser,
                              bundle.interfaces.axiInt[0].params.wBUser,
                              bundle.interfaces.axiInt[0].params.wRUser);
     var wAxId   = Math.max(bundle.interfaces.axiInt[0].params.wArId,bundle.interfaces.axiInt[0].params.wAwId); 
     var wAxAddr = bundle.interfaces.axiInt[0].params.wAddr;
     var wXData  = bundle.interfaces.axiInt[0].params.wData;
    } else if(bundle.fnNativeInterface.includes('CHI')) {
    var datawidth        = bundle.interfaces.chiInt.params.wData;
    var nodeid_width     = bundle.interfaces.chiInt.params.SrcID;
    var addr_width       = bundle.interfaces.chiInt.params.wAddr;
    var req_rsvdc_width  = bundle.interfaces.chiInt.params.REQ_RSVDC;
    var data_rsvdc_width = bundle.interfaces.chiInt.params.DAT_RSVDC;
    var data_check       = 0; 
    if( bundle.interfaces.chiInt.params.enPoison == true){
    var data_poison      = 1; 
    } else {
    var data_poison      = 0; 
    }
    var input_skew       = 1;
    }%>
    <%if(bundle.fnNativeInterface.includes('CHI')) {%>
            <%let intf_name = '';%>
            <%if(bundle.fnNativeInterface == 'CHI-B'){%>
                <%intf_name = 'chi_B_Interface';%>
            <%}else{%>
                <%intf_name = 'chi_E_Interface';%>
            <%}%>
            <%=intf_name%>#(.DATA_WIDTH(<%=datawidth%>),
	       	       .NODE_ID_WIDTH(<%=nodeid_width%>),
	       	       .ADDR_WIDTH(<%=addr_width%>),
	       	       .REQ_RSVDC_WIDTH(<%=req_rsvdc_width%>),
	       	       .DATA_RSVDC_WIDTH(<%=data_rsvdc_width%>),
	       	       .DATA_CHECK(<%=data_check%>),
                   .DATA_POISON(<%=data_poison%>)) m_chi_if_chiaiu<%=chi_idx%>(<%=obj.AiuInfo[pidx].nativeClk%>clk,<%=obj.AiuInfo[pidx].nativeClk%>reset_n) ;
            <%chi_idx++;%>
        <%}else{
            for (var mpu_io = 0; mpu_io < bundle.nNativeInterfacePorts; mpu_io++){
                if(bundle.fnNativeInterface == 'ACE') { %>
                    cdnAceFullInterface #(.ID_WIDTH(<%=wAxId%>),
                        .ADDR_WIDTH(<%=wAxAddr%>),
                        .DATA_WIDTH(<%=wXData%>),
                        .USER_WIDTH(<%=userMax%>))    m_axi_if_ncaiu<%=idx%>(<%=obj.AiuInfo[pidx].nativeClk%>clk,<%=obj.AiuInfo[pidx].nativeClk%>reset_n) ;
                <%  idx++  } else if(bundle.fnNativeInterface == 'ACE5') { %>
                    cdnAce5FullInterface #(.ID_WIDTH(<%=wAxId%>),
                        .ADDR_WIDTH(<%=wAxAddr%>),
                        .DATA_WIDTH(<%=wXData%>),
                        .USER_WIDTH(<%=userMax%>))    m_axi_if_ncaiu<%=idx%>(<%=obj.AiuInfo[pidx].nativeClk%>clk,<%=obj.AiuInfo[pidx].nativeClk%>reset_n) ;
                <%  idx++  } else if(bundle.fnNativeInterface == "ACELITE-E" && bundle.interfaces.axiInt[mpu_io].params.eAc>0) { %>
                cdnAce5LiteDvmInterface #(.ID_WIDTH(<%=wAxId%>),
                            .ADDR_WIDTH(<%=wAxAddr%>),
                            .DATA_WIDTH(<%=wXData%>),
                            .USER_WIDTH(<%=userMax%>)) m_axi_if_ncaiu<%=idx%>(<%=obj.AiuInfo[pidx].nativeClk%>clk,<%=obj.AiuInfo[pidx].nativeClk%>reset_n);
                <%  idx++  } else if(bundle.fnNativeInterface == "ACELITE-E" ) { %>
                cdnAce5LiteInterface #(.ID_WIDTH(<%=wAxId%>),
                         .ADDR_WIDTH(<%=wAxAddr%>),
                         .DATA_WIDTH(<%=wXData%>),
                         .USER_WIDTH(<%=userMax%>)) m_axi_if_ncaiu<%=idx%>(<%=obj.AiuInfo[pidx].nativeClk%>clk,<%=obj.AiuInfo[pidx].nativeClk%>reset_n);
                <%  idx++  } else if(bundle.fnNativeInterface == "ACE-LITE"&& bundle.interfaces.axiInt[mpu_io].params.eAc>0) { %>
                cdnAceLiteDvmInterface #(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)) m_axi_if_ncaiu<%=idx%>(<%=obj.AiuInfo[pidx].nativeClk%>clk,<%=obj.AiuInfo[pidx].nativeClk%>reset_n);
                <%  idx++  } else if(bundle.fnNativeInterface == "ACE-LITE" ) { %>
                    cdnAceLiteInterface #(.ID_WIDTH(<%=wAxId%>),
                        .ADDR_WIDTH(<%=wAxAddr%>),
                        .DATA_WIDTH(<%=wXData%>),
                        .USER_WIDTH(<%=userMax%>)) m_axi_if_ncaiu<%=idx%>(<%=obj.AiuInfo[pidx].nativeClk%>clk,<%=obj.AiuInfo[pidx].nativeClk%>reset_n);
                <%  idx++  } else if(bundle.fnNativeInterface == "AXI5" ) { %>
                    cdnAxi5Interface #(.ID_WIDTH(<%=wAxId%>),
                     .ADDR_WIDTH(<%=wAxAddr%>),
                     .DATA_WIDTH(<%=wXData%>),
                     .USER_WIDTH(<%=userMax%>)) m_axi_if_ncaiu<%=idx%>(<%=obj.AiuInfo[pidx].nativeClk%>clk,<%=obj.AiuInfo[pidx].nativeClk%>reset_n) ;
                <%  idx++  }else { %>
                    cdnAxi4Interface #(.ID_WIDTH(<%=wAxId%>),
                     .ADDR_WIDTH(<%=wAxAddr%>),
                     .DATA_WIDTH(<%=wXData%>),
                     .USER_WIDTH(<%=userMax%>)) m_axi_if_ncaiu<%=idx%>(<%=obj.AiuInfo[pidx].nativeClk%>clk,<%=obj.AiuInfo[pidx].nativeClk%>reset_n) ;
        <%  idx++  }}} %>
<%   }) %>

<%
obj.DmiInfo.forEach(function(e, idx, array) {
     var userMax = Math.max(e.interfaces.axiInt.params.wAwUser, 
                              e.interfaces.axiInt.params.wArUser,
                              e.interfaces.axiInt.params.wWUser,
                              e.interfaces.axiInt.params.wBUser,
                              e.interfaces.axiInt.params.wRUser);
     var wAxId   = Math.max(e.interfaces.axiInt.params.wArId,e.interfaces.axiInt.params.wAwId); 
     var wAxAddr = e.interfaces.axiInt.params.wAddr;
     var wXData  = e.interfaces.axiInt.params.wData;
%>
  cdnAxi4Interface #(.WRITE_ID_WIDTH(<%=obj.DmiInfo[idx].interfaces.axiInt.params.wAwId%>),
                     .READ_ID_WIDTH(<%=obj.DmiInfo[idx].interfaces.axiInt.params.wArId%>),
                     .ADDR_WIDTH(<%=wAxAddr%>),
                     .DATA_WIDTH(<%=wXData%>),
                     .USER_WIDTH(<%=userMax%>)) m_axi_slv_if_dmi<%=idx%>(<%=obj.DmiInfo[idx].unitClk[0]%>clk,<%=obj.DmiInfo[idx].unitClk[0]%>reset_n);
    <%axiidx++  }) %>

<% axiidx =0;
obj.DiiInfo.forEach(function(e,idx, array) {
     var userMax = Math.max(e.interfaces.axiInt.params.wAwUser, 
                              e.interfaces.axiInt.params.wArUser,
                              e.interfaces.axiInt.params.wWUser,
                              e.interfaces.axiInt.params.wBUser,
                              e.interfaces.axiInt.params.wRUser);
     var wAxId   = Math.max(e.interfaces.axiInt.params.wArId,e.interfaces.axiInt.params.wAwId); 
     var wAxAddr = e.interfaces.axiInt.params.wAddr;
     var wXData  = e.interfaces.axiInt.params.wData;
%>
    <% if (obj.DiiInfo[idx].configuration == 0) { %>  					       
  cdnAxi4Interface #(.ID_WIDTH(<%=wAxId%>),
                     .ADDR_WIDTH(<%=wAxAddr%>),
                     .DATA_WIDTH(<%=wXData%>),
                     .USER_WIDTH(<%=userMax%>)) m_axi_slv_if_dii<%=axiidx%>(<%=obj.DiiInfo[idx].unitClk[0]%>clk,<%=obj.DiiInfo[idx].unitClk[0]%>reset_n);
    <%axiidx++  } })%>
   
<%if(obj.useResiliency == 1){%>
  cdnApb4Interface #(.NUM_OF_SLAVES(<%=obj.FscInfo.interfaces.apbInterface.params.wPsel%>),
                     .ADDRESS_WIDTH(<%=obj.FscInfo.interfaces.apbInterface.params.wAddr%>),
                     .DATA_WIDTH(<%=obj.FscInfo.interfaces.apbInterface.params.wData%>)) m_fsc_apb_if(sys_clk, sys_rstn);
<% } %>
<%if(obj.DebugApbInfo.length > 0){%>
  cdnApb4Interface #(.NUM_OF_SLAVES(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wPsel%>),
                     .ADDRESS_WIDTH(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wAddr%>),
                     .DATA_WIDTH(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wData%>)) m_apb_dbg_if(<%=obj.DebugApbInfo[0].unitClk[0]%>clk, <%=obj.DebugApbInfo[0].unitClk[0]%>reset_n);
<% } %>


<% if(obj.useResiliency == 1){ %>
initial begin
   uvm_config_db#(virtual interface cdnApb4Interface#(
                     .NUM_OF_SLAVES(1),
                     .ADDRESS_WIDTH(12),
                     .DATA_WIDTH(32)))::set(null,"","apb_if", m_fsc_apb_if);
   mission_fault_detected = new("mission_fault_detected");
   uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "mission_fault_detected" ),
                                  .value(mission_fault_detected));
end
<% } %>

<%if(obj.DebugApbInfo.length > 0){%>
initial begin
   uvm_config_db#(virtual interface cdnApb4Interface#(
                     .NUM_OF_SLAVES(1),
                     .ADDRESS_WIDTH(24),
                     .DATA_WIDTH(32)))::set(null,"","apb_if", m_apb_dbg_if);
end
<% } %>

initial begin
<%for(var idx = 0; idx < obj.nAIUs; idx++){ %>
    uvm_config_db#(virtual IRQ_if)::set(.cntxt( null ),
                                        .inst_name( "" ),
                                        .field_name( "m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if" ),
                                        .value(m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if));
<% } %>
<%for(var idx = 0; idx < obj.nDMIs; idx++){ %>
    uvm_config_db#(virtual IRQ_if)::set(.cntxt( null ),
                                        .inst_name( "" ),
                                        .field_name( "m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if" ),
                                        .value(m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if));
<% } %>
<%for(var idx = 0; idx < obj.nDIIs; idx++){ %>
    uvm_config_db#(virtual IRQ_if)::set(.cntxt( null ),
                                        .inst_name( "" ),
                                        .field_name( "m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if" ),
                                        .value(m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if));
<% } %>
<%for(var idx = 0; idx < obj.nDVEs; idx++){ %>
    uvm_config_db#(virtual IRQ_if)::set(.cntxt( null ),
                                        .inst_name( "" ),
                                        .field_name( "m_irq_<%=obj.DveInfo[idx].strRtlNamePrefix%>_if" ),
                                        .value(m_irq_<%=obj.DveInfo[idx].strRtlNamePrefix%>_if));
<% } %>
<%for(var idx = 0; idx < obj.nDCEs; idx++){ %>
    uvm_config_db#(virtual IRQ_if)::set(.cntxt( null ),
                                        .inst_name( "" ),
                                        .field_name( "m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if" ),
                                        .value(m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if));
<% } %>
end

<% if (obj.useRtlPrefix == 1) { %>
    <%=obj.strProjectName%>_gen_wrapper u_chip (
<% } else { %>
  gen_wrapper u_chip (
<% } %>

<%if(obj.useResiliency == 1){%>
               .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>psel       (m_fsc_apb_if.psel),
               .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>penable    (m_fsc_apb_if.penable),
               .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>pwrite     (m_fsc_apb_if.pwrite),
               .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>paddr      (m_fsc_apb_if.paddr),
               .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>pwdata     (m_fsc_apb_if.pwdata),
               .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>pready     (m_fsc_apb_if.pready[0]),
               .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>prdata     (m_fsc_apb_if.prdata[0]),
               .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>pslverr    (m_fsc_apb_if.pslverr[0]),
                <% if(obj.FscInfo.interfaces.apbInterface.params.wProt>0){%>
               .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>pprot      (m_fsc_apb_if.pprot),
                <%}%>
               .fsc_<%=obj.FscInfo.interfaces.masterFaultInterface.name%>mission_fault  (m_fsc_master_fault.mission_fault),
               .fsc_<%=obj.FscInfo.interfaces.masterFaultInterface.name%>latent_fault  (m_fsc_master_fault.latent_fault),
               .fsc_<%=obj.FscInfo.interfaces.masterFaultInterface.name%>cerr_over_thres_fault  (m_fsc_master_fault.cerr_over_thres_fault),
	            .ncore_en_debug_bist_pin(1'b1),
	       /*.ncore_debug_atu_config_paddr(24'h0),
	       .ncore_debug_atu_config_psel('d0),
	       .ncore_debug_atu_config_penable('d0),
	       .ncore_debug_atu_config_pwrite('d0),
	       .ncore_debug_atu_config_pwdata(24'h0),
	       .ncore_debug_atu_config_pready(),
	       .ncore_debug_atu_config_prdata(),
	       .ncore_debug_atu_config_pslverr(),*/

<% } %>
<%if(obj.DebugApbInfo.length > 0){%>
	       .ncore_debug_atu_config_paddr(m_apb_dbg_if.paddr),
	       .ncore_debug_atu_config_psel(m_apb_dbg_if.psel),
	       .ncore_debug_atu_config_penable(m_apb_dbg_if.penable),
	       .ncore_debug_atu_config_pwrite(m_apb_dbg_if.pwrite),
	       .ncore_debug_atu_config_pwdata(m_apb_dbg_if.pwdata),
	       .ncore_debug_atu_config_pready(m_apb_dbg_if.pready[0]),
	       .ncore_debug_atu_config_prdata(m_apb_dbg_if.prdata[0]),
	       .ncore_debug_atu_config_pslverr(m_apb_dbg_if.pslverr[0]),
            <%if(obj.DebugApbInfo[0].interfaces.apbInterface.params.wProt>0){%>
	       .ncore_debug_atu_config_pprot(m_apb_dbg_if.pprot),
            <%}%>
<%}%>
<% for(var idx = 0; idx < obj.nAIUs; idx++){ %>
<% if(obj.AiuInfo[idx].interfaces.eventRequestInInt._SKIP_ == false) {%>        
               .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=obj.AiuInfo[idx].interfaces.eventRequestInInt.name%>req              ('d0),
               .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=obj.AiuInfo[idx].interfaces.eventRequestInInt.name%>ack              (),<%  } %>
<% if(obj.AiuInfo[idx].interfaces.eventRequestOutInt._SKIP_ == false) {%>        
               .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=obj.AiuInfo[idx].interfaces.eventRequestOutInt.name%>req              (),
               .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=obj.AiuInfo[idx].interfaces.eventRequestOutInt.name%>ack              ('d0),<%  } %>
<%    if ((obj.AiuInfo[idx].fnNativeInterface !== "CHI-A")&&(obj.AiuInfo[idx].fnNativeInterface !== "CHI-B")&&(obj.AiuInfo[idx].fnNativeInterface !== "CHI-E")) { %>
  <% if (obj.AiuInfo[idx].interfaces.userPlaceInt._SKIP_ == false || (typeof obj.AiuInfo[idx].interfaces.memoryInt !== 'undefined')) { %>
              <% for(var memIdx = 0; memIdx < obj.AiuInfo[idx].interfaces.memoryInt.length; memIdx++){ %>
               <% for(var inIdx = 0; inIdx < obj.AiuInfo[idx].interfaces.memoryInt[memIdx].synonyms.in.length; inIdx++){ %>
                    <%if(obj.AiuInfo[idx].interfaces.memoryInt[memIdx]._SKIP_ === false){%>
               .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=obj.AiuInfo[idx].interfaces.memoryInt[memIdx].name%><%=obj.AiuInfo[idx].interfaces.memoryInt[memIdx].synonyms.in[inIdx].name%>                ('d0),<% } %> <% } %> <% } %>
                      <%}%>
  <% } %>
<% } %>

<% for(var idx = 0; idx < obj.nAIUs; idx++){ %>
<%    if (!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))) { %>
               .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_irq_c                (m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c),
<%    } %>
               .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc),
<%  } %>

<% for(var idx = 0; idx < obj.nDMIs; idx++){ %>
               .<%=obj.DmiInfo[idx].strRtlNamePrefix%>_irq_c                (m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c),
               .<%=obj.DmiInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc),
			<%if (obj.DmiInfo[idx].interfaces.userPlaceInt._SKIP_ == false || (typeof obj.DmiInfo[idx].interfaces.memoryInt !== 'undefined')) { %>
              <% for(var memIdx = 0; memIdx < obj.DmiInfo[idx].interfaces.memoryInt.length; memIdx++){ %>
               <% for(var inIdx = 0; inIdx < obj.DmiInfo[idx].interfaces.memoryInt[memIdx].synonyms.in.length; inIdx++){ %>
                    <%if(obj.DmiInfo[idx].interfaces.memoryInt[memIdx]._SKIP_ === false){%>
               .<%=obj.DmiInfo[idx].strRtlNamePrefix%>_<%=obj.DmiInfo[idx].interfaces.memoryInt[memIdx].name%><%=obj.DmiInfo[idx].interfaces.memoryInt[memIdx].synonyms.in[inIdx].name%>                ('d0),<% } %> <% } %> <% } %>
                      <%}%>
<%  } %>

<% for(var idx = 0; idx < obj.nDIIs; idx++){ %>
               .<%=obj.DiiInfo[idx].strRtlNamePrefix%>_irq_c                (m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c),
               .<%=obj.DiiInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc),
			<%if (obj.DiiInfo[idx].interfaces.userPlaceInt._SKIP_ == false || (typeof obj.DiiInfo[idx].interfaces.memoryInt !== 'undefined')) { %>
               <% for(var inIdx = 0; inIdx < obj.DiiInfo[idx].interfaces.userPlaceInt.synonyms.in.length; inIdx++){ %>
               .<%=obj.DiiInfo[idx].strRtlNamePrefix%>_<%=obj.DiiInfo[idx].interfaces.userPlaceInt.name%><%=obj.DiiInfo[idx].interfaces.userPlaceInt.synonyms.in[inIdx].name%>                ('d0),
               <% } %>
           <% } %>
<%  } %>

<% for(var idx = 0; idx < obj.nDCEs; idx++){ %>
               .<%=obj.DceInfo[idx].strRtlNamePrefix%>_irq_c                (m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c),
               .<%=obj.DceInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_uc),
			<%if (obj.DceInfo[idx].interfaces._SKIP_ == false || (typeof obj.DceInfo[idx].interfaces.memoryInt !== 'undefined')) { %>
              <% for(var memIdx = 0; memIdx < obj.DceInfo[idx].interfaces.memoryInt.length; memIdx++){ %>
               <% for(var inIdx = 0; inIdx < obj.DceInfo[idx].interfaces.memoryInt[memIdx].synonyms.in.length; inIdx++){ %>
               .<%=obj.DceInfo[idx].strRtlNamePrefix%>_<%=obj.DceInfo[idx].interfaces.memoryInt[memIdx].name%><%=obj.DceInfo[idx].interfaces.memoryInt[memIdx].synonyms.in[inIdx].name%>                ('d0),
               <% } %>
             <% } %>
           <% } %>
<%  } %>

<% for(var idx = 0; idx < obj.nDVEs; idx++){ %>
               .<%=obj.DveInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=obj.DveInfo[idx].strRtlNamePrefix%>_if.IRQ_uc),
			<%if (obj.DveInfo[idx].interfaces._SKIP_ == false || (typeof obj.DveInfo[idx].interfaces.memoryInt !== 'undefined')) { %>
              <% for(var memIdx = 0; memIdx < obj.DveInfo[idx].interfaces.memoryInt.length; memIdx++){ %>
               <% for(var inIdx = 0; inIdx < obj.DveInfo[idx].interfaces.memoryInt[memIdx].synonyms.in.length; inIdx++){ %>
               .<%=obj.DveInfo[idx].strRtlNamePrefix%>_<%=obj.DveInfo[idx].interfaces.memoryInt[memIdx].name%><%=obj.DveInfo[idx].interfaces.memoryInt[memIdx].synonyms.in[inIdx].name%>                ('d0),
               <% } %>
             <% } %>
           <% } %>
<%  } %>

<% axiidx = 0; chiidx=0; obj.AiuInfo.forEach(function(bundle, idx) { %>
<%   if (bundle.fnNativeInterface.includes("CHI")) { %>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_link_active_req      ( m_chi_if_chiaiu<%=chiidx%>.DownLinkActiveReq        ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_link_active_ack      ( m_chi_if_chiaiu<%=chiidx%>.DownLinkActiveAck        ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_link_active_req      ( m_chi_if_chiaiu<%=chiidx%>.UpLinkActiveReq          ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_link_active_ack      ( m_chi_if_chiaiu<%=chiidx%>.UpLinkActiveAck          ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_sactive              ( m_chi_if_chiaiu<%=chiidx%>.DownSActive),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_sactive              ( m_chi_if_chiaiu<%=chiidx%>.UpSActive),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flit_pend        ( m_chi_if_chiaiu<%=chiidx%>.ReqFlitPend              ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flitv            ( m_chi_if_chiaiu<%=chiidx%>.ReqFlitV                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flit             ( m_chi_if_chiaiu<%=chiidx%>.ReqFlit                  ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_lcrdv            ( m_chi_if_chiaiu<%=chiidx%>.ReqLCrdV                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flit_pend        ( m_chi_if_chiaiu<%=chiidx%>.DownRspFlitPend          ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flitv            ( m_chi_if_chiaiu<%=chiidx%>.DownRspFlitV             ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flit             ( m_chi_if_chiaiu<%=chiidx%>.DownRspFlit              ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_lcrdv            ( m_chi_if_chiaiu<%=chiidx%>.DownRspLCrdV             ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flit_pend        ( m_chi_if_chiaiu<%=chiidx%>.DownDatFlitPend          ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flitv            ( m_chi_if_chiaiu<%=chiidx%>.DownDatFlitV             ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flit             ( m_chi_if_chiaiu<%=chiidx%>.DownDatFlit              ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_lcrdv            ( m_chi_if_chiaiu<%=chiidx%>.DownDatLCrdV             ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_flit_pend        ( m_chi_if_chiaiu<%=chiidx%>.SnpFlitPend              ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_flitv            ( m_chi_if_chiaiu<%=chiidx%>.SnpFlitV                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_flit             ( m_chi_if_chiaiu<%=chiidx%>.SnpFlit                  ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_lcrdv            ( m_chi_if_chiaiu<%=chiidx%>.SnpLCrdV                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_flit_pend        ( m_chi_if_chiaiu<%=chiidx%>.UpRspFlitPend            ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_flitv            ( m_chi_if_chiaiu<%=chiidx%>.UpRspFlitV               ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_flit             ( m_chi_if_chiaiu<%=chiidx%>.UpRspFlit                ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_lcrdv            ( m_chi_if_chiaiu<%=chiidx%>.UpRspLCrdV               ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_flit_pend        ( m_chi_if_chiaiu<%=chiidx%>.UpDatFlitPend            ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_flitv            ( m_chi_if_chiaiu<%=chiidx%>.UpDatFlitV               ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_flit             ( m_chi_if_chiaiu<%=chiidx%>.UpDatFlit                ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_lcrdv            ( m_chi_if_chiaiu<%=chiidx%>.UpDatLCrdV               ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>sysco_req               ( m_chi_if_chiaiu<%=chiidx%>.SysCoReq),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>sysco_ack               ( m_chi_if_chiaiu<%=chiidx%>.SysCoAck),

               <%if(bundle.interfaces.chiInt.params.checkType != "NONE" ){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>sysco_req_chk      (!m_chi_if_chiaiu<%=chiidx%>.SysCoReq),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_sactive_chk     (!m_chi_if_chiaiu<%=chiidx%>.DownSActive),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_link_active_req_chk  (!m_chi_if_chiaiu<%=chiidx%>.DownLinkActiveReq),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_link_active_ack_chk  (!m_chi_if_chiaiu<%=chiidx%>.UpLinkActiveAck ),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flit_pend_chk  (!m_chi_if_chiaiu<%=chiidx%>.ReqFlitPend ),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flitv_chk  (!m_chi_if_chiaiu<%=chiidx%>.ReqFlitV),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flit_chk  (chi<%=chiidx%>_rx_req_flit_chk),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flit_pend_chk  (!m_chi_if_chiaiu<%=chiidx%>.DownRspFlitPend),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flitv_chk  (!m_chi_if_chiaiu<%=chiidx%>.DownRspFlitV ),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flit_chk  (chi<%=chiidx%>_rx_rsp_flit_chk ),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flit_pend_chk  (!m_chi_if_chiaiu<%=chiidx%>.DownDatFlitPend),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flitv_chk  (! m_chi_if_chiaiu<%=chiidx%>.DownDatFlitV),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flit_chk  (chi<%=chiidx%>_rx_dat_flit_chk),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_lcrdv_chk  (!m_chi_if_chiaiu<%=chiidx%>.SnpLCrdV),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_lcrdv_chk  (!m_chi_if_chiaiu<%=chiidx%>.UpRspLCrdV ),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_lcrdv_chk  (!m_chi_if_chiaiu<%=chiidx%>.UpDatLCrdV ),
               <%}%>

<%   chiidx++; } else { %>
<%   if (( bundle.fnNativeInterface === "ACELITE-E" && obj.DISABLE_CDN_AXI5 ==1 ))  { %>                               
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_ready                (                                                     ),
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_valid                ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_id                   ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_addr                 ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_len                  ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_size                 ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_burst                ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_lock                 ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_cache                ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_prot                 ( 'd0                                                 ) ,
<%     if (bundle.interfaces.axiInt.params.wRegion>0) { %>                                                                        
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_region               ( 'd0                                                 ) ,
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt.params.eUnique> 0) { %>                                                                                 
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_unique               ( 'd0                                                 ) ,
<%     } %>                                                                                                                         
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_ready                 (                                                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_valid                 ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_data                  ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_last                  ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_strb                  ( 'd0                                                 ) ,
<%     if (bundle.interfaces.axiInt.params.wWUser > 0) { %>                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_user                  ( 'd0                                                 ) ,
<%     } %>                                                                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_ready                 ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_valid                 (                                                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_id                    (                                                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_resp                  (                                                     ) ,
<%     if (bundle.interfaces.axiInt.params.wBUser > 0) { %>                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_user                  (                                                     ) ,
<%     } %>                                                                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_valid                ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_ready                (                                                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_id                   ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_addr                 ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_len                  ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_size                 ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_burst                ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_lock                 ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_cache                ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_prot                 ( 'd0                                                 ) ,
<%     if (bundle.interfaces.axiInt.params.wRegion>0) { %>                                                                        
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_region               ( 'd0                                                 ) ,
<%     } %>                                                                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_ready                 ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_valid                 (                                                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_resp                  (                                                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_data                  (                                                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_last                  (                                                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_id                    (                                                     ) ,
<%     if (bundle.interfaces.axiInt.params.wRUser > 0) { %>                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_user                  (                                                     ) ,
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt.params.wQos>0) { %>                                                                           
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_qos                  ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_qos                  ( 'd0                                                 ) ,
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt.params.wAwUser > 0) { %>                                                                      
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_user                 ( 'd0                                                 ) ,
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt.params.wArUser > 0) { %>                                                                      
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_user                 ( 'd0                                                 ) ,
<%     } %>                                                                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_snoop                ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_domain               ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_bar                  ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_snoop                ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_domain               ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_bar                  ( 'd0                                                 ) ,
<%     if (bundle.interfaces.axiInt.params.eAtomic > 0) { %>                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_atop                 ( 'd0                                                 ) ,
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt.params.eStash > 0) { %>                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_stashnid             ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_stashniden           ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_stashlpid            ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_stashlpiden          ( 'd0                                                 ) ,
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt.params.eAc > 0) { %>                                                                               
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ac_snoop                (                                                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ac_addr                 (                                                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ac_prot                 (                                                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ac_valid                (                                                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ac_ready                ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>cr_ready                (                                                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>cr_valid                ( 'd0                                                 ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>cr_resp                 ( 'd0                                                 ) ,
<%     } %>                                                                                                                       
<%   } else { %>
<%     for (var mpu_io = 0; mpu_io < bundle.nNativeInterfacePorts; mpu_io++){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ready                ( m_axi_if_ncaiu<%=axiidx%>.awready                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_valid                ( m_axi_if_ncaiu<%=axiidx%>.awvalid                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_id                   ( m_axi_if_ncaiu<%=axiidx%>.awid                      ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_addr                 ( m_axi_if_ncaiu<%=axiidx%>.awaddr                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_len                  ( m_axi_if_ncaiu<%=axiidx%>.awlen                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_size                 ( m_axi_if_ncaiu<%=axiidx%>.awsize                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_burst                ( m_axi_if_ncaiu<%=axiidx%>.awburst                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_lock                 ( m_axi_if_ncaiu<%=axiidx%>.awlock                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_cache                ( m_axi_if_ncaiu<%=axiidx%>.awcache                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_prot                 ( m_axi_if_ncaiu<%=axiidx%>.awprot                    ) ,
<%     if (bundle.interfaces.axiInt[mpu_io].params.wRegion>0) { %>                                                                        
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_region               ( m_axi_if_ncaiu<%=axiidx%>.awregion                  ) ,
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_trace                ( 'd0/*m_axi_if_ncaiu<%=axiidx%>.awtrace */                    ) ,
<%     } %>                                                                                                                                
<%     if (bundle.interfaces.axiInt[mpu_io].params.eUnique> 0) { %>                                                                                 
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_unique               ( 1'd0/*m_axi_if_ncaiu<%=axiidx%>.awunique */                 ) ,
            <% } %>                                                                                                                         
            <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ready_chk            ( m_axi_if_ncaiu<%=axiidx%>.awreadychk               ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_valid_chk            ( m_axi_if_ncaiu<%=axiidx%>.awvalidchk               ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_id_chk               ( m_axi_if_ncaiu<%=axiidx%>.awidchk                  ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_addr_chk             ( m_axi_if_ncaiu<%=axiidx%>.awaddrchk                ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_len_chk              ( m_axi_if_ncaiu<%=axiidx%>.awlenchk                 ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ctl_chk0             ( m_axi_if_ncaiu<%=axiidx%>.awctlchk0                ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ctl_chk1             ( m_axi_if_ncaiu<%=axiidx%>.awctlchk1                ) ,
                <%if (!( bundle.fnNativeInterface === "AXI5") )  { %>                               
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ctl_chk2             ( m_axi_if_ncaiu<%=axiidx%>.awctlchk2                ) ,
                <%}%>
                <%if (!( bundle.fnNativeInterface === "ACE5") )  { %>                               
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ctl_chk3             ( m_axi_if_ncaiu<%=axiidx%>.awctlchk3                ) ,
                <%}%>
                <%if (bundle.interfaces.axiInt[mpu_io].params.eStash>0) { %>                                                                                    
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashnid_chk         ( m_axi_if_ncaiu<%=axiidx%>.awstashnidchk            ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashlpid_chk        ( m_axi_if_ncaiu<%=axiidx%>.awstashlpidchk           ) ,
                <%}%>                                                                                                                         
                <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
				    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_trace_chk            ( m_axi_if_ncaiu<%=axiidx%>.awtracechk               ) ,
                <%}%>                                                                                                                         
                <%}%>                                                                                                                         

               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_ready                 ( m_axi_if_ncaiu<%=axiidx%>.wready                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_valid                 ( m_axi_if_ncaiu<%=axiidx%>.wvalid                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_data                  ( m_axi_if_ncaiu<%=axiidx%>.wdata[<%=bundle.interfaces.axiInt[mpu_io].params.wData - 1%> : 0]                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_last                  ( m_axi_if_ncaiu<%=axiidx%>.wlast                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_strb                  ( m_axi_if_ncaiu<%=axiidx%>.wstrb[<%=bundle.interfaces.axiInt[mpu_io].params.wData/8 - 1%> : 0]                     ) ,
<%     if (bundle.interfaces.axiInt[mpu_io].params.wWUser > 0) { %>                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_user                  ( m_axi_if_ncaiu<%=axiidx%>.wuser                     ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_user_chk                  ( m_axi_if_ncaiu<%=axiidx%>.wuserchk                     ) ,
<%     } %>                                                                                                                       
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_trace                  ( 1'd0/*m_axi_if_ncaiu<%=axiidx%>.wtrace      */                 ) ,
                <%     } %>                                                                                                                                  
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_ready_chk             ( m_axi_if_ncaiu<%=axiidx%>.wreadychk                ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_valid_chk             ( m_axi_if_ncaiu<%=axiidx%>.wvalidchk                ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_data_chk              ( m_axi_if_ncaiu<%=axiidx%>.wdatachk                 ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_strb_chk              ( m_axi_if_ncaiu<%=axiidx%>.wstrbchk                 ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_last_chk              ( m_axi_if_ncaiu<%=axiidx%>.wlastchk                 ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_trace_chk             ( m_axi_if_ncaiu<%=axiidx%>wtracechk                ) ,
                <%}%>                                                                                                                         
                <%}%>

               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_ready                 ( m_axi_if_ncaiu<%=axiidx%>.bready                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_valid                 ( m_axi_if_ncaiu<%=axiidx%>.bvalid                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_id                    ( m_axi_if_ncaiu<%=axiidx%>.bid                       ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_resp                  ( m_axi_if_ncaiu<%=axiidx%>.bresp                     ) ,
<%     if (bundle.interfaces.axiInt[mpu_io].params.wBUser > 0) { %>                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_user                  ( m_axi_if_ncaiu<%=axiidx%>.buser                     ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_user_chk                  ( m_axi_if_ncaiu<%=axiidx%>.buserchk                     ) ,
<%     } %>                                                                                                                       
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_trace                  ( m_axi_if_ncaiu<%=axiidx%>.btrace                       ) ,
                <%     } %>                                                                                                                                  
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_ready_chk             ( m_axi_if_ncaiu<%=axiidx%>.breadychk                ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_valid_chk             ( m_axi_if_ncaiu<%=axiidx%>.bvalidchk                ) ,
		    	    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_id_chk                ( m_axi_if_ncaiu<%=axiidx%>.bidchk                   ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_resp_chk              ( m_axi_if_ncaiu<%=axiidx%>.brespchk                 ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
				    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_trace_chk             ( m_axi_if_ncaiu<%=axiidx%>.btracechk                ) ,
                <%}%>                                                                                                                         
                <%}%>

               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_valid                ( m_axi_if_ncaiu<%=axiidx%>.arvalid                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ready                ( m_axi_if_ncaiu<%=axiidx%>.arready                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_id                   ( m_axi_if_ncaiu<%=axiidx%>.arid                      ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_addr                 ( m_axi_if_ncaiu<%=axiidx%>.araddr                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_len                  ( m_axi_if_ncaiu<%=axiidx%>.arlen                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_size                 ( m_axi_if_ncaiu<%=axiidx%>.arsize                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_burst                ( m_axi_if_ncaiu<%=axiidx%>.arburst                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_lock                 ( m_axi_if_ncaiu<%=axiidx%>.arlock                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_cache                ( m_axi_if_ncaiu<%=axiidx%>.arcache                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_prot                 ( m_axi_if_ncaiu<%=axiidx%>.arprot                    ) ,
<%     if (bundle.interfaces.axiInt[mpu_io].params.wRegion>0) { %>                                                                        
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_region               ( m_axi_if_ncaiu<%=axiidx%>.arregion                  ) ,
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_trace                  ( 1'd0/*m_axi_if_ncaiu<%=axiidx%>.artrace        */               ) ,
                <%     } %>                                                                                                                                  
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_valid_chk            ( m_axi_if_ncaiu<%=axiidx%>.arvalidchk               ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ready_chk            ( m_axi_if_ncaiu<%=axiidx%>.arreadychk               ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_id_chk               ( m_axi_if_ncaiu<%=axiidx%>.aridchk                  ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_addr_chk             ( m_axi_if_ncaiu<%=axiidx%>.araddrchk                ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_len_chk              ( m_axi_if_ncaiu<%=axiidx%>.arlenchk                 ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ctl_chk0             ( m_axi_if_ncaiu<%=axiidx%>.arctlchk0                ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ctl_chk1             ( m_axi_if_ncaiu<%=axiidx%>.arctlchk1                ) ,
                <%if (!( bundle.fnNativeInterface === "AXI5") )  { %>                               
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ctl_chk2             ( m_axi_if_ncaiu<%=axiidx%>.arctlchk2                ) ,
                    <%if(bundle.interfaces.axiInt[mpu_io].params.eAc == 1 && obj.system.DVMVersionSupport > 128){%>
                        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ctl_chk3         ( m_axi_if_ncaiu<%=axiidx%>.arctlchk3                ) ,
                    <%}%>
                <%}%>
                <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_trace_chk            ( m_axi_if_ncaiu<%=axiidx%>.artracechk               ) ,
                <%}%>                                                                                                                         
                <%}%>

               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_ready                 ( m_axi_if_ncaiu<%=axiidx%>.rready                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_valid                 ( m_axi_if_ncaiu<%=axiidx%>.rvalid                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_resp                  ( m_axi_if_ncaiu<%=axiidx%>.rresp                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_data                  ( m_axi_if_ncaiu<%=axiidx%>.rdata[<%=bundle.interfaces.axiInt[mpu_io].params.wData - 1%> : 0]                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_last                  ( m_axi_if_ncaiu<%=axiidx%>.rlast                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_id                    ( m_axi_if_ncaiu<%=axiidx%>.rid                       ) ,
<%     if (bundle.interfaces.axiInt[mpu_io].params.wRUser > 0) { %>                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_user                  ( m_axi_if_ncaiu<%=axiidx%>.ruser                     ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_user_chk                  ( m_axi_if_ncaiu<%=axiidx%>.ruserchk                     ) ,
<%     } %>                                                                                                                       
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_trace                  ( m_axi_if_ncaiu<%=axiidx%>.rtrace                       ) ,
                <%     } %>                                                                                                                                  
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_ready_chk             ( m_axi_if_ncaiu<%=axiidx%>.rreadychk                ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_valid_chk             ( m_axi_if_ncaiu<%=axiidx%>.rvalidchk                ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_resp_chk              ( m_axi_if_ncaiu<%=axiidx%>.rrespchk                 ) ,
		    	    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_data_chk              ( m_axi_if_ncaiu<%=axiidx%>.rdatachk                 ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_last_chk              ( m_axi_if_ncaiu<%=axiidx%>.rlastchk                 ) ,
	        	    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_id_chk                ( m_axi_if_ncaiu<%=axiidx%>.ridchk                   ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
				.<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_trace_chk             ( m_axi_if_ncaiu<%=axiidx%>.rtracechk                ) ,
                <%}%>                                                                                                                         
                <%}%>

                <%     if (bundle.interfaces.axiInt[mpu_io].params.wQos>0) { %>                                                                           
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_qos                  ( m_axi_if_ncaiu<%=axiidx%>.awqos                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_qos                  ( m_axi_if_ncaiu<%=axiidx%>.arqos                     ) ,
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt[mpu_io].params.wAwUser > 0) { %>                                                                      
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_user                 ( m_axi_if_ncaiu<%=axiidx%>.awuser                    ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_user_chk                 ( m_axi_if_ncaiu<%=axiidx%>.awuserchk                    ) ,
<%     } %>                                                                                                                       
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt[mpu_io].params.wArUser > 0) { %>                                                                      
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_user                 ( m_axi_if_ncaiu<%=axiidx%>.aruser                    ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_user_chk                 ( m_axi_if_ncaiu<%=axiidx%>.aruserchk                    ) ,
<%     } %>            
<%     } %>            
<%     if (bundle.interfaces.axiInt[mpu_io].params.eAtomic > 0) { %>                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_atop                 ( 'd0                   ) ,
<%     } %>                                                                                                             

<%   if (bundle.fnNativeInterface === "ACE-LITE" || ( bundle.fnNativeInterface === "ACELITE-E" && obj.DISABLE_CDN_AXI5 ==0 ))  { %>                               
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_snoop                ( m_axi_if_ncaiu<%=axiidx%>.awsnoop                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_domain               ( m_axi_if_ncaiu<%=axiidx%>.awdomain                  ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_bar                  ('d0                                                  ) ,                                                                                                                      
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_snoop                ( m_axi_if_ncaiu<%=axiidx%>.arsnoop                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_domain               ( m_axi_if_ncaiu<%=axiidx%>.ardomain                  ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_bar                  ('d0                                                  ) ,
<%     if (bundle.interfaces.axiInt[mpu_io].params.eStash > 0) { %>                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashnid             ( m_axi_if_ncaiu<%=axiidx%>.awstashnid                ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashniden           ( m_axi_if_ncaiu<%=axiidx%>.awstashniden              ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashlpid            ( m_axi_if_ncaiu<%=axiidx%>.awstashlpid               ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashlpiden          ( m_axi_if_ncaiu<%=axiidx%>.awstashlpiden             ) ,
<%     } %>                                                                                                                       
<%     if (bundle.interfaces.axiInt[mpu_io].params.eAc > 0) { %>                                                                               
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_snoop                ( m_axi_if_ncaiu<%=axiidx%>.acsnoop                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_addr                 ( m_axi_if_ncaiu<%=axiidx%>.acaddr                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_prot                 ( m_axi_if_ncaiu<%=axiidx%>.acprot                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_valid                ( m_axi_if_ncaiu<%=axiidx%>.acvalid                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ready                ( m_axi_if_ncaiu<%=axiidx%>.acready                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_ready                ( m_axi_if_ncaiu<%=axiidx%>.crready                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_valid                ( m_axi_if_ncaiu<%=axiidx%>.crvalid                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_resp                 ( m_axi_if_ncaiu<%=axiidx%>.crresp                    ) ,
<%       if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_trace                ( m_axi_if_ncaiu<%=axiidx%>.actrace                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_trace                ( 1'd0/*m_axi_if_ncaiu<%=axiidx%>.crtrace*/           ) ,
                <%       } %>                                                                                                                                  
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_valid_chk            ( m_axi_if_ncaiu<%=axiidx%>.acvalidchk               ) ,
				.<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ready_chk            ( m_axi_if_ncaiu<%=axiidx%>.acreadychk               ) ,
				.<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_addr_chk             ( m_axi_if_ncaiu<%=axiidx%>.acaddrchk                ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ctl_chk              ( m_axi_if_ncaiu<%=axiidx%>.acctlchk                 ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_valid_chk            ( m_axi_if_ncaiu<%=axiidx%>.crvalidchk               ) ,
				.<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_ready_chk            ( m_axi_if_ncaiu<%=axiidx%>.crreadychk               ) ,
				.<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_resp_chk             ( m_axi_if_ncaiu<%=axiidx%>.crrespchk                ) ,
                <% if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_trace_chk        ( m_axi_if_ncaiu<%=axiidx%>.actracechk               ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_trace_chk        ( m_axi_if_ncaiu<%=axiidx%>.crtracechk               ) ,
                <%} %>                                                                                                                                  
                <%}%>
                <%     } %>                                                                                                                       
                                                                                                                                  
<%   } %>                                                                                                                         
<%   if (bundle.fnNativeInterface === "ACE" || bundle.fnNativeInterface === "ACE5" )  { %>                                                                                
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_snoop                ( m_axi_if_ncaiu<%=axiidx%>.awsnoop                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_domain               ( m_axi_if_ncaiu<%=axiidx%>.awdomain                  ) ,
<%   if ( bundle.fnNativeInterface === "ACE5" )  { %>                                                                                
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_bar                  ('d0                                                  ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_bar                  ('d0                     ) ,
	<% } else { %>				       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_bar                  ( m_axi_if_ncaiu<%=axiidx%>.awbar                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_bar                  ( m_axi_if_ncaiu<%=axiidx%>.arbar                     ) ,
    <%     } %>                                                                                                                       
                                                                                                                                  
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_snoop                ( m_axi_if_ncaiu<%=axiidx%>.arsnoop                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_domain               ( m_axi_if_ncaiu<%=axiidx%>.ardomain                  ) ,
                                                                                                                                  
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_ack                   ( m_axi_if_ncaiu<%=axiidx%>.wack                      ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_ack                   ( m_axi_if_ncaiu<%=axiidx%>.rack                      ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_ack_chk               ( m_axi_if_ncaiu<%=axiidx%>.wackchk                   ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_ack_chk               ( m_axi_if_ncaiu<%=axiidx%>.rackchk                   ) ,
                <%}%>
                                                                                                                                  
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_valid                ( m_axi_if_ncaiu<%=axiidx%>.acvalid                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ready                ( m_axi_if_ncaiu<%=axiidx%>.acready                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_addr                 ( m_axi_if_ncaiu<%=axiidx%>.acaddr                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_snoop                ( m_axi_if_ncaiu<%=axiidx%>.acsnoop                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_prot                 ( m_axi_if_ncaiu<%=axiidx%>.acprot                    ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_valid_chk            ( m_axi_if_ncaiu<%=axiidx%>.acvalidchk               ) ,
				.<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ready_chk            ( m_axi_if_ncaiu<%=axiidx%>.acreadychk               ) ,
				.<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_addr_chk             ( m_axi_if_ncaiu<%=axiidx%>.acaddrchk                ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ctl_chk              ( m_axi_if_ncaiu<%=axiidx%>.acctlchk                ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_valid_chk            ( m_axi_if_ncaiu<%=axiidx%>.crvalidchk               ) ,
				.<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_ready_chk            ( m_axi_if_ncaiu<%=axiidx%>.crreadychk               ) ,
				.<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_resp_chk             ( m_axi_if_ncaiu<%=axiidx%>.crrespchk                ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_valid_chk            ( m_axi_if_ncaiu<%=axiidx%>.cdvalidchk               ) ,
				.<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_ready_chk            ( m_axi_if_ncaiu<%=axiidx%>.cdreadychk               ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_data_chk             ( m_axi_if_ncaiu<%=axiidx%>.cddatachk                ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_last_chk             ( m_axi_if_ncaiu<%=axiidx%>.cdlastchk                ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
		            .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_trace_chk             ( m_axi_if_ncaiu<%=axiidx%>.actracechk              ) ,
				    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_trace_chk             ( m_axi_if_ncaiu<%=axiidx%>.crtracechk              ) ,
				    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_trace_chk             ( m_axi_if_ncaiu<%=axiidx%>.cdtracechk              ) ,
                <%}%>
                <%}%>
                                                                                                                                  
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_valid                ( m_axi_if_ncaiu<%=axiidx%>.crvalid                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_ready                ( m_axi_if_ncaiu<%=axiidx%>.crready                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_resp                 ( m_axi_if_ncaiu<%=axiidx%>.crresp                    ) ,
<%     if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_trace                  ( m_axi_if_ncaiu<%=axiidx%>.actrace                      ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_trace                  ( 'd0/*m_axi_if_ncaiu<%=axiidx%>.crtrace*/                       ) ,
<%     } %>                                                                                                                                  
                                                                                                                                  
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_valid                ( m_axi_if_ncaiu<%=axiidx%>.cdvalid                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_ready                ( m_axi_if_ncaiu<%=axiidx%>.cdready                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_data                 ( m_axi_if_ncaiu<%=axiidx%>.cddata                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_last                 ( m_axi_if_ncaiu<%=axiidx%>.cdlast                    ) ,
<%     if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_trace                  ( 'd0/*m_axi_if_ncaiu<%=axiidx%>.cdtrace  */                     ) ,
<%     } %>                                                                                                                                  
<%   } %>
<% axiidx++  }}} %>                                                                                                                   
                                                                                                                                    
<% }); %>

<%axiidx =0; obj.DmiInfo.forEach(function(bundle, idx) { %>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_ready                ( m_axi_slv_if_dmi<%=idx%>.awready                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_valid                ( m_axi_slv_if_dmi<%=idx%>.awvalid                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_id                   ( m_axi_slv_if_dmi<%=idx%>.awid                       ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_addr                 ( m_axi_slv_if_dmi<%=idx%>.awaddr                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_burst                ( m_axi_slv_if_dmi<%=idx%>.awburst                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_len                  ( m_axi_slv_if_dmi<%=idx%>.awlen                      ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_lock                 ( m_axi_slv_if_dmi<%=idx%>.awlock                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_prot                 ( m_axi_slv_if_dmi<%=idx%>.awprot                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_size                 ( m_axi_slv_if_dmi<%=idx%>.awsize                     ) ,
<%     if (bundle.interfaces.axiInt.params.wQos>0) { %>                                                                                  
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_qos                  ( m_axi_slv_if_dmi<%=idx%>.awqos                      ) ,
<%     } %>                                                                                                                              
<%     if (bundle.interfaces.axiInt.params.wRegion>0) { %>                                                                               
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_region               ( m_axi_slv_if_dmi<%=idx%>.awregion                   ) ,
<%     } %>                                                                                                                              
<%     if (bundle.interfaces.axiInt.params.wAwUser > 0) { %>                                                                             
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_user                 ( m_axi_slv_if_dmi<%=idx%>.awuser                     ) ,
<%     } %>                                                                                                                              
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_cache                ( m_axi_slv_if_dmi<%=idx%>.awcache                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_ready                 ( m_axi_slv_if_dmi<%=idx%>.wready                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_valid                 ( m_axi_slv_if_dmi<%=idx%>.wvalid                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_data                  ( m_axi_slv_if_dmi<%=idx%>.wdata[<%=bundle.interfaces.axiInt.params.wData -1%> : 0]               ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_last                  ( m_axi_slv_if_dmi<%=idx%>.wlast                      ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_strb                  ( m_axi_slv_if_dmi<%=idx%>.wstrb[<%=bundle.interfaces.axiInt.params.wData/8 -1%> : 0]               ) ,
<%     if (bundle.interfaces.axiInt.params.wWUser > 0) { %>                                                                              
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_user                  ( m_axi_slv_if_dmi<%=idx%>.wuser                      ) ,
<%     } %>                                                                                                                              
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_ready                 ( m_axi_slv_if_dmi<%=idx%>.bready                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_valid                 ( m_axi_slv_if_dmi<%=idx%>.bvalid                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_id                    ( m_axi_slv_if_dmi<%=idx%>.bid                        ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_resp                  ( m_axi_slv_if_dmi<%=idx%>.bresp                      ) ,
<%     if (bundle.interfaces.axiInt.params.wBUser > 0) { %>                                                                              
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_user                  ( m_axi_slv_if_dmi<%=idx%>.buser                      ) ,
<%     } %>                                                                                                                              
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_ready                ( m_axi_slv_if_dmi<%=idx%>.arready                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_valid                ( m_axi_slv_if_dmi<%=idx%>.arvalid                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_addr                 ( m_axi_slv_if_dmi<%=idx%>.araddr                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_burst                ( m_axi_slv_if_dmi<%=idx%>.arburst                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_id                   ( m_axi_slv_if_dmi<%=idx%>.arid                       ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_len                  ( m_axi_slv_if_dmi<%=idx%>.arlen                      ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_lock                 ( m_axi_slv_if_dmi<%=idx%>.arlock                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_prot                 ( m_axi_slv_if_dmi<%=idx%>.arprot                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_size                 ( m_axi_slv_if_dmi<%=idx%>.arsize                     ) ,
<%     if (bundle.interfaces.axiInt.params.wQos>0) { %>                                                                                  
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_qos                  ( m_axi_slv_if_dmi<%=idx%>.arqos                      ) ,
<%     } %>                                                                                                                              
<%     if (bundle.interfaces.axiInt.params.wRegion>0) { %>                                                                               
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_region               ( m_axi_slv_if_dmi<%=idx%>.arregion                   ) ,
<%     } %>                                                                                                                              
<%     if (bundle.interfaces.axiInt.params.wArUser > 0) { %>                                                                             
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_user                 ( m_axi_slv_if_dmi<%=idx%>.aruser                     ) ,
<%     } %>                                                                                                                              
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_cache                ( m_axi_slv_if_dmi<%=idx%>.arcache                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_id                    ( m_axi_slv_if_dmi<%=idx%>.rid                        ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_resp                  ( m_axi_slv_if_dmi<%=idx%>.rresp[1:0]                 ) ,
<%     if (bundle.interfaces.axiInt.params.wRUser > 0) { %>                                                                              
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_user                  ( m_axi_slv_if_dmi<%=idx%>.ruser                      ) ,
<%     } %>                                                                                                                              
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_ready                 ( m_axi_slv_if_dmi<%=idx%>.rready                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_valid                 ( m_axi_slv_if_dmi<%=idx%>.rvalid                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_data                  ( m_axi_slv_if_dmi<%=idx%>.rdata[<%=bundle.interfaces.axiInt.params.wData - 1%> : 0]                ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_last                  ( m_axi_slv_if_dmi<%=idx%>.rlast                      ) ,

<% axiidx++ }); %>

<% obj.DiiInfo.forEach(function(bundle, idx) { %>
    <% if (bundle.configuration == 0) { %>  					       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_ready                 ( m_axi_slv_if_dii<%=idx%>.awready                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_valid                 ( m_axi_slv_if_dii<%=idx%>.awvalid                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_id                    ( m_axi_slv_if_dii<%=idx%>.awid                      ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_addr                  ( m_axi_slv_if_dii<%=idx%>.awaddr                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_burst                 ( m_axi_slv_if_dii<%=idx%>.awburst                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_len                   ( m_axi_slv_if_dii<%=idx%>.awlen                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_lock                  ( m_axi_slv_if_dii<%=idx%>.awlock                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_prot                  ( m_axi_slv_if_dii<%=idx%>.awprot                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_size                  ( m_axi_slv_if_dii<%=idx%>.awsize                    ) ,
<%     if (bundle.interfaces.axiInt.params.wQos>0) { %>                                                                            
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_qos                   ( m_axi_slv_if_dii<%=idx%>.awqos                     ) ,
<%     } %>                                                                                                                        
<%     if (bundle.interfaces.axiInt.params.wRegion>0) { %>                                                                         
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_region                ( m_axi_slv_if_dii<%=idx%>.awregion                  ) ,
<%     } %>                                                                                                                        
<%     if (bundle.interfaces.axiInt.params.wAwUser > 0) { %>                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_user                  ( m_axi_slv_if_dii<%=idx%>.awuser                    ) ,
<%     } %>                                                                                                                        
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_cache                 ( m_axi_slv_if_dii<%=idx%>.awcache                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_ready                  ( m_axi_slv_if_dii<%=idx%>.wready                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_valid                  ( m_axi_slv_if_dii<%=idx%>.wvalid                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_data                   ( m_axi_slv_if_dii<%=idx%>.wdata[<%=bundle.interfaces.axiInt.params.wData - 1%> : 0]               ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_last                   ( m_axi_slv_if_dii<%=idx%>.wlast                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_strb                   ( m_axi_slv_if_dii<%=idx%>.wstrb[<%=bundle.interfaces.axiInt.params.wData/8 - 1%> : 0]               ) ,
<%     if (bundle.interfaces.axiInt.params.wWUser > 0) { %>                                                                        
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_user                   ( m_axi_slv_if_dii<%=idx%>.wuser                     ) ,
<%     } %>                                                                                                                        
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_ready                  ( m_axi_slv_if_dii<%=idx%>.bready                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_valid                  ( m_axi_slv_if_dii<%=idx%>.bvalid                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_id                     ( m_axi_slv_if_dii<%=idx%>.bid                       ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_resp                   ( m_axi_slv_if_dii<%=idx%>.bresp                     ) ,
<%     if (bundle.interfaces.axiInt.params.wBUser > 0) { %>                                                                        
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_user                   ( m_axi_slv_if_dii<%=idx%>.buser                     ) ,
<%     } %>                                                                                                                        
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_ready                 ( m_axi_slv_if_dii<%=idx%>.arready                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_valid                 ( m_axi_slv_if_dii<%=idx%>.arvalid                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_addr                  ( m_axi_slv_if_dii<%=idx%>.araddr                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_burst                 ( m_axi_slv_if_dii<%=idx%>.arburst                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_id                    ( m_axi_slv_if_dii<%=idx%>.arid                      ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_len                   ( m_axi_slv_if_dii<%=idx%>.arlen                     ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_lock                  ( m_axi_slv_if_dii<%=idx%>.arlock                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_prot                  ( m_axi_slv_if_dii<%=idx%>.arprot                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_size                  ( m_axi_slv_if_dii<%=idx%>.arsize                    ) ,
<%     if (bundle.interfaces.axiInt.params.wQos>0) { %>                                                                            
             .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_qos                     ( m_axi_slv_if_dii<%=idx%>.arqos                     ) ,
<%     } %>                                                                                                                        
<%     if (bundle.interfaces.axiInt.params.wRegion>0) { %>                                                                         
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_region                ( m_axi_slv_if_dii<%=idx%>.arregion                  ) ,
<%     } %>                                                                                                                        
<%     if (bundle.interfaces.axiInt.params.wArUser > 0) { %>                                                                       
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_user                  ( m_axi_slv_if_dii<%=idx%>.aruser                    ) ,
<%     } %>                                                                                                                        
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_cache                 ( m_axi_slv_if_dii<%=idx%>.arcache                   ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_id                     ( m_axi_slv_if_dii<%=idx%>.rid                       ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_resp                   ( m_axi_slv_if_dii<%=idx%>.rresp[1:0]                ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_ready                  ( m_axi_slv_if_dii<%=idx%>.rready                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_valid                  ( m_axi_slv_if_dii<%=idx%>.rvalid                    ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_data                   ( m_axi_slv_if_dii<%=idx%>.rdata[<%=bundle.interfaces.axiInt.params.wData - 1%> : 0]               ) ,
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_last                   ( m_axi_slv_if_dii<%=idx%>.rlast                     ) ,
<%     if (bundle.interfaces.axiInt.params.wRUser > 0) { %>                                                                        
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_user                   ( m_axi_slv_if_dii<%=idx%>.ruser                     ) ,
<%     } %>
<%  } %>
<% }); %>
<% obj.PmaInfo.forEach(function(bundle, idx) { %>
    // Needs to add PMA interface/agent if support required 
 		       .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.masterInt.name%>REQn                  ( 1 ),
 		       .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.masterInt.name%>ACTIVE                (   ),
 		       .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.masterInt.name%>ACCEPTn               (   ),
 		       .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.masterInt.name%>DENY                  (   ),
<% }); %>
  <% for(var clock=0; clock < obj.Clocks.length; clock++) { %>
<% if (clock == 0) { %>
		.<%=obj.Clocks[clock].interfaces[Object.keys(obj.Clocks[clock].interfaces)[0]].module%>clk      (<%=obj.Clocks[clock].name%>clk                          )
<% } else { %>
	,	.<%=obj.Clocks[clock].interfaces[Object.keys(obj.Clocks[clock].interfaces)[0]].module%>clk      (<%=obj.Clocks[clock].name%>clk                          )
<% } %>
 	,	.<%=obj.Clocks[clock].interfaces[Object.keys(obj.Clocks[clock].interfaces)[0]].module%>test_en  (<%=obj.Clocks[clock].name%>test_en                      )
<% if ( obj.Clocks[clock].name.indexOf('check') < 0 ) { %>
 	,	.<%=obj.Clocks[clock].interfaces[Object.keys(obj.Clocks[clock].interfaces)[0]].module%>reset_n  (<%=obj.Clocks[clock].name%>reset_n                      )
<% } %>
   <% } %>
   );


    //Passing virtual interface handles to UVM world
  initial begin
    automatic int indx = <%= ioaiu_idx + obj.nDMIs%>;

<% var chi_idx=0; var idx=0; obj.AiuInfo.forEach(function(bundle, pidx) { %>
<%   if(bundle.fnNativeInterface === 'ACE' || bundle.fnNativeInterface === "ACE-LITE" || bundle.fnNativeInterface === 'AXI4' || bundle.fnNativeInterface === "ACELITE-E" || bundle.fnNativeInterface === 'ACE5' || bundle.fnNativeInterface === 'AXI5'  ) {   
      var userMax = Math.max(bundle.interfaces.axiInt[0].params.wAwUser, 
                               bundle.interfaces.axiInt[0].params.wArUser,
                               bundle.interfaces.axiInt[0].params.wWUser,
                               bundle.interfaces.axiInt[0].params.wBUser,
                               bundle.interfaces.axiInt[0].params.wRUser);
      var wAxId   = Math.max(bundle.interfaces.axiInt[0].params.wArId,bundle.interfaces.axiInt[0].params.wAwId); 
      var wAxAddr = bundle.interfaces.axiInt[0].params.wAddr;
      var wXData  = bundle.interfaces.axiInt[0].params.wData;
    } else if(bundle.fnNativeInterface.includes('CHI')) {
      var datawidth        = bundle.interfaces.chiInt.params.wData;
      var nodeid_width     = bundle.interfaces.chiInt.params.SrcID;
      var addr_width       = bundle.interfaces.chiInt.params.wAddr;
      var req_rsvdc_width  = bundle.interfaces.chiInt.params.REQ_RSVDC;
      var data_rsvdc_width = bundle.interfaces.chiInt.params.DAT_RSVDC;
      var data_check       = 0; 
      if( bundle.interfaces.chiInt.params.enPoison == true){
      var data_poison      = 1; 
      } else {
      var data_poison      = 0; 
      }
      var input_skew       = 1;
    }
%>
    <%if(bundle.fnNativeInterface.includes('CHI')) {%>
        <%let intf_name = '';%>
        <%if(bundle.fnNativeInterface == 'CHI-B'){%>
            <%intf_name = 'chi_B_Interface';%>
        <%}else{%>
            <%intf_name = 'chi_E_Interface';%>
        <%}%>

        uvm_config_db #(virtual interface <%=intf_name%>_activeDownStream#(.DATA_WIDTH(<%=datawidth%>),
	       	               .NODE_ID_WIDTH(<%=nodeid_width%>),
	       	               .ADDR_WIDTH(<%=addr_width%>),
	       	               .REQ_RSVDC_WIDTH(<%=req_rsvdc_width%>),
	       	               .DATA_RSVDC_WIDTH(<%=data_rsvdc_width%>),
	       	               .DATA_CHECK(<%=data_check%>),
                           .DATA_POISON(<%=data_poison%>))) ::set(null, "*m_aiuChiMstAgent<%=chi_idx%>", "vif", m_chi_if_chiaiu<%=chi_idx%>.activeDownStream);
        uvm_config_db #(virtual interface <%=intf_name%>_passive#(.DATA_WIDTH(<%=datawidth%>),
	       	               .NODE_ID_WIDTH(<%=nodeid_width%>),
	       	               .ADDR_WIDTH(<%=addr_width%>),
	       	               .REQ_RSVDC_WIDTH(<%=req_rsvdc_width%>),
	       	               .DATA_RSVDC_WIDTH(<%=data_rsvdc_width%>),
	       	               .DATA_CHECK(<%=data_check%>),
                           .DATA_POISON(<%=data_poison%>))) ::set(null, "*m_aiuChiMstAgentPassive<%=chi_idx%>", "vif", m_chi_if_chiaiu<%=chi_idx%>.passiveDownStream);

<% chi_idx++; %>
<%       } else {
           for (var mpu_io = 0; mpu_io < bundle.nNativeInterfacePorts; mpu_io++){
           if(bundle.fnNativeInterface == 'ACE') { %>
    uvm_config_db #(virtual cdnAceFullActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgent<%=idx%>", "vif", m_axi_if_ncaiu<%=idx%>.activeMaster);
    uvm_config_db #(virtual cdnAceFullPassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgentPassive<%=idx%>", "vif", m_axi_if_ncaiu<%=idx%>.passiveMaster);
<%  idx++  } else if(bundle.fnNativeInterface == 'ACE5') { %>
    uvm_config_db #(virtual cdnAce5FullActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgent<%=idx%>", "vif", m_axi_if_ncaiu<%=idx%>.activeMaster);
    uvm_config_db #(virtual cdnAce5FullPassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgentPassive<%=idx%>", "vif", m_axi_if_ncaiu<%=idx%>.passiveMaster);
<%  idx++  } else if(bundle.fnNativeInterface === "ACELITE-E" && bundle.interfaces.axiInt[mpu_io].params.eAc>0) { %>
    uvm_config_db #(virtual cdnAce5LiteDvmActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgent<%=idx%>", "vif", m_axi_if_ncaiu<%=idx%>.activeMaster);
    uvm_config_db #(virtual cdnAce5LiteDvmPassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgentPassive<%=idx%>", "vif",  m_axi_if_ncaiu<%=idx%>.passiveMaster);
<%  idx++  } else if(bundle.fnNativeInterface === "ACELITE-E") { %>
    uvm_config_db #(virtual cdnAce5LiteActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgent<%=idx%>", "vif", m_axi_if_ncaiu<%=idx%>.activeMaster);
    uvm_config_db #(virtual cdnAce5LitePassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgentPassive<%=idx%>", "vif",  m_axi_if_ncaiu<%=idx%>.passiveMaster);
<%  idx++  } else if(bundle.fnNativeInterface === "ACE-LITE" && bundle.interfaces.axiInt[mpu_io].params.eAc>0) { %>
    uvm_config_db #(virtual cdnAceLiteDvmActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgent<%=idx%>", "vif", m_axi_if_ncaiu<%=idx%>.activeMaster);
    uvm_config_db #(virtual cdnAceLiteDvmPassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgentPassive<%=idx%>", "vif",  m_axi_if_ncaiu<%=idx%>.passiveMaster);
<%  idx++  } else if(bundle.fnNativeInterface == "ACE-LITE") { %>
    uvm_config_db #(virtual cdnAceLiteActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgent<%=idx%>", "vif", m_axi_if_ncaiu<%=idx%>.activeMaster);
    uvm_config_db #(virtual cdnAceLitePassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgentPassive<%=idx%>", "vif",  m_axi_if_ncaiu<%=idx%>.passiveMaster);
<%  idx++  } else if(bundle.fnNativeInterface == "AXI5") { %>
    uvm_config_db #(virtual cdnAxi5ActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgent<%=idx%>", "vif", m_axi_if_ncaiu<%=idx%>.activeMaster);
    uvm_config_db #(virtual cdnAxi5PassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgentPassive<%=idx%>", "vif", m_axi_if_ncaiu<%=idx%>.passiveMaster);
<%  idx++  } else { %>
    uvm_config_db #(virtual cdnAxi4ActiveMasterInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgent<%=idx%>", "vif", m_axi_if_ncaiu<%=idx%>.activeMaster);
    uvm_config_db #(virtual cdnAxi4PassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null, "*m_aiuMstAgentPassive<%=idx%>", "vif", m_axi_if_ncaiu<%=idx%>.passiveMaster);
<%  idx++  }}} %>
<%   }); %>

   <% obj.DmiInfo.forEach(function(e, idx, array) {
     var userMax = Math.max(e.interfaces.axiInt.params.wAwUser, 
                              e.interfaces.axiInt.params.wArUser,
                              e.interfaces.axiInt.params.wWUser,
                              e.interfaces.axiInt.params.wBUser,
                              e.interfaces.axiInt.params.wRUser);
     var wAxId   = Math.max(e.interfaces.axiInt.params.wArId,e.interfaces.axiInt.params.wAwId); 
     var wAxAddr = e.interfaces.axiInt.params.wAddr;
     var wXData  = e.interfaces.axiInt.params.wData;
     %>
    uvm_config_db #(virtual cdnAxi4ActiveSlaveInterface#(.WRITE_ID_WIDTH(<%=obj.DmiInfo[idx].interfaces.axiInt.params.wAwId%>),
                           .READ_ID_WIDTH(<%=obj.DmiInfo[idx].interfaces.axiInt.params.wArId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null,"*m_dmiSlvAgent<%=idx%>","vif",m_axi_slv_if_dmi<%=idx%>.activeSlave);

    uvm_config_db #(virtual cdnAxi4PassiveInterface#(.WRITE_ID_WIDTH(<%=obj.DmiInfo[idx].interfaces.axiInt.params.wAwId%>),
                           .READ_ID_WIDTH(<%=obj.DmiInfo[idx].interfaces.axiInt.params.wArId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null,"*m_dmiSlvAgentPassive<%=idx%>","vif",m_axi_slv_if_dmi<%=idx%>.passiveSlave);
    <%axiidx++  }) %>

   <% obj.DiiInfo.forEach(function(e, idx, array) {
     var userMax = Math.max(e.interfaces.axiInt.params.wAwUser, 
                              e.interfaces.axiInt.params.wArUser,
                              e.interfaces.axiInt.params.wWUser,
                              e.interfaces.axiInt.params.wBUser,
                              e.interfaces.axiInt.params.wRUser);
     var wAxId   = Math.max(e.interfaces.axiInt.params.wArId,e.interfaces.axiInt.params.wAwId); 
     var wAxAddr = e.interfaces.axiInt.params.wAddr;
     var wXData  = e.interfaces.axiInt.params.wData;
     %>
    <% if (obj.DiiInfo[idx].configuration == 0) { %>  					       
    uvm_config_db #(virtual cdnAxi4ActiveSlaveInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null,"*m_diiSlvAgent<%=idx%>","vif",m_axi_slv_if_dii<%=idx%>.activeSlave);

    uvm_config_db #(virtual cdnAxi4PassiveInterface#(.ID_WIDTH(<%=wAxId%>),
                           .ADDR_WIDTH(<%=wAxAddr%>),
                           .DATA_WIDTH(<%=wXData%>),
                           .USER_WIDTH(<%=userMax%>)))::set(null,"*m_diiSlvAgentPassive<%=idx%>","vif",m_axi_slv_if_dii<%=idx%>.passiveSlave);
    <%axiidx++  } })%>

        
<%if(obj.useResiliency == 1){%>
    uvm_config_db#(virtual interface cdnApb4ActiveMasterInterface#(
                     .NUM_OF_SLAVES(<%=obj.FscInfo.interfaces.apbInterface.params.wPsel%>),
                     .ADDRESS_WIDTH(<%=obj.FscInfo.interfaces.apbInterface.params.wAddr%>),
                     .DATA_WIDTH(<%=obj.FscInfo.interfaces.apbInterface.params.wData%>)))::set(null,"*m_fsc_activeMaster*","vif", m_fsc_apb_if.activeMaster);
    uvm_config_db#(virtual interface cdnApb4PassiveMasterInterface#(
                     .NUM_OF_SLAVES(<%=obj.FscInfo.interfaces.apbInterface.params.wPsel%>),
                     .ADDRESS_WIDTH(<%=obj.FscInfo.interfaces.apbInterface.params.wAddr%>),
                     .DATA_WIDTH(<%=obj.FscInfo.interfaces.apbInterface.params.wData%>)))::set(null,"*m_fsc_passiveMaster*","vif", m_fsc_apb_if.passiveMaster);
<% } %>
<%if(obj.DebugApbInfo.length > 0){%>
    uvm_config_db#(virtual interface cdnApb4ActiveMasterInterface#(
                     .NUM_OF_SLAVES(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wPsel%>),
                     .ADDRESS_WIDTH(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wAddr%>),
                     .DATA_WIDTH(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wData%>)))::set(null,"*m_apb_dbg_activeMaster*","vif", m_apb_dbg_if.activeMaster);
    uvm_config_db#(virtual interface cdnApb4PassiveMasterInterface#(
                     .NUM_OF_SLAVES(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wPsel%>),
                     .ADDRESS_WIDTH(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wAddr%>),
                     .DATA_WIDTH(<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wData%>)))::set(null,"*m_apb_dbg_passiveMaster*","vif", m_apb_dbg_if.passiveMaster);
<% } %>


 
  end //initial


  assign dut_clk = sys_clk;
  assign soft_rstn = sys_rstn;
  
//--------------------------------------------
<% if(obj.useResiliency == 1){ %>
always @(posedge m_fsc_master_fault.mission_fault) begin
    if(m_fsc_master_fault.mission_fault === 1'b1) begin
        mission_fault_detected.trigger();
        $display("triggered mission_fault_detected @time: %0t",$time);
    end
end
<% } %>

<%l_chi_idx=0;%>
  <%for(pidx = 0; pidx < obj.AiuInfo.length; pidx++) {%>
    <%if(obj.AiuInfo[pidx].fnNativeInterface.includes('CHI')){%>
  <%if(obj.AiuInfo[pidx].interfaces.chiInt.params.checkType != "NONE" ){%>
  always_comb begin
    foreach(chi<%=pidx%>_rx_req_flit_chk[i]) begin
        if (i*8 + 7 < $bits(m_chi_if_chiaiu<%=l_chi_idx%>.ReqFlit)) begin
            chi<%=pidx%>_rx_req_flit_chk[i] = (($countones(m_chi_if_chiaiu<%=l_chi_idx%>.ReqFlit[(i*8) +: 8])) % 2 == 0);
        end else begin
            chi<%=pidx%>_rx_req_flit_chk[i] =  ($countones(m_chi_if_chiaiu<%=l_chi_idx%>.ReqFlit[<%=obj.AiuInfo[pidx].interfaces.chiInt.params.wReqflit-1%>:(<%=obj.AiuInfo[pidx].interfaces.chiInt.params.wReqflit - (obj.AiuInfo[pidx].interfaces.chiInt.params.wReqflit%8)%>)]) % 2 == 0);
        end
    end
    foreach(chi<%=pidx%>_rx_rsp_flit_chk[i]) begin
        if (i*8 + 7 < $bits(m_chi_if_chiaiu<%=l_chi_idx%>.DownRspFlit)) begin
            chi<%=pidx%>_rx_rsp_flit_chk[i] = (($countones(m_chi_if_chiaiu<%=l_chi_idx%>.DownRspFlit[(i*8) +: 8])) % 2 == 0);
        end else begin
            chi<%=pidx%>_rx_rsp_flit_chk[i] =  ($countones(m_chi_if_chiaiu<%=l_chi_idx%>.DownRspFlit[<%=obj.AiuInfo[pidx].interfaces.chiInt.params.wRspflit-1%>:(<%=obj.AiuInfo[pidx].interfaces.chiInt.params.wRspflit - (obj.AiuInfo[pidx].interfaces.chiInt.params.wRspflit%8)%>)]) % 2 == 0);
        end
    end
    foreach(chi<%=pidx%>_rx_dat_flit_chk[i]) begin
        if (i*8 + 7 < $bits(m_chi_if_chiaiu<%=l_chi_idx%>.DownDatFlit)) begin
            chi<%=pidx%>_rx_dat_flit_chk[i] = (($countones(m_chi_if_chiaiu<%=l_chi_idx%>.DownDatFlit[(i*8) +: 8])) % 2 == 0);
        end else begin
            chi<%=pidx%>_rx_dat_flit_chk[i] =  ($countones(m_chi_if_chiaiu<%=l_chi_idx%>.DownDatFlit[<%=obj.AiuInfo[pidx].interfaces.chiInt.params.wDatflit-1%>:(<%=obj.AiuInfo[pidx].interfaces.chiInt.params.wDatflit - (obj.AiuInfo[pidx].interfaces.chiInt.params.wDatflit%8)%>)]) % 2 == 0);
        end
    end
  end
      <%}%>
      <%l_chi_idx++%>
      <%}%>
  <%}%>
//--------------------------------------------
  //Test call
  initial begin
    $timeformat(-9,0,"ns",0);
    `ifdef DUMP_ON
        if($test$plusargs("en_dump")) begin
            <%  if(obj.CDN) { %>
          $shm_open ( "waves.shm" ) ;
          $shm_probe ( "ACMS" ) ;
            <%  } else { %>
          $fsdbDumpvars("+all");
            <%  } %>
        end
    `endif
    run_test();
    $finish;
  end
  <% if(obj.useResiliency) { %>
       fsys_fault_injector_checker fault_injector_checker(
          <% for(var clock=0; clock < obj.Clocks.length; clock++) { %>
               <% if (obj.Clocks[clock].name.includes("_check") == false){ %>
                    <%=obj.Clocks[clock].name%>clk,  
               <% } %>
          <% } %>
       soft_rstn);
  <% } %>
                  
//-----------------------------------------------------------------------------
// Generate clocks and reset
//-----------------------------------------------------------------------------
<% for(var clock=0; clock < obj.Clocks.length; clock++) { %>
clk_rst_gen <%=clocks[clock]%>_gen(.clk_fr(m_clk_if_<%=clocks[clock]%>.clk), .clk_tb(<%=obj.Clocks[clock].name%>clk_sync), .rst(m_clk_if_<%=clocks[clock]%>.reset_n));
  defparam <%=clocks[clock]%>_gen.CLK_PERIOD = <%=obj.Clocks[clock].params.period%>;
<% } %>
  
  // Use first customer defined clock as sys_clk. Customer needs to confirm to this
    assign sys_clk = m_clk_if_<%=clocks[0]%>.clk;
    assign sys_rstn = m_clk_if_<%=clocks[0]%>.reset_n;
  



  task assert_error(input string verbose, input string msg);
      if(verbose == "FATAL") begin 
          `uvm_fatal("ASSERT_ERROR", msg); 
      end else begin 
          `uvm_error("ASSERT_ERROR", msg); 
      end
  endtask: assert_error

  //force
  initial begin
  <% var chi_idx=0; var idx=0; obj.AiuInfo.forEach(function(e, pidx, array) { %>
  <%    if((e.fnNativeInterface == 'CHI-A')||(e.fnNativeInterface == 'CHI-B')||(e.fnNativeInterface == 'CHI-E')) { %>
  <% chi_idx++; %>
  <% } else { %>
  <%     for (var mpu_io = 0; mpu_io < e.nNativeInterfacePorts; mpu_io++){%>
    force m_axi_if_ncaiu<%=idx%>.aruser     = 0; 
    force m_axi_if_ncaiu<%=idx%>.ruser      = 0; 
    force m_axi_if_ncaiu<%=idx%>.awuser     = 0; 
    force m_axi_if_ncaiu<%=idx%>.wuser      = 0; 
    force m_axi_if_ncaiu<%=idx%>.buser      = 0; 
  <% idx++;        }}%>
  <%} )%>
   <% obj.DmiInfo.forEach(function(e, idx, array) {%>
    force m_axi_slv_if_dmi<%=idx%>.arregion = 0;
    force m_axi_slv_if_dmi<%=idx%>.aruser   = 0; 
    force m_axi_slv_if_dmi<%=idx%>.ruser    = 0; 
    force m_axi_slv_if_dmi<%=idx%>.awregion = 0;
    force m_axi_slv_if_dmi<%=idx%>.awuser   = 0;
    force m_axi_slv_if_dmi<%=idx%>.wuser    = 0;
    force m_axi_slv_if_dmi<%=idx%>.buser    = 0; 
    force m_axi_slv_if_dmi<%=idx%>.awqos    = 0;
    force m_axi_slv_if_dmi<%=idx%>.arqos    = 0;
   <%  }) %>
   <% obj.DiiInfo.forEach(function(e, idx, array) {%>
   <% if (obj.DiiInfo[idx].configuration == 0) { %>  					       
    force m_axi_slv_if_dii<%=idx%>.arregion = 0;
    force m_axi_slv_if_dii<%=idx%>.aruser   = 0; 
    force m_axi_slv_if_dii<%=idx%>.ruser    = 0; 
    force m_axi_slv_if_dii<%=idx%>.awregion = 0;
    force m_axi_slv_if_dii<%=idx%>.awuser   = 0; 
    force m_axi_slv_if_dii<%=idx%>.wuser    = 0; 
    force m_axi_slv_if_dii<%=idx%>.buser    = 0; 
    force m_axi_slv_if_dii<%=idx%>.awqos    = 0;
    force m_axi_slv_if_dii<%=idx%>.arqos    = 0;
   <% }}) %>
  end


endmodule: tb_top
