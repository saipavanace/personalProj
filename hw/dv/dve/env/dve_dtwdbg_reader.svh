class dve_dtwdbg_reader extends uvm_component;
  `uvm_component_utils(dve_dtwdbg_reader)
  int last_trace_processed = -1;
  int evtfirst;
  int evtsecond;
  bit a;
  bit b;
  uvm_analysis_port #(dve_debug_txn) dbg_txn_ap;

  <% if(obj.testBench == 'dve'){ %>
   ral_sys_ncore        m_regs;
  <% } else if(obj.testBench == 'fsys'|| obj.testBench == 'emu') { %>
  concerto_register_map_pkg::ral_sys_ncore m_regs;
  <% } else if(obj.testBench == 'cust_tb') { %>
   ral_sys_ncore        m_regs;
   <%}%>
   
  <% if(obj.testBench == 'fsys' || obj.testBench == 'cust_tb'){ 
  
  // find a legal AIU to route CSR requests through. Its index will be ioaiu_idx throughout the file.
     // this will probably be a CHIAIU, and it will have fnCsrAccess
     var ioaiu_idx = 0;
     var chiaiu_idx = 0;
     var which = "";
     for(var idx = 0; idx < obj.nAIUs; idx++) {
       if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
         if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
           ioaiu<%=ioaiu_idx%>_axi_agent_pkg::axi_virtual_sequencer m_inject_vseqr; <%
           which = "ioaiu";
           break;
         }
         ioaiu_idx++;
       } else {
         if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
           //chiaiu<%=chiaiu_idx%>_chi_agent_pkg::chi_virtual_sequencer m_inject_vseqr; <%
           which = "chiaiu";
           //break; // don't break try to find ioaiu with fnCsrAccess
          }
         chiaiu_idx++;
       }
     }
     if(which === "") {
       throw "dve_dtwdbg_reader: could not find an AIU with fnCsrAccess";
     } %>
<% } %>
  uvm_status_e           status;

  uvm_reg_data_t         rd_data,wr_data;
  uvm_reg_data_t         data;
  uvm_reg_data_t         field_rd_data;

  bit filling_buffer = 1'b1;
  bit circular = 1'b0;
  bit objecting = 1'b0;

  function new(string name="", uvm_component parent);
      super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      dbg_txn_ap = new("dbg_txn_ap", this);
      filling_buffer = $test$plusargs("dve_dtw_dbg_loss");
      circular = $test$plusargs("dve_dtw_dbg_circular");
  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
<% if(obj.testBench == 'fsys' || obj.testBench == 'cust_tb') { 
     if(which === "ioaiu") { %>
      uvm_config_db#(ioaiu<%=ioaiu_idx%>_axi_agent_pkg::axi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=ioaiu_idx%>" ),.value( m_inject_vseqr ) );
     <% } else if(which === "chiaiu") { %>
     // do nothing: this is a stub
     <% } else { %>
      uvm_config_db#(chiaiu<%=chiaiu_idx%>_chi_agent_pkg::chi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_chiaiu_vseqr<%=chiaiu_idx%>" ),.value( m_inject_vseqr ) );
     <% } %>
<% } %>
  endfunction: connect_phase


  /////////////////////////////////////////////////////////////
  // Stolen from ral_csr_base seq

    ////////////////////////////////////////////////////////////////////////////////
    //helpers

    function void compareValues(string one, string two, int data1, int data2);
        if (data1 == data2) begin
            `uvm_info("RUN_MAIN",$sformatf("%s:0x%x, expd %s:0x%0x OKAY", one, data1, two, data2), UVM_MEDIUM)
        end else begin
            `uvm_error("RUN_MAIN",$sformatf("Mismatch %s:0x%0x, expd %s:0x%0x",one, data1, two, data2));
        end
    endfunction // compareValues

    function uvm_reg_data_t mask_data(int lsb, int msb);
        uvm_reg_data_t mask_data_val = 0;

        for(int i=0;i<32;i++)begin
            if(i>=lsb &&  i<=msb)begin
                mask_data_val[i] = 1;     
            end
        end
        //$display("func maskdataval:0x%0x",mask_data_val);
        return mask_data_val;
    endfunction:mask_data

    ////////////////////////////////////////////////////////////////////////////////
    //accessors

    task write_csr(uvm_reg_field field, uvm_reg_data_t wr_data);
        int lsb, msb;
        uvm_reg_data_t mask;
<% if(obj.testBench == 'dve') { %>
        field.get_parent().read(status, field_rd_data/*, .parent(this)*/);
<% } else if(obj.testBench == 'fsys' || obj.testBench == 'cust_tb') { %>
        read_csr_fsys(field.get_parent().get_address(), field_rd_data);
<% } %>
        lsb = field.get_lsb_pos();
        msb = lsb + field.get_n_bits() - 1;
        `uvm_info("CSR Ralgen Base Seq", $sformatf("Write %s lsb=%0d msb=%0d", field.get_name(), lsb, msb), UVM_MEDIUM);
        // and with actual field bits 0
        mask = mask_data(lsb, msb);
        //$display("mask:0x%0x",mask);
        mask = ~mask;
        field_rd_data = field_rd_data & mask;
        // shift write data to appropriate position
        wr_data = wr_data << lsb;
        // then or with this data to get value to write
        wr_data = field_rd_data | wr_data;
