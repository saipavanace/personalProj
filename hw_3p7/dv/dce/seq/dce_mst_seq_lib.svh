//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//  Task    : dce_updreq_burst_seq
//  Purpose : test unit ids against json, rather than cpr
//
//-----------------------------------------------------------------------
class dce_default_mst_seq extends dce_mst_base_seq; 
   `uvm_object_utils(dce_default_mst_seq)

   	smi_seq_item cmdreq_seq_item;
    smi_seq      cmdreq_seq;
   	int credits_pend;
   	string credits_msg;

    function new(string name="");
        super.new(name);
    endfunction

	task body();
  		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_default_mst_seq", UVM_NONE)
 		 populate_unique_addrq();
		 send_sysreq_attach();
  		
  		 fork
		 begin : T1
		 	wait_for_sysrsp();
			fork
      				send_cmdreq_txns();      	 //Thread1:  Thread that generates SMI CmdReq messages
      				send_updreq_txns();      	 //Thread2:  Thread that generates SMI UpdReq messages
			join_any
		 end
        	receive_cmdupdrsp_txns();    //Thread3:  Thread that receives SMI CmdRsp & UpdRsp messages
	    begin : SysReq_Attach_detach
		send_sysreq_txns();
	    end
    		update_cache_model_updreq(); //update cache model on successful completion 
    	 	begin                        //Thread4:  Thread that polls on attid dealloc to progress on single_step 
	  			if (m_scb != null) begin
                  fork     
      			forever begin
		  				@(m_scb.e_attid_dealloc);
		  				-> e_single_step;
					end
                  begin
                    @(m_scb.kill_test);
                  end    
                  join_any
                  disable T1;    
     			end
               
    		end 
			if ($test$plusargs("en_scrub")) begin
    			invoke_scrub_routine();
    		end
  		join_any
    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_default_mst_seq", UVM_NONE)


	endtask: body
  
endclass: dce_default_mst_seq	
	
class dce_cmdreq_burst_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_cmdreq_burst_seq)

    function new(string name="");
        super.new(name);
    endfunction

	task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_cmdreq_burst_seq", UVM_NONE)

 		 populate_unique_addrq();
		 send_sysreq_attach();
  		 
  		 fork
            begin  : T1
		 wait_for_sysrsp();
      		send_cmdreq_txns();      	 //Thread1:  Thread that generates SMI CmdReq messages
            end
        	receive_cmdupdrsp_txns();    //Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
    	 	begin                        //Thread3:  Thread that polls on attid dealloc to progress on single_step 
	  			if (m_scb != null) begin
      			forever begin
		  				@(m_scb.e_attid_dealloc);
		  				-> e_single_step;
					end
     			end
    		end 
	    begin : SysReq_Attach_detach
		send_sysreq_txns();
	    end
  		 join_any
    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_cmdreq_burst_seq", UVM_NONE)

	endtask: body
endclass: dce_cmdreq_burst_seq

class dce_updreq_burst_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_updreq_burst_seq)

    function new(string name="");
        super.new(name);
    endfunction

    task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    	`uvm_info("DCE_UPDREQ_BURST_SEQ", "Ready", UVM_LOW)

 		 populate_unique_addrq();
		 send_sysreq_attach();
  		 
  		 fork
		begin : T1
		 	wait_for_sysrsp();
			fork
      				send_cmdreq_txns();      	 //Thread1:  Thread that generates SMI CmdReq messages
      				send_updreq_txns();      	 //Thread2:  Thread that generates SMI UpdReq messages
			join_any
		 end

        	receive_cmdupdrsp_txns();    //Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
    	 	begin                        //Thread3:  Thread that polls on attid dealloc to progress on single_step 
	  			if (m_scb != null) begin
      			forever begin
		  				@(m_scb.e_attid_dealloc);
		  				-> e_single_step;
					end
     			end
    		end 
	    begin : SysReq_Attach_detach
		send_sysreq_txns();
	    end
    		update_cache_model_updreq();
  		 join_any

	endtask: body
endclass : dce_updreq_burst_seq

class dce_allops_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_allops_seq)

    function new(string name="");
        super.new(name);
    endfunction

    task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_allops_seq", UVM_NONE)

 		 populate_unique_addrq();
		 send_sysreq_attach();
  		 
  		 fork
		begin : T1
		 	wait_for_sysrsp();
			fork
      				send_cmdreq_txns();      	 //Thread1:  Thread that generates SMI CmdReq messages
      				send_updreq_txns();      	 //Thread2:  Thread that generates SMI UpdReq messages
			join_any
		 end

        	receive_cmdupdrsp_txns();    //Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
    	 	begin                        //Thread3:  Thread that polls on attid dealloc to progress on single_step 
	  			if (m_scb != null) begin
      			forever begin
		  				@(m_scb.e_attid_dealloc);
		  				-> e_single_step;
					end
     			end
    		end 
	    begin : SysReq_Attach_detach
		send_sysreq_txns();
	    end
  		 join_any
    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_allops_seq", UVM_NONE)

	endtask: body
endclass : dce_allops_seq

class dce_alloc_ops_w_updreq_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_alloc_ops_w_updreq_seq)

    function new(string name="");
        super.new(name);
    endfunction

  	constraint c_concerto_msg {
    	r_cmdupd_item.smi_msg_type dist {
      		//allocating reads only that any cacheable master can issue.
      		eCmdRdVld	:= 100
      	};
      	solve r_pk_ch_agent before r_cmdupd_item.smi_msg_type;
    }

    task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_alloc_ops_w_updreq_seq", UVM_NONE)
 		 populate_unique_addrq();
		 send_sysreq_attach();
  		 
  		 fork
		begin : T1
		 	wait_for_sysrsp();
			fork
      				send_cmdreq_txns();      	 //Thread1:  Thread that generates SMI CmdReq messages
      				send_updreq_txns();      	 //Thread2:  Thread that generates SMI UpdReq messages
			join_any
		 end      	 
        	receive_cmdupdrsp_txns();    //Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
    		update_cache_model_updreq(); //update cache model on successful completion 
	    begin : SysReq_Attach_detach
		send_sysreq_txns();
	    end
  		 join_any

    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_alloc_ops_w_updreq_seq", UVM_NONE)
	endtask: body
endclass : dce_alloc_ops_w_updreq_seq


class dce_snpreq_rbreq_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_snpreq_rbreq_seq)
    
   task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_snpreq_rbreq_seq", UVM_NONE)
 		 populate_unique_addrq();
		 send_sysreq_attach();
  		 
  		 fork
		 	begin
		 		wait_for_sysrsp();
 		 		populate_available_agentsq();
		 		//1. Issue RdUnique to get the line in UD from agent0
		 		//2. Issue RdVld to get the line in SC from agent 1. 
		 		//This will initiate Snoops and RBreq
				send_directed_cmdreq_txn(m_ch_agentq[0], m_dce_cntr.m_unq_addrq[0], eCmdRdUnq);	
				send_directed_cmdreq_txn(m_nc_agentq[0], m_dce_cntr.m_unq_addrq[0], eCmdRdNITC);	
				ev_last_cmdreq_issued.trigger();
		 	end
			begin
        		receive_cmdupdrsp_txns();    //Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
			end
  		 join_any

    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_snpreq_rbreq_seq", UVM_NONE)
	endtask: body
