/*
*
*
*/

class ioaiu_probe_monitor extends uvm_monitor;
    `uvm_component_param_utils(ioaiu_probe_monitor)
    ioaiu_probe_txn m_probe_txn;
    virtual  <%=obj.BlockId%>_probe_if m_vif;
    int core_id;
    uvm_analysis_port #(ioaiu_probe_txn) probe_rtl_ap;
    uvm_analysis_port #(ioaiu_probe_txn) probe_ottvec_ap;
    uvm_analysis_port #(ioaiu_probe_txn) probe_owo_ap;
    uvm_analysis_port #(cycle_tracker_s) probe_cycle_tracker_ap;
    uvm_analysis_port #(ioaiu_probe_txn) probe_bypass_ap;

    extern function new(string name = "ioaiu_probe_monitor", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task grab_qos_signals();
    extern task grab_owo_signals();
    extern task grab_starv_signals();
    extern task grab_ioaiu_ottvec(); 
    extern task grab_cycle_counter();
    extern task grab_bypass_signals();
    extern task grab_owo_ottst_vec();
endclass : ioaiu_probe_monitor

function ioaiu_probe_monitor::new(string name = "ioaiu_probe_monitor", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

function void ioaiu_probe_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);

    probe_owo_ap    = new("probe_owo_ap", this);
    probe_cycle_tracker_ap    = new("probe_cycle_tracker_ap", this);
    probe_bypass_ap    = new("probe_bypass_ap", this);
    probe_rtl_ap            = new("probe_rtl_ap", this);
    probe_ottvec_ap            = new("probe_ottvec_ap", this);
     <% if (obj.testBench=="fsys" ) { %>
    if(!uvm_config_db#(virtual <%=obj.BlockId%>_probe_if )::get(null, get_full_name(), $sformatf("<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_probe_if%0d",core_id), m_vif)) begin
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    end 
    <%}else{%>
    if(!uvm_config_db#(virtual  <%=obj.BlockId%>_probe_if )::get(null, get_full_name(), $sformatf("u_csr_probe_if%0d",core_id), m_vif)) begin
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    end
    <%}%>
    m_probe_txn = ioaiu_probe_txn::type_id::create("m_probe_txn", this);
endfunction : build_phase

task ioaiu_probe_monitor::run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
        grab_qos_signals();
        grab_starv_signals();
        grab_ioaiu_ottvec(); 
        grab_cycle_counter();
        grab_bypass_signals();
        grab_owo_signals();
    join
endtask: run_phase
    

task ioaiu_probe_monitor::grab_owo_signals();
    bit [<%=obj.nOttCtrlEntries%>-1 : 0] prev_ott_owned_st = 0;
    bit [<%=obj.nOttCtrlEntries%>-1 : 0] prev_ott_oldest_st = 0;
    m_probe_txn = ioaiu_probe_txn::type_id::create("m_probe_txn", this);

    forever begin
        @(m_vif.monitor_cb);
        if ((m_vif.snp_req_vld == 1) //SNPreq received
        || (m_vif.ott_owned_st != prev_ott_owned_st) //change in owned_st info
        || (m_vif.ott_oldest_st != prev_ott_oldest_st) ) //change in oldest_st info
        begin
          m_probe_txn.snp_req_vld   = m_vif.snp_req_vld;
          m_probe_txn.snp_req_match = m_vif.snp_req_match;
          m_probe_txn.snp_req_addr  = m_vif.snp_req_addr;
          m_probe_txn.ott_owned_st  = m_vif.ott_owned_st;
          m_probe_txn.ott_oldest_st = m_vif.ott_oldest_st;
          probe_owo_ap.write(m_probe_txn); 
          //`uvm_info("DEBUG_INFO::MONITOR:IN", $psprintf("Time:%t Cycle:%0d Put in owo port, snp_req_match:%0p",$time, m_vif.get_cycle_count(), m_vif.snp_req_match), UVM_LOW);
          prev_ott_owned_st = m_probe_txn.ott_owned_st;
          prev_ott_oldest_st = m_probe_txn.ott_oldest_st;
        end
    end

endtask:grab_owo_signals 

task ioaiu_probe_monitor::grab_cycle_counter();
    cycle_tracker_s cycle_tracker;
    forever begin
        @(m_vif.monitor_cb);
        cycle_tracker.m_time         = $time;
        cycle_tracker.m_cycle_count  = m_vif.get_cycle_count();
        probe_cycle_tracker_ap.write(cycle_tracker);
    end

endtask: grab_cycle_counter

task ioaiu_probe_monitor::grab_bypass_signals();
    forever begin
      @(posedge m_vif.clk);        
      <%if(obj.useCache){%>
            <% if(obj.testBench =="io_aiu") {%>
                <%for( var i=0;i<obj.nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                   m_probe_txn.bypass_bank<%=i%> = m_vif.bypass_bank<%=i%>; 
                <%}%>
            <%}%>
      <%}%>
      m_probe_txn.cycle_counter  = m_vif.get_cycle_count();
      probe_bypass_ap.write(m_probe_txn);
 
    end
