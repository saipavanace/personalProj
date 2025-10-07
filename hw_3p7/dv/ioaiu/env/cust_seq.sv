//=======================================================================
// COPYRIGHT (C) 2011, 2012, 2013 Synopsys Inc.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//=======================================================================

/**
 * Abstract:
 *
 * Execution phase: main_phase
 * Sequencer: Virtual sequencer in AXI System ENV
*/

`ifndef GUARD_AXI_MASTER_CUST_SEQUENCE_SV
`define GUARD_AXI_MASTER_CUST_SEQUENCE_SV

<%
   var no_id = 0;
   if(obj.BlockId == "ioaiu0")
   no_id = 0;
   else if(obj.BlockId == "ioaiu1")
   no_id = 1;
   else if(obj.BlockId == "ioaiu2")
   no_id = 2;
   else if(obj.BlockId == "ioaiu3")
   no_id = 3;
   else if(obj.BlockId == "ioaiu4")
   no_id = 4;
   else if(obj.BlockId == "ioaiu5")
   no_id = 5;
   else if(obj.BlockId == "ioaiu6")
   no_id = 6;
   else if(obj.BlockId == "ioaiu7")
   no_id = 7;
   else if(obj.BlockId == "ioaiu8")
   no_id = 8;
   else if(obj.BlockId == "ioaiu9")
   no_id = 9;
   else if(obj.BlockId == "ioaiu10")
   no_id = 10;
   else if(obj.BlockId == "ioaiu11")
   no_id = 11;
   
%>
<% var found_me      = 0;
   var my_ioaiu_id   = 0;
   var aiu_axiInt   = 0;
   var no_chi   = 0;

   for (var idx=0; idx < obj.AiuInfo.length; idx++) {
      if (obj.AiuInfo[idx].fnNativeInterface.indexOf("CHI") < 0) {
         if (obj.Id == idx) {
            found_me = 1;
         } else if (! found_me) {
            my_ioaiu_id ++;
         }   
      }
      if ((obj.AiuInfo[idx].fnNativeInterface == "CHI-A")||(obj.AiuInfo[idx].fnNativeInterface == "CHI-B")) {
      no_chi ++;
      }
   }

if(obj.AiuInfo[obj.Id].interfaces.axiInt.length > 1) {
   aiu_axiInt = obj.AiuInfo[obj.Id].interfaces.axiInt[0];
} else {
   aiu_axiInt = obj.AiuInfo[obj.Id].interfaces.axiInt;
}

%>
class cust_svt_axi_snoop_transaction extends svt_axi_master_snoop_transaction;

`uvm_object_param_utils(cust_svt_axi_snoop_transaction)

//--------------------------------------------------------------
// Constraints
//-------------
function void pre_randomize();
		super.pre_randomize();                             

reasonable_snoop_resp_datatransfer.constraint_mode(0);
reasonable_snoop_resp.constraint_mode(0);

endfunction

constraint reasonable_cust_snp_xact_data_resp_status {
snoop_resp_datatransfer inside {0,1};
 }
constraint reasonable_cust_snoop_resp_status {
snoop_resp_error inside {0};}


function new (string name = "cust_svt_axi_snoop_transaction");
super.new(name);
endfunction: new

endclass: cust_svt_axi_snoop_transaction

class cust_svt_axi_snoop_err_transaction extends svt_axi_master_snoop_transaction;

`uvm_object_param_utils(cust_svt_axi_snoop_err_transaction)

//--------------------------------------------------------------
// Constraints
//-------------

constraint reasonable_cust_snoop_resp_status {
snoop_resp_error inside {0,1};}


function new (string name = "cust_svt_axi_snoop_err_transaction");
super.new(name);
endfunction: new

