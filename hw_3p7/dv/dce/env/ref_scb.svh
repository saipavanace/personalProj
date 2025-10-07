`uvm_analysis_imp_decl(_master_req)
`uvm_analysis_imp_decl(_master_rsp)
`uvm_analysis_imp_decl(_slave_req)
`uvm_analysis_imp_decl(_slave_rsp)
`uvm_analysis_imp_decl(_dce_probe)
//DC_DEBUG
`ifndef PSEUDO_SYS_TB
`uvm_analysis_imp_decl(_reset_port)
`endif
////////////////////////////////////////////////////////////////////////////////
//
// DCE Scoreboard
//
////////////////////////////////////////////////////////////////////////////////
class dce_scoreboard extends uvm_component;
  
  `uvm_component_utils(dce_scoreboard)
  
  uvm_analysis_imp_master_req #(sfi_seq_item, dce_scoreboard) analysis_master_req;
  uvm_analysis_imp_master_rsp #(sfi_seq_item, dce_scoreboard) analysis_master_rsp;
  uvm_analysis_imp_slave_req  #(sfi_seq_item, dce_scoreboard) analysis_slave_req;
  uvm_analysis_imp_slave_rsp  #(sfi_seq_item, dce_scoreboard) analysis_slave_rsp;
  uvm_analysis_imp_dce_probe  #(dirlookup_seq_item, dce_scoreboard) analysis_dce_probe;
   `ifndef PSEUDO_SYS_TB
  uvm_analysis_imp_reset_port  #(reset_pkt, dce_scoreboard) analysis_reset_port;
   `endif

  bit dce_scoreboard_enable = 1;

  CacheStateModel  m_csm;

  <%=obj.BlockId%>_dirm_scoreboard m_dirm_scb;

  <%=obj.BlockId + '_con'%>::sfi_req_packet_t  cmd_req_pkt_map [<%=obj.BlockId + '_con'%>::SFITransID_t];
  <%=obj.BlockId + '_con'%>::sfi_req_packet_t  upd_req_pkt_map [<%=obj.BlockId + '_con'%>::SFITransID_t];
  <%=obj.BlockId + '_con'%>::sfi_req_packet_t  snp_req_pkt_map [<%=obj.BlockId + '_con'%>::SFITransID_t];
  <%=obj.BlockId + '_con'%>::sfi_req_packet_t  hnt_req_pkt_map [<%=obj.BlockId + '_con'%>::SFITransID_t];
  <%=obj.BlockId + '_con'%>::sfi_req_packet_t  mrd_req_pkt_map [<%=obj.BlockId + '_con'%>::SFITransID_t];
  <%=obj.BlockId + '_con'%>::sfi_req_packet_t  str_req_pkt_map [<%=obj.BlockId + '_con'%>::SFITransID_t];
   
  bit  upd_map [<%=obj.BlockId + '_con'%>::cacheAddress_t];

  //DS indexed with att_id gives you the associated cache address.
  <%=obj.BlockId + '_con'%>::cacheAddress_t attid2cache_addr_map[bit [<%=obj.BlockId + '_con'%>::DCE_nATTEntries-1:0]];

   
   `ifdef COVER_ON
      dce_coverage m_cov;
   `endif

<%
    var nAgentAius = obj.AiuInfo.length;
    var nBridgeAius = obj.BridgeAiuInfo.length;
    var nAius = nAgentAius + nBridgeAius;
    var idSnoopFilterSlice = 0;
    var nSnpInFlight = 0;
    var nSnpDvmInFlight = 0;

    this.DCE_nSNPInflight = "'{";
    for (var i = 0; i < nAius; i++) {
        if (i < nAgentAius) {
            if (obj.AiuInfo[i].fnNativeInterface === "ACE") {
                idSnoopFilterSlice = obj.AiuInfo[i].CmpInfo.idSnoopFilterSlice; 
            }
        } else { 
            if (obj.BridgeAiuInfo[i-nAgentAius].NativeInfo.useIoCache) {
                idSnoopFilterSlice = obj.BridgeAiuInfo[i-nAgentAius].CmpInfo.idSnoopFilterSlice; 
            }
        }
        nSnpInFlight = obj.SnoopFilterInfo[idSnoopFilterSlice].CmpInfo.nSnpInFlight;
        this.DCE_nSNPInflight += nSnpInFlight.toString();
        if (i < (nAius-1)) {
            this.DCE_nSNPInflight += ',';
        }
    }
    this.DCE_nSNPInflight += '}';

    this.DCE_nSnpDvmInflight = "'{";
    for (var i = 0; i < nAius; i++) { 
      if (i < nAgentAius) {
        nSnpDvmInFlight = obj.AiuInfo[i].DvmInfo.nDvmCmpInFlight;
      } else {
        nSnpDvmInFlight = 0;
      }
      this.DCE_nSnpDvmInflight += nSnpDvmInFlight.toString();
      if (i < (nAius-1)) {
        this.DCE_nSnpDvmInflight += ',';
      }
    }
    this.DCE_nSnpDvmInflight += '}';
%>
   
  int              DCE_nSNPInflight [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs] = <%=this.DCE_nSNPInflight%>;
  int              DCE_nSnpDvmInflight [<%=obj.BlockId + '_con'%>::SYS_nSysAIUs] = <%=this.DCE_nSnpDvmInflight%>;
  int              DCE_nMRDInflight [<%=obj.MemRegionInfo.length%>][<%=obj.DmiInfo.length%>];
  int 		   DCE_nDVMInflight;
 
  bit 		   has_coverage = 0;
  bit [8:0] log_SnpRecallErr = 0;
`ifdef COVER_ON
  virtual <%=obj.BlockId%>_tf_cov_if cur_vif;
`endif
   
  extern function new(string name = "dce_scoreboard", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task     main_phase(uvm_phase phase);

  extern function void write_master_req(sfi_seq_item  item);
  extern function void write_master_rsp(sfi_seq_item  item);
  extern function void write_slave_req(sfi_seq_item  item);
  extern function void write_slave_rsp(sfi_seq_item  item);
  extern function void write_dce_probe(dirlookup_seq_item  item);
   `ifndef PSEUDO_SYS_TB
  extern function void write_reset_port(reset_pkt item);
   `endif
  extern function void print_info(<%=obj.BlockId + '_con'%>::errCodeEntry_t err_code_entry);

endclass : dce_scoreboard

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_scoreboard::new(string name = "dce_scoreboard", uvm_component parent = null);
  super.new(name, parent);

  $timeformat(-9, 2, " ns", 10);

  m_csm = new();

  <% for (var i=0; i < obj.MemRegionInfo.length; i++) { %>
  <%   for (var k=0; k < obj.DmiInfo.length; k++) { %>
         DCE_nMRDInflight[<%=i%>][<%=k%>] = <%=obj.MemRegionInfo[i].CmpInfo.nMrdInFlight%>;
  <%   } %>
  <% } %>

  DCE_nDVMInflight = <%=obj.BlockId + '_con'%>::DCE_nDTFSkidBufferSize;

endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_scoreboard::build_phase(uvm_phase phase);
  super.build_phase(phase);
   
  analysis_master_req = new ("analysis_master_req", this);
  analysis_master_rsp = new ("analysis_master_rsp", this);
  analysis_slave_req  = new ("analysis_slave_req",  this);
  analysis_slave_rsp  = new ("analysis_slave_rsp",  this);
  analysis_dce_probe  = new ("analysis_dce_probe",  this);
   `ifndef PSEUDO_SYS_TB
  analysis_reset_port = new ("analysis_reset_port",  this);
   `endif
   
   `ifdef COVER_ON
     if(!uvm_config_db#(virtual <%=obj.BlockId%>_tf_cov_if)::get(.cntxt(this),
                                                             .inst_name( ""),
                                                             .field_name("tf_cov_if"),
                                                             .value(cur_vif))) begin
        `uvm_error("dce_coverage","tf_cov_if not found!")
     end
   m_cov = new(cur_vif);
   m_cov.m_csm = m_csm;

   `endif
   
