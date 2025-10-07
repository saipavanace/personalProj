
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var nGPRA = 0;
   var chiaiu_idx = 0;
   var ioaiu_idx  = 0;
   var aceaiu_idx = 0;
   var has_chib  = 0;
   var has_chia  = 0;
   var has_chie  = 0;
   var has_ace  = 0;
   var nACE = 0;
   var nCHI = 0;


   for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
       _child_blk[pidx]   = 'chiaiu';
       chiaiu_idx++;
       if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') {
        has_chia  = 1;
       }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B') {
        has_chib  = 1;
       }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') {
        has_chie  = 1;
       }
       } else {
       _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
       _child_blk[pidx]   = 'ioaiu';
       ioaiu_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
       }
       if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE')){
         aceaiu_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
         has_ace  = 1 ;
       } 

   } 

   nGPRA = obj.AiuInfo[0].nGPRA;
   nACE = aceaiu_idx;
   nCHI = chiaiu_idx;

%>
    time  		latency_new[int][int][string],min_latency,max_latency,seq_begin_time1;
    //time  		latency_new[int][string],min_latency,max_latency,seq_begin_time1;
    int addr_grp[int];
	bit[7:0] dat_que[bit[<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]];
  //number of GPRA = <%=nGPRA%>
<%var qidx=0%>
class ncore_init_boot_seq<%=qidx%> extends uvm_reg_sequence;

  uvm_event reg_init_done = uvm_event_pool::get_global("reg_init_done");

  // Addr domain queue
  addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t csrq[$];
  

  function new(string name="ncore_init_boot_seq<%=qidx%>");
    super.new(name);
  endfunction : new

  `uvm_object_utils(ncore_init_boot_seq<%=qidx%>)

  virtual task body();
    ral_sys_ncore model;
    uvm_status_e status;
   
    bit[31:0] data;
    bit[<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] addr;
    int timeout;
    int poll_till;

    // For Initiator IOAIU
    bit [7:0] ioaiu_rpn; // Assuming expected value to be 0
    bit [3:0] ioaiu_nrri; // Assuming expected value to be 0
    // System Census 
    bit [7:0] nAIUs; 
    bit [5:0] nDCEs; 
    bit [5:0] nDMIs; 
    bit [5:0] nDIIs; 
    bit       nDVEs; 

    int act_cmd_skidbuf_size[string][];
    int act_cmd_skidbuf_arb[string][];
    int act_mrd_skidbuf_size[string][];
    int act_mrd_skidbuf_arb[string][];
    int exp_cmd_skidbuf_size[string][];
    int exp_cmd_skidbuf_arb[string][];
    int exp_mrd_skidbuf_size[string][];
    int exp_mrd_skidbuf_arb[string][];
    bit [4:0] Credit_for_Cmd[int][int];//array to associate each aiu to DMI/DCE/DII credit Credit[Aiuid][Dmiid/Dceid/Diiid]
    bit [4:0] Credit_for_Mrd[int][int];//array to associate each dce to DMI credit Credit[Dceid][Dmiid]
    int DceIds[];
    int DmiIds[];
    int DiiIds[];
    int aiu_dmi_connect[];
    int aiu_dii_connect[];
    int aiu_dce_connect[];
    int dce_dmi_connect[];
    int dce[];
    int dmi[];
    int dce_dmi[];
    int dii[];

    $cast(model, this.model);
<% var  fidx=0;for(var idx = 0; idx < obj.nAIUs; idx++) { if((obj.AiuInfo[idx].strRtlNamePrefix== "caiu0")) { for(var pidx=0;pidx < Object.keys(obj.AiuInfo[idx].csr.spaceBlock[0].registers).length; pidx++) { if(obj.AiuInfo[idx].csr.spaceBlock[0].registers[pidx].name == "CAIUIDR") { %>
<%  fidx=1;%>
<% } } } } %>

<% if(fidx ==1) {%>
    //1. read CAIUIDR
    model.caiu0.CAIUIDR.read(status, data);
    addr = model.caiu0.CAIUIDR.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>",$sformatf("caiu0.CAIUIDR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    if(data[31]) begin // valid
      ioaiu_rpn  = data[ 7:0];
      ioaiu_nrri = data[11:8];
	  `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("UIDR.RPN=%0d, UIDR.NRRI=%0d", ioaiu_rpn, ioaiu_nrri), UVM_NONE)
    end else begin
      `uvm_error("ncore_init_boot_seq<%=qidx%>","Valid bit not asserted in USIDR register of Initiating IOAIU-AIU")
    end
<% } %>

    // (2) Read NRRUCR
    data = 0;
    model.sys_global_register_blk.GRBUNRRUCR.read(status, data);
    addr = model.sys_global_register_blk.GRBUNRRUCR.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Read:addr = %0h , NRRUCR = 0x%0h", addr, data), UVM_NONE)
    nAIUs = data[ 7: 0];
    nDCEs = data[13: 8];
    nDMIs = data[19:14];
    nDIIs = data[25:20];
    nDVEs = data[26:26];
    `uvm_info("ncore_init_boot_seq<%=qidx%>",$sformatf("nAIUs:%0d nDCEs:%0d nDMIs:%0d nDIIs:%0d nDVEs:%0d",nAIUs,nDCEs,nDMIs,nDIIs,nDVEs),UVM_NONE)
      aiu_dce_connect = new[nAIUs];
      aiu_dmi_connect = new[nAIUs];
      aiu_dii_connect = new[nAIUs];
      dce_dmi_connect = new[nDCEs];
    if(nDCEs>0)begin
      act_cmd_skidbuf_size["DCE"] = new[nDCEs];
      act_cmd_skidbuf_arb["DCE"]  = new[nDCEs];
      exp_cmd_skidbuf_size["DCE"] = new[nDCEs];
      exp_cmd_skidbuf_arb["DCE"]  = new[nDCEs];
      DceIds = new[nDCEs];
      dce = new[nDCEs];
      dce_dmi = new[nDCEs];
    end
    if(nDMIs>0)begin
      act_cmd_skidbuf_size["DMI"] = new[nDMIs];
      act_cmd_skidbuf_arb["DMI"]  = new[nDMIs];
      act_mrd_skidbuf_size["DMI"] = new[nDMIs];
      act_mrd_skidbuf_arb["DMI"]  = new[nDMIs];
      exp_cmd_skidbuf_size["DMI"] = new[nDMIs];
      exp_cmd_skidbuf_arb["DMI"]  = new[nDMIs];
      exp_mrd_skidbuf_size["DMI"] = new[nDMIs];
      exp_mrd_skidbuf_arb["DMI"]  = new[nDMIs];
      DmiIds = new[nDMIs];
      dmi = new[nDMIs];
    end
    if(nDIIs>0)begin
      act_cmd_skidbuf_size["DII"] = new[nDIIs];
      act_cmd_skidbuf_arb["DII"]  = new[nDIIs];
      exp_cmd_skidbuf_size["DII"] = new[nDIIs];
      exp_cmd_skidbuf_arb["DII"]  = new[nDIIs];
      DiiIds = new[nDIIs];
      dii = new[nDIIs];
    end
    
    <%var largest_index = (obj.nDCEs > obj.nDMIs) ? ( (obj.nDCEs > obj.nDIIs) ? obj.nDCEs : obj.nDIIs ) : ( (obj.nDMIs > obj.nDIIs) ? obj.nDMIs : obj.nDIIs );%>

    // (3) Configure all the General Purpose registers
    `uvm_info("ncore_init_boot_seq<%=qidx%>","Configuring GPRs", UVM_NONE)
    foreach (csrq[i]) begin
      //`uvm_info(get_name(),$sformatf("csrq[memregion_id:%0d] --> unit: %s  hui:%0d start_addr:0x%0h ", i,csrq[i].unit.name(), csrq[i].mig_nunitid,csrq[i].start_addr),UVM_NONE) 
      `uvm_info(get_name(),$sformatf("csrq[memregion_id:%0d] --> unit: %s hui:%0d start_addr:0x%0h low-addr:0x0%h up-addr: 0x%0h sz:%0d", i,csrq[i].unit.name(), csrq[i].mig_nunitid,addr_trans_mgr_pkg::addrMgrConst::memregions_info[i].start_addr,csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),UVM_NONE) 
    end
 
    //Configure address regions for CHIAIU/IOUAIU
<% for(var idx = 0; idx < obj.nAIUs; idx++) {%>
    aiu_dmi_connect[<%=idx%>] = 'h<%=obj.AiuInfo[idx].hexAiuDmiVec%>;
    aiu_dii_connect[<%=idx%>] = 'h<%=obj.AiuInfo[idx].hexAiuDiiVec%>;
    aiu_dce_connect[<%=idx%>] = 'h<%=obj.AiuInfo[idx].hexAiuDceVec%>;
    <% if((obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))) {%>
    //Program CAIUAMIGR register
    data = 'd0;
    data[0] = 1'b1; // valid bit
    data[4:1] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs; //AMIGS field
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUAMIGR.write(status, data);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUAMIGR.get_address();
    `uvm_info("ncore_init_boot_seq", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUAMIGR = 0x%0h", addr, data), UVM_NONE)

    //CAIUMIFSR
    data = 'd0;
    data[2:0] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_if[2];
    data[10:8] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_if[4];
    data[18:16] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_if[8];
    data[26:24] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_if[16];
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUMIFSR.write(status, data[31:0]);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUMIFSR.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUMIFSR = 0x%0h", addr, data), UVM_NONE)

    <%for(var pidx = 0; pidx < nGPRA; ++pidx){%>
    //write to GPR register sets with appropriate values
    data = csrq[<%=pidx%>].low_addr;
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRBLR<%=pidx%>.write(status, data);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRBLR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRBLR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)

    data = csrq[<%=pidx%>].upp_addr;
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRBHR<%=pidx%>.write(status, data);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRBHR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRBHR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[<%=pidx%>].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[<%=pidx%>].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[<%=pidx%>].mig_nunitid;
    data[7:6]   = 2'b01; // to configure to non-secure mode
    data[4:0]   = csrq[<%=pidx%>].order; 
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRAR<%=pidx%>.write(status, data[31:0]);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRAR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRAR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
    <%} %>

    <%} else {%>
    //Program AMIGR register for IOAIU
    data = 'd0;
    data[0] = 1'b1; // valid bit
    data[4:1] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs; //AMIGS field

    <%if (obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    <%for(let port_id=0; port_id < obj.AiuInfo[idx].nNativeInterfacePorts; port_id++ ){%>
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=port_id%>.XAIUAMIGR.write(status, data);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=port_id%>.XAIUAMIGR.get_address();
    `uvm_info("ncore_init_boot_seq", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=port_id%>.XAIUAMIGR = 0x%0h", addr, data), UVM_NONE)
    <%}%>
    <%}else{%>
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUAMIGR.write(status, data);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUAMIGR.get_address();
    `uvm_info("ncore_init_boot_seq", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUAMIGR = 0x%0h", addr, data), UVM_NONE)
    <%}%>


    //XAIUMIFSR
    data = 'd0;
    data[2:0] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_if[2];
    data[10:8] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_if[4];
    data[18:16] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_if[8];
    data[26:24] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_if[16];

    <%if (obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    <%for(let port_id=0; port_id < obj.AiuInfo[idx].nNativeInterfacePorts; port_id++ ){%>
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=port_id%>.XAIUMIFSR.write(status, data[31:0]);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=port_id%>.XAIUMIFSR.get_address();
    `uvm_info("ncore_init_boot_seq", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=port_id%>.XAIUMIFSR = 0x%0h", addr, data), UVM_NONE)
    <%}%>
    <%}else{%>
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUMIFSR.write(status, data[31:0]);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUMIFSR.get_address();
    `uvm_info("ncore_init_boot_seq", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUMIFSR = 0x%0h", addr, data), UVM_NONE)
    <%}%>

    <%for(var pidx = 0; pidx < nGPRA; ++pidx){%>
    //write to GPR register sets with appropriate values
     <%for (var mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
    data = csrq[<%=pidx%>].low_addr;
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUGPRBLR<%=pidx%>.write(status, data);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUGPRBLR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUGPRBLR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
    <%} else { %>
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUGPRBLR<%=pidx%>.write(status, data);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUGPRBLR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUGPRBLR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
    <%} %>

    data = csrq[<%=pidx%>].upp_addr;
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUGPRBHR<%=pidx%>.write(status, data);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUGPRBHR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUGPRBHR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
    <%} else { %>
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUGPRBHR<%=pidx%>.write(status, data);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUGPRBHR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUGPRBHR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
    <%} %>
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[<%=pidx%>].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[<%=pidx%>].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[<%=pidx%>].mig_nunitid;
    data[7:6]   = 2'b01; 
    data[4:0]   = csrq[<%=pidx%>].order; 
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUGPRAR<%=pidx%>.write(status, data[31:0]);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUGPRAR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUGPRAR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
    <%} else { %>
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUGPRAR<%=pidx%>.write(status, data[31:0]);
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUGPRAR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUGPRAR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
    <%} %>
    <%}}  %>
    <%}%>

<%}%>

    // (3) Initialize DCEs
