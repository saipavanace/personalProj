class resource_manager extends uvm_object;
  //UVM Factory
  `uvm_object_param_utils(resource_manager)

  string LABEL = "resource_manager";

  dmi_cmd_args m_args;

  //Resources --Begin
  addr_trans_mgr m_addr_mgr;
  dmi_table m_table[$];  
  dmi_addr_format_t addr_q_type[$] = {COH,NONCOH};
  ncoreConfigInfo::addrq m_addr_q[dmi_addr_format_t];
  ncoreConfigInfo::addrq m_secondary_addr_q[dmi_addr_q_format_t][dmi_addr_format_t];
  ncoreConfigInfo::addrq m_tertiary_addr_q[dmi_addr_q_format_t][dmi_addr_format_t];
  int                    addr_collision_q[$];
  bit                    used_cohrbid_q[smi_rbid_t];
  rbid_table_t           rbid_table[COH_RBID_SIZE*2];
  smi_rbid_q             available_rbid_q;
  bit [COH_RBID_SIZE-1:0] gid0_rb_status, gid1_rb_status, gid_rb_status;
  smi_rbid_t             rbid_release_q[$];
  bit credit_table[dmi_credit_table_type_t][];
  aiu_table_t aiu_table[NUM_AIUS][2**SMI_MSG_WIDTH];
  dce_table_t dce_table[NUM_DCES][2**SMI_MSG_WIDTH];
  aiu_id_t aiu_msg_id_q[$];
  dce_id_t dce_msg_id_q[$];
  dmi_exclusive_c load_exclusives_q[$];
  addr_status_item addr_governor[smi_addr_t];
  dmi_delay_t aiu_delay_type = FILL;
  dmi_delay_t smi_delay_type = FILL;
  dmi_delay_t dispatch_delay_type = FILL;
  int burst_size = CMD_SKID_BUF_SIZE;
  int MIN_AIU_TABLE_REQUIRED = 1;
  int MIN_DCE_TABLE_REQUIRED = 1;
  //Resources --End

  //Non-random variables --Begin
  smi_addr_t axi_width_mask;
  smi_ncore_unit_id_bit_t home_dce_unit_id, home_dmi_unit_id;
  smi_ncore_unit_id_bit_t dcefunitID[NUM_DCES];
  static bit addr_q_initialized[dmi_addr_q_format_t] = '{default: 0};
  static int eval_dependency_count=0;
  static int pkt_uid;
  static int rls_credit_cnt, rsrv_credit_cnt;
  static int gen_SP_cnt;
  <% if (obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) { %>
  static bit [31:0] addrTransV[4];
  static bit [31:0] addrTransFrom[4];
  static bit [31:0] addrTransTo[4];
  <% } %>
  smi_addr_t sp_base_addr_i, sp_roof_addr_i, sp_base_addr, sp_roof_addr;
  int sp_size,sp_ways;
  bit sp_exists;
  smi_type_t dependency_free_smi_type_q[$];
  int allowedIntfSize[<%=obj.DmiInfo[obj.Id].nAius%>];
  int allowedIntfSizeActual[<%=obj.DmiInfo[obj.Id].nAius%>];

  //Non-random variables --End

  //Functions
  extern function new(string name="resource_manager");
  extern function int get_unique_pkt_uid();
  extern function void print_aiu_table(input uvm_verbosity verbosity=UVM_DEBUG);
  extern function void initialize_aiu_table();
  extern function void print_dce_table(input uvm_verbosity verbosity=UVM_DEBUG);
  extern function void initialize_dce_table();
  extern function void initialize();
  extern function void get_args(ref dmi_cmd_args r_args);
  extern function void gen_addr(traffic_type_pair_t t_info, int _size);
  extern function void gen_addr_reuse(traffic_type_pair_t t_info, int _size);
  extern function void gen_addr_cache_evict();
  extern function void gen_addr_incremental(traffic_type_pair_t t_info, int _size);
  extern function void gen_addr_random(traffic_type_pair_t t_info, int _size);
  extern function void gen_addr_regular(traffic_type_pair_t t_info, int _size);
  extern function bit filter_SP_interleave();
  <% if (obj.DutInfo.useCmc) { %>
  extern function void gen_addr_cache_warmup();
  <% } %>
  extern function void gen_SP_addr();
  extern function smi_addr_t get_SP_addr();
  extern function int get_SP_addr_q_size(traffic_type_pair_t t_info);
  extern function smi_addr_t get_addr(traffic_type_pair_t t_info, bit is_coh_read);
  extern function smi_addr_t get_available_addr(dmi_addr_q_format_t Q_FORMAT, traffic_type_pair_t t_info, int align_size=1, bit is_coh_read=0);
  extern function bit prepare_addr_q(traffic_type_pair_t t_info, int _size);
  extern function int get_m_addr_q_size();
  extern function int get_m_addr_q_size_by_type(traffic_type_pair_t t_info);
  extern function void evict_addr_dependencies(dmi_addr_q_format_t Q_FORMAT, traffic_type_pair_t t_info);
  extern function void evict_addr_dependencies_old(dmi_addr_q_format_t Q_FORMAT, smi_type_t m_opcode, int pyld_alignment_size=1);
  extern function int aiu_table_size();
  extern function bit aiu_table_full();
  extern function bit aiu_table_ready();
  extern function bit is_aiu_entry_available();
  extern function release_aiu_table(aiu_id_t m_item);
  extern function prepare_aiu_msg_ids();
  extern function aiu_id_t get_aiu_msg_id(string msg_type);
  extern function aiu_id_t get_aiu_specific_msg_id(smi_ncore_unit_id_bit_t m_search_aiu_id, string msg_type);
  extern function bit aiu_specific_msg_id_is_available(smi_ncore_unit_id_bit_t m_search_aiu_id);
  extern function int dce_table_size();
  extern function bit dce_table_full();
  extern function bit dce_table_ready(input bit needs_home_dce_id=0, bit check_msg_id_q=0);
  extern function bit is_dce_entry_available();
  extern function release_dce_table(dce_id_t m_item, input bit is_rb=0);
  extern function prepare_dce_msg_ids();
  extern function dce_id_t get_dce_msg_id(string msg_type, input bit get_home_dce_id=0, bit is_rb=0, smi_rbid_t m_rbid=0);
  extern function int find_dce_table_index(dce_id_t m_item);
  extern function int find_dcefunitID_idx(smi_ncore_unit_id_bit_t dce_id);
  extern function int get_max_skid_buf_size(dmi_credit_table_type_t _type);
  extern function bit reserve_credit(dmi_credit_table_type_t _type);
  extern function release_credit_of_type(dmi_credit_table_type_t _type);
  extern function release_credit(smi_msg_type_bit_t msg_type);
  extern function bit credit_table_full(dmi_credit_table_type_t _type);
  extern function int credit_table_count_ones(dmi_credit_table_type_t _type);
  extern function smi_rbid_t reserve_RBID(input bit internal_release=0, drain_mode=0);
  extern function smi_rbid_q evaluate_RB_dependencies(input bit drain_mode=0);
  extern function gen_available_rbids();
  extern function bit all_release_rbid_flips_are_occupied();
  extern function release_RBID(smi_rbid_t m_rbid);
  extern function bit is_RBID_available();
  extern function bit is_RBID_release_resolved();
  extern function bit is_release_RBID(smi_rbid_t m_rbid);
  extern function add_to_LUT(ref smi_seq_item m_item, input int m_id, dmi_pattern_type_t m_pattern);
  extern function print_LUT(input uvm_verbosity verbosity=UVM_LOW);
  extern function print_LUT_line(string _label, int line, int index);
  extern function print_LUT_matches(int idx_q[$]);
  extern function add_to_addr_governor(smi_addr_t m_addr, int uid, dmi_pattern_type_t m_pattern);
  extern function print_addr_governor_info(string _label, int line, smi_addr_t m_addr);
  extern function del_from_addr_governor(smi_addr_t m_addr, int uid);
  extern function update_addr_governor_flags(smi_addr_t m_addr);
  extern function update_addr_governor_flags_with_idx(int m_idx);

  extern function update_LUT(ref smi_seq_item m_item, output resource_semaphore_t computed_outcome);
  extern function delete_LUT(int m_idx, input bit print_full=0);

  extern function add_to_exclusive_q(ref smi_seq_item m_item);
  
  extern function process_nc_cmd_rsp_LUT(ref smi_seq_item m_item, input aiu_id_t m_aiu_entry);
  extern function process_str_LUT(ref smi_seq_item m_item, input aiu_id_t m_aiu_entry);
  extern function process_dtr_LUT(ref smi_seq_item m_item, input aiu_id_t m_aiu_entry);
  extern function process_dtw_rsp_LUT(ref smi_seq_item m_item, input aiu_id_t m_aiu_entry, output resource_semaphore_t computed_outcome);
  extern function process_rb_rsp_LUT(ref smi_seq_item m_item, input aiu_id_t m_aiu_entry);
  extern function process_mrd_rsp_LUT(ref smi_seq_item m_item);

  extern function bit isCoherentRead(smi_type_t msg_type);
  extern function bit isCmdNcCacheOpsMsg(MsgType_t msgType);
  extern function string smi_type_string(smi_type_t msg_type);
  extern function smi_addr_t cl_aligned(smi_addr_t addr);
  extern function bit cl_aligned_match(smi_addr_t lhs, rhs);
  extern function smi_addr_t size_aligned(smi_addr_t addr, int size);
  extern function smi_addr_t zero_extend_d2d_addr(smi_addr_t m_addr);
  //extern function 
endclass

function resource_manager::new(string name = "resource_manager");
  super.new(name);
  initialize();
endfunction : new////////////////////////////////////////////////////////////////////////////////////////////////////

function int resource_manager::get_unique_pkt_uid();
  pkt_uid++;
  return(pkt_uid);
endfunction

function void resource_manager::get_args(ref dmi_cmd_args r_args);
  m_args = r_args;
  m_addr_mgr = addr_trans_mgr::get_instance();
  <% if(obj.DutInfo.useCmc) { %>
  gen_addr_cache_warmup();
  <% } %>
endfunction

function void resource_manager::initialize();
  axi_width_mask = (2**<%=obj.DutInfo.wAddr%>)-1;
  home_dmi_unit_id  = <%=obj.DmiInfo[obj.Id].FUnitId%>;
  foreach(rbid_table[index]) begin
    if(index < COH_RBID_SIZE) begin
      rbid_table[index].rbid = index;
    end
    else begin
      rbid_table[index].rbid = {~index[WSMIRBID-1], index[WSMIRBID-2:0]};
    end
    rbid_table[index].is_used = 0;
    rbid_table[index].is_int_release = 0;
  end
  credit_table[CMD_CT] = new[CMD_SKID_BUF_SIZE];
  credit_table[MRD_CT] = new[MRD_SKID_BUF_SIZE];
  <% for( var i=0;i < obj.DceInfo.length;i++){%>
  dcefunitID[<%=i%>] = <%=obj.DceInfo[i].FUnitId%>;
  <%}%>
  initialize_aiu_table();
  initialize_dce_table();
  dependency_free_smi_type_q = {CMD_RD_NC,CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF,CMD_WR_NC_PTL,CMD_WR_NC_FULL,CMD_WR_ATM};
endfunction


//Resource Allocation Begin///////////////////////////////////////////////////////////////////////////////////////////////////

function int resource_manager::get_max_skid_buf_size(dmi_credit_table_type_t _type);
  int max;
  //Coherent DTW shares the same pool as RBR, 
  //NonCoherent CMD based DMIs are reactive(implied received) and don't need to wait on this credit mechanism.
  case(_type)
    CMD_CT        : max = CMD_SKID_BUF_SIZE;
    MRD_CT        : max = MRD_SKID_BUF_SIZE;
  endcase
  return(max);
endfunction

function bit resource_manager::credit_table_full(dmi_credit_table_type_t _type);
  int skid_buf_max = get_max_skid_buf_size(_type);
  if(credit_table_count_ones(_type) == skid_buf_max) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function int resource_manager::credit_table_count_ones(dmi_credit_table_type_t _type);
  int ones;
  foreach(credit_table[_type][i]) begin
    if(credit_table[_type][i]) begin
      ones++;
    end
  end
  return(ones);
endfunction

function bit resource_manager::reserve_credit(dmi_credit_table_type_t _type);
  int idx_match_q[$];
  bit credit_assigned;
  int skid_buf_max = get_max_skid_buf_size(_type);
  int available_credits = (skid_buf_max - credit_table_count_ones(_type));
  rsrv_credit_cnt++;
  if(available_credits==0) begin
    return(0);
  end
  else begin
    for(int i=0; i < skid_buf_max; i++) begin
      if(!credit_table[_type][i]) begin
        credit_table[_type][i] = 1;
        available_credits--;
        credit_assigned = 1;
        break;
      end
    end
  end
  if(!credit_assigned) begin
     `uvm_error(LABEL,$sformatf("::reserve_credit::(cnt=%0d) Available credits:%0d [Failed to reserve]", rsrv_credit_cnt, available_credits))
     return(0);
  end
  else begin
    `uvm_info(LABEL,$sformatf("::reserve_credit:: (cnt=%0d) %0s Available Credits:%0d Credit Table:(size=%0d)", rsrv_credit_cnt,
                _type.name, available_credits, credit_table_count_ones(_type)),UVM_MEDIUM)
    `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::reserve_credit:: Credit Table:%0p(size=%0d)",
                                                     credit_table[_type],credit_table_count_ones(_type)),UVM_HIGH)
  end
  return(1);
endfunction

function resource_manager::release_credit(smi_msg_type_bit_t msg_type);
  dmi_credit_table_type_t _type;
  case(msg_type)
    NC_CMD_RSP: begin
      _type = CMD_CT;
    end
    MRD_RSP: begin
      _type = MRD_CT;
    end
    RB_RSP,DTW_RSP: begin  //RBID controlled --no credits
      return;
    end
    default: begin
      `uvm_error(LABEL,$sformatf("::release_credit:: Received MsgType:%0h which is not supported yet.",msg_type))
    end
  endcase
  release_credit_of_type(_type);
endfunction

function resource_manager::release_credit_of_type(dmi_credit_table_type_t _type);
  bit status;
  int skid_buf_max;
  rls_credit_cnt++;
  skid_buf_max = get_max_skid_buf_size(_type);
  for(int i=0; i < skid_buf_max; i++) begin
    if(credit_table[_type][i]) begin
      credit_table[_type][i] = 0;
      status = 1;
      break;
    end
  end
  if(!status) begin
    int used = credit_table_count_ones(_type);
    `uvm_error(LABEL,$sformatf("::release_credit:: (cnt=%0d) No credits to release. %0s Credit Table Occupied:%0d Available:%0d",rls_credit_cnt,_type.name,used,get_max_skid_buf_size(_type)-used))
  end
  else begin
    int used = credit_table_count_ones(_type);
    `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::release_credit:: (cnt=%0d) Released %0s. Credit Table Occupied:%0d Available=%0d",rls_credit_cnt,_type.name,used,get_max_skid_buf_size(_type)-used),UVM_HIGH)
  end
endfunction

function int resource_manager::dce_table_size();
  int _size, match_q[$];
  foreach(dce_table[i]) begin
    match_q = dce_table[i].find_index with (item.is_used == 1);
    _size += match_q.size;
  end
  return(_size);
endfunction

function bit resource_manager::dce_table_full();
  if(dce_table_size()==DCE_TABLE_MAX) begin
    return(1);
  end
  else begin
    return(0);  
  end
endfunction

function bit resource_manager::dce_table_ready(input bit needs_home_dce_id=0, bit check_msg_id_q=0);
  int home_match_q[$];
  bit qualify;
  home_match_q = dce_msg_id_q.find_index with(item.dce_id == home_dce_unit_id);
  qualify = (needs_home_dce_id && (home_match_q.size()==0)) ? is_dce_entry_available : 1;
  `uvm_guarded_info(m_args.k_stimulus_debug,"dce_table_ready",$sformatf("home_match_q=%0d, qualify=%0d, needs_home_dce_id:%0d",home_match_q.size,qualify,needs_home_dce_id),UVM_DEBUG)
  if(check_msg_id_q) begin
    return(home_match_q.size()!=0);
  end
 
  if(dce_msg_id_q.size >= MIN_DCE_TABLE_REQUIRED && qualify) begin //Check the dispatch queue first and then move on
    return(1);
  end
  else begin
    case(smi_delay_type)
      FILL:
        begin
          if(DCE_TABLE_MAX-dce_table_size() >= MIN_DCE_TABLE_REQUIRED && qualify)begin
            return(1);
          end
          else begin
            return(0);
          end
        end
      BURST: 
        begin
          if((DCE_TABLE_MAX-dce_table_size()) >= burst_size && qualify)begin
            return(1);
          end
          else begin
            return(0);
          end
        end
    endcase
  end