endfunction : build_phase

//------------------------------------------------------------------------------
// Main Phase
//------------------------------------------------------------------------------
task dce_scoreboard::main_phase(uvm_phase phase);
  bit done;
  done = 0;
  super.main_phase(phase);
  phase.raise_objection(this, "Raise objection in main_phase.");
  do begin
      #1us
      if (m_csm.transactionPending()) begin
        // still have pending transactions; continue to keep objection raised
      end else begin
        phase.drop_objection(this, "Drop objection in main_phase");
        done = 1;
      end
  end while (!done);
endtask : main_phase

//------------------------------------------------------------------------------
// Print info
//------------------------------------------------------------------------------
function void dce_scoreboard::print_info(<%=obj.BlockId + '_con'%>::errCodeEntry_t err_code_entry);
  string plusarg_string;

  if (err_code_entry.err_code) begin
    //`uvm_error(get_type_name(), $sformatf("\n%s", err_code_entry.info))
    if (m_csm.m_ignore_err_code) begin
      `uvm_info(get_type_name(), $sformatf("\n%s", err_code_entry.info), UVM_LOW)
    end else begin
      `uvm_error(get_type_name(), $sformatf("%s", err_code_entry.info))
    end
  end else begin
    //`uvm_info(get_type_name(), $sformatf("\n%s", err_code_entry.info), UVM_LOW)
    if ( $value$plusargs("UVM_VERBOSITY=%s", plusarg_string) ) begin
      if (plusarg_string == "UVM_MEDIUM") begin
        $display($sformatf("<%=obj.BlockId%> %s", err_code_entry.info));
      end
    end
  end
endfunction : print_info

//------------------------------------------------------------------------------
// Incoming master request packet
//------------------------------------------------------------------------------
function void dce_scoreboard::write_master_req(sfi_seq_item  item);

  <%=obj.BlockId + '_con'%>::CMDreqEntry_t  cmd_req_entry;
  <%=obj.BlockId + '_con'%>::UPDreqEntry_t  upd_req_entry;
  <%=obj.BlockId + '_con'%>::errCodeEntry_t err_code_entry;
  int                 more_err_code;

<% if (obj.wSecurityAttribute > 0) { %>
  localparam msb = <%=obj.BlockId + '_con'%>::SecureCacheAddrMsb;
  localparam lsb = <%=obj.BlockId + '_con'%>::SecureCacheAddrLsb;
<% } %>


  if (!dce_scoreboard_enable) return;

  err_code_entry.err_code = 0;
  err_code_entry.info     = "";
  more_err_code           = 0;

  if (<%=obj.BlockId + '_con'%>::isUPDreqFromSfi(item.req_pkt)) begin
    upd_req_entry = <%=obj.BlockId + '_con'%>::getUPDreqEntryFromSfi(item.req_pkt);
<% if (obj.wSecurityAttribute > 0) { %>
    upd_req_entry.cache_addr[msb:lsb] = upd_req_entry.req_security;
<% } %>
    upd_req_entry.timestamp = $realtime;
     `ifdef COVER_ON
       m_cov.cover_upd_req(upd_req_entry);
     `endif
    m_csm.putUPDreq (upd_req_entry, err_code_entry);
    upd_req_pkt_map[item.req_pkt.req_transId] = item.req_pkt;
    more_err_code[0] = (item.req_pkt.req_opc    == <%=obj.BlockId + '_con'%>::WRITE) ? 0 : 1;
    more_err_code[1] = (item.req_pkt.req_burst  == <%=obj.BlockId + '_con'%>::INCR ) ? 0 : 1;
    more_err_code[2] = (item.req_pkt.req_length == 0) ? 0 : 1;
    err_code_entry.err_code += (more_err_code << 24);
    if (more_err_code[0]) err_code_entry.info = {err_code_entry.info, "FAILED req_opc should indicate WRITE."};
    if (more_err_code[1]) err_code_entry.info = {err_code_entry.info, "FAILED req_burst should indicate INCR."};
    if (more_err_code[2]) err_code_entry.info = {err_code_entry.info, "FAILED req_length should be 0."};
    print_info(err_code_entry);
  end
  else
  if (<%=obj.BlockId + '_con'%>::isCMDreqFromSfi(item.req_pkt)) begin
    cmd_req_entry = <%=obj.BlockId + '_con'%>::getCMDreqEntryFromSfi(item.req_pkt);
<% if (obj.wSecurityAttribute > 0) { %>
    cmd_req_entry.cache_addr[msb:lsb] = cmd_req_entry.req_security;
<% } %>
    cmd_req_entry.timestamp = $realtime;
     `ifdef COVER_ON
       m_cov.cover_cmd_req(cmd_req_entry);
     `endif
    m_csm.putCMDreq (cmd_req_entry, err_code_entry);
    cmd_req_pkt_map[item.req_pkt.req_transId] = item.req_pkt;
    more_err_code[0] = (item.req_pkt.req_opc    == <%=obj.BlockId + '_con'%>::WRITE) ? 0 : 1;
    more_err_code[1] = (item.req_pkt.req_burst  == <%=obj.BlockId + '_con'%>::INCR ) ? 0 : 1;
    more_err_code[2] = (cmd_req_entry.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdDvmMsg && item.req_pkt.req_length == 15) ? 0 : (item.req_pkt.req_length == 0) ? 0 : 1;
    err_code_entry.err_code += (more_err_code << 24);
    if (more_err_code[0]) err_code_entry.info = {err_code_entry.info, "FAILED req_opc should indicate WRITE."};
    if (more_err_code[1]) err_code_entry.info = {err_code_entry.info, "FAILED req_burst should indicate INCR."};
    if (more_err_code[2]) err_code_entry.info = {err_code_entry.info, "FAILED req_length should be 15 for CmdDvmMsg, otherwise 0."};
    if (cmd_req_entry.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdDvmMsg) begin
      DCE_nDVMInflight--;
      err_code_entry.info = {err_code_entry.info, $sformatf(" DVM credit=%0d", DCE_nDVMInflight)};
    end
    print_info(err_code_entry);
  end
  else begin
    `uvm_error(get_type_name(), $sformatf("Unsupported message type on DCE SFI Slave Request Interface %p %p", item.req_pkt, item.rsp_pkt))
  end


endfunction : write_master_req

//------------------------------------------------------------------------------
// Incoming master response packet
//------------------------------------------------------------------------------
function void dce_scoreboard::write_master_rsp(sfi_seq_item  item);

  <%=obj.BlockId + '_con'%>::CMDreqEntry_t  cmd_req_entry;
  <%=obj.BlockId + '_con'%>::CMDrspEntry_t  cmd_rsp_entry;
  <%=obj.BlockId + '_con'%>::UPDrspEntry_t  upd_rsp_entry;
  <%=obj.BlockId + '_con'%>::errCodeEntry_t err_code_entry;

  if (!dce_scoreboard_enable) return;

  if (cmd_req_pkt_map.exists(item.rsp_pkt.rsp_transId)) begin
    cmd_req_entry = <%=obj.BlockId + '_con'%>::getCMDreqEntryFromSfi(cmd_req_pkt_map[item.rsp_pkt.rsp_transId]);
    cmd_rsp_entry = <%=obj.BlockId + '_con'%>::getCMDrspEntryFromSfi(item.rsp_pkt);
    cmd_rsp_entry.timestamp = $realtime;
    m_csm.putCMDrsp (cmd_rsp_entry, err_code_entry);
    cmd_req_pkt_map.delete(item.rsp_pkt.rsp_transId);
     //COV_TEST
     `ifdef COVER_ON
       m_cov.cover_cmd_rsp(cmd_rsp_entry);
     `endif
    if (cmd_req_entry.cmd_msg_type == <%=obj.BlockId + '_con'%>::eCmdDvmMsg) begin
      DCE_nDVMInflight++;
      err_code_entry.info = {err_code_entry.info, $sformatf(" DVM credit=%0d", DCE_nDVMInflight)};
    end
    print_info(err_code_entry);
  end
  else
  if (upd_req_pkt_map.exists(item.rsp_pkt.rsp_transId)) begin
    upd_rsp_entry = <%=obj.BlockId + '_con'%>::getUPDrspEntryFromSfi(item.rsp_pkt);
    upd_rsp_entry.timestamp = $realtime;
    m_csm.putUPDrsp (upd_rsp_entry, err_code_entry);
     `ifdef COVER_ON
       m_cov.cover_upd_rsp(upd_rsp_entry);
     `endif
    upd_req_pkt_map.delete(item.rsp_pkt.rsp_transId);
    print_info(err_code_entry);
  end
  else begin
    `uvm_error(get_type_name(), $sformatf("Stray transId on DCE SFI Slave Response Interface %p %p", item.req_pkt, item.rsp_pkt))
  end

