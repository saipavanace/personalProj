////////////////////////////////////////////////////////////////////////////////
//
// Purpose      : Legato scoreboard
// Notes        : All RX and TX directions used below are w.r.t Legato instance
//
////////////////////////////////////////////////////////////////////////////////


<%
//Embedded javascript code to figure number of blocks
   var _ncore_blkid                  = [];
   var _legato_rx_blkid              = [];
   var _legato_rx_legato_unit_id     = [];
   var _legato_rx_legato_Nunit_id     = [];
   var _legato_rx_legato_unit_id_width = [];
   var _legato_rx_legato_port_id     = [];
   var _legato_rx_legato_fabric_id   = [];
   var _legato_tx_blkid              = [];
   var _legato_tx_legato_unit_id     = [];
   var _legato_tx_legato_Nunit_id     = [];
   var _legato_tx_legato_unit_id_width = [];
   var _legato_tx_legato_port_id     = [];
   var _legato_tx_legato_fabric_id   = [];
   var _legato_tx_ncore_phys_port_id = [];
   var _legato_tx_ncore_total_phys_port = [];
   var _legato_tx_ncore_same_phys_port = [];
   var pidx                          = 0;
   var qidx                          = 0;
   var idx                           = 0;
   var _ncore_blkid_idx              = 0;
   var _legato_rx_blkid_idx          = 0;
   var _legato_tx_blkid_idx          = 0;
   var _legato_wFPortId              = obj.Widths.Concerto.Ndp.Header.wFPortId;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
