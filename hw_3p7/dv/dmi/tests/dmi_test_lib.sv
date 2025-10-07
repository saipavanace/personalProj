<% if((obj.testBench=='dmi') && (obj.INHOUSE_APB_VIP)) { %>
////////////////////////////////////////////////////////////////////////////////
// DMI CSR Base Test
//
////////////////////////////////////////////////////////////////////////////////
class dmi_csr_base_test extends dmi_base_test;
  `uvm_component_utils(dmi_csr_base_test)
  dmi_seq  test_seq;

  extern function new(string name = "dmi_csr_base_test", uvm_component parent = null);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task run_main(uvm_phase phase);
endclass: dmi_csr_base_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dmi_csr_base_test::new(string name = "dmi_csr_base_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------
task dmi_csr_base_test::run_phase(uvm_phase phase);
    run_main(phase);
endtask : run_phase

task dmi_csr_base_test::run_main(uvm_phase phase);
  uvm_objection uvm_obj = phase.get_objection();

 <% if (obj.INHOUSE_APB_VIP) { %>
  dmi_csr_init_seq csr_init_seq = dmi_csr_init_seq::type_id::create("csr_init_seq");
 <% } %>

`ifdef INHOUSE_AXI
  axi_slave_read_seq   m_slave_read_seq   = axi_slave_read_seq::type_id::create("slave_read_seq");
  axi_slave_write_seq  m_slave_write_seq  = axi_slave_write_seq::type_id::create("slave_write_seq");

  m_slave_read_seq.prob_ace_rd_resp_error = prob_ace_rd_resp_error;
  m_slave_write_seq.prob_ace_wr_resp_error = prob_ace_wr_resp_error;
`endif

<% if (obj.INHOUSE_APB_VIP) { %>
  csr_init_seq.model       = m_env.m_regs;
<% } %>

  test_seq = dmi_seq::type_id::create("test_seq");
//  test_seq.wt_mrd_rd_with_unq_cln  = wt_mrd_rd_with_unq_cln;
//  test_seq.wt_mrd_rd_with_shr_cln  = wt_mrd_rd_with_shr_cln;
//  test_seq.wt_mrd_rd_with_inv      = wt_mrd_rd_with_inv;
//  test_seq.wt_mrd_rd_with_unq      = wt_mrd_rd_with_unq;
//  test_seq.wt_mrd_flush            = wt_mrd_flush;
//  test_seq.wt_mrd_cln              = wt_mrd_cln;
//  test_seq.wt_mrd_inv              = wt_mrd_inv;
//  test_seq.wt_mrd_pref_read             = wt_mrd_pref_read;
//  test_seq.wt_dtw_no_dt            = wt_dtw_no_dt;
//  test_seq.wt_dtw_dt_ptl           = wt_dtw_dt_ptl;
//  test_seq.wt_dtw_dt_dty           = wt_dtw_dt_dty;
//  test_seq.wt_dtw_dt_cln           = wt_dtw_dt_cln;
//  test_seq.wt_rb_release           = wt_rb_release;
//  test_seq.wt_dtw_mrg_mrd_ucln     = wt_dtw_mrg_mrd_ucln;
//  test_seq.wt_dtw_mrg_mrd_udty     = wt_dtw_mrg_mrd_udty;
//  test_seq.wt_dtw_mrg_mrd_inv      = wt_dtw_mrg_mrd_inv ;
//  test_seq.wt_cmd_rd_nc            = wt_cmd_rd_nc     ;
//  test_seq.wt_cmd_wr_nc_ptl        = wt_cmd_wr_nc_ptl ;
//  test_seq.wt_cmd_wr_nc_full       = wt_cmd_wr_nc_full;
//  test_seq.wt_cmd_rd_atm           = wt_cmd_rd_atm  ;
//  test_seq.wt_cmd_wr_atm           = wt_cmd_wr_atm  ;
//  test_seq.wt_cmd_swap_atm         = wt_cmd_swap_atm;
//  test_seq.wt_cmd_cmp_atm          = wt_cmd_cmp_atm ;
  test_seq.k_atomic_opcode         = k_atomic_opcode ;
//  test_seq.wt_cmd_cln_inv          = wt_cmd_cln_inv     ;
//  test_seq.wt_cmd_cln_vld          = wt_cmd_cln_vld     ;
//  test_seq.wt_cmd_cln_ShPsist      = wt_cmd_cln_ShPsist ;
//  test_seq.wt_cmd_mk_inv           = wt_cmd_mk_inv      ;
//  test_seq.wt_cmd_pref             = wt_cmd_pref        ;
  test_seq.k_back_to_back_types    = k_back_to_back_types;
  test_seq.k_back_to_back_chains   = k_back_to_back_chains;
  test_seq.k_force_allocate        = k_force_allocate;

  test_seq.use_last_dealloc        = use_last_dealloc;
  test_seq.use_adj_addr            = use_adj_addr;
  test_seq.mrd_use_last_mrd_pref        = mrd_use_last_mrd_pref;

  test_seq.k_num_cmd               = k_num_cmd;
  test_seq.k_num_addr              = k_num_addr;

  test_seq.k_min_reuse_q_size      = k_min_reuse_q_size;
  test_seq.k_max_reuse_q_size      = k_max_reuse_q_size;
  test_seq.k_reuse_q_pct           =  k_reuse_q_pct;

  test_seq.k_sp_base_addr          = k_sp_base_addr;
  test_seq.k_sp_max_addr           = k_sp_max_addr;

  test_seq.k_full_cl_only          = k_full_cl_only;
  test_seq.k_force_size            = k_force_size;

  test_seq.n_pending_txn_mode      = n_pending_txn_mode;

  test_seq.tb_delay          = tb_delay;

`ifdef INHOUSE_AXI
      m_slave_read_seq.m_read_addr_chnl_seqr   = m_env.m_axi_slave_agent.m_read_addr_chnl_seqr;
      m_slave_read_seq.m_read_data_chnl_seqr   = m_env.m_axi_slave_agent.m_read_data_chnl_seqr;
      m_slave_read_seq.m_memory_model          = m_axi_memory_model;
      m_slave_write_seq.m_write_addr_chnl_seqr = m_env.m_axi_slave_agent.m_write_addr_chnl_seqr;
      m_slave_write_seq.m_write_data_chnl_seqr = m_env.m_axi_slave_agent.m_write_data_chnl_seqr;
      m_slave_write_seq.m_write_resp_chnl_seqr = m_env.m_axi_slave_agent.m_write_resp_chnl_seqr;
      m_slave_write_seq.m_memory_model         = m_axi_memory_model;
`endif

  uvm_config_db#(dmi_scoreboard)::set(uvm_root::get(), 
                                  "*", 
                                  "dmi_scb", 
                                  m_env.m_sb);


  fork
   uvm_obj.set_drain_time(null,1us);
`ifdef INHOUSE_AXI
   m_slave_read_seq.start(null);
   m_slave_write_seq.start(null);
`endif
  join_none

 <% if(obj.INHOUSE_APB_VIP && obj.useCmc && obj.DmiInfo[obj.Id].useScratchPad) { %>
  csr_init_seq.ScPadEn       = 'b1;
  csr_init_seq.ScPadBaseAddr = ScPadBaseAddr;
  csr_init_seq.NumScPadWays  = NumScPadWays;
 <% } %>

 <% if(obj.INHOUSE_APB_VIP) { %>
  phase.raise_objection(this, "Start dmi_csr_init_seq");
  `uvm_info("run_main", "dmi_csr_init_seq started",UVM_NONE)
  csr_init_seq.start(m_env.m_apb_agent.m_apb_sequencer);
  `uvm_info("run_main", "dmi_csr_init_seq finished",UVM_NONE)
  #100ns;
  phase.drop_objection(this, "Finish dmi_csr_init_seq");
 <% } %>

endtask : run_main

////////////////////////////////////////////////////////////////////////////////
//******************************************************************************
// Class    : dmi_csr_bit_bash_test 
// Purpose  : Write and read all registers to see if they are correctly written
//******************************************************************************
class dmi_csr_bit_bash_test extends dmi_base_test;
  `uvm_component_utils(dmi_csr_bit_bash_test)
   uvm_reg_bit_bash_seq reg_bit_bash_seq;

  function new(string name = "dmi_csr_bit_bash_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(),"*", "include_coverage", 0);
  endfunction : build_phase

  task run_phase (uvm_phase phase);
      super.run_phase(phase);
<% if (obj.useCmc) { %>
      uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.get_full_name()}, "NO_REG_TESTS", 1,this);
      uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCISR.get_full_name()}, "NO_REG_TESTS", 1,this);
