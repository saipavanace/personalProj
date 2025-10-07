<%
//Embedded javascript code to figure number of blocks
   var pidx = 0;
   var nCHIAIUs = 0;
   var nIOAIUs = 0;
   var nDCEs = obj.nDCEs;
   var nDMIs = obj.nDMIs;
   var nDIIs = obj.nDIIs; 
   var nDVEs = obj.nDVEs;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       nCHIAIUs++;
       } else {
       nIOAIUs++;
       }
   }

%>


`ifndef GUARD_SVT_SEQ_LIB_SV
`define GUARD_SVT_SEQ_LIB_SV
//Generic addr_pkg can be used anywhere
`ifdef USE_VIP_SNPS_COMPILE_OFF
package vip_addr_pkg; //{ 
import uvm_pkg::*;
`include "uvm_macros.svh"
import addr_trans_mgr_pkg::*;

function bit [addrMgrConst::W_SEC_ADDR - 1 : 0] non_coh_sa(output bit [addrMgrConst::W_SEC_ADDR - 1 : 0] sa);
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] start_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] end_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] low_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] upp_addr;
  int dmi_grps[$];
  int dii_grps[$];
  int nintrlv_grps[$];
  int dmi_ig_id;
  addrMgrConst::sys_addr_csr_t csrq[$];
  addrMgrConst::ncore_unit_type_t nintrlv_type[$];
  bit [63:0] domain_size;

  csrq = addrMgrConst::get_all_gpra();
<% if (obj.AiuInfo[0].fnNativeInterface == 'CHI-A') { %>
//SCHEME1(44)
        foreach (csrq[i]) begin
          start_addr = csrq[i].low_addr << 12;
          domain_size = (1 << (csrq[i].size+12));
          end_addr = start_addr + domain_size - 1;
          if(csrq[i].unit == addrMgrConst::DII) begin //{
           sa = start_addr;
           return sa; //return 1 item for now
          end //}
        end //foreach (csrq[i])

<% } else if (obj.AiuInfo[0].fnNativeInterface == 'CHI-B' || obj.AiuInfo[0].fnNativeInterface == 'CHI-E') { %>
//SCHEME2(48)
  dmi_ig_id = 1;
  foreach (addrMgrConst::intrlvgrp_vector[dmi_ig_id][idx]) 
    dmi_grps.push_back(addrMgrConst::intrlvgrp_vector[dmi_ig_id][idx]);
    dii_grps.push_back(1);

  foreach (dmi_grps[i]) begin
    nintrlv_grps.push_back(dmi_grps[i]);
    nintrlv_type.push_back(addrMgrConst::DMI);
  end
  foreach (dii_grps[i]) begin
    nintrlv_grps.push_back(dii_grps[i]);
    nintrlv_type.push_back(addrMgrConst::DII);
  end
 
 foreach (nintrlv_grps[i]) begin
     csrq = addrMgrConst::get_memregions_assoc_ig(i);
     foreach (csrq[j]) begin
       low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
       upp_addr = low_addr + nintrlv_grps[i]*(1<<(csrq[j].size+12)) - 1;
        if(csrq[j].unit == addrMgrConst::DII) begin //{
           sa = low_addr;
           return sa; //return 1 item for now
        end //}
     end // foreach (csrq[j])
 end // foreach (nintrlv_grps[i])

<% } %>
endfunction
function bit [addrMgrConst::W_SEC_ADDR - 1 : 0] non_coh_ea(output bit [addrMgrConst::W_SEC_ADDR - 1 : 0] ea);
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] start_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] end_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] low_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] upp_addr;
  int dmi_grps[$];
  int dii_grps[$];
  int nintrlv_grps[$];
  int dmi_ig_id;
  addrMgrConst::sys_addr_csr_t csrq[$];
  addrMgrConst::ncore_unit_type_t nintrlv_type[$];
  bit [63:0] domain_size;

  csrq = addrMgrConst::get_all_gpra();
<% if (obj.AiuInfo[0].fnNativeInterface == 'CHI-A') { %>
//SCHEME1(44)
        foreach (csrq[i]) begin
          start_addr = csrq[i].low_addr << 12;
          domain_size = (1 << (csrq[i].size+12));
          end_addr = start_addr + domain_size - 1;
          if(csrq[i].unit == addrMgrConst::DII) begin //{
           ea = end_addr;
           return ea; //return 1 item for now
          end //}
        end //foreach (csrq[i])
<% } else if (obj.AiuInfo[0].fnNativeInterface == 'CHI-B' || obj.AiuInfo[0].fnNativeInterface == 'CHI-E') { %>
//SCHEME2(48)
  dmi_ig_id = 1;
  foreach (addrMgrConst::intrlvgrp_vector[dmi_ig_id][idx]) 
    dmi_grps.push_back(addrMgrConst::intrlvgrp_vector[dmi_ig_id][idx]);
    dii_grps.push_back(1);

  foreach (dmi_grps[i]) begin
    nintrlv_grps.push_back(dmi_grps[i]);
    nintrlv_type.push_back(addrMgrConst::DMI);
  end
  foreach (dii_grps[i]) begin
    nintrlv_grps.push_back(dii_grps[i]);
    nintrlv_type.push_back(addrMgrConst::DII);
  end
 
 foreach (nintrlv_grps[i]) begin
     csrq = addrMgrConst::get_memregions_assoc_ig(i);
     foreach (csrq[j]) begin
       low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
       upp_addr = low_addr + nintrlv_grps[i]*(1<<(csrq[j].size+12)) - 1;
        if(csrq[j].unit == addrMgrConst::DII) begin //{
           ea = upp_addr;
           return ea; //return 1 item for now
        end //}
     end // foreach (csrq[j])
 end // foreach (nintrlv_grps[i])
<% } %>
endfunction
/////////////////////////////////////////////////////////////////////////
function bit  [addrMgrConst::W_SEC_ADDR - 1 : 0]   coh_sa(output bit [addrMgrConst::W_SEC_ADDR - 1 : 0] sa);
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] start_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] end_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] low_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] upp_addr;
  int dmi_grps[$];
  int dii_grps[$];
  int nintrlv_grps[$];
  int dmi_ig_id;
  addrMgrConst::sys_addr_csr_t csrq[$];
  addrMgrConst::ncore_unit_type_t nintrlv_type[$];
  bit [63:0] domain_size;

  csrq = addrMgrConst::get_all_gpra();
<% if (obj.AiuInfo[0].fnNativeInterface == 'CHI-A') { %>
//SCHEME1(44)
        foreach (csrq[i]) begin
          start_addr = csrq[i].low_addr << 12;
          domain_size = (1 << (csrq[i].size+12));
          end_addr = start_addr + domain_size - 1;
          if(csrq[i].unit == addrMgrConst::DMI) begin //{
           sa = start_addr;
           return sa; //return 1 item for now
          end //}
        end //foreach (csrq[i])
<% } else if (obj.AiuInfo[0].fnNativeInterface == 'CHI-B' || obj.AiuInfo[0].fnNativeInterface == 'CHI-E') { %>
//SCHEME2(48)
  dmi_ig_id = 1;
  foreach (addrMgrConst::intrlvgrp_vector[dmi_ig_id][idx]) 
    dmi_grps.push_back(addrMgrConst::intrlvgrp_vector[dmi_ig_id][idx]);
    dii_grps.push_back(1);

  foreach (dmi_grps[i]) begin
    nintrlv_grps.push_back(dmi_grps[i]);
    nintrlv_type.push_back(addrMgrConst::DMI);
  end
  foreach (dii_grps[i]) begin
    nintrlv_grps.push_back(dii_grps[i]);
    nintrlv_type.push_back(addrMgrConst::DII);
  end
 
 foreach (nintrlv_grps[i]) begin
     csrq = addrMgrConst::get_memregions_assoc_ig(i);
     foreach (csrq[j]) begin
       low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
       upp_addr = low_addr + nintrlv_grps[i]*(1<<(csrq[j].size+12)) - 1;
       if(csrq[j].unit == addrMgrConst::DMI) begin //{
           sa = low_addr;
           return sa; //return 1 item for now
       end //}
     end // foreach (csrq[j])
 end // foreach (nintrlv_grps[i])
<% } %>
endfunction
function bit [addrMgrConst::W_SEC_ADDR - 1 : 0]    coh_ea(output bit [addrMgrConst::W_SEC_ADDR - 1 : 0] ea);
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] start_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] end_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] low_addr;
  bit [addrMgrConst::W_SEC_ADDR - 1 : 0] upp_addr;
  int dmi_grps[$];
  int dii_grps[$];
  int nintrlv_grps[$];
  int dmi_ig_id;
  addrMgrConst::sys_addr_csr_t csrq[$];
  addrMgrConst::ncore_unit_type_t nintrlv_type[$];
  bit [63:0] domain_size;

  csrq = addrMgrConst::get_all_gpra();
<% if (obj.AiuInfo[0].fnNativeInterface == 'CHI-A') { %>
//SCHEME1(44)
        foreach (csrq[i]) begin
          start_addr = csrq[i].low_addr << 12;
          domain_size = (1 << (csrq[i].size+12));
          end_addr = start_addr + domain_size - 1;
          if(csrq[i].unit == addrMgrConst::DMI) begin //{
           ea = end_addr;
           return ea; //return 1 item for now
          end //}
        end //foreach (csrq[i])
<% } else if (obj.AiuInfo[0].fnNativeInterface == 'CHI-B' || obj.AiuInfo[0].fnNativeInterface == 'CHI-E') { %>
//SCHEME2(48)
  dmi_ig_id = 1;
  foreach (addrMgrConst::intrlvgrp_vector[dmi_ig_id][idx]) 
    dmi_grps.push_back(addrMgrConst::intrlvgrp_vector[dmi_ig_id][idx]);
    dii_grps.push_back(1);

  foreach (dmi_grps[i]) begin
    nintrlv_grps.push_back(dmi_grps[i]);
    nintrlv_type.push_back(addrMgrConst::DMI);
  end
  foreach (dii_grps[i]) begin
    nintrlv_grps.push_back(dii_grps[i]);
    nintrlv_type.push_back(addrMgrConst::DII);
  end
 
 foreach (nintrlv_grps[i]) begin
     csrq = addrMgrConst::get_memregions_assoc_ig(i);
     foreach (csrq[j]) begin
       low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
       upp_addr = low_addr + nintrlv_grps[i]*(1<<(csrq[j].size+12)) - 1;
       if(csrq[j].unit == addrMgrConst::DMI) begin //{
           ea = upp_addr;
           return ea; //return 1 item for now
       end //}
     end // foreach (csrq[j])
 end // foreach (nintrlv_grps[i])
<% } %>
endfunction
endpackage //}
`endif // `ifdef USE_VIP_SNPS_COMPILE_OFF


`ifdef USE_VIP_SNPS
`include "snps_compile.sv"    
`include "svt_amba_env.sv"
`endif // `ifdef USE_VIP_SNPS

package fsys_svt_seq_lib;
import addr_trans_mgr_pkg::*;
`ifdef USE_VIP_SNPS_COMPILE_OFF
import vip_addr_pkg::*;
`endif // `ifdef USE_VIP_SNPS_COMPILE_OFF

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "snps_import.sv"
`ifdef USE_VIP_SNPS
    `include "svt_amba_seq_item_lib.sv"
    `include "svt_amba_seq_lib.sv"
`endif // `ifdef USE_VIP_SNPS

