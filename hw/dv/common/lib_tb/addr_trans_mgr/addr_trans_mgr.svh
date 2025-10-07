////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

<% var aiu;if((obj.testBench === "fsys") || (obj.testBench === "cust_tb") || (obj.testBench == "emu")) {    aiu = obj.AiuInfo[obj.Id];} else {    aiu = obj.DutInfo;}%>
<% 
var _child_blkid = [];
var chiaiu_idx = 0;
var ioaiu_idx = 0;

if((obj.testBench === "fsys") || (obj.testBench === "cust_tb") || (obj.testBench == "emu")) {
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(obj.AiuInfo[pidx].fnNativeInterface.includes('CHI')) {
      _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
      chiaiu_idx++;
    } else {
      _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
      ioaiu_idx++;
    }
  }
} else {
  _child_blkid[0] = obj.BlockId;
}

%>

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Class : gen_new_cacheline
// Description : Singleton class that all components instantiate to lookup/modify cachelines
//               in the system
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
class addr_trans_mgr extends uvm_object;

  `uvm_object_param_utils(addr_trans_mgr)

  //Handles
  local static addr_trans_mgr m_mgr;
  local static ncore_memory_map      m_mem;
  local static gen_new_cacheline     m_gen;
  bit        enable_populate_addrq;

  //flags
  local bit c_memmap;

  //constructor
  extern function new(string s = "addr_trans_mgr");
  //extern local function new(string s = "addr_trans_mgr");

  //class Interface 
  extern static function addr_trans_mgr get_instance();
  extern function void gen_memory_map();
  extern function ncore_memory_map get_memory_map_instance();

  extern function void populate_atomic_capable_addrq();
  extern function void populate_addrq();
  extern function void set_addr_collision_pct(int funitid, bit en_funitid, int hit_pct);
  extern function void addr_evicted_from_agent(int funitid,
                                               bit en_funitid,
                                               bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] addr);

  // Methods to get memory region lower and upper bounds
  extern function void get_mem_region_bounds(int mid,
                                             output [ncoreConfigInfo::W_SEC_ADDR -1:0] lb,
                                             output [ncoreConfigInfo::W_SEC_ADDR -1:0] ub);
                                             
  ////
  //Methods to request for address or cacheline
  ////
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_coh_addr(int funitid, 
                                                                   bit en_funitid, 
                                                                   bit collision_user = 0, 
                                                                   int core_id=0, 
                                                                   int set_index = -1,
                                                                   int tfilter_id = -1);

  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_coh_addr(int funitid,
                                                                   bit en_funitid,
                                                                   int target_id    = -1,
                                                                   int memregion_id = -1,
                                                                   int tfilter_id   = -1,
                                                                   int set_index    = -1,
                                                                   int core_id      =  0);

  //interface methods to request IO-coherent address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_iocoh_addr(int funitid, 
                                                                     bit en_funitid, 
                                                                     int core_id=0);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_iocoh_addr(int funitid,
                                                                     bit en_funitid,
                                                                     int memregion_id, int core_id=0);
<%if (obj.testBench == "fsys" || obj.testBench == "dii") {%>
// This function is quickly build to generate address to particular target (e.g. DII0). Need to verify this function.
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_sel_targ_addr_from_unit_attr(
         string unit_type="DII",/* "DII" OR "DMI" */
         int unit_id=0, /* unit_type=DII : 0,1,2..., unit_type==DMI= 0,1,2...  */ 
         int index=0, /*For multiple mem region configured for any DII or DMI, select one of them*/
         bit nc=1);
<% } %>

  //interface methods to request Non-coherent address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_noncoh_addr(int funitid, 
                                                                      bit en_funitid, 
                                                                      int core_id=0);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_noncoh_addr(int funitid, 
                                                                      bit en_funitid, 
                                                                      int core_id      =  0);

  //interface methods to request Boot region address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_bootreg_addr(int funitid, bit en_funitid);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_bootreg_addr(int funitid, bit en_funitid);

  //interface methods to request Boot region address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_noncohboot_addr(int funitid, 
                                                                          bit en_funitid, 
                                                                          int core_id=0);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_noncohboot_addr(int funitid, 
                                                                          bit en_funitid, 
                                                                          int core_id=0);

    //interface methods to request Boot region address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_cohboot_addr(int funitid, 
                                                                       bit en_funitid, 
                                                                       int core_id=0);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_cohboot_addr(int funitid, 
                                                                       bit en_funitid, 
                                                                       int core_id=0);

     //interface methods to request User address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_user_coh_addr(int funitid, int idx);
  extern function void gen_user_coh_addr(int funitid, int _size, ref ncoreConfigInfo::addrq maddrq);

     //interface methods to request User address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_user_noncoh_addr(int funitid, int idx);
  extern function void gen_user_noncoh_addr(int funitid, 
                                            int _size, 
                                            ref ncoreConfigInfo::addrq maddrq);

  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] alter_tag_bits(int funitid,
                                                                     bit en_funitid,
                                                                     bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,
                                                                     int tfid = -1);

  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_set_index(int funitid,
                                                                    bit en_funitid,
                                                                    bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,
                                                                    int tfid = -1);

  extern function bit get_addr_target_unit(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr);

  extern function bit noncoh_addr_region_mapped_to_dmi();

  extern static function bit allow_atomic_txn_with_addr(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr);

  extern function void set_sf_addr_in_user_addrq(int agentid, 
                                                 int _nSets, 
                                                 int _nWays, 
                                                 ref ncoreConfigInfo::addrq maddrq);
   
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] alt_bits_in_addr(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr, 
                                                                       bit [63:0] alt_bits, 
                                                                       bit [63:0] idx);

  extern function void get_addrq_w_fix_set_index(int set_index, 
                                                 int agent_id, 
                                                 int core_id = 0, 
                                                 int num_addr, 
                                                 ref ncoreConfigInfo::addrq maddrq,ncoreConfigInfo::mem_type get_coh_noncoh_type,bit usecache);
  
  extern function void set_dce_sf_fix_index_in_user_addrq(int agentid, 
                                                          ref ncoreConfigInfo::addrq maddrq, 
                                                          output int csrq_idx);
   
  extern function void set_dmi_smc_fix_index_in_user_addrq(int agentid, 
                                                           ref ncoreConfigInfo::addrq maddrq, 
                                                           input bit c_nc);
   
  extern function void gen_seq_addr_in_user_addrq(int num_addr, 
                                                  int addr_step, 
                                                  int intrlv_grp, 
                                                  int dmi_idx, 
                                                  ref ncoreConfigInfo::addrq maddrq, 
                                                  input bit ioaiu_pick_random = 0, 
                                                  input bit ioaiu_coherent = 0, 
                                                  input int nbr_alternate[0:1]='{0,0}, 
                                                  input int size_alternate[0:1]='{0,0});

  extern function void gen_noncoh_addr_in_user_addrq(int num_addr, ref ncoreConfigInfo::addrq maddrq);

  extern function void gen_seq_dmi_addr_in_user_addrq(int num_addr, 
                                                      int offset, 
                                                      int intrlv_grp, 
                                                      ref ncoreConfigInfo::addrq maddrq);

  extern function void gen_seq_write_addr_in_user_addrq(int num_addr, 
                                                        int addr_step, 
                                                        int intrlv_grp1, 
                                                        int intrlv_grp2, 
                                                        ref ncoreConfigInfo::addrq maddrq);

  extern function void gen_seq_addr_w_offset_in_user_addrq(int num_addr, 
                                                           int addr_step, 
                                                           int offset, 
                                                           int intrlv_grp, 
                                                           ref ncoreConfigInfo::addrq maddrq);

  extern function void gen_seq_addr_in_user_write_read_addrq(int num_addr, 
                                                             int addr_step, 
                                                             int intrlv_grp, 
                                                             ref ncoreConfigInfo::addrq write_addrq, 
                                                             ref ncoreConfigInfo::addrq read_addrq);

  extern function void gen_seq_dmi_addr_in_user_write_read_addrq(int num_addr, 
                                                                 int offset, 
                                                                 int intrlv_grp, 
                                                                 ref ncoreConfigInfo::addrq write_addrq, 
                                                                 ref ncoreConfigInfo::addrq read_addrq);
  
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_intrlvgrp_addr(int intrlv_grp, 
                                                                         int mem_idx=-1);

  //extern function  get_dmi_unit_addr_range();
  extern function  get_dmi_unit_addr_range( output bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] low_addr_dmi0,
                                                   bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] upp_addr_dmi0,
                                                   bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] low_addr_dmi1,
                                                   bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] upp_addr_dmi1);
  /////
  //Debug Methods
  /////
  extern function void destruct_instance();

  //Internal methods
  extern function void rd_static_memory_map();

  extern function void set_addr_in_agent_mem_map(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,
                                                 int initiator_agentid);

  extern function int get_memregion_info(input bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,
                                         output bit hut,
                                         output bit [4:0] hui);

  static bit [ncoreConfigInfo::NUM_AIUS-1:0][<%=obj.nDCEs%>-1:0] AiuDce_connectivity_vec;
  static bit [ncoreConfigInfo::NUM_AIUS-1:0][<%=obj.nDMIs%>-1:0] AiuDmi_connectivity_vec;
  static bit [ncoreConfigInfo::NUM_AIUS-1:0][<%=obj.nDIIs%>-1:0] AiuDii_connectivity_vec;
  static int aiu_unconnected_units_table[0:ncoreConfigInfo::NUM_AIUS-1][$];
  static bit test_connectivity_test;

  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  // Function : set_connectivity_test
  //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  static function void set_connectivity_test();
    test_connectivity_test = 1'b1;
    m_gen.test_connectivity_test = 1'b1;
    m_mem.test_connectivity_test = 1'b1;
  endfunction : set_connectivity_test

  <% if ((obj.testBench == "fsys") || (obj.testBench == "emu") || (obj.testBench =='io_aiu') || (obj.testBench =='chi_aiu')) { %>
  // Interfaces
  <%for(var pidx = 0; pidx < _child_blkid.length; pidx++) {%> virtual <%=_child_blkid[pidx]%>_connectivity_if connectivity_if_<%=_child_blkid[pidx]%>;
  <%}%>
  extern task get_connectivity_if ();
  <%}%>
  extern static function bit check_unmapped_add(bit [ncoreConfigInfo::ADDR_WIDTH - 1 : 0] addr, int agent_id, output bit [2:0] unit_unconnected);
  extern static function bit check_aiu_is_unconnected(int tgt_unit_id, int src_unit_id);  
  extern static function bit check_unmapped_add_c(bit [ncoreConfigInfo::ADDR_WIDTH - 1 : 0] addr, int agent_id);

endclass: addr_trans_mgr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : new
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function addr_trans_mgr::new(string s = "addr_trans_mgr");
  super.new(s);

  //construct ncore memory map
  m_mem = new("m_mem");
  m_gen = new("m_gen");
  m_gen.get_ncore_mem_map(m_mem);
  ncoreConfigInfo::create_connectivity_unconnected_matrix(aiu_unconnected_units_table);
  m_gen.aiu_unconnected_units_table = aiu_unconnected_units_table;

  if($test$plusargs("unmapped_add_access")) begin
    set_connectivity_test();  
  end
  ncoreConfigInfo::general_global_var["inject_slv_error"]=0;
  ncoreConfigInfo::general_global_var["slv_error_injected"]=0;

endfunction: new

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_instance
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function addr_trans_mgr addr_trans_mgr::get_instance();
  if (m_mgr == null)
    m_mgr = new("m_mgr");

  return m_mgr;
endfunction:get_instance

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_memory_map
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::gen_memory_map();
  if (!c_memmap) begin
    if (ncoreConfigInfo::EN_RUN_TIME_MEM_MAP) begin
      `ASSERT(m_mem.randomize());
      `uvm_info("ADDR MGR",
         { "\n Ncore Memory Map: \n", $psprintf("%s", m_mem.convert2string()),
         "\n"
         }, UVM_NONE)
    end else begin
      rd_static_memory_map();
    end
    populate_atomic_capable_addrq();
    
  void'($value$plusargs("enable_populate_addrq=%0b",enable_populate_addrq));
   if(enable_populate_addrq == 1) begin
   populate_addrq();
   end
  end
  c_memmap = 1;

  //`uvm_error("ADDR MGR","fn:gen_memory_map End test to debug")
endfunction: gen_memory_map

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_memory_map_instance
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncore_memory_map addr_trans_mgr::get_memory_map_instance();
  return m_mem;
endfunction: get_memory_map_instance

