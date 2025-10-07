<% if (voltageRegions.length <= 1) { %>
module example_synchronizer_cell (CLK, RSTN, I, O);
   input CLK;
   input RSTN;
   input I;
   output O;

   wire internal;

   DFQD2BWP16P90 RegAsync_reg (
                         .D(I),
                         .CP(CLK),
                         .Q(internal)
                         );

   DFCNQD2BWP16P90 O_reg (
                            .D(internal),
                            .CP(CLK),
                            .CDN(RSTN),
                            .Q(O)
                            );
endmodule

module example_synchronizer_cell_3DFF (CLK, RSTN, I, O);
   input CLK;
   input RSTN;
   input I;
   output O;

   wire internal;
   wire O1;

   DFQD2BWP16P90 RegAsync_reg (
                         .D(I),
                         .CP(CLK),
                         .Q(internal)
                         );

   DFCNQD2BWP16P90 O1_reg (
                            .D(internal),
                            .CP(CLK),
                            .CDN(RSTN),
                            .Q(O1)
                            );

   DFCNQD2BWP16P90 O_reg (
                            .D(O1),
                            .CP(CLK),
                            .CDN(RSTN),
                            .Q(O)
                            );
endmodule
<% } else { %>
<% voltageRegions.forEach(function (region) { %>
module <%=region%>_example_synchronizer_cell (CLK, RSTN, I, O);
   input CLK;
   input RSTN;
   input I;
   output O;

   wire internal;

   DFQD2BWP16P90 RegAsync_reg (
                         .D(I),
                         .CP(CLK),
                         .Q(internal)
                         );

   DFCNQD2BWP16P90 O_reg (
                            .D(internal),
                            .CP(CLK),
                            .CDN(RSTN),
                            .Q(O)
                            );
endmodule
<% }); %>
<% voltageRegions.forEach(function (region) { %>
module <%=region%>_example_synchronizer_cell_3DFF (CLK, RSTN, I, O);
   input CLK;
   input RSTN;
   input I;
   output O;

   wire internal;
   wire O1;

   DFQD2BWP16P90 RegAsync_reg (
                         .D(I),
                         .CP(CLK),
                         .Q(internal)
                         );

   DFCNQD2BWP16P90 O1_reg (
                            .D(internal),
                            .CP(CLK),
                            .CDN(RSTN),
                            .Q(O1)
                            );

   DFCNQD2BWP16P90 O_reg (
                            .D(O1),
                            .CP(CLK),
                            .CDN(RSTN),
                            .Q(O)
                            );
endmodule
<% }); %>
<% } %>
