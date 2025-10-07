class packet_generator_base_seq extends uvm_sequence;

  `uvm_object_utils(packet_generator_base_seq)
  `uvm_declare_p_sequencer(smi_virtual_sequencer)

  static int unique_table_id = 0;
  //Instances
  dmi_env_config    m_cfg;  
  dmi_cmd_args      m_args;
  resource_manager  m_rsrc_mgr;

  //Functions
  extern function new(string name="packet_generator_base_seq");
  extern function initialize();
  extern function get_rsrc_mgr(const ref resource_manager _mgr);
  extern function get_args(const ref dmi_cmd_args _args);
  extern static function int get_unique_table_id();
  
  //Packet construction functions
  extern function construct_packet(traffic_seq m_seq, ref smi_seq_item smi_dispatch_q[$], ref smi_seq_item MW_primary_dtw_q[$]);
  extern function construct_cmd(ref traffic_seq m_seq, ref smi_seq_item smi_dispatch_q[$]);
  extern function construct_dtw(ref traffic_seq m_seq, ref smi_seq_item smi_dispatch_q[$], ref smi_seq_item MW_primary_dtw_q[$]);
  extern function construct_mrd(ref traffic_seq m_seq, ref smi_seq_item smi_dispatch_q[$]);
  extern function construct_atomic_compare_hit(ref traffic_seq m_seq, ref smi_seq_item smi_dispatch_q[$]);
  extern function construct_internal_release(ref traffic_seq m_seq, ref smi_seq_item smi_dispatch_q[$]);
  extern function construct_store_exclusive(ref traffic_seq m_seq, ref cmd_seq_item m_item);

  //Constraining functions
  extern function bit c_EX_CMD_probability(ref traffic_seq m_seq, ref cmd_seq_item m_item);

endclass : packet_generator_base_seq

function packet_generator_base_seq::new(string name="packet_generator_base_seq");
  super.new(name);
  initialize();
endfunction : new

function packet_generator_base_seq::get_rsrc_mgr(const ref resource_manager _mgr);
  m_rsrc_mgr = _mgr;
endfunction

function packet_generator_base_seq::get_args(const ref dmi_cmd_args _args);
  m_args = _args;
endfunction

