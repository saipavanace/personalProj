class rb_seq_item extends dmi_seq_item;
  
  `uvm_object_utils_begin(rb_seq_item)
  `uvm_object_utils_end

  constraint basic_rb_req_c{
    smi_msg_type == RB_REQ;
    !args.k_wrong_targ_id_rb_req -> smi_targ_ncore_unit_id == cfg.m_rsrc_mgr.home_dmi_unit_id;
    args.k_wrong_targ_id_rb_req  -> smi_targ_ncore_unit_id == (cfg.m_rsrc_mgr.home_dmi_unit_id ^ {WSMINCOREUNITID{1'b1}});
    smi_rl == 2;
    args.k_dmiTmBit4Smi2 !=0 -> smi_tm dist { 1:= args.k_dmiTmBit4Smi2,
                                              0:= (100-args.k_dmiTmBit4Smi2)
                                            };
  }

  constraint allocation_c{
    if(args.k_force_allocate){
      smi_ac == 1;
      smi_ca == 1;
    }
    else {
      smi_ca == smi_ac;
    }
  }

  constraint visibility_c{
    args.k_force_sys_vz -> smi_vz == 1;
    args.k_force_coh_vz -> smi_vz == 0;
  }

  function new(string name="rb_seq_item");
    super.new(name);
  endfunction

  function void pre_randomize();
  endfunction

  function void post_randomize();
  endfunction

  function construct_relevant_rb(ref dtw_seq_item m_item);
    pkt_id   = m_item.pkt_id;
    smi_rbid = m_item.smi_rbid;
    smi_size = m_item.smi_size;
    smi_addr = m_item.smi_addr;
    smi_intfsize = m_item.smi_intfsize;
    if(!args.k_force_sys_vz && !args.k_force_coh_vz) begin
      smi_vz = m_item.smi_vz;
    end
    smi_ns = m_item.smi_ns;
    smi_pr = m_item.smi_pr;
    smi_tm = m_item.smi_tm;
    smi_qos = m_item.smi_qos;
    smi_msg_pri = ncoreConfigInfo::qos_mapping(m_item.smi_qos);
    smi_mw = m_item.smi_mw;
    //FIXME FIXME FIXME
    //setSmiPriv(rbreq_out);
    dce_gen_id = cfg.m_rsrc_mgr.get_dce_msg_id("RB_SEQ_ITEM",1,1,smi_rbid);
    
    smi_msg_id = dce_gen_id.msg_id;
    smi_src_ncore_unit_id = dce_gen_id.dce_id;
  endfunction
endclass
