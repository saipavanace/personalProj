package <%=obj.BlockId%>_chi_container_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import <%=obj.BlockId%>_chi_bfm_types_pkg::*;
`ifdef VCS
export <%=obj.BlockId%>_chi_bfm_types_pkg::*;
`endif // `ifdef VCS

import sv_assert_pkg::*;
  import ncore_config_pkg::*;
import addr_trans_mgr_pkg::*;
import <%=obj.BlockId%>_chi_bfm_txn_pkg::*;
import <%=obj.BlockId%>_chi_traffic_seq_lib_pkg::*;
import chi_aiu_unit_args_pkg::*;

//Include files
`include "<%=obj.BlockId%>_chi_container_types.svh"
`include "<%=obj.BlockId%>_chi_cache_info.svh"
`include "<%=obj.BlockId%>_chi_tx_req_chnl_cb.svh"
`include "<%=obj.BlockId%>_chi_tx_rsp_chnl_cb.svh"
`include "<%=obj.BlockId%>_chi_tx_dat_chnl_cb.svh"
`include "<%=obj.BlockId%>_chi_rx_rsp_chnl_cb.svh"
`include "<%=obj.BlockId%>_chi_rx_dat_chnl_cb.svh"
`include "<%=obj.BlockId%>_chi_rx_snp_chnl_cb.svh"

class chi_container #(int ID = 0) extends uvm_object; //ID defined as FunitID

  `uvm_object_param_utils(chi_container#(ID))

  //Static instance of the container associated to 
  //Agent, use get_instance() method to get the handle
  local static chi_container#(ID) m_container;
  local string uname;
  local chi_bfm_node_t m_bfm_node_type;
  local int            m_nbytes_per_flit;
  local bit 	       snprsp_skipped;
  local int 	       snprsp_skip_aiu_id;
  local int 	       stt_fill_count;
  local int 	       fill_stt = 1;

  ncoreConfigInfo::addrq user_addrq[];
  int 		      user_addrq_idx[];
  ncoreConfigInfo::addrq user_write_addrq[];
  int 		      user_write_addrq_idx[];
  ncoreConfigInfo::addrq user_read_addrq[];
  int 		      user_read_addrq_idx[];
   
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event ev_fill_stt = ev_pool.get("ev_fill_stt");
  uvm_event ev_max_snp_req_sent = ev_pool.get("ev_max_snp_req_sent");

  bit [2:0] dec_err_type;
  //Semaphore to control the flow if chi req flits
  local semaphore m_req_sem;

  //Pool of cachelines present in Agent's containter 
  //Behavioral Repesentation of (L1-cache)
  chi_cache_info m_chi_cache[bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0]];
  //uvm_pool #(.KEY(bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0]),
  //  .T(chi_cache_info)) m_chi_cache;

  //In-Flight transactions that are active for given txnid,
  //Transactions are mapped with req channel txid
  chi_bfm_txn m_chi_txns[];

  //Global storage for Stashing snoop responses.
  chi_stashing_snp_t m_chi_stash_rspq[$];

  chi_bfm_rsp_t m_chi_snp_rspq[$];
  chi_bfm_dat_t m_chi_snp_data_rspq[$];
  chi_stashing_snp_t m_chi_stash_snp_rspq[$];
  chi_stashing_snp_t m_chi_stash_snp_data_rspq[$];
  chi_bfm_cache_state_t    snp_stash_data_end_stateq[$];
  chi_bfm_cache_state_t    snp_data_end_stateq[$];
  addr_width_t  snp_stash_data_addrq[$];
  addr_width_t  snp_data_addrq[$];

  //Request channel transaction that were'nt issued
  //due to lack of resouces
  int m_unscheduled_txnq[$];

  //Free pool of transaction ID's
  int m_txnid_pool[$];

  //Cachelines that are installed in L1 cache.
  //This structure is used to avoid iterating over 
  //m_chi_cache for every transaction.
  //Holds cachelines that aren't in inflight i.e.
  //Cachelines that aren't in m_chi_txns queue
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] m_installed_cachelines[][$];

  //cachelines that are request ordered
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] m_pend_reqorder_txnq[$];
  //Mem-Region Indexes w.r.t ncoreConfigInfo::memregion_boundaries
  //that are associated to DII-agents
  int m_pend_endpoint_txnq[$];

  //Instances of various channel pipes
  //Hooks to user to alter the behavior of the model
  chi_tx_req_chnl_cb#(ID) m_tx_req_chnl_cb;
  chi_tx_rsp_chnl_cb#(ID) m_tx_rsp_chnl_cb;
  chi_tx_dat_chnl_cb#(ID) m_tx_dat_chnl_cb;
  chi_rx_rsp_chnl_cb#(ID) m_rx_rsp_chnl_cb;
  chi_rx_dat_chnl_cb#(ID) m_rx_dat_chnl_cb;
  chi_rx_snp_chnl_cb#(ID) m_rx_snp_chnl_cb;

  //Address Manager handle
  addr_trans_mgr m_addr_mgr;
  //CHI unit args
  chi_aiu_unit_args m_args;
  
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] same_dvm_addr = 'h0;
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] cache_flush_addr;

  int k_snp_rsp_non_data_err_wgt;
  int k_snp_rsp_data_err_wgt;
  int max_stt_fill_count;
  int send_pending_snp_rsp;
  int send_pending_snp_rsp_data;
  chi_bfm_snp_t temp_snp_txn;

  //
  //Methods invoked to get instance of chi_container
  //
  static function chi_container#(ID) get_instance();
    if (m_container == null) begin
      string s;
      $sformat(s, "chi_container[%0d]", ID);
      m_container = chi_container#(ID)::type_id::create(s);
    end
    return m_container;
  endfunction: get_instance

  //
  //Methods invoked by CHI virtual sequence
  //

  //configuration methods
  extern function void set_chi_node_type(chi_bfm_node_t node_type, int nbytes);
  extern function void set_unit_args(const ref chi_aiu_unit_args args);

  //request initiation methods
  extern task construct_chi_txn(const ref chi_rn_traffic_cmd_seq io_txn);
  extern task construct_chi_stashing_snprsp();
  
  //CHI containter channel interfaces
  extern task get_txreq_chnl_txn(output chi_bfm_txn     req_txn);
  extern task put_txreq_chnl_txn(input chi_bfm_txn     req_txn);
  extern task get_txrsp_chnl_txn(output chi_bfm_rsp_t   rsp_txn);
  extern task get_txdat_chnl_txn(output chi_bfm_dat_t   dat_txn);
  extern function void put_rxrsp_chnl_txn(chi_bfm_rsp_t rsp_txn);
  extern function void put_rxdat_chnl_txn(chi_bfm_dat_t dat_txn);
  extern function void put_rxsnp_chnl_txn(chi_bfm_snp_t snp_txn);
  extern function void print_pending_txns();
  //
  //Methods for debuging
  //
  extern function string conv2str_rsp_chnl_pkt(
    const ref chi_bfm_rsp_t p);
  extern function string conv2str_dat_chnl_pkt(
    const ref chi_bfm_dat_t p);
  extern function string conv2str_snp_chnl_pkt(
    const ref chi_bfm_snp_t p);

  //
  //Methods invoked by internal logic
  //
<% if((obj.testBench == 'chi_aiu') || (obj.testBench == "fsys")) { %>
 `ifndef VCS
  extern local function new(string s = "chi_container");
 `else 
  extern function new(string s = "chi_container");
 `endif 
<%} else { %>
  extern local function new(string s = "chi_container");
<%}%>

  //Methods to manuplate m_txnid_pool
  extern task get_txnid(output int req_txnid);
  extern function void put_txnid(int req_txnid);
  extern task wait_until_thld_rchd();

  //Method to pick appropriate cacheline & to invoke addr_trans_mgr
  extern function bit pick_associated_cacheline(
    int txnid,
    const ref chi_rn_traffic_cmd_seq  user_req);
  extern function bit order_checks_on_req_txn(int txnid);
  extern function bit request_order_check(
    bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] addr);
  extern function bit endpoint_order_check(
    bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] addr, chi_bfm_opcode_type_t opcode_type);

  extern task check_unmapped_addr_in_gpa (input bit [ncoreConfigInfo::ADDR_WIDTH - 1 : 0] addr, output bit unmapped_addr_gpa);
  extern task check_addr_in_gpa (input bit [ncoreConfigInfo::ADDR_WIDTH - 1 : 0] addr, output bit mapped_addr_gpa);
  extern task get_addr_in_gpa (input bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] tmp_inp_addr, output bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] tmp_op_addr);
  extern function addr_width_t get_device_mem_addr(bit req_new_addr);
  extern function addr_width_t get_boot_mem_addr(bit req_new_addr);
  extern function addr_width_t get_boot_noncoh_mem_addr(bit req_new_addr);
  extern function addr_width_t get_boot_coh_mem_addr(bit req_new_addr);
  extern function addr_width_t get_normal_noncoh_mem_addr(bit req_new_addr);
  extern function addr_width_t get_normal_coh_mem_addr(bit req_new_addr);
  extern function bit get_normal_local_cache_addr(
    input chi_bfm_cache_state_t st, 
    output addr_width_t addr);
  extern function void invalidate_local_cache_addr(addr_width_t addr);

  extern function addr_width_t get_write_user_addrq_addr();
  extern function addr_width_t get_read_user_addrq_addr();

  //Methods invoked on Rsp channel processing
  extern function void initiate_exp_compack(int txnid, int dbid, chi_bfm_rsp_err_t m_rsp_err);
  extern function void initiate_wr_data(
    int txnid,
    int dbid,
    chi_bfm_cache_state_t end_state,
    bit wrdata_cancel,
    chi_bfm_rsp_err_t rsperr,
    chi_data_be_t info);
  extern function void initiate_snp_rsp(
    chi_bfm_cache_state_t    end_state,
    chi_bfm_snprsp_rsp_t     snprsp,
    chi_bfm_rsp_err_t        snprsp_err,
    bit [2:0]                datapull,
    const ref chi_bfm_snp_t  snp_txn);
  extern function void initiate_snp_data_rsp(
    chi_bfm_cache_state_t    end_state,
    chi_bfm_snprsp_data_t    snprsp_data,
    chi_bfm_rsp_err_t        snprsp_err,
    bit [2:0]                datapull,
    const ref chi_bfm_snp_t snp_txn);
  extern function void sch_any_state_blocked_txns();
  extern function void sch_any_order_block_txns(int txnid);
  extern function bit  sch_any_reqord_txns(int txnid);
  extern function bit  sch_any_edpord_txns(int txnid, chi_bfm_opcode_type_t opcode_type);
  extern function bit  is_addr_cacheable(addr_width_t addr);

  //Methods that operate m_chi_cache D.S
  extern function chi_bfm_cache_state_t get_installed_cache_state(
    addr_width_t addr);
  extern function void write_cacheline_data(
    int txnid,
    chi_data_be_t info);
  extern function void install_cacheline(
    chi_bfm_cache_state_t end_state,
    addr_width_t          cacheline_addr);
  extern function chi_bfm_cache_state_t get_end_state(
    int txnid,
    const ref chi_rsp_dat_chnl_resp_t m_resp);

  // newperf_test to allow loop. hence we are able to manage hit & miss
   int use_loop_addr; // nbr of addr before loop
   int use_loop_addr_offset; // addr_offset = nbr of miss

  //Internal check methods
  extern function bit is_rsp4txn_exp(int txnid);
  extern function bit is_read_receipt_exp(int txnid);
  extern function bit is_comp_exp(int txnid);
  extern function bit is_compdbid_exp(int txnid); 
  extern function bit is_dbid_exp(int txnid);
  extern function bit is_compdata_exp(int txnid);

  //Internal Helper methods
  extern function bit is_rdnosnp(int txnid);
  extern function bit is_rdonce(int txnid);
  extern function bit is_prefetch(int txnid);
  extern function bit is_wrnosnp(int txnid);
  extern function bit is_wrunq(int txnid);
  extern function bit is_atomic(int txnid);
  extern function bit is_partial(int txnid);
  extern function bit is_wrback(int txnid);
  extern function bit is_stash_snoop(chi_bfm_snp_opcode_t opcode);
  extern function addr_width_t aligned64B_addr(addr_width_t addr);
  extern function int pow2(int size);
  extern function int num_beats(int st_byte, int size);
  extern function int bus_align_const();
  extern function int mod64(int value);
  extern function bit [1:0] get_ccid(addr_width_t addr);
  extern function chi_bfm_copyback_rsp_t get_wrdat_resp(addr_width_t addr, chi_bfm_cache_state_t end_state);
  extern function bit txn_outsanding4addr(addr_width_t addr);
  extern function bit del_entry_in_req_ordq_if_any(int txnid);
endclass: chi_container

function chi_container::new(string s = "chi_container");
  chi_bfm_cache_state_t f;
  ncoreConfigInfo::addr_format_t af;

  super.new(s);
  uname = $psprintf("chi_container[%0d]", ID);
  m_req_sem = new(1);
  m_installed_cachelines = new[f.num()];
  m_chi_txns = new[256];
  user_addrq = new[f.num()];
  user_write_addrq = new[f.num()];
  user_read_addrq = new[f.num()];

  for (int i = 0; i < 256; ++i) begin
 //   <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
//	i[7:5]=ID; 
 //   <%}%>    
    m_txnid_pool.push_back(i);
    m_chi_txns[i] = chi_bfm_txn::type_id::create(
      $psprintf("chi_txn[%0d]", i));
  end
  m_txnid_pool.shuffle();

  m_addr_mgr = addr_trans_mgr::get_instance();
  m_tx_req_chnl_cb = chi_tx_req_chnl_cb#(ID)::type_id::create("req_cb"); 
  m_tx_rsp_chnl_cb = chi_tx_rsp_chnl_cb#(ID)::type_id::create("rsp_cb");
  m_tx_dat_chnl_cb = chi_tx_dat_chnl_cb#(ID)::type_id::create("dat_cb");
  m_rx_rsp_chnl_cb = chi_rx_rsp_chnl_cb#(ID)::type_id::create("rsp_cb");
  m_rx_dat_chnl_cb = chi_rx_dat_chnl_cb#(ID)::type_id::create("dat_cb");
  m_rx_snp_chnl_cb = chi_rx_snp_chnl_cb#(ID)::type_id::create("snp_cb");

  if($value$plusargs("max_stt_fill_count=%d",max_stt_fill_count)) begin
    fork
      begin
        forever begin
          `uvm_info("CHI_BFM_DEBUG", $psprintf("waiting for ev_max_snp_req_sent fill_stt: %0d, send_pending_snp_rsp: %0d, send_pending_snp_rsp_data: %0d", fill_stt, send_pending_snp_rsp, send_pending_snp_rsp_data), UVM_HIGH)
	      ev_max_snp_req_sent.wait_ptrigger();
          send_pending_snp_rsp = 1; 
          send_pending_snp_rsp_data = 1; 
          fill_stt = 0; 
	      stt_fill_count = stt_fill_count + 1;
          `uvm_info("CHI_BFM_DEBUG", $psprintf("done waiting for ev_max_snp_req_sent calling fill_stt: %0d, initiate_snp_rsp send_pending_snp_rsp: %0d, send_pending_snp_rsp_data: %0d", fill_stt, send_pending_snp_rsp, send_pending_snp_rsp_data), UVM_HIGH)
          initiate_snp_rsp(0, 0, 0, 0, temp_snp_txn);
          `uvm_info("CHI_BFM_DEBUG", $psprintf("done waiting for ev_max_snp_req_sent calling fill_stt: %0d, initiate_snp_data_rsp send_pending_snp_rsp: %0d, send_pending_snp_rsp_data: %0d", fill_stt, send_pending_snp_rsp, send_pending_snp_rsp_data), UVM_HIGH)
          initiate_snp_data_rsp(0, 0, 0, 0, temp_snp_txn);
          #(1ns);
        end
      end
      begin
        forever begin
          `uvm_info("CHI_BFM_DEBUG", $psprintf("waiting for ev_fill_stt fill_stt: %0d", fill_stt), UVM_HIGH)
          ev_fill_stt.wait_ptrigger();
          fill_stt = 1; 
          `uvm_info("CHI_BFM_DEBUG", $psprintf("done waiting for ev_fill_stt fill_stt: %0d", fill_stt), UVM_HIGH)
          #(1ns);
        end
      end
    join_none
  end 
 
 //newperf_test new plusargs to allow percentage of miss
 //for example:  loop_addr=100  & loop_addr_offset=10 with user_addrq =1000
 //=> 10 loops of 100 addr  with first loop 100% miss & 9 loop with 10% of miss
 //use plusargs doff_xx in newperf scoreboard to remove the first loop to calculate the BW 
  if(!$value$plusargs("use_loop_addr=%d",use_loop_addr)) begin
		  use_loop_addr = 0;
  end
 if(!$value$plusargs("use_loop_addr_offset=%d",use_loop_addr_offset)) begin
		  use_loop_addr_offset = 0;
  end
//newperf_test

  user_addrq_idx = new[af.num()];
  user_write_addrq_idx = new[af.num()];
  user_read_addrq_idx = new[af.num()];
  if($test$plusargs("use_seq_user_addrq")) begin
     foreach (user_addrq_idx[i])
       user_addrq_idx[i] = 0;
     foreach (user_write_addrq_idx[i])
       user_write_addrq_idx[i] = 0;
     foreach (user_read_addrq_idx[i])
       user_read_addrq_idx[i] = 0;
  end else begin
     foreach (user_addrq_idx[i])
       user_addrq_idx[i] = -1;
     foreach (user_write_addrq_idx[i])
       user_write_addrq_idx[i] = -1;
     foreach (user_read_addrq_idx[i])
       user_read_addrq_idx[i] = -1;
  end
  snprsp_skipped = 0;
  if(!$value$plusargs("snprsp_skip_chiaiu_id=%d", snprsp_skip_aiu_id)) begin
     snprsp_skip_aiu_id = 1;
  end

endfunction: new

function void chi_container::set_unit_args(
    const ref chi_aiu_unit_args args);
  
  m_args = args;
  m_tx_req_chnl_cb.set_chi_unit_args(m_args); 
  m_tx_rsp_chnl_cb.set_chi_unit_args(m_args); 
  m_tx_dat_chnl_cb.set_chi_unit_args(m_args); 
  m_rx_rsp_chnl_cb.set_chi_unit_args(m_args); 
  m_rx_dat_chnl_cb.set_chi_unit_args(m_args); 
  m_rx_snp_chnl_cb.set_chi_unit_args(m_args); 
endfunction: set_unit_args

task chi_container::construct_chi_txn(
  const ref chi_rn_traffic_cmd_seq io_txn);
  int txnid;
  int stashnid;
  int addr_region_sel;

  //Lock until current request is scheduled
  m_req_sem.get(1);
  //`uvm_info("CHI_BFM_DEBUG", $psprintf("txnid:0x%0h is being constructed", txnid), UVM_HIGH)