//          _ncore_blkid[_ncore_blkid_idx] = obj.AiuInfo[pidx].BlockId;'chiaiu' + idx;
           var tmp1=0;
           _ncore_blkid[_ncore_blkid_idx] = 'chiaiu' + idx;
           for (var tmp = 0; tmp < obj.AiuInfo[pidx].smiPortParams.tx.length; tmp++) {
               _legato_rx_blkid[_legato_rx_blkid_idx]            = 'chiaiu' + idx;
               _legato_rx_legato_unit_id[_legato_rx_blkid_idx]   = obj.AiuInfo[pidx].FUnitId;
               _legato_rx_legato_Nunit_id[_legato_rx_blkid_idx]   = obj.AiuInfo[pidx].NUnitId;
               _legato_rx_legato_unit_id_width[_legato_rx_blkid_idx]   = obj.AiuInfo[pidx].wFUnitId;
               _legato_rx_legato_port_id[_legato_rx_blkid_idx]   = obj.AiuInfo[pidx].smiPortParams.tx[tmp].params.fPortId[0];
               _legato_rx_legato_fabric_id[_legato_rx_blkid_idx] = obj.AiuInfo[pidx].FUnitId;
               _legato_rx_blkid_idx++;
           }
           for (var tmp = 0; tmp < obj.AiuInfo[pidx].smiPortParams.rx.length; tmp++) {
               _legato_tx_blkid[_legato_tx_blkid_idx]              = 'chiaiu' + idx;
               _legato_tx_legato_unit_id[_legato_tx_blkid_idx]     = obj.AiuInfo[pidx].FUnitId;
               _legato_tx_legato_Nunit_id[_legato_tx_blkid_idx]     = obj.AiuInfo[pidx].NUnitId;
               _legato_tx_legato_unit_id_width[_legato_tx_blkid_idx]     = obj.AiuInfo[pidx].wFUnitId;
               _legato_tx_legato_port_id[_legato_tx_blkid_idx]     = obj.AiuInfo[pidx].smiPortParams.rx[tmp].params.fPortId[0];
               _legato_tx_legato_fabric_id[_legato_tx_blkid_idx]   = obj.AiuInfo[pidx].FUnitId;
               //_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp;
		       if(obj.AiuInfo[pidx].smiPortParams.rx[tmp].params.fPortId[0] == "1'd1") {
                 _legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp-1;
		         tmp1=1;
		       } else {
		         if(tmp1 == 1) {_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp-1; tmp1=0;}
		         else {_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp;}
		       }
			   _legato_tx_ncore_total_phys_port[_legato_tx_blkid_idx] = obj.AiuInfo[pidx].smiPortParams.rx.length;
               _legato_tx_blkid_idx++;
           }
           idx++;
       } else {
           var tmp1=0;
           _ncore_blkid[_ncore_blkid_idx] = 'ioaiu' + qidx;
           for (var tmp = 0; tmp < obj.AiuInfo[pidx].smiPortParams.tx.length; tmp++) {
               _legato_rx_blkid[_legato_rx_blkid_idx]          	 = 'ioaiu' + qidx;
               _legato_rx_legato_unit_id[_legato_rx_blkid_idx]   = obj.AiuInfo[pidx].FUnitId;
               _legato_rx_legato_unit_id_width[_legato_rx_blkid_idx]   = obj.AiuInfo[pidx].wFUnitId;
               _legato_rx_legato_port_id[_legato_rx_blkid_idx]   = obj.AiuInfo[pidx].smiPortParams.tx[tmp].params.fPortId[0];
               _legato_rx_legato_fabric_id[_legato_rx_blkid_idx] = obj.AiuInfo[pidx].FUnitId;
               _legato_rx_blkid_idx++;
           }
           for (var tmp = 0; tmp < obj.AiuInfo[pidx].smiPortParams.rx.length; tmp++) {
               _legato_tx_blkid[_legato_tx_blkid_idx]              = 'ioaiu' + qidx;
               _legato_tx_legato_unit_id[_legato_tx_blkid_idx]     = obj.AiuInfo[pidx].FUnitId;
               _legato_tx_legato_unit_id_width[_legato_tx_blkid_idx]     = obj.AiuInfo[pidx].wFUnitId;
               _legato_tx_legato_port_id[_legato_tx_blkid_idx]     = obj.AiuInfo[pidx].smiPortParams.rx[tmp].params.fPortId[0];
               _legato_tx_legato_fabric_id[_legato_tx_blkid_idx]   = obj.AiuInfo[pidx].FUnitId;
               //_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp;
		       if(obj.AiuInfo[pidx].smiPortParams.rx[tmp].params.fPortId[0] == "1'd1") {
                 _legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp-1;
		         tmp1=1;
		       } else {
		         if(tmp1 == 1) {_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp-1; tmp1=0;}
		         else {_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp;}
		       }
			   _legato_tx_ncore_total_phys_port[_legato_tx_blkid_idx] = obj.AiuInfo[pidx].smiPortParams.rx.length;
               _legato_tx_blkid_idx++;
           }
	   qidx++;
       }
       _ncore_blkid_idx++;
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       var tmp1=0;
       _ncore_blkid[_ncore_blkid_idx] = 'dce' + pidx;
       for (var tmp = 0; tmp < obj.DceInfo[pidx].smiPortParams.tx.length; tmp++) {
           _legato_rx_blkid[_legato_rx_blkid_idx]          = 'dce' + pidx;
           _legato_rx_legato_unit_id[_legato_rx_blkid_idx]     = obj.DceInfo[pidx].FUnitId;
           _legato_rx_legato_unit_id_width[_legato_rx_blkid_idx]     = obj.DceInfo[pidx].wFUnitId;
           _legato_rx_legato_port_id[_legato_rx_blkid_idx]     = obj.DceInfo[pidx].smiPortParams.tx[tmp].params.fPortId[0];
           _legato_rx_legato_fabric_id[_legato_rx_blkid_idx] = obj.DceInfo[pidx].FUnitId;
           _legato_rx_blkid_idx++;
       }
       for (var tmp = 0; tmp < obj.DceInfo[pidx].smiPortParams.rx.length; tmp++) {
           _legato_tx_blkid[_legato_tx_blkid_idx]              = 'dce' + pidx;
           _legato_tx_legato_unit_id[_legato_tx_blkid_idx]     = obj.DceInfo[pidx].FUnitId;
           _legato_tx_legato_unit_id_width[_legato_tx_blkid_idx]     = obj.DceInfo[pidx].wFUnitId;
           _legato_tx_legato_port_id[_legato_tx_blkid_idx]     = obj.DceInfo[pidx].smiPortParams.rx[tmp].params.fPortId[0];
           _legato_tx_legato_fabric_id[_legato_tx_blkid_idx]   = obj.DceInfo[pidx].FUnitId;
           //_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp;
		   if(obj.DceInfo[pidx].smiPortParams.rx[tmp].params.fPortId[0] == "1'd1") {
             _legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp-1;
			 tmp1=1;
		   } else {
		     if(tmp1 == 1) {_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp-1; tmp1=0;}
		     else {_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp;}
		   }
		   _legato_tx_ncore_total_phys_port[_legato_tx_blkid_idx] = obj.DceInfo[pidx].smiPortParams.rx.length;
           _legato_tx_blkid_idx++;
       }
       _ncore_blkid_idx++;
   }
   for(pidx = 0; pidx < obj.nDMIs; pidx++) {
       var tmp1=0,tmp2=0;
       _ncore_blkid[_ncore_blkid_idx] = 'dmi' + pidx;
       for (var tmp = 0; tmp < obj.DmiInfo[pidx].smiPortParams.tx.length; tmp++) {
           _legato_rx_blkid[_legato_rx_blkid_idx]          = 'dmi' + pidx;
           _legato_rx_legato_unit_id[_legato_rx_blkid_idx]     = obj.DmiInfo[pidx].FUnitId;
           _legato_rx_legato_unit_id_width[_legato_rx_blkid_idx]     = obj.DmiInfo[pidx].wFUnitId;
           _legato_rx_legato_port_id[_legato_rx_blkid_idx]     = obj.DmiInfo[pidx].smiPortParams.tx[tmp].params.fPortId[0];
           _legato_rx_legato_fabric_id[_legato_rx_blkid_idx] = obj.DmiInfo[pidx].FUnitId;
           _legato_rx_blkid_idx++;
       }
       for (var tmp = 0; tmp < obj.DmiInfo[pidx].smiPortParams.rx.length; tmp++) {
           _legato_tx_blkid[_legato_tx_blkid_idx]              = 'dmi' + pidx;
           _legato_tx_legato_unit_id[_legato_tx_blkid_idx]     = obj.DmiInfo[pidx].FUnitId;
           _legato_tx_legato_unit_id_width[_legato_tx_blkid_idx]     = obj.DmiInfo[pidx].wFUnitId;
           _legato_tx_legato_port_id[_legato_tx_blkid_idx]     = obj.DmiInfo[pidx].smiPortParams.rx[tmp].params.fPortId[0];
           _legato_tx_legato_fabric_id[_legato_tx_blkid_idx]   = obj.DmiInfo[pidx].FUnitId;
           //_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp;
		   if(obj.DmiInfo[pidx].smiPortParams.rx[tmp].params.fPortId[0] == "1'd1") {
             _legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp-1;
			 tmp1=1;
		   } else {
		     if(tmp1 == 1) {_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp-1; 
			 tmp1=0;}
		     else {_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp;}
		   }
		   if(_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] == tmp-1) {_legato_tx_ncore_total_phys_port[_legato_tx_blkid_idx - tmp] = obj.DmiInfo[pidx].smiPortParams.rx.length - 1;
		   _legato_tx_ncore_total_phys_port[_legato_tx_blkid_idx] = obj.DmiInfo[pidx].smiPortParams.rx.length - 1;}
		   else _legato_tx_ncore_total_phys_port[_legato_tx_blkid_idx] = obj.DmiInfo[pidx].smiPortParams.rx.length;
           _legato_tx_blkid_idx++;
       }
       _ncore_blkid_idx++;
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       var tmp1=0;
       _ncore_blkid[_ncore_blkid_idx] = 'dii' + pidx;
       for (var tmp = 0; tmp < obj.DiiInfo[pidx].smiPortParams.tx.length; tmp++) {
           _legato_rx_blkid[_legato_rx_blkid_idx]          = 'dii' + pidx;
           _legato_rx_legato_unit_id[_legato_rx_blkid_idx]     = obj.DiiInfo[pidx].FUnitId;
           _legato_rx_legato_unit_id_width[_legato_rx_blkid_idx]     = obj.DiiInfo[pidx].wFUnitId;
           _legato_rx_legato_port_id[_legato_rx_blkid_idx]     = obj.DiiInfo[pidx].smiPortParams.tx[tmp].params.fPortId[0];
           _legato_rx_legato_fabric_id[_legato_rx_blkid_idx] = obj.DiiInfo[pidx].FUnitId;
           _legato_rx_blkid_idx++;
       }
       for (var tmp = 0; tmp < obj.DiiInfo[pidx].smiPortParams.rx.length; tmp++) {
           _legato_tx_blkid[_legato_tx_blkid_idx]              = 'dii' + pidx;
           _legato_tx_legato_unit_id[_legato_tx_blkid_idx]     = obj.DiiInfo[pidx].FUnitId;
           _legato_tx_legato_unit_id_width[_legato_tx_blkid_idx]     = obj.DiiInfo[pidx].wFUnitId;
           _legato_tx_legato_port_id[_legato_tx_blkid_idx]     = obj.DiiInfo[pidx].smiPortParams.rx[tmp].params.fPortId[0];
           _legato_tx_legato_fabric_id[_legato_tx_blkid_idx]   = obj.DiiInfo[pidx].FUnitId;
           _legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp;
		   if(obj.DiiInfo[pidx].smiPortParams.rx[tmp].params.fPortId[0] == "1'd1") {
             _legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp-1;
		     tmp1=1;
		   } else {
		     if(tmp1 == 1) {_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp-1; tmp1=0;}
		     else {_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp;}
		   }
		   _legato_tx_ncore_total_phys_port[_legato_tx_blkid_idx] = obj.DiiInfo[pidx].smiPortParams.rx.length;
           _legato_tx_blkid_idx++;
       }
       _ncore_blkid_idx++;
   }

   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       var tmp1;
       _ncore_blkid[_ncore_blkid_idx] = 'dve' + pidx;
       for (var tmp = 0; tmp < obj.DveInfo[pidx].smiPortParams.tx.length; tmp++) {
           _legato_rx_blkid[_legato_rx_blkid_idx]                = 'dve' + pidx;
           _legato_rx_legato_unit_id[_legato_rx_blkid_idx]       = obj.DveInfo[pidx].FUnitId;
           _legato_rx_legato_unit_id_width[_legato_rx_blkid_idx] = obj.DveInfo[pidx].wFUnitId;
           _legato_rx_legato_port_id[_legato_rx_blkid_idx]       = obj.DveInfo[pidx].smiPortParams.tx[tmp].params.fPortId[0];
           _legato_rx_legato_fabric_id[_legato_rx_blkid_idx]     = obj.DveInfo[pidx].FUnitId;
           _legato_rx_blkid_idx++;
       }
       for (var tmp = 0; tmp < obj.DveInfo[pidx].smiPortParams.rx.length; tmp++) {
           _legato_tx_blkid[_legato_tx_blkid_idx] = 'dve' + pidx;
           _legato_tx_legato_unit_id[_legato_tx_blkid_idx]     = obj.DveInfo[pidx].FUnitId;
           _legato_tx_legato_port_id[_legato_tx_blkid_idx]     = obj.DveInfo[pidx].smiPortParams.rx[tmp].params.fPortId[0];
           _legato_tx_legato_fabric_id[_legato_tx_blkid_idx]   = obj.DveInfo[pidx].FUnitId;
           //_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp;
		    if(obj.DveInfo[pidx].smiPortParams.rx[tmp].params.fPortId[0] == "1'd1") {
             _legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp-1;
			 tmp1=1;
		   } else {
		     if(tmp1 == 1) {_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp-1; tmp1=0;}
		     else {_legato_tx_ncore_phys_port_id[_legato_tx_blkid_idx] = tmp;}
		   }
		   _legato_tx_ncore_total_phys_port[_legato_tx_blkid_idx] = obj.DveInfo[pidx].smiPortParams.rx.length;
           _legato_tx_blkid_idx++;
       }
       _ncore_blkid_idx++;
   }
   //console.log(_ncore_blkid);
   //console.log(_legato_tx_blkid);
   //console.log(_legato_rx_blkid);
