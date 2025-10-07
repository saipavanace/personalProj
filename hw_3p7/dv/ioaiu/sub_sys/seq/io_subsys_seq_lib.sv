// List of all sequences used in IO subsys
typedef class svt_axi_ace_master_multipart_dvm_sequence;
`include "svt_atomic_seq.svh"
`include "svt_dvm_seq.svh"
`include "svt_exclusive_seq.svh"
`include "svt_axi_seq.svh"
`include "svt_rd_after_wr_seq.svh"
`include "io_subsys_base_seq.svh"
<%if(obj.testBench != "io_aiu"){%>
`include "svt_narrow_single_beat_rd_seq.svh"
`include "svt_narrow_single_beat_wr_seq.svh"
`include "svt_rd_after_wr_wrap_seq.svh"
`include "wr_ordering_selfchk_seq.svh"
`include "svt_producer_seq.svh"
`include "svt_consumer_seq.svh"
`include "io_subsys_axi_directed_noncoh_wr_rd_check_seq.svh"
`include "io_subsys_owo_axi_directed_noncoh_wr_rd_check_seq.svh"
`include "io_subsys_owo_axi_directed_coh_wr_rd_check_seq.svh"
<%}%>
`include "io_subsys_axi_seq.svh"
`include "io_subsys_axi_random_seq.svh"
`include "io_subsys_axi_directed_atomic_self_check_seq.svh"
`include "io_subsys_ace_directed_atomic_self_check_seq.svh"
`include "io_subsys_axi_directed_coh_wr_rd_check_seq.svh"
`include "io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_seq.svh"
`include "io_subsys_axi_exclusive_seq.svh"
`include "io_subsys_axi_sanity_seq.svh"
`include "io_subsys_axi_outstanding_xact_id_seq.svh"
`include "io_subsys_axi_unq_id_random_seq.svh"
`include "io_subsys_axi_unq_id_wr_rd_seq.svh"
`include "io_subsys_axi_wr_data_before_addr_seq.svh"
`include "io_subsys_axi_aligned_addr_seq.svh"
`include "io_subsys_ace_seq.svh"
`include "io_subsys_ace_directed_noncoh_wr_rd_check_seq.svh"
`include "io_subsys_owo_ace_directed_noncoh_wr_rd_check_seq.svh"
`include "io_subsys_ace_directed_coh_wr_rd_check_seq.svh"
`include "io_subsys_owo_ace_directed_coh_wr_rd_check_seq.svh"
`include "io_subsys_atomic_seq.svh"
`include "io_subsys_axi_atomic_seq.svh"
`include "io_subsys_dvm_seq.svh"
`include "io_subsys_ace_mem_upd_seq.svh"

//TODO: Move this into its own file after understanding intent.
// BASE CLASSES USED FOR DVM SEQUENCES
class svt_axi_ace_master_multipart_dvm_sequence extends svt_axi_master_base_sequence;

   //* local field used to set relevant transaction item fields */
   rand svt_axi_transaction::coherent_xact_type_enum seq_xact_type;  
   rand bit [2:0] dvm_message_type = 3'b000;
   svt_axi_master_transaction tr1,tr2;
   

`ifdef SVT_UVM_TECHNOLOGY
  `uvm_object_utils_begin(svt_axi_ace_master_multipart_dvm_sequence)
    `uvm_field_int      (dvm_message_type,UVM_ALL_ON)
    `uvm_field_enum     (svt_axi_transaction::coherent_xact_type_enum,   seq_xact_type, UVM_ALL_ON)
  `uvm_object_utils_end
`elsif SVT_OVM_TECHNOLOGY
  `ovm_object_utils_begin(svt_axi_ace_master_multipart_dvm_sequence)
    `ovm_field_int      (dvm_message_type,OVM_ALL_ON)
    `ovm_field_enum     (svt_axi_transaction::coherent_xact_type_enum,   seq_xact_type, OVM_ALL_ON)
  `ovm_object_utils_end
`endif

`ifdef SVT_MULTI_SIM_ENUM_SCOPE
  // Property needed because MTI 10.0a can't seem to find enums defined in a class
  // scope unless that class is declared somewhere in that file or an included file.
  svt_axi_transaction base_xact;
`endif

  function new(string name="svt_axi_ace_master_multipart_dvm_sequence");
    super.new(name);
  endfunction

  virtual task pre_body();
    super.pre_body();
  endtask: pre_body

  virtual task body();
      svt_configuration base_cfg;
      svt_axi_port_configuration port_cfg;
      int _multi_dvm_first_txn_id;
      bit range_based_tlbi, non_range_based_tlbi;
      bit tlbi;

      super.body();
      `svt_axi_xxm_note("body", "Entered...");
      p_sequencer.get_cfg(base_cfg);
      if (!$cast(port_cfg, base_cfg)) begin
        `svt_axi_xxm_fatal("body", "Unable to $cast the configuration to a svt_axi_system_configuration class");
      end

/** Send part-1 of two-part DVM **/
      `svt_xvm_create(tr1)
      tr1.port_cfg = port_cfg;
      tr1.reasonable_no_multi_part_dvm.constraint_mode(0);
      //tr1.is_part_of_multipart_dvm_sequence = 1;
      void'(tr1.randomize() with {
        tr1.addr[0] == 1;
        tr1.addr[14:12] == dvm_message_type;
        tr1.data_before_addr == 0;
        tr1.xact_type == svt_axi_transaction::COHERENT;
        tr1.burst_type != svt_axi_transaction::FIXED;
        tr1.coherent_xact_type == seq_xact_type;
      });
      _multi_dvm_first_txn_id = tr1.id;
      tlbi = (tr1.addr[14:12]==0) ? 1 : 0;
      range_based_tlbi = (tlbi==1)? ((tr1.addr[7]==1) ? 1 : 0) : 0;
      non_range_based_tlbi = (tlbi==1)? ((tr1.addr[7]==0) ? 1 : 0) : 0;
      `svt_xvm_send(tr1)
      fork
         get_response(rsp);
      join_none
      `uvm_info("body",$psprintf("DVM first part randomized and sent with ID 0x%0h",_multi_dvm_first_txn_id),UVM_LOW)
  
/** Send part-2 of two-part DVM **/
      #10ns;
      `svt_xvm_create(tr2)
      tr2.port_cfg = port_cfg;
      tr2.set_multipart_dvm_flag();
      void'(tr2.randomize() with {
        tr2.id == _multi_dvm_first_txn_id;
        tr2.addr[0] == 0;
        //tr2.addr[14:12] == dvm_message_type;
        if(range_based_tlbi) { // range, num, ttl, tg & scale must be non-zero
             tr2.addr[5:0] != 0; 
             tr2.addr[7:6] != 0; 
             tr2.addr[9:8] != 0; 
             tr2.addr[11:10] != 0; 
             tr2.addr[`SVT_AXI_ADDR_WIDTH:12] == 0; 
        }
        if(non_range_based_tlbi) { // num & scale must be zero
             tr2.addr[5:0] == 0; 
             tr2.addr[7:6] == 0; 
        }
        tr2.data_before_addr == 0;
        tr2.xact_type == svt_axi_transaction::COHERENT;
        tr2.burst_type != svt_axi_transaction::FIXED;
        tr2.coherent_xact_type == seq_xact_type;
      });
      tr2.id = _multi_dvm_first_txn_id;
      `svt_xvm_send(tr2)
      get_response(rsp);
      `uvm_info("body",$psprintf("DVM second part randomized and sent with ID 0x%0h",tr2.id),UVM_LOW)

      fork
      tr1.wait_for_transaction_end();
      tr2.wait_for_transaction_end();
      join

  endtask: body
endclass: svt_axi_ace_master_multipart_dvm_sequence

class conc_svt_axi_ace_master_dvm_base_sequence extends svt_axi_master_base_sequence;

   //* local field used to set relevant transaction item fields */
   rand svt_axi_transaction::coherent_xact_type_enum seq_xact_type;  
   rand bit [2:0] dvm_message_type = 3'b000;
   svt_axi_master_transaction req;
   

`ifdef SVT_UVM_TECHNOLOGY
  `uvm_object_utils_begin(conc_svt_axi_ace_master_dvm_base_sequence)
    `uvm_field_int      (dvm_message_type,UVM_ALL_ON)
    `uvm_field_enum     (svt_axi_transaction::coherent_xact_type_enum,   seq_xact_type, UVM_ALL_ON)
  `uvm_object_utils_end
`elsif SVT_OVM_TECHNOLOGY
  `ovm_object_utils_begin(conc_svt_axi_ace_master_dvm_base_sequence)
    `ovm_field_int      (dvm_message_type,OVM_ALL_ON)
    `ovm_field_enum     (svt_axi_transaction::coherent_xact_type_enum,   seq_xact_type, OVM_ALL_ON)
  `ovm_object_utils_end
`endif

`ifdef SVT_MULTI_SIM_ENUM_SCOPE
  // Property needed because MTI 10.0a can't seem to find enums defined in a class
  // scope unless that class is declared somewhere in that file or an included file.
  svt_axi_transaction base_xact;
`endif

  function new(string name="conc_svt_axi_ace_master_dvm_base_sequence");
    super.new(name);
  endfunction

  virtual task pre_body();
    super.pre_body();
  endtask: pre_body

  virtual task body();
    int unsigned sequence_length = 1;

    super.body();


    /* randomize the item and 
       set the addr and coherent_xact_type from local fields */
    
    `svt_xvm_create(req)
    void'(req.randomize() with {
        req.addr[14:12] == dvm_message_type;
        req.data_before_addr == 0;
        req.xact_type == svt_axi_transaction::COHERENT;
        req.burst_type != svt_axi_transaction::FIXED;
`ifndef SVT_XLVIP_NON_RANDOMIZE_NONAXI3_PARAMETERS
        req.coherent_xact_type == seq_xact_type;
`endif // `ifndef SVT_XLVIP_NON_RANDOMIZE_NONAXI3_PARAMETERS
      });
      `svt_xvm_send(req)
    `uvm_info("body",$psprintf("Sending DVM transaction %0s on port 'd%0d. dvm_message_type = 'h%0x",`SVT_AXI_PRINT_PREFIX1(req),req.port_cfg.port_id,dvm_message_type),UVM_MEDIUM);
      /* 
      Please refer class reference manual on details of following fields
      svt_axi_transaction::is_coherent_xact_dropped
      svt_axi_transaction::is_cached_data
      */
      if(!req.is_coherent_xact_dropped && !req.is_cached_data) begin
         //get_response(rsp);
      end
    `uvm_info("body",$psprintf("Got response for DVM transaction %0s",`SVT_AXI_PRINT_PREFIX1(req)),UVM_MEDIUM);

  endtask: body
endclass: conc_svt_axi_ace_master_dvm_base_sequence

class conc_svt_axi_ace_master_dvm_complete_sequence extends svt_axi_ace_master_dvm_complete_sequence;

bit block_sending_of_DvmComplete = 0;

`ifdef SVT_UVM_TECHNOLOGY
  uvm_phase parent_starting_phase;
`elsif SVT_OVM_TECHNOLOGY
  ovm_phase parent_starting_phase;
`endif

  /** UVM Object Utility macro */
`ifdef SVT_UVM_TECHNOLOGY
  `uvm_object_utils(conc_svt_axi_ace_master_dvm_complete_sequence)
`elsif SVT_OVM_TECHNOLOGY
  `ovm_object_utils(conc_svt_axi_ace_master_dvm_complete_sequence)
`endif

  /** Class Constructor */
  function new (string name = "conc_svt_axi_ace_master_dvm_complete_sequence");
    super.new(name);
  endfunction : new
  
  virtual task body();
    bit status;
`ifdef SVT_UVM_TECHNOLOGY
    uvm_component my_component;
`elsif SVT_OVM_TECHNOLOGY
    ovm_component my_component;
`endif
    svt_configuration base_cfg;
    svt_axi_port_configuration port_cfg;

    `svt_axi_xxm_note("body", "Entered...");
    p_sequencer.get_cfg(base_cfg);
    if (!$cast(port_cfg, base_cfg)) begin
      `svt_axi_xxm_fatal("body", "Unable to $cast the configuration to a svt_axi_system_configuration class");
    end
    my_component = p_sequencer.get_parent();
    if (snoop_resp_seq == null) begin
     `svt_axi_xxm_fatal("body","The snoop_resp_seq member of this class must be set by the sequence calling this sequence")
    end

    fork
    // Wait on DVM Sync and send DVM Complete
    begin
      `SVT_DATA_BASE_OBJECT_TYPE ev_xact;
      svt_axi_snoop_transaction snoop_xact;
      svt_axi_ace_master_dvm_base_sequence dvm_complete_seq= new("dvm_complete_seq");
      while (1) begin
        `svt_axi_xxm_debug("body",$psprintf("Waiting for DVM SYNC on master 'd%0d",port_cfg.port_id));
        snoop_resp_seq.EVENT_DVM_SYNC_XACT.wait_trigger_data(ev_xact);
        if (!$cast(snoop_xact,ev_xact)) begin
          `svt_axi_xxm_fatal("body","Transaction obtained through EVENT_DVM_SYNC_XACT is not of type svt_axi_snoop_transaction");
        end
        `svt_axi_xxm_debug("body",$psprintf("DVM SYNC received on master 'd%0d",snoop_xact.port_cfg.port_id));
        if (snoop_xact.port_cfg.port_id == port_cfg.port_id) begin
          fork
          begin
`ifdef SVT_UVM_TECHNOLOGY
            parent_starting_phase.raise_objection(this);
`endif
            `svt_axi_xxm_debug("body",$psprintf("Received DVM SYNC on port 'd%0d, waiting for transaction to end",port_cfg.port_id));
            wait(snoop_xact.snoop_resp_status == svt_axi_snoop_transaction::ACCEPT);
            `svt_axi_xxm_debug("body",$psprintf("DVM SYNC on port 'd%0d completed, initiating DVM complete",port_cfg.port_id));
            wait(block_sending_of_DvmComplete == 0);
            `svt_xvm_do_with(dvm_complete_seq,
                         {seq_xact_type==svt_axi_transaction::DVMCOMPLETE;
                          dvm_message_type == 3'b000;}
                    ) 
            `svt_axi_xxm_debug("body",$psprintf("DVM COMPLETE on port 'd%0d completed",port_cfg.port_id));
`ifdef SVT_UVM_TECHNOLOGY
            parent_starting_phase.drop_objection(this);
`endif
          end
          join_none
        end
      end
    end
    join_none
    `svt_axi_xxm_note("body", "Exiting...");
  endtask: body
endclass: conc_svt_axi_ace_master_dvm_complete_sequence
