package <%=obj.BlockId%>_concerto_register_map_pkg;
<% if(obj.cli.environment == 'dve'|| obj.env_name =='dve') { %>
`include "<%=obj.BlockId%>_concerto_register_map.sv"
<% } %>
endpackage: <%=obj.BlockId%>_concerto_register_map_pkg