//To-Do CONC-8849 : This logic put by Rama. Review and fix if need to use this sequence. Many times seen compile errors. Adding compile directive temporarily to excude this logic from compilation.
`ifdef USE_VIP_SNPS_COMPILE_OFF
class rn_noncoherent_transaction1 extends svt_chi_rn_transaction;
`ifdef CHI_UNITS_CNT_NON_ZERO
  bit [addrMgrConst::W_SEC_ADDR - 1: 0] sa = vip_addr_pkg::non_coh_sa(sa);
  bit [addrMgrConst::W_SEC_ADDR - 1: 0] ea = vip_addr_pkg::non_coh_ea(ea);

  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
  <% if((obj.AiuInfo[0].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[0].fnNativeInterface == 'CHI-B') ||(obj.AiuInfo[0].fnNativeInterface == 'CHI-E')) { %>
  <% if (obj.testBench == "fsys") { %>
  int my_size     = chiaiu0_svt_chi_node_params_pkg::SVT_CHI_NODE_WSIZE;     //3
  int my_be_width = chiaiu0_svt_chi_node_params_pkg::SVT_CHI_NODE_WBE ;  //16
  <% } else { %>
  int my_size = <%=obj.AiuInfo[0].strRtlNamePrefix%>_svt_chi_node_params_pkg::SVT_CHI_NODE_WSIZE%>;
  int my_be_width = <%=obj.AiuInfo[0].strRtlNamePrefix%>_svt_chi_node_params_pkg::SVT_CHI_NODE_WBE%> ; 
  <% } %>
  <% break; } } %>

  int num_bytes = 2^my_size;

  // Only allow noncoherent transactions
  constraint noncoherent_only {
    xact_type inside { svt_chi_rn_transaction::READNOSNP,
                       //svt_chi_rn_transaction::WRITENOSNPPTL,
                       svt_chi_rn_transaction::WRITENOSNPFULL
                     };
    
    snp_attr_is_snoopable == 0;
    solve snp_attr_is_snoopable before snp_attr_snp_domain_type;

    //addr inside {[ sa:ea  ]}; 
    //addr == sa; 
    //snp_attr_is_snoopable == 0;
    //snp_attr_snp_domain_type == !(INNER);
  }
  
  constraint rn_constraints {
    if (xact_type == svt_chi_rn_transaction::READNOSNP)
        order_type == svt_chi_transaction::NO_ORDERING_REQUIRED;

    // Constraint the RespErr field to NORMAL_OKAY
    // for both RSP and DAT flits.
    response_resp_err_status == NORMAL_OKAY;
    foreach (data_resp_err_status[index]){
      data_resp_err_status[index] == NORMAL_OKAY;
    }

    if (xact_type == svt_chi_transaction::WRITENOSNPFULL) { 
     byte_enable == ( (1 << 64) -1 - int'(addr%num_bytes)  ); 
     data_size   == svt_chi_transaction::SIZE_64BYTE;
    }   

  }
`endif // CHI_UNITS_CNT_NON_ZERO

  `svt_xvm_object_utils(rn_noncoherent_transaction1)

  function new(string name = "rn_noncoherent_transaction1");
    super.new(name);
    `uvm_info("rn_noncoherent_transaction1", $sformatf("vip_addr_pkg: addr inside 0x%12h: 0x%12h", sa,ea ), UVM_NONE)
  endfunction

endclass // rn_noncoherent_transaction1

class rn_coherent_transaction1 extends svt_chi_rn_transaction;
`ifdef CHI_UNITS_CNT_NON_ZERO
  bit [addrMgrConst::W_SEC_ADDR - 1: 0] sa = vip_addr_pkg::coh_sa(sa);
  bit [addrMgrConst::W_SEC_ADDR - 1: 0] ea = vip_addr_pkg::coh_ea(ea);
  // Only allow coherent transactions
  constraint coherent_only {
    xact_type inside { 
                        svt_chi_rn_transaction::READONCE, 
                        svt_chi_rn_transaction::READCLEAN, 
                        svt_chi_rn_transaction::READSHARED, 
                        svt_chi_rn_transaction::READUNIQUE,
                        svt_chi_rn_transaction::WRITEBACKFULL, 
                        svt_chi_rn_transaction::WRITEBACKPTL, 
                        svt_chi_rn_transaction::WRITECLEANFULL, 
                        svt_chi_rn_transaction::WRITECLEANPTL, 
                        svt_chi_rn_transaction::WRITEEVICTFULL,
                        svt_chi_rn_transaction::WRITEUNIQUEFULL,
                        svt_chi_rn_transaction::WRITEUNIQUEPTL
                     };



        //addr inside {[ sa:ea ]}; 
        addr == sa;
        if ( snp_attr_is_snoopable == 1) {
                     (snp_attr_snp_domain_type == INNER);
        }
        if (xact_type == svt_chi_transaction::WRITEUNIQUEFULL) 
           byte_enable == 64'hFFFF_FFFF_FFFF_FFFF;
  }
 
`endif // CHI_UNITS_CNT_NON_ZERO
 
  `svt_xvm_object_utils(rn_coherent_transaction1)

  function new(string name = "rn_coherent_transaction1");
    super.new(name);
    `uvm_info("rn_coherent_transaction1", $sformatf("vip_addr_pkg: addr inside 0x%12h: 0x%12h", sa,ea ), UVM_NONE)
  endfunction

endclass // rn_coherent_transaction1

`ifdef SVT_CHI_ISSUE_B_ENABLE
class rn_stash_transaction1 extends svt_chi_rn_transaction;
`ifdef CHI_UNITS_CNT_NON_ZERO

  // Only allow stash transactions
  constraint coherent_only {
    xact_type inside { 
                        svt_chi_rn_transaction::WRITEUNIQUEFULLSTASH, 
                        svt_chi_rn_transaction::WRITEUNIQUEPTLSTASH, 
                        svt_chi_rn_transaction::STASHONCEUNIQUE, 
                        svt_chi_rn_transaction::STASHONCESHARED
                     };

                    if ( snp_attr_is_snoopable == 1) {
                     (snp_attr_snp_domain_type == INNER);
                    }

    //addr inside {[44'h000_0000_0000:44'h000_FFFF_FFFF]};
  }
`endif // CHI_UNITS_CNT_NON_ZERO
  
  `svt_xvm_object_utils(rn_stash_transaction1)

  function new(string name = "rn_stash_transaction1");
    super.new(name);
  endfunction

endclass // rn_stash_transaction1

class rn_atomic_transaction1 extends svt_chi_rn_transaction;

`ifdef CHI_UNITS_CNT_NON_ZERO
  // Only allow atomic transactions
  constraint coherent_only {
    xact_type inside { 
                        svt_chi_rn_transaction::ATOMICSTORE_ADD, 
                        svt_chi_rn_transaction::ATOMICSTORE_CLR, 
                        svt_chi_rn_transaction::ATOMICSTORE_EOR, 
                        svt_chi_rn_transaction::ATOMICSTORE_SET,
                        svt_chi_rn_transaction::ATOMICSTORE_SMAX, 
                        svt_chi_rn_transaction::ATOMICSTORE_SMIN, 
                        svt_chi_rn_transaction::ATOMICSTORE_UMAX, 
                        svt_chi_rn_transaction::ATOMICSTORE_UMIN, 
                        svt_chi_rn_transaction::ATOMICLOAD_ADD, 
                        svt_chi_rn_transaction::ATOMICLOAD_CLR, 
                        svt_chi_rn_transaction::ATOMICLOAD_EOR, 
                        svt_chi_rn_transaction::ATOMICLOAD_SET,
                        svt_chi_rn_transaction::ATOMICLOAD_SMAX, 
                        svt_chi_rn_transaction::ATOMICLOAD_SMIN, 
                        svt_chi_rn_transaction::ATOMICLOAD_UMAX, 
                        svt_chi_rn_transaction::ATOMICLOAD_UMIN, 
                        svt_chi_rn_transaction::ATOMICSWAP, 
                        svt_chi_rn_transaction::ATOMICCOMPARE
                     };

                    if ( snp_attr_is_snoopable == 1) {
                     (snp_attr_snp_domain_type == INNER);
                    }

    //addr inside {[44'h000_0000_0000:44'h000_FFFF_FFFF]};
  }
`endif // CHI_UNITS_CNT_NON_ZERO
  
  `svt_xvm_object_utils(rn_atomic_transaction1)

  function new(string name = "rn_atomic_transaction1");
    super.new(name);
  endfunction

endclass // rn_atomic_transaction1

`endif // SVT_CHI_ISSUE_B_ENABLE
`endif // `ifdef USE_VIP_SNPS_COMPILE_OFF


<%
//Embedded javascript code to figure number of blocks
   var numIoAiu          = 0;
   var pidx = 0;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
            } else {
              numIoAiu = numIoAiu + 1;
       }
   }
   %>


//`ifdef USE_VIP_SNPS
import concerto_register_map_pkg::*;
//todo
<% if(numIoAiu > 0)  { %>
`include "ioaiu0_axi_widths.svh"

class svt_reg_wr_sequence extends svt_axi_master_base_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `svt_xvm_object_utils(svt_reg_wr_sequence)

  /** Address to be written */
  rand bit [`SVT_AXI_ADDR_WIDTH-1 : 0] addr;

  /** Address to be written */
  rand bit [`SVT_AXI_MAX_DATA_WIDTH-1 : 0] data;

  svt_axi_transaction::atomic_type_enum atomic_type = svt_axi_transaction::NORMAL;

  function new(string name="svt_reg_wr_sequence");
    super.new(name);
  endfunction

  virtual task body();
    super.body();

    `svt_xvm_do_with(req, {
      xact_type == svt_axi_transaction::WRITE;
      addr == local::addr;
`ifndef INCA
      data.size() == 1;
`else
      req.data.size() == 1;
`endif
      data[0] == local::data;
      atomic_type == local::atomic_type;
      burst_length == 1;
    })

    get_response(rsp);
  endtask: body

  virtual function bit is_applicable(svt_configuration cfg);
    return 1;
  endfunction : is_applicable
endclass: svt_reg_wr_sequence

class svt_reg_rd_sequence extends svt_axi_master_base_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `svt_xvm_object_utils(svt_reg_rd_sequence)

  /** Address to be written */
  rand bit [`SVT_AXI_ADDR_WIDTH-1 : 0] addr;

  /** Expected data. This is used to check the return value. */
  bit [`SVT_AXI_MAX_DATA_WIDTH-1 : 0] exp_data;

  /** Enable the check of the expected data. */
  bit check_enable = 0;

  svt_axi_transaction::atomic_type_enum atomic_type = svt_axi_transaction::NORMAL;

  function new(string name="svt_reg_rd_sequence");
    super.new(name);
  endfunction

  virtual task body();
    super.body();

    `svt_xvm_do_with(req, {
      xact_type == svt_axi_transaction::READ;
      addr == local::addr;
      atomic_type == local::atomic_type;
      burst_length == 1;
    })

    get_response(rsp);

    // Check the read data
    if (check_enable) begin
      if (rsp.data.size() != 1) begin
        `svt_xvm_error("body", $sformatf("Unexpected number of data for read to addr=%x.  Expected 1, recreived %0d", addr, rsp.data.size()));
      end
      else if (rsp.data[0] != exp_data) begin
        `svt_xvm_error("body", $sformatf("Data mismatch for read to addr=%x.  Expected %x, received %x", addr, exp_data, rsp.data[0]));
      end
    end
    exp_data = rsp.data[0];

  endtask: body

  virtual function bit is_applicable(svt_configuration cfg);
    return 1;
  endfunction : is_applicable
endclass: svt_reg_rd_sequence

class seq_lib_svt_data_integrity_ace_write_sequence extends svt_axi_master_base_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `svt_xvm_object_utils(seq_lib_svt_data_integrity_ace_write_sequence)
 
 svt_axi_transaction::coherent_xact_type_enum        m_ace_wr_addr_chnl_snoop;
 bit m_coh_transaction;

  /** Address to be written */
   bit [`SVT_AXI_ADDR_WIDTH-1 : 0] myAddr;
  int addr_offset;
  bit directed_wr_rd;
  /** Data to be written */
  bit [1023: 0] myData ;
  //bit [31 : 0] myData ;
  bit [31:0] wstrb;

