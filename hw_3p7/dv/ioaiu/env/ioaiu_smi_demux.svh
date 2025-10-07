<% var aiu;
if((obj.testBench === "fsys") || (obj.testBench === "emu_t") || (obj.testBench === "emu")){
    aiu = obj.AiuInfo[obj.Id];
} else {
    aiu = obj.DutInfo;
}%>


class ioaiu_smi_demux extends uvm_component;
   `uvm_component_param_utils(ioaiu_smi_demux)
    uvm_analysis_imp_ioaiu_smi_every_beat_port #(smi_seq_item, ioaiu_smi_demux) ioaiu_smi_every_beat_port;
    uvm_analysis_imp_ioaiu_smi_port #(smi_seq_item, ioaiu_smi_demux) ioaiu_smi_port; 
    uvm_analysis_port #(smi_seq_item) m_smi_scb_ap[<%=aiu.nNativeInterfacePorts%>];
    uvm_analysis_port #(smi_seq_item) m_smi_every_beat_scb_ap[<%=aiu.nNativeInterfacePorts%>];

    function new (string name="ioaiu_smi_demux", uvm_component parent=null);
        super.new (name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ioaiu_smi_port = new("ioaiu_smi_port", this);
        ioaiu_smi_every_beat_port= new("ioaiu_smi_every_beat_port", this);

        <%for(let i=0; i<aiu.nNativeInterfacePorts; i++) {%>
            m_smi_scb_ap[<%=i%>] = new("m_smi_scb_ap[<%=i%>]", this);
            m_smi_every_beat_scb_ap[<%=i%>] = new("m_smi_every_beat_scb_ap[<%=i%>]", this);
        <%}%>
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
    endfunction : start_of_simulation_phase

    function void report_phase(uvm_phase phase);
    endfunction

     function void write_ioaiu_smi_every_beat_port(smi_seq_item m_pkt);
      	smi_seq_item this_packet;
        int core=0;
        this_packet = smi_seq_item::type_id::create();
      	this_packet.copy(m_pkt);
        if(this_packet.isSysReqMsg() || this_packet.isSysRspMsg()) begin
            m_smi_every_beat_scb_ap[0].write(this_packet);
            return;
        end
        if(this_packet.isSnpMsg()) begin
            if(m_pkt.smi_msg_type == SNP_DVM_MSG) begin
                m_smi_every_beat_scb_ap[0].write(this_packet);
	            return;
            end
            <%if(aiu.nNativeInterfacePorts === 1){%>
                m_smi_every_beat_scb_ap[0].write(this_packet);
	            return;
            <%}%>
            <%if(aiu===undefined || aiu.aNcaiuIntvFunc===undefined || aiu.aNcaiuIntvFunc.aPrimaryBits===undefined ||!aiu.aNcaiuIntvFunc.aPrimaryBits.length){}else{%>
                <%for(var i=0; i<aiu.aNcaiuIntvFunc.aPrimaryBits.length; i++){%>
                    core[<%=i%>] = this_packet.smi_addr[<%=aiu.aNcaiuIntvFunc.aPrimaryBits[i]%>];
                <%}%>
                m_smi_every_beat_scb_ap[core].write(this_packet);
            <%}%>
            return;
        end
        <%if(aiu.nNativeInterfacePorts !== 1) {%>
            if(decodeUsingMsgId(this_packet)) begin
                core = int'(this_packet.smi_msg_id[ WSMIMSGID-1 : WSMIMSGID-$clog2(<%=aiu.nNativeInterfacePorts%>)]);
            end else begin
                core = int'(this_packet.smi_rmsg_id[ WSMIMSGID-1 : WSMIMSGID-$clog2(<%=aiu.nNativeInterfacePorts%>)]);
            end
        <%}%>
        m_smi_every_beat_scb_ap[core].write(this_packet);

      endfunction :write_ioaiu_smi_every_beat_port


    function void write_ioaiu_smi_port(smi_seq_item m_pkt);
    	smi_seq_item this_packet;
        int core=0;
        this_packet = smi_seq_item::type_id::create();
      	this_packet.copy(m_pkt);
        if(this_packet.isSysReqMsg() || this_packet.isSysRspMsg()) begin
            m_smi_scb_ap[0].write(this_packet);
            return;
        end
        if(this_packet.isSnpMsg()) begin
            if(m_pkt.smi_msg_type == SNP_DVM_MSG) begin
                m_smi_scb_ap[0].write(this_packet);
	            return;
            end
            <%if(aiu.nNativeInterfacePorts === 1){%>
                m_smi_scb_ap[0].write(this_packet);
	            return;
            <%}%>
            <%if(aiu===undefined || aiu.aNcaiuIntvFunc===undefined || aiu.aNcaiuIntvFunc.aPrimaryBits===undefined ||!aiu.aNcaiuIntvFunc.aPrimaryBits.length){}else{%>
                <%for(var i=0; i<aiu.aNcaiuIntvFunc.aPrimaryBits.length; i++){%>
                    core[<%=i%>] = this_packet.smi_addr[<%=aiu.aNcaiuIntvFunc.aPrimaryBits[i]%>];
                <%}%>
                m_smi_scb_ap[core].write(this_packet);
            <%}%>
            return;
        end
        <%if(aiu.nNativeInterfacePorts !== 1) {%>
            if(decodeUsingMsgId(this_packet)) begin
                core = int'(this_packet.smi_msg_id[ WSMIMSGID-1 : WSMIMSGID-$clog2(<%=aiu.nNativeInterfacePorts%>)]);
            end else begin
                core = int'(this_packet.smi_rmsg_id[ WSMIMSGID-1 : WSMIMSGID-$clog2(<%=aiu.nNativeInterfacePorts%>)]);
            end
        <%}%>
        m_smi_scb_ap[core].write(this_packet);
    endfunction : write_ioaiu_smi_port

    function bit decodeUsingMsgId(smi_seq_item pkt);
       	if( pkt.isCmdMsg() || 
            (pkt.isDtrMsg() && !pkt.smi_transmitter ) ||
            pkt.isDtwMsg() ||
            (pkt.isDtrRspMsg() && !pkt.smi_transmitter ) ||
            pkt.isStrRspMsg() ||
            pkt.isSnpRspMsg() ||
            pkt.isUpdMsg()
        ) begin
            return 1;
        end
        return 0;
    endfunction : decodeUsingMsgId
    
endclass