endclass : dce_snpreq_rbreq_seq

class dce_snpreq_rdunq_rdvld_rdunq_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_snpreq_rdunq_rdvld_rdunq_seq)
    
   task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_snpreq_rdunq_rdvld_rdunq_seq", UVM_NONE)
 		 populate_unique_addrq();
		 send_sysreq_attach();
  		 
  		 fork
		 	begin
		 		wait_for_sysrsp();
 		 		populate_available_agentsq();
		 		//1. Issue RdUnique to get the line in UD from agent0
		 		//2. Issue RdVld to get the line in SC from agent 1 and line in agent0 UD-->SD. 
		 		//1. Issue RdUnique from agent 2 to snoop both agent0 and agent1
				send_directed_cmdreq_txn(m_updreq_masterq[0], m_dce_cntr.m_unq_addrq[0], eCmdRdUnq);	
				send_directed_cmdreq_txn(m_updreq_masterq[1], m_dce_cntr.m_unq_addrq[0], eCmdRdVld);	
				send_directed_cmdreq_txn(m_updreq_masterq[2], m_dce_cntr.m_unq_addrq[0], eCmdRdUnq);	
    			ev_last_cmdreq_issued.trigger();
		 	end
			begin
        		receive_cmdupdrsp_txns();    //Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
			end
  		 join_any

    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_snpreq_rdunq_rdvld_rdunq_seq", UVM_NONE)
	endtask: body
endclass : dce_snpreq_rdunq_rdvld_rdunq_seq

