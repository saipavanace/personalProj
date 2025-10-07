

`include "snps_compile.sv"    

`include "svt_chi_item_helper_pkg.sv"
`ifdef CHI_SUBSYS
    `include "chi_ss_helper_pkg.sv"
`endif
package <%=obj.BlockId%>_chi_aiu_vseq_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import sv_assert_pkg::*;
  import ncore_config_pkg::*;
import addr_trans_mgr_pkg::*;
import chi_aiu_unit_args_pkg::*;
import <%=obj.BlockId%>_chi_bfm_types_pkg::*;
import <%=obj.BlockId%>_chi_bfm_txn_pkg::*;
import <%=obj.BlockId%>_chi_traffic_seq_lib_pkg::*;
`ifdef VCS
export <%=obj.BlockId%>_chi_bfm_types_pkg::*;
export <%=obj.BlockId%>_chi_bfm_txn_pkg::*;
export <%=obj.BlockId%>_chi_traffic_seq_lib_pkg::*;
`endif // `ifdef VCS


`include "snps_import.sv"


//`ifdef USE_VIP_SNPS_CHI
    //`include "cust_svt_amba_system_configuration.sv"
    //`include "svt_amba_env.sv"
<% if (obj.testBench == "fsys") { %>
    <%if (obj.BlockId.match("chiaiu0")) {%>
        `include "svt_amba_seq_item_lib.sv"
        `include "svt_amba_seq_lib.sv"
    <% } %>
<% } else { %>
    `ifdef USE_VIP_SNPS_CHI
        `include "svt_amba_seq_item_lib.sv"
        `include "svt_amba_seq_lib.sv"
    `endif // `ifdef USE_VIP_SNPS_CHI
<% } %>

//`endif // `ifdef USE_VIP_SNPS_CHI
import <%=obj.BlockId%>_chi_container_pkg::*;
  
import <%=obj.BlockId%>_chi_agent_pkg::*;
`ifdef VCS
export <%=obj.BlockId%>_chi_container_pkg::*;
export <%=obj.BlockId%>_chi_agent_pkg::*;
`endif // `ifdef VCS
<% if(obj.testBench == "fsys"|| obj.testBench == "emu") { %>
import concerto_register_map_pkg::*;
<% } %>
typedef uvm_sequence #(uvm_sequence_item) uvm_virtual_sequence;
<% if (obj.testBench == "fsys") { %>
    `include "<%=obj.BlockId%>_chi_txn_seq.svh"
    `include "<%=obj.BlockId%>_chi_aiu_vseq_helper.svh"
    `include "<%=obj.BlockId%>_chi_aiu_base_vseq.svh"
    `include "<%=obj.BlockId%>_chi_aiu_vseq.svh"
<% } else { %>
    `ifndef USE_VIP_SNPS_CHI
        `include "<%=obj.BlockId%>_chi_txn_seq.svh"
        `include "<%=obj.BlockId%>_chi_aiu_vseq_helper.svh"
        `include "<%=obj.BlockId%>_chi_aiu_base_vseq.svh"
        `include "<%=obj.BlockId%>_chi_aiu_vseq.svh"
    `else
        `include "<%=obj.BlockId%>_chi_aiu_vseq_helper.svh"
        `include "<%=obj.BlockId%>_snps_chi_aiu_vseq.svh"
    `endif
<% } %>

endpackage: <%=obj.BlockId%>_chi_aiu_vseq_pkg