%>

/*
Below class is just a container for all types of smi_seq_item
*/
class legato_scb_txn;
    bit         smi_msg_valid;
    bit         smi_msg_ready;
    bit [63:0]  smi_steer;
    bit [63:0]  smi_targ_id;
	bit [6:0]   smi_targ_ncore_unit_id;
	bit [0:0]   smi_targ_ncore_port_id;
    bit [63:0]  smi_src_id;
    bit [63:0]  smi_msg_tier;
    bit [63:0]  smi_msg_qos;
    bit [63:0]  smi_msg_pri;
    bit [63:0]  smi_msg_type;
    bit [63:0]  smi_ndp_len; 
    bit         smi_ndp[];
    bit         smi_dp_present; 
    bit [63:0]  smi_msg_id;
    bit [63:0]  smi_msg_user;
    bit [63:0]  smi_msg_err;
    bit         smi_dp_valid;
    bit         smi_dp_ready;
    bit         smi_dp_last;
    bit         smi_dp_data[];
    bit         smi_dp_user[];
    bit [63:0]  smi_fabric_id;

    <% for (var tmp = 0; tmp < _ncore_blkid.length; tmp++) { %>
        function void copy_to_me_<%=_ncore_blkid[tmp]%> (const ref <%=_ncore_blkid[tmp]%>_smi_agent_pkg::smi_seq_item m_item, input bit [63:0] m_fabric_id);
            this.smi_msg_valid          = m_item.smi_msg_valid;
            this.smi_msg_ready          = m_item.smi_msg_ready;
            this.smi_steer              = m_item.smi_steer;
            this.smi_targ_id            = m_item.smi_targ_id;
            this.smi_targ_ncore_unit_id = m_item.smi_targ_ncore_unit_id;
            this.smi_targ_ncore_port_id = m_item.smi_targ_ncore_port_id;
            this.smi_src_id             = m_item.smi_src_id;
            this.smi_msg_tier           = m_item.smi_msg_tier;
            this.smi_msg_qos            = m_item.smi_msg_qos;
            this.smi_msg_pri            = m_item.smi_msg_pri;
            this.smi_msg_type           = m_item.smi_msg_type;
            this.smi_ndp_len            = m_item.smi_ndp_len;
            this.smi_dp_present         = m_item.smi_dp_present;
            this.smi_msg_id             = m_item.smi_msg_id;
            this.smi_msg_user           = m_item.smi_msg_user;
            this.smi_msg_err            = m_item.smi_msg_err;
            this.smi_dp_valid           = m_item.smi_dp_valid;
            this.smi_dp_ready           = m_item.smi_dp_ready;
            this.smi_dp_last            = m_item.smi_dp_last;
            this.smi_ndp                = { >> {m_item.smi_ndp}};
            this.smi_dp_data            = { << <%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPdata{m_item.smi_dp_data}};
            this.smi_dp_user            = { << <%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser{m_item.smi_dp_user}};
            this.smi_fabric_id          = m_fabric_id;
            `uvm_info("CG DEBUG copy to me_<%=_ncore_blkid[tmp]%>", $sformatf("Input SMI Txn: %p", m_item), UVM_HIGH)
            `uvm_info("CG DEBUG copy to me_<%=_ncore_blkid[tmp]%>", $sformatf("Legato SCB Txn: %p", this), UVM_HIGH)
        endfunction : copy_to_me_<%=_ncore_blkid[tmp]%>

        function void copy_from_me_<%=_ncore_blkid[tmp]%> (ref <%=_ncore_blkid[tmp]%>_smi_agent_pkg::smi_seq_item m_item,input bit packing,input bit single_beat,input int user_width,input int data_width,input bit multi_beat,input bit padding,input int data_beats,input int user_beats);
            m_item.smi_msg_valid  = this.smi_msg_valid;
            m_item.smi_msg_ready  = this.smi_msg_ready;
            m_item.smi_steer      = this.smi_steer;
            m_item.smi_targ_id    = this.smi_targ_id;
            m_item.smi_targ_ncore_unit_id = this.smi_targ_ncore_unit_id;
            m_item.smi_targ_ncore_port_id = this.smi_targ_ncore_port_id;
            m_item.smi_src_id     = this.smi_src_id;
            m_item.smi_msg_tier   = this.smi_msg_tier;
            m_item.smi_msg_qos    = this.smi_msg_qos;
            m_item.smi_msg_pri    = this.smi_msg_pri;
            m_item.smi_msg_type   = this.smi_msg_type;
            m_item.smi_ndp_len    = this.smi_ndp_len;
            m_item.smi_dp_present = this.smi_dp_present;
            m_item.smi_msg_id     = this.smi_msg_id;
            m_item.smi_msg_user   = this.smi_msg_user;
            m_item.smi_msg_err    = this.smi_msg_err;
            m_item.smi_dp_valid   = this.smi_dp_valid;
            m_item.smi_dp_ready   = this.smi_dp_ready;
            m_item.smi_dp_last    = this.smi_dp_last;
            m_item.smi_ndp        = { >> <%=_ncore_blkid[tmp]%>_smi_agent_pkg::WSMINDP{this.smi_ndp}};
            `ifndef VCS // To-Do : CONC-11829
            m_item.smi_dp_data    = packing ? (single_beat) ? (<%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPdata/2 == 64) ? { << 64{this.smi_dp_data}} :
			                                                  (<%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPdata/2 == 128 && data_width == 128) ? { << 128{this.smi_dp_data}} :
															  (<%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPdata/4 == 64  && data_width ==  64) ? { << 64{this.smi_dp_data}}  :
															  { << <%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPdata{this.smi_dp_data}} :
					                             multi_beat ? { << <%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPdata{this.smi_dp_data}} :
								                    padding ? { << <%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPdata{this.smi_dp_data}} :
												              { >> <%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPdata{this.smi_dp_data}} :
															  { << <%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPdata{this.smi_dp_data}};
            m_item.smi_dp_user    = packing ? (single_beat) ? (<%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser/2 == 12) ? { << 12{this.smi_dp_user}} : 
			                                                  (<%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser/2 == 13) ? { << 13{this.smi_dp_user}} : 
			                                                  (<%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser/2 == 20) ? { << 20{this.smi_dp_user}} : 
															  (<%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser/2 == 24 && user_width == 24) ? { << 24{this.smi_dp_user}} :
															  (<%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser/2 == 26 && user_width == 26) ? { << 26{this.smi_dp_user}} :
															  (<%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser/2 == 40 && user_width == 40) ? { << 40{this.smi_dp_user}} :
															  (<%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser/4 == 12 && user_width == 12) ? { << 12{this.smi_dp_user}} :
															  (<%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser/4 == 13 && user_width == 13) ? { << 13{this.smi_dp_user}} :
															  (<%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser/4 == 20 && user_width == 20) ? { << 20{this.smi_dp_user}} :
															  { << <%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser{this.smi_dp_user}} :
									             multi_beat ? { << <%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser{this.smi_dp_user}} :
												    padding ? { << <%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser{this.smi_dp_user}} :
															  { >> <%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser{this.smi_dp_user}} :
															  { << <%=_ncore_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser{this.smi_dp_user}};
           `endif                                                                                                                          
            m_item.unpack_smi_seq_item();
            m_item.unpack_dp_smi_seq_item();
            `uvm_info("CG DEBUG copy from me_<%=_ncore_blkid[tmp]%>", $sformatf("Legato SCB Txn: %p", this), UVM_HIGH)
            `uvm_info("CG DEBUG copy from me_<%=_ncore_blkid[tmp]%>", $sformatf("Output SMI Txn: %p", m_item), UVM_HIGH)
        endfunction : copy_from_me_<%=_ncore_blkid[tmp]%>
    <% } %>
    
