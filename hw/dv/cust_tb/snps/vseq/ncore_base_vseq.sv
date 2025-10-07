<%const chipletObj = obj.lib.getAllChipletRefs();%>

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

for(let i=0;i<obj.chiplets.length;i+=1){
   for(var pidx = 0; pidx < chipletObj[i].nAIUs; pidx++) {
       if((chipletObj[i].AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(chipletObj[i].AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
       _child_blk[pidx]   = 'chiaiu';
       chiaiu_idx++;
       if(chipletObj[i].AiuInfo[pidx].fnNativeInterface == 'CHI-B') {
        has_chib  = 1;
       }
       if(chipletObj[i].AiuInfo[pidx].fnNativeInterface == 'CHI-E') {
        has_chie  = 1;
       }
       } else {
       _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
       _child_blk[pidx]   = 'ioaiu';
       ioaiu_idx += chipletObj[i].AiuInfo[pidx].nNativeInterfacePorts;
       }
       if((chipletObj[i].AiuInfo[pidx].fnNativeInterface == 'ACE') || (chipletObj[i].AiuInfo[pidx].fnNativeInterface == 'ACE5') ){
         aceaiu_idx += chipletObj[i].AiuInfo[pidx].nNativeInterfacePorts;
         has_ace  = 1 ;
       } 

   } 

   nGPRA = chipletObj[i].AiuInfo[0].nGPRA;
   nACE = aceaiu_idx;
   nCHI = chiaiu_idx;
   } 

%>

class ncore_base_vseq extends uvm_sequence;
  `uvm_object_utils(ncore_base_vseq)
  
  //ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];
  mem_agent ma;
  <%var qidx=0;%>
  bit[31:0] data;
  uvm_status_e status;
  bit[<%=chipletObj[0].Widths.Concerto.Ndp.Body.wAddr-1%>:0] addr;
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
  ral_sys_ncore model;
  mem_info_t csrq[$];
  int index;

  <% for (let i = 0; i < chipletObj.length; i++) { %>
      //bit[<%=chipletObj[i].Widths.Concerto.Ndp.Body.wAddr-1%>:0] addr;
  <% } %>
    
  <% for (let i = 0; i < chipletObj.length; i++) { %>
    <%for(var idx = 0; idx < chipletObj[i].nCHIs; idx++) { %>
        svt_chi_link_service_activate_sequence link_activate_seq<%=i%>_<%=idx%>;
        svt_chi_protocol_service_coherency_entry_sequence chi_sysco_connect_seq<%=i%>_<%=idx%>;
        svt_chi_rn_transaction_sequencer rn_xact_seqr<%=i%>_<%=idx%>;
        svt_chi_link_service_sequencer link_seqr<%=i%>_<%=idx%>;
        svt_chi_protocol_service_sequencer  chi_sysco_seqr<%=i%>_<%=idx%>;
    <%}%>
  
    <%let aidx=0;%>
    <%for(let idx = 0; idx < chipletObj[i].nAIUs; idx++) { %>
        <%if(!(chipletObj[i].AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
            <%for (let mpu_io = 0; mpu_io < chipletObj[i].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                svt_axi_master_sequencer axi_xact_seqr<%=i%>_<%=aidx%>;
                svt_axi_service_coherency_entry_sequence ioaiu_sysco_connect_seq<%=i%>_<%=aidx%>;
                svt_axi_service_sequencer axi_sysco_seqr<%=i%>_<%=aidx%>;
                <%aidx++;%>
            <%}%>
        <%}%>
    <%}%>
  
  <% } //chipletObj.length
  %>
  
  function new(string name = "ncore_base_vseq");
    super.new(name);
     void'($value$plusargs("Credit_for_Dce=%0d",Credit_for_Dce));
     void'($value$plusargs("Credit_for_Dmi=%0d",Credit_for_Dmi));
     void'($value$plusargs("Credit_for_Dii=%0d",Credit_for_Dii));
     ma = mem_agent::get();
     csrq = ma.chiplet[0].regions;
  endfunction: new

  virtual task pre_body();
    //this.csrq = ncore_config_pkg::ncoreConfigInfo::get_all_gpra();
  endtask: pre_body

  task compare_act_exp_skidbuf(int act_skidbuf[string][],int exp_skidbuf[string][],string target_type,int id);

    if(exp_skidbuf[target_type][id]!= act_skidbuf[target_type][id]) begin
        `uvm_error("ncore_init_boot_seq",$sformatf("SKIDBUF compare exp_skidbuf[target_type][%0d] %0d != act_skidbuf[target_type][%0d] %0d target_type: %0s",id,exp_skidbuf[target_type][id],id,act_skidbuf[target_type][id],target_type ))
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
    
fork
<% for (let i = 0; i < chipletObj.length; i++) { %>
begin // <%=i%>
  <% if (obj.chiplets.length > 1) {%>
    //FIX ME : Field Values of registers
    <%for(var idx = 0; idx < chipletObj[i].nGIUs; idx++){%>
        //GIUCXSLR: GIU CXS Link Register
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].GiuInfo[idx])%>.GIUCXSLR.read(status, data);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_read",$sformatf("GIUCXSLR status = %h, data = %h", status, data ),UVM_NONE)
        data = 'd0;
        data[0] = 1'b1; // CXS_RX_en
        data[4] = 1'b1; // CXS_TX_en
        //data[8] = ? CXS_TX_REFUSE_DEACTHINT [RW filed]
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].GiuInfo[idx])%>.GIUCXSLR.write(status, data[31:0]);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_write",$sformatf("GIUCXSLR status = %h, data = %h", status, data ),UVM_NONE)
    <%}%>
        //AIUHOMEDVE : Register is not present
    <%for(var idx = 0; idx < chipletObj[i].nCHIs; idx++){%>
        //CAIUHOMEDVE: Global DVE Id Register [Offset: 0x8]
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUHOMEDVE.read(status, data);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_read",$sformatf("CAIUHOMEDVE status = %h, data = %h", status, data ),UVM_NONE)
        data = 'd0;
        data[10:0]  = 11'b1; // HomeDVEGlobalId
        data[12:11] = 2'b1; // HomeDVELinkId
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUHOMEDVE.write(status, data[31:0]);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_write",$sformatf("CAIUHOMEDVE status = %h, data = %h", status, data ),UVM_NONE)
    <%}%>

    <% for(let idx = 0; idx < chipletObj[i].nDCEs; idx++) {%>
        //DCEUCAMR : DCEUCAMR0: DCEU CachingAgentId to AIU Mapping Register
        <% for(let aiu_id = 0; aiu_id < chipletObj[i].nAius; aiu_id++) {%>
            model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUCAMR<%=aiu_id%>.read(status, data);
            `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_read",$sformatf("DCEUCAMR<%=aiu_id%> status = %h, data = %h", status, data ),UVM_NONE)
            data = 'd0;
            data[9:0] = 10'b1; // GlobalIdCA0
            data[10] ='b1; // valid
            data[25:16] = 10'b1; //GlobalIdCA1
            data[26] ='b1; // valid
            model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUCAMR<%=aiu_id%>.write(status, data[31:0]);
            `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_write",$sformatf("DCEUCAMR<%=aiu_id%> status = %h, data = %h", status, data ),UVM_NONE)
        <%}%>
    <%}%>

    <% for(var idx = 0; idx < chipletObj[i].nDVEs; idx++) {%>
    //*DOMAIN Attachment* 

        //DVEUCDCR :DVE COHERENT DOMAIN CONFIGURATION REGISTER [RO]
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEUCDCR.read(status, data);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_read",$sformatf("DVEUCDCR status = %h, data = %h", status, data ),UVM_NONE)
    
        //DVEUCAER : DVE COHERENT ATTACH ENABLE REGISTER. 
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEUCAER.read(status, data);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_read",$sformatf("DVEUCAER status = %h, data = %h", status, data ),UVM_NONE)
        data = 'd0;
        data[0] = 1'b1; // Chiplet0CohEn
        data[1] = 1'b1; // Chiplet0CohEn
        data[2] = 1'b1; // Chiplet0CohEn
        data[3] = 1'b1; // Chiplet0CohEn
        data[31:29] = 3'b1; // CurrentConfigNumber
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEUCAER.write(status, data[31:0]);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_write",$sformatf("DVEUCAER status = %h, data = %h", status, data ),UVM_NONE)

        //DVEUSCALR
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEUSCALR.read(status, data);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_read",$sformatf("DVEUSCALR status = %h, data = %h", status, data ),UVM_NONE)
        data = 'd0;
        data[1:0] = 2'b1; // RemoteSysCoAttachLinkIdChiplet0
        data[3:2] = 2'b1; // RemoteSysCoAttachLinkIdChiplet1
        data[5:4] = 2'b1; // RemoteSysCoAttachLinkIdChiplet2
        data[7:6] = 2'b1; // RemoteSysCoAttachLinkIdChiplet3
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEUSCALR.write(status, data[31:0]);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_write",$sformatf("DVEUSCALR status = %h, data = %h", status, data ),UVM_NONE)

    //*DVM Handling*
        //AIUHOMEDVE : Register is not present

        //DVEURDVEFUIDR :REMOTE DVE FUNITID REGISTER
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEURDVEFUIDR.read(status, data);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_read",$sformatf("DVEURDVEFUIDR status = %h, data = %h", status, data ),UVM_NONE)
        data = 'd0;
        data[7:0]   = 8'b1; // Chiplet0DVEFUnitId
        data[15:8]  = 8'b1; // Chiplet1DVEFUnitId
        data[23:16] = 8'b1; // Chiplet2DVEFUnitId
        data[31:24] = 8'b1; // Chiplet3DVEFUnitId
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEURDVEFUIDR.write(status, data[31:0]);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_write",$sformatf("DVEURDVEFUIDR status = %h, data = %h", status, data ),UVM_NONE)

        //DVEUDVMDCR : DVM DOMAIN CONFIGURATION REGISTER [ro]
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEUDVMDCR.read(status, data);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_read",$sformatf("DVEUDVMDCR status = %h, data = %h", status, data ),UVM_NONE)

        //DVEUDRSER : DVE REMOTE DVM SNOOP ENABLE REGISTER
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEUDRSER.read(status, data);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_read",$sformatf("DVEUDRSER status = %h, data = %h", status, data ),UVM_NONE)
        data = 'd0;
        data[0] = 1'b1; // Chiplet0DVMEn
        data[1] = 1'b1; // Chiplet1DVMEn
        data[2] = 1'b1; // Chiplet2DVMEn
        data[3] = 1'b1; // Chiplet3DVMEn
        data[31:29] = 3'b1; // CurrentConfigNumber
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEUDRSER.write(status, data[31:0]);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_write",$sformatf("DVEUDRSER status = %h, data = %h", status, data ),UVM_NONE)

        //DVEUDVMLIR :  DVE DVM LINKID REGISTER
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEUDVMLIR.read(status, data);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_read",$sformatf("DVEUDVMLIR status = %h, data = %h", status, data ),UVM_NONE)
        data = 'd0;
        data[1:0] = 2'b1; // RemoteLinkIdChiplet0
        data[3:2] = 2'b1; // RemoteLinkIdChiplet1
        data[5:4] = 2'b1; // RemoteLinkIdChiplet2
        data[7:6] = 2'b1; // RemoteLinkIdChiplet3
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEUDVMLIR.write(status, data[31:0]);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_write",$sformatf("DVEUDVMLIR status = %h, data = %h", status, data ),UVM_NONE)

    //*Event Handling*

        //DVEURSEE: DVE REMOTE EVENT ENABLE REGISTER
         model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEURSEE.read(status, data);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_read",$sformatf("DVEURSEE status = %h, data = %h", status, data ),UVM_NONE)
        data = 'd0;
        data[0] = 1'b1; // Chiplet0EventEn
        data[1] = 1'b1; // Chiplet1EventEn
        data[2] = 1'b1; // Chiplet2EventEn
        data[3] = 1'b1; // Chiplet3EventEn
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEURSEE.write(status, data[31:0]);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_write",$sformatf("DVEURSEE status = %h, data = %h", status, data ),UVM_NONE)

        //DVEURSELR:  DVE REMOTE SYSTEM EVENT LINKID REGISTER
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEURSELR.read(status, data);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_read",$sformatf("DVEURSELR status = %h, data = %h", status, data ),UVM_NONE)
        data = 'd0;
        data[1:0] = 2'b1; // RemoteSysEvLinkIdChiplet0
        data[3:2] = 2'b1; // RemoteSysEvLinkIdChiplet1
        data[5:4] = 2'b1; // RemoteSysEvLinkIdChiplet2
        data[7:6] = 2'b1; // RemoteSysEvLinkIdChiplet3
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DveInfo[idx])%>.DVEURSELR.write(status, data[31:0]);
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=idx%>_write",$sformatf("DVEURSELR status = %h, data = %h", status, data ),UVM_NONE)
    <%} //chipletObj[i].nDVEs
} //if (obj.chiplets.length > 1)
%>

    <% var fidx=0;%>
    <%for(var idx = 0; idx < chipletObj[i].nAIUs; idx++){%>
        <%if((chipletObj[i].AiuInfo[idx].strRtlNamePrefix== "caiu0")){%>
            <%for(var pidx=0;pidx < Object.keys(chipletObj[i].AiuInfo[idx].csr.spaceBlock[0].registers).length; pidx++){%>
                <%if(chipletObj[i].AiuInfo[idx].csr.spaceBlock[0].registers[pidx].name == "CAIUIDR") { %>
                    <%fidx=1;%>
                <%}%>
            <%}%>
        <%}%>
    <%}%>