endclass: cust_svt_axi_snoop_err_transaction 

  <% for(var ncidx = 0,idx = 0; idx < obj.nAIUs; idx++) { 
        if((obj.AiuInfo[idx].fnNativeInterface == 'ACE')) { %>
class ioaiu<%=ncidx%>_axi_master_transaction extends svt_axi_master_transaction;
    `uvm_object_param_utils(ioaiu<%=ncidx%>_axi_master_transaction)

constraint no_narrow {if(is_auto_generated == 1 || coherent_xact_type==svt_axi_transaction::WRITECLEAN || coherent_xact_type==svt_axi_transaction::WRITEBACK) {
                burst_size == <%=Math.log2(obj.AiuInfo[idx].interfaces.axiInt.params.wData/8)%>;}}

function new (string name = "ioaiu<%=ncidx%>_axi_master_transaction");
super.new(name);
endfunction: new

endclass : ioaiu<%=ncidx%>_axi_master_transaction

   <% ncidx++; } %>
<% } %>

class ioaiu_axi_master_transaction extends svt_axi_master_transaction;
    `uvm_object_param_utils(ioaiu_axi_master_transaction)

function void pre_randomize();
		super.pre_randomize();                             
reasonable_no_multi_part_dvm.constraint_mode(0);
endfunction

function new (string name = "ioaiu_axi_master_transaction");
super.new(name);
endfunction: new

endclass : ioaiu_axi_master_transaction
//
//class ioaiu2_axi_master_transaction extends svt_axi_master_transaction;
//    `uvm_object_utils(ioaiu2_axi_master_transaction)
//
//constraint no_narrow {if(is_auto_generated == 1 || coherent_xact_type==svt_axi_transaction::WRITECLEAN || coherent_xact_type==svt_axi_transaction::WRITEBACK) {
//                burst_size == 5;}}
//
//function new (string name = "ioaiu2_axi_master_transaction");
//super.new(name);
//endfunction: new
//
//endclass : ioaiu2_axi_master_transaction

class ioaiu_axi_master_snoop_transaction extends svt_axi_master_snoop_transaction;
   `uvm_object_param_utils(ioaiu_axi_master_snoop_transaction)
  int               prob_ace_snp_resp_error_1 = 0;
/* if (prob_ace_snp_resp_error) begin
  svt_axi_snoop_transaction::snoop_resp_error=1;
 end */

function new(string name = "ioaiu_axi_master_snoop_transaction");
    super.new(name);
    $display("RESP_SNOOP");
endfunction : new

constraint snoop_err_rsp{ if (prob_ace_snp_resp_error_1 == 0){
		 snoop_resp_error==1;}}
endclass : ioaiu_axi_master_snoop_transaction

`endif // GUARD_AXI_MASTER_CUST_SEQUENCE_SV

class snps_axi_master_pipelined_seq extends svt_axi_system_base_sequence;

    `uvm_object_param_utils(snps_axi_master_pipelined_seq)
    svt_axi_master_sequencer m_axi_seqr;
    int master_idx;
    // Read and write sequences
    //axi_master_read_seq         m_read_seq[];
    //svt_axi_ace_master_read_xact_sequence         m_read_seq[];
    snps_axi_master_read_all_seq         m_read_seq[];
    //axi_master_write_noncoh_seq m_noncoh_write_seq[];
     snps_axi_master_write_noncoh_seq m_noncoh_write_seq[];
    //snps_axi_master_write_seq        m_noncoh_write_seq[];
<% if (obj.fnNativeInterface == "ACE") { %>    
    //axi_master_write_coh_seq    m_coh_write_seq;
    snps_axi_master_write_coh_seq    m_coh_write_seq;
    //axi_master_writeback_seq    m_wb_seq[];
<% } %>
    //axi_master_exclusive_seq    m_exclusive_seq;
    
    // Read and write sequencers
    //axi_read_addr_chnl_sequencer  m_read_addr_chnl_seqr;
    //axi_read_data_chnl_sequencer  m_read_data_chnl_seqr;
    //axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    //axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    //axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;

    ace_cache_model               		m_ace_cache_model;
    svt_axi_cache                 		snps_cache;
   snps_axi_master_snoop_seq  			snoop_sequence_h[];
   snps_axi_master_copyback_seq  		copyback_sequence_h;
   snps_axi_master_outstanding_read_seq  	outstanding_read_sequence_h[];
    snps_ace_dvm_outstanding_seq  	outstanding_ace_dvm_sequence_h;
  snps_axi_master_outstanding_write_seq  	outstanding_write_sequence_h[];

    snps_axi_master_exclusive_seq  		exclusive_sequence_h;
    snps_axi4_master_read_write_seq  		axi4_read_write_sequence_h;
    snps_ace_master_read_seq  			ace_read_sequence_h[];
    snps_ace_master_write_seq	  		ace_write_sequence_h[];
    bit [<%=obj.nDIIs%>-1:0] aiu_dii_vec; 



    bit                                       use_addr_from_test = 0;
    bit                                       use_axcache_from_test = 0;
    //axi_axaddr_t   m_ace_addr_from_test;
    <% if (obj.wSecurityAttribute > 0) { %>                                             
        bit [<%=obj.wSecurityAttribute%>-1:0] m_ace_security_from_test;
    <% } %>                                                
    int use_incr_addr_from_test = 0;

    //newperf_test pcie
	int nbr_alt_coh_noncoh_tx[0:1]; // [0] nbr coh tx then alternate to noncoh  [1] nbr noncoh tx then alternate to coh 
	int nbr_alt_noncoh_only_tx[0:1]; // [0] nbr noncoh mem region0 tx then [1] nbr noncoh mem region1 tx
	//end pcie

    // Knobs
<% if (obj.fnNativeInterface == "AXI4") { %>
   <% if (obj.NcMode == 0) { %>
   // AXI4 NcMode (non-coherent mode) = 0, only send coherent traffic
    int wt_ace_rdnosnp                         = 0;
    int wt_ace_rdonce                          = 5;
   <% } else { %>
   // AXI4 NcMode (non-coherent mode) = 1, only send non-coherent traffic
    int wt_ace_rdnosnp                         = 5;
    int wt_ace_rdonce                          = 0;
   <% } %>
<% } else { %>
`ifdef PSEUDO_SYS_TB
    int wt_ace_rdnosnp                         = 0;
`else
    int wt_ace_rdnosnp                         = 5;
`endif
    int wt_ace_rdonce                          = 5;
<% } %>					  
<% if (obj.fnNativeInterface == "ACE") { %>    
    int wt_ace_rdshrd                          = 5;
    int wt_ace_rdcln                           = 5;
    int wt_ace_rdnotshrddty                    = 5;
    int wt_ace_rdunq                           = 5;
    int wt_ace_clnunq                          = 5;
    int wt_ace_mkunq                           = 5;
    int wt_ace_dvm_msg                         = 5;
    int wt_ace_dvm_sync                        = 5;
<% }  
else { %>    
    int wt_ace_rdshrd                          = 0;
    int wt_ace_rdcln                           = 0;
    int wt_ace_rdnotshrddty                    = 0;
    int wt_ace_rdunq                           = 0;
    int wt_ace_clnunq                          = 0;
    int wt_ace_mkunq                           = 0;
    int wt_ace_dvm_msg                         = 0;
    int wt_ace_dvm_sync                        = 0;
<% } %>      
    int wt_ace_clnshrd                         = 0;
    int wt_ace_clninvl                         = 0;
    int wt_ace_mkinvl                          = 0;
    int wt_ace_rd_bar                          = 0;
    // FIXME: Fix below weight to be non-zero
<% if (obj.fnNativeInterface == "AXI4") { %>
   <% if (obj.useCache) { %>
    int wt_ace_wrnosnp                         = 0;
    int wt_ace_wrunq                           = 5;
   <% } else { %>
    int wt_ace_wrnosnp                         = 5;
    int wt_ace_wrunq                           = 0;
   <% } %>
    int wt_ace_wrlnunq                         = 0;
<% } else { %>
`ifdef PSEUDO_SYS_TB
    int wt_ace_wrnosnp                         = 0;
`else
    int wt_ace_wrnosnp                         = 5;
`endif
    int wt_ace_wrunq                           = 5;
    int wt_ace_wrlnunq                         = 5;
<% } %>					  
<% if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")) { %>    
    int wt_ace_wrcln                           = 0;
    int wt_ace_wrbk                            = 0;
    int wt_ace_evct                            = 0;
    int wt_ace_wrevct                          = 0;
<% }  
else { %>    
    int wt_ace_wrcln                           = 5;
    int wt_ace_wrbk                            = 5;
    int wt_ace_evct                            = 5;
    int wt_ace_wrevct                          = 5;
<% } %>      
    // ACE_LITE_E operations
    int wt_ace_atm_str                         = 0;
    int wt_ace_atm_ld                          = 0;
    int wt_ace_atm_swap                        = 0;
    int wt_ace_atm_comp                        = 0;
    int wt_ace_ptl_stash                       = 0;
    int wt_ace_full_stash                      = 0;
    int wt_ace_shared_stash                    = 0;
    int wt_ace_unq_stash                       = 0;
    int wt_ace_stash_trans                     = 0;
    // FIXME: Fix below weights to be non-zero
    int wt_ace_wr_bar                          = 0;
    int wt_ace_rd_cln_invld  = 0;
    int wt_ace_rd_make_invld = 0;
    int wt_ace_clnshrd_pers  = 0;

    int wt_ace_exclusive_wr                       = 0;
    int wt_ace_exclusive_rd                       = 0;

    int k_num_read_req                         = 100;
    int k_num_write_req                        = 100;
    int k_num_txn_req                          = 100;
    int k_num_exclusive_req                    = 0;
    int k_access_boot_region                   = 0;
    bit k_directed_test                        = 0;
    bit k_directed_test_alloc                  = 0;
    bit k_directest_test_addr                  = 0;
    int wt_illegal_op_addr                     = 0;    
    int wt_not_illegal_op_addr   = 0;
    int user_qos;
    int aiu_qos;													   
    
	//newperf test
	int perf_coh_txn_size;    
    int perf_noncoh_txn_size[0:1];    
	int duty_cycle; // newperf test : "duty_cycle" case ex: dutyc_cycle=6 with 60% write & 40% read => W W W W R R 
    int en_force_axid;
	int ioaiu_force_coh_axid;
	int ioaiu_force_noncoh_axid[0:1];

	string seq_name = "snps_axi_master_pipelined_seq";

    // Bit to set if we dont want any updates
    bit no_updates                             = 0;
    // Bit to set if we want to not perform any writes during the read portion of the test and then
    // writeback everything at the end of the read portion of the test
    bit late_updates                           = 0;
    // Following bit is used only for wb throughput test
    bit wb_throughput_test                     = 0; 
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_seq_done;
    <% if(obj.testBench == "fsys") { %>
    uvm_event ev_sim_done;
    <% } %>
    // newperf test event
    uvm_event ev_wr_req_done; 
    uvm_event ev_rd_req_done; 
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string _name = "snps_axi_master_pipelined_seq");
    super.new(_name);
    wb_throughput_test = $test$plusargs("wb_bw_test");
    user_qos = 0;
endfunction : new

function set_seq_name(string s);
  seq_name = s;
endfunction : set_seq_name

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    //newperf pci alternate coh & noncoh or noncoh mem region0 & noncoh mem region1
	int nbr_tx_coh;
	int nbr_tx_noncoh[0:1];
	//end alternate

  int nbr_write_in_duty_cycle; // RF
    int nbr_read_in_duty_cycle; // RF
    int nbr_loop_for_duty_cycle; // RF
    int wt_axlen_256B;
    // newperf test by default 50% when RD/WR test 
    if($test$plusargs("ioaiu<%=my_ioaiu_id%>_noncoherent_test")) begin // RF
        nbr_write_in_duty_cycle = duty_cycle*wt_ace_wrnosnp/100; 
        nbr_read_in_duty_cycle = duty_cycle*wt_ace_rdnosnp/100;
    end else begin
        nbr_write_in_duty_cycle = duty_cycle*wt_ace_wrunq/100; 
        nbr_read_in_duty_cycle = duty_cycle*wt_ace_rdonce/100;
    end
    nbr_loop_for_duty_cycle = (k_num_read_req+k_num_write_req)/duty_cycle;

    if(!$value$plusargs("wt_axlen_256B=%d",wt_axlen_256B)) begin
       wt_axlen_256B = 0; 
    end
    

    // end newperf test

    m_read_seq                      	= new[k_num_read_req];
    m_noncoh_write_seq              	= new[k_num_write_req];
    late_updates                    	= late_updates & no_updates;
    snoop_sequence_h 		    	= new[<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts%>];
    outstanding_read_sequence_h 	= new[<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts%>];
    outstanding_write_sequence_h 	= new[<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts%>];
      exclusive_sequence_h 	    	= snps_axi_master_exclusive_seq::type_id::create("exclusive_sequence_h");

    ace_read_sequence_h       		= new[<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts%>];
    ace_write_sequence_h		= new[<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts%>];
	axi4_read_write_sequence_h	    	= snps_axi4_master_read_write_seq::type_id::create("axi4_read_write_sequence_h");
    for(int k=0;k< <%=obj.AiuInfo[obj.Id].nNativeInterfacePorts%>;k++)begin
	snoop_sequence_h[k]                     = snps_axi_master_snoop_seq::type_id::create($sformatf("snoop_sequence_h%0d", k));
   	outstanding_read_sequence_h[k] 		= snps_axi_master_outstanding_read_seq::type_id::create($sformatf("outstanding_read_sequence_h%0d", k));
    	outstanding_write_sequence_h[k] 	= snps_axi_master_outstanding_write_seq::type_id::create($sformatf("outstanding_write_sequence_h%0d", k));
    	ace_read_sequence_h[k]		 	= snps_ace_master_read_seq::type_id::create($sformatf("ace_read_sequence_h%0d", k));
    	ace_write_sequence_h[k] 		= snps_ace_master_write_seq::type_id::create($sformatf("ace_write_sequence_h%0d", k));
    end
    outstanding_ace_dvm_sequence_h 		    	= snps_ace_dvm_outstanding_seq::type_id::create("outstanding_ace_dvm_sequence_h");
    copyback_sequence_h 	    	= snps_axi_master_copyback_seq::type_id::create("copyback_sequence_h");
    //outstanding_read_sequence_h 	= snps_axi_master_outstanding_read_seq::type_id::create("outstanding_read_sequence_h");
    //outstanding_write_sequence_h 	= snps_axi_master_outstanding_write_seq::type_id::create("outstanding_write_sequence_h");


<% if (obj.fnNativeInterface == "ACE") { %>    
    //m_ace_cache_model.wt_ace_wrcln  = wt_ace_wrcln;
    //m_ace_cache_model.wt_ace_wrbk   = wt_ace_wrbk;
    //m_ace_cache_model.wt_ace_evct   = wt_ace_evct;
    //m_ace_cache_model.wt_ace_wrevct = wt_ace_wrevct;
    //m_wb_seq                        = new[k_num_write_req];
<% } %>      
//disp_wt();
    `uvm_info("IOAIU<%=my_ioaiu_id%> AXI SEQ", $sformatf("Creating ev_seq_done with name %s", seq_name), UVM_NONE)
    ev_seq_done = ev_pool.get(seq_name);
    <% if(obj.testBench == "fsys") { %>
    ev_sim_done = ev_pool.get("sim_done");
	<% } %>
    ev_wr_req_done = ev_pool.get("ioaiu<%=my_ioaiu_id%>_wr_req_done"); //newperf test 
    ev_rd_req_done = ev_pool.get("ioaiu<%=my_ioaiu_id%>_rd_req_done"); //newperf test
    wt_not_illegal_op_addr = 100 - wt_illegal_op_addr;

    for (int i = 0; i < k_num_read_req; i++) begin:for_k_num_read_req

			// newperf test case pcie alternate
			int window_coh;
			int window_noncoh[0:1]; 
			if (nbr_alt_noncoh_only_tx[0]==0 && nbr_tx_noncoh[0] == nbr_alt_coh_noncoh_tx[1]  && nbr_tx_coh == nbr_alt_coh_noncoh_tx[0] ) begin
                nbr_tx_coh=0;
				nbr_tx_noncoh[0]=0;
			end
			if ( nbr_alt_coh_noncoh_tx[0]==0  && nbr_tx_noncoh[0] == nbr_alt_noncoh_only_tx[0]  && nbr_tx_noncoh[1] == nbr_alt_noncoh_only_tx[1] ) begin
				nbr_tx_noncoh='{0,0};
			end
			window_coh = (nbr_tx_coh < nbr_alt_coh_noncoh_tx[0]);
			window_noncoh[0] = ((nbr_tx_noncoh[0] < nbr_alt_coh_noncoh_tx[1])  && (nbr_tx_coh == nbr_alt_coh_noncoh_tx[0])) || (nbr_tx_noncoh[0] < nbr_alt_noncoh_only_tx[0]) ; 
			window_noncoh[1] = (nbr_tx_noncoh[1] < nbr_alt_noncoh_only_tx[1])  && (nbr_tx_noncoh[0] == nbr_alt_noncoh_only_tx[0]); 
            if (window_coh) begin	
				nbr_tx_coh++;
			end 
			if (window_noncoh[0]) begin
			   nbr_tx_noncoh[0]++;		
			end
		    if (window_noncoh[1]) begin
			   nbr_tx_noncoh[1]++;		
			end

			// end newperf test case pcie alternate
				
	//randcase
        //  wt_not_illegal_op_addr : begin
        //        m_read_seq[i]                       = axi_master_read_seq::type_id::create($sformatf("m_read_seq_%0d", i));
        //  end
        //  wt_illegal_op_addr : begin
        //        m_read_seq[i]                       = axi_master_read_seq_err::type_id::create($sformatf("m_read_seq_%0d", i));
        //  end
	//endcase												   
        m_read_seq[i]                       = snps_axi_master_read_all_seq::type_id::create($sformatf("m_read_seq_%0d", i));
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        //m_read_seq[i].get_sequence_initial_setup("body");
        //m_read_seq[i].randomize(addr);
        //m_read_seq[i].id                    = i;
        //m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        //m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        //m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        //m_read_seq[i].sequence_length        = 1;
        //m_read_seq[i].en_force_axid      = en_force_axid;
	//if (nbr_alt_coh_noncoh_tx[0] ==0) begin // case no newperf pcie alternate
	m_read_seq[i].wt_ace_rdnosnp        = wt_ace_rdnosnp;
        m_read_seq[i].wt_ace_rdonce         = wt_ace_rdonce;
 if($test$plusargs("excl_txn_en")) begin	
	m_read_seq[i].wt_ace_exclusive_rd        = wt_ace_exclusive_rd;
end
        //m_read_seq[i].ioaiu_force_axid      = (window_noncoh[1])? ioaiu_force_noncoh_axid[1] : ioaiu_force_noncoh_axid[0]; 
	//end else begin:alternate_rd_case
	m_read_seq[i].wt_ace_rdnosnp        = (window_coh)? 0:  wt_ace_rdnosnp;
        m_read_seq[i].wt_ace_rdonce         = (window_noncoh[0])? 0 : wt_ace_rdonce;
 if($test$plusargs("excl_txn_en")) begin	
	m_read_seq[i].wt_ace_exclusive_rd        = wt_ace_exclusive_rd;
end
        //m_read_seq[i].ioaiu_force_axid     =  (window_coh)? ioaiu_force_coh_axid : ioaiu_force_noncoh_axid[0];
	//end:alternate_rd_case
        m_read_seq[i].wt_ace_rdunq          = wt_ace_rdunq;
        m_read_seq[i].wt_ace_rdshrd         = wt_ace_rdshrd;
        m_read_seq[i].wt_ace_rdcln          = wt_ace_rdcln;
        m_read_seq[i].wt_ace_rdnotshrddty   = wt_ace_rdnotshrddty;
        m_read_seq[i].wt_ace_clnunq         = wt_ace_clnunq;
        m_read_seq[i].wt_ace_mkunq          = wt_ace_mkunq;
        m_read_seq[i].wt_ace_dvm_msg        = wt_ace_dvm_msg;
        m_read_seq[i].wt_ace_dvm_sync       = wt_ace_dvm_sync;
        m_read_seq[i].wt_ace_clnshrd        = wt_ace_clnshrd;
        m_read_seq[i].wt_ace_clninvl        = wt_ace_clninvl;
        m_read_seq[i].wt_ace_mkinvl         = wt_ace_mkinvl;
        //m_read_seq[i].wt_ace_rd_bar         = wt_ace_rd_bar;
        m_read_seq[i].wt_ace_rd_cln_invld   = wt_ace_rd_cln_invld;
        m_read_seq[i].wt_ace_rd_make_invld  = wt_ace_rd_make_invld;
        m_read_seq[i].wt_ace_clnshrd_pers   = wt_ace_clnshrd_pers;
        m_read_seq[i].read_req_total_count  = k_num_read_req;
        //m_read_seq[i].k_access_boot_region  = k_access_boot_region;
        m_read_seq[i].use_axcache_from_test = (k_directed_test & k_directed_test_alloc) ? 1 : 0 ;
        //m_read_seq[i].use_addr_from_test    = use_addr_from_test;
        //m_read_seq[i].m_ace_rd_addr_from_test   = m_ace_addr_from_test + (i*use_incr_addr_from_test);
        m_read_seq[i].force_axlen_256B      = 0;
	m_read_seq[i].perf_coh_txn_size     = perf_coh_txn_size;
        m_read_seq[i].perf_noncoh_txn_size    = (window_noncoh[1])? perf_noncoh_txn_size[1] : perf_noncoh_txn_size[0];

        if(wt_axlen_256B != 0) begin // Depending ongoing Duty cycle, transfer size will be 256B or 64B
            m_read_seq[i].force_axlen_256B = (int'($floor(i/nbr_read_in_duty_cycle)) % duty_cycle) < (duty_cycle*wt_axlen_256B/100);
        end

    <% if (obj.wSecurityAttribute > 0) { %>                                             
	//m_read_seq[i].m_ace_rd_security_from_test  = m_ace_security_from_test;
    <% } %>                                                        
        //m_read_seq[i].user_qos              = user_qos;
        //m_read_seq[i].aiu_qos               = aiu_qos;
    end:for_k_num_read_req

    for (int i = 0; i < k_num_write_req; i++) begin:for_k_num_write_req
        	// newperf test case pcie alternate
			int window_coh;
			int window_noncoh[0:1]; 
			if (nbr_alt_noncoh_only_tx[0]==0 && nbr_tx_noncoh[0] == nbr_alt_coh_noncoh_tx[1]  && nbr_tx_coh == nbr_alt_coh_noncoh_tx[0] ) begin
                nbr_tx_coh=0;
				nbr_tx_noncoh[0]=0;
			end
			if ( nbr_alt_coh_noncoh_tx[0]==0  && nbr_tx_noncoh[0] == nbr_alt_noncoh_only_tx[0]  && nbr_tx_noncoh[1] == nbr_alt_noncoh_only_tx[1] ) begin
				nbr_tx_noncoh='{0,0};
			end
			window_coh = (nbr_tx_coh < nbr_alt_coh_noncoh_tx[0]);
			window_noncoh[0] = ((nbr_tx_noncoh[0] < nbr_alt_coh_noncoh_tx[1])  && (nbr_tx_coh == nbr_alt_coh_noncoh_tx[0])) || (nbr_tx_noncoh[0] < nbr_alt_noncoh_only_tx[0]) ; 
			window_noncoh[1] = (nbr_tx_noncoh[1] < nbr_alt_noncoh_only_tx[1])  && (nbr_tx_noncoh[0] == nbr_alt_noncoh_only_tx[0]); 
            if (window_coh) begin	
				nbr_tx_coh++;
			end 
			if (window_noncoh[0]) begin
			   nbr_tx_noncoh[0]++;		
			end
		    if (window_noncoh[1]) begin
			   nbr_tx_noncoh[1]++;		
			end
			// end newperf test case pcie alternate
           if (wb_throughput_test) begin
            <% if (obj.fnNativeInterface == "ACE") { %>    
                //m_wb_seq[i]                        = axi_master_writeback_seq::type_id::create($sformatf("m_writeback_seq_%0d", i));
                //m_wb_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
                //m_wb_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
                //m_wb_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
                //m_wb_seq[i].k_num_write_req        = 1;
            <% } %>      
        end
        else begin
	  //randcase
          //     wt_not_illegal_op_addr : begin
	  //         m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_noncoh_write_seq_%0d", i));
          //     end
          //     wt_illegal_op_addr : begin
	  //         m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq_err::type_id::create($sformatf("m_noncoh_write_seq_%0d", i));
          //     end
          //endcase
             m_noncoh_write_seq[i]                        = snps_axi_master_write_noncoh_seq::type_id::create($sformatf("m_noncoh_write_seq_%0d", i));
             m_noncoh_write_seq[i].m_ace_cache_model     = m_ace_cache_model;
           //  m_noncoh_write_seq[i].sequence_length        = 1;
            // m_noncoh_write_seq[i].randomize(addr);
            //m_noncoh_write_seq[i].randomize(data);
            //m_noncoh_write_seq[i].get_sequence_initial_setup("body");
            //m_noncoh_write_seq[i].id                    = i;
            //m_noncoh_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
            //m_noncoh_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
            //m_noncoh_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
            //m_noncoh_write_seq[i].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
            //m_noncoh_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
            //  m_noncoh_write_seq[i].k_num_write_req        = 1;
            //m_noncoh_write_seq[i].en_force_axid      = en_force_axid;
                if (nbr_alt_coh_noncoh_tx[0] ==0) begin // case no newperf pcie alternate
                  m_noncoh_write_seq[i].wt_ace_wrnosnp         = wt_ace_wrnosnp;
                  m_noncoh_write_seq[i].wt_ace_wrunq           = wt_ace_wrunq;
 if($test$plusargs("excl_txn_en")) begin	
                m_noncoh_write_seq[i].wt_ace_exclusive_wr         = wt_ace_exclusive_wr;
end
                //m_noncoh_write_seq[i].ioaiu_force_axid      = (window_noncoh[1])? ioaiu_force_noncoh_axid[1] : ioaiu_force_noncoh_axid[0]; 
	    end else begin:alternate_wr_case
                m_noncoh_write_seq[i].wt_ace_wrnosnp         = (window_coh)? 0:wt_ace_wrnosnp;
 if($test$plusargs("excl_txn_en")) begin	
                m_noncoh_write_seq[i].wt_ace_exclusive_wr         = wt_ace_exclusive_wr;
end
                m_noncoh_write_seq[i].wt_ace_wrunq           = (window_noncoh[0])? 0 :wt_ace_wrunq;
                //m_noncoh_write_seq[i].ioaiu_force_axid       = (window_coh)? ioaiu_force_coh_axid : ioaiu_force_noncoh_axid[0]; 
	    end:alternate_wr_case
              m_noncoh_write_seq[i].wt_ace_wrlnunq         = wt_ace_wrlnunq;
              m_noncoh_write_seq[i].wt_ace_wr_bar          = wt_ace_wr_bar;
            //  m_ncoh_write_seq[i].wt_ace_wrcln             = wt_ace_wrcln;
              m_noncoh_write_seq[i].wt_ace_wrbk            = wt_ace_wrbk;
              m_noncoh_write_seq[i].wt_ace_evct            = wt_ace_evct;
              m_noncoh_write_seq[i].wt_ace_wrevct          = wt_ace_wrevct;
            m_noncoh_write_seq[i].write_req_total_count   = k_num_write_req;
           // m_noncoh_write_seq[i].wt_ace_atm_str         = wt_ace_atm_str;
           // m_noncoh_write_seq[i].wt_ace_atm_ld          = wt_ace_atm_ld;
           // m_noncoh_write_seq[i].wt_ace_atm_swap        = wt_ace_atm_swap;
           // m_noncoh_write_seq[i].wt_ace_atm_comp        = wt_ace_atm_comp;
           // m_noncoh_write_seq[i].wt_ace_ptl_stash       = wt_ace_ptl_stash;
           // m_noncoh_write_seq[i].wt_ace_full_stash      = wt_ace_full_stash;
           // m_noncoh_write_seq[i].wt_ace_shared_stash    = wt_ace_shared_stash;
           // m_noncoh_write_seq[i].wt_ace_unq_stash       = wt_ace_unq_stash;
           // m_noncoh_write_seq[i].wt_ace_stash_trans     = wt_ace_stash_trans;
            //m_noncoh_write_seq[i].k_access_boot_region   = k_access_boot_region;
	    m_noncoh_write_seq[i].use_axcache_from_test  = (k_directed_test & k_directed_test_alloc) ? 1 : 0 ;
	    //m_noncoh_write_seq[i].use_addr_from_test     = use_addr_from_test;
	    //m_noncoh_write_seq[i].m_ace_wr_addr_from_test   = m_ace_addr_from_test + (i*use_incr_addr_from_test);
    <% if (obj.wSecurityAttribute > 0) { %>                                             
	    //m_noncoh_write_seq[i].m_ace_wr_security_from_test  = m_ace_security_from_test;
    <% } %> //                                                       
            //m_noncoh_write_seq[i].user_qos               = user_qos;
            //m_noncoh_write_seq[i].aiu_qos                = aiu_qos;
            m_noncoh_write_seq[i].force_axlen_256B       = 0; 
	            m_noncoh_write_seq[i].perf_coh_txn_size     = perf_coh_txn_size;
            m_noncoh_write_seq[i].perf_noncoh_txn_size    = (window_noncoh[1])? perf_noncoh_txn_size[1] : perf_noncoh_txn_size[0];
            if (wt_axlen_256B != 0) begin // Depending ongoing Duty cycle, transfer size will be 256B or 64B
                m_noncoh_write_seq[i].force_axlen_256B = (int'($floor(i/nbr_write_in_duty_cycle)) % duty_cycle) < (duty_cycle*wt_axlen_256B/100);
            end
    
        end
    end:for_k_num_write_req
  if($test$plusargs("en_exclusive_txn")) begin
    	exclusive_sequence_h.sequence_length = k_num_txn_req;
        exclusive_sequence_h.master_id = master_idx;
    	exclusive_sequence_h.start(m_axi_seqr);
end

    if($test$plusargs("ace_snoop_enable")) begin
    <% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
        snoop_sequence_h[<%=k%>].sequence_length = k_num_txn_req;
        snoop_sequence_h[<%=k%>].master_id = <%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>;
        snoop_sequence_h[<%=k%>].start(p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>]);
    <% }}else { %>
        snoop_sequence_h[0].sequence_length = k_num_txn_req;
        snoop_sequence_h[0].master_id = <%=obj.AiuInfo[obj.Id].rpn-no_chi%>;
        snoop_sequence_h[0].start(p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn-no_chi%>]);
    <% } %> 
    end else if($test$plusargs("copyback_txn_enable")) begin
    	copyback_sequence_h.sequence_length = k_num_txn_req;
        copyback_sequence_h.master_id = master_idx;
    	copyback_sequence_h.start(m_axi_seqr);
    end else if($test$plusargs("en_outstanding_txn")) begin
      if($test$plusargs("outstanding_dvm"))begin