<% } %>
      reg_bit_bash_seq       = uvm_reg_bit_bash_seq::type_id::create("reg_bit_bash_seq");
      reg_bit_bash_seq.model = m_env.m_regs;
      fork 
        begin
            phase.raise_objection(this, "Start DMI bit-bash sequence");
            #200ns;
            `uvm_info("DMI CSR Seq", "Starting DMI CSR bit-bash sequence",UVM_NONE)
            reg_bit_bash_seq.start(m_env.m_apb_agent.m_apb_sequencer);
            #200ns;
            phase.drop_objection(this, "Finish DMI bit-bash sequence");
        end
      join

    endtask : run_phase
endclass: dmi_csr_bit_bash_test

//******************************************************************************
// Class    : dmi_csr_all_reg_rd_reset_val_test 
// Purpose  : Reads all register reset values and matched with testbench
//******************************************************************************

class dmi_csr_all_reg_rd_reset_val_test extends dmi_base_test;
  `uvm_component_utils(dmi_csr_all_reg_rd_reset_val_test)
   uvm_reg_hw_reset_seq reg_hw_reset_seq;
   dmi_csr_id_reset_seq id_reset_seq;

  function new(string name = "dmi_csr_all_reg_rd_reset_val_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(bit)::set(uvm_root::get(),"*", "include_coverage", 0);
  endfunction : build_phase

  task run_phase (uvm_phase phase);
      super.run_phase(phase);
      <% if (obj.DmiInfo[obj.Id].useCmc) { %>
      uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCISR.get_full_name()}, "NO_REG_TESTS", 1,this);
      uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUTAR.get_full_name()}, "NO_REG_TESTS", 1,this);
      <% } %>
      reg_hw_reset_seq       = uvm_reg_hw_reset_seq::type_id::create("reg_hw_reset_seq");
      id_reset_seq           = dmi_csr_id_reset_seq::type_id::create("id_reset_seq");
      reg_hw_reset_seq.model = m_env.m_regs;
      id_reset_seq.model     = m_env.m_regs;

      fork 
        begin
            phase.raise_objection(this, "Start DMI CSR reset sequence");
            #100ns;
            `uvm_info("DMI CSR Seq", "Starting DMI CSR reset sequence",UVM_LOW)
            reg_hw_reset_seq.start(m_env.m_apb_agent.m_apb_sequencer);
            #100ns;
            `uvm_info("DMI CSR Seq", "Starting DMI CSR ID reset sequence",UVM_LOW)
            id_reset_seq.start(m_env.m_apb_agent.m_apb_sequencer);
            #100ns;
            phase.drop_objection(this, "Finish DMI CSR reset sequence");
        end
      join
    endtask : run_phase
