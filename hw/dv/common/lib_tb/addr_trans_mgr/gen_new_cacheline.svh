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

typedef ncore_memory_map;
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Class : gen_new_cacheline
// Description : Generate new cacheline depending on arguments
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
class gen_new_cacheline extends uvm_object;

  `uvm_object_utils(gen_new_cacheline)

  localparam int STACK_DEPTH = 3 * ncoreConfigInfo::NUM_AGENTS;
  typedef class constrain_bits;
  ncore_memory_map m_map;
  constrain_bits   m_cnstrn;

  static bit test_connectivity_test;
  static int aiu_unconnected_units_table[0:ncoreConfigInfo::NUM_AIUS-1][$];
  bit [2:0] unit_unconnected;

  //Internal Data structures
  bit [ncoreConfigInfo::W_SEC_ADDR -1: 0] unq_addrq[][$];
  int m_agent_mem_map[bit [63:0]];

  cacheline_dist m_addr_hit[];
  cacheline_dist m_inv_sec;
  cacheline_dist m_rct_addr;

  rand bit nc_reg_h;
  bit merg_c_nc;
 
  //constructor
  extern function new(string name = "gen_new_cacheline");
  //interface methods to pass ncore_memory_map handle
  extern function void get_ncore_mem_map(const ref ncore_memory_map map);
  extern function void set_addr_collision_pct(int agentid, int hit_pct);
  extern function void addr_evicted_from_agent(int agentid, 
                                               bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] addr);

  //interface methods to request coherent address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_coh_addr(int agentid, 
                                                                   bit collision_user = 0, 
                                                                   int core_id=0, 
                                                                   int set_index = -1,
                                                                   int tfilter_id = -1);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_coh_addr(int agentid,
                                                                   int target_id    = -1,
                                                                   int memregion_id = -1,
                                                                   int tfilter_id   = -1,
                                                                   int set_index    = -1, 
                                                                   int core_id     = 0);

  //interface methods to request IO-coherent address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_iocoh_addr(int agentid, int core_id=0);
  
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_iocoh_addr(int agentid,
                                                                     int memregion_id, 
                                                                     int core_id=0);

  //interface methods to request Non-coherent address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_noncoh_addr(int agentid, int core_id=0);
  
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_noncoh_addr(int agentid,
                                                                      int memregion_id = -1,
                                                                      int core_id=0);

  //interface methods to get Boot region address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_bootreg_addr(int agentid);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_bootreg_addr(int agentid);
   
  //interface methods to get Boot region address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_noncohboot_addr(int agentid, int core_id=0);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_noncohboot_addr(int agentid, int core_id=0);
   
  //interface methods to get Boot region address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_cohboot_addr(int agentid, int core_id=0);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_cohboot_addr(int agentid, int core_id=0);

  //interface methods to get memory region lower and upper bound
  extern function void get_region_bounds(input int                              mid,
                                         output [ncoreConfigInfo::W_SEC_ADDR -1:0] lb,
                                         output [ncoreConfigInfo::W_SEC_ADDR -1:0] ub );
   
  //interface methods to get User address
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_user_coh_addr(int agentid, int idx);
  extern function void gen_user_coh_addr(int agentid, int _size, int memregionid, ref ncoreConfigInfo::addrq maddrq);

  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_user_noncoh_addr(int agentid, int idx);
  extern function void gen_user_noncoh_addr(int agentid, int _size, int memregionid, ref ncoreConfigInfo::addrq maddrq);
   
  //Misc address generation methods
  extern function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] get_set_index(int agentid,
                                                                   bit [ncoreConfigInfo::W_SEC_ADDR -1: 0] addr,
                                                                   int tfid = -1);
  extern function bit[ncoreConfigInfo::W_SEC_ADDR-1:0] get_rand_c_nc_addr(int mid,
                                                                       bit c_nc,
                                                                       int agentid = -1, 
                                                                       int core_id=0);    
  ////
  //local D.S handling methods
  ////
  extern function bit addr_map_succ(int agentid, 
                                    bit collision,
                                    bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr, 
                                    int core_id=0);
  extern function bit addr_present_ncore(bit [63:0] key);
  extern function void set_addr_in_agent_mem_map(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,
                                                 int initiator_agentid);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] gen_rand_coh_addr(int iid, int core_id=0);

  //local address generation methods
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] dispatch_coh_addr_gen(int initiator_id,
                                                                            int target_id    = -1,
                                                                            int memregion_id = -1,
                                                                            int tfilter_id   = -1,
                                                                            int set_index    = -1, 
                                                                            int core_id    = 0);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] unq_coh_addr(int iid, 
                                                                   int core_id=0,
                                                                   int set_index = -1);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] unq_coh_addr_target(int iid, 
                                                                          int tid, 
                                                                          int core_id=0);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] unq_coh_addr_memrgn(int iid, 
                                                                          int mid, 
                                                                          int core_id=0);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] unq_coh_addr_tagidx(ncoreConfigInfo::ncore_unit_type_t utype,
                                                                          int iid, 
                                                                          int tid, 
                                                                          int set_index, 
                                                                          int core_id=0);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] unq_iocoh_addr(int agentid, int core_id=0);

  //address generation helper methods
  extern function int pick_memregion(ncoreConfigInfo::addr_format_t mem_type, int agentid=-1);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] rand_addr_bound(bit[63:0] min, bit[63:0] max);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] rand_crit_wrd(bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr);
  extern function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] set_prtsel(bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr,
                                                                ncoreConfigInfo::sel_bits_t bit_idxs,
                                                                int value);

  extern function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] calc_set_index(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,
                                                                     const ref ncoreConfigInfo::sel_bits_t bit_idxs);

  extern function ncoreConfigInfo::sel_bits_t get_port_sel_bits(int iid);
  extern function bit[31:0] get_port_sel_val(int iid);
  extern function bit is_routing_legal(ncoreConfigInfo::sel_bits_t initiator,
                                       bit [31:0] initiator_value,
                                       ncoreConfigInfo::sel_bits_t target,
                                       bit [31:0] target_value);

  extern function bit ord_rt_lgl(const ref ncoreConfigInfo::sel_bits_t ir,
                                 const ref ncoreConfigInfo::sel_bits_t tr,
                                 input bit [31:0] ival,
                                 input bit [31:0] tval);

  extern function both_qs_identcl(const ref int q1[$], const ref int q2[$]);
  extern function ncoreConfigInfo::sel_bits_t get_sf_set_bits(int id);
  extern function ncoreConfigInfo::sel_bits_t get_dmi_set_bits(int id);
  extern function ncoreConfigInfo::sel_bits_t get_aiu_set_bits(int id);

  //configuration helper local methods
  extern function void init_addr_collison_pct();

  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  //
  // Class : constrain_bits 
  // Description: Nested class for simplicity
  //
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  class constrain_bits;
    rand bit bit_vals[$];
    int  num_bits;
    bit  res;

    constraint c1 {
      foreach (bit_vals[i])
        bit_vals[i] inside {[0:1]};
      bit_vals.xor() == res;
      bit_vals.size() == num_bits;
    }

    function void post_randomize();
      bit_vals.shuffle();
    endfunction: post_randomize

  endclass: constrain_bits

endclass: gen_new_cacheline

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : new
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function gen_new_cacheline::new(string name = "gen_new_cacheline");
  ncoreConfigInfo::addr_format_t f;

  super.new(name);
  
  unq_addrq = new[f.num()];
  ncoreConfigInfo::user_addrq = new[f.num()];
  ncoreConfigInfo::tmp_user_addrq = new[f.num()];
  m_cnstrn = new();
  init_addr_collison_pct();
  m_inv_sec = new();
  m_inv_sec.set_posb(ncoreConfigInfo::EN_SEC * 50);
  m_rct_addr = new();
  m_rct_addr.set_posb(10);

  if (! $value$plusargs("merg_c_nc=%d", merg_c_nc)) begin
     merg_c_nc = 0;
  end
endfunction: new

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_ncore_mem_map
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void gen_new_cacheline::get_ncore_mem_map(const ref ncore_memory_map map);
  m_map = map;
endfunction: get_ncore_mem_map

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : set_addr_collision_pct
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void gen_new_cacheline::set_addr_collision_pct(int agentid, int hit_pct);

  `ASSERT(agentid < ncoreConfigInfo::NUM_AGENTS);
  `ASSERT( hit_pct >= 0 && hit_pct <= 100);
  m_addr_hit[agentid].set_posb(hit_pct);
endfunction: set_addr_collision_pct

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : addr_evicted_from_agent
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void gen_new_cacheline::addr_evicted_from_agent(int agentid,  //this is the FUnitId
                                                         bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] addr);

  int lid, cid, id;
  ncoreConfigInfo::ncore_unit_type_t utype;
  bit [63:0] key;
  string m;

  ncoreConfigInfo::get_logical_uinfo(agentid, lid, cid, utype);

  if (utype == ncoreConfigInfo::AIU) begin
    key = (agentid << ncoreConfigInfo::W_SEC_ADDR) | addr;
    //Address stored are 64-byte aligned
    key = (key >> 6) << 6;
    m = $psprintf("addr with security bit: 0x%0h", key);
    
    //Enable commented line for debugging
    `uvm_info("ADDR MGR DBG", $psprintf("DECR agent-id: %0d addr: 0x%0h key: 0x%0h",
       agentid, addr, key), UVM_HIGH)
    `ASSERT(addr_present_ncore(key), m);
    //if(!addr_present_ncore(key))
// `uvm_warning("ADDR_MAP_ERROR", $sformatf("evicted empty cacheline. addr: %x, key: %x, agentid: %x", addr, key, agentid))
  //  else
    begin
      m_agent_mem_map[key] = m_agent_mem_map[key]--;
      `ASSERT(!(m_agent_mem_map[key] < 0));
    end
  end
endfunction: addr_evicted_from_agent


////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_coh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
// agentid is the funitID
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::get_coh_addr(int agentid, 
                                                                             bit collision_user = 0, 
                                                                             int core_id=0, 
                                                                             int set_index = -1, 
                                                                             int tfilter_id = -1); 
<% if (obj.Block =='dmi' || obj.Block == 'ioaiu') { %>
  localparam int TIME_OUT = 200000;   // CONC_10897 - update from 100000 to 200000
<% } else {%>
  localparam int TIME_OUT = 20000;
<% } %>
  bit collision, pick_rct;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr_match[$];
  int pick_itr;
  int const_itr;
  int count;

  `ASSERT(ncoreConfigInfo::get_unit_type(agentid) == ncoreConfigInfo::AIU ||
          ncoreConfigInfo::get_unit_type(agentid) == ncoreConfigInfo::DCE ||
          ncoreConfigInfo::get_unit_type(agentid) == ncoreConfigInfo::DMI);
  `ASSERT(m_addr_hit[agentid].randomize());
  if (!collision_user) begin
      collision = m_addr_hit[agentid].new_cacheline;
  end else begin
      collision = 1;
  end

  //Execution entered this line because none of recent address were picked 
  if (unq_addrq[ncoreConfigInfo::COH].size()) begin
    bit brek;
    pick_itr = $urandom_range(0, unq_addrq[ncoreConfigInfo::COH].size() -1);
    const_itr = pick_itr;
    count = 0;
    do begin
      count++;
      if (addr_map_succ(agentid, collision,
        unq_addrq[ncoreConfigInfo::COH][pick_itr], core_id)) begin

          addr = unq_addrq[ncoreConfigInfo::COH][pick_itr];
          brek = 1;
        end else begin
          pick_itr++;
          if (pick_itr == unq_addrq[ncoreConfigInfo::COH].size())
              pick_itr = 0;
        end
    end while((!brek) && (const_itr != pick_itr) && (count < TIME_OUT));

    if (brek) begin
      set_addr_in_agent_mem_map(addr, agentid);
      return addr;
    end
  end

  `ASSERT(m_inv_sec.randomize());
  //pick a cacheline for which security bit is inverted
  //and if that does not exist, then forward them
  if (m_inv_sec.new_cacheline && unq_addrq[ncoreConfigInfo::COH].size()) begin
    bit brek;
    pick_itr = $urandom_range(0, unq_addrq[ncoreConfigInfo::COH].size() -1);
    const_itr = pick_itr;
    count = 0;
    do begin
      count++;
      addr = unq_addrq[ncoreConfigInfo::COH][pick_itr];
      //Inverting security bit
      addr[ncoreConfigInfo::W_SEC_ADDR-1] = ~addr[ncoreConfigInfo::W_SEC_ADDR-1];
      //Check if address already exists
      if (addr_map_succ(agentid, 0, addr, core_id)) begin

        brek = 1;
      end else begin
        pick_itr++;
        if (pick_itr == unq_addrq[ncoreConfigInfo::COH].size())
            pick_itr = 0;
      end
    end while((!brek) && (const_itr != pick_itr) && (count < TIME_OUT));

    if (brek) begin
      set_addr_in_agent_mem_map(addr, agentid);
      return addr;
    end
  end

  //Execution entered this line because none of pct address was picked
  addr = gen_coh_addr(agentid, -1, -1, tfilter_id,set_index, core_id);
   
  return addr;