<% if (obj.AiuInfo[obj.Id].fnNativeInterface == "ACE") { %>    
        outstanding_ace_dvm_sequence_h.sequence_length = k_num_read_req+k_num_write_req;
        outstanding_ace_dvm_sequence_h.master_id = master_idx;
        outstanding_ace_dvm_sequence_h.start(m_axi_seqr);
    <% } %> 
     end else begin
    <% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
        outstanding_read_sequence_h[<%=k%>].sequence_length = k_num_read_req;
        outstanding_read_sequence_h[<%=k%>].master_id = <%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>;
        outstanding_read_sequence_h[<%=k%>].start(p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>]);
        outstanding_write_sequence_h[<%=k%>].sequence_length = k_num_write_req;
        outstanding_write_sequence_h[<%=k%>].master_id = <%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>;
        outstanding_write_sequence_h[<%=k%>].start(p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>]);
    <% }}else { %>
        outstanding_read_sequence_h[0].sequence_length = k_num_read_req;
        outstanding_read_sequence_h[0].master_id = <%=obj.AiuInfo[obj.Id].rpn-no_chi%>;
        outstanding_read_sequence_h[0].start(p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn-no_chi%>]);
        outstanding_write_sequence_h[0].sequence_length = k_num_write_req;
        outstanding_write_sequence_h[0].master_id = <%=obj.AiuInfo[obj.Id].rpn-no_chi%>;
        outstanding_write_sequence_h[0].start(p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn-no_chi%>]);
    <% } %> 
