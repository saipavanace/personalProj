
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

/**
 * Abstract:
 * Defines an interface that provides access to a internal signal of DUT .This
 */

`ifndef GUARD_CHI_AIU_DUT_PROBE_IF_SV
`define GUARD_CHI_AIU_DUT_PROBE_IF_SV

<% 
var NSMIIFTX = obj.nSmiRx;
%>

interface chi_aiu_dut_probe_if (input clk, input resetn);

    logic [<%=obj.AiuInfo[obj.Id].cmpInfo.nOttCtrlEntries%> + <%=obj.AiuInfo[obj.Id].cmpInfo.nStshSnpInFlight%> - 1:0] ott_entry_validvec;
    <%if(obj.AiuInfo[obj.Id].cmpInfo.nSnpInFlight + obj.AiuInfo[obj.Id].cmpInfo.nDvmSnpInFlight - 1 > 128) {%>
    logic [127:0]     stt_entry_validvec;
    logic [<%=obj.AiuInfo[obj.Id].cmpInfo.nSnpInFlight%> + <%=obj.AiuInfo[obj.Id].cmpInfo.nDvmSnpInFlight%> - 1 - 128:0]     stt_skid_buffer;
    logic stt_skid_buffer_full;
    <%}else{%>
    logic [<%=obj.AiuInfo[obj.Id].cmpInfo.nSnpInFlight%> + <%=obj.AiuInfo[obj.Id].cmpInfo.nDvmSnpInFlight%> - 1:0]     stt_entry_validvec;
    <%}%>
    logic starv_mode;
    //logic clk;

    `ifdef CHI_SUBSYS // This is a dirty code to support CHI SUBSYS - will be removed in 3.8 - Sai
        logic str_req_vld;
        logic str_req_rdy;
        logic[7:0] str_req_cmstatus;
        logic valid_str_req;

        logic dtr_req_rx_vld;
        logic dtr_req_rx_rdy;
        logic[7:0] dtr_req_rx_cmstatus;
        logic valid_dtr_rx_req;
    `endif

    <%if(obj.testBench == 'chi_aiu') {%>
        assign ott_entry_validvec = tb_top.dut.unit.ott_top.entry_validvec;
        assign stt_entry_validvec = tb_top.dut.unit.stt_top.entry_validvec;
    <%if(obj.AiuInfo[obj.Id].cmpInfo.nSnpInFlight + obj.AiuInfo[obj.Id].cmpInfo.nDvmSnpInFlight - 1 > 128) {%>
        assign stt_skid_buffer_full = tb_top.dut.unit.stt_top.snp_req_skid_buffer.input_fifo.fifo.full;
    <%}%>
        <% if (obj.AiuInfo[obj.Id].fnEnableQos) { %>
            assign starv_mode         = tb_top.dut.unit.ott_top.starv_mode;
        <%}%>
    <%}else{%>

    <%}%>

    `ifdef CHI_SUBSYS
        function force_strreq(bit[7:0] val);
            force tb_top.dut.caiu1.smi_rx0_ndp_ndp[15:8] = val;
        endfunction: force_strreq

<%for(let i=0; i< obj.nCHIs; i++) {%>
      <% for (var j = 0; j < NSMIIFTX; j++) { %>
        function force_smi<%=j%>_cmstatus_strreq_chiaiu<%=i%>(bit[7:0] val);
            force tb_top.dut.caiu<%=i%>.smi_rx<%=j%>_ndp_ndp[15:8] = val;
        endfunction: force_smi<%=j%>_cmstatus_strreq_chiaiu<%=i%>
      <% } %>
    <%}%>

    <%for(let i=0; i< obj.nCHIs; i++) {%>
      <% for (var j = 0; j < NSMIIFTX; j++) { %>
        function force_smi<%=j%>_dtwrsp_chiaiu<%=i%>(bit[7:0] val);
            force tb_top.dut.caiu<%=i%>.smi_rx<%=j%>_ndp_ndp[15:8] = val;
        endfunction: force_smi<%=j%>_dtwrsp_chiaiu<%=i%>
      <% } %>
    <%}%>

    <%for(let i=0; i< obj.nCHIs; i++) {%>
      <% for (var j = 0; j < NSMIIFTX; j++) { %>
        function force_smi<%=j%>_dtrreq_chiaiu<%=i%>(bit[7:0] val);
            force tb_top.dut.caiu<%=i%>.smi_rx<%=j%>_ndp_ndp[15:8] = val;
        endfunction: force_smi<%=j%>_dtrreq_chiaiu<%=i%>
      <% } %>
    <%}%>

     <%for(let i=0; i< obj.nCHIs; i++) {%>
      <% for (var j = 0; j < NSMIIFTX; j++) { %>
        function force_smi<%=j%>_cmprsp_chiaiu<%=i%>(bit[7:0] val);
            force tb_top.dut.caiu<%=i%>.smi_rx<%=j%>_ndp_ndp[15:8] = val;
        endfunction: force_smi<%=j%>_cmprsp_chiaiu<%=i%>
      <% } %>
    <%}%>

    <%for(let i=0; i< obj.nCHIs; i++) {%>
      <% for (var j = 0; j < NSMIIFTX; j++) { %>
        function release_smi<%=j%>_dtwrsp_chiaiu<%=i%>();
            release tb_top.dut.caiu<%=i%>.smi_rx<%=j%>_ndp_ndp;
        endfunction: release_smi<%=j%>_dtwrsp_chiaiu<%=i%>
      <% } %>
    <%}%>

    <%for(let i=0; i< obj.nCHIs; i++) {%>
      <% for (var j = 0; j < NSMIIFTX; j++) { %>
        function release_smi<%=j%>_dtrreq_chiaiu<%=i%>();
            release tb_top.dut.caiu<%=i%>.smi_rx<%=j%>_ndp_ndp;
        endfunction: release_smi<%=j%>_dtrreq_chiaiu<%=i%>
      <% } %>
    <%}%>
      
    <%for(let i=0; i< obj.nCHIs; i++) {%>
      <% for (var j = 0; j < NSMIIFTX; j++) { %>
        function release_smi<%=j%>_cmprsp_chiaiu<%=i%>();
            release tb_top.dut.caiu<%=i%>.smi_rx<%=j%>_ndp_ndp;
        endfunction: release_smi<%=j%>_cmprsp_chiaiu<%=i%>
      <% } %>
    <%}%>

    <%for(let i=0; i< obj.nCHIs; i++) {%>
      <% for (var j = 0; j < NSMIIFTX; j++) { %>
        function release_smi<%=j%>_cmstatus_strreq_chiaiu<%=i%>();
            release tb_top.dut.caiu<%=i%>.smi_rx<%=j%>_ndp_ndp;
        endfunction: release_smi<%=j%>_cmstatus_strreq_chiaiu<%=i%>
      <% } %>
    <%}%>

        function release_strreq();
            release tb_top.dut.caiu1.smi_rx0_ndp_ndp;
        endfunction: release_strreq

        function force_dtrreq(bit[7:0] val);
            force tb_top.dut.caiu1.smi_rx2_ndp_ndp[15:8] = val;
        endfunction: force_dtrreq

        function release_dtrreq();
            release tb_top.dut.caiu1.smi_rx2_ndp_ndp;
        endfunction: release_dtrreq
        
        function disable_dtrreq();
            force tb_top.dut.caiu1.smi_rx2_ndp_msg_valid = 0;
        endfunction: disable_dtrreq

        function enable_dtrreq();
            release tb_top.dut.caiu1.smi_rx2_ndp_msg_valid;
        endfunction: enable_dtrreq

    `endif

endinterface

`endif // GUARD_CHI_AIU_DUT_PROBE_IF_SV
