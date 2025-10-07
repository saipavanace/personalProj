<% var has_ocp = 0 
  if (obj.BLK_SNPS_OCP_VIP) { 
    has_ocp = 1
  } 
  if (obj.INHOUSE_OCP_VIP) { 
    has_ocp = 1
  } 
%>
<% var has_secded = 0
   obj.SnoopFilterInfo.forEach(function(snoop, snoop_no) {
	if((snoop.fnFilterType == "TAGFILTER") && (snoop.StorageInfo.TagFilterErrorInfo.fnErrDetectCorrect == "SECDED")) {
	   has_secded = 1
	}   
   }); 
%>
////////////////////////////////////////////////////////////////////////////////
//dce_csr_dirucecr_errDetEn_reg_test
// Correctable Error Detection Enable : If this bit is set, the correctable error 
// detection and logging logic is enabled; otherwise, the correctable error 
// detection and logging logic is disabled
////////////////////////////////////////////////////////////////////////////////

class dce_csr_dirucecr_errDetEn_reg_test extends dce_test_base;

  `uvm_component_utils(dce_csr_dirucecr_errDetEn_reg_test)
    bit [31:0] r_addr;
    bit [31:0] r_mask;
    bit [31:0] r_reset;
    string     reg_name;
    event read_event;

  extern function new(string name = "dce_csr_dirucecr_errDetEn_reg_test", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual task run_main(uvm_phase phase);

endclass: dce_csr_dirucecr_errDetEn_reg_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_csr_dirucecr_errDetEn_reg_test::new(string name = "dce_csr_dirucecr_errDetEn_reg_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_csr_dirucecr_errDetEn_reg_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------
task dce_csr_dirucecr_errDetEn_reg_test::run_phase(uvm_phase phase);
  fork
    run_main(phase);
    run_watchdog_timer(phase);
  join
endtask : run_phase

task dce_csr_dirucecr_errDetEn_reg_test::run_main(uvm_phase phase);
  uvm_objection main_done;
  dce_seq  test_seq = dce_seq::type_id::create("test_seq");

  test_seq.m_csm = m_env.m_sb.m_csm;
  test_seq.m_gen = m_env.m_gen;
  test_seq.m_dirm_mgr = m_env.m_dirm_mgr;

  test_seq.wt_cmd_rd_cpy             = $urandom_range(8,10);
  test_seq.wt_cmd_rd_cln             = $urandom_range(8,10);
  test_seq.wt_cmd_rd_vld             = $urandom_range(8,10);
  test_seq.wt_cmd_rd_unq             = $urandom_range(8,10);
  test_seq.wt_cmd_cln_unq            = $urandom_range(8,10);
  test_seq.wt_cmd_cln_vld            = $urandom_range(8,10);
  test_seq.wt_cmd_cln_inv            = $urandom_range(8,10);
  test_seq.wt_cmd_wr_unq_ptl         = $urandom_range(8,10);
  test_seq.wt_cmd_wr_unq_full        = $urandom_range(8,10);
  test_seq.wt_cmd_upd_inv            = $urandom_range(8,10);
  test_seq.wt_cmd_dvm_msg            = $urandom_range(8,10);

  test_seq.k_num_cmd                 = $urandom_range(10000, 16000);
  test_seq.k_num_addr                = int'(get_dirm_entries_cnt());
  phase.raise_objection(this, "Start dce_csr_dirucecr_errDetEn_reg_test run phase");
 
  test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
  test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;
  //
  // Write to first 32 registers with all 1s to enable all features
  //
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
    //reg_write("DCEUCECR_ErrDetEn", wr_data);
    //reg_write("DCEUCECR_ErrIntEn", wr_data);
    //reg_write("DCEUUECR_ErrDetEn", wr_data);
    //reg_write("DCEUUECR_ErrIntEn", wr_data);
    reg_write("CSADSER_DvmSnpEn", wr_data, 0);
    reg_write("CSADSER_DvmSnpEn", wr_data, 1);
    reg_write("CSADSER_DvmSnpEn", wr_data, 2);
    reg_write("CSADSER_DvmSnpEn", wr_data, 3);
//  csr_seq.start(m_env.ocp_master_agent.df_sequencer);
  `uvm_info(get_full_name(), "Finished activating all registers", UVM_LOW)
				  
