//**************************************************
// Author: David Clarino
//**************************************************
`uvm_analysis_imp_decl(_maint_slave_req)

class dce_maint_recall_checker extends uvm_component;
   `uvm_component_utils(dce_maint_recall_checker)

   uvm_analysis_imp_maint_slave_req #(sfi_seq_item, dce_maint_recall_checker) analysis_slave_req;
   bit m_checker_active = 0;
   bit m_all_snp_recalls_found;
   bit init_all_check;
   
   <%=obj.BlockId%>_con::cacheAddress_t m_expected_addrs[<%=obj.BlockId%>_con::cacheAddress_t];
   <%=obj.BlockId%>_con::cacheAddress_t m_addrs_seen[<%=obj.BlockId%>_con::cacheAddress_t];
   CacheStateModel m_csm;
   localparam TIMEOUT_CNT_MAX = 100;
   extern function new(string name = "dce_maint_recall_checker", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);
      extern task main_phase(uvm_phase phase);   
   extern function void write_maint_slave_req(sfi_seq_item item);
endclass // dce_maint_recall_checker

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_maint_recall_checker::new(string name = "dce_maint_recall_checker", uvm_component parent = null);
  super.new(name, parent);
  $timeformat(-9, 2, " ns", 10);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_maint_recall_checker::build_phase(uvm_phase phase);
     analysis_slave_req  = new ("analysis_slave_req",  this);
endfunction // build_phase

//------------------------------------------------------------------------------
// Main Phase
//------------------------------------------------------------------------------
task dce_maint_recall_checker::main_phase(uvm_phase phase);
   bit done;
   bit prev_m_checker_active = 0;
   
   longint timeout_cnt;
   static <%=obj.BlockId + '_con'%>::cacheAddress_t CACHE_ADDR_MASK;
   done = 0;
   timeout_cnt = 0;
   
   super.main_phase(phase);

   do begin
      #1us;
      //at beginning of checking, raise objection
      if((m_checker_active == 1) && (prev_m_checker_active == 0)) begin
	 $display("raise this objection");
	 phase.raise_objection(this, "Raise objection in dce_maint_recall_checker main_phase.");
	 $display("DEBUG m_expected_addrs = %p", m_expected_addrs);
	 
      end
      if(m_checker_active) begin
	 if(timeout_cnt == TIMEOUT_CNT_MAX) begin
	    done = 1;
	    if(init_all_check) begin
	       `uvm_info(get_full_name(),"SUCCESS! NO SNP recalls found after init_all", UVM_LOW)
	    end
	    else begin
	       `uvm_error(get_type_name(), $sformatf("TIMEOUT, there are still dce maintenance recalls not found"));
	    end
	    phase.drop_objection(this, "Drop objection in dce_maint_recall_checker main_phase");	    
	 end else if(init_all_check) begin
	    timeout_cnt++;
	 end
	 else if (m_expected_addrs.size() == 0) begin
	    done = 1;
	    phase.drop_objection(this, "Drop objection in dce_maint_recall_checker main_phase");	    
	 end else begin
	    timeout_cnt++;
	 end
      end // if (checker_active)
      prev_m_checker_active = m_checker_active;
   end while(!done);
   
endtask // main_phase

//------------------------------------------------------------------------------
// Incoming slave request packet
//------------------------------------------------------------------------------
function void dce_maint_recall_checker::write_maint_slave_req(sfi_seq_item  item);

  <%=obj.BlockId + '_con'%>::SNPreqEntry_t  snp_req_entry;
  <% if (obj.wSecurityAttribute > 0) { %>
      localparam msb = <%=obj.BlockId + '_con'%>::SecureCacheAddrMsb;
      localparam lsb = <%=obj.BlockId + '_con'%>::SecureCacheAddrLsb;
  <% } %>
   if(m_checker_active) begin
      if (<%=obj.BlockId + '_con'%>::isSNPreqFromSfi(item.req_pkt)) begin
	 snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(item.req_pkt);
	 <% if (obj.wSecurityAttribute > 0) { %>
            snp_req_entry.cache_addr[msb:lsb] = snp_req_entry.req_security;
         <% } %>
	 if(snp_req_entry.snp_msg_type == <%=obj.BlockId + '_con'%>::eSnpRecall) begin
	    if(init_all_check) begin
	       `uvm_error(get_full_name(), $sformatf("SNPRecall found after doing a reset!"))
	    end
	    else begin 
	       if(m_expected_addrs.exists(snp_req_entry.cache_addr)) begin
		  `uvm_info(get_full_name(), $sformatf("CHECKER FOUND SNPRecall for %h",snp_req_entry.cache_addr), UVM_LOW)
		  `uvm_info(get_full_name(), $sformatf(m_expected_addrs), UVM_LOW)
		  m_expected_addrs.delete(snp_req_entry.cache_addr);
		  m_addrs_seen[snp_req_entry.cache_addr] = snp_req_entry.cache_addr;
		  `uvm_info(get_full_name(), $sformatf(m_addrs_seen), UVM_LOW)	 	 
	       end
	       else if(m_addrs_seen.exists(snp_req_entry.cache_addr)) begin
		  `uvm_info(get_full_name(), $sformatf("CHECKER FOUND SNPRecall for %h",snp_req_entry.cache_addr), UVM_LOW)
	       end else begin
		  `uvm_info(get_full_name(), $sformatf("CHECKER FOUND SNPRecall with unexpected recall address for %h",snp_req_entry.cache_addr), UVM_LOW)
		  `uvm_info(get_full_name(), $sformatf("Expected Addrs: %p",m_expected_addrs), UVM_LOW)
	       end
	    end // if (init_all_check)
	 end // if (snp_req_entry.snp_msg_type == <%=obj.BlockId% + '_con'%>::eSnpRecall)
      end // if (<%=obj.BlockId + '_con'%>::isSNPreqFromSfi(item.req_pkt))
   end // if (m_checker_active)
endfunction // write_slave_req