<%if(obj.Block == "dmi" || obj.Block == "io_aiu" || obj.Block == "aceaiu" ) { %> 
  bit [WARID-1:0] arid;
  bit [WAWID-1:0] awid;
<% } else { %>    
  bit [WAXID-1:0] arid;
  bit [WAXID-1:0] awid;
<% } %>
  bit [CAXLEN-1:0] axlen;
  bit [CAXSIZE-1:0] awsize;
  int k_addr_valid_delay;


  function new(string name="seq_lib_svt_data_integrity_ace_write_sequence");
    super.new(name);
  endfunction

  virtual task body();
    svt_axi_master_transaction 			tr;
    //super.body();
    if(!$value$plusargs("k_addr_valid_delay=%d",k_addr_valid_delay))begin
      k_addr_valid_delay = 1;
    end
          m_ace_wr_addr_chnl_snoop = svt_axi_transaction::WRITENOSNOOP;
    `svt_xvm_create(tr)
    tr.randomize() with {

    //  xact_type == svt_axi_transaction::COHERENT;
      coherent_xact_type == local::m_ace_wr_addr_chnl_snoop;
      atomic_type == svt_axi_transaction::NORMAL;
      burst_type ==svt_axi_transaction::WRAP;
      domain_type== svt_axi_transaction::SYSTEMSHAREABLE;
      prot_type==svt_axi_transaction::DATA_SECURE_NORMAL;
      cache_type==0;
      associate_barrier==0;
      barrier_type == 0; //no AXBAR=1;
      //DH addr == local::myAddr;
      id <='h1f;

      //critical timing based
      data_before_addr == 1;
      reference_event_for_addr_valid_delay inside {svt_axi_transaction::FIRST_WVALID_DATA_BEFORE_ADDR ,svt_axi_transaction::FIRST_DATA_HANDSHAKE_DATA_BEFORE_ADDR};
      addr_valid_delay                       > k_addr_valid_delay; //Need to wait for pending transactions to complete e.g. DTRRsp (~100 cycles may be, fullsys_test: 5us)
      //match compile option to be greater than 102 say +define+SVT_AXI_MAX_ADDR_VALID_DELAY=103 (to avoid constraint fail)
       //burst_size==local::awsize;
      if(local::axlen<1)
      burst_length == 4;
      else 
      burst_length == local::axlen;      //Rama: initialize data/cache/strobe to 0 and load predictables in post_randomize later (below)
      foreach(data[i]) data[i]==0;
      foreach(wstrb[i]) wstrb[i]==0;
      foreach(cache_write_data[i]) cache_write_data[i]==0;
     };

      tr.addr = myAddr;
      case(awsize)

      3: tr.burst_size   = svt_axi_transaction::BURST_SIZE_64BIT;
      4: tr.burst_size   = svt_axi_transaction::BURST_SIZE_128BIT;
      5: tr.burst_size   = svt_axi_transaction::BURST_SIZE_256BIT;
      default:tr.burst_size   = svt_axi_transaction::BURST_SIZE_32BIT;
     endcase
    //=====================================================
    //post randomzie
    //=====================================================
    //process the 32bit write data/strobe on 128 bit data bus
  //process the 32bit write data/strobe on 128 bit data bus
    
   
      tr.wvalid_delay = new[tr.burst_length];
        foreach (tr.wvalid_delay[i]) begin
        tr.wvalid_delay[i]=i;
      end
      tr.xact_type = svt_axi_transaction::COHERENT;
   
      `uvm_info("BODY",$sformatf("burst_length:%0h burst_size:%0h xact_type:%0s domain_type:%0s wstrb:%0p addr:%0h axlen:%0h awsize:%0h myAddr:%0h",tr.burst_length,tr.burst_size,tr.xact_type,tr.domain_type,tr.wstrb,tr.addr,axlen,awsize,myAddr),UVM_LOW)    
   // if(directed_wr_rd) begin
         case (tr.burst_length)
      1:  begin
          if(awsize==3) begin
          tr.data[0] = myData[63:0];
          tr.wstrb[0] = wstrb[7:0];
          end
          else if(awsize==4) begin
          tr.data[0]  = myData[127: 0];
          //tr.wstrb[0] = wstrb[15:0];
          tr.wstrb[0] = 32'h0000_ffff;
          end
          else if(awsize==5) begin
          tr.data[0]  = myData[255: 0];
          tr.wstrb[0] = wstrb[31:0];
          end
        end
      2: begin
          if(awsize==3) begin
          tr.data[0] = myData[63:0];
          tr.data[1] = myData[127:64];
          tr.wstrb[0] = wstrb[7:0];
          tr.wstrb[1] = wstrb[7:0]; 
          end
          else if(awsize==4) begin
          tr.data[0] =  myData[127: 0];
          tr.data[1] =  myData[255 :128];
          tr.wstrb[0] = wstrb[15:0];
          tr.wstrb[1] = wstrb[15:0];
          end
          else if(awsize==5) begin
          tr.data[0] =  myData[255: 0];
          tr.data[1] =  myData[511:256];
          tr.wstrb[0] = wstrb[31:0];
          tr.wstrb[1] = wstrb[31:0];
          end
         end
      3: begin
          if(awsize==3) begin
          tr.data[0] = myData[63:0];
          tr.data[1] = myData[127:64];
          tr.data[2] = myData[191:128];
          tr.wstrb[0] = wstrb[7:0];
          tr.wstrb[1] = wstrb[7:0]; 
          tr.wstrb[2] = wstrb[7:0];
          end
          else if(awsize==4) begin
          tr.data[0] = myData[127: 0];
          tr.data[1] = myData[255 :128];
          tr.data[2] = myData[383:256];
          tr.wstrb[0] = wstrb[15:0];
          tr.wstrb[1] = wstrb[15:0]; 
          tr.wstrb[2] = wstrb[15:0];
          end
          else if(awsize==5) begin
          tr.data[0] = myData[255: 0];
          tr.data[1] = myData[511 :256];
          tr.data[2] = myData[767:512];
          tr.wstrb[0] = wstrb[31:0];
          tr.wstrb[1] = wstrb[31:0]; 
          tr.wstrb[2] = wstrb[31:0];
          end
         end
      4: begin
          if(awsize==3) begin
          tr.data[0] = myData[63:0];
          tr.data[1] = myData[127:64];
          tr.data[2] = myData[191:128];
          tr.data[3] = myData[255:192];
          tr.wstrb[0] = wstrb[7:0];
          tr.wstrb[1] = wstrb[7:0]; 
          tr.wstrb[2] = wstrb[7:0];
          tr.wstrb[3] = wstrb[7:0];
          end
          else if(awsize==4) begin
          tr.data[0] = myData[127: 0];
          tr.data[1] = myData[255:128];
          tr.data[2] = myData[383:256];
          tr.data[3] = myData[511:384];
          tr.wstrb[0] = wstrb[15:0];
          tr.wstrb[1] = wstrb[15:0]; 
          tr.wstrb[2] = wstrb[15:0];
          tr.wstrb[3] = wstrb[15:0];
          end
          else if(awsize==5) begin
          tr.data[0] = myData[255: 0];
          tr.data[1] = myData[511 :256];
          tr.data[2] = myData[767:512];
          tr.data[3] = myData[1023:768];
          tr.wstrb[0] = wstrb[31:0];
          tr.wstrb[1] = wstrb[31:0]; 
          tr.wstrb[2] = wstrb[31:0];
          tr.wstrb[3] = wstrb[31:0];
          end
           end
      8: begin
	  if(awsize==3) begin
          tr.data[0] = myData[63:0];
          tr.data[1] = myData[127:64];
          tr.data[2] = myData[191:128];
          tr.data[3] = myData[255:192];
          tr.data[4] = myData[319:256];
          tr.data[5] = myData[383:320];
          tr.data[6] = myData[447:384];
          tr.data[7] = myData[511:448];
          tr.wstrb[0] = wstrb[7:0];
          tr.wstrb[1] = wstrb[7:0]; 
          tr.wstrb[2] = wstrb[7:0];
          tr.wstrb[3] = wstrb[7:0];
          tr.wstrb[4] = wstrb[7:0];
          tr.wstrb[5] = wstrb[7:0]; 
          tr.wstrb[6] = wstrb[7:0];
          tr.wstrb[7] = wstrb[7:0];
          end
          else if(awsize==4) begin
          tr.data[0] = myData[127:0];
          tr.data[1] = myData[255:128];
          tr.data[2] = myData[383:256];
          tr.data[3] = myData[511:384];
          tr.data[4] = myData[639:512];
          tr.data[5] = myData[767:640];
          tr.data[6] = myData[895:768];
          tr.data[7] = myData[1023:896];
          tr.wstrb[0] = wstrb[15:0];
          tr.wstrb[1] = wstrb[15:0]; 
          tr.wstrb[2] = wstrb[15:0];
          tr.wstrb[3] = wstrb[15:0];
          tr.wstrb[4] = wstrb[15:0];
          tr.wstrb[5] = wstrb[15:0]; 
          tr.wstrb[6] = wstrb[15:0];
          tr.wstrb[7] = wstrb[15:0];
          end
         end
      16: begin
	  if(awsize==3) begin
          tr.data[0] = myData[63:0];
          tr.data[1] = myData[127:64];
          tr.data[2] = myData[191:128];
          tr.data[3] = myData[255:192];
          tr.data[4] = myData[319:256];
          tr.data[5] = myData[383:320];
          tr.data[6] = myData[447:384];
          tr.data[7] = myData[511:448];
          tr.data[8] = myData[575:512];
          tr.data[9] = myData[639:576];
          tr.data[10] = myData[703:640];
          tr.data[11] = myData[767:704];
          tr.data[12] = myData[831:768];
          tr.data[13] = myData[895:832];
          tr.data[14] = myData[959:896];
          tr.data[15] = myData[1023:960];
          tr.wstrb[0] = wstrb[7:0];
          tr.wstrb[1] = wstrb[7:0]; 
          tr.wstrb[2] = wstrb[7:0];
          tr.wstrb[3] = wstrb[7:0];
          tr.wstrb[4] = wstrb[7:0];
          tr.wstrb[5] = wstrb[7:0]; 
          tr.wstrb[6] = wstrb[7:0];
          tr.wstrb[7] = wstrb[7:0];
          tr.wstrb[8] = wstrb[7:0];
          tr.wstrb[9] = wstrb[7:0]; 
          tr.wstrb[10] = wstrb[7:0];
          tr.wstrb[11] = wstrb[7:0];
          tr.wstrb[12] = wstrb[7:0];
          tr.wstrb[13] = wstrb[7:0]; 
          tr.wstrb[14] = wstrb[7:0];
          tr.wstrb[15] = wstrb[7:0];
          end
         end
      default: `uvm_error("seq_lib", $sformatf("Unsupported length %d for AXI transfer",tr.burst_length))
   endcase
       
            `uvm_info("BODY",$sformatf("burst_length:%0h burst_size:%0h xact_type:%0s domain_type:%0s wstrb:%0p addr:%0h write_data:%0p",tr.burst_length,tr.burst_size,tr.xact_type,tr.domain_type,tr.wstrb,tr.addr,tr.data),UVM_LOW)    
    `svt_xvm_send(tr)
    get_response(rsp);
    tr.wait_for_transaction_end();
  endtask: body

endclass: seq_lib_svt_data_integrity_ace_write_sequence

class seq_lib_svt_data_integrity_ace_read_sequence extends svt_axi_master_base_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `svt_xvm_object_utils(seq_lib_svt_data_integrity_ace_read_sequence)

  svt_axi_master_transaction 			tr;
  bit m_coh_transaction;
  svt_axi_transaction::coherent_xact_type_enum        m_ace_rd_addr_chnl_snoop;
  /** Address to be written */
  bit [`SVT_AXI_ADDR_WIDTH-1 : 0] myAddr;
  int  addr_offset;
  bit  directed_wr_rd;
  /** Expected data. This is used to check the return value. */
  bit [`SVT_AXI_MAX_DATA_WIDTH-1 : 0] rdata;
  bit [31:0] myData ;
  bit [CAXSIZE-1:0] arsize;
  bit dom = 0;

  bit [CAXLEN-1:0] axlen;
