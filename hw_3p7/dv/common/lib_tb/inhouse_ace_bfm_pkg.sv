/////////////////////////////////
//In-House ACE BFM Package
//File: inhouse_ace_bfm_pkg.sv
////////////////////////////////

package <%=obj.BlockId%>_inhouse_axi_bfm_pkg;
   import uvm_pkg::*;
   `include "uvm_macros.svh"

//   import <%=obj.BlockId%>_ConcertoPkg::*;
   import <%=obj.BlockId%>_axi_agent_pkg::*;
   import addr_trans_mgr_pkg::*;
   <%if(obj.COVER_ON) { %> 
   `include "<%=obj.BlockId%>_ace_coverage.sv"
   <%}%>
    <% if(obj.testBench=="fsys" ){ %>
   `include "mstr_seq_cfg.sv"
   `ifdef IO_UNITS_CNT_NON_ZERO
   `include "io_mstr_seq_cfg.sv"
   `endif
    <%}%>
   `include "<%=obj.BlockId%>_ace_cache_model.sv"
   `include "<%=obj.BlockId%>_axi_stl_traffic.sv"
   `include "<%=obj.BlockId%>_axi_master_pipeline_base_seq.sv"
   `include "<%=obj.BlockId%>_axi_seq.sv"

endpackage: <%=obj.BlockId%>_inhouse_axi_bfm_pkg
