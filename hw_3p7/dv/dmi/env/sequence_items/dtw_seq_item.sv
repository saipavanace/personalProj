class dtw_seq_item extends data_seq_item;
  
  `uvm_object_utils_begin(dtw_seq_item)
  `uvm_object_utils_end

  constraint defaults_c{
    smi_msg_id == aiu_gen_id.msg_id;
    smi_src_ncore_unit_id == aiu_gen_id.aiu_id;
    !args.k_wrong_targ_id_dtw_req -> ( smi_targ_ncore_unit_id == cfg.m_rsrc_mgr.home_dmi_unit_id );
    args.k_wrong_targ_id_dtw_req  -> ( smi_targ_ncore_unit_id == (cfg.m_rsrc_mgr.home_dmi_unit_id^{WSMINCOREUNITID{1'b1}}) );
    args.k_dmiTmBit4Smi3 !=0 -> smi_tm dist { 1:= args.k_dmiTmBit4Smi3,
                                              0:= (100-args.k_dmiTmBit4Smi3)
                                            };
  }

  constraint attribute_c{
    //Primary field should be specified in other cases
    soft (smi_mw == 0);
    if(smi_msg_type inside {coh_write_types}) {
      soft smi_prim == 1;
    }
    if( (smi_msg_type inside {dtwmrgmrd_types}) && (smi_mw==1) ){
      smi_prim == 1;
    }
    if(smi_msg_type inside {dtwmrgmrd_types}){
      (smi_prim == 1) -> smi_rl  inside {'b01,'b11};
      (smi_prim == 0) -> (smi_rl == 'b01);
    }
    else {
      smi_rl == 'b10;
    }
    if(cfg.dmi_qos_th_val[qos_pgm_idx] != 0){
      smi_qos dist{
        [(cfg.dmi_qos_th_val[qos_pgm_idx]/2):15]  := args.wt_dmi_qos_hp_pkt.get_value()-1,
        [0:(cfg.dmi_qos_th_val[qos_pgm_idx]/2-1)] := (100-(args.wt_dmi_qos_hp_pkt.get_value()-1))
      };
    }
  }
  function new(string name = "dtw_seq_item");
    super.new(name);
  endfunction

  function void post_randomize();
    assign_identifiers();
    set_payload_size();
    set_intfsize();
    set_data_guidance();
    align_size = get_align_size();
    assign_address();
    arg_overrides();
    if(smi_msg_type inside {dtwmrgmrd_types}) begin
      aiu_gen_id_mpf = cfg.m_rsrc_mgr.get_aiu_msg_id("DTW_SEQ_ITEM=MPF");
      smi_mpf1 = aiu_gen_id_mpf.aiu_id;
      smi_mpf2 = aiu_gen_id_mpf.msg_id;
    end
    smi_msg_pri = addrMgrConst::qos_mapping(smi_qos);
    construct_data_for_preset_payload();
  endfunction

  function assign_identifiers();
    //If SMI_MW Something to do with waiting for event if no IDs are available, shouldn't impact new implementation
    aiu_gen_id  = cfg.m_rsrc_mgr.get_aiu_msg_id("DTW_SEQ_ITEM");
    smi_msg_id = aiu_gen_id.msg_id;
    smi_src_ncore_unit_id = aiu_gen_id.aiu_id;
  endfunction
  function void arg_overrides();
    if(args.k_force_ns != -1)begin
      smi_ns = args.k_force_ns;
    end
    if(args.k_force_no_allocate) begin
      smi_ac = 0;
      smi_ca = 0;
    end
    else if(args.k_force_allocate) begin
      smi_ac = 1;
      smi_ca = 1;
    end
  endfunction

endclass