function packet_generator_base_seq::initialize();
  //Get knobs
  if(!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                          .inst_name( "uvm_test_top.*" ),
                                          .field_name( "dmi_env_config" ),
                                          .value( m_cfg ))) begin
    `uvm_error("packet_generator_base_seq", "::init:: dmi_env_config handle not found")
  end
  get_args(m_cfg.m_args);
  get_rsrc_mgr(m_cfg.m_rsrc_mgr);
endfunction : initialize

static function int packet_generator_base_seq::get_unique_table_id();
   return(unique_table_id++);
endfunction : get_unique_table_id

/*TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
Stage 0
  1. Bringup --DONE
  2. Resource management --DONE
  3. Dispatch --DONE
  4. Arbitration --DONE
Stage 1
  1. Once Tx and Rx flow is clean --DONE
  2. Work on randomizing just CMD_WR and CMD_RD and get a RAW test flowing. --DONE
  3. Then Coherent writes --DONE 
  4. Then Coherent reads --DONE
  5. Finally Atomics --DONE
Stage 2 : Cross-domain traffic.
  1. Non-coherent read/write  --DONE
  2. Coherent read/write together  --DONE
  3. Coherent/Non-coherent together --DONE
  4. All Random traffic --DONE
Stage 3 : Address queues
  1. Target different type of address arrangement --TODO -- Step addresses, Same Set
  2. Coherent/Non-Coherent addressing mixed --DONE
Stage 4: Randomization
  1. Constraints are doing what they are supposed to per sequence item --DONE
  2. Run coverage on tests to check what's being hit -All Configs DONE
Stage 5: Traffic pattern
  1. Random pattern, all ON --DONE
  2. Exercising basic scenarios aka RAW etc
  3. Special scenarios, corner cases
Stage 6: Port all tests from old testlist
  1. Unitduplication -- Done
  2. Q Channel -- Done
  3. Resiliency errors -- 
  4. CSR error testing -- 
  5. MntOp testing -- WIP
  
  TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO*/
function packet_generator_base_seq::construct_packet(traffic_seq m_seq, ref smi_seq_item smi_dispatch_q[$], ref smi_seq_item MW_primary_dtw_q[$]);
  if(m_seq.m_pattern == DMI_CMP_ATM_MATCH_p) begin
    `uvm_info("packet_generator_base_seq",$sformatf("::construct_packet:: Chosen Pattern Type:DMI_CMP_ATM_MATCH_p | Generating CMD_WR_ATM->CMD_SW_ATM."),UVM_HIGH)
  end
  else if (m_seq.merging_write) begin
    `uvm_info("packet_generator_base_seq",$sformatf("::construct_packet:: Chosen CCMP-Type:%0s Addr-Type:%0s (Merging Write) #Dtws:%0d"
                                                                          ,m_seq.msg_s,m_seq.m_addr_type.name,(m_seq.merging_write_success_flag ? 2 : 1)),UVM_HIGH)
  end
  else if (m_seq.internal_release) begin
    `uvm_info("packet_generator_base_seq",$sformatf("::construct_packet:: Chosen CCMP-Type:%0s Addr-Type:%0s (Internal Release)",m_seq.msg_s,m_seq.m_addr_type.name),UVM_HIGH)
  end
  else begin
    `uvm_info("packet_generator_base_seq",$sformatf("::construct_packet:: Chosen CCMP-Type:%0s Addr-Type:%0s Pattern:%0s",m_seq.msg_s,m_seq.m_addr_type.name,m_seq.m_pattern.name),UVM_HIGH)
  end
  case (m_seq.m_opcode)
    MRD_RD_WITH_SHR_CLN,MRD_RD_WITH_UNQ_CLN,MRD_RD_WITH_UNQ,
    MRD_RD_WITH_INV,MRD_FLUSH,MRD_CLN,MRD_INV,MRD_PREF: begin
      //Coherent Reads
      construct_mrd(m_seq, smi_dispatch_q);
    end
    DTW_MRG_MRD_UCLN,DTW_MRG_MRD_UDTY,DTW_MRG_MRD_INV,
    DTW_NO_DATA,DTW_DATA_CLN,DTW_DATA_PTL,DTW_DATA_DTY: begin
      //Coherent Writes
      /*if(m_seq.internal_release) begin
        construct_internal_release(m_seq, smi_dispatch_q);
      end
      else begin*/
        construct_dtw(m_seq, smi_dispatch_q, MW_primary_dtw_q);
      //end
    end
    CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF,
    CMD_RD_NC,CMD_WR_NC_FULL,CMD_WR_NC_PTL,
    CMD_WR_ATM,CMD_RD_ATM,CMD_SW_ATM,CMD_CMP_ATM: begin
      //CMOs, Non-Coherent Read/Writes, Atomics
      if(m_seq.m_pattern == DMI_CMP_ATM_MATCH_p) begin
        construct_atomic_compare_hit(m_seq,smi_dispatch_q);
      end
      else begin
        construct_cmd(m_seq, smi_dispatch_q);
      end
    end
    default: begin
      `uvm_error("packet_generator_base_seq",$sformatf("::construct_packet:: Unsupported opcode=%0h",m_seq.m_opcode))
    end
  endcase
endfunction