<%for(var idx = 0; idx < obj.nDCEs; ++idx){%>
    <%for(var pidx = 0; pidx < nGPRA; ++pidx){%>

    data = csrq[<%=pidx%>].low_addr;
    model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUGPRBLR<%=pidx%>.write(status, csrq[<%=pidx%>].low_addr );
    addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUGPRBLR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUGPRBLR<%=pidx%>  = 0x%0h", addr, data), UVM_NONE)

    data = csrq[<%=pidx%>].upp_addr;
    model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUGPRBHR<%=pidx%>.write(status, csrq[<%=pidx%>].upp_addr );
    addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUGPRBHR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUGPRBHR<%=pidx%>  = 0x%0h", addr, data), UVM_NONE)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30]    = (csrq[<%=pidx%>].unit == addr_trans_mgr_pkg::addrMgrConst::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[<%=pidx%>].size; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[<%=pidx%>].mig_nunitid;
    data[7:6]   = 2'b01 ;
    data[4:0]   = csrq[<%=pidx%>].order; 
    model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUGPRAR<%=pidx%>.write(status, data[31:0]);
    addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUGPRAR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUGPRAR<%=pidx%>  = 0x%0h", addr, data), UVM_NONE)

     <%}%>

    //DCEUAMIGR
    data = 32'h0; data[4:0]={addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs,1'b1};
    model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUAMIGR.write(status, data[31:0]);
    addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUAMIGR.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUAMIGR = 0x%0h", addr, data), UVM_NONE)

    //DCEUMIFSR
    data = 'd0;
    data[2:0] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_if[2];
    data[10:8] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_if[4];
    data[18:16] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_if[8];
    data[26:24] = addr_trans_mgr_pkg::addrMgrConst::picked_dmi_if[16];
    model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUMIFSR.write(status, data[31:0]);
    addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUAMIGR.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUAMIGR = 0x%0h", addr, data), UVM_NONE)

    //DCEUSFMAR
    poll_till = 32'b0;       
    timeout = 500;
    do begin
      timeout -=1;
      model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUSFMAR.read(status, data);
      addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUSFMAR.get_address();
      `uvm_info("ncore_init_boot_seq<%=qidx%>",$sformatf("model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUSFMAR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    end while ((data != poll_till) && (timeout != 0)); // UNMATCHED !!
    if (timeout == 0) begin
      `uvm_error("ncore_init_boot_seq<%=qidx%>", $sformatf("Timeout! Polling  poll_till=0x%0x data=0x%0x", poll_till, data))
    end 

    //DCEUSBSIR
    data = 0;
    addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUSBSIR.get_address();
    model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUSBSIR.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>",$sformatf("model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUSBSIR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    if(data[31]) begin
      act_cmd_skidbuf_size["DCE"][<%=idx%>]=data[25:16];
      act_cmd_skidbuf_arb["DCE"][<%=idx%>]=data[7:0];
    end else begin
      `uvm_error("ncore_init_boot_seq<%=qidx%>",$sformatf("Valid bit not asserted in DCEUSBSIR addr 0x%0h data 0x%0h",addr, data))
    end
    exp_cmd_skidbuf_size["DCE"][<%=idx%>]=<%=obj.DceInfo[idx].nCMDSkidBufSize%>;
    exp_cmd_skidbuf_arb["DCE"][<%=idx%>]=<%=obj.DceInfo[idx].nCMDSkidBufArb%>;
    compare_act_exp_skidbuf(act_cmd_skidbuf_size,exp_cmd_skidbuf_size,"DCE",<%=idx%>);
    compare_act_exp_skidbuf(act_cmd_skidbuf_arb,exp_cmd_skidbuf_arb,"DCE",<%=idx%>);
    
    DceIds[<%=idx%>]= <%=obj.DceInfo[idx].FUnitId%>; 
    dce_dmi_connect[<%=idx%>] = 'h<%=obj.DceInfo[idx].hexDceDmiVec%>;
<%}%>

    // (5) Initialize DMIs ( dmi*_DMIUSMCTCR)
<% for(var idx = 0; idx < obj.nDMIs; ++idx) { %>
    <% if(obj.DmiInfo[idx].useCmc) { %>
    data=32'h3;
    model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUSMCTCR.write(status, data[31:0]);
    addr = model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUSMCTCR.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUSMCTCR = 0x%0h", addr, data), UVM_NONE)
    <%}%> 

    //MRDSBSIR
    data = 0;
    addr = model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.MRDSBSIR.get_address();
    model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.MRDSBSIR.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>",$sformatf("model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.MRDSBSIR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    if(data[31]) begin
      act_mrd_skidbuf_size["DMI"][<%=idx%>]=data[25:16];
      act_mrd_skidbuf_arb["DMI"][<%=idx%>]=data[7:0];
    end else begin
      `uvm_error("ncore_init_boot_seq<%=qidx%>",$sformatf("Valid bit not asserted in MRDSBSIR addr 0x%0h data 0x%0h",addr, data))
    end
    exp_mrd_skidbuf_size["DMI"][<%=idx%>]=<%=obj.DmiInfo[idx].nMrdSkidBufSize%>;
    exp_mrd_skidbuf_arb["DMI"][<%=idx%>]=<%=obj.DmiInfo[idx].nMrdSkidBufArb%>;
    compare_act_exp_skidbuf(act_mrd_skidbuf_size,exp_mrd_skidbuf_size,"DMI",<%=idx%>);
    compare_act_exp_skidbuf(act_mrd_skidbuf_arb,exp_mrd_skidbuf_arb,"DMI",<%=idx%>);

    //CMDSBSIR
    data = 0;
    addr = model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.CMDSBSIR.get_address();
    model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.CMDSBSIR.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>",$sformatf("model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.CMDSBSIR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    if(data[31]) begin
      act_cmd_skidbuf_size["DMI"][<%=idx%>]=data[25:16];
      act_cmd_skidbuf_arb["DMI"][<%=idx%>]=data[7:0];
    end else begin
      `uvm_error("ncore_init_boot_seq<%=qidx%>",$sformatf("Valid bit not asserted in CMDSBSIR addr 0x%0h data 0x%0h",addr, data))
    end
    exp_cmd_skidbuf_size["DMI"][<%=idx%>]=<%=obj.DmiInfo[idx].nCMDSkidBufSize%>;
    exp_cmd_skidbuf_arb["DMI"][<%=idx%>]=<%=obj.DmiInfo[idx].nCMDSkidBufArb%>;
    compare_act_exp_skidbuf(act_cmd_skidbuf_size,exp_cmd_skidbuf_size,"DMI",<%=idx%>);
    compare_act_exp_skidbuf(act_cmd_skidbuf_arb,exp_cmd_skidbuf_arb,"DMI",<%=idx%>);

    DmiIds[<%=idx%>]= <%=obj.DmiInfo[idx].FUnitId%>; 
<%}%>

    //TAGMEM initialization
	fork
        <%for(let idx=0; idx<obj.nDMIs; idx++){%>
		<%if(obj.DmiInfo[idx].useCmc == 1){%>
        begin
            data[3:0] = 1'd0;
            data[21:16] = 1'd0;
            model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUSMCMCR.write(status, data[31:0]);
            `uvm_info("ncore_init_boot_seq",$sformatf("model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUSMCMCR status = %h data = %h", status, data ),UVM_NONE)
            
            data = 'd0;
            //poll to make sure initialization is complete
            fork
                begin
                    while(data[0] != 1'b1) begin
                        model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUSMCISR.read(status, data);
                    end
                end
                begin
                    #500us;
                    `uvm_error("ncore_init_boot_seq0 for <%=obj.DmiInfo[idx].strRtlNamePrefix%>", $sformatf("Timeout! Polling during tagmem initialization poll_till=0x2 data=0x%0x", data))
                end
            join_any
            disable fork;
        end
		<%}%>
        <%}%>
    join

    //DATAMEM initialization
    fork
        <%for(let idx=0; idx<obj.nDMIs; idx++){%>
		<%if(obj.DmiInfo[idx].useCmc == 1){%>
        begin
            data[3:0] = 1'd0;
            data[21:16] = 1'd1;
            model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUSMCMCR.write(status, data[31:0]);
            `uvm_info("ncore_init_boot_seq",$sformatf("model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUSMCMCR status = %h data = %h", status, data ),UVM_NONE)

            data = 'd0;
            //poll to make sure initialization is complete
            fork
                begin
                    while(data[1] != 1'b1) begin
                        model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUSMCISR.read(status, data);
                    end
                end
                begin
                    #500us;
                    `uvm_error("ncore_init_boot_seq0 for <%=obj.DmiInfo[idx].strRtlNamePrefix%>", $sformatf("Timeout! Polling during datamem initialization poll_till=0x3 data=0x%0x", data))
                end
            join_any
            disable fork;
        end
		<%}%>
        <%}%>
    join

<% for(var idx = 0; idx < obj.nDIIs; ++idx) { %>
    //DIIUSBSIR
    data = 0;
    addr = model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUSBSIR.get_address();
    model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUSBSIR.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>",$sformatf("model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUSBSIR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    if(data[31]) begin
      act_cmd_skidbuf_size["DII"][<%=idx%>]=data[25:16];
      act_cmd_skidbuf_arb["DII"][<%=idx%>]=data[7:0];
    end else begin
      `uvm_error("ncore_init_boot_seq<%=qidx%>",$sformatf("Valid bit not asserted in DIIUSBSIR addr 0x%0h data 0x%0h",addr, data))
    end
    exp_cmd_skidbuf_size["DII"][<%=idx%>]=<%=obj.DiiInfo[idx].nCMDSkidBufSize%>;
    exp_cmd_skidbuf_arb["DII"][<%=idx%>]=<%=obj.DiiInfo[idx].nCMDSkidBufArb%>;
    compare_act_exp_skidbuf(act_cmd_skidbuf_size,exp_cmd_skidbuf_size,"DII",<%=idx%>);
    compare_act_exp_skidbuf(act_cmd_skidbuf_arb,exp_cmd_skidbuf_arb,"DII",<%=idx%>);

    DiiIds[<%=idx%>]= <%=obj.DiiInfo[idx].FUnitId%>; 
<%}%>

   for(int k = 0; k < <%=obj.nAIUs%>; k++)begin
     for(int j=0;j<nDCEs;j++)begin
       if(aiu_dce_connect[k][((nDCEs-1)-j)]) dce[j]++;
     end
     for(int j=0;j<nDMIs;j++)begin
       if(aiu_dmi_connect[k][((nDMIs-1)-j)]) dmi[j]++;
     end
     for(int j=0;j<nDIIs;j++)begin
       if(aiu_dii_connect[k][((nDIIs-1)-j)]) dii[j]++;
     end
   end
   for(int k=0;k<nDMIs;k++)begin
     for(int j=0;j<nDCEs;j++)begin
       if(dce_dmi_connect[j][((nDMIs-1)-k)]) dce_dmi[j]++;
     end
   end

   for(int k = 0; k < <%=obj.nAIUs%>; k++)begin
     for(int j=0;j<nDCEs;j++)begin
          Credit_for_Cmd[k][DceIds[j]] =  ((act_cmd_skidbuf_size["DCE"][j]/dce[j]) > 31 ) ? 31 : ((act_cmd_skidbuf_size["DCE"][j]/dce[j]) < 2 )? 2 : (act_cmd_skidbuf_size["DCE"][j]/dce[j]) ;
     end
     for(int j=0;j<nDMIs;j++)begin
          Credit_for_Cmd[k][DmiIds[j]] = ((act_cmd_skidbuf_size["DMI"][j]/dmi[j]) > 31 ) ? 31 : ((act_cmd_skidbuf_size["DMI"][j]/dmi[j]) < 2 ) ? 2 : (act_cmd_skidbuf_size["DMI"][j]/dmi[j]) ;
     end
     for(int j=0;j<nDIIs;j++)begin
          Credit_for_Cmd[k][DiiIds[j]] = ((act_cmd_skidbuf_size["DII"][j]/dii[j]) > 31 ) ? 31 : ((act_cmd_skidbuf_size["DII"][j]/dii[j]) < 2 ) ? 2 : (act_cmd_skidbuf_size["DII"][j]/dii[j]);
          if(j==(nDIIs-1)) Credit_for_Cmd[k][DiiIds[j]] = 2 ;
     end
   end
<% for(var idx = 0; idx < obj.nAIUs; idx++) {%>
     <%if((obj.AiuInfo[idx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-E') ) {%>
    //CAIUCCR
    <%for(var j=0;j<largest_index;j++) {%>
    data =0; // Reset value
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCCR<%=j%>.get_address();
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    data[4:0]   = Credit_for_Cmd[<%=idx%>][DceIds[<%=j%>]];
    data[12:8]  = Credit_for_Cmd[<%=idx%>][DmiIds[<%=j%>]];
    data[20:16] = Credit_for_Cmd[<%=idx%>][DiiIds[<%=j%>]];
    data[31:24] = 8'hE0;
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCCR<%=j%>.write(status, data[31:0]);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)

    <%} %>
    <%} else {%>
    //XAIUCCR
     <%for (var mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    <%for(var j=0;j<largest_index;j++) {%>
    data =0; // Reset value
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCR<%=j%>.get_address();
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    data[4:0]   = Credit_for_Cmd[<%=idx%>][DceIds[<%=j%>]];
    data[12:8]  = Credit_for_Cmd[<%=idx%>][DmiIds[<%=j%>]];
    data[20:16] = Credit_for_Cmd[<%=idx%>][DiiIds[<%=j%>]];
    data[31:24] = 8'hE0;
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCR<%=j%>.write(status, data[31:0]);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    <%} %>
    <%} else { %>
    <%for(var j=0;j<largest_index;j++) {%>
    data =0; // Reset value
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCCR<%=j%>.get_address();
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    data[4:0]   = Credit_for_Cmd[<%=idx%>][DceIds[<%=j%>]];
    data[12:8]  = Credit_for_Cmd[<%=idx%>][DmiIds[<%=j%>]];
    data[20:16] = Credit_for_Cmd[<%=idx%>][DiiIds[<%=j%>]];
    data[31:24] = 8'hE0;
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCCR<%=j%>.write(status, data[31:0]);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)

    <%} %>
    <%}%>
   <%}%>
  <%}%>
<%}%>
<% for(var idx = 0; idx < obj.nDCEs; idx++) {%>
    //DCEUCCR
    <%for(var j=0;j<obj.nDMIs;j++) {%>
    Credit_for_Mrd[DceIds[<%=idx%>]][DmiIds[<%=j%>]] =((act_mrd_skidbuf_size["DMI"][<%=j%>]/dce_dmi[<%=idx%>]) > 31 ) ? 31 : (act_mrd_skidbuf_size["DMI"][<%=j%>]/dce_dmi[<%=idx%>]) ;
    data =0; // Reset value
    addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCCR<%=j%>.get_address();
    model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    data[4:0]   = Credit_for_Mrd[DceIds[<%=idx%>]][DmiIds[<%=j%>]];
    data[12:8]  = 8'hE0;
    data[20:16] = 8'hE0;
    data[31:24] = 8'hE0;
    model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCCR<%=j%>.write(status, data[31:0]);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    <%} %>
<%}%>

