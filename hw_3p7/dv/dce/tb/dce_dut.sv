module dce_dut (

  input logic    clk,
  input logic    rst_n,
  sfi_if.slave   slave_if,
  sfi_if.master  master_if

);

  parameter MAX_NUM_OF_PENDING_CMD_REQ = 8;

  CacheStateModel        csm;
  CON::sfi_req_packet_t  att_cache_addr_map[CON::cacheAddress_t];
  CON::sfi_req_packet_t  snp_req_pkt_map [CON::TransID_t];
  CON::sfi_req_packet_t  mrd_req_pkt_map [CON::TransID_t];
  CON::sfi_req_packet_t  str_req_pkt_map [CON::TransID_t];
  CON::sfi_req_packet_t  slave_req_pkts[$];
  CON::sfi_req_packet_t  slave_req_pkts_cmd[$];
  CON::sfi_req_packet_t  slave_req_pkts_rsp[$];
  CON::sfi_req_packet_t  str_req_pend_pkts[$];
  CON::sfi_req_packet_t  mrd_req_pend_pkts[$];
  int                    num_of_pending_cmd_req;

  //
  // Instantiate Cache State Model for tracking transactions
  //
  initial begin
    csm = new();
  end

  //
  // Slave Interface: Request
  //
  initial begin
    bit drive_rdy_high;
    slave_if.async_reset_slave_request();
    @(posedge rst_n);
    forever begin
      // back-pressure if the number of pending CMDreq messages exceed or equal to the max limit
      drive_rdy_high = (num_of_pending_cmd_req < MAX_NUM_OF_PENDING_CMD_REQ) ? 1 : 0;
      slave_if.drive_slave_request(drive_rdy_high);
    end // forever
  end

  //
  // Slave Interface: collect Request packets (CMDreq) so as to issue Response packets (CMDrsp)
  //
  initial begin
    CON::sfi_req_packet_t slave_req_pkt;
    @(posedge rst_n);
    forever begin
      slave_if.collect_slave_request_packet(slave_req_pkt);
      slave_req_pkts_cmd.push_back(slave_req_pkt);
      num_of_pending_cmd_req++;
    end // forever
  end

  initial begin
    CON::sfi_req_packet_t slave_req_pkt;
    CON::sfi_rsp_packet_t slave_rsp_pkt;
    CON::CMDreqEntry_t    cmd_req_entry;
    CON::errCodeEntry_t   err_code_entry;

    slave_if.async_reset_slave_response();
    @(posedge rst_n);

    forever begin
      @(posedge clk);
      if (slave_req_pkts_cmd.size()) begin
        slave_req_pkt = slave_req_pkts_cmd.pop_front();
        slave_rsp_pkt.rsp_status     = 'h0;
        slave_rsp_pkt.rsp_errCode    = 'h0;
        slave_rsp_pkt.rsp_transId    = slave_req_pkt.req_transId;
        slave_rsp_pkt.rsp_sfiPriv    = slave_req_pkt.req_sfiPriv;
        slave_rsp_pkt.rsp_data       = slave_req_pkt.req_data;
        slave_rsp_pkt.rsp_protBits   = slave_req_pkt.req_protBits;

        slave_if.drive_slave_response(slave_rsp_pkt, slave_req_pkt.req_length);

        slave_req_pkts_rsp.push_back(slave_req_pkt);

        cmd_req_entry = CON::getCMDreqEntryFromSfi(slave_req_pkt);
        csm.putCMDreq (cmd_req_entry, err_code_entry);
      end
    end // forever
  end

  //
  // Slave Interface: collect Response packets (CMDrsp) so as to issue SNPreq / STRreq
  //
  initial begin
    CON::sfi_req_packet_t slave_req_pkt;
    CON::sfi_rsp_packet_t slave_rsp_pkt;
    CON::CMDrspEntry_t    cmd_rsp_entry;
    CON::errCodeEntry_t   err_code_entry;
    @(posedge rst_n);
    forever begin
      slave_if.collect_slave_response_packet(slave_rsp_pkt);
      if (slave_req_pkts_rsp.size()) begin
        slave_req_pkt = slave_req_pkts_rsp.pop_front();
        slave_req_pkts.push_back(slave_req_pkt);
        cmd_rsp_entry = CON::getCMDrspEntryFromSfi(slave_rsp_pkt);
        csm.putCMDrsp (cmd_rsp_entry, err_code_entry);
      end
    end // forever
  end

  //
  // Master Interface: Response
  //
  initial begin
    master_if.async_reset_master_response();
    @(posedge rst_n);
    forever begin
      master_if.drive_master_response();
    end // forever
  end

  //
  // Collect request transactions on DCE master_if, push it to Cache State Model,
  // and remember the TransID so as to track the response transactions on DCE master_if.
  //
  initial begin
    CON::sfi_req_packet_t master_req_pkt;
    CON::SNPreqEntry_t    snp_req_entry;
    CON::MRDreqEntry_t    mrd_req_entry;
    CON::STRreqEntry_t    str_req_entry;
    CON::errCodeEntry_t   err_code_entry;
    @(posedge rst_n);
    forever begin
      master_if.collect_master_request_packet(master_req_pkt);

      if (CON::isSNPreqFromSfi(master_req_pkt)) begin
        snp_req_entry = CON::getSNPreqEntryFromSfi(master_req_pkt);
        csm.putSNPreq (snp_req_entry, err_code_entry);
        snp_req_pkt_map[master_req_pkt.req_transId] = master_req_pkt;
      end
      else
      if (CON::isMRDreqFromSfi(master_req_pkt)) begin
        mrd_req_entry = CON::getMRDreqEntryFromSfi(master_req_pkt);
        csm.putMRDreq (mrd_req_entry, err_code_entry);
        mrd_req_pkt_map[master_req_pkt.req_transId] = master_req_pkt;
      end
      else
      if (CON::isSTRreqFromSfi(master_req_pkt)) begin
        str_req_entry = CON::getSTRreqEntryFromSfi(master_req_pkt);
        csm.putSTRreq (str_req_entry, err_code_entry);
        str_req_pkt_map[master_req_pkt.req_transId] = master_req_pkt;
      end
    end // forever
  end

  //
  // Collect response transactions on DCE master_if, push it to Cache State Model.
  // For snoop response, track if enough responses have been collected so as to issue a STRreq transaction.
  //
  // If any of the snooping AIUs are able to provide the cacheline data, as determined by the DCE from
  // all the SNPrsp messages, the DCE issues a STRreq message to the requesting AIU, summarizing the
  // results of the coherence operations and indicating the final cache state.
  // If none of the snooping AIUs are able to provide the cacheline data, the DCE issues an MRDreq message to a DMI.

  initial begin
    CON::sfi_rsp_packet_t master_rsp_pkt;
    CON::SNPrspEntry_t    snp_rsp_entry;
    CON::MRDrspEntry_t    mrd_rsp_entry;
    CON::STRrspEntry_t    str_rsp_entry;
    CON::errCodeEntry_t   err_code_entry;
    int                   send_str_req;
    CON::sfi_req_packet_t snp_req_pkt;
    CON::AIUTransID_t     req_aiu_trans_id;
    CON::coherResult_t    coher_result;
    CON::MsgType_t        msg_type;

    @(posedge rst_n);
    forever begin
      master_if.collect_master_response_packet(master_rsp_pkt);

      if (snp_req_pkt_map.exists(master_rsp_pkt.rsp_transId)) begin

        snp_rsp_entry = CON::getSNPrspEntryFromSfi(master_rsp_pkt);
        csm.putSNPrsp (snp_rsp_entry, err_code_entry);

        snp_req_pkt      = snp_req_pkt_map[master_rsp_pkt.rsp_transId];
        msg_type         = snp_req_pkt.req_sfiPriv[CON::SFI_PRIV_MSG_TYPE_MSB:CON::SFI_PRIV_MSG_TYPE_LSB]; //[4:0];
        req_aiu_trans_id = snp_req_pkt.req_sfiPriv[CON::SFI_PRIV_REQ_TRANS_ID_MSB:CON::SFI_PRIV_REQ_TRANS_ID_LSB]; //[13:8]
        send_str_req = 0;
        for (int i = 0; i < CON::SYS_nSysAIUs; i++) begin
          if (csm.m_att_map[req_aiu_trans_id].snp_req_valid[i] &&
              csm.m_att_map[req_aiu_trans_id].snp_rsp_valid[i]) begin
            send_str_req++;
          end
        end
        if (send_str_req == (CON::SYS_nSysAIUs-1)) begin //HOT! Number of Snoops
          csm.peekAttCoherResult(req_aiu_trans_id, coher_result);
          if ((coher_result.ST == 0) &&
               ((msg_type == CON::SNP_CLN_DTR) || 
                (msg_type == CON::SNP_VLD_DTR) || 
                (msg_type == CON::SNP_INV_DTR))) begin 
              mrd_req_pend_pkts.push_back(snp_req_pkt);
          end else begin
            str_req_pend_pkts.push_back(snp_req_pkt);
          end
        end

        snp_req_pkt_map.delete(master_rsp_pkt.rsp_transId);

      end
      else
      if (mrd_req_pkt_map.exists(master_rsp_pkt.rsp_transId)) begin

        mrd_rsp_entry = CON::getMRDrspEntryFromSfi(master_rsp_pkt);
        csm.putMRDrsp (mrd_rsp_entry, err_code_entry);
        str_req_pend_pkts.push_back(mrd_req_pkt_map[master_rsp_pkt.rsp_transId]);
        mrd_req_pkt_map.delete(master_rsp_pkt.rsp_transId);

      end
      else
      if (str_req_pkt_map.exists(master_rsp_pkt.rsp_transId)) begin

        str_rsp_entry = CON::getSTRrspEntryFromSfi(master_rsp_pkt);
        csm.putSTRrsp (str_rsp_entry, err_code_entry);
        att_cache_addr_map.delete(str_req_pkt_map[master_rsp_pkt.rsp_transId].req_addr);
        str_req_pkt_map.delete(master_rsp_pkt.rsp_transId);
        if (num_of_pending_cmd_req) num_of_pending_cmd_req--;

      end
    end // forever
  end

  //
  // Process CMDreq list and send SNPreq out on DCE master_if.
  // Process STRreq pending list and send it STRreq out on DCE master_if.
  //
  initial begin
    CON::sfi_req_packet_t master_req_pkt;
    CON::MsgType_t        msg_type;
    CON::eMsgCMD          cmd;
    CON::eMsgSNP          snp;
    CON::AIUID_t          req_aiu_id;
    CON::sfi_transId_t    transId_counter;
    CON::coherResult_t    coher_result;
    CON::AIUTransID_t     req_aiu_trans_id;

    master_if.async_reset_master_request();
    @(posedge rst_n);

    forever begin
      @(posedge clk);
      //
      // process CMDreq and send out SNPreq
      //
      if (slave_req_pkts.size() && !(att_cache_addr_map.exists(slave_req_pkts[0].req_addr))) begin
        att_cache_addr_map[slave_req_pkts[0].req_addr] = slave_req_pkts[0];
        master_req_pkt = slave_req_pkts.pop_front();
        msg_type   = master_req_pkt.req_sfiPriv[CON::SFI_PRIV_MSG_TYPE_MSB:CON::SFI_PRIV_MSG_TYPE_LSB]; //[4:0];
        req_aiu_id = master_req_pkt.req_sfiPriv[CON::SFI_PRIV_REQ_AIU_ID_MSB:CON::SFI_PRIV_REQ_AIU_ID_LSB]; //[7:5]
        cmd = CON::eMsgCMD'(msg_type);
        for (int i = 0; i < CON::SYS_nSysAIUs; i++) begin
          if ( i != req_aiu_id ) begin
            master_req_pkt.req_sfiSlvId = i;

            master_req_pkt.req_transId = CON::getDceMasterTransIdForSNP (transId_counter);

            transId_counter++;
            if (CON::mapOwnerSNPreq (cmd, snp)) begin
              master_req_pkt.req_sfiPriv[CON::SFI_PRIV_MSG_TYPE_MSB:CON::SFI_PRIV_MSG_TYPE_LSB] = CON::MsgType_t'(snp); //[4:0]
              master_req_pkt.req_length = 0;
              master_if.drive_master_request(master_req_pkt);
            end
          end
        end // for
        // Randomly send out HNTreq immediately after sending out SNPreq for CmdRdCpy, CmdRdCln, CmdRdVld, CmdRdUnq
        case (msg_type)
          CON::CMD_RD_CPY, CON::CMD_RD_CLN, CON::CMD_RD_VLD, CON::CMD_RD_UNQ :
            if ($urandom_range(1, 0) == 0) begin
              master_req_pkt.req_sfiPriv[CON::SFI_PRIV_MSG_TYPE_MSB:CON::SFI_PRIV_MSG_TYPE_LSB] = CON::HNT_READ;

              master_req_pkt.req_transId = CON::getDceMasterTransIdForHNT (transId_counter);

              transId_counter++;
              master_req_pkt.req_sfiSlvId = CON::SYS_nSysAIUs + 1; // this is HOME_DMI_UNIT_ID
              master_if.drive_master_request(master_req_pkt);
            end
        endcase
        // No snoop for CmdUpd, need to send STRreq directly.
        if ((cmd == CON::eCmdUpdInv) || (cmd == CON::eCmdUpdVld)) begin
          str_req_pend_pkts.push_back(master_req_pkt);
        end
      end
      //
      // send out MRDreq (note: MRDreq contents is similar to SNPreq, except the bit field req_sfiSlvId (UnitID) and MsgType.
      //
      if (mrd_req_pend_pkts.size()) begin
        master_req_pkt = mrd_req_pend_pkts.pop_front();
        master_req_pkt.req_sfiPriv[CON::SFI_PRIV_MSG_TYPE_MSB:CON::SFI_PRIV_MSG_TYPE_LSB] = CON::MRD_READ; //[4:0];

        master_req_pkt.req_transId = CON::getDceMasterTransIdForMRD (transId_counter);

        transId_counter++;
        master_req_pkt.req_sfiSlvId = CON::SYS_nSysAIUs + 1; // this is HOME_DMI_UNIT_ID
        master_if.drive_master_request(master_req_pkt);
      end
      //
      // send out STRreq
      //
      if (str_req_pend_pkts.size()) begin
        master_req_pkt = str_req_pend_pkts.pop_front();
        master_req_pkt.req_sfiPriv[CON::SFI_PRIV_MSG_TYPE_MSB:CON::SFI_PRIV_MSG_TYPE_LSB] = CON::STR_STATE; //[4:0];

        master_req_pkt.req_transId = CON::getDceMasterTransIdForSTR (transId_counter);

        transId_counter++;

        req_aiu_id       = master_req_pkt.req_sfiPriv[CON::SFI_PRIV_REQ_AIU_ID_MSB  :CON::SFI_PRIV_REQ_AIU_ID_LSB]; //[7:5];
        req_aiu_trans_id = master_req_pkt.req_sfiPriv[CON::SFI_PRIV_REQ_TRANS_ID_MSB:CON::SFI_PRIV_REQ_TRANS_ID_LSB]; //[13:8];

        csm.peekAttCoherResult(req_aiu_trans_id, coher_result);

        master_req_pkt.req_sfiSlvId = req_aiu_id;
        master_req_pkt.req_sfiPriv[CON::SFI_PRIV_COHER_RESULT_MSB:CON::SFI_PRIV_COHER_RESULT_LSB] = coher_result; //[17:14]
        master_req_pkt.req_length = 0;

        master_if.drive_master_request(master_req_pkt);
      end
      
    end  // forever
  end

endmodule : dce_dut
