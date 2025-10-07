package concerto_register_map_pkg;
`include "concerto_register_map.sv"
<% if(obj.useResiliency == 1){ %>
`include "fsc_concerto_register_map.sv"
<%}%>
endpackage: concerto_register_map_pkg