`ifdef VCS
  do begin
    get_txnid(txnid);
    #1;
  end 
  while(m_chi_txns[txnid].m_txn_valid == 1);
`else
  get_txnid(txnid);
`endif 

  `ASSERT(!m_chi_txns[txnid].m_txn_valid);
  m_chi_txns[txnid].m_txn_valid = 1;
  m_chi_txns[txnid].m_req_tgtid = io_txn.m_tgtid;
  m_chi_txns[txnid].m_req_srcid = ID;
  m_chi_txns[txnid].m_req_txnid = txnid;
  m_chi_txns[txnid].m_req_time  = $time;

  if (io_txn.m_rand_type == CMD_BASED) begin
    m_chi_txns[txnid].m_opcode_type    		= io_txn.m_opcode_type;  
    m_chi_txns[txnid].m_req_opcode     		= io_txn.m_opcode;
    m_chi_txns[txnid].m_req_size       		= io_txn.m_size.m_size;
    m_chi_txns[txnid].m_req_expcompack 		= io_txn.m_expcompack.m_expcompack;
    m_chi_txns[txnid].m_req_likelyshared 	= io_txn.m_likelyshared.m_likelyshared;
    m_chi_txns[txnid].m_req_allowretry  	= io_txn.m_allowretry.m_allowretry;
    m_chi_txns[txnid].m_req_memattr    		= {io_txn.m_cacheable_alloc.m_alloc,
      io_txn.m_cacheable_alloc.m_cacheable, io_txn.m_mem_type[0], io_txn.m_ewa};
    m_chi_txns[txnid].m_req_snpattr   		 = io_txn.m_snpattr;
    m_chi_txns[txnid].m_req_snoopme   		 = io_txn.m_snoopme;
    m_chi_txns[txnid].m_req_excl      		 = io_txn.m_excl.m_excl;
    m_chi_txns[txnid].m_req_stashnid      	 = io_txn.m_stashnid.m_stashnid;
    m_chi_txns[txnid].m_req_ns        		 = io_txn.m_ns.m_ns;
    m_chi_txns[txnid].m_req_lpid      		 = io_txn.m_lpid;
    m_chi_txns[txnid].m_req_order     		 = io_txn.m_order.m_order;
    m_chi_txns[txnid].m_req_endian    		 = 0;
    m_chi_txns[txnid].m_req_qos       		 = io_txn.m_qos;

