//==============================================================================================================================
// svt_axi_ace_master_base_virtual_sequence <-- io_subsys_snps_base_vseq <-- io_subsys_snps_vseq
//==============================================================================================================================
class io_subsys_snps_vseq extends io_subsys_snps_base_vseq;
  `uvm_object_utils(io_subsys_snps_vseq)

  function new(string name = "io_subsys_snps_vseq");
    super.new(name);
  endfunction
  
  /**  Raise an objection if this is the parent sequence */
  virtual task pre_body();
    super.pre_body();
    if  (starting_phase!=null) begin
      starting_phase.raise_objection(this);
    end
  endtask: pre_body

  /**  Drop an objection if this is the parent sequence */
  virtual task post_body();
    super.post_body();
    if  (starting_phase!=null) begin
      starting_phase.drop_objection(this);
    end
  endtask: post_body
  
  task body();
    int tmp_axi_idx = 0;
    int tmp_ace_idx = 0;
    int tmp_idx = 0;
    
    io_subsys_axi_seq axi_mstr_seq[];
    io_subsys_ace_seq ace_mstr_seq[];
    io_subsys_ace_mem_upd_seq mem_upd_seq[];

    `uvm_info(get_full_name(), "Enter body", UVM_LOW);
      
    axi_mstr_seq = new[`NUM_IOAIU_SVT_MASTERS - `NUM_ACE_SVT_MASTERS];
    ace_mstr_seq = new[`NUM_ACE_SVT_MASTERS];
    mem_upd_seq = new[`NUM_ACE_SVT_MASTERS];

    foreach(ncoreConfigInfo::io_subsys_nativeif_a[i]) begin: _all_ioaiu_loop_
      if ((ncoreConfigInfo::io_subsys_nativeif_a[i] == "AXI4") || (ncoreConfigInfo::io_subsys_nativeif_a[i] == "AXI5")) begin: _axi_
        fork
          automatic int j = i;
          automatic int axi_idx = tmp_axi_idx;
          if(t_ioaiu_en[j]==1) begin
            `uvm_info(get_full_name(), $psprintf("Starting io_subsys t_ioaiu_en:%0d index :%0d", t_ioaiu_en[j],j), UVM_LOW);
            `uvm_info(get_full_name(), $psprintf("Starting io_subsys_axi_seq(default) on inst:%0s nativeif:%0s on mstr_agnt_seqr:%0s", ncoreConfigInfo::io_subsys_instname_a[j], ncoreConfigInfo::io_subsys_nativeif_a[j], mstr_agnt_seqr_str[j]), UVM_LOW);
            axi_mstr_seq[axi_idx] = io_subsys_axi_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", ncoreConfigInfo::io_subsys_nativeif_a[j].tolower(), ncoreConfigInfo::io_subsys_instname_a[j], j));
            axi_mstr_seq[axi_idx].nativeif = ncoreConfigInfo::io_subsys_nativeif_a[j].tolower();
            axi_mstr_seq[axi_idx].instname = ncoreConfigInfo::io_subsys_instname_a[j];
            axi_mstr_seq[axi_idx].portid   = j;
            axi_mstr_seq[axi_idx].start(mstr_agnt_seqr_a[j]);
          end
        join_none
        tmp_axi_idx++;
      end: _axi_ 
      else begin: _ace_ 
        fork
          automatic int j = i;
          automatic int ace_idx = tmp_ace_idx;
          begin
            if(t_ioaiu_en[j]==1) begin
            `uvm_info(get_full_name(), $psprintf("Starting io_subsys t_ioaiu_en:%0d index :%0d", t_ioaiu_en[j],j), UVM_LOW);
            `uvm_info(get_full_name(), $psprintf("Starting io_subsys_ace_master_seq(default) on inst:%0s nativeif:%0s on mstr_agnt_seqr_str:%0s", ncoreConfigInfo::io_subsys_instname_a[j], ncoreConfigInfo::io_subsys_nativeif_a[j], mstr_agnt_seqr_str[j]), UVM_LOW);
            ace_mstr_seq[ace_idx] = io_subsys_ace_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", ncoreConfigInfo::io_subsys_nativeif_a[j].tolower(), ncoreConfigInfo::io_subsys_instname_a[j], j));
            ace_mstr_seq[ace_idx].nativeif = ncoreConfigInfo::io_subsys_nativeif_a[j].tolower();
            ace_mstr_seq[ace_idx].instname = ncoreConfigInfo::io_subsys_instname_a[j];
            ace_mstr_seq[ace_idx].dvm_enable = ncoreConfigInfo::io_subsys_dvm_enable_a[j];
            ace_mstr_seq[ace_idx].portid   = j;
            ace_mstr_seq[ace_idx].start(mstr_agnt_seqr_a[j]);
            end
          end
        join_none
        tmp_ace_idx++;
      end: _ace_
    end: _all_ioaiu_loop_
    wait fork;
    //add some prints for 
    foreach(ncoreConfigInfo::io_subsys_nativeif_a[i]) begin: _all_ioaiu_if
      if (ncoreConfigInfo::io_subsys_nativeif_a[i] == "ACE") begin: _ace_
        fork
          automatic int j = i;
          automatic int ace_idx = tmp_idx;
          if (p_sequencer.master_sequencer[j] != null)
             my_component = p_sequencer.master_sequencer[j].get_parent();      
          $cast(my_agent,my_component);
          if (my_agent != null) begin
            //`uvm_info(get_full_name(), $psprintf("getting my_agent to get cache "), UVM_LOW);
             my_cache = my_agent.get_cache();
          end
          my_cache.print();

          begin
            if(t_ioaiu_en[j]==1) begin
            `uvm_info(get_full_name(), $psprintf("Starting io_subsys t_ioaiu_en:%0d index :%0d", t_ioaiu_en[j],j), UVM_LOW);
            `uvm_info(get_full_name(), $psprintf("Starting io_subsys_ace_mem_update_seq(default) on inst:%0s nativeif:%0s on mstr_agnt_seqr_str:%0s", ncoreConfigInfo::io_subsys_instname_a[j], ncoreConfigInfo::io_subsys_nativeif_a[j], mstr_agnt_seqr_str[j]), UVM_LOW);
            mem_upd_seq[ace_idx] = io_subsys_ace_mem_upd_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", ncoreConfigInfo::io_subsys_nativeif_a[j].tolower(), ncoreConfigInfo::io_subsys_instname_a[j], j));
            mem_upd_seq[ace_idx].nativeif = ncoreConfigInfo::io_subsys_nativeif_a[j].tolower();
            mem_upd_seq[ace_idx].instname = ncoreConfigInfo::io_subsys_instname_a[j];
            mem_upd_seq[ace_idx].portid   = j;
            mem_upd_seq[ace_idx].cache_size = my_cache.num_cache_lines;
            if(!$test$plusargs("en_all_axlen_for_noncoh_txns")) begin
               mem_upd_seq[ace_idx].start(mstr_agnt_seqr_a[j]);
            end
            end
          end
        join_none
        tmp_idx++;
      end: _ace_ 
    end: _all_ioaiu_if
    wait fork;

  endtask:body
endclass: io_subsys_snps_vseq