function void addr_trans_mgr::populate_addrq();
  ncoreConfigInfo::sys_addr_csr_t csrq[$];
  bit [63:0] start_addr;
  bit [63:0] end_addr;
  bit [63:0] domain_size;
  
  csrq = {};
  csrq = ncoreConfigInfo::get_all_gpra();

  foreach (csrq[i]) begin
    start_addr = {csrq[i].upp_addr, csrq[i].low_addr} << 12;
    if (csrq[i].unit == ncoreConfigInfo::DII) begin 
      domain_size = (1 << (csrq[i].size+12));
      end_addr = start_addr + domain_size - 1;
      ncoreConfigInfo::dii_memory_domain_start_addr.push_back(start_addr);
      ncoreConfigInfo::dii_memory_domain_end_addr.push_back(end_addr);
    end else if ((csrq[i].unit == ncoreConfigInfo::DMI) && (csrq[i].nc==1)) begin
      domain_size = (1 << (csrq[i].size+12)+$clog2(ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][csrq[i].mig_nunitid]));
      end_addr = start_addr + domain_size - 1;
      ncoreConfigInfo::dmi_memory_domain_start_addr.push_back(start_addr);
      ncoreConfigInfo::dmi_memory_domain_end_addr.push_back(end_addr);
      
      ncoreConfigInfo::dmi_memory_noncoh_domain_start_addr.push_back(start_addr);
      ncoreConfigInfo::dmi_memory_noncoh_domain_end_addr.push_back(end_addr);
      
      //split this memregion into cacheable and non_cacheable region
      ncoreConfigInfo::dmi_memory_noncoh_noncacheable_domain_start_addr.push_back(start_addr);
      ncoreConfigInfo::dmi_memory_noncoh_noncacheable_domain_end_addr.push_back(start_addr+((end_addr-start_addr)>>1));
       
      ncoreConfigInfo::dmi_memory_noncoh_cacheable_domain_start_addr.push_back((start_addr+((end_addr-start_addr)>>1)) + 64);
      ncoreConfigInfo::dmi_memory_noncoh_cacheable_domain_end_addr.push_back(end_addr);
    end
    else if ((csrq[i].unit == ncoreConfigInfo::DMI) && (csrq[i].nc==0)) begin
      domain_size = (1 << (csrq[i].size+12)+$clog2(ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][csrq[i].mig_nunitid]));
      end_addr = start_addr + domain_size - 1;
      ncoreConfigInfo::dmi_memory_domain_start_addr.push_back(start_addr);
      ncoreConfigInfo::dmi_memory_domain_end_addr.push_back(end_addr);
      
      ncoreConfigInfo::dmi_memory_coh_domain_start_addr.push_back(start_addr);
      ncoreConfigInfo::dmi_memory_coh_domain_end_addr.push_back(end_addr);
    end
  end
  
 // foreach (ncoreConfigInfo::dmi_memory_domain_start_addr[i]) begin 
 //   `uvm_info(get_name(),$psprintf("dmi_address_region i:%0d start_addr:0x%0h end_addr:0x%0h",i, ncoreConfigInfo::dmi_memory_domain_start_addr[i], ncoreConfigInfo::dmi_memory_domain_end_addr[i]), UVM_LOW)
 // end 

 // foreach (ncoreConfigInfo::dii_memory_domain_start_addr[i]) begin 
 //   `uvm_info(get_name(),$psprintf("dii_address_region i:%0d start_addr:0x%0h end_addr:0x%0h",i, ncoreConfigInfo::dii_memory_domain_start_addr[i], ncoreConfigInfo::dii_memory_domain_end_addr[i]), UVM_LOW)
 // end 
 // 
 // foreach (ncoreConfigInfo::dmi_memory_coh_domain_start_addr[i]) begin 
 //   `uvm_info(get_name(),$psprintf("coh_address_region i:%0d start_addr:0x%0h end_addr:0x%0h",i, ncoreConfigInfo::dmi_memory_coh_domain_start_addr[i], ncoreConfigInfo::dmi_memory_coh_domain_end_addr[i]), UVM_LOW)
 // end 
 // 
 // foreach (ncoreConfigInfo::dmi_memory_noncoh_domain_start_addr[i]) begin 
 //   `uvm_info(get_name(),$psprintf("noncoh_address_region i:%0d start_addr:0x%0h end_addr:0x%0h",i, ncoreConfigInfo::dmi_memory_noncoh_domain_start_addr[i], ncoreConfigInfo::dmi_memory_noncoh_domain_end_addr[i]), UVM_LOW)
 // end 
 //
 // foreach (ncoreConfigInfo::dmi_memory_noncoh_noncacheable_domain_start_addr[i]) begin 
 //   `uvm_info(get_name(),$psprintf("noncoh_noncacheable_address_region i:%0d start_addr:0x%0h end_addr:0x%0h",i, ncoreConfigInfo::dmi_memory_noncoh_noncacheable_domain_start_addr[i], ncoreConfigInfo::dmi_memory_noncoh_noncacheable_domain_end_addr[i]), UVM_LOW)
 // end 
 // 
 // foreach (ncoreConfigInfo::dmi_memory_noncoh_cacheable_domain_start_addr[i]) begin 
 //   `uvm_info(get_name(),$psprintf("noncoh_cacheable_address_region i:%0d start_addr:0x%0h end_addr:0x%0h",i, ncoreConfigInfo::dmi_memory_noncoh_cacheable_domain_start_addr[i], ncoreConfigInfo::dmi_memory_noncoh_cacheable_domain_end_addr[i]), UVM_LOW)
 // end 
 //   
  //`uvm_error(get_name(),$psprintf("Error to debug"))
endfunction:populate_addrq

function void addr_trans_mgr::populate_atomic_capable_addrq();

  bit [ncoreConfigInfo::ADDR_WIDTH-1:0] addr;
  bit [ncoreConfigInfo::ADDR_WIDTH-1:0] start_addr;
  bit [ncoreConfigInfo::ADDR_WIDTH-1:0] end_addr;
  longint i;
  bit atomics_supported = 0;

  foreach (ncoreConfigInfo::dmiUseAtomic[i]) begin 
    if (ncoreConfigInfo::dmiUseAtomic[i] == 1) begin 
      atomics_supported = 1;
      break;
    end
  end 

  if (atomics_supported == 0) begin 
    `uvm_info("POPULATE_ATOMIC_CAPABLE_ADDRQ", $sformatf("Atomics are not supported in this config"), UVM_LOW)
    return;
  end
  
  ncoreConfigInfo::atomic_addrq.delete();
  foreach(ncoreConfigInfo::memregions_info[region]) begin: _all_memregion_loop_
    start_addr = ncoreConfigInfo::memregions_info[region].start_addr;
    end_addr   = ncoreConfigInfo::memregions_info[region].end_addr;

    if (ncoreConfigInfo::memregions_info[region].hut == ncoreConfigInfo::DMI) begin: _dmi_region_
      //`uvm_info("POPULATE_ATOMIC_CAPABLE_ADDRQ", $sformatf("dmi region:%0d start_addr:0x%0h end_addr:0x%0h",region, start_addr, end_addr), UVM_LOW)
      addr = start_addr;
      i = 0;
      do
      begin
        i++;
        //`uvm_info("POPULATE_ATOMIC_CAPABLE_ADDRQ", $sformatf("addr:0x%0h",addr), UVM_LOW)
        if (allow_atomic_txn_with_addr(addr) == 1) begin 
          ncoreConfigInfo::atomic_addrq.push_back(addr >> 6);
          //`uvm_info("POPULATE_ATOMIC_CAPABLE_ADDRQ", $sformatf("cacheline addr pushed:0x%0h",addr>>6), UVM_LOW)
        end
        addr = addr + (1 << ncoreConfigInfo::WCACHE_OFFSET); //advance by cacheline address
      //end while ((addr < end_addr) && (i<10));
      end while ((addr < end_addr) && (ncoreConfigInfo::atomic_addrq.size() < 100));
      //`uvm_info("POPULATE_ATOMIC_CAPABLE_ADDRQ", $sformatf("addrq size:%0d region:%0d i:%0d", ncoreConfigInfo::atomic_addrq.size(), region, i), UVM_LOW)
    end: _dmi_region_
  end: _all_memregion_loop_

  `uvm_info("POPULATE_ATOMIC_CAPABLE_ADDRQ", $sformatf("atomics addrq size:%d", ncoreConfigInfo::atomic_addrq.size()), UVM_LOW)
  //`uvm_error("POPULATE_ATOMIC_CAPABLE_ADDRQ", $sformatf("Error to debug"))
endfunction: populate_atomic_capable_addrq

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : destruct_instance
// Description : Invoked only for testing purpose
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::destruct_instance();
  m_mgr = null;
endfunction: destruct_instance

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : set_addr_collision_pct
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::set_addr_collision_pct(int funitid, 
                                                     bit en_funitid, 
                                                     int hit_pct);
  m_gen.set_addr_collision_pct(
      ncoreConfigInfo::agentid_assoc2funitid(funitid), hit_pct);
endfunction: set_addr_collision_pct

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : addr_evicted_from_agent
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::addr_evicted_from_agent(int funitid,
                                                      bit en_funitid,
                                                      bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] addr);

  m_gen.addr_evicted_from_agent(funitid, addr);
endfunction: addr_evicted_from_agent

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : rd_static_memory_map
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::rd_static_memory_map();

  m_mem.grps_memregion = new[ncoreConfigInfo::intrlvgrp_if.size()];
  foreach (ncoreConfigInfo::intrlvgrp_if[idx]) begin
    m_mem.nintrlv_type.push_back(ncoreConfigInfo::intrlvgrp_if[idx]);
    m_mem.nintrlv_grps.push_back(ncoreConfigInfo::intrlvgrp2mem_map[idx].size());

    if (ncoreConfigInfo::intrlvgrp_if[idx] == ncoreConfigInfo::DMI)
      m_mem.dmi_grps.push_back(ncoreConfigInfo::intrlvgrp2mem_map[idx].size());
    else
      m_mem.dii_grps.push_back(ncoreConfigInfo::intrlvgrp2mem_map[idx].size());

    foreach (ncoreConfigInfo::intrlvgrp2mem_map[idx][ridx]) begin
      int dii_lidx = 0;

      m_mem.grps_memregion[idx].push_back(
        ncoreConfigInfo::intrlvgrp2mem_map[idx][ridx]);
    end
  end
  
  //Store regions per memory type
  m_mem.pick_regions();

  `uvm_info("ADDR MGR",
     { "\n Ncore Memory Map: { \n", $psprintf("%s", m_mem.convert2string()),
     "\n }"
     }, UVM_NONE)
endfunction: rd_static_memory_map

////
//Methods to request for address or cacheline
////

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_coh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::get_coh_addr(int funitid,
                                                                          bit en_funitid,
                                                                          bit collision_user = 0, 
                                                                          int core_id=0,
                                                                          int set_index= -1,
                                                                          int tfilter_id=-1);

  return m_gen.get_coh_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid), collision_user, core_id, set_index,tfilter_id);
endfunction: get_coh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_coh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::gen_coh_addr(int funitid,
                                                                          bit en_funitid,
                                                                          int target_id    = -1,
                                                                          int memregion_id = -1,
                                                                          int tfilter_id   = -1,
                                                                          int set_index    = -1,
                                                                          int core_id      =  0);

  return m_gen.gen_coh_addr(funitid, target_id, memregion_id, tfilter_id, set_index, core_id);
endfunction: gen_coh_addr

//interface methods to request IO-coherent address

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_iocoh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::get_iocoh_addr(int funitid, 
                                                                            bit en_funitid, 
                                                                            int core_id=0);

  return m_gen.get_iocoh_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid), core_id);
endfunction: get_iocoh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_mem_region_bounds
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::get_mem_region_bounds(int                                    mid,
                                                    output [ncoreConfigInfo::W_SEC_ADDR -1:0] lb,
                                                    output [ncoreConfigInfo::W_SEC_ADDR -1:0] ub);
  m_gen.get_region_bounds(mid, lb, ub);
endfunction : get_mem_region_bounds;
   
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_iocoh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::gen_iocoh_addr(int funitid,
                                                                            bit en_funitid,
                                                                            int memregion_id, 
                                                                            int core_id=0);

  return m_gen.gen_iocoh_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid), memregion_id, core_id);
endfunction: gen_iocoh_addr

<%if (obj.testBench == "fsys" || obj.testBench == "dii") {%>
// This function is quickly build to generate address to particular target (e.g. DII0). Need to verify this function.
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::gen_sel_targ_addr_from_unit_attr(
         string unit_type="DII", /* "DII" OR "DMI" */
         int unit_id=0, /* unit_type=DII : 0,1,2..., unit_type==DMI= 0,1,2...  */ 
         int index=0, /*For multiple mem region configured for any DII or DMI, select one of them.*/
         bit nc=1);
ncoreConfigInfo::sys_addr_csr_t csrq[$];
bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] low_addr;
bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] upp_addr;
int dmi_start_nunitid;
bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] gen_addr;
int low_interleave_bit, high_interleave_bit;

 foreach (m_mem.nintrlv_grps[i]) begin : foreach_m_mem__nintrlv_grp_
     csrq = ncoreConfigInfo::get_memregions_assoc_ig(i);
     foreach (csrq[j]) begin : _foreach_csrq_
     int ig = csrq[j].mig_nunitid;
     int nDmis_per_ig = ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][ig];
	low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
	upp_addr = low_addr + m_mem.nintrlv_grps[i]*(1<<(csrq[j].size+12)) - 1;
	if(csrq[j].unit == ncoreConfigInfo::DMI && unit_type=="DMI") begin : _DMI_
           if (m_mem.nintrlv_grps[i]>1)  begin : _m_mem_nintrlv_grps_more_than_one
               for(int unit=0; unit<m_mem.nintrlv_grps[i]; unit=unit+1) begin
                  `uvm_info(get_name(),$psprintf("gen_gprar_addr_from_region_index_unit_attr:: i %0d j %0d nintrlv_grps[%0d] %0d Unit name %0s Unit Id %0d start_addr 0x%h end_addr 0x%h",i,j,i,m_mem.nintrlv_grps[i],csrq[j].unit.name(),dmi_start_nunitid+unit,low_addr,upp_addr),UVM_LOW)
                   if(unit_id==dmi_start_nunitid+unit && j==index && nc==csrq[j].nc) begin
                       gen_addr = m_gen.rand_addr_bound(low_addr,upp_addr);
                       foreach(ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[m_mem.nintrlv_grps[i]]][m_mem.nintrlv_grps[i]].pri_bits[b]) begin
                           if(b==0) high_interleave_bit = ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[m_mem.nintrlv_grps[i]]][m_mem.nintrlv_grps[i]].pri_bits[b];  //Lower index means Highest
                           low_interleave_bit = ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[m_mem.nintrlv_grps[i]]][m_mem.nintrlv_grps[i]].pri_bits[b];
                       end
                       for(int set_interleave_addr=low_interleave_bit;set_interleave_addr<=high_interleave_bit;set_interleave_addr=set_interleave_addr+1) begin
                           gen_addr[set_interleave_addr] = unit_id[set_interleave_addr];
                       end
                       `uvm_info(get_name(),$psprintf("gen_gprar_addr_from_region_index_unit_attr:: Generated addr 'h%0h as per inputs unit_type %0s unit_id %0d index %0d nc %0d low_interleave_bit %0d high_interleave_bit %0d",gen_addr,unit_type,unit_id,index,nc,low_interleave_bit,high_interleave_bit),UVM_LOW)
                       return gen_addr;
                   end
	       end //for
           end : _m_mem_nintrlv_grps_more_than_one else begin : _m_mem_nintrlv_grps_equal_to_one
               for(int unit=0; unit<m_mem.nintrlv_grps[i]; unit=unit+1) begin
                  `uvm_info(get_name(),$psprintf("gen_gprar_addr_from_region_index_unit_attr:: i %0d j %0d nintrlv_grps[%0d] %0d Unit name %0s Unit Id %0d start_addr 0x%h end_addr 0x%h",i,j,i,m_mem.nintrlv_grps[i],csrq[j].unit.name(),dmi_start_nunitid+unit,low_addr,upp_addr),UVM_LOW)
                   if(unit_id==csrq[j].mig_nunitid && j==index && nc==csrq[j].nc) begin
                       gen_addr = m_gen.rand_addr_bound(low_addr,upp_addr);
                       `uvm_info(get_name(),$psprintf("gen_gprar_addr_from_region_index_unit_attr:: Generated addr 'h%0h as per inputs unit_type %0s unit_id %0d index %0d nc %0d",gen_addr,unit_type,unit_id,index,nc),UVM_LOW)
                       return gen_addr;
                   end
	       end //for
           end : _m_mem_nintrlv_grps_equal_to_one
	end : _DMI_
	else if(csrq[j].unit == ncoreConfigInfo::DII && unit_type=="DII") begin : _DII_
           `uvm_info(get_name(),$psprintf("gen_gprar_addr_from_region_index_unit_attr:: i %0d j %0d Unit name %0s Unit Id %0d start_addr 0x%h end_addr 0x%h",i,j,csrq[j].unit.name(),csrq[j].mig_nunitid,low_addr,upp_addr),UVM_LOW)
           if(unit_id==csrq[j].mig_nunitid && j==index) begin
               gen_addr = m_gen.rand_addr_bound(low_addr,upp_addr);
               `uvm_info(get_name(),$psprintf("gen_gprar_addr_from_region_index_unit_attr:: Generated addr 'h%0h as per inputs unit_type %0s unit_id %0d index %0d nc %0d",gen_addr,unit_type,unit_id,index,nc),UVM_LOW)
               return gen_addr;
           end
        end : _DII_ 
     end : _foreach_csrq_
     if(m_mem.nintrlv_type[i] == ncoreConfigInfo::DMI) begin
        dmi_start_nunitid = dmi_start_nunitid + m_mem.nintrlv_grps[i];
     end
  end : foreach_m_mem__nintrlv_grp_ 
  $stacktrace();
  `uvm_error("gen_gprar_addr_from_region_index_unit_attr::", $psprintf("Couldn't generate target addr. Please check inputs unit_type %0s unit_id %0d index %0d nc %0d",unit_type,unit_id,index,nc))