endtask: grab_bypass_signals
task ioaiu_probe_monitor::grab_qos_signals();
    int                     starv_counter = 0;
    bit                     starvation_prev = 0;
    forever begin
        //@(m_vif.monitor_cb);
        @(posedge m_vif.clk);        // FIXME : instead of #1 delay below, check if we can use clocking blocks here sai
        #1;
        m_probe_txn.ott_entries             = m_vif.ott_entries     ;
        m_probe_txn.starvation              = m_vif.starv_evt_status;
        m_probe_txn.overflow                = m_vif.ott_overflow    ;
        m_probe_txn.global_counter          = m_vif.global_counter  ;
        m_probe_txn.starv_threshold         = m_vif.starv_threshold ;
        m_probe_txn.gc_threshold_reached    = (m_vif.global_counter == m_vif.starv_threshold); 
    	m_probe_txn.ott_entries             = m_vif.ott_entries;
    	m_probe_txn.ott_security            = m_vif.ott_security;
        `ifndef VCS
    	    m_probe_txn.ott_address             = m_vif.ott_address;
    	    m_probe_txn.ott_id                  = m_vif.ott_id;
        `elsif VCS
            foreach(m_vif.ott_address[i]) m_probe_txn.ott_address[i]          = m_vif.ott_address[i]; 
            foreach(m_vif.ott_id[i])      m_probe_txn.ott_id[i]               = m_vif.ott_id[i]; 
        `endif // `ifndef VCS ... `else ... 
        if(starvation_prev==0 && m_probe_txn.starvation==1) begin
          starv_counter++;
        end
        m_probe_txn.starv_counter           = starv_counter;
        starvation_prev                     = m_probe_txn.starvation;
        // m_probe_txn.ott_entries_chit = m_vif.ott_entries_chit;
        probe_rtl_ap.write(m_probe_txn);
    end
endtask : grab_qos_signals

task ioaiu_probe_monitor::grab_starv_signals();
    // fork
        // begin
    // forever begin
    //     @(posedge m_vif.starv_evt_status);
    //     m_probe_txn.starv_evt_status = 1'b1;
    //     probe_rtl_ap.write(m_probe_txn);
    //     m_probe_txn.starv_evt_status = 1'b0;
    // end
        // end
        // begin
        //     forever begin
        //         @(negedge m_vif.starv_evt_status);
        //         m_probe_txn.starv_evt_status = m_vif.starv_evt_status;
        //         probe_rtl_ap.write(m_probe_txn);
        //     end
        // end
    // join
endtask
//*****************************************************
task ioaiu_probe_monitor::grab_ioaiu_ottvec();//CONC-9721
     
    forever begin
        @(m_vif.monitor_cb);
        m_probe_txn.ottvld_vec              = m_vif.ott_entries;
        if (m_probe_txn.ottvld_vec_prev != m_probe_txn.ottvld_vec) begin
    	    m_probe_txn.ott_security            = m_vif.ott_security;
	    m_probe_txn.ott_prot                = m_vif.ott_prot;
        `ifndef VCS
    	    m_probe_txn.ott_address             = m_vif.ott_address;
    	    m_probe_txn.ott_id                  = m_vif.ott_id;
	    m_probe_txn.ott_user                = m_vif.ott_user;
	    m_probe_txn.ott_qos                 = m_vif.ott_qos;
	    m_probe_txn.ott_write               = m_vif.ott_write;
	    m_probe_txn.ott_evict               = m_vif.ott_evict;
            m_probe_txn.ott_cache               = m_vif.ott_cache;
        `elsif VCS
            foreach(m_vif.ott_address[i]) m_probe_txn.ott_address[i]          = m_vif.ott_address[i]; 
            foreach(m_vif.ott_id[i])      m_probe_txn.ott_id[i]               = m_vif.ott_id[i]; 
            foreach(m_vif.ott_user[i])    m_probe_txn.ott_user[i]             = m_vif.ott_user[i]; 
            foreach(m_vif.ott_qos[i])     m_probe_txn.ott_qos[i]              = m_vif.ott_qos[i]; 
            foreach(m_vif.ott_write[i])   m_probe_txn.ott_write[i]            = m_vif.ott_write[i]; 
            foreach(m_vif.ott_evict[i])   m_probe_txn.ott_evict[i]            = m_vif.ott_evict[i]; 
            foreach(m_vif.ott_cache[i])   m_probe_txn.ott_cache[i]            = m_vif.ott_cache[i]; 
        `endif // `ifndef VCS ... `else ... 
            probe_ottvec_ap.write(m_probe_txn);
            //adding to prev ott entry
            m_probe_txn.ottvld_vec_prev         = m_probe_txn.ottvld_vec;
            //`uvm_info(get_name(), $psprintf("Time: %t Put the ottvld_vec into probe_ioaiu_ap port, ott_address: %0p \n ott_id: %0p \n ott_user: %0p \n ott_write: %0p \n ottvld_vec_prev: %0p \n ott_security: %0d",$time, m_vif.ott_address, m_vif.ott_id, m_vif.ott_user, m_vif.ott_write, m_probe_txn.ottvld_vec, m_vif.ott_security), UVM_LOW);
        end
    end
endtask: grab_ioaiu_ottvec

task ioaiu_probe_monitor::grab_owo_ottst_vec();//CONC-9721

endtask: grab_owo_ottst_vec
