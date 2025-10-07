////////////////////////////////////////////////////////////////////////////////
//
// Author       : 
// Purpose      : Customer testbench Performance Analyzer
// Description  :    
//
////////////////////////////////////////////////////////////////////////////////
<%
const chipletObj = obj.lib.getAllChipletRefs();
const chipletInstances = obj.lib.getAllChipletInstanceNames();
%>

`include "ncore_perf_metrics.sv"
class ncore_perf_analyzer extends uvm_component;

    `uvm_component_utils(ncore_perf_analyzer)

    // AIU
    <% for(let idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
        `uvm_analysis_imp_decl(_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port)
        `uvm_analysis_imp_decl(_smi_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port)

        <%if(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI')){%>
            uvm_analysis_imp_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port #(svt_chi_transaction, ncore_perf_analyzer) <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port;
            uvm_analysis_imp_smi_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port #(smi_seq_item, ncore_perf_analyzer) smi_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port;
        <%} else {%>
            uvm_analysis_imp_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port #(svt_axi_transaction, ncore_perf_analyzer) <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port;
            uvm_analysis_imp_smi_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port #(smi_seq_item, ncore_perf_analyzer) smi_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port;
        <%}%>
        int num_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_txn_initiated;
        int num_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_txn_completed;
        ncore_perf_metrics <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_perf_metrics;
    <%}%>

    // DMI
    <%for(var pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
        `uvm_analysis_imp_decl(_<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_port)
        `uvm_analysis_imp_decl(_smi_dmi<%=pidx%>_port)
        uvm_analysis_imp_<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_port #(svt_axi_transaction, ncore_perf_analyzer) <%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_port;
        uvm_analysis_imp_smi_dmi<%=pidx%>_port #(smi_seq_item, ncore_perf_analyzer) smi_dmi<%=pidx%>_port;
        ncore_perf_metrics <%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_perf_metrics;
    <%}%>

    // DCE
    <%for(var pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) { %>
        `uvm_analysis_imp_decl(_<%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>_port)
        `uvm_analysis_imp_decl(_smi_dce<%=pidx%>_port)
        uvm_analysis_imp_<%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>_port #(svt_axi_transaction, ncore_perf_analyzer) <%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>_port;
        uvm_analysis_imp_smi_dce<%=pidx%>_port #(smi_seq_item, ncore_perf_analyzer) smi_dce<%=pidx%>_port;
    <%}%>

    // DII
    <%for(var pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) { %>
        `uvm_analysis_imp_decl(_<%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_port)
        `uvm_analysis_imp_decl(_smi_dii<%=pidx%>_port)
        uvm_analysis_imp_<%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_port #(svt_axi_transaction, ncore_perf_analyzer) <%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_port;
        uvm_analysis_imp_smi_dii<%=pidx%>_port #(smi_seq_item, ncore_perf_analyzer) smi_dii<%=pidx%>_port;
        ncore_perf_metrics <%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_perf_metrics;
    <%}%>

    uvm_event sys_test_done_event;
    bit booting_process_done = 'b0;

    virtual ncore_clk_if m_clk_if;

    bit all_txn_done ='b0;

    // Extern Function/Task
    extern function new(string name="ncore_perf_analyzer", uvm_component parent=null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void extract_phase( uvm_phase phase );
    extern function void check_phase  ( uvm_phase phase );
    extern function void report_phase ( uvm_phase phase ); 
    extern function void final_phase  ( uvm_phase phase ); 
    extern task all_txn_done_check();

    <%for(var idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
        <%if(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI')){%>
            extern function void write_smi_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port(const ref smi_seq_item m_pkt);
            extern function void write_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port(svt_chi_transaction chi_pkt);
        <%} else  {%>
            extern function void write_smi_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port(const ref smi_seq_item m_pkt);
            extern function void write_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port(svt_axi_transaction axi_pkt);
        <%}%>
    <%}%>

    <%for(var pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
        extern function void write_smi_dmi<%=pidx%>_port(const ref smi_seq_item m_pkt);
        extern function void write_<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_port(svt_axi_transaction axi_pkt);
    <%}%>

    <%for(var pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) { %>
        extern function void write_smi_dce<%=pidx%>_port(const ref smi_seq_item m_pkt);
        extern function void write_<%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>_port(svt_axi_transaction axi_pkt);
    <%}%>

    <%for(var pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) { %>
        extern function void write_smi_dii<%=pidx%>_port(const ref smi_seq_item m_pkt);
        extern function void write_<%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_port(svt_axi_transaction axi_pkt);
    <%}%>
 
endclass: ncore_perf_analyzer


//******************************************************************************
// Function : new
// Purpose  : 
//******************************************************************************
function ncore_perf_analyzer::new(string name="ncore_perf_analyzer", uvm_component parent=null);
    super.new(name, parent);
    sys_test_done_event = uvm_event_pool::get_global("sys_test_done_event");
endfunction: new

//******************************************************************************
// Function : build_phase
// Purpose  : 
//******************************************************************************
function void ncore_perf_analyzer::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual ncore_clk_if)::get(this,
                                                   "",
                                                   "vif",
                                                   m_clk_if)) begin
        `uvm_fatal("PERF_ANALYZER Build_phase", "Couldn't get the Inteface ");
    end

    // Perf. Metrics
    // ----------------
    // AIUs
    <%for(var idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
        <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_perf_metrics = ncore_perf_metrics::type_id::create("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_perf_metrics",this);
        <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_perf_metrics.data_width = <%=chipletObj[0].AiuInfo[idx].wData%> ;
        <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_perf_metrics.native_interface  = "<%=chipletObj[0].AiuInfo[idx].fnNativeInterface%>" ;
        <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_perf_metrics.isSlave  = '0 ;
        <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_perf_metrics.component_type = "AIU";

        <% for(var clk=0; clk<chipletObj[0].Clocks.length; clk++) { %>
            <%if(chipletObj[0].AiuInfo[idx].nativeClk == chipletObj[0].Clocks[clk].name){%>
                <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_perf_metrics.clock_period = <%=chipletObj[0].Clocks[clk].params.period%>;
            <%}%>
        <%}%>
    <%}%>
    // DMIs
    <%for(var pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
        <%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_perf_metrics = ncore_perf_metrics::type_id::create("<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_perf_metrics",this);
        <%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_perf_metrics.data_width = <%=chipletObj[0].DmiInfo[pidx].wData%> ;
        <%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_perf_metrics.native_interface  = "<%=chipletObj[0].DmiInfo[pidx].fnNativeInterface%>";
        <%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_perf_metrics.isSlave = 'b1;
        <%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_perf_metrics.component_type = "DMI";

        <% for(var clk=0; clk<chipletObj[0].Clocks.length; clk++) { %>
            <%if(chipletObj[0].DmiInfo[pidx].unitClk == chipletObj[0].Clocks[clk].name){%> //TODO : unitClk ?
                <%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_perf_metrics.clock_period = <%=chipletObj[0].Clocks[clk].params.period%>;
            <%}%>
        <%}%>
    <%}%>
    // DIIs
    <%for(var pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) { %>
        <%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_perf_metrics = ncore_perf_metrics::type_id::create("<%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_perf_metrics",this);
        <%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_perf_metrics.data_width = <%=chipletObj[0].DiiInfo[pidx].wData%> ;
        <%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_perf_metrics.native_interface  = "<%=chipletObj[0].DiiInfo[pidx].fnNativeInterface%>";
        <%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_perf_metrics.isSlave = 'b1;
        <%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_perf_metrics.component_type = "DII";

        <% for(var clk=0; clk<chipletObj[0].Clocks.length; clk++) { %>
            <%if(chipletObj[0].DiiInfo[pidx].unitClk == chipletObj[0].Clocks[clk].name){%> //TODO : unitClk ?
                <%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_perf_metrics.clock_period = <%=chipletObj[0].Clocks[clk].params.period%>;
            <%}%>
        <%}%>
    <%}%>

    // SMI Port
    // ---------------
    // AIUs
    <%for(var idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
        smi_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port = new("smi_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port", this);
        <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port = new("<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port", this);
    <%}%>
    // DMIs
    <%for(var pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
        smi_dmi<%=pidx%>_port = new("smi_dmi<%=pidx%>_port", this);
        <%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_port = new("<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_port", this);
    <%}%>
    // DCEs
    <%for(var pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) { %>
        smi_dce<%=pidx%>_port = new("smi_dce<%=pidx%>_port", this);
        <%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>_port = new("<%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>_port", this);
    <%}%>
    // DIIs
    <%for(var pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) { %>
        smi_dii<%=pidx%>_port = new("smi_dii<%=pidx%>_port", this);
        <%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_port = new("<%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_port", this);
    <%}%>

endfunction: build_phase

//******************************************************************************
// Task     : run_phase
// Purpose  : 
//******************************************************************************
task ncore_perf_analyzer::run_phase(uvm_phase phase);
    fork
        begin 
            sys_test_done_event.wait_trigger();
            booting_process_done =  'b1;
        end
        all_txn_done_check();
    join
endtask : run_phase

//******************************************************************************
// Function : extract_phase
// Purpose  : 
//******************************************************************************
function void ncore_perf_analyzer::extract_phase( uvm_phase phase );
    super.extract_phase(phase); 
endfunction : extract_phase

//******************************************************************************
// Function : check_phase
// Purpose  : 
//******************************************************************************
function void ncore_perf_analyzer::check_phase( uvm_phase phase );
    super.check_phase(phase);
    `uvm_info("PERF_ANALYZER Check_Phase ",$sformatf("All Transaction data : "), UVM_DEBUG);
    <%for(var idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
       $display("%-20s : %-20d ", "num_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_txn_initiated",num_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_txn_initiated );
       $display("%-20s : %-20d ", "num_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_txn_completed", num_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_txn_completed);
    <%}%>
        $display("all_txn_done \t : ",all_txn_done);