class dce_directed_seq0 extends dce_default_mst_seq; 
   `uvm_object_utils(dce_directed_seq0)
    
   task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_directed_seq0", UVM_NONE)
 		 populate_unique_addrq();
		 send_sysreq_attach();
  		 
  		 fork
		 	begin
		 		wait_for_sysrsp();
 		 		populate_available_agentsq();
		 		//1. Issue RdUnique to get the line in UD from agent0
		 		//2. Issue RdVld to get the line in SC from agent 1 and line in agent0 UD-->SD. 
		 		//1. Issue RdUnique from agent 2 to snoop both agent0 and agent1
				send_directed_cmdreq_txn(m_ch_agentq[0], m_dce_cntr.m_unq_addrq[0], eCmdRdUnq);	
				send_directed_cmdreq_txn(m_ch_agentq[1], m_dce_cntr.m_unq_addrq[0], eCmdRdVld);	
				send_directed_cmdreq_txn(m_nc_agentq[2], m_dce_cntr.m_unq_addrq[0], eCmdRdNITCClnInv);	
				ev_last_cmdreq_issued.trigger();
		 	end
			begin
        		receive_cmdupdrsp_txns();    //Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
			end
  		 join_any

    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_directed_seq0", UVM_NONE)
	endtask: body
endclass : dce_directed_seq0

class dce_dm_recallreq_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_dm_recallreq_seq)
   int idx;
   int sf0_agentidq[$] = addrMgrConst::get_sf_assoc_agents(0);

    
   task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
 		`ASSERT(sf0_agentidq.size()> 0 );
    	`uvm_info("DCE_MST_SEQ", $psprintf("sf0_agentidq-%0p", sf0_agentidq), UVM_NONE)
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_dm_recallreq_seq", UVM_NONE)
 		populate_unique_addrq();
		 send_sysreq_attach();
  		
  		//fork
			begin:T1 //Generates SMI CMDreq msgs

			while (m_scb.m_dce_txnq.size() == 0) begin // Adding this code before foreach to make sure all SysRsp are recieved
				#<%=obj.Clocks[0].params.period%>ps;
    			end
    			while (m_scb.m_dce_txnq.size() > 0) begin
				#(<%=obj.Clocks[0].params.period%>ps * 20);
    			end
			sysreq_inflight.delete();
        		foreach(m_dce_cntr.m_unq_addrq[i]) begin //Thread1
 					//This do-while loop makes sure we have a cacheable agent available that maps to SF0
 					do 
 					begin
 						populate_available_agentsq();
						for (int k = m_ch_agentq.size()-1; k >= 0; k--) begin
							if ((m_ch_agentq[k] inside {sf0_agentidq}) == 0) begin
								m_ch_agentq.delete(k);
							end
						end
 						if (m_ch_agentq.size() == 0) //add some delay so agents become available
							#(<%=obj.Clocks[0].params.period%>ps * 10);
					end
					while ((m_ch_agentq.size() == 0) && !m_scb.garbage_dmiid);

					if (m_scb.garbage_dmiid == 1)
						populate_available_agentsq();
        			
        			idx = $urandom_range(m_ch_agentq.size() - 1);

		   			//1. Issue RdUnique to get the line in UD from agent0 to initiate recalls for no_addr_hit and multi_addr_hit tests 
		    		send_directed_cmdreq_txn(m_ch_agentq[idx], m_dce_cntr.m_unq_addrq[i], eCmdRdUnq);	
		    		m_cmds_issued++;
    				`uvm_info("DCE_MST_SEQ", $psprintf("Issueing txn_num:%0d m_cmds_issued:%0d stop_cmd_issue:%0d", i, m_cmds_issued, m_stop_cmd_issue), UVM_LOW)
					if (m_stop_cmd_issue == 1) begin
    					`uvm_info("DCE_MST_SEQ", $psprintf("Stop cmd issue after %0d txns", m_cmds_issued), UVM_LOW)
    					break;
					end
					//since we have disabled credit checks in this test, there is a risk of sending too many commands too quickly and hitting RTL assertion on skid buffer cmdreq overflow. hence added the below event to make sure next command issued only when previous one is completed
					@(m_scb.e_attid_dealloc);
				end
				ev_last_cmdreq_issued.trigger();
			end:T1
			//Cannot have credit checks since we dont know how many txns are really issued in this test, due to m_stop_cmd_issue. 
			//begin:T2
        	//	receive_cmdupdrsp_txns(-1, m_cmds_issued);    //Thread3:  Thread that receives SMI CmdRsp & UpdRsp messages
			//end:T2
		//join_any

    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_dm_recallreq_seq", UVM_NONE)
	endtask: body
endclass : dce_dm_recallreq_seq

class dce_ace_ro_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_ace_ro_seq)

    function new(string name="");
        super.new(name);
    endfunction

  	constraint c_concerto_msg {
    	r_cmdupd_item.smi_msg_type dist {
      		//allocating reads only
      		eCmdRdCln	:= m_unit_args.k_cmd_rd_cln_pct.get_value(),
      		eCmdRdNShD	:= m_unit_args.k_cmd_rd_not_shd_pct.get_value(),
      		eCmdRdVld	:= m_unit_args.k_cmd_rd_vld_pct.get_value(),
      		eCmdRdNITC	:= 100
      	};
      	solve r_pk_ch_agent before r_cmdupd_item.smi_msg_type;
    }

    task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_ace_ro_seq", UVM_NONE)
 		 populate_unique_addrq();
		 send_sysreq_attach();
  		 
  		 fork
		begin : T1
		 	wait_for_sysrsp();
			fork
      				send_cmdreq_txns();      	 //Thread1:  Thread that generates SMI CmdReq messages
      				send_updreq_txns();      	 //Thread2:  Thread that generates SMI UpdReq messages
			join_any
		 end      	 
        	receive_cmdupdrsp_txns();    //Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
  		 join_any

    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_ace_ro_seq", UVM_NONE)
	endtask: body
endclass : dce_ace_ro_seq

class dce_mrd_credit_chk_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_mrd_credit_chk_seq)
   const eMsgCMD op_readsq[$] = '{eCmdRdCln, eCmdRdNShD, eCmdRdVld, eCmdRdUnq, eCmdRdNITC};
   int op_idx, aiu_idx;
    
   task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_mrd_credit_chk_seq", UVM_NONE)
 		 populate_unique_addrq();
		 send_sysreq_attach();
  		 
  		 fork
		 	begin
		 		wait_for_sysrsp();
 		 		populate_available_agentsq();
		 		//1. Issue random reads to unique addresses that generate MRDreqs, and in slv_seq delay return of MrdRsps.
				for (int i = 0; i < 200; i++) begin
					aiu_idx = $urandom_range(m_ch_agentq.size() - 1);
					if(addrMgrConst::get_native_interface(m_ch_agentq[aiu_idx]) == addrMgrConst::IO_CACHE_AIU) begin
						op_idx  = $urandom_range(op_readsq.size() - 1,2);
					end
					else
						op_idx  = $urandom_range(op_readsq.size() - 1);
					send_directed_cmdreq_txn(m_ch_agentq[aiu_idx], m_dce_cntr.m_unq_addrq[i], op_readsq[op_idx]);	
				end 
        		#(<%=obj.Clocks[0].params.period%>ps * 5000000);
				ev_last_cmdreq_issued.trigger();
		 	end
        	receive_cmdupdrsp_txns(200);    //Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
  		 join_any

    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_mrd_credit_chk_seq", UVM_NONE)
	endtask: body
endclass : dce_mrd_credit_chk_seq

class dce_rbid_rbuse_credit_chk_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_rbid_rbuse_credit_chk_seq)
   const eMsgCMD op_writesq[$] = '{eCmdWrUnqFull, eCmdWrUnqPtl};
   int op_idx, aiu_idx; 
    
   task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_rbid_rbuse_credit_chk_seq", UVM_NONE)
 		 populate_unique_addrq();
		 send_sysreq_attach();
  		 
  		 fork
		 	begin
		 		wait_for_sysrsp();
 		 		populate_available_agentsq();
		 		//1. Issue random writes to unique addresses that generate RBR reqs, and in slv_seq delay return of RBUreqs.
				for (int i = 0; i < 50; i++) begin
					aiu_idx = $urandom_range(m_ch_agentq.size() - 1);
					op_idx  = $urandom_range(op_writesq.size() - 1);
					send_directed_cmdreq_txn(m_ch_agentq[aiu_idx], m_dce_cntr.m_unq_addrq[i], op_writesq[op_idx]);	
				end 
        		#(<%=obj.Clocks[0].params.period%>ps * 5000000);
				ev_last_cmdreq_issued.trigger();
		 	end
			begin
        		receive_cmdupdrsp_txns(50);    //Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
			end
  		 join_any

    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_rbid_rbuse_credit_chk_seq", UVM_NONE)
	endtask: body
endclass : dce_rbid_rbuse_credit_chk_seq

class dce_rbid_rbrls_credit_chk_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_rbid_rbrls_credit_chk_seq)
   int idx, itr;
    
   task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_rbid_rbrls_credit_chk_seq", UVM_NONE)
 		 populate_unique_addrq();
		 send_sysreq_attach();
  		 
  		 fork
		 	begin
		 		wait_for_sysrsp();
 		 		populate_available_agentsq();
		 		//1. Issue random writes to unique addresses that generate RBR reqs, and in slv_seq delay return of RBUreqs.
		 		//All MkUnqs are targeted to funit-id:0
				for (int i = 0; i < 50; i++) begin 
					send_directed_cmdreq_txn(0, m_dce_cntr.m_unq_addrq[i], eCmdMkUnq);	
				end 
				for (int j = 0; j < 50; j++) begin 
					do
					begin
						populate_available_agentsq();
						#(<%=obj.Clocks[0].params.period%>ps * 10);
					end
					while (m_ch_agentq.size() == 0);
					

					itr = 0;
					do 
					begin 
						if (itr == 50) begin
							#(<%=obj.Clocks[0].params.period%>ps * 10);
							populate_available_agentsq();
							itr = 0;
						end
						idx = $urandom_range(m_ch_agentq.size() - 1);
						itr++;
					end 
					while (m_ch_agentq[idx] == 0);
					send_directed_cmdreq_txn(m_ch_agentq[idx], m_dce_cntr.m_unq_addrq[j], eCmdRdVld);	
				end 
        		#(<%=obj.Clocks[0].params.period%>ps * 5000000);
				ev_last_cmdreq_issued.trigger();
		 	end
			begin
        		receive_cmdupdrsp_txns(100);    //Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
			end
  		 join_any

    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_rbid_rbrls_credit_chk_seq", UVM_NONE)
	endtask: body
endclass : dce_rbid_rbrls_credit_chk_seq

class dce_snp_credit_chk_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_snp_credit_chk_seq)
    
   task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
 		`ASSERT(m_ch_agentq.size() >= 2);
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_snp_credit_chk_seq", UVM_NONE)
 		 populate_unique_addrq();
		 send_sysreq_attach();
  		 
  		 fork
		 	begin
		 		wait_for_sysrsp();
 		 		populate_available_agentsq();
		 		//1. Issue (snp_credits+1) number of RdVlds to unique addresses from AIU0, so those addresses are in unique state
		 		//2. Issue (snp_credits+1) number of RdUnqs to the same unique addresses from AIU1 so that SnpReqs are issued to AIU0, delay the SnpRsps in the dce_slv_seq.
				for (int i = 0; i <= addrMgrConst::snp_credits_inflight[0]; i++) begin 
					send_directed_cmdreq_txn(m_ch_agentq[0], m_dce_cntr.m_unq_addrq[i], eCmdRdVld);	
				end 
				for (int i = 0; i <= addrMgrConst::snp_credits_inflight[0]; i++) begin 
					send_directed_cmdreq_txn(m_ch_agentq[1], m_dce_cntr.m_unq_addrq[i], eCmdRdUnq);	
				end 
        		#(<%=obj.Clocks[0].params.period%>ps * 5000000);
				ev_last_cmdreq_issued.trigger();
		 	end
			begin
        		receive_cmdupdrsp_txns(-1, ((addrMgrConst::snp_credits_inflight[0]+1)*2));    //Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
			end
  		 join_any

    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_snp_credit_chk_seq", UVM_NONE)
	endtask: body
endclass : dce_snp_credit_chk_seq