endfunction: gen_sel_targ_addr_from_unit_attr
<% } %>

//interface methods to request Non-coherent address

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_noncoh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::get_noncoh_addr(int funitid, 
                                                                             bit en_funitid, 
                                                                             int core_id=0);

  return m_gen.get_noncoh_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid), core_id);
endfunction: get_noncoh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_noncoh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::gen_noncoh_addr(int funitid, 
                                                                             bit en_funitid, 
                                                                             int core_id=0);

  return m_gen.gen_noncoh_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid), -1, core_id);
endfunction: gen_noncoh_addr

//interface methods to request Boot region address
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_bootreg_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::get_bootreg_addr(int funitid, 
                                                                              bit en_funitid);

  return m_gen.get_bootreg_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid));
endfunction: get_bootreg_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_bootreg_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::gen_bootreg_addr(int funitid, 
                                                                              bit en_funitid);

  return m_gen.gen_bootreg_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid));
endfunction: gen_bootreg_addr

//interface methods to request NONCOH Boot region address
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_noncohboot_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::get_noncohboot_addr(int funitid, 
                                                                                 bit en_funitid, 
                                                                                 int core_id=0);

  return m_gen.get_noncohboot_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid), core_id);

endfunction: get_noncohboot_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_noncohboot_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::gen_noncohboot_addr(int funitid, 
                                                                                 bit en_funitid, 
                                                                                 int core_id=0);

  return m_gen.gen_noncohboot_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid), core_id);
endfunction: gen_noncohboot_addr

//interface methods to request COH Boot region address
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_cohboot_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::get_cohboot_addr(int funitid, 
                                                                              bit en_funitid, 
                                                                              int core_id=0);

  return m_gen.get_cohboot_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid), core_id);
endfunction: get_cohboot_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_cohboot_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::gen_cohboot_addr(int funitid, 
                                                                              bit en_funitid, 
                                                                              int core_id=0);

  return m_gen.gen_cohboot_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid), core_id);
endfunction: gen_cohboot_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_user_coh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::get_user_coh_addr(int funitid, 
                                                                               int idx);

  return m_gen.get_user_coh_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid), idx);
endfunction: get_user_coh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_user_noncoh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::get_user_noncoh_addr(int funitid, 
                                                                                  int idx);

  return m_gen.get_user_noncoh_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid), idx);
endfunction: get_user_noncoh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_user_coh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::gen_user_coh_addr(int funitid, 
                                                int _size, 
                                                ref ncoreConfigInfo::addrq maddrq);

  m_gen.gen_user_coh_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid), _size, -1, maddrq);
endfunction: gen_user_coh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_user_noncoh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::gen_user_noncoh_addr(int funitid, 
                                                   int _size, 
                                                   ref ncoreConfigInfo::addrq maddrq);

  static time last_time_called;
  static int  count;

  m_gen.gen_user_noncoh_addr(ncoreConfigInfo::agentid_assoc2funitid(funitid), _size, -1, maddrq);
endfunction: gen_user_noncoh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : alter_tag_bits
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::alter_tag_bits(int funitid,
                                                                            bit en_funitid,
                                                                            bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,
                                                                            int tfid = -1);

  int set_index;
  int agentid;

  agentid = ncoreConfigInfo::agentid_assoc2funitid(funitid);
  set_index = m_gen.get_set_index(agentid, addr, tfid);
  return m_gen.gen_coh_addr(agentid, .set_index(set_index));
endfunction: alter_tag_bits

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_set_index
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::get_set_index(int funitid,
                                                                           bit en_funitid,
                                                                           bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,
                                                                           int tfid = -1);
  return m_gen.get_set_index(funitid, addr, tfid);
endfunction: get_set_index

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_addr_target_unit
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit addr_trans_mgr::get_addr_target_unit(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr);

  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] laddr;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] uaddr;
   
  ncoreConfigInfo::sys_addr_csr_t csrq[$];

  // clears security bit
  addr[ncoreConfigInfo::W_SEC_ADDR-1] = 0;
   
  // boot region
  if((addr >= ncoreConfigInfo::BOOT_REGION_BASE) && (addr < (ncoreConfigInfo::BOOT_REGION_BASE+ncoreConfigInfo::BOOT_REGION_SIZE))) begin
     return <%=obj.AiuInfo[0].BootInfo.regionHut%>;
  end

  // mem regions
  foreach (m_mem.nintrlv_grps[grp]) begin
     //csrq = ncoreConfigInfo::get_all_gpra();
     csrq = ncoreConfigInfo::get_memregions_assoc_ig(grp);
     foreach (csrq[i]) begin
        laddr = (csrq[i].low_addr << 12) | (csrq[i].upp_addr << 44);
        uaddr = laddr + m_mem.nintrlv_grps[grp]*(1 << (csrq[i].size + 12));
     
        if((addr >= laddr) && (addr < uaddr)) begin
          return (csrq[i].unit == ncoreConfigInfo::DMI) ? 0 : 1;
        end
     end
  end // foreach (m_mem.intrlv_grps[grp])
endfunction: get_addr_target_unit

function bit addr_trans_mgr::noncoh_addr_region_mapped_to_dmi();

  ncoreConfigInfo::sys_addr_csr_t csrq[$];
  foreach (m_mem.nintrlv_grps[grp]) begin:_each_intrlv_grps // can use m_mem because static
     csrq = ncoreConfigInfo::get_memregions_assoc_ig(grp);
     foreach (csrq[j]) begin:_foreach_mem_region
       if((csrq[j].unit == ncoreConfigInfo::DMI) && csrq[j].nc) begin: _noncoh_dmi_
          return 1;
       end: _noncoh_dmi_
     end: _foreach_mem_region
  end: _each_intrlv_grps
  return 0;
endfunction: noncoh_addr_region_mapped_to_dmi


 function bit addr_trans_mgr::allow_atomic_txn_with_addr(
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr);
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] laddr;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] uaddr;
   
  ncoreConfigInfo::sys_addr_csr_t csrq[$];
  //`uvm_info("ALLOW_ATOMIC_TXN_WITH_ADDR", $sformatf("addr:%0h",addr), UVM_LOW)

  // mem regions
  foreach (m_mem.nintrlv_grps[grp]) begin:_each_intrlv_grps // can use m_mem because static
     csrq = ncoreConfigInfo::get_memregions_assoc_ig(grp);
     foreach (csrq[j]) begin:_foreach_mem_region
        laddr = (csrq[j].low_addr << 12) | (csrq[j].upp_addr << 44);
        uaddr = laddr + m_mem.nintrlv_grps[grp]*(1 << (csrq[j].size + 12));
        //`uvm_info("ALLOW_ATOMIC_TXN_WITH_ADDR", $sformatf("addr:%0h laddr:%0h uaddr:%0h",addr,laddr,uaddr), UVM_MEDIUM)
        if((addr >= laddr) && (addr < uaddr) &&(csrq[j].unit == ncoreConfigInfo::DMI)) begin: _dmi_addr_match
            int dmi_id;
            int ig = csrq[j].mig_nunitid;
            int nDmis_per_ig = ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][ig];
            ncoreConfigInfo::dmisel_bits_t dmi_intrlvsel = ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[nDmis_per_ig]][nDmis_per_ig]; 
            //`uvm_info("ALLOW_ATOMIC_TXN_WITH_ADDR", $sformatf("check_atomic addr:%0h ig:%0d nDmis_per_ig:%0d",addr,ig,nDmis_per_ig), UVM_MEDIUM)
            case(nDmis_per_ig) 
                1: begin
                      for(int i = 0; i < ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs].size(); i++) begin
                         if (i != ig) begin
                            dmi_id += ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][i];
                         end else begin
                            break;
                         end 
                      end
                   end
                2: begin //DMI 2-way interleaving 
                      dmi_id = 0;
                      if (dmi_intrlvsel.pri_bits.size() > 0) begin
                         for(int i=0; i < ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs].size(); i++) begin
                            if (i != ig) begin
                               dmi_id += ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][i];
                            end else begin
                                  dmi_id += addr[dmi_intrlvsel.pri_bits[0]];
                               break;
                            end 
                         end
                      end else begin
                            `uvm_error("NCORE_ALLOW_ATOMIC_TXN", $psprintf("PrimaryBits not defined for 2-way interleaving: PriBits_size:%0d", dmi_intrlvsel.pri_bits.size()))
                       end
                  end
               4: begin//DMI 4 way interleaving
                      dmi_id = 0;
                      if (dmi_intrlvsel.pri_bits.size() > 0) begin
                         for(int i=0; i < ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs].size(); i++) begin
                            if (i != ig) begin
                               dmi_id += ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][i];
                            end else begin
                                  dmi_id += addr[dmi_intrlvsel.pri_bits[1]];
                                  dmi_id += (addr[dmi_intrlvsel.pri_bits[0]]*2);
                               break;
                            end 
                         end
                      end else begin
                            `uvm_error("NCORE_ALLOW_ATOMIC_TXN", $psprintf("PrimaryBits not defined for 4-way interleaving: PriBits_size:%0d", dmi_intrlvsel.pri_bits.size()))
                       end
                     end 
                8: begin//DMI 8 way interleaving
                      dmi_id = 0;
                      if (dmi_intrlvsel.pri_bits.size() > 0) begin
                         for(int i=0; i < ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs].size(); i++) begin
                            if (i != ig) begin
                               dmi_id += ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][i];
                            end else begin
                                  dmi_id += addr[dmi_intrlvsel.pri_bits[2]];
                                  dmi_id += (addr[dmi_intrlvsel.pri_bits[1]]*2);
                                  dmi_id += (addr[dmi_intrlvsel.pri_bits[0]]*4);
                               break;
                            end 
                         end
                      end else begin
                            `uvm_error("NCORE_ALLOW_ATOMIC_TXN", $psprintf("PrimaryBits not defined for 8-way interleaving: PriBits_size:%0d", dmi_intrlvsel.pri_bits.size()))
                      end
                    end
                16: begin//DMI 16 way interleaving
                      dmi_id = 0;
                      if (dmi_intrlvsel.pri_bits.size() > 0) begin
                         for(int i=0; i < ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs].size(); i++) begin
                            if (i != ig) begin
                               dmi_id += ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][i];
                            end else begin
                                  dmi_id += addr[dmi_intrlvsel.pri_bits[3]];
                                  dmi_id += (addr[dmi_intrlvsel.pri_bits[2]]*2);
                                  dmi_id += (addr[dmi_intrlvsel.pri_bits[1]]*4);
                                  dmi_id += (addr[dmi_intrlvsel.pri_bits[0]]*8);
                               break;
                            end 
                         end
                      end else begin
                            `uvm_error("NCORE_ALLOW_ATOMIC_TXN", $psprintf("PrimaryBits not defined for 16-way interleaving: PriBits_size:%0d", dmi_intrlvsel.pri_bits.size()))
                       end
                     end
            endcase 
            //`uvm_info("ALLOW_ATOMIC_TXN_WITH_ADDR", $sformatf("dmi_id:%0d use atomic:%0d",dmi_id,ncoreConfigInfo::dmiUseAtomic[dmi_id]), UVM_MEDIUM)
            return ncoreConfigInfo::dmiUseAtomic[dmi_id];
        end:_dmi_addr_match
     end:_foreach_mem_region
  end:_each_intrlv_grps 
  //`uvm_info("ALLOW_ATOMIC_TXN_WITH_ADDR", $sformatf("use atomic:0"), UVM_LOW)
  return 0;
