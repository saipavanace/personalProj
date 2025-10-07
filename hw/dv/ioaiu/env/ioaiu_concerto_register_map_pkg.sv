
package <%=obj.BlockId%>_concerto_register_map_pkg;
<% if(obj.testBench == "io_aiu") { %>
  <% if(obj.instanceName == obj.BlockId) { %>
    `include "<%=obj.instanceName%>_concerto_register_map.sv"
  <% }%>
<% }%>
endpackage:<%=obj.BlockId%>_concerto_register_map_pkg

