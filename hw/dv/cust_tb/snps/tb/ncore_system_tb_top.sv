<%const chipletObj = obj.lib.getAllChipletRefs();%>

//FIXME: Need to simplify the below if else condition after seeing what is the issue with single die config
// Also need to fixme for the import statements below
<%if(obj.chiplets.length>1){%>
    <%const included = new Set();%>
    <%for(let i=0; i<obj.chiplets.length; i+=1) {%>
        <%if(!included.has(`${obj.chiplets[i].master_chiplet}_ncore_param_info.sv`)){%>
            `include "<%=obj.chiplets[i].master_chiplet%>_ncore_param_info.sv"
            <%included.add(`${obj.chiplets[i].master_chiplet}_ncore_param_info.sv`);%>
        <%}%>
    <%}%>
<%}else{%>
    `include "ncore_param_info.sv";
<%}%>


`include "svt_axi_user_defines.svi"
`include "svt_chi_user_defines.svi"
`include "svt_apb_user_defines.svi"
`include "define.sv"

`ifdef EN_RESILIENCY
    `include "svt_apb_if.svi"
    `include "ncore_fault_if.sv"
    `include "ncore_fsys_fault_injector_checker.sv"
`endif

`include "ncore_irq_if.sv"

// `include "uvm_pkg.sv"

// Include the AMBA SVT UVM package 
`include "svt_amba.uvm.pkg"
`include "import_amba_packages.svi"
//for ACE vip includes
`include "svt_axi_if.svi"

// Include the AXI SVT UVM package 
`include "svt_axi.uvm.pkg"

// Include the AMBA COMMON SVT UVM package 
`include "svt_amba_common.uvm.pkg"
// `include "sv_assert_pkg.sv"
// `include "ncore_config_pkg.sv"
// `include "mem_agent_pkg.sv"
`include "ncore_clk_if.sv"

//<%if ((chipletObj ?? []).some(c => Number(c?.nChis ?? 0) > 0)) {%> //FIXME 
//<%}%>
`include "chi_if.sv"
`include "svt_chi_if.svi"
`include "connection_wrapper.sv"
`include "ncore_clk_rst_module.sv"
`include "ncore_system_register_map.sv"

<%if(obj.chiplets.length>1){%>
    <%const imported = new Set();%>
    <%for(let i=0; i<obj.chiplets.length; i+=1) {%>
        <%if(!imported.has(`${obj.chiplets[i].master_chiplet}_ncore_param_info`)){%>
            import <%=obj.chiplets[i].master_chiplet%>_ncore_param_info::*;
            <%imported.add(`${obj.chiplets[i].master_chiplet}_ncore_param_info`);%>
        <%}%>
    <%}%>
<%}else{%>
    import ncore_param_info::*;
<%}%>

//import ncore_param_info::*;
//import ncore_config_pkg::*;
import mem_agent_pkg::*;
import svt_uvm_pkg::*;
import svt_amba_uvm_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ncore_vip_configuration.sv"
`include "ncore_test_lib.sv"

<%
const isMixedConfig = chipletObj.map(c => {
    const types = new Set((c?.AiuInfo ?? []).map(a => String(a.fnNativeInterface).toUpperCase()));
    return (types.has('CHI-B') && types.has('CHI-E')) == true ? 1 : 0;
});
%>

module ncore_system_tb_top;

    timeunit 1ns;
    timeprecision 1ps;

    <%for(let i=0; i<chipletObj.length; i+=1){%>
        logic sys_clk_<%=i%>; 
    <%}%>
        logic dut_clk;
        logic sys_rstn; 
        logic soft_rstn;

    <%for(let i=0; i<chipletObj.length; i+=1){%>
        <%for(pidx = 0; pidx < chipletObj[i].AiuInfo.length; pidx++) {%>
            <%if(chipletObj[i].AiuInfo[pidx].fnNativeInterface.includes('CHI')){%>
                parameter int WREQFLIT<%=pidx%>_<%=i%> = <%=chipletObj[i].AiuInfo[pidx].interfaces.chiInt.params.wReqflit%>;
                parameter int WDATFLIT<%=pidx%>_<%=i%> = <%=chipletObj[i].AiuInfo[pidx].interfaces.chiInt.params.wDatflit%>;
                parameter int WRSPFLIT<%=pidx%>_<%=i%> = <%=chipletObj[i].AiuInfo[pidx].interfaces.chiInt.params.wRspflit%>;
                parameter int WSNPFLIT<%=pidx%>_<%=i%> = <%=chipletObj[i].AiuInfo[pidx].interfaces.chiInt.params.wSnpflit%>;
            <%}%>
        <%}%>
    <%}%>
    
  
    mem_agent ma;
    ncore_params obj;
    <%for(let i=0; i<chipletObj.length; i+=1){%>
        <%let l_chi_idx=0;%>
        // Declare Interface parity signals
        <%for(pidx = 0; pidx < chipletObj[i].AiuInfo.length; pidx++) {%>
            <%if(chipletObj[i].AiuInfo[pidx].fnNativeInterface.includes('CHI')){%>
                <%if(chipletObj[i].AiuInfo[pidx].interfaces.chiInt.params.checkType != "NONE"){%>
                    logic [((WREQFLIT<%=pidx%>_<%=i%>/8)+(WREQFLIT<%=pidx%>_<%=i%>%8 != 0))-1 : 0]    chi<%=l_chi_idx%>_<%=i%>_rx_req_flit_chk;
                    logic [((WRSPFLIT<%=pidx%>_<%=i%>/8)+(WRSPFLIT<%=pidx%>_<%=i%>%8 != 0))-1 : 0]    chi<%=l_chi_idx%>_<%=i%>_rx_rsp_flit_chk;
                    logic [((WDATFLIT<%=pidx%>_<%=i%>/8)+(WDATFLIT<%=pidx%>_<%=i%>%8 != 0))-1 : 0]    chi<%=l_chi_idx%>_<%=i%>_rx_dat_flit_chk;
                <%}%>
                <%l_chi_idx++;%>
            <%}%>
        <%}%>
    <%}%>

    <%for(let i=0; i<chipletObj.length; i+=1){%>
        <%for(var clock=0; clock < chipletObj[i].Clocks.length; clock++){%>
            ncore_clk_if m_clk_if_<%=chipletObj[i].Clocks[clock].name%><%=i%>();
            logic <%=chipletObj[i].Clocks[clock].name%>clk_<%=i%>;
            logic <%=chipletObj[i].Clocks[clock].name%>clk_sync_<%=i%>; 
            logic <%=chipletObj[i].Clocks[clock].name%>reset_n_<%=i%>;
            assign <%=chipletObj[i].Clocks[clock].name%>clk_<%=i%>  = m_clk_if_<%=chipletObj[i].Clocks[clock].name%><%=i%>.clk;
            assign <%=chipletObj[i].Clocks[clock].name%>reset_n_<%=i%> = m_clk_if_<%=chipletObj[i].Clocks[clock].name%><%=i%>.reset_n;
            assign <%=chipletObj[i].Clocks[clock].name%>test_en_<%=i%> = m_clk_if_<%=chipletObj[i].Clocks[clock].name%><%=i%>.test_en;
        <%}%>
        logic chi_clk_rn_clk_<%=i%>[(`SVT_CHI_MAX_NUM_RNS-1):0];
        logic chi_clk_sn_clk_<%=i%>[(`SVT_CHI_MAX_NUM_SNS-1):0];
        logic chi_clk_rn_resetn_<%=i%>[(`SVT_CHI_MAX_NUM_RNS-1):0];
        logic chi_clk_sn_resetn_<%=i%>[(`SVT_CHI_MAX_NUM_SNS-1):0];
    <%}%>


    //Interfaces instantiation
    <%for(let i=0; i<chipletObj.length; i++){%>
        <%if(chipletObj[i].useResiliency == 1){%>
            svt_apb_if m_fsc_apb_if_<%=i%>();
            fault_if  m_fsc_master_fault_<%=i%>();
            uvm_event mission_fault_detected_<%=i%>;
            parameter integer apb_dbg_id<%=i%> = 1;
        <%}else{%>
            parameter integer apb_dbg_id<%=i%> = 0;
        <%}%>
    <%}%>
    <%for(let i=0; i<chipletObj.length; i+=1){%>
        <%for(let pidx = 0; pidx < chipletObj[i].nAIUs; pidx++) { %>
            ncore_irq_if m_irq_<%=chipletObj[i].AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>_if();
        <%}%>
        <%for(let pidx = 0; pidx < chipletObj[i].nDMIs; pidx++) { %>
            ncore_irq_if m_irq_<%=chipletObj[i].DmiInfo[pidx].strRtlNamePrefix%>_<%=i%>_if();
        <%}%>
        <%for(let pidx = 0; pidx < chipletObj[i].nDCEs; pidx++) { %>
            ncore_irq_if m_irq_<%=chipletObj[i].DceInfo[pidx].strRtlNamePrefix%>_<%=i%>_if();
        <%}%>
        <%for(let pidx = 0; pidx < chipletObj[i].nDIIs; pidx++) { %>
            ncore_irq_if m_irq_<%=chipletObj[i].DiiInfo[pidx].strRtlNamePrefix%>_<%=i%>_if();
        <%}%>
        <%for(let pidx = 0; pidx < chipletObj[i].nDVEs; pidx++) { %>
            ncore_irq_if m_irq_<%=chipletObj[i].DveInfo[pidx].strRtlNamePrefix%>_<%=i%>_if();
        <%}%>
    <%}%>
    <%for(let i=0; i<chipletObj.length; i+=1){%>
        svt_chi_if  m_svt_chi_if_<%=i%>(
            .rn_clk(chi_clk_rn_clk_<%=i%>),
            .sn_clk(chi_clk_sn_clk_<%=i%>),
            .rn_resetn(chi_clk_rn_resetn_<%=i%>),
            .sn_resetn(chi_clk_sn_resetn_<%=i%>)
        );
    <%}%>
    
    //FIXME : Need to confirm
    <%for(let i=0; i<chipletObj.length; i+=1){%>
        svt_axi_if  m_axi_if_<%=i%>();
    <%}%>

    //FIXME: Need to update the below code to work on multiple chiplets
    <%if(process.env.ENABLE_INTERNAL_CODE && 0 ){%> //FIXME : Need to enable this later
        <%for(var idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
            <%for (var i = 0; i < chipletObj[0].AiuInfo[idx].smiPortParams.tx.length; i++) { %>
                smi_if  <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if(<%=chipletObj[0].AiuInfo[idx].nativeClk%>clk, <%=chipletObj[0].AiuInfo[idx].nativeClk%>reset_n );
            <%}%>
            <%for (var i = 0; i < chipletObj[0].AiuInfo[idx].smiPortParams.rx.length; i++) { %>
                smi_if  <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if(<%=chipletObj[0].AiuInfo[idx].nativeClk%>clk, <%=chipletObj[0].AiuInfo[idx].nativeClk%>reset_n);
            <%}%>
        <%}%>

        // DMI
        <%for(var pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
            <%for (var i = 0; i < chipletObj[0].DmiInfo[pidx].smiPortParams.tx.length; i++) { %>
                smi_if dmi<%=pidx%>_smi<%=i%>_tx_port_if(<%=chipletObj[0].DmiInfo[pidx].unitClk[0]%>clk, <%=chipletObj[0].DmiInfo[pidx].unitClk[0]%>reset_n);
            <%}%>
            <%for (var i = 0; i < chipletObj[0].DmiInfo[pidx].smiPortParams.rx.length; i++) { %>
                smi_if dmi<%=pidx%>_smi<%=i%>_rx_port_if(<%=chipletObj[0].DmiInfo[pidx].unitClk[0]%>clk, <%=chipletObj[0].DmiInfo[pidx].unitClk[0]%>reset_n);
            <%}%>
        <%}%>
        // DCE
        <%for(var pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) { %>
            <%for (var i = 0; i < chipletObj[0].DceInfo[pidx].smiPortParams.tx.length; i++) { %>
                smi_if  dce<%=pidx%>_smi<%=i%>_tx_port_if(<%=chipletObj[0].DceInfo[pidx].unitClk[0]%>clk, <%=chipletObj[0].DceInfo[pidx].unitClk[0]%>reset_n);
            <%}%>
            <%for (var i = 0; i < chipletObj[0].DceInfo[pidx].smiPortParams.rx.length; i++) { %>
                smi_if  dce<%=pidx%>_smi<%=i%>_rx_port_if(<%=chipletObj[0].DceInfo[pidx].unitClk[0]%>clk, <%=chipletObj[0].DceInfo[pidx].unitClk[0]%>reset_n);
            <%}%>
        <%}%>
        // DII
        <%for(var pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) { %>
            <%for (var i = 0; i < chipletObj[0].DiiInfo[pidx].smiPortParams.tx.length; i++) { %>
                smi_if  dii<%=pidx%>_smi<%=i%>_tx_port_if(<%=chipletObj[0].DiiInfo[pidx].unitClk[0]%>clk, <%=chipletObj[0].DiiInfo[pidx].unitClk[0]%>reset_n);
            <%}%>
            <%for (var i = 0; i < chipletObj[0].DiiInfo[pidx].smiPortParams.rx.length; i++) { %>
                smi_if  dii<%=pidx%>_smi<%=i%>_rx_port_if(<%=chipletObj[0].DiiInfo[pidx].unitClk[0]%>clk, <%=chipletObj[0].DiiInfo[pidx].unitClk[0]%>reset_n);
            <%}%>
        <%}%>
    <%}%>

    //FIXME: need to fix the connection wrapper below
    <%for(let i=0; i<chipletObj.length; i+=1){%>
        <%let l_chi_idx=0;%>
        <%for(let pidx = 0; pidx < chipletObj[i].AiuInfo.length; pidx++) {%>
            <%if(chipletObj[i].AiuInfo[pidx].fnNativeInterface.includes('CHI')){%>
                chi_if #(WREQFLIT<%=pidx%>_<%=i%>,  WRSPFLIT<%=pidx%>_<%=i%>, WDATFLIT<%=pidx%>_<%=i%>, WSNPFLIT<%=pidx%>_<%=i%>) m_chi_if<%=l_chi_idx%>_<%=i%>();
                connection_wrapper #(FLIT_INFO[<%=l_chi_idx%>], "<%=chipletObj[i].AiuInfo[pidx].fnNativeInterface%>", <%=isMixedConfig[i]%>) m_connect_wrapper<%=pidx%><%=i%>(m_chi_if<%=l_chi_idx%>_<%=i%>, m_svt_chi_if_<%=i%>.rn_if[<%=l_chi_idx%>]);
                <%l_chi_idx++;%>
            <%}%>
        <%}%>
            <%if(chipletObj[i].useResiliency == 1){%>
                assign m_fsc_apb_if_<%=i%>.pclk = <%=chipletObj[i].AiuInfo[0].nativeClk%>clk_<%=i%>;
                assign m_fsc_apb_if_<%=i%>.presetn = <%=chipletObj[i].AiuInfo[0].nativeClk%>reset_n_<%=i%>;
            <%}%>
    <%}%>

    //FIXME : Need to confirm
    <%for(let i=0; i<chipletObj.length; i+=1){%>
        <%if(chipletObj[i].DebugApbInfo.length > 0){%>
            svt_apb_if  m_apb_debug_if_<%=i%>();
        <%}%>

        <% let ioidx=0;
        l_chi_idx=0;%>
        <%for(let idx=0; idx<chipletObj[i].nAIUs; idx++){%>
            <%if(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes("CHI")){%>
                assign chi_clk_rn_clk_<%=i%>[<%=l_chi_idx%>] = <%=chipletObj[0].AiuInfo[idx].nativeClk%>clk_0;
                assign chi_clk_sn_clk_<%=i%>[<%=l_chi_idx%>] = <%=chipletObj[0].AiuInfo[idx].nativeClk%>clk_0;
                assign chi_clk_rn_resetn_<%=i%>[<%=l_chi_idx%>]  =  <%=chipletObj[0].AiuInfo[idx].nativeClk%>reset_n_0; //FIXME: The _0 should come from tachl here
                assign chi_clk_sn_resetn_<%=i%>[<%=l_chi_idx%>]  =  <%=chipletObj[0].AiuInfo[idx].nativeClk%>reset_n_0;
                <%l_chi_idx++;%>
            <%}else{%>
                <%for(let sub_io=0; sub_io<chipletObj[i].AiuInfo[idx].nNativeInterfacePorts; sub_io++){%>
                    assign m_axi_if_<%=i%>.master_if[<%=ioidx%>].aclk = <%=chipletObj[i].AiuInfo[idx].nativeClk%>clk_0; //FIXME: THis _0 should be replaced by tachl
                    assign m_axi_if_<%=i%>.master_if[<%=ioidx%>].aresetn =  <%=chipletObj[i].AiuInfo[idx].nativeClk%>reset_n_0;
                    <%ioidx++;%>
                <%}%>
            <%}%>
            initial  begin
                m_axi_if_<%=i%>.set_master_common_clock_mode(0,<%=idx%>);
            end
        <%}%>
    <%}%>
  
    <%for(let i=0; i<chipletObj.length; i+=1){%>
        <%if(chipletObj[0].DebugApbInfo.length > 0){%>
            assign m_apb_debug_if_<%=i%>.pclk = <%=chipletObj[i].DebugApbInfo[0].unitClk[0]%>clk_0; //FIXME: THis _0 should be replaced by tachl
            assign m_apb_debug_if_<%=i%>.presetn = <%=chipletObj[i].DebugApbInfo[0].unitClk[0]%>reset_n_0; //FIXME: THis _0 should be replaced by tachl
        <%}%>
        assign m_axi_if_<%=i%>.common_aclk = <%=chipletObj[0].DmiInfo[0].unitClk[0]%>clk_0; //FIXME: THis _0 should be replaced by tachl
        <%let axiid=0;%>
        <%for(let pidx = 0; pidx < chipletObj[i].nDMIs; pidx++){%>
            assign m_axi_if_<%=i%>.slave_if[<%=axiid%>].aclk = <%=chipletObj[i].DmiInfo[pidx].unitClk[0]%>clk_0; //FIXME: THis _0 should be replaced by tachl
            assign m_axi_if_<%=i%>.slave_if[<%=axiid%>].aresetn = <%=chipletObj[i].DmiInfo[pidx].unitClk[0]%>reset_n_0; //FIXME: THis _0 should be replaced by tachl
            initial  begin
                m_axi_if_<%=i%>.set_slave_common_clock_mode(0,<%=axiid%>);
            end
            <%axiid++;%>
        <%}%>
        
        <% let axiidx=0;
        for(let pidx = 0; pidx < chipletObj[0].nDIIs; pidx++){%>
            <% if (chipletObj[0].DiiInfo[pidx].configuration == 0){%>  					       
                assign m_axi_if_<%=i%>.slave_if[<%=axiid%>].aclk = <%=chipletObj[i].DiiInfo[pidx].unitClk[0]%>clk_0; //FIXME: THis _0 should be replaced by tachl
                assign m_axi_if_<%=i%>.slave_if[<%=axiid%>].aresetn = <%=chipletObj[i].DiiInfo[pidx].unitClk[0]%>reset_n_0; //FIXME: THis _0 should be replaced by tachl  
                initial  begin
                    m_axi_if_<%=i%>.set_slave_common_clock_mode(0,<%=axiid%>);
                end
                <%axiid++;%>
            <%}%>
        <%}%>
    <%}%>

    function automatic logic[63:0] calculateParity(logic [511:0] sig);
        longint checkValue = 0;
        for(int i=0; i<64; i+=1) begin
            checkValue[i] = ~^sig[(i*8) +: 8];
        end
        return checkValue;
    endfunction

    // DUT Instantiation
    <% if (chipletObj[0].useRtlPrefix == 1) { %>
        //<%=chipletObj[0].strProjectName_gen_wrapper%> u_chip ( // CHECK
        DIE_ASSEMBLY_gen_wrapper u_chip (
    <% } else { %>
        gen_wrapper u_chip (
    <% } %>

    <%for(let i=0; i<chipletObj.length; i+=1){%>
        <%let prefix = chipletObj.length>1 ? `${chiplets[i].chiplet_name}_` : "";%>
        <%if(chipletObj[i].useResiliency == 1){%>
            .fsc_<%=chipletObj[i].FscInfo.interfaces.apbInterface.name%>psel       (m_fsc_apb_if_<%=i%>.psel),
            .fsc_<%=chipletObj[i].FscInfo.interfaces.apbInterface.name%>penable    (m_fsc_apb_if_<%=i%>.penable),
            .fsc_<%=chipletObj[i].FscInfo.interfaces.apbInterface.name%>pwrite     (m_fsc_apb_if_<%=i%>.pwrite),
            <% if(chipletObj[i].FscInfo.interfaces.apbInterface.params.wProt>0){%>
                .fsc_<%=chipletObj[i].FscInfo.interfaces.apbInterface.name%>pprot      (m_fsc_apb_if_<%=i%>.pprot),
            <%}%>
            <%if(chipletObj[i].FscInfo.interfaces.apbInterface.params.wStrb>0){%>
                .fsc_<%=chipletObj[i].FscInfo.interfaces.apbInterface.name%>pstrb      (m_fsc_apb_if_<%=i%>.pstrb),
            <%}%>
            .fsc_<%=chipletObj[i].FscInfo.interfaces.apbInterface.name%>paddr      (m_fsc_apb_if_<%=i%>.paddr),
            .fsc_<%=chipletObj[i].FscInfo.interfaces.apbInterface.name%>pwdata     (m_fsc_apb_if_<%=i%>.pwdata),
            .fsc_<%=chipletObj[i].FscInfo.interfaces.apbInterface.name%>pready     (m_fsc_apb_if_<%=i%>.slave_if[0].pready),
            .fsc_<%=chipletObj[i].FscInfo.interfaces.apbInterface.name%>prdata     (m_fsc_apb_if_<%=i%>.slave_if[0].prdata),
            .fsc_<%=chipletObj[i].FscInfo.interfaces.apbInterface.name%>pslverr    (m_fsc_apb_if_<%=i%>.slave_if[0].pslverr),
            .fsc_<%=chipletObj[i].FscInfo.interfaces.masterFaultInterface.name%>mission_fault  (m_fsc_master_fault_<%=i%>.mission_fault),
            .fsc_<%=chipletObj[i].FscInfo.interfaces.masterFaultInterface.name%>latent_fault  (m_fsc_master_fault_<%=i%>.latent_fault),
            .fsc_<%=chipletObj[i].FscInfo.interfaces.masterFaultInterface.name%>cerr_over_thres_fault  (m_fsc_master_fault_<%=i%>.cerr_over_thres_fault),
            .ncore_en_debug_bist_pin(1'b1),
        <%}%>
        <%if(chipletObj[i].DebugApbInfo.length > 0){%>
            .<%=prefix%>ncore_debug_atu_config_paddr(m_apb_debug_if_<%=i%>.paddr),
            .<%=prefix%>ncore_debug_atu_config_psel(m_apb_debug_if_<%=i%>.psel),
            .<%=prefix%>ncore_debug_atu_config_penable(m_apb_debug_if_<%=i%>.penable),
            .<%=prefix%>ncore_debug_atu_config_pwrite(m_apb_debug_if_<%=i%>.pwrite),
            .<%=prefix%>ncore_debug_atu_config_pwdata(m_apb_debug_if_<%=i%>.pwdata),
            .<%=prefix%>ncore_debug_atu_config_pready(m_apb_debug_if_<%=i%>.slave_if[0].pready),
            .<%=prefix%>ncore_debug_atu_config_prdata(m_apb_debug_if_<%=i%>.slave_if[0].prdata),
            .<%=prefix%>ncore_debug_atu_config_pslverr(m_apb_debug_if_<%=i%>.slave_if[0].pslverr),
            <%if(chipletObj[i].DebugApbInfo[0].interfaces.apbInterface.params.wStrb>0){%>
                .<%=prefix%>ncore_debug_atu_config_pstrb      (m_apb_debug_if_<%=i%>.slave_if[0].pstrb),
            <%}%>
            <%if(chipletObj[i].DebugApbInfo[0].interfaces.apbInterface.params.wProt>0){%>
                .<%=prefix%>ncore_debug_atu_config_pprot      ('d0),
            <%}%>
        <%}%>
        <%for(let idx = 0; idx < chipletObj[i].nAIUs; idx++){ %>
            <%if(chipletObj[i].AiuInfo[idx].interfaces.eventRequestInInt._SKIP_ == false) {%>        
                .<%=prefix%><%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=chipletObj[i].AiuInfo[idx].interfaces.eventRequestInInt.name%>req              (1'b0),
                .<%=prefix%><%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=chipletObj[i].AiuInfo[idx].interfaces.eventRequestInInt.name%>ack              (),
            <%}%>
            <%if(chipletObj[i].AiuInfo[idx].interfaces.eventRequestOutInt._SKIP_ == false) {%>        
                .<%=prefix%><%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=chipletObj[i].AiuInfo[idx].interfaces.eventRequestOutInt.name%>req              (),
                .<%=prefix%><%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=chipletObj[i].AiuInfo[idx].interfaces.eventRequestOutInt.name%>ack              (1'b0),
            <%}%>
            <%if(!(chipletObj[i].AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                <%if(chipletObj[i].AiuInfo[idx].interfaces.userPlaceInt._SKIP_ == false || (typeof chipletObj[i].AiuInfo[idx].interfaces.memoryInt !== 'undefined')){%>
                    <%for(var memIdx = 0; memIdx < chipletObj[i].AiuInfo[idx].interfaces.memoryInt.length; memIdx++){%>
                        <%for(var inIdx = 0; inIdx < chipletObj[i].AiuInfo[idx].interfaces.memoryInt[memIdx].synonyms.in.length; inIdx++){%>
                            <%if(chipletObj[i].AiuInfo[idx].interfaces.memoryInt[memIdx]._SKIP_ === false){%>
                                .<%=prefix%><%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=chipletObj[i].AiuInfo[idx].interfaces.memoryInt[memIdx].name%><%=chipletObj[i].AiuInfo[idx].interfaces.memoryInt[memIdx].synonyms.in[inIdx].name%>                ('b0),
                            <%}%>
                        <%}%>
                    <%}%>
                <%}%>
            <%}%>
        <%}%>

        <%for(let idx = 0; idx < chipletObj[i].nAIUs; idx++){%>
            <%if(!chipletObj[i].AiuInfo[idx].fnNativeInterface.includes('CHI')){%>
                .<%=prefix%><%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_irq_c                (m_irq_<%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=i%>_if.IRQ_c),
            <%}%>
            .<%=prefix%><%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=i%>_if.IRQ_uc),
        <%}%>
        <%for(let idx = 0; idx < chipletObj[i].nDMIs; idx++){ %>
            .<%=prefix%><%=chipletObj[i].DmiInfo[idx].strRtlNamePrefix%>_irq_c                (m_irq_<%=chipletObj[i].DmiInfo[idx].strRtlNamePrefix%>_<%=i%>_if.IRQ_c),
            .<%=prefix%><%=chipletObj[i].DmiInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=chipletObj[i].DmiInfo[idx].strRtlNamePrefix%>_<%=i%>_if.IRQ_uc),
            <%if(chipletObj[i].DmiInfo[idx].interfaces.userPlaceInt._SKIP_ == false || (typeof chipletObj[i].DmiInfo[idx].interfaces.memoryInt !== 'undefined')){%>
                <%for(var memIdx = 0; memIdx < chipletObj[i].DmiInfo[idx].interfaces.memoryInt.length; memIdx++){ %>
                    <%for(var inIdx = 0; inIdx < chipletObj[i].DmiInfo[idx].interfaces.memoryInt[memIdx].synonyms.in.length; inIdx++){%>
                        <%if(chipletObj[i].DmiInfo[idx].interfaces.memoryInt[memIdx]._SKIP_ === false){%>
                            .<%=prefix%><%=chipletObj[i].DmiInfo[idx].strRtlNamePrefix%>_<%=chipletObj[i].DmiInfo[idx].interfaces.memoryInt[memIdx].name%><%=chipletObj[i].DmiInfo[idx].interfaces.memoryInt[memIdx].synonyms.in[inIdx].name%>                ('b0),
                        <%}%>
                    <%}%>
                <%}%>
            <%}%>
        <%}%>
        <%for(let idx = 0; idx < chipletObj[i].nDIIs; idx++){%>
            .<%=prefix%><%=chipletObj[i].DiiInfo[idx].strRtlNamePrefix%>_irq_c                (m_irq_<%=chipletObj[i].DiiInfo[idx].strRtlNamePrefix%>_<%=i%>_if.IRQ_c),
            .<%=prefix%><%=chipletObj[i].DiiInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=chipletObj[i].DiiInfo[idx].strRtlNamePrefix%>_<%=i%>_if.IRQ_uc),
            <%if(chipletObj[i].DiiInfo[idx].interfaces.userPlaceInt._SKIP_ == false || (typeof chipletObj[i].DiiInfo[idx].interfaces.memoryInt !== 'undefined')){%>
                <%for(var inIdx = 0; inIdx < chipletObj[i].DiiInfo[idx].interfaces.userPlaceInt.synonyms.in.length; inIdx++){ %>
                    .<%=prefix%><%=chipletObj[i].DiiInfo[idx].strRtlNamePrefix%>_<%=chipletObj[i].DiiInfo[idx].interfaces.userPlaceInt.name%><%=chipletObj[i].DiiInfo[idx].interfaces.userPlaceInt.synonyms.in[inIdx].name%>                ('b0),
                <%}%>
            <%}%>
        <%}%>
        <%for(let idx = 0; idx < chipletObj[i].nDCEs; idx++){ %>
            .<%=prefix%><%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>_irq_c                (m_irq_<%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>_<%=i%>_if.IRQ_c),
            .<%=prefix%><%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>_<%=i%>_if.IRQ_uc),
            <%if(chipletObj[i].DceInfo[idx].interfaces._SKIP_ == false || (typeof chipletObj[i].DceInfo[idx].interfaces.memoryInt !== 'undefined')){%>
                <%for(var memIdx = 0; memIdx < chipletObj[i].DceInfo[idx].interfaces.memoryInt.length; memIdx++){%>
                    <%for(var inIdx = 0; inIdx < chipletObj[i].DceInfo[idx].interfaces.memoryInt[memIdx].synonyms.in.length; inIdx++){%>
                        .<%=prefix%><%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>_<%=chipletObj[i].DceInfo[idx].interfaces.memoryInt[memIdx].name%><%=chipletObj[i].DceInfo[idx].interfaces.memoryInt[memIdx].synonyms.in[inIdx].name%>                ('b0),
                    <%}%>
                <%}%>
            <%}%>
        <%}%>
        <% for(let idx = 0; idx < chipletObj[i].nDVEs; idx++){ %>
            .<%=prefix%><%=chipletObj[i].DveInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=chipletObj[i].DveInfo[idx].strRtlNamePrefix%>_<%=i%>_if.IRQ_uc),
            <%if(chipletObj[i].DveInfo[idx].interfaces._SKIP_ == false || (typeof chipletObj[i].DveInfo[idx].interfaces.memoryInt !== 'undefined')){%>
                <%for(var memIdx = 0; memIdx < chipletObj[i].DveInfo[idx].interfaces.memoryInt.length; memIdx++){ %>
                    <%for(var inIdx = 0; inIdx < chipletObj[i].DveInfo[idx].interfaces.memoryInt[memIdx].synonyms.in.length; inIdx++){ %>
                        .<%=prefix%><%=chipletObj[i].DveInfo[idx].strRtlNamePrefix%>_<%=chipletObj[i].DveInfo[idx].interfaces.memoryInt[memIdx].name%><%=chipletObj[i].DveInfo[idx].interfaces.memoryInt[memIdx].synonyms.in[inIdx].name%>                ('b0),
                    <%}%>
                <%}%>
            <%}%>
        <%}%>
        <% axiidx = 0; chiidx=0;%>
        <%chipletObj[i].AiuInfo.forEach(function(bundle, idx) { %>
            <%if (bundle.fnNativeInterface.includes('CHI')) { %>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_sactive              (m_chi_if<%=chiidx%>_<%=i%>.tx_sactive),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_sactive_chk     (!m_chi_if<%=chiidx%>_<%=i%>.tx_sactive),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_sactive              (m_chi_if<%=chiidx%>_<%=i%>.rx_sactive),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_link_active_req      (m_chi_if<%=chiidx%>_<%=i%>.tx_link_active_req),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_link_active_req_chk  (!m_chi_if<%=chiidx%>_<%=i%>.tx_link_active_req),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_link_active_ack      (m_chi_if<%=chiidx%>_<%=i%>.tx_link_active_ack),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_link_active_req      (m_chi_if<%=chiidx%>_<%=i%>.rx_link_active_req),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_link_active_ack      (m_chi_if<%=chiidx%>_<%=i%>.rx_link_active_ack),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_link_active_ack_chk  (!m_chi_if<%=chiidx%>_<%=i%>.rx_link_active_ack),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flit_pend        (m_chi_if<%=chiidx%>_<%=i%>.tx_req_flit_pend),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flit_pend_chk  (!m_chi_if<%=chiidx%>_<%=i%>.tx_req_flit_pend),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flitv            (m_chi_if<%=chiidx%>_<%=i%>.tx_req_flitv),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flitv_chk  (!m_chi_if<%=chiidx%>_<%=i%>.tx_req_flitv),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flit             (m_chi_if<%=chiidx%>_<%=i%>.tx_req_flit),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flit_chk  (calculateParity(m_chi_if<%=chiidx%>_<%=i%>.tx_req_flit)),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_lcrdv            (m_chi_if<%=chiidx%>_<%=i%>.tx_req_lcrdv),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flit_pend        (m_chi_if<%=chiidx%>_<%=i%>.tx_rsp_flit_pend),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flit_pend_chk  (!m_chi_if<%=chiidx%>_<%=i%>.tx_rsp_flit_pend),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flitv            (m_chi_if<%=chiidx%>_<%=i%>.tx_rsp_flitv),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flitv_chk  (!m_chi_if<%=chiidx%>_<%=i%>.tx_rsp_flitv),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flit             (m_chi_if<%=chiidx%>_<%=i%>.tx_rsp_flit),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flit_chk  (calculateParity(m_chi_if<%=chiidx%>_<%=i%>.tx_rsp_flit)),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_lcrdv            (m_chi_if<%=chiidx%>_<%=i%>.tx_rsp_lcrdv),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flit_pend        (m_chi_if<%=chiidx%>_<%=i%>.tx_dat_flit_pend),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flit_pend_chk  (!m_chi_if<%=chiidx%>_<%=i%>.tx_dat_flit_pend),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flitv            (m_chi_if<%=chiidx%>_<%=i%>.tx_dat_flitv),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flitv_chk  (!m_chi_if<%=chiidx%>_<%=i%>.tx_dat_flitv),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flit             (m_chi_if<%=chiidx%>_<%=i%>.tx_dat_flit),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flit_chk  (calculateParity(m_chi_if<%=chiidx%>_<%=i%>.tx_dat_flit)),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_lcrdv            (m_chi_if<%=chiidx%>_<%=i%>.tx_dat_lcrdv),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_flit_pend        (m_chi_if<%=chiidx%>_<%=i%>.rx_snp_flit_pend),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_flitv            (m_chi_if<%=chiidx%>_<%=i%>.rx_snp_flitv),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_flit             (m_chi_if<%=chiidx%>_<%=i%>.rx_snp_flit),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_lcrdv            (m_chi_if<%=chiidx%>_<%=i%>.rx_snp_lcrdv),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_lcrdv_chk  (!m_chi_if<%=chiidx%>_<%=i%>.rx_snp_lcrdv),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_flit_pend        (m_chi_if<%=chiidx%>_<%=i%>.rx_rsp_flit_pend),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_flitv            (m_chi_if<%=chiidx%>_<%=i%>.rx_rsp_flitv),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_flit             (m_chi_if<%=chiidx%>_<%=i%>.rx_rsp_flit),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_lcrdv            (m_chi_if<%=chiidx%>_<%=i%>.rx_rsp_lcrdv),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_lcrdv_chk  (!m_chi_if<%=chiidx%>_<%=i%>.rx_rsp_lcrdv),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_flit_pend        (m_chi_if<%=chiidx%>_<%=i%>.rx_dat_flit_pend),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_flitv            (m_chi_if<%=chiidx%>_<%=i%>.rx_dat_flitv),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_flit             (m_chi_if<%=chiidx%>_<%=i%>.rx_dat_flit),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_lcrdv            (m_chi_if<%=chiidx%>_<%=i%>.rx_dat_lcrdv),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_lcrdv_chk  (!m_chi_if<%=chiidx%>_<%=i%>.rx_dat_lcrdv),
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>sysco_req               (m_chi_if<%=chiidx%>_<%=i%>.sysco_req),
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>sysco_ack               (m_chi_if<%=chiidx%>_<%=i%>.sysco_ack),
                <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>sysco_req_chk      (!m_chi_if<%=chiidx%>_<%=i%>.sysco_req),
                <%}%>
                <%chiidx++%>
            <%}else{%>
                <%for (var mpu_io = 0; mpu_io < bundle.nNativeInterfacePorts; mpu_io++){%>
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ready                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awready                   ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_valid                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awvalid                   ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_id                   ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awid                      ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_addr                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awaddr                    ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_len                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awlen                     ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_size                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awsize                    ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_burst                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awburst                   ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_lock                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awlock                    ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_cache                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awcache                   ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_prot                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awprot                    ) ,
                    <%if (bundle.interfaces.axiInt[mpu_io].params.eAtomic>0) { %>                                                                          
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_atop               ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awatop                  ) ,
                    <%}%>                                                                                                                         
                    <%if (bundle.interfaces.axiInt[mpu_io].params.wRegion>0) { %>                                                                          
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_region               ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awregion                  ) ,
                    <%}%>                                                                                                                         
                    <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_trace                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awtrace                     ) ,
                    <%}%>                                                                                                                                
                    <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ready_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awreadychk               ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_valid_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awvalidchk               ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_id_chk               ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awidchk                  ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_addr_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awaddrchk                ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_len_chk              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awlenchk                 ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ctl_chk0             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awctlchk0                ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ctl_chk1             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awctlchk1                ) ,
                        <%if (!(bundle.fnNativeInterface === "AXI5")){%>
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ctl_chk2             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awctlchk2                ) ,
                            <%}%>
                        <%if (!(bundle.fnNativeInterface === "ACE5")){%>
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ctl_chk3             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awctlchk3                ) ,
                        <%}%>
                        <%if (!((bundle.fnNativeInterface === "ACE5") || (bundle.fnNativeInterface === "AXI5"))){%>
                            <%if (bundle.interfaces.axiInt[mpu_io].params.eStash>0) { %>                                                                                    
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashnid_chk         ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awstashnidchk            ) ,
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashlpid_chk        ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awstashlpidchk           ) ,
                            <%}%>                                                                                                                         
                        <%}%>                                                                                                                         
                        <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_trace_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awtracechk               ) ,
                        <%}%>                                                                                                                         
                    <%}%>                                                                                                                         

                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_ready                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wready                    ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_valid                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wvalid                    ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_data                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wdata[<%=bundle.interfaces.axiInt[mpu_io].params.wData - 1%> : 0]                     ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_last                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wlast                     ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_strb                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wstrb[<%=bundle.interfaces.axiInt[mpu_io].params.wData/8 - 1%> : 0]                     ) ,
                    <%if (bundle.interfaces.axiInt[mpu_io].params.wWUser > 0){%>
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_user                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wuser                     ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_user_chk              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wuserchk                  ) ,
                        <%}%>
                    <%}%>
                    <%if(bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_trace                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wtrace                       ) ,
                    <%}%>
                    <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_ready_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wreadychk                ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_valid_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wvalidchk                ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_data_chk              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wdatachk                 ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_strb_chk              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wstrbchk                 ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_last_chk              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wlastchk                 ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_trace_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wtracechk                ) ,
                        <%}%>                                                                                                                         
                    <%}%>

                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_ready                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].bready                    ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_valid                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].bvalid                    ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_id                    ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].bid                       ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_resp                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].bresp                     ) ,
                    <%if (bundle.interfaces.axiInt[mpu_io].params.wBUser > 0){%>
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_user              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].buser                     ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_user_chk          ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].buserchk                  ) ,
                        <%}%>                                                                                                                         
                    <%}%>                                                                                                                         
                    <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_trace                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].btrace                       ) ,
                    <%}%>
                    <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_ready_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].breadychk                ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_valid_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].bvalidchk                ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_id_chk                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].bidchk                   ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_resp_chk              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].brespchk                 ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_trace_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].btracechk                ) ,
                        <%}%>                                                                                                                         
                    <%}%>

                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_valid                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arvalid                   ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ready                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arready                   ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_id                   ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arid                      ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_addr                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].araddr                    ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_len                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arlen                     ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_size                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arsize                    ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_burst                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arburst                   ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_lock                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arlock                    ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_cache                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arcache                   ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_prot                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arprot                    ) ,
                    <%if (bundle.interfaces.axiInt[mpu_io].params.wRegion>0) { %>                                                                          
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_region               ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arregion                    ) ,
                    <%}%>
                    <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_trace                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].artrace                       ) ,
                    <%}%>
                    <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_valid_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arvalidchk               ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ready_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arreadychk               ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_id_chk               ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].aridchk                  ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_addr_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].araddrchk                ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_len_chk              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arlenchk                 ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ctl_chk0             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arctlchk0                ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ctl_chk1             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arctlchk1                ) ,
                        <%if (!(bundle.fnNativeInterface === "AXI5")){%>
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ctl_chk2             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arctlchk2                ) ,
                            <%if(bundle.interfaces.axiInt[mpu_io].params.eAc == 1 && chipletObj[0].DVMVersionSupport > 128){%>
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ctl_chk3             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arctlchk3                ) ,
                            <%}%>
                        <%}%>
                        <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_trace_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].artracechk               ) ,
                        <%}%>                                                                                                                         
                    <%}%>

                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_ready                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rready                    ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_valid                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rvalid                    ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_resp                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rresp                     ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_data                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rdata[<%=bundle.interfaces.axiInt[mpu_io].params.wData - 1%> : 0]                     ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_last                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rlast                     ) ,
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_id                    ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rid                       ) ,
                    <%if (bundle.interfaces.axiInt[mpu_io].params.wRUser > 0){%>
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_user              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].ruser                     ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_user_chk          ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].ruserchk                  ) ,
                        <%}%>
                    <%}%>
                    <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_trace                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rtrace                       ) ,
                    <%}%>
                    <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_ready_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rreadychk                ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_valid_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rvalidchk                ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_resp_chk              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rrespchk                 ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_data_chk              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rdatachk                 ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_last_chk              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rlastchk                 ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_id_chk                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].ridchk                   ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_trace_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rtracechk                ) ,
                        <%}%>                                                                                                                         
                    <%}%>

                    <%if (bundle.interfaces.axiInt[mpu_io].params.wQos>0){%>
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_qos                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awqos                     ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_qos                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arqos                     ) ,
                    <%}%>
                    <%if (bundle.interfaces.axiInt[mpu_io].params.wAwUser > 0){%>
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_user                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awuser                    ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_user_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awuserchk                 ) ,
                        <%}%>
                    <%}%>
                    <%if (bundle.interfaces.axiInt[mpu_io].params.wArUser > 0){%>
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_user                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].aruser                    ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_user_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].aruserchk                 ) ,
                        <%}%>
                    <%}%>
                    <%if (bundle.fnNativeInterface === "ACE-LITE" || bundle.fnNativeInterface === "ACELITE-E"){%>
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_snoop                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awsnoop                   ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_domain               ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awdomain                  ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_bar                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awbar                     ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_snoop                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arsnoop                   ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_domain               ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].ardomain                  ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_bar                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arbar                     ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.eAtomic > 0) { %>
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_atop                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awatop                    ) ,
                        <%}%>                                                                                                                         
                        <%if (bundle.interfaces.axiInt[mpu_io].params.eStash > 0) { %>
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashnid             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awstashnid                ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashniden           ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awstashnid_en              ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashlpid            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awstashlpid               ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashlpiden          ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awstashlpid_en             ) ,
                        <%}%>                                                                                                                         
                        <%if (bundle.interfaces.axiInt[mpu_io].params.eAc > 0){%>
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_snoop                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acsnoop                   ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_addr                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acaddr                    ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_prot                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acprot                    ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_valid                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acvalid                   ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ready                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acready                   ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_ready                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crready                   ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_valid                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crvalid                   ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_resp                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crresp                    ) ,
                            <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_trace                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].actrace                       ) ,
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_trace                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crtrace                       ) ,
                            <%}%>                                                                                                                                  
                            <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_valid_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acvalidchk               ) ,
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ready_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acreadychk               ) ,
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_addr_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acaddrchk                ) ,
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ctl_chk              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acctlchk                ) ,
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_valid_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crvalidchk               ) ,
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_ready_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crreadychk               ) ,
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_resp_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crrespchk                ) ,
                                <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_trace_chk                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].actracechk                       ) ,
                                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_trace_chk                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crtracechk                       ) ,
                                <%}%>                                                                                                                                  
                            <%}%>
                        <%}%>                                                                                                                                    
                    <%}%>
                    <%if (bundle.fnNativeInterface === "ACE" || bundle.fnNativeInterface === "ACE5" ){%>                                                                                  
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_snoop                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awsnoop                   ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_domain               ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awdomain                  ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_bar                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awbar                     ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.eUnique> 0){%>
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_unique               ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awunique                  ) ,
                        <%}%>
                        <%if (bundle.fnNativeInterface === "ACE5" && bundle.interfaces.axiInt[mpu_io].params.eAtomic> 0){%>
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_atop                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].awatop                   ) ,
                        <%}%>
                                                                                                                                        
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_snoop                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arsnoop                   ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_domain               ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].ardomain                  ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_bar                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].arbar                     ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_ack                   ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wack                      ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_ack                   ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rack                      ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_ack_chk               ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].wackchk                   ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_ack_chk               ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].rackchk                   ) ,
                        <%}%>
                                                                                                                                        
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_valid                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acvalid                   ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ready                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acready                   ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_addr                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acaddr                    ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_snoop                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acsnoop                   ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_prot                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acprot                    ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_valid_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acvalidchk               ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ready_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acreadychk               ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_addr_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acaddrchk                ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ctl_chk              ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].acctlchk                ) ,
                        <%}%>
                                                                                                                                                
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_valid                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crvalid                   ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_ready                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crready                   ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_resp                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crresp                    ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_valid_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crvalidchk               ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_ready_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crreadychk               ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_resp_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crrespchk                ) ,
                        <%}%>

                        <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_trace                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].actrace                       ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_trace                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crtrace                       ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_trace                  ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].cdtrace                       ) ,
                        <%}%>
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_valid                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].cdvalid                   ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_ready                ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].cdready                   ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_data                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].cddata                    ) ,
                        .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_last                 ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].cdlast                    ) ,
                        <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_valid_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].cdvalidchk               ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_ready_chk            ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].cdreadychk               ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_data_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].cddatachk                ) ,
                            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_last_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].cdlastchk                ) ,
                            <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_trace_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].actracechk              ) ,
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_trace_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].crtracechk              ) ,
                                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_trace_chk             ( m_axi_if_<%=i%>.master_if[<%=axiidx%>].cdtracechk              ) ,
                            <%}%>
                        <%}%>                                                                                                                                  
                    <%}%>
                    <%axiidx++%>
                <%}%>
            <%}%>                                                                                                                            
        <%});%>

        <%axiidx =0; chipletObj[i].DmiInfo.forEach(function(bundle, idx) { %>
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_ready                ( m_axi_if_<%=i%>.slave_if[<%=idx%>].awready             ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_valid                ( m_axi_if_<%=i%>.slave_if[<%=idx%>].awvalid             ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_id                   ( m_axi_if_<%=i%>.slave_if[<%=idx%>].awid                ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_addr                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].awaddr              ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_burst                ( m_axi_if_<%=i%>.slave_if[<%=idx%>].awburst             ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_len                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].awlen               ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_lock                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].awlock              ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_prot                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].awprot              ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_size                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].awsize              ) ,
            <%if (bundle.interfaces.axiInt.params.wQos>0) { %>                                                                                    
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_qos                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].awqos               ) ,
            <%}%>
            <%if (bundle.interfaces.axiInt.params.wRegion>0){%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_region               ( m_axi_if_<%=i%>.slave_if[<%=idx%>].awregion            ) ,
            <%}%>
            <%if (bundle.interfaces.axiInt.params.wAwUser > 0) { %>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_user                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].awuser              ) ,
            <%}%>
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_cache                ( m_axi_if_<%=i%>.slave_if[<%=idx%>].awcache             ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_ready                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].wready              ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_valid                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].wvalid              ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_data                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].wdata[<%=bundle.interfaces.axiInt.params.wData -1%> : 0]               ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_last                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].wlast               ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_strb                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].wstrb[<%=bundle.interfaces.axiInt.params.wData/8 -1%> : 0]               ) ,
            <%if (bundle.interfaces.axiInt.params.wWUser > 0){%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_user                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].wuser               ) ,
            <%}%>
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_ready                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].bready              ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_valid                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].bvalid              ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_id                    ( m_axi_if_<%=i%>.slave_if[<%=idx%>].bid                 ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_resp                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].bresp               ) ,
            <%if(bundle.interfaces.axiInt.params.wBUser > 0){%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_user                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].buser               ) ,
            <%}%>
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_ready                ( m_axi_if_<%=i%>.slave_if[<%=idx%>].arready             ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_valid                ( m_axi_if_<%=i%>.slave_if[<%=idx%>].arvalid             ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_addr                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].araddr              ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_burst                ( m_axi_if_<%=i%>.slave_if[<%=idx%>].arburst             ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_id                   ( m_axi_if_<%=i%>.slave_if[<%=idx%>].arid                ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_len                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].arlen               ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_lock                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].arlock              ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_prot                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].arprot              ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_size                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].arsize              ) ,
            <%if (bundle.interfaces.axiInt.params.wQos>0) { %>                                                                                    
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_qos                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].arqos               ) ,
            <%}%>
            <%if(bundle.interfaces.axiInt.params.wRegion>0){%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_region               ( m_axi_if_<%=i%>.slave_if[<%=idx%>].arregion            ) ,
            <%}%>                                                                                                                                
            <%if(bundle.interfaces.axiInt.params.wArUser > 0){%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_user                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].aruser              ) ,
            <%}%>
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_cache                ( m_axi_if_<%=i%>.slave_if[<%=idx%>].arcache             ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_id                    ( m_axi_if_<%=i%>.slave_if[<%=idx%>].rid                 ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_resp                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].rresp[1:0]          ) ,
            <%if (bundle.interfaces.axiInt.params.wRUser > 0){%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_user                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].ruser               ) ,
            <%}%>
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_ready                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].rready              ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_valid                 ( m_axi_if_<%=i%>.slave_if[<%=idx%>].rvalid              ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_data                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].rdata[<%=bundle.interfaces.axiInt.params.wData - 1%> : 0]                ) ,
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_last                  ( m_axi_if_<%=i%>.slave_if[<%=idx%>].rlast               ) ,
            <% axiidx++
        });%>

        <% chipletObj[i].DiiInfo.forEach(function(bundle, idx) { %>
            <%if(bundle.configuration == 0){%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_ready                 ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].awready             ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_valid                 ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].awvalid             ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_id                    ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].awid                ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_addr                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].awaddr              ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_burst                 ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].awburst             ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_len                   ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].awlen               ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_lock                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].awlock              ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_prot                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].awprot              ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_size                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].awsize              ) ,
                <%if (bundle.interfaces.axiInt.params.wQos>0){%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_qos                   ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].awqos               ) ,
                <%}%>
                <%if (bundle.interfaces.axiInt.params.wRegion>0){%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_region                ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].awregion            ) ,
                <%}%>
                <%if(bundle.interfaces.axiInt.params.wAwUser > 0){%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_user                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].awuser              ) ,
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_cache                 ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].awcache             ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_ready                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].wready              ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_valid                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].wvalid              ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_data                   ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].wdata[<%=bundle.interfaces.axiInt.params.wData - 1%> : 0]               ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_last                   ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].wlast               ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_strb                   ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].wstrb[<%=bundle.interfaces.axiInt.params.wData/8 - 1%> : 0]               ) ,
                <%if(bundle.interfaces.axiInt.params.wWUser > 0){%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_user                   ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].wuser               ) ,
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_ready                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].bready              ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_valid                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].bvalid              ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_id                     ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].bid                 ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_resp                   ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].bresp               ) ,
                <%if (bundle.interfaces.axiInt.params.wBUser > 0) { %>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_user                   ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].buser               ) ,
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_ready                 ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].arready             ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_valid                 ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].arvalid             ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_addr                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].araddr              ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_burst                 ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].arburst             ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_id                    ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].arid                ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_len                   ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].arlen               ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_lock                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].arlock              ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_prot                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].arprot              ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_size                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].arsize              ) ,
                <%if (bundle.interfaces.axiInt.params.wQos>0) { %>                                                                                     
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_qos                   ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].arqos               ) ,
                <%}%>                                                                                                                                 
                <%if(bundle.interfaces.axiInt.params.wRegion>0) { %>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_region                ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].arregion            ) ,
                <%}%>
                <%if (bundle.interfaces.axiInt.params.wArUser > 0) { %>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_user                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].aruser              ) ,
                <%}%>
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_cache                 ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].arcache             ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_id                     ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].rid                 ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_resp                   ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].rresp[1:0]          ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_ready                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].rready              ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_valid                  ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].rvalid              ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_data                   ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].rdata[<%=bundle.interfaces.axiInt.params.wData - 1%> : 0]               ) ,
                .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_last                   ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].rlast               ) ,
                <%if (bundle.interfaces.axiInt.params.wRUser > 0) { %>                                                                                 
                    .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_user               ( m_axi_if_<%=i%>.slave_if[<%=axiidx+idx%>].ruser               ) ,
                <%}%>
            <%}%>
        <%});%>
        <% chipletObj[0].PmaInfo.forEach(function(bundle, idx) { %>
            // Needs to add PMA interface/agent if support required 
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.masterInt.name%>REQn                  ( 1 ),
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.masterInt.name%>ACTIVE                (   ),
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.masterInt.name%>ACCEPTn               (   ),
            .<%=prefix%><%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.masterInt.name%>DENY                  (   ),
        <%});%>
        <%for(let clock=0; clock < chipletObj[i].Clocks.length; clock++) { %>
            <%if (clock == 0) { %>
                .<%=prefix%><%=chipletObj[0].Clocks[clock].interfaces[Object.keys(chipletObj[0].Clocks[clock].interfaces)[0]].module%>clk      (<%=chipletObj[0].Clocks[clock].name%>clk_<%=i%>                          )
            <%}else{%>
                ,.<%=prefix%><%=chipletObj[0].Clocks[clock].interfaces[Object.keys(chipletObj[0].Clocks[clock].interfaces)[0]].module%>clk      (<%=chipletObj[0].Clocks[clock].name%>clk_<%=i%>                          )
            <%}%>
            ,.<%=prefix%><%=chipletObj[0].Clocks[clock].interfaces[Object.keys(chipletObj[0].Clocks[clock].interfaces)[0]].module%>test_en  (<%=chipletObj[0].Clocks[clock].name%>test_en_<%=i%>                      )
            <% if ( chipletObj[0].Clocks[clock].name.indexOf('check') < 0 ) { %>
                ,.<%=prefix%><%=chipletObj[0].Clocks[clock].interfaces[Object.keys(chipletObj[0].Clocks[clock].interfaces)[0]].module%>reset_n  (<%=chipletObj[0].Clocks[clock].name%>reset_n_<%=i%>                      )
            <%}%>
        <%}%>
        <%if(i<chipletObj.length-1){%>,
        <%}%>
    <%}%>
    );

    <%if(process.env.ENABLE_INTERNAL_CODE && 0){%> //FIXME : Need to enable this later
        <%for(var idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
                <%for(var i = 0; i < chipletObj[0].AiuInfo[idx].nSmiTx; i++) { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_msg_valid      = `AIU<%=idx%>.smi_tx<%=i%>_ndp_msg_valid ;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_msg_ready      = `AIU<%=idx%>.smi_tx<%=i%>_ndp_msg_ready ;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_ndp_len      = `AIU<%=idx%>.smi_tx<%=i%>_ndp_ndp_len ;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_dp_present      = `AIU<%=idx%>.smi_tx<%=i%>_ndp_dp_present;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_targ_id      = `AIU<%=idx%>.smi_tx<%=i%>_ndp_targ_id;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_src_id      = `AIU<%=idx%>.smi_tx<%=i%>_ndp_src_id;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_msg_id      = `AIU<%=idx%>.smi_tx<%=i%>_ndp_msg_id;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_msg_type      = `AIU<%=idx%>.smi_tx<%=i%>_ndp_msg_type;


                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_ndp             = `AIU<%=idx%>.smi_tx<%=i%>_ndp_ndp	   ;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_msg_err         = 'b0	      ;

                <% if(chipletObj[0].AiuInfo[idx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_steer           = `AIU<%=idx%>.smi_tx<%=i%>_ndp_steer	   ;  
                <% } %>

                <% if(chipletObj[0].AiuInfo[idx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_msg_tier        = `AIU<%=idx%>.smi_tx<%=i%>_ndp_msg_tier  ;  
                <% } %>

                <% if(chipletObj[0].AiuInfo[idx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_msg_qos         = `AIU<%=idx%>.smi_tx<%=i%>_ndp_msg_qos   ; 
                <% } else { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_msg_qos         = 'h0                                      ; 
                <% } %>

                <% if(chipletObj[0].AiuInfo[idx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_msg_pri         = `AIU<%=idx%>.smi_tx<%=i%>_ndp_msg_pri   ;  
                <% } %>

                <% if(chipletObj[0].AiuInfo[idx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_msg_user        = `AIU<%=idx%>.smi_tx<%=i%>_ndp_msg_user  ; 
                <% } else { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_msg_user        = 'h0                                      ; 
                <% } %>




                <% if (chipletObj[0].AiuInfo[idx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_dp_valid = `AIU<%=idx%>.smi_tx<%=i%>_dp_valid	   ;  
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_dp_ready = `AIU<%=idx%>.smi_tx<%=i%>_dp_ready	   ;  
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_dp_last  = `AIU<%=idx%>.smi_tx<%=i%>_dp_last	   ;  
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_dp_data  = `AIU<%=idx%>.smi_tx<%=i%>_dp_data	   ;
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_dp_user  = `AIU<%=idx%>.smi_tx<%=i%>_dp_user	   ;  

                <%  } else {  %>
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_dp_valid        = 'b0;  
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if.smi_dp_ready        = 'b0;  
                <%  }  %>



            <% } %>

            <%for(var i = 0; i < chipletObj[0].AiuInfo[idx].nSmiRx; i++) { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_msg_valid       = `AIU<%=idx%>.smi_rx<%=i%>_ndp_msg_valid ;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_msg_ready       = `AIU<%=idx%>.smi_rx<%=i%>_ndp_msg_ready ;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_ndp_len         = `AIU<%=idx%>.smi_rx<%=i%>_ndp_ndp_len ;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_dp_present      = `AIU<%=idx%>.smi_rx<%=i%>_ndp_dp_present ;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_targ_id         = `AIU<%=idx%>.smi_rx<%=i%>_ndp_targ_id ;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_src_id          = `AIU<%=idx%>.smi_rx<%=i%>_ndp_src_id ;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_msg_id          = `AIU<%=idx%>.smi_rx<%=i%>_ndp_msg_id ;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_msg_type        = `AIU<%=idx%>.smi_rx<%=i%>_ndp_msg_type ;



                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_ndp             = `AIU<%=idx%>.smi_rx<%=i%>_ndp_ndp	   ;
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_msg_err         = 'b0	      ;

                <% if(chipletObj[0].AiuInfo[idx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_steer           = `AIU<%=idx%>.smi_rx<%=i%>_ndp_steer	   ;  
                <% } %>

                <% if(chipletObj[0].AiuInfo[idx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_msg_tier        = `AIU<%=idx%>.smi_rx<%=i%>_ndp_msg_tier  ;  
                <% } %>

                <% if(chipletObj[0].AiuInfo[idx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_msg_qos         = `AIU<%=idx%>.smi_rx<%=i%>_ndp_msg_qos   ; 
                <% } else { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_msg_qos         = 'h0                                      ; 
                <% } %>

                <% if(chipletObj[0].AiuInfo[idx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_msg_pri         = `AIU<%=idx%>.smi_rx<%=i%>_ndp_msg_pri   ;  
                <% } %>

                <% if(chipletObj[0].AiuInfo[idx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_msg_user        = `AIU<%=idx%>.smi_rx<%=i%>_ndp_msg_user  ; 
                <% } else { %>
                assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_msg_user        = 'h0                                      ; 
                <% } %>





                <% if (chipletObj[0].AiuInfo[idx].interfaces.smiRxInt[i].params.nSmiDPvc){ %>
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_dp_valid = `AIU<%=idx%>.smi_rx<%=i%>_dp_valid	   ;  
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_dp_ready = `AIU<%=idx%>.smi_rx<%=i%>_dp_ready	   ;  
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_dp_last  = `AIU<%=idx%>.smi_rx<%=i%>_dp_last	   ;  
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_dp_data  = `AIU<%=idx%>.smi_rx<%=i%>_dp_data	   ;
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_dp_user  = `AIU<%=idx%>.smi_rx<%=i%>_dp_user	   ;  

                <%  } else {  %>
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_dp_valid        = 'b0;  
                    assign <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if.smi_dp_ready        = 'b0;  
                <%  }  %>

            <% } %>
        <% } %>
    <%}%>


    <%if(process.env.ENABLE_INTERNAL_CODE && 0 ){%> //FIXME : Need to enable this later
        // DMI
        <%for(var pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
            <%for(var i = 0; i < chipletObj[0].DmiInfo[pidx].nSmiTx; i++) { %>
                assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_valid  = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_valid ;
                assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_ready  = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_ready ;
                assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_ndp_len    = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_ndp_len ;
                assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_present = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_dp_present;
                assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_targ_id    = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_targ_id;
                assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_src_id     = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_src_id;
                assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_id     = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_id;
                assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_type   = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_type;



            assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_ndp             = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_ndp	   ;
            assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_err         = 'b0	      ;

            <% if(chipletObj[0].DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
        	assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_steer           = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_steer	   ;  
            <% } %>

            <% if(chipletObj[0].DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
        	assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_tier        = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_tier  ;  
            <% } %>

            <% if(chipletObj[0].DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
        	assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_qos         = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_qos   ; 
            <% } else { %>
        	assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_qos         = 'h0                                      ; 
            <% } %>

            <% if(chipletObj[0].DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
        	assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_pri         = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_pri   ;  
            <% } %>

            <% if(chipletObj[0].DmiInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
        	assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_user        = `DMI<%=pidx%>.smi_tx<%=i%>_ndp_msg_user  ; 
            <% } else { %>
        	assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_user        = 'h0                                      ; 
            <% } %>


            <% if (chipletObj[0].DmiInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
	            assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_valid = `DMI<%=pidx%>.smi_tx<%=i%>_dp_valid	   ;  
	            assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_ready = `DMI<%=pidx%>.smi_tx<%=i%>_dp_ready	   ;  
	            assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_last  = `DMI<%=pidx%>.smi_tx<%=i%>_dp_last	   ;  
	            assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_data  = `DMI<%=pidx%>.smi_tx<%=i%>_dp_data	   ;
	            assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_user  = `DMI<%=pidx%>.smi_tx<%=i%>_dp_user	   ;  

            <%  } else {  %>
	            assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_valid        = 'b0;  
            	assign dmi<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_ready        = 'b0;  
            <%  }  %>



            <%}%>

            <%for(var i = 0; i < chipletObj[0].DmiInfo[pidx].nSmiRx; i++) { %>
                assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_valid  = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_valid ;
                assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_ready  = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_ready ;
                assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_ndp_len    = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_ndp_len ;
                assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_present = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_dp_present ;
                assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_targ_id    = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_targ_id ;
                assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_src_id     = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_src_id ;
                assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_id     = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_id ;
                assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_type   = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_type ;



            assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_ndp             = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_ndp	   ;
            assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_err         = 'b0	      ;

            <% if(chipletObj[0].DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
        	assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_steer           = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_steer	   ;  
            <% } %>

            <% if(chipletObj[0].DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
        	assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_tier        = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_tier  ;  
            <% } %>

            <% if(chipletObj[0].DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
        	assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_qos         = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_qos   ; 
            <% } else { %>
        	assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_qos         = 'h0                                      ; 
            <% } %>

            <% if(chipletObj[0].DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
        	assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_pri         = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_pri   ;  
            <% } %>

            <% if(chipletObj[0].DmiInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
        	assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_user        = `DMI<%=pidx%>.smi_rx<%=i%>_ndp_msg_user  ; 
            <% } else { %>
        	assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_user        = 'h0                                      ; 
            <% } %>


            <% if (chipletObj[0].DmiInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc){ %>
	            assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_valid = `DMI<%=pidx%>.smi_rx<%=i%>_dp_valid	   ;  
	            assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_ready = `DMI<%=pidx%>.smi_rx<%=i%>_dp_ready	   ;  
	            assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_last  = `DMI<%=pidx%>.smi_rx<%=i%>_dp_last	   ;  
	            assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_data  = `DMI<%=pidx%>.smi_rx<%=i%>_dp_data	   ;
	            assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_user  = `DMI<%=pidx%>.smi_rx<%=i%>_dp_user	   ;  

            <%  } else {  %>
	            assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_valid        = 'b0;  
            	assign dmi<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_ready        = 'b0;  
            <%  }  %>



            <%}%>
        <%}%>

       // DCE
        <%for(var pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) { %>
            <%for(var i = 0; i < chipletObj[0].DceInfo[pidx].nSmiTx; i++) { %>
                assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_valid  = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_valid ;
                assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_ready  = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_ready ;
                assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_ndp_len    = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_ndp_len ;
                assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_present = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_dp_present;
                assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_targ_id    = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_targ_id;
                assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_src_id     = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_src_id;
                assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_id     = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_id;
                assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_type   = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_type;



            assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_ndp             = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_ndp	   ;
            assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_err         = 'b0	      ;

            <% if(chipletObj[0].DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
        	assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_steer           = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_steer	   ;  
            <% } %>

            <% if(chipletObj[0].DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
        	assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_tier        = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_tier  ;  
            <% } %>

            <% if(chipletObj[0].DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
        	assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_qos         = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_qos   ; 
            <% } else { %>
        	assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_qos         = 'h0                                      ; 
            <% } %>

            <% if(chipletObj[0].DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
        	assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_pri         = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_pri   ;  
            <% } %>

            <% if(chipletObj[0].DceInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
        	assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_user        = `DCE<%=pidx%>.smi_tx<%=i%>_ndp_msg_user  ; 
            <% } else { %>
        	assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_user        = 'h0                                      ; 
            <% } %>


           <% if (chipletObj[0].DceInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
	            assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_valid = `DCE<%=pidx%>.smi_tx<%=i%>_dp_valid	   ;  
	            assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_ready = `DCE<%=pidx%>.smi_tx<%=i%>_dp_ready	   ;  
	            assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_last  = `DCE<%=pidx%>.smi_tx<%=i%>_dp_last	   ;  
	            assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_data  = `DCE<%=pidx%>.smi_tx<%=i%>_dp_data	   ;
	            assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_user  = `DCE<%=pidx%>.smi_tx<%=i%>_dp_user	   ;  

            <%  } else {  %>
	            assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_valid        = 'b0;  
            	assign dce<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_ready        = 'b0;  
            <%  }  %>



            <%}%>

            <%for(var i = 0; i < chipletObj[0].DceInfo[pidx].nSmiRx; i++) { %>
                assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_valid  = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_valid ;
                assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_ready  = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_ready ;
                assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_ndp_len    = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_ndp_len ;
                assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_present = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_dp_present ;
                assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_targ_id    = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_targ_id ;
                assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_src_id     = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_src_id ;
                assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_id     = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_id ;
                assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_type   = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_type ;


            assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_ndp             = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_ndp	   ;
            assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_err         = 'b0	      ;

            <% if(chipletObj[0].DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
        	    assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_steer           = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_steer	   ;  
            <% } %>

            <% if(chipletObj[0].DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
        	    assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_tier        = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_tier  ;  
            <% } %>

            <% if(chipletObj[0].DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
        	    assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_qos         = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_qos   ; 
            <% } else { %>
        	    assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_qos         = 'h0                                      ; 
            <%}%>

            <% if(chipletObj[0].DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
        	assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_pri         = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_pri   ;  
            <% } %>

            <% if(chipletObj[0].DceInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
        	assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_user        = `DCE<%=pidx%>.smi_rx<%=i%>_ndp_msg_user  ; 
            <% } else { %>
        	assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_user        = 'h0                                      ; 
            <% } %>



           <% if (chipletObj[0].DceInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc){ %>
	            assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_valid = `DCE<%=pidx%>.smi_rx<%=i%>_dp_valid	   ;  
	            assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_ready = `DCE<%=pidx%>.smi_rx<%=i%>_dp_ready	   ;  
	            assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_last  = `DCE<%=pidx%>.smi_rx<%=i%>_dp_last	   ;  
	            assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_data  = `DCE<%=pidx%>.smi_rx<%=i%>_dp_data	   ;
	            assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_user  = `DCE<%=pidx%>.smi_rx<%=i%>_dp_user	   ;  

            <%  } else {  %>
	            assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_valid        = 'b0;  
            	assign dce<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_ready        = 'b0;  
            <%  }  %>



            <%}%>
        <%}%>

        // DII
        <%for(var pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) { %>
            <%for(var i = 0; i < chipletObj[0].DiiInfo[pidx].nSmiTx; i++) { %>
                assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_valid  = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_valid ;
                assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_ready  = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_ready ;
                assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_ndp_len    = `DII<%=pidx%>.smi_tx<%=i%>_ndp_ndp_len ;
                assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_present = `DII<%=pidx%>.smi_tx<%=i%>_ndp_dp_present;
                assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_targ_id    = `DII<%=pidx%>.smi_tx<%=i%>_ndp_targ_id;
                assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_src_id     = `DII<%=pidx%>.smi_tx<%=i%>_ndp_src_id;
                assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_id     = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_id;
                assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_type   = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_type;



            assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_ndp             = `DII<%=pidx%>.smi_tx<%=i%>_ndp_ndp	   ;
            assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_err         = 'b0	      ;

            <% if(chipletObj[0].DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiSteer > 0) { %>
        	assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_steer           = `DII<%=pidx%>.smi_tx<%=i%>_ndp_steer	   ;  
            <% } %>

            <% if(chipletObj[0].DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiTier > 0) { %>
        	assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_tier        = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_tier  ;  
            <% } %>

            <% if(chipletObj[0].DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiQos > 0) { %>
        	assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_qos         = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_qos   ; 
            <% } else { %>
        	assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_qos         = 'h0                                      ; 
            <% } %>

            <% if(chipletObj[0].DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiPri > 0) { %>
        	assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_pri         = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_pri   ;  
            <% } %>

            <% if(chipletObj[0].DiiInfo[pidx].interfaces.smiTxInt[i].params.wSmiUser > 0) { %>
        	assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_user        = `DII<%=pidx%>.smi_tx<%=i%>_ndp_msg_user  ; 
            <% } else { %>
        	assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_msg_user        = 'h0                                      ; 
            <% } %>






           <% if (chipletObj[0].DiiInfo[pidx].interfaces.smiTxInt[i].params.nSmiDPvc){ %>
	            assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_valid = `DII<%=pidx%>.smi_tx<%=i%>_dp_valid	   ;  
	            assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_ready = `DII<%=pidx%>.smi_tx<%=i%>_dp_ready	   ;  
	            assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_last  = `DII<%=pidx%>.smi_tx<%=i%>_dp_last	   ;  
	            assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_data  = `DII<%=pidx%>.smi_tx<%=i%>_dp_data	   ;
	            assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_user  = `DII<%=pidx%>.smi_tx<%=i%>_dp_user	   ;  

            <%  } else {  %>
	            assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_valid        = 'b0;  
            	assign dii<%=pidx%>_smi<%=i%>_rx_port_if.smi_dp_ready        = 'b0;  
            <%  }  %>




            <%}%>

            <%for(var i = 0; i < chipletObj[0].DiiInfo[pidx].nSmiRx; i++) { %>
                assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_valid  = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_valid ;
                assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_ready  = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_ready ;
                assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_ndp_len    = `DII<%=pidx%>.smi_rx<%=i%>_ndp_ndp_len ;
                assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_present = `DII<%=pidx%>.smi_rx<%=i%>_ndp_dp_present ;
                assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_targ_id    = `DII<%=pidx%>.smi_rx<%=i%>_ndp_targ_id ;
                assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_src_id     = `DII<%=pidx%>.smi_rx<%=i%>_ndp_src_id ;
                assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_id     = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_id ;
                assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_type   = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_type ;


            assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_ndp             = `DII<%=pidx%>.smi_rx<%=i%>_ndp_ndp	   ;
            assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_err         = 'b0	      ;

            <% if(chipletObj[0].DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiSteer > 0) { %>
        	assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_steer           = `DII<%=pidx%>.smi_rx<%=i%>_ndp_steer	   ;  
            <% } %>

            <% if(chipletObj[0].DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiTier > 0) { %>
        	assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_tier        = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_tier  ;  
            <% } %>

            <% if(chipletObj[0].DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiQos > 0) { %>
        	assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_qos         = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_qos   ; 
            <% } else { %>
        	assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_qos         = 'h0                                      ; 
            <% } %>

            <% if(chipletObj[0].DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiPri > 0) { %>
        	assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_pri         = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_pri   ;  
            <% } %>

            <% if(chipletObj[0].DiiInfo[pidx].interfaces.smiRxInt[i].params.wSmiUser > 0) { %>
        	assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_user        = `DII<%=pidx%>.smi_rx<%=i%>_ndp_msg_user  ; 
            <% } else { %>
        	assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_msg_user        = 'h0                                      ; 
            <% } %>




           <% if (chipletObj[0].DiiInfo[pidx].interfaces.smiRxInt[i].params.nSmiDPvc){ %>
	            assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_valid = `DII<%=pidx%>.smi_rx<%=i%>_dp_valid	   ;  
	            assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_ready = `DII<%=pidx%>.smi_rx<%=i%>_dp_ready	   ;  
	            assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_last  = `DII<%=pidx%>.smi_rx<%=i%>_dp_last	   ;  
	            assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_data  = `DII<%=pidx%>.smi_rx<%=i%>_dp_data	   ;
	            assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_user  = `DII<%=pidx%>.smi_rx<%=i%>_dp_user	   ;  

            <%  } else {  %>
	            assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_valid        = 'b0;  
            	assign dii<%=pidx%>_smi<%=i%>_tx_port_if.smi_dp_ready        = 'b0;  
            <%  }  %>




            <%}%>
        <%}%>
    <%}%>

    //assertion to check DECERR/SLVERR
    /*
    always @(posedge ncore_system_tb_top.sys_clk) begin
        <%let ioidx_a=0;%>
        <%for(let i=0; i<chipletObj.length; i+=1){%>
            <%for(let idx = 0; idx < chipletObj[i].nAIUs; idx++) { %>
                <%if(!(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                    <%for (let mpu_io = 0; mpu_io < chipletObj[0].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                        assert ((m_axi_if_<%=i%>.master_if[<%=ioidx_a%>].bresp) != 2'b11)
                        else begin
                            $warning("DECERR detected(BRESP)! Warning issued.");
                        end
                        assert ((m_axi_if_<%=i%>.master_if[<%=ioidx_a%>].bresp) != 2'b10)
                        else begin
                            $warning("SLVERR detected(BRESP)! Warning issued.");
                        end
                        assert ((m_axi_if_<%=i%>.master_if[<%=ioidx_a%>].rresp) != 2'b11)
                        else begin
                            $warning("DECERR detected(RRESP)! Warning issued.");
                        end
                        assert ((m_axi_if_<%=i%>.master_if[<%=ioidx_a%>].rresp) != 2'b10)
                        else begin
                            $warning("SLVERR detected(RRESP)! Warning issued.");
                        end
                        <%ioidx_a++;%>
                    <%}%>
                <%}%>
            <%}%>
        <%}%>
    end
    */

    initial begin
        $timeformat(-9,0,"ns",0);
        ma = mem_agent::get();
        obj = new;
        ma.generate_memory_regions();
        ma.print_all_chiplets_region_table();

        //chipletObj[0].update_params(); // CHECK
        <%for(let i=0; i<chipletObj.length; i+=1){%>
            <%if(chipletObj[i].useResiliency == 1){%>
                //uvm_config_db #(virtual svt_apb_if)::set(uvm_root::get(),"uvm_test_top.m_env.m_amba_env.apb_system[0]","vif",m_fsc_apb_if);
                mission_fault_detected_<%=i%> = new("mission_fault_detected_<%=i%>");
                uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                        .inst_name( "" ),
                                        .field_name( "mission_fault_detected_<%=i%>" ),
                                        .value(mission_fault_detected_<%=i%>));
            
            <%}%>
        <%}%>
        <%for(let i=0; i<chipletObj.length; i+=1){%>
            uvm_config_db #(virtual svt_chi_if)::set(uvm_root::get(),"uvm_test_top.m_env.m_amba_env.chi_system[<%=i%>]","vif",m_svt_chi_if_<%=i%>);
        <%}%>

        <%if(process.env.ENABLE_INTERNAL_CODE && 0){%> //FIXME: Need to enable this later
            uvm_config_db #(virtual ncore_clk_if)::set(uvm_root::get(),"uvm_test_top.m_env.m_perf_analyzer","vif",m_clk_if_<%=chipletObj[0].Clocks[0].name%>);

            <%for(var idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
                <%for (var i = 0; i < chipletObj[0].AiuInfo[idx].smiPortParams.tx.length; i++) { %>
                    uvm_config_db #(virtual smi_if)::set(uvm_root::get(),
                                                        "uvm_test_top.m_env",
                                                        "<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if",
                                                        <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_tx_port_if);
                <%}%>
                <%for (var i = 0; i < chipletObj[0].AiuInfo[idx].smiPortParams.rx.length; i++) { %>
                    uvm_config_db #(virtual smi_if)::set(uvm_root::get(),
                                                        "uvm_test_top.m_env",
                                                        "<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if",
                                                        <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_smi<%=i%>_rx_port_if);
                <%}%>
            <%}%>

            // DMI
            <%for(var pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
                <%for (var i = 0; i < chipletObj[0].DmiInfo[pidx].smiPortParams.tx.length; i++) { %>
                    uvm_config_db #(virtual smi_if)::set(uvm_root::get(),
                                                        "uvm_test_top.m_env",
                                                        "dmi<%=pidx%>_smi<%=i%>_tx_port_if",
                                                        dmi<%=pidx%>_smi<%=i%>_tx_port_if);
                <%}%>
                <%for (var i = 0; i < chipletObj[0].DmiInfo[pidx].smiPortParams.rx.length; i++) { %>
                    uvm_config_db #(virtual smi_if)::set(uvm_root::get(),
                                                        "uvm_test_top.m_env",
                                                        "dmi<%=pidx%>_smi<%=i%>_rx_port_if",
                                                        dmi<%=pidx%>_smi<%=i%>_rx_port_if);
                <%}%>
            <%}%>

            // DCE
            <%for(var pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) { %>
                <%for (var i = 0; i < chipletObj[0].DceInfo[pidx].smiPortParams.tx.length; i++) { %>
                    uvm_config_db #(virtual smi_if)::set(uvm_root::get(),
                                                        "uvm_test_top.m_env",
                                                        "dce<%=pidx%>_smi<%=i%>_tx_port_if",
                                                        dce<%=pidx%>_smi<%=i%>_tx_port_if);
                <%}%>
                <%for (var i = 0; i < chipletObj[0].DceInfo[pidx].smiPortParams.rx.length; i++) { %>
                    uvm_config_db #(virtual smi_if)::set(uvm_root::get(),
                                                        "uvm_test_top.m_env",
                                                        "dce<%=pidx%>_smi<%=i%>_rx_port_if",
                                                        dce<%=pidx%>_smi<%=i%>_rx_port_if);
                <%}%>
            <%}%>

            // DII
            <%for(var pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) { %>
                <%for (var i = 0; i < chipletObj[0].DiiInfo[pidx].smiPortParams.tx.length; i++) { %>
                    uvm_config_db #(virtual smi_if)::set(uvm_root::get(),
                                                        "uvm_test_top.m_env",
                                                        "dii<%=pidx%>_smi<%=i%>_tx_port_if",
                                                        dii<%=pidx%>_smi<%=i%>_tx_port_if);
                <%}%>
                <%for (var i = 0; i < chipletObj[0].DiiInfo[pidx].smiPortParams.rx.length; i++) { %>
                    uvm_config_db #(virtual smi_if)::set(uvm_root::get(),
                                                        "uvm_test_top.m_env",
                                                        "dii<%=pidx%>_smi<%=i%>_rx_port_if",
                                                        dii<%=pidx%>_smi<%=i%>_rx_port_if);
                <%}%>
            <%}%>
        <%}%>

        <% var apb_sys = 0; %>
        <%for(let i=0; i<chipletObj.length; i+=1){%>
            uvm_config_db #(virtual svt_axi_if)::set(uvm_root::get(),"uvm_test_top.m_env.m_amba_env.axi_system[<%=i%>]","vif",m_axi_if_<%=i%>);

           //FIXME : apb interface
            <%if(chipletObj[i].useResiliency == 1){%>
                uvm_config_db #(virtual svt_apb_if)::set(uvm_root::get(),"uvm_test_top.m_env.m_amba_env.apb_system[<%=apb_sys%>]","vif",m_fsc_apb_if_<%=i%>);
                <%apb_sys++%>
            <%} if(chipletObj[i].DebugApbInfo.length>0){%>
                uvm_config_db #(virtual svt_apb_if)::set(uvm_root::get(),"uvm_test_top.m_env.m_amba_env.apb_system[<%=apb_sys%>]","vif",m_apb_debug_if_<%=i%>);
                <%apb_sys++%>
            <%}%>
        <%}%>
        
        <%for(let i=0; i<chipletObj.length; i+=1){%>
            <%for(var idx = 0; idx < chipletObj[i].nAIUs; idx++){ %>
                uvm_config_db#(virtual ncore_irq_if)::set(.cntxt( null ),
                                                    .inst_name( "" ),
                                                    .field_name( "m_irq_<%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=i%>_if" ),
                                                    .value(m_irq_<%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=i%>_if));
            <%}%>
            <%for(var idx = 0; idx < chipletObj[i].nDMIs; idx++){ %>
                uvm_config_db#(virtual ncore_irq_if)::set(.cntxt( null ),
                                                    .inst_name( "" ),
                                                    .field_name( "m_irq_<%=chipletObj[i].DmiInfo[idx].strRtlNamePrefix%>_<%=i%>_if" ),
                                                    .value(m_irq_<%=chipletObj[i].DmiInfo[idx].strRtlNamePrefix%>_<%=i%>_if));
            <%}%>
            <%for(var idx = 0; idx < chipletObj[i].nDIIs; idx++){ %>
                uvm_config_db#(virtual ncore_irq_if)::set(.cntxt( null ),
                                                    .inst_name( "" ),
                                                    .field_name( "m_irq_<%=chipletObj[i].DiiInfo[idx].strRtlNamePrefix%>_<%=i%>_if" ),
                                                    .value(m_irq_<%=chipletObj[i].DiiInfo[idx].strRtlNamePrefix%>_<%=i%>_if));
            <%}%>
            <%for(var idx = 0; idx < chipletObj[i].nDVEs; idx++){ %>
                uvm_config_db#(virtual ncore_irq_if)::set(.cntxt( null ),
                                                    .inst_name( "" ),
                                                    .field_name( "m_irq_<%=chipletObj[i].DveInfo[idx].strRtlNamePrefix%>_<%=i%>_if" ),
                                                    .value(m_irq_<%=chipletObj[i].DveInfo[idx].strRtlNamePrefix%>_<%=i%>_if));
            <%}%>
            <%for(var idx = 0; idx < chipletObj[i].nDCEs; idx++){ %>
                uvm_config_db#(virtual ncore_irq_if)::set(.cntxt( null ),
                                                    .inst_name( "" ),
                                                    .field_name( "m_irq_<%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>_<%=i%>_if" ),
                                                    .value(m_irq_<%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>_<%=i%>_if));
            <%}%>
        <%}%>
        `ifdef DUMP_ON
            if($test$plusargs("en_dump")) begin
                <%if(chipletObj[0].CDN){%>
                    <%if(chipletObj[0].enInternalCode){%>
                        $vcdpluson;
                    <%}else{%>
                        $shm_open ( "waves.shm" ) ;
                        $shm_probe ( "ACMS" ) ;
                    <%}%>
                <%}else{%>
                    $fsdbDumpvars("+all");
                    $vcdpluson;
                <%}%>
            end
        `endif
        run_test("ncore_base_test");
        $finish;
    end

    assign dut_clk = sys_clk_0; //FIXME
    assign soft_rstn = sys_rstn;

    <%for(let i=0; i<chipletObj.length; i++){%>
        <%if(chipletObj[i].useResiliency == 1){%>
            always @(posedge m_fsc_master_fault_<%=i%>.mission_fault) begin
                $display("it_is_here_tb_top_01");
                if(m_fsc_master_fault_<%=i%>.mission_fault === 1'b1) begin
                mission_fault_detected_<%=i%>.trigger();
                $display("triggered mission_fault_detected_<%=i%> @time: %0t",$time);
                end
            end
        <%}%>
    <%}%>

    <%if(chipletObj[0].useResiliency){%>
        fsys_fault_injector_checker fault_injector_checker(
            <%for(var clock=0; clock < chipletObj[0].Clocks.length; clock++){%>
                <%if(chipletObj[0].Clocks[clock].name.includes("_check") == false){%>
                    <%=chipletObj[0].Clocks[clock].name%>clk,  
                <%}%>
            <%}%>
        soft_rstn);
    <%}%>

    //-----------------------------------------------------------------------------
    // Generate clocks and reset
    //-----------------------------------------------------------------------------
    <%for(let i=0; i<chipletObj.length; i+=1){%>
        <%for(var clock=0; clock < chipletObj[i].Clocks.length; clock++) { %>
            ncore_clk_rst_module <%=chipletObj[i].Clocks[clock].name%><%=i%>_gen(.clk_fr(m_clk_if_<%=chipletObj[i].Clocks[clock].name%><%=i%>.clk), .clk_tb(<%=chipletObj[i].Clocks[clock].name%>clk_sync_<%=i%>), .rst(m_clk_if_<%=chipletObj[i].Clocks[clock].name%><%=i%>.reset_n));
            defparam <%=chipletObj[i].Clocks[clock].name%><%=i%>_gen.CLK_PERIOD = <%=chipletObj[i].Clocks[clock].params.period%>;
        <%}%>
  
    // Use first customer defined clock as sys_clk. Customer needs to confirm to this
            assign sys_clk_<%=i%>  = m_clk_if_<%=chipletObj[0].Clocks[0].name%><%=i%>.clk; //FIXME : two systemclk required?
            assign sys_rstn_<%=i%> = m_clk_if_<%=chipletObj[0].Clocks[0].name%><%=i%>.reset_n;
    <%}%>

endmodule: ncore_system_tb_top

//-----------------------------------------------------------
/** Test specific method to read performance metrics from agents */
//-----------------------------------------------------------
function void retrieve_perf_metrics(string msg_id_str, svt_chi_rn_agent my_agent, int unsigned perf_rec_interval, int unsigned master_id,int rd,int wr);
    svt_chi_transaction out_xacts[$];
    real  outvalue;

    // Retrieve rn%0d metrics
    `uvm_info(msg_id_str, "perf_tracking:: rn performance metrics ::", UVM_NONE)

    `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d Latency Unit: %0s  Throughput unit:%0s ", master_id, my_agent.perf_status.get_unit_for_latency_metrics(), my_agent.perf_status.get_unit_for_throughput_metrics()), UVM_NONE)

    if(wr==1)begin
        outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::MAX_WRITE_LATENCY, out_xacts, 1, perf_rec_interval);
        `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d max wr latency %0f", master_id, outvalue), UVM_NONE)
        if (out_xacts.size())
            `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d max wr latency xact %0s", master_id,`SVT_CHI_PRINT_PREFIX(out_xacts[0])), UVM_LOW)

        outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::MIN_WRITE_LATENCY, out_xacts, 1, perf_rec_interval);
        `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d min wr latency %0f", master_id, outvalue), UVM_NONE)
        if (out_xacts.size())
            `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d min wr latency xact %0s", master_id, `SVT_CHI_PRINT_PREFIX(out_xacts[0])), UVM_LOW)

        outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::AVG_WRITE_LATENCY, out_xacts, , perf_rec_interval);
        `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d avg wr latency %0f", master_id, outvalue), UVM_NONE)

        outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::WRITE_THROUGHPUT, out_xacts, ,perf_rec_interval);
        `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d wr throughput %0f", master_id, outvalue), UVM_NONE)
    end

    if(rd==1)begin
        outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::MAX_READ_LATENCY, out_xacts, 1, perf_rec_interval);
        `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d max rd latency %0f", master_id, outvalue), UVM_NONE)
        if (out_xacts.size())
            `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d max rd latency xact %0s", master_id,`SVT_CHI_PRINT_PREFIX(out_xacts[0])), UVM_LOW)

        outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::MIN_READ_LATENCY, out_xacts, 1, perf_rec_interval);
        `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d min rd latency %0f", master_id, outvalue), UVM_NONE)
        if (out_xacts.size())
            `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d min rd latency xact %0s", master_id, `SVT_CHI_PRINT_PREFIX(out_xacts[0])), UVM_LOW)

        outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::AVG_READ_LATENCY, out_xacts, , perf_rec_interval);
        `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d avg rd latency %0f", master_id, outvalue), UVM_NONE)

        outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::READ_THROUGHPUT, out_xacts, ,perf_rec_interval);
        `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d rd throughput %0f", master_id, outvalue), UVM_NONE)
    end

endfunction // retrieve_perf_metrics
