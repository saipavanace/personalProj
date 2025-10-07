<%  if(obj.BlockId.match('chiaiu')) { %>

`ifdef CHI_SUBSYS
class <%=obj.BlockId%>_smi_force_seq extends uvm_sequence #(smi_seq_item);
   `uvm_object_param_utils(<%=obj.BlockId%>_smi_force_seq)

   `uvm_declare_p_sequencer(<%=obj.BlockId%>_smi_force_virtual_sequencer);
    <%=obj.BlockId%>_smi_force_virtual_sequencer  m_smi_force_virtual_seqr;

    smi_sequencer         m_smi_seqr_tx_hash[string];

    function new (string name = "<%=obj.BlockId%>_smi_force_seq");
	super.new(name);
    endfunction : new
   
    task body;
   
   	<% for (var i = 0; i < obj.nSmiRx; i++) { %>
   	    <% for (var j = 0; j < obj.smiPortParams.rx[i].params.fnMsgClass.length; j++) { %>
   		m_smi_seqr_tx_hash["<%=obj.smiPortParams.rx[i].params.fnMsgClass[j]%>"] = m_smi_force_virtual_seqr.m_smi<%=i%>_tx_seqr;
   	    <% } %>
   	<% } %>
   	fork
   	<% for (var i = 0; i < obj.nSmiRx; i++) { %>
   	    begin : main_fork_<%=i%>
   		mailbox #(smi_seq_item) m_tx<%=i%>_ndp_items_mb	= new();
   		mailbox #(smi_seq_item) m_tx<%=i%>_dp_items_mb	= new();
   		<% for (var j = 0; j < obj.nSmiRx; j++) { %>
   	 	    <% for (var k = 0; k < obj.smiPortParams.rx[j].params.fnMsgClass.length; k++) { %>
   			mailbox #(smi_seq_item) m_tx<%=i%>_<%=obj.smiPortParams.rx[j].params.fnMsgClass[k]%>items_mb = new();
   		    <% } %>
   		<% } %>
   				
   		<% for (var j = 0; j < obj.nSmiRx; j++) { %>
   		    <% for (var k = 0; k < obj.smiPortParams.rx[j].params.fnMsgClass.length; k++) { %>
   			smi_seq m_tx<%=i%>_<%=obj.smiPortParams.rx[j].params.fnMsgClass[k]%>seq;
   		    <% } %>
   		<% } %>
   		
   		@(posedge m_smi_force_virtual_seqr.m_<%=i%>_vif.rst_n);
		repeat(10)  @(posedge m_smi_force_virtual_seqr.m_<%=i%>_vif.clk);
		fork 
		    begin : fork_1_collect_ndp
			forever begin : forever_1
		    	    smi_seq_item m_tx<%=i%>_ndp_item     = smi_seq_item::type_id::create("tx<%=i%>ndp_item");
			    m_smi_force_virtual_seqr.m_<%=i%>_vif.collect_ndp(m_tx<%=i%>_ndp_item);
		   	    m_tx<%=i%>_ndp_item.unpack_smi_seq_item();
		   	    m_tx<%=i%>_ndp_item.pack_smi_seq_item();
		   	    m_tx<%=i%>_ndp_items_mb.put(m_tx<%=i%>_ndp_item);
		   	    `uvm_info("FORCE_SEQ_PUT_NDP", $sformatf("ECC DEBUG D0: %p",  m_tx<%=i%>_ndp_item.convert2string()), UVM_DEBUG)
			end : forever_1
		    end : fork_1_collect_ndp
	
		    begin : fork_2_collect_dp
		    	forever begin : forever_2
		    	    smi_seq_item m_tx<%=i%>_dp_item = smi_seq_item::type_id::create("tx<%=i%>dp_item");
		    	    m_smi_force_virtual_seqr.m_<%=i%>_vif.collect_dp(m_tx<%=i%>_dp_item);
		    	    m_tx<%=i%>_dp_item.unpack_smi_seq_item();
		    	    m_tx<%=i%>_dp_item.pack_smi_seq_item();
		    	    m_tx<%=i%>_dp_items_mb.put(m_tx<%=i%>_dp_item);
		    	    `uvm_info("FORCE_SEQ_PUT_DP", $sformatf("ECC DEBUG D0: %p",  m_tx<%=i%>_dp_item.convert2string()), UVM_DEBUG)
		    	end : forever_2
		    end : fork_2_collect_dp
	
		    begin : fork_3
		    	forever begin : forever_3
		    	    smi_seq_item m_tx<%=i%>_tmp_item            = smi_seq_item::type_id::create("m_tx<%=i%>_tmp_item");
	
		    	    m_tx<%=i%>_ndp_items_mb.get(m_tx<%=i%>_tmp_item);
	
		    	    case(m_tx<%=i%>_tmp_item.smi_msg_type) inside 
		    		['h41:'h51] : begin
		    						m_tx<%=i%>_snp_req_items_mb.put(m_tx<%=i%>_tmp_item);
		    		end
		    		'h7a        : begin
		    						m_tx<%=i%>_str_req_items_mb.put(m_tx<%=i%>_tmp_item);
		    		end
		    		'h7b        : begin
		    						m_tx<%=i%>_sys_req_rx_items_mb.put(m_tx<%=i%>_tmp_item);
		    		end
		    		['hf0:'hf1] : begin
		    						m_tx<%=i%>_cmd_rsp_items_mb.put(m_tx<%=i%>_tmp_item);
		    		end
		    		'hf3        : begin
		    						m_tx<%=i%>_dtw_rsp_items_mb.put(m_tx<%=i%>_tmp_item);
		    		end
		    		'hf4        : begin
		    						m_tx<%=i%>_dtr_rsp_rx_items_mb.put(m_tx<%=i%>_tmp_item);
		    		end
		    		'hfb        : begin
		    						m_tx<%=i%>_sys_rsp_rx_items_mb.put(m_tx<%=i%>_tmp_item);
		    		end
		    		'hfc        : begin
		    						m_tx<%=i%>_cmp_rsp_items_mb.put(m_tx<%=i%>_tmp_item);
		    		end
		    		'hff        : begin
		    						m_tx<%=i%>_dtw_dbg_rsp_items_mb.put(m_tx<%=i%>_tmp_item);
		    		end
		    		['h80:'h84] : begin
		    						m_tx<%=i%>_dtr_req_rx_items_mb.put(m_tx<%=i%>_tmp_item);
		    		end
		    	    endcase
		    	end : forever_3
		    end : fork_3
					
		    begin : fork_4_snp_req
			forever begin : forever_4
			    smi_seq_item m_tx<%=i%>_snp_req_item = smi_seq_item::type_id::create("m_tx<%=i%>_snp_req_item");
			    m_tx<%=i%>_snp_req_seq    = smi_seq::type_id::create("m_tx<%=i%>_snp_req_seq");
			    m_tx<%=i%>_snp_req_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
			    m_tx<%=i%>_snp_req_items_mb.get(m_tx<%=i%>_snp_req_item);
			    m_tx<%=i%>_snp_req_seq.m_seq_item = m_tx<%=i%>_snp_req_item;
			    m_tx<%=i%>_snp_req_seq.return_response(m_smi_seqr_tx_hash["snp_req_"]);
			end : forever_4
		    end : fork_4_snp_req

	     	     begin : fork_5_str_req
			forever begin : forever_5
			    smi_seq_item m_tx<%=i%>_str_req_item = smi_seq_item::type_id::create("m_tx<%=i%>_str_req_item");
			    m_tx<%=i%>_str_req_seq    = smi_seq::type_id::create("m_tx<%=i%>_str_req_seq");
			    m_tx<%=i%>_str_req_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
			    m_tx<%=i%>_str_req_items_mb.get(m_tx<%=i%>_str_req_item);
			    if (($test$plusargs("strreq_cmstatus_with_error")) && (m_tx<%=i%>_str_req_item.smi_src_ncore_unit_id >= DCE_FUNIT_IDS[0]) && 
                                  		 (m_tx<%=i%>_str_req_item.smi_src_ncore_unit_id  <= DCE_FUNIT_IDS[<%=obj.DceInfo.length-1%>])) begin
                                m_tx<%=i%>_str_req_item.smi_cmstatus  = 	8'b10000100;
                            	m_tx<%=i%>_str_req_item.smi_ndp[15:8] = 	8'b10000100;
			       	m_smi_force_virtual_seqr.m_<%=obj.BlockId%>_probe_vif.force_smi<%=i%>_cmstatus_strreq_<%=obj.BlockId%>(m_tx<%=i%>_str_req_item.smi_ndp[15:8]);
			    end
			    m_tx<%=i%>_str_req_seq.m_seq_item = m_tx<%=i%>_str_req_item;
                	    m_tx<%=i%>_str_req_seq.return_response(m_smi_seqr_tx_hash["str_req_"]);							
			    if (($test$plusargs("strreq_cmstatus_with_error")) && (m_tx<%=i%>_str_req_item.smi_src_ncore_unit_id >= DCE_FUNIT_IDS[0]) &&
                                   		(m_tx<%=i%>_str_req_item.smi_src_ncore_unit_id  <= DCE_FUNIT_IDS[<%=obj.DceInfo.length-1%>])) begin
                                @(posedge m_smi_force_virtual_seqr.m_<%=obj.BlockId%>_probe_vif.clk);
			    	m_smi_force_virtual_seqr.m_<%=obj.BlockId%>_probe_vif.release_smi<%=i%>_cmstatus_strreq_<%=obj.BlockId%>();
			    end
			end : forever_5
		    end : fork_5_str_req
		
		    begin : fork_6_sys_req
			forever begin : forever_6
			    smi_seq_item m_tx<%=i%>_sys_req_rx_item = smi_seq_item::type_id::create("m_tx<%=i%>_sys_req_rx_item");
			    m_tx<%=i%>_sys_req_rx_seq    = smi_seq::type_id::create("m_tx<%=i%>_sys_req_rx_seq");
			    m_tx<%=i%>_sys_req_rx_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
			    m_tx<%=i%>_sys_req_rx_items_mb.get(m_tx<%=i%>_sys_req_rx_item);
			    m_tx<%=i%>_sys_req_rx_seq.m_seq_item = m_tx<%=i%>_sys_req_rx_item;
                	    m_tx<%=i%>_sys_req_rx_seq.return_response(m_smi_seqr_tx_hash["sys_req_rx_"]);							
			end : forever_6
		    end : fork_6_sys_req
					
		    begin : fork_7_cmd_rsp
			forever begin : forever_7
			    smi_seq_item m_tx<%=i%>_cmd_rsp_item = smi_seq_item::type_id::create("m_tx<%=i%>_cmd_rsp_item");
			    m_tx<%=i%>_cmd_rsp_seq    = smi_seq::type_id::create("m_tx<%=i%>_cmd_rsp_seq");
			    m_tx<%=i%>_cmd_rsp_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
			    m_tx<%=i%>_cmd_rsp_items_mb.get(m_tx<%=i%>_cmd_rsp_item);
			    m_tx<%=i%>_cmd_rsp_seq.m_seq_item = m_tx<%=i%>_cmd_rsp_item;
                	    m_tx<%=i%>_cmd_rsp_seq.return_response(m_smi_seqr_tx_hash["cmd_rsp_"]);							
			end : forever_7
	    	    end : fork_7_cmd_rsp
		
	    	    begin : fork_8_dtw_rsp
			forever begin : forever_8
			    smi_seq_item m_tx<%=i%>_dtw_rsp_item = smi_seq_item::type_id::create("m_tx<%=i%>_dtw_rsp_item");
			    m_tx<%=i%>_dtw_rsp_seq    = smi_seq::type_id::create("m_tx<%=i%>_dtw_rsp_seq");
			    m_tx<%=i%>_dtw_rsp_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
			    m_tx<%=i%>_dtw_rsp_items_mb.get(m_tx<%=i%>_dtw_rsp_item);
			    if ($test$plusargs("dtwrsp_cmstatus_with_error")) begin
                            	std::randomize(m_tx<%=i%>_dtw_rsp_item.smi_cmstatus) with { m_tx<%=i%>_dtw_rsp_item.smi_cmstatus inside {8'b10000100,8'b10000011};};
			        m_smi_force_virtual_seqr.m_<%=obj.BlockId%>_probe_vif.force_smi<%=i%>_dtwrsp_<%=obj.BlockId%>(m_tx<%=i%>_dtw_rsp_item.smi_cmstatus);
			    end
			    m_tx<%=i%>_dtw_rsp_seq.m_seq_item = m_tx<%=i%>_dtw_rsp_item;
                	    m_tx<%=i%>_dtw_rsp_seq.return_response(m_smi_seqr_tx_hash["dtw_rsp_"]);							
			    if ($test$plusargs("dtwrsp_cmstatus_with_error")) begin
                                @(posedge m_smi_force_virtual_seqr.m_<%=obj.BlockId%>_probe_vif.clk);
			        m_smi_force_virtual_seqr.m_<%=obj.BlockId%>_probe_vif.release_smi<%=i%>_dtwrsp_<%=obj.BlockId%>();
			    end
			end : forever_8
		    end : fork_8_dtw_rsp
		
		    begin : fork_9_dtr_rsp
			forever begin : forever_9
			    smi_seq_item m_tx<%=i%>_dtr_rsp_rx_item = smi_seq_item::type_id::create("m_tx<%=i%>_dtr_rsp_rx_item");
			    m_tx<%=i%>_dtr_rsp_rx_seq    = smi_seq::type_id::create("m_tx<%=i%>_dtr_rsp_rx_seq");
			    m_tx<%=i%>_dtr_rsp_rx_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
			    m_tx<%=i%>_dtr_rsp_rx_items_mb.get(m_tx<%=i%>_dtr_rsp_rx_item);
			    m_tx<%=i%>_dtr_rsp_rx_seq.m_seq_item = m_tx<%=i%>_dtr_rsp_rx_item;
                	    m_tx<%=i%>_dtr_rsp_rx_seq.return_response(m_smi_seqr_tx_hash["dtr_rsp_rx_"]);							
			end : forever_9
		    end : fork_9_dtr_rsp
					
		    begin : fork_10_sys_rsp
		    	forever begin : forever_10
		    	    smi_seq_item m_tx<%=i%>_sys_rsp_rx_item = smi_seq_item::type_id::create("m_tx<%=i%>_sys_rsp_rx_item");
		    	    m_tx<%=i%>_sys_rsp_rx_seq    = smi_seq::type_id::create("m_tx<%=i%>_sys_rsp_rx_seq");
		    	    m_tx<%=i%>_sys_rsp_rx_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
		    	    m_tx<%=i%>_sys_rsp_rx_items_mb.get(m_tx<%=i%>_sys_rsp_rx_item);
		    	    m_tx<%=i%>_sys_rsp_rx_seq.m_seq_item = m_tx<%=i%>_sys_rsp_rx_item;
                    	    m_tx<%=i%>_sys_rsp_rx_seq.return_response(m_smi_seqr_tx_hash["sys_rsp_rx_"]);							
		    	end : forever_10
		    end : fork_10_sys_rsp
		    
		    begin : fork_11_cmp_rsp
		    	forever begin : forever_11
		    	    smi_seq_item m_tx<%=i%>_cmp_rsp_item = smi_seq_item::type_id::create("m_tx<%=i%>_cmp_rsp_item");
		    	    m_tx<%=i%>_cmp_rsp_seq    = smi_seq::type_id::create("m_tx<%=i%>_cmp_rsp_seq");
		    	    m_tx<%=i%>_cmp_rsp_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
		    	    m_tx<%=i%>_cmp_rsp_items_mb.get(m_tx<%=i%>_cmp_rsp_item);
			    if ($test$plusargs("cmprsp_cmstatus_with_error")) begin
                                m_tx<%=i%>_cmp_rsp_item.smi_cmstatus = 	8'b10000100;
			    	m_smi_force_virtual_seqr.m_<%=obj.BlockId%>_probe_vif.force_smi<%=i%>_cmprsp_<%=obj.BlockId%>(m_tx<%=i%>_cmp_rsp_item.smi_cmstatus);
                            end
		    	    m_tx<%=i%>_cmp_rsp_seq.m_seq_item = m_tx<%=i%>_cmp_rsp_item;
                    	    m_tx<%=i%>_cmp_rsp_seq.return_response(m_smi_seqr_tx_hash["cmp_rsp_"]);							
			    if ($test$plusargs("cmprsp_cmstatus_with_error")) begin
                                @(posedge m_smi_force_virtual_seqr.m_<%=obj.BlockId%>_probe_vif.clk);
			        m_smi_force_virtual_seqr.m_<%=obj.BlockId%>_probe_vif.release_smi<%=i%>_cmprsp_<%=obj.BlockId%>();
                            end
		    	end : forever_11
		    end : fork_11_cmp_rsp
		    
		    begin : fork_12_dtw_dbg_rsp
		    	forever begin : forever_12
		    	    smi_seq_item m_tx<%=i%>_dtw_dbg_rsp_item = smi_seq_item::type_id::create("m_tx<%=i%>_dtw_dbg_rsp_item");
		    	    m_tx<%=i%>_dtw_dbg_rsp_seq    = smi_seq::type_id::create("m_tx<%=i%>_dtw_dbg_rsp_seq");
		    	    m_tx<%=i%>_dtw_dbg_rsp_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
		    	    m_tx<%=i%>_dtw_dbg_rsp_items_mb.get(m_tx<%=i%>_dtw_dbg_rsp_item);
		    	    m_tx<%=i%>_dtw_dbg_rsp_seq.m_seq_item = m_tx<%=i%>_dtw_dbg_rsp_item;
                    	    m_tx<%=i%>_dtw_dbg_rsp_seq.return_response(m_smi_seqr_tx_hash["dtw_dbg_rsp_"]);							
		    	end : forever_12
		    end : fork_12_dtw_dbg_rsp
					
		    begin : fork_13_dtr_req_rx
		    	forever begin : forever_13
		    	    smi_seq_item m_tx<%=i%>_every_beat_item 	= smi_seq_item::type_id::create("m_tx<%=i%>_every_beat_item");
		    	    smi_seq_item m_tx<%=i%>_dtr_req_rx_item = smi_seq_item::type_id::create("m_tx<%=i%>_dtr_req_rx_item");
		    	    m_tx<%=i%>_dtr_req_rx_seq    = smi_seq::type_id::create("m_tx<%=i%>_dtr_req_rx_seq");
		    	    m_tx<%=i%>_dtr_req_rx_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
		    	    m_tx<%=i%>_dtr_req_rx_items_mb.get(m_tx<%=i%>_dtr_req_rx_item);
			    if (m_tx<%=i%>_dtr_req_rx_item.hasDP()) begin
		                bit first_pkt = 1;
			        if ($test$plusargs("dtrreq_cmstatus_with_error")) begin
                                    std::randomize(m_tx<%=i%>_dtr_req_rx_item.smi_cmstatus) with { m_tx<%=i%>_dtr_req_rx_item.smi_cmstatus inside {8'b10000100,8'b10000011};};
			            m_smi_force_virtual_seqr.m_<%=obj.BlockId%>_probe_vif.force_smi<%=i%>_dtrreq_<%=obj.BlockId%>( m_tx<%=i%>_dtr_req_rx_item.smi_cmstatus);
			        end
                                do begin
                                    smi_seq_item m_tx<%=i%>_tmp_data_item = smi_seq_item::type_id::create("m_tx<%=i%>_tmp_data_item");
			            if(first_pkt) begin
                                    	m_tx<%=i%>_dp_items_mb.get(m_tx<%=i%>_tmp_data_item);
                                        $cast(m_tx<%=i%>_every_beat_item, m_tx<%=i%>_dtr_req_rx_item.clone());
                                        m_tx<%=i%>_every_beat_item.do_copy_one_beat_data_zero_out(m_tx<%=i%>_tmp_data_item);
			                first_pkt = 0;
			            end else begin
                                    	m_tx<%=i%>_dp_items_mb.get(m_tx<%=i%>_tmp_data_item);
                                        `uvm_info("FORCE_SEQ_GET_DP", $sformatf("ECC DEBUG S0: %p",  m_tx<%=i%>_tmp_data_item), UVM_LOW)
                                        $cast(m_tx<%=i%>_every_beat_item, m_tx<%=i%>_tmp_data_item.clone());
                                        m_tx<%=i%>_every_beat_item.smi_dp_present = 1;  
			            end
                                    m_tx<%=i%>_every_beat_item.unpack_dp_smi_seq_item();
            	                    m_tx<%=i%>_every_beat_item.pack_smi_seq_item();
                                    m_tx<%=i%>_dtr_req_rx_seq.m_seq_item = m_tx<%=i%>_every_beat_item;
                                    m_tx<%=i%>_dtr_req_rx_seq.return_response(m_smi_seqr_tx_hash["dtr_req_rx_"]);
                             	end while (m_tx<%=i%>_every_beat_item.smi_dp_last == 0);
			        if ($test$plusargs("dtrreq_cmstatus_with_error")) begin
                                    @(posedge m_smi_force_virtual_seqr.m_<%=obj.BlockId%>_probe_vif.clk);
			            m_smi_force_virtual_seqr.m_<%=obj.BlockId%>_probe_vif.release_smi<%=i%>_dtrreq_<%=obj.BlockId%>();
			        end       
                            end
		    	end : forever_13
		    end : fork_13_dtr_req_rx
		join
	    end : main_fork_<%=i%>
	<% } %>
	join
    endtask
endclass
`endif
<% } %>


