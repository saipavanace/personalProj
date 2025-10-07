

class traffic_base_seq extends uvm_object;

  `uvm_object_param_utils(traffic_base_seq)

  dmi_env_config m_cfg;
  dmi_cmd_args args;
  string msg_s;
  string arg_val;
  traffic_type_pair_t traffic_info;

  function new(string name="traffic_base_seq");
    super.new(name);
  endfunction

  function void get_args(ref dmi_cmd_args r_args);
    args = r_args;
  endfunction

  
endclass
//TODO generate a queue instead of randomizing every single time. Control the re-randomization when all types in a queue are consumed. TODO

class traffic_seq extends traffic_base_seq;
  `uvm_object_param_utils(traffic_seq)
  //Now i need super patterns that choose from other clusters of patterns
  rand dmi_pattern_type_t m_pattern; //Level-1 traffic pattern
  rand dmi_super_pattern_type_t m_super_pattern; //Level-2 traffic pattern
  rand smi_type_t m_opcode;
  randc smi_type_t m_opcode_c;
  rand dmi_addr_format_t m_addr_type;
  rand bit pattern_mode;
  smi_type_t atomic_types[$],mrd_types[$],cmo_types[$],dtwmrgmrd_types[$],coh_write_types[$],noncoh_read_types[$],noncoh_write_types[$];
  smi_type_t read_types[$],write_types[$],write_with_data_types[$];
  smi_type_t load_exclusive_types[$], store_exclusive_types[$];
  smi_rbid_t m_rbid;
  rand smi_msg_id_bit_t aiu_msg_id;
  rand smi_ncore_unit_id_bit_t aiu_id;
  rand bit merging_write;
  bit merging_write_success_flag;
  rand bit internal_release;
  rand bit cache_warmup_mode, SP_warmup_mode;
  bit avoid_scratchpad;
 //Write constraints to pick from super patterns
  constraint pattern_c{
    if(!cache_warmup_mode && !SP_warmup_mode) {
      pattern_mode == !args.only_traffic_mode;
      if(args.k_cmdline_super_pattern_mode) { 
        //Apply specific level-2 cmdline control by exercising specific level-1 traffic patterns
        m_super_pattern == args.k_super_pattern_type;
      }
      else {
        m_super_pattern == SUPER_NULL_s_p;
        //Apply cmdline control of a specific level-1 traffic pattern or randomize between all
        if(!args.k_cmdline_pattern_mode && pattern_mode) {//Default pattern distribution
          m_pattern dist { 
            <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
            DMI_CMP_ATM_MATCH_p := 20,
            <%}%>
            DMI_RAW_p       := 10,
            DMI_CMO_on_WR_p := 10,
            DMI_LATE_MRD_p  := 10,
            DMI_RAND_p      := 80
          };
          <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
          if(args.atomics_disabled) {
            m_pattern != DMI_CMP_ATM_MATCH_p;
          }
          <%}%>
        }
        else{ m_pattern == args.k_pattern_type; } //Cmdline control
      }
    }
  }
  constraint super_pattern_c {
    if(pattern_mode && args.k_cmdline_super_pattern_mode) {
      (m_super_pattern == ATM_WITH_HITS_s_p) -> m_pattern dist {
                                                                DMI_CMP_ATM_MATCH_p := 30,
                                                                DMI_ATM_p := 70
                                                               };
      (m_super_pattern == DEADLOCK_ATM_MRG_s_p) -> m_pattern dist {
                                                                DMI_CMP_ATM_MATCH_p := 20,
                                                                DMI_ATM_MRG_p := 80
                                                                };
    }
  }
  constraint opcode_wt_c{
    //TODO add a layer mode where you don't specify weights from common knobs class but specify balance through this layer
    if(pattern_mode) {
      if(args.atomics_disabled){
        !(m_opcode inside {atomic_types});
      }
      (m_pattern == DMI_CMP_ATM_MATCH_p)  -> (m_opcode ==CMD_WR_ATM);
      (m_pattern == DMI_LATE_MRD_p)       -> m_opcode inside {MRD_FLUSH,MRD_CLN,MRD_INV};
      (m_pattern == DMI_RAW_p)  -> m_opcode dist{
                                                  CMD_RD_NC           := args.wt_cmd_rd_nc.get_value(),
                                                  CMD_WR_NC_PTL       := args.wt_cmd_wr_nc_ptl.get_value(),
                                                  CMD_WR_NC_FULL      := args.wt_cmd_wr_nc_full.get_value()
                                                };
      (m_pattern == DMI_WAW_p)  -> m_opcode dist{
                                                  CMD_WR_NC_PTL       := args.wt_cmd_wr_nc_ptl.get_value(),
                                                  CMD_WR_NC_FULL      := args.wt_cmd_wr_nc_full.get_value()
                                                };
      (m_pattern == DMI_EXCLUSIVE_p)  -> m_opcode dist{
                                                  CMD_RD_NC           := args.wt_cmd_rd_nc.get_value(),
                                                  CMD_WR_NC_PTL       := args.wt_cmd_wr_nc_ptl.get_value(),
                                                  CMD_WR_NC_FULL      := args.wt_cmd_wr_nc_full.get_value()
                                                };      
      (m_pattern == DMI_CMO_on_WR_p)  -> m_opcode dist{       
                                                  CMD_WR_NC_PTL       := args.wt_cmd_wr_nc_ptl.get_value(),
                                                  CMD_WR_NC_FULL      := args.wt_cmd_wr_nc_full.get_value(),
                                                  DTW_DATA_CLN        := args.wt_dtw_dt_cln.get_value(),
                                                  DTW_DATA_PTL        := args.wt_dtw_dt_ptl.get_value(),
                                                  DTW_DATA_DTY        := args.wt_dtw_dt_dty.get_value(),
                                                  DTW_MRG_MRD_UCLN    := args.wt_dtw_mrg_mrd_ucln.get_value(),
                                                  DTW_MRG_MRD_UDTY    := args.wt_dtw_mrg_mrd_udty.get_value(),
                                                  DTW_MRG_MRD_INV     := args.wt_dtw_mrg_mrd_inv.get_value(),
                                                  MRD_FLUSH           := args.wt_mrd_flush.get_value(),
                                                  MRD_CLN             := args.wt_mrd_cln.get_value(),
                                                  MRD_INV             := args.wt_mrd_inv.get_value(),
                                                  MRD_PREF            := args.wt_mrd_pref.get_value(),
                                                  CMD_CLN_INV         := args.wt_cmd_cln_inv.get_value(),
                                                  CMD_CLN_VLD         := args.wt_cmd_cln_vld.get_value(),
                                                  CMD_CLN_SH_PER      := args.wt_cmd_cln_ShPsist.get_value(),
                                                  CMD_MK_INV          := args.wt_cmd_mk_inv.get_value(),
                                                  CMD_PREF            := args.wt_cmd_pref.get_value()
                                                };
      (m_pattern == DMI_ATM_MRG_p) -> m_opcode dist {
                                                 <% if(obj.DmiInfo[obj.Id].useAtomic) { %>    
                                                  CMD_RD_ATM          := args.wt_cmd_rd_atm.get_value(),
                                                  CMD_WR_ATM          := args.wt_cmd_wr_atm.get_value(),
                                                  CMD_SW_ATM          := args.wt_cmd_swap_atm.get_value(),
                                                  CMD_CMP_ATM         := args.wt_cmd_cmp_atm.get_value(),
                                                  <%}%>
                                                  DTW_MRG_MRD_UCLN    := args.wt_dtw_mrg_mrd_ucln.get_value(),
                                                  DTW_MRG_MRD_UDTY    := args.wt_dtw_mrg_mrd_udty.get_value(),
                                                  DTW_MRG_MRD_INV     := args.wt_dtw_mrg_mrd_inv.get_value()
                                                };
      <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
      (m_pattern == DMI_ATM_p) -> m_opcode dist {
                                                  CMD_RD_ATM          := args.wt_cmd_rd_atm.get_value(),
                                                  CMD_WR_ATM          := args.wt_cmd_wr_atm.get_value(),
                                                  CMD_SW_ATM          := args.wt_cmd_swap_atm.get_value(),
                                                  CMD_CMP_ATM         := args.wt_cmd_cmp_atm.get_value()
                                                };                                                
      <%}%>
      (m_pattern == DMI_RAND_p) -> m_opcode dist{
                                                  <% if(obj.DmiInfo[obj.Id].useAtomic) { %>    
                                                  CMD_RD_ATM          := args.wt_cmd_rd_atm.get_value(),
                                                  CMD_WR_ATM          := args.wt_cmd_wr_atm.get_value(),
                                                  CMD_SW_ATM          := args.wt_cmd_swap_atm.get_value(),
                                                  CMD_CMP_ATM         := args.wt_cmd_cmp_atm.get_value(),
                                                  <%}%>
                                                  CMD_RD_NC           := args.wt_cmd_rd_nc.get_value(),
                                                  CMD_WR_NC_PTL       := args.wt_cmd_wr_nc_ptl.get_value(),
                                                  CMD_WR_NC_FULL      := args.wt_cmd_wr_nc_full.get_value(),
                                                  MRD_RD_WITH_SHR_CLN := args.wt_mrd_rd_with_shr_cln.get_value(),
                                                  MRD_RD_WITH_UNQ_CLN := args.wt_mrd_rd_with_unq_cln.get_value(),
                                                  MRD_RD_WITH_UNQ     := args.wt_mrd_rd_with_unq.get_value(),
                                                  MRD_RD_WITH_INV     := args.wt_mrd_rd_with_inv.get_value(),
                                                  MRD_FLUSH           := args.wt_mrd_flush.get_value(),
                                                  MRD_CLN             := args.wt_mrd_cln.get_value(),
                                                  MRD_INV             := args.wt_mrd_inv.get_value(),
                                                  MRD_PREF            := args.wt_mrd_pref.get_value(),
                                                  CMD_CLN_INV         := args.wt_cmd_cln_inv.get_value(),
                                                  CMD_CLN_VLD         := args.wt_cmd_cln_vld.get_value(),
                                                  CMD_CLN_SH_PER      := args.wt_cmd_cln_ShPsist.get_value(),
                                                  CMD_MK_INV          := args.wt_cmd_mk_inv.get_value(),
                                                  CMD_PREF            := args.wt_cmd_pref.get_value(),
                                                  DTW_NO_DATA         := args.wt_dtw_no_dt.get_value(),
                                                  DTW_DATA_CLN        := args.wt_dtw_dt_cln.get_value(),
                                                  DTW_DATA_PTL        := args.wt_dtw_dt_ptl.get_value(),
                                                  DTW_DATA_DTY        := args.wt_dtw_dt_dty.get_value(),
                                                  DTW_MRG_MRD_UCLN    := args.wt_dtw_mrg_mrd_ucln.get_value(),
                                                  DTW_MRG_MRD_UDTY    := args.wt_dtw_mrg_mrd_udty.get_value(),
                                                  DTW_MRG_MRD_INV     := args.wt_dtw_mrg_mrd_inv.get_value()
                                                };
      
    }
  }
  constraint cache_warmup_c {
    soft cache_warmup_mode == 0;
    (cache_warmup_mode) && (m_pattern == DMI_CACHE_WARMUP_p) -> m_opcode inside {MRD_PREF};
  }
  constraint scratchpad_warmup_c{
    soft SP_warmup_mode == 0;
    (SP_warmup_mode) && (m_pattern == DMI_SP_WARMUP_p) -> m_opcode inside {write_with_data_types};
  }
  constraint only_traffic_mode_c{
    if(args.only_traffic_mode){
      <% if(obj.DmiInfo[obj.Id].useAtomic) { %>    
      args.k_atomic_traffic_only -> m_opcode inside {atomic_types};
      <%}%>
      args.k_mrd_traffic_only -> m_opcode inside {mrd_types};
      args.k_cmo_traffic_only -> m_opcode inside {cmo_types};
      args.k_read_traffic_only  -> m_opcode inside {read_types};
      args.k_read_traffic_only_no_cmo -> (m_opcode inside {read_types} && !(m_opcode inside {cmo_types}));
      args.k_write_traffic_only -> m_opcode inside {write_types};
      args.k_write_with_data_traffic_only -> m_opcode inside {write_with_data_types};
      args.k_read_write_traffic_only -> m_opcode inside {read_types,write_types};
      args.k_read_write_data_traffic_only -> m_opcode inside {read_types,write_with_data_types};
      args.k_mrd_dtwmrgmrd_traffic_only -> m_opcode inside {mrd_types,dtwmrgmrd_types};
      args.k_dtwmrgmrd_traffic_only -> m_opcode inside {dtwmrgmrd_types};
      args.k_coh_write_traffic_only -> m_opcode inside {coh_write_types};
      args.k_noncoh_read_traffic_only -> m_opcode inside {noncoh_read_types};
      args.k_noncoh_write_traffic_only -> m_opcode inside {noncoh_write_types};    
      args.k_cmd_mrd_traffic_only -> m_opcode inside {read_types,cmo_types,noncoh_write_types<%if(obj.DmiInfo[obj.Id].useAtomic){%>,atomic_types<%}%>};
    }
  }
  constraint ignore_mode_c{
    args.k_no_CMO_traffic -> !(m_opcode inside {cmo_types});
  }
  constraint addr_c{
    if( (args.wt_noncoh_addr.get_value() == 0) || (args.wt_coh_addr.get_value() == 0)) {
      m_addr_type inside {NONCOH,COH};
    }
    else{ 
      m_addr_type dist{
        NONCOH := args.wt_noncoh_addr.get_value(),
        COH    := args.wt_coh_addr.get_value()
      };
    }
  }
  constraint defaults_c{
   if(args.wt_dtw_intervention.get_value() == 100 || args.wt_dtw_intervention.get_value() == 0) {
     (args.wt_dtw_intervention.get_value() == 100) -> merging_write == 1;
     (args.wt_dtw_intervention.get_value() == 0)   -> merging_write == 0;
   }
   else {
    merging_write dist {
      1 := args.wt_dtw_intervention.get_value(),
      0 := args.wt_dtw_intervention.get_value()
    };
   }
    solve m_opcode before internal_release;
  };
  constraint internal_release_c{
    if(m_opcode inside {DTW_NO_DATA,DTW_DATA_PTL,DTW_DATA_DTY,DTW_DATA_CLN}) {
      if(args.wt_rb_release.get_value() == 0 || args.wt_rb_release.get_value() == 100){
        (args.wt_rb_release.get_value() == 0) -> internal_release == 0;
        (args.wt_rb_release.get_value() == 100) -> internal_release == 1;
      }
      else{
        internal_release dist{
          1 := args.wt_rb_release.get_value(),
          0 := 100-args.wt_rb_release.get_value()
        };
      }
    }
    else { internal_release == 0;}
  }
 //Enforce b2b type legacy mode to select from list

  function void post_randomize();

    if(args.k_force_atomic_traffic) begin
      m_opcode = atomic_types[$urandom_range(0,atomic_types.size()-1)];
      `uvm_guarded_info(args.k_stimulus_debug,"traffic_seq",$sformatf("Forcing atomic traffic 'h%0h",m_opcode),UVM_MEDIUM)
    end

    msg_s = m_cfg.smi_type_string(m_opcode);

    addr_type_constraints();

    if(  m_opcode inside {DTW_DATA_PTL,DTW_MRG_MRD_UDTY} 
      && !args.k_all_internal_release 
      && !internal_release 
      && (args.k_force_mw!=-1)) begin
      merging_write = args.k_force_mw;
    end
    else begin 
      merging_write = 0;
    end

    merging_write_success_flag = c_get_merging_write_status(merging_write);
    traffic_info.payload_size = m_cfg.get_payload_size(m_opcode,predict_primary_bit());
    traffic_info.smi_type = m_opcode;
    traffic_info.addr_type = m_addr_type;
    traffic_info.pattern_type = m_pattern;

    if(pattern_mode) begin
      if(args.k_cmdline_super_pattern_mode) begin
        `uvm_guarded_info(args.k_stimulus_debug,"traffic_seq",$sformatf("Super Pattern Mode [%0s]| m_pattern:%0s m_opcode:%0s(%0h) type:%0s traffic_info:%0p", m_super_pattern.name ,m_pattern.name, msg_s, m_opcode, m_addr_type.name, traffic_info),UVM_LOW)
      end
      else begin
        `uvm_guarded_info(args.k_stimulus_debug,"traffic_seq",$sformatf("Pattern Mode | m_pattern:%0s m_opcode:%0s(%0h) type:%0s traffic_info:%0p", m_pattern.name, msg_s, m_opcode, m_addr_type.name, traffic_info),UVM_LOW)
      end
    end

    if(args.only_traffic_mode) begin
      `uvm_guarded_info(args.k_stimulus_debug,"traffic_seq",$sformatf("Only Mode | m_opcode:%0s(%0h) type:%0s traffic_info:%0p", msg_s, m_opcode, m_addr_type.name, traffic_info),UVM_LOW)
    end

    if(cache_warmup_mode || SP_warmup_mode) begin
      `uvm_guarded_info(args.k_stimulus_debug,"traffic_seq",$sformatf("Warmup Mode | m_opcode:%0s(%0h) type:%0s traffic_info:%0p", msg_s, m_opcode, m_addr_type.name, traffic_info),UVM_LOW)
    end

    if(args.k_all_internal_release && (m_opcode inside {DTW_NO_DATA,DTW_DATA_PTL,DTW_DATA_DTY,DTW_DATA_CLN})) begin
      internal_release = 1;
    end
    //VIK FIXME-- major. Revisit if you enabled this constraint to avoid QoS issues or if this is actually needed
    if($countones(m_cfg.m_rsrc_mgr.gid_rb_status) >= COH_RBID_SIZE-1) begin
      //Constraint to ensure there is at least 1 RB available to dispatch a release in case of all internal release RBReqs in the RB skid buffer.
      internal_release = 0;
      `uvm_guarded_info(args.k_stimulus_debug,"traffic_seq",$sformatf("Overriding internal release randomization to ensure skid buffer is not filled with internal release RBs(Used:%0d Max:%0d)",
                                                            $countones(m_cfg.m_rsrc_mgr.gid_rb_status), COH_RBID_SIZE),UVM_HIGH) 
    end
  endfunction

  function bit predict_primary_bit();
    bit m_prim;
    if(
      (m_opcode inside {coh_write_types}) ||
      ((m_opcode inside {dtwmrgmrd_types}) && (merging_write==1) )
      ) begin
      m_prim = 1;
    end
    `uvm_guarded_info(args.k_stimulus_debug,"traffic_seq",$sformatf("::predict_primary_bit:: Predict primary:%0b",m_prim),UVM_DEBUG)
    return(m_prim);
  endfunction

  function void addr_type_constraints();
    if(args.k_shared_c_nc_addressing) begin
      return;
    end
    if(m_cfg.isNcCmd(m_opcode) || (m_cfg.isAtomics(m_opcode) && args.k_all_noncoh_atomics_traffic_only)) begin
      m_addr_type = NONCOH;
    end
    if( (m_pattern == DMI_CMP_ATM_MATCH_p) || 
        (m_opcode inside {atomic_types} & !args.k_all_noncoh_atomics_traffic_only ) ||
        (m_opcode inside {mrd_types,cmo_types,dtwmrgmrd_types,coh_write_types})
        ) begin 
      m_addr_type = COH;
    end
  endfunction

  function new(string name="traffic_seq");
    super.new(name);
    m_pattern = DMI_RAND_p;
    initialize();
    set_default_queues();
  endfunction

  //Constraints --Begin
  function bit c_get_merging_write_status(bit is_mw);
    //Constraint-- MW flag can be set in the primary with no second DTW to follow.
    int rand_dist = $urandom_range(0,100);
    if(is_mw && (rand_dist < m_cfg.wt_merging_write_success)) begin
      return(1);
    end
    else begin
      return(0);
    end
  endfunction 
  //Constraints --End

  function void initialize();
    if(!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                       .inst_name( "uvm_test_top.*" ),
                                       .field_name( "dmi_env_config" ),
                                       .value( m_cfg ))) begin
    `uvm_error("traffic_seq",":init:: dmi_env_config handle not found")
    end
    get_args(m_cfg.m_args);
  endfunction

  function void set_default_queues();
    atomic_types = {CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM,CMD_CMP_ATM};
    mrd_types = {MRD_RD_WITH_SHR_CLN,MRD_RD_WITH_UNQ_CLN,MRD_RD_WITH_UNQ,MRD_RD_WITH_INV,MRD_FLUSH,MRD_CLN,MRD_INV,MRD_PREF};
    cmo_types = {MRD_FLUSH,MRD_CLN,MRD_INV,MRD_PREF,CMD_CLN_INV,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF};
    dtwmrgmrd_types = {DTW_MRG_MRD_UCLN,DTW_MRG_MRD_UDTY,DTW_MRG_MRD_INV};
    coh_write_types = {DTW_NO_DATA,DTW_DATA_CLN,DTW_DATA_PTL,DTW_DATA_DTY};
    noncoh_read_types = {CMD_RD_NC};
    noncoh_write_types = {CMD_WR_NC_PTL,CMD_WR_NC_FULL};
    read_types = {mrd_types,noncoh_read_types};
    write_types = {DTW_DATA_CLN,DTW_DATA_PTL,DTW_DATA_DTY,noncoh_write_types};
    write_with_data_types = {DTW_DATA_PTL,DTW_DATA_DTY,noncoh_write_types};
    load_exclusive_types = {noncoh_read_types};
    store_exclusive_types = {noncoh_write_types};
  endfunction
endclass

