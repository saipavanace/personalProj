

class chi_tx_req_chnl_cb#(int ID = 0) extends uvm_object;

  `uvm_object_param_utils(chi_tx_req_chnl_cb#(ID))

  //Properties
  chi_aiu_unit_args     m_args;
  chi_bfm_txn m_txn[$];

  function new(string s = "chi_tx_req_chnl_cb");
    super.new(s);
  endfunction: new

  function void set_chi_unit_args(const ref chi_aiu_unit_args args);
    m_args = args;
  endfunction: set_chi_unit_args 

  virtual function void put_chi_txn(chi_bfm_txn txn);
    m_txn.push_back(txn);
  endfunction: put_chi_txn

  virtual task get_chi_txn(output chi_bfm_txn txn);
    wait (m_txn.size() > 0);
    txn = m_txn.pop_front();
  endtask: get_chi_txn
<% if(obj.testBench == 'chi_aiu' || obj.testBench == 'fsys') { %>
`ifndef VCS
  virtual function int size();
`else // `ifndef VCS
  function int size();
`endif // `ifndef VCS
<% } else {%>
  virtual function int size();
<% } %>
    return m_txn.size();
  endfunction: size

endclass: chi_tx_req_chnl_cb
