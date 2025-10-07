<% var has_ocp = 0 
  if (obj.BLK_SNPS_OCP_VIP) { 
    has_ocp = 1
  } 
  if (obj.INHOUSE_OCP_VIP) { 
    has_ocp = 1
  } 
%>
<% var has_tagfilter = 0
   obj.SnoopFilterInfo.forEach(function(snoop, snoop_no) {
	if(snoop.fnFilterType == "TAGFILTER") {
	   has_tagfilter = 1
	}   
   }); 
%>

////////////////////////////////////////////////////////////////////////////////
//dce_csr_diruuecr_errcnt_reg_test
// Uncorrectable Error Count - This field indicates the number of uncorrectable errors 
// detected by the unit. The field stops incrementing if the uncorrectable Error Count 
// Overflow bit is set.
//////////////////////////////////////////////////////////////////////////////////

class dce_csr_diruuecr_errcnt_reg_test extends dce_test_base;

  `uvm_component_utils(dce_csr_diruuecr_errcnt_reg_test)
    bit [31:0] r_addr;
    bit [31:0] r_mask;
    bit [31:0] r_reset;
    string     reg_name;
    event read_event;
    bit [7:0]  errthd;
    int        errcount_vld;
    int        errcount_ovf;
    int        injerr_count;

  virtual dce_csr_probe_if u_csr_probe_vif;

  extern function new(string name = "dce_csr_diruuecr_errcnt_reg_test", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase);
  extern virtual task run_main(uvm_phase phase);

endclass: dce_csr_diruuecr_errcnt_reg_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_csr_diruuecr_errcnt_reg_test::new(string name = "dce_csr_diruuecr_errcnt_reg_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_csr_diruuecr_errcnt_reg_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------
task dce_csr_diruuecr_errcnt_reg_test::main_phase(uvm_phase phase);
  fork
    run_main(phase);
    run_watchdog_timer(phase);
  join
endtask : main_phase

task dce_csr_diruuecr_errcnt_reg_test::run_main(uvm_phase phase);
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

  phase.raise_objection(this, "Start dce_csr_diruuecr_errcnt_reg_test run phase");
 
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
    // Read the DCEUUECR_ErrDetEn should be at reset value 
    //*****************************************************************************

     reg_name = "DCEUUECR_ErrDetEn";
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
    // Read the DCEUUESR_ErrVld should be at reset value 
    //*****************************************************************************

     reg_name = "DCEUUESR_ErrVld";
     r_mask   = mask_data(reg_name);
     r_reset  = regs.reg_reset[reg_name];
     reg_read(reg_name,rd_data);
     

     if(rd_data[0] == r_reset[0])begin
        `uvm_info("RUN_MAIN",$sformatf("ErrVld reg returned reset value :%b",rd_data[0]), UVM_LOW)
     end else begin
        uvm_report_error("RUN_MAIN",$sformatf("Read Data:%b, Expected data :%b",rd_data[0],r_reset[0]), UVM_LOW);
     end
     //*****************************************************************************
     // Set the DCEUUECR_ErrThreshold 
     //*****************************************************************************
     
      errthd = 8'hFF;
      wr_data ={20'b0,errthd,4'b0};        
      reg_name = "DCEUUECR_ErrThreshold";
      reg_rmwrite(reg_name,wr_data);

      //*****************************************************************************
      // Set the DCEUUECR_ErrDetEn = 1
      //*****************************************************************************
       `uvm_info("RUN_MAIN",$sformatf("Setting DCEUUECR_ErrDetEn = 1 "), UVM_LOW)

       reg_name = "DCEUUECR_ErrDetEn";
       reg_rmwrite(reg_name,32'h00000001);

      //*****************************************************************************
      // Set the DCEUUECR_ErrIntEn = 1
      //*****************************************************************************
       `uvm_info("RUN_MAIN",$sformatf("Setting DCEUUECR_ErrIntEn = 1 "), UVM_LOW)

       reg_name = "DCEUUECR_ErrIntEn";
       reg_rmwrite(reg_name,32'h00000002);

   m_env.m_sb.dce_scoreboard_enable = 0; //disable the scoreboard //TO REMOVE THIS AFTER SCOREBOARD IS UPDATED
<% if(has_tagfilter) { %>
  fork
    begin
        //*****************************************************************************
        // wait for IRQ_C interrupt 
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("waiting for Interrupt IRQ_C "), UVM_LOW)

         @(u_csr_probe_vif.IRQ_UC)
        //****************************************************************************
        // Collect error count from error injector
        //*****************************************************************************
      <% var nBit_counts = 0;
      obj.SnoopFilterInfo.forEach( function(snoop) {
	 if(snoop.fnFilterType == "TAGFILTER") {
//	     for(var w=0; w < snoop.StorageInfo.nWays; w++) {
                  nBit_counts++;
//             }     
	 }
      }); %>
    <%if(nBit_counts > 0) { %>
      injerr_count = <%for(var i=0; i < nBit_counts - 1; i++) { %> u_csr_probe_vif.double_bit_count<%=i%> + <% } %> u_csr_probe_vif.double_bit_count<%=nBit_counts - 1 %>;
    <% } %>
        //**********************************************************************************
        // Read DCEUUESR_ErrCount 
        //*****************************************************************************
          reg_name = "DCEUUESR_ErrCount";
          reg_read(reg_name,rd_data);

          if((rd_data[11:4] == 0) || (rd_data[0] == 1))begin
           `uvm_info("RUN_MAIN",$sformatf(" DCEUUESR reg errCount :%d,injerr_count:%d,vld=%0d ",rd_data[11:4],injerr_count,rd_data[0]), UVM_LOW)
          end else begin
           uvm_report_error("RUN_MAIN",$sformatf("DCEUUESR reg errCount :%d,injerr_count:%d,vld=%0d",rd_data[11:4],injerr_count,rd_data[0]), UVM_LOW);
          end
        //**********************************************************************************
        // Read DCEUUESAR_ErrCount 
        //*****************************************************************************
          reg_name = "DCEUUESAR_ErrCount";
          reg_read(reg_name,rd_data);

          if((rd_data[11:4] == 0) || (rd_data[0] == 1))begin
           `uvm_info("RUN_MAIN",$sformatf(" DCEUUESR reg errCount :%d,injerr_count:%d,vld=%0d ",rd_data[11:4],injerr_count,rd_data[0]), UVM_LOW)
          end else begin
           uvm_report_error("RUN_MAIN",$sformatf("DCEUUESR reg errCount :%d,injerr_count:%d,vld=%0d",rd_data[11:4],injerr_count,rd_data[0]), UVM_LOW);
          end

    end
     begin
       test_seq.start(null);
    end
  join
<% } %>
  main_done = phase.get_objection();
  main_done.set_drain_time(null, 1us);


  phase.drop_objection(this, "Finish dce_csr_diruuecr_errcnt_reg_test run phase");

endtask : run_main

////////////////////////////////////////////////////////////////////////////////