endfunction: get_coh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_coh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::gen_coh_addr(int agentid,
                                                                             int target_id    = -1,
                                                                             int memregion_id = -1,
                                                                             int tfilter_id   = -1,
                                                                             int set_index    = -1, 
                                                                             int core_id      = 0);

  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr_match[$];

  `ASSERT(ncoreConfigInfo::get_unit_type(agentid) == ncoreConfigInfo::AIU ||
          ncoreConfigInfo::get_unit_type(agentid) == ncoreConfigInfo::DCE ||
          ncoreConfigInfo::get_unit_type(agentid) == ncoreConfigInfo::DMI);
  do begin
  <%if(obj.testBench =='dce' && obj.initiatorGroups.length > 1){ %>
  do begin 
  <%}%>
      addr = dispatch_coh_addr_gen(agentid, target_id, memregion_id, tfilter_id, set_index, core_id);
  <%if(obj.testBench =='dce' && obj.initiatorGroups.length > 1){ %>
  end
  while(ncoreConfigInfo::check_dmi_is_unconnected(addr));
  <%}%>
      // make sure address generated is unique to NONCOH space as well
      addr_match = unq_addrq[ncoreConfigInfo::NONCOH].find(x) with (x == addr);
  end
  while(addr_match.size() > 0); 

  unq_addrq[ncoreConfigInfo::COH].push_back(addr);
  set_addr_in_agent_mem_map(addr, agentid);
  return addr;  
endfunction: gen_coh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_iocoh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::get_iocoh_addr(int agentid, int core_id=0);

  localparam int TIME_OUT = 20000;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
  bit collision, pick_rct;
  int pick_itr;
  int const_itr;
  int count;

  `ASSERT(ncoreConfigInfo::get_unit_type(agentid) == ncoreConfigInfo::AIU ||
          ncoreConfigInfo::get_unit_type(agentid) == ncoreConfigInfo::DII);
  `ASSERT(m_addr_hit[agentid].randomize());
  collision = m_addr_hit[agentid].new_cacheline;

  if (unq_addrq[ncoreConfigInfo::IOCOH].size()) begin
    bit brek;
    //Execution entered this line because none of recent address was picked 
    pick_itr = $urandom_range(0, unq_addrq[ncoreConfigInfo::IOCOH].size() -1);
    const_itr = pick_itr;
    count = 0;
    do begin
      count++;
      if (addr_map_succ(agentid, collision,
          unq_addrq[ncoreConfigInfo::IOCOH][pick_itr], core_id)) begin

        addr = unq_addrq[ncoreConfigInfo::IOCOH][pick_itr];
        brek = 1;
      end else begin
        pick_itr++;
        if (pick_itr == unq_addrq[ncoreConfigInfo::IOCOH].size())
            pick_itr = 0;
      end
    end while((!brek) && (const_itr != pick_itr) && (count < TIME_OUT));

    if (brek) begin
      set_addr_in_agent_mem_map(addr, agentid);
      return addr;
    end
  end

  //Execution entered this line because none of pct address was picked
  if(ncoreConfigInfo::NUM_DIIS > 1) begin
     addr = unq_iocoh_addr(agentid, core_id);
     unq_addrq[ncoreConfigInfo::IOCOH].push_back(addr);
  end else begin
     addr = 0;
  end

  return addr;
endfunction: get_iocoh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_iocoh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::gen_iocoh_addr(int agentid,
                                                                               int memregion_id, 
                                                                               int core_id=0);

  int mid;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;

  mid  = pick_memregion(ncoreConfigInfo::IOCOH, agentid);
//  addr = rand_addr_bound(m_map.lbound(memregion_id),
//       m_map.ubound(memregion_id));

  addr = get_rand_c_nc_addr(mid, 1, agentid, core_id);
  addr = rand_crit_wrd(addr);
  `ASSERT(m_inv_sec.randomize());
  if (m_inv_sec.new_cacheline) 
    addr[ncoreConfigInfo::W_SEC_ADDR - 1] = ~addr[ncoreConfigInfo::W_SEC_ADDR - 1];
    
  return set_prtsel(addr,
    get_port_sel_bits(agentid), get_port_sel_val(agentid));