end
        //outstanding_read_sequence_h.sequence_length = k_num_read_req;
        //outstanding_write_sequence_h.sequence_length = k_num_write_req;
        //outstanding_read_sequence_h.start(m_axi_seqr);
        //outstanding_write_sequence_h.start(m_axi_seqr);
    end else if($test$plusargs("en_ace_rd_wr_txn")) begin
    <% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
        ace_read_sequence_h[<%=k%>].sequence_length = k_num_read_req;
        ace_read_sequence_h[<%=k%>].master_id = <%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>;
        ace_read_sequence_h[<%=k%>].start(p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>]);
        ace_write_sequence_h[<%=k%>].sequence_length = k_num_write_req;
        ace_write_sequence_h[<%=k%>].master_id = <%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>;
        ace_write_sequence_h[<%=k%>].start(p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>]);
    <% }}else { %>
        ace_read_sequence_h[0].sequence_length = k_num_read_req;
        ace_read_sequence_h[0].master_id = <%=obj.AiuInfo[obj.Id].rpn-no_chi%>;
        ace_read_sequence_h[0].start(p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn-no_chi%>]);
        ace_write_sequence_h[0].sequence_length = k_num_write_req;
        ace_write_sequence_h[0].master_id = <%=obj.AiuInfo[obj.Id].rpn-no_chi%>;
        ace_write_sequence_h[0].start(p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn-no_chi%>]);
    <% } %> 
    end else if($test$plusargs("k_axi4_seq_f_cov")) begin
      if($test$plusargs("dii_access"))begin
        aiu_dii_vec = 'h<%=obj.AiuInfo[obj.Id].hexAiuDiiVec%>;
        if(aiu_dii_vec)begin
            axi4_read_write_sequence_h.sequence_length = k_num_txn_req;
            axi4_read_write_sequence_h.master_id = master_idx;
            axi4_read_write_sequence_h.dii_access = 1;
            axi4_read_write_sequence_h.start(m_axi_seqr);
        end
      end else begin
        axi4_read_write_sequence_h.sequence_length = k_num_txn_req;
        axi4_read_write_sequence_h.master_id = master_idx;
        axi4_read_write_sequence_h.dii_access = 0;
        axi4_read_write_sequence_h.start(m_axi_seqr);
      end
    end else if($test$plusargs("long_delay_en")) begin
        snoop_sequence_h[0].sequence_length = k_num_txn_req;
        snoop_sequence_h[0].master_id = master_idx;
        snoop_sequence_h[0].start(m_axi_seqr);
        outstanding_read_sequence_h[0].sequence_length = k_num_read_req;
        outstanding_read_sequence_h[0].master_id = master_idx;
        outstanding_read_sequence_h[0].start(m_axi_seqr);
        outstanding_write_sequence_h[0].sequence_length = k_num_write_req;
        outstanding_write_sequence_h[0].master_id = master_idx;
        outstanding_write_sequence_h[0].start(m_axi_seqr);
    end else begin
    if($test$plusargs("ioaiu<%=my_ioaiu_id%>_rw_split")) begin    // RF section : For NxP PerfTest
        automatic int k = 0;