endfunction
function int resource_manager::aiu_table_size();
  int _size, match_q[$];
  foreach(aiu_table[i]) begin
    match_q = aiu_table[i].find_index with(item.is_used == 1);
    _size += match_q.size;
  end
  return(_size);
endfunction

function bit resource_manager::aiu_table_full();
  if(aiu_table_size()==AIU_TABLE_MAX) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit resource_manager::aiu_table_ready();
  if(aiu_msg_id_q.size >= MIN_AIU_TABLE_REQUIRED) begin //Consume allotted IDs first
    return(1);
  end
  else if(!is_aiu_entry_available) begin
    return(0);
  end
  else begin
    case(aiu_delay_type)
      FILL: //Keep streaming packets as soon as IDs are available
        begin
          if((AIU_TABLE_MAX-aiu_table_size())>=MIN_AIU_TABLE_REQUIRED) begin
            return(1);
          end
          else begin
            return(0);
          end
        end
      BURST: //Queue packets in bursts of burst_size
        begin
          if(burst_size < 2) begin
            `uvm_error(LABEL,$sformatf("Cannot set burst_size to a value %0d < 2", burst_size))
          end
          if((AIU_TABLE_MAX-aiu_table_size()) >= burst_size)begin
            return(1);
          end
          else begin
            return(0);
          end
        end
    endcase
  end
endfunction

function bit resource_manager::is_aiu_entry_available();
  int unused_q[NUM_AIUS][$];
  int index ,match_size, pick_aiu, attempts, elements_added;

  foreach(unused_q[i])begin
    unused_q[i] = aiu_table[i].find_index with(item.is_used == 0);
    match_size += $size(unused_q[i]);
  end
  `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::is_aiu_entry_available:: Matches | nAius:%0d, match_size:%0d, MIN_AIU_TABLE_REQUIRED:%0d",$size(unused_q),match_size,MIN_AIU_TABLE_REQUIRED),UVM_DEBUG)
  if(match_size < MIN_AIU_TABLE_REQUIRED) begin
    return(0);
  end
  else begin
    return(1);
  end
endfunction

function resource_manager::prepare_aiu_msg_ids();
//Based on availability, queue random AIU and SMI MSG IDs to the main resource queue
//Call only when the aiu_table is not full
  int idx_match_q[NUM_AIUS][$];
  int index ,match_size, pick_aiu, attempts, elements_added;

  foreach(idx_match_q[i])begin
    idx_match_q[i] = aiu_table[i].find_index with(item.is_used == 0);
    match_size += $size(idx_match_q[i]);
  end
  `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::prepare_aiu_msg_ids:: Matches | idx_match_q:%0d, match_size:%0d",$size(idx_match_q),match_size),UVM_DEBUG)
  if(match_size == 0) begin
    `uvm_error(LABEL,$sformatf("::prepare_aiu_msg_ids:: Can't get SMI-IDs"))
  end
  else begin
    foreach(idx_match_q[i]) begin
      foreach(idx_match_q[i][j]) begin
        aiu_id_t item;
        item.msg_id = aiu_table[i][idx_match_q[i][j]].msg_id;
        item.aiu_id = aiu_table[i][idx_match_q[i][j]].aiu_id;
        aiu_table[i][idx_match_q[i][j]].is_used = 1;
        `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::prepare_aiu_msg_ids:: Adding AiuId: %0h MsgId:%0h",aiu_table[i][idx_match_q[i][j]].aiu_id,aiu_table[i][idx_match_q[i][j]].msg_id),UVM_DEBUG)
        aiu_msg_id_q.push_back(item);
        elements_added++;
      end
    end
    if(aiu_msg_id_q.size!=0) begin
      `uvm_info(LABEL,$sformatf("::prepare_aiu_msg_ids:: Reserved %0d IDs. aiu_msg_id_q(size=%0d)",elements_added,aiu_msg_id_q.size),UVM_LOW)
      aiu_msg_id_q.shuffle();
    end
    else begin
      `uvm_error(LABEL,$sformatf("::prepare_aiu_msg_ids:: Reserved %0d IDs. aiu_msg_id_q(size=%0d)",elements_added,aiu_msg_id_q.size))
    end
  end
endfunction

function aiu_id_t resource_manager::get_aiu_msg_id(string msg_type);
  aiu_id_t _item;
  if(aiu_msg_id_q.size()==0) begin
    `uvm_error(LABEL,$sformatf("::get_aiu_msg_id:: Attempting to pop an empty queue while construction of %0s", msg_type))
  end
  _item = aiu_msg_id_q.pop_front();
  `uvm_info(LABEL,$sformatf("::get_aiu_msg_id:: Fetching (aiu_id:%0h,msg_id:%0h) for %0s aiu_msg_id_q(size=%0d)",
                                          _item.aiu_id,_item.msg_id,msg_type,aiu_msg_id_q.size),UVM_MEDIUM)
  return(_item);
endfunction

function bit resource_manager::aiu_specific_msg_id_is_available(smi_ncore_unit_id_bit_t m_search_aiu_id);
  int match_q[$];
  match_q = aiu_msg_id_q.find_index with ( item.aiu_id == m_search_aiu_id);
  if(match_q.size()==0) begin
    return(0);
  end
  else begin
    return(1);
  end
endfunction

function aiu_id_t resource_manager::get_aiu_specific_msg_id(smi_ncore_unit_id_bit_t m_search_aiu_id, string msg_type);
  aiu_id_t p_item;
  int match_q[$];

  match_q = aiu_msg_id_q.find_index with ( item.aiu_id == m_search_aiu_id);

  if(aiu_msg_id_q.size()==0 || match_q.size()==0) begin
    `uvm_error(LABEL,$sformatf("::get_aiu_msg_id:: Received %0s for aiu_id:%0d :: aiu_msg_id_q(size=%0d) match_q(size=%0d)",
                                                          msg_type, m_search_aiu_id, aiu_msg_id_q.size(),match_q.size()))
  end
  else begin
    p_item = aiu_msg_id_q[match_q[match_q.size-1]];
    aiu_msg_id_q.delete(match_q[match_q.size-1]);
    return(p_item);
  end
endfunction

function resource_manager::release_aiu_table(aiu_id_t m_item);
  int match_q[$];
  if(m_item.aiu_id >= NUM_AIUS) begin
    `uvm_error(LABEL,$sformatf("::release_aiu_table:: Received an unsupported AiuId:%0h",m_item.aiu_id))
  end
  match_q = aiu_table[m_item.aiu_id].find_index with( (item.msg_id == m_item.msg_id) &&
                                                       item.is_used);
  if(match_q.size == 0 || match_q.size >  1) begin
    print_aiu_table(UVM_MEDIUM);
    `uvm_error(LABEL,$sformatf("::release_aiu_table:: %0d matches found for AiuId:%0h MsgId:%0h",
                                            match_q.size,m_item.aiu_id,m_item.msg_id))
  end
  else begin
    `uvm_info(LABEL,$sformatf("::release_aiu_table:: Releasing AiuId:%0h MsgId:%0h",
                                            m_item.aiu_id,m_item.msg_id),UVM_HIGH)
  end
  aiu_table[m_item.aiu_id][match_q[0]].is_used = 0;
endfunction


function bit resource_manager::is_dce_entry_available();
  int unused_q[NUM_DCES][$];
  int index ,match_size, pick_aiu, attempts, elements_added;
  bit [NUM_DCES-1:0] one_id_per_dce;
  bit home_dce_id_available;
  foreach(unused_q[i])begin
    unused_q[i] = dce_table[i].find_index with(item.is_used == 0);
    match_size += $size(unused_q[i]);
    if($size(unused_q[i]) > 0 && !home_dce_id_available) begin
      home_dce_id_available = (dce_table[i][unused_q[i][0]].dce_id == home_dce_unit_id) ? 1 : 0;
    end
    one_id_per_dce[i] = ($size(unused_q[i]) > 0) ? 1 : 0;
  end
  `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::is_dce_entry_available:: home_dce:%0d avail:%0b",home_dce_unit_id,home_dce_id_available),UVM_DEBUG)
  `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::is_dce_entry_available:: Matches:%0d MIN_DCE_TABLE_REQUIRED:%0d",match_size,MIN_DCE_TABLE_REQUIRED),UVM_DEBUG)
  if(match_size == 0 || !home_dce_id_available) begin
    return(0);
  end
  else begin
    return(1);
  end
endfunction 

function dce_id_t resource_manager::get_dce_msg_id(string msg_type, input bit get_home_dce_id=0, bit is_rb=0, smi_rbid_t m_rbid=0);
  dce_id_t _item;
  if(dce_msg_id_q.size()==0) begin
    `uvm_error(LABEL,$sformatf("::get_dce_msg_id:: Attempting to pop an empty queue %0s",msg_type))
  end
  if(get_home_dce_id) begin
    int match_q[$], last_idx;
    match_q = dce_msg_id_q.find_index with (item.dce_id == home_dce_unit_id);
    if(match_q.size()==0) begin
      print_dce_table(UVM_MEDIUM);
      `uvm_error(LABEL,$sformatf("::get_dce_msg_id:: Couldn't find any available Msg-IDs for DceId:%0d Type:%0s dec_msg_id_q(size=%0d)", home_dce_unit_id,msg_type,dce_msg_id_q.size))
    end
    last_idx = match_q.size()-1;
    _item = dce_msg_id_q[match_q[last_idx]];
    `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::get_dce_msg_id:: Home DCE ID match_q:%0d last_idx:%0d",match_q.size(),last_idx),UVM_HIGH)
    dce_msg_id_q.delete(match_q[last_idx]);
  end
  else begin
    _item = dce_msg_id_q.pop_front();
  end
  if(is_rb) begin //Insert RBID tag to match responses
    int dce_idx = find_dcefunitID_idx(_item.dce_id);
    int idx = find_dce_table_index(_item);
    dce_table[dce_idx][idx].rbid = m_rbid;
  end
  `uvm_info(LABEL,$sformatf("::get_dce_msg_id:: Fetching (dce_id:%0h,msg_id:%0h) dce_msg_id_q(size=%0d)",_item.dce_id,_item.msg_id,dce_msg_id_q.size),UVM_MEDIUM)
  return(_item);
endfunction

function int resource_manager::find_dce_table_index(dce_id_t m_item);
  int match_q[$];
  int dce_idx = find_dcefunitID_idx(m_item.dce_id);
  match_q = dce_table[dce_idx].find_index with (item.dce_id == m_item.dce_id &&
                                 item.msg_id == m_item.msg_id &&
                                 item.rbid == -1);
  if(match_q.size()==1) begin
    `uvm_info(LABEL,$sformatf("::dce_index:: %0p is at index:%0d",m_item, match_q[0]),UVM_DEBUG)
  end
  else begin
    print_dce_table(UVM_MEDIUM);
    `uvm_error(LABEL,$sformatf("::dce_index:: Found %0d matches for dce_table[%0d] = %0p, fix your calling method.",match_q.size, dce_idx, m_item))
  end
  return(match_q[0]);
endfunction

function resource_manager::prepare_dce_msg_ids();
//Based on availability, queue random DCE and SMI MSG IDs to the main resource queue
//Call only when the dce_table is not full
  int unused_idx_q[NUM_DCES][$];
  int index ,match_size, pick_aiu, attempts, elements_added;

  foreach(unused_idx_q[i])begin
    unused_idx_q[i] = dce_table[i].find_index with(item.is_used == 0);
    match_size += $size(unused_idx_q[i]);
  end
  `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::prepare_dce_msg_ids:: Matches | unused_idx_q:%0d, match_size:%0d",$size(unused_idx_q),match_size),UVM_DEBUG)
  if(match_size == 0) begin
    `uvm_error(LABEL,$sformatf("::prepare_dce_msg_ids:: Can't get SMI-IDs"))
  end
  else begin
    foreach(unused_idx_q[i]) begin
      foreach(unused_idx_q[i][j]) begin
        dce_id_t item;
        item.msg_id = dce_table[i][unused_idx_q[i][j]].msg_id;
        item.dce_id = dce_table[i][unused_idx_q[i][j]].dce_id;
        dce_table[i][unused_idx_q[i][j]].is_used = 1;
        `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::prepare_dce_msg_ids:: Adding DceId: %0h MsgId:%0h",dce_table[i][unused_idx_q[i][j]].dce_id,dce_table[i][unused_idx_q[i][j]].msg_id),UVM_DEBUG)
        dce_msg_id_q.push_back(item);
        elements_added++;
      end
    end
    if(dce_msg_id_q.size!=0) begin
      `uvm_info(LABEL,$sformatf("::prepare_dce_msg_ids:: Reserved %0d IDs. dce_msg_id_q(size=%0d)",elements_added,dce_msg_id_q.size),UVM_LOW)
      //dce_msg_id_q.shuffle(); //Remember this might make debug hard during bringup FIXME
    end
    else begin
      `uvm_error(LABEL,$sformatf("::prepare_dce_msg_ids:: Reserved %0d IDs. dce_msg_id_q(size=%0d)",elements_added,dce_msg_id_q.size))
    end
  end
endfunction

