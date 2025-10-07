`ifndef GUARD_SVT_AMBA_SEQ_LIB_SV
`define GUARD_SVT_AMBA_SEQ_LIB_SV

<% if(obj.testBench == "fsys") { %>
`ifdef VCS
typedef svt_chi_rn_coherent_transaction_base_sequence cust_svt_chi_rn_coherent_transaction_base_sequence; 
`endif
<% } %>
  import ncore_config_pkg::*;
import addr_trans_mgr_pkg::*;

`ifdef CHI_UNITS_CNT_NON_ZERO
//----------------------------------------------------------------------------------
/**
 * @groupname CHI_SNP
 * Abstract: <br>
 * Class cust_svt_chi_rn_directed_snoop_response_sequence defines a sequence class that 
 * the testbench uses to provide snoop response to the RN agent present in 
 * the System agent. <br>
 * The sequence receives a response object of type 
 * svt_chi_rn_snoop_transaction from RN snoop sequencer. The sequence class then 
 * sets up the snoop response attributes and provides it to the RN driver 
 * within the RN agent. 
 * <br>
 * Execution phase: main_phase <br>
 * Sequencer: RN agent snoop sequencer <br>
 *  <br>
 * The basis for setting up the snoop response based on snoop request type is as 
 * per "Table 6-2 Snooped cache response to snoop requests" of CHI Specification. <br>
 *  <br>
 * The handle to Cache of the RN agent is retrieved from the RN agent and following 
 * method is invoked to read the cache line corresponding to the received snoop
 * request address: read_line_by_addr(req_resp.addr,index,data,byte_enable,is_unique,is_clean,age). <br> 
 * Then the output values from the above method is_unique, is_clean are used to know the
 * state of the cacheline. <br>
 * The state of cache line is used to setup the snoop response attributes based on 
 * the following information: <br>
 *   is_unique is_clean  init_state  read_status <br>
 *     0        0         I           0 <br>
 *     0        0         SD          1 <br>
 *     0        1         SC          1 <br>
 *     1        0         UD          1 <br>
 *     1        1         UC          1 <br>
 *  <br>
 *   datatransfer  Data includes <br>
 *    0            no <br>
 *    1            yes <br>
 *  <br>
 *   passdirty     PD <br>
 *    0            no <br>
 *    1            yes <br>
 *  <br>
 *   isshared      final_state <br>
 *    0            I <br>
 *    1            anything other than I <br>
 *  <br>
 * Following are the attributes of the snoop resonse that are set accordingly, based
 * on the Snp Request type: 
 * - svt_chi_snoop_transaction::snp_rsp_isshared 
 * - svt_chi_snoop_transaction::snp_rsp_datatransfer 
 * - svt_chi_common_transaction::resp_pass_dirty
 * .
 * 
 * Wherever there are more than one possible values for setting of these response
 * attributes, the response attribute values are set randomly.
 */

class cust_svt_chi_rn_directed_snoop_response_sequence extends svt_chi_snoop_transaction_base_sequence;
  /* Response request from the RN snoop sequencer */
  svt_chi_rn_snoop_transaction req_resp;

  /* Handle to RN configuration object obtained from the sequencer */
  svt_chi_node_configuration cfg;
 int chi_snp_rsp_data_err;
 int chi_snp_rsp_non_data_err;

  /** UVM Object Utility macro */
  `svt_xvm_object_utils(cust_svt_chi_rn_directed_snoop_response_sequence)
  
  /** Class Constructor */
  function new(string name="cust_svt_chi_rn_directed_snoop_response_sequence");
    super.new(name);
    
  endfunction

  virtual task body();
    `svt_xvm_debug("body", "Entered ...");

    get_rn_virt_seqr();

    forever begin
      bit [`SVT_CHI_MAX_TAGGED_ADDR_WIDTH-1:0] aligned_addr;
      bit is_unique, is_clean, read_status;
      longint index,age;
      bit[7:0] data[];
      bit byte_enable[];
      data = new[`SVT_CHI_CACHE_LINE_SIZE];
      byte_enable = new[`SVT_CHI_CACHE_LINE_SIZE];
      /**
       * Get the response request from the rn snoop sequencer. The response request is
       * provided to the rn snoop sequencer by the rn driver, through
       * TLM port.
       */
      wait_for_snoop_request(req_resp);
      aligned_addr=req_resp.cacheline_addr(1); 
      read_status = rn_cache.read_line_by_addr(aligned_addr,index,data,byte_enable,is_unique,is_clean,age);

      if (read_status) begin
        case (req_resp.snp_req_msg_type)
          svt_chi_snoop_transaction::SNPSHARED, svt_chi_snoop_transaction::SNPCLEAN
            : begin

            case ({is_unique,is_clean}) 
              2'b00,
              2'b10: begin
                req_resp.snp_rsp_isshared = 0;
                req_resp.snp_rsp_datatransfer = 1;
                req_resp.resp_pass_dirty = 1;
              end
              2'b01: begin
                    req_resp.snp_rsp_isshared = 1;
                    req_resp.resp_pass_dirty = 0; //$urandom_range(1,0);
            //   `ifndef SVT_CHI_ISSUE_A_ENABLE
                    if (req_resp.ret_to_src) begin
                         req_resp.snp_rsp_datatransfer = 1;
                    end else begin
                         req_resp.snp_rsp_datatransfer = 0;
                    end
            //   `endif

              end
              2'b11: begin
                req_resp.snp_rsp_isshared = 1;
                req_resp.snp_rsp_datatransfer = 1;
              end
            endcase // case ({is_unique,is_clean})
          end
        //   `ifndef SVT_CHI_ISSUE_A_ENABLE
          svt_chi_snoop_transaction::SNPNOTSHAREDDIRTY: begin
            case ({is_unique,is_clean}) 
              2'b00,
              2'b10: begin
                req_resp.snp_rsp_isshared = 0;
                req_resp.resp_pass_dirty = 1;
                req_resp.snp_rsp_datatransfer = 1;
              end
              2'b01: begin
                    req_resp.snp_rsp_isshared = 1;
                    req_resp.resp_pass_dirty = 0; //$urandom_range(1,0);
            //   `ifndef SVT_CHI_ISSUE_A_ENABLE
                    if (req_resp.ret_to_src) begin
                        req_resp.snp_rsp_datatransfer = 1;
                    end else begin
                        req_resp.snp_rsp_datatransfer = 0;
                    end
            //   `endif
              end
              2'b11: begin
                req_resp.snp_rsp_isshared = 1;
                req_resp.snp_rsp_datatransfer = 1;
              end
            endcase // case ({is_unique,is_clean})
          end
        //   `endif
          svt_chi_snoop_transaction::SNPONCE: begin
            case ({is_unique,is_clean}) 
              2'b00,
              2'b10: begin
                req_resp.snp_rsp_isshared = 1;
                req_resp.snp_rsp_datatransfer = 1;
                req_resp.resp_pass_dirty = $urandom_range(1,0);
              end
            //   `ifndef SVT_CHI_ISSUE_A_ENABLE
              2'b01: begin
                if (req_resp.ret_to_src) begin
                  req_resp.snp_rsp_datatransfer = 1;
                end
              end
            //   `endif
              2'b11: begin
                req_resp.snp_rsp_isshared = 1;
                // Spec says Yes/No for Data. So made it random.
                req_resp.snp_rsp_datatransfer = $urandom_range(1,0);
              end
            endcase // case ({is_unique,is_clean})
          end
          svt_chi_snoop_transaction::SNPUNIQUE
            // `ifndef SVT_CHI_ISSUE_A_ENABLE
            , svt_chi_snoop_transaction::SNPUNIQUESTASH
            // `endif
          : begin
            if (is_clean) begin
              if (is_unique) begin
                req_resp.snp_rsp_datatransfer = 1;
              end
            //   `ifndef SVT_CHI_ISSUE_A_ENABLE
              if (req_resp.ret_to_src) begin
                req_resp.snp_rsp_datatransfer = 1;
              end
            //   `endif
            end
            else begin
              req_resp.resp_pass_dirty = 1;
              req_resp.snp_rsp_datatransfer = 1;
            end
          end
          svt_chi_snoop_transaction::SNPCLEANSHARED: begin
            req_resp.snp_rsp_isshared = 1;
            if (!is_clean) begin
              req_resp.snp_rsp_datatransfer = 1;
              req_resp.resp_pass_dirty = 1;
              req_resp.snp_rsp_isshared = 0;
            end
          end
          svt_chi_snoop_transaction::SNPCLEANINVALID: begin
            if (!is_clean) begin
              req_resp.snp_rsp_datatransfer = 1;
              req_resp.resp_pass_dirty = 1;
            end
          end
      'hc: begin
           case ({is_unique,is_clean})
           2'b00,
            2'b01: begin
              req_resp.snp_rsp_isshared = 1;
            end
          endcase
        end

       'hb: begin
           case ({is_unique,is_clean})
           2'b00,
            2'b01: begin
            //2'b10: begin
              req_resp.snp_rsp_isshared = 1;
            end
          endcase
        end

        endcase // case (req_resp.snp_req_msg_type)

    if ($test$plusargs("SNPrsp_time_out_test")) begin
        if (req_resp.snp_rsp_datatransfer) begin
        req_resp.MIN_DELAY_wt =1;
        req_resp.SHORT_DELAY_wt =1;
        req_resp.LONG_DELAY_wt = 100;
              if (( 1<< `SVT_CHI_DATA_SIZE_64BYTE)/(req_resp.cfg.flit_data_width/8)) begin
               // req_resp.txdatflitv_delay.size() = ((1 << `SVT_CHI_DATA_SIZE_64BYTE)/(req_resp.cfg.flit_data_width/8));
                req_resp.txdatflitv_delay = new[((1 << `SVT_CHI_DATA_SIZE_64BYTE)/(req_resp.cfg.flit_data_width/8))];
              //req_resp.txdatflitpend_delay = new[((1 << `SVT_CHI_DATA_SIZE_64BYTE)/(req_resp.cfg.flit_data_width/8))];
              //req_resp.txdatflitv_delay =  new[req_resp.compute_num_dat_flits()];
                  $display($time, "SVT_AMBA_SEQ_LIB : delay index size is %0h",req_resp.txdatflitv_delay.size());
              end
              else begin
                req_resp.txdatflitv_delay = new[1];
                //req_resp.txdatflitpend_delay = new[1];
              end
            end 
    end 
        
        if (req_resp.snp_rsp_datatransfer) begin
          for (int j=0; j<`SVT_CHI_CACHE_LINE_SIZE; j++) begin
            req_resp.data[8*j+:8] = data[j];
            // If clean, then all bytes are valid, if dirty it can be
            // that only some bytes are valid (ie, UDP state)
            if (!is_clean)
              req_resp.byte_enable[j] = byte_enable[j];
            else
              req_resp.byte_enable[j] = 1'b1;

            if ($test$plusargs("SNPrsp_time_out_test")) begin
                foreach (req_resp.txdatflitv_delay[idx]) 
                    req_resp.txdatflitv_delay[idx] = $urandom_range(9000,10000);
              //foreach (req_resp.txdatflitpend_delay[idx]) 
                  //req_resp.txdatflitpend_delay[idx] = 20000;
                  //req_resp.txdatflitv_delay[idx] = 15;
                  //$display($time, "SVT_AMBA_SEQ_LIB : delay index is %0h index is %0h",req_resp.txdatflitv_delay[idx],idx);
            end

	    `ifdef SVT_CHI_ISSUE_E_ENABLE
		req_resp.snp_data_cbusy = new[((1 << `SVT_CHI_DATA_SIZE_64BYTE)/(req_resp.cfg.flit_data_width/8))];
	    `endif // `ifdef SVT_CHI_ISSUE_E_ENABLE

          end

          req_resp.dat_rsvdc = new[req_resp.compute_num_dat_flits()];
          foreach (req_resp.dat_rsvdc[idx])
            req_resp.dat_rsvdc[idx] = (idx+1);          
          if ($value$plusargs("SNPrsp_with_data_error=%0d",chi_snp_rsp_data_err)) begin
              req_resp.data_resp_err_status = new[req_resp.compute_num_dat_flits()];
              foreach (req_resp.data_resp_err_status[index])
                req_resp.data_resp_err_status[index] = svt_chi_common_transaction::DATA_ERROR;          
                //req_resp.data_resp_err_status[index] = {req_resp.data_resp_err_status[index] dist {DATA_ERROR := (100-chi_snp_rsp_data_err), NORMAL_OKAY := chi_snp_rsp_data_err};}
               //void'(std::randomize(req_resp.data_resp_err_status) with {req_resp.data_resp_err_status[index] dist {svt_chi_common_transaction::DATA_ERROR := (100-chi_snp_rsp_data_err), svt_chi_common_transaction::NORMAL_OKAY := chi_snp_rsp_data_err};});
          end

          `svt_xvm_debug("body", {`SVT_CHI_SNP_PRINT_PREFIX(req_resp),$sformatf("populating data %0x from cache",req_resp.data)});
        end

      end // if (read_status)

      begin
        string rsp_details, data_details;
        rsp_details = $sformatf("Response: isshared = %0b. datatransfer = %0b. passdirty = %0b. State of the cacheline : is_clean = %0b. is_unique = %0b.", req_resp.snp_rsp_isshared, req_resp.snp_rsp_datatransfer, req_resp.resp_pass_dirty,is_clean,is_unique);
        data_details = req_resp.snp_rsp_datatransfer?"":$sformatf("data = 'h%0h. dat_rsvdc.size = %0d", req_resp.data, req_resp.dat_rsvdc.size());
        `svt_xvm_debug("body", {`SVT_CHI_SNP_PRINT_PREFIX(req_resp), rsp_details, data_details});        
      end
      if ($value$plusargs("SNPrsp_with_data_error=%0d",chi_snp_rsp_data_err)) begin
          req_resp.response_resp_err_status = svt_chi_common_transaction::NORMAL_OKAY;
      end else if ($value$plusargs("SNPrsp_with_non_data_error=%0d",chi_snp_rsp_non_data_err)) begin
          void'(std::randomize(req_resp.response_resp_err_status) with {req_resp.response_resp_err_status dist {svt_chi_common_transaction::NORMAL_OKAY :/ chi_snp_rsp_non_data_err, svt_chi_common_transaction::NON_DATA_ERROR :/ 100-chi_snp_rsp_non_data_err};});
          $display($time, "SVT_AMBA_SEQ_LIB : non-data error on snoop response is %s",req_resp.response_resp_err_status);
      end else begin
          req_resp.response_resp_err_status = svt_chi_common_transaction::NORMAL_OKAY;
      end
      

      $cast(req,req_resp);

      /**
       * send to driver
       */
      `svt_xvm_send(req)

      
    end

    `svt_xvm_debug("body", "Exiting...")
  endtask: body

