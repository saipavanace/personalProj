class ncore_svt_chi_rn_directed_snoop_resp_seq extends svt_chi_snoop_transaction_base_sequence;

  bit is_performance_test;

  svt_chi_rn_snoop_transaction req_resp;
  svt_chi_node_configuration cfg;
  `svt_xvm_object_utils(ncore_svt_chi_rn_directed_snoop_resp_seq)
  
  function new(string name="ncore_svt_chi_rn_directed_snoop_resp_seq");
    super.new(name);
	if ($test$plusargs("performance_test")) begin
		is_performance_test = 1;
	end
  endfunction

virtual task body();
  `svt_xvm_debug("body", "Entering...");

  if (p_sequencer == null) begin
    `svt_fatal("body", "The svt_chi_rn_snoop_response_sequence sequence was not started on a sequencer");
    return;
  end
  
  get_rn_virt_seqr();

  forever begin
    bit[`SVT_CHI_MAX_TAGGED_ADDR_WIDTH-1:0] aligned_addr;
    bit is_unique, is_clean, read_status;
    longint index,age;
    bit[7:0] data[];
    bit byte_enable[];
    `ifdef SVT_CHI_ISSUE_B_ENABLE  
       bit snp_cache_poison[];
       bit snp_cache_fwded_poison[];
       string snp_cache_fwded_poison_str = "";
       bit fwded_poison_rcvd_flag;
    `endif   
    data = new[`SVT_CHI_CACHE_LINE_SIZE];
    byte_enable = new[`SVT_CHI_CACHE_LINE_SIZE];
    
    wait_for_snoop_request(req);
    aligned_addr = req.cacheline_addr(1);
    if (!rn_cfg.disable_rn_cache) begin
      if(rn_cfg.chi_interface_type == svt_chi_node_configuration::RN_F)  
        read_status = rn_cache.read_line_by_addr(aligned_addr,index,data,byte_enable,is_unique,is_clean,age);

      if($size(req.byte_enable) && byte_enable.size())begin
        for (int j=0; j<`SVT_CHI_CACHE_LINE_SIZE; j++) begin
          req.byte_enable[j] = byte_enable[j];
        end
      end
    end else begin
      populate_initial_state_and_data_fields_for_snoop(req);
    end

    void'(req.randomize() with {
      if(req.snp_req_msg_type == svt_chi_snoop_transaction::SNPONCE && read_status==1){
        if({is_unique,is_clean} == 2'b11){
		  if(is_performance_test) {
			snp_rsp_isshared == 1;
			snp_rsp_datatransfer == 1;
			resp_pass_dirty == 0;
		  }
		}
      }		
	}); 

    if(!rn_cfg.disable_rn_cache) begin
      if (req.snp_rsp_datatransfer) begin
         for (int j=0; j<`SVT_CHI_CACHE_LINE_SIZE; j++) begin
           // If clean, then all bytes are valid, if dirty it can be
           // that only some bytes are valid (ie, UDP state)
           if (!is_clean) begin
             req.byte_enable[j] = byte_enable[j];
             `ifdef SVT_CHI_ISSUE_B_ENABLE
               if(byte_enable[j] == 0)
                 req.data[8*j+:8] = 0;
               else
             `endif
               req.data[8*j+:8] = data[j];
           end else begin
             req.byte_enable[j] = 1'b1;
             req.data[8*j+:8] = data[j];
           end
         end
         `ifdef SVT_CHI_ISSUE_E_ENABLE
           if (rn_cfg.chi_interface_type == svt_chi_node_configuration::RN_F && rn_cfg.mem_tagging_enable) begin
             if(read_status)begin
               if(req.data_tag_op == svt_chi_snoop_transaction::TAG_TRANSFER || req.data_tag_op == svt_chi_snoop_transaction::TAG_UPDATE) begin
                 bit[(`SVT_CHI_NUM_BITS_IN_TAG - 1):0] cache_tag[];
                 bit cache_tag_update[];
                 bit is_tag_invalid, is_tag_clean;
                 string tag_str;
                 void'(rn_cache.get_tag(aligned_addr, cache_tag, cache_tag_update, is_tag_invalid, is_tag_clean, tag_str));
                 if(is_tag_invalid == 0) begin
                   for (int j=0; j<`SVT_CHI_CACHE_LINE_SIZE/16; j++) begin
                     req.tag[j*`SVT_CHI_CACHE_LINE_SIZE/16 +: `SVT_CHI_NUM_BITS_IN_TAG] = cache_tag[j];
                   end
                   
                   if(req.data_tag_op == svt_chi_snoop_transaction::TAG_UPDATE) begin
                     for (int j=0; j<`SVT_CHI_CACHE_LINE_SIZE/16; j++) begin
                       req.tag_update[j] = cache_tag_update[j];
                     end
                   end else begin
                     req.tag_update = 0;
                   end
                 end else begin
                   req.tag = 0;
                   req.tag_update = 0;
                 end
               end
             end
           end
         `endif  

         `ifdef SVT_CHI_ISSUE_F_ENABLE
           if (rn_cfg.chi_interface_type == svt_chi_node_configuration::RN_F) begin
             if(read_status)begin
               if(rn_cfg.pbha_support == svt_chi_node_configuration::CHI_PBHA_SUPPORT_TRUE)begin
                 bit[(`SVT_CHI_PBHA_WIDTH - 1):0] cache_pbha;
                 if(rn_cache.is_pbha_enabled())begin
                   void'(rn_cache.get_pbha(aligned_addr,cache_pbha));
                   `svt_debug("svt_chi_rn_snoop_response_sequence",{`SVT_CHI_SNP_PRINT_PREFIX(req), $sformatf("Address =%0h holds a PBHA value %0d  ", aligned_addr, cache_pbha)});
                   if ((req.snp_req_msg_type == svt_chi_snoop_transaction::SNPSTASHSHARED || req.snp_req_msg_type == svt_chi_snoop_transaction::SNPSTASHUNIQUE || 
                        req.snp_req_msg_type == svt_chi_snoop_transaction::SNPUNIQUESTASH || req.snp_req_msg_type == svt_chi_snoop_transaction::SNPMAKEINVALIDSTASH)) begin
                     if (cache_pbha != req.pbha) begin
                      `svt_debug("svt_chi_rn_snoop_response_sequence",{`SVT_CHI_SNP_PRINT_PREFIX(req), $sformatf("RN cache Address =%0h holds a PBHA value %0d.  PBHA attribute in the cache is different from the pbha value in the request. PBHA in cache %0d, PBHA in the request %0d. PBHA value in the snp request will be sent in the snp resp data instead of PBHA value in the cache.", aligned_addr, cache_pbha, cache_pbha, req.pbha)});
                     end
                   end
                   else begin
                     req.pbha = cache_pbha;
                   end
                 end
               end
               //CAH
               if(rn_cfg.cah_support == svt_chi_node_configuration::CHI_CAH_SUPPORT_TRUE)begin
                 bit cache_cah;
                 if(rn_cache.is_cah_enabled())begin
                   void'(rn_cache.get_cah(aligned_addr,cache_cah));
                   `svt_debug("svt_chi_rn_snoop_response_sequence",{`SVT_CHI_SNP_PRINT_PREFIX(req), $sformatf("Address = %0h holds a cah value 'b%0b, populating the same in snoop_xact.cah", aligned_addr, cache_cah)});
                   req.cah = cache_cah;
                 end
               end
             end
           end
         `endif

         `ifdef SVT_CHI_ISSUE_B_ENABLE  
           if (rn_cfg.chi_interface_type == svt_chi_node_configuration::RN_F) begin
             if(read_status)begin
               bit snp_cache_datacheck[];
               string snp_cache_poison_str = "";
               string snp_cache_datacheck_str = "";
               bit poison_rcvd_flag;
               bit datacheck_rcvd_flag;

               /** Poison **/
               if(`SVT_CHI_POISON_INTERNAL_WIDTH_ENABLE == 1 && rn_cfg.poison_enable == 1)begin      
                 snp_cache_poison = new[`SVT_CHI_CACHE_LINE_SIZE/8];
                 if(!rn_cache.is_poison_enabled())begin
                   `svt_xvm_debug("body", {`SVT_CHI_SNP_PRINT_PREFIX(req), $sformatf("poison is not enabled in the cache. Calling set_poison_enable method of the cache ")});        
                   rn_cache.set_poison_enable(1);
                 end
                 if(rn_cache.is_poison_enabled())begin
                   poison_rcvd_flag = rn_cache.get_poison(aligned_addr,snp_cache_poison,snp_cache_poison_str);
                   `svt_debug("svt_chi_rn_snoop_response_sequence",{`SVT_CHI_SNP_PRINT_PREFIX(req), $sformatf("Address =%0h holds a poisned data with snp_cache_poison_str = %0s  ", aligned_addr, snp_cache_poison_str)});
                   for (int j=0; j<`SVT_CHI_CACHE_LINE_SIZE/8; j++) begin
                     req.poison[j] = snp_cache_poison[j];
                   end 
                 end 
               end  
             end
           end
         `endif  
      end

      `ifdef SVT_CHI_ISSUE_B_ENABLE
      if(req.is_dct_used) begin
         for (int j=0; j<`SVT_CHI_CACHE_LINE_SIZE; j++) begin
           req.fwded_compdata[8*j+:8] = data[j];
         end
         /** Poison **/
         if(`SVT_CHI_POISON_INTERNAL_WIDTH_ENABLE == 1 && rn_cfg.poison_enable == 1)begin   
           snp_cache_fwded_poison = new[`SVT_CHI_CACHE_LINE_SIZE/8];
           if(!rn_cache.is_poison_enabled())begin
             `svt_xvm_debug("body", {`SVT_CHI_SNP_PRINT_PREFIX(req), $sformatf("poison is not enabled in the cache. Calling set_poison_enable method of the cache ")});        
             rn_cache.set_poison_enable(1);
           end
           if(rn_cache.is_poison_enabled())begin
             fwded_poison_rcvd_flag = rn_cache.get_poison(aligned_addr,snp_cache_fwded_poison,snp_cache_fwded_poison_str);
             for (int j=0; j<`SVT_CHI_CACHE_LINE_SIZE/8; j++) begin
               req.poison[j] = snp_cache_fwded_poison[j];
             end
           end
         end
         `ifdef SVT_CHI_ISSUE_E_ENABLE
           if(req.cfg.mem_tagging_enable && req.fwded_tag_op != svt_chi_snoop_transaction::TAG_INVALID) begin
             bit[(`SVT_CHI_NUM_BITS_IN_TAG - 1):0] cache_tag[];
             bit cache_tag_update[];
             bit is_tag_invalid, is_tag_clean;
             string tag_str;
             void'(rn_cache.get_tag(aligned_addr, cache_tag, cache_tag_update, is_tag_invalid, is_tag_clean, tag_str));
             for (int j=0; j<`SVT_CHI_CACHE_LINE_SIZE/16; j++) begin
               req.fwded_tag[j*`SVT_CHI_CACHE_LINE_SIZE/16 +: `SVT_CHI_NUM_BITS_IN_TAG] = cache_tag[j];
             end
           end
         `endif
         `ifdef SVT_CHI_ISSUE_F_ENABLE
           if (rn_cfg.chi_interface_type == svt_chi_node_configuration::RN_F) begin
             if(read_status && !req.snp_rsp_datatransfer)begin
               //CAH
               if(rn_cfg.cah_support == svt_chi_node_configuration::CHI_CAH_SUPPORT_TRUE)begin
                 bit cache_cah;
                 if(rn_cache.is_cah_enabled())begin
                   void'(rn_cache.get_cah(aligned_addr,cache_cah));
                   `svt_debug("svt_chi_rn_snoop_response_sequence",{`SVT_CHI_SNP_PRINT_PREFIX(req), $sformatf("Address = %0h holds a cah value 'b%0b, populating the same in snoop_xact.cah", aligned_addr, cache_cah)});
                   req.cah = cache_cah;
                 end
               end
             end
           end
         `endif
      end
      `endif
    end
    
    begin
      string rsp_details, data_details;
      rsp_details = $sformatf("Response: isshared = %0b. datatransfer = %0b. passdirty = %0b. ", req.snp_rsp_isshared, req.snp_rsp_datatransfer, req.resp_pass_dirty);
      data_details = req.snp_rsp_datatransfer?"":$sformatf("data = 'h%0h. dat_rsvdc.size = %0d", req.data, req.dat_rsvdc.size());
      `svt_xvm_debug("body", {`SVT_CHI_SNP_PRINT_PREFIX(req), rsp_details, data_details});        
    end
    
    `svt_xvm_send(req)
  end

  `svt_xvm_debug("body", "Exiting...")
endtask: body

task populate_initial_state_and_data_fields_for_snoop(svt_chi_rn_snoop_transaction req);
  `svt_xvm_debug("populate_initial_state_and_data_fields_for_snoop", $sformatf("Default method implementation executed. The Snoop transaction fields will be set to default values"));
endtask

endclass: ncore_svt_chi_rn_directed_snoop_resp_seq