//$display("%s, memattr value %x, %x", io_txn.m_opcode.name(), m_chi_txns[txnid].m_req_memattr, {io_txn.m_cacheable_alloc.m_alloc, io_txn.m_cacheable_alloc.m_cacheable, io_txn.m_mem_type, io_txn.m_ewa});

    // newperf_test  add stash BW test 
    if ($value$plusargs("chi<%=obj.Id%>_stashnid=%d",stashnid)) begin
         m_chi_txns[txnid].m_req_stashnid = stashnid;
		 m_chi_txns[txnid].m_req_stashnid_valid = 1;
     end
	 // end nexperf_test 
    if ((io_txn.m_opcode_type == WR_CPYBCK_CMD) && (io_txn.cache_flush_start == 'h1)) begin
          m_chi_txns[txnid].m_req_addr = cache_flush_addr;
          if (order_checks_on_req_txn(txnid)) begin
            m_tx_req_chnl_cb.put_chi_txn(m_chi_txns[txnid]);
          end else begin
            m_chi_txns[txnid].m_txn_order_blkd = 1'b1;
            m_unscheduled_txnq.push_back(txnid);
          end
    end else if (io_txn.m_opcode_type == DVM_OPERT_CMD) begin
      if($test$plusargs("use_same_dvm_addr")) begin
          if (same_dvm_addr == 'h0) begin
              same_dvm_addr = io_txn.m_dvm_addr_data.m_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0];
          end
          m_chi_txns[txnid].m_req_addr = same_dvm_addr;
      end
      else begin
          m_chi_txns[txnid].m_req_addr = io_txn.m_dvm_addr_data.m_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0];
          if($test$plusargs("dvm_addr_region_overlap")) begin
              addr_region_sel = $urandom_range(ncoreConfigInfo::NGPRA+2,0);
              `uvm_info("CHI_BFM_DEBUG-construct_chi_txn", $psprintf("addr_region_sel = %0d",addr_region_sel), UVM_HIGH)
              if (addr_region_sel < ncoreConfigInfo::NGPRA) begin
                  m_chi_txns[txnid].m_req_addr = (m_chi_txns[txnid].m_req_addr & ((1 << (ncoreConfigInfo::memregions_info[addr_region_sel].size+12)) - 1)) | ncoreConfigInfo::memregions_info[addr_region_sel].start_addr;
                  `uvm_info("CHI_BFM_DEBUG-construct_chi_txn", $psprintf("DVM GPRA region addr = %0x",m_chi_txns[txnid].m_req_addr), UVM_HIGH)
              end else if (addr_region_sel == ncoreConfigInfo::NGPRA) begin
                  m_chi_txns[txnid].m_req_addr = (m_chi_txns[txnid].m_req_addr & (ncoreConfigInfo::NRS_REGION_SIZE - 1)) | ncoreConfigInfo::NRS_REGION_BASE;
                  `uvm_info("CHI_BFM_DEBUG-construct_chi_txn", $psprintf("DVM NRS region addr = 0x%0x",m_chi_txns[txnid].m_req_addr), UVM_HIGH)
              end else if (addr_region_sel == (ncoreConfigInfo::NGPRA+1)) begin
                  m_chi_txns[txnid].m_req_addr = (m_chi_txns[txnid].m_req_addr & (ncoreConfigInfo::BOOT_REGION_SIZE - 1)) | ncoreConfigInfo::BOOT_REGION_BASE;
                  `uvm_info("CHI_BFM_DEBUG-construct_chi_txn", $psprintf("DVM BOOT region addr = 0x%0x",m_chi_txns[txnid].m_req_addr), UVM_HIGH)
              end else begin
                  `uvm_info("CHI_BFM_DEBUG-construct_chi_txn", $psprintf("DVM non NRS/BOOT/NRS region addr = 0x%0x",m_chi_txns[txnid].m_req_addr), UVM_HIGH)
              end
          end
      end
      m_chi_txns[txnid].m_req_ns   = 0; //Table 8-1 CHI Spec
      if (order_checks_on_req_txn(txnid)) begin
        m_tx_req_chnl_cb.put_chi_txn(m_chi_txns[txnid]);
      end else begin
        m_chi_txns[txnid].m_txn_order_blkd = 1'b1;
        m_unscheduled_txnq.push_back(txnid);
      end
    end else if (io_txn.m_opcode_type == RQ_LCRDRT_CMD) begin
        m_tx_req_chnl_cb.put_chi_txn(m_chi_txns[txnid]);
    end else if (pick_associated_cacheline(txnid, io_txn)) begin
      `uvm_info("CHI_BFM_DEBUG-construct_chi_txn", $psprintf("txnid: 0x%0h Inside pick_associated_cacheline",txnid), UVM_HIGH)
      if (order_checks_on_req_txn(txnid)) begin
        m_tx_req_chnl_cb.put_chi_txn(m_chi_txns[txnid]);
        ////For PRE_FETCH_CMD
        //if (m_chi_txns[txnid].m_opcode_type == PRE_FETCH_CMD) begin
        //    sch_any_state_blocked_txns();
        //    m_chi_txns[txnid].reset();
        //    put_txnid(txnid);
        //end
      end else begin
        m_chi_txns[txnid].m_txn_order_blkd = 1'b1;
        `uvm_info("CHI_BFM_DEBUG", $psprintf("txnid: 0x%0h is order blocked with addr: 0x%0h", txnid, m_chi_txns[txnid].m_req_addr), UVM_HIGH)
        m_unscheduled_txnq.push_back(txnid);
      end
    end else begin
      m_chi_txns[txnid].m_txn_state_blkd = 1'b1;
      m_chi_txns[txnid].set_cache_st(io_txn.m_start_state);
      `uvm_info("CHI_BFM_DEBUG", $psprintf("txnid:0x%0h is being state_blocked", txnid), UVM_HIGH)
      m_unscheduled_txnq.push_back(txnid);
    end
  end else begin
    `ASSERT(0, "NOT YET IMPLEMENTED");
  end

  //wait(m_tx_req_chnl_cb.size() < 8);   
  //Unlock semaphore
  `uvm_info("CHI_BFM_DEBUG-construct_chi_txn", $psprintf("txnid: 0x%0h m_unscheduled_txnq.size %0d Unlocking semaphore m_req_sem", txnid, m_unscheduled_txnq.size,m_chi_txns[txnid].m_req_addr), UVM_HIGH)
  m_req_sem.put(1);
endtask: construct_chi_txn

task chi_container::construct_chi_stashing_snprsp();
  int txnid;

  wait(m_chi_stash_rspq.size() > 0);
  //Lock until current request is scheduled
  // Commenting below semaphore out because it caused a simulation hang (deadlock) 
  // The reason it was put in in the first place was to make sure that we get
  // unique txnid
  //m_req_sem.get(1);
//  get_txnid(txnid);
`ifdef VCS
  do begin
    get_txnid(txnid);
  end 
  while(m_chi_txns[txnid].m_txn_valid == 1);
`else
  get_txnid(txnid);
`endif 
  
  `ASSERT(!m_chi_txns[txnid].m_txn_valid);
  m_chi_txns[txnid].m_txn_valid = 1;
  m_chi_txns[txnid].m_req_tgtid = m_chi_stash_rspq[0].stash_rsp.tgtid;
  m_chi_txns[txnid].m_req_srcid = ID;//m_chi_stash_rspq[0].stash_rsp.srcid;
  m_chi_txns[txnid].m_req_txnid = txnid;
  m_chi_txns[txnid].m_opcode_type = SNP_STASH_CMD;
  m_chi_txns[txnid].m_sth_opcode = m_chi_stash_rspq[0].opcode;
  m_chi_txns[txnid].m_req_addr = m_chi_stash_rspq[0].addr << 3;
  m_chi_txns[txnid].m_req_ns   = m_chi_stash_rspq[0].ns;
  m_chi_txns[txnid].m_req_size  = 6;
  m_chi_txns[txnid].m_req_time  = $time;

//$display("construct snp rsp txnid: %x req_addr %x", m_chi_txns[txnid].m_req_txnid, m_chi_txns[txnid].m_req_addr);

  if (m_chi_stash_rspq[0].snp_type == BFM_SNPRSP) begin
    m_chi_stash_rspq[0].stash_rsp.dbid = txnid;
    m_tx_rsp_chnl_cb.put_chi_txn(m_chi_stash_rspq[0].stash_rsp);
    if ($test$plusargs("SNPrsp_with_non_data_error") || (k_snp_rsp_non_data_err_wgt != 0)) begin
      // when datapull is 1, then only m_chi_stash_rspq is being filled
      if(m_chi_stash_rspq[0].stash_rsp.m_resp.get_resp_err() == BFM_RESP_NDERR) begin
        `uvm_info(get_full_name(), $sformatf("CONC-7061 fix. put_txnid:0x%0h, chi_snp_req_txnid:0x%0h", txnid, m_chi_stash_rspq[0].stash_rsp.txnid), UVM_LOW)
        m_chi_txns[txnid].reset();
        put_txnid(txnid);
      end
    end
  end else begin
    m_chi_stash_rspq[0].stash_dat.dbid = txnid;
    m_tx_dat_chnl_cb.put_chi_txn(m_chi_stash_rspq[0].stash_dat);
  end

  void'(m_chi_stash_rspq.pop_front());
  //Unlock semaphore
  //m_req_sem.put(1);
endtask: construct_chi_stashing_snprsp

task chi_container::get_txreq_chnl_txn(output chi_bfm_txn req_txn);
  m_tx_req_chnl_cb.get_chi_txn(req_txn);
endtask: get_txreq_chnl_txn

task chi_container::put_txreq_chnl_txn(input chi_bfm_txn req_txn);
  m_tx_req_chnl_cb.put_chi_txn(req_txn);
endtask: put_txreq_chnl_txn

task chi_container::get_txrsp_chnl_txn(output chi_bfm_rsp_t rsp_txn);
  m_tx_rsp_chnl_cb.get_chi_txn(rsp_txn);
endtask: get_txrsp_chnl_txn

task chi_container::get_txdat_chnl_txn(output chi_bfm_dat_t dat_txn);
<%if(obj.testBench == "fsys" || obj.testBench == "emu"){ %>
  m_tx_dat_chnl_cb.get_chi_txn(dat_txn);
<%} else { %>
  m_tx_dat_chnl_cb.get_chi_txn(dat_txn, m_txnid_pool);
<%}%>
endtask: get_txdat_chnl_txn

function void chi_container::put_rxrsp_chnl_txn(chi_bfm_rsp_t rsp_txn);
 bit wrdata_cancel;
  
  `ASSERT(rsp_txn.tgtid == ID);
  //Invoke RxRsp call-back to randomize certain fields
  if (m_chi_txns[rsp_txn.txnid].get_opcode_type() == UNSUP_TXN_CMD) begin  
      sch_any_state_blocked_txns();
      m_chi_txns[rsp_txn.txnid].reset();
      put_txnid(rsp_txn.txnid);
      return;
  end
  if (rsp_txn.m_resp.get_rsp_opcode_type() == BFM_RESPLCRDRETURN) 
	`ASSERT(rsp_txn.txnid!='0);
  
  if (rsp_txn.m_resp.get_rsp_opcode_type() !== BFM_READRECEIPT)
    m_rx_rsp_chnl_cb.rcvd_chi_txn(rsp_txn, this);
  case (rsp_txn.m_resp.get_rsp_opcode_type())
    BFM_COMP: begin
      `ASSERT(is_comp_exp(rsp_txn.txnid));
      m_chi_txns[rsp_txn.txnid].m_comprsp_rcvd = 1;
      m_chi_txns[rsp_txn.txnid].m_comprsp_time = $time();

      if (m_chi_txns[rsp_txn.txnid].get_opcode_type() == DT_LS_UPD_CMD) begin
        chi_data_be_t info;
        addr_width_t  coh_addr;

        coh_addr = m_chi_txns[rsp_txn.txnid].get_cacheline_addr();
        install_cacheline(m_rx_rsp_chnl_cb.get_end_state(), 
                          m_chi_txns[rsp_txn.txnid].get_cacheline_addr());
        if(m_rx_rsp_chnl_cb.get_end_state() == CHI_UDP)
    		`uvm_info(get_full_name(), $sformatf("UDP state with addr %x",  m_chi_txns[rsp_txn.txnid].get_cacheline_addr()), UVM_LOW)


        //if (m_rx_rsp_chnl_cb.get_end_state() == CHI_UD ||
        //    m_rx_rsp_chnl_cb.get_end_state() == CHI_UDP)
        if (m_rx_rsp_chnl_cb.get_end_state() == CHI_UDP)
           write_cacheline_data(
               rsp_txn.txnid,
               m_rx_rsp_chnl_cb.get_data_be());
      end

      if (m_chi_txns[rsp_txn.txnid].m_req_expcompack)
        initiate_exp_compack(rsp_txn.txnid, rsp_txn.dbid, m_rx_rsp_chnl_cb.get_err_resp());

//$display("init_compack resp_err %s txnid: %x", m_rx_rsp_chnl_cb.get_err_resp.name,rsp_txn.dbid);

      if($test$plusargs("use_stash") && $test$plusargs("fsys_coverage")) begin
          if (m_chi_txns[rsp_txn.txnid].get_opcode_type() == DT_LS_STH_CMD) begin
            install_cacheline(CHI_IX,m_chi_txns[rsp_txn.txnid].get_cacheline_addr());
          end
      end
      
      if (m_chi_txns[rsp_txn.txnid].is_ok2reset()) begin
        sch_any_state_blocked_txns();
        m_chi_txns[rsp_txn.txnid].reset();
        put_txnid(rsp_txn.txnid);
      end
    end

    BFM_COMPDBIDRESP: begin
      `ASSERT(is_compdbid_exp(rsp_txn.txnid));
      m_chi_txns[rsp_txn.txnid].m_comprsp_rcvd = 1;
      m_chi_txns[rsp_txn.txnid].m_dbidrsp_rcvd = 1;
      m_chi_txns[rsp_txn.txnid].m_comprsp_time = $time();
      m_chi_txns[rsp_txn.txnid].m_dbidrsp_time = $time();
      wrdata_cancel = m_rx_rsp_chnl_cb.get_wrdata_cancel();
      initiate_wr_data(
          rsp_txn.txnid,
          rsp_txn.dbid,
          m_rx_rsp_chnl_cb.get_end_state(),
          //m_rx_rsp_chnl_cb.get_wrdata_cancel(),
          wrdata_cancel,
          m_rx_rsp_chnl_cb.get_err_resp(),
          m_rx_rsp_chnl_cb.get_data_be()
      );
      if (m_chi_txns[rsp_txn.txnid].m_req_expcompack)
        initiate_exp_compack(rsp_txn.txnid, rsp_txn.dbid, m_rx_rsp_chnl_cb.get_err_resp());
      sch_any_order_block_txns(rsp_txn.txnid);

      if (m_chi_txns[rsp_txn.txnid].is_ok2reset()) begin
        sch_any_state_blocked_txns();
        m_chi_txns[rsp_txn.txnid].reset();
        put_txnid(rsp_txn.txnid);
      end
    end

    BFM_DBIDRESP: begin
      `ASSERT(is_dbid_exp(rsp_txn.txnid));
      m_chi_txns[rsp_txn.txnid].m_dbidrsp_rcvd = 1;
      m_chi_txns[rsp_txn.txnid].m_dbidrsp_time = $time();
      wrdata_cancel = m_rx_rsp_chnl_cb.get_wrdata_cancel();
      initiate_wr_data(
          rsp_txn.txnid,
          rsp_txn.dbid,
          m_rx_rsp_chnl_cb.get_end_state(),
          //m_rx_rsp_chnl_cb.get_wrdata_cancel(),
          wrdata_cancel,
          m_rx_rsp_chnl_cb.get_err_resp(),
          m_rx_rsp_chnl_cb.get_data_be()
      );
      sch_any_order_block_txns(rsp_txn.txnid);

      if (m_chi_txns[rsp_txn.txnid].is_ok2reset()) begin
        sch_any_state_blocked_txns();
        m_chi_txns[rsp_txn.txnid].reset();
        put_txnid(rsp_txn.txnid);
      end
    end

    BFM_READRECEIPT: begin
      `ASSERT(is_read_receipt_exp(rsp_txn.txnid));
      m_chi_txns[rsp_txn.txnid].m_rdrcpt_rcvd = 1;
      m_chi_txns[rsp_txn.txnid].m_rdrcpt_time = $time();
      sch_any_order_block_txns(rsp_txn.txnid);

      if (m_chi_txns[rsp_txn.txnid].is_ok2reset()) begin
        sch_any_state_blocked_txns();
        m_chi_txns[rsp_txn.txnid].reset();
        put_txnid(rsp_txn.txnid);
      end
    end

    //default: if (!$test$plusargs("unmapped_add_access")) begin
    default: if ($test$plusargs("non_secure_access_test") || !$test$plusargs("unmapped_add_access") || ($test$plusargs("unmapped_add_access") && !addr_trans_mgr::check_unmapped_add(m_chi_txns[rsp_txn.txnid].m_req_addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)) || ($test$plusargs("pick_boundary_addr") && !addr_trans_mgr::check_unmapped_add(m_chi_txns[rsp_txn.txnid].m_req_addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type))) begin
      string s;
      $sformat(s, "%s ERROR unexpected opcode received on RXRSP channel: ", s);
      $sformat(s, "%s %s", s, conv2str_rsp_chnl_pkt(rsp_txn));
      `uvm_fatal(uname, s)
    end
  endcase
endfunction: put_rxrsp_chnl_txn

function void chi_container::put_rxdat_chnl_txn(chi_bfm_dat_t dat_txn);
  `ASSERT(dat_txn.tgtid == ID );
  case (dat_txn.m_resp.get_dat_opcode_type())
    BFM_COMPDATA: begin
      `ASSERT(is_compdata_exp(dat_txn.txnid));
      m_rx_dat_chnl_cb.rcvd_chi_txn(dat_txn, this);

      if (m_chi_txns[dat_txn.txnid].all_rxdat_flits_rcvd()) begin
        //Determine the state transition of current cacheline
        if (is_addr_cacheable(m_chi_txns[dat_txn.txnid].m_req_addr) ||
            (is_atomic(dat_txn.txnid) && m_chi_txns[dat_txn.txnid].m_req_snpattr)) begin

          if ((m_rx_dat_chnl_cb.get_err_resp(dat_txn.txnid) == BFM_RESP_OK) || (m_chi_txns[dat_txn.txnid].m_req_excl && (m_rx_dat_chnl_cb.get_err_resp(dat_txn.txnid) == BFM_RESP_EXOK))) begin
            install_cacheline(
                m_rx_dat_chnl_cb.get_end_state(dat_txn.txnid),
                m_chi_txns[dat_txn.txnid].get_cacheline_addr());
            write_cacheline_data(
                dat_txn.txnid,
                m_rx_dat_chnl_cb.get_data_be(dat_txn.txnid));
          end
          else begin
            void'(m_rx_dat_chnl_cb.get_data_be(dat_txn.txnid));
          end

        end else begin
          //For non-coherent transactions & atomic we invoke get_data_be()
          //to clear the flag
          void'(m_rx_dat_chnl_cb.get_data_be(dat_txn.txnid));
        end
        if (m_chi_txns[dat_txn.txnid].m_req_expcompack ||
            m_chi_txns[dat_txn.txnid].get_opcode_type() == SNP_STASH_CMD) begin

          initiate_exp_compack(dat_txn.txnid, dat_txn.dbid, m_rx_dat_chnl_cb.get_err_resp(dat_txn.txnid));
        end

        if (m_chi_txns[dat_txn.txnid].is_ok2reset()) begin
          sch_any_state_blocked_txns();
          m_chi_txns[dat_txn.txnid].reset();
          put_txnid(dat_txn.txnid);
        end
      end
    end
    default: begin
      string s;
      $sformat(s, "%s ERROR unexpected opcode received on RXRSP channel: ", s);
      $sformat(s, "%s %s", s, conv2str_dat_chnl_pkt(dat_txn));
      `uvm_fatal(uname, s)
    end
  endcase
endfunction: put_rxdat_chnl_txn

function void chi_container::put_rxsnp_chnl_txn(chi_bfm_snp_t snp_txn);

 // `ASSERT(snp_txn.tgtid == ID); snoop req doesn't have a tgt ID
  m_rx_snp_chnl_cb.rcvd_chi_txn(snp_txn, this);

  //DVMop needs 2 part snoops, do not send a response until both parts are received
  if (snp_txn.opcode == BFM_SNPDVMOP 
      && !m_rx_snp_chnl_cb.get_snprsp_rdy(snp_txn.txnid))
  begin
    return;
  end
  if (snp_txn.opcode == BFM_SNPDVMOP)
      m_rx_snp_chnl_cb.reset_snpreq_observed_flag(snp_txn.txnid);

//$display("Rcv snp: addr %x, snprsp %x", snp_txn.addr, m_rx_snp_chnl_cb.get_snprsp_type());

  if($test$plusargs("dvm_hang_test") && (snprsp_skip_aiu_id == ID) && (snprsp_skipped==0)) begin
     snprsp_skipped = 1;
     return;
  end

  case (m_rx_snp_chnl_cb.get_snprsp_type())
    BFM_SNPRSP: begin
      initiate_snp_rsp(
          m_rx_snp_chnl_cb.get_end_state(),
          m_rx_snp_chnl_cb.get_snprsp(),
          m_rx_snp_chnl_cb.get_snprsp_err(),
          m_rx_snp_chnl_cb.get_datapull(),
          snp_txn
      );
    end

    BFM_SNPRSP_DATA: begin
      initiate_snp_data_rsp(
          m_rx_snp_chnl_cb.get_end_state(),
          m_rx_snp_chnl_cb.get_snprsp_data(),
          m_rx_snp_chnl_cb.get_snprsp_err(),
          m_rx_snp_chnl_cb.get_datapull(),
          snp_txn
      );
    end
    default: `ASSERT(0, "Not yet Implemented");
  endcase

endfunction: put_rxsnp_chnl_txn

function void chi_container::print_pending_txns();
  if (m_txnid_pool.size() != 256) begin
    `uvm_info(uname, "ERROR: Above pending transactions in CHI-BFM", UVM_NONE)
    `uvm_info(uname, $psprintf("ERROR: m_unscheduled_txnq.size()=%0d, m_tx_req_chnl_cb.size()=%0d", m_unscheduled_txnq.size(), m_tx_req_chnl_cb.size()), UVM_NONE)
    `uvm_info(uname, $psprintf("ERROR: end_req: %0d", m_pend_endpoint_txnq.size()), UVM_NONE)
    foreach (m_unscheduled_txnq[idx]) begin
      `uvm_info(uname, $psprintf("ERROR: %0d unscheduled_txnq=0x%0h", idx, m_unscheduled_txnq[idx]), UVM_NONE)
      `uvm_info(uname, m_chi_txns[m_unscheduled_txnq[idx]].convert2string(), UVM_NONE)
    end
    `uvm_info(uname, $psprintf("end_req: %0d", m_pend_endpoint_txnq.size()), UVM_NONE)
    foreach (m_pend_endpoint_txnq[idx])
      `uvm_info(uname, $psprintf("ERROR: %0d endpoint_ord=0x%0h", idx, m_pend_endpoint_txnq[idx]), UVM_NONE)
    `uvm_info(uname, $psprintf("req_order: %0d", m_pend_reqorder_txnq.size()), UVM_NONE)
    foreach (m_pend_reqorder_txnq[idx])
      `uvm_info(uname, $psprintf("ERROR: req_ord=0x%0h", m_pend_reqorder_txnq[idx]), UVM_NONE)
    
    foreach (m_chi_txns[idx]) begin
      if (m_chi_txns[idx].m_txn_valid) begin
        `uvm_info(uname, m_chi_txns[idx].convert2string(), UVM_NONE)
      end
    end
  end
endfunction: print_pending_txns

function void chi_container::set_chi_node_type(
  chi_bfm_node_t node_type,
  int            nbytes);
  m_bfm_node_type   = node_type;
  m_nbytes_per_flit = nbytes;
endfunction: set_chi_node_type

task chi_container::check_unmapped_addr_in_gpa(input bit [ncoreConfigInfo::ADDR_WIDTH - 1 : 0] addr, output bit unmapped_addr_gpa);

    unmapped_addr_gpa = 0;

    foreach(ncoreConfigInfo::memregion_boundaries[idx]) begin
        if ((addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0] >= ncoreConfigInfo::memregion_boundaries[idx].start_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]) && (addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0] <= (ncoreConfigInfo::memregion_boundaries[idx].end_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]-1))) begin
            unmapped_addr_gpa = 1;
        end
    end

endtask: check_unmapped_addr_in_gpa

task chi_container::check_addr_in_gpa(input bit [ncoreConfigInfo::ADDR_WIDTH - 1 : 0] addr, output bit mapped_addr_gpa);

    mapped_addr_gpa = 0;

    foreach(ncoreConfigInfo::memregion_boundaries[idx]) begin
        if (addr inside {[ncoreConfigInfo::memregion_boundaries[idx].start_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0] : (ncoreConfigInfo::memregion_boundaries[idx].end_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]-1)]} ) begin

            mapped_addr_gpa = 1;
        end
    end

endtask: check_addr_in_gpa

task chi_container::get_addr_in_gpa(input bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] tmp_inp_addr, output bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] tmp_op_addr);

     bit[2:0] sel_boundary_addr ;
     bit mapped_addr_in_gpa = 0;
     sel_boundary_addr = $urandom_range(4,1);
     foreach(ncoreConfigInfo::memregion_boundaries[idx]) begin
        if (tmp_inp_addr inside {[ncoreConfigInfo::memregion_boundaries[idx].start_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0] : (ncoreConfigInfo::memregion_boundaries[idx].end_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]-1)]} ) begin

          if (sel_boundary_addr == 1) begin
                tmp_op_addr = ncoreConfigInfo::memregion_boundaries[idx].start_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]; 
          end else if (sel_boundary_addr == 2) begin
                tmp_op_addr = ncoreConfigInfo::memregion_boundaries[idx].end_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]-1; 
          end else if (sel_boundary_addr == 3) begin
                tmp_op_addr = ncoreConfigInfo::memregion_boundaries[idx].start_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]-1; 
                check_addr_in_gpa(tmp_op_addr, mapped_addr_in_gpa); 
                if (mapped_addr_in_gpa) begin
                    tmp_op_addr = ncoreConfigInfo::memregion_boundaries[idx].start_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]; 
                end
                if (tmp_op_addr  == 'h0) begin
                    tmp_op_addr = ncoreConfigInfo::memregion_boundaries[idx].start_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]; 
                end
          end else if (sel_boundary_addr == 4) begin
                tmp_op_addr = ncoreConfigInfo::memregion_boundaries[idx].end_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]; 
                check_addr_in_gpa(tmp_op_addr, mapped_addr_in_gpa); 
                if (mapped_addr_in_gpa) begin
                    tmp_op_addr = ncoreConfigInfo::memregion_boundaries[idx].end_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]-1; 
                end
                if (tmp_op_addr  == 'h0) begin
                    tmp_op_addr = ncoreConfigInfo::memregion_boundaries[idx].end_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]-1; 
                end
          end
        end
     end


endtask: get_addr_in_gpa

function bit chi_container::pick_associated_cacheline(
  int txnid,
  const ref chi_rn_traffic_cmd_seq  user_req);
  int addr_try_counter = 0;
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] random_unmapped_addr;
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] tmp_inp_addr;
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] tmp_out_addr;
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] addr;
  int k_unmapped_add_access_wgt;
  bit unmapped_addr_in_gpa = 1;

  if (user_req.m_addr_type == NON_COH_ADDR) begin
    if(user_req.m_boot_addr == 1) begin
      addr = get_boot_noncoh_mem_addr(user_req.m_new_addr);
    end
   <%if(obj.AiuInfo[obj.Id].nDiis >1){%>
    else if (user_req.m_mem_type == DEVICE) begin
          addr = get_device_mem_addr(user_req.m_new_addr);
          if(ncoreConfigInfo::NUM_DIIS > 1) begin
             `ASSERT(addr != 0);
	  end
    end else begin
   <%}else{%>
    else begin
   <%}%>
      <% if (obj.initiatorGroups.length >= 1) { %>
        int try_count = 10_000;

        do begin // Force addr to be connected to the initiator
          addr = get_normal_noncoh_mem_addr(user_req.m_new_addr);
          try_count--;
        end while(try_count!=0  && !$test$plusargs("unmapped_add_access") && ncoreConfigInfo::check_unmapped_add(addr, <%=obj.AiuInfo[obj.Id].FUnitId%>, dec_err_type));
        
        if(!try_count) begin
          $stacktrace();
          `uvm_error("Connectivity Interleaving CHI CONTAINER",$sformatf("Not succeed to generate connected addr inside user_addrq, Hitting possible 0-time infinite loop here"))
        end 
        <% } else { %>
        addr = get_normal_noncoh_mem_addr(user_req.m_new_addr);
        <% } %>
       
          if(ncoreConfigInfo::NUM_DIIS > 1) begin
             `ASSERT(addr != 0);
          end
    end
  end else begin
    `ASSERT(user_req.m_mem_type == NORMAL);
    if(user_req.m_boot_addr == 1) begin
      addr = get_boot_coh_mem_addr(user_req.m_new_addr);
    end
    else if (user_req.m_start_state == CHI_IX ) begin // || user_req.m_new_addr ) begin
          addr_try_counter = 0;
          //Added a loop to check if the new address already exists in the local cache or not, for CONC-4909
          do begin 
              if($test$plusargs("perf_test") && $test$plusargs("use_user_addrq") && $test$plusargs("use_user_write_read_addrq")) begin
                  if((user_req.m_opcode_type == WR_COHUNQ_CMD)||(user_req.m_opcode_type == WR_NONCOH_CMD)) begin
                     addr = get_write_user_addrq_addr();
                  end
		  else if((user_req.m_opcode_type == RD_RDONCE_CMD)||(user_req.m_opcode_type == RD_LDRSTR_CMD)||(user_req.m_opcode_type == RD_NONCOH_CMD)) begin
                     addr = get_read_user_addrq_addr();
                  end
	      end
        else begin	  
                  <% if (obj.initiatorGroups.length >= 1) { %>
                  int try_count = 10_000;
                  do begin // Force addr to be connected to the initiator
                  <% } %>
                  addr = get_normal_coh_mem_addr(1);
                  <% if (obj.initiatorGroups.length >= 1) { %>
                  try_count--;
                  end while(try_count!=0  && !$test$plusargs("unmapped_add_access") && ncoreConfigInfo::check_unmapped_add(addr, <%=obj.AiuInfo[obj.Id].FUnitId%>, dec_err_type));
                  
                  if(!try_count) begin
                    `uvm_error("Connectivity Interleaving CHI CONTAINER",$sformatf("Not succeed to generate connected addr inside user_addrq, Hitting possible 0-time infinite loop here"))
                  end 
                  <% } %>
                  addr_try_counter++;
                  if (addr_try_counter > 50 || $test$plusargs("seq_case")) begin //newperf_test add plusargs
                      `uvm_warning(get_type_name(), $psprintf("Number of tries to get a new address failed for 50 times"));
                      break;
                  end
                end // else: !if($test$plusargs("perf_test") && $test$plusargs("use_user_addrq") && $test$plusargs("use_user_write_read_addrq"))
          end while (m_chi_cache.exists(aligned64B_addr(addr)));
          `ASSERT(addr != 0);
          install_cacheline(user_req.m_start_state, addr);
          //$display("%t, CHI[%d], 8normal addr %x, opocode %s, start state %s", $time, ID, addr, user_req.m_opcode.name, user_req.m_start_state.name());
    end else begin
      bit ret;

      ret = get_normal_local_cache_addr(user_req.m_start_state, addr);
       
      //$display("%t, CHI[%d], normal addr %x, opocode %s ret %X", $time, ID, addr, user_req.m_opcode.name, ret);

      if (ret) begin
        `ASSERT(addr != 0);
      end else begin
        return 0;
      end
    end // else: !if(user_req.m_start_state == CHI_IX || user_req.m_new_addr )
  end // else: !if(user_req.m_addr_type == NON_COH_ADDR)

  m_chi_txns[txnid].m_req_addr = addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0];

 if (!$test$plusargs("non_secure_access_test")) begin
     m_chi_txns[txnid].m_req_ns   = addr[ncoreConfigInfo::W_SEC_ADDR - 1];
 end

  if ($value$plusargs("unmapped_add_access=%d",k_unmapped_add_access_wgt)) begin
    randcase
      k_unmapped_add_access_wgt: begin       
                                        std::randomize(random_unmapped_addr) with {!(random_unmapped_addr inside {[ncoreConfigInfo::BOOT_REGION_BASE : (ncoreConfigInfo::BOOT_REGION_BASE + ncoreConfigInfo::BOOT_REGION_SIZE)]});
                                                                                   !(random_unmapped_addr inside {[ncoreConfigInfo::NRS_REGION_BASE : (ncoreConfigInfo::NRS_REGION_BASE + ncoreConfigInfo::NRS_REGION_SIZE)]});
                                                                                     foreach(ncoreConfigInfo::memregion_boundaries[idx]) {
                                                                                       !(random_unmapped_addr inside {[ncoreConfigInfo::memregion_boundaries[idx].start_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0] : (ncoreConfigInfo::memregion_boundaries[idx].end_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]-1)]});
                                                                                     }
                                                                                  };

                                        while (unmapped_addr_in_gpa == 1) begin // CONC-9644
                                           foreach(ncoreConfigInfo::memregion_boundaries[idx]) begin
                                               if ((random_unmapped_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0] >= ncoreConfigInfo::memregion_boundaries[idx].start_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]) && (random_unmapped_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0] <= (ncoreConfigInfo::memregion_boundaries[idx].end_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0]-1))) begin
                                                      random_unmapped_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0] = ncoreConfigInfo::memregion_boundaries[idx].end_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0];
                                               end
                                            end
                                            check_unmapped_addr_in_gpa(random_unmapped_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0], unmapped_addr_in_gpa); // CONC-9644
                                        end 

                                        m_chi_txns[txnid].m_req_addr = random_unmapped_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0];
                                        m_chi_txns[txnid].m_req_ns   = random_unmapped_addr[ncoreConfigInfo::W_SEC_ADDR - 1];
                                 end
      (100-k_unmapped_add_access_wgt):begin
                                        m_chi_txns[txnid].m_req_addr = addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0];
                                        m_chi_txns[txnid].m_req_ns   = addr[ncoreConfigInfo::W_SEC_ADDR - 1];
                                   end
    endcase
    
  end

  if (is_atomic(txnid)) 
    m_chi_txns[txnid].m_req_addr[5:0] = user_req.m_size.m_starting_byte;

  if ($test$plusargs("atomic_fcov")) begin
     if (!is_atomic(txnid)) begin
      if (m_nbytes_per_flit == 32)
          m_chi_txns[txnid].m_req_addr[4] = 1'b0;
      if (m_nbytes_per_flit == 64)
          m_chi_txns[txnid].m_req_addr[5:4] = 2'b00;
     end
  end else begin
      if (is_atomic(txnid)) begin
          if (m_nbytes_per_flit == 32)
              m_chi_txns[txnid].m_req_addr[4] = 1'b0;
          if (m_nbytes_per_flit == 64)
              m_chi_txns[txnid].m_req_addr[5:4] = 2'b00;
      end else begin
<%if(obj.testBench == "fsys"){ %>
          if (m_nbytes_per_flit == 32)
              m_chi_txns[txnid].m_req_addr[4:0] = ((m_chi_txns[txnid].m_req_opcode == BFM_WRITENOSNPFULL) && (m_chi_txns[txnid].m_req_memattr[1] == 1)) ? 0 : $urandom_range(0,m_nbytes_per_flit-1);
          if (m_nbytes_per_flit == 16)
              m_chi_txns[txnid].m_req_addr[3:0] = ((m_chi_txns[txnid].m_req_opcode == BFM_WRITENOSNPFULL) && (m_chi_txns[txnid].m_req_memattr[1] == 1)) ? 0 : $urandom_range(0,m_nbytes_per_flit-1);
<%} else { %>
          if (m_nbytes_per_flit == 32)
              m_chi_txns[txnid].m_req_addr[4:0] = $urandom_range(0,m_nbytes_per_flit-1);
          if (m_nbytes_per_flit == 16)
              m_chi_txns[txnid].m_req_addr[3:0] = $urandom_range(0,m_nbytes_per_flit-1);
<%}%>
      end
  end
  if(((m_chi_txns[txnid].m_req_excl == 1) && (m_chi_txns[txnid].m_req_snpattr == 0)) || ($test$plusargs("perf_test_tens"))) begin 

          if (m_chi_txns[txnid].m_req_size == 1) begin
              m_chi_txns[txnid].m_req_addr[0] = 'h0;
          end else if(m_chi_txns[txnid].m_req_size == 2) begin
              m_chi_txns[txnid].m_req_addr[1:0] = 'h0;
          end else if(m_chi_txns[txnid].m_req_size == 3) begin
              m_chi_txns[txnid].m_req_addr[2:0] = 'h0;
          end else if(m_chi_txns[txnid].m_req_size == 4) begin
              m_chi_txns[txnid].m_req_addr[3:0] = 'h0;
          end else if(m_chi_txns[txnid].m_req_size == 5) begin
              m_chi_txns[txnid].m_req_addr[4:0] = 'h0;
          end else if(m_chi_txns[txnid].m_req_size == 6) begin
              m_chi_txns[txnid].m_req_addr[5:0] = 'h0;
          end
   end

    if ($test$plusargs("pick_boundary_addr")) begin
         tmp_inp_addr = m_chi_txns[txnid].m_req_addr; 
         get_addr_in_gpa(tmp_inp_addr, tmp_out_addr);
         m_chi_txns[txnid].m_req_addr = tmp_out_addr; 
    end
  
  <%if(obj.testBench == "fsys"){ %>
      if(is_atomic(txnid) && (m_chi_txns[txnid].m_req_opcode == BFM_ATOMICCOMPARE)) begin
          if (m_chi_txns[txnid].m_req_size == 2) begin
              m_chi_txns[txnid].m_req_addr[0] = 'h0;
          end else if(m_chi_txns[txnid].m_req_size == 3) begin
              m_chi_txns[txnid].m_req_addr[1:0] = 'h0;
          end else if(m_chi_txns[txnid].m_req_size == 4) begin
              m_chi_txns[txnid].m_req_addr[2:0] = 'h0;
          end else if(m_chi_txns[txnid].m_req_size == 5) begin
              m_chi_txns[txnid].m_req_addr[3:0] = 'h0;
          end
      end
      if(is_atomic(txnid) && (m_chi_txns[txnid].m_opcode_type inside {ATOMIC_ST_CMD, ATOMIC_LD_CMD, ATOMIC_SW_CMD})) begin
          if (m_chi_txns[txnid].m_req_size == 1) begin
              m_chi_txns[txnid].m_req_addr[0] = 'h0;
          end else if(m_chi_txns[txnid].m_req_size == 2) begin
              m_chi_txns[txnid].m_req_addr[1:0] = 'h0;
          end else if(m_chi_txns[txnid].m_req_size == 3) begin
              m_chi_txns[txnid].m_req_addr[2:0] = 'h0;
          end else if(m_chi_txns[txnid].m_req_size == 4) begin
              m_chi_txns[txnid].m_req_addr[3:0] = 'h0;
          end
      end
  <%}%>

  return 1;
endfunction: pick_associated_cacheline

//TODO FIXME
function bit chi_container::order_checks_on_req_txn(int txnid);
  //if (!$test$plusargs("unsupported_txn") && !$test$plusargs("unmapped_add_access")) begin
   if ((!$test$plusargs("pick_boundary_addr")) && (!$test$plusargs("unsupported_txn")) && (!$test$plusargs("unmapped_add_access") || ($test$plusargs("unmapped_add_access") && !addr_trans_mgr::check_unmapped_add(m_chi_txns[txnid].m_req_addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type)))) begin
    if (m_chi_txns[txnid].m_req_order == REQUEST_ORDER) begin
      `ASSERT(is_rdnosnp(txnid) || is_rdonce(txnid) || is_wrnosnp(txnid) ||
              is_wrunq(txnid)   || is_atomic(txnid));
      return request_order_check(aligned64B_addr(m_chi_txns[txnid].m_req_addr));

    end else if (m_chi_txns[txnid].m_req_order == ENDPOINT_ORDER) begin
      `ASSERT(is_rdnosnp(txnid) || is_rdonce(txnid) || is_wrnosnp(txnid) ||
              is_wrunq(txnid)   || is_atomic(txnid));

      return endpoint_order_check(aligned64B_addr(m_chi_txns[txnid].m_req_addr),m_chi_txns[txnid].m_opcode_type);
    end
  end
  return 1;
endfunction: order_checks_on_req_txn

function bit chi_container::request_order_check(
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] addr);
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] q[$];

  q = m_pend_reqorder_txnq.find(x) with (x == aligned64B_addr(addr));
  //Save address to flag request ordering is set for current addr
  if (q.size() == 0)
    m_pend_reqorder_txnq.push_back(aligned64B_addr(addr));

  return q.size() ? 0 : 1;
endfunction: request_order_check

function bit chi_container::endpoint_order_check(
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] addr, chi_bfm_opcode_type_t opcode_type);
  bit flag1, flag2;
  ncoreConfigInfo::intq regionq;
  bit [ncoreConfigInfo::ADDR_WIDTH - 1 : 0] tmp_addr;
  chi_bfm_opcode_type_t tmp_opcode_type;
  bit addr_is_nc;
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] q[$];
  ncore_memory_map m_map;

  //Endpoint ordering is super set of Request ordering
  //hence must check request order q too.
  q = m_pend_reqorder_txnq.find(x) with (x == aligned64B_addr(addr));

  if (q.size() == 0) begin
    if((addr >= ncoreConfigInfo::BOOT_REGION_BASE) && (addr < (ncoreConfigInfo::BOOT_REGION_BASE + ncoreConfigInfo::BOOT_REGION_SIZE)))
    begin
        flag1 = 1; 
        m_pend_reqorder_txnq.push_back(aligned64B_addr(addr));
        // FIXME - what region to assign for m_pend_endpoint_txnq
       flag2 = 1;
    end
    else begin	 
        m_map = m_addr_mgr.get_memory_map_instance();
        tmp_opcode_type = opcode_type;
        tmp_addr = addr;
        addr_is_nc = ncoreConfigInfo::get_addr_gprar_nc(addr);
        if (tmp_opcode_type == RD_RDONCE_CMD || tmp_opcode_type == ATOMIC_ST_CMD || tmp_opcode_type == ATOMIC_LD_CMD || tmp_opcode_type == ATOMIC_SW_CMD || tmp_opcode_type == ATOMIC_CM_CMD || tmp_opcode_type == WR_COHUNQ_CMD) begin

            if (addr_is_nc == 0) begin
             regionq  = m_map.get_coh_mem_regions();
            end else if (addr_is_nc == 1) begin 
             regionq  = m_map.get_noncoh_mem_regions();
            end

        end else begin
        <%if(obj.AiuInfo[obj.Id].nDiis >1){%>
             regionq  = m_map.get_iocoh_mem_regions();
        <% } else { %>
             regionq  = m_map.get_noncoh_mem_regions();
        <% } %>
        end

        foreach (regionq[idx]) begin
            bit [63:0] lreg;
            bit [63:0] hreg;
            lreg = ncoreConfigInfo::memregion_boundaries[regionq[idx]].start_addr;
            hreg = ncoreConfigInfo::memregion_boundaries[regionq[idx]].end_addr;
            if (tmp_addr >=  lreg && tmp_addr < hreg) begin
                int q[$];
                flag1 = 1;     

                q = m_pend_endpoint_txnq.find(x) with (x == regionq[idx]);
                //Legal values for size of q is 0 or 1
                `ASSERT(q.size() < 2);
                if (q.size() == 0) begin
                    flag2 = 1;
                    m_pend_reqorder_txnq.push_back(aligned64B_addr(addr));
                    m_pend_endpoint_txnq.push_back(regionq[idx]);
                end
          end
        end // foreach (regionq[idx])
    end // else: !if((addr >= ncoreConfigInfo::BOOT_REGION_BASE) && (addr < (ncoreConfigInfo::BOOT_REGION_BASE + ncoreConfigInfo::BOOT_REGION_SIZE)))
    `ASSERT(flag1);
  end
  return flag2;
endfunction: endpoint_order_check

task chi_container::get_txnid(output int req_txnid);
  wait (m_txnid_pool.size() != 0);

  req_txnid = m_txnid_pool.pop_back();
endtask: get_txnid

task chi_container::wait_until_thld_rchd();
<% if((obj.testBench == 'chi_aiu') || (obj.testBench == "fsys")) { %>
`ifdef VCS
 m_args.k_on_fly_req.set_value(350);