endclass: cust_svt_chi_rn_directed_snoop_response_sequence
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO


`ifdef CHI_UNITS_CNT_NON_ZERO

/**
 * @groupname CHI_RN_DIRECTED
 * Abstract:
 * This class defines a sequence that sends Read type transactions.
 * Execution phase: main_phase
 * Sequencer: RN agent sequencer
 *
 * This sequence also provides the following attributes which can be
 * controlled through config DB:
 * - sequence_length: Length of the sequence
 * - seq_exp_comp_ack: Control Expect CompAck bit of the transaction from sequences
 * - seq_suspend_wr_data: Control suspend_wr_data response from sequences 
 * - enable_outstanding: Control outstanding transactions from sequences 
 * .
 *
 *
 * <br><b>Usage Guidance::</b>
 * <br>======================================================================
 * <br>[1] General Controls
 * <br>&emsp; a) seq_order_type:
 *        - svt_chi_transaction::NO_ORDERING_REQUIRED      &emsp;&emsp;&emsp;&emsp;<i>// No Ordering</i>
 *        - svt_chi_transaction::REQ_ORDERING_REQUIRED     &emsp;&emsp;&emsp;<i>// Request Ordering</i>
 *        - svt_chi_transaction::REQ_EP_ORDERING_REQUIRED  &emsp;<i>// Request and End-Point Ordering</i>
 *        .
 *
 * &emsp; b) by_pass_read_data_check:
 *        - '0'   &emsp;<i>// Perform Read Data Integrity Check</i>
 *        - '1'   &emsp;<i>// Bypass Read Data Integrity Check</i>
 *        .
 *
 * &emsp; c) use_seq_is_non_secure_access:
 *        - '0'   &emsp;<i>// Do Not consider Secure/Non-Secure Address Space</i>
 *        - '1'   &emsp;<i>// Consider Secure/Non-Secure Address Space</i>
 *        .
 * <br>
 *
 *
 * [2] To generate a CHI RN Read Transaction targetting specific address range, the below sequence's properties <b>MUST</b> be programmed:
 *     - hn_addr_rand_type  ---->  svt_chi_rn_transaction_base_sequence::DIRECTED_ADDR_RANGE_RAND_TYPE
 *     - min_addr           ---->  <font color="#1A41A8"><i>To control the lower value for the range of address</i></font>
 *     - max_addr           ---->  <font color="#1A41A8"><i>To control the upper value for the range of address</i></font>
 *     .
 * &emsp; In case of targetting a specific address, <b><i>min_addr</i></b> and <b><i>max_addr</i></b> must be programmed to same value
 * <br>
 *
 * &emsp; If there are any prior transactions targetting a specific cache line, ensure subsequent transactions have same attributes wherever required
 *     - min_addr                      ---->  <font color="#1A41A8"><i>Address of prior executed transaction</i></font>
 *     - max_addr                      ---->  <font color="#1A41A8"><i>Address of prior executed transaction</i></font>
 *     - seq_snp_attr_snp_domain_type  ---->  <font color="#1A41A8"><i>Same property value from prior executed transaction</i></font>
 *     - seq_mem_attr_allocate_hint    ---->  <font color="#1A41A8"><i>Same property value from prior executed transaction</i></font>
 *     - seq_is_non_secure_access      ---->  <font color="#1A41A8"><i>Same property value from prior executed transaction</i></font>
 *     .
 * <br>
 *
 *
 * [3] To generate a CHI RN Read Transaction targetting a specific HN Node, the below sequence's properties <b>MUST</b> be programmed:
 *     - hn_addr_rand_type  ---->  svt_chi_rn_transaction_base_sequence::DIRECTED_HN_NODE_IDX_RAND_TYPE
 *     - seq_hn_node_idx    ---->  <font color="#1A41A8"><i>Targetted hn_node index</i></font>
 *     .
 * <br>
 *
 *
 */

class cust_svt_chi_rn_read_type_transaction_directed_sequence extends svt_chi_rn_transaction_base_sequence;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length = 10;

  /** @cond PRIVATE */  
  /** Defines the byte enable */
  rand bit [(`SVT_CHI_MAX_BE_WIDTH-1):0] byte_enable = 0;
  
  /** Stores the data written in Cache */
  rand bit [511:0]   data_in_cache;
  
  /** Transaction address */
  rand bit [(`SVT_CHI_MAX_ADDR_WIDTH-1):0]   addr; 
  
  /** Transaction txn_id */
  rand bit[(`SVT_CHI_TXN_ID_WIDTH-1):0] seq_txn_id = 0;

  /** Parameter that controls Suspend CompAck bit of the transaction */
  bit seq_suspend_comp_ack = 0;

  /** Parameter that controls Expect CompAck bit of the transaction */
  bit seq_exp_comp_ack = 0;
  bit seq_exp_comp_ack_status;
  bit seq_suspend_comp_ack_status;
  
  bit enable_outstanding = 0;
  
  /** Flag used to bypass read data check */
  rand bit by_pass_read_data_check = 0;
  
  /** Order type for transaction  is no_ordering_required */
  rand svt_chi_transaction::order_type_enum seq_order_type = svt_chi_transaction::REQ_EP_ORDERING_REQUIRED;

  /** Parameter that controls the MemAttr and SnpAttr of the transaction */
  rand bit seq_mem_attr_allocate_hint = 0;
  rand bit seq_mem_attr_is_early_wr_ack_allowed = 0;
  rand bit seq_mem_attr_mem_type = 1;
  rand bit seq_snp_attr_snp_domain_type = 0;
  rand bit seq_is_non_secure_access = 0;

  /** Handle to CHI Node configuration */
  svt_chi_node_configuration cfg;

  /** Controls using seq_is_non_secure_access or not */
  rand bit use_seq_is_non_secure_access;
  
  /** Local variables */
  int received_responses = 0;

  /** Parameter that controls the type of transaction that will be generated */
  rand svt_chi_transaction::xact_type_enum seq_xact_type;
  
  /** Handle to the read transaction sent out */
  svt_chi_rn_transaction read_tran;

  bit k_decode_err_illegal_acc_format_test_unsupported_size = 0; 
  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 100;
  }

  `ifdef SVT_CHI_ISSUE_E_ENABLE
  constraint valid_txn_id_values {
      /** Constraining the txn_id to be less than 1024 when macro SVT_CHI_ISSUE_E_ENABLE is defined and chi_spec_revision is equal to ISSUE_D */
       if (node_cfg.chi_spec_revision == svt_chi_node_configuration::ISSUE_D) {
         seq_txn_id inside {[0:1023]};
       }
      /** Constraining the txn_id to be less than 256 when macro SVT_CHI_ISSUE_E_ENABLE is defined and chi_spec_revision is less than ISSUE_D */
       else if (node_cfg.chi_spec_revision <= svt_chi_node_configuration::ISSUE_C) {
         seq_txn_id inside {[0:255]};
       }
  }
  `elsif SVT_CHI_ISSUE_D_ENABLE
  constraint valid_txn_id_values {
      /** Constraining the txn_id to be less than 256 when macro SVT_CHI_ISSUE_D_ENABLE is defined and chi_spec_revision is less than ISSUE_D */
       if (node_cfg.chi_spec_revision <= svt_chi_node_configuration::ISSUE_C) {
         seq_txn_id inside {[0:255]};
       }
  }
  `endif

  constraint reasonable_coherent_load_xact_type {
`ifdef SVT_CHI_ISSUE_E_ENABLE
      seq_xact_type inside {
                          svt_chi_transaction::READSHARED, 
                          svt_chi_transaction::READONCE, 
                          svt_chi_transaction::READCLEAN, 
                          svt_chi_transaction::READUNIQUE,
                          svt_chi_transaction::READSPEC,
                          svt_chi_transaction::READNOTSHAREDDIRTY,
                          svt_chi_transaction::READPREFERUNIQUE,
                          svt_chi_transaction::READONCECLEANINVALID,
                          svt_chi_transaction::READONCEMAKEINVALID,
                          svt_chi_transaction::READNOSNP
                         };
