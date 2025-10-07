`ifndef GUARD_IOAIU_RANDOM_ALL_OPS_NO_DVM_SEQUENCE_SVH
`define GUARD_IOAIU_RANDOM_ALL_OPS_NO_DVM_SEQUENCE_SVH

/** 
 *  Sequence used in test - concerto_iosubsys_random_all_ops_no_dvm_snps 
*/
class ioaiu_random_all_ops_no_dvm_sequence extends ioaiu_axi_ace_master_base_virtual_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_system_sequencer) 

  `svt_xvm_object_utils(ioaiu_random_all_ops_no_dvm_sequence)

    /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }

  function new(string name = "ioaiu_random_all_ops_no_dvm_sequence");
    super.new(name);
  endfunction

  virtual task pre_body();
    bit status;
    super.pre_body();
    raise_phase_objection();

  endtask

    /**
    * Initializes cachelines and sends particlar txn from port "port_id"
    */
  virtual task body();
    
    // Check for valid port type
    if (!is_supported(cfg)) begin
      `svt_xvm_note("body", "The sequence cannot be run based on the current system configuration"); 
    end 
    else begin
      super.body();
      `svt_xvm_create_on(coherent_seq, p_sequencer.master_sequencer[port_id])    
       coherent_seq.initialize_cachelines = 1;
      if (cfg.master_cfg[port_id].axi_interface_type == svt_axi_port_configuration::AXI_ACE) begin
          coherent_seq.readnosnoop_wt         = vseq_controls.readnosnoop_wt           ;
          coherent_seq.readonce_wt            = vseq_controls.readonce_wt              ; 
          coherent_seq.readclean_wt           = vseq_controls.readclean_wt             ; 
          coherent_seq.readnotshareddirty_wt  = vseq_controls.readnotshareddirty_wt    ; 
          coherent_seq.readshared_wt          = vseq_controls.readshared_wt            ; 
          coherent_seq.readunique_wt          = vseq_controls.readunique_wt            ; 
          coherent_seq.cleanunique_wt         = vseq_controls.cleanunique_wt           ; 
          coherent_seq.cleanshared_wt         = vseq_controls.cleanshared_wt           ; 
          coherent_seq.cleansharedpersist_wt  = vseq_controls.cleansharedpersist_wt    ; 
          coherent_seq.cleaninvalid_wt        = vseq_controls.cleaninvalid_wt          ; 
          coherent_seq.makeunique_wt          = vseq_controls.makeunique_wt            ; 
          coherent_seq.makeinvalid_wt         = vseq_controls.makeinvalid_wt           ; 
          coherent_seq.writenosnoop_wt        = vseq_controls.writenosnoop_wt          ; 
          coherent_seq.writeunique_wt         = vseq_controls.writeunique_wt           ; 
          coherent_seq.writelineunique_wt     = vseq_controls.writelineunique_wt       ; 
          coherent_seq.writeback_wt           = vseq_controls.writeback_wt             ; 
          coherent_seq.writeclean_wt          = vseq_controls.writeclean_wt            ; 
          coherent_seq.evict_wt               = vseq_controls.evict_wt                 ; 
          coherent_seq.writeevict_wt          = vseq_controls.writeevict_wt            ; 
      end else if ((cfg.master_cfg[port_id].axi_interface_type == svt_axi_port_configuration::ACE_LITE) && (cfg.master_cfg[port_id].ace_version == svt_axi_port_configuration::ACE_VERSION_2_0)) begin
          coherent_seq.readnosnoop_wt               = vseq_controls.readnosnoop_wt           ;
          coherent_seq.readonce_wt                  = vseq_controls.readonce_wt              ;
          coherent_seq.readclean_wt                 =   0;
          coherent_seq.readnotshareddirty_wt        =   0;
          coherent_seq.readshared_wt                =   0;
          coherent_seq.readunique_wt                =   0;
          coherent_seq.cleanunique_wt               =   0;
          coherent_seq.cleanshared_wt               = vseq_controls.cleanshared_wt           ;
          coherent_seq.cleansharedpersist_wt        = vseq_controls.cleansharedpersist_wt    ;
          coherent_seq.cleaninvalid_wt              = vseq_controls.cleaninvalid_wt          ;
          coherent_seq.makeunique_wt                =   0;
          coherent_seq.makeinvalid_wt               = vseq_controls.makeinvalid_wt           ;
          coherent_seq.writenosnoop_wt              = vseq_controls.writenosnoop_wt          ;
          coherent_seq.writeunique_wt               = vseq_controls.writeunique_wt           ;
          coherent_seq.writelineunique_wt           = vseq_controls.writelineunique_wt       ;
          coherent_seq.writeback_wt                 =   0;
          coherent_seq.writeclean_wt                =   0;
          coherent_seq.evict_wt                     =   0; 
          coherent_seq.writeevict_wt                =   0;
          coherent_seq.readoncecleaninvalid_wt      = vseq_controls.readoncecleaninvalid_wt  ;
          coherent_seq.readoncemakeinvalid_wt       = vseq_controls.readoncemakeinvalid_wt   ;

`ifdef SVT_ACE5_ENABLE
          // CONC-11906 : To-do Add logic for stash target to be chiaiu only
          coherent_seq.writeuniqueptlstash_wt      = vseq_controls.writeuniqueptlstash_wt      ;  
          coherent_seq.writeuniquefullstash_wt     = vseq_controls.writeuniquefullstash_wt     ;  
          coherent_seq.stashonceunique_wt          = vseq_controls.stashonceunique_wt          ;  
          coherent_seq.stashonceshared_wt          = vseq_controls.stashonceshared_wt          ;  

          // CONC-11906 : To-do ACE5 feature - Check for cmo on write support
          coherent_seq.cmo_wt                        = vseq_controls.cmo_wt            ; // zero weight due to unsure of cmo on write support
          coherent_seq.writeptlcmo_wt                = vseq_controls.writeptlcmo_wt    ; // zero weight due to unsure of cmo on write support
          coherent_seq.writefullcmo_wt               = vseq_controls.writefullcmo_wt   ; // zero weight due to unsure of cmo on write support