<% if(obj.testBench == 'dve') { %>
        field.get_parent().write(status, wr_data/*, .parent(this)*/);
<% } else if(obj.testBench == 'fsys' || obj.testBench == 'cust_tb') { %>
        write_csr_fsys(field.get_parent().get_address(), wr_data);
<% } %>
    endtask : write_csr

    task read_csr(uvm_reg_field field, output uvm_reg_data_t fieldVal);
        int lsb, msb;
        uvm_reg_data_t mask;
<% if(obj.testBench == 'dve') { %>
        field.get_parent().read(status, field_rd_data/*, .parent(this)*/);
<% } else if(obj.testBench == 'fsys' || obj.testBench == 'cust_tb') { %>
        read_csr_fsys(field.get_parent().get_address(), field_rd_data);
<% } %>
        lsb = field.get_lsb_pos();
        msb = lsb + field.get_n_bits() - 1;
        `uvm_info("CSR Ralgen Base Seq", $sformatf("Read %s lsb=%0d msb=%0d", field.get_name(), lsb, msb), UVM_MEDIUM);
        //$display("rd_data:0x%0x",field_rd_data);
        // AND other bits to 0
        mask = mask_data(lsb, msb);
        //$display("mask:0x%0x",mask);
        field_rd_data = field_rd_data & mask;
        //$display("masked data:0x%0x",field_rd_data);
        // shift read data by lsb to return field
        fieldVal = field_rd_data >> lsb;
        //$display("fieldVal:0x%0x",fieldVal);
    endtask : read_csr

    task poll_csr(uvm_reg_field field, bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        int timeout;
        timeout = 5000;
        do begin
            timeout -=1;
            read_csr(field, fieldVal);
            //fieldVal = field_rd_data;
            `uvm_info("CSR Ralgen Base Seq", $sformatf("%s poll_till=0x%0x fieldVal=0x%0x timeout=%0d", field.get_name(), poll_till, fieldVal, timeout), UVM_NONE);
        end while ((fieldVal != poll_till) && (timeout != 0)); // UNMATCHED !!
        if (timeout == 0) begin
            `uvm_error("CSR Ralgen Base Seq", $sformatf("Timeout! Polling %s, poll_till=0x%0x fieldVal=0x%0x", field.get_name(), poll_till, fieldVal))
        end
    endtask : poll_csr

<% if(obj.testBench == 'fsys' || obj.testBench == 'cust_tb') { %>

// ported from concerto_base_test
<% if(which === "ioaiu") { %>
task write_csr_fsys(input ioaiu<%=ioaiu_idx%>_axi_agent_pkg::axi_axaddr_t addr, bit[31:0] data, bit nonblocking=0);
    ioaiu<%=ioaiu_idx%>_inhouse_axi_bfm_pkg::axi_single_wrnosnp_seq m_inject_seq;
    bit [ioaiu<%=ioaiu_idx%>_axi_agent_pkg::WXDATA-1:0] wdata;
    int addr_mask;
    int addr_offset;

    addr_mask = (ioaiu<%=ioaiu_idx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
    
    m_inject_seq = ioaiu<%=ioaiu_idx%>_inhouse_axi_bfm_pkg::axi_single_wrnosnp_seq::type_id::create("m_inject_seq");

    if(nonblocking == 0) begin
        m_inject_seq.m_addr = addr;
        m_inject_seq.use_awid = 0;
        m_inject_seq.m_axlen = 0;
        m_inject_seq.m_size  = 3'b010;
        m_inject_seq.m_data[(addr_offset*8)+:32] = data;
        m_inject_seq.m_wstrb = 32'hF<<addr_offset; // Assuming (ioaiu<%=ioaiu_idx%>_axi_agent_pkg::WXDATA/8) < 32
        m_inject_seq.start(m_inject_vseqr);
    end else begin
    fork
        begin
        m_inject_seq.m_addr = addr;
        m_inject_seq.use_awid = 0;
        m_inject_seq.m_axlen = 0;
        m_inject_seq.m_size  = 3'b010;
        m_inject_seq.m_data[(addr_offset*8)+:32] = data;
        m_inject_seq.m_wstrb = 32'hF<<addr_offset; // Assuming (ioaiu<%=ioaiu_idx%>_axi_agent_pkg::WXDATA/8) < 32
        m_inject_seq.start(m_inject_vseqr);
        end
    join_none
    end // else: !if(nonblocking == 0)
endtask : write_csr_fsys
<% } else if(which === "chiaiu") { %>
task write_csr_fsys(input bit[31:0] addr, bit[31:0] data, bit nonblocking=0);
    // this isn't yet supported: fake it
    `uvm_info(get_name(), $psprintf("Faking CHIAIU write %8h to DVE address %8h", data, addr), UVM_DEBUG)