endfunction: gen_iocoh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_noncoh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::get_noncoh_addr(int agentid, int core_id=0);
<% if (obj.Block =='dmi') { %>
  localparam int TIME_OUT = 200000;       // CONC_10897 - update from 100000 to 200000
<% } else {%>
  localparam int TIME_OUT = 20000;
<% } %>
  int mid;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr_match[$];
  bit collision, pick_rct;
  int pick_itr;
  int const_itr;
  int count;

if(!$test$plusargs("addr_mgr_dummy_addr")) begin
  `ASSERT(m_addr_hit[agentid].randomize());
  collision = m_addr_hit[agentid].new_cacheline;

  //Execution entered this line because none of recent address was picked 
  if (unq_addrq[ncoreConfigInfo::NONCOH].size()) begin
    bit brek;
    pick_itr = $urandom_range(0, unq_addrq[ncoreConfigInfo::NONCOH].size() -1);
    const_itr = pick_itr;
    count = 0;
    do begin
        count++;
        if (addr_map_succ(agentid, collision, unq_addrq[ncoreConfigInfo::NONCOH][pick_itr], core_id)) begin
            addr = unq_addrq[ncoreConfigInfo::NONCOH][pick_itr];
            brek = 1;
        end else begin
            pick_itr++;
            if (pick_itr == unq_addrq[ncoreConfigInfo::NONCOH].size())
                pick_itr = 0;
        end
    end while((!brek) && (const_itr != pick_itr) && (count < TIME_OUT));

    if (brek) begin
      set_addr_in_agent_mem_map(addr, agentid);
      return addr;
    end
  end
end  

  //Execution entered this line because none of pct address was picked
  addr = gen_noncoh_addr(agentid, -1, core_id); 
  return addr;
endfunction: get_noncoh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_bootreg_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::get_bootreg_addr(int agentid);

  localparam int TIME_OUT = 20000;
  int      mid;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
  bit collision, pick_rct;
  int pick_itr;
  int const_itr;
  int count;
  
  `ASSERT(m_addr_hit[agentid].randomize());
  collision = m_addr_hit[agentid].new_cacheline;
   
  //Execution entered this line because none of recent address was picked 
  if (unq_addrq[ncoreConfigInfo::BOOT].size()) begin
    bit brek;
    pick_itr = $urandom_range(0, unq_addrq[ncoreConfigInfo::BOOT].size() -1);
    const_itr = pick_itr;
    count = 0;
    do begin
        count++;
        if (addr_map_succ(agentid, collision, unq_addrq[ncoreConfigInfo::BOOT][pick_itr])) begin
            addr = unq_addrq[ncoreConfigInfo::BOOT][pick_itr];
            brek = 1;
        end else begin
            pick_itr++;
            if (pick_itr == unq_addrq[ncoreConfigInfo::BOOT].size())
                pick_itr = 0;
        end
    end while ((!brek) && (const_itr != pick_itr) && (count < TIME_OUT)); // UNMATCHED !!
    if (brek) begin
      set_addr_in_agent_mem_map(addr, agentid);
      return addr;
    end
  end

  //Execution entered this line because none of pct address was picked
   `uvm_info($sformatf("%m"), $sformatf("BOOT REG: generating addr"), UVM_HIGH)
  addr = rand_addr_bound(ncoreConfigInfo::BOOT_REGION_BASE, ncoreConfigInfo::BOOT_REGION_BASE+ncoreConfigInfo::BOOT_REGION_SIZE-1);
  addr = rand_crit_wrd(addr);
  addr = set_prtsel(addr, get_port_sel_bits(agentid),get_port_sel_val(agentid));
  `uvm_info($sformatf("%m"), $sformatf("BOOT REG: generated addr %p for agent=%0d", addr, agentid), UVM_HIGH)

  unq_addrq[ncoreConfigInfo::BOOT].push_back(addr);
  set_addr_in_agent_mem_map(addr, agentid);
  return addr;
endfunction: get_bootreg_addr
     
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_noncoh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::gen_noncoh_addr(int agentid, 
                                                                                int memregion_id = -1, 
                                                                                int core_id=0);

  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr_match[$];
  int mid;

  do begin

    if(memregion_id != -1)
       mid  = memregion_id;
    else
       mid  = pick_memregion(ncoreConfigInfo::NONCOH, agentid);
    
    addr = get_rand_c_nc_addr(mid, 0, agentid, core_id);
    if($test$plusargs("perf_test")) begin
       addr[7:0] = 8'h00;  // 256B aligned address for performance sim
    end
    else if($test$plusargs("en_excl_noncoh_txn")) begin
       addr[5:0] = 6'h00;  // 64B aligned address for exclusive transaction
    end
    else begin
       addr = rand_crit_wrd(addr);
       addr = set_prtsel(addr, get_port_sel_bits(agentid),
              get_port_sel_val(agentid));
    end
    `ASSERT(m_inv_sec.randomize());
    if (m_inv_sec.new_cacheline) 
      addr[ncoreConfigInfo::W_SEC_ADDR - 1] = ~addr[ncoreConfigInfo::W_SEC_ADDR - 1];

    addr_match = unq_addrq[ncoreConfigInfo::COH].find(x) with (x == addr);
  end while(addr_match.size() > 0); 

if(!$test$plusargs("addr_mgr_dummy_addr")) begin  
  unq_addrq[ncoreConfigInfo::NONCOH].push_back(addr);
end else begin
  unq_addrq[ncoreConfigInfo::NONCOH] = {};
end
  set_addr_in_agent_mem_map(addr, agentid);
  //`uvm_info($sformatf("%m"), $sformatf("fn:gen_noncoh_addr ADDR_MGR: generated NC address %p for core_id:%0d", addr, core_id), UVM_DEBUG)
  return addr;
endfunction: gen_noncoh_addr
   
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_bootreg_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] gen_new_cacheline::gen_bootreg_addr(int agentid);
   bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
   addr = rand_addr_bound(ncoreConfigInfo::BOOT_REGION_BASE, ncoreConfigInfo::BOOT_REGION_BASE+ncoreConfigInfo::BOOT_REGION_SIZE);
   addr = rand_crit_wrd(addr);
   addr = set_prtsel(addr, get_port_sel_bits(agentid), get_port_sel_val(agentid));
   unq_addrq[ncoreConfigInfo::BOOT].push_back(addr);
   //`uvm_info($sformatf("%m"), $sformatf("Generated boot_region address %p for agentid %0d", addr, agentid), UVM_LOW)
   return addr;
endfunction : gen_bootreg_addr
   
////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_noncohboot_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] gen_new_cacheline::gen_noncohboot_addr(int agentid, int core_id=0);
   bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
   addr = rand_addr_bound(ncoreConfigInfo::BOOT_REGION_BASE, ncoreConfigInfo::BOOT_REGION_BASE+ncoreConfigInfo::BOOT_REGION_SIZE/2);
   addr = rand_crit_wrd(addr);
   addr = set_prtsel(addr, get_port_sel_bits(agentid), get_port_sel_val(agentid));
   addr = ncoreConfigInfo::update_addr_for_core(addr,agentid,core_id);
   unq_addrq[ncoreConfigInfo::BOOTNONCOH].push_back(addr);
   set_addr_in_agent_mem_map(addr, agentid);
   //`uvm_info($sformatf("%m"), $sformatf("Generated NONCOH boot_region address %p for agentid %0d", addr, agentid), UVM_LOW)
   return addr;