//
class dce_directed_wrunq_from_ace_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_directed_wrunq_from_ace_seq)
    
   task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    	`uvm_info("DCE_MST_SEQ", "Start executing dce_directed_wr_unq_from_ace_seq", UVM_NONE)
 		 populate_unique_addrq();
		 send_sysreq_attach();
  		 
  		 fork
		 	begin
		 		wait_for_sysrsp();
 		 		populate_available_agentsq();
				send_directed_cmdreq_txn(m_ace_agentq[0], m_dce_cntr.m_unq_addrq[0], eCmdRdUnq);	
		  		@(m_scb.e_attid_dealloc);
				send_directed_cmdreq_txn(m_ace_agentq[0], m_dce_cntr.m_unq_addrq[0], eCmdWrUnqFull);	
		  		@(m_scb.e_attid_dealloc);
				
				if(m_ace_agentq[0] != m_ch_agentq[0]) // Want this command from different AIU
				send_directed_cmdreq_txn(m_ch_agentq[0], m_dce_cntr.m_unq_addrq[0], eCmdMkInv);
				else	
				send_directed_cmdreq_txn(m_ch_agentq[1], m_dce_cntr.m_unq_addrq[0], eCmdMkInv);
		  		
				@(m_scb.e_attid_dealloc);
				
				if(m_ace_agentq[0] != m_ch_agentq[0])
				send_directed_cmdreq_txn(m_ch_agentq[0], m_dce_cntr.m_unq_addrq[0], eCmdRdUnq);	
				else	
				send_directed_cmdreq_txn(m_ch_agentq[1], m_dce_cntr.m_unq_addrq[0], eCmdRdUnq);	
		  		
				@(m_scb.e_attid_dealloc);
				send_directed_cmdreq_txn(m_ace_agentq[0], m_dce_cntr.m_unq_addrq[0], eCmdRdCln);	
		  		@(m_scb.e_attid_dealloc);
				
				if(m_ace_agentq[0] != m_ch_agentq[0])
				send_directed_updreq_txn(m_ch_agentq[0], m_dce_cntr.m_unq_addrq[0]);	
				else	
				send_directed_updreq_txn(m_ch_agentq[1], m_dce_cntr.m_unq_addrq[0]);	
			
		  		@(m_scb.e_attid_dealloc);
				send_directed_cmdreq_txn(m_ace_agentq[0], m_dce_cntr.m_unq_addrq[0], eCmdWrUnqPtl);	
				ev_last_cmdreq_issued.trigger();
		 	end
			begin 
        		receive_cmdupdrsp_txns(6);    //Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
			end
  		 join_any

    	`uvm_info("DCE_MST_SEQ", "Finish executing dce_directed_wr_unq_from_ace_seq", UVM_NONE)
	endtask: body
endclass : dce_directed_wrunq_from_ace_seq

//#Check.DCE.dm_aliasing_test
class dce_addr_aliasing_seq extends dce_default_mst_seq; 
   `uvm_object_utils(dce_addr_aliasing_seq)
   
	task body();
 		`ASSERT(m_handles_fwded && m_seqrs_fwded);
    		`uvm_info("DCE_MST_SEQ", "Start executing dce_addr_aliasing_seq", UVM_NONE)
 		 populate_unique_addrq();
		 send_sysreq_attach();

		fork
			begin	//Thread1: Thread that generates SMI CmdReq messages
		 		wait_for_sysrsp();
 		 		populate_available_agentsq();
				for(int i = 0; i < (addrMgrConst::snoop_filters_info[0].num_ways * addrMgrConst::snoop_filters_info[0].num_sets); i++) begin
					m_ch_agentq.shuffle();
					send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq[i], eCmdRdUnq);
					m_cmdupdreqs_issued++;
		  			@(m_scb.e_attid_dealloc);
				end
				ev_last_cmdreq_issued.trigger();
			end
			begin	//Thread2:  Thread that receives SMI CmdRsp & UpdRsp messages
        			//receive_cmdupdrsp_txns(addrMgrConst::snoop_filters_info[0].num_ways * addrMgrConst::snoop_filters_info[0].num_sets); 
        			receive_cmdupdrsp_txns(m_dce_cntr.m_unq_addrq.size()); 
			end
				if ($test$plusargs("en_scrub"))
    				invoke_scrub_routine();
		join_any   				
					
	`uvm_info("DCE_MST_SEQ", "Finish executing dce_addr_aliasing_seq", UVM_NONE)
	endtask: body
endclass : dce_addr_aliasing_seq

class dce_directed_cmd_upd_req_same_address_seq extends dce_default_mst_seq;
	`uvm_object_utils(dce_directed_cmd_upd_req_same_address_seq)

	int dealloc_count = 0;
		task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "Start executing dce_directed_cmd_upd_req_same_address_seq", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();
			fork
				begin
		 			wait_for_sysrsp();
 		 			populate_available_agentsq();
					for(int j=0;j < 50;j++) begin
						for(int i =1; i < 10 ;i++) begin
							//m_exc_masterq.shuffle();
							send_directed_cmdreq_txn(m_exc_masterq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdVld,0);
							#2ns;
							if(m_exc_masterq.size() > 1) begin
								send_directed_updreq_txn(m_exc_masterq[1], m_dce_cntr.m_unq_addrq[0],i-1);
								wait(dealloc_count == ((i*2)+(j*18)));	
							end	
							else begin
		  						@(m_scb.e_attid_dealloc);
								send_directed_cmdreq_txn(m_exc_masterq[0],m_dce_cntr.m_unq_addrq[1], eCmdRdVld,0);
		  						@(m_scb.e_attid_dealloc);
							end	
		  				
						end
					end
					ev_last_cmdreq_issued.trigger();
				end
				begin
        				receive_cmdupdrsp_txns(18*50);
				end
				begin
					forever begin
		  					@(m_scb.e_attid_dealloc);
							dealloc_count++;
					end
				end
			join_any 
						
	`uvm_info("DCE_MST_SEQ", "Finish executing dce_directed_cmd_upd_req_same_address_seq", UVM_NONE)
	endtask: body
endclass : dce_directed_cmd_upd_req_same_address_seq

