// base testcase
<% if(obj.useResiliency && (obj.testBench != "fsys")) { %>
  /*
   *demoter class used for the Resiliency feature testing
   *to demote any error occur due to UECC generation
   */
  `include "report_catcher_demoter_base.sv"
  `uvm_analysis_imp_decl(_smi_res_port)
<% } %>

class resiliency_base_test #(type INST=uvm_test) extends INST;

	`uvm_component_param_utils(resiliency_base_test);

  function new(
    string name = "resiliency_base_test",
    uvm_component parent = null
  );
    super.new(name, parent);
  endfunction: new

  <% if((obj.useResiliency) && (obj.testBench != "fsys")) { %>
  local string inst_s = "resiliency_base_test";//this.get_name;
  local string func_s = "";
  local string task_s = "";
  local string hook_pre_s = {inst_s,"_"};//"fault_injector_checker_";
  local string hook_pos_s = "";
  local string info_pattern = {{60{"-"}}};

  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event ev_system_reset_done = ev_pool.get("ev_system_reset_done");
  uvm_event ev_drop_obj_for_resiliency_test = ev_pool.get("ev_drop_obj_for_resiliency_test");
<% if(obj.testBench == 'chi_aiu') { %>
`ifndef VCS
  event raise_obj_for_resiliency_test;
  event drop_obj_for_resiliency_test;
`else // `ifndef VCS
  uvm_event raise_obj_for_resiliency_test;
  uvm_event drop_obj_for_resiliency_test;