//   =======  CONC-11480
<% for(var idx = 0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&& (obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')  && (obj.AiuInfo[idx].fnNativeInterface == 'ACE'|| (((obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E') ) && (obj.AiuInfo[idx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[idx].fnNativeInterface == 'AXI4' && obj.AiuInfo[idx].useCache == 1 ))) { 
      for(var pidx=0;pidx < Object.keys(obj.AiuInfo[idx].csr.spaceBlock[0].registers).length; pidx++) { 
        if(obj.AiuInfo[idx].csr.spaceBlock[0].registers[pidx].name == "XAIUPCTCR") { %>
     <%for (var mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
    data=32'h0;
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
	addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCTCR.get_address();
	model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCTCR.read(status, data);
	`uvm_info("ncore_init_boot_seq0", $sformatf("Reg Read:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCTCR = 0x%0h", addr, data), UVM_NONE)
	data[1:0] = 2'b11; // enable LookupEn & AllocEn
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCTCR.write(status, data[31:0]);  
    `uvm_info("ncore_init_boot_seq0", $sformatf("my_if Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCTCR = 0x%0h", addr, data), UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCTCR.read(status, data);

    <%} else { %>
	addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCTCR.get_address();
	model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCTCR.read(status, data);
	`uvm_info("ncore_init_boot_seq0", $sformatf("Reg Read:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCTCR = 0x%0h", addr, data), UVM_NONE)
	data[1:0] = 2'b11; // enable LookupEn & AllocEn
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCTCR.write(status, data[31:0]);  
    `uvm_info("ncore_init_boot_seq0", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCTCR = 0x%0h", addr, data), UVM_NONE)
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCTCR.read(status, data);
    
<% } } } } } } %> 

//ACE SYSCO attach & pool status
<% for(var idx = 0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&& (obj.AiuInfo[idx].fnNativeInterface != 'CHI-E') && (obj.AiuInfo[idx].fnNativeInterface == 'ACE'|| (((obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E') ) && (obj.AiuInfo[idx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[idx].fnNativeInterface == 'AXI4' && obj.AiuInfo[idx].useCache == 1 ))) { 
      for(var pidx=0;pidx < Object.keys(obj.AiuInfo[idx].csr.spaceBlock[0].registers).length; pidx++) { 
        if(obj.AiuInfo[idx].csr.spaceBlock[0].registers[pidx].name == "XAIUTCR") { %>
     <%for (var mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
    // Attach
    data=0;
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTCR.get_address();
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTCR.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Read:addr = %0h, <%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTCR.SysCoAttach = 0x%0h", addr, data), UVM_NONE)
    data[model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTCR.SysCoAttach.get_lsb_pos()]=1'b1;    //SysCoAttach 
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTCR.write(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h, <%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTCR.SysCoAttach = 0x%0h", addr, data), UVM_NONE)
    //poll until attach
    poll_till = 0;                       
    poll_till[model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.SysCoAttached.get_lsb_pos()] = 1'b1; // SysCoAttached                       
    timeout = 2000;
    do begin                
      timeout -=1;
      data=0;
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.read(status, data);
      if (data[model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.SysCoError.get_lsb_pos()]) //SysCoError
       `uvm_error("ncore_init_boot_seq", $sformatf("SysCoError!!! model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.SysCoError status = %h addr = %h data = %h", status, addr, data))
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.read(status, data);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>",$sformatf("POLLING model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.SysCoAttached status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    end while((data[model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.SysCoAttached.get_lsb_pos()] != poll_till[model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.SysCoAttached.get_lsb_pos()])&& (timeout != 0));
    <%} else { %>
    addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTCR.get_address();
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTCR.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Read:addr = %0h, <%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTCR.SysCoAttach = 0x%0h", addr, data), UVM_NONE)
    data[model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTCR.SysCoAttach.get_lsb_pos()]=1'b1;    //SysCoAttach 
    model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTCR.write(status, data);
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h, <%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTCR.SysCoAttach = 0x%0h", addr, data), UVM_NONE)
    //poll until attach
    poll_till = 0;                       
    poll_till[model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.SysCoAttached.get_lsb_pos()] = 1'b1; // SysCoAttached                       
    timeout = 2000;
    do begin                
      timeout -=1;
      data=0;
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.read(status, data);
      if (data[model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.SysCoError.get_lsb_pos()]) //SysCoError
       `uvm_error("ncore_init_boot_seq", $sformatf("SysCoError!!! model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.SysCoError status = %h addr = %h data = %h", status, addr, data))
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.read(status, data);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>",$sformatf("POLLING model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.SysCoAttached status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    end while((data[model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.SysCoAttached.get_lsb_pos()] != poll_till[model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.SysCoAttached.get_lsb_pos()])&& (timeout != 0));
    <%}%>
    if (timeout == 0) begin
      `uvm_error("ncore_init_boot_seq", $sformatf("Timeout! Polling  poll_till=0x%0x data=0x%0x", poll_till, data))
    end
<% } } } } } %>

//POLL XAIUPCISR

<% for(var idx = 0; idx < obj.nAIUs; idx++) { if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&& (obj.AiuInfo[idx].fnNativeInterface != 'CHI-E') && (obj.AiuInfo[idx].fnNativeInterface != 'ACE')) { for(var pidx=0;pidx < Object.keys(obj.AiuInfo[idx].csr.spaceBlock[0].registers).length; pidx++) { if(obj.AiuInfo[idx].csr.spaceBlock[0].registers[pidx].name == "XAIUPCISR") { %>
     <%for (var mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
    poll_till = 32'b11;                       
    timeout = 5000;
    do begin                
      timeout -=1;
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCISR.read(status, data);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCISR.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>",$sformatf("model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCISR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    <%} else { %>
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCISR.read(status, data);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCISR.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>",$sformatf("model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCISR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    <%}%>
    end while((data != poll_till)&& (timeout != 0));
    if (timeout == 0) begin
      `uvm_error("ncore_init_boot_seq", $sformatf("Timeout! Polling  poll_till=0x%0x data=0x%0x", poll_till, data))
    end
<% }} } } } %>

    //trigger event for init done
     
    reg_init_done.trigger();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("triggered reg_init_done event"), UVM_MEDIUM)

  endtask : body

  task compare_act_exp_skidbuf(int act_skidbuf[string][],int exp_skidbuf[string][],string target_type,int id);

        if(exp_skidbuf[target_type][id]!= act_skidbuf[target_type][id]) begin
            `uvm_error("ncore_init_boot_seq",$sformatf("SKIDBUF compare exp_skidbuf[target_type][%0d] %0d != act_skidbuf[target_type][%0d] %0d",id,exp_skidbuf[target_type][id],id,act_skidbuf[target_type][id]))
        end else begin
            `uvm_info("ncore_init_boot_seq",$sformatf("SKIDBUF compare target_type %0s id %0d skidbuf_info %0d",target_type,id,exp_skidbuf[target_type][id] ),UVM_NONE)
        end

  endtask
  

endclass : ncore_init_boot_seq<%=qidx%>

class wr_rd_seq extends uvm_reg_sequence #(uvm_sequence #(uvm_reg_item));

   uvm_reg rg;

   `uvm_object_utils(wr_rd_seq)

   function new(string name="wr_rd_seq");
     super.new(name);
   endfunction

   virtual task body();
      uvm_reg_field fields[$];
      string mode[`UVM_REG_DATA_WIDTH];
      uvm_reg_map maps[$];
      uvm_reg_data_t  dc_mask;
      uvm_reg_data_t  reset_val;
      int n_bits;
      string field_access;
      uvm_status_e status;
      uvm_reg_data_t  val, exp, v;
      bit bit_val;
       
   
      if(rg == null) begin
         `uvm_error("wr_rd_seq", "No register specified to run sequence on");
         return;
      end

      if(uvm_resource_db#(bit)::get_by_name({"REG::",rg.get_full_name()},"NO_REG_TESTS", 0) != null || uvm_resource_db#(bit)::get_by_name({"REG::",rg.get_full_name()},"NO_REG_BIT_BASH_TEST", 0) != null )
            return;
      
      n_bits = rg.get_n_bytes() * 8;
         
      rg.get_fields(fields);
         
      rg.get_maps(maps);
         
      foreach (maps[j]) begin
         uvm_status_e status;
         uvm_reg_data_t  val, exp, v,read_data;
         int next_lsb;
         
         next_lsb = 0;
         dc_mask  = 0;
         foreach (fields[k]) begin
            int lsb, w, dc;

            field_access = fields[k].get_access(maps[j]);
            dc = (fields[k].get_compare() == UVM_NO_CHECK);
            lsb = fields[k].get_lsb_pos();
            w   = fields[k].get_n_bits();
            // Ignore Write-only fields because
            // you are not supposed to read them
            case (field_access)
             "WO", "WOC", "WOS", "WO1", "NOACCESS": dc = 1;
            endcase
            // Any unused bits on the right side of the LSB?
            while (next_lsb < lsb) mode[next_lsb++] = "RO";
            
            repeat (w) begin
               mode[next_lsb] = field_access;
               dc_mask[next_lsb] = dc;
               next_lsb++;
            end
         end
         // Any unused bits on the left side of the MSB?
         while (next_lsb < `UVM_REG_DATA_WIDTH)
            mode[next_lsb++] = "RO";
         

            bash_reg(rg,maps[j], dc_mask);

      end
   endtask: body

   task bash_reg(uvm_reg         rg,
                     uvm_reg_map     map,
                     uvm_reg_data_t  dc_mask);
      uvm_status_e status;
      uvm_reg_data_t  val, exp, v;
      bit bit_val;

      `uvm_info("wr_rd_seq", $sformatf("...Bashing reg %0s", rg.get_full_name()),UVM_NONE);
      
         for(int i=0;i<3;i++)begin  
            val=32'h55555555;
            if(i==1)val[31:0] = ~val;
            if(i==2)val[31:0] = 0;
            v= val;

            rg.write(status, val);
            if (status != UVM_IS_OK)
               `uvm_error("wr_rd_seq", $sformatf("Status was %s when writing to register \"%s\" through map \"%s\".",status.name(), rg.get_full_name(), map.get_full_name()));

            exp = rg.get() & ~dc_mask;
            rg.read(status, val);
            if (status != UVM_IS_OK)
               `uvm_error("wr_rd_seq", $sformatf("Status was %s when reading register \"%s\" through map \"%s\".",status.name(), rg.get_full_name(), map.get_full_name()));

            val &= ~dc_mask;
            if (val !== exp) 
               `uvm_error("wr_rd_seq", $sformatf("Writing a %0h in  of register \"%s\" with initial value 'h%h yielded 'h%h instead of 'h%h",v, rg.get_full_name(), v, val, exp));

         end
      
   endtask: bash_reg

