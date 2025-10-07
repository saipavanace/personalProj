`ifndef DMI_RB_SEQ
`define DMI_RB_SEQ
`include "<%=obj.BlockId%>_dmi_base_seq.svh"

<%  var ch_rbid  = 0;
    var NcH_rbid = 0;
    var nDce     = 0;
        ch_rbid  = obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries; 
        Nch_rbid = obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries; 
        nDce     = obj.DceInfo.length;

%>
class dmi_rb_seq extends dmi_base_seq;
  rand smi_rbid_t rbid_q[$];
  smi_seq_item smi_dtw_txn_q[$], smi_rb_req_txn_q[$];
  
  `uvm_object_utils(dmi_rb_seq);
  `uvm_declare_p_sequencer(smi_virtual_sequencer);

  extern function new(string name = "dmi_rb_seq");
  extern task body;
  extern task populateQs(bit[1:0] _type, input bit flip_gid_in_rbid = 0, input int max_rbs= <%=ch_rbid%>, input bit dispatch_to_rb_arbiter = 0 , input bit dispatch_to_dtw_arbiter = 0, input bit randomize_rbs = 1, input bit skip_rbid_assignment=0, input do_not_generate_dtw = 0);
  extern task dispatchRbReq();
  extern task dispatchDtwReq();

endclass: dmi_rb_seq

function dmi_rb_seq::new(string name = "dmi_rb_seq");
   super.new(name);
endfunction : new

task dmi_rb_seq::body();
  super.body();

  fork begin
    if($test$plusargs("shuffle_rb_seq")) begin
      int switch;
     // randcase
      $value$plusargs("seq_scenario=%d",switch);
    case(switch)
       0:
        begin
          SMImsgIDTableEntry_t tmp_smi_table[$];
          `uvm_info("saturate_rbs_b2b","Choosing Scenario FillRB-GID[0] ->  1/2-DTW GID[0] -> FillRB-GID[1] -> Internal Release RB-GID[0]", UVM_LOW)
          k_num_cmd = (<%=ch_rbid%>*3);
          rb_release_scenario = 1;
          populateQs(1);
          dispatchRbReq();
          dispatchDtwReq();
          wait(m_scb.numRbrsReq == <%=ch_rbid%>);
          wait(m_scb.numDtwTxns == <%=ch_rbid%>);
          wait(numRbRsp == <%=ch_rbid%>);
          `uvm_info("saturate_rbs_b2b",$sformatf("RBRsp received:%0d ", numRbRsp),UVM_LOW)
          `uvm_info("saturate_rbs_b2b",$sformatf("Waiting on DTWRsp completion Expected:%0d Current:%0d ", <%=ch_rbid%>, numDtwRsp),UVM_LOW)
          wait(numDtwRsp == <%=ch_rbid%>);
          `uvm_info("saturate_rbs_b2b",$sformatf("All DTWRsp received:%0d ", numDtwRsp),UVM_LOW)
          `uvm_info("saturate_rbs_b2b",$sformatf("SMI Table Size:%0d ", smi_table.size()),UVM_LOW)
          populateQs(0,1);
          dispatchRbReq();
          wait(m_scb.numRbrsReq == <%=ch_rbid%>*2);
          `uvm_info("saturate_rbs_b2b",$sformatf("SMI Table Size:%0d ", smi_table.size()),UVM_LOW)
          `uvm_info("saturate_rbs_b2b",$sformatf("RBRsp received:%0d ", numRbRsp),UVM_LOW)
          tmp_smi_table = smi_table;
          smi_table.delete();
          populateQs(0,0);
          foreach(tmp_smi_table[i]) begin
            smi_table.push_front(tmp_smi_table[i]);
          end
          dispatchRbReq();
          `uvm_info("saturate_rbs_b2b",$sformatf("Waiting on RBRsp completion Expected:%0d Current:%0d ", <%=ch_rbid%>*2, numRbRsp),UVM_LOW)
          wait(numRbRsp == <%=ch_rbid%>*2);
          `uvm_info("saturate_rbs_b2b",$sformatf("All RBRsp received:%0d ", numRbRsp),UVM_LOW)
        end
       1:
        begin
          SMImsgIDTableEntry_t tmp_smi_table[$];
          `uvm_info("saturate_rbs_b2b","Choosing Scenario FillRB-GID[0] -> Internal Release RB-GID[1]->  1-DTW GID[1] -> Release Back-pressure ", UVM_LOW)
          k_num_cmd = (<%=ch_rbid%>*2);
          populateQs(0);
          dispatchRbReq();
          wait(m_scb.numRbrsReq == <%=ch_rbid%>);
          `uvm_info("saturate_rbs_b2b",$sformatf("Received RbReqs in scb %0d==%0d ", m_scb.numRbrsReq, <%=ch_rbid%>),UVM_LOW)
          tmp_smi_table = smi_table;
          smi_table.delete();
          populateQs(1,1);
          foreach(tmp_smi_table[i]) begin
            smi_table.push_front(tmp_smi_table[i]);
          end
          dispatchRbReq();
          dispatchDtwReq();
          `uvm_info("saturate_rbs_b2b",$sformatf("Waiting on RBRsp completion Expected:%0d Current:%0d ", <%=ch_rbid%>*2, numRbRsp),UVM_LOW)
          wait(numRbRsp == <%=ch_rbid%>*2);
          `uvm_info("saturate_rbs_b2b",$sformatf("All RBRsp received:%0d ", numRbRsp),UVM_LOW)

          `uvm_info("saturate_rbs_b2b",$sformatf("Waiting on DTWRsp completion Expected:%0d Current:%0d ", <%=ch_rbid%>*2, numDtwRsp),UVM_LOW)
          wait(numDtwRsp == <%=ch_rbid%>);
          `uvm_info("saturate_rbs_b2b",$sformatf("All DTWRsp received:%0d ", numDtwRsp),UVM_LOW)
        end
       2:
        begin
          SMImsgIDTableEntry_t tmp_smi_table[$];
          `uvm_info("saturate_rbs_b2b","Choosing Scenario FillRB-GID[0] -> Internal Release RB-GID[1]->  2-DTW GID[1] -> Release Back-pressure ", UVM_LOW)
          k_num_cmd = (<%=ch_rbid%>);
          populateQs(0,0,<%=ch_rbid%>/2);
          dispatchRbReq();
          `uvm_info("saturate_rbs_b2b",$sformatf("Waiting for Rb req in scb %0d==%0d ", m_scb.numRbrsReq, <%=ch_rbid%>/2),UVM_LOW)
          wait(m_scb.numRbrsReq == <%=ch_rbid%>/2);
          `uvm_info("saturate_rbs_b2b",$sformatf("Received RbReqs in scb %0d==%0d ", m_scb.numRbrsReq, <%=ch_rbid%>/2),UVM_LOW)
          tmp_smi_table = smi_table;
          smi_table.delete();
          populateQs(2,1,<%=ch_rbid%>/2,0,0,0);
          foreach(tmp_smi_table[i]) begin
            smi_table.push_front(tmp_smi_table[i]);
          end
          dispatchDtwReq();
          dispatchRbReq();
          wait(m_scb.numRbrlReq == (<%=ch_rbid%>/2));
          `uvm_info("saturate_rbs_b2b",$sformatf("Waiting on RBRsp completion Expected:%0d Current:%0d ", <%=ch_rbid%>/2, numRbRsp),UVM_LOW)
          wait(numRbRsp == <%=ch_rbid%>);
          `uvm_info("saturate_rbs_b2b",$sformatf("All RBRsp received:%0d ", numRbRsp),UVM_LOW)

          `uvm_info("saturate_rbs_b2b",$sformatf("Waiting on DTWRsp completion Expected:%0d Current:%0d ", <%=ch_rbid%>, numDtwRsp),UVM_LOW)
          wait(numDtwRsp == <%=ch_rbid%>);
          `uvm_info("saturate_rbs_b2b",$sformatf("All DTWRsp received:%0d ", numDtwRsp),UVM_LOW)
        end
       3:
        begin
          SMImsgIDTableEntry_t tmp_smi_table[$];
          bit tmp_aiu_table [aiu_id_queue_t];
          smi_seq_item tmp_smi_rb_req_q[$];
          `uvm_info("saturate_rbs_b2b","Choosing Scenario FillRB-GID[0] -> 1-DTW GID[1]-> Internal Release+Fill RB-GID[1] -> Release Back-pressure ", UVM_LOW)
          k_num_cmd = ((<%=ch_rbid%>)*2);
          rb_release_scenario = 1;
          populateQs(0);
          dispatchRbReq();
          //Clear unused AIU IDs
          `uvm_info("saturate_rbs_b2b",$sformatf("Current AIU Table Size==%0d ", aiu_table.size()),UVM_DEBUG)
          `uvm_info("saturate_rbs_b2b",$sformatf("Received RbReqs in scb %0d==%0d ", m_scb.numRbrsReq, <%=ch_rbid%>),UVM_LOW)
          wait(m_scb.numRbrsReq == <%=ch_rbid%>);
          tmp_smi_table = smi_table;
          smi_table.delete();
          `uvm_info("saturate_rbs_b2b",$sformatf("Received RbReqs in scb %0d==%0d ", m_scb.numRbrsReq, <%=ch_rbid%>),UVM_LOW)
          populateQs(1,1);
          dispatchDtwReq();
          foreach(tmp_smi_table[i]) begin
            smi_table.push_front(tmp_smi_table[i]);
          end
          dispatchRbReq();
          wait(m_scb.numRbrlReq == <%=ch_rbid%>);
          `uvm_info("saturate_rbs_b2b",$sformatf("Waiting on RBRsp completion Expected:%0d Current:%0d ", <%=ch_rbid%>*2, numRbRsp),UVM_LOW)
          wait(numRbRsp == (<%=ch_rbid%>)*2);
          `uvm_info("saturate_rbs_b2b",$sformatf("All RBRsp received:%0d ", numRbRsp),UVM_DEBUG)
          `uvm_info("saturate_rbs_b2b",$sformatf("Waiting on DTWRsp completion Expected:%0d Current:%0d ", <%=ch_rbid%>*2, numDtwRsp),UVM_LOW)
          wait(numDtwRsp == <%=ch_rbid%>);
          `uvm_info("saturate_rbs_b2b",$sformatf("All DTWRsp received:%0d ", numDtwRsp),UVM_LOW)
        end
       4:
        begin
          smi_seq_item tmp_smi_rb_req_q[$];
          SMImsgIDTableEntry_t tmp_smi_table[$];
          `uvm_info("saturate_rbs_b2b","Choosing Scenario 1/2-DTW GID[0] -> FillRB-GID[1] -> Internal Release+Fill RB-GID[0] -> Release Back-pressure ", UVM_LOW)
          k_num_cmd = ((<%=ch_rbid%>)*2)+4;
          rb_release_scenario = 1;
          populateQs(1);
          dispatchDtwReq();
          tmp_smi_rb_req_q = smi_rb_req_txn_q;
          tmp_smi_table = smi_table;
          //Clear these SMI entries, they won't be used until later. Ensure tables don't overflow
          smi_rb_req_txn_q.delete();
          smi_table.delete();
          wait(m_scb.numDtwTxns == <%=ch_rbid%>);
          populateQs(0,1,<%=ch_rbid%>,0,0,0,0,1);
          `uvm_info("saturate_rbs_b2b",$sformatf("SMI Table Size==%0d ", smi_table.size()),UVM_DEBUG)
          dispatchRbReq();
          wait(m_scb.numRbrsReq == <%=ch_rbid%>);
          `uvm_info("saturate_rbs_b2b",$sformatf("Received RbReq release requests in SCB %0d==%0d ", m_scb.numRbrsReq, <%=ch_rbid%>),UVM_LOW)
          foreach(tmp_smi_table[i]) begin
            smi_table.push_front(tmp_smi_table[i]);
          end
          while(tmp_smi_rb_req_q.size() != 0) begin
            smi_rb_req_txn_q.push_back(tmp_smi_rb_req_q[0]);
            tmp_smi_rb_req_q.delete(0);
          end
          #10ns;
          dispatchRbReq();
          `uvm_info("saturate_rbs_b2b",$sformatf("SMI Table Size:%0d ", smi_table.size()),UVM_DEBUG)
          wait(m_scb.numRbrlReq == <%=ch_rbid%>);
          `uvm_info("saturate_rbs_b2b",$sformatf("Received RbReqs:%0d RbRlReqs:%0d, triggering release of smi_msg_ready block", m_scb.numRbrsReq, m_scb.numRbrlReq),UVM_DEBUG)
          wait(numRbRsp == 4);
          repeat(4) begin
            std::randomize(rbid_q) with {rbid_q.size()==1;};
            //Additional pressure when RBR RSP FIFO is at maximum
            begin
              smi_seq_item m_txn;
              bit status = 0; int attempt=0;
              m_txn = smi_seq_item::type_id::create("m_txn");
              while(!status) begin
                int currRbRsp_count = numRbRsp;
                attempt++;
                `uvm_info("saturate_rbs_b2b", $sformatf("Attempt %0d to fetch an RBID when they are released sporadically", attempt),UVM_MEDIUM)
                status = getcohrbid(m_txn);
                wait(numRbRsp>currRbRsp_count);
              end
              rbid_q[0] = m_txn.smi_rbid;
            end
            populateQs(1,0,1,1,1,0,1);
          end
          //Control end of test
          `uvm_info("saturate_rbs_b2b",$sformatf("Waiting on RBRsp completion Expected:%0d Current:%0d ", (<%=ch_rbid%>*2)+4, numRbRsp),UVM_LOW)
          wait(numRbRsp == ((<%=ch_rbid%>)*2));
          `uvm_info("saturate_rbs_b2b",$sformatf("All RBRsp received:%0d ", numRbRsp),UVM_DEBUG)
        end
      endcase
    end
    else begin //Resort to cmdline control
      if($test$plusargs("rb_all_dtws")) begin
        k_num_cmd = (<%=ch_rbid%>);
        populateQs(1);
        dispatchRbReq();
        `uvm_info("saturate_rbs_seq", $sformatf("All RBReqs dispatched..."),UVM_LOW)
        dispatchDtwReq();
        `uvm_info("saturate_rbs_seq", $sformatf("All DTWs dispatched..."),UVM_LOW)
        wait(numRbRsp == <%=ch_rbid%>);
        wait(numDtwRsp == <%=ch_rbid%>);
      end
      if($test$plusargs("rb_all_2dtws")) begin
        k_num_cmd = (<%=ch_rbid%>)/2;
        populateQs(2,0,<%=ch_rbid%>/2);
        dispatchRbReq();
        `uvm_info("saturate_rbs_seq", $sformatf("All RBReqs dispatched..."),UVM_LOW)
        dispatchDtwReq();
        `uvm_info("saturate_rbs_seq", $sformatf("All DTWs dispatched..."),UVM_LOW)
        wait(numRbRsp == (<%=ch_rbid%>/2));
        wait(numDtwRsp == <%=ch_rbid%>);
      end

      else if($test$plusargs("rb_all_release")) begin 
        SMImsgIDTableEntry_t tmp_smi_table[$];
        k_num_cmd = (<%=ch_rbid%>*2);
        rb_release_scenario = 1;
        populateQs(0);
        dispatchRbReq();
        `uvm_info("saturate_rbs_seq", $sformatf("All RBReqs dispatched..."),UVM_LOW)
        tmp_smi_table = smi_table;
        smi_table.delete();
        populateQs(0,1);
        foreach(tmp_smi_table[i]) begin
          smi_table.push_front(tmp_smi_table[i]);
        end
        dispatchRbReq();
        wait(numRbRsp == <%=ch_rbid%>);
        `uvm_info("saturate_rbs_seq", $sformatf("All RBs Released..."),UVM_LOW)
      end
    end
  end join
endtask

task dmi_rb_seq::populateQs(bit[1:0] _type, input bit flip_gid_in_rbid = 0, input int max_rbs= <%=ch_rbid%>, input bit dispatch_to_rb_arbiter = 0, input bit dispatch_to_dtw_arbiter = 0, input bit randomize_rbs=1, input bit skip_rbid_assignment=0, input do_not_generate_dtw = 0);
  smi_seq_item req_item, req_item_2nd;
  smi_seq_item req_rbid_item;
  smi_addr_t   cache_addr;
  int numRBIDs = max_rbs;
  bit cmd_status, rand_status;
  `uvm_info("populate_q",$sformatf(" Flip GID :%0b , Dispatch to RB arbiter : %0b, Dispatch to DTW arbiter : %0b", flip_gid_in_rbid, dispatch_to_rb_arbiter, dispatch_to_dtw_arbiter), UVM_LOW)
  //Shuffle
  if(randomize_rbs) begin
    rand_status = std::randomize(rbid_q) with { 
                     rbid_q.size() == numRBIDs;
                     unique {rbid_q};
                     foreach(rbid_q[i]){
                     rbid_q[i] < (<%=ch_rbid%>);
                     }
                   };
    if(!rand_status) `uvm_error("populate_q", "RBID queue randomization failed")
  end
  foreach(rbid_q[itr]) begin
    req_item = smi_seq_item::type_id::create("req_item");
    case(_type) 
      0: //All Release
        begin
          cmd_msg_type = DTW_NO_DATA;
        end
      1: //All Dtws
        begin
          randcase
            wt_dtw_no_dt.get_value()          : cmd_msg_type = DTW_NO_DATA;
            wt_dtw_dt_cln.get_value()         : cmd_msg_type = DTW_DATA_CLN;
	    wt_dtw_dt_dty.get_value()         : cmd_msg_type = DTW_DATA_DTY;
            wt_dtw_mrg_mrd_ucln.get_value()   : cmd_msg_type = DTW_MRG_MRD_UCLN;          
            wt_dtw_mrg_mrd_inv.get_value()    : cmd_msg_type = DTW_MRG_MRD_INV;        
          endcase
        end
      2: //All 2Dtws
        begin
          randcase
	          wt_dtw_dt_ptl.get_value()         : cmd_msg_type = DTW_DATA_PTL;
            wt_dtw_mrg_mrd_udty.get_value()   : cmd_msg_type = DTW_MRG_MRD_UDTY;          
          endcase
        end
    endcase

    `uvm_info("populate_q", $sformatf("Iteration:%0d Message Type Chosen 0x%0x", itr, cmd_msg_type),UVM_DEBUG)

    smi_txn_count += 1;
    if(cmd_msg_type inside {DTW_DATA_PTL,DTW_MRG_MRD_UDTY})begin
      req_item.smi_mw = 1;
    end
    else begin
      req_item.smi_mw = 0;
    end
    req_item.smi_msg_type = cmd_msg_type;
    if(flip_gid_in_rbid) begin
      req_item.smi_rbid = {~rbid_q[itr][WSMIRBID-1],rbid_q[itr][WSMIRBID-2:0]};
    end
    else begin
      req_item.smi_rbid = rbid_q[itr];
    end
    if(!skip_rbid_assignment) begin
      if(used_cohrbid_q.exists(req_item.smi_rbid)) begin
        `uvm_error("populate_q",$sformatf("RBID:%0h is already in use", req_item.smi_rbid))
      end
      else begin
        used_cohrbid_q[req_item.smi_rbid] = 1;
        `uvm_info("populate_q",$sformatf("Generating RBID:%0h txn", req_item.smi_rbid),UVM_DEBUG)
      end
    end
    if (do_not_generate_dtw) begin 
        buildPkt(req_item,1);
    end else begin
        buildPkt(req_item);
    end
    setSmiPriv(req_item);
    addPktToInfoQueues(req_item);
    `uvm_info("populate_q", $sformatf("Ready to send item...%p",req_item),UVM_DEBUG)
    `uvm_info("populate_q",$sformatf("Dispatching %0h", req_item.smi_rbid),UVM_DEBUG);
    case(cmd_msg_type)
      DTW_MRG_MRD_UCLN,DTW_MRG_MRD_INV: begin
         req_rbid_item = smi_seq_item::type_id::create("req_rbid_item");
         buildrbpkt(req_rbid_item,req_item,1,0,0);
         if(dispatch_to_dtw_arbiter) begin
           m_smi_tx_dtw_req_q.push_back(req_item);
           ->e_smi_dtw_req_q;
         end
         else begin
           smi_dtw_txn_q.push_back(req_item);
         end
         dtw_info[dtw_info.size()-1].RBRs_rmsg_id = req_rbid_item.smi_msg_id;
         dtw_info[dtw_info.size()-1].dce_id       = req_rbid_item.smi_src_ncore_unit_id;
         dtw_info[dtw_info.size()-1].dtws_expd = 1;
         if(dispatch_to_rb_arbiter) begin
          m_smi_tx_rb_req_q.push_back(req_rbid_item);
          ->e_smi_rb_req_q;
         end
         else begin
           smi_rb_req_txn_q.push_back(req_rbid_item);
         end
       end
      DTW_NO_DATA,DTW_DATA_PTL,DTW_DATA_DTY,DTW_DATA_CLN,DTW_MRG_MRD_UDTY: begin
         req_rbid_item = smi_seq_item::type_id::create("req_rbid_item");
         buildrbpkt(req_rbid_item,req_item,1,req_item.smi_mw,0);
         smi_rbid = req_rbid_item.smi_rbid;
         smi_tm   = req_rbid_item.smi_tm;
         dtw_info[dtw_info.size()-1].RBRs_rmsg_id = req_rbid_item.smi_msg_id;
         dtw_info[dtw_info.size()-1].dce_id       = req_rbid_item.smi_src_ncore_unit_id;
         smi_qos_rb = req_rbid_item.smi_qos;

         if(_type == 0) begin
           dtw_info[dtw_info.size()-1].rb_rl_rsp_expd = 1; 
         end
         else begin
           if(req_rbid_item.smi_mw && _type == 2)begin
             req_item_2nd = smi_seq_item::type_id::create("req_item_2nd");
             `uvm_info("txn_gen", $sformatf("smi_mw :%0b ",req_rbid_item.smi_mw),UVM_DEBUG)
             genDtwPktMW(req_item_2nd,smi_rbid);
             req_item_2nd.smi_tm = smi_tm;
             dtw_info[dtw_info.size()-1].aiu_id_2nd     = req_item_2nd.smi_src_ncore_unit_id;
             dtw_info[dtw_info.size()-1].smi_msg_id_2nd = req_item_2nd.smi_msg_id;
             dtw_info[dtw_info.size()-1].isMW           = 1;
             dtw_info[dtw_info.size()-1].dtws_expd      = 2;
             if(dispatch_to_dtw_arbiter) begin
               m_smi_tx_dtw_req_q.push_back(req_item_2nd);
               m_smi_tx_dtw_req_2nd_q.push_back(req_item);
               ->e_smi_dtw_req_q;
             end
             else begin
               smi_dtw_txn_q.push_back(req_item_2nd);
               m_smi_tx_dtw_req_2nd_q.push_back(req_item);
             end
             aiu_txn_count++;
           end
           else begin
             dtw_info[dtw_info.size()-1].dtws_expd = 1;
             if(dispatch_to_dtw_arbiter) begin
               m_smi_tx_dtw_req_q.push_back(req_item);
               ->e_smi_dtw_req_q;
             end
             else begin
               smi_dtw_txn_q.push_back(req_item);
             end
           end
         end

         if(dispatch_to_rb_arbiter) begin
           m_smi_tx_rb_req_q.push_back(req_rbid_item);
           ->e_smi_rb_req_q;
         end
         else begin
           smi_rb_req_txn_q.push_back(req_rbid_item);
         end

      end
    endcase
    `uvm_info("populate_q",$sformatf("Done working on RBID:%0h txn", req_item.smi_rbid),UVM_DEBUG)
  end