endfunction : gen_noncohboot_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_noncohboot_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::get_noncohboot_addr(int agentid, int core_id=0);

  localparam int TIME_OUT = 20000;
  int      mid;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
  bit collision, pick_rct;
  int pick_itr;
  int const_itr;
  int count;
  
  `ASSERT(m_addr_hit[agentid].randomize());
  collision = m_addr_hit[agentid].new_cacheline;
   
  //Execution entered this line because none of recent address was picked 
  if (unq_addrq[ncoreConfigInfo::BOOTNONCOH].size()) begin
    bit brek;
    pick_itr = $urandom_range(0, unq_addrq[ncoreConfigInfo::BOOTNONCOH].size() -1);
    const_itr = pick_itr;
    count = 0;
    do begin
        count++;
        if (addr_map_succ(agentid, collision, unq_addrq[ncoreConfigInfo::BOOTNONCOH][pick_itr], core_id)) begin
            addr = unq_addrq[ncoreConfigInfo::BOOTNONCOH][pick_itr];
            brek = 1;
        end else begin
            pick_itr++;
            if (pick_itr == unq_addrq[ncoreConfigInfo::BOOTNONCOH].size())
                pick_itr = 0;
        end
    end while ((!brek) && (const_itr != pick_itr) && (count < TIME_OUT)); // UNMATCHED !!
    if (brek) begin
      set_addr_in_agent_mem_map(addr, agentid);
      return addr;
    end
  end

  //Execution entered this line because none of pct address was picked
  addr = gen_noncohboot_addr(agentid, core_id);

  return addr;
endfunction: get_noncohboot_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_cohboot_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] gen_new_cacheline::gen_cohboot_addr(int agentid, int core_id=0);

   bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
   addr = rand_addr_bound(ncoreConfigInfo::BOOT_REGION_BASE+ncoreConfigInfo::BOOT_REGION_SIZE/2, ncoreConfigInfo::BOOT_REGION_BASE+ncoreConfigInfo::BOOT_REGION_SIZE);
   addr = rand_crit_wrd(addr);
   addr = set_prtsel(addr, get_port_sel_bits(agentid), get_port_sel_val(agentid));
   addr = ncoreConfigInfo::update_addr_for_core(addr,agentid, core_id);
   unq_addrq[ncoreConfigInfo::BOOTCOH].push_back(addr);
   set_addr_in_agent_mem_map(addr, agentid);
   //`uvm_info($sformatf("%m"), $sformatf("Generated COH boot_region address %p for agentid %0d for core_id:%0d", addr, agentid, core_id), UVM_LOW)
   return addr;
endfunction : gen_cohboot_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_cohboot_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::get_cohboot_addr(int agentid, int core_id=0);

  localparam int TIME_OUT = 20000;
  int      mid;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
  bit collision, pick_rct;
  int pick_itr;
  int const_itr;
  int count;
  
  `ASSERT(m_addr_hit[agentid].randomize());
  collision = m_addr_hit[agentid].new_cacheline;
   
  //Execution entered this line because none of recent address was picked 
  if (unq_addrq[ncoreConfigInfo::BOOTCOH].size()) begin
    bit brek;
    pick_itr = $urandom_range(0, unq_addrq[ncoreConfigInfo::BOOTCOH].size() -1);
    const_itr = pick_itr;
    count = 0;
    do begin
        count++;
        if (addr_map_succ(agentid, collision, unq_addrq[ncoreConfigInfo::BOOTCOH][pick_itr], core_id)) begin
            addr = unq_addrq[ncoreConfigInfo::BOOTCOH][pick_itr];
            brek = 1;
        end else begin
            pick_itr++;
            if (pick_itr == unq_addrq[ncoreConfigInfo::BOOTCOH].size())
                pick_itr = 0;
        end
    end while ((!brek) && (const_itr != pick_itr) && (count < TIME_OUT)); // UNMATCHED !!
    if (brek) begin
      set_addr_in_agent_mem_map(addr, agentid);
      return addr;
    end
  end

  //Execution entered this line because none of pct address was picked
  addr = gen_cohboot_addr(agentid, core_id);

  return addr;
endfunction: get_cohboot_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_user_noncoh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void gen_new_cacheline::gen_user_noncoh_addr(int agentid, 
                                                      int _size, 
                                                      int memregionid, 
                                                      ref ncoreConfigInfo::addrq maddrq);

  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr_match[$];
  int mid;

  for(int i=0; i<_size; i=i+1) begin
    do begin

    if(memregionid != -1) begin
       mid = memregionid;
    end else begin
       if(m_map.noncoh_regq.size()>0) begin
          mid  = pick_memregion(ncoreConfigInfo::NONCOH, agentid);
       end else begin
          mid  = pick_memregion(ncoreConfigInfo::COH, agentid);
       end
    end
    addr = get_rand_c_nc_addr(mid, 0, agentid);

    if($test$plusargs("perf_test")) begin
       addr[7:0] = 8'h00;  // 256B aligned address for performance sim
    end
    else if($test$plusargs("en_excl_noncoh_txn")) begin
       addr[5:0] = 6'h00;  // 64B aligned address for exclusive transaction
    end
    else begin
       addr = rand_crit_wrd(addr);
       addr = set_prtsel(addr, get_port_sel_bits(agentid),
              get_port_sel_val(agentid));
    end

    if(!$test$plusargs("perf_test")) begin  // case perf_test doesn't create security bit (last bit address)
    `ASSERT(m_inv_sec.randomize());
    if (m_inv_sec.new_cacheline) 
      addr[ncoreConfigInfo::W_SEC_ADDR - 1] = ~addr[ncoreConfigInfo::W_SEC_ADDR - 1];
    end
    addr_match = maddrq.find(x) with (x == addr);
    end while(addr_match.size() > 0); 

    maddrq.push_back(addr);
    //set_addr_in_agent_mem_map(addr, agentid);
    `uvm_info($sformatf("%m"), $sformatf("ADDR_MGR: generated user NC address %p", addr), UVM_MEDIUM)
  end // for (int i=0; i<_size; i=i+1)   
endfunction: gen_user_noncoh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_user_coh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void gen_new_cacheline::gen_user_coh_addr(int agentid, 
                                                   int _size, 
                                                   int memregionid, 
                                                   ref ncoreConfigInfo::addrq maddrq);

  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr_match[$];
  int mid;

  for(int i=0; i<_size; i=i+1) begin
    do begin

    if(memregionid != -1) begin
       mid = memregionid;
    end else begin
       mid  = pick_memregion(ncoreConfigInfo::COH, agentid);
    end
    addr = get_rand_c_nc_addr(mid, 1, agentid);
    if($test$plusargs("perf_test")) begin
       addr[7:0] = 8'h00;  // 256B aligned address for performance sim
    end
    else if($test$plusargs("en_excl_txn")) begin
       addr[5:0] = 6'h00;  // 64B aligned address for exclusive transaction
    end
    else begin
       addr = rand_crit_wrd(addr);
       addr = set_prtsel(addr, get_port_sel_bits(agentid),
              get_port_sel_val(agentid));
    end

    `ASSERT(m_inv_sec.randomize());
    if (m_inv_sec.new_cacheline) 
      addr[ncoreConfigInfo::W_SEC_ADDR - 1] = ~addr[ncoreConfigInfo::W_SEC_ADDR - 1];

    addr_match = maddrq.find(x) with (x == addr);
    end while(addr_match.size() > 0); 

    maddrq.push_back(addr);
    //set_addr_in_agent_mem_map(addr, agentid);
    `uvm_info($sformatf("%m"), $sformatf("ADDR_MGR: generated user C address %p", addr), UVM_MEDIUM)
  end // for (int i=0; i<_size; i=i+1)   
endfunction: gen_user_coh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_user_noncoh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::get_user_noncoh_addr(int agentid, int idx);

  localparam int TIME_OUT = 20000;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
  int pick_itr;

   if(ncoreConfigInfo::NUM_DIIS > 1) begin
      `ASSERT(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size() > 0);

      if(idx == -1) begin
         pick_itr = $urandom_range(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size() -1);
      end else begin
         pick_itr = idx;
      end
      addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][pick_itr];
   end else if(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size() > 0) begin
      if(idx == -1) begin
         pick_itr = $urandom_range(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size() -1);
      end else begin
         pick_itr = idx;
      end
      addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][pick_itr];
   end else begin
      addr = 0;
      `ASSERT(addr > 0);
   end // else: !if(ncoreConfigInfo::NUM_DIIS > 1)
   set_addr_in_agent_mem_map(addr, agentid);

   return addr;
endfunction: get_user_noncoh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_user_coh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::get_user_coh_addr(int agentid, int idx);

  localparam int TIME_OUT = 20000;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
  int pick_itr;

   `ASSERT(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size() > 0);

   if(idx == -1) begin
      pick_itr = $urandom_range(0, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size() -1);
   end else begin
      pick_itr = idx;
   end

   addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][pick_itr];
   set_addr_in_agent_mem_map(addr, agentid);
   return addr;