`endif // `ifndef VCS
<% } else {%>
  event raise_obj_for_resiliency_test;
  event drop_obj_for_resiliency_test;
<% } %>

  //SMI Analysis Port
  uvm_analysis_imp_smi_res_port #(smi_seq_item, resiliency_base_test#(INST)) m_smi_res_port;

  int cmdline_args_aa[string];
  bit is_skip_super_call;
  bit is_coverage_override;
  bit is_error_demoted;
  bit is_unit_dup_on;
  bit is_msg_field_inj_on;
  bit is_err_prot_on;
  bit is_err_inj_arg_on;
  bit is_err_msg_sel;
  bit exp_ecc_uce_fault;
  bit exp_parity_uce_fault;
  bit exp_mission_fault;
  bit exp_latent_fault;
  bit act_mission_fault;
  bit act_mission_fault_seen;
  bit act_latent_fault;
  bit act_corr_err_over_thres_fault;
  typedef enum bit[1:0] {NONE=0, ECC=1, PARITY=2, UNKNOWN=3} protection_type_e;
  typedef enum bit[2:0] {ECC_CE=1, ECC_UCE=2, PARITY_UCE=4} inj_cntl_type_e;
  protection_type_e prot_e;
  inj_cntl_type_e inj_cntl_e;

  // SMI error injection statistics
  int  num_smi_corr_err   = 0;
  int  num_smi_uncorr_err = 0;
  int  num_smi_parity_err = 0;  // also uncorrectable

  realtime smi_pkt_time_old, smi_pkt_time_new;
  int mod_dp_corr_error, res_corr_err_threshold_width, res_smi_corr_err, mod_res_smi_corr_err, exp_corr_err_threshold;
  int act_corr_err_threshold, act_corr_err_counter;
  bit patch_conc_7033, patch_conc_7597;
  bit res_corr_err_tolerance_cnt = 1;
  bit is_pre_err_pkt;

  event kill_test;
  int smi_if_valid_ready_timeout = $value$plusargs("RDY_NOT_ASSERTED_TIMEOUT=%0d", smi_if_valid_ready_timeout) ? (smi_if_valid_ready_timeout-1000) : 10000;
  bit is_smi_if_VR_timeout;
  uvm_object objectors_list[$];
  uvm_objection objection;

  bit test_done, is_pre_abort_call;
  /**
   *demote handle to suppress any error coming for the resiliency
   *testing. error form the fault_injector_checker will show, but
   *others will be converted to info
   */
  report_catcher_demoter_base err_demoter_h;

  //uvm_phases--
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void start_of_simulation_phase(uvm_phase phase);
  extern virtual task          run_phase(uvm_phase phase);
  extern virtual function void extract_phase(uvm_phase phase);
  extern virtual function void check_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);

  extern virtual function void pre_abort();
  extern virtual task delay_to_end(uvm_phase phase, int delay=1);
  extern virtual function void phase_ready_to_end(uvm_phase phase);

  // helper methods/functions
  extern virtual function void get_arg();
  extern virtual function void set_exp();
  extern virtual function int get_dflt_corr_err_threshold_val();
  extern virtual function void write_smi_res_port(const ref smi_seq_item m_item);

  virtual function void set_res_env_var;
    func_s = "set_res_env_var";
    `uvm_fatal({hook_pre_s,func_s}, $sformatf({"This function(%0s) must be implemented in extended class"}, func_s))
  endfunction

  virtual function bit is_sb_on;
    func_s = "is_sb_on";
    `uvm_fatal({hook_pre_s,func_s}, $sformatf({"This function(%0s) must be implemented in extended class"}, func_s))
  endfunction

  virtual function void connect_smi_res_port;
    func_s = "connect_smi_res_port";
    `uvm_fatal({hook_pre_s,func_s}, $sformatf({"This function(%0s) must be implemented in extended class"}, func_s))
  endfunction

  virtual function void get_fault_from_vif();
    task_s = "get_fault_from_vif";
    `uvm_fatal({hook_pre_s,func_s}, $sformatf({"This task(%0s) must be implemented in extended class"}, task_s))
  endfunction

  virtual task wait4clk(int num_clk=1);
    task_s = "wait4clk";
    `uvm_fatal({hook_pre_s,func_s}, $sformatf({"This task(%0s) must be implemented in extended class"}, task_s))
  endtask

  virtual task set_corr_err_threshold(string range="rand", int value);
    task_s = "set_corr_err_threshold";
    `uvm_fatal({hook_pre_s,func_s}, $sformatf({"This task(%0s) must be implemented in extended class"}, task_s))
  endtask

  <% } else { %>
  //uvm_phases--
  virtual function void build_phase(uvm_phase phase);
  endfunction
  virtual function void connect_phase(uvm_phase phase);
  endfunction
  virtual function void start_of_simulation_phase(uvm_phase phase);
  endfunction
  virtual task run_phase(uvm_phase phase);
  endtask
  virtual function void extract_phase(uvm_phase phase);
  endfunction
  virtual function void check_phase(uvm_phase phase);
  endfunction
  virtual function void report_phase(uvm_phase phase);
    `uvm_info(get_name(), $sformatf("Config don't have Resiliency Enabled(obj.useResiliency = <%= obj.useResiliency %>)"), UVM_NONE);
  endfunction
  <% } %>

endclass: resiliency_base_test

<% if((obj.useResiliency) && (obj.testBench != "fsys")) { %>
//*************************************//
function void resiliency_base_test::get_arg();
  int tmp_val;
  string disp_s, args_str_q[$];
  int args_val_aa[string];

  func_s = "get_arg";
  disp_s = "## TEST_CFG::Args ## Command line arguments are as:";
  args_str_q = {
                 "test_unit_duplication"
                ,"inj_cntl"
                ,"inject_smi_uncorr_error", "inject_smi_corr_error"
                ,"smi_ndp_err_inj", "smi_hdr_err_inj", "smi_dp_ecc_inj", "smi_rand_field_err_inj"
                ,"collect_resiliency_cov"
                ,"res_corr_err_threshold"
                ,"check_corr_err_cnt"
                ,"res_corr_err_tolerance_cnt"
                ,"cmd_req_err_inj", "ccmd_rsp_err_inj", "nccmd_rsp_err_inj", "snp_req_err_inj", "snp_rsp_err_inj", "mrd_req_err_inj", "mrd_rsp_err_inj", "str_req_err_inj", "str_rsp_err_inj", "dtr_req_err_inj", "dtr_rsp_err_inj", "dtw_req_err_inj", "dtwmrg_req_err_inj", "dtw_rsp_err_inj", "dtw_dbg_rsp_err_inj", "upd_req_err_inj", "upd_rsp_err_inj", "rbr_req_err_inj", "rbr_rsp_err_inj", "rbu_req_err_inj", "rbu_rsp_err_inj", "cmp_rsp_err_inj"
                ,"test_placeholder_connectivity"
                ,"corr_error_inj_pcnt"
                ,"uncorr_error_inj_pcnt"
                ,"parity_error_inj_pcnt"
  };

  args_val_aa = { "res_corr_err_threshold" : 1,
                  "res_corr_err_tolerance_cnt" : 1
  };
  $sformat(disp_s,"%0s\n%0s",disp_s, {2{info_pattern}});
  $sformat(disp_s,"%0s\n\t%40s | %0s",disp_s, "Name", "Value");
  $sformat(disp_s,"%0s\n%0s",disp_s, {2{info_pattern}});
  foreach(args_str_q[i]) begin
    if($test$plusargs({args_str_q[i]})) begin
      if($value$plusargs({args_str_q[i],"=%0d"}, tmp_val))
        cmdline_args_aa[args_str_q[i]] = tmp_val;
      else begin
        if(args_val_aa.exists(args_str_q[i]))
          cmdline_args_aa[args_str_q[i]] = args_val_aa[args_str_q[i]];
        else
          cmdline_args_aa[args_str_q[i]] = 'hc0ffee;
      end
      $sformat(disp_s,"%0s\n\t%40s | 0x%0h",disp_s, args_str_q[i], cmdline_args_aa[args_str_q[i]]);
    end
  end
  $sformat(disp_s,"%0s\n%0s",disp_s, {2{info_pattern}});
  `uvm_info({hook_pre_s,func_s}, $sformatf("%0s",disp_s), UVM_NONE);
endfunction : get_arg

function void resiliency_base_test::set_exp();
  string disp_s;
  func_s = "set_exp";
  disp_s = "## TEST_CFG::Exp ## Command line arguments are as:";

  $sformat(disp_s,"%0s\n%0s",disp_s, {2{info_pattern}});
  $sformat(disp_s,"%0s\n\t%40s | %0s",disp_s, "Name", "Status");
  $sformat(disp_s,"%0s\n%0s",disp_s, {2{info_pattern}});
  if(cmdline_args_aa.exists("cmd_req_err_inj")     ||
     cmdline_args_aa.exists("ccmd_rsp_err_inj")    ||
     cmdline_args_aa.exists("nccmd_rsp_err_inj")   ||
     cmdline_args_aa.exists("snp_req_err_inj")     ||
     cmdline_args_aa.exists("snp_rsp_err_inj")     ||
     cmdline_args_aa.exists("mrd_req_err_inj")     ||
     cmdline_args_aa.exists("mrd_rsp_err_inj")     ||
     cmdline_args_aa.exists("str_req_err_inj")     ||
     cmdline_args_aa.exists("str_rsp_err_inj")     ||
     cmdline_args_aa.exists("dtr_req_err_inj")     ||
     cmdline_args_aa.exists("dtr_rsp_err_inj")     ||
     cmdline_args_aa.exists("dtw_req_err_inj")     ||
     cmdline_args_aa.exists("dtwmrg_req_err_inj")  ||
     cmdline_args_aa.exists("dtw_rsp_err_inj")     ||
     cmdline_args_aa.exists("dtw_dbg_rsp_err_inj")     ||
     cmdline_args_aa.exists("upd_req_err_inj")     ||
     cmdline_args_aa.exists("upd_rsp_err_inj")     ||
     cmdline_args_aa.exists("rbr_req_err_inj")     ||
     cmdline_args_aa.exists("rbr_rsp_err_inj")     ||
     cmdline_args_aa.exists("rbu_req_err_inj")     ||
     cmdline_args_aa.exists("rbu_rsp_err_inj")     ||
     cmdline_args_aa.exists("cmp_rsp_err_inj")
    ) begin
    is_err_msg_sel = 1'b1;
  end
  $sformat(disp_s,"%0s\n\t%40s | %0d",disp_s, "is_err_msg_sel?", is_err_msg_sel);

  if(cmdline_args_aa.exists("inj_cntl")) begin
    if(!$cast(inj_cntl_e, cmdline_args_aa["inj_cntl"]))
      `uvm_error({hook_pre_s,func_s}, $sformatf({"Please set valid inj_cntl value(i.e 1,2,4). Observed value=%0d"}, cmdline_args_aa["inj_cntl"]))
    is_err_inj_arg_on = 1'b1;
  end
  if(cmdline_args_aa.exists("inject_smi_corr_error") || cmdline_args_aa.exists("inject_smi_uncorr_error")) begin
    is_err_inj_arg_on = 1'b1;
  end
  $sformat(disp_s,"%0s\n\t%40s | %0d",disp_s, "is_err_inj_arg_on?", is_err_inj_arg_on);

  if(cmdline_args_aa.exists("smi_ndp_err_inj") ||
     cmdline_args_aa.exists("smi_hdr_err_inj") ||
     cmdline_args_aa.exists("smi_dp_ecc_inj")  ||
     cmdline_args_aa.exists("smi_rand_field_err_inj")
  ) begin
    is_msg_field_inj_on = 1'b1;
  end
  $sformat(disp_s,"%0s\n\t%40s | %0d",disp_s, "NDP/DP/HDR fields selected?", is_msg_field_inj_on);

  <% if (AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
    prot_e = ECC;
  <% } else if (AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
    prot_e = PARITY;
  <% } else if (AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "none") { %>
    prot_e = NONE;
  <% } else { %>
    prot_e = UNKNOWN;
  <% } %>
  $sformat(disp_s,"%0s\n\t%40s | %0s",disp_s, "RTL protetction Type", prot_e);

  case(prot_e)
    NONE : begin
      is_err_prot_on = 0;
      is_skip_super_call = 1'b1;
    end
    ECC,
    PARITY : begin
      is_err_prot_on = 1'b1;
    end
    UNKNOWN : begin
      is_skip_super_call = 1'b1;
      is_err_prot_on = 1'b0;
      `uvm_error({hook_pre_s,func_s}, $sformatf("Please check the Json config for protection type. Observed value=%0s",prot_e));
    end
  endcase
  $sformat(disp_s,"%0s\n\t%40s | %0d",disp_s, "RTL protection is on?", is_err_prot_on);

  <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
    is_unit_dup_on = 1'b1;
  <% } %>
  $sformat(disp_s,"%0s\n\t%40s | %0d",disp_s, "RTL unit_duplication on?", is_unit_dup_on);

  if(is_err_prot_on && is_msg_field_inj_on) begin
    case(prot_e)
      UNKNOWN,
      NONE : begin
        exp_ecc_uce_fault = 0;
        exp_parity_uce_fault = 0;
      end
      ECC,
      PARITY : begin
        case(inj_cntl_e)
          ECC_UCE : begin
            exp_ecc_uce_fault = 1'b1;
            exp_parity_uce_fault = 1'b0;
          end
          ECC_CE : begin
            exp_ecc_uce_fault = 1'b0;
            exp_parity_uce_fault = 1'b0;
          end
          PARITY_UCE : begin
            exp_ecc_uce_fault = 1'b0;
            exp_parity_uce_fault = 1'b1;
          end
          default : begin
            if(is_err_inj_arg_on) begin
              if(cmdline_args_aa.exists("inject_smi_uncorr_error")) begin
                case(prot_e)
                  ECC : begin
                    exp_ecc_uce_fault = 1'b1;
                  end
                  PARITY : begin
                    exp_parity_uce_fault = 1'b1;
                  end
                  default : begin
                    {exp_ecc_uce_fault, exp_parity_uce_fault} = '0;
                    `uvm_warning({hook_pre_s,func_s}, $sformatf("DBG-0: Setting exp_(ecc/parity)_uce_fault to default 0"));
                  end
                endcase
              end else if(cmdline_args_aa.exists("inject_smi_corr_error")) begin
                {exp_ecc_uce_fault, exp_parity_uce_fault} = '0;
                `uvm_info({hook_pre_s,func_s}, $sformatf("DBG-1: Setting exp_(ecc/parity)_uce_fault to default 0"), UVM_DEBUG);
              end else begin
                {exp_ecc_uce_fault, exp_parity_uce_fault} = '0;
                `uvm_warning({hook_pre_s,func_s}, $sformatf("DBG-2: Setting exp_(ecc/parity)_uce_fault to default 0"));
              end
            end else begin
              {exp_ecc_uce_fault, exp_parity_uce_fault} = '0;
              `uvm_warning({hook_pre_s,func_s}, $sformatf("DBG-3: Setting exp_(ecc/parity)_uce_fault to default 0"));
            end
          end
        endcase
      end
      default : begin
        {exp_ecc_uce_fault, exp_parity_uce_fault} = '0;
        `uvm_warning({hook_pre_s,func_s}, $sformatf("DBG-4: Setting exp_ecc/parity_fault to default 0"));
      end
    endcase
  end else begin
    {exp_ecc_uce_fault, exp_parity_uce_fault} = '0;
    `uvm_info({hook_pre_s,func_s}, $sformatf("DBG-5: Setting exp_ecc/parity_fault to default 0"), UVM_DEBUG);
  end
  $sformat(disp_s,"%0s\n\t%40s | %0d",disp_s, "exp_ecc_uce_fault", exp_ecc_uce_fault);
  $sformat(disp_s,"%0s\n\t%40s | %0d",disp_s, "exp_parity_uce_fault", exp_parity_uce_fault);

  if(exp_ecc_uce_fault || exp_parity_uce_fault) begin
    exp_mission_fault = 1'b1;
  end
  if(cmdline_args_aa.exists("test_unit_duplication")) begin
    // we have set it explicitely high in the end from
    // file: $WORK_TOP/dv/common/lib_tb/fault_injector_checker.sv
    if(is_unit_dup_on) begin
      exp_mission_fault = 1'b1;
      exp_latent_fault = 1'b1;
    end
    is_skip_super_call = 1;
  end
  $sformat(disp_s,"%0s\n\t%40s | %0d",disp_s, "exp_mission_fault", exp_mission_fault);

  if(cmdline_args_aa.exists("test_unit_duplication") || cmdline_args_aa.exists("test_placeholder_connectivity")) begin
    is_error_demoted = 1'b1;
  end
  $sformat(disp_s,"%0s\n\t%40s | %0d",disp_s, "TB is_error_demoted", is_error_demoted);
  $sformat(disp_s,"%0s\n\t%40s | %0d",disp_s, "TB is_skip_super_call?", is_skip_super_call);

  if(cmdline_args_aa.exists("collect_resiliency_cov")) begin
    is_coverage_override = 1'b1;
  end
  $sformat(disp_s,"%0s\n\t%40s | %0d",disp_s, "Resiliency Cov collected by override", is_coverage_override);

  $sformat(disp_s,"%0s\n%0s",disp_s, {2{info_pattern}});
  `uvm_info({hook_pre_s,func_s}, $sformatf("%0s",disp_s), UVM_NONE);
endfunction : set_exp

//*************************************//
function void resiliency_base_test::write_smi_res_port(const ref smi_seq_item m_item);
  int tmp_dp_corr_error;
  func_s = "write_smi_res_port";

  //-----------START: count corractable error-----------//
  `uvm_info({hook_pre_s,func_s}, $sformatf("time1 new=%0t, old=%0t", smi_pkt_time_new, smi_pkt_time_old), UVM_DEBUG);
  smi_pkt_time_new = $realtime;
  if(smi_pkt_time_new != smi_pkt_time_old) begin
    // get error statistics
    if(m_item.ndp_corr_error || m_item.hdr_corr_error || m_item.dp_corr_error_eb) begin
      res_smi_corr_err++;
      if(m_item.dp_corr_error_eb) begin
        res_smi_corr_err = res_smi_corr_err + (m_item.dp_corr_error_eb-1);
        mod_dp_corr_error = m_item.dp_corr_error_eb;
        `uvm_info({hook_pre_s,func_s}, $sformatf("(if/if)tmp_dp_corr_error=%0d, this.mod_dp_corr_error=%0d", tmp_dp_corr_error, this.mod_dp_corr_error), UVM_DEBUG);
      end
      is_pre_err_pkt = 1'b1;
      `uvm_info({hook_pre_s,func_s}, $sformatf("new smi_pkt(if). res_smi_corr_err=%0d, is_pre_err_pkt=%0d", res_smi_corr_err, is_pre_err_pkt), UVM_DEBUG);
    end else begin
      is_pre_err_pkt = 1'b0;
    end
    `uvm_info({hook_pre_s,func_s}, $sformatf("time2 new=%0t, old=%0t", smi_pkt_time_new, smi_pkt_time_old), UVM_DEBUG);
  end else begin
    if(is_pre_err_pkt) begin
      if(m_item.dp_corr_error_eb) begin
        tmp_dp_corr_error = m_item.dp_corr_error_eb - this.mod_dp_corr_error;
        if(tmp_dp_corr_error < 0)
          tmp_dp_corr_error = 1'b0;
        else
          this.mod_dp_corr_error = this.mod_dp_corr_error + tmp_dp_corr_error;
        `uvm_info({hook_pre_s,func_s}, $sformatf("(else/if)tmp_dp_corr_error=%0d, this.mod_dp_corr_error=%0d", tmp_dp_corr_error, this.mod_dp_corr_error), UVM_DEBUG);
        res_smi_corr_err = res_smi_corr_err + tmp_dp_corr_error;
      end
      `uvm_info({hook_pre_s,func_s}, $sformatf("new smi_pkt(else/if). res_smi_corr_err=%0d, is_pre_err_pkt=%0d", res_smi_corr_err, is_pre_err_pkt), UVM_DEBUG);
    end else begin
      if(m_item.ndp_corr_error || m_item.hdr_corr_error || m_item.dp_corr_error_eb) begin
        res_smi_corr_err++;
        if(m_item.dp_corr_error_eb) begin
          res_smi_corr_err = res_smi_corr_err + (m_item.dp_corr_error_eb-1);
          mod_dp_corr_error = m_item.dp_corr_error_eb;
          `uvm_info({hook_pre_s,func_s}, $sformatf("(else/else)tmp_dp_corr_error=%0d, this.mod_dp_corr_error=%0d", tmp_dp_corr_error, this.mod_dp_corr_error), UVM_DEBUG);
        end
        is_pre_err_pkt = 1'b1;
      end
      `uvm_info({hook_pre_s,func_s}, $sformatf("new smi_pkt(else/else). res_smi_corr_err=%0d, is_pre_err_pkt=%0d", res_smi_corr_err, is_pre_err_pkt), UVM_DEBUG);
    end
    `uvm_info({hook_pre_s,func_s}, $sformatf("time3 new=%0t, old=%0t", smi_pkt_time_new, smi_pkt_time_old), UVM_DEBUG);
  end
  smi_pkt_time_old = smi_pkt_time_new;
  `uvm_info({hook_pre_s,func_s}, $sformatf("time4 new=%0t, old=%0t", smi_pkt_time_new, smi_pkt_time_old), UVM_DEBUG);
  //-----------END: count corractable error-----------//

  num_smi_corr_err      += m_item.ndp_corr_error + m_item.hdr_corr_error + m_item.dp_corr_error;
  num_smi_uncorr_err    += m_item.ndp_uncorr_error + m_item.hdr_uncorr_error + m_item.dp_uncorr_error;
  num_smi_parity_err    += m_item.ndp_parity_error + m_item.hdr_parity_error + m_item.dp_parity_error;
endfunction : write_smi_res_port

//*************************************//
function void resiliency_base_test::build_phase(uvm_phase phase);
  func_s = "build_phase";
  super.build_phase(phase);

  `uvm_info({hook_pre_s,func_s}, $sformatf("Inside %0s of %0s", func_s, inst_s), UVM_LOW);
  set_res_env_var;
  get_arg();
  set_exp();
  m_smi_res_port = new("m_smi_res_port", this);

  if(cmdline_args_aa.exists("test_unit_duplication") && is_unit_dup_on) begin
