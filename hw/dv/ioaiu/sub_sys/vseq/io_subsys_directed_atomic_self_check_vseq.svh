//==============================================================================================================================
// svt_axi_ace_master_base_virtual_sequence <-- io_subsys_snps_base_vseq <-- io_subsys_snps_vseq <-- io_subsys_directed_atomic_self_check_vseq
//==============================================================================================================================
class io_subsys_directed_atomic_self_check_vseq extends io_subsys_snps_vseq;
  `uvm_object_utils(io_subsys_directed_atomic_self_check_vseq)
  bit [31:0]ioaiu_seq_en ; //= 32'b1100_1000;

  function new(string name = "io_subsys_directed_atomic_self_check_vseq");
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
    
    io_subsys_axi_directed_atomic_self_check_seq axi_mstr_seq[];
    io_subsys_ace_directed_atomic_self_check_seq ace_mstr_seq[];

    `uvm_info(get_full_name(), "Enter body", UVM_LOW);
    if (!$value$plusargs("ioaiu_seq_en=%0d",ioaiu_seq_en)) begin
        ioaiu_seq_en = 32'hFFFF_FFFF; 
    end  
      
    axi_mstr_seq = new[`NUM_IOAIU_SVT_MASTERS - `NUM_ACE_SVT_MASTERS];
    ace_mstr_seq = new[`NUM_ACE_SVT_MASTERS];

  foreach(ncoreConfigInfo::io_subsys_nativeif_a[i]) begin: _all_ioaiu_loop_
    if(ioaiu_seq_en[i]==1) begin : _ioaiu_seq_en_1
      if ((ncoreConfigInfo::io_subsys_nativeif_a[i] == "AXI4") || (ncoreConfigInfo::io_subsys_nativeif_a[i] == "AXI5")) begin: _axi_
          automatic int j = i;
          automatic int axi_idx = tmp_axi_idx;
          begin
              if(ncoreConfigInfo::io_subsys_atomic_enable_a[j]==1) begin : _axi_atomic
               `uvm_info(get_full_name(), $psprintf("Starting io_subsys_axi_directed_atomic_self_check_seq(default) on inst:%0s nativeif:%0s on mstr_agnt_seqr:%0s", ncoreConfigInfo::io_subsys_instname_a[j], ncoreConfigInfo::io_subsys_nativeif_a[j], mstr_agnt_seqr_str[j]), UVM_LOW);
               axi_mstr_seq[axi_idx] = io_subsys_axi_directed_atomic_self_check_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", ncoreConfigInfo::io_subsys_nativeif_a[j].tolower(), ncoreConfigInfo::io_subsys_instname_a[j], j));
               axi_mstr_seq[axi_idx].nativeif = ncoreConfigInfo::io_subsys_nativeif_a[j].tolower();
               axi_mstr_seq[axi_idx].instname = ncoreConfigInfo::io_subsys_instname_a[j];
               axi_mstr_seq[axi_idx].portid   = j;
               axi_mstr_seq[axi_idx].start(mstr_agnt_seqr_a[j]);
               tmp_axi_idx++;
              end : _axi_atomic
          end
      end: _axi_ 
      else begin: _ace_ 
          automatic int j = i;
          automatic int ace_idx = tmp_ace_idx;
          begin
              if(ncoreConfigInfo::io_subsys_atomic_enable_a[j]==1) begin : _ace_lite_atomic
               `uvm_info(get_full_name(), $psprintf("Starting io_subsys_ace_directed_atomic_self_check_seq(default) on inst:%0s nativeif:%0s on mstr_agnt_seqr_str:%0s", ncoreConfigInfo::io_subsys_instname_a[j], ncoreConfigInfo::io_subsys_nativeif_a[j], mstr_agnt_seqr_str[j]), UVM_LOW);
               ace_mstr_seq[ace_idx] = io_subsys_ace_directed_atomic_self_check_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", ncoreConfigInfo::io_subsys_nativeif_a[j].tolower(), ncoreConfigInfo::io_subsys_instname_a[j], j));
               ace_mstr_seq[ace_idx].nativeif = ncoreConfigInfo::io_subsys_nativeif_a[j].tolower();
               ace_mstr_seq[ace_idx].instname = ncoreConfigInfo::io_subsys_instname_a[j];
               ace_mstr_seq[ace_idx].portid   = j;
               ace_mstr_seq[ace_idx].start(mstr_agnt_seqr_a[j]);
               tmp_ace_idx++;
              end : _ace_lite_atomic
          end
      end: _ace_
    end: _ioaiu_seq_en_1 
  end: _all_ioaiu_loop_

    `uvm_info(get_full_name(), "End body", UVM_LOW);
  endtask:body
endclass: io_subsys_directed_atomic_self_check_vseq
