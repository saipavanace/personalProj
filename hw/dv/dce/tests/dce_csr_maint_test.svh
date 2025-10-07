////////////////////////////////////////////////////////////////////////////////
//
// DCE CSR Maintenance Operation Test
//
////////////////////////////////////////////////////////////////////////////////
<% var has_ocp = 0;
  if(obj.BLK_SNPS_OCP_VIP)
    has_ocp = 1;
  if(obj.INHOUSE_OCP_VIP)
    has_ocp = 1;
	      
  %>


class dce_csr_maint_random_obj;

   int wt_maint_recall_all;
   int wt_maint_recall_addrs;
   int wt_maint_recall_loc;
   int wt_maint_recall_vb;
   int wt_maint_recall_vctb;
   int wt_inj_cor_err;
   int wt_inj_uncor_err;
   
   typedef enum int {
       COR_ERR, UNCOR_ERR} err_type_t;
   
   rand int maint_xact_type;
   rand int filter_no;
   rand err_type_t err_type;

   <% 
     var tag_filter_string = "";
     var filter_no = 0;
   
     obj.SnoopFilterInfo.forEach( function(snoop) {
	if(snoop.fnFilterType == "TAGFILTER") {
	  if(filter_no > 0)
	     tag_filter_string += ',';			       
	  tag_filter_string += filter_no;
	}				   
	filter_no++;					   
     });
   %>   

    constraint c {
        maint_xact_type dist {
            0 :/ wt_maint_recall_all,
            1 :/ wt_maint_recall_addrs,
            2 :/ wt_maint_recall_loc,
            3 :/ wt_maint_recall_vctb
        };
        filter_no inside {[0:(ncoreConfigInfo::snoop_filters_info.size() -1)]};
    }

    constraint c_err_type {
        err_type dist {
            0 :/ wt_inj_cor_err,
            1 :/ wt_inj_uncor_err
        };
    }

   function new();
      maint_xact_type = 0;
      set_weights();
   endfunction: new

   function void set_weights(
       int wt_maint_all     = 5,
       int wt_maint_addr    = 40,
       int wt_maint_set_way = 40,
       int wt_maint_vctb    = 15,
       int wt_inj_cor_err   = 50,
       int wt_inj_uncor_err = 50);

       wt_maint_recall_all   = wt_maint_all;
       wt_maint_recall_addrs = wt_maint_addr;
       wt_maint_recall_loc   = wt_maint_set_way;
       wt_maint_recall_vctb  = wt_maint_vctb;
       this.wt_inj_cor_err   = wt_inj_cor_err;
       this.wt_inj_uncor_err = wt_inj_uncor_err;
   endfunction: set_weights

endclass // dce_csr_maint_random_obj

typedef <%=obj.BlockId + '_con'%>::cacheAddress_t cachelines_q[$];