endfunction : write_master_rsp

//------------------------------------------------------------------------------
// Incoming slave request packet
//------------------------------------------------------------------------------
function void dce_scoreboard::write_slave_req(sfi_seq_item  item);

  <%=obj.BlockId + '_con'%>::SNPreqEntry_t  snp_req_entry;
  <%=obj.BlockId + '_con'%>::HNTreqEntry_t  hnt_req_entry;
  <%=obj.BlockId + '_con'%>::MRDreqEntry_t  mrd_req_entry;
  <%=obj.BlockId + '_con'%>::STRreqEntry_t  str_req_entry;
  <%=obj.BlockId + '_con'%>::errCodeEntry_t err_code_entry;
  <%=obj.BlockId + '_con'%>::sfi_addr_t     sfi_address;
  int                 more_err_code;
  int                 dmi_select;
  int                 base_dmi_unit_id;
  bit                 addrNotInMemRegion;
  int                 memRegion;
  int                 memRegionPrefixMatch;
  bit[<%=obj.BlockId + '_con'%>::DCE_nATTEntries-1:0]   m_attid;
  bit [<%=obj.BlockId + '_con'%>::SYS_nSysCohAIUs-1:0]  dirm_olv;
  bit [<%=obj.BlockId + '_con'%>::SYS_nSysCohAIUs-1:0]  dirm_slv;

  localparam wAttId = $clog2(<%=obj.DceInfo.CmpInfo.nAttCtrlEntries%>);

<% if (obj.wSecurityAttribute > 0) { %>
  localparam msb = <%=obj.BlockId + '_con'%>::SecureCacheAddrMsb;
  localparam lsb = <%=obj.BlockId + '_con'%>::SecureCacheAddrLsb;
<% } %>

  if (!dce_scoreboard_enable) return;

  err_code_entry.err_code = 0;
  err_code_entry.info     = "";
  more_err_code           = 0;
   
  if (<%=obj.BlockId + '_con'%>::isSNPreqFromSfi(item.req_pkt)) begin

    snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(item.req_pkt);
