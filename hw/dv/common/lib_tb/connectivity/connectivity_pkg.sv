package <%=obj.BlockId%>_connectivity_pkg;
    
  import uvm_pkg::*;
  import <%=obj.BlockId%>_connectivity_defines::*;

  <% if((obj.INHOUSE_APB_VIP) && (obj.DutInfo.strRtlNamePrefix == obj.instanceName)) { %>
  // `include "<%=obj.DutInfo.strRtlNamePrefix%>_concerto_register_map.sv"
  // `include "<%=obj.DutInfo.strRtlNamePrefix%>_connectivity_cfg_seq.sv"
   <% } %>
  
endpackage : <%=obj.BlockId%>_connectivity_pkg