`endif // `ifndef VCS
<% } %>
  wait(m_tx_req_chnl_cb.size() < (m_args.k_on_fly_req.get_value()));
endtask: wait_until_thld_rchd

function void chi_container::put_txnid(int req_txnid);
  int q[$];

  q = m_txnid_pool.find(x) with (x == req_txnid);
  `ASSERT(q.size() == 0);
  m_txnid_pool.push_back(req_txnid);
endfunction: put_txnid

function addr_width_t chi_container::get_device_mem_addr(bit req_new_addr);
 if (req_new_addr) begin
   ncore_memory_map m_map;
   int q[$];

   m_map = m_addr_mgr.get_memory_map_instance();
   q = m_map.get_iocoh_mem_regions();
   `ASSERT(q.size() > 0);
   q.shuffle();  
   return m_addr_mgr.gen_iocoh_addr(ID, 1, q[0]);
 end

 return m_addr_mgr.get_iocoh_addr(ID, 1);
endfunction: get_device_mem_addr

function addr_width_t chi_container::get_boot_mem_addr(
  bit req_new_addr);

  return m_addr_mgr.get_bootreg_addr(ID, 1);
endfunction: get_boot_mem_addr

function addr_width_t chi_container::get_boot_noncoh_mem_addr(
  bit req_new_addr);

  return m_addr_mgr.get_noncohboot_addr(ID, 1);
endfunction: get_boot_noncoh_mem_addr

function addr_width_t chi_container::get_boot_coh_mem_addr(
  bit req_new_addr);

  return m_addr_mgr.get_cohboot_addr(ID, 1);
endfunction: get_boot_coh_mem_addr

function addr_width_t chi_container::get_normal_noncoh_mem_addr(
  bit req_new_addr);
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
  int 				      pick_itr;
   
  if($test$plusargs("use_user_addrq") && (user_addrq[ncoreConfigInfo::NONCOH].size()>0)) begin
     if(user_addrq_idx[ncoreConfigInfo::NONCOH] == -1) begin
        pick_itr = $urandom_range(0, user_addrq[ncoreConfigInfo::NONCOH].size()-1);
        addr = user_addrq[ncoreConfigInfo::NONCOH][pick_itr];
     end
     else begin
        addr = user_addrq[ncoreConfigInfo::NONCOH][user_addrq_idx[ncoreConfigInfo::NONCOH]];
        if(!$test$plusargs("force_unique_addr")) user_addrq_idx[ncoreConfigInfo::NONCOH] = user_addrq_idx[ncoreConfigInfo::NONCOH] + 1;  //newperf test add plusargs 
        if(user_addrq_idx[ncoreConfigInfo::NONCOH] >= user_addrq[ncoreConfigInfo::NONCOH].size() || (use_loop_addr>0 && user_addrq_idx[ncoreConfigInfo::NONCOH] >= use_loop_addr)) begin
           user_addrq_idx[ncoreConfigInfo::NONCOH] = use_loop_addr_offset;
		   use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
           use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
        end
     end
     return addr;
  end else begin
     if (req_new_addr)
        return m_addr_mgr.gen_noncoh_addr(ID, 1);

     return m_addr_mgr.get_noncoh_addr(ID, 1);
  end