endfunction: allow_atomic_txn_with_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_dmi_unit_addr_range
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function  addr_trans_mgr::get_dmi_unit_addr_range( output bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] low_addr_dmi0,
                                                   bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] upp_addr_dmi0,
                                                   bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] low_addr_dmi1,
                                                   bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] upp_addr_dmi1);
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] low_addr;
  bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] upp_addr;
  int dmi_start_nunitid = 0;
  ncoreConfigInfo::sys_addr_csr_t csrq[$];

  foreach (m_mem.nintrlv_grps[i]) begin
    csrq = ncoreConfigInfo::get_memregions_assoc_ig(i);
    foreach (csrq[j]) begin
      low_addr = (csrq[j].low_addr<<12) | (csrq[j].upp_addr << 44);
      upp_addr = low_addr + m_mem.nintrlv_grps[i]*(1<<(csrq[j].size+12)) - 1;
      if(csrq[j].unit == ncoreConfigInfo::DMI) begin
        for(int unit=0; unit<m_mem.nintrlv_grps[i]; unit=unit+1) begin
          if((i == 0) && (j == 0)) begin
            low_addr_dmi0 = low_addr;
            upp_addr_dmi0 = upp_addr;
          end else if((i == 0) && (j == 1)) begin     
            low_addr_dmi1 = low_addr;
            upp_addr_dmi1 = upp_addr;
          end
        end // for
      end // if DMI 
    end //foreach csrq
    if(m_mem.nintrlv_type[i] == ncoreConfigInfo::DMI) begin
       dmi_start_nunitid = dmi_start_nunitid + m_mem.nintrlv_grps[i];
    end // if DMI
  end //foreach nintrlv_grps
endfunction: get_dmi_unit_addr_range

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : set_sf_addr_in_user_addrq
// Description : Fill user_addrq with addresses that fall in the range of a particular SnoopFilter
//                specify which DCE unit's SnoopFilter, and how many ways/how many sets to fill
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::set_sf_addr_in_user_addrq(int agentid, 
                                                        int _nSets, 
                                                        int _nWays, 
                                                        ref ncoreConfigInfo::addrq maddrq);

   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_match[$];
   int sf_id;
   bit[31:0] set, way;

   // SnoopFilter id mapped to DCE unit
   sf_id = ncoreConfigInfo::get_snoopfilter_id(agentid);
   
   // loop through nSets
   for(set=0; set<_nSets; set=set+1) begin

      // loop through nWays
      for(way=0; way<_nWays; way=way+1) begin
         do begin
            // 1. get random coh address
            addr = m_gen.gen_coh_addr(agentid);
            addr[5:0] = 6'b000000;  // FIXME - 64B cacheline aligned
   
            `uvm_info("ADDR DBG", $sformatf("set_sf_addr_in_user_addrq 1 - Generated COH addr 0x%0h", addr), UVM_MEDIUM)

            // 2. set address range mapped to dce sel bits (dce_port_sel.pri_bits) to assigned agentid
            foreach (ncoreConfigInfo::dce_port_sel[agentid].pri_bits[i]) begin
               addr[ncoreConfigInfo::dce_port_sel[agentid].pri_bits[i]] = agentid[i];
            end
            `uvm_info("ADDR DBG", $sformatf("set_sf_addr_in_user_addrq 2 - Set dce_sel %0d. addr: 0x%0h", agentid, addr), UVM_MEDIUM)

            // 3. set address range mapped to SnoopFilter primary bits to set#
            foreach (ncoreConfigInfo::sf_set_sel[sf_id].pri_bits[i]) begin
               addr[ncoreConfigInfo::sf_set_sel[sf_id].pri_bits[i]] = set[i];
            end
            `uvm_info("ADDR DBG", $sformatf("set_sf_addr_in_user_addrq 3 - Set set# %0d. addr: 0x%0h", set, addr), UVM_MEDIUM)

            addr_match = maddrq.find(x) with (x == addr);
         end while(addr_match.size() > 0); 

         // 4. add to user_addrq
         `uvm_info("ADDR DBG", $sformatf("set_sf_addr_in_user_addrq 4 - Pushing addr 0x%0h to user_addrq", addr), UVM_MEDIUM)
         maddrq.push_back(addr);
      end // for nWays
   end // for _nSets
endfunction:set_sf_addr_in_user_addrq


////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : alt_bits_in_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_trans_mgr::alt_bits_in_addr(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr, 
                                                                              bit [63:0] alt_bits, 
                                                                              bit [63:0] idx);
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_o = addr;
   `uvm_info("ADDR DBG", $sformatf("alt_bits_in_addr addr:%0h alt_bits:%0h index:%0h", addr, alt_bits, idx), UVM_DEBUG)
   for(int i=0,j=0;alt_bits > 0;i++) begin
      if(alt_bits[0]) begin
          addr_o[i] = idx[j];
          j++;
      end
      alt_bits = alt_bits >>1;
   end
   `uvm_info("ADDR DBG", $sformatf("alt_bits_in_addr out addr:%0h", addr_o), UVM_DEBUG)
   return (addr_o);