endtask

task dmi_rb_seq::dispatchRbReq();
  `uvm_info("dispatch_rb_req", $sformatf("Ready to dispatch %0d RBReqs", smi_rb_req_txn_q.size()),UVM_LOW)
  while(smi_rb_req_txn_q.size() != 0) begin
    smi_seq_item m_txn;
    m_txn = smi_seq_item::type_id::create("m_txn");
    m_txn.do_copy(smi_rb_req_txn_q[0]);
    m_smi_tx_rb_req_q.push_back(m_txn);
    smi_rb_req_txn_q.delete(0);
    ->e_smi_rb_req_q;
  end
  wait(m_smi_tx_rb_req_q.size() == 0);
  `uvm_info("dispatch_rb_req", $sformatf("RBReq dispatch done"),UVM_LOW)
endtask

task dmi_rb_seq::dispatchDtwReq();
  `uvm_info("dispatch_dtw_req", $sformatf("Ready to dispatch %0d DTWs", smi_dtw_txn_q.size()),UVM_LOW)
  while(smi_dtw_txn_q.size() != 0) begin
    smi_seq_item m_txn;
    m_txn = smi_seq_item::type_id::create("m_txn");
    m_txn.do_copy(smi_dtw_txn_q[0]);
    m_txn.smi_mpf1 = smi_dtw_txn_q[0].smi_mpf1;
    m_txn.smi_mpf2 = smi_dtw_txn_q[0].smi_mpf2;
    m_smi_tx_dtw_req_q.push_back(m_txn);
    smi_dtw_txn_q.delete(0);
    ->e_smi_dtw_req_q;
  end
  wait(m_smi_tx_dtw_req_q.size() == 0);
  `uvm_info("dispatch_dtw_req", $sformatf("DTWReq dispatch done"),UVM_LOW)
endtask

`endif
