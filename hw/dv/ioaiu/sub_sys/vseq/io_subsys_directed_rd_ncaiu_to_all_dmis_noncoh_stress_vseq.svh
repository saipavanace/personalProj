//==============================================================================================================================
// svt_axi_ace_master_base_virtual_sequence <-- io_subsys_snps_base_vseq <-- io_subsys_snps_vseq <-- io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_vseq
//==============================================================================================================================
class io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_vseq extends io_subsys_snps_vseq;
  `uvm_object_utils(io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_vseq)
  int ioaiu_inf[];

  function new(string name = "io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_vseq");
    super.new(name);
  endfunction
  
  /**  Raise an objection if this is the parent sequence */
  virtual task pre_body();
    super.pre_body();
    foreach(ncoreConfigInfo::inf[i]) begin: _all_aiu_loop_
       if(!((ncoreConfigInfo::inf[i]==2) || (ncoreConfigInfo::inf[i]==3) || (ncoreConfigInfo::inf[i]==7))) begin // exclude chi i/f
           ioaiu_inf = new[ioaiu_inf.size() + 1] (ioaiu_inf) ;
           ioaiu_inf[ioaiu_inf.size() - 1] = ncoreConfigInfo::inf[i];
       end
    end : _all_aiu_loop_
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
    
    io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_seq axi_mstr_seq[];

    `uvm_info(get_full_name(), "Enter body", UVM_LOW);
      
    axi_mstr_seq = new[`NUM_IOAIU_SVT_MASTERS - `NUM_ACE_SVT_MASTERS];

    foreach(ncoreConfigInfo::io_subsys_nativeif_a[i]) begin: _all_ioaiu_loop_
      if ((ncoreConfigInfo::io_subsys_nativeif_a[i] == "AXI4") && (ioaiu_inf[i] == 5)) begin: _axi_
          automatic int j = i;
          automatic int axi_idx = tmp_axi_idx;
          begin
            `uvm_info(get_full_name(), $psprintf("Starting io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_seq(default) on inst:%0s nativeif:%0s on mstr_agnt_seqr:%0s", ncoreConfigInfo::io_subsys_instname_a[j], ncoreConfigInfo::io_subsys_nativeif_a[j], mstr_agnt_seqr_str[j]), UVM_LOW);
            axi_mstr_seq[axi_idx] = io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", ncoreConfigInfo::io_subsys_nativeif_a[j].tolower(), ncoreConfigInfo::io_subsys_instname_a[j], j));
            axi_mstr_seq[axi_idx].nativeif = ncoreConfigInfo::io_subsys_nativeif_a[j].tolower();
            axi_mstr_seq[axi_idx].instname = ncoreConfigInfo::io_subsys_instname_a[j];
            axi_mstr_seq[axi_idx].portid   = j;
            axi_mstr_seq[axi_idx].ioaiu_num_trans = ioaiu_num_trans;
            axi_mstr_seq[axi_idx].set_response_queue_error_report_disabled(1);
            axi_mstr_seq[axi_idx].start(mstr_agnt_seqr_a[j]);
          end
        tmp_axi_idx++;
      end: _axi_ 
    end: _all_ioaiu_loop_

    `uvm_info(get_full_name(), "End body", UVM_LOW);
  endtask:body
endclass: io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_vseq
