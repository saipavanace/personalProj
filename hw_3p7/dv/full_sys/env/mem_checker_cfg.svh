////////////////////////////////////////////////////////////////////////////////
//
// Author       : Neha F
// Purpose      : This class stores configuration information for memory checker 
// Description  : Memory consistency checker will use this configuration information
//                to predict and compare memory consistency in NCore
//
////////////////////////////////////////////////////////////////////////////////


`undef LABEL
`define  LABEL "mem_checker_cfg"

class mem_checker_cfg extends uvm_object;

   `uvm_object_param_utils(mem_checker_cfg)

    int sp_ways[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
    int sp_size[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
    bit [<%=obj.wSysAddr-1%>:0] sp_base_addr[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];

   extern function new(string name = "mem_checker_cfg");
   extern function bit is_sp_addr(bit[63:0] addr);

endclass : mem_checker_cfg

function mem_checker_cfg::new(string name = "mem_checker_cfg");
endfunction : new

function bit mem_checker_cfg::is_sp_addr(bit[63:0] addr);
   smi_addr_t cl_aligned_addr;
   bit sp_addr = 0;
   bit [<%=obj.wSysAddr-1%>:0] sp_top_addr; 
   <% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
   sp_top_addr = sp_base_addr[<%=pidx%>] + (<%=obj.DmiInfo[pidx].ccpParams.nSets%>*sp_ways[<%=pidx%>])-1;
   cl_aligned_addr = addrMgrConst::gen_spad_intrlv_rmvd_addr(addr,<%=obj.DmiInfo[pidx].nUnitId%>) >> <%=obj.wCacheLineOffset%>;
   `uvm_info(`LABEL, $psprintf("DMI#<%=pidx%>: sp_ways = 0x%0h, sp-low addr=0x%0h, top_Addr=0x%0h, addr in question=0x%0h, inlv_removed_Addr=0x%0h", sp_ways[<%=pidx%>], sp_base_addr[<%=pidx%>], sp_top_addr, addr, cl_aligned_addr), UVM_MEDIUM)
   if(sp_ways[<%=pidx%>] > 0 
      && (cl_aligned_addr >= sp_base_addr[<%=pidx%>]) 
      && (cl_aligned_addr <= sp_top_addr)) begin
      sp_addr = 1;
      `uvm_info(`LABEL, $psprintf("DMI#<%=pidx%>: This is Scratchpad address"), UVM_MEDIUM)
   end
   <% } //foreach DMI %>
   return (sp_addr);
endfunction:is_sp_addr 


