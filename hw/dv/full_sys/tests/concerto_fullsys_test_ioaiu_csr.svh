<%
//Embedded javascript code to figure number of blocks
   let chiaiu0 = 0;
   let _blkid = [];
   let _blkidpkg = [];
   let _blktype = [];
   let _blkports_suffix =[];
   let _blk_nCore = [];
   let _blk   = [{}];
   let pidx = 0;
   let ridx = 0;
   let _idx = 0;
   let chiaiu_idx = 0;
   let numChiAiu = 0;
   let numCAiu = 0;
   let numIoAiu = 0;
   let numACEAiu = 0;
   let numNCAiu = 0;
   let ioaiu_idx = 0;
   let ioidx = 0;
   let ioaiu_mpu_idx = 0;
   let nAIUs_mpu =0; 
   let aiu_rpn = [];
   let ioAiuWithPC;
   let idxIoAiuWithPC;
   let numDmiWithSMC = 0; // Number of DMIs with SystemMemoryCache
   let idxDmiWithSMC = 0; // To get valid index of DMI with SystemMemoryCache
   let numDmiWithSP = 0; // Number of DMIs with ScratchPad memory
   let idxDmiWithSP = 0; // To get valid index of DMIs with ScratchPad memory
   let numDmiWithWP = 0; // Number of DMIs with WayPartitioning
   let idxDmiWithWP = 0; // To get valid index of DMIs with WayPartitioning
   let csrAccess_ioaiu;
   let csrAccess_chiaiu;
   let found_csr_access_chiaiu=0;
   let found_csr_access_ioaiu=0;

for(pidx= 0; pidx < obj.nAIUs; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn[0];
   } else {
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn;
   }
 }
// Assuming CHI AIU will appear first in AiuInfo in top.level.dv.json before IO-AIUs
for(pidx= 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-B") || (obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) 
       { 
       if(obj.AiuInfo[pidx].fnNativeInterface == "CHI-A") {
           chiA_present=1;
           throw "ERROR - NCORE3.6 does not support CHI-A native interface in CHIAIU."
       }
       if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
      // CLU TMP COMPILE FIX CONC-11383 if(obj.AiuInfo[pidx].fnCsrAccess == 1) {
         if (found_csr_access_chiaiu == 0) {
          csrAccess_chiaiu = numChiAiu;
          found_csr_access_chiaiu = 1;
         }
       //}
       numChiAiu++ ; numCAiu++ ; 
       }
    else
       { 
     // CLU TMP COMPILE FIX CONC-11383  if(obj.AiuInfo[pidx].fnCsrAccess == 1) {
            if (found_csr_access_ioaiu == 0) {
	       csrAccess_ioaiu = numIoAiu;
	       found_csr_access_ioaiu = 1;
            }
     //    }
         numIoAiu++ ; 
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { 
            if(numACEAiu == 0) { aceaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; ioaiu0=aceaiu0;}
            numCAiu++; numACEAiu++; 
         } else {
            if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
               if (numNCAiu == 0) { ncaiu0  = obj.AiuInfo[pidx].strRtlNamePrefix + "_0"; ioaiu0=ncaiu0;}
            } else {
               if (numNCAiu == 0) { ncaiu0  = obj.AiuInfo[pidx].strRtlNamePrefix; ioaiu0=ncaiu0;}
            }
            numNCAiu++ ;
         }
//         if(obj.AiuInfo[pidx].useCache) idxIoAiuWithPC = numNCAiu;
         if(obj.AiuInfo[pidx].useCache) {
            idxIoAiuWithPC = numNCAiu-1;
            if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
                ioAiuWithPC  = obj.AiuInfo[pidx].strRtlNamePrefix + "_0";
            } else {
                ioAiuWithPC  = obj.AiuInfo[pidx].strRtlNamePrefix;
            }
         }
       }
}
   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {
       _blk[_idx]   = obj.AiuInfo[pidx];
       _blkid[_idx] = 'chiaiu' + chiaiu_idx +"_0";
       _blkidpkg[_idx] = 'chiaiu' + chiaiu_idx;
       _blktype[_idx]   = 'chiaiu';
       _blk_nCore[pidx] = 1;
       numChiAiu++;
       chiaiu_idx++;
       nAIUs_mpu++;
       _idx++;
       if (obj.AiuInfo[pidx].fnCsrAccess == 1) {
         if (found_csr_access_chiaiu == 0) {
          csrAccess_chiaiu = chiaiu_idx;
          found_csr_access_chiaiu = 1;
         }
       }
       } else {
       for (var port_idx = 0; port_idx < obj.AiuInfo[pidx].nNativeInterfacePorts; port_idx++) {
        _blk[_idx]   = obj.AiuInfo[pidx];
        _blkidpkg[_idx] = 'ioaiu' + ioaiu_idx;
        _blkid[_idx] = 'ioaiu' + ioaiu_idx +"_"+port_idx;
        _blkports_suffix[_idx] = "_" + port_idx;
        _blktype[_idx]   = 'ioaiu';
        _blk_nCore[pidx] = obj.AiuInfo[pidx].nNativeInterfacePorts;
         _idx++;
        nAIUs_mpu++;
        }
        if(obj.AiuInfo[pidx].fnCsrAccess == 1) {
        if (found_csr_access_ioaiu == 0) {
	       csrAccess_ioaiu = ioaiu_idx;
	       found_csr_access_ioaiu = 1;
        }
       }
         ioaiu_idx++;
    }
   }

   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + nAIUs_mpu;
       _blkid[ridx] = 'dce' + pidx;
       _blkidpkg[ridx] = 'dce' + pidx;
       _blktype[ridx]   = 'dce';
       _blk[ridx]   = obj.DceInfo[pidx];
   }
 for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + nAIUs_mpu + obj.nDCEs;
       _blkid[ridx] = 'dmi' + pidx;
       _blkidpkg[ridx] = 'dmi' + pidx;
       _blktype[ridx]   = 'dmi';
       _blk[ridx]   = obj.DmiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + nAIUs_mpu + obj.nDCEs + obj.nDMIs;
       _blkid[ridx] = 'dii' + pidx;
       _blkidpkg[ridx] = 'dii' + pidx;
       _blk[ridx]   = 'dii';
       _blk[ridx]   = obj.DiiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + nAIUs_mpu + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _blkid[ridx] = 'dve' + pidx;
       _blkidpkg[ridx] = 'dve' + pidx;
       _blktype[ridx]   = 'dve';
       _blk[ridx]   = obj.DveInfo[pidx];
   }
   var nALLs = ridx+1;
 var numAiuRpns = 0;   //Total AIU RPN's
for(pidx= 0; pidx < obj.nAIUs; pidx++) {
    if(obj.AiuInfo[pidx].nNativeInterfacePorts) {
       numAiuRpns += obj.AiuInfo[pidx].nNativeInterfacePorts;
    } else {
       numAiuRpns++;
    }
}