`uvm_info("body", $sformatf("nbr_loop_for_duty_cycle %0d, nbr_write_in_duty_cycle %0d, nbr_read_in_duty_cycle %0d, ", nbr_loop_for_duty_cycle, nbr_write_in_duty_cycle, nbr_read_in_duty_cycle), UVM_NONE);

        if(duty_cycle > 0) begin    // case duty cycle 

            for(k=0;k<nbr_loop_for_duty_cycle;k++) begin

                fork
                begin  : isolate_write_fork
                    begin
                        for (int i = 0; i < nbr_write_in_duty_cycle; i++) begin
                            fork
                                automatic int w=i+(k*nbr_write_in_duty_cycle);
                                begin
                                    //m_noncoh_write_seq[w].start(null);
                                     m_noncoh_write_seq[w].m_write_seqr = p_sequencer.master_sequencer[<%=my_ioaiu_id%>];
                                     m_noncoh_write_seq[w].start(null);
                                    //m_noncoh_write_seq[w].start(m_axi_seqr);
//`uvm_info("body", $sformatf("WR[%0d]: %0s", w, m_noncoh_write_seq[w].seq_xact_type), UVM_NONE);
                                end
                            join_none
                        end // end loop for nbr_write_in_duty_cycle
                    end

                    begin // wait for all ev_wr_req_done
                        for (int j = 0; j < nbr_write_in_duty_cycle; j++) begin
                            ev_wr_req_done.wait_trigger();
                        end // end loop for nbr_write_in_duty_cycle
                    end
                //wait fork;
                end : isolate_write_fork
                join

                fork
                begin  : isolate_read_fork
                    begin
                        for (int i = 0; i < nbr_read_in_duty_cycle; i++) begin
                            fork
                                automatic int r=i+(k*nbr_read_in_duty_cycle);
                                begin
                                    //m_read_seq[r].start(null);
                                    m_read_seq[r].m_read_seqr = p_sequencer.master_sequencer[<%=my_ioaiu_id%>];
                                    m_read_seq[r].m_write_seqr = p_sequencer.master_sequencer[<%=my_ioaiu_id%>];
                                    m_read_seq[r].start(null);
                                    //m_read_seq[r].start(m_axi_seqr);
