////////////////////////////
//AIU Seq Package
//File: aiu_seq_pkg.sv
////////////////////////////
`include "snps_compile.sv"

package <%=obj.BlockId%>_ioaiu_seq_lib_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "snps_import.sv"
    //Import AIU env
<% if(obj.CUSTOMER_ENV === undefined) { %>
    import <%=obj.BlockId%>_env_pkg::*;
<% } else { %>
    import <%=obj.BlockId%>_ioaiu_env_pkg::*;
<% } %>


endpackage: <%=obj.BlockId%>_ioaiu_seq_lib_pkg

