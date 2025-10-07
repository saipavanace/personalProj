package <%=obj.BlockId%>_ccp_env_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh"
   import addr_trans_mgr_pkg::*;
   import <%=obj.BlockId%>_ccp_agent_pkg::*;
   export <%=obj.BlockId%>_ccp_agent_pkg::*;

`include "<%=obj.BlockId%>_ccp_scb_txn.sv"   
`include "<%=obj.BlockId%>_ccp_scoreboard.sv"
`include "<%=obj.BlockId%>_ccp_env.sv";
endpackage : <%=obj.BlockId%>_ccp_env_pkg
   
