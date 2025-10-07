<% var has_secded = 0;
var ioaiu_id=0;
var hit_ioaiu=0;
var has_secded_ott = 0;
obj.AiuInfo.forEach(function findId(item,index){
   if((item.fnNativeInterface != "CHI-A" )&&(item.fnNativeInterface != "CHI-B" )){
      if (hit_ioaiu == 0) {
        ioaiu_id = index;
        hit_ioaiu = 1;
      }
   }
});

if (obj.assertOn) {
if (obj.DutInfo.useCache) {
if ((obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED") || (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED") || (obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") || (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) {
    has_secded = 1;
    console.log("has_secded: "+has_secded);
   }
 }
if ((obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) {
    has_secded_ott = 1;
   
    console.log("has_secded_ott: "+has_secded_ott);
   }
}
if(obj.DutInfo.useCache){
    // CCP Tag and Data Array width
    var wDataNoProt = obj.DutInfo.ccpParams.wData + 1 ; // 1bit of poison
    var wTagNoProt  = obj.DutInfo.ccpParams.wAddr - obj.DutInfo.ccpParams.PriSubDiagAddrBits.length - obj.DutInfo.ccpParams.wCacheLineOffset + obj.DutInfo.ccpParams.wSecurity // TagWidth
                    + obj.DutInfo.ccpParams.wStateBits // State
                     // Only add when replacement policy is NRU
                    + (((obj.DutInfo.ccpParams.nWays > 1) && (obj.DutInfo.ccpParams.RepPolicy !== 'RANDOM') && (obj.DutInfo.ccpParams.nRPPorts === 1)) ? 1 : 0);
    var wDataArrayEntry = wDataNoProt + (obj.DutInfo.ccpParams.DataErrInfo == "PARITYENTRY" ? 1 : (obj.DutInfo.ccpParams.DataErrInfo == "SECDED" ? (Math.ceil(Math.log2(wDataNoProt + Math.ceil(Math.log2(wDataNoProt)) + 1)) + 1):0));
    var wTagArrayEntry = wTagNoProt + (obj.DutInfo.ccpParams.TagErrInfo == "PARITYENTRY" ? 1 : (obj.DutInfo.ccpParams.TagErrInfo == "SECDED" ? (Math.ceil(Math.log2(wTagNoProt + Math.ceil(Math.log2(wTagNoProt)) + 1)) + 1):0));
}
let computedAxiInt;
if(Array.isArray(obj.DutInfo.interfaces.axiInt)){
    computedAxiInt = obj.DutInfo.interfaces.axiInt[0];
    console.log(JSON.stringify(computedAxiInt));
}else{
    computedAxiInt = obj.DutInfo.interfaces.axiInt;
}

var nSetsPerCore = obj.DutInfo.ccpParams.nSets/obj.DutInfo.nNativeInterfacePorts;
%>

<%function generateRegPath(regName) {
    if(obj.DutInfo.nNativeInterfacePorts > 1) {
        return 'm_regs.'+obj.DutInfo.strRtlNamePrefix+'_'+regName;
    } else {
        var hold = regName.split('.');
        hold.shift();
        regName = hold.join('.');
        return 'm_regs.'+obj.DutInfo.strRtlNamePrefix+'.'+regName;
    }
}%>

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//  Task    : ioaiu_csr_id_reset_seq
//  Purpose : test unit ids against json, rather than cpr
//
//-----------------------------------------------------------------------
class ioaiu_csr_id_reset_seq_<%=obj.multiPortCoreId%> extends ral_csr_base_seq; 
   `uvm_object_utils(ioaiu_csr_id_reset_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t read_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
       read_data = 'hDEADBEEF ;  //bogus sentinel

       poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTAR.TransActv')%>,1,read_data);
       do begin
         read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTAR.TransActv')%>, read_data);
       end while (read_data != 0);

       read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUIDR.RPN')%>, read_data);
       compareValues("XAIUIDR_RPN", "should be <%=obj.AiuInfo[ioaiu_id].rpn%> (json)", read_data, <%=obj.AiuInfo[ioaiu_id].rpn%>);  //TODO FIXME meaningful values from json
       read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUIDR.NRRI')%>, read_data);
       compareValues("XAIUIDR_NRRI", "should be <%=obj.AiuInfo[ioaiu_id].nrri%> (json)", read_data, <%=obj.AiuInfo[ioaiu_id].nrri%>);  //TODO FIXME meaningful values from json
       read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUIDR.NUnitId')%>, read_data);
       //compareValues("XAIUIDR_NUnitId", "should be 0 (json)", read_data, <%=obj.DutInfo.FUnitId%>);
       compareValues("XAIUIDR_NUnitId", "should be <%=obj.AiuInfo[ioaiu_id].nUnitId%> (json)", read_data, <%=obj.AiuInfo[ioaiu_id].nUnitId%>);
       read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUIDR.Valid')%>, read_data);
       compareValues("XAIUIDR_Valid", "should always be 1", read_data, 1);  
       read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUFUIDR.FUnitId')%>, read_data);
       compareValues("XAIUIDR_FUnitId", "should be <%=obj.AiuInfo[ioaiu_id].FUnitId%> (json)", read_data, <%=obj.AiuInfo[ioaiu_id].FUnitId%>);
    endtask
endclass : ioaiu_csr_id_reset_seq_<%=obj.multiPortCoreId%>

//-----------------------------------------------------------------------
//   base method for chi_aiu 
//-----------------------------------------------------------------------
class io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%> extends ral_csr_base_seq;

    virtual <%=obj.BlockId%>_probe_if u_csr_probe_vif;
    <%for (var i = 0; i <  obj.DutInfo.nSmiRx; i++) { %>
        virtual <%=obj.BlockId%>_smi_if   m_smi<%=i%>_tx_vif;
    <%}%>
    ioaiu_env env;
    ioaiu_multiport_env mp_env;
    ioaiu_env_config m_env_cfg[<%=obj.DutInfo.nNativeInterfacePorts%>];

    virtual <%=obj.BlockId%>_apb_if  apb_vif;
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_<%=obj.multiPortCoreId%> = ev_pool.get("ev_<%=obj.multiPortCoreId%>");
    uvm_event ev_sysco_fsm_state_change = ev_pool.get("ev_sysco_fsm_state_change_<%=obj.DutInfo.FUnitId%>");
    uvm_event ev_agent_is_attached 		  = ev_pool.get("ev_agent_is_attached_<%=obj.DutInfo.FUnitId%>");
    uvm_event ev_agent_is_detached 		  = ev_pool.get("ev_agent_is_detached_<%=obj.DutInfo.FUnitId%>");
    uvm_event ev_agent_is_attach_error	= ev_pool.get("ev_agent_is_attach_error_<%=obj.DutInfo.FUnitId%>");
    uvm_event ev_agent_is_detach_error  = ev_pool.get("ev_agent_is_detach_error_<%=obj.DutInfo.FUnitId%>");
    uvm_event ev_sysco_all_sys_rsp_received = ev_pool.get("ev_sysco_all_sys_rsp_received_<%=obj.DutInfo.FUnitId%>");
    uvm_event ev_sysco_protocol_timeout     = ev_pool.get("ev_sysco_protocol_timeout_<%=obj.DutInfo.FUnitId%>");

    uvm_event ev_always_inject_error_<%=obj.multiPortCoreId%> = ev_pool.get("ev_always_inject_error_<%=obj.multiPortCoreId%>");
    uvm_event ev_wait_for_inject_error_<%=obj.multiPortCoreId%> = ev_pool.get("ev_wait_for_inject_error_<%=obj.multiPortCoreId%>");

    uvm_event ev_snoop_rsp_err = ev_pool.get("ev_snoop_rsp_err");
    uvm_event ev_snoop_rsp_err_dvm = ev_pool.get("ev_snoop_rsp_err_dvm");
    uvm_event ev_csr_test_time_out_CMDrsp_STRreq_Evict<%=obj.multiPortCoreId%> = ev_pool.get("ev_csr_test_time_out_CMDrsp_STRreq_Evict<%=obj.multiPortCoreId%>");
    uvm_event ev_ar_req_<%=obj.multiPortCoreId%> = ev_pool.get("ev_ar_req_<%=obj.multiPortCoreId%>");
    uvm_event ev_aw_req_<%=obj.multiPortCoreId%> = ev_pool.get("ev_aw_req_<%=obj.multiPortCoreId%>");
    <%if (obj.assertOn) { %>
        <%for( var i= ((obj.multiPortCoreId)*(obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks)) ;i<(obj.multiPortCoreId + 1)*(obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks);i++){%>
            uvm_event         injectSingleErrOtt<%=i%>;
            uvm_event         injectDoubleErrOtt<%=i%>;
            uvm_event         inject_multi_block_single_double_ErrOtt<%=i%>;
            uvm_event         inject_multi_block_double_ErrOtt<%=i%>;
            uvm_event         inject_multi_block_single_ErrOtt<%=i%>;
            uvm_event 	      injectAddrErrOtt<%=i%>;

        <%}%>
             <%for( var i= ((obj.multiPortCoreId) * obj.AiuInfo[obj.Id].ccpParams.nRPPorts);i<= ( (obj.multiPortCoreId + 1) * obj.AiuInfo[obj.Id].ccpParams.nRPPorts);i++){%>
            uvm_event         injectSingleErrplru<%=i%>;
            uvm_event         injectDoubleErrplru<%=i%>;
            uvm_event         injectAddrErrplru<%=i%>;
        <%}%>
        <%if (obj.AiuInfo[obj.Id].useCache) { %>
             <%for( var i= ((obj.multiPortCoreId) * obj.AiuInfo[obj.Id].ccpParams.nTagBanks);i< ( (obj.multiPortCoreId + 1) * obj.AiuInfo[obj.Id].ccpParams.nTagBanks);i++){%>
                uvm_event         injectSingleErrTag<%=i%>;
                uvm_event         injectDoubleErrTag<%=i%>;
                uvm_event         inject_multi_block_single_double_ErrTag<%=i%>;
                uvm_event         inject_multi_block_double_ErrTag<%=i%>;
                uvm_event         inject_multi_block_single_ErrTag<%=i%>;
                uvm_event         injectAddrErrTag<%=i%>;

            <%}%>
            <%for( var i=0;i<((obj.multiPortCoreId + 1) * (obj.AiuInfo[obj.Id].ccpParams.nDataBanks));i++){%>
                uvm_event         injectSingleErrData<%=i%>;
                uvm_event         injectDoubleErrData<%=i%>;
                uvm_event         inject_multi_block_single_double_ErrData<%=i%>;
                uvm_event         inject_multi_block_double_ErrData<%=i%>;
                uvm_event         inject_multi_block_single_ErrData<%=i%>;
		uvm_event 	  injectAddrErrData<%=i%>;
            <%}%>
        <%}%>
    <%}%>
    int ott_way;

    <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
            ioaiu_coverage                          cov;
        `endif
    <%}%>
    
    function new(string name="");
        super.new(name);
        <% if(obj.COVER_ON) { %>
           `ifndef FSYS_COVER_ON
            cov = new();
        	`endif
        <% } %>
    endfunction

    function void getSMIIf();
        <% var smi_portid_cmdrsp =0;
        var smi_portid_updrsp =0;
        var smi_portid_dtwrsp =0;
        var smi_portid_cmprsp =0;
        var smi_portid_dtwdbgrsp =0;
        var smi_portid_dtrrsp =0;
        var smi_portid_dtrreq =0;
        var smi_portid_strreq =0;
        var smi_portid_snpreq =0;
        var smi_portid_sysrsp =0;
        var smi_portid_sysreq =0;
        obj.AiuInfo[ioaiu_id].smiPortParams.rx.forEach(function find_port_id(port,index){
	        var item = port.params;
            if(item.fnMsgClass.indexOf('cmd_rsp_') != -1) {
                smi_portid_cmdrsp = index;
                console.log("smi_portid_cmdrsp is = "+ index ) ;
            }
                if(item.fnMsgClass.indexOf('upd_rsp_') != -1) {
                smi_portid_updrsp = index;
                console.log("smi_portid_updrsp is = "+ index ) ;
            }
            if(item.fnMsgClass.indexOf('dtw_rsp_') != -1) {
                smi_portid_dtwrsp = index;
                console.log("smi_portid_dtwrsp is = "+ index ) ;
            }
            if(item.fnMsgClass.indexOf('cmp_rsp_') != -1) {
                smi_portid_cmprsp = index;
                console.log("smi_portid_cmprsp is = "+ index ) ;
            }
            if(item.fnMsgClass.indexOf('dtr_rsp_rx_') != -1) {
                smi_portid_dtrrsp = index;
                console.log("smi_portid_dtrrsp is = "+ index ) ;
            }
            if(item.fnMsgClass.indexOf('dtr_req_rx_') != -1) {
                smi_portid_dtrreq = index;
                console.log("smi_portid_dtrreq is = "+ index ) ;
            }
            if(item.fnMsgClass.indexOf('str_req_') != -1) {
                smi_portid_strreq = index;
                console.log("smi_portid_strreq is = "+ index ) ;
            }
            if(item.fnMsgClass.indexOf('snp_req_') != -1) {
                smi_portid_snpreq = index;
                console.log("smi_portid_snpreq is = "+ index ) ;
            }
            if(item.fnMsgClass.indexOf('sys_rsp_rx_') != -1) {
                smi_portid_sysrsp = index;
                console.log("smi_portid_sysrsp is = "+ index ) ;
            }
            if(item.fnMsgClass.indexOf('sys_req_rx_') != -1) {
                smi_portid_sysreq = index;
                console.log("smi_portid_sysreq is = "+ index ) ;
            }
            if(item.fnMsgClass.indexOf('dtw_dbg_rsp_') != -1) {
                smi_portid_dtwdbgrsp = index;
                console.log(" is = "+ index ) ;
            }
        });%>
        <% for (var i = 0; i < obj.DutInfo.nSmiRx; i++) { %>
            if (!uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::get(
                .cntxt(null),
                .inst_name(get_full_name()),
                .field_name("m_smi<%=i%>_tx_port_if"),
                .value(m_smi<%=i%>_tx_vif))) begin

                `uvm_fatal(get_name(), "unable to find m_smi<%=i%>_tx_vif")
            end
        <%}%>
    endfunction

    function getCsrProbeIf();
        if(!uvm_config_db#(virtual <%=obj.BlockId%>_probe_if )::get(null, get_full_name(), "u_csr_probe_if<%=obj.multiPortCoreId%>",u_csr_probe_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    endfunction // checkCsrProbeIf

    function get_env_handle();
        if(!uvm_config_db#(ioaiu_env)::get(null, get_full_name(), "env_handle",env))
            `uvm_fatal(get_full_name(),"Could not find env handle")
    endfunction 

    function get_mp_env_handle();
      if(!uvm_config_db#(ioaiu_multiport_env)::get(uvm_root::get(), "", "mp_env",mp_env))
          `uvm_fatal(get_full_name(),"Could not find mp_env handle")
    endfunction 

    function get_m_env_cfg_handle();
      if(!uvm_config_db#(ioaiu_env_config)::get(uvm_root::get(),"uvm_test_top.mp_env.m_env[<%=obj.multiPortCoreId%>]", "ioaiu_env_config",m_env_cfg[<%=obj.multiPortCoreId%>]))
          `uvm_fatal(get_full_name(),"Could not find m_env_cfg handle")
    endfunction 

    function getInjectErrEvent();
<% if (obj.assertOn) { %>
     <%for( var i= ((obj.multiPortCoreId)*(obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks)) ;i<(obj.multiPortCoreId + 1)*(obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks);i++){%>   
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectSingleErrOtt<%=i%>"),
                                          .value(injectSingleErrOtt<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for single error ott")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectDoubleErrOtt<%=i%>"),
                                          .value(injectDoubleErrOtt<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for double error ott")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_double_ErrOtt<%=i%>"),
                                          .value(inject_multi_block_single_double_ErrOtt<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block single double error ott")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_double_ErrOtt<%=i%>"),
                                          .value(inject_multi_block_double_ErrOtt<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block double error ott")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_ErrOtt<%=i%>"),
                                          .value(inject_multi_block_single_ErrOtt<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block single error ott")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectAddrErrOtt<%=i%>"),
                                          .value(injectAddrErrOtt<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for address error ott")
      <% } %>
       <%for( var i= ((obj.multiPortCoreId) * obj.AiuInfo[obj.Id].ccpParams.nRPPorts);i<= ( (obj.multiPortCoreId + 1) * obj.AiuInfo[obj.Id].ccpParams.nRPPorts);i++){%>
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectSingleErrplru<%=i%>"),
                                          .value(injectSingleErrplru<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for single error plru")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectDoubleErrplru<%=i%>"),
                                          .value(injectDoubleErrplru<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for double error plru")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectAddrErrplru<%=i%>"),
                                          .value(injectAddrErrplru<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for address error plru")

      <% } %>

 
<%if (obj.AiuInfo[obj.Id].useCache) { %>
       <%for( var i= ((obj.multiPortCoreId) * obj.AiuInfo[obj.Id].ccpParams.nTagBanks);i< ( (obj.multiPortCoreId + 1) * obj.AiuInfo[obj.Id].ccpParams.nTagBanks);i++){%>
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectSingleErrTag<%=i%>"),
                                          .value(injectSingleErrTag<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for single error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectDoubleErrTag<%=i%>"),
                                          .value(injectDoubleErrTag<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for double error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_double_ErrTag<%=i%>"),
                                          .value(inject_multi_block_single_double_ErrTag<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block single double error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_double_ErrTag<%=i%>"),
                                          .value(inject_multi_block_double_ErrTag<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block double error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_ErrTag<%=i%>"),
                                          .value(inject_multi_block_single_ErrTag<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block single error tag")
         if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectAddrErrTag<%=i%>"),
                                          .value(injectAddrErrTag<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for address error tag")

      <% } %>
      <%for( var i=0;i<((obj.multiPortCoreId + 1) * (obj.AiuInfo[obj.Id].ccpParams.nDataBanks));i++){%>
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectSingleErrData<%=i%>"),
                                          .value(injectSingleErrData<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for single error data")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectDoubleErrData<%=i%>"),
                                          .value(injectDoubleErrData<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for double error data")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_double_ErrData<%=i%>"),
                                          .value(inject_multi_block_single_double_ErrData<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block single double error data")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_double_ErrData<%=i%>"),
                                          .value(inject_multi_block_double_ErrData<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block double error data")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_ErrData<%=i%>"),
                                          .value(inject_multi_block_single_ErrData<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block single error data")
       if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectAddrErrData<%=i%>"),
                                          .value(injectAddrErrData<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for address error data")

      <% } %>
<% } %>
<% } %>
    endfunction
   
task inject_error(input int error_threshold = 1, input int delay_btwn_err_inj = 1, input bit serial_err_inj = 0, output int ott_no);
          int i,j,k,l;
          bit[<%=Math.log2(obj.AiuInfo[obj.Id].ccpParams.nDataBanks)%>-1:0]             sel_bank;
          bit[<%=(Math.log2((obj.DutInfo.nNativeInterfacePorts) * obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks))%>-1:0] sel_ott_bank;
          semaphore sema_ott=new(1);
          semaphore sema_tag=new(1);
          semaphore sema_data=new(1);
          semaphore sema_plru=new(1);
<% if (obj.assertOn) { %>
      <%if(obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") {%>

       <%for( var i= ((obj.multiPortCoreId)*(obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks)) ;i<(obj.multiPortCoreId + 1)*(obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks);i++){%>
          int no_of_sngl_bit_ott_err_injected_bank_<%=i%>;
          int no_of_dbl_bit_ott_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_sngl_dbl_bit_ott_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_dbl_bit_ott_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_sngl_bit_ott_err_injected_bank_<%=i%>;
        <% } %>
      <% } %>
  
        <%if(obj.AiuInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
        <%for( var i= ((obj.multiPortCoreId) * obj.AiuInfo[obj.Id].ccpParams.nRPPorts);i<= ( (obj.multiPortCoreId + 1) * obj.AiuInfo[obj.Id].ccpParams.nRPPorts);i++){%>
          int no_of_sngl_bit_plru_err_injected_bank_<%=i%>;
          int no_of_dbl_bit_plru_err_injected_bank_<%=i%>;
        <% } %>
      <% } %>


<%if (obj.AiuInfo[obj.Id].useCache) { %>
      <%if(obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") {%>
        <%for( var i= ((obj.multiPortCoreId) * obj.AiuInfo[obj.Id].ccpParams.nTagBanks);i< ( (obj.multiPortCoreId + 1) * obj.AiuInfo[obj.Id].ccpParams.nTagBanks);i++){%>
          int no_of_sngl_bit_tag_err_injected_bank_<%=i%>;
          int no_of_dbl_bit_tag_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_sngl_dbl_bit_tag_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_dbl_bit_tag_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_sngl_bit_tag_err_injected_bank_<%=i%>;
        <% } %>
      <% } %>
      <%if(obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY") {%>
        <%for( var i=0;i<((obj.multiPortCoreId + 1) * (obj.AiuInfo[obj.Id].ccpParams.nDataBanks));i++){%>
          int no_of_sngl_bit_data_err_injected_bank_<%=i%>;
          int no_of_dbl_bit_data_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_sngl_dbl_bit_data_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_dbl_bit_data_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_sngl_bit_data_err_injected_bank_<%=i%>;
        <% } %>
      <% } %>
<% } %>
<% } %>
      `uvm_info("INJECT_ERROR",$sformatf("error_threshold = %0h",error_threshold),UVM_NONE)
       if (!uvm_config_db#(int)::get(null, "<%=obj.DutInfo.strRtlNamePrefix%>_env", "sel_bank",sel_bank)) begin
            sel_bank = 0; 
       end

	if (uvm_config_db#(int)::get(null, "<%=obj.DutInfo.strRtlNamePrefix%>_env", "sel_ott_bank",sel_ott_bank)) begin
		
	end
        fork
<% if (obj.assertOn) { %>
        <%if(obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") {%>
          <%for( var i= ((obj.multiPortCoreId)*(obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks)) ;i<(obj.multiPortCoreId + 1)*(obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks);i++){%>
          if(((sel_ott_bank + <%=((obj.multiPortCoreId)*(obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks))%>) == <%=i%>) || $test$plusargs("always_inject_corr_error")) begin
          do begin
            if (!$test$plusargs("always_inject_corr_error")) begin
            sema_ott.get(1);
            end
            if (i < error_threshold) begin
              if (!serial_err_inj) begin
                i++;
                sema_ott.put(1);
              end
              if ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("always_inject_corr_error")) begin
                injectSingleErrOtt<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_ott_single_next<%=i%>);
                no_of_sngl_bit_ott_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("ccp_double_bit_direct_ott_error_test")) begin
                injectDoubleErrOtt<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_ott_double_next<%=i%>); 
                no_of_dbl_bit_ott_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test")) begin
                inject_multi_block_single_double_ErrOtt<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_ott_single_double_multi_blk_next<%=i%>); 
                no_of_mlt_blk_sngl_dbl_bit_ott_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("ccp_multi_blk_double_ott_direct_error_test")) begin
                inject_multi_block_double_ErrOtt<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_ott_double_multi_blk_next<%=i%>); 
                no_of_mlt_blk_dbl_bit_ott_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("ccp_multi_blk_single_ott_direct_error_test")) begin
                inject_multi_block_single_ErrOtt<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_ott_single_multi_blk_next<%=i%>); 
                no_of_mlt_blk_sngl_bit_ott_err_injected_bank_<%=i%>++;
              end
               if ($test$plusargs("address_error_test_ott")) begin
                injectAddrErrOtt<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_ott_addr_next<%=i%>); 
              end
              repeat(delay_btwn_err_inj) begin
                @(negedge u_csr_probe_vif.clk);
              end
              if (serial_err_inj) begin
                i++;
                sema_ott.put(1);
              end
              ott_no = <%=i%> % <%=obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks%>;
            end else begin
              sema_ott.put(1);
            end
          end while (i < error_threshold);
          end
          <% } %>
        <% } %>
        <%if(obj.AiuInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
          <%for( var i= ((obj.multiPortCoreId)*(obj.AiuInfo[obj.Id].ccpParams.nRPPorts)) ;i<=(obj.multiPortCoreId + 1)*(obj.AiuInfo[obj.Id].ccpParams.nRPPorts);i++){%>
          do begin
            if (!$test$plusargs("always_inject_corr_error")) begin
            sema_plru.get(1);
            end
            if (l < error_threshold) begin
              if (!serial_err_inj) begin
                l++;
                sema_plru.put(1);
              end

             if ($test$plusargs("plru_single_bit_direct_error_test")) begin
                injectSingleErrplru<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_plru_single_next<%=i%>);
                no_of_sngl_bit_plru_err_injected_bank_<%=i%>++;
              end
             if ($test$plusargs("plru_double_bit_direct_error_test")) begin
                injectDoubleErrplru<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_plru_double_next<%=i%>);
                no_of_dbl_bit_plru_err_injected_bank_<%=i%>++;
              end
             if ($test$plusargs("plru_address_error_test")) begin
                injectAddrErrplru<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_plru_addr_next<%=i%>);
             end
             repeat(delay_btwn_err_inj) begin
                @(negedge u_csr_probe_vif.clk);
             end

             if (serial_err_inj) begin
                l++;
                sema_plru.put(1);
             end
           end else begin
              sema_plru.put(1);
           end
          end while (l < error_threshold);

          <% } %>
          <% } %>
<%if (obj.AiuInfo[obj.Id].useCache) { %>
        <%if(obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") {%>
           <%for( var i= ((obj.multiPortCoreId) * obj.AiuInfo[obj.Id].ccpParams.nTagBanks);i< ( (obj.multiPortCoreId + 1) * obj.AiuInfo[obj.Id].ccpParams.nTagBanks);i++){%>
          do begin
            if(!$test$plusargs("always_inject_corr_error")) begin
            sema_tag.get(1);
            end
            if (j < error_threshold) begin
              if (!serial_err_inj) begin
                j++;
                sema_tag.put(1);
              end
              if ($test$plusargs("ccp_single_bit_tag_direct_error_test") ||$test$plusargs("always_inject_corr_error")) begin
                injectSingleErrTag<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_tag_single_next<%=i%>); 
                no_of_sngl_bit_tag_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("ccp_double_bit_direct_tag_error_test")) begin
                injectDoubleErrTag<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_tag_double_next<%=i%>); 
                no_of_dbl_bit_tag_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test")) begin
                inject_multi_block_single_double_ErrTag<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_tag_single_double_multi_blk_next<%=i%>); 
                no_of_mlt_blk_sngl_dbl_bit_tag_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("ccp_multi_blk_double_tag_direct_error_test")) begin
                inject_multi_block_double_ErrTag<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_tag_double_multi_blk_next<%=i%>); 
                no_of_mlt_blk_dbl_bit_tag_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("ccp_multi_blk_single_tag_direct_error_test")) begin
                inject_multi_block_single_ErrTag<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_tag_single_multi_blk_next<%=i%>); 
                no_of_mlt_blk_sngl_bit_tag_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("address_error_test_tag")) begin
                injectAddrErrTag<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_tag_addr_next<%=i%>);
              end
              repeat(delay_btwn_err_inj) begin
                @(negedge u_csr_probe_vif.clk);
              end
              if (serial_err_inj) begin
                j++;
                sema_tag.put(1);
              end
            end else begin
             sema_tag.put(1);
            end
          end while (j < error_threshold);
          <% } %>
        <% } %>
        <%if(obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY") {%>
          <%for(var i=((obj.multiPortCoreId)*(obj.AiuInfo[obj.Id].ccpParams.nDataBanks));i<((obj.multiPortCoreId + 1) * (obj.AiuInfo[obj.Id].ccpParams.nDataBanks));i++){%>
          if((sel_bank + <%=((obj.multiPortCoreId)*(obj.AiuInfo[obj.Id].ccpParams.nDataBanks))%> == <%=i%>) || $test$plusargs("always_inject_corr_error")) begin
          do begin
           if(!$test$plusargs("always_inject_corr_error")) begin
            sema_data.get(1);
           end
            if (k < error_threshold) begin
              if (!serial_err_inj) begin
                k++;
                sema_data.put(1);
              end
              if ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("always_inject_corr_error")) begin
                injectSingleErrData<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_data_single_next<%=i%>); 
                no_of_sngl_bit_data_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("ccp_double_bit_data_direct_error_test")) begin
                injectDoubleErrData<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_data_double_next<%=i%>); 
                no_of_dbl_bit_data_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("ccp_multi_blk_single_double_data_direct_error_test")) begin
                inject_multi_block_single_double_ErrData<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_data_single_double_multi_blk_next<%=i%>); 
                no_of_mlt_blk_sngl_dbl_bit_data_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("ccp_multi_blk_double_data_direct_error_test")) begin
                inject_multi_block_double_ErrData<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_data_double_multi_blk_next<%=i%>); 
                no_of_mlt_blk_dbl_bit_data_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("ccp_multi_blk_single_data_direct_error_test")) begin
                inject_multi_block_single_ErrData<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_data_single_multi_blk_next<%=i%>); 
                no_of_mlt_blk_sngl_bit_data_err_injected_bank_<%=i%>++;
              end
              if ($test$plusargs("address_error_test_data")) begin
                injectAddrErrData<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_data_addr_next<%=i%>); 
              end

              repeat(delay_btwn_err_inj) begin
                @(negedge u_csr_probe_vif.clk);
              end
              if (serial_err_inj) begin
                k++;
                sema_data.put(1);
              end
            end else begin
              sema_data.put(1);
            end
          end while (k < error_threshold);
          end
        <% } %>
      <% } %>
     <% } %>
<% } %>
        join
<% if (obj.assertOn) { %>
      <%if(obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY") {%>
        <%for( var i= ((obj.multiPortCoreId)*(obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks)) ;i<(obj.multiPortCoreId + 1)*(obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks);i++){%>
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_single_bit_ott_error_injected_bank_<%=i%> = %0h",no_of_sngl_bit_ott_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_double_bit_ott_error_injected_bank_<%=i%> = %0h",no_of_dbl_bit_ott_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_double_bit_ott_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_sngl_dbl_bit_ott_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_double_bit_ott_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_dbl_bit_ott_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_bit_ott_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_sngl_bit_ott_err_injected_bank_<%=i%>),UVM_NONE)
        <% } %>
      <% } %>
        <%if(obj.AiuInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
        <%for( var i= ((obj.multiPortCoreId)*(obj.AiuInfo[obj.Id].ccpParams.nRPPorts)) ;i<=(obj.multiPortCoreId + 1)*(obj.AiuInfo[obj.Id].ccpParams.nRPPorts);i++){%>
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_single_bit_plru_error_injected_bank_<%=i%> = %0h",no_of_sngl_bit_plru_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_double_bit_plru_error_injected_bank_<%=i%> = %0h",no_of_dbl_bit_plru_err_injected_bank_<%=i%>),UVM_NONE)
      <% } %>
      <% } %>
<%if (obj.AiuInfo[obj.Id].useCache) { %>
      <%if(obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") {%>
         <%for( var i= ((obj.multiPortCoreId) * obj.AiuInfo[obj.Id].ccpParams.nTagBanks);i< ( (obj.multiPortCoreId + 1) * obj.AiuInfo[obj.Id].ccpParams.nTagBanks);i++){%>
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_single_bit_tag_error_injected_bank_<%=i%> = %0h",no_of_sngl_bit_tag_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_double_bit_tag_error_injected_bank_<%=i%> = %0h",no_of_dbl_bit_tag_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_double_bit_tag_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_sngl_dbl_bit_tag_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_double_bit_tag_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_dbl_bit_tag_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_bit_tag_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_sngl_bit_tag_err_injected_bank_<%=i%>),UVM_NONE)
        <% } %>
      <% } %>
      <%if(obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY") {%>
        <%for( var i=0;i<obj.AiuInfo[obj.Id].ccpParams.nDataBanks;i++){%>
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_single_bit_data_error_injected_bank_<%=i%> = %0h",no_of_sngl_bit_data_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_double_bit_data_error_injected_bank_<%=i%> = %0h",no_of_dbl_bit_data_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_double_bit_data_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_sngl_dbl_bit_data_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_double_bit_data_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_dbl_bit_data_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_bit_data_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_sngl_bit_data_err_injected_bank_<%=i%>),UVM_NONE)
        <% } %>
      <% } %>
<% } %>
<% } %>
    endtask
    

    task poll_UUESR_ErrVld(bit [31:0] poll_till, output uvm_reg_data_t fieldVal,input int time_out = 10_000);
        poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>,poll_till,fieldVal,time_out);
    endtask
    task poll_UCESR_ErrVld(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>,poll_till,fieldVal);
    endtask
    task poll_UCESR_ErrCount(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCount')%>,poll_till,fieldVal);
    endtask
    task poll_UCESR_ErrCountOverflow(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCountOverflow')%>,poll_till,fieldVal);
    endtask

    function bit [`UVM_REG_ADDR_WIDTH-1 : 0] get_unmapped_csr_addr();
      bit [`UVM_REG_ADDR_WIDTH-1 : 0] all_csr_addr[$];
      typedef struct packed {
                             bit [`UVM_REG_ADDR_WIDTH-1 : 0] lower_addr;
                             bit [`UVM_REG_ADDR_WIDTH-1 : 0] upper_addr;
                            } csr_addr;
      csr_addr csr_unmapped_addr_range[$];
      int randomly_selected_unmapped_csr_sddr;
      
      <% obj.DutInfo.csr.spaceBlock[0].registers.forEach(function GetAllregAddr(item,i){ %>
                                  //all_csr_addr.push_back({12'h<%=obj.DutInfo.nrri%>,8'h<%=obj.DutInfo.rpn%>,12'h<%=item.addressOffset%>});
                                  all_csr_addr.push_back(<%=item.addressOffset%>);
                               <% }); %>
      all_csr_addr.sort();
      `uvm_info(get_full_name(),$sformatf("all_csr_addr : %0p",all_csr_addr),UVM_NONE);
      for (int i = 0; i <= (all_csr_addr.size() - 2); i++) begin 
        if ((all_csr_addr[i+1] - all_csr_addr[i]) > 'h4) begin
          csr_unmapped_addr_range.push_back({(all_csr_addr[i]+'h4),(all_csr_addr[i+1]-4)});
        end
      end
      `uvm_info(get_full_name(),$sformatf("csr_unmapped_addr_range : %0p",csr_unmapped_addr_range),UVM_NONE);
      randomly_selected_unmapped_csr_sddr = $urandom_range((csr_unmapped_addr_range.size()-1),0);
      get_unmapped_csr_addr = $urandom_range(csr_unmapped_addr_range[randomly_selected_unmapped_csr_sddr].lower_addr,csr_unmapped_addr_range[randomly_selected_unmapped_csr_sddr].upper_addr);
      `uvm_info(get_full_name(),$sformatf("unmapped_csr_addr : 0x%0x",get_unmapped_csr_addr),UVM_NONE);
    endfunction : get_unmapped_csr_addr

    function void get_apb_if();
      if (!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("apb_if"),
                                          .value(apb_vif)))
        `uvm_error(get_name,"Failed to get apb if")
    endfunction

endclass : io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>

class ioaiu_starv_en_chk_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_starv_en_chk_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, write_data;
    uvm_reg_data_t field_rd_data_evtcount,field_rd_data_prev_evtcount,field_rd_data;
    uvm_reg_data_t eventThreshold;
    int starvation_wait_count,delay,k_timeout;
    int starvation_count_<%=obj.multiPortCoreId%>=0;
    // bit st,to;// to randomly set Starvation TIME or TimeOut register
    uvm_event ev_delay_smi_msg = ev_pool.get("ev_delay_smi_msg");//delay message to trigger timeout
    uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
    string arg_value;
    uvm_status_e           status;

    function new(string name="");
        super.new(name);
        if (clp.get_arg_value("+k_timeout=", arg_value)) begin
           k_timeout = arg_value.atoi();
           k_timeout = (k_timeout /100);
        end

    endfunction

    task body();

        getCsrProbeIf();
        <%if(obj.DutInfo.fnEnableQos == 1){%>

        read_data = 0;
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUQOSCR.EventThreshold')%>,read_data);
        `uvm_info(get_full_name(),$sformatf("XAIUQOSCR.EventThreshold initial Read Data = %0h",read_data),UVM_NONE)
        //#Stimulus.IOAIU.Starvation
        std::randomize(eventThreshold) with {eventThreshold dist{0:=2, [1:3]:=98};};
        if($test$plusargs("Starv_Event_Thrs"))
            $value$plusargs("Starv_Event_Thrs=%d",eventThreshold);

        write_data = eventThreshold;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUQOSCR.EventThreshold')%>, write_data); 
        `uvm_info(get_full_name(),$sformatf("XAIUQOSCR.EventThreshold Write Data = %0h",write_data),UVM_NONE)

        read_data = 0;
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUQOSCR.EventThreshold')%>,read_data);
        if (read_data != write_data)
            `uvm_error(get_full_name(),$sformatf("XAIUQOSCR.EventThreshold Read Data = %0d (should be %0d)",read_data, write_data))
        else
            `uvm_info(get_full_name(),$sformatf("ioaiu_starv_en_chk_seq XAIUQOSCR.EventThreshold = %0d", read_data), UVM_NONE)
        <%}%>

        ev_<%=obj.multiPortCoreId%>.trigger();
<%if(obj.DutInfo.fnEnableQos == 1){%>
      //Check to make sure we enter starvation. 
      //#Check.IOAIU.Starvation.EventStatus
      //#Check.IOAIU.NoStarvation_ThresholdZero
      //#Check.IOAIU.Starvation.EventStatusCount
      fork
      begin
      do begin
         field_rd_data = 0;

         read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUQOSSR.EventStatus')%>,field_rd_data);
         if(field_rd_data==1)`uvm_info(get_full_name(),$sformatf("Entered in starvation mode Reg EvntStatus %0d ",field_rd_data), UVM_NONE)

         read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUQOSSR.EventStatusCount')%>,field_rd_data_evtcount);


         if(eventThreshold ==0 && field_rd_data_evtcount !=0 ) begin
             `uvm_error("STARV_EN_CHK", $sformatf("Entered in starvation mode at threshold=0"));
         end   

         <% if(obj.COVER_ON) { %>
           `ifndef FSYS_COVER_ON
             cov.Starvation_EachCore_EventStatus(<%=obj.multiPortCoreId%>,starvation_count_<%=obj.multiPortCoreId%>,field_rd_data);
           `endif 
         <%}%> 
         field_rd_data_prev_evtcount= field_rd_data_evtcount;
         k_timeout--;
      end while ( (u_csr_probe_vif.TransActv !== 0));
      end
      begin
         forever begin
         @(posedge u_csr_probe_vif.clk)
         @(posedge u_csr_probe_vif.starv_evt_status)
          starvation_count_<%=obj.multiPortCoreId%> ++;
              `uvm_info(get_full_name(),$sformatf("Entered in starvation mode probe if EvntStatus %0d count %0d ",u_csr_probe_vif.starv_evt_status,starvation_count_<%=obj.multiPortCoreId%>), UVM_NONE)
         end
      end
      join_any
      disable fork;
      if(field_rd_data_evtcount !=starvation_count_<%=obj.multiPortCoreId%> ) begin
             `uvm_error("STARV_EN_CHK", $sformatf("coreID_<%=obj.multiPortCoreId%> Starvation Event count mismatch  expected eventstatuscount=0x%0d from QoS eventstatuscount reg =0x%0d",starvation_count_<%=obj.multiPortCoreId%>,field_rd_data_evtcount));
      end
      else begin
       `uvm_info(get_full_name(),$sformatf("starvation count %0d ",starvation_count_<%=obj.multiPortCoreId%>), UVM_NONE) 
      end

<%}%>

    endtask
endclass : ioaiu_starv_en_chk_seq_<%=obj.multiPortCoreId%>

class ioaiu_chk_proxy_cache_initial_done_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
  `uvm_object_utils(ioaiu_chk_proxy_cache_initial_done_seq_<%=obj.multiPortCoreId%>)

    bit done;
    uvm_reg_data_t poll_data, read_data, write_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

         getCsrProbeIf();
         ev_<%=obj.multiPortCoreId%>.trigger();

<% if (obj.DutInfo.useCache){ %>
         // check PC tag intialization is done
         read_data = 0;
         read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCISR.TagInitDone')%>,read_data);
         `uvm_info(get_full_name(),$sformatf("XAIUPCISR.TagInitDone Read Data = %0h",read_data),UVM_NONE)
         compareValues("XAIUPCISR.TagInitDone","done", read_data, done);

         // check PC data intialization is done
         read_data = 0;
         read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCISR.DataInitDone')%>,read_data);
         `uvm_info(get_full_name(),$sformatf("XAIUPCISR.DataInitDone Read Data = %0h",read_data),UVM_NONE)
         compareValues("XAIUPCISR.DataInitDone","done", read_data, done);
<% } %>
    endtask
endclass : ioaiu_chk_proxy_cache_initial_done_seq_<%=obj.multiPortCoreId%>

class access_unmapped_csr_addr_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
  `uvm_object_utils(access_unmapped_csr_addr_<%=obj.multiPortCoreId%>)
  bit [`UVM_REG_ADDR_WIDTH-1 : 0] unmapped_csr_addr;
  apb_pkt_t apb_pkt;

  function new(string name="");
      super.new(name);
  endfunction

  task body();
    get_apb_if();
    ev_<%=obj.multiPortCoreId%>.trigger();
    unmapped_csr_addr = get_unmapped_csr_addr();
    apb_pkt = apb_pkt_t::type_id::create("apb_pkt");
    apb_pkt.paddr = unmapped_csr_addr;
    apb_pkt.pwrite = 1;
    apb_pkt.psel = 1;
    apb_pkt.pwdata = $urandom;
    apb_vif.drive_apb_channel(apb_pkt);
  endtask
endclass : access_unmapped_csr_addr_<%=obj.multiPortCoreId%>

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check error interrupt functionality through alias register write. 
* 1. Enable correctable error interrupt. 
* 2. Write 1 to XAIUCESAR.ErrVld (alias register) so that XAIUCESR.ErrVld asserts in actual register.
* 3. Check that uncorrectable error interrupt should be asserted by DUT.
* 4. Write 0 to XAIUCESAR.ErrVld (alias register) so that XAIUCESR.ErrVld de-asserts in actual register.
* 5. Check that uncorrectable error interrupt should be de-asserted by DUT.
* 2. Write 1 to XAIUCESAR.ErrVld (alias register) so that XAIUCESR.ErrVld asserts in actual register.
* 3. Check that uncorrectable error interrupt should be asserted by DUT.
* 4. Write 0 to XAIUCESAR.ErrVld (alias register) so that XAIUCESR.ErrVld de-asserts in actual register.
* 5. Check that uncorrectable error interrupt should be de-asserted by DUT.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class ioaiu_corr_errint_check_through_xaiucesar_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_corr_errint_check_through_xaiucesar_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
           getCsrProbeIf();
           ev_<%=obj.multiPortCoreId%>.trigger();
           //set correctable error interrupt
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
       
           //Assert XAIUCESR.ErrVld through alias register write
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrCount')%>, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrCountOverflow')%>, write_data);
         
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
           compareValues("XAIUCESR_ErrVld","set", read_data, 1);

           // wait for IRQ_C interrupt 
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 1);
           end
           begin
             #200;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
           join_any
           disable fork;
  
           //De-assert XAIUCESR.ErrVld through alias register write

           write_data = 0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrCount')%>, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrCountOverflow')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
           compareValues("XAIUCESR_ErrVld", "now clear", read_data, 0);

           // wait for IRQ_C interrupt to de-assert
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 0);
           end
           begin
             #200;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C de-asserted"));
           end
           join_any
           disable fork;

           // make counter overflow
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, 1);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrCount')%>, 8'hff);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrCountOverflow')%>, 1);

           //Repeat the entire procedure
           // wait for IRQ_C interrupt 
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 1);
           end
           begin
             #200;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
           join_any
           disable fork;


           //De-assert XAIUCESR.ErrVld through alias register write

           write_data = 0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrCount')%>, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrCountOverflow')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
           compareValues("XAIUCESR_ErrVld", "now clear", read_data, 0);

           // wait for IRQ_C interrupt to de-assert
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 0);
           end
           begin
             #200;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C de-asserted"));
           end
           join_any
           disable fork;

           // make counter overflow
           //set correctable error interrupt
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
       
           //Assert XAIUCESR.ErrVld through alias register write
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrCount')%>, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrCountOverflow')%>, write_data);
         
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
           compareValues("XAIUCESR_ErrVld","set", read_data, 1);

           // wait for IRQ_C interrupt 
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 1);
           end
           begin
             #200;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
           join_any
           disable fork;
  
           //De-assert XAIUCESR.ErrVld through alias register write

           write_data = 0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrCount')%>, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrCountOverflow')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
           compareValues("XAIUCESR_ErrVld", "now clear", read_data, 0);

           // wait for IRQ_C interrupt to de-assert
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 0);
           end
           begin
             #200;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C de-asserted"));
           end
           join_any
           disable fork;
  
    endtask
endclass : ioaiu_corr_errint_check_through_xaiucesar_seq_<%=obj.multiPortCoreId%>

class ioaiu_timeout_errint_check_through_xaiuuesar_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
      `uvm_object_utils(ioaiu_timeout_errint_check_through_xaiuuesar_seq_<%=obj.multiPortCoreId%>)
     
       uvm_reg_data_t poll_data, read_data, write_data;

       function new(string name="");
        super.new(name);
       endfunction

        task body();
        getCsrProbeIf();
        ev_<%=obj.multiPortCoreId%>.trigger();

        write_data = 1;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.TimeoutErrIntEn')%>, write_data);

        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrType')%>, 9);
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrInfo')%>,20'hABCDE);
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrVld')%>, write_data);

        fork
            begin
                wait (u_csr_probe_vif.IRQ_UC === 1);
            end
            begin
              #200000ns;
              `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
            end
        join_any
        disable fork;

        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>,read_data);
        compareValues("XAIUUESR_ErrVld", "now set", read_data, 1);
        
        write_data = 0;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrVld')%>, write_data);
        // Read the XAIUUESR_ErrVld should be cleared
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>,read_data);
        compareValues("XAIUUESR_ErrVld", "now clear", read_data, 0);
        fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 0);
           end
           begin
             #200000ns;
             `uvm_error(get_full_name(),$sformatf("IRQ_UC interruped still aseerted"));
           end
           join_any
           disable fork;
    endtask     

endclass : ioaiu_timeout_errint_check_through_xaiuuesar_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_trace_debug_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
   `uvm_object_utils(ioaiu_csr_trace_debug_seq_<%=obj.multiPortCoreId%>)
    uvm_reg_data_t write_data ,poll_data, read_data,read_data_type,read_data_info,read_data_valid;
   
    trace_trigger_utils m_trace_trigger;

    TRIG_TCTRLR_t tctrlr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBALR_t  tbalr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBAHR_t  tbahr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR0_t topcr0[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR1_t topcr1[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBR_t   tubr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBMR_t  tubmr[<%=obj.DutInfo.nTraceRegisters%>];

    uvm_event csr_trace_debug_done = ev_pool.get("csr_trace_debug_done");
    int tmp_idx;
    int ioaiu_cctrlr_phase = 0;    // This variable is controlled by the test.
    bit [31:0] ioaiu_cctrlr_val;   // Parm to use for CCTRLR
    bit err_det_en;
    int        errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;
    bit [19:0]  errinfo;
    bit [51:0]  exp_addr;
    bit errinfo_check, erraddr_check;
    bit [51:0] actual_addr;
    bit [19:0] err_entry;
    bit [5:0] err_way;
    bit [5:0] err_word;
    bit [19:0] err_addr;
    bit Intf_Check_Err_Det_En = 0;
   bit Intf_Check_Err_Int_En =0;
   int data;
   string name;
<% for (j=0; j < obj.DutInfo.nTraceRegisters; ++j) {%> 
    bit [31:0] ioaiu_tctrlr<%=j%>_val;   // Parm to use for TCTRLR
    bit [31:0] ioaiu_tbalr<%=j%>_val;    // Parm to use for TBALR
    bit [31:0] ioaiu_tbahr<%=j%>_val;    // Parm to use for TBAHR
    bit [31:0] ioaiu_topcr0<%=j%>_val;   // Parm to use for TOPCR0
    bit [31:0] ioaiu_topcr1<%=j%>_val;   // Parm to use for TOPCR1
    bit [31:0] ioaiu_tubr<%=j%>_val;     // Parm to use for TUBR
    bit [31:0] ioaiu_tubmr<%=j%>_val;    // Parm to use for TUBMR
<% } %>

    function new(string name="");
        super.new(name);

        $value$plusargs("ioaiu_cctrlr_val=%x",ioaiu_cctrlr_val);

<% for (j=0; j < obj.DutInfo.nTraceRegisters; ++j) {%> 
        $value$plusargs("ioaiu_tctrlr<%=j%>_val=%x",ioaiu_tctrlr<%=j%>_val);
        $value$plusargs("ioaiu_tbalr<%=j%>_val=%x",ioaiu_tbalr<%=j%>_val);
        $value$plusargs("ioaiu_tbahr<%=j%>_val=%x",ioaiu_tbahr<%=j%>_val);
        $value$plusargs("ioaiu_topcr0<%=j%>_val=%x",ioaiu_topcr0<%=j%>_val);
        $value$plusargs("ioaiu_topcr1<%=j%>_val=%x",ioaiu_topcr1<%=j%>_val);
        $value$plusargs("ioaiu_tubr<%=j%>_val=%x",ioaiu_tubr<%=j%>_val);
        $value$plusargs("ioaiu_tubmr<%=j%>_val=%x",ioaiu_tubmr<%=j%>_val);
<% } %>
        
        m_trace_trigger = new();
        m_trace_trigger.set_mpCoreId_value(<%=obj.multiPortCoreId%>);
        uvm_config_db#(trace_trigger_utils)::set(null, "mp_env.m_env[<%=obj.multiPortCoreId%>]", "m_trace_trigger", m_trace_trigger);
 
    endfunction

    task body();
        
        bit dis_uedr_ted_4resiliency ;
	std::randomize(dis_uedr_ted_4resiliency)with{dis_uedr_ted_4resiliency dist {1:=20,0:=80};};
        getCsrProbeIf();
        getSMIIf();
        get_env_handle();

        // to get full randomization of each trigger register, unconstrained, set the plusarg trigger<%=i%>_random
        // the recommended plusarg usage to control trigger register values is to use one of the following, from highest priority to lowest, 
        // 1. trigger<%=i%>_random plusarg, to get full randomization of every trigger register, unconstrained
        // 2. register value plusargs, such as tctrlr<%=i%>_value for full control of an entire trigger register
        // 3. use field plusargs, such as trace<%=i%>_native_match_en, for full control of a particular trigger register field
        // 4. default is to let the sequence randomize the field plusargs using a weighted random
        // do not mix plusarg types 2 and 3 for a single register, the result is undefined

        //#Stimulus.IOAIU.MasterInitiatedTrace
        //#Stimulus.IOAIU.Native.Trace.Matchen
        //#Stimulus.IOAIU.Address.Matchen
        //#Stimulus.IOAIU.Op_code.Matchen
        //#Stimulus.IOAIU.Memory.Attribute.Matchen
        //#Stimulus.IOAIU.Userbits.Matchen
        //#Stimulus.IOAIU.Target.Type.Match
        
        if(dis_uedr_ted_4resiliency)begin
           `uvm_info(get_full_name(),$sformatf("Skipping-1 enabling of error detection inside xUEDR"),UVM_NONE)
           end
           else begin
                if($test$plusargs("inject_parity_err_cr_chnl")||$test$plusargs("inject_parity_err_w_chnl")||$test$plusargs("inject_parity_err_ar_chnl")||$test$plusargs("inject_parity_err_aw_chnl"))begin
                  std::randomize(Intf_Check_Err_Det_En) with { Intf_Check_Err_Det_En dist{1 := 90,0:=10};};
                  std::randomize(Intf_Check_Err_Int_En) with { Intf_Check_Err_Int_En dist{1 := 90,0:=10};}; 
                  write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.IntfCheckErrDetEn')%>, Intf_Check_Err_Det_En); 
                  write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.IntfCheckErrIntEn')%>, Intf_Check_Err_Int_En);
                  errtype = 4'hD;                  
                end else begin
                  errtype = 4'h8;
                  // Set the UUECR_ErrDetEn = 1
                  write_data = 1;
	  	  if (!($test$plusargs("dtw_dbg_rsp_err_inj_c")))begin 
                  write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.TransErrDetEn')%>, write_data); 
                  write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.TransErrIntEn')%>, write_data);
	  	  end else begin 
      	  	  write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
      	          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
	  	  end
                end
	    end

        <% for(var i=0; i<obj.DutInfo.nTraceRegisters; i++) {%>
        if ($test$plusargs("ttrig_reg_prog_en")) begin : ttrig_reg_prog_en_code_<%=i%>
            // decide register values
            // randomize registers if value not passed through plusargs.
            bit [5:0] trace<%=i%>_match_en_rand;
            bit trace<%=i%>_native_match_en;
            bit trace<%=i%>_addr_match_en;
            bit trace<%=i%>_opcode_match_en;
            bit trace<%=i%>_memattr_match_en;
            bit trace<%=i%>_user_match_en;
            bit trace<%=i%>_target_type_match_en;
            bit [4:0] trace<%=i%>_addr_match_size;
            bit trace<%=i%>_memattr_match_ar;
            bit trace<%=i%>_memattr_match_aw;
            bit [3:0] trace<%=i%>_memattr_match_value;
            bit [3:0] trace<%=i%>_opcode_valids_rand;
            bit [14:0] trace<%=i%>_opcode1;
            bit [14:0] trace<%=i%>_opcode2;
            bit [14:0] trace<%=i%>_opcode3;
            bit [14:0] trace<%=i%>_opcode4;
            bit trace<%=i%>_target_type_match_hut;
            bit [4:0] trace<%=i%>_target_type_match_hui;
            int rand_ttrig;
            rand_ttrig = $urandom_range(<%=obj.DutInfo.nTraceRegisters%>);

            uvm_config_db#(int)::get(null, "", "ioaiu_cctrlr_phase", ioaiu_cctrlr_phase);

            if (($test$plusargs("ioaiu_cctrlr_mod")) && ($test$plusargs("ioaiu_tctrlr<%=i%>_val")) && 
                (ioaiu_cctrlr_phase==2)) begin
                tctrlr[<%=i%>] = ioaiu_tctrlr<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                tctrlr[<%=i%>] = $urandom();
            end else if($value$plusargs("tctrlr<%=i%>_value=%0x", tctrlr[<%=i%>])) begin
                // user-specified tctrlr
            end else begin : randomize_tctrlr_by_field
              begin: select_values_for_enables
                case ($urandom_range(100,1)) inside
                    ['d01:'d20]: trace<%=i%>_match_en_rand = 'h3f; // all enabled
                    ['d21:'d25]: trace<%=i%>_match_en_rand = 'h20; // enable one at a time
                    ['d26:'d30]: trace<%=i%>_match_en_rand = 'h10;
                    ['d31:'d35]: trace<%=i%>_match_en_rand = 'h08;
                    ['d36:'d40]: trace<%=i%>_match_en_rand = 'h04;
                    ['d41:'d45]: trace<%=i%>_match_en_rand = 'h02;
                    ['d46:'d50]: trace<%=i%>_match_en_rand = 'h01;
                    ['d51:'d60]: trace<%=i%>_match_en_rand = 'h00; // none enabled
                    default :    trace<%=i%>_match_en_rand = $urandom_range('h3f,'h00); // unconstrained
                endcase
                if ($test$plusargs("trigger_random")) begin 
                  trace<%=i%>_native_match_en         = trace<%=i%>_match_en_rand[0];
                  trace<%=i%>_addr_match_en           = trace<%=i%>_match_en_rand[1];
                  trace<%=i%>_opcode_match_en         = trace<%=i%>_match_en_rand[2];
                  trace<%=i%>_memattr_match_en        = trace<%=i%>_match_en_rand[3];
                  trace<%=i%>_user_match_en           = trace<%=i%>_match_en_rand[4];
                  trace<%=i%>_target_type_match_en    = trace<%=i%>_match_en_rand[5];
                end else if (<%=i%> == rand_ttrig) begin 
                  if($value$plusargs("trace_native_match_en=%0b",trace<%=i%>_native_match_en)) begin
                      // user-specified native_match_en
                  end else begin
                      trace<%=i%>_native_match_en = 0;
                  end
                  if($value$plusargs("trace_addr_match_en=%0b", trace<%=i%>_addr_match_en)) begin
                      // user-specified addr_match_en
                  end else begin
                      trace<%=i%>_addr_match_en = 0;
                  end
                  if($value$plusargs("trace_opcode_match_en=%0b", trace<%=i%>_opcode_match_en)) begin
                      // user-specified opcode_match_en
                  end else begin
                      trace<%=i%>_opcode_match_en = 0;
                  end
                  if($value$plusargs("trace_memattr_match_en=%0b", trace<%=i%>_memattr_match_en)) begin
                      // user-specified memattr_match_en
                  end else begin
                      trace<%=i%>_memattr_match_en = 0;
                  end
                  if($value$plusargs("trace_user_match_en=%0b", trace<%=i%>_user_match_en)) begin
                      // user-specified user_match_en
                  end else begin
                      trace<%=i%>_user_match_en = 0;
                  end
                  if($value$plusargs("trace_target_type_match_en=%0b", trace<%=i%>_target_type_match_en)) begin
                      // user-specified target_type_match_en
                  end else begin
                      trace<%=i%>_target_type_match_en = 0;
                  end
                end else begin 
                  trace<%=i%>_native_match_en         = 0;
                  trace<%=i%>_addr_match_en           = 0;
                  trace<%=i%>_opcode_match_en         = 0;
                  trace<%=i%>_memattr_match_en        = 0;
                  trace<%=i%>_user_match_en           = 0;
                  trace<%=i%>_target_type_match_en    = 0;
                end 

                  tctrlr[<%=i%>].native_trace_en      = trace<%=i%>_native_match_en;
                  tctrlr[<%=i%>].addr_match_en        = trace<%=i%>_addr_match_en;
                  tctrlr[<%=i%>].opcode_match_en      = trace<%=i%>_opcode_match_en;
                  tctrlr[<%=i%>].memattr_match_en     = trace<%=i%>_memattr_match_en;
                  tctrlr[<%=i%>].user_match_en        = trace<%=i%>_user_match_en;
                  tctrlr[<%=i%>].target_type_match_en = trace<%=i%>_target_type_match_en;
              end: select_values_for_enables
                  
              begin: select_values_for_tctrlr_misc_fields
                if($value$plusargs("trace_addr_match_size=%0x", trace<%=i%>_addr_match_size)) begin
                    // user-specified addr_match_size
                end else begin
                    case ($urandom_range(100,1)) inside
                        ['d01:'d25]: trace<%=i%>_addr_match_size = 'h1f; // max size
                        ['d26:'d50]: trace<%=i%>_addr_match_size = 'h00; // min size
                        default :    trace<%=i%>_addr_match_size = $urandom_range('h1f,'h00); // unconstrained
                    endcase
                end
                tctrlr[<%=i%>].range = trace<%=i%>_addr_match_size;

                trace<%=i%>_memattr_match_ar = $urandom_range('h1,'h0); // unconstrained
                tctrlr[<%=i%>].ar = trace<%=i%>_memattr_match_ar;
                trace<%=i%>_memattr_match_aw = $urandom_range('h1,'h0); // unconstrained
                tctrlr[<%=i%>].aw = trace<%=i%>_memattr_match_aw;

                if($value$plusargs("trace_memattr_match_value=%0x", trace<%=i%>_memattr_match_value)) begin
                    // user-specified memattr_match_value
                end else begin
                    trace<%=i%>_memattr_match_value = $urandom_range('hf,'h0); // unconstrained
                end
                tctrlr[<%=i%>].memattr = trace<%=i%>_memattr_match_value;

                // hut dii=1, dmi=0
                if($value$plusargs("trace_target_type_match_hut=%0b", trace<%=i%>_target_type_match_hut)) begin
                    // user-specified target_type_match_hut
                end else begin
                    trace<%=i%>_target_type_match_hut = $urandom_range('h1,'h0); // unconstrained
                end
                tctrlr[<%=i%>].hut = trace<%=i%>_target_type_match_hut;
                
                if($value$plusargs("trace_target_type_match_hui=%0b", trace<%=i%>_target_type_match_hui)) begin
                    // user-specified target_type_match_hui
                end else begin
                    case ($urandom_range(100,1)) inside
                        // 'h00 and 'h01 are most commonly seen in simulations, larger values are rare or do not occur
                        ['d01:'d30]: trace<%=i%>_target_type_match_hui = 'h00; 
                        ['d31:'d45]: trace<%=i%>_target_type_match_hui = 'h01; 
                        ['d46:'d50]: trace<%=i%>_target_type_match_hui = 'h02; 
                        default :    trace<%=i%>_target_type_match_hui = $urandom_range('h1f,'h00); // unconstrained
                    endcase
                end
                tctrlr[<%=i%>].hui = trace<%=i%>_target_type_match_hui;

              end: select_values_for_tctrlr_misc_fields
            end : randomize_tctrlr_by_field

            if (($test$plusargs("ioaiu_cctrlr_mod")) && ($test$plusargs("ioaiu_tbalr<%=i%>_val")) && 
                (ioaiu_cctrlr_phase==2)) begin
                tbalr[<%=i%>] = ioaiu_tbalr<%=i%>_val;
            end 
            if (($test$plusargs("ioaiu_cctrlr_mod")) && ($test$plusargs("ioaiu_tbahr<%=i%>_val")) && 
                (ioaiu_cctrlr_phase==2)) begin
                tbahr[<%=i%>] = ioaiu_tbahr<%=i%>_val;
            end else if($value$plusargs("tbalr_value=%0x", tbalr[<%=i%>])) begin
                // user-specified tbalr
                $value$plusargs("tbahr_value=%0x", tbahr[<%=i%>]); 
                // user-specified tbahr
            end else begin
                addrMgrConst::sys_addr_csr_t csrq[$];
                csrq = addrMgrConst::get_all_gpra();
                foreach(csrq[i])
                  tmp_idx = $urandom_range(csrq.size()); 

                tbahr[<%=i%>] = csrq[tmp_idx].upp_addr; 
                tbalr[<%=i%>] = csrq[tmp_idx].low_addr;
            end


            if (($test$plusargs("ioaiu_cctrlr_mod")) && ($test$plusargs("ioaiu_topcr0<%=i%>_val")) && 
                (ioaiu_cctrlr_phase==2)) begin
                topcr0[<%=i%>] = ioaiu_topcr0<%=i%>_val; 
            end 
            if (($test$plusargs("ioaiu_cctrlr_mod")) && ($test$plusargs("ioaiu_topcr1<%=i%>_val")) && 
                (ioaiu_cctrlr_phase==2)) begin
                topcr1[<%=i%>] = ioaiu_topcr1<%=i%>_val; 
            end else if($test$plusargs("trigger_random")) begin
                topcr0[<%=i%>] = $urandom();
                topcr1[<%=i%>] = $urandom();
            // assume if user specifies topcr0 they also specify topcr1
            end else if($value$plusargs("topcr0_value=%0x", topcr0[<%=i%>])) begin
                // user-specified topcr0
                $value$plusargs("topcr1_value=%0x", topcr1[<%=i%>]);
                // user-specified topcr1
            end else begin : opcode_weighted_randomization
                case ($urandom_range(100,1)) inside
                    // prioritize more valids for a better chance of getting a match
                    ['d01:'d20]: trace<%=i%>_opcode_valids_rand = 'hf; // all
                    ['d21:'d30]: trace<%=i%>_opcode_valids_rand = 'h8; // one at a time
                    ['d31:'d40]: trace<%=i%>_opcode_valids_rand = 'h4; 
                    ['d41:'d50]: trace<%=i%>_opcode_valids_rand = 'h2; 
                    ['d51:'d60]: trace<%=i%>_opcode_valids_rand = 'h1; 
                    ['d61:'d70]: trace<%=i%>_opcode_valids_rand = 'h0; // none
                    default :    trace<%=i%>_opcode_valids_rand = $urandom_range('hf,'h0); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    <%if(obj.DutInfo.fnNativeInterface === "ACELITE-E") {%>
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d60]: trace<%=i%>_opcode1 = $urandom_range('h3f,'h00);
                     ['d61:'d90]: trace<%=i%>_opcode1 =  'hc40;
                    ['d90:'d91]: trace<%=i%>_opcode1 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode1 = $urandom_range('h7fff,'h0000); // unconstrained
                    <%}else {%>
                     // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode1 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode1 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode1 = $urandom_range('h7fff,'h0000); // unconstrained
                    <%}%>
                endcase
                case ($urandom_range(100,1)) inside
                     <%if(obj.DutInfo.fnNativeInterface === "ACELITE-E") {%>
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d60]: trace<%=i%>_opcode2 = $urandom_range('h3f,'h00);
                    ['d61:'d90]: trace<%=i%>_opcode2 =  'hc40;
                    ['d90:'d91]: trace<%=i%>_opcode2 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode2 = $urandom_range('h7fff,'h0000); // unconstrained
                    <%} else {%>
                       // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode2 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode2 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode2 = $urandom_range('h7fff,'h0000); // unconstrained

                    <%}%>
                endcase
                case ($urandom_range(100,1)) inside
                      <%if(obj.DutInfo.fnNativeInterface === "ACELITE-E") {%> 
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d60]: trace<%=i%>_opcode3 = $urandom_range('h3f,'h00);
                    ['d61:'d90]: trace<%=i%>_opcode3 = 'hc40;
                    ['d90:'d91]: trace<%=i%>_opcode3 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode3 = $urandom_range('h7fff,'h0000); // unconstrained
                    <%} else {%>
                      // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode2 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode2 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode2 = $urandom_range('h7fff,'h0000); // unconstrained
                    <%}%>
                endcase
                case ($urandom_range(100,1)) inside
                     <%if(obj.DutInfo.fnNativeInterface === "ACELITE-E") {%>
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d60]: trace<%=i%>_opcode4 = $urandom_range('h3f,'h00);
                    ['d61:'d90]: trace<%=i%>_opcode4 = 'hc40;
                    ['d90:'d91]: trace<%=i%>_opcode4 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode4 = $urandom_range('h7fff,'h0000); // unconstrained
                    <%} else {%>
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode2 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode2 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode2 = $urandom_range('h7fff,'h0000); // unconstrained
                    <%}%>
                endcase
                topcr0[<%=i%>].valid1  = trace<%=i%>_opcode_valids_rand[0];
                topcr0[<%=i%>].valid2  = trace<%=i%>_opcode_valids_rand[1];
                topcr1[<%=i%>].valid3  = trace<%=i%>_opcode_valids_rand[2];
                topcr1[<%=i%>].valid4  = trace<%=i%>_opcode_valids_rand[3];
                topcr0[<%=i%>].opcode1 = trace<%=i%>_opcode1;
                topcr0[<%=i%>].opcode2 = trace<%=i%>_opcode2;
                topcr1[<%=i%>].opcode3 = trace<%=i%>_opcode3;
                topcr1[<%=i%>].opcode4 = trace<%=i%>_opcode4;
            end : opcode_weighted_randomization

            if (($test$plusargs("ioaiu_cctrlr_mod")) && ($test$plusargs("ioaiu_tubr<%=i%>_val")) && 
                (ioaiu_cctrlr_phase==2)) begin
                tubr[<%=i%>] = ioaiu_tubr<%=i%>_val; 
            end else if($test$plusargs("trigger_random")) begin
                tubr[<%=i%>] = $urandom();
            end else if($value$plusargs("tubr_value=%0x", tubr[<%=i%>])) begin
                // user-specified tubr
            end else begin : tubr_weighted_randomization
                case ($urandom_range(100,1)) inside
                    ['d01:'d20]: tubr[<%=i%>] = 'h0000_0000; 
                    ['d21:'d40]: tubr[<%=i%>] = $urandom_range('hf,'h0);
                    ['d41:'d41]: tubr[<%=i%>] = 'h0000_0010; 
                    ['d42:'d42]: tubr[<%=i%>] = 'h0000_0020; 
                    ['d43:'d43]: tubr[<%=i%>] = 'h0000_0040; 
                    ['d44:'d44]: tubr[<%=i%>] = 'h0000_0080; 
                    ['d45:'d45]: tubr[<%=i%>] = 'h0000_0100; 
                    ['d46:'d46]: tubr[<%=i%>] = 'h0000_0200; 
                    ['d47:'d47]: tubr[<%=i%>] = 'h0000_0400; 
                    ['d48:'d48]: tubr[<%=i%>] = 'h0000_0800; 
                    ['d49:'d49]: tubr[<%=i%>] = 'h0000_1000; 
                    ['d50:'d50]: tubr[<%=i%>] = 'h0000_2000; 
                    ['d51:'d51]: tubr[<%=i%>] = 'h0000_4000; 
                    ['d52:'d52]: tubr[<%=i%>] = 'h0000_8000; 
                    ['d53:'d53]: tubr[<%=i%>] = 'h0001_0000; 
                    ['d54:'d54]: tubr[<%=i%>] = 'h0002_0000; 
                    ['d55:'d55]: tubr[<%=i%>] = 'h0004_0000; 
                    ['d56:'d56]: tubr[<%=i%>] = 'h0008_0000; 
                    ['d57:'d57]: tubr[<%=i%>] = 'h0010_0000; 
                    ['d58:'d58]: tubr[<%=i%>] = 'h0020_0000; 
                    ['d59:'d59]: tubr[<%=i%>] = 'h0040_0000; 
                    ['d60:'d60]: tubr[<%=i%>] = 'h0080_0000; 
                    ['d61:'d61]: tubr[<%=i%>] = 'h0100_0000; 
                    ['d62:'d62]: tubr[<%=i%>] = 'h0200_0000; 
                    ['d63:'d63]: tubr[<%=i%>] = 'h0400_0000; 
                    ['d64:'d64]: tubr[<%=i%>] = 'h0800_0000; 
                    ['d65:'d65]: tubr[<%=i%>] = 'h1000_0000; 
                    ['d66:'d66]: tubr[<%=i%>] = 'h2000_0000; 
                    ['d67:'d67]: tubr[<%=i%>] = 'h4000_0000; 
                    ['d68:'d68]: tubr[<%=i%>] = 'h8000_0000; 
                    ['d69:'d74]: tubr[<%=i%>] = 'hffff_ffff; 
                    ['d75:'d79]: tubr[<%=i%>] = $urandom_range('hffff_ffff,'hffff_fff0);
                    default :    tubr[<%=i%>] = $urandom_range('hffff_ffff,'h0000_0000); // unconstrained
                endcase
            end : tubr_weighted_randomization


            if (($test$plusargs("ioaiu_cctrlr_mod")) && ($test$plusargs("ioaiu_tubmr<%=i%>_val")) && 
                (ioaiu_cctrlr_phase==2)) begin
                tubmr[<%=i%>] = ioaiu_tubmr<%=i%>_val; 
            end else if($test$plusargs("trigger_random")) begin
                tubmr[<%=i%>] = $urandom();
            end else if($value$plusargs("tubmr_value=%0x", tubmr[<%=i%>])) begin
                // user-specified tubmr
            end else begin : tubmr_weighted_randomization
                case ($urandom_range(100,1)) inside
                    ['d01:'d20]: tubmr[<%=i%>] = 'h0000_0000; 
                    ['d21:'d40]: tubmr[<%=i%>] = $urandom_range('hf,'h0);
                    ['d41:'d41]: tubmr[<%=i%>] = 'h0000_0010; 
                    ['d42:'d42]: tubmr[<%=i%>] = 'h0000_0020; 
                    ['d43:'d43]: tubmr[<%=i%>] = 'h0000_0040; 
                    ['d44:'d44]: tubmr[<%=i%>] = 'h0000_0080; 
                    ['d45:'d45]: tubmr[<%=i%>] = 'h0000_0100; 
                    ['d46:'d46]: tubmr[<%=i%>] = 'h0000_0200; 
                    ['d47:'d47]: tubmr[<%=i%>] = 'h0000_0400; 
                    ['d48:'d48]: tubmr[<%=i%>] = 'h0000_0800; 
                    ['d49:'d49]: tubmr[<%=i%>] = 'h0000_1000; 
                    ['d50:'d50]: tubmr[<%=i%>] = 'h0000_2000; 
                    ['d51:'d51]: tubmr[<%=i%>] = 'h0000_4000; 
                    ['d52:'d52]: tubmr[<%=i%>] = 'h0000_8000; 
                    ['d53:'d53]: tubmr[<%=i%>] = 'h0001_0000; 
                    ['d54:'d54]: tubmr[<%=i%>] = 'h0002_0000; 
                    ['d55:'d55]: tubmr[<%=i%>] = 'h0004_0000; 
                    ['d56:'d56]: tubmr[<%=i%>] = 'h0008_0000; 
                    ['d57:'d57]: tubmr[<%=i%>] = 'h0010_0000; 
                    ['d58:'d58]: tubmr[<%=i%>] = 'h0020_0000; 
                    ['d59:'d59]: tubmr[<%=i%>] = 'h0040_0000; 
                    ['d60:'d60]: tubmr[<%=i%>] = 'h0080_0000; 
                    ['d61:'d61]: tubmr[<%=i%>] = 'h0100_0000; 
                    ['d62:'d62]: tubmr[<%=i%>] = 'h0200_0000; 
                    ['d63:'d63]: tubmr[<%=i%>] = 'h0400_0000; 
                    ['d64:'d64]: tubmr[<%=i%>] = 'h0800_0000; 
                    ['d65:'d65]: tubmr[<%=i%>] = 'h1000_0000; 
                    ['d66:'d66]: tubmr[<%=i%>] = 'h2000_0000; 
                    ['d67:'d67]: tubmr[<%=i%>] = 'h4000_0000; 
                    ['d68:'d68]: tubmr[<%=i%>] = 'h8000_0000; 
                    ['d69:'d74]: tubmr[<%=i%>] = 'hffff_ffff; 
                    ['d75:'d79]: tubmr[<%=i%>] = $urandom_range('hffff_ffff,'hffff_fff0);
                    default :    tubmr[<%=i%>] = $urandom_range('hffff_ffff,'h0000_0000); // unconstrained
                endcase
            end : tubmr_weighted_randomization

            // zero out bits that should not exist in the RTL for this particular config
            <% if(!computedAxiInt.params.eTrace) {%> // if eTrace is 0 or null
                tctrlr[<%=i%>].native_trace_en = 1'b0; // no native trace for this bus type
            <%}%>
            <% if(obj.DutInfo.fnNativeInterface == "AXI4" || obj.DutInfo.fnNativeInterface == "AXI5"){%>
                tctrlr[<%=i%>].opcode_match_en = 1'b0;
            <%}%>
            <% if(computedAxiInt.params.wAwUser == 0) {%>
                tctrlr[<%=i%>].user_match_en = 1'b0; // no user_match_en if zero user bits
            <%}%>

            //uvm_config_db#(int)::get(null, "", "ioaiu_cctrlr_phase", ioaiu_cctrlr_phase);
            if (ioaiu_cctrlr_phase==1) begin
               tctrlr[<%=i%>]   = 32'h0;
               tubmr[<%=i%>]    = 32'h0; 
               tubr[<%=i%>]     = 32'h0; 
               topcr0[<%=i%>]   = 32'h0; 
               topcr1[<%=i%>]   = 32'h0; 
               tbalr[<%=i%>]    = 32'h0; 
               tbahr[<%=i%>]    = 32'h0; 

              `uvm_info(get_name(), $sformatf("All Trace Regs have been reset as ioaiu_cctrlr_phase=1."), UVM_HIGH)
            end

            // write register values to RTL
            <% if(computedAxiInt.params.eTrace) {%> // if eTrace is 0 or null
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR'+i+'.native_trace_en')%>, tctrlr[<%=i%>].native_trace_en);
            <%}%>
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR'+i+'.addr_match_en')%>, tctrlr[<%=i%>].addr_match_en);
            <% if(obj.DutInfo.fnNativeInterface != "AXI4" && obj.DutInfo.fnNativeInterface != "AXI5"){%>
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR'+i+'.opcode_match_en')%>, tctrlr[<%=i%>].opcode_match_en);
            <%}%>
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR'+i+'.memattr_match_en')%>, tctrlr[<%=i%>].memattr_match_en);
            <% if(computedAxiInt.params.wAwUser > 0) {%>
              write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR'+i+'.user_match_en')%>, tctrlr[<%=i%>].user_match_en);
            <%}%>

            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR'+i+'.target_type_match_en')%>, tctrlr[<%=i%>].target_type_match_en);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR'+i+'.hut')%>, tctrlr[<%=i%>].hut);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR'+i+'.hui')%>, tctrlr[<%=i%>].hui);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR'+i+'.range')%>, tctrlr[<%=i%>].range);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR'+i+'.aw')%>, tctrlr[<%=i%>].aw);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR'+i+'.ar')%>, tctrlr[<%=i%>].ar);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR'+i+'.memattr')%>, tctrlr[<%=i%>].memattr);

            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTBALR'+i+'.base_addr_lo')%>, tbalr[<%=i%>].base_addr_43_12);

            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTBAHR'+i+'.base_addr_hi')%>, tbahr[<%=i%>].base_addr_51_44);

            topcr0[<%=i%>].opcode1 = topcr0[<%=i%>].opcode1; 
            topcr0[<%=i%>].opcode2 = topcr0[<%=i%>].opcode2;
            topcr1[<%=i%>].opcode3 = topcr1[<%=i%>].opcode3;
            topcr1[<%=i%>].opcode4 = topcr1[<%=i%>].opcode4;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR0'+i+'.opcode1')%>, topcr0[<%=i%>].opcode1);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR0'+i+'.valid1')%>,  topcr0[<%=i%>].valid1);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR0'+i+'.opcode2')%>, topcr0[<%=i%>].opcode2);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR0'+i+'.valid2')%>,  topcr0[<%=i%>].valid2);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR1'+i+'.opcode3')%>, topcr1[<%=i%>].opcode3);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR1'+i+'.valid3')%>,  topcr1[<%=i%>].valid3);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR1'+i+'.opcode4')%>, topcr1[<%=i%>].opcode4);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR1'+i+'.valid4')%>,  topcr1[<%=i%>].valid4);

            <% if(computedAxiInt.params.wAwUser > 0) {%>
            tubr[<%=i%>].user = tubr[<%=i%>].user & {<%=computedAxiInt.params.wAwUser%>{1'b1}};
            tubmr[<%=i%>].user_mask = tubmr[<%=i%>].user_mask & {<%=computedAxiInt.params.wAwUser%>{1'b1}};
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTUBR'+i+'.user')%>, tubr[<%=i%>].user);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTUBMR'+i+'.user_mask')%>, tubmr[<%=i%>].user_mask);
            <% } else { %>
            tubr[<%=i%>].user = 0;
            tubmr[<%=i%>].user_mask = 0;
            <%}%>

            // pass register values to the scoreboard.
            m_trace_trigger.TCTRLR_write_reg(<%=i%>,tctrlr[<%=i%>]);
            m_trace_trigger.TBALR_write_reg(<%=i%>,tbalr[<%=i%>]);
            m_trace_trigger.TBAHR_write_reg(<%=i%>,tbahr[<%=i%>]);
            m_trace_trigger.TOPCR0_write_reg(<%=i%>,topcr0[<%=i%>]);
            m_trace_trigger.TOPCR1_write_reg(<%=i%>,topcr1[<%=i%>]);
            m_trace_trigger.TUBR_write_reg(<%=i%>,tubr[<%=i%>]);
            m_trace_trigger.TUBMR_write_reg(<%=i%>,tubmr[<%=i%>]);
            m_trace_trigger.print_trigger_sets_reg_values();

            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: tctrlr[<%=i%>]                    = %8h", tctrlr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: tbalr[<%=i%>]                     = %8h", tbalr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: tbahr[<%=i%>]                     = %8h", tbahr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: topcr0[<%=i%>]                    = %8h", topcr0[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: topcr1[<%=i%>]                    = %8h", topcr1[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: tubr[<%=i%>]                      = %8h", tubr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: tubmr[<%=i%>]                     = %8h", tubmr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_match_en_rand         = %6b",  trace<%=i%>_match_en_rand), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_native_match_en       = %b",  trace<%=i%>_native_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_addr_match_en         = %b",  trace<%=i%>_addr_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_opcode_match_en       = %b",  trace<%=i%>_opcode_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_memattr_match_en      = %b",  trace<%=i%>_memattr_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_user_match_en         = %b",  trace<%=i%>_user_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_target_type_match_en  = %b",  trace<%=i%>_target_type_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: match_en native       = %b, addr = %b, opcode = %b, memattr = %b, user = %b, target_type = %b", trace<%=i%>_native_match_en, trace<%=i%>_addr_match_en, trace<%=i%>_opcode_match_en, trace<%=i%>_memattr_match_en, trace<%=i%>_user_match_en, trace<%=i%>_target_type_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_addr_match_size       = %h", trace<%=i%>_addr_match_size), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_memattr_match_value   = %h", trace<%=i%>_memattr_match_value), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_memattr_match_ar      = %b", trace<%=i%>_memattr_match_ar), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_memattr_match_aw      = %b", trace<%=i%>_memattr_match_aw), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_opcode_valids_rand    = %4b", trace<%=i%>_opcode_valids_rand), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_opcode1               = %4h", trace<%=i%>_opcode1), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_opcode2               = %4h", trace<%=i%>_opcode2), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_opcode3               = %4h", trace<%=i%>_opcode3), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_opcode4               = %4h", trace<%=i%>_opcode4), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_target_type_match_hut = %b", trace<%=i%>_target_type_match_hut), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: core<%=obj.multiPortCoreId%>: trace<%=i%>_target_type_match_hui = %5h", trace<%=i%>_target_type_match_hui), UVM_HIGH)

        end : ttrig_reg_prog_en_code_<%=i%>
        <%}%>

        if ($test$plusargs("tcap_reg_prog_en")) begin : tcap_reg_prog_en_code
            bit [31:0] set_value = 0;
            bit [7:0]  smi_cap   = 0;
            bit [3:0]  gain      = 0;
            bit [11:0] inc       = 0;

            if (($test$plusargs("ioaiu_cctrlr_mod")) && ($test$plusargs("ioaiu_cctrlr_val")) &&
                (ioaiu_cctrlr_phase==2)) begin
                smi_cap = ioaiu_cctrlr_val[7:0];
                gain    = ioaiu_cctrlr_val[19:16];
                inc     = ioaiu_cctrlr_val[31:20];
            end else if ($test$plusargs("cctrlr_random")) begin
                if (<%=obj.multiPortCoreId%> == 0) begin
                	std::randomize(smi_cap);
                	std::randomize(gain);
                	std::randomize(inc);
                	uvm_config_db#(bit[7:0])::set(null,"*","tcap_smi_cap", smi_cap);
                  	uvm_config_db#(bit[3:0])::set(null,"*","tcap_gain", gain);
                  	uvm_config_db#(bit[11:0])::set(null,"*","tcap_inc", inc);
				end else begin
                  	uvm_config_db#(bit[7:0])::get(null,"*","tcap_smi_cap", smi_cap);
                  	uvm_config_db#(bit[3:0])::get(null,"*","tcap_gain", gain);
                  	uvm_config_db#(bit[11:0])::get(null,"*","tcap_inc", inc);
				end

                `uvm_info(get_name(), $sformatf("<%=obj.DutInfo.strRtlNamePrefix%> Set CCRTRLR to random values. SMI_CAPT=%0h, GAIN=%0d, VALUE=%0d", smi_cap, gain, inc), UVM_HIGH)					
            end else if ($value$plusargs("cctrlr_value=0x%0h", set_value)) begin
                smi_cap      = set_value[7:0];
                gain         = set_value[19:16];
                inc          = set_value[31:20];
                `uvm_info(get_name(), $sformatf("<%=obj.DutInfo.strRtlNamePrefix%> Set CCRTRLR through cmdln=%0h. SMI_CAPT=%0h, GAIN=%0d, INC=%0d", set_value, smi_cap, gain, inc), UVM_HIGH)
            end else begin : weighted_random
                if (<%=obj.multiPortCoreId%> == 0) begin
                	if ($value$plusargs("cctrlr_enables=0x%0h", smi_cap)) begin
                	  // user-specified smi_cap
                	end else begin : cctrlr_enables_weighted_random
                	  case ($urandom_range(100,1)) inside
                	    ['d01:'d10]: smi_cap = 'hff; // all on DMI
                	    ['d11:'d20]: smi_cap = 'hcf; // all on IOAIU
                	    ['d21:'d22]: smi_cap = 'h01; // try one at a time
                	    ['d23:'d24]: smi_cap = 'h02;
                	    ['d25:'d26]: smi_cap = 'h04;
                	    ['d27:'d28]: smi_cap = 'h08;
                	    ['d29:'d30]: smi_cap = 'h10;
                	    ['d31:'d32]: smi_cap = 'h20;
                	    ['d33:'d34]: smi_cap = 'h40;
                	    ['d35:'d36]: smi_cap = 'h80;
                	    ['d37:'d70]: smi_cap = 'h00; // all off
                	    default :    smi_cap = $urandom_range('hff,'h00); // unconstrained
                	  endcase

                	end : cctrlr_enables_weighted_random
                	if ($value$plusargs("cctrlr_gain=0x%0h", gain)) begin
                	  // user-specified gain
                	end else begin : cctrlr_gain_weighted_random 
                	  case ($urandom_range(100,1)) inside
                	    ['d01:'d50]: gain = 'h0; // disables TS corrections
                	    default :    gain = $urandom_range('hf,'h0); // unconstrained
                	  endcase
                	end : cctrlr_gain_weighted_random
                	if ($value$plusargs("cctrlr_inc_integer=0x%0h", inc[11:8])) begin
                	  // user-specified inc integer
                	end else begin : cctrlr_inc_integer_weighted_random 
                	  case ($urandom_range(100,1)) inside
                	    ['d01:'d25]: inc[11:8] = 'h0;
                	    ['d26:'d50]: inc[11:8] = 'hf;
                	    default :    inc[11:8] = $urandom_range('hf,'h0); // unconstrained
                	  endcase
                	end : cctrlr_inc_integer_weighted_random
                	if ($value$plusargs("cctrlr_inc_fractional=0x%0h", inc[7:0])) begin
                	  // user-specified inc fractional
                	end else begin : cctrlr_inc_fractional_weighted_random 
                	  case ($urandom_range(100,1)) inside
                	    ['d01:'d05]: inc[7:0] = 'h00;
                	    ['d06:'d10]: inc[7:0] = 'h01;
                	    ['d11:'d15]: inc[7:0] = 'h02;
                	    ['d16:'d20]: inc[7:0] = 'h04;
                	    ['d21:'d25]: inc[7:0] = 'h08;
                	    ['d26:'d30]: inc[7:0] = 'h10;
                	    ['d31:'d35]: inc[7:0] = 'h20;
                	    ['d36:'d40]: inc[7:0] = 'h40;
                	    ['d41:'d45]: inc[7:0] = 'h80;
                	    ['d46:'d60]: inc[7:0] = 'hff;
                	    default :    inc[7:0] = $urandom_range('hff,'h00); // unconstrained
                	  endcase
                	end : cctrlr_inc_fractional_weighted_random
                  	uvm_config_db#(bit[7:0])::set(null,"*","tcap_smi_cap", smi_cap);
                  	uvm_config_db#(bit[3:0])::set(null,"*","tcap_gain", gain);
                  	uvm_config_db#(bit[11:0])::set(null,"*","tcap_inc", inc);
				end else begin
                  	uvm_config_db#(bit[7:0])::get(null,"*","tcap_smi_cap", smi_cap);
                  	uvm_config_db#(bit[3:0])::get(null,"*","tcap_gain", gain);
                  	uvm_config_db#(bit[11:0])::get(null,"*","tcap_inc", inc);
				end
            end : weighted_random

            uvm_config_db#(int)::get(null, "*", "ioaiu_cctrlr_phase", ioaiu_cctrlr_phase);
            if ($test$plusargs("ioaiu_cctrlr_mod") && (ioaiu_cctrlr_phase != 0)) begin
                // CCTRLR[7:0] are updated
                smi_cap = (ioaiu_cctrlr_phase==2) ? smi_cap : 0;
                tctrlr[<%=i%>] = (ioaiu_cctrlr_phase==2) ? tctrlr[<%=i%>] : 0;
            end

            write_data = (smi_cap >> 0) & 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn0Tx')%>, write_data);
            trace_debug_scb::port_capture_en[0] = write_data ? (smi_cap[0] | 'b1) : (smi_cap[0] & 'b0);

            write_data = (smi_cap >> 1) & 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn0Rx')%>, write_data);
            trace_debug_scb::port_capture_en[1] = write_data ? (smi_cap[1] | 'b1) : (smi_cap[1] & 'b0);

            write_data = (smi_cap >> 2) & 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn1Tx')%>, write_data);
            trace_debug_scb::port_capture_en[2] = write_data ? (smi_cap[2] | 'b1) : (smi_cap[2] & 'b0);

            write_data = (smi_cap >> 3) & 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn1Rx')%>, write_data);
            trace_debug_scb::port_capture_en[3] = write_data ? (smi_cap[3] | 'b1) : (smi_cap[3] & 'b0);

            write_data = (smi_cap >> 4) & 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn2Tx')%>, write_data);
            trace_debug_scb::port_capture_en[4] = write_data ? (smi_cap[4] | 'b1) : (smi_cap[4] & 'b0);

            write_data = (smi_cap >> 5) & 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn2Rx')%>, write_data);
            trace_debug_scb::port_capture_en[5] = write_data ? (smi_cap[5] | 'b1) : (smi_cap[5] & 'b0);

            write_data = (smi_cap >> 6) & 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.dn0Tx')%> , write_data);
            trace_debug_scb::port_capture_en[6] = write_data ? (smi_cap[6] | 'b1) : (smi_cap[6] & 'b0);

            write_data = (smi_cap >> 7) & 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.dn0Rx')%> , write_data);
            trace_debug_scb::port_capture_en[7] = write_data ? (smi_cap[7] | 'b1) : (smi_cap[7] & 'b0);

            write_data = gain;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.gain')%>  , write_data);
            trace_debug_scb::gain = write_data;

            write_data = inc;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.inc')%>   , write_data);
            trace_debug_scb::inc = write_data;

        end : tcap_reg_prog_en_code

        //trigger event to notify trace trigger csr programming is done.
        ev_<%=obj.multiPortCoreId%>.trigger();
        if ($test$plusargs("ttrig_reg_prog_en")) begin
            csr_trace_debug_done.trigger(null);
        end

       	if (($test$plusargs("wrong_DtwDbg_rsp_target_id")) || ($test$plusargs("dtw_dbg_rsp_err_inj_uc")) || ($test$plusargs("dtw_dbg_rsp_err_inj_c")) || ($test$plusargs("inject_parity_err_cr_chnl"))|| ($test$plusargs("inject_parity_err_w_chnl")) || ($test$plusargs("inject_parity_err_ar_chnl")) || ($test$plusargs("inject_parity_err_aw_chnl")))begin
	<% if(obj.useResiliency) { %>
	   if($test$plusargs("dtw_dbg_rsp_err_inj_c"))begin
              write_data = 0;
              write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCRTR.ResThreshold')%>, write_data);
	   end
	   <%}%>
	  
                           ev_<%=obj.multiPortCoreId%>.trigger();
		if ($test$plusargs("wrong_DtwDbg_rsp_target_id")) 
                do begin
                @(posedge m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.clk);
                end while (((m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_type) != eConcMsgDtwDbgRsp) || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_type) == eConcMsgDtwDbgRsp) && (m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_targ_id[WSMITGTID-1-WSMINCOREPORTID:0] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))))));                   
		else if (($test$plusargs("dtw_dbg_rsp_err_inj_uc")) || ($test$plusargs("dtw_dbg_rsp_err_inj_c")))
                do begin
                    @(posedge m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.clk);
      		<%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
        	end while (m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.dtw_dbg_rsp_ready_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.dtw_dbg_rsp_valid_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_type) != eConcMsgDtwDbgRsp)));
        	<%} else {%>
        	end while (m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_type) != eConcMsgDtwDbgRsp)));
        	 <% } %>
		if ($test$plusargs("wrong_DtwDbg_rsp_target_id")) begin
                errinfo[0] = 1'b0; //0 for wrong targ_id
		end else begin
                errinfo[0] = 1'b1; //1 for SMI Protection
		end
		if (!($test$plusargs("dtw_dbg_rsp_err_inj_c")))begin 
                errinfo[7:1] = 0; //Resereved
                errinfo[19:8] = m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
		if ($test$plusargs("wrong_DtwDbg_rsp_target_id")) begin
                errinfo_check = 1;
		end else begin
                errinfo_check = 0;
		end
                if($value$plusargs("inject_parity_err_cr_chnl=%0s",name)||$value$plusargs("inject_parity_err_aw_chnl=%0s",name)||$value$plusargs("inject_parity_err_ar_chnl=%0s",name)||$value$plusargs("inject_parity_err_w_chnl=%0s",name))begin
                  errinfo = 0;
                  if(name== "AWTRACE_CHK")begin 
                    data=9;
                    errinfo[3:0] = 4'b0001;
                   end
                  if(name== "ARTRACE_CHK")begin 
                    data=21; 
                    errinfo[3:0] = 4'b0000;
                  end
                  if(name== "WTRACE_CHK")begin
                    data=27;
                    errinfo[3:0] = 4'b0010;
                  end
                 if(name== "CRTRACE_CHK")begin  
                   data=29;
                   errinfo[3:0] = 4'b0101;
                 end
                end
                
                erraddr_check = 0;
		uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type",eConcMsgDtwDbgRsp); //for coverage
                //#Check.IOAIU.WrongTargetId.ErrVld
		<% if(obj.useResiliency) { %>
                //#Check.IOAIU.Parity.mission_fault
		fork
	           begin
                       wait(u_csr_probe_vif.fault_mission_fault==1);
                       `uvm_info("RUN_MAIN","fault_mission_fault is asserted", UVM_NONE) 
	           end
		   begin
		       #200000ns;
                       `uvm_error("RUN_MAIN","fault_mission_fault isn't asserted")
	           end
       join_any
      disable fork;
      uvm_config_db#(int)::set(null,"*","ioaiu_fault_mission_fault",u_csr_probe_vif.fault_mission_fault);
      <%}%>
                if(dis_uedr_ted_4resiliency) begin
                `uvm_info(get_full_name(),$sformatf("Skipping-1 enabling of error detection inside xUEDR"),UVM_NONE)
                end
                else begin 
                //#Check.IOAIU.Parity.ErrVld
                poll_UUESR_ErrVld(1, poll_data);
		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data); 
                uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_vld",read_data);
                // wait for IRQ_UC interrupt 
                fork
     	        begin
                //#Check.IOAIU.WrongTargetId.IRQ_UC
                  if($test$plusargs("inject_parity_err_cr_chnl")||$test$plusargs("inject_parity_err_w_chnl")||$test$plusargs("inject_parity_err_ar_chnl")||$test$plusargs("inject_parity_err_aw_chnl"))begin
                    if( Intf_Check_Err_Int_En == 1)begin
                      wait (u_csr_probe_vif.IRQ_UC === 1);
                    end
                  end else begin
                     wait (u_csr_probe_vif.IRQ_UC === 1);
                  end
                end
                begin
                #200000ns;
                `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
                end
                join_any
                disable fork;
                if($test$plusargs("inject_parity_err_cr_chnl")||$test$plusargs("inject_parity_err_w_chnl")||$test$plusargs("inject_parity_err_ar_chnl")||$test$plusargs("inject_parity_err_aw_chnl"))begin
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data_type);
                //#Check.IOAIU.Parity.ErrType
                compareValues("UUESR_ErrType","Valid Type", read_data_type, errtype);
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data_info);
                //#Check.IOAIU.Parity.ErrInfo
                compareValues("UUESR_ErrInfo","Valid Type",read_data_info, errinfo);
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>,read_data_valid);
	        cov.collect_parity_err(read_data_type,read_data_info,Intf_Check_Err_Det_En,<% if(obj.useResiliency) { %>u_csr_probe_vif.fault_mission_fault <%}else {%> 0 <%}%>,data);

                end else begin
      		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
                compareValues("UUESR_ErrType","Valid Type", read_data, errtype);
		uvm_config_db#(int)::set(null,"*","ioaiu_wrong_target_id_uesr_err_type",read_data); //for coverage
		uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_type",read_data); //for coverage
                //#Check.IOAIU.WrongTargetId.ErrType
               //if (errinfo_check) begin	//CONC-12675
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
		uvm_config_db#(int)::set(null,"*","ioaiu_wrong_target_id_uesr_err_info",read_data); //for coverage
	        uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_info",read_data); //for coverage
                //#Check.IOAIU.WrongTargetId.ErrInfo
                if(!$test$plusargs("smi_hdr_err_inj"))
                compareValues("UUESR_ErrInfo","Valid Type", read_data, errinfo);
               //end
                write_data = 0;
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.TransErrDetEn')%>, write_data); 
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.TransErrIntEn')%>, write_data);
                write_data = 1;
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data); 
                compareValues("UUESR_ErrVld","should be", read_data, 0); 
      	//	read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
        //        //#Check.IOAIU.SMIProtectionType.ErrType
      	//	compareValues("UUESR_ErrType","Valid Type", read_data, 0);
        //        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
        //        //#Check.IOAIU.SMIProtectionType.ErrInfo
        //        compareValues("UUESR_ErrInfo","Valid Type", read_data, 0);
		cov.collect_uncorrectable_error(<%=obj.multiPortCoreId%>);
                end
		end
		end else
		begin 
		errinfo[19:16] = 4'b0; 
		errinfo[15:6] = m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
		errinfo[5:0] = 6'b0; 
		errinfo_check = 0;
		uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type",eConcMsgDtwDbgRsp); //for coverage
	        <% if(obj.useResiliency) { %>
                 fork
                              begin
                                  wait(u_csr_probe_vif.cerr_over_thres_fault==1);
                                  `uvm_info("RUN_MAIN","fault_thres_fault is asserted", UVM_NONE) 
                              end
                   	   begin
                   	       #200000ns;
                                  `uvm_error("RUN_MAIN","fault_thres_fault isn't asserted")
                              end
                  join_any
                 disable fork;
                 uvm_config_db#(int)::set(null,"*","ioaiu_fault_thres_fault",u_csr_probe_vif.cerr_over_thres_fault);
                 <%}%>
                if(dis_uedr_ted_4resiliency) begin
                 `uvm_info(get_full_name(),$sformatf("Skipping-1 enabling of error detection inside xUEDR"),UVM_NONE)
                 end
                 else begin
	       	poll_UCESR_ErrVld(1, poll_data);
	        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data); 
                uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_vld",read_data);	
	     	// wait for IRQ_C interrupt 
	     	fork
	     	begin
	     	    //#Check.IOAIU.SMIProtectionType.IRQ_C
	     	    wait (u_csr_probe_vif.IRQ_C === 1);
	     	end
	     	begin
	     	  #2000ns;
	     	  `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C asserted"));
		end
		join_any
		disable fork;
		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrType')%>, read_data);
		compareValues("UCESR_ErrType","Valid Type", read_data, errtype);
		uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_cesr_err_type",read_data); //for coverage
		if (errinfo_check) begin
		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrInfo')%>, read_data);
		uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_cesr_err_type",read_data); //for coverage
		compareValues("UCESR_ErrInfo","Valid Type", read_data, errinfo);
		end
		write_data = 0;
		write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
		write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
		write_data = 1;
		write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, write_data);
		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCount')%>, read_data);
      		compareValues("UCESR_ErrVld","should be", read_data, 0);
		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
      		compareValues("UCESR_ErrVld","should be", read_data, 0);
		cov.collect_uncorrectable_error(<%=obj.multiPortCoreId%>);
		end
		end
           
        end
    endtask : body

endclass : ioaiu_csr_trace_debug_seq_<%=obj.multiPortCoreId%>

class csr_connectivity_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
   `uvm_object_utils(csr_connectivity_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, write_data;
    bit [WSMIADDR-1:0] exp_addr;
    bit [WSMIADDR-1:0] erraddr_q[$];
    bit [WSMIADDR-1:0]actual_addr;
    bit [19:0] err_entry;
    bit [5:0] err_way;
    bit [5:0] err_word;
    bit [19:0] err_addr;
    bit [31:0] err_addr0;

    bit [19:0] exp_errinfo;
    bit [19:0] errinfo_q[$];
    bit cmdType;
    axi_arid_t txn_id;
    int addr_idx;
    ioaiu_scoreboard ioaiu_scb;
    bit dec_err_det_en, dec_err_int_en, sof_err_det_en,sof_err_int_en;

    function new(string name="");
        super.new(name);
    endfunction
   
  task body();
      getCsrProbeIf();
      erraddr_q.delete();
      errinfo_q.delete();

      if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                                 .inst_name( "*" ),
                                                 .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                                 .value( ioaiu_scb ))) begin
          `uvm_error("ioaiu_csr_time_out_error_seq", "ioaiu_scb model not found")
      end

      if($test$plusargs("addr_no_hit_check")) begin
      dec_err_det_en = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.DecErrDetEn')%>, dec_err_det_en); 

      dec_err_int_en = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.DecErrIntEn')%>, dec_err_int_en);
      end else begin
      sof_err_det_en = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.SoftwareProgConfigErrEn')%>, sof_err_det_en); 
      //#Cover.IOAIU.Smi.UncorrectableErr 
      sof_err_int_en = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.SoftwareProgConfigErrIntEn')%>, sof_err_int_en);
      end

      ev_<%=obj.multiPortCoreId%>.trigger();
      
      if (dec_err_det_en || sof_err_det_en) begin
 
          //keep on Reading the UUESR_ErrVld bit = 1
          poll_UUESR_ErrVld(1, poll_data);

   
          //foreach (ioaiu_scb.csr_addr_decode_err_addr_q[i]) begin
          if($test$plusargs("addr_no_hit_check")) begin
          for (int i=0; i < ioaiu_scb.csr_addr_decode_err_addr_q.size(); i++) begin
              exp_addr = ioaiu_scb.csr_addr_decode_err_addr_q[i];
              exp_errinfo[3:0] = ioaiu_scb.csr_addr_decode_err_type_q[i];
              exp_errinfo[5:4] = ioaiu_scb.csr_addr_decode_err_cmd_type_q[i];
              exp_errinfo[7:6] = 0; //Reserved
              exp_errinfo[19:8] = ioaiu_scb.csr_addr_decode_err_msg_id_q[i];
              errinfo_q.push_back(exp_errinfo);
              erraddr_q.push_back(exp_addr);
          end
          
          `uvm_info(get_full_name(),$sformatf("erraddr_q = %0p, errinfo_q = %0p",erraddr_q,errinfo_q),UVM_NONE)

          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
          if (!(read_data inside {errinfo_q})) begin
              `uvm_error(get_full_name(),$sformatf("Expected error info should be inside %0p, Actual ErrInfo = %0h",errinfo_q,read_data))
          end

          txn_id = read_data[19:8]; // Transaction ID
          cmdType = read_data[5:4];   // Command Type (Write/Read)
          foreach (errinfo_q[i]) begin
              //$display("KDB foreach loop i=%0d errinfo_q_txnid=%0h, errinfo_q_cmdtype=%0h, errinfo_q_errtype=%0h", i, errinfo_q[i][15:6], errinfo_q[i][4], errinfo_q[i][2:0]);
              if(errinfo_q[i][19:8] == read_data[19:8] && errinfo_q[i][5:4] == cmdType) begin
                  exp_errinfo = errinfo_q[i];
                  exp_addr = erraddr_q[i];
                  break;
              end
          end
          end else begin
           for (int i=0; i < ioaiu_scb.csr_addr_decode_err_addr_q.size(); i++) begin
               exp_addr = ioaiu_scb.csr_addr_decode_err_addr_q[i];
              exp_errinfo[19:4] = 0; 
              exp_errinfo[3:0] = ioaiu_scb.csr_addr_decode_err_type_q[i];
              errinfo_q.push_back(exp_errinfo);
              erraddr_q.push_back(exp_addr);
          end
         end

                  

          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrAddr')%>, err_addr0);
//        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrEntry')%>, err_entry);
//        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWay')%>,err_way);
//        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWord')%>, err_word);
          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR1.ErrAddr')%>, err_addr);
          actual_addr = {err_addr,err_addr0};
           if (!(actual_addr inside {erraddr_q})) begin
                    `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, exp_addr))
            end

           if(!$test$plusargs("addr_no_hit_check")) begin
           for(int i=0; i<erraddr_q.size(); i++) begin
           if(actual_addr == erraddr_q[i]) begin
           exp_errinfo[3:0] =  errinfo_q[i];
           break;
           end
           end
           end
      
           //#Check.IOAIU.v3.4.Connectivity.ErrorLogging
          //#Check.IOAIU.Software.ErrorLogging          
          if     ($test$plusargs("dce_connectivity_check"))   exp_errinfo[3:0] = 4'b0101; // unconnected DCE unit access
          else if($test$plusargs("dmi_connectivity_check"))   exp_errinfo[3:0] = 4'b0010; // unconnected DMI unit access
          else if($test$plusargs("dii_connectivity_check"))   exp_errinfo[3:0] = 4'b0011; // unconnected DII unit access
          else if($test$plusargs("addr_no_hit_check"))        exp_errinfo[3:0] = 4'b0000; // No address hit
          else if($test$plusargs("no_credit_check"))          exp_errinfo[3:0] = 4'b0001; // Zero credits configured

          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
          uvm_config_db#(int)::set(null,"*","ioaiu_software_uesr_err_info",read_data); //for coverage
	  //$display("KDB exp_errinfo_txnid=%0h, exp_errinfo_cmdtype=%0h, exp_errinfo_errtype=%0h \n csr_read_data=%0h",exp_errinfo[15:6], exp_errinfo[4], exp_errinfo[2:0], read_data);
          compareValues("XAIUUESR_ErrInfo", "", read_data, exp_errinfo); 
	  read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
          uvm_config_db#(int)::set(null,"*","ioaiu_software_uesr_err_type",read_data); //for coverage
          if($test$plusargs("addr_no_hit_check"))
          compareValues("XAIUUESR_ErrType", "", read_data, 'h7); //Decode Error
          else
          compareValues("XAIUUESR_ErrType", "", read_data, 'hC); //Software Error
         

          fork : irq_fork
              begin
                if (dec_err_int_en || sof_err_int_en) begin
                  wait (u_csr_probe_vif.IRQ_UC === 1);
                end
              end
              begin
                  #200000ns;
                  `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
              end
          join_any
          disable irq_fork;

      end

      //#Stimulus.IOAIU.v3.4.Connectivity.ErrDetEnErrDetInt
      write_data = 0;
      if($test$plusargs("addr_no_hit_check")) begin
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.DecErrDetEn')%>, write_data); 
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.DecErrIntEn')%>, write_data);
      end else begin
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.SoftwareProgConfigErrEn')%>, write_data); 
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.SoftwareProgConfigErrIntEn')%>, write_data);
      end
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
      // Read the XAIUUESR_ErrVld should be cleared
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
      compareValues("XAIUUESR_ErrVld", "now clear", read_data, 0);


    endtask
endclass : csr_connectivity_seq_<%=obj.multiPortCoreId%>




class csr_credit_sw_mgr_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
  `uvm_object_utils(csr_credit_sw_mgr_seq_<%=obj.multiPortCoreId%>)

   uvm_reg_data_t poll_data, read_data, write_data;
   int coreId;
   ioaiu_scoreboard ioaiu_scb;

   function new(string name="");
       super.new(name);
   endfunction
  
 task body();
     getCsrProbeIf();
     get_env_handle();
     get_mp_env_handle();
     get_m_env_cfg_handle();

     if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                                .inst_name( "*" ),
                                                .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                                .value( ioaiu_scb ))) begin
         `uvm_error("ioaiu_csr_time_out_error_seq", "ioaiu_scb model not found")
     end

    ev_<%=obj.multiPortCoreId%>.trigger();
    
    //#Check.IOAIU.v3.4.SCM.CounterState
    `uvm_info(get_name(), $sformatf("CSR Credit SW MGR Launched"), UVM_LOW)
    <%for (j=0; j< obj.nDCEs; j++){%>
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DCECounterState')%>, read_data);  
      `uvm_info(get_name(), $sformatf("<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DCECounterState')%>=%0d", read_data), UVM_LOW)
      <%}%>
    <%for (j=0; j< obj.nDMIs; j++){%>
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DMICounterState')%>, read_data);  
      `uvm_info(get_name(), $sformatf("<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DMICounterState')%>=%0d", read_data), UVM_LOW)
    <%}%>
    <%for (j=0; j< obj.nDIIs; j++){%>
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DIICounterState')%>, read_data);  
      `uvm_info(get_name(), $sformatf("<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DIICounterState')%>=%0d", read_data), UVM_LOW)
    <%}%>

    //#Stimulus.IOAIU.NoCreditsConfigured
    // case (coreId)
    // <%for (var i=0; i<obj.DutInfo.nNativeInterfacePorts;i++) {%>
      // <%=i%>: begin
      <%for (j=0; j< obj.nDCEs; j++){%>
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DCECreditLimit')%>, m_env_cfg[<%=obj.multiPortCoreId%>].dceCreditLimitTemp[<%=j%>]);
        m_env_cfg[<%=obj.multiPortCoreId%>].dceCreditLimit[<%=j%>] = m_env_cfg[<%=obj.multiPortCoreId%>].dceCreditLimitTemp[<%=j%>];
      <%}%>
      // end
    // <%}%>
    // endcase
    // write_csr(<%=generateRegPath(i+'.XAIUCCR'+j+'.DCECreditLimit')%>, mp_env.m_env_cfg[<%=i%>].dceCreditLimitTemp[<%=j%>]);
    // <%=obj.multiPortCoreId%>
    
    // case (coreId)
    // <%for (var i=0; i<obj.DutInfo.nNativeInterfacePorts;i++) {%>
    //   <%=i%>: begin
      <%for (var j=0; j< obj.nDMIs; j++){%>
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DMICreditLimit')%>, m_env_cfg[<%=obj.multiPortCoreId%>].dmiCreditLimitTemp[<%=j%>]);
        m_env_cfg[<%=obj.multiPortCoreId%>].dmiCreditLimit[<%=j%>] = m_env_cfg[<%=obj.multiPortCoreId%>].dmiCreditLimitTemp[<%=j%>];
      <%}%>
    //   end
    // <%}%>
    // endcase

    // case (coreId)
    // <%for (var i=0; i<obj.DutInfo.nNativeInterfacePorts;i++) {%>
    //   <%=i%>: begin  
      <%for (var j=0; j< obj.nDIIs; j++){%>
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DIICreditLimit')%>, m_env_cfg[<%=obj.multiPortCoreId%>].diiCreditLimitTemp[<%=j%>]);
        m_env_cfg[<%=obj.multiPortCoreId%>].diiCreditLimit[<%=j%>] = m_env_cfg[<%=obj.multiPortCoreId%>].diiCreditLimitTemp[<%=j%>];
      <%}%>
    //   end
    // <%}%>
    // endcase
    <% if(obj.COVER_ON) { %>
      `ifndef FSYS_COVER_ON
        cov.collect_ccr_val(<%=obj.multiPortCoreId%>, m_env_cfg[<%=obj.multiPortCoreId%>].dceCreditLimit, m_env_cfg[<%=obj.multiPortCoreId%>].dmiCreditLimit, m_env_cfg[<%=obj.multiPortCoreId%>].diiCreditLimit);
      `endif 
    <%}%> 
  



   endtask
endclass : csr_credit_sw_mgr_seq_<%=obj.multiPortCoreId%>

//#Stimulus.IOAIU.v3.4.SCM.NegativeCounterStateDirectedTest
class csr_scm_negative_state_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
  `uvm_object_utils(csr_scm_negative_state_seq_<%=obj.multiPortCoreId%>)

  uvm_reg_data_t read_data, write_data, poll_data;
    int new_credits;
    int delay;
    ioaiu_scoreboard ioaiu_scb;

  function new(string name="");
    super.new(name);
  endfunction

  task body();
    getCsrProbeIf();
    get_env_handle();
    get_mp_env_handle();
     get_m_env_cfg_handle();

    if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                              .inst_name( "*" ),
                                              .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                              .value( ioaiu_scb ))) begin
        `uvm_error("ioaiu_csr_time_out_error_seq", "ioaiu_scb model not found")
    end
    ev_<%=obj.multiPortCoreId%>.trigger();

    for(int x=0; x < 100; x++) begin
      delay = $urandom_range(1,500);
      // new_credits = $urandom_range(1, 31);
      new_credits = (x%2) ? 2 : 6;
      //$display("time=%0t KDB%0d credit=%0d, delay=%0d", $time, x, new_credits, delay);
		  #(<%=obj.Clocks[0].params.period%>ps * delay); //wait for random cycles


      <%for (j=0; j< obj.nDCEs; j++){%>
          //m_env_cfg[<%=obj.multiPortCoreId%>].dceCreditLimit[<%=j%>] = new_credits;
          //write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DCECreditLimit')%>, m_env_cfg[<%=obj.multiPortCoreId%>].dceCreditLimit[<%=j%>]);
          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DCECreditLimit')%>, new_credits);
      <%}%>
      
      <%for (j=0; j< obj.nDMIs; j++){%>
          //m_env_cfg[<%=obj.multiPortCoreId%>].dmiCreditLimit[<%=j%>] = new_credits;
          //write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DMICreditLimit')%>, m_env_cfg[<%=obj.multiPortCoreId%>].dmiCreditLimit[<%=j%>]);
          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DMICreditLimit')%>, new_credits);
      <%}%>

      <%for (j=0; j< obj.nDIIs; j++){%>
          //m_env_cfg[<%=obj.multiPortCoreId%>].diiCreditLimit[<%=j%>] = new_credits;
          //write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DIICreditLimit')%>, m_env_cfg[<%=obj.multiPortCoreId%>].diiCreditLimit[<%=j%>]);
          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DIICreditLimit')%>, new_credits);
      <%}%>

      //<% if(obj.COVER_ON) { %>
      //`ifndef FSYS_COVER_ON
      //  cov.collect_ccr_val(<%=obj.multiPortCoreId%>, mp_env.m_env_cfg[<%=obj.multiPortCoreId%>].dceCreditLimit, mp_env.m_env_cfg[<%=obj.multiPortCoreId%>].dmiCreditLimit, mp_env.m_env_cfg[<%=obj.multiPortCoreId%>].diiCreditLimit);
      //`endif 
      //<%}%> 
      
    end
  endtask

endclass : csr_scm_negative_state_seq_<%=obj.multiPortCoreId%>





//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check alias register can be reflected in actual register in status. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. write each filed of alias register and should reflect in actual status register. 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class ioaiu_csr_xaiucesar_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_xaiucesar_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

           getCsrProbeIf();
           ev_<%=obj.multiPortCoreId%>.trigger();
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
           compareValues("XAIUCESR_ErrVld","set", read_data, 1);

           write_data = 0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
           compareValues("XAIUCESR_ErrVld","now clear", read_data, 0);

           // Write Alias CSR field ErrType to reflect into SR ErrType filed
           write_data = 4'b1111;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrType')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrType')%>, read_data);
           compareValues("XAIUCESR_ErrType", "", read_data, write_data);

           write_data = 4'b0000;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrType')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrType')%>, read_data);
           compareValues("XAIUCESR_ErrType", "", read_data, write_data);

           // Write Alias CSR field ErrInfo to reflect into SR ErrInfo filed
           write_data = 20'hfffff;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrInfo')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrInfo')%>, read_data);
           compareValues("XAIUCESR_ErrInfo", "", read_data, write_data);

           write_data = 20'h00000;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrInfo')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrInfo')%>, read_data);
           compareValues("XAIUCESR_ErrInfo", "", read_data, write_data);
    endtask
endclass : ioaiu_csr_xaiucesar_seq_<%=obj.multiPortCoreId%>

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will make sure that every bit of this register that is
* accessible will be set to '1'  then clear afterwards.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class ioaiu_csr_xaiucctrlr_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_xaiucctrlr_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

           getCsrProbeIf();
           ev_<%=obj.multiPortCoreId%>.trigger();
           write_data = 1;

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn0Tx')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn0Tx')%>, read_data);
           compareValues("XAIUCCTRLR.ndn0Tx","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn0Tx')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn0Rx')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn0Rx')%>, read_data);
           compareValues("XAIUCCTRLR.ndn0Rx","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn0Rx')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn1Tx')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn1Tx')%>, read_data);
           compareValues("XAIUCCTRLR.ndn1Tx","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn1Tx')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn1Rx')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn1Rx')%>, read_data);
           compareValues("XAIUCCTRLR.ndn1Rx","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn1Rx')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn2Tx')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn2Tx')%>, read_data);
           compareValues("XAIUCCTRLR.ndn2Tx","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn2Tx')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn2Rx')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn2Rx')%>, read_data);
           compareValues("XAIUCCTRLR.ndn2Rx","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn2Rx')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.dn0Rx')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.dn0Rx')%>, read_data);
           compareValues("XAIUCCTRLR.dn0Rx","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.dn0Rx')%>, 0);
    endtask
endclass : ioaiu_csr_xaiucctrlr_seq_<%=obj.multiPortCoreId%>

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will make sure that every bit of this register is 
* accessible.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class ioaiu_csr_xaiutctrlr0_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_xaiutctrlr0_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t read_data, write_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

           getCsrProbeIf();
           ev_<%=obj.multiPortCoreId%>.trigger();

           write_data = 1;
           <% if(computedAxiInt.params.eTrace) {%>
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.native_trace_en')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.native_trace_en')%>, read_data);
           compareValues("XAIUTCTRLR0.native_trace_en","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.native_trace_en')%>, 0);
           <%}%>

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.addr_match_en')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.addr_match_en')%>, read_data);
           compareValues("XAIUTCTRLR0.addr_match_en","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.addr_match_en')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.opcode_match_en')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.opcode_match_en')%>, read_data);
           compareValues("XAIUTCTRLR0.opcode_match_en","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.opcode_match_en')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.memattr_match_en')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.memattr_match_en')%>, read_data);
           compareValues("XAIUTCTRLR0.memattr_match_en","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.memattr_match_en')%>, 0);

           <% if(computedAxiInt.params.wAwUser > 0) {%>
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.user_match_en')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.user_match_en')%>, read_data);
           compareValues("XAIUTCTRLR0.user_match_en","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.user_match_en')%>, 0);
           <%}%>

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.target_type_match_en')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.target_type_match_en')%>, read_data);
           compareValues("XAIUTCTRLR0.target_type_match_en","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.target_type_match_en')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.hut')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.hut')%>, read_data);
           compareValues("XAIUTCTRLR0.hut","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.hut')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.hui')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.hui')%>, read_data);
           compareValues("XAIUTCTRLR0.hui","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.hui')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.range')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.range')%>, read_data);
           compareValues("XAIUTCTRLR0.range","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.range')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.aw')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.aw')%>, read_data);
           compareValues("XAIUTCTRLR0.aw","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.aw')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.ar')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.ar')%>, read_data);
           compareValues("XAIUTCTRLR0.ar","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.ar')%>, 0);

           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.memattr')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.memattr')%>, read_data);
           compareValues("XAIUTCTRLR0.memattr","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.memattr')%>, 0);

    endtask
endclass : ioaiu_csr_xaiutctrlr0_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_xaiutopcr0_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_xaiutopcr0_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t read_data, write_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

           getCsrProbeIf();
           ev_<%=obj.multiPortCoreId%>.trigger();

           write_data = 7'h7F;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.opcode1')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.opcode1')%>, read_data);
           compareValues("XAIUTOPCR00.opcode1","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.opcode1')%>, 0);

           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.valid1')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.valid1')%>, read_data);
           compareValues("XAIUTOPCR00.valid1","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.valid1')%>, 0);

           write_data = 7'h7F;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.opcode2')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.opcode2')%>, read_data);
           compareValues("XAIUTOPCR00.opcode2","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.opcode2')%>, 0);

           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.valid2')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.valid2')%>, read_data);
           compareValues("XAIUTOPCR00.valid2","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.valid2')%>, 0);

           write_data = 7'h7F;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.opcode3')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.opcode3')%>, read_data);
           compareValues("XAIUTOPCR10.opcode3","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.opcode3')%>, 0);

           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.valid3')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.valid3')%>, read_data);
           compareValues("XAIUTOPCR10.valid3","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.valid3')%>, 0);

           write_data = 7'h7F;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.opcode4')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.opcode4')%>, read_data);
           compareValues("XAIUTOPCR10.opcode4","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.opcode4')%>, 0);

           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.valid4')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.valid4')%>, read_data);
           compareValues("XAIUTOPCR10.valid4","", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.valid4')%>, 0);

    endtask
endclass : ioaiu_csr_xaiutopcr0_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_xaiutbahr0_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_xaiutbahr0_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t read_data, write_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

           getCsrProbeIf();
           ev_<%=obj.multiPortCoreId%>.trigger();

           write_data = 8'hFF;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTBAHR0.base_addr_hi')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTBAHR0.base_addr_hi')%>, read_data);
           compareValues("XAIUTBAHR0.base_addr_hi","", read_data, write_data);

           write_data = 8'h0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTBAHR0.base_addr_hi')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTBAHR0.base_addr_hi')%>, read_data);
           compareValues("XAIUTBAHR0.base_addr_hi","", read_data, write_data);

    endtask
endclass : ioaiu_csr_xaiutbahr0_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_xaiutbalr0_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_xaiutbalr0_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t read_data, write_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

           getCsrProbeIf();
           ev_<%=obj.multiPortCoreId%>.trigger();

           write_data = 32'hFFFFFFFF;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTBALR0.base_addr_lo')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTBALR0.base_addr_lo')%>, read_data);
           compareValues("XAIUTBALR0.base_addr_lo","", read_data, write_data);

           write_data = 32'h0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTBALR0.base_addr_lo')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTBALR0.base_addr_lo')%>, read_data);
           compareValues("XAIUTBALR0.base_addr_lo","", read_data, write_data);

    endtask
endclass : ioaiu_csr_xaiutbalr0_seq_<%=obj.multiPortCoreId%>


class ioaiu_csr_xaiutubr0_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_xaiutubr0_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t read_data, write_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

           getCsrProbeIf();
           ev_<%=obj.multiPortCoreId%>.trigger();

           write_data = 32'hFFFFFFFF;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTUBR0.user')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTUBR0.user')%>, read_data);
           compareValues("XAIUTUBR0.user","", read_data, write_data);

           write_data = 32'h0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTUBR0.user')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTUBR0.user')%>, read_data);
           compareValues("XAIUTUBR0.user","", read_data, write_data);

    endtask
endclass : ioaiu_csr_xaiutubr0_seq_<%=obj.multiPortCoreId%>


class ioaiu_csr_xaiutubmr0_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_xaiutubmr0_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t read_data, write_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

           getCsrProbeIf();
           ev_<%=obj.multiPortCoreId%>.trigger();

           write_data = 32'hFFFFFFFF;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTUBMR0.user_mask')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTUBMR0.user_mask')%>, read_data);
           compareValues("XAIUTUBMR0.user_mask","", read_data, write_data);

           write_data = 32'h0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTUBMR0.user_mask')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTUBMR0.user_mask')%>, read_data);
           compareValues("XAIUTUBMR0.user_mask","", read_data, write_data);

    endtask
endclass : ioaiu_csr_xaiutubmr0_seq_<%=obj.multiPortCoreId%>

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check alias register can be reflected in actual register in status. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. write each filed of alias register and should reflect in actual status register. 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class ioaiu_csr_xaiuuesar_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_xaiuuesar_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

           getCsrProbeIf();
           ev_<%=obj.multiPortCoreId%>.trigger();
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.MemErrIntEn')%>, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrVld')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("XAIUUESR_ErrVld","set", read_data, 1);

           // wait for IRQ_UC interrupt 
           fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 1);
           end
           begin
             #200000ns;
             `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
           end
           join_any
           disable fork;

           write_data = 0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrVld')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("XAIUUESR_ErrVld","now clear", read_data, 0);

           // wait for IRQ_UC interrupt 
           fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 0);
           end
           begin
             #200000ns;
             `uvm_error(get_full_name(),$sformatf("IRQ_UC interruped still aseerted"));
           end
           join_any
           disable fork;

           // Write Alias CSR field ErrType to reflect into SR ErrType filed
           write_data = 4'b1111;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrType')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
           compareValues("XAIUUESR_ErrType","", read_data, write_data);

           write_data = 5'b00000;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrType')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
           compareValues("XAIUUESR_ErrType","", read_data, write_data);
           
           // Write Alias CSR field ErrInfo to reflect into SR ErrInfo filed
           write_data = 20'hfffff;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrInfo')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
           compareValues("XAIUUESR_ErrInfo","", read_data, write_data);

           write_data = 20'h00000;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrInfo')%>, write_data);

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
           compareValues("XAIUUESR_ErrInfo","", read_data, write_data);
    endtask
endclass : ioaiu_csr_xaiuuesar_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_credit_adjustment_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_credit_adjustment_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

           getCsrProbeIf();
           ev_<%=obj.multiPortCoreId%>.trigger();
           //      - Limit maximum up to config value.
           //              0x1: Maximum credit is 1.
           //              0x2: Maximum credit is 2.
           //              0x3: Maximum credit is 3.
           //      - Reduce total to minimum of 1.
           //              0x5: Minus 1.
           //              0x6: Minus 2.
           //              0x7: Minus 3.
           //      - Special cases
           //              0x9: 1 read only. Others write.
           //              0xa: Reserve 1 write if possible
           //              0xb: Let it rip. No limit at all
           //      - Increase write reservation to max-1
           //              0xd: 1 extra reserved writes
           //              0xe: 2 extra reserved writes
           //              0xf: 3 extra reserved writes

           write_data = $urandom_range(0,15);
           if($test$plusargs("crd_adj"))
               $value$plusargs("crd_adj=%d",write_data);
             
           `uvm_info("ioaiu_csr_credit_adjustment_seq",$sformatf("configuring XAIUEDR6 : Credit Adjustment Register with value :%x ",write_data), UVM_NONE)
        
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR6.DVE')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR6.DVE')%>, read_data);
           compareValues("XAIUEDR6_DVE","set", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR6.QOS')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR6.QOS')%>, read_data);
           compareValues("XAIUEDR6_QOS","set", read_data, write_data);
           //if(write_data == 7) write_data = 6; // Getting HBFAIL
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR6.DCE')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR6.DCE')%>, read_data);
           compareValues("XAIUEDR6_DCE","set", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR6.DMI')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR6.DMI')%>, read_data);
           compareValues("XAIUEDR6_DMI","set", read_data, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR6.DII')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR6.DII')%>, read_data);
           compareValues("XAIUEDR6_DII","set", read_data, write_data);

           
    endtask
endclass : ioaiu_csr_credit_adjustment_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_time_out_error_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_time_out_error_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, write_data,timeout_threshold;
    bit [47:0] actual_addr;
    bit [47:0] expt_addr;
    bit [19:0]errinfo;
    bit [19:0] errentry;
    bit [5:0] errway;
    bit [5:0] errword;
    bit [19:0] erraddr;
    bit [31:0] erraddr0;
    smi_seq_item cmd_req_pkt;
    int m_rand_index_dirty_state[$];
    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    rand bit [5:0]  m_nWord;
    bit security;
    ioaiu_scoreboard ioaiu_scb;
    uvm_event ev_ccp_eviction_time_out_test_<%=obj.multiPortCoreId%> = ev_pool.get("ev_ccp_eviction_time_out_test_<%=obj.multiPortCoreId%>");

   <% if (obj.DutInfo.useCache){ %>
    constraint c_nSets  { m_nSets >= 0; m_nSets < <%=nSetsPerCore%>;}
    constraint c_nWays  { m_nWays >= 0; m_nWays < <%=obj.DutInfo.ccpParams.nWays%>;}  
   <%}%>

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        uvm_status_e status; 
        uvm_reg my_register;
        uvm_reg_field my_field;
        uvm_reg_data_t write_data = 32'hFFFF_FFFF; 
        uvm_reg_data_t mirrored_value;

        if (m_regs == null) begin
            `uvm_error(get_type_name(), "m_regs is null. Cannot perform write operation.");
            return;
        end

      
        my_register = m_regs.get_reg_by_name("XAIUUELR0");
        if (my_register == null) begin
            `uvm_error(get_type_name(), "Register XAIUUELR0 not found in m_regs");
            return;
        end

       my_register.write(status, write_data);
       `uvm_info(get_type_name(), $sformatf("Wrote %0h to register XAIUUELR0 in sequence", write_data), UVM_LOW)

       if (status != UVM_IS_OK) begin
       `uvm_error(get_type_name(), $sformatf("Error writing to reg XAIUUELR0: %s", status.name()));
        return;
      end

       my_register.read(status,read_data);
       `uvm_info(get_type_name(), $sformatf("And XAIUUELR0 in seq after reading is %0h",read_data),UVM_LOW)

      if (status != UVM_IS_OK) begin
       `uvm_error(get_type_name(), $sformatf("Error reading from reg XAIUUELR0: %s", status.name()));
        return;
      end 
      getCsrProbeIf();
      if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                                  .inst_name( "*" ),
                                                  .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                                  .value( ioaiu_scb ))) begin
             `uvm_error("ioaiu_csr_time_out_error_seq", "ioaiu_scb model not found")
      end

      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.TimeoutErrDetEn')%>, write_data);
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.TimeoutErrIntEn')%>, write_data);
      //#Stimulus.IOAIU.TimeOutThreshold
      timeout_threshold = $urandom_range(3, 1);;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOCR.TimeOutThreshold')%>, timeout_threshold);
      ev_<%=obj.multiPortCoreId%>.trigger();

      if ($test$plusargs("dvm_time_out_test")) begin
        ev_csr_test_time_out_CMDrsp_STRreq_Evict<%=obj.multiPortCoreId%>.wait_ptrigger();
         #(<%=obj.Clocks[0].params.period%>ps*$urandom_range(30,50));

        errinfo[1:0] = 2'b11; // DVM
        errinfo[2] = ioaiu_scb.sv_ovt_timeout_security ;
        errinfo[7:3] = 5'b0; //reserved
        errinfo[19:8] = ioaiu_scb.sv_ovt_timeout_id; 
        expt_addr = ioaiu_scb.sv_ovt_timeout_addr;


      end else if ($test$plusargs("CMDrsp_time_out_test")) begin
        ev_csr_test_time_out_CMDrsp_STRreq_Evict<%=obj.multiPortCoreId%>.wait_ptrigger();
         #(<%=obj.Clocks[0].params.period%>ps*$urandom_range(30,50));

        errinfo[1:0] = 2'b01; //Writes
        errinfo[2] = ioaiu_scb.sv_ovt_timeout_security ;
        errinfo[7:3] = 5'b0; //reserved
        errinfo[19:8] = ioaiu_scb.sv_ovt_timeout_id; 
        expt_addr = ioaiu_scb.sv_ovt_timeout_addr;

      end else if ($test$plusargs("STRreq_time_out_test")) begin
        ev_csr_test_time_out_CMDrsp_STRreq_Evict<%=obj.multiPortCoreId%>.wait_ptrigger();
         #(<%=obj.Clocks[0].params.period%>ps*$urandom_range(30,50));

        errinfo[1:0] = ioaiu_scb.timeout_err_cmd_type; //Reads or dataless 
        errinfo[2] = ioaiu_scb.sv_ovt_timeout_security ;
        errinfo[7:3] = 5'b0; //reserved
        errinfo[19:8] = ioaiu_scb.sv_ovt_timeout_id; 
        expt_addr = ioaiu_scb.sv_ovt_timeout_addr;

      end else if ($test$plusargs("CCP_eviction_time_out_test")) begin 
        ev_csr_test_time_out_CMDrsp_STRreq_Evict<%=obj.multiPortCoreId%>.wait_ptrigger();
        wait (ioaiu_scb.eviction_addr != 0);

        expt_addr = ioaiu_scb.eviction_addr;
        errinfo[1:0]  = 2'b01; //Writes
        errinfo[2]    = ioaiu_scb.eviction_security ;
        errinfo[7:3]  = 5'b0;    // Reserved 
        errinfo[19:8] = ioaiu_scb.evict_id;  

     end
       `uvm_info(get_full_name(),$sformatf("errinfo %0h, expt_addr = %0h",errinfo,expt_addr),UVM_NONE)
      //#Check.IOAIU.TimeOutError.ErrVld
      poll_UUESR_ErrVld(1, poll_data);
      //#Check.IOAIU.TimeOutError.IRQ_UC
      fork
      begin
          wait (u_csr_probe_vif.IRQ_UC === 1);
      end
      begin
        #200000ns;
        `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
      end
      join_any
      disable fork;
      //#Check.IOAIU.TimeOutError.ErrType
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
      uvm_config_db#(int)::set(null,"*","ioaiu_normal_time_out_uesr_err_type",read_data); //for coverag
      compareValues("DCEUUESR.ErrType","should be",read_data,9);
      //#Check.IOAIU.TimeOutError.ErrInfo_NS
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
      uvm_config_db#(int)::set(null,"*","ioaiu_normal_time_out_uesr_err_info",read_data); //for coverag
      compareValues("DCEUUESR.ErrInfo","should be",read_data,errinfo);
      //#Check.IOAIU.TimeOutError.ELR0
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrAddr')%>, read_data);
      erraddr0 = read_data;
//    read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrEntry')%>, read_data);
//    errentry = read_data;
//    read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWay')%>, read_data);
//    errway = read_data;
//    read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWord')%>, read_data);
//    errword = read_data;
      //#Check.IOAIU.TimeOutError.ELR1
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR1.ErrAddr')%>, read_data);
      erraddr = read_data;
      actual_addr = {erraddr,erraddr0};
      if (actual_addr !== expt_addr) begin
        `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, expt_addr))
      end
      write_data = 0;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.TimeoutErrDetEn')%>, write_data);
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.TimeoutErrIntEn')%>, write_data);
      timeout_threshold = 0;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOCR.TimeOutThreshold')%>, timeout_threshold);
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
      // Read the XAIUUESR_ErrVld should be cleared
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
      compareValues("XAIUUESR_ErrVld", "now clear", read_data, 0);
    endtask

endclass : ioaiu_csr_time_out_error_seq_<%=obj.multiPortCoreId%>


class io_aiu_default_reset_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
    `uvm_object_utils(io_aiu_default_reset_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]           errthd;
    int                 errcount_vld, errthd_vld;
    int                 errcount_ovf;
    bit [3:0]           errtype;
    int                 coreId;
    int                 evictionQoS;
    bit                 en_XAIUUEDR_DecErrDetEn;
    TRIG_TCTRLR_t       tctrlr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBALR_t        tbalr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBAHR_t        tbahr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR0_t       topcr0[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR1_t       topcr1[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBR_t         tubr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBMR_t        tubmr[<%=obj.DutInfo.nTraceRegisters%>];
    bit                 dvm_resp_order = 1;
    bit ccp_lookupen = 1;
    bit ccp_allocen = 1;
    addr_trans_mgr      m_addr_mgr = addr_trans_mgr::get_instance();
    ncore_memory_map    m_mem = m_addr_mgr.get_memory_map_instance();
    gpra_order_t        gpra_order;
    int                 index ;
    int                 num_credits;
    uvm_reg_data_t      eventThreshold, edr1_wr_data, edr1_rd_data;
    uvm_event ev_delay_smi_msg = ev_pool.get("ev_delay_smi_msg");//delay message to trigger timeout
    TransOrderMode_e    transOrderMode_wr, transOrderMode_rd;
    rand int starv_eventThershold;
    int xaiucr_ott_wr_pool, xaiucr_ott_rd_pool;

    <%for(var i = 0; i < obj.DutInfo.nGPRA; i++){%>
        gpra_order_t    gpra<%=i%>_order;
    <%}%>

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        string k_csr_SMC_mntop_seq = "";
        addrMgrConst::sys_addr_csr_t csrq[$];
        csrq = addrMgrConst::get_all_gpra();
        foreach (csrq[i]) begin
          `uvm_info(get_name(),
              $psprintf("unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d nc:%0d nsx:%0b",
                  csrq[i].unit.name(), csrq[i].mig_nunitid,
                  csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size, csrq[i].nc, csrq[i].nsx),
              UVM_NONE)
        end
        if($value$plusargs("gpra_order=%b", gpra_order)) begin
        end
        get_mp_env_handle();
     get_m_env_cfg_handle();
        if($test$plusargs("check_enable_low_parity_test"))begin
         `uvm_info("check_enable testing",$sformatf("register setting done"),UVM_LOW)
         write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.IntfCheckErrDetEn')%>, 1); 
         write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.IntfCheckErrIntEn')%>, 1);
       end
        //#Stimulus.IOAIU.v3.4.SCM.BringUp
        begin : Setup_reset_credit_limits
          if ($test$plusargs("no_credit_check")) num_credits = 0;
          else                                   num_credits = 31;
          for (int i=0; i<<%=obj.DutInfo.nNativeInterfacePorts%>;i++)begin
            for (int j=0; j<<%=obj.nDCEs%>; j++) begin
              m_env_cfg[<%=obj.multiPortCoreId%>].dceCreditLimit[j] = num_credits;
            end
          end
          for (int i=0; i<<%=obj.DutInfo.nNativeInterfacePorts%>;i++)begin
            for (int j=0; j<<%=obj.nDMIs%>; j++) begin
              m_env_cfg[<%=obj.multiPortCoreId%>].dmiCreditLimit[j] = num_credits;
            end
          end
          for (int i=0; i<<%=obj.DutInfo.nNativeInterfacePorts%>;i++)begin
            for (int j=0; j<<%=obj.nDIIs%>; j++) begin
              m_env_cfg[<%=obj.multiPortCoreId%>].diiCreditLimit[j] = num_credits;
            end
          end
          
            <%for (j=0; j< obj.nDCEs; j++){%>
              write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DCECreditLimit')%>, m_env_cfg[<%=obj.multiPortCoreId%>].dceCreditLimit[<%=j%>]);
            <%}%>
            <%for (var j=0; j< obj.nDMIs; j++){%>
              write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DMICreditLimit')%>, m_env_cfg[<%=obj.multiPortCoreId%>].dmiCreditLimit[<%=j%>]);
            <%}%>
             <%for (var j=0; j< obj.nDIIs; j++){%>
              write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCR'+j+'.DIICreditLimit')%>, m_env_cfg[<%=obj.multiPortCoreId%>].diiCreditLimit[<%=j%>]);
            <%}%>
          <% if(obj.COVER_ON) { %>
            `ifndef FSYS_COVER_ON
              cov.collect_ccr_val(<%=obj.multiPortCoreId%>, m_env_cfg[<%=obj.multiPortCoreId%>].dceCreditLimit, m_env_cfg[<%=obj.multiPortCoreId%>].dmiCreditLimit, m_env_cfg[<%=obj.multiPortCoreId%>].diiCreditLimit);
            `endif 
          <%}%> 

        end: Setup_reset_credit_limits
    
        begin : setup_starv_thresh
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUQOSCR.EventThreshold')%>,read_data);
            `uvm_info(get_full_name(),$sformatf("XAIUQOSCR.EventThreshold Read Data = %0h",read_data),UVM_NONE)

            std::randomize(starv_eventThershold) with {starv_eventThershold dist {0:=2,[1:3]:=98} ;};
            eventThreshold = starv_eventThershold;
            if($test$plusargs("Starv_Event_Thrs"))
                $value$plusargs("Starv_Event_Thrs=%d",eventThreshold);

            write_data = eventThreshold;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUQOSCR.EventThreshold')%>,write_data);
            read_data = 0;
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUQOSCR.EventThreshold')%>, read_data);
            `uvm_info(get_full_name(),$sformatf("XAIUQOSCR.EventThreshold Read Data = %0h (should be %0d)",read_data,write_data),UVM_NONE)
        end
        
        <%for(var i = 0; i < obj.DutInfo.nGPRA; i++){%>
            if($value$plusargs("gpra<%=i%>_order=%b", gpra<%=i%>_order)) begin
                `uvm_info("IOAIU<%=obj.Id%> TEST", $psprintf("Received gpra_order from the plusarg. gpra<%=i%>_order = %p", gpra<%=i%>_order), UVM_NONE)
            end
            else begin
                gpra<%=i%>_order = csrq[<%=i%>].order;
                /* $display("BING DEBUG: Got gpra_order from addr manager. gpra_order for gpra[%0d]: %p", <%=i%>, gpra_order); */
                `uvm_info("IOAIU<%=obj.Id%> TEST", $psprintf("Got gpra_order from addr mgr. gpra<%=i%>_order[%0d] = %p", <%=i%>, gpra<%=i%>_order), UVM_NONE)
            end
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRBLR'+i+'.AddrLow')%>, csrq[<%=i%>].low_addr);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRBHR'+i+'.AddrHigh')%>, csrq[<%=i%>].upp_addr);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.ReadID')%>, gpra<%=i%>_order.readID);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.WriteID')%>, gpra<%=i%>_order.writeID);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.Policy')%>, gpra<%=i%>_order.policy);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.Size')%>, csrq[<%=i%>].size);
            if($test$plusargs("pcie_directed_test")) begin //DCDEBUG 
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.ReadID')%>, 0);
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.WriteID')%>, 1);
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.Policy')%>, 0);
            end
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.Valid')%>, 1);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.HUI')%>, csrq[<%=i%>].mig_nunitid);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.HUT')%>, csrq[<%=i%>].unit == addrMgrConst::DII ? 1 : 0);
            <% if ((obj.DutInfo.fnNativeInterface === "AXI4") || (obj.DutInfo.fnNativeInterface === "AXI5")) {%>
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.NC')%>, csrq[<%=i%>].nc); // noncoherent bit
            <%}%>
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.NSX')%>, csrq[<%=i%>].nsx); // security setting
            /* //NCore3SysArch 4.5.2.3.5 */
            ev_<%=obj.multiPortCoreId%>.trigger();
        <%}%>

        if(en_XAIUUEDR_DecErrDetEn) begin
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.DecErrDetEn')%>, 1);
	      end
        
        //#Stimulus.IOAIU.OWO.transOrderMode
        <% if (obj.DutInfo.orderedWriteObservation == false && obj.DutInfo.fnNativeInterface != "ACE" && obj.DutInfo.fnNativeInterface != "ACE5") {%>
	       //#Stimulus.IOAIU.transOrderMode_nonACE
            std::randomize(transOrderMode_wr) with {transOrderMode_wr dist { strictReqMode:=10, pcieOrderMode:=90};};
            std::randomize(transOrderMode_rd) with {transOrderMode_rd dist { strictReqMode:=10, pcieOrderMode:=90};};
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCR.TransOrderModeWr')%>, transOrderMode_wr);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCR.TransOrderModeRd')%>, transOrderMode_rd);
        <%}%>
        
        <%if(obj.DutInfo.useCache){%>
        	


            if($test$plusargs("k_csr_SMC_mntop_seq")) begin
                $value$plusargs("k_csr_SMC_mntop_seq=%s",k_csr_SMC_mntop_seq);
                if (k_csr_SMC_mntop_seq == "ioaiu_ccp_offline_seq_<%=obj.multiPortCoreId%>") begin
                    <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status, 0, .parent(this));
                end 
            end

            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCTCR.LookupEn')%> ,ccp_lookupen);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCTCR.AllocEn')%>  ,ccp_allocen);

            `uvm_info(get_full_name(), $psprintf("Programmed XAIUPCTCR.LookupEn:%0d XAIUPCTCR.AllocEn:%0d", ccp_lookupen, ccp_allocen), UVM_LOW)
            
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCTCR.UpdateDis')%>, read_data);
            compareValues("XAIUPCTCR.UpdateDis", "clear", read_data, 0);

            if($test$plusargs("disable_updates")) begin
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCTCR.UpdateDis')%>  ,1);
            end

            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUQOSCR.useEvictionQoS')%> , $urandom_range(0,1));
                
            evictionQoS = $urandom_range(0,15);
            
            //`uvm_info(get_type_name(), $sformatf("configuring  XAIUQOSCR with useEvictionQoS:%0b EvictionQoS:0x%0h", useEvictionQoS, evictionQoS),UVM_NONE)
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUQOSCR.EvictionQoS')%> , evictionQoS);
            
        <%}%>
 
        
        if(dvm_resp_order == 0) begin
            //CONTROL[20]
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR1.cfg')%>, read_data);
            write_data = read_data | 32'h10_0000;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR1.cfg')%>, write_data);
        end
        begin: setup_TCTRLR
            <% if(computedAxiInt.params.eTrace){%>
              write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.native_trace_en')%>, tctrlr[0].native_trace_en);
            <%}%>
            if(tctrlr[0].memattr_match_en) begin
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.memattr_match_en')%>, tctrlr[0].memattr_match_en);
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.memattr')%>, tctrlr[0].memattr);
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.ar')%>, tctrlr[0].ar);
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.aw')%>, tctrlr[0].aw);
            end
            <%if(computedAxiInt.params.wAwUser > 0){%>
                if(tctrlr[0].user_match_en) begin
                    write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.user_match_en')%>, tctrlr[0].user_match_en);
                end
            <%}%>
            if(tctrlr[0].target_type_match_en) begin
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.target_type_match_en')%>, tctrlr[0].target_type_match_en);
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.hut')%>, tctrlr[0].hut);
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCTRLR0.hui')%>, tctrlr[0].hui);
            end
        end: setup_TCTRLR
        begin: setup_TOPCR
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.opcode1')%>, topcr0[0].opcode1);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.valid1 ')%>,  topcr0[0].valid1);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.opcode2')%>, topcr0[0].opcode2);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR00.valid2 ')%>,  topcr0[0].valid2);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.opcode3')%>, topcr1[0].opcode3);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.valid3 ')%>,  topcr1[0].valid3);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.opcode4')%>, topcr1[0].opcode4);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTOPCR10.valid4 ')%>,  topcr1[0].valid4);
        end: setup_TOPCR
        begin: setup_TUBR
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTUBR0.user')%>, tubr[0].user);
        end: setup_TUBR
        begin: setup_TUBMR
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTUBMR0.user_mask')%>, tubmr[0].user_mask);
        end: setup_TUBMR
        begin : setup_CCTRLR
            /*
            * Set up trace capture control register (CCTRLR).
            * If "cctrlr_value" plusarg is specified, the CCTRLR register is set accordingly.
            * If "cctrlr_random" plusarg is specified, the CCTRLR register takes random value.
            * Otherwise, CCTRLR is set to 0
            */
            uvm_reg_data_t cctrlr_value;
            if (!$value$plusargs("cctrlr_value=0x%h", cctrlr_value)) begin
                if ($test$plusargs("cctrlr_random")) begin
                    std::randomize(cctrlr_value);
                end else begin
                    cctrlr_value = 0;
                end
            end
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn0Tx')%>, ((cctrlr_value >> 0)&1));
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn0Rx')%>, ((cctrlr_value >> 1)&1));
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn1Tx')%>, ((cctrlr_value >> 2)&1));
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn1Rx')%>, ((cctrlr_value >> 3)&1));
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn2Tx')%>, ((cctrlr_value >> 4)&1));
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.ndn2Rx')%>, ((cctrlr_value >> 5)&1));
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.dn0Tx')%>,  ((cctrlr_value >> 6)&1));
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.dn0Rx')%>,  ((cctrlr_value >> 7)&1));
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.gain')%>,   ((cctrlr_value >> 16)&15));
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCCTRLR.inc')%>,    ((cctrlr_value >> 20)&4095));

            trace_debug_scb::port_capture_en    = cctrlr_value[7:0];
            trace_debug_scb::gain               = cctrlr_value[11:8];
            trace_debug_scb::inc                = cctrlr_value[23:12];
        end : setup_CCTRLR

        begin : check_SysCo
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCR.SysCoDisable')%>, read_data);
            compareValues("XAIUTCR.SysCoDisable", "clear", read_data, 0);
            
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTCR.SysCoAttach')%>, read_data);
            compareValues("XAIUTCR.SysCoAttach", "clear", read_data, 0);
            
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTAR.SysCoConnecting')%>, read_data); 
            compareValues("XAIUTAR.SysCoConnecting", "clear", read_data, 0);
            
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTAR.SysCoAttached')%>, read_data);
            compareValues("XAIUTAR.SysCoAttached", "clear", read_data, 0);
            
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTAR.SysCoError')%>, read_data);
            compareValues("XAIUTAR.SysCoErr", "clear", read_data, 0);
        end: check_SysCo
        
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCR.RD')%>, xaiucr_ott_rd_pool);
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCR.WR')%>, xaiucr_ott_wr_pool);
        `uvm_info(get_full_name(),$sformatf("Default value of XAIUCR.RD = 0x%0h XAIUCR.WR = 0x%0h",xaiucr_ott_rd_pool, xaiucr_ott_wr_pool),UVM_LOW)

        if ($test$plusargs("restrict_ott_pool")) begin 
        //`uvm_error(get_full_name(),$sformatf("Error out to debug"))
            xaiucr_ott_wr_pool = $urandom_range(0,3);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCR.WR')%>, xaiucr_ott_wr_pool);
        
            xaiucr_ott_rd_pool = $urandom_range(0,3);
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCR.RD')%>, xaiucr_ott_rd_pool);

            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCR.RD')%>, xaiucr_ott_rd_pool);
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCR.WR')%>, xaiucr_ott_wr_pool);
            `uvm_info(get_full_name(),$sformatf("Updated value of XAIUCR.RD = 0x%0h XAIUCR.WR = 0x%0h",xaiucr_ott_rd_pool, xaiucr_ott_wr_pool),UVM_LOW)
        end
        //CONC-16093
        //if ($test$plusargs("edr1_owo_mkunq_fullwr")) begin 
        //    read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR1')%>, edr1_rd_data);
        //    `uvm_info(get_full_name(),$sformatf("XAIUEDR1 RdData = 0x%0h",edr1_rd_data),UVM_LOW)
        //    edr1_wr_data = edr1_rd_data;
        //    edr1_wr_data[9] = 1;
        //    write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUEDR1')%>, edr1_wr_data);
        //end

    endtask
endclass : io_aiu_default_reset_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_cfg_ccp_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
	`uvm_object_utils(ioaiu_csr_cfg_ccp_seq_<%=obj.multiPortCoreId%>)

  bit ccp_lookupen;
  bit ccp_allocen;

  function new(string name="");
    super.new(name);
  endfunction:new

task body();
  <%if(obj.DutInfo.useCache){%>
  `uvm_info(get_type_name(),$sformatf("configuring  XAIUPCTCR lookupen=%0b allocen=%0b",ccp_lookupen,ccp_allocen),UVM_NONE)
  write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCTCR.LookupEn')%> ,ccp_lookupen);
  write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCTCR.AllocEn')%>  ,ccp_allocen);
<%}%>
endtask: body

endclass : ioaiu_csr_cfg_ccp_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_attach_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
	`uvm_object_utils(ioaiu_csr_attach_seq_<%=obj.multiPortCoreId%>)
	
    uvm_reg_data_t read_data,read_data1,read_data2,read_data3,read_data0, read_data_tmp, write_data, poll_data, mask, SysCoConnecting_fieldVal, SysCoAttached_fieldVal, SysCoError_fieldVal,timeout_val;
    ioaiu_scoreboard ioaiu_scb[<%=obj.DutInfo.nNativeInterfacePorts%>];
    int lsb, msb;
    bit scb_en[<%=obj.DutInfo.nNativeInterfacePorts%>];
    bit enable_attach_error;
    int        errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;
    bit [19:0]  errinfo;
    bit [51:0]  exp_addr;
    bit errinfo_check, erraddr_check;
    bit [51:0] actual_addr;
    bit [19:0] err_entry;
    bit [5:0] err_way;
    bit [5:0] err_word;
    bit [19:0] err_addr;
    
    function new(string name="");
    super.new(name);
    endfunction

    task body();

    	bit dis_uedr_ted_4resiliency;
        std::randomize(dis_uedr_ted_4resiliency)with{dis_uedr_ted_4resiliency dist {1:=20,0:=80};};
      	getCsrProbeIf();
      	getSMIIf();

     	if (($test$plusargs("wrong_sysrsp_target_id")) || ($test$plusargs("sys_rsp_err_inj_uc")) || ($test$plusargs("sys_rsp_err_inj_c"))) begin
	<% if(obj.useResiliency) { %>
	        if($test$plusargs("sys_rsp_err_inj_c"))begin
                write_data = 0;
                write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCRTR.ResThreshold')%>, write_data);
		end
		<%}%>
       		if(dis_uedr_ted_4resiliency) begin
        		`uvm_info(get_full_name(),$sformatf("Skipping-0 enabling of error detection inside xUEDR"),UVM_NONE)
      		end
      		else if ((($test$plusargs("wrong_sysrsp_target_id")) || ($test$plusargs("sys_rsp_err_inj_uc")))) begin
      			errtype = 4'h8;
      			write_data = 1;
                         <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%>
                         <% 
                         const indices = Array.from({ length: obj.DutInfo.nNativeInterfacePorts }, (_, i) => i); 
                         for (var i = 0; i < indices.length; i++) { 
                        %>
      			write_csr(<%=generateRegPath(indices[i] + '.XAIUUEDR.TransErrDetEn')%>, write_data); 
      			write_csr(<%=generateRegPath(indices[i] + '.XAIUUEIR.TransErrIntEn')%>, write_data);
                       <%}%>
                        <%} else {%>
                        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.TransErrDetEn')%>, write_data); 
     	         	write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.TransErrIntEn')%>, write_data);
                        <%}%>
      		end
		else begin
      			errtype = 4'h8;
      			write_data = 1;
      			write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
      			write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
      		end
      		ev_<%=obj.multiPortCoreId%>.trigger();      
       	end

        if($test$plusargs("timeout_attach_sys_rsp_error") || $test$plusargs("timeout_detach_sys_rsp_error")) begin
                    //enable timeout error register
                    write_data = 1; // randomly turn on error detection or dont
                    write_csr(<%=generateRegPath('0.XAIUUEDR.TimeoutErrDetEn')%>, write_data);
                    //enable interrupts
                    write_csr(<%=generateRegPath('0.XAIUUEIR.TimeoutErrIntEn')%>, write_data);
         end

        if ($test$plusargs("enable_attach_error") || $test$plusargs("attach_sys_rsp_error")) begin
     	 write_data = $urandom_range(1,0);
     	 write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.ProtErrDetEn')%>, write_data); 
     	 write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.ProtErrIntEn')%>, write_data);
        end
        //#Stimulus.IOAIU.SyscoreqTimeOutThreshold
       	timeout_val = $urandom_range(5, 2); // Timeout Value multiple of 4k cycles: 1:4096 2:8192
	if ($test$plusargs("timeout_attach_sys_rsp_error") || $test$plusargs("timeout_detach_sys_rsp_error")) begin
            `uvm_info(get_full_name(),$sformatf("Step1-0: Write Data = 0x%0h to XAIUSCPTOCR.TimeOutThreshold", write_data),UVM_LOW)
       	     write_csr(<%=generateRegPath('0.XAIUSCPTOCR.TimeOutThreshold')%>, timeout_val);
    	end
        if ( $test$plusargs("rand_event_delay")) begin
             timeout_val = 15;
             write_csr(<%=generateRegPath('0.XAIUEHTOCR.TimeOutThreshold')%>, timeout_val);
        end
      	if($test$plusargs("enable_attach_error")) begin 
        	enable_attach_error = 1'b1;
      	end

        read_csr(<%=generateRegPath('0.XAIUTAR.SysCoAttached')%>, read_data);
        `uvm_info(get_full_name(),$sformatf("Step1: Read XAIUTAR.SysCoAttached Read Data = 0x%0h and it should be 0",read_data),UVM_LOW)
        compareValues("XAIUTAR.SysCoAttached", "clear", read_data, 0);
    	
<%if ((obj.DutInfo.orderedWriteObservation == true) || ((obj.DutInfo.fnNativeInterface === "ACELITE-E") && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.DutInfo.fnNativeInterface == "ACE" || obj.DutInfo.fnNativeInterface == "ACE5") || (obj.DutInfo.useCache)) {%>
	<%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
      	if(scb_en[<%=i%>])begin
        	ioaiu_scb[<%=i%>].m_sysco_fsm_state = CONNECT;
      	end
     <%}%>
    	ev_sysco_fsm_state_change.trigger();
<%}%>

		/* XAIUTCR.SysCoAttach: Writing 1 to this bit when XAIUTAR.SysCoAttached=0 starts an attach sequence. 
    	   NOTE: This control is an OR with the SysCo HW interface signal "sysco_req" if present.*/
    	write_data = 1;
      	write_csr(<%=generateRegPath('0.XAIUTCR.SysCoAttach')%>, write_data); //Idle -> Connect 
      	`uvm_info(get_full_name(),$sformatf("Step2: Done write 1 to XAIUTCR.SysCoAttach Write Data = %0h", write_data),UVM_LOW)

      	if (!(($test$plusargs("wrong_sysrsp_target_id")) || ($test$plusargs("sys_rsp_err_inj_uc"))  || ($test$plusargs("sys_rsp_err_inj_c")||$test$plusargs("inject_smi_uncorr_error")))) begin
      		<%=generateRegPath('0.XAIUTAR')%>.read(status, read_data);
      		`uvm_info(get_full_name(),$sformatf("Step3: Read XAIUTAR Read Data = 0x%0h to check XAIUTAR.SysCoError", read_data),UVM_LOW)
      		lsb = <%=generateRegPath('0.XAIUTAR.SysCoConnecting')%>.get_lsb_pos();
  			msb = lsb + <%=generateRegPath('0.XAIUTAR.SysCoConnecting')%>.get_n_bits() - 1;

      		mask = mask_data(lsb, msb);
      		read_data_tmp = read_data & mask;
      		SysCoConnecting_fieldVal = read_data_tmp >> lsb;

			// HS 01-06-23  Not clear why this is commented out. May be timing issue?
     		// compareValues("XAIUTAR.SysCoConnecting", "set", SysCoConnecting_fieldVal, 1);
      	end	
      	
      	lsb = <%=generateRegPath('0.XAIUTAR.SysCoAttached')%>.get_lsb_pos();
  	msb = lsb + <%=generateRegPath('0.XAIUTAR.SysCoAttached')%>.get_n_bits() - 1;
        
      	mask = mask_data(lsb, msb);
      	read_data_tmp = read_data & mask;
      	SysCoAttached_fieldVal = read_data_tmp >> lsb;
        
		// HS 01-06-23  Not clear why this is commented out. May be timing issue?
     	// compareValues("XAIUTAR.SysCoAttached", "clear", SysCoAttached_fieldVal, 0);
        	
      	lsb = <%=generateRegPath('0.XAIUTAR.SysCoError')%>.get_lsb_pos();
  	msb = lsb + <%=generateRegPath('0.XAIUTAR.SysCoError')%>.get_n_bits() - 1;
        
        mask = mask_data(lsb, msb);
      	read_data_tmp = read_data & mask;
      	SysCoError_fieldVal = read_data_tmp >> lsb;
        
      	compareValues("XAIUTAR.SysCoError", "clear", SysCoError_fieldVal, 0);
       
      	if ($test$plusargs("wrong_sysrsp_target_id") &&  <%=obj.multiPortCoreId%> == 0) begin: _wrong_sysrsp_target_id_and_core0
      		fork 
      			begin
       				read_csr(<%=generateRegPath('0.XAIUTCR.SysCoAttach')%>, read_data);
      				`uvm_info(get_full_name(),$sformatf("XAIUTCR.SysCoAttach Read Data = %0h",read_data),UVM_HIGH)
      				compareValues("XAIUTCR.SysCoAttach", "set", read_data, 1);
      			end
      			begin
         			do 
         			begin
       			 		@(posedge m_smi<%=smi_portid_sysrsp%>_tx_vif.clk);
         			end while(((m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_ready === 1'b0) || /* (smi_seq_item::type2class(m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_type) != eConcMsgSysRsp) || */ (m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[obj.Id].FUnitId%>)));

        			errinfo[19:8] = m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        			errinfo[7:1] = 7'b0;
        			errinfo[0] = 1'b0; //0 for wrong targ_id
        			errinfo_check = 1;
        			erraddr_check = 0;
       
         			`uvm_info(get_full_name(),$sformatf("errinfo = %0h, exp_addr = %0h", errinfo, exp_addr),UVM_DEBUG)
      				if(dis_uedr_ted_4resiliency) begin
        				`uvm_info(get_full_name(),$sformatf("Skipping-1 enabling of error detection inside xUEDR"),UVM_NONE)
      				end
      				else begin: _not_dis_uedr_ted_4resiliency_
      					//keep on  Reading the XAIUUESR_ErrVld bit = 1
					//#Check.IOAIU.WrongTargetId.ErrVld
      					poll_UUESR_ErrVld(1, poll_data);
      					// wait for IRQ_UC interrupt 
      					fork
      						begin
							//#Check.IOAIU.WrongTargetId.IRQ_UC
          						wait (u_csr_probe_vif.IRQ_UC === 1);
      						end
      						begin
        						#200000ns;
        						`uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
      						end
      					join_any
      					disable fork;
      					read_csr(<%=generateRegPath('0.XAIUUESR.ErrType')%>, read_data);
                                        //#Check.IOAIU.WrongTargetId.ErrType
      					compareValues("UUESR_ErrType","Valid Type", read_data, errtype);
					uvm_config_db#(int)::set(null,"*","ioaiu_wrong_target_id_uesr_err_type",read_data); //for coverag
      				//	if (errinfo_check) begin
        					read_csr(<%=generateRegPath('0.XAIUUESR.ErrInfo')%>, read_data);
						uvm_config_db#(int)::set(null,"*","ioaiu_wrong_target_id_uesr_err_info",read_data); //for coverage
    						uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_info",read_data); //for coverage
                                                //#Check.IOAIU.WrongTargetId.ErrInfo
        					compareValues("UUESR_ErrInfo","Valid Type", read_data, errinfo);
      				//	end
      					if (erraddr_check) begin
       						 //Disabled address check as per CONC-6294
      					end
      					write_data = 0;
      					write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.TransErrDetEn')%>, write_data); 
						write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.TransErrIntEn')%>, write_data);
						write_data = 1;
						write_csr(<%=generateRegPath('0.XAIUUESR.ErrVld')%>, write_data);
						read_csr(<%=generateRegPath('0.XAIUUESR.ErrVld')%>, read_data); 
						compareValues("UUESR_ErrVld","should be", read_data, 0);
	cov.collect_uncorrectable_error(<%=obj.multiPortCoreId%>);
      				end: _not_dis_uedr_ted_4resiliency_
      			end
      		join
      end: _wrong_sysrsp_target_id_and_core0
      else if  ((($test$plusargs("sys_rsp_err_inj_uc")) || ($test$plusargs("sys_rsp_err_inj_c"))) &&  <%=obj.multiPortCoreId%> == 0) begin: sys_rsp_err_core0
     		fork
                	begin
      				read_csr(<%=generateRegPath('0.XAIUTCR.SysCoAttach')%>, read_data);
      				`uvm_info(get_full_name(),$sformatf("XAIUTCR.SysCoAttach Read Data = %0h",read_data),UVM_HIGH)
      				compareValues("XAIUTCR.SysCoAttach", "set", read_data, 1);
       			end

       		 	do begin
       		        @(posedge m_smi<%=smi_portid_sysrsp%>_tx_vif.clk);
                        if ($test$plusargs("sys_rsp_err_inj_uc")) begin
        	errinfo[19:8] = m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        	//errinfo[7:1] = Reserved;
        	errinfo[0] = 1'b1; // 1 for SMI Protection Error
		end else begin
		errinfo[19:16] = 4'b0; 
		errinfo[15:6] = m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
		errinfo[5:0] = 6'b0; 
		end

       		        <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
       		  	end while (m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.sys_rsp_ready_<%=obj.multiPortCoreId%> === 1'b0 || u_csr_probe_vif.sys_rsp_valid_<%=obj.multiPortCoreId%> === 1'b0|| ((smi_seq_item::type2class(m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_type) != eConcMsgSysRsp)));
       		  	<%} else {%>
       		  	end while (m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_type) != eConcMsgSysRsp) ));
       		  <% } %>
                join
		uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgSysRsp); //for coverage
               <% if(obj.useResiliency) { %>
	       if ($test$plusargs("sys_rsp_err_inj_c")) begin
                fork
                             begin
                                 wait(u_csr_probe_vif.cerr_over_thres_fault==1);
                                 `uvm_info("RUN_MAIN","fault_thres_fault is asserted", UVM_NONE) 
                             end
                  	   begin
                  	       #200000ns;
                                 `uvm_error("RUN_MAIN","fault_thres_fault isn't asserted")
                             end
                 join_any
                disable fork;
                uvm_config_db#(int)::set(null,"*","ioaiu_fault_thres_fault",u_csr_probe_vif.cerr_over_thres_fault);
		end
                <%}%> 
               <% if(obj.useResiliency) { %>
                if ($test$plusargs("sys_rsp_err_inj_uc")) begin
                fork
	           begin
                       wait(u_csr_probe_vif.fault_mission_fault==1);
                       `uvm_info("RUN_MAIN","fault_mission_fault is asserted", UVM_NONE) 
	           end
		   begin
		       #200000ns;
                       `uvm_error("RUN_MAIN","fault_mission_fault isn't asserted")
	           end
                join_any
              disable fork;
              uvm_config_db#(int)::set(null,"*","ioaiu_fault_mission_fault",u_csr_probe_vif.fault_mission_fault);
              end
             <%}%>
           if(!dis_uedr_ted_4resiliency) begin
        	if ($test$plusargs("sys_rsp_err_inj_uc")) begin
               // wait for IRQ_UC interrupt 
     		fork
     		begin
     		    //#Check.IOAIU.WrongTargetId.IRQ_UC
     		    wait (u_csr_probe_vif.IRQ_UC === 1);
     		end
     		begin
     		  #2000ns;
     		  `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
     		end
     		join_any
     		disable fork;
                 //This code handles error logging when a core change occurs due to error injection.
                 <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%>
                <% 
                const indices = Array.from({ length: obj.DutInfo.nNativeInterfacePorts }, (_, i) => i); 
                for (var i = 0; i < indices.length; i++) { 
                %>
               read_csr(<%= generateRegPath(indices[i] + '.XAIUUESR.ErrVld') %>, read_data<%= indices[i] %>);
               <% } %>                
                if(!(read_data1 || read_data2 || read_data3 || read_data0))
                `uvm_error(get_full_name(),$sformatf("Timeout! Polling ErrVld, poll_till=0x1 fieldVal=0x0"));
                <%} else {%>
                poll_UUESR_ErrVld(1, poll_data);
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data0);
                <%}%>
                uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_vld",read_data0);
                if(read_data0 == 1) begin
     		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
     		uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_type",read_data); //for coverage
     		//#Check.IOAIU.SMIProtectionType.ErrType
     		compareValues("UUESR_ErrType","Valid Type", read_data, errtype);
                //if (errinfo_check) begin
     		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
    		uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_info",read_data); //for coverage
     		//#Check.IOAIU.SMIProtectionType.ErrInfo
     		if(!$test$plusargs("smi_hdr_err_inj")) begin
                compareValues("UCESR_ErrInfo","Valid Type", read_data, errinfo);
                end else begin 
                compareValues("UCESR_ErrInfo","Valid Type", read_data[7:0], errinfo[7:0]);
                end
                end
     		write_data = 0;
     		write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.TransErrDetEn')%>, write_data); 
     		write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.TransErrIntEn')%>, write_data);
     		write_data = 1;
     		write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
     		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data); 
     		compareValues("UUESR_ErrVld","should be", read_data, 0); 
		cov.collect_uncorrectable_error(<%=obj.multiPortCoreId%>);
		end else begin
                
 		poll_UCESR_ErrVld(1, poll_data);
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data); 
                uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_vld",read_data);
     		// wait for IRQ_C interrupt 
     		fork
     		begin
     		    //#Check.IOAIU.SMIProtectionType.IRQ_C
     		    wait (u_csr_probe_vif.IRQ_C === 1);
     		end
     		begin
     		  #2000ns;
     		  `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C asserted"));
     		end
     		join_any
     		disable fork;
     		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrType')%>, read_data);
     		uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_cesr_err_type",read_data); //for coverag
     		compareValues("UCESR_ErrType","Valid Type", read_data, errtype);
     		if (errinfo_check) begin
     		  read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrInfo')%>, read_data);
     		  uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_cesr_err_type",read_data); //for coverage
     		  compareValues("UCESR_ErrInfo","Valid Type", read_data, errinfo);
     		end
     		write_data = 0;
     		write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
     		write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
     		write_data = 1;
     		write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, write_data);
     		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCount')%>, read_data);
     		compareValues("UCESR_ErrVld","should be", read_data, 0);
	        end 
                end
      end: sys_rsp_err_core0
    
      else begin: _not_wrong_sysrsp_target_id_and_core0
    		read_csr(<%=generateRegPath('0.XAIUTCR.SysCoAttach')%>, read_data);
      		`uvm_info(get_full_name(),$sformatf("Step4: Read XAIUTCR to check XAIUTCR.SysCoAttach=1"),UVM_LOW)
      		compareValues("XAIUTCR.SysCoAttach", "set", read_data, 1);
      end: _not_wrong_sysrsp_target_id_and_core0
		            	
      <%if ((obj.DutInfo.orderedWriteObservation == true) ||
      ((obj.DutInfo.fnNativeInterface === "ACELITE-E") && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) ||
      (obj.DutInfo.fnNativeInterface == "ACE" || obj.DutInfo.fnNativeInterface == "ACE5") || 
      obj.DutInfo.useCache) {%>
      
      if (!(($test$plusargs("wrong_sysrsp_target_id")) || ($test$plusargs("sys_rsp_err_inj_uc")) || ($test$plusargs("sys_rsp_err_inj_c"))||$test$plusargs("inject_smi_uncorr_error"))) begin: _not_wrong_sysrsp_tgt_id
      	    if(enable_attach_error) begin : _attach_error_
                        
                error_check("ATTACH_ERROR");
                if ($test$plusargs("timeout_detach_sys_rsp_error") || $test$plusargs("detach_sys_rsp_error"))
                    error_check("DETACH_ERROR");

      	    end: _attach_error_
      	    else begin: _not_attach_error // By default, we want to be attached

                if(!$test$plusargs("expect_mission_fault")) begin
                    poll_csr(<%=generateRegPath('0.XAIUTAR.SysCoAttached')%>, 1, poll_data);
                    `uvm_info(get_full_name(),$sformatf("Step5: XAIUTAR.SysCoAttached Poll CSR reads 1"),UVM_LOW)
                    <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                        if(scb_en[<%=i%>]) begin
                            ioaiu_scb[<%=i%>].m_sysco_fsm_state = ATTACHED;
                        end
                    <%}%>
                    ev_sysco_fsm_state_change.trigger();
                    ev_agent_is_attached.trigger();
                end else begin //CONC-9893 mission_fault
                    fork
                        begin
                            poll_csr(<%=generateRegPath('0.XAIUTAR.SysCoAttached')%>, 1, poll_data);
                            `uvm_info(get_full_name(),$sformatf("expect_mission_fault XAIUTAR.SysCoAttached Poll CSR reads 1"),UVM_LOW)
                            <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                            if(scb_en[<%=i%>]) begin
                                ioaiu_scb[<%=i%>].m_sysco_fsm_state = ATTACHED;
                            end
                            <%}%>
                            ev_sysco_fsm_state_change.trigger();
                            ev_agent_is_attached.trigger();
                        end
                        <% if(obj.useResiliency) { %>
                        begin
                            #(100*1ns);
                            wait(u_csr_probe_vif.fault_mission_fault === 1'b1);
                        end
                        <%}%>
                    join_any
                end //mission_fault
 
      	    end:  _not_attach_error
      end: _not_wrong_sysrsp_tgt_id
      <%}%>
        

	  //Below checks make sure for non-Attach Error tests, after agent is successfully attached, XAIUTAR.SysCoConnecting=0 and XAIUTAR.SysCoError=0
      if(!enable_attach_error) begin
          //  if (!$test$plusargs("wrong_sysrsp_target_id")) begin: _not_wrong_sysrsp_tgt_id
            if (!(($test$plusargs("wrong_sysrsp_target_id")) || ($test$plusargs("sys_rsp_err_inj_uc")) || ($test$plusargs("sys_rsp_err_inj_c"))||$test$plusargs("inject_smi_uncorr_error"))) begin
                read_csr(<%=generateRegPath('0.XAIUTAR.SysCoConnecting')%>, read_data);
        	`uvm_info(get_full_name(),$sformatf("Step7: XAIUTAR.SysCoConnecting Read Data = %0h",read_data),UVM_LOW)
        	compareValues("XAIUTAR.SysCoConnecting", "clear", read_data, 0);
            end

            // By default, we want to be attached, so Error should not be flagged
          fork
           begin
            read_csr(<%=generateRegPath('0.XAIUTAR.SysCoError')%>, read_data);
       	    `uvm_info(get_full_name(),$sformatf("Step7: XAIUTAR.SysCoError Read Data = %0h",read_data),UVM_LOW)
            compareValues("XAIUTAR.SysCoError", "clear", read_data, 0);
           end 
           begin
            read_csr(<%=generateRegPath('0.XAIUTCR.SysCoAttach')%>, read_data);
            `uvm_info(get_full_name(),$sformatf("Step6: XAIUTCR.SysCoAttach Read Data = %0h", read_data),UVM_LOW)
            compareValues("XAIUTCR.SysCoAttach", "set", read_data, 1);
           end 
          join
      end 	 
	endtask: body

        task error_check(string sysco_fsm_state);

      	    `uvm_info(get_full_name(),$sformatf("tsk:error_check entry sysco_fsm_state:%0s", sysco_fsm_state),UVM_LOW)
            if ($test$plusargs("timeout_attach_sys_rsp_error") || $test$plusargs("timeout_detach_sys_rsp_error")) begin
      	        `uvm_info(get_full_name(),$sformatf("Step5: Waiting for ev_sysco_protocol_timeout event in sysco_timeout tests"),UVM_LOW)
          	ev_sysco_protocol_timeout.wait_trigger();
          	#<%=obj.Clocks[0].params.period%>ps; 
            end else begin // We should receive all sys_rsp with errors
      	        `uvm_info(get_full_name(),$sformatf("Step5: Waiting for ev_sysco_all_sys_rsp_received event in sysco sysrsp_error tests"),UVM_LOW)
          	ev_sysco_all_sys_rsp_received.wait_trigger();
          	#(<%=obj.Clocks[0].params.period%>ps*3); //3 cycles to allow RTL goes through all FSM states
            end

            //Update the sysco_fsm_state to indicate error
            <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
	        if(scb_en[<%=i%>]) begin
        	    ioaiu_scb[<%=i%>].m_sysco_fsm_state = (sysco_fsm_state == "ATTACH_ERROR") ? ATTACH_ERROR : DETACH_ERROR;
            end
            <%}%>
            ev_sysco_fsm_state_change.trigger();
           
            fork 
                if ($test$plusargs("timeout_attach_sys_rsp_error") || $test$plusargs("timeout_detach_sys_rsp_error")) begin:_check_uuesr_ 
      	            `uvm_info(get_full_name(),$sformatf("Step6: Start poll for XAIUUESR.ErrVld in timeout sysco error tests"),UVM_LOW)
                    //#Check.IOAIU.SyscoreqTimeOutError.ErrVld
                    do begin
                        read_csr(<%=generateRegPath('0.XAIUUESR.ErrVld')%>, read_data);
                    end while (read_data == 0);
      	            `uvm_info(get_full_name(),$sformatf("Step6: XAIUUESR.ErrVld=1 in timeout sysco error tests"),UVM_LOW)
      		     //#Check.IOAIU.SyscoreqTimeOutError.ErrType		
                    `uvm_info(get_full_name(),$sformatf("Step7: Read XAIUUESR.ErrType=0xb in sysco_timeout tests"),UVM_LOW)
                    read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
      		    compareValues("XAIUUESR.ErrType","should be",read_data, 4'b1011);
                    uvm_config_db#(int)::set(null,"*","ioaiu_sysco_time_out_uesr_err_type",read_data); //for coverag
                    
                    //irq_check
                    //#Check.IOAIU.SyscoreqTimeOutError.IRQ_UC
                    fork
      		        begin
          	    	    wait (u_csr_probe_vif.IRQ_UC === 1);
      		    end
      		    begin
        	        #200000ns;
                   	`uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
      		    end
                    join_any
                    disable fork;
		    //#Check.IOAIU.SyscoreqTimeOutError.ErrInfo 
		    read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
		    
      		    uvm_config_db#(int)::set(null,"*","ioaiu_sysco_time_out_uesr_err_info",read_data); //for coverag 
                    compareValues("IOAIUUUESR.ErrInfo","should be",read_data,0);
		    
		    //Clear the error register
                    //#($urandom_range(50,1) * 1us); //wait for random amount of time before clearing error
                    #(<%=obj.Clocks[0].params.period%>ps*2);
      		    `uvm_info(get_full_name(),$sformatf("Step8: Write 1 to clear XAIUUESR.ErrVld in sysco_timeout tests"),UVM_LOW)
                    write_csr(<%=generateRegPath('0.XAIUUESR.ErrVld')%>, 1);

                end: _check_uuesr_
                begin: _poll_sysco_err_
      	            `uvm_info(get_full_name(),$sformatf("Step6: Start poll for XAIUTAR.SysCoError in sysco error tests"),UVM_LOW)
                    do begin
                        read_csr(<%=generateRegPath('0.XAIUTAR.SysCoError')%>, read_data);
                    end while (read_data == 0);
      	            `uvm_info(get_full_name(),$sformatf("Step6: XAIUTAR.SysCoError=1 in sysco error tests"),UVM_LOW)
                end:_poll_sysco_err_
            join

            //Write 1 to SysCoAttach to stop the attach process after fsm goes to IDLE
            write_csr(<%=generateRegPath('0.XAIUTCR.SysCoAttach')%>, 0); 

      	    `uvm_info(get_full_name(),$sformatf("tsk:error_check exit sysco_fsm_state:%0s", sysco_fsm_state),UVM_LOW)

        endtask: error_check
	
endclass : ioaiu_csr_attach_seq_<%=obj.multiPortCoreId%>


class ioaiu_csr_detach_seq_<%=obj.multiPortCoreId%> extends ioaiu_csr_attach_seq_<%=obj.multiPortCoreId%>;
    `uvm_object_utils(ioaiu_csr_detach_seq_<%=obj.multiPortCoreId%>)
	
    uvm_reg_data_t read_data, read_data_tmp, write_data, poll_data, mask, SysCoConnecting_fieldVal, SysCoAttached_fieldVal, SysCoError_fieldVal,timeout_val;
    int lsb, msb;

    function new(string name="");
    	super.new(name);
    endfunction

    task body();

        getCsrProbeIf();

        <%=generateRegPath('0.XAIUTAR')%>.read(status, read_data);
        `uvm_info(get_full_name(),$sformatf("Step1:XAIUTAR Read Data = 0x%0h", read_data),UVM_LOW)

        lsb = <%=generateRegPath('0.XAIUTAR.SysCoAttached')%>.get_lsb_pos();
        msb = lsb + <%=generateRegPath('0.XAIUTAR.SysCoAttached')%>.get_n_bits() - 1;
        mask = mask_data(lsb, msb);
        read_data_tmp = read_data & mask;
        SysCoAttached_fieldVal = read_data_tmp >> lsb;
        compareValues("XAIUTAR.SysCoAttached start of Detach seq", "set", SysCoAttached_fieldVal, 1);
    	
        lsb = <%=generateRegPath('0.XAIUTAR.SysCoConnecting')%>.get_lsb_pos();
        msb = lsb + <%=generateRegPath('0.XAIUTAR.SysCoConnecting')%>.get_n_bits() - 1;
        mask = mask_data(lsb, msb);
        read_data_tmp = read_data & mask;
        SysCoConnecting_fieldVal = read_data_tmp >> lsb;
        compareValues("XAIUTAR.SysCoConnecting Start of Detach seq", "clear", SysCoConnecting_fieldVal, 0);
        
        lsb = <%=generateRegPath('0.XAIUTAR.SysCoError')%>.get_lsb_pos();
        msb = lsb + <%=generateRegPath('0.XAIUTAR.SysCoError')%>.get_n_bits() - 1;
        mask = mask_data(lsb, msb);
        read_data_tmp = read_data & mask;
        SysCoError_fieldVal = read_data_tmp >> lsb;
        compareValues("XAIUTAR.SysCoError start of detach seq", "clear", SysCoError_fieldVal, 0);

	<%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
        if(scb_en[<%=i%>]) begin
            ioaiu_scb[<%=i%>].m_sysco_fsm_state = DETACH;
        end
        <%}%>
        ev_sysco_fsm_state_change.trigger();
        
        `uvm_info(get_full_name(),$sformatf("Step2:XAIUTCR.SysCoAttach Write Data=0 to initiate a Detach sequence"),UVM_LOW)
        write_csr(<%=generateRegPath('0.XAIUTCR.SysCoAttach')%>, 0); //Attached -> Detach
        read_csr(<%=generateRegPath('0.XAIUTCR.SysCoAttach')%>, read_data);
        compareValues("XAIUTCR.SysCoAttach", "clear", read_data, 0);

        if ($test$plusargs("enable_detach_error") || $test$plusargs("detach_sys_rsp_error")) begin
     	 write_data = 1;
     	 write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.ProtErrDetEn')%>, write_data); 
     	 write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.ProtErrIntEn')%>, write_data);
        end

        if($test$plusargs("enable_detach_error")) begin 
            error_check("DETACH_ERROR"); 
        end else begin //!enable_detach_error
            poll_csr(<%=generateRegPath('0.XAIUTAR.SysCoAttached')%>, 0, poll_data);
	    <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            if(scb_en[<%=i%>]) begin
                ioaiu_scb[<%=i%>].m_sysco_fsm_state = IDLE;
            end
            <%}%>
            ev_sysco_fsm_state_change.trigger();
            ev_agent_is_detached.trigger();
        end

        #(<%=obj.Clocks[0].params.period%>ps*3); //3 cycles to allow RTL to relax
        <%=generateRegPath('0.XAIUTAR')%>.read(status, read_data);
        `uvm_info(get_full_name(),$sformatf("XAIUTAR Read Data = 0x%0h after Detach sequence completion", read_data),UVM_LOW)

        lsb = <%=generateRegPath('0.XAIUTAR.SysCoConnecting')%>.get_lsb_pos();
        msb = lsb + <%=generateRegPath('0.XAIUTAR.SysCoConnecting')%>.get_n_bits() - 1;
        mask = mask_data(lsb, msb);
        read_data_tmp = read_data & mask;
        SysCoConnecting_fieldVal = read_data_tmp >> lsb;
        compareValues("XAIUTAR.SysCoConnecting", "clear", SysCoConnecting_fieldVal, 0);
    
        lsb = <%=generateRegPath('0.XAIUTAR.SysCoAttached')%>.get_lsb_pos();
        msb = lsb + <%=generateRegPath('0.XAIUTAR.SysCoAttached')%>.get_n_bits() - 1;
        mask = mask_data(lsb, msb);
        read_data_tmp = read_data & mask;
        SysCoAttached_fieldVal = read_data_tmp >> lsb;
        compareValues("XAIUTAR.SysCoAttached", "clear", SysCoAttached_fieldVal, 0);

        lsb = <%=generateRegPath('0.XAIUTAR.SysCoError')%>.get_lsb_pos();
        msb = lsb + <%=generateRegPath('0.XAIUTAR.SysCoError')%>.get_n_bits() - 1;
        mask = mask_data(lsb, msb);
        read_data_tmp = read_data & mask;
        SysCoError_fieldVal = read_data_tmp >> lsb;
        if($test$plusargs("enable_detach_error"))
            compareValues("XAIUTAR.SysCoError", "set", SysCoError_fieldVal, 1);
        else     
            compareValues("XAIUTAR.SysCoError", "clear", SysCoError_fieldVal, 0);

        read_csr(<%=generateRegPath('0.XAIUTCR.SysCoAttach')%>, read_data);
        `uvm_info(get_full_name(),$sformatf("XAIUTCR.SysCoAttach Read Data = %0h after Detach sequence completion",read_data),UVM_LOW)
        compareValues("XAIUTCR.SysCoAttach", "clear", read_data, 0);      

    endtask
	
endclass : ioaiu_csr_detach_seq_<%=obj.multiPortCoreId%>

//#Check.IOAIU.IllegalNSAccess_ErrorLogging
class ioaiu_csr_illegal_security_nsaccess_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
  `uvm_object_utils(ioaiu_csr_illegal_security_nsaccess_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, write_data;
    bit [WSMIADDR-1:0] exp_addr;
    bit [51:0]actual_addr;
    bit [19:0] err_entry;
    bit [5:0] err_way;
    bit [5:0] err_word;
    bit [19:0] err_addr;
    bit [31:0] err_addr0;
    bit [19:0] exp_errinfo;
    bit [19:0] exp_errinfo_q[$];
    bit [WSMIADDR-1:0] exp_addr_q[$];
    ioaiu_scoreboard ioaiu_scb;



    function new(string name="");
        super.new(name);
    endfunction

   task body();
    getCsrProbeIf();
        if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                               .inst_name( "*" ),
                                               .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                               .value( ioaiu_scb ))) begin
          `uvm_error("ioaiu_csr_illegal_security_nsaccess", "ioaiu_scb model not found")
        end

            write_data = 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.DecErrDetEn')%>, write_data); 
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.DecErrIntEn')%>, write_data);
         
            ev_<%=obj.multiPortCoreId%>.trigger();
           fork
              ev_ar_req_<%=obj.multiPortCoreId%>.wait_ptrigger();
              ev_aw_req_<%=obj.multiPortCoreId%>.wait_ptrigger();
            join_any

      //keep on  Reading the XAIUUESR_ErrVld bit = 1
            //#Check.IOAIU.IllegalSecurityAccess.ErrVld
            poll_UUESR_ErrVld(1, poll_data);
             
           foreach (ioaiu_scb.csr_addr_decode_err_addr_q[i]) begin
            exp_addr = ioaiu_scb.csr_addr_decode_err_addr_q[i];
            exp_errinfo[3:0] = 4'b0100; //4'b0100: Illegal security access
            exp_errinfo[5:4] = ioaiu_scb.csr_addr_decode_err_cmd_type_q[i]; //Command Type
            exp_errinfo[7:6] = 0;
            exp_errinfo[19:8] = ioaiu_scb.csr_addr_decode_err_msg_id_q[i]; //Transaction ID/AXID
            
           
            exp_errinfo_q.push_back(exp_errinfo);
            exp_addr_q.push_back(exp_addr);
           end
            //#Check.IOAIU.IllegalSecurityAccess.ErrInfo
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
	    uvm_config_db#(int)::set(null,"*","ioaiu_decode_uesr_err_info",read_data); //for coverage
            `uvm_info(get_full_name(),$sformatf("exp_addr = %0h, exp_errinfo = %0h",exp_addr,exp_errinfo),UVM_NONE)
            if (!(read_data inside {exp_errinfo_q})) begin
             `uvm_error(get_full_name(),$sformatf("Expected ErrInfo inside %0p, Actual ErrInfo = %0h",exp_errinfo_q,read_data))
            end
            //#Check.IOAIU.IllegalSecurityAccess.ErrType
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
	    uvm_config_db#(int)::set(null,"*","ioaiu_decode_uesr_err_type",read_data); //for coverage
            compareValues("XAIUUESR_ErrType", "", read_data, 7);
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrAddr')%>, read_data);
            err_addr0 = read_data;
//          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrEntry')%>, read_data);
//          err_entry = read_data;
//          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWay')%>, read_data);
//          err_way = read_data;
//          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWord')%>, read_data);
//          err_word = read_data;
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR1.ErrAddr')%>, read_data);
            err_addr = read_data;
            actual_addr = {err_addr,err_addr0};
            if (!(actual_addr inside {exp_addr_q})) begin
                    `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, exp_addr))
                  end
            //#Check.IOAIU.IllegalSecurityAccess.IRQ_UC
            fork
                begin
                    wait (u_csr_probe_vif.IRQ_UC === 1);
                end
                begin
                  #200000ns;
                  `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
                end
              join_any
            disable fork;

            write_data = 0;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.DecErrDetEn')%>, write_data); 
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.DecErrIntEn')%>, write_data);

            write_data = 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
            // Read the XAIUUESR_ErrVld should be cleared
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
            compareValues("XAIUUESR_ErrVld", "now clear", read_data, 0);

    endtask 
endclass : ioaiu_csr_illegal_security_nsaccess_<%=obj.multiPortCoreId%>

//#Check.IOAIU.CoherentDIIAccess_ErrorLogging
class ioaiu_csr_illegal_dii_access_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
  `uvm_object_utils(ioaiu_csr_illegal_dii_access_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, write_data;
    bit [WSMIADDR-1:0] exp_addr;
    bit [51:0]actual_addr;
    bit [19:0] err_entry;
    bit [5:0] err_way;
    bit [5:0] err_word;
    bit [19:0] err_addr;
    bit [31:0] err_addr0;
    bit [19:0] exp_errinfo;
    bit [19:0] exp_errinfo_q[$];
    bit [WSMIADDR-1:0] exp_addr_q[$];
    ioaiu_scoreboard ioaiu_scb;



    function new(string name="");
        super.new(name);
    endfunction

   task body();
    getCsrProbeIf();
        if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                               .inst_name( "*" ),
                                               .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                               .value( ioaiu_scb ))) begin
          `uvm_error("ioaiu_csr_illegal_security_nsaccess", "ioaiu_scb model not found")
        end

            write_data = 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.DecErrDetEn')%>, write_data); 
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.DecErrIntEn')%>, write_data);
         
            ev_<%=obj.multiPortCoreId%>.trigger();
           fork
              ev_ar_req_<%=obj.multiPortCoreId%>.wait_ptrigger();
              ev_aw_req_<%=obj.multiPortCoreId%>.wait_ptrigger();
            join_any

      //keep on  Reading the XAIUUESR_ErrVld bit = 1
            //#Check.IOAIU.IllegaIOpToDII.ErrVld
            poll_UUESR_ErrVld(1, poll_data);
            //#Check.IOAIU.IllegaIOpToDII.ErrInfo  
           foreach (ioaiu_scb.csr_addr_decode_err_addr_q[i]) begin
            exp_addr = ioaiu_scb.csr_addr_decode_err_addr_q[i];
            exp_errinfo[3:0] = 4'b0011; //4'b0011 Illegal DII access type
            exp_errinfo[5:4] = ioaiu_scb.csr_addr_decode_err_cmd_type_q[i]; //Command Type
            exp_errinfo[7:6] = 0;  // Reserved
            exp_errinfo[19:8] = ioaiu_scb.csr_addr_decode_err_msg_id_q[i]; //Transaction ID/AXID
            exp_errinfo_q.push_back(exp_errinfo);
            exp_addr_q.push_back(exp_addr);
           end
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
	    uvm_config_db#(int)::set(null,"*","ioaiu_decode_uesr_err_info",read_data); //for coverag
            `uvm_info(get_full_name(),$sformatf("exp_addr = %0h, exp_errinfo = %0h",exp_addr,exp_errinfo),UVM_NONE)
            if (!(read_data inside {exp_errinfo_q})) begin
             `uvm_error(get_full_name(),$sformatf("Expected ErrInfo inside %0p, Actual ErrInfo = %0h",exp_errinfo_q,read_data))
            end
            //#Check.IOAIU.IllegaIOpToDII.ErrType
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
	    uvm_config_db#(int)::set(null,"*","ioaiu_decode_uesr_err_type",read_data); //for coverage
            compareValues("XAIUUESR_ErrType", "", read_data, 7);
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrAddr')%>, read_data);
            err_addr0 = read_data;
//          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrEntry')%>, read_data);
//          err_entry = read_data;
//          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWay')%>, read_data);
//          err_way = read_data;
//          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWord')%>, read_data);
//          err_word = read_data;
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR1.ErrAddr')%>, read_data);
            err_addr = read_data;
            actual_addr = {err_addr,err_addr0};
            //#Check.IOAIU.IllegaIOpToDII.IRQ_UC
            if (!(actual_addr inside {exp_addr_q})) begin
                    `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, exp_addr))
                  end
            fork
                begin
                    wait (u_csr_probe_vif.IRQ_UC === 1);
                end
                begin
                  #200000ns;
                  `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
                end
              join_any
            disable fork;

            write_data = 0;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.DecErrDetEn')%>, write_data); 
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.DecErrIntEn')%>, write_data);

            write_data = 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
            // Read the XAIUUESR_ErrVld should be cleared
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
            compareValues("XAIUUESR_ErrVld", "now clear", read_data, 0);

    endtask 
endclass : ioaiu_csr_illegal_dii_access_<%=obj.multiPortCoreId%>

class ioaiu_csr_illegal_format_access_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
  `uvm_object_utils(ioaiu_csr_illegal_format_access_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, write_data;
    bit [WSMIADDR-1:0] exp_addr;
    bit [51:0]actual_addr;
    bit [19:0] err_entry;
    bit [5:0] err_way;
    bit [5:0] err_word;
    bit [19:0] err_addr;
    bit [31:0] err_addr0;
    bit [19:0] exp_errinfo;
    bit [19:0] exp_errinfo_q[$];
    bit [WSMIADDR-1:0] exp_addr_q[$];
    ioaiu_scoreboard ioaiu_scb;



    function new(string name="");
        super.new(name);
    endfunction

   task body();
    getCsrProbeIf();
        if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                               .inst_name( "*" ),
                                               .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                               .value( ioaiu_scb ))) begin
          `uvm_error("ioaiu_csr_illegal_security_nsaccess", "ioaiu_scb model not found")
        end

            write_data = 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.DecErrDetEn')%>, write_data); 
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.DecErrIntEn')%>, write_data);
         
            ev_<%=obj.multiPortCoreId%>.trigger();
           fork
              ev_ar_req_<%=obj.multiPortCoreId%>.wait_ptrigger();
              ev_aw_req_<%=obj.multiPortCoreId%>.wait_ptrigger();
            join_any

      //keep on  Reading the XAIUUESR_ErrVld bit = 1
            //#Check.IOAIU.IllegalCSRaccess.ErrVld
            poll_UUESR_ErrVld(1, poll_data);
             
           foreach (ioaiu_scb.csr_addr_decode_err_addr_q[i]) begin
            exp_addr = ioaiu_scb.csr_addr_decode_err_addr_q[i];
            exp_addr = ioaiu_scb.csr_addr_decode_err_addr_q[i];
            <%if(obj.AiuInfo[obj.Id].fnCsrAccess  == 0) {%>
            exp_errinfo[3:0] = 4'b0000; //4'b0010 Illegal CSR Format access type
            <% } else {%>
	    exp_errinfo[3:0] = 4'b0010; //4'b0010 Illegal CSR Format access type
            <% }%>
            exp_errinfo[5:4] = ioaiu_scb.csr_addr_decode_err_cmd_type_q[i];
	    exp_errinfo[7:6] = 0;
	    exp_errinfo[19:8] = ioaiu_scb.csr_addr_decode_err_msg_id_q[i]; //Transaction ID/AXID            
	    exp_errinfo_q.push_back(exp_errinfo);
            exp_addr_q.push_back(exp_addr);
           end
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
            `uvm_info(get_full_name(),$sformatf("exp_addr = %0h, exp_errinfo = %0h",exp_addr,exp_errinfo),UVM_NONE)
             uvm_config_db#(int)::set(null,"*","ioaiu_decode_uesr_err_info",read_data); //for coverage
            //#Check.IOAIU.IllegalCSRaccess.ErrInfo
            if (!(read_data inside {exp_errinfo_q})) begin
             `uvm_error(get_full_name(),$sformatf("Expected ErrInfo inside %0p, Actual ErrInfo = %0h",exp_errinfo_q,read_data))
            end
            //#Check.IOAIU.IllegalCSRaccess.ErrType
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
            uvm_config_db#(int)::set(null,"*","ioaiu_decode_uesr_err_type",read_data); //for coverage
            compareValues("XAIUUESR_ErrType", "", read_data, 7);
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrAddr')%>, read_data);
            err_addr0 = read_data;
//          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrEntry')%>, read_data);
//          err_entry = read_data;
//          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWay')%>, read_data);
//          err_way = read_data;
//          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWord')%>, read_data);
//          err_word = read_data;
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR1.ErrAddr')%>, read_data);
            err_addr = read_data;
            actual_addr = {err_addr,err_addr0};
            //#Check.IOAIU.IllegalCSRaccess.IRQ_UC
            if (!(actual_addr inside {exp_addr_q})) begin
                    `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, exp_addr))
                  end
            fork
                begin
                    wait (u_csr_probe_vif.IRQ_UC === 1);
                end
                begin
                  #200000ns;
                  `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
                end
              join_any
            disable fork;

            write_data = 0;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.DecErrDetEn')%>, write_data); 
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.DecErrIntEn')%>, write_data);

            write_data = 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
            // Read the XAIUUESR_ErrVld should be cleared
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
            compareValues("XAIUUESR_ErrVld", "now clear", read_data, 0);

    endtask 
endclass : ioaiu_csr_illegal_format_access_<%=obj.multiPortCoreId%>


class ioaiu_csr_address_region_overlap_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
  `uvm_object_utils(ioaiu_csr_address_region_overlap_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, write_data;
    bit [WSMIADDR-1:0] exp_addr;
    bit [51:0]actual_addr;
    bit [19:0] err_entry;
    bit [5:0] err_way;
    bit [5:0] err_word;
    bit [19:0] err_addr;
    bit [31:0] err_addr0;
    bit [19:0] exp_errinfo;
    ioaiu_scoreboard ioaiu_scb;
    bit [addrMgrConst::W_SEC_ADDR -1:0] laddr;
    bit [addrMgrConst::W_SEC_ADDR -1:0] uaddr;
    bit [addrMgrConst::W_SEC_ADDR -1:0] random_cfg_addr;
    int selected_addr_map_index;
    int ndmi = 1;
    int nuber_of_random_addr = 2;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        getCsrProbeIf();
        if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                               .inst_name( "*" ),
                                               .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                               .value( ioaiu_scb ))) begin
          `uvm_error("ioaiu_csr_address_region_overlap_seq", "ioaiu_scb model not found")
        end

            // Set the XAIUUECR_ErrDetEn = 1
            write_data = 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.DecErrDetEn')%>, write_data); 
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.DecErrIntEn')%>, write_data);

        <% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
        <% } %>
            ev_<%=obj.multiPortCoreId%>.trigger();
           
            //keep on  Reading the XAIUUESR_ErrVld bit = 1
            //#Check.IOAIU.MultipleAddrhit.ErrVld
            poll_UUESR_ErrVld(1, poll_data);
            exp_addr = ioaiu_scb.csr_addr_decode_err_addr_q[0];
            exp_errinfo[3:0] = 4'b0001;   // Multiple address hit
            exp_errinfo[5:4] = ioaiu_scb.csr_addr_decode_err_cmd_type_q[0];
            exp_errinfo[7:6] = 0;
            exp_errinfo[19:8] = ioaiu_scb.csr_addr_decode_err_msg_id_q[0]; //Transaction ID/AXID
            `uvm_info(get_full_name(),$sformatf("exp_addr = %0h, exp_errinfo = %0h",exp_addr,exp_errinfo),UVM_NONE)
            //#Check.IOAIU.MultipleAddrhit.ErrInfo
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
            uvm_config_db#(int)::set(null,"*","ioaiu_decode_uesr_err_info",read_data); //for coverag
            compareValues("XAIUUESR_ErrInfo", "", read_data, exp_errinfo);
            //#Check.IOAIU.MultipleAddrhit.ErrType
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
	    uvm_config_db#(int)::set(null,"*","ioaiu_decode_uesr_err_type",read_data); //for coverage
            compareValues("XAIUUESR_ErrType", "", read_data, 7);
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrAddr')%>, read_data);
            err_addr0 = read_data;
//          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrEntry')%>, read_data);
//          err_entry = read_data;
//          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWay')%>, read_data);
//          err_way = read_data;
//          read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWord')%>, read_data);
//          err_word = read_data;
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR1.ErrAddr')%>, read_data);
            err_addr = read_data;
            actual_addr = {err_addr,err_addr0};
            //#Check.IOAIU.MultipleAddrhit.IRQ_UC
            if (actual_addr !== exp_addr) begin
                    `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, exp_addr))
                  end
            fork
                begin
                    wait (u_csr_probe_vif.IRQ_UC === 1);
                end
                begin
                  #200000ns;
                  `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
                end
              join_any
            disable fork;

            write_data = 0;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.DecErrDetEn')%>, write_data); 
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.DecErrIntEn')%>, write_data);

            write_data = 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
            // Read the XAIUUESR_ErrVld should be cleared
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
            compareValues("XAIUUESR_ErrVld", "now clear", read_data, 0);

    endtask

endclass : ioaiu_csr_address_region_overlap_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_no_address_hit_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
  `uvm_object_utils(ioaiu_csr_no_address_hit_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, write_data;
    bit [WSMIADDR-1:0] exp_addr;
    bit [WSMIADDR-1:0] exp_addr_q[$];
    bit [51:0]actual_addr;
    bit [19:0] err_entry;
    bit [5:0] err_way;
    bit [5:0] err_word;
    bit [19:0] err_addr;
    bit [31:0] err_addr0;
    ioaiu_scoreboard ioaiu_scb;
    //rand bit [47:0] unmapped_lower_addr, range_select;
    //bit [47:0] unmapped_upper_addr;
    //bit [47:0] all_end_addr[$];
    //bit [47:0] max_end_addr[$];
    //typedef struct {
    //        bit [47:0] start_addr;
    //        bit [47:0] end_addr;
    //       } s;
    //s all_addr_range[$];
    //int addr_size[$];
    //int max_addr_size[$];
    //int min_addr_size[$];
    //bit [31:0] addr_low;
    //bit [3:0] addr_high;
    bit [19:0] exp_errinfo;
    bit [19:0] exp_errinfo_q[$];

    function new(string name="");
        super.new(name);
    endfunction

    //function void post_randomize();
    //  unmapped_upper_addr = (unmapped_lower_addr+((2**(range_select+12))-1));
    //  `uvm_info(get_full_name(),$sformatf("unmapped_lower_addr = 0x%0x, unmapped_upper_addr = 0x%0x",unmapped_lower_addr, unmapped_upper_addr),UVM_NONE)
    //endfunction

    task body();
        //addrMgrConst::sys_addr_csr_t csrq[$];
        //csrq = addrMgrConst::get_all_gpra();
        getCsrProbeIf();
        if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                               .inst_name( "*" ),
                                               .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                               .value( ioaiu_scb ))) begin
          `uvm_error("ioaiu_csr_no_address_hit_seq", "ioaiu_scb model not found")
        end
        //foreach (csrq[i]) begin
        //  `uvm_info(get_name(),
        //      $psprintf("unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d",
        //          csrq[i].unit.name(), csrq[i].mig_nunitid,
        //          csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),
        //      UVM_NONE)
        //  addr_size.push_back(csrq[i].size);
        //end

        //     max_addr_size = addr_size.max();
        //     min_addr_size = addr_size.min();
        //     `uvm_info(get_full_name(), $sformatf("max_addr_size = %0d",max_addr_size[0]), UVM_NONE)

        //     all_addr_range.push_back('{addrMgrConst::BOOT_REGION_BASE,((addrMgrConst::BOOT_REGION_BASE + addrMgrConst::BOOT_REGION_SIZE)-1)});
        //     all_addr_range.push_back('{addrMgrConst::NRS_REGION_BASE,((addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE)-1)});
        //     all_end_addr.push_back((addrMgrConst::BOOT_REGION_BASE + addrMgrConst::BOOT_REGION_SIZE)-1);
        //     all_end_addr.push_back((addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE)-1);
        //     foreach(addrMgrConst::memregion_boundaries[i]) begin
        //       all_addr_range.push_back('{addrMgrConst::memregion_boundaries[i].start_addr,(addrMgrConst::memregion_boundaries[i].end_addr-1)});
        //       all_end_addr.push_back(addrMgrConst::memregion_boundaries[i].end_addr);
        //     end
        //     max_end_addr = all_end_addr.max();
        //     `uvm_info(get_full_name(), $sformatf("all_addr_range = %0p, max_end_addr = 0x%0x", all_addr_range, max_end_addr[0]), UVM_NONE)

        //     this.randomize() with { foreach(all_addr_range[i])
        //                             {
        //                               !(unmapped_lower_addr inside {[all_addr_range[i].start_addr:all_addr_range[i].end_addr]});
        //                               (unmapped_lower_addr < all_addr_range[i].start_addr) -> ((unmapped_lower_addr + (2**(range_select+12))) < all_addr_range[i].start_addr);
        //                             }
        //                             48'(unmapped_lower_addr+(2**(range_select+12))) == 49'(unmapped_lower_addr+(2**(range_select+12)));
        //                             unmapped_lower_addr == ((unmapped_lower_addr >> (range_select+12)) << (range_select+12));
        //                             range_select <= max_addr_size[0];
        //                             range_select >= min_addr_size[0];
        //                             unmapped_lower_addr <= max_end_addr[0];
        //                           };

        //     addr_low = unmapped_lower_addr[43:0] >> 12;
        //     addr_high = unmapped_lower_addr[47:44];
        //     `uvm_info(get_full_name(), $sformatf("addr_low = 0x%0x, addr_high = 0x%0x", addr_low, addr_high), UVM_NONE)

            // Set the XAIUUECR_ErrDetEn = 1
            write_data = 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.DecErrDetEn')%>, write_data); 
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.DecErrIntEn')%>, write_data);

            ev_<%=obj.multiPortCoreId%>.trigger();
           
            fork
              ev_ar_req_<%=obj.multiPortCoreId%>.wait_ptrigger();
              ev_aw_req_<%=obj.multiPortCoreId%>.wait_ptrigger();
            join
            if (ioaiu_scb.csr_addr_decode_err_addr_q.size() != 0) begin
              //keep on  Reading the XAIUUESR_ErrVld bit = 1
              //#Check.IOAIU.NoAddresshit.ErrVld
              poll_UUESR_ErrVld(1, poll_data);
              if (ioaiu_scb.csr_addr_decode_err_addr_q.size() == 1) begin
                exp_addr = ioaiu_scb.csr_addr_decode_err_addr_q[0];
                exp_errinfo[3:0] = 4'b0000; // no address hit 
                exp_errinfo[5:4] = ioaiu_scb.csr_addr_decode_err_cmd_type_q[0]; 
                exp_errinfo[7:6] = 0; //reserved 
                exp_errinfo[19:8] = ioaiu_scb.csr_addr_decode_err_msg_id_q[0];
                `uvm_info(get_full_name(),$sformatf("exp_addr = %0h, exp_errinfo = %0h",exp_addr,exp_errinfo),UVM_NONE)
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
	        uvm_config_db#(int)::set(null,"*","ioaiu_decode_uesr_err_info",read_data); //for coverage
                //#Check.IOAIU.NoAddresshit.ErrInfo
                compareValues("XAIUUESR_ErrInfo", "", read_data, exp_errinfo);
                //#Check.IOAIU.NoAddresshit.ErrType
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
		uvm_config_db#(int)::set(null,"*","ioaiu_decode_uesr_err_type",read_data); //for coverage
                compareValues("XAIUUESR_ErrType", "", read_data, 7);
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrAddr')%>, read_data);
                err_addr0 = read_data;
//              read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrEntry')%>, read_data);
//              err_entry = read_data;
//              read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWay')%>, read_data);
//              err_way = read_data;
//              read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWord')%>, read_data);
//              err_word = read_data;
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR1.ErrAddr')%>, read_data);
                err_addr = read_data;
                actual_addr = {err_addr,err_addr0};
                if (actual_addr !== exp_addr) begin
                        `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, exp_addr))
                end
              end else begin
                foreach(ioaiu_scb.csr_addr_decode_err_addr_q[i]) begin
                  exp_errinfo[3:0] = 4'b0000; // no address hit 
                  exp_errinfo[5:4] = ioaiu_scb.csr_addr_decode_err_cmd_type_q[i]; 
                  exp_errinfo[7:6] = 0; //reserved 
                  exp_errinfo[19:8] = ioaiu_scb.csr_addr_decode_err_msg_id_q[i];
                  exp_errinfo_q.push_back(exp_errinfo);
                  exp_addr = ioaiu_scb.csr_addr_decode_err_addr_q[i];
                  exp_addr_q.push_back(exp_addr);
                end
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
                uvm_config_db#(int)::set(null,"*","ioaiu_decode_uesr_err_info",read_data); //for coverage

                if (!(read_data inside {exp_errinfo_q})) begin
                  `uvm_error(get_full_name(),$sformatf("received XAIUUESR_ErrInfo = 0x%0x it should be inside %0p",read_data,exp_errinfo_q))
                end
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
		 uvm_config_db#(int)::set(null,"*","ioaiu_decode_uesr_err_type",read_data); //for coverage
                compareValues("XAIUUESR_ErrType", "", read_data, 7);
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrAddr')%>, read_data);
                err_addr0 = read_data;
//              read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrEntry')%>, read_data);
//              err_entry = read_data;
//              read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWay')%>, read_data);
//              err_way = read_data;
//              read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWord')%>, read_data);
//              err_word = read_data;
                read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR1.ErrAddr')%>, read_data);
                err_addr = read_data;
                actual_addr = {err_addr,err_addr0};
                if (!(actual_addr inside {exp_addr_q})) begin
                        `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x it should be inside = %0p",actual_addr, exp_addr_q))
                end
              end
              fork
                  begin
                      //#Check.IOAIU.NoAddresshit.IRQ_UC
                      wait (u_csr_probe_vif.IRQ_UC === 1);
                  end
                  begin
                    #200000ns;
                    `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
                  end
                join_any
              disable fork;
            end

            write_data = 0;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.DecErrDetEn')%>, write_data); 
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.DecErrIntEn')%>, write_data);

            write_data = 1;
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
            // Read the XAIUUESR_ErrVld should be cleared
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
            compareValues("XAIUUESR_ErrVld", "now clear", read_data, 0);

    endtask

endclass : ioaiu_csr_no_address_hit_seq_<%=obj.multiPortCoreId%>

class io_aiu_csr_uuedr_ProtErrDetEn_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(io_aiu_csr_uuedr_ProtErrDetEn_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, write_data;
    bit [3:0]  errtype;
    bit [19:0]  errinfo;
    bit [WSMIADDR-1:0]  exp_addr;
    bit [WSMIADDR-1:0] actual_addr;
    ioaiu_scb_txn scb_txn;
    bit [19:0] err_entry;
    bit [5:0] err_way;
    bit [5:0] err_word;
    bit [19:0] err_addr;
    bit [31:0] err_addr0;
    bit need_cache_alignment;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
<%if(obj.DutInfo.fnNativeInterface == "ACE-LITE" || obj.DutInfo.fnNativeInterface == "ACELITE-E" || obj.DutInfo.fnNativeInterface == "ACE" || obj.DutInfo.fnNativeInterface == "ACE5") { %>
      getCsrProbeIf();
      get_env_handle();

      //#Check.IOAIU.SNPrspError.ErrType
      errtype = 4'h4;

      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.ProtErrDetEn')%>, write_data); 
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.ProtErrIntEn')%>, write_data);
      ev_<%=obj.multiPortCoreId%>.trigger();
      if ($test$plusargs("dvm_snp_rsp_error_test")) begin
        ev_snoop_rsp_err_dvm.wait_ptrigger();
        if (env.m_scb.snoop_rsp_err_info.size() != 0) begin
          if (env.m_scb.snoop_rsp_err_info[0].t_ace_snoop_resp_recd < env.m_scb.snoop_rsp_err_info[0].smi_act_time["ACESnpRspDvm1"]) begin
            scb_txn = env.m_scb.snoop_rsp_err_info[0];
            errinfo = {scb_txn.m_ace_snoop_addr_pkt.acprot[1], scb_txn.m_ace_snoop_resp_pkt.crresp[1:0]};
            errinfo[19:3] = 0;
            //exp_addr = scb_txn.m_ace_snoop_addr_pkt.acaddr;
            exp_addr = ((scb_txn.m_snp_req_pkt.smi_addr >> $clog2(SYS_nSysCacheline)) << $clog2(SYS_nSysCacheline)); //Changed to SMI snoop req addr as per the RTL owner comment in CONC-7251
            need_cache_alignment = 1;
          end else begin
            scb_txn = env.m_scb.snoop_rsp_err_info[0];
            errinfo = {scb_txn.m_ace_snoop_addr_pkt0_act.acprot[1], scb_txn.m_ace_snoop_resp_pkt0_act.crresp[1:0]};
            errinfo[19:3] = 0;
            exp_addr = scb_txn.m_ace_snoop_addr_pkt0_act.acaddr;
          end
        end else begin
          scb_txn = env.m_scb.snoop_rsp_err_info[0];
          errinfo = {scb_txn.m_ace_snoop_addr_pkt0_act.acprot[1], scb_txn.m_ace_snoop_resp_pkt0_act.crresp[1:0]};
          errinfo[19:3] = 0;
          exp_addr = scb_txn.m_ace_snoop_addr_pkt0_act.acaddr;
        end
      end else begin
        ev_snoop_rsp_err.wait_ptrigger();
        scb_txn = env.m_scb.snoop_rsp_err_info[0];
        //#Check.IOAIU.SNPrspError.ErrType
        errinfo = {scb_txn.m_ace_snoop_addr_pkt.acprot[1], scb_txn.m_ace_snoop_resp_pkt.crresp[1:0]};
        errinfo[19:3] = 0;
        //exp_addr = scb_txn.m_ace_snoop_addr_pkt.acaddr;
        exp_addr = ((scb_txn.m_snp_req_pkt.smi_addr >> $clog2(SYS_nSysCacheline)) << $clog2(SYS_nSysCacheline)); //Changed to SMI snoop req addr as per the RTL owner comment in CONC-7251
        need_cache_alignment = 1;
      end
      `uvm_info(get_type_name(),$sformatf("errinfo = %0h, exp_addr = %0h", errinfo, exp_addr),UVM_DEBUG)
      poll_UUESR_ErrVld(1, poll_data);
     // CHECK for IRQ_UC interrupt 
      fork      
      begin: _wait_irq
          wait (u_csr_probe_vif.IRQ_UC === 1);
      end: _wait_irq
      begin: _timeout
        #10000ns;
        `uvm_error(get_type_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
      end:_timeout
            join_any
      disable fork;
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
      compareValues("UUESR_ErrType","Valid Type", read_data, errtype);
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
      //#Check.IOAIU.SNPrspError.Errinfo
      compareValues("UUESR_ErrInfo","Valid Type", read_data, errinfo);
          uvm_config_db#(int)::set(null,"*","ioaiu_snoop_user_err_info",read_data[2]); //for coverage
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrAddr')%>, read_data);
      err_addr0 = read_data;
//    read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrEntry')%>, read_data);
//    err_entry = read_data;
//    read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWay')%>, read_data);
//    err_way = read_data;
//    read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWord')%>, read_data);
//    err_word = read_data;
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR1.ErrAddr')%>, read_data);
      err_addr = read_data;
      if (need_cache_alignment) begin
        actual_addr = (({err_addr,err_addr0} >> $clog2(SYS_nSysCacheline)) << $clog2(SYS_nSysCacheline));
      end else begin
        actual_addr = {err_addr,err_addr0};
      end
      //#Check.IOAIU.SNPrspError.ErrAddr
      if (actual_addr !== exp_addr) begin
                `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, exp_addr))
      end
      write_data = 0;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.ProtErrDetEn')%>, write_data); 
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.ProtErrIntEn')%>, write_data);
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data); 
      compareValues("UUESR_ErrVld","should be", read_data, 0);
    <% } else { %>  
      ev_<%=obj.multiPortCoreId%>.trigger();
    <% } %>
    endtask
endclass : io_aiu_csr_uuedr_ProtErrDetEn_seq_<%=obj.multiPortCoreId%>


class io_aiu_csr_caiuuedr_TransErrDetEn_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(io_aiu_csr_caiuuedr_TransErrDetEn_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    int        errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;
    bit [19:0]  errinfo;
    bit [51:0]  exp_addr;
    bit errinfo_check, erraddr_check;
    bit [51:0] actual_addr;
    bit [19:0] err_entry;
    bit [5:0] err_way;
    bit [5:0] err_word;
    bit [19:0] err_addr;
    bit [DTR_REQ_RMSGID_MSB - DTR_REQ_RMSGID_LSB:0] smi_rmsg_id;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      bit dis_uedr_ted_4resiliency;
      std::randomize(dis_uedr_ted_4resiliency)with{dis_uedr_ted_4resiliency dist {1:=20,0:=80};};
      getCsrProbeIf();
      getSMIIf();
      get_env_handle();
      if(dis_uedr_ted_4resiliency) begin
        `uvm_info(get_full_name(),$sformatf("Skipping-0 enabling of error detection inside xUEDR"),UVM_NONE)
      end
      else begin
      errtype = 4'h8;
      // Set the UUECR_ErrDetEn = 1
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.TransErrDetEn')%>, write_data); 
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.TransErrIntEn')%>, write_data);
      end
      ev_<%=obj.multiPortCoreId%>.trigger();

      if ($test$plusargs("snp_req_err_inj")) begin
        do
          @(posedge m_smi<%=smi_portid_snpreq%>_tx_vif.clk);
       <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
        while (m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.snp_req_ready_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.snp_req_valid_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_type) != eConcMsgSnpReq)));
        <%} else {%>
        while (m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_type) != eConcMsgSnpReq)));
         <% } %>
        errinfo[19:8] = m_smi<%=smi_portid_snpreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[7:1] = Reserved;
        errinfo[0] = 1'b1; // 1 for SMI Protection Error
        exp_addr = m_smi<%=smi_portid_snpreq%>_tx_vif.smi_ndp[SNP_REQ_ADDR_MSB:SNP_REQ_ADDR_LSB];
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgSnpReq); //for coverage
      end
      if ($test$plusargs("str_req_err_inj")) begin
        do
          @(posedge m_smi<%=smi_portid_strreq%>_tx_vif.clk);
        <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
        while (m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.str_req_ready_<%=obj.multiPortCoreId%> === 1'b0 || u_csr_probe_vif.str_req_valid_<%=obj.multiPortCoreId%> === 1'b0|| ((smi_seq_item::type2class(m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_type) != eConcMsgStrReq)));
        <%} else {%>
         while (m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_type) != eConcMsgStrReq)));
        <% } %>
        errinfo[19:8] = m_smi<%=smi_portid_strreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[7:1] = Reserved;
        errinfo[0] = 1'b1; // 1 for SMI Protection Error
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgStrReq); //for coverage
      end
      if ($test$plusargs("dtr_req_err_inj")) begin
         do begin
          @(posedge m_smi<%=smi_portid_dtrreq%>_tx_vif.clk);
         <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
         smi_rmsg_id = m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_ndp[DTR_REQ_RMSGID_MSB:DTR_REQ_RMSGID_LSB];
      end  while ((int'(smi_rmsg_id[ WSMIMSGID-1 : WSMIMSGID-$clog2(<%=obj.DutInfo.nNativeInterfacePorts%>)]) != <%=obj.multiPortCoreId%>) || m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_ready === 1'b0 ||  ((smi_seq_item::type2class(m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_type) != eConcMsgDtrReq)));
         <%} else {%>
        end while (m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_type) != eConcMsgDtrReq)));
          <% } %>
        errinfo[19:8] = m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[7:1] = Reserved;
        errinfo[0] = 1'b1; // 1 for SMI Protection error
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type",eConcMsgDtrReq); //for coverage
      end	
     if ($test$plusargs("dtw_rsp_err_inj")) begin
        do
          @(posedge m_smi<%=smi_portid_dtwrsp%>_tx_vif.clk);
        <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
        while (m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.dtw_rsp_valid_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.dtw_rsp_ready_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_type) != eConcMsgDtwRsp)));
        <%} else {%>
        while (m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_type) != eConcMsgDtwRsp)));
        <% } %>

        errinfo[19:8] = m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[7:1] = Reserved;
        errinfo[0] = 1'b1; // 1 for SMI Protection error
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgDtwRsp); //for coverage
      end
      if ($test$plusargs("dtr_rsp_err_inj")) begin
        do
          @(posedge m_smi<%=smi_portid_dtrrsp%>_tx_vif.clk);
        <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
        while (m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.dtr_rsp_ready_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.dtr_rsp_valid_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_type) != eConcMsgDtrRsp)));
         <%} else {%>
        while (m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_ready === 1'b0  || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_type) != eConcMsgDtrRsp)));
           <% } %>
        errinfo[0] = 1'b1; // 1 for SMI Protection Error
        errinfo[7:1] = 0;  //Reserved
        errinfo[19:8] = m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgDtrRsp); //for coverage
      end
      if ($test$plusargs("cmp_rsp_err_inj")) begin
        do begin
          @(posedge m_smi<%=smi_portid_cmprsp%>_tx_vif.clk);
        <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
        end while (m_smi<%=smi_portid_cmprsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_cmprsp%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.cmp_rsp_ready_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.cmp_rsp_valid_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_cmprsp%>_tx_vif.smi_msg_type) != eConcMsgCmpRsp)));
         <%} else {%>
        end while (m_smi<%=smi_portid_cmprsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_cmprsp%>_tx_vif.smi_msg_ready === 1'b0  || ((smi_seq_item::type2class(m_smi<%=smi_portid_cmprsp%>_tx_vif.smi_msg_type) != eConcMsgCmpRsp)));
           <% } %>
        errinfo[0] = 1'b1; // 1 for SMI Protection Error
        errinfo[7:1] = 0;  //Reserved
        errinfo[19:8] = m_smi<%=smi_portid_cmprsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgCmpRsp); //for coverage
      end
      if ($test$plusargs("upd_rsp_err_inj")) begin
        do begin
          @(posedge m_smi<%=smi_portid_updrsp%>_tx_vif.clk);
        <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
        end while (m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.upd_rsp_ready_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.upd_rsp_valid_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_type) != eConcMsgUpdRsp)));
         <%} else {%>
        end while (m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_ready === 1'b0  || ((smi_seq_item::type2class(m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_type) != eConcMsgUpdRsp)));
           <% } %>
        errinfo[0] = 1'b1; // 1 for SMI Protection Error
        errinfo[7:1] = 0;  //Reserved
        errinfo[19:8] = m_smi<%=smi_portid_updrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgUpdRsp); //for coverage
      end
       if ($test$plusargs("ccmd_rsp_err_inj")) begin
        do
          @(posedge m_smi<%=smi_portid_cmdrsp%>_tx_vif.clk);
 	<%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%>         
        while (m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_ready === 1'b0 ||  u_csr_probe_vif.cmd_rsp_valid_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.cmd_rsp_ready_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) != eConcMsgCCmdRsp)));
        <%} else {%>
         while (m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) != eConcMsgCCmdRsp)));
         <%}%>
        errinfo[0] = 1'b1; // 1 for SMI Protection Error
        errinfo[7:1] =  0;    //Reserved
        errinfo[19:8] = m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgCCmdRsp); //for coverage
      end
       if ($test$plusargs("nccmd_rsp_err_inj")) begin
        do
          @(posedge m_smi<%=smi_portid_cmdrsp%>_tx_vif.clk);
 	<%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%>         
        while (m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_ready === 1'b0 ||  u_csr_probe_vif.cmd_rsp_valid_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.cmd_rsp_ready_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) != eConcMsgNcCmdRsp)));
        <%} else {%>
         while (m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) != eConcMsgNcCmdRsp)));
         <%}%>
        errinfo[0] = 1'b1; // 1 for SMI Protection Error
        errinfo[7:1] =  0;    //Reserved
        errinfo[19:8] = m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgNcCmdRsp); //for coverage
      end
       if ($test$plusargs("wrong_cmdrsp_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_cmdrsp%>_tx_vif.clk);

 	<%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%>         
        while (m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_ready === 1'b0 ||  u_csr_probe_vif.cmd_rsp_valid_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.cmd_rsp_ready_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) != eConcMsgCCmdRsp && smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) != eConcMsgNcCmdRsp) || ((smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) == eConcMsgCCmdRsp || smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) == eConcMsgNcCmdRsp) && (m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));
        <%} else {%>
         while (m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) != eConcMsgCCmdRsp && smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) != eConcMsgNcCmdRsp) || ((smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) == eConcMsgCCmdRsp || smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) == eConcMsgNcCmdRsp) && (m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));
         <%}%>
        errinfo[0] = 1'b0; // 0 for wrong targ_id
        errinfo[7:1] =  0;    //Reserved
        errinfo[19:8] = m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_updrsp_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_updrsp%>_tx_vif.clk);
        <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%>  
        while (m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.upd_rsp_valid_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.upd_rsp_ready_<%=obj.multiPortCoreId%> === 0 || (smi_seq_item::type2class(m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_type) != eConcMsgUpdRsp || ((smi_seq_item::type2class(m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_type) == eConcMsgUpdRsp) && (m_smi<%=smi_portid_updrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));
         <%} else {%>
         while (m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_ready === 1'b0 || (smi_seq_item::type2class(m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_type) != eConcMsgUpdRsp || ((smi_seq_item::type2class(m_smi<%=smi_portid_updrsp%>_tx_vif.smi_msg_type) == eConcMsgUpdRsp) && (m_smi<%=smi_portid_updrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));
          <% } %>

        errinfo[0]    = 1'b0; // 0 for wrong targ_id
        errinfo[7:1]  = 0;   //Reserved
        errinfo[19:8] = m_smi<%=smi_portid_updrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_dtwrsp_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_dtwrsp%>_tx_vif.clk);
        <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
        while (m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.dtw_rsp_valid_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.dtw_rsp_ready_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_type) != eConcMsgDtwRsp) || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_type) == eConcMsgDtwRsp) && (m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));
        <%} else {%>
        while (m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_type) != eConcMsgDtwRsp) || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_type) == eConcMsgDtwRsp) && (m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));
        <% } %>

        errinfo[0] = 1'b0; // 0 for wrong targ_id
        errinfo[7:1] = 0; //Reserved
        errinfo[19:8] = m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_dtrrsp_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_dtrrsp%>_tx_vif.clk);
        <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
        while (m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.dtr_rsp_ready_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.dtr_rsp_valid_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_type) != eConcMsgDtrRsp) || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_type) == eConcMsgDtrRsp) && (m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));
         <%} else {%>
        while (m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_ready === 1'b0  || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_type) != eConcMsgDtrRsp) || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_type) == eConcMsgDtrRsp) && (m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));
           <% } %>

        errinfo[0] = 1'b0; // 0 for wrong targ_id
        errinfo[7:1] = 0;  //Reserved
        errinfo[19:8] = m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_dtrreq_target_id")) begin
         do begin
          @(posedge m_smi<%=smi_portid_dtrreq%>_tx_vif.clk);
         <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
         smi_rmsg_id = m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_ndp[DTR_REQ_RMSGID_MSB:DTR_REQ_RMSGID_LSB];
      end  while ((int'(smi_rmsg_id[ WSMIMSGID-1 : WSMIMSGID-$clog2(<%=obj.DutInfo.nNativeInterfacePorts%>)]) != <%=obj.multiPortCoreId%>) || m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_ready === 1'b0 ||  ((smi_seq_item::type2class(m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_type) != eConcMsgDtrReq) || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_type) == eConcMsgDtrReq) && (m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));
 
         <%} else {%>
        end while (m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_type) != eConcMsgDtrReq) || ((smi_seq_item::type2class(m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_type) == eConcMsgDtrReq) && (m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));

          <% } %>

   
        errinfo[0] = 1'b0; // 0 for wrong targ_id
        errinfo[7:1] = 0;  //eserved
        errinfo[19:8] = m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_strreq_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_strreq%>_tx_vif.clk);
        <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
        while (m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.str_req_ready_<%=obj.multiPortCoreId%> === 1'b0 || u_csr_probe_vif.str_req_valid_<%=obj.multiPortCoreId%> === 1'b0|| ((smi_seq_item::type2class(m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_type) != eConcMsgStrReq) || ((smi_seq_item::type2class(m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_type) == eConcMsgStrReq) && (m_smi<%=smi_portid_strreq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));
        <%} else {%>
         while (m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_type) != eConcMsgStrReq) || ((smi_seq_item::type2class(m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_type) == eConcMsgStrReq) && (m_smi<%=smi_portid_strreq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));
        <% } %>


        errinfo[0] = 1'b0; // 0 for wrong targ_id
        errinfo[7:1] = 0;  //Reserved
        errinfo[19:8] = m_smi<%=smi_portid_strreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_snpreq_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_snpreq%>_tx_vif.clk);
       <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
        while (m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.snp_req_ready_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.snp_req_valid_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_type) != eConcMsgSnpReq) || ((smi_seq_item::type2class(m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_type) == eConcMsgSnpReq) && (m_smi<%=smi_portid_snpreq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));
        <%} else {%>
        while (m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_type) != eConcMsgSnpReq) || ((smi_seq_item::type2class(m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_type) == eConcMsgSnpReq) && (m_smi<%=smi_portid_snpreq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[ioaiu_id].FUnitId%>))));
         <% } %>
        errinfo[0] = 1'b0; // 0 for wrong targ_id
        errinfo[7:1] = 0;  //Reserved
        errinfo[19:8] = m_smi<%=smi_portid_snpreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        exp_addr = m_smi<%=smi_portid_snpreq%>_tx_vif.smi_ndp[SNP_REQ_ADDR_MSB:SNP_REQ_ADDR_LSB];
        errinfo_check = 1;
        erraddr_check = 1;
      end
      `uvm_info(get_full_name(),$sformatf("errinfo = %0h, exp_addr = %0h", errinfo, exp_addr),UVM_DEBUG)
      <% if(obj.useResiliency) { %>
      fork
	           begin
                       wait(u_csr_probe_vif.fault_mission_fault==1);
                       `uvm_info("RUN_MAIN","fault_mission_fault is asserted", UVM_NONE) 
	           end
		   begin
		       #200000ns;
                       `uvm_error("RUN_MAIN","fault_mission_fault isn't asserted")
	           end
       join_any
      disable fork;
      uvm_config_db#(int)::set(null,"*","ioaiu_fault_mission_fault",u_csr_probe_vif.fault_mission_fault);
      <%}%>
      if(dis_uedr_ted_4resiliency) begin
        `uvm_info(get_full_name(),$sformatf("Skipping-1 enabling of error detection inside xUEDR"),UVM_NONE)
      end
      else begin
      //keep on  Reading the XAIUUESR_ErrVld bit = 1
      //#Check.IOAIU.WrongTargetId.ErrVld
      //#Check.IOAIU.Transport.ErrVld
      poll_UUESR_ErrVld(1, poll_data);
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data); 
      uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_vld",read_data);
      // wait for IRQ_UC interrupt 
      fork
      begin
          //#Check.IOAIU.WrongTargetId.IRQ_UC
          //#Check.IOAIU.Transport.IRQ_UC
          wait (u_csr_probe_vif.IRQ_UC === 1);
      end
      begin
        #200000ns;
        `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
      end
      join_any
      disable fork;
        //#Check.IOAIU.Transport.ErrType
    	read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
    	compareValues("UUESR_ErrType","Valid Type", read_data, errtype);
    	uvm_config_db#(int)::set(null,"*","ioaiu_wrong_target_id_uesr_err_type",read_data); //for coverage
    	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_type",read_data); //for coverage
    	//#Check.IOAIU.WrongTargetId.ErrType
    	//#Check.IOAIU.Transport.ErrInfo
        //CONC-16604 review ErrInfo check disable for multi-core configs  
         if (errinfo_check) begin
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
            uvm_config_db#(int)::set(null,"*","ioaiu_wrong_target_id_uesr_err_info",read_data); //for coverage
            uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_info",read_data); //for coverage
            //#Check.IOAIU.WrongTargetId.ErrInfo
            if(!$test$plusargs("smi_hdr_err_inj")) begin
                compareValues("UCESR_ErrInfo","Valid Type", read_data, errinfo);
            end else begin 
                compareValues("UCESR_ErrInfo","Valid Type", read_data[7:0], errinfo[7:0]);
            end
    	end
    	write_data = 0;
    	write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.TransErrDetEn')%>, write_data); 
    	write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.TransErrIntEn')%>, write_data);
    	write_data = 1;
    	write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
    	read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data); 
    	compareValues("UUESR_ErrVld","should be", read_data, 0); 
    //	read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
    	//#Check.IOAIU.SMIProtectionType.ErrType
    //	compareValues("UUESR_ErrType","Valid Type", read_data, 0);
    //	read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
    	//#Check.IOAIU.SMIProtectionType.ErrInfo
    //	compareValues("UUESR_ErrInfo","Valid Type", read_data, 0);

	cov.collect_uncorrectable_error(<%=obj.multiPortCoreId%>);
      end
    endtask
endclass : io_aiu_csr_caiuuedr_TransErrDetEn_seq_<%=obj.multiPortCoreId%>

class io_aiu_csr_caiuuedr_TransCorrErrDetEn_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(io_aiu_csr_caiuuedr_TransCorrErrDetEn_seq_<%=obj.multiPortCoreId%>)
   uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    int        errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;
    bit [19:0] errinfo;
    bit [51:0] exp_addr;
    bit errinfo_check, erraddr_check;
    bit [51:0] actual_addr;
    bit [19:0] err_entry;
    bit [5:0]  err_way;
    bit [5:0]  err_word;
    bit [19:0] err_addr;
    bit [DTR_REQ_RMSGID_MSB - DTR_REQ_RMSGID_LSB:0] smi_rmsg_id;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      bit dis_uedr_ted_4resiliency;
      std::randomize(dis_uedr_ted_4resiliency)with{dis_uedr_ted_4resiliency dist {1:=0,0:=100};};
      getCsrProbeIf();
      getInjectErrEvent();
      getSMIIf();
      get_env_handle();
      <% if(obj.useResiliency) { %>
      write_data = 0;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCRTR.ResThreshold')%>, write_data);
      <%}%>
      if(dis_uedr_ted_4resiliency) begin
        `uvm_info(get_full_name(),$sformatf("Skipping-0 enabling of error detection inside xUEDR"),UVM_NONE)
      end
      else begin
      errtype = 4'h8;
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
      ev_<%=obj.multiPortCoreId%>.trigger();

       if ($test$plusargs("ccmd_rsp_err_inj")) begin
        do
          @(posedge m_smi<%=smi_portid_cmdrsp%>_tx_vif.clk);
          
        while (u_csr_probe_vif.cmd_rsp_valid_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.cmd_rsp_ready_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(u_csr_probe_vif.cmux_cmd_rsp_cm_typ) != eConcMsgCCmdRsp)));
               errinfo[19:16] = 4'b0; 
        errinfo[15:6] = u_csr_probe_vif.cmux_cmd_rsp_initiator_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgCCmdRsp); //for coverage
      end
       if ($test$plusargs("nccmd_rsp_err_inj")) begin
        do
          @(posedge m_smi<%=smi_portid_cmdrsp%>_tx_vif.clk);
        while (u_csr_probe_vif.cmd_rsp_valid_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.cmd_rsp_ready_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(u_csr_probe_vif.cmux_cmd_rsp_cm_typ) != eConcMsgNcCmdRsp)));
        errinfo[19:16] = 4'b0; 
        errinfo[15:6] = u_csr_probe_vif.cmux_cmd_rsp_initiator_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgNcCmdRsp); //for coverage
      end
      if ($test$plusargs("snp_req_err_inj")) begin
        do
          @(posedge m_smi<%=smi_portid_snpreq%>_tx_vif.clk);
        while ( u_csr_probe_vif.snp_req_ready_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.snp_req_valid_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(u_csr_probe_vif.cmux_snp_req_cm_typ) != eConcMsgSnpReq)));
        errinfo[19:16] = 4'b0; 
        errinfo[15:6] = u_csr_probe_vif.cmux_snp_req_initiator_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgSnpReq); //for coverage
      end
      if ($test$plusargs("str_req_err_inj")) begin
        do
          @(posedge m_smi<%=smi_portid_strreq%>_tx_vif.clk);
        while ( u_csr_probe_vif.str_req_ready_<%=obj.multiPortCoreId%> === 1'b0 || u_csr_probe_vif.str_req_valid_<%=obj.multiPortCoreId%> === 1'b0|| ((smi_seq_item::type2class(u_csr_probe_vif.cmux_str_req_cm_typ) != eConcMsgStrReq)));
        errinfo[19:16] = 4'b0; 
        errinfo[15:6] = u_csr_probe_vif.cmux_str_req_initiator_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgStrReq); //for coverage
      end 
      if ($test$plusargs("dtr_req_err_inj")) begin
         do begin
          @(posedge m_smi<%=smi_portid_dtrreq%>_tx_vif.clk);
         <%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
         smi_rmsg_id = m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_ndp[DTR_REQ_RMSGID_MSB:DTR_REQ_RMSGID_LSB];
      end  while ((int'(smi_rmsg_id[ WSMIMSGID-1 : WSMIMSGID-$clog2(<%=obj.DutInfo.nNativeInterfacePorts%>)]) != <%=obj.multiPortCoreId%>) || m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_ready === 1'b0 ||  ((smi_seq_item::type2class(u_csr_probe_vif.cmux_dtr_req_rx_cm_typ) != eConcMsgDtrReq)));
         <%} else {%>
        end while (m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(u_csr_probe_vif.cmux_dtr_req_rx_cm_typ) != eConcMsgDtrReq)));
          <% } %>
        errinfo[19:16] = 4'b0; 
        errinfo[15:6] = u_csr_probe_vif.cmux_dtr_req_rx_initiator_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type",eConcMsgDtrReq); //for coverage
      end
      if ($test$plusargs("dtr_rsp_err_inj")) begin
        do
          @(posedge m_smi<%=smi_portid_dtrrsp%>_tx_vif.clk);
        while ( u_csr_probe_vif.dtr_rsp_ready_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.dtr_rsp_valid_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(u_csr_probe_vif.cmux_dtr_rsp_rx_cm_typ) != eConcMsgDtrRsp)));
        errinfo[19:16] = 4'b0; 
        errinfo[15:6] = u_csr_probe_vif.cmux_dtr_rsp_rx_initiator_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgDtrRsp); //for coverage
      end
      if ($test$plusargs("cmp_rsp_err_inj")) begin
        do begin
          @(posedge m_smi<%=smi_portid_cmprsp%>_tx_vif.clk);
        end while (u_csr_probe_vif.cmp_rsp_ready_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.cmp_rsp_valid_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(u_csr_probe_vif.cmux_cmp_rsp_cm_typ) != eConcMsgCmpRsp)));
        errinfo[19:16] = 4'b0; 
        errinfo[15:6] = u_csr_probe_vif.cmux_cmp_rsp_initiator_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgCmpRsp); //for coverage
      end
      if ($test$plusargs("upd_rsp_err_inj")) begin
        do begin
          @(posedge m_smi<%=smi_portid_updrsp%>_tx_vif.clk);
        end while ( u_csr_probe_vif.upd_rsp_ready_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.upd_rsp_valid_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(u_csr_probe_vif.cmux_upd_rsp_cm_typ) != eConcMsgUpdRsp)));
        errinfo[19:16] = 4'b0; 
        errinfo[15:6] = u_csr_probe_vif.cmux_upd_rsp_initiator_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgUpdRsp); //for coverage
      end
     if ($test$plusargs("dtw_rsp_err_inj")) begin
        do
          @(posedge m_smi<%=smi_portid_dtwrsp%>_tx_vif.clk);
        while ( u_csr_probe_vif.dtw_rsp_valid_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.dtw_rsp_ready_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(u_csr_probe_vif.cmux_dtw_rsp_cm_typ) != eConcMsgDtwRsp)));
        errinfo[19:16] = 4'b0; 
        errinfo[15:6] = u_csr_probe_vif.cmux_dtw_rsp_initiator_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type", eConcMsgDtwRsp); //for coverage
      end
 end
      `uvm_info(get_full_name(),$sformatf("errinfo = %0h, exp_addr = %0h", errinfo, exp_addr),UVM_DEBUG)
      <% if(obj.useResiliency) { %>
      fork
	           begin
                       wait(u_csr_probe_vif.cerr_over_thres_fault==1);
                       `uvm_info("RUN_MAIN","fault_thres_fault is asserted", UVM_NONE) 
	           end
		   begin
		       #200000ns;
                       `uvm_error("RUN_MAIN","fault_thres_fault isn't asserted")
	           end
       join_any
      disable fork;
      uvm_config_db#(int)::set(null,"*","ioaiu_fault_thres_fault",u_csr_probe_vif.cerr_over_thres_fault);
      <%}%>
            
      if(dis_uedr_ted_4resiliency) begin
        `uvm_info(get_full_name(),$sformatf("Skipping-1 enabling of error detection inside xUEDR"),UVM_NONE)
      end
      else begin
      //#Check.IOAIU.CorrectableTransport.ErrVld
      poll_UCESR_ErrVld(1, poll_data);
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data); 
        uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_vld",read_data);
      // wait for IRQ_C interrupt 
      fork
      begin
          //#Check.IOAIU.SMIProtectionType.IRQ_C
          wait (u_csr_probe_vif.IRQ_C === 1);
      end
      begin
        #2000ns;
        `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C asserted"));
      end
      join_any
      disable fork;
      //#Check.IOAIU.CorrectableTransport.ErrType
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrType')%>, read_data);
      uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_cesr_err_type",read_data); //for coverag
      compareValues("UCESR_ErrType","Valid Type", read_data, errtype);
      //#Check.IOAIU.CorrectableTransport.ErrInfo
    //CONC-16604 review ErrInfo check disable for multi-core configs  
      if (errinfo_check) begin
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrInfo')%>, read_data);
	uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_cesr_err_info",read_data); //for coverage
        compareValues("UCESR_ErrInfo","Valid Type", read_data, errinfo);
      end
      cov.collect_uncorrectable_error(<%=obj.multiPortCoreId%>);
      if (erraddr_check) begin
        //Disabled address check as per CONC-6294
        
      end
      write_data = 0;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, write_data);
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCount')%>, read_data);
      compareValues("UCESR_ErrVld","should be", read_data, 0);
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
      compareValues("UCESR_ErrVld","should be", read_data, 0);

      end
    endtask
endclass : io_aiu_csr_caiuuedr_TransCorrErrDetEn_seq_<%=obj.multiPortCoreId%>
      	
//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class ioaiu_csr_PlruErrInject_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_PlruErrInject_seq_<%=obj.multiPortCoreId%>)
    
  function new(string name="");
    super.new(name);
  endfunction

  task body();
    getInjectErrEvent();
    getCsrProbeIf();
    ev_<%=obj.multiPortCoreId%>.trigger();
    inject_error(1000,1,1'b0,.ott_no(ott_way)); 
  endtask
endclass : ioaiu_csr_PlruErrInject_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_uuedr_MemErrDetEn_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_uuedr_MemErrDetEn_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [4:0]  errtype;
    bit [19:0] errinfo;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      bit dis_uedr_med_4resiliency = $test$plusargs("dis_uedr_med_4resiliency") ? 1 : 0;
      <% if(obj.useResiliency) { %>
      bit double_bitErr = ($test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test")
                          || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test")
                          || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test")
                          || $test$plusargs("ccp_double_bit_direct_tag_error_test")
                          || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test")
                          || $test$plusargs("ccp_double_bit_data_direct_error_test")
                          || $test$plusargs("ccp_multi_blk_double_data_direct_error_test")
                          || $test$plusargs("ccp_double_bit_direct_ott_error_test")
                          || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test")
                        ) ? 1 : 0;
      bit single_bitErr = ($test$plusargs("ccp_single_bit_tag_direct_error_test")
                          || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test")
                          || $test$plusargs("ccp_single_bit_data_direct_error_test")
                          || $test$plusargs("ccp_multi_blk_single_data_direct_error_test")
                          || $test$plusargs("ccp_single_bit_ott_direct_error_test")
                          || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")
                        ) ? 1 : 0;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCRTR.ResThreshold')%>, 0);
      <% } %>

getCsrProbeIf();
getSMIIf();
getInjectErrEvent();
<% if(has_secded_ott || has_secded) { %>
        if((tag_secded && ( $test$plusargs("address_error_test_tag") ||  $test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test"))) || (data_secded && ($test$plusargs("address_error_test_data") ||$test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))) || (ott_secded && ($test$plusargs("address_error_test_ott") || $test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test")))) begin
   

           if ($test$plusargs("address_error_test_tag") || $test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test") ) begin
             errinfo = 20'h0;
             errtype = 5'h1;
             end
           else if ($test$plusargs("address_error_test_data") || $test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test")) begin
	     errtype = 5'h1;
             errinfo = 20'h1;
            end
            else if($test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("address_error_test_ott") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test")) begin
             errtype = 5'h0;
            errinfo =  20'h0;
           end
           if(!dis_uedr_med_4resiliency) begin
           // Set the UUECR_ErrDetEn = 1
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
           ev_<%=obj.multiPortCoreId%>.trigger();
           if ($test$plusargs("wait_for_snp_req")) begin
             do begin
               @(posedge m_smi<%=smi_portid_snpreq%>_tx_vif.clk);
             end while (m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_ready === 1'b0 || (smi_seq_item::type2class(m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_type) != eConcMsgSnpReq));
           end
           //#Stimulus.IOAIU.DTWreq.CMStatusError_DBad
           inject_error(.ott_no(ott_way));
           //keep on  Reading the UUESR_ErrVld bit = 1
           //#Check.IOAIU.UnCorrectable.ErrVld
           poll_UUESR_ErrVld(1, poll_data);
             
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
	   uvm_config_db#(int)::set(null,"*","ioaiu_data_user_err_type",read_data); //for coverage
           //#Check.IOAIU.UnCorrectableErr.ErrType
           compareValues("UUESR_ErrType","Valid Type", read_data, errtype);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
           //#Check.IOAIU.UnCorrectableErr.ErrInfo
	   uvm_config_db#(int)::set(null,"*","ioaiu_data_user_err_info",read_data); //for coverage
           compareValues("UUESR_ErrInfo","Valid Type", read_data, errinfo);
           write_data = 0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
           // write  UUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
           // Read the UUESR_ErrVld should be cleared
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "now clear", read_data, 0);
           end
           else begin
             write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, 0);
             ev_<%=obj.multiPortCoreId%>.trigger();
             if ($test$plusargs("wait_for_snp_req")) begin
               do begin
                 @(posedge m_smi<%=smi_portid_snpreq%>_tx_vif.clk);
               end while (m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_ready === 1'b0 || (smi_seq_item::type2class(m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_type) != eConcMsgSnpReq));
             end
             inject_error(.ott_no(ott_way));
             #200us;
             `uvm_info("RUN_MAIN",$sformatf("Timeout!"), UVM_NONE);
           end
           <% if(obj.useResiliency) { %>
           begin
             if(double_bitErr) begin
               if(u_csr_probe_vif.cerr_over_thres_fault)
                 `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr))
               else
                 `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr), UVM_NONE)
               if(!u_csr_probe_vif.fault_mission_fault)
                 `uvm_error("RUN_MAIN",$sformatf("fault_mission_fault isn't asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr))
               else
                 `uvm_info("RUN_MAIN",$sformatf("fault_mission_fault is asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr), UVM_NONE)
               if(u_csr_probe_vif.fault_latent_fault)
                 `uvm_error("RUN_MAIN",$sformatf("fault_latent_fault is asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr))
               else
                 `uvm_info("RUN_MAIN",$sformatf("fault_latent_fault isn't asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr), UVM_NONE)
             end
           end
           <% } %>
           end else if ((tag_parity && ($test$plusargs("address_error_test_tag") ||$test$plusargs("ccp_single_bit_tag_direct_error_test") ||  $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_parity && ($test$plusargs("address_error_test_data") || $test$plusargs("ccp_single_bit_data_direct_error_test")  || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_parity && ($test$plusargs("address_error_test_ott") || $test$plusargs("ccp_single_bit_ott_direct_error_test")  || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin
           if( $test$plusargs("address_error_test_tag") || $test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test")) begin
           errinfo = 20'h0;
           errtype = 5'h1;
           end
           else if(($test$plusargs("address_error_test_data") || $test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))) begin
            errtype = 5'h1;
            errinfo = 20'h1;
           end
           else if($test$plusargs("address_error_test_ott") || $test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test")) begin
            errtype = 5'h0;
            errinfo = 20'h0;
           end
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.MemErrIntEn')%>, write_data);
           ev_<%=obj.multiPortCoreId%>.trigger();
           inject_error(.ott_no(ott_way)); 
           // wait for IRQ_UC interrupt 
           //#Check.IOAIU.UnCorrectableErr.IRQ_UC
           fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 1);
           end
           begin
             #200000ns;
             `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
           end
           join_any
           disable fork;
           // Read the UUESR_ErrVld
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "set", read_data, 1);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
	   uvm_config_db#(int)::set(null,"*","ioaiu_data_user_err_type",read_data); //for coverage
           compareValues("UUESR_ErrType","Valid Type", read_data, errtype);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
	   uvm_config_db#(int)::set(null,"*","ioaiu_data_user_err_info",read_data); //for coverage
           compareValues("UUESR_ErrInfo","Valid Type", read_data, errinfo);
           write_data = 0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.MemErrIntEn')%>, write_data);
           // write  UUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
           // Read the UUESR_ErrVld should be cleared
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "now clear", read_data, 0);
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
        end else begin
           ev_<%=obj.multiPortCoreId%>.trigger();
           // Read the UUESR_ErrVld should be clear
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read UUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register UUESR_*
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrVld')%>, read_data);
           compareValues("UESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the UUESR_ErrVld should be still be 0
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "still clear", read_data, 0);
           // write  UUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
           // Read the UUESR_ErrVld should be cleared
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "clear", read_data, 0);
           // Read UUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register UUESR_*
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrVld')%>, read_data);
           compareValues("UUESAR_ErrVld", "clear", read_data, 0);
       end
<% } else { %>
           ev_<%=obj.multiPortCoreId%>.trigger();
           // Read the UUESR_ErrVld should be clear
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read UUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register UUESR_*
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrVld')%>, read_data);
           compareValues("UESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the UUESR_ErrVld should be still be 0
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "still clear", read_data, 0);
           // write  UUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
           // Read the UUESR_ErrVld should be cleared
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "clear", read_data, 0);
           // Read UUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register UUESR_*
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrVld')%>, read_data);
           compareValues("UUESAR_ErrVld", "clear", read_data, 0);
<% } %>
    endtask
endclass : ioaiu_csr_uuedr_MemErrDetEn_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_uueir_MemErrInt_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_uueir_MemErrInt_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [4:0] errtype;
    bit [19:0] errinfo;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded_ott || has_secded) { %>
         if((tag_secded && ($test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))) || (ott_secded && ($test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test")))) begin

           if ($test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test") || $test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test"))
             errinfo = 20'h0;
           else if ($test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))
             errinfo = 20'h1;

           if ($test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test") || $test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))
             errtype = 5'h1;
           else if($test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test"))
             errtype = 5'h0;

           // Set the UUEDR_MemErrDetEn = 1
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data);
           // Set the UUEIR_MemErrIntEn = 1
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.MemErrIntEn')%>, write_data);
           ev_<%=obj.multiPortCoreId%>.trigger();
           inject_error(.ott_no(ott_way)); 
           // wait for IRQ_UC interrupt 
           fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 1);
           end
           begin
             #200000ns;
             `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
           end
           join_any
           disable fork;
           // Read the UUESR_ErrVld
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "set", read_data, 1);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
	   uvm_config_db#(int)::set(null,"*","ioaiu_data_user_err_type",read_data); //for coverage
           compareValues("UUESR_ErrType","Valid Type", read_data, errtype);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
	   uvm_config_db#(int)::set(null,"*","ioaiu_data_user_err_info",read_data); //for coverage
           compareValues("UUESR_ErrType","Valid Type", read_data, errinfo);
           // Set the UUECR_ErrDetEn = 0, to disable the error detection
           write_data = 0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data);
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.MemErrIntEn')%>, write_data);
           // write UUESR_ErrVld = 1 to clear it
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
           // Read UUESR_ErrVld , it should be 0
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "reset", read_data, 0);
           <%if(!(obj.DutInfo.nNativeInterfacePorts > 1)) { %>
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
           <%}%>
         end else begin
           ev_<%=obj.multiPortCoreId%>.trigger();
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
           end
          // Read UUESR_ErrVld , it should be 0
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "reset", read_data, 0);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
           compareValues("UUESR_ErrType","Valid Type", read_data, 4'h0);
          // Read UUESAR_ErrVld , it should be 0
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrVld')%>, read_data);
           compareValues("UUESAR_ErrVld", "reset", read_data, 0);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrType')%>, read_data);
           compareValues("UUESAR_ErrType","Valid Type", read_data, 4'h0);
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
              `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
           end else begin
              `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
         end
<% } else { %>
           ev_<%=obj.multiPortCoreId%>.trigger();
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
           end
          // Read UUESR_ErrVld , it should be 0
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "reset", read_data, 0);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
           compareValues("UUESR_ErrType","Valid Type", read_data, 4'h0);
          // Read UUESAR_ErrVld , it should be 0
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrVld')%>, read_data);
           compareValues("UUESAR_ErrVld", "reset", read_data, 0);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrType')%>, read_data);
           compareValues("UUESAR_ErrType","Valid Type", read_data, 4'h0);
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
              `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
           end else begin
              `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
<% } %>
    endtask
endclass : ioaiu_csr_uueir_MemErrInt_seq_<%=obj.multiPortCoreId%>

class set_max_errthd_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(set_max_errthd_<%=obj.multiPortCoreId%>)

  uvm_reg_data_t poll_data, read_data, read_data2, write_data,read_errcountoverflow,read_err_count;
  bit [4:0]  errtype;
  bit [19:0] errinfo;
  bit [7:0]  errthd;

  function new(string name="");
      super.new(name);
  endfunction

  task body();
  getCsrProbeIf();
  getInjectErrEvent();

<% if(has_secded_ott || has_secded) { %>
        if ((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_secded && ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin

        
          if ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test") || $test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test"))
            errinfo = 19'h0;
          else if ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))
            errinfo = 19'h1;

          if ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test") || $test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))
            errtype = 5'h1;
          else if($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test"))
            errtype = 5'h0;
       write_data = 255;
      <% if(obj.useResiliency) { %>
      `uvm_info(get_name(), $sformatf("Writing XAIUCRTR res_corr_err_threshold = %0d", write_data), UVM_NONE)
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCRTR.ResThreshold')%>, write_data);
      <% } %>
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrThreshold')%>, write_data);
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
      ev_<%=obj.multiPortCoreId%>.trigger();
      inject_error(255,150,1'b1,.ott_no(ott_way)); 
      poll_UCESR_ErrVld(0, poll_data);
      poll_UCESR_ErrCountOverflow(0,poll_data);
      poll_UCESR_ErrCount(255,poll_data);
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCountOverflow')%>,read_errcountoverflow);
      read_err_count = poll_data;
            cov.collect_correctable_error(errinfo,errtype,read_err_count,read_errcountoverflow,<%=obj.multiPortCoreId%>);
      if(poll_data != 255) begin
          `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be 255",poll_data))
      end
      if(u_csr_probe_vif.IRQ_C) begin
      `uvm_error("RUN_MAIN",$sformatf("IRQ_C is shuld be zero for ErrCount < ErrThreshold"));
      end
      <% if(obj.useResiliency) { %>
      if(u_csr_probe_vif.cerr_over_thres_fault) begin
      `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault is shuld be zero for ErrCount < ErrThreshold"));
      end
      <% } %>
      inject_error(1,.ott_no(ott_way)); 
      poll_UCESR_ErrVld(1, poll_data);
      //poll_UCESR_ErrCountOverflow(1,poll_data); // ErrVld and ErrCountOverflow both will assert when injected error = 256, This will be valid only when ErrThreshold = 255, this is not consistent with other blocks, CONC-7569.
      poll_UCESR_ErrCountOverflow(0,poll_data); // Only ErrVld will assert when injected error = 256, CONC-8116
      poll_UCESR_ErrCount(255,poll_data);
      if(poll_data != 255) begin
          `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be 255",poll_data))
      end
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrType')%>, read_data);
      compareValues("UCESR_ErrType","Valid Type", read_data, errtype);
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrInfo')%>, read_data);
      compareValues("UCESR_ErrType","Valid Type", read_data, errinfo);
      fork
        begin
          wait (u_csr_probe_vif.IRQ_C === 1);
        end
        begin
          #200000ns;
          `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
        end
      join_any
      disable fork;
       <% if(obj.useResiliency) { %>
        if(!u_csr_probe_vif.cerr_over_thres_fault) begin
       `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted"));
        end
        else begin
          `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted"), UVM_NONE);
        end
      <% } %>

      inject_error(1,.ott_no(ott_way)); 
      poll_UCESR_ErrVld(1, poll_data);
      poll_UCESR_ErrCountOverflow(1,poll_data);
      poll_UCESR_ErrCount(255,poll_data);
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCountOverflow')%>,read_errcountoverflow);
      read_err_count = poll_data;
            cov.collect_correctable_error(errinfo,errtype,read_err_count,read_errcountoverflow,<%=obj.multiPortCoreId%>);
      if(poll_data != 255) begin
          `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be 255",poll_data))
      end
      #(<%=obj.Clocks[0].params.period%>ps*$urandom_range(0,50));
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, write_data);
           // Read UCESR_ErrVld , it should be 0
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
           compareValues("UCESR_ErrVld", "reset", read_data, 0);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCount')%>, read_data);
           compareValues("UCESR_ErrCount", "now clear", read_data, 0);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCountOverflow')%>, read_data);
           compareValues("UCESR_ErrOvf", "now clear", read_data, 0);

           // Monitor IRQ_C pin , it should be 0 now
           fork
             begin
               wait (u_csr_probe_vif.IRQ_C === 0);
	       `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asseretd"), UVM_HIGH)
             end
             begin
               #200000ns;
                `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still aseerted"));
             end
           join_any
           disable fork;   
      end else begin
      ev_<%=obj.multiPortCoreId%>.trigger();
    end
<% } else { %>
    ev_<%=obj.multiPortCoreId%>.trigger();
<% } %>
  endtask
endclass : set_max_errthd_<%=obj.multiPortCoreId%>

class always_inject_error_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(always_inject_error_<%=obj.multiPortCoreId%>)

  uvm_reg_data_t write_data, read_data;
  uvm_reg_data_t poll_data;
  int  k_num_read_req;
  int  k_num_write_req;

  function new(string name="");
      super.new(name);
  endfunction

  task body();
  getCsrProbeIf();
  getInjectErrEvent();
  $value$plusargs("k_num_read_req=%d",k_num_read_req);
 $value$plusargs("k_num_write_req=%d",k_num_write_req);

<% if(has_secded_ott || has_secded) { %>
    if(tag_secded || data_secded || ott_secded) begin
      write_data = 0;
      <% if(obj.useResiliency) { %>
             //#Stimulus.IOAIU.CorrectableErr.ResThreshold
             write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCRTR.ResThreshold')%>, 0);
     <% } %>

      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
      
   
        fork
           if($test$plusargs("always_inject_corr_error")) begin
           inject_error(5000000,1,1'b1,.ott_no(ott_way)); 
           end

    join_none
   end
  <% } %>
  ev_<%=obj.multiPortCoreId%>.trigger();

  endtask
endclass : always_inject_error_<%=obj.multiPortCoreId%>

class ioaiu_csr_cecr_errInt_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_cecr_errInt_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, write_data, read_data, read_err_info, read_err_type,read_errcountoverflow,read_err_count;
    bit [4:0]  errtype;
    bit [19:0] errinfo;
    bit [7:0]  errthd;

    function new(string name="");
    super.new(name);
    endfunction

task body();
 bit dis_cecr_med_4resiliency = $test$plusargs("dis_cecr_med_4resiliency") ? 1 : 0;
getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded_ott || has_secded) { %>
        if ((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_secded && ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin

        
          if ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test") || $test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test"))
            errinfo = 20'h0;
          else if ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))
            errinfo = 20'h1;

          if ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test") || $test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))
            errtype = 5'h1;
          else if($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test"))
            errtype = 5'h0;
            if($test$plusargs("eviction_seq"))
            std::randomize(errthd) with { errthd dist{[0:100] := 25, [101:200] := 25,  [201:254] := 25, 255:=50};};
            else
            errthd = 0;
            <% if(obj.useResiliency) { %>
             //#Stimulus.IOAIU.CorrectableErr.ResThreshold
            `uvm_info(get_name(), $sformatf("Writing XAIUCRTR res_corr_err_threshold = %0d",errthd), UVM_NONE)
             write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCRTR.ResThreshold')%>, errthd);
            <% } %>
            //#Stimulus.IOAIU.CorrectableErr.ErrThreshold
            write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrThreshold')%>, errthd);
           //#Stimulus.IOAIU.CorrectableErr.ErrDetEn
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
           //#Stimulus.IOAIU.CorrectableErr.ErrIntEn
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
           ev_<%=obj.multiPortCoreId%>.trigger();
           //#Stimulus.IOAIU.CorrectableErr.SingleBitErrInjection
           inject_error(errthd,120,1'b1,.ott_no(ott_way));
           //#Check.IOAIU.CorrectableErr.ErrVld 
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
           compareValues("UCESR_ErrVld","reset", read_data, 0);
            //#Check.IOAIU.CorrectableErr.ErrorCountOverflow
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCountOverflow')%>, read_data);
           compareValues("UCESR_ErrCountOverflow","reset", read_data, 0);
            poll_data = 0;
           poll_UCESR_ErrCount(errthd,poll_data);
           if(poll_data != errthd) begin
               `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
           end
            //#Check.IOAIU.CorrectableErr.IRQ_C
            if(u_csr_probe_vif.IRQ_C) begin
           `uvm_error("RUN_MAIN",$sformatf("IRQ_C is shuld be zero for ErrCount < ErrThreshold"));
            end
            <% if(obj.useResiliency) { %>
           //#Check.IOAIU.CorrectableErr.cerr_over_thres_fault
           if(u_csr_probe_vif.cerr_over_thres_fault) begin
           `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault is shuld be zero for ErrCount < ErrThreshold"));
           end
           <% } %>
           //#Stimulus.IOAIU.CorrectableErr.SingleBitErrInjection 
           inject_error(1,.ott_no(ott_way));
           //#Check.IOAIU.CorrectableErr.ErrVld 
           poll_UCESR_ErrVld(1, poll_data);
           //#Check.IOAIU.CorrectableErr.ErrorCountOverflow
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCountOverflow')%>,read_errcountoverflow);
           compareValues("UCESR_ErrCountOverflow","reset", read_data, 0);
           //#Check.IOAIU.CorrectableErr.ErrType
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrType')%>,  read_err_type);
           compareValues("UCESR_ErrType","Valid Type",  read_err_type,  errtype);
           //#Check.IOAIU.CorrectableErr.ErrInfo
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrInfo')%>, read_err_info);
           compareValues("UCESR_ErrType","Valid Type",  read_err_info, errinfo);
          // Read UCESR_ErrCount , it should be at errthd
           poll_data = 0;
           poll_UCESR_ErrCount(errthd,poll_data);
           read_err_count = poll_data;
           if(read_err_count != errthd) begin
               `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",read_err_count,errthd))
           end
            cov.collect_correctable_error(errinfo,errtype,read_err_count,read_errcountoverflow,<%=obj.multiPortCoreId%>);
           fork
             begin
               //#Check.IOAIU.CorrectableErr.IRQ_C
               wait (u_csr_probe_vif.IRQ_C === 1);
             end
             begin
               #200000ns;
               `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
             end
           join_any
           disable fork;
           <% if(obj.useResiliency) { %>
              //#Check.IOAIU.CorrectableErr.cerr_over_thres_fault
              if(!u_csr_probe_vif.cerr_over_thres_fault) begin
              `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted"));
              end
              else begin
             `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted"), UVM_NONE);
              end
           <% } %>
          //#Stimulus.IOAIU.CorrectableErr.SingleBitErrInjection 
           inject_error(1,.ott_no(ott_way)); 
           //#Check.IOAIU.CorrectableErr.ErrVld
           poll_UCESR_ErrVld(1, poll_data);
          //#Check.IOAIU.CorrectableErr.ErrorCountOverflowErrCount
           poll_UCESR_ErrCountOverflow(1,poll_data);
           read_errcountoverflow = poll_data;
           // Read DMIUCESR_ErrCount , it should be at errthd
           poll_data = 0;
           poll_UCESR_ErrCount(errthd,poll_data);
           read_err_count = poll_data;
          //#Check.IOAIU.CorrectableErr.ErrorCount
           if(read_err_count != errthd) begin
               `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
           end
           //#Stimulus.IOAIU.CorrectableErr.SingleBitErrInjection
            cov.collect_correctable_error(errinfo,errtype,read_err_count,read_errcountoverflow,<%=obj.multiPortCoreId%>);
           inject_error(1,.ott_no(ott_way)); 
           poll_UCESR_ErrVld(1, poll_data);
           //#Check.IOAIU.CorrectableErr.ErrorCountOverflowErrCount
           poll_UCESR_ErrCountOverflow(1,poll_data);
           // Read DMIUCESR_ErrCount , it should be at errthd
           poll_data = 0;
           poll_UCESR_ErrCount(errthd,poll_data);
           if(poll_data != errthd) begin
               `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
           end
           #(<%=obj.Clocks[0].params.period%>ps*$urandom_range(0,50));
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, write_data);
           // Read UCESR_ErrVld , it should be 0
           //#Check.IOAIU.CorrectableErr.ErrVld
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
           compareValues("UCESR_ErrVld", "reset", read_data, 0);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCount')%>, read_data);
           compareValues("UCESR_ErrCount", "now clear", read_data, 0);
            //#Check.IOAIU.CorrectableErr.ErrorCountOverflowErrCount
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCountOverflow')%>, read_data);
           compareValues("UCESR_ErrOvf", "now clear", read_data, 0);

           // Monitor IRQ_C pin , it should be 0 now
           fork
             begin
              //#Check.IOAIU.CorrectableErr.IRQ_C
               wait (u_csr_probe_vif.IRQ_C === 0);
	       `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asseretd"), UVM_HIGH)
             end
             begin
               #200000ns;
                `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still aseerted"));
             end
           join_any
           disable fork;          
         end else if ((tag_parity && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_parity && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_parity && ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.MemErrIntEn')%>, write_data);
           ev_<%=obj.multiPortCoreId%>.trigger();
           inject_error(.ott_no(ott_way)); 
           // wait for IRQ_UC interrupt 
           fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 1);
           end
           begin
             #200000ns;
             `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
           end
           join_any
           disable fork;
           // Read the UUESR_ErrVld
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "set", read_data, 1);
           write_data = 0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.MemErrIntEn')%>, write_data);
           // write  UUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
           // Read the UUESR_ErrVld should be cleared
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "now clear", read_data, 0);
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
         end else begin
           // Read UCESR_ErrVld , it should be 0
           ev_<%=obj.multiPortCoreId%>.trigger();
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
           compareValues("UCESR_ErrVld", "set", read_data, 0);
           // Read UCESAR_ErrVld , it should be 0
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, read_data);
           compareValues("UCESAR_ErrVld", "set", read_data, 0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_C === 0)begin
              `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asseretd"), UVM_HIGH)
           end else begin
              `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still asserted"));
           end
         end
<% } else { %>
          // Read UCESR_ErrVld , it should be 0
           ev_<%=obj.multiPortCoreId%>.trigger();
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
           compareValues("UCESR_ErrVld", "set", read_data, 0);
          // Read UCESAR_ErrVld , it should be 0
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, read_data);
           compareValues("UCESAR_ErrVld", "set", read_data, 0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_C === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asseretd"), UVM_HIGH)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still asserted"));
          end
<% } %>
    endtask
endclass : ioaiu_csr_cecr_errInt_seq_<%=obj.multiPortCoreId%>

//CSR sequences//
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if ErrDetEn is set, correctable errors are logged by design. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. If dir contains SECDED, enable Error detection from correctable CSR
* 2. Enable OTT single-bit error from command line
* 3. Poll Error valid bit from Correctable status register until it is 1. (Error captured)
* 4. Disable error detection in CSR.
* 5. Read ErrVld, which should be set until its cleared.
* 6. Clear ErrVld by writting 1 (W1C access types of this field) in status register
* 7. Compare read value with 0 for ErrVld field in status register (should be cleared)
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
class ioaiu_csr_ucecr_errDetEn_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_ucecr_errDetEn_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [4:0]  errtype;
    bit [19:0] errinfo;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      bit dis_cecr_med_4resiliency = $test$plusargs("dis_cecr_med_4resiliency") ? 1 : 0;
      bit dis_uedr_med_4resiliency = $test$plusargs("dis_uedr_med_4resiliency") ? 1 : 0;
      <% if(obj.useResiliency) { %>
      bit double_bitErr = ($test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test")
                          || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test")
                          || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test")
                        ) ? 1 : 0;
      bit single_bitErr = ($test$plusargs("ccp_single_bit_tag_direct_error_test")
                          || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test")
                          || $test$plusargs("ccp_single_bit_data_direct_error_test")
                          || $test$plusargs("ccp_multi_blk_single_data_direct_error_test")
                          || $test$plusargs("ccp_single_bit_ott_direct_error_test")
                          || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")
                        ) ? 1 : 0;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCRTR.ResThreshold')%>, 0);
      <% } %>
      getCsrProbeIf();
      getInjectErrEvent();
      getSMIIf();
<% if(has_secded_ott || has_secded) { %>
      if ((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_secded && ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin

        
        if ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test") || $test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test"))
          errinfo = 20'h0;
        else if ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))
          errinfo = 20'h1;

        if ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test") || $test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))
          errtype = 5'h1;
        else if($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test"))
          errtype = 5'h0;

        if(!dis_cecr_med_4resiliency) begin
        // Set the UCECR_ErrDetEn = 1
        write_data = 1;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
        ev_<%=obj.multiPortCoreId%>.trigger();
        inject_error(.ott_no(ott_way)); 
        //keep on  Reading the UCESR_ErrVld bit = 1
        poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>,1,poll_data);
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrType')%>, read_data);
        compareValues("UCESR_ErrType","Valid Type", read_data, errtype);
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrInfo')%>, read_data);
        compareValues("UCESR_ErrInfo","Valid Type", read_data, errinfo);
        // Set the UCECR_ErrDetEn = 0, to diable the error detection
        write_data = 0;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
        // Read UCESR_ErrVld , it should be 1
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
        compareValues("UCESR_ErrVld", "set", read_data, 1);
        // write  UCESR_ErrVld = 1 , W1C
        write_data = 0;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, write_data);
        // Read the UCESR_ErrVld should be cleared
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
        compareValues("UCESR_ErrVld", "now clear", read_data, 0);
        end
        else begin
          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, 0);
          ev_<%=obj.multiPortCoreId%>.trigger();
          inject_error(.ott_no(ott_way));
          #200us;
          `uvm_info("RUN_MAIN",$sformatf("Timeout!"), UVM_NONE);
        end
        <% if(obj.useResiliency) { %>
        begin
          if(single_bitErr) begin
            if(!u_csr_probe_vif.cerr_over_thres_fault) begin
              `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr));
            end
            else begin
              `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr), UVM_NONE);
            end
          end
          else if(double_bitErr) begin
            if(u_csr_probe_vif.cerr_over_thres_fault) begin
              `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr));
            end
            else begin
              `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr), UVM_NONE);
            end
            if(!u_csr_probe_vif.fault_mission_fault)
              `uvm_error("RUN_MAIN",$sformatf("fault_mission_fault isn't asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr))
            else
              `uvm_info("RUN_MAIN",$sformatf("fault_mission_fault is asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr), UVM_NONE)
            if(u_csr_probe_vif.fault_latent_fault)
              `uvm_error("RUN_MAIN",$sformatf("fault_latent_fault is asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr))
            else
              `uvm_info("RUN_MAIN",$sformatf("fault_latent_fault isn't asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr), UVM_NONE)
          end
        end
        <% } %>
      end else if ((tag_parity && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_parity && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_parity && ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin
        if(!dis_uedr_med_4resiliency) begin
        write_data = 1;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
        ev_<%=obj.multiPortCoreId%>.trigger();
        if ($test$plusargs("wait_for_snp_req")) begin
             do begin
               @(posedge m_smi<%=smi_portid_snpreq%>_tx_vif.clk);
             end while (m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_ready === 1'b0 || (smi_seq_item::type2class(m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_type) != eConcMsgSnpReq));
           end
        inject_error(.ott_no(ott_way)); 
        //keep on  Reading the UUESR_ErrVld bit = 1
        poll_UUESR_ErrVld(1, poll_data);
        write_data = 0;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
        // write  UUESR_ErrVld = 1 , W1C
        write_data = 1;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
        // Read the UUESR_ErrVld should be cleared
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
        compareValues("UUESR_ErrVld", "now clear", read_data, 0);
        end
        else begin
          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data);
          ev_<%=obj.multiPortCoreId%>.trigger();
          if ($test$plusargs("wait_for_snp_req")) begin
             do begin
               @(posedge m_smi<%=smi_portid_snpreq%>_tx_vif.clk);
             end while (m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_ready === 1'b0 || (smi_seq_item::type2class(m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_type) != eConcMsgSnpReq));
           end
          inject_error(.ott_no(ott_way));
          #200us;
          `uvm_info("RUN_MAIN",$sformatf("Timeout!"), UVM_NONE);
        end
        <% if(obj.useResiliency) { %>
        begin
          if(single_bitErr || double_bitErr) begin
            if(u_csr_probe_vif.cerr_over_thres_fault) begin
              `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr));
            end
            else begin
              `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr), UVM_NONE);
            end
            if(!u_csr_probe_vif.fault_mission_fault)
              `uvm_error("RUN_MAIN",$sformatf("fault_mission_fault isn't asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr))
            else
              `uvm_info("RUN_MAIN",$sformatf("fault_mission_fault is asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr), UVM_NONE)
            if(u_csr_probe_vif.fault_latent_fault)
              `uvm_error("RUN_MAIN",$sformatf("fault_latent_fault is asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr))
            else
              `uvm_info("RUN_MAIN",$sformatf("fault_latent_fault isn't asserted. single_bitErr=%0d, double_bitErr=%0d", single_bitErr, double_bitErr), UVM_NONE)
          end
        end
        <% } %>
      end else begin
        ev_<%=obj.multiPortCoreId%>.trigger();
        // Read the UCESR_ErrVld should be clear
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
        compareValues("UESR_ErrVld", "RAZ/WI", read_data, 0);
        // Read UCESAR_ErrVld , it should also clear, beacuse it is alias register
        // of register UCESR_*
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, read_data);
        compareValues("UESAR_ErrVld", "RAZ/WI", read_data, 0);
      end
<% } else { %>
      ev_<%=obj.multiPortCoreId%>.trigger();
      // Read the UCESR_ErrVld should be clear
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
      compareValues("UESR_ErrVld", "RAZ/WI", read_data, 0);
      // Read UCESAR_ErrVld , it should also clear, beacuse it is alias register
      // of register UCESR_*
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, read_data);
      compareValues("UESAR_ErrVld", "RAZ/WI", read_data, 0);
<% } %>
    endtask
endclass : ioaiu_csr_ucecr_errDetEn_seq_<%=obj.multiPortCoreId%>

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are corrected (ErrThreshold filed CECR register) which should be count by Error counter. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. If dir contains SECDED, Write Error threshold with random value b/w 1 to 20 (DUT must assert Interrupt once threshold value errors are corrected.
* 2. Eable Error detection from correctable CSR.
* 3. Enable Error Interrupt from CSR. If enabled then correctable iterrupt signal is asserted.
* 4. Enable OTT single-bit error from command line
* 5. Poll ErrVld from Status register until it is set i.e. Correctable Errors are logged.
* 7. Compare ErrCount value and should be non-zero 
* 8. Disable Error Detection and Error Interrupt filed by writing 0.
* 9. Clear ErrVld by writting 1 (W1C access types of this field) in status register
* 10. Check if ErrCount should be cleared.
* 11. Repeat step 1 to 10.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class ioaiu_csr_ucecr_errThd_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_ucecr_errThd_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      getCsrProbeIf();
      getInjectErrEvent();
<% if(has_secded_ott || has_secded) { %>
    if ((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_secded && ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin
      // Set the UCECR_ErrThreshold 
      errthd = $urandom_range(1,20);
      write_data = errthd;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrThreshold')%>, write_data);
      // Set the UCECR_ErrDetEn = 1
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
      // Set the UCECR_ErrIntEn = 1
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
      // write  UCESR_ErrVld = 1 , to reset it
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, write_data);
      ev_<%=obj.multiPortCoreId%>.trigger();
      inject_error(errthd+1,5,1'b1,.ott_no(ott_way)); 
      //keep on  Reading the UCESR_ErrVld bit = 1 
      poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>,1,poll_data);
      // Read UCESR_ErrCount , it should be at errthd
      poll_data = 0;
      poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCount')%>,errthd,poll_data);
      if(poll_data < errthd) begin
          `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
      end
      // Set the UCECR_ErrDetEn = 0
      write_data = 0;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
      // write : UCESR_ErrVld = 1 , to reset it
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, write_data);
      // Read UCESR_ErrVld , it should be 0
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
      compareValues("UCESR_ErrVld", "now clear", read_data, 0);
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCount')%>, read_data);
      compareValues("UCESR_ErrCount", "now clear", read_data, 0);
      ///////////////////////////////////
      // Repeat entire process
      ///////////////////////////////////
      // Set the UCECR_ErrThreshold 
      errthd = $urandom_range(1,20);
      poll_data = 0;
      write_data = errthd;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrThreshold')%>, write_data);
      // Set the UCECR_ErrDetEn = 1
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
      // Set the UCECR_ErrIntEn = 1
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
      // write  UCESR_ErrVld = 1 , to reset it
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, write_data);
      ev_<%=obj.multiPortCoreId%>.trigger();
      inject_error(errthd+1,5,1'b1,.ott_no(ott_way)); 
      //keep on  Reading the UCESR_ErrVld bit = 1 
      poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>,1,poll_data);
      // Read UCESR_ErrCount , it should be at errthd
      poll_data = 0;
      poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCount')%>,errthd,poll_data);
      if(poll_data < errthd) begin
          `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
      end
      // Set the UCECR_ErrDetEn = 0
      write_data = 0;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
      // write : UCESR_ErrVld = 1 , to reset it
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, write_data);
      // Read UCESR_ErrVld , it should be 0
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
      compareValues("UCESR_ErrVld", "now clear", read_data, 0);
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCount')%>, read_data);
      compareValues("UCESR_ErrCount", "now clear", read_data, 0);     
    end else if ((tag_parity && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_parity && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_parity && ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
      ev_<%=obj.multiPortCoreId%>.trigger();
      inject_error(.ott_no(ott_way)); 
      //keep on  Reading the UUESR_ErrVld bit = 1
      poll_UUESR_ErrVld(1, poll_data);
      write_data = 0;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
      // write  UUESR_ErrVld = 1 , W1C
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
      // Read the UUESR_ErrVld should be cleared
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
      compareValues("UUESR_ErrVld", "now clear", read_data, 0);
    end else begin
      ev_<%=obj.multiPortCoreId%>.trigger();
    end
<% } else { %>
      ev_<%=obj.multiPortCoreId%>.trigger();
<% } %>
    endtask
endclass : ioaiu_csr_ucecr_errThd_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_prot_cecr_errThd_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_ucecr_errThd_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      getCsrProbeIf();
      getInjectErrEvent();
      // Set the UCECR_ErrThreshold 
      errthd = $urandom_range(1,20);
      write_data = errthd;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrThreshold')%>, write_data);
       <% if(obj.useResiliency) { %>
      `uvm_info(get_name(), $sformatf("Writing XAIUCRTR res_corr_err_threshold = %0d", write_data), UVM_NONE)
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCRTR.ResThreshold')%>, write_data);
      <% } %>
      // Set the UCECR_ErrDetEn = 1
      write_data = 1;
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
      // Set the UCECR_ErrIntEn = 1
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
      ev_<%=obj.multiPortCoreId%>.trigger();
      // Read UCESR_ErrCount , it should be at errthd
      poll_data = 0;
       while(poll_data > errthd) begin
       fork
       begin
       read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCount')%>,poll_data);
       end
       begin
       read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
       end
       begin
        <% if(obj.useResiliency) { %>
        if(u_csr_probe_vif.cerr_over_thres_fault) begin
       `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted"));
        end
        else begin
          `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted"), UVM_NONE);
        end
      <% } %>
      end
      join_none
      end 
      // Set the UCECR_ErrDetEn = 0
     fork
        begin
          wait (u_csr_probe_vif.IRQ_C === 1);
        end
        begin
          #200000ns;
          `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
        end
      join_any
      disable fork;
       <% if(obj.useResiliency) { %>
        if(!u_csr_probe_vif.cerr_over_thres_fault) begin
       `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted"));
        end
        else begin
          `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted"), UVM_NONE);
        end
      <% } %>
      poll_UCESR_ErrVld(1, poll_data);
      endtask
endclass : ioaiu_csr_prot_cecr_errThd_seq_<%=obj.multiPortCoreId%>


//  ________________________________________________________________________________________________________
//
//  Concerto System Architecture Specification Revision B, Version 0.4 Section 8.7 Page 55
//  ________________________________________________________________________________________________________
//
//  Additionally, in the case that software is writing the error status register in the same cycle that one or
//  more errors occur, the result appears as if first the error occurred and then the write updated the state
//  of the register. In the case that software is writing the error status alias register in the same cycle that
//  one or more errors occur, the write simply updates the state of the register.
//
//-----------------------------------------------------------------------
class ioaiu_csr_ucecr_sw_write_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_ucecr_sw_write_seq_<%=obj.multiPortCoreId%>)

   uvm_reg_data_t poll_data, read_data, read_data2, write_data;
   uvm_status_e           status;
   bit [7:0]  errthd;
   int        errcount_vld, errthd_vld;
   int        i,j;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
<% if(has_secded_ott || has_secded) { %>
      if ((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_secded && ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin
        getCsrProbeIf();
        getInjectErrEvent();
        // Set the UCECR_ErrDetEn = 1
        write_data = 1;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
        ev_<%=obj.multiPortCoreId%>.trigger();
        inject_error(.ott_no(ott_way)); 
        poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>,1,poll_data);
        // write  UCESR_ErrVld = 1 , to reset it
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, write_data);
        
        write_data = 0;
        fork
            begin
               for (i=0;i<100;i++) begin
                  <%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR')%>.write(status,write_data,.parent(this));
               end
            end
            begin
              for (j=0;j<10;j++) begin
                inject_error(.ott_no(ott_way)); 
              end
            end
        join
        // Set the UCECR_ErrDetEn = 0
        write_data = 0;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
        // if vld is set, reset it
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
        if(read_data) begin
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, write_data);
        end
      end else begin
        ev_<%=obj.multiPortCoreId%>.trigger();
      end
<% } else { %>
      ev_<%=obj.multiPortCoreId%>.trigger();
<% } %>
    endtask
endclass : ioaiu_csr_ucecr_sw_write_seq_<%=obj.multiPortCoreId%>


class ioaiu_csr_uuecr_sw_write_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_uuecr_sw_write_seq_<%=obj.multiPortCoreId%>)

   uvm_reg_data_t poll_data, read_data, read_data2, write_data;
   uvm_status_e           status;
   bit [7:0]  errthd;
   int        errcount_vld, errthd_vld;
   int        i,j;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
<% if(has_secded_ott || has_secded) { %>
      if((tag_secded && ($test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))) || (ott_secded && ($test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test")))) begin
        getCsrProbeIf();
        getInjectErrEvent();
        // Set the UUECR_ErrDetEn = 1
        write_data = 1;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data);
        ev_<%=obj.multiPortCoreId%>.trigger();
        inject_error(.ott_no(ott_way)); 
        poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>,1,poll_data);
        // write  UCESR_ErrVld = 1 , to reset it
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
        
        write_data = 0;
        fork
            begin
               for (i=0;i<100;i++) begin
                  <%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR')%>.write(status,write_data,.parent(this));
               end
            end
            begin
              for (j=0;j<10;j++) begin
                inject_error(.ott_no(ott_way)); 
              end
            end
        join
        // Set the UUECR_ErrDetEn = 0
        write_data = 0;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data);
        // if vld is set, reset it
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
        if(read_data) begin
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESAR.ErrVld')%>, write_data);
        end
      end else begin
        ev_<%=obj.multiPortCoreId%>.trigger();
      end
<% } else { %>
      ev_<%=obj.multiPortCoreId%>.trigger();
<% } %>
    endtask
endclass : ioaiu_csr_uuecr_sw_write_seq_<%=obj.multiPortCoreId%>

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are injected and logging is disabled (ErrDetEn set to 0) ErrVld and ErrCount should be 0. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. Enable OTT single-bit error from command line
* 2. Compare ErrVld value and should be zero 
* 3. Compare ErrCount value and should be zero 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class ioaiu_csr_ucecr_noDetEn_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_ucecr_noDetEn_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      getCsrProbeIf();
      getInjectErrEvent();
<% if(has_secded_ott || has_secded) { %>
      if ((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_secded && ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin
        ev_<%=obj.multiPortCoreId%>.trigger();
        inject_error(.ott_no(ott_way)); 
        // Don't Set the UCECR_ErrDetEn = 1
        //Reading the UCESR_ErrVld bit = 0
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
        compareValues("UCESR_ErrVld", "not set", read_data, 0);
        // Read UCESR_ErrCount , it should be at 0
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCount')%>, read_data);
        compareValues("UCESR_ErrCount","not set", read_data, 0);
      end else if ((tag_parity && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_parity && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_parity && ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin
        write_data = 0;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
        ev_<%=obj.multiPortCoreId%>.trigger();
        inject_error(.ott_no(ott_way)); 
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
        compareValues("UCESR_ErrVld", "not set", read_data, 0);
      end else begin
        ev_<%=obj.multiPortCoreId%>.trigger();
        // Read the UCESR_ErrVld should be cleared
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
        compareValues("UCESR_ErrVld", "not set", read_data, 0);
        // Read UCESAR_ErrVld , it should also clear, beacuse it is alias register
        // of register UCESR_*
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, read_data);
        compareValues("UCESAR_ErrVld", "not set", read_data, 0);
      end
<% } else { %>
      ev_<%=obj.multiPortCoreId%>.trigger();
      // Read the UCESR_ErrVld should be cleared
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
      compareValues("UCESR_ErrVld", "not set", read_data, 0);
      // Read UCESAR_ErrVld , it should also clear, beacuse it is alias register
      // of register UCESR_*
      read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESAR.ErrVld')%>, read_data);
      compareValues("UCESAR_ErrVld", "not set", read_data, 0);
<% } %>
    endtask
endclass : ioaiu_csr_ucecr_noDetEn_seq_<%=obj.multiPortCoreId%>

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are injected and interrupt assertion is disabled (ErrIntEn set to 0) ErrVld and ErrCount should be 0. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. Enable OTT single-bit error from command line
* 2. Program ErrThreshold to 1 so we can check interupt is asserted or not.
* 3. Enable  error detection and logging.       
* 4. Wait to check if interrupt signal is asserted or not.
* 5. Poll for ErrVld be set and compare to 1.
* 6. Clear ErrVld value and should be zero 
* 7. Compare ErrCountOverflow value and should be zero 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class ioaiu_csr_ucecr_noIntEn_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_ucecr_noIntEn_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      getCsrProbeIf();
      getInjectErrEvent();
<% if(has_secded_ott || has_secded) { %>
      if ((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_secded && ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin
        // Set the UCECR_ErrThreshold 
        write_data = 0;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrThreshold')%>, write_data);
        write_data = 1;
        // Set the UCECR_ErrDetEn = 1
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
        // Dont Set the UCECR_ErrIntEn = 1
        ev_<%=obj.multiPortCoreId%>.trigger();
        inject_error(.ott_no(ott_way)); 
        // wait for IRQ_C interrupt for a while. Shouldn't happen. Then join
        //#Cov.DMI.ErrIntDisEnCorrErrs
        fork
          begin
           `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It shouldn't happen"), UVM_NONE)
           @(u_csr_probe_vif.IRQ_C);
           `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
          end
          begin
           #50000ns;
           `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_NONE)
          end
        join_any
        disable fork;
        //Reading the UCESR_ErrVld bit = 1
        poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>,1,poll_data);
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
        compareValues("UCESR_ErrVld", "set", read_data, 1);
        // write UCESR_ErrVld = 1 to clear it
        write_data = 1;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, write_data);
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCountOverflow')%>, read_data);
        compareValues("UCESR_ErrCountOverflow", "Should be clear", read_data, 0);
        // write UCESR_ErrVld = 1 to clear it
      end else if ((tag_parity && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_parity && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_parity && ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin
        write_data = 1;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
        write_data = 0;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.MemErrIntEn')%>, write_data);
        ev_<%=obj.multiPortCoreId%>.trigger();
        inject_error(.ott_no(ott_way)); 
        // wait for IRQ_C interrupt for a while. Shouldn't happen. Then join
        //#Cov.DMI.ErrIntDisEnCorrErrs
        fork
          begin
           `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It shouldn't happen"), UVM_NONE)
           @(u_csr_probe_vif.IRQ_UC);
           `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
          end
          begin
           #50000ns;
           `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_NONE)
          end
        join_any
        disable fork;
        // Read the UUESR_ErrVld
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
        compareValues("UUESR_ErrVld", "set", read_data, 1);
        write_data = 0;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
        // write  UUESR_ErrVld = 1 , W1C
        write_data = 1;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
        // Read the UUESR_ErrVld should be cleared
        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
        compareValues("UUESR_ErrVld", "now clear", read_data, 0);
      end else begin
        ev_<%=obj.multiPortCoreId%>.trigger();
        fork
          begin
           `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It shouldn't happen"), UVM_HIGH)
          @(u_csr_probe_vif.IRQ_C);
           `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
          end
          begin
           #100000ns;
           `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_HIGH)
          end
        join_any
        disable fork;
      end
<% } else { %>
      ev_<%=obj.multiPortCoreId%>.trigger();
      fork
        begin
         `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It shouldn't happen"), UVM_HIGH)
        @(u_csr_probe_vif.IRQ_C);
         `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
        end
        begin
         #100000ns;
         `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_HIGH)
        end
      join_any
      disable fork;
<% } %>
    endtask
endclass : ioaiu_csr_ucecr_noIntEn_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_CMO_test_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_CMO_test_seq_<%=obj.multiPortCoreId%>)
  uvm_reg_data_t read_data, write_data, write_data_to_compare;
  rand bit [5:0]  cache_word;
  rand bit [5:0]  cache_way;
  rand bit [19:0] cache_entry;
  rand bit [5:0]  cache_arrayId;
  bit [31:0] mask =32'hffff_ffff;
  bit security;
  ioaiu_scoreboard ioaiu_scb;

  function new(string name="");
      super.new(name);
  endfunction

  task body();
    <% if (obj.DutInfo.useCache){ %>
    if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                               .inst_name( "*" ),
                                               .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                               .value( ioaiu_scb ))) begin
      `uvm_error("ioaiu_csr_CMO_test_seq", "ioaiu_scb model not found")
    end

    if(ioaiu_scb.m_ncbu_cache_q.size()==0) 
        `uvm_error("ioaiu_csr_CMO_test_seq", "no entry in cache to inject errors")
    else 
        `uvm_info("ioaiu_csr_CMO_test_seq", $sformatf("cache_size:%0d", ioaiu_scb.m_ncbu_cache_q.size()), UVM_LOW)

    foreach(ioaiu_scb.m_ncbu_cache_q[i]) begin
      mask = 32'hFFFF_FFFF;
      cache_entry = ioaiu_scb.m_ncbu_cache_q[i].Index;
      cache_way = ioaiu_scb.m_ncbu_cache_q[i].way;
      security = ioaiu_scb.m_ncbu_cache_q[i].security;
      //cache_arrayId = $urandom_range(0,1);
      //cache_arrayId = $urandom_range(0,1);
      cache_arrayId = 0;
      if(cache_arrayId) begin: _data_array_
         //cache_word = ($urandom_range(0,<%=(512/obj.DutInfo.ccpParams.wData)-1%>) << (5-$clog2(<%=(512/obj.DutInfo.ccpParams.wData)%>))) | ($urandom_range(0,<%=Math.ceil(wDataArrayEntry/32)-1%>));
         //cache_word = $urandom_range(0,3);
         mask &= ((cache_word & ((1<< <%=(5-Math.log2(512/obj.DutInfo.ccpParams.wData))%>)-1)  ) == <%=Math.ceil(wDataArrayEntry/32)-1%> ) ? ((32'h1 << <%=(wDataArrayEntry%32)%>)-32'h1): mask;
      end: _data_array_
      else begin: _tag_array_
         cache_word = $urandom_range(0,<%=Math.ceil(wTagArrayEntry/32)-1%>);
         mask &= (cache_word == <%=Math.ceil(wTagArrayEntry/32)-1%> ) ? ((32'h1 << <%=(wTagArrayEntry%32)%>)-32'h1): mask;
      end: _tag_array_

      `uvm_info(get_full_name(),$sformatf("itr:%0d wTagArrayEntry:<%=wTagArrayEntry%> wDataArrayEntry:<%=wDataArrayEntry%> Configuring arrayId:%0d Index:0x%0x, Way:0x%0x, Word:0x%0x, Sec:0x%0x Mask:0x%0x",i, cache_arrayId, cache_entry, cache_way,cache_word,security, mask), UVM_NONE)

      //Set cache index way word
      write_data = {cache_word,cache_way,cache_entry};
      <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,write_data,.parent(this));

      //Execute debug read to check with the cacheQ content, the checks are in ioaiu_scoreboard.
      write_data = {9'h0,security,cache_arrayId,12'h0,4'hc};
      <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));
      
      //Wait for MntOp to complete
      do 
          <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
      while(field_rd_data);
      `uvm_info(get_full_name(), $psprintf("itr:%0d 1st Debug Read Operation Done", i),UVM_NONE);

      //Read the Data from data register to compare with ncbu cache data
      <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMDR')%>.read(status,field_rd_data,.parent(this));
      `uvm_info(get_full_name(), $psprintf("itr:%0d PCMDR read to check against data in cache-model", i),UVM_NONE);
      
      //Write data in to data register
      write_data_to_compare = $urandom;
      <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMDR')%>.write(status,write_data_to_compare,.parent(this));
      `uvm_info(get_full_name(), $psprintf("itr:%0d Done writing data:0x%0x to PCMDR" ,i, write_data_to_compare),UVM_NONE);

      //Execute debug write
      write_data = {9'h0,security,cache_arrayId,12'h0,4'he};
      <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));
      
      //Wait for MntOp to complete
      do 
          <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
      while(field_rd_data);
      `uvm_info(get_full_name(), $psprintf("itr:%0d Debug Write Operation Done", i),UVM_NONE);
      <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
	  cov.collect_mnt_opcode(write_data);
        `endif
      <%}%>  

      //currupting previous debug write data to make sure previous write is not lingering and do not false match with debug read data.
      write_data = write_data_to_compare ^ 32'hFFFF_FFFF;
      `uvm_info("CMO_TEST_SEQ", $psprintf("itr:%0d corrupting previous debug write data in register XAIUPCMDR by writing data: 0x%0x",i, write_data),UVM_NONE);
      <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMDR')%>.write(status,write_data,.parent(this));
           //Execute debug read
      write_data = {9'h0,security,cache_arrayId,12'h0,4'hc};
      <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));
      
      //Wait for MntOp to complete
      do 
          <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
      while(field_rd_data);
      `uvm_info(get_full_name(), $psprintf("itr:%0d 2nd Debug Read Operation Done", i),UVM_NONE);

      //Read the Data from data register to compare with write data
      <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMDR')%>.read(status,field_rd_data,.parent(this));
      `uvm_info(get_full_name(), $psprintf("itr:%0d PCMDR read to check against debug write-data", i),UVM_NONE);

      if ((write_data_to_compare & mask) !== (field_rd_data & mask)) begin
        `uvm_error(get_full_name(),$sformatf("CMO debug read data: 0x%0x not matching with debug write data: 0x%0x, Mask :0x%0x",field_rd_data,write_data_to_compare,mask))
      end else begin
        `uvm_info(get_full_name(),$sformatf("CMO debug read data: 0x%0x matching with debug write data: 0x%0x Mask:0x%0x",field_rd_data,write_data_to_compare,mask),UVM_NONE)
      end
      <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
	  cov.collect_mnt_opcode(write_data);
        `endif
      <%}%>

    end
    <% } %>
  endtask
endclass : ioaiu_csr_CMO_test_seq_<%=obj.multiPortCoreId%>

class ioaiu_csr_elr_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_elr_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [4:0]  errtype;
    bit [19:0] errinfo;
    ioaiu_scoreboard ioaiu_scb;
    bit [47:0] actual_addr;
    bit [47:0] expt_addr;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;
    rand bit [5:0]  err_injected_cache_word;
    rand bit [5:0]  err_injected_cache_way;
    rand bit [19:0] err_injected_cache_entry;
    bit [31:0]  mask1;
    bit [31:0]  mask2;
    bit [31:0]  mask;
    smi_addr_t  m_addr; 
    int offset = <%=obj.wCacheLineOffset%>;
    int unsigned m_rand_index;
    int m_rand_index_dirty_state[$];
    bit security;

    <% if (obj.DutInfo.useCache){ %>
    constraint c_nSets  { err_injected_cache_entry >= 0; err_injected_cache_entry < <%=nSetsPerCore%>;}
    constraint c_nWays  { err_injected_cache_way >= 0; err_injected_cache_way < <%=obj.DutInfo.ccpParams.nWays%>;}  
   <%}%>

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded_ott || has_secded) { %>
        if((tag_secded && $test$plusargs("tag_error_test") && $test$plusargs("ccp_double_bit_direct_tag_error_test")) || (data_secded && ($test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test") || $test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_secded && ($test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test") || $test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin
     
           if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                                  .inst_name( "*" ),
                                                  .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                                  .value( ioaiu_scb ))) begin
             `uvm_error("ioaiu_csr_elr_seq", "ioaiu_scb model not found")
           end

           if($test$plusargs("uncorr_mem_err_en")) begin
             write_data = 1;
             write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
           end
           if($test$plusargs("corr_mem_err_en")) begin
             write_data = 1;
             write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
           end
           ev_<%=obj.multiPortCoreId%>.trigger();
           if ($test$plusargs("ott_error_test")) begin
             inject_error(.ott_no(ott_way)); 
           end
           <% if (obj.DutInfo.useCache){ %>
           if ($test$plusargs("data_error_test")) begin
             #500us;
             if(ioaiu_scb.m_ncbu_cache_q.size()==0) `uvm_error("ioaiu_csr_elr_seq", "no entry in cache to inject errors")
             if(ioaiu_scb.m_ncbu_cache_q.size()>0) begin
               //m_rand_index = $urandom_range(0, ioaiu_scb.m_ncbu_cache_q.size()-1);
               m_rand_index_dirty_state = ioaiu_scb.m_ncbu_cache_q.find_index with (item.state == UD);
               err_injected_cache_entry = ioaiu_scb.m_ncbu_cache_q[m_rand_index_dirty_state[0]].Index;
               err_injected_cache_way = ioaiu_scb.m_ncbu_cache_q[m_rand_index_dirty_state[0]].way;
               security = ioaiu_scb.m_ncbu_cache_q[m_rand_index_dirty_state[0]].security;
               m_addr   = ioaiu_scb.m_ncbu_cache_q[m_rand_index_dirty_state[0]].addr; 
               err_injected_cache_word = 0;
               `uvm_info("RUN_MAIN",$sformatf("configuring Sets :0x%0x,  way :0x%0x,  Word :0x%0x, security = 0x%0x, addr = 0x%0x",err_injected_cache_entry,err_injected_cache_way,err_injected_cache_word,security,m_addr), UVM_NONE)
               
               //Setup MntOp Read
               write_data = {err_injected_cache_word,err_injected_cache_way,err_injected_cache_entry};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,write_data,.parent(this));

               write_data = {9'h0,security,6'h1,12'h0,4'hc};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));

               //Wait for MntOpActv
               do
               begin
                   data = 0;
                   <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
               end while(field_rd_data != data);

               //Read the Data
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMDR')%>.read(status,field_rd_data,.parent(this));

               if($test$plusargs("corr_mem_err_en")) begin
                 //Inject the tag Error 
                 mask = 1'b1 << $urandom_range(31, 0);
                 write_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));
               end

               if ($test$plusargs("uncorr_mem_err_en")) begin
                 mask1 = 1'b1 << $urandom_range(15, 0);
                 mask2 = 1'b1 << $urandom_range(31, 16);
                 mask = mask1 | mask2;
                 write_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));
               end

               `uvm_info("RUN_MAIN", $psprintf("RD_DATA:%0h and WR_DATA:%0h and Mask:%0h", 
                            field_rd_data,write_data,mask),UVM_MEDIUM);

               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMDR')%>.write(status,write_data,.parent(this));

               write_data = {9'h0,security,6'h1,12'h0,4'he};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));

               //Wait for MntOpActv
               do
               begin
                   data = 0;
                   <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
               end while(field_rd_data != data);

               <% if((obj.DutInfo.wAddr-obj.wCacheLineOffset) > 32) {%>
               //Program the ML0 Entry for Addr
               //TODO: This is correct as per the specs, RTL will be updated in Ncore 3.2
                write_data   = m_addr >> offset;
             
	       //write_data = m_addr - (m_addr %64);
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,write_data,.parent(this));
               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)

               //Program the ML1 Entry for Addr
               write_data   = m_addr  >> offset;
               write_data   = write_data >> 'h20;
               write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR1.MntAddr')%>, write_data);

               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)
               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Found the Addr size to be greater than 32 Size:%0d",<%=obj.DutInfo.wAddr-obj.wCacheLineOffset%>), UVM_MEDIUM)
              <%}else{%>
               //Program the ML0 Entry for Addr
               write_data   = m_addr >> offset;
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,write_data,.parent(this));
               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)
              <%}%>

               //Program the MntOp Register with Opcode-6 to flush the entry
               write_data = {9'h0,security,6'h0,12'h0,4'h6};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));

               //Wait for MntOpActv
               do
               begin
                   data = 0;
                   <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
               end while(field_rd_data != data);
             end
           end
           if ($test$plusargs("tag_error_test")) begin
             #500us;
             if(ioaiu_scb.m_ncbu_cache_q.size()==0) `uvm_error("ioaiu_csr_elr_seq", "no entry in cache to inject errors")
             if(ioaiu_scb.m_ncbu_cache_q.size()>0) begin
               m_rand_index = $urandom_range(0, ioaiu_scb.m_ncbu_cache_q.size()-1);
               err_injected_cache_entry = ioaiu_scb.m_ncbu_cache_q[m_rand_index].Index;
               err_injected_cache_way = ioaiu_scb.m_ncbu_cache_q[m_rand_index].way;
               security = ioaiu_scb.m_ncbu_cache_q[m_rand_index].security;
               m_addr   = ioaiu_scb.m_ncbu_cache_q[m_rand_index].addr; 
               err_injected_cache_word = 0;
               `uvm_info("RUN_MAIN",$sformatf("configuring Sets :0x%0x,  way :0x%0x,  Word :0x%0x, security = 0x%0x, addr = 0x%0x",err_injected_cache_entry,err_injected_cache_way,err_injected_cache_word,security,m_addr), UVM_MEDIUM)
               
               //Setup MntOp Read
               write_data = {err_injected_cache_word,err_injected_cache_way,err_injected_cache_entry};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,write_data,.parent(this));

               write_data = {9'h0,security,6'h0,12'h0,4'hc};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));

               //Wait for MntOpActv
               do
               begin
                   data = 0;
                   <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
               end while(field_rd_data != data);

               //Read the Data
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMDR')%>.read(status,field_rd_data,.parent(this));

               if($test$plusargs("corr_mem_err_en")) begin
                 //Inject the tag Error 
                 mask = 1'b1 << $urandom_range(31, 0);
                 write_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));
               end

               if ($test$plusargs("uncorr_mem_err_en")) begin
                 mask1 = 1'b1 << $urandom_range(15, 0);
                 mask2 = 1'b1 << $urandom_range(31, 16);
                 mask = mask1 | mask2;
                 write_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));
               end

               `uvm_info("RUN_MAIN", $psprintf("RD_DATA:%0h and WR_DATA:%0h and Mask:%0h", 
                            field_rd_data,write_data,mask),UVM_MEDIUM);

               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMDR')%>.write(status,write_data,.parent(this));

               write_data = {9'h0,security,6'h0,12'h0,4'he};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));

               //Wait for MntOpActv
               do
               begin
                   data = 0;
                   <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
               end while(field_rd_data != data);

               <% if((obj.DutInfo.wAddr-obj.wCacheLineOffset) > 32) {%>
               //Program the ML0 Entry for Addr
               //TODO: This is correct as per the specs, RTL will be updated in Ncore 3.2
               write_data   = m_addr >> offset;

	      // write_data = m_addr - (m_addr %64);
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,write_data,.parent(this));
               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)

               //Program the ML1 Entry for Addr
               write_data   = m_addr >> offset;
               write_data   = write_data >> 'h20;
               write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR1.MntAddr')%>, write_data);

               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)
               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Found the Addr size to be greater than 32 Size:%0d",<%=obj.DutInfo.wAddr-obj.wCacheLineOffset%>), UVM_MEDIUM)
              <%}else{%>
               //Program the ML0 Entry for Addr
               write_data   = m_addr >> offset;
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,write_data,.parent(this));
               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)
              <%}%>

               //Program the MntOp Register with Opcode-6 to flush the entry
               write_data = {9'h0,security,6'h0,12'h0,4'h6};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));

               //Wait for MntOpActv
               do
               begin
                   data = 0;
                   <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
               end while(field_rd_data != data);
             end
     
           end
           <% } %>
           if ($test$plusargs("uncorr_mem_err_en")) begin
             poll_UUESR_ErrVld(1, poll_data);
           end
           if($test$plusargs("corr_mem_err_en")) begin
             poll_UCESR_ErrVld(1, poll_data);
           end
             
           if ($test$plusargs("uncorr_mem_err_en")) begin
             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
	     uvm_config_db#(int)::set(null,"*","ioaiu_data_user_err_type",read_data); //for coverage
             if ($test$plusargs("tag_error_test") || $test$plusargs("data_error_test")) begin
               compareValues("UUESR_ErrType","Valid Type", read_data, 1);
             end else if ($test$plusargs("ott_error_test")) begin
               compareValues("UUESR_ErrType","Valid Type", read_data, 0);
             end
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
            uvm_config_db#(int)::set(null,"*","ioaiu_data_user_err_info",read_data); //for coverage


             if ($test$plusargs("tag_error_test") || $test$plusargs("ott_error_test")) begin
               compareValues("UUESR_ErrInfo","Valid Type", read_data, 0);
             end
             if ($test$plusargs("data_error_test")) begin
               compareValues("UUESR_ErrInfo","Valid Type", read_data, 1);
             end
           end
           if ($test$plusargs("corr_mem_err_en")) begin
             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrType')%>, read_data);
             if ($test$plusargs("tag_error_test") || $test$plusargs("data_error_test")) begin
               compareValues("UUESR_ErrType","Valid Type", read_data, 1);
             end else if ($test$plusargs("ott_error_test")) begin
               compareValues("UUESR_ErrType","Valid Type", read_data, 0);
             end

             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrInfo')%>, read_data);
             if ($test$plusargs("tag_error_test") || $test$plusargs("ott_error_test")) begin
               compareValues("UUESR_ErrInfo","Valid Type", read_data, 0);
             end
             if ($test$plusargs("data_error_test")) begin
               compareValues("UUESR_ErrInfo","Valid Type", read_data, 1);
             end
           end
         
           if($test$plusargs("corr_mem_err_en")) begin
             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCELR0.ErrAddr')%>, read_data);
             errentry = read_data[19:0];
//             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCELR0.ErrWay')%>, read_data);
             errway = read_data[25:20];
//             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCELR0.ErrWord')%>, read_data);
             errword = read_data[31:26];
             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCELR1.ErrAddr')%>, read_data);
             erraddr = read_data;
             //#Check.IOAIU.CorrectableErr.ErrorLocation
             if ($test$plusargs("tag_error_test")) begin
               compareValues("XAIUCELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
               compareValues("XAIUCELR0.ErrWord", "should be", errword, err_injected_cache_word);
               compareValues("XAIUCELR0.ErrWay", "should be", errway, err_injected_cache_way);
               compareValues("XAIUCELR0.ErrEntry", "should be", errentry, err_injected_cache_entry);
             end
             if ($test$plusargs("data_error_test")) begin
               compareValues("XAIUCELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
               compareValues("XAIUCELR0.ErrWord", "should be", errword, err_injected_cache_word);
               compareValues("XAIUCELR0.ErrWay", "should be", errway, err_injected_cache_way);
               compareValues("XAIUCELR0.ErrEntry", "should be", errentry, err_injected_cache_entry);
             end
             if ($test$plusargs("ott_error_test")) begin
               //TODO: As per the discussion with Nabil, We do not have any michanism to get ErrEntry and ErrWord so currently checking for non-zero value only, Error injection tasks in memory module need improvement.
               compareValues("XAIUCELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
               compareValues("XAIUCELR0.ErrWord", "ErrWord must be zero", errword, 0); //Word MBZ
               compareValues("XAIUUELR0.ErrWay", "should be", errway, ott_way);
               //Removed ErrEntry check as per CONC-6585
               //if (errentry === 0) begin
               //  `uvm_error(get_full_name(), $sformatf("ErrEntry must not be zero, Received XAIUCELR0.ErrEntry = %0h", errentry))
               //end
             end
           end
           //#Check.IOAIU.UnCorrectableErr.ErrorLocation
           if($test$plusargs("uncorr_mem_err_en")) begin
             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrAddr')%>, read_data);
//           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrEntry')%>, read_data);
             errentry = read_data[19:0];
//           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWay')%>, read_data);
             errway = read_data[25:20];
//           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWord')%>, read_data);
             errword = read_data[19:0];
             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR1.ErrAddr')%>, read_data);
             erraddr = read_data;
             if ($test$plusargs("tag_error_test")) begin
               compareValues("XAIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
               compareValues("XAIUUELR0.ErrWord", "should be", errword, err_injected_cache_word);
               compareValues("XAIUUELR0.ErrWay", "should be", errway, err_injected_cache_way);
               compareValues("XAIUUELR0.ErrEntry", "should be", errentry, err_injected_cache_entry);
             end
             if ($test$plusargs("data_error_test")) begin
               compareValues("XAIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
               compareValues("XAIUUELR0.ErrWord", "should be", errword, err_injected_cache_word);
               compareValues("XAIUUELR0.ErrWay", "should be", errway, err_injected_cache_way);
               compareValues("XAIUUELR0.ErrEntry", "should be", errentry, err_injected_cache_entry);
             end
             if ($test$plusargs("ott_error_test")) begin
               //TODO: As per the discussion with Nabil, We do not have any michanism to get ErrEntry and ErrWord so currently checking for non-zero value only, Error injection tasks in memory module need improvement.
               compareValues("XAIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
               compareValues("XAIUUELR0.ErrWord", "ErrWord must be zero", errword, 0); //Word MBZ
               compareValues("XAIUUELR0.ErrWay", "should be", errway, ott_way);
               //Removed ErrEntry check as per CONC-6585
               //if (errentry === 0) begin
               //  `uvm_error(get_full_name(), $sformatf("ErrEntry must not be zero, Received XAIUUELR0.ErrEntry = %0h", errentry))
               //end
             end
           end
         
           if($test$plusargs("uncorr_mem_err_en")) begin
             write_data = 0;
             write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
           end
           if($test$plusargs("corr_mem_err_en")) begin
             write_data = 0;
             write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
           end
           // write  UUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, write_data);
           // Read the UCESR_ErrVld should be cleared
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
           compareValues("UCESR_ErrVld", "now clear", read_data, 0);
           // write  UUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
           // Read the UUESR_ErrVld should be cleared
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "now clear", read_data, 0);
        end else if ((tag_parity && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_parity && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (ott_parity && ($test$plusargs("ccp_single_bit_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_single_ott_direct_error_test")))) begin
           if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                                  .inst_name( "*" ),
                                                  .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                                  .value( ioaiu_scb ))) begin
             `uvm_error("ioaiu_csr_elr_seq", "ioaiu_scb model not found")
           end
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
           ev_<%=obj.multiPortCoreId%>.trigger();
           if ($test$plusargs("ott_error_test")) begin
             inject_error(.ott_no(ott_way)); 
           end
           <% if (obj.DutInfo.useCache){ %>
           if ($test$plusargs("data_error_test")) begin
             #500us;
             if(ioaiu_scb.m_ncbu_cache_q.size()==0) `uvm_error("ioaiu_csr_elr_seq", "no entry in cache to inject errors")
             if(ioaiu_scb.m_ncbu_cache_q.size()>0) begin
               //m_rand_index = $urandom_range(0, ioaiu_scb.m_ncbu_cache_q.size()-1);
               m_rand_index_dirty_state = ioaiu_scb.m_ncbu_cache_q.find_index with (item.state == UD);
               err_injected_cache_entry = ioaiu_scb.m_ncbu_cache_q[m_rand_index_dirty_state[0]].Index;
               err_injected_cache_way = ioaiu_scb.m_ncbu_cache_q[m_rand_index_dirty_state[0]].way;
               security = ioaiu_scb.m_ncbu_cache_q[m_rand_index_dirty_state[0]].security;
               m_addr   = ioaiu_scb.m_ncbu_cache_q[m_rand_index_dirty_state[0]].addr; 
               err_injected_cache_word = 0;
               `uvm_info("RUN_MAIN",$sformatf("configuring Sets :0x%0x,  way :0x%0x,  Word :0x%0x, security = 0x%0x, addr = 0x%0x",err_injected_cache_entry,err_injected_cache_way,err_injected_cache_word,security,m_addr), UVM_NONE)
               
               //Setup MntOp Read
               write_data = {err_injected_cache_word,err_injected_cache_way,err_injected_cache_entry};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,write_data,.parent(this));

               write_data = {9'h0,security,6'h1,12'h0,4'hc};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));

               //Wait for MntOpActv
               do
               begin
                   data = 0;
                   <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
               end while(field_rd_data != data);

               //Read the Data
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMDR')%>.read(status,field_rd_data,.parent(this));

               //Inject the tag Error 
               mask = 1'b1 << $urandom_range(31, 0);
               write_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));

               `uvm_info("RUN_MAIN", $psprintf("RD_DATA:%0h and WR_DATA:%0h and Mask:%0h", 
                            field_rd_data,write_data,mask),UVM_MEDIUM);

               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMDR')%>.write(status,write_data,.parent(this));

               write_data = {9'h0,security,6'h1,12'h0,4'he};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));

               //Wait for MntOpActv
               do
               begin
                   data = 0;
                   <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
               end while(field_rd_data != data);

               <% if((obj.DutInfo.wAddr-obj.wCacheLineOffset) > 32) {%>
               //Program the ML0 Entry for Addr
               //TODO: This is correct as per the specs, RTL will be updated in Ncore 3.2
               write_data   = m_addr >> offset;
	     //  write_data = m_addr - (m_addr %64);
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,write_data,.parent(this));
               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)

               //Program the ML1 Entry for Addr
               write_data   = m_addr  >> offset;
               write_data   = write_data >> 'h20;
               write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR1.MntAddr')%>, write_data);

               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)
               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Found the Addr size to be greater than 32 Size:%0d",<%=obj.DutInfo.wAddr-obj.wCacheLineOffset%>), UVM_MEDIUM)
              <%}else{%>
               //Program the ML0 Entry for Addr
               write_data   = m_addr >> offset;
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,write_data,.parent(this));
               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)
              <%}%>

               //Program the MntOp Register with Opcode-6 to flush the entry
               write_data = {9'h0,security,6'h0,12'h0,4'h6};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));

               //Wait for MntOpActv
               do
               begin
                   data = 0;
                   <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
               end while(field_rd_data != data);
             end
           end
           if ($test$plusargs("tag_error_test")) begin
             #500us;
             if(ioaiu_scb.m_ncbu_cache_q.size()==0) `uvm_error("ioaiu_csr_elr_seq", "no entry in cache to inject errors")
             if(ioaiu_scb.m_ncbu_cache_q.size()>0) begin
               m_rand_index = $urandom_range(0, ioaiu_scb.m_ncbu_cache_q.size()-1);
               err_injected_cache_entry = ioaiu_scb.m_ncbu_cache_q[m_rand_index].Index;
               err_injected_cache_way = ioaiu_scb.m_ncbu_cache_q[m_rand_index].way;
               security = ioaiu_scb.m_ncbu_cache_q[m_rand_index].security;
               m_addr   = ioaiu_scb.m_ncbu_cache_q[m_rand_index].addr; 
               err_injected_cache_word = 0;
               `uvm_info("RUN_MAIN",$sformatf("configuring Sets :0x%0x,  way :0x%0x,  Word :0x%0x, security = 0x%0x, addr = 0x%0x",err_injected_cache_entry,err_injected_cache_way,err_injected_cache_word,security,m_addr), UVM_MEDIUM)
               
               //Setup MntOp Read
               write_data = {err_injected_cache_word,err_injected_cache_way,err_injected_cache_entry};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,write_data,.parent(this));

               write_data = {9'h0,security,6'h0,12'h0,4'hc};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));

               //Wait for MntOpActv
               do
               begin
                   data = 0;
                   <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
               end while(field_rd_data != data);

               //Read the Data
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMDR')%>.read(status,field_rd_data,.parent(this));

               //Inject the tag Error 
               mask = 1'b1 << $urandom_range(31, 0);
               write_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));


               `uvm_info("RUN_MAIN", $psprintf("RD_DATA:%0h and WR_DATA:%0h and Mask:%0h", 
                            field_rd_data,write_data,mask),UVM_MEDIUM);

               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMDR')%>.write(status,write_data,.parent(this));

               write_data = {9'h0,security,6'h0,12'h0,4'he};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));

               //Wait for MntOpActv
               do
               begin
                   data = 0;
                   <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
               end while(field_rd_data != data);

               <% if((obj.DutInfo.wAddr-obj.wCacheLineOffset) > 32) {%>
               //Program the ML0 Entry for Addr
               //TODO: This is correct as per the specs, RTL will be updated in Ncore 3.2
      	       write_data = m_addr  >> offset;
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,write_data,.parent(this));
               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)

               //Program the ML1 Entry for Addr
               write_data   = m_addr >> offset;
               write_data   = write_data >> 'h20;
               write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR1.MntAddr')%>, write_data);

               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)
               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Found the Addr size to be greater than 32 Size:%0d",<%=obj.DutInfo.wAddr-obj.wCacheLineOffset%>), UVM_MEDIUM)
              <%}else{%>
               //Program the ML0 Entry for Addr
               write_data   = m_addr >> offset;
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,write_data,.parent(this));
               `uvm_info("ioaiu_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)
              <%}%>

               //Program the MntOp Register with Opcode-6 to flush the entry
               write_data = {9'h0,security,6'h0,12'h0,4'h6};
               <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,write_data,.parent(this));

               //Wait for MntOpActv
               do
               begin
                   data = 0;
                   <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR')%>.read(status,field_rd_data,.parent(this));
               end while(field_rd_data != data);
             end
           end
           <% } %>
           poll_UUESR_ErrVld(1, poll_data);
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
	   uvm_config_db#(int)::set(null,"*","ioaiu_data_user_err_type",read_data); //for coverage
           if ($test$plusargs("tag_error_test") || $test$plusargs("data_error_test")) begin
             compareValues("UUESR_ErrType","Valid Type", read_data, 1);
           end else if ($test$plusargs("ott_error_test")) begin
             compareValues("UUESR_ErrType","Valid Type", read_data, 0);
           end

           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
           uvm_config_db#(int)::set(null,"*","ioaiu_data_user_err_info",read_data); //for coverage
           if ($test$plusargs("tag_error_test") || $test$plusargs("ott_error_test")) begin
             compareValues("UUESR_ErrInfo","Valid Type", read_data, 0);
           end
           if ($test$plusargs("data_error_test")) begin
             compareValues("UUESR_ErrInfo","Valid Type", read_data, 1);
           end
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrAddr')%>, read_data);
//         read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrEntry')%>, read_data);
           errentry = read_data[19:0];
//         read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWay')%>, read_data);
           errway = read_data[25:20];
//         read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR0.ErrWord')%>, read_data);
           errword = read_data[31:26];
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUELR1.ErrAddr')%>, read_data);
           erraddr = read_data;
           if ($test$plusargs("tag_error_test")) begin
             compareValues("XAIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
             compareValues("XAIUUELR0.ErrWord", "should be", errword, err_injected_cache_word);
             compareValues("XAIUUELR0.ErrWay", "should be", errway, err_injected_cache_way);
             compareValues("XAIUUELR0.ErrEntry", "should be", errentry, err_injected_cache_entry);
           end
           if ($test$plusargs("data_error_test")) begin
             compareValues("XAIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
             compareValues("XAIUUELR0.ErrWord", "should be", errword, err_injected_cache_word);
             compareValues("XAIUUELR0.ErrWay", "should be", errway, err_injected_cache_way);
             compareValues("XAIUUELR0.ErrEntry", "should be", errentry, err_injected_cache_entry);
           end
           if ($test$plusargs("ott_error_test")) begin
             //TODO: As per the discussion with Nabil, We do not have any michanism to get ErrEntry and ErrWord so currently checking for non-zero value only, Error injection tasks in memory module need improvement.
             compareValues("XAIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
             compareValues("XAIUUELR0.ErrWord", "ErrWord must be zero", errword, 0); //Word MBZ
             compareValues("XAIUUELR0.ErrWay", "should be", errway, ott_way);
             //Removed ErrEntry check as per CONC-6585
             //if (errentry === 0) begin
             //  `uvm_error(get_full_name(), $sformatf("ErrEntry must not be zero, Received XAIUUELR0.ErrEntry = %0h", errentry))
             //end
           end
           write_data = 0;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.MemErrDetEn')%>, write_data); 
           // write  UUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
           // Read the UUESR_ErrVld should be cleared
           read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data);
           compareValues("UUESR_ErrVld", "now clear", read_data, 0);
        end else begin
           ev_<%=obj.multiPortCoreId%>.trigger();
        end
<% } else { %>
           ev_<%=obj.multiPortCoreId%>.trigger();
<% } %>
  endtask // body
   
endclass : ioaiu_csr_elr_seq_<%=obj.multiPortCoreId%>

<%if(obj.DutInfo.useCache) { %>
//-----------------------------------------------------------------------
//  Class : ioaiu_csr_flush_all_seq
//  Purpose : To flush all entries
//-----------------------------------------------------------------------
//#Check.IOAIU.MaintOp.FlushAllEntries
class ioaiu_csr_flush_all_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_flush_all_seq_<%=obj.multiPortCoreId%>)

    ioaiu_scoreboard ioaiu_scb;
    uvm_reg_data_t poll_data;
    bit disable_check = 0;
    string spkt;
    <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
            ioaiu_coverage                          cov;
        `endif
    <%}%>

    function new(string name="");
        super.new(name);
        cov = new();
    endfunction

    task body();
    	`uvm_info(get_full_name(), "Entered body...", UVM_NONE)
		
	   	if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                                  .inst_name( "*" ),
                                                  .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                                  .value( ioaiu_scb ))) begin
             `uvm_error(get_full_name(), "ioaiu_scb not found")
    	end

	if(ioaiu_scb.m_ncbu_cache_q.size() == 0 && !disable_check)
            `uvm_error(get_full_name(),$sformatf("IO Cache empty, nothing to flush"))
       	else 
            `uvm_info(get_full_name(),$sformatf("IO Cache:%0d entries to flush", ioaiu_scb.m_ncbu_cache_q.size()), UVM_LOW)

        //Poll the MntOp Active Bit
        do begin
	    	#<%=obj.Clocks[0].params.period%>ps;
            data = 0;
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR.MntOpActv')%>, field_rd_data);
        end while(field_rd_data != data);
        `uvm_info(get_full_name(),$sformatf("Step1:MntOpActv is 0"), UVM_NONE)

        `uvm_info(get_full_name(),$sformatf("Step2:Attempt to Write 4 to PCMCR"), UVM_NONE)
          
        wr_data   = 'h4;
        <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status, wr_data, .parent(this));
        `uvm_info(get_full_name(),$sformatf("Step3:Done Write 4 to PCMCR"), UVM_NONE)
        <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
	  cov.collect_mnt_opcode(wr_data);
        `endif
        <%}%>


        poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR.MntOpActv')%>,1,poll_data);
        `uvm_info(get_full_name(),$sformatf("Step4:PCMAR.MntOpActv asserted"), UVM_NONE)
          
        //Poll the MntOp Active Bit
        do begin
	    	#<%=obj.Clocks[0].params.period%>ps;
            data = 0;
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR.MntOpActv')%>, field_rd_data);
        end while(field_rd_data != data);
        `uvm_info(get_full_name(),$sformatf("Step5:PCMAR.MntOpActv deasserted"), UVM_NONE)

		if(ioaiu_scb.m_ncbu_cache_q.size() != 0)
		`uvm_error(get_full_name(),$sformatf("IO Cache not empty %0d entries left, at end of MaintOp=FLUSH_ALL sequence", ioaiu_scb.m_ncbu_cache_q.size()))

       	`uvm_info(get_full_name(), "Exiting body...", UVM_NONE)
    endtask
endclass : ioaiu_csr_flush_all_seq_<%=obj.multiPortCoreId%>
//-----------------------------------------------------------------------
//  Class : ioaiu_csr_flush_by_index_way_seq
//  Purpose : To flush cache entries using index and way range
//-----------------------------------------------------------------------
//#Check.IOAIU.MaintOp.FlushByIndexWay
class ioaiu_csr_flush_by_index_way_seq_<%=obj.multiPortCoreId%> extends ral_csr_base_seq; 
  `uvm_object_utils(ioaiu_csr_flush_by_index_way_seq_<%=obj.multiPortCoreId%>)

    ioaiu_scoreboard ioaiu_scb;
    int unsigned m_rand_index;

    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    rand bit [5:0]  m_nWord;
    int k_num_flush_cmd=100;
    string spkt;

   <% if (obj.DutInfo.useCache){ %>
    constraint c_nSets  { m_nSets >= 0; m_nSets < <%=nSetsPerCore%>;}
    constraint c_nWays  { m_nWays >= 0; m_nWays < <%=obj.DutInfo.ccpParams.nWays%>;}  
   <%}%>
   <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
            ioaiu_coverage                          cov;
        `endif
    <%}%>
    function new(string name="");
        super.new(name);
        cov = new();
    endfunction

    task body();
       `uvm_info("body", "Entered...", UVM_MEDIUM)
       repeat(k_num_flush_cmd) begin
          #100ns;
          if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                                  .inst_name( "*" ),
                                                  .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                                  .value( ioaiu_scb ))) begin
             `uvm_error("ioaiu_csr_flush_by_index_way_seq", "ioaiu_scb model not found")
          end

          assert(randomize(m_nSets))
          assert(randomize(m_nWays))

          <% if (obj.DutInfo.useCache){ %>
          if(ioaiu_scb.m_ncbu_cache_q.size()>0) begin
              m_rand_index = $urandom_range(0, ioaiu_scb.m_ncbu_cache_q.size()-1);
              `uvm_info("ioaiu_csr_flush_by_index_way_seq",$sformatf("index %d cache model q size %d",m_rand_index,
                                                                   ioaiu_scb.m_ncbu_cache_q.size()), UVM_MEDIUM)
              m_nSets = ioaiu_scb.m_ncbu_cache_q[m_rand_index].Index; 
              m_nWays = ioaiu_scb.m_ncbu_cache_q[m_rand_index].way; 
          end 
          <%}%>

          `uvm_info("ioaiu_csr_flush_by_index_way_seq",$sformatf("configuring m_nSets :%x,  m_nWays :%x ",m_nSets,m_nWays), UVM_NONE)

          //Poll the MntOp Active Bit
          do begin
	     #20ns
             field_rd_data = 0;
             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR.MntOpActv')%>, field_rd_data);
	     uvm_report_info("DCDEBUG",$sformatf("field_rd_data:%0d",field_rd_data),UVM_MEDIUM);
          end while(field_rd_data != 0);

          wr_data = m_nSets;
          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0.MntSet')%>, wr_data);
          wr_data = m_nWays;
          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0.MntWay')%>, wr_data);

          // ************************************************************************************
          //  Initiate and complete a Flush by set-way operation (Proxy Cache Maintenance Control 
          //  Register and Proxy Cache Maintenance Activity Register).
          //  a. the "UPCMCR.ArrayId" field is 0. This will flush the tag array
          // ************************************************************************************
          wr_data   = 'h5;
          <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status, wr_data, .parent(this));
        <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
	  cov.collect_mnt_opcode(wr_data);
        `endif
        <%}%>

          //Poll the MntOp Active Bit
	  #100ns
          do begin
	     #20ns
             field_rd_data = 0;
             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR.MntOpActv')%>, field_rd_data);
	     uvm_report_info("DCDEBUG",$sformatf("field_rd_data:%0d",field_rd_data),UVM_MEDIUM);
          end while(field_rd_data != 0);
       end

       `uvm_info("body", "Exiting...", UVM_NONE)
    endtask
endclass : ioaiu_csr_flush_by_index_way_seq_<%=obj.multiPortCoreId%>

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Flushes cachelines using address
//-----------------------------------------------------------------------
//#Check.IOAIU.MaintOp.FlushByAddr
class ioaiu_csr_flush_by_addr_seq_<%=obj.multiPortCoreId%> extends ral_csr_base_seq;
	`uvm_object_utils(ioaiu_csr_flush_by_addr_seq_<%=obj.multiPortCoreId%>)

  	ioaiu_scoreboard ioaiu_scb;
  	int unsigned m_rand_index;
  	bit m_security;
  	smi_addr_t  m_addr; 
  	int offset = <%=obj.wCacheLineOffset%>;
  	int k_num_flush_cmd=100;
  	addr_trans_mgr m_addr_mgr = addr_trans_mgr::get_instance();
         <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
            ioaiu_coverage                          cov;
        `endif
        <%}%>
  	
  	function new(string name="ioaiu_csr_flush_by_addr_seq");
    	super.new(name);
        cov = new();
  	endfunction

  	task body();
		`uvm_info("body", "Entered...", UVM_NONE)
      	repeat(k_num_flush_cmd) begin
        	#(100ns);
          	if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                                  .inst_name( "*" ),
                                                  .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                                  .value( ioaiu_scb ))) begin
             	`uvm_error("ioaiu_csr_flush_by_addr_seq", "ioaiu_scb model not found")
          	end

          	<% if (obj.DutInfo.useCache){ %>
      	 		`uvm_info("ioaiu_csr_flush_by_addr_seq",$sformatf("Start waiting for cache to be filled up"),UVM_MEDIUM)

          		if( ioaiu_scb.m_ncbu_cache_q.size()>0) begin
            		m_rand_index = $urandom_range(0, ioaiu_scb.m_ncbu_cache_q.size()-1);
              		`uvm_info("ioaiu_csr_flush_by_addr_seq",$sformatf("index %d cache model q size %d", m_rand_index, ioaiu_scb.m_ncbu_cache_q.size()), UVM_MEDIUM)
              		m_addr   = ioaiu_scb.m_ncbu_cache_q[m_rand_index].addr; 
              		m_security = ioaiu_scb.m_ncbu_cache_q[m_rand_index].security; 
              		`uvm_info("ioaiu_csr_flush_by_addr_seq",$sformatf("Hurray Got Addr :%x from IO cache model",m_addr), UVM_MEDIUM)
          		end 
          	<%}%>
	  
          	//Poll the MntOp Active Bit until it Reads 0
          	do begin
          		data = 0;
             	read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR.MntOpActv')%>, field_rd_data);
          	end while(field_rd_data != data);
	  
          	`uvm_info("ioaiu_csr_flush_by_addr_seq",$sformatf("Flushing Addr :%x from IO cache model",m_addr), UVM_MEDIUM)
         	
         	<% if((obj.DutInfo.wAddr-obj.wCacheLineOffset) > 32) {%>

          		//Program the ML0 Entry for Addr
	          	wr_data   = m_addr >> offset;
          		<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,wr_data,.parent(this));
          		`uvm_info("ioaiu_csr_flush_by_addr_seq",$sformatf("Sending Addr :%x from IO cache model",wr_data), UVM_MEDIUM)

          		//Program the ML1 Entry for Addr
		        wr_data   = m_addr >> offset;
          		wr_data   = wr_data >> 'h20;
          		write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR1.MntAddr')%>, wr_data);
          		`uvm_info("ioaiu_csr_flush_by_addr_seq",$sformatf("Sending Addr :%x from IO cache model",wr_data), UVM_MEDIUM)
          		`uvm_info("ioaiu_csr_flush_by_addr_seq",$sformatf("Found the Addr size to be greater than 32 Size:%0d",<%=obj.DutInfo.wAddr-obj.wCacheLineOffset%>), UVM_MEDIUM)
         	<%}else{%>
          		
          		//Program the ML0 Entry for Addr
          		wr_data   = m_addr >> offset;
          		<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,wr_data,.parent(this));
          		`uvm_info("ioaiu_csr_flush_by_addr_seq",$sformatf("Sending Addr :%x from IO cache model",wr_data), UVM_MEDIUM)

         	<%}%>

          	//Program the MntOp Register with Opcode-6
          	wr_data   = {9'h0,m_security,22'h6};
          	<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,wr_data, .parent(this));
        <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
	  cov.collect_mnt_opcode(wr_data);
        `endif
        <%}%>

          	//Poll the MntOp Active Bit until it reads 0
          	do begin
            	data = 0;
             	read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR.MntOpActv')%>, field_rd_data);
          	end while(field_rd_data != data);

      end
      `uvm_info("body", "Exiting...", UVM_NONE)
  endtask      
endclass : ioaiu_csr_flush_by_addr_seq_<%=obj.multiPortCoreId%> 

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Flushes cachelines using address range
//-----------------------------------------------------------------------
//#Check.IOAIU.MaintOp.FlushByAddrRange
class ioaiu_csr_flush_by_addr_range_seq_<%=obj.multiPortCoreId%> extends ral_csr_base_seq;
  `uvm_object_utils(ioaiu_csr_flush_by_addr_range_seq_<%=obj.multiPortCoreId%>)

  ioaiu_scoreboard ioaiu_scb;
  int unsigned m_rand_index;
  bit security;
  smi_addr_t  m_addr; 
  bit [63:0]  mem_end_addr; 
  int offset = <%=obj.wCacheLineOffset%>;
  int k_num_flush_cmd=10;
  addr_trans_mgr m_addr_mgr = addr_trans_mgr::get_instance();
  <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
            ioaiu_coverage                          cov;
        `endif
    <%}%>

  function new(string name="ioaiu_csr_flush_by_addr_range_seq");
      super.new(name);
      cov = new();
  endfunction

  task body();
      `uvm_info("body", "Entered...", UVM_NONE)
      repeat(k_num_flush_cmd) begin
          #(30000ns);
          if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                                  .inst_name( "*" ),
                                                  .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                                  .value( ioaiu_scb ))) begin
             `uvm_error("ioaiu_csr_flush_by_addr_range_seq", "ioaiu_scb model not found")
          end
//	  `uvm_error("DCDEBUG","fail 2nd")
//          m_addr   = $urandom();
          m_addr   = m_addr_mgr.get_coh_addr(<%=obj.DutInfo.FUnitId%>, 1);
          security = $urandom();
          <% if(obj.DutInfo.useCache) { %>
					
          if( ioaiu_scb.m_ncbu_cache_q.size()>0) begin
              m_rand_index = $urandom_range(0, ioaiu_scb.m_ncbu_cache_q.size()-1);
              `uvm_info("ioaiu_csr_flush_by_addr_range_seq",$sformatf("index %d cache model q size %d",m_rand_index,
                                             ioaiu_scb.m_ncbu_cache_q.size()), UVM_NONE)
              m_addr   = ioaiu_scb.m_ncbu_cache_q[m_rand_index].addr; 
              security = ioaiu_scb.m_ncbu_cache_q[m_rand_index].security; 
              `uvm_info("ioaiu_csr_flush_by_addr_range_seq",$sformatf("Hurray Got Addr :%x Security :%x from IO cache model",m_addr,security), UVM_NONE)
	      ioaiu_scb.m_ncbu_cache_q[m_rand_index].print(); //DCDEBUG
          end 
          <%}%>
	  m_addr = m_addr - (m_addr %64);
          //Poll the MntOp Active Bit
          do begin
	     #20ns
             data = 0;
             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR.MntOpActv')%>, field_rd_data);
          end while(field_rd_data != data);

         <% if((obj.DutInfo.wAddr-obj.wCacheLineOffset) > 32) {%>
          //Program the ML0 Entry for Addr
//          wr_data   = m_addr >> offset;
//          wr_data   = m_addr >> offset;
          wr_data = m_addr;						       
          <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,wr_data,.parent(this));
          `uvm_info("ioaiu_csr_flush_by_addr_range_seq",$sformatf("MCMLR00 Sending Addr :%x from IO cache model",wr_data), UVM_NONE)

          //Program the ML1 Entry for Addr
//          wr_data   = m_addr >> offset;
//          wr_data   = wr_data >> 'h20;
          wr_data   = m_addr >> 'h20;
          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR1.MntAddr')%>, wr_data);
          `uvm_info("ioaiu_csr_flush_by_addr_range_seq",$sformatf("MCMLR10 Sending Addr :%x from IO cache model",wr_data), UVM_NONE)
          `uvm_info("ioaiu_csr_flush_by_addr_range_seq",$sformatf("Found the Addr size to be greater than 32 Size:%0d",<%=obj.DutInfo.wAddr-obj.wCacheLineOffset%>), UVM_NONE)
         <%}else{%>
          //Program the ML0 Entry for Addr
  //        wr_data   = m_addr >> offset;
           wr_data   = m_addr; 
          <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0')%>.write(status,wr_data,.parent(this));
          `uvm_info("ioaiu_csr_flush_by_addr_range_seq",$sformatf("Sending Addr :%x from IO cache model",wr_data), UVM_NONE)
         <%}%>

          do begin
            randcase
                40: wr_data = $urandom_range(1,<%=obj.DutInfo.ccpParams.nWays%> *<%=nSetsPerCore/2%>);
                60: wr_data = $urandom_range(<%=obj.DutInfo.ccpParams.nWays%> *<%=nSetsPerCore/2%>,<%=obj.DutInfo.ccpParams.nWays%> *<%=nSetsPerCore%>); 
            endcase
            foreach(addrMgrConst::memregion_boundaries[i]) begin
              if (m_addr inside {[addrMgrConst::memregion_boundaries[i].start_addr:addrMgrConst::memregion_boundaries[i].end_addr]}) begin
                mem_end_addr = addrMgrConst::memregion_boundaries[i].end_addr;
                break;
              end 
            end
          end while (!((m_addr + (wr_data*(2**<%=obj.DutInfo.ccpParams.wCacheLineOffset%>))) < mem_end_addr));
          `uvm_info("ioaiu_csr_flush_by_addr_range_seq",$sformatf("MCMLR10 Sending MntRange :%x from IO cache model and last evict addr: 0x%0x",wr_data,(m_addr + wr_data)), UVM_NONE)
          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR1.MntRange')%>, wr_data);

          //Program the MntOp Register with Opcode-7
          wr_data   = {9'h0,security,22'h7};
          `uvm_info("ioaiu_csr_flush_by_addr_range_seq",$sformatf("UPCMCR Sending Security :%x OpCode from IO cache model",security,'h7), UVM_NONE)
          <%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR')%>.write(status,wr_data, .parent(this));
        <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
	  cov.collect_mnt_opcode(wr_data);
        `endif
        <%}%>

	  #100ns          
          //Poll the MntOp Active Bit
          do begin
	     #20ns
             data = 0;
             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR.MntOpActv')%>, field_rd_data);
          end while(field_rd_data != data);
      end
      `uvm_info("body", "Exiting...", UVM_NONE)
  endtask      
endclass : ioaiu_csr_flush_by_addr_range_seq_<%=obj.multiPortCoreId%> 



//-----------------------------------------------------------------------
//  Class : ioaiu_csr_flush_by_index_way_range_seq
//  Purpose : To flush cache entries using index and way
//-----------------------------------------------------------------------
//#Check.IOAIU.MaintOp.FlushByIndexWayRange
class ioaiu_csr_flush_by_index_way_range_seq_<%=obj.multiPortCoreId%> extends ral_csr_base_seq; 
  `uvm_object_utils(ioaiu_csr_flush_by_index_way_range_seq_<%=obj.multiPortCoreId%>)

    ioaiu_scoreboard ioaiu_scb;
    int unsigned m_rand_index;

    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    rand bit [5:0]  m_nWord;
    int k_num_flush_cmd=1;
    string spkt;

   <% if (obj.DutInfo.useCache){ %>
    constraint c_nSets  { m_nSets >= 0; m_nSets < <%=nSetsPerCore%>;}
    constraint c_nWays  { m_nWays >= 0; m_nWays < <%=obj.DutInfo.ccpParams.nWays%>;}  
   <%}%>
    <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
            ioaiu_coverage                          cov;
        `endif
    <%}%>


    function new(string name="");
        super.new(name);
        cov = new();
    endfunction

    task body();
       `uvm_info("body", "Entered...", UVM_MEDIUM)
       repeat(k_num_flush_cmd) begin
          #100ns;
          if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                                  .inst_name( "*" ),
                                                  .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                                  .value( ioaiu_scb ))) begin
             `uvm_error("ioaiu_csr_flush_by_index_way_range_seq", "ioaiu_scb model not found")
          end

          assert(randomize(m_nSets))
          assert(randomize(m_nWays))

          <% if (obj.DutInfo.useCache){ %>
          if(ioaiu_scb.m_ncbu_cache_q.size()>0) begin
              m_rand_index = $urandom_range(0, ioaiu_scb.m_ncbu_cache_q.size()-1);
              `uvm_info("ioaiu_csr_flush_by_index_way_range_seq",$sformatf("index %d cache model q size %d",m_rand_index,
                                                                   ioaiu_scb.m_ncbu_cache_q.size()), UVM_NONE)
              m_nSets = ioaiu_scb.m_ncbu_cache_q[m_rand_index].Index; 
              m_nWays = ioaiu_scb.m_ncbu_cache_q[m_rand_index].way; 
          end 
          <%}%>



          //Poll the MntOp Active Bit
          do begin
	     #20ns;
             data = 0;
             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR.MntOpActv')%>, field_rd_data);
          end while(field_rd_data != data);

          wr_data = m_nSets;
          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0.MntSet')%>, wr_data);
          //wr_data = m_nWays;
          wr_data = 0; // CONC-7148, As Range will be multiple of number of Ways, the ways will be set to 0, to flush whole index/set
          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0.MntWay')%>, wr_data);

          wr_data = <%=obj.DutInfo.ccpParams.nWays%> * ($urandom_range(1,<%=nSetsPerCore%>)); // CONC-7148, Range set to multiple of number of ways
                                                                                                                                                      // CONC-11032 - Sets need to be divided per core 
          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR1.MntRange')%>, wr_data);
          `uvm_info("ioaiu_csr_flush_by_index_way_range_seq",$sformatf("Setting regs for MntSet=%x, MntRange=%x",m_nSets, wr_data), UVM_MEDIUM)

//          `uvm_info("ioaiu_csr_flush_by_index_way_range_seq",$sformatf("configuring m_nSets :%x,  m_nWays :%x range:%0d",m_nSets,m_nWays,wr_data), UVM_MEDIUM)
          // ************************************************************************************
          //  Initiate and complete a Flush by set-way range operation (Proxy Cache Maintenance Control 
          //  Register and Proxy Cache Maintenance Activity Register).
          //  a. the "UPCMCR.ArrayId" field is 0. This will flush the tag array
          // ************************************************************************************
          wr_data   = 'h8;
          write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR.MntOp')%>, wr_data);
        <%if(obj.COVER_ON) { %>
        `ifndef FSYS_COVER_ON
	  cov.collect_mnt_opcode(wr_data);
        `endif
        <%}%>
	  #100ns
	    
          //Poll the MntOp Active Bit
          do begin
	     #20ns;
             data = 0;
             read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR.MntOpActv')%>, field_rd_data);
          end while(field_rd_data != data);
       end

       `uvm_info("body", "Exiting...", UVM_NONE)
    endtask
endclass : ioaiu_csr_flush_by_index_way_range_seq_<%=obj.multiPortCoreId%>


//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Flushes complete cache
//-----------------------------------------------------------------------
class ioaiu_ccp_offline_seq_<%=obj.multiPortCoreId%> extends ral_csr_base_seq;
  `uvm_object_utils(ioaiu_ccp_offline_seq_<%=obj.multiPortCoreId%>)

    function new(string name="ioaiu_ccp_offline_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info("body", "Entered...", UVM_MEDIUM)
        #100us;
        uvm_report_info("ioaiu_ccp_offline_seq",$sformatf("setting fill en to 0"),UVM_NONE);
        // ************************************************************************************
        //  Clear the Proxy Cache Fill Enable bit (Proxy Cache Transaction Control Register)
        // ************************************************************************************
        wr_data = 0;

        // ************************************************************************************
        //  Poll the Proxy Cache Fill Active bit (Proxy Cache Transaction Activity Register) 
        //  until clear
        // ************************************************************************************
        do begin
           data = 0;

        end while(field_rd_data != data);

        // Wait for MntOpActv to go low
        do begin
            data = 0;
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR.MntOpActv')%>, field_rd_data);
        end while(field_rd_data != data);

        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMLR0.MntWay')%>, 0);

        // ************************************************************************************
        //  Initiate and complete a Full cache flush operation (Proxy Cache Maintenance Control 
        //  Register and Proxy Cache Maintenance Activity Register).
        //  a. the "UPCMCR.ArrayId" field is 0. This will flush the tag array
        // ************************************************************************************
        wr_data   = 'h4;
        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMCR.MntOp')%>, wr_data);

        // Wait for MntOpActv to go low
        do begin
            read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUPCMAR.MntOpActv')%>, field_rd_data);
        end while(field_rd_data);

        // ************************************************************************************
        //  Poll the Proxy Cache Evict Active bit (Proxy Cache Transaction Activity Register) 
        //  until clear
        // ************************************************************************************
        do begin
           data = 0;
        end while(field_rd_data != data);

        // ************************************************************************************
        //  Clear the Proxy Cache Lookup Enable bit (Proxy Cache Transaction Control Register)
        //  the main phase of the Master agent's dataflow Sequencer
        // ************************************************************************************
        wr_data = 0;

        `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask: body
endclass : ioaiu_ccp_offline_seq_<%=obj.multiPortCoreId%> 

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Flushes cachelines via different types of flushes selected randomly
//-----------------------------------------------------------------------
//#Check.IOAIU.MaintOp.FlushAllType
class ioaiu_csr_run_all_type_flush_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
  `uvm_object_utils(ioaiu_csr_run_all_type_flush_seq_<%=obj.multiPortCoreId%>)

  rand bit [19:0] m_nSets;
  rand bit [5:0]  m_nWays;

  bit [3:0]  mntop_cmd[5] = {5,6,7,8,4};

  apb_sequencer   m_apb_sequencer;

  //constraint c_mntop_cmd { mntop_cmd inside {4,5,6,7,8};}

  <% if (obj.DutInfo.useCache){ %>
  constraint c_nSets  { m_nSets >= 0; m_nSets < <%=nSetsPerCore%>;}
  constraint c_nWays  { m_nWays >= 0; m_nWays < <%=obj.DutInfo.ccpParams.nWays%>;}  
  <%}%>

  function new(string name="");
      super.new(name);
  endfunction

  task body();
    `uvm_info("body", "Entered...", UVM_MEDIUM)

    get_mp_env_handle();
     get_m_env_cfg_handle();
    if (!uvm_config_db#(ioaiu_scoreboard)::get(.cntxt( null ),
                                                .inst_name( "*" ),
                                                .field_name( "ioaiu_scb_<%=obj.multiPortCoreId%>" ),
                                                .value( mp_env.m_env[<%=obj.multiPortCoreId%>].m_scb ))) begin
        `uvm_error("ioaiu_csr_run_all_type_flush_seq", "ioaiu_scb_<%=obj.multiPortCoreId%> model not found")
    end
    //repeat(20) begin
    for (int i=0; i< $size(mntop_cmd); i++) begin
      //assert(randomize(mntop_cmd));
      //$display("KDBMKC ioaiu_scb_<%=obj.multiPortCoreId%>.m_ncbu_cache_q.size()=%0d", mp_env.m_env[<%=obj.multiPortCoreId%>].m_scb.m_ncbu_cache_q.size());
      if (mp_env.m_env[<%=obj.multiPortCoreId%>].m_scb.m_ncbu_cache_q.size()>0) begin
        uvm_report_info("run_all_flush_seq",$sformatf("mntop_cmd %d",mntop_cmd[i]),UVM_NONE);
        //If Flush By Index 
        if(mntop_cmd[i] == 'h5) begin
            ioaiu_csr_flush_by_index_way_seq_<%=obj.multiPortCoreId%> csr_seq = ioaiu_csr_flush_by_index_way_seq_<%=obj.multiPortCoreId%>::type_id::create("csr_seq");
            csr_seq.model = this.model; 
            csr_seq.k_num_flush_cmd = $urandom_range(1,3); 
            csr_seq.start(m_apb_sequencer);
        //Else if Flush by Addr
        end else if(mntop_cmd[i] == 'h6) begin
            ioaiu_csr_flush_by_addr_seq_<%=obj.multiPortCoreId%> csr_seq = ioaiu_csr_flush_by_addr_seq_<%=obj.multiPortCoreId%>::type_id::create("csr_seq");
            csr_seq.model = this.model; 
            csr_seq.k_num_flush_cmd = $urandom_range(1,3); 
            csr_seq.start(m_apb_sequencer);
        //Else if Flush by Addr Range
        end else if(mntop_cmd[i] == 'h7) begin
            ioaiu_csr_flush_by_addr_range_seq_<%=obj.multiPortCoreId%> csr_seq = ioaiu_csr_flush_by_addr_range_seq_<%=obj.multiPortCoreId%>::type_id::create("csr_seq");
            csr_seq.model = this.model; 
            csr_seq.k_num_flush_cmd = $urandom_range(1,3); 
            csr_seq.start(m_apb_sequencer);
        //Else if Flush by Set-Way Range
        end else if(mntop_cmd[i] == 'h8) begin
            ioaiu_csr_flush_by_index_way_range_seq_<%=obj.multiPortCoreId%> csr_seq = ioaiu_csr_flush_by_index_way_range_seq_<%=obj.multiPortCoreId%>::type_id::create("csr_seq");
            csr_seq.model = this.model;
            csr_seq.k_num_flush_cmd = $urandom_range(1,3);
            csr_seq.start(m_apb_sequencer);
        //Else flush all
        end else begin
            ioaiu_ccp_offline_seq_<%=obj.multiPortCoreId%> csr_seq = ioaiu_ccp_offline_seq_<%=obj.multiPortCoreId%>::type_id::create("csr_seq");
            csr_seq.model = this.model; 
            csr_seq.start(m_apb_sequencer);
        end
      end else begin
        `uvm_warning("IOAIU CSR MntOp Seq Error", $psprintf("The mp_env.m_env[<%=obj.multiPortCoreId%>].m_scb.ncbu_cache_q is empty. Either run more txns or debug further"))
	break;
      end
    end
    `uvm_info("body", "Exiting...", UVM_MEDIUM)
  endtask
endclass : ioaiu_csr_run_all_type_flush_seq_<%=obj.multiPortCoreId%>
<% } %> //end of if obj.useCache

class res_corr_err_threshold_seq_<%=obj.multiPortCoreId%> extends ral_csr_base_seq; 
   `uvm_object_utils(res_corr_err_threshold_seq_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t write_data, read_data;
    uvm_status_e   status;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      <% if(obj.useResiliency) { %>
      if(!$value$plusargs("res_corr_err_threshold=%0d", write_data)) begin
        write_data = $urandom_range(5,50);
      end
      `uvm_info(get_name(), $sformatf("Writing XAIUCRTR res_corr_err_threshold = %0d", write_data), UVM_NONE)
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCRTR.ResThreshold')%>, write_data); 
      <% } %>
    endtask
endclass : res_corr_err_threshold_seq_<%=obj.multiPortCoreId%>

class pcie_prod_cons_prog_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;
   `uvm_object_utils(pcie_prod_cons_prog_<%=obj.multiPortCoreId%>)
   function new(string name="");
      super.new(name);
   endfunction // new



   task body();
   addrMgrConst::sys_addr_csr_t csrq[$];
   gpra_order_t        gpra_order;      
   csrq = addrMgrConst::get_all_gpra();
   foreach(csrq[i]) begin
      if(csrq[i].unit == addrMgrConst::DII)
	csrq[i].order = 'b11001;
      else
	csrq[i].order = 'b10001;
          `uvm_info(get_name(),
              $psprintf("program unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d order:%0b",
                  csrq[i].unit.name(), csrq[i].mig_nunitid,
                  csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size,csrq[i].order),
              UVM_NONE)
      gpra_order = csrq[i].order;
      <% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
         if(i == <%=i%>) begin
             write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.ReadID')%>, gpra_order.readID);
             write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.WriteID')%>, gpra_order.writeID);
             write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUGPRAR'+i+'.Policy')%>, gpra_order.policy);
	 end					      
      <% } %>
   end
      
   endtask // body
   
endclass // pcie_prod_cons_prog_<%=obj.multiPortCoreId%>

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* This sequence programs the required registers for Sys Req events 
* verification
*     - This will program the timeouts and enable-disable csrs 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
class ioaiu_csr_sysreq_event_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>; 
   `uvm_object_utils(ioaiu_csr_sysreq_event_seq_<%=obj.multiPortCoreId%>)
    uvm_reg_data_t write_data, septocr_timeout_threshold, ehtocr_timeout_threshold;
    uvm_reg_data_t poll_data;
    uvm_reg_data_t read_data, read_data1, read_data2;

    rand int ev_disable_clock_cycles;  // introduce this delay while enabling and disabling events
    int ev_enable_toggle_count;
    bit ev_enable=1;
    bit err_det_en;
    int        errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;
    bit [19:0]  errinfo;
    bit [51:0]  exp_addr;
    bit errinfo_check, erraddr_check;
    bit [51:0] actual_addr;
    bit [19:0] err_entry;
    bit [5:0] err_way;
    bit [5:0] err_word;
    bit [19:0] err_addr;
    int k_num_event_msg;

    constraint c_ev_disable_clock_cycles{
      ev_disable_clock_cycles inside {[1:5000]};
    }

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        bit dis_uedr_ted_4resiliency;
      std::randomize(dis_uedr_ted_4resiliency)with{dis_uedr_ted_4resiliency dist {1:=50,0:=50};};
        getCsrProbeIf();
        getSMIIf();
        get_env_handle();

        fork
            // program Error Related registers when timeout is enabled
            begin
                if($test$plusargs("ev_enable_toggle")) begin
                    write_csr(<%=generateRegPath('0.XAIUTCR.EventDisable')%>, 1'b1); // Disable events
                    `uvm_info("ev_<%=obj.multiPortCoreId%> CSR SEQ",$sformatf("events enable = %0d at %0t", ev_enable, $realtime),UVM_DEBUG)
                end
                    if (($test$plusargs("wrong_sysreq_target_id")) || ($test$plusargs("sys_req_err_inj_uc")) || ($test$plusargs("sys_req_err_inj_c"))) begin
		        <% if(obj.useResiliency) { %>
		        if($test$plusargs("sys_req_err_inj_c"))begin
		        write_data = 0;
                        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCRTR.ResThreshold')%>, write_data);
			end
			<%}%>
		        if(dis_uedr_ted_4resiliency) begin
                         `uvm_info(get_full_name(),$sformatf("Skipping-0 enabling of error detection inside xUEDR"),UVM_NONE)
			 errtype = 4'h8;
                        // Set the UUECR_ErrDetEn = 1
                         write_data = 0;
                      //  write_csr(<%=generateRegPath('0.XAIUUEDR.TransErrDetEn')%>, write_data); 
                      //  write_csr(<%=generateRegPath('0.XAIUUEIR.TransErrIntEn')%>, write_data);
			if (!($test$plusargs("sys_req_err_inj_c")))begin 
      			write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.TransErrDetEn')%>, write_data); 
      			write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.TransErrIntEn')%>, write_data);
			end else begin 
      			write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
      			write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
			end

                        end
                       else begin
                        errtype = 4'h8;
                        // Set the UUECR_ErrDetEn = 1
                        write_data = 1;
                      //  write_csr(<%=generateRegPath('0.XAIUUEDR.TransErrDetEn')%>, write_data); 
                      //  write_csr(<%=generateRegPath('0.XAIUUEIR.TransErrIntEn')%>, write_data);
			if (!($test$plusargs("sys_req_err_inj_c")))begin 
      			write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.TransErrDetEn')%>, write_data); 
      			write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.TransErrIntEn')%>, write_data);
			end else begin 
      			write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
      			write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
			end
			end
                        ev_<%=obj.multiPortCoreId%>.trigger();
			if ($test$plusargs("wrong_sysreq_target_id")) 
                        do begin
                            @(posedge m_smi<%=smi_portid_sysreq%>_tx_vif.clk);
                        end while (((m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_type) != eConcMsgSysReq) || ((smi_seq_item::type2class(m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_type) == eConcMsgSysReq) && (m_smi<%=smi_portid_sysreq%>_tx_vif.smi_targ_id[WSMITGTID-1-WSMINCOREPORTID:0] == <%=obj.AiuInfo[obj.Id].FUnitId%>))))));
			else if (($test$plusargs("sys_req_err_inj_uc")) || ($test$plusargs("sys_req_err_inj_c")))
                        do begin
                            @(posedge m_smi<%=smi_portid_sysreq%>_tx_vif.clk);
      			<%if(obj.DutInfo.nNativeInterfacePorts !== 1) {%> 
        		end while (m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_ready === 1'b0 || u_csr_probe_vif.sys_req_ready_<%=obj.multiPortCoreId%> === 0 || u_csr_probe_vif.sys_req_valid_<%=obj.multiPortCoreId%> === 0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_type) != eConcMsgSysReq)));
        		<%} else {%>
        		end while (m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_type) != eConcMsgSysReq)));
        		 <% } %>
			if ($test$plusargs("wrong_sysreq_target_id")) begin
                        errinfo[0] = 1'b0; //0 for wrong targ_id
			end else begin
                        errinfo[0] = 1'b1; //1 for SMI Protection
			end
			if (!($test$plusargs("sys_req_err_inj_c")))begin 
                        errinfo[7:1] = 0;  //Resereved
                        errinfo[19:8] = m_smi<%=smi_portid_sysreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
			if ($test$plusargs("wrong_sysreq_target_id")) begin
                        errinfo_check = 1;
			end else begin
                        errinfo_check = 0; //CONC-12675
			end
                        erraddr_check = 0;
			uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type",eConcMsgSysReq); //for coverage
                         if(<%=obj.multiPortCoreId%> == 0) begin
			 <% if(obj.useResiliency) { %>

			 fork
	           begin
                       wait(u_csr_probe_vif.fault_mission_fault==1);
                       `uvm_info("RUN_MAIN","fault_mission_fault is asserted", UVM_NONE) 
	           end
		   begin
		       #200000ns;
                       `uvm_error("RUN_MAIN","fault_mission_fault isn't asserted")
	           end
       join_any
      disable fork;
      uvm_config_db#(int)::set(null,"*","ioaiu_fault_mission_fault",u_csr_probe_vif.fault_mission_fault);
      <%}%>
			 if(dis_uedr_ted_4resiliency) begin
                         `uvm_info(get_full_name(),$sformatf("Skipping-0 enabling of error detection inside xUEDR"),UVM_NONE)
                           end
                        else begin
                        //#Check.IOAIU.WrongTargetId.ErrVld
                        poll_UUESR_ErrVld(1, poll_data);
			read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data); 
        uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_vld",read_data);
                        // wait for IRQ_UC interrupt 
                        fork
                            begin
                                //#Check.IOAIU.WrongTargetId.IRQ_UC
                                wait (u_csr_probe_vif.IRQ_UC === 1);
                            end
                            begin
                                #200000ns;
                                `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
                            end
                        join_any
	     		disable fork;
               	     	read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
                        compareValues("UUESR_ErrType","Valid Type", read_data, errtype);
		        uvm_config_db#(int)::set(null,"*","ioaiu_wrong_target_id_uesr_err_type",read_data); //for coverage
		        uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_type",read_data); //for coverage
                        //#Check.IOAIU.WrongTargetId.ErrType
                      //  if (errinfo_check) begin
                        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
		        uvm_config_db#(int)::set(null,"*","ioaiu_wrong_target_id_uesr_err_info",read_data); //for coverage
	                uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_info",read_data); //for coverage
                        //#Check.IOAIU.WrongTargetId.ErrInfo
                        if(!$test$plusargs("smi_hdr_err_inj"))
                        compareValues("UUESR_ErrInfo","Valid Type", read_data, errinfo);
                        end
			end
                        write_data = 0;
                        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.TransErrDetEn')%>, write_data); 
                        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.TransErrIntEn')%>, write_data);
                        write_data = 1;
                        write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, write_data);
                        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>, read_data); 
                        compareValues("UUESR_ErrVld","should be", read_data, 0);
			cov.collect_uncorrectable_error(<%=obj.multiPortCoreId%>);
			end else
			begin 
		        errinfo[19:16] = 4'b0; 
		        errinfo[15:6] = m_smi<%=smi_portid_sysreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
		        errinfo[5:0] = 6'b0; 
		        errinfo_check = 0;
			uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_err_msg_type",eConcMsgSysReq); //for coverage
		        
	
                        if(<%=obj.multiPortCoreId%> == 0) begin
                        <% if(obj.useResiliency) { %>
                              fork
                        	           begin
                                               wait(u_csr_probe_vif.cerr_over_thres_fault==1);
                                               `uvm_info("RUN_MAIN","fault_thres_fault is asserted", UVM_NONE) 
                        	           end
                        		   begin
                        		       #200000ns;
                                               `uvm_error("RUN_MAIN","fault_thres_fault isn't asserted")
                        	           end
                               join_any
                              disable fork;
                              uvm_config_db#(int)::set(null,"*","ioaiu_fault_thres_fault",u_csr_probe_vif.cerr_over_thres_fault);
                              <%}%>
			
			if(dis_uedr_ted_4resiliency) begin
                         `uvm_info(get_full_name(),$sformatf("Skipping-0 enabling of error detection inside xUEDR"),UVM_NONE)
                           end
                        else begin
	       		poll_UCESR_ErrVld(1, poll_data);
			read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data); 
                        uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_uesr_err_vld",read_data);
	     		// wait for IRQ_C interrupt 
	     		fork
	     		begin
	     		    //#Check.IOAIU.SMIProtectionType.IRQ_C
	     		    wait (u_csr_probe_vif.IRQ_C === 1);
	     		end
	     		begin
	     		  #2000ns;
	     		  `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C asserted"));
	     		end
	     		join_any
	     		disable fork;
	     		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrType')%>, read_data);
	     		compareValues("UCESR_ErrType","Valid Type", read_data, errtype);
	     		uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_cesr_err_type",read_data); //for coverage
	     		if (errinfo_check) begin
	     		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrInfo')%>, read_data);
	     		uvm_config_db#(int)::set(null,"*","ioaiu_smi_prot_cesr_err_type",read_data); //for coverage
	     		compareValues("UCESR_ErrInfo","Valid Type", read_data, errinfo);
	     		end
                        end
			end
	     		write_data = 0;
	     		write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrDetEn')%>, write_data);
	     		write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCECR.ErrIntEn')%>, write_data);
	     		write_data = 1;
	     		write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, write_data);
	     		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrCount')%>, read_data);
      			compareValues("UCESR_ErrVld","should be", read_data, 0);
	     		read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUCESR.ErrVld')%>, read_data);
      			compareValues("UCESR_ErrVld","should be", read_data, 0);
			cov.collect_uncorrectable_error(<%=obj.multiPortCoreId%>);
			end
                    end //(($test$plusargs("wrong_sysreq_target_id")) || ($test$plusargs("sys_req_err_inj_uc")) || ($test$plusargs("sys_req_err_inj_c"))) 

                if($test$plusargs("enable_ev_timeout")) begin
                    //enable timeout error register
                    write_data = $urandom_range(1,0); // randomly turn on error detection or dont
                    err_det_en = write_data;
                    write_csr(<%=generateRegPath('0.XAIUUEDR.TimeoutErrDetEn')%>, write_data);
                    //enable interrupts
                    write_csr(<%=generateRegPath('0.XAIUUEIR.TimeoutErrIntEn')%>, write_data);
                    //septocr_timeout_threshold = $urandom_range(1,3); //Timeout Threshold - increments in the multiples of 4K so only randomizing few values to save time
                    ehtocr_timeout_threshold = $urandom_range(1,3); //Timeout Threshold - increments in the multiples of 4K so only randomizing few values to save time
                    //#Stimulus.IOAIU.SysevnetTimeOutThreshold
                    write_csr(<%=generateRegPath('0.XAIUEHTOCR.TimeOutThreshold')%>, ehtocr_timeout_threshold);
                    `uvm_info(get_full_name(), $sformatf("Programmed TimeoutErrDetEn:%0d EHTOCR:%0d", err_det_en, ehtocr_timeout_threshold), UVM_LOW)
                end
                if($test$plusargs("event_sys_rsp_timeout_error")) begin
                    //enable timeout error register
                    write_data = $urandom_range(1,0); // randomly turn on error detection or dont
                    err_det_en = write_data;
                    write_csr(<%=generateRegPath('0.XAIUUEDR.TimeoutErrDetEn')%>, write_data);
                    //enable interrupts
                    write_csr(<%=generateRegPath('0.XAIUUEIR.TimeoutErrIntEn')%>, write_data);
                    septocr_timeout_threshold = $urandom_range(1,3); //Timeout Threshold - increments in the multiples of 4K so only randomizing few values to save time
                    //ehtocr_timeout_threshold = $urandom_range(1,3); //Timeout Threshold - increments in the multiples of 4K so only randomizing few values to save time
                    //#Stimulus.IOAIU.SysevnetTimeOutThreshold
                    write_csr(<%=generateRegPath('0.XAIUSEPTOCR.TimeOutThreshold')%>, septocr_timeout_threshold);
                    `uvm_info(get_full_name(), $sformatf("Programmed TimeoutErrDetEn:%0d SEPTOCR:%0d", err_det_en, septocr_timeout_threshold), UVM_LOW)
                end

                if($test$plusargs("rand_event_delay")) begin //CONC-10371
                    write_data = 9;
                    write_csr(<%=generateRegPath('0.XAIUEHTOCR.TimeOutThreshold')%>, write_data);
                    `uvm_info(get_full_name(), $sformatf("Programmed EHTOCR to %0d",write_data),UVM_LOW)
                end

                read_csr(<%=generateRegPath('0.XAIUSEPTOCR.TimeOutThreshold')%>, read_data1);
                read_csr(<%=generateRegPath('0.XAIUEHTOCR.TimeOutThreshold')%>, read_data2);

                `uvm_info(get_full_name(), $sformatf("Before random traffic starts SEPTOCR:%0d EHTOCR:%0d", read_data1, read_data2),UVM_LOW)

                ev_<%=obj.multiPortCoreId%>.trigger();
                <%if (obj.DutInfo.fnNativeInterface !== "AXI4" && obj.DutInfo.fnNativeInterface !== "AXI5"){%>
                    if(($test$plusargs("enable_ev_timeout") || $test$plusargs("event_sys_rsp_timeout_error")) && err_det_en) begin  //randomly enable or disable error clearing
                        //#Check.IOAIU.SysceventSysTimeOutError.ErrVld
			do begin
                            read_csr(<%=generateRegPath('0.XAIUUESR.ErrVld')%>, read_data);
                            `uvm_info(get_full_name(), "Polling error valid register for error", UVM_LOW);
                        end while (read_data == 0);
                        `uvm_info(get_full_name(), "XAIUUESR.ErrVld asserted", UVM_LOW);

                        fork
                            begin
                                //#Check.IOAIU.SyseventTimeOutError.IRQ_UC
                                wait (u_csr_probe_vif.IRQ_UC === 1);
                                `uvm_info("ioaiu csr seq", "Interrupt asserted, waiting for mission fault to assert", UVM_LOW);
                                <%if(obj.useResiliency){%>
                                    #500ns;
                                    wait (u_csr_probe_vif.fault_mission_fault);
                                <%}%>
                            end
                            begin
                                #200000ns;
                                `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted or mission fault asserted"));
                            end
                        join_any
                        disable fork;
                        
                        //#Check.IOAIU.SyseventTimeOutError.ErrType
                        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrType')%>, read_data);
                        uvm_config_db#(int)::set(null,"*","ioaiu_sys_event_time_out_err_type",read_data); //for coverag
                        compareValues("XAIUUESR_ErrType","set", read_data, 'hA);

                        //#Check.IOAIU.SyseventTimeOutError.ErrInfo
                        read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrInfo')%>, read_data);
                        uvm_config_db#(int)::set(null,"*","ioaiu_sys_event_time_out_err_info",read_data); //for coverag
                        if ($test$plusargs("event_sys_rsp_timeout_error"))
                            compareValues("XAIUUESR_ErrInfo","clear", read_data, 0);
                           
                        if ($test$plusargs("enable_ev_timeout"))
                            compareValues("XAIUUESR_ErrInfo","set", read_data, 1);
                        
                                    
                        #1us; //wait for sometime before clearing error
                        write_data = 1;
                        write_csr(<%=generateRegPath('0.XAIUUESR.ErrVld')%>, write_data);
                    end
                    else begin 
                            //Keep the sequence active so it hits timeout, and
                            //mission_fault is asserted in resiliency configs
                            if ($test$plusargs("event_sys_rsp_timeout_error")) begin
                                //`uvm_info(get_full_name(),$sformatf("Start sequence active for %0d cycles", 4096*septocr_timeout_threshold), UVM_LOW)
	    	                #(<%=obj.Clocks[0].params.period%>ps*4096*septocr_timeout_threshold);
                                //`uvm_info(get_full_name(),$sformatf("End sequence active for %0d cycles", 4096*septocr_timeout_threshold), UVM_LOW)
                            end 
                            if($test$plusargs("enable_ev_timeout")) begin 
                                //`uvm_info(get_full_name(),$sformatf("Start sequence active for %0d cycles", 4096*ehtocr_timeout_threshold), UVM_LOW)
	    	                #(<%=obj.Clocks[0].params.period%>ps*4096*ehtocr_timeout_threshold);
                                //`uvm_info(get_full_name(),$sformatf("End sequence active for %0d cycles", 4096*ehtocr_timeout_threshold), UVM_LOW)
                            end
                    end 
                <%}%>
            end
        join
    endtask
endclass : ioaiu_csr_sysreq_event_seq_<%=obj.multiPortCoreId%>
//-----------------------------------------------------------------------
//   wait till ioaiu idle
//-----------------------------------------------------------------------
class ioaiu_wait_for_idle_<%=obj.multiPortCoreId%> extends ral_csr_base_seq; 
   `uvm_object_utils(ioaiu_wait_for_idle_<%=obj.multiPortCoreId%>)

    uvm_reg_data_t read_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
       read_data = 'hDEADBEEF ;  //bogus sentinel

       poll_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTAR.TransActv')%>,0,read_data);
       do begin
         read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUTAR.TransActv')%>, read_data);
       end while (read_data != 0);

    endtask
endclass : ioaiu_wait_for_idle_<%=obj.multiPortCoreId%>

class ioaiu_interface_parity_detection_seq_<%=obj.multiPortCoreId%> extends io_aiu_ral_csr_base_seq_<%=obj.multiPortCoreId%>;

   bit Intf_Check_Err_Det_En = 0;
   bit Intf_Check_Err_Int_En =0;
    uvm_reg_data_t read_data_info,read_data_type,read_data_valid,read_data2, read_data_tmp, write_data, poll_data, mask, SysCoConnecting_fieldVal, SysCoAttached_fieldVal, SysCoError_fieldVal,timeout_val;
   bit [3:0]  errtype;
   bit [19:0]  errinfo;
   int delay;
   string name;
   int data;
  `uvm_object_utils(ioaiu_interface_parity_detection_seq_<%=obj.multiPortCoreId%>)

  function new (string name = "ioaiu_interface_parity_detection_seq_<%=obj.multiPortCoreId%>");
       super.new(name);
  endfunction
 task body();
      getCsrProbeIf();
      std::randomize(Intf_Check_Err_Det_En) with { Intf_Check_Err_Det_En dist{1 := 90,0:=10};};
      std::randomize(Intf_Check_Err_Int_En) with { Intf_Check_Err_Int_En dist{1 := 90,0:=10};}; 
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEDR.IntfCheckErrDetEn')%>, Intf_Check_Err_Det_En); 
      write_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUEIR.IntfCheckErrIntEn')%>, Intf_Check_Err_Int_En);
      ev_<%=obj.multiPortCoreId%>.trigger();
      errtype = 4'hD; 
      if ($test$plusargs("inject_parity_err_aw_chnl")) begin
          $value$plusargs("inject_parity_err_aw_chnl=%0s",name);
          if(name== "AWVALID_CHK")begin 
              data = 0; 
            end
            if(name== "AWID_CHK")begin
                data=1; 
            end
            if(name== "AWADDR_CHK")begin 
                data=2; 
            end
            if(name== "AWLEN_CHK")begin  
                data=3; 
            end
            if(name== "AWCTL_CHK0")begin
                data=4; 
            end
            if(name== "AWCTL_CHK1")begin 
                data=5; 
            end
            if(name== "AWCTL_CHK2")begin 
                data=6; 
            end
            if(name== "AWCTL_CHK3")begin 
                data=7; 
            end
            if(name== "AWUSER_CHK")begin 
                data=8; 
            end
            if(name== "AWSTASHNID_CHK")begin 
                data=10; 
            end
            if(name== "AWSTASHLPID_CHK")begin 
                data=11; 
            end
           errinfo[4:0] = 5'b00001;
      end
      if ($test$plusargs("inject_parity_err_ar_chnl")) begin
          $value$plusargs("inject_parity_err_ar_chnl=%0s",name);
          if(name== "ARVALID_CHK")begin 
              data = 12; 
            end
            if(name== "ARID_CHK")begin
                data=13; 
            end
            if(name== "ARADDR_CHK")begin 
                data=14; 
            end
            if(name== "ARLEN_CHK")begin  
                data=15; 
            end
            if(name== "ARCTL_CHK0")begin
                data=16; 
            end
            if(name== "ARCTL_CHK1")begin 
                data=17; 
            end
            if(name== "ARCTL_CHK2")begin 
                data=18; 
            end
            if(name== "ARCTL_CHK3")begin 
                data=19; 
            end
            if(name== "ARUSER_CHK")begin 
                data=20; 
            end

           errinfo[4:0] = 5'b00000;
      end
      if ($test$plusargs("inject_parity_err_w_chnl")) begin
          $value$plusargs("inject_parity_err_w_chnl=%0s",name);
           if(name== "WVALID_CHK")begin 
                data=22; 
            end
            if(name== "WDATA_CHK")begin  
                 data=23;
            end
            if(name== "WSTRB_CHK")begin 
                data=24;
            end
            if(name== "WLAST_CHK")begin
                 data=25;
            end
            if(name== "WUSER_CHK")begin
                 data=26;
            end
           errinfo[4:0] = 5'b00010;
           
      end
      if ($test$plusargs("inject_parity_err_cr_chnl")) begin
          $value$plusargs("inject_parity_err_cr_chnl=%0s",name);
           if(name== "CRRESP_CHK")begin 
                data=28; 
            end
            if(name == "CRVALID_CHK")begin
              data =35;
            end
            
      errinfo[4:0] = 5'b0101;     
      end

        if ($test$plusargs("inject_parity_err_b_chnl")) begin
        data = 30;
        errinfo[4:0] = 5'b00100;
        end

        if ($test$plusargs("inject_parity_err_r_chnl")) begin
        data=31;
        errinfo[4:0] = 5'b00011;
        end
        
        if ($test$plusargs("inject_parity_err_cr_chnl")) begin
        errinfo[4:0] = 5'b00101;
        end

       if ($test$plusargs("inject_parity_err_ac_chnl")) begin
       data=32;
        errinfo[4:0] = 5'b00111;
        end

       if ($test$plusargs("inject_parity_err_rack")) begin
       data=33;
        errinfo[4:0] = 5'b01000;
        end

        if ($test$plusargs("inject_parity_err_wack")) begin
        data=34;
        errinfo[3:0] = 4'b01001;
        end
        
        if ($test$plusargs("inject_parity_err_cd_chnl")) begin
          $value$plusargs("inject_parity_err_cd_chnl=%0s",name);
        errinfo[4:0] = 5'b00110;
        if(name == "CDVALID_CHK")begin
        data =36 ;
        end
        if(name == "CDDATA_CHK")begin
        data =37 ;
        end
        if(name == "CDLAST_CHK")begin
        data =38 ;
        end
        end
       fork
           begin
	       if( Intf_Check_Err_Int_En == 1)begin
                   fork
                       begin
                            wait (u_csr_probe_vif.IRQ_UC === 1);
                       end
                       begin
                           #200000ns;
                           `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
                       end 
                   join_any
                   disable fork;
               end
           end

	   begin
	        if(Intf_Check_Err_Det_En == 1)begin
                    //#Check.IOAIU.Parity.ErrVld
                    poll_UUESR_ErrVld(1, poll_data,200_000);
                    read_csr(<%=generateRegPath('0.XAIUUESR.ErrType')%>, read_data_type);                     
                    //#Check.IOAIU.Parity.ErrType
                    compareValues("UUESR_ErrType","Valid Type", read_data_type, errtype);
                    read_csr(<%=generateRegPath('0.XAIUUESR.ErrInfo')%>, read_data_info);
                    //#Check.IOAIU.Parity.ErrInfo
                    compareValues("UUESR_ErrInfo","Valid Type", read_data_info, errinfo);
                    read_csr(<%=generateRegPath(obj.multiPortCoreId+'.XAIUUESR.ErrVld')%>,read_data_valid);
               end
	   end

	   begin
	       <% if(obj.useResiliency) { %>
               //#Check.IOAIU.Parity.mission_fault
	       fork
	           begin
                       wait(u_csr_probe_vif.fault_mission_fault==1);
                       `uvm_info("RUN_MAIN","fault_mission_fault is asserted", UVM_NONE) 
	           end
		   begin
		       #200000ns;
                       `uvm_error("RUN_MAIN","fault_mission_fault isn't asserted")
	           end
               join_any
	       disable fork;
              <%}%>
	   end
       join           
	 cov.collect_parity_err(read_data_type,read_data_info,Intf_Check_Err_Det_En,<% if(obj.useResiliency) { %>u_csr_probe_vif.fault_mission_fault <%}else {%> 0 <%}%>,data);
     
 endtask

endclass
