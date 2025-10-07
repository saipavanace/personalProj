`include "ncore_env.sv"

class my_report_server extends uvm_default_report_server;

    function new(string name = "my_report_server");
        super.new();
    endfunction
 
    virtual function void report_summarize(UVM_FILE file = 0);
        uvm_report_server svr;
        string id;
        string name;
        string output_str;
        string q[$],q2[$];
        int m_max_quit_count,m_quit_count;
        int m_severity_count[uvm_severity];
        int m_id_count[string];
        bit enable_report_id_count_summary =1 ;
        uvm_severity q1[$];

        svr = uvm_report_server::get_server();
        m_max_quit_count = get_max_quit_count();
        m_quit_count = get_quit_count();

        svr.get_id_set(q2);
        foreach(q2[s]) begin
            m_id_count[q2[s]] = svr.get_id_count(q2[s]);
        end

        svr.get_severity_set(q1);
        foreach(q1[s]) begin
            m_severity_count[q1[s]] = svr.get_severity_count(q1[s]);
        end

        uvm_report_catcher::summarize();
        q.push_back("\n--- UVM Report Summary ---\n\n");

        if(m_max_quit_count != 0) begin
            if ( m_quit_count >= m_max_quit_count ) begin
                q.push_back("Quit count reached!\n");
            end
            q.push_back($sformatf("Quit count : %5d of %5d\n",m_quit_count, m_max_quit_count));
        end

        q.push_back("** Report counts by severity\n");
        foreach(m_severity_count[s]) begin
            q.push_back($sformatf("%s :%5d\n", s.name(), m_severity_count[s]));
        end

        if (enable_report_id_count_summary) begin
            q.push_back("** Report counts by id\n");
            foreach(m_id_count[id]) begin
                q.push_back($sformatf("[%s] %5d\n", id, m_id_count[id]));
            end
        end

        `uvm_info("UVM/REPORT/SERVER",`UVM_STRING_QUEUE_STREAMING_PACK(q),UVM_NONE)
    endfunction: report_summarize
endclass: my_report_server

class ncore_base_test extends uvm_test;
    `uvm_component_utils(ncore_base_test)

    ncore_env m_env;
    ncore_base_vseq m_base_vseq;
    ncore_vip_configuration cfg;
    
    function new(string name = "ncore_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cfg = ncore_vip_configuration::type_id::create("cfg");
        cfg.set_amba_sys_config();
        uvm_config_db#(ncore_vip_configuration)::set(this, "env", "cfg", cfg);
        m_env = ncore_env::type_id::create("m_env", this);
        m_base_vseq = ncore_base_vseq::type_id::create("m_base_vseq");
        //Display the configuration
        `uvm_info("body", $sformatf("The NCORE system configuration is: \n%0s", cfg.sprint()), UVM_NONE)
        <% for(var idx = 0; idx < obj.nCHIs; idx++) { %>
            uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_amba_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr.run_phase", "default_sequence", svt_chi_rn_transaction_null_sequence::type_id::get());
            /** Apply the Snoop sequence to CHI RNs SNP XACT SEQR */
            uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_amba_env.chi_system[0].rn[<%=idx%>].rn_snp_xact_seqr.run_phase", "default_sequence", ncore_svt_chi_rn_directed_snoop_resp_seq::type_id::get());
        <%}%>

        /** Apply the memory SN response sequence to SN sequencer */
        uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_amba_env.axi_system[0].slave*.sequencer.run_phase", "default_sequence", ncore_axi_slave_mem_resp_seq::type_id::get());
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        super.run_phase(phase);
        phase.drop_objection(this);
    endtask: run_phase

    function void start_of_simulation_phase(uvm_phase phase);
        `ifndef UVM_VERSION_1_1
            my_report_server my_server = new;
        `endif

        `uvm_info("start_of_simulation_phase", "is entered",UVM_NONE)
        super.start_of_simulation_phase(phase);
        
        `ifndef UVM_VERSION_1_1
            uvm_report_server::set_server( my_server );
        `endif

        `uvm_info("start_of_simulation_phase", "is exited",UVM_NONE)
    endfunction :start_of_simulation_phase

    function void final_phase(uvm_phase phase);
        uvm_report_server svr;
        super.final_phase(phase);
        svr = uvm_report_server::get_server();
        
        if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) > 0) begin
            `uvm_info("FAIL", "\nNCORE TEST RESULT: Failed\n",UVM_NONE)
        end else begin
            `uvm_info("PASS", "\nNCORE TEST RESULT: Passed\n",UVM_NONE)
        end
    endfunction: final_phase
endclass: ncore_base_test
