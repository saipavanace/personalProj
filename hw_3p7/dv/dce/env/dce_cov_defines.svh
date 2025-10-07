   
   //==========================================================================
   //             U T I L I T Y     D E F I N E S 
   //==========================================================================
   `define NUM_AIUS 3
   //******** eMsgCMD defines ****************
     `define DCE_RD_CMDS <%=obj.BlockId + '_con'%>::eCmdRdCpy,<%=obj.BlockId + '_con'%>::eCmdRdCln,<%=obj.BlockId + '_con'%>::eCmdRdVld,<%=obj.BlockId + '_con'%>::eCmdRdUnq
     `define DCE_CLN_CMDS <%=obj.BlockId + '_con'%>::eCmdClnUnq,<%=obj.BlockId + '_con'%>::eCmdClnVld,<%=obj.BlockId + '_con'%>::eCmdClnInv
     `define DCE_WR_CMDS <%=obj.BlockId + '_con'%>::eCmdWrUnqPtl,<%=obj.BlockId + '_con'%>::eCmdWrUnqFull
     `define DCE_UPD_CMDS <%=obj.BlockId + '_con'%>::eCmdUpdInv,<%=obj.BlockId + '_con'%>::eCmdUpdVld
   
     `define sfi_cov_points(cg_name,rsp_req)\
            SFIAddr       : coverpoint m_``cg_name``_``rsp_req``_entry.cache_addr \
            SFITransID    : coverpoint m_``cg_name``_``rsp_req``_entry. \
	                            cg_name``_sfi_trans_id; \
            SFIAIUTransID : coverpoint m_``cg_name``_``rsp_req``_entry.\
	                                     req_aiu_trans_id; \
	    SFIPrivAIUID  : coverpoint m_``cg_name``_``rsp_req``_entry.req_aiu_id; \
   
     `define xact_sample(msg_type, req_rsp) \
            <%=obj.BlockId + '_con'%>::eMsgCMD cmd_type; \
            cmd_type = aiu_cmd_trans_map[``msg_type``_``req_rsp``_entry.req_aiu_id]\
	       [``msg_type``_``req_rsp``_entry.req_aiu_trans_id].cmd_msg_type; \
            case(cmd_type) \
	      `DCE_RD_CMDS   : rd_``msg_type``_``req_rsp``_cov.sample(); \
              `DCE_CLN_CMDS  :; \
	      `DCE_WR_CMDS   :; \
	      <%=obj.BlockId + '_con'%>::eCmdDvmMsg : ; \
            endcase 

