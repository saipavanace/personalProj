//`ifndef AXI_SEQ
//`define AXI_SEQ

////////////////////////////////////////////////////////////////////////////////
//
//
//
//  Channel layer sequences
//
//
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
//
// AXI Read Address Sequence
//
////////////////////////////////////////////////////////////////////////////////

<% var this_aiu_id = obj.Id; 
if (obj.NctiAgent === 1) {
    this_aiu_id = obj.Id + obj.AiuInfo.length + obj.BridgeAiuInfo.length;
}
%>
<% var found_me      = 0;
   var my_ioaiu_id   = 0;

   for (var idx=0; idx < obj.AiuInfo.length; idx++) {
      if (obj.AiuInfo[idx].fnNativeInterface.indexOf("CHI") < 0) {
         if (obj.Id == idx) {
            found_me = 1;
         } else if (! found_me) {
            my_ioaiu_id ++;
         }   
      }
   }
%>

// semaphore s_wr_addr = new(1);
// semaphore s_wr_data = new(1);

axi_axaddr_t eviction_rd_wr_addr_q[$];
axi_axaddr_t eviction_rd_wr_full_addr_q[$];


class axi_read_addr_seq extends uvm_sequence #(axi_rd_seq_item);

    `uvm_object_param_utils(axi_read_addr_seq)

    axi_rd_seq_item                                     m_seq_item;
    ace_command_types_enum_t m_ace_rd_addr_chnl_snoop;
    bit                                                 m_constraint_snoop;
    axi_axaddr_t             m_ace_rd_addr_chnl_addr;
<% if (obj.wSecurityAttribute > 0) { %>                                             
    bit [<%=obj.wSecurityAttribute%>-1:0]               m_ace_rd_addr_chnl_security;
<% } %>                                                
    bit                                                 m_constraint_addr;
    bit                                                 should_randomize;
    bit                                                 en_partial=0;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_read_addr_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    bit success;

    if (should_randomize) begin
        m_seq_item = axi_rd_seq_item::type_id::create("m_seq_item");
    end
    start_item(m_seq_item);
    m_seq_item.m_has_addr = 1;
    if (should_randomize) begin
        if (m_constraint_addr) m_seq_item.m_read_addr_pkt.constrained_addr = 1;
        success = m_seq_item.m_read_addr_pkt.randomize() with {
            if (m_constraint_snoop == 1) m_seq_item.m_read_addr_pkt.arcmdtype == m_ace_rd_addr_chnl_snoop;
            if (m_constraint_addr  == 1) m_seq_item.m_read_addr_pkt.araddr    == m_ace_rd_addr_chnl_addr;
<% if (obj.wSecurityAttribute > 0) { %>                                             
            if (m_constraint_addr  == 1) m_seq_item.m_read_addr_pkt.arprot[1] == m_ace_rd_addr_chnl_security;
<% } %>                                                
        };
         <%if((obj.testBench == "io_aiu")) {%>
         if($test$plusargs("fixed_ioc_setindex")) begin
    	       <%for(var idx=0;idx<obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length;idx++){%>
    	       m_seq_item.m_read_addr_pkt.araddr [<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits[idx]%>] = 0;
   	       <% } %> 
               end
         <% } %> 

        if (!success) begin
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_read_addr_seq"), UVM_NONE);
        end
    end
    finish_item(m_seq_item);
endtask : body

task return_response(output axi_rd_seq_item m_return_seq_item, input uvm_sequencer_base seqr, input uvm_sequence_base parent = null);
    axi_rd_seq_item m_local_return_seq_item;
    m_local_return_seq_item = axi_rd_seq_item::type_id::create("m_local_return_seq_item");
    this.start(seqr, parent);
    m_local_return_seq_item.do_copy(m_seq_item);
    m_return_seq_item = m_local_return_seq_item;
endtask : return_response

endclass : axi_read_addr_seq

////////////////////////////////////////////////////////////////////////////////
//
// AXI Read Data Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_read_data_seq extends uvm_sequence #(axi_rd_seq_item);

    `uvm_object_param_utils(axi_read_data_seq)

    axi_rd_seq_item m_seq_item;
    bit             should_randomize;
    int             prob_ace_rd_resp_error = 0;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_read_data_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    bit success;
    bit done = 0;

    do begin
        start_item(m_seq_item);
        m_seq_item.m_has_data = 1;
        if (should_randomize) begin
            success = m_seq_item.m_read_data_pkt.randomize(); 
            if (!success) begin
                uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_read_data_seq"), UVM_NONE);
            end
            m_seq_item.m_read_data_pkt.rdata = new [m_seq_item.m_read_addr_pkt.arlen + 1];
            foreach (m_seq_item.m_read_data_pkt.rdata[i]) begin 
                axi_xdata_t tmp;
                assert(std::randomize(tmp))
                else begin
                    uvm_report_error("AXI SEQ", "Failure to randomize tmp", UVM_NONE);
                end
                m_seq_item.m_read_data_pkt.rdata[i] = tmp;
                //#Stimulus.DII.v3.protocol
                if ($urandom_range(0,100) < prob_ace_rd_resp_error) begin
                    m_seq_item.m_read_data_pkt.rresp_per_beat[i][1:0] = $urandom_range(2,3); // SLVERR:2 DECERR:3
                end
            end
        end
        m_seq_item.m_read_data_pkt.rid = m_seq_item.m_read_addr_pkt.arid;
        finish_item(m_seq_item);
        if (m_seq_item.m_has_data == 1) begin
            done = 1;
        end
    end while (!done);
endtask : body

task return_response(output axi_rd_seq_item m_return_seq_item, input uvm_sequencer_base seqr, input uvm_sequence_base parent = null);
    axi_rd_seq_item m_local_return_seq_item;
    m_local_return_seq_item = axi_rd_seq_item::type_id::create("m_local_return_seq_item");
    this.start(seqr, parent);
    m_local_return_seq_item.do_copy(m_seq_item);
    m_return_seq_item = m_local_return_seq_item;
endtask : return_response

endclass : axi_read_data_seq


////////////////////////////////////////////////////////////////////////////////
//
// AXI Write Address Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_write_addr_seq extends uvm_sequence #(axi_wr_seq_item);

    ace_command_types_enum_t m_ace_wr_addr_chnl_snoop;
    bit                                                 m_constraint_snoop;
    axi_axaddr_t             m_ace_wr_addr_chnl_addr;
<% if (obj.wSecurityAttribute > 0) { %>                                             
    bit [<%=obj.wSecurityAttribute%>-1:0]               m_ace_wr_addr_chnl_security;
<% } %>                                                
    bit                                                 m_constraint_addr;
    axi_wr_seq_item                                     m_seq_item;
    bit                                                 should_randomize;
    bit                                                 en_partial=0;
    bit                                                 isSlave = 0;
    axi_axaddr_t                                        random_unmapped_addr;
    int                                                 core_id;
    static semaphore s_wr_addr[int];

   <%if((obj.testBench == "io_aiu" && obj.useCache) && (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) {%> 
    bit[<%=Math.log2(obj.nDataBanks)%>-1:0]             sel_bank;
   <%}%>

    <% if(obj.testBench =="io_aiu" && (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) { %>

    bit[<%=(Math.log2((obj.DutInfo.nNativeInterfacePorts) * obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks))%>-1:0]             sel_ott_bank;

    <% } %>

    `uvm_object_param_utils_begin(axi_write_addr_seq)
        `uvm_field_enum (ace_command_types_enum_t, m_ace_wr_addr_chnl_snoop, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (m_constraint_snoop, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (m_ace_wr_addr_chnl_addr, UVM_DEFAULT + UVM_NOPRINT)
<% if (obj.wSecurityAttribute > 0) { %>                                             
        `uvm_field_int (m_ace_wr_addr_chnl_security, UVM_DEFAULT + UVM_NOPRINT)
<% } %>                                                
        `uvm_field_int (m_constraint_addr, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_object (m_seq_item, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (should_randomize, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (en_partial, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (isSlave, UVM_DEFAULT + UVM_NOPRINT)

    `uvm_object_utils_end
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_write_addr_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Copy Function 
//------------------------------------------------------------------------------
function void do_copy(uvm_object rhs);
    axi_write_addr_seq rhs_;
    if(!$cast(rhs_, rhs)) begin
        `uvm_fatal("do_copy", "cast of rhs object failed")
    end
    super.do_copy(rhs_);
    this.m_ace_wr_addr_chnl_snoop = rhs_.m_ace_wr_addr_chnl_snoop;
    this.m_constraint_snoop       = rhs_.m_constraint_snoop;
    this.m_ace_wr_addr_chnl_addr  = rhs_.m_ace_wr_addr_chnl_addr;
    <% if (obj.wSecurityAttribute > 0) { %>                                             
        this.m_ace_wr_addr_chnl_security = rhs_.m_ace_wr_addr_chnl_security;
    <% } %>                                                
    this.m_constraint_addr = rhs_.m_constraint_addr;
    this.m_seq_item        = axi_wr_seq_item::type_id::create("m_seq_item");
    this.m_seq_item.do_copy(rhs_.m_seq_item);
    this.should_randomize = rhs_.should_randomize;
    this.en_partial       = rhs_.en_partial;
    this.isSlave          = rhs_.isSlave;
endfunction : do_copy 


//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    bit success;
  
    if (should_randomize) begin
        m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
    end
    start_item(m_seq_item);
    m_seq_item.m_has_addr = 1;
    if (should_randomize) begin
        if (m_constraint_addr) m_seq_item.m_write_addr_pkt.constrained_addr = 1;
        success = m_seq_item.m_write_addr_pkt.randomize() with {
            if (m_constraint_snoop == 1) m_seq_item.m_write_addr_pkt.awcmdtype == m_ace_wr_addr_chnl_snoop; 
            if (m_constraint_addr == 1) m_seq_item.m_write_addr_pkt.awaddr     == m_ace_wr_addr_chnl_addr; 
<% if (obj.wSecurityAttribute > 0) { %>                                             
            if (m_constraint_addr == 1) m_seq_item.m_write_addr_pkt.awprot[1]  == m_ace_wr_addr_chnl_security; 
<% } %>                                                
        };
        if (!success) begin
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_write_addr_seq"), UVM_NONE);
        end
    end
 
    //Force all addresses in the test to go to selected data bank
    
     <%if((obj.testBench == "io_aiu")) { %>
     if($test$plusargs("fixed_ioc_setindex")) begin
     <%for(var idx=0;idx<obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length;idx++){%>
     m_seq_item.m_write_addr_pkt.awaddr[<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits[idx]%>] = 0;
     <% } %> 
     end
   <% } %>
       finish_item(m_seq_item);
    if(!isSlave)begin
      s_wr_addr[core_id].put();
    end

    //uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("return s_wr_addr credit. aw_addr = 0x%x", m_seq_item.m_write_addr_pkt.awaddr), UVM_HIGH);
endtask : body

task return_response(output axi_wr_seq_item m_return_seq_item, input uvm_sequencer_base seqr, input uvm_sequence_base parent = null);
    axi_wr_seq_item m_local_return_seq_item;
    m_local_return_seq_item = axi_wr_seq_item::type_id::create("m_local_return_seq_item");
    this.start(seqr, parent);
    m_local_return_seq_item.do_copy(m_seq_item);
    m_return_seq_item = m_local_return_seq_item;
endtask : return_response

endclass : axi_write_addr_seq


////////////////////////////////////////////////////////////////////////////////
//
// AXI Write Data Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_write_data_seq extends uvm_sequence #(axi_wr_seq_item);

    axi_wr_seq_item m_seq_item;
    bit             should_randomize;
    bit             isSlave = 0;
    int             core_id = 0;
    static semaphore s_wr_data[int];

    `uvm_object_param_utils_begin(axi_write_data_seq)
        `uvm_field_object (m_seq_item, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (should_randomize, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (isSlave, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end


//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_write_data_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Copy Function 
//------------------------------------------------------------------------------
function void do_copy(uvm_object rhs);
    axi_write_data_seq rhs_;
    if(!$cast(rhs_, rhs)) begin
        `uvm_fatal("do_copy", "cast of rhs object failed")
    end
    super.do_copy(rhs_);
    this.m_seq_item        = axi_wr_seq_item::type_id::create("m_seq_item");
    this.m_seq_item.do_copy(rhs_.m_seq_item);
    this.should_randomize = rhs_.should_randomize;
    this.isSlave = rhs_.isSlave;
endfunction : do_copy 

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    bit success;

    if (should_randomize) begin
        m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
    end
    if(!isSlave)begin
      s_wr_data[core_id].put();
    end
    start_item(m_seq_item);
    m_seq_item.m_has_data = 1;
    if (should_randomize) begin
        success = m_seq_item.m_write_data_pkt.randomize();  
        if (!success) begin
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_write_data_seq"), UVM_NONE);
        end
    end
    finish_item(m_seq_item);
endtask : body

task return_response(output axi_wr_seq_item m_return_seq_item, input uvm_sequencer_base seqr, input uvm_sequence_base parent = null);
    axi_wr_seq_item m_local_return_seq_item;
    m_local_return_seq_item = axi_wr_seq_item::type_id::create("m_local_return_seq_item");
    this.start(seqr, parent);
    m_local_return_seq_item.do_copy(m_seq_item);
    m_return_seq_item = m_local_return_seq_item;
endtask : return_response

endclass : axi_write_data_seq

////////////////////////////////////////////////////////////////////////////////
//
// AXI Write Resp Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_write_resp_seq extends uvm_sequence #(axi_wr_seq_item);

    axi_wr_seq_item m_seq_item;
    bit             should_randomize;
    int             prob_ace_wr_resp_error = 0;
    
    `uvm_object_param_utils_begin(axi_write_resp_seq)
        `uvm_field_object (m_seq_item, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (should_randomize, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (prob_ace_wr_resp_error, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_write_resp_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Copy Function 
//------------------------------------------------------------------------------
function void do_copy(uvm_object rhs);
    axi_write_resp_seq rhs_;
    if(!$cast(rhs_, rhs)) begin
        `uvm_fatal("do_copy", "cast of rhs object failed")
    end
    super.do_copy(rhs_);
    this.m_seq_item        = axi_wr_seq_item::type_id::create("m_seq_item");
    this.m_seq_item.do_copy(rhs_.m_seq_item);
    this.should_randomize     = rhs_.should_randomize;
    this.prob_ace_wr_resp_error = rhs_.prob_ace_wr_resp_error;
endfunction : do_copy 


//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    
    bit success;
    bit done = 0;;

    do begin
        start_item(m_seq_item);
        m_seq_item.m_has_resp = 1;
        if (should_randomize) begin
            success = m_seq_item.m_write_resp_pkt.randomize();
            if (!success) begin
                uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_write_resp_seq"), UVM_NONE);
            end
            m_seq_item.m_write_resp_pkt.bid = m_seq_item.m_write_addr_pkt.awid;
        end
        if(m_seq_item.m_write_addr_pkt.awlock && ($urandom_range(0,100) < 50))begin
          m_seq_item.m_write_resp_pkt.bresp[1:0] = 1; //EXOKAY:1
        end
	//#Stimulus.DII.v3.prot
        if ($urandom_range(0,100) < prob_ace_wr_resp_error) begin
            //`uvm_info("AXI SEQ", "Setting write Response Error", UVM_MEDIUM)
            m_seq_item.m_write_resp_pkt.bresp[1:0] = $urandom_range(2,3); // SLVERR:2 DECERR:3
        end
        finish_item(m_seq_item);
        if (m_seq_item.m_has_resp == 1) begin
            done = 1;
        end
    end while (!done);
endtask : body

task return_response(output axi_wr_seq_item m_return_seq_item, input uvm_sequencer_base seqr, input uvm_sequence_base parent = null);
    axi_wr_seq_item m_local_return_seq_item;
    m_local_return_seq_item = axi_wr_seq_item::type_id::create("m_local_return_seq_item");
    this.start(seqr, parent);
    m_local_return_seq_item.do_copy(m_seq_item);
    m_return_seq_item = m_local_return_seq_item;
endtask : return_response

endclass : axi_write_resp_seq

////////////////////////////////////////////////////////////////////////////////
//
// AXI Snoop Address Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_snoop_addr_seq extends uvm_sequence #(axi_snp_seq_item);

    `uvm_object_param_utils(axi_snoop_addr_seq)

    axi_snp_seq_item m_seq_item;
    bit             should_randomize;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_snoop_addr_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    bit success;

    m_seq_item = axi_snp_seq_item::type_id::create("m_seq_item");
    start_item(m_seq_item);
    m_seq_item.m_has_addr = 1;
    if (should_randomize) begin
        success = m_seq_item.m_snoop_addr_pkt.randomize();
        if (!success) begin
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_snoop_addr_seq"), UVM_NONE);
        end
    end
    finish_item(m_seq_item);
endtask : body

task return_response(output axi_snp_seq_item m_return_seq_item, input uvm_sequencer_base seqr, input uvm_sequence_base parent = null);
    axi_snp_seq_item m_local_return_seq_item;
    m_local_return_seq_item = axi_snp_seq_item::type_id::create("m_local_return_seq_item");
    this.start(seqr, parent);
    m_local_return_seq_item.do_copy(m_seq_item);
    m_return_seq_item = m_local_return_seq_item;
endtask : return_response

endclass : axi_snoop_addr_seq

////////////////////////////////////////////////////////////////////////////////
//
// AXI Snoop Response Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_snoop_resp_seq extends uvm_sequence #(axi_snp_seq_item);

    `uvm_object_param_utils(axi_snoop_resp_seq)

    axi_snp_seq_item  m_seq_item;
    axi_crresp_t m_ace_snoop_rsp_chnl_resp;
    bit               is_dvm_sync;
    bit               m_constraint_snoop_resp;
    bit               should_randomize;
    // int               prob_ace_snp_resp_error = 0;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_snoop_resp_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    bit success;

    start_item(m_seq_item);
    m_seq_item.m_has_resp = 1;
    if (should_randomize) begin
        success = m_seq_item.m_snoop_resp_pkt.randomize() with {if (m_constraint_snoop_resp == 1) m_seq_item.m_snoop_resp_pkt.crresp == m_ace_snoop_rsp_chnl_resp; m_seq_item.m_snoop_resp_pkt.is_dvm_sync_crresp == is_dvm_sync;};
        if (!success) begin
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_snoop_resp_seq"), UVM_NONE);
        end
    end
    //`uvm_info("AXI SEQ", $psprintf("prob_ace_snp_resp_error = %0d",prob_ace_snp_resp_error), UVM_MEDIUM)
    // if ($urandom_range(0,99) < prob_ace_snp_resp_error) begin
    //     //`uvm_info("AXI SEQ", "Setting Snoop Response Error bit", UVM_MEDIUM)
    //     m_seq_item.m_snoop_resp_pkt.crresp[CCRRESPERRBIT] = 1;
    // end
    finish_item(m_seq_item);
endtask : body

task return_response(output axi_snp_seq_item m_return_seq_item, input uvm_sequencer_base seqr, input uvm_sequence_base parent = null);
    axi_snp_seq_item m_local_return_seq_item;
    m_local_return_seq_item = axi_snp_seq_item::type_id::create("m_local_return_seq_item");
    this.start(seqr, parent);
    m_local_return_seq_item.do_copy(m_seq_item);
    m_return_seq_item = m_local_return_seq_item;
endtask : return_response

endclass : axi_snoop_resp_seq

////////////////////////////////////////////////////////////////////////////////
//
// AXI Snoop Data Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_snoop_data_seq extends uvm_sequence #(axi_snp_seq_item);

    `uvm_object_param_utils(axi_snoop_data_seq)

    axi_snp_seq_item  m_seq_item;
    axi_cddata_t m_ace_snoop_data_chnl_data[];
    bit               m_constraint_snoop_data;
    bit               should_randomize;
    int no_of_ones_in_a_byte=0;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_snoop_data_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    bit success;

    start_item(m_seq_item);
    m_seq_item.m_has_data = 1;
    if (should_randomize) begin
        success = m_seq_item.m_snoop_data_pkt.randomize();
        if (!success) begin
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_snoop_data_seq"), UVM_NONE);
        end
    end
    if (m_constraint_snoop_data) begin
        m_seq_item.m_snoop_data_pkt.cddata = m_ace_snoop_data_chnl_data;

        for (int i=0; i< (m_ace_snoop_data_chnl_data.size());i++) begin
            m_seq_item.m_snoop_data_pkt.cdpoison[i] = 0;
            for (int j=0; j<(WXDATA/8); j++) begin
                no_of_ones_in_a_byte = $countones(m_ace_snoop_data_chnl_data[i][((8*j)+7)-:8]);
                if (no_of_ones_in_a_byte[0] == 1) begin
                    m_seq_item.m_snoop_data_pkt.cddatachk[i][j] = 1;
                end else begin
                    m_seq_item.m_snoop_data_pkt.cddatachk[i][j] = 0;
                end
            end
        end
    end
    finish_item(m_seq_item);
endtask : body

task return_response(output axi_snp_seq_item m_return_seq_item, input uvm_sequencer_base seqr, input uvm_sequence_base parent = null);
    axi_snp_seq_item m_local_return_seq_item;
    m_local_return_seq_item = axi_snp_seq_item::type_id::create("m_local_return_seq_item");
    this.start(seqr, parent);
    m_local_return_seq_item.do_copy(m_seq_item);
    m_return_seq_item = m_local_return_seq_item;
endtask : return_response

endclass : axi_snoop_data_seq

////////////////////////////////////////////////////////////////////////////////
//
//
//
//  Transaction layer sequences
//
//
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// Helper class to randomize a number as long as its not in an array 
////////////////////////////////////////////////////////////////////////////////

class randomize_helper_read; 

    rand axi_arid_t randomized_number;
    axi_arid_t      queue_of_excluded_numbers[$];

    constraint ar {
        foreach (queue_of_excluded_numbers[i]) {
            randomized_number != queue_of_excluded_numbers[i];
        }
    };

endclass : randomize_helper_read
 
class randomize_helper_write; 

    rand axi_awid_t randomized_number;
    axi_awid_t      queue_of_excluded_numbers[$];

    constraint aw {
        foreach (queue_of_excluded_numbers[i]) {
            randomized_number != queue_of_excluded_numbers[i];
        }
    };

endclass : randomize_helper_write
////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Sequence Base classes
// Below master sequences will have a semaphore that each transaction layer
// sequence can use along with same ID blocking
////////////////////////////////////////////////////////////////////////////////

class axi_master_read_base_seq extends uvm_sequence #(axi_rd_seq_item);
    
    `uvm_object_param_utils(axi_master_read_base_seq)

    typedef struct {
        ace_read_addr_pkt_t m_ace_read_addr_pkt;
        time                t_ace_read_addr_pkt;
    } read_addr_time_t;

    static semaphore s_rd[int];

    static read_addr_time_t m_ott_q[int][$]; 
    static event            e_ott_q_del;
    static event e_delete_axid;
    static event dvm_resp_rcvd;
    static bit use_random_axid;
    static bit use_incrementing_axid;
    static bit axi_perf_mode;
    static bit use_full_cl = 0;
    static bit no_axid_collision = 0;
    static axi_arid_t axid_counter_r;
    static axi_arid_t axid_inuse_q[$];
    // To keep track of DVMs and Barrier AXIDs
    static axi_arid_t axid_unqinuse_q[$];
    // To keep track of Noncoh AXIDs
    <% if (obj.wNcAxIdSbCtr > 1) { %>
        static axi_arid_t axid_noncoh_inuse_q[$];
    <% } %>

    bit use_burst_incr;
    bit use_burst_wrap;
    bit iocache_perf_test = 0;
    int core_id=0;
    int txn_id=0;
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
    function new(string name = "axi_master_read_base_seq");
        uvm_cmdline_processor clp;
        string arg_value; 
        super.new(name);
        clp = uvm_cmdline_processor::get_inst();
        clp.get_arg_value("+UVM_TESTNAME=", arg_value);
        if (arg_value == "concerto_inhouse_iocache_perf_test") begin
            iocache_perf_test = 1;
        end
        else begin
            iocache_perf_test = 0;
        end
        use_random_axid = (($urandom_range(0,100) < 75) && !$test$plusargs("incrementing_axid") && !$test$plusargs("axid_collision"));
        no_axid_collision = $test$plusargs("no_axid_collision");

        if (!use_random_axid && !$test$plusargs("axid_collision")) begin
            use_incrementing_axid = 1;
        end
        else begin
            if(!($test$plusargs("axid_collision"))) begin
                axi_perf_mode   = ($urandom_range(0,100) < 30);
            end
        end
        use_full_cl = $test$plusargs("use_full_cl");
        //FIXME: Please remove this guys once you are done with bringup 
        use_burst_wrap = $test$plusargs("use_burst_wrap");
        use_burst_incr = $test$plusargs("use_burst_incr");

        if (iocache_perf_test) begin
            axi_perf_mode = 1;
            use_incrementing_axid = 0;
            use_random_axid = 1;
        end
    endfunction : new

    // Task to support providing unique axids for all requests of cohsb or noncohsb are non-existent
    task get_axid(input ace_command_types_enum_t m_ace_cmd_type, output axi_arid_t use_axid, input bit firstReqDone = 1, input axi_arid_t force_this_axid = 0, input bit use_force_this_axid = 0);  
        // For coherent requests
        axi_arid_t tmp_axid;
        bit keep_axid = 0;
        bit done = 0;
        int m_tmp_q[$];
        use_axid = 0;
       
        //CONC-13788 DVMCMPL+all nonDVM commands use a AxID pool different
        //from the DVMMSGs AxID pool.
        if (m_ace_cmd_type == DVMCMPL) begin 
            //`uvm_info(get_full_name(), $sformatf("tsk:get_axid- use_random_axid:%0d use_incrementing_axid:%0d", use_random_axid, use_incrementing_axid), UVM_LOW)
            //`uvm_info(get_full_name(), $sformatf("tsk:get_axid- axid_inuse_q %p axid_unqinuse_q %p", axid_inuse_q, axid_unqinuse_q), UVM_LOW)      
            use_random_axid = 0;
            use_incrementing_axid = 0;
        end 

        if (use_random_axid) begin
            tmp_axid = $urandom_range(0,2**WARID-1);
        end
        else if (use_incrementing_axid) begin
            tmp_axid = axid_counter_r;
            if( !($test$plusargs("read_test")) && !($test$plusargs("write_test"))) begin
                if (axid_counter_r >= (2**WARID)-2) begin
                    axid_counter_r = 0;
                end else begin
                    axid_counter_r = axid_counter_r + 2;
                end
            end else begin
                if (axid_counter_r == 2**WARID) begin
                    axid_counter_r = 0;
                end else begin
                    axid_counter_r = axid_counter_r + 2;
                end
            end 
        end
        if (!firstReqDone && tmp_axid == 0) begin
            tmp_axid = 3;
        end
        do begin
            bit all_axids_used = 0;
            bit need_unq_axid = 0;
            int m_tmp_axid_q[$];
            m_tmp_axid_q = axid_inuse_q.unique_index();
            //`uvm_info("CHIRAGDBG", $sformatf("%p size %d axid_inuse_q %p use_force %0d force_axid 0x%0x", m_tmp_axid_q, m_tmp_axid_q.size(), axid_inuse_q, use_force_this_axid, force_this_axid), UVM_NONE)
            if (m_tmp_axid_q.size() >= (2**WARID)) begin
                all_axids_used = 1;
            end
            if (
                m_ace_cmd_type == DVMMSG     || 
                m_ace_cmd_type == DVMCMPL    || 
                m_ace_cmd_type == ATMSTR     || 
                m_ace_cmd_type == ATMSWAP    ||
                m_ace_cmd_type == ATMLD      || 
                m_ace_cmd_type == ATMCOMPARE ||
            no_axid_collision) begin
                need_unq_axid = 1;
            end
            if (m_ace_cmd_type == RDNOSNP) begin
                <% if (obj.nNcAxIdSbEntries == 0) { %>
                    need_unq_axid = 1;
                <% } %>
            end
            else begin
                <%if (obj.nCohAxIdSbEntries == 0) { %>
                    need_unq_axid = 1;
                <% } %>
            end
            if (axi_perf_mode) begin
                need_unq_axid = 1;
            end
            // Checking to see if forced axid is already in use
            if (use_force_this_axid) begin
                m_tmp_axid_q = {};
                m_tmp_axid_q = axid_inuse_q.find_first_index with (item == force_this_axid);
                if (m_tmp_axid_q.size() > 0) begin
                    all_axids_used = 1;
                end 
            end
            m_tmp_q = {};
            m_tmp_q = axid_unqinuse_q.find_first_index with (item == tmp_axid);  
            if (m_tmp_q.size() > 0) begin
                need_unq_axid = 1;
            end
            if (need_unq_axid && all_axids_used) begin
                @e_delete_axid;
            end
            else begin
                done = 1;
                if (use_force_this_axid) begin
                    tmp_axid = force_this_axid;
                    // Sanity check to confirm force_this_axid is not in use
                    m_tmp_axid_q = {};
                    m_tmp_axid_q = axid_inuse_q.find_first_index with (item == force_this_axid);
                    if (m_tmp_axid_q.size() > 0) begin
                        `uvm_error("RD ARID Seq",$sformatf("TB Error: Trying to use ARID from sequence, but its found in inuse queue. force_this_axid 0x%0x axid_inuse_q %p", force_this_axid, axid_inuse_q))      
                    end
                end
                else if (need_unq_axid) begin
                    bit found = 0;
                    int m_tmp_qA[$];
                    int m_tmp_qB[$];
                    int count = 0;
                    randomize_helper_read x = new();
                    do begin
                        foreach (axid_inuse_q[i]) begin
                            x.queue_of_excluded_numbers.push_back(axid_inuse_q[i]);
                        end
                        x.randomize();
                        tmp_axid = x.randomized_number;
                        if (!firstReqDone && tmp_axid == 0) begin
                            tmp_axid = 3;
                        end
                        count++;
                        m_tmp_qA = {};
                        m_tmp_qA = axid_inuse_q.find_first_index with (item == tmp_axid);
                        m_tmp_qB = {};
                        m_tmp_qB = axid_unqinuse_q.find_first_index with (item == tmp_axid);
                        if (m_tmp_qA.size() == 0) begin
                            found = 1;
                            if (m_tmp_qB.size() > 0) begin
                                `uvm_error("RD ARID Seq",$sformatf("TB Error: Sanity check failed. ID chosen is in unique queue. axid_inuse_q %p axid_unqinuse_q %p ID chosen 0x%0x", axid_inuse_q, axid_unqinuse_q, tmp_axid))      
                            end
                        end
                        if (count > 100) begin
                            `uvm_error("RD ARID Seq",$sformatf("TB Error: Possible infinite loop. Taking too long to find axid. axid_inuse_q size %0d axid width %0d axid_inuse_q %p", axid_inuse_q.size(), WARID, axid_inuse_q))      
                        end
                    end while (!found);
                end
            end
        end while (!done);
        <% if (obj.wNcAxIdSbCtr > 1) { %>
            if (m_ace_cmd_type == RDNOSNP) begin
                if ($urandom_range(0,100) < 70 && axid_noncoh_inuse_q.size() > 0) begin
                    int tmp_index = $urandom_range(0,axid_noncoh_inuse_q.size());
                    tmp_axid = axid_noncoh_inuse_q[tmp_index];
                end
            end
        <% } %>
        //`uvm_info("CHIRAGDBG RD ARID Seq", $sformatf("Adding arid 0x%0x for snoop type %0s", tmp_axid, m_ace_cmd_type.name()), UVM_NONE)
        axid_inuse_q.push_back(tmp_axid);
        <% if (obj.wNcAxIdSbCtr > 1 && obj.nNcAxIdSbEntries > 0) { %>
            if (m_ace_cmd_type == RDNOSNP) begin
                axid_noncoh_inuse_q.push_back(tmp_axid);
            end
        <% } %>
        if (
            m_ace_cmd_type == DVMMSG     || 
            m_ace_cmd_type == DVMCMPL    ||
            m_ace_cmd_type == ATMSTR     || 
            m_ace_cmd_type == ATMSWAP    ||
            m_ace_cmd_type == ATMLD      || 
            m_ace_cmd_type == ATMCOMPARE 
        ) begin
            axid_unqinuse_q.push_back(tmp_axid);
        end
        if (m_ace_cmd_type == RDNOSNP) begin
            <% if (obj.nNcAxIdSbEntries == 0) { %>
                axid_unqinuse_q.push_back(tmp_axid);
            <% } %>
        end
        else begin
            <%if (obj.nCohAxIdSbEntries == 0) { %>
                if (!( m_ace_cmd_type == DVMMSG || m_ace_cmd_type == DVMCMPL)) begin
                    axid_unqinuse_q.push_back(tmp_axid);
                end
            <% } %>
        end
        use_axid = tmp_axid;
    endtask : get_axid

    task wait_till_arid_latest(ace_read_addr_pkt_t m_ace_read_addr_pkt_tmp);
        read_addr_time_t m_read_addr_time_t;
        int              m_tmp_q[$];

        m_read_addr_time_t.t_ace_read_addr_pkt = $time;
        m_read_addr_time_t.m_ace_read_addr_pkt = m_ace_read_addr_pkt_tmp;
        m_ott_q[core_id].push_back(m_read_addr_time_t);
        m_tmp_q = {};
        m_tmp_q = m_ott_q[core_id].find_index with (item.m_ace_read_addr_pkt.arid == m_ace_read_addr_pkt_tmp.arid);
        if (m_tmp_q.size == 1) begin
            return;
        end
        else begin
            bit oldest;
            do begin
                oldest = 1;
                // Recalculating since m_ott_q has changed since last iteration of loop
                m_tmp_q = {};
                m_tmp_q = m_ott_q[core_id].find_index with (item.m_ace_read_addr_pkt.arid == m_ace_read_addr_pkt_tmp.arid);
                foreach (m_tmp_q[i]) begin
                    if (m_ott_q[core_id][m_tmp_q[i]].t_ace_read_addr_pkt < m_read_addr_time_t.t_ace_read_addr_pkt) begin
                        oldest = 0;
                        break;
                    end
                end
                if (!oldest) begin
                    @e_ott_q_del;
                end
            end while (!oldest);
        end
    endtask : wait_till_arid_latest

    function void delete_axid_inuse(axi_arid_t arid);
        int m_tmp_q[$];

        m_tmp_q = {};
        m_tmp_q = axid_inuse_q.find_first_index with (item == arid);
        //`uvm_info("CHIRAGDBG RD AXID Seq", $sformatf("Deleting arid 0x%0x", m_ace_read_addr_pkt_tmp.arid), UVM_NONE)
        if (m_tmp_q.size == 0) begin
            `uvm_error(get_full_name(),$sformatf("TB Error: Trying to delete and axid even though its not in queue. Arid: 0x%0x Queue: %p", arid, axid_inuse_q))      
        end
        else begin
            axid_inuse_q.delete(m_tmp_q[0]);
            ->e_delete_axid;
        end
        <% if (obj.wNcAxIdSbCtr > 1) { %>
            m_tmp_q = {};
            m_tmp_q = axid_noncoh_inuse_q.find_first_index with (item == arid);
            if (m_tmp_q.size > 0) begin
                axid_noncoh_inuse_q.delete(m_tmp_q[0]);
            end
        <% } %>
        m_tmp_q = {};
        m_tmp_q = axid_unqinuse_q.find_first_index with (item == arid);
        if (m_tmp_q.size > 0) begin
            axid_unqinuse_q.delete(m_tmp_q[0]);
        end
    endfunction : delete_axid_inuse

    function void delete_ott_entry(ace_read_addr_pkt_t m_ace_read_addr_pkt_tmp);
        int m_tmp_q[$];

        delete_axid_inuse(m_ace_read_addr_pkt_tmp.arid);
        m_tmp_q = {};
        m_tmp_q = m_ott_q[core_id].find_index with (item.m_ace_read_addr_pkt.arid == m_ace_read_addr_pkt_tmp.arid);
        if (m_tmp_q.size == 0) begin
            uvm_report_info("AXI SEQ ERROR", $sformatf("Printing ott_q entries size:%0d", m_ott_q[core_id].size()), UVM_NONE);
            foreach (m_ott_q[core_id][i]) begin
                uvm_report_info("AXI SEQ ERROR", $sformatf("Entry:%0d Value:%1p", i, m_ott_q[core_id][i]), UVM_NONE);
            end
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not find packet with arid: %0d address:0x%0x", m_ace_read_addr_pkt_tmp.arid, m_ace_read_addr_pkt_tmp.araddr), UVM_NONE);
        end
        else begin
            // Finding oldest entry to delete
            time t_temp;
            int  index_tmp;
            t_temp    = m_ott_q[core_id][m_tmp_q[0]].t_ace_read_addr_pkt;
            index_tmp = m_tmp_q[0];

            foreach (m_tmp_q[i]) begin
                if (t_temp > m_ott_q[core_id][m_tmp_q[i]].t_ace_read_addr_pkt) begin
                    t_temp    = m_ott_q[core_id][m_tmp_q[i]].t_ace_read_addr_pkt;
                    index_tmp = m_tmp_q[i];
                end
            end
            m_ott_q[core_id].delete(index_tmp);
            ->e_ott_q_del;
        end
    endfunction : delete_ott_entry
endclass : axi_master_read_base_seq

class axi_master_write_base_seq extends uvm_sequence #(axi_wr_seq_item);
    
    `uvm_object_param_utils(axi_master_write_base_seq)

    typedef struct {
        ace_write_addr_pkt_t m_ace_write_addr_pkt;
        time                t_ace_write_addr_pkt;
    } write_addr_time_t;

    static semaphore s_wr[int];
    static semaphore s_wr_addr[int];
    static semaphore s_wr_data[int];

    static write_addr_time_t m_ott_q[int][$]; 
    static event            e_ott_q_del;
    static event e_delete_axid;
    static bit use_random_axid;
    static axi_awid_t axid_counter_w;
    static bit use_incrementing_axid;
    static bit axi_perf_mode;
    static bit use_full_cl = 0;
    static bit no_axid_collision = 0;
    static axi_awid_t axid_inuse_q[$];
    // To keep track of DVMs and Barrier AXIDs
    static axi_awid_t axid_unqinuse_q[$];
    // To keep track of Noncoh AXIDs
    <% if (obj.wNcAxIdSbCtr > 1) { %>
        static axi_awid_t axid_noncoh_inuse_q[$];
    <% } %>

    bit iocache_perf_test = 0;
    int core_id=0;
    int txn_id=0;
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
    function new(string name = "axi_master_write_base_seq");
        uvm_cmdline_processor clp;
        string arg_value; 
        super.new(name);
        clp = uvm_cmdline_processor::get_inst();
        clp.get_arg_value("+UVM_TESTNAME=", arg_value);
        if (arg_value == "concerto_inhouse_iocache_perf_test") begin
            iocache_perf_test = 1;
        end
        else begin
            iocache_perf_test = 0;
        end
        use_random_axid = (($urandom_range(0,100) < 75) && !$test$plusargs("incrementing_axid") && !$test$plusargs("axid_collision"));
        no_axid_collision = $test$plusargs("no_axid_collision");

        if (!use_random_axid && !$test$plusargs("axid_collision")) begin
            use_incrementing_axid = 1;
        end
        else begin
            if(!($test$plusargs("axid_collision"))) begin
                axi_perf_mode   = ($urandom_range(0,100) < 30);
            end
        end
        use_full_cl = $test$plusargs("use_full_cl");
        if (iocache_perf_test) begin
            axi_perf_mode = 1;
            use_incrementing_axid = 0;
            use_random_axid = 1;
        end
    endfunction : new

    // Task to support providing unique axids for all requests of cohsb or noncohsb are non-existent
    task get_axid(input ace_command_types_enum_t m_ace_cmd_type, output axi_awid_t use_axid, input axi_awid_t force_this_axid = 0, input bit use_force_this_axid = 0);  
        // For coherent requests
        axi_awid_t tmp_axid;
        bit keep_axid = 0;
        bit done = 0;
        int m_tmp_q[$];
        use_axid = 0;
        if (use_random_axid) begin
            tmp_axid = $urandom_range(0,2**WAWID-1);
        end
        else if (use_incrementing_axid) begin
            tmp_axid = axid_counter_w;
            if( !($test$plusargs("read_test")) && !($test$plusargs("write_test"))) begin
                if ( axid_counter_w >= (2**WAWID)-2  || axid_counter_w == 0 ) begin
                    axid_counter_w = 1;
                end else begin
                    axid_counter_w = axid_counter_w + 2;
                end
            end else begin
                if (axid_counter_w == 2**WAWID) begin
                    axid_counter_w = 0;
                end else begin
                    axid_counter_w++;
                end 
            end 
        end
        do begin
            bit all_axids_used = 0;
            bit need_unq_axid = 0;
            int m_tmp_axid_q[$];
            m_tmp_axid_q = axid_inuse_q.unique_index();
            if (m_tmp_axid_q.size() >= (2**WAWID)) begin
                all_axids_used = 1;
            end
            if (no_axid_collision                 ||
                m_ace_cmd_type == ATMSTR       || m_ace_cmd_type == ATMSWAP         ||
                m_ace_cmd_type == ATMLD        || m_ace_cmd_type == ATMCOMPARE      ||
                m_ace_cmd_type == STASHONCEUNQ || m_ace_cmd_type == STASHONCESHARED ||
                m_ace_cmd_type == STASHTRANS) begin
                need_unq_axid = 1;
            end
            if (m_ace_cmd_type == WRNOSNP) begin
                <% if (obj.nNcAxIdSbEntries == 0) { %>
                    need_unq_axid = 1;
                <% } %>
            end
            else begin
                <%if (obj.nCohAxIdSbEntries == 0) { %>
                    need_unq_axid = 1;
                <% } %>
            end
            m_tmp_q = {};
            m_tmp_q = axid_unqinuse_q.find_first_index with (item == tmp_axid);  
            if (m_tmp_q.size() > 0) begin
                need_unq_axid = 1;
            end
            if (axi_perf_mode) begin
                need_unq_axid = 1;
            end
            // Checking to see if forced axid is already in use
            if (use_force_this_axid) begin
                m_tmp_axid_q = {};
                m_tmp_axid_q = axid_inuse_q.find_first_index with (item == force_this_axid);
                if (m_tmp_axid_q.size() > 0) begin
                    all_axids_used = 1;
                end 
            end
            if (need_unq_axid && all_axids_used) begin
                @e_delete_axid;
            end
            else begin
                done = 1;
                if (use_force_this_axid) begin
                    tmp_axid = force_this_axid;
                    // Sanity check to confirm force_this_axid is not in use
                    m_tmp_axid_q = {};
                    m_tmp_axid_q = axid_inuse_q.find_first_index with (item == force_this_axid);
                    if (m_tmp_axid_q.size() > 0) begin
                        `uvm_error("WR AWID Seq",$sformatf("TB Error: Trying to use AWID from sequence, but its found in inuse queue. force_this_axid 0x%0x axid_inuse_q %p", force_this_axid, axid_inuse_q))      
                    end
                end
                else if (need_unq_axid) begin
                    bit found = 0;
                    int m_tmp_qA[$];
                    int m_tmp_qB[$];
                    int count = 0;
                    randomize_helper_write x = new();
                    do begin
                        foreach (axid_inuse_q[i]) begin
                            x.queue_of_excluded_numbers.push_back(axid_inuse_q[i]);
                        end
                        x.randomize() with {if( m_ace_cmd_type == ATMSTR || 
						 m_ace_cmd_type == ATMSWAP ||
                				 m_ace_cmd_type == ATMLD  || 
						 m_ace_cmd_type == ATMCOMPARE) {randomized_number inside {[0:2**WARID-1]};}};
                        tmp_axid = x.randomized_number;
                        count++;
                        m_tmp_qA = {};
                        m_tmp_qA = axid_inuse_q.find_first_index with (item == tmp_axid);
                        m_tmp_qB = {};
                        m_tmp_qB = axid_unqinuse_q.find_first_index with (item == tmp_axid);
                        if (m_tmp_qA.size() == 0) begin
                            found = 1;
                            if (m_tmp_qB.size() > 0) begin
                                `uvm_error("WR AWID Seq",$sformatf("TB Error: Sanity check failed. ID chosen is in unique queue. axid_inuse_q %p axid_unqinuse_q %p ID chosen 0x%0x", axid_inuse_q, axid_unqinuse_q, tmp_axid))      
                            end
                        end
                        if (count > 100) begin
                            $stacktrace;
                            `uvm_error("WR AWID Seq",$sformatf("TB Error: Possible infinite loop. Taking too long to find axid. axid_inuse_q size %0d axid width %0d axid_inuse_q %p tmp_axid:%0p", axid_inuse_q.size(), WAWID, axid_inuse_q,tmp_axid))
                        end
                    end while (!found);
                end
            end
        end while (!done);
        <% if (obj.wNcAxIdSbCtr > 1 && obj.nNcAxIdSbEntries > 0) { %>
            if (m_ace_cmd_type == WRNOSNP) begin
                if ($urandom_range(0,100) < 70 && axid_noncoh_inuse_q.size() > 0) begin
                    int tmp_index = $urandom_range(0,axid_noncoh_inuse_q.size());
                    tmp_axid = axid_noncoh_inuse_q[tmp_index];
                end
            end
        <% } %>
        //`uvm_info("CHIRAGDBG WR AWID Seq", $sformatf("Adding awid 0x%0x for snoop type %0s", tmp_axid, m_ace_cmd_type.name()), UVM_NONE)
        axid_inuse_q.push_back(tmp_axid);
        <% if (obj.wNcAxIdSbCtr > 1) { %>
            if (m_ace_cmd_type == WRNOSNP) begin
                axid_noncoh_inuse_q.push_back(tmp_axid);
            end
        <% } %>
        if (      
            m_ace_cmd_type == ATMSTR          || 
            m_ace_cmd_type == ATMSWAP         ||
            m_ace_cmd_type == ATMLD           || 
            m_ace_cmd_type == ATMCOMPARE      ||
            m_ace_cmd_type == STASHONCEUNQ    || 
            m_ace_cmd_type == STASHONCESHARED ||
        m_ace_cmd_type == STASHTRANS) begin
            axid_unqinuse_q.push_back(tmp_axid);
        end
        if (m_ace_cmd_type == WRNOSNP) begin
            <% if (obj.nNcAxIdSbEntries == 0) { %>
                axid_unqinuse_q.push_back(tmp_axid);
            <% } %>
        end
        else begin
            <%if (obj.nCohAxIdSbEntries == 0) { %>
                                    axid_unqinuse_q.push_back(tmp_axid);
            <% } %>
        end
        use_axid = tmp_axid;
    endtask : get_axid

    task wait_till_awid_latest(ace_write_addr_pkt_t m_ace_write_addr_pkt_tmp);
        write_addr_time_t m_write_addr_time_t;
        int              m_tmp_q[$];
       
        m_write_addr_time_t.t_ace_write_addr_pkt = $time;
        m_write_addr_time_t.m_ace_write_addr_pkt = m_ace_write_addr_pkt_tmp;
        m_ott_q[core_id].push_back(m_write_addr_time_t);
        m_tmp_q = {};
        m_tmp_q = m_ott_q[core_id].find_index with (item.m_ace_write_addr_pkt.awid == m_ace_write_addr_pkt_tmp.awid);
        if (m_tmp_q.size == 1) begin
            return;
        end
        else begin
            bit oldest;
            do begin
                oldest = 1;
                // Recalculating since m_ott_q has changed since last iteration of loop
                m_tmp_q = {};
                m_tmp_q = m_ott_q[core_id].find_index with (item.m_ace_write_addr_pkt.awid == m_ace_write_addr_pkt_tmp.awid);
                foreach (m_tmp_q[i]) begin
                    if (m_ott_q[core_id][m_tmp_q[i]].t_ace_write_addr_pkt < m_write_addr_time_t.t_ace_write_addr_pkt) begin
                        oldest = 0;
                        break;
                    end
                end
                if (!oldest) begin
                    @e_ott_q_del;
                end
            end while (!oldest);
        end
    endtask : wait_till_awid_latest

    function void delete_axid_inuse (axi_awid_t awid); 
        int m_tmp_q[$];
 
        m_tmp_q = {};
        m_tmp_q = axid_inuse_q.find_first_index with (item == awid);
        //`uvm_info("CHIRAGDBG WR AWID Seq", $sformatf("Deleting awid 0x%0x", m_ace_read_addr_pkt_tmp.arid), UVM_NONE)
        if (m_tmp_q.size == 0) begin
            `uvm_error("WR AWID Seq",$sformatf("TB Error: Trying to delete and axid even though its not in queue. Awid: 0x%0xQueue: %p", awid, axid_inuse_q))      
        end
        else begin
            axid_inuse_q.delete(m_tmp_q[0]);
            ->e_delete_axid;
        end
        <% if (obj.wNcAxIdSbCtr > 1) { %>
            m_tmp_q = {};
            m_tmp_q = axid_noncoh_inuse_q.find_first_index with (item == awid);
            if (m_tmp_q.size > 0) begin
                axid_noncoh_inuse_q.delete(m_tmp_q[0]);
            end
        <% } %>
        m_tmp_q = {};
        m_tmp_q = axid_unqinuse_q.find_first_index with (item == awid);
        if (m_tmp_q.size > 0) begin
            axid_unqinuse_q.delete(m_tmp_q[0]);
        end
    endfunction : delete_axid_inuse

    function void delete_ott_entry(ace_write_addr_pkt_t m_ace_write_addr_pkt_tmp);
        int m_tmp_q[$];
        m_tmp_q = {};
        if (!$test$plusargs("pcie_prod_consu_stress_test")) delete_axid_inuse(m_ace_write_addr_pkt_tmp.awid);
        m_tmp_q = m_ott_q[core_id].find_index with (item.m_ace_write_addr_pkt.awid == m_ace_write_addr_pkt_tmp.awid);
        if (m_tmp_q.size == 0) begin
            uvm_report_info("AXI SEQ ERROR", $sformatf("Printing ott_q entries size:%0d", m_ott_q[core_id].size()), UVM_NONE);
            foreach (m_ott_q[core_id][i]) begin
                uvm_report_info("AXI SEQ ERROR", $sformatf("Entry:%0d Value:%1p", i, m_ott_q[core_id][i]), UVM_NONE);
            end
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not find packet with awid: %0d address:0x%0x", m_ace_write_addr_pkt_tmp.awid, m_ace_write_addr_pkt_tmp.awaddr), UVM_NONE);
        end
        else begin
            // Finding oldest entry to delete
            time t_temp;
            int  index_tmp;
            t_temp    = m_ott_q[core_id][m_tmp_q[0]].t_ace_write_addr_pkt;
            index_tmp = m_tmp_q[0];

            foreach (m_tmp_q[i]) begin
                if (t_temp > m_ott_q[core_id][m_tmp_q[i]].t_ace_write_addr_pkt) begin
                    t_temp    = m_ott_q[core_id][m_tmp_q[i]].t_ace_write_addr_pkt;
                    index_tmp = m_tmp_q[i];
                end
            end
            m_ott_q[core_id].delete(index_tmp);
            ->e_ott_q_del;
        end
    endfunction : delete_ott_entry
endclass : axi_master_write_base_seq

<% if((obj.Block === 'aiu') || (obj.Block === 'io_aiu') || (obj.Block === 'mem' && obj.is_master === 1)) { %>
//This is just a single_directed_rd_txn child sequence called from higher level sequences
class axi_directed_rd_seq extends axi_master_read_base_seq;
    `uvm_object_param_utils(axi_directed_rd_seq)
    
    //child sequence handles
    axi_read_addr_seq            m_read_addr_seq;
    axi_read_data_seq            m_read_data_seq;
    
    //sequencer handles
    axi_read_addr_chnl_sequencer m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer m_read_data_chnl_seqr;
    
    axi_rd_seq_item              m_seq_item;

    axi_axaddr_t                 m_addr;
    axi_axlen_t                  m_len;
    axi_arid_t                   m_id;
    axi_axsize_t                 m_size;
    axi_axburst_t                m_burst;
    ace_command_types_enum_t 	 m_cmdtype;
    axi_arcache_enum_t           m_cache;
    axi_axdomain_enum_t          m_domain;
    axi_axprot_t                 m_prot;

    bit                          success;
    bit                          dis_post_randomize = 0;
    string io_subsys_inhouse_seq_name;
    
    function new(string name="axi_directed_rd_seq");
      super.new();
    endfunction:new

    task body;

        //`uvm_info(get_full_name(),$sformatf("Entering Body txn_id:%0d sec:%0b addr:0x%0h", txn_id, m_prot[1], m_addr), UVM_LOW)
        if(s_rd[core_id] == null) s_rd[core_id] = new(1);
        s_rd[core_id].get();

        m_read_addr_seq = axi_read_addr_seq::type_id::create("m_read_addr_seq"); 
        m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 
       
        m_read_addr_seq.should_randomize        = 0;
        m_read_addr_seq.m_seq_item  = axi_rd_seq_item::type_id::create("m_seq_item");
   
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.dis_post_randomize = dis_post_randomize;
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.constrained_addr = 1;
       if (!$value$plusargs("io_subsys_inhouse_seq_name=%0s", io_subsys_inhouse_seq_name)) begin
        io_subsys_inhouse_seq_name = "";
       end

       if(io_subsys_inhouse_seq_name=="read_after_write_sequance") begin
        success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_cmdtype;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen == m_len;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr == m_addr;
           };
        end else begin
 
        success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid == m_id;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_cmdtype;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == m_burst;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache == m_cache; 
               if(m_cmdtype== RDNOSNP) 
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.coh_domain == 0;
               if(m_cmdtype == RDONCE) 
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.coh_domain == 1;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsize == m_size;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.ardomain == m_domain;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlock == NORMAL;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen == m_len;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr == m_addr;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot == m_prot;
           };
        end
        if (!success) begin
            `uvm_error(get_full_name(), $sformatf("TB Error: Could not randomize packet in axi_master_read_seq"))
        end else begin 
            `uvm_info(get_full_name(), $sformatf("Sending C%0d_AXI[%0d] %0s", core_id, txn_id, m_read_addr_seq.m_seq_item.convert2string()), UVM_LOW);
        end
        
        m_read_addr_seq.return_response(m_seq_item, m_read_addr_chnl_seqr);
        s_rd[core_id].put();
        m_read_data_seq.m_seq_item       = m_seq_item;
        m_read_data_seq.should_randomize = 0;
        m_read_data_seq.return_response(m_seq_item, m_read_data_chnl_seqr);

    endtask:body
endclass: axi_directed_rd_seq

//This is just a single_directed_wr_txn child sequence called from higher level sequences
class axi_directed_wr_seq extends axi_master_write_base_seq;
    `uvm_object_param_utils(axi_directed_wr_seq)
    
    //child sequence handles
    axi_write_addr_seq            m_write_addr_seq;
    axi_write_data_seq            m_write_data_seq;
    axi_write_resp_seq            m_write_resp_seq;
    
    //sequencer handles
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;
    
    axi_wr_seq_item              m_seq_item;
    ace_cache_model              m_ace_cache_model;

    axi_axaddr_t                 m_addr;
    axi_axlen_t                  m_len;
    axi_awid_t                   m_id;
    axi_axsize_t                 m_size;
    axi_axburst_t                m_burst;
    ace_command_types_enum_t 	 m_cmdtype;
    axi_awcache_enum_t           m_cache;
    axi_axdomain_enum_t          m_domain;
    axi_axprot_t                 m_prot;

    bit                          success;
    bit                          dis_post_randomize = 0;
    string io_subsys_inhouse_seq_name;
    
    function new(string name="axi_directed_wr_seq");
      super.new();
    endfunction:new

    task body;
        axi_wr_seq_item               m_seq_item0;
        axi_wr_seq_item               m_seq_item1;

        //`uvm_info(get_full_name(),$sformatf("Entering Body txn_id:%0d sec:%0b addr:0x%0h", txn_id, m_prot[1], m_addr), UVM_LOW)
        m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq"); 
        m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq"); 
        m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq"); 
        
        m_write_addr_seq.should_randomize = 0;
        m_write_data_seq.should_randomize = 0;
        m_write_resp_seq.should_randomize = 0;

        m_write_addr_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_resp_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_seq_item0                                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_seq_item1                                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_addr_seq.m_constraint_snoop        = 1;
        m_write_addr_seq.m_constraint_addr         = 1;

        m_write_addr_seq.core_id = core_id; 
        m_write_data_seq.core_id = core_id;
        
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
        
        m_write_addr_seq.s_wr_addr = s_wr_addr; 
        m_write_data_seq.s_wr_data = s_wr_data; 

        m_write_addr_seq.should_randomize        = 0;
   
        m_write_addr_seq.m_seq_item.m_write_addr_pkt.constrained_addr = 1;
       if (!$value$plusargs("io_subsys_inhouse_seq_name=%0s", io_subsys_inhouse_seq_name)) begin
        io_subsys_inhouse_seq_name = "";
       end
       if(io_subsys_inhouse_seq_name=="read_after_write_sequance") begin
      success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr == m_addr;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen == m_len;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_cmdtype;
           };
      end else begin 
 
        success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid == m_id;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_cmdtype;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst == m_burst;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache == m_cache; 
               if(m_cmdtype== WRNOSNP) 
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.coh_domain == 0;
               if(m_cmdtype == WRUNQ) 
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.coh_domain == 1;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize == m_size;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awdomain == m_domain;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlock == NORMAL;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen == m_len;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr == m_addr;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot == m_prot;
           };
        end
        if (!success) begin
            `uvm_error(get_full_name(), $sformatf("TB Error: Could not randomize packet in axi_master_write_seq"))
        end
        
        //Create the write data packet
        success = m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
        if (!success) begin
            `uvm_error(get_name(), $sformatf("TB Error: Could not randomize write data packet in directed_wr_seq"));
        end
       
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb    = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wpoison  = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdatachk = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wtrace = $urandom;

        m_ace_cache_model.give_data_for_ace_req(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize, m_write_data_seq.m_seq_item.m_write_data_pkt.wdata, m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]
<% } %>                                                
            );
      /*  foreach(m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[idx]) begin
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[idx]=64'hffffffff;
        end */
        m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;

        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        s_wr_addr[core_id].get();
        s_wr_data[core_id].get();
 
        fork 
            begin
                m_write_addr_seq.return_response(m_seq_item0, m_write_addr_chnl_seqr);
	        //`uvm_info(get_name(), $sformatf("Sent AXI[%0d] WR Addr: %s",txn_id, m_write_addr_seq.m_seq_item.convert2string()), UVM_LOW)
            end
            begin
                m_write_data_seq.return_response(m_seq_item1, m_write_data_chnl_seqr);
	        //`uvm_info(get_name(), $sformatf("Sent AXI[%0d] WR Data: %s",txn_id, m_write_data_seq.m_seq_item.convert2string()), UVM_LOW)
            end
        join
        
        m_write_resp_seq.m_seq_item = m_seq_item0;
        m_write_resp_seq.return_response(m_seq_item0, m_write_resp_chnl_seqr);
	`uvm_info(get_name(), $sformatf("Received AXI[%0d] WR Resp: %s",txn_id, m_write_resp_seq.m_seq_item.convert2string()), UVM_LOW)

        //`uvm_info(get_full_name(),$sformatf("Exiting Body txn_id:%0d", txn_id), UVM_LOW)
    
    endtask:body
endclass: axi_directed_wr_seq

typedef class axi_master_pipelined_seq;
class read_after_write_sequance extends axi_master_pipelined_seq;
    <% if (obj.testBench == "fsys") { %>
       `uvm_object_utils(ioaiu<%=my_ioaiu_id%>_inhouse_axi_bfm_pkg::read_after_write_sequance)
    <% }else {%>
      `uvm_object_param_utils(read_after_write_sequance)
    <% } %>

  uvm_event ev_seq_done;
  uvm_event ev_sim_done;
  axi_directed_rd_seq   rd_seq[];
  axi_directed_wr_seq   wr_seq[];
  bit usecache ='b0;
  addrMgrConst::mem_type get_coh_noncoh_type;
  bit [addrMgrConst::W_SEC_ADDR -1: 0] temp_addr,uaddrq[$],temp_uaddrq[$];
  bit [<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length%> -1:0] index[$];
  uvm_event ev_wait_completion_of_seq_aiu<%=obj.Id%> = uvm_event_pool::get_global("ev_wait_completion_of_seq_aiu<%=obj.Id%>");
  function new(string name = "read_after_write_sequance");
    super.new(name); 
  endfunction : new
    
  task body;
    num_sets = $urandom_range(2,5);
    ev_sim_done = ev_pool.get("sim_done");
    ev_seq_done = ev_pool.get(seq_name);
    if($test$plusargs("coh_addr_rgn"))     get_coh_noncoh_type=addrMgrConst::COH_DMI;
    if($test$plusargs("non_coh_dmi_addr")) get_coh_noncoh_type=addrMgrConst::NONCOH_DMI;
    if($test$plusargs("non_coh_dii_addr")) get_coh_noncoh_type=addrMgrConst::NONCOH_DII;
    <% if(obj.useCache) { %>
       usecache ='b1; 
    <%}%>
    repeat (num_sets) begin
    <% if(obj.useCache) { %>
        assert(std::randomize(ccp_setindex) with {(!(ccp_setindex inside {index}));})
        else begin
            `uvm_error(get_full_name(), "Failure to randomize ccp_setindex");
        end
      index.push_back(ccp_setindex);
    <%}%>
      m_addr_mgr.get_addrq_w_fix_set_index(ccp_setindex, <%=obj.FUnitId%>, core_id, k_num_write_req, temp_uaddrq,get_coh_noncoh_type,usecache);
      foreach(temp_uaddrq[i]) begin
        temp_uaddrq[i][SYS_wSysCacheline-1:0] = '0;    
        temp_addr=temp_uaddrq[i]; 
        uaddrq.push_back(temp_addr);
      end
    end
    uaddrq.shuffle(); 
    rd_seq = new[uaddrq.size()];
    wr_seq = new[uaddrq.size()];
    foreach(uaddrq[i]) begin
    automatic int j=i;
      fork
	begin
        wr_seq[j]                        = axi_directed_wr_seq::type_id::create($sformatf("c%0d_wr_seq_%0d", core_id, j));
        rd_seq[j]                        = axi_directed_rd_seq::type_id::create($sformatf("c%0d_rd_seq_%0d", core_id, j));
        wr_seq[j].core_id                = core_id;
        wr_seq[j].m_ace_cache_model      = m_ace_cache_model;
        wr_seq[j].m_addr                   = uaddrq[j];
        wr_seq[j].m_len                 = ((SYS_nSysCacheline*8/(WXDATA)) - 1);
        if(addrMgrConst::is_dii_addr(uaddrq[j]) || (addrMgrConst::get_addr_gprar_nc(uaddrq[j]) && addrMgrConst::is_dmi_addr(uaddrq[j])))
        wr_seq[j].m_cmdtype = WRNOSNP;
        else
        wr_seq[j].m_cmdtype = WRUNQ;
        wr_seq[j].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        wr_seq[j].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        wr_seq[j].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
        rd_seq[j].core_id                = core_id;
        rd_seq[j].m_addr                 = uaddrq[j];
        rd_seq[j].m_len                 = ((SYS_nSysCacheline*8/(WXDATA)) - 1);//cache-line size
        if(addrMgrConst::is_dii_addr(uaddrq[j]) || (addrMgrConst::get_addr_gprar_nc(uaddrq[j]) && addrMgrConst::is_dmi_addr(uaddrq[j])))
        rd_seq[j].m_cmdtype = RDNOSNP;
        else
        rd_seq[j].m_cmdtype = RDONCE;
        rd_seq[j].m_read_addr_chnl_seqr  = m_read_addr_chnl_seqr;
        rd_seq[j].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
        wr_seq[j].start(null);
        rd_seq[j].start(null);
        end
      join_none;
    end
    wait fork;
 
    ev_seq_done.trigger(null);													   
    ev_wait_completion_of_seq_aiu<%=obj.Id%>.trigger();
    <% if (obj.testBench == "fsys"|| obj.testBench == "emu") { %>
      ev_sim_done.wait_trigger();
    <% } %>

  endtask:body
    
endclass:read_after_write_sequance


////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Read Sequence
//
////////////////////////////////////////////////////////////////////////////////

typedef class axi_master_write_noncoh_seq;

class axi_master_read_seq extends axi_master_read_base_seq;

    `uvm_object_param_utils(axi_master_read_seq)
    
    axi_read_addr_seq                   m_read_addr_seq;
    axi_read_data_seq                   m_read_data_seq;
    axi_read_addr_chnl_sequencer m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer m_read_data_chnl_seqr;
    axi_rd_seq_item                     m_seq_item;
    ace_cache_model              m_ace_cache_model;

    // For barriers
    static axi_wr_seq_item m_wr_bar_seq_item_q[$];

    //Control Knobs
    `ifdef PSEUDO_SYS_TB
        int wt_ace_rdnosnp      = 0;
    `else
        int wt_ace_rdnosnp      = 5;
    `endif

    int wt_ace_rdonce       = 5;
    <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
        int wt_ace_rdshrd       = 5;
        int wt_ace_rdcln        = 5;
        int wt_ace_rdnotshrddty = 5;
        int wt_ace_rdunq        = 5;
        int wt_ace_clnunq       = 5;
        int wt_ace_mkunq        = 5;
        // FIXME: Fix below weight to be non-zero
        int wt_ace_dvm_msg      = 0;
        int wt_ace_dvm_sync     = 0;
    <% }else { %>    
        int wt_ace_rdshrd       = 0;
        int wt_ace_rdcln        = 0;
        int wt_ace_rdnotshrddty = 0;
        int wt_ace_rdunq        = 0;
        int wt_ace_clnunq       = 0;
        int wt_ace_mkunq        = 0;
        int wt_ace_dvm_msg      = 0;
        int wt_ace_dvm_sync     = 0;
    <% } %>      
    int wt_ace_clnshrd       = 0;
    int wt_ace_clninvl       = 0;
    int wt_ace_mkinvl        = 0;
    int wt_ace_rd_bar        = 0;
    int wt_ace_rd_cln_invld  = 0;
    int wt_ace_rd_make_invld = 0;
    int wt_ace_clnshrd_pers  = 0;

    int k_num_read_req      = 1;
    int k_access_boot_region = 0;
    int wt_illegal_op_addr   = 0;    
    int wt_not_illegal_op_addr   = 0;
    int is_illegal_op   = 0;
    int aiu_qos;
    int user_qos;
    
    int num_alt_qos_values;
    int total_aiu_qos_cycle;
    int aiu_qos1;
    int aiu_qos1_cycle;
    int aiu_qos2;
    int aiu_qos2_cycle;
    int aiu_qos3;
    int aiu_qos3_cycle;
    int aiu_qos4;
    int aiu_qos4_cycle;
    static int qos_cycle_count;

    int                         ioaiu_force_axid; //newperf test force same axid on the transactions
    int                         en_force_axid;
    // For directed test case purposes
    bit                                       use_addr_from_test = 0;
    bit                                       use_axcache_from_test = 0;
    bit                                       force_axlen_256B = 0;

    axi_axaddr_t   m_ace_rd_addr_from_test;
    <% if (obj.wSecurityAttribute > 0) { %>                                             
        bit [<%=obj.wSecurityAttribute%>-1:0] m_ace_rd_security_from_test;
    <% } %>                                                
    bit                                       m_ace_rd_two_line_multicl = 0;
    static bit firstReqDone         = 0;
    static bit isDVMSyncOutStanding = 0;
    static bit sendDVMComplete      = 0;
    static int nDVMMSGCredit        = 256;
    static int read_req_count       = 0;
    static int read_req_total_count = 0;
    static bit pwrmgt_power_down    = 0;

    int perf_test;
    int perf_test_ace;
    int perf_txn_size;    
    int perf_coh_txn_size;    
    int perf_noncoh_txn_size;   
    int id;

     //For data bank selection
	<%if((obj.testBench == "io_aiu" && obj.useCache) && (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) {%>
       bit[<%=Math.log2(obj.nDataBanks)%>-1:0]             sel_bank;
	<%}%>

<% if(obj.testBench =="io_aiu" && (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) { %>
       bit[<%=(Math.log2((obj.DutInfo.nNativeInterfacePorts) * obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks))%>-1:0]             sel_ott_bank;
<%}%>
	
    // newperf test 
    uvm_event_pool ev_pool     = uvm_event_pool::get_global_pool();
    uvm_event ev_rd_req_done   = ev_pool.get("ioaiu<%=my_ioaiu_id%>_rd_req_done");
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_master_read_seq");
        super.new(name);
        user_qos = 0;
        qos_cycle_count    = 0; 
        num_alt_qos_values = 0;

    endfunction : new

    //------------------------------------------------------------------------------
    // Body Task
    //------------------------------------------------------------------------------
    task body;

        int                         num_req;
        bit                         success;
        int force_single_dvm,force_multi_dvm;
        int                         m_tmp_q[$];
        int                         num_coh_addr_in_ort[$];
        int                         num_noncoh_addr_in_ort[$];                         
        addr_trans_mgr              m_addr_mgr;
        bit                         isDvmSync = 0;
        bit force_single_beat = $test$plusargs("force_single_beat");
        int force_arlen;
        int idxq[$];
        string str;
        // Supporting variables to count OTT entries for performance monitor verification
        ORT_struct_t m_tmp_var;

        m_addr_mgr = addr_trans_mgr::get_instance();
        num_req = 0;

        m_read_addr_seq = axi_read_addr_seq::type_id::create("m_read_addr_seq"); 
        m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq");

        if (!$value$plusargs("force_arlen=%d", force_arlen)) begin 
            force_arlen = 0;
        end else begin 
        end

        //m_ace_cache_model.core_id=core_id;
        if($test$plusargs("perf_test")) begin
            perf_test = 1;
        end else begin
            perf_test = 0;
        end
        if($test$plusargs("perf_test_ace")) begin
            perf_test_ace= 1;
        end else begin
            perf_test_ace = 0;
        end


        if(perf_txn_size !=0 || $value$plusargs("perf_txn_size=%d", perf_txn_size)) begin
            perf_coh_txn_size = perf_txn_size;
            perf_noncoh_txn_size = perf_txn_size;
        end 


        if($value$plusargs("aiu_qos=%d", aiu_qos)) begin
            user_qos = 1;
        end
        if($test$plusargs("force_single_dvm")) begin
            force_single_dvm = 1;
            force_multi_dvm = 0;
        end
        if($test$plusargs("force_multi_dvm")) begin
            force_single_dvm = 0;
            force_multi_dvm = 1;
        end
    
        if($test$plusargs("multi_ACE_DVM_agents")) begin
            nDVMMSGCredit = <%=obj.nOttCtrlEntries%> -2; //CONC-7024
        end

        if($value$plusargs("<%=obj.BlockId%>_alt_qos_values=%d", num_alt_qos_values)) begin
            if(num_alt_qos_values <= 1) begin
                `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_alt_qos_values has to be greater than 1.  Specified value=%0d", num_alt_qos_values))
            end
            if(num_alt_qos_values > 1) begin
                if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos1=%d", aiu_qos1)) begin
                    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos1 not specified."))
                end
                if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos1_cycle=%d", aiu_qos1_cycle)) begin
                    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos1_cycle not specified."))
                end
                if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos2=%d", aiu_qos2)) begin
                    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos2 not specified."))
                end
                if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos2_cycle=%d", aiu_qos2_cycle)) begin
                    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos2_cycle not specified."))
                end
                total_aiu_qos_cycle = aiu_qos1_cycle + aiu_qos2_cycle;
            end
            if(num_alt_qos_values > 2) begin
                if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos3=%d", aiu_qos3)) begin
                    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos3 not specified."))
                end
                if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos3_cycle=%d", aiu_qos3_cycle)) begin
                    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos3_cycle not specified."))
                end
                total_aiu_qos_cycle += aiu_qos3_cycle;
            end
            if(num_alt_qos_values > 3) begin
                if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos4=%d", aiu_qos4)) begin
                    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos4 not specified."))
                end
                if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos4_cycle=%d", aiu_qos4_cycle)) begin
                    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos4_cycle not specified."))
                end
                total_aiu_qos_cycle += aiu_qos4_cycle;
            end
            if(num_alt_qos_values > 4) begin
                `uvm_error(get_full_name(), $sformatf("Only supporting maximum <%=obj.BlockId%>_alt_qos_values of 4.  Specified value=%0d", num_alt_qos_values))
            end
        end

        do begin
            bit [addrMgrConst::W_SEC_ADDR - 1 : 0] sec_addr;
            int                                   count;
            bit                                   done = 0;
            bit                                   is_coh = 0;
            axi_arid_t use_arid;
            
            if(s_rd[core_id] == null) s_rd[core_id] = new(1);
            s_rd[core_id].get();
            //`uvm_info(get_full_name(), $sformatf("sendDVMComplete:%0b", sendDVMComplete), UVM_LOW)
            
            if (k_num_read_req == 1) begin
                read_req_count++;
            end
            if (sendDVMComplete == 1) begin: _dvmcmpl_
                m_read_addr_seq.m_ace_rd_addr_chnl_snoop = DVMCMPL;
            end: _dvmcmpl_
            
            else begin: _not_dvmcmpl_
                int                                              wt_ace_dvm_msg_tmp;
                int                                              wt_ace_dvm_sync_tmp;
                wt_ace_dvm_msg_tmp = (nDVMMSGCredit > 1) ? wt_ace_dvm_msg : 0;
                wt_ace_dvm_sync_tmp = (nDVMMSGCredit > 1) ? wt_ace_dvm_sync : 0;
                if (((addrMgrConst::aiu_connected_dii_ids[<%=obj.FUnitId%>].ConnectedfUnitIds.size() == 0) ||
                    ((addrMgrConst::aiu_connected_dii_ids[<%=obj.FUnitId%>].ConnectedfUnitIds.size() == 1) && (addrMgrConst::aiu_connected_dii_ids[<%=obj.FUnitId%>].ConnectedfUnitIds[0] == addrMgrConst::funit_ids[addrMgrConst::diiIds[addrMgrConst::get_sys_dii_idx()]]))) //no normal txn dii connected
                    && (m_addr_mgr.noncoh_addr_region_mapped_to_dmi() == 0) //all dmi are mapped to coh region only
                   ) begin
                    wt_ace_rdnosnp = 0;
                    `uvm_info(get_full_name(), $sformatf("Forced rdnosnp wt to 0"), UVM_LOW);
                    wt_ace_rdonce = 1; //Need at least one transaction wt enabled.
                end 
                
                count = 0;
                do begin
                    randcase
                        wt_ace_rdnosnp       : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDNOSNP;
                        wt_ace_rdonce        : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDONCE;
                        wt_ace_rdshrd        : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDSHRD;
                        wt_ace_rdcln         : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDCLN;
                        wt_ace_rdnotshrddty  : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDNOTSHRDDIR;
                        wt_ace_rdunq         : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDUNQ;
                        wt_ace_clnunq        : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = CLNUNQ;
                        wt_ace_mkunq         : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = MKUNQ;
                        wt_ace_clnshrd       : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = CLNSHRD;
                        wt_ace_clninvl       : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = CLNINVL;
                        wt_ace_mkinvl        : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = MKINVL;
                        wt_ace_rd_cln_invld  : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDONCECLNINVLD;
                        wt_ace_rd_make_invld : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDONCEMAKEINVLD;
                        wt_ace_clnshrd_pers  : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = CLNSHRDPERSIST;
  
                        <%if(obj.nDvmMsgInFlight > 0){%>
                            wt_ace_dvm_msg_tmp      : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = DVMMSG;
                            wt_ace_dvm_sync_tmp     :begin
                                m_read_addr_seq.m_ace_rd_addr_chnl_snoop = DVMMSG; 
                                isDvmSync = 1;
                            end
                        <% } %>
                    endcase
//`uvm_info(get_full_name(),$psprintf("wt_ace_rdnosnp %0d ,wt_ace_rdonce %0d ,wt_ace_rdshrd %0d ,wt_ace_rdcln %0d ,wt_ace_rdnotshrddty %0d ,wt_ace_rdunq %0d ,wt_ace_clnunq %0d ,wt_ace_mkunq %0d ,wt_ace_clnshrd %0d ,wt_ace_clninvl %0d ,wt_ace_mkinvl %0d ,wt_ace_rd_cln_invld %0d ,wt_ace_rd_make_invld %0d ,wt_ace_clnshrd_pers %0d", wt_ace_rdnosnp,wt_ace_rdonce,wt_ace_rdshrd,wt_ace_rdcln,wt_ace_rdnotshrddty,wt_ace_rdunq,wt_ace_clnunq,wt_ace_mkunq,wt_ace_clnshrd,wt_ace_clninvl,wt_ace_mkinvl,wt_ace_rd_cln_invld,wt_ace_rd_make_invld,wt_ace_clnshrd_pers),UVM_LOW)
 //           	    `uvm_info(get_full_name(), $sformatf("After randcase. cmdtype = %0s", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name()), UVM_LOW);
                    if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMMSG) begin: _dvm_
                        done = 1;
                    end: _dvm_
                    else begin: _not_dvm_
                        if(k_access_boot_region == 1) begin: _boot_region_
                            use_addr_from_test = 1;
                            if(m_read_addr_seq.m_ace_rd_addr_chnl_snoop == RDNOSNP) begin
                                m_ace_rd_addr_from_test = m_ace_cache_model.m_addr_mgr.get_noncohboot_addr(<%=obj.FUnitId%>, 1, core_id);
                            end else begin
                                m_ace_rd_addr_from_test = m_ace_cache_model.m_addr_mgr.get_cohboot_addr(<%=obj.FUnitId%>, 1, core_id);
                            end
                            <% if (obj.wSecurityAttribute > 0) { %>                                             
                                m_ace_rd_security_from_test = 0;
                            <% } %>
                        end: _boot_region_
                        <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
                        while ((m_ace_cache_model.m_ort.size == m_ace_cache_model.max_number_of_outstanding_txn) || (m_ace_cache_model.m_ort.size >= m_ace_cache_model.user_addrq[addrMgrConst::COH].size() && $test$plusargs("use_user_addrq") && m_ace_cache_model.calculate_is_coh(m_read_addr_seq.m_ace_rd_addr_chnl_snoop))) begin
                            @m_ace_cache_model.e_ort_delete;
                        end
            if (m_ace_cache_model.m_ort.size > m_ace_cache_model.max_number_of_outstanding_txn) begin
	        `uvm_error("AXI_SEQ",$sformatf("axi_master_read_seq cache txn m_ort_size :%0d greater than max_number_of_outstanding_txn :%0d",m_ace_cache_model.m_ort.size, m_ace_cache_model.max_number_of_outstanding_txn));
            end
                        <%}%>
                         if($test$plusargs("use_user_addrq") && count > 30 ) begin
                         num_coh_addr_in_ort = {};
                         num_noncoh_addr_in_ort = {};
                         num_noncoh_addr_in_ort = m_ace_cache_model.m_ort.find_index with (addrMgrConst::get_addr_gprar_nc(item.m_addr) == 1 && m_ace_cache_model.calculate_is_coh(item.m_cmdtype) ==0);
                         num_coh_addr_in_ort    = m_ace_cache_model.m_ort.find_index with (addrMgrConst::get_addr_gprar_nc(item.m_addr) == 0 && m_ace_cache_model.calculate_is_coh(item.m_cmdtype) ==1);
                         if(num_coh_addr_in_ort.size() >= m_ace_cache_model.user_addrq[addrMgrConst::COH].size()) begin
                         @m_ace_cache_model.e_ort_delete;
                         end else if(num_noncoh_addr_in_ort.size() >= m_ace_cache_model.user_addrq[addrMgrConst::NONCOH].size() )begin
                         @m_ace_cache_model.e_ort_delete;
                         end
	                //`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("axi_master_read_seq ort size after:%0d", m_ace_cache_model.m_ort.size()), UVM_LOW);
                         end

                        done                          = m_ace_cache_model.give_addr_for_ace_req_read(id, m_read_addr_seq.m_ace_rd_addr_chnl_snoop, m_read_addr_seq.m_ace_rd_addr_chnl_addr
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            ,m_read_addr_seq.m_ace_rd_addr_chnl_security
                        <% } %>
                        ,is_coh
                        ,use_addr_from_test, m_ace_rd_addr_from_test
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            ,m_ace_rd_security_from_test
                        <% } %>                                                
                        );

                        //`uvm_info("axi_read_addr_seq", $sformatf("Just after cache model exit AXI[%0d] txn- addr:0x%0h sec:%0d", id, m_read_addr_seq.m_ace_rd_addr_chnl_addr, m_read_addr_seq.m_ace_rd_addr_chnl_security), UVM_LOW)
                  end: _not_dvm_
                    count++;
                    if (count > 50) begin
                        uvm_report_error("ACE BFM SEQ AIU <%=my_ioaiu_id%>", $sformatf("TB Error: Infinite loop possibility in read seq do-while loop"), UVM_NONE);
                    end
                end while (!done);
               
            end: _not_dvmcmpl_

          

            m_read_addr_seq.m_constraint_snoop = 1;
            m_read_addr_seq.should_randomize   = 0;
            m_read_addr_seq.m_seq_item         = axi_rd_seq_item::type_id::create("m_seq_item");
            m_seq_item                         = axi_rd_seq_item::type_id::create("m_seq_item");

            <%if((obj.testBench == "io_aiu" && obj.useCache) && (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) {%>
               if($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test") || $test$plusargs("address_error_test_data")) begin 
               //Force all addresses in the test to go to DataBank
               <%for( var i=0; i< Math.log2(obj.nDataBanks); i++){%>
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr[<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits[obj.AiuInfo[obj.Id].ccpParams.DataBankSelBits[i]]%>] = sel_bank[<%=i%>];
              <%}%>
              end
		<%}%>
          <% if(obj.testBench =="io_aiu" && (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) { %>
if($test$plusargs("address_error_test_ott") || $test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test"))begin
             m_read_addr_seq.m_ace_rd_addr_chnl_addr[<%=!obj.useCache ? 6 :obj.AiuInfo[obj.Id].ccpParams.wCacheLineOffset%> -1 : <%=Math.log2(obj.AiuInfo[obj.Id].ccpParams.wData/8)%>] = sel_ott_bank;
end
            <%}%>
              if ((!(m_read_addr_seq.m_ace_rd_addr_chnl_snoop inside {RDNOSNP,RDONCE})) && force_single_beat) begin
              force_single_beat = 0;
              end
                if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMCMPL) begin 
                    get_axid(m_read_addr_seq.m_ace_rd_addr_chnl_snoop, use_arid);
                end else if(en_force_axid) begin // newperf test case same AxID on each txn
                    use_arid = ioaiu_force_axid;
                end else begin 
                    get_axid(m_read_addr_seq.m_ace_rd_addr_chnl_snoop, use_arid, firstReqDone);
                end  

            if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMMSG  ||
                m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMCMPL
            ) begin
                if(m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMMSG) begin
                    nDVMMSGCredit--;
                end

                success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
                    // Fix for weird monitor issue that is not getting the first request only if arid is 0
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.include_arid_0 == firstReqDone;
                    //#Stimulus.IOAIU.DVM.TxnCostraint.axid 
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid           == use_arid;
                    solve m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype before m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsnoop;
                    if (m_read_addr_seq.m_constraint_snoop == 1) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
                    //#Stimulus.IOAIU.DVM.TxnCostraint.araddr.MsgType
                    if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMMSG && isDVMSyncOutStanding) m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr[14:12] inside {'b000, 'b001, 'b010, 'b011, 'b110};
                    if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMMSG && isDvmSync && !isDVMSyncOutStanding) m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr[14:12] == 'b100;
                    //#Stimulus.IOAIU.DVM.TxnCostraint.araddr.MsgAddr
                    if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMMSG && force_single_dvm) m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr[0] == 0;
                    if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMMSG && force_multi_dvm) m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr[0] == 1;
                    if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMCMPL) m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr == 'h0;
                };
            end
           
            else begin
                m_read_addr_seq.m_constraint_addr  = 1;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.constrained_addr = 1;
                success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
                    // Fix for weird monitor issue that is not getting the first request only if arid is 0
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.include_arid_0 == firstReqDone; 
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid           == use_arid;
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.coh_domain     == is_coh;
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.useFullCL      == ((use_addr_from_test & !m_ace_rd_two_line_multicl) || use_full_cl);
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.use2FullCL     == (use_addr_from_test & m_ace_rd_two_line_multicl & ~use_full_cl);
                    if (use_addr_from_test & m_ace_rd_two_line_multicl) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == AXIWRAP;
                    if (m_read_addr_seq.m_constraint_snoop == 1) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
                    if (m_read_addr_seq.m_constraint_addr  == 1) m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr    == m_read_addr_seq.m_ace_rd_addr_chnl_addr;
                    if (use_burst_wrap) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == AXIWRAP;
                    if (use_burst_incr) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == AXIINCR;
                    if (user_qos)       m_read_addr_seq.m_seq_item.m_read_addr_pkt.arqos == aiu_qos;
                    if(local::force_single_beat) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen == 0;
                    if(local::force_arlen > 0) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen == force_arlen;
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        if (m_read_addr_seq.m_constraint_addr  == 1) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1] == m_read_addr_seq.m_ace_rd_addr_chnl_security;
                    <% } %>
                };
            
                //`uvm_info("axi_read_addr_seq", $sformatf("Just after randomize AXI[%0d] txn: %s", id,m_read_addr_seq.m_seq_item.convert2string()), UVM_LOW)
                if( $test$plusargs("perf_test") && m_read_addr_seq.m_constraint_addr &&
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr != m_read_addr_seq.m_ace_rd_addr_chnl_addr) begin
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr = m_read_addr_seq.m_ace_rd_addr_chnl_addr ;   
                end

	 
                if($test$plusargs("force_single_txn") && use_burst_incr) begin // To be used with use_burst_incr
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen = 0;
                end
                if(m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == AXIWRAP) begin
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr[WLOGXDATA-1:0] = 'h0;
                end
                if (perf_test == 1 ||perf_test_ace == 1) begin
                    if(force_axlen_256B)begin
                        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen = 256 / (2**m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsize) - 1;// 256B transfer for performance test
                        /*
                        if ( (m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr + 
                        ((m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen+1) * (2**m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsize))) % 4096
                        <= m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr % 4096 ) begin
                            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen = 'h0 ;  // Limit burstsize to not cross 4kB 
                        boundary
                        end
                        */
                    end else begin
                        if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop == RDNOSNP)
                            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen = (((perf_noncoh_txn_size*8)/WXDATA) - 1); 
                        else 
                            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen = (((perf_coh_txn_size*8)/WXDATA) - 1);  
                    end
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsize = WLOGXDATA;
                end
                      if(use_axcache_from_test) begin
                        `uvm_info("AXI SEQ", $sformatf("use_axcache_from_test - araddr = 0x%0h", m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr), UVM_MEDIUM)
                        if(m_ace_cache_model.m_addr_mgr.get_addr_target_unit(m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr) == 0) begin
                            $cast(m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache , 4'hf);
                            $cast(m_read_addr_seq.m_seq_item.m_read_addr_pkt.ardomain , 'h0);
                        end
                    end
                    else if(perf_test == 1 ||perf_test_ace == 1) begin
                        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[0] = 1'b0;
                        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1] = 1'b0; // secure access
                        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[2] = 1'b0; // Data access
                        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlock = axi_axlock_enum_t'(0);
                        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst = AXIINCR; 

                        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[3:0] = 1; // by default bufferable 
                        if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop == RDNOSNP) begin:noncoh_rd_case
                            if($test$plusargs("force_noncoh_allocate_txn")) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[3:2] = 2'b11; 
                            if($test$plusargs("force_noncoh_cacheable_txn"))   m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[1] = 1; 
                            if($test$plusargs("force_noncoh_unbufferable_txn"))  m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[0] = 1'b0; 
                            m_read_addr_seq.m_seq_item.m_read_addr_pkt.ardomain = axi_axdomain_enum_t'(0);
                        end:noncoh_rd_case	
                        else begin:coh_rd_case
                            if($test$plusargs("force_coh_allocate_txn")) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[3:2] = 2'b11; 
                            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[1] = 1; 
                            if($test$plusargs("force_coh_unbufferable_txn"))  m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[0] = 1'b0; 
                            m_read_addr_seq.m_seq_item.m_read_addr_pkt.ardomain = axi_axdomain_enum_t'(2);
                        end:coh_rd_case 
                    
                        if($test$plusargs("force_allocate_txn"))    m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[3:2] = 2'b11; 
                        if($test$plusargs("force_cacheable_txn"))   m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[1] = 1; 
                        if($test$plusargs("force_unbufferable_txn"))  m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[0] = 1'b0; 
                        if($test$plusargs("force_non_allocate_txn"))    m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[3:2] = 2'b00; 
                        if($test$plusargs("force_non_cacheable_txn"))   m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[1] = 1'b0; 
                    end		// end perf_test										   
                    if($test$plusargs("k_axcache_0_to_dii")) begin
                    if(m_ace_cache_model.m_addr_mgr.get_addr_target_unit(m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr) == 1) begin
                        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[3:1] = 3'b000;
	                if(m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == RDNOSNP) m_read_addr_seq.m_seq_item.m_read_addr_pkt.ardomain = axi_axdomain_enum_t'(3);
                    end
                end       
                //if (this.m_wr_bar_seq_item_q.size() > 0) begin
                //    this.m_count_of_requests_till_barrier++;
                //end

                if(num_alt_qos_values > 1) begin
                    if(qos_cycle_count < aiu_qos1_cycle) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arqos = aiu_qos1;
                    else if(qos_cycle_count < (aiu_qos1_cycle + aiu_qos2_cycle)) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arqos = aiu_qos2;
                    else if(qos_cycle_count < (aiu_qos1_cycle + aiu_qos2_cycle + aiu_qos3_cycle)) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arqos = aiu_qos3;
                    else m_read_addr_seq.m_seq_item.m_read_addr_pkt.arqos = aiu_qos4;

                    qos_cycle_count += 1;
                    if(qos_cycle_count == total_aiu_qos_cycle) qos_cycle_count = 0;
                end
            end
            if (!firstReqDone) begin
                firstReqDone = 1;
            end
            if (!success) begin
                uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_master_read_seq is_coh:%0d use_addr_from_test:%0d m_ace_rd_two_line_multicl:%0d use_full_cl:%0d cmdtype:%0s addr:0x%0h",is_coh, use_addr_from_test, m_ace_rd_two_line_multicl, use_full_cl,m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), m_read_addr_seq.m_ace_rd_addr_chnl_addr), UVM_NONE);
            end else begin 
                //`uvm_info("AXI SEQ", $sformatf("m_read_addr_seq.m_ace_rd_addr_chnl_security:%0d arprot_1:%0d", m_read_addr_seq.m_ace_rd_addr_chnl_security, m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1]), UVM_LOW);
            end 
            m_read_addr_seq.m_ace_rd_addr_chnl_addr     = m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr;
            
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                m_read_addr_seq.m_ace_rd_addr_chnl_security = m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1];
            <% } %>
            //uvm_report_info("ACE BFM SEQ AIU <%=my_ioaiu_id%>", $sformatf("RD snooptype %0s addr 0x%0x secure bit 0x%0x arid 0x%0x  arsnoop 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), m_read_addr_seq.m_ace_rd_addr_chnl_addr, 
            //<% if (obj.wSecurityAttribute > 0) { %>                                             
            //    m_read_addr_seq.m_ace_rd_addr_chnl_security, 
            //<% } else { %>                                                
            //    0,
            //<% } %>
            //m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid,  m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsnoop), UVM_LOW);
            if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMMSG &&
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr[14:12] == 'b100
            ) begin
                isDVMSyncOutStanding = 1;
            end
            if (!(m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMMSG  ||
                m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMCMPL)
            ) begin
                sec_addr = m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr;
                <%if (obj.wSecurityAttribute > 0) { %>
                    sec_addr[addrMgrConst::W_SEC_ADDR - 1] = m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1];
             <% if(obj.testBench == "fsys") { %>
             if ($test$plusargs("random_gpra_nsx")) begin
                 //#Stimulus.FSYS.GPRAR.NS_zero.withatleast.oneTxnSecure
                 m_read_addr_seq.m_ace_rd_addr_chnl_security = m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1] ;
             end
             <% } %>                     
                <%}%>

                m_addr_mgr.set_addr_in_agent_mem_map(sec_addr, <%=obj.AiuInfo[obj.Id].FUnitId%>);
                m_ace_cache_model.update_addr(m_read_addr_seq.m_ace_rd_addr_chnl_snoop, m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        ,.security(m_read_addr_seq.m_ace_rd_addr_chnl_security)
                    <% } %>
                );
            end
            if (pwrmgt_power_down == 1 && m_read_addr_seq.m_ace_rd_addr_chnl_snoop != DVMCMPL) begin
                wait(pwrmgt_power_down == 0);
                s_rd[core_id].put();
                continue;
            end
            m_tmp_q = {};
            m_tmp_q = m_ace_cache_model.m_ort.find_index with (item.isRead == 1
                && item.m_addr == m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    && item.m_security == m_read_addr_seq.m_ace_rd_addr_chnl_security
                <% } %>
            && item.isReqInFlight == 0);
            if (m_tmp_q.size > 0) begin
                m_ace_cache_model.m_ort[m_tmp_q[0]].isReqInFlight = 1;
            end
            <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5"){ %> 
            if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop inside {DVMMSG, DVMCMPL}) begin
	       //`uvm_info($sformatf("AXI SEQ%s", get_full_name()), $sformatf("axi_master_read_seq dvm ort size before:%0d", m_ace_cache_model.m_ort.size()), UVM_LOW);
               while (m_ace_cache_model.m_ort.size == m_ace_cache_model.max_number_of_outstanding_txn) begin
                   @m_ace_cache_model.e_ort_delete;
               end
	       //`uvm_info($sformatf("ACE CACHE MODEL%s", get_full_name()), $sformatf("axi_master_read_seq dvm ort size after:%0d", m_ace_cache_model.m_ort.size()), UVM_LOW);
                m_tmp_var.m_cmdtype=m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype;
                m_tmp_var.m_addr=m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr;
                m_tmp_var.isUpdate=0;
                m_tmp_var.isRead=0;
                m_tmp_var.t_creation = $time;
                m_tmp_var.isReqInFlight = 1;
                m_ace_cache_model.m_ort.push_back(m_tmp_var);
            end
            <% } %> 
            
            `uvm_info("axi_read_addr_seq", $sformatf("Sending AXI[%0d] txn: %s", id,m_read_addr_seq.m_seq_item.convert2string()), UVM_LOW)
            m_read_addr_seq.return_response(m_seq_item, m_read_addr_chnl_seqr);
            if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMMSG && !sendDVMComplete) begin
                //m_ace_cache_model.num_outstanding_dvms++;
                m_ace_cache_model.outstanding_dvm_axidq.push_back(m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid);
                str = "";
                foreach (m_ace_cache_model.outstanding_dvm_axidq[i]) str = $sformatf("%0s 0x%0h", str, m_ace_cache_model.outstanding_dvm_axidq[i]);
                //`uvm_info("axi_read_addr_seq", $sformatf("AR 1st part outstanding dvmq - %0s", str), UVM_LOW)
            end
            ev_rd_req_done.trigger(null); // newperf test generate a event
            if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMCMPL) begin
                sendDVMComplete = 0;
                // Want to only increment when in the middle of simulation. If a DVMCMPL is sent in the end, we do not need to send a new read request
                //if (read_req_count < read_req_total_count) begin
                //    k_num_read_req++;
                //end
            end
            // Sending a multi-part DVM Op message
            if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop             == DVMMSG &&
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr[0] == 1
            ) begin

                axi_rd_seq_item   m_seq_item_tmp;
                axi_read_addr_seq m_read_addr_seq_tmp;
                nDVMMSGCredit--;
                m_read_addr_seq_tmp                                                                            = axi_read_addr_seq::type_id::create("m_read_addr_seq_tmp");
                m_read_addr_seq_tmp.m_constraint_snoop                                                         = 1;
                m_read_addr_seq_tmp.m_constraint_addr                                                          = 1;
                m_read_addr_seq_tmp.should_randomize                                                           = 0;
                m_read_addr_seq_tmp.m_seq_item                                                                 = axi_rd_seq_item::type_id::create("m_seq_item_tmp");
                m_read_addr_seq_tmp.m_seq_item.do_copy(m_read_addr_seq.m_seq_item);
                //#Stimulus.IOAIU.DVM.TxnCostraint.araddrpart2
                m_read_addr_seq_tmp.m_seq_item.m_read_addr_pkt.araddr[WAXADDR-1:12] = $urandom;
           
                m_read_addr_seq_tmp.m_seq_item.m_read_addr_pkt.araddr[2:0]          = 0;

                 <% if (obj.DVMVersionSupport >= 132) { /*DVMVersionSupport  = 132 -> DVM v8.4  */ %> 
                if(m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr[7]==1  && m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr[14:12]==0)
                begin
                   m_read_addr_seq_tmp.m_seq_item.m_read_addr_pkt.araddr[5:0]          = $urandom;
                end else begin
                   m_read_addr_seq_tmp.m_seq_item.m_read_addr_pkt.araddr[5:0]          = 0;
                end

            <% } %>

                <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5"){ %> 
	            //`uvm_info($sformatf("AXI SEQ%s", get_full_name()), $sformatf("axi_master_read_seq dvm 2nd part ort size before:%0d", m_ace_cache_model.m_ort.size()), UVM_LOW);
                    while (m_ace_cache_model.m_ort.size == m_ace_cache_model.max_number_of_outstanding_txn) begin
                        @m_ace_cache_model.e_ort_delete;
                    end
	            //`uvm_info($sformatf("AXI SEQ%s", get_full_name()), $sformatf("axi_master_read_seq dvm 2nd part ort size after:%0d", m_ace_cache_model.m_ort.size()), UVM_LOW);
                    m_tmp_var.m_cmdtype=m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype;
                    m_tmp_var.m_addr=m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr;
                    m_tmp_var.isUpdate=0;
                    m_tmp_var.isRead=0;
                    m_tmp_var.t_creation = $time;
                    m_tmp_var.isReqInFlight = 1;
                    m_ace_cache_model.m_ort.push_back(m_tmp_var);
                <% } %> 

                `uvm_info("axi_read_addr_seq", $sformatf("Sending AXI txn(2nd part of DVM): %s", m_read_addr_seq_tmp.m_seq_item.convert2string()), UVM_LOW)
                m_read_addr_seq_tmp.return_response(m_seq_item_tmp, m_read_addr_chnl_seqr);
                if (!sendDVMComplete) m_ace_cache_model.outstanding_dvm_axidq.push_back(m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid);
                str = "";
                foreach (m_ace_cache_model.outstanding_dvm_axidq[i]) str = $sformatf("%0s 0x%0h", str, m_ace_cache_model.outstanding_dvm_axidq[i]);
                //`uvm_info("axi_read_addr_seq", $sformatf("AR 2nd part outstanding dvmq - %0s", str), UVM_LOW)
            end
            if (!(m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMCMPL && pwrmgt_power_down == 1)) begin
                s_rd[core_id].put();
            end
            //s_rd.put();
            // Blocking till previous request with same arid has a response that has been received
            if(!en_force_axid) begin // newperf test case same AxID on each txn
                wait_till_arid_latest(m_read_addr_seq.m_seq_item.m_read_addr_pkt);
            end
            m_read_data_seq.m_seq_item       = m_seq_item;
            m_read_data_seq.should_randomize = 0;
            m_read_data_seq.return_response(m_seq_item, m_read_data_chnl_seqr);

            if(m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMCMPL) begin
                m_tmp_q = {};
                m_tmp_q = m_ace_cache_model.m_ort.find_first_index with (item.m_cmdtype == DVMCMPL);
                if(m_tmp_q.size()>0) begin
                   m_ace_cache_model.m_ort.delete(m_tmp_q[0]);
                   ->m_ace_cache_model.e_ort_delete;
                end
            end

            if(m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMMSG) begin
                nDVMMSGCredit++;
                if (m_ace_cache_model.outstanding_dvm_axidq.size() > 0) begin 
                    idxq = {};
                    idxq = m_ace_cache_model.outstanding_dvm_axidq.find_index with(item == m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid);
                    if (idxq.size() > 0) begin
                        m_ace_cache_model.outstanding_dvm_axidq.delete(idxq[0]);
                    end
                    str = "";
                    foreach (m_ace_cache_model.outstanding_dvm_axidq[i]) str = $sformatf("%0s 0x%0h", str, m_ace_cache_model.outstanding_dvm_axidq[i]);
                    //`uvm_info(get_full_name(), $sformatf("RdRsp 1st part - outstanding dvmq - %0s", str), UVM_LOW)
                end
                m_tmp_q = {};
                m_tmp_q = m_ace_cache_model.m_ort.find_first_index with ( item.m_cmdtype == DVMMSG);
                if(m_tmp_q.size()>0) begin
                   m_ace_cache_model.m_ort.delete(m_tmp_q[0]);
                ->m_ace_cache_model.e_ort_delete;
                end

                ->dvm_resp_rcvd;
            end
            if (m_read_addr_seq.m_ace_rd_addr_chnl_snoop             == DVMMSG &&
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr[0] == 1
            ) begin
                axi_read_data_seq m_read_data_seq_tmp;
                m_read_data_seq_tmp                  = axi_read_data_seq::type_id::create("m_read_data_seq_tmp");
                m_read_data_seq_tmp.m_seq_item       = m_seq_item;
                m_read_data_seq_tmp.should_randomize = 0;
                m_read_data_seq_tmp.return_response(m_seq_item, m_read_data_chnl_seqr);
                nDVMMSGCredit++;
                if (m_ace_cache_model.outstanding_dvm_axidq.size() > 0) begin 
                    idxq = {};
                    idxq = m_ace_cache_model.outstanding_dvm_axidq.find_index with(item == m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid);
                    if (idxq.size() > 0) begin
                        m_ace_cache_model.outstanding_dvm_axidq.delete(idxq[0]);
                    end
                    str = "";
                    foreach (m_ace_cache_model.outstanding_dvm_axidq[i]) str = $sformatf("%0s 0x%0h", str, m_ace_cache_model.outstanding_dvm_axidq[i]);
                    //`uvm_info(get_full_name(), $sformatf("RdRsp 2nd part - outstanding dvmq - %0s", str), UVM_LOW)
                end
                m_tmp_q = {};
                m_tmp_q = m_ace_cache_model.m_ort.find_first_index with ( item.m_cmdtype == DVMMSG);
                if(m_tmp_q.size()>0) begin
                   m_ace_cache_model.m_ort.delete(m_tmp_q[0]);
                ->m_ace_cache_model.e_ort_delete;
                end
                ->dvm_resp_rcvd;
            end
            if(!en_force_axid) begin // newperf test case same AxID on each txn
                delete_ott_entry(m_read_addr_seq.m_seq_item.m_read_addr_pkt);
            end  
                        <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
                if (!(m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMMSG  ||
                    m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMCMPL)
                ) begin
                    axi_bresp_t m_tmp_bresp[];
                    m_tmp_bresp = new[m_seq_item.m_read_data_pkt.rresp_per_beat.size()];
                    foreach (m_tmp_bresp[i]) begin
                        m_tmp_bresp[i] = m_seq_item.m_read_data_pkt.rresp_per_beat[i][CRRESP-1:0];
                    end
                    m_ace_cache_model.modify_cache_line(m_seq_item.m_read_addr_pkt.araddr, m_read_addr_seq.m_ace_rd_addr_chnl_snoop, m_tmp_bresp, m_seq_item.m_read_data_pkt.rdata, , m_seq_item.m_read_addr_pkt.arsize,m_seq_item.m_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT], m_seq_item.m_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT], ((m_seq_item.m_read_addr_pkt.arlock == 1) ? (m_seq_item.m_read_data_pkt.rresp_per_beat[0][1:0] == EXOKAY) : 1),.axdomain(m_seq_item.m_read_addr_pkt.ardomain)
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        ,.security(m_seq_item.m_read_addr_pkt.arprot[1])
                    <% } %>                                                
                    );
                end
            <% } else { %>
                 m_tmp_q = {};
                 m_tmp_q = m_ace_cache_model.m_ort.find_index with (item.isRead == 1
                     && item.m_addr == m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr
                 <% if (obj.wSecurityAttribute > 0) { %>                                             
                     && item.m_security == m_read_addr_seq.m_ace_rd_addr_chnl_security
                 <% } %>
                     && item.m_cmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop);

                 if(m_tmp_q.size() > 0) begin
                 m_ace_cache_model.m_ort.delete(m_tmp_q[0]);
                 ->m_ace_cache_model.e_ort_delete;
                 end

                //informing address manager that response for cacheline is received
                //For all NCB's this logic will be triggered and we evict on response
                sec_addr = m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr;
                <%if (obj.wSecurityAttribute > 0) { %>                                             
                    sec_addr[addrMgrConst::W_SEC_ADDR - 1] = m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1];
                <%} %>
                if (!(
                    m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMMSG  ||
                    m_read_addr_seq.m_ace_rd_addr_chnl_snoop == DVMCMPL)
                ) begin
                    m_addr_mgr.addr_evicted_from_agent(
                    <%=obj.AiuInfo[obj.Id].FUnitId%>, 1, sec_addr);
                end
            <% } %>
            num_req++;

        end while (num_req < k_num_read_req);

        `uvm_info("body", "Exiting...", UVM_LOW)
    endtask : body

endclass : axi_master_read_seq

class axi_master_read_seq_err extends axi_master_read_seq;
    `uvm_object_param_utils(axi_master_read_seq_err)
     //------------------------------------------------------------------------------
     // Constructor
     //------------------------------------------------------------------------------
     function new(string name = "axi_master_read_seq_err");
        super.new(name);
        user_qos = 0;
     endfunction : new
     task body;
	    int                         num_req;
            bit                         success;
            int                         m_tmp_q[$];
            addr_trans_mgr              m_addr_mgr;
            axi_axaddr_t                base_addr;
            axi_arid_t use_arid;
	    addrMgrConst::sys_addr_csr_t csr_q[$];
            axi_axaddr_t random_unmapped_addr;
            bit unmapped_add_access = $test$plusargs("unmapped_add_access");

            m_addr_mgr = addr_trans_mgr::get_instance();
            num_req = 0;
            m_read_addr_seq = axi_read_addr_seq::type_id::create("m_read_addr_seq"); 
            m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 

            m_read_addr_seq.m_seq_item         = axi_rd_seq_item::type_id::create("m_seq_item");
            m_seq_item                         = axi_rd_seq_item::type_id::create("m_seq_item");
            get_axid(m_read_addr_seq.m_ace_rd_addr_chnl_snoop, use_arid);
            //Randomize Read Addr packet

            //	    m_read_addr_seq.m_ace_rd_addr_chnl_addr = m_addr_mgr.gen_noncoh_addr(<%=obj.FUnitId%>, 1);
            csr_q = addrMgrConst::get_all_gpra();
            if(s_rd[core_id] == null) s_rd[core_id] = new(1);
            s_rd[core_id].get();
	    m_tmp_q = {};
	    m_tmp_q = csr_q.find_index with (
		 item.unit == addrMgrConst::DII
	    );
             if (!$test$plusargs("unmapped_add_access"))begin 
                wt_ace_rdnosnp = 0 ;
             end

           randcase
                        wt_ace_rdnosnp       : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDNOSNP;
                        wt_ace_rdonce        : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDONCE;
                        wt_ace_rdshrd        : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDSHRD;
                        wt_ace_rdcln         : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDCLN;
                        wt_ace_rdnotshrddty  : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDNOTSHRDDIR;
                        wt_ace_rdunq         : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDUNQ;
                        wt_ace_clnunq        : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = CLNUNQ;
                        wt_ace_mkunq         : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = MKUNQ;
                        wt_ace_clnshrd       : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = CLNSHRD;
                        wt_ace_clninvl       : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = CLNINVL;
                        wt_ace_mkinvl        : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = MKINVL;
                        wt_ace_rd_cln_invld  : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDONCECLNINVLD;
                        wt_ace_rd_make_invld : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDONCEMAKEINVLD;
                        wt_ace_clnshrd_pers  : m_read_addr_seq.m_ace_rd_addr_chnl_snoop = CLNSHRDPERSIST;

            endcase

            //#Stimulus.IOAIU.IllegaIOpToDII.DECERR
	    m_tmp_q[0] = m_tmp_q[$urandom_range(0,m_tmp_q.size()-1)];
            base_addr = {csr_q[m_tmp_q[0]].upp_addr,csr_q[m_tmp_q[0]].low_addr} << 12;
            read_req_count = read_req_count + 1;
           success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
	       m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype ==  m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid      == use_arid;
                    `ifdef VCS
		    if(m_read_addr_seq.m_ace_rd_addr_chnl_snoop inside{RDONCE,RDSHRD,RDCLN,RDNOTSHRDDIR,RDUNQ,CLNUNQ,MKUNQ}) 
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.coh_domain == 1;
		    if(m_read_addr_seq.m_ace_rd_addr_chnl_snoop== RDNOSNP) 
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.coh_domain == 0;
                    `endif
               if (!local::unmapped_add_access) { ! (m_read_addr_seq.m_seq_item.m_read_addr_pkt.ardomain inside {0,3}); }//
               if (local::unmapped_add_access) {
               !( m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr inside {[addrMgrConst::BOOT_REGION_BASE : (addrMgrConst::BOOT_REGION_BASE + addrMgrConst::BOOT_REGION_SIZE)]});
                                                               !( m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr inside {[addrMgrConst::NRS_REGION_BASE : (addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE)]});
                                                     foreach(addrMgrConst::memregion_boundaries[idx]) {
                                                       !( m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr inside {[addrMgrConst::memregion_boundaries[idx].start_addr : addrMgrConst::memregion_boundaries[idx].end_addr]});
                                                     } } 
               else {
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr    >= base_addr;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr    < base_addr + (2**(csr_q[m_tmp_q[0]].size + 12)) - ((m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen +1) * 2**m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsize);
                }                  
	       m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == AXIINCR;
               <% if (obj.wSecurityAttribute > 0) { %>
                  m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1] == m_read_addr_seq.m_ace_rd_addr_chnl_security;
               <% } %>                                                
            };

            if(!success)
	   uvm_report_error("AXI_SEQ",$sformatf("Failed randomization"),UVM_NONE);
	
            if ($test$plusargs("unmapped_add_access")) begin
 	    <%if(obj.AiuInfo[obj.Id].aNcaiuIntvFunc===undefined || obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits===undefined || !obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits.length){}else{%>
            <%for(var i=0; i<obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits.length; i++){%>
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr[<%=obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[i]%>] = core_id[<%=i%>];
             <%}%>
	     <%}%>
            end
             
            if($test$plusargs("force_single_txn") && use_burst_incr)begin
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen = 0;
            end
	    m_seq_item = m_read_addr_seq.m_seq_item;
	    m_read_addr_seq.m_ace_rd_addr_chnl_snoop = m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype;
//	    uvm_report_info("DCDEBUG",$sformatf("m_seq_item.addr = 0x%0h, seq = 0x%0h",m_seq_item.m_read_addr_pkt.araddr,m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr),UVM_MEDIUM);
//	    uvm_report_info("DCDEBUG",$sformatf("gen_coh_addr"),UVM_MEDIUM);
            m_read_addr_seq.return_response(m_read_addr_seq.m_seq_item, m_read_addr_chnl_seqr);
            wait_till_arid_latest(m_read_addr_seq.m_seq_item.m_read_addr_pkt);
	    m_read_data_seq.m_seq_item       = m_read_addr_seq.m_seq_item;
            m_read_data_seq.should_randomize = 0;
            m_read_data_seq.return_response(m_read_addr_seq.m_seq_item, m_read_data_chnl_seqr);
            delete_ott_entry(m_read_addr_seq.m_seq_item.m_read_addr_pkt);
     	    s_rd[core_id].put();
	endtask													   
endclass // axi_master_read_seq_err

class axi_master_write_noncoh_seq_err extends axi_master_write_noncoh_seq;
    `uvm_object_param_utils(axi_master_write_noncoh_seq_err)
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_master_write_noncoh_seq");
        super.new(name);
    endfunction : new
    
    task body;
        int                 num_req;
        bit                 success;
        int wt_ace_wrlnunq_tmp = wt_ace_wrlnunq;
        int wt_ace_wrunq_tmp   = wt_ace_wrunq;
        bit                 force_targ_id;
        bit is_coh;
        int                 m_tmp_q[$];
        axi_axaddr_t          base_addr;
        addr_trans_mgr      m_addr_mgr;
        bit unmapped_add_access=$test$plusargs("unmapped_add_access");

        <% if ((obj.fnNativeInterface == "AXI4") ||(obj.fnNativeInterface == "AXI5") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")) { %>    
        int wt_ace_wrcln                           = 0;
        int wt_ace_wrbk                            = 0;
        int wt_ace_evct                            = 0;
        int wt_ace_wrevct                          = 0;
        <% } else { %>    
        int wt_ace_wrcln                           = 5;
        int wt_ace_wrbk                            = 5;
        int wt_ace_evct                            = 5;
        int wt_ace_wrevct                          = 5;
        <% } %> 
	
	bit [addrMgrConst::W_SEC_ADDR - 1: 0] sec_addr;
	int prob_of_dmi_dii_addr                = 50;
	int funitid = 0;
	uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
	string arg_value;

        axi_awid_t use_awid;  
        axi_arid_t use_arid;   
        addrMgrConst::sys_addr_csr_t csr_q[$];
        axi_axaddr_t random_unmapped_addr;
        axi_master_read_seq m_tmp_read_seq = axi_master_read_seq::type_id::create("m_tmp_read_seq");

        m_addr_mgr = addr_trans_mgr::get_instance();
        num_req = 0;
        write_req_count = write_req_count + 1;
        m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq"); 
        m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq"); 
        m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq");
        m_write_addr_seq.core_id = core_id; 
        m_write_data_seq.core_id = core_id;
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
        m_write_addr_seq.s_wr_addr = s_wr_addr; 
        m_write_data_seq.s_wr_data = s_wr_data; 
 
	    if(s_wr[core_id] == null) s_wr[core_id] = new(1);
        s_wr[core_id].get();
        m_write_addr_seq.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_data_seq.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_resp_seq.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
        m_seq_item0                 = axi_wr_seq_item::type_id::create("m_seq_item");
        m_seq_item1                 = axi_wr_seq_item::type_id::create("m_seq_item");

        m_write_addr_seq.should_randomize = 0;
        m_write_data_seq.should_randomize = 0;
       /* csr_q = addrMgrConst::get_all_gpra();
        m_tmp_q = {};
        m_tmp_q = csr_q.find_index with (item.unit == addrMgrConst::DII);
        m_tmp_q[0] = m_tmp_q[$urandom_range(0,m_tmp_q.size()-1)];
        base_addr  = {csr_q[m_tmp_q[0]].upp_addr,csr_q[m_tmp_q[0]].low_addr} << 12;*/

        if (!$test$plusargs("unmapped_add_access"))begin 
        wt_ace_wrnosnp = 0 ;
        end

        randcase
                wt_ace_wrnosnp       : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRNOSNP;
                 wt_ace_wrunq_tmp    : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRUNQ;
                 wt_ace_wrlnunq_tmp  : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRLNUNQ;
                 wt_ace_wrcln	     : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRCLN;
                 wt_ace_wrbk	     : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRBK;
                 wt_ace_evct	     : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = EVCT;
                 wt_ace_wrevct	     : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WREVCT;
                 wt_ace_atm_str      : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = ATMSTR;
                 wt_ace_atm_ld       : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = ATMLD;
                 wt_ace_atm_swap     : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = ATMSWAP;
                 wt_ace_atm_comp     : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = ATMCOMPARE;
                 wt_ace_ptl_stash    : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRUNQPTLSTASH;
                 wt_ace_shared_stash : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = STASHONCESHARED;
                 wt_ace_unq_stash    : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = STASHONCEUNQ;
                 wt_ace_stash_trans  : 	m_write_addr_seq.m_ace_wr_addr_chnl_snoop = STASHTRANS;
        endcase
	
	if (clp.get_arg_value("+prob_of_dmi_dii_addr=", arg_value)) begin
                prob_of_dmi_dii_addr = arg_value.atoi();
        end

	if (!$test$plusargs("unmapped_add_access") )begin
	   int  gen_addr_to_dmi = <%=obj.DiiInfo.length%> < 2 ? 1 : $urandom_range(0,99) < prob_of_dmi_dii_addr ? 1 : 0;
              if(gen_addr_to_dmi) begin
                    sec_addr = m_addr_mgr.gen_noncoh_addr(funitid, 1, core_id);
              end else begin
                    sec_addr = m_addr_mgr.gen_iocoh_addr(funitid, 1, 1, core_id);
                  end
		 m_write_addr_seq.m_ace_wr_addr_chnl_addr = sec_addr; 
	         m_write_addr_seq.m_ace_wr_addr_chnl_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
	end

        if(en_force_axid) begin 
            use_awid=ioaiu_force_axid;
        end else begin
            get_axid(m_write_addr_seq.m_ace_wr_addr_chnl_snoop, use_awid);
        end
        if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop == ATMSWAP || 
            m_write_addr_seq.m_ace_wr_addr_chnl_snoop == ATMLD   ||
            m_write_addr_seq.m_ace_wr_addr_chnl_snoop == ATMCOMPARE) begin
            m_tmp_read_seq.get_axid(m_write_addr_seq.m_ace_wr_addr_chnl_snoop, use_arid, 1, axi_arid_t'(use_awid), 1);  
        end
        //#Stimulus.IOAIU.NoAddresshit.DECERR
        success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid      == use_awid;
                    `ifdef VCS
		    if(m_write_addr_seq.m_ace_wr_addr_chnl_snoop inside{WRUNQ,WRLNUNQ}) 
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.coh_domain == 1;
		    if(m_write_addr_seq.m_ace_wr_addr_chnl_snoop== WRNOSNP) 
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.coh_domain == 0;
                    `endif
                    if (!local::unmapped_add_access) { !(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awdomain inside {0,3}); }
				    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst==AXIINCR;
				    if(m_write_addr_seq.m_ace_wr_addr_chnl_snoop == WRNOSNP)
 				        m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen ==0;
                    if(local::unmapped_add_access){
                        !(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr inside {[addrMgrConst::BOOT_REGION_BASE : (addrMgrConst::BOOT_REGION_BASE + addrMgrConst::BOOT_REGION_SIZE)]});
                        !(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr inside {[addrMgrConst::NRS_REGION_BASE : (addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE)]});
                        foreach(addrMgrConst::memregion_boundaries[idx]) {
                        !(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr inside {[addrMgrConst::memregion_boundaries[idx].start_addr : addrMgrConst::memregion_boundaries[idx].end_addr]});}
                    } else {
				        m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr == m_write_addr_seq.m_ace_wr_addr_chnl_addr;}
		};
	    if(!success)
	        uvm_report_error("AXI_SEQ",$sformatf("Failed randomization"),UVM_NONE);												  
        if ($test$plusargs("unmapped_add_access")) begin
            <%if(obj.AiuInfo[obj.Id].aNcaiuIntvFunc===undefined || obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits===undefined || !obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits.length){}else{%>
            <%for(var i=0; i<obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits.length; i++){%>
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr[<%=obj.AiuInfo[obj.Id].aNcaiuIntvFunc.aPrimaryBits[i]%>] = core_id[<%=i%>];
            <%}%>
	    <%}%>
 	    end
 
        if($test$plusargs("force_single_txn")  && use_burst_incr)begin
            m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen = 0;
        end
        if(s_wr_addr[core_id] == null) s_wr_data[core_id] = new(1);
        s_wr_addr[core_id].get();
        s_wr_data[core_id].get();
        m_write_addr_seq.return_response(m_seq_item0, m_write_addr_chnl_seqr);
        success = m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
           m_ace_cache_model.give_data_for_ace_req(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_ace_wr_addr_chnl_snoop, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize, m_write_data_seq.m_seq_item.m_write_data_pkt.wdata, m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]
<% } %>                                                
            );

        `uvm_info("DEBUG",$sformatf("sending %s",m_write_addr_seq.m_seq_item.m_write_addr_pkt.sprint_pkt()),UVM_HIGH);
        m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;
//        m_write_data_seq.return_response(m_write_addr_seq.m_seq_item, m_write_data_chnl_seqr);
        fork
	    begin
            if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== EVCT &&
                    m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== STASHONCEUNQ &&
                    m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== STASHONCESHARED
                ) begin
                m_write_data_seq.return_response(m_seq_item1, m_write_data_chnl_seqr);
            end
            else begin
                s_wr_data[core_id].put();
	        end
        end
        join
        wait_till_awid_latest(m_write_addr_seq.m_seq_item.m_write_addr_pkt);
        if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop == ATMSWAP ||
            m_write_addr_seq.m_ace_wr_addr_chnl_snoop == ATMLD   ||
            m_write_addr_seq.m_ace_wr_addr_chnl_snoop == ATMCOMPARE) begin
            m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 
            m_seq_item                         = axi_rd_seq_item::type_id::create("m_seq_item");
            m_read_data_seq.m_seq_item         = m_seq_item;
            m_read_data_seq.should_randomize = 0;
            m_read_data_seq.m_seq_item.m_read_addr_pkt.arid = m_write_data_seq.m_seq_item.m_write_addr_pkt.awid;
            fork
                begin
                    m_read_data_seq.return_response(m_seq_item, m_read_data_chnl_seqr);
                    m_tmp_read_seq.delete_axid_inuse(m_read_data_seq.m_seq_item.m_read_addr_pkt.arid);
                end
            join
        end	
      delete_ott_entry(m_write_addr_seq.m_seq_item.m_write_addr_pkt);												   
      s_wr[core_id].put();	
    endtask													   
endclass // axi_master_write_noncoh_seq_err
													   
////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Write Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_master_write_noncoh_seq extends axi_master_write_base_seq;

    `uvm_object_param_utils(axi_master_write_noncoh_seq)
   
    axi_write_addr_seq            m_write_addr_seq;
    axi_write_data_seq            m_write_data_seq;
    axi_write_resp_seq            m_write_resp_seq;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;
    axi_wr_seq_item               m_seq_item0;
    axi_wr_seq_item               m_seq_item1;
    ace_cache_model               m_ace_cache_model;

    axi_rd_seq_item               m_seq_item;
    axi_read_data_seq             m_read_data_seq;
    axi_read_data_chnl_sequencer m_read_data_chnl_seqr;

    // For barriers
    static axi_rd_seq_item m_rd_bar_seq_item_q[$];

    int   done;
    int   count_try;
    int id;
    //Control Knobs
`ifdef PSEUDO_SYS_TB
    int wt_ace_wrnosnp = 0;
`else
    int wt_ace_wrnosnp = 5;
`endif

    // FIXME: Fix below weight to be non-zero
    int wt_ace_wrunq   = 5;
    int wt_ace_wrlnunq = 0;
    int wt_ace_wrbk    = 0;
    int wt_ace_wrcln   = 0;
    int wt_ace_wrevct  = 0;
    // FIXME: Fix below weights to be non-zero
    int wt_ace_wr_bar  = 0;

    // ACE_LITE_E operations
    int wt_ace_atm_str      = 0;
    int wt_ace_atm_ld       = 0;
    int wt_ace_atm_swap     = 0;
    int wt_ace_atm_comp     = 0;
    int wt_ace_ptl_stash    = 0;
    int wt_ace_full_stash   = 0;
    int wt_ace_shared_stash = 0;
    int wt_ace_unq_stash    = 0;
    int wt_ace_stash_trans  = 0;

    int k_num_write_req = 1;
    int k_access_boot_region = 0;

    // For directed test case purposes
    bit                                     use_addr_from_test = 0;
    bit                                     use_axcache_from_test = 0;
    bit                                     force_axlen_256B = 0; //

   //For data bank selection
  <%if((obj.testBench == "io_aiu" && obj.useCache) && (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) {%>
    bit[<%=Math.log2(obj.nDataBanks)%>-1:0]             sel_bank;
    <%}%>

<% if(obj.testBench =="io_aiu" && (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) { %>
    bit[<%=(Math.log2((obj.DutInfo.nNativeInterfacePorts) * obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks))%>-1:0]             sel_ott_bank;
<%}%>
    axi_axaddr_t m_ace_wr_addr_from_test;
<% if (obj.wSecurityAttribute > 0) { %>                                             
    bit [<%=obj.wSecurityAttribute%>-1:0]   m_ace_wr_security_from_test;
<% } %>                                                
 
    static bit   firstReqDone = 0;
    static bit   req_sent = 0;
    static int   write_req_count = 0;
    static int   write_req_total_count = 0;
    static int   req_generation_count = 0;
    static bit   pwrmgt_power_down = 0;

    bit use_burst_incr;
    bit use_burst_wrap;

    int no_of_ones_in_a_byte=0;

	int                         ioaiu_force_axid; //newperf test force same axid on the transactions
    int                         en_force_axid;

    int perf_test;
    int perf_test_ace;
	int perf_txn_size;
    int perf_coh_txn_size;    
    int perf_noncoh_txn_size;    
    int aiu_qos;
    int user_qos;

    int num_alt_qos_values;
    int total_aiu_qos_cycle;
    int aiu_qos1;
    int aiu_qos1_cycle;
    int aiu_qos2;
    int aiu_qos2_cycle;
    int aiu_qos3;
    int aiu_qos3_cycle;
    int aiu_qos4;
    int aiu_qos4_cycle;
    static int qos_cycle_count;

    // newperf test 
	uvm_event_pool ev_pool          = uvm_event_pool::get_global_pool();
    uvm_event ev_wr_req_done   = ev_pool.get("ioaiu<%=my_ioaiu_id%>_wr_req_done");
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_master_write_noncoh_seq");
    super.new(name);

    //FIXME: Please remove this guys once you are done with bringup 
    use_burst_wrap = $test$plusargs("use_burst_wrap");
    use_burst_incr = $test$plusargs("use_burst_incr");
    user_qos = 0;
    qos_cycle_count    = 0; 
    num_alt_qos_values = 0;
 
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    int                 num_req;
    bit                 success;
    bit                 force_targ_id;
    int                 m_tmp_q[$];
    int                         num_coh_addr_in_ort[$];
    int                         num_noncoh_addr_in_ort[$];
    int                 m_tmp_addr_q[$];
    addr_trans_mgr      m_addr_mgr;
    bit [47:0]                  base_addr;
    int                 ioaiu_force_stash = $test$plusargs("ioaiu<%=my_ioaiu_id%>_stashnid");	
    bit force_single_beat = $test$plusargs("force_single_beat");
    aceState_t m_cache_state;
    bit m_tmp_awunique;
    bit constrain_awunique;
    axi_arid_t use_arid;
    int                 temp_cnt;
    bit forbidden_stashnid;	
    addrMgrConst::sys_addr_csr_t csr_q[$];
    
    axi_master_read_seq m_tmp_read_seq = axi_master_read_seq::type_id::create("m_tmp_read_seq");

    m_addr_mgr = addr_trans_mgr::get_instance();
    num_req = 0;
    m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq"); 
    m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq"); 
    m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq"); 
    m_write_addr_seq.core_id = core_id; 
    m_write_data_seq.core_id = core_id;
    if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
    if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
    m_write_addr_seq.s_wr_addr = s_wr_addr; 
    m_write_data_seq.s_wr_data = s_wr_data; 
	`uvm_info(get_full_name(), "Starting ...", UVM_LOW)
    if($test$plusargs("perf_test")) begin
        perf_test = 1;
    end else begin
        perf_test = 0;
    end
    if($test$plusargs("perf_test_ace")) begin
        perf_test_ace = 1;
    end else begin
        perf_test_ace = 0;
    end

    if(perf_txn_size !=0 || $value$plusargs("perf_txn_size=%d", perf_txn_size)) begin
       perf_coh_txn_size = perf_txn_size;
       perf_noncoh_txn_size = perf_txn_size;
	end 

    if($test$plusargs("stash_targ_id_test")) begin
       force_targ_id = 1;
    end else begin
       force_targ_id = 0;
    end
													   
    if($value$plusargs("aiu_qos=%d", aiu_qos)) begin
       user_qos = 1;
    end													   

  if($value$plusargs("<%=obj.BlockId%>_alt_qos_values=%d", num_alt_qos_values)) begin
     if(num_alt_qos_values <= 1) begin
	`uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_alt_qos_values has to be greater than 1.  Specified value=%0d", num_alt_qos_values))
     end
     if(num_alt_qos_values > 1) begin
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos1=%d", aiu_qos1)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos1 not specified."))
	end
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos1_cycle=%d", aiu_qos1_cycle)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos1_cycle not specified."))
	end
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos2=%d", aiu_qos2)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos2 not specified."))
	end
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos2_cycle=%d", aiu_qos2_cycle)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos2_cycle not specified."))
	end
        total_aiu_qos_cycle = aiu_qos1_cycle + aiu_qos2_cycle;
     end
     if(num_alt_qos_values > 2) begin
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos3=%d", aiu_qos3)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos3 not specified."))
	end
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos3_cycle=%d", aiu_qos3_cycle)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos3_cycle not specified."))
	end
        total_aiu_qos_cycle += aiu_qos3_cycle;
     end
     if(num_alt_qos_values > 3) begin
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos4=%d", aiu_qos4)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos4 not specified."))
	end
	if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos4_cycle=%d", aiu_qos4_cycle)) begin
	   `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos4_cycle not specified."))
	end
        total_aiu_qos_cycle += aiu_qos4_cycle;
     end
     if(num_alt_qos_values > 4) begin
	`uvm_error(get_full_name(), $sformatf("Only supporting maximum <%=obj.BlockId%>_alt_qos_values of 4.  Specified value=%0d", num_alt_qos_values))
     end
  end

    temp_cnt=0;
    if(s_wr[core_id] == null) s_wr[core_id] = new(1);
        s_wr[core_id].get();
        
        if (firstReqDone) begin
            wait(req_sent == 1);
        end

    do begin
        bit [addrMgrConst::W_SEC_ADDR - 1 : 0] sec_addr;
        bit is_coh;
        int do_count;
        axi_bresp_t tmp_bresp[] = new[1];
        axi_awid_t use_awid;
        bit addr_gen_failure = 0;

        csr_q = addrMgrConst::get_all_gpra();
        m_tmp_addr_q = {};

       // Check if noncoh or coh mem area exist with atomic engine if not atomic is forbidden
        if(!$test$plusargs("disable_atomic_checker"))begin:_check_allow_atomic
       bit find_area_coh_with_atm=0;
       bit find_area_noncoh_with_atm=0;
       foreach(csr_q[i]) begin:_foreach_mem_area
          if (csr_q[i].nc && addr_trans_mgr::allow_atomic_txn_with_addr((csr_q[i].low_addr << 12) | (csr_q[i].upp_addr << 44))) begin // if noncoh area & check engine
              find_area_noncoh_with_atm =1; 
          end
          if (!csr_q[i].nc && addr_trans_mgr::allow_atomic_txn_with_addr((csr_q[i].low_addr << 12) | (csr_q[i].upp_addr << 44))) begin // if noncoh area & check engine
              find_area_coh_with_atm =1; 
          end
        end:_foreach_mem_area
        //`uvm_info(get_full_name(), $sformatf("find_area_coh_with_atm:%0d find_area_noncoh_with_atm:%0d", find_area_coh_with_atm, find_area_noncoh_with_atm), UVM_LOW);
       if (!find_area_noncoh_with_atm && !find_area_coh_with_atm) begin
            wt_ace_atm_str      =0;
            wt_ace_atm_ld       =0;
            wt_ace_atm_swap     =0;
            wt_ace_atm_comp     =0;
       end
       if (!find_area_coh_with_atm)
            m_ace_cache_model.prob_ace_coh_win_error  =  100; // coh area without atomic engine must put 100 because to avoid teh fct calculate_iscoh return iscoh   
            if($test$plusargs("dmi_connectivity_check")||$test$plusargs("dce_connectivity_check")) begin
            m_ace_cache_model.prob_ace_coh_win_error = 0;
        end
       end:_check_allow_atomic
       
       if(!$test$plusargs("force_wb_wc_noncoh")) begin
           wt_ace_wrbk=0;
           wt_ace_wrcln=0;
        end
        if(!$test$plusargs("force_we_noncoh")) begin
           wt_ace_wrevct=0;
        end
        if (((addrMgrConst::aiu_connected_dii_ids[<%=obj.FUnitId%>].ConnectedfUnitIds.size() == 0) ||
            ((addrMgrConst::aiu_connected_dii_ids[<%=obj.FUnitId%>].ConnectedfUnitIds.size() == 1) && (addrMgrConst::aiu_connected_dii_ids[<%=obj.FUnitId%>].ConnectedfUnitIds[0] == addrMgrConst::funit_ids[addrMgrConst::diiIds[addrMgrConst::get_sys_dii_idx()]]))) //no normal txn dii connected
            && (m_addr_mgr.noncoh_addr_region_mapped_to_dmi() == 0) //all dmi are mapped to coh region only
           )  begin
            wt_ace_wrnosnp = 0;
            `uvm_info(get_full_name(), $sformatf("Forced wrnosnp wt to 0"), UVM_LOW);
            wt_ace_wrunq = 1; //Need at least one txn wt enabled.
        end 

            //uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("%0s wt_ace_wrnosnp %0d wt_wrunq_tmp %0d wt_wrlnunq_tmp %0d wt_ace_wr_bar_tmp %0d wt_ace_atm_str %0d wt_ace_atm_ld %0d wt_ace_atm_swap %0d wt_ace_atm_comp %0d wt_ace_ptl_stash %0d wt_ace_full_stash %0d wt_ace_shared_stash %0d wt_ace_unq_stash %0d wt_ace_stash_trans %0d wt_ace_wrbk_tmp %0d wt_ace_wrcln_tmp %0d",  get_full_name(), wt_ace_wrnosnp, wt_ace_wrunq_tmp, wt_ace_wrlnunq_tmp, wt_ace_wr_bar_tmp, wt_ace_atm_str, wt_ace_atm_ld, wt_ace_atm_swap, wt_ace_atm_comp, wt_ace_ptl_stash, wt_ace_full_stash, wt_ace_shared_stash, wt_ace_unq_stash, wt_ace_stash_trans, wt_ace_wrbk_tmp, wt_ace_wrcln_tmp), UVM_LOW);
        randcase
            wt_ace_wrnosnp      : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRNOSNP;
            wt_ace_wrunq        : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRUNQ;
            wt_ace_wrlnunq      : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRLNUNQ;
            wt_ace_atm_str      : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = ATMSTR;
            wt_ace_atm_ld       : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = ATMLD;
            wt_ace_atm_swap     : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = ATMSWAP;
            wt_ace_atm_comp     : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = ATMCOMPARE;
            wt_ace_ptl_stash    : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRUNQPTLSTASH;
            wt_ace_full_stash   : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRUNQFULLSTASH;
            wt_ace_shared_stash : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = STASHONCESHARED;
            wt_ace_unq_stash    : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = STASHONCEUNQ;
            wt_ace_wrbk         : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRBK;
            wt_ace_wrcln        : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRCLN;
            wt_ace_wrevct       : m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WREVCT;
        endcase

        //`uvm_info(get_full_name(), $sformatf("After randcase. m_write_addr_seq.m_ace_wr_addr_chnl_snoop = %0s",m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name()), UVM_LOW);

        if(k_access_boot_region == 1) begin: _access_boot_region_
	    use_addr_from_test = 1;
	    if(m_write_addr_seq.m_ace_wr_addr_chnl_snoop == WRNOSNP) begin
	        m_ace_wr_addr_from_test = m_ace_cache_model.m_addr_mgr.get_noncohboot_addr(<%=obj.FUnitId%>, 1, core_id);
            end else begin
	        m_ace_wr_addr_from_test = m_ace_cache_model.m_addr_mgr.get_cohboot_addr(<%=obj.FUnitId%>, 1, core_id);
            end
<% if (obj.wSecurityAttribute > 0) { %>                                             
	    m_ace_wr_security_from_test = 0;					    
<% } %>
        end: _access_boot_region_

        count_try=0;
        do begin:_loop_find_addr
        done=1; 
        //request address from cache model
        m_ace_cache_model.give_addr_for_ace_req_noncoh_write(id, m_write_addr_seq.m_ace_wr_addr_chnl_snoop, m_write_addr_seq.m_ace_wr_addr_chnl_addr
                             <% if (obj.wSecurityAttribute > 0) { %>                                             
                                ,m_write_addr_seq.m_ace_wr_addr_chnl_security
                             <% } %>
                            ,is_coh
                            ,use_addr_from_test, m_ace_wr_addr_from_test
                             <% if (obj.wSecurityAttribute > 0) { %>                                             
                                ,m_ace_wr_security_from_test
                             <% } %>                                                
                            ,addr_gen_failure 
                        );
           if (!$test$plusargs("disable_atomic_checker") && !uvm_re_match(uvm_glob_to_re("*ATM*"),m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name()))
            if(!addr_trans_mgr::allow_atomic_txn_with_addr(m_write_addr_seq.m_ace_wr_addr_chnl_addr) // double if to avoid to launch the function
            ) begin:_check_atomic
            done =0;
            count_try++;
           end:_check_atomic
           if (count_try > 1000) done=1;
        end:_loop_find_addr while (!done);
        if (count_try>1000) `uvm_error("axi_master_write_noncoh_seq","can't generate an ATOMIC addr, maybe cfg doesn't have atomic engine"); 

        if (addr_gen_failure == 1) begin 
            `uvm_info(get_full_name(), $sformatf("After give_addr_for_ace_req_noncoh_write addr_gen_failure: chnl_addr:0x%0x is_coh:0x%0x snoop:%0s", m_write_addr_seq.m_ace_wr_addr_chnl_addr, is_coh, m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name()), UVM_LOW);
              if($test$plusargs("use_user_addrq") && temp_cnt > 750 ) begin

                         num_coh_addr_in_ort = {};
                         num_noncoh_addr_in_ort = {};
                         num_noncoh_addr_in_ort = m_ace_cache_model.m_ort.find_index with (addrMgrConst::get_addr_gprar_nc(item.m_addr) == 1 && m_ace_cache_model.calculate_is_coh(item.m_cmdtype) ==0);
                         num_coh_addr_in_ort    = m_ace_cache_model.m_ort.find_index with (addrMgrConst::get_addr_gprar_nc(item.m_addr) == 0 && m_ace_cache_model.calculate_is_coh(item.m_cmdtype) ==1);

                         if(num_coh_addr_in_ort.size() >= m_ace_cache_model.user_addrq[addrMgrConst::COH].size()) begin
                             @m_ace_cache_model.e_ort_delete;
                         end else if(num_noncoh_addr_in_ort.size() >= m_ace_cache_model.user_addrq[addrMgrConst::NONCOH].size() )begin
                             @m_ace_cache_model.e_ort_delete;
                         end
	     end
             if (temp_cnt > 1000) 
             `uvm_error(get_full_name(),"TB Error: fn:give_addr_for_ace_req_noncoh_write unable to find addr even after 10000 iterat");
             temp_cnt ++;
             continue;
        end 
        
        `uvm_info(get_full_name(), $sformatf("After give_addr_for_ace_req_noncoh_write: chnl_addr:0x%0x is_coh:0x%0x snoop:%0s", m_write_addr_seq.m_ace_wr_addr_chnl_addr, is_coh, m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name()), UVM_LOW);

	if( en_force_axid) begin // newperf test case same AxID on each txn
                //get_axid(m_write_addr_seq.m_ace_wr_addr_chnl_snoop, use_awid,.force_this_axid(ioaiu_force_axid),.use_force_this_axid(1'b1));
	    use_awid=ioaiu_force_axid;
        end else begin
            get_axid(m_write_addr_seq.m_ace_wr_addr_chnl_snoop, use_awid);
        end           
        
        if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop inside {ATMSWAP, ATMLD, ATMCOMPARE}) begin
            m_tmp_read_seq.get_axid(m_write_addr_seq.m_ace_wr_addr_chnl_snoop, use_arid, 1, axi_arid_t'(use_awid), 1);  
        end
       
        m_write_addr_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_resp_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_seq_item0                                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_seq_item1                                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_addr_seq.m_constraint_snoop        = 1;
        m_write_addr_seq.m_constraint_addr         = 1;
      
        //axi_axaddr_t     tmp_wr_addr;
        m_cache_state = m_ace_cache_model.current_cache_state(m_write_addr_seq.m_ace_wr_addr_chnl_addr
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    ,m_write_addr_seq.m_ace_wr_addr_chnl_security
                <% } %>                                                
            );
        
        //TODO: HS 01/30/24 Revisit the spec
        if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop inside {WRUNQ,WRLNUNQ}) begin
            if (m_cache_state inside {ACE_UC,ACE_SC}) begin
                if(WUSEACEUNIQUE>0) begin
                    m_tmp_awunique = $urandom_range(0,1);
                    constrain_awunique = 1;
                end else begin
                    m_tmp_awunique = 0;
                    constrain_awunique = 1;
                end
            end
            else begin
                    if(WUSEACEUNIQUE>0) begin
                        m_tmp_awunique = 1;
                        constrain_awunique = 1;
                    end
            end
        end
        else if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop == WRBK) begin 
            if (m_cache_state == ACE_SD) begin
                m_tmp_awunique = 0;
                constrain_awunique = 1;
            end
        end

        `uvm_info("AXI SEQ", $sformatf("%0s Before randomizing: constraint addr 0x%0x constraint_snoop:%0d awaddr 0x%0x chnl_addr 0x%0x is_coh 0x%0x snoop %0s", get_full_name(), m_write_addr_seq.m_constraint_addr, m_write_addr_seq.m_constraint_snoop, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_ace_wr_addr_chnl_addr, is_coh, m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name()), UVM_LOW);


        if (ioaiu_force_stash) m_write_addr_seq.m_seq_item.m_write_addr_pkt.c_awcmdtype_1.constraint_mode(0); // disable constraints on CMD
        if (m_write_addr_seq.m_constraint_addr) m_write_addr_seq.m_seq_item.m_write_addr_pkt.constrained_addr = 1;
        if ((!(m_write_addr_seq.m_ace_wr_addr_chnl_snoop inside {WRUNQ,WRNOSNP})) && force_single_beat) begin
              force_single_beat = 0;
        end
	
	<%if((obj.testBench == "io_aiu" && obj.useCache) && (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) {%>
              if($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test") || $test$plusargs("address_error_test_data")) begin 
              //Force all addresses in the test to go to DataBank
               <%for( var i=0; i< Math.log2(obj.nDataBanks); i++){%>
              	m_write_addr_seq.m_ace_wr_addr_chnl_addr[<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits[obj.AiuInfo[obj.Id].ccpParams.DataBankSelBits[i]]%>] = sel_bank[<%=i%>];
              <%}%>
             end
     <%}%>
              
        <% if(obj.testBench =="io_aiu" && (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) { %>
        if($test$plusargs("address_error_test_ott") || $test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test"))begin
             	m_write_addr_seq.m_ace_wr_addr_chnl_addr[<%=!obj.useCache ? 6 :obj.AiuInfo[obj.Id].ccpParams.wCacheLineOffset%> -1 : <%=Math.log2(obj.AiuInfo[obj.Id].ccpParams.wData/8)%>] = sel_ott_bank;
        end
<%}%>
	
 
        if (!($value$plusargs("forbidden_stashnid=%d",forbidden_stashnid)))  forbidden_stashnid=0;
        success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid           == use_awid;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.useFullCL      == (use_addr_from_test || use_full_cl);
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.coh_domain     == is_coh;
                if (m_write_addr_seq.m_constraint_snoop == 1) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
                if (m_write_addr_seq.m_constraint_addr  == 1) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr    == m_write_addr_seq.m_ace_wr_addr_chnl_addr;
                if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop inside {WRBK,WRCLN,WREVCT}) { 
                        if(!local::force_single_beat)
                        m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen ==  m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen; // cacheline and narrow possible for wrcln,wrbk - multiple not supported, wrevct is cacheline size
                        if(local::force_single_beat && m_write_addr_seq.m_ace_wr_addr_chnl_snoop inside {WRBK,WRCLN})
                        m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen == 0; 
                        `ifndef VCS
                        m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr >= m_write_addr_seq.m_ace_wr_addr_chnl_addr;
                        m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr < m_write_addr_seq.m_ace_wr_addr_chnl_addr + (2**(csr_q[m_tmp_addr_q[0]].size + 12)) - ((m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen +1) * 2**m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize);
                        `endif
                } else {
                    if(local::force_single_beat)
                        m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen == 0; 
                } 
                if(use_burst_incr) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst==AXIINCR;
                if(use_burst_wrap) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst==AXIWRAP;
                if(user_qos)       m_write_addr_seq.m_seq_item.m_write_addr_pkt.awqos==aiu_qos;
                if(constrain_awunique == 1 && WUSEACEUNIQUE>0) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awunique == m_tmp_awunique;
                if(force_targ_id) (m_write_addr_seq.m_seq_item.m_write_addr_pkt.awstashniden == 1);
                if(m_write_addr_seq.m_ace_wr_addr_chnl_snoop == WRUNQPTLSTASH || m_write_addr_seq.m_ace_wr_addr_chnl_snoop == WRUNQFULLSTASH ||
                        m_write_addr_seq.m_ace_wr_addr_chnl_snoop == STASHONCESHARED || m_write_addr_seq.m_ace_wr_addr_chnl_snoop == STASHONCEUNQ) {
                     (m_write_addr_seq.m_seq_item.m_write_addr_pkt.awstashniden && !forbidden_stashnid) -> m_write_addr_seq.m_seq_item.m_write_addr_pkt.awstashnid inside {addrMgrConst::stash_nids,addrMgrConst::stash_nids_ace_aius};
                     (m_write_addr_seq.m_seq_item.m_write_addr_pkt.awstashniden && forbidden_stashnid) -> m_write_addr_seq.m_seq_item.m_write_addr_pkt.awstashnid inside {addrMgrConst::stash_nids,addrMgrConst::stash_nids_forbidden};
                     (m_write_addr_seq.m_seq_item.m_write_addr_pkt.awstashniden == 0) -> m_write_addr_seq.m_seq_item.m_write_addr_pkt.awstashnid == 0;
                     (m_write_addr_seq.m_seq_item.m_write_addr_pkt.awstashniden == 1) -> awstashlpiden dist {0 := 10, 1 := 90};
                    }
                <%if(obj.wSecurityAttribute > 0){%>
                    if (m_write_addr_seq.m_constraint_addr  == 1) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1] == m_write_addr_seq.m_ace_wr_addr_chnl_security;
                <%}%>   
            };

    
		
                if( $test$plusargs("perf_test") && m_write_addr_seq.m_constraint_addr &&
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr != m_write_addr_seq.m_ace_wr_addr_chnl_addr) begin
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr = m_write_addr_seq.m_ace_wr_addr_chnl_addr ;   
                end

            //`uvm_info(get_full_name(), $sformatf("After randomizin w constraints addr:0x%0x awaddr:0x%0x chnl_addr:0x%0x is_coh:0x%0x chnl_snoop:%0s awsnoop:%0p", m_write_addr_seq.m_constraint_addr, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_ace_wr_addr_chnl_addr, is_coh, m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsnoop), UVM_LOW);


	if($test$plusargs("force_single_txn") && use_burst_incr && m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype != WRLNUNQ) begin
            m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen = 0;
	end
	    
	if(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst == AXIWRAP &&  m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype != ATMCOMPARE) begin
	    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr[WLOGXDATA-1:0] = 'h0;
	end
        if(use_axcache_from_test) begin
            `uvm_info("AXI SEQ", $sformatf("use_axcache_from_test - awaddr = 0x%0h", m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr), UVM_MEDIUM)
	    if(m_addr_mgr.get_addr_target_unit(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr) == 0) begin // no dii
                $cast(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache , 4'hf);
                $cast(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awdomain , 'h0);
                //avoid generating exclusive transactions for 256Bytes multiline transactions
                if(perf_test == 1 && perf_txn_size == 256 ) begin
                  m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlock =  axi_axlock_enum_t'(0);
                end
	    end
        end
        else if(perf_test == 1 || perf_test_ace == 1 ) begin
            int stashnid;
            m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlock =  axi_axlock_enum_t'(0); 
            m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[2] = 1'b0 ; //Unprivileged access
            m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1] = 1'b0 ; //secure access
            m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[0] =  1'b0; // Data access
	    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst = AXIINCR;
  	    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[3:0] = 1; // bufferable by default
	    
            if(m_write_addr_seq.m_ace_wr_addr_chnl_snoop == WRNOSNP) begin:noncoh_wr_case
	        if($test$plusargs("force_noncoh_allocate_txn"))  m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[3:2]= 2'b11; 
	        if($test$plusargs("force_noncoh_cacheable_txn"))    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[1] = 1; 
                if($test$plusargs("force_noncoh_unbufferable_txn"))   m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[0] = 1'b0; 
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awdomain =  axi_axdomain_enum_t'(0); 
            end:noncoh_wr_case	
            else begin:coh_wr_case
	        if($test$plusargs("force_coh_allocate_txn")) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[3:2] = 2'b11; 
		m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[1] = 1; 
                if($test$plusargs("force_coh_unbufferable_txn"))  m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[0] = 1'b0; 
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awdomain =  axi_axdomain_enum_t'(2); 
            end:coh_wr_case 
            
            if($test$plusargs("force_allocate_txn"))    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[3:2] = 2'b11; 
	    if($test$plusargs("force_cacheable_txn"))   m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[1] = 1; 
            if($test$plusargs("force_unbufferable_txn"))  m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[0] = 1'b0; 
            if($test$plusargs("force_non_allocate_txn"))  m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[3:2] = 2'b00; 
            if($test$plusargs("force_non_cacheable_txn")) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[1]   = 0;
	    if($test$plusargs("ioaiu<%=my_ioaiu_id%>_write_through")) 

            m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[0] = 0;
				                 
	    // overwrite/force stash BW test
            if ($value$plusargs("ioaiu<%=my_ioaiu_id%>_stashnid=%d",stashnid)) begin
                m_write_addr_seq.m_ace_wr_addr_chnl_snoop = STASHONCEUNQ;
		m_write_addr_seq.m_seq_item.m_write_addr_pkt.awstashniden = 1;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awstashnid = stashnid;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awdomain =  axi_axdomain_enum_t'(2); 
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlock =  axi_axlock_enum_t'(0);
	        m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst = AXIINCR;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[1] = 1'b1;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[2] = 1'b1 ; // Instruction access
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1] = 1'b0 ; //secure access
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[0] =  1'b0; //Unprivileged acces
            end
      	end // end newperf test											   
        
        if($test$plusargs("k_axcache_0_to_dii")) begin
	    if(m_addr_mgr.get_addr_target_unit(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr) == 1) begin
	        m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[3:1] = 3'b000;
	        if(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == WRNOSNP)  m_write_addr_seq.m_seq_item.m_write_addr_pkt.awdomain = axi_axdomain_enum_t'(3);
	    end
	end

        if ((perf_test == 1 || perf_test_ace == 1)&&(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype != WRLNUNQ)) begin
            if(force_axlen_256B)begin
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen = 256 / (2**m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize) - 1;// 256B transfer for performance test
            end else begin
                if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop == WRNOSNP)
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen = (((perf_noncoh_txn_size*8)/WXDATA) - 1);  // 64B transfer for performance test
		else 
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen = (((perf_coh_txn_size*8)/WXDATA) - 1);  // 64B transfer for performance test
            end
	    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize = WLOGXDATA;
        end

        if(num_alt_qos_values > 1) begin
            if(qos_cycle_count < aiu_qos1_cycle) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awqos = aiu_qos1;
            else if(qos_cycle_count < (aiu_qos1_cycle + aiu_qos2_cycle)) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awqos = aiu_qos2;
            else if(qos_cycle_count < (aiu_qos1_cycle + aiu_qos2_cycle + aiu_qos3_cycle)) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awqos = aiu_qos3;
            else m_write_addr_seq.m_seq_item.m_write_addr_pkt.awqos = aiu_qos4;

            qos_cycle_count += 1;
            if(qos_cycle_count == total_aiu_qos_cycle) qos_cycle_count = 0;
        end
        `uvm_info("DEBUG",$sformatf("sending %s",m_write_addr_seq.m_seq_item.m_write_addr_pkt.sprint_pkt()),UVM_LOW);

        if (!success) begin
            `uvm_error(get_name(), $sformatf("TB Error: Could not randomize write address packet in axi_master_write_noncoh_seq"));
        end
        
        m_write_addr_seq.m_ace_wr_addr_chnl_addr = m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr;
        
        <% if(obj.testBench == "fsys") { %>
        if ($test$plusargs("random_gpra_nsx")) begin
            //#Stimulus.FSYS.GPRAR.NS_zero.withatleast.oneTxnSecure
            m_write_addr_seq.m_ace_wr_addr_chnl_security = m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1] ;
        end
        <% } %> 
        
        m_ace_cache_model.update_addr(m_write_addr_seq.m_ace_wr_addr_chnl_snoop, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    ,.security(m_write_addr_seq.m_ace_wr_addr_chnl_security)
                <% } %>
        );
 
        sec_addr = m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr;
<%    if (obj.wSecurityAttribute > 0) { %>
        sec_addr[addrMgrConst::W_SEC_ADDR - 1] = m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1];
<%    } %>
	
        m_addr_mgr.set_addr_in_agent_mem_map(sec_addr, <%=obj.AiuInfo[obj.Id].FUnitId%>);
        success = m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
        
        if (!success) begin
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize write data packet in axi_master_write_noncoh_seq"), UVM_NONE);
        end
        
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb    = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wpoison  = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdatachk = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
            
        m_ace_cache_model.give_data_for_ace_req(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_ace_wr_addr_chnl_snoop, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize, m_write_data_seq.m_seq_item.m_write_data_pkt.wdata, m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]
<% } %>                                                
            );

        m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;
        m_write_data_seq.m_seq_item.m_write_data_pkt.wtrace = $urandom;
            
        for (int i=0; i< (m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1);i++) begin
            m_write_data_seq.m_seq_item.m_write_data_pkt.wpoison[i] = 0;
            for (int j=0; j<(WXDATA/8); j++) begin
                no_of_ones_in_a_byte = $countones(m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[i][((8*j)+7)-:8]);
                // Odd byte parity
                if (no_of_ones_in_a_byte[0] == 1) begin
                    m_write_data_seq.m_seq_item.m_write_data_pkt.wdatachk[i][j] = 1;
                end else begin
                    m_write_data_seq.m_seq_item.m_write_data_pkt.wdatachk[i][j] = 0;
                end
            end
        end
        
        m_write_addr_seq.should_randomize = 0;
        m_write_data_seq.should_randomize = 0;
        //CONC-16243 comment out for useCache to get past fails but why should this wait
        //statement be there. what purpose does it serve? 
        req_generation_count++;
        <% if (obj.useCache == 0) { %>
        wait(req_generation_count < 8);
        <%}%>
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        s_wr[core_id].put();
      
        if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop inside {WRUNQ, WRLNUNQ}) begin 

            //CONC-11840 Do not issue wrunq/wrlnunq when coh update txns (WRBK, WRCLN,WREVCT are in flight
            do_count = 0;
            do begin 
                if (m_ace_cache_model.wrunq_wrlnunq_txn_ok_to_send() == 0) begin
                    //uvm_report_info("HS_DBG", $sformatf("foreverloop-send_write_address: waiting for ort_delete event count:%0d", do_count), UVM_LOW);
                    @m_ace_cache_model.e_ort_delete;
                    //uvm_report_info("HS_DBG", $sformatf("foreverloop-send_write_address: done waiting for ort_delete event:%0d", do_count), UVM_LOW);
                end
                do_count++;
            end while ((m_ace_cache_model.wrunq_wrlnunq_txn_ok_to_send() == 0) && (do_count < 10000));
            if (do_count == 10000)
                `uvm_error("noncoh_write_seq", "10000 tries to clear all the outstanding coherent update txns");
        end
        //`uvm_info("axi_write_addr_seq", $sformatf("done waiting for all upd txns to be done. ready to issue this one - %0s", m_write_addr_seq.m_seq_item.convert2string()), UVM_LOW)

        s_wr_addr[core_id].get();
        s_wr_data[core_id].get();
        m_tmp_q = {};
        m_tmp_q = m_ace_cache_model.m_ort.find_index with (item.isRead == 0
            && (item.m_cmdtype inside {WRBK,WRCLN,WREVCT}?item.isUpdate==1:item.isUpdate==0)
            && item.m_addr == m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                && item.m_security == m_write_addr_seq.m_ace_wr_addr_chnl_security
            <% } %>
        && item.isReqInFlight == 0);
        
        if (m_tmp_q.size > 0) begin
            m_ace_cache_model.m_ort[m_tmp_q[0]].isReqInFlight = 1;
	    //`uvm_info(get_full_name(), $sformatf("setting axi_master_ace_noncoh_seq:body isReqInFlight for ORT txn: %0p", m_ace_cache_model.m_ort[m_tmp_q[0]]), UVM_LOW)
        end else begin 
	    `uvm_error(get_full_name(), $sformatf("NonCohWrSeq: cannot find txnn in ORTq"))
        end
        
        if (!firstReqDone) begin
            firstReqDone = 1;
        end
        if($test$plusargs("force_nonallocate_txn"))  m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[3:2]= 'b0; 
        
        fork 
            begin
 
	        `uvm_info("axi_write_addr_seq", $sformatf("Sending AXI[%0d] txn: %s",id, m_write_addr_seq.m_seq_item.convert2string()), UVM_LOW)
                m_write_addr_seq.return_response(m_seq_item0, m_write_addr_chnl_seqr);
	        `uvm_info("axi_write_addr_seq", $sformatf("Sent AXI[%0d] txn: %s",id, m_write_addr_seq.m_seq_item.convert2string()), UVM_LOW)
                m_tmp_q = {};
                m_tmp_q = m_ace_cache_model.m_ort.find_index with ((item.m_cmdtype inside {WRUNQ, WRLNUNQ})
                && item.m_addr == m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr
                && item.m_security == m_write_addr_seq.m_ace_wr_addr_chnl_security
                && item.isReqInFlight == 1);
	        if (m_tmp_q.size() > 0) 
                    m_ace_cache_model.m_ort[m_tmp_q[0]].isCohWriteSent = 1;
                req_sent = 1;
	        ev_wr_req_done.trigger(null); // newperf test
		req_generation_count--;
            end
            begin
                // Nothing goes on write data channel for evicts/barriers
                if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== EVCT &&
                    m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== STASHONCEUNQ &&
                    m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== STASHONCESHARED
                ) begin
                    m_write_data_seq.return_response(m_seq_item1, m_write_data_chnl_seqr);
                    req_sent = 1;
                end
                else begin
                    s_wr_data[core_id].put();
                end
            end
        join
        
        // Blocking till previous request with same awid has a response that has been received
        if(!en_force_axid) begin // newperf test case same AxID on each txn
            wait_till_awid_latest(m_write_addr_seq.m_seq_item.m_write_addr_pkt);
        end 	
        
        m_write_resp_seq.should_randomize = 0;
        m_write_resp_seq.m_seq_item       = m_seq_item0;
        tmp_bresp[0]                      = m_seq_item0.m_write_resp_pkt.bresp;
        if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop inside {ATMSWAP, ATMLD, ATMCOMPARE}) begin
            m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 
            m_seq_item                         = axi_rd_seq_item::type_id::create("m_seq_item");
            m_read_data_seq.m_seq_item         = m_seq_item;
            m_read_data_seq.should_randomize = 0;
            m_read_data_seq.m_seq_item.m_read_addr_pkt.arid = m_write_data_seq.m_seq_item.m_write_addr_pkt.awid;
            fork
                begin
                    m_read_data_seq.return_response(m_seq_item, m_read_data_chnl_seqr);
                    m_tmp_read_seq.delete_axid_inuse(m_read_data_seq.m_seq_item.m_read_addr_pkt.arid);
                end
                begin
                    m_write_resp_seq.return_response(m_seq_item0, m_write_resp_chnl_seqr);
                end
            join
        end else begin
            m_write_resp_seq.return_response(m_seq_item0, m_write_resp_chnl_seqr);
        end

        if(!en_force_axid) begin // newperf test case same AxID on each txn
            delete_ott_entry(m_write_addr_seq.m_seq_item.m_write_addr_pkt);
        end
<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
        
        if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop == EVCT) begin
                axi_xdata_t wdata[];
                m_ace_cache_model.modify_cache_line(m_write_addr_seq.m_ace_wr_addr_chnl_addr, m_write_addr_seq.m_ace_wr_addr_chnl_snoop, tmp_bresp, wdata,.axdomain(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awdomain)
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,.security(m_write_addr_seq.m_ace_wr_addr_chnl_security)
<% } %>                                                
                );
        end
        else begin
                m_ace_cache_model.modify_cache_line(m_write_addr_seq.m_ace_wr_addr_chnl_addr, m_write_addr_seq.m_ace_wr_addr_chnl_snoop, tmp_bresp, m_seq_item1.m_write_data_pkt.wdata, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize,.awunique(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awunique),.axdomain(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awdomain)
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,.security(m_write_addr_seq.m_ace_wr_addr_chnl_security)
<% } %>                                                
                );
        end
<% } else { %>      
        m_tmp_q = {};
        m_tmp_q = m_ace_cache_model.m_ort.find_first_index with (item.m_cmdtype == m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype && 
                                                                 item.isRead ==0                                                          &&
                                                                 item.isUpdate == 0                                                       &&
                                                                 item.m_addr == m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr        &&
                                                                 <% if (obj.wSecurityAttribute > 0) { %>                                             
                                                                 item.m_security == m_write_addr_seq.m_ace_wr_addr_chnl_security           
                                                                 <% } %>);
        if(m_tmp_q.size() > 0) begin
        m_ace_cache_model.m_ort.delete(m_tmp_q[0]);
        ->m_ace_cache_model.e_ort_delete;
        end

        //informing address manager that response for cacheline is received
        //For all NCB's this logic will be triggered and we evict on response
        sec_addr = m_write_addr_seq.m_ace_wr_addr_chnl_addr;
<%    if (obj.wSecurityAttribute > 0) { %>                                             
        sec_addr[addrMgrConst::W_SEC_ADDR - 1] = m_write_addr_seq.m_ace_wr_addr_chnl_security;
<%    } %>
        m_addr_mgr.addr_evicted_from_agent(
            <%=obj.AiuInfo[obj.Id].FUnitId%>, 1, sec_addr);
<% } %>
        write_req_count++;
        num_req++;

    end while (num_req < k_num_write_req);

    //`uvm_info(get_full_name(), "Exiting body ...", UVM_LOW)
endtask:body

endclass : axi_master_write_noncoh_seq


<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
class axi_master_write_coh_seq extends axi_master_write_base_seq;

    `uvm_object_param_utils(axi_master_write_coh_seq)
    
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;
    ace_cache_model               m_ace_cache_model;
    axi_wr_seq_item               m_seq_item;
    static bit                    pwrmgt_power_down;
    static bit                    pwrmgt_power_down_done;
    static bit                    dont_ever_kill_seq = 0;

    typedef struct {
        ace_command_types_enum_t m_cmd_type;
        axi_axaddr_t             m_addr;
        <% if (obj.wSecurityAttribute > 0) { %>                                             
            bit [<%=obj.wSecurityAttribute%>-1:0]           m_security;
        <% } %>                                                
        axi_wr_seq_item                                     m_seq_item;
    } wr_req_t;

    typedef struct {
        axi_xdata_t m_data[];
        axi_wr_seq_item                        m_seq_item;
    } wr_dat_t;

    typedef struct {
        axi_axaddr_t   m_addr;
        <% if (obj.wSecurityAttribute > 0) { %>                                             
            bit [<%=obj.wSecurityAttribute%>-1:0] m_security;
        <% } %>                                                
        axi_xdata_t    m_data[];
    } wr_addr_data_t;

    event e_axi_wr_data_add_q;
    bit force_single_beat = $test$plusargs("force_single_beat");
    bit wide_txn_offset = $test$plusargs("wide_txn_offset");

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_master_write_coh_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    // FIXME: Note:
    // The coherent write sequence does NOT generate barriers. When Concerto will
    // add support for ACE agents sending barriers, we need to evaluate whether
    // we need barriers between coherent requests or not. If we do, then I should
    // add some support in this sequence to send barriers.

    wr_req_t m_axi_wr_req_q[$];
    wr_dat_t m_axi_wr_dat_q[$];
    wr_addr_data_t m_axi_wr_addr_data_q[$];
    axi_wr_seq_item m_axi_wr_rsp_q[$];
    bit firstReqDone                            = 0;
    bit last_access_done                        = 0;
    axi_master_read_seq m_tmp_read_seq          = axi_master_read_seq::type_id::create("m_tmp_read_seq");
    axi_master_write_noncoh_seq m_tmp_write_seq = axi_master_write_noncoh_seq::type_id::create("m_tmp_write_seq");
    bit sequence_done                           = 0;
    bit write_addr_done                         = 0;
    bit gen_req_done                            = 0;
    int count_outstanding_requests              = 0;
    event event_sequence_done;  // VS
    int num_coh_wr_txns = 0;
    int   dbg_q[$];
    
    //`uvm_info(get_full_name(), "CohWrite sequence started", UVM_LOW);
      // Check if coh mem area exist with atomic engine if not atomic is forbidden
       if(!$test$plusargs("disable_atomic_checker"))begin:_check_allow_atomic
	   addrMgrConst::sys_addr_csr_t csr_q[$];
       bit find_area_coh_with_atm=0;
       csr_q = addrMgrConst::get_all_gpra();
       foreach(csr_q[i]) begin:_foreach_mem_area
          if (!csr_q[i].nc && addr_trans_mgr::allow_atomic_txn_with_addr((csr_q[i].low_addr << 12) | (csr_q[i].upp_addr << 44))) begin // if noncoh area & check engine
              find_area_coh_with_atm =1; 
              break;          
          end
        end:_foreach_mem_area
       if (!find_area_coh_with_atm) begin
            m_ace_cache_model.prob_ace_coh_win_error  =  100; //  coh area without atomic engine must put 100 because to avoid teh fct calculate_iscoh return iscoh   
            if($test$plusargs("dmi_connectivity_check")||$test$plusargs("dce_connectivity_check")) begin
            m_ace_cache_model.prob_ace_coh_win_error = 0;
        end
       end
       end:_check_allow_atomic
    fork
        begin : sequence_done_check
            int tmp_rd_count, tmp_wr_count;
            forever begin
                tmp_rd_count = m_tmp_read_seq.read_req_count;
                tmp_wr_count = m_tmp_write_seq.write_req_count;
				sequence_done = !dont_ever_kill_seq && ((m_tmp_write_seq.write_req_count >= m_tmp_write_seq.write_req_total_count)&& 
                (m_tmp_read_seq.read_req_count >= m_tmp_read_seq.read_req_total_count));
            	//uvm_report_info("CHIRAG<%=this_aiu_id%>", $sformatf("read count %0d total read count %0d write count %0d total write count %0d", m_tmp_read_seq.read_req_count, m_tmp_read_seq.read_req_total_count, m_tmp_write_seq.write_req_count, m_tmp_write_seq.write_req_total_count), UVM_LOW);
                if (sequence_done) begin
                    //uvm_report_info("CHIRAG<%=this_aiu_id%>", "VS Sequence done, generate_requests breaking", UVM_NONE);
                    ->event_sequence_done;  // VS
                    break;
                end
                wait (tmp_rd_count !== m_tmp_read_seq.read_req_count || tmp_wr_count !== m_tmp_write_seq.write_req_count);
            end
        end : sequence_done_check
        begin : generate_requests
            forever begin
                wr_req_t m_axi_req_tmp;
                wr_dat_t m_axi_dat_tmp;
                bit done;
                bit loop_done;
                bit nothing_to_flush = 0;
                int m_tmp_q[$], m_dbg_q[$];
                bit is_coh;
                m_axi_req_tmp.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
                m_axi_dat_tmp.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
                if (firstReqDone) begin
                    wait(last_access_done == 1 || sequence_done == 1
                );
                end
                last_access_done = 0;
                done = 0;
                do begin
                    fork 
                        begin
                            wait (/*m_ace_cache_model.cache_flush_mode_on == 0 && */pwrmgt_power_down == 1 && m_ace_cache_model.pwrmgt_cache_flush == 0 && nothing_to_flush == 0);
                            if (m_ace_cache_model.m_cache.size() == 0 && pwrmgt_power_down == 1 && count_outstanding_requests <= 1) begin
                                pwrmgt_power_down_done = 1;
                                m_ace_cache_model.pwrmgt_cache_flush = 0;
                                //`uvm_info("CHIRAG", "POWER MGT DONE SET 1", UVM_NONE);
                                nothing_to_flush = 1;
                                m_ace_cache_model.m_ort = {};
                                ->m_ace_cache_model.e_cache_modify;
                            end
                            else begin
                                m_ace_cache_model.m_ort = {};
                                ->m_ace_cache_model.e_cache_modify;
                                m_ace_cache_model.pwrmgt_cache_flush   = 1;
                                m_ace_cache_model.coh_write_seq_active = 0;
                                pwrmgt_power_down_done                 = 0;
                                m_ace_cache_model.s_coh_noncoh.put();
                                loop_done = 0;
                            end
                        end
                        begin
                            bit not_sending_addr;
                            m_ace_cache_model.give_addr_for_ace_req_coh_write(m_axi_req_tmp.m_cmd_type, not_sending_addr, m_axi_req_tmp.m_addr
                                <% if (obj.wSecurityAttribute > 0) { %>                                             
                                    ,m_axi_req_tmp.m_security
                                <% } %>
                            );
                            if (not_sending_addr) begin
                                pwrmgt_power_down_done = 1;
                                m_ace_cache_model.pwrmgt_cache_flush = 0;
                                nothing_to_flush = 1;
                                done = 1;
                                m_ace_cache_model.m_ort = {};
                                ->m_ace_cache_model.e_cache_modify;
                            end
                            loop_done = 1;
                        end
                        begin
                            wait (m_tmp_read_seq.read_req_count >= m_tmp_read_seq.read_req_total_count);
                            loop_done = 1;
                        end
                    join_any
                    disable fork;
                end while (!loop_done);
                if (m_tmp_read_seq.read_req_count >= m_tmp_read_seq.read_req_total_count) begin
                    done = 1;
                    // Deleting from m_ort
                    m_tmp_q = {};
                    m_tmp_q = m_ace_cache_model.m_ort.find_index with (item.isRead == 0 &&
                        (item.m_cmdtype == WRBK || 
                            item.m_cmdtype == WREVCT ||
                            item.m_cmdtype == EVCT ||
                        item.m_cmdtype == WRCLN)
                        &&  item.isNonCoh ==0
                    && item.isReqInFlight == 0);
                    for (int i = m_tmp_q.size - 1; i >=0;i--) begin
                        m_ace_cache_model.m_ort.delete(m_tmp_q[i]);
                        ->m_ace_cache_model.e_ort_delete;
                    end
                    m_ace_cache_model.end_of_sim = 1;
                    m_ace_cache_model.s_coh_noncoh.put();
                    wait (m_tmp_write_seq.write_req_count >= m_tmp_write_seq.write_req_total_count && sequence_done == 1);
                    // @(event_sequence_done);  // VS
                end
                if (!done) begin
                    bit success = 0;
                    bit constrain_awunique = 0;
                    bit m_tmp_awunique;
                    bit flag = 0;
                    int m_tmp_qA[$];
                    axi_awid_t use_awid;
                    aceState_t m_cache_state;
					
                    m_cache_state = m_ace_cache_model.current_cache_state(m_axi_req_tmp.m_addr
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            ,.security(m_axi_req_tmp.m_security)
                        <% } %>                                                
                    );

                    gen_req_done = 1;
                    `uvm_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("WRCOH currstate:%0p, snooptype %0s address 0x%0x secure bit 0x%0x", m_cache_state, m_axi_req_tmp.m_cmd_type.name(), m_axi_req_tmp.m_addr, 
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            m_axi_req_tmp.m_security
                        <% } else { %>
                            0
                        <% } %>
                    ), UVM_LOW);

                    m_tmp_q = {};
                    m_tmp_q = m_ace_cache_model.m_ort.find_first_index with (item.isRead == 0 &&
                        item.m_addr == m_axi_req_tmp.m_addr
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            && item.m_security == m_axi_req_tmp.m_security
                        <% } %>
                            && item.isUpdate==1 
                            && (item.m_cmdtype inside {WRBK,WRCLN,WREVCT,EVCT})
                           
                    );
                    if (m_tmp_q.size() == 0) begin
                        uvm_report_error("ACE BFM SEQ AIU 0", $sformatf("TB Error: Cannot find address 0x%0x in m_ort", m_axi_req_tmp.m_addr), UVM_NONE);
                    end
                    else begin
                        if (m_tmp_q.size() > 0) begin
                            m_ace_cache_model.m_ort[m_tmp_q[0]].isReqInFlight = 1;
                        end
                    end
                    constrain_awunique = 0;
                    if (m_axi_req_tmp.m_cmd_type == WRBK) begin 
                        if (m_cache_state == ACE_SD) begin
                            m_tmp_awunique     = 0;
                            constrain_awunique = 1;
                        end
                    end
                    if(m_axi_req_tmp.m_cmd_type inside {WRBK,WRCLN} && force_single_beat==1) begin
                        m_axi_req_tmp.m_addr[SYS_wSysCacheline-1:0]=$urandom_range((1 << SYS_wSysCacheline)-1,0);
                        if(wide_txn_offset==1)
                        m_axi_req_tmp.m_addr[$clog2(<%=obj.wData%>/8)-1:0]='d0; // Added for coverage offset on the wide txns
                    end
                    get_axid(m_axi_req_tmp.m_cmd_type, use_awid);
                    m_tmp_q = {};
                    m_tmp_q = m_ace_cache_model.m_cache.find_first_index with (item.m_addr == m_axi_req_tmp.m_addr &&
                                                                            <% if (obj.wSecurityAttribute > 0) { %>
                                                                               item.m_security == m_axi_req_tmp.m_security
                                                                            <% } %>
                                                                              );
                    if(m_tmp_q.size() != 0)begin
                    is_coh = !m_ace_cache_model.m_cache[m_tmp_q[0]].m_non_coherent_addr;
                    end else begin
                    is_coh = 1;
                    end
                    m_axi_req_tmp.m_seq_item.m_write_addr_pkt.constrained_addr = 1;
                    success = m_axi_req_tmp.m_seq_item.m_write_addr_pkt.randomize() with {
                        m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awid      == use_awid;
                        m_axi_req_tmp.m_seq_item.m_write_addr_pkt.coh_domain== is_coh;
                        m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awcmdtype == m_axi_req_tmp.m_cmd_type;
                        m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awaddr    == m_axi_req_tmp.m_addr;
                        if (constrain_awunique == 1  && WUSEACEUNIQUE>0) m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awunique == m_tmp_awunique;
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awprot[1] == m_axi_req_tmp.m_security;
                        <% } %>                                                
                    };
                    `uvm_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("Coh write. CMD:%h, addr:0x%x, is_coh:%0b, awdomain:%h", m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awcmdtype, m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awaddr, is_coh, m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awdomain), UVM_LOW);
                    
                    m_ace_cache_model.update_addr(m_axi_req_tmp.m_cmd_type, m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awaddr
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            ,.security(m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awprot[1])
                        <% } %>
                    );

                    if (!success) begin
                        uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize write address packet in axi_master_write_coh_seq"), UVM_NONE);
                    end
                    if (!firstReqDone) begin
                        firstReqDone = 1;
                    end
                    if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
                    if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
                    s_wr_addr[core_id].get();
                    s_wr_data[core_id].get();
                    //uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("get s_wr_addr in coherent write"), UVM_HIGH);
                    m_axi_wr_req_q.push_back(m_axi_req_tmp);
                    count_outstanding_requests++;
                    gen_req_done = 0;
                end
                if (sequence_done) begin
                    //uvm_report_info("CHIRAG<%=this_aiu_id%>", "generate_requests breaking", UVM_NONE);
                    break;
                end
           end
        end : generate_requests
        begin : send_write_address
            int m_tmp_q[$];
            bit success;
            int do_count = 0;
            wr_req_t m_wr_req;
            wr_dat_t m_axi_dat_tmp;
            axi_write_addr_seq m_write_addr_seq;
            axi_wr_seq_item    m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
            m_wr_req.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");

            forever begin 
                //uvm_report_info("HS_DBG", $sformatf("foreverloop-send_write_address: checking if m_axi_wr_req_q.size:%0d", m_axi_wr_req_q.size()), UVM_LOW);
                //wait(((m_axi_wr_req_q.size() > 0) && m_ace_cache_model.coh_upd_txn_ok_to_send()) ||
                //   (sequence_done == 1 && !gen_req_done)
                //);
                wait((m_axi_wr_req_q.size() > 0) || (sequence_done == 1 && !gen_req_done));

                //uvm_report_info("HS_DBG", $sformatf("foreverloop-send_write_address: got past checking outstanding m_axi_wr_req_q.size:%0d", m_axi_wr_req_q.size()), UVM_LOW);

                if ((m_axi_wr_req_q.size() == 0 && sequence_done ==1 && !gen_req_done)) begin
                    //if (m_axi_wr_req_q.size() > 0)
                       // `uvm_error("coh_write_seq", "axi_wr_req_q.size:%0d when the coh_write_seq is about to be terminated");
                    write_addr_done = 1;
                    break;
                end else begin: wr_req_q_nonzero
                   // foreach (m_ace_cache_model.m_ort[i]) begin
                   //     if (m_ace_cache_model.m_ort[i].m_cmdtype inside  {WRLNUNQ, WRUNQ}) && m_ort[i].isReqInFlight)
                   //         `uvm_info("ORTB", $sformatf("%0p", m_ace_cache_model.m_ort[i]), UVM_LOW);
                   // end
                    do_count = 0;
                    do begin 
                        if (m_ace_cache_model.coh_upd_txn_ok_to_send() == 0) begin
                            //uvm_report_info("HS_DBG", $sformatf("foreverloop-send_write_address: waiting for ort_delete event count:%0d", do_count), UVM_LOW);
                            @m_ace_cache_model.e_ort_delete;
                            //uvm_report_info("HS_DBG", $sformatf("foreverloop-send_write_address: done waiting for ort_delete event:%0d", do_count), UVM_LOW);
                        end
                        do_count++;
                    end while ((m_ace_cache_model.coh_upd_txn_ok_to_send() == 0) && (do_count < 10000));
                    if (do_count == 10000)
                        `uvm_error("coh_write_seq", "10000 tries to clear all the outstanding wrunq/wrlineunq");
                end: wr_req_q_nonzero

                `uvm_info(get_full_name(), $sformatf("foreverloop-send_write_address: ah! finally coh update txn is ok to send outstanding num_coherent updates:%0d seq_done:%0d gen_req_done:%0d", m_axi_wr_req_q.size(), sequence_done, gen_req_done), UVM_LOW);

                //foreach (m_ace_cache_model.m_ort[i]) begin
                //        `uvm_info("ORTA", $sformatf("%0p", m_ace_cache_model.m_ort[i]), UVM_LOW);
                //end
                m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq");
                m_write_addr_seq.core_id = core_id; 
                m_write_addr_seq.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
                m_wr_req = m_axi_wr_req_q.pop_front();
                m_write_addr_seq.should_randomize = 0;
                m_write_addr_seq.m_seq_item.do_copy(m_wr_req.m_seq_item);
                m_write_addr_seq.s_wr_addr = s_wr_addr; 
                //check if the Coherent Wr is ok to send
                m_tmp_q = {};
                m_tmp_q = m_ace_cache_model.m_ort.find_first_index with (item.isRead == 0 &&
                    item.isUpdate == 1 &&
                    item.isCohWriteSent == 0 &&
                    item.m_addr[WAXADDR-1:SYS_wSysCacheline] == m_wr_req.m_addr[WAXADDR-1:SYS_wSysCacheline]
                    <% if (obj.wSecurityAttribute > 0) { %>
                        && item.m_security == m_wr_req.m_security
                    <% } %>
                );
        if (m_ace_cache_model.m_ort.size > m_ace_cache_model.max_number_of_outstanding_txn) begin
	     `uvm_error("AXI_SEQ",$sformatf("axi_master_write_noncoh_seq:cache m_ort_size :%0d greater than max_number_of_outstanding_txn :%0d",m_ace_cache_model.m_ort.size, m_ace_cache_model.max_number_of_outstanding_txn));
        end
                if (m_tmp_q.size() == 0) begin
                    m_ace_cache_model.print_queues();
                    uvm_report_error("ACE BFM SEQ AIU 0", $sformatf("TB Error: Cannot find address 0x%0x in m_ort", m_wr_req.m_addr), UVM_NONE);
                end
                else begin
                    aceState_t tmp_aceState;
                    start_state_queue_t m_possible_start_states_array = new();
                    aceState_t m_cache_state = m_ace_cache_model.current_cache_state(m_wr_req.m_addr
                        <% if (obj.wSecurityAttribute > 0) { %>
                            ,.security(m_wr_req.m_security)
                        <% } %>
                    );

                    m_possible_start_states_array = m_ace_cache_model.return_legal_start_states(m_wr_req.m_cmd_type);
                    success = 0;
                    for (int i = 0; i < m_possible_start_states_array.m_start_state_queue_t[0].size(); i++) begin
                        if(!$cast(tmp_aceState, m_possible_start_states_array.m_start_state_queue_t[0][i]))
                            `uvm_error("In Coh write seq(ACE CACHE MODEL)", "Cast failed to temp state");
                        if(m_cache_state == tmp_aceState) begin
                            success = 1;
                            break;
                        end
                    end
                    if(!success) begin
                    	//uvm_report_info(get_full_name(), $sformatf("Coh write from currstate:%0p cmd_type:%0p addr:0x%0h security:0x%0h is not ok to send so drop txn", m_cache_state, m_wr_req.m_cmd_type, m_wr_req.m_addr, m_wr_req.m_security), UVM_LOW);
                        m_ace_cache_model.m_ort.delete(m_tmp_q[0]);
                        ->m_ace_cache_model.e_ort_delete;
                        s_wr_addr[core_id].put();
                        s_wr_data[core_id].put();
                        if (m_ace_cache_model.s_coh_noncoh.try_get() == 0)
							m_ace_cache_model.s_coh_noncoh.put();
                        count_outstanding_requests--;
                        continue;
					end 
					else begin
                    	//uvm_report_info(get_full_name(), $sformatf("Coh write from currstate:%0p cmd_type:%0p addr:0x%0h security:0x%0h ok to send", tmp_aceState, m_wr_req.m_cmd_type, m_wr_req.m_addr, m_wr_req.m_security), UVM_NONE);
                    end
                end
                //prepare Wr data
                m_axi_dat_tmp.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
                success = m_axi_dat_tmp.m_seq_item.m_write_data_pkt.randomize();
                if (!success) begin
                    uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize write data packet in axi_master_write_coh_seq"), UVM_NONE);
                end
                m_axi_dat_tmp.m_seq_item.m_write_data_pkt.wdata = new [m_wr_req.m_seq_item.m_write_addr_pkt.awlen + 1];
                m_axi_dat_tmp.m_seq_item.m_write_data_pkt.wstrb = new [m_wr_req.m_seq_item.m_write_addr_pkt.awlen + 1];
                m_ace_cache_model.give_data_for_ace_req(m_wr_req.m_seq_item.m_write_addr_pkt.awaddr, m_wr_req.m_cmd_type, m_wr_req.m_seq_item.m_write_addr_pkt.awlen, m_wr_req.m_seq_item.m_write_addr_pkt.awburst, m_wr_req.m_seq_item.m_write_addr_pkt.awsize, m_axi_dat_tmp.m_seq_item.m_write_data_pkt.wdata, m_axi_dat_tmp.m_seq_item.m_write_data_pkt.wstrb
                    <% if (obj.wSecurityAttribute > 0) { %>
                        ,m_wr_req.m_seq_item.m_write_addr_pkt.awprot[1]
                    <% } %>
                );
                m_axi_dat_tmp.m_seq_item.m_write_addr_pkt = m_wr_req.m_seq_item.m_write_addr_pkt;
                if (m_wr_req.m_seq_item.m_write_addr_pkt.awcmdtype !== EVCT) begin
                    m_axi_wr_dat_q.push_back(m_axi_dat_tmp);
                end
                else begin
                    s_wr_data[core_id].put();
                end


                //set isCohWriteSent
                m_ace_cache_model.m_ort[m_tmp_q[0]].isCohWriteSent = 1;
				

				dbg_q = {};
  				dbg_q = m_ace_cache_model.m_ort.find_first_index with ((item.m_cmdtype inside {WRLNUNQ, WRUNQ}) && (item.isReqInFlight == 1));
				if (dbg_q.size() > 0) begin
        			`uvm_info("axi_master_write_coh_seq", $sformatf("%0p", m_ace_cache_model.m_ort[dbg_q[0]]), UVM_NONE);
					`uvm_info("axi_master_write_coh_seq", $sformatf("Sending coh_write[%0d] txn: %s from state:%0p", num_coh_wr_txns, m_write_addr_seq.m_seq_item.convert2string(), m_ace_cache_model.current_cache_state(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1])), UVM_LOW)
	        		`uvm_error("axi_master_write_coh_seq", $sformatf("TB Error: Above coherent update txn is about to be issued when there are outstanding WRUNQ and WRLNUNQ. Violating ARM IHI 0022H.c ACE Spec D4.8.7 Restrictions on WriteUnique and WriteLineUnique usage"))
				end 

                //send Coherent Wr
                m_write_addr_seq.return_response(m_seq_item, m_write_addr_chnl_seqr);

				`uvm_info(get_full_name(), $sformatf("Sent coh_write[%0d] txn: %s from state:%0p", num_coh_wr_txns, m_write_addr_seq.m_seq_item.convert2string(), m_ace_cache_model.current_cache_state(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_ace_wr_addr_chnl_security)), UVM_LOW)

				num_coh_wr_txns++;
                last_access_done = 1;
                m_axi_wr_rsp_q.push_back(m_wr_req.m_seq_item);
           end
        end : send_write_address
        begin : send_write_data
            wr_dat_t m_wr_dat;
            axi_write_data_seq m_write_data_seq;
            axi_wr_seq_item    m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
            wr_addr_data_t     m_wr_addr_data;
            m_wr_dat.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");

            forever begin 
                wait(m_axi_wr_dat_q.size() > 0 ||
                    (sequence_done == 1 && write_addr_done == 1)
                );
                if (m_axi_wr_dat_q.size() == 0 && sequence_done == 1 &&  write_addr_done == 1) begin
                    //uvm_report_info("CHIRAG", "send_write_data breaking", UVM_NONE);
                    break;
                end
                m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq");
                m_write_data_seq.core_id = core_id;
                if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
                m_write_data_seq.s_wr_data = s_wr_data;
                m_write_data_seq.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
                m_wr_dat = m_axi_wr_dat_q.pop_front();
                m_write_data_seq.should_randomize = 0;
                m_write_data_seq.m_seq_item.do_copy(m_wr_dat.m_seq_item);
                m_write_data_seq.return_response(m_seq_item, m_write_data_chnl_seqr);
                m_wr_addr_data.m_addr = m_wr_dat.m_seq_item.m_write_addr_pkt.awaddr;
                <% if (obj.wSecurityAttribute > 0) { %>
                    m_wr_addr_data.m_security = m_wr_dat.m_seq_item.m_write_addr_pkt.awprot[1];
                <% } %>                                                
                m_wr_addr_data.m_data = new[m_wr_dat.m_seq_item.m_write_data_pkt.wdata.size()] (m_wr_dat.m_seq_item.m_write_data_pkt.wdata);
                //uvm_report_info("AXI SEQ DEBUG", $sformatf("Address 0x%0x added to m_axi_wr_addr_data", m_wr_dat.m_seq_item.m_write_addr_pkt.awaddr), UVM_NONE);
                m_axi_wr_addr_data_q.push_back(m_wr_addr_data);
                ->e_axi_wr_data_add_q;
                last_access_done = 1;
           end
        end : send_write_data
        begin : get_write_response
            axi_wr_seq_item m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
            bit             copy_done = 1;

            forever begin
                wait(m_axi_wr_rsp_q.size() > 0 ||
                    (sequence_done == 1 && count_outstanding_requests == 0)
                );
                wait(copy_done == 1 ||
                    (sequence_done == 1 && count_outstanding_requests == 0)
                );
                if (m_axi_wr_rsp_q.size() > 0) begin
                    m_seq_item = m_axi_wr_rsp_q.pop_front();
                    copy_done = 0;
                    fork 
                        begin
                            axi_wr_seq_item m_fork_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
                            axi_write_resp_seq m_fork_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq");
                            m_fork_seq_item.do_copy(m_seq_item);
                            copy_done = 1;
                            // Waiting till data is sent before going through below set of code
                            if (m_fork_seq_item.m_write_addr_pkt.awcmdtype !== EVCT) begin
                                bit done = 0;
                                int m_tmp_q[$];
                                do begin
                                    m_tmp_q = {};
                                    m_tmp_q = m_axi_wr_addr_data_q.find_index with (item.m_addr == m_fork_seq_item.m_write_addr_pkt.awaddr 
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            && item.m_security == m_fork_seq_item.m_write_addr_pkt.awprot[1] 
                                        <% } %>                                                
                                    );
                                    if (m_tmp_q.size() == 0) begin
                                        @e_axi_wr_data_add_q;
                                    end 
                                    else begin
                                        done = 1;
                                    end
                                end while (!done);
                            end
                            //uvm_report_info("AXI SEQ DEBUG 1", $sformatf("Address 0x%0x id:0x%0x calling wait", m_fork_seq_item.m_write_addr_pkt.awaddr, m_fork_seq_item.m_write_addr_pkt.awid), UVM_NONE);
                            wait_till_awid_latest(m_fork_seq_item.m_write_addr_pkt);
                            //uvm_report_info("AXI SEQ DEBUG 1", $sformatf("Address 0x%0x id:0x%0x done waiting", m_fork_seq_item.m_write_addr_pkt.awaddr, m_fork_seq_item.m_write_addr_pkt.awid), UVM_NONE);
                            m_fork_resp_seq.should_randomize = 0;
                            m_fork_resp_seq.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
                            m_fork_resp_seq.m_seq_item.do_copy(m_fork_seq_item);
                            //uvm_report_info("AXI SEQ DEBUG 1", $sformatf("Address 0x%0x id:0x%0x calling fork", m_fork_seq_item.m_write_addr_pkt.awaddr, m_fork_seq_item.m_write_addr_pkt.awid), UVM_NONE);
                            m_fork_resp_seq.return_response(m_fork_seq_item, m_write_resp_chnl_seqr);
                            //uvm_report_info("AXI SEQ DEBUG 1", $sformatf("Address 0x%0x id:0x%0x done calling fork", m_fork_seq_item.m_write_addr_pkt.awaddr, m_fork_seq_item.m_write_addr_pkt.awid), UVM_NONE);
                            delete_ott_entry(m_fork_resp_seq.m_seq_item.m_write_addr_pkt);
                            if (m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awcmdtype != BARRIER) begin
                                if (m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awcmdtype == EVCT) begin
                                    axi_xdata_t wdata[];
                                    axi_bresp_t tmp_bresp[] = new[1];
                                    tmp_bresp[0] = m_fork_resp_seq.m_seq_item.m_write_resp_pkt.bresp;
                                    m_ace_cache_model.modify_cache_line(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awaddr, m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awcmdtype , tmp_bresp, wdata,
                                        .axdomain(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awdomain)
                                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                                            , .security(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awprot[1])
                                        <% } %>                                                
                                    );
                                end
                                else begin
                                    int m_tmp_q[$];
                                    axi_bresp_t tmp_bresp[] = new[1];
                                    m_tmp_q = m_axi_wr_addr_data_q.find_index with (item.m_addr == m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awaddr 
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            && item.m_security == m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awprot[1] 
                                        <% } %>                                                
                                    );
                                    if (m_tmp_q.size() == 0) begin
                                        foreach(m_axi_wr_addr_data_q[i]) begin
                                            uvm_report_info("AXI SEQ", $sformatf("i %0d Address:0x%0x", i, m_axi_wr_addr_data_q[i].m_addr), UVM_NONE);
                                        end
                                        uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not find write data packet in axi_wr_dat_q for address 0x%0x security 0x%0x", m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awaddr,
                                            <% if (obj.wSecurityAttribute > 0) { %>
                                                m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awprot[1]
                                            <% } else { %>                                                
                                                0
                                            <% } %>
                                        ), UVM_NONE);
                                    end
                                    tmp_bresp[0] = m_fork_resp_seq.m_seq_item.m_write_resp_pkt.bresp;
                                    m_ace_cache_model.modify_cache_line(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awaddr , m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awcmdtype, tmp_bresp, m_axi_wr_addr_data_q[m_tmp_q[0]].m_data,
                                        .axdomain(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awdomain)
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            , .security(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awprot[1])
                                        <% } %>                                                
                                    );
                                    //uvm_report_info("AXI SEQ DEBUG", $sformatf("Address 0x%0x deleting from m_axi_wr_addr_data", m_axi_wr_addr_data_q[m_tmp_q[0]].m_addr), UVM_NONE);
                                    m_axi_wr_addr_data_q.delete(m_tmp_q[0]);
                                end
                                if (m_ace_cache_model.m_cache.size() == 0 && pwrmgt_power_down == 1 && count_outstanding_requests <= 1) begin
                                    pwrmgt_power_down_done = 1;
                                    m_ace_cache_model.pwrmgt_cache_flush = 0;
                                    //`uvm_info("CHIRAG", "POWER MGT DONE SET 3", UVM_NONE);
                                    m_ace_cache_model.m_ort = {};
                                    ->m_ace_cache_model.e_cache_modify;
                                end
                            end
                            count_outstanding_requests--;
                        end
                    join_none
                end
                if (sequence_done && count_outstanding_requests == 0) begin
                    wait fork;
                    //uvm_report_info("CHIRAG", "get_write_response breaking", UVM_NONE);
                    break;
                end
            end
        end : get_write_response
    join

    //`uvm_info(get_full_name(), "CohWrite sequence finished", UVM_LOW);
endtask:body

endclass : axi_master_write_coh_seq

<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
class ace_master_cache_flush_seq extends axi_master_write_base_seq;
    `uvm_object_param_utils(ace_master_cache_flush_seq)
    
	axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
	axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
	axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;
    ace_cache_model               m_ace_cache_model;

	axi_wr_seq_item               m_wr_seq_item;
	static bit                    pwrmgt_power_down;
    static bit                    pwrmgt_power_down_done;
	
    event e_axi_wr_data_add_q;
	typedef struct {
        ace_command_types_enum_t 							m_cmd_type;
        axi_axaddr_t             							m_addr;
        <% if (obj.wSecurityAttribute > 0) { %>                                             
            bit [<%=obj.wSecurityAttribute%>-1:0]           m_security;
        <% } %>                                                
        axi_wr_seq_item                                     m_seq_item;
    } wr_req_t;

	typedef struct {
        axi_xdata_t m_data[];
        axi_wr_seq_item                        m_seq_item;
    } wr_dat_t;

    typedef struct {
        axi_axaddr_t   m_addr;
        <% if (obj.wSecurityAttribute > 0) { %>                                             
            bit [<%=obj.wSecurityAttribute%>-1:0] m_security;
        <% } %>                                                
        axi_xdata_t    m_data[];
    } wr_addr_data_t;
    
    typedef struct {
        axi_axaddr_t   m_addr;
        <% if (obj.wSecurityAttribute > 0) { %>                                             
            bit [<%=obj.wSecurityAttribute%>-1:0] m_security;
        <% } %>                                                
    } cache_flush_addr_t;

	function new(string name = "ace_master_cache_flush_seq");
    	super.new(name);
	endfunction : new

	task body;
		wr_req_t 			m_axi_wr_req_q[$];
	    wr_dat_t 			m_axi_wr_dat_q[$];
	    wr_addr_data_t 		m_axi_wr_addr_data_q[$];
    	axi_wr_seq_item 	m_axi_wr_rsp_q[$];
		cache_flush_addr_t 	m_cache_flush_addr_tmp;
		cache_flush_addr_t 	m_cache_flush_addr_q[$];
		int 				fnd_idxq[$];

    	bit gen_req_done 			   		= 0;
    	bit firstReqDone 			  		= 0;
    	bit last_access_done 		   		= 0;
    	int count_outstanding_requests 		= 0;
    	bit write_addr_done            		= 0;
    	bit delete_snoop_entries_cache_flush_addr_q	= 0;
        int temp_coh_addr_match_idxq[$];
		bit generate_requests_thread_done	= 0;
		int coh_addr_match_idxq[$]     		= m_ace_cache_model.m_cache.find_index(item) with (item.m_non_coherent_addr == 0 && item.m_state != ACE_IX);

		int num_txns = coh_addr_match_idxq.size();
        //uvm_report_info("ACE_MASTER_CACHE_FLUSH_SEQ", $sformatf("num_txns: %0d", num_txns), UVM_NONE);

		m_cache_flush_addr_q = {};
	    foreach (coh_addr_match_idxq[i]) begin
			m_cache_flush_addr_tmp.m_addr 		= m_ace_cache_model.m_cache[coh_addr_match_idxq[i]].m_addr;
<% if (obj.wSecurityAttribute > 0) { %>                                             
			m_cache_flush_addr_tmp.m_security	= m_ace_cache_model.m_cache[coh_addr_match_idxq[i]].m_security;
<% } %>                                                
			m_cache_flush_addr_q.push_back(m_cache_flush_addr_tmp);
    	end
        
        uvm_report_info("ACE_MASTER_CACHE_FLUSH_SEQ", $sformatf("Total number of transactions - cache_flush_addrq.size: %0d", m_cache_flush_addr_q.size()), UVM_NONE);
		
		if (num_txns != 0) begin 

			fork
				begin : generate_requests

					m_ace_cache_model.prob_cache_flush_mode_per_1k = 1001;
					m_ace_cache_model.pwrmgt_cache_flush   = 1;
					m_ace_cache_model.end_of_sim   		   = 0;
					m_ace_cache_model.coh_write_seq_active = 0;

					//CONC-9761 Force wt for update commands to be non-zero for ace cache flush sequence
					m_ace_cache_model.wt_ace_wrbk = 100;
					m_ace_cache_model.wt_ace_evct = 100;
					m_ace_cache_model.wt_ace_wrevct = 100;


					for (int i = 1; i <= num_txns; i++) begin
						wr_req_t m_axi_req_tmp;
						bit done;
						bit loop_done;
						bit nothing_to_flush = 0;
						bit not_sending_addr;
						bit success = 0;
						bit constrain_awunique = 0;
						bit m_tmp_awunique;
						axi_awid_t use_awid;
						aceState_t m_cache_state;
						bit is_coh;
						int m_tmp_q[$];
						int do_count;
						m_axi_req_tmp.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
					
						//uvm_report_info("ACE_MASTER_CACHE_FLUSH_SEQ", $sformatf("thread:generate_requests txn:%0d firstReqDone:%0d last_access_done:%0d", i, firstReqDone, last_access_done), UVM_NONE);
						last_access_done = 0;
						done = 0;
						do_count = 0;

						do 
						begin
							m_ace_cache_model.give_addr_for_ace_req_coh_write(m_axi_req_tmp.m_cmd_type, not_sending_addr, m_axi_req_tmp.m_addr
									<% if (obj.wSecurityAttribute > 0) { %>                                             
										,m_axi_req_tmp.m_security
									<% } %>
								);
							fnd_idxq = {};
							fnd_idxq = m_cache_flush_addr_q.find_index(item) with (item.m_addr == m_axi_req_tmp.m_addr
	<% if (obj.wSecurityAttribute > 0) { %>                                             
										&& item.m_security == m_axi_req_tmp.m_security
	<% } %>);
							do_count++;
                                                        //CONC-9872 cache-flush sequence is in progress, there can be invalidating snoops to the cache-lines and m_ace_cache_model.m_cache can become empty
		                                        temp_coh_addr_match_idxq = m_ace_cache_model.m_cache.find_index(item) with (item.m_non_coherent_addr == 0 && item.m_state != ACE_IX);
                                                        if(temp_coh_addr_match_idxq.size()==0 ) begin
                                                            foreach(m_cache_flush_addr_q[m])begin 
						            uvm_report_info("ACE_MASTER_CACHE_FLUSH_SEQ", $sformatf("Deleting snooped/invalidated cache entries 0x%0h ", m_cache_flush_addr_q[m].m_addr), UVM_LOW);
                                                            end
                                                            m_cache_flush_addr_q.delete();
                                                            delete_snoop_entries_cache_flush_addr_q=1;
                                                            break;
                                                        end
						end while (fnd_idxq.size() == 0 && do_count < 1000);
                                                if(delete_snoop_entries_cache_flush_addr_q==1) break;
						if (do_count == 1000)
							uvm_report_error($sformatf("ACE_MASTER_CACHE_FLUSH_SEQ", get_full_name()), $sformatf("give_addr_for_ace_req_coh_write unable to find addr even after 1000 iterations for Cmdtype %0s", m_axi_req_tmp.m_cmd_type), UVM_NONE);
						
						m_cache_flush_addr_q.delete(fnd_idxq[0]);
						
						//uvm_report_info("ACE_MASTER_CACHE_FLUSH_SEQ", $sformatf("thread:generate_requests txn:%0d not_sending_addr:%0d", i, not_sending_addr), UVM_LOW);
						if (not_sending_addr) begin
							pwrmgt_power_down_done = 1;
							m_ace_cache_model.pwrmgt_cache_flush = 0;
							nothing_to_flush = 1;
							done = 1;
							m_ace_cache_model.m_ort = {};
							->m_ace_cache_model.e_cache_modify;
							//uvm_report_info("ACE_MASTER_CACHE_FLUSH_SEQ", $sformatf("thread:generate_requests txn:%0d breaking from forever loop num_requestq_size:%0d", i, m_axi_wr_req_q.size()), UVM_NONE);
						end

						m_cache_state = m_ace_cache_model.current_cache_state(m_axi_req_tmp.m_addr
							<% if (obj.wSecurityAttribute > 0) { %>                                             
								,.security(m_axi_req_tmp.m_security)
							<% } %>                                                
						);
						gen_req_done = 1;

						//`uvm_info("ACE_MASTER_CACHE_FLUSH_SEQ", $sformatf("thread:generate_requests txn:%0d CACHE-FLUSH cmdtype %0s address 0x%0x secure bit 0x%0x, state %0s", 
//							i,
//							m_axi_req_tmp.m_cmd_type.name(), 
//							m_axi_req_tmp.m_addr, 
//	<% if (obj.wSecurityAttribute > 0) { %>                                             
//							m_axi_req_tmp.m_security
//							<% } else { %>
//								0
//							<% } %>,
//							m_cache_state), UVM_NONE)
					
						//uvm_report_info("AIU TB", $sformatf("-------------------thread:generate_requests txn:%0d ORT Contents Before--------------------", i), UVM_NONE);
					//	foreach (m_ace_cache_model.m_ort[i]) begin
					//		if (m_ace_cache_model.m_ort[i].m_addr == 'h478523c9e100)
					//			`uvm_info("ORT", $sformatf("%0p", m_ace_cache_model.m_ort[i]), UVM_NONE);
					//	end
						m_tmp_q = {};
						m_tmp_q = m_ace_cache_model.m_ort.find_first_index with (item.isRead == 0 &&
							item.m_addr == m_axi_req_tmp.m_addr
							<% if (obj.wSecurityAttribute > 0) { %>                                             
								&& item.m_security == m_axi_req_tmp.m_security
							<% } %>
						);
					
						if (m_tmp_q.size() == 0) begin
							uvm_report_error("ACE_MASTER_CACHE_FLUSH_SEQ", $sformatf("TB Error: Cannot find address 0x%0x in m_ort", m_axi_req_tmp.m_addr), UVM_NONE);
						end
						else begin
							if (m_tmp_q.size() > 0) begin
								m_ace_cache_model.m_ort[m_tmp_q[0]].isReqInFlight = 1;
							end
						end
						constrain_awunique = 0;
						if (m_axi_req_tmp.m_cmd_type == WRBK) begin 
							if (m_cache_state == ACE_SD) begin
								m_tmp_awunique     = 0;
								constrain_awunique = 1;
							end
						end
						get_axid(m_axi_req_tmp.m_cmd_type, use_awid);
						m_tmp_q = {};
						m_tmp_q = m_ace_cache_model.m_cache.find_first_index with (item.m_addr == m_axi_req_tmp.m_addr &&
																				<% if (obj.wSecurityAttribute > 0) { %>
																				   item.m_security == m_axi_req_tmp.m_security
																				<% } %>
																				  );
                        is_coh = !m_ace_cache_model.m_cache[m_tmp_q[0]].m_non_coherent_addr;
                        m_axi_req_tmp.m_seq_item.m_write_addr_pkt.constrained_addr = 1;
						success = m_axi_req_tmp.m_seq_item.m_write_addr_pkt.randomize() with {
							m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awid      == use_awid;
							m_axi_req_tmp.m_seq_item.m_write_addr_pkt.coh_domain == is_coh;
							m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awcmdtype == m_axi_req_tmp.m_cmd_type;
							m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awaddr    == m_axi_req_tmp.m_addr;
						        if (constrain_awunique == 1  && WUSEACEUNIQUE>0) m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awunique == m_tmp_awunique;
							<% if (obj.wSecurityAttribute > 0) { %>                                             
								m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awprot[1] == m_axi_req_tmp.m_security;
							<% } %>                                                
						};
					
						//`uvm_info("ACE_MASTER_CACHE_FLUSH_SEQ", $sformatf("thread:generate_requests txn:%0d Coh write. CMD:%h, addr:0x%x, ns:0x%x is_coh:%0b, awdomain:%h", i, m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awcmdtype, m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awaddr, m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awprot[1], is_coh, m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awdomain), UVM_NONE);
	                                        
                                                m_ace_cache_model.update_addr(m_axi_req_tmp.m_cmd_type, m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awaddr
							<% if (obj.wSecurityAttribute > 0) { %>                                             
								,.security(m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awprot[1])
							<% } %>
						);

						if (!success)
							uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize write address packet in axi_master_write_coh_seq"), UVM_NONE);
						if (!firstReqDone)
							firstReqDone = 1;
                        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
                        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
						s_wr_addr[core_id].get();
						s_wr_data[core_id].get();
						//uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("get s_wr_addr in coherent write"), UVM_HIGH);
						m_axi_wr_req_q.push_back(m_axi_req_tmp);
						count_outstanding_requests++;
						gen_req_done = 0;
				
						//uvm_report_info("AIU TB", $sformatf("-------------------thread:generate_requests txn:%0d ORT Contents After--------------------", i), UVM_NONE);
					end //foreach cache[i] block
					generate_requests_thread_done = 1;
					if (m_cache_flush_addr_q.size() != 0)
						uvm_report_error("ACE CACHE FLUSH SEQ", $sformatf("m_cache_flush_addrq.size:%0d at the end of thread:generate_requests", m_cache_flush_addr_q.size()), UVM_NONE);

					//uvm_report_info("ACE CACHE FLUSH SEQ", "thread:generate_requests finished", UVM_NONE);
				end : generate_requests
				begin : send_write_address
					int m_tmp_q[$];
					bit success;
					int num_addr_issued = 0;
					wr_req_t m_wr_req;
					wr_dat_t m_axi_dat_tmp;
					axi_write_addr_seq m_write_addr_seq;
					axi_wr_seq_item    m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
					m_wr_req.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");

					//uvm_report_info("ACE CACHE FLUSH SEQ", "thread:send_write_address invoked", UVM_NONE);
					forever begin 
						wait(m_axi_wr_req_q.size() > 0 || (generate_requests_thread_done && !gen_req_done));
						//uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:send_write_address num_addr_issued:%0d done waiting for m_axi_wr_req_q.size:%0d gen_req_done:%0d count_outstanding_requests:%0d", num_addr_issued, m_axi_wr_req_q.size(), gen_req_done, count_outstanding_requests), UVM_NONE);
						if ((m_axi_wr_req_q.size() == 0 && generate_requests_thread_done && !gen_req_done)) begin
							//uvm_report_info("CHIRAG", "send_write_address breaking", UVM_NONE);
							//uvm_report_info("ACE CACHE FLUSH SEQ", "thread:send_write_address m_axi_wr_req_q.size==0 and gen_req_done==0 and generate_requests_thread_done==1 hence break", UVM_NONE);
							write_addr_done = 1;
							break;
						end
						m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq");
                        m_write_addr_seq.core_id = core_id; 
						m_write_addr_seq.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
						m_wr_req = m_axi_wr_req_q.pop_front();
						m_write_addr_seq.should_randomize = 0;
						m_write_addr_seq.m_seq_item.do_copy(m_wr_req.m_seq_item);
						//check if the Coherent Wr is ok to send
						m_tmp_q = {};
						m_tmp_q = m_ace_cache_model.m_ort.find_first_index with (item.isRead == 0 &&
						item.isUpdate == 1 &&
						item.isCohWriteSent == 0 &&
						item.m_addr[WAXADDR-1:SYS_wSysCacheline] == m_wr_req.m_addr[WAXADDR-1:SYS_wSysCacheline]
						<% if (obj.wSecurityAttribute > 0) { %>
							&& item.m_security == m_wr_req.m_security
						<% } %>);
						if (m_tmp_q.size() == 0) begin
							m_ace_cache_model.print_queues();
							uvm_report_error("ACE BFM SEQ AIU 0", $sformatf("TB Error: Cannot find address 0x%0x in m_ort", m_wr_req.m_addr), UVM_NONE);
						end
						else begin
							aceState_t tmp_aceState;
							start_state_queue_t m_possible_start_states_array = new();
							aceState_t m_cache_state = m_ace_cache_model.current_cache_state(m_wr_req.m_addr
							<% if (obj.wSecurityAttribute > 0) { %>
								,.security(m_wr_req.m_security)
							<% } %>
						);
							m_possible_start_states_array = m_ace_cache_model.return_legal_start_states(m_wr_req.m_cmd_type);
							success = 0;
							for (int i = 0; i < m_possible_start_states_array.m_start_state_queue_t[0].size(); i++) begin
								if(!$cast(tmp_aceState, m_possible_start_states_array.m_start_state_queue_t[0][i]))
								`uvm_error("In Coh write seq(ACE CACHE MODEL)", "Cast failed to temp state");
								if(m_cache_state == tmp_aceState) begin
									success = 1;
									break;
								end
							end
							if(!success) begin
								//uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:send_write_address success:%0d", success), UVM_NONE);
								m_ace_cache_model.m_ort.delete(m_tmp_q[0]);
								->m_ace_cache_model.e_ort_delete;
								s_wr_addr[core_id].put();
								s_wr_data[core_id].put();
								count_outstanding_requests--;
								continue;
							end
						end
						//uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:send_write_address about to prep wr_data for addr:0x%0h security:%0d count_outstanding_requests:%0d", m_wr_req.m_addr, m_wr_req.m_security, count_outstanding_requests), UVM_NONE);
						//prepare Wr data
						m_axi_dat_tmp.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
						success = m_axi_dat_tmp.m_seq_item.m_write_data_pkt.randomize();
						if (!success) begin
							uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize write data packet in axi_master_write_coh_seq"), UVM_NONE);
						end
						m_axi_dat_tmp.m_seq_item.m_write_data_pkt.wdata = new [m_wr_req.m_seq_item.m_write_addr_pkt.awlen + 1];
						m_axi_dat_tmp.m_seq_item.m_write_data_pkt.wstrb = new [m_wr_req.m_seq_item.m_write_addr_pkt.awlen + 1];
						m_ace_cache_model.give_data_for_ace_req(m_wr_req.m_seq_item.m_write_addr_pkt.awaddr, m_wr_req.m_cmd_type, m_wr_req.m_seq_item.m_write_addr_pkt.awlen, m_wr_req.m_seq_item.m_write_addr_pkt.awburst, m_wr_req.m_seq_item.m_write_addr_pkt.awsize, m_axi_dat_tmp.m_seq_item.m_write_data_pkt.wdata, m_axi_dat_tmp.m_seq_item.m_write_data_pkt.wstrb
						<% if (obj.wSecurityAttribute > 0) { %>
							,m_wr_req.m_seq_item.m_write_addr_pkt.awprot[1]
						<% } %>);
						m_axi_dat_tmp.m_seq_item.m_write_addr_pkt = m_wr_req.m_seq_item.m_write_addr_pkt;
						if (m_wr_req.m_seq_item.m_write_addr_pkt.awcmdtype !== EVCT) begin
							m_axi_wr_dat_q.push_back(m_axi_dat_tmp);
						end
						else begin
							s_wr_data[core_id].put();
						end
						//set isCohWriteSent
						m_ace_cache_model.m_ort[m_tmp_q[0]].isCohWriteSent = 1;
						//uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:send_write_address ORT.isCohWriteSent set for addr = 0x%x, security:%0d cmdtype = %s", m_wr_req.m_addr, m_wr_req.m_security, m_wr_req.m_cmd_type.name()), UVM_NONE);
						//send Coherent Wr
						m_write_addr_seq.return_response(m_seq_item, m_write_addr_chnl_seqr);
						num_addr_issued++;
					//	uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:send_write_address num_addr_issued:%0d Done sent Coherent Write addr = 0x%x, security:%0d cmdtype = %s", num_addr_issued, m_wr_req.m_addr, m_wr_req.m_security, m_wr_req.m_cmd_type.name()), UVM_NONE);
						last_access_done = 1;
						m_axi_wr_rsp_q.push_back(m_wr_req.m_seq_item);
					end //forever block
				//	uvm_report_info("ACE CACHE FLUSH SEQ", "thread:send_write_address finished", UVM_NONE);
				end : send_write_address
			begin : send_write_data
				wr_dat_t m_wr_dat;
				axi_write_data_seq m_write_data_seq;
				axi_wr_seq_item    m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
				wr_addr_data_t     m_wr_addr_data;
				m_wr_dat.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
				
				//uvm_report_info("ACE CACHE FLUSH SEQ", "thread:send_write_data invoked", UVM_NONE);
				forever begin 
					wait(m_axi_wr_dat_q.size() > 0 || write_addr_done == 1);
					if (m_axi_wr_dat_q.size() == 0 && write_addr_done == 1) begin
						//uvm_report_info("ACE CACHE FLUSH SEQ", "thread:send_write_data breaking", UVM_NONE);
						break;
					end
					m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq");
                    if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
                    m_write_data_seq.s_wr_data = s_wr_data;
                    m_write_data_seq.core_id = core_id;
					m_write_data_seq.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
					m_wr_dat = m_axi_wr_dat_q.pop_front();
					m_write_data_seq.should_randomize = 0;
					m_write_data_seq.m_seq_item.do_copy(m_wr_dat.m_seq_item);
					m_write_data_seq.return_response(m_seq_item, m_write_data_chnl_seqr);
					m_wr_addr_data.m_addr = m_wr_dat.m_seq_item.m_write_addr_pkt.awaddr;
					<% if (obj.wSecurityAttribute > 0) { %>
						m_wr_addr_data.m_security = m_wr_dat.m_seq_item.m_write_addr_pkt.awprot[1];
					<% } %>                                                
					m_wr_addr_data.m_data = new[m_wr_dat.m_seq_item.m_write_data_pkt.wdata.size()] (m_wr_dat.m_seq_item.m_write_data_pkt.wdata);
					//uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:send_write_data address 0x%0x added to m_axi_wr_addr_data_q", m_wr_dat.m_seq_item.m_write_addr_pkt.awaddr), UVM_NONE);
					m_axi_wr_addr_data_q.push_back(m_wr_addr_data);
					->e_axi_wr_data_add_q;
					last_access_done = 1;
			   end
			   //uvm_report_info("ACE CACHE FLUSH SEQ", "thread:send_write_data finished", UVM_NONE);
			end : send_write_data
			begin : get_write_response
				axi_wr_seq_item m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
				bit             copy_done = 1;
				int num_wr_resp_recd = 0;

				uvm_report_info("ACE CACHE FLUSH SEQ", "thread:get_write_resp invoked", UVM_NONE);
				forever begin
					wait (m_axi_wr_rsp_q.size() > 0 || (generate_requests_thread_done == 1 && count_outstanding_requests == 0));
					//uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:get_write_response After 1st wait m_axi_wr_rsp_q.size:%0d generate_requests_thread_done:%0d count_outstanding_requests:%0d num_wr_resp_recd:%0d", m_axi_wr_rsp_q.size(), generate_requests_thread_done, count_outstanding_requests, num_wr_resp_recd), UVM_NONE);
					wait (copy_done == 1 || (generate_requests_thread_done == 1 && count_outstanding_requests == 0));
	 
					//uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:get_write_response After 2nd wait copy_done:%0d generate_requests_thread_done:%0d count_outstanding_requests:%0d", copy_done, generate_requests_thread_done, count_outstanding_requests), UVM_NONE);
					
					if (m_axi_wr_rsp_q.size() > 0) begin
						m_seq_item = m_axi_wr_rsp_q.pop_front();
						copy_done = 0;
						fork 
							begin //thread1
								axi_wr_seq_item m_fork_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
								axi_write_resp_seq m_fork_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq");
								m_fork_seq_item.do_copy(m_seq_item);
								copy_done = 1;
								// Waiting till data is sent before going through below set of code
								if (m_fork_seq_item.m_write_addr_pkt.awcmdtype !== EVCT) begin
									bit done = 0;
									int m_tmp_q[$];
									do begin
										m_tmp_q = {};
										m_tmp_q = m_axi_wr_addr_data_q.find_index with (item.m_addr == m_fork_seq_item.m_write_addr_pkt.awaddr 
											<% if (obj.wSecurityAttribute > 0) { %>
												&& item.m_security == m_fork_seq_item.m_write_addr_pkt.awprot[1] 
											<% } %>                                                
										);
										if (m_tmp_q.size() == 0) begin
											@e_axi_wr_data_add_q;
										end 
										else begin
											done = 1;
										end
									end while (!done);
								end//(m_fork_seq_item.m_write_addr_pkt.awcmdtype !== EVCT)
								//uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:get_write_response Address 0x%0x id:0x%0x calling wait", m_fork_seq_item.m_write_addr_pkt.awaddr, m_fork_seq_item.m_write_addr_pkt.awid), UVM_NONE);
								wait_till_awid_latest(m_fork_seq_item.m_write_addr_pkt);
								//uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:get_write_response Address 0x%0x id:0x%0x done waiting", m_fork_seq_item.m_write_addr_pkt.awaddr, m_fork_seq_item.m_write_addr_pkt.awid), UVM_NONE);
								m_fork_resp_seq.should_randomize = 0;
								m_fork_resp_seq.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
								m_fork_resp_seq.m_seq_item.do_copy(m_fork_seq_item);
								//uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:get_write_response Address 0x%0x id:0x%0x calling fork", m_fork_seq_item.m_write_addr_pkt.awaddr, m_fork_seq_item.m_write_addr_pkt.awid), UVM_NONE);
								m_fork_resp_seq.return_response(m_fork_seq_item, m_write_resp_chnl_seqr);
								num_wr_resp_recd++;
								//uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:get_write_response Address 0x%0x id:0x%0x num_wr_resp_recd:%0d done calling fork", m_fork_seq_item.m_write_addr_pkt.awaddr, m_fork_seq_item.m_write_addr_pkt.awid, num_wr_resp_recd), UVM_NONE);
								delete_ott_entry(m_fork_resp_seq.m_seq_item.m_write_addr_pkt);
									if (m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awcmdtype == EVCT) begin
										axi_xdata_t wdata[];
										axi_bresp_t tmp_bresp[] = new[1];
										tmp_bresp[0] = m_fork_resp_seq.m_seq_item.m_write_resp_pkt.bresp;
										m_ace_cache_model.modify_cache_line(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awaddr, m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awcmdtype , tmp_bresp, wdata,
											.axdomain(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awdomain)
											<% if (obj.wSecurityAttribute > 0) { %>                                             
												, .security(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awprot[1])
											<% } %>                                                
										);
									end //EVCT
									else begin //WRBK, WREVCT
										int m_tmp_q[$];
										axi_bresp_t tmp_bresp[] = new[1];
										m_tmp_q = m_axi_wr_addr_data_q.find_index with (item.m_addr == m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awaddr 
											<% if (obj.wSecurityAttribute > 0) { %>
												&& item.m_security == m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awprot[1] 
											<% } %>                                                
										);
										if (m_tmp_q.size() == 0) begin
											/*foreach(m_axi_wr_addr_data_q[i]) begin
												uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:get_write_response i %0d Address:0x%0x", i, m_axi_wr_addr_data_q[i].m_addr), UVM_NONE);
											end*/
											uvm_report_error("ACE CACHE FLUSH SEQ", $sformatf("TB Error: Could not find write data packet in axi_wr_dat_q for address 0x%0x security 0x%0x", m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awaddr,
												<% if (obj.wSecurityAttribute > 0) { %>
													m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awprot[1]
												<% } else { %>                                                
													0
												<% } %>
											), UVM_NONE);
										end
										tmp_bresp[0] = m_fork_resp_seq.m_seq_item.m_write_resp_pkt.bresp;
										m_ace_cache_model.modify_cache_line(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awaddr , m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awcmdtype, tmp_bresp, m_axi_wr_addr_data_q[m_tmp_q[0]].m_data,
											.axdomain(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awdomain)
											<% if (obj.wSecurityAttribute > 0) { %>
												, .security(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awprot[1])
											<% } %>                                                
										);
										uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:get_write_response Address 0x%0x deleting from m_axi_wr_addr_data count_outstanding_requests:%0d", m_axi_wr_addr_data_q[m_tmp_q[0]].m_addr, count_outstanding_requests), UVM_NONE);
										m_axi_wr_addr_data_q.delete(m_tmp_q[0]);
									end  //WRBK, WREVCT
								count_outstanding_requests--;
							end  //thread1
						join_none
					end//if (m_axi_wr_rsp_q.size() > 0)
					if (generate_requests_thread_done == 1 & count_outstanding_requests == 0) begin
						wait fork;
						//uvm_report_info("ACE CACHE FLUSH SEQ", $sformatf("thread:get_write_response get_write_response breakingnum_wr_resp_recd:%0d", num_wr_resp_recd), UVM_NONE);
						break;
					end
				end //forever block

				//uvm_report_info("ACE CACHE FLUSH SEQ", "thread:get_write_resp finished", UVM_NONE);
			end : get_write_response
			join

		end //if (num_txns != 0)

		//uvm_report_info("ACE CACHE FLUSH SEQ", "Check cache-contents at end of sequence", UVM_NONE);
		coh_addr_match_idxq = {};
		coh_addr_match_idxq = m_ace_cache_model.m_cache.find_index(item) with (item.m_non_coherent_addr == 0 && item.m_state != ACE_IX);
		
		if (coh_addr_match_idxq.size() != 0) begin
	        foreach (m_ace_cache_model.m_cache[i]) begin
	        	if (m_ace_cache_model.m_cache[i].m_non_coherent_addr == 0)
        	    	`uvm_info("CACHE_A", m_ace_cache_model.m_cache[i].sprint_pkt(), UVM_NONE);
    	    end

			`uvm_error("ACE_MASTER_CACHE_FLUSH_SEQ", $sformatf("ACE processor cache not empty on sequence completion cache_size:%0d", coh_addr_match_idxq.size()));
		end

        m_ace_cache_model.pwrmgt_cache_flush   = 0;
        m_ace_cache_model.cache_flush_mode_on  = 0;
		m_ace_cache_model.end_of_sim   		   = 0;
        m_ace_cache_model.s_coh_noncoh.put();
    	//`uvm_info("body", "Exiting...", UVM_LOW)
	endtask
endclass:ace_master_cache_flush_seq
<% } %>                                                

//******************************************************************************
// To generate a stream of WB 
// Purpose : Generates a single WriteOnce transaction.
// Warning: This sequence can only be used in the block level because it 
// will just send WBs without care for whether the cacheline is in the agent's
// cache or not. For this reason, I am not going to use the ace_cache_model
//******************************************************************************


class axi_master_writeback_seq extends axi_master_write_base_seq;

    `uvm_object_param_utils(axi_master_writeback_seq)
    
    axi_write_addr_seq            m_write_addr_seq;
    axi_write_data_seq            m_write_data_seq;
    axi_write_resp_seq            m_write_resp_seq;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;
    axi_wr_seq_item               m_seq_item0;
    axi_wr_seq_item               m_seq_item1;

    axi_axaddr_t     m_addr;
    axi_axlen_t      m_axlen;


    //Control Knobs

    int k_num_write_req         = 1;
    addr_trans_mgr m_addr_mgr;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_master_writeback_seq");
    super.new(name);
    m_addr_mgr = addr_trans_mgr::get_instance();
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    int num_req;
    bit success;
    ace_cache_line_model m_cache[$];
    bit [63:0]           m_inflight_q[$];

    num_req = 0;
    m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq"); 
    m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq"); 
    m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq");
    m_write_addr_seq.core_id = core_id; 
    m_write_data_seq.core_id = core_id;
    if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
    if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
    m_write_addr_seq.s_wr_addr = s_wr_addr; 
    m_write_data_seq.s_wr_data = s_wr_data; 
    do begin
        bit done = 0;
        bit [addrMgrConst::W_SEC_ADDR - 1 : 0] sec_addr;
        axi_awid_t use_awid;
	   	if(s_wr[core_id] == null) s_wr[core_id] = new(1);
        s_wr[core_id].get();
        m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRBK;
        sec_addr = m_addr_mgr.get_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>, 1, 0, core_id);
        m_write_addr_seq.m_ace_wr_addr_chnl_addr = sec_addr;
        <% if (obj.wSecurityAttribute > 0) { %>                                             
            m_write_addr_seq.m_ace_wr_addr_chnl_security = sec_addr[addrMgrConst::W_SEC_ADDR - 1];
        <% } %>                                                
        done = 1;
        if (done) begin
            uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("WR snooptype %0s address 0x%0x secure bit 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_ace_wr_addr_chnl_addr, 
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    m_write_addr_seq.m_ace_wr_addr_chnl_security
                <% } else { %>
                    0
                <% } %>
            ), UVM_MEDIUM);

        end
        m_write_addr_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_addr_seq.m_constraint_snoop        = 1;
        m_write_addr_seq.m_constraint_addr         = 1;

        get_axid(m_write_addr_seq.m_ace_wr_addr_chnl_snoop, use_awid);
        m_write_addr_seq.m_seq_item.m_write_addr_pkt.constrained_addr = 1;
        success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
            if (m_write_addr_seq.m_constraint_snoop == 1) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
            m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid   == use_awid;
            m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr == m_write_addr_seq.m_ace_wr_addr_chnl_addr;
            // For directed test case purposes
            m_write_addr_seq.m_seq_item.m_write_addr_pkt.useFullCL == use_full_cl;
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]==m_write_addr_seq.m_ace_wr_addr_chnl_security;
            <% } %>
        };
        if (!success) begin
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize write address packet in axi_master_writeback_seq"), UVM_NONE);
        end

        `uvm_info("ACE BFM SEQ",$sformatf("WR snooptype %0s address 0x%0x len 0x%0x" ,
                                m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name() ,
                                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen), UVM_MEDIUM);

        success = m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
        if (!success) begin
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize write data packet in axi_master_writeback_seq"), UVM_NONE);
        end
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        foreach (m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[i]) begin
            axi_xdata_t tmp_data;
            axi_xstrb_t tmp_strb;
            assert(std::randomize(tmp_data))
            else begin
                uvm_report_error($sformatf("%s", get_full_name()), "Failure to randomize tmp_data", UVM_NONE);
            end
            assert(std::randomize(tmp_strb))
            else begin
                uvm_report_error($sformatf("%s", get_full_name()), "Failure to randomize tmp_strb", UVM_NONE);
            end
            m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[i] = tmp_data;
            m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[i] = tmp_strb;
        end
        
        m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;
        m_write_addr_seq.should_randomize = 0;
        m_write_data_seq.should_randomize = 0;
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        s_wr_addr[core_id].get();
        s_wr_data[core_id].get();
        fork 
            begin
                m_write_addr_seq.return_response(m_seq_item0, m_write_addr_chnl_seqr);
            end
            begin
                // Nothing goes on write data channel for evicts
                if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== EVCT &&
                    m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== STASHONCEUNQ &&		    
                    m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== STASHONCESHARED

                ) begin
                    m_write_data_seq.return_response(m_seq_item1, m_write_data_chnl_seqr);
                end
            end
        join
        s_wr[core_id].put();
        wait_till_awid_latest(m_write_addr_seq.m_seq_item.m_write_addr_pkt);
        m_write_resp_seq.should_randomize = 0;
        m_write_resp_seq.m_seq_item       = m_seq_item0;
        m_write_resp_seq.return_response(m_seq_item0, m_write_resp_chnl_seqr);
        delete_ott_entry(m_write_addr_seq.m_seq_item.m_write_addr_pkt);
        num_req++;
    end while (num_req < k_num_write_req);

endtask : body

endclass : axi_master_writeback_seq



<% } %>

<% if(obj.Block === 'aiu' || obj.Block === 'io_aiu') { %>
////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Snoop Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_master_snoop_seq extends uvm_sequence #(axi_snp_seq_item);

    `uvm_object_param_utils(axi_master_snoop_seq)
    
    axi_snoop_addr_seq            m_snoop_addr_seq;
    axi_read_addr_chnl_sequencer  m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer  m_read_data_chnl_seqr;
    axi_snoop_addr_chnl_sequencer m_snoop_addr_chnl_seqr;
    axi_snoop_data_chnl_sequencer m_snoop_data_chnl_seqr;
    axi_snoop_resp_chnl_sequencer m_snoop_resp_chnl_seqr;
    axi_snp_seq_item              m_seq_item;

    ace_cache_model               m_ace_cache_model;
    //int prob_ace_snp_resp_error = 0; comment out this double declaration to fix questa cfg9 failure

    // Knobs
    // int                           prob_ace_snp_resp_error = 0; 
    int                           prob_ace_snp_resp_wodata_error = 0; 
    static bit                    pwrmgt_power_down = 0;

    typedef struct {
        axi_crresp_t m_crresp;
        axi_snp_seq_item                        m_seq_item;
    } snp_rsp_t;

    typedef struct {
        axi_cddata_t m_cddata[];
        axi_snp_seq_item                        m_seq_item;
    } snp_dat_t;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_master_snoop_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    axi_snp_seq_item m_axi_snp_addr_q[$];
    snp_rsp_t        m_axi_snp_resp_q[$];
    snp_dat_t        m_axi_snp_data_q[$];
    bit              m_axi_dvm_sync_q[$];
    
    //`uvm_info(get_full_name(), "Starting master_snoop_seq", UVM_LOW)
    fork
        begin : collect_snoops
            m_snoop_addr_seq = axi_snoop_addr_seq::type_id::create("m_snoop_addr_seq"); 
            forever begin
                m_snoop_addr_seq.should_randomize = 0;
                if (pwrmgt_power_down == 1) begin
		    `uvm_info(get_full_name(), $sformatf("waiting pwrmgt_power_down==0"), UVM_LOW)
                    wait(pwrmgt_power_down == 0);
                end
                m_snoop_addr_seq.return_response(m_seq_item, m_snoop_addr_chnl_seqr);
                m_axi_snp_addr_q.push_back(m_seq_item);
            end
        end : collect_snoops
        begin : setup_snoop_response 
            axi_snp_seq_item                        m_seq_item;
            axi_crresp_t m_crresp;
            axi_xdata_t  m_cddata[];
            snp_rsp_t                               m_axi_snp_rsp;
            snp_dat_t                               m_axi_snp_dat;

            forever begin
                wait(m_axi_snp_addr_q.size() > 0);
                m_seq_item = m_axi_snp_addr_q.pop_front();
                m_ace_cache_model.give_snoop_resp(m_seq_item.m_snoop_addr_pkt.acaddr, m_seq_item.m_snoop_addr_pkt.acsnoop, m_crresp, m_cddata
                                            <%if(obj.wSecurityAttribute > 0){%>
                                                ,m_seq_item.m_snoop_addr_pkt.acprot[1]
                                            <%}%>);
                m_axi_snp_rsp.m_crresp   = m_crresp;
                m_axi_snp_rsp.m_seq_item = m_seq_item;
                m_axi_snp_resp_q.push_back(m_axi_snp_rsp);
                if (m_crresp[CCRRESPDATXFERBIT]) begin
                    m_axi_snp_dat.m_cddata   = m_cddata;
                    m_axi_snp_dat.m_seq_item = m_seq_item;
                    m_axi_snp_data_q.push_back(m_axi_snp_dat);
                end
            end
        end : setup_snoop_response
        begin : send_snoop_response 
            axi_snoop_resp_seq                                  m_snoop_resp_seq;
            snp_rsp_t                                           m_snp_rsp_item;
            bit                                                 need_to_send_dvmcmpl;
            bit                                                 is_single_part_dvm_snp;
            bit                                                 is_dvm_sync_snp, is_dvm_hint_snp;
            bit                                                 is_last_part_dvm_snp = 1;
            ace_command_types_enum_t snptype;
            axi_crresp_t                                        crresp_1st_part; //AMBA PROTOCOL: For two-part DVM messages, the response to each transaction must be the same.
           


            forever begin
                wait(m_axi_snp_resp_q.size() > 0);
                m_snoop_resp_seq                           = axi_snoop_resp_seq::type_id::create("m_snoop_resp_seq");
                m_snp_rsp_item                             = m_axi_snp_resp_q.pop_front();
                snptype                                    = m_ace_cache_model.convert_snp_type(m_snp_rsp_item.m_seq_item.m_snoop_addr_pkt.acsnoop);

                m_snoop_resp_seq.should_randomize          = 1;
                m_snoop_resp_seq.m_constraint_snoop_resp   = 1;

                begin
                    if(snptype == DVMCMPL) begin
                        
                        need_to_send_dvmcmpl = 0;
                        is_single_part_dvm_snp = 1;
                        is_dvm_sync_snp = 0;
                        is_last_part_dvm_snp = 1;

                    end
                    else if (snptype == DVMMSG &&
                    m_snp_rsp_item.m_seq_item.m_snoop_addr_pkt.acaddr[0] == 1 &&
                    is_last_part_dvm_snp == 1) begin: _1st_of_multi_part_snp_
                        
                        is_single_part_dvm_snp = 0;
                        is_last_part_dvm_snp = 0;
                        
                        if (m_snp_rsp_item.m_seq_item.m_snoop_addr_pkt.acaddr[15] == 1)
                            need_to_send_dvmcmpl = 1;
                        else
                            need_to_send_dvmcmpl = 0;

                        if (m_snp_rsp_item.m_seq_item.m_snoop_addr_pkt.acaddr[14:12] == 'b100) begin 
                            is_dvm_sync_snp = 1;
                            is_dvm_hint_snp = 0;
                        end else if (m_snp_rsp_item.m_seq_item.m_snoop_addr_pkt.acaddr[14:12] == 'b110) begin 
                            is_dvm_sync_snp = 0;
                            is_dvm_hint_snp = 1;
                        end else begin 
                            is_dvm_sync_snp = 0;
                            is_dvm_hint_snp = 0;
                        end

                    end: _1st_of_multi_part_snp_
                    else if(snptype == DVMMSG &&
                            is_last_part_dvm_snp == 0) begin: _2nd_of_multi_part_snp_
                        
                        is_single_part_dvm_snp = 0;
                        is_last_part_dvm_snp = 1;

                    end: _2nd_of_multi_part_snp_
                    else if (snptype == DVMMSG &&
                            m_snp_rsp_item.m_seq_item.m_snoop_addr_pkt.acaddr[0] == 0  &&
                            is_last_part_dvm_snp == 1) begin: _single_part_snp_
                        
                        is_single_part_dvm_snp = 1;
                        is_last_part_dvm_snp = 1;

                        if (m_snp_rsp_item.m_seq_item.m_snoop_addr_pkt.acaddr[15] == 1)
                            need_to_send_dvmcmpl = 1;
                        else
                            need_to_send_dvmcmpl = 0;

                        if (m_snp_rsp_item.m_seq_item.m_snoop_addr_pkt.acaddr[14:12] == 'b100) begin 
                            is_dvm_sync_snp = 1;
                            is_dvm_hint_snp = 0;
                        end else if (m_snp_rsp_item.m_seq_item.m_snoop_addr_pkt.acaddr[14:12] == 'b110) begin 
                            is_dvm_sync_snp = 0;
                            is_dvm_hint_snp = 1;
                        end else begin 
                            is_dvm_sync_snp = 0;
                            is_dvm_hint_snp = 0;
                        end
                    end: _single_part_snp_
                    else begin
                        if ((snptype inside {DVMMSG, DVMCMPL}) == 1) begin  
                            `uvm_error("AXI SEQ DBG", $psprintf("thread:send_snoop_response all nonDVM snoops should get here, but we see a dvm_snp: m_snp_rsp_item.m_seq_item:%0s", m_snp_rsp_item.m_seq_item.convert2string()));
                        end else begin 
                            is_dvm_sync_snp = 0;
                            is_dvm_hint_snp = 0;
                        end
                        //HS TODO:remove below lines after stable regressions
                        if(is_last_part_dvm_snp == 0) begin
                            `uvm_error("AXI SEQ DBG", $psprintf("thread:send_snoop_response not a dvm_snp but why would is_last_part_dvm_snp=0 since all parts of DVM snoop should have been done? : m_snp_rsp_item.m_seq_item:%0s", m_snp_rsp_item.m_seq_item.convert2string()));
                            is_single_part_dvm_snp = 0;
                            is_last_part_dvm_snp = 1;
                        end
                    end
                    if ((snptype == DVMMSG) && (is_single_part_dvm_snp == 0)) begin 
                        if (is_last_part_dvm_snp == 0)
                            crresp_1st_part = m_snp_rsp_item.m_crresp; //save snpresp of 1st of multi-part
                        else if (is_last_part_dvm_snp == 1) 
                            m_snp_rsp_item.m_crresp = crresp_1st_part; //assign the same to the 2nd part of multi-part
                    end
                   
                    m_snoop_resp_seq.is_dvm_sync = is_dvm_sync_snp;

                    if ((snptype == DVMCMPL) || is_dvm_sync_snp || is_dvm_hint_snp) m_snp_rsp_item.m_crresp=0; // AMBA protocol : A component is not permitted to set CRRESP to 0b00010 in response to a DVM Sync or a DVM Complete or DVM Hint.
                    
                    m_snoop_resp_seq.m_ace_snoop_rsp_chnl_resp = m_snp_rsp_item.m_crresp; 
                    m_snoop_resp_seq.m_seq_item                = m_snp_rsp_item.m_seq_item;                     

                    //`uvm_info("AXI SEQ DBG", $psprintf("thread:send_snoop_response Sending CRRESP:%0s %0b", m_snp_rsp_item.m_seq_item.convert2string(), m_snp_rsp_item.m_crresp), UVM_LOW);
                    m_snoop_resp_seq.return_response(m_snp_rsp_item.m_seq_item, m_snoop_resp_chnl_seqr);
                    if (snptype == DVMCMPL) begin
                        axi_master_read_seq m_read_seq = axi_master_read_seq::type_id::create("m_read_seq");
                        m_read_seq.isDVMSyncOutStanding = 0;
                    end
                    if (snptype !== DVMMSG &&
                        snptype !== DVMCMPL
                    ) begin
                        m_ace_cache_model.modify_cache_line_for_snoop(m_snp_rsp_item.m_seq_item.m_snoop_addr_pkt.acaddr
                        <%if(obj.wSecurityAttribute > 0){%>
                            ,m_snp_rsp_item.m_seq_item.m_snoop_addr_pkt.acprot[1]
                        <%}%>);
                    end
                    //`uvm_info("AXI SEQ DBG", $psprintf("thread:send_snoop_response need_to_send_dvmcmpl:%0b is_single_part_dvm_snp:%0b is_dvm_sync_snp:%0b is_dvm_hint_snp:%0b is_last_part_dvm_snp:%0b", need_to_send_dvmcmpl, is_single_part_dvm_snp, is_dvm_sync_snp, is_dvm_hint_snp, is_last_part_dvm_snp), UVM_LOW);
                    //`uvm_info("AXI SEQ DBG", $psprintf("thread:send_snoop_response m_snp_rsp_item.m_seq_item:%0s", m_snp_rsp_item.m_seq_item.convert2string()), UVM_LOW);
                    // Checking to see if a DVM Sync has been received
                    if (snptype == DVMMSG &&
                        need_to_send_dvmcmpl == 1 &&
                        is_last_part_dvm_snp ==1 &&
                        is_dvm_sync_snp == 1
                    ) begin
                        m_axi_dvm_sync_q.push_back('b1);
                        need_to_send_dvmcmpl = 0;
                        //`uvm_info("AXI SEQ DBG", $psprintf("thread:send_snoop_response Pushing into axi_dvm_sync_q.size:%0d count:%0d", m_axi_dvm_sync_q.size(), count), UVM_LOW);
                    end
                end
            end //forever
        end : send_snoop_response 
        begin : send_snoop_data
            axi_snoop_data_seq m_snoop_data_seq;
            snp_dat_t          m_snp_dat_item;
            axi_snp_seq_item   m_tmp_seq_item1;

            forever begin
                wait(m_axi_snp_data_q.size() > 0);
                m_snoop_data_seq                            = axi_snoop_data_seq::type_id::create("m_snoop_data_seq");
                m_tmp_seq_item1                             = axi_snp_seq_item::type_id::create("m_tmp_seq_item1");
                m_snoop_data_seq.m_seq_item                 = axi_snp_seq_item::type_id::create("m_seq_item");
                m_snp_dat_item                              = m_axi_snp_data_q.pop_front();
                m_tmp_seq_item1.do_copy(m_snp_dat_item.m_seq_item);
                m_snoop_data_seq.should_randomize           = 1;
                m_snoop_data_seq.m_constraint_snoop_data    = 1;
                m_snoop_data_seq.m_ace_snoop_data_chnl_data = m_snp_dat_item.m_cddata;
                m_snoop_data_seq.m_seq_item.m_snoop_data_pkt.cdpoison = new [m_snoop_data_seq.m_ace_snoop_data_chnl_data.size()];
                m_snoop_data_seq.m_seq_item.m_snoop_data_pkt.cddatachk = new [m_snoop_data_seq.m_ace_snoop_data_chnl_data.size()];
                m_snoop_data_seq.m_seq_item                 = m_tmp_seq_item1;
                m_snoop_data_seq.return_response(m_tmp_seq_item1, m_snoop_data_chnl_seqr);
            end
        end : send_snoop_data
        begin : send_read_dvm_cmpl
            axi_master_read_seq m_read_seq;

            forever begin
                wait(m_axi_dvm_sync_q.size() > 0);
                m_axi_dvm_sync_q.pop_front();
                //`uvm_info("AXI SEQ DBG", $psprintf("thread:send_read_dvm_cmpl Popped from m_axi_dvm_sync_q"), UVM_LOW);
                m_read_seq                   = axi_master_read_seq::type_id::create("m_read_seq");
                m_read_seq.m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
                m_read_seq.m_read_data_chnl_seqr = m_read_data_chnl_seqr;
                m_read_seq.m_ace_cache_model = m_ace_cache_model; 
                m_read_seq.sendDVMComplete   = 1;
                if ((m_read_seq.read_req_count >= m_read_seq.read_req_total_count) | (m_read_seq.pwrmgt_power_down == 1)) begin
                    m_read_seq.start(null);
                end
                wait (m_read_seq.sendDVMComplete == 0);
            end
        end : send_read_dvm_cmpl
    join
endtask : body

endclass : axi_master_snoop_seq

<% } %>

////////////////////////////////////////////////////////////////////////////////
//
// AXI Exclusive Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_master_exclusive_seq extends axi_master_read_base_seq;

    `uvm_object_param_utils(axi_master_exclusive_seq)

    //Read Channel properties
    axi_read_addr_seq            m_read_addr_seq;
    axi_read_data_seq            m_read_data_seq;
    axi_read_addr_chnl_sequencer m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer m_read_data_chnl_seqr;
    axi_rd_seq_item              m_seq_item;
    
    //Inhouse Cache Model
    ace_cache_model              m_ace_cache_model;
    //Cacheline address
    axi_axaddr_t m_cacheline_addr;
<% if (obj.wSecurityAttribute > 0) { %>
    bit [<%=obj.wSecurityAttribute%>-1:0]   m_security;
<% } %>                                                
  
    //Exclusive time out plus-arg controlled
    int exclusive_timeout = 50;
    //Random Weights
    int wt_ace_rdcln;
    int wt_ace_rdshrd;

    function new(string name = "axi_master_exclusive_seq");
       super.new(name);
    endfunction: new

    task body();
        bit en_load  = 1;
        bit en_store = 1;
        bit flag = 0;
        int count = 0;

        //Get Exclusive address
        do begin
            int tmp_q[$];
            m_ace_cache_model.give_addr_for_exclusive_req(m_cacheline_addr);
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                m_security = $urandom();
                if ($test$plusargs("prot_rand_disable")) begin
                    m_security = '0;
                end
            <% } %>                                                
            tmp_q = {};
            tmp_q = m_ace_cache_model.m_ort.find_first_index with (item.m_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)] == m_cacheline_addr[WAXADDR-1:$clog2(SYS_nSysCacheline)]);
            if (tmp_q.size == 0) begin
                flag = 1;
            end 
            count++;
            if (count > 50 && !flag) begin
                uvm_report_error("ACE BFM EXCL SEQ AIU <%=this_aiu_id%>", $sformatf("TB Error: Infinite loop possibility in exclusive seq do-while loop"), UVM_NONE);
            end
        end while (!flag);
        
        if(exclusive_addr_state(m_cacheline_addr) == ACE_IX) begin

            //Drive both Exclusive Load, Store sequences
            `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Initiating for Exclusive Load, Store sequences for cachelines %0h, Initial State: ACE_IX",
                                 <%=this_aiu_id%>, m_cacheline_addr), UVM_LOW);
            exclusive_seq(en_load, (!en_store), 0);
            //exclusive_seq((!en_load), en_store, 0);
        end
        else if(exclusive_addr_state(m_cacheline_addr) == ACE_SC) begin
            //Drive only Exclusive Store sequences
            `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Initiating for Exclusive Store sequences for cachelines %0h, Initial State: ACE_SC",
                                 <%=this_aiu_id%>, m_cacheline_addr), UVM_LOW);
            exclusive_seq((!en_load), en_store, 0);
        end
        else begin
            `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Unexpected ACE Cache State %s for cacheline %0h",
                                 <%=this_aiu_id%>, exclusive_addr_state(m_cacheline_addr), m_cacheline_addr), UVM_LOW);
        end

    `uvm_info("body", "Exiting...", UVM_LOW)
    endtask: body

    function aceState_t exclusive_addr_state(
                                                       axi_axaddr_t addr);
        ace_cache_line_model  m_tmp_line;
        aceState_t cur_state;

        //Check if Cacheline already exists in cache
        foreach(m_ace_cache_model.m_cache[idx]) begin
            if(addr == m_ace_cache_model.m_cache[idx].get_cacheline()) begin
                if(!$cast(cur_state, m_ace_cache_model.m_cache[idx].m_state))
                    `uvm_fatal("AXI_SEQ", "ACE State cast failed");
                return(cur_state);
            end
        end

        //If not present, then return invalid state
        return(ACE_IX);

    endfunction: exclusive_addr_state

    //////////////////////////////////////////////////////////////////////
    //Initiates Exclusive Load & Store sequences depending on 
    //arguments are passed
    //////////////////////////////////////////////////////////////////////
    
    task exclusive_seq(input bit en_load,
                       input bit en_store,
                       input int count);
        axi_bresp_enum_t m_rresp;
        int tmp_cnt;
        bit _en_load  = 1;
        bit _en_store = 1;
        axi_arid_t use_arid;
        string msg = "";

        msg = en_load ? "Load" : "Store";
        tmp_cnt = count;

        //Sanity check
        if((en_load && en_store)||(!(en_load || en_store))) 
            `uvm_fatal("AXI SEQ", $psprintf("AIU[%0d] Illegal arguments passed by caller, en_load: %b en_store: %b",
                                  <%=this_aiu_id%>, en_load, en_store));

        //Construct read address, data sequences
        m_read_addr_seq = axi_read_addr_seq::type_id::create("m_read_addr_seq"); 
        m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 

        //Set Address
        m_read_addr_seq.m_ace_rd_addr_chnl_addr = m_cacheline_addr;
<% if (obj.wSecurityAttribute > 0) { %>
        m_read_addr_seq.m_ace_rd_addr_chnl_security = m_security;
<% } %>                                                
        m_read_addr_seq.m_constraint_snoop = 1;
        m_read_addr_seq.m_constraint_addr  = 1;
        m_read_addr_seq.should_randomize   = 0;
        m_read_addr_seq.m_seq_item         = axi_rd_seq_item::type_id::create("m_seq_item");

        //Set Exclusive Load ace command
        if(en_load) begin
            randcase
                wt_ace_rdcln:  m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDCLN;
                wt_ace_rdshrd: m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDSHRD;
            endcase
        end
        else begin
            m_read_addr_seq.m_ace_rd_addr_chnl_snoop = CLNUNQ;
        end
 
        m_ace_cache_model.store_exclusive_req(m_read_addr_seq.m_ace_rd_addr_chnl_snoop,
                                              m_read_addr_seq.m_ace_rd_addr_chnl_addr
<% if (obj.wSecurityAttribute > 0) { %>                                             
        ,m_read_addr_seq.m_ace_rd_addr_chnl_security
<% } %>
        );

        get_axid(m_read_addr_seq.m_ace_rd_addr_chnl_snoop, use_arid);
        //Randomize Read Addr packet
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.constrained_addr = 1;
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid      == use_arid;
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr    == m_read_addr_seq.m_ace_rd_addr_chnl_addr;
            // For directed test case purposes
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.useFullCL  == use_full_cl;
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.use2FullCL == 0;
<% if (obj.wSecurityAttribute > 0) { %>
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1] == m_read_addr_seq.m_ace_rd_addr_chnl_security;
<% } %>                                                
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlock    == EXCLUSIVE;
        };

        `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Initiating Exclusive %s ACE command %s for cacheline %0h",
                             <%=this_aiu_id%>, msg, m_read_addr_seq.m_ace_rd_addr_chnl_snoop, m_read_addr_seq.m_ace_rd_addr_chnl_addr), UVM_LOW);

        //Drive Read address packet
        m_ace_cache_model.update_addr(m_read_addr_seq.m_ace_rd_addr_chnl_snoop, m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                ,.security(m_read_addr_seq.m_ace_rd_addr_chnl_security)
            <% } %>
        );

        m_read_addr_seq.return_response(m_seq_item, m_read_addr_chnl_seqr);

        //Blocking till previous request with same arid has a response has been received
        wait_till_arid_latest(m_read_addr_seq.m_seq_item.m_read_addr_pkt);

        //Wait for response
        m_read_data_seq.m_seq_item       = m_seq_item;
        m_read_data_seq.should_randomize = 0;
        m_read_data_seq.return_response(m_seq_item, m_read_data_chnl_seqr);

        delete_ott_entry(m_read_addr_seq.m_seq_item.m_read_addr_pkt);
        //Check Response status and update cache
<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %> 
        m_rresp = axi_bresp_enum_t'(m_seq_item.m_read_data_pkt.rresp_per_beat[0][CRRESP-1:0]);
         <% } else { %>
         m_rresp = axi_bresp_enum_t'(m_seq_item.m_read_data_pkt.rresp_per_beat[0][1:0]);
              <%}%>


        if(m_rresp == EXOKAY) begin
            axi_bresp_t m_tmp_bresp[];
            m_tmp_bresp = new[m_seq_item.m_read_data_pkt.rresp_per_beat.size()];
            foreach (m_tmp_bresp[i]) begin
                m_tmp_bresp[i] = m_seq_item.m_read_data_pkt.rresp_per_beat[i][1:0];
            end
            if(en_load) begin
                `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Exclusive Load is successfull for cacheline %0h count %0d",
                                     <%=this_aiu_id%>, m_read_addr_seq.m_ace_rd_addr_chnl_addr, tmp_cnt), UVM_LOW);

               m_ace_cache_model.modify_cache_line(m_seq_item.m_read_addr_pkt.araddr,
                                                    m_read_addr_seq.m_ace_rd_addr_chnl_snoop,
                                                    m_tmp_bresp, m_seq_item.m_read_data_pkt.rdata, , ,
                                                    <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %> 
                                                    m_seq_item.m_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT],
                                                    m_seq_item.m_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT],
                                                     <% } else { %>
                                                     , ,
                                                    <%}%>
                                                    
                                                    ((m_seq_item.m_read_addr_pkt.arlock == 1) ? (m_seq_item.m_read_data_pkt.rresp_per_beat[0][1:0] == EXOKAY) : 1),
                                                    .axdomain(m_seq_item.m_read_addr_pkt.ardomain)
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,.security(m_seq_item.m_read_addr_pkt.arprot[1])
<% } %>                                                
                                                );

                //initiate Exclusive store sequence
                exclusive_seq((!_en_load), _en_store, tmp_cnt);
            end else begin
                `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Exclusive Store is successfull for cacheline %0h count %0d",
                                         <%=this_aiu_id%>, m_read_addr_seq.m_ace_rd_addr_chnl_addr, tmp_cnt), UVM_LOW);
                m_ace_cache_model.modify_cache_line(m_seq_item.m_read_addr_pkt.araddr,
                                                    m_read_addr_seq.m_ace_rd_addr_chnl_snoop,
                                                    m_tmp_bresp, m_seq_item.m_read_data_pkt.rdata, , ,
                                                 <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %> 
                                                    m_seq_item.m_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT],
                                                    m_seq_item.m_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT],
                                                     <% } else { %>
                                                     , ,
                                                    <%}%>
                                                    ((m_seq_item.m_read_addr_pkt.arlock == 1) ? (m_seq_item.m_read_data_pkt.rresp_per_beat[0][1:0] == EXOKAY) : 1),
                                                    .axdomain(m_seq_item.m_read_addr_pkt.ardomain)
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,.security(m_seq_item.m_read_addr_pkt.arprot[1])
<% } %>                                                
                                                );
            end
        end
        else if(m_rresp == OKAY) begin
            if(tmp_cnt < exclusive_timeout) begin
                if(en_load) begin
                    `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Exclusive Load failed for cacheline %0h, retry-count %0d",
                                             <%=this_aiu_id%>, m_read_addr_seq.m_ace_rd_addr_chnl_addr, tmp_cnt), UVM_LOW);
                    tmp_cnt++;
                    exclusive_seq(_en_load, (!_en_store), tmp_cnt);
                end
                else begin
                    `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Exclusive Store failed for cacheline %0h, retry-count %0d",
                                             <%=this_aiu_id%>, m_read_addr_seq.m_ace_rd_addr_chnl_addr, tmp_cnt), UVM_LOW);
                    tmp_cnt++;

                    if(exclusive_addr_state(m_cacheline_addr) == ACE_IX) begin
                        `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Exclusive Load is successfull for cacheline %0h count %0d",
                        <%=this_aiu_id%>, m_read_addr_seq.m_ace_rd_addr_chnl_addr, tmp_cnt), UVM_LOW);

                        exclusive_seq(_en_load, (!_en_store), tmp_cnt);
                    end else  begin
                        exclusive_seq((!_en_load), _en_store, tmp_cnt);
                    end
                end
            end
            else begin
                `uvm_error("AXI SEQ", $psprintf("AIU[%0d] Following Exclusive %s transaction timed out: cacheline %0h",
                                       <%=this_aiu_id%>, msg, m_read_addr_seq.m_ace_rd_addr_chnl_addr));
            end
        end
    endtask: exclusive_seq

endclass: axi_master_exclusive_seq

<% } %>

////////////////////////////////////////////////////////////////////////////////
//
// AXI Slave Read Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_slave_read_seq extends uvm_sequence #(axi_rd_seq_item);

    `uvm_object_param_utils(axi_slave_read_seq)
    
    axi_read_addr_seq            m_read_addr_seq;
    axi_read_addr_chnl_sequencer m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer m_read_data_chnl_seqr;
    axi_rd_seq_item              m_seq_item;

    axi_memory_model             m_memory_model;

    //Control Knobs
    int                          prob_ace_rd_resp_error = 0;


//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_slave_read_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    m_read_addr_seq            = axi_read_addr_seq::type_id::create("m_read_addr_seq");
    m_read_addr_seq.m_seq_item = axi_rd_seq_item::type_id::create("m_seq_item");
    forever begin
        m_read_addr_seq.should_randomize = 0;
        m_read_addr_seq.return_response(m_seq_item, m_read_addr_chnl_seqr);
        fork
            begin
                axi_read_data_seq m_read_data_seq;
                axi_rd_seq_item   m_tmp_seq_item;
                m_tmp_seq_item = axi_rd_seq_item::type_id::create("m_tmp_seq_item");
                m_tmp_seq_item.do_copy(m_seq_item);
                m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 
                m_read_data_seq.prob_ace_rd_resp_error = this.prob_ace_rd_resp_error;
                `uvm_info("AXI SEQ", $psprintf("prob_ace_rd_resp_error = %0d", prob_ace_rd_resp_error), UVM_HIGH)

                m_memory_model.read_data(
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        {m_tmp_seq_item.m_read_addr_pkt.arprot[1], m_tmp_seq_item.m_read_addr_pkt.araddr},
                    <% } else { %>
                        m_tmp_seq_item.m_read_addr_pkt.araddr, 
                    <% } %>
                m_tmp_seq_item.m_read_addr_pkt.arlen, m_tmp_seq_item.m_read_addr_pkt.arsize, m_tmp_seq_item.m_read_data_pkt.rdata, m_tmp_seq_item.m_read_addr_pkt.arburst);

                m_tmp_seq_item.m_read_data_pkt.rresp_per_beat = new[m_tmp_seq_item.m_read_addr_pkt.arlen + 1];
                foreach (m_tmp_seq_item.m_read_data_pkt.rresp_per_beat[i]) begin
                    if(m_tmp_seq_item.m_read_addr_pkt.arlock)begin
                        m_tmp_seq_item.m_read_data_pkt.rresp_per_beat[i][1:0] = 1; // EXOKAY:1
                    end
                    if ($urandom_range(0,100) < prob_ace_rd_resp_error) begin
                        `uvm_info("AXI SEQ", "Setting Read Resp Error", UVM_MEDIUM)
                        m_tmp_seq_item.m_read_data_pkt.rresp_per_beat[i][1:0] = $urandom_range(2,3); // SLVERR:2 DECERR:3
                    end
                end
                m_read_data_seq.m_seq_item = m_tmp_seq_item;
                m_read_data_seq.should_randomize  = 0;
                m_read_data_seq.return_response(m_tmp_seq_item, m_read_data_chnl_seqr);
            end
        join_none
    end 

endtask : body

endclass : axi_slave_read_seq

////////////////////////////////////////////////////////////////////////////////
//
// AXI Slave Write Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_slave_write_seq extends uvm_sequence #(axi_rd_seq_item);

    `uvm_object_param_utils(axi_slave_write_seq)
    
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;


    axi_memory_model              m_memory_model;
    
    //Control Knobs
    int                           prob_ace_wr_resp_error = 0;


//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_slave_write_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    semaphore s_slave_write_addr_capture = new(1);
    semaphore s_slave_write_data_capture = new(1);
    forever begin
        fork 
            event e_req_done;
            begin
                axi_write_addr_seq m_write_addr_seq;
                axi_write_data_seq m_write_data_seq;
                axi_write_resp_seq m_write_resp_seq;
                axi_wr_seq_item    m_seq_item0;
                axi_wr_seq_item    m_seq_item1;
                bit                flag = 0;
                m_write_addr_seq                  = axi_write_addr_seq::type_id::create("m_write_addr_seq");
                m_write_data_seq                  = axi_write_data_seq::type_id::create("m_write_data_seq");
                m_write_addr_seq.m_seq_item       = axi_wr_seq_item::type_id::create("m_seq_item");
                m_write_data_seq.m_seq_item       = axi_wr_seq_item::type_id::create("m_seq_item");
                m_write_addr_seq.should_randomize = 0;
                m_write_data_seq.should_randomize = 0;
                m_write_addr_seq.isSlave = 1;
                m_write_data_seq.isSlave = 1;
                fork 
                    begin
                        s_slave_write_addr_capture.get();
                        m_write_addr_seq.return_response(m_seq_item0, m_write_addr_chnl_seqr);
                        if (!flag) begin
                            ->e_req_done;
                            flag = 1;
                        end
                        s_slave_write_addr_capture.put();
                    end
                    begin
                        s_slave_write_data_capture.get();
                        m_write_data_seq.return_response(m_seq_item1, m_write_data_chnl_seqr);
                        if (!flag) begin
                            ->e_req_done;
                            flag = 1;
                        end
                        s_slave_write_data_capture.put();
                    end
                join
                m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq"); 
                m_write_resp_seq.prob_ace_wr_resp_error = this.prob_ace_wr_resp_error;
                m_memory_model.write_data(
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        {m_seq_item0.m_write_addr_pkt.awprot[1], m_seq_item0.m_write_addr_pkt.awaddr},
                    <% } else { %>
                        m_seq_item0.m_write_addr_pkt.awaddr, 
                    <% } %>
                m_seq_item0.m_write_addr_pkt.awlen, m_seq_item0.m_write_addr_pkt.awsize, m_seq_item0.m_write_addr_pkt.awburst, m_seq_item1.m_write_data_pkt.wdata, m_seq_item1.m_write_data_pkt.wstrb);

                m_write_resp_seq.should_randomize = 1;
                m_write_resp_seq.m_seq_item = m_seq_item0;
                m_write_resp_seq.return_response(m_seq_item0, m_write_resp_chnl_seqr);
            end 
            begin
                @e_req_done;
            end
        join_any
    end
endtask : body

endclass : axi_slave_write_seq

<% if((obj.Block === 'io_aiu') || (obj.Block === 'aiu') || (obj.Block === 'mem' && obj.is_master === 1)) { %>
////////////////////////////////////////////////////////////////////////////////
//
//
//
//  Random pipelined sequences
//
//
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Pipelined Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_master_pipelined_seq extends axi_master_pipeline_base_seq;

    <% if (obj.testBench == "fsys") { %>
      `uvm_object_utils(ioaiu<%=my_ioaiu_id%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq)
    <% }else {%>
      `uvm_object_param_utils(axi_master_pipelined_seq)
    <% } %>

    addr_trans_mgr m_addr_mgr;
    uvm_event ev_wait_completion_of_seq_aiu<%=obj.Id%> = uvm_event_pool::get_global("ev_wait_completion_of_seq_aiu<%=obj.Id%>");

	time m_stop_txn_issue_time = 0;
    // iRead and write sequences
    axi_master_read_seq         m_read_seq[];
    axi_master_write_noncoh_seq m_noncoh_write_seq[];
    <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
        axi_master_write_coh_seq    m_coh_write_seq;
        axi_master_writeback_seq    m_wb_seq[];
        axi_master_exclusive_seq    m_exclusive_seq;
    <% } %>
    
    // Read and write sequencers
    axi_read_addr_chnl_sequencer  m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer  m_read_data_chnl_seqr;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;

    ace_cache_model               m_ace_cache_model;
    
    <% if ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %>
         parameter IOC_NUM_WAYS = <%=obj.AiuInfo[obj.Id].ccpParams.nWays%>;
    <% } %>

    bit                                       use_addr_from_test = 0;
    bit                                       use_axcache_from_test = 0;
    axi_axaddr_t   m_ace_addr_from_test;
    <% if (obj.wSecurityAttribute > 0) { %>                                             
        bit [<%=obj.wSecurityAttribute%>-1:0] m_ace_security_from_test;
    <% } %>                                                
    int use_incr_addr_from_test = 0;
    bit [<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length%> -1:0]   ccp_setindex;

    //newperf_test pcie
	int nbr_alt_coh_noncoh_tx[0:1]; // [0] nbr coh tx then alternate to noncoh  [1] nbr noncoh tx then alternate to coh 
	int nbr_alt_noncoh_only_tx[0:1]; // [0] nbr noncoh mem region0 tx then [1] nbr noncoh mem region1 tx
	//end pcie

    // Knobs added to axi_master_pipeline_base_seq
    
	//newperf test
	int perf_coh_txn_size;    
    int perf_noncoh_txn_size[0:1];    
	int duty_cycle; // newperf test : "duty_cycle" case ex: dutyc_cycle=6 with 60% write & 40% read => W W W W R R 
    int en_force_axid;
	int ioaiu_force_coh_axid;
	int ioaiu_force_noncoh_axid[0:1];

	string seq_name = "axi_master_pipelined_seq";
	string dbg_str	= $sformatf("%0s_<%=obj.strRtlNamePrefix%>", seq_name);

    // Bit to set if we want to not perform any writes during the read portion of the test and then
    // writeback everything at the end of the read portion of the test
    bit late_updates                           = 0;
    // Following bit is used only for wb throughput test
    bit wb_throughput_test                     = 0; 
    
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_stop_txns_issue = ev_pool.get("ev_stop_txns_issue");
    uvm_event ev_seq_done;
    <% if(obj.testBench == "fsys" || obj.testBench == "emu") { %>
    uvm_event ev_sim_done;
    bit wait_ev_sim_done=1'b1;
    bit trigger_ev_steady_bw=1'b1;
    <% } %>
    // newperf test event
    uvm_event ev_wr_req_done; 
    uvm_event ev_rd_req_done; 
    int core_id=0;
    `ifdef USE_STL_TRACE
    bit [63:0] stl_write_q[$],stl_read_q[$];
    int stl_idlecnt_q[$],stl_rsp_q[$];
    int inject_idle_cycles;
    int wr_txn_cnt,rd_txn_cnt;
    axi_rd_seq_item   m_seq_item0;
    axi_wr_seq_item   m_seq_item1;
    axi_wr_seq_item   m_seq_item2;
    axi_read_addr_seq   m_read_addr_seq;
    axi_rd_seq_item     m_seq_item;
    axi_write_addr_seq            m_write_addr_seq;
    axi_write_data_seq            m_write_data_seq;
    axi_write_resp_seq            m_write_resp_seq;

    `endif
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string _name = "axi_master_pipelined_seq");
    super.new(_name);
    wb_throughput_test = $test$plusargs("wb_bw_test");
    user_qos = 0;
    m_addr_mgr = addr_trans_mgr::get_instance();
endfunction : new

function set_seq_name(string s);
  seq_name = s;
endfunction : set_seq_name
//------------------------------------------------------------------------------
// Pre-Body Task
//------------------------------------------------------------------------------
virtual task pre_body();
    super.pre_body();

  endtask:pre_body;

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    //newperf pci alternate coh & noncoh or noncoh mem region0 & noncoh mem region1
	int nbr_tx_coh;
	int nbr_tx_noncoh[0:1];
	//end alternate

    int nbr_write_in_duty_cycle; // RF
    int nbr_read_in_duty_cycle; // RF
    int nbr_loop_for_duty_cycle; // RF
    int wt_axlen_256B;
    int iter_aiu_qos;
    int use_incremental_qos;
    int qos_bound;
    int qos_group_size;
      // newperf test by default 50% when RD/WR test 
    if($test$plusargs("ioaiu<%=my_ioaiu_id%>_noncoherent_test")) begin // RF
        nbr_write_in_duty_cycle = duty_cycle*wt_ace_wrnosnp/100; 
        nbr_read_in_duty_cycle = duty_cycle*wt_ace_rdnosnp/100;
    end else begin
        nbr_write_in_duty_cycle = duty_cycle*wt_ace_wrunq/100; 
        nbr_read_in_duty_cycle = duty_cycle*wt_ace_rdonce/100;
    end
    nbr_loop_for_duty_cycle = (k_num_read_req+k_num_write_req)/duty_cycle;

    if(!$value$plusargs("wt_axlen_256B=%d",wt_axlen_256B)) begin
       wt_axlen_256B = 0; 
    end
    
    if(!$value$plusargs("<%=obj.BlockId%>_qos_bound=%d", qos_bound))
        qos_bound = 15;
    if(!$value$plusargs("<%=obj.BlockId%>_qos_group_size=%d", qos_group_size))
        qos_group_size = 1;

    // end newperf test

    m_read_seq                      = new[k_num_read_req];
    m_noncoh_write_seq              = new[k_num_write_req];
    late_updates                    = late_updates & no_updates;

    m_ace_cache_model.core_id=core_id;
    //`uvm_info(get_full_name(), $sformatf("core_id=%0d", core_id), UVM_NONE)
<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
    m_ace_cache_model.wt_ace_wrcln  = wt_ace_wrcln;
    m_ace_cache_model.wt_ace_wrbk   = wt_ace_wrbk;
    m_ace_cache_model.wt_ace_evct   = wt_ace_evct;
    m_ace_cache_model.wt_ace_wrevct = wt_ace_wrevct;
    m_wb_seq                        = new[k_num_write_req];
<% } %>      

    `uvm_info(dbg_str, $sformatf("k_num_read_req:%0d k_num_write_req:%0d", k_num_read_req, k_num_write_req), UVM_NONE)
    `uvm_info(dbg_str, $sformatf("MASTER ALLOC RD TXN WTS- mkunq:%0d rdunq:%0d rdcln:%0d rdshrd:%0d rdnotshrddty:%0d", wt_ace_mkunq, wt_ace_rdunq, wt_ace_rdcln, wt_ace_rdshrd, wt_ace_rdnotshrddty), UVM_LOW)
    `uvm_info(dbg_str, $sformatf("CLEAN TXN WTS- clnunq:%0d clnshrd:%0d clninv:%0d", wt_ace_clnunq, wt_ace_clnshrd, wt_ace_clninvl), UVM_LOW)
    `uvm_info(dbg_str, $sformatf("MAKE TXN WTS- mkinv:%0d", wt_ace_mkinvl), UVM_LOW)
    `uvm_info(dbg_str, $sformatf("ATOMIC TXN WTS- atmld:%0d atmstr:%0d atmcmp:%0d atmswap:%0d", wt_ace_atm_ld, wt_ace_atm_str, wt_ace_atm_comp, wt_ace_atm_swap), UVM_LOW)
    `uvm_info(dbg_str, $sformatf("COPYBACK TXN WTS- wrbk:%0d wrcln:%0d wrevct:%0d evct:%0d", wt_ace_wrbk, wt_ace_wrcln, wt_ace_wrevct, wt_ace_evct), UVM_LOW)
    `uvm_info(dbg_str, $sformatf("COH TXN WTS- rdonce:%0d wrunq:%0d wrlnunq:%0d", wt_ace_rdonce, wt_ace_wrunq, wt_ace_wrlnunq), UVM_LOW)
    `uvm_info(dbg_str, $sformatf("NONCOH TXN WTS- rdnosnp:%0d wrnosnp:%0d", wt_ace_rdnosnp, wt_ace_wrnosnp), UVM_LOW)

    `uvm_info("IOAIU<%=my_ioaiu_id%> AXI SEQ", $sformatf("Creating ev_seq_done with name %s", seq_name), UVM_NONE)
    ev_seq_done = ev_pool.get(seq_name);
    <% if(obj.testBench == "fsys"|| obj.testBench == "emu") { %>
    ev_sim_done = ev_pool.get("sim_done");
	<% } %>
    ev_wr_req_done = ev_pool.get("ioaiu<%=my_ioaiu_id%>_wr_req_done"); //newperf test 
    ev_rd_req_done = ev_pool.get("ioaiu<%=my_ioaiu_id%>_rd_req_done"); //newperf test
    wt_not_illegal_op_addr = 100 - wt_illegal_op_addr;

    iter_aiu_qos = aiu_qos;
    `ifdef USE_STL_TRACE
    axi_stl_format_read( stl_idlecnt_q,stl_rsp_q,stl_write_q,stl_read_q,wr_txn_cnt,rd_txn_cnt);
    `uvm_info("STL::AXI",$psprintf("STL::AXI Collecting stl read transactions=%0p write transactions=%0p stl_idlecnt_q=%0p stl_rsp_q=%0p",stl_read_q,stl_write_q,stl_idlecnt_q,stl_rsp_q),UVM_NONE)
    `uvm_info(dbg_str, $sformatf("STL::k_num_read_req:%0d k_num_write_req:%0d", rd_txn_cnt, wr_txn_cnt), UVM_NONE)
    `endif
    for (int i = 0; i < k_num_read_req; i++) begin:for_k_num_read_req

			// newperf test case pcie alternate
			int window_coh;
			int window_noncoh[0:1]; 
			if (nbr_alt_noncoh_only_tx[0]==0 && nbr_tx_noncoh[0] == nbr_alt_coh_noncoh_tx[1]  && nbr_tx_coh == nbr_alt_coh_noncoh_tx[0] ) begin
                nbr_tx_coh=0;
				nbr_tx_noncoh[0]=0;
			end
			if ( nbr_alt_coh_noncoh_tx[0]==0  && nbr_tx_noncoh[0] == nbr_alt_noncoh_only_tx[0]  && nbr_tx_noncoh[1] == nbr_alt_noncoh_only_tx[1] ) begin
				nbr_tx_noncoh='{0,0};
			end
			window_coh = (nbr_tx_coh < nbr_alt_coh_noncoh_tx[0]);
			window_noncoh[0] = ((nbr_tx_noncoh[0] < nbr_alt_coh_noncoh_tx[1])  && (nbr_tx_coh == nbr_alt_coh_noncoh_tx[0])) || (nbr_tx_noncoh[0] < nbr_alt_noncoh_only_tx[0]) ; 
			window_noncoh[1] = (nbr_tx_noncoh[1] < nbr_alt_noncoh_only_tx[1])  && (nbr_tx_noncoh[0] == nbr_alt_noncoh_only_tx[0]); 
            if (window_coh) begin	
				nbr_tx_coh++;
			end 
			if (window_noncoh[0]) begin
			   nbr_tx_noncoh[0]++;		
			end
		    if (window_noncoh[1]) begin
			   nbr_tx_noncoh[1]++;		
			end

			// end newperf test case pcie alternate
				
	randcase
          wt_not_illegal_op_addr : begin
                m_read_seq[i]                       = axi_master_read_seq::type_id::create($sformatf("c%0d_read_seq_%0d", core_id, i));
          end
          wt_illegal_op_addr : begin
                m_read_seq[i]                       = axi_master_read_seq_err::type_id::create($sformatf("read_seq_%0d", i));
          end
	endcase												   
        m_read_seq[i].core_id               = this.core_id;
        m_read_seq[i].id                    = i;
        m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        m_read_seq[i].k_num_read_req        = 1;
        m_read_seq[i].en_force_axid      = en_force_axid;

<%if((obj.testBench == "io_aiu" && obj.useCache) && (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) {%>
        if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", "sel_bank",sel_bank)) begin
            sel_bank = 0; 
        end
         if($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test") || $test$plusargs("address_error_test_data")) begin 
         m_read_seq[i].sel_bank               = sel_bank;
         end
<%}%>

<% if(obj.testBench =="io_aiu" && (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) { %>
if($test$plusargs("address_error_test_ott") || $test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test"))begin 
       if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", "sel_ott_bank",sel_ott_bank)) begin
            sel_ott_bank = 0; 
        end
	         m_read_seq[i].sel_ott_bank               = sel_ott_bank;
end
<%}%>

        if (nbr_alt_coh_noncoh_tx[0] ==0) begin // case no newperf pcie alternate
        m_read_seq[i].wt_ace_rdnosnp        = wt_ace_rdnosnp;
        m_read_seq[i].wt_ace_rdonce         = wt_ace_rdonce;
        m_read_seq[i].ioaiu_force_axid      = (window_noncoh[1])? ioaiu_force_noncoh_axid[1] : ioaiu_force_noncoh_axid[0]; 
	    end else begin:alternate_rd_case
		m_read_seq[i].wt_ace_rdnosnp        = (window_coh)? 0:  wt_ace_rdnosnp;
        m_read_seq[i].wt_ace_rdonce         = (window_noncoh[0])? 0 : wt_ace_rdonce;
        m_read_seq[i].ioaiu_force_axid     =  (window_coh)? ioaiu_force_coh_axid : ioaiu_force_noncoh_axid[0];
	    end:alternate_rd_case
        m_read_seq[i].wt_ace_rdunq          = wt_ace_rdunq;
        m_read_seq[i].wt_ace_rdshrd         = wt_ace_rdshrd;
        m_read_seq[i].wt_ace_rdcln          = wt_ace_rdcln;
        m_read_seq[i].wt_ace_rdnotshrddty   = wt_ace_rdnotshrddty;
        m_read_seq[i].wt_ace_clnunq         = wt_ace_clnunq;
        m_read_seq[i].wt_ace_mkunq          = wt_ace_mkunq;
        m_read_seq[i].wt_ace_dvm_msg        = wt_ace_dvm_msg;
        m_read_seq[i].wt_ace_dvm_sync       = wt_ace_dvm_sync;
        m_read_seq[i].wt_ace_clnshrd        = wt_ace_clnshrd;
        m_read_seq[i].wt_ace_clninvl        = wt_ace_clninvl;
        m_read_seq[i].wt_ace_mkinvl         = wt_ace_mkinvl;
        m_read_seq[i].wt_ace_rd_bar         = wt_ace_rd_bar;
        m_read_seq[i].wt_ace_rd_cln_invld   = wt_ace_rd_cln_invld;
        m_read_seq[i].wt_ace_rd_make_invld  = wt_ace_rd_make_invld;
        m_read_seq[i].wt_ace_clnshrd_pers   = wt_ace_clnshrd_pers;
        
        <% if(obj.fnNativeInterface != "AXI4" && obj.fnNativeInterface != "AXI5" && obj.orderedWriteObservation != true) { %>
        if($test$plusargs("dii_cmo_test")) begin
        m_read_seq[i].wt_ace_clninvl        = 100;
        m_read_seq[i].wt_ace_mkinvl         = 100;
        m_read_seq[i].wt_ace_clnshrd        = 100;
        <% if(obj.fnNativeInterface == 'ACELITE-E') { %>
        m_read_seq[i].wt_ace_clnshrd_pers   = 100;
        <%}%>
        end 
        <%}%>
        
        m_read_seq[i].read_req_total_count  = k_num_read_req;
        m_read_seq[i].k_access_boot_region  = k_access_boot_region;
        m_read_seq[i].use_axcache_from_test = (k_directed_test & k_directed_test_alloc) ? 1 : 0 ;
        m_read_seq[i].use_addr_from_test    = use_addr_from_test;
        m_read_seq[i].m_ace_rd_addr_from_test   = m_ace_addr_from_test + (i*use_incr_addr_from_test);
        m_read_seq[i].force_axlen_256B      = 0;
	   	m_read_seq[i].perf_coh_txn_size     = perf_coh_txn_size;
        m_read_seq[i].perf_noncoh_txn_size    = (window_noncoh[1])? perf_noncoh_txn_size[1] : perf_noncoh_txn_size[0];

        if(wt_axlen_256B != 0) begin // Depending ongoing Duty cycle, transfer size will be 256B or 64B
            m_read_seq[i].force_axlen_256B = (int'($floor(i/nbr_read_in_duty_cycle)) % duty_cycle) < (duty_cycle*wt_axlen_256B/100);
        end

    <% if (obj.wSecurityAttribute > 0) { %>                                             
	m_read_seq[i].m_ace_rd_security_from_test  = m_ace_security_from_test;
    <% } %>                                                        
        m_read_seq[i].user_qos              = user_qos;
        m_read_seq[i].aiu_qos               = iter_aiu_qos;
        if($test$plusargs("increment_qos")) begin
           if((i>0) && (i%qos_group_size)==0) begin
	      if(iter_aiu_qos == qos_bound) iter_aiu_qos = aiu_qos;
	      else iter_aiu_qos = iter_aiu_qos + 1;
	   end
	end
	
    end:for_k_num_read_req

    iter_aiu_qos = aiu_qos;
    for (int i = 0; i < k_num_write_req; i++) begin:for_k_num_write_req
        	// newperf test case pcie alternate
			int window_coh;
			int window_noncoh[0:1]; 
			if (nbr_alt_noncoh_only_tx[0]==0 && nbr_tx_noncoh[0] == nbr_alt_coh_noncoh_tx[1]  && nbr_tx_coh == nbr_alt_coh_noncoh_tx[0] ) begin
                nbr_tx_coh=0;
				nbr_tx_noncoh[0]=0;
			end
			if ( nbr_alt_coh_noncoh_tx[0]==0  && nbr_tx_noncoh[0] == nbr_alt_noncoh_only_tx[0]  && nbr_tx_noncoh[1] == nbr_alt_noncoh_only_tx[1] ) begin
				nbr_tx_noncoh='{0,0};
			end
			window_coh = (nbr_tx_coh < nbr_alt_coh_noncoh_tx[0]);
			window_noncoh[0] = ((nbr_tx_noncoh[0] < nbr_alt_coh_noncoh_tx[1])  && (nbr_tx_coh == nbr_alt_coh_noncoh_tx[0])) || (nbr_tx_noncoh[0] < nbr_alt_noncoh_only_tx[0]) ; 
			window_noncoh[1] = (nbr_tx_noncoh[1] < nbr_alt_noncoh_only_tx[1])  && (nbr_tx_noncoh[0] == nbr_alt_noncoh_only_tx[0]); 
            if (window_coh) begin	
				nbr_tx_coh++;
			end 
			if (window_noncoh[0]) begin
			   nbr_tx_noncoh[0]++;		
			end
		    if (window_noncoh[1]) begin
			   nbr_tx_noncoh[1]++;		
			end
			// end newperf test case pcie alternate
           if (wb_throughput_test) begin
            <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
                m_wb_seq[i]                        = axi_master_writeback_seq::type_id::create($sformatf("m_writeback_seq_%0d", i));
                m_wb_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
                m_wb_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
                m_wb_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
                m_wb_seq[i].k_num_write_req        = 1;
                m_wb_seq[i].core_id               = this.core_id;
            <% } %>      
        	end
        	else begin
	  		randcase
               wt_not_illegal_op_addr : begin
		   		m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("c%0d_noncoh_write_seq_%0d", core_id, i));
               end
               wt_illegal_op_addr : begin
		   m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq_err::type_id::create($sformatf("noncoh_write_seq_%0d", i));
               end
          endcase
//            m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_noncoh_write_seq_%0d", i));
            m_noncoh_write_seq[i].core_id               = this.core_id;
            m_noncoh_write_seq[i].id                    = i;
            m_noncoh_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
            m_noncoh_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
            m_noncoh_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
            m_noncoh_write_seq[i].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
            m_noncoh_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
            m_noncoh_write_seq[i].k_num_write_req        = 1;
            m_noncoh_write_seq[i].en_force_axid      = en_force_axid;
            if($test$plusargs("force_wb_wc_noncoh")) begin
                m_noncoh_write_seq[i].wt_ace_wrbk        = wt_ace_wrbk;
                m_noncoh_write_seq[i].wt_ace_wrcln       = wt_ace_wrcln;
            end
            if($test$plusargs("force_we_noncoh")) begin
                m_noncoh_write_seq[i].wt_ace_wrevct      = wt_ace_wrevct;
            end
            
 <%if((obj.testBench == "io_aiu" && obj.useCache) && (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) {%>
         if($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test") || $test$plusargs("address_error_test_data")) begin
            if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", "sel_bank",sel_bank)) begin
            sel_bank = 0; 
            end
               m_noncoh_write_seq[i].sel_bank               = sel_bank;
             end
<%}%>

<% if(obj.testBench =="io_aiu" && (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) { %>
if($test$plusargs("address_error_test_ott") || $test$plusargs("ccp_double_bit_direct_ott_error_test") || $test$plusargs("ccp_multi_blk_single_double_ott_direct_error_test") || $test$plusargs("ccp_multi_blk_double_ott_direct_error_test"))begin
            if (!uvm_config_db#(int)::get(null, "<%=obj.strRtlNamePrefix%>_env", "sel_ott_bank",sel_ott_bank)) begin
            sel_ott_bank = 0; 
            end
             m_noncoh_write_seq[i].sel_ott_bank               = sel_ott_bank;
end
<%}%>

        	if (nbr_alt_coh_noncoh_tx[0] ==0) begin // case no newperf pcie alternate
                m_noncoh_write_seq[i].wt_ace_wrnosnp         = wt_ace_wrnosnp;
                m_noncoh_write_seq[i].wt_ace_wrunq           = wt_ace_wrunq;
                m_noncoh_write_seq[i].ioaiu_force_axid      = (window_noncoh[1])? ioaiu_force_noncoh_axid[1] : ioaiu_force_noncoh_axid[0]; 
	    end else begin:alternate_wr_case
                m_noncoh_write_seq[i].wt_ace_wrnosnp         = (window_coh)? 0:wt_ace_wrnosnp;
                m_noncoh_write_seq[i].wt_ace_wrunq           = (window_noncoh[0])? 0 :wt_ace_wrunq;
                m_noncoh_write_seq[i].ioaiu_force_axid       = (window_coh)? ioaiu_force_coh_axid : ioaiu_force_noncoh_axid[0]; 
	    end:alternate_wr_case
            m_noncoh_write_seq[i].wt_ace_wrlnunq         = wt_ace_wrlnunq;
            m_noncoh_write_seq[i].wt_ace_wr_bar          = wt_ace_wr_bar;
            m_noncoh_write_seq[i].write_req_total_count  = k_num_write_req;
            m_noncoh_write_seq[i].wt_ace_atm_str         = wt_ace_atm_str;
            m_noncoh_write_seq[i].wt_ace_atm_ld          = wt_ace_atm_ld;
            m_noncoh_write_seq[i].wt_ace_atm_swap        = wt_ace_atm_swap;
            m_noncoh_write_seq[i].wt_ace_atm_comp        = wt_ace_atm_comp;
            m_noncoh_write_seq[i].wt_ace_ptl_stash       = wt_ace_ptl_stash;
            m_noncoh_write_seq[i].wt_ace_full_stash      = wt_ace_full_stash;
            m_noncoh_write_seq[i].wt_ace_shared_stash    = wt_ace_shared_stash;
            m_noncoh_write_seq[i].wt_ace_unq_stash       = wt_ace_unq_stash;
            m_noncoh_write_seq[i].wt_ace_stash_trans     = wt_ace_stash_trans;
            m_noncoh_write_seq[i].k_access_boot_region   = k_access_boot_region;
	    m_noncoh_write_seq[i].use_axcache_from_test  = (k_directed_test & k_directed_test_alloc) ? 1 : 0 ;
	    m_noncoh_write_seq[i].use_addr_from_test     = use_addr_from_test;
	    m_noncoh_write_seq[i].m_ace_wr_addr_from_test   = m_ace_addr_from_test + (i*use_incr_addr_from_test);
    <% if (obj.wSecurityAttribute > 0) { %>                                             
	    m_noncoh_write_seq[i].m_ace_wr_security_from_test  = m_ace_security_from_test;
    <% } %>                                                        
            m_noncoh_write_seq[i].user_qos               = user_qos;
            m_noncoh_write_seq[i].aiu_qos                = iter_aiu_qos;
            if($test$plusargs("increment_qos")) begin
                if((i>0) && (i%qos_group_size)==0) begin
	            if(iter_aiu_qos == qos_bound) iter_aiu_qos = aiu_qos;
	            else iter_aiu_qos = iter_aiu_qos + 1;
	        end
	    end

            m_noncoh_write_seq[i].force_axlen_256B       = 0; 
	   	    m_noncoh_write_seq[i].perf_coh_txn_size     = perf_coh_txn_size;
            m_noncoh_write_seq[i].perf_noncoh_txn_size    = (window_noncoh[1])? perf_noncoh_txn_size[1] : perf_noncoh_txn_size[0];
            if (wt_axlen_256B != 0) begin // Depending ongoing Duty cycle, transfer size will be 256B or 64B
                m_noncoh_write_seq[i].force_axlen_256B = (int'($floor(i/nbr_write_in_duty_cycle)) % duty_cycle) < (duty_cycle*wt_axlen_256B/100);
            end
    
        end
    end:for_k_num_write_req

    
    if($test$plusargs("ioaiu<%=my_ioaiu_id%>_rw_split")) begin    // RF section : For NxP PerfTest
        automatic int k = 0;

        if(duty_cycle > 0) begin    // case duty cycle 

            for(k=0;k<nbr_loop_for_duty_cycle;k++) begin: _loop_duty

                fork
                begin  : isolate_write_fork
                    begin
                        for (int i = 0; i < nbr_write_in_duty_cycle; i++) begin
                            fork
                                automatic int w=i+(k*nbr_write_in_duty_cycle);
                                begin
                                    m_noncoh_write_seq[w].start(null);
                                end
                            join_none
                        end // end loop for nbr_write_in_duty_cycle
                    end

                    begin // wait for all ev_wr_req_done
                        for (int j = 0; j < nbr_write_in_duty_cycle; j++) begin
                            ev_wr_req_done.wait_trigger();
                        end // end loop for nbr_write_in_duty_cycle
                    end
                //wait fork;
                end : isolate_write_fork
                join

                fork
                begin  : isolate_read_fork
                    begin
                        for (int i = 0; i < nbr_read_in_duty_cycle; i++) begin
                            fork
                                automatic int r=i+(k*nbr_read_in_duty_cycle);
                                begin
                                    m_read_seq[r].start(null);
                                end
                            join_none
                        end // end loop for nbr_read_in_duty_cycle
                    end

                    begin // wait for all ev_rd_req_done
                        for (int j = 0; j < nbr_read_in_duty_cycle; j++) begin
                            ev_rd_req_done.wait_trigger();
                        end // end loop for nbr_read_in_duty_cycle
                    end
                //wait fork;
                end : isolate_read_fork
                join
			end:_loop_duty
        end

		wait fork;
end else begin // end newperf test// else no newperf test duty cycle
    		for (int i = k_num_read_req-1; i >= 0; i--) begin // decrement because we can apply the right arbiration in the sequencer
        		fork
            		automatic int j = i;
            		begin
    					//`uvm_info(dbg_str, $sformatf("Forked m_read_seq with j:%0d", j), UVM_DEBUG)
                               `ifdef USE_STL_TRACE
                                 if($test$plusargs("normal_axi_txn")) m_read_seq[j].start(null);
                                 else begin
                                 if(stl_read_q.size()>0) drive_stl_rd_txn();
                                 else `uvm_info("STL::AXI_DRIVE",$psprintf("STL::AXI not driving traffic, empty read txn queue=%0d ",stl_read_q.size()),UVM_LOW)
                                 end
                               `else
                		m_read_seq[j].start(null);
                               `endif //USE_STL_TRACE
            		end
        		join_none
    		end

			for (int i =  k_num_write_req-1; i >=0; i--) begin
				fork
					automatic int j = i;
					begin
						if (wb_throughput_test) begin
							<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
								m_wb_seq[j].start(null);
							<% } %>      
						end
						else begin
                                                        `ifdef USE_STL_TRACE
                                                        if($test$plusargs("normal_axi_txn")) m_noncoh_write_seq[j].start(null);
                                                        else begin
                                                        if(stl_write_q.size()>0) drive_stl_wr_txn();
                                                        else `uvm_info("STL::AXI_DRIVE",$psprintf("STL::AXI not driving traffic, empty write txn queue=%0d ",stl_write_q.size()),UVM_LOW)
                                                        end
                                                        `else
								m_noncoh_write_seq[j].start(null);
                                                        `endif //USE_STL_TRACE
						end
					end
				join_none
			end

<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
			m_coh_write_seq                        = axi_master_write_coh_seq::type_id::create($sformatf("c%0d_coh_write_seq", core_id));
			m_coh_write_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
			m_coh_write_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
			m_coh_write_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
			m_coh_write_seq.m_ace_cache_model      = m_ace_cache_model;
                        m_coh_write_seq.core_id               = this.core_id;
                        //`uvm_info(get_full_name(), $sformatf("core_id=%0d", core_id), UVM_NONE)

			fork
				begin
					if(!no_updates)begin
						m_coh_write_seq.start(null);
				 	end
				end
			join_none
			
			fork
				begin
					for(int i = 0; i < k_num_exclusive_req; i++) begin
						m_exclusive_seq                       = axi_master_exclusive_seq::type_id::create($sformatf("c%0d_exclusive_seq_%0d", core_id, i));
						m_exclusive_seq.m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
						m_exclusive_seq.m_read_data_chnl_seqr = m_read_data_chnl_seqr;
						m_exclusive_seq.m_ace_cache_model     = m_ace_cache_model;
						m_exclusive_seq.wt_ace_rdshrd         = wt_ace_rdshrd;
						m_exclusive_seq.wt_ace_rdcln          = wt_ace_rdcln;
                                                m_exclusive_seq.core_id               = this.core_id;
                                                //`uvm_info(get_full_name(), $sformatf("core_id=%0d", core_id), UVM_NONE)

						m_exclusive_seq.start(null);
					end
				end
			join_none
<% } %> 
			wait fork;

end // end else no newperf test duty cycle

    `uvm_info("IOAIU<%=my_ioaiu_id%> AXI SEQ", $sformatf("AXI %s Sequence done", seq_name), UVM_NONE)
        `uvm_info("IOAIU<%=my_ioaiu_id%> AXI SEQ", $sformatf("AXI axi_master_pipelined_seq %s Sequence done", seq_name), UVM_MEDIUM)
    ev_seq_done.trigger(null);													   
    ev_wait_completion_of_seq_aiu<%=obj.Id%>.trigger();
<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
    fork
        begin
         if(late_updates)begin
             m_coh_write_seq.dont_ever_kill_seq = 1;
             m_coh_write_seq.start(null);
         end
        end
    join_none
<% } %>

<% if (obj.testBench == "fsys"|| obj.testBench == "emu") { %>
    `uvm_info("IOAIU<%=my_ioaiu_id%> AXI SEQ", "axi_master_pipelined_seq Waiting on simulation done", UVM_LOW)    
    if(wait_ev_sim_done) ev_sim_done.wait_trigger();
    `uvm_info("IOAIU<%=my_ioaiu_id%> AXI SEQ", "Received simulation done", UVM_NONE)
<% } %>
													   
endtask : body
`ifdef USE_STL_TRACE
task drive_stl_rd_txn();
    axi_axaddr_t araddr;
    axi_arid_t arid;
    axi_axburst_t arsize;
    axi_axqos_t arqos;
    axi_axlen_t arlen;
    bit[3:0] arcache;
    bit[1:0] arburst,beat;
    bit arlock,cache,buff,cache_rd_aloc,cache_wr_aloc;
    int idle_cnt,rsp_wait,arburst_size;
    bit first_txn,last_txn,en_user_delay;
    //`uvm_info("STL::AXI",$psprintf("STL::AXI Randomizing stl read transactions=%0p ",stl_read_q),UVM_NONE)
    m_read_addr_seq = axi_read_addr_seq::type_id::create("m_read_addr_seq"); 
    m_read_addr_seq.m_seq_item         = axi_rd_seq_item::type_id::create("m_seq_item");
    m_seq_item0         = axi_rd_seq_item::type_id::create("m_seq_item0");
    //stl rd txn
    first_txn=stl_read_q.pop_front();
    if(first_txn==1) idle_cnt=stl_read_q.pop_front(); 
    arid=stl_read_q.pop_front();
    arlen=stl_read_q.pop_front()-1;
    araddr=stl_read_q.pop_front();
    arburst=stl_read_q.pop_front();
    cache=stl_read_q.pop_front();
    buff=stl_read_q.pop_front();
    cache_rd_aloc=stl_read_q.pop_front();
    cache_wr_aloc=stl_read_q.pop_front();
    arburst_size=stl_read_q.pop_front();
    arlock=stl_read_q.pop_front();
    arqos=stl_read_q.pop_front();
    last_txn=stl_read_q.pop_front();
    arcache={cache,buff,cache_rd_aloc,cache_wr_aloc};  
    arsize=$clog2(arburst_size);
    if(first_txn==1) begin
    en_user_delay=1;
    `uvm_info("STL::AXI", $sformatf("STL::AXI<%=my_ioaiu_id%> rd-ch inserting idle cycles=%0d",idle_cnt), UVM_NONE)
    end  else en_user_delay=0;
    `uvm_info("STL::AXI", $sformatf("STL::AXI<%=my_ioaiu_id%> Sending AXI read txn:first_txn=%0h arid= %0h,araddr=%0h num_beats=%h arburst=%0h arcache=%0h arburst_size=%0h arlock=%0h arqos=%0h last_txn=%0h",first_txn,arid,araddr,arlen+1,arburst,arcache,arsize,arlock,arqos,last_txn), UVM_NONE)

    m_read_addr_seq.should_randomize   = 0;

    //randomize
    m_read_addr_seq.m_seq_item.m_read_addr_pkt.constrained_addr = 1;  
    m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.en_user_delay_before_txn ==local::en_user_delay ;
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.val_user_delay_before_txn ==local::idle_cnt ;
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid == local::arid ;
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == RDONCE;
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen==local::arlen;
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr == local::araddr; 
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache ==local::arcache;
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlock == local::arlock;
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arqos == local::arqos;
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst ==local::arburst;
    };
    `uvm_info("axi_read_addr_seq", $sformatf("STL::AXI Sending AXI read txn: %s", m_read_addr_seq.m_seq_item.convert2string()), UVM_NONE)

    m_read_addr_seq.return_response(m_seq_item0, m_read_addr_chnl_seqr);
endtask
task drive_stl_wr_txn();
    axi_axaddr_t awaddr;
    axi_awid_t awid;
    axi_axburst_t awsize;
    axi_xdata_t wdata;
    axi_axqos_t awqos;
    axi_axlen_t awlen;
    axi_bresp_t tmp_bresp[] = new[1];
    bit[3:0] awcache;
    bit[1:0] awburst,beat;
    bit awlock,cache,buff,cache_rd_aloc,cache_wr_aloc;
    int idle_cnt,rsp_wait,awburst_size;
    bit first_txn,last_txn,en_user_delay;
    static semaphore s_wr_addr[int];
    static semaphore s_wr_data[int];
    int core_id=0;
    //`uvm_info("STL::AXI",$psprintf("STL::AXI Randomizing stl write transactions=%0p ",stl_write_q),UVM_NONE)
    m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq"); 
    m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq"); 
    m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq"); 
    m_write_addr_seq.m_seq_item  = axi_wr_seq_item::type_id::create("m_seq_item");
    m_write_data_seq.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
    m_write_resp_seq.m_seq_item  = axi_wr_seq_item::type_id::create("m_seq_item");
    m_seq_item1         = axi_wr_seq_item::type_id::create("m_seq_item1");
    m_seq_item2         = axi_wr_seq_item::type_id::create("m_seq_item2");
    m_write_addr_seq.should_randomize  = 0;
    m_write_addr_seq.core_id  = core_id;
    m_write_data_seq.core_id = core_id;
    if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
    if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
    m_write_addr_seq.s_wr_addr = s_wr_addr; 
    m_write_data_seq.s_wr_data = s_wr_data; 
    //stl wr txn
    first_txn=stl_write_q.pop_front();
    if(first_txn==1) idle_cnt=stl_write_q.pop_front(); 
    awid=stl_write_q.pop_front();
    awlen=stl_write_q.pop_front()-1;
    awaddr=stl_write_q.pop_front();
    awburst=stl_write_q.pop_front();
    cache=stl_write_q.pop_front();
    buff=stl_write_q.pop_front();
    cache_wr_aloc=stl_write_q.pop_front();
    cache_rd_aloc=stl_write_q.pop_front();
    awburst_size=stl_write_q.pop_front();
    awlock=stl_write_q.pop_front();
    awqos=stl_write_q.pop_front();
    last_txn=stl_write_q.pop_front();
    awcache={cache,buff,cache_rd_aloc,cache_wr_aloc};
    awsize=$clog2(awburst_size);

     if(first_txn==1) begin
        en_user_delay=1;
        `uvm_info("STL::AXI", $sformatf("STL::AXI<%=my_ioaiu_id%> wr-ch inserting idle cycles=%0d",idle_cnt), UVM_NONE)
     end 
     else en_user_delay=0;
     if(last_txn==1) begin
        `uvm_info("STL::AXI", $sformatf("STL::AXI<%=my_ioaiu_id%> waiting for the resp of last txn wr-ch"), UVM_NONE)
        wait(tmp_bresp[0] ==OKAY);
     end 
    `uvm_info("STL::AXI", $sformatf("STL::AXI<%=my_ioaiu_id%> Sending AXI write txn:first_txn=%0h awid= %0h,awaddr=%0h wdata=%0h num_of_beats=%0h awburst=%0h awcache=%0h awburst_size=%0h awlock=%0h awqos=%0h last_txn=%0h",first_txn,awid,awaddr,wdata,awlen+1,awburst,awcache,awsize,awlock,awqos,last_txn), UVM_NONE)

    //s_wr_addr[core_id].get();
    //randomize
    m_write_addr_seq.m_seq_item.m_write_addr_pkt.constrained_addr = 1;
    m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
       m_write_addr_seq.m_seq_item.m_write_addr_pkt.en_user_delay_before_txn ==local::en_user_delay; 
       m_write_addr_seq.m_seq_item.m_write_addr_pkt.val_user_delay_before_txn ==local::idle_cnt; 
       m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid ==local::awid ;
       m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype ==WRUNQ ;
       m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen==local::awlen;
       m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr ==local::awaddr ;
       m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr ==local::awaddr ;
       m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache ==local::awcache ;
       m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlock ==local::awlock ;
       m_write_addr_seq.m_seq_item.m_write_addr_pkt.awqos ==local::awqos ;
       m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst ==local::awburst ;
    };

     m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
     m_write_data_seq.m_seq_item.m_write_data_pkt.wdata    = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
     m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb    = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
     m_write_data_seq.m_seq_item.m_write_data_pkt.wpoison  = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
     m_write_data_seq.m_seq_item.m_write_data_pkt.wdatachk = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
     m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;
    if (m_write_data_seq.m_seq_item.m_write_addr_pkt.awtrace) begin
        m_write_data_seq.m_seq_item.m_write_data_pkt.wtrace = 1;
    end
    for (int i=0; i< (m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1);i++) begin
        for (int j=0; j<(WXDATA/8); j++) begin
                m_write_data_seq.m_seq_item.m_write_data_pkt.wdatachk[i][j] = 0;
        end
    end
    m_write_data_seq.should_randomize = 0;
    fork 
       begin
          `uvm_info("axi_write_addr_seq", $sformatf("STL::AXI Sending AXI write txn: %s", m_write_addr_seq.m_seq_item.convert2string()), UVM_NONE)
          m_write_addr_seq.return_response(m_seq_item1, m_write_addr_chnl_seqr);
       end
       begin
          m_write_data_seq.return_response(m_seq_item2, m_write_data_chnl_seqr);
       end
   join
     
endtask
`endif //USE_STL_TRACE
endclass : axi_master_pipelined_seq


////////////////////////////////////////////////////////////////////////////////
//
// AXI Master WriteRead Pipelined Sequence
//
////////////////////////////////////////////////////////////////////////////////

class axi_master_writeread_pipelined_seq extends axi_master_pipeline_base_seq;

    `uvm_object_param_utils(axi_master_writeread_pipelined_seq)
    
    // Read and write sequences
    axi_master_read_seq         m_read_seq[];
    axi_master_write_noncoh_seq m_noncoh_write_seq[];
<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
    axi_master_write_coh_seq    m_coh_write_seq;
    axi_master_writeback_seq    m_wb_seq[];
<% } %>
    axi_master_exclusive_seq    m_exclusive_seq;
    
    // Read and write sequencers
    axi_read_addr_chnl_sequencer  m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer  m_read_data_chnl_seqr;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;

    ace_cache_model               m_ace_cache_model;

    bit                                       use_addr_from_test = 0;
    bit                                       use_axcache_from_test = 0;
    axi_axaddr_t   m_ace_addr_from_test;
    <% if (obj.wSecurityAttribute > 0) { %>                                             
        bit [<%=obj.wSecurityAttribute%>-1:0] m_ace_security_from_test;
    <% } %>                                                
    int use_incr_addr_from_test = 0;

    // Knobs added to axi_master_pipeline_base_seq
    int k_num_req                              = 100;
		   
    int k_num_read_weight                      = 50;
    int k_num_write_weight                     = 50;

    int random_txn[];													   
    int random_read_cnt;
    int random_write_cnt;

    string seq_name = "axi_master_writeread_pipelined_seq";

    // Bit to set if we dont want any updates
    bit no_updates                             = 0;
    // Bit to set if we want to not perform any writes during the read portion of the test and then
    // writeback everything at the end of the read portion of the test
    bit late_updates                           = 0;
    // Following bit is used only for wb throughput test
    bit wb_throughput_test                     = 0; 
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_seq_done;
    <% if(obj.testBench == "fsys"|| obj.testBench == "emu") { %>
    uvm_event ev_sim_done;
    <% } %>

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string _name = "axi_master_pipelined_seq");
    super.new(_name);
    wb_throughput_test = $test$plusargs("wb_bw_test");
    user_qos = 0;
endfunction : new

function set_seq_name(string s);
  seq_name = s;
endfunction : set_seq_name

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    m_read_seq                      = new[k_num_read_req];
    m_noncoh_write_seq              = new[k_num_write_req];
    late_updates                    = late_updates & no_updates;

<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5"){ %> 
    m_ace_cache_model.wt_ace_wrcln  = wt_ace_wrcln;
    m_ace_cache_model.wt_ace_wrbk   = wt_ace_wrbk;
    m_ace_cache_model.wt_ace_evct   = wt_ace_evct;
    m_ace_cache_model.wt_ace_wrevct = wt_ace_wrevct;
    m_wb_seq                        = new[k_num_write_req];
<% } %>      
    random_txn = new[k_num_req];
    random_read_cnt = 0;
    random_write_cnt = 0;
    for (int i = 0; i < k_num_req; i=i+1) begin
       randcase
       k_num_read_weight       : 
       begin
           random_txn[i] = 0;
	   random_read_cnt = random_read_cnt+1;
       end
       k_num_write_weight      : 
       begin
           random_txn[i] = 1;
	   random_write_cnt = random_write_cnt+1;
       end
       endcase
    end

    `uvm_info("IOAIU<%=my_ioaiu_id%> AXI SEQ", $sformatf("Creating ev_seq_done with name %s", seq_name), UVM_NONE)
    ev_seq_done = ev_pool.get(seq_name);
    <% if(obj.testBench == "fsys") { %>
    ev_sim_done = ev_pool.get("sim_done");
    <% } %>
    wt_not_illegal_op_addr = 100 - wt_illegal_op_addr;

    for (int i = 0; i < k_num_read_req; i++) begin
	randcase
          wt_not_illegal_op_addr : begin
                m_read_seq[i]                       = axi_master_read_seq::type_id::create($sformatf("m_read_seq_%0d", i));
          end
          wt_illegal_op_addr : begin
                m_read_seq[i]                       = axi_master_read_seq_err::type_id::create($sformatf("m_read_seq_%0d", i));
          end
	endcase												   
//        m_read_seq[i]                       = axi_master_read_seq::type_id::create($sformatf("m_read_seq_%0d", i));
        m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        m_read_seq[i].k_num_read_req        = 1;
        m_read_seq[i].wt_ace_rdnosnp        = wt_ace_rdnosnp;
        m_read_seq[i].wt_ace_rdonce         = wt_ace_rdonce;
        m_read_seq[i].wt_ace_rdshrd         = wt_ace_rdshrd;
        m_read_seq[i].wt_ace_rdcln          = wt_ace_rdcln;
        m_read_seq[i].wt_ace_rdnotshrddty   = wt_ace_rdnotshrddty;
        m_read_seq[i].wt_ace_rdunq          = wt_ace_rdunq;
        m_read_seq[i].wt_ace_clnunq         = wt_ace_clnunq;
        m_read_seq[i].wt_ace_mkunq          = wt_ace_mkunq;
        m_read_seq[i].wt_ace_dvm_msg        = wt_ace_dvm_msg;
        m_read_seq[i].wt_ace_dvm_sync       = wt_ace_dvm_sync;
        m_read_seq[i].wt_ace_clnshrd        = wt_ace_clnshrd;
        m_read_seq[i].wt_ace_clninvl        = wt_ace_clninvl;
        m_read_seq[i].wt_ace_mkinvl         = wt_ace_mkinvl;
        m_read_seq[i].wt_ace_rd_bar         = wt_ace_rd_bar;
        m_read_seq[i].wt_ace_rd_cln_invld   = wt_ace_rd_cln_invld;
        m_read_seq[i].wt_ace_rd_make_invld  = wt_ace_rd_make_invld;
        m_read_seq[i].wt_ace_clnshrd_pers   = wt_ace_clnshrd_pers;
        m_read_seq[i].read_req_total_count  = random_read_cnt;
	m_read_seq[i].k_access_boot_region  = k_access_boot_region;
	m_read_seq[i].use_axcache_from_test = (k_directed_test & k_directed_test_alloc) ? 1 : 0 ;
        m_read_seq[i].user_qos              = user_qos;
        m_read_seq[i].aiu_qos               = aiu_qos;
	m_read_seq[i].use_addr_from_test    = use_addr_from_test;
	m_read_seq[i].m_ace_rd_addr_from_test   = m_ace_addr_from_test + (i*use_incr_addr_from_test);
    <% if (obj.wSecurityAttribute > 0) { %>                                             
	m_read_seq[i].m_ace_rd_security_from_test  = m_ace_security_from_test;
    <% } %>                                                        
    end
    for (int i = 0; i < k_num_write_req; i++) begin
        if (wb_throughput_test) begin
            <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5"){ %> 
                m_wb_seq[i]                        = axi_master_writeback_seq::type_id::create($sformatf("m_writeback_seq_%0d", i));
                m_wb_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
                m_wb_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
                m_wb_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
                m_wb_seq[i].k_num_write_req        = 1;
            <% } %>      
        end
        else begin
	  randcase
               wt_not_illegal_op_addr : begin
		   m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_noncoh_write_seq_%0d", i));
               end
               wt_illegal_op_addr : begin
		   m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq_err::type_id::create($sformatf("m_noncoh_write_seq_%0d", i));
               end
          endcase
//            m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_noncoh_write_seq_%0d", i));
            m_noncoh_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
            m_noncoh_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
            m_noncoh_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
            m_noncoh_write_seq[i].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
            m_noncoh_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
            m_noncoh_write_seq[i].k_num_write_req        = 1;
            m_noncoh_write_seq[i].wt_ace_wrnosnp         = wt_ace_wrnosnp;
            m_noncoh_write_seq[i].wt_ace_wrunq           = wt_ace_wrunq;
            m_noncoh_write_seq[i].wt_ace_wrlnunq         = wt_ace_wrlnunq;
            m_noncoh_write_seq[i].wt_ace_wr_bar          = wt_ace_wr_bar;
            m_noncoh_write_seq[i].write_req_total_count  = random_write_cnt;
            m_noncoh_write_seq[i].wt_ace_atm_str         = wt_ace_atm_str;
            m_noncoh_write_seq[i].wt_ace_atm_ld          = wt_ace_atm_ld;
            m_noncoh_write_seq[i].wt_ace_atm_swap        = wt_ace_atm_swap;
            m_noncoh_write_seq[i].wt_ace_atm_comp        = wt_ace_atm_comp;
            m_noncoh_write_seq[i].wt_ace_ptl_stash       = wt_ace_ptl_stash;
            m_noncoh_write_seq[i].wt_ace_full_stash      = wt_ace_full_stash;
            m_noncoh_write_seq[i].wt_ace_shared_stash    = wt_ace_shared_stash;
            m_noncoh_write_seq[i].wt_ace_unq_stash       = wt_ace_unq_stash;
            m_noncoh_write_seq[i].wt_ace_stash_trans     = wt_ace_stash_trans;
            m_noncoh_write_seq[i].k_access_boot_region   = k_access_boot_region;
	    m_noncoh_write_seq[i].use_axcache_from_test  = (k_directed_test & k_directed_test_alloc) ? 1 : 0 ;
            m_noncoh_write_seq[i].user_qos               = user_qos;
            m_noncoh_write_seq[i].aiu_qos                = aiu_qos;
	    m_noncoh_write_seq[i].use_addr_from_test     = use_addr_from_test;
	    m_noncoh_write_seq[i].m_ace_wr_addr_from_test   = m_ace_addr_from_test + (i*use_incr_addr_from_test);
    <% if (obj.wSecurityAttribute > 0) { %>                                             
	    m_noncoh_write_seq[i].m_ace_wr_security_from_test  = m_ace_security_from_test;
    <% } %>                                                        
        end
    end
<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5"){ %> 
    m_coh_write_seq                        = axi_master_write_coh_seq::type_id::create("m_coh_write_seq");
    m_coh_write_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
    m_coh_write_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
    m_coh_write_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
    m_coh_write_seq.m_ace_cache_model      = m_ace_cache_model;
<% } %>


<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5"){ %> 
    fork
        begin
            for(int i = 0; i < k_num_exclusive_req; i++) begin
                m_exclusive_seq                       = axi_master_exclusive_seq::type_id::create($sformatf("m_exclusive_seq_%0d", i));
                m_exclusive_seq.m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
                m_exclusive_seq.m_read_data_chnl_seqr = m_read_data_chnl_seqr;
                m_exclusive_seq.m_ace_cache_model     = m_ace_cache_model;
                m_exclusive_seq.wt_ace_rdshrd         = wt_ace_rdshrd;
                m_exclusive_seq.wt_ace_rdcln          = wt_ace_rdcln;

                m_exclusive_seq.start(null);
            end
        end
    join_none

<% } %>
    for (int i = 0; i < k_num_req; i++) begin
        fork
            automatic int j = i;
            if(random_txn[j] == 0) begin
                m_read_seq[j].start(null);
            end
            else begin
                m_noncoh_write_seq[j].start(null);
            end
        join_none
    end
<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5"){ %> 
    fork
        begin
         if(!no_updates)begin
            m_coh_write_seq.start(null);
         end
        end
    join_none
<% } %>
    wait fork;
    `uvm_info("IOAIU<%=my_ioaiu_id%> AXI SEQ", $sformatf("AXI %s Sequence done", seq_name), UVM_NONE)
    ev_seq_done.trigger(null);													   
<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5"){ %> 
    fork
        begin
         if(late_updates)begin
             m_coh_write_seq.dont_ever_kill_seq = 1;
             m_coh_write_seq.start(null);
         end
        end
    join_none
<% } %>

<% if (obj.testBench == "fsys"|| obj.testBench == "emu") { %>    
    ev_sim_done.wait_trigger();
    `uvm_info("IOAIU<%=my_ioaiu_id%> AXI SEQ", "Received simulation done", UVM_NONE)
<% } %>
													   
endtask : body

endclass : axi_master_writeread_pipelined_seq

////////////////////////////////////////////////////////////////////////////////
// 
//          Barrier Testing
// 
// 
// Section1: Directed barrier sequence.
//
////////////////////////////////////////////////////////////////////////////////


//******************************************************************************
// Section1: axi_master_barrier_bringup_seq
// Purpose : Directed sequence that generate 2 reads, followed by a barrier txn, 
// followed by couple of more coherent reads.
//******************************************************************************

/*class axi_master_barrier_bringup_seq extends uvm_sequence #(axi_rd_seq_item);

    `uvm_object_param_utils(axi_master_barrier_bringup_seq)
    
    // Read and write sequences
    axi_master_read_seq         m_read_seq[];
    axi_master_write_noncoh_seq m_write_seq[];
    
    // Read and write sequencers
    axi_read_addr_chnl_sequencer  m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer  m_read_data_chnl_seqr;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;

    ace_cache_model               m_ace_cache_model;

    // Knobs

// Knobs
`ifdef PSEUDO_SYS_TB
    int wt_ace_rdnosnp                         = 0;
`else
    int wt_ace_rdnosnp                         = 5;
`endif
    int wt_ace_rdonce                          = 100;
    int wt_ace_clnunq                          = 0;
    int wt_ace_mkunq                           = 0;
     
    int wt_ace_clnshrd                         = 0;
    int wt_ace_clninvl                         = 0;
    int wt_ace_mkinvl                          = 0;
    int wt_ace_rd_bar                          = 0;
`ifdef PSEUDO_SYS_TB
    int wt_ace_wrnosnp                         = 0;
`else
    int wt_ace_wrnosnp                         = 5;
`endif
    // FIXME: Fix below weight to be non-zero
    int wt_ace_wrunq                           = 100;
    int wt_ace_wrlnunq                         = 0;
    int wt_ace_wrcln                           = 0;
    int wt_ace_wrbk                            = 0;
    int wt_ace_evct                            = 0;
    int wt_ace_wrevct                          = 0;
    // FIXME: Fix below weights to be non-zero
    int wt_ace_wr_bar                          = 0;


    int k_num_read_req              = 100;
    int k_num_write_req             = 100;


//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_master_barrier_bringup_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    m_read_seq  = new[5];
    m_write_seq = new[5];
   
    //Generate 2 coherent reads i.e ReadOnce 
    for (int i = 0; i < 2; i++) begin
        m_read_seq[i]                       = axi_master_read_seq::type_id::create($sformatf("m_read_seq_%0d", i));
        m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        m_read_seq[i].k_num_read_req        = 1;
        m_read_seq[i].wt_ace_rdnosnp        = wt_ace_rdnosnp;
        m_read_seq[i].wt_ace_rdonce         = wt_ace_rdonce;
        m_read_seq[i].wt_ace_clnunq         = wt_ace_clnunq;
        m_read_seq[i].wt_ace_mkunq          = wt_ace_mkunq;
        m_read_seq[i].wt_ace_clnshrd        = wt_ace_clnshrd;
        m_read_seq[i].wt_ace_clninvl        = wt_ace_clninvl;
        m_read_seq[i].wt_ace_mkinvl         = wt_ace_mkinvl;
        m_read_seq[i].wt_ace_rd_bar         = wt_ace_rd_bar;
    end

    //Generate 2 coherent write i.e WriteUnique 
    for (int i = 0; i < 2; i++) begin
        m_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_write_seq_%0d", i));
        m_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        m_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        m_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
        m_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
        m_write_seq[i].k_num_write_req        = 1;
        m_write_seq[i].wt_ace_wrnosnp         = wt_ace_wrnosnp;
        m_write_seq[i].wt_ace_wrunq           = wt_ace_wrunq;
        m_write_seq[i].wt_ace_wrlnunq         = wt_ace_wrlnunq;
        m_write_seq[i].wt_ace_wr_bar          = wt_ace_wr_bar;
    end

    
    //Generate Read/Write pair barrier trans.
    for (int i = 2; i < 3; i++) begin
        m_read_seq[i]                       = axi_master_read_seq::type_id::create($sformatf("m_read_seq_%0d", i));
        m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        m_read_seq[i].k_num_read_req        = 1;
        m_read_seq[i].wt_ace_rdnosnp        = 0;
        m_read_seq[i].wt_ace_rdonce         = 0;
        m_read_seq[i].wt_ace_rdshrd         = 0;
        m_read_seq[i].wt_ace_rdcln          = 0;
        m_read_seq[i].wt_ace_rdnotshrddty   = 0;
        m_read_seq[i].wt_ace_rdunq          = 0;
        m_read_seq[i].wt_ace_clnunq         = 0;
        m_read_seq[i].wt_ace_mkunq          = 0;
        m_read_seq[i].wt_ace_dvm_msg        = 0;
        m_read_seq[i].wt_ace_dvm_sync       = 0;
        m_read_seq[i].wt_ace_clnshrd        = 0;
        m_read_seq[i].wt_ace_clninvl        = 0;
        m_read_seq[i].wt_ace_mkinvl         = 0;
        m_read_seq[i].wt_ace_rd_bar         = 100;
    end

    //Write barrier trans.
    m_write_seq[2]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_write_seq_%0d", 0));
    m_write_seq[2].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
    m_write_seq[2].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
    m_write_seq[2].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
    m_write_seq[2].m_ace_cache_model      = m_ace_cache_model;
    m_write_seq[2].k_num_write_req        = 1;
    m_write_seq[2].wt_ace_wr_bar          = 100;


    //Follow up the barrier with more coherent read trans.   
    for (int i = 3; i < 5; i++) begin
        m_read_seq[i]                       = axi_master_read_seq::type_id::create($sformatf("m_read_seq_%0d", i));
        m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        m_read_seq[i].k_num_read_req        = 1;
        m_read_seq[i].wt_ace_rdnosnp        = wt_ace_rdnosnp;
        m_read_seq[i].wt_ace_rdonce         = wt_ace_rdonce;
        m_read_seq[i].wt_ace_clnunq         = wt_ace_clnunq;
        m_read_seq[i].wt_ace_mkunq          = wt_ace_mkunq;
        m_read_seq[i].wt_ace_clnshrd        = wt_ace_clnshrd;
        m_read_seq[i].wt_ace_clninvl        = wt_ace_clninvl;
        m_read_seq[i].wt_ace_mkinvl         = wt_ace_mkinvl;
    end
      
    //Generate 2 coherent write i.e WriteUnique 
    for (int i = 3; i < 5; i++) begin
        m_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_write_seq_%0d", i));
        m_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        m_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        m_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
        m_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
        m_write_seq[i].k_num_write_req        = 1;
        m_write_seq[i].wt_ace_wrnosnp         = wt_ace_wrnosnp;
        m_write_seq[i].wt_ace_wrunq           = wt_ace_wrunq;
        m_write_seq[i].wt_ace_wrlnunq         = wt_ace_wrlnunq;
        m_write_seq[i].wt_ace_wr_bar          = wt_ace_wr_bar;
    end



   
    for (int i = 0; i < 5; i++) begin
        fork
            automatic int j = i;
            begin
                m_read_seq[j].start(null);
            end
        join_none
    end

    
    for (int i = 0; i < 5; i++) begin
        fork
            automatic int j = i;
            begin
                m_write_seq[j].start(null);
            end
        join_none
    end

    wait fork;


endtask : body

endclass : axi_master_barrier_bringup_seq*/

<% if ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %>
////////////////////////////////////////////////////////////////////////////////
// 
//          Eviction Testing
// 
// 
// Section1: Eviction sequence.
// Section2: nonalloc txn with evict
//
////////////////////////////////////////////////////////////////////////////////

//******************************************************************************
// Section1 : Eviction sequence
// Purpose : 
//******************************************************************************

class eviction_wr_seq extends axi_master_write_base_seq;

    `uvm_object_param_utils(eviction_wr_seq)
    
    axi_write_addr_seq            m_write_addr_seq;
    axi_write_data_seq            m_write_data_seq;
    axi_write_resp_seq            m_write_resp_seq;
	
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;

    axi_wr_seq_item               m_seq_item0;
    axi_wr_seq_item               m_seq_item1;

    ace_cache_model              m_ace_cache_model;
    int core_id, txn_id;

    ace_command_types_enum_t 	cmd_type;
    axi_axaddr_t     		m_addr;
    axi_axaddr_t     		m_evict_addr;
    axi_axlen_t      		m_axlen;
    axi_awid_t use_awid;
    
    bit [<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length%> -1:0]   ccp_setindex;
    bit [addrMgrConst::W_SEC_ADDR-1:0] addr;
    addr_trans_mgr m_addr_mgr;									     
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "eviction_wr_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    bit                                              success;
    int itr, axlen , axid;
    bit [addrMgrConst::W_SEC_ADDR-2:0] next_addr;
 
   //    `uvm_info(get_full_name(),"Entering Body........", UVM_LOW)
    m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq"); 
    m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq");
    m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq"); 
    m_write_addr_seq.core_id = core_id; 
    m_write_data_seq.core_id = core_id;
    if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
    if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
    m_write_addr_seq.s_wr_addr = s_wr_addr; 
    m_write_data_seq.s_wr_data = s_wr_data; 

    std::randomize(cmd_type)with{cmd_type == WRUNQ;};
    m_write_addr_seq.m_ace_wr_addr_chnl_snoop = cmd_type;
    m_write_addr_seq.m_ace_wr_addr_chnl_addr  = addr[addrMgrConst::W_SEC_ADDR-2:0];
    m_write_addr_seq.m_ace_wr_addr_chnl_addr[SYS_wSysCacheline-1:0] = '0;
    m_write_addr_seq.m_ace_wr_addr_chnl_security = addr[addrMgrConst::W_SEC_ADDR-1];
    
    m_write_addr_seq.m_constraint_snoop = 1;
    m_write_addr_seq.m_constraint_addr  = 1;
    m_write_addr_seq.should_randomize   = 0;

    m_write_addr_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
    m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");

    m_ace_cache_model.core_id=core_id;	
    
    
    m_write_addr_seq.m_seq_item.m_write_addr_pkt.constrained_addr = 1;

    ccp_setindex = addrMgrConst::get_set_index(addr,<%=obj.FUnitId%>);
    axlen = ((SYS_nSysCacheline*8)/ WXDATA) - 1;
    next_addr = addr + SYS_nSysCacheline;
    itr = 1;
    
    while ((itr <= 3) && (ccp_setindex == addrMgrConst::get_set_index(next_addr,<%=obj.FUnitId%>)))
    begin 
        itr++;
        axlen = (((SYS_nSysCacheline*8)/ WXDATA)*itr) - 1;
        //`uvm_info(get_full_name(),$sformatf("itr:%0d start_addr:0x%0h axlen:%0d || next_addr:0x%0h setidx_next_addr:0x%0h", itr,addr, axlen, next_addr, addrMgrConst::get_set_index(next_addr,<%=obj.FUnitId%>)), UVM_LOW)
        next_addr += SYS_nSysCacheline;
    end

    axlen = $urandom_range(0,1) ? 0 : axlen;
    axid = $urandom_range(0, ((1<<WAWID)-1));
    success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid    == axid;
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr  == m_write_addr_seq.m_ace_wr_addr_chnl_addr;
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awdomain inside {2'b01,2'b10};
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[3:2] == 2'b11;
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen == axlen; 
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst == AXIINCR; 
                    //m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen == (((SYS_nSysCacheline*8)/ WXDATA)-1); 

            <% if (obj.wSecurityAttribute > 0) { %>                                             
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]==m_write_addr_seq.m_ace_wr_addr_chnl_security;
            <% } %>
            };
    
    if (!success) begin
        `uvm_error(get_full_name(), $sformatf("TB Error: Could not randomize write address packet in eviction_wr_seq"));
    end
    

    success = m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
    
    if (!success) begin
        `uvm_error(get_full_name(), $sformatf("TB Error: Could not randomize write data packet in eviction_wr_seq"));
    end
    
    m_write_data_seq.m_seq_item.m_write_data_pkt.wdata = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
    m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        
    m_ace_cache_model.give_data_for_ace_req(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_ace_wr_addr_chnl_snoop, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize, m_write_data_seq.m_seq_item.m_write_data_pkt.wdata, m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb
<% if (obj.wSecurityAttribute > 0) { %>                                             
               ,m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]
<% } %>                                                
    );

    m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;
		
    m_write_addr_seq.should_randomize = 0;
    m_write_data_seq.should_randomize = 0;
        
    fork 
        begin
            `uvm_info(get_full_name(), $sformatf("Sending C%0d_AXI[%0d] %0s", core_id, txn_id, m_write_addr_seq.m_seq_item.convert2string()), UVM_LOW);
            m_write_addr_seq.return_response(m_seq_item0, m_write_addr_chnl_seqr);
            //s_wr_addr[core_id].put();
        end
	begin
            //`uvm_info(get_full_name(), $sformatf("Sending C%0d_AXI[%0d] Write Data", core_id, txn_id), UVM_LOW);
            m_write_data_seq.return_response(m_seq_item1, m_write_data_chnl_seqr);
            //s_wr_data[core_id].put();
        end
    join
    
    m_write_resp_seq.should_randomize = 0;
    m_write_resp_seq.m_seq_item       = m_seq_item0;
    m_write_resp_seq.return_response(m_seq_item0, m_write_resp_chnl_seqr);

//      `uvm_info(get_full_name(),"Exiting Body........", UVM_LOW)
endtask : body

endclass : eviction_wr_seq


//******************************************************************************
// Section1 : Eviction sequence
// Purpose : 
//******************************************************************************

class eviction_rd_seq extends axi_master_read_base_seq;

    `uvm_object_param_utils(eviction_rd_seq)
    

    axi_read_addr_seq            m_read_addr_seq;
    axi_read_data_seq            m_read_data_seq;
    axi_read_addr_chnl_sequencer m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer m_read_data_chnl_seqr;
    axi_rd_seq_item              m_seq_item;
	
    ace_cache_model              m_ace_cache_model;

    int core_id, txn_id;
    ace_command_types_enum_t 	cmd_type;
    bit [addrMgrConst::W_SEC_ADDR-1:0] addr;

    bit [<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length%> -1:0]   ccp_setindex;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "eviction_rd_seq");
    super.new(name);
endfunction : new


//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    bit success;
    axi_arid_t use_arid;
     int axid, itr, axlen ;
    bit [addrMgrConst::W_SEC_ADDR-2:0] next_addr;

    //`uvm_info(get_full_name(),"Entering Body........", UVM_LOW)
    m_read_addr_seq = axi_read_addr_seq::type_id::create("m_read_addr_seq"); 
    m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 
    
    std::randomize(cmd_type)with{cmd_type == RDONCE;};
    m_read_addr_seq.m_ace_rd_addr_chnl_snoop = cmd_type;
    m_read_addr_seq.m_ace_rd_addr_chnl_addr  = addr[addrMgrConst::W_SEC_ADDR-2:0];
    m_read_addr_seq.m_ace_rd_addr_chnl_addr[SYS_wSysCacheline-1:0] = '0;
    m_read_addr_seq.m_ace_rd_addr_chnl_security = addr[addrMgrConst::W_SEC_ADDR-1];
		
    m_read_addr_seq.m_constraint_snoop      = 1;
    m_read_addr_seq.m_constraint_addr       = 1;
    m_read_addr_seq.should_randomize        = 0;
        
    m_read_addr_seq.m_seq_item  = axi_rd_seq_item::type_id::create("m_seq_item");
    m_ace_cache_model.core_id=core_id;	
       

    m_read_addr_seq.m_seq_item.m_read_addr_pkt.constrained_addr = 1;
   
    axid = $urandom_range(0, ((1<<WARID)-1));
    axlen = ((SYS_nSysCacheline*8)/ WXDATA) - 1;
    axlen = $urandom_range(0,1) ? 0 : axlen;
    success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid    == axid;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr  == m_read_addr_seq.m_ace_rd_addr_chnl_addr;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.ardomain inside {2'b01,2'b10};
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[3:2] == 2'b11;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen == axlen;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == AXIINCR; 

            <% if (obj.wSecurityAttribute > 0) { %>                                             
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1]==m_read_addr_seq.m_ace_rd_addr_chnl_security;
            <% } %>
            };

    if (!success) begin
        `uvm_error(get_full_name(), $sformatf("TB Error: Could not randomize read address packet in eviction_rd_seq"));
    end

    `uvm_info(get_full_name(), $sformatf("Sending C%0d_AXI[%0d] %0s", core_id, txn_id, m_read_addr_seq.m_seq_item.convert2string()), UVM_LOW);
    
    m_read_addr_seq.return_response(m_seq_item, m_read_addr_chnl_seqr);
    
    m_read_data_seq.m_seq_item       = m_seq_item;
    m_read_data_seq.should_randomize = 0;
    m_read_data_seq.return_response(m_seq_item, m_read_data_chnl_seqr);

   // `uvm_info(get_full_name(),"Exiting Body........", UVM_LOW)
endtask : body

endclass : eviction_rd_seq


//******************************************************************************
// Section2 :eviction_seq
// Purpose : 
//******************************************************************************
class eviction_seq extends axi_master_pipelined_seq;

    `uvm_object_param_utils(eviction_seq)
    
    eviction_wr_seq   evict_wr_seq[];
    eviction_rd_seq   evict_rd_seq[];

    int num_txns, num_reads, num_writes, num_evictions;
    bit [addrMgrConst::W_SEC_ADDR -1: 0] raddrq[$];
    bit [addrMgrConst::W_SEC_ADDR -1: 0] waddrq[$];
    bit usecache='b1;
    addrMgrConst::mem_type get_coh_noncoh_type =addrMgrConst::ANY;
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "eviction_seq");
    super.new(name);
    if (ccp_setindex == 0) begin
        assert(std::randomize(ccp_setindex))
        else begin
            `uvm_error(get_full_name(), "Failure to randomize ccp_setindex");
        end
     end
 
    if (!$value$plusargs("num_evictions=%0d", num_evictions)) begin 
       // num_evictions = $urandom_range(500, 1500); 
        num_evictions = 10; 
    end
    num_txns = IOC_NUM_WAYS + num_evictions;
    if ($test$plusargs("write_only")) 
    num_reads = 0;
    else
    num_reads = $urandom_range(0,num_txns);
    num_writes = num_txns - num_reads;
    
    evict_rd_seq = new[num_reads];
    evict_wr_seq = new[num_writes];

endfunction : new
 
//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    int k; 
        `uvm_info(get_full_name(),$sformatf("c%0d Entering Body........num_evictions:%0d num_txns:%0d num_reads:%0d num_writes:%0d ccp_setindex:0x%0h", core_id, num_evictions, num_txns, num_reads, num_writes, ccp_setindex), UVM_LOW)
    //m_addr_mgr.get_addrq_w_fix_set_index(ccp_setindex, <%=obj.FUnitId%>, core_id, num_txns, uaddrq, get_coh_noncoh_type,usecache);
    get_coh_noncoh_type = addrMgrConst::NONCOH_DII;
    m_addr_mgr.get_addrq_w_fix_set_index(ccp_setindex, <%=obj.FUnitId%>, core_id, num_reads, raddrq, get_coh_noncoh_type, usecache);
    
    //`uvm_info(get_full_name(), $psprintf("c%0d addrq - %0p", core_id, uaddrq), UVM_LOW);

    foreach(evict_rd_seq[i]) begin 
            evict_rd_seq[i] = eviction_rd_seq::type_id::create($sformatf("c%0d_setidx_0x%0h_evict_rd_seq_%0d", core_id, ccp_setindex, i)); 
            evict_rd_seq[i].core_id      	  = core_id;
            evict_rd_seq[i].txn_id      	  = i;
            evict_rd_seq[i].addr      	          = raddrq[i];
            evict_rd_seq[i].m_ace_cache_model     = m_ace_cache_model;
            evict_rd_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
            evict_rd_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
            k++;
    end 
    
    get_coh_noncoh_type = addrMgrConst::COH_DMI;
    m_addr_mgr.get_addrq_w_fix_set_index(ccp_setindex, <%=obj.FUnitId%>, core_id, num_writes, waddrq, get_coh_noncoh_type, usecache);
    foreach(evict_wr_seq[j]) begin 
            evict_wr_seq[j] = eviction_wr_seq::type_id::create($sformatf("c%0d_setidx_0x%0h_evict_wr_seq_%0d", core_id, ccp_setindex, j)); 
            evict_wr_seq[j].core_id      	   = core_id;
            evict_wr_seq[j].txn_id      	   = j;
            evict_wr_seq[j].addr        	   = waddrq[j];
            evict_wr_seq[j].m_ace_cache_model      = m_ace_cache_model;
            evict_wr_seq[j].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
            evict_wr_seq[j].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
            evict_wr_seq[j].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
            k++;
    end

    if ($test$plusargs("sequential_access")) begin: _sequential_access
        for (int i = evict_rd_seq.size()-1; i >= 0 ; i--) begin
            evict_rd_seq[i].start(null);
        end 
        for (int i = evict_wr_seq.size()-1; i >= 0 ; i--) begin
            evict_wr_seq[i].start(null);
        end 
    end: _sequential_access 
    else begin:_stream_access
        fork 
            begin
                for (int i = evict_rd_seq.size()-1; i >= 0 ; i--) begin
                    fork
                        automatic int j=i;
                        begin
                            evict_rd_seq[j].start(null);
                        end
                    join_none
                end
                //wait fork;
                //`uvm_info(get_full_name(), $sformatf("c%0d Done with all forked read threads", core_id), UVM_LOW)
            end
            begin
                for (int k = evict_wr_seq.size()-1; k >= 0 ; k--) begin
                    fork
                        automatic int m=k;
                        begin
                            evict_wr_seq[m].start(null);
                        end
                    join_none
                end
                //wait fork;
                //`uvm_info(get_full_name(), $sformatf("c%0d Done with all forked write threads", core_id), UVM_LOW)
            end
        join_none
        //wait fork;
    end:_stream_access

    `uvm_info(get_full_name(), $sformatf("c%0d Exiting Body........", core_id), UVM_LOW)
endtask : body
 
endclass : eviction_seq

class nonallocate_seq extends axi_master_pipelined_seq;

    `uvm_object_param_utils(nonallocate_seq)
    
    axi_master_write_noncoh_seq         m_noncoh_write_seq;
    eviction_seq evict_seq;

    int num_req;
    bit wr_rd;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "nonallocate_seq");
    super.new(name);
endfunction : new
 
//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    m_noncoh_write_seq           = axi_master_write_noncoh_seq::type_id::create("m_noncoh_write_seq");
    evict_seq                   = eviction_seq::type_id::create("evict_seq");
    
           fork 
            begin
             m_noncoh_write_seq.core_id      	        = core_id;
             m_noncoh_write_seq.m_ace_cache_model      = m_ace_cache_model;
             m_noncoh_write_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
             m_noncoh_write_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
             m_noncoh_write_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
             m_noncoh_write_seq.k_num_write_req = 0;
             m_noncoh_write_seq.start(null);
           end 
           begin
             evict_seq.core_id      	        = core_id;
             evict_seq.m_ace_cache_model     = m_ace_cache_model;
             evict_seq.m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
             evict_seq.m_read_data_chnl_seqr = m_read_data_chnl_seqr;
             evict_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
             evict_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
             evict_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
             evict_seq.num_txns = 10;
             evict_seq.ccp_setindex      	          = ccp_setindex;
             evict_seq.start(null);
           end
           join


endtask : body
 
endclass : nonallocate_seq
<%}%>

////////////////////////////////////////////////////////////////////////////////
// 
//          IO Cache Sequences
// 
// Browse code using this sections. 
//
// Section1 : Basic ReadOnce sequence 
// Section2 : Basic WriteUnique sequence 
// Section3 : Random Read/Write sequence.  
// Section4 : Read hit sequence.  
// Section5 : Write hit sequence.  
// Section6 : Read Miss sequence.  
// Section7 : Write Miss sequence.  
// Section8 : Read Evict sequence.  
// Section9 : Write Evict sequence.  
////////////////////////////////////////////////////////////////////////////////

typedef class iocache_addr_gen;


class iocache_addr_gen extends uvm_object;

    rand axi_axaddr_t         addr;

endclass


//******************************************************************************
// Section1: ReadOnce
// Purpose : Generates a single ReadOnce transaction.
//******************************************************************************

class axi_master_readonce_seq extends axi_master_read_base_seq;

    `uvm_object_param_utils(axi_master_readonce_seq)
    
    axi_read_addr_seq            m_read_addr_seq;
    axi_read_data_seq            m_read_data_seq;
    axi_read_addr_chnl_sequencer m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer m_read_data_chnl_seqr;
    axi_rd_seq_item              m_seq_item;

    ace_cache_model              m_ace_cache_model;

    iocache_addr_gen             m_iocache_addr_gen;
    bit stall_wr_port;
    bit dont_send_updates;
    bit success;
    bit en_read_hits;
    bit en_read_evicts;
    bit gen_io_cache_addr;
    bit en_perf_mode;
    bit en_trace_file_mode;
    int no_of_bytes;
    bit en_2beat_multi_line;
    bit en_1beat_seq;

    //Control Knobs

    axi_axaddr_t     m_addr;
    axi_axaddr_t     m_evict_addr;
    axi_axlen_t      m_axlen;

    bit set_rd_hit_addr;

    int k_num_read_req           = 100;

    int wt_num_of_rd_partial     = 0;
    int wt_num_of_rd_full        = 5;
    static bit pwrmgt_power_down = 0;

    <% if(obj.useIoCache) { %>                   
    parameter NO_OF_SETS = <%=obj.nSets%>;
    parameter NO_OF_WAYS = <%=obj.nWays%>;
    parameter INDEX_SIZE = $clog2(NO_OF_SETS);
    parameter INDEX_LOW  = SYS_wSysCacheline;
    <%if(obj.nSets>2){%>
    parameter INDEX_HIGH = INDEX_SIZE+INDEX_LOW-1;
    <%}else{%>
    parameter INDEX_HIGH = INDEX_LOW;
    <%}%>
    <%}else{%>
    parameter NO_OF_SETS = 0;
    parameter NO_OF_WAYS = 0;
    parameter INDEX_SIZE = 0;
    parameter INDEX_LOW  = SYS_wSysCacheline;
    parameter INDEX_HIGH = INDEX_LOW+1;
    <%}%>

    bit directed_burst_type;
    bit addr_from_seq;
    int m_axlen_from_cmdline;
    addr_trans_mgr m_addr_mgr;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_master_readonce_seq");
    uvm_cmdline_processor clp;
    string arg_value;
    super.new(name);
    if ($test$plusargs("directed_burst_type")) begin
        directed_burst_type = 1'b1;
    end

    clp = uvm_cmdline_processor::get_inst();
    if (clp.get_arg_value("+set_axlen_from_cmdline=", arg_value)) begin
        m_axlen_from_cmdline = arg_value.atoi();
    end else begin
        m_axlen_from_cmdline = -1;
    end
    m_addr_mgr = addr_trans_mgr::get_instance();

endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    int                                              num_req;

    num_req = 0;
    m_read_addr_seq = axi_read_addr_seq::type_id::create("m_read_addr_seq"); 
    m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 
    do begin
        bit                                         done = 0;
        bit                                         is_coh = 0;
        axi_arid_t use_arid;
        if(s_rd[core_id] == null) s_rd[core_id] = new(1);
        s_rd[core_id].get();
        if (pwrmgt_power_down == 1) begin
            wait(pwrmgt_power_down == 0);
        end
        //do begin
            m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDONCE;

            if(gen_io_cache_addr) begin
                done = m_ace_cache_model.give_addr_for_io_cache(m_read_addr_seq.m_ace_rd_addr_chnl_snoop, 
                                                                m_read_addr_seq.m_ace_rd_addr_chnl_addr
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,m_read_addr_seq.m_ace_rd_addr_chnl_security
<% } %>                                                
                                                            );
                 is_coh = 0;
            
            end else begin
                done                          = m_ace_cache_model.give_addr_for_ace_req_read(0, m_read_addr_seq.m_ace_rd_addr_chnl_snoop, 
                                                                                        m_read_addr_seq.m_ace_rd_addr_chnl_addr
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,m_read_addr_seq.m_ace_rd_addr_chnl_security
<% } %>
    ,is_coh
    
                                                            );
            end
            if (done) begin
               uvm_report_info("ACE BFM SEQ", $sformatf("RD snooptype %0s addr 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), m_read_addr_seq.m_ace_rd_addr_chnl_addr), UVM_MEDIUM);
               uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("RD snooptype %0s addr 0x%0x secure bit 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), m_read_addr_seq.m_ace_rd_addr_chnl_addr, 
       <% if (obj.wSecurityAttribute > 0) { %>                                             
               m_read_addr_seq.m_ace_rd_addr_chnl_security 
       <% } else { %>                                                
               0
       <% } %>
    ), UVM_MEDIUM);
 
            end
        //end while (!done);

        m_read_addr_seq.m_constraint_snoop      = 1;
        m_read_addr_seq.m_constraint_addr       = 0;
        m_read_addr_seq.should_randomize        = 0;
        
        m_read_addr_seq.m_seq_item  = axi_rd_seq_item::type_id::create("m_seq_item");
      
        m_iocache_addr_gen = new;
        if(en_read_hits == 1'b1) 
            if(set_rd_hit_addr)
                m_iocache_addr_gen.addr = m_addr; 
            else begin
                set_rd_hit_addr         = 1'b1;
                m_addr                  = m_read_addr_seq.m_ace_rd_addr_chnl_addr;
                m_iocache_addr_gen.addr = m_read_addr_seq.m_ace_rd_addr_chnl_addr;
            end
        else if(en_read_evicts == 1'b1) begin
            m_evict_addr = m_read_addr_seq.m_ace_rd_addr_chnl_addr;
            m_iocache_addr_gen.addr = m_addr_mgr.gen_coh_addr(
               <%=obj.FUnitId%>, 1, .set_index(1), .core_id(core_id));
            //m_iocache_addr_gen.addr[INDEX_HIGH:INDEX_LOW]=1;
        end else
            m_iocache_addr_gen.addr = m_read_addr_seq.m_ace_rd_addr_chnl_addr;

        get_axid(m_read_addr_seq.m_ace_rd_addr_chnl_snoop, use_arid);


        if(m_axlen_from_cmdline == -1) begin
            m_axlen_from_cmdline = $urandom_range((((SYS_nSysCacheline*8)/WXDATA)-1),0); 
        end 

        if(en_perf_mode) begin
            m_iocache_addr_gen.addr = m_addr; 

            m_read_addr_seq.m_seq_item.m_read_addr_pkt.constrained_addr = 1;
            success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid == use_arid;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.coh_domain == is_coh;
                if (m_read_addr_seq.m_constraint_snoop == 1) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr == m_iocache_addr_gen.addr;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1]==0;
                if (!en_1beat_seq) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen == (((SYS_nSysCacheline*8)/
                                    WXDATA)-1);
                if (en_1beat_seq) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen == m_axlen_from_cmdline;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst ==  AXIINCR;
                // For directed test case purposes
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.useFullCL  == use_full_cl;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.use2FullCL == 0;
            };

        end else if (en_trace_file_mode) begin

            m_iocache_addr_gen.addr = m_addr; 

            if(no_of_bytes>0) begin
                m_axlen = (no_of_bytes/WXDATA) - 1;
            end else begin
                `uvm_error("IO-$-SEQ",$psprintf("While using the Trace file mode the seq need to know the num of bytes to transfer"))      
            end

            m_read_addr_seq.m_seq_item.m_read_addr_pkt.constrained_addr = 1;
            success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid == use_arid;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.coh_domain == is_coh;
                if (m_read_addr_seq.m_constraint_snoop == 1) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr == m_iocache_addr_gen.addr;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1]==0;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen ==  m_axlen;
                // For directed test case purposes
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.useFullCL  == use_full_cl;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.use2FullCL == 0;
            };

        end else if (en_2beat_multi_line) begin
            m_iocache_addr_gen.addr[SYS_wSysCacheline-1:SYS_wSysCacheline-2] = 'h3;

            m_read_addr_seq.m_seq_item.m_read_addr_pkt.constrained_addr = 1;
            success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid == use_arid;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.coh_domain == is_coh;
                if (m_read_addr_seq.m_constraint_snoop == 1) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr == m_iocache_addr_gen.addr;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1]==0;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen ==  'h1;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == AXIINCR;
                // For directed test case purposes
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.useFullCL  == use_full_cl;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.use2FullCL == 0;
            };

        end else begin
            if(addr_from_seq) begin
                m_iocache_addr_gen.addr = m_addr; 
            end 
            
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.constrained_addr = 1;
            success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid == use_arid;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.coh_domain == is_coh;
                if (m_read_addr_seq.m_constraint_snoop == 1) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr == m_iocache_addr_gen.addr;
                // For directed test case purposes
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.useFullCL == use_full_cl;
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.use2FullCL == 0;
                if (use_burst_wrap) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == AXIWRAP;
                if (use_burst_incr) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == AXIINCR;
                if (directed_burst_type) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen ==  'h1;
                if(directed_burst_type) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1]==0;

                <% if (obj.wSecurityAttribute > 0) { %>                                             
                if(!directed_burst_type) m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1]==m_read_addr_seq.m_ace_rd_addr_chnl_security;
                <% } %>                                                
            };
        end
        
        if (!success) begin
            `uvm_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_master_read_seq"))
        end
        
        `uvm_info("ACE BFM SEQ", $sformatf("RD snooptype %0s addr 0x%0x Len 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), 
                                        m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr, m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen), UVM_HIGH);
        m_read_addr_seq.return_response(m_seq_item, m_read_addr_chnl_seqr);
        s_rd[core_id].put();
        wait_till_arid_latest(m_read_addr_seq.m_seq_item.m_read_addr_pkt);
        m_read_data_seq.m_seq_item       = m_seq_item;
        m_read_data_seq.should_randomize = 0;
        m_read_data_seq.return_response(m_seq_item, m_read_data_chnl_seqr);

        delete_ott_entry(m_read_addr_seq.m_seq_item.m_read_addr_pkt);
        //m_seq_item.m_read_data_pkt.rdata = new[SYS_nSysCacheline/(WXDATA/8)];
        num_req++;

    end while (num_req < k_num_read_req);
endtask : body

endclass : axi_master_readonce_seq


//******************************************************************************
// Section2: WriteUnique
// Purpose : Generates a single WriteOnce transaction.
//
// anippuleti (11/11/2016) Added more support to use it in system level.
//                         concerto_inhouse_mutex_basic_test. Refer to knobs
//                         get_addr_from_test
//******************************************************************************


class axi_master_writeunique_seq extends axi_master_write_base_seq;

    `uvm_object_param_utils(axi_master_writeunique_seq)
    
    axi_write_addr_seq            m_write_addr_seq;
    axi_write_data_seq            m_write_data_seq;
    axi_write_resp_seq            m_write_resp_seq;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;
    axi_wr_seq_item               m_seq_item0;
    axi_wr_seq_item               m_seq_item1;

    ace_cache_model              m_ace_cache_model;

    iocache_addr_gen             m_iocache_addr_gen;

    bit en_write_hits;
    bit en_write_evicts;
    bit gen_io_cache_addr;
    bit en_perf_mode;
    bit en_trace_file_mode;
    int no_of_bytes;

    static bit pwrmgt_power_down = 0;

    bit use_full=1;

    axi_axaddr_t     m_addr;
    axi_axaddr_t     m_evict_addr;
    axi_axlen_t      m_axlen = ((SYS_nSysCacheline * 8 / WXDATA) - 1);


    //Control Knobs

    bit use_burst_incr;
    bit use_burst_wrap;
    bit set_wr_hit_addr;
    bit get_addr_from_test, get_data_from_test;
    axi_axaddr_t      m_addr_from_test;
    axi_xdata_t      m_data_from_test[];


    <% if(obj.isBridgeInterface && obj.useIoCache) { %>                   //FIXME:This should be removed.
    parameter NO_OF_SETS = <%=obj.nSets%>;
    parameter NO_OF_WAYS = <%=obj.nWays%>;
    parameter INDEX_SIZE = $clog2(NO_OF_SETS);
    parameter INDEX_LOW  = SYS_wSysCacheline;
    <%if(obj.nSets>2){%>
    parameter INDEX_HIGH = INDEX_SIZE+INDEX_LOW-1;
    <%}else{%>
    parameter INDEX_HIGH = INDEX_LOW;
    <%}%>

    <%}else{%>
    parameter NO_OF_SETS = 0;
    parameter NO_OF_WAYS = 0;
    parameter INDEX_SIZE = 0;
    parameter INDEX_LOW  = SYS_wSysCacheline;
    parameter INDEX_HIGH = INDEX_LOW+1;
    <%}%>


    int k_num_write_req         = 100;
    int wt_num_of_wr_partial    = 0;
    int wt_num_of_wr_full       = 5;

    bit en_1beat_seq;
    int m_axlen_from_cmdline;
    addr_trans_mgr m_addr_mgr;									     
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_master_writeunique_seq");
    uvm_cmdline_processor clp;
    string arg_value;
    super.new(name);

    clp = uvm_cmdline_processor::get_inst();
    if (clp.get_arg_value("+set_axlen_from_cmdline=", arg_value)) begin
        m_axlen_from_cmdline = arg_value.atoi();
    end else begin
        m_axlen_from_cmdline = -1;
    end
    m_addr_mgr = addr_trans_mgr::get_instance();

endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    int                                              num_req;
    bit                                              success;

    num_req = 0;
    m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq"); 
    m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq"); 
    m_write_addr_seq.core_id = core_id; 
    m_write_data_seq.core_id = core_id;
    if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
    if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
    m_write_addr_seq.s_wr_addr = s_wr_addr; 
    m_write_data_seq.s_wr_data = s_wr_data; 
    m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq"); 
    do begin
        bit done = 0;
        bit is_coh = 1; // by default writeuniq is coh
        bit addr_gen_failure = 0;
        axi_awid_t use_awid;
	   	if(s_wr[core_id] == null) s_wr[core_id] = new(1);
        s_wr[core_id].get();
        if (pwrmgt_power_down == 1) begin
            wait(pwrmgt_power_down == 0);
        end
        //do begin
            m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRUNQ;
            if(gen_io_cache_addr) begin
                done = m_ace_cache_model.give_addr_for_io_cache(m_write_addr_seq.m_ace_wr_addr_chnl_snoop,
                    m_write_addr_seq.m_ace_wr_addr_chnl_addr
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        ,m_write_addr_seq.m_ace_wr_addr_chnl_security
                    <% } %>                                                
                );
            
            end else begin
                if(get_addr_from_test) begin
                    m_write_addr_seq.m_ace_wr_addr_chnl_addr = m_addr_from_test;
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                    m_write_addr_seq.m_ace_wr_addr_chnl_security = 1'b0;
                    <% } %>                                                
                end else begin
                    m_ace_cache_model.give_addr_for_ace_req_noncoh_write(0, m_write_addr_seq.m_ace_wr_addr_chnl_snoop, 
                        m_write_addr_seq.m_ace_wr_addr_chnl_addr
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            ,m_write_addr_seq.m_ace_wr_addr_chnl_security
                        <% } %>
                           ,is_coh 
                           ,.addr_gen_failure(addr_gen_failure)
                    );
                end
                done = 1;
            end
            if (done) begin
                uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("WR snooptype %0s address 0x%0x secure bit 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_ace_wr_addr_chnl_addr, 
        <% if (obj.wSecurityAttribute > 0) { %>                                             
                m_write_addr_seq.m_ace_wr_addr_chnl_security
        <% } else { %>
                0
        <% } %>
            ), UVM_MEDIUM);
 
            end
       // end while (!done);
        m_write_addr_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_addr_seq.m_constraint_snoop        = 1;
        m_write_addr_seq.m_constraint_addr         = 1;

        m_iocache_addr_gen = new;

        if(en_write_hits == 1'b1) 
            if(set_wr_hit_addr)
                m_iocache_addr_gen.addr = m_addr; 
            else begin
                set_wr_hit_addr = 1'b1;
                m_addr = m_write_addr_seq.m_ace_wr_addr_chnl_addr;
                m_iocache_addr_gen.addr = m_write_addr_seq.m_ace_wr_addr_chnl_addr;
            end
        else if(en_write_evicts == 1'b1) begin
            m_evict_addr = m_write_addr_seq.m_ace_wr_addr_chnl_addr;
            m_iocache_addr_gen.addr = m_addr_mgr.gen_coh_addr(
                <%=obj.FUnitId%>, 1, .set_index(1), .core_id(core_id));
            //m_iocache_addr_gen.addr[INDEX_HIGH:INDEX_LOW]=1;
        end else
            m_iocache_addr_gen.addr = m_write_addr_seq.m_ace_wr_addr_chnl_addr;


        if(m_axlen_from_cmdline == -1) begin
            use_full = $urandom_range(1,0);
            if(use_full) begin
                m_axlen_from_cmdline = ((SYS_nSysCacheline*8)/WXDATA)-1; 
            end else begin
		<%if((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) { %>
                m_axlen_from_cmdline = $urandom_range(<%=Math.max((2**obj.wCacheLineOffset) * 8 / obj.wData,16)%>,0); 
	        <% } else { %>
                m_axlen_from_cmdline = $urandom_range((((SYS_nSysCacheline*8)/WXDATA)-1),0); 
	        <% } %>
            end
        end 

        if ($test$plusargs("pcie_prod_consu_stress_test")) use_awid =0; 
        else get_axid(m_write_addr_seq.m_ace_wr_addr_chnl_snoop, use_awid);

        if(en_perf_mode) begin
            m_iocache_addr_gen.addr = m_addr; 

            m_write_addr_seq.m_seq_item.m_write_addr_pkt.constrained_addr = 1;
            success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
                if (m_write_addr_seq.m_constraint_snoop == 1) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid   == use_awid;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.coh_domain == is_coh;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr == m_iocache_addr_gen.addr;
                // For directed test case purposes
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.useFullCL == use_full_cl;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]==0;
                if (en_1beat_seq)  m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen==m_axlen_from_cmdline;
                if (!en_1beat_seq) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen==(((SYS_nSysCacheline*8)/
                                    WXDATA)-1);
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst==AXIINCR;
            };

        end else if (en_trace_file_mode) begin

            m_iocache_addr_gen.addr = m_addr; 

            if(no_of_bytes>0) begin
                m_axlen = (no_of_bytes/WXDATA) - 1;
            end else begin
                `uvm_error("IO-$-SEQ",$psprintf("While using the Trace file mode the seq need to know the num of bytes to transfer"))      
            end

            m_write_addr_seq.m_seq_item.m_write_addr_pkt.constrained_addr = 1;
            success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
                if (m_write_addr_seq.m_constraint_snoop == 1) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid   == use_awid;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.coh_domain == is_coh;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr == m_iocache_addr_gen.addr;
                // For directed test case purposes
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.useFullCL == use_full_cl;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]==0;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst==AXIINCR;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen==m_axlen;
            };

        end else begin
            m_write_addr_seq.m_seq_item.m_write_addr_pkt.constrained_addr = 1;
            success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
                if(m_write_addr_seq.m_constraint_snoop == 1)
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
                if(get_addr_from_test)
                    m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen   == m_axlen;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid    == use_awid;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.coh_domain == is_coh;
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr  == m_iocache_addr_gen.addr;
                // For directed test case purposes
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.useFullCL == use_full_cl;
                if(use_burst_incr) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst==AXIINCR;
                if(use_burst_wrap) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst==AXIWRAP;

            <% if (obj.wSecurityAttribute > 0) { %>                                             
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]==m_write_addr_seq.m_ace_wr_addr_chnl_security;
            <% } %>
            };
        end
        if (!success) begin
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize write address packet in axi_master_writeunique_seq"), UVM_NONE);
        end

        `uvm_info("ACE BFM SEQ",$sformatf("WR snooptype %0s address 0x%0x len 0x%0x" ,
                                m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name() ,
                                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen), UVM_HIGH);

        success = m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
        if (!success) begin
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize write data packet in axi_master_writeunique_seq"), UVM_NONE);
        end
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        
        if(get_data_from_test) begin
            foreach(m_data_from_test[idx]) begin
                m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[idx] = m_data_from_test[idx];
                m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[idx] = 64'hffffffff;  //Assigning to max value
            end
        end else begin
            m_ace_cache_model.give_data_for_ace_req(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_ace_wr_addr_chnl_snoop, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize, m_write_data_seq.m_seq_item.m_write_data_pkt.wdata, m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb
<% if (obj.wSecurityAttribute > 0) { %>                                             
               ,m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]
<% } %>                                                
            );

        end
        
        m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;
        m_write_addr_seq.should_randomize = 0;
        m_write_data_seq.should_randomize = 0;
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        s_wr_addr[core_id].get();
        s_wr_data[core_id].get();
        fork 
            begin
                m_write_addr_seq.return_response(m_seq_item0, m_write_addr_chnl_seqr);
            end
            begin
                // Nothing goes on write data channel for evicts
                if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== EVCT &&
                    m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== STASHONCEUNQ &&		    
                    m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== STASHONCESHARED
                ) begin
                    m_write_data_seq.return_response(m_seq_item1, m_write_data_chnl_seqr);
                end
            end
        join
        s_wr[core_id].put();
        wait_till_awid_latest(m_write_addr_seq.m_seq_item.m_write_addr_pkt);
        m_write_resp_seq.should_randomize = 0;
        m_write_resp_seq.m_seq_item       = m_seq_item0;
        m_write_resp_seq.return_response(m_seq_item0, m_write_resp_chnl_seqr);
        delete_ott_entry(m_write_addr_seq.m_seq_item.m_write_addr_pkt);
        num_req++;
    end while (num_req < k_num_write_req);
endtask : body

endclass : axi_master_writeunique_seq




//******************************************************************************
// Section3: axi_master_iocache_pipelined_seq
// Purpose : Generates random readOnce and writeUnique transactions.
//******************************************************************************

class axi_master_iocache_pipelined_seq extends uvm_sequence #(axi_rd_seq_item);

    `uvm_object_param_utils(axi_master_iocache_pipelined_seq)
    
    // Read and write sequences
    axi_master_readonce_seq  m_read_seq[];
    axi_master_writeunique_seq m_write_seq[];
    
    // Read and write sequencers
    axi_read_addr_chnl_sequencer  m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer  m_read_data_chnl_seqr;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;

    ace_cache_model               m_ace_cache_model;

    // Knobs


    int k_num_read_req              = 100;
    int k_num_write_req             = 100;
    int k_num_iocache_addr;
    bit k_iocache_perf_mode;

    bit en_trace_file_mode;

    int trace_rd_addr[$];
    int trace_rd_bytes[$];

    int trace_wr_addr[$];
    int trace_wr_bytes[$];

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_master_iocache_pipelined_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    m_read_seq  = new[k_num_read_req];
    m_write_seq = new[k_num_write_req];
    
    for (int i = 0; i < k_num_read_req; i++) begin

        m_read_seq[i]                       = axi_master_readonce_seq::type_id::create($sformatf("m_read_seq_%0d", i));
        m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        m_read_seq[i].k_num_read_req        = 1;
        m_read_seq[i].wt_num_of_rd_partial  = 0;
        m_read_seq[i].wt_num_of_rd_full     = 5;
        m_read_seq[i].gen_io_cache_addr     = 1;

        if(en_trace_file_mode && ((trace_rd_addr.size()>0) && (trace_rd_bytes.size()>0))) begin
            m_read_seq[i].en_trace_file_mode = 1;
            m_read_seq[i].m_addr             = trace_rd_addr[i];
            m_read_seq[i].no_of_bytes        = trace_rd_bytes[i];
        end

    end

    for (int i = 0; i < k_num_write_req; i++) begin
        m_write_seq[i]                        = axi_master_writeunique_seq::type_id::create($sformatf("m_write_seq_%0d", i));
        m_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        m_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        m_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
        m_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
        m_write_seq[i].k_num_write_req        = 1;
        m_write_seq[i].wt_num_of_wr_partial   = 0;
        m_write_seq[i].wt_num_of_wr_full      = 5;
        m_write_seq[i].gen_io_cache_addr      = 1;

        if(en_trace_file_mode && ((trace_wr_addr.size()>0) && (trace_wr_bytes.size()>0))) begin
            m_write_seq[i].en_trace_file_mode     = 1;
            m_write_seq[i].m_addr                 = trace_wr_addr[i];
            m_write_seq[i].no_of_bytes            = trace_wr_bytes[i];
        end
    end

    for (int i = 0; i < k_num_read_req; i++) begin
        fork
            automatic int j = i;
            begin
                m_read_seq[j].start(null);
            end
        join_none
    end
    for (int i = 0; i < k_num_write_req; i++) begin
        fork
            automatic int j = i;
            begin
                m_write_seq[j].start(null);
            end
        join_none
    end
    wait fork;
endtask : body

endclass : axi_master_iocache_pipelined_seq


//******************************************************************************
// Section4: iocache_read_hits_seq
// Purpose : 
//******************************************************************************

class iocache_read_hits_seq extends axi_master_iocache_pipelined_seq;

    `uvm_object_param_utils(iocache_read_hits_seq)
    
    int k_num_read_req              = 100;


//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "iocache_read_hits_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    m_read_seq  = new[1];
    
    m_read_seq[0]                       = axi_master_readonce_seq::type_id::create($sformatf("m_read_seq_%0d", 0));
    m_read_seq[0].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
    m_read_seq[0].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
    m_read_seq[0].m_ace_cache_model     = m_ace_cache_model;
    m_read_seq[0].k_num_read_req        = this.k_num_read_req;
    m_read_seq[0].wt_num_of_rd_partial  = 0;
    m_read_seq[0].wt_num_of_rd_full     = 5;
    m_read_seq[0].en_read_hits          = 1;
    m_read_seq[0].en_perf_mode          = 1;
    
    m_read_seq[0].start(null);

endtask : body

endclass : iocache_read_hits_seq


//******************************************************************************
// Section5: iocache_write_hits_seq
// Purpose : 
//******************************************************************************

class iocache_write_hits_seq extends axi_master_iocache_pipelined_seq;

    `uvm_object_param_utils(iocache_write_hits_seq)
    
    // Knobs
    int k_num_write_req             = 100;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "iocache_write_hits_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body; 
    m_write_seq = new[1];
    
    m_write_seq[0]                        = axi_master_writeunique_seq::type_id::create($sformatf("m_write_seq_%0d", 0));
    m_write_seq[0].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
    m_write_seq[0].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
    m_write_seq[0].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
    m_write_seq[0].m_ace_cache_model      = m_ace_cache_model;
    m_write_seq[0].k_num_write_req        = k_num_write_req;
    m_write_seq[0].wt_num_of_wr_partial   = 0;
    m_write_seq[0].wt_num_of_wr_full      = 5;
    m_write_seq[0].en_write_hits          = 1;
    m_write_seq[0].en_perf_mode           = 1;

    m_write_seq[0].start(null);
endtask : body

endclass : iocache_write_hits_seq


//******************************************************************************
// Section6: iocache_read_miss_seq
// Purpose : 
//******************************************************************************

class iocache_read_miss_seq extends axi_master_iocache_pipelined_seq;

    `uvm_object_param_utils(iocache_read_miss_seq)
    
    int k_num_read_req              = 100;


//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "iocache_read_miss_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    m_read_seq  = new[k_num_read_req];
    
    for (int i = 0; i < k_num_read_req; i++) begin
        m_read_seq[i]                       = axi_master_readonce_seq::type_id::create($sformatf("m_read_seq_%0d", i));
        m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        m_read_seq[i].k_num_read_req        = 1;
        m_read_seq[i].wt_num_of_rd_partial  = 0;
        m_read_seq[i].wt_num_of_rd_full     = 5;
    end
    
    for (int i = 0; i < k_num_read_req; i++) begin
        fork
            automatic int j = i;
            begin
                m_read_seq[j].start(null);
            end
        join_none
    end
    wait fork;
endtask : body

endclass : iocache_read_miss_seq


//******************************************************************************
// Section7: iocache_write_miss_seq
// Purpose : 
//******************************************************************************
class iocache_write_miss_seq extends axi_master_iocache_pipelined_seq;

    `uvm_object_param_utils(iocache_write_miss_seq)
    
    // Knobs
    int k_num_write_req             = 100;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "iocache_write_miss_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body; 
    m_write_seq = new[k_num_write_req];
    
    for (int i = 0; i < k_num_write_req; i++) begin
        m_write_seq[i]                        = axi_master_writeunique_seq::type_id::create($sformatf("m_write_seq_%0d", i));
        m_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        m_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        m_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
        m_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
        m_write_seq[i].k_num_write_req        = 1;
        m_write_seq[i].wt_num_of_wr_partial   = 0;
        m_write_seq[i].wt_num_of_wr_full      = 5;
    end

    for (int i = 0; i < k_num_write_req; i++) begin
        fork
            automatic int j = i;
            begin
                m_write_seq[j].start(null);
            end
        join_none
    end
    wait fork;
endtask : body

endclass : iocache_write_miss_seq


//******************************************************************************
// Section8: iocache_read_evict_seq
// Purpose : 
//******************************************************************************

class iocache_read_evict_seq extends axi_master_iocache_pipelined_seq;

    `uvm_object_param_utils(iocache_read_evict_seq)
    
    int k_num_read_req              = 100;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "iocache_read_evict_seq");
    super.new(name);
endfunction : new
 
//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    m_read_seq  = new[k_num_read_req];
    
    for (int i = 0; i < k_num_read_req; i++) begin
        m_read_seq[i]                       = axi_master_readonce_seq::type_id::create($sformatf("m_read_seq_%0d", i));
        m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        m_read_seq[i].k_num_read_req        = 1;
        m_read_seq[i].wt_num_of_rd_partial  = 0;
        m_read_seq[i].wt_num_of_rd_full     = 5;
        m_read_seq[i].en_read_evicts        = 1;
        m_read_seq[i].gen_io_cache_addr     = 1;
    end
   
    for (int i = 0; i < k_num_read_req-2; i++) begin
        fork
            automatic int j = i;
            begin
                m_read_seq[j].start(null);
            end
        join_none
    end
    wait fork;

    m_read_seq[k_num_read_req-2].start(null);
    m_read_seq[k_num_read_req-1].start(null);

endtask : body

endclass : iocache_read_evict_seq

//******************************************************************************
// Section9: iocache_write_evict_seq
// Purpose : 
//******************************************************************************

class iocache_write_evict_seq extends axi_master_iocache_pipelined_seq;

    `uvm_object_param_utils(iocache_write_evict_seq)
    
    // Knobs
    int k_num_write_req             = 100;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "iocache_write_evict_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body; 
    m_write_seq = new[k_num_write_req];
    
    for (int i = 0; i < k_num_write_req; i++) begin
        m_write_seq[i]                        = axi_master_writeunique_seq::type_id::create($sformatf("m_write_seq_%0d", i));
        m_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        m_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        m_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
        m_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
        m_write_seq[i].k_num_write_req        = 1;
        m_write_seq[i].wt_num_of_wr_partial   = 0;
        m_write_seq[i].wt_num_of_wr_full      = 5;
        m_write_seq[i].en_write_evicts        = 1;
        m_write_seq[i].gen_io_cache_addr     = 1;
    end

    for (int i = 0; i < k_num_write_req-1; i++) begin
        fork
            automatic int j = i;
            begin
                m_write_seq[j].start(null);
            end
        join_none
    end
    wait fork;
    
    m_write_seq[k_num_write_req-1].start(null);
endtask : body

endclass : iocache_write_evict_seq


//******************************************************************************
// Section: axi_master_iocache_pipelined_seq
// Purpose : 
//******************************************************************************

class axi_master_iocache_warmup_perf_seq extends uvm_sequence #(axi_rd_seq_item);

    `uvm_object_param_utils(axi_master_iocache_warmup_perf_seq)
    
    // Read and write sequences
    axi_master_readonce_seq  m_read_seq[];
    axi_master_writeunique_seq m_write_seq[];
    
    // Read and write sequencers
    axi_read_addr_chnl_sequencer  m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer  m_read_data_chnl_seqr;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;

    ace_cache_model               m_ace_cache_model;

    axi_axaddr_t     iocache_perf_addr_q[$];
    axi_axaddr_t     iocache_perf_addr;
    axi_axaddr_t     cpy_addr;
    axi_axaddr_t     addr;

    ace_command_types_enum_t m_ace_wr_addr_chnl_snoop;
    ace_command_types_enum_t m_ace_rd_addr_chnl_snoop;

    bit [<%=obj.wSecurityAttribute%>-1:0]               m_ace_addr_chnl_security;

    // Knobs

    int k_num_read_req              = 100;
    int k_num_write_req             = 100;
    int k_num_iocache_addr;
    bit k_iocache_perf_mode;
    addr_trans_mgr m_addr_mgr;									     


//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_master_iocache_warmup_perf_seq");
    super.new(name);
    m_addr_mgr = addr_trans_mgr::get_instance();
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    
   //Generate Unique address for the entire cache warm-up 

    m_ace_rd_addr_chnl_snoop = RDONCE;
    m_ace_cache_model.give_addr_for_io_cache(m_ace_rd_addr_chnl_snoop,
        iocache_perf_addr
        <% if (obj.wSecurityAttribute > 0) { %>                                             
        ,m_ace_addr_chnl_security
        <%}%>                                                
    );

    iocache_perf_addr[SYS_wSysCacheline-1:0] = '0;
   
   <% if(obj.isBridgeInterface && obj.useIoCache) { %>  
   <% if(obj.testBench == "cbi"){%>
    for(int i =0; i<<%=obj.nSets%>;i++) begin
    <%}else{%>
    for(int i =0; i<<%=obj.nSets%>/2;i++) begin
    <%}%>
        <% if(obj.nSets>1) {%>
         cpy_addr = m_addr_mgr.gen_coh_addr(
             <%=obj.FUnitId%>, 1, .set_index(i), .core_id(core_id));
        <%}else{%>
            cpy_addr = iocache_perf_addr;
        <%}%>
        for(int m=0; m<<%=obj.nWays%>;m++) begin
            //addr = addrMgrConst::set_ncbu_tag_bits(cpy_addr,m,<%=obj.SlvId%>);
            iocache_perf_addr_q.push_back(addr);
        end
    end
    <%}%>

    if(iocache_perf_addr_q.size()>0) begin
        foreach(iocache_perf_addr_q[i]) begin
            `uvm_info("IO-$-SEQ", $psprintf("Generating Addr:%0h", iocache_perf_addr_q[i]),UVM_MEDIUM)
        end
    end else 
        `uvm_error("IO-$-SEQ", "No Address generated to warm up the cache")
    


   //Warm Up the Cache 
   if((k_num_write_req>0) || ((k_num_write_req>0) &&  (k_num_read_req>0))) begin
       m_write_seq  = new[iocache_perf_addr_q.size()];
       for (int i = 0; i < iocache_perf_addr_q.size(); i++) begin
           m_write_seq[i]                        = axi_master_writeunique_seq::type_id::create($sformatf("m_write_seq_%0d", i));
           m_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
           m_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
           m_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
           m_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
           m_write_seq[i].k_num_write_req        = 1;
           m_write_seq[i].wt_num_of_wr_partial   = 0;
           m_write_seq[i].wt_num_of_wr_full      = 5;
           m_write_seq[i].gen_io_cache_addr      = 0;
           m_write_seq[i].en_perf_mode           = 1;
           m_write_seq[i].m_addr                 = iocache_perf_addr_q[i];
       end

       for (int i = 0; i < iocache_perf_addr_q.size(); i++) begin
           fork
               automatic int j = i;
               begin
                   m_write_seq[j].start(null);
               end
           join_none
       end
       wait fork;
   end
   else if(k_num_read_req>0) begin

       m_read_seq  = new[iocache_perf_addr_q.size()];
       for (int i = 0; i < iocache_perf_addr_q.size(); i++) begin
           m_read_seq[i]                       = axi_master_readonce_seq::type_id::create($sformatf("m_read_seq_%0d", i));
           m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
           m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
           m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
           m_read_seq[i].k_num_read_req        = 1;
           m_read_seq[i].wt_num_of_rd_partial  = 0;
           m_read_seq[i].wt_num_of_rd_full     = 5;
           m_read_seq[i].gen_io_cache_addr     = 0;
           m_read_seq[i].en_perf_mode          = 1;
           m_read_seq[i].m_addr                = iocache_perf_addr_q[i];

       end

       for (int i = 0; i < iocache_perf_addr_q.size(); i++) begin
           fork
               automatic int j = i;
               begin
                   m_read_seq[j].start(null);
               end
           join_none
       end
       wait fork;
   end else  begin
       `uvm_error("IO-$-SEQ", "Number of read/write request variable not set")
   end

endtask : body

endclass : axi_master_iocache_warmup_perf_seq


//******************************************************************************
// Section: axi_master_iocache_pipelined_seq
// Purpose : 
//******************************************************************************

class axi_master_iocache_perf_seq extends uvm_sequence #(axi_rd_seq_item);

    `uvm_object_param_utils(axi_master_iocache_perf_seq)
    
    // Read and write sequences
    axi_master_readonce_seq  m_read_seq[];
    axi_master_writeunique_seq m_write_seq[];
    
    // Read and write sequencers
    axi_read_addr_chnl_sequencer  m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer  m_read_data_chnl_seqr;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;

    ace_cache_model               m_ace_cache_model;

    axi_axaddr_t     iocache_perf_addr_q[$];
    axi_axaddr_t     iocache_perf_miss_addr_q[$];
    axi_axaddr_t     iocache_miss_addr;
    axi_axaddr_t     iocache_perf_addr;
    axi_axaddr_t     cpy_addr;
    axi_axaddr_t     addr;

    ace_command_types_enum_t m_ace_wr_addr_chnl_snoop;
    ace_command_types_enum_t m_ace_rd_addr_chnl_snoop;

    bit [<%=obj.wSecurityAttribute%>-1:0]               m_ace_addr_chnl_security;

    // Knobs

    int k_num_read_req              = 10000;
    int k_num_write_req             = 2500;
    int k_num_iocache_addr;
    bit k_iocache_perf_mode;
    int k_num_read_miss;
    int k_num_write_miss;
 
    bit k_iocache_sys_perf_mode=1;
    int <%=obj.BlockId%>_k_iocache_rd_hit_perc=80;
    int <%=obj.BlockId%>_k_iocache_rd_miss_perc=20;
    
    int <%=obj.BlockId%>_k_iocache_wr_hit_perc=50;
    int <%=obj.BlockId%>_k_iocache_wr_miss_perc=50;

    int findq1[$];
    int findq2[$];
    int count;
    bit success;
    int hitIndex;
    int missIndex;



//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_master_iocache_perf_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    if(iocache_perf_addr_q.size()>0) begin
        foreach(iocache_perf_addr_q[i]) begin
            `uvm_info("IO-$-SEQ", $psprintf("Generating Addr:%0h", iocache_perf_addr_q[i]),UVM_MEDIUM)
        end
    end else 
        `uvm_error("IO-$-SEQ", "No Address generated to warm up the cache")
    
  
    if(!($value$plusargs("k_iocache_sys_perf_mode=%d",k_iocache_sys_perf_mode))) begin
        k_iocache_sys_perf_mode = 0;
    end

    if(!($value$plusargs("<%=obj.BlockId%>_k_iocache_rd_hit_perc=%d",<%=obj.BlockId%>_k_iocache_rd_hit_perc))) begin
        <%=obj.BlockId%>_k_iocache_rd_hit_perc = 0;
    end

    if(!($value$plusargs("<%=obj.BlockId%>_k_iocache_wr_hit_perc=%d",<%=obj.BlockId%>_k_iocache_wr_hit_perc))) begin
        <%=obj.BlockId%>_k_iocache_wr_hit_perc = 0;
    end



   if(k_iocache_sys_perf_mode) begin
       int number_of_misses_per_index;
        <%=obj.BlockId%>_k_iocache_rd_miss_perc = 100 - <%=obj.BlockId%>_k_iocache_rd_hit_perc;
        <%=obj.BlockId%>_k_iocache_wr_miss_perc = 100 - <%=obj.BlockId%>_k_iocache_wr_hit_perc;
        

        k_num_read_miss  =  (<%=obj.BlockId%>_k_iocache_rd_miss_perc * k_num_read_req)/100;
        k_num_write_miss =  (<%=obj.BlockId%>_k_iocache_wr_miss_perc * k_num_write_req)/100;

        `uvm_info("IO-$-SEQ", $psprintf("Enabling IO-$ system performance for mobileye with rd_hit_perc:%0d and wr_hit_perc:%0d", 
                            <%=obj.BlockId%>_k_iocache_rd_hit_perc,<%=obj.BlockId%>_k_iocache_wr_hit_perc),UVM_LOW)

        m_ace_cache_model.give_addr_for_io_cache(m_ace_rd_addr_chnl_snoop,
            iocache_perf_addr
            <% if (obj.wSecurityAttribute > 0) { %>                                             
            ,m_ace_addr_chnl_security
            <%}%>                                                
        );
        // Adding 100 extra addresses generated just in case
        <% if(obj.isBridgeInterface && obj.useIoCache) { %>  
            number_of_misses_per_index = ((k_num_read_miss + k_num_write_miss + <%=obj.nSets%>/2)/(<%=obj.nSets%>/2));
            for(int i = <%=obj.nSets%>/2 + 1; i<<%=obj.nSets%>;i++) begin
                for(int m=0; m<number_of_misses_per_index;m++) begin
                    setIoCacheIndex(iocache_perf_addr,i,cpy_addr);
                    setIoCacheTag(cpy_addr,m,addr);
                    iocache_perf_miss_addr_q.push_back(addr);
                end
            end
        <%}%>

 /*         for(int i=0;i<(k_num_read_miss+k_num_write_miss);i++) begin
            success = 0;
            count   = 0;
            do begin
                //Generate Unique address for the entire cache warm-up 
                axi_axaddr_t addr_arr[] = '{};
                foreach (iocache_perf_addr_q[i]) begin
                    addr_arr = new[addr_arr.size() + 1] (addr_arr);
                    addr_arr[addr_arr.size() - 1] = iocache_perf_addr_q[i];
                end
                foreach (iocache_perf_miss_addr_q[i]) begin
                    addr_arr = new[addr_arr.size() + 1] (addr_arr);
                    addr_arr[addr_arr.size() - 1] = iocache_perf_miss_addr_q[i];
                end




                m_ace_cache_model.give_addr_for_io_cache(m_ace_rd_addr_chnl_snoop,
                    iocache_perf_addr
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        ,m_ace_addr_chnl_security
                    <%}%>                                                
                    , addr_arr
                );

                iocache_perf_addr[SYS_wSysCacheline-1:0] = '0;
                           // CHIRAG Edit here                 iocache_perf_addr[SYS_wSysCacheline-1:0] = '0;
                findq1 = iocache_perf_addr_q.find_index(x) with (x == iocache_perf_addr);
                findq2 = iocache_perf_miss_addr_q.find_index(x) with (x == iocache_perf_addr);

                //hitIndex   = mapAddrToIoCacheIndex(iocache_perf_addr_q[0]);
                //missIndex  = mapAddrToIoCacheIndex(iocache_perf_addr);


                if((findq1.size() == 0) && (findq2.size() == 0) 
                    //&& (hitIndex != missIndex)
                ) begin
                    success = 1'b1;
                    iocache_perf_miss_addr_q.push_back(iocache_perf_addr);
                end 
                else begin 
                    count = count + 1;
                    foreach (addr_arr[i]) begin
                        `uvm_info("CHIRAG-DEBUG", $sformatf("ADDR ARR Addr[%0d]: 0x%0x", i, addr_arr[i]), UVM_NONE)
                    end
                    foreach (iocache_perf_addr_q[i]) begin
                        `uvm_info("CHIRAG-DEBUG", $sformatf("PERF ADDR Addr[%0d]: 0x%0x", i, iocache_perf_addr_q[i]), UVM_NONE)
                    end
                    foreach (iocache_perf_miss_addr_q[i]) begin
                        `uvm_info("CHIRAG-DEBUG", $sformatf("PERF MISS Addr[%0d]: 0x%0x", i, iocache_perf_miss_addr_q[i]), UVM_NONE)
                    end
                    `uvm_error("CHIRAG-DEBUG", $sformatf("What you doing bro? 0x%0x", iocache_perf_addr));
                end
                if(count > 500) begin
                    `uvm_error("IO-$-SEQ", $sformatf("Performance sequence tried to generate a new miss addr 500 times but couldn't get a new addr for loop count %0d", i))
                end
            end while(!success);
        end
        */

        if(iocache_perf_miss_addr_q.size()>0) begin
            foreach(iocache_perf_miss_addr_q[i]) begin
                `uvm_info("IO-$-SEQ", $psprintf("Generating Miss Addr:%0h", iocache_perf_miss_addr_q[i]),UVM_MEDIUM)
            end
        end else 
            `uvm_error("IO-$-SEQ", "No Address generated in the IO cache miss addr queue ")
   end

    
    
    //Now Let the traffic start
    m_read_seq  = new[k_num_read_req];
    m_write_seq = new[k_num_write_req];


    for (int i = 0; i < k_num_read_req; i++) begin

        m_read_seq[i]                       = axi_master_readonce_seq::type_id::create($sformatf("m_read_seq_%0d", i));
        m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        m_read_seq[i].k_num_read_req        = 1;
        m_read_seq[i].wt_num_of_rd_partial  = 0;
        m_read_seq[i].wt_num_of_rd_full     = 5;
        m_read_seq[i].gen_io_cache_addr     = 0;
        m_read_seq[i].en_perf_mode          = 1;

        if(k_iocache_sys_perf_mode) begin
            randcase 
                <%=obj.BlockId%>_k_iocache_rd_hit_perc  : iocache_perf_addr = iocache_perf_addr_q[i%(iocache_perf_addr_q.size() - 2)]; 
                <%=obj.BlockId%>_k_iocache_rd_miss_perc : iocache_perf_addr = iocache_perf_miss_addr_q.pop_front();
            endcase
            m_read_seq[i].m_addr                = iocache_perf_addr;
        end else begin
            m_read_seq[i].m_addr                = iocache_perf_addr_q[$urandom_range(1,iocache_perf_addr_q.size())];
        end
    end

    for (int i = 0; i < k_num_write_req; i++) begin
        m_write_seq[i]                        = axi_master_writeunique_seq::type_id::create($sformatf("m_write_seq_%0d", i));
        m_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        m_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        m_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
        m_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
        m_write_seq[i].k_num_write_req        = 1;
        m_write_seq[i].wt_num_of_wr_partial   = 0;
        m_write_seq[i].wt_num_of_wr_full      = 5;
        m_write_seq[i].gen_io_cache_addr      = 0;
        m_write_seq[i].en_perf_mode           = 1;

        if(k_iocache_sys_perf_mode) begin
            randcase 
                <%=obj.BlockId%>_k_iocache_wr_hit_perc  : iocache_perf_addr = iocache_perf_addr_q[(i+200)%(iocache_perf_addr_q.size() - 2)]; 
                <%=obj.BlockId%>_k_iocache_wr_miss_perc : iocache_perf_addr = iocache_perf_miss_addr_q.pop_front();
            endcase
            m_write_seq[i].m_addr                = iocache_perf_addr;
        end else begin
            m_write_seq[i].m_addr                = iocache_perf_addr_q[$urandom_range(1,iocache_perf_addr_q.size())];
        end

    end

    for (int i = 0; i < k_num_read_req; i++) begin
        fork
            automatic int j = i;
            begin
                m_read_seq[j].start(null);
            end
        join_none
    end
    for (int i = 0; i < k_num_write_req; i++) begin
        fork
            automatic int j = i;
            begin
                m_write_seq[j].start(null);
            end
        join_none
    end
    wait fork;


endtask : body

endclass : axi_master_iocache_perf_seq

//******************************************************************************
// Section: axi_master_iocache_dynamic_perf_seq
// Purpose : 
//******************************************************************************

class axi_master_iocache_dynamic_perf_seq extends uvm_sequence #(axi_rd_seq_item);

    `uvm_object_param_utils(axi_master_iocache_dynamic_perf_seq)
    
    // Read and write sequences
    axi_master_readonce_seq  m_read_seq[];
    axi_master_writeunique_seq m_write_seq[];
    
    // Read and write sequencers
    axi_read_addr_chnl_sequencer  m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer  m_read_data_chnl_seqr;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;

    ace_cache_model               m_ace_cache_model;

    axi_axaddr_t          iocache_perf_addr_q[$];
    axi_axaddr_t          iocache_perf_miss_q[$];
    axi_axaddr_t          iocache_perf_hit_q[$];
    rand axi_axaddr_t     iocache_miss_addr;
    axi_axaddr_t          iocache_perf_addr;
    axi_axaddr_t          cpy_addr;
    axi_axaddr_t          addr;

    ace_command_types_enum_t m_ace_wr_addr_chnl_snoop;
    ace_command_types_enum_t m_ace_rd_addr_chnl_snoop;

    bit [<%=obj.wSecurityAttribute%>-1:0]               m_ace_addr_chnl_security;

    // Knobs

    int k_num_read_req              = 10000;
    int k_num_write_req             = 2500;
    int k_num_iocache_addr;
    bit k_iocache_perf_mode;
    int k_num_read_miss;
    int k_num_write_miss;
 
    bit k_iocache_sys_perf_mode=1;
    int <%=obj.BlockId%>_k_iocache_rd_hit_perc=80;
    int <%=obj.BlockId%>_k_iocache_rd_miss_perc=20;
    
    int <%=obj.BlockId%>_k_iocache_wr_hit_perc=50;
    int <%=obj.BlockId%>_k_iocache_wr_miss_perc=50;

    int findq1[$];
    int findq2[$];
    int count;
    bit success;
    int hitIndex;
    int missIndex;
    int cnt;
    addr_trans_mgr m_addr_mgr;


//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_master_iocache_dynamic_perf_seq");
    super.new(name);

    m_addr_mgr = addr_trans_mgr::get_instance();
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    if(iocache_perf_addr_q.size()>0) begin
        foreach(iocache_perf_addr_q[i]) begin
            `uvm_info("IO-$-SEQ", $psprintf("Warmup Addr:%0h", iocache_perf_addr_q[i]),UVM_MEDIUM)
        end
    end else 
        `uvm_error("IO-$-SEQ", "No Address generated to warm up the cache")

   <% if(obj.isBridgeInterface && obj.useIoCache) { %>  
    iocache_perf_addr =  iocache_perf_addr_q[0];
    for(int i =0; i<<%=obj.nSets/2%>;i++) begin
        <% if(obj.nSets>1) {%>
         cpy_addr = m_addr_mgr.gen_coh_addr(
             <%=obj.FUnitId%>, 1, .set_index(i));
        <%}else{%>
            cpy_addr = iocache_perf_addr;
        <%}%>
        for(int m=<%=obj.nWays%>; m<1000;m++) begin
            //addr = addrMgrConst::set_ncbu_tag_bits(cpy_addr,m,<%=obj.SlvId%>);
            iocache_perf_miss_q.push_back(addr);
        end
    end
    for(int i=<%=obj.nSets/2%>; i<<%=obj.nSets%>;i++) begin
        <% if(obj.nSets>1) {%>

         cpy_addr = m_addr_mgr.gen_coh_addr(
             <%=obj.FUnitId%>, 1, .set_index(i));
        <%}else{%>
            cpy_addr = iocache_perf_addr;
        <%}%>
        for(int m=0; m<<%=obj.nWays%>;m++) begin
            //addr = addrMgrConst::set_ncbu_tag_bits(cpy_addr,m,<%=obj.SlvId%>);
            iocache_perf_hit_q.push_back(addr);
        end
    end

    <%}%>

    if(iocache_perf_hit_q.size()>0) begin
        foreach(iocache_perf_hit_q[i]) begin
<%if(obj.NO_ADDR_MGR === undefined) { %>
            hitIndex = m_addr_mgr.get_set_index(iocache_perf_hit_q[i],
                <%=obj.AiuInfo[obj.Id].FUnitId%>, 1);
<% } %>
            `uvm_info("IO-$-SEQ", $psprintf("Generating Hit Addr:%0h Index:%0d", iocache_perf_hit_q[i], hitIndex),UVM_MEDIUM)
        end
    end else 
        `uvm_error("IO-$-SEQ", "No Address generated to warm up the cache")
    
  
    if(iocache_perf_miss_q.size()>0) begin
        foreach(iocache_perf_miss_q[i]) begin
<%if(obj.NO_ADDR_MGR === undefined) { %>
            missIndex = m_addr_mgr.get_set_index(iocache_perf_miss_q[i],
                <%=obj.AiuInfo[obj.Id].FUnitId%>,
                1);
<% } %>
            `uvm_info("IO-$-SEQ", $psprintf("Generating Miss Addr:%0h Index:%0d ", iocache_perf_miss_q[i], missIndex),UVM_MEDIUM)
        end
    end else 
        `uvm_error("IO-$-SEQ", "No Address generated to warm up the cache")
    
    
    if(!($value$plusargs("<%=obj.BlockId%>_k_iocache_rd_hit_perc=%d",<%=obj.BlockId%>_k_iocache_rd_hit_perc))) begin
        //<%=obj.BlockId%>_k_iocache_rd_hit_perc = 0;
    end

    if(!($value$plusargs("<%=obj.BlockId%>_k_iocache_rd_miss_perc=%d",<%=obj.BlockId%>_k_iocache_rd_miss_perc))) begin
        //<%=obj.BlockId%>_k_iocache_rd_hit_perc = 0;
    end

    if(!($value$plusargs("<%=obj.BlockId%>_k_iocache_wr_hit_perc=%d",<%=obj.BlockId%>_k_iocache_wr_hit_perc))) begin
        //<%=obj.BlockId%>_k_iocache_wr_hit_perc = 0;
    end

    if(!($value$plusargs("<%=obj.BlockId%>_k_iocache_wr_miss_perc=%d",<%=obj.BlockId%>_k_iocache_wr_miss_perc))) begin
        //<%=obj.BlockId%>_k_iocache_wr_hit_perc = 0;
    end
    
    `uvm_info("AXI-PERF-SEQ", $psprintf("Read Hit Perc:%0d, Read Miss Perc:%0d, Write Hit Perc:%0d, Write Miss Perc:%0d", 
                                       <%=obj.BlockId%>_k_iocache_rd_hit_perc, <%=obj.BlockId%>_k_iocache_rd_miss_perc, 
                                       <%=obj.BlockId%>_k_iocache_wr_hit_perc, <%=obj.BlockId%>_k_iocache_wr_miss_perc),
                                       UVM_NONE)
                                        
    //Now Let the traffic start
    m_read_seq  = new[k_num_read_req];
    m_write_seq = new[k_num_write_req];

    for (int i = 0; i < k_num_read_req; i++) begin
        m_read_seq[i]                       = axi_master_readonce_seq::type_id::create($sformatf("m_read_seq_%0d", i));
        m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        m_read_seq[i].k_num_read_req        = 1;
        m_read_seq[i].wt_num_of_rd_partial  = 0;
        m_read_seq[i].wt_num_of_rd_full     = 5;
        m_read_seq[i].gen_io_cache_addr     = 0;
        m_read_seq[i].en_perf_mode          = 1;


        randcase 
            <%=obj.BlockId%>_k_iocache_rd_hit_perc  : iocache_perf_addr = iocache_perf_hit_q[$urandom_range(1,iocache_perf_hit_q.size())]; 
            <%=obj.BlockId%>_k_iocache_rd_miss_perc : begin 
                                                         if(iocache_perf_miss_q.size() > cnt) begin
                                                            iocache_perf_addr = iocache_perf_miss_q[cnt]; 
                                                            cnt++;
                                                         end else begin
                                                            `uvm_error("AXI-SEQ", $psprintf("Unable to generate address in read seq Queqe:%0d Cnt:%0d", iocache_perf_miss_q.size(), cnt))
                                                         end
                                                      end
        endcase

        m_read_seq[i].m_addr                = iocache_perf_addr;
    end
    for (int i = 0; i < k_num_write_req; i++) begin
        m_write_seq[i]                        = axi_master_writeunique_seq::type_id::create($sformatf("m_write_seq_%0d", i));
        m_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        m_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        m_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
        m_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
        m_write_seq[i].k_num_write_req        = 1;
        m_write_seq[i].wt_num_of_wr_partial   = 0;
        m_write_seq[i].wt_num_of_wr_full      = 5;
        m_write_seq[i].gen_io_cache_addr      = 0;
        m_write_seq[i].en_perf_mode           = 1;

        randcase 
            <%=obj.BlockId%>_k_iocache_wr_hit_perc  : iocache_perf_addr = iocache_perf_hit_q[$urandom_range(1,iocache_perf_hit_q.size())]; 
            <%=obj.BlockId%>_k_iocache_wr_miss_perc : begin
                                                         if(iocache_perf_miss_q.size() > cnt) begin
                                                            iocache_perf_addr = iocache_perf_miss_q[cnt]; 
                                                            cnt++;
                                                         end else begin
                                                            `uvm_error("AXI-SEQ", $psprintf("Unable to generate address in write seq Queqe:%0d Cnt:%0d", iocache_perf_miss_q.size(), cnt))
                                                         end
                                                       end
        endcase
        m_write_seq[i].m_addr                = iocache_perf_addr;
    end
    

    for (int i = 0; i < k_num_read_req; i++) begin
        fork
            automatic int j = i;
            begin
                m_read_seq[j].start(null);
            end
        join_none
    end
    for (int i = 0; i < k_num_write_req; i++) begin
        fork
            automatic int j = i;
            begin
                m_write_seq[j].start(null);
            end
        join_none
    end
    wait fork;

endtask : body

endclass : axi_master_iocache_dynamic_perf_seq


//******************************************************************************
// Section: axi_master_1beat_perf_seq
// Purpose : 
//******************************************************************************

class axi_master_1beat_perf_seq extends uvm_sequence #(axi_rd_seq_item);

    `uvm_object_param_utils(axi_master_1beat_perf_seq)
    
    // Read and write sequences
    axi_master_readonce_seq  m_read_seq[];
    axi_master_writeunique_seq m_write_seq[];
    
    // Read and write sequencers
    axi_read_addr_chnl_sequencer  m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer  m_read_data_chnl_seqr;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;

    ace_cache_model               m_ace_cache_model;

    axi_axaddr_t          iocache_perf_addr_q[$];
    axi_axaddr_t          bank_split_addr_q[$];
    axi_axaddr_t          iocache_perf_miss_q[$];
    axi_axaddr_t          iocache_perf_hit_q[$];
    rand axi_axaddr_t     iocache_miss_addr;
    axi_axaddr_t          iocache_perf_addr;
    axi_axaddr_t          cpy_addr;
    axi_axaddr_t          addr;

    ace_command_types_enum_t m_ace_wr_addr_chnl_snoop;
    ace_command_types_enum_t m_ace_rd_addr_chnl_snoop;

    bit [<%=obj.wSecurityAttribute%>-1:0]               m_ace_addr_chnl_security;

    // Knobs

    int k_num_read_req              = 10000;
    int k_num_write_req             = 2500;
    int k_num_iocache_addr;
    bit k_iocache_perf_mode;
    int k_num_read_miss;
    int k_num_write_miss;
 
    bit k_iocache_sys_perf_mode=1;
    int <%=obj.BlockId%>_k_iocache_rd_hit_perc=80;
    int <%=obj.BlockId%>_k_iocache_rd_miss_perc=20;
    
    int <%=obj.BlockId%>_k_iocache_wr_hit_perc=50;
    int <%=obj.BlockId%>_k_iocache_wr_miss_perc=50;

    int findq1[$];
    int findq2[$];
    int count=0;
    int flag_count=0;
    bit success;
    int hitIndex;
    int missIndex;
    int cnt;

    parameter CACHELINE_SIZE    = ((SYS_nSysCacheline*8)/
                                    WXDATA);


    parameter DATA_WIDTH        = WXDATA;
    parameter LINE_INDEX_LOW  = $clog2(DATA_WIDTH/8);
    parameter LINE_INDEX_HIGH = LINE_INDEX_LOW + $clog2(CACHELINE_SIZE) - 1;

    typedef bit [$clog2(<%=(obj.nSets > 1 ? obj.nSets : 1)%>)-1:0]  ccp_index;

    ccp_index val_q[$];
    ccp_index temp_indx;

    addr_trans_mgr m_addr_mgr;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_master_1beat_perf_seq");
    super.new(name);
    m_addr_mgr = addr_trans_mgr::get_instance();
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    if(iocache_perf_addr_q.size()>0) begin
        foreach(iocache_perf_addr_q[i]) begin
            `uvm_info("IO-$-SEQ", $psprintf("Warmup Addr:%0h", iocache_perf_addr_q[i]),UVM_MEDIUM)
        end
    end else begin 
        `uvm_error("IO-$-SEQ", "No Address generated to warm up the cache")
    end


    <% if(obj.nDataBanks > 1) {%>

        val_q = {4'd0, 4'd2, 4'd4, 4'd6};

        for(int i=0; i<<%=obj.nDataBanks%>;i++) begin
            temp_indx = val_q[i]; 
            cpy_addr = m_addr_mgr.gen_coh_addr(
                <%=obj.AiuInfo[obj.Id].FUnitId%>, 1, .set_index(temp_indx));
            bank_split_addr_q.push_back(cpy_addr);
        end
    <%}else{%>
        bank_split_addr_q =  iocache_perf_addr_q;
    <%}%>


  
    
    if(!($value$plusargs("<%=obj.BlockId%>_k_iocache_rd_hit_perc=%d",<%=obj.BlockId%>_k_iocache_rd_hit_perc))) begin
        //<%=obj.BlockId%>_k_iocache_rd_hit_perc = 0;
    end

    if(!($value$plusargs("<%=obj.BlockId%>_k_iocache_rd_miss_perc=%d",<%=obj.BlockId%>_k_iocache_rd_miss_perc))) begin
        //<%=obj.BlockId%>_k_iocache_rd_hit_perc = 0;
    end

    if(!($value$plusargs("<%=obj.BlockId%>_k_iocache_wr_hit_perc=%d",<%=obj.BlockId%>_k_iocache_wr_hit_perc))) begin
        //<%=obj.BlockId%>_k_iocache_wr_hit_perc = 0;
    end

    if(!($value$plusargs("<%=obj.BlockId%>_k_iocache_wr_miss_perc=%d",<%=obj.BlockId%>_k_iocache_wr_miss_perc))) begin
        //<%=obj.BlockId%>_k_iocache_wr_hit_perc = 0;
    end
    
    `uvm_info("AXI-PERF-SEQ", $psprintf("Read Hit Perc:%0d, Read Miss Perc:%0d, Write Hit Perc:%0d, Write Miss Perc:%0d", 
                                       <%=obj.BlockId%>_k_iocache_rd_hit_perc, <%=obj.BlockId%>_k_iocache_rd_miss_perc, 
                                       <%=obj.BlockId%>_k_iocache_wr_hit_perc, <%=obj.BlockId%>_k_iocache_wr_miss_perc),
                                       UVM_NONE)
                                        
    //Now Let the traffic start
    m_read_seq  = new[k_num_read_req];
    m_write_seq = new[k_num_write_req];


    for (int i = 0; i < int'(k_num_read_req); i++) begin
        //for (int j = 0; j < CACHELINE_SIZE; j++) begin
            m_read_seq[i]                       = axi_master_readonce_seq::type_id::create($sformatf("m_read_seq_%0d", i));
            m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
            m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
            m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
            m_read_seq[i].k_num_read_req        = 1;
            m_read_seq[i].wt_num_of_rd_partial  = 0;
            m_read_seq[i].wt_num_of_rd_full     = 5;
            m_read_seq[i].gen_io_cache_addr     = 0;
            m_read_seq[i].en_perf_mode          = 1;
            m_read_seq[i].en_1beat_seq          = 1;

            
            m_read_seq[i].m_addr                =  iocache_perf_addr_q[flag_count];
            //m_read_seq[count].m_addr[LINE_INDEX_HIGH:LINE_INDEX_LOW] = j;
            //count = count + 1;

        //end
            flag_count = flag_count + 1;

            if(flag_count >= iocache_perf_addr_q.size()) 
                flag_count = 0;
    end
    count      = 0;
    flag_count = 0;
    
    for (int i = 0; i < int'(k_num_write_req); i++) begin
            m_write_seq[i]                        = axi_master_writeunique_seq::type_id::create($sformatf("m_write_seq_%0d", i));
            m_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
            m_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
            m_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
            m_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
            m_write_seq[i].k_num_write_req        = 1;
            m_write_seq[i].wt_num_of_wr_partial   = 0;
            m_write_seq[i].wt_num_of_wr_full      = 5;
            m_write_seq[i].gen_io_cache_addr      = 0;
            m_write_seq[i].en_perf_mode           = 1;
            m_write_seq[i].en_1beat_seq            = 1;

            m_write_seq[i].m_addr                =  bank_split_addr_q[flag_count];


            flag_count = flag_count + 1;
            if(flag_count >= bank_split_addr_q.size()) 
                flag_count = 0;

    end
    

    for (int i = 0; i < k_num_read_req; i++) begin
        fork
            automatic int j = i;
            begin
                m_read_seq[j].start(null);
            end
        join_none
    end
    for (int i = 0; i < k_num_write_req; i++) begin
        fork
            automatic int j = i;
            begin
                m_write_seq[j].start(null);
            end
        join_none
    end
    wait fork;

endtask : body

endclass : axi_master_1beat_perf_seq

//******************************************************************************
// Section4: iocache_2beat_multi_line_seq
// Purpose : 
//******************************************************************************

class iocache_2beat_multi_line_seq extends axi_master_iocache_pipelined_seq;

    `uvm_object_param_utils(iocache_2beat_multi_line_seq)
    
    int k_num_read_req              = 100;


//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "iocache_2beat_multi_line_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    m_read_seq  = new[k_num_read_req];
    
    for (int i = 0; i < k_num_read_req; i++) begin
        m_read_seq[i]                       = axi_master_readonce_seq::type_id::create($sformatf("m_read_seq_%0d", 0));
        m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        m_read_seq[i].wt_num_of_rd_partial  = 0;
        m_read_seq[i].wt_num_of_rd_full     = 5;
        m_read_seq[i].en_2beat_multi_line   = 1;
        m_read_seq[i].k_num_read_req        = 1;
    end

    for (int i = 0; i < k_num_read_req; i++) begin
        fork
            automatic int j = i;
            begin
                m_read_seq[j].start(null);
            end
        join_none
    end
    

endtask : body

endclass : iocache_2beat_multi_line_seq



//******************************************************************************
// Section: axi_rd_wr_latency_seq
// Purpose : 
//******************************************************************************

class axi_rd_wr_latency_seq extends uvm_sequence #(axi_rd_seq_item);

    `uvm_object_param_utils(axi_rd_wr_latency_seq)
    
    // Read and write sequences
    axi_master_readonce_seq     m_read_seq[];
    axi_master_writeunique_seq  m_write_seq[];
    
    // Read and write sequencers
    axi_read_addr_chnl_sequencer  m_read_addr_chnl_seqr;
    axi_read_data_chnl_sequencer  m_read_data_chnl_seqr;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;

    ace_cache_model               m_ace_cache_model;

    axi_axaddr_t     iocache_perf_addr_q[$];
    axi_axaddr_t     iocache_perf_addr;
    axi_axaddr_t     cpy_addr;
    axi_axaddr_t     addr;
    
    ace_command_types_enum_t m_ace_wr_addr_chnl_snoop;
    ace_command_types_enum_t m_ace_rd_addr_chnl_snoop;

    bit [<%=obj.wSecurityAttribute%>-1:0]               m_ace_addr_chnl_security;

    // Knobs

    int k_num_read_req             = 2;
    int k_num_write_req            = 2;
    int k_num_iocache_addr;
    bit k_iocache_perf_mode;


    axi_rd_seq_item exp_seq_item;
    axi_rd_seq_item got_seq_item;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_rd_wr_latency_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
   
   //Generate Unique address for the entire cache warm-up 
    m_ace_cache_model.give_addr_for_io_cache(m_ace_rd_addr_chnl_snoop,
        iocache_perf_addr
        <% if (obj.wSecurityAttribute > 0) { %>                                             
        ,m_ace_addr_chnl_security
        <%}%>                                                
    );


       m_read_seq   = new[k_num_read_req];
       m_write_seq  = new[k_num_write_req];
       for (int i = 0; i < k_num_read_req; i++) begin
           m_read_seq[i]                       = axi_master_readonce_seq::type_id::create($sformatf("m_read_seq_%0d", i));
           m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
           m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
           m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
           m_read_seq[i].k_num_read_req        = 1;
           m_read_seq[i].wt_num_of_rd_partial  = 0;
           m_read_seq[i].wt_num_of_rd_full     = 5;
           m_read_seq[i].gen_io_cache_addr     = 0;
           m_read_seq[i].en_perf_mode          = 1;
           m_read_seq[i].m_addr                = iocache_perf_addr;
        end

       for (int i = 0; i < k_num_write_req; i++) begin
           m_write_seq[i]                        = axi_master_writeunique_seq::type_id::create($sformatf("m_write_seq_%0d", i));
           m_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
           m_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
           m_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
           m_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
           m_write_seq[i].k_num_write_req        = 1;
           m_write_seq[i].wt_num_of_wr_partial   = 0;
           m_write_seq[i].wt_num_of_wr_full      = 5;
           m_write_seq[i].gen_io_cache_addr      = 0;
           m_write_seq[i].en_perf_mode           = 1;
           m_write_seq[i].m_addr                 = iocache_perf_addr;
        end

   
        if(k_num_read_req>0) begin
            m_read_seq[0].start(null);
            //repeat (1000) begin
            //    @(posedge aiu_tb_top.tb_clk);
            //end
            
            for (int i = 1; i < k_num_read_req; i++) begin
                fork
                    automatic int j = i;
                    begin
                        m_read_seq[j].start(null);
                    end
                join_none
            end
            wait fork;
        end 

        if(k_num_write_req>0) begin
            m_write_seq[0].start(null);
            //repeat (1000) begin
            //    @(posedge aiu_tb_top.tb_clk);
            //end
            for (int i = 1; i < k_num_write_req; i++) begin
                fork
                    automatic int j = i;
                    begin
                        m_write_seq[j].start(null);
                    end
                join_none
            end
            wait fork;
        end 
        
endtask : body

endclass : axi_rd_wr_latency_seq



<% } %>

<% if(obj.Block === 'aiu' || obj.Block === 'io_aiu'  || (obj.Block === 'mem' && obj.is_master === 1)) { %>
////////////////////////////////////////////////////////////////////////////////
//
// AXI Mutex Sequence
// It is extention of Exclucsive sequence where Data recived is compared to
// check if the cacheline is locked or unlocked. If locked then seq restarts
// itself by reperforming ex-load
// anippuleti (11/11/2016) Added more support to use it in system level.
//                         concerto_inhouse_mutex_basic_test. Refer to knobs
//                         get_addr_from_test
////////////////////////////////////////////////////////////////////////////////

class axi_mutex_seq extends axi_master_exclusive_seq;

    `uvm_object_param_utils(axi_mutex_seq)

    //Exclusive time out plus-arg controlled
    //Random Weights
    int wt_ace_rdcln;
    int wt_ace_rdshrd;
 
    //control knobs set from test
    bit get_addr_from_test;
    axi_axaddr_t      m_addr_from_test;
    bit [255:0] unlocked_const;
    bit [255:0] locked_const;
    int exclusive_timeout;


    function new(string name = "axi_mutex_seq");
        super.new(name);

        wt_ace_rdcln   = 50;
        wt_ace_rdshrd  = 50;
        exclusive_timeout = 100;
    endfunction: new

    task body();
        bit en_load  = 1;
        bit en_store = 1;
        bit flag = 0;
        int count = 0;

        m_cacheline_addr = m_addr_from_test;

        // CG: Not required now because cacheline will always be valid
        //if(addrMgrConst::is_valid_cacheline(<%=my_ioaiu_id%>, m_cacheline_addr)) begin
            //Drive both Exclusive Load, Store sequences
            `uvm_info("AXI SEQ", $psprintf(
                "AIU[%0d] Initiating for Exclusive Load, Store sequences for cacheline:0x%0h, Initial State: ACE_IX",
                <%=this_aiu_id%>, m_cacheline_addr), UVM_MEDIUM)
            exclusive_seq(en_load, (!en_store), 0, 0);
        //end else begin
        //    `uvm_info("AXI SEQ", $psprintf("Cannot initiate exclusive seq:0x%0h on agent aiu<%=my_ioaiu_id%>",
        //        m_cacheline_addr), UVM_NONE)
        //end

        `uvm_info("body", "Exiting...", UVM_LOW)
    endtask: body

    //////////////////////////////////////////////////////////////////////
    //Initiates Exclusive Load & Store sequences depending on 
    //arguments are passed
    //////////////////////////////////////////////////////////////////////
    task exclusive_seq(input bit en_load,
                       input bit en_store,
                       input int count,
                       input axi_arid_t exmon_arid);
        axi_bresp_enum_t m_rresp;
        int tmp_cnt;
        bit _en_load  = 1;
        bit _en_store = 1;
        axi_arid_t use_arid;
        string msg = "";
        int indexq[$];
        bit security;
        msg = en_load ? "Load" : "Store";
        tmp_cnt = count;

        //Sanity check
        if((en_load && en_store)||(!(en_load || en_store))) 
            `uvm_fatal("AXI SEQ", $psprintf("AIU[%0d] Illegal arguments passed by caller, en_load: %b en_store: %b",
                <%=this_aiu_id%>, en_load, en_store));

        //Construct read address, data sequences
        m_read_addr_seq = axi_read_addr_seq::type_id::create("m_read_addr_seq"); 
        m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 

        //Set Address
        m_read_addr_seq.m_ace_rd_addr_chnl_addr = m_cacheline_addr;
<% if (obj.wSecurityAttribute > 0) { %>
        m_read_addr_seq.m_ace_rd_addr_chnl_security = m_security;
<% } %>                                                
<% if (obj.wSecurityAttribute > 0) { %>
        security = m_read_addr_seq.m_ace_rd_addr_chnl_security;
<% } else { %>                                                
        security = 1'b0;
<% } %>
        m_read_addr_seq.m_constraint_snoop = 1;
        m_read_addr_seq.m_constraint_addr  = 1;
        m_read_addr_seq.should_randomize   = 0;
        m_read_addr_seq.m_seq_item         = axi_rd_seq_item::type_id::create("m_seq_item");

        //Set Exclusive Load ace command
        if(en_load) begin
            randcase
                wt_ace_rdcln:  m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDCLN;
                wt_ace_rdshrd: m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDSHRD;
            endcase
            get_axid(m_read_addr_seq.m_ace_rd_addr_chnl_snoop, use_arid, .force_this_axid(exmon_arid), .use_force_this_axid(1));
        end
        else begin
            m_read_addr_seq.m_ace_rd_addr_chnl_snoop = CLNUNQ;
            get_axid(m_read_addr_seq.m_ace_rd_addr_chnl_snoop, use_arid, .force_this_axid(exmon_arid), .use_force_this_axid(1));
        end
 
        m_ace_cache_model.store_exclusive_req(m_read_addr_seq.m_ace_rd_addr_chnl_snoop,
                                              m_read_addr_seq.m_ace_rd_addr_chnl_addr
<% if (obj.wSecurityAttribute > 0) { %>                                             
        ,m_read_addr_seq.m_ace_rd_addr_chnl_security
<% } %>
        );

        //Randomize Read Addr packet
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.constrained_addr = 1;
        m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid      == use_arid;
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr    == m_read_addr_seq.m_ace_rd_addr_chnl_addr;
            // For directed test case purposes
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.useFullCL  == use_full_cl;
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.use2FullCL == 0;
<% if (obj.wSecurityAttribute > 0) { %>
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1] == m_read_addr_seq.m_ace_rd_addr_chnl_security;
<% } %>                                                
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlock    == EXCLUSIVE;
        };

        `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Initiating Exclusive %s ACE command %s for cacheline 0x%0h",
            <%=this_aiu_id%>, msg, m_read_addr_seq.m_ace_rd_addr_chnl_snoop,
            m_read_addr_seq.m_ace_rd_addr_chnl_addr), UVM_LOW);

        //Drive Read address packet
         m_ace_cache_model.update_addr(m_read_addr_seq.m_ace_rd_addr_chnl_snoop,
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                ,.security(m_read_addr_seq.m_ace_rd_addr_chnl_security)
            <% } %>
        );

        m_read_addr_seq.return_response(m_seq_item, m_read_addr_chnl_seqr);

        //Blocking till previous request with same arid has a response has been received
        wait_till_arid_latest(m_read_addr_seq.m_seq_item.m_read_addr_pkt);

        //Wait for response
        m_read_data_seq.m_seq_item       = m_seq_item;
        m_read_data_seq.should_randomize = 0;
        m_read_data_seq.return_response(m_seq_item, m_read_data_chnl_seqr);

        delete_ott_entry(m_read_addr_seq.m_seq_item.m_read_addr_pkt);
        //Check Response status and update cache
        <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5"){ %> 
        m_rresp = axi_bresp_enum_t'(m_seq_item.m_read_data_pkt.rresp_per_beat[0][CRRESP-1:0]);
         <% } else { %>
         m_rresp = axi_bresp_enum_t'(m_seq_item.m_read_data_pkt.rresp_per_beat[0][1:0]);
              <%}%>

        if(m_rresp == EXOKAY) begin
            axi_bresp_t m_tmp_bresp[];
            m_tmp_bresp = new[m_seq_item.m_read_data_pkt.rresp_per_beat.size()];
            foreach (m_tmp_bresp[i]) begin
                m_tmp_bresp[i] = m_seq_item.m_read_data_pkt.rresp_per_beat[i][1:0];
            end
            if(en_load) begin
                m_ace_cache_model.modify_cache_line(m_seq_item.m_read_addr_pkt.araddr,
                    m_read_addr_seq.m_ace_rd_addr_chnl_snoop,
                    m_tmp_bresp, m_seq_item.m_read_data_pkt.rdata, , ,
                                <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5"){ %> 
                    m_seq_item.m_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT],
                    m_seq_item.m_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT],
                                                     <% } else { %>
                                                     , ,
                                                    <%}%>
                    ((m_seq_item.m_read_addr_pkt.arlock == 1) ? 
                        (m_seq_item.m_read_data_pkt.rresp_per_beat[0][1:0] == EXOKAY) : 1),
                    .axdomain(m_seq_item.m_read_addr_pkt.ardomain)
<% if (obj.wSecurityAttribute > 0) { %>                                             
                    ,.security(m_seq_item.m_read_addr_pkt.arprot[1])
<% } %>                                                
                );
                //Perfrom Ex-Store only if data is unlocked
                if(rddata_unlocked(m_seq_item.m_read_data_pkt)) begin
                    //initiate Exclusive store sequence
                    //This step is just to make sure data in cache is not altered
                    `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Exclusive Load is successfull for cacheline:0x%0h and data is unlocked count:%0d",
                                     <%=this_aiu_id%>, m_read_addr_seq.m_ace_rd_addr_chnl_addr, tmp_cnt), UVM_LOW);
                    write_unlocked_value2cache(m_read_addr_seq.m_ace_rd_addr_chnl_addr, security);
                    exclusive_seq((!_en_load), _en_store, tmp_cnt, 0);
                end else begin
                    `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Exclusive Load is successfull but for cacheline:0x%0h and data is locked count:%0d",
                                     <%=this_aiu_id%>, m_read_addr_seq.m_ace_rd_addr_chnl_addr, tmp_cnt), UVM_LOW);
                    //initiate Exclusive load sequence
                    tmp_cnt++;
                    if(tmp_cnt > exclusive_timeout) begin
                        `uvm_error("AXI SEQ", $psprintf("AIU[%0d] Following Exclusive %s transaction timed out due to potential livelock senario: cacheline 0x%0h",
                            <%=this_aiu_id%>, msg, m_read_addr_seq.m_ace_rd_addr_chnl_addr));
                    end
                    exclusive_seq(_en_load, (!_en_store), tmp_cnt, 0);
                end
            end else begin
                //If Ex-Store is sucessfull then mutex is graneted and lock it for certain period of time
                //NOTE: Always set prob_unq_cln_to_unq_dirty:100  wt_expected_end_state:100 wt_legal_end_state_without_sf:0
                //      wt_legal_end_state_with_sf:0 for this test
                `uvm_info("AXI SEQ", $psprintf(
                    "AIU[%0d] Exclusive Store is successfull for cacheline:0x%0h and data is locked count %0d",
                    <%=this_aiu_id%>, m_read_addr_seq.m_ace_rd_addr_chnl_addr, tmp_cnt), UVM_LOW);
                
                m_ace_cache_model.modify_cache_line(m_seq_item.m_read_addr_pkt.araddr,
                    m_read_addr_seq.m_ace_rd_addr_chnl_snoop,
                    m_tmp_bresp, m_seq_item.m_read_data_pkt.rdata, , ,
                                                <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5"){ %> 
                    m_seq_item.m_read_data_pkt.rresp_per_beat[0][CRRESPISSHAREDBIT],
                    m_seq_item.m_read_data_pkt.rresp_per_beat[0][CRRESPPASSDIRTYBIT],
                                                     <% } else { %>
                                                     , ,
                                                    <%}%>
                    ((m_seq_item.m_read_addr_pkt.arlock == 1) ?
                         (m_seq_item.m_read_data_pkt.rresp_per_beat[0][1:0] == EXOKAY) : 1),
                    .axdomain(m_seq_item.m_read_addr_pkt.ardomain)
<% if (obj.wSecurityAttribute > 0) { %>                                             
                    ,.security(m_seq_item.m_read_addr_pkt.arprot[1])
<% } %>                                                
                );

                `uvm_info("AXI SEQ", "Entering Critical section of the code. mutex locked", UVM_NONE)
                write_locked_value2cache(m_read_addr_seq.m_ace_rd_addr_chnl_addr, security);
                blocking_lock_section();
                `uvm_info("AXI SEQ", "Exiting Critical section of the code", UVM_NONE)
                //Invalidate all other copies of the cacheline
                invalidate_copies_of_cacheline(m_read_addr_seq.m_ace_rd_addr_chnl_addr, security, exmon_arid);
                write_unlocked_value2cache(m_read_addr_seq.m_ace_rd_addr_chnl_addr, security);
            end
        end
        else if(m_rresp == OKAY) begin
            if(tmp_cnt < exclusive_timeout) begin
               `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Exclusive Store failed for cacheline 0x%0h, retry-count %0d starting from load",
                                        <%=this_aiu_id%>, m_read_addr_seq.m_ace_rd_addr_chnl_addr, tmp_cnt), UVM_NONE);
               tmp_cnt++;
               exclusive_seq(_en_load, (!_en_store), tmp_cnt, 0);
            end
            else begin
                `uvm_error("AXI SEQ", $psprintf("AIU[%0d] Following Exclusive %s transaction timed out: cacheline 0x%0h",
                                       <%=this_aiu_id%>, msg, m_read_addr_seq.m_ace_rd_addr_chnl_addr));
            end
        end
    endtask: exclusive_seq

    function bit rddata_unlocked(const ref ace_read_data_pkt_t m_seq_item);
        bit status;

        //Setting default value to 1 only if data exists
        status = m_seq_item.rdata.size() > 0 ? 1'b1 : 1'b0;
        if(m_seq_item.rdata[0][63:0] == unlocked_const[63:0]) begin
            status = status && 1'b1;
        end else if(m_seq_item.rdata[0][63:0] == locked_const[63:0]) begin
            status = status && 1'b0;
        end else begin
            string s;
            $sformat(s, "%s Data is Unexpectedly modified to unknown value.", s);
            $sformat(s, "%s Neither matches locked_const:0x%0h nor unlocked_const:0x%0h. Data is",
                     s, locked_const, unlocked_const);
            foreach(m_seq_item.rdata[idx])
                $sformat(s, "%s data[%0d]:0x%0h", s, idx, m_seq_item.rdata[idx]);
            `uvm_info("AXI SEQ", s, UVM_NONE)
            `uvm_error("AXI SEQ", "Data is Unexpectedly modified")
        end
        return(status);
    endfunction: rddata_unlocked

    task blocking_lock_section();
        #200000ns;
    endtask: blocking_lock_section

    function void write_locked_value2cache(axi_axaddr_t tmp_addr, bit security);
        int indexq[$];

        //Modify data in the cache
        indexq = m_ace_cache_model.m_cache.find_index(item) with (
                     item.m_addr[WAXADDR-1:SYS_wSysCacheline] ==
                     tmp_addr[WAXADDR-1:SYS_wSysCacheline]
                     && item.m_security == security);

        if(indexq.size() == 0) begin
            `uvm_fatal("AXI SEQ", $psprintf("TbError: rdaddr:0x%0h must exist in cache", tmp_addr))
        end
        //Modify data by writing Locked Value
        foreach(m_ace_cache_model.m_cache[indexq[0]].m_data[idx]) begin
            m_ace_cache_model.m_cache[indexq[0]].m_data[idx] = locked_const;
        end
    endfunction: write_locked_value2cache

    function void write_unlocked_value2cache(axi_axaddr_t tmp_addr, bit security);
        int indexq[$];

        //Modify data in the cache
        indexq = m_ace_cache_model.m_cache.find_index(item) with (
                     item.m_addr[WAXADDR-1:SYS_wSysCacheline] ==
                     tmp_addr[WAXADDR-1:SYS_wSysCacheline]
                     && item.m_security == security);

        if(indexq.size() == 0) begin
            `uvm_fatal("AXI SEQ", $psprintf("TbError: rdaddr:0x%0h must exist in cache", tmp_addr))
        end
        //Modify data by writing Locked Value
        foreach(m_ace_cache_model.m_cache[indexq[0]].m_data[idx]) begin
            m_ace_cache_model.m_cache[indexq[0]].m_data[idx] = unlocked_const;
        end
    endfunction: write_unlocked_value2cache

    task invalidate_copies_of_cacheline(
        input axi_axaddr_t tmp_addr,
        input bit security,
        input axi_arid_t exmon_arid);

        axi_read_addr_seq m_makeunique_rd_req_seq;
        axi_read_data_seq m_makeunique_rd_rsp_seq;
        axi_arid_t use_arid;
        axi_bresp_enum_t m_rresp;

        m_makeunique_rd_req_seq = axi_read_addr_seq::type_id::create("m_makeunique_rd_req_seq");
        m_makeunique_rd_rsp_seq = axi_read_data_seq::type_id::create("m_makeunique_rd_rsp_seq"); 

        //set address
        m_makeunique_rd_req_seq.m_ace_rd_addr_chnl_addr     = tmp_addr;
<% if (obj.wSecurityAttribute > 0) { %>
        m_makeunique_rd_req_seq.m_ace_rd_addr_chnl_security = security;
<% } %>                                                

        m_makeunique_rd_req_seq.m_constraint_snoop = 1;
        m_makeunique_rd_req_seq.m_constraint_addr  = 1;
        m_makeunique_rd_req_seq.should_randomize   = 0;
        m_makeunique_rd_req_seq.m_seq_item         = axi_rd_seq_item::type_id::create("m_seq_item");
        m_makeunique_rd_req_seq.m_ace_rd_addr_chnl_snoop = MKUNQ;

        get_axid(m_makeunique_rd_req_seq.m_ace_rd_addr_chnl_snoop, use_arid, .force_this_axid(exmon_arid), .use_force_this_axid(1));

        //Randomize Read Addr packet
        m_makeunique_rd_req_seq.m_seq_item.m_read_addr_pkt.constrained_addr = 1;
        m_makeunique_rd_req_seq.m_seq_item.m_read_addr_pkt.randomize() with {
            m_makeunique_rd_req_seq.m_seq_item.m_read_addr_pkt.arid      == use_arid;
            m_makeunique_rd_req_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_makeunique_rd_req_seq.m_ace_rd_addr_chnl_snoop;
            m_makeunique_rd_req_seq.m_seq_item.m_read_addr_pkt.araddr    == m_makeunique_rd_req_seq.m_ace_rd_addr_chnl_addr;
            // For directed test case purposes
            m_makeunique_rd_req_seq.m_seq_item.m_read_addr_pkt.useFullCL  == use_full_cl;
            m_makeunique_rd_req_seq.m_seq_item.m_read_addr_pkt.use2FullCL == 0;
<% if (obj.wSecurityAttribute > 0) { %>
            m_makeunique_rd_req_seq.m_seq_item.m_read_addr_pkt.arprot[1] == m_makeunique_rd_req_seq.m_ace_rd_addr_chnl_security;
<% } %>                                                
            m_makeunique_rd_req_seq.m_seq_item.m_read_addr_pkt.arlock    == NORMAL;
        };

        `uvm_info("AXI SEQ", $psprintf("AIU[%0d] Initiating ACE command %s for cacheline 0x%0h to invalidate all other copies",
            <%=this_aiu_id%>, m_makeunique_rd_req_seq.m_ace_rd_addr_chnl_snoop.name(),
            m_makeunique_rd_req_seq.m_ace_rd_addr_chnl_addr), UVM_LOW);

        //Drive Read address packet
        m_makeunique_rd_req_seq.return_response(m_seq_item, m_read_addr_chnl_seqr);

        //Blocking till previous request with same arid has a response has been received
        wait_till_arid_latest(m_makeunique_rd_req_seq.m_seq_item.m_read_addr_pkt);

        //Wait for response
        m_makeunique_rd_rsp_seq.m_seq_item       = m_seq_item;
        m_makeunique_rd_rsp_seq.should_randomize = 0;
        m_makeunique_rd_rsp_seq.return_response(m_seq_item, m_read_data_chnl_seqr);

        delete_ott_entry(m_makeunique_rd_req_seq.m_seq_item.m_read_addr_pkt);
        //Check Response status and update cache
       <% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5"){ %> 
        m_rresp = axi_bresp_enum_t'(m_seq_item.m_read_data_pkt.rresp_per_beat[0][CRRESP-1:0]);
         <% } else { %>
         m_rresp = axi_bresp_enum_t'(m_seq_item.m_read_data_pkt.rresp_per_beat[0][1:0]);
              <%}%> 
        if(m_rresp != OKAY) begin
         `uvm_error("AXI SEQ", $psprintf("AIU[%0d] Invalid rrsep type for command:%s cacheline:0x%0h",
              <%=this_aiu_id%>, m_makeunique_rd_req_seq.m_ace_rd_addr_chnl_snoop.name(),
              m_makeunique_rd_req_seq.m_seq_item.m_read_addr_pkt.araddr))
        end
    endtask: invalidate_copies_of_cacheline

endclass: axi_mutex_seq
<% } %>


//******************************************************************************
// Section1: ReadNosnoop
// Purpose : Generates a single ReadNoSnoop transaction.
//******************************************************************************

class axi_single_rdnosnp_seq extends axi_master_read_base_seq;

    `uvm_object_param_utils(axi_single_rdnosnp_seq)

    `uvm_declare_p_sequencer(axi_virtual_sequencer);
    
    axi_read_addr_seq            m_read_addr_seq;
    axi_read_data_seq            m_read_data_seq;
    axi_rd_seq_item              m_seq_item;
    axi_axaddr_t                 m_addr;
    axi_axlen_t                  m_axlen;
    axi_arid_t                   use_arid;
    axi_axsize_t                 m_size;
    int aiu_qos;
    int user_qos;
    bit                          success;
    bit k_decode_err_illegal_acc_format_test_unsupported_size;
    bit ioaiu_csr_ns_access;

    function new(string name="axi_single_rdnosnp_seq");
      super.new();
      user_qos = 0;
    endfunction


   task body;
   
    if($value$plusargs("aiu_qos=%d", aiu_qos)) begin
       user_qos = 1;
    end

       m_read_addr_seq = axi_read_addr_seq::type_id::create("m_read_addr_seq"); 
       m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 
               m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDNOSNP;
   
                  uvm_report_info("ACE BFM SEQ", $sformatf("RD snooptype %0s addr 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), m_read_addr_seq.m_ace_rd_addr_chnl_addr), UVM_MEDIUM);
                  uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("RD snooptype %0s addr 0x%0x secure bit 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), m_read_addr_seq.m_ace_rd_addr_chnl_addr, 
          <% if (obj.wSecurityAttribute > 0) { %>                                             
                  m_read_addr_seq.m_ace_rd_addr_chnl_security 
          <% } else { %>                                                
                  0
          <% } %>
       ), UVM_MEDIUM);
    
   
           m_read_addr_seq.m_constraint_snoop      = 1;
           m_read_addr_seq.m_constraint_addr       = 0;
           m_read_addr_seq.should_randomize        = 0;
           
           m_read_addr_seq.m_seq_item  = axi_rd_seq_item::type_id::create("m_seq_item");
         
   
   
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.constrained_addr = 1;
           success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid == 0;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == AXIINCR;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache == RDEVNONBUF;
               //m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1]==0;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlock==NORMAL;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr == m_addr; // added to be check on post_randomize function for config with connectivity
   	       if (user_qos)   m_read_addr_seq.m_seq_item.m_read_addr_pkt.arqos == aiu_qos;
   
           };
           
           if (!success) begin
               `uvm_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_master_read_seq"))
           end
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen  = 0;
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1] = (ioaiu_csr_ns_access) ? 1 : 0;
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsize = (k_decode_err_illegal_acc_format_test_unsupported_size==0) ? 3'b010 : 3'b100;
           
           `uvm_info("ACE BFM SEQ", $sformatf("RD snooptype %0s addr 0x%0x Len 0x%0x NonSecure 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), 
                                           m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr, m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen, m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1]), UVM_NONE);
           m_read_addr_seq.return_response(m_seq_item,p_sequencer.m_read_addr_chnl_seqr);
           m_read_data_seq.m_seq_item       = m_seq_item;
           m_read_data_seq.should_randomize = 0;
           m_read_data_seq.return_response(m_seq_item,p_sequencer.m_read_data_chnl_seqr);

   
   
   endtask : body
endclass: axi_single_rdnosnp_seq

<% if ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache) { %>
//******************************************************************************
// Section:  ioc fill seq 
// Purpose:  Sequence fill up the cache with user-settable number of txns
//******************************************************************************

class ioc_fill_seq extends axi_master_pipelined_seq;
    `uvm_object_param_utils(ioc_fill_seq)
    
    bit [WAXADDR:0] addr_q[$];

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "ioc_fill_seq");
    super.new(name);

endfunction : new


//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    int ccp_index, do_cnt;
    int addr_cnt_per_set[int];
    bit is_coh = 1;
    bit[<%=Math.log2(obj.nDataBanks)%>-1:0]             sel_bank;
    axi_axaddr_t             m_addr;
<% if (obj.wSecurityAttribute > 0) { %>                                             
    bit [<%=obj.wSecurityAttribute%>-1:0]               m_security;
<% } %>                                                

    `uvm_info(get_full_name(),"Entering Body........", UVM_LOW)
     //FIXME: if sum of reads+writes > cache-size, throw an error
    `uvm_info(get_full_name(), $sformatf("k_num_read_req:%0d k_num_write_req:%0d", k_num_read_req, k_num_write_req), UVM_LOW)
    m_ace_cache_model.core_id = core_id;
    do begin
        do_cnt = 0;
        //keep randomizing the addr until a unique address is found, and not
        //more than num_addr in a set
        do begin
            ace_command_types_enum_t cmd = RDONCE;
            do_cnt++;
            m_ace_cache_model.give_addr_for_ace_req_read(0, cmd, 
                                                         m_addr
                <% if (obj.wSecurityAttribute > 0) { %>                                                                                                              ,m_security
                <% } %>
                                                        ,is_coh);
            
            if ($value$plusargs("data_bank=%0d", sel_bank)) begin
              <%for( var i=0; i< Math.log2(obj.nDataBanks); i++){%>
                m_addr[<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits[obj.AiuInfo[obj.Id].ccpParams.DataBankSelBits[i]]%>] = sel_bank[<%=i%>];
              <%}%>
            end

            ccp_index = addrMgrConst::get_set_index(m_addr,<%=obj.FUnitId%>);
            if (addr_cnt_per_set.exists(ccp_index) == 0)
                addr_cnt_per_set[ccp_index] = 0;
                        
        end while((({m_security, m_addr} >> 6) inside {addr_q} || addr_cnt_per_set[ccp_index] == IOC_NUM_WAYS) && (do_cnt < 10000));

        if(do_cnt == 10000)
	    `uvm_error(get_full_name(), $sformatf("TB Error: addr randomization failed"));
        
        //Got an address successfully
        addr_cnt_per_set[ccp_index]++;
        addr_q.push_back({m_security, m_addr} >> 6);

        //`uvm_info(get_full_name(), $sformatf("Pushed security:%0b addr:0x%0h ccp_index:0x%0h into addrq",m_security, m_addr, ccp_index), UVM_LOW);
    end while (addr_q.size() < (k_num_read_req + k_num_write_req));
        
    foreach (addr_q[i]) begin  
        if (i < k_num_read_req) begin 
            axi_directed_rd_seq rd_seq = axi_directed_rd_seq::type_id::create($sformatf("c%0d_rd_seq_%0d", core_id, i));
            
            rd_seq.core_id               = core_id;
            rd_seq.txn_id      	         = i;
            rd_seq.m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
            rd_seq.m_read_data_chnl_seqr = m_read_data_chnl_seqr;

           //rd_seq.dis_post_randomize = 1;
            rd_seq.m_cmdtype = RDONCE;
            rd_seq.m_addr    = addr_q[i] << 6;    
            rd_seq.m_id      = i;
            rd_seq.m_len     = ((SYS_nSysCacheline*8/(WXDATA)) - 1);//cache-line size
            if (WXDATA == 64)
                rd_seq.m_size = AXI8B;
            else if (WXDATA == 128)
                rd_seq.m_size = AXI16B;
            else if (WXDATA == 256)
                rd_seq.m_size = AXI32B;
           
            rd_seq.m_burst   = AXIINCR ;
            rd_seq.m_prot[1] = addr_q[i] >> (WAXADDR - 6);
            rd_seq.m_prot[0] = $urandom_range(0,1);
            rd_seq.m_prot[2] = $urandom_range(0,1);
            rd_seq.m_cache   = RWBRWALLOC;
            rd_seq.m_domain  = INNRSHRBL;
            rd_seq.start(null);
        end else begin 
            axi_directed_wr_seq wr_seq = axi_directed_wr_seq::type_id::create($sformatf("c%0d_wr_seq_%0d", core_id, i));
            
            wr_seq.core_id               = core_id;
            wr_seq.txn_id      	         = i;
            wr_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
            wr_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
            wr_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
            wr_seq.m_ace_cache_model      = m_ace_cache_model;

           //wr_seq.dis_post_randomize = 1;
            wr_seq.m_cmdtype = WRUNQ;
            wr_seq.m_addr    = addr_q[i] << 6;    
            wr_seq.m_id      = i;
           if($test$plusargs("seq_single_read_multi_write")) begin
            wr_seq.m_len     = 0;
           end else begin
           wr_seq.m_len     = ((SYS_nSysCacheline*8/(WXDATA)) - 1);//cache-line size
            end
            if (WXDATA == 64)
                wr_seq.m_size = AXI8B;
            else if (WXDATA == 128)
                wr_seq.m_size = AXI16B;
            else if (WXDATA == 256)
                wr_seq.m_size = AXI32B;
            wr_seq.m_burst   = AXIINCR ;
            wr_seq.m_prot[1] = addr_q[i] >> (WAXADDR - 6);
            wr_seq.m_prot[0] = $urandom_range(0,1);
            wr_seq.m_prot[2] = $urandom_range(0,1);
            wr_seq.m_cache   = WWBRWALLOC;
            wr_seq.m_domain  = INNRSHRBL;
            wr_seq.start(null);
        end 
    end 

    `uvm_info(get_full_name(),"Exiting Body........", UVM_LOW);
endtask : body

endclass : ioc_fill_seq

class ioc_wrhit_upg_w_rd_seq extends axi_master_pipelined_seq;
    `uvm_object_param_utils(ioc_wrhit_upg_w_rd_seq)
    axi_directed_rd_seq rd_seq[];
    axi_directed_wr_seq wr_seq[];
    ioc_fill_seq fill_seq;
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "ioc_wrhit_upg_w_rd_seq");
        super.new(name);
    endfunction : new

    //------------------------------------------------------------------------------
    // Body Task
    //------------------------------------------------------------------------------
    task body;
        bit[<%=Math.log2(obj.nDataBanks)%>-1:0]             sel_bank;
        //`uvm_info(get_full_name(),"Entering Body........", UVM_LOW)
       
        //Fill the cache with SD and SC states.
        fill_seq = ioc_fill_seq::type_id::create($sformatf("c%0d_fill_seq", core_id));

        fill_seq.k_num_read_req        = k_num_read_req;
        fill_seq.k_num_write_req       = k_num_write_req;
        fill_seq.core_id               = core_id;
        fill_seq.m_ace_cache_model     = m_ace_cache_model;
        fill_seq.m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        fill_seq.m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        fill_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        fill_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        fill_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;

        `uvm_info(get_full_name(),"fill_seq started", UVM_LOW);
        fill_seq.start(null);
        `uvm_info(get_full_name(),"fill_seq completed", UVM_LOW);

        // Reads that are a mix of hits and misses.
         rd_seq = new[fill_seq.addr_q.size() * 2];
         foreach (rd_seq[i]) begin  
            int idx = $urandom_range(0, fill_seq.addr_q.size()-1);
            bit jdx = $urandom_range(0,1);
            rd_seq[i] = axi_directed_rd_seq::type_id::create($sformatf("c%0d_rd_seq_%0d", core_id, i));
            
            rd_seq[i].core_id               = core_id;
            rd_seq[i].txn_id      	         = i;
            rd_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
            rd_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;

            rd_seq[i].dis_post_randomize = 1;
            rd_seq[i].m_cmdtype = RDONCE;
            rd_seq[i].m_addr    = jdx ? fill_seq.addr_q[idx] << 6 : m_addr_mgr.get_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, 0, core_id);    
            if ($value$plusargs("data_bank=%0d", sel_bank)) begin
              <%for( var i=0; i< Math.log2(obj.nDataBanks); i++){%>
                rd_seq[i].m_addr[<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits[obj.AiuInfo[obj.Id].ccpParams.DataBankSelBits[i]]%>] = sel_bank[<%=i%>];
              <%}%>
            end
            rd_seq[i].m_addr[SYS_wSysCacheline-1:0] = 0;
            rd_seq[i].m_id      = i;
            rd_seq[i].m_len     = ((SYS_nSysCacheline*8/(WXDATA)) - 1);//cache-line size
            if (WXDATA == 64)
                rd_seq[i].m_size = AXI8B;
            else if (WXDATA == 128)
                rd_seq[i].m_size = AXI16B;
            else if (WXDATA == 256)
                rd_seq[i].m_size = AXI32B;
            rd_seq[i].m_burst   = AXIINCR;
            rd_seq[i].m_prot[1] = jdx ? fill_seq.addr_q[idx] >> (WAXADDR - 6) : $urandom_range(0,1);
            rd_seq[i].m_prot[0] = $urandom_range(0,1);
            rd_seq[i].m_prot[2] = $urandom_range(0,1);
            rd_seq[i].m_cache   = RWBRWALLOC;
            rd_seq[i].m_domain  = INNRSHRBL;
        end 
   
        //Partial Write Hits on SD and SC triggering a Read-Modify-Write in
        //proxyCache. They are also called write hit upgrades.
        wr_seq = new[fill_seq.addr_q.size()];
        fill_seq.addr_q.shuffle();
        foreach (wr_seq[j]) begin 
          wr_seq[j]                        = axi_directed_wr_seq::type_id::create($sformatf("c%0d_wr_seq_%0d", core_id, j));
          wr_seq[j].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
          wr_seq[j].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
          wr_seq[j].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
          wr_seq[j].dis_post_randomize = 1;
          wr_seq[j].m_id      = j;
          wr_seq[j].core_id                = core_id;
          wr_seq[j].m_ace_cache_model      = m_ace_cache_model;
          wr_seq[j].m_addr                 = fill_seq.addr_q[j] << 6;;
          wr_seq[j].m_len                 = ((SYS_nSysCacheline*8/(WXDATA)) - 1);
          wr_seq[j].m_cmdtype = WRUNQ;
          if (WXDATA == 64)
           wr_seq[j].m_size = AXI8B;
          else if (WXDATA == 128)
         wr_seq[j].m_size = AXI16B;
        else if (WXDATA == 256)
        wr_seq[j].m_size = AXI32B;
        wr_seq[j].m_burst   = $urandom_range(0,1) ? AXIINCR : AXIWRAP;
        wr_seq[j].m_prot[1] = fill_seq.addr_q[j] >> (WAXADDR - 6);
        wr_seq[j].m_prot[0] = $urandom_range(0,1);
        wr_seq[j].m_prot[2] = $urandom_range(0,1);
        wr_seq[j].m_cache   = WWBRWALLOC;
        wr_seq[j].m_domain  = INNRSHRBL;
       end

       fork
        for (int i = rd_seq.size()-1; i >= 0 ; i--) begin
            fork
                automatic int j=i;
                begin
                    rd_seq[j].start(null);
                end
            join_none
        end
        for (int i = wr_seq.size()-1; i >= 0 ; i--) begin
            fork
                automatic int j=i;
                begin
                    wr_seq[j].start(null);
                end
            join_none
        end
      join_none;
      wait fork;

      //`uvm_info(get_name(),"Exiting Body ioc_stream_of_read_hits seq ......", UVM_LOW)

endtask:body 

endclass :ioc_wrhit_upg_w_rd_seq

class ioc_stream_of_hits_seq extends axi_master_pipelined_seq;
    `uvm_object_param_utils(ioc_stream_of_hits_seq)
    axi_directed_rd_seq rd_seq[];
    axi_directed_wr_seq   wr_seq[];
    ioc_fill_seq fill_seq;
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "ioc_stream_of_hits_seq");
        super.new(name);
    endfunction : new

    //------------------------------------------------------------------------------
    // Body Task
    //------------------------------------------------------------------------------
    task body;
        `uvm_info(get_full_name(),"Entering Body........", UVM_LOW)
        
        fill_seq = ioc_fill_seq::type_id::create($sformatf("c%0d_fill_seq", core_id));

        fill_seq.k_num_read_req        = k_num_read_req;
        fill_seq.k_num_write_req       = k_num_write_req;
        fill_seq.core_id               = core_id;
        fill_seq.m_ace_cache_model     = m_ace_cache_model;
        fill_seq.m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        fill_seq.m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        fill_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        fill_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        fill_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;

        `uvm_info(get_full_name(),"fill_seq started", UVM_LOW);
        fill_seq.start(null);
    
        `uvm_info(get_full_name(),"fill_seq completed", UVM_LOW);
        if(!$test$plusargs("write_hit")) begin 
        rd_seq = new[fill_seq.addr_q.size()];
        foreach (rd_seq[i]) begin  
            rd_seq[i] = axi_directed_rd_seq::type_id::create($sformatf("c%0d_rd_seq_%0d", core_id, i));
            
            rd_seq[i].core_id               = core_id;
            rd_seq[i].txn_id      	         = i;
            rd_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
            rd_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;

            rd_seq[i].dis_post_randomize = 1;
            rd_seq[i].m_cmdtype = RDONCE;
            rd_seq[i].m_addr    = fill_seq.addr_q[i] << 6;    
            rd_seq[i].m_id      = i;
            rd_seq[i].m_len     = ((SYS_nSysCacheline*8/(WXDATA)) - 1);//cache-line size
            if (WXDATA == 64)
                rd_seq[i].m_size = AXI8B;
            else if (WXDATA == 128)
                rd_seq[i].m_size = AXI16B;
            else if (WXDATA == 256)
                rd_seq[i].m_size = AXI32B;
            rd_seq[i].m_burst   = $urandom_range(0,1) ? AXIINCR : AXIWRAP;
            rd_seq[i].m_prot[1] = fill_seq.addr_q[i] >> (WAXADDR - 6);
            rd_seq[i].m_prot[0] = $urandom_range(0,1);
            rd_seq[i].m_prot[2] = $urandom_range(0,1);
            rd_seq[i].m_cache   = RWBRWALLOC;
            rd_seq[i].m_domain  = INNRSHRBL;
            //rd_seq.start(null);
        end 

        for (int i = rd_seq.size()-1; i >= 0 ; i--) begin
            fork
                automatic int j=i;
                begin
                    rd_seq[j].start(null);
                end
            join_none
        end
       end else begin
        wr_seq = new[fill_seq.addr_q.size()];
        foreach (wr_seq[j]) begin 
        wr_seq[j]                        = axi_directed_wr_seq::type_id::create($sformatf("c%0d_wr_seq_%0d", core_id, j));
        wr_seq[j].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        wr_seq[j].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        wr_seq[j].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
        wr_seq[j].dis_post_randomize = 1;
        wr_seq[j].m_id      = j;
        wr_seq[j].core_id                = core_id;
        wr_seq[j].m_ace_cache_model      = m_ace_cache_model;
        wr_seq[j].m_addr                   = fill_seq.addr_q[j] << 6;;
        wr_seq[j].m_len                 = ((SYS_nSysCacheline*8/(WXDATA)) - 1);
        wr_seq[j].m_cmdtype = WRUNQ;
        if (WXDATA == 64)
        wr_seq[j].m_size = AXI8B;
        else if (WXDATA == 128)
        wr_seq[j].m_size = AXI16B;
        else if (WXDATA == 256)
        wr_seq[j].m_size = AXI32B;
        wr_seq[j].m_burst   = $urandom_range(0,1) ? AXIINCR : AXIWRAP;
        wr_seq[j].m_prot[1] = fill_seq.addr_q[j] >> (WAXADDR - 6);
        wr_seq[j].m_prot[0] = $urandom_range(0,1);
        wr_seq[j].m_prot[2] = $urandom_range(0,1);
        wr_seq[j].m_cache   = WWBRWALLOC;
        wr_seq[j].m_domain  = INNRSHRBL;
        end

         for (int i = wr_seq.size()-1; i >= 0 ; i--) begin
            fork
                automatic int j=i;
                begin
                    wr_seq[j].start(null);
                end
            join_none
        end

       end

        `uvm_info(get_full_name(),"Exiting Body........", UVM_LOW)

endtask:body 

endclass : ioc_stream_of_hits_seq

class seq_single_write_multi_read extends axi_master_pipelined_seq;
    `uvm_object_param_utils(seq_single_write_multi_read)
    axi_directed_rd_seq rd_seq[];
    axi_directed_wr_seq   wr_seq;
    ioc_fill_seq fill_seq;
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "seq_single_write_multi_read");
        super.new(name);
    endfunction : new

    //------------------------------------------------------------------------------
    // Body Task
    //------------------------------------------------------------------------------
    task body;
        int unsigned delay_cycles;
        `uvm_info(get_full_name(),"Entering Body........", UVM_LOW)
        
        fill_seq = ioc_fill_seq::type_id::create($sformatf("c%0d_fill_seq", core_id));

        fill_seq.k_num_read_req        = 1;
        fill_seq.k_num_write_req       = 0;
        fill_seq.core_id               = core_id;
        fill_seq.m_ace_cache_model     = m_ace_cache_model;
        fill_seq.m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        fill_seq.m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        fill_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        fill_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        fill_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;

        `uvm_info(get_full_name(),"fill_seq started", UVM_LOW);
        fill_seq.start(null);
    
        `uvm_info(get_full_name(),"fill_seq completed", UVM_LOW);
        
        rd_seq = new[1000];
        foreach (rd_seq[i]) begin  
            rd_seq[i] = axi_directed_rd_seq::type_id::create($sformatf("c%0d_rd_seq_%0d", core_id, i));
            
            rd_seq[i].core_id               = core_id;
            rd_seq[i].txn_id      	         = i;
            rd_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
            rd_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;

            rd_seq[i].dis_post_randomize = 1;
            rd_seq[i].m_cmdtype = RDONCE;
            rd_seq[i].m_addr    = fill_seq.addr_q[0] << 6;    
            rd_seq[i].m_id      = i;
            rd_seq[i].m_len     = 0;//cache-line size
            rd_seq[i].m_size    = 0;//cache-line size
            rd_seq[i].m_burst   = AXIINCR;
            rd_seq[i].m_prot[1] = fill_seq.addr_q[0] >> (WAXADDR - 6);
            rd_seq[i].m_prot[0] = $urandom_range(0,1);
            rd_seq[i].m_prot[2] = $urandom_range(0,1);
            rd_seq[i].m_cache   = 'hf;
            rd_seq[i].m_domain  = INNRSHRBL;
        end 

        fork

          begin 
            for (int i = rd_seq.size()-1; i >= 0 ; i--) begin
                fork
                    automatic int j=i;
                    begin
                        rd_seq[j].start(null);
                    end
                join_none
            end
          end
  
          begin
            delay_cycles = $urandom_range(200, 4500);
            `uvm_info(get_name(), $sformatf("delay_cycles:%0d", delay_cycles), UVM_LOW);
            #(<%=obj.Clocks[0].params.period%>ps * delay_cycles); //wait for random cycles            
            wr_seq                        = axi_directed_wr_seq::type_id::create($sformatf("c%0d_wr_seq", core_id));
            wr_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
            wr_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
            wr_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
            wr_seq.dis_post_randomize = 1;
            wr_seq.m_id      = $urandom();
            wr_seq.core_id                = core_id;
            wr_seq.m_ace_cache_model      = m_ace_cache_model;
            wr_seq.m_addr                   = m_addr_mgr.get_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, 0, core_id);
            wr_seq.m_len                 = 0;
            wr_seq.m_cmdtype = WRUNQ;
            if (WXDATA == 64)
            wr_seq.m_size = AXI8B;
            else if (WXDATA == 128)
            wr_seq.m_size = AXI16B;
            else if (WXDATA == 256)
            wr_seq.m_size = AXI32B;
            wr_seq.m_burst   = AXIINCR;
            wr_seq.m_prot[1] = 0;
            wr_seq.m_prot[0] = $urandom_range(0,1);
            wr_seq.m_prot[2] = $urandom_range(0,1);
            wr_seq.m_cache   = 'hf;
            wr_seq.m_domain  = INNRSHRBL;
            wr_seq.start(null);
          end
        join

        `uvm_info(get_full_name(),"Exiting Body........", UVM_LOW)

endtask:body 

endclass : seq_single_write_multi_read

class seq_single_read_multi_write extends axi_master_pipelined_seq;
    `uvm_object_param_utils(seq_single_read_multi_write)
    axi_directed_rd_seq rd_seq;
    axi_directed_wr_seq   wr_seq[];
    ioc_fill_seq fill_seq;
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "seq_single_read_multi_write");
        super.new(name);
    endfunction : new

    //------------------------------------------------------------------------------
    // Body Task
    //------------------------------------------------------------------------------
    task body;
        int unsigned delay_cycles;
        `uvm_info(get_full_name(),"Entering Body........", UVM_LOW)
        
        fill_seq = ioc_fill_seq::type_id::create($sformatf("c%0d_fill_seq", core_id));

        fill_seq.k_num_read_req        = 0;
        fill_seq.k_num_write_req       = 1;
        fill_seq.core_id               = core_id;
        fill_seq.m_ace_cache_model     = m_ace_cache_model;
        fill_seq.m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        fill_seq.m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        fill_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        fill_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        fill_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;

        `uvm_info(get_full_name(),"fill_seq started", UVM_LOW);
        fill_seq.start(null);
    
        `uvm_info(get_full_name(),"fill_seq completed", UVM_LOW);
        //rd_seq = new[fill_seq.addr_q.size()];
        //foreach (rd_seq[i]) begin  
                    //end 
        fork
        begin
        wr_seq = new[2000];
        foreach (wr_seq[j]) begin 
        wr_seq[j]                        = axi_directed_wr_seq::type_id::create($sformatf("c%0d_wr_seq_%0d", core_id, j));
        wr_seq[j].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        wr_seq[j].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        wr_seq[j].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
        wr_seq[j].dis_post_randomize = 1;
        wr_seq[j].m_id      = j;
        wr_seq[j].core_id                = core_id;
        wr_seq[j].m_ace_cache_model      = m_ace_cache_model;
        wr_seq[j].m_addr                   = fill_seq.addr_q[0] << 6;;
        wr_seq[j].m_len                 = 0;
        wr_seq[j].m_cmdtype = WRUNQ;
        if (WXDATA == 64)
        wr_seq[j].m_size = AXI4B;
        else if (WXDATA == 128)
        wr_seq[j].m_size = AXI8B;
        else if (WXDATA == 256)
        wr_seq[j].m_size = AXI16B;
        wr_seq[j].m_burst   = AXIINCR;
        wr_seq[j].m_prot[1] = fill_seq.addr_q[0] >> (WAXADDR - 6);
        wr_seq[j].m_prot[0] = $urandom_range(0,1);
        wr_seq[j].m_prot[2] = $urandom_range(0,1);
        wr_seq[j].m_cache   = WWBRWALLOC;
        wr_seq[j].m_domain  = INNRSHRBL;
        end

         for (int i = wr_seq.size()-1; i >= 0 ; i--) begin
            fork
                automatic int j=i;
                begin
                    wr_seq[j].start(null);
                end
            join_none
        end

   end
        
    begin
        delay_cycles = $urandom_range(200, 4500);
        `uvm_info(get_name(), $sformatf("delay_cycles:%0d", delay_cycles), UVM_LOW);
        #(<%=obj.Clocks[0].params.period%>ps * delay_cycles); //wait for random cycles        
        rd_seq = axi_directed_rd_seq::type_id::create($sformatf("c%0d_rd_seq_%0d", core_id, 0));
            
            rd_seq.core_id               = core_id;
            rd_seq.txn_id      	         = 0;
            rd_seq.m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
            rd_seq.m_read_data_chnl_seqr = m_read_data_chnl_seqr;

            rd_seq.dis_post_randomize = 1;
            rd_seq.m_cmdtype = RDONCE;

            rd_seq.m_addr    = fill_seq.addr_q[0] << 6;    
            rd_seq.m_id      = 0;
            if($test$plusargs("enable_dual_cl_read")) begin
            rd_seq.m_len     = ((2*(SYS_nSysCacheline*8/(WXDATA))) - 1);
            end else begin
            rd_seq.m_len     = ((SYS_nSysCacheline*8/(WXDATA)) - 1);//cache-line size
            end
            if (WXDATA == 64)
                rd_seq.m_size = AXI8B;
            else if (WXDATA == 128)
                rd_seq.m_size = AXI16B;
            else if (WXDATA == 256)
                rd_seq.m_size = AXI32B;
            rd_seq.m_burst   = $urandom_range(0,1) ? AXIINCR : AXIWRAP;
            rd_seq.m_prot[1] = fill_seq.addr_q[0] >> (WAXADDR - 6);
            rd_seq.m_prot[0] = $urandom_range(0,1);
            rd_seq.m_prot[2] = $urandom_range(0,1);
            rd_seq.m_cache   = RWBRWALLOC;
            rd_seq.m_domain  = INNRSHRBL;
            rd_seq.start(null);
   end
   join



        `uvm_info(get_full_name(),"Exiting Body........", UVM_LOW)

endtask:body 

endclass : seq_single_read_multi_write



//*Need to deprecate this sequence since the problem with this is allocating
//are happending to one set for a long time before switching set. As a result
//most the the ccp accesses are turning into nonalloc due to "all ways busy"
//hence switched to a better sequence
//class ioc_stream_of_alloc_ops_some_sets extends axi_master_pipelined_seq;
//    `uvm_object_param_utils(ioc_stream_of_alloc_ops_some_sets)
//
//    eviction_seq   evict_seq[];
//
//    function new(string name = "ioc_stream_of_alloc_ops_some_sets");
//        super.new(name); 
//    endfunction : new
//    
//    task body;
//    evict_seq = new[num_sets];
//
//        `uvm_info(get_full_name(),$sformatf("sequence started num_sets:%0d ", num_sets), UVM_LOW)
//        for(int i=0;i<num_sets;i++) begin
//        automatic int j=i;
//        fork
//        evict_seq[j]                        = eviction_seq::type_id::create($sformatf("c%0d_evict_seq_%0d", core_id, j)); 
//        evict_seq[j].core_id                = core_id;
//        evict_seq[j].m_ace_cache_model      = m_ace_cache_model;
//        evict_seq[j].m_read_addr_chnl_seqr  = m_read_addr_chnl_seqr;
//        evict_seq[j].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
//        evict_seq[j].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
//        evict_seq[j].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
//        evict_seq[j].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
//        evict_seq[j].start(null);
//        join_none;
//        end
//        wait fork;
//        `uvm_info(get_full_name(),$sformatf("sequence done num_sets:%0d ", num_sets), UVM_LOW)
//    endtask:body
//    
//endclass:ioc_stream_of_alloc_ops_some_sets


class ioc_stream_of_alloc_ops_some_sets extends axi_master_pipelined_seq;
    `uvm_object_param_utils(ioc_stream_of_alloc_ops_some_sets)

    function new(string name = "ioc_stream_of_alloc_ops_some_sets");
        super.new(name); 
    endfunction : new
    
    task body;
        int widx;
        int ridx;
        int num_reads;
        int num_writes;
        int num_reads_per_set;
        int num_writes_per_set;
        bit usecache = 1; 
        bit [addrMgrConst::W_SEC_ADDR -1: 0] uaddrq[$];
        bit [addrMgrConst::W_SEC_ADDR -1: 0] waddrq[$];
        bit [addrMgrConst::W_SEC_ADDR -1: 0] rdiiaddrq[$];
        bit [addrMgrConst::W_SEC_ADDR -1: 0] rdmiaddrq[$];
        addrMgrConst::mem_type get_coh_noncoh_type;
        eviction_wr_seq   wr_seq[];
        eviction_rd_seq   rd_seq[];
       
        uaddrq = {};
        num_reads_per_set  = 3000;
        num_writes_per_set = 1000;
        for (int i=0; i < num_sets; i++) begin 
            assert(std::randomize(ccp_setindex));
            waddrq.delete();
            rdiiaddrq.delete();

            get_coh_noncoh_type = addrMgrConst::NONCOH_DII;
            m_addr_mgr.get_addrq_w_fix_set_index(ccp_setindex, <%=obj.FUnitId%>, core_id, num_reads_per_set, rdiiaddrq, get_coh_noncoh_type, usecache);
           
            foreach(rdiiaddrq[i]) begin
                uaddrq.push_back(rdiiaddrq[i]);
            end
            rdiiaddrq = {};
            
            get_coh_noncoh_type = addrMgrConst::COH_DMI;
            m_addr_mgr.get_addrq_w_fix_set_index(ccp_setindex, <%=obj.FUnitId%>, core_id, num_writes_per_set, waddrq, get_coh_noncoh_type, usecache); 

            foreach(waddrq[i]) begin 
                uaddrq.push_back(waddrq[i]); 
            end 
            waddrq = {};
        end

        uaddrq.shuffle();

        num_reads = num_reads_per_set * num_sets;
        num_writes = num_writes_per_set * num_sets;
        
        `uvm_info(get_full_name(),$sformatf("uaddrq.size:%0d num_reads:%0d num_writes:%0d",uaddrq.size(), num_reads, num_writes), UVM_NONE)
        rd_seq = new[num_reads];
        wr_seq = new[num_writes];
        
        ridx = 0;
        widx = 0;
        foreach (uaddrq[i]) begin 
            ccp_setindex = addrMgrConst::get_set_index(uaddrq[i],<%=obj.FUnitId%>);
           // `uvm_info(get_full_name(),$sformatf("i:%0d addr:0x%0h nc:%0b", i, uaddrq[i], addrMgrConst::get_addr_gprar_nc(uaddrq[i])), UVM_LOW)
            if(addrMgrConst::get_addr_gprar_nc(uaddrq[i]) == 1) begin 
                rd_seq[ridx]         = eviction_rd_seq::type_id::create($sformatf("c%0d_setidx_0x%0h_rd_seq_%0d", core_id, ccp_setindex, ridx)); 
                if (rd_seq[ridx] == null)
                    `uvm_error(get_full_name(),$sformatf("weird error i:%0d ridx:%0d",i, ridx))

                rd_seq[ridx].core_id               = core_id;
                rd_seq[ridx].txn_id                = ridx;
                rd_seq[ridx].addr      	           = uaddrq[i];
                rd_seq[ridx].m_ace_cache_model     = m_ace_cache_model;
                rd_seq[ridx].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
                rd_seq[ridx].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
                ridx++;
            end else begin 
                wr_seq[widx]         = eviction_wr_seq::type_id::create($sformatf("c%0d_setidx_0x%0h_wr_seq_%0d", core_id, ccp_setindex, widx)); 
                wr_seq[widx].core_id               = core_id;
                wr_seq[widx].txn_id                = widx;
                wr_seq[widx].addr      	           = uaddrq[i];
                wr_seq[widx].m_ace_cache_model     = m_ace_cache_model;
                wr_seq[widx].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
                wr_seq[widx].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
                wr_seq[widx].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
                widx++;
            end 
        end


        fork 
            begin
                for (int i = rd_seq.size()-1; i >= 0 ; i--) begin
                    fork
                        automatic int j=i;
                        begin
                            rd_seq[j].start(null);
                        end
                    join_none
                end
                //wait fork;
                //`uvm_info(get_full_name(), $sformatf("c%0d Done with all forked read threads", core_id), UVM_LOW)
            end
            begin
                for (int k = wr_seq.size()-1; k >= 0 ; k--) begin
                    fork
                        automatic int m=k;
                        begin
                            wr_seq[m].start(null);
                        end
                    join_none
                end
                //wait fork;
                //`uvm_info(get_full_name(), $sformatf("c%0d Done with all forked write threads", core_id), UVM_LOW)
            end
        join_none
        wait fork;  
    endtask:body
    
endclass:ioc_stream_of_alloc_ops_some_sets

<% } %>

//******************************************************************************
// Section1: Read
// Purpose : Generates a single read transaction.
//******************************************************************************

class axi_single_rd_seq extends axi_master_read_base_seq;

    `uvm_object_param_utils(axi_single_rd_seq)

    `uvm_declare_p_sequencer(axi_virtual_sequencer);
    
    axi_read_addr_seq            m_read_addr_seq;
    axi_read_data_seq            m_read_data_seq;
    axi_rd_seq_item              m_seq_item;
    axi_axaddr_t                 m_addr;
    axi_axlen_t                  m_axlen;
    axi_arid_t                   use_arid;
    axi_axsize_t                 m_size;
    axi_axburst_t                m_burst;
    ace_command_types_enum_t 	 m_cmdtype;
    axi_arcache_enum_t            mcache;

    bit                          success;
    bit                          dis_post_randomize = 0;

    
   <%if((obj.testBench == "io_aiu" && obj.useCache) && (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) {%> 
    bit[<%=Math.log2(obj.nDataBanks)%>-1:0]             sel_bank;
   <%} else {%>
    bit                                                 sel_bank;
   <%}%>

    axi_axprot_t                 m_prot;
<% if((obj.testBench == "dii") || (obj.testBench == "dmi") || (obj.testBench == "io_aiu")|| (obj.testBench == "fsys")) { %>
   `ifdef VCS
    int    illegalCSRAccess_no_EndPoint_order_r_vcs;
    int    address_error_test_data_vcs;
   `endif 
<% }  %>
    function new(string name="axi_single_rd_seq");
      super.new();
<% if((obj.testBench == "dii") || (obj.testBench == "dmi") || (obj.testBench == "io_aiu")|| (obj.testBench == "fsys")) { %>
   `ifdef VCS
        if($test$plusargs("illegalCSRAccess_no_EndPoint_order")) begin
        	illegalCSRAccess_no_EndPoint_order_r_vcs = 1;
        end
        if($test$plusargs("address_error_test_data")) begin
        	address_error_test_data_vcs = 1;
        end
   `endif 
<% }  %>
    endfunction

   task body;
   
       m_read_addr_seq = axi_read_addr_seq::type_id::create("m_read_addr_seq"); 
       m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 
   
                  uvm_report_info(get_full_name(), $sformatf("RD snooptype %0s addr 0x%0x", m_cmdtype.name(), m_addr), UVM_LOW);
                  uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("RD snooptype %0s addr 0x%0x", m_cmdtype.name(), m_addr), UVM_LOW);
    
   
           m_read_addr_seq.should_randomize        = 0;
           
           m_read_addr_seq.m_seq_item  = axi_rd_seq_item::type_id::create("m_seq_item");
   
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.dis_post_randomize = dis_post_randomize;
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.constrained_addr = 1;
           success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid == use_arid;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_cmdtype;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == m_burst;
             <% if((obj.testBench == "dii") || (obj.testBench == "dmi") || (obj.testBench == "io_aiu")|| (obj.testBench == "fsys")) { %>
               `ifndef VCS
               if($test$plusargs("illegalCSRAccess_no_EndPoint_order"))
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache == RNORNCNONBUF;
               else if($test$plusargs("address_error_test_data"))
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache == mcache; 
               `else 
               if(m_cmdtype== RDNOSNP) 
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.coh_domain == 0;
               if(m_cmdtype == RDONCE) 
                    m_read_addr_seq.m_seq_item.m_read_addr_pkt.coh_domain == 1;
               if(illegalCSRAccess_no_EndPoint_order_r_vcs)
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache == RNORNCNONBUF;
               else if(address_error_test_data_vcs)
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache == mcache; 
               `endif  // `ifndef VCS ... `else ...
             <% } else {%>
               if($test$plusargs("illegalCSRAccess_no_EndPoint_order"))
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache == RNORNCNONBUF;
               else if($test$plusargs("address_error_test_data"))
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache == mcache; 
             <% } %>
               else
		m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache == RDEVNONBUF; 
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot == m_prot;
           	   m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsize == m_size;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlock==NORMAL;
           	   m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen  == m_axlen;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr == m_addr; // added to be check on post_randomize function for config with connectivity
   
           };

                      
	<%if((obj.testBench == "io_aiu" && obj.useCache) && (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) {%>
               if($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test") || $test$plusargs("address_error_test_data") || $test$plusargs("address_error_test_data")) begin 
               //Force all addresses in the test to go to DataBank
               <%for( var i=0; i< Math.log2(obj.nDataBanks); i++){%>
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr[<%=obj.AiuInfo[obj.Id].ccpParams.PriSubDiagAddrBits[obj.AiuInfo[obj.Id].ccpParams.DataBankSelBits[i]]%>] = sel_bank[<%=i%>];
              <%}%>
              end
		<%}%>
           
           if (!success) begin
               `uvm_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_master_read_seq"))
           end
           
           `uvm_info("ACE BFM SEQ", $sformatf("Sending RD txn: %0s", m_read_addr_seq.m_seq_item.m_read_addr_pkt.convert2string()), UVM_LOW);
           m_read_addr_seq.return_response(m_seq_item,p_sequencer.m_read_addr_chnl_seqr);
           `uvm_info("ACE BFM SEQ", $sformatf("Sent RD txn: %0s", m_read_addr_seq.m_seq_item.m_read_addr_pkt.convert2string()), UVM_LOW);
           m_read_data_seq.m_seq_item       = m_seq_item;
           m_read_data_seq.should_randomize = 0;
           m_read_data_seq.return_response(m_seq_item,p_sequencer.m_read_data_chnl_seqr);
           `uvm_info("ACE BFM SEQ", $sformatf("Received RD data txn: %0s", m_read_data_seq.m_seq_item.m_read_data_pkt.convert2string()), UVM_LOW);
   
   endtask : body
endclass: axi_single_rd_seq

//******************************************************************************
// Section1: write
// Purpose : Generates a single write transaction.
//******************************************************************************

class axi_single_wr_seq extends axi_master_write_base_seq;

    `uvm_object_param_utils(axi_single_wr_seq)

    `uvm_declare_p_sequencer(axi_virtual_sequencer);

    axi_write_addr_seq            m_write_addr_seq;
    axi_write_data_seq            m_write_data_seq;
    axi_write_resp_seq            m_write_resp_seq;
    axi_wr_seq_item               m_seq_item;
    axi_wr_seq_item               m_seq_item0;
    axi_wr_seq_item               m_seq_item1;
    axi_axaddr_t                  m_addr;
    axi_axlen_t                   m_axlen = 0;
    axi_awid_t                    m_id = 0;
    axi_xdata_t                   m_data;
    axi_axsize_t                  m_size = WLOGXDATA;
    axi_awcache_enum_t            m_cache;
    int                           aiu_qos;
    int                           user_qos;
    bit                           success;
    axi_xstrb_t                   m_wstrb = 64'hffffffffffffffff;
    axi_axburst_t                 m_burst;
    ace_command_types_enum_t 	  m_cmdtype;
    bit                           dis_post_randomize = 0;
    axi_axprot_t                  m_prot;
    axi_axdomain_enum_t           m_domain;
<% if((obj.testBench == "dii") || (obj.testBench == "dmi") || (obj.testBench == "io_aiu")|| (obj.testBench == "fsys")) { %>
   `ifdef VCS
    int    illegalCSRAccess_no_EndPoint_order_w_vcs;
   `endif 
<% }  %>
    function new(string name="axi_single_wr_seq");
      super.new();
<% if((obj.testBench == "dii") || (obj.testBench == "dmi") || (obj.testBench == "io_aiu")|| (obj.testBench == "fsys")) { %>
   `ifdef VCS
        if($test$plusargs("illegalCSRAccess_no_EndPoint_order")) begin
        	illegalCSRAccess_no_EndPoint_order_w_vcs = 1;
        end
   `endif 
<% }  %>
    endfunction

    task body;
   
       if($value$plusargs("aiu_qos=%d", aiu_qos)) begin
          user_qos = 1;
       end
       m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq"); 
       m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq");
       m_write_addr_seq.core_id = core_id; 
       m_write_data_seq.core_id = core_id; 
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
       m_write_addr_seq.s_wr_addr = s_wr_addr; 
       m_write_data_seq.s_wr_data = s_wr_data; 
       m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq"); 
       m_write_resp_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
       m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
               m_write_addr_seq.m_ace_wr_addr_chnl_snoop = m_cmdtype;
   
                  uvm_report_info("ACE BFM SEQ", $sformatf("WR snooptype %0s addr 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_ace_wr_addr_chnl_addr), UVM_MEDIUM);
                  uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("WR snooptype %0s addr 0x%0x secure bit 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_ace_wr_addr_chnl_addr, 
          <% if (obj.wSecurityAttribute > 0) { %>                                             
                  m_write_addr_seq.m_ace_wr_addr_chnl_security 
          <% } else { %>                                                
                  0
          <% } %>
       ), UVM_MEDIUM);
    
   
           m_write_addr_seq.m_constraint_snoop      = 1;
           m_write_addr_seq.m_constraint_addr       = 0;
           m_write_addr_seq.should_randomize        = 0;
           
           m_write_addr_seq.m_seq_item  = axi_wr_seq_item::type_id::create("m_seq_item");
   
     success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_cmdtype;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst == m_burst;
             <% if((obj.testBench == "dii") || (obj.testBench == "dmi") || (obj.testBench == "io_aiu")|| (obj.testBench == "fsys")) { %>
               `ifndef VCS
               if($test$plusargs("illegalCSRAccess_no_EndPoint_order"))
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache == WNORNCNONBUF;
               `else 
               if(illegalCSRAccess_no_EndPoint_order_w_vcs)
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache == WNORNCNONBUF;
               `endif  // `ifndef VCS ... `else ...
             <% } else {%>
               if($test$plusargs("illegalCSRAccess_no_EndPoint_order"))
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache == WNORNCNONBUF;
             <% } %>
               else        
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache == m_cache;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot == m_prot;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlock== NORMAL;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr == m_addr;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid == m_id;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awdomain == m_domain;
   	       if (user_qos)   m_write_addr_seq.m_seq_item.m_write_addr_pkt.awqos == aiu_qos;
   
           };
           
           if (!success) begin
               `uvm_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_master_write_seq"))
           end
           
           m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid   = m_id;
           m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen  = m_axlen;
       m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize = m_size;
   `uvm_info("ACE BFM SEQ", $sformatf("WR snooptype %0s addr 0x%0x Len 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), 
                                           m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen), UVM_HIGH);

        m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        success = m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        
        foreach(m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[idx]) begin
            m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[idx] = m_data + (idx*(WXDATA/8));
        end
        begin
            axi_axaddr_t addr_tmp = m_addr;
            int size_p2, size_up;
            size_p2 = 2**m_size;
            for (int j = 0; j <= m_axlen; j++) begin
                size_up = size_p2 - (addr_tmp%size_p2);
                for (int i = 0; i < size_up; i++) begin
                    m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[j][addr_tmp%(WXDATA/8) + i] = 'b1;
                end
                addr_tmp += size_up;
            end
        end

        m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;
        m_write_addr_seq.should_randomize = 0;
        m_write_data_seq.should_randomize = 0;
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        s_wr_addr[core_id].get();
        s_wr_data[core_id].get();
        fork 
            begin
                m_write_addr_seq.return_response(m_seq_item0, p_sequencer.m_write_addr_chnl_seqr);
            end
            begin
                m_write_data_seq.return_response(m_seq_item1, p_sequencer.m_write_data_chnl_seqr);
            end
        join
        m_write_resp_seq.should_randomize = 0;
        m_write_resp_seq.m_seq_item       = m_seq_item0;
        m_write_resp_seq.return_response(m_seq_item0, p_sequencer.m_write_resp_chnl_seqr);
   
   endtask : body
endclass: axi_single_wr_seq



//******************************************************************************
// Section1: WriteNosnoop
// Purpose : Generates a single WriteNoSnoop transaction.
//******************************************************************************
class axi_single_wrnosnp_seq extends axi_master_write_base_seq;

    `uvm_object_param_utils(axi_single_wrnosnp_seq)
    
    `uvm_declare_p_sequencer(axi_virtual_sequencer);

    axi_write_addr_seq            m_write_addr_seq;
    axi_write_data_seq            m_write_data_seq;
    axi_write_resp_seq            m_write_resp_seq;
    axi_wr_seq_item               m_seq_item;
    axi_wr_seq_item               m_seq_item0;
    axi_wr_seq_item               m_seq_item1;
    axi_axaddr_t                  m_addr;
    axi_axlen_t                   m_axlen = 0;
    axi_awid_t                    use_awid = 0;
    axi_xdata_t                   m_data;
    axi_axsize_t                  m_size = WLOGXDATA;
    int aiu_qos;
    int user_qos;
    bit                           success;
    axi_xstrb_t                   m_wstrb = 64'hffffffffffffffff;
    bit ioaiu_csr_ns_access;

    function new(string name="axi_single_wrnosnp_seq");
      super.new();
      user_qos = 0;
    endfunction


   task body;
   
    if($value$plusargs("aiu_qos=%d", aiu_qos)) begin
       user_qos = 1;
    end
       m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq"); 
       m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq");
       m_write_addr_seq.core_id = core_id; 
       m_write_data_seq.core_id = core_id; 
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
       m_write_addr_seq.s_wr_addr = s_wr_addr; 
       m_write_data_seq.s_wr_data = s_wr_data; 
       m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq"); 
       m_write_resp_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
       m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
               m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRNOSNP;
   
                  uvm_report_info("ACE BFM SEQ", $sformatf("WR snooptype %0s addr 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_ace_wr_addr_chnl_addr), UVM_MEDIUM);
                  uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("WR snooptype %0s addr 0x%0x secure bit 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_ace_wr_addr_chnl_addr, 
          <% if (obj.wSecurityAttribute > 0) { %>                                             
                  m_write_addr_seq.m_ace_wr_addr_chnl_security 
          <% } else { %>                                                
                  0
          <% } %>
       ), UVM_MEDIUM);
    
   
           m_write_addr_seq.m_constraint_snoop      = 1;
           m_write_addr_seq.m_constraint_addr       = 0;
           m_write_addr_seq.should_randomize        = 0;
           
           m_write_addr_seq.m_seq_item  = axi_wr_seq_item::type_id::create("m_seq_item");
         
   
   
           m_write_addr_seq.m_seq_item.m_write_addr_pkt.constrained_addr = 1;
     success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
`ifdef VCS
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == WRNOSNP;
`else
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
`endif
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst == AXIINCR;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache == WDEVNONBUF;
               //m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]==0;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlock==NORMAL;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr == m_addr; // added to be check on post_randomize function for config with connectivity
`ifdef VCS
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen == 1; // To not have narrow data transfers awsize<log2(datawidth), Later on will override it.
`endif
   	       if (user_qos)   m_write_addr_seq.m_seq_item.m_write_addr_pkt.awqos == aiu_qos;
   
           };
           
           if (!success) begin
               `uvm_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_master_write_seq"))
           end
           
           m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid   = use_awid;
           m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen  = m_axlen;
           m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1] = (ioaiu_csr_ns_access) ? 1 : 0;
       m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize = m_size;
   `uvm_info("ACE BFM SEQ", $sformatf("WR snooptype %0s addr 0x%0x Len 0x%0x NonSecure 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), 
                                           m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]), UVM_NONE);

        m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        success = m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        
        foreach(m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[idx]) begin
            m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[idx] = m_data + (idx*(WXDATA/8));
            m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[idx] = m_wstrb;  //Assigning to max value
        end

        m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;
        m_write_addr_seq.should_randomize = 0;
        m_write_data_seq.should_randomize = 0;
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        s_wr_addr[core_id].get();
        s_wr_data[core_id].get();
        fork 
            begin
                m_write_addr_seq.return_response(m_seq_item0, p_sequencer.m_write_addr_chnl_seqr);
            end
            begin
                m_write_data_seq.return_response(m_seq_item1, p_sequencer.m_write_data_chnl_seqr);
            end
        join
        m_write_resp_seq.should_randomize = 0;
        m_write_resp_seq.m_seq_item       = m_seq_item0;
        m_write_resp_seq.return_response(m_seq_item0, p_sequencer.m_write_resp_chnl_seqr);
   
   endtask : body
endclass: axi_single_wrnosnp_seq


//******************************************************************************
// Section1: WriteNosnoop/WriteUnique
// Purpose : Generates a WriteNoSnoop/Write Unique transaction.
//******************************************************************************
class axi_wrnosnp_wrunq_seq extends axi_master_write_base_seq;

    `uvm_object_param_utils(axi_wrnosnp_wrunq_seq)
    
    `uvm_declare_p_sequencer(axi_virtual_sequencer);

    axi_write_addr_seq            m_write_addr_seq;
    axi_write_data_seq            m_write_data_seq;
    axi_write_resp_seq            m_write_resp_seq;
    axi_wr_seq_item               m_seq_item;
    axi_wr_seq_item               m_seq_item0;
    axi_wr_seq_item               m_seq_item1;
    axi_axaddr_t                  m_addr;
    axi_axlen_t                   m_axlen;
    axi_awid_t                    use_awid;
    axi_xdata_t                   m_data[4];
    axi_axsize_t                  m_size;
    bit                           success;
    bit [3:0]                     cache_val_dist;
    axi_xstrb_t                   m_wstrb;
    bit                           m_coh_transaction;
<% if((obj.Block === 'aiu') || (obj.Block === 'io_aiu')) { %>
    bit                           generate_per_beat_strb=0;
    ace_cache_model               m_ace_cache_model;
<% } %>    

    function new(string name="axi_wrnosnp_wrunq_seq");
      super.new();
    endfunction


   task body;
     axi_xdata_t data[];
   
       m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq"); 
       m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq"); 
       m_write_addr_seq.core_id = core_id; 
       m_write_data_seq.core_id = core_id;
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
       m_write_addr_seq.s_wr_addr = s_wr_addr; 
       m_write_data_seq.s_wr_data = s_wr_data; 
       m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq"); 
       m_write_resp_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
       m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");

       if (m_coh_transaction == 0) begin
           m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRNOSNP;
       end
       else begin
           m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRUNQ;
       end
                  uvm_report_info("ACE BFM SEQ", $sformatf("RD snooptype %0s addr 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_ace_wr_addr_chnl_addr), UVM_MEDIUM);
                  uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("WR snooptype %0s addr 0x%0x secure bit 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_ace_wr_addr_chnl_addr, 
          <% if (obj.wSecurityAttribute > 0) { %>                                             
                  m_write_addr_seq.m_ace_wr_addr_chnl_security 
          <% } else { %>                                                
                  0
          <% } %>
       ), UVM_MEDIUM);
    
   
           m_write_addr_seq.m_constraint_snoop      = 1;
           m_write_addr_seq.m_constraint_addr       = 0;
           m_write_addr_seq.should_randomize        = 0;
           
           m_write_addr_seq.m_seq_item  = axi_wr_seq_item::type_id::create("m_seq_item");
         
   
   
     // get_axid(m_write_addr_seq.m_ace_wr_addr_chnl_snoop, use_awid);
     use_awid = 0;
     if (m_coh_transaction == 0) begin
       success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid == use_awid;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst == AXIINCR;
               //m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache == WDEVNONBUF;
<% if(obj.testBench == "fsys" || obj.testBench == 'io_aiu') { %>
`ifdef VCS // CONC-11829
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.coh_domain == 0;
`endif
<% } %>
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr  == m_addr;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]==0;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlock==NORMAL;
   
           };
           if(addrMgrConst::is_dii_addr(m_addr)) begin
             m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache = WDEVNONBUF;
           end else if(addrMgrConst::is_dmi_addr(m_addr)) begin
             cache_val_dist = $urandom();
             if(cache_val_dist==2)
                 m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache = WNORNCNONBUF;
           end
     end
     else begin
        success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid == use_awid;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst == AXIINCR;
//               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache == WWTRWALLOC;   //WNORNCNONBUF;
<% if(obj.testBench == "fsys" || obj.testBench == 'io_aiu') { %>
`ifdef VCS // CONC-11829
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.coh_domain == 1;
`endif
<% } %>
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]==0;   
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr==m_addr;   
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlock==NORMAL;
           };
     end
           
           if (!success) begin
               `uvm_error("VS", $sformatf("TB Error: Could not randomize packet in axi_master_write_seq coh=%0d", m_coh_transaction))
           end
           
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr = m_addr;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen  = m_axlen;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize = m_size;
           `uvm_info("ACE BFM SEQ", $sformatf("WR snooptype %0s addr 0x%0x Len 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), 
                                           m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen), UVM_HIGH);

        m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        success = m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[0] = m_data[0];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[0] = m_wstrb;  //Assigning to max value
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[1] = m_data[1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[1] = m_wstrb;  //Assigning to max value
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[2] = m_data[2];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[2] = m_wstrb;  //Assigning to max value
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[3] = m_data[3];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[3] = m_wstrb;  //Assigning to max value
<% if((obj.Block === 'aiu') || (obj.Block === 'io_aiu')) { %>
        if(generate_per_beat_strb==1) begin
            m_ace_cache_model.give_data_for_ace_req(m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_ace_wr_addr_chnl_snoop, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize, data /*m_write_data_seq.m_seq_item.m_write_data_pkt.wdata*/, m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]
<% } %>                                                
            );
        end
<% } %>    
        
        m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;
        m_write_addr_seq.should_randomize = 0;
        m_write_data_seq.should_randomize = 0;
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        s_wr_addr[core_id].get();
        s_wr_data[core_id].get();
        fork 
            begin
                m_write_addr_seq.return_response(m_seq_item0, p_sequencer.m_write_addr_chnl_seqr);
            end
            begin
                m_write_data_seq.return_response(m_seq_item1, p_sequencer.m_write_data_chnl_seqr);
            end
        join
        m_write_resp_seq.should_randomize = 0;
        m_write_resp_seq.m_seq_item       = m_seq_item0;
        m_write_resp_seq.return_response(m_seq_item0, p_sequencer.m_write_resp_chnl_seqr);
   
   endtask : body
endclass: axi_wrnosnp_wrunq_seq

<% if((obj.Block === 'aiu') || (obj.Block === 'io_aiu') || (obj.Block === 'mem' && obj.is_master === 1)) { %>
//******************************************************************************
// Section1: ReadNosnoop
// Purpose : Generates ReadNoSnoop transaction with specified len.
//******************************************************************************

class axi_rdnosnp_seq extends axi_master_read_base_seq;

    `uvm_object_param_utils(axi_rdnosnp_seq)

    `uvm_declare_p_sequencer(axi_virtual_sequencer);
    
    axi_read_addr_seq            m_read_addr_seq;
    axi_read_data_seq            m_read_data_seq;
    axi_rd_seq_item              m_seq_item;
    axi_axaddr_t                 m_addr;
    axi_axlen_t                  m_len = 0;
    axi_axsize_t                 m_size = WLOGXDATA;
    axi_arid_t                   use_arid = 0;
    int aiu_qos;
    int user_qos;
    bit                          success;
    bit [3:0]                    cache_val_dist;

    ace_cache_model              m_ace_cache_model;

    function new(string name="axi_rdnosnp_seq");
      super.new(); 
      user_qos = 0;
    endfunction


   task body;
   
    if($value$plusargs("aiu_qos=%d", aiu_qos)) begin
       user_qos = 1;
    end

       m_read_addr_seq = axi_read_addr_seq::type_id::create("m_read_addr_seq"); 
       m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 
       m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDNOSNP;
   
       uvm_report_info("ACE BFM SEQ", $sformatf("RD snooptype %0s addr 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), m_read_addr_seq.m_ace_rd_addr_chnl_addr), UVM_MEDIUM);
       uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("RD snooptype %0s addr 0x%0x secure bit 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), m_read_addr_seq.m_ace_rd_addr_chnl_addr, 
          <% if (obj.wSecurityAttribute > 0) { %>                                             
                  m_read_addr_seq.m_ace_rd_addr_chnl_security 
          <% } else { %>                                                
                  0
          <% } %>
       ), UVM_MEDIUM);
    
   
           m_read_addr_seq.m_constraint_snoop      = 1;
           m_read_addr_seq.m_constraint_addr       = 0;
           m_read_addr_seq.should_randomize        = 0;
           
           m_read_addr_seq.m_seq_item  = axi_rd_seq_item::type_id::create("m_seq_item");
         
   
   
           success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == AXIINCR;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr  == m_addr;
               //m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache == RNORNCNONBUF; //cmted out to fix randomization issue
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1]==0;
<% if(obj.testBench == "fsys" || obj.testBench == 'io_aiu') { %>
`ifdef VCS // CONC-11829
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.coh_domain==0;
`endif
<% } %>
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlock==NORMAL;   
   	       if (user_qos)   m_read_addr_seq.m_seq_item.m_read_addr_pkt.arqos == aiu_qos;
           };
           if(addrMgrConst::is_dii_addr(m_addr)) begin
             m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache = RDEVNONBUF;
           end else if(addrMgrConst::is_dmi_addr(m_addr)) begin
             cache_val_dist = $urandom();
             if(cache_val_dist==2)
                 m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache = RNORNCNONBUF;
           end
           
           if (!success) begin
               `uvm_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_master_read_seq"))
           end
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr = m_addr;
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid   = use_arid;
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen  = m_len;
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsize = m_size;
           if($test$plusargs("k_axcache_0_to_dii")) begin
	        if(m_ace_cache_model.m_addr_mgr.get_addr_target_unit(m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr) == 1) begin
	            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[3:1] = 3'b000;
	            if(m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == RDNOSNP) m_read_addr_seq.m_seq_item.m_read_addr_pkt.ardomain = axi_axdomain_enum_t'(3);
	        end
           end
           
           `uvm_info("ACE BFM SEQ", $sformatf("RD snooptype %0s addr 0x%0x Len 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), 
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr, m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen), UVM_HIGH);
           m_read_addr_seq.return_response(m_seq_item,p_sequencer.m_read_addr_chnl_seqr);
           m_read_data_seq.m_seq_item       = m_seq_item;
           m_read_data_seq.should_randomize = 0;
           m_read_data_seq.return_response(m_seq_item,p_sequencer.m_read_data_chnl_seqr);
   
   
   endtask : body
endclass: axi_rdnosnp_seq

//******************************************************************************
// Section1: ReadUnique
// Purpose : Generates ReadUnique transaction with specified len.
//******************************************************************************

class axi_rdunq_seq extends axi_master_read_base_seq;

    `uvm_object_param_utils(axi_rdunq_seq)

    `uvm_declare_p_sequencer(axi_virtual_sequencer);
    
    axi_read_addr_seq            m_read_addr_seq;
    axi_read_data_seq            m_read_data_seq;
    axi_rd_seq_item              m_seq_item;
    axi_axaddr_t                 m_addr;
    axi_axlen_t                  m_len;
    axi_arid_t                   use_arid;
    axi_axsize_t                 m_size;
    int aiu_qos;
    int user_qos;
    bit                          success;

    ace_cache_model              m_ace_cache_model;

    function new(string name="axi_rdunq_seq");
      super.new();
      m_size = WLOGXDATA;
      user_qos = 0;
    endfunction


   task body;
   
    if($value$plusargs("aiu_qos=%d", aiu_qos)) begin
       user_qos = 1;
    end
       m_read_addr_seq = axi_read_addr_seq::type_id::create("m_read_addr_seq"); 
       m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 
       m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDUNQ;
   
       uvm_report_info("ACE BFM SEQ", $sformatf("RD snooptype %0s addr 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), m_read_addr_seq.m_ace_rd_addr_chnl_addr), UVM_MEDIUM);
       uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("RD snooptype %0s addr 0x%0x secure bit 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), m_read_addr_seq.m_ace_rd_addr_chnl_addr, 
          <% if (obj.wSecurityAttribute > 0) { %>                                             
                  m_read_addr_seq.m_ace_rd_addr_chnl_security 
          <% } else { %>                                                
                  0
          <% } %>
       ), UVM_MEDIUM);
    
   
           m_read_addr_seq.m_constraint_snoop      = 1;
           m_read_addr_seq.m_constraint_addr       = 0;
           m_read_addr_seq.should_randomize        = 0;
           
           m_read_addr_seq.m_seq_item  = axi_rd_seq_item::type_id::create("m_seq_item");
         
   
   
           success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid == use_arid;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == AXIINCR;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1]==0;
   	       if (user_qos)   m_read_addr_seq.m_seq_item.m_read_addr_pkt.arqos == aiu_qos;
   
           };
           
           if (!success) begin
               `uvm_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_master_read_seq"))
           end
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr = m_addr;
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen  = m_len;
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsize = m_size;
           if($test$plusargs("k_axcache_0_to_dii")) begin
	        if(m_ace_cache_model.m_addr_mgr.get_addr_target_unit(m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr) == 1) begin
	            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[3:1] = 3'b000;
	        end
           end
           
           `uvm_info("ACE BFM SEQ", $sformatf("RD snooptype %0s addr 0x%0x Len 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), 
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr, m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen), UVM_HIGH);
           m_read_addr_seq.return_response(m_seq_item,p_sequencer.m_read_addr_chnl_seqr);
           m_read_data_seq.m_seq_item       = m_seq_item;
           m_read_data_seq.should_randomize = 0;
           m_read_data_seq.return_response(m_seq_item,p_sequencer.m_read_data_chnl_seqr);
   
   
   endtask : body
endclass: axi_rdunq_seq
   

class axi_rdonce_seq extends axi_master_read_base_seq;

    `uvm_object_param_utils(axi_rdonce_seq)

    `uvm_declare_p_sequencer(axi_virtual_sequencer);
    
    axi_read_addr_seq            m_read_addr_seq;
    axi_read_data_seq            m_read_data_seq;
    axi_rd_seq_item              m_seq_item;
    axi_axaddr_t                 m_addr;
    axi_axlen_t                  m_len;
    axi_arid_t                   use_arid;
    axi_axsize_t                 m_size;
    bit                          success;
    int aiu_qos;
    int user_qos;

    ace_cache_model              m_ace_cache_model;

    function new(string name="axi_rdonce_seq");
      super.new();
      m_size = WLOGXDATA;
      use_arid = 0;
      user_qos = 0;
    endfunction


   task body;
   
    if($value$plusargs("aiu_qos=%d", aiu_qos)) begin
       user_qos = 1;
    end

       m_read_addr_seq = axi_read_addr_seq::type_id::create("m_read_addr_seq"); 
       m_read_data_seq = axi_read_data_seq::type_id::create("m_read_data_seq"); 
       m_read_addr_seq.m_ace_rd_addr_chnl_snoop = RDONCE;
   
       uvm_report_info("ACE BFM SEQ", $sformatf("RD snooptype %0s addr 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), m_read_addr_seq.m_ace_rd_addr_chnl_addr), UVM_MEDIUM);
       uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("RD snooptype %0s addr 0x%0x secure bit 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), m_read_addr_seq.m_ace_rd_addr_chnl_addr, 
          <% if (obj.wSecurityAttribute > 0) { %>                                             
                  m_read_addr_seq.m_ace_rd_addr_chnl_security 
          <% } else { %>                                                
                  0
          <% } %>
       ), UVM_MEDIUM);
    
   
           m_read_addr_seq.m_constraint_snoop      = 1;
           m_read_addr_seq.m_constraint_addr       = 0;
           m_read_addr_seq.should_randomize        = 0;
           
           m_read_addr_seq.m_seq_item  = axi_rd_seq_item::type_id::create("m_seq_item");
         
   
   
           success = m_read_addr_seq.m_seq_item.m_read_addr_pkt.randomize() with {
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid == use_arid;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcmdtype == m_read_addr_seq.m_ace_rd_addr_chnl_snoop;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arburst == AXIINCR;
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr  == m_addr;
<% if(obj.testBench == "fsys" || obj.testBench == 'io_aiu') { %>
`ifdef VCS // CONC-11829
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.coh_domain == 1;
`endif
<% } %>
               m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1]==0;
   	       if (user_qos)   m_read_addr_seq.m_seq_item.m_read_addr_pkt.arqos == aiu_qos;

           };
           
           if (!success) begin
               `uvm_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_master_read_seq"))
           end
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr = m_addr;
	   m_read_addr_seq.m_seq_item.m_read_addr_pkt.arid   = use_arid;
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen  = m_len;
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsize = m_size;
           if($test$plusargs("k_axcache_0_to_dii")) begin
	        if(m_ace_cache_model.m_addr_mgr.get_addr_target_unit(m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr) == 1) begin
	            m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[3:1] = 3'b000;
	        end
           end

           `uvm_info("ACE BFM SEQ", $sformatf("RD snooptype %0s addr 0x%0x Len 0x%0x", m_read_addr_seq.m_ace_rd_addr_chnl_snoop.name(), 
           m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr, m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen), UVM_HIGH);
  // VS         m_read_data_seq.m_seq_item       = m_seq_item;
           m_read_data_seq.should_randomize = 0;
           m_read_addr_seq.return_response(m_seq_item,p_sequencer.m_read_addr_chnl_seqr);
           m_read_data_seq.m_seq_item       = m_seq_item;  // VS
           m_read_data_seq.return_response(m_seq_item,p_sequencer.m_read_data_chnl_seqr);
   
   endtask : body
endclass: axi_rdonce_seq
//******************************************************************************
// Section1: WriteUnique
// Purpose : IOAIU Write BW seq
//******************************************************************************
class ioaiu_write_bw_seq extends axi_master_write_base_seq;

    `uvm_object_param_utils(ioaiu_write_bw_seq)

    `uvm_declare_p_sequencer(axi_virtual_sequencer);

    axi_write_addr_seq            m_write_addr_seq;
    axi_write_data_seq            m_write_data_seq;
    axi_write_resp_seq            m_write_resp_seq;
    axi_wr_seq_item               m_seq_item;
    axi_wr_seq_item               m_seq_item0;
    axi_wr_seq_item               m_seq_item1;
    axi_axaddr_t                  m_addr;
    axi_axlen_t                   m_axlen;
    axi_awid_t                    use_awid;
    axi_xdata_t                   m_data;
    axi_axsize_t                  m_size;
    bit                           success;
    axi_xstrb_t                   m_wstrb = '1;
    iocache_addr_gen              m_iocache_addr_gen;
    addr_trans_mgr                m_addr_mgr;
    rand  axi_axsize_t            m_awsize;
    bit                           use_awaddr;

    function new(string name="ioaiu_write_bw_seq");
      super.new();
    endfunction
													   
    constraint c_awsize_1 {
        (WXDATA == 8)    -> m_awsize == AXI1B;
        (WXDATA == 16)   -> m_awsize == AXI2B;
        (WXDATA == 32)   -> m_awsize == AXI4B;
        (WXDATA == 64)   -> m_awsize == AXI8B;
        (WXDATA == 128)  -> m_awsize == AXI16B;
        (WXDATA == 256)  -> m_awsize == AXI32B;
        (WXDATA == 512)  -> m_awsize == AXI64B;
        (WXDATA == 1024) -> m_awsize == AXI128B;
    };

   task body;
       m_addr_mgr = addr_trans_mgr::get_instance();

       m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq");
       m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq");
       m_write_addr_seq.core_id = core_id; 
       m_write_data_seq.core_id = core_id;
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
       m_write_addr_seq.s_wr_addr = s_wr_addr; 
       m_write_data_seq.s_wr_data = s_wr_data; 
       m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq");
       m_write_resp_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
       m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
       m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRUNQ;

       uvm_report_info("ACE BFM SEQ", $sformatf("RD snooptype %0s addr 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_ace_wr_addr_chnl_addr), UVM_MEDIUM);
       uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("WR snooptype %0s addr 0x%0x secure bit 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_ace_wr_addr_chnl_addr,
          <% if (obj.wSecurityAttribute > 0) { %>
                  m_write_addr_seq.m_ace_wr_addr_chnl_security
          <% } else { %>
                  0
          <% } %>
       ), UVM_MEDIUM);


           m_write_addr_seq.m_constraint_snoop      = 1;
           m_write_addr_seq.m_constraint_addr       = 0;
           m_write_addr_seq.should_randomize        = 0;

           m_write_addr_seq.m_seq_item  = axi_wr_seq_item::type_id::create("m_seq_item");
           m_iocache_addr_gen = new;
           m_iocache_addr_gen.addr = m_addr_mgr.get_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, 0, core_id);

     success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid == use_awid;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst == AXIINCR;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache == WNORNCNONBUF;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]==0;
           };

           if (!success) begin
               `uvm_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_master_write_seq"))
           end

	       if(use_awaddr)
                 m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr = m_addr;
	       else												   
                 m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr = m_iocache_addr_gen.addr;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr = (m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr >> $clog2((m_axlen+1)*WXDATA/8)) << $clog2((m_axlen+1)*WXDATA/8);
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen  = m_axlen;
               assert(randomize(m_awsize));
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize  = m_awsize;
           `uvm_info("ACE BFM SEQ", $sformatf("WR snooptype %0s addr 0x%0x Len 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(),
                                           m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen), UVM_HIGH);

        m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        success = m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];

        foreach(m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[idx]) begin
            m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[idx] = m_data + idx;
            m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[idx] = m_wstrb;
        end

        m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;
        m_write_addr_seq.should_randomize = 0;
        m_write_data_seq.should_randomize = 0;
        fork
            begin
                m_write_addr_seq.return_response(m_seq_item0, p_sequencer.m_write_addr_chnl_seqr);
            end
            begin
                m_write_data_seq.return_response(m_seq_item1, p_sequencer.m_write_data_chnl_seqr);
            end
        join
        m_write_resp_seq.should_randomize = 0;
        m_write_resp_seq.m_seq_item       = m_seq_item0;
        m_write_resp_seq.return_response(m_seq_item0, p_sequencer.m_write_resp_chnl_seqr);

   endtask : body
endclass: ioaiu_write_bw_seq

//******************************************************************************
// Section1: WriteUnique
// Purpose : IOAIU Write BW seq
//******************************************************************************
class axi_single_wrunq_seq extends axi_master_write_base_seq;

    `uvm_object_param_utils(axi_single_wrunq_seq)
    
    `uvm_declare_p_sequencer(axi_virtual_sequencer);

    axi_write_addr_seq            m_write_addr_seq;
    axi_write_data_seq            m_write_data_seq;
    axi_write_resp_seq            m_write_resp_seq;
    axi_wr_seq_item               m_seq_item;
    axi_wr_seq_item               m_seq_item0;
    axi_wr_seq_item               m_seq_item1;
    axi_axaddr_t                  m_addr;
    axi_axlen_t                   m_axlen = 0;
    axi_awid_t                    use_awid = 0;
    axi_xdata_t                   m_data;
    axi_axsize_t                  m_size = WLOGXDATA;
    bit                           success;
    bit                           is_coh;
    bit                           addr_gen_failure;
    axi_xstrb_t                   m_wstrb = 64'hffffffffffffffff;
    int aiu_qos;
    int user_qos;
    addr_trans_mgr                m_addr_mgr;
    ace_cache_model               m_ace_cache_model;

    function new(string name="axi_single_wrunq_seq");
      super.new();
      m_size = WLOGXDATA;
      m_axlen = 0;
      user_qos = 0;
    endfunction


   task body;
       
    if($value$plusargs("aiu_qos=%d", aiu_qos)) begin
       user_qos = 1;
    end

       m_addr_mgr = addr_trans_mgr::get_instance(); 
        
       m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq"); 
       m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq"); 
       m_write_addr_seq.core_id = core_id; 
       m_write_data_seq.core_id = core_id;
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
       m_write_addr_seq.s_wr_addr = s_wr_addr; 
       m_write_data_seq.s_wr_data = s_wr_data; 
       m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq"); 
       m_write_resp_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
       m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
       m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRUNQ;
   
       uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("WR snooptype %0s addr 0x%0x secure bit 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_ace_wr_addr_chnl_addr, 
          <% if (obj.wSecurityAttribute > 0) { %>                                             
                  m_write_addr_seq.m_ace_wr_addr_chnl_security 
          <% } else { %>                                                
                  0
          <% } %>
       ), UVM_MEDIUM);
    
   
           m_write_addr_seq.m_constraint_snoop      = 1;
           m_write_addr_seq.m_constraint_addr       = 0;
           m_write_addr_seq.should_randomize        = 0;
           
           m_write_addr_seq.m_seq_item  = axi_wr_seq_item::type_id::create("m_seq_item");

     success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid == use_awid;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst == AXIINCR;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache == WWTRWALLOC;   //WNORNCNONBUF;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]==0;   
   	       if (user_qos)   m_write_addr_seq.m_seq_item.m_write_addr_pkt.awqos == aiu_qos;
           };
           
           if (!success) begin
               `uvm_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_master_write_seq"))
           end
           m_ace_cache_model.give_addr_for_ace_req_noncoh_write(0, m_write_addr_seq.m_ace_wr_addr_chnl_snoop, m_write_addr_seq.m_ace_wr_addr_chnl_addr
								<% if (obj.wSecurityAttribute > 0) { %>                                             
								,m_write_addr_seq.m_ace_wr_addr_chnl_security
								<% } %>
                                                                ,is_coh
								,0, 0
								<% if (obj.wSecurityAttribute > 0) { %>                                             
								,0
								<% } %>
                                                                ,.addr_gen_failure(addr_gen_failure)
								);
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr = m_write_addr_seq.m_ace_wr_addr_chnl_addr;
               /* m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr[$clog2(SYS_nSysCacheline)-1:0] = 0;//TODO */ 
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr[7:0] = 0;//TODO: align to 256B
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen  = m_axlen;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize = m_size;
           `uvm_info("ACE BFM SEQ", $sformatf("WR snooptype %0s addr 0x%0x Len 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), 
                                           m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen), UVM_HIGH);

        m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        success = m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];

        foreach(m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[idx]) begin        
            m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[idx] = m_data + idx;
            m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[idx] = m_wstrb;
        end
        
        m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;
        m_write_addr_seq.should_randomize = 0;
        m_write_data_seq.should_randomize = 0;
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        s_wr_addr[core_id].get();
        s_wr_data[core_id].get();
        fork 
            begin
                m_write_addr_seq.return_response(m_seq_item0, p_sequencer.m_write_addr_chnl_seqr);
            end
            begin
                m_write_data_seq.return_response(m_seq_item1, p_sequencer.m_write_data_chnl_seqr);
            end
        join
        m_write_resp_seq.should_randomize = 0;
        m_write_resp_seq.m_seq_item       = m_seq_item0;
        m_write_resp_seq.return_response(m_seq_item0, p_sequencer.m_write_resp_chnl_seqr);
   
   endtask : body
endclass: axi_single_wrunq_seq

//******************************************************************************
// Section1: WriteUnique
// Purpose : IOAIU Write BW seq
//******************************************************************************
class axi_single_wrunq_data_seq extends axi_master_write_base_seq;

    `uvm_object_param_utils(axi_single_wrunq_data_seq)
    
    `uvm_declare_p_sequencer(axi_virtual_sequencer);

    axi_write_addr_seq            m_write_addr_seq;
    axi_write_data_seq            m_write_data_seq;
    axi_write_resp_seq            m_write_resp_seq;
    axi_wr_seq_item               m_seq_item;
    axi_wr_seq_item               m_seq_item0;
    axi_wr_seq_item               m_seq_item1;
    axi_axaddr_t                  m_addr;
    axi_axlen_t                   m_axlen = 0;
    axi_axsize_t                  m_size = WLOGXDATA;
    axi_awid_t                    use_awid = 0;
    axi_xdata_t                   m_data;
    axi_xstrb_t                   m_wstrb;
    bit                           success;
    bit                           is_coh;
    int aiu_qos;
    int user_qos;
    addr_trans_mgr                m_addr_mgr;
    ace_cache_model               m_ace_cache_model;

    function new(string name="axi_single_wrunq_data_seq");
      super.new();
      user_qos = 0;
    endfunction


   task body;
       
    if($value$plusargs("aiu_qos=%d", aiu_qos)) begin
       user_qos = 1;
    end

       m_addr_mgr = addr_trans_mgr::get_instance(); 
        
       m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq"); 
       m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq");
       m_write_addr_seq.core_id = core_id; 
       m_write_data_seq.core_id = core_id;
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
       m_write_addr_seq.s_wr_addr = s_wr_addr; 
       m_write_data_seq.s_wr_data = s_wr_data; 
       m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq"); 
       m_write_resp_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
       m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
       m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRUNQ;
   
       uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("WR snooptype %0s addr 0x%0x secure bit 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_ace_wr_addr_chnl_addr, 
          <% if (obj.wSecurityAttribute > 0) { %>                                             
                  m_write_addr_seq.m_ace_wr_addr_chnl_security 
          <% } else { %>                                                
                  0
          <% } %>
       ), UVM_MEDIUM);
    
   
           m_write_addr_seq.m_constraint_snoop      = 1;
           m_write_addr_seq.m_constraint_addr       = 0;
           m_write_addr_seq.should_randomize        = 0;
           
           m_write_addr_seq.m_seq_item  = axi_wr_seq_item::type_id::create("m_seq_item");

     success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid == use_awid;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awburst == AXIINCR;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache == WWTRWALLOC;   //WNORNCNONBUF;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]==0;   
   	       if (user_qos)   m_write_addr_seq.m_seq_item.m_write_addr_pkt.awqos == aiu_qos;
           };
           
           if (!success) begin
               `uvm_error("AXI SEQ", $sformatf("TB Error: Could not randomize packet in axi_master_write_seq"))
           end
//           m_ace_cache_model.give_addr_for_ace_req_noncoh_write(m_write_addr_seq.m_ace_wr_addr_chnl_snoop, m_write_addr_seq.m_ace_wr_addr_chnl_addr
//								<% if (obj.wSecurityAttribute > 0) { %>                    //                         
//								,m_write_addr_seq.m_ace_wr_addr_chnl_security
//								<% } %>
//                                                              ,is_coh
//								,0, 0
//								<% if (obj.wSecurityAttribute > 0) { %>                    //                         
//								,0
//								<% } %>
//								);
               //m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr = m_write_addr_seq.m_ace_wr_addr_chnl_addr;
               /* m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr[$clog2(SYS_nSysCacheline)-1:0] = 0;//TODO */ 
               //m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr[7:0] = 0;//TODO: align to 256B
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr = m_addr;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen  = m_axlen;
               m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize = m_size;
           `uvm_info("ACE BFM SEQ", $sformatf("WR snooptype %0s addr 0x%0x Len 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), 
                                           m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen), UVM_HIGH);

        m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        success = m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];

        foreach(m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[idx]) begin        
            m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[idx] = m_data + (idx * WXDATA/8);
            m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[idx] = m_wstrb; 
//           `uvm_info("ACE BFM SEQ", $sformatf("master_wrunq_data_seq: data[%0d]:0x%0h, wstrb[%0d]: 0x%0h", idx, m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[idx], idx, m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[idx]), UVM_NONE) 
       end
        
        m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;
        m_write_addr_seq.should_randomize = 0;
        m_write_data_seq.should_randomize = 0;
        if(s_wr_data[core_id] == null) s_wr_data[core_id] = new(1);
        if(s_wr_addr[core_id] == null) s_wr_addr[core_id] = new(1);
        s_wr_addr[core_id].get();
        s_wr_data[core_id].get();
        fork 
            begin
                m_write_addr_seq.return_response(m_seq_item0, p_sequencer.m_write_addr_chnl_seqr);
            end
            begin
                m_write_data_seq.return_response(m_seq_item1, p_sequencer.m_write_data_chnl_seqr);
            end
        join
        m_write_resp_seq.should_randomize = 0;
        m_write_resp_seq.m_seq_item       = m_seq_item0;
        m_write_resp_seq.return_response(m_seq_item0, p_sequencer.m_write_resp_chnl_seqr);
   
   endtask : body
endclass: axi_single_wrunq_data_seq

//******************************************************************************
// Section: axi_rd_wr_latency_seq
// Purpose : 
//******************************************************************************

class axi_mesh_traffic_seq extends axi_master_pipelined_seq;

    `uvm_object_param_utils(axi_mesh_traffic_seq)
    
//    axi_master_read_seq         m_read_seq[];
//    axi_master_write_noncoh_seq m_noncoh_write_seq[];

//    axi_master_pipelined_seq          m_read_seq;
//    axi_master_pipelined_seq          m_write_seq;
//    axi_master_writeread_pipelined_seq          m_writeread_seq;
//    axi_master_writeread_pipelined_seq          m_common_seq;

    // Read and write sequencers
//    axi_read_addr_chnl_sequencer  m_read_addr_chnl_seqr;
//    axi_read_data_chnl_sequencer  m_read_data_chnl_seqr;
//    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
//    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
//    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;

//    ace_cache_model               m_ace_cache_model;

    int k_num_writeread_req;
    int k_num_common_req;
    int k_num_writeread_read_wt;
    int k_num_writeread_write_wt;
    int k_num_common_read_wt;
    int k_num_common_write_wt;

    axi_axaddr_t   m_ace_read_addr_from_test;
    axi_axaddr_t   m_ace_write_addr_from_test;
    axi_axaddr_t   m_ace_common_addr_from_test;
    <% if (obj.wSecurityAttribute > 0) { %>                                             
        bit [<%=obj.wSecurityAttribute%>-1:0] m_ace_read_security_from_test;
        bit [<%=obj.wSecurityAttribute%>-1:0] m_ace_write_security_from_test;
        bit [<%=obj.wSecurityAttribute%>-1:0] m_ace_common_security_from_test;
    <% } %>                                                

    int random_txn[];
    int random_read_cnt;
    int random_write_cnt;

    int read_req_total_cnt;
    int write_req_total_cnt;

//    string seq_name = "axi_mesh_traffic_seq";

//    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
//    uvm_event ev_seq_done;
//    <% if(obj.testBench == "fsys"|| obj.testBench == "emu") { %>
//    uvm_event ev_sim_done;
//    <% } %>

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "axi_mesh_traffic_seq");
    super.new(name);
    k_num_read_req             = 128;
    k_num_write_req            = 128;
    k_num_writeread_req        = 128;
    k_num_common_req           = 16;
    k_num_writeread_read_wt    = 70;
    k_num_writeread_write_wt   = 30;
    k_num_common_read_wt       = 50;
    k_num_common_write_wt      = 50;

    use_addr_from_test = 1;
    use_incr_addr_from_test = (1 << <%=obj.wCacheLineOffset%>);
endfunction : new

//function set_seq_name(string s);
//  seq_name = s;
//endfunction : set_seq_name

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
   
    m_read_seq                      = new[k_num_read_req + k_num_writeread_req + k_num_common_req];
    m_noncoh_write_seq              = new[k_num_write_req + k_num_writeread_req + k_num_common_req];

    ev_seq_done = ev_pool.get(seq_name);
    <% if(obj.testBench == "fsys"|| obj.testBench == "emu") { %>
    ev_sim_done = ev_pool.get("sim_done");
    <% } %>

    read_req_total_cnt = k_num_read_req;													   
    write_req_total_cnt = 0;
    for (int i = 0; i < k_num_read_req; i++) begin
        m_read_seq[i]                       = axi_master_read_seq::type_id::create($sformatf("m_read_seq_%0d", i));
        m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        m_read_seq[i].k_num_read_req        = 1;
        m_read_seq[i].wt_ace_rdnosnp        = 0;
        m_read_seq[i].wt_ace_rdonce         = 100;
        m_read_seq[i].wt_ace_rdshrd         = 0;
        m_read_seq[i].wt_ace_rdcln          = 0;
        m_read_seq[i].wt_ace_rdnotshrddty   = 0;
        m_read_seq[i].wt_ace_rdunq          = 0;
        m_read_seq[i].wt_ace_clnunq         = 0;
        m_read_seq[i].wt_ace_mkunq          = 0;
        m_read_seq[i].wt_ace_dvm_msg        = 0;
        m_read_seq[i].wt_ace_dvm_sync       = 0;
        m_read_seq[i].wt_ace_clnshrd        = 0;
        m_read_seq[i].wt_ace_clninvl        = 0;
        m_read_seq[i].wt_ace_mkinvl         = 0;
        m_read_seq[i].wt_ace_rd_bar         = 0;
        m_read_seq[i].wt_ace_rd_cln_invld   = 0;
        m_read_seq[i].wt_ace_rd_make_invld  = 0;
        m_read_seq[i].wt_ace_clnshrd_pers   = 0;
        m_read_seq[i].read_req_total_count  = read_req_total_cnt;
	m_read_seq[i].k_access_boot_region  = 0;
	m_read_seq[i].use_axcache_from_test = 0;
        m_read_seq[i].user_qos              = 1;
        m_read_seq[i].aiu_qos               = 0;
	m_read_seq[i].use_addr_from_test    = 1;
	m_read_seq[i].m_ace_rd_addr_from_test   = m_ace_read_addr_from_test + (i*use_incr_addr_from_test);
    end

    // start read transactions
    `uvm_info($sformatf("AXI SEQ %s", seq_name), $sformatf("AXI %s Sequential Read Phase.  Issuing %0d transactions, starting address = 0x%0h", seq_name, k_num_read_req, m_ace_read_addr_from_test), UVM_MEDIUM)
    for (int i=k_num_read_req-1; i >= 0; i=i-1) begin
        fork
            automatic int j = i;
            begin
               m_read_seq[j].start(null);
            end
        join_none
    end
    wait fork;
	
    // start random write-read transactions    
    random_txn = new[k_num_writeread_req];
    random_read_cnt = 0;
    random_write_cnt = 0;
    for (int i = 0; i < k_num_writeread_req; i=i+1) begin
       randcase
       k_num_writeread_read_wt       : 
       begin
           random_txn[i] = 0;
	   random_read_cnt = random_read_cnt+1;
       end
       k_num_writeread_write_wt      : 
       begin
           random_txn[i] = 1;
	   random_write_cnt = random_write_cnt+1;
       end
       endcase
    end

    read_req_total_cnt += random_read_cnt; 
    write_req_total_cnt += random_write_cnt;
    for (int i = k_num_read_req; i < k_num_writeread_req + k_num_read_req; i++) begin
        m_read_seq[i]                       = axi_master_read_seq::type_id::create($sformatf("m_read_seq_%0d", i));
        m_read_seq[i].m_read_addr_chnl_seqr = m_read_addr_chnl_seqr;
        m_read_seq[i].m_read_data_chnl_seqr = m_read_data_chnl_seqr;
        m_read_seq[i].m_ace_cache_model     = m_ace_cache_model;
        m_read_seq[i].k_num_read_req        = 1;
        m_read_seq[i].wt_ace_rdnosnp        = 0;
        m_read_seq[i].wt_ace_rdonce         = 100;
        m_read_seq[i].wt_ace_rdshrd         = 0;
        m_read_seq[i].wt_ace_rdcln          = 0;
        m_read_seq[i].wt_ace_rdnotshrddty   = 0;
        m_read_seq[i].wt_ace_rdunq          = 0;
        m_read_seq[i].wt_ace_clnunq         = 0;
        m_read_seq[i].wt_ace_mkunq          = 0;
        m_read_seq[i].wt_ace_dvm_msg        = 0;
        m_read_seq[i].wt_ace_dvm_sync       = 0;
        m_read_seq[i].wt_ace_clnshrd        = 0;
        m_read_seq[i].wt_ace_clninvl        = 0;
        m_read_seq[i].wt_ace_mkinvl         = 0;
        m_read_seq[i].wt_ace_rd_bar         = 0;
        m_read_seq[i].wt_ace_rd_cln_invld   = 0;
        m_read_seq[i].wt_ace_rd_make_invld  = 0;
        m_read_seq[i].wt_ace_clnshrd_pers   = 0;
        m_read_seq[i].read_req_total_count  = k_num_read_req+random_read_cnt;
	m_read_seq[i].k_access_boot_region  = 0;
	m_read_seq[i].use_axcache_from_test = 0;
        m_read_seq[i].user_qos              = 1;
        m_read_seq[i].aiu_qos               = 0;
	m_read_seq[i].use_addr_from_test    = 0;
	//m_read_seq[i].m_ace_rd_addr_from_test   = m_ace_addr_from_test + (i*use_incr_addr_from_test);
    end
    for (int i = 0; i < k_num_writeread_req; i++) begin
	    m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_noncoh_write_seq_%0d", i));
            m_noncoh_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
            m_noncoh_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
            m_noncoh_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
            m_noncoh_write_seq[i].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
            m_noncoh_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
            m_noncoh_write_seq[i].k_num_write_req        = 1;
            m_noncoh_write_seq[i].wt_ace_wrnosnp         = 0;
            m_noncoh_write_seq[i].wt_ace_wrunq           = 100;
            m_noncoh_write_seq[i].wt_ace_wrlnunq         = 0;
            m_noncoh_write_seq[i].wt_ace_wr_bar          = 0;
            m_noncoh_write_seq[i].write_req_total_count  = write_req_total_cnt;
            m_noncoh_write_seq[i].wt_ace_atm_str         = 0;
            m_noncoh_write_seq[i].wt_ace_atm_ld          = 0;
            m_noncoh_write_seq[i].wt_ace_atm_swap        = 0;
	    m_noncoh_write_seq[i].wt_ace_atm_comp        = 0;
            m_noncoh_write_seq[i].wt_ace_ptl_stash       = 0;
            m_noncoh_write_seq[i].wt_ace_full_stash      = 0;
            m_noncoh_write_seq[i].wt_ace_shared_stash    = 0;
            m_noncoh_write_seq[i].wt_ace_unq_stash       = 0;
            m_noncoh_write_seq[i].wt_ace_stash_trans     = 0;
            m_noncoh_write_seq[i].k_access_boot_region   = 0;
	    m_noncoh_write_seq[i].use_axcache_from_test  = 0;
            m_noncoh_write_seq[i].user_qos               = 1;
            m_noncoh_write_seq[i].aiu_qos                = 0;
	    m_noncoh_write_seq[i].use_addr_from_test     = 0;
//	    m_noncoh_write_seq[i].m_ace_wr_addr_from_test   = m_ace_addr_from_test + (i*use_incr_addr_from_test);
    end

    `uvm_info($sformatf("AXI SEQ %s", seq_name), $sformatf("AXI %s Random Write/Read Phase.  Issuing %0d transactions, %0d reads, %0d write", seq_name, k_num_writeread_req, random_read_cnt, random_write_cnt), UVM_MEDIUM)
    for (int i = k_num_writeread_req-1; i >= 0; i=i-1) begin
        fork
            automatic int j = i;
            if(random_txn[j] == 0) begin
                m_read_seq[j+k_num_read_req].start(null);
            end
            else begin
               m_noncoh_write_seq[j].start(null);
           end
        join_none
    end
    wait fork;

    // starts sequential write transactions
    //read_req_total_cnt += random_read_cnt; 
    write_req_total_cnt += k_num_write_req;
    for (int i = k_num_writeread_req; i < k_num_write_req+k_num_writeread_req; i++) begin
	    m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_noncoh_write_seq_%0d", i));
            m_noncoh_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
            m_noncoh_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
            m_noncoh_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
            m_noncoh_write_seq[i].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
            m_noncoh_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
            m_noncoh_write_seq[i].k_num_write_req        = 1;
            m_noncoh_write_seq[i].wt_ace_wrnosnp         = 0;
            m_noncoh_write_seq[i].wt_ace_wrunq           = 100;
            m_noncoh_write_seq[i].wt_ace_wrlnunq         = 0;
            m_noncoh_write_seq[i].wt_ace_wr_bar          = 0;
            m_noncoh_write_seq[i].write_req_total_count  = write_req_total_cnt;
            m_noncoh_write_seq[i].wt_ace_atm_str         = 0;
            m_noncoh_write_seq[i].wt_ace_atm_ld          = 0;
            m_noncoh_write_seq[i].wt_ace_atm_swap        = 0;
	    m_noncoh_write_seq[i].wt_ace_atm_comp        = 0;
            m_noncoh_write_seq[i].wt_ace_ptl_stash       = 0;
            m_noncoh_write_seq[i].wt_ace_full_stash      = 0;
            m_noncoh_write_seq[i].wt_ace_shared_stash    = 0;
            m_noncoh_write_seq[i].wt_ace_unq_stash       = 0;
            m_noncoh_write_seq[i].wt_ace_stash_trans     = 0;
            m_noncoh_write_seq[i].k_access_boot_region   = 0;
	    m_noncoh_write_seq[i].use_axcache_from_test  = 0;
            m_noncoh_write_seq[i].user_qos               = 1;
            m_noncoh_write_seq[i].aiu_qos                = 0;
	    m_noncoh_write_seq[i].use_addr_from_test     = use_addr_from_test;
	    m_noncoh_write_seq[i].m_ace_wr_addr_from_test   = m_ace_write_addr_from_test + ((i-k_num_writeread_req)*use_incr_addr_from_test);
    end

    // start write transactions
    `uvm_info($sformatf("AXI SEQ %s", seq_name), $sformatf("AXI %s Sequential Write Phase.  Issuing %0d transactions, starting address=0x%0h", seq_name, k_num_write_req, m_ace_write_addr_from_test), UVM_MEDIUM)
    for (int i=k_num_write_req-1; i >= 0; i=i-1) begin
        fork
            automatic int j = i;
            begin
               m_noncoh_write_seq[j+k_num_writeread_req].start(null);
            end
        join_none
    end
    wait fork;

    // start common write-read transactions    
    random_read_cnt = 0;
    random_write_cnt = 0;
    for (int i = 0; i < k_num_common_req; i=i+1) begin
       randcase
       k_num_common_read_wt       : 
       begin
           random_txn[i] = 0;
	   random_read_cnt = random_read_cnt+1;
       end
       k_num_common_write_wt      : 
       begin
           random_txn[i] = 1;
	   random_write_cnt = random_write_cnt+1;
       end
       endcase
    end

    read_req_total_cnt += random_read_cnt; 
    write_req_total_cnt += random_write_cnt;
    for (int i = k_num_read_req + k_num_writeread_req; i < k_num_writeread_req + k_num_read_req + k_num_common_req; i++) begin
	    m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_noncoh_write_seq_%0d", i));
            m_noncoh_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
            m_noncoh_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
            m_noncoh_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
            m_noncoh_write_seq[i].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
            m_noncoh_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
            m_noncoh_write_seq[i].k_num_write_req        = 1;
            m_noncoh_write_seq[i].wt_ace_wrnosnp         = 0;
            m_noncoh_write_seq[i].wt_ace_wrunq           = 100;
            m_noncoh_write_seq[i].wt_ace_wrlnunq         = 0;
            m_noncoh_write_seq[i].wt_ace_wr_bar          = 0;
            m_noncoh_write_seq[i].write_req_total_count  = write_req_total_cnt;
            m_noncoh_write_seq[i].wt_ace_atm_str         = 0;
            m_noncoh_write_seq[i].wt_ace_atm_ld          = 0;
            m_noncoh_write_seq[i].wt_ace_atm_swap        = 0;
	    m_noncoh_write_seq[i].wt_ace_atm_comp        = 0;
            m_noncoh_write_seq[i].wt_ace_ptl_stash       = 0;
            m_noncoh_write_seq[i].wt_ace_full_stash      = 0;
            m_noncoh_write_seq[i].wt_ace_shared_stash    = 0;
            m_noncoh_write_seq[i].wt_ace_unq_stash       = 0;
            m_noncoh_write_seq[i].wt_ace_stash_trans     = 0;
            m_noncoh_write_seq[i].k_access_boot_region   = 0;
	    m_noncoh_write_seq[i].use_axcache_from_test  = 0;
            m_noncoh_write_seq[i].user_qos               = 1;
            m_noncoh_write_seq[i].aiu_qos                = 0;
	    m_noncoh_write_seq[i].use_addr_from_test     = 1;
	    m_noncoh_write_seq[i].m_ace_wr_addr_from_test   = m_ace_common_addr_from_test + ((i-k_num_write_req-k_num_writeread_req)*use_incr_addr_from_test);
    end
    for (int i = k_num_write_req+k_num_writeread_req; i < (k_num_writeread_req+k_num_write_req+k_num_common_req); i++) begin
	    m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_noncoh_write_seq_%0d", i));
            m_noncoh_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
            m_noncoh_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
            m_noncoh_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
            m_noncoh_write_seq[i].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
            m_noncoh_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
            m_noncoh_write_seq[i].k_num_write_req        = 1;
            m_noncoh_write_seq[i].wt_ace_wrnosnp         = 0;
            m_noncoh_write_seq[i].wt_ace_wrunq           = 100;
            m_noncoh_write_seq[i].wt_ace_wrlnunq         = 0;
            m_noncoh_write_seq[i].wt_ace_wr_bar          = 0;
            m_noncoh_write_seq[i].write_req_total_count  = write_req_total_cnt;
            m_noncoh_write_seq[i].wt_ace_atm_str         = 0;
            m_noncoh_write_seq[i].wt_ace_atm_ld          = 0;
            m_noncoh_write_seq[i].wt_ace_atm_swap        = 0;
	    m_noncoh_write_seq[i].wt_ace_atm_comp        = 0;
            m_noncoh_write_seq[i].wt_ace_ptl_stash       = 0;
            m_noncoh_write_seq[i].wt_ace_full_stash      = 0;
            m_noncoh_write_seq[i].wt_ace_shared_stash    = 0;
            m_noncoh_write_seq[i].wt_ace_unq_stash       = 0;
            m_noncoh_write_seq[i].wt_ace_stash_trans     = 0;
            m_noncoh_write_seq[i].k_access_boot_region   = 0;
	    m_noncoh_write_seq[i].use_axcache_from_test  = 0;
            m_noncoh_write_seq[i].user_qos               = 1;
            m_noncoh_write_seq[i].aiu_qos                = 0;
	    m_noncoh_write_seq[i].use_addr_from_test     = 1;
	    m_noncoh_write_seq[i].m_ace_wr_addr_from_test   = m_ace_common_addr_from_test + ((i-k_num_write_req-k_num_writeread_req)*use_incr_addr_from_test);
    end

    `uvm_info($sformatf("AXI SEQ %s", seq_name), $sformatf("AXI %s Common Write/Read Phase.  Issuing %0d transactions, %0d reads, %0d write.  Common address = 0x%0h", seq_name, k_num_common_req, random_read_cnt, random_write_cnt, m_ace_common_addr_from_test), UVM_MEDIUM)
    for (int i = k_num_common_req-1; i >= 0; i=i-1) begin
        fork
            automatic int j = i;
            if(random_txn[j] == 0) begin
                m_read_seq[j+k_num_read_req+k_num_writeread_req].start(null);
            end
            else begin
               m_noncoh_write_seq[j+k_num_write_req+k_num_writeread_req].start(null);
           end
        join_none
    end
    wait fork;

    `uvm_info($sformatf("AXI SEQ %s", seq_name), $sformatf("AXI %s Sequence done", seq_name), UVM_NONE)
    ev_seq_done.trigger(null);													   

<% if (obj.testBench == "fsys"|| obj.testBench == "emu") { %>    
    ev_sim_done.wait_trigger();
    `uvm_info($sformatf("AXI SEQ %s", seq_name), "Received simulation done", UVM_NONE)
<% } %>
													   
endtask : body

endclass : axi_mesh_traffic_seq
													   
class axi_pcie_posted_posted_seq extends axi_master_pipelined_seq;
   `uvm_object_param_utils(axi_pcie_posted_posted_seq)
   int write_req_total_cnt = 2;													   
   task body;

     axi_axaddr_t   m_ace_addr_from_test;

     m_noncoh_write_seq              = new[write_req_total_cnt];
     m_ace_addr_from_test                         = m_ace_cache_model.m_addr_mgr.get_cohboot_addr(<%=obj.FUnitId%>, 1, core_id);

     for(int i = 0; i < 2; i++) begin
        m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_noncoh_write_seq_%0d", 0));
        m_noncoh_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
        m_noncoh_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
        m_noncoh_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
        m_noncoh_write_seq[i].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
        m_noncoh_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
        m_noncoh_write_seq[i].k_num_write_req        = 1;
        m_noncoh_write_seq[i].wt_ace_wrnosnp         = 0;
        m_noncoh_write_seq[i].wt_ace_wrunq           = 100;
        m_noncoh_write_seq[i].wt_ace_wrlnunq         = 0;
        m_noncoh_write_seq[i].wt_ace_wr_bar          = 0;
        m_noncoh_write_seq[i].write_req_total_count  = write_req_total_cnt;
        m_noncoh_write_seq[i].wt_ace_atm_str         = 0;
        m_noncoh_write_seq[i].wt_ace_atm_ld          = 0;
        m_noncoh_write_seq[i].wt_ace_atm_swap        = 0;
        m_noncoh_write_seq[i].wt_ace_atm_comp        = 0;
        m_noncoh_write_seq[i].wt_ace_ptl_stash       = 0;
        m_noncoh_write_seq[i].wt_ace_full_stash      = 0;
        m_noncoh_write_seq[i].wt_ace_shared_stash    = 0;
        m_noncoh_write_seq[i].wt_ace_unq_stash       = 0;
        m_noncoh_write_seq[i].wt_ace_stash_trans     = 0;
        m_noncoh_write_seq[i].k_access_boot_region   = 0;
        m_noncoh_write_seq[i].use_axcache_from_test  = 0;
        m_noncoh_write_seq[i].user_qos               = 0;
        m_noncoh_write_seq[i].aiu_qos                = 0;
        m_noncoh_write_seq[i].use_addr_from_test      = 1;
        m_noncoh_write_seq[i].m_ace_wr_addr_from_test = m_ace_addr_from_test;
    end
    for (int i = 2; i < write_req_total_cnt; i++) begin
	    m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_noncoh_write_seq_%0d", i));
            m_noncoh_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
            m_noncoh_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
            m_noncoh_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
            m_noncoh_write_seq[i].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
            m_noncoh_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
            m_noncoh_write_seq[i].k_num_write_req        = 1;
            m_noncoh_write_seq[i].wt_ace_wrnosnp         = 0;
            m_noncoh_write_seq[i].wt_ace_wrunq           = 100;
            m_noncoh_write_seq[i].wt_ace_wrlnunq         = 0;
            m_noncoh_write_seq[i].wt_ace_wr_bar          = 0;
            m_noncoh_write_seq[i].write_req_total_count  = 1;
            m_noncoh_write_seq[i].wt_ace_atm_str         = 0;
            m_noncoh_write_seq[i].wt_ace_atm_ld          = 0;
            m_noncoh_write_seq[i].wt_ace_atm_swap        = 0;
	    m_noncoh_write_seq[i].wt_ace_atm_comp        = 0;
            m_noncoh_write_seq[i].wt_ace_ptl_stash       = 0;
            m_noncoh_write_seq[i].wt_ace_full_stash      = 0;
            m_noncoh_write_seq[i].wt_ace_shared_stash    = 0;
            m_noncoh_write_seq[i].wt_ace_unq_stash       = 0;
            m_noncoh_write_seq[i].wt_ace_stash_trans     = 0;
            m_noncoh_write_seq[i].k_access_boot_region   = 0;
	    m_noncoh_write_seq[i].use_axcache_from_test  = 0;
            m_noncoh_write_seq[i].user_qos               = 0;
            m_noncoh_write_seq[i].aiu_qos                = 0;
	    m_noncoh_write_seq[i].use_addr_from_test     = 1;
	    m_noncoh_write_seq[i].m_ace_wr_addr_from_test = m_ace_addr_from_test;
    end
    for (int i = 0; i < write_req_total_cnt; i++) begin

	fork 
	automatic int j = i;
        m_noncoh_write_seq[j].start(null);
        join_none													   
    end
   endtask
endclass													   
class axi_pcie_posted_read_seq extends axi_master_pipelined_seq;
   `uvm_object_param_utils(axi_pcie_posted_read_seq)
   task body;
      
   endtask
endclass

class axi_pcie_sequential_read extends axi_master_pipelined_seq;
   `uvm_object_param_utils(axi_pcie_sequential_read)
   addr_trans_mgr        m_addr_mgr;
   axi_axlen_t           m_axlen;
   axi_axsize_t          m_axsize;
   axi_axsize_t          m_size;
   rand int              m_txsize;
   axi_virtual_sequencer m_virtual_sequencer;
   int k_num_read_req;
   function new(string name = "",axi_virtual_sequencer virtual_sequencer = null);
      super.new(name);
      m_virtual_sequencer = virtual_sequencer;
   endfunction
   task body;
      axi_axaddr_t             m_addr;
      axi_master_read_seq      read_seqs[];
      m_addr_mgr  = addr_trans_mgr::get_instance();
      read_seqs = new[k_num_read_req];
      if(WXDATA == 8)
         m_size = AXI1B;
      else if(WXDATA == 16)
         m_size = AXI2B;
      else if(WXDATA == 32) 
         m_size = AXI4B;
      else if(WXDATA == 64)
         m_size = AXI8B;
      else if(WXDATA == 128)
         m_size = AXI16B;
      else if(WXDATA == 256) 
         m_size = AXI32B;
      else if(WXDATA == 512)
         m_size = AXI64B;
      else if(WXDATA == 1024)
         m_size = AXI128B;
      m_addr = m_addr_mgr.get_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, 0, core_id);
      for(int i = 0; i < k_num_read_req; i++) begin
        read_seqs[i]                         = axi_master_read_seq::type_id::create($sformatf("pcie_read_seq%0d",i));
        read_seqs[i].use_addr_from_test      = 1;
        read_seqs[i].m_ace_rd_addr_from_test = m_addr;
//        read_seqs[i].use_arid                = 0;
        read_seqs[i].en_force_axid           = 1;
        read_seqs[i].ioaiu_force_axid        = 0;
        case($urandom % 4)
	  0 : m_txsize = 64;
	  1 : m_txsize = 256;	
	  2 : m_txsize = 1024;
	  3 : m_txsize = 4096;
        endcase							   
//        read_seqs[i].m_axlen    = m_txsize / (WXDATA / 8) - 1;
        read_seqs[i].perf_txn_size = m_txsize;
        m_addr += m_txsize;
      end

      for (int i = 0; i < k_num_read_req; i++) begin
  	  fork 
	  automatic int j = i;
          begin
             read_seqs[j].start(m_virtual_sequencer);
	  end
          join_none			
      end
   endtask
endclass

class axi_pcie_sequential_write extends axi_master_pipelined_seq;
   `uvm_object_param_utils(axi_pcie_sequential_write)
   addr_trans_mgr                m_addr_mgr;
   axi_axlen_t                   m_axlen;
   axi_axsize_t                  m_axsize;
    axi_axsize_t                  m_size;
   rand int                           m_txsize;
   axi_virtual_sequencer m_virtual_sequencer;
   function new(string name = "",axi_virtual_sequencer virtual_sequencer = null);
      super.new(name);
      m_virtual_sequencer = virtual_sequencer;
   endfunction

   task body;
    axi_axaddr_t m_addr;
    ioaiu_write_bw_seq write_seqs[];
    m_addr_mgr = addr_trans_mgr::get_instance();
    write_seqs = new[k_num_write_req];
        if(WXDATA == 8)
           m_size = AXI1B;
        else if(WXDATA == 16)
           m_size = AXI2B;
        else if(WXDATA == 32) 
           m_size = AXI4B;
        else if(WXDATA == 64)
           m_size = AXI8B;
        else if(WXDATA == 128)
           m_size = AXI16B;
        else if(WXDATA == 256) 
           m_size = AXI32B;
        else if(WXDATA == 512)
           m_size = AXI64B;
        else if(WXDATA == 1024)
           m_size = AXI128B;

    //for loop
    m_addr = m_addr_mgr.get_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, 0, core_id);
    for(int i = 0; i < k_num_write_req; i++) begin
      write_seqs[i]            = ioaiu_write_bw_seq::type_id::create($sformatf("ioaiu_write_bw%0d",i));
      write_seqs[i].p_sequencer = m_virtual_sequencer;
//      write_seqs[i].p_sequencer.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
//      write_seqs[i].p_sequencer.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
//      write_seqs[i].p_sequencer.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
//      write_seqs[i].p_sequencer.m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
//      write_seqs[i].m_ace_cache_model      = m_ace_cache_model;
      write_seqs[i].m_addr     = m_addr;
      write_seqs[i].use_awid   = 0;
      case($urandom % 4)
	0 : m_txsize = 64;
	1 : m_txsize = 256;	
	2 : m_txsize = 1024;
	3 : m_txsize = 4096;
      endcase							   
      write_seqs[i].m_axlen    = m_txsize / (WXDATA / 8) - 1;
      m_addr += m_txsize;
    end

    for (int i = 0; i < k_num_write_req; i++) begin
	fork 
	automatic int j = i;
        begin
           write_seqs[j].start(m_virtual_sequencer);
	end
        join_none			
    end

    //m_addr = coh_addr

    //randomize arlen
    
/*
    m_noncoh_write_seq[0]            = axi_master_write_noncoh_seq::type_id::create($sformatf("m_noncoh_write_seq_%0d", 0));
    m_noncoh_write_seq[0].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
    m_noncoh_write_seq[0].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
    m_noncoh_write_seq[0].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
    m_noncoh_write_seq[0].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
    m_noncoh_write_seq[0].m_ace_cache_model      = m_ace_cache_model;
    m_noncoh_write_seq[0].k_num_write_req    = 1;
    m_noncoh_write_seq[0].wt_ace_wrnosnp     = 0;
    m_noncoh_write_seq[0].wt_ace_wrunq       = 100;
    m_noncoh_write_seq[0].wt_ace_wrlnunq     = 0;
    m_noncoh_write_seq[0].wt_ace_wr_bar      = 0;
    m_noncoh_write_seq[0].write_req_total_count = 1;
    m_noncoh_write_seq[0].wt_ace_atm_str     = 0;
    m_noncoh_write_seq[0].wt_ace_atm_ld      = 0;
    m_noncoh_write_seq[0].wt_ace_atm_swap    = 0;
    m_noncoh_write_seq[0].wt_ace_atm_comp    = 0;
    m_noncoh_write_seq[0].wt_ace_ptl_stash       = 0;
    m_noncoh_write_seq[0].wt_ace_full_stash      = 0;
    m_noncoh_write_seq[0].wt_ace_shared_stash    = 0;
    m_noncoh_write_seq[0].wt_ace_unq_stash       = 0;
    m_noncoh_write_seq[0].wt_ace_stash_trans     = 0;
    m_noncoh_write_seq[0].k_access_boot_region   = 0;
    m_noncoh_write_seq[0].use_axcache_from_test  = 0;
    m_noncoh_write_seq[0].user_qos           = 0;
    m_noncoh_write_seq[0].aiu_qos        = 0;
    m_noncoh_write_seq[0].use_addr_from_test      = 1;
    m_noncoh_write_seq[0].m_ace_wr_addr_from_test = m_ace_addr_from_test;
    for (int i = 1; i < 2; i++) begin
	    m_noncoh_write_seq[i]                        = axi_master_write_noncoh_seq::type_id::create($sformatf("m_noncoh_write_seq_%0d", i));
            m_noncoh_write_seq[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
            m_noncoh_write_seq[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
            m_noncoh_write_seq[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
            m_noncoh_write_seq[i].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
            m_noncoh_write_seq[i].m_ace_cache_model      = m_ace_cache_model;
            m_noncoh_write_seq[i].k_num_write_req        = 1;
            m_noncoh_write_seq[i].wt_ace_wrnosnp         = 0;
            m_noncoh_write_seq[i].wt_ace_wrunq           = 100;
            m_noncoh_write_seq[i].wt_ace_wrlnunq         = 0;
            m_noncoh_write_seq[i].wt_ace_wr_bar          = 0;
            m_noncoh_write_seq[i].write_req_total_count  = 1;
            m_noncoh_write_seq[i].wt_ace_atm_str         = 0;
            m_noncoh_write_seq[i].wt_ace_atm_ld          = 0;
            m_noncoh_write_seq[i].wt_ace_atm_swap        = 0;
	    m_noncoh_write_seq[i].wt_ace_atm_comp        = 0;
            m_noncoh_write_seq[i].wt_ace_ptl_stash       = 0;
            m_noncoh_write_seq[i].wt_ace_full_stash      = 0;
            m_noncoh_write_seq[i].wt_ace_shared_stash    = 0;
            m_noncoh_write_seq[i].wt_ace_unq_stash       = 0;
            m_noncoh_write_seq[i].wt_ace_stash_trans     = 0;
            m_noncoh_write_seq[i].k_access_boot_region   = 0;
	    m_noncoh_write_seq[i].use_axcache_from_test  = 0;
            m_noncoh_write_seq[i].user_qos               = 0;
            m_noncoh_write_seq[i].aiu_qos                = 0;
	    m_noncoh_write_seq[i].use_addr_from_test     = 1;
	    m_noncoh_write_seq[i].m_ace_wr_addr_from_test = m_ace_addr_from_test;
    end
    for (int i = 0; i < 2; i++) begin

	fork 
	automatic int j = i;
        m_noncoh_write_seq[j].start(null);
        join_none													   
    end
*/
   endtask
endclass

class axi_pcie_prod_cons_ioaiu extends axi_master_pipelined_seq;
    `uvm_object_param_utils(axi_pcie_prod_cons_ioaiu)
    axi_virtual_sequencer m_virtual_sequencer;									
				   
    function new(string name = "axi_pcie_prod_cons_ioaiu");
        super.new(name);
    endfunction // new

    task body;
       axi_pcie_sequential_write sequential_seq;
       axi_master_pipelined_seq dii_seq;
       use_incr_addr_from_test = 64;
       sequential_seq = axi_pcie_sequential_write::type_id::create($sformatf("sequential_seq"));
       sequential_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
       sequential_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
       sequential_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
       sequential_seq.m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
       sequential_seq.m_read_addr_chnl_seqr  = m_read_addr_chnl_seqr;
       sequential_seq.m_ace_cache_model      = m_ace_cache_model;
       sequential_seq.m_virtual_sequencer = m_virtual_sequencer;

       sequential_seq.use_incr_addr_from_test       = use_incr_addr_from_test;
       sequential_seq.use_addr_from_test            = 1;
       sequential_seq.m_ace_addr_from_test          = 0;
       sequential_seq.wt_ace_wrnosnp                = 0;
       sequential_seq.wt_ace_wrlnunq                = 0;
       sequential_seq.wt_ace_wrunq                  = 100;
       sequential_seq.wt_ace_wr_bar                 = 0;
       sequential_seq.wt_ace_atm_str                = 0;
       sequential_seq.wt_ace_atm_ld                 = 0;
       sequential_seq.wt_ace_atm_swap               = 0;
       sequential_seq.wt_ace_atm_comp               = 0;
       sequential_seq.wt_ace_full_stash             = 0;
       sequential_seq.wt_ace_shared_stash           = 0;
       sequential_seq.wt_ace_unq_stash              = 0;
       sequential_seq.wt_ace_stash_trans            = 0;

       dii_seq        = axi_master_pipelined_seq::type_id::create($sformatf("dii_seq"));
       dii_seq.m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
       dii_seq.m_write_data_chnl_seqr = m_write_data_chnl_seqr;
       dii_seq.m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
       dii_seq.m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
       dii_seq.m_read_addr_chnl_seqr  = m_read_addr_chnl_seqr;
       dii_seq.m_ace_cache_model      = m_ace_cache_model;
       dii_seq.k_access_boot_region   = 1;
       dii_seq.k_num_read_req         = 0;
       dii_seq.k_num_write_req        = 1;

       dii_seq.wt_ace_wrnosnp         = 100;
       dii_seq.wt_ace_wrlnunq         = 0;
       dii_seq.wt_ace_wrunq           = 0;
       dii_seq.wt_ace_wr_bar          = 0;
       dii_seq.wt_ace_atm_str         = 0;
       dii_seq.wt_ace_atm_ld          = 0;
       dii_seq.wt_ace_atm_swap        = 0;
       dii_seq.wt_ace_atm_comp        = 0;
       dii_seq.wt_ace_full_stash      = 0;
       dii_seq.wt_ace_shared_stash    = 0;
       dii_seq.wt_ace_unq_stash       = 0;
       dii_seq.wt_ace_stash_trans     = 0;
       sequential_seq.start(null);
       dii_seq.start(null);
    endtask
endclass


class axi_pcie_master_test_seq extends axi_master_pipelined_seq;
   `uvm_object_param_utils(axi_pcie_master_test_seq)
   axi_master_pipelined_seq     pcie_seqs[];
   int         max_pcie_seqs;
   // int         posted_posted;
   // int         posted_read;
   // int         posted_nprdata;

   // int         read_posted;
   // int         read_read;
   // int         read_nprdata;

   // int         nprdata_posted;
   // int         nprdata_read;
   // int         nprdata_nprdata;

   int         wt_posted_posted    = 100;
   int         wt_posted_read      = 100;
   int         wt_posted_nprdata   = 100;

   int         wt_read_posted      = 100;
   int         wt_read_read        = 100;
   int         wt_read_nprdata     = 100;

   int         wt_nprdata_posted   = 100;
   int         wt_nprdata_read     = 100;
   int         wt_nprdata_nprdata  = 100;
													   
   task body;
        pcie_seqs = new[max_pcie_seqs];
	for(int i = 0; i < max_pcie_seqs; i++) begin
	    randcase
		wt_posted_posted : begin
		   pcie_seqs[i] = axi_pcie_posted_posted_seq::type_id::create($sformatf("m_pcie_posted_posted_seq%0d",i));
		end	   
	    endcase
	    pcie_seqs[i].m_read_addr_chnl_seqr  = m_read_addr_chnl_seqr;
	    pcie_seqs[i].m_read_data_chnl_seqr  = m_read_data_chnl_seqr;
	    pcie_seqs[i].m_write_addr_chnl_seqr = m_write_addr_chnl_seqr;
	    pcie_seqs[i].m_write_data_chnl_seqr = m_write_data_chnl_seqr;
	    pcie_seqs[i].m_write_resp_chnl_seqr = m_write_resp_chnl_seqr;
	    pcie_seqs[i].m_ace_cache_model      = m_ace_cache_model;
	end										   
	pcie_seqs[0].start(null);
        for(int i = 0; i < max_pcie_seqs; i++) begin
           fork 
              automatic int j = i;
	      begin 
	        uvm_report_info("DCDEBUG",$sformatf("starting seq[%0d] at time %t",j,$time),UVM_MEDIUM);
	        pcie_seqs[j].start(null);
	      end
	   join_none
	end
													   
   endtask //

endclass // axi_pcie_test_seq

 <% } %>

//`endif // AXI_SEQ
