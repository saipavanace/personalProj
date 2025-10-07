`ifndef GUARD_NCORE_VIP_CONFIGURATION_SV
`define GUARD_NCORE_VIP_CONFIGURATION_SV

//---------------------------------------------------------------------
//
//---------------------------------------------------------------------
<%
   var aiu_useAceQosPort = [];
   var aiu_useAceRegionPort = [];
   var aiu_wData = [];
   var aiu_wAddr = [];
   var aiu_wAwUser = [];
   var aiu_wWUser = [];
   var aiu_wBUser = [];
   var aiu_wArUser = [];
   var aiu_wRUser = [];
   var aiu_wId    = [];
   var aiu_useAceUniquePort = [];

   var dmi_useAceQosPort = [];
   var dmi_useAceRegionPort = [];
   var dmi_wData = [];
   var dmi_wAddr = [];
   var dmi_wAwUser = [];
   var dmi_wWUser = [];
   var dmi_wBUser = [];
   var dmi_wArUser = [];
   var dmi_wRUser = [];
   var dmi_wId    = [];
   var dmi_useAceUniquePort = [];
   
   var dii_wData = [];
   var dii_wAddr = [];
   var dii_useAceQosPort    = [];
   var dii_useAceRegionPort = [];
   var dii_wAwUser          = [];
   var dii_wWUser           = [];
   var dii_wBUser           = [];
   var dii_wArUser          = [];
   var dii_wRUser           = [];
   var dii_wId              = [];
   var dii_useAceUniquePort = [];
   var initiatorAgents        = obj.nAIUs ;

   for(var pidx = 0; pidx < obj.nDMIs; pidx++) {
       if((obj.DmiInfo[pidx].interfaces.axiInt.params.useQosPort == 0) && (obj.wPriorityLevel == 0)) { 
           dmi_useAceQosPort.push(0);
       } else {
           dmi_useAceQosPort.push(1);
       }
       dmi_useAceRegionPort.push(obj.DmiInfo[pidx].interfaces.axiInt.params.useRegionPort);
       dmi_wAwUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wAwUser);
       dmi_wWUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wWUser);
       dmi_wBUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wBUser);
       dmi_wArUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wArUser);
       dmi_wRUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wRUser);
       dmi_wId.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wAwId);
       dmi_wData.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wData);
       dmi_wAddr.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wAddr);
   }
   for(var pidx = 0; pidx < obj.nDIIs; pidx++) {
       if((obj.DiiInfo[pidx].interfaces.axiInt.params.useQosPort == 0) && (obj.wPriorityLevel == 0)) { 
           dii_useAceQosPort.push(0);
       } else {
           dii_useAceQosPort.push(1);
       }
       dii_useAceRegionPort.push(obj.DiiInfo[pidx].interfaces.axiInt.params.useRegionPort);
       dii_wAwUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wAwUser);
       dii_wWUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wWUser);
       dii_wBUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wBUser);
       dii_wArUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wArUser);
       dii_wRUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wRUser);
       dii_wId.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wAwId);
       dii_wData.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wData);
       dii_wAddr.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wAddr);
   }
%>		  
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var pidx = 0;
   var ridx = 0;
   var total_aiu = 0;
   var mpu_nb = 0;
   var chiaiu_idx = 0;
   var ioaiu_idx = 0;
   var axi_idx = 0;
   var acelite_idx = 0;
   var initiatorAgents = obj.AiuInfo.length ;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
       _child_blk[pidx]   = 'chiaiu';
       chiaiu_idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
       _child_blk[pidx]   = 'ioaiu';
       ioaiu_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
       if (obj.AiuInfo[pidx].nNativeInterfacePorts > 1) { mpu_nb ++;}
       }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5' ){
       axi_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
       }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE'){
       acelite_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
       }
   }
   total_aiu = chiaiu_idx + ioaiu_idx;
   
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



//----------------------------------------------------------------------
//number of AIUs 	= <%=total_aiu%>
//number of CHIAIU 	= <%=chiaiu_idx%>
//number of IOAIU  	= <%=ioaiu_idx%>
//number of MPU      	= <%=mpu_nb%>
//number of AXI4     	= <%=axi_idx%>
//number of ACE-LITE 	= <%=acelite_idx%>
//number of DMI    	= <%=obj.nDMIs%>
//number of DII    	= <%=obj.nDIIs%>
//number of DCE    	= <%=obj.nDCEs%>
//----------------------------------------------------------------------