function int resource_manager::find_dcefunitID_idx(smi_ncore_unit_id_bit_t dce_id);
  foreach(dcefunitID[i]) begin
    if(dcefunitID[i]==dce_id) begin
      return(i);
    end
  end
  `uvm_error(LABEL,$sformatf("::find_dcefunitID_idx:: Received an unsupported DCE_ID:%0h",dce_id))
endfunction
function resource_manager::release_dce_table(dce_id_t m_item, input bit is_rb=0);
  int match_q[$];
  int dce_idx = find_dcefunitID_idx(m_item.dce_id);
  if(is_rb) begin
    match_q = dce_table[dce_idx].find_index with( item.rbid   == m_item.rbid   &&
                                                  item.dce_id == m_item.dce_id &&
                                                  item.is_used);
  end
  else begin
    match_q = dce_table[dce_idx].find_index with( item.msg_id == m_item.msg_id &&
                                                  item.dce_id == m_item.dce_id &&
                                                  item.is_used);
  end
  if(match_q.size == 0 || match_q.size >  1) begin
    print_dce_table(UVM_MEDIUM);
    `uvm_error(LABEL,$sformatf("::release_dce_table:: %0d matches found for DceId:%0h (idx=%0d) MsgId:%0h",
                                            match_q.size,m_item.dce_id,dce_idx,m_item.msg_id))
  end
  else begin
    `uvm_info(LABEL,$sformatf("::release_dce_table:: Releasing DceId:%0h MsgId:%0h",
                                            m_item.dce_id,m_item.msg_id),UVM_HIGH)
  end
  dce_table[dce_idx][match_q[0]].is_used =  0;
  dce_table[dce_idx][match_q[0]].rbid    = -1;
endfunction

function void resource_manager::initialize_aiu_table(); 
  foreach(aiu_table[i]) begin
    foreach(aiu_table[i][j]) begin
      aiu_table[i][j].is_used = 0;
      aiu_table[i][j].aiu_id = i;
      aiu_table[i][j].msg_id = j;
    end
  end
endfunction

function void resource_manager::initialize_dce_table();
  foreach(dce_table[i]) begin
    foreach(dce_table[i][j]) begin
      dce_table[i][j].is_used = 0;
      dce_table[i][j].dce_id  = dcefunitID[i];
      dce_table[i][j].msg_id  = j;
      dce_table[i][j].rbid    =-1;
    end
  end
endfunction

function void resource_manager::print_dce_table(input uvm_verbosity verbosity=UVM_DEBUG);
  `uvm_info(LABEL,"===============================================dce_table===========================================",verbosity)
  `uvm_info(LABEL,$sformatf("= dce_msg_id_q(size=%0d)                                                                          =",dce_msg_id_q.size),verbosity)
  foreach(dce_table[i])begin
    `uvm_info(LABEL,$sformatf("---------------------------dce_table[%0d]----------------------begin",i),verbosity)
    foreach(dce_table[i][j])begin
      `uvm_info(LABEL,$sformatf("[%0d]=dce_id:%0h msg_id:%06h rbid:%0h (used=%0b)",
                                   j,dce_table[i][j].dce_id,dce_table[i][j].msg_id,dce_table[i][j].rbid,dce_table[i][j].is_used),verbosity)
    end
  end
  `uvm_info(LABEL,"===============================================dce_table===========================================",verbosity)
endfunction

function void resource_manager::print_aiu_table(input uvm_verbosity verbosity=UVM_DEBUG);
  `uvm_info(LABEL,"===============================================aiu_table===========================================",verbosity)
  `uvm_info(LABEL,$sformatf("= aiu_msg_id_q(size=%0d)                                                                          =",aiu_msg_id_q.size),verbosity)
  foreach(aiu_table[i])begin
    `uvm_info(LABEL,$sformatf("---------------------------aiu_table[%0d]----------------------begin",i),verbosity)
    foreach(aiu_table[i][j])begin
      `uvm_info(LABEL,$sformatf("[%0d]=aiu_id:%0h msg_id:%06h  (used=%0b)",
                                   j,aiu_table[i][j].aiu_id,aiu_table[i][j].msg_id,aiu_table[i][j].is_used),verbosity)
    end
  end
  `uvm_info(LABEL,"===============================================aiu_table===========================================",verbosity)
endfunction

function bit resource_manager::prepare_addr_q(traffic_type_pair_t t_info, int _size);
  //Check if you can generate an address and evaluate dependencies out
  gen_addr(t_info,_size*2);

  if(m_addr_q[t_info.addr_type].size >= _size) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function int resource_manager::get_m_addr_q_size();
  int size;
  foreach(m_addr_q[_type]) begin
    size += m_addr_q[_type].size();
  end
  `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::m_addr_q_size:: size:%0d",size),UVM_HIGH)
  return(size);
endfunction
/*
function bit resource_manager::is_one_address_available(traffic_type_pair_t t_info);
  //Check if at least one address is available
endfunction*/

function int resource_manager::get_m_addr_q_size_by_type(traffic_type_pair_t t_info);
  int size;
  bit is_coh_read = isCoherentRead(t_info.smi_type);
  evict_addr_dependencies(REGULAR,t_info);
  size = m_addr_q[t_info.addr_type].size();
  `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::m_addr_q_size:: type:%0s isCohRead:%0b size:%0d",t_info.addr_type.name,is_coh_read,size),UVM_HIGH)
  return(size);
endfunction

function smi_addr_t resource_manager::get_SP_addr();
  smi_addr_t m_addr;
  int m_index;
  <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
  m_addr = zero_extend_d2d_addr(m_secondary_addr_q[SCRATCHPAD][COH].pop_front());
  m_secondary_addr_q[SCRATCHPAD][COH].push_back(m_addr);
  m_index = (m_addr - sp_base_addr_i) >> CCP_CL_OFFSET;
  `uvm_info(LABEL,$sformatf("::get_SP_addr:: Using Addr:'h%0h index:'d%0d",m_addr,m_index),UVM_HIGH)
  return(m_addr);
  <% } else {%>
  `uvm_error(LABEL,"::get_SP_addr:: No Scratchpad in this configuration")
  <% } %>
endfunction

function int resource_manager::get_SP_addr_q_size(traffic_type_pair_t t_info);
  <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
  evict_addr_dependencies(SCRATCHPAD,t_info);
  if(m_secondary_addr_q[SCRATCHPAD][COH].size()==0) begin
    gen_SP_addr();
    evict_addr_dependencies(SCRATCHPAD,t_info); 
    if(m_secondary_addr_q[SCRATCHPAD][COH].size()==0) begin
      `uvm_warning(LABEL,$sformatf("::get_SP_addr_q_size:: %0d attempt at populating SP queue returns 0.",gen_SP_cnt))
    end
  end
  return(m_secondary_addr_q[SCRATCHPAD][COH].size());
  <% } else {%>
  `uvm_error(LABEL,"::get_SP_addr_q_size:: No Scratchpad in this configuration")
  <% } %>
endfunction

function smi_addr_t resource_manager::get_addr(traffic_type_pair_t t_info, bit is_coh_read);
  smi_addr_t _addr, addr_caddy;
  int trans_idx;
  bit trans_flag;
  bit [3:0] mask;
  bit useCmc = <%=obj.DutInfo.useCmc%>;
  bit choose_evict_addr = useCmc ? ( ($urandom_range(1,100) <= m_args.wt_ccp_evict_addr.get_value()) && (t_info.addr_type==COH) ) : 0;
  bit choose_regular_addr = ~choose_evict_addr;
  int data_alignment_size = t_info.payload_size;
  if(t_info.pattern_type == DMI_CACHE_WARMUP_p) begin
    _addr = zero_extend_d2d_addr(m_addr_q[CACHE_WARMUP].pop_front());
    m_addr_q[CACHE_WARMUP].push_back(_addr);
    `uvm_info(LABEL,$sformatf("::get_addr:: Using Cache Warmup | Addr:'h%0h Type:%0s ",_addr, t_info.addr_type.name),UVM_HIGH)
  end
  else begin
    if(choose_evict_addr) begin //Evaluate dependencies and rest expectations
      evict_addr_dependencies(CACHE_EVICT,t_info);
      if(m_secondary_addr_q[CACHE_EVICT][COH].size == 0 && addr_q_initialized[CACHE_EVICT]) begin
        m_secondary_addr_q[CACHE_EVICT][COH] = m_tertiary_addr_q[CACHE_EVICT][COH];
        evict_addr_dependencies(CACHE_EVICT,t_info);
        if(m_secondary_addr_q[CACHE_EVICT][COH].size == 0 && addr_q_initialized[CACHE_EVICT]) begin
          `uvm_info(LABEL,$sformatf("::get_addr:: Attempt to reuse queue resulted in full evictions | m_secondary_addr_q[CACHE_EVICT] size:0 "),UVM_MEDIUM)
          choose_evict_addr   = 0;
        end
        else begin
          choose_evict_addr   = 1;
        end
        choose_regular_addr = ~choose_evict_addr;
      end
    end
    if(choose_evict_addr) begin
      t_info.addr_type = COH;
      _addr = zero_extend_d2d_addr(get_available_addr(CACHE_EVICT,t_info,data_alignment_size,is_coh_read));
      //_addr = m_secondary_addr_q[CACHE_EVICT][COH].pop_front();
      
      `uvm_info(LABEL,$sformatf("::get_addr:: Using Evict Addr:'h%0h Type:COH ",_addr),UVM_HIGH)
    end
    if(choose_regular_addr) begin
      if(m_addr_q[t_info.addr_type].size == 0) begin
        `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::get_addr:: Fix resources allocation in vseq | m_addr_q size 0 %0p",t_info),UVM_MEDIUM)
      end
      _addr = zero_extend_d2d_addr(get_available_addr(REGULAR,t_info,data_alignment_size,is_coh_read));
      //_addr = m_addr_q[t_info.addr_type].pop_front();
    end
    <% if (obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) { %>
    if(m_args.k_translate_addresses && !choose_evict_addr) begin
      for(int itr=0; itr<4; itr++) begin
        trans_idx = $urandom_range(0,3);
        if(addrTransV[trans_idx][31]==1) begin
          trans_flag = 1;
          break;
        end
      end
      if(trans_flag) begin
        addr_caddy = _addr;
        mask = addrTransV[trans_idx] & 4'hf;
        _addr = ( (addrTransFrom[trans_idx] >> mask) << (20+mask) );
        _addr +=  $urandom_range((2**(20+mask))-1,0);
      end
      `uvm_info(LABEL,$sformatf("::get_addr:: Using translated Addr:'h%0h derived from Addr:'h%0h Type:%0s TransFlag:%0b",_addr, addr_caddy, t_info.addr_type.name,trans_flag),UVM_HIGH)
    end
    else if(!choose_evict_addr) begin
      `uvm_info(LABEL,$sformatf("::get_addr:: Using Addr:'h%0h Type:%0s ",_addr, t_info.addr_type.name),UVM_HIGH)
    end
    <% } else { %>
    if(!choose_evict_addr) begin
      `uvm_info(LABEL,$sformatf("::get_addr:: Using Addr:'h%0h Type:%0s ",_addr, t_info.addr_type.name),UVM_HIGH)
    end
    <% } %>
  end
  return(_addr);
endfunction

function void resource_manager::gen_addr(traffic_type_pair_t t_info, int _size);
  <% if (obj.DutInfo.useCmc) { %>
  if(!addr_q_initialized[CACHE_EVICT]) begin
    gen_addr_cache_evict();
  end
  <%}%>
  case(m_args.k_addr_q_type)
    REUSE: begin
      gen_addr_reuse(t_info,_size);
    end
    CACHE_EVICT: begin
      `uvm_error(LABEL,"::gen_addr:: specifying CACHE_EVICT as +k_addr_q_type doesn't achieve anything, set wt_ccp_evict_addr > 0 instead")
    end
    INCREMENTAL: begin
      gen_addr_incremental(t_info,_size);
    end
    RANDOM: begin
      gen_addr_random(t_info,_size);
    end
    REGULAR: begin 
      gen_addr_regular(t_info,_size);
    end
    default: begin
      `uvm_error(LABEL,$sformatf("::gen_addr:: Received unsupported k_addr_q_type:%0s",m_args.k_addr_q_type.name))
    end
  endcase
endfunction

function void resource_manager::gen_addr_reuse(traffic_type_pair_t t_info, int _size); //Reuse addresses only
  //First attempt initialize the address queue and then keep reusing the addresses 
  if(addr_q_initialized[REUSE] == 1) begin
    int init_size = m_addr_q[t_info.addr_type].size;
    m_addr_q[t_info.addr_type] = {m_addr_q[t_info.addr_type],m_secondary_addr_q[REUSE][t_info.addr_type]};
    //FIXME evict_addr_dependencies_old(REGULAR,t_info.smi_type);
    evict_addr_dependencies(REGULAR,t_info);
    `uvm_info(LABEL,$sformatf("::gen_addr_reuse:: %0s Size | Initial:%0d Current:%0d Secondary:%0d",t_info.addr_type.name, init_size,m_addr_q[t_info.addr_type].size,m_secondary_addr_q[REUSE][t_info.addr_type].size),UVM_DEBUG)
  end
  else begin
    foreach(addr_q_type[itr]) begin
      t_info.addr_type=addr_q_type[itr];
      gen_addr_regular(t_info,_size);
      evict_addr_dependencies(REGULAR,t_info);
      if(m_addr_q[addr_q_type[itr]].size == 0) begin
        `uvm_error(LABEL,$sformatf("::gen_addr_reuse:: Populating and evicting for m_addr_q[%0s] returns (Size=0)",addr_q_type[itr].name))
      end
      else begin
        `uvm_info(LABEL,$sformatf("::gen_addr_reuse:: Populating and evicting for m_addr_q[%0s] returns (Size=%0d)",addr_q_type[itr].name,m_addr_q[addr_q_type[itr]].size),UVM_DEBUG)
      end
      m_secondary_addr_q[REUSE][addr_q_type[itr]] = m_addr_q[addr_q_type[itr]];
    end
    addr_q_initialized[REUSE] = 1;
  end
endfunction

function void resource_manager::gen_addr_cache_evict();
  //Initialized once and reused. Same set address to target cache evictions, ties in with wt_ccp_evict_addr > 0
  if(m_secondary_addr_q[CACHE_EVICT][COH].size() == 0 && !addr_q_initialized[CACHE_EVICT]) begin
    m_addr_mgr.set_dmi_smc_fix_index_in_user_addrq(<%=obj.DmiInfo[obj.Id].nUnitId%>,m_secondary_addr_q[CACHE_EVICT][COH],1);
    m_tertiary_addr_q[CACHE_EVICT][COH] = m_secondary_addr_q[CACHE_EVICT][COH];
    addr_q_initialized[CACHE_EVICT] = 1'b1;
    `uvm_info(LABEL,$sformatf("::gen_addr_cache_evict:: Generated same set address queue of size %0d to target evictions on COH",m_secondary_addr_q[CACHE_EVICT][COH].size()),UVM_LOW)
  end
  else begin
    `uvm_warning(LABEL,$sformatf("::gen_addr_cache_evict:: COH eviction queue skipping generation. Generate once and reuse tertiary_q:%0d",m_tertiary_addr_q[CACHE_EVICT][COH].size()))
  end
endfunction

function void resource_manager::gen_addr_incremental(traffic_type_pair_t t_info, int _size);
endfunction

function void resource_manager::gen_addr_random(traffic_type_pair_t t_info, int _size);
endfunction

<% if(obj.DutInfo.useCmc) { %>
function void resource_manager::gen_addr_cache_warmup();
  smi_addr_t m_addr_1, m_addr_2;
  if(!m_args.k_cache_warmup) begin
    return;
  end
  for(int set =0; set< CCP_SETS;set++) begin
    for(int way=0; way< CCP_WAYS;way++) begin
      assert(std::randomize(m_addr_1));
      <% if(obj.DmiInfo[obj.Id].ccpParams.nSets>1) {%>
      m_addr_2 = ncoreConfigInfo::set_dmi_index_bits(m_addr_1,set,<%=obj.DmiInfo[obj.Id].FUnitId%>);
      <%}else{%>
      m_addr_2 = m_addr_1;
      <%}%>
      //m_addr_2  = (m_addr_2/N_SYS_CACHELINE)*N_SYS_CACHELINE;
      m_addr_q[CACHE_WARMUP].push_back(m_addr_2);
      `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL, $sformatf("::gen_addr_cache_warmup:: Set:%0d Way:%0d :: addr:'h%h",set,way,m_addr_2),UVM_MEDIUM)
    end
  end
  `uvm_info(LABEL, $sformatf("::gen_addr_cache_warmup:: Generated warmump queue of size:%0d for Sets:%0d Ways:%0d",m_addr_q[CACHE_WARMUP].size(),<%=obj.DmiInfo[obj.Id].ccpParams.nSets%>,<%=obj.DmiInfo[obj.Id].ccpParams.nWays%>),UVM_MEDIUM)
endfunction
<% } %>

function void resource_manager::gen_SP_addr();
  <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
  smi_addr_t m_addr;
  int m_index;
  gen_SP_cnt++;
  m_secondary_addr_q[SCRATCHPAD][COH].delete();
  for(int way=0; way < sp_ways; way++)begin
    for(int set=0; set < CCP_SETS; set++) begin
      int sp_index= {way[$clog2(CCP_WAYS)-1:0],set[$clog2(CCP_SETS)-1:0]};
      int m_way;
      m_addr  = sp_base_addr_i + (sp_index << CCP_CL_OFFSET);
      m_index = m_addr[$clog2(CCP_SETS)+CCP_CL_OFFSET-1:CCP_CL_OFFSET];
      m_way = m_addr[$clog2(CCP_SETS*CCP_WAYS)+CCP_CL_OFFSET-1:$clog2(CCP_SETS)+CCP_CL_OFFSET];
      if(m_addr < sp_base_addr_i || m_addr > sp_roof_addr_i) begin
        `uvm_error(LABEL,$sformatf("::gen_SP_addr:: address generation range failures %0h Base:%0h Roof:%0h",cl_aligned(m_addr),sp_base_addr_i,sp_roof_addr_i))
      end
      else begin
        `uvm_info(LABEL,$sformatf("::gen_SP_addr:: Way:%0d Set:%0d sp_index:%0d m_way:%0h m_index:%0h  sp_addr:%0h",way,set,sp_index,m_way,m_index,m_addr),UVM_DEBUG)
        m_secondary_addr_q[SCRATCHPAD][COH].push_back(m_addr);
      end
    end
  end
  <%} else { %>
  `uvm_error(LABEL,"::gen_SP_addr:: Calling address generation for SCP on a config with no scratchpad")
  <% } %>
