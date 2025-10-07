////////////////////////////////////////////////////////////////////////////////
//
// DCE Test
//
////////////////////////////////////////////////////////////////////////////////

class dce_test extends dce_test_base;

  `uvm_component_utils(dce_test)

  uvm_analysis_imp_reset_port  #(reset_pkt, dce_test) analysis_reset_port;

  extern function new(string name = "dce_test", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task run_main(uvm_phase phase);
  extern virtual task shutdown_phase(uvm_phase phase);
  extern virtual task power_seq(uvm_phase phase, dce_seq test_seq);
<% for(var pidx = 0; pidx < obj.SnoopFilterInfo.length; pidx++) { %> // every snoop filter
  extern virtual task power_down_snoop_filter_<%=pidx%>(uvm_phase phase);
  extern virtual task power_up_snoop_filter_<%=pidx%>(uvm_phase phase);
<% } %>
<% if (obj.nAIUs > 0) { %>
<% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
  extern virtual task power_down_caiu_<%=pidx%>(uvm_phase phase, dce_seq test_seq);
  extern virtual task power_up_caiu_<%=pidx%>(uvm_phase phase, dce_seq test_seq);
<% } } %>
<% if (obj.nCBIs > 0) { %>
<% for(var pidx = obj.nAIUs; pidx < obj.nAIUs+obj.nCBIs; pidx++) { %>
  extern virtual task power_down_ncbu_<%=pidx%>(uvm_phase phase, dce_seq test_seq);
  extern virtual task power_up_ncbu_<%=pidx%>(uvm_phase phase, dce_seq test_seq);
<% } } %>
  extern virtual function void assign_test_plusargs(ref dce_seq m_seq);
  extern function void write_reset_port(reset_pkt item);

  bit reset_on;
  bit reset_active;

    bit [31:0] wr_data;
    bit [31:0] rd_data;
    bit [31:0] mask_data;
    bit [31:0] r_addr;
    bit [31:0] r_mask;
    string     reg_name;
    int timeout_count;

endclass: dce_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_test::new(string name = "dce_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------
task dce_test::run_phase(uvm_phase phase);
  fork
    run_main(phase);
    run_watchdog_timer(phase);
  join
endtask : run_phase

task dce_test::shutdown_phase(uvm_phase phase);
endtask : shutdown_phase

task dce_test::run_main(uvm_phase phase);
  bit [31:0] diruuesr_err_vld_rd_data;
  bit [31:0] diruuesr_err_type_rd_data;
  int        rand_value;
  uvm_objection main_done;
<% if(obj.INHOUSE_OCP_VIP) { %>
`ifdef MAINTENANCE_OP			     
  dce_maint_seq maint_seq;
`endif			     
<% } %>		       
  dce_seq  test_seq = dce_seq::type_id::create("test_seq");


   
<% if (obj.BLK_SNPS_OCP_VIP) { %>
  csr_wr_seq  wr_seq = csr_wr_seq::type_id::create("wr_seq");
  csr_rd_seq  rd_seq = csr_rd_seq::type_id::create("rd_seq");
<% } %>


  m_env.m_reset_monitor.m_vif.force_values = force_reset_values;   
  test_seq.m_csm = m_env.m_sb.m_csm;
  test_seq.m_gen = m_env.m_gen;
  test_seq.m_dirm_mgr = m_env.m_dirm_mgr;

  //Assign all plusargs
  assign_test_plusargs(test_seq);

  phase.raise_objection(this, "Start dce_test run phase");

<% if (obj.BLK_SNPS_OCP_VIP) { %>
    wr_data = '0;
    wr_data[3:0] = 4'h0; //Opcode=Init All Entries
    wr_data[20:16] = 5'h0; //Snoop Filter Identifier
    reg_write("DCEUSFMCR_SfMntOp", wr_data);
    reg_wait_for_value(rd_seq,32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
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

  fork 
    begin
      test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
      test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;
      test_seq.start(null);
    end
<% if(obj.INHOUSE_OCP_VIP) { %>			     
    begin
      if ($test$plusargs("power_test")) begin
         power_seq(phase, test_seq);
      end
    end
    begin
     `ifdef MAINTENANCE_OP		     
      if ($test$plusargs("random_maint_ops")) begin
        #200us;
        while(!m_env.m_sb.m_csm.transactionPending()) #1us;
        maint_seq = dce_maint_seq::type_id::create("maint_seq");
			     
	//FIXME these take percentages from command line. FIXED for now		       
        maint_seq.wt_maint_recall_all = 50;
