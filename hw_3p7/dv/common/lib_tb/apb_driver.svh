`include "uvm_macros.svh"
////////////////////////////////////////////////////////////////////////////////
//
// APB Channel Driver
//
////////////////////////////////////////////////////////////////////////////////
class apb_driver extends uvm_driver#(apb_pkt_t);

    `uvm_component_param_utils(apb_driver)

    virtual <%=obj.BlockId%>_apb_if  m_vif;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "apb_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        apb_pkt_t m_pkt;

        uvm_sequence_item seq_item;

        m_vif.async_reset_apb_channel();
        @(posedge m_vif.rst_n);
        repeat(1)  @(posedge m_vif.clk);

        fork
          forever
          begin
              seq_item_port.get_next_item(seq_item);
              $cast(m_pkt, seq_item);  
              <%if(obj.testBench === "io_aiu" && Array.isArray(obj.DutInfo.rpn)) {%>
                  m_pkt.paddr[WPADDR-1: WPADDR-$clog2(<%=obj.DutInfo.nNativeInterfacePorts%>)] = m_pkt.paddr[WPADDR-1: WPADDR-$clog2(<%=obj.DutInfo.nNativeInterfacePorts%>)] - 'd<%=obj.DutInfo.rpn[0]%>;
              <%}%>
              send_req(m_pkt);

              rcv_req(m_pkt);

              end_tr(m_pkt);

              seq_item_port.item_done();
          end
      join_none

    endtask : run_phase

   task send_req(ref apb_pkt_t m_pkt);
      apb_pkt_t pkt;

      pkt = new();
      pkt.copy(m_pkt);
      m_vif.drive_apb_channel(pkt);

   endtask : send_req

   task rcv_req(ref apb_pkt_t m_pkt);

      m_vif.collect_apb_channel(m_pkt);
      if(!($test$plusargs("apb4_csr_nonsecure"))) begin
         if(m_pkt.paddr == m_pkt.unmap_addr) begin      //To check: pslverr in case of CSR unmapped address
           if (m_pkt.pslverr != apb_pslverr_logic_t'(ERR)) begin
             `uvm_error("Unmapped address", $sformatf("Ncore should return the pslverr during APB response: paddr %0h",m_pkt.paddr))
           end
         end else begin                                 //General case
           if (m_pkt.pslverr == apb_pslverr_logic_t'(ERR)) begin
             `uvm_error("APB error","Ncore returned error during APB response");
           end
         end
      end
      else begin
         if (m_pkt.pslverr != apb_pslverr_logic_t'(ERR)) begin
            `uvm_error("Unmapped address", $sformatf("Ncore should return the pslverr during APB response: paddr %0h for Non Secure access",m_pkt.paddr))
         end
      end
   endtask : rcv_req

endclass: apb_driver


