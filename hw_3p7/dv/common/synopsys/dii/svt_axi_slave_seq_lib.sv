
/**
 * Abstract:
 * Class axi_slave_mem_response_sequence defines a sequence class that
 * the testbench uses to provide slave response to the Slave agent present in
 * the System agent. The sequence receives a response object of type
 * svt_axi_slave_transaction from slave sequencer. The sequence class then
 * randomizes the response with constraints and provides it to the slave driver
 * within the slave agent. The sequence also instantiates the slave built-in
 * memory, and writes into or reads from the slave memory.
 *
 * Execution phase: main_phase
 * Sequencer: Slave agent sequencer
 */

`ifndef GUARD_SVT_AXI_SLAVE_SEQ_LIB_SV
`define GUARD_SVT_AXI_SLAVE_SEQ_LIB_SV

class axi_slave_mem_response_sequence extends svt_axi_slave_base_sequence;

  svt_axi_slave_transaction req_resp;


  int                          prob_ace_rd_resp_error = 0;
  int                          prob_ace_wr_resp_error = 0;
  int                          long_delay = 0;
  uvm_event                    item_randomize_done_e;
  int                          m_addr_ready_delay;
  int t_resp;
  svt_axi_slave_transaction::resp_type_enum resp_e;
  bit   user_delay_en = 0; // if user_delay_en is set to 1 delay is randomized using slave_X_chnl_delay_min and slave_X_chnl_delay_max else we use ZERO_DELAY_wt, SHORT_DELAY_wt, LONG_DELAY_wt for delay control
  int slave_write_addr_chnl_delay_min = 1 ; 
  int slave_write_addr_chnl_delay_max = 5 ;
  int slave_write_data_chnl_delay_min = 1 ;
  int slave_write_data_chnl_delay_max = 5 ; 
  int slave_write_resp_chnl_delay_min = 1 ;
  int slave_write_resp_chnl_delay_max = 5 ;
  int slave_read_addr_chnl_delay_min  = 1 ;
  int slave_read_addr_chnl_delay_max  = 5 ;
  int slave_read_data_chnl_delay_min  = 1 ;
  int slave_read_data_chnl_delay_max  = 5 ;

  int slave_write_addr_chnl_delay = 0;
  int slave_write_data_chnl_delay = 0;
  int slave_write_resp_chnl_delay = 0;
  int slave_read_addr_chnl_delay  = 0;
  int slave_read_data_chnl_delay  = 0;
     /**
     * @groupname axi3_4_delays
     * Weight used to control distribution of zero delay within transaction generation.
     *
     * This controls the distribution of delays for the 'delay' fields 
     * (e.g., delays for asserting the ready signals).
     */
  int ZERO_DELAY_wt = 50;

   /**
     * @groupname axi3_4_delays
     * Weight used to control distribution of short delays within transaction generation.
     *
     * This controls the distribution of delays for the 'delay' fields 
     * (e.g., delays for asserting the ready signals).
     */
  int SHORT_DELAY_wt = 40;

  /**
    * @groupname axi3_4_delays
    * Weight used to control distribution of long delays within transaction generation.
    *
    * This controls the distribution of delays for the 'delay' fields 
    * (e.g., delays for asserting the ready signals).
    */
  int LONG_DELAY_wt = 10; //default 1 in svt_axi_slave_transaction
  //int LONG_DELAY_wt = 100; //default 1 in svt_axi_slave_transaction

  // Randomization logic in svt_axi_slave_transaction
  //0 := ZERO_DELAY_wt, 
  //[1:(`SVT_AXI_MAX_ADDR_VALID_DELAY >> 2)] :/ SHORT_DELAY_wt,
  //[((`SVT_AXI_MAX_ADDR_VALID_DELAY >> 2)+1):`SVT_AXI_MAX_ADDR_VALID_DELAY] :/ LONG_DELAY_wt

  /** UVM Object Utility macro */
  `uvm_object_utils(axi_slave_mem_response_sequence)

  /** Class Constructor */
  function new(string name="axi_slave_mem_response_sequence");
    super.new(name);
    item_randomize_done_e = new();
  endfunction

  virtual task body();
    integer status;
    svt_configuration get_cfg;

    `uvm_info("axi_slave_mem_response_sequence-body", "Entered ...", UVM_LOW)  
    `uvm_info("axi_slave_mem_response_sequence-body", $psprintf("prob_ace_rd_resp_error = %0d", prob_ace_rd_resp_error), UVM_NONE)
    `uvm_info("axi_slave_mem_response_sequence-body", $psprintf("prob_ace_wr_resp_error = %0d", prob_ace_wr_resp_error), UVM_NONE)

    set_plusargs();

    /** Refernce axi_slave_mem to slave agent's memori. */
    instantiate_axi_slave_mem();

    axi_slave_mem.meminit = svt_mem::RANDOM;

    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("axi_slave_mem_response_sequence-body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end

    // consumes responses sent by driver
    sink_responses();
     `uvm_info("axi_slave_mem_response_sequence-body", $psprintf("Printing Delay values ZERO_DELAY_wt = %0d SHORT_DELAY_wt=%0d LONG_DELAY_wt =%0d",ZERO_DELAY_wt,SHORT_DELAY_wt,LONG_DELAY_wt), UVM_NONE)
     `uvm_info("axi_slave_mem_response_sequence-body", $psprintf("Printing user_delay_en = %d",user_delay_en), UVM_NONE)    
    
    forever begin
      /**
       * Get the response request from the slave sequencer. The response request is
       * provided to the slave sequencer by the slave port monitor, through
       * TLM port.
       */
      p_sequencer.response_request_port.peek(req_resp);

      if ($urandom_range(0,100) < (prob_ace_rd_resp_error + prob_ace_wr_resp_error)) begin
          t_resp = $urandom_range(2,3); // SLVERR:2 DECERR:3
          `uvm_info("axi_slave_mem_response_sequence-body", $psprintf("Setting ERROR %0s Resp",(t_resp==2)?"SLVERR":"DECERR"), UVM_NONE)
      end else begin
          if(req_resp.bresp==svt_axi_slave_transaction::EXOKAY)t_resp = 1;
          else t_resp = 0; // OKAY:0 
          `uvm_info("axi_slave_mem_response_sequence-body", $psprintf("Setting OKAY Resp t_resp %0d bresp %0d",t_resp,req_resp.bresp), UVM_NONE)
      end

      if(t_resp==0) resp_e = svt_axi_slave_transaction::OKAY;
      else if(t_resp==1) resp_e = svt_axi_slave_transaction::EXOKAY;
      else if(t_resp==2) resp_e = svt_axi_slave_transaction::SLVERR;
      else if(t_resp==3) resp_e = svt_axi_slave_transaction::DECERR;
      /**
       * Randomize the response and delays
       */
      if (user_delay_en) begin
      
         slave_write_addr_chnl_delay = $urandom_range(slave_write_addr_chnl_delay_min,slave_write_addr_chnl_delay_max);
         slave_write_data_chnl_delay = $urandom_range(slave_write_data_chnl_delay_min,slave_write_data_chnl_delay_max);
         slave_write_resp_chnl_delay = $urandom_range(slave_write_resp_chnl_delay_min,slave_write_resp_chnl_delay_max);
         slave_read_addr_chnl_delay  = $urandom_range(slave_read_addr_chnl_delay_min,slave_read_addr_chnl_delay_max);
         slave_read_data_chnl_delay  = $urandom_range(slave_read_data_chnl_delay_min,slave_read_data_chnl_delay_max);
         
      end


      if(long_delay) m_addr_ready_delay = $urandom_range(100,200);
      
      status=req_resp.randomize with {        

        foreach (rresp[index])  {
           rresp[index] == bresp;
        }
      };
       if(!status)
        `uvm_fatal("axi_slave_mem_response_sequence-body","Unable to randomize a response")
       else begin
        // addr_ready_delay = req_resp.addr_ready_delay;
         item_randomize_done_e.trigger();
         `uvm_info("axi_slave_mem_response_sequence-body","Randomization successful",UVM_NONE)
         
       end

        req_resp.bresp = resp_e;
        //if(long_delay) addr_ready_delay == m_addr_ready_delay ;
        foreach (req_resp.rresp[index])  begin
           req_resp.rresp[index] = resp_e;
        end
       req_resp.ZERO_DELAY_wt  = ZERO_DELAY_wt;
       req_resp.SHORT_DELAY_wt = SHORT_DELAY_wt;
       req_resp.LONG_DELAY_wt  = LONG_DELAY_wt;

       if (user_delay_en) begin
          if (req_resp.xact_type == svt_axi_slave_transaction::WRITE) begin
            req_resp.addr_ready_delay = slave_write_addr_chnl_delay;
          end
          if (req_resp.xact_type == svt_axi_slave_transaction::READ) begin
            req_resp.addr_ready_delay = slave_read_addr_chnl_delay;
          
          end  

          foreach(req_resp.wready_delay[i]) begin
            req_resp.wready_delay[i] = slave_write_data_chnl_delay;
          end
          if (req_resp.xact_type == svt_axi_slave_transaction::WRITE) begin
            req_resp.bvalid_delay = slave_write_resp_chnl_delay;
          end
          if (req_resp.xact_type == svt_axi_slave_transaction::READ)  begin
            foreach(req_resp.rvalid_delay[k]) begin
              req_resp.rvalid_delay[k] = slave_read_data_chnl_delay;
            end
          end
        end
        req_resp.print();
      /**
       * If write transaction, write data into slave built-in memory, else get
       * data from slave built-in memory
       */
      if(req_resp.get_transmitted_channel() == svt_axi_slave_transaction::WRITE) begin
        `protect      
        put_write_transaction_data_to_mem(req_resp);
        `endprotect
      end
      else if (req_resp.get_transmitted_channel() == svt_axi_slave_transaction::READ) begin
        `protect
        get_read_data_from_mem_to_transaction(req_resp);
        `endprotect
      end
    
      $cast(req,req_resp);

      /**
       * send to driver
       */
      `uvm_send(req)

    end

    `uvm_info("axi_slave_mem_response_sequence-body", "Exiting...", UVM_LOW)
  endtask: body

  function set_plusargs();
    if($value$plusargs("SYNPS_AXI_SLV_ZERO_DELAY_wt=%0d",ZERO_DELAY_wt)) begin
       `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting ZERO_DELAY_wt %0d",ZERO_DELAY_wt),UVM_NONE)
    end
    if($value$plusargs("SYNPS_AXI_SLV_SHORT_DELAY_wt=%0d",SHORT_DELAY_wt)) begin
       `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting SHORT_DELAY_wt %0d",SHORT_DELAY_wt),UVM_NONE)
    end
    if($value$plusargs("SYNPS_AXI_SLV_LONG_DELAY_wt=%0d",LONG_DELAY_wt)) begin
       `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting LONG_DELAY_wt %0d",LONG_DELAY_wt),UVM_NONE)
    end
    if($test$plusargs("random_resp_en")) begin
     prob_ace_rd_resp_error = 20;
     prob_ace_wr_resp_error = 20;
       `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting random_resp_en"),UVM_NONE)
    end
    if($test$plusargs("long_delay_en")) begin
       long_delay=1;
       LONG_DELAY_wt = 100; 
    end

  if($value$plusargs("synps_axi_slave_write_addr_chnl_delay_min=%0d",slave_write_addr_chnl_delay_min)) begin
      `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting slave_write_addr_chnl_delay_min %0d",slave_write_addr_chnl_delay_min),UVM_LOW)
   end
   if($value$plusargs("synps_axi_slave_write_addr_chnl_delay_max=%0d",slave_write_addr_chnl_delay_max)) begin
      `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting slave_write_addr_chnl_delay_max %0d",slave_write_addr_chnl_delay_max),UVM_LOW)
   end
   if($value$plusargs("synps_axi_slave_write_data_chnl_delay_min=%0d",slave_write_data_chnl_delay_min)) begin
    `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting slave_write_data_chnl_delay_min %0d",slave_write_data_chnl_delay_min),UVM_LOW)
   end
    if($value$plusargs("synps_axi_slave_write_data_chnl_delay_max=%0d",slave_write_data_chnl_delay_max)) begin
    `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting slave_write_data_chnl_delay_max %0d",slave_write_data_chnl_delay_max),UVM_LOW)
    end
    if($value$plusargs("synps_axi_slave_read_addr_chnl_delay_min=%0d",slave_read_addr_chnl_delay_min)) begin
      `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting slave_read_addr_chnl_delay_min %0d",slave_read_addr_chnl_delay_min),UVM_LOW)
   end
   if($value$plusargs("synps_axi_slave_read_addr_chnl_delay_max=%0d",slave_read_addr_chnl_delay_max)) begin
      `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting slave_read_addr_chnl_delay_max %0d",slave_read_addr_chnl_delay_max),UVM_LOW)
   end
   if($value$plusargs("synps_axi_slave_read_data_chnl_delay_min=%0d",slave_read_data_chnl_delay_min)) begin
    `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting slave_write_data_chnl_delay_min %0d",slave_read_data_chnl_delay_min),UVM_LOW)
   end
    if($value$plusargs("synps_axi_slave_read_data_chnl_delay_max=%0d",slave_read_data_chnl_delay_max)) begin
    `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting slave_read_data_chnl_delay_max %0d",slave_read_data_chnl_delay_max),UVM_LOW)
    end

    if($value$plusargs("synps_axi_slave_write_resp_chnl_delay_min=%0d",slave_write_resp_chnl_delay_min)) begin
      `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting slave_write_resp_chnl_delay_min %0d",slave_write_resp_chnl_delay_min),UVM_LOW)
     end
    if($value$plusargs("synps_axi_slave_write_resp_chnl_delay_max=%0d",slave_write_resp_chnl_delay_max)) begin
      `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting slave_read_data_chnl_delay_max %0d",slave_write_resp_chnl_delay_max),UVM_LOW)
    end
    if($test$plusargs("user_delay_en")) begin
      user_delay_en=1;
   end

  endfunction

endclass: axi_slave_mem_response_sequence

`endif // GUARD_SVT_AXI_SLAVE_SEQ_LIB_SV
