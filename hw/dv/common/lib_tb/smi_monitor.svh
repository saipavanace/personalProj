////////////////////////////////////////////////////////////////////////////////
// SMI Monitor
<% if (1 == 0) { %>
// Author: Chirag Gandhi
<% } %>
////////////////////////////////////////////////////////////////////////////////
class smi_monitor #(smi_agent_type_enum_t agent_type = SMI_TRANSMITTER, int port_id = 0) extends uvm_monitor;

    `uvm_component_param_utils(smi_monitor);

<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
        virtual <%=obj.BlockId + '_smi_force_if'%>  m_vif;
     `else
    	virtual <%=obj.BlockId + '_smi_if'%>  m_vif;
    `endif
<% } else { %> 
    virtual <%=obj.BlockId + '_smi_if'%>  m_vif;
<% } %>

    bit                                   delay_export;
    smi_agent_type_enum_t                 m_agent_type;
    int                                   m_port_id;
    bit                                   is_transmitter;

    uvm_analysis_port #(smi_seq_item) smi_ap;
    uvm_analysis_port #(smi_seq_item) every_beat_smi_ap;
    uvm_analysis_port #(smi_seq_item) smi_ndp_ap;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "smi_monitor", uvm_component parent = null);
        super.new(name, parent);
        m_agent_type = agent_type;
        m_port_id    = port_id;
    endfunction : new

    function void build();
        smi_ap            = new("smi_ap", this);
        every_beat_smi_ap = new("every_beat_smi_ap", this);
        smi_ndp_ap        = new("smi_ndp_ap", this);
    endfunction : build

    //------------------------------------------------------------------------------
    // Run Task
    //------------------------------------------------------------------------------
    task run;
        mailbox #(smi_seq_item) m_ndp_items_mb    = new();
        mailbox #(smi_seq_item) m_dp_items_mb     = new();
        @(posedge m_vif.rst_n);
        fork
            begin
                // collect ndp packets
                forever begin
                    smi_seq_item m_ndp_item     = smi_seq_item::type_id::create("ndp_item");
                    smi_seq_item m_ndp2_item    = smi_seq_item::type_id::create("ndp2_item");
                    m_vif.collect_ndp(m_ndp_item);
                  <% if (!obj.useResiliency) { %>
                    m_ndp_item.unpack_smi_seq_item();
                  <% } %>
                    m_ndp_item.smi_transmitter = is_transmitter;
                    m_ndp2_item.do_copy(m_ndp_item);
                    m_ndp2_item.unpack_smi_seq_item();
                    smi_ndp_ap.write(m_ndp2_item);
                    `uvm_info(get_full_name(), $sformatf("ECC DEBUG M0: %p", m_ndp2_item.convert2string()), UVM_HIGH)
                    check_packet(m_ndp_item);
                    m_ndp_items_mb.put(m_ndp_item);
                end
            end
            begin
                // collect dp packets
                forever begin
                    smi_seq_item m_dp_item = smi_seq_item::type_id::create("dp_item");
                    m_vif.collect_dp(m_dp_item);
                    m_dp_item.unpack_dp_smi_seq_item();
                    m_dp_item.smi_transmitter = is_transmitter;
                    check_packet(m_dp_item);
                    m_dp_items_mb.put(m_dp_item);
                end
            end
            begin : AP_WRITE
                // Analysis port writes
                forever begin
                  <% if (obj.useResiliency) { %>
                    smi_ndp_len_bit_t pld_len;
                    smi_ndp_protection_t  prot;
                  <% } %>
                    smi_seq_item m_item            = smi_seq_item::type_id::create("m_item");
                    smi_seq_item m_every_beat_item = smi_seq_item::type_id::create("m_every_beat_item");
                    smi_seq_item m_tmp_item        = smi_seq_item::type_id::create("m_tmp_item");
                    m_ndp_items_mb.get(m_tmp_item);
                    m_item.do_copy(m_tmp_item);
                    m_item.clear_error_counts();
                    //#Check.DMI.Concerto.v3.0.MrdReqHProt
                    //#Check.DMI.Concerto.v3.0.MrdReqMProt
                    //#Check.DMI.Concerto.v3.0.MrdRspHProt
                    //#Check.DMI.Concerto.v3.0.MrdRspMProt
                    //#Check.DMI.Concerto.v3.0.DtrReqHProt
                    //#Check.DMI.Concerto.v3.0.DtrReqMProt
                    //#Check.DMI.Concerto.v3.0.RbReqHProt
                    //#Check.DMI.Concerto.v3.0.RbReqMProt
                    //#Check.DMI.Concerto.v3.0.RbRspHProt
                    //#Check.DMI.Concerto.v3.0.RbRspMProt
                    //#Check.DMI.Concerto.v3.0.DtwReqHProt
                    //#Check.DMI.Concerto.v3.0.DtwReqMProt
                    //#Check.DMI.Concerto.v3.0.DtwRspHProt
                    //#Check.DMI.Concerto.v3.0.DtwRspMProt
                    //#Check.DMI.Concerto.v3.0.RbuReqHProt
                    //#Check.DMI.Concerto.v3.0.RbuReqMProt
                    //#Check.DMI.Concerto.v3.0.RbuRspHProt
                    //#Check.DMI.Concerto.v3.0.RbuRspMProt
                    //#Check.DMI.Concerto.v3.0.CmdReqHProt
                    //#Check.DMI.Concerto.v3.0.CmdReqMProt
                    //#Check.DMI.Concerto.v3.0.CmdRspMProt
                    //#Check.DMI.Concerto.v3.0.STRRspHPROT
                    //#Check.DMI.Concerto.v3.0.DtrRspHProt
                    //#Check.DMI.Concerto.v3.0.DtrRspMProt
                    //#Check.DMI.Concerto.v3.0.STRreqMPROT
                    //#Check.IOAIU.SMI.CMDReq.HProt
                    //#Check.IOAIU.SMI.CMDReq.MProt
                    //#Check.IOAIU.SMI.SNPRsp.MProt
                    //#Check.IOAIU.SMI.StrRsp.HProt
                    //#Check.IOAIU.SMI.StrRsp.MProt
                    //#Check.IOAIU.SMI.DtrReq.HProt
                    //#Check.IOAIU.SMI.DtwReq.HProt
                    //#Check.IOAIU.SMI.DtwReq.MProt
                    //#Check.IOAIU.SMI.DtwRsp.HProt
                    //#Check.IOAIU.SMI.DtwRsp.MProt
                    //#Check.IOAIU.SMI.UpdReq.HProt
                    //#Check.IOAIU.SMI.UpdReq.MProt
                    //#Check.IOAIU.SMI.SysReq.HProt
                    //#Check.IOAIU.SMI.SysReq.MProt
                    //#Check.IOAIU.SMI.SysRSP.HProt
                    //#Check.IOAIU.SMI.SysRSP.MProt
                    //#Check.IOAIU.SMI.DtrRsp.HProt
                    //#Check.IOAIU.SMI.DtrRsp.MProt
                    //#Check.IOAIU.SMI.SNPReq.HProt
                  <% if (obj.useResiliency) { %>
                    `uvm_info(get_name(), "Correcting NDP error for every_beat_smi_ap port", UVM_DEBUG)
                    m_item.clear_error_counts();
                    begin : CHECK_N_CORRECT_NDP
                       // Check if there check bits match
                       <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                         // check hdr
                       prot = checkSECDED_N( {m_item.smi_targ_id, m_item.smi_src_id, m_item.smi_msg_type, m_item.smi_msg_id}, WSMITGTID+WSMISRCID+WSMIMSGTYPE+WSMIMSGID, 0);
                       <% } else if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %> 
                       prot = checkPARITY_N( {m_item.smi_targ_id, m_item.smi_src_id, m_item.smi_msg_type, m_item.smi_msg_id}, WSMITGTID+WSMISRCID+WSMIMSGTYPE+WSMIMSGID );
                       <% } %>
                       if ( prot != m_item.smi_msg_user ) begin
                          `uvm_info($sformatf("%m"), $sformatf("Agent=%p: HDR ECC Not match: msg_type=%0h: exp ECC=%0h, act ECC=%0h (targId=%0p srcId=%0p, msgId=%0p)",
                                                               m_agent_type, m_item.smi_msg_type, prot, m_item.smi_msg_user, m_item.smi_targ_id, m_item.smi_src_id, m_item.smi_msg_id), UVM_HIGH)
                           m_item.correct_smi_hdr_error();
                           m_tmp_item.correct_smi_hdr_error();
                          `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG M1H: Corrected HDR: msg_type=%p targId=%p srcId=%p, msgId=%p Prot=%p",
                                                               m_item.smi_msg_type, m_item.smi_targ_id, m_item.smi_src_id, m_item.smi_msg_id, m_item.smi_msg_user), UVM_HIGH)
                       end
                       m_item.unpack_smi_seq_item();

                       pld_len = get_ndp_len(m_item.smi_msg_type, 0);
                       <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                       prot = checkSECDED_N( m_item.smi_ndp, pld_len, 0 );
                       <% } else if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %> 
                       prot = checkPARITY_N( m_item.smi_ndp, pld_len );
                       <% } %>
                       if ( prot != ((m_item.smi_ndp >> pld_len) & ((1 << (m_item.smi_ndp_len-pld_len)) - 1)) ) begin
                          `uvm_info($sformatf("%m"), $sformatf("Agent=%p: NDP ECC Not match: ndp len=%0d pld len=%0d msg_type=%0h, exp ECC=%0h, act ECC=%0h",
                                                               m_agent_type, m_item.smi_ndp_len, pld_len, m_item.smi_msg_type, prot,
                                                               ((m_item.smi_ndp >> pld_len) & ((1 << (m_item.smi_ndp_len-pld_len))-1))), UVM_DEBUG)

                            m_item.correct_smi_ndp_error();
                            m_tmp_item.correct_smi_ndp_error();
                       end
                       m_item.unpack_smi_seq_item();

//                       if (m_item.hasDP()) begin
//                             m_item.unpack_dp_smi_seq_item();
//                       end
                    end : CHECK_N_CORRECT_NDP
                  <% } %>
                    `uvm_info(get_full_name(), $sformatf("ECC DEBUG M2: %p", m_item.convert2string()), UVM_HIGH)

                    if (m_item.hasDP()) begin
                        bit [WSMIDPUSERPERDW-1:0] dp_user_b4inj, dp_user_corr;
                        bit [wSmiDPbundle   -1:0] dp_pld_b4inj, dp_pld_injctd;
                        smi_seq_item m_tmp_data_item;
                        do begin
                            m_tmp_data_item = smi_seq_item::type_id::create("m_tmp_data_item");
                            m_dp_items_mb.get(m_tmp_data_item);
                            $cast(m_every_beat_item, m_item.clone());
                            m_every_beat_item.do_copy_one_beat_data_zero_out(m_tmp_data_item);
                            m_every_beat_item.smi_dp_present = 1;  // for debugging purposes
//                            m_every_beat_item.unpack_dp_smi_seq_item();
                            `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG M3: every_beat_item %p", m_every_beat_item.convert2string()), UVM_HIGH) 
                            foreach(m_every_beat_item.smi_dp_user[i]) begin