class dce_directed_same_set_target_all_SF_seq extends dce_default_mst_seq; // This sequence is to cover retry's to all snoop filters.
	`uvm_object_utils(dce_directed_same_set_target_all_SF_seq)
	int total_cmds = 0;
        <% if(obj.testBench == 'dce') { %>
        `ifndef VCS
	int indxq[];
       `else // `ifndef VCS
        int indxq[$];
       `endif // `ifndef VCS ... `else ... 
        <% } else {%>
        int indxq[];
        <% } %>
	task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "Start executing dce_directed_same_set_target_all_SF_seq", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();
			for(int i = 0; i < addrMgrConst::snoop_filters_info.size();i++) begin
				total_cmds += addrMgrConst::snoop_filters_info[i].num_ways + 4;
			end
	fork
		begin
		 	wait_for_sysrsp();
 		 	populate_available_agentsq();
    			`uvm_info("DCE_MST_SEQ", $psprintf("Number of unique address for set index: %d are %d",sf_setaddr,m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr].size()), UVM_LOW)
			for(int i = 0; i < addrMgrConst::snoop_filters_info.size();i++) begin
				for(int j=0 ; j < addrMgrConst::snoop_filters_info[i].num_ways + 4;j++) begin
					do begin
						m_ch_agentq.shuffle();	
					end
					while(addrMgrConst::get_snoopfilter_id(m_ch_agentq[0]) != i);
					
					if(j == addrMgrConst::snoop_filters_info[i].num_ways + 3) begin
						if(m_scb.m_dce_txnq.size() != 0)
							@(m_scb.e_attid_dealloc);
						if(addrMgrConst::snoop_filters_info.size() > 1) begin
							do begin
								m_ch_agentq.shuffle();	
							end
							while(addrMgrConst::get_snoopfilter_id(m_ch_agentq[0]) == i);
						end
						indxq = m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr].find_index(item) with ((item >> addrMgrConst::WCACHE_OFFSET) == (m_scb.deallocated_address >> addrMgrConst::WCACHE_OFFSET));
						if(indxq.size() != 0) 
							send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr][indxq[0]], eCmdRdUnq);
						else
							send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr][0], eCmdRdUnq);
					end
					else begin
						if(m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr].size() >= addrMgrConst::snoop_filters_info[i].num_ways + 3)
							send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr][j], eCmdRdUnq);
						else
							send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq[j], eCmdRdUnq);
					end
				end
				#(<%=obj.Clocks[0].params.period%>ps * 100);
				wait(m_scb.m_dce_txnq.size() == 0);
				`uvm_info("DCE_MST_SEQ_DEBUG",$psprintf("dce_scb_txns size :%d",m_scb.m_dce_txnq.size()), UVM_LOW)
			end
			ev_last_cmdreq_issued.trigger();
		end
		begin
        		receive_cmdupdrsp_txns(total_cmds);
		end
	join_any
	`uvm_info("DCE_MST_SEQ", "dce_directed_same_set_target_all_SF_seq", UVM_NONE)
	endtask: body
endclass : dce_directed_same_set_target_all_SF_seq

class dce_directed_same_set_target_all_SF_seq_hw_cfg_41 extends dce_default_mst_seq;
	`uvm_object_utils(dce_directed_same_set_target_all_SF_seq_hw_cfg_41)
	int total_cmds = 0;
	<% if(obj.testBench == 'dce') { %>
        `ifndef VCS
	int indxq[];
       `else // `ifndef VCS
        int indxq[$];
       `endif // `ifndef VCS ... `else ... 
        <% } else {%>
        int indxq[];
        <% } %>
	task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "Start executing dce_directed_same_set_target_all_SF_seq_hw_cfg_41", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();
			for(int i = 0; i < addrMgrConst::snoop_filters_info.size();i++) begin
				total_cmds += addrMgrConst::snoop_filters_info[i].num_ways + 4;
			end
			total_cmds = total_cmds * 2;
	fork
		begin
		 	wait_for_sysrsp();
 		 	populate_available_agentsq();
    			`uvm_info("DCE_MST_SEQ", $psprintf("Number of unique address for set index: %d are %d",sf_setaddr,m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr].size()), UVM_LOW)
			for(int k = 0; k < 2; k++) begin
				for(int i = (addrMgrConst::snoop_filters_info.size() -1); i >=0 ;i--) begin
					for(int j=0 ; j < addrMgrConst::snoop_filters_info[i].num_ways + 4;j++) begin
						do begin
							m_ch_agentq.shuffle();	
						end
						while(addrMgrConst::get_snoopfilter_id(m_ch_agentq[0]) != i);
						if(j == addrMgrConst::snoop_filters_info[i].num_ways + 3) begin
							if(m_scb.m_dce_txnq.size() != 0)
								@(m_scb.e_attid_dealloc);
							if(addrMgrConst::snoop_filters_info.size() > 1) begin
								do begin
									m_ch_agentq.shuffle();	
								end
								while(addrMgrConst::get_snoopfilter_id(m_ch_agentq[0]) == i);
							end
							indxq = m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr].find_index(item) with ((item >> addrMgrConst::WCACHE_OFFSET) == (m_scb.deallocated_address >> addrMgrConst::WCACHE_OFFSET));
							if(indxq.size() != 0) 
								send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr][indxq[0]], eCmdRdUnq);
							else
								send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr][0], eCmdRdUnq);
						end
						else begin
							if(m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr].size() >= addrMgrConst::snoop_filters_info[i].num_ways + 3)
								send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr][j], eCmdRdUnq);
							else
								send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq[j], eCmdRdUnq);
						end	
					end
					//#(<%=obj.Clocks[0].params.period%>ps * 100);
					wait(m_scb.m_dce_txnq.size() == 0);
				`uvm_info("DCE_MST_SEQ_DEBUG",$psprintf("dce_scb_txns size :%d",m_scb.m_dce_txnq.size()), UVM_LOW)
				end
			end
			ev_last_cmdreq_issued.trigger();
		end
		begin
        		receive_cmdupdrsp_txns(total_cmds);
		end
	join_any
	`uvm_info("DCE_MST_SEQ", "dce_directed_same_set_target_all_SF_seq_hw_cfg_41", UVM_NONE)
	endtask: body
endclass : dce_directed_same_set_target_all_SF_seq_hw_cfg_41

class dce_directed_wrclnptl_silent_seq extends dce_default_mst_seq; // This sequence is to test how DCE behaves when there is WrClnPtl from a CHI-A AIU so that DM has it has owner but due to silent transition line was downgraded to IX state from UC/UD in AIU
	`uvm_object_utils(dce_directed_wrclnptl_silent_seq)
	task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "Start executing dce_directed_wrclnptl_silent_seq", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();

			fork
				begin
		 			wait_for_sysrsp();
 		 			populate_available_agentsq();
					`uvm_info("DCE_LIB_DBG",$psprintf("m_chia_agentq size() = %d",m_chia_agentq.size()),UVM_LOW)
					send_directed_cmdreq_txn(m_chia_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdUnq);
		  			@(m_scb.e_attid_dealloc);
					m_dce_cntr.invoke_silent_cache_state_transition(0);
					send_directed_cmdreq_txn(m_chia_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdWrClnPtl);
		  			@(m_scb.e_attid_dealloc);
					send_directed_cmdreq_txn(m_chia_agentq[1],m_dce_cntr.m_unq_addrq[0], eCmdRdVld);
		  			@(m_scb.e_attid_dealloc);
					ev_last_cmdreq_issued.trigger();
				end
				begin
        				receive_cmdupdrsp_txns(3);
				end
			join_any
			`uvm_info("DCE_MST_SEQ", "dce_directed_wrclnptl_silent_seq", UVM_NONE)
	endtask: body
endclass : dce_directed_wrclnptl_silent_seq

class dce_directed_backpressure_seq extends dce_default_mst_seq;
	`uvm_object_utils(dce_directed_backpressure_seq)
	task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "Start executing dce_directed_backpressure_seq", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();

			fork
				begin
		 	wait_for_sysrsp();
 		 	populate_available_agentsq();
				//	for(int k = 0; k < 10; k++) begin
						send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdUnq,0);
		  				@(m_scb.e_attid_dealloc);
						send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdUnq,0);
							#(<%=obj.Clocks[0].params.period%>ps * 10);
				//	end
		  		//	@(m_scb.e_attid_dealloc);
					for(int j = 10; j < 20; j++) begin
						send_directed_updreq_txn(m_ch_agentq[0], m_dce_cntr.m_unq_addrq[j],0);
					end
					ev_last_cmdreq_issued.trigger();
				end
				begin
        				receive_cmdupdrsp_txns(12);
				end
			join_any
			`uvm_info("DCE_MST_SEQ", "dce_directed_backpressure_seq", UVM_NONE)
	endtask: body
endclass : dce_directed_backpressure_seq
					
class dce_directed_same_set_writes_fast_ports_seq extends dce_default_mst_seq;
	`uvm_object_utils(dce_directed_same_set_writes_fast_ports_seq)
	int total_cmds = 0;
	int indxq[];
	task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "Start executing dce_directed_same_set_writes_fast_ports_seq", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();
 		 	populate_available_agentsq();
			total_cmds = m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr].size();
	fork
		begin
		 	wait_for_sysrsp();
 		 	populate_available_agentsq();
    			`uvm_info("DCE_MST_SEQ", $psprintf("Number of unique address for set index: %d are %d",sf_setaddr,m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr].size()), UVM_LOW)
				for(int i = 0; i < total_cmds; i++) begin
					send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq_per_sfsetaddr[sf_setaddr][i], eCmdWrUnqFull,0);
					//send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq[i], eCmdWrUnqFull,0);
				end	
			ev_last_cmdreq_issued.trigger();
		end
		begin
        		receive_cmdupdrsp_txns(total_cmds);
		end
	join_any
	`uvm_info("DCE_MST_SEQ", "dce_directed_same_set_writes_fast_ports_seq", UVM_NONE)
	endtask: body