function packet_generator_base_seq::construct_atomic_compare_hit(ref traffic_seq m_seq, ref smi_seq_item smi_dispatch_q[$]);
  //Since there is no easy way to read the AXI memory model, perform a write atomic followed by a compare atomic on the same address.
  cmd_seq_item wr_atm_txn, cmp_atm_txn;
  smi_seq_item wr_smi_item,cmp_smi_item;
  wr_smi_item = smi_seq_item::type_id::create("wr_smi_item");
  wr_atm_txn  = cmd_seq_item::type_id::create("wr_atm_txn");
  cmp_atm_txn = cmd_seq_item::type_id::create("cmp_atm_txn");
  wr_atm_txn.get_cfg(m_cfg);
  `ASSERT(wr_atm_txn.randomize () with {
                                    smi_msg_type  == CMD_WR_ATM;
                                    m_addr_type   == m_seq.m_addr_type;
                                    m_pattern_type == m_seq.m_pattern;
                                    avoid_SCP_addr == m_seq.avoid_scratchpad;
                                    num_payload_bytes == m_seq.traffic_info.payload_size;
                                    smi_ac        == 1;
                                    smi_prim      == 0;
                                    all_BE_on     == 1;
                                    });
  wr_smi_item.do_copy(wr_atm_txn);
  smi_dispatch_q.push_back(wr_smi_item);
  
  m_rsrc_mgr.add_to_LUT(wr_smi_item,get_unique_table_id(),m_seq.m_pattern);
  cmp_smi_item = smi_seq_item::type_id::create("cmp_smi_item");
  cmp_atm_txn.get_cfg(m_cfg);
  `ASSERT(cmp_atm_txn.randomize () with {
                                    smi_msg_type        == CMD_CMP_ATM;
                                    smi_addr            == wr_atm_txn.smi_addr;
                                    smi_ns              == wr_atm_txn.smi_ns;
                                    smi_ac              == 1;
                                    smi_prim            == 0;
                                    abort_addr_gen      == 1;
                                    abort_full_data_gen == 1;
                                    });
  cmp_atm_txn.copy_data_for_atm_cmp(wr_atm_txn);
  cmp_atm_txn.pkt_id = wr_atm_txn.pkt_id;
  `uvm_guarded_info(m_args.k_stimulus_debug,get_type_name(),$sformatf("::construct_atm_cmp_hit:: Generating atomic on WR Addr:%0h CMP Addr:%0h",wr_atm_txn.smi_addr, cmp_atm_txn.smi_addr),UVM_HIGH)
  cmp_smi_item.do_copy(cmp_atm_txn);
  smi_dispatch_q.push_back(cmp_smi_item);
  m_rsrc_mgr.add_to_LUT(cmp_smi_item,get_unique_table_id(),m_seq.m_pattern);
  m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].exp_cmp_match = 1;
  `uvm_info(get_type_name(),$sformatf("%s",m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].convert2string()),UVM_HIGH)
endfunction