endclass: dmi_csr_all_reg_rd_reset_val_test


<% if(obj.useCmc){%>
//******************************************************************************
// Class    : dmi_data_mem_single_bit_err_inj_chk_intrpt_test 
// Purpose  : Injects single bit error in CCP data mem and then waits for interrupt
//            signal to go high. after that, checks ErrInfo and ErrType
//******************************************************************************
class dmi_data_mem_single_bit_err_inj_chk_intrpt_test extends dmi_csr_base_test;
  `uvm_component_utils(dmi_data_mem_single_bit_err_inj_chk_intrpt_test)

  function new(string name = "dmi_data_mem_single_bit_err_inj_chk_intrpt_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  task run_phase (uvm_phase phase);
     single_bit_data_mem_err_inj_chk_seq csr_seq = single_bit_data_mem_err_inj_chk_seq::type_id::create("csr_seq");
     csr_seq.model = m_env.m_regs;
     super.run_phase(phase);

     fork
        begin
           phase.raise_objection(this, "Start DMI CSR sequence");
           `uvm_info("DMI CSR Seq", "Starting DMI CSR sequence",UVM_LOW)
           csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
           `uvm_info("DMI CSR Seq", "Starting DMI CSR sequence",UVM_LOW)
           phase.drop_objection(this, "Finish DMI CSR sequence");
        end
        begin
           phase.raise_objection(this, "Start DMI test sequence");
           `uvm_info("run_main", "test_seq objection raised",UVM_NONE)
           test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
           this.cache_addr_list = test_seq.cache_addr_list;
           phase.drop_objection(this, "Finish DMI test sequence");
           `uvm_info("run_main", "test_seq objection dropped",UVM_NONE)
        end
     join
     `uvm_info("run_main", "fork join completed",UVM_NONE)
  endtask : run_phase
endclass: dmi_data_mem_single_bit_err_inj_chk_intrpt_test


//******************************************************************************
// Class    : dmi_data_mem_double_bit_err_inj_chk_intrpt_test 
// Purpose  : Injects double bit error in CCP data mem and then waits for interrupt
//            signal to go high. after that, checks ErrInfo and ErrType
//******************************************************************************
class dmi_data_mem_double_bit_err_inj_chk_intrpt_test extends dmi_csr_base_test;
  `uvm_component_utils(dmi_data_mem_double_bit_err_inj_chk_intrpt_test)

  function new(string name = "dmi_data_mem_double_bit_err_inj_chk_intrpt_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  task run_phase (uvm_phase phase);
     double_bit_data_mem_err_inj_chk_seq csr_seq = double_bit_data_mem_err_inj_chk_seq::type_id::create("csr_seq");
     csr_seq.model = m_env.m_regs;
     super.run_phase(phase);

     fork
        begin
           phase.raise_objection(this, "Start DMI CSR sequence");
           `uvm_info("DMI CSR Seq", "Starting DMI CSR sequence",UVM_LOW)
           csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
           `uvm_info("DMI CSR Seq", "Starting DMI CSR sequence",UVM_LOW)
           phase.drop_objection(this, "Finish DMI CSR sequence");
        end
        begin
           phase.raise_objection(this, "Start DMI test sequence");
           `uvm_info("run_main", "test_seq objection raised",UVM_NONE)
           test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
           this.cache_addr_list = test_seq.cache_addr_list;
           phase.drop_objection(this, "Finish DMI test sequence");
           `uvm_info("run_main", "test_seq objection dropped",UVM_NONE)
        end
     join
     `uvm_info("run_main", "fork join completed",UVM_NONE)
  endtask : run_phase
endclass: dmi_data_mem_double_bit_err_inj_chk_intrpt_test


//******************************************************************************
// Class    : dmi_tag_mem_single_bit_err_inj_chk_intrpt_test 
// Purpose  : Injects single bit error in CCP tag mem and then waits for interrupt
//            signal to go high. after that, checks ErrInfo and ErrType
//******************************************************************************
class dmi_tag_mem_single_bit_err_inj_chk_intrpt_test extends dmi_csr_base_test;
  `uvm_component_utils(dmi_tag_mem_single_bit_err_inj_chk_intrpt_test)

  function new(string name = "dmi_tag_mem_single_bit_err_inj_chk_intrpt_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  task run_phase (uvm_phase phase);
     single_bit_tag_mem_err_inj_chk_seq csr_seq = single_bit_tag_mem_err_inj_chk_seq::type_id::create("csr_seq");
     csr_seq.model = m_env.m_regs;
     super.run_phase(phase);

     fork
        begin
           phase.raise_objection(this, "Start DMI CSR sequence");
           `uvm_info("DMI CSR Seq", "Starting DMI CSR sequence",UVM_LOW)
           csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
           `uvm_info("DMI CSR Seq", "Starting DMI CSR sequence",UVM_LOW)
           phase.drop_objection(this, "Finish DMI CSR sequence");
        end
        begin
           phase.raise_objection(this, "Start DMI test sequence");
           `uvm_info("run_main", "test_seq objection raised",UVM_NONE)
           test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
           this.cache_addr_list = test_seq.cache_addr_list;
           phase.drop_objection(this, "Finish DMI test sequence");
           `uvm_info("run_main", "test_seq objection dropped",UVM_NONE)
        end
     join
     `uvm_info("run_main", "fork join completed",UVM_NONE)
  endtask : run_phase
endclass: dmi_tag_mem_single_bit_err_inj_chk_intrpt_test


//******************************************************************************
// Class    : dmi_tag_mem_double_bit_err_inj_chk_intrpt_test 
// Purpose  : Injects double bit error in CCP tag mem and then waits for interrupt
//            signal to go high. after that, checks ErrInfo and ErrType
//******************************************************************************
class dmi_tag_mem_double_bit_err_inj_chk_intrpt_test extends dmi_csr_base_test;
  `uvm_component_utils(dmi_tag_mem_double_bit_err_inj_chk_intrpt_test)

  function new(string name = "dmi_tag_mem_double_bit_err_inj_chk_intrpt_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  task run_phase (uvm_phase phase);
     double_bit_tag_mem_err_inj_chk_seq csr_seq = double_bit_tag_mem_err_inj_chk_seq::type_id::create("csr_seq");
     csr_seq.model = m_env.m_regs;
     super.run_phase(phase);

     fork
        begin
           phase.raise_objection(this, "Start DMI CSR sequence");
           `uvm_info("DMI CSR Seq", "Starting DMI CSR sequence",UVM_LOW)
           csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
           `uvm_info("DMI CSR Seq", "Starting DMI CSR sequence",UVM_LOW)
           phase.drop_objection(this, "Finish DMI CSR sequence");
        end
        begin
           phase.raise_objection(this, "Start DMI test sequence");
           `uvm_info("run_main", "test_seq objection raised",UVM_NONE)
           test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
           this.cache_addr_list = test_seq.cache_addr_list;
           phase.drop_objection(this, "Finish DMI test sequence");
           `uvm_info("run_main", "test_seq objection dropped",UVM_NONE)
        end
     join
     `uvm_info("run_main", "fork join completed",UVM_NONE)
  endtask : run_phase
endclass: dmi_tag_mem_double_bit_err_inj_chk_intrpt_test

// In this test, allocation in Cache is necessary with UD state to detect the injected errors
class dmi_ccp_single_double_bit_data_error_intr_info_test extends dmi_csr_base_test;

  `uvm_component_utils(dmi_ccp_single_double_bit_data_error_intr_info_test)

  function new(string name = "dmi_ccp_single_double_bit_data_error_intr_info_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  task run_phase (uvm_phase phase);
     dmi_ccp_single_double_bit_data_error_intr_info_seq csr_seq = dmi_ccp_single_double_bit_data_error_intr_info_seq::type_id::create("csr_seq");
     dmi_ccp_offline_seq csr_offline_seq = dmi_ccp_offline_seq::type_id::create("csr_offline_seq");
     csr_offline_seq.model = m_env.m_regs;
     csr_seq.model = m_env.m_regs;

     super.run_phase(phase);
     uvm_config_db#(dmi_scoreboard)::set(uvm_root::get(), 
                                     "*", 
                                     "dmi_scb", 
                                     m_env.m_sb);

     //test_seq.k_num_write_req = 1000;
     //test_seq.k_num_read_req = 0;

     fork 
       begin
          phase.raise_objection(this, "Start DMI test_seq");
          `uvm_info("DMI CSR Seq", "Starting DMI test sequence",UVM_LOW)
          test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
          `uvm_info("DMI CSR Seq", "Finish DMI test sequence",UVM_LOW)
          phase.drop_objection(this, "Finish DMI test_seq");

          phase.raise_objection(this, "Start dmi_single_double_bit_err_inj_seq");
          #20000ns;
          `uvm_info("DMI CSR Seq", "Starting DMI CSR sequence",UVM_LOW)
          csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
          #20000ns;
          `uvm_info("DMI CSR Seq", "Finish DMI CSR sequence",UVM_LOW)
          phase.drop_objection(this, "Finish dmi_single_double_bit_err_inj_seq");

          phase.raise_objection(this, "Start CBI offline sequence");
          #20000ns;
          `uvm_info("DMI CSR Seq", "Running CBI CSR offline sequence",UVM_LOW)
          csr_offline_seq.start(m_env.m_apb_agent.m_apb_sequencer);
          #200000ns;
          phase.drop_objection(this, "Finish CBI offline sequence");
       end
     join

   endtask : run_phase

endclass: dmi_ccp_single_double_bit_data_error_intr_info_test


class dmi_ccp_single_double_bit_tag_error_intr_info_test extends dmi_csr_base_test;

  `uvm_component_utils(dmi_ccp_single_double_bit_tag_error_intr_info_test)

  function new(string name = "dmi_ccp_single_double_bit_tag_error_intr_info_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  task run_phase (uvm_phase phase);
     dmi_ccp_single_double_bit_tag_error_intr_info_seq csr_seq = dmi_ccp_single_double_bit_tag_error_intr_info_seq::type_id::create("csr_seq");
     dmi_ccp_offline_seq csr_offline_seq = dmi_ccp_offline_seq::type_id::create("csr_offline_seq");
     csr_offline_seq.model = m_env.m_regs;
     csr_seq.model = m_env.m_regs;

     super.run_phase(phase);
     uvm_config_db#(dmi_scoreboard)::set(uvm_root::get(), 
                                     "*", 
                                     "dmi_scb", 
                                     m_env.m_sb);

     fork 
       begin
          phase.raise_objection(this, "Start DMI test_seq");
          `uvm_info("DMI CSR Seq", "Starting DMI test sequence",UVM_LOW)
          test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
          `uvm_info("DMI CSR Seq", "Finish DMI test sequence",UVM_LOW)
          phase.drop_objection(this, "Finish DMI test_seq");

          phase.raise_objection(this, "Start dmi_single_double_bit_err_inj_seq");
          #20000ns;
          `uvm_info("DMI CSR Seq", "Starting DMI CSR sequence",UVM_LOW)
          csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
          #20000ns;
          `uvm_info("DMI CSR Seq", "Finish DMI CSR sequence",UVM_LOW)
          phase.drop_objection(this, "Finish dmi_single_double_bit_err_inj_seq");

          phase.raise_objection(this, "Start CBI offline sequence");
          #20000ns;
          `uvm_info("DMI CSR Seq", "Running CBI CSR offline sequence",UVM_LOW)
          csr_offline_seq.start(m_env.m_apb_agent.m_apb_sequencer);
          #200000ns;
          phase.drop_objection(this, "Finish CBI offline sequence");
       end
     join

   endtask : run_phase

endclass: dmi_ccp_single_double_bit_tag_error_intr_info_test
<% } %> // useCmc