`elsif SVT_CHI_ISSUE_B_ENABLE
    //Can't look at svt_chi_node_configuration::chi_spec_revision here as the node configuration handle is only obtained in the body()
    //The code which calls this sequence should ensure that the CHIE Read transaction types are selected only if the corresponding
    //node configuration has svt_chi_node_configuration::chi_spec_revision set to svt_chi_node_configuration::ISSUE_B
    //if(cfg.chi_spec_revision >= svt_chi_node_configuration::ISSUE_B) {
      seq_xact_type inside {
                          svt_chi_transaction::READSHARED, 
                          svt_chi_transaction::READONCE, 
                          svt_chi_transaction::READCLEAN, 
                          svt_chi_transaction::READUNIQUE,
                          svt_chi_transaction::READSPEC,
                          svt_chi_transaction::READNOTSHAREDDIRTY,
                          svt_chi_transaction::READONCECLEANINVALID,
                          svt_chi_transaction::READONCEMAKEINVALID,
                          svt_chi_transaction::READNOSNP
                         };
 `else
      seq_xact_type inside {
                          svt_chi_transaction::READSHARED, 
                          svt_chi_transaction::READONCE, 
                          svt_chi_transaction::READCLEAN, 
                          svt_chi_transaction::READUNIQUE,
                          svt_chi_transaction::READNOSNP 
                         };
 `endif
  } 

  /** @endcond */
  /** UVM/OVM Object Utility macro */
  `svt_xvm_object_utils(cust_svt_chi_rn_read_type_transaction_directed_sequence)
  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  extern function new(string name="cust_svt_chi_rn_read_type_transaction_directed_sequence"); 

  // -----------------------------------------------------------------------------
  virtual task pre_start();
    bit status;
    bit enable_outstanding_status;
    super.pre_start();
    raise_phase_objection();
    status = uvm_config_db #(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);
    `svt_xvm_debug("body", $sformatf("sequence_length is %0d as a result of %0s.", sequence_length, status ? "config DB" : "randomization"));
    enable_outstanding_status = uvm_config_db#(bit)::get(m_sequencer, get_type_name(), "enable_outstanding", enable_outstanding);
    `svt_xvm_debug("body", $sformatf("enable_outstanding is %0d as a result of %0s", enable_outstanding, (enable_outstanding_status?"config DB":"default setting")));
    seq_exp_comp_ack_status = uvm_config_db#(bit)::get(m_sequencer, get_type_name(), "seq_exp_comp_ack", seq_exp_comp_ack);
    `svt_xvm_debug("body", $sformatf("seq_exp_comp_ack is %0d as a result of %0s", seq_exp_comp_ack, (seq_exp_comp_ack_status?"config DB":"default setting")));
    seq_suspend_comp_ack_status = uvm_config_db#(bit)::get(m_sequencer, get_type_name(), "seq_suspend_comp_ack", seq_suspend_comp_ack);
    `svt_xvm_debug("body", $sformatf("seq_suspend_comp_ack is %0d as a result of %0s", seq_suspend_comp_ack, (seq_suspend_comp_ack_status?"config DB":"default setting")));
  endtask // pre_start
  
  // -----------------------------------------------------------------------------
  virtual task body();
    svt_configuration get_cfg;
    bit rand_success;
 
    `svt_xvm_debug("body", "Entered ...")

    if (enable_outstanding)
      track_responses();
   
    /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `svt_xvm_fatal("body", "Unable to $cast the configuration to a svt_chi_node_configuration class");
    end
    get_rn_virt_seqr();
    
    for(int i = 0; i < sequence_length; i++) begin
       
      /** Set up the write transaction */
      `svt_xvm_create(read_tran)
      read_tran.chi_reasonable_exp_comp_ack.constraint_mode(0);
      read_tran.cfg = this.cfg;
      rand_success = read_tran.randomize() with {
        if(hn_addr_rand_type == svt_chi_rn_transaction_base_sequence::DIRECTED_HN_NODE_IDX_RAND_TYPE)
          hn_node_idx == seq_hn_node_idx;
        else if (hn_addr_rand_type == svt_chi_rn_transaction_base_sequence::DIRECTED_ADDR_RANGE_RAND_TYPE) {
          addr >= min_addr;
          addr <= max_addr;
        //   `ifndef SVT_CHI_ISSUE_A_ENABLE
           if(xact_type == svt_chi_transaction::READONCEMAKEINVALID) {
             mem_attr_allocate_hint == 0;
           }
           else {    
             mem_attr_allocate_hint == seq_mem_attr_allocate_hint;
           }
        //   `else
            // mem_attr_allocate_hint == seq_mem_attr_allocate_hint;
        //   `endif
          seq_snp_attr_snp_domain_type == seq_snp_attr_snp_domain_type;
        }
        mem_attr_is_early_wr_ack_allowed == seq_mem_attr_is_early_wr_ack_allowed;
        mem_attr_mem_type  == seq_mem_attr_mem_type;
        order_type == seq_order_type;
        
        xact_type == seq_xact_type;
        //order_type == seq_order_type;
        // order_type == svt_chi_rn_transaction::REQ_ORDERING_REQUIRED;
        txn_id == seq_txn_id;
        data_size == svt_chi_rn_transaction::SIZE_4BYTE;
        if (use_seq_is_non_secure_access) is_non_secure_access == seq_is_non_secure_access;
        is_likely_shared == 0;
        is_exclusive == 0;
        exp_comp_ack == 0;
       
        if (xact_type == svt_chi_transaction::CLEANUNIQUE){
          data == data_in_cache;
        }
      };

      `svt_xvm_debug("body", $sformatf("Sending CHI READ transaction %0s", `SVT_CHI_PRINT_PREFIX(read_tran)));
      `svt_xvm_verbose("body", $sformatf("Sending CHI READ transaction %0s", read_tran.sprint()));
      
      if(seq_exp_comp_ack_status)begin
        /** Expect CompAck field is optional for ReadOnce, ReadNoSnp, CleanShared, CleanInvalid, MakeInvalid in case of RN-I/RN-D */
        if ((cfg.sys_cfg.chi_version == svt_chi_system_configuration::VERSION_5_0) &&
           ((cfg.chi_interface_type == svt_chi_node_configuration::RN_I) ||
            (cfg.chi_interface_type == svt_chi_node_configuration::RN_F) || 
            (cfg.chi_interface_type == svt_chi_node_configuration::RN_D)) 
           ) begin
          read_tran.exp_comp_ack=seq_exp_comp_ack;
        end 
      end
    
      if (read_tran.exp_comp_ack)begin
        read_tran.suspend_comp_ack = seq_suspend_comp_ack;
      end 
      
      `svt_xvm_verbose("body", $sformatf("CHI READ transaction %0s sent", read_tran.sprint()));

      /** Send the Read transaction */
      `svt_xvm_send(read_tran)
      output_xacts.push_back(read_tran);
      if (!enable_outstanding) begin
        get_response(rsp);
        `svt_xvm_verbose("cust_svt_chi_rn_read_type_transaction_directed_sequence::body",$sformatf("data %0h wysiwyg_data %0h",read_tran.data,read_tran.wysiwyg_data));
         //read_tran.wysiwyg_to_right_aligned_data;
         //read_tran.wysiwyg_to_right_aligned_byte_enable;
        // read_tran.right_aligned_to_wysiwyg_data;
        // read_tran.right_aligned_to_wysiwyg_byte_enable;
        //`svt_xvm_verbose("cust_svt_chi_rn_read_type_transaction_directed_sequence::body",$sformatf("\ndata %0h after wysiwyg_to_right_aligned_data",read_tran.data));
        // Exclude data checking for CLEANUNIQUE xact_type
        // Also for READSPEC in cases where data is not updated in the RN
        // cache
        if ((seq_xact_type != svt_chi_transaction::CLEANUNIQUE) 
            && (read_tran.is_error_response_received(0) == 0)
// `ifndef SVT_CHI_ISSUE_A_ENABLE
            && (!((seq_xact_type == svt_chi_transaction::READSPEC) && 
                (read_tran.req_status == svt_chi_transaction::ACCEPT) && 
                (read_tran.data_status == svt_chi_transaction::INITIAL))
                )
// `endif
           ) begin
          // Check READ DATA with data written in Cache 
          if(!by_pass_read_data_check) begin
            if (read_tran.data == data_in_cache) begin
              `svt_xvm_debug("body",{`SVT_CHI_PRINT_PREFIX(read_tran),$sformatf("DATA MATCH: Read data is same as data written to cache. Data = %0x", data_in_cache)});
            end
            else begin
              `svt_xvm_error("body",{`SVT_CHI_PRINT_PREFIX(read_tran),$sformatf("DATA MISMATCH: Read data did not match with data written in cache: GOLDEN DATA %x READ DATA %x",data_in_cache,read_tran.data)});
            end
          end
        end
      end
    end//seq_len

    `svt_xvm_debug("body", "Exiting...");
  endtask: body

  virtual task post_body();
    if (enable_outstanding) begin
      `svt_xvm_debug("body", "Waiting for all responses to be received");
      wait (received_responses == sequence_length);
      `svt_xvm_debug("body", "Received all responses. Dropping objections");
    end
    drop_phase_objection();
  endtask

  task track_responses();
    fork
    begin
      forever begin
        read_tran.wait_end();
        if (read_tran.req_status == svt_chi_transaction::RETRY) begin
          if (read_tran.p_crd_return_on_retry_ack == 0) begin
            `svt_xvm_debug("body", $sformatf({`SVT_CHI_PRINT_PREFIX(read_tran), "received retry response. p_crd_return_on_retry_ack = 0. continuing to wait for completion"}));
            wait (read_tran.req_status == svt_chi_transaction::ACTIVE);
          end
          else begin
            `svt_xvm_debug("body", $sformatf({`SVT_CHI_PRINT_PREFIX(read_tran), "received retry response. p_crd_return_on_retry_ack = 1. As request will be cancelled, not waiting for completion"}));
          end
        end
        else begin
          received_responses++;
          `svt_xvm_debug("body", $sformatf({`SVT_CHI_PRINT_PREFIX(read_tran), "transaction complete"}));
          `svt_xvm_verbose("body", $sformatf({$sformatf("load_directed_seq_received response. received_responses = %0d:\n",received_responses), read_tran.sprint()}));
          break;
        end
      end//forever
    end
    join_none
  endtask

endclass: cust_svt_chi_rn_read_type_transaction_directed_sequence

function cust_svt_chi_rn_read_type_transaction_directed_sequence::new(string name="cust_svt_chi_rn_read_type_transaction_directed_sequence");
  super.new(name);
  //Set the response depth to -1, to accept infinite number of responses
  this.set_response_queue_depth(-1);
endfunction
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO

`ifdef CHI_UNITS_CNT_NON_ZERO
// =============================================================================
/** 
 * @groupname CHI_RN_ORDERING
 * RN transaction non-coherent transaction type sequence that exercises global observability
 * for pre-barrier transactions
 */
class cust_svt_chi_rn_go_noncoherent_sequence extends svt_chi_rn_coherent_transaction_base_sequence;

  typedef bit [(`SVT_CHI_MAX_DATA_WIDTH-1):0] store_data_type;
  store_data_type store_data, directed_store_data;

  /** 
   * Indicates that the data provided in directed_data_mailbox should be used
   * for the transactions generated by this sequence
   */
  bit randomize_with_directed_data;
  rand svt_chi_transaction::order_type_enum seq_order_type = svt_chi_transaction::REQ_EP_ORDERING_REQUIRED;
  rand bit seq_mem_attr_is_early_wr_ack_allowed = 0;
  rand bit seq_mem_attr_mem_type = 1;
  bit k_decode_err_illegal_acc_format_test_unsupported_size = 0; 

  /**
   * Applicable if randomize_with_directed_data is set.
   * A mailbox into which a user can put data to which transactions have to be
   * generated.
   */
  mailbox #(store_data_type) directed_data_mailbox;
  
  `svt_xvm_object_utils(cust_svt_chi_rn_go_noncoherent_sequence)
  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  function new(string name = "cust_svt_chi_rn_go_noncoherent_sequence");
    super.new(name);
    directed_data_mailbox=new();
  endfunction // new

    /** 
    * This sequence randomizes a single transaction based on the weights assigned.
    *  - If randomized_with_directed_addr is set, the transaction is randomized with
    *    the address specified in directed_addr
    *  - If randomized_with_directed_data is set, the transaction is randomized with
    *    the data specified in directed_store_data
    *  - If store_data is set, the transaction is randomized with
    *    the data specified in store_data
    *  .
    */
  virtual task randomize_xact(svt_chi_rn_transaction           rn_xact,
                              bit                              randomize_with_directed_addr, 
                              bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] directed_addr,
                              bit                              directed_snp_attr_is_snoopable,
                              svt_chi_common_transaction::snp_attr_snp_domain_type_enum directed_snp_attr_snp_domain_type,
                              bit                              directed_mem_attr_allocate_hint,
                              bit                              directed_is_non_secure_access,
                              bit                              directed_allocate_in_cache,
                              svt_chi_common_transaction::data_size_enum directed_data_size, 
                              bit [(`SVT_CHI_MAX_DATA_WIDTH-1):0] directed_data,
                              bit [(`SVT_CHI_MAX_BE_WIDTH-1):0] directed_byte_enable,
                              output bit                       req_success,
                              input  int                       sequence_index = 0,
                              input  bit                       gen_uniq_txn_id = 0);
    
    `svt_debug("randomize_xact", "cust_svt_chi_rn_go_noncoherent_sequence - Entered ");

    // Get config from corresponding sequencer and assign it here.
    rn_xact.cfg      = node_cfg;
    if (randomize_with_directed_data)begin
      void'(directed_data_mailbox.try_get(directed_store_data));
    end
    
    req_success = rn_xact.randomize() with 
    { 
    mem_attr_is_early_wr_ack_allowed == seq_mem_attr_is_early_wr_ack_allowed;
    mem_attr_mem_type  == seq_mem_attr_mem_type;
    order_type == seq_order_type;
    xact_type dist {
                    svt_chi_common_transaction::READNOSNP       := readnosnp_wt,       
                    svt_chi_common_transaction::WRITENOSNPFULL  := writenosnpfull_wt,  
                    svt_chi_common_transaction::WRITENOSNPPTL   := writenosnpptl_wt   
                    };
    
    if (randomize_with_directed_addr)  addr == directed_addr;
    // `ifdef SVT_CHI_ISSUE_A_ENABLE
      if (randomize_with_directed_addr && directed_snp_attr_is_snoopable && use_directed_snp_attr)  snp_attr_snp_domain_type == directed_snp_attr_snp_domain_type;
    // `endif
    if (randomize_with_directed_addr && use_directed_mem_attr)  mem_attr_allocate_hint == directed_mem_attr_allocate_hint;
    if (randomize_with_directed_addr && use_directed_non_secure_access)  is_non_secure_access == directed_is_non_secure_access;
    
    requires_go_before_barrier == 1;

    if(store_data != 0) data == store_data;
    if (randomize_with_directed_data)  data == directed_store_data;


    data_size == (k_decode_err_illegal_acc_format_test_unsupported_size==0) ? svt_chi_rn_transaction::SIZE_4BYTE : svt_chi_rn_transaction::SIZE_8BYTE;

    mem_attr_is_cacheable == 0;
    byte_enable == 'hF;
    if(xact_type==svt_chi_common_transaction::WRITENOSNPPTL) {
        is_writedatacancel_used_for_write_xact == 0;
    }
    // `endif
    };
    `svt_debug("randomize_xact", $sformatf("cust_svt_chi_rn_go_noncoherent_sequence - After randomization, randomize_xact \nrandomize_with_directed_addr %0b directed_addr %0h directed_snp_attr_is_snoopable %0b directed_snp_attr_snp_domain_type %0s directed_mem_attr_allocate_hint %0b directed_is_non_secure_access %0b directed_allocate_in_cache %0b directed_data_size %0s directed_data %0h directed_byte_enable %0h req_success %0b sequence_index %0b gen_uniq_txn_id %0b directed_store_data %0h randomize_with_directed_data %0b store_data %0h data_size %0s xact_type %0s byte_enable %0h data %0h",randomize_with_directed_addr, directed_addr, directed_snp_attr_is_snoopable, directed_snp_attr_snp_domain_type.name, directed_mem_attr_allocate_hint, directed_is_non_secure_access, directed_allocate_in_cache, directed_data_size.name, directed_data, directed_byte_enable, req_success, sequence_index, gen_uniq_txn_id, directed_store_data,randomize_with_directed_data,store_data,rn_xact.data_size.name,rn_xact.xact_type.name,rn_xact.byte_enable,rn_xact.data));
  
    //rn_xact.addr[5:0] = 'h0;
    store_data = 'h0;
    `svt_debug("randomize_xact",$psprintf("cust_svt_chi_rn_go_noncoherent_sequence req_success - %b \n%0s", req_success, rn_xact.sprint()));
  endtask // randomize_xact
  
  virtual task body();
    if((readnosnp_wt+writenosnpfull_wt+writenosnpptl_wt) == 0)
      `svt_fatal("body","Wight should be non zero value for atleast one Non-Coherent transaction (READNOSNP, WRITENOSNPPTL, WRITENOSNPFULL)");
    super.body();
  endtask // body

  virtual function svt_chi_rn_transaction get_xact_from_active_queue(int unsigned index);
    if(index > active_xacts.size())
      get_xact_from_active_queue = null;
    else
      get_xact_from_active_queue = active_xacts[index];
  endfunction // get_xact_from_active_queue
  
endclass
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO

`ifdef CHI_UNITS_CNT_NON_ZERO
// =============================================================================
/** 
 * @groupname CHI_PROTOCOL_SERVICE
 * cust_svt_chi_protocol_service_coherency_entry_sequence
 * This sequence creates a coherency_entry svt_chi_protocol_service request.
 */
class cust_svt_chi_protocol_service_coherency_entry_sequence extends svt_chi_protocol_service_base_sequence; 

  /** 
   * Factory Registration.
   */
  `svt_xvm_object_utils(cust_svt_chi_protocol_service_coherency_entry_sequence) 

  /** Constrain the sequence length one for this sequence */
  constraint reasonable_sequence_length {
    sequence_length == 1;
  }
 
  int delay_in_ns;
  bit wait_mode_using_delay;
  bit wait_mode_using_trigger=1;
  static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();
  static uvm_event csr_init_done = ev_pool.get("csr_init_done");
  /**
   * Constructs the svt_chi_protocol_service_active_sequence sequence
   * @param name Sequence instance name.
   */
  extern function new(string name = "cust_svt_chi_protocol_service_coherency_entry_sequence");

  /** 
   * Executes the svt_chi_protocol_service_active_sequence sequence. 
   */
  extern virtual task body();

/** 
  * Function to check if current system configuration meets requirements of this sequence.
  * This sequence requires following configurations
  *  #- Interface type should be RN-F or RN-D with dvm enabled
  *  #- svt_chi_node_configuration::chi_spec_revision = svt_chi_node_configuration::ISSUE_B or more
  *  #- configuration should be set to sysco_interface_enable
  */
  extern virtual function bit is_supported(svt_configuration cfg, bit silent = 0);
endclass

//------------------------------------------------------------------------------
function cust_svt_chi_protocol_service_coherency_entry_sequence::new(string name = "cust_svt_chi_protocol_service_coherency_entry_sequence");
  super.new(name);
  // Make the default sequence_length equal to 1
  sequence_length = 1;
endfunction

//------------------------------------------------------------------------------
task cust_svt_chi_protocol_service_coherency_entry_sequence::body();
  
  super.body();
   
   if (wait_mode_using_delay) begin
      `svt_xvm_debug("body", $sformatf("Adding delay %0d ns cust_svt_chi_protocol_service_coherency_entry_sequence",delay_in_ns));
      #(delay_in_ns*1ns);
   end else if(wait_mode_using_trigger) begin
      `svt_xvm_debug("body", $sformatf("Waiting for csr_init_done trigger cust_svt_chi_protocol_service_coherency_entry_sequence"));
      csr_init_done.wait_trigger();
      #2ns;
      `svt_xvm_debug("body", $sformatf("Done waiting for csr_init_done trigger cust_svt_chi_protocol_service_coherency_entry_sequence"));
   end
//   `ifndef SVT_CHI_ISSUE_A_ENABLE
    /** check if current environment is supported or not */ 
    if(!is_supported(node_cfg, silent))  begin
      `svt_xvm_note("body",$sformatf("This sequence cannot be run based on the current system configuration. Exiting..."))
      return;
    end
    repeat(sequence_length) begin
      `svt_xvm_do_with(req, { service_type == svt_chi_protocol_service::COHERENCY_ENTRY; })
    end
//   `endif
endtask: body

//------------------------------------------------------------------------------
function bit cust_svt_chi_protocol_service_coherency_entry_sequence::is_supported(svt_configuration cfg, bit silent = 0);
    string str_is_supported_info_prefix = "This sequence cannot be run based on the current configuration.\n";
    string str_is_supported_info = "";
    string str_is_supported_info_suffix = "Modify the configurations \n";
    is_supported = super.is_supported(cfg, silent);
    // `ifndef SVT_CHI_ISSUE_A_ENABLE
      if(is_supported) begin
        if(!( 
              (node_cfg.sysco_interface_enable == 1) &&
              (node_cfg.chi_spec_revision >= svt_chi_node_configuration::ISSUE_B) && 
              (node_cfg.chi_interface_type == svt_chi_node_configuration::RN_F || (node_cfg.chi_interface_type == svt_chi_node_configuration::RN_D && node_cfg.dvm_enable == 1))
            ) 
          ) begin
          is_supported = 0;
          str_is_supported_info = $sformatf("sysco_interface_enable %0b, chi_spec_revision %0s, chi_interface_type %0s, dvm_enable %0b", node_cfg.sysco_interface_enable, node_cfg.chi_spec_revision.name(), node_cfg.chi_interface_type.name(), node_cfg.dvm_enable);
        end else begin
          is_supported = 1;
        end  
      end 
    // `endif
    if (!is_supported) begin
      string str_complete_is_supported_info = {str_is_supported_info_prefix, str_is_supported_info, str_is_supported_info_suffix};
      issue_is_supported_failure(str_complete_is_supported_info);
    end
endfunction
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO


`ifdef CHI_UNITS_CNT_NON_ZERO
// =============================================================================
/** 
 * @groupname CHI_RN_BASE_RDM
 * cust_svt_chi_rn_transaction_random_sequence
 *
 * This sequence creates a random svt_chi_rn_transaction request with control
 * over the xact_type field.
 */
class cust_svt_chi_rn_transaction_random_sequence extends svt_chi_rn_transaction_random_sequence;
  
  /** 
   * Factory Registration. 
   */
  `svt_xvm_object_utils(cust_svt_chi_rn_transaction_random_sequence) 

  /** Controls the transaction type of the generated transactions */
  rand svt_chi_common_transaction::xact_type_enum xact_type = svt_chi_common_transaction::READNOSNP;
  bit user_xact_type = 0;

  /** Controls the transaction type of the generated transactions */
  rand bit [(`SVT_CHI_QOS_WIDTH-1):0] qos = 0;
  bit user_qos = 1;
  rand bit [(`SVT_CHI_QOS_WIDTH-1):0] user_non_secure_access = 0;
  /**
   * Constructs the svt_chi_rn_transaction_random_txnid_sequence sequence
   * @param name Sequence instance name.
   */
  extern function new(string name = "cust_svt_chi_rn_transaction_random_sequence");
  
  /** 
   * Executes the svt_chi_rn_transaction_random_txnid_sequence sequence. 
   */
  extern virtual task body();

  /** 
   * Calls `svt_xvm_do_with to send the transction.  Constrains both the xact_type
   * and the txn_id properties.
   */
  extern virtual task send_random_transaction(svt_chi_rn_transaction req);

endclass

//------------------------------------------------------------------------------
function cust_svt_chi_rn_transaction_random_sequence::new(string name = "cust_svt_chi_rn_transaction_random_sequence");
  super.new(name);
endfunction

//------------------------------------------------------------------------------
task cust_svt_chi_rn_transaction_random_sequence::body();
  int xact_type_status;

  /** Get the user sequence_length. */
`ifdef SVT_UVM_TECHNOLOGY
  xact_type_status = uvm_config_db#(svt_chi_common_transaction::xact_type_enum)::get(m_sequencer, get_type_name(), "xact_type", xact_type);
`else
  xact_type_status = m_sequencer.get_config_int({get_type_name(), ".xact_type"}, xact_type);
`endif
  `svt_xvm_debug("body", $sformatf("xact_type is %s as a result of %0s.", xact_type.name(), xact_type_status ? "the config DB" : "randomization"));

  super.body();
endtask

//------------------------------------------------------------------------------
task cust_svt_chi_rn_transaction_random_sequence::send_random_transaction(svt_chi_rn_transaction req);
  `svt_xvm_rand_send_with(req, { 
                            if(local::user_xact_type) {xact_type == local::xact_type;}
                            if(local::user_qos) {qos == local::qos;}
                            if(local::user_non_secure_access) {is_non_secure_access == 0;}
                            });
endtask
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO





`ifdef CHI_UNITS_CNT_NON_ZERO
//////////////////////////////////////////////////////////////////////
//below sequence is for directed_wr_rd test
/////////////////////////////////////////////////////////////////////

class cust_svt_chi_rn_directed_sequence extends svt_chi_rn_coherent_transaction_base_sequence;

  typedef bit [(`SVT_CHI_MAX_DATA_WIDTH-1):0] store_data_type;
  store_data_type store_data, directed_store_data;

  /** 
   * Indicates that the data provided in directed_data_mailbox should be used
   * for the transactions generated by this sequence
   */
  bit randomize_with_directed_data;

  //for coherent and noncohrent transaction 
  bit write_coh;

  //for data_size
  bit [2:0] size;

  /**
   * Applicable if randomize_with_directed_data is set.
   * A mailbox into which a user can put data to which transactions have to be
   * generated.
   */
  mailbox #(store_data_type) directed_data_mailbox;
  
  `svt_xvm_object_utils(cust_svt_chi_rn_directed_sequence)
  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  function new(string name = "cust_svt_chi_rn_directed_sequence");
    super.new(name);
    directed_data_mailbox=new();
  endfunction // new

 /** 
  * This sequence randomizes a single transaction based on the weights assigned.
  *  - If randomized_with_directed_addr is set, the transaction is randomized with
  *    the address specified in directed_addr
  *  - If randomized_with_directed_data is set, the transaction is randomized with
  *    the data specified in directed_store_data
  *  - If store_data is set, the transaction is randomized with
  *    the data specified in store_data
  *  .
  */
  virtual task randomize_xact(svt_chi_rn_transaction           rn_xact,
                              bit                              randomize_with_directed_addr, 
                              bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] directed_addr,
                              bit                              directed_snp_attr_is_snoopable,
                              svt_chi_common_transaction::snp_attr_snp_domain_type_enum directed_snp_attr_snp_domain_type,
                              bit                              directed_mem_attr_allocate_hint,
                              bit                              directed_is_non_secure_access,
                              bit                              directed_allocate_in_cache,
                              svt_chi_common_transaction::data_size_enum directed_data_size, 
                              bit [(`SVT_CHI_MAX_DATA_WIDTH-1):0] directed_data,
                              bit [(`SVT_CHI_MAX_BE_WIDTH-1):0] directed_byte_enable,
                              output bit                       req_success,
                              input  int                       sequence_index = 0,
                              input  bit                       gen_uniq_txn_id = 0);
    
    `svt_debug("randomize_xact", "cust_svt_chi_rn_directed_sequence - Entered ");

    // Get config from corresponding sequencer and assign it here.
    rn_xact.cfg      = node_cfg;
    if (randomize_with_directed_data)begin
      void'(directed_data_mailbox.try_get(directed_store_data));
    end
    
    req_success = rn_xact.randomize() with 
    { 
    if(write_coh==0){
    xact_type inside {       
                    svt_chi_common_transaction::WRITENOSNPFULL,  
                    svt_chi_common_transaction::WRITENOSNPPTL };
                    }
    else{
    xact_type inside { 
                        
                        svt_chi_common_transaction::WRITEBACKFULL, 
                        svt_chi_common_transaction::WRITEBACKPTL, 
                        svt_chi_common_transaction::WRITECLEANFULL, 
                        svt_chi_common_transaction::WRITECLEANPTL, 
                        svt_chi_common_transaction::WRITEEVICTFULL,
                        svt_chi_common_transaction::WRITEUNIQUEFULL,
                        svt_chi_common_transaction::WRITEUNIQUEPTL
                     };
                     }
      
      

    
    if (randomize_with_directed_addr)  addr == directed_addr;
    // `ifdef SVT_CHI_ISSUE_A_ENABLE
      if (randomize_with_directed_addr && directed_snp_attr_is_snoopable && use_directed_snp_attr)  snp_attr_snp_domain_type == directed_snp_attr_snp_domain_type;
    // `endif
    if (randomize_with_directed_addr && use_directed_mem_attr)  mem_attr_allocate_hint == directed_mem_attr_allocate_hint;
    if (randomize_with_directed_addr && use_directed_non_secure_access)  is_non_secure_access == directed_is_non_secure_access;
    
    requires_go_before_barrier == 1;

    if(store_data != 0) data == store_data;
    if (randomize_with_directed_data)  data == directed_store_data;

    order_type == svt_chi_common_transaction::REQ_ORDERING_REQUIRED;
      
    if(size==0){
    data_size == svt_chi_rn_transaction::SIZE_1BYTE && byte_enable == 'h1};
    else if(size==1){
    data_size == svt_chi_rn_transaction::SIZE_2BYTE && byte_enable == 'h3};
    else if(size==2){
    data_size == svt_chi_rn_transaction::SIZE_4BYTE && byte_enable == 'hF};
    else if(size==3){
    data_size == svt_chi_rn_transaction::SIZE_8BYTE && byte_enable == 'hFF};
    else if(size==4){
    data_size == svt_chi_rn_transaction::SIZE_16BYTE &&  byte_enable == 'hFFFF};
    else if(size==5){
    data_size == svt_chi_rn_transaction::SIZE_32BYTE && byte_enable == 'hFFFFFFFF};
    else if(size==6){
    data_size == svt_chi_rn_transaction::SIZE_64BYTE && byte_enable == 'hFFFFFFFFFFFFFFFF};

    mem_attr_is_cacheable == 0;
    //byte_enable == 'hFFFF;
//    `ifndef SVT_CHI_ISSUE_A_ENABLE
    if(xact_type==svt_chi_common_transaction::WRITENOSNPPTL) {
        is_writedatacancel_used_for_write_xact == 0;
    }
    // `endif
    };
    `svt_debug("randomize_xact", $sformatf("cust_svt_chi_rn_directed_sequence - After randomization, randomize_xact \nrandomize_with_directed_addr %0b directed_addr %0h directed_snp_attr_is_snoopable %0b directed_snp_attr_snp_domain_type %0s directed_mem_attr_allocate_hint %0b directed_is_non_secure_access %0b directed_allocate_in_cache %0b directed_data_size %0s directed_data %0h directed_byte_enable %0h req_success %0b sequence_index %0b gen_uniq_txn_id %0b directed_store_data %0h randomize_with_directed_data %0b store_data %0h data_size %0s xact_type %0s byte_enable %0h data %0h",randomize_with_directed_addr, directed_addr, directed_snp_attr_is_snoopable, directed_snp_attr_snp_domain_type.name, directed_mem_attr_allocate_hint, directed_is_non_secure_access, directed_allocate_in_cache, directed_data_size.name, directed_data, directed_byte_enable, req_success, sequence_index, gen_uniq_txn_id, directed_store_data,randomize_with_directed_data,store_data,rn_xact.data_size.name,rn_xact.xact_type.name,rn_xact.byte_enable,rn_xact.data));
  
    //rn_xact.addr[5:0] = 'h0;
    store_data = 'h0;
    `svt_debug("randomize_xact",$psprintf("cust_svt_chi_rn_directed_sequence req_success - %b \n%0s", req_success, rn_xact.sprint()));
  endtask // randomize_xact
  
  virtual task body();
    if((readnosnp_wt+writenosnpfull_wt+writenosnpptl_wt+writeuniquefull_wt+writeuniqueptl_wt) == 0)
      `svt_fatal("body","Wight should be non zero value for atleast one Non-Coherent transaction (READNOSNP, WRITENOSNPPTL, WRITENOSNPFULL)");
    super.body();
  endtask // body

  virtual function svt_chi_rn_transaction get_xact_from_active_queue(int unsigned index);
    if(index > active_xacts.size())
      get_xact_from_active_queue = null;
    else
      get_xact_from_active_queue = active_xacts[index];
  endfunction // get_xact_from_active_queue
  
endclass
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO

`ifdef CHI_UNITS_CNT_NON_ZERO
/////////////////////////////////////////////////////
//directed_rd_seq
////////////////////////////////////////////////////

class cust_svt_chi_rn_read_directed_sequence extends svt_chi_rn_transaction_base_sequence;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length = 10;

  /** @cond PRIVATE */  
  /** Defines the byte enable */
  rand bit [(`SVT_CHI_MAX_BE_WIDTH-1):0] byte_enable = 0;
  
  /** Stores the data written in Cache */
  rand bit [511:0]   data_in_cache;

  //coh and non_coh transaction
  bit rd_coh;

  //size of transaction
  bit [2:0] size;
  
  /** Transaction address */
  rand bit [(`SVT_CHI_MAX_ADDR_WIDTH-1):0]   addr; 
  
  /** Transaction txn_id */
  rand bit[(`SVT_CHI_TXN_ID_WIDTH-1):0] seq_txn_id = 0;

  /** Parameter that controls Suspend CompAck bit of the transaction */
  bit seq_suspend_comp_ack = 0;

  /** Parameter that controls Expect CompAck bit of the transaction */
  bit seq_exp_comp_ack = 0;
  bit seq_exp_comp_ack_status;
  bit seq_suspend_comp_ack_status;
  
  bit enable_outstanding = 0;
  
  /** Flag used to bypass read data check */
  rand bit by_pass_read_data_check = 0;
  
  /** Order type for transaction  is no_ordering_required */
  rand svt_chi_transaction::order_type_enum seq_order_type = svt_chi_transaction::NO_ORDERING_REQUIRED;

  /** Parameter that controls the MemAttr and SnpAttr of the transaction */
  rand bit seq_mem_attr_allocate_hint = 0;
  rand bit seq_snp_attr_snp_domain_type = 0;
  rand bit seq_is_non_secure_access = 0;

  /** Handle to CHI Node configuration */
  svt_chi_node_configuration cfg;

  /** Controls using seq_is_non_secure_access or not */
  rand bit use_seq_is_non_secure_access;
  
  /** Local variables */
  int received_responses = 0;

  /** Parameter that controls the type of transaction that will be generated */
  rand svt_chi_transaction::xact_type_enum seq_xact_type;
  
  /** Handle to the read transaction sent out */
  svt_chi_rn_transaction read_tran;

  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 100;
  }

  `ifdef SVT_CHI_ISSUE_E_ENABLE
  constraint valid_txn_id_values {
      /** Constraining the txn_id to be less than 1024 when macro SVT_CHI_ISSUE_E_ENABLE is defined and chi_spec_revision is equal to ISSUE_D */
       if (node_cfg.chi_spec_revision == svt_chi_node_configuration::ISSUE_D) {
         seq_txn_id inside {[0:1023]};
       }
      /** Constraining the txn_id to be less than 256 when macro SVT_CHI_ISSUE_E_ENABLE is defined and chi_spec_revision is less than ISSUE_D */
       else if (node_cfg.chi_spec_revision <= svt_chi_node_configuration::ISSUE_C) {
         seq_txn_id inside {[0:255]};
       }
  }
  `elsif SVT_CHI_ISSUE_D_ENABLE
  constraint valid_txn_id_values {
      /** Constraining the txn_id to be less than 256 when macro SVT_CHI_ISSUE_D_ENABLE is defined and chi_spec_revision is less than ISSUE_D */
       if (node_cfg.chi_spec_revision <= svt_chi_node_configuration::ISSUE_C) {
         seq_txn_id inside {[0:255]};
       }
  }
  `endif

  /** @endcond */
  /** UVM/OVM Object Utility macro */
  `svt_xvm_object_utils(cust_svt_chi_rn_read_directed_sequence)
  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  extern function new(string name="cust_svt_chi_rn_read_directed_sequence"); 

  // -----------------------------------------------------------------------------
  virtual task pre_start();
    bit status;
    bit enable_outstanding_status;
    super.pre_start();
    raise_phase_objection();
    status = uvm_config_db #(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);
    `svt_xvm_debug("body", $sformatf("sequence_length is %0d as a result of %0s.", sequence_length, status ? "config DB" : "randomization"));
    enable_outstanding_status = uvm_config_db#(bit)::get(m_sequencer, get_type_name(), "enable_outstanding", enable_outstanding);
    `svt_xvm_debug("body", $sformatf("enable_outstanding is %0d as a result of %0s", enable_outstanding, (enable_outstanding_status?"config DB":"default setting")));
    seq_exp_comp_ack_status = uvm_config_db#(bit)::get(m_sequencer, get_type_name(), "seq_exp_comp_ack", seq_exp_comp_ack);
    `svt_xvm_debug("body", $sformatf("seq_exp_comp_ack is %0d as a result of %0s", seq_exp_comp_ack, (seq_exp_comp_ack_status?"config DB":"default setting")));
    seq_suspend_comp_ack_status = uvm_config_db#(bit)::get(m_sequencer, get_type_name(), "seq_suspend_comp_ack", seq_suspend_comp_ack);
    `svt_xvm_debug("body", $sformatf("seq_suspend_comp_ack is %0d as a result of %0s", seq_suspend_comp_ack, (seq_suspend_comp_ack_status?"config DB":"default setting")));
  endtask // pre_start
  
  // -----------------------------------------------------------------------------
  virtual task body();
    svt_configuration get_cfg;
    bit rand_success;
 
    `svt_xvm_debug("body", "Entered ...")

    if (enable_outstanding)
      track_responses();
   
    /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `svt_xvm_fatal("body", "Unable to $cast the configuration to a svt_chi_node_configuration class");
    end
    get_rn_virt_seqr();
    
    for(int i = 0; i < sequence_length; i++) begin
       
      /** Set up the write transaction */
      `svt_xvm_create(read_tran)
      read_tran.chi_reasonable_exp_comp_ack.constraint_mode(0);
      read_tran.cfg = this.cfg;
      rand_success = read_tran.randomize() with {
        if(hn_addr_rand_type == svt_chi_rn_transaction_base_sequence::DIRECTED_HN_NODE_IDX_RAND_TYPE)
          hn_node_idx == seq_hn_node_idx;
        else if (hn_addr_rand_type == svt_chi_rn_transaction_base_sequence::DIRECTED_ADDR_RANGE_RAND_TYPE) {
          addr >= min_addr;
          addr <= max_addr;
        //   `ifndef SVT_CHI_ISSUE_A_ENABLE
           if(xact_type == svt_chi_transaction::READONCEMAKEINVALID) {
             mem_attr_allocate_hint == 0;
           }
           else {    
             mem_attr_allocate_hint == seq_mem_attr_allocate_hint;
           }
        //   `else
        //     mem_attr_allocate_hint == seq_mem_attr_allocate_hint;
        //   `endif
          seq_snp_attr_snp_domain_type == seq_snp_attr_snp_domain_type;
        }
        
        //xact_type == seq_xact_type;
        //order_type == seq_order_type;
        order_type == svt_chi_rn_transaction::REQ_ORDERING_REQUIRED;
        txn_id == seq_txn_id;
        if(size==0){
         data_size == svt_chi_rn_transaction::SIZE_1BYTE};
        else if(size==1){
         data_size == svt_chi_rn_transaction::SIZE_2BYTE};
        else if(size==2){
         data_size == svt_chi_rn_transaction::SIZE_4BYTE};
        else if(size==3){
         data_size == svt_chi_rn_transaction::SIZE_8BYTE};
        else if(size==4){
         data_size == svt_chi_rn_transaction::SIZE_16BYTE};
        else if(size==5){
         data_size == svt_chi_rn_transaction::SIZE_32BYTE};
        else if(size==6){
         data_size == svt_chi_rn_transaction::SIZE_64BYTE};
        if (use_seq_is_non_secure_access) is_non_secure_access == seq_is_non_secure_access;
        is_likely_shared == 0;
        is_exclusive == 0;
        exp_comp_ack == 0;
      
    //   `ifndef  SVT_CHI_ISSUE_A_ENABLE
        if(rd_coh==1){
        xact_type inside {
                          svt_chi_common_transaction::READSHARED, 
                          svt_chi_common_transaction::READONCE, 
                          svt_chi_common_transaction::READCLEAN, 
                          svt_chi_common_transaction::READUNIQUE,
                          svt_chi_common_transaction::READSPEC,
                          svt_chi_common_transaction::READNOTSHAREDDIRTY,
                          svt_chi_common_transaction::READONCECLEANINVALID,
                          svt_chi_common_transaction::READONCEMAKEINVALID
                         };
                         }
     else{ 
       xact_type == svt_chi_common_transaction::READNOSNP;
         }
    
//  `else
//     if(rd_coh==1){
//        xact_type inside {
//                           svt_chi_common_transaction::READSHARED, 
//                           svt_chi_common_transaction::READONCE, 
//                           svt_chi_common_transaction::READCLEAN, 
//                           svt_chi_common_transaction::READUNIQUE
//                          };
//                          }
//      else{ 
//        xact_type == svt_chi_common_transaction::READNOSNP;
//          }
//  `endif
       
        if (xact_type == svt_chi_common_transaction::CLEANUNIQUE){
          data == data_in_cache;
        }
      };

      `svt_xvm_debug("body", $sformatf("Sending CHI READ transaction %0s", `SVT_CHI_PRINT_PREFIX(read_tran)));
      `svt_xvm_verbose("body", $sformatf("Sending CHI READ transaction %0s", read_tran.sprint()));
      
      if(seq_exp_comp_ack_status)begin
        /** Expect CompAck field is optional for ReadOnce, ReadNoSnp, CleanShared, CleanInvalid, MakeInvalid in case of RN-I/RN-D */
        if ((cfg.sys_cfg.chi_version == svt_chi_system_configuration::VERSION_5_0) &&
           ((cfg.chi_interface_type == svt_chi_node_configuration::RN_I) ||
            (cfg.chi_interface_type == svt_chi_node_configuration::RN_F) || 
            (cfg.chi_interface_type == svt_chi_node_configuration::RN_D)) 
           ) begin
          read_tran.exp_comp_ack=seq_exp_comp_ack;
        end 
      end
    
      if (read_tran.exp_comp_ack)begin
        read_tran.suspend_comp_ack = seq_suspend_comp_ack;
      end 
      
      `svt_xvm_verbose("body", $sformatf("CHI READ transaction %0s sent", read_tran.sprint()));

      /** Send the Read transaction */
      `svt_xvm_send(read_tran)
      output_xacts.push_back(read_tran);
      if (!enable_outstanding) begin
        get_response(rsp);
        `svt_xvm_verbose("cust_svt_chi_rn_read_directed_sequence::body",$sformatf("data %0h wysiwyg_data %0h",read_tran.data,read_tran.wysiwyg_data));
         //read_tran.wysiwyg_to_right_aligned_data;
         //read_tran.wysiwyg_to_right_aligned_byte_enable;
        // read_tran.right_aligned_to_wysiwyg_data;
        // read_tran.right_aligned_to_wysiwyg_byte_enable;
        //`svt_xvm_verbose("cust_svt_chi_rn_read_type_directed_sequence::body",$sformatf("\ndata %0h after wysiwyg_to_right_aligned_data",read_tran.data));
        // Exclude data checking for CLEANUNIQUE xact_type
        // Also for READSPEC in cases where data is not updated in the RN
        // cache
        if ((seq_xact_type != svt_chi_transaction::CLEANUNIQUE) 
            && (read_tran.is_error_response_received(0) == 0)
// `ifndef SVT_CHI_ISSUE_A_ENABLE
            && (!((seq_xact_type == svt_chi_transaction::READSPEC) && 
                (read_tran.req_status == svt_chi_transaction::ACCEPT) && 
                (read_tran.data_status == svt_chi_transaction::INITIAL))
                )
// `endif
           ) begin
          // Check READ DATA with data written in Cache 
          if(!by_pass_read_data_check) begin
            if (read_tran.data == data_in_cache) begin
              `svt_xvm_debug("body",{`SVT_CHI_PRINT_PREFIX(read_tran),$sformatf("DATA MATCH: Read data is same as data written to cache. Data = %0x", data_in_cache)});
            end
            else begin
              `svt_xvm_error("body",{`SVT_CHI_PRINT_PREFIX(read_tran),$sformatf("DATA MISMATCH: Read data did not match with data written in cache: GOLDEN DATA %x READ DATA %x",data_in_cache,read_tran.data)});
            end
          end
        end
      end
    end//seq_len

    `svt_xvm_debug("body", "Exiting...");
  endtask: body

  virtual task post_body();
    if (enable_outstanding) begin
      `svt_xvm_debug("body", "Waiting for all responses to be received");
      wait (received_responses == sequence_length);
      `svt_xvm_debug("body", "Received all responses. Dropping objections");
    end
    drop_phase_objection();
  endtask

  task track_responses();
    fork
    begin
      forever begin
        read_tran.wait_end();
        if (read_tran.req_status == svt_chi_transaction::RETRY) begin
          if (read_tran.p_crd_return_on_retry_ack == 0) begin
            `svt_xvm_debug("body", $sformatf({`SVT_CHI_PRINT_PREFIX(read_tran), "received retry response. p_crd_return_on_retry_ack = 0. continuing to wait for completion"}));
            wait (read_tran.req_status == svt_chi_transaction::ACTIVE);
          end
          else begin
            `svt_xvm_debug("body", $sformatf({`SVT_CHI_PRINT_PREFIX(read_tran), "received retry response. p_crd_return_on_retry_ack = 1. As request will be cancelled, not waiting for completion"}));
          end
        end
        else begin
          received_responses++;
          `svt_xvm_debug("body", $sformatf({`SVT_CHI_PRINT_PREFIX(read_tran), "transaction complete"}));
          `svt_xvm_verbose("body", $sformatf({$sformatf("load_directed_seq_received response. received_responses = %0d:\n",received_responses), read_tran.sprint()}));
          break;
        end
      end//forever
    end
    join_none
  endtask

endclass: cust_svt_chi_rn_read_directed_sequence

function cust_svt_chi_rn_read_directed_sequence::new(string name="cust_svt_chi_rn_read_directed_sequence");
  super.new(name);
  //Set the response depth to -1, to accept infinite number of responses
  this.set_response_queue_depth(-1);
endfunction
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO


`ifdef CHI_UNITS_CNT_NON_ZERO
////////////////////////////////////////////////
//READ FINAL_STATE_CACHE
////////////////////////////////////////////

class cust_svt_chi_rd_final_cache_seq extends svt_chi_rn_transaction_base_sequence;

  local svt_chi_rn_agent my_agent;

   /** UVM Object Utility macro */
  `uvm_object_utils(cust_svt_chi_rd_final_cache_seq)

    /** Class Constructor */
  extern function new(string name="cust_svt_chi_rd_final_cache_seq");

  /** Node configuration obtained from the sequencer */
  svt_chi_node_configuration cfg;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length;


  
  /** Stores the data written in Cache */
  bit [511:0]   data_in_cache;

  bit [7:0]                                my_data[];
  bit                                      byteen[];


  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }
  
 // ncore_system_env env;

  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  virtual task body();
    svt_chi_rn_transaction read_tran;
    svt_chi_rn_transaction write_tran;
    svt_chi_rn_agent                         my_agent;
    `SVT_XVM(component)                      my_component;
    svt_axi_cache                            my_cache;
    bit [(`SVT_CHI_MAX_ADDR_WIDTH-1):0] addr_q[];
    bit is_unique,is_clean;
    int status;
    svt_configuration get_cfg;
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("body", "Unable to $cast the configuration to a svt_chi_port_configuration class");
    end
    
     addr_q=new[sequence_length]; 
     my_component = p_sequencer.get_parent();
    
     void'($cast(my_agent,my_component));
     if (my_agent != null)begin
         my_cache = my_agent.rn_cache;
         `uvm_info("body", {$sformatf("CHI HERE ")}, UVM_NONE);
      end 
    super.body();


  for (int i=0; i < sequence_length; i++) begin
      
                      
      /** Set up the read transaction */
       `uvm_create(read_tran)
       read_tran.cfg = this.cfg;
       `svt_xvm_do_with(read_tran,
          {
            data_size        == svt_chi_transaction::SIZE_64BYTE;
	    //is_likely_shared                   == ;
	    snp_attr_is_snoopable              == 1;
	    mem_attr_is_early_wr_ack_allowed   == 1;
	    mem_attr_is_cacheable              ==1 ;
	    //mem_attr_allocate_hint             == ;
	    is_non_secure_access	       ==0;
	    exp_comp_ack                       ==1 ;
            mem_attr_mem_type == svt_chi_transaction::NORMAL;
            xact_type inside {svt_chi_transaction::READSHARED,svt_chi_transaction::READCLEAN,svt_chi_transaction::READUNIQUE
                            //    `ifndef SVT_CHI_ISSUE_A_ENABLE
                              ,svt_chi_transaction::READNOTSHAREDDIRTY
                                //  `endif
                              };
          })

          std::randomize(data_in_cache);
          if (my_cache != null) begin
            my_data = new[`SVT_CHI_CACHE_LINE_SIZE];
            byteen = new[`SVT_CHI_CACHE_LINE_SIZE];
            
            for (int j= 0; j < my_data.size(); j++) begin
              byteen[j] = 1'b1;
              my_data[j] = data_in_cache[j*8+:8];
            end
           end
         
          //if(read_tran.final_state==svt_chi_common_transaction::UC || read_tran.final_state==svt_chi_common_transaction::SC) begin 
          
            is_unique = 1;
            is_clean = 0;
            status = my_cache.write(-1,read_tran.addr,my_data,byteen,is_unique, is_clean);
             my_cache.update_status(read_tran.addr,is_unique,is_clean);
            if (!status) begin
              `uvm_fatal("body", "Unable to write data to RN agent cache");
            end
            else begin
              string info_str = $sformatf(" status = %0b. addr = %0x. is_unique = %0b. is_clean = %0b.", status,read_tran.addr, is_unique, is_clean);
              `uvm_info("body",{"Data written successfully to RN agent cache", info_str}, UVM_NONE);
            end
          //end
          
        /** Wait for the read transaction to complete */
        read_tran.wait_end();

       addr_q[i]=read_tran.addr;
        my_cache.get_status(read_tran.addr,is_unique,is_clean);
      `uvm_info("body", $sformatf("CHI_rd_transaction addr %0h is_unique %0d is_clean %0d",read_tran.addr,is_unique,is_clean), UVM_NONE);
      `uvm_info("body", $sformatf("CHI read transaction data %0h BE %0h addr %0h  is_unique %0d is_clean %0d cu_st %0d fi_st %0d",read_tran.data,read_tran.byte_enable,read_tran.addr,is_unique,is_clean,read_tran.current_state,read_tran.final_state), UVM_NONE);
   

/** Set up the write transaction */
       `uvm_create(write_tran)
       write_tran.cfg = this.cfg;
       `svt_xvm_do_with(write_tran,
          {
            addr==read_tran.addr;
            data_size        == svt_chi_transaction::SIZE_64BYTE;
            xact_type==svt_chi_transaction::READUNIQUE;
            order_type == svt_chi_common_transaction::NO_ORDERING_REQUIRED;
            //is_likely_shared                   == ;
            snp_attr_is_snoopable              == 1;
            mem_attr_is_early_wr_ack_allowed   == 1;
            mem_attr_is_cacheable              == 1;
            //mem_attr_allocate_hint           ==   ;
	    is_non_secure_access	       ==0;
            exp_comp_ack                       == 1 ; 
           
          })

       /** Wait for the write transaction to complete */
       write_tran.wait_end();

        my_cache.get_status(write_tran.addr,is_unique,is_clean);
      `uvm_info("body", {$sformatf("CHI write transaction completed:\n"), write_tran.sprint()}, UVM_NONE);
      `uvm_info("body", $sformatf("CHI_wr_transaction data %0h BE %0h addr %0h  sequence_length %0d cu_st %0d fi_st %0d is_unique %0d is_clean %0d",write_tran.data,write_tran.byte_enable,write_tran.addr,sequence_length,write_tran.current_state,write_tran.final_state,is_unique,is_clean), UVM_NONE);
      

  end
 
  `uvm_info("body", $sformatf("TEST Results"), UVM_NONE);
    //uvm_wait_for_nba_region();

   `uvm_info("body", "Exiting...", UVM_LOW)
  endtask: body

endclass: cust_svt_chi_rd_final_cache_seq

function cust_svt_chi_rd_final_cache_seq::new(string name="cust_svt_chi_rd_final_cache_seq");
  super.new(name);
  //Set the response depth to -1, to accept infinite number of responses
  this.set_response_queue_depth(-1);
endfunction
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO


`ifdef CHI_UNITS_CNT_NON_ZERO
////////////////////////////////////////////////
//EXCLUSIVE FOR READNOTSHAREDDIRTY
////////////////////////////////////////////
// `ifndef SVT_CHI_ISSUE_A_ENABLE
class cust_svt_chi_rdnsd_excl_seq extends svt_chi_rn_transaction_base_sequence;

  local svt_chi_rn_agent my_agent;

   /** UVM Object Utility macro */
  `uvm_object_utils(cust_svt_chi_rdnsd_excl_seq)

    /** Class Constructor */
  extern function new(string name="cust_svt_chi_rdnsd_excl_seq");

  /** Node configuration obtained from the sequencer */
  svt_chi_node_configuration cfg;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length;


  
  /** Stores the data written in Cache */
  bit [511:0]   data_in_cache;

  bit [7:0]                                my_data[];
  bit                                      byteen[];


  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }
  
 // ncore_system_env env;

  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  virtual task body();
    svt_chi_rn_transaction read_tran;
    svt_chi_rn_transaction write_tran;
    svt_chi_rn_agent                         my_agent;
    `SVT_XVM(component)                      my_component;
    svt_axi_cache                            my_cache;
    bit is_unique,is_clean;
    int status;
    svt_configuration get_cfg;
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("body", "Unable to $cast the configuration to a svt_chi_port_configuration class");
    end
    
      `uvm_info("body", $sformatf("CHI_rd_transaction seq_length:%0d",sequence_length), UVM_NONE);
     my_component = p_sequencer.get_parent();
    
     void'($cast(my_agent,my_component));
     if (my_agent != null)begin
         my_cache = my_agent.rn_cache;
      end 
    super.body();


  for (int i=0; i < sequence_length; i++) begin
      
                      
      /** Set up the read transaction */
       `uvm_create(read_tran)
      this.cfg.exclusive_access_enable=1;
       read_tran.cfg = this.cfg;
       `svt_xvm_do_with(read_tran,
          {
            data_size        == svt_chi_transaction::SIZE_64BYTE;
	    //is_likely_shared                   == ;
	    snp_attr_is_snoopable              == 1;
	    mem_attr_is_early_wr_ack_allowed   == 1;
	    mem_attr_is_cacheable              ==1 ;
	    //mem_attr_allocate_hint             == ;
	    exp_comp_ack                       ==1 ;
	    is_non_secure_access	       ==0;
            mem_attr_mem_type == svt_chi_transaction::NORMAL;
            xact_type==svt_chi_transaction::READNOTSHAREDDIRTY;
            is_exclusive==1;
          
          })
          
          
        /** Wait for the read transaction to complete */
        read_tran.wait_end();

        my_cache.get_status(read_tran.addr,is_unique,is_clean);
      `uvm_info("body", $sformatf("CHI_rd_transaction addr %0h is_unique %0d is_clean %0d",read_tran.addr,is_unique,is_clean), UVM_NONE);
      `uvm_info("body", $sformatf("CHI read transaction data %0h BE %0h addr %0h  is_unique %0d is_clean %0d cu_st %0d fi_st %0d",read_tran.data,read_tran.byte_enable,read_tran.addr,is_unique,is_clean,read_tran.current_state,read_tran.final_state), UVM_NONE);
   


  end
 
  `uvm_info("body", $sformatf("TEST Results"), UVM_NONE);
    //uvm_wait_for_nba_region();

   `uvm_info("body", "Exiting...", UVM_LOW)
  endtask: body

endclass: cust_svt_chi_rdnsd_excl_seq

function cust_svt_chi_rdnsd_excl_seq ::new(string name="cust_svt_chi_rdnsd_excl_seq");
  super.new(name);
  //Set the response depth to -1, to accept infinite number of responses
  this.set_response_queue_depth(-1);
endfunction
// `endif //     SVT_CHI_ISSUE_A_ENABLE
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO

`ifdef CHI_UNITS_CNT_NON_ZERO
////////////////////////////////////////////////
//copyback
////////////////////////////////////////////

class cust_svt_chi_copyback_seq extends svt_chi_rn_transaction_base_sequence;

  local svt_chi_rn_agent my_agent;

   /** UVM Object Utility macro */
  `uvm_object_utils(cust_svt_chi_copyback_seq)

    /** Class Constructor */
  extern function new(string name="cust_svt_chi_copyback_seq");

  /** Node configuration obtained from the sequencer */
  svt_chi_node_configuration cfg;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length;


  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }
  
 // ncore_system_env env;

  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  virtual task body();
    svt_chi_rn_transaction write_tran_1,write_tran_2,write_tran_3;
    svt_chi_rn_transaction write_tran;
    svt_chi_rn_agent                         my_agent;
    `SVT_XVM(component)                      my_component;
    svt_axi_cache                            my_cache;
    bit is_unique,is_clean;


    super.body();



  for (int i=0; i < sequence_length; i++) begin
      
         my_component = p_sequencer.get_parent();
         void'($cast(my_agent,my_component));
        if (my_agent != null)begin
          my_cache = my_agent.rn_cache;
        end 

       /** Set up the mkuniq transaction */
       `uvm_create(write_tran)
       write_tran.cfg = this.cfg;
       `svt_xvm_do_with(write_tran,
          {
           xact_type                     == svt_chi_rn_transaction::MAKEUNIQUE;
           data_size                     == svt_chi_rn_transaction::SIZE_64BYTE;
           exp_comp_ack                  == 1'b1;
           snp_attr_is_snoopable         == 1'b1;
           mem_attr_is_cacheable         == 1'b1;
           snp_attr_snp_domain_type      == svt_chi_transaction::INNER;
	   is_non_secure_access inside {0,1};
           mem_attr_is_early_wr_ack_allowed == 1'b1;
           mem_attr_mem_type             == svt_chi_transaction::NORMAL;
                      })


       /** Wait for the write transaction to complete */
       write_tran.wait_end();

        my_cache.get_status(write_tran.addr,is_unique,is_clean);
      `uvm_info("body", {$sformatf("CHI mkuniq transaction completed:\n"), write_tran.sprint()}, UVM_NONE);
      `uvm_info("body", $sformatf("CHI_mkuniq_transaction data %0h BE %0h addr %0h  sequence_length %0d cu_st %0d fi_st %0d is_unique %0d is_clean %0d",write_tran.data,write_tran.byte_enable,write_tran.addr,sequence_length,write_tran.current_state,write_tran.final_state,is_unique,is_clean), UVM_NONE);
       
      /** Set up the cpback transaction */
       `uvm_create(write_tran_1)
       write_tran_1.cfg = this.cfg;
       `svt_xvm_do_with(write_tran_1,
          {
           addr==write_tran.addr;
           data_size == svt_chi_rn_transaction::SIZE_64BYTE;
       xact_type inside {svt_chi_transaction::WRITEBACKFULL, 
                      svt_chi_transaction::WRITEBACKPTL, 
                      svt_chi_transaction::WRITECLEANFULL, 
                      svt_chi_transaction::WRITECLEANPTL,
                      //svt_chi_transaction::WRITEUNIQUEFULL, 
                      //svt_chi_transaction::WRITEUNIQUEPTL,
                      svt_chi_transaction::WRITEEVICTFULL,
                      svt_chi_transaction::EVICT};
      if ((xact_type != svt_chi_transaction::WRITEBACKPTL) && (xact_type != svt_chi_transaction::WRITECLEANPTL) && (xact_type != svt_chi_transaction::WRITEUNIQUEPTL)) {
      byte_enable == 64'hFFFF_FFFF_FFFF_FFFF;}
      else {
        byte_enable == byte_enable; 
      }

      exp_comp_ack == 1'b0;
      is_non_secure_access inside {0,1};
      if(xact_type == svt_chi_transaction::WRITEBACKPTL){
      is_likely_shared == 1'b0;}
      snp_attr_is_snoopable == 1'b1;
      mem_attr_is_cacheable == 1'b1;
      snp_attr_snp_domain_type == svt_chi_transaction::INNER;
      mem_attr_is_early_wr_ack_allowed == 1'b1;
      mem_attr_mem_type == svt_chi_transaction::NORMAL;
      if (xact_type == svt_chi_transaction::EVICT){
          mem_attr_allocate_hint == 1'b0;}

      if (cfg.chi_spec_revision >= svt_chi_node_configuration::ISSUE_B){
        if (xact_type == svt_chi_transaction::WRITEEVICTFULL) {
          mem_attr_allocate_hint == 1'b1;}
        }
          })


       /** Wait for the write transaction to complete */
      // write_tran_1.wait_end();

       my_cache.get_status(write_tran_1.addr,is_unique,is_clean);
      `uvm_info("body", $sformatf("CHI_cpback_transaction addr %0h is_unique %0d is_clean %0d",write_tran_1.addr,is_unique,is_clean), UVM_NONE);
      `uvm_info("body", $sformatf("CHI cpback transaction data %0h BE %0h addr %0h  is_unique %0d is_clean %0d cu_st %0d fi_st %0d",write_tran_1.data,write_tran_1.byte_enable,write_tran_1.addr,is_unique,is_clean,write_tran_1.current_state,write_tran_1.final_state), UVM_NONE);

       

  end


for (int i=0; i <200; i++) begin
      
         my_component = p_sequencer.get_parent();
         void'($cast(my_agent,my_component));
        if (my_agent != null)begin
          my_cache = my_agent.rn_cache;
          `uvm_info("body", {$sformatf("CHI HERE ")}, UVM_NONE);
        end 

       /** Set up the write transaction */
       `uvm_create(write_tran_2)
       write_tran_2.cfg = this.cfg;
       `svt_xvm_do_with(write_tran_2,
          {
            //is_non_secure_access == 1'b0;
            data_size        == svt_chi_transaction::SIZE_64BYTE;
            xact_type inside {svt_chi_transaction::READCLEAN,svt_chi_transaction::READONCE};
	    if(xact_type == svt_chi_transaction::READONCE){
            is_likely_shared                   ==0 };
	    snp_attr_is_snoopable              == 1;
	    mem_attr_is_early_wr_ack_allowed   == 1;
	    mem_attr_is_cacheable              == 1;
	    is_non_secure_access inside {0,1};
	    //mem_attr_allocate_hint           ==   ;
	    exp_comp_ack                       == 1;
            mem_attr_mem_type == svt_chi_transaction::NORMAL;
           
          })


       /** Wait for the write transaction to complete */
       write_tran_2.wait_end();
       my_cache.get_status(write_tran_2.addr,is_unique,is_clean);

      `uvm_info("body", {$sformatf("CHI write transaction completed:\n"), write_tran_2.sprint()}, UVM_NONE);
      `uvm_info("body", $sformatf("CHI_wr_transaction data %0h BE %0h addr %0h  sequence_length %0d cu_st %0d fi_st %0d is_unique %0d is_clean %0d",write_tran_2.data,write_tran_2.byte_enable,write_tran_2.addr,sequence_length,write_tran_2.current_state,write_tran_2.final_state,is_unique,is_clean), UVM_NONE);
       
      /** Set up the read transaction */
       `uvm_create(write_tran_3)
       write_tran_3.cfg = this.cfg;
       `svt_xvm_do_with(write_tran_3,
          {
           addr==write_tran_2.addr;
           data_size == svt_chi_rn_transaction::SIZE_64BYTE;
           xact_type inside {
                      svt_chi_transaction::WRITEEVICTFULL,
                      svt_chi_transaction::EVICT};
          exp_comp_ack == 1'b0;
	  is_non_secure_access inside {0,1};
          if (xact_type == svt_chi_transaction::EVICT){
          is_likely_shared == 1'b0};
          snp_attr_is_snoopable == 1'b1;
          mem_attr_is_cacheable == 1'b1;
         snp_attr_snp_domain_type == svt_chi_transaction::INNER;
      mem_attr_is_early_wr_ack_allowed == 1'b1;
      mem_attr_mem_type == svt_chi_transaction::NORMAL;
      if (xact_type == svt_chi_transaction::EVICT){
          mem_attr_allocate_hint == 1'b0};
          })

       /** Wait for the write transaction to complete */
       write_tran_3.wait_end();

       my_cache.get_status(write_tran_3.addr,is_unique,is_clean);
      `uvm_info("body", $sformatf("CHI_rd_transaction addr %0h is_unique %0d is_clean %0d",write_tran_3.addr,is_unique,is_clean), UVM_NONE);
         my_cache.get_status(write_tran_3.addr,is_unique,is_clean);

      `uvm_info("body", $sformatf("CHI read transaction data %0h BE %0h addr %0h  is_unique %0d is_clean %0d cu_st %0d fi_st %0d",write_tran_3.data,write_tran_3.byte_enable,write_tran_3.addr,is_unique,is_clean,write_tran_3.current_state,write_tran_3.final_state), UVM_NONE);

       

  end

 
  `uvm_info("body", $sformatf("TEST Results"), UVM_NONE);
    //uvm_wait_for_nba_region();

   `uvm_info("body", "Exiting...", UVM_LOW)
  endtask: body

endclass: cust_svt_chi_copyback_seq

function cust_svt_chi_copyback_seq::new(string name="cust_svt_chi_copyback_seq");
  super.new(name);
  //Set the response depth to -1, to accept infinite number of responses
  this.set_response_queue_depth(-1);
endfunction
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO

`ifdef CHI_UNITS_CNT_NON_ZERO
`ifdef SVT_CHI_ISSUE_E_ENABLE
////////////////////////////////////////////////
//copyback_chi_e_write_evict_or_evict
////////////////////////////////////////////

class cust_svt_chi_e_write_evict_or_evict_seq extends svt_chi_rn_transaction_base_sequence;

  local svt_chi_rn_agent my_agent;

   /** UVM Object Utility macro */
  `uvm_object_utils(cust_svt_chi_e_write_evict_or_evict_seq)

   //Address Manager handle
   addr_trans_mgr m_addr_mgr;

    /** Class Constructor */
  extern function new(string name="cust_svt_chi_e_write_evict_or_evict_seq");

  /** Node configuration obtained from the sequencer */
  svt_chi_node_configuration cfg;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length;

  bit use_backdoor_cache_write = 1;

  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }
  
 // ncore_system_env env;

  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  virtual task body();
    svt_chi_rn_transaction read_tran;
    svt_chi_rn_transaction write_tran;
    svt_chi_rn_transaction write_tran_2;
    svt_chi_rn_agent                         my_agent;
    `SVT_XVM(component)                      my_component;
    svt_axi_cache                            my_cache;
    bit is_unique,is_clean;
    bit [`SVT_CHI_MAX_ADDR_WIDTH-1:0] aligned_addr;
    bit[7:0] data[];
    bit byte_enable[];
    data = new[`SVT_CHI_CACHE_LINE_SIZE];
    byte_enable = new[`SVT_CHI_CACHE_LINE_SIZE]; 

    super.body();

      
         my_component = p_sequencer.get_parent();
         void'($cast(my_agent,my_component));
        if (my_agent != null)begin
          my_cache = my_agent.rn_cache;
        end 

  for (int i=0; i < sequence_length; i++) begin

      if($test$plusargs("unmapped_add_enabled") || $test$plusargs("non_secure_access_test") || $test$plusargs("dce_connectivity_check") || $test$plusargs("illegal_dii_access_check") || $test$plusargs("STRreq_time_out_test") || $test$plusargs("CMDrsp_time_out_test")) begin

	if($test$plusargs("illegal_dii_access_check")) aligned_addr = m_addr_mgr.gen_noncoh_addr(0, 1);
	else if($test$plusargs("unmapped_add_enabled")) std::randomize(aligned_addr) with {!(aligned_addr inside {[ncoreConfigInfo::BOOT_REGION_BASE:ncoreConfigInfo::BOOT_REGION_BASE + ncoreConfigInfo::BOOT_REGION_SIZE-1]});};
	else aligned_addr = m_addr_mgr.gen_coh_addr(0, 1);
	
	aligned_addr[5:0] 	= 6'h0;
	for(int j=0; j < 64; j++) begin
	    data[j]		= $urandom();
	    byte_enable[j]	= 1; 
	end

	my_cache.backdoor_write($urandom_range(255, 0),aligned_addr,data,byte_enable,1,1,-1,1,-1,0);

	my_cache.get_status(aligned_addr,is_unique,is_clean);
        `uvm_info("body", $sformatf("cust_svt_chi_e_write_evict_or_evict_seq cache backdoor_write data %p BE %p addr %0h sequence_length %0d is_unique %0d is_clean %0d",data,byte_enable,aligned_addr,sequence_length,is_unique,is_clean), UVM_NONE);

	`uvm_create(write_tran_2)
        write_tran_2.cfg = this.cfg;
        `svt_xvm_do_with(write_tran_2,
          {
           addr			== aligned_addr;
           data_size 		== svt_chi_rn_transaction::SIZE_64BYTE;
       	   xact_type		== svt_chi_rn_transaction::WRITEEVICTOREVICT; 
	   is_non_secure_access == 1;
          })

        /** Wait for the write transaction to complete */
        write_tran_2.wait_end();

      end else begin


	if(use_backdoor_cache_write) begin 
	    aligned_addr = m_addr_mgr.gen_coh_addr(0, 1);
	    
	    aligned_addr[5:0] 	= 6'h0;
	    for(int j=0; j < 64; j++) begin
	        data[j]		= $urandom();
	        byte_enable[j]	= 1; 
	    end

	    my_cache.backdoor_write($urandom_range(255, 0),aligned_addr,data,byte_enable,0,1,-1,1,-1,0);

	    my_cache.get_status(aligned_addr,is_unique,is_clean);
            `uvm_info("body", $sformatf("cust_svt_chi_e_write_evict_or_evict_seq cache backdoor_write data %p BE %p addr %0h sequence_length %0d is_unique %0d is_clean %0d",data,byte_enable,aligned_addr,sequence_length,is_unique,is_clean), UVM_NONE);
	end else begin
	    /** Set up the read transaction */
            `uvm_create(read_tran)
            read_tran.cfg = this.cfg;
            `svt_xvm_do_with(read_tran,
              {
               xact_type inside {svt_chi_transaction::READCLEAN,svt_chi_transaction::READSHARED,svt_chi_transaction::READPREFERUNIQUE};
               data_size                     	== svt_chi_rn_transaction::SIZE_64BYTE;
               exp_comp_ack                  	== 1'b1;
               snp_attr_is_snoopable         	== 1'b1;
               mem_attr_is_cacheable         	== 1'b1;
               mem_attr_is_early_wr_ack_allowed     == 1'b1;
               mem_attr_mem_type             	== svt_chi_transaction::NORMAL;
	     })

            /* Wait for the read transaction to complete */
            read_tran.wait_end();
	end

      /* Set up the writeevictorevict transaction */
       `uvm_create(write_tran)
       write_tran.cfg = this.cfg;
       `svt_xvm_do_with(write_tran,
          {
	   if(use_backdoor_cache_write){
           addr					== aligned_addr;
	   is_non_secure_access 		== 1;
	   } else {
           addr					== read_tran.addr;
	   }
           data_size 				== svt_chi_rn_transaction::SIZE_64BYTE;
       	   xact_type			 	== svt_chi_rn_transaction::WRITEEVICTOREVICT; 
          })

       /** Wait for the write transaction to complete */
       //write_tran.wait_end();
       
      end

  end

  `uvm_info("body", $sformatf("TEST Results"), UVM_NONE);
    //uvm_wait_for_nba_region();

   `uvm_info("body", "Exiting...", UVM_LOW)
  endtask: body

endclass: cust_svt_chi_e_write_evict_or_evict_seq

function cust_svt_chi_e_write_evict_or_evict_seq::new(string name="cust_svt_chi_e_write_evict_or_evict_seq");
  super.new(name);

  m_addr_mgr = addr_trans_mgr::get_instance();

  //Set the response depth to -1, to accept infinite number of responses
  this.set_response_queue_depth(-1);
endfunction
`endif // `ifdef SVT_CHI_ISSUE_E_ENABLE
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO

`ifdef CHI_UNITS_CNT_NON_ZERO
`ifdef SVT_CHI_ISSUE_E_ENABLE
////////////////////////////////////////////////
//copyback_chi_e_write_cmo
////////////////////////////////////////////

class cust_svt_chi_copyback_chi_e_write_cmo_seq extends svt_chi_rn_transaction_base_sequence;

  local svt_chi_rn_agent my_agent;

   /** UVM Object Utility macro */
  `uvm_object_utils(cust_svt_chi_copyback_chi_e_write_cmo_seq)

    /** Class Constructor */
  extern function new(string name="cust_svt_chi_copyback_chi_e_write_cmo_seq");

  /** Node configuration obtained from the sequencer */
  svt_chi_node_configuration cfg;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length;


  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }
  
 // ncore_system_env env;

  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  virtual task body();
    svt_chi_rn_transaction read_tran;
    svt_chi_rn_transaction write_tran;
    svt_chi_rn_agent                         my_agent;
    `SVT_XVM(component)                      my_component;
    svt_axi_cache                            my_cache;
    bit is_unique,is_clean;

    super.body();

  for (int i=0; i < sequence_length; i++) begin
      
         my_component = p_sequencer.get_parent();
         void'($cast(my_agent,my_component));
        if (my_agent != null)begin
          my_cache = my_agent.rn_cache;
        end 

       /** Set up the mkuniq transaction */
       `uvm_create(read_tran)
        read_tran.cfg = this.cfg;
       `svt_xvm_do_with(read_tran,
          {
       	   xact_type			 	== svt_chi_rn_transaction::MAKEUNIQUE; 
           data_size                     	== svt_chi_rn_transaction::SIZE_64BYTE;
           exp_comp_ack                  	== 1'b1;
           snp_attr_is_snoopable         	== 1'b1;
           mem_attr_is_cacheable         	== 1'b1;
           snp_attr_snp_domain_type      	== svt_chi_transaction::INNER;
	   is_non_secure_access inside {0,1};
           mem_attr_is_early_wr_ack_allowed     == 1'b1;
           mem_attr_mem_type             	== svt_chi_transaction::NORMAL;
	 })

       /* Wait for the read transaction to complete */
       read_tran.wait_end();

      /* Set up the cpback transaction */
       `uvm_create(write_tran)
       write_tran.cfg = this.cfg;
       `svt_xvm_do_with(write_tran,
          {
           addr					== read_tran.addr;
           data_size 				== svt_chi_rn_transaction::SIZE_64BYTE;
           xact_type inside			{  svt_chi_rn_transaction::WRITEBACKFULL_CLEANSHARED,
						   svt_chi_rn_transaction::WRITEBACKFULL_CLEANINVALID,
						   svt_chi_rn_transaction::WRITEBACKFULL_CLEANSHAREDPERSISTSEP,
           					   svt_chi_rn_transaction::WRITECLEANFULL_CLEANSHARED,
						   svt_chi_rn_transaction::WRITECLEANFULL_CLEANSHAREDPERSISTSEP };
      	   exp_comp_ack 			== 1'b0;
	   is_non_secure_access inside {0,1};
      	   snp_attr_is_snoopable 		== 1'b1;
      	   mem_attr_is_cacheable 		== 1'b1;
      	   snp_attr_snp_domain_type 		== svt_chi_transaction::INNER;
      	   mem_attr_is_early_wr_ack_allowed 	== 1'b1;
      	   mem_attr_mem_type 			== svt_chi_transaction::NORMAL;
          })

       /** Wait for the write transaction to complete */
       //write_tran.wait_end();

  end

  `uvm_info("body", $sformatf("TEST Results"), UVM_NONE);
    //uvm_wait_for_nba_region();

   `uvm_info("body", "Exiting...", UVM_LOW)
  endtask: body

endclass: cust_svt_chi_copyback_chi_e_write_cmo_seq

function cust_svt_chi_copyback_chi_e_write_cmo_seq::new(string name="cust_svt_chi_copyback_chi_e_write_cmo_seq");
  super.new(name);
  //Set the response depth to -1, to accept infinite number of responses
  this.set_response_queue_depth(-1);
endfunction
`endif // `ifdef SVT_CHI_ISSUE_E_ENABLE
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO

`ifdef CHI_UNITS_CNT_NON_ZERO

//////////////////////////////////////////////
////EXCLUSIVE_SEQ FOR WRITE
////////////////////////////////////////////

class cust_svt_chi_exclusive_seq extends svt_chi_rn_transaction_base_sequence;

  local svt_chi_rn_agent my_agent;

   /** UVM Object Utility macro */
  `uvm_object_utils(cust_svt_chi_exclusive_seq)

    /** Class Constructor */
  extern function new(string name="cust_svt_chi_exclusive_seq");

  /** Node configuration obtained from the sequencer */
  svt_chi_node_configuration cfg;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length;

  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }
  
 // ncore_system_env env;

  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  virtual task body();

    svt_chi_rn_transaction load_tran;
    svt_chi_rn_transaction store_tran;
    svt_chi_rn_agent                         my_agent;
    `SVT_XVM(component)                      my_component;
    svt_axi_cache                            my_cache;
    bit is_unique,is_clean;
    int status;
    svt_configuration get_cfg;
    p_sequencer.get_cfg(get_cfg);

    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("body", "Unable to $cast the configuration to a svt_chi_port_configuration class");
    end
         my_component = p_sequencer.get_parent();
         void'($cast(my_agent,my_component));
        if (my_agent != null)begin
          my_cache = my_agent.rn_cache;
        end 

    super.body();

   for (int i=0; i < sequence_length; i++) begin

    if ($test$plusargs("non_snoopable_full_excl")) begin

      `uvm_create(load_tran)
      this.cfg.exclusive_access_enable=1;
      load_tran.cfg = this.cfg;
      load_tran.cfg.exclusive_access_enable=1;

       `svt_xvm_do_with(load_tran,
          {
          xact_type			 	== svt_chi_rn_transaction::READNOSNP; 
          data_size == svt_chi_rn_transaction::SIZE_64BYTE;
          mem_attr_is_cacheable inside {0,1} ;
	  is_non_secure_access inside {0,1};
          is_exclusive==1;
	  })

       load_tran.wait_end();

      `uvm_create(store_tran)
       store_tran.cfg = this.cfg;
       store_tran.cfg.exclusive_access_enable=1;
       store_tran.lpid   = load_tran.lpid;	
       `svt_xvm_do_with(store_tran,
          {
           addr					== load_tran.addr;
           xact_type			 	== svt_chi_rn_transaction::WRITENOSNPFULL; 
           data_size == svt_chi_rn_transaction::SIZE_64BYTE;
           mem_attr_is_cacheable inside {0,1} ;
	   is_non_secure_access inside {0,1};
           is_exclusive==1;
          })

       store_tran.wait_end();
  end

    if ($test$plusargs("non_snoopable_ptl_excl")) begin

      `uvm_create(load_tran)
      this.cfg.exclusive_access_enable=1;
      load_tran.cfg = this.cfg;
      load_tran.cfg.exclusive_access_enable=1;

       `svt_xvm_do_with(load_tran,
          {
          xact_type			 	== svt_chi_rn_transaction::READNOSNP; 
          data_size inside { svt_chi_rn_transaction::SIZE_1BYTE,svt_chi_rn_transaction::SIZE_2BYTE,svt_chi_rn_transaction::SIZE_4BYTE, svt_chi_rn_transaction::SIZE_8BYTE,
                             svt_chi_rn_transaction::SIZE_16BYTE,svt_chi_rn_transaction::SIZE_32BYTE, svt_chi_rn_transaction::SIZE_64BYTE};
          mem_attr_is_cacheable inside {0,1} ;
	  is_non_secure_access inside {0,1};
          is_exclusive==1;
	  })

       load_tran.wait_end();

      `uvm_create(store_tran)
       store_tran.cfg = this.cfg;
       store_tran.lpid   = load_tran.lpid;	
       store_tran.cfg.exclusive_access_enable=1;
       `svt_xvm_do_with(store_tran,
          {
           addr					== load_tran.addr;
           xact_type			 	== svt_chi_rn_transaction::WRITENOSNPPTL; 
           data_size inside { svt_chi_rn_transaction::SIZE_1BYTE,svt_chi_rn_transaction::SIZE_2BYTE,svt_chi_rn_transaction::SIZE_4BYTE, svt_chi_rn_transaction::SIZE_8BYTE,
                              svt_chi_rn_transaction::SIZE_16BYTE,svt_chi_rn_transaction::SIZE_32BYTE, svt_chi_rn_transaction::SIZE_64BYTE};
           mem_attr_is_cacheable inside {0,1} ;
	   is_non_secure_access inside {0,1};
           is_exclusive==1;
          })

       store_tran.wait_end();
  end

  if ($test$plusargs("snoopable_excl")) begin

      `uvm_create(load_tran)
      this.cfg.exclusive_access_enable=1;
      load_tran.cfg = this.cfg;
      load_tran.cfg.exclusive_access_enable=1;

       `svt_xvm_do_with(load_tran,
          {
          xact_type inside {svt_chi_transaction::READCLEAN,svt_chi_transaction::READSHARED,svt_chi_transaction::READNOTSHAREDDIRTY};
          data_size inside { svt_chi_rn_transaction::SIZE_1BYTE,svt_chi_rn_transaction::SIZE_2BYTE,svt_chi_rn_transaction::SIZE_4BYTE, svt_chi_rn_transaction::SIZE_8BYTE,
                             svt_chi_rn_transaction::SIZE_16BYTE,svt_chi_rn_transaction::SIZE_32BYTE, svt_chi_rn_transaction::SIZE_64BYTE};
          mem_attr_is_cacheable inside {0,1} ;
	  is_non_secure_access inside {0,1};
          snp_attr_is_snoopable == 1;
          is_exclusive==1;
	  })

       load_tran.wait_end();

      `uvm_create(store_tran)
       store_tran.cfg = this.cfg;
       store_tran.lpid   = load_tran.lpid;	
       store_tran.cfg.exclusive_access_enable=1;
       `svt_xvm_do_with(store_tran,
          {
           addr					== load_tran.addr;
           xact_type			 	== svt_chi_rn_transaction::CLEANUNIQUE; 
           data_size inside { svt_chi_rn_transaction::SIZE_1BYTE,svt_chi_rn_transaction::SIZE_2BYTE,svt_chi_rn_transaction::SIZE_4BYTE, svt_chi_rn_transaction::SIZE_8BYTE,
                              svt_chi_rn_transaction::SIZE_16BYTE,svt_chi_rn_transaction::SIZE_32BYTE, svt_chi_rn_transaction::SIZE_64BYTE};
           mem_attr_is_cacheable inside {0,1} ;
	   is_non_secure_access inside {0,1};
           snp_attr_is_snoopable == 1;
           is_exclusive==1;
          })

       store_tran.wait_end();
  end
 
  end

  `uvm_info("body", $sformatf("TEST Results"), UVM_NONE);

   `uvm_info("body", "Exiting...", UVM_LOW)
  endtask: body

endclass: cust_svt_chi_exclusive_seq
function cust_svt_chi_exclusive_seq::new(string name="cust_svt_chi_exclusive_seq");
  super.new(name);
  //Set the response depth to -1, to accept infinite number of responses
  this.set_response_queue_depth(-1);
endfunction
`endif // `ifdef CHI_UNITS_CNT_NON_ZERO

`endif // GUARD_SVT_AMBA_SEQ_LIB_SV

