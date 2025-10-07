//Covers all CmdReq type sequence item constraints including atomics
class cmd_seq_item extends data_seq_item;

  rand axi_awid_t AXI_AWID;
  rand axi_arid_t AXI_ARID;

  `uvm_object_utils_begin(cmd_seq_item)
  `uvm_object_utils_end
  
  //Constraints
  constraint defaults_c{
    !args.k_wrong_targ_id_cmd -> ( smi_targ_ncore_unit_id == cfg.m_rsrc_mgr.home_dmi_unit_id );
    args.k_wrong_targ_id_cmd  -> ( smi_targ_ncore_unit_id == (cfg.m_rsrc_mgr.home_dmi_unit_id^{WSMINCOREUNITID{1'b1}}) );
  }


  constraint attribute_c{
    if (smi_msg_type inside {atomic_types}){
      smi_vz == 0;
      smi_st == 0;
    }
    //Response-level
    if(smi_msg_type inside {cmd_cmo_types}){
      smi_rl == 'b10; //Protocol-level completion at the immediate destination of the message
    }
    else if(smi_msg_type inside {noncoh_read_types,noncoh_write_types}){
      smi_rl == 'b01; //Transport flow control response
    }
    else { 
      smi_rl == 'b00; //No response expected
    }
    /* FIXME FIXME -priority-3
          if(!(req_item.isRbMsg() || req_item.isMrdMsg() || isDtw(req_item.smi_msg_type) || isDtwMrgMrd(req_item.smi_msg_type) || (req_item.smi_msg_type inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_RD_NC,CMD_WR_NC_PTL,CMD_WR_NC_FULL})))begin
        req_item.smi_rl       = 0;
      end*/
    args.k_dmiTmBit4Smi0 !=0 -> smi_tm dist { 1:= args.k_dmiTmBit4Smi0,
                                              0:= (100-args.k_dmiTmBit4Smi0)
                                            };
    smi_mpf1_argv inside {[0:7]};
    if(cfg.dmi_qos_th_val[qos_pgm_idx] != 0){
      smi_qos dist{
        [(cfg.dmi_qos_th_val[qos_pgm_idx]/2):15]  := args.wt_dmi_qos_hp_pkt.get_value()-1,
        [0:(cfg.dmi_qos_th_val[qos_pgm_idx]/2-1)] := (100-(args.wt_dmi_qos_hp_pkt.get_value()-1))
      };
    }
    solve smi_qos before smi_msg_pri;
    smi_msg_pri == ncoreConfigInfo::qos_mapping(smi_qos);
    args.k_pmon_bw_user_bits -> smi_ndp_aux inside {[5:15]};
    smi_msg_type inside {atomic_types} -> smi_ac == 1;
    soft (m_addr_type == NONCOH) -> smi_ac == 0;
  }
  
  constraint exclusive_c{

    if(smi_msg_type inside {CMD_WR_NC_PTL,CMD_WR_NC_FULL,CMD_RD_NC}){
      if( (args.k_shared_c_nc_addressing && (cfg.exclusive_monitor_size == 0) ) || (m_addr_type == COH) ) {
        //ES bit is 0 when exclusive monitor is disabled and NonCoh addresses are used for Coh Commands.
        //This wil cause data allocation in cache, if ES = 1 and it hits in cache then the behavior is undefined in SPEC.
        smi_es == 0;
      }
      else{
        //Exclusives can only be sent to Non-Coh Rd/Wr and Atomics interpret EX bit as SS(Self Snoop)
        if(args.wt_exclusives.get_value() == 100 || args.wt_exclusives.get_value() == 0) {
          (args.wt_exclusives.get_value() == 100) -> smi_es == 1;
          (args.wt_exclusives.get_value() == 0)   -> smi_es == 0;
        }
        else {
          smi_es dist{
            1 := args.wt_exclusives.get_value(),
            0 := (100-args.wt_exclusives.get_value())
          };
        }
        if(smi_es){
          (cfg.exclusive_monitor_size == 0) -> smi_ac == 0; //Exclusives
          smi_vz == 1; //System visibility for exclusives
        }
      }
    }
    if(!(smi_msg_type inside {legal_exclusive_types})){
      //ES is treated as SS for atomics
      smi_es == 0;
    }
    //smi_mpf2 == AXI_AWID;
    if(smi_es){
      (smi_msg_type inside {noncoh_read_types})  -> smi_mpf2_flowid == AXI_ARID;
      (smi_msg_type inside {noncoh_write_types}) -> smi_mpf2_flowid == AXI_AWID;
      smi_mpf2_flowid_valid == 1;
    }
  }
  //Common constraints
  constraint common_c{
    smi_mpf1_burst_type == 2'b00;
    smi_ch == 0;
    smi_en == 0;
  }
  function new(string name = "cmd_seq_item");
    super.new(name);
  endfunction

  //Construct
  function void pre_randomize();
   
  endfunction

  function void post_randomize();
    assign_identifiers();
    set_payload_size();
    set_intfsize();
    set_data_guidance();
    align_size = get_align_size();
    assign_address();
    construct_data_for_preset_payload();
    if(!smi_es)begin
      smi_mpf2_flowid = 0;
      smi_mpf2_flowid_valid = 0;
    end
    arg_overrides();
  endfunction

  function assign_identifiers();
  aiu_gen_id  = cfg.m_rsrc_mgr.get_aiu_msg_id("CMD_SEQ_ITEM");
  smi_msg_id = aiu_gen_id.msg_id;
  smi_src_ncore_unit_id = aiu_gen_id.aiu_id;
  endfunction

  function void arg_overrides();
    if(args.k_force_coh_vz && !noncoh_non_CA_EX) begin
      smi_vz = 0;
    end
    if(args.k_force_sys_vz) begin
      smi_vz = 1;
    end
    if(args.k_force_no_allocate) begin
      smi_ac = 0;
      smi_ca = 0;
    end
    if((args.k_force_allocate || smi_msg_type == CMD_PREF) && !noncoh_non_CA_EX) begin
      smi_ac = 1;
      smi_ca = 1;
    end
    if(args.k_no_exclusives) begin
      smi_es = 0;
    end
    if(args.k_force_exclusive != -1) begin
      smi_es = args.k_force_exclusive;
    end
    if(args.k_atomic_opcode != 8) begin
      smi_mpf1_argv = args.k_atomic_opcode;
    end
    if(args.k_force_ns != -1)begin
      smi_ns = args.k_force_ns;
    end
  endfunction
endclass