//******************************************************************************
// Class   : dmi_trans_actv_test 
// Purpose : Checks TransActv register, TransActv should be 1 if there are txns pending in DMI, otherwise 0
//******************************************************************************

class dmi_trans_actv_test extends dmi_csr_base_test;
  time t_transactv_last_asserted;
  `uvm_component_utils(dmi_trans_actv_test)
  virtual dmi_csr_probe_if u_csr_probe_if;
  int count=0;

  function new(string name = "dmi_trans_actv_test", uvm_component parent=null);
     super.new(name,parent);
  endfunction: new

  task run_phase (uvm_phase phase);
     dmi_end_of_test_seq csr_seq = dmi_end_of_test_seq::type_id::create("csr_seq");
     dmi_trans_actv_high_seq csr_seq1 = dmi_trans_actv_high_seq::type_id::create("csr_seq1");

     csr_seq.model               = m_env.m_regs;
     csr_seq1.model                    = m_env.m_regs;
     super.run_phase(phase);
      if(!uvm_config_db#(virtual dmi_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_if))
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})

     fork 
        begin
           phase.raise_objection(this, "Start DMI test seq");
           `uvm_info("dmi_trans_actv_test", "Starting DMI test sequence",UVM_LOW)
           test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
           `uvm_info("dmi_trans_actv_test", "Finish DMI test sequence",UVM_LOW)
           #2000ns;
           csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
           phase.drop_objection(this, "Finish DMI test seq");
        end

        begin
           `uvm_info("DMI CSR Seq", "Starting to check TransActv register every cycle",UVM_LOW)
           fork
             forever begin
               @(posedge u_csr_probe_if.TransActv) begin
                 t_transactv_last_asserted = $time;
               end
             end
           join_none
           forever begin
              @(negedge u_csr_probe_if.clk);
              if ((((m_env.m_sb.rtt_q.size() + m_env.m_sb.wtt_q.size()) == 0) && (u_csr_probe_if.TransActv !== 0)) ||
                  (((m_env.m_sb.rtt_q.size() + m_env.m_sb.wtt_q.size()) != 0) && (u_csr_probe_if.TransActv !== 1))) begin
                 if(((m_env.m_sb.rtt_q.size() + m_env.m_sb.wtt_q.size()) != 0) && (u_csr_probe_if.TransActv !== 1)) begin
                   m_env.m_sb.compute_pma_exceptions(t_transactv_last_asserted);
                   if(m_env.m_sb.wtt_q.size !=0) begin
                     if(m_env.m_sb.wtt_q.size != m_env.m_sb.num_rb_waiting_on_dtw && m_env.m_sb.wtt_q.size != m_env.m_sb.num_dtws_early_transactv )
                       `uvm_error("dmi_trans_actv_test", $sformatf("WTT queue is not empty when dmi asserted TransActv. %0d != %0d,%0d", m_env.m_sb.wtt_q.size, m_env.m_sb.num_rb_waiting_on_dtw,m_env.m_sb.num_dtws_early_transactv))
                     else
                       `uvm_info("dmi_trans_actv_test", $sformatf("WTT has %0d pending entries but they're marked as RbReq with no DTW rcvd", m_env.m_sb.wtt_q.size), UVM_MEDIUM)
                   end
                   if(m_env.m_sb.rtt_q.size !=0) begin
                     if(m_env.m_sb.num_dtws_early_transactv != m_env.m_sb.num_dtwmrgmrd)
                       `uvm_error("dmi_trans_actv_test", $sformatf("RTT queue has pending entries when dmi asserted TransActv but they are due to pending DTWs created on a DTWMrgMrd %0d != %0d", m_env.m_sb.num_dtwmrgmrd, m_env.m_sb.num_dtws_early_transactv))
                     else
                       `uvm_info("dmi_trans_actv_test", $sformatf("RTT queue has %0d pending entries when dmi asserted TransActv but they are due to pending DTWs created on a DTWMrgMrd", m_env.m_sb.rtt_q.size), UVM_MEDIUM)
                   end
                 end
                 else begin   
                   `uvm_error("dmi_trans_actv_test", $sformatf("TransActv is not correct TransActv %0b rtt_q size %0d wtt_q size %0d",
                                                             u_csr_probe_if.TransActv, m_env.m_sb.rtt_q.size(), m_env.m_sb.wtt_q.size()))
                 end
              end else begin
                 `uvm_info("dmi_trans_actv_test", $sformatf("TransActv register matched TransActv %0b rtt_q size %0d wtt_q size %0d",
                                                            u_csr_probe_if.TransActv, m_env.m_sb.rtt_q.size(), m_env.m_sb.wtt_q.size()),UVM_HIGH)
              end
           end
        end

        begin
           repeat(50) @(negedge u_csr_probe_if.clk);
           `uvm_info("DMI CSR Seq", "Reading TransActv register",UVM_LOW)
           phase.raise_objection(this, "Start dmi_trans_actv_high_seq");
           do begin
              @(negedge u_csr_probe_if.clk);
              count++;
              if (count > 1000) begin
                 `uvm_error("dmi_trans_actv_test", "No enries in wtt/rtt queues for a long time")
              end
           end while ((m_env.m_sb.rtt_q.size() + m_env.m_sb.wtt_q.size()) == 0);
           csr_seq1.start(m_env.m_apb_agent.m_apb_sequencer);
           phase.drop_objection(this, "Finish dmi_trans_actv_high_seq");
        end
     join
  endtask : run_phase