function packet_generator_base_seq::construct_cmd(ref traffic_seq m_seq, ref smi_seq_item smi_dispatch_q[$]);
  cmd_seq_item cmd_txn;
  smi_seq_item smi_item;
  bit exclusive_match_found = 0;
  smi_item = smi_seq_item::type_id::create("smi_item");
  cmd_txn  = cmd_seq_item::type_id::create("cmd_txn");
  cmd_txn.get_cfg(m_cfg);
  `ASSERT(cmd_txn.randomize () with {
                                      smi_msg_type  == m_seq.m_opcode;
                                      m_addr_type   == m_seq.m_addr_type;
                                      m_pattern_type == m_seq.m_pattern;
                                      avoid_SCP_addr == m_seq.avoid_scratchpad;
                                      num_payload_bytes == m_seq.traffic_info.payload_size;
                                      smi_prim      == 0;
                                    });
  construct_store_exclusive(m_seq,cmd_txn);
  smi_item.do_copy(cmd_txn);
  smi_dispatch_q.push_back(smi_item);
  m_rsrc_mgr.add_to_LUT(smi_item,get_unique_table_id(),m_seq.m_pattern);
  if(m_cfg.randomly_streamed_exclusives) begin
    m_rsrc_mgr.add_to_exclusive_q(smi_item);
  end
endfunction

function bit packet_generator_base_seq::c_EX_CMD_probability(ref traffic_seq m_seq, ref cmd_seq_item m_item);
  //Constraint Distribution -- For exclusive Load/Store
  int rand_dist = $urandom_range(1,100);
  if(m_item.smi_msg_type inside {m_seq.load_exclusive_types}) begin
    return 0;
  end
  else begin
    if(((m_cfg.randomly_streamed_exclusives) && 
        (rand_dist <= m_cfg.wt_randomly_streamed_exclusives) &&
        (m_item.smi_es) 
       )) begin
      return(1);
    end
    else begin
      return(0);
    end
  end
endfunction

function packet_generator_base_seq::construct_store_exclusive(ref traffic_seq m_seq, ref cmd_seq_item m_item);
  //Exclusive traffic to elicit PASS/FAIL response from exclusive monitor
  if(c_EX_CMD_probability(m_seq,m_item)) begin
    int LD_match_q[$];
    dmi_exclusive_c LD_EX_item;
    bit is_aiu_specific_entry_available;
    LD_EX_item = new(); 
    LD_match_q = m_rsrc_mgr.load_exclusives_q.find_index with (item.addr == m_item.smi_addr);
    if(LD_match_q.size != 0) begin
      `uvm_info(get_type_name(),$sformatf("::construct_store_exclusive::Before Exclusive Override:: smi_addr=%h smi_src_ncore_unit_id=%h smi_mpf2_flowid=%h", 
                                                                               m_item.smi_addr,m_item.smi_src_ncore_unit_id,m_item.smi_mpf2_flowid), UVM_HIGH)
      LD_EX_item = m_rsrc_mgr.load_exclusives_q[LD_match_q[LD_match_q.size-1]];
      is_aiu_specific_entry_available = (m_rsrc_mgr.aiu_specific_msg_id_is_available(LD_EX_item.src_id));
      m_rsrc_mgr.load_exclusives_q.delete(LD_match_q[LD_match_q.size-1]);
      if(m_item.smi_src_ncore_unit_id != LD_EX_item.src_id) begin
        if(is_aiu_specific_entry_available) begin
          //Release existing reservations in resource manager. Reserve from a matching AIU instead.
          aiu_id_t n_aiu_entry;
          m_rsrc_mgr.release_aiu_table(m_item.aiu_gen_id);
          n_aiu_entry = m_rsrc_mgr.get_aiu_specific_msg_id(LD_EX_item.src_id,"STORE_EXCLUSIVE");
          `uvm_guarded_info(m_args.k_stimulus_debug,get_type_name(),$sformatf("::construct_store_exclusive:: Mismatched Source AIUs: LD_EX_item:%0h m_item:%0h | Got new ID:%0p",
                                                                                                          LD_EX_item.src_id,m_item.smi_src_ncore_unit_id,n_aiu_entry),UVM_HIGH)
          m_item.smi_src_ncore_unit_id = n_aiu_entry.aiu_id;
          m_item.smi_msg_id = n_aiu_entry.msg_id;
          m_item.aiu_gen_id = n_aiu_entry;
          m_item.construct_data(); //Realign, rotate and apply constraints.
          m_item.smi_mpf2_flowid = LD_EX_item.flowid;
          m_item.smi_ns = LD_EX_item.ns;
          `uvm_info(get_type_name(),$sformatf("::construct_store_exclusive::After Exclusive Override(New ID):: smi_addr=%0h smi_src_ncore_unit_id=%0h smi_mpf2_flowid=%0h", 
                                                                                                  m_item.smi_addr,m_item.smi_src_ncore_unit_id,m_item.smi_mpf2_flowid), UVM_HIGH)
        end                                                                                                
      end
      else if(m_item.smi_src_ncore_unit_id == LD_EX_item.src_id) begin
        m_item.smi_mpf2_flowid = LD_EX_item.flowid;
        m_item.smi_ns = LD_EX_item.ns;
        `uvm_info(get_type_name(),$sformatf("::construct_store_exclusive::After Exclusive Override:: isAiuIdAvail:%0b smi_addr=%0h smi_src_ncore_unit_id=%0h smi_mpf2_flowid=%0h", 
                                                                   is_aiu_specific_entry_available,m_item.smi_addr,m_item.smi_src_ncore_unit_id,m_item.smi_mpf2_flowid), UVM_HIGH)
      end
    end
    else begin
      `uvm_info(get_type_name(),$sformatf("::construct_store_exclusive:: No Matches Found || load_exclusives_q:%0d smi_addr=%0h ", 
                                                                            m_rsrc_mgr.load_exclusives_q.size, m_item.smi_addr), UVM_DEBUG)
    end
  end
