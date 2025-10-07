/**
 * creating separate testcase for resiliency testing. Parameter
 * of class type from which traffic will be generated need to pass.
 * base testcase resiliency_base_test is located in path
 * $WORK_TOP/dv/common/lib_tb/resiliency_base_test.svh
 * #1 UCE transport error tested
 * #2 CE transport error tested
 * #3 unit_duplication tested
 */
`include "resiliency_base_test.svh"
class chi_aiu_resiliency_test extends resiliency_base_test#(chi_aiu_bringup_test);

	`uvm_component_utils(chi_aiu_resiliency_test);

  function new(
    string name = "chi_aiu_resiliency_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction: new

  <% if((obj.useResiliency) && (obj.testBench != "fsys")) { %>
  typedef virtual chi_aiu_csr_probe_if test_res_csr_if;
  test_res_csr_if res_csr_probe_if;

  /**
   *Overriding below sequence items which are used inside
   *the chi_monitor to generate/assign the appropriate 
   *response and then drive. But as they are using $cast
   *as task and not function, so it's giving the failure
   *for casting when forcing responce with the not declared
   *value in enum data type.
   *
   *(1). chi_rsp_seq_item -> chi_rsp_seq_item_extended
   *(2). chi_snp_seq_item -> chi_snp_seq_item_extended
   */

  class chi_rsp_seq_item_extended extends chi_rsp_seq_item;
    `uvm_object_utils(chi_rsp_seq_item_extended)

    //Constructor
    function new(string name = "chi_rsp_seq_item_extended");
        super.new(name);
    endfunction
    virtual function void unpack_flit(const ref packed_flit_t flit);
        if($cast(this.opcode   , flit[0][`CHI_RSP_OPCODE_MSB:`CHI_RSP_OPCODE_LSB]));
        this.resperr        = flit[0][`CHI_RSP_RESPERR_MSB:`CHI_RSP_RESPERR_LSB];
        this.resp           = flit[0][`CHI_RSP_RESP_MSB:`CHI_RSP_RESP_LSB];
        this.dbid           = flit[0][`CHI_RSP_DBID_MSB:`CHI_RSP_DBID_LSB];
        this.pcrdtype       = flit[0][`CHI_RSP_PCRDTYPE_MSB:`CHI_RSP_PCRDTYPE_LSB];
        `uvm_info("CHI_SEQ_ITEM", $psprintf("unpacking response: txnid: %0h, before unpack: %0p", txnid, flit[0]), UVM_HIGH)
    endfunction : unpack_flit
  endclass

  class chi_snp_seq_item_extended extends chi_snp_seq_item;
    `uvm_object_utils(chi_snp_seq_item_extended)

    //Constructor
    function new(string name = "chi_snp_seq_item_extended");
        super.new(name);
    endfunction
    virtual function void unpack_flit(const ref packed_flit_t flit);
        this.qos            = flit[0][`CHI_SNP_QOS_MSB:`CHI_SNP_QOS_LSB];
        this.srcid          = flit[0][`CHI_SNP_SRCID_MSB:`CHI_SNP_SRCID_LSB];
        this.txnid          = flit[0][`CHI_SNP_TXNID_MSB:`CHI_SNP_TXNID_LSB];
        if($cast(this.opcode   , flit[0][`CHI_SNP_OPCODE_MSB:`CHI_SNP_OPCODE_LSB]));
        this.addr           = flit[0][`CHI_SNP_ADDR_MSB:`CHI_SNP_ADDR_LSB];
        this.ns             = flit[0][`CHI_SNP_NS_MSB:`CHI_SNP_NS_LSB];
    endfunction : unpack_flit
  endclass


  local string inst_s = "chi_aiu_resiliency_test";//this.get_name;
  local string func_s = "";
  local string task_s = "";
  local string hook_pre_s = {inst_s,"_"};
  local string hook_pos_s = "";
  local string info_pattern = {{60{"-"}}};
  chiaiu_env m_res_env;
  chiaiu_env_config m_res_env_cfg;

  //*************************************//
  function void build_phase(uvm_phase phase);
    func_s = "build_phase";
    super.build_phase(phase);
    `uvm_info({hook_pre_s,func_s}, $sformatf("Inside %0s of %0s", func_s, inst_s), UVM_DEBUG);
    if(!uvm_config_db#(test_res_csr_if)::get(null, get_full_name(), "u_csr_probe_if", res_csr_probe_if)) begin
      `uvm_fatal({hook_pre_s,func_s}, {"virtual interface must be set for :",get_full_name(),".vif"})
    end
    if(cmdline_args_aa.exists("test_unit_duplication") && is_unit_dup_on) begin
      set_type_override_by_type (.original_type(chi_snp_seq_item::get_type()), .override_type(chi_snp_seq_item_extended::get_type()), .replace(1));
      set_type_override_by_type (.original_type(chi_rsp_seq_item::get_type()), .override_type(chi_rsp_seq_item_extended::get_type()), .replace(1));
      dis_sb();
      err_demoter_h.demote_uvm_fatal = 1;
    end
    if(cmdline_args_aa.exists("test_placeholder_connectivity")) begin
      err_demoter_h.demote_uvm_fatal = 1;
    end
  endfunction : build_phase

  //*************************************//
  function void connect_phase(uvm_phase phase);
    func_s = "connect_phase";
    super.connect_phase(phase);
    `uvm_info({hook_pre_s,func_s}, $sformatf("Inside %0s of %0s", func_s, inst_s), UVM_DEBUG);
  endfunction : connect_phase

  //*************************************//
  virtual task set_corr_err_threshold(string range="rand", int value);
    int min_range, max_range;
    res_corr_err_threshold_seq seq;
    task_s = "set_corr_err_threshold";
    `uvm_info({hook_pre_s,task_s}, $sformatf("Inside %0s of %0s", task_s, inst_s), UVM_DEBUG);
     range = "fix_range";
     min_range = 0;
     max_range = $urandom_range(2,8);
    <% if(obj.INHOUSE_APB_VIP) { %>
      seq = res_corr_err_threshold_seq::type_id::create("seq");
      seq.model = m_env.m_regs;
      seq.set_threshold_range(range);
      seq.set_threshold_range_value(min_range, max_range);
      seq.set_threshold_value(value);
      seq.start(m_env.m_apb_agent.m_apb_sequencer);
      //update exp from sequence for CE
      res_corr_err_threshold_width = seq.get_threshold_width();
      exp_corr_err_threshold = seq.get_threshold_value();
    <% } %>
  endtask

  virtual function int get_dflt_corr_err_threshold_val;
    func_s = "get_dflt_corr_err_threshold_val";
    `uvm_info({hook_pre_s,func_s}, $sformatf("Inside %0s of %0s", func_s, inst_s), UVM_DEBUG);
    return 1;
  endfunction

  virtual function void get_fault_from_vif();
    task_s = "get_fault_from_vif";
    act_mission_fault             = res_csr_probe_if.fault_mission_fault;
    act_latent_fault              = res_csr_probe_if.fault_latent_fault;
    act_corr_err_over_thres_fault = res_csr_probe_if.cerr_over_thres_fault;
    act_corr_err_threshold        = res_csr_probe_if.cerr_threshold;
    act_corr_err_counter          = res_csr_probe_if.cerr_counter;
  endfunction

  virtual task wait4clk(int num_clk=1);
    task_s = "wait4clk";
    repeat(num_clk) @(posedge res_csr_probe_if.clk);
  endtask

  virtual function void set_res_env_var;
    func_s = "set_res_env_var";
    $cast(m_res_env, m_env);
    $cast(m_res_env_cfg, m_env_cfg);
  endfunction

  virtual function bit is_sb_on;
    func_s = "is_sb_on";
    return m_res_env_cfg.has_scoreboard;
  endfunction

  virtual function void dis_sb;
    func_s = "dis_sb";
    m_res_env_cfg.disable_scoreboard();
  endfunction

  virtual function void connect_smi_res_port;
    func_s = "connect_smi_res_port";
    //Calculate based on the jscript numPorts
    <% for(var i=0; i<obj.AiuInfo[obj.Id].smiPortParams.rx.length; i++) {%>
      m_res_env.m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_smi_res_port);
    <%}%>
    <% for(var i=0; i<obj.AiuInfo[obj.Id].smiPortParams.tx.length; i++) {%>
      m_res_env.m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_smi_res_port);
    <%}%>
  endfunction

  <% } %>

endclass: chi_aiu_resiliency_test
/**
 *END
 */