<%if(obj.Block == "dmi" || obj.Block == "io_aiu" || obj.Block == "aceaiu" ) { %> 
  bit [WARID-1:0] arid;
  bit [WAWID-1:0] awid;
<% } else { %>    
  bit [WAXID-1:0] arid;
  bit [WAXID-1:0] awid;
<% } %>
  

  function new(string name="seq_lib_svt_data_integrity_ace_read_sequence");
    super.new(name);
  endfunction

  virtual task body();
    //super.body();
   
          m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READNOSNOOP;

   `svt_xvm_create(tr)
    tr.randomize() with {
      //xact_type == svt_axi_transaction::COHERENT;
      coherent_xact_type == local::m_ace_rd_addr_chnl_snoop;
      domain_type== svt_axi_transaction::SYSTEMSHAREABLE;
      prot_type==svt_axi_transaction::DATA_SECURE_NORMAL;
      atomic_type == svt_axi_transaction::NORMAL;
      burst_type ==svt_axi_transaction::WRAP;
      cache_type==0;
      associate_barrier==0;
      barrier_type == 0; //no AXBAR=1;
      //addr == /*local::*/myAddr;
      id <='h1f;
       data_before_addr == 1;
       reference_event_for_addr_valid_delay inside {svt_axi_transaction::FIRST_WVALID_DATA_BEFORE_ADDR ,svt_axi_transaction::FIRST_DATA_HANDSHAKE_DATA_BEFORE_ADDR};
  //    addr_valid_delay                       > k_addr_valid_delay; 
        addr_valid_delay                       > 1;

     
      if(axlen <1)
      burst_length == 4;
      else
      burst_length == local::axlen;
      //burst_length == 4;
      foreach(data[i]) data[i]==0;
     // data_before_addr == 0;
      foreach(cache_write_data[i]) cache_write_data[i]==0;
    };

      tr.addr = myAddr;
     case(arsize)

      3: tr.burst_size   = svt_axi_transaction::BURST_SIZE_64BIT;
      4: tr.burst_size   = svt_axi_transaction::BURST_SIZE_128BIT;
      5: tr.burst_size   = svt_axi_transaction::BURST_SIZE_256BIT;
      default:tr.burst_size   = svt_axi_transaction::BURST_SIZE_32BIT;
     endcase
     tr.rresp        = new[tr.burst_length];
<% for(var idx = 0; idx < obj.nAIUs; idx++) {
 if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') ) { 
     dom = 1;
  } else {
     dom = 0;
  }
} %>
   if(dom)
     tr.coh_rresp     = new[tr.burst_length];	   

    //tr.data         = new[tr.burst_length];
    tr.rready_delay = new[tr.burst_length];
    foreach (tr.rready_delay[i]) begin
        tr.rready_delay[i]=i;
      end
      
      tr.xact_type = svt_axi_transaction::COHERENT;    
      `uvm_info("BODY",$sformatf("burst_length:%0h burst_size:%0h xact_type:%0s domain_type:%0s rresp_size:%0h addr:%0p read_data:%0p",tr.burst_length,tr.burst_size,tr.xact_type,tr.domain_type,tr.rresp.size(),tr.addr,tr.data),UVM_LOW)    

    `svt_xvm_send(tr)
     get_response(rsp);
    tr.wait_for_transaction_end();
    //BELOW FOR PRINT PURPOSE ONLY
    //process the 32bit read data on a 128 bit data bus
    //rdata = tr.data[0];

endtask: body

endclass: seq_lib_svt_data_integrity_ace_read_sequence


class seq_lib_svt_ace_wlunq_sequence extends svt_axi_master_base_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `svt_xvm_object_utils(seq_lib_svt_ace_wlunq_sequence)
 
 svt_axi_transaction::coherent_xact_type_enum        m_ace_wr_addr_chnl_snoop;
 bit m_coh_transaction;

  /** Address to be written */
  rand bit [`SVT_AXI_ADDR_WIDTH-1 : 0] myAddr;
  int addr_offset;
  bit directed_wr_rd;
  /** Data to be written */
  bit [4*`SVT_AXI_MAX_DATA_WIDTH-1 : 0] myData ;
  //bit [31 : 0] myData ;
  bit [`SVT_AXI_MAX_DATA_WIDTH/8-1:0] wstrb;

<%if(obj.Block == "dmi" || obj.Block == "io_aiu" || obj.Block == "aceaiu" ) { %> 
  bit [WARID-1:0] arid;
  bit [WAWID-1:0] awid;
<% } else { %>    
  bit [WAXID-1:0] arid;
  bit [WAXID-1:0] awid;
<% } %>
  bit [CAXLEN-1:0] axlen;
  bit [CAXSIZE-1:0] awsize;
  int k_addr_valid_delay;


  function new(string name="seq_lib_svt_ace_wlunq_sequence");
    super.new(name);
  endfunction

  virtual task body();
    svt_axi_master_transaction 			tr;
    //super.body();
    if(!$value$plusargs("k_addr_valid_delay=%d",k_addr_valid_delay))begin
      k_addr_valid_delay = 1;
    end

    `svt_xvm_create(tr)
    tr.randomize() with {
     xact_type == svt_axi_transaction::COHERENT;
      coherent_xact_type inside {svt_axi_transaction::WRITEUNIQUE,svt_axi_transaction::WRITELINEUNIQUE};
      atomic_type == svt_axi_transaction::NORMAL;
      burst_type ==svt_axi_transaction::INCR;
      domain_type== svt_axi_transaction::INNERSHAREABLE;
      addr == local::myAddr;
      //critical timing based
      data_before_addr == 1;
      prot_type==svt_axi_transaction::DATA_SECURE_NORMAL;
      reference_event_for_addr_valid_delay inside {svt_axi_transaction::FIRST_WVALID_DATA_BEFORE_ADDR ,svt_axi_transaction::FIRST_DATA_HANDSHAKE_DATA_BEFORE_ADDR};
      addr_valid_delay                       > k_addr_valid_delay; //Need to wait for pending transactions to complete e.g. DTRRsp (~100 cycles may be, fullsys_test: 5us)
      //match compile option to be greater than 102 say +define+SVT_AXI_MAX_ADDR_VALID_DELAY=103 (to avoid constraint fail)
       burst_size==local::awsize;
      burst_length == local::axlen;      //Rama: initialize data/cache/strobe to 0 and load predictables in post_randomize later (below)
     };
//send trans to VIP
    `svt_xvm_send(tr)
    get_response(rsp);
    tr.wait_for_transaction_end();
  endtask: body

endclass: seq_lib_svt_ace_wlunq_sequence

class seq_lib_svt_ace_wrevict_sequence extends svt_axi_master_base_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `svt_xvm_object_utils(seq_lib_svt_ace_wrevict_sequence)
 
 svt_axi_transaction::coherent_xact_type_enum        m_ace_wr_addr_chnl_snoop;
 bit m_coh_transaction;

  /** Address to be written */
  rand bit [`SVT_AXI_ADDR_WIDTH-1 : 0] myAddr;
  int addr_offset;
  bit directed_wr_rd;
  /** Data to be written */
  bit [4*`SVT_AXI_MAX_DATA_WIDTH-1 : 0] myData ;
  //bit [31 : 0] myData ;
  bit [`SVT_AXI_MAX_DATA_WIDTH/8-1:0] wstrb;

<%if(obj.Block == "dmi" || obj.Block == "io_aiu" || obj.Block == "aceaiu" ) { %> 
  bit [WARID-1:0] arid;
  bit [WAWID-1:0] awid;
<% } else { %>    
  bit [WAXID-1:0] arid;
  bit [WAXID-1:0] awid;
<% } %>
  bit [CAXLEN-1:0] axlen;
  bit [CAXSIZE-1:0] awsize;
  int k_addr_valid_delay;


  function new(string name="seq_lib_svt_ace_wrevict_sequence");
    super.new(name);
  endfunction

  virtual task body();
    svt_axi_master_transaction 			tr;
    //super.body();
    if(!$value$plusargs("k_addr_valid_delay=%d",k_addr_valid_delay))begin
      k_addr_valid_delay = 1;
    end

    `svt_xvm_create(tr)
    tr.randomize() with {

    //  xact_type == svt_axi_transaction::COHERENT;
     xact_type == svt_axi_transaction::COHERENT;
      coherent_xact_type inside {svt_axi_transaction::WRITECLEAN,svt_axi_transaction::WRITEBACK,svt_axi_transaction::EVICT, svt_axi_transaction::WRITEEVICT};
      if(coherent_xact_type == svt_axi_transaction::WRITEEVICT || coherent_xact_type == svt_axi_transaction::EVICT){ port_cfg.writeevict_enable == 1;
	 	port_cfg.awunique_enable == 1; }
      atomic_type == svt_axi_transaction::NORMAL;
      burst_type ==svt_axi_transaction::INCR;
      prot_type==svt_axi_transaction::DATA_SECURE_NORMAL;
      domain_type== svt_axi_transaction::INNERSHAREABLE;
      addr == local::myAddr;
      //critical timing based
      data_before_addr == 1;
      reference_event_for_addr_valid_delay inside {svt_axi_transaction::FIRST_WVALID_DATA_BEFORE_ADDR ,svt_axi_transaction::FIRST_DATA_HANDSHAKE_DATA_BEFORE_ADDR};
      addr_valid_delay                       > k_addr_valid_delay; //Need to wait for pending transactions to complete e.g. DTRRsp (~100 cycles may be, fullsys_test: 5us)
      //match compile option to be greater than 102 say +define+SVT_AXI_MAX_ADDR_VALID_DELAY=103 (to avoid constraint fail)
      burst_length == local::axlen;      //Rama: initialize data/cache/strobe to 0 and load predictables in post_randomize later (below)
     };
//send trans to VIP
    `svt_xvm_send(tr)
    get_response(rsp);
    tr.wait_for_transaction_end();
  endtask: body

endclass: seq_lib_svt_ace_wrevict_sequence


class seq_lib_svt_ace_write_sequence extends svt_axi_master_base_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `svt_xvm_object_utils(seq_lib_svt_ace_write_sequence)
 
 svt_axi_transaction::coherent_xact_type_enum        m_ace_wr_addr_chnl_snoop;
 bit m_coh_transaction;

  /** Address to be written */
  rand bit [`SVT_AXI_ADDR_WIDTH-1 : 0] myAddr;
  int addr_offset;
  bit directed_wr_rd;
  /** Data to be written */
  bit [1023 : 0] myData ;
  //bit [31 : 0] myData ;
  bit [31:0] wstrb;

<%if(obj.Block == "dmi" || obj.Block == "io_aiu" || obj.Block == "aceaiu" ) { %> 
  bit [WARID-1:0] arid;
  bit [WAWID-1:0] awid;
<% } else { %>    
  bit [WAXID-1:0] arid;
  bit [WAXID-1:0] awid;
<% } %>
  bit [CAXLEN-1:0] axlen;
  bit [CAXSIZE-1:0] awsize;
  int k_addr_valid_delay;


  function new(string name="seq_lib_svt_ace_write_sequence");
    super.new(name);
  endfunction

  virtual task body();
    svt_axi_master_transaction 			tr;
    //super.body();
    if(!$value$plusargs("k_addr_valid_delay=%d",k_addr_valid_delay))begin
      k_addr_valid_delay = 1;
    end
    if (m_coh_transaction == 0) begin
          m_ace_wr_addr_chnl_snoop = svt_axi_transaction::WRITENOSNOOP;
       end
       else begin
           m_ace_wr_addr_chnl_snoop = svt_axi_transaction::WRITEUNIQUE;
       end
    `svt_xvm_create(tr)
    if(cfg.axi_interface_type==svt_axi_port_configuration::AXI4) begin
      tr.randomize() with {

      xact_type == svt_axi_transaction::WRITE;
      prot_type==svt_axi_transaction::DATA_SECURE_NORMAL;
      cache_type==0;
      addr == local::myAddr;
      id   == local::awid;

      //critical timing based
      //data_before_addr == 1;
      //reference_event_for_addr_valid_delay inside {svt_axi_transaction::FIRST_WVALID_DATA_BEFORE_ADDR ,svt_axi_transaction::FIRST_DATA_HANDSHAKE_DATA_BEFORE_ADDR};
      addr_valid_delay                       > k_addr_valid_delay; //Need to wait for pending transactions to complete e.g. DTRRsp (~100 cycles may be, fullsys_test: 5us)
      //match compile option to be greater than 102 say +define+SVT_AXI_MAX_ADDR_VALID_DELAY=103 (to avoid constraint fail)
      if(directed_wr_rd == 1)
       burst_size==local::awsize;
      else
      burst_size==svt_axi_transaction::BURST_SIZE_32BIT;
      if(local::axlen<1)
      burst_length == 1;
      else 
      burst_length == local::axlen;      //Rama: initialize data/cache/strobe to 0 and load predictables in post_randomize later (below)
      foreach(data[i]) data[i]==0;
      foreach(wstrb[i]) wstrb[i]==0;
      foreach(cache_write_data[i]) cache_write_data[i]==0;
     };
    end else begin
      tr.randomize() with {

    //  xact_type == svt_axi_transaction::COHERENT;
     xact_type == svt_axi_transaction::COHERENT;
      coherent_xact_type == local::m_ace_wr_addr_chnl_snoop;
      atomic_type == svt_axi_transaction::NORMAL;
      burst_type ==svt_axi_transaction::INCR;
      if(m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITENOSNOOP)
      domain_type== svt_axi_transaction::SYSTEMSHAREABLE;
      else
      domain_type== svt_axi_transaction::INNERSHAREABLE;
      prot_type==svt_axi_transaction::DATA_SECURE_NORMAL;
      if(m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITENOSNOOP)
      cache_type==0;
      associate_barrier==0;
      barrier_type == 0; //no AXBAR=1;
      addr == local::myAddr;
      id   == local::awid;

      //critical timing based
      data_before_addr == 1;
      reference_event_for_addr_valid_delay inside {svt_axi_transaction::FIRST_WVALID_DATA_BEFORE_ADDR ,svt_axi_transaction::FIRST_DATA_HANDSHAKE_DATA_BEFORE_ADDR};
      addr_valid_delay                       > k_addr_valid_delay; //Need to wait for pending transactions to complete e.g. DTRRsp (~100 cycles may be, fullsys_test: 5us)
      //match compile option to be greater than 102 say +define+SVT_AXI_MAX_ADDR_VALID_DELAY=103 (to avoid constraint fail)
      if(directed_wr_rd == 1)
       burst_size==local::awsize;
      else
      burst_size==svt_axi_transaction::BURST_SIZE_32BIT;
      if(local::axlen<1)
      burst_length == 1;
      else 
      burst_length == local::axlen;      //Rama: initialize data/cache/strobe to 0 and load predictables in post_randomize later (below)
      foreach(data[i]) data[i]==0;
      foreach(wstrb[i]) wstrb[i]==0;
      foreach(cache_write_data[i]) cache_write_data[i]==0;
     };
     end

    //=====================================================
    //post randomzie
    //=====================================================
    //process the 32bit write data/strobe on 128 bit data bus
  //process the 32bit write data/strobe on 128 bit data bus
    
   
    
    if(directed_wr_rd) begin
         case (tr.burst_length)
      1:  begin
	  if(awsize==4) begin
 	  tr.data[0]  = myData[127: 0];
          tr.wstrb[0] = wstrb[15:0];
          end
          else if(awsize==5) begin
	  tr.data[0]  = myData[255: 0];
          tr.wstrb[0] = wstrb[31:0];
	  end
          // else if (awsize==16) begin
         // tr.wstrb[0] = wstrb[15:0];
         // end
         // else if (awsize==32) begin
         // tr.wstrb[0] = wstrb[31:0];
         //end
	end
      2: begin
          if(awsize==4) begin
          tr.data[0] =  myData[127: 0];
          tr.data[1] =  myData[255 :128];
          tr.wstrb[0] = wstrb[15:0];
          tr.wstrb[1] = wstrb[15:0];
	  end
          else if(awsize==5) begin
          tr.data[0] =  myData[255: 0];
          tr.data[1] =  myData[511:256];
          tr.wstrb[0] = wstrb[31:0];
          tr.wstrb[1] = wstrb[31:0];
	  end
         /* else if (awsize==16) begin
          tr.wstrb[0] = wstrb[15:0];
          tr.wstrb[1] = wstrb[15:0];
          end
          else if (awsize==32) begin
          tr.wstrb[0] = wstrb[31:0];
          tr.wstrb[1] = wstrb[31:0];
          end  */
         end
      3: begin
	  if(awsize==4) begin
          tr.data[0] = myData[127: 0];
          tr.data[1] = myData[255 :128];
          tr.data[2] = myData[383:256];
          tr.wstrb[0] = wstrb[15:0];
          tr.wstrb[1] = wstrb[15:0]; 
          tr.wstrb[2] = wstrb[15:0];
	  end
	  else if(awsize==5) begin
          tr.data[0] = myData[255: 0];
          tr.data[1] = myData[511 :256];
          tr.data[2] = myData[767:512];
          tr.wstrb[0] = wstrb[31:0];
          tr.wstrb[1] = wstrb[31:0]; 
          tr.wstrb[2] = wstrb[31:0];
	  end
         end
      4: begin
	  if(awsize==4) begin
          tr.data[0] = myData[127: 0];
          tr.data[1] = myData[255:128];
          tr.data[2] = myData[383:256];
          tr.data[3] = myData[511:384];
          tr.wstrb[0] = wstrb[15:0];
          tr.wstrb[1] = wstrb[15:0]; 
          tr.wstrb[2] = wstrb[15:0];
          tr.wstrb[3] = wstrb[15:0];
	  end
	  else if(awsize==5) begin
          tr.data[0] = myData[255: 0];
          tr.data[1] = myData[511 :256];
          tr.data[2] = myData[767:512];
          tr.data[3] = myData[1023:768];
          tr.wstrb[0] = wstrb[31:0];
          tr.wstrb[1] = wstrb[31:0]; 
          tr.wstrb[2] = wstrb[31:0];
          tr.wstrb[3] = wstrb[31:0];
	  end
           end
      default: `uvm_error("seq_lib", $sformatf("Unsupported length %d for AXI transfer",tr.burst_length))
   endcase
       
       end
       else begin
	if(addr_offset ==0) begin
	  tr.data[0]  = myData[31:0];
	  tr.wstrb[0] = wstrb[3:0];
         `uvm_info("seq_lib_svt_ace_write_sequence", $sformatf("1: myAddr = 0x%0h, myData = %0h, tr.addr[3:0]= %0h, tr.data[0] = %0h", myAddr, myData, tr.addr[3:0],     tr.data[0]), UVM_NONE)
	end
	if(addr_offset==4) begin
	  tr.data[0]  = myData[63:32];
	  tr.wstrb[0] = wstrb[7:4];
          `uvm_info("seq_lib_svt_ace_write_sequence", $sformatf("2: myAddr = 0x%0h, myData = %0h, tr.addr[3:0]= %0h, tr.data[0] = %0h", myAddr, myData, tr.addr[3:0], {myData,32'h0}), UVM_NONE)
	end
	if(addr_offset==8) begin
	  tr.data[0]  = myData[95:64];
	  tr.wstrb[0] = wstrb[11:8];
          `uvm_info("seq_lib_svt_ace_write_sequence", $sformatf("3: myAddr = 0x%0h, myData = %0h, tr.addr[3:0]= %0h, tr.data[0] = %0h", myAddr, myData, tr.addr[3:0], {myData,64'h0}), UVM_NONE)
	end
	if(addr_offset=='hc) begin
	  tr.data[0]  =  myData[127:96];
	  tr.wstrb[0] = wstrb[15:12];
          `uvm_info("seq_lib_svt_ace_write_sequence", $sformatf("4: myAddr = 0x%0h, myData = %0h, tr.addr[3:0]= %0h, tr.data[0] = %0h", myAddr, myData, tr.addr[3:0], {myData,96'h0}), UVM_NONE)
	end
	if(addr_offset=='hc) begin
	  tr.data[0]  =  myData[127:96];
	  tr.wstrb[0] = wstrb[15:12];
          `uvm_info("seq_lib_svt_ace_write_sequence", $sformatf("4: myAddr = 0x%0h, myData = %0h, tr.addr[3:0]= %0h, tr.data[0] = %0h", myAddr, myData, tr.addr[3:0], {myData,96'h0}), UVM_NONE)
	end
	if(addr_offset=='h10) begin
	  tr.data[0]  =  myData[159:128];
	  tr.wstrb[0] = wstrb[19:16];
          `uvm_info("seq_lib_svt_ace_write_sequence", $sformatf("4: myAddr = 0x%0h, myData = %0h, tr.addr[3:0]= %0h, tr.data[0] = %0h", myAddr, myData, tr.addr[3:0], {myData,96'h0}), UVM_NONE)
	end
	if(addr_offset=='h14) begin
	  tr.data[0]  =  myData[191:160];
	  tr.wstrb[0] = wstrb[23:20];
          `uvm_info("seq_lib_svt_ace_write_sequence", $sformatf("4: myAddr = 0x%0h, myData = %0h, tr.addr[3:0]= %0h, tr.data[0] = %0h", myAddr, myData, tr.addr[3:0], {myData,96'h0}), UVM_NONE)
	end
	if(addr_offset=='h18) begin
	  tr.data[0]  =  myData[223:192];
	  tr.wstrb[0] = wstrb[27:24];
          `uvm_info("seq_lib_svt_ace_write_sequence", $sformatf("4: myAddr = 0x%0h, myData = %0h, tr.addr[3:0]= %0h, tr.data[0] = %0h", myAddr, myData, tr.addr[3:0], {myData,96'h0}), UVM_NONE)
	end
	if(addr_offset=='h1c) begin
	  tr.data[0]  =  myData[255:224];
	  tr.wstrb[0] = wstrb[31:28];
          `uvm_info("seq_lib_svt_ace_write_sequence", $sformatf("4: myAddr = 0x%0h, myData = %0h, tr.addr[3:0]= %0h, tr.data[0] = %0h", myAddr, myData, tr.addr[3:0], {myData,96'h0}), UVM_NONE)
	end
end 
    //=====================================================
    //send to VIP
    //=====================================================
    //send trans to VIP
    `svt_xvm_send(tr)
    get_response(rsp);
    tr.wait_for_transaction_end();
  endtask: body

endclass: seq_lib_svt_ace_write_sequence

// =============================================================================
class seq_lib_svt_ace_read_sequence extends svt_axi_master_base_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `svt_xvm_object_utils(seq_lib_svt_ace_read_sequence)

  svt_axi_master_transaction 			tr;
  bit m_coh_transaction;
  svt_axi_transaction::coherent_xact_type_enum        m_ace_rd_addr_chnl_snoop;
  /** Address to be written */
  rand bit [`SVT_AXI_ADDR_WIDTH-1 : 0] myAddr;
  int  addr_offset;
  bit  directed_wr_rd;
  /** Expected data. This is used to check the return value. */
  bit [`SVT_AXI_MAX_DATA_WIDTH-1 : 0] rdata;
  bit [31:0] myData ;
  bit [CAXSIZE-1:0] arsize;

  bit [CAXLEN-1:0] axlen;
<%if(obj.Block == "dmi" || obj.Block == "io_aiu" || obj.Block == "aceaiu" ) { %> 
  bit [WARID-1:0] arid;
  bit [WAWID-1:0] awid;
<% } else { %>    
  bit [WAXID-1:0] arid;
  bit [WAXID-1:0] awid;
<% } %>
  

  function new(string name="seq_lib_svt_ace_read_sequence");
    super.new(name);
  endfunction

  virtual task body();
    //super.body();
      if (m_coh_transaction == 0) begin
   
          m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READNOSNOOP;
       end
       else begin
           m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READONCE;
       end

   `svt_xvm_create(tr)
    if(cfg.axi_interface_type==svt_axi_port_configuration::AXI4) begin
      tr.randomize() with {
      xact_type == svt_axi_transaction::READ;
      prot_type==svt_axi_transaction::DATA_SECURE_NORMAL;
      atomic_type == svt_axi_transaction::NORMAL;
      burst_type ==svt_axi_transaction::INCR;
      cache_type==0;
      addr == local::myAddr;
      id ==   local::arid;
       //data_before_addr == 1;
       //reference_event_for_addr_valid_delay inside {svt_axi_transaction::FIRST_WVALID_DATA_BEFORE_ADDR ,svt_axi_transaction::FIRST_DATA_HANDSHAKE_DATA_BEFORE_ADDR};
        addr_valid_delay                       > 1;

      if(directed_wr_rd == 1)
      burst_size==local::arsize; 
      else
      burst_size==3'b010; //svt_axi_transaction::BURST_SIZE_32BIT;
      if(axlen <1)
      burst_length == 1;
      else
      burst_length == local::axlen;
      foreach(data[i]) data[i]==0;
      foreach(cache_write_data[i]) cache_write_data[i]==0;
    };
    end else begin
      tr.randomize() with {
      xact_type == svt_axi_transaction::COHERENT;
      coherent_xact_type == local::m_ace_rd_addr_chnl_snoop;
      if(m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READNOSNOOP)
      domain_type== svt_axi_transaction::SYSTEMSHAREABLE;
      else
      domain_type== svt_axi_transaction::INNERSHAREABLE;
      prot_type==svt_axi_transaction::DATA_SECURE_NORMAL;
      atomic_type == svt_axi_transaction::NORMAL;
      burst_type ==svt_axi_transaction::INCR;
      if(m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READNOSNOOP)
      cache_type==0;
      associate_barrier==0;
      barrier_type == 0; //no AXBAR=1;
      addr == local::myAddr;
      id ==   local::arid;
       //data_before_addr == 1;
       //reference_event_for_addr_valid_delay inside {svt_axi_transaction::FIRST_WVALID_DATA_BEFORE_ADDR ,svt_axi_transaction::FIRST_DATA_HANDSHAKE_DATA_BEFORE_ADDR};
        addr_valid_delay                       > 1;

      if(directed_wr_rd == 1)
      burst_size==local::arsize; 
      else
      burst_size==3'b010; //svt_axi_transaction::BURST_SIZE_32BIT;
      if(axlen <1)
      burst_length == 1;
      else
      burst_length == local::axlen;
      foreach(data[i]) data[i]==0;
     // data_before_addr == 0;
      foreach(cache_write_data[i]) cache_write_data[i]==0;
    };
    end
    
    `svt_xvm_send(tr)
     get_response(rsp);
    tr.wait_for_transaction_end();
    //BELOW FOR PRINT PURPOSE ONLY
    //process the 32bit read data on a 128 bit data bus
    //rdata = tr.data[0];

endtask: body

endclass: seq_lib_svt_ace_read_sequence


class seq_lib_svt_ace_rdunq_sequence extends svt_axi_master_base_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `svt_xvm_object_utils(seq_lib_svt_ace_rdunq_sequence)

  svt_axi_master_transaction 			tr;
  bit m_coh_transaction;
  svt_axi_transaction::coherent_xact_type_enum        m_ace_rd_addr_chnl_snoop;
  /** Address to be written */
  rand bit [`SVT_AXI_ADDR_WIDTH-1 : 0] myAddr;
  int  addr_offset;
  bit  directed_wr_rd;
  /** Expected data. This is used to check the return value. */
  bit [`SVT_AXI_MAX_DATA_WIDTH-1 : 0] rdata;
  bit [31:0] myData ;
  bit [CAXSIZE-1:0] arsize;

  bit [CAXLEN-1:0] axlen;
<%if(obj.Block == "dmi" || obj.Block == "io_aiu" || obj.Block == "aceaiu" ) { %> 
  bit [WARID-1:0] arid;
  bit [WAWID-1:0] awid;
<% } else { %>    
  bit [WAXID-1:0] arid;
  bit [WAXID-1:0] awid;
<% } %>
  bit random_ud;
  
  function new(string name="seq_lib_svt_ace_rdunq_sequence");
    super.new(name);
  endfunction

  virtual task body();
    svt_configuration get_cfg;
    svt_axi_master_agent              my_agent;
    `SVT_XVM(component)           my_component;
    svt_axi_cache                            my_cache;
        int data_size;

    bit is_unique,is_clean;


    //super.body();
my_component = p_sequencer.get_parent();
    void'($cast(my_agent,my_component));
    if (my_agent != null)
      my_cache = my_agent.get_cache();

    //p_sequencer.get_cfg(get_cfg);
    //if (!$cast(cfg, get_cfg)) begin
    //  `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    //end

   `svt_xvm_create(tr)
    tr.randomize() with {
      //port_cfg == cfg;
      xact_type == svt_axi_transaction::COHERENT;
      coherent_xact_type == svt_axi_transaction::READUNIQUE;
      domain_type== svt_axi_transaction::INNERSHAREABLE;
      atomic_type == svt_axi_transaction::NORMAL;
      burst_type ==svt_axi_transaction::INCR;
      prot_type==svt_axi_transaction::DATA_SECURE_NORMAL;
      cache_type[1]==1;
      addr == local::myAddr;
      burst_size==local::arsize; 
      burst_length == local::axlen;
      //foreach(data[i]) data[i]==0;
     // data_before_addr == 0;
      //foreach(cache_write_data[i]) cache_write_data[i]==0;
    };
    
    `svt_xvm_send(tr)
     get_response(rsp);
    tr.wait_for_transaction_end();

 if ($test$plusargs("wrlunq_wrunq_test")) begin
  random_ud=$urandom_range(0,1);
 end 
 if ($test$plusargs("cache_maintainance_test")) begin
    random_ud=1;
 end 
    if(random_ud)begin
    is_unique=1;
    is_clean=0;
       if(my_cache != null)begin
         my_cache.update_status(tr.addr,is_unique,is_clean);
       end
    end

    //BELOW FOR PRINT PURPOSE ONLY
    //process the 32bit read data on a 128 bit data bus
    //rdata = tr.data[0];

endtask: body

endclass: seq_lib_svt_ace_rdunq_sequence

class seq_lib_svt_ace_all_read_sequence extends svt_axi_master_base_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `svt_xvm_object_utils(seq_lib_svt_ace_all_read_sequence)

  svt_axi_master_transaction 			tr;
  bit m_coh_transaction;
  svt_axi_transaction::coherent_xact_type_enum        m_ace_rd_addr_chnl_snoop;
  /** Address to be written */
  rand bit [`SVT_AXI_ADDR_WIDTH-1 : 0] myAddr;
  int  addr_offset;
  bit  directed_wr_rd;
  /** Expected data. This is used to check the return value. */
  bit [`SVT_AXI_MAX_DATA_WIDTH-1 : 0] rdata;
  bit [31:0] myData ;
  bit [CAXSIZE-1:0] arsize;

  bit [CAXLEN-1:0] axlen;
<%if(obj.Block == "dmi" || obj.Block == "io_aiu" || obj.Block == "aceaiu" ) { %> 
  bit [WARID-1:0] arid;
  bit [WAWID-1:0] awid;
<% } else { %>    
  bit [WAXID-1:0] arid;
  bit [WAXID-1:0] awid;
<% } %>
  

  function new(string name="seq_lib_svt_ace_all_read_sequence");
    super.new(name);
  endfunction

  virtual task body();
    //super.body();
      if (m_coh_transaction == 0) begin
   
          m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READNOSNOOP;
       end
       else begin
           m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READUNIQUE;
       end

   `svt_xvm_create(tr)
    tr.randomize() with {
      xact_type == svt_axi_transaction::COHERENT;
      coherent_xact_type inside { svt_axi_transaction::READONCE,svt_axi_transaction::READSHARED,svt_axi_transaction::READCLEAN,svt_axi_transaction::READNOTSHAREDDIRTY,svt_axi_transaction::READUNIQUE,svt_axi_transaction::CLEANSHARED,svt_axi_transaction::CLEANINVALID,svt_axi_transaction::CLEANUNIQUE,svt_axi_transaction::MAKEUNIQUE,svt_axi_transaction::MAKEINVALID};
      domain_type== svt_axi_transaction::INNERSHAREABLE;
      atomic_type == svt_axi_transaction::NORMAL;
      burst_type ==svt_axi_transaction::INCR;
      prot_type==svt_axi_transaction::DATA_SECURE_NORMAL;
      addr == local::myAddr;
        addr_valid_delay                       > 1;
      burst_size==local::arsize; 
      burst_length == local::axlen;
    };
    
    `svt_xvm_send(tr)
     get_response(rsp);
    tr.wait_for_transaction_end();
    //BELOW FOR PRINT PURPOSE ONLY
    //process the 32bit read data on a 128 bit data bus
    //rdata = tr.data[0];

endtask: body

endclass: seq_lib_svt_ace_all_read_sequence


class snp_cust_seq extends svt_axi_master_base_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `svt_xvm_object_utils(snp_cust_seq)

  /** Address to be written */
  //addr = 8001ffc, addr_mask = f, addr_offset = c
  bit [`SVT_AXI_ADDR_WIDTH-1 : 0] myAddr;
  bit [`SVT_AXI_ADDR_WIDTH-1 : 0] sa;
  bit [`SVT_AXI_ADDR_WIDTH-1 : 0] ea;


  bit [`SVT_AXI_MAX_DATA_WIDTH-1 : 0] rdata;
  bit [31:0] myData = 'hbeefbaad;
  //rand bit [31:0] myData;

  bit [CAXLEN-1:0] axlen;
<%if(obj.Block == "dmi" || obj.Block == "io_aiu" || obj.Block == "aceaiu" ) { %> 
  bit [WARID-1:0] arid = 0;
  bit [WAWID-1:0] awid;
<% } else { %>    
  bit [WAXID-1:0] arid;
  bit [WAXID-1:0] awid=0;
<% } %>
  int k_addr_valid_delay;

  function new(string name="snp_cust_seq");
    super.new(name);
  endfunction

  virtual task body();
    svt_axi_master_transaction 			tr;
    //super.body();
    if(!$value$plusargs("k_addr_valid_delay=%d",k_addr_valid_delay))begin
      k_addr_valid_delay = 1;
    end

           //get_valid_addr("DII", 0, myAddr);
           //get_valid_addr("DMI", 0, myAddr);
           myAddr[5:0] = '0; //aligned
           `uvm_info("snp_cust_seq", $sformatf("Retrieved myAddr = 0x%0h", myAddr), UVM_NONE)

          `svt_xvm_create(tr)
          tr.randomize() with {
            xact_type == svt_axi_transaction::COHERENT;
            coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
            atomic_type == svt_axi_transaction::NORMAL;
            burst_type ==svt_axi_transaction::INCR;
            domain_type== svt_axi_transaction::NONSHAREABLE;
            prot_type==svt_axi_transaction::DATA_SECURE_NORMAL;
            cache_type==0;
            associate_barrier==0;
            barrier_type == 0; //no AXBAR=1;
            addr == myAddr;
            id   == awid;

            //critical timing based
            data_before_addr == 1;
            reference_event_for_addr_valid_delay inside {svt_axi_transaction::FIRST_WVALID_DATA_BEFORE_ADDR ,svt_axi_transaction::FIRST_DATA_HANDSHAKE_DATA_BEFORE_ADDR};
            addr_valid_delay                       > k_addr_valid_delay; //Need to wait for pending transactions to complete e.g. DTRRsp (~100 cycles may be, fullsys_test: 5us)

            burst_size==svt_axi_transaction::BURST_SIZE_32BIT;
            burst_length == 1;
            //Rama: initialize data/cache/strobe to 0 and load predictables in post_randomize later (below)
            foreach(data[i]) data[i]==0;
            foreach(wstrb[i]) wstrb[i]==0;
            foreach(cache_write_data[i]) cache_write_data[i]==0;

          };

          //=====================================================
          //post randomzie
          //=====================================================
          //process the 32bit write data/strobe on 128 bit data bus
              if(tr.addr[3:0]==0) begin
                tr.data[0]=myData;
                tr.wstrb[0]=4'hf;
                `uvm_info("snp_cust_seq", $sformatf("1: myAddr = 0x%0h, myData = %0h, tr.addr[3:0]= %0h, tr.data[0] = %0h", myAddr, myData, tr.addr[3:0],     tr.data[0]), UVM_NONE)
              end
              if(tr.addr[3:0]==4) begin
                tr.data[0]={myData,32'h0};
                tr.wstrb[0]={4'hf,4'h0};
                `uvm_info("snp_cust_seq", $sformatf("2: myAddr = 0x%0h, myData = %0h, tr.addr[3:0]= %0h, tr.data[0] = %0h", myAddr, myData, tr.addr[3:0], {myData,32'h0}), UVM_NONE)
              end
              if(tr.addr[3:0]==8) begin
                tr.data[0]={myData,64'h0};
                tr.wstrb[0]={4'hf,8'h0};
                `uvm_info("snp_cust_seq", $sformatf("3: myAddr = 0x%0h, myData = %0h, tr.addr[3:0]= %0h, tr.data[0] = %0h", myAddr, myData, tr.addr[3:0], {myData,64'h0}), UVM_NONE)
              end
              if(tr.addr[3:0]=='hc) begin
                tr.data[0]={myData,96'h0};
                tr.wstrb[0]={4'hf,12'h0};
                `uvm_info("snp_cust_seq", $sformatf("4: myAddr = 0x%0h, myData = %0h, tr.addr[3:0]= %0h, tr.data[0] = %0h", myAddr, myData, tr.addr[3:0], {myData,96'h0}), UVM_NONE)
              end

          //=====================================================
          //send to VIP
          //=====================================================
          //send trans to VIP
          `svt_xvm_send(tr)
          get_response(rsp);
          tr.wait_for_transaction_end();
   endtask: body
endclass: snp_cust_seq
<% } %>


/**
 * Abstract:
 *
 * Execution phase: main_phase
 * Sequencer: Virtual sequencer in AXI System ENV
*/


//----system env sequences ----
/* M0 initiating MAKEUNIQUE to addr 100000000
   M1 initiating READSHARED to addr 100000000
   M2 initiating READONCE   to addr 10000ff00
*/

//class cust_seq extends svt_axi_system_base_sequence;
//
//   /* AXI environment for setting cache */
//   svt_axi_system_env axi_system_env;
//
//  /** UVM Object Utility macro */
//   `uvm_object_utils(cust_seq)
//
//  /** Sequence length in used to constsrain the sequence length in sub-sequences */
//  rand int unsigned sequence_length;
//
//  /** Constrain the sequence length to a reasonable value */
//  constraint reasonable_sequence_length {
//    sequence_length <= 50;
//    sequence_length >0;
//  }
//
//  /** Class Constructor */
//  function new (string name = "cust_seq");
//    super.new(name);
//  endfunction : new
//  /** Raise an objection if this is the parent sequence */
//  virtual task pre_body();
//    uvm_phase starting_phase_for_curr_seq;
//    super.pre_body();
//`ifdef SVT_UVM_12_OR_HIGHER
//    starting_phase_for_curr_seq = get_starting_phase();
//`else
//    starting_phase_for_curr_seq = starting_phase;
//`endif
//  if (starting_phase_for_curr_seq!=null) begin
//    starting_phase_for_curr_seq.raise_objection(this);
//  end
//  endtask: pre_body
//
//  /** Drop an objection if this is the parent sequence */
//  virtual task post_body();
//    uvm_phase starting_phase_for_curr_seq;
//    super.post_body();
//`ifdef SVT_UVM_12_OR_HIGHER
//    starting_phase_for_curr_seq = get_starting_phase();
//`else
//    starting_phase_for_curr_seq = starting_phase;
//`endif
//  if (starting_phase_for_curr_seq!=null) begin
//    starting_phase_for_curr_seq.drop_objection(this);
//  end
//  endtask: post_body
//
//  virtual task body();
//    bit status;
//    snp_cust_seq  ace_seq;
//
//    `uvm_info("body", "Entered...", UVM_LOW)
//
//    //  status = uvm_resource_db#(svt_axi_system_env)::read_by_name("cust_seq", "axi_system_env", axi_system_env);
//
//    //status = uvm_config_db#(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);
//    //`uvm_info("body", $sformatf("sequence_length is %0d as a result of %0s.", sequence_length, status ? "config DB" : "randomization"), UVM_LOW);
//
//    ace_seq = new("ace_seq");
//    //repeat(2) begin
//    ////random txns
//    //`uvm_do_on_with(ace_seq, p_sequencer.master_sequencer[0],
//    //                {});
//    //end
//    //writenosnoop
//    `uvm_do_on_with(ace_seq, p_sequencer.master_sequencer[0],
//                    {seq_xact_type==svt_axi_transaction::WRITENOSNOOP;
//                     seq_addr=='hcc000000000;});
//    //readnosnoop
//    `uvm_do_on_with(ace_seq, p_sequencer.master_sequencer[0],
//                    {seq_xact_type==svt_axi_transaction::READNOSNOOP;
//                     seq_addr=='hcc000000000;});
//
//    `uvm_info("body", "Exiting...", UVM_LOW)
//  endtask: body
//
//
//endclass: cust_seq

class reg2axi_adapter extends uvm_reg_adapter;

  /** The svt_axi_master_reg_transaction is extended from  the svt_axi_transaction class, with additional constraints required for uvm reg */
  svt_axi_master_reg_transaction axi_reg_trans;

  /** The svt_axi_port_configuration ,which is passed from the Master Agent */
  svt_axi_port_configuration p_cfg=new("p_cfg");

// UVM Field Macros
// ****************************************************************************
  `uvm_object_param_utils_begin(reg2axi_adapter)
    `uvm_field_object(axi_reg_trans, UVM_ALL_ON);
    `uvm_field_object(p_cfg,     UVM_ALL_ON);
  `uvm_object_utils_end
  //----------------------------------------------------------------------------
  /**
  * CONSTUCTOR: Create a new transaction instance, passing the appropriate argument
  * values to the parent class.
  *
  * @param name Instance name of the transaction
  */

  // -----------------------------------------------------------------------------
  function new(string name= "reg2axi_adapter");
    super.new(name);
    supports_byte_enable = 1;
    provides_responses = 1;
    `svt_amba_debug("new", "Reg Model Constructed  .... ");
  endfunction

  // -----------------------------------------------------------------------------
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    bit [`SVT_AXI_TRANSACTION_BURST_SIZE_64:0] burst_size_e;
    bit [`SVT_AXI_WSTRB_WIDTH - 1 :0] wstrb = '0;
  
    axi_reg_trans = svt_axi_master_reg_transaction::type_id::create("axi_reg_trans");
    axi_reg_trans.port_cfg = p_cfg;
  
    if (rw.n_bits > p_cfg.data_width)
      `svt_fatal("reg2bus", "Transfer requested with a data width greater than the configured system data width. Please reconfigure the system with the appropriate data width or reduce the data size");
     `svt_amba_debug("reg2bus", $sformatf("n_bits data = %b log_base_2 n_bits", rw.n_bits));
  
     // Turn the TR burst size into an AXI one (smallest burst is 8bit)
     burst_size_e = $clog2(rw.n_bits) - $clog2(8);
     if (! axi_reg_trans.randomize() with {
       if ((p_cfg.axi_interface_type == svt_axi_port_configuration::AXI3)|| (p_cfg.axi_interface_type == svt_axi_port_configuration::AXI4)|| (p_cfg.axi_interface_type == svt_axi_port_configuration::AXI4_LITE)) {
         axi_reg_trans.xact_type == ((rw.kind == UVM_WRITE) ? svt_axi_master_reg_transaction::WRITE : svt_axi_master_reg_transaction::READ);
  	   }
       else if ((p_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE)|| (p_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE)) {
  	   axi_reg_trans.xact_type == svt_axi_transaction::COHERENT;
   	   axi_reg_trans.coherent_xact_type == ((rw.kind == UVM_READ) ? svt_axi_master_transaction::READNOSNOOP : svt_axi_master_transaction::WRITENOSNOOP);
  	 }
         axi_reg_trans.addr == rw.addr;
         axi_reg_trans.burst_length == 1;
         axi_reg_trans.burst_type == svt_axi_transaction::INCR;
         axi_reg_trans.burst_size == burst_size_e;
        }) begin
        `svt_fatal("reg2bus", " Transaction randomization failed");
     end
  
    if (rw.kind == UVM_WRITE) begin
      axi_reg_trans.data[0] = rw.data;
      if (burst_size_e > 0) begin
        for(int i = 0; i < (2**burst_size_e); i++)
          wstrb[i] = 1'h1;
        end
      else begin
          wstrb[0] = 1'h1;
      end
      axi_reg_trans.wstrb[0] = wstrb;
    end
    else if (rw.kind == UVM_READ) begin
      axi_reg_trans.rresp     = new[axi_reg_trans.burst_length];
    end
  
    return axi_reg_trans;
  endfunction : reg2bus

  // -----------------------------------------------------------------------------
  function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    svt_axi_master_transaction bus_trans;
    if (!$cast(bus_trans,bus_item)) begin
       `svt_fatal("bus2reg", "bus2reg: Provided bus_item is not of the correct type");
      return;
    end
  
    if (bus_trans!= null) begin
      rw.addr = bus_trans.addr;
      rw.data = bus_trans.data[0] ;
      if (bus_trans.xact_type == svt_axi_master_reg_transaction::READ) begin
        rw.kind = UVM_READ;	    
        `svt_amba_debug("bus2reg" , $sformatf("bus_trans.data = %0h (READ)", bus_trans.data[0]));
        if (bus_trans.rresp[0] == svt_axi_transaction::OKAY)
          rw.status = UVM_IS_OK;
        else
          rw.status  = UVM_NOT_OK;
      end 
      else begin
        if (bus_trans.xact_type == svt_axi_master_reg_transaction::WRITE) begin
          rw.kind = UVM_WRITE;
          if (bus_trans.bresp == svt_axi_transaction::OKAY)
            rw.status = UVM_IS_OK;
          else
            rw.status  = UVM_NOT_OK;
        end
      end
    end
    else
      rw.status  = UVM_NOT_OK;
  endfunction

endclass : reg2axi_adapter
/////////////////////////////////////////////////////////////////////////////////////////////

//To-Do CONC-8684/CONC-8682 : This logic put by Rama. Review and fix if need to use this sequence. Many times seen compile errors. Adding compile directive temporarily to excude this logic from compilation.
`ifdef USE_VIP_SNPS_COMPILE_OFF
class fsys_bootseq extends uvm_reg_sequence;

  uvm_event reg_init_done = uvm_event_pool::get_global("reg_init_done");
  addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t csrq[$];
  concerto_register_map_pkg::ral_sys_ncore m_regs;

  function new(string name="fsys_bootseq");
    super.new(name);
  endfunction : new

  `uvm_object_utils(fsys_bootseq)

  virtual task pre_body();
  `uvm_info("fsys_bootseq", $sformatf("pre_body"), UVM_MEDIUM)
    if(starting_phase != null)
       starting_phase.raise_objection (this);
  endtask

  virtual task body();
    uvm_status_e status;
   
    bit[31:0] data;
    bit[44:0] addr;
    int timeout;
    int poll_till;
    bit [7:0] ioaiu_rpn;
    bit [3:0] ioaiu_nrri;
    // System Census 
    bit [7:0] nAIUs; 
    bit [5:0] nDCEs; 
    bit [5:0] nDMIs; 
    bit [5:0] nDPIs; 
    bit       nDVEs; 

    //$cast(m_regs, model);

    // (2) Read NRRUCR
    data = 0;
    m_regs.sys_global_register_blk.GRBUNRRUCR.read(status, data);
    addr = m_regs.sys_global_register_blk.GRBUNRRUCR.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Read:addr = %0h , NRRUCR = 0x%0h", addr, data), UVM_LOW)
    nAIUs = data[ 7: 0];
    nDCEs = data[13: 8];
    nDMIs = data[19:14];
    nDPIs = data[25:20];
    nDVEs = data[26:26];
    `uvm_info("fsys_bootseq",$sformatf("nAIUs:%0d nDCEs:%0d nDMIs:%0d nDPIs:%0d nDVEs:%0d",nAIUs,nDCEs,nDMIs,nDPIs,nDVEs),UVM_LOW)

   <% if(nCHIAIUs>0) { %>
    //1. read CAIUIDR
    addr = m_regs.caiu0.CAIUIDR.get_address();
    `uvm_info("fsys_bootseq",$sformatf("caiu0.CAIUIDR addr = %0h", addr),UVM_LOW)
    //read_reg(m_regs.caiu0.CAIUIDR, status, data);
    m_regs.caiu0.CAIUIDR.read(status, data);
    `uvm_info("fsys_bootseq",$sformatf("caiu0.CAIUIDR status = %h addr = %h data = %h", status, addr, data ),UVM_LOW)
    if(data[31]) begin // valid
      ioaiu_rpn  = data[ 7:0];
      ioaiu_nrri = data[11:8];
	  `uvm_info("fsys_bootseq", $sformatf("UIDR.RPN=%0d, UIDR.NRRI=%0d", ioaiu_rpn, ioaiu_nrri), UVM_LOW)
    end else begin
      `uvm_error("fsys_bootseq","Valid bit not asserted in USIDR register of Initiating IOAIU-AIU")
    end





    // (3) Configure all the General Purpose registers
    `uvm_info("fsys_bootseq","Configuring GPRs", UVM_LOW)
    //foreach (csrq[i]) begin
    //  `uvm_info("SEQ_LIB", $sformatf("csrq[memregion_id:%0d] --> unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d", i, csrq[i].unit.name(), csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size), UVM_LOW) 
    //end
 
    //Configure address regions for CHIAIU/IOUAIU
    //write to GPR register sets with appropriate values
    data = csrq[0].low_addr;
    m_regs.caiu0.CAIUGPRBLR0.write(status, data);
    addr = m_regs.caiu0.CAIUGPRBLR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRBLR0 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[0].upp_addr;
    m_regs.caiu0.CAIUGPRBHR0.write(status, data);
    addr = m_regs.caiu0.CAIUGPRBHR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRBHR0 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[0].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[0].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[0].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.caiu0.CAIUGPRAR0.write(status, data[31:0]);
    addr = m_regs.caiu0.CAIUGPRAR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRAR0 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[1].low_addr;
    m_regs.caiu0.CAIUGPRBLR1.write(status, data);
    addr = m_regs.caiu0.CAIUGPRBLR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRBLR1 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[1].upp_addr;
    m_regs.caiu0.CAIUGPRBHR1.write(status, data);
    addr = m_regs.caiu0.CAIUGPRBHR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRBHR1 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[1].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[1].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[1].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.caiu0.CAIUGPRAR1.write(status, data[31:0]);
    addr = m_regs.caiu0.CAIUGPRAR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRAR1 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[2].low_addr;
    m_regs.caiu0.CAIUGPRBLR2.write(status, data);
    addr = m_regs.caiu0.CAIUGPRBLR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRBLR2 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[2].upp_addr;
    m_regs.caiu0.CAIUGPRBHR2.write(status, data);
    addr = m_regs.caiu0.CAIUGPRBHR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRBHR2 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[2].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[2].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[2].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.caiu0.CAIUGPRAR2.write(status, data[31:0]);
    addr = m_regs.caiu0.CAIUGPRAR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRAR2 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[3].low_addr;
    m_regs.caiu0.CAIUGPRBLR3.write(status, data);
    addr = m_regs.caiu0.CAIUGPRBLR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRBLR3 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[3].upp_addr;
    m_regs.caiu0.CAIUGPRBHR3.write(status, data);
    addr = m_regs.caiu0.CAIUGPRBHR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRBHR3 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[3].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[3].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[3].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.caiu0.CAIUGPRAR3.write(status, data[31:0]);
    addr = m_regs.caiu0.CAIUGPRAR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRAR3 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[4].low_addr;
    m_regs.caiu0.CAIUGPRBLR4.write(status, data);
    addr = m_regs.caiu0.CAIUGPRBLR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRBLR4 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[4].upp_addr;
    m_regs.caiu0.CAIUGPRBHR4.write(status, data);
    addr = m_regs.caiu0.CAIUGPRBHR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRBHR4 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[4].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[4].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[4].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.caiu0.CAIUGPRAR4.write(status, data[31:0]);
    addr = m_regs.caiu0.CAIUGPRAR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRAR4 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[5].low_addr;
    m_regs.caiu0.CAIUGPRBLR5.write(status, data);
    addr = m_regs.caiu0.CAIUGPRBLR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRBLR5 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[5].upp_addr;
    m_regs.caiu0.CAIUGPRBHR5.write(status, data);
    addr = m_regs.caiu0.CAIUGPRBHR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRBHR5 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[5].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[5].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[5].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.caiu0.CAIUGPRAR5.write(status, data[31:0]);
    addr = m_regs.caiu0.CAIUGPRAR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu0.CAIUGPRAR5 = 0x%0h", addr, data), UVM_LOW)
   <%  } %>
    

    


    
   <% if(nCHIAIUs>1) { %>
    //write to GPR register sets with appropriate values
    data = csrq[0].low_addr;
    m_regs.caiu1.CAIUGPRBLR0.write(status, data);
    addr = m_regs.caiu1.CAIUGPRBLR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRBLR0 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[0].upp_addr;
    m_regs.caiu1.CAIUGPRBHR0.write(status, data);
    addr = m_regs.caiu1.CAIUGPRBHR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRBHR0 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[0].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[0].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[0].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.caiu1.CAIUGPRAR0.write(status, data[31:0]);
    addr = m_regs.caiu1.CAIUGPRAR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRAR0 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[1].low_addr;
    m_regs.caiu1.CAIUGPRBLR1.write(status, data);
    addr = m_regs.caiu1.CAIUGPRBLR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRBLR1 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[1].upp_addr;
    m_regs.caiu1.CAIUGPRBHR1.write(status, data);
    addr = m_regs.caiu1.CAIUGPRBHR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRBHR1 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[1].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[1].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[1].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.caiu1.CAIUGPRAR1.write(status, data[31:0]);
    addr = m_regs.caiu1.CAIUGPRAR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRAR1 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[2].low_addr;
    m_regs.caiu1.CAIUGPRBLR2.write(status, data);
    addr = m_regs.caiu1.CAIUGPRBLR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRBLR2 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[2].upp_addr;
    m_regs.caiu1.CAIUGPRBHR2.write(status, data);
    addr = m_regs.caiu1.CAIUGPRBHR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRBHR2 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[2].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[2].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[2].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.caiu1.CAIUGPRAR2.write(status, data[31:0]);
    addr = m_regs.caiu1.CAIUGPRAR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRAR2 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[3].low_addr;
    m_regs.caiu1.CAIUGPRBLR3.write(status, data);
    addr = m_regs.caiu1.CAIUGPRBLR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRBLR3 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[3].upp_addr;
    m_regs.caiu1.CAIUGPRBHR3.write(status, data);
    addr = m_regs.caiu1.CAIUGPRBHR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRBHR3 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[3].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[3].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[3].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.caiu1.CAIUGPRAR3.write(status, data[31:0]);
    addr = m_regs.caiu1.CAIUGPRAR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRAR3 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[4].low_addr;
    m_regs.caiu1.CAIUGPRBLR4.write(status, data);
    addr = m_regs.caiu1.CAIUGPRBLR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRBLR4 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[4].upp_addr;
    m_regs.caiu1.CAIUGPRBHR4.write(status, data);
    addr = m_regs.caiu1.CAIUGPRBHR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRBHR4 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[4].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[4].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[4].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.caiu1.CAIUGPRAR4.write(status, data[31:0]);
    addr = m_regs.caiu1.CAIUGPRAR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRAR4 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[5].low_addr;
    m_regs.caiu1.CAIUGPRBLR5.write(status, data);
    addr = m_regs.caiu1.CAIUGPRBLR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRBLR5 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[5].upp_addr;
    m_regs.caiu1.CAIUGPRBHR5.write(status, data);
    addr = m_regs.caiu1.CAIUGPRBHR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRBHR5 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[5].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[5].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[5].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.caiu1.CAIUGPRAR5.write(status, data[31:0]);
    addr = m_regs.caiu1.CAIUGPRAR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , caiu1.CAIUGPRAR5 = 0x%0h", addr, data), UVM_LOW)
   <%  } %>
    

    


   <% if(nIOAIUs>0) { %>
    
    //write to GPR register sets with appropriate values
    data = csrq[0].low_addr;
    m_regs.ncaiu0.XAIUGPRBLR0.write(status, data);
    addr = m_regs.ncaiu0.XAIUGPRBLR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRBLR0 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[0].upp_addr;
    m_regs.ncaiu0.XAIUGPRBHR0.write(status, data);
    addr = m_regs.ncaiu0.XAIUGPRBHR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRBHR0 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[0].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[0].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[0].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu0.XAIUGPRAR0.write(status, data[31:0]);
    addr = m_regs.ncaiu0.XAIUGPRAR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRAR0 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[1].low_addr;
    m_regs.ncaiu0.XAIUGPRBLR1.write(status, data);
    addr = m_regs.ncaiu0.XAIUGPRBLR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRBLR1 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[1].upp_addr;
    m_regs.ncaiu0.XAIUGPRBHR1.write(status, data);
    addr = m_regs.ncaiu0.XAIUGPRBHR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRBHR1 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[1].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[1].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[1].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu0.XAIUGPRAR1.write(status, data[31:0]);
    addr = m_regs.ncaiu0.XAIUGPRAR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRAR1 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[2].low_addr;
    m_regs.ncaiu0.XAIUGPRBLR2.write(status, data);
    addr = m_regs.ncaiu0.XAIUGPRBLR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRBLR2 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[2].upp_addr;
    m_regs.ncaiu0.XAIUGPRBHR2.write(status, data);
    addr = m_regs.ncaiu0.XAIUGPRBHR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRBHR2 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[2].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[2].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[2].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu0.XAIUGPRAR2.write(status, data[31:0]);
    addr = m_regs.ncaiu0.XAIUGPRAR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRAR2 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[3].low_addr;
    m_regs.ncaiu0.XAIUGPRBLR3.write(status, data);
    addr = m_regs.ncaiu0.XAIUGPRBLR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRBLR3 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[3].upp_addr;
    m_regs.ncaiu0.XAIUGPRBHR3.write(status, data);
    addr = m_regs.ncaiu0.XAIUGPRBHR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRBHR3 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[3].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[3].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[3].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu0.XAIUGPRAR3.write(status, data[31:0]);
    addr = m_regs.ncaiu0.XAIUGPRAR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRAR3 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[4].low_addr;
    m_regs.ncaiu0.XAIUGPRBLR4.write(status, data);
    addr = m_regs.ncaiu0.XAIUGPRBLR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRBLR4 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[4].upp_addr;
    m_regs.ncaiu0.XAIUGPRBHR4.write(status, data);
    addr = m_regs.ncaiu0.XAIUGPRBHR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRBHR4 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[4].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[4].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[4].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu0.XAIUGPRAR4.write(status, data[31:0]);
    addr = m_regs.ncaiu0.XAIUGPRAR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRAR4 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[5].low_addr;
    m_regs.ncaiu0.XAIUGPRBLR5.write(status, data);
    addr = m_regs.ncaiu0.XAIUGPRBLR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRBLR5 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[5].upp_addr;
    m_regs.ncaiu0.XAIUGPRBHR5.write(status, data);
    addr = m_regs.ncaiu0.XAIUGPRBHR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRBHR5 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[5].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[5].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[5].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu0.XAIUGPRAR5.write(status, data[31:0]);
    addr = m_regs.ncaiu0.XAIUGPRAR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu0.XAIUGPRAR5 = 0x%0h", addr, data), UVM_LOW)
   <%  } %>
    
    


   <% if(nIOAIUs>1) { %>
    
    //write to GPR register sets with appropriate values
    data = csrq[0].low_addr;
    m_regs.ncaiu1.XAIUGPRBLR0.write(status, data);
    addr = m_regs.ncaiu1.XAIUGPRBLR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRBLR0 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[0].upp_addr;
    m_regs.ncaiu1.XAIUGPRBHR0.write(status, data);
    addr = m_regs.ncaiu1.XAIUGPRBHR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRBHR0 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[0].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[0].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[0].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu1.XAIUGPRAR0.write(status, data[31:0]);
    addr = m_regs.ncaiu1.XAIUGPRAR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRAR0 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[1].low_addr;
    m_regs.ncaiu1.XAIUGPRBLR1.write(status, data);
    addr = m_regs.ncaiu1.XAIUGPRBLR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRBLR1 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[1].upp_addr;
    m_regs.ncaiu1.XAIUGPRBHR1.write(status, data);
    addr = m_regs.ncaiu1.XAIUGPRBHR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRBHR1 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[1].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[1].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[1].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu1.XAIUGPRAR1.write(status, data[31:0]);
    addr = m_regs.ncaiu1.XAIUGPRAR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRAR1 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[2].low_addr;
    m_regs.ncaiu1.XAIUGPRBLR2.write(status, data);
    addr = m_regs.ncaiu1.XAIUGPRBLR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRBLR2 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[2].upp_addr;
    m_regs.ncaiu1.XAIUGPRBHR2.write(status, data);
    addr = m_regs.ncaiu1.XAIUGPRBHR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRBHR2 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[2].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[2].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[2].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu1.XAIUGPRAR2.write(status, data[31:0]);
    addr = m_regs.ncaiu1.XAIUGPRAR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRAR2 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[3].low_addr;
    m_regs.ncaiu1.XAIUGPRBLR3.write(status, data);
    addr = m_regs.ncaiu1.XAIUGPRBLR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRBLR3 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[3].upp_addr;
    m_regs.ncaiu1.XAIUGPRBHR3.write(status, data);
    addr = m_regs.ncaiu1.XAIUGPRBHR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRBHR3 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[3].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[3].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[3].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu1.XAIUGPRAR3.write(status, data[31:0]);
    addr = m_regs.ncaiu1.XAIUGPRAR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRAR3 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[4].low_addr;
    m_regs.ncaiu1.XAIUGPRBLR4.write(status, data);
    addr = m_regs.ncaiu1.XAIUGPRBLR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRBLR4 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[4].upp_addr;
    m_regs.ncaiu1.XAIUGPRBHR4.write(status, data);
    addr = m_regs.ncaiu1.XAIUGPRBHR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRBHR4 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[4].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[4].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[4].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu1.XAIUGPRAR4.write(status, data[31:0]);
    addr = m_regs.ncaiu1.XAIUGPRAR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRAR4 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[5].low_addr;
    m_regs.ncaiu1.XAIUGPRBLR5.write(status, data);
    addr = m_regs.ncaiu1.XAIUGPRBLR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRBLR5 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[5].upp_addr;
    m_regs.ncaiu1.XAIUGPRBHR5.write(status, data);
    addr = m_regs.ncaiu1.XAIUGPRBHR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRBHR5 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[5].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[5].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[5].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu1.XAIUGPRAR5.write(status, data[31:0]);
    addr = m_regs.ncaiu1.XAIUGPRAR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu1.XAIUGPRAR5 = 0x%0h", addr, data), UVM_LOW)
   <%  } %>
    
    

   <% if(nIOAIUs>2) { %>

    
    //write to GPR register sets with appropriate values
    data = csrq[0].low_addr;
    m_regs.ncaiu2.XAIUGPRBLR0.write(status, data);
    addr = m_regs.ncaiu2.XAIUGPRBLR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRBLR0 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[0].upp_addr;
    m_regs.ncaiu2.XAIUGPRBHR0.write(status, data);
    addr = m_regs.ncaiu2.XAIUGPRBHR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRBHR0 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[0].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[0].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[0].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu2.XAIUGPRAR0.write(status, data[31:0]);
    addr = m_regs.ncaiu2.XAIUGPRAR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRAR0 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[1].low_addr;
    m_regs.ncaiu2.XAIUGPRBLR1.write(status, data);
    addr = m_regs.ncaiu2.XAIUGPRBLR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRBLR1 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[1].upp_addr;
    m_regs.ncaiu2.XAIUGPRBHR1.write(status, data);
    addr = m_regs.ncaiu2.XAIUGPRBHR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRBHR1 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[1].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[1].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[1].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu2.XAIUGPRAR1.write(status, data[31:0]);
    addr = m_regs.ncaiu2.XAIUGPRAR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRAR1 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[2].low_addr;
    m_regs.ncaiu2.XAIUGPRBLR2.write(status, data);
    addr = m_regs.ncaiu2.XAIUGPRBLR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRBLR2 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[2].upp_addr;
    m_regs.ncaiu2.XAIUGPRBHR2.write(status, data);
    addr = m_regs.ncaiu2.XAIUGPRBHR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRBHR2 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[2].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[2].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[2].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu2.XAIUGPRAR2.write(status, data[31:0]);
    addr = m_regs.ncaiu2.XAIUGPRAR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRAR2 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[3].low_addr;
    m_regs.ncaiu2.XAIUGPRBLR3.write(status, data);
    addr = m_regs.ncaiu2.XAIUGPRBLR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRBLR3 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[3].upp_addr;
    m_regs.ncaiu2.XAIUGPRBHR3.write(status, data);
    addr = m_regs.ncaiu2.XAIUGPRBHR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRBHR3 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[3].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[3].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[3].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu2.XAIUGPRAR3.write(status, data[31:0]);
    addr = m_regs.ncaiu2.XAIUGPRAR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRAR3 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[4].low_addr;
    m_regs.ncaiu2.XAIUGPRBLR4.write(status, data);
    addr = m_regs.ncaiu2.XAIUGPRBLR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRBLR4 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[4].upp_addr;
    m_regs.ncaiu2.XAIUGPRBHR4.write(status, data);
    addr = m_regs.ncaiu2.XAIUGPRBHR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRBHR4 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[4].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[4].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[4].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu2.XAIUGPRAR4.write(status, data[31:0]);
    addr = m_regs.ncaiu2.XAIUGPRAR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRAR4 = 0x%0h", addr, data), UVM_LOW)
    
    //write to GPR register sets with appropriate values
    data = csrq[5].low_addr;
    m_regs.ncaiu2.XAIUGPRBLR5.write(status, data);
    addr = m_regs.ncaiu2.XAIUGPRBLR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRBLR5 = 0x%0h", addr, data), UVM_LOW)

    data = csrq[5].upp_addr;
    m_regs.ncaiu2.XAIUGPRBHR5.write(status, data);
    addr = m_regs.ncaiu2.XAIUGPRBHR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRBHR5 = 0x%0h", addr, data), UVM_LOW)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[5].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[5].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[5].mig_nunitid;
    data[2:0]   = 0; 
    m_regs.ncaiu2.XAIUGPRAR5.write(status, data[31:0]);
    addr = m_regs.ncaiu2.XAIUGPRAR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , ncaiu2.XAIUGPRAR5 = 0x%0h", addr, data), UVM_LOW)
   <%  } %>
    
    



    // (3) Initialize DCEs

    
   <% if(nDCEs>0) { %>

    data = csrq[0].low_addr;
    m_regs.dce0.DCEUGPRBLR0.write(status, csrq[0].low_addr );
    addr = m_regs.dce0.DCEUGPRBLR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRBLR0  = 0x%0h", addr, data), UVM_LOW)

    data = csrq[0].upp_addr;
    m_regs.dce0.DCEUGPRBHR0.write(status, csrq[0].upp_addr );
    addr = m_regs.dce0.DCEUGPRBHR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRBHR0  = 0x%0h", addr, data), UVM_LOW)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[0].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[0].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[0].mig_nunitid;
    data[2:0]   = 0;
    m_regs.dce0.DCEUGPRAR0.write(status, data[31:0]);
    addr = m_regs.dce0.DCEUGPRAR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRAR0  = 0x%0h", addr, data), UVM_LOW)

     

    data = csrq[1].low_addr;
    m_regs.dce0.DCEUGPRBLR1.write(status, csrq[1].low_addr );
    addr = m_regs.dce0.DCEUGPRBLR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRBLR1  = 0x%0h", addr, data), UVM_LOW)

    data = csrq[1].upp_addr;
    m_regs.dce0.DCEUGPRBHR1.write(status, csrq[1].upp_addr );
    addr = m_regs.dce0.DCEUGPRBHR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRBHR1  = 0x%0h", addr, data), UVM_LOW)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[1].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[1].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[1].mig_nunitid;
    data[2:0]   = 0;
    m_regs.dce0.DCEUGPRAR1.write(status, data[31:0]);
    addr = m_regs.dce0.DCEUGPRAR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRAR1  = 0x%0h", addr, data), UVM_LOW)

     

    data = csrq[2].low_addr;
    m_regs.dce0.DCEUGPRBLR2.write(status, csrq[2].low_addr );
    addr = m_regs.dce0.DCEUGPRBLR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRBLR2  = 0x%0h", addr, data), UVM_LOW)

    data = csrq[2].upp_addr;
    m_regs.dce0.DCEUGPRBHR2.write(status, csrq[2].upp_addr );
    addr = m_regs.dce0.DCEUGPRBHR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRBHR2  = 0x%0h", addr, data), UVM_LOW)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[2].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[2].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[2].mig_nunitid;
    data[2:0]   = 0;
    m_regs.dce0.DCEUGPRAR2.write(status, data[31:0]);
    addr = m_regs.dce0.DCEUGPRAR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRAR2  = 0x%0h", addr, data), UVM_LOW)

     

    data = csrq[3].low_addr;
    m_regs.dce0.DCEUGPRBLR3.write(status, csrq[3].low_addr );
    addr = m_regs.dce0.DCEUGPRBLR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRBLR3  = 0x%0h", addr, data), UVM_LOW)

    data = csrq[3].upp_addr;
    m_regs.dce0.DCEUGPRBHR3.write(status, csrq[3].upp_addr );
    addr = m_regs.dce0.DCEUGPRBHR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRBHR3  = 0x%0h", addr, data), UVM_LOW)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[3].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[3].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[3].mig_nunitid;
    data[2:0]   = 0;
    m_regs.dce0.DCEUGPRAR3.write(status, data[31:0]);
    addr = m_regs.dce0.DCEUGPRAR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRAR3  = 0x%0h", addr, data), UVM_LOW)

     

    data = csrq[4].low_addr;
    m_regs.dce0.DCEUGPRBLR4.write(status, csrq[4].low_addr );
    addr = m_regs.dce0.DCEUGPRBLR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRBLR4  = 0x%0h", addr, data), UVM_LOW)

    data = csrq[4].upp_addr;
    m_regs.dce0.DCEUGPRBHR4.write(status, csrq[4].upp_addr );
    addr = m_regs.dce0.DCEUGPRBHR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRBHR4  = 0x%0h", addr, data), UVM_LOW)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[4].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[4].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[4].mig_nunitid;
    data[2:0]   = 0;
    m_regs.dce0.DCEUGPRAR4.write(status, data[31:0]);
    addr = m_regs.dce0.DCEUGPRAR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRAR4  = 0x%0h", addr, data), UVM_LOW)

     

    data = csrq[5].low_addr;
    m_regs.dce0.DCEUGPRBLR5.write(status, csrq[5].low_addr );
    addr = m_regs.dce0.DCEUGPRBLR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRBLR5  = 0x%0h", addr, data), UVM_LOW)

    data = csrq[5].upp_addr;
    m_regs.dce0.DCEUGPRBHR5.write(status, csrq[5].upp_addr );
    addr = m_regs.dce0.DCEUGPRBHR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRBHR5  = 0x%0h", addr, data), UVM_LOW)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[5].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[5].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[5].mig_nunitid;
    data[2:0]   = 0;
    m_regs.dce0.DCEUGPRAR5.write(status, data[31:0]);
    addr = m_regs.dce0.DCEUGPRAR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUGPRAR5  = 0x%0h", addr, data), UVM_LOW)

     

    //DCEUAMIGR
    data = 32'h0; data[4:0]={addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs,1'b1};
    m_regs.dce0.DCEUAMIGR.write(status, data[31:0]);
    addr = m_regs.dce0.DCEUAMIGR.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce0.DCEUAMIGR = 0x%0h", addr, data), UVM_LOW)

    //DCEUSFMAR
    poll_till = 32'b0;       
    timeout = 500;
    do begin
      timeout -=1;
      m_regs.dce0.DCEUSFMAR.read(status, data);
      addr = m_regs.dce0.DCEUSFMAR.get_address();
      `uvm_info("fsys_bootseq",$sformatf("m_regs.dce0.DCEUSFMAR status = %h addr = %h data = %h", status, addr, data ),UVM_LOW)
    end while ((data != poll_till) && (timeout != 0)); // UNMATCHED !!
    if (timeout == 0) begin
      `uvm_error("ncore_init_boot_seq", $sformatf("Timeout! Polling  poll_till=0x%0x data=0x%0x", poll_till, data))
    end 
   <%  } %>

    

   <% if(nDCEs>1) { %>
    data = csrq[0].low_addr;
    m_regs.dce1.DCEUGPRBLR0.write(status, csrq[0].low_addr );
    addr = m_regs.dce1.DCEUGPRBLR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRBLR0  = 0x%0h", addr, data), UVM_LOW)

    data = csrq[0].upp_addr;
    m_regs.dce1.DCEUGPRBHR0.write(status, csrq[0].upp_addr );
    addr = m_regs.dce1.DCEUGPRBHR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRBHR0  = 0x%0h", addr, data), UVM_LOW)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[0].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[0].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[0].mig_nunitid;
    data[2:0]   = 0;
    m_regs.dce1.DCEUGPRAR0.write(status, data[31:0]);
    addr = m_regs.dce1.DCEUGPRAR0.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRAR0  = 0x%0h", addr, data), UVM_LOW)

     

    data = csrq[1].low_addr;
    m_regs.dce1.DCEUGPRBLR1.write(status, csrq[1].low_addr );
    addr = m_regs.dce1.DCEUGPRBLR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRBLR1  = 0x%0h", addr, data), UVM_LOW)

    data = csrq[1].upp_addr;
    m_regs.dce1.DCEUGPRBHR1.write(status, csrq[1].upp_addr );
    addr = m_regs.dce1.DCEUGPRBHR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRBHR1  = 0x%0h", addr, data), UVM_LOW)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[1].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[1].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[1].mig_nunitid;
    data[2:0]   = 0;
    m_regs.dce1.DCEUGPRAR1.write(status, data[31:0]);
    addr = m_regs.dce1.DCEUGPRAR1.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRAR1  = 0x%0h", addr, data), UVM_LOW)

     

    data = csrq[2].low_addr;
    m_regs.dce1.DCEUGPRBLR2.write(status, csrq[2].low_addr );
    addr = m_regs.dce1.DCEUGPRBLR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRBLR2  = 0x%0h", addr, data), UVM_LOW)

    data = csrq[2].upp_addr;
    m_regs.dce1.DCEUGPRBHR2.write(status, csrq[2].upp_addr );
    addr = m_regs.dce1.DCEUGPRBHR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRBHR2  = 0x%0h", addr, data), UVM_LOW)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[2].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[2].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[2].mig_nunitid;
    data[2:0]   = 0;
    m_regs.dce1.DCEUGPRAR2.write(status, data[31:0]);
    addr = m_regs.dce1.DCEUGPRAR2.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRAR2  = 0x%0h", addr, data), UVM_LOW)

     

    data = csrq[3].low_addr;
    m_regs.dce1.DCEUGPRBLR3.write(status, csrq[3].low_addr );
    addr = m_regs.dce1.DCEUGPRBLR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRBLR3  = 0x%0h", addr, data), UVM_LOW)

    data = csrq[3].upp_addr;
    m_regs.dce1.DCEUGPRBHR3.write(status, csrq[3].upp_addr );
    addr = m_regs.dce1.DCEUGPRBHR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRBHR3  = 0x%0h", addr, data), UVM_LOW)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[3].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[3].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[3].mig_nunitid;
    data[2:0]   = 0;
    m_regs.dce1.DCEUGPRAR3.write(status, data[31:0]);
    addr = m_regs.dce1.DCEUGPRAR3.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRAR3  = 0x%0h", addr, data), UVM_LOW)

     

    data = csrq[4].low_addr;
    m_regs.dce1.DCEUGPRBLR4.write(status, csrq[4].low_addr );
    addr = m_regs.dce1.DCEUGPRBLR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRBLR4  = 0x%0h", addr, data), UVM_LOW)

    data = csrq[4].upp_addr;
    m_regs.dce1.DCEUGPRBHR4.write(status, csrq[4].upp_addr );
    addr = m_regs.dce1.DCEUGPRBHR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRBHR4  = 0x%0h", addr, data), UVM_LOW)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[4].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[4].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[4].mig_nunitid;
    data[2:0]   = 0;
    m_regs.dce1.DCEUGPRAR4.write(status, data[31:0]);
    addr = m_regs.dce1.DCEUGPRAR4.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRAR4  = 0x%0h", addr, data), UVM_LOW)

     

    data = csrq[5].low_addr;
    m_regs.dce1.DCEUGPRBLR5.write(status, csrq[5].low_addr );
    addr = m_regs.dce1.DCEUGPRBLR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRBLR5  = 0x%0h", addr, data), UVM_LOW)

    data = csrq[5].upp_addr;
    m_regs.dce1.DCEUGPRBHR5.write(status, csrq[5].upp_addr );
    addr = m_regs.dce1.DCEUGPRBHR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRBHR5  = 0x%0h", addr, data), UVM_LOW)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[5].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[5].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[5].mig_nunitid;
    data[2:0]   = 0;
    m_regs.dce1.DCEUGPRAR5.write(status, data[31:0]);
    addr = m_regs.dce1.DCEUGPRAR5.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUGPRAR5  = 0x%0h", addr, data), UVM_LOW)

     

    //DCEUAMIGR
    data = 32'h0; data[4:0]={addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs,1'b1};
    m_regs.dce1.DCEUAMIGR.write(status, data[31:0]);
    addr = m_regs.dce1.DCEUAMIGR.get_address();
    `uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dce1.DCEUAMIGR = 0x%0h", addr, data), UVM_LOW)

    //DCEUSFMAR
    poll_till = 32'b0;       
    timeout = 500;
    do begin
      timeout -=1;
      m_regs.dce1.DCEUSFMAR.read(status, data);
      addr = m_regs.dce1.DCEUSFMAR.get_address();
      `uvm_info("fsys_bootseq",$sformatf("m_regs.dce1.DCEUSFMAR status = %h addr = %h data = %h", status, addr, data ),UVM_LOW)
    end while ((data != poll_till) && (timeout != 0)); // UNMATCHED !!
    if (timeout == 0) begin
      `uvm_error("ncore_init_boot_seq", $sformatf("Timeout! Polling  poll_till=0x%0x data=0x%0x", poll_till, data))
    end 
   <%  } %>


    // (5) Initialize DMIs ( dmi*_DMIUSMCTCR)
    //data=32'h3;

    //
    //m_regs.dmi0.DMIUSMCTCR.write(status, data[31:0]);
    //addr = m_regs.dmi0.DMIUSMCTCR.get_address();
    //`uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dmi0.DMIUSMCTCR = 0x%0h", addr, data), UVM_LOW)
    // 

    //
    //m_regs.dmi1.DMIUSMCTCR.write(status, data[31:0]);
    //addr = m_regs.dmi1.DMIUSMCTCR.get_address();
    //`uvm_info("fsys_bootseq", $sformatf("Reg Write:addr = %0h , dmi1.DMIUSMCTCR = 0x%0h", addr, data), UVM_LOW)
     
    //DMIUSMCISR

    //trigger event for init done
    reg_init_done.trigger();
    `uvm_info("fsys_bootseq", $sformatf("triggered reg_init_done event"), UVM_MEDIUM)

  endtask : body

  virtual task post_body();
  `uvm_info("fsys_bootseq", $sformatf("post_body"), UVM_MEDIUM)
    if(starting_phase != null)
       starting_phase.drop_objection (this);
  endtask

endclass : fsys_bootseq
`endif //USE_VIP_SNPS_COMPILE_OFF
//`endif //USE_VIP_SNPS


endpackage
`endif //GUARD_SVT_AMBA_SEQ_LIB_SV
