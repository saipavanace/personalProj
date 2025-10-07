class smi_packet_t extends uvm_object
    smi_targ_id_logic_t  smi_targ_id;
    smi_src_id_logic_t   smi_src_id;
    smi_msg_tier_logic_t smi_msg_tier;
    smi_msg_qos_logic_t  smi_msg_qos;
    smi_ndp_len_logic_t  smi_ndp_len;
    smi_ndp_logic_t      smi_ndp;
    bit                  smi_dp_present;
    smi_cdw_logic_t      smi_cdw;
    smi_msg_len_logic_t  smi_msg_len;
    smi_dp_data_logic_t  smi_dp_data[$];
    smi_dp_be_logic_t    smi_dp_be[$];
    smi_dp_user_logic_t  smi_dp_user[$];

    `uvm_object_utils_begin(smi_packet_t)
        `uvm_field_int (smi_targ_id, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (smi_src_id, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (smi_msg_tier, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (smi_msg_qos, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (smi_ndp_len, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (smi_ndp, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (smi_dp_present, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (smi_cdw, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (smi_msg_len, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (smi_dp_data, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (smi_dp_be, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (smi_dp_user, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end


    function new();
    endfunction : new

    function bit do_compare_pkts(smi_packet_t m_pkt);
        bit legal = 1;
        if (this.smi_targ_id !== m_pkt.smi_targ_id) begin
            uvm_report_info(get_full_name(), $sformatf("ERROR Expected: smi_targ_id: 0x%0x Actual: smi_targ_id: 0x%0x", this.smi_targ_id, m_pkt.smi_targ_id), UVM_NONE); 
            legal = 0;
        end
        if (this.smi_src_id !== m_pkt.smi_src_id) begin
            uvm_report_info(get_full_name(), $sformatf("ERROR Expected: smi_src_id: 0x%0x Actual: smi_src_id: 0x%0x", this.smi_src_id, m_pkt.smi_src_id), UVM_NONE); 
            legal = 0;
        end
        if (this.smi_msg_tier !== m_pkt.smi_msg_tier) begin
            uvm_report_info(get_full_name(), $sformatf("ERROR Expected: smi_msg_tier: 0x%0x Actual: smi_msg_tier: 0x%0x", this.smi_msg_tier, m_pkt.smi_msg_tier), UVM_NONE); 
            legal = 0;
        end
        if (this.smi_msg_qos !== m_pkt.smi_msg_qos) begin
            uvm_report_info(get_full_name(), $sformatf("ERROR Expected: smi_msg_qos: 0x%0x Actual: smi_msg_qos: 0x%0x", this.smi_msg_qos, m_pkt.smi_msg_qos), UVM_NONE); 
            legal = 0;
        end
        if (this.smi_ndp_len !== m_pkt.smi_ndp_len) begin
            uvm_report_info(get_full_name(), $sformatf("ERROR Expected: smi_ndp_len: 0x%0x Actual: smi_ndp_len: 0x%0x", this.smi_ndp_len, m_pkt.smi_ndp_len), UVM_NONE); 
            legal = 0;
        end
        if (this.smi_ndp !== m_pkt.smi_ndp) begin
            uvm_report_info(get_full_name(), $sformatf("ERROR Expected: smi_ndp: 0x%0x Actual: smi_ndp: 0x%0x", this.smi_ndp, m_pkt.smi_ndp), UVM_NONE); 
            legal = 0;
        end
        if (<%=obj.BlockId + '_con'%>::WUSEACECACHE) begin
            if (this.arcache !== m_pkt.arcache) begin
                uvm_report_info(get_full_name(), $sformatf("ERROR Expected: arcache: 0x%0x Actual: arcache: 0x%0x", this.arcache, m_pkt.arcache), UVM_NONE); 
                legal = 0;
            end
        end
        if (<%=obj.BlockId + '_con'%>::WUSEACEPROT) begin
            if (this.arprot !== m_pkt.arprot) begin
                uvm_report_info(get_full_name(), $sformatf("ERROR Expected: arprot: 0x%0x Actual: arprot: 0x%0x", this.arprot, m_pkt.arprot), UVM_NONE); 
                legal = 0;
            end
        end
        if (<%=obj.BlockId + '_con'%>::WUSEACEQOS) begin
            if (this.arqos !== m_pkt.arqos) begin
                uvm_report_info(get_full_name(), $sformatf("ERROR Expected: arqos: 0x%0x Actual: arqos: 0x%0x", this.arqos, m_pkt.arqos), UVM_NONE); 
                legal = 0;
            end
        end
        if (<%=obj.BlockId + '_con'%>::WUSEACEREGION) begin
            if (this.arregion !== m_pkt.arregion) begin
                uvm_report_info(get_full_name(), $sformatf("ERROR Expected: arregion: 0x%0x Actual: arregion: 0x%0x", this.arregion, m_pkt.arregion), UVM_NONE); 
                legal = 0;
            end
        end
        if (<%=obj.BlockId + '_con'%>::WARUSER != 0) begin
            if (this.aruser !== m_pkt.aruser) begin
                uvm_report_info(get_full_name(), $sformatf("ERROR Expected: aruser: 0x%0x Actual: aruser: 0x%0x", this.aruser, m_pkt.aruser), UVM_NONE); 
                legal = 0;
            end
        end
        return legal;
    endfunction : do_compare_pkts

    function string sprint_pkt();
        
        if($test$plusargs("en_perf_trace")) begin
            sprint_pkt = $sformatf("ID=0x%0x Addr=0x%0x Len=0x%0x Size=0x%0x BurstType=0x%0x Prot=0x%0x Cache=0x%0x QoS=0x%0x TIME=%0t"
                               , arid, araddr, arlen, arsize, arburst, arprot, arcache, arqos, t_pkt_seen_on_intf);  
        end else begin
            sprint_pkt = $sformatf("READ AR: ID:0x%0x Addr:0x%0x Len:0x%0x Size:0x%0x BurstType:0x%0x Prot:0x%0x Time:%0t"
                               , arid, araddr, arlen, arsize, arburst, arprot, t_pkt_seen_on_intf);  
        end
       return sprint_pkt;
    endfunction : sprint_pkt

