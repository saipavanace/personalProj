class chi_subsys_directed_snp_resp_seq extends svt_chi_snoop_transaction_base_sequence;
  /* Response request from the RN snoop sequencer */
  svt_chi_rn_snoop_transaction req_resp;

  /* Handle to RN configuration object obtained from the sequencer */
  svt_chi_node_configuration cfg;
 int chi_snp_rsp_data_err;
 int chi_snp_rsp_non_data_err;

  /** UVM Object Utility macro */
  `svt_xvm_object_utils(chi_subsys_directed_snp_resp_seq)
  
  /** Class Constructor */
  function new(string name="chi_subsys_directed_snp_resp_seq");
    super.new(name);
    
  endfunction

  virtual task body();
    `svt_xvm_debug("body", "chi_subsys_directed_snp_resp_seq Entered ...");

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

endclass: chi_subsys_directed_snp_resp_seq