// `uvm_info("body", $sformatf("RD[%0d]: %0s", r, m_read_seq[r].seq_xact_type), UVM_NONE);
                                end
                            join_none
                        end // end loop for nbr_read_in_duty_cycle
                    end

                    begin // wait for all ev_rd_req_done
                        for (int j = 0; j < nbr_read_in_duty_cycle; j++) begin
                            ev_rd_req_done.wait_trigger();
                        end // end loop for nbr_read_in_duty_cycle
                    end
                //wait fork;
                end : isolate_read_fork
                join
            end
        end
end else begin // end newperf test// else no newperf test duty cycle


<% if (obj.fnNativeInterface == "ACE") { %>    
    //m_coh_write_seq                        = axi_master_write_coh_seq::type_id::create("m_coh_write_seq");
    m_coh_write_seq                        = snps_axi_master_write_coh_seq::type_id::create("m_coh_write_seq");
    //m_coh_write_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
    //m_coh_write_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
    //m_coh_write_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
    m_coh_write_seq.m_ace_cache_model      = m_ace_cache_model;
    //m_coh_write_seq.m_write_seqr      = p_sequencer.master_sequencer[0];
    m_coh_write_seq.m_write_seqr      = p_sequencer.master_sequencer[<%=my_ioaiu_id%>];
<% } %>