<% } %>

<% if(has_ocp) { %>
    //*****************************************************************************
    // Delay for ocp vip reset de-asseretion  
    //*****************************************************************************
    
    #(1000ns);
<% } %>

    //*****************************************************************************
    // Read the DCEUCECR_ErrDetEn should be at reset value 
    //*****************************************************************************

     reg_name = "DCEUCECR_ErrDetEn";
     r_mask   = mask_data(reg_name);
     r_reset  = regs.reg_reset[reg_name];
     reg_read(reg_name,rd_data);
     
     rd_data = (rd_data & r_mask);

     if(rd_data[0] == r_reset[0])begin
        `uvm_info("RUN_MAIN",$sformatf("reg returned reset value :%b",rd_data[0]), UVM_LOW)
     end else begin
        uvm_report_error("RUN_MAIN",$sformatf("Read Data :%b, Expected data :%b",rd_data[0],r_reset[0]), UVM_LOW);
     end

    //*****************************************************************************
    // Read the DCEUCESR_ErrVld should be at reset value 
    //*****************************************************************************

     reg_name = "DCEUCESR_ErrVld";
     r_mask   = mask_data(reg_name);
     r_reset  = regs.reg_reset[reg_name];
     reg_read(reg_name,rd_data);
     
     rd_data = (rd_data & r_mask);

     if(rd_data[0] == r_reset[0])begin
        `uvm_info("RUN_MAIN",$sformatf("reg returned reset value :%b",rd_data[0]), UVM_LOW)
     end else begin
        uvm_report_error("RUN_MAIN",$sformatf("Read Data:%b, Expected data :%b",rd_data[0],r_reset[0]), UVM_LOW);
     end

