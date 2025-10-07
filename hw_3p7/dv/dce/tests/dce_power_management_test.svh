////////////////////////////////////////////////////////////////////////////////
//
// DCE Power Management Test
//
////////////////////////////////////////////////////////////////////////////////
<% var has_ocp = 0 
  if (obj.BLK_SNPS_OCP_VIP) { 
    has_ocp = 1
  } 
  if (obj.INHOUSE_OCP_VIP) { 
    has_ocp = 1
  } 
%>
class dce_power_management_test extends dce_test_base;

   `uvm_component_utils(dce_power_management_test)
   dce_seq  test_seq;
   extern function new(string name = "dce_power_management_test", uvm_component parent = null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern virtual task run_main(uvm_phase phase);
   extern virtual task init_regs();
   extern virtual task generate_traffic();

endclass: dce_power_management_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_power_management_test::new(string name = "dce_power_management_test", uvm_component parent = null);
   super.new(name, parent);
  regs = new();
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_power_management_test::build_phase(uvm_phase phase);
   super.build_phase(phase);
endfunction : build_phase

task dce_power_management_test::init_regs();

<% if (has_ocp) { %>
    wr_data = '0;
    wr_data[3:0] = 4'h0; //Opcode=Init All Entries
    wr_data[20:16] = 5'h0; //Snoop Filter Identifier
    reg_write("DCEUSFMCR_SfMntOp", wr_data);
    reg_wait_for_value(32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
    wr_data = '0;
    wr_data[3:0] = 4'h0; //Opcode=Init All Entries
    wr_data[20:16] = 5'h1; //Snoop Filter Identifier
    reg_write("DCEUSFMCR_SfMntOp", wr_data);
    reg_wait_for_value(32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
    wr_data = '1;
    reg_write("DCEUSFER_SfEn", wr_data);
    reg_write("DCEUCASER_CaSnpEn", wr_data, 0);
    reg_write("DCEUCASER_CaSnpEn", wr_data, 1);
    reg_write("DCEUCASER_CaSnpEn", wr_data, 2);
    reg_write("DCEUCASER_CaSnpEn", wr_data, 3);
    reg_write("DCEUMRHER_MrHntEn", wr_data);
    reg_write("DCEUCECR_ErrDetEn", wr_data);
    reg_write("DCEUCECR_ErrIntEn", wr_data);
    reg_write("DCEUUECR_ErrDetEn", wr_data);
    reg_write("DCEUUECR_ErrIntEn", wr_data);
    reg_write("CSADSER_DvmSnpEn", wr_data, 0);
    reg_write("CSADSER_DvmSnpEn", wr_data, 1);
    reg_write("CSADSER_DvmSnpEn", wr_data, 2);
    reg_write("CSADSER_DvmSnpEn", wr_data, 3);
<% } %>

endtask : init_regs

//------------------------------------------------------------------------------
// Generate coherent traffic
//------------------------------------------------------------------------------
task dce_power_management_test::generate_traffic();
   test_seq = dce_seq::type_id::create("test_seq");   
   test_seq.m_csm = m_env.m_sb.m_csm;
   test_seq.m_gen = m_env.m_gen;
   test_seq.m_dirm_mgr = m_env.m_dirm_mgr;

   test_seq.wt_cmd_rd_cpy             = 3;
   test_seq.wt_cmd_rd_cln             = 20;
   test_seq.wt_cmd_rd_vld             = 20;
   test_seq.wt_cmd_rd_unq             = 15;
   test_seq.wt_cmd_cln_unq            = 15;
   test_seq.wt_cmd_cln_vld            = 3;
   test_seq.wt_cmd_cln_inv            = 3;
   test_seq.wt_cmd_wr_unq_ptl         = 3;
   test_seq.wt_cmd_wr_unq_full        = 3;
   test_seq.wt_cmd_upd_inv            = 5;
   test_seq.wt_cmd_dvm_msg            = 10;
   test_seq.k_num_cmd          = $urandom_range(25000, 50000);
   test_seq.k_num_addr         = get_dirm_entries_cnt();
   

   test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
   test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;
   test_seq.start(null);

  while (m_env.m_sb.m_csm.transactionPending()) begin #1us; end;

endtask // generate_traffic

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------
task dce_power_management_test::run_phase(uvm_phase phase);
   fork
      this.run_main(phase);
      run_watchdog_timer(phase);
   join
endtask : run_phase

task dce_power_management_test::run_main(uvm_phase phase);
   uvm_objection main_done;
   string pm_test_type;
   string arg_value;
   int    rand_value;
   int    aiu_id;
   int    cache_id;
   int    done;
   
   phase.raise_objection(this, "Start dce_power_management_test run phase"); 

   init_regs();
 
   <% if (has_ocp) { %>

  if (clp.get_arg_value("+pm_test_type=", arg_value)) begin
    pm_test_type = arg_value;
  end else begin
    $error("test type not defined!");
  end

  if(pm_test_type == "mr_hnt_en") begin
    wr_data = '0;
    reg_write("DCEUMRHER_MrHntEn", wr_data);
    m_env.m_sb.m_csm.regMrHntEn = '0;
    generate_traffic();

  end else if(pm_test_type == "sf_en") begin
    wr_data = '0;
    reg_write("DCEUSFER_SfEn", wr_data);
    m_env.m_sb.m_csm.SfEnPerAiu = '0;
    m_env.m_sb.m_csm.dce_directory.nullFilterAgents = '1;
    m_env.m_sb.m_csm.dce_directory.c_nullFilterAgents = '1;
    m_env.m_sb.m_csm.dce_directory.eosFilterAgents = '0;
    m_env.m_sb.m_csm.dce_directory.c_eosFilterAgents = '0;
    m_env.m_sb.m_csm.dce_directory.pvFilterAgents = '0;
    m_env.m_sb.m_csm.dce_directory.c_pvFilterAgents = '0;
    generate_traffic();

  end else if(pm_test_type == "ca_snp_en") begin
    wr_data = '0;
    reg_write("DCEUCASER_CaSnpEn", wr_data, 0);
    reg_write("DCEUCASER_CaSnpEn", wr_data, 1);
    reg_write("DCEUCASER_CaSnpEn", wr_data, 2);
    reg_write("DCEUCASER_CaSnpEn", wr_data, 3);
    m_env.m_sb.m_csm.CaSnpEn = '0;
    m_env.m_sb.m_csm.dce_directory.nullFilterAgents = '0;
    m_env.m_sb.m_csm.dce_directory.c_nullFilterAgents = '0;
    m_env.m_sb.m_csm.dce_directory.eosFilterAgents = '0;
    m_env.m_sb.m_csm.dce_directory.c_eosFilterAgents = '0;
    m_env.m_sb.m_csm.dce_directory.pvFilterAgents = '0;
    m_env.m_sb.m_csm.dce_directory.c_pvFilterAgents = '0;
    generate_traffic();

  end else if(pm_test_type == "dvm_snp_en") begin
    wr_data = '0;
    reg_write("CSADSER_DvmSnpEn", wr_data, 0);
    reg_write("CSADSER_DvmSnpEn", wr_data, 1);
    reg_write("CSADSER_DvmSnpEn", wr_data, 2);
    reg_write("CSADSER_DvmSnpEn", wr_data, 3);
    m_env.m_sb.m_csm.DvmSnpEn = '0;
    generate_traffic();

  end else if(pm_test_type == "mr_hnt_en_rand") begin
    rand_value = $urandom_range(<%=obj.DmiInfo.length%>-1, 0);
    wr_data = 1 << rand_value;
    reg_write("DCEUMRHER_MrHntEn", wr_data);
    m_env.m_sb.m_csm.regMrHntEn = wr_data;
    generate_traffic();

  end else if(pm_test_type == "sf_en_rand") begin
    rand_value = 0; //$urandom_range(<%=obj.SnoopFilterInfo.length%>-1, 0);
    for (int f=0; f < <%=obj.SnoopFilterInfo.length%>; f++ ) begin
      foreach (m_env.m_sb.m_csm.dce_directory.idSnoopFilterAgents[f][i]) begin
        if (f == rand_value) begin
          aiu_id = m_env.m_sb.m_csm.dce_directory.idSnoopFilterAgents[f][i];
          cache_id = m_env.m_sb.m_csm.cachingIdArray[aiu_id];
          m_env.m_sb.m_csm.SfEnPerAiu[aiu_id] = 0;
          m_env.m_sb.m_csm.dce_directory.nullFilterAgents[aiu_id] = 1;
          m_env.m_sb.m_csm.dce_directory.eosFilterAgents[aiu_id] = 0;
          m_env.m_sb.m_csm.dce_directory.pvFilterAgents[aiu_id] = 0;
          if (cache_id != -1) begin
            m_env.m_sb.m_csm.dce_directory.c_nullFilterAgents[cache_id] = 1;
            m_env.m_sb.m_csm.dce_directory.c_eosFilterAgents[cache_id] = 0;
            m_env.m_sb.m_csm.dce_directory.c_pvFilterAgents[cache_id] = 0;
          end
          $display("m_env.m_sb.m_csm.dce_directory.nullFilterAgents=%b", m_env.m_sb.m_csm.dce_directory.nullFilterAgents);
          $display("m_env.m_sb.m_csm.dce_directory.eosFilterAgents=%b", m_env.m_sb.m_csm.dce_directory.eosFilterAgents);
          $display("m_env.m_sb.m_csm.dce_directory.pvFilterAgents=%b", m_env.m_sb.m_csm.dce_directory.pvFilterAgents);
          $display("m_env.m_sb.m_csm.dce_directory.c_nullFilterAgents[cache_id=%0d]=%b", cache_id, m_env.m_sb.m_csm.dce_directory.c_nullFilterAgents[cache_id]);
          $display("m_env.m_sb.m_csm.dce_directory.c_eosFilterAgents[cache_id=%0d]=%b", cache_id, m_env.m_sb.m_csm.dce_directory.c_eosFilterAgents[cache_id]);
          $display("m_env.m_sb.m_csm.dce_directory.c_pvFilterAgents[cache_id=%0d]=%b", cache_id, m_env.m_sb.m_csm.dce_directory.c_pvFilterAgents[cache_id]);
        end //if
      end //foreach
    end //for
    wr_data = 2'b11; //1 << rand_value;
    wr_data[rand_value] = 0;
    reg_write("DCEUSFER_SfEn", wr_data);
    generate_traffic();

  end else if(pm_test_type == "ca_snp_en_rand") begin

fork
  begin
    #100us;
    rand_value = $urandom_range(<%=obj.BridgeAiuInfo.length+obj.AiuInfo.length%>-1, 0);
    wr_data = '1;
    if (rand_value < <%=obj.AiuInfo.length%>) begin
      wr_data[rand_value] = 0;
      reg_write("DCEUCASER_CaSnpEn", wr_data, 0);
    end else begin
      wr_data[rand_value-<%=obj.AiuInfo.length%>] = 0;
      reg_write("DCEUCASER_CaSnpEn", wr_data, 3);
    end
    #100us;
  end
  begin
    generate_traffic();
  end
join

  end else if(pm_test_type == "dvm_snp_en_rand") begin

fork
  begin
    #100us;
    repeat (200) begin
      done = 0;
      do begin
        rand_value = $urandom_range(<%=obj.AiuInfo.length%>-1, 0);
        if (m_env.m_sb.m_csm.dvmTargets == 0) begin
          done = 1;
        end else if (m_env.m_sb.m_csm.dvmTargets[rand_value]) begin
          done = 1;
        end
      end while (!done);
      wr_data = '1;
      wr_data[rand_value] = 0;
      reg_write("CSADSER_DvmSnpEn", wr_data, 0);
    end
    #1us;
  end
  begin
    generate_traffic();
  end
join

  end else if(pm_test_type == "recall_all_in_middle") begin

fork
  begin
    #100us;
    wr_data[3:0] = 4'h4; //Opcode=Recall All Entries
    wr_data[20:16] = 5'h0; //Snoop Filter Identifier
    wr_data[21] = 1'h0; //Snoop Filter Security Attribute
    reg_write("DCEUSFMCR_SfMntOp", wr_data); //Recall All Entries SnoopFilter 0
    reg_wait_for_value(32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
    wr_data[20:16] = 5'h1; //Snoop Filter Identifier
    reg_write("DCEUSFMCR_SfMntOp", wr_data); //Recall All Entries SnoopFilter 1
    reg_wait_for_value(32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
    #100us;
  end
  begin
    generate_traffic();
  end
join

  end else if(pm_test_type == "sf_en_in_middle") begin
      int m_sf_id;
      fork
        begin
          #10ns;
          test_seq.mas_seq.wait_until_master_seq_halted();

          `uvm_info("pow test", "Sequence Halted", UVM_MEDIUM)
          //Wait untill all AttIds are processed
          wait_for_dirutar_reg_inactive();
          `uvm_info("pow test", "All active Att transactions are completed", UVM_MEDIUM)

          wr_data = '1;
          m_sf_id = $urandom_range(0, (addrMgrConst::snoop_filters_info.size() -1));
          wr_data[m_sf_id] = 1'b0;
          `uvm_info("pow test", $psprintf("snoop filter about to shut down:%0d wr_data:0x%0h",
              m_sf_id, wr_data), UVM_MEDIUM)
          reg_write("DCEUSFER_SfEn", wr_data);

          `uvm_info(get_full_name(), "resuming sequence", UVM_LOW)
          test_seq.mas_seq.release_master_seq();
        end
        begin
            test_seq = dce_seq::type_id::create("test_seq");   
            test_seq.test_type = "sf_en_in_middle";
            test_seq.m_csm = m_env.m_sb.m_csm;
            test_seq.m_gen = m_env.m_gen;
            test_seq.m_dirm_mgr = m_env.m_dirm_mgr;

            test_seq.wt_cmd_rd_cpy             = 3;
            test_seq.wt_cmd_rd_cln             = 20;
            test_seq.wt_cmd_rd_vld             = 20;
            test_seq.wt_cmd_rd_unq             = 15;
            test_seq.wt_cmd_cln_unq            = 15;
            test_seq.wt_cmd_cln_vld            = 3;
            test_seq.wt_cmd_cln_inv            = 3;
            test_seq.wt_cmd_wr_unq_ptl         = 3;
            test_seq.wt_cmd_wr_unq_full        = 3;
            test_seq.wt_cmd_upd_inv            = 5;
            test_seq.wt_cmd_dvm_msg            = 10;
            test_seq.k_num_cmd          = $urandom_range(5000, 8000);
            test_seq.k_num_addr         = get_dirm_entries_cnt();
            

            test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
            test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;
            test_seq.start(null);
        end
      join


  end else if ($test$plusargs("conc1646")) begin
fork
  begin
        #100us;
        maint_write_addr(48'h0_e307_5f19 >> 6);
        maint_start_op(4'h6, 0);
        reg_wait_for_value(32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
        maint_write_addr(48'h0_e307_5f19 >> 6);
        maint_start_op(4'h6, 1);
        reg_wait_for_value(32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
        #1us;
  end
  begin
    generate_traffic();
  end
join

  end else begin
    $error("test type not found: %s", pm_test_type);		
  end
				  
  main_done = phase.get_objection();
  main_done.set_drain_time(null, 1us);

  phase.drop_objection(this, "Finish dce_power_management_test run phase");
<% }%>   

endtask : run_main

////////////////////////////////////////////////////////////////////////////////