endfunction

function smi_addr_t resource_manager::get_available_addr(dmi_addr_q_format_t Q_FORMAT, traffic_type_pair_t t_info, int align_size=1, bit is_coh_read=0);
  //Scan the dependency queue for collisions and dispatch the first available collision free address
  dmi_addr_q_type_t Q_TYPE = (Q_FORMAT == REGULAR) ? PRIMARY : SECONDARY;
  bit addr_generated, repopulate_done;
  smi_addr_t m_addr;
  dmi_addr_format_t addr_type = t_info.addr_type;
  case(Q_TYPE)
    PRIMARY: begin
      while( !addr_generated && (m_addr_q[addr_type].size()!=0) ) begin
        m_addr = (m_addr_q[addr_type].pop_front()/align_size)*align_size;
        if(!addr_governor.exists(cl_aligned(m_addr))) begin
          addr_generated = 1;
        end
        else begin
          update_addr_governor_flags(cl_aligned(m_addr));
          if(!addr_governor[cl_aligned(m_addr)].is_pending(is_coh_read)) begin
            addr_generated = 1;
            `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::get_available_addr:: Q_FORMAT:%0s Main queue addr-gen success | addr:%0h align_size:%0d"
                          ,Q_FORMAT.name,m_addr,align_size),UVM_HIGH)
          end
        end
        if(!addr_generated && !repopulate_done && m_addr_q[addr_type].size()==0) begin
          gen_addr(t_info,CMD_SKID_BUF_SIZE);
          if(m_addr_q[Q_FORMAT][addr_type].size() == 0) begin
            `uvm_error(LABEL,$sformatf("::get_available_addr:: Q_FORMAT:%0s Main queue address repopulation failure addr_q size:%0d"
                          ,Q_FORMAT.name,m_addr_q[addr_type].size()))
          end
          repopulate_done = 1;
        end
      end
      if(!addr_generated) begin
          `uvm_error(LABEL,$sformatf("::get_available_addr:: Q_FORMAT:%0s Main queue address generation failure addr_q size:%0d"
                          ,Q_FORMAT.name,m_addr_q[addr_type].size()))
      end
    end
    SECONDARY: begin
      while( !addr_generated && (m_secondary_addr_q[Q_FORMAT][addr_type].size()!=0) ) begin
        m_addr = (m_secondary_addr_q[Q_FORMAT][addr_type].pop_front()/align_size)*align_size;
        if(!addr_governor.exists(cl_aligned(m_addr))) begin
          addr_generated = 1;
        end
        else begin
          update_addr_governor_flags(cl_aligned(m_addr));
          if(!addr_governor[cl_aligned(m_addr)].is_pending(is_coh_read)) begin
            addr_generated = 1;
            `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::get_available_addr:: Q_FORMAT:%0s Secondary queue addr-gen success | addr:%0h align_size:%0d"
                          ,Q_FORMAT.name,m_addr,align_size),UVM_HIGH)
          end
        end
        if(!addr_generated && !repopulate_done && m_secondary_addr_q[addr_type].size()==0) begin
          gen_addr(t_info,CMD_SKID_BUF_SIZE);
          if(m_secondary_addr_q[Q_FORMAT][addr_type].size() == 0) begin
            `uvm_error(LABEL,$sformatf("::get_available_addr:: Q_FORMAT:%0s Secondary queue repopulation failure addr_q size:%0d"
                            ,Q_FORMAT.name,m_secondary_addr_q[Q_FORMAT][addr_type].size()))
          end
          repopulate_done = 1;
        end
      end
      if(!addr_generated) begin
        `uvm_error(LABEL,$sformatf("::get_available_addr:: Q_FORMAT:%0s Secondary queue address generation failure addr_q size:%0d"
                          ,Q_FORMAT.name,m_secondary_addr_q[Q_FORMAT][addr_type].size()))
      end
    end
  endcase

  if(!addr_generated) `uvm_fatal(LABEL,$sformatf("::get_available_addr:: Check your code"));

  return(m_addr);
endfunction

function void resource_manager::gen_addr_regular(traffic_type_pair_t t_info, int _size);
  m_addr_mgr.set_addr_collision_pct(home_dmi_unit_id,1,m_args.wt_reuse_addr.get_value());
  if(t_info.addr_type == COH) begin
    `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::gen_addr_regular:: Size of coh_q:%0d | Generating %0d items.", m_addr_q[COH].size, _size),UVM_MEDIUM)
    m_addr_mgr.gen_user_coh_addr(home_dmi_unit_id, _size, m_addr_q[COH]);
    `uvm_info(LABEL,$sformatf("::gen_addr_regular:: Size of coh_q:%0d generated.", m_addr_q[COH].size),UVM_MEDIUM)
  end
  else if(t_info.addr_type == NONCOH) begin
    `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::gen_addr_regular:: Size of noncoh_q:%0d | Generating %0d items.", m_addr_q[NONCOH].size, _size),UVM_MEDIUM)
    m_addr_mgr.gen_user_noncoh_addr(home_dmi_unit_id, _size, m_addr_q[NONCOH]);
    `uvm_info(LABEL,$sformatf("::gen_addr_regular:: Size of noncoh_q:%0d generated.", m_addr_q[NONCOH].size),UVM_MEDIUM)
  end
  if(sp_exists) begin //Filtering interleave bits beforehand for fair dependency evaluation
    filter_SP_interleave();
  end
  //FIXME evict_addr_dependencies_old(REGULAR,t_info.smi_type);
  //evict_addr_dependencies(REGULAR, t_info);
endfunction

function void resource_manager::evict_addr_dependencies_old(dmi_addr_q_format_t Q_FORMAT, smi_type_t m_opcode, int pyld_alignment_size);
  //Lookup the dmi_table and generate a dependency queue on what addresses can't be reused and evict from m_addr_q
  int coh_wr_match_q[$], coh_rd_match_q[$], atm_ld_match_q[$], cmo_match_q[$];
  int non_coh_wr_match_q[$], non_coh_rd_match_q[$];
  int local_collision_q[dmi_addr_format_t][$];
  bit is_coh_read = isCoherentRead(m_opcode);
  dmi_addr_q_type_t Q_TYPE = (Q_FORMAT == REGULAR) ? PRIMARY : SECONDARY;
  if(is_coh_read) begin
    //DTW response for Cohrent Writes or Write Merge
    coh_wr_match_q = m_table.find_index with(item.is_in_flight_coh_wr == 1 || item.is_in_flight_coh_wr_merge);
    //DTR request for Coherent Reads
    coh_rd_match_q = m_table.find_index with(item.is_in_flight_coh_rd == 1);
    //STR response for CMOs
    cmo_match_q = m_table.find_index with(item.is_active_cmo == 1);
    //DTR request + DTW response for Atomic Loads
    atm_ld_match_q = m_table.find_index with(item.is_in_flight_atomic_ld == 1);

    addr_collision_q = {coh_wr_match_q,coh_rd_match_q,cmo_match_q,atm_ld_match_q};
  end
  else begin
    //DTW response for Cohrent writes
    coh_wr_match_q = m_table.find_index with(item.is_in_flight_coh_wr == 1);
    //DTR request for coherent reads
    coh_rd_match_q = m_table.find_index with(item.is_in_flight_coh_rd == 1);
    //STR response for CMOS
    cmo_match_q = m_table.find_index with(item.is_active_cmo == 1);

    addr_collision_q = {coh_wr_match_q,coh_rd_match_q,cmo_match_q};
  end
  eval_dependency_count++;
  if(addr_collision_q.size == 0 ) begin
    `uvm_info(LABEL,$sformatf("::evict_addr_dependencies_old:: No address collisions found isCohRead:%0b | Attempt:%0d Q_TYPE:%0s Q_FORMAT:%0s ", is_coh_read, eval_dependency_count,Q_TYPE.name,Q_FORMAT.name),UVM_HIGH)
  end
  else begin
    //FIXME instead of intensively evicting every single time, avoid traversing the queue. 
    //Pick an address from the front of the queue check if it hits in the match_q, if it does. Discard it and repeat until you hit something.
    //Evict all active addresses that cannot be used for dispatch
    `uvm_info(LABEL,$sformatf("::evict_addr_dependencies_old:: Attempt:%0d Matches %0d isCohRead:%0b | coh_wr_match_q:%0d coh_rd_match_q:%0d cmo_match_q:%0d atm_ld_match_q:%0d Q_TYPE:%0s Q_FORMAT:%0s ", 
                                              eval_dependency_count,addr_collision_q.size,is_coh_read,coh_wr_match_q.size,coh_rd_match_q.size,cmo_match_q.size,atm_ld_match_q.size,Q_TYPE.name,Q_FORMAT.name),UVM_DEBUG)
  end
  foreach(addr_collision_q[i]) begin
    smi_full_addr_t m_faddr;
    int evict_idx_q[dmi_addr_format_t][$];
    m_faddr = m_table[addr_collision_q[i]].get_full_addr(); 
    //FIXME -- Manage eviction queues better than simply evicting any active transaction, aka mixed addressing modes.
    case(Q_TYPE)
      PRIMARY: begin          
        evict_idx_q[COH]    = m_addr_q[COH].find_index with(cl_aligned_match(m_faddr.addr,size_aligned(item,pyld_alignment_size)));
        evict_idx_q[NONCOH] = m_addr_q[NONCOH].find_index with(cl_aligned_match(m_faddr.addr,size_aligned(item,pyld_alignment_size)));
      end
      SECONDARY: begin
        evict_idx_q[COH]    = m_secondary_addr_q[Q_FORMAT][COH].find_index with(cl_aligned_match(m_faddr.addr,size_aligned(item,pyld_alignment_size)));
        evict_idx_q[NONCOH] = m_secondary_addr_q[Q_FORMAT][NONCOH].find_index with(cl_aligned_match(m_faddr.addr,size_aligned(item,pyld_alignment_size)));
      end
      default begin
        `uvm_error(LABEL,$sformatf("::evict_addr_dependencies_old:: Received unsupported Q_TYPE:%0s",Q_TYPE.name))
      end
    endcase

    `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::evict_addr_dependencies_old:: m_table_idx:%0d faddr:%0p |COH:%0d NON-COH:%0d Q_TYPE:%0s Q_FORMAT:%0s ",addr_collision_q[i],m_faddr,evict_idx_q[COH].size, evict_idx_q[NONCOH].size,Q_TYPE.name,Q_FORMAT.name),UVM_DEBUG)
    
    if(evict_idx_q[COH].size > 0) begin
      if (evict_idx_q[COH].size > 1) begin
        `uvm_info(LABEL,$sformatf("::evict_addr_dependencies_old:: Multiple address hits %0p for eviction in COH queue Q_TYPE:%0s Q_FORMAT:%0s ",m_faddr,Q_TYPE.name,Q_FORMAT.name),UVM_HIGH)
      end
      local_collision_q[COH] = {local_collision_q[COH], evict_idx_q[COH]};
    end
    if(evict_idx_q[NONCOH].size > 0) begin
      if (evict_idx_q[NONCOH].size > 1) begin
        `uvm_info(LABEL,$sformatf("::evict_addr_dependencies_old:: Multiple address hits %0p for eviction in NONCOH queue Q_TYPE:%0s Q_FORMAT:%0s ",m_faddr,Q_TYPE.name,Q_FORMAT.name),UVM_HIGH)
      end
      //else begin
      local_collision_q[NONCOH] = {local_collision_q[NONCOH], evict_idx_q[NONCOH]};
      //end
    end
  end
  //Evict addresses
  `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("---------------------------------------------------------------"),UVM_HIGH)
  `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::evict_addr_dependencies_old:: local_collision_q | COH:%0d NON-COH:%0d Q_TYPE:%0s Q_FORMAT:%0s "
                                                                  ,local_collision_q[COH].size,local_collision_q[NONCOH].size,Q_TYPE.name,Q_FORMAT.name),UVM_HIGH)
  `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("---------------------------------------------------------------"),UVM_HIGH)
  case(Q_TYPE)
    SECONDARY: begin
      foreach(m_secondary_addr_q[Q_FORMAT][_type]) begin
        for(int i= (m_secondary_addr_q[Q_FORMAT][_type].size-1); i>=0; i--) begin
          if( i inside {local_collision_q[_type]} ) begin
            `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::evict_addr_dependencies_old:: Evicting address:%0h from m_secondary_addr_q(size=%0d)",m_secondary_addr_q[Q_FORMAT][_type][i],$size(m_secondary_addr_q[Q_FORMAT][_type])-1),UVM_HIGH)
            m_secondary_addr_q[Q_FORMAT][_type].delete(i);
          end
        end
      end
      `uvm_info(LABEL,$sformatf("::evict_addr_dependencies_old:: Post eviction size m_secondary_addr_q[%0s]| COH:%0d NONCOH:%0d",Q_FORMAT.name,m_secondary_addr_q[Q_FORMAT][COH].size(),m_secondary_addr_q[Q_FORMAT][NONCOH].size()),UVM_HIGH)
    end
    PRIMARY: begin
      foreach(m_addr_q[_type]) begin
        for(int i= (m_addr_q[_type].size-1); i>=0; i--) begin
          if( i inside {local_collision_q[_type]} ) begin
            `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::evict_addr_dependencies_old:: Evicting address:%0h from m_addr_q(size=%0d)",m_addr_q[_type][i],$size(m_addr_q[_type])-1),UVM_HIGH)
            m_addr_q[_type].delete(i);
          end
        end
      end
      `uvm_info(LABEL,$sformatf("::evict_addr_dependencies_old:: Post eviction size m_addr_q| COH:%0d NONCOH:%0d",m_addr_q[COH].size(),m_addr_q[NONCOH].size()),UVM_HIGH)
    end
  endcase
  `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("---------------------------------------------------------------"),UVM_DEBUG)
endfunction
function void resource_manager::evict_addr_dependencies(dmi_addr_q_format_t Q_FORMAT, traffic_type_pair_t t_info);
  //Scan through the relevant queue, check the address governor, remove from relevant queue if pending 
  smi_type_t m_optype;
  dmi_addr_format_t m_addr_type = t_info.addr_type;
  dmi_addr_q_type_t Q_TYPE = (Q_FORMAT==REGULAR) ? PRIMARY : SECONDARY;
  int align_size = t_info.payload_size;
  bit is_align = (align_size==0) ? 0 : 1;
  `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::evict_addr_dependencies:: is_align:%0b align_size:%0d Q_FORMAT:%0s t_info:%0p",is_align,align_size,Q_FORMAT,t_info),UVM_DEBUG)
  case(Q_TYPE)
    PRIMARY : begin
      for(int i=m_addr_q[m_addr_type].size()-1; i >=0; i--) begin
        smi_addr_t data_aligned_addr;
        data_aligned_addr = is_align ? (m_addr_q[m_addr_type][i]/align_size)*align_size : m_addr_q[m_addr_type][i];
        `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::evict_addr_dependencies:: data_aligned_addr:%0h exists:%0h",data_aligned_addr, addr_governor.exists(cl_aligned(data_aligned_addr))),UVM_DEBUG)
        if(addr_governor.exists(cl_aligned(data_aligned_addr))) begin
          m_addr_q[m_addr_type].delete(i);
        end
      end
    end
    SECONDARY: begin
      for(int i=m_secondary_addr_q[Q_FORMAT][m_addr_type].size()-1; i >=0; i--) begin
        smi_addr_t data_aligned_addr;
        data_aligned_addr = is_align ? (m_secondary_addr_q[Q_FORMAT][m_addr_type][i]/align_size)*align_size : m_secondary_addr_q[Q_FORMAT][m_addr_type][i];
        `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::evict_addr_dependencies:: data_aligned_addr:%0h exists:%0h",data_aligned_addr, addr_governor.exists(cl_aligned(data_aligned_addr))),UVM_DEBUG)
        if(addr_governor.exists(cl_aligned(data_aligned_addr))) begin
          m_secondary_addr_q[Q_FORMAT][m_addr_type].delete(i);
        end
      end
    end
    default: begin
      `uvm_error(LABEL,$sformatf("::evict_addr_dependencies:: Received unsupported Q_TYPE:%0s",Q_TYPE.name))
    end
  endcase

endfunction

function bit resource_manager::all_release_rbid_flips_are_occupied();
  smi_rbid_q m_q = evaluate_RB_dependencies(1);
  return( m_q.size == 0 ? 1 : 0);
endfunction

function bit resource_manager::is_RBID_available();
  bit rb_status;
  gid_rb_status = gid0_rb_status | gid1_rb_status;
  rb_status = (&gid_rb_status);
  // If all RBIDs are occupied or there are no release rbid flips that can be dispatched. 
  if( rb_status && ( (rbid_release_q.size()==0) || (rbid_release_q.size()!=0 && all_release_rbid_flips_are_occupied()) ) )  begin
    `uvm_info(LABEL,$sformatf("::is_RBID_available:: all coherent rbids are in use rbid_release_q:%0d gid0_status:%0d gid1_status:%0d rb_status:%0b", rbid_release_q.size, $countones(gid0_rb_status), $countones(gid1_rb_status), rb_status),UVM_MEDIUM)
    return(0);
  end
  else begin
    `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::is_RBID_available:: rbid_release_q:%0d gid0_status:%0d gid1_status:%0d rb_status:%0b", rbid_release_q.size, $countones(gid0_rb_status), $countones(gid1_rb_status), rb_status),UVM_HIGH)
    return(1);
  end
endfunction

function bit resource_manager::is_RBID_release_resolved();
  smi_rbid_t gid_flip_rbid;
  bit resolved = 1;
  foreach(rbid_release_q[i])begin
    int check_state[$];
    gid_flip_rbid = {~rbid_release_q[i][WSMIRBID-1], rbid_release_q[i][WSMIRBID-2:0]};
    check_state = m_table.find_index with(  (item.smi_rbid == gid_flip_rbid) 
                                          &&(!item.rb_rsp_rcvd));
    resolved &= (check_state.size==0) && (!used_cohrbid_q.exists(gid_flip_rbid));
  end
  return(resolved);
endfunction

function bit resource_manager::is_release_RBID(smi_rbid_t m_rbid);
  int pending_in_seq_q[$];
  smi_rbid_t gid_flip_rbid;
  
  gid_flip_rbid = {~m_rbid[WSMIRBID-1], m_rbid[WSMIRBID-2:0]};
  pending_in_seq_q = rbid_release_q.find_index with( item == m_rbid);
  if(pending_in_seq_q.size==0) begin
    return(0);
  end
  else begin
    return(1);
  end
endfunction

function smi_rbid_q resource_manager::evaluate_RB_dependencies(input bit drain_mode=0);
  smi_rbid_q m_q;
  bit release_mode = $urandom_range(1,100) <= m_args.wt_rb_release.get_value();
  bit rb_status;
  gid_rb_status = gid0_rb_status | gid1_rb_status;
  rb_status = (&gid_rb_status);
  if(rbid_release_q.size()==0 ||!(drain_mode || release_mode) || rb_status ) begin
    `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::evaluate_RB_dependencies:: Exiting, no RBIDs that need to be internally released"),UVM_DEBUG)
    return(m_q);
  end
  else begin
    //Construct a queue of RBIDs that are eligible to release
    foreach(rbid_release_q[i]) begin
      smi_rbid_t gid_flip_rbid = {~rbid_release_q[i][WSMIRBID-1], rbid_release_q[i][WSMIRBID-2:0]};
      //Check if {!GID,RBID} is utilized. If it is, check if it's expecting a release
      if(  ( used_cohrbid_q.exists(gid_flip_rbid) && is_release_RBID(gid_flip_rbid))
         ||(!used_cohrbid_q.exists(gid_flip_rbid))
        ) begin
        m_q.push_back(gid_flip_rbid);
        `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::evaluate_RB_dependencies:: Pushing RBID:%0h size(=%0d)",gid_flip_rbid,m_q.size),UVM_DEBUG)
      end
      else begin
        `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::evaluate_RB_dependencies:: Occupied RBID:%0h size(=%0d)",gid_flip_rbid,m_q.size),UVM_DEBUG)
      end
    end
    `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::evaluate_RB_dependencies:: Found RBIDs:%0d",m_q.size),UVM_DEBUG)
    return(m_q);
  end
endfunction

function smi_rbid_t resource_manager::reserve_RBID(input bit internal_release=0, drain_mode=0);
  int rls_rbid, gid_flip_rbid, reg_rbid, m_rbid;
  int NunitID;
  bit status = 0;
  int release_index;
  smi_rbid_q dependency_free_q;
  string mode;
  if(rbid_release_q.size != 0 && (&(gid0_rb_status || gid1_rb_status))) begin
    `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,"::reserve_RBID:: Forcing Drain Mode ON",UVM_MEDIUM)
    drain_mode = 1;
  end
  dependency_free_q = evaluate_RB_dependencies(drain_mode);
  //Check weight of release and use release q or drain rbid mode
  if(dependency_free_q.size()!=0) begin
    int find_release_q[$];
    int available_violation[$];
    mode = (drain_mode) ? "DRAIN" : (m_args.k_all_internal_release) ? "ALL_RELEASE" : "WEIGHTED_RELEASE";

    gid_flip_rbid = dependency_free_q[$urandom_range(dependency_free_q.size()-1,0)];
    rls_rbid = {~gid_flip_rbid[WSMIRBID-1], gid_flip_rbid[WSMIRBID-2:0]};
    NunitID = rls_rbid[WSMIRBID-2:0]/<%=obj.DceInfo[0].nRbsPerDmi%>; 
    m_rbid = gid_flip_rbid;

    find_release_q = rbid_release_q.find_index with (item == rls_rbid);
    if(find_release_q.size() == 0 || find_release_q.size() > 1) begin
      `uvm_info(LABEL,$sformatf("::reserve_RBID:: rbid_release_q:%0p",rbid_release_q),UVM_LOW)
      `uvm_error(LABEL,$sformatf("::reserve_RBID:: Failed to find RBID:%0h in the rbid_release_q(size=%0d) | Matches:%0d",rls_rbid,rbid_release_q.size,find_release_q.size))
    end
    else begin
     `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::reserve_RBID:: Deleting index:%0d RBID:%0h from rbid_release_q",find_release_q[0],rbid_release_q[find_release_q[0]]),UVM_DEBUG)
      rbid_release_q.delete(find_release_q[0]);
    end
    //smi_tm = rbid_release_q[release_idx].tm;
    status = 1;
    home_dce_unit_id = dcefunitID[NunitID]; 
    available_violation = available_rbid_q.find_index with (item == rls_rbid);
    if(available_violation.size != 0) begin
      `uvm_error(LABEL,$sformatf("Violation queue non-zero==%0d. If this is indeed a RBID:%0h expecting a release then it shouldn't be available.",available_violation.size,rls_rbid))
    end
  end
  else begin
    int attempt = 0;
    mode = "DEFAULT";
    if(available_rbid_q.size == 0) begin
      gen_available_rbids();
    end
    if(available_rbid_q.size != 0) begin
      reg_rbid = available_rbid_q.pop_front();
      gid_flip_rbid = {~reg_rbid[WSMIRBID-1], reg_rbid[WSMIRBID-2:0]};
      NunitID = reg_rbid/<%=obj.DceInfo[0].nRbsPerDmi%>; 
      m_rbid = reg_rbid;
      if( (used_cohrbid_q.exists(reg_rbid) || used_cohrbid_q.exists(gid_flip_rbid)) ) begin
        `uvm_info(LABEL,$sformatf("::reserve_RBID:: Failed alloting RBID:%0h available_rbid_q(%0d)",reg_rbid,available_rbid_q.size),UVM_MEDIUM)
        status = 0;
      end
      else begin
        status = 1;
      end
    end
    home_dce_unit_id = dcefunitID[NunitID]; 
  end
  if(status) begin
    used_cohrbid_q[m_rbid] = 1;
    if(m_rbid[WSMIRBID-1]) gid1_rb_status[m_rbid[WSMIRBID-2:0]] = 1;
    else gid0_rb_status[m_rbid[WSMIRBID-2:0]] = 1;
    gid_rb_status = gid0_rb_status | gid1_rb_status;
    if(internal_release) begin
      rbid_release_q.push_back(m_rbid);
      `uvm_info(LABEL,$sformatf("::reserve_RBID:: RBID:%0h Reserved:%0b Mode:%s | Internal Release(size=%0d)",m_rbid,status,mode,rbid_release_q.size),UVM_HIGH)
    end
    else begin
      `uvm_info(LABEL,$sformatf("::reserve_RBID:: RBID:%0h Reserved:%0b Mode:%s",m_rbid,status,mode),UVM_HIGH)
    end
    return(m_rbid);
  end
  else begin
    `uvm_error(LABEL,"::reserve_RBID:: Failed, fix your calling method")
  end