endclass: dmi_trans_actv_test


<% if (obj.useCmc) { %>
//******************************************************************************
// Class   : dmi_lookup_alloc_en_test 
// Purpose :
//******************************************************************************

class dmi_lookup_alloc_en_test extends dmi_csr_base_test;
  `uvm_component_utils(dmi_lookup_alloc_en_test)
  virtual dmi_csr_probe_if u_csr_probe_if;
  bit lookup_en=0;
  bit alloc_en=0;

  function new(string name = "dmi_lookup_alloc_en_test", uvm_component parent=null);
     super.new(name,parent);
  endfunction: new

  task run_phase (uvm_phase phase);
     dmi_rand_lookup_alloc_en_seq csr_seq = dmi_rand_lookup_alloc_en_seq::type_id::create("csr_seq");
     csr_seq.model                        = m_env.m_regs;

     super.run_phase(phase);
     if(!uvm_config_db#(virtual dmi_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_if))
       `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})

     phase.raise_objection(this, "Start DMI test seq");
     `uvm_info("dmi_lookup_alloc_en_test", "Starting DMI test sequence",UVM_LOW)
     test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
     `uvm_info("dmi_lookup_alloc_en_test", "Finish DMI test sequence",UVM_LOW)
     #2000ns;
     phase.drop_objection(this, "Finish DMI test seq");

     lookup_en = $urandom_range(0,1);
     alloc_en  = $urandom_range(0,1);
     csr_seq.lookup_en = lookup_en;
     csr_seq.alloc_en  = alloc_en;
     m_env.m_sb.lookup_en = lookup_en;
     m_env.m_sb.alloc_en  = alloc_en;
     `uvm_info("DMI CSR Seq", $sformatf("lookup_en %0b alloc_en %0b", lookup_en, alloc_en),UVM_NONE)

     phase.raise_objection(this, "Start DMI rand_lookup_alloc_en sequence");
     `uvm_info("DMI CSR Seq", "Starting DMI rand_lookup_alloc_en sequence",UVM_LOW)
     csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
     `uvm_info("DMI CSR Seq", "Starting DMI rand_lookup_alloc_en sequence",UVM_LOW)
     phase.drop_objection(this, "Finish DMI rand_lookup_alloc_en sequence");

     fork 
        begin
           phase.raise_objection(this, "Start DMI test seq");
           `uvm_info("dmi_lookup_alloc_en_test", "Starting DMI test sequence",UVM_LOW)
           test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
           `uvm_info("dmi_lookup_alloc_en_test", "Finish DMI test sequence",UVM_LOW)
           if (lookup_en && alloc_en && (m_env.m_sb.m_dmi_cache_q.size == 0)) begin
              `uvm_error("dmi_lookup_alloc_en_test", $sformatf("lookup_en %0b and alloc_en %0b both are high, yet there is no entry in cache %0d",
                                                               lookup_en, alloc_en, m_env.m_sb.m_dmi_cache_q.size()))
           end
           #2000ns;
           phase.drop_objection(this, "Finish DMI test seq");
        end

        begin
           `uvm_info("DMI CSR Seq", "Starting to check TransActv register",UVM_LOW)
           forever begin
              @(negedge u_csr_probe_if.clk);
              if (!(lookup_en && alloc_en) && (m_env.m_sb.m_dmi_cache_q.size() != 0)) begin
                 `uvm_error("dmi_lookup_alloc_en_test", $sformatf("lookup_en %0b and alloc_en %0b both are not high, yet there are entries in cache %0d",
                                                                  lookup_en, alloc_en, m_env.m_sb.m_dmi_cache_q.size()))
              end
           end
        end
     join
  endtask : run_phase
