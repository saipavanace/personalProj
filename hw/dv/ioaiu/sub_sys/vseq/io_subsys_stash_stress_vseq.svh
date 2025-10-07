class io_subsys_stash_stress_vseq extends io_subsys_snps_vseq;
    `uvm_object_utils(io_subsys_stash_stress_vseq)

  function new(string name = "io_subsys_stash_stress_vseq");
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
    int tmp_ace_lite_e_idx = 0;
    int tmp_idx = 0;

    io_subsys_axi_seq axi_mstr_seq[];
    io_subsys_ace_seq ace_mstr_seq[];
    io_subsys_ace_seq ace_lite_e_mstr_seq[];

    `uvm_info(get_full_name(), "Enter body", UVM_LOW);
      
    axi_mstr_seq = new[`NUM_IOAIU_SVT_MASTERS - `NUM_ACE_SVT_MASTERS];
    ace_mstr_seq = new[`NUM_ACE_SVT_MASTERS];
    ace_lite_e_mstr_seq = new[`NUM_ACE_SVT_MASTERS];
  fork
    foreach(ncoreConfigInfo::io_subsys_nativeif_a[i]) begin: _all_ioaiu_loop_
      if ((ncoreConfigInfo::io_subsys_nativeif_a[i] == "AXI4") || (ncoreConfigInfo::io_subsys_nativeif_a[i] == "AXI5") ) begin: _axi_

          automatic int j = i;
          automatic int axi_idx = tmp_axi_idx;
          begin
          if(t_ioaiu_en[j]==1) begin
            `uvm_info(get_full_name(), $psprintf("Starting io_subsys t_ioaiu_en:%0d index :%0d", t_ioaiu_en[j],j), UVM_LOW);
            `uvm_info(get_full_name(), $psprintf("Starting io_subsys_axi_seq(default) on inst:%0s nativeif:%0s on mstr_agnt_seqr:%0s", ncoreConfigInfo::io_subsys_instname_a[j], ncoreConfigInfo::io_subsys_nativeif_a[j], mstr_agnt_seqr_str[j]), UVM_LOW);
            
            axi_mstr_seq[axi_idx] = io_subsys_axi_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", ncoreConfigInfo::io_subsys_nativeif_a[j].tolower(), ncoreConfigInfo::io_subsys_instname_a[j], j));
   
           //starting axi_mstr_seq
            axi_mstr_seq[axi_idx].nativeif = ncoreConfigInfo::io_subsys_nativeif_a[j].tolower();
            axi_mstr_seq[axi_idx].instname = ncoreConfigInfo::io_subsys_instname_a[j];
            axi_mstr_seq[axi_idx].portid   = j;
            axi_mstr_seq[axi_idx].start(mstr_agnt_seqr_a[j]);
          end
        end
          tmp_axi_idx++;
      end:_axi_
      if (ncoreConfigInfo::io_subsys_nativeif_a[i] == "ACE" || ncoreConfigInfo::io_subsys_nativeif_a[i] == "ACE5" ) begin: _ace_          
            automatic int j = i;
            automatic int ace_idx = tmp_ace_idx;
            `uvm_info(get_full_name(),$sformatf("starting ace seq"),UVM_LOW)
            begin
            if(t_ioaiu_en[j]==1) begin
            `uvm_info(get_full_name(), $psprintf("Starting io_subsys t_ioaiu_en:%0d index :%0d", t_ioaiu_en[j],j), UVM_LOW);
            `uvm_info(get_full_name(), $psprintf("Starting io_subsys_ace_master_seq(default) on inst:%0s nativeif:%0s on mstr_agnt_seqr_str:%0s", ncoreConfigInfo::io_subsys_instname_a[j], ncoreConfigInfo::io_subsys_nativeif_a[j], mstr_agnt_seqr_str[j]), UVM_LOW);

            ace_mstr_seq[ace_idx] = io_subsys_ace_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", ncoreConfigInfo::io_subsys_nativeif_a[j].tolower(), ncoreConfigInfo::io_subsys_instname_a[j], j));
            
           //starting ace_mstr_seq
            ace_mstr_seq[ace_idx].nativeif = ncoreConfigInfo::io_subsys_nativeif_a[j].tolower();
            ace_mstr_seq[ace_idx].instname = ncoreConfigInfo::io_subsys_instname_a[j];
            ace_mstr_seq[ace_idx].dvm_enable = ncoreConfigInfo::io_subsys_dvm_enable_a[j];
            ace_mstr_seq[ace_idx].portid   = j;
            ace_mstr_seq[ace_idx].start(mstr_agnt_seqr_a[j]);
            
            end
        end
          
      tmp_ace_idx++;
    end: _ace_
    end:_all_ioaiu_loop_
  join_none
  wait fork;

  foreach(ncoreConfigInfo::io_subsys_nativeif_a[i]) begin: _all_ioaiu_loop_
      if (ncoreConfigInfo::io_subsys_nativeif_a[i] == "ACE" || ncoreConfigInfo::io_subsys_nativeif_a[i] == "ACE5" ) begin: _ace_          
       if (p_sequencer.master_sequencer[i] != null)
                my_component = p_sequencer.master_sequencer[i].get_parent();      
            $cast(my_agent,my_component);
            if (my_agent != null) begin
                //`uvm_info(get_full_name(), $psprintf("getting my_agent to get cache "), UVM_LOW);
                my_cache = my_agent.get_cache();
            end
            `uvm_info(get_full_name(),$sformatf("hello iam printing the cache ace"),UVM_LOW)
             `uvm_info(get_full_name(),$sformatf("my_cache=%0p",my_cache),UVM_LOW)
            `uvm_info(get_full_name(),$sformatf("hello printing the cache completed"),UVM_LOW) 
      end: _ace_
  end:_all_ioaiu_loop_
  #50ns;
  
  `uvm_info("IO_SUBSYS_BASE_TEST", $psprintf("user_addrq=%0p", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]), UVM_LOW);

  `uvm_info(get_full_name(),$sformatf("starting ace-lite-e traffic"),UVM_LOW) 
  foreach(ncoreConfigInfo::io_subsys_nativeif_a[i]) begin: _all_ioaiu_if
      if (ncoreConfigInfo::io_subsys_nativeif_a[i] == "ACELITE-E") begin: _ace_lite_e_            
            automatic int j = i;
            automatic int ace_lite_e_idx = tmp_ace_lite_e_idx;
            begin
            if(t_ioaiu_en[j]==1) begin
            `uvm_info(get_full_name(), $psprintf("Starting io_subsys t_ioaiu_en:%0d index :%0d", t_ioaiu_en[j],j), UVM_LOW);
            `uvm_info(get_full_name(), $psprintf("Starting io_subsys_ace_lite_e_master_seq(default) on inst:%0s nativeif:%0s on mstr_agnt_seqr_str:%0s", ncoreConfigInfo::io_subsys_instname_a[j], ncoreConfigInfo::io_subsys_nativeif_a[j], mstr_agnt_seqr_str[j]), UVM_LOW);

            ace_lite_e_mstr_seq[ace_lite_e_idx] = io_subsys_ace_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", ncoreConfigInfo::io_subsys_nativeif_a[j].tolower(), ncoreConfigInfo::io_subsys_instname_a[j], j));
            
           //starting ace_lite_e_mstr_seq 
            ace_lite_e_mstr_seq[ace_lite_e_idx].nativeif = ncoreConfigInfo::io_subsys_nativeif_a[j].tolower();
            ace_lite_e_mstr_seq[ace_lite_e_idx].instname = ncoreConfigInfo::io_subsys_instname_a[j];
            ace_lite_e_mstr_seq[ace_lite_e_idx].dvm_enable = ncoreConfigInfo::io_subsys_dvm_enable_a[j];
            ace_lite_e_mstr_seq[ace_lite_e_idx].portid   = j;
            ace_lite_e_mstr_seq[ace_lite_e_idx].start(mstr_agnt_seqr_a[j]);
          end
         end
      tmp_ace_lite_e_idx++;
    end: _ace_lite_e_
   end: _all_ioaiu_if
  `uvm_info(get_full_name(),$sformatf("completed ace-lite-e traffic"),UVM_LOW) 

  endtask:body
endclass:io_subsys_stash_stress_vseq 