<% if (obj.wSecurityAttribute > 0) { %>
    snp_req_entry.cache_addr[msb:lsb] = snp_req_entry.req_security;
<% } %>

    snp_req_entry.timestamp = $realtime;
    m_attid  = snp_req_entry.snp_sfi_trans_id[wAttId-1:0];

    if(snp_req_entry.snp_msg_type != <%=obj.BlockId + '_con'%>::eSnpDvmMsg) begin
        if(m_dirm_scb.m_dirm_txnq.exists(m_attid)) begin
            dirm_olv = m_dirm_scb.m_dirm_txnq[m_attid].m_olv;
            dirm_slv = m_dirm_scb.m_dirm_txnq[m_attid].m_slv;

        end else begin
            `uvm_error("DCE SCB", $psprintf("SNPreq Unexpected attid:%0d sfi_transid:%0d aiu_transid:%0d req_aiuid:%0d",
                m_attid, snp_req_entry.snp_sfi_trans_id, snp_req_entry.req_aiu_trans_id, snp_req_entry.snp_aiu_unit_id))
        end
    end

    m_csm.putSNPreq (snp_req_entry, err_code_entry, dirm_olv, dirm_slv);
    snp_req_pkt_map[item.req_pkt.req_transId] = item.req_pkt;
    more_err_code[0] = (item.req_pkt.req_opc    == <%=obj.BlockId + '_con'%>::WRITE) ? 0 : 1;
    more_err_code[1] = (item.req_pkt.req_burst  == <%=obj.BlockId + '_con'%>::INCR ) ? 0 : 1;
    more_err_code[2] = (snp_req_entry.snp_msg_type == <%=obj.BlockId + '_con'%>::eSnpDvmMsg && item.req_pkt.req_length == 15) ? 0 : (item.req_pkt.req_length == 0) ? 0 : 1;

     
     
    if (snp_req_entry.snp_msg_type != <%=obj.BlockId + '_con'%>::eSnpDvmMsg) begin
      if (DCE_nSNPInflight[snp_req_entry.snp_aiu_unit_id] > 0) begin
        DCE_nSNPInflight[snp_req_entry.snp_aiu_unit_id]--;
      end else begin
        more_err_code[4] = 1;
      end
      err_code_entry.info = {err_code_entry.info, $sformatf(" SNP credit=%0d", DCE_nSNPInflight[snp_req_entry.snp_aiu_unit_id])};
    end
     `ifdef COVER_ON
       m_cov.cover_snp_req(snp_req_entry, DCE_nSNPInflight[snp_req_entry.snp_aiu_unit_id]);
     `endif
    if (snp_req_entry.snp_msg_type == <%=obj.BlockId + '_con'%>::eSnpDvmMsg) begin
      if (DCE_nSnpDvmInflight[snp_req_entry.snp_aiu_unit_id] > 0) begin
        DCE_nSnpDvmInflight[snp_req_entry.snp_aiu_unit_id]--;
      end else begin
        more_err_code[4] = 1;
      end
      err_code_entry.info = {err_code_entry.info, $sformatf(" SNP credit DVM=%0d", DCE_nSnpDvmInflight[snp_req_entry.snp_aiu_unit_id])};
    end

    err_code_entry.err_code += (more_err_code << 24);
    if (more_err_code[0]) err_code_entry.info = {err_code_entry.info, "FAILED req_opc should indicate WRITE."};
    if (more_err_code[1]) err_code_entry.info = {err_code_entry.info, "FAILED req_burst should indicate INCR."};
    if (more_err_code[2]) err_code_entry.info = {err_code_entry.info, "FAILED req_length should be 15 for SnpDvmMsg, otherwise 0."};
    if (more_err_code[4]) err_code_entry.info = {err_code_entry.info, "FAILED SNP credit pool runs out."};
    print_info(err_code_entry);
  end
  else
  if (<%=obj.BlockId + '_con'%>::isHNTreqFromSfi(item.req_pkt)) begin
    hnt_req_entry = <%=obj.BlockId + '_con'%>::getHNTreqEntryFromSfi(item.req_pkt);
<% if (obj.wSecurityAttribute > 0) { %>
    hnt_req_entry.cache_addr[msb:lsb] = hnt_req_entry.req_security;
<% } %>
     `ifdef COVER_ON
	m_cov.cover_hnt_req(hnt_req_entry);
    `endif				
    hnt_req_entry.timestamp = $realtime;
    m_csm.putHNTreq (hnt_req_entry, err_code_entry);
    hnt_req_pkt_map[item.req_pkt.req_transId] = item.req_pkt;
    more_err_code[0] = (item.req_pkt.req_opc    == <%=obj.BlockId + '_con'%>::WRITE) ? 0 : 1;
    more_err_code[1] = (item.req_pkt.req_burst  == <%=obj.BlockId + '_con'%>::INCR ) ? 0 : 1;
    more_err_code[2] = (item.req_pkt.req_length == 0) ? 0 : 1;
    more_err_code[3] = <%=obj.BlockId + '_con'%>::checkDceMasterTransIdForHNT(item.req_pkt.req_transId) ? 0 : 1;

    err_code_entry.err_code += (more_err_code << 24);
    if (more_err_code[0]) err_code_entry.info = {err_code_entry.info, "FAILED req_opc should indicate WRITE."};
    if (more_err_code[1]) err_code_entry.info = {err_code_entry.info, "FAILED req_burst should indicate INCR."};
    if (more_err_code[2]) err_code_entry.info = {err_code_entry.info, "FAILED req_length should be 0."};
    if (more_err_code[3]) err_code_entry.info = {err_code_entry.info, "FAILED req_transId (DCE Master TransId encoding) for HNT."};
    print_info(err_code_entry);
  end
  else
  if (<%=obj.BlockId + '_con'%>::isMRDreqFromSfi(item.req_pkt)) begin
    mrd_req_entry = <%=obj.BlockId + '_con'%>::getMRDreqEntryFromSfi(item.req_pkt);
    sfi_address = mrd_req_entry.cache_addr;
    <%=obj.BlockId + '_con'%>::mapAddrToSelectDmi(sfi_address, addrNotInMemRegion, memRegion, memRegionPrefixMatch);

<% if (obj.wSecurityAttribute > 0) { %>
    mrd_req_entry.cache_addr[msb:lsb] = mrd_req_entry.req_security;
<% } %>
					
    mrd_req_entry.timestamp = $realtime;
    //dmi_select = <%=obj.BlockId + '_con'%>::mapAddrToSelectDmi(mrd_req_entry.cache_addr) - mrd_req_entry.home_dmi_unit_id;
    base_dmi_unit_id = <%=obj.BlockId + '_con'%>::SYS_nSysAIUs + <%=obj.BlockId + '_con'%>::SYS_nSysDCEs;
    dmi_select = mrd_req_entry.home_dmi_unit_id - base_dmi_unit_id;
    m_csm.putMRDreq (mrd_req_entry, err_code_entry);
    mrd_req_pkt_map[item.req_pkt.req_transId] = item.req_pkt;
    more_err_code[0] = (item.req_pkt.req_opc    == <%=obj.BlockId + '_con'%>::WRITE) ? 0 : 1;
    more_err_code[1] = (item.req_pkt.req_burst  == <%=obj.BlockId + '_con'%>::INCR ) ? 0 : 1;
    more_err_code[2] = (item.req_pkt.req_length == 0) ? 0 : 1;
    more_err_code[3] = <%=obj.BlockId + '_con'%>::checkDceMasterTransIdForMRD(item.req_pkt.req_transId) ? 0 : 1;
    if (DCE_nMRDInflight[memRegion][dmi_select] > 0) begin
      DCE_nMRDInflight[memRegion][dmi_select]--;
    end else begin
      //more_err_code[4] = 1;
    end
     `ifdef COVER_ON
       m_cov.cover_mrd_req(mrd_req_entry, DCE_nMRDInflight[memRegion][dmi_select]);
     `endif
    err_code_entry.err_code += (more_err_code << 24);
    if (more_err_code[0]) err_code_entry.info = {err_code_entry.info, "FAILED req_opc should indicate WRITE."};
    if (more_err_code[1]) err_code_entry.info = {err_code_entry.info, "FAILED req_burst should indicate INCR."};
    if (more_err_code[2]) err_code_entry.info = {err_code_entry.info, "FAILED req_length should be 0."};
    if (more_err_code[3]) err_code_entry.info = {err_code_entry.info, "FAILED req_transId (DCE Master TransId encoding) for MRD."};
    if (more_err_code[4]) err_code_entry.info = {err_code_entry.info, "FAILED MRD credit pool runs out."};
    err_code_entry.info = {err_code_entry.info, $sformatf(" MRD credit[mr=%0d][dmi=%0d]=%0d", memRegion, dmi_select, DCE_nMRDInflight[memRegion][dmi_select])};
    print_info(err_code_entry);
  end
  else
  if (<%=obj.BlockId + '_con'%>::isSTRreqFromSfi(item.req_pkt)) begin
    str_req_entry = <%=obj.BlockId + '_con'%>::getSTRreqEntryFromSfi(item.req_pkt);
    str_req_entry.timestamp = $realtime;
     `ifdef COVER_ON
        m_cov.cover_str_req(str_req_entry);
     `endif

    m_attid  = str_req_entry.str_sfi_trans_id[wAttId-1:0];

    if(str_req_entry.str_msg_type != <%=obj.BlockId + '_con'%>::eStrDvmCmp) begin
        if(m_dirm_scb.m_dirm_txnq.exists(m_attid)) begin
            dirm_olv = m_dirm_scb.m_dirm_txnq[m_attid].m_olv;
            dirm_slv = m_dirm_scb.m_dirm_txnq[m_attid].m_slv;

        end else begin
            `uvm_error("DCE SCB", $psprintf("STRreq Unexpected attid:%0d sfi_transid:%0d aiu_transid:%0d req_aiuid:%0d",
                m_attid, str_req_entry.str_sfi_trans_id, str_req_entry.req_aiu_trans_id, str_req_entry.req_aiu_unit_id))
        end
    end

    m_csm.putSTRreq(str_req_entry, err_code_entry, dirm_olv, dirm_slv);
    str_req_pkt_map[item.req_pkt.req_transId] = item.req_pkt;
    more_err_code[0] = (item.req_pkt.req_opc    == <%=obj.BlockId + '_con'%>::WRITE) ? 0 : 1;
    more_err_code[1] = (item.req_pkt.req_burst  == <%=obj.BlockId + '_con'%>::INCR ) ? 0 : 1;
    more_err_code[2] = (item.req_pkt.req_length == 0) ? 0 : 1;
    err_code_entry.err_code += (more_err_code << 24);
    if (more_err_code[0]) err_code_entry.info = {err_code_entry.info, "FAILED req_opc should indicate WRITE."};
    if (more_err_code[1]) err_code_entry.info = {err_code_entry.info, "FAILED req_burst should indicate INCR."};
    if (more_err_code[2]) err_code_entry.info = {err_code_entry.info, "FAILED req_length should be 0."};
     
    print_info(err_code_entry);
  end
  else begin
    `uvm_error(get_type_name(), $sformatf("Unsupported message type on DCE SFI Master Request Interface %p %p", item.req_pkt, item.rsp_pkt))
  end

endfunction : write_slave_req

//------------------------------------------------------------------------------
// Incoming slave response packet
//------------------------------------------------------------------------------
function void dce_scoreboard::write_slave_rsp(sfi_seq_item  item);

  <%=obj.BlockId + '_con'%>::SNPreqEntry_t  snp_req_entry;
  <%=obj.BlockId + '_con'%>::SNPrspEntry_t  snp_rsp_entry;
  <%=obj.BlockId + '_con'%>::MRDrspEntry_t  mrd_rsp_entry;
  <%=obj.BlockId + '_con'%>::HNTrspEntry_t  hnt_rsp_entry;
  <%=obj.BlockId + '_con'%>::STRrspEntry_t  str_rsp_entry;
  <%=obj.BlockId + '_con'%>::errCodeEntry_t err_code_entry;
  <%=obj.BlockId + '_con'%>::MRDreqEntry_t  mrd_req_entry;
  <%=obj.BlockId + '_con'%>::sfi_addr_t     sfi_address;
  int  dmi_select;
  int  base_dmi_unit_id;
  bit  addrNotInMemRegion;
  int  memRegion;
  int  memRegionPrefixMatch;

  if (!dce_scoreboard_enable) return;

  if (snp_req_pkt_map.exists(item.rsp_pkt.rsp_transId)) begin
    snp_rsp_entry = <%=obj.BlockId + '_con'%>::getSNPrspEntryFromSfi(item.rsp_pkt);
    snp_rsp_entry.timestamp = $realtime;
     //COV_TEST
     `ifdef COVER_ON
       m_cov.cover_snp_rsp(snp_rsp_entry);
     `endif
    m_csm.putSNPrsp (snp_rsp_entry, err_code_entry);
    snp_req_entry = <%=obj.BlockId + '_con'%>::getSNPreqEntryFromSfi(snp_req_pkt_map[item.rsp_pkt.rsp_transId]);

     //if there is a recall error, log what the error registers are supposed to show
     if ((log_SnpRecallErr[8] != 1) && (snp_rsp_entry.rsp_status != 0) && (snp_req_entry.snp_msg_type == <%=obj.BlockId + '_con'%>::eSnpRecall)) begin
	log_SnpRecallErr = 0;
	log_SnpRecallErr[8] = 1;
	log_SnpRecallErr[5] = snp_req_entry.req_security;
	case(snp_rsp_entry.rsp_errCode)
	  <%=obj.BlockId + '_con'%>::SLV :  log_SnpRecallErr[1:0] = <%=obj.BlockId + '_con'%>::SFIPRIV_ERRRESULT_ADDR_ERR;
	  <%=obj.BlockId + '_con'%>::DERR : log_SnpRecallErr[1:0] = <%=obj.BlockId + '_con'%>::SFIPRIV_ERRRESULT_DATA_ERR;	  
	  default :                         log_SnpRecallErr[1:0] = 0;
	endcase // case (snp_rsp_entry.rsp_errCode)
     end
    if (snp_req_entry.snp_msg_type != <%=obj.BlockId + '_con'%>::eSnpDvmMsg) begin
      DCE_nSNPInflight[snp_req_entry.snp_aiu_unit_id]++;
      err_code_entry.info = {err_code_entry.info, $sformatf(" SNP credit=%0d", DCE_nSNPInflight[snp_req_entry.snp_aiu_unit_id])};
    end
    if (snp_req_entry.snp_msg_type == <%=obj.BlockId + '_con'%>::eSnpDvmMsg) begin
      DCE_nSnpDvmInflight[snp_req_entry.snp_aiu_unit_id]++;
      err_code_entry.info = {err_code_entry.info, $sformatf(" SNP credit DVM=%0d", DCE_nSnpDvmInflight[snp_req_entry.snp_aiu_unit_id])};
    end
    print_info(err_code_entry);
    snp_req_pkt_map.delete(item.rsp_pkt.rsp_transId);
  end
  else
  if (mrd_req_pkt_map.exists(item.rsp_pkt.rsp_transId)) begin
    mrd_rsp_entry = <%=obj.BlockId + '_con'%>::getMRDrspEntryFromSfi(item.rsp_pkt);
    mrd_rsp_entry.timestamp = $realtime;
     //COV_TEST
     `ifdef COVER_ON
       m_cov.cover_mrd_rsp(mrd_rsp_entry);
     `endif
    m_csm.putMRDrsp (mrd_rsp_entry, err_code_entry);
    mrd_req_entry = <%=obj.BlockId + '_con'%>::getMRDreqEntryFromSfi(mrd_req_pkt_map[item.rsp_pkt.rsp_transId]);
    sfi_address = mrd_req_entry.cache_addr;
    <%=obj.BlockId + '_con'%>::mapAddrToSelectDmi(sfi_address, addrNotInMemRegion, memRegion, memRegionPrefixMatch);
    //dmi_select = <%=obj.BlockId + '_con'%>::mapAddrToSelectDmi(mrd_req_entry.cache_addr) - mrd_req_entry.home_dmi_unit_id;
    base_dmi_unit_id = <%=obj.BlockId + '_con'%>::SYS_nSysAIUs + <%=obj.BlockId + '_con'%>::SYS_nSysDCEs;
    dmi_select = mrd_req_entry.home_dmi_unit_id - base_dmi_unit_id;
    mrd_req_pkt_map.delete(item.rsp_pkt.rsp_transId);
    DCE_nMRDInflight[memRegion][dmi_select]++;
    err_code_entry.info = {err_code_entry.info, $sformatf(" MRD credit[mr=%0d][dmi=%0d]=%0d", memRegion, dmi_select, DCE_nMRDInflight[memRegion][dmi_select])};
    print_info(err_code_entry);
  end
  else
  if (hnt_req_pkt_map.exists(item.rsp_pkt.rsp_transId)) begin
    hnt_rsp_entry = <%=obj.BlockId + '_con'%>::getHNTrspEntryFromSfi(item.rsp_pkt);
    hnt_rsp_entry.timestamp = $realtime;
     //COV_TEST
     `ifdef COVER_ON
       m_cov.cover_hnt_rsp(hnt_rsp_entry);
     `endif
    m_csm.putHNTrsp (hnt_rsp_entry, err_code_entry);
    hnt_req_pkt_map.delete(item.rsp_pkt.rsp_transId);
    print_info(err_code_entry);
  end
  else
  if (str_req_pkt_map.exists(item.rsp_pkt.rsp_transId)) begin
    str_rsp_entry = <%=obj.BlockId + '_con'%>::getSTRrspEntryFromSfi(item.rsp_pkt);
    str_rsp_entry.timestamp = $realtime;
     //COV_TEST
     `ifdef COVER_ON
       m_cov.cover_str_rsp(str_rsp_entry);
     `endif
    m_csm.putSTRrsp (str_rsp_entry, err_code_entry);
    str_req_pkt_map.delete(item.rsp_pkt.rsp_transId);
    print_info(err_code_entry);
  end
  else begin
    `uvm_error(get_type_name(), $sformatf("Stray transId on DCE SFI Master Response Interface %p %p", item.req_pkt, item.rsp_pkt))
  end

