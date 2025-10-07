<%if(obj.enInternalCode){%>
    `include "ncore_predictor.sv"
<%}%>
class ncore_perf_analyzer extends uvm_scoreboard;
    <%if(obj.enInternalCode){%>
        `uvm_component_utils(ncore_perf_analyzer)

        ncore_predictor n_predictor;

        `uvm_analysis_imp_decl(_port1)
        `uvm_analysis_imp_decl(_port2)
 
        uvm_analysis_imp_port1 #(svt_chi_transaction, ncore_perf_analyzer) analysis_imp1;
        uvm_analysis_imp_port2 #(svt_axi_transaction, ncore_perf_analyzer) analysis_imp2;
        
        int latency = 0;
        int bandwidth = 0;
        int total_latency = 0;
        int total_bandwidth = 0;
        int transaction_count = 0;
        static int num_chi_txn = 0;
        static int num_axi_txn = 0;

        real chi_latency[$]; 
        real axi_latency[$]; 
        real longest_chi_delay, longest_axi_delay; 


        function new(string name="ncore_perf_analyzer", uvm_component parent=null);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            analysis_imp1 = new("analysis_imp1"     , this);
            analysis_imp2 = new("analysis_imp2"     , this);
            n_predictor   = ncore_predictor::type_id::create("n_predictor", this);
        endfunction: build_phase

        virtual function void write_port1(svt_chi_transaction chi_pkt);
            chi_pkt.print();
            calculate_chi_performance(chi_pkt);
            `uvm_info("PERF_ANALYZER", $sformatf("Received chi_pkt: %s", chi_pkt.convert2string()), UVM_DEBUG)
        endfunction

        virtual function void write_port2(svt_axi_transaction axi_txn);
            axi_txn.print();
            calculate_axi_performance(axi_txn);
            `uvm_info("PERF_ANALYZER", $sformatf("Received axi_txn: %s", axi_txn.convert2string()), UVM_DEBUG)
        endfunction
  
        virtual function void calculate_chi_performance(svt_chi_transaction chi_pkt);
            latency =  chi_pkt.get_end_time - chi_pkt.get_begin_time;
            chi_latency.push_back(latency); 
            bandwidth = (64 / (latency*1.0)) * 1000000000.0;
            `uvm_info("PERF_ANALYZER_CHI", $sformatf("Received latency: %0d, bandwidth: %0d, num_chi_txn: %0d", latency, bandwidth,num_chi_txn), UVM_DEBUG)
            num_chi_txn++;
        endfunction: calculate_chi_performance

        virtual function void calculate_axi_performance(svt_axi_transaction axi_txn);
            latency =  axi_txn.get_end_time - axi_txn.get_begin_time;
            axi_latency.push_back(latency); 
            bandwidth = (64 / (latency*1.0)) * 1000000000.0;
            `uvm_info("PERF_ANALYZER_AXI", $sformatf("Received latency: %0d, bandwidth: %0d, num_axi_txn: %0d", latency, bandwidth,num_axi_txn), UVM_DEBUG)
            num_axi_txn++;
        endfunction: calculate_axi_performance

        function void extract_phase( uvm_phase phase ); 
            foreach (chi_latency[i]) 
                if (chi_latency[i] > longest_chi_delay) longest_chi_delay = chi_latency[i]; 
            foreach (axi_latency[i]) 
                if (axi_latency[i] > longest_axi_delay) longest_axi_delay = axi_latency[i]; 
        endfunction

        function void check_phase( uvm_phase phase ); 
        endfunction 

        function void report_phase( uvm_phase phase ); 
            `uvm_info("PERF_ANALYZER_CHI", $sformatf("Longest CHI delay: %5.2f", longest_chi_delay), UVM_DEBUG); 
            `uvm_info("PERF_ANALYZER_AXI", $sformatf("Longest Axi delay: %5.2f", longest_axi_delay), UVM_DEBUG);
        endfunction
        function void final_phase( uvm_phase phase ); 
            //my_summarize_test_results(); 
        endfunction 

    <%}%>
endclass: ncore_perf_analyzer
