////////////////////////////////////////////////////////////////////////////////
//
// DCE CSR Maintenance Operation Test
//
////////////////////////////////////////////////////////////////////////////////
class dce_csr_maint_simple_test extends dce_test_base;

   `uvm_component_utils(dce_csr_maint_simple_test)

   extern function new(string name = "dce_csr_maint_simple_test", uvm_component parent = null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual task main_phase(uvm_phase phase);
   extern virtual task run_main(uvm_phase phase);

endclass: dce_csr_maint_simple_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_csr_maint_simple_test::new(string name = "dce_csr_maint_simple_test", uvm_component parent = null);
   super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_csr_maint_simple_test::build_phase(uvm_phase phase);
   super.build_phase(phase);
endfunction : build_phase

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------
task dce_csr_maint_simple_test::main_phase(uvm_phase phase);
   fork
      run_main(phase);
      run_watchdog_timer(phase);
   join
endtask : main_phase

task dce_csr_maint_simple_test::run_main(uvm_phase phase);
   bit [5:0] word;
   int 	     f,s,w;
   int unsigned	     check_data;
   int unsigned check_data_arr[1000];
   int check_data_index;
   int car_val;
   
   
   uvm_objection main_done;
   dce_seq  test_seq = dce_seq::type_id::create("test_seq");

   <% if (obj.BLK_SNPS_OCP_VIP) { %>
				  csr_wr_seq  wr_seq = csr_wr_seq::type_id::create("wr_seq");
				  csr_rd_seq  rd_seq = csr_rd_seq::type_id::create("rd_seq");
				  ocp_master_directed_sequence  csr_seq = ocp_master_directed_sequence::type_id::create("csr_seq");
				  csr_seq.sequence_length = 32;
				  <% } %>

							    test_seq.m_csm = m_env.m_sb.m_csm;
   test_seq.m_gen = m_env.m_gen;

   test_seq.wt_cmd_rd_cpy      = wt_cmd_rd_cpy;
   test_seq.wt_cmd_rd_cln      = wt_cmd_rd_cln;
   test_seq.wt_cmd_rd_vld      = wt_cmd_rd_vld;
   test_seq.wt_cmd_rd_unq      = wt_cmd_rd_unq;
   test_seq.wt_cmd_cln_unq     = wt_cmd_cln_unq;
   test_seq.wt_cmd_cln_vld     = wt_cmd_cln_vld;
   test_seq.wt_cmd_cln_inv     = wt_cmd_cln_inv;
   test_seq.wt_cmd_wr_unq_ptl  = wt_cmd_wr_unq_ptl;
   test_seq.wt_cmd_wr_unq_full = wt_cmd_wr_unq_full;
   test_seq.wt_cmd_upd_inv     = wt_cmd_upd_inv;
   test_seq.wt_cmd_upd_vld     = wt_cmd_upd_vld;
   test_seq.wt_cmd_dvm_msg     = wt_cmd_dvm_msg;
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

   test_seq.k_force_req_aiu0   = k_force_req_aiu0;
   test_seq.k_init_rand_state  = k_init_rand_state;
   test_seq.k_num_cmd          = k_num_cmd;
   test_seq.k_num_addr         = k_num_addr;
   test_seq.k_hnt_rsp_delay    = k_hnt_rsp_delay;
   test_seq.k_mrd_rsp_delay    = k_mrd_rsp_delay;
   test_seq.k_snp_rsp_delay    = k_snp_rsp_delay;
   test_seq.k_str_rsp_delay    = k_str_rsp_delay;
   test_seq.k_security         = k_security;
   test_seq.k_priority         = k_priority;

   phase.raise_objection(this, "Start dce_csr_maint_simple_test run phase");

   <% if (obj.BLK_SNPS_OCP_VIP) { %>

  //
  // Write to first 32 registers with all 1s to enable all features
  //
  csr_seq.start(m_env.ocp_master_agent.df_sequencer);

  //
  // Snoop Filter 1 : nSets=4  nWays=4
  // Snoop Filter 2 : nSets=16 nWays=8
  //

  //
  // Write Entry at Index, Way, Word
  // Read Entry at Index, Way, Word
  //
			       
//WRITE TO ALL THE LOCATIONS FIRST
  f=0;
  word = 0;	
  check_data_index = 0;
  check_data_arr[check_data_index] = 32'h45454545;				  
  car_val = 1;
  s=2;
  w=3;
        wr_data[19:0] = s; //set index
        wr_data[25:20] = w; //way
        wr_data[31:26] = word;
        reg_write(wr_seq, "DCEUSFMLR0_MntWay", wr_data);
        check_data = check_data_arr[check_data_index];
        wr_data = check_data_arr[check_data_index];
        reg_write(wr_seq, "DCEUSFMDR_MntData", wr_data);	
        wr_data[20:16] = f; //Snoop Filter Identifier
//        reg_write(wr_seq, "DCEUSFMCR_Sfid", wr_data);					 
        wr_data[3:0] = 4'he; //Opcode=Write Entry at Index, Way, and Word
        reg_write(wr_seq, "DCEUSFMCR_SfMntOp", wr_data);
        #500ns;
     reg_wait_for_value(rd_seq,32'h00000000,"DCEUSFMAR_MntOpAct",rd_data);					 					 
	// do begin
	//  reg_read(rd_seq, "DCEUSFMAR_MntOpAct", car_val);
	//  end while(car_val != 0); // UNMATCHED !!
	//  car_val = 1;				 
        wr_data[20:16] = f; //Snoop Filter Identifier
        wr_data[3:0] = 4'hc; //Opcode=Read Entry at Index, Way, and Word
        reg_write(wr_seq, "DCEUSFMCR_SfMntOp", wr_data);
        #500ns;
     reg_wait_for_value(rd_seq,32'h00000000,"DCEUSFMAR_MntOpAct",rd_data);		
	// do begin
	//  reg_read(rd_seq, "DCEUSFMAR_MntOpAct", car_val);
	//  end while(car_val != 0); // UNMATCHED !!
	//  car_val = 1;				 
        reg_read (rd_seq, "DCEUSFMDR_MntData", rd_data );
	 #500ns;					 
	 $display("check_index is %d", check_data_index);		
        if (rd_data != check_data_arr[check_data_index]) begin
	`uvm_info(get_full_name(),$sformatf("THIS IS TEST STUFF: Read Entry at Index Way Word doesn't match Write Entry: rd_data=%x, wr_data=%x, set=%0d, way=%0d, word=%0d, sf=%0d", rd_data, check_data_arr[check_data_index], s, w, word, f), UVM_MEDIUM);
        end
        else begin
	`uvm_info(get_full_name(),$sformatf("THIS IS TEST STUFF: Read Entry at Index Way Word matches Write Entry: rd_data=%x, wr_data=%x, set=%0d, way=%0d, word=%0d sf=%0d", rd_data, check_data_arr[check_data_index], s, w, word, f), UVM_MEDIUM);
	 end
	 check_data_index++;


/*
  test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
  test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;
  test_seq.start(null);

  main_done = phase.get_objection();
  main_done.set_drain_time(null, 1us);
*/

<% } %>
  phase.drop_objection(this, "Finish dce_csr_maint_simple_test run phase");

endtask : run_main

////////////////////////////////////////////////////////////////////////////////

/*
 
 HERE'S THE BACKUP
 $display("check_data array is below");
  $display(check_data_arr);				  
//READ ALL THE LOCATIONS
f=0;
 check_data_index = 0;
  car_val = 1;				  
<% obj.SnoopFilterInfo.forEach( function(snoop) { %>	
    <%if(snoop.fnFilterType != "NULL") { %>			  
    for (int s=0; s < <%=snoop.StorageInfo.nSets%>; s++) begin
      for (int w=0; w < <%=snoop.StorageInfo.nWays%>; w++) begin
        wr_data[19:0] = s; //set index
        wr_data[25:20] = w; //way
        wr_data[31:26] = word;
        reg_write(wr_seq, "DCEUSFMLR0_MntWay", wr_data);
        check_data = check_data_arr[check_data_index];
        wr_data = check_data_arr[check_data_index];
        reg_write(wr_seq, "DCEUSFMDR_MntData", wr_data);	
        wr_data[20:16] = f; //Snoop Filter Identifier
//        reg_write(wr_seq, "DCEUSFMCR_Sfid", wr_data);					 
        wr_data[3:0] = 4'he; //Opcode=Write Entry at Index, Way, and Word
        reg_write(wr_seq, "DCEUSFMCR_SfMntOp", wr_data);
        #500ns;
     reg_wait_for_value(rd_seq,32'h00000000,"DCEUSFMAR_MntOpAct",rd_data);					 					 
	// do begin
	//  reg_read(rd_seq, "DCEUSFMAR_MntOpAct", car_val);
	//  end while(car_val != 0); // UNMATCHED !!
	//  car_val = 1;				 
        wr_data[20:16] = f; //Snoop Filter Identifier
        wr_data[3:0] = 4'hc; //Opcode=Read Entry at Index, Way, and Word
        reg_write(wr_seq, "DCEUSFMCR_SfMntOp", wr_data);
        #500ns;
     reg_wait_for_value(rd_seq,32'h00000000,"DCEUSFMAR_MntOpAct",rd_data);		
	// do begin
	//  reg_read(rd_seq, "DCEUSFMAR_MntOpAct", car_val);
	//  end while(car_val != 0); // UNMATCHED !!
	//  car_val = 1;				 
        reg_read (rd_seq, "DCEUSFMDR_MntData", rd_data );
	 #500ns;					 
	 $display("check_index is %d", check_data_index);		
        if (rd_data != (4'hc | (check_data_arr[check_data_index] & 12'hff0))) begin
	`uvm_info(get_full_name(),$sformatf("THIS IS TEST STUFF: Read Entry at Index Way Word doesn't match Write Entry: rd_data=%x, wr_data=%x, set=%0d, way=%0d, word=%0d, sf=%0d", rd_data, (4'hc | (check_data_arr[check_data_index] & 12'hff0)), s, w, word, f), UVM_MEDIUM);
        end
        else begin
	`uvm_info(get_full_name(),$sformatf("THIS IS TEST STUFF: Read Entry at Index Way Word matches Write Entry: rd_data=%x, wr_data=%x, set=%0d, way=%0d, word=%0d sf=%0d", rd_data, (4'hc | (check_data_arr[check_data_index] & 12'hff0)), s, w, word, f), UVM_MEDIUM);
	 end
	 check_data_index++;
 end
 end // for (int w=0; w < <%=snoop.StorageInfo.nWays%>; w++)
<% }%>						  
//  end
  f++;						  
<% }); %>
*/