endfunction:alt_bits_in_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : alt_bits_in_addr
// Description : This function returns an q of addresses "maddrq" of size-"num_addr" that maps to the 
//                "set_index" of the IOAIU's proxyCache. Very useful to generate transactions to stress 
//                IOAIU's proxyCache
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::get_addrq_w_fix_set_index(int set_index, 
                                                        int agent_id, 
                                                        int core_id = 0, 
                                                        int num_addr, 
                                                        ref ncoreConfigInfo::addrq maddrq,ncoreConfigInfo::mem_type get_coh_noncoh_type,bit usecache);
  int lid, cid, cnt;
  bit xsum;
  ncoreConfigInfo::ncore_unit_type_t utype;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr, inv_addr;
  bit [2:0] unit_unconnected = 'b000;
  bit addr_found = 0;
  bit random_addr=0;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0]temp_idx;
  ncoreConfigInfo::get_logical_uinfo(agent_id, lid, cid, utype);
   //`uvm_info("ADDR MGR DBG", $sformatf("fn:get_addrq_w_fix_set_index - set_index: 0x%0h agent_id:0x%0h core_id:%0d maddrq_size:%0d num_addr:%0d", set_index, agent_id, core_id, maddrq.size(), num_addr), UVM_LOW)
  //`uvm_info("ADDR MGR DBG", $sformatf("fn:get_addrq_w_fix_set_index - pri_bits: %0p", ncoreConfigInfo::cbi_set_sel[lid].pri_bits), UVM_LOW)
  //`uvm_info("ADDR MGR DBG", $sformatf("fn:get_addrq_w_fix_set_index - sec_bits: %0p", ncoreConfigInfo::cbi_set_sel[lid].sec_bits), UVM_LOW) 
  if(get_coh_noncoh_type==ncoreConfigInfo::ANY) random_addr='b1; 
  do begin
    if(random_addr=='b1) std::randomize(get_coh_noncoh_type) with {get_coh_noncoh_type inside {ncoreConfigInfo::NONCOH_DMI,ncoreConfigInfo::NONCOH_DII,ncoreConfigInfo::COH_DMI}; }; 
    if(get_coh_noncoh_type==ncoreConfigInfo::NONCOH_DMI) begin
      addr = gen_noncoh_addr(.funitid(agent_id), .en_funitid(1), .core_id(core_id));
    end else if(get_coh_noncoh_type==ncoreConfigInfo::NONCOH_DII) begin
      addr = get_iocoh_addr(.funitid(agent_id), .en_funitid(1), .core_id(core_id));
    end else if(get_coh_noncoh_type==ncoreConfigInfo::COH_DMI) begin
    addr = gen_coh_addr(.funitid(agent_id), .en_funitid(1), .core_id(core_id));
    end 
    //`uvm_info("ADDR MGR DBG", $sformatf("fn:get_addrq_w_fix_set_index - gen_coh_addr:0x%0h", addr), UVM_LOW)
    addr_found = 0;
    if(usecache) begin
      cnt = 0;
      do begin
        cnt++;
        foreach (ncoreConfigInfo::cbi_set_sel[lid].pri_bits[i]) begin
         temp_idx[i]= addr[ncoreConfigInfo::cbi_set_sel[lid].pri_bits[i]];
         if(ncoreConfigInfo::cbi_set_sel[lid].sec_bits[i].size()>0)begin
         foreach (ncoreConfigInfo::cbi_set_sel[lid].sec_bits[i][j]) begin
          if(j == (ncoreConfigInfo::cbi_set_sel[lid].sec_bits[i].size()-1))begin
             if(temp_idx[i]== set_index[i])begin
                if(addr[ncoreConfigInfo::cbi_set_sel[lid].sec_bits[i][j]] != 1'b0)begin
                 addr[ncoreConfigInfo::cbi_set_sel[lid].pri_bits[i]] = addr[ncoreConfigInfo::cbi_set_sel[lid].pri_bits[i]] ^ 1'b1; 
                end
             end
             else begin
                 if(addr[ncoreConfigInfo::cbi_set_sel[lid].sec_bits[i][j]] != 1'b1)begin
                 addr[ncoreConfigInfo::cbi_set_sel[lid].pri_bits[i]] = addr[ncoreConfigInfo::cbi_set_sel[lid].pri_bits[i]] ^ 1'b1; 
                 end
             end
          end
          temp_idx[i] = temp_idx[i] ^ addr[ncoreConfigInfo::cbi_set_sel[lid].sec_bits[i][j]];
         end 
         end
         else begin
           addr[ncoreConfigInfo::cbi_set_sel[lid].pri_bits[i]] = set_index[i];
         end
        end 
        if (ncoreConfigInfo::get_set_index(addr, agent_id) == set_index) begin
          //`uvm_info("ADDR MGR DBG", $sformatf("fn:get_addrq_w_fix_set_index - addr found after %0d bit-position pri bit altered cnt:%0d", i, cnt), UVM_LOW)
          break;
        end
        
      end while (cnt<100);
       if (cnt >= 100) begin 
          `uvm_error("ADDR MGR DBG", $sformatf("fn:get_addrq_w_fix_set_index - %0d tries to set a correct values at bit position for idx bit", cnt))
        end
      
    end

    //`uvm_info("ADDR MGR DBG", $sformatf("fn:get_addrq_w_fix_set_index - updated_addr:0x%0h set_index:0x%0h good_addr:%0d cnt:%0d", addr, ncoreConfigInfo::get_set_index(addr, agent_id), !ncoreConfigInfo::check_unmapped_add(addr, agent_id, unit_unconnected), cnt), UVM_LOW)
    
    if(!(ncoreConfigInfo::check_unmapped_add(addr, agent_id, unit_unconnected)) && !(addr inside {maddrq}) && ((usecache)?(ncoreConfigInfo::get_set_index(addr, agent_id) == set_index):1) && ((get_coh_noncoh_type==ncoreConfigInfo::COH_DMI && !ncoreConfigInfo::get_addr_gprar_nc(addr) && ncoreConfigInfo::is_dmi_addr(addr)) || (get_coh_noncoh_type==ncoreConfigInfo::NONCOH_DMI && ncoreConfigInfo::get_addr_gprar_nc(addr) && ncoreConfigInfo::is_dmi_addr(addr)) || (get_coh_noncoh_type==ncoreConfigInfo::NONCOH_DII && ncoreConfigInfo::is_dii_addr(addr)) ) ) begin
      maddrq.push_back(addr);
      //`uvm_info("ADDR MGR DBG", $sformatf("fn:get_addrq_w_fix_set_index - addr:0x%0h added to maddrq, size:%0d", addr, maddrq.size()), UVM_LOW)
      <% if (obj.wSecurityAttribute > 0) { %>                                             
        inv_addr = addr;
        inv_addr[ncoreConfigInfo::W_SEC_ADDR -1] = ~addr[ncoreConfigInfo::W_SEC_ADDR -1];
        if (!(inv_addr inside {maddrq}) && maddrq.size() < num_addr) begin
          maddrq.push_back(inv_addr);
       //`uvm_info("ADDR MGR DBG", $sformatf("fn:get_addrq_w_fix_set_index - inv_addr:0x%0h added to maddrq, size:%0d", inv_addr, maddrq.size()), UVM_LOW)
        end
      <% } %>      
    end

  end while (maddrq.size() < num_addr);

endfunction:get_addrq_w_fix_set_index

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : set_dce_sf_fix_index_in_user_addrq
// Description : To make SF evict entry use below function. Idea is to use same SF index pointing 
//                addresses to cover all AIUs we are going to loop through all SF. We will find number 
//                of ways for that SF and generate random address more than that to get random address 
//                we need to find bits that we can alter without changing the DCE_Sel_bit and SF's 
//                pribits for index
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::set_dce_sf_fix_index_in_user_addrq(int agentid, 
                                                                 ref ncoreConfigInfo::addrq maddrq, 
                                                                 output int csrq_idx);

   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_to_push;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_match[$];
   int sf_id;
   bit[63:0] way, _ways;
   bit[63:0] size;
   bit[63:0] alt_bits;
   bit[63:0] alt_bits_temp;
   bit[63:0] alt_bits_shifted;
   int mr_idx=0;
   int dmi_ig_id, intrlved_dmis;
   bit vld_address_found =0 ;      
   ncoreConfigInfo::sys_addr_csr_t csrq[$];
   int ndmi=1;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] laddr;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] uaddr;
  int mem_reg_idx[$];
  bit mem_id_found=0;

   foreach(m_mem.coh_regq[coh_mem_reg]) begin

      //Check if this mem region is connected to the DCE(agentid)
      mem_reg_idx.delete();
      mem_id_found = 0;
     mem_reg_idx = ncoreConfigInfo::memregions_info.find_index(mid) with (mid.start_addr == m_mem.lbound(m_mem.coh_regq[coh_mem_reg])); 
     foreach(ncoreConfigInfo::memregions_info[mem_reg_idx[0]].UnitIds[i]) begin
        mem_id_found = ((mem_id_found ) ||  
          (ncoreConfigInfo::dmi_ids[ncoreConfigInfo::memregions_info[mem_reg_idx[0]].UnitIds[i]] inside
            {ncoreConfigInfo::aiu_dce_connected_dce_dmi_dii_ids[ncoreConfigInfo::dce_ids[agentid]].ConnectedfUnitIds}));
      end
      if (mem_id_found == 0) begin
         continue;
      end

      // Get a random coh address from MemoryRegion (for targetted DCE), we will use address's index based on SF pri_bits
      addr = m_gen.gen_coh_addr(ncoreConfigInfo::dce_ids[agentid],-1,m_mem.coh_regq[coh_mem_reg]);
      addr[5:0] = 6'b000000;  // FIXME - 64B cacheline aligned 
      `uvm_info("ADDR DBG", $sformatf("set_dce_sf_fix_index_in_user_addrq 1 - Generated COH addr 0x%0h mid:%0d cohreg:%0d/%0d", addr, m_mem.coh_regq[coh_mem_reg], coh_mem_reg, m_mem.coh_regq.size()), UVM_LOW)

      // Find the MemoryRegion and it's region size, those many bits we can alter to generate new address with same SF indices
      foreach(ncoreConfigInfo::memregion_boundaries[i]) begin
         if(addr[ncoreConfigInfo::ADDR_WIDTH -1:0] inside {[ncoreConfigInfo::memregion_boundaries[i].start_addr:ncoreConfigInfo::memregion_boundaries[i].end_addr]}) begin
            mr_idx=i;
            size = ncoreConfigInfo::memregion_boundaries[i].end_addr - ncoreConfigInfo::memregion_boundaries[i].start_addr;
            alt_bits = size -1 ;
            alt_bits[5:0] = 6'b0; //remove the last 6 bits as they will point to same cacheline
            `uvm_info("ADDR DBG", $sformatf("set_dce_sf_fix_index_in_user_addrq 2 - Generated COH addr 0x%0h in mid:%0d {0x%0h,0x%0h} size:%0h alt_bits:0x%0h", addr,i,ncoreConfigInfo::memregion_boundaries[i].start_addr,ncoreConfigInfo::memregion_boundaries[i].end_addr-1,size,alt_bits), UVM_LOW)
            break;
         end
      end

      // Mask out DCE sel_bits, as we don't want to change the targetted DCE
      foreach (ncoreConfigInfo::dce_port_sel[agentid].pri_bits[i]) begin
         addr[ncoreConfigInfo::dce_port_sel[agentid].pri_bits[i]] = agentid[i];
         `uvm_info("ADDR DBG", $sformatf("set_dce_sf_fix_index_in_user_addrq 3 i:%0d bit:%0d - Set dce_sel %0d. addr[bit]: 0x%0h",i, ncoreConfigInfo::dce_port_sel[agentid].pri_bits[i], agentid, addr[ncoreConfigInfo::dce_port_sel[agentid].pri_bits[i]]), UVM_LOW)
         alt_bits[ncoreConfigInfo::dce_port_sel[agentid].pri_bits[i]] = 1'b0;
      end
      `uvm_info("ADDR DBG", $sformatf("set_dce_sf_fix_index_in_user_addrq 3 - after dce_sel alt_bits:0x%0h addr:%0h", alt_bits, addr), UVM_LOW)
      if(addr[ncoreConfigInfo::ADDR_WIDTH -1:0] inside {[ncoreConfigInfo::memregion_boundaries[mr_idx].start_addr:ncoreConfigInfo::memregion_boundaries[mr_idx].end_addr]}) vld_address_found = 1;

      // loop for all Snoop Filters
      for(sf_id=0; sf_id<ncoreConfigInfo::snoop_filters_info.size(); sf_id++) begin
         alt_bits_temp = alt_bits;
         `uvm_info("ADDR DBG", $sformatf("set_dce_sf_fix_index_in_user_addrq Generating addresses for SnoopFilter :%0d with ref address :0x%0h", sf_id, addr), UVM_LOW)
         
         foreach (ncoreConfigInfo::sf_set_sel[sf_id].pri_bits[i]) begin
            alt_bits_temp[ncoreConfigInfo::sf_set_sel[sf_id].pri_bits[i]] = 1'b0; // Mask out SF pri_bits, as we want to keep the index unaltered
         end
         `uvm_info("ADDR DBG", $sformatf("set_dce_sf_fix_index_in_user_addrq 4 - after sf%0d pri_bit alt_bits:0x%0h", sf_id, alt_bits_temp), UVM_LOW)
   
         alt_bits_shifted  = (1<<$countones(alt_bits_temp));
         if(alt_bits_shifted <= (ncoreConfigInfo::snoop_filters_info[sf_id].num_ways + ncoreConfigInfo::snoop_filters_info[sf_id].victim_entries)) begin
            `uvm_info("ADDR DBG", $sformatf("set_dce_sf_fix_index_in_user_addrq 5 - SF%0d num_ways:%0d + num_vb_entries:%0d is less than alt_bits:0x%0h (1's %0d)", sf_id, ncoreConfigInfo::snoop_filters_info[sf_id].num_ways, ncoreConfigInfo::snoop_filters_info[sf_id].victim_entries, alt_bits_temp, $countones(alt_bits_temp)), UVM_LOW)
            vld_address_found = 0;
         end else begin
            `uvm_info("ADDR DBG", $sformatf("set_dce_sf_fix_index_in_user_addrq 5 - SF%0d num_ways:%0d num_vb_entries:%0d alt_bits:0x%0h (1's %0d)", sf_id, ncoreConfigInfo::snoop_filters_info[sf_id].num_ways, ncoreConfigInfo::snoop_filters_info[sf_id].victim_entries, alt_bits_temp, $countones(alt_bits_temp)), UVM_LOW)
            vld_address_found &= 1;
         end
      end
      if(vld_address_found) begin 
         //To get csr queue index for GPR register
         csrq = ncoreConfigInfo::get_all_gpra();
         foreach (csrq[i]) begin
             if (csrq[i].unit == ncoreConfigInfo::DMI) begin
               ndmi = ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][csrq[i].mig_nunitid];
             end
             laddr = ({csrq[i].upp_addr,csrq[i].low_addr} << 12);
             uaddr = laddr + ndmi * (1 << (csrq[i].size + 12));
             if (laddr == ncoreConfigInfo::memregion_boundaries[mr_idx].start_addr && uaddr == ncoreConfigInfo::memregion_boundaries[mr_idx].end_addr) begin
               csrq_idx = i;
               `uvm_info(get_full_name(),$sformatf("laddr = 0x%0x, uaddr = 0x%0x",laddr,uaddr),UVM_LOW)
               `uvm_info(get_full_name(),$sformatf("csrq_idx = %0d",csrq_idx),UVM_LOW)
             end
             ndmi = 1;
         end
         break;
      end
   end
   <%if(obj.testBench === "dce" && obj.initiatorGroups.length > 1){ %>
      // - This gives the IG of DMI = [ncoreConfigInfo::dmi_intrlvgrp[ncoreConfigInfo::picked_dmi_igs][agentid]]
      dmi_ig_id = ncoreConfigInfo::dmi_intrlvgrp[ncoreConfigInfo::picked_dmi_igs]['h20] ;
      // - In that IG how many interleaved DMIs are there, that will be used to find the DMI sel bits
      intrlved_dmis = ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][dmi_ig_id];

      foreach (ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i]) begin
         alt_bits[ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i]] = 1'b0;
      end
   <%}%>   

   // loop for all Snoop Filters
   for(sf_id=0; sf_id<ncoreConfigInfo::snoop_filters_info.size(); sf_id++) begin
      alt_bits_temp = alt_bits;
      `uvm_info("ADDR DBG", $sformatf("set_dce_sf_fix_index_in_user_addrq 6 Generating addresses for SnoopFilter :%0d with ref address :0x%0h", sf_id, addr), UVM_LOW)
      
      foreach (ncoreConfigInfo::sf_set_sel[sf_id].pri_bits[i]) begin
         alt_bits_temp[ncoreConfigInfo::sf_set_sel[sf_id].pri_bits[i]] = 1'b0; // Mask out SF pri_bits, as we want to keep the index unaltered
      end
            `uvm_info("ADDR DBG", $sformatf("set_dce_sf_fix_index_in_user_addrq 7 - after sf%0d pri_bit alt_bits:0x%0h", sf_id, alt_bits_temp), UVM_LOW)

      alt_bits_shifted  = (1<<$countones(alt_bits_temp));
      if(alt_bits_shifted <= (ncoreConfigInfo::snoop_filters_info[sf_id].num_ways + ncoreConfigInfo::snoop_filters_info[sf_id].victim_entries)) begin
         `uvm_error("ADDR DBG", $sformatf("set_dce_sf_fix_index_in_user_addrq 8 - SF%0d num_ways:%0d + num_vb_entries:%0d is less than alt_bits:0x%0h (1's %0d)", sf_id, ncoreConfigInfo::snoop_filters_info[sf_id].num_ways, ncoreConfigInfo::snoop_filters_info[sf_id].victim_entries, alt_bits_temp, $countones(alt_bits_temp)))
      end else begin
         `uvm_info("ADDR DBG", $sformatf("set_dce_sf_fix_index_in_user_addrq 8 - SF%0d num_ways:%0d num_vb_entries:%0d alt_bits:0x%0h (1's %0d)", sf_id, ncoreConfigInfo::snoop_filters_info[sf_id].num_ways, ncoreConfigInfo::snoop_filters_info[sf_id].victim_entries, alt_bits_temp, $countones(alt_bits_temp)), UVM_LOW)
      end

      _ways = (alt_bits_shifted<(2*(ncoreConfigInfo::snoop_filters_info[sf_id].num_ways + ncoreConfigInfo::snoop_filters_info[sf_id].victim_entries))) ? (alt_bits_shifted) : (2*(ncoreConfigInfo::snoop_filters_info[sf_id].num_ways + ncoreConfigInfo::snoop_filters_info[sf_id].victim_entries));// Create enough addresses
      // loop through nWays
      for(way=0; way<_ways; way=way+1) begin
          addr_to_push = alt_bits_in_addr(addr, alt_bits_temp,way);
          addr_match = maddrq.find(x) with (x == addr_to_push);
          if(addr_match.size() == 0) begin // add to user_addrq
             `uvm_info("ADDR DBG", $sformatf("set_dce_sf_fix_index_in_user_addrq 9 - Pushing addr 0x%0h to user_addrq", addr_to_push), UVM_LOW)
             maddrq.push_back(addr_to_push);
          end
      end 
   end
endfunction:set_dce_sf_fix_index_in_user_addrq

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : set_dmi_smc_fix_index_in_user_addrq
// Description : To make SMC evict entry use below function. Idea is to use same SMC index pointing 
//                addresses. We will find number of ways for that SMC and generate random address more 
//                than that, to get random address we need to find bits that we can alter without 
//                changing the DMI_Sel_bit and SMC's pribits for index.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::set_dmi_smc_fix_index_in_user_addrq(int agentid, 
                                                                  ref ncoreConfigInfo::addrq maddrq,
                                                                  input bit c_nc);

   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_to_push;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_match[$];
   int dmi_ig_id, intrlved_dmis;
   bit[63:0] way, _ways;
   bit[63:0] size;
   bit[63:0] alt_bits;
   bit[63:0] alt_bits_shifted;
   int mr_idx=0;
   bit vld_address_found =0 ;      
  int mem_reg_idx[$];
  bit mem_id_found=0;

   `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 0 - agentid: %0d, c_nc: %0d", agentid, c_nc), UVM_LOW)
