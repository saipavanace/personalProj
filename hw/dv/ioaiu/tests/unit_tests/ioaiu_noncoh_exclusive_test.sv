/*
 *creating a stand alone testcase as after it works fine will merge it
 */
class ioaiu_noncoh_exclusive_test extends bring_up_test;

  `uvm_component_utils(ioaiu_noncoh_exclusive_test)


  function new(string name = "ioaiu_noncoh_exclusive_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new


  task run_phase (uvm_phase phase);
<% if(!obj.BLK_SNPS_ACE_VIP) { %>
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    m_ace_cache_model[<%=i%>].m_addr_mgr.gen_noncoh_addr_in_user_addrq(k_num_read_req/20,m_ace_cache_model[<%=i%>].user_read_addrq[ncoreConfigInfo::NONCOH]);
    foreach(m_ace_cache_model[<%=i%>].user_read_addrq[ncoreConfigInfo::NONCOH][i]) begin 
       m_ace_cache_model[<%=i%>].user_write_addrq[ncoreConfigInfo::NONCOH][i] = m_ace_cache_model[<%=i%>].user_read_addrq[ncoreConfigInfo::NONCOH][i];
$display("Address Generated %0d:%0h",i,m_ace_cache_model[<%=i%>].user_read_addrq[ncoreConfigInfo::NONCOH][i]);
    end
<% } %>
<% } %>
      super.run_phase(phase);
  endtask : run_phase

endclass : ioaiu_noncoh_exclusive_test
