class ioaiu_vseq#(int ID=0) extends ioaiu_base_vseq#(ID);
	`include "<%=obj.BlockId%>_smi_widths.svh";
	`include "<%=obj.BlockId%>_smi_types.svh";
	
	`uvm_object_param_utils(ioaiu_vseq#(ID))
	
	function new(string s = "ioaiu_vseq");
  		super.new(s);
  		uname = $psprintf("ioaiu_vseq[%0d]", ID);
	endfunction: new

	task body();
		 `uvm_info(uname, "Start IOAIU VSEQ", UVM_NONE)
		m_master_rd_wr_seq = axi_master_pipelined_seq::type_id::create("m_master_rd_wr_seq");
		
		//get seqr handles
		m_master_rd_wr_seq.m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
		m_master_rd_wr_seq.m_read_data_chnl_seqr = m_read_data_chnl_seqr;
		m_master_rd_wr_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
		m_master_rd_wr_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
		m_master_rd_wr_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
		
		//get cache-model handle
		m_master_rd_wr_seq.m_ace_cache_model = m_ace_cache_model;
		m_master_rd_wr_seq.k_num_read_req = 1;
		m_master_rd_wr_seq.k_num_write_req = 0;

		fork
			m_master_rd_wr_seq.start(null);
		join

	endtask:body

endclass: ioaiu_vseq
