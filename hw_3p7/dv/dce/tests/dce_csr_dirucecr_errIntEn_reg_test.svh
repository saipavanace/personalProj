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
//dce_csr_dirucecr_errIntEn_reg_test
// Correctable Error Interrupt Enable : If this bit is set, the correctable error 
// interrupt signal is asserted when appropriate condition are met,otherwise 
// the correctable error interript signal is not asserted
////////////////////////////////////////////////////////////////////////////////

class dce_csr_dirucecr_errIntEn_reg_test extends dce_test_base;

  `uvm_component_utils(dce_csr_dirucecr_errIntEn_reg_test)
    bit [31:0] r_addr;
    bit [31:0] r_mask;
    bit [31:0] r_reset;
    string     reg_name;
    event read_event;

  virtual dce_csr_probe_if u_csr_probe_vif;

  extern function new(string name = "dce_csr_dirucecr_errIntEn_reg_test", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase);
  extern virtual task run_main(uvm_phase phase);

endclass: dce_csr_dirucecr_errIntEn_reg_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_csr_dirucecr_errIntEn_reg_test::new(string name = "dce_csr_dirucecr_errIntEn_reg_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_csr_dirucecr_errIntEn_reg_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------
task dce_csr_dirucecr_errIntEn_reg_test::main_phase(uvm_phase phase);
  fork
    run_main(phase);
    run_watchdog_timer(phase);
  join
endtask : main_phase

task dce_csr_dirucecr_errIntEn_reg_test::run_main(uvm_phase phase);
  uvm_objection main_done;
  dce_seq  test_seq = dce_seq::type_id::create("test_seq");

  test_seq.m_csm = m_env.m_sb.m_csm;
  test_seq.m_gen = m_env.m_gen;

  test_seq.wt_cmd_rd_cpy          = wt_cmd_rd_cpy;
  test_seq.wt_cmd_rd_cln          = wt_cmd_rd_cln;
  test_seq.wt_cmd_rd_vld          = wt_cmd_rd_vld;
  test_seq.wt_cmd_rd_unq          = wt_cmd_rd_unq;
  test_seq.wt_cmd_cln_unq         = wt_cmd_cln_unq;
  test_seq.wt_cmd_cln_vld         = wt_cmd_cln_vld;
  test_seq.wt_cmd_cln_inv         = wt_cmd_cln_inv;
  test_seq.wt_cmd_wr_unq_ptl      = wt_cmd_wr_unq_ptl;
  test_seq.wt_cmd_wr_unq_full     = wt_cmd_wr_unq_full;
  test_seq.wt_cmd_upd_inv         = wt_cmd_upd_inv;
  test_seq.wt_cmd_upd_vld         = wt_cmd_upd_vld;
  test_seq.wt_cmd_dvm_msg         = wt_cmd_dvm_msg;
  test_seq.wt_err_snp_sfi_slv     = wt_err_snp_sfi_slv;
  test_seq.wt_err_snp_sfi_disc    = wt_err_snp_sfi_disc;
  test_seq.wt_err_snp_sfi_derr    = wt_err_snp_sfi_derr;
  test_seq.wt_err_snp_sfi_tmo     = wt_err_snp_sfi_tmo;
  test_seq.wt_err_hnt_sfi_disc    = wt_err_hnt_sfi_disc;
  test_seq.wt_err_hnt_sfi_tmo     = wt_err_hnt_sfi_tmo;
  test_seq.wt_err_mrd_sfi_disc    = wt_err_mrd_sfi_disc;
  test_seq.wt_err_mrd_sfi_tmo     = wt_err_mrd_sfi_tmo;
  test_seq.wt_err_str_sfi_disc    = wt_err_str_sfi_disc;
  test_seq.wt_err_str_sfi_tmo     = wt_err_str_sfi_tmo;

  test_seq.k_force_req_aiu0       = k_force_req_aiu0;
  test_seq.k_init_rand_state      = k_init_rand_state;
  test_seq.k_num_cmd              = k_num_cmd;
  test_seq.k_num_addr             = k_num_addr;
  test_seq.k_hnt_rsp_delay        = k_hnt_rsp_delay;
  test_seq.k_mrd_rsp_delay        = k_mrd_rsp_delay;
  test_seq.k_snp_rsp_delay        = k_snp_rsp_delay;
  test_seq.k_str_rsp_delay        = k_str_rsp_delay;
  test_seq.k_security             = k_security;
  test_seq.k_priority             = k_priority;

  phase.raise_objection(this, "Start dce_csr_dirucecr_errIntEn_reg_test run phase");
 
  test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
  test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;

  if(!uvm_config_db#(virtual dce_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif))
    `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})