endfunction: get_normal_noncoh_mem_addr

function addr_width_t chi_container::get_normal_coh_mem_addr(
 bit req_new_addr);
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
   int 				      pick_itr;

  if($test$plusargs("use_user_addrq") && (user_addrq[ncoreConfigInfo::COH].size()>0)) begin
     if(user_addrq_idx[ncoreConfigInfo::COH] == -1) begin
        pick_itr = $urandom_range(0, user_addrq[ncoreConfigInfo::COH].size()-1);
        addr = user_addrq[ncoreConfigInfo::COH][pick_itr];
     end
     else begin
        addr = user_addrq[ncoreConfigInfo::COH][user_addrq_idx[ncoreConfigInfo::COH]];
	    if(!$test$plusargs("force_unique_addr")) user_addrq_idx[ncoreConfigInfo::COH] = user_addrq_idx[ncoreConfigInfo::COH] + 1; //newperf test add plusargs
	    if(user_addrq_idx[ncoreConfigInfo::COH] >= user_addrq[ncoreConfigInfo::COH].size() || (use_loop_addr>0 && user_addrq_idx[ncoreConfigInfo::COH] >= use_loop_addr)) begin
	       user_addrq_idx[ncoreConfigInfo::COH] = use_loop_addr_offset;
		   use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
	       use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
	    end
     end
     return addr;
  end else begin
     if (req_new_addr)
        return m_addr_mgr.gen_coh_addr(ID, 1);
   
     return m_addr_mgr.get_coh_addr(ID, 1);
  end
endfunction: get_normal_coh_mem_addr

function bit chi_container::get_normal_local_cache_addr(
  input chi_bfm_cache_state_t st, 
  output addr_width_t addr);
  chi_bfm_cache_state_t c_st;

  if (m_installed_cachelines[st].size() > 0) begin
    int pick_itr;

    pick_itr = $urandom_range(0, m_installed_cachelines[st].size() - 1);
    addr = m_installed_cachelines[st][pick_itr];
    if(m_chi_cache.exists(aligned64B_addr(addr)))
	return 0;
    c_st = st.first;
    do
    begin
	foreach(m_installed_cachelines[c_st][i])
	begin
	//$display("%t, 6normal addr %x, state %s pick_itr %x", $time, addr, c_st.name, i);
		if(m_installed_cachelines[c_st][i] === addr)begin
			m_installed_cachelines[c_st].delete(i);
		end
	end
	c_st = c_st.next;
    end while(c_st!=c_st.first);
    m_installed_cachelines[st].push_back(addr);
    return 1;
  end
/*
    do
    begin
	foreach(m_installed_cachelines[c_st][i])
	begin
	`uvm_info(get_type_name(), $psprintf("%t, 6normal addr %x, state %s pick_itr %x", $time, addr, c_st.name, i), UVM_LOW)
	end
	c_st = c_st.next;
    end while(c_st!=c_st.first);
*/
	
  return 0;
endfunction: get_normal_local_cache_addr