<% if(fidx ==1) {%>
    //1. read CAIUIDR
    model.<%=obj.lib.getFullInstanceName(chiplets[i], "caiu0")%>.CAIUIDR.read(status, data);
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], "caiu0")%>.CAIUIDR.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("caiu0.CAIUIDR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    if(data[31]) begin // valid
      ioaiu_rpn  = data[ 7:0];
      ioaiu_nrri = data[11:8];
	  `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("UIDR.RPN=%0d, UIDR.NRRI=%0d", ioaiu_rpn, ioaiu_nrri), UVM_NONE)
    end else begin
      `uvm_error("ncore_init_boot_seq<%=i%>_<%=qidx%>","Valid bit not asserted in USIDR register of Initiating IOAIU-AIU")
    end
<% } %>

    // (2) Read NRRUCR
    data = 0;
    model.<%=obj.lib.getFullInstanceName(chiplets[i], "sys_global_register_blk")%>.GRBUNRRUCR.read(status, data);
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], "sys_global_register_blk")%>.GRBUNRRUCR.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Read:addr = %0h , NRRUCR = 0x%0h", addr, data), UVM_NONE)
    nAIUs = data[ 7: 0];
    nDCEs = data[13: 8];
    nDMIs = data[19:14];
    nDIIs = data[25:20];
    nDVEs = data[26:26];
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("nAIUs:%0d nDCEs:%0d nDMIs:%0d nDIIs:%0d nDVEs:%0d",nAIUs,nDCEs,nDMIs,nDIIs,nDVEs),UVM_NONE)
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
    
    <%var largest_index = (chipletObj[i].nDCEs > chipletObj[i].nDMIs) ? ( (chipletObj[i].nDCEs > chipletObj[i].nDIIs) ? chipletObj[i].nDCEs : chipletObj[i].nDIIs ) : ( (chipletObj[i].nDMIs > chipletObj[i].nDIIs) ? chipletObj[i].nDMIs : chipletObj[i].nDIIs );%>

    // (3) Configure all the General Purpose registers
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>","Configuring GPRs", UVM_NONE)
    // foreach (csrq[i]) begin
    //   //`uvm_info(get_name(),$sformatf("csrq[memregion_id:%0d] --> unit: %s  hui:%0d start_addr:0x%0h ", i,csrq[i].unit.name(), csrq[i].mig_nunitid,csrq[i].start_addr),UVM_NONE) 
    //   `uvm_info(get_name(),$sformatf("csrq[memregion_id:%0d] --> unit: %s hui:%0d start_addr:0x%0h low-addr:0x0%h up-addr: 0x%0h sz:%0d", i,csrq[i].unit.name(), csrq[i].mig_nunitid,ncore_config_pkg::ncoreConfigInfo::memregions_info[i].start_addr,csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),UVM_NONE) 
    // end
 
    //Configure address regions for CHIAIU/IOUAIU
    <%for(var idx = 0; idx < chipletObj[i].nAIUs; idx++) {%>
        aiu_dmi_connect[<%=idx%>] = 'h<%=chipletObj[i].AiuInfo[idx].hexAiuDmiVec%>;
        aiu_dii_connect[<%=idx%>] = 'h<%=chipletObj[i].AiuInfo[idx].hexAiuDiiVec%>;
        aiu_dce_connect[<%=idx%>] = 'h<%=chipletObj[i].AiuInfo[idx].hexAiuDceVec%>;
    <% if((chipletObj[i].AiuInfo[idx].fnNativeInterface.includes('CHI'))) {%>
        //Program CAIUAMIGR register
        data = 'd0;
        data[0] = 1'b1; // valid bit
        data[4:1] = 0; //ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs; //AMIGS field FIXME: Make this more generic
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUAMIGR.write(status, data);
        addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUAMIGR.get_address();
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.CAIUAMIGR = 0x%0h", addr, data), UVM_NONE)

        //CAIUMIFSR
        data = 'd0;
        data[2:0] = 0; //ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[2];
        data[10:8] = 0; //ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[4];
        data[18:16] = 0; //ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[8];
        data[26:24] = 0; //ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[16];
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUMIFSR.write(status, data[31:0]);
        addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUMIFSR.get_address();
        `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.CAIUMIFSR = 0x%0h", addr, data), UVM_NONE)

        <%for(var pidx = 0; pidx < nGPRA; ++pidx){%>
            //write to GPR register sets with appropriate values
            data = csrq[<%=pidx%>].lower_part2;
            model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUGPRBLR<%=pidx%>.write(status, data);
            addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUGPRBLR<%=pidx%>.get_address();
            `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRBLR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)

            data = csrq[<%=pidx%>].lower_part1;
            model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUGPRBHR<%=pidx%>.write(status, data);
            addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUGPRBHR<%=pidx%>.get_address();
            `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRBHR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
            
            //GPRAR
            data =0; // Reset value
            data[31]    = 1; // Valid
            data[30:29]    = (csrq[<%=pidx%>].home_unit_type); // Home Unit Type
            data[25:20] = csrq[<%=pidx%>].size_log2; // interleave group member size(2^(size+12) bytes)
            data[13:9]  = csrq[<%=pidx%>].mig_nunitid;
            data[7:6]   = 2'b01; // to configure to non-secure mode
            data[1]     = csrq[<%=pidx%>].order.readid;
            data[2]   = csrq[<%=pidx%>].order.writeid;
            data[4:3]   = csrq[<%=pidx%>].order.policy;
            model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUGPRAR<%=pidx%>.write(status, data[31:0]);
            addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUGPRAR<%=pidx%>.get_address();
            `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.CAIUGPRAR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
        <%}%>

    <%} else {%>
        //Program AMIGR register for IOAIU
        data = 'd0;
        data[0] = 1'b1; // valid bit
        data[4:1] = 0; //ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs; //AMIGS field //FIXME: make this more generic

        <%if (chipletObj[i].AiuInfo[idx].nNativeInterfacePorts > 1){%>
            <%for(let port_id=0; port_id < chipletObj[i].AiuInfo[idx].nNativeInterfacePorts; port_id++ ){%>
                model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=port_id%>.XAIUAMIGR.write(status, data);
                addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=port_id%>.XAIUAMIGR.get_address();
                `uvm_info("ncore_init_boot_seq", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=port_id%>.XAIUAMIGR = 0x%0h", addr, data), UVM_NONE)
            <%}%>
        <%}else{%>
            model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUAMIGR.write(status, data);
            addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUAMIGR.get_address();
            `uvm_info("ncore_init_boot_seq", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.XAIUAMIGR = 0x%0h", addr, data), UVM_NONE)
        <%}%>


    //XAIUMIFSR
    data = 'd0;
    data[2:0]   = 0; //ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[2];
    data[10:8]  = 0; //ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[4];
    data[18:16] = 0; //ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[8];
    data[26:24] = 0; //ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[16];

    <%if (chipletObj[i].AiuInfo[idx].nNativeInterfacePorts > 1){%>
        <%for(let port_id=0; port_id < chipletObj[i].AiuInfo[idx].nNativeInterfacePorts; port_id++ ){%>
            model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=port_id%>.XAIUMIFSR.write(status, data[31:0]);
            addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=port_id%>.XAIUMIFSR.get_address();
            `uvm_info("ncore_init_boot_seq", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=port_id%>.XAIUMIFSR = 0x%0h", addr, data), UVM_NONE)
        <%}%>
    <%}else{%>
        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUMIFSR.write(status, data[31:0]);
        addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUMIFSR.get_address();
        `uvm_info("ncore_init_boot_seq", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.XAIUMIFSR = 0x%0h", addr, data), UVM_NONE)
    <%}%>

    <%for(var pidx = 0; pidx < nGPRA; ++pidx){%>
        //write to GPR register sets with appropriate values
        <%for (var mpu_io = 0; mpu_io < chipletObj[i].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
            data = csrq[<%=pidx%>].lower_part2;
            <% if(chipletObj[i].AiuInfo[idx].nNativeInterfacePorts > 1){%>
                model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUGPRBLR<%=pidx%>.write(status, data);
                addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUGPRBLR<%=pidx%>.get_address();
                `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUGPRBLR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
            <%} else { %>
                model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUGPRBLR<%=pidx%>.write(status, data);
                addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUGPRBLR<%=pidx%>.get_address();
                `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.XAIUGPRBLR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
            <%} %>

    data = csrq[<%=pidx%>].lower_part2;
    <% if(chipletObj[i].AiuInfo[idx].nNativeInterfacePorts > 1){%>
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUGPRBHR<%=pidx%>.write(status, data);
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUGPRBHR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUGPRBHR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
    <%} else { %>
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUGPRBHR<%=pidx%>.write(status, data);
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUGPRBHR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.XAIUGPRBHR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
    <%} %>
    
    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30:29]    = csrq[<%=pidx%>].home_unit_type;// == ncore_config_pkg::ncoreConfigInfo::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[<%=pidx%>].size_log2; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[<%=pidx%>].mig_nunitid;
    data[7:6]   = 2'b01;
    if(csrq[<%=pidx%>].home_unit_type == 2'b10) begin //FIXME: Confirm with hut is 2'b10 for local DII
        data[5]   = 1'b1;
    end
    //data[4:0]   = csrq[<%=pidx%>].order;
    data[1]     = csrq[<%=pidx%>].order.readid;
    data[2]   = csrq[<%=pidx%>].order.writeid;
    data[4:3]   = csrq[<%=pidx%>].order.policy;
    <% if(chipletObj[i].AiuInfo[idx].nNativeInterfacePorts > 1){%>
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUGPRAR<%=pidx%>.write(status, data[31:0]);
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUGPRAR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUGPRAR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
    <%} else { %>
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUGPRAR<%=pidx%>.write(status, data[31:0]);
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUGPRAR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.XAIUGPRAR<%=pidx%> = 0x%0h", addr, data), UVM_NONE)
    <%} %>
    <%}}  %>
    <%}%>

<%}%>

    // (3) Initialize DCEs
<%for(var idx = 0; idx < chipletObj[i].nDCEs; ++idx){%>
    <%for(var pidx = 0; pidx < nGPRA; ++pidx){%>

    data = csrq[<%=pidx%>].lower_part1;
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUGPRBLR<%=pidx%>.write(status, csrq[<%=pidx%>].lower_part1 );
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUGPRBLR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>.DCEUGPRBLR<%=pidx%>  = 0x%0h", addr, data), UVM_NONE)

    data = csrq[<%=pidx%>].lower_part2;
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUGPRBHR<%=pidx%>.write(status, csrq[<%=pidx%>].lower_part2 );
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUGPRBHR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>.DCEUGPRBHR<%=pidx%>  = 0x%0h", addr, data), UVM_NONE)

    //GPRAR
    data =0; // Reset value
    data[31]    = 1; // Valid
    data[30:29]    = csrq[<%=pidx%>].home_unit_type;// == ncore_config_pkg::ncoreConfigInfo::DII ? 1 : 0); // Home Unit Type
    data[25:20] = csrq[<%=pidx%>].size_log2; // interleave group member size(2^(size+12) bytes)
    data[13:9]  = csrq[<%=pidx%>].mig_nunitid;
    data[7:6]   = 2'b01 ;
    //data[4:0]   = csrq[<%=pidx%>].order;
    data[1]     = csrq[<%=pidx%>].order.readid;
    data[2]   = csrq[<%=pidx%>].order.writeid;
    data[4:3]   = csrq[<%=pidx%>].order.policy;
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUGPRAR<%=pidx%>.write(status, data[31:0]);
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUGPRAR<%=pidx%>.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>.DCEUGPRAR<%=pidx%>  = 0x%0h", addr, data), UVM_NONE)

     <%}%>

    //DCEUAMIGR
    data = 32'h0;
    data[4:0]={/*ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs*/1'b0,1'b1}; //FIXME: Make this more generic
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUAMIGR.write(status, data[31:0]);
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUAMIGR.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>.DCEUAMIGR = 0x%0h", addr, data), UVM_NONE)

    //DCEUMIFSR
    data = 'd0;
    data[2:0]   = 1'b0;//ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[2]; //FIXME: Make this more generic
    data[10:8]  = 1'b0;//ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[4];
    data[18:16] = 1'b0;//ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[8];
    data[26:24] = 1'b0;//ncore_config_pkg::ncoreConfigInfo::picked_dmi_if[16];
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUMIFSR.write(status, data[31:0]);
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUMIFSR.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>.DCEUMIFSR = 0x%0h", addr, data), UVM_NONE)

    //DCEUSFMAR
    poll_till = 32'b0;       
    timeout = 500;
    do begin
      timeout -=1;
      model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUSFMAR.read(status, data);
      addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUSFMAR.get_address();
      `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUSFMAR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    end while ((data != poll_till) && (timeout != 0)); // UNMATCHED !!
    if (timeout == 0) begin
      `uvm_error("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Timeout! Polling  poll_till=0x%0x data=0x%0x", poll_till, data))
    end 

    //DCEUSBSIR
    data = 0;
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUSBSIR.get_address();
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUSBSIR.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUSBSIR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    if(data[31]) begin
      act_cmd_skidbuf_size["DCE"][<%=idx%>]=data[25:16];
      act_cmd_skidbuf_arb["DCE"][<%=idx%>]=data[8:0];
    end else begin  
      `uvm_error("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("Valid bit not asserted in DCEUSBSIR addr 0x%0h data 0x%0h",addr, data))
    end
    exp_cmd_skidbuf_size["DCE"][<%=idx%>]=<%=chipletObj[i].DceInfo[idx].nCMDSkidBufSize%>;
    exp_cmd_skidbuf_arb["DCE"][<%=idx%>]=<%=chipletObj[i].DceInfo[idx].nCMDSkidBufArb%>;
    compare_act_exp_skidbuf(act_cmd_skidbuf_size,exp_cmd_skidbuf_size,"DCE",<%=idx%>);
    compare_act_exp_skidbuf(act_cmd_skidbuf_arb,exp_cmd_skidbuf_arb,"DCE",<%=idx%>);
    
    DceIds[<%=idx%>]= <%=chipletObj[i].DceInfo[idx].FUnitId%>; 
    dce_dmi_connect[<%=idx%>] = 'h<%=chipletObj[i].DceInfo[idx].hexDceDmiVec%>;
<%}%>

    // (5) Initialize DMIs ( dmi*_DMIUSMCTCR)
<% for(var idx = 0; idx < chipletObj[i].nDMIs; ++idx) { %>
    <% if(chipletObj[i].DmiInfo[idx].useCmc) { %>
    data=32'h3;
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.DMIUSMCTCR.write(status, data[31:0]);
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.DMIUSMCTCR.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].DmiInfo[idx].strRtlNamePrefix%>.DMIUSMCTCR = 0x%0h", addr, data), UVM_NONE)
    <%}%> 

    //MRDSBSIR
    data = 0;
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.MRDSBSIR.get_address();
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.MRDSBSIR.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.MRDSBSIR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    if(data[31]) begin
      act_mrd_skidbuf_size["DMI"][<%=idx%>]=data[25:16];
      act_mrd_skidbuf_arb["DMI"][<%=idx%>]=data[8:0];
    end else begin
      `uvm_error("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("Valid bit not asserted in MRDSBSIR addr 0x%0h data 0x%0h",addr, data))
    end
    exp_mrd_skidbuf_size["DMI"][<%=idx%>]=<%=chipletObj[i].DmiInfo[idx].nMrdSkidBufSize%>;
    exp_mrd_skidbuf_arb["DMI"][<%=idx%>]=<%=chipletObj[i].DmiInfo[idx].nMrdSkidBufArb%>;
    compare_act_exp_skidbuf(act_mrd_skidbuf_size,exp_mrd_skidbuf_size,"DMI",<%=idx%>);
    compare_act_exp_skidbuf(act_mrd_skidbuf_arb,exp_mrd_skidbuf_arb,"DMI",<%=idx%>);

    //CMDSBSIR
    data = 0;
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.CMDSBSIR.get_address();
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.CMDSBSIR.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.CMDSBSIR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    if(data[31]) begin
      act_cmd_skidbuf_size["DMI"][<%=idx%>]=data[25:16];
      act_cmd_skidbuf_arb["DMI"][<%=idx%>]=data[8:0];
    end else begin
      `uvm_error("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("Valid bit not asserted in CMDSBSIR addr 0x%0h data 0x%0h",addr, data))
    end
    exp_cmd_skidbuf_size["DMI"][<%=idx%>]=<%=chipletObj[i].DmiInfo[idx].nCMDSkidBufSize%>;
    exp_cmd_skidbuf_arb["DMI"][<%=idx%>]=<%=chipletObj[i].DmiInfo[idx].nCMDSkidBufArb%>;
    compare_act_exp_skidbuf(act_cmd_skidbuf_size,exp_cmd_skidbuf_size,"DMI",<%=idx%>);
    compare_act_exp_skidbuf(act_cmd_skidbuf_arb,exp_cmd_skidbuf_arb,"DMI",<%=idx%>);

    DmiIds[<%=idx%>]= <%=chipletObj[i].DmiInfo[idx].FUnitId%>; 
<%}%>

    //TAGMEM initialization
	fork
        <%for(let idx=0; idx<chipletObj[i].nDMIs; idx++){%>
		<%if(chipletObj[i].DmiInfo[idx].useCmc == 1){%>
        begin
            data[3:0] = 1'd0;
            data[21:16] = 1'd0;
            model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.DMIUSMCMCR.write(status, data[31:0]);
            `uvm_info("ncore_init_boot_seq",$sformatf("model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.DMIUSMCMCR status = %h data = %h", status, data ),UVM_NONE)
            
            data = 'd0;
            //poll to make sure initialization is complete
            fork
                begin
                    while(data[0] != 1'b1) begin
                        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.DMIUSMCISR.read(status, data);
                    end
                end
                begin
                    #500us;
                    `uvm_error("ncore_init_boot_seq0 for <%=chipletObj[i].DmiInfo[idx].strRtlNamePrefix%>", $sformatf("Timeout! Polling during tagmem initialization poll_till=0x2 data=0x%0x", data))
                end
            join_any
            disable fork;
        end
		<%}%>
        <%}%>
    join

    //DATAMEM initialization
    fork
        <%for(let idx=0; idx<chipletObj[i].nDMIs; idx++){%>
		<%if(chipletObj[i].DmiInfo[idx].useCmc == 1){%>
        begin
            data[3:0] = 1'd0;
            data[21:16] = 1'd1;
            model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.DMIUSMCMCR.write(status, data[31:0]);
            `uvm_info("ncore_init_boot_seq",$sformatf("model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.DMIUSMCMCR status = %h data = %h", status, data ),UVM_NONE)

            data = 'd0;
            //poll to make sure initialization is complete
            fork
                begin
                    while(data[1] != 1'b1) begin
                        model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DmiInfo[idx])%>.DMIUSMCISR.read(status, data);
                    end
                end
                begin
                    #500us;
                    `uvm_error("ncore_init_boot_seq0 for <%=chipletObj[i].DmiInfo[idx].strRtlNamePrefix%>", $sformatf("Timeout! Polling during datamem initialization poll_till=0x3 data=0x%0x", data))
                end
            join_any
            disable fork;
        end
		<%}%>
        <%}%>
    join

<% for(var idx = 0; idx < chipletObj[i].nDIIs; ++idx) { %>
    //DIIUSBSIR
    data = 0;
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DiiInfo[idx])%>.DIIUSBSIR.get_address();
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DiiInfo[idx])%>.DIIUSBSIR.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DiiInfo[idx])%>.DIIUSBSIR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    if(data[31]) begin
      act_cmd_skidbuf_size["DII"][<%=idx%>]=data[25:16];
      act_cmd_skidbuf_arb["DII"][<%=idx%>]=data[8:0];
    end else begin
      `uvm_error("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("Valid bit not asserted in DIIUSBSIR addr 0x%0h data 0x%0h",addr, data))
    end
    exp_cmd_skidbuf_size["DII"][<%=idx%>]=<%=chipletObj[i].DiiInfo[idx].nCMDSkidBufSize%>;
    exp_cmd_skidbuf_arb["DII"][<%=idx%>]=<%=chipletObj[i].DiiInfo[idx].nCMDSkidBufArb%>;
    compare_act_exp_skidbuf(act_cmd_skidbuf_size,exp_cmd_skidbuf_size,"DII",<%=idx%>);
    compare_act_exp_skidbuf(act_cmd_skidbuf_arb,exp_cmd_skidbuf_arb,"DII",<%=idx%>);

    DiiIds[<%=idx%>]= <%=chipletObj[i].DiiInfo[idx].FUnitId%>; 
<%}%>

   for(int k = 0; k < <%=chipletObj[i].nAIUs%>; k++)begin
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

   for(int k = 0; k < <%=chipletObj[i].nAIUs%>; k++)begin
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
<% for(var idx = 0; idx < chipletObj[i].nAIUs; idx++) {%>
     <%if((chipletObj[i].AiuInfo[idx].fnNativeInterface == 'CHI-A')||(chipletObj[i].AiuInfo[idx].fnNativeInterface == 'CHI-B')||(chipletObj[i].AiuInfo[idx].fnNativeInterface == 'CHI-E') ) {%>
    //CAIUCCR
    <%for(var j=0;j<largest_index;j++) {%>
    data =0; // Reset value
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUCCR<%=j%>.get_address();
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.CAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
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
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUCCR<%=j%>.write(status, data[31:0]);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.CAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.CAIUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.CAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)

    <%} %>
    <%} else {%>
    //XAIUCCR
     <%for (var mpu_io = 0; mpu_io < chipletObj[i].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
    <% if(chipletObj[i].AiuInfo[idx].nNativeInterfacePorts > 1){%>
    <%for(var j=0;j<largest_index;j++) {%>
    data =0; // Reset value
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUCCR<%=j%>.get_address();
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
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
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUCCR<%=j%>.write(status, data[31:0]);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    <%} %>
    <%} else { %>
    <%for(var j=0;j<largest_index;j++) {%>
    data =0; // Reset value
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUCCR<%=j%>.get_address();
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.XAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
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
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUCCR<%=j%>.write(status, data[31:0]);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.XAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.XAIUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)

    <%} %>
    <%}%>
   <%}%>
  <%}%>
<%}%>
<% for(var idx = 0; idx < chipletObj[i].nDCEs; idx++) {%>
    //DCEUCCR
    <%for(var j=0;j<chipletObj[i].nDMIs;j++) {%>
    Credit_for_Mrd[DceIds[<%=idx%>]][DmiIds[<%=j%>]] =((act_mrd_skidbuf_size["DMI"][<%=j%>]/dce_dmi[<%=idx%>]) > 31 ) ? 31 : (act_mrd_skidbuf_size["DMI"][<%=j%>]/dce_dmi[<%=idx%>]) ;
    data =0; // Reset value
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUCCR<%=j%>.get_address();
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>.DCEUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    if ($test$plusargs("override_decuccr")) begin
        data[4:0]   = Credit_for_Dce;
    end else begin
        data[4:0]   = Credit_for_Mrd[DceIds[<%=idx%>]][DmiIds[<%=j%>]];
    end
        data[12:8]  = 8'hE0;
        data[20:16] = 8'hE0;
        data[31:24] = 8'hE0;
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUCCR<%=j%>.write(status, data[31:0]);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>.DCEUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].DceInfo[idx])%>.DCEUCCR<%=j%>.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Read:addr = %0h , <%=chipletObj[i].DceInfo[idx].strRtlNamePrefix%>.DCEUCCR<%=j%> = 0x%0h", addr, data), UVM_NONE)
    <%} %>
<%}%>

//   =======  CONC-11480
<% for(var idx = 0; idx < chipletObj[i].nAIUs; idx++) { 
    if((chipletObj[i].AiuInfo[idx].fnNativeInterface != 'CHI-A') && (chipletObj[i].AiuInfo[idx].fnNativeInterface != 'CHI-B')&& (chipletObj[i].AiuInfo[idx].fnNativeInterface != 'CHI-E')  && ((chipletObj[i].AiuInfo[idx].fnNativeInterface == 'ACE'|| chipletObj[i].AiuInfo[idx].fnNativeInterface == 'ACE5' )|| (((chipletObj[i].AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (chipletObj[i].AiuInfo[idx].fnNativeInterface == 'ACELITE-E') ) && (chipletObj[i].AiuInfo[idx].cmpInfo.nDvmSnpInFlight > 0)) || ((chipletObj[i].AiuInfo[idx].fnNativeInterface == 'AXI4'|| chipletObj[i].AiuInfo[idx].fnNativeInterface == 'AXI5') && chipletObj[i].AiuInfo[idx].useCache == 1 ))) { 
      for(var pidx=0;pidx < Object.keys(chipletObj[i].AiuInfo[idx].csr.spaceBlock[0].registers).length; pidx++) { 
        if(chipletObj[i].AiuInfo[idx].csr.spaceBlock[0].registers[pidx].name == "XAIUPCTCR") { %>
     <%for (var mpu_io = 0; mpu_io < chipletObj[i].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
    data=32'h0;
    <% if(chipletObj[i].AiuInfo[idx].nNativeInterfacePorts > 1){%>
	addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUPCTCR.get_address();
	model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUPCTCR.read(status, data);
	`uvm_info("ncore_init_boot_seq0", $sformatf("Reg Read:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCTCR = 0x%0h", addr, data), UVM_NONE)
	data[1:0] = 2'b11; // enable LookupEn & AllocEn
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUPCTCR.write(status, data[31:0]);  
    `uvm_info("ncore_init_boot_seq0", $sformatf("my_if Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCTCR = 0x%0h", addr, data), UVM_NONE)
      model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUPCTCR.read(status, data);

    <%} else { %>
	addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUPCTCR.get_address();
	model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUPCTCR.read(status, data);
	`uvm_info("ncore_init_boot_seq0", $sformatf("Reg Read:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.XAIUPCTCR = 0x%0h", addr, data), UVM_NONE)
	data[1:0] = 2'b11; // enable LookupEn & AllocEn
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUPCTCR.write(status, data[31:0]);  
    `uvm_info("ncore_init_boot_seq0", $sformatf("Reg Write:addr = %0h , <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.XAIUPCTCR = 0x%0h", addr, data), UVM_NONE)
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUPCTCR.read(status, data);
    
<% } } } } } } %> 

//ACE SYSCO attach & pool status
<% for(var idx = 0; idx < chipletObj[i].nAIUs; idx++) { 
    if((chipletObj[i].AiuInfo[idx].fnNativeInterface != 'CHI-A') && (chipletObj[i].AiuInfo[idx].fnNativeInterface != 'CHI-B')&& (chipletObj[i].AiuInfo[idx].fnNativeInterface != 'CHI-E') && ((chipletObj[i].AiuInfo[idx].fnNativeInterface == 'ACE'|| chipletObj[i].AiuInfo[idx].fnNativeInterface == 'ACE5')|| (((chipletObj[i].AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (chipletObj[i].AiuInfo[idx].fnNativeInterface == 'ACELITE-E') ) && (chipletObj[i].AiuInfo[idx].cmpInfo.nDvmSnpInFlight > 0)) || ((chipletObj[i].AiuInfo[idx].fnNativeInterface == 'AXI4' || chipletObj[i].AiuInfo[idx].fnNativeInterface == 'AXI5') && chipletObj[i].AiuInfo[idx].useCache == 1 ))) { 
      for(var pidx=0;pidx < Object.keys(chipletObj[i].AiuInfo[idx].csr.spaceBlock[0].registers).length; pidx++) { 
        if(chipletObj[i].AiuInfo[idx].csr.spaceBlock[0].registers[pidx].name == "XAIUTCR") { %>
     <%for (var mpu_io = 0; mpu_io < chipletObj[i].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
    // Attach
    data=0;
    <% if(chipletObj[i].AiuInfo[idx].nNativeInterfacePorts > 1){%>
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUTCR.get_address();
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUTCR.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Read:addr = %0h, <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTCR.SysCoAttach = 0x%0h", addr, data), UVM_NONE)
    data[model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUTCR.SysCoAttach.get_lsb_pos()]=1'b1;    //SysCoAttach 
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUTCR.write(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h, <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTCR.SysCoAttach = 0x%0h", addr, data), UVM_NONE)
    //poll until attach
    poll_till = 0;                       
    poll_till[model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUTAR.SysCoAttached.get_lsb_pos()] = 1'b1; // SysCoAttached                       
    timeout = 2000;
    do begin                
      timeout -=1;
      data=0;
      model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUTAR.read(status, data);
      if (data[model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUTAR.SysCoError.get_lsb_pos()]) //SysCoError
       `uvm_error("ncore_init_boot_seq", $sformatf("SysCoError!!! model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUTAR.SysCoError status = %h addr = %h data = %h", status, addr, data))
      model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUTAR.read(status, data);
      addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUTAR.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("POLLING model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUTAR.SysCoAttached status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    end while((data[model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUTAR.SysCoAttached.get_lsb_pos()] != poll_till[model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUTAR.SysCoAttached.get_lsb_pos()])&& (timeout != 0));
    <%} else { %>
    addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUTCR.get_address();
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUTCR.read(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Read:addr = %0h, <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.XAIUTCR.SysCoAttach = 0x%0h", addr, data), UVM_NONE)
    data[model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUTCR.SysCoAttach.get_lsb_pos()]=1'b1;    //SysCoAttach 
    model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUTCR.write(status, data);
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>", $sformatf("Reg Write:addr = %0h, <%=chipletObj[i].AiuInfo[idx].strRtlNamePrefix%>.XAIUTCR.SysCoAttach = 0x%0h", addr, data), UVM_NONE)
    //poll until attach
    poll_till = 0;                       
    poll_till[model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUTAR.SysCoAttached.get_lsb_pos()] = 1'b1; // SysCoAttached                       
    timeout = 2000;
    do begin                
      timeout -=1;
      data=0;
      model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUTAR.read(status, data);
      if (data[model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUTAR.SysCoError.get_lsb_pos()]) //SysCoError
       `uvm_error("ncore_init_boot_seq", $sformatf("SysCoError!!! model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUTAR.SysCoError status = %h addr = %h data = %h", status, addr, data))
      model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUTAR.read(status, data);
      addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUTAR.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("POLLING model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUTAR.SysCoAttached status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    end while((data[model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUTAR.SysCoAttached.get_lsb_pos()] != poll_till[model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUTAR.SysCoAttached.get_lsb_pos()])&& (timeout != 0));
    <%}%>
    if (timeout == 0) begin
      `uvm_error("ncore_init_boot_seq", $sformatf("Timeout! Polling  poll_till=0x%0x data=0x%0x", poll_till, data))
    end
<% } } } } } %>

//POLL XAIUPCISR

<% for(var idx = 0; idx < chipletObj[i].nAIUs; idx++) { if((chipletObj[i].AiuInfo[idx].fnNativeInterface != 'CHI-A') && (chipletObj[i].AiuInfo[idx].fnNativeInterface != 'CHI-B')&& (chipletObj[i].AiuInfo[idx].fnNativeInterface != 'CHI-E') && (chipletObj[i].AiuInfo[idx].fnNativeInterface != 'ACE' || chipletObj[i].AiuInfo[idx].fnNativeInterface != 'ACE5' )) { for(var pidx=0;pidx < Object.keys(chipletObj[i].AiuInfo[idx].csr.spaceBlock[0].registers).length; pidx++) { if(chipletObj[i].AiuInfo[idx].csr.spaceBlock[0].registers[pidx].name == "XAIUPCISR") { %>
     <%for (var mpu_io = 0; mpu_io < chipletObj[i].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
    poll_till = 32'b11;                       
    timeout = 5000;
    do begin                
      timeout -=1;
    <% if(chipletObj[i].AiuInfo[idx].nNativeInterfacePorts > 1){%>
      model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUPCISR.read(status, data);
      addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUPCISR.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>_<%=mpu_io%>.XAIUPCISR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    <%} else { %>
      model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUPCISR.read(status, data);
      addr = model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUPCISR.get_address();
    `uvm_info("ncore_init_boot_seq<%=i%>_<%=qidx%>",$sformatf("model.<%=obj.lib.getFullInstanceName(chiplets[i], chipletObj[i].AiuInfo[idx])%>.XAIUPCISR status = %h addr = %h data = %h", status, addr, data ),UVM_NONE)
    <%}%>
    end while((data != poll_till)&& (timeout != 0));
    if (timeout == 0) begin
      `uvm_error("ncore_init_boot_seq", $sformatf("Timeout! Polling  poll_till=0x%0x data=0x%0x", poll_till, data))
    end
<% }} } } } %>
end  // <%=i%>

<%}%>
join
  endtask: run_boot_sequence

endclass: ncore_base_vseq