endclass: wr_rd_seq

class reg_wr_rd_seq extends uvm_reg_sequence#(uvm_sequence #(uvm_reg_item));

  `uvm_object_utils(reg_wr_rd_seq)

wr_rd_seq reg_seq;

  function new(string name="reg_wr_rd_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    ral_sys_ncore model;
    uvm_status_e status;
    bit[31:0] data,write_data,expt_data;
    bit[<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] addr;
    uvm_reg_field 	fields[$];
    string str;
    int lsb,bits;

    $cast(model, this.model);
 


      if (model == null) begin
         `uvm_error("reg_wr_rd_seq", "No register model specified to run sequence on");
         return;
      end

      reg_seq = wr_rd_seq::type_id::create("reg_seq");

      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_NONE);


      model.reset();

      do_block(model);

  endtask 

    task do_block(uvm_reg_block blk);
      uvm_reg regs[$];

      if (uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},"NO_REG_TESTS", 0) != null || uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},"NO_REG_BIT_BASH_TEST", 0) != null )
         return;

      // Iterate over all registers, checking accesses
      blk.get_registers(regs, UVM_NO_HIER);
      foreach (regs[i]) begin
         // Registers with some attributes are not to be tested
         if (uvm_resource_db#(bit)::get_by_name({"REG::",regs[i].get_full_name()},"NO_REG_TESTS", 0) != null || uvm_resource_db#(bit)::get_by_name({"REG::",regs[i].get_full_name()},"NO_REG_BIT_BASH_TEST", 0) != null )
            continue;
         
         reg_seq.rg = regs[i];
         reg_seq.start(null);
      end

      begin
         uvm_reg_block blks[$];
         
         blk.get_blocks(blks);
         foreach (blks[i]) begin
            do_block(blks[i]);
         end
      end
   endtask: do_block

endclass 

//--------------------------------------------------------
// ncore_fsc_ralgen_err_intr_seq 
//---------------------------------------------------------
                                  
class ncore_fsc_ralgen_err_intr_seq extends uvm_reg_sequence;

  /** UVM Object Utility macro */
  `uvm_object_utils(ncore_fsc_ralgen_err_intr_seq)


  /** reginit event **/ 
  uvm_event              reginit_done;
  uvm_status_e           status;
  uvm_reg_data_t         field_rd_data;
  uvm_reg_data_t         field_wr_data;
  uvm_reg                rg; 
  uvm_reg_field          fields;
  integer                ErrVld;

<%for(pidx = 0; pidx < obj.nAIUs; pidx++) {%>
  virtual IRQ_if m_irq_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_if;
<% }%>
<% for(pidx = 0; pidx < obj.nDCEs; pidx++) {%>
  virtual IRQ_if m_irq_<%=obj.DceInfo[pidx].strRtlNamePrefix%>_if;
<% }%>
<% for(pidx = 0; pidx < obj.nDMIs; pidx++) {%>
  virtual IRQ_if m_irq_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>_if;
<% }%>
<% for(pidx = 0; pidx < obj.nDIIs; pidx++) {%>
  virtual IRQ_if m_irq_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>_if;
<% }%>
<% for(pidx = 0; pidx < obj.nDVEs; pidx++) {%>
  virtual IRQ_if m_irq_<%=obj.DveInfo[pidx].strRtlNamePrefix%>_if;
<% }%>
  
  // Addr domain queue
  addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t csrq[$];

  /** Class Constructor */
  function new (string name = "concerto_fullsys_ralgen_err_intr_seq");
    super.new(name);
  endfunction : new

  /** Raise an objection if this is the parent sequence */
  virtual task pre_body();
    string arg_value;
    super.pre_body();
    if (starting_phase!=null) begin
      starting_phase.raise_objection(this);
    end
  endtask: pre_body

  /** Drop an objection if this is the parent sequence */
  virtual task post_body();
    super.post_body();
    if (starting_phase!=null) begin
      starting_phase.drop_objection(this);
    end
  endtask: post_body

  virtual task body();
      ral_sys_ncore model;
      uvm_status_e status;
      time time_diff;
      bit[31:0] data;
      bit[<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] addr;
      $cast(model, this.model);

<%for(pidx = 0; pidx < obj.nAIUs; pidx++) {%>
      if(!uvm_config_db#(virtual IRQ_if)::get(null,get_full_name(),"m_irq_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_if",m_irq_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_if))begin
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
      end
<%  }%>
<% for(pidx = 0; pidx < obj.nDCEs; pidx++) {%>
      if(!uvm_config_db#(virtual IRQ_if)::get(null,get_full_name(),"m_irq_<%=obj.DceInfo[pidx].strRtlNamePrefix%>_if",m_irq_<%=obj.DceInfo[pidx].strRtlNamePrefix%>_if))begin
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
      end
<% }%>
<% for(pidx = 0; pidx < obj.nDMIs; pidx++) {%>
      if(!uvm_config_db#(virtual IRQ_if)::get(null,get_full_name(),"m_irq_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>_if",m_irq_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>_if))begin
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
      end
<% }%>
<% for(pidx = 0; pidx < obj.nDIIs; pidx++) {%>
      if(!uvm_config_db#(virtual IRQ_if)::get(null,get_full_name(),"m_irq_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>_if",m_irq_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>_if))begin
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
      end
<% }%>
<% for(pidx = 0; pidx < obj.nDVEs; pidx++) {%>
      if(!uvm_config_db#(virtual IRQ_if)::get(null,get_full_name(),"m_irq_<%=obj.DveInfo[pidx].strRtlNamePrefix%>_if",m_irq_<%=obj.DveInfo[pidx].strRtlNamePrefix%>_if))begin
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
      end
<% }%>

<% for(var idx = 0; idx < obj.nAIUs; idx++) {
      if((obj.AiuInfo[idx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-E')) {%>
      ///step-1
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("\n<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_1: check uncorrectable pin should be at reset state  at time: %t \n", $time),UVM_NONE)
      if(m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
      end
     //step-2  
     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_2: read register *UESR,it should be at reset state at time: %t \n",$time),UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.get_address();
      ErrVld = 0;

      if(field_rd_data[0] == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h CAIUUESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h CAIUUESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
      end
   
      //************************************************************************************
      // set IntEn   step-3
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_3: set ProtErrIntEn in UUEIR* at time: %t \n",$time),UVM_NONE)
      //************************************************************************************
      field_wr_data[0] = 1; 
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUEIR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUEIR.get_address();

     
      ///step-4
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_4: set *CESAR.ErrVld = 1 and ErrType = 0x2 (Native Interface Write Response Error) at time: %t \n",$time),UVM_NONE)

      ErrVld = 1;
      field_wr_data[0] = ErrVld; 
      field_wr_data[9:4] = 2;   
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUESAR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUESAR.get_address();
      field_wr_data[9:4] = 0;   

      //****************************************************************************
      // check intr pin  step-5 
      //****************************************************************************
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_5: wait for uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
      wait(m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc == 1)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc  interrupt asserted"),UVM_NONE);
      end
     
     //step-6
     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_6: read *CESR.ErrVld, check to make sure ErrVld = 1 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.get_address();

      if(field_rd_data[0] == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h CAIUUESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h CAIUUESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
      end

   
      //step-7 
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_7: set *UESR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
      ErrVld = 1;
      field_wr_data[0] = ErrVld; 
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.get_address();
      
      //step-8
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_8: wait for ucorrectable interrupt =0 at time: %t \n",$time),UVM_NONE)
      wait(m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc == 0)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc  interrupt de-asserted"),UVM_NONE);
      end
      
      //step-9
      ErrVld = 0;
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_9: read *UESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUUESR.get_address();
      if(field_rd_data[0] == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h CAIUUESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h CAIUUESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
      end
   
    <%} else {
     for (var mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
      ///step-1
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("\n<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_1: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
      if((m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
    <%} else { %>
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("\n<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_1: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
      if((m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
    <%} %>
         `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
      //step-2  
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_2: read alias register *CESAR,it should be at reset state at time: %t \n",$time),UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESAR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESAR.get_address();
    <%} else { %>
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_2: read alias register *CESAR,it should be at reset state at time: %t \n",$time),UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCESAR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCESAR.get_address();
    <%} %>
      ErrVld = 0;

      if(field_rd_data[0] == ErrVld)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h XAIUCESAR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
      end else begin
         `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h XAIUCESAR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
      end
      ///step-3
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_3: set *CESAR.ErrVld = 1 & ErrCountOverflow = 1 at time: %t \n",$time),UVM_NONE)

      ErrVld = 3;
      field_wr_data = ErrVld; 
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESAR.get_address();

      //step-4
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_4: read *CESR.ErrVld, check to make sure ErrVld = 1 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESR.get_address();
    <%} else { %>
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_3: set *CESAR.ErrVld = 1 & ErrCountOverflow = 1 at time: %t \n",$time),UVM_NONE)

      ErrVld = 3;
      field_wr_data = ErrVld; 
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCESAR.get_address();

      //step-4
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_4: read *CESR.ErrVld, check to make sure ErrVld = 1 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCESR.get_address();
    <%} %>

      if(field_rd_data == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h XAIUCESR_ErrVld value :%b XAIUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0],field_rd_data[1]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h XAIUCESR_ErrVld value :%b XAIUCESR_ErrCountOverflow value :%b Expected :%b",addr,field_rd_data[0],field_wr_data[0] ,field_rd_data[1], field_wr_data[1]));
      end
      ///step-5
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_5: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
      if((m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
      //step-6
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_6: read System interrupt register CAIUUESRx,check to make sure, all these at reset state  at time: %t \n",$time),UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
    <%} else { %>
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_5: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
      if((m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
      //step-6
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_6: read System interrupt register CAIUUESRx,check to make sure, all these at reset state  at time: %t \n",$time),UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
    <%}%>
      if(!field_rd_data)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("XAIUUESR value :%b",field_rd_data),UVM_NONE)
      end
      else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("XAIUUESR value :%b",field_rd_data))
      end
   
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
      //****************************************************************************
      // set IntEn   step-7
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_7: set *ECR.ErrIntEn at time: %t \n",$time),UVM_NONE)
      //****************************************************************************

     
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCECR.ErrIntEn.set(1);
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCECR.update(status,UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCECR.get_address();
      //****************************************************************************
      // check intr pin  step-8 
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_8: wait for correctable interrupt =1, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
      //****************************************************************************
      wait(m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 1)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt asserted"),UVM_NONE);
      end
      if(m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
         `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
      end
 
      //step-9 
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_9: read System interrupt register XAIUUESRx,check to make sure,only one bit corresponding to block is set , all other bit should be 0 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
    <%} else { %>
      //****************************************************************************
      // set IntEn   step-7
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_7: set *ECR.ErrIntEn at time: %t \n",$time),UVM_NONE)
      //****************************************************************************

     
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCECR.ErrIntEn.set(1);
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCECR.update(status,UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCECR.get_address();
      //****************************************************************************
      // check intr pin  step-8 
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_8: wait for correctable interrupt =1, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
      //****************************************************************************
      wait(m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 1)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt asserted"),UVM_NONE);
      end
      if(m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
         `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
      end
 
      //step-9 
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_9: read System interrupt register XAIUUESRx,check to make sure,only one bit corresponding to block is set , all other bit should be 0 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUUESR.read(status, field_rd_data, UVM_FRONTDOOR);

    <%}%>
       
      if(!field_rd_data)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("XAIUUESR value :%b",field_rd_data),UVM_MEDIUM)
      end
      else begin
         `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("XAIUUESR value :%b",field_rd_data))
      end
      
  
      //step-10
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_10: set *CESAR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
      ErrVld = 0;
      field_wr_data = ErrVld; 
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESAR.get_address();
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCESR.get_address();
      //step-11
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_11: read *CESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
    <%} else { %>
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_10: set *CESAR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
      ErrVld = 0;
      field_wr_data = ErrVld; 
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCESAR.get_address();
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCESR.get_address();
      //step-11
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_11: read *CESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
    <%}%>
      if(field_rd_data == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h XAIUCESR_ErrVld value :%b XAIUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0],field_rd_data[1]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h XAIUCESR_ErrVld value :%b XAIUCESR_ErrCountOverflow value :%b Expected :%b",addr,field_rd_data[0],field_wr_data[0] ,field_rd_data[1], field_wr_data[1]));
      end
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
      //step-12
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_12: wait for correctable interrupt =0, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
      wait(m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 0)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt de-asserted"),UVM_NONE);
      end
      if((m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
         `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end

      //step-13
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%> STEP_13: read System interrupt register XAIUUESR.,check to make sure all at time: %t \n",$time),UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUUESR.read(status,field_rd_data,UVM_FRONTDOOR);
    <%} else { %>
      //step-12
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_12: wait for correctable interrupt =0, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
      wait(m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 0)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt de-asserted"),UVM_NONE);
      end
      if((m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
         `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end

      //step-13
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.AiuInfo[idx].strRtlNamePrefix%> STEP_13: read System interrupt register XAIUUESR.,check to make sure all at time: %t \n",$time),UVM_NONE)
      model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUUESR.read(status,field_rd_data,UVM_FRONTDOOR);
    <%} %>
      if(!field_rd_data)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("XAIUUESR. value :%b",field_rd_data),UVM_MEDIUM)
      end
      else begin
         `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("XAIUUESR. value :%b",field_rd_data))
      end
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
      if((m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
    <%} else { %>
      if((m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
    <%}%>
 
<%}} %>
<%} %>
<%for(var idx = 0; idx < obj.nDCEs; idx++){%>
      ///step-1
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DceInfo[idx].strRtlNamePrefix%> STEP_1: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
      if((m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
      //step-2  
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DceInfo[idx].strRtlNamePrefix%> STEP_2: read alias register *CESAR,it should be at reset state at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCESAR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCESAR.get_address();
      ErrVld = 0;

      if(field_rd_data[0] == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DCEUCESAR_ErrVld value :%b ",addr,field_rd_data[0]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DCEUCESAR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
      end
      ///step-3
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DceInfo[idx].strRtlNamePrefix%> STEP_3: set *CESAR ErrVld = 1  & ErrCountOverflow = 1 at time: %t \n",$time),UVM_NONE)

      ErrVld = 3;
      field_wr_data = ErrVld; 
      model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCESAR.get_address();

      //step-4
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DceInfo[idx].strRtlNamePrefix%> STEP_4: read *CESR, check to make sure ErrVld = 1 & ErrCountOverflow = 1 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCESR.get_address();

      if(field_rd_data == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DCEUCESR_ErrVld value :%b & DCEUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0],field_rd_data[1]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DCEUCESR_ErrVld value :%b Expected :1 DCEUCESR_ErrCountOverflow value :%b Expected :1",addr,field_rd_data[0],field_rd_data[1]));
      end
      ///step-5
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DceInfo[idx].strRtlNamePrefix%> STEP_5: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
      if((m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
      //step-6
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DceInfo[idx].strRtlNamePrefix%> STEP_6: read System interrupt register DCEUUEIR,check to make sure, all these at reset state  at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUUEIR.read(status, field_rd_data, UVM_FRONTDOOR);
      if(!field_rd_data)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DCEUUEIR value :%b",field_rd_data),UVM_NONE)
      end
      else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DCEUUEIR value :%b",field_rd_data))
      end
   
      //****************************************************************************
      // set IntEn   step-7
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DceInfo[idx].strRtlNamePrefix%> STEP_7: set *ECR.ErrIntEn at time: %t \n",$time),UVM_NONE)
      //****************************************************************************

     
      model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCECR.ErrIntEn.set(1);
      model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCECR.update(status,UVM_FRONTDOOR);
      addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCECR.get_address();
      //****************************************************************************
      // check intr pin  step-8 
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DceInfo[idx].strRtlNamePrefix%> STEP_8: wait for correctable interrupt =1, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
      //****************************************************************************
      wait(m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 1)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt asserted"),UVM_NONE);
      end
      if(m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
         `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
      end
 
      //step-9 
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DceInfo[idx].strRtlNamePrefix%> STEP_9: read System interrupt register DCEUUEIRx,check to make sure,only one bit corresponding to block is set , all other bit should be 0 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUUEIR.read(status, field_rd_data, UVM_FRONTDOOR);
       
      if(!field_rd_data)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DCEUUEIR value :%b",field_rd_data),UVM_MEDIUM)
      end
      else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DCEUUEIR value :%b",field_rd_data))
      end
      
  
      //step-10
     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DceInfo[idx].strRtlNamePrefix%> STEP_10: set *CESAR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
      ErrVld = 0;
      field_wr_data = ErrVld; 
      model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCESAR.get_address();
      model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUCESR.get_address();
      //step-11
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DceInfo[idx].strRtlNamePrefix%> STEP_11: read *CESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
      if(field_rd_data == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DCEUCESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DCEUCESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
      end
      //step-12
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DceInfo[idx].strRtlNamePrefix%> STEP_12: wait for correctable interrupt =0, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
      wait(m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 0)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt de-asserted"),UVM_NONE);
      end
      if((m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end

      //step-13
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DceInfo[idx].strRtlNamePrefix%> STEP_13: read System interrupt register DCEUUEIR,check to make sure all at time: %t\n",$time),UVM_NONE)
      model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUUEIR.read(status,field_rd_data,UVM_FRONTDOOR);
      if(!field_rd_data)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DCEUUEIR. value :%b",field_rd_data),UVM_MEDIUM)
      end
      else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DCEUUEIR. value :%b",field_rd_data))
      end
      if((m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
<%} %>
<%for(var idx = 0; idx < obj.nDMIs; idx++){%>
      ///step-1
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DmiInfo[idx].strRtlNamePrefix%> STEP_1: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
      if((m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
      //step-2  
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DmiInfo[idx].strRtlNamePrefix%> STEP_2: read alias register *CESAR,it should be at reset state at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUCESAR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUCESAR.get_address();
      ErrVld = 0;

      if(field_rd_data[0] == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DMIUCESAR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DMIUCESAR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
      end
      ///step-3
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DmiInfo[idx].strRtlNamePrefix%> STEP_3: set *CESAR.ErrVld = 1 at time: %t \n",$time),UVM_NONE)

      ErrVld = 3;
      field_wr_data = ErrVld; 
      model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUCESAR.get_address();

      //step-4
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DmiInfo[idx].strRtlNamePrefix%> STEP_4: read *CESR.ErrVld, check to make sure ErrVld = 1  & ErrCountOverflow = 1 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUCESR.get_address();

      if(field_rd_data == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DMIUCESR_ErrVld value  :%b DMIUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0], field_rd_data[1]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DMIUCESR_ErrVld value :%b Expected :%b DMIUCESR_ErrCountOverflow value :%b Expected :%b",addr,field_rd_data[0], field_wr_data[0],field_rd_data[1], field_wr_data[1]));
      end
      ///step-5
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DmiInfo[idx].strRtlNamePrefix%> STEP_5: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
      if((m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
      //step-6
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DmiInfo[idx].strRtlNamePrefix%> STEP_6: read System interrupt register DMIUUEIR,check to make sure, all these at reset state  at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUUEIR.read(status, field_rd_data, UVM_FRONTDOOR);
      if(!field_rd_data)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DMIUUEIR value :%b",field_rd_data),UVM_NONE)
      end
      else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DMIUUEIR value :%b",field_rd_data))
      end
   
      //****************************************************************************
      // set IntEn   step-7
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DmiInfo[idx].strRtlNamePrefix%> STEP_7: set *ECR.ErrIntEn at time: %t \n",$time),UVM_NONE)
      //****************************************************************************

     
      model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUCECR.ErrIntEn.set(1);
      model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUCECR.update(status,UVM_FRONTDOOR);
      addr = model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUCECR.get_address();
      //****************************************************************************
      // check intr pin  step-8 
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DmiInfo[idx].strRtlNamePrefix%> STEP_8: wait for correctable interrupt =1, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
      //****************************************************************************
      wait(m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 1)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt asserted"),UVM_NONE);
      end
      if(m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
      end
 
      //step-9 
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DmiInfo[idx].strRtlNamePrefix%> STEP_9: read System interrupt register DMIUUEIRx,check to make sure,only one bit corresponding to block is set , all other bit should be 0 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUUEIR.read(status, field_rd_data, UVM_FRONTDOOR);
       
      if(!field_rd_data)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DMIUUEIR value :%b",field_rd_data),UVM_MEDIUM)
      end
      else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DMIUUEIR value :%b",field_rd_data))
      end
      
  
      //step-10
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DmiInfo[idx].strRtlNamePrefix%> STEP_10: set *CESAR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
      ErrVld = 0;
      field_wr_data = ErrVld; 
      model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUCESAR.get_address();
      model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUCESR.get_address();
      //step-11
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DmiInfo[idx].strRtlNamePrefix%> STEP_11: read *CESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
      if(field_rd_data == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DMIUCESR_ErrVld value :%b DMIUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0],field_rd_data[1]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DMIUCESR_ErrVld value :%b Expected :%b DMIUCESR_ErrCountOverflow value :%b Expected :%b",addr,field_rd_data[0],field_wr_data[0], field_rd_data[1], field_wr_data[1]));
      end

      //step-12
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DmiInfo[idx].strRtlNamePrefix%> STEP_12: wait for correctable interrupt =0, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
      wait(m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 0)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt de-asserted"),UVM_NONE);
      end
      if((m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end

      //step-13
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DmiInfo[idx].strRtlNamePrefix%> STEP_13: read System interrupt register DMIUUEIR,check to make sure all at time: %t\n",$time),UVM_NONE)
      model.<%=obj.DmiInfo[idx].strRtlNamePrefix%>.DMIUUEIR.read(status,field_rd_data,UVM_FRONTDOOR);
      if(!field_rd_data)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DMIUUEIR. value :%b",field_rd_data),UVM_MEDIUM)
      end
      else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DMIUUEIR. value :%b",field_rd_data))
      end
      if((m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
<%} %>

<%for(var idx = 0; idx < obj.nDIIs; idx++){%>
  <% if(obj.DiiInfo[idx].useResiliency == 1 && obj.DiiInfo[idx].ResilienceInfo.fnResiliencyProtectionType === "ecc"){ %>
      ///step-1
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("\n<%=obj.DiiInfo[idx].strRtlNamePrefix%> STEP_1: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
      if((m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
      //step-2  
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DiiInfo[idx].strRtlNamePrefix%> STEP_2: read alias register *CESAR,it should be at reset state at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUCESAR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUCESAR.get_address();
      ErrVld = 0;

      if(field_rd_data[0] == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DIIUCESAR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DIIUCESAR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
      end
      ///step-3
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DiiInfo[idx].strRtlNamePrefix%> STEP_3: set *CESAR.ErrVld = 1 at time: %t \n",$time),UVM_NONE)

      ErrVld = 3;
      field_wr_data = ErrVld; 
      model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUCESAR.get_address();

      //step-4
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DiiInfo[idx].strRtlNamePrefix%> STEP_4: read *CESR.ErrVld, check to make sure ErrVld = 1  & ErrCountOverflow = 1 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUCESR.get_address();

      if(field_rd_data == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DIIUCESR_ErrVld value  :%b DIIUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0], field_rd_data[1]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DIIUCESR_ErrVld value :%b Expected :%b DIIUCESR_ErrCountOverflow value :%b Expected :%b",addr,field_rd_data[0],field_wr_data[0], field_rd_data[1], field_wr_data[1]));
      end
      ///step-5
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DiiInfo[idx].strRtlNamePrefix%> STEP_5: check correctable and uncorrectabe pin both should be at reset state  at time: %t \n",$time),UVM_NONE)
      if((m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
      //step-6
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DiiInfo[idx].strRtlNamePrefix%> STEP_6: read System interrupt register DIIUUEIR,check to make sure, all these at reset state  at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUUEIR.read(status, field_rd_data, UVM_FRONTDOOR);
      if(!field_rd_data)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DIIUUEIR value :%b",field_rd_data),UVM_NONE)
      end
      else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DIIUUEIR value :%b",field_rd_data))
      end
   
      //****************************************************************************
      // set IntEn   step-7
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DiiInfo[idx].strRtlNamePrefix%> STEP_7: set *ECR.ErrIntEn at time: %t \n",$time),UVM_NONE)
      //****************************************************************************

     
      model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUCECR.ErrIntEn.set(1);
      model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUCECR.update(status,UVM_FRONTDOOR);
      addr = model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUCECR.get_address();
      //****************************************************************************
      // check intr pin  step-8 
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DiiInfo[idx].strRtlNamePrefix%> STEP_8: wait for correctable interrupt =1, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
      //****************************************************************************
      wait(m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 1)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt asserted"),UVM_NONE);
      end
      if(m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
      end
 
      //step-9 
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DiiInfo[idx].strRtlNamePrefix%> STEP_9: read System interrupt register DIIUUEIRx,check to make sure,only one bit corresponding to block is set , all other bit should be 0 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUUEIR.read(status, field_rd_data, UVM_FRONTDOOR);
       
      if(!field_rd_data)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DIIUUEIR value :%b",field_rd_data),UVM_MEDIUM)
      end
      else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DIIUUEIR value :%b",field_rd_data))
      end
      
  
      //step-10
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DiiInfo[idx].strRtlNamePrefix%> STEP_10: set *CESAR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
      ErrVld = 0;
      field_wr_data = ErrVld; 
      model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUCESAR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUCESAR.get_address();
      model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUCESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUCESR.get_address();
      //step-11
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DiiInfo[idx].strRtlNamePrefix%> STEP_11: read *CESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
      if(field_rd_data == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DIIUCESR_ErrVld value :%b DIIUCESR_ErrCountOverflow value :%b",addr,field_rd_data[0],field_rd_data[1]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DIIUCESR_ErrVld value :%b Expected :%b DIIUCESR_ErrCountOverflow value :%b Expected :%b",addr,field_rd_data[0],field_wr_data[0], field_rd_data[1], field_wr_data[1]));
      end

      //step-12
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DiiInfo[idx].strRtlNamePrefix%> STEP_12: wait for correctable interrupt =0, check uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
      wait(m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c == 0)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c  interrupt de-asserted"),UVM_NONE);
      end
      if((m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end

      //step-13
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DiiInfo[idx].strRtlNamePrefix%> STEP_13: read System interrupt register DIIUUEIR,check to make sure all at time: %t\n",$time),UVM_NONE)
      model.<%=obj.DiiInfo[idx].strRtlNamePrefix%>.DIIUUEIR.read(status,field_rd_data,UVM_FRONTDOOR);
      if(!field_rd_data)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("DIIUUEIR. value :%b",field_rd_data),UVM_MEDIUM)
      end
      else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("DIIUUEIR. value :%b",field_rd_data))
      end
      if((m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c | m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc ))begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_c or IRQ_uc interrupt should  not assert"));
      end
  <%} %>
<%} %>
<%for(var idx = 0; idx < obj.nDVEs; idx++){%>
      ///step-1
      field_wr_data = 0; 
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("\n<%=obj.DveInfo[idx].strRtlNamePrefix%> STEP_1: check uncorrectable pin should be at reset state  at time: %t \n", $time),UVM_NONE)
      if(m_irq_<%=obj.DveInfo[idx].strRtlNamePrefix%>_if.IRQ_uc )begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc interrupt should  not assert"));
      end
     //step-2  
     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DveInfo[idx].strRtlNamePrefix%> STEP_2: read register *UESR,it should be at reset state at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.get_address();
      ErrVld = 0;

      if(field_rd_data[0] == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h DVEUUESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h DVEUUESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
      end
   
      //************************************************************************************
      // set IntEn   step-3
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DveInfo[idx].strRtlNamePrefix%> STEP_3: set MemErrIntEn in UUEIR* at time: %t \n",$time),UVM_NONE)
      //************************************************************************************
      field_wr_data[2] = 1; 
      model.<%=obj.DveInfo[idx].strRtlNamePrefix%>.DVEUUEIR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.DveInfo[idx].strRtlNamePrefix%>.DVEUUEIR.get_address();
      field_wr_data = 0; 

     
      ///step-4
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DveInfo[idx].strRtlNamePrefix%> STEP_4: set *CESAR.ErrVld = 1 and ErrType = 0x2 (Native Interface Write Response Error) at time: %t \n",$time),UVM_NONE)

      ErrVld = 1;
      field_wr_data[0] = ErrVld; 
      model.<%=obj.DveInfo[idx].strRtlNamePrefix%>.DVEUUESAR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.DveInfo[idx].strRtlNamePrefix%>.DVEUUESAR.get_address();
      field_wr_data[9:4] = 0;   

      //****************************************************************************
      // check intr pin  step-5 
      //****************************************************************************
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DveInfo[idx].strRtlNamePrefix%> STEP_5: wait for uncorrectable interrupt pin at time: %t \n",$time),UVM_NONE)
      wait(m_irq_<%=obj.DveInfo[idx].strRtlNamePrefix%>_if.IRQ_uc == 1)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc  interrupt asserted"),UVM_NONE);
      end
     
     //step-6
     `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DveInfo[idx].strRtlNamePrefix%> STEP_6: read *CESR.ErrVld, check to make sure ErrVld = 1 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.get_address();

      if(field_rd_data[0] == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h DVEUUESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Read:addr = %0h DVEUUESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
      end

   
      //step-7 
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DveInfo[idx].strRtlNamePrefix%> STEP_7: set *UESR.ErrVld = 0 at time: %t \n",$time),UVM_NONE)
      ErrVld = 1;
      field_wr_data[0] = ErrVld; 
      model.<%=obj.DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.write(status,field_wr_data,UVM_FRONTDOOR);
      addr = model.<%=obj.DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.get_address();
      
      //step-8
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DveInfo[idx].strRtlNamePrefix%> STEP_8: wait for ucorrectable interrupt =0 at time: %t \n",$time),UVM_NONE)
      wait(m_irq_<%=obj.DveInfo[idx].strRtlNamePrefix%>_if.IRQ_uc == 0)begin
         `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("IRQ_uc  interrupt de-asserted"),UVM_NONE);
      end
      
      //step-9
      ErrVld = 0;
      `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("<%=obj.DveInfo[idx].strRtlNamePrefix%> STEP_9: read *UESR.ErrVld, check to make sure ErrVld = 0 at time: %t \n",$time),UVM_NONE)
      model.<%=obj.DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.read(status, field_rd_data, UVM_FRONTDOOR);
      addr = model.<%=obj.DveInfo[idx].strRtlNamePrefix%>.DVEUUESR.get_address();
      if(field_rd_data[0] == ErrVld)begin
        `uvm_info("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DVEUUESR_ErrVld value :%b",addr,field_rd_data[0]), UVM_NONE)
      end else begin
        `uvm_error("ncore_fsc_ralgen_err_intr_seq",$sformatf("Reg Write:addr = %0h DVEUUESR_ErrVld value :%b Expected :%b",addr,field_rd_data[0], ErrVld));
      end
<%} %>
endtask: body
endclass: ncore_fsc_ralgen_err_intr_seq
                                
//==================================================
class myChiUvmVirtualSequence extends uvm_sequence;
//==================================================

  `uvm_object_utils(myChiUvmVirtualSequence)

  `uvm_declare_p_sequencer(cdnChiUvmSequencer)

  function new(string name="myChiUvmVirtualSequence");
    super.new(name);
`ifdef UVM_VERSION
   // UVM-IEEE
   set_response_queue_error_report_enabled(0);
`else
   set_response_queue_error_report_disabled(1);
`endif
  endfunction // new

  virtual function void configSeq();
  endfunction : configSeq

  // ***************************************************************
  // Method : pre_body
  // Desc.  : Raise an objection to prevent premature simulation end
  // ***************************************************************
  virtual task pre_body();
`ifdef UVM_POST_VERSION_1_1
    var uvm_phase starting_phase = get_starting_phase();
`endif
    // configure the test
    configSeq();
    if (starting_phase != null)
      starting_phase.raise_objection(this,"seq not finished");
    #1000;
  endtask

  // ***************************************************************
  // Method : post_body
  // Desc.  : Drop the objection raised earlier
  // ***************************************************************
  virtual task post_body();
`ifdef UVM_POST_VERSION_1_1
    var uvm_phase starting_phase = get_starting_phase();
`endif
    if (starting_phase != null) begin
      starting_phase.drop_objection(this);
    end
  endtask

  // ***************************************************************
  // Method : store
  // This store task is first checking the cache line state of the given address.
  // If the line is invalid and the store is partial, it performs a ReadUnique transaction and merge the Store data.
  // If the line is invalid and the store is full line, it performs a MakeUnique transaction and update the line with the StoreData array.
  // If the line is in Shared state, it first issue a MakeUnique/CleanUnique Transaction to aquire line ownership and merge the Store data.
  // If the line is in Unique state, it performs a back-door write with the Store Data without any transactions on the bus.
  // Parameters:
  //    Rn: the Request node component to perform the store operation
  //    Address: <%=obj.Widths.Concerto.Ndp.Body.wAddr-1%> bit start address for the store operation
  //    NonSecure: The secure/non-secure attribute of the desire address.
  //    StoreData: The data byte array input to be stored.
  //    BE: (optional) Bit enable array input for the StoreData array.
  // ***************************************************************
  task store(cdnChiUvmAgent Rn, reg [43:0] Address, bit NonSecure, input reg [7:0] StoreData[] , input reg BE[] = '{64{1}});
	bit PartialStore = 0;
	reg [43:0] AlignedAddr;
	denaliChiCacheLineStateT State;
	reg [5:0] Offset;
	reg [7:0] ReadData [];
	reg ReadBE [];
	reg [7:0] AlignedStoreData [];
	reg AlignedBE [];
	integer CacheLineSize = 64;

	// You can replace the following line.
	// Instead of myChiTransaction, use your own class that extends denaliChiTransaction
	myChiTransaction ChiReq;

	uvm_sequence_item item;
	// Input validity checks
	if (StoreData.size() > CacheLineSize) begin
	  `uvm_fatal(get_type_name(), "store() task invalid input: StoreData array size is bigger than 64 elements.");
	end
	if (BE.size() > CacheLineSize) begin
	  `uvm_fatal(get_type_name(), "store() task invalid input: BE array size is bigger than 64 elements.");
    end
	if (BE.size() != 64 && StoreData.size() != BE.size()) begin
	  `uvm_fatal(get_type_name(), "store() task invalid input: StoreData array and BE array have different sizes.");
    end

	AlignedStoreData = new[CacheLineSize];
	AlignedBE = new[CacheLineSize];

	AlignedAddr = Address / CacheLineSize * CacheLineSize;
	Offset = Address - AlignedAddr;

	// aligning the input data and input BE to cache line boundaries
	for (int i=0; i<CacheLineSize ; i++) begin
	  if (i < StoreData.size()) begin
	    AlignedStoreData[(Offset+i)%CacheLineSize] = StoreData[i];
		AlignedBE[(Offset+i)%CacheLineSize] = BE[i];
		if (BE[i] == 0) begin
		  PartialStore = 1;
	    end
	  end
	  else begin
	    AlignedStoreData[(Offset+i)%CacheLineSize] = 0;
	    AlignedBE[(Offset+i)%CacheLineSize] = 0;
	    PartialStore = 1;
	  end
	end

    // Reading the current cache line state
    Rn.inst.cacheRead(AlignedAddr, State, ReadData, ReadBE, NonSecure);

    case (State)
      DENALI_CHI_CACHELINESTATE_Invalid: begin
		ChiReq = new;
		if (PartialStore) begin
		  `uvm_info(get_type_name(), "== store == Line is not in the cache for partial line store. Sending ReadUnique transaction", UVM_LOW);
		  `uvm_do_on_with(ChiReq, Rn.sequencer, {
		  				ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_ReadUnique;
		  				ChiReq.Addr == AlignedAddr;
		  				ChiReq.NonSecure == local::NonSecure;
		  });

		  // will wait for the ReadUnique to end.
		    get_response(item, ChiReq.get_transaction_id());

	        `uvm_info(get_type_name(), "== store == The ReadUnique was ended. Merging the data with the partially store data.", UVM_MEDIUM);

		  // Reading the cache line again after ReadUnique
		  Rn.inst.cacheRead(AlignedAddr, State, ReadData, ReadBE, NonSecure);

		  // Merging the read data with the partially store data.
          for (int i=0; i<CacheLineSize ; i++) begin
            if (AlignedBE[i]==0) begin
              AlignedStoreData[i] = ReadData[i];
              AlignedBE[i] = 1;
            end
          end
        end
        else begin
          `uvm_info(get_type_name(), "== store == Line is not in the cache for full line store. Sending MakeUnique transaction", UVM_LOW);
          `uvm_do_on_with(ChiReq, Rn.sequencer, {
                                  ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_MakeUnique;
                                  ChiReq.Addr == AlignedAddr;
                                  ChiReq.NonSecure == local::NonSecure;
                                  });
          // will wait for the MakeUnique to end.
          get_response(item, ChiReq.get_transaction_id());
        
          `uvm_info(get_type_name(), "== store == The MakeUnique was ended. Overriding the data with the full line store data.", UVM_MEDIUM);
        end

	    // Back-door write the store data to the cache
	    Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirty, AlignedStoreData, AlignedBE, NonSecure);
	  end

	  DENALI_CHI_CACHELINESTATE_SharedClean, DENALI_CHI_CACHELINESTATE_SharedDirty: begin
		ChiReq = new;
		if (PartialStore) begin
		  `uvm_info(get_type_name(), "== store == Line is in the cache with Shared state for partial line store. Sending CleanUnique transaction", UVM_LOW);
          `uvm_do_on_with(ChiReq, Rn.sequencer, {
                                  ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_CleanUnique;
                                  ChiReq.Addr == AlignedAddr;
                                  ChiReq.NonSecure == local::NonSecure;
                                  });
      
          // will wait for the CleanUnique to end.
          get_response(item, ChiReq.get_transaction_id());
          
          `uvm_info(get_type_name(), "== store == The CleanUnique was ended. Merging the existing data with the partially store data.", UVM_MEDIUM);
          
          // Merging the read data with the partially store data.
          for (int i=0; i<CacheLineSize ; i++) begin
            if (AlignedBE[i]==0) begin
              AlignedStoreData[i] = ReadData[i];
              AlignedBE[i] = 1;
            end
          end
        end
        else begin
          `uvm_info(get_type_name(), "== store == Line is in the cache with Shared state for full line store. Sending MakeUnique transaction", UVM_LOW);
          `uvm_do_on_with(ChiReq, Rn.sequencer, {
                                  ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_MakeUnique;
                                  ChiReq.Addr == AlignedAddr;
                                  ChiReq.NonSecure == local::NonSecure;
                                  });
          
          // will wait for the MakeUnique to end.
          get_response(item, ChiReq.get_transaction_id());
          
          `uvm_info(get_type_name(), "== store == The MakeUnique was ended. Overriding the data with the full line store data.", UVM_MEDIUM);
        end
      
        // Back-door write the store data to the cache
        Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirty, AlignedStoreData, AlignedBE, NonSecure);
      end

	  // if the data is already in the cache in unique FULL state
	  DENALI_CHI_CACHELINESTATE_UniqueClean, DENALI_CHI_CACHELINESTATE_UniqueDirty: begin
        `uvm_info(get_type_name(), "== store == Line is in the cache with Unique state. No need to send any transaction", UVM_LOW);
        if (PartialStore) begin
          // Merging the read data with the partially store data.
          for (int i=0; i<CacheLineSize ; i++) begin
            if (AlignedBE[i]==0) begin
              AlignedStoreData[i] = ReadData[i];
              AlignedBE[i] = 1;
            end
          end
        end
        // Back-door write the store data to the cache
        Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirty, AlignedStoreData, AlignedBE, NonSecure);
      end

      DENALI_CHI_CACHELINESTATE_UniqueDirtyPartial: begin
        `uvm_info(get_type_name(), "== store == Line is in the cache with UniqueDirtyPartial state. No need to send any transaction", UVM_LOW);
        if (PartialStore) begin
          PartialStore = 0;
          for (int i=0; i<CacheLineSize ; i++) begin
            if (AlignedBE[i]==0 && ReadBE[i]==1) begin
              AlignedStoreData[i] = ReadData[i];
              AlignedBE[i] = 1;
            end
			else if (AlignedBE[i]==0) begin
			  PartialStore = 1;
		    end
		  end
		end
        if (PartialStore) begin
          // Back-door write the partial store data to the cache
          Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirtyPartial, AlignedStoreData, AlignedBE, NonSecure);
        end
	    else begin
	      // Back-door write the store data to the cache
	      Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirty, AlignedStoreData, AlignedBE, NonSecure);
	    end
	  end

	  DENALI_CHI_CACHELINESTATE_UniqueCleanEmpty: begin
		`uvm_info(get_type_name(), "== store == Line is in the cache with Unique Empty state. No need to send any transaction", UVM_LOW);;
		if (PartialStore) begin
		  // Back-door write the partial store data to the cache
		  Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirtyPartial, AlignedStoreData, AlignedBE, NonSecure);
		end
		else begin
		  // Back-door write the store data to the cache
		  Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirty, AlignedStoreData, AlignedBE, NonSecure);
		end
	  end
	endcase

	`uvm_info(get_type_name(), " == store == Store operation ended.", UVM_LOW);
  endtask : store

  // ***************************************************************
  // Method : load
  // This load task is checking the cache line state of the given Address. If it is invalid, it performs
  // a ReadShared transaction to read the data and put the result in the LoadData array.
  // If the cache line state is valid and full, it will return the current data from the cache.
  // If the cache line state is valid and partial/empty, it will perform  a ReadUnique transaction
  // and merge the read data with the valid cache data.
  // Parameters:
  //	Rn: the Request node component to perform the load operation
  //    Address: <%=obj.Widths.Concerto.Ndp.Body.wAddr-1%> bit start address for the load operation
  //    NonSecure: The secure/non-secure attribute of the desire address.
  //    LoadData: Reference to the read cache line's data byte array.
  // The LoadData will always be full line (64 bytes) and aligned to cache line boundaries.
  // ***************************************************************
  task load(cdnChiUvmAgent Rn, reg [43:0] Address, bit NonSecure, ref reg [7:0] LoadData []);
    reg [43:0] AlignedAddr;
    reg BE[];
    reg BE2[];
    reg [7:0] MergedData[];
    denaliChiCacheLineStateT State;
    
    // You can replace the following line.
    // Instead of myChiTransaction, use your own class that extends denaliChiTransaction
    myChiTransaction ChiReq;
    
    uvm_sequence_item item;
    
    integer CacheLineSize = 64, status;
    
    AlignedAddr = Address / CacheLineSize * CacheLineSize;
    LoadData = new[CacheLineSize];
    
    ChiReq = new();
    
    // Reading the current cache line
    Rn.inst.cacheRead(AlignedAddr, State, LoadData, BE, NonSecure);

	case (State)
	  DENALI_CHI_CACHELINESTATE_Invalid: begin
	    `uvm_info(get_type_name(), "== load == data is not in the cache. Sending ReadShared transaction", UVM_LOW);
        `uvm_do_on_with(ChiReq, Rn.sequencer, {
                                ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_ReadShared;
                                ChiReq.Addr == AlignedAddr;
                                ChiReq.NonSecure == local::NonSecure;
                                });

        // will wait for the ReadShared to end.
        get_response(item, ChiReq.get_transaction_id());
        
        `uvm_info(get_type_name(), "== load == The ReadShared was ended and now the cache line is valid", UVM_MEDIUM);
        // Reading the cache line again after ReadShared
        Rn.inst.cacheRead(AlignedAddr, State, LoadData, BE, NonSecure);
      end

      // if the data is already in the cache, this data will be returned.
      // The data was already read above, so nothing to do
      DENALI_CHI_CACHELINESTATE_UniqueClean, DENALI_CHI_CACHELINESTATE_UniqueDirty,
      DENALI_CHI_CACHELINESTATE_SharedClean, DENALI_CHI_CACHELINESTATE_SharedDirty: begin
        `uvm_info(get_type_name(), "== load == data is already in the cache hence no READ transaction will be issued.", UVM_LOW);
      end

      DENALI_CHI_CACHELINESTATE_UniqueDirtyPartial: begin
        `uvm_info(get_type_name(), "== load == data is partially dirty in the cache. Need to read the full line again", UVM_MEDIUM);
        
        `uvm_do_on_with(ChiReq, Rn.sequencer, {
                                ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_ReadUnique;
                                ChiReq.Addr == AlignedAddr;
                                ChiReq.NonSecure == local::NonSecure;
                                });

        // will wait for the ReadUnique to end.
        get_response(item, ChiReq.get_transaction_id());
        
        `uvm_info(get_type_name(), "== load == The ReadUnique was ended. Merging the data with the partially dirty data.", UVM_MEDIUM);
        
        // Reading the cache line again after ReadUnique
        Rn.inst.cacheRead(AlignedAddr, State, MergedData, BE2, NonSecure);
        
        // Merging the read data with the partially existing data.
        for (int i=0; i<LoadData.size(); i++) begin
          if (BE[i] == 1'b0) begin
            LoadData[i] = MergedData[i];
            BE[i] = 1'b1;
          end
        end
         
        // Writing the full line back to the cache with UniqueDirty state
        Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirty, LoadData, BE, NonSecure);
      end

      DENALI_CHI_CACHELINESTATE_UniqueCleanEmpty: begin
        `uvm_info(get_type_name(), "== load == Line is in the cache with UniqueCleanEmpty state. Sending ReadUnique transaction.", UVM_LOW);
        
        `uvm_do_on_with(ChiReq, Rn.sequencer, {
                                ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_ReadUnique;
                                ChiReq.Addr == AlignedAddr;
                                ChiReq.NonSecure == local::NonSecure;
                                });
      
        // will wait for the ReadUnique to end.
        get_response(item, ChiReq.get_transaction_id());
        
        `uvm_info(get_type_name(), "== load == The ReadUnique was ended and now the cache line is UniqueClean state", UVM_MEDIUM);
        
        // Reading the cache line again after ReadUnique
        Rn.inst.cacheRead(AlignedAddr, State, LoadData, BE, NonSecure);
      end
    endcase

	`uvm_info(get_type_name(), " == load == load operation ended.", UVM_LOW);

  endtask : load

endclass

//==================================================
class readAfterWrite extends myChiUvmVirtualSequence;
//==================================================

  rand bit[<%=obj.wSysAddr-1%>:0] start_addr = 'h0;

  readAfterWriteSeq seq;

  `uvm_object_utils_begin(readAfterWrite)
    `uvm_field_object(seq, UVM_ALL_ON)
  `uvm_object_utils_end

  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "readAfterWrite");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Virtual sequence readAfterWrite started", UVM_LOW);

    // Send multiple transactions
    for (int i=0; i<10; i++) begin
      `uvm_do_on_with(seq, p_sequencer, {
				           seq.address == start_addr + 'h40*i;
				           seq.txnId == i;
			          });
    end

    `uvm_info(get_type_name(), "Finished body of readAfterWrite", UVM_MEDIUM);

  endtask

endclass : readAfterWrite

//==================================================
class chi_base_seq extends cdnChiUvmSequence;
//==================================================

  bit[<%=obj.wSysAddr-1%>:0] start_addr = 'h0;
  int txnid,id_width,seq_len,cnt,cnt1;
  string command;
  int txn_no,is_finished,mem_region,aiu_id ;
  int master_id,transaction_delay = 0;
  int latency[],min_latency,max_latency,avg_latency,total,transaction;
  int cache_value = 'h0;
  myChiTransaction trans;

  uvm_sequence_item item;
  
  
  `uvm_object_utils(chi_base_seq)
  
  `uvm_declare_p_sequencer(cdnChiUvmSequencer)
  
  function new(string name="chi_base_seq");
  	super.new(name);
  endfunction // new

  virtual task body();
/** BANDWIDTH_TEST time variable  */
  time  	seq_end_time1;
  shortreal  	bandwidth1, latency1;
  time  		begin_time;
  time  		end_time,latency[],min_latency,max_latency;
 
    trans = new();
    latency = new[seq_len];
   

    `uvm_info(get_type_name(), "Virtual sequence chi_base_seq started", UVM_MEDIUM);

      //fork
          if(command =="READNOSNOOP")begin
	    `uvm_do_with(trans,  {
	    		ReqOpCode == DENALI_CHI_REQOPCODE_ReadNoSnp;
	    		TxnID == txn_no%id_width;
	    		Addr == start_addr ;
	    		Order == 0 ;
	    		NonSecure == 0 ;
	    		QoS == 0 ;
	    		MemAttr == 1 ;
	    		ExpCompAck == 0 ;
	    		Size == DENALI_CHI_SIZE_FULLLINE;
	    		Type == DENALI_CHI_TR_RequestTransaction;
	    		DynReqFlitDelay == 0;
	    	}) 
          end
          if(command =="READONCE")begin
	    `uvm_do_with(trans,  {
	    		ReqOpCode == DENALI_CHI_REQOPCODE_ReadOnce;
	    		TxnID == txn_no%id_width;
	    		Addr == start_addr;
	    		Order == 0 ;
	    		NonSecure == 0 ;
	    		QoS == 0 ;
	    		MemAttr == 5 ;
	    		Size == DENALI_CHI_SIZE_FULLLINE;
	    		//Type == DENALI_CHI_TR_RequestTransaction;
	    	}) 
          end
          if(command =="READUNIQUE")begin
	    `uvm_do_with(trans,  {
	    		ReqOpCode == DENALI_CHI_REQOPCODE_ReadUnique;
	    		TxnID == txn_no%id_width;
	    		Addr == start_addr ;
	    		Order == 0 ;
	    		NonSecure == 0 ;
	    		QoS == 0 ;
	    		MemAttr == 'hd ;
	    		Size == DENALI_CHI_SIZE_FULLLINE;
	    		//Type == DENALI_CHI_TR_RequestTransaction;
	    	}) 
          end
          if(command =="WRITENOSNOOP")begin
	    `uvm_do_with(trans,  {
	    		ReqOpCode == DENALI_CHI_REQOPCODE_WriteNoSnpPtl;
	    		TxnID == txn_no%id_width;
	    		Addr == start_addr ;
	    		Order == 0 ;
	    		NonSecure == 0 ;
	    		QoS == 0 ;
	    		MemAttr == DENALI_CHI_V8MEMATTR_DEVICE_nGnRE ;
	    		ExpCompAck == 0 ;
	    		Size == DENALI_CHI_SIZE_FULLLINE;
	    	}) 
          end
          if(command =="WRITEUNIQUE")begin
	    `uvm_do_with(trans,  {
	    		ReqOpCode == DENALI_CHI_REQOPCODE_WriteUniqueFull;
	    		TxnID == txn_no%id_width;
	    		Addr == start_addr ;
	    		Order == 0 ;
	    		NonSecure == 0 ;
	    		QoS == 0 ;
	    		MemAttr == (cache_value[4] ? 'hd : 'h5 ) ;
	    		//MemAttr == 5 ;
	    		Size == DENALI_CHI_SIZE_FULLLINE;
	    		ExpCompAck == 0 ;
	    	}) 
          end

          //if(txn_no == 0)
          //  seq_begin_time1 =  $time;

          get_response(item, trans.get_transaction_id());
    

// add for BANDWIDTH_TEST
      begin_time  =trans.StartTime; 
      if(command =="READONCE" || command =="READNOSNOOP" || command =="READUNIQUE" )end_time  = trans.CompDataEndTime; 
      if(command =="WRITENOSNOOP" || command =="WRITEUNIQUE") end_time = trans.WriteDataEndTime ; 
     
      latency_new[txn_no][aiu_id]["CHI"] = (end_time - begin_time) ; 
      if(txn_no==0)seq_begin_time1 =  trans.StartTime;
   if(is_finished==1)begin
    latency = new[seq_len];
    for(int k=0; k<seq_len;k++) begin
      latency[k] = latency_new[k][aiu_id]["CHI"] ; 
    end
    min_latency =  latency[0];
    max_latency =  latency[0];
    for(int i=0; i<seq_len;i++) begin
        if(min_latency > latency[i])
          min_latency =  latency[i];
        if(max_latency < latency[i])
          max_latency =  latency[i];
        total = total + latency[i];
    end
    avg_latency = total / seq_len ;
    
    seq_end_time1   =  $time;
    bandwidth1 =seq_len*64*1000000/(seq_end_time1-seq_begin_time1);
    latency1   = (seq_end_time1-seq_begin_time1)/seq_len;
    if($test$plusargs("performance_test"))begin
       $display("===============================================================");
       $display("Performance Results");
       $display("===============================================================");
       $display("BANDWIDTH CAIU%0d to Memory Region %0d  %s :%.2f MB/s min_latency=%0d ps max_latency=%0d ps avg_latency=%0d ps", master_id,mem_region,command,bandwidth1,min_latency,max_latency,avg_latency);
    end
    end
    `uvm_info(get_type_name(), "Finished body of chi_base_seq", UVM_MEDIUM);

  endtask

endclass : chi_base_seq


//==================================================
class axi_base_seq extends cdnAxiUvmSequence;
//==================================================

  bit[<%=obj.wSysAddr-1%>:0] start_addr = 'h0;
  int size,id_width,seq_len,cnt,cnt1,resp,transaction,len,len1;
  int cache_value = 'h0;
  string command,protocol;
  int txn_no,is_finished,mem_region,aiu_id = 0;
  int master_id,transaction_delay = 0;
  int latency[],min_latency,max_latency,avg_latency,total;
  ncore_env env;
  int diff;

  uvm_sequence_item item;

  `uvm_object_utils(axi_base_seq)

  `uvm_declare_p_sequencer(cdnAxiUvmSequencer)

  function new(string name="axi_base_seq");
      super.new(name);
  endfunction // new

  virtual task body();
    denaliCdn_axiTransaction trans;

/** BANDWIDTH_TEST time variable  */
    time  	seq_end_time1,begin_time,end_time;
    shortreal  	bandwidth1, bandwidth2, bandwidth3, bandwidth4,latency1;
    super.body();

    trans = new();
    latency = new[seq_len];


<% if(has_ace == 1){ %>
    if(command =="READUNIQUE" && transaction == 1 && protocol =="ACE")begin
      p_sequencer.pAgent.cfg.memory_segments = {};
      p_sequencer.pAgent.cfg.addToMemorySegments(addr_trans_mgr_pkg::addrMgrConst::memregions_info[0].start_addr,addr_trans_mgr_pkg::addrMgrConst::memregions_info[0].end_addr, DENALI_CDN_AXI_DOMAIN_OUTER);
      p_sequencer.pAgent.reconfigure(p_sequencer.pAgent.cfg);

      env.m_aiuMstAgentPassive0.cfg.memory_segments = {};
      env.m_aiuMstAgentPassive0.cfg.addToMemorySegments(addr_trans_mgr_pkg::addrMgrConst::memregions_info[0].start_addr,addr_trans_mgr_pkg::addrMgrConst::memregions_info[0].end_addr, DENALI_CDN_AXI_DOMAIN_OUTER);
      env.m_aiuMstAgentPassive0.reconfigure(env.m_aiuMstAgentPassive0.cfg);
    end
<% } %>


              if(command =="READNOSNOOP" || (command =="READONCE" && protocol == "AXI4" && !transaction ))begin
	        `uvm_do_with(trans, {
                             Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	                     StartAddress == start_addr ;
    	                     Domain == DENALI_CDN_AXI_DOMAIN_NON_SHAREABLE;
    	                     Size == size + 1;
    	                     Length == (diff ? len1 : len );
    	                     Kind inside {DENALI_CDN_AXI_BURSTKIND_INCR};
    	                     Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	                     DataInstr == DENALI_CDN_AXI_FETCHKIND_DATA;
                             }); 
              end
              if( command =="READONCE" && protocol == "AXI4" && transaction == 1 )begin
	        `uvm_do_with(trans, {
                             Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	                     StartAddress == start_addr ;
    	                     Domain == DENALI_CDN_AXI_DOMAIN_NON_SHAREABLE;
    	                     Size == size + 1;
    	                     Length == (diff ? len1 : len );
    	                     Kind inside {DENALI_CDN_AXI_BURSTKIND_INCR};
    	                     Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	                     DataInstr == DENALI_CDN_AXI_FETCHKIND_DATA;
    	                     Privileged == DENALI_CDN_AXI_PRIVILEGEDMODE_NORMAL;
    	                     Bufferable == DENALI_CDN_AXI_BUFFERMODE_BUFFERABLE;
    	                     Cacheable == DENALI_CDN_AXI_CACHEMODE_CACHEABLE;
    	                     ReadAllocate == DENALI_CDN_AXI_READALLOCATE_NO_READ_ALLOCATE;
    	                     WriteAllocate == DENALI_CDN_AXI_WRITEALLOCATE_NO_WRITE_ALLOCATE;
                             }); 
              end
              if(command =="READONCE" && protocol != "AXI4" )begin
	        `uvm_do_with(trans, {
    	                     ReadSnoop == DENALI_CDN_AXI_READSNOOP_ReadOnce;
    	                     StartAddress == start_addr ;
    	                     Domain inside {DENALI_CDN_AXI_DOMAIN_OUTER};
    	                     Size == size +1 ;
    	                     Length == (diff ? len1 : len );
    	                     Kind inside {DENALI_CDN_AXI_BURSTKIND_INCR};
    	                     Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	                     DataInstr == DENALI_CDN_AXI_FETCHKIND_DATA;
    	                     Privileged == DENALI_CDN_AXI_PRIVILEGEDMODE_NORMAL;
    	                     Bufferable == DENALI_CDN_AXI_BUFFERMODE_NON_BUFFERABLE;
    	                     Cacheable == DENALI_CDN_AXI_CACHEMODE_CACHEABLE;
    	                     ReadAllocate == DENALI_CDN_AXI_READALLOCATE_READ_ALLOCATE;

                             }); 
              end
              if(command =="READUNIQUE" && protocol != "AXI4" )begin
	        `uvm_do_with(trans, {
    	                     ReadSnoop == DENALI_CDN_AXI_READSNOOP_ReadUnique;
    	                     StartAddress == start_addr ;
    	                     Domain inside {DENALI_CDN_AXI_DOMAIN_OUTER};
    	                     Size == size + 1;
    	                     Length == len;
    	                     Kind inside {DENALI_CDN_AXI_BURSTKIND_INCR};
    	                     Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	                     DataInstr == DENALI_CDN_AXI_FETCHKIND_DATA;
    	                     Privileged == DENALI_CDN_AXI_PRIVILEGEDMODE_NORMAL;
    	                     Bufferable == DENALI_CDN_AXI_BUFFERMODE_BUFFERABLE;
    	                     Cacheable == DENALI_CDN_AXI_CACHEMODE_CACHEABLE;
    	                     ReadAllocate == DENALI_CDN_AXI_READALLOCATE_NO_READ_ALLOCATE;
    	                     //WriteAllocate == DENALI_CDN_AXI_WRITEALLOCATE_NO_WRITE_ALLOCATE;
    	                     Barrier == DENALI_CDN_AXI_BARRIER_NORMAL_RESPECTING;

                             }); 
              end
              if(command =="WRITENOSNOOP" || (command =="WRITEUNIQUE" && protocol == "AXI4"))begin
	        `uvm_do_with(trans,  {
    	                     Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
    	                     StartAddress == start_addr;
    	                     Domain == DENALI_CDN_AXI_DOMAIN_NON_SHAREABLE;
    	                     Size == size + 1;
    	                     Length == (diff ? len1 : len );
    	                     Kind inside { DENALI_CDN_AXI_BURSTKIND_INCR };
    	                     Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	                     WriteAllocate == (cache_value[2] ? DENALI_CDN_AXI_WRITEALLOCATE_WRITE_ALLOCATE :DENALI_CDN_AXI_WRITEALLOCATE_NO_WRITE_ALLOCATE ) ;
                             }); 
              end
              if(command =="WRITEUNIQUE" && protocol != "AXI4")begin
	        `uvm_do_with(trans, { 
			     WriteSnoop == DENALI_CDN_AXI_WRITESNOOP_WriteUnique;
    	                     StartAddress == start_addr ;
    	                     Domain inside {DENALI_CDN_AXI_DOMAIN_OUTER,DENALI_CDN_AXI_DOMAIN_INNER};
    	                     Size == size + 1;
    	                     Length == (diff ? len1 : len );
    	                     Kind inside {DENALI_CDN_AXI_BURSTKIND_INCR};
    	                     Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	                     WriteAllocate == (cache_value[2] ? DENALI_CDN_AXI_WRITEALLOCATE_WRITE_ALLOCATE :DENALI_CDN_AXI_WRITEALLOCATE_NO_WRITE_ALLOCATE) ;
                             }); 
              end


              get_response(item, trans.get_transaction_id());


      begin_time  = trans.StartTime; 
      end_time  = trans.EndTime; 
      if(txn_no == 0) seq_begin_time1 =  trans.StartTime;
      //latency[i] = (end_time - begin_time) ; 
      latency_new[txn_no][aiu_id][protocol] = (end_time - begin_time) ; 
   if(is_finished==1)begin
    latency = new[seq_len];
    for(int k=0; k<seq_len;k++) begin
      latency[k] = latency_new[k][aiu_id][protocol] ; 
    end
    min_latency =  latency[0];
    max_latency =  latency[0];
    for(int i=0; i<seq_len;i++) begin
        if(min_latency > latency[i])
          min_latency =  latency[i];
        if(max_latency < latency[i])
          max_latency =  latency[i];
        total = total + latency[i];
    end
    avg_latency = total / seq_len ;

// add for BANDWIDTH_TEST
    seq_end_time1   =  $time;
    bandwidth1 =(seq_len*64*1000000)/((seq_end_time1-seq_begin_time1));
    latency1   = (seq_end_time1-seq_begin_time1)/seq_len;
    
    if($test$plusargs("performance_test"))begin
       $display("===============================================================");
       $display("Performance Results");
       $display("===============================================================");
       $display("BANDWIDTH %s %0d to Memory Region %0d  %s :%.2f MB/s min_latency=%0d ps max_latency=%0d ps avg_latency=%0d ps",((protocol== "ACE") ? "CAIU" : "NCAIU"), master_id,mem_region,command,bandwidth1,min_latency,max_latency,avg_latency);
    end
end
    `uvm_info(get_type_name(), "Finished body of axi_base_seq", UVM_MEDIUM);

  endtask

endclass : axi_base_seq
