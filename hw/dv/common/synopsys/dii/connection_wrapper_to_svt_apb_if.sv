`timescale 1 ns/1 ps

`ifdef USE_VIP_SNPS
<% if (obj.testBench == "dii") { %>

module <%=obj.BlockId%>_connection_wrapper_to_svt_apb_if ( <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_apb_if inhouse_apb_if, svt_apb_if snps_apb_if );

    assign inhouse_apb_if.paddr = snps_apb_if.paddr;
    assign inhouse_apb_if.psel = snps_apb_if.psel;
    assign inhouse_apb_if.penable = snps_apb_if.penable;
    assign inhouse_apb_if.pwrite = snps_apb_if.pwrite;
    assign inhouse_apb_if.pwdata = snps_apb_if.pwdata;
    assign snps_apb_if.slave_if[0].pready = inhouse_apb_if.pready;
    assign snps_apb_if.slave_if[0].prdata = inhouse_apb_if.prdata;
    assign snps_apb_if.slave_if[0].pslverr = inhouse_apb_if.pslverr;
    <%  if(obj.DiiInfo[obj.Id].interfaces.apbInt.params.wProt !== 0) { %>
    assign inhouse_apb_if.pprot = {snps_apb_if.pprot[2], 1'b0, snps_apb_if.pprot[0]}; // Normal - 0 or Privelege - 1;
    <% } %>
    <%  if(obj.DiiInfo[obj.Id].interfaces.apbInt.params.wStrb !== 0) { %>
    assign inhouse_apb_if.pstrb = snps_apb_if.pstrb;
    <% } %>

endmodule

<% } %>
`endif