endfunction: get_user_coh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : dispatch_coh_addr_gen
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::dispatch_coh_addr_gen(int initiator_id,
                                                                                      int target_id    = -1,
                                                                                      int memregion_id = -1,
                                                                                      int tfilter_id   = -1,
                                                                                      int set_index    = -1,
                                                                                      int core_id);

  if (set_index != -1) begin

    if (tfilter_id != -1) begin
      return unq_coh_addr_tagidx(ncoreConfigInfo::DCE, initiator_id, tfilter_id, set_index);
    end else if(target_id != -1) begin
      return unq_coh_addr_tagidx(ncoreConfigInfo::get_unit_type(target_id), initiator_id, target_id, set_index, core_id);
    end else begin
      return unq_coh_addr(initiator_id, core_id,set_index);
    end

  end else if (memregion_id != -1) begin
    return unq_coh_addr_memrgn(initiator_id, memregion_id, core_id);
  
  end else if (target_id != -1) begin
    return unq_coh_addr_target(initiator_id, target_id, core_id);
  end

  return unq_coh_addr(initiator_id, core_id);
endfunction: dispatch_coh_addr_gen

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : unq_iocoh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::unq_iocoh_addr(int agentid, int core_id=0);

  int mid;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
  bit [63:0] key;

  mid  = pick_memregion(ncoreConfigInfo::IOCOH, agentid);
//  addr = rand_addr_bound(m_map.lbound(mid), m_map.ubound(mid));
  addr = get_rand_c_nc_addr(mid,1,agentid, core_id);
  addr = rand_crit_wrd(addr);
  `ASSERT(m_inv_sec.randomize());
  if (m_inv_sec.new_cacheline) 
    addr[ncoreConfigInfo::W_SEC_ADDR - 1] = ~addr[ncoreConfigInfo::W_SEC_ADDR - 1];

  //Assign port selection bits
  addr = set_prtsel(addr,
    get_port_sel_bits(agentid), get_port_sel_val(agentid));

  //Save the address generated for a specific agent
  set_addr_in_agent_mem_map(addr, agentid);

  return addr;
endfunction: unq_iocoh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : unq_coh_addr
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::unq_coh_addr(int iid, 
                                                                             int core_id=0,
                                                                             int set_index    = -1);

  int mid;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
  int lid, cid;
  ncoreConfigInfo::ncore_unit_type_t utype;
  ncoreConfigInfo::sel_bits_t        psel;

  mid  = pick_memregion(ncoreConfigInfo::COH, iid);
  addr = get_rand_c_nc_addr(mid,1,iid, core_id);
  if($test$plusargs("perf_test")) begin
     addr[7:0] = 8'h00;  // 256B aligned address for performance sim
  end
  else if($test$plusargs("en_excl_txn")) begin
     addr[5:0] = 6'h00;  // 64B aligned address for exclusive transaction
  end
  else begin
     addr = rand_crit_wrd(addr);
     addr = set_prtsel(addr, get_port_sel_bits(iid), get_port_sel_val(iid));
  end     
  `ASSERT(m_inv_sec.randomize());
  if (m_inv_sec.new_cacheline) 
    addr[ncoreConfigInfo::W_SEC_ADDR-1] = ~addr[ncoreConfigInfo::W_SEC_ADDR-1];

  
  ncoreConfigInfo::get_logical_uinfo(iid, lid, cid, utype);
  if (utype == ncoreConfigInfo::AIU) begin
    if(set_index  != -1)begin
       addr = set_prtsel(addr,get_aiu_set_bits(ncoreConfigInfo::get_logical_id(iid)), set_index);
    end
  end

  if($test$plusargs("chi_perf_read_txn_test")) addr[5:0]='0;
  //Save the address generated for a specific agent
  set_addr_in_agent_mem_map(addr, iid);

  `uvm_info($sformatf("%m"), $sformatf("ADDR_MGR: generated C unq address %p", addr), UVM_MEDIUM)
  return addr;
endfunction: unq_coh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : unq_coh_addr_target 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::unq_coh_addr_target(int iid,
                                                                                    int tid,
                                                                                    int core_id=0);

  int mid;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;

  if (!is_routing_legal(get_port_sel_bits(iid), get_port_sel_val(iid),
                        get_port_sel_bits(tid), get_port_sel_val(tid)))
    `uvm_fatal("ADDR MGR", $psprintf(
      "Unable to route any cacheline from initiator:%0d to target:%0d",
      iid, tid))

  mid  = pick_memregion(ncoreConfigInfo::COH, iid);
  addr = get_rand_c_nc_addr(mid,1,iid, core_id);
  addr = rand_crit_wrd(addr);
  `ASSERT(m_inv_sec.randomize());
  if (m_inv_sec.new_cacheline) 
    addr[ncoreConfigInfo::W_SEC_ADDR - 1] = ~addr[ncoreConfigInfo::W_SEC_ADDR -1];

  addr = set_prtsel(addr, get_port_sel_bits(tid), get_port_sel_val(tid));
  //Save the address generated for a specific agent
  set_addr_in_agent_mem_map(addr, iid);

  `uvm_info($sformatf("%m"), $sformatf("ADDR_MGR: generated C target address %p", addr), UVM_MEDIUM)
  return addr;
endfunction: unq_coh_addr_target

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : unq_coh_addr_memrgn
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::unq_coh_addr_memrgn(int iid,
                                                                                    int mid, 
                                                                                    int core_id=0);

  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;

  addr = get_rand_c_nc_addr(mid,1,iid, core_id);
  addr = rand_crit_wrd(addr);
  `ASSERT(m_inv_sec.randomize());
  if (m_inv_sec.new_cacheline) 
    addr[ncoreConfigInfo::W_SEC_ADDR - 1] = ~addr[ncoreConfigInfo::W_SEC_ADDR - 1];

  addr = set_prtsel(addr, get_port_sel_bits(iid), get_port_sel_val(iid));
  //Save the address generated for a specific agent
  set_addr_in_agent_mem_map(addr, iid);

  //`uvm_info($sformatf("%m"), $sformatf("ADDR_MGR: generated C memrgn address %p for core_id:%0d", addr, core_id), UVM_LOW)
  return addr;