endclass : legato_scb_txn

<% for (var tmp = 0; tmp < _legato_rx_blkid.length; tmp++) { %>
    `uvm_analysis_imp_decl (_rx_<%=tmp%>_<%=_legato_rx_blkid[tmp]%>_port)
<% } %>
<% for (var tmp = 0; tmp < _legato_tx_blkid.length; tmp++) { %>
    `uvm_analysis_imp_decl (_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_port)
<% } %>
class legato_scb extends uvm_scoreboard;
    `uvm_component_utils(legato_scb)

    <% for (var tmp = 0; tmp < _legato_rx_blkid.length; tmp++) { %>
        uvm_analysis_imp_rx_<%=tmp%>_<%=_legato_rx_blkid[tmp]%>_port #(<%=_legato_rx_blkid[tmp]%>_smi_agent_pkg::smi_seq_item, legato_scb) m_rx_<%=tmp%>_<%=_legato_rx_blkid[tmp]%>_port; 
    <% } %>
    <% for (var tmp = 0; tmp < _legato_tx_blkid.length; tmp++) { %>
        uvm_analysis_imp_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_port #(<%=_legato_tx_blkid[tmp]%>_smi_agent_pkg::smi_seq_item, legato_scb) m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_port; 
    <% } %>

    <% for (var tmp = 0; tmp < _legato_tx_blkid.length; tmp++) { %>
        <%=_legato_tx_blkid[tmp]%>_smi_agent_pkg::smi_seq_item m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[$];
    <% } %>
    function new(string name = "legato_scb", uvm_component parent = null); 
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        <% for (var tmp = 0; tmp < _legato_rx_blkid.length; tmp++) { %>
            m_rx_<%=tmp%>_<%=_legato_rx_blkid[tmp]%>_port = new ("m_rx_<%=tmp%>_<%=_legato_rx_blkid[tmp]%>_port", this); 
        <% } %>
        <% for (var tmp = 0; tmp < _legato_tx_blkid.length; tmp++) { %>
            m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_port = new ("m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_port", this); 
        <% } %>
    endfunction : build_phase

    function void print_pending_txn();
        <% for (var tmp = 0; tmp < _legato_tx_blkid.length; tmp++) { %>
            `uvm_info("Legato Scoreboard", "Printing type <%=_legato_tx_blkid[tmp]%> of TX queue number <%=tmp%> Fabric ID <%=_legato_tx_legato_fabric_id[tmp]%>", UVM_HIGH)
            foreach (m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[i]) begin
                `uvm_info("Legato Scoreboard", m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[i].convert2string(), UVM_HIGH)
            end
        <% } %>
    endfunction : print_pending_txn

    <% for (var tmp = 0; tmp < _legato_rx_blkid.length; tmp++) { %>
        function void write_rx_<%=tmp%>_<%=_legato_rx_blkid[tmp]%>_port (const ref <%=_legato_rx_blkid[tmp]%>_smi_agent_pkg::smi_seq_item m_item);
            <%=_legato_rx_blkid[tmp]%>_smi_agent_pkg::smi_seq_item m_tmp_item;
			bit [3:0] phy_port;
			int data_width,size_of_dp_data,user_width,legato_rx_ports;
			bit single_beat,multi_beat_at_init;
            legato_scb_txn                                         m_legato_scb_txn = new();

	    if(m_item.smi_src_id !==  {<%=_legato_rx_legato_unit_id_width[tmp]%>'d<%=_legato_rx_legato_unit_id[tmp]%>,<%=_legato_rx_legato_port_id[tmp]%>} )
		`uvm_error(get_full_name(), $sformatf("On Unit <%=_legato_tx_blkid[tmp]%> port <%=_legato_tx_ncore_phys_port_id[tmp]%> smi_src_id mismatched: expected %x, actual %x", 
				{<%=_legato_rx_legato_unit_id_width[tmp]%>'d<%=_legato_rx_legato_unit_id[tmp]%>,<%=_legato_rx_legato_port_id[tmp]%>}, m_item.smi_src_id))


            m_tmp_item = new();
            m_tmp_item.copy(m_item);
            m_legato_scb_txn.copy_to_me_<%=_legato_rx_blkid[tmp]%>(m_tmp_item, <%=_legato_rx_legato_fabric_id[tmp]%>);
			phy_port=<%=_legato_tx_ncore_phys_port_id[tmp]%>;
            legato_rx_ports=<%=_legato_tx_ncore_total_phys_port[tmp]%>;
			data_width=<%=_legato_rx_blkid[tmp]%>_smi_agent_pkg::wSmiDPdata;
			user_width=<%=_legato_rx_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser;
            size_of_dp_data=m_legato_scb_txn.smi_dp_data.size();
			if(size_of_dp_data==data_width) single_beat=1;
			if(size_of_dp_data > data_width) multi_beat_at_init=1;
			`uvm_info(get_name,$psprintf("DEBUG RX_PORT:: dp_present = %0d for port_id = %0d legato_rx_ports=%0d multi_beat_at_init=%0d",m_legato_scb_txn.smi_dp_present,phy_port,legato_rx_ports,multi_beat_at_init),UVM_HIGH)
			`uvm_info(get_name,$psprintf("DEBUG RX_PORT:: SMI_PACKET sent from port=%0d by block=<%=_legato_rx_blkid[tmp]%> with instance_id=<%=tmp%>",phy_port),UVM_HIGH)
            push_into_queue(m_legato_scb_txn,phy_port,data_width,single_beat,user_width,legato_rx_ports,multi_beat_at_init);
        endfunction :  write_rx_<%=tmp%>_<%=_legato_rx_blkid[tmp]%>_port
    <% } %>

    function void push_into_queue(const ref legato_scb_txn m_legato_scb_txn,bit [3:0] port,int dw,bit single_beat,int uw,int legato_rx_ports,bit multi_beat_at_init); 
		bit [3:0] target_tx_port;
		if(m_legato_scb_txn.smi_dp_present) begin
          case (m_legato_scb_txn.smi_targ_id)
            <% for (var tmp = 0; tmp < _legato_tx_blkid.length; tmp++) { %>
			    {<%=_legato_tx_legato_unit_id_width[tmp]%>'d<%=_legato_tx_legato_unit_id[tmp]%>,<%=_legato_tx_legato_port_id[tmp]%>}: begin
	               int legato_tx_ports[];
				   if (<%=_legato_tx_ncore_total_phys_port[tmp]%> > legato_rx_ports) target_tx_port = port+1;
				   else if (legato_rx_ports > <%=_legato_tx_ncore_total_phys_port[tmp]%>) target_tx_port = port-1;
                   else target_tx_port=port;
				   `uvm_info(get_name,$psprintf("DEBUG RX_PORT:: for Instance <%=tmp%> legato_tx_ports=%0d target_tx_port=%0d",legato_tx_ports[<%=tmp%>],target_tx_port),UVM_HIGH)
				end
            <% } %>
		  endcase
		end else begin
		target_tx_port=port;
		end
        unique case ({m_legato_scb_txn.smi_targ_id,target_tx_port})
            <% for (var tmp = 0; tmp < _legato_tx_blkid.length; tmp++) { %>
                {<%=_legato_tx_legato_unit_id_width[tmp]%>'d<%=_legato_tx_legato_unit_id[tmp]%>,<%=_legato_tx_legato_port_id[tmp]%>,4'd<%=_legato_tx_ncore_phys_port_id[tmp]%>}: begin
                    <%=_legato_tx_blkid[tmp]%>_smi_agent_pkg::smi_seq_item m_smi_seq_item = new();
		            int width_of_data,width_of_user,user_padding,size_of_data,size_of_user,no_of_data_beats,no_of_user_beats;
		            bit r_packing,multi_beat_at_targ,padding_required;
                    width_of_data = <%=_legato_tx_blkid[tmp]%>_smi_agent_pkg::wSmiDPdata;
                    width_of_user = <%=_legato_tx_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser;
					size_of_data  = m_legato_scb_txn.smi_dp_data.size();
					size_of_user  = m_legato_scb_txn.smi_dp_user.size();
					no_of_data_beats = size_of_data/dw;
					no_of_user_beats = size_of_user/uw; 
					if(size_of_data>width_of_data) multi_beat_at_targ=1;
					if(size_of_data<width_of_data && multi_beat_at_init) padding_required = 1;
					if(width_of_data>dw) r_packing=1; 
					if((single_beat || padding_required) && r_packing) begin
	                  bit [<%=_legato_tx_blkid[tmp]%>_smi_agent_pkg::wSmiDPdata-1:0] data_array;
		              bit [<%=_legato_tx_blkid[tmp]%>_smi_agent_pkg::wSmiDPuser-1:0] user_array;
					  data_array = { >>{m_legato_scb_txn.smi_dp_data}};
					  user_array = { >>{m_legato_scb_txn.smi_dp_user}};
					  if(padding_required) begin 
					    data_array = { <<{m_legato_scb_txn.smi_dp_data}};
					    user_array = { <<{m_legato_scb_txn.smi_dp_user}};
					  end
`ifndef VCS // To-Do : CONC-11829                                          
                      m_legato_scb_txn.smi_dp_data = { >>{data_array}};
                      m_legato_scb_txn.smi_dp_user = { >>{user_array}};
					  if(padding_required) begin 
                        m_legato_scb_txn.smi_dp_data = { <<{data_array}};
                        m_legato_scb_txn.smi_dp_user = { <<{user_array}};
					  end
`endif                                        
					end
                    m_legato_scb_txn.copy_from_me_<%=_legato_tx_blkid[tmp]%>(m_smi_seq_item,r_packing,single_beat,uw,dw,multi_beat_at_targ,padding_required,no_of_data_beats,no_of_user_beats);
                    m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q.push_back(m_smi_seq_item);
		            `uvm_info(get_name,$psprintf("DEBUG RX_PORT:: SMI_PACKET pushed in queue of block=<%=_legato_tx_blkid[tmp]%> with port_id=%0d && PHY_PORT <%=_legato_tx_ncore_phys_port_id[tmp]%> && instance_id=<%=tmp%>",port),UVM_HIGH)
                end
            <% } %>
                default: begin
                    `uvm_error ("Legato Scoreboard", $sformatf ("No matching targ_id and fabric_id for packet with targ_id 0x%0x fabric_id 0x%0x Packet %p", m_legato_scb_txn.smi_targ_id, m_legato_scb_txn.smi_fabric_id, m_legato_scb_txn))
                end
        endcase
    endfunction : push_into_queue

    <% for (var tmp = 0; tmp < _legato_tx_blkid.length; tmp++) { %>
        function void write_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_port (const ref <%=_legato_tx_blkid[tmp]%>_smi_agent_pkg::smi_seq_item m_item);
            int m_tmp_q[$],match=0;
			`uvm_info(get_name,$psprintf("DEBUG TX_PORT:: SMI_PACKET received at port=%0x for block=<%=_legato_tx_blkid[tmp]%> with instance_id=<%=tmp%>",<%=_legato_tx_ncore_phys_port_id[tmp]%>),UVM_HIGH)
            m_tmp_q = m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q.find_first_index with (item.smi_src_id == m_item.smi_src_id);
            if (m_tmp_q.size == 0) begin
                print_pending_txn();
                `uvm_error("Legato Scoreboard", $sformatf("On Unit <%=_legato_tx_blkid[tmp]%> port <%=_legato_tx_ncore_phys_port_id[tmp]%> fabric ID <%=_legato_tx_legato_fabric_id[tmp]%>, Legato sent packet %s, but there was no match for smi_src_id 0x%0x in expected queue", m_item.convert2string(), m_item.smi_src_id))
            end
            if (!m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].compare(m_item)) begin
			    if(m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].smi_dp_data != m_item.smi_dp_data && m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].smi_dp_user != m_item.smi_dp_user) begin
     		    `uvm_info("Legato Scoreboard", $sformatf("DP_DATA_DEBUG :: Expected smi_dp_data=%p Actual_dp_data=%p Expected smi_dp_data_size=%0d Actual smi_dp_data_size=%0d",m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].smi_dp_data,m_item.smi_dp_data,m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].smi_dp_data.size(),m_item.smi_dp_data.size()),UVM_HIGH)
     		    `uvm_info("Legato Scoreboard", $sformatf("DP_USER_DEBUG :: Expected smi_dp_user=%p Actual_dp_user=%p Expected smi_dp_user_size=%0d Actual smi_dp_user_size=%0d",m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].smi_dp_user,m_item.smi_dp_user,m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].smi_dp_user.size(),m_item.smi_dp_user.size()),UVM_HIGH)
				   foreach(m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].smi_dp_data[i]) begin
     			       if (m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].smi_dp_data[i] == m_item.smi_dp_data[i] && m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].smi_dp_user[i] == m_item.smi_dp_user[i]) begin
     			   		`uvm_info("Legato Scoreboard", $sformatf("PACKET DP DATA MATCH and USER MATCH:: Expected smi_dp_data=%p Actual smi_dp_data=%p and Expected smi_dp_user=%p Actual smi_dp_user=%p",m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].smi_dp_data[i],m_item.smi_dp_data[i],m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].smi_dp_user[i],m_item.smi_dp_user[i]),UVM_HIGH)
			            `uvm_info("Legato_scoreboard",$sformatf("Packet Matched  for block = <%=_legato_tx_blkid[tmp]%>"),UVM_HIGH)
						match=1;
     			       end else
     			   		`uvm_error("Legato Scoreboard", $sformatf("PACKET DP DATA MATCH and USER MISMATCH:: Expected smi_dp_data=%p Actual smi_dp_data=%p and Expected smi_dp_user=%p Actual smi_dp_user=%p",m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].smi_dp_data[i],m_item.smi_dp_data[i],m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].smi_dp_user[i],m_item.smi_dp_user[i]))
				   end
				   if (match) begin m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q.delete(m_tmp_q[0]); match=0; end 
				end else begin 
                print_pending_txn();
                `uvm_error("Legato Scoreboard", $sformatf("PACKET MISMATCH :: On Unit <%=_legato_tx_blkid[tmp]%> port <%=_legato_tx_ncore_phys_port_id[tmp]%> fabric ID <%=_legato_tx_legato_fabric_id[tmp]%>, Legato sent packet %s, but it did not match packet %s in expected queue", m_item.convert2string(), m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q[m_tmp_q[0]].convert2string()))
				end
            end
            else begin
			    `uvm_info("Legato_scoreboard",$sformatf("Packet Matched  for block = <%=_legato_tx_blkid[tmp]%>"),UVM_HIGH)
                m_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_fabric<%=_legato_tx_legato_fabric_id[tmp]%>_q.delete(m_tmp_q[0]);
            end
        endfunction :  write_tx_<%=tmp%>_<%=_legato_tx_blkid[tmp]%>_port
    <% } %>


endclass : legato_scb
