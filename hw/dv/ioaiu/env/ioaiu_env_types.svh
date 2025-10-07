//
//IOAIU env Package Typedefs
// 

parameter nOttEntries  = <%=obj.AiuInfo[obj.Id].cmpInfo.nOttCtrlEntries%>;

typedef enum {
			  IDLE,
			  CONNECT,
			  ATTACH_ERROR, 
			  ATTACHED,
			  DETACH,
			  DETACH_ERROR
		  } eSysCoFSM;

typedef enum {  
                      addrNotInMemRegion,
                      addrHitInMultipleRegion,
                      illegalNSAccess,
 		      illDIIAccess,
		      dtwrsp_cmstatus_addr_err,
 		      strreq_cmstatus_addr_err,
                      dtrreq_cmstatus_addr_err,
		      dtwrsp_cmstatus_data_err,
 		      strreq_cmstatus_data_err,
                      dtrreq_cmstatus_data_err,
                      dataUncorrectableError,
                      no_error
		} errtype;
            
typedef enum{
            	      coh_write,
		      noncoh_write,
		      coh_read,
 		      noncoh_read,
		      coh_atomic,
                      noncoh_atomic,
                      dvm,
		      Dvmsync,
		      Dvmsync_nonsync,
                      isUpdate

            }txn_type;

typedef enum{
            	      is_write,
                      is_IoCacheEvict,
                      is_read,
		      is_snoop
            }cmdreq_type;   
                                                                   
typedef enum{
            	      is_StrReq,
                      is_SnpReq,
                      is_SysReq,
		      is_CCmdRsp,
		      is_NcCmdRsp,
		      is_DtwDbgRsp,
		      is_CmpRsp,
		      is_UpdRsp,
		      is_SysRsp,
		      is_DtrRsp,
		      is_DtwRsp,
		      is_DtrReq,
		      is_bad_smi_prot_cmd_type
            }smi_prot_cmd_types;                                                                      

typedef enum {
                      CMDrsp_wrong_tgt_id,
                      DTRreq_wrong_tgt_id,
                      DTRrsp_wrong_tgt_id,
                      DTWrsp_wrong_tgt_id,
                      SNPreq_wrong_tgt_id,
                      UPDrsp_wrong_tgt_id,
                      SYSreq_wrong_tgt_id,
                      SYSrsp_wrong_tgt_id,
                      dvm_time_out,
                      STRreq_time_out,
                      CCP_eviction_time_out,
                      CMDrsp_time_out,
                      sys_event_timeout,
                      sys_req_timeout,
		      sysevent_error,
                      ott_err,
                      data_err,
                      tag_err
 
 
             } mission_fault_causes;