endfunction: unq_coh_addr_memrgn

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : unq_coh_addr_tagidx 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::unq_coh_addr_tagidx(ncoreConfigInfo::ncore_unit_type_t utype,
                                                                                    int iid,
                                                                                    int tid,
                                                                                    int set_index, 
                                                                                    int core_id=0);

  int mid;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
  ncoreConfigInfo::sel_bits_t set_sel;

  if (utype == ncoreConfigInfo::AIU) begin
    set_sel = get_aiu_set_bits(ncoreConfigInfo::get_logical_id(tid));
    addr = gen_rand_coh_addr(iid, core_id);
    addr = set_prtsel(addr, get_port_sel_bits(iid), get_port_sel_val(iid));
    addr =  set_prtsel(addr, set_sel, set_index);
    //Save the address generated for a specific agent
    set_addr_in_agent_mem_map(addr, iid);
    return addr;
  end

  if (utype == ncoreConfigInfo::DCE) begin
    set_sel = get_sf_set_bits(tid);

    if (iid == tid) begin
      addr = gen_rand_coh_addr(iid);
      addr = set_prtsel(addr, get_port_sel_bits(iid), get_port_sel_val(iid));
      addr = set_prtsel(addr, set_sel, set_index);
      //Save the address generated for a specific agent
      set_addr_in_agent_mem_map(addr, iid);
      return addr;
    end else begin
      
      if (!is_routing_legal(get_port_sel_bits(iid), get_port_sel_val(iid),
                            set_sel, set_index))
        `uvm_fatal("ADDR MGR", $psprintf(
          "Cannot map address set_index:0x%0h inititaror:%0d sfid:%0d",
          set_index, iid, tid))

      addr = gen_rand_coh_addr(iid);
      addr = set_prtsel(addr, get_port_sel_bits(iid), get_port_sel_val(iid));
      addr = set_prtsel(addr, set_sel, set_index);
      //Save the address generated for a specific agent
      set_addr_in_agent_mem_map(addr, iid);
      return addr;
    end
  end

  if (utype == ncoreConfigInfo::DMI) begin
    set_sel = get_dmi_set_bits(ncoreConfigInfo::get_logical_id(tid));

    if (iid == tid) begin
      //addr = gen_rand_coh_addr(iid);//CONC-11042
      addr = gen_rand_coh_addr(iid, core_id);
      addr = set_prtsel(addr, get_port_sel_bits(iid), get_port_sel_val(iid));
      addr = set_prtsel(addr, set_sel, set_index);
      //Save the address generated for a specific agent
      set_addr_in_agent_mem_map(addr, iid);
      return addr;
    end else begin

      if (!is_routing_legal(get_port_sel_bits(iid), get_port_sel_val(iid),
                            set_sel, set_index))
        `uvm_fatal("ADDR MGR", $psprintf(
          "Cannot map address set_index:0x%0h inititaror:%0d sfid:%0d",
          set_index, iid, tid))

      //addr = gen_rand_coh_addr(iid);//CONC-11042
      addr = gen_rand_coh_addr(iid, core_id);
      addr = set_prtsel(addr, get_port_sel_bits(iid), get_port_sel_val(iid));
      addr = set_prtsel(addr, set_sel, set_index);
      //Save the address generated for a specific agent
      set_addr_in_agent_mem_map(addr, iid);
      return addr;
    end
  end

  `ASSERT(0, "Must not execute this line");
  return 0;
endfunction: unq_coh_addr_tagidx

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : pick_memregion
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function int gen_new_cacheline::pick_memregion(ncoreConfigInfo::addr_format_t mem_type, int agentid =-1);

  return m_map.get_rand_memregion(mem_type, agentid);
endfunction: pick_memregion

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : rand_addr_bound
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] gen_new_cacheline::rand_addr_bound(bit[63:0] min, bit[63:0] max);

  param_gen_value #(bit[63:0]) rval;
  bit [63:0] cacheline;

  rval = param_gen_value #(bit[63:0])::GetInstance();
  rval.set_min_range(min);
  rval.set_max_range(max-1);
  rval.randomize();
  //Generating 64-byte aligned address
  cacheline = ((rval.get_rand_value() >> 6) << 6);
  return cacheline;
endfunction: rand_addr_bound

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : rand_crit_wrd
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] gen_new_cacheline::rand_crit_wrd(bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr);
 
  param_gen_value #(bit[1:0]) rval;
 
  rval = param_gen_value #(bit[1:0])::GetInstance();
  rval.set_min_range(0);
  rval.set_max_range(3);
  rval.randomize();
  addr[5:4] = rval.get_rand_value();

  return addr;
endfunction: rand_crit_wrd

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : set_prtsel
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] gen_new_cacheline::set_prtsel(bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr,
                                                                          ncoreConfigInfo::sel_bits_t bit_idxs,
                                                                          int value); 

  bit [31:0] bval = value;

  if (!value)
    return addr;

  foreach (bit_idxs.pri_bits[idx]) begin
    int q[$];

    q.push_back(bit_idxs.pri_bits[idx]);
    foreach (bit_idxs.sec_bits[idx][cidx])
     if(bit_idxs.sec_bits[idx][cidx] >0)begin
       q.push_back(bit_idxs.sec_bits[idx][cidx]);
     end

    m_cnstrn.num_bits = q.size();
    m_cnstrn.res      = bval[idx];

    `ASSERT(m_cnstrn.randomize());
    foreach (q[kidx])
      addr[q[kidx]] = m_cnstrn.bit_vals[kidx];
  end
  return addr;
endfunction: set_prtsel

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_set_index 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] gen_new_cacheline::get_set_index(int agentid,
                                                                             bit [ncoreConfigInfo::W_SEC_ADDR -1: 0] addr,
                                                                             int tfid = -1);

  int lid, cid;
  ncoreConfigInfo::ncore_unit_type_t utype;
  ncoreConfigInfo::sel_bits_t        psel;
  
  ncoreConfigInfo::get_logical_uinfo(agentid, lid, cid, utype);
  if (utype == ncoreConfigInfo::AIU) begin
`ASSERT(ncoreConfigInfo::get_native_interface(agentid) == ncoreConfigInfo::IO_CACHE_AIU);
    psel = get_aiu_set_bits(ncoreConfigInfo::get_logical_id(agentid));
  end else if (utype == ncoreConfigInfo::DCE) begin
    psel = get_sf_set_bits(tfid);
  end else if (utype == ncoreConfigInfo::DMI) begin
    psel = get_dmi_set_bits(ncoreConfigInfo::get_logical_id(agentid));
  end 

  return calc_set_index(addr, psel);
endfunction: get_set_index

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_port_sel_bits 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::sel_bits_t gen_new_cacheline::get_port_sel_bits(int iid);
  
  int lid, cid;
  ncoreConfigInfo::ncore_unit_type_t utype;
  ncoreConfigInfo::sel_bits_t        psel;

  ncoreConfigInfo::get_logical_uinfo(iid, lid, cid, utype);
  if (utype == ncoreConfigInfo::AIU) begin

    if (ncoreConfigInfo::aiu_port_sel[lid].num_entries == 1)
      return psel;

    psel.pri_bits = new[ncoreConfigInfo::aiu_port_sel[lid].num_pri_bits];
    foreach (ncoreConfigInfo::aiu_port_sel[lid].pri_bits[idx])
      psel.pri_bits[idx] = ncoreConfigInfo::aiu_port_sel[lid].pri_bits[idx];
    return psel;

  end else if(utype == ncoreConfigInfo::DCE) begin

    if (ncoreConfigInfo::dce_port_sel[lid].num_entries <= 2) //RS. 2 DCE needs only 1 primary bit
      return psel;

    psel.pri_bits = new[ncoreConfigInfo::dce_port_sel[lid].num_pri_bits];
    psel.sec_bits = new[ncoreConfigInfo::dce_port_sel[lid].num_pri_bits];

    foreach (ncoreConfigInfo::dce_port_sel[lid].pri_bits[ridx]) begin
      psel.pri_bits[ridx] = ncoreConfigInfo::dce_port_sel[lid].pri_bits[ridx];
   
      if (ncoreConfigInfo::dce_port_sel[lid].sec_bits[ridx].size())
        psel.sec_bits[ridx] = new[
          ncoreConfigInfo::dce_port_sel[lid].sec_bits[ridx].size()];

      foreach (ncoreConfigInfo::dce_port_sel[lid].sec_bits[ridx][cidx])
        psel.sec_bits[ridx][cidx] = 
        ncoreConfigInfo::dce_port_sel[lid].sec_bits[ridx][cidx];
    end
    return psel;

  end else if (utype == ncoreConfigInfo::DMI) begin
    return m_map.get_port_sel_bits(lid, utype);   
  end else if (utype == ncoreConfigInfo::DII) begin
    return psel;  //dii never takes part in interleave group -> psel empty
  end

  `ASSERT(0, "Must not execute this line");
  return psel;
endfunction: get_port_sel_bits

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_port_sel_val
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function  bit[31:0] gen_new_cacheline::get_port_sel_val(int iid);
  int lid, cid;
  ncoreConfigInfo::ncore_unit_type_t utype;

  ncoreConfigInfo::get_logical_uinfo(iid, lid, cid, utype);
  if (utype == ncoreConfigInfo::AIU)
     return ncoreConfigInfo::logical2aiu_prt[lid][cid];

  else if (utype == ncoreConfigInfo::DCE)
     return ncoreConfigInfo::logical2dce_prt[lid][cid];

  else if (utype == ncoreConfigInfo::DMI)
     return ncoreConfigInfo::logical2dmi_prt[lid][cid];

  else if (utype == ncoreConfigInfo::DII)
     return ncoreConfigInfo::logical2dii_prt[lid][cid];

  `ASSERT(0, "Must not execute this line");
  return 0;
endfunction: get_port_sel_val

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : is_routing_legal
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit gen_new_cacheline::is_routing_legal(ncoreConfigInfo::sel_bits_t initiator,
                                                 bit [31:0] initiator_value,
                                                 ncoreConfigInfo::sel_bits_t target,
                                                 bit [31:0] target_value);

  if (initiator.pri_bits.size() == 0 || target.pri_bits.size())
    return 1;

  if (initiator.pri_bits.size() > target.pri_bits.size())
    return ord_rt_lgl(initiator, target, initiator_value, target_value);

  return ord_rt_lgl(target, initiator, target_value, initiator_value);
endfunction: is_routing_legal

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : ord_rt_lgl
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit gen_new_cacheline::ord_rt_lgl(const ref ncoreConfigInfo::sel_bits_t ir,
                                           const ref ncoreConfigInfo::sel_bits_t tr,
                                           input bit [31:0] ival,
                                           input bit [31:0] tval);

  foreach (ir.pri_bits[iidx]) begin
    int iq[$], tq[$];

    if (ival[iidx] != tval[iidx]) begin
      iq.push_back(ir.pri_bits[iidx]);
      tq.push_back(ir.pri_bits[iidx]);

      foreach (ir.sec_bits[iidx][sidx])
        iq.push_back(ir.sec_bits[iidx][sidx]);

      foreach (tr.sec_bits[iidx][sidx])
        tq.push_back(tr.sec_bits[iidx][sidx]);

      if (both_qs_identcl(iq, tq)) 
        return 0;
    end
  end

  return 1;
endfunction: ord_rt_lgl

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : both_qs_identcl 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function gen_new_cacheline::both_qs_identcl(const ref int q1[$], const ref int q2[$]);

  if (q1.size() != q2.size())
    return 0;

  foreach (q1[idx]) begin
    if (q1[idx] != q2[idx])
      return 0;
  end

  return 1;
endfunction: both_qs_identcl

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : both_qs_identcl
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::sel_bits_t gen_new_cacheline::get_sf_set_bits(int id);
  ncoreConfigInfo::sel_bits_t bit_idxs;

  `ASSERT(id < ncoreConfigInfo::sf_set_sel.size() && id >= 0);
  bit_idxs.pri_bits = new[ncoreConfigInfo::sf_set_sel[id].pri_bits.size()];
  bit_idxs.sec_bits = new[ncoreConfigInfo::sf_set_sel[id].pri_bits.size()];

  foreach (ncoreConfigInfo::sf_set_sel[id].pri_bits[pidx]) begin
    bit_idxs.pri_bits[pidx] =  ncoreConfigInfo::sf_set_sel[id].pri_bits[pidx];

    if (ncoreConfigInfo::sf_set_sel[id].sec_bits[pidx].size() > 0) 
      bit_idxs.sec_bits[pidx] = new[
        ncoreConfigInfo::sf_set_sel[id].sec_bits[pidx].size()];

    foreach (ncoreConfigInfo::sf_set_sel[id].sec_bits[pidx][sidx])
      bit_idxs.sec_bits[pidx][sidx] = 
        ncoreConfigInfo::sf_set_sel[id].sec_bits[pidx][sidx];
  end

  return bit_idxs;
