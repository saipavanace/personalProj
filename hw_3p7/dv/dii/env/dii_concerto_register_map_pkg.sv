package <%=obj.BlockId%>_concerto_register_map_pkg; 
<% if ((obj.cli.environment == 'dii' || obj.env_name =='dii') || (obj.cli.environment == 'dii_snps' || obj.env_name =='dii_snps'))  { %>
//<% console.log("vyshak Blockid is=", (JSON.stringify(obj.BlockId,null,2)))%>
//<% console.log("vyshak diiinfo is=", (JSON.stringify(obj.diiInfo,null,2)))%>
 
   `include "<%=obj.BlockId%>_concerto_register_map.sv"
   
<% } %>
endpackage: <%=obj.BlockId%>_concerto_register_map_pkg
