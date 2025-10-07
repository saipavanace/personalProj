`ifndef CUST_SVT_AXI_SLAVE_TRANSACTION_SV
`define CUST_SVT_AXI_SLAVE_TRANSACTION_SV

class cust_svt_axi_slave_transaction extends svt_axi_slave_transaction;

   `uvm_object_utils(cust_svt_axi_slave_transaction)
   
   function new(string name="cust_svt_axi_slave_transaction");
      super.new(name);
   endfunction

endclass
`endif
