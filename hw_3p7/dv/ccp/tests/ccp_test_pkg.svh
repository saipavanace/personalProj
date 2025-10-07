
////////////////////////////////////////////////////////////////////////////////
//
// CCP Test Package
//
////////////////////////////////////////////////////////////////////////////////

package ccp_test_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh"
import <%=obj.BlockId%>_ccp_agent_pkg::*;
import <%=obj.BlockId%>_ccp_env_pkg::*;
`include "ccp_base_test.sv"   
`include "ccp_bring_up_test.sv"
endpackage: ccp_test_pkg