//TODO FIXME
function void chi_container::invalidate_local_cache_addr(addr_width_t addr);
  `ASSERT(0);
endfunction: invalidate_local_cache_addr

function addr_width_t chi_container::get_write_user_addrq_addr();
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
   int 				      pick_itr;

  if($test$plusargs("use_user_addrq") && (user_write_addrq[ncoreConfigInfo::COH].size()>0)) begin
     if(user_write_addrq_idx[ncoreConfigInfo::COH] == -1) begin
        pick_itr = $urandom_range(0, user_write_addrq[ncoreConfigInfo::COH].size()-1);
        addr = user_write_addrq[ncoreConfigInfo::COH][pick_itr];
     end
     else begin
        addr = user_write_addrq[ncoreConfigInfo::COH][user_write_addrq_idx[ncoreConfigInfo::COH]];
	if(!$test$plusargs("force_unique_addr")) user_write_addrq_idx[ncoreConfigInfo::COH] = user_write_addrq_idx[ncoreConfigInfo::COH] + 1; //newperf test add plusargs
	if(user_write_addrq_idx[ncoreConfigInfo::COH] >= user_write_addrq[ncoreConfigInfo::COH].size() || (use_loop_addr>0 && user_write_addrq_idx[ncoreConfigInfo::COH] >= use_loop_addr)) begin
	   user_write_addrq_idx[ncoreConfigInfo::COH] = use_loop_addr_offset;
	   use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
	   use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
	end
     end // else: !if(user_write_addrq_idx[ncoreConfigInfo::COH] == -1)
  end						  
  return addr;
endfunction // get_write_user_addrq_addr
						  
function addr_width_t chi_container::get_read_user_addrq_addr();
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
   int 				      pick_itr;

  if($test$plusargs("use_user_addrq") && (user_read_addrq[ncoreConfigInfo::COH].size()>0)) begin
     if(user_read_addrq_idx[ncoreConfigInfo::COH] == -1) begin
        pick_itr = $urandom_range(0, user_read_addrq[ncoreConfigInfo::COH].size()-1);
        addr = user_read_addrq[ncoreConfigInfo::COH][pick_itr];
     end
     else begin
        addr = user_read_addrq[ncoreConfigInfo::COH][user_read_addrq_idx[ncoreConfigInfo::COH]];
	if(!$test$plusargs("force_unique_addr")) user_read_addrq_idx[ncoreConfigInfo::COH] = user_read_addrq_idx[ncoreConfigInfo::COH] + 1; //newperf test add plusargs
	if(user_read_addrq_idx[ncoreConfigInfo::COH] >= user_read_addrq[ncoreConfigInfo::COH].size() || (use_loop_addr>0 && user_read_addrq_idx[ncoreConfigInfo::COH] >= use_loop_addr)) begin
	   user_read_addrq_idx[ncoreConfigInfo::COH] = use_loop_addr_offset;
	   use_loop_addr +=use_loop_addr_offset; //newperf_test add the miss addr
	   use_loop_addr_offset +=use_loop_addr_offset; // newperf_test each loop add the offset to allow SMC percentage of miss
	end
     end // else: !if(user_read_addrq_idx[ncoreConfigInfo::COH] == -1)
  end						  
  return addr;
endfunction // get_read_user_addrq_addr

function void chi_container::initiate_exp_compack(int txnid, int dbid, chi_bfm_rsp_err_t m_rsp_err);
  chi_bfm_rsp_t exp_compack_rsp;

  exp_compack_rsp.m_resp   = new(TX_RSP_CHNL);
  exp_compack_rsp.tgtid    = (m_chi_txns[txnid].m_opcode_type == SNP_STASH_CMD) ? m_chi_txns[txnid].m_req_srcid : m_chi_txns[txnid].m_req_tgtid;
  exp_compack_rsp.srcid    = ID;
  exp_compack_rsp.txnid    = dbid;
  //exp_compack_rsp.qos      = m_chi_txns[txnid].m_req_qos;
  exp_compack_rsp.m_resp.set_comprsp_opcode_resp(
      BFM_COMPACK, BFM_COMP_IX, BFM_RESP_OK);
//$display("exp_compack resp_err %x txnid: %x", exp_compack_rsp.m_resp.get_resp_err,exp_compack_rsp.txnid );
  exp_compack_rsp.datapull = 0;
  m_tx_rsp_chnl_cb.put_chi_txn(exp_compack_rsp);
endfunction: initiate_exp_compack

function void chi_container::initiate_wr_data(
    int txnid,
    int dbid,
    chi_bfm_cache_state_t end_state,
    bit wrdata_cancel,
    chi_bfm_rsp_err_t rsperr,
    chi_data_be_t info);

  chi_bfm_dat_t wr_data;
  int           nbeats;
  bit [7:0]     m_dummy_data[64];
  bit           m_dummy_be[64];
  int addr_mask;
  int addr_offset;
  int size_in_bytes;
  int ccid_offset;
  int max_offset;
  int data_width;
  bit wrnosnp_wrunq_ptl;

  wr_data.m_info = new(m_nbytes_per_flit);
  wr_data.m_resp = new(TX_DAT_CHNL);
  wr_data.tgtid  = m_chi_txns[txnid].m_req_tgtid;
  wr_data.srcid  = ID;
  wr_data.txnid  = dbid;
  nbeats = num_beats(m_chi_txns[txnid].m_req_addr & 6'h3F,
     m_chi_txns[txnid].m_req_opcode == BFM_ATOMICCOMPARE ?
         m_chi_txns[txnid].m_req_size - 1 : m_chi_txns[txnid].m_req_size);

  //HACK, to fix this above num_beats mwthods must have knowledege that
  //this transaction is BFM_ATOMICCOMPARE
  if (m_chi_txns[txnid].m_req_opcode == BFM_ATOMICCOMPARE &&
      m_chi_txns[txnid].m_req_size   == 5                 &&
      m_nbytes_per_flit              == 16)
    nbeats = nbeats + 1;

<%if(obj.testBench == "fsys"){ %>
  data_width = <%=obj.AiuInfo[obj.Id].wData%>;
  addr_mask = data_width/8 - 1;
  addr_offset = m_chi_txns[txnid].m_req_addr & addr_mask;
  size_in_bytes = pow2(m_chi_txns[txnid].m_req_size);
  ccid_offset = (data_width == 128) ? m_chi_txns[txnid].m_req_addr[5:4]*data_width/8 : m_chi_txns[txnid].m_req_addr[5]*data_width/8;
  max_offset = (((addr_offset+ccid_offset)/size_in_bytes) + 1)*size_in_bytes;
  if(m_chi_txns[txnid].m_req_opcode inside {BFM_WRITENOSNPPTL, BFM_WRITEUNIQUEPTL, BFM_WRITEUNIQUEPTLSTASH}) begin
      wrnosnp_wrunq_ptl='1;
  end

  if (wrnosnp_wrunq_ptl || (m_chi_txns[txnid].m_req_opcode == BFM_ATOMICCOMPARE)) begin
      for (int i = 0; i < 64; ++i) begin
          info.m_data[i] = 0;
          info.m_be[i]   = 0;
      end
  end

 if (m_chi_txns[txnid].m_req_opcode == BFM_ATOMICCOMPARE) begin
      addr_offset = m_chi_txns[txnid].m_req_addr[5:0] & (64 - size_in_bytes);
  end

  for (int i = 0; i < size_in_bytes; ++i) begin
    if (wrnosnp_wrunq_ptl) begin
      if ((i+addr_offset+ccid_offset) < max_offset) begin
          info.m_data[i+addr_offset+ccid_offset] = $urandom_range(0, 255);
          info.m_be[i+addr_offset+ccid_offset]   = 1;
      end
      else begin
          if (m_chi_txns[txnid].m_req_memattr[1] == NORMAL) begin
              info.m_data[((i+addr_offset+ccid_offset)%max_offset) + (max_offset - size_in_bytes)] = $urandom_range(0, 255);
              info.m_be[((i+addr_offset+ccid_offset)%max_offset) + (max_offset - size_in_bytes)]   = 1;
           end
      end
    end
  if (m_chi_txns[txnid].m_req_opcode == BFM_ATOMICCOMPARE) begin
        info.m_data[i+addr_offset] = $urandom_range(0, 255);
        info.m_be[i+addr_offset]   = 1;
    end
  end

<%}else{%>
  if (m_chi_txns[txnid].m_req_memattr[1] == 1) begin
      for (int i = 0; i < 64; ++i) begin
          if (i < m_chi_txns[txnid].m_req_addr[5:0]) begin
              info.m_be[i] = 0;
          end
      end
  end
<%}%>

  case (m_chi_txns[txnid].get_opcode_type())
    WR_NONCOH_CMD: begin
      wr_data.m_info.set_txdat_info(
          get_ccid(m_chi_txns[txnid].m_req_addr),
          nbeats,
          info.m_data,
          info.m_be
      );

<% if (obj.fnNativeInterface != 'CHI-A') { %>
      if (wrdata_cancel) begin
        wr_data.m_resp.set_wrdat_opcode_resp(
            BFM_WRITEDATACANCEL,
            BFM_NONCPYBCK_CPYBCK_IX,
            rsperr
        );
      end else begin
        wr_data.m_resp.set_wrdat_opcode_resp(
            BFM_NONCOPYBACKWRDATA,
            BFM_NONCPYBCK_CPYBCK_IX,
            rsperr
        );
      end
<% } else { %>
        wr_data.m_resp.set_wrdat_opcode_resp(
            BFM_NONCOPYBACKWRDATA,
            BFM_NONCPYBCK_CPYBCK_IX,
            rsperr
        );
 <% } %>
    end

    WR_COHUNQ_CMD: begin
      addr_width_t tmp_addr;
 
      tmp_addr = aligned64B_addr(m_chi_txns[txnid].m_req_addr);
      if (rsperr inside {BFM_RESP_OK, BFM_RESP_EXOK}) begin
        install_cacheline(end_state, m_chi_txns[txnid].get_cacheline_addr());
      end

      wr_data.m_info.set_txdat_info(
          get_ccid(m_chi_txns[txnid].m_req_addr),
          nbeats,
          info.m_data,
          info.m_be
      );

<% if (obj.fnNativeInterface != 'CHI-A') { %>
      if (wrdata_cancel) begin
        wr_data.m_resp.set_wrdat_opcode_resp(
            BFM_WRITEDATACANCEL,
            BFM_NONCPYBCK_CPYBCK_IX,
            rsperr
        );
      end else begin
        wr_data.m_resp.set_wrdat_opcode_resp(
            BFM_NONCOPYBACKWRDATA,
            BFM_NONCPYBCK_CPYBCK_IX,
            rsperr
        );
      end
<% } else { %>
        wr_data.m_resp.set_wrdat_opcode_resp(
            BFM_NONCOPYBACKWRDATA,
            BFM_NONCPYBCK_CPYBCK_IX,
            rsperr
        );
 <% } %>
    end

    WR_CPYBCK_CMD: begin
      chi_bfm_copyback_rsp_t tmp_rsp;
      addr_width_t tmp_addr;
      bit result[$];
 
      tmp_addr = aligned64B_addr(m_chi_txns[txnid].get_cacheline_addr());
      //`ASSERT(m_chi_cache.exists(tmp_addr));
      tmp_rsp = get_wrdat_resp(tmp_addr, get_installed_cache_state(tmp_addr)); //snoop can change the initial cache state. Hence resp can be different. CHI B spec P4-160
      if(($test$plusargs("use_copyback") && $test$plusargs("fsys_coverage"))) begin
          if (m_chi_txns[txnid].m_req_opcode == BFM_WRITEBACKPTL) begin
              case (tmp_rsp)
                BFM_NONCPYBCK_CPYBCK_IX:  tmp_rsp = BFM_NONCPYBCK_CPYBCK_IX;
                default: tmp_rsp = BFM_COPYBACKWRDATA_UD_PD;
              endcase
          end
          if (m_chi_txns[txnid].m_req_opcode == BFM_WRITEEVICTFULL) begin
              case (tmp_rsp)
                BFM_NONCPYBCK_CPYBCK_IX:  tmp_rsp = BFM_NONCPYBCK_CPYBCK_IX;
                BFM_COPYBACKWRDATA_SC:  tmp_rsp = BFM_COPYBACKWRDATA_SC;
                default: tmp_rsp = BFM_COPYBACKWRDATA_UC;
              endcase
          end
      end
      if($test$plusargs("pick_boundary_addr") || $test$plusargs("cache_state_wrbkptl")) begin
      <% if (obj.fnNativeInterface != 'CHI-A') { %>
          if (m_chi_txns[txnid].m_req_opcode == BFM_WRITEBACKPTL) begin
      <% } else { %>
          if (m_chi_txns[txnid].m_req_opcode == BFM_WRITEBACKPTL || m_chi_txns[txnid].m_req_opcode == BFM_WRITECLEANPTL) begin
      <% } %>
              case (tmp_rsp)
                BFM_NONCPYBCK_CPYBCK_IX:  tmp_rsp = BFM_NONCPYBCK_CPYBCK_IX;
                default: tmp_rsp = BFM_COPYBACKWRDATA_UD_PD;
              endcase
          end
         if (m_chi_txns[txnid].m_req_opcode == BFM_WRITEEVICTFULL) begin
             std::randomize(tmp_rsp) with {tmp_rsp inside {BFM_COPYBACKWRDATA_SC,BFM_COPYBACKWRDATA_UC,BFM_NONCPYBCK_CPYBCK_IX};};
         end
      end
      if($test$plusargs("write_cpbck_cov") && ($urandom_range(1,100) > 10)) begin
          if ((m_chi_txns[txnid].m_req_opcode == BFM_WRITEBACKFULL) || (m_chi_txns[txnid].m_req_opcode == BFM_WRITECLEANFULL)) begin
          std::randomize(tmp_rsp) with {tmp_rsp inside {BFM_COPYBACKWRDATA_UC,BFM_NONCPYBCK_CPYBCK_IX};};
          end
          if (m_chi_txns[txnid].m_req_opcode == BFM_WRITEEVICTFULL) begin
          std::randomize(tmp_rsp) with {tmp_rsp inside {BFM_COPYBACKWRDATA_SC,BFM_NONCPYBCK_CPYBCK_IX};};
          end
      end
      //$display("wr_rsp %s, addr %x, cache_state %s", tmp_rsp.name(), tmp_addr, get_installed_cache_state(tmp_addr).name());
      `ASSERT(end_state != CHI_UCE);
      if (rsperr inside {BFM_RESP_OK, BFM_RESP_EXOK}) begin
        install_cacheline(end_state, m_chi_txns[txnid].get_cacheline_addr());
      end

      if(m_chi_cache.exists(tmp_addr) ) //&& tmp_rsp!= '0) //new_cmd and we force the cache state //writenosnpfull can have final state at I
      begin
	result = m_chi_cache[tmp_addr].m_be.find(x) with (x > 0);
	if(result.size==0)
	 foreach (info.m_be[i])
              if(info.m_be[i]>0) 
    		m_chi_cache[tmp_addr].set_valid_bytes(i, $urandom_range(0,64), '1);
      end

      if (($test$plusargs("non_secure_access_test")) || ($test$plusargs("unmapped_add_access") && addr_trans_mgr::check_unmapped_add(m_chi_txns[txnid].m_req_addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type))) begin
          wr_data.m_info.set_txdat_info(
              get_ccid(m_chi_txns[txnid].m_req_addr),
              nbeats,
              m_dummy_data,
              m_dummy_be
          );
      end
      else begin
          wr_data.m_info.set_txdat_info(
              get_ccid(m_chi_txns[txnid].m_req_addr),
              nbeats,
              m_chi_cache[tmp_addr].get_cacheline_data(),
              m_chi_cache[tmp_addr].get_cacheline_be()
          );
      end

      wr_data.m_resp.set_wrdat_opcode_resp(
          BFM_COPYBACKWRDATA, tmp_rsp, rsperr);
    end

    ATOMIC_ST_CMD, ATOMIC_LD_CMD, ATOMIC_SW_CMD, ATOMIC_CM_CMD: begin
      addr_width_t al = aligned64B_addr(m_chi_txns[txnid].m_req_addr);
      if (m_chi_cache.exists(al))
        `ASSERT(end_state == CHI_IX);

      wr_data.m_info.set_txdat_info(
          get_ccid(m_chi_txns[txnid].m_req_addr),
          nbeats,
          info.m_data,
          info.m_be
      );
      wr_data.m_resp.set_wrdat_opcode_resp(
          BFM_NONCOPYBACKWRDATA, BFM_NONCPYBCK_CPYBCK_IX, rsperr);
    end

    DVM_OPERT_CMD: begin
      wr_data.m_info.set_txdat_info(
          get_ccid(m_chi_txns[txnid].m_req_addr),
          nbeats,
          info.m_data,
          info.m_be
      );
      wr_data.m_resp.set_wrdat_opcode_resp(
          BFM_NONCOPYBACKWRDATA, BFM_NONCPYBCK_CPYBCK_IX, rsperr);
    end

    default: begin
      string s;

      $sformat(s, "%s txnid:0x%0h dbid:0x%0h opcode_type:%s",
               s, txnid, dbid, m_chi_txns[txnid].get_opcode_type());
      print_pending_txns();
      `uvm_fatal(uname, {"Issuing write data for unexpected request ", s});
    end
  endcase

  wr_data.datapull = 0;
  wr_data.datasource = 0;
  //Issue WRDAT transaction
  m_tx_dat_chnl_cb.put_chi_txn(wr_data);
endfunction: initiate_wr_data

function void chi_container::initiate_snp_rsp(
    chi_bfm_cache_state_t    end_state,
    chi_bfm_snprsp_rsp_t     snprsp,
    chi_bfm_rsp_err_t        snprsp_err,
    bit [2:0]                datapull,
    const ref chi_bfm_snp_t  snp_txn);

  chi_bfm_rsp_t snprsp_txn;
  addr_width_t  addr;

  if(send_pending_snp_rsp) begin

    `uvm_info("CHI_BFM_DEBUG", $psprintf("tsk::initiate_snp_rsp inside send_pending_snp_rsp m_chi_snp_rspq size = %0d, m_chi_stash_snp_rspq size = %0d", m_chi_snp_rspq.size(), m_chi_stash_snp_rspq.size()), UVM_HIGH)
	foreach(m_chi_snp_rspq[i]) begin
      m_tx_rsp_chnl_cb.put_chi_txn(m_chi_snp_rspq[i]);
	end
	m_chi_snp_rspq.delete();
    foreach(m_chi_stash_snp_rspq[i]) begin
      m_chi_stash_rspq.push_back(m_chi_stash_snp_rspq[i]);
	end
	m_chi_stash_snp_rspq.delete();
    send_pending_snp_rsp = 0;
    `uvm_info("CHI_BFM_DEBUG", $psprintf("tsk::initiate_snp_rsp inside send_pending_snp_rsp after sending snp_rsp m_chi_snp_rspq size = %0d, m_chi_stash_snp_rspq size = %0d", m_chi_snp_rspq.size(), m_chi_stash_snp_rspq.size()), UVM_HIGH)

  end else begin

    addr  = snp_txn.addr << 3;
    addr[ncoreConfigInfo::ADDR_WIDTH] = snp_txn.ns;
    snprsp_txn.m_resp = new(TX_RSP_CHNL);
    snprsp_txn.tgtid  = snp_txn.srcid;
    snprsp_txn.srcid  = ID;
    snprsp_txn.txnid  = snp_txn.txnid;
    snprsp_txn.datapull = datapull;
    if ( k_snp_rsp_non_data_err_wgt == 0) begin // Not already set by affectation
      void'($value$plusargs("SNPrsp_with_non_data_error=%d",k_snp_rsp_non_data_err_wgt));
    end
    if (k_snp_rsp_non_data_err_wgt != 0) begin
        void'(std::randomize(snprsp_err) with {snprsp_err dist {BFM_RESP_NDERR :/ k_snp_rsp_non_data_err_wgt, BFM_RESP_OK :/ 100-k_snp_rsp_non_data_err_wgt};});
    end
    snprsp_txn.m_resp.set_snprsp_opcode_resp(BFM_SNPRESP, snprsp, snprsp_err);

    //Invoke install**() method only if address exists in cache
    if (m_chi_cache.exists(aligned64B_addr(addr)))
      install_cacheline(end_state, addr);
    else
      `ASSERT(end_state == CHI_IX);

    $display("Rcv snp 1: addr %x, datapull %x", snp_txn.addr, datapull);

    if (datapull == 1) begin
      chi_stashing_snp_t lds;

      `ASSERT(is_stash_snoop(snp_txn.opcode));
      //If stashing snoop response, then dbid is required
      //hence wait until new entry is created.
      lds.opcode    = snp_txn.opcode;
      lds.snp_type  = BFM_SNPRSP;
      lds.stash_rsp = snprsp_txn;
      lds.addr = snp_txn.addr ;
      lds.ns   = snp_txn.ns;
      if($test$plusargs("snp_srsp_delay") && stt_fill_count < max_stt_fill_count && fill_stt == 1) begin
        m_chi_stash_snp_rspq.push_back(lds);
        `uvm_info("CHI_BFM_DEBUG", $psprintf("tsk::initiate_snp_rsp m_chi_stash_snp_rspq size = %0d",m_chi_stash_snp_rspq.size()), UVM_HIGH)
      end else begin
        m_chi_stash_rspq.push_back(lds);
      end
    end else begin
      // #Stimulus.CHI.v3.7.MaxSttEntries
      if($test$plusargs("snp_srsp_delay") && stt_fill_count < max_stt_fill_count && fill_stt == 1) begin
        m_chi_snp_rspq.push_back(snprsp_txn);
        `uvm_info("CHI_BFM_DEBUG", $psprintf("tsk::initiate_snp_rsp m_chi_snp_rspq size = %0d",m_chi_snp_rspq.size()), UVM_HIGH)
      end else begin
      	m_tx_rsp_chnl_cb.put_chi_txn(snprsp_txn);
      end
    end
  end
endfunction: initiate_snp_rsp

function void chi_container::initiate_snp_data_rsp(
    chi_bfm_cache_state_t    end_state,
    chi_bfm_snprsp_data_t    snprsp_data,
    chi_bfm_rsp_err_t        snprsp_err,
    bit [2:0]                datapull,
    const ref chi_bfm_snp_t  snp_txn);

  chi_bfm_dat_t    dat_txn;
  addr_width_t  addr;
  bit_64_t      tmp_be;
  bit           valid_be;

  if(send_pending_snp_rsp_data) begin

    `uvm_info("CHI_BFM_DEBUG", $psprintf("tsk::initiate_snp_data_rsp inside send_pending_snp_rsp_data m_chi_snp_data_rspq size = %0d, m_chi_stash_snp_data_rspq size = %0d", m_chi_snp_data_rspq.size(), m_chi_stash_snp_data_rspq.size()), UVM_HIGH)
	foreach(m_chi_snp_data_rspq[i]) begin
      m_tx_dat_chnl_cb.put_chi_txn(m_chi_snp_data_rspq[i]);
      install_cacheline(snp_data_end_stateq[i], snp_data_addrq[i]);
	end
	m_chi_snp_data_rspq.delete();
    foreach(m_chi_stash_snp_data_rspq[i]) begin
      m_chi_stash_rspq.push_back(m_chi_stash_snp_data_rspq[i]);
      install_cacheline(snp_stash_data_end_stateq[i], snp_stash_data_addrq[i]);
	end
	m_chi_stash_snp_data_rspq.delete();
    send_pending_snp_rsp_data = 0;
    `uvm_info("CHI_BFM_DEBUG", $psprintf("tsk::initiate_snp_data_rsp inside send_pending_snp_rsp_data after sending snp_rsp m_chi_snp_data_rspq size = %0d, m_chi_stash_snp_data_rspq size = %0d", m_chi_snp_data_rspq.size(), m_chi_stash_snp_data_rspq.size()), UVM_HIGH)

  end else begin

    addr  = snp_txn.addr << 3;
    addr[ncoreConfigInfo::ADDR_WIDTH] = snp_txn.ns;

    `ASSERT(m_chi_cache.exists(aligned64B_addr(addr)));
    dat_txn.m_info = new(m_nbytes_per_flit);
    dat_txn.m_resp = new(TX_DAT_CHNL);
    dat_txn.tgtid  = snp_txn.srcid;
    dat_txn.srcid  = ID; //snp_txn.tgtid;
    dat_txn.txnid  = snp_txn.txnid;
    if ( k_snp_rsp_data_err_wgt == 0) begin  // Not already set by affectation //#Stimulus.CHIAIU.v3.snpsrsperr
      void'($value$plusargs("SNPrsp_with_data_error=%d",k_snp_rsp_data_err_wgt));
    end
    if (k_snp_rsp_data_err_wgt != 0) begin
      void'(std::randomize(snprsp_err) with {snprsp_err dist {BFM_RESP_DERR :/ k_snp_rsp_data_err_wgt, BFM_RESP_OK :/ 100-k_snp_rsp_data_err_wgt};});
    end
    if($test$plusargs("placeholder_snprspdata_ptl"))begin
      if (($test$plusargs("force_snpdataptl")) && (end_state == CHI_IX)) begin
      //if ((snp_txn.opcode == BFM_SNPONCE) && ((end_state == CHI_IX) || (end_state == CHI_UDP) || (end_state == CHI_UD))) begin
        if ((snp_txn.opcode == BFM_SNPONCE) && ((end_state == CHI_IX))) begin
            snprsp_data =  BFM_SNPRSP_DATAPTL_IX_PD;
        end
      end
    end
    else begin
      if (($test$plusargs("force_snpdataptl")) && (end_state == CHI_IX)) begin
        if (snp_txn.opcode == BFM_SNPONCE) begin
            snprsp_data = ($urandom_range(0,1)) ? BFM_SNPRSP_DATAPTL_UD : BFM_SNPRSP_DATAPTL_IX_PD;
        end
        else begin
            snprsp_data = BFM_SNPRSP_DATAPTL_IX_PD;
        end
      end
    end

    if ($test$plusargs("snp_data_rsp")) begin
     if ((snp_txn.opcode == BFM_SNPCLEAN) || (snp_txn.opcode == BFM_SNPSHARED) ) begin
          std::randomize(snprsp_data) with {snprsp_data inside {BFM_SNPRSP_DATA_IX,BFM_SNPRSP_DATA_SC};};
          end 
     if ((snp_txn.opcode == BFM_SNPONCE) && (end_state == CHI_SC)) begin
          std::randomize(snprsp_data) with {snprsp_data inside {BFM_SNPRSP_DATA_IX,BFM_SNPRSP_DATA_SC};};
          end 
     if((snp_txn.opcode ==BFM_SNPUNIQUE) ) begin
        snprsp_data = BFM_SNPRSP_DATA_IX;
         end 
    end
    dat_txn.m_resp.set_snprsp_data_opcode_resp(
        snprsp_data, snprsp_err);
    dat_txn.datapull = datapull;
    dat_txn.datasource = 0;
    
    if (!m_chi_cache.exists(aligned64B_addr(addr)))
    begin
      m_chi_cache[aligned64B_addr(addr)] = new($psprintf("m_cacheline[0x%0h]", aligned64B_addr(addr)));
    end

    tmp_be = m_chi_cache[aligned64B_addr(addr)].get_cacheline_be();
    valid_be = 0;
    foreach (tmp_be[i])
        valid_be = valid_be | tmp_be[i];

    //if entire cacheline is empty populate data.
    if(!valid_be) begin
        foreach (tmp_be[i])
            m_chi_cache[aligned64B_addr(addr)].set_valid_bytes(i, $urandom_range(0,255), '1);
    end

    if(dat_txn.m_resp.get_opcode() != BFM_SNPRESPDATAPTL)
      foreach(tmp_be[i])
        if(tmp_be[i]!= 1)
          m_chi_cache[aligned64B_addr(addr)].set_valid_bytes(i, $urandom_range(0,255), '1);
      		

    dat_txn.m_info.set_txdat_info(
        get_ccid(snp_txn.addr << 3),
        64 / m_nbytes_per_flit,
        m_chi_cache[aligned64B_addr(addr)].get_cacheline_data(),
        m_chi_cache[aligned64B_addr(addr)].get_cacheline_be()
    );

    if (datapull == 1) begin
      chi_stashing_snp_t lds;

      `ASSERT(is_stash_snoop(snp_txn.opcode));
      //If stashing snoop response, then dbid is required
      //hence wait until new entry is created.
      lds.opcode    = snp_txn.opcode;
      lds.snp_type  = BFM_SNPRSP_DATA;
      lds.stash_dat = dat_txn;
      lds.addr = snp_txn.addr;
      lds.ns   = snp_txn.ns;
      if($test$plusargs("snp_srsp_delay") && stt_fill_count < max_stt_fill_count && fill_stt == 1) begin
        m_chi_stash_snp_data_rspq.push_back(lds);
        snp_stash_data_end_stateq.push_back(end_state);
        snp_stash_data_addrq.push_back(addr);
        `uvm_info("CHI_BFM_DEBUG", $psprintf("tsk::initiate_snp_data_rsp m_chi_stash_snp_data_rspq size = %0d",m_chi_stash_snp_data_rspq.size()), UVM_HIGH)
      end else begin
        m_chi_stash_rspq.push_back(lds);
      end
    end else begin
      // inject error for tempo negative testing
      if($test$plusargs("inject_error_all_chi_snp_data_rsp")) begin
         bit be_en; 
         if($value$plusargs("inject_error_all_chi_snp_data_rsp=%d",be_en)) // used to select data_byte to currupt with Byte_En = be_en value
           dat_txn.m_info.inj_err_txdat(be_en);
         else
           dat_txn.m_info.inj_err_txdat();
      end
      if($test$plusargs("snp_srsp_delay") && stt_fill_count < max_stt_fill_count && fill_stt == 1) begin
        m_chi_snp_data_rspq.push_back(dat_txn);
        snp_data_end_stateq.push_back(end_state);
        snp_data_addrq.push_back(addr);
        `uvm_info("CHI_BFM_DEBUG", $psprintf("tsk::initiate_snp_data_rsp m_chi_snp_data_rspq size = %0d",m_chi_snp_data_rspq.size()), UVM_HIGH)
      end else begin
        m_tx_dat_chnl_cb.put_chi_txn(dat_txn);
      end
    end

    install_cacheline(end_state, addr);

  end
endfunction: initiate_snp_data_rsp

function string chi_container::conv2str_rsp_chnl_pkt(
  const ref chi_bfm_rsp_t p);
  string s;
  chi_bfm_rsp_opcode_t opcode;

  opcode = p.m_resp.get_rsp_opcode_type();
  $sformat(s, "%s tgtid:%0d srcid:%0d txnid:0x%0h dbid:0x%0h opcode:0x%0h",
           s, p.tgtid, p.srcid, p.txnid, p.dbid, opcode);
  $sformat(s, "%s resperr:%s resp:%0d fwdstate:%0d datapull:%0d",
           s, p.m_resp.get_resp_err_type(), p.m_resp.get_resp(),
           p.m_resp.get_fwd_state(), p.datapull);
  return s;
endfunction: conv2str_rsp_chnl_pkt

function string chi_container::conv2str_dat_chnl_pkt(
  const ref chi_bfm_dat_t p);
  string s;
  chi_bfm_dat_opcode_t opcode;

  opcode = p.m_resp.get_dat_opcode_type();
  $sformat(s, "%s tgtid:%0d srcid:%0d txnid:0x%0h dbid:0x%0h opcode:%s",
           s, p.tgtid, p.srcid, p.txnid, p.dbid, opcode);
  $sformat(s, "%s resp:0x%0h resperr:%s fwdstate:%0d datapull:%0d ccid:%0d",
           s, p.m_resp.get_resp(), p.m_resp.get_resp_err_type(),
           p.m_resp.get_fwd_state(), p.datapull, p.m_info.get_ccid());
  $sformat(s, "%s datasource:%0d", s, p.datasource);

  for (int i = 0; i < p.m_info.num_flits(); ++i) begin
    $sformat(s, "%s dataid:%0d", s, p.m_info.get_tx_dataid(i));
    $sformat(s, "%s data: 0x%0h be: 0x%0h",
             s, p.m_info.get_tx_data(i), p.m_info.get_tx_be(i));
  end
  return s;
endfunction: conv2str_dat_chnl_pkt

function string chi_container::conv2str_snp_chnl_pkt(
  const ref chi_bfm_snp_t p);
  string s;

  $sformat(s, "%s tgtid:%0d txnid:0x%0h fwdtxnid:0x%0h stashlpid:0x%0h stashlpid_vld:%0d",
           s, p.tgtid, p.txnid, p.fwdtxnid, p.stashlpid, p.stashlpid_vld);
  $sformat(s, "%s vmid_ext:%0d srcid:%0d opcode:%s addr:0x%0h ns:%0b",
           s, p.vmid_ext, p.srcid, p.opcode.name(), p.addr, p.ns);
  $sformat(s, "%s donotgoto_sd:%0d donot_datapull:%0d ret2src:%0d",
           s, p.donotgoto_sd, p.donot_datapull, p.ret2src);
  return s;
endfunction: conv2str_snp_chnl_pkt

function bit chi_container::is_rdnosnp(int txnid);
  return (m_chi_txns[txnid].m_req_opcode == BFM_READNOSNP);
endfunction: is_rdnosnp

function bit chi_container::is_rdonce(int txnid);
  return (m_chi_txns[txnid].m_req_opcode == BFM_READONCE ||
          m_chi_txns[txnid].m_req_opcode == BFM_READONCEMAKEINVALID ||
          m_chi_txns[txnid].m_req_opcode == BFM_READONCECLEANINVALID);
endfunction: is_rdonce

function bit chi_container::is_prefetch(int txnid);
  return (m_chi_txns[txnid].m_req_opcode == BFM_PREFETCHTARGET);
endfunction: is_prefetch

function bit chi_container::is_wrnosnp(int txnid);
  return (m_chi_txns[txnid].m_req_opcode == BFM_WRITENOSNPFULL ||
          m_chi_txns[txnid].m_req_opcode == BFM_WRITENOSNPPTL);
endfunction: is_wrnosnp

function bit chi_container::is_wrunq(int txnid);
  return (m_chi_txns[txnid].m_req_opcode == BFM_WRITEUNIQUEFULL ||
          m_chi_txns[txnid].m_req_opcode == BFM_WRITEUNIQUEPTL);
endfunction: is_wrunq

function bit chi_container::is_atomic(int txnid);
  return (m_chi_txns[txnid].m_req_opcode == BFM_ATOMICSTORE_STADD  || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICSTORE_STCLR  || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICSTORE_STEOR  || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICSTORE_STSET  || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICSTORE_STSMAX || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICSTORE_STMIN  || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICSTORE_STUSMAX|| 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICSTORE_STUMIN || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICLOAD_LDADD   || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICLOAD_LDCLR   || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICLOAD_LDEOR   || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICLOAD_LDSET   || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICLOAD_LDSMAX  || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICLOAD_LDMIN   || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICLOAD_LDUSMAX || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICLOAD_LDUMIN  || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICSWAP         || 
          m_chi_txns[txnid].m_req_opcode == BFM_ATOMICCOMPARE
  );
endfunction: is_atomic

function bit chi_container::is_partial(int txnid);
  return (m_chi_txns[txnid].m_req_opcode == BFM_WRITECLEANPTL  ||
          m_chi_txns[txnid].m_req_opcode == BFM_WRITEUNIQUEPTL ||
          m_chi_txns[txnid].m_req_opcode == BFM_WRITEBACKPTL   ||
          m_chi_txns[txnid].m_req_opcode == BFM_WRITENOSNPPTL  ||
          m_chi_txns[txnid].m_req_opcode == BFM_WRITEUNIQUEPTLSTASH
  ); 
endfunction: is_partial

function bit chi_container::is_wrback(int txnid);
  return (m_chi_txns[txnid].m_req_opcode == BFM_WRITEBACKFULL ||
          m_chi_txns[txnid].m_req_opcode == BFM_WRITEBACKPTL);
endfunction: is_wrback

function bit chi_container::is_stash_snoop(
    chi_bfm_snp_opcode_t opcode);

  return (opcode == BFM_SNPUNIQUESTASH      ||
          opcode == BFM_SNPMAKEINVALIDSTASH || 
          opcode == BFM_SNPSTASHUNIQUE      ||
          opcode == BFM_SNPSTASHSHARED);

endfunction: is_stash_snoop

//For opcodes for responses are not expected refer
//CHI Spec Ch 4.5.1 Pg 146
function bit chi_container::is_rsp4txn_exp(int txnid);
  return (
      m_chi_txns[txnid].m_txn_valid &&
      (!(m_chi_txns[txnid].m_txn_state_blkd  ||
         m_chi_txns[txnid].m_txn_order_blkd
        )
      ) || 
      (!(m_chi_txns[txnid].m_req_opcode == BFM_PREFETCHTARGET ||
         m_chi_txns[txnid].m_req_opcode == BFM_PCRDRETURN
        )
      )
  );
endfunction: is_rsp4txn_exp

function bit chi_container::is_read_receipt_exp(int txnid);
  `ASSERT(is_rsp4txn_exp(txnid));
  return (
      (m_chi_txns[txnid].m_opcode_type == RD_NONCOH_CMD ||
       m_chi_txns[txnid].m_opcode_type == RD_RDONCE_CMD
      ) &&
      (m_chi_txns[txnid].m_req_order == REQUEST_ORDER   || 
       m_chi_txns[txnid].m_req_order == ENDPOINT_ORDER
      )
  );
endfunction: is_read_receipt_exp

function bit chi_container::is_comp_exp(int txnid);
  `ASSERT(is_rsp4txn_exp(txnid));
  `ASSERT(
      !(m_chi_txns[txnid].m_opcode_type == ATOMIC_ST_CMD ||
        m_chi_txns[txnid].m_opcode_type == ATOMIC_LD_CMD ||
        m_chi_txns[txnid].m_opcode_type == ATOMIC_SW_CMD ||
        m_chi_txns[txnid].m_opcode_type == ATOMIC_CM_CMD),
      "Not yet Implemented"
  );

  return (
      m_chi_txns[txnid].m_opcode_type == DT_LS_UPD_CMD ||
      m_chi_txns[txnid].m_opcode_type == DT_LS_CMO_CMD ||
      m_chi_txns[txnid].m_opcode_type == DT_LS_STH_CMD ||
      m_chi_txns[txnid].m_opcode_type == WR_NONCOH_CMD ||
      m_chi_txns[txnid].m_opcode_type == WR_COHUNQ_CMD ||
      m_chi_txns[txnid].m_opcode_type == WR_STHUNQ_CMD ||
      m_chi_txns[txnid].m_opcode_type == DVM_OPERT_CMD 
  );
endfunction: is_comp_exp

function bit chi_container::is_compdbid_exp(int txnid);
  `ASSERT(is_rsp4txn_exp(txnid));
  return (m_chi_txns[txnid].m_opcode_type == WR_CPYBCK_CMD ||
          m_chi_txns[txnid].m_opcode_type == ATOMIC_ST_CMD ||
          ((m_chi_txns[txnid].m_opcode_type == WR_NONCOH_CMD) && m_chi_txns[txnid].m_req_memattr[0] && (!m_chi_txns[txnid].m_req_excl)));
endfunction: is_compdbid_exp

function bit chi_container::is_dbid_exp(int txnid);
  `ASSERT(is_rsp4txn_exp(txnid));
  `ASSERT(!(m_chi_txns[txnid].m_opcode_type == WR_STHUNQ_CMD),
            "Not yet implemented");
  return (m_chi_txns[txnid].m_opcode_type == WR_NONCOH_CMD ||
          m_chi_txns[txnid].m_opcode_type == ATOMIC_ST_CMD ||
          m_chi_txns[txnid].m_opcode_type == ATOMIC_LD_CMD ||
          m_chi_txns[txnid].m_opcode_type == ATOMIC_SW_CMD ||
          m_chi_txns[txnid].m_opcode_type == ATOMIC_CM_CMD ||
          m_chi_txns[txnid].m_opcode_type == DVM_OPERT_CMD ||
          m_chi_txns[txnid].m_opcode_type == WR_COHUNQ_CMD);
endfunction: is_dbid_exp

function bit chi_container::is_compdata_exp(int txnid);
  `ASSERT(is_rsp4txn_exp(txnid));
  return (!(m_chi_txns[txnid].all_rxdat_flits_rcvd()) &&
          (m_chi_txns[txnid].m_opcode_type == RD_NONCOH_CMD ||
           m_chi_txns[txnid].m_opcode_type == RD_RDONCE_CMD ||
           m_chi_txns[txnid].m_opcode_type == RD_LDRSTR_CMD ||
           m_chi_txns[txnid].m_opcode_type == ATOMIC_LD_CMD || 
           m_chi_txns[txnid].m_opcode_type == ATOMIC_CM_CMD || 
           m_chi_txns[txnid].m_opcode_type == ATOMIC_SW_CMD ||
           m_chi_txns[txnid].m_opcode_type == SNP_STASH_CMD));
endfunction: is_compdata_exp

function addr_width_t chi_container::aligned64B_addr(addr_width_t addr);
  return ((addr >> 6) << 6);
endfunction: aligned64B_addr

function int chi_container::pow2(int size);
  case (size)
    0: return 1;
    1: return 2;
    2: return 4;
    3: return 8;
    4: return 16;
    5: return 32;
    6: return 64;
    default: `ASSERT(0, $psprintf("Unexepected size:%0d", size));
  endcase
endfunction: pow2

function int chi_container::num_beats(int st_byte, int size);
  int nbeats;
  int ed_byte;
  int st_ch_algn_byte, ed_ch_algn_byte;
  string s;
  st_byte = 'h0;

  ed_byte = st_byte + pow2(size);
  st_ch_algn_byte = (st_byte >> bus_align_const()) << bus_align_const();
  ed_ch_algn_byte = (ed_byte >> bus_align_const()) << bus_align_const();

  if (ed_byte != ed_ch_algn_byte)
    ed_ch_algn_byte = ed_ch_algn_byte + (1 << bus_align_const());

  if (ed_ch_algn_byte > st_ch_algn_byte) begin
    `ASSERT((ed_ch_algn_byte - st_ch_algn_byte) % m_nbytes_per_flit == 0);
    nbeats =  (ed_ch_algn_byte - st_ch_algn_byte) / m_nbytes_per_flit;
  end else begin
    `ASSERT((st_ch_algn_byte - ed_ch_algn_byte) % m_nbytes_per_flit == 0);
    nbeats = (st_ch_algn_byte - ed_ch_algn_byte) / m_nbytes_per_flit;
  end

  $sformat(s, "%s nbeats: %0d st_ch_algn_byte:%0d ed_ch_algn_byte: %0d",
      s, nbeats, st_ch_algn_byte, ed_ch_algn_byte);
  $sformat(s, "%s st_byte:%0d size:%0d m_nbytes_per_flit:%0d",
      s, st_byte, size, m_nbytes_per_flit);

  `ASSERT(nbeats > 0 && nbeats <= 64 / m_nbytes_per_flit, s);
  return nbeats;
endfunction: num_beats

function int chi_container::mod64(int value);
  return value % 64;
endfunction: mod64

function int chi_container::bus_align_const();
  int res;
  int width;

  width = 1;
  while (!(width << res == m_nbytes_per_flit))
    ++res;
  return res;
endfunction: bus_align_const

function bit [1:0] chi_container::get_ccid(addr_width_t addr);
  bit [1:0] res;

  //res = (addr & 6'h3F) >> bus_align_const();
  //if (m_nbytes_per_flit == 16)
  //  return res;
  //else if (m_nbytes_per_flit == 32)
  //  return res << 1;
  res = addr[5:4];
  return res;

  //return 0;
endfunction: get_ccid

function bit [5:0] pick_starting_byte(int size);
  bit [5:0] stb;
  bit legal;

  while (!legal) begin
    stb = $urandom_range(0, 63);
    if (stb + size < 64)
      legal = 1;
  end
  return stb;
endfunction: pick_starting_byte

function void chi_container::sch_any_state_blocked_txns();
  int del_idxq[$];
  int addr_try_counter;
  chi_bfm_cache_state_t c_st;

  foreach (m_unscheduled_txnq[idx]) begin
    int txnid = m_unscheduled_txnq[idx];
    if (m_chi_txns[txnid].m_txn_state_blkd) begin
      bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] addr;
      bit ret;

      ret = get_normal_local_cache_addr(
              m_chi_txns[txnid].get_cache_st(), addr);
/*
    $display("%t, CHI[%d], 1normal addr %x, opocode %s  starting cache st %s, ret %X", $time, ID, addr,  m_chi_txns[txnid].m_req_opcode.name, m_chi_txns[txnid].get_cache_st().name, ret);
    c_st = c_st.first;
    do
    begin
	foreach(m_installed_cachelines[c_st][i])
	begin
	  $display("%t, CHI[%d] 6normal addr %x, state %s pick_itr %x", $time, ID, m_installed_cachelines[c_st][i], c_st.name, i);
	end
	c_st = c_st.next;
    end while(c_st!=c_st.first);
*/	
      if (ret) begin
        m_chi_txns[txnid].m_req_addr = addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0];
        m_chi_txns[txnid].m_req_ns   = addr[ncoreConfigInfo::W_SEC_ADDR - 1];
        m_chi_txns[txnid].m_txn_state_blkd = 0;
        install_cacheline(m_chi_txns[txnid].get_cache_st(), addr);
        
        if (order_checks_on_req_txn(txnid)) begin
          m_tx_req_chnl_cb.put_chi_txn(m_chi_txns[txnid]);
          del_idxq.push_back(idx);
        end else begin
          m_chi_txns[txnid].m_txn_order_blkd = 1'b1;
        end
      end else begin
        m_chi_txns[txnid].tried_to_state_unblock_counter++;
        if (m_chi_txns[txnid].tried_to_state_unblock_counter > 9) begin
            //`uvm_info("CHI_BFM_DEBUG", $psprintf("tried_to_state_unblock_counter reached 10. Changing address for txnid:0x%0h",txnid), UVM_HIGH)
            //Delete the entry from order blocked queues before changing the address
            if (m_chi_txns[txnid].m_txn_order_blkd == 1'b1) begin
                if (m_chi_txns[txnid].m_req_order == REQUEST_ORDER) begin
                  del_entry_in_req_ordq_if_any(txnid);
                end else if (m_chi_txns[txnid].m_req_order == ENDPOINT_ORDER) begin
                    int q[$];
                    ncore_memory_map m_map;
                    ncoreConfigInfo::intq regionq;

                    void'(del_entry_in_req_ordq_if_any(txnid));
                    m_map = m_addr_mgr.get_memory_map_instance();
                    regionq  = m_map.get_iocoh_mem_regions();
                    foreach (regionq[idx]) begin
                       bit [63:0] lreg;
                       bit [63:0] hreg;

                       lreg = ncoreConfigInfo::memregion_boundaries[regionq[idx]].start_addr;
                       hreg = ncoreConfigInfo::memregion_boundaries[regionq[idx]].end_addr;
                       if (m_chi_txns[txnid].m_req_addr >= lreg && m_chi_txns[txnid].m_req_addr < hreg) begin
                         int q[$];
                         int del_indxq[$];

                         q = m_pend_endpoint_txnq.find(x) with (x == regionq[idx]);
                         //Legal values for size of q is 0 or 1
                         `ASSERT(q.size() < 2);
                         if (q.size() == 1) begin
                           del_indxq = m_pend_endpoint_txnq.find_index(x) with (
                             x == regionq[idx]);
                           m_pend_endpoint_txnq.delete(del_indxq[0]);
                         end 
                         break;
                       end
                    end
                end
            end 
          //  addr = get_normal_coh_mem_addr(1); // + 'h40;
          //  if(m_chi_cache.exists(aligned64B_addr(addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0])))
           // 	addr = get_normal_coh_mem_addr(1);
      //Added a loop to check if the new address already exists in the local cache or not, for CONC-4909
      addr_try_counter = 0;

      do begin 
        <% if (obj.initiatorGroups.length >= 1) { %>
        int try_count = 10_000;
        do begin // Force addr to be connected to the initiator
        <% } %>
        addr = get_normal_coh_mem_addr(1);
        <% if (obj.initiatorGroups.length >= 1) { %>
        try_count--;
        end while(try_count!=0  && !$test$plusargs("unmapped_add_access") && ncoreConfigInfo::check_unmapped_add(addr, <%=obj.AiuInfo[obj.Id].FUnitId%>, dec_err_type));
        
        if(!try_count) begin
          `uvm_error("Connectivity Interleaving CHI CONTAINER",$sformatf("Not succeed to generate connected addr inside user_addrq, Hitting possible 0-time infinite loop here"))
        end 
        <% } %>

        addr_try_counter++;
        if (addr_try_counter > 80) begin
          `uvm_warning(get_type_name(), $psprintf("Number of tries to get a new address failed for 80 times"));
          break;
        end
      end while (m_chi_cache.exists(aligned64B_addr(addr)));
			
            `ASSERT(addr != 0);
            m_chi_txns[txnid].m_req_addr = addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0];
            if (!$test$plusargs("non_secure_access_test")) begin
                m_chi_txns[txnid].m_req_ns   = addr[ncoreConfigInfo::W_SEC_ADDR - 1];
            end
            m_chi_txns[txnid].m_txn_state_blkd = 0;
     <%if(obj.testBench == "fsys"|| obj.testBench == "emu"){ %>
            if(addr_try_counter<=30)
            begin
            	install_cacheline(m_chi_txns[txnid].get_cache_st(), addr);
       	    end     
     <%}else{%>
            	install_cacheline(m_chi_txns[txnid].get_cache_st(), addr);
     <%}%>    
            //`uvm_info("CHI_BFM_DEBUG", $psprintf("Changing address for txnid:0x%0h",txnid), UVM_HIGH)
        
            if (order_checks_on_req_txn(txnid)) begin
              m_chi_txns[txnid].m_txn_order_blkd = 0;
              m_tx_req_chnl_cb.put_chi_txn(m_chi_txns[txnid]);
            //`uvm_info("CHI_BFM_DEBUG", $psprintf("issuing transaction. Changing address for txnid:0x%0h",txnid), UVM_HIGH)
              del_idxq.push_back(idx);
            end else begin
              m_chi_txns[txnid].m_txn_order_blkd = 1'b1;
            //`uvm_info("CHI_BFM_DEBUG", $psprintf("Marking order blocked. Changing address for txnid:0x%0h",txnid), UVM_HIGH)
            end