<% if(has_secded) { %>
  fork
    begin
      repeat(2)
        begin
        //*****************************************************************************
        // Set the DCEUCECR_ErrDetEn = 1
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Setting DCEUCECR_ErrDetEn = 1 "), UVM_LOW)

         reg_name = "DCEUCECR_ErrDetEn";
         reg_rmwrite(reg_name,32'h00000001);

        //*****************************************************************************
        //keep on  Reading the DCEUCESR_ErrVld bit = 1 
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Keep Reading DCEUCESR_ErrVld   = 1 "), UVM_LOW)

          reg_name = "DCEUCESR_ErrVld";
          
          reg_wait_for_value(32'h00000001,reg_name,rd_data);

          if(rd_data[0] == 1)begin
           `uvm_info("RUN_MAIN",$sformatf("DCEUESR_ErrVld value :%b",rd_data[0]), UVM_LOW)
          end else begin
           uvm_report_error("RUN_MAIN",$sformatf("DCEUESR_ErrVld value :%b",rd_data[0]), UVM_LOW);
          end
          if(rd_data[15:12] == 4'h4 )begin
           `uvm_info("RUN_MAIN",$sformatf(" DCEUESR  error type :%x",rd_data[15:12]), UVM_LOW)
          end else begin
           uvm_report_error("RUN_MAIN",$sformatf("DCEUESR  Not valid error type :%x",rd_data[15:12]), UVM_LOW);
          end

        //*****************************************************************************
        // Read DCEUCESAR_ErrVld , it should be 1
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Read alias reg DCEUCESAR_ErrVld it should also be 1"), UVM_LOW)
          reg_name = "DCEUCESAR_ErrVld";
          reg_read(reg_name,rd_data);

          if(rd_data[0] == 1)begin
           `uvm_info("RUN_MAIN",$sformatf("DCEUESAR_ErrVld value :%b",rd_data[0]), UVM_LOW)
          end else begin
           uvm_report_error("RUN_MAIN",$sformatf("DCEUESAR_ErrVld value :%b",rd_data[0]), UVM_LOW);
          end
          if(rd_data[15:12] == 4'h4 )begin
           `uvm_info("RUN_MAIN",$sformatf(" DCEUESAR ESAR  error type :%x",rd_data[15:12]), UVM_LOW)
          end else begin
           uvm_report_error("RUN_MAIN",$sformatf("DCEUESAR ESAR Not valid error type :%x",rd_data[15:12]), UVM_LOW);
          end
         //*****************************************************************************
         // Set the DCEUCECR_ErrDetEn = 0, to diable the error detection
         //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Setting DCEUCECR_ErrDetEn = 0 "), UVM_LOW)

          reg_name = "DCEUCECR_ErrDetEn";
          reg_rmwrite(reg_name,32'h00000000);

        //*****************************************************************************
        // Read DCEUCESR_ErrVld , it should be 1
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Read DCEUCESR_ErrVld "), UVM_LOW)
          reg_name = "DCEUCESR_ErrVld";
          reg_read(reg_name,rd_data);

          if(rd_data[0] == 1)begin
           `uvm_info("RUN_MAIN",$sformatf("DCEUESR_ErrVld value :%b",rd_data[0]), UVM_LOW)
          end else begin
           uvm_report_error("RUN_MAIN",$sformatf("DCEUESR_ErrVld value :%b",rd_data[0]), UVM_LOW);
          end
          if(rd_data[15:12] == 4'h4 )begin
           `uvm_info("RUN_MAIN",$sformatf(" DCEUESR  error type :%x",rd_data[15:12]), UVM_LOW)
          end else begin
           uvm_report_error("RUN_MAIN",$sformatf("DCEUESR  Not valid error type :%x",rd_data[15:12]), UVM_LOW);
          end

        //*****************************************************************************
        // Read DCEUCESAR_ErrVld , it should be 1
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Read DCEUCESAR_ErrVld "), UVM_LOW)
          reg_name = "DCEUCESAR_ErrVld";
          reg_read(reg_name,rd_data);

          if(rd_data[0] == 1)begin
           `uvm_info("RUN_MAIN",$sformatf("DCEUESAR_ErrVld value :%b",rd_data[0]), UVM_LOW)
          end else begin
           uvm_report_error("RUN_MAIN",$sformatf("DCEUESAR_ErrVld value :%b",rd_data[0]), UVM_LOW);
          end
          if(rd_data[15:12] == 4'h4 )begin
           `uvm_info("RUN_MAIN",$sformatf(" DCEUESAR ESAR  error type :%x",rd_data[15:12]), UVM_LOW)
          end else begin
           uvm_report_error("RUN_MAIN",$sformatf("DCEUESAR ESAR Not valid error type :%x",rd_data[15:12]), UVM_LOW);
          end
        //*****************************************************************************
        // write  DCEUCESR_ErrVld = 1 , to reset it
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("write 1 on DCEUCESR_ErrVld to reset it "), UVM_LOW)
          reg_name = "DCEUCESR_ErrVld";
          reg_write(reg_name,32'h00000001);

        //*****************************************************************************
        // Read the DCEUCESR_ErrVld should be cleared
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Read DCEUCESER_ErrVld "), UVM_LOW)

          reg_name = "DCEUCESR_ErrVld";
          r_mask   = mask_data(reg_name);
          r_reset  = regs.reg_reset[reg_name];
          reg_read(reg_name,rd_data);
         
          if(rd_data[0] == 0)begin
            `uvm_info("RUN_MAIN",$sformatf("DCEUCESR_ErrVld bit cleared :%b",rd_data[0]), UVM_LOW)
          end else begin
            uvm_report_error("RUN_MAIN",$sformatf("DCEUCESR_ErrVld bit not cleared Read Data:%b, Expected data :0",rd_data[0]), UVM_LOW);
          end
        //*****************************************************************************
        // Read DCEUCESAR_ErrVld , it should also clear, beacuse it is alias register
        // of register DCEUCESR_*
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Read DCEUCESAR_ErrVld "), UVM_LOW)

          reg_name = "DCEUCESAR_ErrVld";
          reg_read(reg_name,rd_data);

          if(rd_data[0] == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("DCEUESAR_ErrVld value :%b",rd_data[0]), UVM_LOW)
          end else begin
             uvm_report_error("RUN_MAIN",$sformatf("DCEUESAR_ErrVld value :%b",rd_data[0]), UVM_LOW);
          end
       end
      end
    begin
       test_seq.start(null);
    end
  join
<% } %>
  main_done = phase.get_objection();
  main_done.set_drain_time(null, 1us);


  phase.drop_objection(this, "Finish dce_csr_dirucecr_errDetEn_reg_test run phase");

endtask : run_main

////////////////////////////////////////////////////////////////////////////////

