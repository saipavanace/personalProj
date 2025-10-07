/////////////////////////////////////////////////////////////////////////////
//
//  AXI Virtual Sequencer
<% if(1 == 0) { %>
// Author: Satya Prakash
<% } %>
//
////////////////////////////////////////////////////////////////////////////

class axi_virtual_sequencer extends uvm_sequencer;
   
   `uvm_component_param_utils(axi_virtual_sequencer)

     axi_read_addr_chnl_sequencer      m_read_addr_chnl_seqr;
     axi_read_data_chnl_sequencer      m_read_data_chnl_seqr;
     axi_write_addr_chnl_sequencer     m_write_addr_chnl_seqr;
     axi_write_data_chnl_sequencer     m_write_data_chnl_seqr;
     axi_write_resp_chnl_sequencer     m_write_resp_chnl_seqr;
     axi_snoop_addr_chnl_sequencer     m_snoop_addr_chnl_seqr;
     axi_snoop_data_chnl_sequencer     m_snoop_data_chnl_seqr;
     axi_snoop_resp_chnl_sequencer     m_snoop_resp_chnl_seqr;
    

     
     function new(string name="axi_virtual_sequencer",uvm_component parent = null);
        super.new(name,parent);
     endfunction: new

endclass:axi_virtual_sequencer