<% if(has_ocp) { %>
    //*****************************************************************************
    // Delay for ocp vip reset de-asseretion  
    //*****************************************************************************
    
    #(176ns);
<% } %>

    //*****************************************************************************
    // Read the DCEUCECR_ErrDetEn should be at reset value 
    //*****************************************************************************

     reg_name = "DCEUCECR_ErrDetEn";
     r_mask   = mask_data(reg_name);
     r_reset  = regs.reg_reset[reg_name];
     reg_read(reg_name,rd_data);
     

     if(rd_data[0] == r_reset[0])begin
        `uvm_info("RUN_MAIN",$sformatf("ErrDetEn reg returned reset value :%b",rd_data[0]), UVM_LOW)
     end else begin
        uvm_report_error("RUN_MAIN",$sformatf("ErrDetEn Read Data :%b, Expected data :%b",rd_data[0],r_reset[0]), UVM_LOW);
     end

     if(rd_data[1] == r_reset[1])begin
        `uvm_info("RUN_MAIN",$sformatf("ErrIntEn reg returned reset value :%b",rd_data[1]), UVM_LOW)
     end else begin
        uvm_report_error("RUN_MAIN",$sformatf("ErrIntEn Read Data :%b, Expected data :%b",rd_data[1],r_reset[1]), UVM_LOW);
     end

    //*****************************************************************************
    // Read the DCEUCESR_ErrVld should be at reset value 
    //*****************************************************************************

     reg_name = "DCEUCESR_ErrVld";
     r_mask   = mask_data(reg_name);
     r_reset  = regs.reg_reset[reg_name];
     reg_read(reg_name,rd_data);
     

     if(rd_data[0] == r_reset[0])begin
        `uvm_info("RUN_MAIN",$sformatf("ErrVld reg returned reset value :%b",rd_data[0]), UVM_LOW)
     end else begin
        uvm_report_error("RUN_MAIN",$sformatf("Read Data:%b, Expected data :%b",rd_data[0],r_reset[0]), UVM_LOW);
     end
     //*****************************************************************************
     // Set the DCEUCECR_ErrDetEn = 1
     //*****************************************************************************
      `uvm_info("RUN_MAIN",$sformatf("Setting DCEUCECR_ErrDetEn = 1 "), UVM_LOW)

      reg_name = "DCEUCECR_ErrDetEn";
      reg_rmwrite(reg_name,32'h00000001);

     //*****************************************************************************
     // Set the DCEUCECR_ErrIntEn = 1
     //*****************************************************************************
      `uvm_info("RUN_MAIN",$sformatf("Setting DCEUCECR_ErrIntEn = 1 "), UVM_LOW)

      reg_name = "DCEUCECR_ErrIntEn";
      reg_rmwrite(reg_name,32'h00000002);

<% if(has_secded) { %>
  fork
    begin
      repeat(2)
        begin

        //*****************************************************************************
        // wait for IRQ_C interrupt 
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("waiting for Interrupt IRQ_C "), UVM_LOW)

         @(u_csr_probe_vif.IRQ_C)
         begin

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
         // Set the DCEUCECR_ErrIntEn = 0, to diable the error Interrupt
         //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Setting DCEUCECR_ErrIntEn = 0 "), UVM_LOW)

          reg_name = "DCEUCECR_ErrIntEn";
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

          //*****************************************************************************
          // Monitor IRQ_C pin , it should be 0 now
          //*****************************************************************************

          if(u_csr_probe_vif.IRQ_C == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asseretd"), UVM_LOW)
          end else begin
             uvm_report_error("RUN_MAIN",$sformatf("IRQ_C interruped still aseerted"), UVM_LOW);
          end

         //*****************************************************************************
         // Set the DCEUCECR_ErrDetEn = 1
         //*****************************************************************************
          `uvm_info("RUN_MAIN",$sformatf("Setting DCEUCECR_ErrDetEn = 1 "), UVM_LOW)

          reg_name = "DCEUCECR_ErrDetEn";
          reg_rmwrite(reg_name,32'h00000001);

         //*****************************************************************************
         // Set the DCEUCECR_ErrIntEn = 1
         //*****************************************************************************
          `uvm_info("RUN_MAIN",$sformatf("Setting DCEUCECR_ErrIntEn = 1 "), UVM_LOW)

          reg_name = "DCEUCECR_ErrIntEn";
          reg_rmwrite(reg_name,32'h00000002);
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


  phase.drop_objection(this, "Finish dce_csr_dirucecr_errIntEn_reg_test run phase");

endtask : run_main

////////////////////////////////////////////////////////////////////////////////

