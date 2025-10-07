`ifndef DMI_SEQ
`define DMI_SEQ
`include "<%=obj.BlockId%>_dmi_base_seq.svh"
////////////////////////////////////////////////////////////////////////////////
//
// DMI Master Sequence
//
////////////////////////////////////////////////////////////////////////////////
class dmi_seq extends dmi_base_seq;

  `uvm_object_utils(dmi_seq);
  `uvm_declare_p_sequencer(smi_virtual_sequencer);
   
  extern function new(string name = "dmi_seq");
  extern task body;
  extern task disable_body;

endclass : dmi_seq

function dmi_seq::new(string name = "dmi_seq");
  super.new(name);
endfunction : new
     
task dmi_seq::disable_body;
 	disable this.body;
endtask

task dmi_seq::body;
  aiu_id_queue_t aiu_queue_entry;
  int                 idx_sp_base;
  int                 idx_sp_max;
 
  smi_seq_item  req_item,req_item_2nd;
  smi_seq_item  req_rbid_item;
  smi_addr_t    cache_addr;

  int tmp_q[$];
  int tmp_q2[$];
  bit cmd_status;


  super.body();

  fork //Produce
    begin
      for (int k = 0; k < k_num_cmd; k++) begin // this causes vcs to hang
         clear_pending_rbs = 0;
         `uvm_info("txn_gen", $sformatf("Inside for loop for num_cmd=%0d (rbid_release_q=%0d)",k, rbid_release_q.size()),UVM_DEBUG)
  
         if($test$plusargs("address_error_test_wbuff") || $test$plusargs("k_addr_inject_pct_wbuff")) begin
            if(k == k_num_cmd -1)begin
               inject_err.trigger();
            end
         end
  
         if(single_step) wait_for_prev_txn();
  
         req_item = smi_seq_item::type_id::create("req_item");
  
         if (tb_delay==1) begin
           #2000ns; //seq_delay
         end
  
        //start_item(req_item); 
        `uvm_info("txn_gen", "Started item...",UVM_DEBUG);
        cmd_status = 0;
        do 
          begin
          if(((k_num_cmd-k)-1) == rbid_release_q.size())begin
            conclude_sending_rbrelease = 1;
          end
          if((k_num_cmd-k) == rbid_release_q.size())begin
            `uvm_info("txn_gen",$sformatf("Forcing all pending internal release(%0d) for end of test %0d", rbid_release_q.size(), k), UVM_LOW);
            cmd_msg_type = DTW_NO_DATA;
            clear_pending_rbs = 1;
          end
          else if(!bw_test)begin
            if($test$plusargs("enable_only_atomics")) begin
              chooseAtomicReqType();
            end
            else if(n_pending_txn_mode == 0) begin
               chooseReqType(k); // choose between MRD / HNT / DTW
            end
            else begin
               if(k < <%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries + obj.DmiInfo[obj.Id].nMrdSkidBufSize%> ) begin
                   chooseNextReqType(k);
               end
              else begin
                  chooseReqType(k);
               end
            end
          end 
          else begin
             //#Cov.DMI.v2.DtwDataDtyThroughput
             cmd_msg_type = DTW_DATA_DTY;
          end
          cmd_status = 1; 
          if(isDtw(cmd_msg_type) || isDtwMrgMrd(cmd_msg_type))begin
              cmd_status =  getcohrbid(req_item);
              if($test$plusargs("conc9307_test")) begin
                  while(!cmd_status) begin
                      cmd_status =  getcohrbid(req_item);
                      `uvm_info("delay_debug","RBID conc9307 delay",UVM_LOW);
                      #5ns; //seq_delay
                  end
              end //TODO consider a timeout instead of a timebased infinite loop
          end
          if(!cmd_status) begin
            `uvm_info("delay_debug","RBID regular delay",UVM_LOW);
            #5ns; //seq_delay
          end
        end  while(!cmd_status);
        
         `uvm_info("txn_gen", $sformatf("Message Type Chosen %0s(0x%0x)", m_cfg.smi_type_string(cmd_msg_type),cmd_msg_type),UVM_DEBUG)
  
         req_item.smi_msg_type  = cmd_msg_type;
         if(req_item.isCmdMsg())begin
           waitForNcSmimsgId();
           Nctxns_in_flight += 1;
         end
         else begin
           smi_txn_count += 1;
           if(isMrd(cmd_msg_type))begin
             waitForSmimsgId(); // check max MrdInFlight and wait if needed
           end
         end
         if(cmd_msg_type inside {DTW_DATA_PTL,DTW_MRG_MRD_UDTY})begin
          smi_mw = $urandom;
         end
         else begin
          smi_mw = 0;
         end
         buildPkt(req_item); // MRD / HNT / DTW
         setSmiPriv(req_item); // msg type + prot + ACE Fields in there if required
         ///////////////////////////////////////////////////////////////////////////////
         // Done setting packet thingys
         ///////////////////////////////////////////////////////////////////////////////
         addPktToInfoQueues(req_item);
         print_dtw_info_q();
         `uvm_info("txn_gen", "Ready to send item...",UVM_DEBUG)
         `uvm_info("txn_gen", $sformatf("Ready to send item...%p",req_item),UVM_DEBUG)
         `uvm_info("NKR - txn_gen", $sformatf("smi_qos_rand  : %0d", req_item.smi_qos), UVM_MEDIUM)
  
        case (cmd_msg_type)
          CMD_WR_NC_PTL,CMD_WR_NC_FULL,CMD_RD_NC,CMD_WR_ATM,CMD_RD_ATM,CMD_SW_ATM,CMD_CMP_ATM,CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF: begin
             m_smi_tx_cmd_req_q.push_back(req_item);
             ->e_smi_cmd_req_q;
          end
          MRD_RD_WITH_INV, MRD_FLUSH, MRD_CLN, MRD_INV,MRD_PREF: begin
             m_smi_tx_cmd_req_q.push_back(req_item);
             ->e_smi_cmd_req_q;
          end
          MRD_RD_WITH_SHR_CLN,MRD_RD_WITH_UNQ_CLN,MRD_RD_WITH_UNQ: begin
             m_smi_tx_cmd_req_q.push_back(req_item);
             ->e_smi_cmd_req_q;
          end
          DTW_MRG_MRD_UCLN,DTW_MRG_MRD_INV: begin
             req_rbid_item = smi_seq_item::type_id::create("req_rbid_item");
             buildrbpkt(req_rbid_item,req_item,1,0,0);
             m_smi_tx_dtw_req_q.push_back(req_item);
             m_smi_tx_rb_req_q.push_back(req_rbid_item);
             dtw_info[dtw_info.size()-1].RBRs_rmsg_id = req_rbid_item.smi_msg_id;
             dtw_info[dtw_info.size()-1].dce_id       = req_rbid_item.smi_src_ncore_unit_id;
             dtw_info[dtw_info.size()-1].dtws_expd = 1;
             ->e_smi_dtw_req_q;
             ->e_smi_rb_req_q;
           end
          DTW_NO_DATA,DTW_DATA_PTL,DTW_DATA_DTY,DTW_DATA_CLN,DTW_MRG_MRD_UDTY: begin
             req_rbid_item = smi_seq_item::type_id::create("req_rbid_item");
             buildrbpkt(req_rbid_item,req_item,1,smi_mw,0);
             smi_rbid = req_rbid_item.smi_rbid;
             smi_tm   = req_rbid_item.smi_tm;
             m_smi_tx_rb_req_q.push_back(req_rbid_item);
             dtw_info[dtw_info.size()-1].RBRs_rmsg_id = req_rbid_item.smi_msg_id;
             dtw_info[dtw_info.size()-1].dce_id       = req_rbid_item.smi_src_ncore_unit_id;
             smi_qos_rb = req_rbid_item.smi_qos;
             `uvm_info("SATYA:0",$sformatf("req_item :%p",req_item),UVM_DEBUG);
             ->e_smi_rb_req_q;
             if((!(k == k_num_cmd -1)) && ($urandom_range(1,100)  <= wt_rb_release.get_value()) && (cmd_msg_type != DTW_MRG_MRD_UDTY ) && !clear_pending_rbs && !conclude_sending_rbrelease) begin
              //The last transaction should not be a release, on a clear_pending_rbs flag force the sequence to process pending release
               `uvm_info("SATYA:1",$sformatf("req_item :%p",req_item),UVM_DEBUG); 
               rbid_release_q.push_back('{req_item.smi_rbid,req_item.smi_tm});
               dtw_info[dtw_info.size()-1].rb_rl_rsp_expd = 1; 
             end
             else begin
               `uvm_info("txn_gen", $sformatf("wt_dtw_intervention :%0d smi_mw :%0b ",wt_dtw_intervention.get_value(),req_rbid_item.smi_mw),UVM_DEBUG)
               if(req_rbid_item.smi_mw && ($urandom_range(1,99)  <= wt_dtw_intervention.get_value()))begin
                 req_item_2nd = smi_seq_item::type_id::create("req_item_2nd");
                 genDtwPktMW(req_item_2nd,smi_rbid);
                 req_item_2nd.smi_tm = smi_tm;
                 `uvm_info("SATYA:2",$sformatf("req_item_2nd :%p",req_item_2nd),UVM_DEBUG);
                 `uvm_info("SATYA:3",$sformatf("req_item_prim :%p",req_item),UVM_DEBUG);
                 dtw_info[dtw_info.size()-1].aiu_id_2nd     = req_item_2nd.smi_src_ncore_unit_id;
                 dtw_info[dtw_info.size()-1].smi_msg_id_2nd = req_item_2nd.smi_msg_id;
                 dtw_info[dtw_info.size()-1].isMW           = 1;
                 dtw_info[dtw_info.size()-1].dtws_expd      = 2;
                 m_smi_tx_dtw_req_q.push_back(req_item_2nd);
                 ->e_smi_dtw_req_q;
                 m_smi_tx_dtw_req_2nd_q.push_back(req_item);
                 //->e_smi_dtw_req_q;
                 aiu_txn_count++;
               end
               else begin
                 dtw_info[dtw_info.size()-1].dtws_expd = 1;
                 m_smi_tx_dtw_req_q.push_back(req_item);
                 ->e_smi_dtw_req_q;
               end
             end
          end
        endcase // case (cmd_msg_type)\
        // finish_item(req_item); // finish talking for this packet
        `uvm_info("txn_gen", $sformatf("Finished item... addr_cnt :%0d warmup_done :%0b",addr_cnt,warmup_done),UVM_DEBUG)
        addr_cnt++;
        <% if(obj.useCmc) { %>
        if((addr_cnt >  <%=obj.DmiInfo[obj.Id].ccpParams.nWays*obj.DmiInfo[obj.Id].ccpParams.nSets%>) && cache_warmup_flg && !warmup_done)begin
         warmup_done = 1;
         //#1000ns;
        end
        <% } %>
      end // for k
      `uvm_info("txn_gen", $sformatf("Finished sending all %0d commands",k_num_cmd), UVM_LOW)
    end
  join
  
  if(!uncorr_error_test && !uncorr_wrbuffer_err && !m_cfg.m_args.sram_uc_error_test && !m_cfg.m_args.k_ungate_wait_aiu_txn) begin
   `uvm_info("dmi_seq", $sformatf("Waiting for aiu_txn_count(%0d)==0",aiu_txn_count),UVM_MEDIUM)
    wait(!aiu_txn_count);
    if($test$plusargs("rbr_rsp_extreme_backpressure")) begin
      `uvm_info("dmi_seq", $sformatf("Waiting for all RBID to finish processing(%0d)==0",used_cohrbid_q.num()),UVM_MEDIUM)
      wait(used_cohrbid_q.num()==0);
    end
    //#100us; //seq_delay
  end
  else begin
    //#3000us; //seq_delay
  end
   `uvm_info("dmi_seq", $sformatf("Exiting dmi_seq DTW_q size:%0d RBreq:%0d CmdReq:%0d",m_smi_tx_dtw_req_q.size(), m_smi_tx_rb_req_q.size(),m_smi_tx_cmd_req_q.size()),UVM_MEDIUM)
endtask : body


////////////////////////////////////////////////////////////////////////////////

`endif // DMI_SEQ