endfunction

function resource_manager::gen_available_rbids();
  smi_rbid_t index_q[$];
  smi_rbid_t gid_flip_rbid;
  index_q = used_cohrbid_q.find_index with (1);
  //Efficient allotment. COH_RBID_SIZE iterations accessed only when available queue is empty.
  for(smi_rbid_t rbid =0; rbid < COH_RBID_SIZE; rbid++) begin
    gid_flip_rbid = {~rbid[WSMIRBID-1],rbid[WSMIRBID-2:0]};
    if( !(used_cohrbid_q.exists(rbid) || used_cohrbid_q.exists(gid_flip_rbid)) ) begin
      available_rbid_q.push_back(rbid);
    end
    else begin
      `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::gen_available_RBIDs:: RBID:%0h is occupied",rbid),UVM_DEBUG)
    end
  end
  if(available_rbid_q.size==0) begin
    `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::gen_available_rbids resulted in 0 matches| index_q:%0d",index_q.size),UVM_HIGH)
  end
endfunction

function resource_manager::release_RBID(smi_rbid_t m_rbid);
  int used = used_cohrbid_q.num();
  int available = COH_RBID_SIZE - used;
  if(used_cohrbid_q.exists(m_rbid))begin
    `uvm_info(LABEL,$sformatf("::release_RBID:: Releasing RBID:%0h | Used:%0d Available:%0d",m_rbid, used-1, available+1),UVM_HIGH)
    used_cohrbid_q.delete(m_rbid);
    if(m_rbid[WSMIRBID-1]) gid1_rb_status[m_rbid[WSMIRBID-2:0]] = 0;
    else gid0_rb_status[m_rbid[WSMIRBID-2:0]] = 0;
    gid_rb_status = gid0_rb_status | gid1_rb_status;
    `uvm_guarded_info(m_args.k_stimulus_debug,LABEL,$sformatf("::release_RBID:: gid0_rb_status:%0d gid1_rb_status:%0d",$countones(gid0_rb_status),$countones(gid1_rb_status)),UVM_HIGH)
  end
  else begin
    `uvm_error(LABEL,$sformatf("::release_RBID:: RBID:%0h doesn't exist in used_cohrbid_q | Used:%0d Available:%0d", m_rbid, used, available))
  end
endfunction
//Resource Allocation End///////////////////////////////////////////////////////////////////////////////////////////////////

//Exclusive Manager Control Begin///////////////////////////////////////////////////////////////////////////////////////////
function resource_manager::add_to_exclusive_q(ref smi_seq_item m_item);
  dmi_exclusive_c p_item;
  if(m_item.smi_msg_type != CMD_RD_NC) begin
    return;
  end
  p_item = new();
  p_item.addr       = m_item.smi_addr;
  p_item.src_id     = m_item.smi_src_ncore_unit_id;
  p_item.flowid     = m_item.smi_mpf2_flowid;
  p_item.msg_type   = m_item.smi_msg_type;
  p_item.ns         = m_item.smi_ns;
  load_exclusives_q.push_back(p_item);
  `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::add_to_exclusive_q:: Adding -- %0p -- (size=%0d)",p_item,load_exclusives_q.size()),UVM_DEBUG)
endfunction
//Exclusive Manager Control End/////////////////////////////////////////////////////////////////////////////////////////////