endfunction : write_slave_rsp
    
//------------------------------------------------------------------------------
// Incoming dce probe packet
//------------------------------------------------------------------------------
function void dce_scoreboard::write_dce_probe(dirlookup_seq_item  item);
  <%=obj.BlockId + '_con'%>::CMDreqEntry_t  cmd_req_entry;
  <%=obj.BlockId + '_con'%>::dce_probe_dir_commit_req_packet_t  dir_commit_req;
  <%=obj.BlockId + '_con'%>::dce_dir_commit_info_t  commit_info;
  bit [<%=obj.BlockId + '_con'%>::SYS_nSysCohAIUs-1:0] c_owners, c_aov;
  bit [<%=obj.BlockId + '_con'%>::SYS_nSysCohAIUs-1:0] c_sharers, c_asv;
  <%=obj.BlockId + '_con'%>::cacheAddress_t cache_addr;
  int req_id;
  int req_aiu_id;
  int cache_id;
  int aiu_id;
  bit mon_check_passed;
  bit mon_check_valid;
  int err_code;
  <%=obj.BlockId + '_con'%>::AIUID_t         p2_aiuid;
  int                                        p2_cache_id;

  if (!dce_scoreboard_enable) return;

  //Associate att_id to cache_address map
  if(item.coh_req_packet.valid) begin
      bit [<%=obj.BlockId + '_con'%>::DCE_nATTEntries-1:0] tmp_attid;
      <%=obj.BlockId + '_con'%>::cacheAddress_t            tmp_addr;

      tmp_attid = item.coh_req_packet.att_activate_rsp_attid;
      tmp_addr  = {item.coh_req_packet.coh_req_security, item.coh_req_packet.coh_req_addr};
      attid2cache_addr_map[tmp_attid] = tmp_addr;
  end

  if(item.coh_req_packet.valid) begin
      bit [<%=obj.BlockId + '_con'%>::DCE_nATTEntries-1:0] tmp_attid;
      <%=obj.BlockId + '_con'%>::cacheAddress_t            tmp_addr;

      tmp_attid = item.coh_req_packet.att_activate_rsp_attid;
      tmp_addr  = {item.coh_req_packet.coh_req_security, item.coh_req_packet.coh_req_addr};
      attid2cache_addr_map[tmp_attid] = tmp_addr;
  end
  
  if(item.recall_req_packet.valid) begin
      bit [<%=obj.BlockId + '_con'%>::DCE_nATTEntries-1:0] tmp_attid;
      <%=obj.BlockId + '_con'%>::cacheAddress_t            tmp_addr;

      tmp_attid = item.recall_req_packet.att_activate_rsp_attid;
      tmp_addr  = {item.recall_req_packet.att_activate_security, item.recall_req_packet.att_activate_txn_addr};
      attid2cache_addr_map[tmp_attid] = tmp_addr;
  end

  if(item.dir_commit_req_packet.valid) begin
      bit [<%=obj.BlockId + '_con'%>::DCE_nATTEntries-1:0] tmp_attid;
      <%=obj.BlockId + '_con'%>::cacheAddress_t            tmp_addr;

      tmp_attid = item.dir_commit_req_packet.dir_commit_req_attid;
      tmp_addr  = {item.dir_commit_req_packet.dir_commit_req_security, item.dir_commit_req_packet.dir_commit_req_addr};

      if(attid2cache_addr_map[tmp_attid] != tmp_addr) begin
          string msg;
          $sformat(msg, "cache_addr mismatch attid:%0d {EXP}:0x%0h {ACT}:0x%0h", 
              tmp_attid, attid2cache_addr_map[tmp_attid], tmp_addr);
          `uvm_error("DCE SCB", msg)
      end

      attid2cache_addr_map.delete(tmp_attid);
  end

  if(item.coh_req_packet.valid) begin
    cache_addr = {item.coh_req_packet.coh_req_security, item.coh_req_packet.coh_req_addr};
    cmd_req_entry.cache_addr        = cache_addr;
    cmd_req_entry.req_sfiPriv       = item.coh_req_packet.coh_req_sfipriv;
    cmd_req_entry.cmd_msg_type      = <%=obj.BlockId + '_con'%>::eMsgCMD'(
                                        item.coh_req_packet.coh_req_sfipriv[
                                        <%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_MSB:
                                        <%=obj.BlockId + '_con'%>::SFI_PRIV_MSG_TYPE_LSB]);
    cmd_req_entry.req_aiu_id        = item.coh_req_packet.coh_req_sfipriv[
                                        <%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_MSB:
                                        <%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_LSB];
    cmd_req_entry.req_aiu_trans_id  = item.coh_req_packet.coh_req_sfipriv[
                                        <%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_TRANS_ID_MSB:
                                        <%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_TRANS_ID_LSB];
    if (<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_PROCID_MSB > 0) begin
      cmd_req_entry.req_aiu_proc_id   = item.coh_req_packet.coh_req_sfipriv[
                                        <%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_PROCID_MSB:
                                        <%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_PROCID_LSB];
    end
    cmd_req_entry.ace_lock          = item.coh_req_packet.coh_req_sfipriv[
                                        <%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_ACE_LOCK_MSB:
                                        <%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_ACE_LOCK_LSB];

    req_id = {cmd_req_entry.req_aiu_id, cmd_req_entry.req_aiu_trans_id};

    if (m_csm.cachingIdArray[cmd_req_entry.req_aiu_id] != -1) begin
      m_csm.dce_exclusive_mons.processExclusiveRdClnRdVld(cmd_req_entry);
      m_csm.dce_exclusive_mons.processExclusiveClnUnq(cmd_req_entry, mon_check_passed, mon_check_valid);
      m_csm.m_att_map[req_id].mon_chk_passed = mon_check_passed & mon_check_valid;
      m_csm.m_att_map[req_id].mon_chk_failed = (~mon_check_passed) & mon_check_valid;
    end

    m_csm.dce_directory.c_get_lookup_vectors (cache_addr, item.coh_req_packet.att_activate_rsp_attid, c_owners, c_sharers);
  end

  if(item.wake_req_packet.valid) begin
    cache_addr = {item.wake_req_packet.wake_req_security, item.wake_req_packet.wake_req_addr};
    m_csm.dce_directory.c_get_lookup_vectors(cache_addr, item.wake_req_packet.wake_req_attid, c_owners, c_sharers);
  end

  if(item.dir_rsp_packet.valid) begin
      cache_addr = attid2cache_addr_map[item.dir_rsp_packet.dir_rsp_attid];
      m_csm.dce_directory.c_get_lookup_vectors(cache_addr, item.dir_rsp_packet.dir_rsp_attid, c_owners, c_sharers);
  end

  if ((item.dir_commit_req_packet.valid && item.dir_commit_req_packet.dir_commit_req_dont_write) &&
      (item.dir_commit_req_packet.dir_commit_req_ocv == 0) && (item.dir_commit_req_packet.dir_commit_req_scv == 0) &&
      (item.dir_commit_req_packet.dir_commit_req_aiuid == 0)) begin
    $display("%t <%=obj.BlockId%> Coherent Recall dir_commit_req_packet=%p", $time, item.dir_commit_req_packet);
    //Recall
    cache_addr = {item.dir_commit_req_packet.dir_commit_req_security, item.dir_commit_req_packet.dir_commit_req_addr};
    if (m_csm.m_snp_recall_slice.exists(cache_addr & m_csm.CACHE_ADDR_MASK)) begin
      m_csm.m_snp_recall_slice.delete(cache_addr & m_csm.CACHE_ADDR_MASK);
    end
    if (m_csm.m_snp_recall_attid.exists(cache_addr & m_csm.CACHE_ADDR_MASK)) begin
      m_csm.m_snp_recall_attid.delete(cache_addr & m_csm.CACHE_ADDR_MASK);
    end
  end
  if ((item.dir_commit_req_packet.valid && !item.dir_commit_req_packet.dir_commit_req_dont_write && item.dir_commit_req_packet.dir_commit_req_maint_recall) &&
      (item.dir_commit_req_packet.dir_commit_req_ocv == 0) && (item.dir_commit_req_packet.dir_commit_req_scv == 0) &&
      (item.dir_commit_req_packet.dir_commit_req_aiuid == 0)) begin
    $display("%t <%=obj.BlockId%> Maintenance Recall dir_commit_req_packet=%p", $time, item.dir_commit_req_packet);
    //Recall
    cache_addr = {item.dir_commit_req_packet.dir_commit_req_security, item.dir_commit_req_packet.dir_commit_req_addr};
    if (m_csm.m_snp_recall_slice.exists(cache_addr & m_csm.CACHE_ADDR_MASK)) begin
      m_csm.m_snp_recall_slice.delete(cache_addr & m_csm.CACHE_ADDR_MASK);
    end
    if (m_csm.m_snp_recall_attid.exists(cache_addr & m_csm.CACHE_ADDR_MASK)) begin
      m_csm.m_snp_recall_attid.delete(cache_addr & m_csm.CACHE_ADDR_MASK);
    end
    req_aiu_id = m_csm.m_maint_recall_map[cache_addr & m_csm.CACHE_ADDR_MASK];
    cache_id = m_csm.cachingIdArray[req_aiu_id];
    for (int i=0; i < <%=obj.BlockId + '_con'%>::SYS_nSysAIUs; i++) begin
        if ((m_csm.dce_directory.eosFilterAgentsSlices[i] == m_csm.dce_directory.eosFilterAgentsSlices[req_aiu_id]) && (m_csm.dce_directory.eosFilterAgentsSlices[i] != -1)) begin
          m_csm.dce_directory.c_invalidate(i, cache_addr);
          $display("%t <%=obj.BlockId%> maint_recall_req_packet now invalidates directory AIU=%0d cache_addr=%0x", $time, i, cache_addr);
          m_csm.updateAIUState(i, cache_addr, <%=obj.BlockId + '_con'%>::IX, 0);
        end
        if ((m_csm.dce_directory.pvFilterAgentsSlices[i] == m_csm.dce_directory.pvFilterAgentsSlices[req_aiu_id]) && (m_csm.dce_directory.pvFilterAgentsSlices[i] != -1)) begin
          m_csm.dce_directory.c_invalidate(i, cache_addr);
          $display("%t <%=obj.BlockId%> maint_recall_req_packet now invalidates directory AIU=%0d cache_addr=%0x", $time, i, cache_addr);
          m_csm.updateAIUState(i, cache_addr, <%=obj.BlockId + '_con'%>::IX, 0);
        end
    end //for
  end
  if(item.upd_req_packet.valid) begin
    cache_addr = {item.upd_req_packet.upd_req_security, item.upd_req_packet.upd_req_addr};
    req_aiu_id = item.upd_req_packet.upd_req_sfipriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_LSB];
    m_csm.dce_directory.c_invalidate(req_aiu_id, cache_addr);
    upd_map[cache_addr & m_csm.CACHE_ADDR_MASK] = 1;
  end
  if(item.recall_req_packet.valid) begin
    cache_addr = {item.recall_req_packet.att_activate_security, item.recall_req_packet.att_activate_txn_addr};
    req_aiu_id = item.recall_req_packet.att_activate_txn_sfipriv[<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_MSB:<%=obj.BlockId + '_con'%>::SFI_PRIV_REQ_AIU_ID_LSB];
    cache_id = m_csm.cachingIdArray[req_aiu_id];

    p2_aiuid = item.recall_req_packet.p2_aiuid;
    p2_cache_id = m_csm.cachingIdArray[p2_aiuid];

    $display("%t <%=obj.BlockId%> recall_req_packet=%p, cache_addr=%0x req_aiu_id=%0d cache_id=%0d p2_aiuid=%0d p2_cache_id=%0d", $time, item.recall_req_packet, cache_addr, req_aiu_id, cache_id, p2_aiuid, p2_cache_id);
    if (!item.recall_req_packet.att_activate_txn_is_wakeup && item.recall_req_packet.att_activate_maint_recall) begin
      m_csm.m_maint_recall_map[cache_addr & m_csm.CACHE_ADDR_MASK] = m_csm.dce_directory.idSnoopFilterAgents[item.recall_req_packet.maint_req_snoopfilter_id][0]; //req_aiu_id;
    end
    if (!item.recall_req_packet.att_activate_txn_is_wakeup && !item.recall_req_packet.att_activate_maint_recall) begin
      for (int i=0; i < <%=obj.BlockId + '_con'%>::SYS_nSysAIUs; i++) begin
        p2_cache_id = m_csm.cachingIdArray[i];
        if ((m_csm.dce_directory.eosFilterAgentsSlices[i] == m_csm.dce_directory.eosFilterAgentsSlices[p2_aiuid]) && (m_csm.dce_directory.eosFilterAgentsSlices[i] != -1)) begin
          m_csm.dce_directory.c_invalidate(i, cache_addr);
          if (p2_cache_id != -1) begin
            for (int myattid=0; myattid < 64; myattid++) begin
              m_csm.dce_directory.c_lookup_owner_vector2[cache_addr & m_csm.CACHE_ADDR_MASK][myattid][p2_cache_id] = 0;
              m_csm.dce_directory.c_lookup_sharer_vector2[cache_addr & m_csm.CACHE_ADDR_MASK][myattid][p2_cache_id] = 0;
            end
          end
          $display("%t <%=obj.BlockId%> recall_req_packet now invalidates directory AIU=%0d cache_addr=%0x", $time, i, cache_addr);
          m_csm.updateAIUState(i, cache_addr, <%=obj.BlockId + '_con'%>::IX, 0);
        end
        if ((m_csm.dce_directory.pvFilterAgentsSlices[i] == m_csm.dce_directory.pvFilterAgentsSlices[p2_aiuid]) && (m_csm.dce_directory.pvFilterAgentsSlices[i] != -1)) begin
          m_csm.dce_directory.c_invalidate(i, cache_addr);
          if (p2_cache_id != -1) begin
            for (int myattid=0; myattid < 64; myattid++) begin
              m_csm.dce_directory.c_lookup_owner_vector2[cache_addr & m_csm.CACHE_ADDR_MASK][myattid][p2_cache_id] = 0;
              m_csm.dce_directory.c_lookup_sharer_vector2[cache_addr & m_csm.CACHE_ADDR_MASK][myattid][p2_cache_id] = 0;
            end
          end
          $display("%t <%=obj.BlockId%> recall_req_packet now invalidates directory AIU=%0d cache_addr=%0x", $time, i, cache_addr);
          m_csm.updateAIUState(i, cache_addr, <%=obj.BlockId + '_con'%>::IX, 0);
        end
      end
    end
  end
  if(item.hw_req_packet.valid) begin
    $display("%t <%=obj.BlockId%> hw_req_packet=%p", $time, item.hw_req_packet);

    for (int f=0; f < <%=obj.SnoopFilterInfo.length%>; f++ ) begin
      for (int i=0; i < m_csm.dce_directory.idSnoopFilterAgents[f].size(); i++ ) begin
        if (item.hw_req_packet.DIRUSFER_SfEn[f] == 0) begin
          m_csm.m_SfEnChanges = 1;
          aiu_id = m_csm.dce_directory.idSnoopFilterAgents[f][i];
          cache_id = m_csm.cachingIdArray[aiu_id];
          m_csm.SfEnPerAiu[aiu_id] = 0;
          m_csm.dce_directory.nullFilterAgents[aiu_id] = 1;
          m_csm.dce_directory.eosFilterAgents[aiu_id] = 0;
          m_csm.dce_directory.pvFilterAgents[aiu_id] = 0;
          if (cache_id != -1) begin
            m_csm.dce_directory.c_nullFilterAgents[cache_id] = 1;
            m_csm.dce_directory.c_eosFilterAgents[cache_id] = 0;
            m_csm.dce_directory.c_pvFilterAgents[cache_id] = 0;
          end
          $display("m_csm.dce_directory.nullFilterAgents=%b", m_csm.dce_directory.nullFilterAgents);
          $display("m_csm.dce_directory.eosFilterAgents=%b", m_csm.dce_directory.eosFilterAgents);
          $display("m_csm.dce_directory.pvFilterAgents=%b", m_csm.dce_directory.pvFilterAgents);
          $display("m_csm.dce_directory.c_nullFilterAgents[cache_id=%0d]=%b", cache_id, m_csm.dce_directory.c_nullFilterAgents[cache_id]);
          $display("m_csm.dce_directory.c_eosFilterAgents[cache_id=%0d]=%b", cache_id, m_csm.dce_directory.c_eosFilterAgents[cache_id]);
          $display("m_csm.dce_directory.c_pvFilterAgents[cache_id=%0d]=%b", cache_id, m_csm.dce_directory.c_pvFilterAgents[cache_id]);
        end //if
      end //foreach
    end //for

<% if (obj.AiuInfo.length > 0) { %>
    m_csm.CaSnpEn[<%=obj.AiuInfo.length%>-1:0] = item.hw_req_packet.DIRUCASER_CaSnpEn[<%=obj.AiuInfo.length%>-1:0];
<% } %>
<% if (obj.BridgeAiuInfo.length > 1) { %>
    m_csm.CaSnpEn[<%=obj.BridgeAiuInfo.length+obj.AiuInfo.length%>-1:<%=obj.AiuInfo.length%>] = item.hw_req_packet.DIRUCASER_CaSnpEn[<%=obj.BridgeAiuInfo.length%>-1+96:96];
<% } %>
    m_csm.regMrHntEn  = item.hw_req_packet.DIRUMRHER_MrHntEn;
    m_csm.DvmSnpEn    = item.hw_req_packet.CSADSER_DvmSnpEn;
    $display("%t CacheStateModel SfEnPerAiu = %0x, CaSnpEn = %0x, regMrHntEn = %0x, DvmSnpEn = %0x", $time, m_csm.SfEnPerAiu, m_csm.CaSnpEn, m_csm.regMrHntEn, m_csm.DvmSnpEn);
  end

  if (item.dir_commit_req_packet.valid && !item.dir_commit_req_packet.dir_commit_req_dont_write) begin
    cache_addr = {item.dir_commit_req_packet.dir_commit_req_security, item.dir_commit_req_packet.dir_commit_req_addr};
    c_owners  = item.dir_commit_req_packet.dir_commit_req_ocv; 
    c_sharers = item.dir_commit_req_packet.dir_commit_req_scv; 
    m_csm.dce_directory.c_active_owner_vector[cache_addr & m_csm.CACHE_ADDR_MASK] = c_owners;
    m_csm.dce_directory.c_active_sharer_vector[cache_addr & m_csm.CACHE_ADDR_MASK] = c_sharers;
    if (upd_map.exists(cache_addr & m_csm.CACHE_ADDR_MASK)) begin
      upd_map.delete(cache_addr & m_csm.CACHE_ADDR_MASK);
    end
  end

  if ((item.dir_commit_req_packet.valid && (item.dir_commit_req_packet.dir_commit_req_dont_write || item.dir_commit_req_packet.dir_commit_req_maint_recall)) &&
      (item.dir_commit_req_packet.dir_commit_req_ocv == 0) && (item.dir_commit_req_packet.dir_commit_req_scv == 0) &&
      (item.dir_commit_req_packet.dir_commit_req_aiuid == 0)) begin
    //Recall (coherent or maintenance)

  end else if (item.dir_commit_req_packet.valid) begin

    dir_commit_req = item.dir_commit_req_packet;

    if (m_csm.m_commit_info_q.size()) begin
      commit_info = m_csm.m_commit_info_q.pop_front();

      err_code = 0;
      req_aiu_id = commit_info.cmd_req_entry.req_aiu_id;
      cache_id = m_csm.cachingIdArray[req_aiu_id];

      if (dir_commit_req.dir_commit_req_dont_write == 0) begin
        if (dir_commit_req.dir_commit_req_addr       != commit_info.cmd_req_entry.cache_addr[<%=obj.BlockId + '_con'%>::SYS_wSysAddress-1:0]) err_code[1] = 1;
        if (dir_commit_req.dir_commit_req_security   != commit_info.cmd_req_entry.req_security) err_code[2] = 1;
        if (dir_commit_req.dir_commit_req_aiuid      != commit_info.cmd_req_entry.req_aiu_id) err_code[3] = 1;
        if (dir_commit_req.dir_commit_req_attid      != commit_info.str_rsp_entry.str_sfi_trans_id[$clog2(<%=obj.BlockId + '_con'%>::DCE_nATTEntries)-1:0]) err_code[4] = 1;
        if (dir_commit_req.dir_commit_req_ocv != commit_info.c_owner_commit_vector) err_code[6] = 1;
        if (dir_commit_req.dir_commit_req_scv != commit_info.c_sharer_commit_vector) err_code[7] = 1;
      end
`ifdef PSEUDO_SYS_TB
      if (err_code) `uvm_warning(get_type_name(), $sformatf("DEBUG WARNING DIR_COMMIT err_code=%0x cache_id=%0x, dir_commit_req=%p TB(ocv=%0x osv=%0x)", err_code, cache_id, item.dir_commit_req_packet, commit_info.c_owner_commit_vector, commit_info.c_sharer_commit_vector))
`else
//      if (err_code) `uvm_error(get_type_name(), $sformatf("DEBUG WARNING DIR_COMMIT err_code=%0x cache_id=%0x, dir_commit_req=%p TB(ocv=%0x osv=%0x)", err_code, cache_id, item.dir_commit_req_packet, commit_info.c_owner_commit_vector, commit_info.c_sharer_commit_vector))
`endif
    end
  end

endfunction : write_dce_probe

////////////////////////////////////////////////////////////////////////////////
`ifndef PSEUDO_SYS_TB
function void dce_scoreboard::write_reset_port(reset_pkt item);
  $display("SAW RESET");

  if (item.reset_on == 1) begin // reset goes active
$display("RESET goes ACTIVE");
    dce_scoreboard_enable = 0;
    cmd_req_pkt_map.delete();
    upd_req_pkt_map.delete();
    snp_req_pkt_map.delete();
    hnt_req_pkt_map.delete();
    mrd_req_pkt_map.delete();
    str_req_pkt_map.delete();
    upd_map.delete();
    DCE_nSNPInflight = <%=this.DCE_nSNPInflight%>;
    DCE_nSnpDvmInflight = <%=this.DCE_nSnpDvmInflight%>;
    <% for (var i=0; i < obj.MemRegionInfo.length; i++) { %>
    <%   for (var k=0; k < obj.DmiInfo.length; k++) { %>
           DCE_nMRDInflight[<%=i%>][<%=k%>] = <%=obj.MemRegionInfo[i].CmpInfo.nMrdInFlight%>;
    <%   } %>
    <% } %>
    DCE_nDVMInflight = <%=obj.BlockId + '_con'%>::DCE_nDTFSkidBufferSize;
  end

  if (item.reset_on == 0) begin // reset goes inactive
$display("RESET goes INACTIVE");
    dce_scoreboard_enable = 1;
    m_csm = new();
  end

endfunction // write_dce_probe
`endif
