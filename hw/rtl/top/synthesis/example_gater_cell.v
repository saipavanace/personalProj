<% if (voltageRegions.length <= 1) { %>
module example_gater_cell (CLKIN, CLKOUT, EN, RSTN, TE);
   input CLKIN;
   output CLKOUT;
   input EN;
   input RSTN;
   input TE;
   CKLNQD16BWP16P90 gater_cell (
                                .CP(CLKIN),
                                .E(EN),
                                .TE(TE),
                                .Q(CLKOUT)
                                );
endmodule
<% } else { %>
<% voltageRegions.forEach(function (region) { %>
module <%=region%>_example_gater_cell (CLKIN, CLKOUT, EN, RSTN, TE);
   input CLKIN;
   output CLKOUT;
   input EN;
   input RSTN;
   input TE;
   CKLNQD16BWP16P90 gater_cell (
                                .CP(CLKIN),
                                .E(EN),
                                .TE(TE),
                                .Q(CLKOUT)
                                );
endmodule
<% }); %>
<% } %>
