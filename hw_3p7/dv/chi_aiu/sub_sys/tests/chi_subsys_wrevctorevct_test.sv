
class chi_subsys_wrevctorevct_test extends chi_subsys_base_test;
    
    `uvm_component_utils(chi_subsys_wrevctorevct_test)

    function new(string name = "chi_subsys_wrevctorevct_test", uvm_component parent = null);
        super.new(name, parent);
        m_addr_mgr = addr_trans_mgr::get_instance();
    endfunction: new

    function void build_phase(uvm_phase phase);
        `uvm_info("Build", "Entered Wrevctorevct Build Phase", UVM_LOW);
        super.build_phase(phase);
        `uvm_info("Build", "Exited Wrevctorevct Build Phase", UVM_LOW);
    endfunction: build_phase

    virtual task start_sequence();
        bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr;
        chi_subsys_wrevctorevct_vseq      m_wrevctorevct_vseq;

        `uvm_info("TEST_MAIN", "Starting chi_subsys_wrevctorevct_test::staring sequence ...", UVM_LOW)
        
        m_wrevctorevct_vseq = chi_subsys_wrevctorevct_vseq::type_id::create("m_wrevctorevct_vseq");
        // m_wrevctorevct_vseq.chi_sys_cfg = cfg.chi_sys_cfg[0];
        m_wrevctorevct_vseq.rn_xact_seqr0 = m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[0].rn_xact_seqr;
        m_wrevctorevct_vseq.rn_xact_seqr1 = m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[1].rn_xact_seqr;
        m_wrevctorevct_vseq.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].virt_seqr);
        `uvm_info("TEST_MAIN", "Finish chi_subsys_wrevctorevct_test end of sequence ...", UVM_LOW)
                
    endtask: start_sequence

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask: run_phase

endclass: chi_subsys_wrevctorevct_test