endfunction: get_sf_set_bits

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_dmi_set_bits 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::sel_bits_t gen_new_cacheline::get_dmi_set_bits(int id);
  ncoreConfigInfo::sel_bits_t bit_idxs;

  `ASSERT(id < ncoreConfigInfo::cmc_set_sel.size());
  bit_idxs.pri_bits = new[ncoreConfigInfo::cmc_set_sel[id].pri_bits.size()];
  bit_idxs.sec_bits = new[ncoreConfigInfo::cmc_set_sel[id].pri_bits.size()];

  foreach (ncoreConfigInfo::cmc_set_sel[id].pri_bits[pidx]) begin
    bit_idxs.pri_bits[pidx] =  ncoreConfigInfo::cmc_set_sel[id].pri_bits[pidx];

    if (ncoreConfigInfo::cmc_set_sel[id].sec_bits[pidx].size() > 0) 
      bit_idxs.sec_bits[pidx] = new[
        ncoreConfigInfo::cmc_set_sel[id].sec_bits[pidx].size()];

    foreach (ncoreConfigInfo::cmc_set_sel[id].sec_bits[pidx][sidx])
      bit_idxs.sec_bits[pidx][sidx] = 
        ncoreConfigInfo::cmc_set_sel[id].sec_bits[pidx][sidx];
  end

  return bit_idxs;
endfunction: get_dmi_set_bits

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_aiu_set_bits 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function ncoreConfigInfo::sel_bits_t gen_new_cacheline::get_aiu_set_bits(int id);
  ncoreConfigInfo::sel_bits_t bit_idxs;

  `ASSERT(id < ncoreConfigInfo::cbi_set_sel.size());
  bit_idxs.pri_bits = new[ncoreConfigInfo::cbi_set_sel[id].pri_bits.size()];
  bit_idxs.sec_bits = new[ncoreConfigInfo::cbi_set_sel[id].pri_bits.size()];

  foreach (ncoreConfigInfo::cbi_set_sel[id].pri_bits[pidx]) begin
    bit_idxs.pri_bits[pidx] =  ncoreConfigInfo::cbi_set_sel[id].pri_bits[pidx];

    if (ncoreConfigInfo::cbi_set_sel[id].sec_bits[pidx].size() > 0) 
      bit_idxs.sec_bits[pidx] = new[
        ncoreConfigInfo::cbi_set_sel[id].sec_bits[pidx].size()];

    foreach (ncoreConfigInfo::cbi_set_sel[id].sec_bits[pidx][sidx])
      bit_idxs.sec_bits[pidx][sidx] = 
        ncoreConfigInfo::cbi_set_sel[id].sec_bits[pidx][sidx];
  end

  return bit_idxs;
endfunction: get_aiu_set_bits

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : init_addr_collison_pct 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void gen_new_cacheline::init_addr_collison_pct();
  int lid, cid, utype; 

  m_addr_hit = new[ncoreConfigInfo::NUM_AGENTS];
  for (int i = 0; i < ncoreConfigInfo::NUM_AGENTS; i++) begin
    m_addr_hit[i] = new();
    ncoreConfigInfo::get_logical_uinfo(i, lid, cid, utype);

    if (utype == ncoreConfigInfo::AIU) begin
      //Bridge AIU with IO-Cache
      if (ncoreConfigInfo::get_native_interface(i) == ncoreConfigInfo::IO_CACHE_AIU)
        m_addr_hit[i].set_posb(70);
      //Bridge AIU without IO-Cache
      else if (
        (ncoreConfigInfo::get_native_interface(i) == ncoreConfigInfo::AXI_AIU)      ||
        (ncoreConfigInfo::get_native_interface(i) == ncoreConfigInfo::ACE_LITE_AIU) ||
        (ncoreConfigInfo::get_native_interface(i) == ncoreConfigInfo::ACE_LITE_E_AIU)) 

         m_addr_hit[i].set_posb(50);

      //ACE or ACE-LITE AIU 
      else
         m_addr_hit[i].set_posb(0);

    end else if (utype == ncoreConfigInfo::DCE) begin
      m_addr_hit[i].set_posb(0);

    end else if (utype == ncoreConfigInfo::DMI) begin
      int id = i - ncoreConfigInfo::NUM_AIUS -ncoreConfigInfo::NUM_DCES;
      if (ncoreConfigInfo::dmis_with_cmc[id])
        m_addr_hit[i].set_posb(70);
      else
        m_addr_hit[i].set_posb(0);

    end else begin
      m_addr_hit[i].set_posb(0);
    end
  end
endfunction: init_addr_collison_pct

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : addr_map_succ 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit gen_new_cacheline::addr_map_succ(int agentid, 
                                              bit collision,
                                              bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr, 
                                              int core_id=0);

  bit [63:0] key;
  bit [11:0] agt;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] tmp_addr;
  int primary_bits[$] = ncoreConfigInfo::mp_aiu_intv_bits[agentid].pri_bits;
  
  agt = agentid;
  key = (agt << ncoreConfigInfo::W_SEC_ADDR) | addr;
  key = (key >> 6) << 6;

  if (primary_bits.size()) begin
    tmp_addr = ncoreConfigInfo::update_addr_for_core(addr,agentid, core_id);
    if (tmp_addr != addr)
      return 0;
    //else 
    //   `uvm_info("ADDR_DBG", $sformatf("fn:gen_new_cacheline-addr_map_success tmp_addr matches addr for core_id:%0d", addr), UVM_LOW)
  end

  if (collision) begin
    if (addr_present_ncore(key))
      return 1;
    else
      return 0;
  end
  
  //If collision is set to 0 then return 0 if address is present 
  //in ncore system. opposite of above
  addr_map_succ = !addr_present_ncore(key);
  <%if(obj.testBench =='dce' && obj.initiatorGroups.length > 1){%>
  if(ncoreConfigInfo::check_dmi_is_unconnected(addr))
      return 0;
  <%}

   if ((obj.testBench == "fsys" || (obj.testBench === "cust_tb") || obj.testBench == "emu" || obj.testBench =='io_aiu' || obj.testBench =='chi_aiu') && obj.initiatorGroups.length >= 1) { %>
  if(!test_connectivity_test && ncoreConfigInfo::check_unmapped_add(addr, agentid, unit_unconnected))
    return 0;
  else  <%}%>
    return addr_map_succ;
 
endfunction: addr_map_succ

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : addr_present_ncore 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit gen_new_cacheline::addr_present_ncore(bit [63:0] key);
  if (m_agent_mem_map.exists(key)) begin
    if (m_agent_mem_map[key] > 0)
      return 1;
    else
      return 0;
  end
  return 0;
