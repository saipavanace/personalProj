`timescale 1 ns/1 ps

`ifdef USE_VIP_SNPS_APB
<% if (obj.testBench == "fsys") { %>

module connection_wrapper_to_svt_apb_if ( apb_debug_apb_if m_apb_debug_ncore_debug_atu_if, svt_apb_if snps_apb_if );

    assign m_apb_debug_ncore_debug_atu_if.paddr = snps_apb_if.paddr;
    assign m_apb_debug_ncore_debug_atu_if.psel = snps_apb_if.psel;
    assign m_apb_debug_ncore_debug_atu_if.penable = snps_apb_if.penable;
    assign m_apb_debug_ncore_debug_atu_if.pwrite = snps_apb_if.pwrite;
    assign m_apb_debug_ncore_debug_atu_if.pwdata = snps_apb_if.pwdata;
    assign snps_apb_if.slave_if[0].pready = m_apb_debug_ncore_debug_atu_if.pready;
    assign snps_apb_if.slave_if[0].prdata = m_apb_debug_ncore_debug_atu_if.prdata;
    assign snps_apb_if.slave_if[0].pslverr = m_apb_debug_ncore_debug_atu_if.pslverr;
    <%  if(obj.DebugApbInfo[0].interfaces.apbInterface.params.wProt !== 0) { %>
             assign m_apb_debug_ncore_debug_atu_if.pprot = {snps_apb_if.pprot[2], 1'b0, snps_apb_if.pprot[0]}; // Normal - 0 or Privelege - 1
            //  assign m_apb_debug_ncore_debug_atu_if.pprot[1] = 1'b0; // Always Secure Mode access
            //  assign m_apb_debug_ncore_debug_atu_if.pprot[2] = snps_apb_if.pprot[2]; // Data - 0 or Instruction - 1
    <% } %>
    <%  if(obj.DebugApbInfo[0].interfaces.apbInterface.params.wStrb !== 0) { %>
            assign m_apb_debug_ncore_debug_atu_if.pstrb = snps_apb_if.pstrb;
    <% } %>

endmodule

<% } %>
`endif
