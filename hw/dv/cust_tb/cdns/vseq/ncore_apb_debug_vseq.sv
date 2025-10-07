class ncore_apb_debug_vseq extends uvm_sequence;
  `uvm_object_utils(ncore_apb_debug_vseq)
  
  ral_sys_ncore regmodel;
  ral_sys_ncore debug_regmodel;
  uvm_status_e status;
  bit[31:0] data;
  int pkt_id = 0;
  ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t  csr_q[$];
  
    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
      cdnChiUvmSequencer chi_sequencer<%=idx%>;
      ncore_apb_debug_seq m_apb_debug_seq<%=idx%>;
    <%}%>

    function new (string name = "ncore_apb_debug_vseq");
        super.new(name);
    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
    <%}%>
    endfunction : new
    
    virtual task body();
    super.body();
    $cast(regmodel, this.regmodel);
    $cast(debug_regmodel, this.debug_regmodel);

     data = 'h3FF;
    <%for(let idx=0; idx<obj.AiuInfo.length; idx++){%>
        `uvm_info("ncore_apb_debug_vseq", "Enabling TX/RX capture using CCTRLR register on <%=obj.AiuInfo[idx].strRtlNamePrefix%>", UVM_NONE);
        <%if(obj.AiuInfo[idx].fnNativeInterface.includes("CHI")){%>
            debug_regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCCTRLR.write(status,data);
        <%}else{%>
             <%if(obj.AiuInfo[idx].nNativeInterfacePorts && obj.AiuInfo[idx].nNativeInterfacePorts > 1) {%>
		  <%for(let i=0; i<obj.AiuInfo[idx].nNativeInterfacePorts; i++){%>
		       debug_regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=i%>.XAIUCCTRLR.write(status,data);
		   <%}%>
	     <%}else{%>
		  debug_regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCCTRLR.write(status,data);
	     <%}%>
        <%}%>
    <%}%>
    
    <% for(let idx = 0; idx < obj.nDMIs; idx++) {%>
         `uvm_info("ncore_apb_debug_vseq", "Enabling TX/RX capture using CCTRLR register on <%=obj.DmiInfo[idx].strRtlNamePrefix%>", UVM_NONE);
         debug_regmodel.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMICCTRLR.write(status,data);
    <%}%>
    <% for(let idx = 0; idx < obj.nDIIs; idx++) {%>
         `uvm_info("ncore_apb_debug_vseq", "Enabling TX/RX capture using CCTRLR register on <%=obj.DiiInfo[idx].strRtlNamePrefix%>", UVM_NONE);
         debug_regmodel.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIICCTRLR.write(status,data);
    <%}%>
            `uvm_info("VSEQ", "Starting ncore_apb_debug_vseq", UVM_LOW);
        fork
        <% for(let idx = 0; idx < obj.nCHIs; idx++) {%>
          begin
             // send 10 transactions
             repeat(10) begin
              m_apb_debug_seq<%=idx%> = ncore_apb_debug_seq::type_id::create("m_apb_debug_seq<%=idx%>");
              m_apb_debug_seq<%=idx%>.trace_tag_val = 1;
              m_apb_debug_seq<%=idx%>.sequence_length  =  1;
              m_apb_debug_seq<%=idx%>.txn_id           = <%=idx%>;
              m_apb_debug_seq<%=idx%>.tx_OpCode = DENALI_CHI_REQOPCODE_ReadNoSnp;
              m_apb_debug_seq<%=idx%>.cache_value = 'h3c;
              m_apb_debug_seq<%=idx%>.start(chi_sequencer<%=idx%>);
             end
          end
        <%}%>
       join
    // Wait until debug information is put in the buffer
    //repeat(10000) @(posedge tb_top.sys_clk);
    `uvm_info("ncore_apb_debug_vseq", "wait until the debug information is put in DVE buffer", UVM_NONE);
    
    // Read debug packets from DVE until the buffer becomes empty again
      do begin
      // Trigger a read
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETASCR.write(status, 'h11);
      `uvm_info("ncore_apb_debug_vseq", "trigger a read", UVM_NONE);
      // read header
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETADHR.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Header for dbg pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read timestamp
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETADTSR.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Timestamp for dbg pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      
      // read datapayload 0
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD0R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 0 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 1
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD1R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 1 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 2
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD2R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 2 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 3
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD3R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 3 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 4
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD4R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 4 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 5
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD5R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 5 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 6
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD6R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 6 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 7
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD7R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 7 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 8
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD8R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 8 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 9
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD9R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 9 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 10
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD10R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 10 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 11
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD11R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 11 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 12
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD12R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 12 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 13
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD13R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 13 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 14
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD14R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 14 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      // read datapayload 15
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETAD15R.read(status, data);
      `uvm_info("ncore_apb_debug_vseq", $sformatf("Data Payload 15 for pkt%0d : 0x%0h", pkt_id, data), UVM_NONE);
      
      pkt_id++;
      
      // check if buffer is empty again
      debug_regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETASCR.read(status,data);
    end while(data[0] == 0);
    
    `uvm_info("ncore_apb_debug_vseq", "All debug packets are read out and buffer is empty", UVM_NONE);
        `uvm_info("VSEQ", "Finished ncore_apb_debug_vseq", UVM_LOW);
    endtask: body
endclass: ncore_apb_debug_vseq