<% if (obj.fnNativeInterface == "ACE") { %>    
    //fork
    //    begin
    //        for(int i = 0; i < k_num_exclusive_req; i++) begin
    //            m_exclusive_seq                       = axi_master_exclusive_seq::type_id::create($sformatf("m_exclusive_seq_%0d", i));
    //            m_exclusive_seq.m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
    //            m_exclusive_seq.m_read_data_chnl_seqr = m_read_data_chnl_seqr;
    //            m_exclusive_seq.m_ace_cache_model     = m_ace_cache_model;
    //            m_exclusive_seq.wt_ace_rdshrd         = wt_ace_rdshrd;
    //            m_exclusive_seq.wt_ace_rdcln          = wt_ace_rdcln;

    //            m_exclusive_seq.start(null);
    //        end
    //    end
    //join_none

<% } %> 
`uvm_info("body", $sformatf("k_num_read_req %0d, k_num_write_req %0d, wb_throughput_test %0d, ", k_num_read_req, k_num_write_req, wb_throughput_test), UVM_NONE);
<% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){  %>
   k_num_write_req = k_num_write_req /<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts%> ;
   k_num_read_req = k_num_read_req /<%=obj.AiuInfo[obj.Id].nNativeInterfacePorts%> ;
`uvm_info("body", $sformatf("inside loop k_num_read_req %0d, k_num_write_req %0d, wb_throughput_test %0d, ", k_num_read_req, k_num_write_req, wb_throughput_test), UVM_NONE);
<% } %> 

fork
    for (int i =  k_num_write_req-1; i >=0; i--) begin
        fork
            automatic int j = i;
            begin
                if (wb_throughput_test) begin
                    <% if (obj.fnNativeInterface == "ACE") { %>    
                        //m_wb_seq[j].start(null);
                    <% } %>      
                end
                else begin
    <% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
                    m_noncoh_write_seq[j].m_write_seqr = p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>];
                    m_noncoh_write_seq[j].master_id = <%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>;
                    m_noncoh_write_seq[j].start(null);
    <% }}else { %>

                    m_noncoh_write_seq[j].m_write_seqr = p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn-no_chi%>];
                    m_noncoh_write_seq[j].master_id = <%=obj.AiuInfo[obj.Id].rpn-no_chi%>;
                    m_noncoh_write_seq[j].start(null);
    <% } %> 
                    //m_noncoh_write_seq[j].start(m_axi_seqr);