endclass : dce_directed_same_set_writes_fast_ports_seq

class dce_directed_attach_detach_seq extends dce_default_mst_seq;
	`uvm_object_utils(dce_directed_attach_detach_seq)
	

	task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "Start executing dce_directed_attach_detach_seq", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();
	fork
		begin
		 	wait_for_sysrsp();
 		 	populate_available_agentsq();
			for(int i=0; i < <%=obj.DceInfo[0].nCachingAgents%>; i++) begin
				send_sysreq_detach(CACHING_AIU_FUNIT_IDS[i]);
			end
			ev_last_cmdreq_issued.trigger();
		end
		begin
        		receive_cmdupdrsp_txns(<%=obj.DceInfo[0].nCachingAgents%>*2);
		end
	join_any
	`uvm_info("DCE_MST_SEQ", "dce_directed_attach_detach_seq", UVM_NONE)
	endtask: body
endclass : dce_directed_attach_detach_seq

class dce_directed_1_attach_detach_seq extends dce_default_mst_seq;
	`uvm_object_utils(dce_directed_1_attach_detach_seq)
	

	task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "Start executing dce_directed_1_attach_detach_seq", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();
	fork
		begin
		 	wait_for_sysrsp();
 		 	populate_available_agentsq();
			send_directed_cmdreq_txn(addrMgrConst::get_aiu_funitid(0),m_dce_cntr.m_unq_addrq[0], eCmdRdUnq,0);
		  	@(m_scb.e_attid_dealloc);
			send_sysreq_detach(0);
			#50ns;
			while(sys_rsps_recieved != (<%=obj.DceInfo[0].nCachingAgents%> +1))
			begin
				#100ns;
				`uvm_info("DCE_MST_DBG",$psprintf("rsps recieved = %p",sys_rsps_recieved),UVM_LOW)
			end
			send_directed_cmdreq_txn(1,m_dce_cntr.m_unq_addrq[0], eCmdRdUnq,0);
			ev_last_cmdreq_issued.trigger();
		end
		begin
        		receive_cmdupdrsp_txns(2);
		end
	join_any
	`uvm_info("DCE_MST_SEQ", "dce_directed_1_attach_detach_seq", UVM_NONE)
	endtask: body
endclass : dce_directed_1_attach_detach_seq

class dce_directed_2_attach_detach_seq extends dce_default_mst_seq;
	`uvm_object_utils(dce_directed_2_attach_detach_seq)
	

	task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "Start executing dce_directed_2_attach_detach_seq", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();
 		 	populate_available_agentsq();
	fork
		begin
		 	wait_for_sysrsp();
 		 	populate_available_agentsq();
			send_directed_cmdreq_txn(addrMgrConst::get_aiu_funitid(0),m_dce_cntr.m_unq_addrq[0], eCmdRdUnq,0);
		  	@(m_scb.e_attid_dealloc);
			send_directed_cmdreq_txn(addrMgrConst::get_aiu_funitid(1),m_dce_cntr.m_unq_addrq[0], eCmdRdVld,0);
		  	@(m_scb.e_attid_dealloc);
			send_directed_cmdreq_txn(addrMgrConst::get_aiu_funitid(2),m_dce_cntr.m_unq_addrq[0], eCmdRdVld,0);
			send_sysreq_detach(1);
			send_sysreq_detach(2);
			#50ns;
			while(sys_rsps_recieved != (<%=obj.DceInfo[0].nCachingAgents%> +2))
			begin
				#100ns;
				`uvm_info("DCE_MST_DBG",$psprintf("rsps recieved = %p",sys_rsps_recieved),UVM_LOW)
			end
			send_directed_cmdreq_txn(0,m_dce_cntr.m_unq_addrq[0], eCmdRdVld,0);
			ev_last_cmdreq_issued.trigger();
		end
		begin
        		receive_cmdupdrsp_txns(4);
		end
	join_any
	`uvm_info("DCE_MST_SEQ", "dce_directed_2_attach_detach_seq", UVM_NONE)
	endtask: body
endclass : dce_directed_2_attach_detach_seq