endfunction : check_phase

//******************************************************************************
// Function : report_phase
// Purpose  : 
//******************************************************************************
function void ncore_perf_analyzer::report_phase( uvm_phase phase );
    super.report_phase(phase); 
endfunction : report_phase

//******************************************************************************
// Function : final_phase
// Purpose  : 
//******************************************************************************
function void ncore_perf_analyzer::final_phase( uvm_phase phase );
    super.final_phase(phase);
    //my_summarize_test_results(); 
endfunction : final_phase

//******************************************************************************
// Task     : all_txn_done_check
// Purpose  : 
//******************************************************************************
task ncore_perf_analyzer::all_txn_done_check();
    forever begin
        @(posedge m_clk_if.clk);
        all_txn_done = ( 
        <%for(var idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
           num_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_txn_initiated == num_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_txn_completed &&
        <%}%>
            'd1 );
    end
endtask : all_txn_done_check

//******************************************************************************
// 
//                  All Write Methods
//
//******************************************************************************
<%for(var idx = 0; idx < chipletObj[0].AiuInfo.length; idx++) {%>
    function void ncore_perf_analyzer::write_smi_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port(const ref smi_seq_item m_pkt);
        smi_seq_item temp_pkt = smi_seq_item::type_id::create("temp_pkt");
        temp_pkt.copy(m_pkt);

        if(temp_pkt.isCmdMsg()) begin // CMD_REQ
            num_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_txn_initiated++;
            `uvm_info("PERF_ANALYZER_SMI : <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> ", $psprintf("Received below SMI packet at PERF_ANALYZER: TXN_INITIATED:%0d, PKT: %0s",num_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_txn_initiated,temp_pkt.convert2string()), UVM_DEBUG)
        end
        if(temp_pkt.isStrRspMsg()) begin // STR_RSP
            num_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_txn_completed++;
            `uvm_info("PERF_ANALYZER_SMI : <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%> ", $psprintf("Received below SMI packet at PERF_ANALYZER: TXN_COMPLETED:%0d, PKT: %0s",num_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_txn_completed,temp_pkt.convert2string()), UVM_DEBUG)
        end
    endfunction : write_smi_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port

    <%if(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI')){%>
        function void ncore_perf_analyzer::write_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port( svt_chi_transaction chi_pkt);
            string txn_type;
            chi_pkt.print();
            if(booting_process_done) begin
                txn_type = $sformatf("%s",chi_pkt.xact_type);
                <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_perf_metrics.calculate_latency_bandwidth(chi_pkt.get_begin_time, chi_pkt.get_end_time,chi_pkt.data_size, 'b1 );
                <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_perf_metrics.store_txn_data(chi_pkt.addr, txn_type);
                `uvm_info("PERF_ANALYZER", $sformatf("Received chi_pkt: %s", chi_pkt.convert2string()), UVM_DEBUG)
            end
        endfunction : write_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port
    <%} else  {%>
        function void ncore_perf_analyzer::write_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port( svt_axi_transaction axi_pkt);
            string txn_type;
            axi_pkt.print();
            if(booting_process_done) begin
                <%if(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('AXI4') || chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('AXI5') ){%>
                    txn_type = $sformatf("%s",axi_pkt.xact_type);
                <% } else { %>
                    txn_type = $sformatf("%s",axi_pkt.coherent_xact_type);
                <%}%>
                <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_perf_metrics.calculate_latency_bandwidth(axi_pkt.get_begin_time, axi_pkt.get_end_time, axi_pkt.burst_size, axi_pkt.burst_length);
                <%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_perf_metrics.store_txn_data(axi_pkt.addr, txn_type);
                `uvm_info("PERF_ANALYZER", $sformatf("Received axi_pkt: %s", axi_pkt.convert2string()), UVM_DEBUG)
            end
        endfunction : write_<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_port
    <%}%>
<%}%>

<%for(var pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
    function void ncore_perf_analyzer::write_smi_dmi<%=pidx%>_port(const ref smi_seq_item m_pkt);
        smi_seq_item temp_pkt = smi_seq_item::type_id::create("temp_pkt");
        temp_pkt.copy(m_pkt);
        `uvm_info("PERF_ANALYZER_SMI : DMI<%=pidx%> ", $psprintf("Received below SMI packet at PERF_ANALYZER: %0s",temp_pkt.convert2string()), UVM_DEBUG)
    endfunction : write_smi_dmi<%=pidx%>_port 

    function void ncore_perf_analyzer::write_<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_port( svt_axi_transaction axi_pkt);
        string txn_type;
        //axi_pkt.print();
        if(booting_process_done) begin
            <%if(chipletObj[0].DmiInfo[pidx].fnNativeInterface.includes('AXI4') || chipletObj[0].DmiInfo[pidx].fnNativeInterface.includes('AXI5') ){%>
                txn_type = $sformatf("%s",axi_pkt.xact_type);
            <% } else { %>
                txn_type = $sformatf("%s",axi_pkt.coherent_xact_type);
            <%}%>
            <%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_perf_metrics.calculate_latency_bandwidth(axi_pkt.get_begin_time, axi_pkt.get_end_time, axi_pkt.burst_size, axi_pkt.burst_length);
            <%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_perf_metrics.store_txn_data(axi_pkt.addr, txn_type);
            `uvm_info("PERF_ANALYZER", $sformatf("Received axi_pkt: %s", axi_pkt.convert2string()), UVM_DEBUG)
        end
       `uvm_info("PERF_ANALYZER : write_<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_port ", $sformatf("Received axi_pkt: %s", axi_pkt.convert2string()), UVM_DEBUG)
    endfunction : write_<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>_port
<%}%>


<%for(var pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) { %>
    function void ncore_perf_analyzer::write_smi_dce<%=pidx%>_port(const ref smi_seq_item m_pkt);
        smi_seq_item temp_pkt = smi_seq_item::type_id::create("temp_pkt");
        temp_pkt.copy(m_pkt);
        `uvm_info("PERF_ANALYZER_SMI : DCE<%=pidx%> ", $psprintf("Received below SMI packet at PERF_ANALYZER: %0s",temp_pkt.convert2string()), UVM_DEBUG)
    endfunction : write_smi_dce<%=pidx%>_port

    function void ncore_perf_analyzer::write_<%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>_port(svt_axi_transaction axi_pkt);
       //axi_pkt.print();
       `uvm_info("PERF_ANALYZER : write_<%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>_port ", $sformatf("Received axi_pkt: %s", axi_pkt.convert2string()), UVM_DEBUG)
    endfunction : write_<%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>_port
<%}%>

<%for(var pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) { %>
    function void ncore_perf_analyzer::write_smi_dii<%=pidx%>_port(const ref smi_seq_item m_pkt);
        smi_seq_item temp_pkt = smi_seq_item::type_id::create("temp_pkt");
        temp_pkt.copy(m_pkt);
        `uvm_info("PERF_ANALYZER_SMI : DII<%=pidx%> ", $psprintf("Received below SMI packet at PERF_ANALYZER: %0s",temp_pkt.convert2string()), UVM_DEBUG)
    endfunction : write_smi_dii<%=pidx%>_port

    function void ncore_perf_analyzer::write_<%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_port( svt_axi_transaction axi_pkt);
        string txn_type;
        //axi_pkt.print();
        if(booting_process_done) begin
            <%if(chipletObj[0].DiiInfo[pidx].fnNativeInterface.includes('AXI4') || chipletObj[0].DmiInfo[pidx].fnNativeInterface.includes('AXI5') ){%>
                txn_type = $sformatf("%s",axi_pkt.xact_type);
            <% } else { %>
                txn_type = $sformatf("%s",axi_pkt.coherent_xact_type);
            <%}%>
            <%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_perf_metrics.calculate_latency_bandwidth(axi_pkt.get_begin_time, axi_pkt.get_end_time, axi_pkt.burst_size, axi_pkt.burst_length);
            <%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_perf_metrics.store_txn_data(axi_pkt.addr, txn_type);
            `uvm_info("PERF_ANALYZER", $sformatf("Received axi_pkt: %s", axi_pkt.convert2string()), UVM_DEBUG)
        end
       `uvm_info("PERF_ANALYZER : write_<%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_port ", $sformatf("Received axi_pkt: %s", axi_pkt.convert2string()), UVM_DEBUG)
    endfunction : write_<%=chipletObj[0].DiiInfo[pidx].strRtlNamePrefix%>_port
<%}%>
