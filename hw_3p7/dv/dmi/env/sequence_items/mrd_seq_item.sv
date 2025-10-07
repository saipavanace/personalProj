class mrd_seq_item extends data_seq_item;

  
  `uvm_object_utils_begin(mrd_seq_item)
  `uvm_object_utils_end

  //Constraints
  constraint defaults_c{
    !args.k_wrong_targ_id_mrd -> ( smi_targ_ncore_unit_id == cfg.m_rsrc_mgr.home_dmi_unit_id );
    args.k_wrong_targ_id_mrd  -> ( smi_targ_ncore_unit_id == (cfg.m_rsrc_mgr.home_dmi_unit_id^{WSMINCOREUNITID{1'b1}}) );
  }
  constraint common_c{
    smi_ch == 1;
    smi_ac == smi_ac & smi_ca; //All allocations should be cacheable
    if(smi_msg_type inside {MRD_FLUSH,MRD_CLN,MRD_INV}){
      smi_rl == 'b10;
    }
    else if (smi_msg_type inside {MRD_RD_CLN,MRD_RD_WITH_SHR_CLN,MRD_RD_WITH_UNQ_CLN}) {
      smi_rl inside {'b01,'b11};
    }
    else { smi_rl == 'b01; }
    if(args.k_starvation_test) {
       (aiu_gen_id.aiu_id == 0) -> smi_qos == 'hF;
      !(aiu_gen_id.aiu_id == 0) -> smi_qos == 0;
    }
    else if(cfg.dmi_qos_th_val[qos_pgm_idx] != 0){
      smi_qos dist{
        [(cfg.dmi_qos_th_val[qos_pgm_idx]/2):15]  := args.wt_dmi_qos_hp_pkt.get_value()-1,
        [0:(cfg.dmi_qos_th_val[qos_pgm_idx]/2-1)] := (100-(args.wt_dmi_qos_hp_pkt.get_value()-1))
      };
    }
  }
  function new(string name = "mrd_seq_item");
    super.new(name);
  endfunction

  function void arg_overrides();
    if(args.k_force_allocate || smi_msg_type == MRD_PREF) begin
      smi_ac = 1;
      smi_ca = 1;
    end
    if(args.k_force_ns != -1)begin
      smi_ns = args.k_force_ns;
    end
    if(args.k_force_late_rsp) begin
      smi_rl = 2'b10;
    end
  endfunction

  function void assign_identifiers();
    aiu_gen_id = cfg.m_rsrc_mgr.get_aiu_msg_id("MRD_SEQ_ITEM");
    dce_gen_id = cfg.m_rsrc_mgr.get_dce_msg_id("MRD_SEQ_ITEM");
    smi_msg_id = dce_gen_id.msg_id;
    smi_src_ncore_unit_id = dce_gen_id.dce_id;
    smi_mpf1_dtr_tgt_id = aiu_gen_id.aiu_id;
    smi_mpf2_dtr_msg_id = aiu_gen_id.msg_id;
  endfunction

  function void post_randomize();
    smi_msg_pri = addrMgrConst::qos_mapping(smi_qos);
    assign_identifiers();
    set_intfsize();
    set_payload_size();
    set_data_guidance();
    align_size = get_align_size();
    assign_address();
    align_address();
  endfunction

endclass