//$display("%t, 2normal addr %x, opocode %s ret %X", $time, addr,  m_chi_txns[txnid].m_req_opcode.name, ret);
          `uvm_warning(get_type_name(), $psprintf("%t, Forcing addr %x, opocode %s ret %X", $time, addr,  m_chi_txns[txnid].m_req_opcode.name, ret));


        end

      end
      end
    end
  
  //foreach (del_idxq[idx])
  for (int i=del_idxq.size()-1; i >= 0; i--) 
    m_unscheduled_txnq.delete(del_idxq[i]);
endfunction: sch_any_state_blocked_txns

//parameter to the method is the txnid that just reveived POS guarntee 
//from RTL
function void chi_container::sch_any_order_block_txns(int txnid);
  if (m_chi_txns[txnid].m_req_order == REQUEST_ORDER) begin
    if (!sch_any_reqord_txns(txnid)) begin
      void'(sch_any_edpord_txns(txnid, m_chi_txns[txnid].m_opcode_type));
     end
  end else if (m_chi_txns[txnid].m_req_order == ENDPOINT_ORDER) begin
    if (!sch_any_edpord_txns(txnid, m_chi_txns[txnid].m_opcode_type))
      void'(sch_any_reqord_txns(txnid));
  end
endfunction: sch_any_order_block_txns

function bit chi_container::sch_any_reqord_txns(int txnid);
  del_entry_in_req_ordq_if_any(txnid);
  //Schedule any txns that were blocked due to ordering collision
  foreach (m_unscheduled_txnq[idx]) begin
    int lid;
    bit addr_match;

    lid = m_unscheduled_txnq[idx];
    addr_match = (aligned64B_addr(m_chi_txns[lid].m_req_addr) == 
                  aligned64B_addr(m_chi_txns[txnid].m_req_addr));

    if(addr_match && m_chi_txns[lid].m_req_order == ENDPOINT_ORDER) m_chi_txns[lid].m_req_order = REQUEST_ORDER;

    if (m_chi_txns[lid].m_txn_order_blkd && addr_match && order_checks_on_req_txn(lid)) begin
      m_unscheduled_txnq.delete(idx);
      m_chi_txns[lid].m_txn_order_blkd = 0;
      m_tx_req_chnl_cb.put_chi_txn(m_chi_txns[lid]);
      return 1'b1;
    end
  end
  return 1'b0;
endfunction: sch_any_reqord_txns

function bit chi_container::sch_any_edpord_txns(int txnid, chi_bfm_opcode_type_t opcode_type);
  ncoreConfigInfo::intq regionq;
  bit [ncoreConfigInfo::ADDR_WIDTH - 1 : 0] tmp_addr;
  int endpoint_idx;
  ncore_memory_map m_map;
  chi_bfm_opcode_type_t temp_opcode_type;

  void'(del_entry_in_req_ordq_if_any(txnid));
  endpoint_idx = -1;
  tmp_addr = m_chi_txns[txnid].m_req_addr;
  m_map = m_addr_mgr.get_memory_map_instance();
  temp_opcode_type = opcode_type; 
 // regionq  = m_map.get_iocoh_mem_regions();
        if (temp_opcode_type == RD_RDONCE_CMD || temp_opcode_type == ATOMIC_ST_CMD || temp_opcode_type == ATOMIC_LD_CMD || temp_opcode_type == ATOMIC_SW_CMD || temp_opcode_type == ATOMIC_CM_CMD || temp_opcode_type == WR_COHUNQ_CMD) begin
             regionq  = m_map.get_coh_mem_regions();
        end else begin
             regionq  = m_map.get_iocoh_mem_regions();
        end
  //`uvm_info("CHI_BFM_DEBUG", $psprintf("Processing txnid:0x%0h, addr:0x%0h", txnid, tmp_addr), UVM_HIGH)
  foreach (regionq[idx]) begin
    bit [63:0] lreg;
    bit [63:0] hreg;

    lreg = ncoreConfigInfo::memregion_boundaries[regionq[idx]].start_addr;
    hreg = ncoreConfigInfo::memregion_boundaries[regionq[idx]].end_addr;
    if (tmp_addr >= lreg && tmp_addr < hreg) begin
      int q[$];
      int del_indxq[$];

      //`uvm_info("CHI_BFM_DEBUG", $psprintf("2-Processing txnid:0x%0h", txnid), UVM_HIGH)
      q = m_pend_endpoint_txnq.find(x) with (x == regionq[idx]);
      //Legal values for size of q is 0 or 1
      `ASSERT(q.size() < 2);
      if (q.size() == 1) begin
        //`uvm_info("CHI_BFM_DEBUG", $psprintf("3-Processing txnid:0x%0h", txnid), UVM_HIGH)
        del_indxq = m_pend_endpoint_txnq.find_index(x) with (
          x == regionq[idx]);
        m_pend_endpoint_txnq.delete(del_indxq[0]);
        endpoint_idx = regionq[idx];
      end 
      break;
    end
  end
  
  //Schedule any txns that were blocked due to ordering collision
  if (endpoint_idx > -1) begin
    //`uvm_info("CHI_BFM_DEBUG", $psprintf("4-Processing txnid:0x%0h", txnid), UVM_HIGH)
    foreach (m_unscheduled_txnq[idx]) begin
      int lid;
      bit addr_match;

      lid = m_unscheduled_txnq[idx];
      addr_match = 
         (m_chi_txns[lid].m_req_addr >=
              ncoreConfigInfo::memregion_boundaries[endpoint_idx].start_addr) &&
         (m_chi_txns[lid].m_req_addr <
              ncoreConfigInfo::memregion_boundaries[endpoint_idx].end_addr);

      if (m_chi_txns[lid].m_txn_order_blkd && addr_match &&
          order_checks_on_req_txn(lid)) begin
        //`uvm_info("CHI_BFM_DEBUG", $psprintf("6-Processing txnid:0x%0h", txnid), UVM_HIGH)
        m_unscheduled_txnq.delete(idx);
        m_chi_txns[lid].m_txn_order_blkd = 0;
        m_tx_req_chnl_cb.put_chi_txn(m_chi_txns[lid]);
        return 1'b1;
      end
    end
  end
  return 1'b0;