class dce_directed_3_attach_detach_seq extends dce_default_mst_seq;
	`uvm_object_utils(dce_directed_3_attach_detach_seq)
	

	task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "Start executing dce_directed_3_attach_detach_seq", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();
 		 	populate_available_agentsq();
	fork
		begin
		 	wait_for_sysrsp();
 		 	populate_available_agentsq();
			send_sysreq_detach(m_stash_targetq[0]);
			#50ns;
			while(sys_rsps_recieved != (<%=obj.DceInfo[0].nCachingAgents%> +1))
			begin
				#100ns;
				`uvm_info("DCE_MST_DBG",$psprintf("rsps recieved = %p",sys_rsps_recieved),UVM_LOW)
			end
			if(m_stash_targetq.size() > 1)
				send_directed_cmdreq_txn(m_stash_targetq[1],m_dce_cntr.m_unq_addrq[0], eCmdLdCchUnq,0);	
			else if(m_wr_stash_masterq.size() > 0)
				send_directed_cmdreq_txn(m_wr_stash_masterq[0],m_dce_cntr.m_unq_addrq[0], eCmdLdCchUnq,0);
			ev_last_cmdreq_issued.trigger();
		end
		begin
        		receive_cmdupdrsp_txns(1);
		end
	join_any
	`uvm_info("DCE_MST_SEQ", "dce_directed_3_attach_detach_seq", UVM_NONE)
	endtask: body
endclass : dce_directed_3_attach_detach_seq

class dce_directed_4_attach_detach_seq extends dce_default_mst_seq;
	`uvm_object_utils(dce_directed_4_attach_detach_seq)
	

	task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "Start executing dce_directed_4_attach_detach_seq", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();
	fork
		begin
		 	wait_for_sysrsp();
 		 	populate_available_agentsq();
			send_directed_cmdreq_txn(addrMgrConst::get_aiu_funitid(0),m_dce_cntr.m_unq_addrq[0], eCmdRdUnq,0);
		  	@(m_scb.e_attid_dealloc);
			send_directed_cmdreq_txn(addrMgrConst::get_aiu_funitid(1),m_dce_cntr.m_unq_addrq[0], eCmdRdVld,0);
		  	@(m_scb.e_attid_dealloc);
			send_directed_cmdreq_txn(addrMgrConst::get_aiu_funitid(2),m_dce_cntr.m_unq_addrq[0], eCmdRdVld,0);
			send_sysreq_detach(1);
		//	send_sysreq_detach(2);
			#50ns;
			while(sys_rsps_recieved != (<%=obj.DceInfo[0].nCachingAgents%> +1))
			begin
				#100ns;
				`uvm_info("DCE_MST_DBG",$psprintf("rsps recieved = %p",sys_rsps_recieved),UVM_LOW)
			end
			send_directed_cmdreq_txn(0,m_dce_cntr.m_unq_addrq[0], eCmdRdUnq,0);
			ev_last_cmdreq_issued.trigger();
		end
		begin
        		receive_cmdupdrsp_txns(4);
		end
	join_any
	`uvm_info("DCE_MST_SEQ", "dce_directed_4_attach_detach_seq", UVM_NONE)
	endtask: body
endclass : dce_directed_4_attach_detach_seq	

class dce_snprsp_snarf1_error_seq extends dce_default_mst_seq;
	`uvm_object_utils(dce_snprsp_snarf1_error_seq)

	task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "dce_snprsp_snarf1_error_seq", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();

	fork
		begin
		 	wait_for_sysrsp();
 		 	populate_available_agentsq();
			send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdUnq,0);
		  	@(m_scb.e_attid_dealloc);
			if ($test$plusargs("sharer_snprsp_error")) begin
				send_directed_cmdreq_txn(m_proxy_cache_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdVld,0);
		  		@(m_scb.e_attid_dealloc);
			end
			//#Test.DCE.SnpRspErr.RdStsh
			if(m_unit_args.k_cmd_ldcch_unq_pct.get_value() == 100) begin
			//#Test.DCE.SnpRspErr.RdStshUnq
				send_directed_cmdreq_txn(m_wr_stash_masterq[0],m_dce_cntr.m_unq_addrq[0], eCmdLdCchUnq,0);
			end
			else if(m_unit_args.k_cmd_ldcch_shd_pct.get_value() == 100) begin
			//#Test.DCE.SnpRspErr.RdStshShd
				send_directed_cmdreq_txn(m_wr_stash_masterq[0],m_dce_cntr.m_unq_addrq[0], eCmdLdCchShd,0);
			end
			else if(m_unit_args.k_cmd_wr_stsh_ptl_pct.get_value() == 100) begin
			//#Test.DCE.SnpRspErr.WrStsh_NonTarget
				send_directed_cmdreq_txn(m_wr_stash_masterq[0],m_dce_cntr.m_unq_addrq[0], eCmdWrStshPtl,0);
			end
			else if(m_unit_args.k_cmd_wr_unq_ptl_pct.get_value() == 100) begin
			//#Test.DCE.SnpRspErr.WRUNQ
				<% if (obj.DceInfo[0].nCachingAgents <=1 ) { %>
				send_directed_cmdreq_txn(m_nc_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdWrUnqPtl,0);
				<%}
				else {%>
				send_directed_cmdreq_txn(m_ch_agentq[1],m_dce_cntr.m_unq_addrq[0], eCmdWrUnqPtl,0);
				<%}%>
			end
			else if(m_unit_args.k_cmd_wr_unq_full_pct.get_value() == 100) begin
			//#Test.DCE.SnpRspErr.WRUNQ
				<% if (obj.DceInfo[0].nCachingAgents <=1 ) { %>
				send_directed_cmdreq_txn(m_nc_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdWrUnqFull,0);
				<%}
				else {%>
				send_directed_cmdreq_txn(m_ch_agentq[1],m_dce_cntr.m_unq_addrq[0], eCmdWrUnqFull,0);
				<%}%>
			end
			else if(m_unit_args.k_cmd_rd_unq_pct.get_value() == 100) begin
			//#Test.DCE.SnpRspErr.RdUnq
				send_directed_cmdreq_txn(m_ch_agentq[1],m_dce_cntr.m_unq_addrq[0], eCmdRdUnq,0);
			end
			else if(m_unit_args.k_cmd_rd_nitc_clninv_pct.get_value() != 0) begin
			//#Test.DCE.SnpRspErr.NITCs
				if($urandom(2) > 1) begin
					if (m_nc_agentq.size() > 0) begin
						send_directed_cmdreq_txn(m_nc_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdNITCClnInv,0);
					end
					else begin
						send_directed_cmdreq_txn(m_ch_agentq[1],m_dce_cntr.m_unq_addrq[0], eCmdRdNITCClnInv,0);
					end
				end
				else begin
					if (m_nc_agentq.size() > 0) begin
						send_directed_cmdreq_txn(m_nc_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdNITCMkInv,0);
					end
					else begin
						send_directed_cmdreq_txn(m_ch_agentq[1],m_dce_cntr.m_unq_addrq[0], eCmdRdNITCMkInv,0);
					end
				end
			end
			else
      				send_cmdreq_txns();
		  	@(m_scb.e_attid_dealloc);
			ev_last_cmdreq_issued.trigger();
		end
		begin
			if ($test$plusargs("sharer_snprsp_error"))
        			receive_cmdupdrsp_txns(3);
			else
        			receive_cmdupdrsp_txns(2);
			
		end
	join_any
	`uvm_info("DCE_MST_SEQ", "dce_snprsp_snarf1_error_seq", UVM_NONE)
	endtask: body
endclass : dce_snprsp_snarf1_error_seq

class dce_exc_ops_error_seq extends dce_default_mst_seq;
	`uvm_object_utils(dce_exc_ops_error_seq)
	
	task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "dce_exc_ops_error_seq", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();

	fork
		begin
		 	wait_for_sysrsp();
 		 	populate_available_agentsq();
			send_directed_cmdreq_txn(m_proxy_cache_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdUnq,0);
		  	@(m_scb.e_attid_dealloc);
			send_directed_cmdreq_txn(m_exc_masterq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdVld,0);
		  	@(m_scb.e_attid_dealloc);
			send_directed_cmdreq_txn(m_exc_masterq[0],m_dce_cntr.m_unq_addrq[0], eCmdClnUnq,0);
		  	@(m_scb.e_attid_dealloc);
			ev_last_cmdreq_issued.trigger();
			
		end
		begin
        			receive_cmdupdrsp_txns(3);
			
		end
	join_any
	`uvm_info("DCE_MST_SEQ", "dce_exc_ops_error_seq", UVM_NONE)
	endtask: body
