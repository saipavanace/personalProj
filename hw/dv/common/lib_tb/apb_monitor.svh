//----------------------------------------------------------------------- 
// APB Master Monitor
//----------------------------------------------------------------------- 

class apb_monitor extends uvm_component;

    `uvm_component_param_utils(apb_monitor);

    virtual <%=obj.BlockId%>_apb_if       m_vif;
    bit                  delay_export;

    uvm_analysis_port #(apb_pkt_t)  apb_req_ap;
    uvm_analysis_port #(apb_pkt_t)  apb_rsp_ap;

    //----------------------------------------------------------------------- 
    // New
    //----------------------------------------------------------------------- 

    function new(string name = "apb_monitor", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new

    //----------------------------------------------------------------------- 
    // Build phase
    //----------------------------------------------------------------------- 

    function void build_phase(uvm_phase phase);
        apb_req_ap                 = new("apb_req_ap", this);
        apb_rsp_ap                 = new("apb_rsp_ap", this);
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
        wait(m_vif.rst_n == 1); 
        fork
          monitor_apb_req_loop();
          //monitor_apb_rsp_loop();
        join
    endtask : run_phase

    //-----------------------------------------------------------------------
    // Monitor apb req loop
    //----------------------------------------------------------------------- 

    task monitor_apb_req_loop;
        apb_pkt_t pkt;
        
        pkt = new();

        forever begin
            pkt = new();
            m_vif.collect_apb_req_channel(pkt);
            if (m_vif.rst_n == 0) begin
                continue;
            end
            //`uvm_info(get_full_name(), $psprintf("About to send pkt: %0s", pkt.sprint_pkt()), UVM_LOW);
            apb_req_ap.write(pkt);
            //`uvm_info(get_full_name(), $psprintf("Done sending pkt: %0s", pkt.sprint_pkt()), UVM_LOW);
        end
    endtask : monitor_apb_req_loop

    //-----------------------------------------------------------------------
    // Monitor apb rsp loop
    //----------------------------------------------------------------------- 

    task monitor_apb_rsp_loop;
        apb_pkt_t pkt;
        apb_pkt_t beat_pkt;
        apb_prdata_t lshft;
        bit [31:0] lshift;
        beat_pkt = new();
        pkt = new();
    endtask : monitor_apb_rsp_loop

endclass : apb_monitor


