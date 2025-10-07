interface <%=obj.BlockId%>_tf_cov_if(input clk, input rst_n);

   <%
   var nCacheIds = 0;
   var nCacheIdsString = "0";
   obj.AiuInfo.forEach(function(agent, index, arr) {
       if((agent.fnNativeInterface == "ACE")) {
	     nCacheIds++;
       }
   });
   %>
  import <%=obj.BlockId + '_ConcertoPkg'%>::*;
   //att signals
   bit 	      att_activate_recall_req;
   bit 	      att_activate_req_vld;
//   bit 	      att_activate_rsp_rdy;
   bit 	      att_activate_security;
   bit [47:0] att_activate_txn_addr;
//   bit [3:0]  att_activate_txn_attid;
   bit 	      att_activate_txn_is_wakeup;
   bit [12:0] att_activate_txn_sfipriv;
   bit [2:0]  att_activate_urgency;
   bit 	      att_activate_coh_rdy;
   bit 	      att_activate_rsp_SnoopTag_ways_in_use;
   bit [3:0]  att_activate_rsp_attid;
   //dir_commit signs
   bit 	      dir_commit_req_SnoopTag_way;
   bit 	      dir_commit_req_SnoopTag_write;
   bit [47:0] dir_commit_req_addr;
   bit [1:0]  dir_commit_req_aiuid;
   bit [3:0]  dir_commit_req_attid;
   bit 	      dir_commit_req_dont_write;
   bit [<%=nCacheIds-1%>:0]  dir_commit_req_ocv;
   bit [<%=nCacheIds-1%>:0]  dir_commit_req_scv;
   bit 	      dir_commit_req_security;
   bit 	      dir_commit_req_vld;
   bit 	      dir_commit_req_rdy;
   //dir_rsp signals
   bit [3:0] dir_rsp_attid;
   bit 	     dir_rsp_commit_vld;
   bit 	     dir_rsp_lookup_vld;
   bit [<%=nCacheIds-1%>:0] dir_rsp_olv;
   bit [<%=nCacheIds-1%>:0] dir_rsp_slv;
   //dir_rsp2 signals
   bit 	     dir_rsp2_SnoopTag_way;
   bit 	     dir_rsp2_SnoopTag_write;
//   bit [3:0] dir_rsp2_attid;
//   bit 	     dir_rsp2_valid;
   
   bit [47:0] wake_req_addr;
   bit [3:0]  wake_req_attid;
   bit 	      wake_req_security;
   bit [12:0] wake_req_sfipriv;
   bit [2:0]  wake_req_urgency;
   bit 	      wake_req_vld;
   bit 	      wake_req_rdy;
   
   bit [48:0] coh_req_addr;
   bit 	      coh_req_security;
   bit [12:0] coh_req_sfipriv;
   bit [2:0]  coh_req_urgency;
   bit 	      coh_req_vld;
   bit 	      coh_req_rdy;
   
   bit 	      upd_req_security;
   bit [12:0] upd_req_sfipriv;
   bit [2:0]  upd_req_urgency;
   bit 	      upd_req_vld;
   bit 	      upd_req_rdy;

   bit 	      dirutar_reg;
   
   clocking cov_cb @(negedge clk);
      input   dirutar_reg;      
      input   att_activate_recall_req;
      input   att_activate_req_vld;
//      input   att_activate_rsp_rdy;
      input   att_activate_security;
      input   att_activate_txn_addr;
//      input   att_activate_txn_attid;
      input   att_activate_txn_is_wakeup;
      input   att_activate_txn_sfipriv;
      input   att_activate_urgency;
      input   att_activate_coh_rdy;
      input   att_activate_rsp_SnoopTag_ways_in_use;
      input   att_activate_rsp_attid;
      //dir_commit signs
      input   dir_commit_req_SnoopTag_way;
      input   dir_commit_req_SnoopTag_write;
      input   dir_commit_req_addr;
      input   dir_commit_req_aiuid;
      input   dir_commit_req_attid;
      input   dir_commit_req_dont_write;
      input   dir_commit_req_ocv;
      input   dir_commit_req_scv;
      input   dir_commit_req_security;
      input   dir_commit_req_vld;
      input   dir_commit_req_rdy;
      //dir_rsp signals
      input   dir_rsp_attid;
      input   dir_rsp_commit_vld;
      input   dir_rsp_lookup_vld;
      input   dir_rsp_olv;
      input   dir_rsp_slv;
      //dir_rsp2 signals
      input   dir_rsp2_SnoopTag_way;
      input   dir_rsp2_SnoopTag_write;
//      input   dir_rsp2_attid;
//      input   dir_rsp2_valid;
      
      input   wake_req_addr;
      input   wake_req_attid;
      input   wake_req_security;
      input   wake_req_sfipriv;
      input   wake_req_urgency;
      input   wake_req_vld;
      input   wake_req_rdy;
      
      input   coh_req_addr;
      input   coh_req_security;
      input   coh_req_sfipriv;
      input   coh_req_urgency;
      input   coh_req_vld;
      input   coh_req_rdy;
      
      input   upd_req_security;
      input   upd_req_sfipriv;
      input   upd_req_urgency;
      input   upd_req_vld;
      input   upd_req_rdy;
   endclocking // cov_cb
   
endinterface // dce_tf_cov_if