endclass: dmi_lookup_alloc_en_test


//******************************************************************************
// Class   : dmi_alloc_evict_actv_test 
// Purpose : Checks AllocActv and EvictActv register fields
//           AllocActv should be 1 only if there are allocations pending in DMI
//           EvictActv should be 1 only if there are Evictions pending in DMI
//******************************************************************************

class dmi_alloc_evict_actv_test extends dmi_csr_base_test;
  `uvm_component_utils(dmi_alloc_evict_actv_test)
  virtual dmi_csr_probe_if u_csr_probe_if;
  logic expd_AllocActv;
  logic expd_EvictActv;
  logic recd_AllocActv;
  logic recd_EvictActv;
  logic match1;
  logic match2;
  int tmp1_q[$];
  int tmp2_q[$];

  function new(string name = "dmi_alloc_evict_actv_test", uvm_component parent=null);
     super.new(name,parent);
  endfunction: new

  task run_phase (uvm_phase phase);
     dmi_end_of_test_seq csr_seq = dmi_end_of_test_seq::type_id::create("csr_seq");
     csr_seq.model               = m_env.m_regs;

     super.run_phase(phase);
      if(!uvm_config_db#(virtual dmi_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_if))
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})

     fork 
        begin
           phase.raise_objection(this, "Start DMI test seq");
           `uvm_info("dmi_trans_actv_test", "Starting DMI test sequence",UVM_LOW)
           test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
           `uvm_info("dmi_trans_actv_test", "Finish DMI test sequence",UVM_LOW)
           #20000ns;
           csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
           phase.drop_objection(this, "Finish DMI test seq");
        end

        begin
           `uvm_info("DMI CSR Seq", "Starting to check AllocActv and EvictActv register fields",UVM_LOW)
           forever begin
              @(negedge u_csr_probe_if.clk);
              tmp1_q = {};
              tmp2_q = {};
              tmp1_q = m_env.m_sb.rtt_q.find_index with (!item.sp_txn && !item.isCacheHit && (item.fillExpd || item.fillDataExpd) && (!item.fillSeen || !item.fillDataSeen));
              tmp2_q = m_env.m_sb.wtt_q.find_index with (!item.sp_txn && !item.isCacheHit && (item.fillExpd || item.fillDataExpd) && (!item.fillSeen || !item.fillDataSeen));
              expd_AllocActv = ((tmp1_q.size() + tmp2_q.size()) > 0);

              tmp2_q = {};
              tmp2_q = m_env.m_sb.wtt_q.find_index with (item.isEvict && item.evictDataExpd && item.AXI_write_addr_expd);
              expd_EvictActv = (tmp2_q.size() > 0);

              recd_AllocActv = u_csr_probe_if.AllocActv;
              recd_EvictActv = u_csr_probe_if.EvictActv;

              match1 = expd_AllocActv ^ recd_AllocActv;
              match2 = expd_EvictActv ^ recd_EvictActv;

              if ((match1 !== 0) || (match2 !== 0)) begin
                 `uvm_error("dmi_alloc_evict_actv_test", $sformatf("AllocActv and EvictActv register fields didn't match Expd: AllocActv %0b EvictActv %0b  Recd: AllocActv %0b EvictActv %0b", expd_AllocActv, expd_EvictActv, recd_AllocActv, recd_EvictActv))
              end else begin
                 `uvm_info("dmi_alloc_evict_actv_test", $sformatf("AllocActv and EvictActv register fields matched Expd: AllocActv %0b EvictActv %0b  Recd: AllocActv %0b EvictActv %0b", expd_AllocActv, expd_EvictActv, recd_AllocActv, recd_EvictActv), UVM_HIGH)
              end
           end
        end
     join
  endtask : run_phase
