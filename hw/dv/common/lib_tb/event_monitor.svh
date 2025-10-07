///////////////////////////////
// Event Monitor
// Author: Abdelaziz EL HAMADI
//////////////////////////////
class event_monitor extends uvm_monitor;

    `uvm_component_param_utils(event_monitor);

    virtual <%=obj.BlockId%>_event_if #(.IF_MASTER(1))  m_vif_master;
    virtual <%=obj.BlockId%>_event_if #(.IF_MASTER(0))  m_vif_slave;

    uvm_analysis_port #(event_pkt)  event_sender_ap_master;
    uvm_analysis_port #(event_pkt)  event_receiver_ap_slave;

    extern function new(string name = "event_monitor", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task monitor_sender_loop();
    extern task monitor_receiver_loop();


endclass : event_monitor

    //----------------------------------------------------------------------- 
    // New
    //----------------------------------------------------------------------- 

    function event_monitor::new(string name = "event_monitor", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new

    //----------------------------------------------------------------------- 
    // Build phase
    //----------------------------------------------------------------------- 

    function void event_monitor::build_phase(uvm_phase phase);
        event_sender_ap_master            = new("event_sender_ap_master", this);
        event_receiver_ap_slave           = new("event_receiver_ap_slave", this);
    endfunction : build_phase

    //-----------------------------------------------------------------------
    // Run phase
    //----------------------------------------------------------------------- 

    task event_monitor::run_phase(uvm_phase phase); 
    <% if( obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
            wait(m_vif_master.rst_n == 1);
    <% }  else if (obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false  ) {%>
        wait(m_vif_slave.rst_n == 1);
    <% } %>

        fork
  <% if( obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
            monitor_sender_loop();
   <% } %>
  <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false  ) { %>
            monitor_receiver_loop();
   <% } %>
        join
    endtask : run_phase
    //-----------------------------------------------------------------------
    // Monitor Sender loop
    //-----------------------------------------------------------------------    
    task event_monitor::monitor_sender_loop();
        event_pkt pkt_sender;

        pkt_sender = new();
        forever begin
            m_vif_master.collect_master(pkt_sender);
            if (m_vif_master.rst_n == 0) begin
                continue;
            end
            event_sender_ap_master.write(pkt_sender);
            pkt_sender.prev_req=pkt_sender.req;
            pkt_sender.prev_ack=pkt_sender.ack;
        end     
    endtask : monitor_sender_loop
    //-----------------------------------------------------------------------
    // Monitor Receiver loop
    //-----------------------------------------------------------------------    
   task event_monitor::monitor_receiver_loop();
        event_pkt pkt_receiver;

        pkt_receiver = new();
        forever begin
            m_vif_slave.collect_slave(pkt_receiver);
            if (m_vif_slave.rst_n == 0) begin
                continue;
            end
            event_receiver_ap_slave.write(pkt_receiver);
            pkt_receiver.prev_req=pkt_receiver.req;
            pkt_receiver.prev_ack=pkt_receiver.ack;
        end      
    endtask : monitor_receiver_loop
