//----------------------------------------------------------------------- 
// Q channel Monitor
//----------------------------------------------------------------------- 

class q_chnl_monitor extends uvm_component;

    `uvm_component_param_utils(q_chnl_monitor);

<% if (obj.testBench=="fsys" || obj.testBench=="cust_tb" || obj.testBench=="emu") { %> 
    virtual concerto_q_chnl_if  m_vif;
<% } else { %>
    virtual <%=obj.BlockId%>_q_chnl_if  m_vif;
<% } %>

    uvm_analysis_port #(q_chnl_seq_item)  q_chnl_ap;

    //----------------------------------------------------------------------- 
    // New (constuctor)
    //----------------------------------------------------------------------- 

    function new(string name = "q_chnl_monitor", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new

    //----------------------------------------------------------------------- 
    // Build phase
    //----------------------------------------------------------------------- 
    
    function void build_phase(uvm_phase phase);
        q_chnl_ap  = new("q_chnl_ap", this);
    endfunction : build_phase

    //----------------------------------------------------------------------- 
    // Connect phase
    //----------------------------------------------------------------------- 

    function void connect_phase(uvm_phase phase);
    endfunction : connect_phase

    //-----------------------------------------------------------------------
    // Run phase
    //----------------------------------------------------------------------- 

    task run_phase(uvm_phase phase);
            monitor_collect_loop();
    endtask : run_phase

    //-----------------------------------------------------------------------
    // Monitor q channel collect loop 
    //----------------------------------------------------------------------- 

    task monitor_collect_loop;
        q_chnl_seq_item pkt;
        pkt = new();

        forever begin
            m_vif.collect_q_channel(pkt);

            q_chnl_ap.write(pkt);
        end
    endtask : monitor_collect_loop

endclass : q_chnl_monitor