<% if(obj.testBench == 'chi_aiu') { %>
`ifndef VCS
    if(!uvm_config_db#(event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error({hook_pre_s,task_s}, $sformatf({"Event raise_obj_for_resiliency_test not found"}))
    end

    if(!uvm_config_db#(event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error({hook_pre_s,task_s}, $sformatf({"Event drope_obj_for_resiliency_test not found"}))
    end
`else // `ifndef VCS
    if(!uvm_config_db#(uvm_event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error({hook_pre_s,task_s}, $sformatf({"Event raise_obj_for_resiliency_test not found"}))
    end

    if(!uvm_config_db#(uvm_event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error({hook_pre_s,task_s}, $sformatf({"Event drope_obj_for_resiliency_test not found"}))
    end
`endif // `ifndef VCS
<% } else {%>
    if(!uvm_config_db#(event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error({hook_pre_s,task_s}, $sformatf({"Event raise_obj_for_resiliency_test not found"}))
    end

    if(!uvm_config_db#(event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error({hook_pre_s,task_s}, $sformatf({"Event drope_obj_for_resiliency_test not found"}))
    end
<% } %>
  end

  if(is_error_demoted) begin
    err_demoter_h        = report_catcher_demoter_base::type_id::create("err_demoter_h");
    err_demoter_h.exp_id = {"fault_injector_checker", hook_pre_s};
    if(cmdline_args_aa.exists("test_placeholder_connectivity")) begin
      err_demoter_h.exp_id.push_back("placeholder_connectivity_checker");
    end
    err_demoter_h.not_of = 1;
    err_demoter_h.build();
    `uvm_info({hook_pre_s,func_s}, $sformatf("Registering demoter class{%0s} for resiliency error ignore", err_demoter_h.get_name()), UVM_LOW)
    uvm_report_cb::add(null, err_demoter_h);
  end

  if(is_coverage_override) begin
<% if(obj.testBench == 'chi_aiu') { %>
//`ifndef VCS
//    `uvm_info({hook_pre_s,func_s}, $sformatf("Overriding smi_coverage class{%0s} for resiliency with coverage class {%0s}", <%=obj.BlockId%>_smi_agent_pkg::smi_coverage::get_type_name(), <%=obj.BlockId%>_smi_agent_pkg::smi_resiliency_coverage::get_type_name()), UVM_LOW)
//`else // `ifndef VCS
//    begin
    <%=obj.BlockId%>_smi_agent_pkg::smi_coverage smi_coverage_tmp;
    <%=obj.BlockId%>_smi_agent_pkg::smi_resiliency_coverage smi_resiliency_coverage_tmp; 
    string smi_cov;
    string smi_resiliency_cov;
    smi_coverage_tmp=new();
    smi_resiliency_coverage_tmp=new();
    smi_cov=smi_coverage_tmp.get_type_name();
    smi_resiliency_cov=smi_resiliency_coverage_tmp.get_type_name();
    `uvm_info({hook_pre_s,func_s}, $sformatf("Overriding smi_coverage class{%0s} for resiliency with coverage class {%0s}", smi_cov, smi_resiliency_cov), UVM_LOW)
//    end
//`endif // `ifndef VCS
<% } else {%>
    `uvm_info({hook_pre_s,func_s}, $sformatf("Overriding smi_coverage class{%0s} for resiliency with coverage class {%0s}", <%=obj.BlockId%>_smi_agent_pkg::smi_coverage::get_type_name(), <%=obj.BlockId%>_smi_agent_pkg::smi_resiliency_coverage::get_type_name()), UVM_LOW)
<% } %>
    set_type_override_by_type(.original_type(<%=obj.BlockId%>_smi_agent_pkg::smi_coverage::get_type()), .override_type(<%=obj.BlockId%>_smi_agent_pkg::smi_resiliency_coverage::get_type()), .replace(1));
  end

endfunction:build_phase

//*************************************//
function void resiliency_base_test::connect_phase(uvm_phase phase);
  func_s = "connect_phase";
  super.connect_phase(phase);
  `uvm_info({hook_pre_s,func_s}, $sformatf("Inside %0s of %0s", func_s, inst_s), UVM_LOW);
  if(is_sb_on) begin
    connect_smi_res_port;
  end else begin
    if(cmdline_args_aa.exists("test_unit_duplication") && is_unit_dup_on) begin
      `uvm_info({hook_pre_s,task_s}, $sformatf("Scoreboard isn't ON"), UVM_NONE);
    end else begin
      `uvm_fatal({hook_pre_s,task_s}, $sformatf("Scoreboard isn't ON"));
    end
  end
endfunction : connect_phase

//*************************************//
function void resiliency_base_test::start_of_simulation_phase(uvm_phase phase);
  func_s = "start_of_simulation_phase";
  if(!is_skip_super_call) begin
    `uvm_info({hook_pre_s,func_s}, $sformatf({"Calling super.start_of_simulation_phase()"}), UVM_LOW)
    super.start_of_simulation_phase(phase);
  end
  `uvm_info({hook_pre_s,func_s}, $sformatf("Inside %0s of %0s", func_s, inst_s), UVM_LOW);
endfunction:start_of_simulation_phase

//*************************************//
task resiliency_base_test::run_phase(uvm_phase phase);
  task_s = "run_phase";
  `uvm_info({hook_pre_s,task_s}, $sformatf("Inside %0s of %0s", task_s, inst_s), UVM_LOW);
  phase.raise_objection(this, "<%=obj.BlockId%>_resiliency_base_test");
  phase.phase_done.set_drain_time(this, 50us);

  begin : th_ce
    string range;
    int value;
    exp_corr_err_threshold = get_dflt_corr_err_threshold_val();
    if(cmdline_args_aa.exists("res_corr_err_threshold")) begin
      range = "fix";
      value = cmdline_args_aa["res_corr_err_threshold"];
    end else begin
      randcase
        'd4 : begin
          range = "rand";
        end
        'd1 : begin
          range = "min";
        end
        'd1 : begin
          range = "max";
        end
      endcase
    end
    `uvm_info({hook_pre_s,func_s}, $sformatf({"Setting for corr_err_threshold_csr as, range=%0s, value=%0d"}, range, value), UVM_DEBUG)
    set_corr_err_threshold(range, value);
  end
  fork
    begin
      forever begin
        wait4clk;
        get_fault_from_vif();
      end
    end
    begin
	ev_system_reset_done.wait_ptrigger();
        exp_mission_fault = 1'b0;
        exp_latent_fault = 1'b0;
	exp_corr_err_threshold = 1;
    end
    begin : th_run_phase
      if(!is_skip_super_call) begin
        `uvm_info({hook_pre_s,func_s}, $sformatf({"Calling super.run_phase()"}), UVM_LOW)
        super.run_phase(phase);
      end
    end
    begin : th_uce
      if(!cmdline_args_aa.exists("test_unit_duplication") && exp_mission_fault) begin
        forever begin
          #(100*1ns);
          if(act_mission_fault == 0) begin
            phase.raise_objection(this, "<%=obj.BlockId%>_resiliency_base_test");
            `uvm_info({hook_pre_s,task_s}, $sformatf({"<%=obj.BlockId%> Raised_objection::UCE"}), UVM_DEBUG);
            @act_mission_fault;
	    act_mission_fault_seen = 1;
            `uvm_info({hook_pre_s,task_s}, $sformatf("<%=obj.BlockId%> DUT saw mission fault"), UVM_NONE)
            phase.drop_objection(this, "<%=obj.BlockId%>_resiliency_base_test");
            `uvm_info({hook_pre_s,task_s}, $sformatf({"<%=obj.BlockId%> Dropped_objection::UCE"}), UVM_DEBUG);
            `uvm_info({hook_pre_s,task_s}, $sformatf("Kill test after %0d number of clocks", smi_if_valid_ready_timeout), UVM_NONE)
            wait4clk(smi_if_valid_ready_timeout);
            -> kill_test; // otherwise the test will hang and timeout
            `uvm_info({hook_pre_s,task_s}, $sformatf("Jumping to report_phase"), UVM_NONE)
            phase.jump(uvm_report_phase::get());
          end
        end
      end else begin
        //Duplication
        /**
         *creating a stand alone testcase as testing for the features
         *related to unit duplication is done using force mechanism.
         */
        if(cmdline_args_aa.exists("test_unit_duplication") && is_unit_dup_on) begin
          phase.raise_objection(this, {"test_unit_duplication"});
          `uvm_info({hook_pre_s,task_s}, $sformatf({"Waiting for drope_obj_for_resiliency_test event to trigger"}), UVM_LOW)
        <% if(obj.testBench == 'chi_aiu') { %>
	  ev_drop_obj_for_resiliency_test.wait_ptrigger();
        <% } else {%>
          @drop_obj_for_resiliency_test;
        <% } %>
	
          `uvm_info({hook_pre_s,task_s}, $sformatf({"Event drope_obj_for_resiliency_test triggered"}), UVM_LOW)
          phase.drop_objection(this, {"test_unit_duplication"});
        <% if(obj.testBench == 'chi_aiu') { %>
	uvm_root::get().set_report_id_verbosity_hier("UVM/REPORT/CATCHER", UVM_LOW);
    	uvm_root::get().set_report_id_verbosity_hier("UVM/REPORT/SERVER", UVM_LOW);
        <% } %>
        end
      end
    end
    begin : th_kill_test
      `uvm_info({hook_pre_s,task_s}, "<%=obj.BlockId%> waiting for kill_test event to trigger", UVM_NONE)
      @kill_test;
      `uvm_info({hook_pre_s,task_s}, "<%=obj.BlockId%> kill_test event triggered", UVM_NONE)
      objection = phase.get_objection(); // Fetching the objection from current phase
      objection.get_objectors(objectors_list); // Collecting all the objectors which currently have objections raised
      foreach(objectors_list[i]) begin // Dropping the objections forcefully
        uvm_report_info({hook_pre_s,task_s}, $sformatf("objection count %d", objection.get_objection_count(objectors_list[i])), UVM_MEDIUM);
        while(objection.get_objection_count(objectors_list[i]) != 0) begin
          phase.drop_objection(objectors_list[i], "dropping objections to kill the test");
        end
      end
    end
  join_none

  //ideal time for asserting test_done;
  #10us; // waiting for above fork_join_none to start
  phase.drop_objection(this, "<%=obj.BlockId%>_resiliency_base_test");
  test_done = 1;
  `uvm_info({hook_pre_s,func_s}, $sformatf({"Finished run_phase()"}), UVM_LOW)

endtask: run_phase

//*************************************//
task resiliency_base_test::delay_to_end(uvm_phase phase, int delay=1);
    #delay;
    `uvm_info(get_name(),$sformatf("Now to end %s...",phase.get_name()),UVM_DEBUG)
    phase.drop_objection(this);
endtask

function void resiliency_base_test::phase_ready_to_end(uvm_phase phase);
    if(phase.get_name == "run")begin
      if(!test_done) begin
        `uvm_info(get_name(),"Not yet to end...",UVM_DEBUG)
        phase.raise_objection(this);
        fork
            begin
                #1;
                this.delay_to_end(phase, 10);
            end
        join_none
      end
    end
endfunction

//*************************************//
function void resiliency_base_test::report_phase(uvm_phase phase);
  bit err_flag;
  string disp_s;
  int tolerance_range_low_val, tolerance_range_high_val;
  real chk_num;
  func_s = "report_phase";
  disp_s = "## TEST_CFG::Checks ## Checking expectated values as,";
  $sformat(disp_s,"%0s\n%0s",disp_s, {2{info_pattern}});
  $sformat(disp_s,"%0s\n\t| %5s | %40s | %20s | %20s | %10s |",disp_s, "Sr.No", "Name", "Expected Value", "Actual Value", "Err_Flag");
  $sformat(disp_s,"%0s\n%0s",disp_s, {2{info_pattern}});
  get_fault_from_vif;

  //#1 UCE
  chk_num = 1.1; //check mission_fault
  if(act_mission_fault_seen !== exp_mission_fault) err_flag = 1'b1;
  $sformat(disp_s,"%0s\n\t| %2.3f | %40s | %20d | %20d | %10d |",disp_s, chk_num, "UCE:: Mission Fault", exp_mission_fault, act_mission_fault_seen, err_flag);

  chk_num = 1.2; //check latent_fault
  if(act_latent_fault !== exp_latent_fault) err_flag = 1'b1;
  $sformat(disp_s,"%0s\n\t| %2.3f | %40s | %20d | %20d | %10d |",disp_s, chk_num, "UCE:: Latent Fault", exp_latent_fault, act_latent_fault, err_flag);

  //#2 CE
  chk_num = 2.1; //check TB/RTL error count
  res_corr_err_threshold_width++; //counter value incremented by 1
  if(res_smi_corr_err > exp_corr_err_threshold) begin
    mod_res_smi_corr_err = exp_corr_err_threshold + 1;
    `uvm_info({hook_pre_s,func_s}, $sformatf({"Resiliency count reached to (threshold+1). corr_cnt=%0d"}, mod_res_smi_corr_err), UVM_LOW)
    patch_conc_7597 = 0;
  end else begin
    patch_conc_7597 = 1;
    mod_res_smi_corr_err = res_smi_corr_err;
  end
  if(cmdline_args_aa.exists("check_corr_err_cnt")) begin
    patch_conc_7033 = 1; // TODO: disabled if CONC-7033 decides to stop counter at threshold+1
    if(!patch_conc_7597) res_corr_err_tolerance_cnt = 0; // already hit threshold so no tolerance required
    tolerance_range_low_val = mod_res_smi_corr_err-res_corr_err_tolerance_cnt;
    tolerance_range_high_val = mod_res_smi_corr_err+res_corr_err_tolerance_cnt + patch_conc_7033;
    `uvm_info({hook_pre_s,func_s}, $sformatf({"tolerance_range=[%0d:%0d]"}, tolerance_range_low_val, tolerance_range_high_val), UVM_DEBUG)
    if(!(act_corr_err_counter inside {[tolerance_range_low_val : tolerance_range_high_val]})) err_flag = 1'b1;
    $sformat(disp_s,"%0s\n\t| %2.3f | %40s | %20d | %20d | %10d |",disp_s, chk_num, "CE:: counter value", mod_res_smi_corr_err, act_corr_err_counter, err_flag);
  end
  else begin
    $sformat(disp_s,"%0s\n\t| %2.3f | %40s | %20d | %20d | %10s |",disp_s, chk_num, "CE:: counter value", mod_res_smi_corr_err, act_corr_err_counter, "skipped");
  end

  chk_num = 2.2; //check if ce_fault gets trigger or not once counter cross threshold limit
  if(act_corr_err_counter > act_corr_err_threshold) begin
    if(act_corr_err_over_thres_fault !== 1) err_flag = 1'b1;
    $sformat(disp_s,"%0s\n\t| %2.3f | %40s | %20d | %20d | %10d |",disp_s, chk_num, "CE:: Fault", 1'b1, act_corr_err_over_thres_fault, err_flag);
  end else begin
    if(act_corr_err_over_thres_fault === 1) err_flag = 1'b1;
    $sformat(disp_s,"%0s\n\t| %2.3f | %40s | %20d | %20d | %10d |",disp_s, chk_num, "CE:: Fault", 1'b0, act_corr_err_over_thres_fault, err_flag);
  end

  chk_num = 2.3; //check if csr for threshold holds correct set value from TB or not
  if(act_corr_err_threshold !== exp_corr_err_threshold) err_flag = 1'b1;
  $sformat(disp_s,"%0s\n\t| %2.3f | %40s | %20d | %20d | %10d |",disp_s, chk_num, "CE:: CSR threshold", exp_corr_err_threshold, act_corr_err_threshold, err_flag);

  $sformat(disp_s,"%0s\n%0s",disp_s, {2{info_pattern}});
  if(err_flag)
    if(is_pre_abort_call)
      `uvm_warning({hook_pre_s,func_s}, $sformatf({"Resiliency FAIL :: %0s"}, disp_s))
    else
      `uvm_error({hook_pre_s,func_s}, $sformatf({"Resiliency FAIL :: %0s"}, disp_s))
  else
    `uvm_info({hook_pre_s,func_s}, $sformatf({"Resiliency PASS :: %0s"}, disp_s), UVM_NONE)

  if(!is_skip_super_call) begin
    `uvm_info({hook_pre_s,func_s}, $sformatf({"Calling super.report_phase()"}), UVM_LOW)
    super.report_phase(phase);
  end
endfunction: report_phase

function int resiliency_base_test::get_dflt_corr_err_threshold_val();
  func_s = "get_dflt_corr_err_threshold_val";
  return 1;
endfunction

function void resiliency_base_test::extract_phase(uvm_phase phase);
  func_s = "extract_phase";
  if(!is_skip_super_call) begin
    `uvm_info({hook_pre_s,func_s}, $sformatf({"Calling super.extract_phase()"}), UVM_LOW)
    super.extract_phase(phase);
  end
endfunction

function void resiliency_base_test::check_phase(uvm_phase phase);
  func_s = "check_phase";
  if(!is_skip_super_call) begin
    `uvm_info({hook_pre_s,func_s}, $sformatf({"Calling super.check_phase()"}), UVM_LOW)
    super.check_phase(phase);
  end
endfunction

function void resiliency_base_test::pre_abort();
  func_s = "pre_abort";
  is_pre_abort_call = 1;
  super.pre_abort();
endfunction : pre_abort

<% } %>