endclass : dce_exc_ops_error_seq
	
class dce_alloc_nonalloc_back_pressure_seq extends dce_default_mst_seq;
	`uvm_object_utils(dce_alloc_nonalloc_back_pressure_seq)
	task body();
 			`ASSERT(m_handles_fwded && m_seqrs_fwded);
    			`uvm_info("DCE_MST_SEQ", "dce_alloc_nonalloc_back_pressure_seq", UVM_NONE)
 		 	populate_unique_addrq();
		 	send_sysreq_attach();

	fork
		begin
		 	wait_for_sysrsp();
 		 	populate_available_agentsq();
			for(int i=0; i < 10;i++) begin
				send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq[i], eCmdRdNITC,0);
			end
			#(<%=obj.Clocks[0].params.period%>ps * 10);
			while (m_scb.m_dce_txnq.size() != 0) begin // Adding this to wait for all the commands to finish
				#<%=obj.Clocks[0].params.period%>ps;
    			end
			for(int i=0; i < 10;i++) begin
				send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq[i], eCmdRdVld,0);
			end
			#(<%=obj.Clocks[0].params.period%>ps * 10);
			while (m_scb.m_dce_txnq.size() != 0) begin // Adding this to wait for all the commands to finish
				#<%=obj.Clocks[0].params.period%>ps;
    			end
			if(m_ch_agentq.size() > 1) begin
				for(int i=0; i < 10;i++) begin
					send_directed_cmdreq_txn(m_ch_agentq[1],m_dce_cntr.m_unq_addrq[i], eCmdRdNITC,0);
				end
			end
			else begin
				for(int i=0; i < 10;i++) begin
					send_directed_cmdreq_txn(m_nc_agentq[0],m_dce_cntr.m_unq_addrq[i], eCmdRdNITC,0);
				end
			end
			#(<%=obj.Clocks[0].params.period%>ps * 10);
			while (m_scb.m_dce_txnq.size() != 0) begin // Adding this to wait for all the commands to finish
				#<%=obj.Clocks[0].params.period%>ps;
    			end
			for(int i=0; i < 10;i++) begin
				send_directed_cmdreq_txn(m_ch_agentq[0],m_dce_cntr.m_unq_addrq[i], eCmdRdVld,0);
			end
		end
		begin
        			receive_cmdupdrsp_txns(40);
		end
	join_any
	`uvm_info("DCE_MST_SEQ", "dce_alloc_nonalloc_back_pressure_seq", UVM_NONE)
	endtask: body
endclass : dce_alloc_nonalloc_back_pressure_seq

class dce_dm_hit_target_as_sharer_seq extends dce_default_mst_seq;
    `uvm_object_utils(dce_dm_hit_target_as_sharer_seq)
	
	task body();
 	    `ASSERT(m_handles_fwded && m_seqrs_fwded);

        `uvm_info("DCE_MST_SEQ", "dce_dm_hit_target_as_share_seq", UVM_NONE)
 	    populate_unique_addrq();
	    send_sysreq_attach();

	    fork
	    	begin
	    	 	wait_for_sysrsp();
 	    	 	populate_available_agentsq();
                $display("KDB00 %0t m_chib_agentq=%0p m_proxy_cache_agentq=%0p m_wr_stash_masterq=%0p m_dce_cntr.m_unq_addrq=%0p", $time, m_chib_agentq, m_proxy_cache_agentq, m_wr_stash_masterq, m_dce_cntr.m_unq_addrq);

                //1. owner absent sharer present - WORKS!!
                //send_directed_cmdreq_txn(m_chib_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdCln,0);
	    	  	//@(m_scb.e_attid_dealloc);
	    		//send_directed_cmdreq_txn(m_chib_agentq[1],m_dce_cntr.m_unq_addrq[0], eCmdRdCln,0);
	    	  	//@(m_scb.e_attid_dealloc);
	    		//send_directed_cmdreq_txn(m_wr_stash_masterq[0],m_dce_cntr.m_unq_addrq[0], eCmdLdCchShd,0);
                //ev_last_cmdreq_issued.trigger();

                //2. owner absent sharer absent - exclude , not possible
                //send_directed_cmdreq_txn(m_chib_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdCln,0);
	    	  	//@(m_scb.e_attid_dealloc);
	    		//send_directed_cmdreq_txn(m_chib_agentq[1],m_dce_cntr.m_unq_addrq[0], eCmdRdCln,0);
	    	  	//@(m_scb.e_attid_dealloc);
	    		//send_directed_cmdreq_txn(m_chib_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdCln,0);
	    	  	//@(m_scb.e_attid_dealloc);
	    		//send_directed_cmdreq_txn(m_wr_stash_masterq[0],m_dce_cntr.m_unq_addrq[0], eCmdLdCchShd,0); //owner absent sharer present
	    	  	//@(m_scb.e_attid_dealloc);
                //ev_last_cmdreq_issued.trigger();

                //3. owner present sharer absent - WORKS!!
	    		//send_directed_cmdreq_txn(m_chib_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdMkUnq,0);
	    	  	//@(m_scb.e_attid_dealloc);
	    		//send_directed_cmdreq_txn(m_chib_agentq[1],m_dce_cntr.m_unq_addrq[0], eCmdRdCln,0);
	    	  	//@(m_scb.e_attid_dealloc);
	    		//send_directed_cmdreq_txn(m_wr_stash_masterq[0],m_dce_cntr.m_unq_addrq[0], eCmdLdCchShd,0); //owner absent sharer present
	    	  	//@(m_scb.e_attid_dealloc);
	    		//ev_last_cmdreq_issued.trigger();

                //4. owner present sharer present
	    		send_directed_cmdreq_txn(m_chib_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdMkUnq,0);
	    	  	@(m_scb.e_attid_dealloc);
	    		send_directed_cmdreq_txn(m_chib_agentq[1],m_dce_cntr.m_unq_addrq[0], eCmdRdCln,0);
	    	  	@(m_scb.e_attid_dealloc);
                send_directed_cmdreq_txn(m_proxy_cache_agentq[0],m_dce_cntr.m_unq_addrq[0], eCmdRdVld,0);
	    	  	@(m_scb.e_attid_dealloc);
	    		send_directed_cmdreq_txn(m_wr_stash_masterq[0],m_dce_cntr.m_unq_addrq[0], eCmdLdCchShd,0);
	    	  	@(m_scb.e_attid_dealloc);
	    		ev_last_cmdreq_issued.trigger();
	    		
	    	end
	    	begin
            	receive_cmdupdrsp_txns(4);
	    	end
	    join_any
	    `uvm_info("DCE_MST_SEQ", "dce_dm_hit_target_as_share_seq", UVM_NONE)
	endtask: body

endclass : dce_dm_hit_target_as_sharer_seq
