
class chi_subsys_mkrdunq_error_test extends chi_subsys_base_test;
    
    `uvm_component_utils(chi_subsys_mkrdunq_error_test)

    function new(string name = "chi_subsys_mkrdunq_error_test", uvm_component parent = null);
        super.new(name, parent);
        m_addr_mgr = addr_trans_mgr::get_instance();
    endfunction: new

    function void build_phase(uvm_phase phase);
        `uvm_info("Build", "Entered Mkrdunq error test Build Phase", UVM_LOW);
        super.build_phase(phase);
        `uvm_info("Build", "Exited Mkrdunq error test Build Phase", UVM_LOW);
    endfunction: build_phase

    virtual task start_sequence();
        bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr;
        chi_subsys_mkrdunq_error_vseq      m_mkrdunq_error_vseq;
        int count = 0;

        `uvm_info("TEST_MAIN", "Starting chi_subsys_mkrdunq_error_test::staring sequence ...", UVM_LOW)

        // #Check.CHI.v3.6.MakeReadUnique.Err_first_part
        // #Check.CHI.v3.6.MakeReadUnique.Err_second_part
        // #Check.CHI.v3.6.MakeReadUnique_Err_not_excl
        
        m_mkrdunq_error_vseq = chi_subsys_mkrdunq_error_vseq::type_id::create("m_mkrdunq_error_vseq");
        // m_mkrdunq_error_vseq.chi_sys_cfg = cfg.chi_sys_cfg[0];
        m_mkrdunq_error_vseq.rn_xact_seqr0 = m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[0].rn_xact_seqr;
        m_mkrdunq_error_vseq.rn_xact_seqr1 = m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[1].rn_xact_seqr;
        fork
            begin
                m_mkrdunq_error_vseq.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].virt_seqr);
                #1us; 
            end
            
            begin
                forever begin
                    @(posedge m_chi1_probe_vif.str_req_vld);
                    count++;
                    if (count == 4) begin
                        m_chi1_probe_vif.force_strreq(8'b10000010);
                    end
                    
                    @(posedge m_chi1_probe_vif.clk);
                    if (count == 4) begin
                        m_chi1_probe_vif.release_strreq();
                    end
                end
            end

            begin
                forever begin
                    @(posedge m_chi1_probe_vif.dtr_req_rx_vld);
                    count++;
                    if (count == 1) begin
                        @(posedge m_chi1_probe_vif.clk);
                        @(posedge m_chi1_probe_vif.clk);
                        @(posedge m_chi1_probe_vif.clk);
                        @(posedge m_chi1_probe_vif.clk);
                        @(posedge m_chi1_probe_vif.clk);
                        m_chi1_probe_vif.disable_dtrreq();
                    end
                    
                    // @(posedge m_chi1_probe_vif.clk);
                    // if (count == 3) begin
                    //     m_chi1_probe_vif.release_strreq();
                    // end
                end
            end
        join_any
        // access DCE probe signals
        
        `uvm_info("TEST_MAIN", "Finish chi_subsys_mkrdunq_error_test end of sequence ...", UVM_LOW)
                
    endtask: start_sequence

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase

endclass: chi_subsys_mkrdunq_error_test