endfunction: sch_any_edpord_txns

function bit chi_container::is_addr_cacheable(addr_width_t addr);
  ncore_memory_map m_map;
  ncoreConfigInfo::intq coh_regionsq;
  int assoc_mem_region;
  addr_width_t tmp_addr;
  int q[$];

  tmp_addr = aligned64B_addr(addr);
  //Exclude NS bit
  tmp_addr = tmp_addr[ncoreConfigInfo::ADDR_WIDTH - 1 : 0];
  m_map = m_addr_mgr.get_memory_map_instance();
  coh_regionsq = m_map.get_coh_mem_regions();

  //if (!$test$plusargs("unmapped_add_access")) begin
if ((!$test$plusargs("unmapped_add_access") && (!$test$plusargs("pick_boundary_addr"))) || ($test$plusargs("unmapped_add_access") && !addr_trans_mgr::check_unmapped_add(tmp_addr,<%=obj.AiuInfo[obj.Id].FUnitId%>,dec_err_type))) begin
    //Get memory-region ID to given addr
    `ASSERT(ncoreConfigInfo::map_addr2dmi_or_dii(
        tmp_addr, assoc_mem_region) != -1);
    q = coh_regionsq.find(x) with (x == assoc_mem_region);

    `ASSERT(q.size() == 0 || q.size() == 1);
    return q.size() == 1;
  end else begin
    return 0;
  end
endfunction: is_addr_cacheable

function chi_bfm_cache_state_t chi_container::get_installed_cache_state(
    addr_width_t addr);

  addr_width_t tmp_addr;

  tmp_addr = aligned64B_addr(addr);
  if (m_chi_cache.exists(tmp_addr))
    return m_chi_cache[tmp_addr].get_cacheline_state();

  return CHI_IX;
endfunction: get_installed_cache_state

function void chi_container::write_cacheline_data(
    int txnid,
    chi_data_be_t info);
  addr_width_t aligned_addr;

  aligned_addr = aligned64B_addr(m_chi_txns[txnid].get_cacheline_addr());
  `ASSERT(m_chi_cache.exists(aligned_addr));
  for (int i = 0; i < 64; ++i) 
    m_chi_cache[aligned_addr].set_valid_bytes(
        i, info.m_data[i], info.m_be[i]);
endfunction: write_cacheline_data

function void chi_container::install_cacheline(
    chi_bfm_cache_state_t end_state,
    addr_width_t          cacheline_addr);

  addr_width_t aligned_addr;
  chi_bfm_cache_state_t c_st;
  bit new_addr;
  int silent_update_uce_to_udp;

  aligned_addr = aligned64B_addr(cacheline_addr);
  if (!m_chi_cache.exists(aligned_addr))
  begin
    m_chi_cache[aligned_addr] = new($psprintf("m_cacheline[0x%0h]", aligned_addr));
    new_addr = 1;
  end
  `ASSERT(cacheline_addr != 0);

  m_chi_cache[aligned_addr].set_cacheline_addr(aligned_addr);
  m_chi_cache[aligned_addr].set_cacheline_state(end_state);
  //Inform address manager if end state is IX for re-use purpose
  //else install the cacheline in L1 cache
  c_st = end_state.first;

  if (end_state != CHI_IX) begin
    do
    begin
	foreach(m_installed_cachelines[c_st][i])
	begin
	//$display("%t, 6normal addr %x, state %s pick_itr %x", $time, addr, c_st.name, i);
		if(m_installed_cachelines[c_st][i] === cacheline_addr)begin
			m_installed_cachelines[c_st].delete(i);
		end
	end
	c_st = c_st.next;
    end while(c_st!=c_st.first);

    if(end_state inside {CHI_UCE} && $test$plusargs("silent_update_uce_to_udp") ) begin
        if(!$value$plusargs("silent_update_uce_to_udp=%0d",silent_update_uce_to_udp)) begin
          silent_update_uce_to_udp = 50;
        end

        randcase
          100 - silent_update_uce_to_udp: begin end
          silent_update_uce_to_udp:       begin
                                            //Cacheline silently upgraded from UCE to UDP state
                                            end_state = CHI_UDP;
                                          end
        endcase
    end

    m_installed_cachelines[end_state].push_back(cacheline_addr);
  end else if(!new_addr) begin
    m_installed_cachelines[end_state].push_back(cacheline_addr);
    m_chi_cache[aligned_addr].reset_data();
    //if the line is from snooop stash, the address might not have the key registered in the addr_mgr
    //if(m_addr_mgr.m_gen.addr_present_ncore((ncoreConfigInfo::get_aiu_funitid(<%=obj.AiuInfo[obj.Id].FUnitId%>) << ncoreConfigInfo::W_SEC_ADDR) | cacheline_addr))
    if(end_state inside {CHI_UC, CHI_SC, CHI_UCE, CHI_UD}) begin
      m_addr_mgr.addr_evicted_from_agent(<%=obj.AiuInfo[obj.Id].FUnitId%>, 1, cacheline_addr);
    end
    
    `uvm_info(get_full_name(), $sformatf("evicted sstate %s, addr %x", end_state.name(), cacheline_addr), UVM_LOW)

  end
`uvm_info(get_full_name(), $sformatf("sstate %s, addr %x", end_state.name(), cacheline_addr), UVM_LOW)
endfunction: install_cacheline

function chi_bfm_cache_state_t chi_container::get_end_state(
  int txnid,
  const ref chi_rsp_dat_chnl_resp_t m_resp);
  
  if (is_rdnosnp(txnid) || is_rdonce(txnid) || is_atomic(txnid) || is_prefetch(txnid))
    return CHI_IX;

  if (m_chi_txns[txnid].get_opcode_type() == RD_LDRSTR_CMD || 
      m_chi_txns[txnid].get_opcode_type() == SNP_STASH_CMD) begin
    case (m_resp.get_compdata_rsp())
      BFM_COMPDATA_IX:    return CHI_IX;
      BFM_COMPDATA_UC:    return CHI_UC;
      BFM_COMPDATA_SC:    return CHI_SC;
      BFM_COMPDATA_UD_PD: return CHI_UD;
      BFM_COMPDATA_SD_PD: return CHI_SD;
      default: `ASSERT(0, "ERROR: Unpexpected response received");
    endcase
  end

  if (m_chi_txns[txnid].get_opcode_type() == DT_LS_STH_CMD) begin
    case (m_resp.get_comprsp_resp())
      BFM_COMP_IX: return CHI_IX;
      BFM_COMP_UC: return CHI_UC;
      BFM_COMP_SC: return CHI_SC;
      default: `ASSERT(0, "ERROR: Unpexpected response received");
    endcase
  end

  if (m_chi_txns[txnid].get_opcode_type() == DT_LS_CMO_CMD
      || m_chi_txns[txnid].get_opcode_type() == DT_LS_UPD_CMD 
      || m_chi_txns[txnid].get_opcode_type() == WR_CPYBCK_CMD )
    return get_installed_cache_state(m_chi_txns[txnid].m_req_addr);

  `ASSERT(0, $psprintf("ERROR: txnid:0x%0h", txnid));
  return CHI_IX;
endfunction: get_end_state

function chi_bfm_copyback_rsp_t chi_container::get_wrdat_resp(
    addr_width_t 		addr,
    chi_bfm_cache_state_t     	end_state);

  addr_width_t tmp_addr;

  tmp_addr = aligned64B_addr(addr);
  if (m_chi_cache.exists(tmp_addr)) begin
    case (m_chi_cache[tmp_addr].get_cacheline_state())
      CHI_IX:  return BFM_NONCPYBCK_CPYBCK_IX;
      CHI_SC:  return BFM_COPYBACKWRDATA_SC;
      CHI_SD:  return BFM_COPYBACKWRDATA_SD_PD;
      CHI_UC:  return BFM_COPYBACKWRDATA_UC;
      CHI_UD:  return BFM_COPYBACKWRDATA_UD_PD;
      CHI_UDP: return BFM_COPYBACKWRDATA_UD_PD;
      default: return BFM_NONCPYBCK_CPYBCK_IX;
    endcase
  end

  return BFM_NONCPYBCK_CPYBCK_IX;
endfunction: get_wrdat_resp

function bit chi_container::txn_outsanding4addr(addr_width_t addr);
  
  foreach (m_chi_txns[idx]) begin
    if (aligned64B_addr(m_chi_txns[idx].m_req_addr) == aligned64B_addr(addr))
      return 1;
  end

  return 0; 
endfunction: txn_outsanding4addr

function bit chi_container::del_entry_in_req_ordq_if_any(int txnid);
  addr_width_t q[$];
  int qidx[$];

  q = m_pend_reqorder_txnq.find(x) with (
    x == aligned64B_addr(m_chi_txns[txnid].m_req_addr));

  `ASSERT((q.size() == 1 || q.size() == 0));

  if (q.size() > 0) begin
    qidx = m_pend_reqorder_txnq.find_index(x) with (
      x == aligned64B_addr(m_chi_txns[txnid].m_req_addr));
    m_pend_reqorder_txnq.delete(qidx[0]);
    return 1;
  end
  return 0;
endfunction: del_entry_in_req_ordq_if_any

endpackage: <%=obj.BlockId%>_chi_container_pkg