endfunction

function packet_generator_base_seq::construct_internal_release(ref traffic_seq m_seq, ref smi_seq_item smi_dispatch_q[$]);
  smi_seq_item smi_item;
  rb_seq_item rb_txn;
  dtw_seq_item primary_dtw_txn;
  rb_txn = rb_seq_item::type_id::create("rb_txn");
  primary_dtw_txn  = dtw_seq_item::type_id::create("primary_dtw_txn");
  smi_item = smi_seq_item::type_id::create("smi_item");
  primary_dtw_txn.get_cfg(m_cfg);
  `ASSERT(primary_dtw_txn.randomize() with {
                                    smi_msg_type == m_seq.m_opcode;
                                    m_addr_type  == m_seq.m_addr_type;
                                    m_pattern_type == m_seq.m_pattern;
                                    smi_rbid     == m_seq.m_rbid;
                                    smi_mw       == m_seq.merging_write;
                                    avoid_SCP_addr == m_seq.avoid_scratchpad;
                                    num_payload_bytes == m_seq.traffic_info.payload_size;
                                    smi_prim     == 1;
                                    });
  rb_txn.get_cfg(m_cfg);
  `ASSERT(rb_txn.randomize());
  rb_txn.construct_relevant_rb(primary_dtw_txn);
  smi_item.do_copy(rb_txn);
  smi_dispatch_q.push_back(smi_item);
  m_rsrc_mgr.add_to_LUT(smi_item,get_unique_table_id(),m_seq.m_pattern);
  m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].rb_rl_rsp_expd = 1;
  m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].RBRs_rmsg_id = rb_txn.smi_msg_id;
  m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].dce_id       = rb_txn.smi_src_ncore_unit_id;
  `uvm_info(get_type_name(),$sformatf("%s",m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].convert2string()),UVM_HIGH)
endfunction

function packet_generator_base_seq::construct_dtw(ref traffic_seq m_seq, ref smi_seq_item smi_dispatch_q[$], ref smi_seq_item MW_primary_dtw_q[$]);
  rb_seq_item  rb_txn;
  dtw_seq_item primary_dtw_txn, secondary_dtw_txn; 
  //If 1 DTW only primary| If 2 DTws : Secondary goes first (prim=0), primary is last (prim = 1).
  //Secondary data : Provided by an agent via intervention data response to a snoop, always treated as DIRTY
  //Primary data   : Originating from the agent. Dirty (or) Clean
  smi_seq_item smi_item;
  smi_item = smi_seq_item::type_id::create("smi_item");
  primary_dtw_txn  = dtw_seq_item::type_id::create("primary_dtw_txn");
  rb_txn   = rb_seq_item::type_id::create("rb_txn");
  primary_dtw_txn.get_cfg(m_cfg);
  `ASSERT(primary_dtw_txn.randomize() with {
                                    smi_msg_type   == m_seq.m_opcode;
                                    m_addr_type    == m_seq.m_addr_type;
                                    m_pattern_type == m_seq.m_pattern;
                                    smi_rbid       == m_seq.m_rbid;
                                    smi_mw         == m_seq.merging_write;
                                    abort_data_gen == m_seq.internal_release;
                                    avoid_SCP_addr == m_seq.avoid_scratchpad;
                                    num_payload_bytes == m_seq.traffic_info.payload_size;
                                    });
  rb_txn.get_cfg(m_cfg);
  `ASSERT(rb_txn.randomize());
  rb_txn.construct_relevant_rb(primary_dtw_txn);
  smi_item.do_copy(rb_txn); 
  smi_dispatch_q.push_back(smi_item);
  if(m_seq.merging_write_success_flag) begin
    //Construct Secondary DTW
    secondary_dtw_txn  = dtw_seq_item::type_id::create("secondary_dtw_txn");
    secondary_dtw_txn.get_cfg(m_cfg);
    secondary_dtw_txn.pkt_id = primary_dtw_txn.pkt_id;
    `ASSERT(secondary_dtw_txn.randomize() with {
                                    //smi_msg_type inside {DTW_DATA_DTY,DTW_MRG_MRD_UDTY,DTW_MRG_MRD_UCLN,DTW_MRG_MRD_INV}; FIXME --Priority-1
                                    smi_msg_type inside {DTW_DATA_DTY};
                                    smi_rbid       == m_seq.m_rbid;
                                    smi_tm         == primary_dtw_txn.smi_tm;
                                    num_payload_bytes == 64;
                                    abort_addr_gen == 1;
                                    smi_prim       == 0;
                                    smi_mw         == 1;
                                    });
    smi_item = smi_seq_item::type_id::create("smi_item");
    smi_item.do_copy(secondary_dtw_txn);
    smi_dispatch_q.push_back(smi_item);
  end
  smi_item = smi_seq_item::type_id::create("smi_item");
  smi_item.do_copy(primary_dtw_txn);
  if(!m_seq.internal_release) begin
    if(!m_seq.merging_write_success_flag) begin
      smi_dispatch_q.push_back(smi_item);
    end
    else begin
      MW_primary_dtw_q.push_back(smi_item);
    end
  end
  m_rsrc_mgr.add_to_LUT(smi_item,get_unique_table_id(),m_seq.m_pattern);
  m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].dce_id = rb_txn.smi_src_ncore_unit_id;
  m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].RBRs_rmsg_id = rb_txn.smi_msg_id;
  m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].rb_rl_rsp_expd = m_seq.internal_release;
  if(m_seq.merging_write) begin
    m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].isMW = 1;
    if(m_seq.merging_write_success_flag) begin
      m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].secondary_aiu_id = secondary_dtw_txn.smi_src_ncore_unit_id;
      m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].secondary_smi_msg_id = secondary_dtw_txn.smi_msg_id;
      m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].dtws_expd = 2;
    end
    else begin
      m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].dtws_expd = 1;
    end
  end
  `uvm_info(get_type_name(),$sformatf("%s",m_rsrc_mgr.m_table[m_rsrc_mgr.m_table.size-1].convert2string()),UVM_HIGH)
endfunction

function packet_generator_base_seq::construct_mrd(ref traffic_seq m_seq, ref smi_seq_item smi_dispatch_q[$]);
  mrd_seq_item mrd_txn;
  smi_seq_item smi_item;
  smi_item = smi_seq_item::type_id::create("smi_item");
  mrd_txn  = mrd_seq_item::type_id::create("mrd_txn");
  mrd_txn.get_cfg(m_cfg);
  `ASSERT(mrd_txn.randomize () with {
                                    smi_msg_type  == m_seq.m_opcode;
                                    m_addr_type   == m_seq.m_addr_type;
                                    m_pattern_type == m_seq.m_pattern;
                                    avoid_SCP_addr == m_seq.avoid_scratchpad;
                                    num_payload_bytes == m_seq.traffic_info.payload_size;
                                    });
  smi_item.do_copy(mrd_txn);
  smi_dispatch_q.push_back(smi_item);
  m_rsrc_mgr.add_to_LUT(smi_item,get_unique_table_id(),m_seq.m_pattern);
endfunction