<% if ( (obj.useResiliency) && (obj.AiuInfo[0].concParams.cmdReqParams.wMProt > 0) ) { %>
                               if (WSMIDPPROTPERDW > 0) begin
                                  for(int j=0; j<wSmiDPdata/64; j++) begin
                                  // DP_USER LAYOUT: {dbad, dwid, prot, <conc_user>, be}
                                  // For injectio/correction: the payload needs to be {prot, data, dbad, dwid, <conc_user>, be}
                                     dp_user_b4inj = m_every_beat_item.userToProtChk(m_every_beat_item.smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW]);
                                     dp_pld_b4inj  = { dp_user_b4inj[SmiDPUserProtNpM:SmiDPUserProtNpL],
                                                       m_every_beat_item.smi_dp_data[i][j*64 +: 64],
                                                       dp_user_b4inj[SmiDPUserDbadNpM:0]};
<% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                                     prot = checkSECDED_N(dp_pld_b4inj, wSmiDPbundleNoProt, 0);
<% } else if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
                                     prot = checkPARITY_N(dp_pld_b4inj, wSmiDPbundleNoProt   );
<% } %>
                                     if ( prot != dp_user_b4inj[SmiDPUserProtM:SmiDPUserProtL] ) begin
                                         `uvm_info($sformatf("%m"), $sformatf("Agent=%p: DP ECC Not match: Beat%0d DW=%0d, pld=%p exp ECC=%0h, act ECC=%0h (prot:%p data:%p userNP:%p)",
                                                                              m_agent_type, i, j, dp_pld_b4inj, prot, dp_user_b4inj[SmiDPUserProtM:SmiDPUserProtL],
                                                                              dp_user_b4inj[SmiDPUserProtNpM:SmiDPUserProtNpL], m_every_beat_item.smi_dp_data[i][j*64 +: 64], dp_user_b4inj[SmiDPUserDbadNpM:0]), UVM_HIGH)
                                     end
                                  end // for (int j=0; j<wSmiDPdata/64; j++)
                                  m_every_beat_item.correct_smi_dp_error();
                               end // if (WSMIDPPROTPERDW > 0)
<% } %>
                                m_item.do_copy_one_beat_data_only(m_every_beat_item);
                                m_item.unpack_dp_smi_seq_item();
                                if (m_item.update_error_counts(m_every_beat_item)) begin
                                   `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG ME: error detected SB=%0d, DB=%0d, P=%0d",
                                                                        m_item.ndp_corr_error + m_item.hdr_corr_error + m_item.dp_corr_error,
                                                                        m_item.ndp_uncorr_error + m_item.hdr_uncorr_error + m_item.dp_uncorr_error,
                                                                        m_item.ndp_parity_error + m_item.hdr_parity_error + m_item.dp_parity_error), UVM_HIGH)
                                end
                                `uvm_info(get_full_name(), $sformatf("ECC DEBUG M4: every_beat_item %p m_item %p",
                                                                     m_every_beat_item.convert2string(), m_item.convert2string()), UVM_HIGH) 
                            end // foreach (m_every_beat_item.smi_dp_user[i])
                            if (m_agent_type == SMI_RECEIVER && delay_export) begin
                                #0;
                            end 
                            m_every_beat_item.unpack_dp_smi_seq_item();
                            `uvm_info(get_full_name(), $sformatf("ECC DEBUG M10: Beat%0d %p", m_item.smi_dp_data.size(), m_item.convert2string()), UVM_HIGH)
                            every_beat_smi_ap.write(m_every_beat_item);
                        end while (m_every_beat_item.smi_dp_last == 0);
                    end // if (m_item.hasDP())
                    if (delay_export) begin
                        #0;
                    end 

                    m_item.unpack_smi_seq_item();
                    `uvm_info(get_full_name(), $sformatf("ECC DEBUG M11: %p", m_item.convert2string()), UVM_HIGH)
                    `uvm_info(get_full_name(), $sformatf("ECC DEBUG M12: agent_type=%p msg_type=%p ndp=%p hprot=%0h",
                                                         agent_type, m_item.smi_msg_type, m_item.smi_ndp, m_item.smi_msg_user), UVM_MEDIUM)
                    smi_ap.write(m_item);
                    `uvm_info(get_full_name(),$sformatf("Wrote item to smi_ap in monitor"), UVM_HIGH);
                end // forever begin
            end : AP_WRITE
        join
    endtask: run

    //---------------------------------------------------------------------------
    // Creating a place holder for version 3.4..
    // The SMI common checks will be moving from the Unit Scoreboards to here.
    //---------------------------------------------------------------------------
    function void check_packet(smi_seq_item smi_pkt);
      if (smi_pkt.smi_msg_type==8'hA0) begin          // DtwDbgReq - NDP bus
          if (smi_pkt.smi_tm) 
             `uvm_error(get_name(), $psprintf("RTL failed to set the TM-bit to 0, for DTWDbgReq..."))  
      end
      if (smi_pkt.smi_msg_type==8'hFF) begin          // DtwDbgRsp - NDP bus
          if (smi_pkt.smi_tm) 
             `uvm_error(get_name(), $psprintf("RTL should never set the TM-bit for DTWDbgRsp..."))  
      end
    endfunction : check_packet

endclass: smi_monitor
