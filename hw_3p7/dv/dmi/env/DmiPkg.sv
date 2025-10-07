////////////////////////////////////////////////////////////////////////////////
//
// DMI Package contains:
// - class DMI that stores common parameters, typedefs, functions for Concerto DMI
// aniket.ponkshe@arteris.com
////////////////////////////////////////////////////////////////////////////////

package <%=obj.BlockId%>_DmiPkg;


   import uvm_pkg::*;
   `include "uvm_macros.svh"

   import <%=obj.BlockId%>_axi_agent_pkg::*;
   import <%=obj.BlockId%>_smi_agent_pkg::*;
<% if(obj.useCmc == 1) { %>
    import <%=obj.BlockId%>_ccp_agent_pkg::*;
    import <%=obj.BlockId%>_ccp_env_pkg::*;
<% } %>   

//   `include "<%=obj.BlockId%>_dmi_states.svh"

endpackage : <%=obj.BlockId%>_DmiPkg
/*
 <%=JSON.stringify(obj,null,' ')%>
 */
