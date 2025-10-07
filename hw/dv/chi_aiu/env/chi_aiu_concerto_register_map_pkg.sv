
package <%=obj.BlockId%>_concerto_register_map_pkg;
<% if(obj.cli.environment == "chi_aiu" || obj.cli.environment == "chi_aiu_snps" || obj.env_name =="chi_aiu"|| obj.env_name == "chi_aiu_snps") { %>
   `include "<%=obj.BlockId%>_concerto_register_map.sv"
   <% } %>
endpackage:<%=obj.BlockId%>_concerto_register_map_pkg