//	if(clp.get_arg_value("+wt_maint_recall_all=",arg_value)) begin
//	    maint_seq.wt_maint_recall_all = arg_value.atoi();
//	end
        maint_seq.wt_maint_recall_addrs = 0;
        maint_seq.wt_maint_recall_loc = 50;
        maint_seq.wt_maint_recall_vb = 50;

        maint_seq.m_csm = m_env.m_sb.m_csm;		       
	maint_seq.m_ocp_agent = m_env.m_ocp_agent;		     

        maint_seq.start(null);		       
        #200us;
      end //if
     `endif			     
    end
<% } %>
<% if (obj.BLK_SNPS_OCP_VIP) { %>
    begin
      if ($test$plusargs("recall_error_check")) begin
        #100us;
        reg_read(rd_seq, "DCEUUESR_ErrVld",  diruuesr_err_vld_rd_data);
        reg_read(rd_seq, "DCEUUESR_ErrType", diruuesr_err_type_rd_data);
        if (diruuesr_err_vld_rd_data[0] == 0) begin
          `uvm_error(get_type_name(), $sformatf("DCEUUESR_ErrVld not asserted! rd_data=%0x", diruuesr_err_vld_rd_data))
        end
        reg_read(rd_seq, "DCEUUESR_ErrType", diruuesr_err_type_rd_data);
        if (diruuesr_err_type_rd_data[15:12] != 4'hd) begin
          `uvm_error(get_type_name(), $sformatf("DCEUUESR_ErrType mismatch! rd_data=%0x expected=%0x", diruuesr_err_type_rd_data[15:12], 4'hd))
        end
      end
    end
    begin
      if ($test$plusargs("ca_snp_en_rand_in_middle")) begin
        #100us;
        rand_value = $urandom_range(<%=obj.BridgeAiuInfo.length+obj.AiuInfo.length%>-1, 0);
        wr_data = '1;
        if (rand_value < <%=obj.AiuInfo.length%>) begin
          wr_data[rand_value] = 0;
          reg_write(wr_seq, "DCEUCASER_CaSnpEn", wr_data, 0);
        end else begin
          wr_data[rand_value-<%=obj.AiuInfo.length%>] = 0;
          reg_write(wr_seq, "DCEUCASER_CaSnpEn", wr_data, 3);
        end
        #200us;
      end
    end
<% } %>
  join

  main_done = phase.get_objection();
  main_done.set_drain_time(null, 1us);

<% if (obj.BLK_SNPS_OCP_VIP) { %>

      if($test$plusargs("recall_maint_active_test")) begin

        while (m_env.m_sb.m_csm.transactionPending()) begin #1us; end;
        wr_data[3:0] = 4'h4; //Opcode=Recall All Entries
        wr_data[20:16] = 5'h0; //Snoop Filter Identifier
        wr_data[21] = 1'h0; //Snoop Filter Security Attribute
        reg_write(wr_seq, "DCEUSFMCR_SfMntOp", wr_data); //Recall All Entries SnoopFilter 0
        #1us;
        do begin
          reg_read(rd_seq, "DCEUSFMAR_MntOpAct", rd_data);
          reg_read(rd_seq, "DCEUTAR_TransActv",  wr_data);
          if ((rd_data[0] == 0) && (wr_data[0] == 1))
            `uvm_error(get_type_name(), $sformatf("Maintenance Op Active bit deasserted prematurely! DCEUSFMAR_MntOpAct=%x DCEUTAR_TransActv=%x ", rd_data, wr_data))
        end while (wr_data[0]);

      end

      if ($test$plusargs("recall_error_check")) begin
        #100us;
        reg_read(rd_seq, "DCEUUESR_ErrVld",  diruuesr_err_vld_rd_data);
        reg_read(rd_seq, "DCEUUESR_ErrType", diruuesr_err_type_rd_data);
        if (diruuesr_err_vld_rd_data[0] == 0) begin
          `uvm_error(get_type_name(), $sformatf("DCEUUESR_ErrVld not asserted! rd_data=%0x", diruuesr_err_vld_rd_data))
        end
        reg_read(rd_seq, "DCEUUESR_ErrType", diruuesr_err_type_rd_data);
        if (diruuesr_err_type_rd_data[15:12] != 4'hd) begin
          `uvm_error(get_type_name(), $sformatf("DCEUUESR_ErrType mismatch! rd_data=%0x expected=%0x", diruuesr_err_type_rd_data[15:12], 4'hd))
        end
      end

<% } %>

  if($test$plusargs("reset_testing")) begin
    m_env.m_reset_monitor.m_vif.RESET_CNT_MAX = 500;
    m_env.m_reset_monitor.m_vif.HOLD_CNT_MAX = 5;
    m_env.m_reset_monitor.m_vif.m_inject_rst = 1;
    #100ns;
    test_seq.kill();
    do begin
      #10ns;
    end while (reset_on == 1);
    #1us;
    m_env.m_reset_monitor.m_vif.m_inject_rst = 0;

<% if (obj.BLK_SNPS_OCP_VIP) { %>
    wr_data = '0;
    wr_data[3:0] = 4'h0; //Opcode=Init All Entries
    wr_data[20:16] = 5'h0; //Snoop Filter Identifier
    reg_write(wr_seq, "DCEUSFMCR_SfMntOp", wr_data);
    reg_wait_for_value(rd_seq,32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
    wr_data = '0;
    wr_data[3:0] = 4'h0; //Opcode=Init All Entries
    wr_data[20:16] = 5'h1; //Snoop Filter Identifier
    reg_write(wr_seq, "DCEUSFMCR_SfMntOp", wr_data);
    reg_wait_for_value(rd_seq,32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
    wr_data = '1;
    reg_write(wr_seq, "DCEUSFER_SfEn", wr_data);
    reg_write(wr_seq, "DCEUCASER_CaSnpEn", wr_data);
    reg_write(wr_seq, "DCEUMRHER_MrHntEn", wr_data);
    reg_write(wr_seq, "DCEUCECR_ErrDetEn", wr_data);
    reg_write(wr_seq, "DCEUCECR_ErrIntEn", wr_data);
    reg_write(wr_seq, "DCEUUECR_ErrDetEn", wr_data);
    reg_write(wr_seq, "DCEUUECR_ErrIntEn", wr_data);
    reg_write(wr_seq, "CSADSER_DvmSnpEn", wr_data);
<% } %>

    test_seq = dce_seq::type_id::create("test_seq");

    test_seq.m_csm = m_env.m_sb.m_csm;
    test_seq.m_gen = m_env.m_gen;
    test_seq.k_init_rand_state  = k_init_rand_state;
    test_seq.k_num_cmd          = k_num_cmd;
    test_seq.k_num_addr         = k_num_addr;
    test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
    test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;
    test_seq.start(null);
    main_done = phase.get_objection();
    main_done.set_drain_time(null, 1us);
  end

  phase.drop_objection(this, "Finish dce_test run phase");

endtask : run_main

task dce_test::power_seq(uvm_phase phase, dce_seq test_seq);
     phase.raise_objection(this, "Start dce_power_test ");
      if ($test$plusargs("snoop_filter")) begin
       #100000ns;
<% for(var pidx = 0; pidx < obj.SnoopFilterInfo.length; pidx++) { %> // every snoop filter
        power_down_snoop_filter_<%=pidx%>(phase);
<% if (obj.nAIUs > 0) { %>
<% for(var agtId = 0; agtId < obj.nAIUs; agtId++) { %>
<% if ((obj.AiuInfo[agtId].fnNativeInterface == "ACE") && (obj.AiuInfo[agtId].CmpInfo.idSnoopFilterSlice == pidx)) { %> // pdown those with this filter
       power_down_caiu_<%=agtId%>(phase, test_seq);
       #50000ns;
<%} } } %>
<% if (obj.nCBIs > 0) { %>
<% for(var agtId = obj.nAIUs; agtId < obj.nAIUs+obj.nCBIs; agtId++) { %>
<% var bridgeId = agtId - obj.nAIUs; %>
<% if ((obj.BridgeAiuInfo[bridgeId].NativeInfo.useIoCache == 1) && (obj.BridgeAiuInfo[bridgeId].CmpInfo.idSnoopFilterSlice == pidx)) { %> // pdown those with this filter
       //power_down_ncbu_<%=pidx%>(phase, test_seq);
       #50000ns;
<% } } %>
<% } } %>
<% for(var pidx = 0; pidx < obj.SnoopFilterInfo.length; pidx++) { %> // every snoop filter
        power_up_snoop_filter_<%=pidx%>(phase);
<% if (obj.nAIUs > 0) { %>
<% for(var agtId = 0; agtId < obj.nAIUs; agtId++) { %>
<% if ((obj.AiuInfo[agtId].fnNativeInterface == "ACE") && (obj.AiuInfo[agtId].CmpInfo.idSnoopFilterSlice == pidx)) { %>
        power_up_caiu_<%=agtId%>(phase, test_seq);
<% } } }%>
<% if (obj.nCBIs > 0) { %>
<% for(var agtId = obj.nAIUs; agtId < obj.nAIUs+obj.nCBIs; agtId++) { %>
<% var bridgeId = agtId - obj.nAIUs; %>
<% if ((obj.BridgeAiuInfo[bridgeId].NativeInfo.useIoCache == 1) && (obj.BridgeAiuInfo[bridgeId].CmpInfo.idSnoopFilterSlice == pidx)) { %>
       //power_up_ncbu_<%=pidx%>(phase, test_seq);
<% } } }%>
<% } %>
     end
      if ($test$plusargs("agent")) begin
       #100000ns;
<% if (obj.nAIUs > 0) { %>
<% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
       power_down_caiu_<%=pidx%>(phase, test_seq);
       #50000ns;
<%} } %>
<% if (obj.nCBIs > 0) { %>
<% for(var pidx = obj.nAIUs; pidx < obj.nAIUs+obj.nCBIs; pidx++) { %>
       //power_down_ncbu_<%=pidx%>(phase, test_seq);
       #50000ns;
<% } } %>

<% if (obj.nAIUs > 0) { %>
<% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
       power_up_caiu_<%=pidx%>(phase, test_seq);
       #50000ns;
<%} } %>
<% if (obj.nCBIs > 0) { %>
<% for(var pidx = obj.nAIUs; pidx < obj.nAIUs+obj.nCBIs; pidx++) { %>
       //power_up_ncbu_<%=pidx%>(phase, test_seq);
       #50000ns;
<% } } %>
     end
     phase.drop_objection(this, "Finish dce_power_test ");
endtask : power_seq

<% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %> // every snoop filter
task dce_test::power_down_caiu_<%=pidx%>(uvm_phase phase, dce_seq test_seq);
        test_seq.agent_is_powered_down(<%=pidx%>);
        //power_down_bfm(<%=pidx%>);
    `uvm_info("POWER DOWN",$sformatf("Entered power down aiu %0d",<%=pidx%>), UVM_NONE)
   <% var agtid = 0;%>
   //////////////////////////////////////////////////////////////////////////
   // 1.. For each DCE clear the Caching Agent Snoop Enable Register.snoop_en (for this agent)
   //////////////////////////////////////////////////////////////////////////
       reg_name = "DCEUCASER_CaSnpEn";
       reg_read(reg_name, rd_data, 0);
       mask_data = (32'hffffffff - (1<<<%=pidx%>));
       wr_data = (rd_data & mask_data);
       reg_write(reg_name, wr_data, 0);
       `uvm_info("POWER DOWN",$sformatf("Write to DCE%0d to clear SnoopEn for this AIU ",<%=agtid-obj.nAIUs-obj.nCBIs%>), UVM_NONE)

   //////////////////////////////////////////////////////////////////////////
   // 2. Clear ACE DVM Snoop Enable bit in ACE DVM Snoop En register for the AIU (if appropriate)
   //////////////////////////////////////////////////////////////////////////
       reg_name = "CSADSER_DvmSnpEn";
       reg_read(reg_name, rd_data, 0);
       mask_data = (32'hffffffff - (1<<<%=pidx%>));
       wr_data = (rd_data & mask_data);
       reg_write(reg_name, wr_data, 0);
       `uvm_info("POWER DOWN",$sformatf("Clear Ace DvmSnpEn"), UVM_NONE)

   //////////////////////////////////////////////////////////////////////////
   // 3. In each directory unit, poll the Caching Agent Snoop Active bit (Caching Agent Snoop Activity Register) for the caching agent until clear, if appropriate (DCEUCASAR)
   //////////////////////////////////////////////////////////////////////////
       rd_data = 'b1;
       timeout_count = 100000;
       reg_name = "DCEUCASAR_CaSnpActv";
       do begin
         reg_read(reg_name, rd_data, 0);
         timeout_count -= 1;
         `uvm_info("POWER DOWN",$sformatf("Reading DCEUCASAR.casnpactv"), UVM_NONE)
	 #500ns;
       end while((rd_data[<%=pidx%>] !== 'b0) && (timeout_count != 0));
       if(timeout_count == 0) begin
            `uvm_fatal("POWER DOWN", "Timedout reading DCEUCASAR.casnpactv")
       end

   //////////////////////////////////////////////////////////////////////////
   // 4. Poll the ACE DVM Snoop Active bit (ACE DVM Snoop Activity Register) for the AIU until clear, if appropriate (CSADSAR)
   //////////////////////////////////////////////////////////////////////////
       rd_data = 'b1;
       reg_name = "CSADSAR_DvmSnpActv";
       timeout_count = 100000;
       do begin
         reg_read(reg_name, rd_data, 0);
         timeout_count -= 1;
         `uvm_info("POWER DOWN",$sformatf("Reading CSADSAR.dvmsnpactv"), UVM_NONE)
	 #500ns;
       end while((rd_data[<%=pidx%>] !== 'b0) && (timeout_count != 0));
       if(timeout_count == 0) begin
            `uvm_fatal("POWER DOWN", "Timedout reading CSADSAR.casnpactv")
       end
   //////////////////////////////////////////////////////////////////////////
   // 5. Poll TAR in AIU until clean
   //////////////////////////////////////////////////////////////////////////
endtask: power_down_caiu_<%=pidx%>

task dce_test::power_up_caiu_<%=pidx%>(uvm_phase phase, dce_seq test_seq);

   //////////////////////////////////////////////////////////////////////////
   //  1. In each directory unit, set the Caching Agent Snoop Enable
   //  bit (Caching Agent Snoop Enable Register) for the caching agent, if appropriate
   //////////////////////////////////////////////////////////////////////////
       reg_name = "DCEUCASER_CaSnpEn";
       reg_read(reg_name, rd_data, 0);
       mask_data = (32'h0 | (1<<<%=pidx%>));
       wr_data = (rd_data | mask_data);
       reg_write(reg_name, wr_data, 0);
       `uvm_info("[POWER UP]",$sformatf("Write to DCE to set snoop en for this AIU"), UVM_NONE)

   //////////////////////////////////////////////////////////////////////////
   //  2. Set the ACE DVM Snoop Enable bit (ACE DVM Snoop Enable Register)
   //  for the AIU, if appropriate
   //////////////////////////////////////////////////////////////////////////
       reg_name = "CSADSER_DvmSnpEn";
       reg_read(reg_name, rd_data, 0);
       mask_data = (32'h0 | (1<<<%=pidx%>));
       wr_data = (rd_data | mask_data);
       reg_write(reg_name, wr_data, 0);
       `uvm_info("[POWER UP]",$sformatf("Set ace dvm snp en"), UVM_NONE)

        test_seq.agent_is_powered_up(<%=pidx%>);
       //power_up_bfm(<%=pidx%>);
endtask: power_up_caiu_<%=pidx%>
<% } %>

<% for(var pidx = obj.nAIUs; pidx < obj.nAIUs+obj.nCBIs; pidx++) { %> // every snoop filter
task dce_test::power_down_ncbu_<%=pidx%>(uvm_phase phase, dce_seq test_seq);
        test_seq.agent_is_powered_down(<%=pidx%>);
        //power_down_bfm(<%=pidx%>);
    `uvm_info("POWER DOWN",$sformatf("Entered power down aiu %0d",<%=pidx%>), UVM_NONE)
   <% var agtid = 0;%>
   <% var bridgeId = pidx - obj.nAIUs; %>
   //////////////////////////////////////////////////////////////////////////
   // 1.. For each DCE clear the Caching Agent Snoop Enable Register.snoop_en (for this agent)
   //////////////////////////////////////////////////////////////////////////
       reg_name = "DCEUCASER_CaSnpEn";
       reg_read(reg_name, rd_data, 3);
       mask_data = (32'hffffffff - (1<<<%=bridgeId%>));
       wr_data = (rd_data & mask_data);
       reg_write(reg_name, wr_data, 3);
       `uvm_info("POWER DOWN",$sformatf("Write to DCE%0d to clear SnoopEn for this AIU ",<%=agtid%>), UVM_NONE)

   //////////////////////////////////////////////////////////////////////////
   // 2. Clear ACE DVM Snoop Enable bit in ACE DVM Snoop En register for the AIU (if appropriate)
   //////////////////////////////////////////////////////////////////////////
       reg_name = "CSADSER_DvmSnpEn";
       reg_read(reg_name, rd_data, 3);
       mask_data = (32'hffffffff - (1<<<%=bridgeId%>));
       wr_data = (rd_data & mask_data);
       reg_write(reg_name, wr_data, 3);
       `uvm_info("POWER DOWN",$sformatf("Clear Ace DvmSnpEn"), UVM_NONE)

   //////////////////////////////////////////////////////////////////////////
   // 3. In each directory unit, poll the Caching Agent Snoop Active bit (Caching Agent Snoop Activity Register) for the caching agent until clear, if appropriate (DCEUCASAR)
   //////////////////////////////////////////////////////////////////////////
       rd_data = 'b1;
       timeout_count = 100000;
       reg_name = "DCEUCASAR_CaSnpActv";
       do begin
         reg_read(reg_name, rd_data, 3);
         timeout_count -= 1;
         `uvm_info("POWER DOWN",$sformatf("Reading DCEUCASAR.casnpactv"), UVM_NONE)
	 #500ns;
       end while((rd_data[<%=bridgeId%>] !== 'b0) && (timeout_count != 0));
       if(timeout_count == 0) begin
            `uvm_fatal("POWER DOWN", "Timedout reading DCEUCASAR.casnpactv")
       end

   //////////////////////////////////////////////////////////////////////////
   // 4. Poll the ACE DVM Snoop Active bit (ACE DVM Snoop Activity Register) for the AIU until clear, if appropriate (CSADSAR)
   //////////////////////////////////////////////////////////////////////////
       rd_data = 'b1;
       reg_name = "CSADSAR_DvmSnpActv";
       timeout_count = 100000;
       do begin
         reg_read(reg_name, rd_data, 3);
         timeout_count -= 1;
         `uvm_info("POWER DOWN",$sformatf("Reading CSADSAR.dvmsnpactv"), UVM_NONE)
	 #500ns;
       end while((rd_data[<%=bridgeId%>] !== 'b0) && (timeout_count != 0));
       if(timeout_count == 0) begin
            `uvm_fatal("POWER DOWN", "Timedout reading CSADSAR.casnpactv")
       end
   //////////////////////////////////////////////////////////////////////////
   // 5. Poll TAR in AIU until clean
   //////////////////////////////////////////////////////////////////////////
endtask: power_down_ncbu_<%=pidx%>

task dce_test::power_up_ncbu_<%=pidx%>(uvm_phase phase, dce_seq test_seq);

   //////////////////////////////////////////////////////////////////////////
   //  1. In each directory unit, set the Caching Agent Snoop Enable
   //  bit (Caching Agent Snoop Enable Register) for the caching agent, if appropriate
   //////////////////////////////////////////////////////////////////////////
       reg_name = "DCEUCASER_CaSnpEn";
       reg_read(reg_name, rd_data, 3);
       mask_data = (32'h0 | (1<<<%=bridgeId%>));
       wr_data = (rd_data | mask_data);
       reg_write(reg_name, wr_data, 3);
       `uvm_info("[POWER UP]",$sformatf("Write to DCE to set snoop en for this AIU"), UVM_NONE)

   //////////////////////////////////////////////////////////////////////////
   //  2. Set the ACE DVM Snoop Enable bit (ACE DVM Snoop Enable Register)
   //  for the AIU, if appropriate
   //////////////////////////////////////////////////////////////////////////
       reg_name = "CSADSER_DvmSnpEn";
       reg_read(reg_name, rd_data, 3);
       mask_data = (32'h0 | (1<<<%=bridgeId%>));
       wr_data = (rd_data | mask_data);
       reg_write(reg_name, wr_data, 3);
       `uvm_info("[POWER UP]",$sformatf("Set ace dvm snp en"), UVM_NONE)

        test_seq.agent_is_powered_up(<%=pidx%>);
       //power_up_bfm(<%=pidx%>);
endtask: power_up_ncbu_<%=pidx%>
<% } %>

<% for(var pidx = 0; pidx < obj.SnoopFilterInfo.length; pidx++) { %> // every snoop filter
task dce_test::power_down_snoop_filter_<%=pidx%>(uvm_phase phase);
   //////////////////////////////////////////////////////////////////////////
   // 1. Clear the Snoop Filter En bit (DCEUSFER)
   //////////////////////////////////////////////////////////////////////////
       <% var agtid = 0; %>
       reg_name = "DCEUSFER_SfEn";
       reg_read(reg_name, rd_data);
       mask_data = (32'hffffffff - (1<<<%=pidx%>)); // snoopFilter number
       wr_data = (rd_data & mask_data);
       reg_write(reg_name, wr_data);
       `uvm_info("POWER DOWN",$sformatf("Write to DCEUSFER %0d to clear snoop en for this snp filter (%0d)",<%=agtid%>, <%=pidx%>), UVM_NONE)
       #100000ns;
endtask : power_down_snoop_filter_<%=pidx%>

task dce_test::power_up_snoop_filter_<%=pidx%>(uvm_phase phase);
       reg_name = "DCEUSFMCR_SfMntOp";
       reg_read(reg_name, rd_data);
       mask_data = (32'hffe0fff0);
       wr_data = ((rd_data & mask_data) + (<%=pidx%><<16));  // snoopFilter number
       reg_write(reg_name, wr_data);
       `uvm_info("POWER DOWN",$sformatf("DCE%0d snp filter init (%0d)",<%=agtid%>, <%=pidx%>), UVM_NONE)

       reg_name = "DCEUSFMAR_MntOpActv";
       reg_wait_for_value(32'b0, reg_name, rd_data);

       reg_name = "DCEUSFEN_SnpEn";
       reg_read(reg_name, rd_data);
       mask_data = (32'h0 | (1<<<%=pidx%>)); // snoopFilter number
       wr_data = (rd_data | mask_data);
       reg_write(reg_name, wr_data);
       `uvm_info("POWER DOWN",$sformatf("Write to DCEUSFER %0d to set snoop en for this snp filter (%0d)",<%=agtid%>, <%=pidx%>), UVM_NONE)
       #10000ns;
endtask : power_up_snoop_filter_<%=pidx%>
<% } %>

//------------------------------------------------------------------------------
// reset_port
//------------------------------------------------------------------------------

function void dce_test::write_reset_port(reset_pkt item);
   $display("DCE TEST SAW A RESET PACKET!!!!");
   reset_on = item.reset_on;
   if (item.reset_on == 1) begin
     reset_active = 1;
   end
   if (item.reset_on == 0) begin
     reset_active = 0;
   end
endfunction : write_reset_port

function void dce_test::assign_test_plusargs(ref dce_seq m_seq);
    dce_seq tmp_seq;

    if(!$cast(tmp_seq, m_seq))
        `uvm_fatal("dce_test", "Unable to cast")

    //Number of commands
    tmp_seq.k_num_cmd                  = $urandom_range(50000,60000);

    //Stress Test for Directory manager & victim bufferlogic, 
    //coherent lookups, updates, recalls & maintanence recalls
    if($test$plusargs("dirm_alloc_test")) begin
        `uvm_info("dce_test", "stress test for Directory Manager", UVM_NONE)
        tmp_seq.wt_cmd_rd_cpy             = 5;
        tmp_seq.wt_cmd_rd_cln             = 15;
        tmp_seq.wt_cmd_rd_vld             = 5;
        tmp_seq.wt_cmd_rd_unq             = 15;
        tmp_seq.wt_cmd_cln_unq            = 15;
        tmp_seq.wt_cmd_cln_vld            = 5;
        tmp_seq.wt_cmd_cln_inv            = 5;
        tmp_seq.wt_cmd_wr_unq_ptl         = 15;
        tmp_seq.wt_cmd_wr_unq_full        = 15;
        tmp_seq.wt_cmd_upd_inv            = 5;
        tmp_seq.wt_cmd_dvm_msg            = 0;

        tmp_seq.k_num_addr                 = get_dirm_entries_cnt();

    //Stress test for address sharing among differnt caching agents 
    end else if($test$plusargs("addr_sharing_test")) begin
        `uvm_info("dce_test", "stress test for Address sharing among different caches", UVM_NONE)
        tmp_seq.wt_cmd_rd_cpy             = 20;
        tmp_seq.wt_cmd_rd_cln             = 20;
        tmp_seq.wt_cmd_rd_vld             = 25;
        tmp_seq.wt_cmd_rd_unq             = 5;
        tmp_seq.wt_cmd_cln_unq            = 5;
        tmp_seq.wt_cmd_cln_vld            = 15;
        tmp_seq.wt_cmd_cln_inv            = 0;
        tmp_seq.wt_cmd_wr_unq_ptl         = 0;
        tmp_seq.wt_cmd_wr_unq_full        = 0;
        tmp_seq.wt_cmd_upd_inv            = 10;
        tmp_seq.wt_cmd_dvm_msg            = 0;

        tmp_seq.k_num_addr                = int'(get_dirm_entries_cnt() / 2);

    //Stress test to initiate more MRDreq's
    end else if($test$plusargs("mem_test")) begin
        `uvm_info("dce_test", "stress test for memory request transactions", UVM_NONE)
        tmp_seq.wt_cmd_rd_cpy             = 5;
        tmp_seq.wt_cmd_rd_cln             = 10;
        tmp_seq.wt_cmd_rd_vld             = 10;
        tmp_seq.wt_cmd_rd_unq             = 10;
        tmp_seq.wt_cmd_cln_unq            = 10;
        tmp_seq.wt_cmd_cln_vld            = 10;
        tmp_seq.wt_cmd_cln_inv            = 10;
        tmp_seq.wt_cmd_wr_unq_ptl         = 10;
        tmp_seq.wt_cmd_wr_unq_full        = 10;
        tmp_seq.wt_cmd_upd_inv            = 10;
        tmp_seq.wt_cmd_dvm_msg            = 5;

        tmp_seq.k_num_addr                = int'(get_dirm_entries_cnt() * 2);

    //Stress test for DVM operations & Wr transactions
    end else if($test$plusargs("dvm_test")) begin
        `uvm_info("dce_test", "stress test for DVM/Wr transactions", UVM_NONE)
        tmp_seq.wt_cmd_rd_cpy             = 10;
        tmp_seq.wt_cmd_rd_cln             = 5;
        tmp_seq.wt_cmd_rd_vld             = 5;
        tmp_seq.wt_cmd_rd_unq             = 5;
        tmp_seq.wt_cmd_cln_unq            = 5;
        tmp_seq.wt_cmd_cln_vld            = 5;
        tmp_seq.wt_cmd_cln_inv            = 5;
        tmp_seq.wt_cmd_wr_unq_ptl         = 10;
        tmp_seq.wt_cmd_wr_unq_full        = 10;
        tmp_seq.wt_cmd_upd_inv            = 10;
        tmp_seq.wt_cmd_dvm_msg            = 30;

        tmp_seq.k_num_addr                = int'(get_dirm_entries_cnt() * 1.5);

    end else begin
        `uvm_info("dce_test", "stress Test with random knobs", UVM_NONE)

        tmp_seq.wt_cmd_rd_cpy             = $urandom_range(8,10);
        tmp_seq.wt_cmd_rd_cln             = $urandom_range(8,10);
        tmp_seq.wt_cmd_rd_vld             = $urandom_range(8,10);
        tmp_seq.wt_cmd_rd_unq             = $urandom_range(8,10);
        tmp_seq.wt_cmd_cln_unq            = $urandom_range(8,10);
        tmp_seq.wt_cmd_cln_vld            = $urandom_range(8,10);
        tmp_seq.wt_cmd_cln_inv            = $urandom_range(8,10);
        tmp_seq.wt_cmd_wr_unq_ptl         = $urandom_range(8,10);
        tmp_seq.wt_cmd_wr_unq_full        = $urandom_range(8,10);
        tmp_seq.wt_cmd_upd_inv            = $urandom_range(8,10);
        tmp_seq.wt_cmd_dvm_msg            = $urandom_range(8,10);

        tmp_seq.k_num_addr                = int'(get_dirm_entries_cnt() * 3);
    end

     tmp_seq.wt_err_snp_sfi_slv        = wt_err_snp_sfi_slv;
     tmp_seq.wt_err_snp_sfi_slv_recall = wt_err_snp_sfi_slv_recall;
     tmp_seq.wt_err_snp_sfi_disc       = wt_err_snp_sfi_disc;
     tmp_seq.wt_err_snp_sfi_derr        = wt_err_snp_sfi_derr;
     tmp_seq.wt_err_snp_sfi_derr_recall = wt_err_snp_sfi_derr_recall;
     tmp_seq.wt_err_snp_sfi_tmo         = wt_err_snp_sfi_tmo;
     tmp_seq.wt_err_hnt_sfi_disc        = wt_err_hnt_sfi_disc;
     tmp_seq.wt_err_hnt_sfi_tmo         = wt_err_hnt_sfi_tmo;
     tmp_seq.wt_err_mrd_sfi_disc        = wt_err_mrd_sfi_disc;
     tmp_seq.wt_err_mrd_sfi_tmo         = wt_err_mrd_sfi_tmo;
     tmp_seq.wt_err_str_sfi_disc        = wt_err_str_sfi_disc;
     tmp_seq.wt_err_str_sfi_tmo         = wt_err_str_sfi_tmo;

//   tmp_seq.k_force_req_aiu0           = k_force_req_aiu0;
     tmp_seq.k_init_rand_state          = 0;
     tmp_seq.k_hnt_rsp_delay            = 1;
     tmp_seq.k_mrd_rsp_delay            = 1;
     tmp_seq.k_snp_rsp_delay            = 1;
     tmp_seq.k_str_rsp_delay            = 1;
     tmp_seq.k_security                 = k_security;
     tmp_seq.k_priority                 = k_priority;

     `uvm_info("dce_test", $psprintf("num_cmd:%0d num_addr:%0d", 
     tmp_seq.k_num_cmd, tmp_seq.k_num_addr), UVM_NONE)

endfunction: assign_test_plusargs

////////////////////////////////////////////////////////////////////////////////