//`uvm_info("body", $sformatf("WR[%0d]: %0s", j, m_noncoh_write_seq[j].seq_xact_type), UVM_NONE);
                end
            end
        join_none
    end
    for (int i = k_num_read_req-1; i >= 0; i--) begin // decrement because we can apply the right arbiration in the sequencer
        fork
            automatic int j = i;
            begin
                //m_read_seq[j].start(null);
    <% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
                m_read_seq[j].m_read_seqr = p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>];
                m_read_seq[j].master_id = <%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>;
                m_read_seq[j].m_write_seqr = p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn[k]-no_chi%>];
                m_read_seq[j].start(null);
    <% }}else { %>
                m_read_seq[j].m_read_seqr = p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn-no_chi%>];
                m_read_seq[j].master_id = <%=obj.AiuInfo[obj.Id].rpn-no_chi%>;
                m_read_seq[j].m_write_seqr = p_sequencer.master_sequencer[<%=obj.AiuInfo[obj.Id].rpn-no_chi%>];
                m_read_seq[j].start(null);
    <% } %> 
                //m_read_seq[j].start(m_axi_seqr);
//`uvm_info("body", $sformatf("RD[%0d]: %0s", j, m_read_seq[j].seq_xact_type), UVM_NONE);
            end
        join_none
    end
join
<% if (obj.fnNativeInterface == "ACE") { %>    
    fork
        begin
         if(!no_updates)begin
            m_coh_write_seq.start(null);
         end
        end
    join_none
<% } %>
end // end else no newperf test duty cycle
    wait fork;
    `uvm_info("IOAIU<%=my_ioaiu_id%> AXI SEQ", $sformatf("AXI %s Sequence done", seq_name), UVM_NONE)
    ev_seq_done.trigger(null);													   
<% if (obj.fnNativeInterface == "ACE") { %>    
    fork
        begin
         if(late_updates)begin
             m_coh_write_seq.dont_ever_kill_seq = 1;
             m_coh_write_seq.start(null);
         end
        end
    join_none
<% } %>

<% if (obj.testBench == "fsys") { %>    
    //ev_sim_done.wait_trigger();
    `uvm_info("IOAIU<%=my_ioaiu_id%> AXI SEQ", "Received simulation done", UVM_NONE)
<% } %>
    end
													   
endtask : body

/*
function disp_wt();
  `uvm_info(get_name(), $sformatf("---------- All Knobs/wts ----------
     wt_ace_rdnosnp                         = %0d
     wt_ace_rdonce                          = %0d
     wt_ace_rdshrd                          = %0d
     wt_ace_rdcln                           = %0d
     wt_ace_rdnotshrddty                    = %0d
     wt_ace_rdunq                           = %0d
     wt_ace_clnunq                          = %0d
     wt_ace_mkunq                           = %0d
     wt_ace_dvm_msg                         = %0d
     wt_ace_dvm_sync                        = %0d
     wt_ace_clnshrd                         = %0d
     wt_ace_clninvl                         = %0d
     wt_ace_mkinvl                          = %0d
     // wt_ace_rd_bar                          = %0d
     wt_ace_wrnosnp                         = %0d
     wt_ace_wrunq                           = %0d
     wt_ace_wrlnunq                         = %0d
     wt_ace_wrcln                           = %0d
     wt_ace_wrbk                            = %0d
     wt_ace_evct                            = %0d
     wt_ace_wrevct                          = %0d
     wt_ace_atm_str                         = %0d
     wt_ace_atm_ld                          = %0d
     wt_ace_atm_swap                        = %0d
     wt_ace_atm_comp                        = %0d
     wt_ace_ptl_stash                       = %0d
     wt_ace_full_stash                      = %0d
     wt_ace_shared_stash                    = %0d
     wt_ace_unq_stash                       = %0d
     wt_ace_stash_trans                     = %0d
     wt_ace_wr_bar                          = %0d
     wt_ace_rd_cln_invld                    = %0d
     wt_ace_rd_make_invld                   = %0d
     wt_ace_clnshrd_pers                    = %0d
     k_num_read_req                         = %0d
     k_num_write_req                        = %0d
     k_num_exclusive_req                    = %0d
     k_access_boot_region                   = %0d
     k_directed_test                        = %0d
     k_directed_test_alloc                  = %0d
     k_directest_test_addr                  = %0d
     wt_illegal_op_addr                     = %0d
     wt_not_illegal_op_addr                 = %0d",
     wt_ace_rdnosnp                         ,
     wt_ace_rdonce                          ,
     wt_ace_rdshrd                          ,
     wt_ace_rdcln                           ,
     wt_ace_rdnotshrddty                    ,
     wt_ace_rdunq                           ,
     wt_ace_clnunq                          ,
     wt_ace_mkunq                           ,
     wt_ace_dvm_msg                         ,
     wt_ace_dvm_sync                        ,
     wt_ace_clnshrd                         ,
     wt_ace_clninvl                         ,
     wt_ace_mkinvl                          ,
     // wt_ace_rd_bar                       ,
     wt_ace_wrnosnp                         ,
     wt_ace_wrunq                           ,
     wt_ace_wrlnunq                         ,
     wt_ace_wrcln                           ,
     wt_ace_wrbk                            ,
     wt_ace_evct                            ,
     wt_ace_wrevct                          ,
     wt_ace_atm_str                         ,
     wt_ace_atm_ld                          ,
     wt_ace_atm_swap                        ,
     wt_ace_atm_comp                        ,
     wt_ace_ptl_stash                       ,
     wt_ace_full_stash                      ,
     wt_ace_shared_stash                    ,
     wt_ace_unq_stash                       ,
     wt_ace_stash_trans                     ,
     wt_ace_wr_bar                          ,
     wt_ace_rd_cln_invld                    ,
     wt_ace_rd_make_invld                   ,
     wt_ace_clnshrd_pers                    ,
     k_num_read_req                         ,
     k_num_write_req                        ,
     k_num_exclusive_req                    ,
     k_access_boot_region                   ,
     k_directed_test                        ,
     k_directed_test_alloc                  ,
     k_directest_test_addr                  ,
     wt_illegal_op_addr                     ,
     wt_not_illegal_op_addr                 )
, UVM_NONE) 
endfunction */
endclass : snps_axi_master_pipelined_seq