//Address Governor Begin////////////////////////////////////////////////////////////////////////////////////////////////////
function resource_manager::add_to_addr_governor(smi_addr_t m_addr, int uid, dmi_pattern_type_t m_pattern);
  if(!addr_governor.exists(m_addr)) begin
    addr_governor[m_addr] = addr_status_item::type_id::create($sformatf("addr_governor[%0h]",m_addr));
    addr_governor[m_addr].lut_UID = uid;
    update_addr_governor_flags_with_idx(m_table.size()-1);
    print_addr_governor_info("::add_to_addr_gov::",`__LINE__,m_addr);
  end
  else if(m_pattern == DMI_CACHE_WARMUP_p) begin
    if(addr_governor[m_addr].UID_q.size() == 0) begin
      addr_governor[m_addr].UID_q.push_back(addr_governor[m_addr].lut_UID);
    end
    addr_governor[m_addr].UID_q.push_back(uid);
    print_addr_governor_info("::add_to_addr_gov::",`__LINE__,m_addr);
  end
  else begin
    `uvm_error(LABEL,$sformatf("::add_to_addr_gov:: smi_addr:%0h already exists as part of DT_UID:%0d:",m_addr,addr_governor[m_addr].lut_UID))
  end
endfunction

function resource_manager::del_from_addr_governor(smi_addr_t m_addr, int uid);
  if(addr_governor.exists(m_addr)) begin
    if(addr_governor[m_addr].UID_q.size() > 0 ) begin
      int match_q[$];
      match_q = addr_governor[m_addr].UID_q.find_index with (item == uid);
      if(match_q.size == 1) begin
        addr_governor[m_addr].UID_q.delete(match_q[0]);
        if( addr_governor[m_addr].UID_q.size()==0 ) begin
          `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("Deleting multi smi_addr:%0h addr_governor(size:%0d)",m_addr,addr_governor.num()-1),UVM_HIGH)
          addr_governor.delete(m_addr);
        end
      end
      else begin
        `uvm_error(LABEL,$sformatf("::del_from_addr_gov:: Sanity violation, received UID:%0h for Addr:%0h not found in queue %0p"
                                                                    ,uid,m_addr,addr_governor[m_addr].UID_q))
      end
    end
    else begin
      if(addr_governor[m_addr].lut_UID != uid ) begin
        `uvm_error(LABEL,$sformatf("::del_from_addr_gov:: Sanity violation, received smi_addr:%0h doesn't match expected m_table uid exp:%0d rcvd:%0d"
                                                                      ,m_addr,addr_governor[m_addr].lut_UID,uid))
      end
      else begin
        `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("Deleting smi_addr:%0h addr_governor(size:%0d)",m_addr,addr_governor.num()-1),UVM_HIGH)
        addr_governor.delete(m_addr);
      end
    end
  end
  else begin
    `uvm_error(LABEL,$sformatf("::del_from_addr_gov:: Received smi_addr:%0h doesn't exist in addr_governor(size:%0d)",m_addr,addr_governor.num()))
  end
endfunction

function resource_manager::print_addr_governor_info(string _label, int line, smi_addr_t m_addr);
  if(addr_governor.exists(m_addr)) begin
    `uvm_info(LABEL,$sformatf("%s addr:%0h %0s (line:%0d)",addr_governor[m_addr].convert2string,m_addr,_label,line),UVM_MEDIUM)
  end
  else begin
    `uvm_error(LABEL,$sformatf("::print_addr_gov:: Received smi_addr:%0h doesn't exist in addr_governor(size:%0d)",m_addr,addr_governor.num()))
  end
endfunction

function resource_manager::update_addr_governor_flags(smi_addr_t m_addr);
  if(addr_governor.exists(m_addr)) begin
    int m_UID, m_idx;
    int match_q[$];
    m_UID  = addr_governor[m_addr].lut_UID;
    match_q = m_table.find_index with ( (item.UID == m_UID) && (item.cache_addr == m_addr) ); 
    //FIXME i don't want it to search every time an address is accessed, that's O(m)
    if(match_q.size()==1) begin
      m_idx = match_q[0];
    end
    else begin
      `uvm_error(LABEL,$sformatf("::update_addr_gov_flags:: Found matches:%0d, expected one",match_q.size()))
    end
    addr_governor[m_addr].coh_write_flg = m_table[m_idx].is_in_flight_coh_wr || m_table[m_idx].is_in_flight_coh_wr_merge; 
    addr_governor[m_addr].coh_read_flg  = m_table[m_idx].is_in_flight_coh_rd;
    addr_governor[m_addr].cmo_flg       = m_table[m_idx].is_active_cmo;
    addr_governor[m_addr].atomic_flg    = m_table[m_idx].is_in_flight_atomic_ld;
    `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::update_addr_gov_flags:: %0s addr:%0h",addr_governor[m_addr].convert2string(),m_addr),UVM_DEBUG)
  end
  else begin
    `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::update_addr_gov_flags:: Received smi_addr:%0h doesn't exist in addr_governor(size:%0d)",m_addr,addr_governor.num()),UVM_DEBUG)
  end
endfunction

function resource_manager::update_addr_governor_flags_with_idx(int m_idx);
  smi_addr_t m_addr = cl_aligned(m_table[m_idx].cache_addr);
  if(addr_governor.exists(m_addr)) begin
    addr_governor[m_addr].coh_write_flg = m_table[m_idx].is_in_flight_coh_wr || m_table[m_idx].is_in_flight_coh_wr_merge; 
    addr_governor[m_addr].coh_read_flg  = m_table[m_idx].is_in_flight_coh_rd;
    addr_governor[m_addr].cmo_flg       = m_table[m_idx].is_active_cmo;
    addr_governor[m_addr].atomic_flg    = m_table[m_idx].is_in_flight_atomic_ld;
    `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::update_addr_gov_flags_with_idx:: %0s addr:%0h",addr_governor[m_addr].convert2string(),m_addr),UVM_DEBUG)
  end
  else begin
    `uvm_guarded_info(m_args.k_stimulus_address_debug,LABEL,$sformatf("::update_addr_gov_flags_with_idx:: Received smi_addr:%0h doesn't exist in addr_governor(size:%0d)",m_addr,addr_governor.num()),UVM_DEBUG)
  end
endfunction

//Address Governor End//////////////////////////////////////////////////////////////////////////////////////////////////////

//DMI Lookup Table Begin////////////////////////////////////////////////////////////////////////////////////////////////////
function resource_manager::add_to_LUT(ref smi_seq_item m_item, input int m_id, dmi_pattern_type_t m_pattern);
  dmi_table item;
  item = dmi_table::type_id::create("item");
  item.initialize(m_item,m_id);
  `uvm_info(LABEL,$sformatf("%s",item.convert2string()),UVM_HIGH)
  m_table.push_back(item);
  if(!(m_item.smi_msg_type inside {dependency_free_smi_type_q})) begin 
    //Maintain address status only for addresses that matter.
    add_to_addr_governor(cl_aligned(item.cache_addr),item.UID,m_pattern);
  end
endfunction

function resource_manager::print_LUT_line(string _label, int line, int index);
   `uvm_info(LABEL,$sformatf("%s %s (line:%0d)",m_table[index].convert2string(),_label,line),UVM_HIGH)
endfunction

function resource_manager::print_LUT(input uvm_verbosity verbosity=UVM_LOW);
  if(m_table.size == 0) begin
    return;
  end
  uvm_report_info(LABEL,$sformatf("-------------dmi_table[size=%0d]-----------------",m_table.size()),verbosity);
  foreach(m_table[i]) begin
    uvm_report_info(LABEL,$sformatf("%s",m_table[i].convert2string()),verbosity);
  end
  uvm_report_info(LABEL,$sformatf("-------------------------------------------------"),verbosity);

endfunction

function resource_manager::print_LUT_matches(int idx_q[$]);
  `uvm_info(LABEL,$sformatf("-------------dmi_table[size=%0d]-----------------",m_table.size()),UVM_LOW)
  foreach(idx_q[i]) begin
    `uvm_info(LABEL,$sformatf("%s",m_table[idx_q[i]].convert2string()),UVM_LOW)
  end
endfunction 

function resource_manager::delete_LUT(int m_idx, input bit print_full=0);
  if(print_full) begin
    `uvm_info(LABEL,$sformatf("%s",m_table[m_idx].convert2string()),UVM_HIGH)
  end
  `uvm_info(LABEL,$sformatf("DT_UID:%0d Deleting entry.",m_table[m_idx].UID),UVM_HIGH)
  if(!(m_table[m_idx].msg_type inside {dependency_free_smi_type_q})) begin 
    //Maintain address status only for addresses that matter.
    del_from_addr_governor(cl_aligned(m_table[m_idx].cache_addr),m_table[m_idx].UID);
  end
  m_table.delete(m_idx);
endfunction

function resource_manager::update_LUT(ref smi_seq_item m_item,output resource_semaphore_t computed_outcome);
  aiu_id_t aiu_entry;
  dce_id_t dce_entry;
  aiu_entry.aiu_id = m_item.smi_targ_ncore_unit_id;
  aiu_entry.msg_id = m_item.smi_rmsg_id;
  dce_entry.dce_id = m_item.smi_targ_ncore_unit_id;
  dce_entry.msg_id = m_item.smi_rmsg_id;
  dce_entry.rbid   = m_item.smi_rbid;

  if(m_item.isDtwRspMsg()) begin
    `uvm_info(LABEL,$sformatf("::update_LUT:: Processing %0s AiuId:%0h MsgId:%0h",
                                 smi_type_string(m_item.smi_msg_type),aiu_entry.aiu_id,aiu_entry.msg_id),UVM_HIGH)
    process_dtw_rsp_LUT(m_item,aiu_entry, computed_outcome);
  end
  else if(m_item.isNcCmdRspMsg()) begin
    `uvm_info(LABEL,$sformatf("::update_LUT:: Processing %0s AiuId:%0h MsgId:%0h",
                                 smi_type_string(m_item.smi_msg_type),aiu_entry.aiu_id,aiu_entry.msg_id),UVM_HIGH)
    process_nc_cmd_rsp_LUT(m_item,aiu_entry);
  end
  else if(m_item.isDtrMsg()) begin
    `uvm_info(LABEL,$sformatf("::update_LUT:: Processing %0s AiuId:%0h MsgId:%0h",
                                 smi_type_string(m_item.smi_msg_type),aiu_entry.aiu_id,aiu_entry.msg_id),UVM_HIGH)
    process_dtr_LUT(m_item,aiu_entry);
  end
  else if(m_item.isStrMsg()) begin
    `uvm_info(LABEL,$sformatf("::update_LUT:: Processing %0s AiuId:%0h MsgId:%0h",
                                 smi_type_string(m_item.smi_msg_type),aiu_entry.aiu_id,aiu_entry.msg_id),UVM_HIGH)
    process_str_LUT(m_item,aiu_entry);
  end
  else if(m_item.isRbRspMsg()) begin
    `uvm_info(LABEL,$sformatf("::update_LUT:: Processing %0s AiuId:%0h MsgId:%0h DceId:%0h RMsgId:%0h RBID:%0h",
                                 smi_type_string(m_item.smi_msg_type),aiu_entry.aiu_id,aiu_entry.msg_id,
                                 dce_entry.dce_id,dce_entry.msg_id,dce_entry.rbid),UVM_HIGH)
    process_rb_rsp_LUT(m_item,aiu_entry);
    release_dce_table(dce_entry,1);
  end
  else if(m_item.isMrdRspMsg()) begin
    `uvm_info(LABEL,$sformatf("::update_LUT:: Processing %0s AiuId:%0h MsgId:%0h DceId:%0h RMsgId:%0h",      
                                 smi_type_string(m_item.smi_msg_type),aiu_entry.aiu_id,aiu_entry.msg_id,
                                 dce_entry.dce_id,dce_entry.msg_id),UVM_HIGH)
    process_mrd_rsp_LUT(m_item);
    release_dce_table(dce_entry);
  end
  else begin
    `uvm_error(LABEL,$sformatf("::update_LUT:: Received unsupported type:%0h",m_item.smi_msg_type))
  end
endfunction

