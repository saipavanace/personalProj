////////////////////////////////////////////////////////////////////////////////
//
// DCE CSR Maintenance Operation Test
//
////////////////////////////////////////////////////////////////////////////////
class dce_csr_maint_test_base extends dce_test_base;

   `uvm_component_utils(dce_csr_maint_test_base)
     
   int   sf_sets[<%=obj.SnoopFilterInfo.length%>];
   int 	 sf_ways[<%=obj.SnoopFilterInfo.length%>];   

//   bit [<%=obj.wSfiAddr - 1%>:0] wr_data[$]
//   bit [<%=obj.wSfiAddr - 1%>:0] rd_data[$]				 
   extern function new(string name = "dce_csr_maint_test_base", uvm_component parent = null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual task init_regs();
   extern virtual task maint_write_all_entries();
   extern virtual task maint_read_all_entries();   
//   extern virtual task run_main(uvm_phase phase);
//   extern virtual task main_phase(uvm_phase phase);
   
//   extern virtual task maint_write_to_all(int filter_no);
endclass: dce_csr_maint_test_base

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_csr_maint_test_base::new(string name = "dce_csr_maint_test_base", uvm_component parent = null);
   super.new(name, parent);

   // Get sets and ways for each snoop filter
   <% var filter_no = 0;
      obj.SnoopFilterInfo.forEach( function(snoop) { %>	
         <%if(snoop.fnFilterType != "NULL") { %>
	   sf_sets[<%=filter_no%>] = <%=snoop.StorageInfo.nSets%>;
	   sf_ways[<%=filter_no%>] = <%=snoop.StorageInfo.nWays%>;
       <% } else {%>
	   sf_sets[<%=filter_no%>] = 0;
	   sf_ways[<%=filter_no%>] = 0;
       <% } %>
     <% filter_no++;
       }); %>
      
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_csr_maint_test_base::build_phase(uvm_phase phase);
   super.build_phase(phase);
endfunction : build_phase

//------------------------------------------------------------------------------
// Write all entries
//------------------------------------------------------------------------------

task dce_csr_maint_test_base::maint_write_all_entries();
   longint check_data;
   int 	   check_data_index = 0;
   int 	   cur_word;
   int 	   cur_word_width;
   
   for(int f = 0; f < <%=obj.SnoopFilterInfo.length%>; f++) begin
      for(int s=0; s < sf_sets[f]; s++) begin
	 for(int w=0; w < sf_ways[f]; w++) begin
	  cur_word = 0;			  
	  cur_word_width = sf_memWidth[f];
	  if(cur_word_width > 0) begin
              maint_temp_data = maint_wr_data[check_data_index];
	     $display("Writing %0h to index %0d way %0d", maint_temp_data, s, w);
	     
	     maint_wait_inactive();
	      maint_write_entry(s,w,f,maint_temp_data);
	      check_data_index++;				  
	  end
         end
      end
   end // for (int f = 0; f < <%=obj.SnoopFilterInfo.length%>; f++)
   
endtask // maint_write_all_entries


//------------------------------------------------------------------------------
// Read all entries
//------------------------------------------------------------------------------

task dce_csr_maint_test_base::maint_read_all_entries();
   longint check_data;
   int 	   check_data_index = 0;
   int 	   cur_word;
   int 	   cur_word_width;
   
   for(int f = 0; f < <%=obj.SnoopFilterInfo.length%>; f++) begin
      for(int s=0; s < sf_sets[f]; s++) begin
	 for(int w=0; w < sf_ways[f]; w++) begin
	  cur_word = 0;			  
	  cur_word_width = sf_memWidth[f];
	  if(cur_word_width > 0) begin			  
	     maint_wait_inactive();
	     maint_read_entry(s,w,f,maint_temp_data);
	     `uvm_info(get_full_name(), $sformatf("Reading %0h from index %0d way %0d", maint_temp_data, s, w), UVM_HIGH)
	     maint_rd_data.push_back(maint_temp_data);
	     check_data_index++;
	  end
         end
      end
   end // for (int f = 0; f < <%=obj.SnoopFilterInfo.length%>; f++)
   
endtask // maint_write_all_entries
   
//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------

task dce_csr_maint_test_base::init_regs();
   bit [5:0] word;
   int 	     f;
   int unsigned	     check_data;
   int unsigned check_data_arr[1000];
   int check_data_index;
   int car_val;

   uvm_objection main_done;
   dce_seq  test_seq = dce_seq::type_id::create("test_seq");
   $display("DEBUG: initializing registers");
   
  //
  // Write to first 32 registers with all 1s to enable all features
  //
   <%obj.SnoopFilterInfo.forEach( function(snoop,cur_filter_no) { %>	  
	<%if(snoop.fnFilterType	== "TAGFILTER") { %>
	  maint_wait_inactive();
	  maint_start_op(4'h0, <%=cur_filter_no%>);
	  #500ns;
	<% } %>					  
   <% }); %>
      maint_wait_inactive();
/*
    reg_wait_for_value(32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
    wr_data = '0;
    wr_data[3:0] = 4'h0; //Opcode=Init All Entries
    wr_data[20:16] = 5'h0; //Snoop Filter Identifier
    reg_write("DCEUSFMCR_SfMntOp", wr_data);
    reg_wait_for_value(32'h00000000,"DCEUSFMAR_MntOpActv",rd_data);
    wr_data = '0;
    wr_data[3:0] = 4'h0; //Opcode=Init All Entries
    wr_data[20:16] = 5'h1; //Snoop Filter Identifier
    reg_write("DCEUSFMCR_SfMntOp", wr_data);
    reg_wait_for_value(32'h00000000,"DCEUSFMAR_MntOpActv",rd_data); */
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
  #5us;
  `uvm_info(get_full_name(), "Finished activating all registers", UVM_LOW)
  while (m_env.m_sb.m_csm.transactionPending()) begin #1us; end;
endtask : init_regs

////////////////////////////////////////////////////////////////////////////////