// For DMI registers's offset value
function getDmiOffset(register) {
    var found=0;
    var offset=0; 
    obj.DmiInfo.forEach(function regOffsetFindSB(item,i){
                            if(!found){
                               const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                               if(reg != undefined) {
                                  found = 1;
                                  offset = reg.addressOffset;
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For CHI registers's offset value
function getChiOffset(register) {
    var found=0;
    var offset=0; 
    obj.AiuInfo.forEach(function regOffsetFindSB(item,i){
                            if(item.fnNativeInterface === "CHI-A" || item.fnNativeInterface === "CHI-B" || item.fnNativeInterface === "CHI-E") {
                               if(!found){
                                  const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                                  if(reg != undefined) {
                                     found = 1;
                                     offset = reg.addressOffset;
                                  }
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For IOAIU registers's offset value
function getIoOffset(register) {
    var found=0;
    var offset=0; 
    obj.AiuInfo.forEach(function regOffsetFindSB(item,i){
                            if(!(item.fnNativeInterface === "CHI-A" || item.fnNativeInterface === "CHI-B" || item.fnNativeInterface === "CHI-E")) {
                               if(!found){
                                  const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                                  if(reg != undefined) {
                                     found = 1;
                                     offset = reg.addressOffset;
                                  }
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For DCE registers's offset value
function getDceOffset(register) {
    var found=0;
    var offset=0; 
    obj.DceInfo.forEach(function regOffsetFindSB(item,i){
                            if(!found){
                               const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                               if(reg != undefined) {
                                  found = 1;
                                  offset = reg.addressOffset;
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For DVE registers's offset value
function getDveOffset(register) {
    var found=0;
    var offset=0; 
    obj.DveInfo.forEach(function regOffsetFindSB(item,i){
                            if(!found){
                               const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                               if(reg != undefined) {
                                  found = 1;
                                  offset = reg.addressOffset;
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

let Dvm_NUnitIds = [] ;
for (const o of obj.AiuInfo) {
    if(o.cmpInfo.nDvmSnpInFlight > 0) {
        Dvm_NUnitIds.push(o.nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}

var SnoopEn = 0;
   for(let i in Dvm_NUnitIds) {
      SnoopEn |= 1 << Dvm_NUnitIds[i];
   }
%>
class concerto_fullsys_test_ioaiu_csr extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_test_ioaiu_csr)
   bit AIUUEDR_DecErrDetEn;

// UVM PHASE
  extern function void build_phase(uvm_phase phase);
  extern task ncore_test_stimulus(uvm_phase phase);
 
 <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))){ 
    if(obj.AiuInfo[idx].fnCsrAccess == 1 && !(Array.isArray(obj.AiuInfo[idx].interfaces.axiInt))){ %>
    extern virtual task ioaiu_boot_seq<%=qidx%>(bit [31:0] agent_ids_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$], bit [31:0] wayvec_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$], bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[], int sp_ways[], int sp_size[], int aiu_qos_threshold[int], int dce_qos_threshold[int], int dmi_qos_threshold[int], int dmi_qos_rsved);
   <% } qidx++;%>
  <%}%>
  <%}%>

  function new(string name = "concerto_fullsys_test_ioaiu_csr", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new
  
endclass: concerto_fullsys_test_ioaiu_csr


//METHOD Definitions
///////////////////////////////////////////////////////////////////////////////// 
// #     #  #     #  #     #         ######   #     #     #      #####   #######  
// #     #  #     #  ##   ##         #     #  #     #    # #    #     #  #        
// #     #  #     #  # # # #         #     #  #     #   #   #   #        #        
// #     #  #     #  #  #  #         ######   #######  #     #   #####   #####    
// #     #   #   #   #     #         #        #     #  #######        #  #        
// #     #    # #    #     #         #        #     #  #     #  #     #  #        
//  #####      #     #     #  #####  #        #     #  #     #   #####   #######  
///////////////////////////////////////////////////////////////////////////////// 
function void concerto_fullsys_test_ioaiu_csr::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction : build_phase

task concerto_fullsys_test_ioaiu_csr::ncore_test_stimulus(uvm_phase phase); 
   `uvm_info("CONCERTO_FULLSYS_TEST_IOAIU_CSR", "START ncore_test_stimulus", UVM_LOW)
  #100ns;
  if (!test_cfg.k_csr_access_only)
      `uvm_error("REG_BASH_TEST", "you must use +k_csr_access_only=1")
<% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))){ 
    if(!(Array.isArray(obj.AiuInfo[idx].interfaces.axiInt))){ %>
      <% if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
    ioaiu_boot_seq<%=qidx%>(test_cfg.agent_ids_assigned_q,
                                       test_cfg.wayvec_assigned_q,
                                       test_cfg.k_sp_base_addr, 
                                       test_cfg.sp_ways,
                                       test_cfg.sp_size,
                                       test_cfg.aiu_qos_threshold,
                                       test_cfg.dce_qos_threshold,
                                       test_cfg.dmi_qos_threshold,
                                       test_cfg.dmi_qos_rsved);
    <% } } %>
<% qidx++;  }}%>

    ev_sim_done.trigger();
   `uvm_info("CONCERTO_FULLSYS_TEST_IOAIU_CSR", "END ncore_test_stimulus", UVM_LOW)
endtask:ncore_test_stimulus

<% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))){ 
    if(obj.AiuInfo[idx].fnCsrAccess == 1 && !(Array.isArray(obj.AiuInfo[idx].interfaces.axiInt))){ %>
task concerto_fullsys_test_ioaiu_csr::ioaiu_boot_seq<%=qidx%>(bit [31:0] agent_ids_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$], bit [31:0] wayvec_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$], bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[], int sp_ways[], int sp_size[], int aiu_qos_threshold[int], int dce_qos_threshold[int], int dmi_qos_threshold[int], int dmi_qos_rsved
);
    // For IOAIU CSR Seq
    ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;
    bit [31:0] data;
    bit [31:0] infor;
    // For Initiator IOAIU
    bit [7:0] ioaiu_rpn; // Assuming expected value to be 0
    bit [3:0] ioaiu_nrri; // Assuming expected value to be 0
    // System Census 
    bit [7:0] nAIUs; // Max 128
    bit [5:0] nDCEs; // Max 32
    bit [5:0] nDMIs; // Max 32
    bit [5:0] nDIIs; // Max 32 or nDIIs
    bit       nDVEs; // Max 1
    // For interleaving
    bit [4:1] AMIGS;
    // Addr_Mgr
    ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];
    bit [7:0] rpn;
    bit [7:0] cur_rpn;
    int qos_threshold;
    bit [<%=obj.wSysAddr-1%>:0] ScPadBaseAddr;
    bit ScPadEn;
    bit [31:0] transorder_mode;
    bit k_csr_access_only;
    bit nonblocking;								   
    bit sys_event_disable;
    string temp_string="";
    bit t_boot_from_ioaiu=1;
    int chiaiu_timeout_val;
    int ioaiu_timeout_val;
    string dce_credit_msg="";
    int new_dce_credits;
    int     use_sw_crdt_mgr_cls;
    bit [31:0]credit_limit_sys_dii_access_aiu; 
    int this_ioaiu_intf= <%=aiu_rpn[idx]%>; //<%=obj.AiuInfo[idx].rpn%>;  //<%=qidx%>;
    int find_this_ioaiu_intf=0;
    bit ccp_allocen;
    bit ccp_lookupen ;
    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] temp_addr; 
 // #Stimulus.FSYS.address_dec_error.illegalCSRaccess.ioaiu
    bit k_decode_err_illegal_acc_format_test_unsupported_size;
    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] all_dmi_dii_start_addr[int][$]; 
    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] all_dii_start_addr[int][$]; 
    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] all_dmi_start_addr[int][$]; 

    if (!$value$plusargs("use_sw_crdt_mgr_cls=%d",use_sw_crdt_mgr_cls)) begin
        use_sw_crdt_mgr_cls = 0;
    end
    if (!$value$plusargs("credit_limit_sys_dii_access_aiu=%h",credit_limit_sys_dii_access_aiu)) begin
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$psprintf("Not setting credit_limit_sys_dii_access_aiu plusarg..."),UVM_LOW)
    end
   
    if (!$value$plusargs("chiaiu_timeout_val=%d",chiaiu_timeout_val)) begin
        chiaiu_timeout_val= 2000;
    end
    if (!$value$plusargs("ioaiu_timeout_val=%d",ioaiu_timeout_val)) begin
        ioaiu_timeout_val= 2000;
    end											   
    if(!($value$plusargs("ccp_lookupen=%0d",ccp_lookupen))) begin
        ccp_lookupen  = 1;
    end
    if(!($value$plusargs("ccp_allocen=%0d",ccp_allocen))) begin
        ccp_allocen  = 1;
    end
    if (!$value$plusargs("k_decode_err_illegal_acc_format_test_unsupported_size=%d",k_decode_err_illegal_acc_format_test_unsupported_size)) begin
        k_decode_err_illegal_acc_format_test_unsupported_size = 0;
    end
   

    act_cmd_skid_buf_size["DCE"] = new[1];
    act_cmd_skid_buf_size["DCE"][0] = 0; //Default value First index zero. If nDCE>1, It will be equal to DCE0 skidbufsize and then skidbufsize of rest of DCEs will be filled in rest of elements
    act_cmd_skid_buf_arb["DCE"] = new[1];
    act_cmd_skid_buf_arb["DCE"][0] = 0; //Default value First index zero. If nDCE>1, It will be equal to DCE0 skidbufarb and then skidbufarb of rest of DCEs will be filled in rest of elements
    act_cmd_skid_buf_size["DMI"] = new[1];
    act_cmd_skid_buf_size["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufsize and then skidbufsize of rest of DMIs will be filled in rest of elements
    act_cmd_skid_buf_arb["DMI"] = new[1];
    act_cmd_skid_buf_arb["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufarb and then skidbufarb of rest of DMIs will be filled in rest of elements
    act_mrd_skid_buf_size["DMI"] = new[1];
    act_mrd_skid_buf_size["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufsize and then skidbufsize of rest of DMIs will be filled in rest of elements
    act_mrd_skid_buf_arb["DMI"] = new[1];
    act_mrd_skid_buf_arb["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufarb and then skidbufarb of rest of DMIs will be filled in rest of elements
    act_cmd_skid_buf_size["DII"] = new[1];
    act_cmd_skid_buf_size["DII"][0] = 0; //Default value First index zero. If nDII>1, It will be equal to DII0 skidbufsize and then skidbufsize of rest of DIIs will be filled in rest of elements
    act_cmd_skid_buf_arb["DII"] = new[1];
    act_cmd_skid_buf_arb["DII"][0] = 0; //Default value First index zero. If nDII>1, It will be equal to DII0 skidbufarb and then skidbufarb of rest of DIIs will be filled in rest of elements

    exp_cmd_skid_buf_size["DCE"] = new[1];
    exp_cmd_skid_buf_size["DCE"][0] = 0; //Default value First index zero. If nDCE>1, It will be equal to DCE0 skidbufsize and then skidbufsize of rest of DCEs will be filled in rest of elements
    exp_cmd_skid_buf_arb["DCE"] = new[1];
    exp_cmd_skid_buf_arb["DCE"][0] = 0; //Default value First index zero. If nDCE>1, It will be equal to DCE0 skidbufarb and then skidbufarb of rest of DCEs will be filled in rest of elements
    exp_cmd_skid_buf_size["DMI"] = new[1];
    exp_cmd_skid_buf_size["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufsize and then skidbufsize of rest of DMIs will be filled in rest of elements
    exp_cmd_skid_buf_arb["DMI"] = new[1];
    exp_cmd_skid_buf_arb["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufarb and then skidbufsize of rest of DMIs will be filled in rest of elements
    exp_mrd_skid_buf_size["DMI"] = new[1];
    exp_mrd_skid_buf_size["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufsize and then skidbufsize of rest of DMIs will be filled in rest of elements
    exp_mrd_skid_buf_arb["DMI"] = new[1];
    exp_mrd_skid_buf_arb["DMI"][0] = 0; //Default value First index zero. If nDMI>1, It will be equal to DMI0 skidbufarb and then skidbufarb of rest of DMIs will be filled in rest of elements
    exp_cmd_skid_buf_size["DII"] = new[1];
    exp_cmd_skid_buf_size["DII"][0] = 0; //Default value First index zero. If nDII>1, It will be equal to DII0 skidbufsize and then skidbufsize of rest of DIIs will be filled in rest of elements
    exp_cmd_skid_buf_arb["DII"] = new[1];
    exp_cmd_skid_buf_arb["DII"][0] = 0; //Default value First index zero. If nDII>1, It will be equal to DII0 skidbufarb and then skidbufarb of rest of DIIs will be filled in rest of elements

    if(!$value$plusargs("k_csr_access_only=%d",k_csr_access_only))begin
       k_csr_access_only = 0;
    end

    if(!$value$plusargs("nonblocking_csr=%d", nonblocking)) begin
        nonblocking = 0;
    end

    if(!$value$plusargs("sys_event_disable=%d", sys_event_disable)) begin
        sys_event_disable = 0;
    end
    // set csrBaseAddr													
    addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE ; //  addr = {<%=obj.AiuInfo[idx].CsrInfo.csrBaseAddress.replace("0x","'h")%>, 8'hFF, 12'h000}; 
 
 if(!$test$plusargs("disable_boot_tasks") || !$test$plusargs("k_csr_access_only")) begin
    `uvm_error("IOAIU<%=qidx%>_CSR_SEQ", " this test case must use +disable_boot_tasks & k_csr_access_only")
 end
 
 begin:_boot_ioaiu 

// #Check.FSYS.csr.NRSbaseAddr
    if(ncore_config_pkg::ncoreConfigInfo::program_nrs_base) begin
      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$psprintf("Running test concerto_nrs_reg_test ..."),UVM_LOW)
      for(int i=0; i<<%=numAiuRpns%>; i++) begin
        if(find_this_ioaiu_intf==this_ioaiu_intf) begin
            //addr = ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i];
            `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$psprintf("Assigning NRSBASE to %h",ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i]),UVM_LOW)
            addr[19:12]=this_ioaiu_intf;// Register Page Number
            addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.NRSBAR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUNRSBAR.get_offset()<%}%>;
            rw_tsks.read_csr<%=qidx%>(addr,data);
            `uvm_info("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("Reading NRSBAR ADDR 0x%0h DATA 0x%0h", addr, data),UVM_LOW)
            if(ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE[51:20]==data)
              `uvm_info("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("Checking NRSBAR ADDR 0x%0h EXP-DATA 0x%0h ACT-DATA 0x%0h", addr, ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE[51:20], data),UVM_LOW)
            else
              `uvm_error("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("Checking NRSBAR ADDR 0x%0h EXP-DATA 0x%0h ACT-DATA 0x%0h. Found Mismatch!",  addr, ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE[51:20], data))

            addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.NRSBHR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUNRSBHR.get_offset()<%}%>;
            data = ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i][51:20]; 
            `uvm_info("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("Writing NRSBHR ADDR 0x%0h DATA 0x%0h",  addr, data),UVM_LOW)
            rw_tsks.write_csr<%=qidx%>(addr,data,  nonblocking);

            do begin
                addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.NRSBLR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUNRSBLR.get_offset()<%}%>;
                rw_tsks.read_csr<%=qidx%>(addr,data);
                `uvm_info("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("Reading NRSBLR ADDR 0x%0h DATA 0x%0h",  addr, data),UVM_LOW)
            end
            while(data[31]==0);
            `uvm_info("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("NRSBLR.BALoaded is set"),UVM_LOW)
            #10ns;
            addr = ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i];
            `uvm_info("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("Changing NRS_REGION_BASE from 0x%h to 0x%h",ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE,ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i]),UVM_LOW)
            ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE = ncore_config_pkg::ncoreConfigInfo::NEW_NRS_REGION_BASE_PER_AIU[i];
        end // if(find_this_ioaiu_intf==this_ioaiu_intf) begin
        find_this_ioaiu_intf = find_this_ioaiu_intf + 1;
        //if(ncore_config_pkg::ncoreConfigInfo::get_native_interface(i) inside {ncore_config_pkg::ncoreConfigInfo::ACE_AIU,ncore_config_pkg::ncoreConfigInfo::ACE_LITE_AIU,ncore_config_pkg::ncoreConfigInfo::AXI_AIU,ncore_config_pkg::ncoreConfigInfo::IO_CACHE_AIU,ncore_config_pkg::ncoreConfigInfo::ACE_LITE_E_AIU}) begin
        //  find_this_ioaiu_intf = find_this_ioaiu_intf + 1;
        //  `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$psprintf("RPN %0d is tied to %0s %0d %0d",i,ncore_config_pkg::ncoreConfigInfo::get_native_interface(i).name(),find_this_ioaiu_intf,this_ioaiu_intf),UVM_LOW)
        //end
      end // for(int i=0; i<<%=numAiuRpns%>; i++) begin
    end // if(ncore_config_pkg::ncoreConfigInfo::program_nrs_base) begin

    // TODO: Assuming(1) the Reset value of NRSBAR = 0x0 and (2)this Boot_seq will work on 1st Chi-BFM
    // (1) Read USIDR 
    addr[19:0] = 20'hFF000;   
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading USIDR (0x%0h)", addr), UVM_LOW)
    if (k_decode_err_illegal_acc_format_test_unsupported_size) begin
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Checking illegal_acc_format_test_unsupported_size for read access"), UVM_NONE)
        rw_tsks.k_decode_err_illegal_acc_format_test_unsupported_size =1;
        val_change_k_decode_err_illegal_acc_format_test_unsupported_size.trigger(null);
        rw_tsks.read_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Done Checking illegal_acc_format_test_unsupported_size for read access"), UVM_NONE)
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Continue regular flow of csr sequence, read access should not return DECERR response. Setting k_decode_err_illegal_acc_format_test_unsupported_size to 0"), UVM_NONE)
        k_decode_err_illegal_acc_format_test_unsupported_size = 0;
        rw_tsks.k_decode_err_illegal_acc_format_test_unsupported_size =0;
        val_change_k_decode_err_illegal_acc_format_test_unsupported_size.trigger(null);
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Triggering uvm_event val_change_k_decode_err_illegal_acc_format_test_unsupported_size"), UVM_MEDIUM)
         addr[19:12]=<%=aiu_rpn[idx]%>;// Register Page Number
         addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUUESR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUUESR.get_offset()<%}%>;
        rw_tsks.read_csr<%=qidx%>(addr,data);
        if(data[0]==0 && !AIUUEDR_DecErrDetEn) begin
            `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0(=No Error is logged). That is expected"), UVM_MEDIUM)
        end else begin
            if(!AIUUEDR_DecErrDetEn) begin
                `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 1. That is not expected(=No Error is logged)"))
            end else begin
                if(data[7:4]==7) begin // Error Type
                 `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrType is found 7(=Dec Error). That is expected"), UVM_MEDIUM)
                end else begin
                     `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrType isn't 7. That is not expected we have: %0h",data[7:4]))
                end
                 if(data[15:12]==2) begin // Error Info
                      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrInfo is found 2(=illegal CSR access). That is expected"), UVM_MEDIUM)
                     end else begin
                     `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrInfo isn't 2. That is not expected(=illegal CSR access) we have: %0h",data[15:12]))
                     end
                `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing AIUUESR.ErrVld to clear the error"), UVM_MEDIUM)
                data=0;data[0]=1;
                rw_tsks.write_csr<%=qidx%>(addr,data,nonblocking);
                rw_tsks.read_csr<%=qidx%>(addr,data);
                if(data[0]==0 )
                    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0, meaning Error is cleared. That is expected"), UVM_MEDIUM)
                else
                    `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is not empty, meaning Error is not cleared."))
            end
        end
    end
    addr[19:0] = 20'hFF000;  
  
   if($test$plusargs("ioaiu_csr_ns_access")) rw_tsks.ioaiu_csr_ns_access=1;
   rw_tsks.read_csr<%=qidx%>(addr,data);
   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("USIDR = 0x%0h", data), UVM_LOW)
   if(data[31]) begin // valid
        ioaiu_rpn  = data[ 7:0];
        ioaiu_nrri = data[11:8];
	`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("USIDR.RPN=%0d, USIDR.NRRI=%0d", ioaiu_rpn, ioaiu_nrri), UVM_LOW)
    end else begin
        if(!($test$plusargs("ioaiu_csr_ns_access"))) begin
        `uvm_error("IOAIU<%=qidx%>BOOT_SEQ","Valid bit not asserted in USIDR register of Initiating IOAIU-AIU")
        end
    end
    rw_tsks.ioaiu_csr_ns_access=0;
  
   rw_tsks.read_csr<%=qidx%>(addr,data);
   if(data[31]) begin // valid
        ioaiu_rpn  = data[ 7:0];
        ioaiu_nrri = data[11:8];
	`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("USIDR.RPN=%0d, USIDR.NRRI=%0d", ioaiu_rpn, ioaiu_nrri), UVM_LOW)
    end else begin
        if(!($test$plusargs("ioaiu_csr_ns_access"))) begin
        `uvm_error("IOAIU<%=qidx%>BOOT_SEQ","Valid bit not asserted in USIDR register of Initiating IOAIU-AIU")
        end
    end

    // (2) Read NRRUCR
    addr[11:0] = m_concerto_env.m_regs.sys_global_register_blk.GRBUNRRUCR.get_offset();
    data = 0;
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading NRRUCR (0x%0h)", addr), UVM_LOW)
    if($test$plusargs("ioaiu_csr_ns_access")) rw_tsks.ioaiu_csr_ns_access=1;
    rw_tsks.read_csr<%=qidx%>(addr,data);
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("NRRUCR = 0x%0h", data), UVM_LOW)
    if (data == 0) begin
       if(!($test$plusargs("ioaiu_csr_ns_access"))) begin
        `uvm_error("IOAIU<%=qidx%>BOOT_SEQ","NRRUCR register is 0")
       end
    end
    rw_tsks.ioaiu_csr_ns_access=0;
    rw_tsks.read_csr<%=qidx%>(addr,data);


`ifndef USE_VIP_SNPS
    if (k_nrsar_test && k_csr_access_only) begin
        rw_tsks.set_aiu_nrsar_reg<%=qidx%>();
    end
`endif
    nAIUs = data[ 7: 0];
    nDCEs = data[13: 8];
    nDMIs = data[19:14];
    nDIIs = data[25:20];
    nDVEs = data[26:26];
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$sformatf("nAIUs:%0d nDCEs:%0d nDMIs:%0d nDIIs:%0d nDVEs:%0d",nAIUs,nDCEs,nDMIs,nDIIs,nDVEs),UVM_NONE)

    if(k_csr_access_only==1) begin
        sys_reg_exp_data_val["GRBUCSSFIDR"]  = new[<%=obj.SnoopFilterInfo.length%>];
        sys_reg_exp_data_mask["GRBUCSSFIDR"] = new[<%=obj.SnoopFilterInfo.length%>];
        <%for(var tempidx = 0; tempidx < obj.SnoopFilterInfo.length; tempidx++) {%>
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>][19:0]  = <%=obj.SnoopFilterInfo[tempidx].nSets%> -1;
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>][25:20] = <%=obj.SnoopFilterInfo[tempidx].nWays%> -1;
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>][28:26] = <%=(obj.SnoopFilterInfo[tempidx].nVictimEntries>0) ? 7 : 3%>;
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>][31:29] = 0;

            sys_reg_exp_data_mask["GRBUCSSFIDR"][<%=tempidx%>][31:0] = 32'hFFFF_FFFF;
            sys_reg_exp_data_mask["GRBUCSSFIDR"][<%=tempidx%>][28:26] = 3'h0;
            addr[11:0] = m_concerto_env.m_regs.sys_global_register_blk.GRBUCSSFIDR<%=tempidx%>.get_offset() /*+ (<%=tempidx%> * 4)*/;
            data = 0;
            rw_tsks.read_csr<%=qidx%>(addr,data);
            `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading GRBUCSSFIDR<%=tempidx%>(0x%0h)= 0x%0h",addr,data), UVM_NONE)
            sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>] = sys_reg_exp_data_mask["GRBUCSSFIDR"][<%=tempidx%>] & sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>];
            data = sys_reg_exp_data_mask["GRBUCSSFIDR"][<%=tempidx%>] & data; 
            `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUCSSFIDR<%=tempidx%>(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>]), UVM_NONE)
            // #Check.FSYS.csr.Check.GRBUCSSFIDR
            if(data != sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>]) begin 
              `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUCSSFIDR<%=tempidx%>(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUCSSFIDR"][<%=tempidx%>]))
              end
        <%}%>

        sys_reg_exp_data_val["GRBUNRRIR"]  = new[1];
        sys_reg_exp_data_mask["GRBUNRRIR"] = new[1];
        sys_reg_exp_data_val["GRBUNRRIR"][0][3:0]   = 0;
        sys_reg_exp_data_val["GRBUNRRIR"][0][15:4]  = 0;
        sys_reg_exp_data_val["GRBUNRRIR"][0][19:16] = 0;
        sys_reg_exp_data_val["GRBUNRRIR"][0][31:20] = 0;

        sys_reg_exp_data_mask["GRBUNRRIR"][0][31:0] = 32'hFFFF_FFFF;

        addr[11:0] = m_concerto_env.m_regs.sys_global_register_blk.GRBUNRRIR.get_offset();
        data = 0;
        rw_tsks.read_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading GRBUNRRIR(0x%0h)= 0x%0h",addr,data), UVM_NONE)
        sys_reg_exp_data_val["GRBUNRRIR"][0] = sys_reg_exp_data_mask["GRBUNRRIR"][0] & sys_reg_exp_data_val["GRBUNRRIR"][0];
        data = sys_reg_exp_data_mask["GRBUNRRIR"][0] & data; 
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUNRRIR(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNRRIR"][0]), UVM_NONE)
        // #Check.FSYS.csr.Check.GRBUNRRIR
        if(data != sys_reg_exp_data_val["GRBUNRRIR"][0]) begin
          `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUNRRIR(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNRRIR"][0]))
         end

        sys_reg_exp_data_val["GRBUENGIDR"]  = new[1];
        sys_reg_exp_data_mask["GRBUENGIDR"] = new[1];
        sys_reg_exp_data_val["GRBUENGIDR"][0][31:0] = <%=obj.AiuInfo[0].engVerId%>;

        sys_reg_exp_data_mask["GRBUENGIDR"][0][31:0] = 32'hFFFF_FFFF;

        addr[11:0] = m_concerto_env.m_regs.sys_global_register_blk.GRBUENGIDR.get_offset();
        data = 0;
        rw_tsks.read_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading GRBUENGIDR(0x%0h)= 0x%0h",addr,data), UVM_NONE)
        sys_reg_exp_data_val["GRBUENGIDR"][0] = sys_reg_exp_data_mask["GRBUENGIDR"][0] & sys_reg_exp_data_val["GRBUENGIDR"][0];
        data = sys_reg_exp_data_mask["GRBUENGIDR"][0] & data; 
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUENGIDR(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUENGIDR"][0]), UVM_NONE)
        // #Check.FSYS.csr.Check.GRBUENGIDR
        if(data != sys_reg_exp_data_val["GRBUENGIDR"][0]) begin
          `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUENGIDR(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUENGIDR"][0]))
          end

        sys_reg_exp_data_val["GRBUNRRUCR"]  = new[1];
        sys_reg_exp_data_mask["GRBUNRRUCR"] = new[1];
        sys_reg_exp_data_val["GRBUNRRUCR"][0][7:0]  =<%=obj.AiuInfo.length%>;
        sys_reg_exp_data_val["GRBUNRRUCR"][0][13:8] =<%=obj.DceInfo.length%>;
        sys_reg_exp_data_val["GRBUNRRUCR"][0][19:14]=<%=obj.DmiInfo.length%>;
        sys_reg_exp_data_val["GRBUNRRUCR"][0][25:20]=<%=obj.DiiInfo.length%>;
        sys_reg_exp_data_val["GRBUNRRUCR"][0][31:26]=<%=obj.DveInfo.length%>;

        sys_reg_exp_data_mask["GRBUNRRUCR"][0][31:0] = 32'hFFFF_FFFF;

        addr[11:0] = m_concerto_env.m_regs.sys_global_register_blk.GRBUNRRUCR.get_offset();
        data = 0;
        rw_tsks.read_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading GRBUNRRUCR(0x%0h)= 0x%0h",addr,data), UVM_NONE)
        sys_reg_exp_data_val["GRBUNRRUCR"][0] = sys_reg_exp_data_mask["GRBUNRRUCR"][0] & sys_reg_exp_data_val["GRBUNRRUCR"][0];
        data = sys_reg_exp_data_mask["GRBUNRRUCR"][0] & data; 
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUNRRUCR(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNRRUCR"][0]), UVM_NONE)
        // #Check.FSYS.csr.Check.GRBUNRRUCR
        if(data != sys_reg_exp_data_val["GRBUNRRUCR"][0]) begin
          `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUNRRUCR(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNRRUCR"][<%=tempidx%>]))
          end

        sys_reg_exp_data_val["GRBUNSIDR"]  = new[1];
        sys_reg_exp_data_mask["GRBUNSIDR"] = new[1];
        sys_reg_exp_data_val["GRBUNSIDR"][0][15:0]  = <%=obj.AiuInfo[0].implVerId%>;
        sys_reg_exp_data_val["GRBUNSIDR"][0][19:16] = <%=obj.DceInfo[0].wCacheLineOffset%> - 5;
        sys_reg_exp_data_val["GRBUNSIDR"][0][31:20] = <%=obj.SnoopFilterInfo.length%> - 1;

        sys_reg_exp_data_mask["GRBUNSIDR"][0][31:0] = 32'hFFFF_FFFF;

        addr[11:0] = m_concerto_env.m_regs.sys_global_register_blk.GRBUNSIDR.get_offset();
        data = 0;
        rw_tsks.read_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Reading GRBUNSIDR(0x%0h)= 0x%0h",addr,data), UVM_NONE)
        sys_reg_exp_data_val["GRBUNSIDR"][0] = sys_reg_exp_data_mask["GRBUNSIDR"][0] & sys_reg_exp_data_val["GRBUNSIDR"][0];
        data = sys_reg_exp_data_mask["GRBUNSIDR"][0] & data; 
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUNSIDR(0x%0h): ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNSIDR"][0]), UVM_NONE)
        // #Check.FSYS.csr.Check.GRBUNSIDR
        if(data != sys_reg_exp_data_val["GRBUNSIDR"][0]) begin
          `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("GRBUNSIDR(0x%0h) mismatch: ActExpData 0x%0h ExpData 0x%0h",addr,data,sys_reg_exp_data_val["GRBUNSIDR"][0]))
        end
    end

    if(nDCEs>0) begin
      act_cmd_skid_buf_size["DCE"] = new[nDCEs];
      act_cmd_skid_buf_arb["DCE"] = new[nDCEs];
      exp_cmd_skid_buf_size["DCE"] = new[nDCEs];
      exp_cmd_skid_buf_arb["DCE"] = new[nDCEs];
      dce_connected = new[nDCEs];
      dce_dmi_connected = new[nDCEs];
    end

    if(nDMIs>0) begin
      act_cmd_skid_buf_size["DMI"] = new[nDMIs];
      act_mrd_skid_buf_size["DMI"] = new[nDMIs];
      act_cmd_skid_buf_arb["DMI"] = new[nDMIs];
      act_mrd_skid_buf_arb["DMI"] = new[nDMIs];
      exp_cmd_skid_buf_size["DMI"] = new[nDMIs];
      exp_mrd_skid_buf_size["DMI"] = new[nDMIs];
      exp_cmd_skid_buf_arb["DMI"] = new[nDMIs];
      exp_mrd_skid_buf_arb["DMI"] = new[nDMIs];
      dmi_connected = new[nDMIs];
    end

    if(nDIIs>0) begin
      act_cmd_skid_buf_size["DII"] = new[nDIIs];
      act_cmd_skid_buf_arb["DII"] = new[nDIIs];
      exp_cmd_skid_buf_size["DII"] = new[nDIIs];
      exp_cmd_skid_buf_arb["DII"] = new[nDIIs];
      dii_connected = new[nDIIs];
    end

      aiu_dce_connect = new[nAIUs];
      aiu_dmi_connect = new[nAIUs];
      aiu_dii_connect = new[nAIUs];
      dce_dmi_connect = new[nDCEs];
    
<%var tempidx = 0;%>
<%for(var tempidx = 0; tempidx < obj.nDCEs; tempidx++) {%>
      exp_cmd_skid_buf_size["DCE"][<%=tempidx%>] = <%=obj.DceInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DCE"][<%=tempidx%>] = <%=obj.DceInfo[tempidx].nCMDSkidBufArb%>;
<%}%>

<%var tempidx = 0;%>
<%for(var tempidx = 0; tempidx < obj.nDMIs; tempidx++) {%>
      exp_cmd_skid_buf_size["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nCMDSkidBufArb%>;
      exp_mrd_skid_buf_size["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nMrdSkidBufSize%>;
      exp_mrd_skid_buf_arb["DMI"][<%=tempidx%>] = <%=obj.DmiInfo[tempidx].nMrdSkidBufArb%>;
<%}%>

<%var tempidx = 0;%>
<%for(var tempidx = 0; tempidx < obj.nDIIs; tempidx++) {%>
      exp_cmd_skid_buf_size["DII"][<%=tempidx%>] = <%=obj.DiiInfo[tempidx].nCMDSkidBufSize%>;
      exp_cmd_skid_buf_arb["DII"][<%=tempidx%>] = <%=obj.DiiInfo[tempidx].nCMDSkidBufArb%>;
<%}%>

<%var tempidx = 0;%>
<% for(var tempidx = 0; tempidx < obj.nAIUs; tempidx++) {%>
    aiu_dmi_connect[<%=tempidx%>] = 'h<%=obj.AiuInfo[tempidx].hexAiuDmiVec%>;
    aiu_dii_connect[<%=tempidx%>] = 'h<%=obj.AiuInfo[tempidx].hexAiuDiiVec%>;
    aiu_dce_connect[<%=tempidx%>] = 'h<%=obj.AiuInfo[tempidx].hexAiuDceVec%>;
<%}%>

   for(int k = 0; k < <%=obj.nAIUs%>; k++)begin
     for(int j=0;j<nDCEs;j++)begin
       if(aiu_dce_connect[k][((nDCEs-1)-j)]) dce_connected[j]++;
     end
     for(int j=0;j<nDMIs;j++)begin
       if(aiu_dmi_connect[k][((nDMIs-1)-j)]) dmi_connected[j]++;
     end
     for(int j=0;j<nDIIs;j++)begin
       if(aiu_dii_connect[k][((nDIIs-1)-j)]) dii_connected[j]++;
     end
   end


    // (3) Configure all the General Purpose registers
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ","Configuring GPRs", UVM_LOW)
    csrq = ncore_config_pkg::ncoreConfigInfo::get_all_gpra();

    foreach (csrq[i]) begin
      `uvm_info(get_name(),
          $psprintf("csrq[memregion_id:%0d] --> unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d", i,
              csrq[i].unit.name(), csrq[i].mig_nunitid,
              csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),
          UVM_LOW) 
    end

    rpn = 0; //ioaiu_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number
        if(ncoreConfigInfo::picked_dmi_igs > 0) begin
           addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUAMIGR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUAMIGR.get_offset()<%}%>;
           data[0] = 1;
           data[4:1] = ncoreConfigInfo::picked_dmi_igs;
           data[31:5] = 0;
           rw_tsks.write_chk<%=qidx%>(addr,data, k_csr_access_only, nonblocking);
	end
        foreach (csrq[ig]) begin
           //Write to GPR register sets with appropriate values.
           //GPRBLR : 12'b01XX XXXX 0100 ; addr[11:0] = {2'b01,ig[5:0],4'h4};
           addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUGPRBLR0.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUGPRBLR0.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUGPRBLR0")%>;=12'h<%=getIoOffset("XAIUGPRBLR0")%>;
           addr[9:4] = ig[5:0];
           data[31:0] = csrq[ig].low_addr;
	   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s low_addr 0x%0h GPRBLR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].low_addr, addr, data), UVM_LOW)
          <% if (obj.wSysAddr > 44) {%> 
               temp_addr[43:12] = csrq[ig].low_addr;
            <%} else {%>
              temp_addr[ncoreConfigInfo::W_SEC_ADDR-1:12] = csrq[ig].low_addr;
            <%}%>
           if (!$value$plusargs("k_decode_err_illegal_acc_format_test_unsupported_size=%d",k_decode_err_illegal_acc_format_test_unsupported_size)) begin
               k_decode_err_illegal_acc_format_test_unsupported_size = 0;
           end
           if (k_decode_err_illegal_acc_format_test_unsupported_size) begin
               `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Checking illegal_acc_format_test_unsupported_size for write access"), UVM_NONE)
               rw_tsks.k_decode_err_illegal_acc_format_test_unsupported_size =1;
               k_decode_err_illegal_acc_format_test_unsupported_size = 1;
               val_change_k_decode_err_illegal_acc_format_test_unsupported_size.trigger(null);
               rw_tsks.write_csr<%=qidx%>(addr,data, nonblocking);
               `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Done Checking illegal_acc_format_test_unsupported_size for write access"), UVM_NONE)
               `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Continue regular flow of csr sequence, write access should not return DECERR response. Setting k_decode_err_illegal_acc_format_test_unsupported_size to 0"), UVM_NONE)
               rw_tsks.k_decode_err_illegal_acc_format_test_unsupported_size =0;
               k_decode_err_illegal_acc_format_test_unsupported_size = 0;
               val_change_k_decode_err_illegal_acc_format_test_unsupported_size.trigger(null);
               `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Triggering uvm_event val_change_k_decode_err_illegal_acc_format_test_unsupported_size"), UVM_MEDIUM)
               `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Checking XAIUUESR.ErrVld."), UVM_MEDIUM)
                addr[19:12]=<%=aiu_rpn[idx]%>;// Register Page Number
                addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUUESR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUUESR.get_offset()<%}%>;
               rw_tsks.read_csr<%=qidx%>(addr,data);
               if(data[0]==0 && !AIUUEDR_DecErrDetEn) begin
                   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0(=No Error is logged). That is expected"), UVM_MEDIUM)
               end else begin
                   if(!AIUUEDR_DecErrDetEn) begin
                       `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 1. That is not expected(= Error is logged)"))
                   end else begin
                     if(data[7:4]==7) begin //ErrType
                      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrType is found 7(=Dec error). That is expected"), UVM_MEDIUM)
                     end else begin
                     `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrType isn't 7. That is not expected(=Dec Error) we have: %0h",data[7:4]))
                     end
                     if(data[15:12]==2) begin
                      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrInfo is found 2(=illegal CSR access). That is expected"), UVM_MEDIUM)
                     end else begin
                     `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrInfo isn't 2. That is not expected(=illegal CSR access) we have: %0h",data[7:4]))
                     end
                     `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing AIUUESR.ErrVld to clear the error"), UVM_MEDIUM)
                     data=0;data[0]=1;
                     rw_tsks.write_csr<%=qidx%>(addr,data,nonblocking);
                     rw_tsks.read_csr<%=qidx%>(addr,data);
                     if(data[0]==0 )
                      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0, meaning Error is cleared. That is expected"), UVM_MEDIUM)
                     else
                      `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is not empty, meaning Error is not cleared."))
                   end
               end
               `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Enabling XAIUUEDR.DecErrDetEn"), UVM_MEDIUM)
                addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUUEDR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUUEDR.get_offset()<%}%>;
               data=0;
               data[3] = 1;
               AIUUEDR_DecErrDetEn = 1;
               rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
           end
           addr[19:12]=rpn;// Register Page Number
           addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUGPRBLR0.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUGPRBLR0.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUGPRBLR0")%>;=12'h<%=getIoOffset("XAIUGPRBLR0")%>;
           addr[9:4] = ig[5:0];
           data[31:0] = csrq[ig].low_addr;
           if($test$plusargs("ioaiu_csr_ns_access")) begin 
            // Check WRITE ERROR with NS=nonsecure
            int read_data;
            rw_tsks.write_csr<%=qidx%>(addr,0); // first reset
            rw_tsks.ioaiu_csr_ns_access=1;
            rw_tsks.write_csr<%=qidx%>(addr,data); // write with NS=nonsecure => error
            rw_tsks.ioaiu_csr_ns_access=0;
            rw_tsks.read_csr<%=qidx%>(addr,read_data); // read with NS=secure => no error
            if((data == read_data) && (csrq[ig].low_addr != 0)) `uvm_error("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("IOAIU_CSR_NS_ACCESS read data =%0h should be 0 due to nosecure write access",read_data))
           end  
           data[31:0] = csrq[ig].low_addr;
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

           //GPRBHR : 12'b01XX XXXX 1000 ; addr[11:0] = {2'b01,ig[5:0],4'h8};
           addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUGPRBHR0.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUGPRBHR0.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUGPRBHR0")%>;=12'h<%=getIoOffset("XAIUGPRBHR0")%>;
           addr[9:4] = ig[5:0];
           //data =0;
           //data[7:0] = csrq[ig].upp_addr;
           data[31:0] = csrq[ig].upp_addr;
	   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s upp_addr 0x%0h GPRHLR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].upp_addr, addr, data), UVM_LOW)
           <% if (obj.wSysAddr > 44) {%> 
               temp_addr[ncoreConfigInfo::W_SEC_ADDR-1:44] = test_cfg.csrq[ig].upp_addr; 
            <%}%>
           all_dmi_dii_start_addr[rpn].push_back(temp_addr);
           if(csrq[ig].unit.name=="DII") begin
               all_dii_start_addr[rpn].push_back(temp_addr);
           end else begin
               all_dmi_start_addr[rpn].push_back(temp_addr);
           end
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

           //GPRAR : 12'b01XX XXXX 0000 ; addr[11:0] = {2'b01,ig[5:0],4'h0};
           addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUGPRAR0.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUGPRAR0.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUGPRAR0")%>;=12'h<%=getIoOffset("XAIUGPRAR0")%>;
           addr[9:4] = ig[5:0];
           data =0; // Reset value
           data[31]    = 1; // Valid
           data[30]    = (csrq[ig].unit == ncore_config_pkg::ncoreConfigInfo::DII ? 1 : 0); // Home Unit Type
           data[25:20] = csrq[ig].size; // interleave group member size(2^(size+12) bytes)
           data[13:9]  = csrq[ig].mig_nunitid;
           if ($test$plusargs("random_gpra_nsx")) begin
            data[7:6]   = csrq[ig].nsx;// randomize GPRAR.NS filed NSX[0] = NS :NS=0 Only secure transactions NS=1 All transactions are accepted
           end 
           else if ($test$plusargs("gpra_secure_uncorr_err")) begin
             //#Stimulus.FSYS.address_dec_error.illegal_non_secure_txn
             data[7:6]   = 'h0;  
           end 
           else begin
             data[7:6]   = 'h1;  
           end
           begin:_gprar_nc // if GPRAR.NC field exist, write it
            //#Stimulus.FSYS.dii_noncoh_txn  
            //#Stimulus.FSYS.GPRAR.NC_zero
            //#Stimulus.FSYS.GPRAR.NC_one
            uvm_reg gprar;
            uvm_reg  xaiupctcr ;
            ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t xaiupctcr_addr_offset;
            ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t xaiupctcr_recompute_addr = addr; // get the base address + rpn;
            //gprar= m_concerto_env.m_regs.default_map.get_reg_by_offset(addr);
            gprar= m_concerto_env.m_regs.default_map.get_reg_by_offset({ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE_COPY[51:20],addr[19:0]});
            xaiupctcr= m_concerto_env.m_regs.get_reg_by_name("XAIUPCTCR"); // get the first register just to get the offset
            if (xaiupctcr) begin :_unless_one_pctcr //useCache
                xaiupctcr_addr_offset = xaiupctcr.get_offset(); // get lower address =register offset
                xaiupctcr_recompute_addr[11:0] = xaiupctcr_addr_offset[11:0];  // apply base address + rpn +  register offset
                //xaiupctcr = m_concerto_env.m_regs.default_map.get_reg_by_offset(xaiupctcr_recompute_addr);
                xaiupctcr = m_concerto_env.m_regs.default_map.get_reg_by_offset({ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE_COPY[51:20],xaiupctcr_recompute_addr[19:0]});
                if (xaiupctcr && xaiupctcr.get_field_by_name("LookupEn")) begin: _field_exist   // last check with "Lookup_en" field exit => useCache
                   data[5] = csrq[ig].nc ;
                end:_field_exist else begin:_no_field
                    if (gprar.get_field_by_name("NC")) data[5] = ($test$plusargs("coherent_dii")) ? csrq[ig].nc :1;  // if no useCache => AXI4 without proxycache => assert GPRAR.NCmode=1 by default
                end:_no_field
            end:_unless_one_pctcr else begin: _no_pctcr // no useCache
                if (gprar.get_field_by_name("NC")) data[5] =  ($test$plusargs("coherent_dii")) ? csrq[ig].nc :1;  // if no useCache => AXI4 without proxycache => assert GPRAR.NCmode=1 by default
            end:_no_pctcr
           end:_gprar_nc
           data[4:1]   = csrq[ig].order;//bit0(Hazard bit) is deprecated; CONC-11405
	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s size %0d order 0x%0h NC:%0h GPRAR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].size, csrq[ig].order, csrq[ig].nc,addr, data), UVM_LOW)
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
        end
        
        rpn++;
    end

    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        if (!$value$plusargs("k_decode_err_illegal_acc_format_test_unsupported_size=%d",k_decode_err_illegal_acc_format_test_unsupported_size)) begin
            k_decode_err_illegal_acc_format_test_unsupported_size = 0;
        end
        if (k_decode_err_illegal_acc_format_test_unsupported_size) begin
            `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Checking illegal_acc_format_test_unsupported_size for read access"), UVM_NONE)
            rw_tsks.k_decode_err_illegal_acc_format_test_unsupported_size =1;
            k_decode_err_illegal_acc_format_test_unsupported_size = 1;
            val_change_k_decode_err_illegal_acc_format_test_unsupported_size.trigger(null);
            rw_tsks.read_csr<%=qidx%>(addr,data);
            rw_tsks.k_decode_err_illegal_acc_format_test_unsupported_size =0;
            k_decode_err_illegal_acc_format_test_unsupported_size = 0;
            val_change_k_decode_err_illegal_acc_format_test_unsupported_size.trigger(null);
            `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Triggering uvm_event val_change_k_decode_err_illegal_acc_format_test_unsupported_size"), UVM_MEDIUM)
            `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Checking XAIUUESR.ErrVld."), UVM_MEDIUM)
             addr[19:12]=<%=aiu_rpn[idx]%>;// Register Page Number
             addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUUESR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUUESR.get_offset()<%}%>;
             rw_tsks.read_csr<%=qidx%>(addr,data);
             if((data[0]==0) && !AIUUEDR_DecErrDetEn) begin
            `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0(=No Error is logged). That is expected"), UVM_MEDIUM)
                `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0. That is not expected(=Error is logged)"))
            end else begin
            if(AIUUEDR_DecErrDetEn==0) begin
                `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 1. That is not expected(=No Error is logged)"))
            end else begin
                if(data[7:4]==7) begin // Error Type
                 `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrType is found 7(=Dec Error). That is expected"), UVM_MEDIUM)
                end else begin
                     `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrType isn't 7. That is not expected we have: %0h",data[7:4]))
                end
                if(data[15:12]==2) begin // Error Info
                      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrInfo is found 2(=illegal CSR access). That is expected"), UVM_MEDIUM)
                end else begin
                     `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrInfo isn't 2. That is not expected(=illegal CSR access) we have: %0h",data[15:12]))
            end
            end
                data=0;data[0]=1;
                rw_tsks.write_csr<%=qidx%>(addr,data,nonblocking);
                rw_tsks.read_csr<%=qidx%>(addr,data);
                if(data[0]==0 )
                    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is found 0, meaning Error is cleared. That is expected"), UVM_MEDIUM)
                else
                    `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("AIUUESR.ErrVld is not empty, meaning Error is not cleared."))
            end
            `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Done Checking illegal_acc_format_test_unsupported_size for write access"), UVM_NONE)
            `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Continue regular flow of csr sequence"), UVM_NONE)
        end

        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        rw_tsks.read_csr<%=qidx%>(addr,infor); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        //Unit Type: 0b000=Coherent Agent Interface Unit (CAIU), 0b001=Non-Coherent Agent Interface Unit (NCAIU), 0b010 - Non-coherent Agent Interface Unit with Proxy Cache (NCAIU)
        //Unit Sub-Types: for CAIU 0b000=ACE, 0b001=CHI-A, 0b010=CHI-B, 0b011-0b111:Reserved; for NCAIU 0b000=AXI, 0b001=ACE-Lite, 0b010=ACE-Lite-E, 0b011-0b111=Reserved
        if(infor[19:16] > 4'h2) begin //UT
           //`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Improper Unit Type for AIU%0d : %0d", i, infor[19:16]),UVM_NONE)
           `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Improper Unit Type for AIU%0d : %0d", i, infor[19:16]))
        end
        if(infor[19:16] > 4'h2) begin //UST
           //`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Improper Unit Sub-Types for AIU%0d : %0d", i, infor[19:16]),UVM_NONE)
           `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Improper Unit Sub-Types for AIU%0d : %0d", i, infor[19:16]))
        end
           // Enable Error detection to enable error correction feature by default
           //XAIUUEDR : 12'b0001 0000 0000
           addr[11:0] = 'h0;
           <% if(numChiAiu > 0) { %>
                 addr[11:0] = m_concerto_env.m_regs.<%=chiaiu0%>.CAIUUEDR.get_offset(); // 12'h<%=getIoOffset("CAIUUEDR")%>;
            <% } else { %>
                 addr[11:0] = m_concerto_env.m_regs.<%=ioaiu0%>.XAIUUEDR.get_offset(); // 12'h<%=getIoOffset("XAIUUEDR")%>;
            <% } %>
           if (addr[11:0]) begin
              data=32'h0; // data[3]:DecErrDetEn
              rw_tsks.read_csr<%=qidx%>(addr,data);
              data[3]=1; // DecErrDetEn
	          `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing aiu%0d xAIUUEDR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only);
              AIUUEDR_DecErrDetEn = 1;
           end

        if(infor[19:16] > 0) begin // NCAIU  
           if (infor[19:16] == 2) begin:_setup_ccp_ioc<%=qidx%> // INFOR = 2= NCAIU with Proxycache
           // XAIUPCTCR offset
            <%
              // first find XAIUPCTCR
              var XAIUPCTCR;  
              obj.AiuInfo.every( agent => {
                XAIUPCTCR = agent.csr.spaceBlock[0].registers.find(register => register.name === 'XAIUPCTCR');
               if (XAIUPCTCR) return false; // if not null found! => stop every fction
               return true;
              });
              if (XAIUPCTCR) { //if XAIUPCTCR exist
               var lookupen = XAIUPCTCR.fields.find(field => field.name === 'LookupEn');
               var allocen = XAIUPCTCR.fields.find(field => field.name === 'AllocEn');
               var UpdateDis = XAIUPCTCR.fields.find(field => field.name === 'UpdateDis');
            %>
            addr[11:0] = <%=XAIUPCTCR.addressOffset%>; // XAIUPCTCR OFFSET // ADDR[11:0] OFFSET always the same foreach AIU
            data=32'h0;
            // legacy lookupen & allocen =1 TODO randomize
            if($test$plusargs("rand_alloc_lookup")) begin
                //#Stimulus.FSYS.PxC.noallocen_rand           
                data[<%=lookupen.bitOffset%>]   = $urandom_range(0,1);  //lookupen
                data[<%=allocen.bitOffset%>]    = $urandom_range(0,1); //allocen            
            end else begin
                data[<%=lookupen.bitOffset%>]   = ccp_lookupen; //lookupen
                data[<%=allocen.bitOffset%>]    = ccp_allocen; //allocen
            end 
            //#Cover.FSYS.PROXY.UpdateDis 
            <% if (obj.initiatorGroups.length > 1) { %>
            update_cmd_disable = 1;// if connectivity feature disable update channel in the proxy cache
            <%}%>
            data[<%=UpdateDis.bitOffset%>]  = update_cmd_disable; //UpdateDis
	        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn:%0d aiu:%0d XAIUPCTCR (0x%0h) = 0x%0h",rpn,i, addr, data), UVM_LOW)
            rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
            <% } // if XAIUPCTCR exist %>
           end:_setup_ccp_ioc<%=qidx%>

	end // if (data[19:16] == 4'h1 || data[19:16] == 4'h2)

     <% if (numNCAiu > 0) { %>
         //infor[19:16] == xAIUINFOR.UT = 0(coh)||1(noncoh)||2(noncoh with proxy cache)
         //infor[18:16] == xAIUINFOR.UST = 0(ace)||1(chiA)||2(chib)  0(AXI)||1(ACE-LITE)||2(ACE-LITE-E)
           if(infor[19:16] == 1 || infor[19:16] == 2)  begin:_transorder  // Program XAIUTCR.TransOrderMode for NCAIU
                if(!$value$plusargs("ace_transorder_mode=%d", transorder_mode)) begin
                    randcase
                        10:    transorder_mode= 3;  // 2: Pcie_order 3:strict request order
                        90:    transorder_mode= 2; 
                    endcase
                  end
           addr[11:0] = m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTCR.get_offset();
	       data = (transorder_mode << m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTCR.TransOrderModeRd.get_lsb_pos()) | (transorder_mode << m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTCR.TransOrderModeWr.get_lsb_pos());
	       data = data | (1 << m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTCR.EventDisable.get_lsb_pos());
	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Programming rpn %0d XAIUTCR.TransOrderMode to %0d ", rpn, transorder_mode), UVM_NONE)
	       rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
	    end:_transorder
        <% } %>

        <% if(numChiAiu > 0) { %>
        if((infor[19:16] == 0) && (infor[19:16] < 3) && (infor[19:16] > 0))  begin  // Enable SysEvent for CHI-AIU
           addr[11:0] = m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTCR.get_offset();
	   data = sys_event_disable << m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTCR.EventDisable.get_lsb_pos();

	   data = data | (0 << m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTCR.SysCoDisable.get_lsb_pos());
	   rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

           addr[11:0] = m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTOCR.get_offset();
	   data = chiaiu_timeout_val;
	   rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
        end
        <% } %>

        <% if(obj.AiuInfo[0].fnEnableQos == 1) { %>
        if($value$plusargs("qos_threshold=%d", qos_threshold)) begin
            // Program QOS Event Threshold
            addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUQOSCR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUQOSCR.get_offset()<%}%>;
            rw_tsks.write_chk<%=qidx%>(addr, qos_threshold, k_csr_access_only, nonblocking);
        end
        if($test$plusargs("aiu_qos_threshold")) begin
            addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUQOSCR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUQOSCR.get_offset()<%}%>;
	    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Programming rpn %0d XAIUQOSCR.EventThreshold to aiu_qos_threshold[%0d]=%0d ", rpn, rpn, aiu_qos_threshold[rpn]), UVM_LOW)
            rw_tsks.write_chk<%=qidx%>(addr, aiu_qos_threshold[rpn], k_csr_access_only, nonblocking);
	end
        <% } %>

        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        rw_tsks.read_csr<%=qidx%>(addr,infor); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        if(infor[19:16] == 4'h2) begin // NCAIU
              // Enable Error detection to enable error correction feature by default
              //XAIUCECR : 12'b0001 0100 0000
	      <% if(numNCAiu > 0) { %>
              addr[11:0] = m_concerto_env.m_regs.<%=ncaiu0%>.XAIUCECR.get_offset(); // 12'h<%=getIoOffset("XAIUCECR")%>;
              data=32'h1; // data[0]:ErrDetEn
	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Waiting aiu %0d XAIUCECR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
              <% } %>

	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Initializing SMC Tag Memory for rpn %0d ", rpn), UVM_LOW)
              //USMCMCR0 : 12'b0000 0101 1000 ; addr[11:0]=12'h58;
              addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=ioAiuWithPC%>.XAIUPCMCR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMCR")%>;
              data = 32'h0; // data[21:16] : Tag_0/Data_1 memory array; data[3:0]: CacheMntOp :  Initialize all Entries
              rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);

              // Wait for Initialization to start
              //USMCMAR0 : 12'b0000 0101 1100 ; addr[11:0]=12'h5C;
	      //`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Waiting for initializing PC Tag Memory for rpn %0d to start", rpn), UVM_LOW)
              //addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=ioAiuWithPC%>.XAIUPCMAR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMAR")%>;
              //do begin
              //   rw_tsks.read_csr<%=qidx%>(addr,data);
              //end while (!data[0]); // data[0] : Maintanance Operation Active 

	end // if (data[19:16] == 4'h2)
       rpn++;
    end // for (int i=0; i<nAIUs; i++)				   
				   
    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        rw_tsks.read_csr<%=qidx%>(addr,data); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        if(data[19:16] == 4'h2) begin // NCAIU with proxycache
              // Wait for SMC Tag Mem Initialization to complete
	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Waiting for initializing PC Tag Memory for rpn %0d to complete", rpn), UVM_LOW)
              addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=ioAiuWithPC%>.XAIUPCMAR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMAR")%>;
              do begin
                 rw_tsks.read_csr<%=qidx%>(addr,data);
              end while (data[0]); // data[0] : Maintanance Operation Active 
	end // if (data[19:16] == 4'h1 || data[19:16] == 4'h2)
        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        rw_tsks.read_csr<%=qidx%>(addr,data); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        if(data[19:16] == 4'h2) begin // NCAIU with proxycache
              // Initialize data memory Array
	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Initializing PC Data Memory for rpn %0d ", rpn), UVM_LOW)
              //USMCMCR0 : 12'b0000 0101 1000 ; addr[11:0]=12'h58;
              addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=ioAiuWithPC%>.XAIUPCMCR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMCR")%>;
              data = 32'h10000; // data[21:16] : Tag_0/Data_1 memory array; data[3:0]: CacheMntOp :  Initialize all Entries
              rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);

              // Wait for Initialization to start
              //USMCMAR0 : 12'b0000 0101 1100 ; addr[11:0]=12'h5C;
	      //`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Waiting for initializing PC Data Memory for rpn %0d to start", rpn), UVM_LOW)
              //addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=ioAiuWithPC%>.XAIUPCMAR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMAR")%>;
              //do begin
              //   rw_tsks.read_csr<%=qidx%>(addr,data);
              //end while (!data[0]); // data[0] : Maintanance Operation Active 
	end // if (data[19:16] == 4'h1 || data[19:16] == 4'h2)
        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number

        // Check if the AIU is IOAIU, then initialize it
        //UINFOR : 12'b1111 1111 1100 ; addr[11:0] = 12'hFFC;
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUINFOR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUINFOR.get_offset()<%}%>; // =12'h<%=getChiOffset("CAIUINFOR")%>;=12'h<%=getIoOffset("XAIUINFOR")%>;
        rw_tsks.read_csr<%=qidx%>(addr,data); // 1-> NCAIU, 2-> NCAIU with ProxyCache
        if(data[19:16] == 4'h2) begin // NCAIU with proxycache
              // Wait for Initialization to complete
	      `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Waiting for initializing PC Data Memory for rpn %0d to complete", rpn), UVM_LOW)
              addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=ioAiuWithPC%>.XAIUPCMAR.get_offset()<%} else {%> 12'h0 <%}%>; // 12'h<%=getIoOffset("XAIUPCMAR")%>;
              do begin
                 rw_tsks.read_csr<%=qidx%>(addr,data);
              end while (data[0]); // data[0] : Maintanance Operation Active 
	end // if (data[19:16] == 4'h1 || data[19:16] == 4'h2)
        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    // (4) Initialize DCEs
    //rpn = nAIUs;
    for(int i=0; i<nDCEs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(k_csr_access_only == 1) begin
           // Wait for any activity to complete
           //DCEUSFMAR : 12'b0010 0100 0100 ; addr[11:0]=12'h244;
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSFMAR.get_offset(); // 12'h<%=getDceOffset("DCEUSFMAR")%>;
           do begin
              rw_tsks.read_csr<%=qidx%>(addr,data);
           end while (data[0]); // data[0] : Maintanance Operation Active 

           // Initialize Snoop Filter Memory(By default initially this is done as reset value is 0)
           //DCEUSFMCR: 12'b0010 0100 0000 ; addr[11:0]=12'h240;
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSFMCR.get_offset(); // 12'h<%=getDceOffset("DCEUSFMCR")%>;
           data = 32'h1; // data[0] Toggle the bit to start snoop filter initialization, setting 1 resets the initialization counter
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);
           data = 32'h0; // data[0] Toggle the bit to start snoop filter initialization, setting 0 will start using counter
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);

           //DCEUSFMAR : 12'b0010 0100 0100 ; addr[11:0]=12'h244;
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSFMAR.get_offset(); // 12'h<%=getDceOffset("DCEUSFMAR")%>;
           // Wait for any activity to start
           //`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$psprintf("Waiting for SnoopFiler initialization to start"),UVM_LOW) 
           //do begin
           //   rw_tsks.read_csr<%=qidx%>(addr,data);
           //end while (!data[0]); // data[0] : Maintanance Operation Active 
           // Wait for any activity to complete
           `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$psprintf("Waiting for SnoopFiler initialization to complete"),UVM_LOW) 
           do begin
              rw_tsks.read_csr<%=qidx%>(addr,data);
           end while (data[0]); // data[0] : Maintanance Operation Active 

           //DCEUINFOR : 12'b1111 1111 1000 ; addr[11:0]=12'hFF8;
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUINFOR.get_offset(); // 12'h<%=getDceOffset("DCEUINFOR")%>;
           rw_tsks.read_csr<%=qidx%>(addr,data);
           if(data[19:16] != 4'h8) begin // UT/Unit Type: should be 4'b1000 for DCE
              `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("DCE%0d Information register Unit type unexpected: Exp:%0h Act:%0h", i, 4'h8,data[19:16]))
           end
        end  //CHECK CSR
        
           // Enable Error detection to enable error correction feature by default
           //XAIUUEDR : 12'b0001 0000 0000
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUUEDR.get_offset(); 
           data=32'h0; // data[3]:DecErrDetEn
           rw_tsks.read_csr<%=qidx%>(addr,data);
           data[3] = 1; //DecErrDetEn
	         `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing DCE%0d DCEUUEDR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only);

        foreach (csrq[ig]) begin
           //Write to GPR register sets with appropriate values.
           //GPRBLR : 12'b01XX XXXX 0100 ; addr[11:0] = {2'b01,ig[5:0],4'h4};
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUGPRBLR0.get_offset(); // 12'h<%=getDceOffset("DCEUGPRBLR0")%>;
           addr[9:4]=ig[5:0];
           data[31:0] = csrq[ig].low_addr;
	   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s low_addr 0x%0h GPRBLR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].low_addr, addr, data), UVM_LOW)
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

           //GPRBHR : 12'b01XX XXXX 1000 ; addr[11:0] = {2'b01,ig[5:0],4'h8};
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUGPRBHR0.get_offset(); // 12'h<%=getDceOffset("DCEUGPRBHR0")%>;
           addr[9:4]=ig[5:0];
           //data =0;
           //data[7:0] = csrq[ig].upp_addr;
           data[31:0] = csrq[ig].upp_addr;
	   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s upp_addr 0x%0h GPRHLR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].upp_addr, addr, data), UVM_LOW)
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

           //GPRAR : 12'b01XX XXXX 0000 ; addr[11:0] = {2'b01,ig[5:0],4'h0};
           addr[11:0] = m_concerto_env.m_regs.dce0.DCEUGPRAR0.get_offset(); // 12'h<%=getDceOffset("DCEUGPRAR0")%>;
           addr[9:4]=ig[5:0];
           data =0; // Reset value
           data[31]    = 1; // Valid
           data[30]    = (csrq[ig].unit == ncore_config_pkg::ncoreConfigInfo::DII ? 1 : 0); // Home Unit Type
           data[25:20] = csrq[ig].size; // interleave group member size(2^(size+12) bytes)
           data[13:9]  = csrq[ig].mig_nunitid;
           data[4:1]   = csrq[ig].order;//bit0(Hazard bit) is deprecated; CONC-11405
	   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d ig %0d unitid %0d unit %s size %0d GPRAR (0x%0h) = 0x%0h", rpn, ig, csrq[ig].mig_nunitid, csrq[ig].unit.name, csrq[ig].size, addr, data), UVM_LOW)
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
        end

        addr[11:0] = m_concerto_env.m_regs.dce0.DCEUAMIGR.get_offset(); // 12'h<%=getDceOffset("DCEUAMIGR")%>; addr[11:0] = 12'h3c0; 
        data = 32'h0; data[4:0]={ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs,1'b1};
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dce %0d DCEUAMIGR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
        rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

        // Enable VB recovery on wr/up; TODO : Temporary Enabled through Register; later will be enabled by default (No register)
        // TODO: Disable for now. Enable later
        addr[11:0] = m_concerto_env.m_regs.dce0.DCEUEDR0.get_offset(); // 12'h<%=getDceOffset("DCEUEDR0")%>; addr[11:0] = 12'hA00; 
        rw_tsks.read_csr<%=qidx%>(addr,data);
        rw_tsks.write_chk<%=qidx%>(addr,data | (0<<10),k_csr_access_only, nonblocking);

        // Enable Error detection to enable error correction feature by default
        //DCEUCECR : 12'b0001 0100 0000
        addr[11:0] = m_concerto_env.m_regs.dce0.DCEUCECR.get_offset(); // 12'h<%=getDceOffset("DCEUCECR")%>;
        data=32'h1; // data[0]:ErrDetEn
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dce %0d DCEUCECR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
        rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
            
        <% if (obj.DceInfo[0].fnEnableQos == 1) { %> 
        if($value$plusargs("qos_threshold=%d", qos_threshold)) begin
            // Program QOS Event Threshold
            addr[11:0] = m_concerto_env.m_regs.dce0.DCEUQOSCR0.get_offset(); // 12'h<%=getDceOffset("DCEUEDR0")%>; addr[11:0] = 12'hA00; 
            rw_tsks.write_chk<%=qidx%>(addr, qos_threshold, k_csr_access_only, nonblocking);
        end
        if($test$plusargs("dce_qos_threshold")) begin
            addr[11:0] = m_concerto_env.m_regs.dce0.DCEUQOSCR0.get_offset(); // 12'h<%=getDceOffset("DCEUEDR0")%>; addr[11:0] = 12'hA00; 
	    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Programming rpn %0d DCEQOSCR0.EventThreshold to dce_qos_threshold[%0d]=%0d ", rpn, rpn-<%=obj.nAIUs%>, dce_qos_threshold[rpn-<%=obj.nAIUs%>]), UVM_LOW)
            rw_tsks.write_chk<%=qidx%>(addr, dce_qos_threshold[rpn-<%=obj.nAIUs%>], k_csr_access_only, nonblocking);
        end
        <% } %>

        if($test$plusargs("sysco_disable")) begin
        addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSER0.get_offset();
        //data = <%=SnoopEn%>;  //FFFFFFF - FIXME
        data = 32'hFFFF_FFFF;
        rw_tsks.write_csr<%=qidx%>(addr,data, nonblocking);

	<%if(obj.DceInfo[0].nAius > 32) { %>
	addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSER1.get_offset();
	data = 32'hFFFF_FFFF;
	rw_tsks.write_csr<%=qidx%>(addr, data, nonblocking);
    	<%}%>

	<%if(obj.DceInfo[0].nAius > 64) { %>
	addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSER2.get_offset();
	data = 32'hFFFF_FFFF;
	rw_tsks.write_csr<%=qidx%>(addr, data, nonblocking);
    	<%}%>
        end

        addr[11:0] = m_concerto_env.m_regs.dce0.DCEUTCR.get_offset();
	data = sys_event_disable << m_concerto_env.m_regs.dce0.DCEUTCR.EventDisable.get_lsb_pos();
	rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

        addr[11:0] = m_concerto_env.m_regs.dce0.DCEUSBSIR.get_offset(); 
        rw_tsks.read_csr<%=qidx%>(addr,data);
	`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ-sw_credit_mgmt", $sformatf("[DCE REG] Reading rpn %0d DCEUSBSIR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        if(data[31]==1) begin
          act_cmd_skid_buf_size["DCE"][i]=data[25:16];
          act_cmd_skid_buf_arb["DCE"][i]=data[8:0];
        end else begin
          `uvm_error("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("[DCE REG] Valid bit not asserted in DCEUSBSIR-%0d ADDR 0x%0h DATA 0x%0h", i, addr, data))
        end
        rpn++;
    end

    if(exp_cmd_skid_buf_size["DCE"].size != act_cmd_skid_buf_size["DCE"].size) begin
        `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DCE] exp_cmd_skid_buf_size[DCE].size %0d != act_cmd_skid_buf_size[DCE].size %0d",exp_cmd_skid_buf_size["DCE"].size,act_cmd_skid_buf_size["DCE"].size))
    end
    foreach(exp_cmd_skid_buf_size["DCE"][temp]) begin
        if(exp_cmd_skid_buf_size["DCE"][temp]!= act_cmd_skid_buf_size["DCE"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DCE] exp_cmd_skid_buf_size[DCE][%0d] %0d != act_cmd_skid_buf_size[DCE][%0d] %0d",temp,exp_cmd_skid_buf_size["DCE"][temp],temp,act_cmd_skid_buf_size["DCE"][temp]))
        end
        if(exp_cmd_skid_buf_arb["DCE"][temp]!= act_cmd_skid_buf_arb["DCE"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ-sw_credit_mgmt",$sformatf("[DCE] exp_cmd_skid_buf_arb[DCE][%0d] %0d != act_cmd_skid_buf_arb[DCE][%0d] %0d",temp,exp_cmd_skid_buf_arb["DCE"][temp],temp,act_cmd_skid_buf_arb["DCE"][temp]))
        end
    end

    // (5) Initialize DMIs ( dmi*_DMIUSMCTCR)
    //rpn = nAIUs + nDCEs;
    cur_rpn = rpn;
    for(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) begin  
           // Configure Scratchpad memories
           if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcsp[i]) begin  
	          ScPadEn = (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i] && !($test$plusargs("all_ways_for_cache"))) ? 32'h1 : 32'h0;
              ScPadBaseAddr = k_sp_base_addr[i] >> <%=obj.wCacheLineOffset%>;

              //DMIUSMCSPBR0 : 12'b0011 0011 0000
              <%if(numDmiWithSP > 0){ %>
              addr[11:0] = <%if(numDmiWithSP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSP].strRtlNamePrefix%>.DMIUSMCSPBR0.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCSPBR0")%>;
              data= ScPadBaseAddr[31:0];
              `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCSPBR0 (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

              if(ncore_config_pkg::ncoreConfigInfo::WCACHE_OFFSET > 32) begin
                 //DMIUSMCSPBR1 : 12'b0011 0011 0100
                 addr[11:0] = <%if(numDmiWithSP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSP].strRtlNamePrefix%>.DMIUSMCSPBR1.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCSPBR1")%>;
                 data= ScPadBaseAddr >> 32 ; // ScPadBaseAddrHi
                 `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCSPBR1 (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
                 rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
              end

              //DMIUSMCSPCR0 : 12'b0011 0011 1000
              addr[11:0] = <%if(numDmiWithSP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSP].strRtlNamePrefix%>.DMIUSMCSPCR0.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCSPCR0")%>;
	      data = 'h0;
              data[0]   = ScPadEn; // data[0] = (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]) ? ScPadEn : 0
              data[6:1] = sp_ways[i]-1; // NumScPadWays=ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]-1 ,
              `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCSPCR0 (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);

              //DMIUSMCSPCR1 : 12'b0011 0011 1100
              addr[11:0] = <%if(numDmiWithSP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSP].strRtlNamePrefix%>.DMIUSMCSPCR1.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCSPCR1")%>;
              data= sp_size[i]-1; // Scratchpad size in number of cachelines.
              `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCSPCR1 (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
              <% } %>
           end

           // Configure policies
           //DMIUSMCTCR : 12'b0011 0000 0000
           <%if(numDmiWithSMC > 0){ %>
           addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCTCR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCTCR")%>;
           if($test$plusargs("dmi_alloc_dis")) begin
              data=32'h1; // data[1]:AllocEn , data[0]:LookupEn
           end else begin
              data=32'h3; // data[1]:AllocEn , data[0]:LookupEn
           end
           if($test$plusargs("rand_alloc_lookup")) begin
            //#Stimuls.FSYS.SMC.noallocen_rand
              data[1]  = dmi_nallocen_rand ;
              data[0]  = dmi_nlooken_rand ;
            end

           `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCTCR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
 
           //DMIUSMCAPR : 12'b0011 0000 1000
           addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCAPR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCAPR")%>;
           //#Check.FSYS.SMC.TOFAllocDisable
           //#Check.FSYS.SMC.ClnWrAllocDisable
           //#Check.FSYS.SMC.DtyWrAllocDisable
           //#Check.FSYS.SMC.RdAllocDisable
           //#Check.FSYS.SMC.WrAllocDisable 
           // by defautl data = 0 ,when dmiusmc_policy test is enabled dmiusmc_policy reg field will be set to 1
           if($test$plusargs("dmiusmc_policy_test")) begin
            data = dmiusmc_policy_rand; // data[4]:WrAllocDisable , data[3]:RdAllocDisable , data[2]:DtyWrAllocDisable , data[1]:ClnWrAllocDisable , data[0]:TOFAllocDisable
           end else begin
            data = dmiusmc_policy; // data[4]:WrAllocDisable , data[3]:RdAllocDisable , data[2]:DtyWrAllocDisable , data[1]:ClnWrAllocDisable , data[0]:TOFAllocDisable
           end 
           `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCAPR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
           <% } %>
           // Configure way partitioning // TODO what if SP and Way partitioning both are enabled together
           if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcwp[i]) begin  
              if ($test$plusargs("no_way_partitioning")) begin
                <% if(numDmiWithWP > 0) { %>
                 for( int j=0;j<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];j++) begin
                    //DMIUSMCWPCR0 : 12'b0011 0100 0000
                    addr[11:0] = <%if(numDmiWithWP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithWP].strRtlNamePrefix%>.DMIUSMCWPCR00.get_offset()+ (j*8) <%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCWPCR00")%>;
                    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCWPCR0%0d (0x%0h) = 0x%0h", i, j, addr, j), UVM_LOW)
                    rw_tsks.write_chk<%=qidx%>(addr,j,k_csr_access_only, nonblocking);
                 end
                <% } %>
              end else begin
                //bit [31:0] agent_ids_assigned_q[$];
                //int shared_ways_per_user;
                <% if(numDmiWithWP > 0) { %>
                for( int j=0;j<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];j++) begin
                   bit [31:0] agent_id;
                   agent_id = agent_ids_assigned_q[i][j];
                   //DMIUSMCWPCR0 : 12'b0011 0100 0000
                   addr[11:0] = <%if(numDmiWithWP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithWP].strRtlNamePrefix%>.DMIUSMCWPCR00.get_offset()+ (j*8) <%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCWPCR00")%>;
                   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUSMCWPCR0%0d (0x%0h) = 0x%0h", i, j, addr, agent_id), UVM_LOW)
                   rw_tsks.write_chk<%=qidx%>(addr,agent_id,k_csr_access_only, nonblocking);

                   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("dmi %0d way-part reg no %0d vld %0b id %0h", i, j, agent_id[31], agent_id[30:0]), UVM_LOW)

                   data = wayvec_assigned_q[i][j];
                   //DMIUSMCWPCR1 : 12'b0011 0100 0100
                   addr[11:0] = <%if(numDmiWithWP){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithWP].strRtlNamePrefix%>.DMIUSMCWPCR10.get_offset()+ (j*8) <%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCWPCR10")%>;
                   rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
                   `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("dmi %0d way-part reg no %0d way %0b", i, j, data), UVM_LOW)
                end
                <% } %>
              end // if ($test$plusargs("no_way_partitioning")) begin
           end
         <%if(numDmiWithSMC > 0){ %>
           if(k_csr_access_only) begin
              //DMIUSMCIFR : 12'b1111 1111 1000
              addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCIFR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCIFR")%>;
              rw_tsks.read_csr<%=qidx%>(addr,data);
              if((data[19: 0] == (ncore_config_pkg::ncoreConfigInfo::dmi_CmcSet[i] ? ncore_config_pkg::ncoreConfigInfo::dmi_CmcSet[i]-1 : 0 )) && // Data[19:0] NumSet
                 (data[25:20] == (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i] ? ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]-1 : 0 )) && // Data[25:20] NumWay
                 (data[26:26] == (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcsp[i])) && // Data[26:26] SP: ScratchPad Support Exist
                 (data[27:27] == (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcwp[i])) && // Data[27:27] WP: Way Partitioning Support Exist
                 (data[31:28] == (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i] ? ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i]-1 : 0 )) // Data[31:28] NumWayPartitionig Registers
                ) begin
                 `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Read dmi %0d DMIUSMCIFR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              end else begin
                 `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Read dmi %0d DMIUSMCIFR (0x%0h) = 0x%0h, Sets/Ways mismatch", i, addr, data))
              end

              //DMIUINFOR : 12'b1111 1111 1100
              addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUINFOR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUINFOR")%>;
              rw_tsks.read_csr<%=qidx%>(addr,data);
              if((data[19:16] == 'h9) && // Data[19:16] UT=DMI ('h9) unit type
                 (data[23:20] == 'h0) && // Data[23:20] UST=AXI ('h0) unit sub type - Native Interface
                 (data[24  ] == ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) && // Data[13] SMC System Memory Cache present
                 (data[25  ] == ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[i]) && // Data[12] AE  Atomic Engine present
                 (data[31  ] == 'b1) // Data[31] Valid
                ) begin
                 `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Read dmi %0d DMIUINFOR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
              end else begin
                 `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Read dmi %0d DMIUINFOR (0x%0h) = 0x%0h, UniteType/AtomicEngine/SMC/Valid mismatch", i, addr, data))
              end
           end
         <% } %>
        end
        // Enable Error detection to enable error correction feature by default
        //DMIUCECR : 12'b0001 0100 0000
        addr[11:0] = m_concerto_env.m_regs.<%=DmiInfo[0].strRtlNamePrefix%>.DMIUCECR.get_offset(); // 12'h<%=getDmiOffset("DMIUCECR")%>;
        data=32'h1; // data[0]:ErrDetEn
        `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing dmi %0d DMIUCECR (0x%0h) = 0x%0h", i, addr, data), UVM_LOW)
        rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, nonblocking);
            
        <% if (obj.DmiInfo[0].fnEnableQos == 1) { %> 
 
        if($value$plusargs("qos_threshold=%d", qos_threshold)) begin
            // Program QOS Event Threshold
            addr[11:0] = m_concerto_env.m_regs.<%=DmiInfo[0].strRtlNamePrefix%>.DMIUQOSCR0.get_offset(); 
            rw_tsks.write_chk<%=qidx%>(addr, qos_threshold, k_csr_access_only, nonblocking);
        end
        if($test$plusargs("dmi_qos_threshold")) begin
            // Program QOS Event Threshold
            addr[11:0] = m_concerto_env.m_regs.<%=DmiInfo[0].strRtlNamePrefix%>.DMIUQOSCR0.get_offset(); 
	    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Programming rpn %0d DMIQOSCR0.EventThreshold to dmi_qos_threshold[%0d]=%0d ", rpn, rpn-<%=obj.nAIUs%>-<%=obj.nDCEs%>, dmi_qos_threshold[rpn-<%=obj.nAIUs%>-<%=obj.nDCEs%>]), UVM_LOW)
            rw_tsks.write_chk<%=qidx%>(addr, dmi_qos_threshold[rpn-<%=obj.nAIUs%>-<%=obj.nDCEs%>], k_csr_access_only, nonblocking);
        end
       
         if($test$plusargs("dmi_qos_rsved")) begin
            // Program QOS Event Threshold
            addr[11:0] = m_concerto_env.m_regs.<%=DmiInfo[0].strRtlNamePrefix%>.DMIUTQOSCR0.get_offset(); 
	    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Programming rpn %0d DMITQOSCR0 to dmi_qos_rsved[%0d]=%0d ", rpn, rpn-<%=obj.nAIUs%>-<%=obj.nDCEs%>, dmi_qos_rsved), UVM_LOW)
            rw_tsks.write_chk<%=qidx%>(addr, dmi_qos_rsved, k_csr_access_only, nonblocking);
        end
        <% } %>
        rpn++;
    end
    <%if(numDmiWithSMC > 0){ %>
    rpn = cur_rpn;
    ;fkr(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) begin  
           // Initialize tag memory Array
           //DMIUSMCMCR : 12'b0011 0001 0000
           addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCMCR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCMCR")%>;
           data = 32'h0; // data[21:16] : Tag_0/Data_1 memory array; data[3:0]: CacheMntOp :  Initialize all Entries
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);

	end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i])
        rpn++;
    end			   

    rpn = cur_rpn;
    for(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) begin  
           // Wait for Tag Mem Initialization to complete
           //DMIUSMCMAR : 12'b0011 0001 0100
           addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCMAR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCMAR")%>;
           do begin
              rw_tsks.read_csr<%=qidx%>(addr,data);
           end while (data[0]); // data[0] : Maintanance Operation Active 
           
	end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i])
        rpn++;
    end			   

    rpn = cur_rpn;
    for(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number

        if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) begin  
           // Initialize data memory Array
           //DMIUSMCMCR : 12'b0011 0001 0000
           addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCMCR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCMCR")%>;
           data = 32'h10000; // data[21:16] : Tag_0/Data_1 memory array; data[3:0]: CacheMntOp :  Initialize all Entries
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);
	end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i])
        rpn++;
    end			   
    <% } %>
    rpn = cur_rpn;
    for(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number
        <% if(numDmiWithSMC > 0) { %>
        if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i]) begin  
           // Wait for Data Mem Initialization to complete
           //DMIUSMCMAR : 12'b0011 0001 0100
           addr[11:0] = <%if(numDmiWithSMC){%>m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUSMCMAR.get_offset()<%} else {%>12'h0<%}%>; // 12'h<%=getDmiOffset("DMIUSMCMAR")%>;
           do begin
              rw_tsks.read_csr<%=qidx%>(addr,data);
           end while (data[0]); // data[0] : Maintanance Operation Active 
	end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmc[i])
        <% } %>
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.MRDSBSIR.get_offset(); 
        rw_tsks.read_csr<%=qidx%>(addr,data);
	`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ-sw_credit_mgmt", $sformatf("[DMI REG] Reading rpn %0d MRDSBSIR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        if(data[31]==1) begin
          act_mrd_skid_buf_size["DMI"][i]=data[25:16];
          act_mrd_skid_buf_arb["DMI"][i]=data[8:0];
        end else begin
          `uvm_error("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI REG] Valid bit not asserted in MRDSBSIR-%0d ADDR 0x%0h DATA 0x%0h", i, addr, data))
        end

        addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.CMDSBSIR.get_offset(); 
        rw_tsks.read_csr<%=qidx%>(addr,data);
	`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ-sw_credit_mgmt", $sformatf("[DMI REG] Reading rpn %0d CMDSBSIR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        if(data[31]==1) begin
          act_cmd_skid_buf_size["DMI"][i]=data[25:16];
          act_cmd_skid_buf_arb["DMI"][i]=data[8:0];
        end else begin
          `uvm_error("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI REG] Valid bit not asserted in CMDSBSIR-%0d ADDR 0x%0h DATA 0x%0h", i, addr, data))
        end

        rpn++;
    end			   

    if(exp_cmd_skid_buf_size["DMI"].size != act_cmd_skid_buf_size["DMI"].size) begin
        `uvm_error("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI] exp_cmd_skid_buf_size[DMI].size %0d != act_cmd_skid_buf_size[DMI].size %0d",exp_cmd_skid_buf_size["DMI"].size,act_cmd_skid_buf_size["DMI"].size))
    end
    foreach(exp_cmd_skid_buf_size["DMI"][temp]) begin
        if(exp_cmd_skid_buf_size["DMI"][temp]!= act_cmd_skid_buf_size["DMI"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI] exp_cmd_skid_buf_size[DMI][%0d] %0d != act_cmd_skid_buf_size[DMI][%0d] %0d",temp,exp_cmd_skid_buf_size["DMI"][temp],temp,act_cmd_skid_buf_size["DMI"][temp]))
           end
        if(exp_cmd_skid_buf_arb["DMI"][temp]!= act_cmd_skid_buf_arb["DMI"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("[DMI] exp_cmd_skid_buf_arb[DMI][%0d] %0d != act_cmd_skid_buf_arb[DMI][%0d] %0d",temp,exp_cmd_skid_buf_arb["DMI"][temp],temp,act_cmd_skid_buf_arb["DMI"][temp]))
        end
    end

    if(exp_mrd_skid_buf_size["DMI"].size != act_mrd_skid_buf_size["DMI"].size) begin
        `uvm_error("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("[DMI] exp_mrd_skid_buf_size[DMI].size %0d != act_mrd_skid_buf_size[DMI].size %0d",exp_mrd_skid_buf_size["DMI"].size,act_mrd_skid_buf_size["DMI"].size))
    end
    foreach(exp_mrd_skid_buf_size["DMI"][temp]) begin
        if(exp_mrd_skid_buf_size["DMI"][temp]!= act_mrd_skid_buf_size["DMI"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("[DMI] exp_mrd_skid_buf_size[DMI][%0d] %0d != act_mrd_skid_buf_size[DMI][%0d] %0d",temp,exp_mrd_skid_buf_size["DMI"][temp],temp,act_mrd_skid_buf_size["DMI"][temp]))
        end
        if(exp_mrd_skid_buf_arb["DMI"][temp]!= act_mrd_skid_buf_arb["DMI"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("[DMI] exp_mrd_skid_buf_arb[DMI][%0d] %0d != act_mrd_skid_buf_arb[DMI][%0d] %0d",temp,exp_mrd_skid_buf_arb["DMI"][temp],temp,act_mrd_skid_buf_arb["DMI"][temp]))
        end
    end

    cur_rpn = rpn;
    for(int i=0; i<nDIIs; i++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DiiInfo[0].strRtlNamePrefix%>.DIIUSBSIR.get_offset(); 
        rw_tsks.read_csr<%=qidx%>(addr,data);
	`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("[DII REG] Reading rpn %0d CMDSBSIR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        if(data[31]==1) begin
          act_cmd_skid_buf_size["DII"][i]=data[25:16];
          act_cmd_skid_buf_arb["DII"][i]=data[8:0];
        end else begin
          `uvm_error("IOAIU<%=qidx%>BOOT_SEQ",$sformatf("[DII REG] Valid bit not asserted in CMDSBSIR-%0d ADDR 0x%0h DATA 0x%0h", i, addr, data))
        end

        rpn++;
    end

    if(exp_cmd_skid_buf_size["DII"].size != act_cmd_skid_buf_size["DII"].size) begin
        `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ",$sformatf("[DII] exp_cmd_skid_buf_size[DII].size %0d != act_cmd_skid_buf_size[DII].size %0d",exp_cmd_skid_buf_size["DII"].size,act_cmd_skid_buf_size["DII"].size))
    end
    foreach(exp_cmd_skid_buf_size["DII"][temp]) begin
        if(exp_cmd_skid_buf_size["DII"][temp]!= act_cmd_skid_buf_size["DII"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ",$sformatf("[DII] exp_cmd_skid_buf_size[DII][%0d] %0d != act_cmd_skid_buf_size[DII][%0d] %0d",temp,exp_cmd_skid_buf_size["DII"][temp],temp,act_cmd_skid_buf_size["DII"][temp]))
        end
        if(exp_cmd_skid_buf_arb["DII"][temp]!= act_cmd_skid_buf_arb["DII"][temp]) begin
            `uvm_error("IOAIU<%=qidx%>_BOOT_SEQ",$sformatf("[DII] exp_cmd_skid_buf_arb[DII][%0d] %0d != act_cmd_skid_buf_arb[DII][%0d] %0d",temp,exp_cmd_skid_buf_arb["DII"][temp],temp,act_cmd_skid_buf_arb["DII"][temp]))
        end
    end

    // program DVE SnpsEnb
    // rpn += nDIIs;
    if($test$plusargs("sysco_disable")) begin
        for(int i=0; i<nDVEs; i++) begin
            addr[19:12]=rpn;// Register Page Number
            addr[11:0] = m_concerto_env.m_regs.dve0.DVEUSER0.get_offset();
            data = <%=SnoopEn%>;
            rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);
         `ifdef USE_VIP_SNPS
            //CONC-9313
            addr[11:0] = m_concerto_env.m_regs.dve0.DVEUENGDBR.get_offset();
            data = 1;
            rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);
         `endif
            rpn++;
        end
    end	   
    //CONC-9313
   `ifdef USE_VIP_SNPS
    else begin
       for(int i=0; i<nDVEs; i++) begin
           addr[19:12]=rpn;// Register Page Number
           addr[11:0] = m_concerto_env.m_regs.dve0.DVEUENGDBR.get_offset();
           data = 1;
           rw_tsks.write_chk<%=qidx%>(addr,data,k_csr_access_only, 0);
           rpn++;
       end
    end	   
   `endif

<% ioidx=0;
for(pidx=0; pidx<obj.nAIUs; pidx++) {
if((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")  || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || (obj.AiuInfo[pidx].fnNativeInterface == "AXI4")) {
    if(Array.isArray(obj.AiuInfo[pidx].rpn)) {
       rpn_val = obj.AiuInfo[pidx].rpn[0];
    } else {
       rpn_val = obj.AiuInfo[pidx].rpn;
    } %>
    addr[19:12] = <%=rpn_val%>;
    addr[11:0] = m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUTOCR.get_offset();
    data = ioaiu_timeout_val;
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d XAIUTOCR (0x%0h) = 0x%0h", <%=pidx%>, addr, data), UVM_LOW)
    rw_tsks.write_csr<%=qidx%>(addr,data, 0);
     
<% } } %>

if(!$test$plusargs("sysco_disable")) begin
    // Setup SysCo Attach for IOAIUs
<% ioidx=0;
for(pidx=0; pidx<obj.nAIUs; pidx++) {
if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache))) {
    if(Array.isArray(obj.AiuInfo[pidx].rpn)) {
       rpn_val = obj.AiuInfo[pidx].rpn[0];
    } else {
       rpn_val = obj.AiuInfo[pidx].rpn;
    } %>
    addr[19:12] = <%=rpn_val%>;
    addr[11:0] = m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUTCR.get_offset();
    rw_tsks.read_csr<%=qidx%>(addr, data);
    data = data | (1 << m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUTCR.SysCoAttach.get_lsb_pos());
    `uvm_info("IOAIU<%=qidx%>_BOOT_SEQ", $sformatf("Writing rpn %0d XAIUTCR.SysCoAttach (0x%0h) = 0x%0h", <%=pidx%>, addr, data), UVM_LOW)
    rw_tsks.write_csr<%=qidx%>(addr,data, 0);
     
<% } } %>

// poll for SysCo Attached state
<% ioidx=0;
for(pidx=0; pidx<obj.nAIUs; pidx++) {
if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache))) {
    if(Array.isArray(obj.AiuInfo[pidx].rpn)) {
       rpn_val = obj.AiuInfo[pidx].rpn[0];
    } else {
       rpn_val = obj.AiuInfo[pidx].rpn;
    } %>
    addr[19:12] = <%=rpn_val%>;
    addr[11:0] = m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUTAR.get_offset();
    do begin
       rw_tsks.read_csr<%=qidx%>(addr, data);
       data = (data >> m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUTAR.SysCoAttached.get_lsb_pos()) & 1;
    end while(data == 0);
    <% if(obj.testBench!="emu") { %>
    // Let the ioaiu_scoreboard know we're now in ATTACHED state, see CONC-10924
    // Test should only be on ATTACHED but many fsys legacy files unduly set the the FSM in CONNECT as an equivalent state
    // Should be corrected in all files ideally but would be rather intrusive, due to multiport configs etc. TODO
    // Only core 0 should be considered as it's the AIU reference in multiport configs
    if(m_args.ioaiu_scb_en) begin
        if (!m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state inside {ioaiu<%=ioidx%>_env_pkg::CONNECT, ioaiu<%=ioidx%>_env_pkg::ATTACHED}) begin 
            m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state = ioaiu<%=ioidx%>_env_pkg::ATTACHED; 
            ev_sysco_fsm_state_change_<%=obj.AiuInfo[pidx].FUnitId%>.trigger();
            end
        else begin
        	`uvm_warning("IOAIU<%=qidx%>BOOT_SEQ", $psprintf("ioaiu<%=ioidx%> sysco_fsm_state already in %s state at ATTACH time", m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state.name()))
        	// `uvm_error("IOAIU<%=qidx%>BOOT_SEQ", $psprintf("ioaiu<%=ioidx%> sysco_fsm_state already in %s state at ATTACH time", m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state.name()))
	    end
    end
    <% } %>
<% } 
    if( !(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) )
        {ioidx++;}
} %>
end

