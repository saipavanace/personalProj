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
       if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') ){
         aceaiu_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
         has_ace  = 1 ;
       } 

   } 

   nGPRA = obj.AiuInfo[0].nGPRA;
   nACE = aceaiu_idx;
   nCHI = chiaiu_idx;

%>

class ncore_base_vseq extends uvm_sequence;
  `uvm_object_utils(ncore_base_vseq)
  
  addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t csrq[$];
  <%var qidx=0;%>
  ral_sys_ncore model;
  bit[31:0] data;
  uvm_status_e status;
  bit[<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] addr;
  int aiu_dmi_connect[];
  int aiu_dii_connect[];
  int aiu_dce_connect[];
  int dce_dmi_connect[];
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
  int dce[];
  int dmi[];
  int dce_dmi[];
  int dii[];
  bit [7:0] nAIUs; 
  bit [5:0] nDCEs; 
  bit [5:0] nDMIs; 
  bit [5:0] nDIIs; 
  bit       nDVEs;
  bit [7:0] ioaiu_rpn; // Assuming expected value to be 0
  bit [3:0] ioaiu_nrri; // Assuming expected value to be 0
  int timeout;
  int poll_till;
  int Credit_for_Dce;
  int Credit_for_Dmi;
  int Credit_for_Dii;
  
  <%for(var idx = 0; idx < obj.nCHIs; idx++) { %>
      svt_chi_link_service_activate_sequence link_activate_seq<%=idx%>;
      svt_chi_protocol_service_coherency_entry_sequence chi_sysco_connect_seq<%=idx%>;
      svt_chi_rn_transaction_sequencer rn_xact_seqr<%=idx%>;
      svt_chi_link_service_sequencer link_seqr<%=idx%>;
      svt_chi_protocol_service_sequencer  chi_sysco_seqr<%=idx%>;
  <%}%>
  <%let aidx=0;%>
  <%for(let idx = 0; idx < obj.nAIUs; idx++) { %>
      <%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
          <%for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
              svt_axi_master_sequencer axi_xact_seqr<%=aidx%>;
              svt_axi_service_coherency_entry_sequence ioaiu_sysco_connect_seq<%=aidx%>;
              svt_axi_service_sequencer axi_sysco_seqr<%=aidx%>;
              <%aidx++;%>
          <%}%>
      <%}%>
  <%}%>
  
  function new(string name = "ncore_base_vseq");
    super.new(name);
     void'($value$plusargs("Credit_for_Dce=%0d",Credit_for_Dce));
     void'($value$plusargs("Credit_for_Dmi=%0d",Credit_for_Dmi));
     void'($value$plusargs("Credit_for_Dii=%0d",Credit_for_Dii));
  endfunction: new

  virtual task pre_body();
    this.csrq = addr_trans_mgr_pkg::addrMgrConst::get_all_gpra();
  endtask: pre_body

  task compare_act_exp_skidbuf(int act_skidbuf[string][],int exp_skidbuf[string][],string target_type,int id);

    if(exp_skidbuf[target_type][id]!= act_skidbuf[target_type][id]) begin
        `uvm_error("ncore_init_boot_seq",$sformatf("SKIDBUF compare exp_skidbuf[target_type][%0d] %0d != act_skidbuf[target_type][%0d] %0d",id,exp_skidbuf[target_type][id],id,act_skidbuf[target_type][id]))
    end else begin
        `uvm_info("ncore_init_boot_seq",$sformatf("SKIDBUF compare target_type %0s id %0d skidbuf_info %0d",target_type,id,exp_skidbuf[target_type][id] ),UVM_NONE)
    end

  endtask
  
  virtual task body();
    super.body();
    $cast(model, this.model);
    #1;
    run_boot_sequence();
  endtask: body
  
  virtual task run_boot_sequence();
    
    <% var fidx=0;%>
    <%for(var idx = 0; idx < obj.nAIUs; idx++){%>
        <%if((obj.AiuInfo[idx].strRtlNamePrefix== "caiu0")){%>
            <%for(var pidx=0;pidx < Object.keys(obj.AiuInfo[idx].csr.spaceBlock[0].registers).length; pidx++){%>
                <%if(obj.AiuInfo[idx].csr.spaceBlock[0].registers[pidx].name == "CAIUIDR") { %>
                    <%fidx=1;%>
                <%}%>
            <%}%>
        <%}%>
    <%}%>

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
    <%for(var idx = 0; idx < obj.nAIUs; idx++) {%>
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
            data[1]     = csrq[<%=pidx%>].order.readid;
            data[2]   = csrq[<%=pidx%>].order.writeid;
            data[4:3]   = csrq[<%=pidx%>].order.policy;
            model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRAR<%=pidx%>.write(status, data[31:0]);
            addr = model.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRAR<%=pidx%>.get_address();
            `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRAR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
        <%}%>

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
    if(csrq[<%=pidx%>].unit == addr_trans_mgr_pkg::addrMgrConst::DII) begin
        data[5]   = 1'b1;
    end
    //data[4:0]   = csrq[<%=pidx%>].order;
    data[1]     = csrq[<%=pidx%>].order.readid;
    data[2]   = csrq[<%=pidx%>].order.writeid;
    data[4:3]   = csrq[<%=pidx%>].order.policy;
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
    //data[4:0]   = csrq[<%=pidx%>].order;
    data[1]     = csrq[<%=pidx%>].order.readid;
    data[2]   = csrq[<%=pidx%>].order.writeid;
    data[4:3]   = csrq[<%=pidx%>].order.policy;
    model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUGPRAR<%=pidx%>.write(status, data[31:0]);
    addr = model.<%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUGPRAR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=obj.DceInfo[idx].strRtlNamePrefix%>.DCEUGPRAR<%=pidx%>  = 0x%0h", addr, data), UVM_NONE)

     <%}%>

    //DCEUAMIGR
    data = 32'h0;
    data[4:0]={addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs,1'b1};
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
      act_cmd_skidbuf_arb["DCE"][<%=idx%>]=data[8:0];
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
      act_mrd_skidbuf_arb["DMI"][<%=idx%>]=data[8:0];
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
      act_cmd_skidbuf_arb["DMI"][<%=idx%>]=data[8:0];
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
      act_cmd_skidbuf_arb["DII"][<%=idx%>]=data[8:0];
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
    if ($test$plusargs("override_caiuccr")) begin
        data[4:0]   = Credit_for_Dce;
        data[12:8]  = Credit_for_Dmi;
        data[20:16] = Credit_for_Dii;
    end else begin
        data[4:0]   = Credit_for_Cmd[<%=idx%>][DceIds[<%=j%>]];
        data[12:8]  = Credit_for_Cmd[<%=idx%>][DmiIds[<%=j%>]];
        data[20:16] = Credit_for_Cmd[<%=idx%>][DiiIds[<%=j%>]];
    end
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
    if ($test$plusargs("override_xaiuccr")) begin
        data[4:0]   = Credit_for_Dce;
        data[12:8]  = Credit_for_Dmi;
        data[20:16] = Credit_for_Dii;
    end else begin
        data[4:0]   = Credit_for_Cmd[<%=idx%>][DceIds[<%=j%>]];
        data[12:8]  = Credit_for_Cmd[<%=idx%>][DmiIds[<%=j%>]];
        data[20:16] = Credit_for_Cmd[<%=idx%>][DiiIds[<%=j%>]];
    end
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
    if ($test$plusargs("override_xaiuccr")) begin
        data[4:0]   = Credit_for_Dce;
        data[12:8]  = Credit_for_Dmi;
        data[20:16] = Credit_for_Dii;
    end else begin
        data[4:0]   = Credit_for_Cmd[<%=idx%>][DceIds[<%=j%>]];
        data[12:8]  = Credit_for_Cmd[<%=idx%>][DmiIds[<%=j%>]];
        data[20:16] = Credit_for_Cmd[<%=idx%>][DiiIds[<%=j%>]];
    end
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
    if ($test$plusargs("override_decuccr")) begin
        data[4:0]   = Credit_for_Dce;
    end else begin
        data[4:0]   = Credit_for_Mrd[DceIds[<%=idx%>]][DmiIds[<%=j%>]];
    end
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
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&& (obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')  && ((obj.AiuInfo[idx].fnNativeInterface == 'ACE'|| obj.AiuInfo[idx].fnNativeInterface == 'ACE5' )|| (((obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E') ) && (obj.AiuInfo[idx].cmpInfo.nDvmSnpInFlight > 0)) || ((obj.AiuInfo[idx].fnNativeInterface == 'AXI4'|| obj.AiuInfo[idx].fnNativeInterface == 'AXI5') && obj.AiuInfo[idx].useCache == 1 ))) { 
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
    if((!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))) && ((obj.AiuInfo[idx].fnNativeInterface == 'ACE'|| obj.AiuInfo[idx].fnNativeInterface == 'ACE5')|| (((obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) && (obj.AiuInfo[idx].cmpInfo.nDvmSnpInFlight > 0)) || ((obj.AiuInfo[idx].fnNativeInterface == 'AXI4' || obj.AiuInfo[idx].fnNativeInterface == 'AXI5') && obj.AiuInfo[idx].useCache == 1 ) || ((obj.AiuInfo[idx].fnNativeInterface == 'AXI5') && obj.AiuInfo[idx].useCache == 0 && obj.AiuInfo[idx].orderedWriteObservation == true) || ((obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E') && obj.AiuInfo[idx].orderedWriteObservation == true))) { 
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

<% for(var idx = 0; idx < obj.nAIUs; idx++) { if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&& (obj.AiuInfo[idx].fnNativeInterface != 'CHI-E') && (obj.AiuInfo[idx].fnNativeInterface != 'ACE' || obj.AiuInfo[idx].fnNativeInterface != 'ACE5' )) { for(var pidx=0;pidx < Object.keys(obj.AiuInfo[idx].csr.spaceBlock[0].registers).length; pidx++) { if(obj.AiuInfo[idx].csr.spaceBlock[0].registers[pidx].name == "XAIUPCISR") { %>
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

  endtask: run_boot_sequence

endclass: ncore_base_vseq