endfunction: addr_present_ncore

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : set_addr_in_agent_mem_map 
// Description: Save the address generated for a specific agent
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void gen_new_cacheline::set_addr_in_agent_mem_map(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,
                                                           int initiator_agentid);
  
  bit [63:0] key;
  key = initiator_agentid;
  key = (key << ncoreConfigInfo::W_SEC_ADDR) | addr;
  //Address stored are 64-byte aligned
  key = (key >> 6) << 6;

  if (m_agent_mem_map.exists(key))
    m_agent_mem_map[key] = m_agent_mem_map[key]++;
  else
    m_agent_mem_map[key] = 1;

  //Enable commented line for debugging
  `uvm_info("ADDR MGR DBG", $psprintf("set_addr_in_agent_mem_map - agent-id:%0d addr:0x%0h key:0x%0h, count:%0d",
     initiator_agentid, addr, key, m_agent_mem_map[key]), UVM_MEDIUM)
endfunction: set_addr_in_agent_mem_map

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : gen_rand_coh_addr 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR-1:0] gen_new_cacheline::gen_rand_coh_addr(int iid, int core_id=0);

  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr;
  int mid;

  mid  = pick_memregion(ncoreConfigInfo::COH, iid);
  addr = get_rand_c_nc_addr(mid, 1, iid, core_id);
  addr = rand_crit_wrd(addr);
  `ASSERT(m_inv_sec.randomize());
  if (m_inv_sec.new_cacheline) 
    addr[ncoreConfigInfo::W_SEC_ADDR - 1] = ~addr[ncoreConfigInfo::W_SEC_ADDR - 1];
  `uvm_info($sformatf("%m"), $sformatf("ADDR_MGR: generated C rand address %p", addr), UVM_MEDIUM)
  return addr;
endfunction: gen_rand_coh_addr

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : calc_set_index
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::calc_set_index(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,
                                                                               const ref ncoreConfigInfo::sel_bits_t bit_idxs);

  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] val;

  foreach (bit_idxs.pri_bits[i]) begin
    val[i] = addr[bit_idxs.pri_bits[i]];
    foreach (bit_idxs.sec_bits[i][j]) begin
      if(bit_idxs.sec_bits[i][j] >0)begin
       val[i] = val[i] ^ addr[bit_idxs.sec_bits[i][j]];
      end
    end
  end

  return (val);
endfunction: calc_set_index

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_region_bounds 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function void gen_new_cacheline::get_region_bounds(input int                              mid,
                                                   output [ncoreConfigInfo::W_SEC_ADDR -1:0] lb,
                                                   output [ncoreConfigInfo::W_SEC_ADDR -1:0] ub );
   
   lb = m_map.lbound(mid);
   ub = m_map.ubound(mid);
endfunction : get_region_bounds

////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : get_rand_c_nc_addr 
//
////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] gen_new_cacheline::get_rand_c_nc_addr(int mid, 
                                                                                   bit c_nc, 
                                                                                   int agentid = -1, 
                                                                                   int core_id=0);
   bit nc_reg_h;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] addr,addr_tested[$];
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] nc_l_ceil, nc_h_bot;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] region_size;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] use_memregion_size = 0;
   int try_count;
   int try_count_total = 100_000;

   if($test$plusargs("use_memregion_size")) begin
      $value$plusargs("use_memregion_size=%d", use_memregion_size);
   end

   nc_l_ceil = m_map.lbound(mid) + (m_map.ubound(mid) - m_map.lbound(mid))/4;
   nc_h_bot  = m_map.ubound(mid) - (m_map.ubound(mid) - m_map.lbound(mid))/4;

   //`uvm_info($sformatf("%m"), $sformatf("ADDRMGR: Picking addr from memregion %0d, upperbound: 0x%0h, lowerbound: 0x%0x", mid, m_map.ubound(mid), m_map.lbound(mid)), UVM_MEDIUM)
   <% if ((obj.testBench == "fsys" || (obj.testBench === "cust_tb") || obj.testBench == "emu" || obj.testBench =='io_aiu' || obj.testBench =='chi_aiu') && obj.initiatorGroups.length >= 1) { %>
   try_count = try_count_total; 
   do begin
    <%}%>
   <% if (obj.testBench == "dce" && obj.initiatorGroups.length > 1) { %>
   try_count = try_count_total; 
   do begin
    <%}%>
    std::randomize(nc_reg_h);
   if (c_nc) begin // Coherent address
      region_size = nc_h_bot - nc_l_ceil;
      if((use_memregion_size > 0) && (use_memregion_size < region_size)) begin
         region_size = use_memregion_size;
      end
      addr = rand_addr_bound(nc_l_ceil, nc_l_ceil + region_size);
   end else begin
      if (merg_c_nc == 0) begin
   if (nc_reg_h) begin
            region_size = m_map.ubound(mid) - nc_h_bot;
            if((use_memregion_size > 0) && (use_memregion_size < region_size)) begin
               region_size = use_memregion_size;
            end
      addr = rand_addr_bound(nc_h_bot, nc_h_bot + region_size);
   end else begin
            region_size = nc_l_ceil - m_map.lbound(mid);
            if((use_memregion_size > 0) && (use_memregion_size < region_size)) begin
               region_size = use_memregion_size;
            end
      addr = rand_addr_bound(m_map.lbound(mid), m_map.lbound(mid)+region_size);
   end
      end else begin
         region_size = m_map.ubound(mid) - m_map.lbound(mid);
         if((use_memregion_size > 0) && (use_memregion_size < region_size)) begin
            region_size = use_memregion_size;
         end
   addr = rand_addr_bound(m_map.lbound(mid), m_map.lbound(mid) + region_size);
      end
   end
   addr = ncoreConfigInfo::update_addr_for_core(addr,agentid, core_id);

  <% if ((obj.testBench == "fsys" || (obj.testBench === "cust_tb") || obj.testBench == "emu" || obj.testBench =='io_aiu' || obj.testBench =='chi_aiu') && obj.initiatorGroups.length >= 1) { %>
  addr_tested.push_back(addr);
  try_count--;
  // #Stimulus.FSYS.connectivity.AddressConnected
end while(try_count!=0 && agentid != -1 && !test_connectivity_test && ncoreConfigInfo::check_unmapped_add(addr, agentid, unit_unconnected));

if(!try_count) begin
  addr_tested.unique(); 
  addr_tested.sort(); 
  `uvm_info("Connectivity Interleaving ADDR MGR", $sformatf("ADDRMGR: No addr found for MID %0d, C_NC %0d Agent_ID %0d after %0d tries", mid, c_nc, agentid, try_count_total), UVM_NONE)
  `uvm_info("Connectivity Interleaving ADDR MGR", $sformatf("ADDRMGR: all ADDR already tested %p",addr_tested), UVM_NONE)
  $stacktrace;
  `uvm_error("Connectivity Interleaving ADDR MGR",$sformatf("Not succeed to generate connected address, Hitting possible 0-time infinite loop here"))
end else
  `uvm_info("Connectivity Interleaving ADDR MGR", $sformatf("ADDRMGR: MID %0d, C_NC %0d Agent_ID %0d after %0d tries NEW addr found", mid, c_nc, agentid, (try_count_total - try_count)), UVM_DEBUG)
<%}
   if (obj.testBench == "dce" && obj.initiatorGroups.length > 1) { %>
  addr_tested.push_back(addr);
  try_count--;
end while(try_count!=0 && agentid != -1 && ncoreConfigInfo::check_dmi_is_unconnected(addr));

if(!try_count) begin
  addr_tested.unique(); 
  /*addr_tested.sort(); 
  `uvm_info("Connectivity Interleaving ADDR MGR", $sformatf("ADDRMGR: No addr found for MID %0d, C_NC %0d Agent_ID %0d after %0d tries", mid, c_nc, agentid, try_count_total), UVM_NONE)
  `uvm_info("Connectivity Interleaving ADDR MGR", $sformatf("ADDRMGR: all ADDR already tested %p",addr_tested), UVM_NONE)
  `uvm_error("Connectivity Interleaving ADDR MGR",$sformatf("Not succeed to generate connected address, Hitting possible 0-time infinite loop here",))*/
end else
  `uvm_info("Connectivity Interleaving ADDR MGR", $sformatf("ADDRMGR: MID %0d, C_NC %0d Agent_ID %0d after %0d tries NEW addr found", mid, c_nc, agentid, (try_count_total - try_count)), UVM_DEBUG)

   <%}%>

   `uvm_info($sformatf("%m"), $sformatf("ADDRMGR: NEW %s addr %p for core_id:%0d", c_nc?"COH":"NCOH", addr, core_id), UVM_DEBUG)
   return addr;
endfunction : get_rand_c_nc_addr
//End of file
