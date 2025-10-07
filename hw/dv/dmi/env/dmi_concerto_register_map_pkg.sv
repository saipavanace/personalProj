package <%=obj.BlockId%>_concerto_register_map_pkg;
<% if(obj.cli.environment == "dmi" || obj.env_name =="dmi" || obj.env_name =="dmi_snps" || obj.env_name =="dmi_v2") { %>
   <% if((obj.instanceName == obj.BlockId) && (obj.Id == 0)){%>
   `include "<%=obj.instanceName%>_concerto_register_map.sv"
   <% } %>
<% } %>
endpackage: <%=obj.BlockId%>_concerto_register_map_pkg
