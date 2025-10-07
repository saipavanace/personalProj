typedef uvm_sequence #(uvm_sequence_item) uvm_virtual_sequence;

class ioaiu_base_vseq#(int ID = 0) extends uvm_virtual_sequence;
	`uvm_object_param_utils(ioaiu_base_vseq#(ID))

  	//Properties
  	string uname;

	ace_cache_model m_ace_cache_model;

  	//Sequences
    axi_master_pipelined_seq  	m_master_rd_wr_seq;
    
    <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE")) { %>
		axi_master_snoop_seq	m_master_snp_seq;
    <%}%>

    //io_aiu_default_reset_seq default_seq;
  	//ioaiu_csr_attach_seq     sysco_attach_seq;

	//virtual sequencer handle
	//static axi_virtual_sequencer	 	m_master_vseqr;
    // Read and write sequencers
    axi_read_addr_chnl_sequencer  m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer  m_read_data_chnl_seqr;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;

	function new(string s = "ioaiu_base_vseq");
  		super.new(s);
  		uname = $psprintf("ioaiu_base_vseq[%0d]", ID);
		`uvm_info(uname, "fn:new called", UVM_NONE)

   		m_ace_cache_model  = new();
   		//m_master_vseqr     = new();		
	    if($test$plusargs("cache_model_dbg_en")) begin //update to knob from ioaiu_unit_args
		    m_ace_cache_model.cache_model_dbg_en = 1;
		end

	endfunction: new
	
	function get_native_interface_read_chnl_seqr_handles(const ref axi_read_addr_chnl_sequencer read_addr_chnl, const ref axi_read_data_chnl_sequencer read_data_chnl);
		//m_master_vseqr.m_read_addr_chnl_seqr = read_addr_chnl;
		//m_master_vseqr.m_read_data_chnl_seqr = read_data_chnl;
    	m_read_addr_chnl_seqr = read_addr_chnl;
        m_read_data_chnl_seqr = read_data_chnl;
		
		`uvm_info(uname, "fn:get_native_interface_read_chnl_seqr_handles done", UVM_NONE)
	endfunction: get_native_interface_read_chnl_seqr_handles
	
	function get_native_interface_write_chnl_seqr_handles(const ref axi_write_addr_chnl_sequencer write_addr_chnl, const ref axi_write_data_chnl_sequencer write_data_chnl, const ref axi_write_resp_chnl_sequencer write_resp_chnl);
		m_write_addr_chnl_seqr = write_addr_chnl;
		m_write_data_chnl_seqr = write_data_chnl;
		m_write_resp_chnl_seqr = write_resp_chnl;
		`uvm_info(uname, "fn:get_native_interface_write_chnl_seqr_handles done", UVM_NONE)
	endfunction: get_native_interface_write_chnl_seqr_handles

endclass:ioaiu_base_vseq	