class dce_csr_maint_test extends dce_csr_maint_test_base;


   dce_seq  test_seq;


   `uvm_component_utils(dce_csr_maint_test)
   longint unsigned check_data_arr[10000];
//   bit [<%=obj.wSfiAddr-1%>:0] unsigned check_data_arr[$];
   <%=obj.BlockId%>_con::cacheAddress_t m_expected_addrs[int];
  static <%=obj.BlockId + '_con'%>::cacheAddress_t CACHE_ADDR_MASK;

   int 	   num_expected_addresses;
   bit test_active;
   extern function new(string name = "dce_csr_maint_test", uvm_component parent = null);
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual task run_phase(uvm_phase phase);
   extern virtual task run_main(uvm_phase phase);
//   extern virtual task maint_write_all_entries();
//   extern virtual task maint_read_all_entries();
   extern virtual task generate_traffic(int wait_for_end = 1, output dce_seq test_seq);

   extern virtual task generate_directed_traffic();
   extern virtual function void get_set_index_way_for_cor_err(int sf_index, 
       output int sf_entry,
       output int sf_way);

   extern virtual task populate_recall_check();
   extern virtual task populate_recall_check_from_csm();         
endclass: dce_csr_maint_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_csr_maint_test::new(string name = "dce_csr_maint_test", uvm_component parent = null);
   super.new(name, parent);
  regs = new();
   CACHE_ADDR_MASK = <%=obj.BlockId + '_con'%>::makeCacheAddressMask();   
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_csr_maint_test::build_phase(uvm_phase phase);
   super.build_phase(phase);
endfunction : build_phase

//------------------------------------------------------------------------------
// Write all entries
//------------------------------------------------------------------------------

task dce_csr_maint_test::populate_recall_check();
   int cur_index = 0;
   int rand_num;
   
   num_expected_addresses = 0;
   
   <% var sfinfo = obj.SnoopFilterInfo;
var all_addrs = [];
sfinfo.forEach( function(snoop) {
    if(snoop.fnFilterType == "TAGFILTER") {
	var select_bits = snoop.StorageInfo.SetSelectInfo.SelectBits;
	var hash_bits = snoop.StorageInfo.SetSelectInfo.HashBits; 	
	var set_addrs = [];	
	for(var i=0; i < snoop.StorageInfo.nSets; i++) {
	    var set_addr_mask = 0;
	    var set_addr = 0;
	    var set_addr_bits = Math.abs(Math.pow(2,6) * Math.ceil(Math.random() * Math.pow(2,(Math.ceil(obj.DceInfo.Derived.wSfiAddr - 6))))); 
            //set base address
	    var k=0;
	    select_bits.forEach( function( select_bit ) {
		set_addr = set_addr | (((i >>> k) & 1) << select_bit); //take the kth bit of the index
		set_addr_mask = set_addr_mask | (1 << select_bit); //take the kth bit of the index							 
		if(hash_bits.length > 0) {
		    set_addr_mask = set_addr_mask ^ (~(1 << hash_bits[k]));//FIXME
		}
		set_addr_mask = ~set_addr_mask; //turn 1's into 0's
		set_addr = Math.abs((set_addr_bits & set_addr_mask) | set_addr);
		k++;			   
	    }); %>
	m_expected_addrs[cur_index] = <%=set_addr%>;
	cur_index++;						
	num_expected_addresses++;						
<%	}
    }
}); %>

endtask // populate_recall_check

//------------------------------------------------------------------------------
// Populate the recall check array for the dce_maint_recall_checker
//------------------------------------------------------------------------------
task dce_csr_maint_test::populate_recall_check_from_csm();
   <%=obj.BlockId%>_con::cacheAddress_t sfi_addr;   
   num_expected_addresses = 0;
   foreach(m_env.m_sb.m_csm.m_coh_req_pending[cache_addr]) begin
      sfi_addr = cache_addr[(<%=obj.BlockId + '_con'%>::SecureCacheAddrLsb)-1:0];
      if(m_env.m_sb.m_csm.dce_directory.c_active_owner_vector[cache_addr & CACHE_ADDR_MASK] > 0) begin
	 //m_env.m_maint_recall_checker.m_expected_addrs[sfi_addr] = sfi_addr;
	 num_expected_addresses++;
      end
      
   end
/*  foreach(m_env.m_sb.m_csm.m_aiu_state[aiu]) begin
    foreach(m_env.m_sb.m_csm.m_aiu_state[aiu][cache_addr]) begin
       m_env.m_maint_recall_checker.m_expected_addrs[cache_addr] = cache_addr;
    end
  end */
endtask // populate_recall_check_from_csm

//Sends less number of coherent transactions and is a blocking task
task dce_csr_maint_test::generate_directed_traffic();
   test_seq = dce_seq::type_id::create("test_seq");
   test_seq.m_csm = m_env.m_sb.m_csm;
   test_seq.m_gen = m_env.m_gen;
   test_seq.m_dirm_mgr = m_env.m_dirm_mgr;

   test_seq.wt_cmd_rd_cpy             = 5;
   test_seq.wt_cmd_rd_cln             = 15;
   test_seq.wt_cmd_rd_vld             = 15;
   test_seq.wt_cmd_rd_unq             = 15;
   test_seq.wt_cmd_cln_unq            = 15;
   test_seq.wt_cmd_cln_vld            = 5;
   test_seq.wt_cmd_cln_inv            = 5;
   test_seq.wt_cmd_wr_unq_ptl         = 5;
   test_seq.wt_cmd_wr_unq_full        = 5;
   test_seq.wt_cmd_upd_inv            = 5;
   test_seq.wt_cmd_dvm_msg            = 10;

   test_seq.k_num_cmd          = 10000;
   test_seq.k_num_addr         = get_dirm_entries_cnt();
   test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
   test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;
   test_seq.start(null);

endtask: generate_directed_traffic

function void dce_csr_maint_test::get_set_index_way_for_cor_err(
    int sf_index,
    output int sf_entry,
    output int sf_way);

    bit [31:0] all_entries[$];
    int all_ways[$];
    int indx;
    cachelines_q addr_list;

    m_env.m_dirm_mgr.get_valid_entries_info(sf_index, all_entries, all_ways, addr_list);

    if(all_entries.size() ==0)
        `uvm_error("dce_test", "Thre are'nt any sf_entry/ways filled")

    indx = $urandom_range(0, all_entries.size() - 1);
    if(!$cast(sf_entry, all_entries[indx]))
        `uvm_fatal("dce_test", "cast failed")
    sf_way = all_ways[indx];

endfunction: get_set_index_way_for_cor_err


//------------------------------------------------------------------------------
// Generate coherent traffic to fill dirm
//------------------------------------------------------------------------------
task dce_csr_maint_test::generate_traffic(int wait_for_end = 1, output dce_seq test_seq);
   test_seq = dce_seq::type_id::create("test_seq");
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

   test_seq.k_num_cmd          = $urandom_range(80000, 100000);
   test_seq.k_num_addr         = get_dirm_entries_cnt() * $urandom_range(1,4);


//Populate SnoopFilter Tables
  test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
  test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;

  if(wait_for_end > 0) begin
      test_seq.test_type = "wr_test";

      fork
          //Thread 1 launches sfi_master/slave seq
          begin
              test_seq.start(null);
              `uvm_info(get_full_name(), "Thread-1 released", UVM_LOW)
          end

          //Thread 2 waits until master seq is halted and then 
          //performs maint rd/wr
          begin
              #10ns;
              test_seq.mas_seq.wait_until_master_seq_halted();

              //Wait untill all AttIds are processed
              wait_for_dirutar_reg_inactive();

              `uvm_info(get_full_name(), "reading all entries", UVM_LOW)
              maint_read_all_entries();
              for(int check_data_index = 0; check_data_index < maint_rd_data.size(); check_data_index++) begin
                 maint_wr_data.push_back(maint_rd_data[check_data_index]);
              end
                  		  
              `uvm_info(get_full_name(), "inserting maintenance init_all", UVM_LOW)

             //Initialize all snoopfilters