if(c_nc) begin
      `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq  - Generating COH addr.  cohreg size:%0d", m_mem.coh_regq.size()), UVM_LOW)
   foreach(m_mem.coh_regq[coh_mem_reg]) begin

     //Check if this mem region is connected to the DMI(agentid)
     mem_reg_idx.delete();
     mem_id_found = 0;
     mem_reg_idx = ncoreConfigInfo::memregions_info.find_index(mid) with (mid.start_addr == m_mem.lbound(m_mem.coh_regq[coh_mem_reg])); 
     foreach(ncoreConfigInfo::memregions_info[mem_reg_idx[0]].UnitIds[i]) begin
        if (ncoreConfigInfo::memregions_info[mem_reg_idx[0]].UnitIds[i] == agentid) begin
           mem_id_found = 1; 
        end
     end
     if (mem_id_found == 0) begin
         if (coh_mem_reg == m_mem.coh_regq.size()-1) begin
            `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq  - Failed to generate COH addr, no memory mapped as COH"), UVM_NONE)
            return;
         end else begin
            continue;
         end
     end

      // Get a random coh address from MemoryRegion (for targetted DMI), we will use address's index based on SF pri_bits
      addr = m_gen.gen_coh_addr(ncoreConfigInfo::dmi_ids[agentid],-1,m_mem.coh_regq[coh_mem_reg]);
      addr[5:0] = 6'b000000;  // FIXME - 64B cacheline aligned 
      `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 1 - Generated COH addr 0x%0h mid:%0d cohreg:%0d/%0d", addr, m_mem.coh_regq[coh_mem_reg], coh_mem_reg, m_mem.coh_regq.size()), UVM_LOW)

      // Find the MemoryRegion and it's region size, those many bits we can alter to generate new address with same SF indices
      foreach(ncoreConfigInfo::memregion_boundaries[i]) begin
         if(addr[ncoreConfigInfo::ADDR_WIDTH -1:0] inside {[ncoreConfigInfo::memregion_boundaries[i].start_addr:ncoreConfigInfo::memregion_boundaries[i].end_addr]}) begin
            mr_idx=i;
            size = ncoreConfigInfo::memregion_boundaries[i].end_addr - ncoreConfigInfo::memregion_boundaries[i].start_addr;
            alt_bits = size -1 ;
            alt_bits[5:0] = 6'b0; //remove the last 6 bits as they will point to same cacheline
            `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 2 - Generated COH addr 0x%0h in mid:%0d {0x%0h,0x%0h} size:%0h alt_bits:0x%0h", addr,i,ncoreConfigInfo::memregion_boundaries[i].start_addr,ncoreConfigInfo::memregion_boundaries[i].end_addr-1,size,alt_bits), UVM_LOW)
            break;
         end
      end

      // Mask out DMI sel_bits, as we don't want to change the targetted DMI

      // - This gives the IG of DMI = [ncoreConfigInfo::dmi_intrlvgrp[ncoreConfigInfo::picked_dmi_igs][agentid]]
      dmi_ig_id = ncoreConfigInfo::dmi_intrlvgrp[ncoreConfigInfo::picked_dmi_igs][agentid] ;
      // - In that IG how many interleaved DMIs are there, that will be used to find the DMI sel bits
      intrlved_dmis = ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][dmi_ig_id];
      // - use the DMI sel bits ans mask them
      foreach (ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i]) begin
         addr[ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i]] = agentid[i];
         `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 3 i:%0d bit:%0d - Set dmi_sel %0d. addr[bit]: 0x%0h",i, ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i], agentid, addr[ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i]]), UVM_LOW)
         alt_bits[ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i]] = 1'b0;
      end
      `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 3 - after dmi_sel alt_bits:0x%0h addr:%0h", alt_bits, addr), UVM_LOW)
      if(addr[ncoreConfigInfo::ADDR_WIDTH -1:0] inside {[ncoreConfigInfo::memregion_boundaries[mr_idx].start_addr:ncoreConfigInfo::memregion_boundaries[mr_idx].end_addr]}) vld_address_found = 1;

      // find the pri bits and mask out in alt_bits
      foreach (ncoreConfigInfo::cmc_set_sel[agentid].pri_bits[i]) begin
         alt_bits[ncoreConfigInfo::cmc_set_sel[agentid].pri_bits[i]] = 1'b0; // Mask out SMC pri_bits, as we want to keep the index unaltered
      end
      `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 4 - after dmi%0d pri_bit alt_bits:0x%0h", agentid, alt_bits), UVM_LOW)
   
      if((1<<$countones(alt_bits)) <= ncoreConfigInfo::dmi_CmcWays[agentid]) begin
         `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 5 - DMI%0d num_ways:%0d is less than alt_bits:0x%0h (1's %0d)", agentid, ncoreConfigInfo::dmi_CmcWays[agentid], alt_bits, $countones(alt_bits)), UVM_LOW)
         vld_address_found = 0;
      end else begin
         `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 5 - DMI%0d num_ways:%0d alt_bits:0x%0h (1's %0d)", agentid, ncoreConfigInfo::dmi_CmcWays[agentid], alt_bits, $countones(alt_bits)), UVM_LOW)
         vld_address_found &= 1;
      end

      if(vld_address_found) break;
   end // foreach
end else begin
      `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq  - Generating NONCOH addr.  noncohreg size:%0d", m_mem.noncoh_regq.size()), UVM_LOW)
   foreach(m_mem.noncoh_regq[noncoh_mem_reg]) begin

     //Check if this mem region is connected to the DMI(agentid)
     mem_reg_idx.delete();
     mem_id_found = 0;
     mem_reg_idx = ncoreConfigInfo::memregions_info.find_index(mid) with (mid.start_addr == m_mem.lbound(m_mem.noncoh_regq[noncoh_mem_reg])); 
     foreach(ncoreConfigInfo::memregions_info[mem_reg_idx[0]].UnitIds[i]) begin
        if (ncoreConfigInfo::memregions_info[mem_reg_idx[0]].UnitIds[i] == agentid) begin
           mem_id_found = 1; 
        end
     end
     if (mem_id_found == 0) begin
         if (noncoh_mem_reg == m_mem.noncoh_regq.size()-1) begin
            `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq  - Failed to generate NONCOH addr, no memory mapped as NONCOH"), UVM_NONE)
            return;
         end else begin
            continue;
         end
     end
  
      // Get a random coh address from MemoryRegion (for targetted DMI), we will use address's index based on SF pri_bits
      addr = m_gen.gen_noncoh_addr(ncoreConfigInfo::dmi_ids[agentid],m_mem.noncoh_regq[noncoh_mem_reg]);
      addr[5:0] = 6'b000000;  // FIXME - 64B cacheline aligned 
      `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 1 - Generated NONCOH addr 0x%0h mid:%0d noncohreg:%0d/%0d", addr, m_mem.noncoh_regq[noncoh_mem_reg], noncoh_mem_reg, m_mem.noncoh_regq.size()), UVM_LOW)

      // Find the MemoryRegion and it's region size, those many bits we can alter to generate new address with same SF indices
      foreach(ncoreConfigInfo::memregion_boundaries[i]) begin
         if(addr[ncoreConfigInfo::ADDR_WIDTH -1:0] inside {[ncoreConfigInfo::memregion_boundaries[i].start_addr:ncoreConfigInfo::memregion_boundaries[i].end_addr]}) begin
            mr_idx=i;
            size = ncoreConfigInfo::memregion_boundaries[i].end_addr - ncoreConfigInfo::memregion_boundaries[i].start_addr;
            alt_bits = size -1 ;
            alt_bits[5:0] = 6'b0; //remove the last 6 bits as they will point to same cacheline
            `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 2 - Generated NONCOH addr 0x%0h in mid:%0d {0x%0h,0x%0h} size:%0h alt_bits:0x%0h", addr,i,ncoreConfigInfo::memregion_boundaries[i].start_addr,ncoreConfigInfo::memregion_boundaries[i].end_addr-1,size,alt_bits), UVM_LOW)
            break;
         end
      end

      // Mask out DMI sel_bits, as we don't want to change the targetted DMI

      // - This gives the IG of DMI = [ncoreConfigInfo::dmi_intrlvgrp[ncoreConfigInfo::picked_dmi_igs][agentid]]
      dmi_ig_id = ncoreConfigInfo::dmi_intrlvgrp[ncoreConfigInfo::picked_dmi_igs][agentid] ;
      // - In that IG how many interleaved DMIs are there, that will be used to find the DMI sel bits
      intrlved_dmis = ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][dmi_ig_id];
      // - use the DMI sel bits ans mask them
      foreach (ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i]) begin
         addr[ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i]] = agentid[i];
         `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 3 i:%0d bit:%0d - Set dmi_sel %0d. addr[bit]: 0x%0h",i, ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i], agentid&1, addr[ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i]]), UVM_LOW)
         alt_bits[ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i]] = 1'b0;
      end
      `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 3 - after dmi_sel alt_bits:0x%0h addr:%0h", alt_bits, addr), UVM_LOW)
      if(addr[ncoreConfigInfo::ADDR_WIDTH -1:0] inside {[ncoreConfigInfo::memregion_boundaries[mr_idx].start_addr:ncoreConfigInfo::memregion_boundaries[mr_idx].end_addr]}) vld_address_found = 1;

      // find the pri bits and mask out in alt_bits
      foreach (ncoreConfigInfo::cmc_set_sel[agentid].pri_bits[i]) begin
         alt_bits[ncoreConfigInfo::cmc_set_sel[agentid].pri_bits[i]] = 1'b0; // Mask out SMC pri_bits, as we want to keep the index unaltered
      end
      `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 4 - after dmi%0d pri_bit alt_bits:0x%0h", agentid, alt_bits), UVM_LOW)
   
      if((1<<$countones(alt_bits)) <= ncoreConfigInfo::dmi_CmcWays[agentid]) begin
         `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 5 - DMI%0d num_ways:%0d is less than alt_bits:0x%0h (1's %0d)", agentid, ncoreConfigInfo::dmi_CmcWays[agentid], alt_bits, $countones(alt_bits)), UVM_LOW)
         vld_address_found = 0;
      end else begin
         `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 5 - DMI%0d num_ways:%0d alt_bits:0x%0h (1's %0d)", agentid, ncoreConfigInfo::dmi_CmcWays[agentid], alt_bits, $countones(alt_bits)), UVM_LOW)
         vld_address_found &= 1;
      end

      if(vld_address_found) break;
   end // foreach
end

      alt_bits_shifted  = (1<<$countones(alt_bits));
      if((alt_bits_shifted <= ncoreConfigInfo::dmi_CmcWays[agentid]) && (!($countones(alt_bits)==31 && ncoreConfigInfo::dmi_CmcWays[agentid]== 0))) begin
      `uvm_error("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 6 - DMI%0d num_ways:%0d is greater than alt_bits:0x%0h (1's %0d)", agentid, ncoreConfigInfo::dmi_CmcWays[agentid], alt_bits, $countones(alt_bits)))
   end else begin
      `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 6 - DMI%0d num_ways:%0d alt_bits:0x%0h (1's %0d)", agentid, ncoreConfigInfo::dmi_CmcWays[agentid], alt_bits, $countones(alt_bits)), UVM_LOW)
   end

   _ways = (alt_bits_shifted<(2*ncoreConfigInfo::dmi_CmcWays[agentid])) ? (1<<$countones(alt_bits)) :
           ( ((alt_bits_shifted)<(4*ncoreConfigInfo::dmi_CmcWays[agentid])) ? (2*ncoreConfigInfo::dmi_CmcWays[agentid]) : (4*ncoreConfigInfo::dmi_CmcWays[agentid]));// Create enough addresses
   // loop through nWays
   for(way=0; way<_ways; way=way+1) begin
       addr_to_push = alt_bits_in_addr(addr, alt_bits, way);
       addr_match = maddrq.find(x) with (x == addr_to_push);
       if(addr_match.size() == 0) begin // add to user_addrq
          `uvm_info("ADDR DBG", $sformatf("set_dmi_smc_fix_index_in_user_addrq 7 - Pushing addr 0x%0h to user_addrq", addr_to_push), UVM_LOW)
          maddrq.push_back(addr_to_push);
       end
   end 
endfunction:set_dmi_smc_fix_index_in_user_addrq

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_noncoh_addr_in_user_addrq
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::gen_noncoh_addr_in_user_addrq(int num_addr, 
                                                            ref ncoreConfigInfo::addrq maddrq);

   int mid;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
   
   // pick random non_coh memory region
   mid  = m_mem.get_rand_memregion(ncoreConfigInfo::NONCOH);
   `uvm_info("ADDR DBG", $sformatf("gen_noncoh_addr_in_user_addrq - Picked NonCoh memregion %0d ", mid), UVM_NONE)
   for(int i=0; i<num_addr; i=i+1) begin
      // pick random address inside memory region
      addr = m_gen.get_rand_c_nc_addr(mid, 0);
      if($test$plusargs("perf_test"))     addr[7:0] = 8'h00;  // 256B aligned address for performance sim
      else                                addr = m_gen.rand_crit_wrd(addr);
      `uvm_info("ADDR DBG", $sformatf("gen_noncoh_addr_in_user_addrq - Picked addr[%0d]: 0x%0h",i, addr), UVM_NONE)
   
       maddrq.push_back(addr);
   end
endfunction: gen_noncoh_addr_in_user_addrq

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_seq_addr_in_user_addrq
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::gen_seq_addr_in_user_addrq(int num_addr, 
                                                         int addr_step, 
                                                         int intrlv_grp, 
                                                         int dmi_idx, 
                                                         ref ncoreConfigInfo::addrq maddrq, 
                                                         input bit ioaiu_pick_random = 0, 
                                                         input bit ioaiu_coherent = 0, 
                                                         input int nbr_alternate[0:1]='{0,0}, 
                                                         input int size_alternate[0:1]='{0,0});

  int mid[0:1]; // 2 values in case alternate on 2 mem regions
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr[0:1]; // 2 addr in case alternate on 2 mem regions
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_base; 
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_mask; 
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_incr; 
  
  int                   nbr_addr_memreg[0:1];
  int                   pick_itr;
  int                   region_size = num_addr * addr_step;
  int                   shift_bits = $clog2(addr_step);
  int                   intrlved_dmis;

  int unaligned_offset;
  bit unaligned_addr_gen;

  // new perf test 
  bit ioaiu_seq_case = 1'b0;
  ncoreConfigInfo::intq coh_regionsq;
  ncoreConfigInfo::intq noncoh_regionsq;
  ncoreConfigInfo::intq iocoh_regionsq;
  coh_regionsq = m_gen.m_map.get_coh_mem_regions();
  noncoh_regionsq = m_gen.m_map.get_noncoh_mem_regions();
  iocoh_regionsq = m_gen.m_map.get_iocoh_mem_regions();

  // rofurtado: new perf test to allow the exact memory address allocation
  //  replace one line: pick_itr = $urandom_range(m_gen.m_map.grps_memregion[intrlv_grp].size()-1, 0);
  //  by the section below until "end newperf test"
  if ($test$plusargs("seq_case")) begin // if seq_case => always the same memory section
       mid[0] = coh_regionsq[0]; // take always the first coherent memory regions
  end else begin 
  // pick random memory region in interleave group
      pick_itr = $urandom_range(m_gen.m_map.grps_memregion[intrlv_grp].size()-1, 0);
      `uvm_info("ADDR DBG", $sformatf("gen_seq_addr_in_user_addrq - Picked memregion %0d of interleave_group %0d", pick_itr, intrlv_grp), UVM_MEDIUM)
      mid[0]  = m_gen.m_map.grps_memregion[intrlv_grp][pick_itr];
  end

  //TODO:::  MUST REMOVE the tips: intrlv_grp > 100 when perf_test

  // pick user defined memory region in interleave group 
  if (intrlv_grp >= 100) begin //  intrlv_grp > 100 in case of newperf test 
      mid[0] = noncoh_regionsq[intrlv_grp%100]; // take always one noncoherent memory regions per IO in case of seq case
      ioaiu_seq_case = 1'b1;
      intrlv_grp = 0;
  end
  
  if (ioaiu_pick_random) begin  // in case IOAIU random: pick random memory region in interleave group
    pick_itr = $urandom_range(m_gen.m_map.grps_memregion[intrlv_grp].size()-1, 0);
  `uvm_info("ADDR DBG", $sformatf("gen_seq_addr_in_user_addrq - Picked memregion %0d of interleave_group %0d", pick_itr, intrlv_grp), UVM_MEDIUM)
    mid[0]  = m_gen.m_map.grps_memregion[intrlv_grp][pick_itr];
  end 
  if (ioaiu_coherent) begin  // pick 1st memory region in interleave group
    mid[0] = coh_regionsq[0]; // take always the first coherent memory regions same as CHI
  end
  
  if ($test$plusargs("use_dii_intrlv_grp")) begin // if seq_case => always the same memory section
      mid[0] = iocoh_regionsq[intrlv_grp%100]; // take always one IO noncoherent memory regions per IO in case of seq case
      mid[1] = iocoh_regionsq[(intrlv_grp%100)+1]; // case alternate between 2 specific mem region !!! use ioaiux_addr_idx_offset if you enable 2 IO to avoid read or write in same address!!!
  end 
  // end newperf test

  // pick random address inside memory region or when nonoherent the addresses do not overlap
  addr[0] = ($test$plusargs("seq_case") ||( !ioaiu_pick_random && ioaiu_seq_case)) ?  
                                                m_gen.m_map.lbound(mid[0]) : m_gen.get_rand_c_nc_addr(mid[0], 1);
  // addr[1] use only in alternate case
  addr[1] = ($test$plusargs("seq_case") ||( !ioaiu_pick_random && ioaiu_seq_case)) ?  
                                                m_gen.m_map.lbound(mid[1]) : m_gen.get_rand_c_nc_addr(mid[1], 1);
   
  //addr[0] = m_gen.get_rand_c_nc_addr(mid, 1);

    if($test$plusargs("perf_unaligned_txn")) begin
      if(!($value$plusargs("perf_unaligned_txn=%d",unaligned_offset))) begin
        unaligned_offset=32;
      end
      unaligned_addr_gen = 1;
      addr[0][5:0] = unaligned_offset;
    end

  //if($test$plusargs("perf_test")) begin
  if (addr_step == 256 && !unaligned_addr_gen) begin
     addr[0][7:0] = 8'h00;  // 256B aligned address for performance sim
  end else  if (addr_step == 128 && !unaligned_addr_gen) begin
     addr[0][6:0] = 7'h00;  // 128B aligned address for performance sim
  end else  if (addr_step == 64 && !unaligned_addr_gen) begin
     addr[0][5:0] = 6'h00;  // 64B aligned address for performance sim
  end
  else begin
    int unaligned_offset;
    if($test$plusargs("perf_unaligned_txn")) begin
      if(!($value$plusargs("perf_unaligned_txn=%d",unaligned_offset))) begin
        unaligned_offset=32;
      end
      addr[0][5:0] = unaligned_offset;
    end else begin
      addr[0] = m_gen.rand_crit_wrd(addr[0]);
    end
  end

  addr_base = 0;
  addr_mask = 0;

  if(dmi_idx != -1) begin
    // how many interleaved DMIs are there, that will be used to find the DMI sel bits
    intrlved_dmis = ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][intrlv_grp];
    `uvm_info("ADDR DBG", $sformatf("gen_seq_addr_in_user_addrq - dmi_idx: %0d, num_intrlv_dmis=%0d", dmi_idx, intrlved_dmis), UVM_MEDIUM)

    // - use the DMI sel bits ans mask them
    for(int i=0; i<$size(ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits); i=i+1) begin
      addr[0][ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i]] = dmi_idx&1;
      addr_base[ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i]] = dmi_idx&1;
      addr_mask[ncoreConfigInfo::dmi_sel_bits[ncoreConfigInfo::picked_dmi_if[intrlved_dmis]][intrlved_dmis].pri_bits[i]] = 1;
      dmi_idx=dmi_idx>>1; 
      `uvm_info("ADDR DBG", $sformatf("gen_seq_addr_in_user_addrq - addr[0]=0x%0h , addr_base=0x%0h , addr_mask=0x%0h ,dmi_idx: %0d, num_intrlv_dmis=%0d", addr[0], addr_base, addr_mask, dmi_idx, intrlved_dmis), UVM_MEDIUM)
    end     
  end

  `uvm_info("ADDR DBG", $sformatf("gen_seq_addr_in_user_addrq - Picked addr[0]: 0x%0h", addr[0]), UVM_MEDIUM)
  `uvm_info("ADDR DBG", $sformatf("gen_seq_addr_in_user_addrq - Picked addr[1]: 0x%0h", addr[1]), UVM_MEDIUM)
   
  for(int i=0; i<num_addr; i=i+1) begin
    if (nbr_alternate[0]==0) begin:classic_case
      maddrq.push_back(addr[0]);

      addr[0] = addr[0] + addr_step;
      addr_incr = addr[0] + addr_step;

      if (addr_incr[12] != addr[0][12] ) begin 
        `uvm_info("ADDR DBG", $sformatf("Due to 4k boundary cross possibility, skipping addr[0]=0x%0h", addr[0]), UVM_NONE)
        addr[0] = addr[0] + addr_step;
      end

        //set correctly interleaving bits and address if targeting a specific DMI
      if(dmi_idx != -1) begin
        while ((addr[0]&addr_mask) != addr_base) begin
          `uvm_info("ADDR DBG", $sformatf("skipping addr[0]=0x%0h", addr[0]), UVM_NONE)
          addr[0] = addr[0] + addr_step;
        end ;
      end
      `uvm_info("ADDR DBG", $sformatf("gen_seq_addr_in_user_addrq - addr[0]=0x%0h , dmi_idx: %0d, num_intrlv_dmis=%0d", addr[0], dmi_idx, intrlved_dmis), UVM_NONE)
    end:classic_case else begin:alternate_case_between_2memregion //newperf_test pcie case alternate on noncoh mem region
      int window_memreg[0:1];
      if (nbr_addr_memreg[0] == nbr_alternate[0]  && nbr_addr_memreg[1] == nbr_alternate[1] ) begin
        nbr_addr_memreg= '{0,0};
      end
      window_memreg[0] = (nbr_addr_memreg[0] < nbr_alternate[0]);
      window_memreg[1] = (nbr_addr_memreg[1] <  nbr_alternate[1])  && (nbr_addr_memreg[0] == nbr_alternate[0]); 
      if (window_memreg[0]) begin  
         maddrq.push_back(addr[0]);
         addr[0] = addr[0] + size_alternate[0];
         nbr_addr_memreg[0]++;
      end 
      if (window_memreg[1]) begin
        maddrq.push_back(addr[1]);
        addr[1] = addr[1] + size_alternate[1];
        nbr_addr_memreg[1]++;    
      end
    end:alternate_case_between_2memregion
  end