//Configure credit limit for AIUs and DCEs                                  
    rpn = 0; //chi_rpn;
    AiuIds.delete();
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUFUIDR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUFUIDR.get_offset()<%}%>; ;
        rw_tsks.read_csr<%=qidx%>(addr,data);
	`uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg AIU_FUIDR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        AiuIds = new[AiuIds.size()+1] (AiuIds);
        AiuIds[AiuIds.size()-1] =  data[15:0];
        if(i==0) begin temp_string=""; temp_string = $sformatf("%0s AiuIds : \n",temp_string); end
        temp_string = $sformatf("%0s %0d",temp_string,AiuIds[i]);
        rpn++;
    end // for (int i=0; i<nAIUs; i++)				   
    `uvm_info("IOAIU<%=qidx%>BOOT_SEQ", $sformatf("%0s",temp_string), UVM_LOW)

    cur_rpn = rpn;
    cur_rpn = rpn;
    DceIds.delete();
    for(int i=0; i<nDCEs; i++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = m_concerto_env.m_regs.dce0.DCEUFUIDR.get_offset();
        rw_tsks.read_csr<%=qidx%>(addr,data);
	`uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg DCE_FUIDR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        DceIds = new[DceIds.size()+1] (DceIds);
        DceIds[DceIds.size()-1] =  data[15:0];
        if(i==0) begin temp_string=""; temp_string = $sformatf("%0s DceIds : \n",temp_string); end
        temp_string = $sformatf("%0s %0d",temp_string,DceIds[i]);
        rpn++;
    end // for (int i=0; i<nDCEs; i++)				   
    `uvm_info("IOAIU<%=qidx%>BOOT_SEQ", $sformatf("%0s",temp_string), UVM_LOW)

    cur_rpn = rpn;
    DmiIds.delete();
    for(int i=0; i<nDMIs; i++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUFUIDR.get_offset();
        rw_tsks.read_csr<%=qidx%>(addr,data);
	`uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg DMI_FUIDR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        DmiIds = new[DmiIds.size()+1] (DmiIds);
        DmiIds[DmiIds.size()-1] =  data[15:0];
        if(i==0) begin temp_string=""; temp_string = $sformatf("%0s DmiIds : \n",temp_string); end
        temp_string = $sformatf("%0s %0d",temp_string,DmiIds[i]);
        rpn++;
    end // for (int i=0; i<nDMIs; i++)				   
    `uvm_info("IOAIU<%=qidx%>BOOT_SEQ", $sformatf("%0s",temp_string), UVM_LOW)

    cur_rpn = rpn;
    DiiIds.delete();
    for(int i=0; i<nDIIs; i++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DiiInfo[0].strRtlNamePrefix%>.DIIUFUIDR.get_offset();
        rw_tsks.read_csr<%=qidx%>(addr,data);
	`uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg DII_FUIDR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        DiiIds = new[DiiIds.size()+1] (DiiIds);
        DiiIds[DiiIds.size()-1] =  data[15:0];
        if(i==0) begin temp_string=""; temp_string = $sformatf("%0s DiiIds : \n",temp_string); end
        temp_string = $sformatf("%0s %0d",temp_string,DiiIds[i]);
        rpn++;
    end // for (int i=0; i<nDMIs; i++)				   
    `uvm_info("IOAIU<%=qidx%>BOOT_SEQ", $sformatf("%0s",temp_string), UVM_LOW)

    foreach(t_chiaiu_en[i]) begin
       `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("t_chiaiu_en[%0d] = %0d", i, t_chiaiu_en[i]), UVM_MEDIUM)
    end
    foreach(t_ioaiu_en[i]) begin
       `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("t_ioaiu_en[%0d] = %0d", i, t_ioaiu_en[i]), UVM_MEDIUM)
    end
    active_numChiAiu = $countones(t_chiaiu_en);
    active_numIoAiu = $countones(t_ioaiu_en);
    numChiAiu = active_numChiAiu;
    numIoAiu  = active_numIoAiu;

    temp_string="";
    numCmdCCR=0;
    foreach(AiuIds[i]) begin
    int tempCmdCCR=0;
      foreach(DceIds[x]) begin
        if($test$plusargs("chiaiu_test")) begin
          if(i<<%=numChiAiu%>  && t_chiaiu_en[i]==1) aCredit_Cmd[AiuIds[i]][DceIds[x]] = ((act_cmd_skid_buf_size["DCE"][x]/numChiAiu) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE  : (act_cmd_skid_buf_size["DCE"][x]/numChiAiu);
          else aCredit_Cmd[AiuIds[i]][DceIds[x]] = 0; 
        end
        else if($test$plusargs("ioaiu_test")) begin
          if(i>=<%=numChiAiu%> && t_ioaiu_en[i-<%=numChiAiu%>]==1)  aCredit_Cmd[AiuIds[i]][DceIds[x]] = ((act_cmd_skid_buf_size["DCE"][x]/numIoAiu) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DCE"][x]/numIoAiu);
          else aCredit_Cmd[AiuIds[i]][DceIds[x]] = 0; 
        end
        else begin
          aCredit_Cmd[AiuIds[i]][DceIds[x]] = ((act_cmd_skid_buf_size["DCE"][x]/dce_connected[x]) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DCE"][x]/dce_connected[x]);
          //aCredit_Cmd[AiuIds[i]][DceIds[x]] = ((act_cmd_skid_buf_size["DCE"][x]/AiuIds.size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DCE"][x]/AiuIds.size());
        end

        tempCmdCCR = tempCmdCCR + 1;
        temp_string = $sformatf("%0saCredit_Cmd[%0d][%0d] %0d\n",temp_string,AiuIds[i],DceIds[x],aCredit_Cmd[AiuIds[i]][DceIds[x]]);

      end

      numCmdCCR = tempCmdCCR;
      tempCmdCCR=0;
      foreach(DmiIds[y]) begin
        if($test$plusargs("chiaiu_test")) begin
          if(i<<%=numChiAiu%> && t_chiaiu_en[i]==1) aCredit_Cmd[AiuIds[i]][DmiIds[y]] = ((act_cmd_skid_buf_size["DMI"][y]/numChiAiu) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DMI"][y]/numChiAiu);
          else aCredit_Cmd[AiuIds[i]][DmiIds[y]] = 0; 
        end
        else if($test$plusargs("ioaiu_test")) begin
          if(i>=<%=numChiAiu%> && t_ioaiu_en[i-<%=numChiAiu%>]==1)  aCredit_Cmd[AiuIds[i]][DmiIds[y]] = ((act_cmd_skid_buf_size["DMI"][y]/numIoAiu) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE: (act_cmd_skid_buf_size["DMI"][y]/numIoAiu);
          else aCredit_Cmd[AiuIds[i]][DmiIds[y]] = 0; 
        end
        else begin
          //aCredit_Cmd[AiuIds[i]][DmiIds[y]] = ((act_cmd_skid_buf_size["DMI"][y]/AiuIds.size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DMI"][y]/AiuIds.size());
          aCredit_Cmd[AiuIds[i]][DmiIds[y]] = ((act_cmd_skid_buf_size["DMI"][y]/dmi_connected[y]) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DMI"][y]/dmi_connected[y]);
        end

        tempCmdCCR = tempCmdCCR + 1;
        temp_string = $sformatf("%0saCredit_Cmd[%0d][%0d] %0d\n",temp_string,AiuIds[i],DmiIds[y],aCredit_Cmd[AiuIds[i]][DmiIds[y]]);
      end

      if(tempCmdCCR>numCmdCCR) numCmdCCR = tempCmdCCR;
      tempCmdCCR=0;
      foreach(DiiIds[z]) begin
        if(z<(DiiIds.size()-1)) begin
            if($test$plusargs("chiaiu_test")) begin
              if(i<<%=numChiAiu%> && t_chiaiu_en[i]==1) aCredit_Cmd[AiuIds[i]][DiiIds[z]] = ((act_cmd_skid_buf_size["DII"][z]/numChiAiu) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE: (act_cmd_skid_buf_size["DII"][z]/numChiAiu);
              else aCredit_Cmd[AiuIds[i]][DiiIds[z]] = 0; 
            end
            else if($test$plusargs("ioaiu_test")) begin
              if(i>=<%=numChiAiu%> && t_ioaiu_en[i-<%=numChiAiu%>]==1)  aCredit_Cmd[AiuIds[i]][DiiIds[z]] = ((act_cmd_skid_buf_size["DII"][z]/numIoAiu) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE: (act_cmd_skid_buf_size["DII"][z]/numIoAiu);
              else aCredit_Cmd[AiuIds[i]][DiiIds[z]] = 0; 
            end
            else begin
              aCredit_Cmd[AiuIds[i]][DiiIds[z]] = ((act_cmd_skid_buf_size["DII"][z]/dii_connected[z]) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DII"][z]/dii_connected[z]);
              if($test$plusargs("credit_limit_sys_dii_access_aiu") && (credit_limit_sys_dii_access_aiu[AiuIds[i]]==1)) begin
                  aCredit_Cmd[AiuIds[i]][DiiIds[DiiIds.size()-1]] = (act_cmd_skid_buf_size["DII"][DiiIds.size()-1]/($countones(credit_limit_sys_dii_access_aiu)));
              end
            end
        end else begin
            if($test$plusargs("chiaiu_test") || $test$plusargs("ioaiu_test")) begin
              if(t_boot_from_ioaiu==1) begin
                if(i>=<%=numChiAiu%> && t_ioaiu_en[i-<%=numChiAiu%>]==1)  aCredit_Cmd[AiuIds[i]][DiiIds[z]] = ((act_cmd_skid_buf_size["DII"][z]/numIoAiu) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DII"][z]/numIoAiu);
                else aCredit_Cmd[AiuIds[i]][DiiIds[z]] = 0; 
              end
              else begin
                if(i<<%=numChiAiu%> && t_chiaiu_en[i]==1) aCredit_Cmd[AiuIds[i]][DiiIds[z]] = ((act_cmd_skid_buf_size["DII"][z]/numChiAiu) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DII"][z]/numChiAiu);
                else aCredit_Cmd[AiuIds[i]][DiiIds[z]] = 0; 
              end
            end else begin
                ////Dividing sys_dii credits between first chiaiu and first ioaiu
                //<% if(numIoAiu>0) {%>
                //if(i==(<%=numChiAiu%>+<%=csrAccess_ioaiu%>))  aCredit_Cmd[AiuIds[i]][DiiIds[z]] = ((act_cmd_skid_buf_size["DII"][z]/2) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DII"][z]/2);
                //<% } %>
                //<% if(numChiAiu>0) {%>
                //if(i==<%=csrAccess_chiaiu%>) aCredit_Cmd[AiuIds[i]][DiiIds[z]] = ((act_cmd_skid_buf_size["DII"][z]/2) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DII"][z]/2);
                //<% } %>
              // finaly in case of check CSR we set credit for each IOAIU
              aCredit_Cmd[AiuIds[i]][DiiIds[z]] = ((act_cmd_skid_buf_size["DII"][z]/dii_connected[z]) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_cmd_skid_buf_size["DII"][z]/dii_connected[z]);
              if($test$plusargs("credit_limit_sys_dii_access_aiu") && (credit_limit_sys_dii_access_aiu[AiuIds[i]]==1)) begin
                  aCredit_Cmd[AiuIds[i]][DiiIds[DiiIds.size()-1]] = (act_cmd_skid_buf_size["DII"][DiiIds.size()-1]/($countones(credit_limit_sys_dii_access_aiu)));
              end
            end
        end

        tempCmdCCR = tempCmdCCR + 1;
        temp_string = $sformatf("%0saCredit_Cmd[%0d][%0d] %0d\n",temp_string,AiuIds[i],DiiIds[z],aCredit_Cmd[AiuIds[i]][DiiIds[z]]);
      end

      if(tempCmdCCR>numCmdCCR) numCmdCCR = tempCmdCCR;
    end

    numMrdCCR = 0;
    foreach(DceIds[i]) begin
      foreach(DmiIds[p]) begin
        aCredit_Mrd[DceIds[i]][DmiIds[p]] = ((act_mrd_skid_buf_size["DMI"][p]/DceIds.size()) > VALID_MAX_CREDIT_VALUE) ? VALID_MAX_CREDIT_VALUE : (act_mrd_skid_buf_size["DMI"][p]/DceIds.size());
        if(i<1) numMrdCCR = numMrdCCR+1;
      end
        //temp_string = $sformatf("%0saCredit_Mrd[%0d][%0d] %0d\n",temp_string,DceIds[i],DmiIds[p],aCredit_Mrd[DceIds[i]][DmiIds[p]]);
      //numMrdCCR = (numMrdCCR%4==0)?(numMrdCCR/4):((numMrdCCR/4)+1);
    end

    `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("numMrdCCR %0d numCmdCCR %0d  active_numChiAiu %0d active_numIoAiu %0d",numMrdCCR,numCmdCCR,active_numChiAiu,active_numIoAiu),UVM_NONE)
    `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt",$sformatf("%0s",temp_string),UVM_NONE)
if(use_sw_crdt_mgr_cls == 0 ) begin:_no_sw_credit
    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
      for(int x=0;x<numCmdCCR;x++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUCCR0.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUCCR0.get_offset()<%}%>; ;
        addr[11:0] = addr[11:0] + (x*4);
        rw_tsks.read_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg AIUCCR-%0d ADDR (0x%0h) = 0x%0h",rpn, x, addr, data), UVM_LOW)
        data[4:0]   = aCredit_Cmd[AiuIds[i]][DceIds[x]];
        data[12:8]  = aCredit_Cmd[AiuIds[i]][DmiIds[x]];
        data[20:16] = aCredit_Cmd[AiuIds[i]][DiiIds[x]];
        data[31:24] = 8'hE0;
        rw_tsks.write_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("Writing rpn %0d Reg AIUCCR-%0d ADDR (0x%0h) = 0x%0h",rpn, x, addr, data), UVM_LOW)
        rw_tsks.read_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg AIUCCR-%0d ADDR (0x%0h) = 0x%0h",rpn, x, addr, data), UVM_LOW)
      end
      rpn++;
    end // for (int i=0; i<nAIUs; i++)				   

    cur_rpn = rpn; ;
    for(int i=0; i<nDCEs; i++) begin
      for(int x=0;x<numMrdCCR;x++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] =  m_concerto_env.m_regs.dce0.DCEUCCR0.get_offset();
        addr[11:0] = addr[11:0] + (x*4);
        rw_tsks.read_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg DCEUCCR-%0d ADDR (0x%0h) = 0x%0h",rpn, i, addr, data), UVM_LOW)
        data[4:0]   = aCredit_Mrd[DceIds[i]][DmiIds[x]];
        data[15:8]  = 8'hE0;
        data[23:16] = 8'hE0;
        data[31:24] = 8'hE0;
        rw_tsks.write_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("Writing rpn %0d Reg DCEUCCR-%0d ADDR (0x%0h) = 0x%0h",rpn, i, addr, data), UVM_LOW)
        rw_tsks.read_csr<%=qidx%>(addr,data);
        `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("Reading rpn %0d Reg DCEUCCR-%0d ADDR (0x%0h) = 0x%0h",rpn, i, addr, data), UVM_LOW)
      end
      rpn++;
    end // for (int i=0; i<nDCEs; i++)				   
					    
<% for(pidx= 0; pidx < obj.nDCEs; pidx++) { %>
      for(int x=0;x<numMrdCCR;x++) begin
        $sformat(dce_credit_msg, "dce%0d_dmi%0d_nMrdInFlight", DceIds[<%=pidx%>], DmiIds[x]);
        new_dce_credits=aCredit_Mrd[DceIds[<%=pidx%>]][DmiIds[x]];
        if(m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.has_scoreboard)
          m_concerto_env.inhouse.m_dce<%=pidx%>_env.m_dce_scb.m_credits.scm_credit(dce_credit_msg, new_dce_credits);
      end
<% } %>
end:_no_sw_credit
end:_boot_ioaiu

<%ioidx=0;%>
<%for(pidx=0; pidx<obj.nAIUs; pidx++) {%>
<%if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache))) {%>
 <% if(obj.testBench!="emu") { %>
    // Let the ioaiu_scoreboard know we're now in ATTACHED state, see CONC-10924
    // Test should only be on ATTACHED but many fsys legacy files unduly set the the FSM in CONNECT as an equivalent state
    // Should be corrected in all files ideally but would be rather intrusive, due to multiport configs etc. TODO
    // Only core 0 should be considered as it's the AIU reference in multiport configs
    if(m_args.ioaiu_scb_en && !$test$plusargs("sysco_disable")) begin
        // during configure phas attache all IOAIU
        if (!m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state inside {ioaiu<%=ioidx%>_env_pkg::CONNECT, ioaiu<%=ioidx%>_env_pkg::ATTACHED}) begin 
            `uvm_info("FULLSYS_TEST", "Triggering IOAIU<%=ioidx%> ev_sysco_fsm_state_change to ATTACHED", UVM_NONE)
             m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state = ioaiu<%=ioidx%>_env_pkg::ATTACHED; 
            ev_sysco_fsm_state_change_<%=obj.AiuInfo[pidx].FUnitId%>.trigger();
            end
        else begin
        	`uvm_warning("IOAIU<%=qidx%>BOOT_SEQ", $psprintf("ioaiu<%=ioidx%> sysco_fsm_state already in %s state at ATTACH time", m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state.name()))
        	// `uvm_error("IOAIU<%=qidx%>BOOT_SEQ", $psprintf("ioaiu<%=ioidx%> sysco_fsm_state already in %s state at ATTACH time", m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state.name()))
	    end
    end
    <% } // if not emu %>
  <%ioidx++;%>
 <%} // if IO%>
<% } //foreach io%>
//REMOVED in concerto_sw_credit_mgr //`uvm_info("IOAIU<%=qidx%>_BOOT_SEQ",$sformatf("Leaving Boot Sequence"),UVM_NONE)
endtask: ioaiu_boot_seq<%=qidx%>

<% } qidx++; }%>
<%} %>

////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////