<%
var cur_filter_no = 0;
obj.SnoopFilterInfo.forEach( function(snoop) { %>	  
              maint_wait_inactive();
              maint_start_op(4'h0, <%=cur_filter_no%>);
              #500ns;
<%
cur_filter_no++;
});
%>
              `uvm_info(get_full_name(), "write back all entries", UVM_LOW)
              maint_write_all_entries();

              //resume sequence. There should be no failures
              `uvm_info(get_full_name(), "resuming sequence", UVM_LOW)
              test_seq.mas_seq.release_master_seq();
              `uvm_info(get_full_name(), "Thread-2 released", UVM_LOW)
          end 
      join

   end else begin
       test_seq.start(null);
   end
  
endtask // generate_traffic

//------------------------------------------------------------------------------
// Run Phase
//------------------------------------------------------------------------------
task dce_csr_maint_test::run_phase(uvm_phase phase);
   fork
      this.run_main(phase);
      run_watchdog_timer(phase);
   join
endtask : run_phase

task dce_csr_maint_test::run_main(uvm_phase phase);
   
   bit [5:0] word;
   int 	     f,s,w,cur_word,cur_word_width;
   longint unsigned	     check_data;
   <%=obj.BlockId%>_con::cacheAddress_t sfi_addr;           

   int check_data_index;
   int car_val;
   int filter_no,i;
   string maint_test_type;
   string arg_value;
   uvm_objection main_done;
   dce_csr_maint_random_obj rand_obj;
   int 	  sf_nSets[int];
   int 	  sf_nWays[int];
   cachelines_q addr_list;
   

   test_seq = dce_seq::type_id::create("test_seq");
   phase.raise_objection(this, "Start dce_csr_maint_test run phase"); 

   init_regs();

   <% if (has_ocp) { %>

  if (clp.get_arg_value("+maint_test_type=", arg_value)) begin
    maint_test_type = arg_value;
  end else begin
    $error("test type not defined!");
  end
				  
  if(maint_test_type == "wr_test") begin

				  
   //*****************************************************
   //      READ AND WRITE ALL ENTRIES
   //*****************************************************		
    generate_traffic(1,test_seq);

   end
   else if(maint_test_type == "recall_locs") begin
   //*****************************************************	
   //      RECALL ALL ENTRIES BY LOCATION
   //*****************************************************	
//    populate_recall_check();
//    maint_write_all_entries_addrs();				  

    generate_traffic(0,test_seq);
    while (m_env.m_sb.m_csm.transactionPending()) begin #1us; end;
  num_expected_addresses = 0;					  
   foreach(m_env.m_sb.m_csm.m_coh_req_pending[cache_addr]) begin
       if(m_env.m_sb.m_csm.dce_directory.c_active_owner_vector[cache_addr & CACHE_ADDR_MASK] > 0) begin
         sfi_addr = cache_addr[(<%=obj.BlockId + '_con'%>::SecureCacheAddrLsb)-1:0];
	 //m_env.m_maint_recall_checker.m_expected_addrs[sfi_addr] = sfi_addr;
	 m_expected_addrs[num_expected_addresses] = sfi_addr;			  
	 num_expected_addresses++;
      end
     end
    m_env.m_sb.dce_scoreboard_enable = 0;
    check_data_index = 0;			  
    //m_env.m_maint_recall_checker.m_checker_active = 1;
    <%var cur_filter_no = 0 %>
     f=0;				  
    <% obj.SnoopFilterInfo.forEach( function(snoop) { %>	
       <%if(snoop.fnFilterType != "NULL") { %>			  
          for (int s=0; s < <%=snoop.StorageInfo.nSets%>; s++) begin
            for (int w=0; w < <%=snoop.StorageInfo.nWays%>; w++) begin
	        maint_write_loc(s,w,0); //0 for word because it doesn't matter for recall locs
                maint_start_op(4'h5, f);
		maint_wait_inactive();
         	#500ns;
            end
          end // for (int s=0; s < <%=snoop.StorageInfo.nSets%>; s++)
       <% }%>
       f++;						  
   <% }); %>
   end
   else if(maint_test_type == "recall_addrs") begin
   //*****************************************************		
   //      RECALL ALL ENTRIES BY ADDRESS
   //*****************************************************	

    generate_traffic(0,test_seq);
    while (m_env.m_sb.m_csm.transactionPending()) begin #1us; end;
  num_expected_addresses = 0;				  
   foreach(m_env.m_sb.m_csm.m_coh_req_completion[cache_addr]) begin
      if((m_env.m_sb.m_csm.dce_directory.c_active_sharer_vector[cache_addr & CACHE_ADDR_MASK] > 0) || (m_env.m_sb.m_csm.dce_directory.c_active_owner_vector[cache_addr & CACHE_ADDR_MASK] > 0)) begin
         sfi_addr = cache_addr[(<%=obj.BlockId + '_con'%>::SecureCacheAddrLsb)-1:0];
	 //m_env.m_maint_recall_checker.m_expected_addrs[cache_addr & CACHE_ADDR_MASK] = cache_addr & CACHE_ADDR_MASK;
	 m_expected_addrs[num_expected_addresses] = cache_addr & CACHE_ADDR_MASK;
	  $display("num_expected_addresses = %d", num_expected_addresses);		
	 num_expected_addresses++;
      end
     end

    m_env.m_sb.dce_scoreboard_enable = 1;
    //FIXME add translation from check entry to check addresses		
    check_data_index = 0;			  
    //m_env.m_maint_recall_checker.m_checker_active = 1;
  #1us;
  $display("num_expected_addresses = %d", num_expected_addresses);
  for(int filter_no=0; filter_no < <%=obj.SnoopFilterInfo.length%>; filter_no++) begin
    for(int i = 0;i < num_expected_addresses;i++) begin
        sfi_addr = m_expected_addrs[i][(<%=obj.BlockId + '_con'%>::SecureCacheAddrLsb)-1:0];
	$display("writing expected addr 0x%0h for filter %d", sfi_addr, filter_no);

	maint_write_addr(sfi_addr >> 6);
	$display("DEBUG: sfi_addr >> 6 = 0x%0h", sfi_addr >> 6);
	maint_start_op(4'h6, filter_no, m_expected_addrs[i] >> <%=obj.BlockId + '_con'%>::SecureCacheAddrLsb);
	maint_wait_inactive();
    end
  end
   end
   else if(maint_test_type == "wr_check_bits_test") begin
   //*****************************************************	
   //      WRITE TO ALL THE LOCATIONS FIRST
   //*****************************************************	
				  
    check_data_index = 0;
    car_val = 1;
   $display("nSnoopFilters = %d",<%=obj.SnoopFilterInfo.length%>);
    for(int f = 0; f < <%=obj.SnoopFilterInfo.length%>; f++) begin
      for (int s=0; s < sf_sets[f]; s++) begin
        for (int w=0; w < sf_ways[f]; w++) begin
	  cur_word = 0;			  
	  cur_word_width = sf_memWidth[f];			  
	  while(cur_word_width > 0) begin			  
            check_data = $random & 1'h1;
	    check_data_arr[check_data_index] = check_data;	
            wr_data = check_data;
	    maint_write_check_bits(s,w,word,f,wr_data);
	    check_data_index++;
	    cur_word_width = cur_word_width - 32;
	    cur_word++;			  
	  end			  
        end
      end
    end

   //*****************************************************			       
   //      READ FROM ALL LOCATIONS
   //*****************************************************			          
      
    check_data_index = 0;
    car_val = 1;
    for(int f = 0; f < <%=obj.SnoopFilterInfo.length%>; f++) begin
      for (int s=0; s < sf_sets[f]; s++) begin
        for (int w=0; w < sf_ways[f]; w++) begin
	  cur_word = 0;			  
	  cur_word_width = sf_memWidth[f];			  
	  while(cur_word_width > 0) begin			  
	   maint_read_check_bits(s,w,word,f,rd_data);
           #500ns;
	   $display("Check data for filter %0d", f);			  
	   maint_check_check_bits(s,w,word,f,rd_data, check_data_arr[check_data_index]);
	   check_data_index++;
	   cur_word_width = cur_word_width - 32;
	   cur_word++;			  				  
	  end			  
	end
      end
    end
   end

   else if(maint_test_type == "init_all") begin

   //*****************************************************			       
   //      INIT ALL ENTRIES
   //*****************************************************			       

   generate_traffic(0,test_seq);				  
   //populate check data with zeros				  
   for(int f = 0; f < <%=obj.SnoopFilterInfo.length%>; f++) begin
     for (int s=0; s < sf_sets[f]; s++) begin
       for (int w=0; w < sf_ways[f]; w++) begin
         check_data_arr[check_data_index] = 0;
         end			  
       end
   end

   //Initialize all snoopfilters				  
   <%var cur_filter_no = 0;
    obj.SnoopFilterInfo.forEach( function(snoop) { %>	  
      maint_start_op(4'h0, <%=cur_filter_no%>);
      #500ns;
   <% cur_filter_no++;
   }); %>

  maint_wait_inactive();
//FIXME populate this with 0's
  //m_env.m_maint_recall_checker.m_checker_active = 1;
  //m_env.m_maint_recall_checker.init_all_check = 1;
   <%var cur_filter_no = 0;
    obj.SnoopFilterInfo.forEach( function(snoop) { %>	
      maint_start_op(4'h4, <%=cur_filter_no%>);
      #500ns;
   <% cur_filter_no++;
   }); %>					   
				  
   //*****************************************************
   //      RECALL ALL ENTRIES
   //*****************************************************
   end else if(maint_test_type == "recall_all") begin

       generate_traffic(0,test_seq);

       foreach(ncoreConfigInfo::snoop_filters_info[ridx]) begin
           phase.raise_objection(this, "Start recall op"); 
           maint_start_op(4'h4, ridx);
           #500ns;
           maint_wait_inactive();
           phase.drop_objection(this, "Start recall op");
       end
  
   end else if(maint_test_type == "recall_vctb") begin
       int m_sfid;
       fork
           begin
               test_active = 1'b1;
               generate_traffic(0,test_seq);
               test_active = 1'b0;
           end
           begin
               #10000ns;
               while(test_active) begin
                   m_sfid = $urandom_range(0, (ncoreConfigInfo::snoop_filters_info.size() -1));
                   phase.raise_objection(this, "Start recall op"); 
                   maint_start_op(4'h8, m_sfid);
                   maint_wait_inactive();
                   phase.drop_objection(this, "Stop recall op");
               end
           end
       join_any
   end
   //Test starts of coherent transactions and waits until its done
   //Then injects single bit error by perfroming maint rd/wr operations
   //And then does an maint recall index/way for that address.
   else if(maint_test_type == "directed_cor_err_test") begin
       int sf_entry;
       int sf_way;
       int secded_sf[$];
       int sf_index;
<%
    obj.SnoopFilterInfo.forEach(function(bundle, indx, array) {
        if(bundle.fnFilterType === "TAGFILTER") {
            if(bundle.StorageInfo.TagFilterErrorInfo.fnErrDetectCorrect === "SECDED") {
%>
                secded_sf.push_back(<%=indx%>);
<%
            }
        }
    });
%>
       if(secded_sf.size() == 0)
          `uvm_error("dce_test", "None of the snoopp filters have secded memory")

       sf_index = $urandom_range(0, (secded_sf.size() - 1));

       phase.raise_objection(this, "Start recall op"); 
       `uvm_info("dce_test", "coherent traffic is initiated", UVM_NONE)
       generate_directed_traffic();
       //polling dirutar register until processing all traffic is done
       wait_for_dirutar_reg_inactive();
       `uvm_info("dce_test", "coherent traffic is all driven", UVM_NONE)
       
       //pick set_insex/way for error injection
       get_set_index_way_for_cor_err(sf_index, sf_entry, sf_way);
       `uvm_info("dce_test", $psprintf("selected sf_index:%0d sf_entry:%0d sf_way:%0d",
                            sf_index, sf_entry, sf_way), UVM_MEDIUM)
       
       maint_wait_inactive();
       maint_read_entry(sf_entry, sf_way, sf_index, maint_temp_data);
       `uvm_info("dce_test", $psprintf("maint read:0x%0h", maint_temp_data), UVM_MEDIUM)

       //Write back corrupted data
       maint_temp_data[0] = ~maint_temp_data[0];
       maint_wait_inactive();
       maint_write_entry(sf_entry, sf_way, sf_index, maint_temp_data);
       `uvm_info("dce_test", $psprintf("maint write:0x%0h corrupted data", maint_temp_data), UVM_MEDIUM)
       
       maint_wait_inactive();
       //Initiating maint index way to the corrupted location
       maint_write_loc(sf_entry, sf_way, 0); //0 for word because it doesn't matter for recall locs
       maint_start_op(4'h5, sf_index);
       maint_wait_inactive();
       phase.drop_objection(this, "Stop recall op");
   end
   else if(maint_test_type == "random_test") begin
      fork 
          begin		  
              test_active = 1;
              `uvm_info("MAINT_TEST", "Traffic active", UVM_MEDIUM)
              test_seq = dce_seq::type_id::create("test_seq");  
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

              test_seq.k_num_cmd          = $urandom_range(80000, 100000);

              test_seq.k_num_addr         = get_dirm_entries_cnt() * $urandom_range(1,4);
              test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
              test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;
              test_seq.start(null);

              `uvm_info("MAINT_TEST", "Traffic inactive", UVM_MEDIUM)
              test_active = 0;			  
          end
          begin
              $display("testing start");
              rand_obj = new();			  
              `uvm_info(get_full_name(),"start inserting maintenance operations", UVM_LOW)

              #500ns;

              while(test_active) begin
                  rand_obj.randomize();	
                  filter_no = rand_obj.filter_no;

                  case(rand_obj.maint_xact_type)			  
                      0 : begin
                      	  `uvm_info(get_full_name(),$sformatf("inserting recall all for filter %0d",filter_no), UVM_MEDIUM);
                          phase.raise_objection(this, "Start recall op"); 
                      	  maint_start_op(4'h4, filter_no);
                      	  maint_wait_inactive();
                          phase.drop_objection(this, "Stop recall op");
                      end		  
                      1 : begin
                                   int agent_ids[$];
                                   int req_aiu;
                                   int idx;
                                   bit fail;
                                   <%=obj.BlockId + '_con'%>::cacheAddress_t m_addr_list[$];
                                   <%=obj.BlockId + '_con'%>::cacheAddress_t m_cacheline;

                                   foreach(ncoreConfigInfo::inf[ridx]) begin
                                       if(ncoreConfigInfo::inf[ridx] != 1) 
                                           agent_ids.push_back(ncoreConfigInfo::inf[ridx]);
                                   end

                                   idx = $urandom_range(0, (agent_ids.size() -1));
                                   req_aiu = agent_ids[0];
                                   randcase
                                       40: m_env.m_dirm_mgr.get_reqaiu_valid_tagf_cachelines(req_aiu, m_addr_list);
                                       40: m_env.m_dirm_mgr.get_reqaiu_valid_vctb_cachelines(req_aiu, m_addr_list);
                                       20: m_env.m_dirm_mgr.get_reqaiu_invalid_cachelines(req_aiu, m_addr_list);
                                   endcase

                                   if(m_addr_list.size() > 0) begin
                                       idx = $urandom_range(0, (m_addr_list.size()-1));
                                       m_cacheline = m_addr_list[idx];
                                   end else begin
                                       ace_cache_line_model m_addr;
                                       addr_gen_helper m_helper;

                                       m_addr = new("cache_line");
                                       m_helper = new("helper");
 
                                       m_addr.assign_helper(m_helper);
                                       m_addr.gen_cacheline(req_aiu);
                                       m_cacheline = m_addr.get_cacheline();
                                   end

                          phase.raise_objection(this, "Start recall op"); 
                      	  maint_write_addr(m_cacheline >> 6);
                      	  maint_start_op(4'h6, filter_no, m_cacheline >> <%=obj.BlockId + '_con'%>::SecureCacheAddrLsb);
                      	  maint_wait_inactive();
                          phase.drop_objection(this, "Stop recall op");
                      end		  
                      2 : begin
                                   bit [31:0] set_indexes_q[$];
                                   int ways_q[$];
                                   int idx;

                                   randcase
                                       95: begin
                                           m_env.m_dirm_mgr.get_valid_entries_info(filter_no, set_indexes_q, ways_q, addr_list);
                                           idx = $urandom_range(0, (ways_q.size() -1));
                      	          s = set_indexes_q[idx];
                      	          w = ways_q[idx];
                                           end

                                        5: begin
                      	          s = $urandom_range(0, (ncoreConfigInfo::snoop_filters_info[filter_no].num_sets -1));
                      	          w = $urandom_range(0, (ncoreConfigInfo::snoop_filters_info[filter_no].num_ways -1));
                                           end
                                   endcase

                      	  f = filter_no;	  
                      	  `uvm_info(get_full_name(),$sformatf("inserting recall for loc for set= %0d,way = %0d for filter %d", s,w, filter_no),UVM_MEDIUM);
                          phase.raise_objection(this, "Start recall op"); 
                      	  maint_write_loc(s,w,0); //0 for word because it doesn't matter for recall locs
                      	  maint_start_op(4'h5, f);
                      	  maint_wait_inactive();
                          phase.drop_objection(this, "Stop recall op");
                      end		  
                      3 : begin
                      	  `uvm_info(get_full_name(),$sformatf("inserting recall victim buffer for filter %0d",filter_no), UVM_MEDIUM);
                          phase.raise_objection(this, "Start recall op"); 
                      	  maint_start_op(4'h8, filter_no);
                      	  maint_wait_inactive();
                          phase.drop_objection(this, "Stop recall op");
                      end		  
                  endcase	
              end				 
          end
      join
   end
   else	begin
     $error("test type not found: %s", maint_test_type);		
   end // else: !if(maint_test_type == "recall_all")
  main_done = phase.get_objection();
  main_done.set_drain_time(null, 2us);
  phase.drop_objection(this, "Start dce_csr_maint_test run phase");
<% }%>   

endtask : run_main

////////////////////////////////////////////////////////////////////////////////