endtask: write_csr_fsys
<% } else { %>
task write_csr_fsys(input chiaiu<%=chiaiu_idx%>_chi_agent_pkg::chi_addr_t addr, bit[31:0] data, bit nonblocking=0);
    chiaiu<%=chiaiu_idx%>_inhouse_chi_bfm_pkg::chi_single_wrnosnp_seq m_inject_seq;
    bit [chiaiu<%=chiaiu_idx%>_chi_agent_pkg::WXDATA-1:0] wdata;
    int addr_mask;
    int addr_offset;

    addr_mask = (chiaiu<%=chiaiu_idx%>_chi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
    
    m_inject_seq = chiaiu<%=chiaiu_idx%>_inhouse_chi_bfm_pkg::chi_single_wrnosnp_seq::type_id::create("m_inject_seq");
endtask: write_csr_fsys
<% } %>

<% if(which === "ioaiu") { %>
task read_csr_fsys(input ioaiu<%=ioaiu_idx%>_axi_agent_pkg::axi_axaddr_t addr, output bit[31:0] data);
    ioaiu<%=ioaiu_idx%>_inhouse_axi_bfm_pkg::axi_single_rdnosnp_seq m_inject_seq;
    bit [ioaiu<%=ioaiu_idx%>_axi_agent_pkg::WXDATA-1:0] wdata;
    int addr_mask;
    int addr_offset;
    bit [ioaiu<%=ioaiu_idx%>_axi_agent_pkg::WXDATA-1:0] rdata;
    ioaiu<%=ioaiu_idx%>_axi_agent_pkg::axi_rresp_t rresp;

    addr_mask = (ioaiu<%=ioaiu_idx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
    
    m_inject_seq = ioaiu<%=ioaiu_idx%>_inhouse_axi_bfm_pkg::axi_single_rdnosnp_seq::type_id::create("m_inject_seq");
    m_inject_seq.m_addr = addr;
    m_inject_seq.use_arid = 0;
    m_inject_seq.m_axlen =  0;
    m_inject_seq.start(m_inject_vseqr);

    rdata = (m_inject_seq.m_seq_item.m_has_data) ? m_inject_seq.m_seq_item.m_read_data_pkt.rdata[0] : 0;
    data = rdata[(addr_offset*8)+:32];
    rresp =  (m_inject_seq.m_seq_item.m_has_data) ? m_inject_seq.m_seq_item.m_read_data_pkt.rresp : 0;
    if(rresp) begin
        `uvm_error("READ_CSR",$sformatf("Resp_err :0x%0h on Read Data",rresp))
    end
endtask : read_csr_fsys
<% } else if(which === "chiaiu") { %>
task read_csr_fsys(input bit [31:0] addr, output bit[31:0] data);
    data = $urandom();
    `uvm_info(get_name(), $psprintf("Faking CHIAIU write %8h to DVE address %8h", data, addr), UVM_DEBUG)
endtask: read_csr_fsys
<% } else { %>
task read_csr_fsys(input chiaiu<%=chiaiu_idx%>_chi_agent_pkg::chi_addr_t addr, output bit[31:0] data);
    chiaiu<%=chiaiu_idx%>_inhouse_chi_bfm_pkg::chi_single_rdnosnp_seq m_inject_seq;
    bit [chiaiu<%=chiaiu_idx%>_chi_agent_pkg::WXDATA-1:0] wdata;
    int addr_mask;
    int addr_offset;
    bit [chiaiu<%=chiaiu_idx%>_chi_agent_pkg::WXDATA-1:0] rdata;
    chiaiu<%=chiaiu_idx%>_chi_agent_pkg::chi_rresp_t rresp;

    addr_mask = (chiaiu<%=chiaiu_idx%>_chi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;

    m_inject_seq = chiaiu<%=chiaiu_idx%>_inhouse_chi_bfm_pkg::chi_single_rdnosnp_seq::type_id::create("m_inject_seq");
endtask: read_csr_fsys
<% } %>
<% } // end obj.testBench == 'fsys' %>

  task body(uvm_phase phase);
    bit buffer_empty = 1'b1;
    bit buffer_full = 1'b0;
    bit data_ready = 1'b0;
    dve_debug_txn txn = new;
    txn.circular = circular;
    //***************************************
    // If we are waiting for full, do nothing
    //***************************************
    read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETASCR.BufferIsFull, buffer_full);
    txn.full = buffer_full;
    if(filling_buffer) begin
      if(!buffer_full) begin
        return;
      end else begin
        filling_buffer = 1'b0;
        txn.dropping = 1'b1;
        phase.drop_objection(this, "Done waiting for buffer fill");
      end
    end else begin
      txn.dropping = buffer_full;
    end
    //***************************************
    // If there isn't new data, do nothing
    //***************************************
    read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETASCR.BufferIsEmpty, buffer_empty);
    txn.empty = buffer_empty;
    `uvm_info(get_name(), $sformatf("Read DVETASCR.BufferIsEmpty = %0h", buffer_empty), UVM_NONE)
    if(buffer_empty) begin
      // There are no new trace messages we want to process.
      // TODO: we need to be able to do manual clears.
      dbg_txn_ap.write(txn); // let the scoreboard know we're empty, for coverage
      //Refer CONC 16723::when we do analysis_port.write with empty transaction multiple times,
      //the delay in read_csr.DVETASCR.BufferIsEmpty causes false dropping of dtw_dbg_req from trace_pkt_q in dve_sb::write_dve_debug_txn.
      if(objecting) begin
        phase.drop_objection(this, "No more outstanding dtwdbgs in buffer");
        objecting = 1'b0;
      end
      return;
    end
    if(!objecting) begin
      phase.raise_objection(this, "Outstanding dtwdbgs in buffer");
      objecting = 1'b1;
    end

    //*******************************
    // State machine operation
    //*******************************
    // #Stimulus.DVE.v3.2.ReadOut
    // Prevent interruption while doing this
    phase.raise_objection(this, "<%=obj.BlockId%>_dve_dtwdbg_reader: starting read out");
    // Trigger the state machine by writing xTASCR[16]
    write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETASCR.BufferRead, 1'b1);

    // Wait for the state machine
    while(data_ready != 1'b1) begin
      #1000 // TODO use a real delay here. We need 10 clocks or so.
      read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETADHR.valid, data_ready);
    end

    // Clear any data errors, now that we've seen them
    begin
      uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
      uvm_event did_read = ev_pool.get("dve_trace_mem_did_read");
      did_read.trigger();
    end

    // Grab header info
    read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETADHR.fid, txn.srcid);
    read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETADTSR.timestamp, txn.timestamp);

    //*******************************
    // Data Readout
    //*******************************
    // Read data out of CSRs and compare
    <% for(i = 0; i<16; i++) { %>
    read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETAD<%=i%>R.data, txn.data[<%=i%>]);
    <% } %>

    //*******************************
    // Push txn into analysis port
    //*******************************
    dbg_txn_ap.write(txn);
    phase.drop_objection(this, "<%=obj.BlockId%>_dve_dtwdbg_reader: finishing read out");
  endtask

  task run_phase(uvm_phase phase);
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event csr_init_done = ev_pool.get("dve_csr_init_done");
    bit ready = 1'b0;
    while(!ready) begin: await_initial_clear
      read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETASCR.BufferIsEmpty, ready);
    end: await_initial_clear
    `uvm_info(get_name(), $psprintf("Setting DVETASCR.BufferIsCircular = %b", circular), UVM_HIGH)
    write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVETASCR.BufferIsCircular, circular);
    // set up performance monitor
    while ( evtfirst == evtsecond ) begin 
    evtfirst = $urandom_range(22,23);
    evtsecond = $urandom_range(22,23);
    a=$urandom_range(0,1);
    b=$urandom_range(0,1);
    evtfirst = evtfirst*a;
    evtsecond = evtsecond*b;
   end
    <% if (obj.DutInfo.nPerfCounters) { %>
    read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVECNTCR0.CntEvtFirst, evtfirst);
    read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVECNTCR0.CntEvtSecond, evtsecond);
    read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVECNTCR1.CntEvtFirst, evtfirst);
    read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVECNTCR1.CntEvtSecond, evtsecond);
    write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVECNTCR0.CountEn, 1'b1);
    write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVECNTCR1.CountEn, 1'b1);
    <% } %>
    // Enable ECC error detection in errors block (DV count does not depend on this)
    write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.MemErrDetEn, $urandom());
    write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVECECR.ErrDetEn, $urandom());
    write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEIR.MemErrIntEn, $urandom());
    csr_init_done.trigger();
    if(filling_buffer) begin
      phase.raise_objection(this, "Waiting for buffer fill");
    end
    `uvm_info(get_name(), "Entering loop body", UVM_HIGH)
    forever #2000000 body(phase);
  endtask: run_phase

endclass : dve_dtwdbg_reader
