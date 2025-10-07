
`include "snps_compile.sv"    
package <%=obj.BlockId%>_ioaiu_seq_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import sv_assert_pkg::*;
import addr_trans_mgr_pkg::*;
import <%=obj.BlockId%>_axi_agent_pkg::*;
`include "snps_import.sv"
import <%=obj.BlockId%>_inhouse_axi_bfm_pkg::*;
  
/*<% if(obj.testBench == "fsys") { %>
import concerto_register_map_pkg::*;
<% } %> */
<%if((obj.INHOUSE_APB_VIP) && (obj.testBench == "io_aiu") && 
        ((obj.instanceName) ? (obj.BlockId == obj.instanceName) :
        (obj.ioaiuId==0))) { %>
        import <%=obj.BlockId%>_concerto_register_map_pkg::*;  
<% } else if(obj.testBench == 'fsys' || obj.testBench =='emu'){%>
        import concerto_register_map_pkg::*;;
<% } %> 


  `include "<%=obj.BlockId%>_ioaiu_base_vseq.svh"
  `include "<%=obj.BlockId%>_ioaiu_vseq.svh"

endpackage: <%=obj.BlockId%>_ioaiu_seq_pkg