function resource_manager::process_mrd_rsp_LUT(ref smi_seq_item m_item);
  int mrd_q[$];
  aiu_id_t m_aiu_entry;
  mrd_q = m_table.find_index with( item.smi_msg_id == m_item.smi_rmsg_id &&
                                   item.dce_id     == m_item.smi_targ_ncore_unit_id &&
                                  !item.cmd_rsp_rcvd &&
                                  !item.mrd_rsp_rcvd &&
                                   item.is_coh_rd_TT
                                 );
  if(mrd_q.size == 1) begin
    m_table[mrd_q[0]].mrd_rsp_rcvd = 1;
    print_LUT_line("::mrd_rsp_LUT",`__LINE__, mrd_q[0]);
    if( m_table[mrd_q[0]].dtr_req_rcvd || 
       (m_table[mrd_q[0]].msg_type inside {MRD_FLUSH, MRD_INV, MRD_CLN,MRD_PREF})) begin
      if(m_table[mrd_q[0]].mrd_rsp_rcvd) begin
        `uvm_info(LABEL, $sformatf("::mrd_rsp_LUT:: DtrReq already seen. Deleting entry"), UVM_HIGH)
      end
      else begin
        `uvm_info(LABEL, $sformatf("::mrd_rsp_LUT:: Received a CMO %0s. Deleting entry",
                                               smi_type_string(m_table[mrd_q[0]].msg_type)), UVM_HIGH)
      end
      m_aiu_entry.aiu_id = m_table[mrd_q[0]].aiu_id;
      m_aiu_entry.msg_id = m_table[mrd_q[0]].aiu_msg_id;
      release_aiu_table(m_aiu_entry);
      delete_LUT(mrd_q[0]);
    end
  end
  else begin
    print_LUT_matches(mrd_q);
    `uvm_error("process_mrd_rsp_LUT",$sformatf("::mrd_rsp_LUT:: %0d matches for MrdRsp",mrd_q.size))
  end
endfunction

function resource_manager::process_nc_cmd_rsp_LUT(ref smi_seq_item m_item, input aiu_id_t m_aiu_entry);
  int ncrd_q[$],ncwr_q[$],atmld_q[$];
  ncrd_q = m_table.find_index with( item.is_aiu_match(item.aiu_entry,m_aiu_entry) &&
                                   !item.cmd_rsp_rcvd &&
                                    item.is_non_coh_rd_TT);

  ncwr_q = m_table.find_index with( item.is_aiu_match(item.aiu_entry,m_aiu_entry) &&
                                   !item.cmd_rsp_rcvd &&
                                    item.is_non_coh_wr_TT);

  atmld_q = m_table.find_index with( item.is_aiu_match(item.aiu_entry,m_aiu_entry) &&
                                    !item.cmd_rsp_rcvd &&
                                     item.is_atm_ld_TT);
  `uvm_guarded_info(m_args.k_stimulus_debug,LABEL, $sformatf("::nc_cmd_rsp_LUT:: CmdRsp Match || NcRd :%0d | NcWr :%0d | NcLd :%0d",ncrd_q.size,ncwr_q.size,atmld_q.size),UVM_HIGH)
  if (ncrd_q.size +ncwr_q.size +atmld_q.size == 0) begin
     `uvm_error(LABEL, $sformatf("::nc_cmd_rsp_LUT:: No NcRd :%0d or NcWr :%0d or NcLd :%0d match this CmdRsp",ncrd_q.size,ncwr_q.size,atmld_q.size))
  end
  else if (ncrd_q.size +ncwr_q.size + atmld_q.size > 1) begin
      print_LUT_matches({ncrd_q,ncwr_q,atmld_q});
     `uvm_error(LABEL, $sformatf("::nc_cmd_rsp_LUT:: Multiple NcRd :%0d or NcWr :%0d or NcLd :%0d match this CmdRsp",ncrd_q.size,ncwr_q.size,atmld_q.size))
  end
  else begin
     if(ncrd_q.size == 1)begin
       m_table[ncrd_q[0]].cmd_rsp_rcvd = 1;
       print_LUT_line("::nc_cmd_rsp_LUT",`__LINE__, ncrd_q[0]);
       if ((m_table[ncrd_q[0]].str_rsp_sent == 1  && m_table[ncrd_q[0]].dtr_req_rcvd == 1)||
           (isCmdNcCacheOpsMsg(m_table[ncrd_q[0]].msg_type) && m_table[ncrd_q[0]].str_rsp_sent == 1)) begin 
         release_aiu_table(m_aiu_entry); 
         delete_LUT(ncrd_q[0]);
         `uvm_info(LABEL, $sformatf("::nc_cmd_rsp_LUT:: Received for NcRd"), UVM_HIGH)
       end
     end
     else if(ncwr_q.size == 1)begin
       m_table[ncwr_q[0]].cmd_rsp_rcvd = 1;
       print_LUT_line("::nc_cmd_rsp_LUT",`__LINE__, ncwr_q[0]);
       if (m_table[ncwr_q[0]].str_rsp_sent == 1  && m_table[ncwr_q[0]].dtw_rsp_rcvd == 1) begin 
         release_aiu_table(m_aiu_entry); 
         delete_LUT(ncwr_q[0]);
         //delete_addr = 1;
         `uvm_info(LABEL, $sformatf("::nc_cmd_rsp_LUT:: Received for NcWr"), UVM_HIGH)
       end
     end
     else begin
       m_table[atmld_q[0]].cmd_rsp_rcvd = 1;
       print_LUT_line("::nc_cmd_rsp_LUT",`__LINE__, atmld_q[0]);
       if (m_table[atmld_q[0]].str_rsp_sent == 1  && m_table[atmld_q[0]].dtr_req_rcvd == 1 && m_table[atmld_q[0]].dtw_rsp_rcvd == 1) begin 
         release_aiu_table(m_aiu_entry); 
         delete_LUT(atmld_q[0]);
         //delete_addr = 1;
         `uvm_info(LABEL, $sformatf("::nc_cmd_rsp_LUT:: Received for Atomics"), UVM_HIGH)
       end
     end
  end
endfunction

function resource_manager::process_dtr_LUT(ref smi_seq_item m_item, input aiu_id_t m_aiu_entry);
  int mrd_q[$], ncrd_q[$], atmld_q[$], dtw_mrg_mrd_q[$];
  
  mrd_q = m_table.find_index with(item.aiu_id == m_aiu_entry.aiu_id &&
                                  item.aiu_msg_id == m_aiu_entry.msg_id &&
                                 !item.dtr_req_rcvd &&
                                  item.is_coh_rd_TT);

  ncrd_q = m_table.find_index with(item.is_aiu_match(item.aiu_entry,m_aiu_entry) &&
                                   !item.dtr_req_rcvd&&
                                   item.is_non_coh_rd_TT);

  atmld_q = m_table.find_index with(item.is_aiu_match(item.aiu_entry,m_aiu_entry) &&
                                   !isCmdNcCacheOpsMsg(item.msg_type) &&
                                   !item.dtr_req_rcvd &&
                                   item.is_atm_ld_TT);

  dtw_mrg_mrd_q = m_table.find_index with(item.isMrgMrd  &&
                                          item.is_aiu_match(item.dtr_aiu_entry,m_aiu_entry) &&
                                          !item.dtr_req_rcvd&&
                                          item.is_coh_wr_TT);

  if(mrd_q.size +ncrd_q.size + atmld_q.size + dtw_mrg_mrd_q.size == 0) begin
    `uvm_error(LABEL, $sformatf("::dtr_LUT:: No NcRd :%0d or NcWr :%0d or NcLd :%0d matches this dtr req",mrd_q.size,ncrd_q.size,atmld_q.size))
  end
  else if ((mrd_q.size +ncrd_q.size() + atmld_q.size() + dtw_mrg_mrd_q.size) > 1) begin
    print_LUT_matches({mrd_q,ncrd_q,atmld_q,dtw_mrg_mrd_q});
    `uvm_error(LABEL, $sformatf("::dtr_LUT:: Multiple NcRd :%0d or NcWr :%0d or NcLd :%0d  matches this dtr req",mrd_q.size,ncrd_q.size,atmld_q.size))
  end
  else begin
    if(mrd_q.size == 1)begin
     m_table[mrd_q[0]].dtr_req_rcvd = 1;
     print_LUT_line("::dtr_LUT",`__LINE__, mrd_q[0]);
     if (m_table[mrd_q[0]].mrd_rsp_rcvd == 1) begin 
       release_aiu_table(m_aiu_entry); 
       `uvm_info(LABEL, $sformatf("::dtr_LUT:: Received for Mrd"), UVM_HIGH)
       delete_LUT(mrd_q[0]);
     end
    end
    else if(ncrd_q.size == 1) begin
     m_table[ncrd_q[0]].dtr_req_rcvd = 1;
     print_LUT_line("::dtr_LUT",`__LINE__, ncrd_q[0]);
     if (m_table[ncrd_q[0]].cmd_rsp_rcvd == 1 && m_table[ncrd_q[0]].str_rsp_sent == 1) begin 
       release_aiu_table(m_aiu_entry); 
       `uvm_info(LABEL, $sformatf("::dtr_LUT:: Received for NcRd"), UVM_HIGH)
       delete_LUT(ncrd_q[0]);
     end
    end
    else if(atmld_q.size == 1) begin
      m_table[atmld_q[0]].dtr_req_rcvd = 1;
      print_LUT_line("::dtr_LUT",`__LINE__, atmld_q[0]);
      if (m_table[atmld_q[0]].cmd_rsp_rcvd == 1 && m_table[atmld_q[0]].str_rsp_sent == 1 && m_table[atmld_q[0]].dtw_rsp_rcvd == 1 ) begin 
        release_aiu_table(m_aiu_entry); 
        `uvm_info(LABEL, $sformatf("::dtr_LUT:: Received for Atomics "), UVM_HIGH)
        delete_LUT(atmld_q[0]);
      end
    end
    else begin
      m_table[dtw_mrg_mrd_q[0]].dtr_req_rcvd = 1;
      print_LUT_line("::dtr_LUT",`__LINE__, dtw_mrg_mrd_q[0]);
      if(m_table[dtw_mrg_mrd_q[0]].isMrgMrd)begin
        release_aiu_table(m_aiu_entry);
        if(m_table[dtw_mrg_mrd_q[0]].dtw_rsp_rcvd == 1 ) begin 
          m_aiu_entry.aiu_id   = m_table[dtw_mrg_mrd_q[0]].aiu_id;
          m_aiu_entry.msg_id   = m_table[dtw_mrg_mrd_q[0]].smi_msg_id;  //TBD
          release_aiu_table(m_aiu_entry); 
          `uvm_info(LABEL, $sformatf("::dtr_LUT:: Received for dtwMrgMrd "), UVM_HIGH)
          if(m_table[dtw_mrg_mrd_q[0]].rb_rsp_rcvd)begin
            delete_LUT(dtw_mrg_mrd_q[0]);
          end
        end
      end
    end
  end
endfunction

function resource_manager::process_str_LUT(ref smi_seq_item m_item, input aiu_id_t m_aiu_entry);
  int ncrd_q[$], ncwr_q[$], atmld_q[$];
  ncrd_q = m_table.find_index with(item.is_aiu_match(item.aiu_entry,m_aiu_entry) &&
                                   item.str_req_rcvd &&
                                  !item.str_rsp_sent  &&
                                   item.is_non_coh_rd_TT);

  ncwr_q = m_table.find_index with(item.is_aiu_match(item.aiu_entry,m_aiu_entry) &&
                                   item.str_req_rcvd &&
                                  !item.str_rsp_sent &&
                                   item.is_non_coh_wr_TT);

  atmld_q = m_table.find_index with(item.is_aiu_match(item.aiu_entry,m_aiu_entry) &&
                                    item.str_req_rcvd &&
                                   !item.str_rsp_sent  &&
                                    item.is_atm_ld_TT);
  `uvm_guarded_info(m_args.k_stimulus_debug,LABEL, $sformatf("::str_LUT:: StrReq match | NcRd :%0d NcWr :%0d NcLd :%0d",ncrd_q.size,ncwr_q.size,atmld_q.size),UVM_HIGH)
  if(ncrd_q.size +ncwr_q.size + atmld_q.size == 0) begin
    `uvm_error(LABEL, $sformatf("::str_LUT::No NcRd :%0d or NcWr :%0d or NcLd :%0d match this StrReq",ncrd_q.size,ncwr_q.size,atmld_q.size))
  end
  else if (ncrd_q.size +ncwr_q.size + atmld_q.size > 1) begin
    print_LUT_matches({ncrd_q,ncwr_q,atmld_q});
    `uvm_error(LABEL, $sformatf("::str_LUT::Multiple NcRd :%0d or NcWr :%0d or NcLd :%0d  match this StrReq",ncrd_q.size,ncwr_q.size,atmld_q.size))
  end
  else begin
    if(ncrd_q.size == 1)begin
      m_table[ncrd_q[0]].str_rsp_sent = 1;
      print_LUT_line("::str_rsp_LUT",`__LINE__, ncrd_q[0]);
      if ((m_table[ncrd_q[0]].cmd_rsp_rcvd == 1 && m_table[ncrd_q[0]].dtr_req_rcvd == 1 && m_table[ncrd_q[0]].str_req_rcvd) ||
          (isCmdNcCacheOpsMsg(m_table[ncrd_q[0]].msg_type) && m_table[ncrd_q[0]].cmd_rsp_rcvd == 1 && m_table[ncrd_q[0]].str_req_rcvd == 1)) begin 
        release_aiu_table(m_aiu_entry); 
        delete_LUT(ncrd_q[0]);
        `uvm_info(LABEL, $sformatf("::str_LUT::Received for NcRd"), UVM_HIGH)
      end
    end
    else if(ncwr_q.size == 1) begin
      m_table[ncwr_q[0]].str_rsp_sent = 1;
      print_LUT_line("::str_rsp_LUT",`__LINE__, ncwr_q[0]);
      if (m_table[ncwr_q[0]].cmd_rsp_rcvd == 1 && m_table[ncwr_q[0]].dtw_rsp_rcvd == 1 && m_table[ncwr_q[0]].str_req_rcvd ) begin 
        release_aiu_table(m_aiu_entry); 
        delete_LUT(ncwr_q[0]);
        `uvm_info(LABEL, $sformatf("::str_LUT::Received for NcWr"), UVM_HIGH)
      end
    end
    else  begin
      m_table[atmld_q[0]].str_rsp_sent = 1;
      print_LUT_line("::str_rsp_LUT",`__LINE__, atmld_q[0]);
      if (m_table[atmld_q[0]].cmd_rsp_rcvd == 1 && m_table[atmld_q[0]].dtw_rsp_rcvd == 1 && m_table[atmld_q[0]].dtr_req_rcvd == 1 ) begin 
        release_aiu_table(m_aiu_entry); 
        delete_LUT(atmld_q[0]);
        //delete_addr = 1;
        `uvm_info(LABEL, $sformatf("::str_LUT::Received for AtmNcWr"), UVM_HIGH)
      end
    end
  end
endfunction

function resource_manager::process_dtw_rsp_LUT(ref smi_seq_item m_item, input aiu_id_t m_aiu_entry, output resource_semaphore_t computed_outcome);
  int dtw_q[$], dtw_mw_q[$], ncwr_q[$], atmld_q[$];
  //numDtwRsp++;
  dtw_q = m_table.find_index with( item.is_aiu_match(item.aiu_entry,m_aiu_entry) &&
                                  !item.dtw_rsp_rcvd  &&
                                   item.is_coh_wr_TT);

  dtw_mw_q = m_table.find_index with( item.isMW &&
                                     (item.dtws_expd == 2) &&
                                     (item.secondary_aiu_id == m_aiu_entry.aiu_id) &&
                                     (item.secondary_smi_msg_id == m_aiu_entry.msg_id) &&
                                     !item.secondary_dtw_rsp_rcvd &&
                                      item.is_coh_wr_TT);

  ncwr_q = m_table.find_index with( item.is_aiu_match(item.aiu_entry,m_aiu_entry) &&
                                    item.str_req_rcvd &&
                                   !item.dtw_rsp_rcvd  &&
                                    item.is_non_coh_wr_TT);

  atmld_q = m_table.find_index with( item.is_aiu_match(item.aiu_entry,m_aiu_entry) &&
                                     item.str_req_rcvd &&
                                    !item.dtw_rsp_rcvd  &&
                                     item.is_atm_ld_TT);
  `uvm_guarded_info(m_args.k_stimulus_debug,LABEL, $sformatf("::dtw_rsp_LUT:: DtwRsp Matches || Dtw:%0d DtwMw:%0d NcWr:%0d AtmLd:%0d",dtw_q.size,dtw_mw_q.size,ncwr_q.size,atmld_q.size),UVM_HIGH)
  if (dtw_q.size + ncwr_q.size + atmld_q.size +dtw_mw_q.size == 0) begin
     `uvm_error(LABEL, $sformatf("::dtw_rsp_LUT:: No Ch/Nc dtw,AtmLoad  matches this Dtw rsp receiced :tgt_unit_id :%0x smi_rmsg_id :%d ",m_aiu_entry.aiu_id,m_aiu_entry.msg_id))
  end
  else if (dtw_q.size + ncwr_q.size + atmld_q.size + dtw_mw_q.size  > 1) begin
      print_LUT_matches({dtw_q,ncwr_q,atmld_q,dtw_mw_q});
     `uvm_error(LABEL, $sformatf("::dtw_rsp_LUT:: Multiple dtw for this Dtw rsp ChWr :%0d ChWrMw:%0d NcWr :%0d AtmLd :%0d",dtw_q.size,dtw_mw_q.size,ncwr_q.size,atmld_q.size))
  end
  else begin
    if(dtw_q.size == 1)begin 
      m_table[dtw_q[0]].dtw_rsp_rcvd = 1;          
      if(m_table[dtw_q[0]].rb_rsp_rcvd && !m_table[dtw_q[0]].rb_released) begin
        `uvm_error(LABEL, $sformatf("::dtw_rsp_LUT:: RBID:%0h should have been released earlier", m_table[dtw_q[0]].smi_rbid))
      end
      //m_item.isDtw      =  1;
      `uvm_info(LABEL, $sformatf("::dtw_rsp_LUT:: Received for Coh Dtw"), UVM_MEDIUM)
      if(m_table[dtw_q[0]].isMrgMrd)begin
        if(m_table[dtw_q[0]].dtr_req_rcvd == 1)begin
          //delete_addr = 1;
          release_aiu_table(m_aiu_entry); 
          m_aiu_entry.aiu_id   = m_item.smi_targ_ncore_unit_id;
          m_aiu_entry.msg_id   = m_item.smi_rmsg_id; 
          print_LUT_line("::dtw_rsp_LUT",`__LINE__, dtw_q[0]);
          if(m_table[dtw_q[0]].rb_rsp_rcvd)begin
           delete_LUT(dtw_q[0]);
          end
        end
      end
      else begin
        release_aiu_table(m_aiu_entry); 
        print_LUT_line("::dtw_rsp_LUT",`__LINE__, dtw_q[0]);
        if(m_table[dtw_q[0]].isMW && (m_table[dtw_q[0]].dtws_expd == 1))begin
          if(m_table[dtw_q[0]].rb_rsp_rcvd && m_table[dtw_q[0]].dtw_rsp_rcvd)begin
            delete_LUT(dtw_q[0]);
          end
        end
        else begin
          if(m_table[dtw_q[0]].rb_rsp_rcvd)begin
            delete_LUT(dtw_q[0]);
          end
        end
      end
    end
    else if(dtw_mw_q.size == 1)begin 
      m_table[dtw_mw_q[0]].secondary_dtw_rsp_rcvd = 1;
      if(m_table[dtw_mw_q[0]].dtws_expd == 2) begin
        `uvm_info(LABEL, $sformatf("::dtw_rsp_LUT:: Sending primary DTW for MW on RBID:%0h",m_table[dtw_mw_q[0]].smi_rbid), UVM_MEDIUM)
        computed_outcome.flag = 1;
        computed_outcome._type = MERGING_WRITE;
        computed_outcome.mw_rbid = m_table[dtw_mw_q[0]].smi_rbid;
      end
      release_aiu_table(m_aiu_entry); 
      print_LUT_line("::dtw_rsp_LUT",`__LINE__, dtw_mw_q[0]);
      if(m_table[dtw_mw_q[0]].rb_rsp_rcvd && m_table[dtw_mw_q[0]].dtw_rsp_rcvd)begin
        delete_LUT(dtw_mw_q[0]);
      end
    end
    else if(ncwr_q.size() == 1) begin
      m_table[ncwr_q[0]].dtw_rsp_rcvd = 1;
      print_LUT_line("::dtw_rsp_LUT",`__LINE__, ncwr_q[0]);
      `uvm_info(LABEL, $sformatf("::dtw_rsp_LUT:: Non-Coh DTWRsp recevied"), UVM_MEDIUM)
      if(m_table[ncwr_q[0]].cmd_rsp_rcvd == 1 && m_table[ncwr_q[0]].str_rsp_sent == 1)begin 
        `uvm_info(LABEL, $sformatf("::dtw_rsp_LUT:: Non-Coh DTWRsp with CmdRsp & StrRsp recevied"), UVM_MEDIUM)
        release_aiu_table(m_aiu_entry); 
        delete_LUT(ncwr_q[0]);
      end  
    end
    else  begin
      m_table[atmld_q[0]].dtw_rsp_rcvd = 1;
      `uvm_info(LABEL, $sformatf("::dtw_rsp_LUT:: Received for Atomics"), UVM_MEDIUM)
      print_LUT_line("::dtw_rsp_LUT",`__LINE__, atmld_q[0]);
      if(m_table[atmld_q[0]].cmd_rsp_rcvd == 1 && m_table[atmld_q[0]].str_rsp_sent == 1 && m_table[atmld_q[0]].dtr_req_rcvd == 1)begin 
        release_aiu_table(m_aiu_entry); 
        `uvm_info(LABEL, $sformatf("::dtw_rsp_LUT:: Received for Atomics but DTR pending"), UVM_MEDIUM)
        delete_LUT(atmld_q[0]);
      end
    end
  end
endfunction

function resource_manager::process_rb_rsp_LUT(ref smi_seq_item m_item, input aiu_id_t m_aiu_entry);
  int dtw_q[$];
  int all_rls_q[$], all_int_wr_q[$], mixed_q[$];
  bit delete_dtw_entry, clean_smi_id;

  dtw_q  = m_table.find_index with((item.smi_rbid == m_item.smi_rbid) &&
                                   (item.dce_id  == m_aiu_entry.aiu_id ) &&
                                   !item.rb_rsp_rcvd &&
                                    item.is_coh_wr_TT);

  if(dtw_q.size()>1) begin 
    print_LUT_matches(dtw_q);
    `uvm_error(LABEL, $sformatf("::rb_rsp_LUT:: Found multiple matches for RBID:%0h. dtw_q: %0p", m_item.smi_rbid, dtw_q))
  end
  else if(dtw_q.size()==0) begin
    `uvm_error(LABEL, $sformatf("::rb_rsp_LUT:: RbRsp with RBID:%0h entry:%0p not matching any pending RbReq",m_item.smi_rbid, m_aiu_entry))
  end

  //1. All internal release case: Release immediately, no dependency
  all_rls_q = m_table.find_index with((item.smi_rbid[WSMIRBID-2:0] === m_item.smi_rbid[WSMIRBID-2:0]) &&
                                      (item.dce_id  == m_aiu_entry.aiu_id ) &&
                                       item.rb_rl_rsp_expd &&
                                      !item.rb_released &&
                                       item.is_coh_wr_TT);
  //2. All DTW case: Both the RBs are being used to send coherent data. Release only on receiving DtwRsp+RbRsp per entry
  all_int_wr_q =  m_table.find_index with((item.smi_rbid[WSMIRBID-2:0] === m_item.smi_rbid[WSMIRBID-2:0]) &&
                                          (item.dce_id  == m_aiu_entry.aiu_id ) &&
                                          !item.rb_rl_rsp_expd &&
                                          !item.rb_released&&
                                           item.is_coh_wr_TT);
  //3. Mixed case, wait on both RBrsp to release (rbid, flipped_rbid). Release on second RBRsp and delete both m_table entries
  mixed_q = m_table.find_index with((item.smi_rbid[WSMIRBID-2:0] === m_item.smi_rbid[WSMIRBID-2:0]) &&
                                    (item.dce_id  == m_aiu_entry.aiu_id ) &&
                                    (item.rb_rl_rsp_expd || item.dtws_expd > 0) &&
                                    !item.rb_released &&
                                     item.is_coh_wr_TT);

  if(dtw_q.size == 1)begin 
     m_table[dtw_q[0]].rb_rsp_rcvd = 1;
     //m_item.isDtw      =  1;
     if(m_table[dtw_q[0]].isMW) begin 
       if(m_table[dtw_q[0]].dtws_expd == 1) begin
          if(m_table[dtw_q[0]].isMrgMrd) begin
             if(m_table[dtw_q[0]].dtw_rsp_rcvd && m_table[dtw_q[0]].dtr_req_rcvd)begin
               `uvm_info(LABEL,$sformatf("::rb_rsp_LUT:: MW set with 1 DtwRsp, RbRsp and DtrReq received for DtwMrg| RBID:%0h",m_table[dtw_q[0]].smi_rbid),UVM_HIGH)
               delete_dtw_entry = 1;
             end
          end
          else if(m_table[dtw_q[0]].dtw_rsp_rcvd) begin
            `uvm_info(LABEL,$sformatf("::rb_rsp_LUT:: MW set with 1 DtwRsp and RbRsp received | RBID:%0h",m_table[dtw_q[0]].smi_rbid),UVM_HIGH)
             delete_dtw_entry = 1;
          end
       end
       else begin
         if(m_table[dtw_q[0]].isMrgMrd)begin
           if(m_table[dtw_q[0]].dtw_rsp_rcvd && m_table[dtw_q[0]].secondary_dtw_rsp_rcvd && m_table[dtw_q[0]].dtr_req_rcvd)begin
             //TODO refine releasing cohrbid in these cases
             `uvm_info(LABEL,$sformatf("::rb_rsp_LUT:: MrgMrd with both DTWs and DTR received | RBID:%0h",m_table[dtw_q[0]].smi_rbid),UVM_HIGH)
             delete_dtw_entry = 1;
           end
         end
         else begin
           if(m_table[dtw_q[0]].dtw_rsp_rcvd && m_table[dtw_q[0]].secondary_dtw_rsp_rcvd)begin
             `uvm_info(LABEL,$sformatf("::rb_rsp_LUT:: 2-DTW with both received | RBID:%0h",m_table[dtw_q[0]].smi_rbid),UVM_HIGH)
             delete_dtw_entry = 1;
           end
         end
       end
     end
     else if(m_table[dtw_q[0]].isMrgMrd && !m_table[dtw_q[0]].isMW) begin 
       if(m_table[dtw_q[0]].dtw_rsp_rcvd && m_table[dtw_q[0]].dtr_req_rcvd)begin
        `uvm_info(LABEL,$sformatf("::rb_rsp_LUT:: MrgMrd MW:0 with DTW and DTR received| RBID:%0h",m_table[dtw_q[0]].smi_rbid),UVM_HIGH)
         delete_dtw_entry = 1; 
       end
     end
     else if(m_table[dtw_q[0]].isMrgMrd && m_table[dtw_q[0]].isMW && (m_table[dtw_q[0]].dtws_expd == 2)
            && m_table[dtw_q[0]].dtw_rsp_rcvd && !m_table[dtw_q[0]].secondary_dtw_rsp_rcvd) begin
       `uvm_info(LABEL,$sformatf("::rb_rsp_LUT:: MrgMrd MW:1 2-DTW waiting on second DTW (pending delete)| RBID:%0h",m_table[dtw_q[0]].smi_rbid),UVM_HIGH)
     end
     else begin
       if(m_table[dtw_q[0]].rb_rl_rsp_expd && !m_table[dtw_q[0]].rb_rl_rsp_rcvd) begin
         m_table[dtw_q[0]].rb_rl_rsp_rcvd = 1;
         `uvm_info(LABEL,$sformatf("::rb_rsp_LUT:: Internal release received| RBID:%0h",m_table[dtw_q[0]].smi_rbid),UVM_HIGH)
         delete_dtw_entry = 1;
       end
       if(m_table[dtw_q[0]].dtw_rsp_rcvd) begin
        `uvm_info(LABEL,$sformatf("::rb_rsp_LUT:: Internal release with DTW response received?!? | RBID:%0h",m_table[dtw_q[0]].smi_rbid),UVM_HIGH) //FIXME priority-2 violation
         delete_dtw_entry = 1;
       end
     end
  end

  //Decide RBID release process
  `uvm_info(LABEL,$sformatf("::rb_rsp_LUT:: Matches found all_rls_q: %0d, all_int_wr_q: %0d, mixed_q: %0d dtw_q: %0d | RBID:%0h", all_rls_q.size(), all_int_wr_q.size(), mixed_q.size(), dtw_q.size(), m_item.smi_rbid),UVM_MEDIUM)

  if(all_rls_q.size() == 2 && dtw_q.size()==1) begin
    foreach(all_rls_q[i]) begin
      if(m_table[all_rls_q[i]].rb_rl_rsp_rcvd ) begin //Process internal release when both responses are received
        m_aiu_entry.aiu_id   = m_table[all_rls_q[i]].aiu_id;
        m_aiu_entry.msg_id   = m_table[all_rls_q[i]].smi_msg_id; 
        release_aiu_table(m_aiu_entry); 
        release_RBID(m_table[all_rls_q[i]].smi_rbid);
        m_table[all_rls_q[i]].rb_released = 1;
        print_LUT_line("::rb_rsp_LUT",`__LINE__, all_rls_q[i]);
      end
    end
  end
  else if(mixed_q.size() == 2) begin
    foreach(mixed_q[i])begin
     if(m_table[mixed_q[i]].rb_rsp_rcvd  && m_table[mixed_q[i]].rb_rl_rsp_expd && m_table[mixed_q[i]].rb_rl_rsp_rcvd &&
        all_rls_q.size() != 2
     ) begin //Make sure you process internal release when both transactions are received in a mixed case
        m_aiu_entry.aiu_id   = m_table[mixed_q[i]].aiu_id;
        m_aiu_entry.msg_id   = m_table[mixed_q[i]].smi_msg_id; 
        release_aiu_table(m_aiu_entry); 
        release_RBID(m_table[mixed_q[i]].smi_rbid);
        m_table[mixed_q[i]].rb_released = 1;
        print_LUT_line("::rb_rsp_LUT",`__LINE__, mixed_q[i]);
     end
    end
  end
  else if(all_int_wr_q.size() inside {1,2}) begin
    foreach(all_int_wr_q[i])begin
      //Early Single or Double Coherent Write from DCE
      if(( m_table[all_int_wr_q[i]].rb_rsp_rcvd &&
          !m_table[all_int_wr_q[i]].isMW && (m_table[all_int_wr_q[i]].smi_rbid == m_item.smi_rbid) && !m_table[all_int_wr_q[i]].rb_released)) begin
        release_RBID(m_table[all_int_wr_q[i]].smi_rbid);
        m_table[all_int_wr_q[i]].rb_released = 1;
        print_LUT_line("::rb_rsp_LUT",`__LINE__, all_int_wr_q[i]);
      end
      else if((m_table[all_int_wr_q[i]].isMW || m_table[all_int_wr_q[i]].isMrgMrd) && m_table[all_int_wr_q[i]].rb_rsp_rcvd) begin
        `uvm_info(LABEL,$sformatf("::rb_rsp_LUT:: Expecting a second DTW response, releasing RBID:%0h but retaining information in m_table",m_table[all_int_wr_q[i]].smi_rbid),UVM_HIGH) //FIXME
        release_RBID(m_table[all_int_wr_q[i]].smi_rbid);
        m_table[all_int_wr_q[i]].rb_released = 1;
        print_LUT_line("::rb_rsp_LUT",`__LINE__, all_int_wr_q[i]);
      end
    end
  end
  else begin
    `uvm_error(LABEL, $sformatf("::rb_rsp_LUT:: Failed to match RbRsp to any existing DTW info items RBID:%0h", m_item.smi_rbid))
  end 
  if(delete_dtw_entry) begin
     delete_LUT(dtw_q[0]);
     `uvm_info(LABEL, $sformatf("::rb_rsp_LUT:: Deleting entry %0d m_table size:%0d", dtw_q[0], m_table.size()),UVM_HIGH);
  end
endfunction

//DMI Lookup Table End///////////////////////////////////////////////////////////////////////////////////////////////////////


//Useful Common Operations Begin/////////////////////////////////////////////////////////////////////////////////////////////
function bit resource_manager::isCmdNcCacheOpsMsg(MsgType_t msgType);
  return (msgType inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF}); 
endfunction : isCmdNcCacheOpsMsg

function bit resource_manager::isCoherentRead(smi_type_t msg_type);
  return (msg_type inside {MRD_RD_WITH_SHR_CLN,MRD_RD_WITH_UNQ_CLN,MRD_RD_WITH_UNQ,MRD_RD_WITH_INV,MRD_FLUSH,MRD_CLN,MRD_INV,MRD_PREF});
endfunction : isCoherentRead

function string resource_manager::smi_type_string(smi_type_t msg_type);
  smi_msg_type_e _type;
  string _s, _sfx;
  _type = smi_msg_type_e'(msg_type);
  _sfx  = $sformatf("%0s",_type.name);
  _s    = _sfx.substr(0,_sfx.len()-3);
  return(_s);
endfunction

function smi_addr_t resource_manager::size_aligned(smi_addr_t addr, int size);
  smi_addr_t m_addr = (addr/size)*size;
  return((addr/size)*size);
endfunction : size_aligned

function smi_addr_t resource_manager::zero_extend_d2d_addr(smi_addr_t m_addr);
  return(m_addr[WAXADDR-1:0]);
endfunction : zero_extend_d2d_addr

function smi_addr_t resource_manager::cl_aligned(smi_addr_t addr);
  return(addr >> $clog2(N_SYS_CACHELINE));
endfunction : cl_aligned

function bit resource_manager::filter_SP_interleave();
  foreach(m_addr_q[i]) begin
    foreach(m_addr_q[i][j]) begin
      smi_addr_t caddy;
      caddy = ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(m_addr_q[i][j],0);
      m_addr_q[i][j] = ncoreConfigInfo::gen_full_cache_addr_from_spad_addr(caddy,0);
    end
  end
endfunction : filter_SP_interleave

function bit resource_manager::cl_aligned_match(smi_addr_t lhs, rhs);

  return(cl_aligned(lhs) == cl_aligned(rhs));
endfunction : cl_aligned_match
//Useful Common Operations End  /////////////////////////////////////////////////////////////////////////////////////////////
