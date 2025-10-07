package <%=obj.instanceName%>_concerto_register_map_pkg;
<% if(obj.cli.environment == 'giu'|| obj.env_name =='giu') { %>
    `include "<%=obj.instanceName%>_concerto_register_map.sv"
<% } %>
endpackage: <%=obj.instanceName%>_concerto_register_map_pkg
