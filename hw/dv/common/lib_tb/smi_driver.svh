////////////////////////////////////////////////////////////////////////////////
//
// SMI Driver
<% if (1 == 0) { %>
// Author: Chirag Gandhi
<% } %>
//
////////////////////////////////////////////////////////////////////////////////

class smi_driver #(smi_agent_type_enum_t agent_type=SMI_TRANSMITTER) extends uvm_driver #(smi_seq_item);
    `uvm_component_param_utils(smi_driver #(agent_type))

    virtual <%=obj.BlockId + '_smi_if'%> m_vif;
    smi_agent_type_enum_t                m_agent_type;
    bit [2:0]                            inj_cntl;
    integer unsigned                     corr_error_inj_pcnt;
    integer unsigned                     uncorr_error_inj_pcnt;
    integer unsigned                     parity_error_inj_pcnt;
    <% if (obj.useResiliency) { %>
    uvm_event                            single_err_inj_ev;
    uvm_event                            err_inj_ev;
    smi_seq_item                         single_err_inj_item;
    bit                                  single_err_inj_on;
    bit                                  single_err_inj_arg;
    <% } %>

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "smi_driver", uvm_component parent = null);
        super.new(name, parent);
        m_agent_type = agent_type;
        <% if (obj.useResiliency) { %>
        single_err_inj_item = smi_seq_item::type_id::create("single_err_inj_item");
        single_err_inj_ev = uvm_event_pool::get_global("single_err_inj_ev");
        err_inj_ev = uvm_event_pool::get_global("err_inj_ev");
        single_err_inj_on = 0;
        if($test$plusargs("single_err_inj")) begin
          single_err_inj_arg = 1;
        end
        if (! $value$plusargs("inj_cntl=%d", inj_cntl) ) begin
           inj_cntl = 0;
        end
        <% if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "none") { %>
             inj_cntl = 3'b000;
        <% } else { %>
        <%     if (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType == "parity") { %>
             inj_cntl = $test$plusargs("inject_smi_uncorr_error") ? 3'b100 : ( 3'b100 & inj_cntl );
        <%     } else { %>
             inj_cntl = $test$plusargs("inject_smi_uncorr_error") ? 3'b011 : ( 3'b011 & inj_cntl );
        <%     } %>
        <%   } %>
        <% } else { %>
             inj_cntl = 3'b000;
        <% } %>
        //#Stimulus.IOAIU.Smi.CorrectableErr
        //#Stimulus.IOAIU.Smi.UncorrectableErr
        //#Stimulus.IOAIU.TransportErr
        if (! $value$plusargs("corr_error_inj_pcnt=%0d", corr_error_inj_pcnt) ) begin
           corr_error_inj_pcnt = $test$plusargs("inject_corr_error")?1:0;
        end
        if (! $value$plusargs("uncorr_error_inj_pcnt=%0d", uncorr_error_inj_pcnt) ) begin
           uncorr_error_inj_pcnt = $test$plusargs("inject_smi_uncorr_error")?1:0;
        end
        if (! $value$plusargs("parity_error_inj_pcnt=%0d", parity_error_inj_pcnt) ) begin
           parity_error_inj_pcnt = $test$plusargs("inject_smi_uncorr_error")?(uncorr_error_inj_pcnt?uncorr_error_inj_pcnt:1):0;
        end
        `uvm_info($sformatf("%m"), $sformatf("ECC corr error pcnt=%0d, uncorr error pcnt=%0d, parity pcnt=%0d",
                                             corr_error_inj_pcnt, uncorr_error_inj_pcnt, parity_error_inj_pcnt), UVM_NONE)
    endfunction : new

    //------------------------------------------------------------------------------
    // Run Task
    //------------------------------------------------------------------------------
    task run;
        mailbox#(smi_seq_item) m_driver_seq_item = new(1);
        bit reset_goes_inactive;
        bit sync_m_reset;
        bit sync_m_reset_dup;
        bit reset_goes_inactive_dup;
        bit [2:0] err_inj_mask;
        int unsigned err_inj_pcnt_gnrtd;

        if (m_agent_type == SMI_TRANSMITTER) begin : TRANS
            fork
                m_vif.drive_dp_nonvalid();
                m_vif.drive_ndp_nonvalid();
            join
            @(posedge m_vif.rst_n);
            repeat(10)  @(posedge m_vif.clk);
            fork
                begin : fork_1
                    forever begin : forever_1
                        automatic smi_seq_item m_item;
                        seq_item_port.get_next_item(m_item);
                        m_item.pack_smi_seq_item();
                       `uvm_info(get_full_name(),$sformatf("ECC DEBUG D2O %p", m_item), UVM_HIGH);
<% if ( (obj.useResiliency) && (obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType != "none") ) { %>
                        <% if(obj.testBench == "chi_aiu") { %>
                              err_inj_pcnt_gnrtd = $urandom_range(0, 99) > 80 ? $urandom_range(0,99) : 0;
                        <% } else { %>
                              err_inj_pcnt_gnrtd = $urandom_range(0, 99);
                        <% } %>
                        err_inj_mask       = 3'b111;
                        if ( ((inj_cntl[1:0] != 2'b00) && ("<%=obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType%>" != "ecc")) ||
                             ((inj_cntl[2] != 1'b0) && ("<%=obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType%>" != "parity")) ) begin
                           `uvm_info($sformatf("%m"), $sformatf("Inject: inj_cntl set to 0 since protection type does not match inj_cntl"), UVM_DEBUG)
                            inj_cntl = 0;
                        end
                        if ((inj_cntl & 3'b001) && (err_inj_pcnt_gnrtd >= corr_error_inj_pcnt)) begin
                             err_inj_mask = 3'b110;
                        end
                        if ((inj_cntl & 3'b010) && (err_inj_pcnt_gnrtd >= uncorr_error_inj_pcnt)) begin
                             err_inj_mask = 3'b101;
                        end
                        if ((inj_cntl & 3'b100) && (err_inj_pcnt_gnrtd >= parity_error_inj_pcnt)) begin
                             err_inj_mask = 3'b011;
                        end

                        `uvm_info($sformatf("%m"), $sformatf("ERR INJECT MASK = %0b, generated pcnt=%0d inj_cntl=%0b", err_inj_mask, err_inj_pcnt_gnrtd, inj_cntl), UVM_HIGH)
                        $cast(single_err_inj_item, m_item.clone());
                        /*
                         *NDP error injection
                         */
                        if($test$plusargs("smi_ndp_err_inj") && !single_err_inj_on) begin
                          single_err_inj_item.smi_ndp = inject_smi_ndp_error(single_err_inj_item.smi_msg_type, single_err_inj_item.smi_ndp, inj_cntl & err_inj_mask);
                          if(single_err_inj_item.smi_ndp != m_item.smi_ndp) begin
                            `uvm_info($sformatf("%m"), $sformatf("Injected SMI_PKT_NDP error {org:%0h|mod:%0h}", single_err_inj_item.smi_ndp, m_item.smi_ndp), UVM_NONE)
                              err_inj_ev.trigger();
                            if(single_err_inj_arg) begin
                              single_err_inj_ev.trigger();
                            end
                          end
                        end
                        /*
                         *DP error injection
                         */
                        if (m_item.smi_dp_present && $test$plusargs("smi_dp_ecc_inj") && !single_err_inj_on) begin
                            smi_dp_user_bit_t           dp_user_beat_b4inj, dp_user_beat_injctd;
                            bit [WSMIDPUSERPERDW  -1:0] dp_user_b4inj, dp_user_injctd;
                            bit [wSmiDPbundle     -1:0] dp_b4inj, dp_injctd;
                            bit [WSMIDPPROTPERDW  -1:0] dp_prot_b4inj, dp_prot_injctd;
                            bit [63                 :0] dp_data_b4inj, dp_data_injctd;
                            bit [wSmiDPbundle     -1:0] dp_dataBundle_b4inj, dp_dataBundle_injctd;

                            `uvm_info($sformatf("%m"),$sformatf("ECC DEBUG DI: %p", single_err_inj_item.convert2string()), UVM_DEBUG)
                            foreach (single_err_inj_item.smi_dp_data[i]) begin
                               dp_user_beat_b4inj = single_err_inj_item.smi_dp_user[i];
                               for (int j=0; j<(wSmiDPdata/64); j++) begin
                                  // ECC is calculated using <dp_prot>,dp_data,dp_dbad,dp_dwid,<dp_concUser>,dp_be
                                  dp_user_b4inj = single_err_inj_item.userToProtChk(dp_user_beat_b4inj[j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW]);
                                  dp_data_b4inj = single_err_inj_item.smi_dp_data[i][j*64 +: 64];
                                  dp_prot_b4inj = dp_user_b4inj[SmiDPUserProtNpM:SmiDPUserProtNpL];
                                  dp_dataBundle_b4inj = { dp_prot_b4inj,
                                                          dp_data_b4inj,
                                                          dp_user_b4inj[SmiDPUserDbadNpM:0]
                                                          };
                                  dp_dataBundle_injctd = smi_inject_error(single_err_inj_item.smi_msg_type, dp_dataBundle_b4inj, wSmiDPbundleNoProt, wSmiDPbundle, inj_cntl & err_inj_mask);
                                  dp_prot_injctd       = dp_dataBundle_injctd[wSmiDPbundle-1:wSmiDPbundleNoProt];
                                  dp_data_injctd       = dp_dataBundle_injctd[wSmiDPbundleNoProt-1:wSmiDPbundleNoProt-64];
                                  dp_user_injctd       = { dp_prot_injctd, dp_dataBundle_injctd[wSmiDPbundleNoProt-64-1:0] };

                                  if (dp_dataBundle_b4inj != dp_dataBundle_injctd) begin
                                     `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG D0: Beat%0d DW%0d: Injected SMI_PKT_DP error in DP payload: orig:%p injctd:%p",
                                                                          i, j, dp_dataBundle_b4inj, dp_dataBundle_injctd), UVM_NONE)
                                     `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG D1: Beat%0d DW%0d, DP_USER(b4:%p aft:%p), DP_DATA(b4:%p aft:%p)",
                                                                          i, j, dp_user_b4inj, dp_user_injctd,
                                                                          single_err_inj_item.smi_dp_data[i][j*64 +: 64], dp_data_injctd), UVM_HIGH)
                                     single_err_inj_item.smi_dp_user[i][j*WSMIDPUSERPERDW +: WSMIDPUSERPERDW] = single_err_inj_item.userFromProtChk(dp_user_injctd);
                                     single_err_inj_item.smi_dp_data[i][j*64              +: 64             ] = dp_data_injctd;
                              	     err_inj_ev.trigger();
                                     if(single_err_inj_arg) begin
                                         single_err_inj_ev.trigger();
                                     end
                                  end // if (dp_dataBundle_b4inj != dp_dataBundle_injctd)
                               end // for (int j=0; j<(wSmiDPdata/64); j++)
                               `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG D2: %p", single_err_inj_item.convert2string()), UVM_HIGH)
                            end // foreach (single_err_inj_item.smi_dp_data[i])
                         end // if (single_err_inj_item.smi_dp_present && $test$plusargs("smi_dp_ecc_inj") && !single_err_inj_on)
                        /*
                         *HDR error injection
                         */
                        if ($test$plusargs("smi_hdr_err_inj") && !single_err_inj_on) begin
                           `uvm_info($sformatf("%m"),$sformatf("Inject SMI HDR error msg_type:%0p", single_err_inj_item.smi_msg_type), UVM_HIGH)
                            {single_err_inj_item.smi_msg_hprot,single_err_inj_item.smi_targ_id,single_err_inj_item.smi_src_id,single_err_inj_item.smi_msg_type,single_err_inj_item.smi_msg_id}
                                 = smi_inject_error(single_err_inj_item.smi_msg_type, {single_err_inj_item.smi_msg_hprot,single_err_inj_item.smi_targ_id,single_err_inj_item.smi_src_id,single_err_inj_item.smi_msg_type,single_err_inj_item.smi_msg_id},
                                                    WSMITGTID+WSMISRCID+WSMIMSGTYPE+WSMIMSGID, WSMIHPROT+WSMITGTID+WSMISRCID+WSMIMSGTYPE+WSMIMSGID, inj_cntl & err_inj_mask);
                             // update smi_msg_user as smi_msg_hprot is an alias of it.
                            single_err_inj_item.smi_msg_user = single_err_inj_item.smi_msg_hprot;
							 // Not sending data for non-dtr/non-dtw req to avoid read data mismatch in scoreboard
							<% if(obj.testBench == "chi_aiu") { %>
                                                           if ($test$plusargs("uncorr_error_inj_pcnt"))begin
							    if(m_item.hasDP() && single_err_inj_item.smi_msg_type != m_item.smi_msg_type && !single_err_inj_item.hasDP()) single_err_inj_item.smi_dp_present = 0;
end
							<% } %>
                            if({single_err_inj_item.smi_msg_hprot,single_err_inj_item.smi_targ_id,single_err_inj_item.smi_src_id,single_err_inj_item.smi_msg_type,single_err_inj_item.smi_msg_id} != {m_item.smi_msg_hprot,m_item.smi_targ_id,m_item.smi_src_id,m_item.smi_msg_type,m_item.smi_msg_id}) begin
                                `uvm_info($sformatf("%m"), $sformatf("Injected SMI_PKT_HDR error {org:%0h|mod:%0h}", {single_err_inj_item.smi_msg_hprot,single_err_inj_item.smi_targ_id,single_err_inj_item.smi_src_id,single_err_inj_item.smi_msg_type,single_err_inj_item.smi_msg_id}, {m_item.smi_msg_hprot,m_item.smi_targ_id,m_item.smi_src_id,m_item.smi_msg_type,m_item.smi_msg_id}), UVM_NONE)
                                err_inj_ev.trigger();
                                if(single_err_inj_arg) begin
                                    single_err_inj_ev.trigger();
                                 end
                             end
                         end // if ($test$plusargs("smi_hdr_err_inj") && !single_err_inj_on)
                         `uvm_info($sformatf("%m"), $sformatf("DEBUG D3: %p", single_err_inj_item.convert2string()), UVM_HIGH)
                         m_driver_seq_item.put(single_err_inj_item);
<% } else { %>
                         `uvm_info($sformatf("%m"), $sformatf("DEBUG D4: %p", m_item.convert2string()), UVM_HIGH)
                         m_driver_seq_item.put(m_item);
<% } %>
                         seq_item_port.item_done();
                    end : forever_1
                end : fork_1
                begin : fork_2
                    forever begin : forever_2
                        smi_seq_item m_drv_item;
                        m_driver_seq_item.get(m_drv_item);
                       `uvm_info(get_full_name(),$sformatf("ECC DEBUG D2A %p", m_drv_item), UVM_HIGH);
                        fork
                            begin
                                m_vif.drive_ndp(m_drv_item);
                            end
                            begin
                                smi_seq_item m_temp_item;
                                if (m_drv_item.smi_dp_present) begin
                                    for (int i=0; i<m_drv_item.smi_dp_data.size(); i++) begin
                                        $cast(m_temp_item, m_drv_item.clone());
                                        m_temp_item.smi_dp_data       = new[1];
                                        m_temp_item.smi_dp_data[0]    = m_drv_item.smi_dp_data[i];
                                        m_temp_item.smi_dp_user       = new [1];
                                        m_temp_item.smi_dp_user[0]    = m_drv_item.smi_dp_user[i];
                                        m_temp_item.smi_dp_last       = (i==(m_drv_item.smi_dp_data.size()-1));
                                        `uvm_info($sformatf("%m"), $sformatf("ECC DEBUG D2B: Beat%0d: %p", i, m_temp_item.convert2string()), UVM_HIGH)
                                        #0 m_vif.drive_dp(m_temp_item);
                                    end
                                end
                            end
                        join
                    end : forever_2
                end : fork_2
              <% if (obj.useResiliency) { %>
                begin : fork_3
                  if(single_err_inj_arg) begin
                    `uvm_info($sformatf("%m"), $sformatf("Waiting for event single_err_inj_ev to trigger"), UVM_DEBUG)
                    single_err_inj_ev.wait_on();
                    `uvm_info($sformatf("%m"), $sformatf("Event single_err_inj_ev triggered"), UVM_DEBUG)
                    single_err_inj_on = 'b1;
                  end
                end : fork_3
              <% } %>
            join_none
        end : TRANS
        else if (m_agent_type == SMI_RECEIVER) begin : RECV
            fork
                m_vif.drive_smi_rx_nonready();
            join
            @(posedge m_vif.rst_n);
            forever begin
                fork
                    m_vif.drive_smi_rx_ready();
                join
            end
        end : RECV
    endtask : run
endclass : smi_driver
