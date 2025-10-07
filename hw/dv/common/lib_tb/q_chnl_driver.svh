`include "uvm_macros.svh"
////////////////////////////////////////////////////////////////////////////////
//
// Q Channel Driver
//
////////////////////////////////////////////////////////////////////////////////
class q_chnl_driver extends uvm_driver #(q_chnl_seq_item);

    `uvm_component_param_utils(q_chnl_driver)

<% if (obj.testBench=="fsys" || obj.testBench == "cust_tb" || obj.testBench == "emu") { %> 
    virtual concerto_q_chnl_if  m_vif;
<% } else { %>
    virtual <%=obj.BlockId%>_q_chnl_if  m_vif;
<% } %>
    int     time_bw_Q_chnl_req=100;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "q_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        q_chnl_seq_item m_pkt;
        q_chnl_seq_item rsp_pkt;
        m_pkt = new();
        rsp_pkt = new();
        //Ref CONC-6565
        @(posedge m_vif.rst_n); 
        wait (m_vif.QACCEPTn == 'b0);
        repeat(10)@(posedge m_vif.clk); 
        m_vif.QREQn = 1;

        forever begin
           repeat (time_bw_Q_chnl_req) @(posedge m_vif.clk);
           //Getting & Driving Q channel Req.    
           seq_item_port.get_next_item(m_pkt);
           `uvm_info("Q_Channel DRV", "Driving Q Channel Pkt",UVM_MEDIUM)
           m_vif.drive_q_channel(m_pkt);

           // De asserting QREQn once QACCEPTn or QDENy received
           repeat(100)@(posedge m_vif.clk); 
           m_vif.QREQn = 1;

           // Sampling response from Q channel interface.
           `uvm_info("Q_Channel DRV", "Sampling Q Channel Signals",UVM_MEDIUM)
           m_vif.collect_q_channel(rsp_pkt);

           `uvm_info("Q_Channel DRV", "Setting Q Channel Pkt id",UVM_MEDIUM)
           rsp_pkt.set_id_info(m_pkt);
           
           //Sending Response to seq.
           `uvm_info("Q_Channel DRV", "Sending Q Channel Pkt Respomse to Seq",UVM_MEDIUM)
           seq_item_port.put(rsp_pkt); 

           //Item done
           `uvm_info("Q_Channel DRV", "Q Channel Item done",UVM_MEDIUM)
           seq_item_port.item_done();
        end

    endtask : run_phase


endclass: q_chnl_driver