endclass: dmi_alloc_evict_actv_test


//******************************************************************************
// Class   : dmi_csr_flush_per_index_way_test
// Purpose : Performs a MntOps to flush a cacheline using Index/Way.
//
//******************************************************************************

class dmi_csr_flush_per_index_way_test extends dmi_csr_base_test;
  `uvm_component_utils(dmi_csr_flush_per_index_way_test)

  function new(string name = "dmi_csr_flush_per_index_way_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  task run_phase (uvm_phase phase);
      dmi_csr_flush_by_index_way_seq csr_seq = dmi_csr_flush_by_index_way_seq::type_id::create("csr_seq");
      csr_seq.model = m_env.m_regs;
      super.run_phase(phase);

      uvm_config_db#(dmi_scoreboard)::set(uvm_root::get(), 
                                          "*", 
                                          "dmi_scb", 
                                          m_env.m_sb);

      fork 
        begin
           phase.raise_objection(this, "Start DMI flush Index/Way seq");
           `uvm_info("dmi_csr_flush_per_index_way_test", "Starting DMI flush index/way sequence",UVM_LOW)
           csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
           #10000ns;
           `uvm_info("dmi_csr_flush_per_index_way_test", "Finished DMI flush index/way sequence",UVM_LOW)
           phase.drop_objection(this, "Finish DMI flush Index/Way seq");
        end 
        begin
           phase.raise_objection(this, "Start DMI bring up seq");
           `uvm_info("dmi_csr_flush_per_index_way_test", "Starting DMI bring up sequence",UVM_LOW)
           test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
           #10000ns;
           `uvm_info("dmi_csr_flush_per_index_way_test", "Finished DMI bring up sequence",UVM_LOW)
           phase.drop_objection(this, "Finish DMI bring up seq");
        end
      join

  endtask : run_phase
endclass: dmi_csr_flush_per_index_way_test


//******************************************************************************
// Class   : dmi_csr_rand_all_type_flush_test
// Purpose : Performs a MntOps to flush a cacheline using either of Index-Way,
//           Addr, Index-Way range, Addr range randomly.
//
//******************************************************************************

class dmi_csr_rand_all_type_flush_test extends dmi_csr_base_test;
  `uvm_component_utils(dmi_csr_rand_all_type_flush_test)

  function new(string name = "dmi_csr_rand_all_type_flush_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  task run_phase (uvm_phase phase);
      dmi_csr_rand_all_type_flush_seq csr_seq = dmi_csr_rand_all_type_flush_seq::type_id::create("csr_seq");
      csr_seq.model = m_env.m_regs;
      csr_seq.m_apb_sequencer = m_env.m_apb_agent.m_apb_sequencer;

      super.run_phase(phase);

      uvm_config_db#(dmi_scoreboard)::set(uvm_root::get(), 
                                          "*", 
                                          "dmi_scb", 
                                          m_env.m_sb);

      fork 
        begin
           phase.raise_objection(this, "Start DMI rand all types of flush seq");
           `uvm_info("dmi_csr_rand_all_type_flush_test", "Starting DMI rand all types of flush sequence",UVM_LOW)
           csr_seq.start(m_env.m_apb_agent.m_apb_sequencer);
           #10000ns;
           `uvm_info("dmi_csr_rand_all_type_flush_test", "Finished DMI rand all type flush sequence",UVM_LOW)
           phase.drop_objection(this, "Finish DMI flush Index/Way seq");
        end 
        begin
           phase.raise_objection(this, "Start DMI bring up seq");
           `uvm_info("dmi_csr_rand_all_type_flush_test", "Starting DMI bring up sequence",UVM_LOW)
           test_seq.start(m_env.m_smi_agent.m_smi_virtual_seqr);
           #10000ns;
           `uvm_info("dmi_csr_rand_all_type_flush_test", "Finished DMI bring up sequence",UVM_LOW)
           phase.drop_objection(this, "Finish DMI bring up seq");
        end
      join

  endtask : run_phase
endclass: dmi_csr_rand_all_type_flush_test
<%}%> // useCmc
<%}%> // INHOUSE_APB_VIP