endfunction: gen_seq_addr_in_user_addrq

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_seq_write_addr_in_user_addrq
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::gen_seq_write_addr_in_user_addrq(int num_addr, 
                                                               int addr_step, 
                                                               int intrlv_grp1, 
                                                               int intrlv_grp2, 
                                                               ref ncoreConfigInfo::addrq maddrq);

  int mid;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr2;
  int                   pick_itr;
  int                   region_size = num_addr * addr_step;
  int                   shift_bits = $clog2(addr_step);
   
  // pick random memory region in interleave group
  pick_itr = $urandom_range(m_gen.m_map.grps_memregion[intrlv_grp1].size()-1, 0);
  mid  = m_gen.m_map.grps_memregion[intrlv_grp1][pick_itr];
  // pick random address inside memory region
  addr = m_gen.get_rand_c_nc_addr(mid, 1);
  //if($test$plusargs("perf_test")) begin
  if(addr_step == 256) begin  
     addr[7:0] = 8'h00;  // 256B aligned address for performance sim
  end else if (addr_step == 64) begin
     addr[5:0] = 6'h00;
  end else begin
     addr = m_gen.rand_crit_wrd(addr);
  end
  pick_itr = $urandom_range(m_gen.m_map.grps_memregion[intrlv_grp2].size()-1, 0);
  mid  = m_gen.m_map.grps_memregion[intrlv_grp2][pick_itr];
  // pick random address inside memory region
  addr2 = m_gen.get_rand_c_nc_addr(mid, 1);
  addr2 = m_gen.rand_crit_wrd(addr2);

   for(int i=0; i<num_addr; i=i+17) begin
      for(int j=0; j<16; j=j+1) begin
         maddrq.push_back(addr);
         addr = addr + addr_step;
      end
      maddrq.push_back(addr2);
      addr2 = addr2 + addr_step;
   end