class ncore_vip_configuration extends uvm_object;

  int k_timeout                              = 200000;

  //Utility macro
  `uvm_object_utils (ncore_vip_configuration)
<% var cnt =0; var chi_idx =0;%>
<% obj.AiuInfo.forEach(function(e, indx, array) { %>
<%       if(e.fnNativeInterface.includes('CHI')) {%>
  cdnChiUvmConfig m_aiuChiMstCfg<%=chi_idx%> ;
  cdnChiUvmConfig m_aiuChiMstCfgPassive<%=chi_idx%> ;
<%       chi_idx++;  %>
<%       } else { 
  for (var mpu_io = 0; mpu_io < e.nNativeInterfacePorts; mpu_io++){
   if(e.fnNativeInterface == 'ACE') { %>
  aceFullUvmUserConfig  m_aiuMstCfg<%=cnt%> ;
  aceFullUvmUserConfig  m_aiuMstCfgPassive<%=cnt%> ;
<%  cnt++  } else if(e.fnNativeInterface === 'ACE5' ) { %>
  ace5FullUvmUserConfig  m_aiuMstCfg<%=cnt%> ;
  ace5FullUvmUserConfig  m_aiuMstCfgPassive<%=cnt%> ;
<%  cnt++  } else if(e.fnNativeInterface === 'ACELITE-E' ) { %>
  ace5LiteUvmUserConfig  m_aiuMstCfg<%=cnt%>;
  ace5LiteUvmUserConfig  m_aiuMstCfgPassive<%=cnt%> ;
<%  cnt++  } else if(e.fnNativeInterface === 'ACE-LITE' ) { %>
  aceLiteUvmUserConfig  m_aiuMstCfg<%=cnt%>;
  aceLiteUvmUserConfig  m_aiuMstCfgPassive<%=cnt%> ;
<%  cnt++  } else if(e.fnNativeInterface === 'AXI4' ) { %>
  axi4UvmUserConfig  m_aiuMstCfg<%=cnt%>;
  axi4UvmUserConfig  m_aiuMstCfgPassive<%=cnt%> ;
<%  cnt++  } else if(e.fnNativeInterface === 'AXI5' ) { %>
  axi5UvmUserConfig  m_aiuMstCfg<%=cnt%>;
  axi5UvmUserConfig  m_aiuMstCfgPassive<%=cnt%> ;
<%  cnt++  }}} %>
<%   }); %>
<% var cnt = 0;
obj.DmiInfo.forEach(function(e, i, array) { %>
  axiSlaveUvmUserConfig m_dmiSlvCfg<%=cnt%>;
  axiSlaveUvmUserConfig m_dmiSlvCfgPassive<%=cnt%>;
<% cnt++ }); %>

<% var cnt = 0;
obj.DiiInfo.forEach(function(e, i, array) { %>
<%  if (e.configuration == 0) {   %>	
  axiSlaveUvmUserConfig m_diiSlvCfg<%=cnt%>;
  axiSlaveUvmUserConfig m_diiSlvCfgPassive<%=cnt%>;
<% cnt++ } %>
<% }); %>

<%if(obj.useResiliency == 1){%>
  cdnApbUvmConfig m_fscMstCfg; 
  cdnApbUvmConfig m_fscMstCfgPassive;
<% } %>
<%if(obj.DebugApbInfo.length>0){%>
  cdnApbUvmConfig m_apb_dbg_MstCfg; 
  cdnApbUvmConfig m_apb_dbg_MstCfgPassive;
<% } %>

  function new (string name="ncore_vip_configuration");
    super.new(name);
  endfunction
     
//-------------------------------------------------------------------------  
//  Utility method in the testbench to initialize the configuration of AMBA
//  System ENV, and underlying CHI System ENV.
//-------------------------------------------------------------------------  
  extern function void set_amba_sys_config();

endclass
// =============================================================================

//------------------------------------------------------------------------------
function void ncore_vip_configuration::set_amba_sys_config();

//-----------------------------------------------------------------------------------------------------------  
//   svt_amba_system_configuration::create_sub_cfgs allows user to allocate
//   system configurations for AXI, and CHI System Envs.
//-----------------------------------------------------------------------------------------------------------  

//------------------------------------------------------------------------------------------------------------  
//  Allocates the RN and SN node configurations before a user sets the parameters.
//------------------------------------------------------------------------------------------------------------  

//------------------------------------------------------------------------------
// set AXI configuration
//------------------------------------------------------------------------------

<% var cnt =0; var chi_idx =0;%>
<% obj.AiuInfo.forEach(function(e, indx, array) { %>
<%   var addrwidth = e.wAddr %>
<%       if(e.fnNativeInterface.includes('CHI')) {%>
  m_aiuChiMstCfg<%=chi_idx%> = cdnChiUvmConfig::type_id::create("m_aiuChiMstCfg<%=chi_idx%>");
  <%if(e.fnNativeInterface == 'CHI-B'){%>
  m_aiuChiMstCfg<%=chi_idx%>.Issue_B_Compliant = 1; 
  <%}%>
  <%if(e.fnNativeInterface == 'CHI-E'){%>
  m_aiuChiMstCfg<%=chi_idx%>.Issue_E_Compliant = 1;
  m_aiuChiMstCfg<%=chi_idx%>.Issue_D_Compliant = 1;
  m_aiuChiMstCfg<%=chi_idx%>.Issue_C_Compliant = 1;
  m_aiuChiMstCfg<%=chi_idx%>.Issue_B_Compliant = 1;
  <%}%>
  <%if(e.interfaces.chiInt.params.REQ_RSVDC > 0){%>
    m_aiuChiMstCfg<%=chi_idx%>.SupportRSVDC = 1;
    m_aiuChiMstCfg<%=chi_idx%>.pins.ReqRSVDC.size = <%=e.interfaces.chiInt.params.REQ_RSVDC%>;
  <%}else{%>
    m_aiuChiMstCfg<%=chi_idx%>.SupportRSVDC = 0;
  <%}%>
//   <%if(e.interfaces.chiInt.params.DAT_RSVDC > 0){%>
//     m_aiuChiMstCfg<%=chi_idx%>.SupportRSVDC = 1;
//     m_aiuChiMstCfg<%=chi_idx%>.pins.TxDatRSVDC.size = <%=e.interfaces.chiInt.params.DAT_RSVDC%>;
//     m_aiuChiMstCfg<%=chi_idx%>.pins.RxDatRSVDC.size = <%=e.interfaces.chiInt.params.DAT_RSVDC%>;
//   <%}else{%>
//     m_aiuChiMstCfg<%=chi_idx%>.SupportRSVDC = 0;
//   <%}%>
  m_aiuChiMstCfg<%=chi_idx%>.pins.ReqAddr.size = <%=e.interfaces.chiInt.params.wAddr%>;
  m_aiuChiMstCfg<%=chi_idx%>.pins.SnpAddr.size = m_aiuChiMstCfg<%=chi_idx%>.pins.ReqAddr.size - 3;
  m_aiuChiMstCfg<%=chi_idx%>.pins.ReqLPID.size = <%=((e.interfaces.fnNativeInterface == 'CHI-B') ? 8 : 5)%>;
  m_aiuChiMstCfg<%=chi_idx%>.pins.ReqOpCode.size = <%=e.interfaces.chiInt.params.REQ_Opcode%>;
  m_aiuChiMstCfg<%=chi_idx%>.pins.ReqPCrdType.size = <%=e.interfaces.chiInt.params.PCrdType%>;
  m_aiuChiMstCfg<%=chi_idx%>.pins.ReqSnpAttr.size = <%=e.interfaces.chiInt.params.SnpAttr%>;
  m_aiuChiMstCfg<%=chi_idx%>.pins.ReqSrcID.size = <%=e.interfaces.chiInt.params.SrcID%>;
  m_aiuChiMstCfg<%=chi_idx%>.pins.ReqTgtID.size = <%=e.interfaces.chiInt.params.TgtID%>;
  m_aiuChiMstCfg<%=chi_idx%>.pins.RxDatSrcID.size = <%=e.interfaces.chiInt.params.SrcID%>;
  m_aiuChiMstCfg<%=chi_idx%>.pins.RxDatTgtID.size = <%=e.interfaces.chiInt.params.TgtID%>;
  m_aiuChiMstCfg<%=chi_idx%>.pins.TxDatSrcID.size = <%=e.interfaces.chiInt.params.SrcID%>;
  m_aiuChiMstCfg<%=chi_idx%>.pins.TxDatTgtID.size = <%=e.interfaces.chiInt.params.TgtID%>;
  m_aiuChiMstCfg<%=chi_idx%>.DataBusWidthInBytes =  <%=e.interfaces.chiInt.params.wData/8%>;;
  m_aiuChiMstCfg<%=chi_idx%>.is_active = UVM_ACTIVE;
  m_aiuChiMstCfg<%=chi_idx%>.LinkType = CDN_CHI_CFG_LINK_TYPE_RN2HN;
  m_aiuChiMstCfg<%=chi_idx%>.LinkInterface = CDN_CHI_CFG_LINK_INTERFACE_FULL;
  m_aiuChiMstCfg<%=chi_idx%>.Orientation = CDN_CHI_CFG_ORIENTATION_DOWNSTREAM;
  m_aiuChiMstCfg<%=chi_idx%>.NodeIdWidth = <%=e.interfaces.chiInt.params.SrcID%>; 
  m_aiuChiMstCfg<%=chi_idx%>.DataCheckFeature = 0;
  <%  if( e.interfaces.chiInt.params.enPoison == true){ %>
  m_aiuChiMstCfg<%=chi_idx%>.DataPoisonFeature = 1;
  <%} else {%>
  m_aiuChiMstCfg<%=chi_idx%>.DataPoisonFeature = 0;
  <%}%>
  if($test$plusargs("performance_test"))begin
    m_aiuChiMstCfg<%=chi_idx%>.MaxCreditDelayPerChannel = 0;
    m_aiuChiMstCfg<%=chi_idx%>.MaxOutStandingTransactions = <%= obj.AiuInfo[indx].cmpInfo.nOttCtrlEntries%>;
    m_aiuChiMstCfg<%=chi_idx%>.MaxReqCredits = 15;
    m_aiuChiMstCfg<%=chi_idx%>.MaxRspCredits = 15;
    m_aiuChiMstCfg<%=chi_idx%>.MaxDatCredits = 15;
    m_aiuChiMstCfg<%=chi_idx%>.KeepPermanentSysCoherency = 1;
    m_aiuChiMstCfg<%=chi_idx%>.KeepPermanentLinkActive = 1;
  end else begin
    m_aiuChiMstCfg<%=chi_idx%>.MaxCreditDelayPerChannel = 10;
  end
  
  m_aiuChiMstCfg<%=chi_idx%>.SourceID = <%=e.FUnitId%>;
  m_aiuChiMstCfg<%=chi_idx%>.TargetID = <%=e.FUnitId%>;
  m_aiuChiMstCfg<%=chi_idx%>.MiscellaneousID = 9;
  m_aiuChiMstCfg<%=chi_idx%>.CacheAwareRequests = 0;
  m_aiuChiMstCfg<%=chi_idx%>.CacheAwareSnoops = 1;
  m_aiuChiMstCfg<%=chi_idx%>.CacheAwareResponses = 1;
  m_aiuChiMstCfg<%=chi_idx%>.UsingSnoopFilter = 1;
  m_aiuChiMstCfg<%=chi_idx%>.UsingMainMemory = 0;
  m_aiuChiMstCfg<%=chi_idx%>.RandomDownStreamTargetID = 1;
  m_aiuChiMstCfg<%=chi_idx%>.ResetSignalsSimStart = 1;
  m_aiuChiMstCfg<%=chi_idx%>.CheckDownStream = 0;
  m_aiuChiMstCfg<%=chi_idx%>.CheckUpStream = 1;
  m_aiuChiMstCfg<%=chi_idx%>.print();

  m_aiuChiMstCfgPassive<%=chi_idx%> = cdnChiUvmConfig::type_id::create("m_aiuChiMstCfgPassive<%=chi_idx%>");
  <%if(e.fnNativeInterface == 'CHI-B'){%>
  m_aiuChiMstCfgPassive<%=chi_idx%>.Issue_B_Compliant = 1; 
  <%}%>
  <%if(e.fnNativeInterface == 'CHI-E'){%>
  m_aiuChiMstCfgPassive<%=chi_idx%>.Issue_E_Compliant = 1;
  m_aiuChiMstCfgPassive<%=chi_idx%>.Issue_D_Compliant = 1;
  m_aiuChiMstCfgPassive<%=chi_idx%>.Issue_C_Compliant = 1;
  m_aiuChiMstCfgPassive<%=chi_idx%>.Issue_B_Compliant = 1;
  <%}%>
  <%if(e.interfaces.chiInt.params.REQ_RSVDC > 0){%>
    m_aiuChiMstCfgPassive<%=chi_idx%>.SupportRSVDC = 1;
    m_aiuChiMstCfgPassive<%=chi_idx%>.pins.ReqRSVDC.size = <%=e.interfaces.chiInt.params.REQ_RSVDC%>;
  <%}else{%>
    m_aiuChiMstCfgPassive<%=chi_idx%>.SupportRSVDC = 0;
  <%}%>
//   <%if(e.interfaces.chiInt.params.DAT_RSVDC > 0){%>
//     m_aiuChiMstCfgPassive<%=chi_idx%>.SupportRSVDC = 1;
//     m_aiuChiMstCfgPassive<%=chi_idx%>.pins.TxDatRSVDC.size = <%=e.interfaces.chiInt.params.DAT_RSVDC%>;
//     m_aiuChiMstCfgPassive<%=chi_idx%>.pins.RxDatRSVDC.size = <%=e.interfaces.chiInt.params.DAT_RSVDC%>;
//   <%}else{%>
//     m_aiuChiMstCfgPassive<%=chi_idx%>.SupportRSVDC = 0;
//   <%}%>
  m_aiuChiMstCfgPassive<%=chi_idx%>.pins.ReqAddr.size =  <%=e.interfaces.chiInt.params.wAddr%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.pins.SnpAddr.size = m_aiuChiMstCfgPassive<%=chi_idx%>.pins.ReqAddr.size - 3;
  m_aiuChiMstCfgPassive<%=chi_idx%>.pins.ReqLPID.size = <%=((e.interfaces.fnNativeInterface == 'CHI-B') ? 8 : 5)%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.pins.ReqOpCode.size = <%=e.interfaces.chiInt.params.REQ_Opcode%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.pins.ReqPCrdType.size = <%=e.interfaces.chiInt.params.PCrdType%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.pins.ReqSnpAttr.size = <%=e.interfaces.chiInt.params.SnpAttr%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.pins.ReqSrcID.size = <%=e.interfaces.chiInt.params.SrcID%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.pins.ReqTgtID.size = <%=e.interfaces.chiInt.params.TgtID%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.pins.RxDatSrcID.size = <%=e.interfaces.chiInt.params.SrcID%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.pins.RxDatTgtID.size =  <%=e.interfaces.chiInt.params.TgtID%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.pins.TxDatSrcID.size = <%=e.interfaces.chiInt.params.SrcID%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.pins.TxDatTgtID.size = <%=e.interfaces.chiInt.params.TgtID%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.DataBusWidthInBytes =  <%=e.interfaces.chiInt.params.wData/8%>;;
  m_aiuChiMstCfgPassive<%=chi_idx%>.is_active = UVM_PASSIVE;
  m_aiuChiMstCfgPassive<%=chi_idx%>.LinkType = CDN_CHI_CFG_LINK_TYPE_RN2HN;
  m_aiuChiMstCfgPassive<%=chi_idx%>.LinkInterface = CDN_CHI_CFG_LINK_INTERFACE_FULL;
  m_aiuChiMstCfgPassive<%=chi_idx%>.Orientation = CDN_CHI_CFG_ORIENTATION_DOWNSTREAM;
  m_aiuChiMstCfgPassive<%=chi_idx%>.NodeIdWidth = <%=e.interfaces.chiInt.params.SrcID%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.DataCheckFeature = 0;
  <%  if( e.interfaces.chiInt.params.enPoison == true){ %>
  m_aiuChiMstCfgPassive<%=chi_idx%>.DataPoisonFeature = 1;
  <%} else {%>
  m_aiuChiMstCfgPassive<%=chi_idx%>.DataPoisonFeature = 0;
  <%}%>
  if($test$plusargs("performance_test"))begin
    m_aiuChiMstCfgPassive<%=chi_idx%>.MaxCreditDelayPerChannel = 0;
    m_aiuChiMstCfgPassive<%=chi_idx%>.MaxOutStandingTransactions = <%= obj.AiuInfo[indx].cmpInfo.nOttCtrlEntries%>;
    m_aiuChiMstCfgPassive<%=chi_idx%>.MaxReqCredits = 15;
    m_aiuChiMstCfgPassive<%=chi_idx%>.MaxRspCredits = 15;
    m_aiuChiMstCfgPassive<%=chi_idx%>.MaxDatCredits = 15;
    m_aiuChiMstCfgPassive<%=chi_idx%>.MaxReqCredits = 15;
    m_aiuChiMstCfgPassive<%=chi_idx%>.KeepPermanentSysCoherency = 1;
    m_aiuChiMstCfgPassive<%=chi_idx%>.KeepPermanentLinkActive = 1;
  end else begin
    m_aiuChiMstCfgPassive<%=chi_idx%>.MaxCreditDelayPerChannel = 10;
  end
  
  m_aiuChiMstCfgPassive<%=chi_idx%>.SourceID = <%=e.FUnitId%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.TargetID = <%=e.FUnitId%>;
  m_aiuChiMstCfgPassive<%=chi_idx%>.MiscellaneousID = 9;
  m_aiuChiMstCfgPassive<%=chi_idx%>.CacheAwareRequests = 0;
  m_aiuChiMstCfgPassive<%=chi_idx%>.CacheAwareSnoops = 1;
  m_aiuChiMstCfgPassive<%=chi_idx%>.CacheAwareResponses = 1;
  m_aiuChiMstCfgPassive<%=chi_idx%>.UsingSnoopFilter = 1;
  m_aiuChiMstCfgPassive<%=chi_idx%>.UsingMainMemory = 0;
  m_aiuChiMstCfgPassive<%=chi_idx%>.RandomDownStreamTargetID = 1;
  m_aiuChiMstCfgPassive<%=chi_idx%>.ResetSignalsSimStart = 1;
  m_aiuChiMstCfgPassive<%=chi_idx%>.CheckDownStream = 0;
  m_aiuChiMstCfgPassive<%=chi_idx%>.CheckUpStream = 1;
  m_aiuChiMstCfgPassive<%=chi_idx%>.print();
  //m_aiuChiMstCfgPassive<%=chi_idx%>.addToAddressMapping(0,2**<%=addrwidth%>-1, CDN_CHI_CFG_V8MEMATTR_DEVICE_nGnRnE,1 );
<%       chi_idx++;  %>
<%       } else { %>
 <% for (var mpu_io = 0; mpu_io < e.nNativeInterfacePorts; mpu_io++) { %>
        <%var aiuinfo_idx = obj.IoaiuInfo[cnt].aiuinfo_idx;
	var subio_idx   = obj.IoaiuInfo[cnt].subio_idx;
	var params = obj.AiuInfo[indx].interfaces.axiInt[subio_idx].params;%>
<%    if(e.fnNativeInterface == 'ACE') { %>
  m_aiuMstCfg<%=cnt%> = aceFullUvmUserConfig::type_id::create("m_aiuMstCfg<%=cnt%>");
  m_aiuMstCfg<%=cnt%>.cache_line_size         = <%= Math.pow(2, obj.wCacheLineOffset)%>;
  m_aiuMstCfg<%=cnt%>.write_evict_supported         = 1;
<%  } else if(e.fnNativeInterface == 'ACE5' ) { %>
  m_aiuMstCfg<%=cnt%> = ace5FullUvmUserConfig::type_id::create("m_aiuMstCfg<%=cnt%>");
<%  } else if(e.fnNativeInterface == 'ACELITE-E' ) { %>
  m_aiuMstCfg<%=cnt%> = ace5LiteUvmUserConfig::type_id::create("m_aiuMstCfg<%=cnt%>");
  <% if(params.eAc) {%>
  m_aiuMstCfg<%=cnt%>.pins.cddata.size = <%= Math.pow(2, params.wSnoop)%>;
  <% } %>
<%  } else if(e.fnNativeInterface == 'ACE-LITE' ) { %>
  m_aiuMstCfg<%=cnt%> = aceLiteUvmUserConfig::type_id::create("m_aiuMstCfg<%=cnt%>");
<%  } else if(e.fnNativeInterface == 'AXI4' ) { %>
  m_aiuMstCfg<%=cnt%> = axi4UvmUserConfig::type_id::create("m_aiuMstCfg<%=cnt%>");
<%  } else if( e.fnNativeInterface == 'AXI5' ) { %>
  m_aiuMstCfg<%=cnt%> = axi5UvmUserConfig::type_id::create("m_aiuMstCfg<%=cnt%>");
<%     } %>
  m_aiuMstCfg<%=cnt%>.all_legal_states        = 1;
  m_aiuMstCfg<%=cnt%>.write_issuing_capability = 128;
  m_aiuMstCfg<%=cnt%>.read_issuing_capability = 128;
  m_aiuMstCfg<%=cnt%>.read_acceptance_capability = 20;
  m_aiuMstCfg<%=cnt%>.is_active               = UVM_ACTIVE;
  m_aiuMstCfg<%=cnt%>.PortType                = CDN_AXI_CFG_MASTER;
  m_aiuMstCfg<%=cnt%>.reset_signals_sim_start = 1;
  m_aiuMstCfg<%=cnt%>.addr_width              = <%=params.wAddr%>;
  m_aiuMstCfg<%=cnt%>.id_width                = <%=Math.max(params.wArId,params.wAwId)%>;
  m_aiuMstCfg<%=cnt%>.read_data_width         = <%=params.wData%>;
  m_aiuMstCfg<%=cnt%>.write_data_width        = <%=params.wData%>;
  <%if (params.checkType == 'ODD_PARITY_BYTE_ALL') { %>
  m_aiuMstCfg<%=cnt%>.check_type              = CDN_AXI_CFG_CHECK_TYPE_ODD_PARITY_BYTE_ALL;
  m_aiuMstCfg<%=cnt%>.data_check_supported    = CDN_AXI_CFG_DATA_CHECK_SUPPORTED_ODD_PARITY;
 <%} %>
<%if((e.fnNativeInterface === 'ACE-LITE' || e.fnNativeInterface === 'ACELITE-E' ) && params.eAc) { %>
  m_aiuMstCfg<%=cnt%>.ace_lite_dvm_support = 1;
<%} %>
<%if(e.fnNativeInterface === 'ACELITE-E'  && params.eAtomic >0) { %>
  m_aiuMstCfg<%=cnt%>.atomic_transactions_supported = 1;
<%} %>

<%if(e.fnNativeInterface === 'ACELITE-E'  && params.eStash >0) { %>
  m_aiuMstCfg<%=cnt%>.cache_stash_transactions_supported  = 1;
<%} %>

<%if(e.fnNativeInterface === 'ACE' || e.fnNativeInterface == 'ACE5') { %>
  m_aiuMstCfg<%=cnt%>.snoop_data_width        = <%=params.wCdData%>;
<%} %>
  m_aiuMstCfg<%=cnt%>.verbosity               = CDN_AXI_CFG_MESSAGEVERBOSITY_LOW;
  if($test$plusargs("performance_test"))begin
    m_aiuMstCfg<%=cnt%>.is_bounded_cache_model  = 0 ;
  end else begin
    m_aiuMstCfg<%=cnt%>.is_bounded_cache_model  = 1;
    m_aiuMstCfg<%=cnt%>.bounded_cache_model_size= 5;
  end

  //m_aiuMstCfg<%=cnt%>.addToMemorySegments(0,2**<%=addrwidth%>-1, DENALI_CDN_AXI_DOMAIN_SYSTEM);


  //AgentAiu<%=pidx%> Mst Configuration
<%if(e.fnNativeInterface === 'ACE') { %>
  m_aiuMstCfgPassive<%=cnt%> = aceFullUvmUserConfig::type_id::create("m_aiuMstCfgPassive<%=cnt%>");
  m_aiuMstCfgPassive<%=cnt%>.cache_line_size         = <%= Math.pow(2, obj.wCacheLineOffset)%>;
<%  }     else if(e.fnNativeInterface == 'ACE5' ) { %>
  m_aiuMstCfgPassive<%=cnt%> = ace5FullUvmUserConfig::type_id::create("m_aiuMstCfgPassive<%=cnt%>");
<%  }     else if(e.fnNativeInterface == 'ACELITE-E' ) { %>
  m_aiuMstCfgPassive<%=cnt%> = ace5LiteUvmUserConfig::type_id::create("m_aiuMstCfgPassive<%=cnt%>");
<%  }     else if(e.fnNativeInterface == 'ACE-LITE' ) { %>
  m_aiuMstCfgPassive<%=cnt%> = aceLiteUvmUserConfig::type_id::create("m_aiuMstCfgPassive<%=cnt%>");
<%  }     else if(e.fnNativeInterface == 'AXI4' ) { %>
  m_aiuMstCfgPassive<%=cnt%> = axi4UvmUserConfig::type_id::create("m_aiuMstCfgPassive<%=cnt%>");
<%  }     else if( e.fnNativeInterface == 'AXI5') { %>
  m_aiuMstCfgPassive<%=cnt%> = axi5UvmUserConfig::type_id::create("m_aiuMstCfgPassive<%=cnt%>");
<%        } %>

  m_aiuMstCfgPassive<%=cnt%>.all_legal_states        = 1;
  m_aiuMstCfgPassive<%=cnt%>.write_issuing_capability = 128;
  m_aiuMstCfgPassive<%=cnt%>.read_issuing_capability = 128;
  m_aiuMstCfgPassive<%=cnt%>.read_acceptance_capability = 50;
  m_aiuMstCfgPassive<%=cnt%>.read_data_reordering_depth = 20;
  m_aiuMstCfgPassive<%=cnt%>.is_active               = UVM_PASSIVE;
  m_aiuMstCfgPassive<%=cnt%>.PortType                = CDN_AXI_CFG_SLAVE;
  m_aiuMstCfgPassive<%=cnt%>.reset_signals_sim_start = 1;
  m_aiuMstCfgPassive<%=cnt%>.addr_width              = <%=params.wAddr%>;
  m_aiuMstCfgPassive<%=cnt%>.id_width                = <%=Math.max(params.wArId,params.wAwId)%>;
  m_aiuMstCfgPassive<%=cnt%>.read_data_width         = <%=params.wData%>;
  m_aiuMstCfgPassive<%=cnt%>.write_data_width        = <%=params.wData%>;
<%if((e.fnNativeInterface === 'ACE-LITE' || e.fnNativeInterface === 'ACELITE-E' ) && params.eAc) { %>
  m_aiuMstCfgPassive<%=cnt%>.ace_lite_dvm_support = 1;
<%} %>
<%if(e.fnNativeInterface === 'ACELITE-E'  && params.eAtomic >0) { %>
  m_aiuMstCfgPassive<%=cnt%>.atomic_transactions_supported = 1;
<%} %>

<%if(e.fnNativeInterface === 'ACELITE-E'  && params.eStash >0) { %>
  m_aiuMstCfgPassive<%=cnt%>.cache_stash_transactions_supported  = 1;
<%} %>
<%if(e.fnNativeInterface === 'ACE' || e.fnNativeInterface == 'ACE5') { %>
  m_aiuMstCfgPassive<%=cnt%>.snoop_data_width        = <%=params.wCdData%>;
<%} %>
  m_aiuMstCfgPassive<%=cnt%>.verbosity               = CDN_AXI_CFG_MESSAGEVERBOSITY_LOW;
  if($test$plusargs("performance_test"))begin
    m_aiuMstCfgPassive<%=cnt%>.is_bounded_cache_model  = 0;
  end else begin
    m_aiuMstCfgPassive<%=cnt%>.is_bounded_cache_model  = 1;
    m_aiuMstCfgPassive<%=cnt%>.bounded_cache_model_size= 5;
  end 
  m_aiuMstCfgPassive<%=cnt%>.snoop_issuing_capability  = 50;

  m_aiuMstCfgPassive<%=cnt%>.addToMemorySegments(0,2**<%=addrwidth%>-1, DENALI_CDN_AXI_DOMAIN_SYSTEM);
<% cnt++  }} %>
<%  }); %>


<%
obj.DmiInfo.forEach(function(e, pidx, array) {
%>
<%       var addrwidth = e.wAddr; %>
  m_dmiSlvCfg<%=pidx%>   = axiSlaveUvmUserConfig::type_id::create("m_dmiSlvCfg<%=pidx%>");

  m_dmiSlvCfg<%=pidx%>.is_active               = UVM_ACTIVE;
  m_dmiSlvCfg<%=pidx%>.read_acceptance_capability = 1;
  m_dmiSlvCfg<%=pidx%>.PortType                = CDN_AXI_CFG_SLAVE;
  m_dmiSlvCfg<%=pidx%>.cache_line_size         = <%= Math.pow(2, obj.wCacheLineOffset)%>;
  m_dmiSlvCfg<%=pidx%>.reset_signals_sim_start = 1;
  m_dmiSlvCfg<%=pidx%>.addr_width              = <%=e.interfaces.axiInt.params.wAddr%>;
  m_dmiSlvCfg<%=pidx%>.id_width                = <%=Math.max(e.interfaces.axiInt.params.wArId,e.interfaces.axiInt.params.wAwId)%>;
  m_dmiSlvCfg<%=pidx%>.read_data_width         = <%=e.interfaces.axiInt.params.wData%>;
  m_dmiSlvCfg<%=pidx%>.write_data_width        = <%=e.interfaces.axiInt.params.wData%>;
  m_dmiSlvCfg<%=pidx%>.verbosity               = CDN_AXI_CFG_MESSAGEVERBOSITY_LOW;

  m_dmiSlvCfg<%=pidx%>.addToMemorySegments(0,2**<%=addrwidth%>-1, DENALI_CDN_AXI_DOMAIN_SYSTEM);


  m_dmiSlvCfgPassive<%=pidx%>   = axiSlaveUvmUserConfig::type_id::create("m_dmiSlvCfgPassive<%=pidx%>");

  m_dmiSlvCfgPassive<%=pidx%>.is_active               = UVM_PASSIVE;
  m_dmiSlvCfgPassive<%=pidx%>.read_acceptance_capability = 1;
  m_dmiSlvCfgPassive<%=pidx%>.PortType                = CDN_AXI_CFG_MASTER;
  m_dmiSlvCfgPassive<%=pidx%>.cache_line_size         = <%= Math.pow(2, obj.wCacheLineOffset)%>;
  m_dmiSlvCfgPassive<%=pidx%>.reset_signals_sim_start = 1;
  m_dmiSlvCfgPassive<%=pidx%>.addr_width              = <%=e.interfaces.axiInt.params.wAddr%>;
  m_dmiSlvCfgPassive<%=pidx%>.id_width                = <%=Math.max(e.interfaces.axiInt.params.wArId,e.interfaces.axiInt.params.wAwId)%>;
  m_dmiSlvCfgPassive<%=pidx%>.read_data_width         = <%=e.interfaces.axiInt.params.wData%>;
  m_dmiSlvCfgPassive<%=pidx%>.write_data_width        = <%=e.interfaces.axiInt.params.wData%>;
  m_dmiSlvCfgPassive<%=pidx%>.verbosity               = CDN_AXI_CFG_MESSAGEVERBOSITY_LOW;

  m_dmiSlvCfgPassive<%=pidx%>.addToMemorySegments(0,2**<%=addrwidth%>-1, DENALI_CDN_AXI_DOMAIN_SYSTEM);

<% }); %>

<%
var pidx = 0;
obj.DiiInfo.forEach(function(e, i, array) {
%>
<%  if (e.configuration == 0) {   %>	
<%   var addrwidth = e.wAddr; %>
  m_diiSlvCfg<%=pidx%>   = axiSlaveUvmUserConfig::type_id::create("m_diiSlvCfg<%=pidx%>");

  m_diiSlvCfg<%=pidx%>.is_active               = UVM_ACTIVE;
  m_diiSlvCfg<%=pidx%>.read_acceptance_capability = 1;
  m_diiSlvCfg<%=pidx%>.PortType                = CDN_AXI_CFG_SLAVE;
  m_diiSlvCfg<%=pidx%>.cache_line_size         = <%= Math.pow(2, obj.wCacheLineOffset)%>;
  m_diiSlvCfg<%=pidx%>.reset_signals_sim_start = 1;
  m_diiSlvCfg<%=pidx%>.addr_width              = <%=e.interfaces.axiInt.params.wAddr%>;
  m_diiSlvCfg<%=pidx%>.id_width                = <%=Math.max(e.interfaces.axiInt.params.wArId,e.interfaces.axiInt.params.wAwId)%>;
  m_diiSlvCfg<%=pidx%>.read_data_width         = <%=e.interfaces.axiInt.params.wData%>;
  m_diiSlvCfg<%=pidx%>.write_data_width        = <%=e.interfaces.axiInt.params.wData%>;
  m_diiSlvCfg<%=pidx%>.verbosity               = CDN_AXI_CFG_MESSAGEVERBOSITY_LOW;

  m_diiSlvCfg<%=pidx%>.addToMemorySegments(0,2**<%=addrwidth%>-1, DENALI_CDN_AXI_DOMAIN_SYSTEM);


  m_diiSlvCfgPassive<%=pidx%>   = axiSlaveUvmUserConfig::type_id::create("m_diiSlvCfgPassive<%=pidx%>");

  m_diiSlvCfgPassive<%=pidx%>.is_active               = UVM_PASSIVE;
  m_diiSlvCfgPassive<%=pidx%>.read_acceptance_capability = 1;
  m_diiSlvCfgPassive<%=pidx%>.PortType                = CDN_AXI_CFG_MASTER;
  m_diiSlvCfgPassive<%=pidx%>.cache_line_size         = <%= Math.pow(2, obj.wCacheLineOffset)%>;
  m_diiSlvCfgPassive<%=pidx%>.reset_signals_sim_start = 1;
  m_diiSlvCfgPassive<%=pidx%>.addr_width              = <%=addrwidth%>;
  m_diiSlvCfgPassive<%=pidx%>.id_width                = <%=Math.max(e.interfaces.axiInt.params.wArId,e.interfaces.axiInt.params.wAwId)%>;
  m_diiSlvCfgPassive<%=pidx%>.read_data_width         = <%=e.interfaces.axiInt.params.wData%>;
  m_diiSlvCfgPassive<%=pidx%>.write_data_width        = <%=e.interfaces.axiInt.params.wData%>;
  m_diiSlvCfgPassive<%=pidx%>.verbosity               = CDN_AXI_CFG_MESSAGEVERBOSITY_LOW;

  m_diiSlvCfgPassive<%=pidx%>.addToMemorySegments(0,2**<%=addrwidth%>-1, DENALI_CDN_AXI_DOMAIN_SYSTEM);
<% pidx++ } %>

<% });%>
<%if(obj.useResiliency == 1){%>
  m_fscMstCfg = cdnApbUvmConfig::type_id::create("m_fscMstCfg");
  m_fscMstCfg.is_active = UVM_ACTIVE;
  m_fscMstCfg.data_width = <%=obj.FscInfo.interfaces.apbInterface.params.wData%>;
  m_fscMstCfg.addr_width = <%=obj.FscInfo.interfaces.apbInterface.params.wAddr%>;
  m_fscMstCfg.DeviceType = CDN_APB_CFG_MASTER;
  m_fscMstCfg.number_of_slaves = <%=obj.FscInfo.interfaces.apbInterface.params.wPsel%>;
  m_fscMstCfg.reset_signals_sim_start = 1;
  m_fscMstCfg.verbosity = CDN_APB_CFG_MESSAGEVERBOSITY_LOW;
  m_fscMstCfg.use_apb_amba3_extension = 1;
  m_fscMstCfg.use_apb_amba4_extension = 1;
  m_fscMstCfg.use_apb_ver_e_extension = 1;
  m_fscMstCfg.timings.ttxHCLKToSigValid.set(1, CDN_VIP_PS, 1);
  m_fscMstCfg.check_prdata_for_x_and_z = 1;
  for (int ii=0; ii<<%=obj.FscInfo.interfaces.apbInterface.params.wPsel%>; ii++) begin
    m_fscMstCfg.addToAddressSegments(0,2**<%=obj.FscInfo.interfaces.apbInterface.params.wAddr%>-1, ii);
  end
		
  m_fscMstCfgPassive= cdnApbUvmConfig::type_id::create("m_fscMstCfgPassive");
  m_fscMstCfgPassive.is_active = UVM_PASSIVE;
  m_fscMstCfgPassive.data_width = <%=obj.FscInfo.interfaces.apbInterface.params.wData%>;
  m_fscMstCfgPassive.addr_width = <%=obj.FscInfo.interfaces.apbInterface.params.wAddr%>;
  m_fscMstCfgPassive.DeviceType = CDN_APB_CFG_MASTER;
  m_fscMstCfgPassive.number_of_slaves = <%=obj.FscInfo.interfaces.apbInterface.params.wPsel%>;
  m_fscMstCfgPassive.verbosity = CDN_APB_CFG_MESSAGEVERBOSITY_LOW;
  m_fscMstCfgPassive.use_apb_amba3_extension = 1;
  m_fscMstCfgPassive.use_apb_amba4_extension = 1;
  m_fscMstCfgPassive.use_apb_ver_e_extension = 1;
  m_fscMstCfgPassive.timings.ttxHCLKToSigValid.set(1, CDN_VIP_PS, 1);
  m_fscMstCfgPassive.check_prdata_for_x_and_z = 1;
  for (int ii=0; ii<<%=obj.FscInfo.interfaces.apbInterface.params.wPsel%>; ii++) begin
    m_fscMstCfgPassive.addToAddressSegments(0,2**<%=obj.FscInfo.interfaces.apbInterface.params.wAddr%>-1, ii);
  end
<% } %>
<%if(obj.DebugApbInfo.length>0){%>
  m_apb_dbg_MstCfg = cdnApbUvmConfig::type_id::create("m_apb_dbg_MstCfg");
  m_apb_dbg_MstCfg.is_active = UVM_ACTIVE;
  m_apb_dbg_MstCfg.data_width = <%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wData%>;
  m_apb_dbg_MstCfg.addr_width = <%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wAddr%>;
  m_apb_dbg_MstCfg.number_of_slaves = <%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wPsel%>;
  m_apb_dbg_MstCfg.DeviceType = CDN_APB_CFG_MASTER;
  m_apb_dbg_MstCfg.reset_signals_sim_start = 1;
  m_apb_dbg_MstCfg.verbosity = CDN_APB_CFG_MESSAGEVERBOSITY_LOW;
  m_apb_dbg_MstCfg.timings.ttxHCLKToSigValid.set(1, CDN_VIP_PS, 1);
  m_apb_dbg_MstCfg.check_prdata_for_x_and_z = 1;
  m_apb_dbg_MstCfg.use_apb_amba3_extension = 1;
  m_apb_dbg_MstCfg.use_apb_amba4_extension = 1;
  m_apb_dbg_MstCfg.use_apb_ver_e_extension = 1;
 // m_apb_dbg_MstCfg.transfer_timeout = 100000;
 // m_apb_dbg_MstCfg.set_transfer_timeout(100000);
  for (int ii=0; ii<<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wPsel%>; ii++) begin
    m_apb_dbg_MstCfg.addToAddressSegments(0,2**<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wAddr%>-1, ii);
  end
		
  m_apb_dbg_MstCfgPassive= cdnApbUvmConfig::type_id::create("m_apb_dbg_MstCfgPassive");
  m_apb_dbg_MstCfgPassive.is_active = UVM_PASSIVE;
  m_apb_dbg_MstCfgPassive.data_width = <%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wData%>;
  m_apb_dbg_MstCfgPassive.addr_width = <%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wAddr%>;
  m_apb_dbg_MstCfgPassive.number_of_slaves = <%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wPsel%>;
  m_apb_dbg_MstCfgPassive.DeviceType = CDN_APB_CFG_MASTER;
  m_apb_dbg_MstCfgPassive.verbosity = CDN_APB_CFG_MESSAGEVERBOSITY_LOW;
  m_apb_dbg_MstCfgPassive.timings.ttxHCLKToSigValid.set(1, CDN_VIP_PS, 1);
  m_apb_dbg_MstCfgPassive.check_prdata_for_x_and_z = 1;
  m_apb_dbg_MstCfgPassive.use_apb_amba3_extension = 1;
  m_apb_dbg_MstCfgPassive.use_apb_amba4_extension = 1;
  m_apb_dbg_MstCfgPassive.use_apb_ver_e_extension = 1;
 // m_apb_dbg_MstCfgPassive.transfer_timeout = 100000;
 // m_apb_dbg_MstCfgPassive.set_transfer_timeout(100000);
  for (int ii=0; ii<<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wPsel%>; ii++) begin
    m_apb_dbg_MstCfgPassive.addToAddressSegments(0,2**<%=obj.DebugApbInfo[0].interfaces.apbInterface.params.wAddr%>-1, ii);
  end
<% } %>

endfunction
`endif // GUARD_NCORE_SYSTEM_CONFIGURATION_SV

