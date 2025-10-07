///////////////////////////////
// EVent Driver
// Author: Abdelaziz EL HAMADI
//////////////////////////////
class event_driver extends uvm_driver #(event_signals);

    `uvm_component_param_utils(event_driver)
    
    virtual <%=obj.BlockId%>_event_if #(.IF_MASTER(1))  m_vif_master;
    virtual <%=obj.BlockId%>_event_if #(.IF_MASTER(0))  m_vif_slave;

    extern function new(string name = "event_driver", uvm_component parent = null);
    extern task run_phase(uvm_phase phase);   

endclass: event_driver 

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function event_driver::new(string name = "event_driver", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

task event_driver::run_phase(uvm_phase phase);

  event_signals m_pkt;
  m_pkt = new();
  #1;
  <% if( obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
  @(posedge m_vif_master.rst_n);
  @(posedge m_vif_master.clk);
  <% }  else if (obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false  ) {%>
  @(posedge m_vif_slave.rst_n);
  @(posedge m_vif_slave.clk);
  <% } %>
  fork
  <% if( obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
     begin
     forever begin
         seq_item_port.get_next_item(m_pkt);
         if(m_pkt.req==1) begin 
         //#Stimulus.FSYS.sysevent.aiu_to_aiu
         #100ns;
            `uvm_info("EVENT DRIVER", $sformatf("start drive master" ), UVM_LOW)
            m_vif_master.drive_master();
         end else
         if (m_pkt.has_error==1) begin
            #100ns;
            `uvm_info("EVENT DRIVER", $sformatf("start drive handshak timeout" ), UVM_LOW)
            m_vif_master.drive_master_hds_error();            

         end 
         seq_item_port.item_done();
     end
     end
   <% } %>
  <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false  ) { %>
     begin
     forever begin
         if(m_pkt.ack==1) begin 
           //#Stimulus.FSYS.sysevent.dii_dmi
           //#Stimulus.FSYS.sysevent.dce
           `uvm_info("EVENT DRIVER", $sformatf("start drive slave" ), UVM_LOW)
            m_vif_slave.drive_slave();
         end            
     end     
     end 
   <% } %>
  join

endtask : run_phase

   

