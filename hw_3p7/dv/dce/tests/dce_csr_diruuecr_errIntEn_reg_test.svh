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
//dce_csr_diruuecr_errIntEn_reg_test
// Unorrectable Error Interrupt Enable : If this bit is set, the uncorrectable error 
// interrupt signal is asserted when appropriate condition are met,otherwise 
// the uncorrectable error interript signal is not asserted
////////////////////////////////////////////////////////////////////////////////

class dce_csr_diruuecr_errIntEn_reg_test extends dce_test_base;

  `uvm_component_utils(dce_csr_diruuecr_errIntEn_reg_test)
    bit [31:0] r_addr;
    bit [31:0] r_mask;
    bit [31:0] r_reset;
    string     reg_name;
    event read_event;
    bit [7:0] errthd;

  virtual dce_csr_probe_if u_csr_probe_vif;

  extern function new(string name = "dce_csr_diruuecr_errIntEn_reg_test", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task main_phase(uvm_phase phase);
  extern virtual task run_main(uvm_phase phase);

endclass: dce_csr_diruuecr_errIntEn_reg_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_csr_diruuecr_errIntEn_reg_test::new(string name = "dce_csr_diruuecr_errIntEn_reg_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_csr_diruuecr_errIntEn_reg_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction : build_phase

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------
task dce_csr_diruuecr_errIntEn_reg_test::main_phase(uvm_phase phase);
  fork
    run_main(phase);
    run_watchdog_timer(phase);
  join
endtask : main_phase

task dce_csr_diruuecr_errIntEn_reg_test::run_main(uvm_phase phase);
   bit transaction_finished = 0;
  <% var i = 0;
     obj.SnoopFilterInfo.forEach( function(snoop) {
	 if(snoop.fnFilterType == "TAGFILTER") {
		  %>
  logic [31:0] prev_single_bit_count<%=i%>;
  logic [31:0] prev_double_bit_count<%=i%>;
    <%    i++;
	}					  
      }); %>
  int exp_corr_err_info[$] = {};
  int exp_uncor_err_info[$] = {};

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

  phase.raise_objection(this, "Start dce_csr_diruuecr_errIntEn_reg_test run phase");
 
  test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
  test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;

  if(!uvm_config_db#(virtual dce_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif))
    `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
  //
  // Write to first 32 registers with all 1s to enable all features
  //
   <% if (has_ocp) { %>      
    wr_data = '0;
    wr_data[3:0] = 4'h0; //Opcode=Init All Entries
    wr_data[20:16] = 5'h0; //Snoop Filter Identifier
    reg_write( "DCEUSFMCR_SfMntOp", wr_data);
    reg_wait_for_value(32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
    wr_data = '0;
    wr_data[3:0] = 4'h0; //Opcode=Init All Entries
    wr_data[20:16] = 5'h1; //Snoop Filter Identifier
    reg_write( "DCEUSFMCR_SfMntOp", wr_data);
    reg_wait_for_value(32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
    wr_data = '1;
    reg_write( "DCEUSFER_SfEn", wr_data);
    reg_write( "DCEUCASER_CaSnpEn", wr_data, 0);
    reg_write( "DCEUCASER_CaSnpEn", wr_data, 1);
    reg_write( "DCEUCASER_CaSnpEn", wr_data, 2);
    reg_write( "DCEUCASER_CaSnpEn", wr_data, 3);
    reg_write( "DCEUMRHER_MrHntEn", wr_data);
    //reg_write( "DCEUCECR_ErrDetEn", wr_data);
    //reg_write( "DCEUCECR_ErrIntEn", wr_data);
    //reg_write( "DCEUUECR_ErrDetEn", wr_data);
    //reg_write( "DCEUUECR_ErrIntEn", wr_data);
    reg_write( "CSADSER_DvmSnpEn", wr_data, 0);
    reg_write( "CSADSER_DvmSnpEn", wr_data, 1);
    reg_write( "CSADSER_DvmSnpEn", wr_data, 2);
    reg_write( "CSADSER_DvmSnpEn", wr_data, 3);
//  csr_seq.start(m_env.ocp_master_agent.df_sequencer);
  #5us;
  `uvm_info(get_full_name(), "Finished activating all registers", UVM_LOW)
				  
<% } %>

<% if(has_ocp) { %>
    //*****************************************************************************
    // Delay for ocp vip reset de-asseretion  
    //*****************************************************************************
    
    #(176ns);
<% } %>


    m_env.m_sb.dce_scoreboard_enable = 0;

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
        `uvm_error("RUN_MAIN",$sformatf("Read Data:%b, Expected data :%b",rd_data[0],r_reset[0]));
     end
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

       errthd = 8'hFF;
       wr_data ={20'b0,errthd,4'b0};
       reg_name = "DCEUCECR_ErrThreshold";
       reg_rmwrite(reg_name,wr_data);
<% if(has_tagfilter) { %>
  fork
    begin
       //this watches for errstatus at error interrupt
       //only activate this ifthere's errors: TODO
	  while(~transaction_finished) begin
	     #5ns;
  <% var i = 0;
     var snoop_no = 0;
     obj.SnoopFilterInfo.forEach( function(snoop) {
	 if(snoop.fnFilterType == "TAGFILTER") {
		  %>
//	   $display("single bit error count = %0d", u_csr_probe_vif.single_bit_count<%=i%>);
//	   $display("double bit error count = %0d", u_csr_probe_vif.double_bit_count<%=i%>);
	<% if(snoop.StorageInfo.TagFilterErrorInfo.fnErrDetectCorrect != "SECDED") { %>
	  if((prev_single_bit_count<%=i%> != u_csr_probe_vif.single_bit_count<%=i%>) && (exp_uncor_err_info.size() == 0)) begin
		 exp_uncor_err_info.push_front(<%=snoop_no%>);
		 $display("exp_uncor_err_info = %p from bit_count = %d", exp_uncor_err_info, <%=i%>);
	  end
        <% } else { %>	      
	  if((u_csr_probe_vif.single_bit_count<%=i%> >= errthd) && (exp_corr_err_info.size() == 0)) begin
		    $display("exp_corr_err_info = %p", exp_corr_err_info);
		 exp_corr_err_info.push_front(<%=snoop_no%>);
	  end	    
        <% } %>	
	  if((prev_double_bit_count<%=i%> != u_csr_probe_vif.double_bit_count<%=i%>) && (exp_uncor_err_info.size() == 0)) begin
		 exp_uncor_err_info.push_front(<%=snoop_no%>);
		 $display("exp_uncor_err_info = %p from bit_count = %d", exp_uncor_err_info, <%=i%>);
	  end
          prev_single_bit_count<%=i%> = u_csr_probe_vif.single_bit_count<%=i%>;
          prev_double_bit_count<%=i%> = u_csr_probe_vif.double_bit_count<%=i%>;

    <%    i++;
	}
	snoop_no++;					   
      }); %>
       end // if (m_env.m_sb.m_csm.transactionPending())
    end // fork begin

     m_env.m_sb.dce_scoreboard_enable = 0; //disable the scoreboard //TO REMOVE THIS AFTER SCOREBOARD IS UPDATED
    begin
      repeat(1)
        begin

        //*****************************************************************************
        $display("%t DEBUG: wait for IRQ_C interrupt", $time);
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("waiting for Interrupt IRQ_C "), UVM_LOW)

         @(u_csr_probe_vif.IRQ_UC)
         begin
	 //m_env.m_sb.dce_scoreboard_enable = 0; //disable the scoreboard to stop further transactions
	 //m_env.m_sb.m_csm.m_str_uncor_err = 1; //set this bit high so that error tests
	    

        //*****************************************************************************
        $display("%t DEBUG: keep on Reading the DCEUUESR_ErrVld bit till it becomes 1", $time); 
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Keep Reading DCEUUESR_ErrVld   = 1 "), UVM_LOW)
          reg_name = "DCEUUESR_ErrVld";
          
          reg_wait_for_value(32'h00000001,reg_name,rd_data);

          if(rd_data[0] == 1)begin
           `uvm_info("RUN_MAIN",$sformatf("DCEUESR_ErrVld value :%b",rd_data[0]), UVM_LOW)
          end else begin
           `uvm_error("RUN_MAIN",$sformatf("DCEUESR_ErrVld value :%b",rd_data[0]));
          end
          if(rd_data[15:12] == 4'hC || rd_data[15:12] == 4'hD )begin
           `uvm_info("RUN_MAIN",$sformatf(" DCEUESR  error type :%x",rd_data[15:12]), UVM_LOW)
          end else begin
           `uvm_error("RUN_MAIN",$sformatf("DCEUESR  Not valid error type :%x",rd_data[15:12]));
          end
	    
        //*****************************************************************************
        $display("%t DEBUG: Read DCEUUESAR_ErrVld , it should be 1", $time);
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Read alias reg DCEUUESAR_ErrVld it should also be 1"), UVM_LOW)
          reg_name = "DCEUUESAR_ErrVld";
          reg_read(reg_name,rd_data);

          if(rd_data[0] == 1)begin
           `uvm_info("RUN_MAIN",$sformatf("DCEUESAR_ErrVld value :%b",rd_data[0]), UVM_LOW)
          end else begin
           `uvm_error("RUN_MAIN",$sformatf("DCEUESAR_ErrVld value :%b",rd_data[0]));
          end
          if(rd_data[15:12] == 4'hC || rd_data[15:12] == 4'hD )begin
           `uvm_info("RUN_MAIN",$sformatf(" DCEUESAR ESAR  error type :%x",rd_data[15:12]), UVM_LOW)
          end else begin
           `uvm_error("RUN_MAIN",$sformatf("DCEUESAR ESAR Not valid error type :%x",rd_data[15:12]));
          end
         //*****************************************************************************
         $display("%t DEBUG: Set the DCEUUECR_ErrDetEn = 0, to diable the error detection", $time);
         //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Setting DCEUUECR_ErrDetEn = 0 "), UVM_LOW)

          reg_name = "DCEUUECR_ErrDetEn";
//          reg_rmwrite(reg_name,32'h00000000);

         //*****************************************************************************
         $display("%t DEBUG: Set the DCEUUECR_ErrIntEn = 0, to diable the error Interrupt", $time);
         //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Setting DCEUUECR_ErrIntEn = 0 "), UVM_LOW)

          reg_name = "DCEUUECR_ErrIntEn";
          reg_rmwrite(reg_name,32'h00000000);

        //*****************************************************************************
        $display("%t DEBUG: Read DCEUUESR_ErrVld , it should be 1", $time);
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Read DCEUUESR_ErrVld "), UVM_LOW)
          reg_name = "DCEUUESR_ErrVld";
          reg_read(reg_name,rd_data);

          if(rd_data[0] == 1)begin
           `uvm_info("RUN_MAIN",$sformatf("DCEUESR_ErrVld value :%b",rd_data[0]), UVM_LOW)
          end else begin
           `uvm_error("RUN_MAIN",$sformatf("DCEUESR_ErrVld value :%b",rd_data[0]));
          end
          if(rd_data[15:12] == 4'hC || rd_data[15:12] == 4'hD )begin
           `uvm_info("RUN_MAIN",$sformatf(" DCEUESR  error type :%x",rd_data[15:12]), UVM_LOW)
          end else begin
           `uvm_error("RUN_MAIN",$sformatf("DCEUESR  Not valid error type :%x",rd_data[15:12]));
          end

        //*****************************************************************************
        $display("%t DEBUG: Read alias register DCEUUESAR_ErrVld , it should be 1", $time);
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Read DCEUUESAR_ErrVld "), UVM_LOW)
          reg_name = "DCEUUESAR_ErrVld";
          reg_read(reg_name,rd_data);

          if(rd_data[0] == 1)begin
           `uvm_info("RUN_MAIN",$sformatf("DCEUESAR_ErrVld value :%b",rd_data[0]), UVM_LOW)
          end else begin
           `uvm_error("RUN_MAIN",$sformatf("DCEUESAR_ErrVld value :%b",rd_data[0]));
          end
          if(rd_data[15:12] == 4'hC || rd_data[15:12] == 4'hD )begin
           `uvm_info("RUN_MAIN",$sformatf(" DCEUESAR ESAR  error type :%x",rd_data[15:12]), UVM_LOW)
          end else begin
           `uvm_error("RUN_MAIN",$sformatf("DCEUESAR ESAR Not valid error type :%x",rd_data[15:12]));
          end
        //*****************************************************************************
        $display("%t DEBUG: write  DCEUUESR_ErrVld = 1 , to reset it", $time);
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("write 1 on DCEUUESR_ErrVld to reset it "), UVM_LOW)
          reg_name = "DCEUUESR_ErrVld";
          reg_write(reg_name,32'h00000001);

        //*****************************************************************************
        $display("%t DEBUG: Read the DCEUUESR_ErrVld should be cleared", $time);
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Read DCEUUESER_ErrVld "), UVM_LOW)

          reg_name = "DCEUUESR_ErrVld";
          r_mask   = mask_data(reg_name);
          r_reset  = regs.reg_reset[reg_name];
          reg_read(reg_name,rd_data);
         
          if(rd_data[0] == 0)begin
            `uvm_info("RUN_MAIN",$sformatf("DCEUUESR_ErrVld bit cleared :%b",rd_data[0]), UVM_LOW)
          end else begin
            `uvm_error("RUN_MAIN",$sformatf("DCEUUESR_ErrVld bit not cleared Read Data:%b, Expected data :0",rd_data[0]));
          end

        //*****************************************************************************
        $display("%t DEBUG: Read DCEUUESAR_ErrVld , it should also clear, beacuse it is alias of register DCEUUESR_*", $time);
        //*****************************************************************************
         `uvm_info("RUN_MAIN",$sformatf("Read DCEUUESAR_ErrVld "), UVM_LOW)

          reg_name = "DCEUUESAR_ErrVld";
          reg_read(reg_name,rd_data);

          if(rd_data[0] == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("DCEUESAR_ErrVld value :%b",rd_data[0]), UVM_LOW)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("DCEUESAR_ErrVld value :%b",rd_data[0]));
          end

          //*****************************************************************************
          $display("%t DEBUG: Monitor IRQ_UC pin , it should be 0 now", $time);
          //*****************************************************************************

          if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asseretd"), UVM_LOW)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still aseerted"));
          end
         //*****************************************************************************
         $display("%t DEBUG: Set the DCEUUECR_ErrDetEn = 1", $time);
         //*****************************************************************************
          `uvm_info("RUN_MAIN",$sformatf("Setting DCEUUECR_ErrDetEn = 1 "), UVM_LOW)

          reg_name = "DCEUUECR_ErrDetEn";
          reg_rmwrite(reg_name,32'h00000001);

         //*****************************************************************************
         $display("%t DEBUG: Set the DCEUUECR_ErrIntEn = 1", $time);
         //*****************************************************************************
          `uvm_info("RUN_MAIN",$sformatf("Setting DCEUUECR_ErrIntEn = 1 "), UVM_LOW)

          reg_name = "DCEUUECR_ErrIntEn";
          reg_rmwrite(reg_name,32'h00000002);
        end
       end
      end
    begin
       test_seq.start(null);
       transaction_finished = 1;
    end
  join
<% } %>
  main_done = phase.get_objection();
  main_done.set_drain_time(null, 1us);


  phase.drop_objection(this, "Finish dce_csr_diruuecr_errIntEn_reg_test run phase");

endtask : run_main

////////////////////////////////////////////////////////////////////////////////