endfunction: gen_seq_write_addr_in_user_addrq

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_seq_dmi_addr_in_user_addrq
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::gen_seq_dmi_addr_in_user_addrq(int num_addr, 
                                                             int offset, 
                                                             int intrlv_grp, 
                                                             ref ncoreConfigInfo::addrq maddrq);

  int mid;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_mask;
  int                   pick_itr;
  int                   addr_step = m_mem.nintrlv_grps[intrlv_grp] * (1 << <%=obj.wCacheLineOffset%>);
  int                   region_size = num_addr * addr_step;
  int                   shift_bits = $clog2(addr_step);
  int                   dmi_id_id;
 
  addr_mask = ~(addr_step - 1);
  // pick random memory region in interleave group
  pick_itr = $urandom_range(m_gen.m_map.grps_memregion[intrlv_grp].size()-1, 0);
  mid  = m_gen.m_map.grps_memregion[intrlv_grp][pick_itr];
  `uvm_info("ADDR DBG", $sformatf("gen_seq_dmi_addr_in_user_addrq - Picked memregion %0d of interleave_group %0d", pick_itr, intrlv_grp), UVM_MEDIUM)
  // pick random address inside memory region
  addr = m_gen.get_rand_c_nc_addr(mid, 1);
  addr = (addr & addr_mask) + offset;
  `uvm_info("ADDR DBG", $sformatf("gen_seq_dmi_addr_in_user_addrq - addr_step: 0x%0h, offset: 0x%0h, Picked addr: 0x%0h", addr_step, offset, addr), UVM_MEDIUM)
   
   for(int i=0; i<num_addr; i=i+1) begin
         maddrq.push_back(addr);
         addr = addr + addr_step;
   end
endfunction: gen_seq_dmi_addr_in_user_addrq

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_seq_dmi_addr_in_user_write_read_addrq
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::gen_seq_dmi_addr_in_user_write_read_addrq(int num_addr, 
                                                                        int offset, 
                                                                        int intrlv_grp, 
                                                                        ref ncoreConfigInfo::addrq write_addrq, 
                                                                        ref ncoreConfigInfo::addrq read_addrq);

  int mid;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr_mask;
  int                   pick_itr;
  int                   addr_step = m_mem.nintrlv_grps[intrlv_grp] * (1 << <%=obj.wCacheLineOffset%>);
  int                   region_size = num_addr * addr_step;
  int                   shift_bits = $clog2(addr_step);

  addr_mask = ~(addr_step - 1);
  // pick random memory region in interleave group
  pick_itr = $urandom_range(m_gen.m_map.grps_memregion[intrlv_grp].size()-1, 0);
  mid  = m_gen.m_map.grps_memregion[intrlv_grp][pick_itr];
  `uvm_info("ADDR DBG", $sformatf("gen_seq_dmi_addr_in_user_addrq - Picked memregion %0d of interleave_group %0d", pick_itr, intrlv_grp), UVM_MEDIUM)
  // pick random address inside memory region
  addr = m_gen.get_rand_c_nc_addr(mid, 1);
  addr = (addr & addr_mask) + offset;
  `uvm_info("ADDR DBG", $sformatf("gen_seq_dmi_addr_in_user_addrq - addr_step: 0x%0h, offset: 0x%0h, Picked addr: 0x%0h", addr_step, offset, addr), UVM_MEDIUM)
   
   for(int i=0; i<num_addr; i=i+1) begin
         read_addrq.push_back(addr);
         addr = addr + addr_step;
         write_addrq.push_back(addr);
         addr = addr + addr_step;
   end
endfunction: gen_seq_dmi_addr_in_user_write_read_addrq

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_seq_addr_w_offset_in_user_addrq
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::gen_seq_addr_w_offset_in_user_addrq(int num_addr, 
                                                                  int addr_step, 
                                                                  int offset, 
                                                                  int intrlv_grp, 
                                                                  ref ncoreConfigInfo::addrq maddrq);

  int mid;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
  int                   pick_itr;
  int                   region_size = num_addr * addr_step;
  int                   shift_bits = $clog2(addr_step);

  // pick random memory region in interleave group
  pick_itr = $urandom_range(m_gen.m_map.grps_memregion[intrlv_grp].size()-1, 0);
  mid  = m_gen.m_map.grps_memregion[intrlv_grp][pick_itr];
  `uvm_info("ADDR DBG", $sformatf("gen_seq_addr_w_offset_in_user_addrq - Picked memregion %0d of interleave_group %0d", pick_itr, intrlv_grp), UVM_MEDIUM)
  // pick random address inside memory region
  addr = m_gen.get_rand_c_nc_addr(mid, 1);
  addr[9:0] = offset;
  `uvm_info("ADDR DBG", $sformatf("gen_seq_addr_w_offset_in_user_addrq - Picked addr: 0x%0h", addr), UVM_MEDIUM)
   
   for(int i=0; i<num_addr; i=i+1) begin
         maddrq.push_back(addr);
         addr = addr + addr_step;
   end
endfunction: gen_seq_addr_w_offset_in_user_addrq

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_seq_addr_in_user_write_read_addrq
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::gen_seq_addr_in_user_write_read_addrq(int num_addr, 
                                                                    int addr_step, 
                                                                    int intrlv_grp, 
                                                                    ref ncoreConfigInfo::addrq write_addrq, 
                                                                    ref ncoreConfigInfo::addrq read_addrq);

  int mid;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
  int                   pick_itr;
  int                   region_size = num_addr * addr_step;
  int                   shift_bits = $clog2(addr_step);

  // pick random memory region in interleave group
  pick_itr = $urandom_range(m_gen.m_map.grps_memregion[intrlv_grp].size()-1, 0);
  mid  = m_gen.m_map.grps_memregion[intrlv_grp][pick_itr];
  `uvm_info("ADDR DBG", $sformatf("gen_seq_addr_in_user_addrq - Picked memregion %0d of interleave_group %0d", pick_itr, intrlv_grp), UVM_MEDIUM)
  // pick random address inside memory region
  addr = m_gen.get_rand_c_nc_addr(mid, 1);
  if($test$plusargs("perf_test")) begin
     addr[7:0] = 8'h00;  // 256B aligned address for performance sim
  end
  else begin
     addr = m_gen.rand_crit_wrd(addr);
  end
  `uvm_info("ADDR DBG", $sformatf("gen_seq_addr_in_user_write_read_addrq - Picked addr: 0x%0h", addr), UVM_MEDIUM)
   
   for(int i=0; i<num_addr; i=i+1) begin
         read_addrq.push_back(addr);
         addr = addr + addr_step;
         write_addrq.push_back(addr);
         addr = addr + addr_step;      
   end
endfunction: gen_seq_addr_in_user_write_read_addrq

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_intrlvgrp_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr_trans_mgr::gen_intrlvgrp_addr(int intrlv_grp, int mem_idx);

  int mid;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
  int                   pick_itr;

  if(mem_idx == -1) begin
     // pick random memory region in interleave group
     pick_itr = $urandom_range(m_gen.m_map.grps_memregion[intrlv_grp].size()-1, 0);
  end else begin
     pick_itr = mem_idx;
  end

  mid  = m_gen.m_map.grps_memregion[intrlv_grp][pick_itr];
  // pick random address inside memory region
  addr = m_gen.get_rand_c_nc_addr(mid, 1);
  `uvm_info("ADDR DBG", $sformatf("gen_intrlvgrp_addr - Picked addr: 0x%0h", addr), UVM_MEDIUM)

   return addr;

endfunction: gen_intrlvgrp_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : set_addr_in_agent_mem_map
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void addr_trans_mgr::set_addr_in_agent_mem_map(
    bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,
    int initiator_agentid);

   m_gen.set_addr_in_agent_mem_map(addr, initiator_agentid);
endfunction // set_addr_in_agent_mem_map

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_memregion_info
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function int addr_trans_mgr::get_memregion_info(input bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,
                                                output bit hut,
                                                output bit [4:0] hui);

    int match = 0;

    foreach(ncoreConfigInfo::memregions_info[region]) begin
       if( (addr >= ncoreConfigInfo::memregions_info[region].start_addr) && (addr <= ncoreConfigInfo::memregions_info[region].end_addr) ) begin
         match = 1;
         hut = (ncoreConfigInfo::memregions_info[region].hut == ncoreConfigInfo::DMI) ? 0 : 1;
         hui = ncoreConfigInfo::memregions_info[region].hui;
         break;
       end
    end

    return match;

endfunction // get_memregion_info

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : check_unmapped_add
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

 function bit addr_trans_mgr::check_unmapped_add(bit [ncoreConfigInfo::ADDR_WIDTH - 1 : 0] addr, int agent_id, output bit [2:0] unit_unconnected);

  unit_unconnected = 0;
 <%if ((obj.testBench != "fsys") && (obj.testBench != "cust_tb") && (obj.testBench != "emu")) {%>
    <%if (obj.Id !== "" && obj.Id !== undefined){%>
      agent_id = <%=obj.Id%>;
    <%} else {%>
      agent_id = 0;
    <%}%>
  <%}%>
  // Previously check function used from ncoreConfigInfo class
  check_unmapped_add = ncoreConfigInfo::check_unmapped_add(
      .addr(addr),
      .agent_id(agent_id),
      .unit_unconnected(unit_unconnected),
      .test_connectivity_test(test_connectivity_test),
      .try_to_gen_addr(1'b0)
      <% if(obj.testBench == "chi_aiu" || obj.testBench == "io_aiu" ) { %>,
      .AiuDce_connectivity_vec(AiuDce_connectivity_vec[agent_id]),
      .AiuDmi_connectivity_vec(AiuDmi_connectivity_vec[agent_id]),
      .AiuDii_connectivity_vec(AiuDii_connectivity_vec[agent_id])
      <%}%>
      );
endfunction : check_unmapped_add


////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : check_unmapped_add_c
// Description : To be able to use in constraint randomizer. Remove output port & set try_gen_addr 
//                to avoid Error message when address isn't the good one.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////
// to be able to use in constraint randomizer 
//remove output port & set try_gen_addr to avoid Error message when address isn't the good one

 function bit addr_trans_mgr::check_unmapped_add_c(bit [ncoreConfigInfo::ADDR_WIDTH - 1 : 0] addr, int agent_id);
  bit [2:0] unit_unconnected; 
  check_unmapped_add_c = ncoreConfigInfo::check_unmapped_add(
      .addr(addr),
      .agent_id(agent_id),
      .unit_unconnected(unit_unconnected),
      .test_connectivity_test(0),
      .try_to_gen_addr(1'b1)
      );
endfunction : check_unmapped_add_c


////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : check_aiu_is_unconnected
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

function bit addr_trans_mgr::check_aiu_is_unconnected(int tgt_unit_id, int src_unit_id);
  int check_unit_id_1, check_unit_id_2;

  if(tgt_unit_id inside {ncoreConfigInfo::aiu_ids}) begin 
    check_unit_id_1 = tgt_unit_id;
    check_unit_id_2 = src_unit_id;
  end else if (src_unit_id inside {ncoreConfigInfo::aiu_ids}) begin 
    check_unit_id_1 = src_unit_id;
    check_unit_id_2 = tgt_unit_id;
  end else // Check only for AIU to AIU/DCE connectivity
    return 0;

  `uvm_info("Connectivity Interleaving feature", $sformatf("check_aiu_is_unconnected AIU%0d to fUnitID %0d", check_unit_id_1, check_unit_id_2),UVM_LOW);
  if(check_unit_id_2 inside {aiu_unconnected_units_table[check_unit_id_1]}) begin
    return 1;
  end else
    return 0;
  
endfunction : check_aiu_is_unconnected



////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_connectivity_if
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
<% if ((obj.testBench == "fsys") || (obj.testBench == "emu") || (obj.testBench =='io_aiu') || (obj.testBench =='chi_aiu')) { %>
 task addr_trans_mgr::get_connectivity_if();

  // Bound Interface
  <%for(var pidx = 0; pidx < _child_blkid.length; pidx++) {%> 
  if (! (uvm_config_db#(virtual <%=_child_blkid[pidx]%>_connectivity_if)::get(null, "", "<%=_child_blkid[pidx]%>_connectivity_if", connectivity_if_<%=_child_blkid[pidx]%>))) begin
    `uvm_fatal("Connectivity interface error", "virtual interface must be set for connectivity_if_<%=_child_blkid[pidx]%>");
  end
  <%}%>

      <%if ((obj.testBench == "fsys") || (obj.testBench === "cust_tb") || (obj.testBench == "emu")) {%> 
  fork
    <%for(var pidx = 0; pidx < _child_blkid.length; pidx++) {%> 
    begin
        AiuDce_connectivity_vec[<%=pidx%>] = connectivity_if_<%=_child_blkid[pidx]%>.AiuDce_connectivity_vec;
        AiuDmi_connectivity_vec[<%=pidx%>] = connectivity_if_<%=_child_blkid[pidx]%>.AiuDmi_connectivity_vec;
        AiuDii_connectivity_vec[<%=pidx%>] = connectivity_if_<%=_child_blkid[pidx]%>.AiuDii_connectivity_vec;
    end
      <%}%>
  join
      <%} else {%>

  fork
    begin
      forever begin
         @(posedge connectivity_if_<%=obj.BlockId%>.clk);
        AiuDce_connectivity_vec[<%=obj.Id%>] = connectivity_if_<%=obj.BlockId%>.AiuDce_connectivity_vec;
        AiuDmi_connectivity_vec[<%=obj.Id%>] = connectivity_if_<%=obj.BlockId%>.AiuDmi_connectivity_vec;
        AiuDii_connectivity_vec[<%=obj.Id%>] = connectivity_if_<%=obj.BlockId%>.AiuDii_connectivity_vec;
     end
    end
  join
     <%}%>
 endtask : get_connectivity_if
 <%}%>