`endif          
      end else if ((cfg.master_cfg[port_id].axi_interface_type == svt_axi_port_configuration::ACE_LITE) && (cfg.master_cfg[port_id].ace_version != svt_axi_port_configuration::ACE_VERSION_2_0)) begin
          coherent_seq.readnosnoop_wt             = vseq_controls.readnosnoop_wt         ;
          coherent_seq.readonce_wt                = vseq_controls.readonce_wt            ;
          coherent_seq.readclean_wt               = 0;
          coherent_seq.readnotshareddirty_wt      = 0;
          coherent_seq.readshared_wt              = 0;
          coherent_seq.readunique_wt              = 0;
          coherent_seq.cleanunique_wt             = 0;
          coherent_seq.cleanshared_wt             = vseq_controls.cleanshared_wt          ;
          coherent_seq.cleansharedpersist_wt      = vseq_controls.cleansharedpersist_wt   ;
          coherent_seq.cleaninvalid_wt            = vseq_controls.cleaninvalid_wt         ;
          coherent_seq.makeunique_wt              = 0;
          coherent_seq.makeinvalid_wt             = vseq_controls.makeinvalid_wt          ;
          coherent_seq.writenosnoop_wt            = vseq_controls.writenosnoop_wt         ;
          coherent_seq.writeunique_wt             = vseq_controls.writeunique_wt          ;
          coherent_seq.writelineunique_wt         = vseq_controls.writelineunique_wt      ;
          coherent_seq.writeback_wt               = 0;
          coherent_seq.writeclean_wt              = 0;
          coherent_seq.evict_wt                   = 0; 
          coherent_seq.writeevict_wt              = 0;
          coherent_seq.readoncecleaninvalid_wt    = vseq_controls.readoncecleaninvalid_wt ;
          coherent_seq.readoncemakeinvalid_wt     = vseq_controls.readoncemakeinvalid_wt  ;
      end else if (cfg.master_cfg[port_id].axi_interface_type == svt_axi_port_configuration::AXI4) begin
          coherent_seq.write_wt                   = vseq_controls.write_wt                    ;
          coherent_seq.read_wt                    = vseq_controls.read_wt                     ;
      end

      void'(coherent_seq.randomize with {use_directed_addr == 0;sequence_length==local::sequence_length;});
      coherent_seq.start(p_sequencer.master_sequencer[port_id]); 

      // Wait for all transactions to finish
      coherent_seq.wait_for_active_xacts_to_end();
    end
  
  endtask: body


 /** Drop objection */
  virtual task post_body();
    drop_phase_objection();
  endtask: post_body

endclass    
 

`endif // `ifndef GUARD_IOAIU_RANDOM_ALL_OPS_NO_DVM_SEQUENCE_SVH 
