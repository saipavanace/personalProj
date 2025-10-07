<%

let pma_en_dmi_blk = 1;
let pma_en_dii_blk = 1;
let pma_en_aiu_blk = 1;
let pma_en_dce_blk = 1;
let pma_en_dve_blk = 1;
let pma_en_at_least_1_blk = 0;
let pma_en_all_blk = 1;
let numChiAiu = 0; // Number of CHI AIUs
let numACEAiu = 0; // Number of ACE AIUs
let numIoAiu = 0; // Number of IO AIUs
let numCAiu = 0; // Number of Coherent AIUs
let numNCAiu = 0; // Number of Non-Coherent AIUs
let numBootIoAiu = 0; // Number of NCAIUs can participate in Boot
let chiaiu0;  // strRtlNamePrefix of chiaiu0
let aceaiu0;  // strRtlNamePrefix of aceaiu0
let ncaiu0;   // strRtlNamePrefix of aceaiu0
let csrAccess_ioaiu;
let csrAccess_chiaiu;
let idxIoAiuWithPC = obj.nAIUs; // To get valid index of NCAIU with ProxyCache. Initialize to nAIUs
let numDmiWithSMC = 0; // Number of DMIs with SystemMemoryCache
let idxDmiWithSMC = 0; // To get valid index of DMI with SystemMemoryCache
let numDmiWithSP = 0; // Number of DMIs with ScratchPad memory
let idxDmiWithSP = 0; // To get valid index of DMIs with ScratchPad memory
let numDmiWithWP = 0; // Number of DMIs with WayPartitioning
let idxDmiWithWP = 0; // To get valid index of DMIs with WayPartitioning
let noBootIoAiu = 1;
const BootIoAiu = [];
let found_csr_access_chiaiu=0;
let found_csr_access_ioaiu=0;
const aiu_axiInt = [];
const dmi_width= [];
let AiuCore;
const initiatorAgents   = obj.AiuInfo.length ;
const aiu_NumCores = [];
const aiu_rpn = [];
const aiuName = [];

   const _blkid = [];
   const _blkportsid =[];
   const _blk   = [{}];
   let _idx = 0;
   let qidx=0;
   let idx=0;
   let chi_idx=0;
   let io_idx=0;
   let aiu_idx = 0;
   let nAIUs_mpu =0; 
   
   for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
      if(!Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       _blk[_idx]   = obj.AiuInfo[pidx];
       _blkid[_idx] = 'aiu' + aiu_idx;
       _blkportsid[_idx] = 0;
       nAIUs_mpu++;
       aiu_idx++;
       _idx++;
       } else {
       for (let port_idx = 0; port_idx < obj.AiuInfo[pidx].nNativeInterfacePorts; port_idx++) {
        _blk[_idx]   = obj.AiuInfo[pidx];
        _blkid[_idx] = 'aiu' + aiu_idx ;
        _blkportsid[_idx] = port_idx;
        _idx++;
        nAIUs_mpu++;
        }
        aiu_idx++;
       }
   }

 for(let pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn[0];
   } else {
       aiu_NumCores[pidx]    = 1;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn;
   }
 }

for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt[0];
        AiuCore = 'ioaiu_core0';
    } else {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt;
        AiuCore = 'ioaiu_core0';
    }
}

for(let pidx = 0; pidx < obj.nDMIs; pidx++) {
    pma_en_dmi_blk &= obj.DmiInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DmiInfo[pidx].usePma;
    if(obj.DmiInfo[pidx].useCmc)
       {
         numDmiWithSMC++;
         idxDmiWithSMC = pidx;
         if(obj.DmiInfo[pidx].ccpParams.useScratchpad)
            {
              numDmiWithSP++;
              idxDmiWithSP = pidx;
            }
         if(obj.DmiInfo[pidx].useWayPartitioning)
            {
              numDmiWithWP++;
              idxDmiWithWP = pidx;
            }
       }
}
for(let pidx = 0; pidx < obj.nDIIs; pidx++) {
    pma_en_dii_blk &= obj.DiiInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DiiInfo[pidx].usePma;
}
// Assuming CHI AIU will appear first in AiuInfo in top.level.dv.json before IO-AIUs
chi_idx=0;
io_idx=0;
for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
    pma_en_aiu_blk &= obj.AiuInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.AiuInfo[pidx].usePma;
    if((obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) 
       { 
       if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
       if(obj.AiuInfo[pidx].fnCsrAccess == 1) {
         if (found_csr_access_chiaiu == 0) {
          csrAccess_chiaiu = chi_idx;
          found_csr_access_chiaiu = 1;
         }
       }
       numChiAiu++ ; numCAiu++ ; 
       chi_idx++;
       }
    else
       { numIoAiu++ ; 
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { 
             if(numACEAiu == 0) { aceaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
	     numCAiu++; numACEAiu++; 
         } else {
             if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
                 if (numNCAiu == 0) { ncaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix + "_0"; }
             } else {
                 if (numNCAiu == 0) { ncaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
             }
             numNCAiu++ ;
         }
//         if(obj.AiuInfo[pidx].useCache) idxIoAiuWithPC = numNCAiu;
         if(obj.AiuInfo[pidx].useCache) {
             idxIoAiuWithPC = pidx;
             if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
                 aiuName[pidx]  = obj.AiuInfo[pidx].strRtlNamePrefix + "_0";
             } else {
                 aiuName[pidx]  = obj.AiuInfo[pidx].strRtlNamePrefix;
            }
         }
         if(obj.AiuInfo[pidx].fnCsrAccess == 1) {
            if (found_csr_access_ioaiu == 0) {
	       csrAccess_ioaiu = io_idx;
	       found_csr_access_ioaiu = 1;
            }
	    BootIoAiu[numBootIoAiu] = io_idx;
            numBootIoAiu++;
	    noBootIoAiu = 0;
         }
         io_idx++;
       }
}
for(let pidx = 0; pidx < obj.nDCEs; pidx++) {
    pma_en_dce_blk &= obj.DceInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DceInfo[pidx].usePma;
}
for(let pidx = 0; pidx < obj.nDVEs; pidx++) {
    pma_en_dve_blk &= obj.DveInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DveInfo[pidx].usePma;
}
pma_en_all_blk = pma_en_dmi_blk & pma_en_dii_blk & pma_en_aiu_blk & pma_en_dce_blk & pma_en_dve_blk;

console.log("pma_en_at_least_1_blk = "+pma_en_at_least_1_blk);
console.log("pma_en_all_blk = "+pma_en_all_blk);

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
                             if((item.fnNativeInterface.match("CHI"))) { 
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
                             if(!(item.fnNativeInterface.match("CHI"))) { 
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
%>
class concerto_fullsys_qchannel_test extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_qchannel_test)

<% for(idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
  if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) {%>
  extern virtual task access_boot_region_ioaiu<%=qidx%>();
  ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer  m_ioaiu_vseqr<%=qidx%>[<%=aiu_NumCores[idx]%>];
    <%qidx++; }
    } %>

  function new(string name = "concerto_fullsys_qchannel_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  // UVM PHASE
   extern virtual function void end_of_elaboration_phase(uvm_phase  phase);
   extern virtual task ncore_test_stimulus(uvm_phase phase);

endclass: concerto_fullsys_qchannel_test


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
function void concerto_fullsys_qchannel_test::end_of_elaboration_phase(uvm_phase phase);
  super.end_of_elaboration_phase(phase);
<% for(idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
   if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) {
     for(let i=0; i<aiu_NumCores[idx]; i++) { %> 
 if(!(uvm_config_db#(ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=qidx%>[<%=i%>]" ),.value( m_ioaiu_vseqr<%=qidx%>[<%=i%>] ) ))) begin
 `uvm_error(get_name(), "Cannot get m_ioaiu_vseqr<%=qidx%>[<%=i%>]")
 end
      <%}%>
    <%qidx++; }
    } %>
endfunction:end_of_elaboration_phase

// pre_configure_phase => Before the Boot tasks
task concerto_fullsys_qchannel_test::ncore_test_stimulus(uvm_phase phase); 
   int 	      num_qchannel_loop;
   int 	      loop;
   int 	      rand_delay;
   
 `uvm_info("CONCERTO_FULLSYS_QCHANNEL_TEST", "START ncore_test_stimulus", UVM_LOW)
phase.raise_objection(this, "Start QCHANNEL test");

 if (!test_cfg.k_access_boot_region)
      `uvm_error("QCHANNEL_TEST", "you must use +k_access_boot_region")

 `ifndef USE_VIP_SNPS_CHI //existing flow will not run when USE_VIP_SNPS_CHI set
  <% qidx=0;idx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
    m_chi<%=idx%>_vseq = chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)::type_id::create("m_chi<%=idx%>_seq");

    m_chi<%=idx%>_vseq.set_seq_name("m_chi<%=idx%>_seq");
    m_chi<%=idx%>_vseq.m_chi_container =  m_concerto_env.inhouse.m_chi<%=idx%>_container;
    m_chi<%=idx%>_vseq.m_regs = m_concerto_env.m_regs;
    
    m_chi<%=idx%>_vseq.wt_chi_data_flit_data_err                           =  m_args.aiu<%=pidx%>_wt_chi_data_flit_data_err;
    m_chi<%=idx%>_vseq.wt_chi_data_flit_non_data_err                       =  m_args.aiu<%=pidx%>_wt_chi_data_flit_non_data_err;
    m_chi<%=idx%>_vseq.m_chi_container.k_snp_rsp_data_err_wgt              =  m_args.aiu<%=pidx%>_k_snp_rsp_data_err_wgt;
    m_chi<%=idx%>_vseq.m_chi_container.k_snp_rsp_non_data_err_wgt          =  m_args.aiu<%=pidx%>_k_snp_rsp_non_data_err_wgt;
    m_concerto_env_cfg.m_chiaiu<%=idx%>_env_cfg.k_snp_rsp_non_data_err_wgt =  m_args.aiu<%=pidx%>_k_snp_rsp_non_data_err_wgt; 

    foreach(chiaiu_en[i]) begin
      m_chi<%=idx%>_vseq.t_chiaiu_en[i]= chiaiu_en[i];
    end

    m_chi<%=idx%>_vseq.m_rn_tx_req_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_tx_req_chnl_seqr;
    m_chi<%=idx%>_vseq.m_rn_tx_dat_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_tx_dat_chnl_seqr;
    m_chi<%=idx%>_vseq.m_rn_tx_rsp_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_tx_rsp_chnl_seqr;
    m_chi<%=idx%>_vseq.m_rn_rx_rsp_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_rx_rsp_chnl_seqr;
    m_chi<%=idx%>_vseq.m_rn_rx_dat_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_rx_dat_chnl_seqr;
    m_chi<%=idx%>_vseq.m_rn_rx_snp_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_rx_snp_chnl_seqr;
    m_chi<%=idx%>_vseq.m_lnk_hske_seqr            = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_lnk_hske_seqr;
    m_chi<%=idx%>_vseq.m_txs_actv_seqr            = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_txs_actv_seqr;
    m_chi<%=idx%>_vseq.m_sysco_seqr               = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_sysco_seqr;
    m_chi<%=idx%>_vseq.k_directed_test            = k_directed_test;
 <%idx++;%>
<%} // if CHI%>  
<%} // foreach AIU%>  
`endif

 <% if(obj.PmaInfo.length > 0) { %>
  <% if (pma_en_all_blk) { %>
  if($test$plusargs("qchannel_multiple_request_test"))begin:_qch_multi_req
   // #Stimulus.FSYS.qchannel.multiple_request_test

   fork 
     begin //traffic
     automatic int boot_loop = 0;
     <% qidx=0;idx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
       repeat(20)begin
       phase.raise_objection(this, $sformatf("ioaiu_boot_seq%0d", boot_loop));
       `uvm_info("FULLSYS_TEST", $sformatf("Start IOAIU<%=qidx%> access_boot_region_seq loop %0d", boot_loop), UVM_NONE)
       access_boot_region_ioaiu<%=qidx%>();
       `uvm_info("FULLSYS_TEST", $sformatf("Done IOAIU<%=qidx%> access_boot_region_seq loop %0d", boot_loop), UVM_NONE)
       phase.drop_objection(this, $sformatf("ioaiu_boot_seq%0d", boot_loop));
       boot_loop = boot_loop + 1;
       end
      <% break; } %>
<%  } %>
     end

     begin //q_chal_req
        //Starting Q channel sequence
       automatic int qseq_loop = 0;
       automatic int random_delay;

       repeat(05)begin
          random_delay = $urandom_range(10000,1000);
          #(random_delay * 1ns);

          fork
        <% idx = 0; %>
        <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
          <% if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
          begin
            `ifdef USE_VIP_SNPS_CHI //SVT LINK
              `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_DOWN_service_sequence::START[<%=idx%>]", UVM_LOW)
               svt_chi_link_dn_seq_h<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].link_svc_seqr) ;
              `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_DOWN_service_sequence::END[<%=idx%>]", UVM_LOW)
            `else //`ifdef USE_VIP_SNPS_CHI
              m_chi<%=idx%>_vseq.construct_lnk_down_seq();
            `endif //`ifdef USE_VIP_SNPS_CHI ... `else
          end
          <% idx++; %>
          <%} %>
        <% } %>
         begin
         phase.raise_objection(this, $sformatf("q_chnl_seq%0d", qseq_loop));
//         wait(!m_concerto_env.inhouse.<%=obj.PmaInfo[0].strRtlNamePrefix%>_qc_if.QACCEPTn);
         `uvm_info("FULLSYS_TEST", $sformatf("Q_SEQ%0d wait for <%=obj.PmaInfo[0].strRtlNamePrefix%>_qc_if.QACCEPTn==1", loop),UVM_NONE)
         wait(m_concerto_env.inhouse.<%=obj.PmaInfo[0].strRtlNamePrefix%>_qc_if.QACCEPTn == 1);
         rand_delay = $urandom_range(12000, 10000);
         `uvm_info("FULLSYS_TEST", $sformatf("Q_SEQ%0d_START", qseq_loop),UVM_NONE)
         m_concerto_env.inhouse.m_q_chnl_seq0.start(m_concerto_env.inhouse.m_q_chnl_agent0.m_q_chnl_seqr);
         `uvm_info("FULLSYS_TEST", $sformatf("Q_SEQ%0d_END", qseq_loop),UVM_NONE)
     	 #((rand_delay) * 1ns);
         //wait(m_concerto_env.inhouse.<%=obj.PmaInfo[0].strRtlNamePrefix%>_qc_if.QACCEPTn);
         phase.drop_objection(this, $sformatf("q_chnl_seq%0d", qseq_loop));
	 qseq_loop = qseq_loop + 1;
         end
          join
       end
     end
   join

    fork
  <% idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
    begin
      `ifdef USE_VIP_SNPS_CHI //SVT LINK
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_UP_service_sequence::START[<%=idx%>]", UVM_LOW)
         chi_coh_bringup_vseq.chi_linkup_vseq.svt_chi_link_up_seq_h<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].link_svc_seqr) ;
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_UP_service_sequence::END[<%=idx%>]", UVM_LOW)
      `else //`ifdef USE_VIP_SNPS_CHI
        m_chi<%=idx%>_vseq.construct_lnk_seq();
      `endif //`ifdef USE_VIP_SNPS_CHI ... `else
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join
  end:_qch_multi_req
else if($test$plusargs("qchannel_req_between_cmd_test"))begin:_qch_cmd_test
// #Stimulus.FSYS.qchannel.between_cmd_test

  <% qidx=0;idx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
     if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
            `uvm_info("FULLSYS_TEST", $sformatf("Start IOAIU<%=qidx%> access_boot_region_seq loop %0d", loop), UVM_NONE)
            access_boot_region_ioaiu<%=qidx%>();
            `uvm_info("FULLSYS_TEST", $sformatf("Done IOAIU<%=qidx%> access_boot_region_seq loop %0d", loop), UVM_NONE)
      <% break; } %>
  <%} %>
    fork
  <% idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
    begin
      `ifdef USE_VIP_SNPS_CHI //SVT LINK
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_DOWN_service_sequence::START[<%=idx%>]", UVM_LOW)
         svt_chi_link_dn_seq_h<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].link_svc_seqr) ;
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_DOWN_service_sequence::END[<%=idx%>]", UVM_LOW)
      `else //`ifdef USE_VIP_SNPS_CHI
        m_chi<%=idx%>_vseq.construct_lnk_down_seq();
      `endif //`ifdef USE_VIP_SNPS_CHI ... `else
    end
    <% idx++; %>
    <%} %>
  <% } %>
    begin
        //Starting Q channel sequence
        phase.raise_objection(this, $sformatf("q_chnl_seq%0d", loop));
        wait(m_concerto_env.inhouse.<%=obj.PmaInfo[0].strRtlNamePrefix%>_qc_if.QACCEPTn); 
        `uvm_info("qchannel_req_between_cmd_test", $sformatf("Q_SEQ%0d_START", loop),UVM_LOW)
        m_concerto_env.inhouse.m_q_chnl_seq0.start(m_concerto_env.inhouse.m_q_chnl_agent0.m_q_chnl_seqr);
        `uvm_info("qchannel_req_between_cmd_test", $sformatf("Q_SEQ%0d_END", loop),UVM_LOW)
        phase.drop_objection(this, $sformatf("q_chnl_seq%0d", loop));
    end
    join

  <% qidx=0;idx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
     if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
            `uvm_info("FULLSYS_TEST", $sformatf("Start IOAIU<%=qidx%> access_boot_region_seq loop %0d", loop), UVM_NONE)
            access_boot_region_ioaiu<%=qidx%>();
            `uvm_info("FULLSYS_TEST", $sformatf("Done IOAIU<%=qidx%> access_boot_region_seq loop %0d", loop), UVM_NONE)
      <% break; } %>
  <% } %>
        //Starting Q channel sequence
    fork
  <% idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
    begin
      `ifdef USE_VIP_SNPS_CHI //SVT LINK
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_UP_service_sequence::START[<%=idx%>]", UVM_LOW)
         chi_coh_bringup_vseq.chi_linkup_vseq.svt_chi_link_up_seq_h<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].link_svc_seqr) ;
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_UP_service_sequence::END[<%=idx%>]", UVM_LOW)
      `else //`ifdef USE_VIP_SNPS_CHI
        m_chi<%=idx%>_vseq.construct_lnk_seq();
      `endif //`ifdef USE_VIP_SNPS_CHI ... `else
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join
end:_qch_cmd_test
else if($test$plusargs("qchannel_reset_test"))begin:_qch_reset
// #Stimulus.FSYS.qchannel.reset_test

    fork
      begin
  <% qidx=0;idx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
     <%if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
            `uvm_info("FULLSYS_TEST", $sformatf("Start IOAIU<%=qidx%> access_boot_region_seq loop %0d", loop), UVM_NONE)
            access_boot_region_ioaiu<%=qidx%>();
            `uvm_info("FULLSYS_TEST", $sformatf("Done IOAIU<%=qidx%> access_boot_region_seq loop %0d", loop), UVM_NONE)
      <% break; } %>
  <%} %>
    fork
  <% idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
      begin
      `ifdef USE_VIP_SNPS_CHI //SVT LINK
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_DOWN_service_sequence::START[<%=idx%>]", UVM_LOW)
         svt_chi_link_dn_seq_h<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].link_svc_seqr) ;
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_DOWN_service_sequence::END[<%=idx%>]", UVM_LOW)
      `else //`ifdef USE_VIP_SNPS_CHI
        m_chi<%=idx%>_vseq.construct_lnk_down_seq();
      `endif //`ifdef USE_VIP_SNPS_CHI ... `else
      end
    <% idx++; %>
    <%} %>
  <% } %>
      begin
        //Starting Q channel sequence
        phase.raise_objection(this, $sformatf("q_chnl_seq%0d", loop));
        `uvm_info("qchannel_reset_test", $sformatf("Q_SEQ%0d_START", loop),UVM_LOW)
        wait(!m_concerto_env.inhouse.<%=obj.PmaInfo[0].strRtlNamePrefix%>_qc_if.QACTIVE); 
        m_concerto_env.inhouse.m_q_chnl_seq0.start(m_concerto_env.inhouse.m_q_chnl_agent0.m_q_chnl_seqr);
        `uvm_info("qchannel_reset_test", $sformatf("Q_SEQ%0d_END", loop),UVM_LOW)
        phase.drop_objection(this, $sformatf("q_chnl_seq%0d", loop));
      end
    join
      end
      begin
        repeat(1) begin
          phase.raise_objection(this, $sformatf("reset_test q_cnl_seq")); 
          wait(!m_concerto_env.inhouse.<%=obj.PmaInfo[0].strRtlNamePrefix%>_qc_if.QACTIVE && !m_concerto_env.inhouse.<%=obj.PmaInfo[0].strRtlNamePrefix%>_qc_if.QREQn && !m_concerto_env.inhouse.<%=obj.PmaInfo[0].strRtlNamePrefix%>_qc_if.QACCEPTn);
          repeat(2)@(posedge m_concerto_env.inhouse.<%=obj.PmaInfo[0].strRtlNamePrefix%>_qc_if.clk); 
          #30ns;//repeat(3)@(posedge qc_if.clk); 
          `uvm_info("FULLSYS_TEST", $sformatf("Toggling reset"),UVM_LOW)
          toggle_rstn.trigger();
          #30ns;//repeat(3)@(posedge qc_if.clk); 
          `uvm_info("FULLSYS_TEST", $sformatf("Toggling reset"),UVM_LOW)
          toggle_rstn.trigger();
	  //wait till the reset is deaserted before booting once again
          repeat(10)@(posedge m_concerto_env.inhouse.<%=obj.PmaInfo[0].strRtlNamePrefix%>_qc_if.clk); 
    <% qidx=0;idx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
     if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
          `uvm_info("FULLSYS_TEST", $sformatf("Start IOAIU<%=qidx%> access_boot_region_seq loop %0d", loop), UVM_NONE)
          access_boot_region_ioaiu<%=qidx%>();
          `uvm_info("FULLSYS_TEST", $sformatf("Done IOAIU<%=qidx%> access_boot_region_seq loop %0d", loop), UVM_NONE)
      <% break; } %>
  <%} %>
          phase.drop_objection(this, $sformatf("reset_test q_cnl_seq"));
        end
      end
    join

    fork
  <% idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
     <%if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
    begin
      `ifdef USE_VIP_SNPS_CHI //SVT LINK
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_UP_service_sequence::START[<%=idx%>]", UVM_LOW)
         chi_coh_bringup_vseq.chi_linkup_vseq.svt_chi_link_up_seq_h<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].link_svc_seqr) ;
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_UP_service_sequence::END[<%=idx%>]", UVM_LOW)
      `else //`ifdef USE_VIP_SNPS_CHI
        m_chi<%=idx%>_vseq.construct_lnk_seq();
      `endif //`ifdef USE_VIP_SNPS_CHI ... `else
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join
end:_qch_reset
else begin: _qch_bydefault

     if(!$value$plusargs("num_qchannel_loop=%d", num_qchannel_loop)) begin
        num_qchannel_loop = 0;
     end
     if(num_qchannel_loop > 0) begin
	loop = 0;
        repeat(num_qchannel_loop) begin
  <% qidx=0;idx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
     <%if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
            `uvm_info("FULLSYS_TEST", $sformatf("Start IOAIU<%=qidx%> access_boot_region_seq loop %0d", loop), UVM_NONE)
            access_boot_region_ioaiu<%=qidx%>();
            `uvm_info("FULLSYS_TEST", $sformatf("Done IOAIU<%=qidx%> access_boot_region_seq loop %0d", loop), UVM_NONE)
      <% break; } %>
  <%} %>
    fork
  <% idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
     <%if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
    begin
      `ifdef USE_VIP_SNPS_CHI //SVT LINK
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_DOWN_service_sequence::START[<%=idx%>]", UVM_LOW)
         svt_chi_link_dn_seq_h<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].link_svc_seqr) ;
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_DOWN_service_sequence::END[<%=idx%>]", UVM_LOW)
      `else //`ifdef USE_VIP_SNPS_CHI
        m_chi<%=idx%>_vseq.construct_lnk_down_seq();
      `endif //`ifdef USE_VIP_SNPS_CHI ... `else
    end
    <% idx++; %>
    <%} %>
  <% } %>
    begin
        //Starting Q channel sequence
        // #Stimulus.FSYS.qchannel.sanity_test
        phase.raise_objection(this, $sformatf("q_chnl_seq%0d", loop));
        wait(m_concerto_env.inhouse.<%=obj.PmaInfo[0].strRtlNamePrefix%>_qc_if.QACCEPTn); 
        #5000ns;
        `uvm_info("qchannel_sanity_test", $sformatf("Q_SEQ%0d_START", loop),UVM_LOW)
        m_concerto_env.inhouse.m_q_chnl_seq0.start(m_concerto_env.inhouse.m_q_chnl_agent0.m_q_chnl_seqr);
        `uvm_info("qchannel_sanity_test", $sformatf("Q_SEQ%0d_END", loop),UVM_LOW)
        phase.drop_objection(this, $sformatf("q_chnl_seq%0d", loop));
    end
    join
        loop = loop + 1;
        end // repeat (num_qchannel_loop)			   
     end // if (num_qchannel_loop > 0)			   

    fork
  <% idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
     <%if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
    begin
      `ifdef USE_VIP_SNPS_CHI //SVT LINK
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_UP_service_sequence::START[<%=idx%>]", UVM_LOW)
         chi_coh_bringup_vseq.chi_linkup_vseq.svt_chi_link_up_seq_h<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].link_svc_seqr) ;
        `uvm_info(get_name(), "USE_VIP_SNPS_CHI svt_chi_link_UP_service_sequence::END[<%=idx%>]", UVM_LOW)
      `else //`ifdef USE_VIP_SNPS_CHI
        m_chi<%=idx%>_vseq.construct_lnk_seq();
      `endif //`ifdef USE_VIP_SNPS_CHI ... `else
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join
end:_qch_bydefault    
  <% } %>
<% } %>

ev_sim_done.trigger(null);

phase.drop_objection(this, "END QCHANNEL test");
 `uvm_info("CONCERTO_FULLSYS_QCHANNEL_TEST", "END ncore_test_stimulus", UVM_LOW)
endtask:ncore_test_stimulus

////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////

<% for(idx = 0, qidx=0; idx < obj.nAIUs; idx++) { %>
     <%if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
`ifdef USE_VIP_SNPS_AXI_MASTERS
task concerto_fullsys_qchannel_test::access_boot_region_ioaiu<%=qidx%>();
  bit [51:0] boot_region_addr;
  bit [31:0] data;
  seq_lib_svt_ace_read_sequence m_iordnosnp_iordonce_seq<%=qidx%>[<%=aiu_NumCores[idx]%>];

  <% for(let i=0; i<aiu_NumCores[idx]; i++) { %> 
   m_iordnosnp_iordonce_seq<%=qidx%>[<%=i%>]   = seq_lib_svt_ace_read_sequence::type_id::create("m_iordnosnp_iordonce_seq<%=qidx%>[<%=i%>]");
   m_iordnosnp_iordonce_seq<%=qidx%>[<%=i%>].tr   = svt_axi_master_transaction::type_id::create("tr");
   <% } %>

  if($test$plusargs("boot_coh_access")) begin
          // m_iordonce_seq<%=qidx%>.m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>;
          do begin
          boot_region_addr = addr_mgr.get_bootreg_addr(<%=obj.AiuInfo[idx].FUnitId%>, 1);
          end while (boot_region_addr[11:0] > 12'hFC0);
          `uvm_info("access_boot_region_ioaiu<%=qidx%>", $sformatf("Reading boot region addr 0x%0h", boot_region_addr), UVM_NONE)
          <% for(let i=0; i<aiu_NumCores[idx]; i++) { %> 
          m_iordnosnp_iordonce_seq<%=qidx%>[<%=i%>].myAddr = boot_region_addr;
          m_iordnosnp_iordonce_seq<%=qidx%>[<%=i%>].axlen  = ((64*8)/ioaiu<%=qidx%>_axi_agent_pkg::WXDATA)-1;
          m_iordnosnp_iordonce_seq<%=qidx%>[<%=i%>].m_coh_transaction =1;
          m_iordnosnp_iordonce_seq<%=qidx%>[<%=i%>].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=qidx%>].sequencer);
         
         // data = (m_iordonce_seq<%=qidx%>.m_seq_item.m_has_data) ? m_iordonce_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rdata[0] : 0;
            data =  m_iordnosnp_iordonce_seq<%=qidx%>[<%=i%>].tr.data[0];
         <% } %>
          `uvm_info("access_boot_region_ioaiu<%=qidx%>", $sformatf("boot region[0x%0h] = 0x%0h", boot_region_addr, data), UVM_NONE)
//          boot_region_addr = boot_region_addr+8'b01000000;
      
  end
  else begin
          for(int i=0; i<test_cfg.ioaiu_num_trans; i=i+1) begin
          do begin
          boot_region_addr = addr_mgr.get_bootreg_addr(<%=obj.AiuInfo[idx].FUnitId%>, 1);
          end while (boot_region_addr[11:0] > 12'hFC0);
          `uvm_info("access_boot_region_ioaiu<%=qidx%>", $sformatf("Reading boot region addr 0x%0h", boot_region_addr), UVM_NONE)
          <% for(let i=0; i<aiu_NumCores[idx]; i++) { %>
          m_iordnosnp_iordonce_seq<%=qidx%>[<%=i%>].myAddr = boot_region_addr;
          m_iordnosnp_iordonce_seq<%=qidx%>[<%=i%>].axlen  = ((64*8)/ioaiu<%=qidx%>_axi_agent_pkg::WXDATA)-1;
          m_iordnosnp_iordonce_seq<%=qidx%>[<%=i%>].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=qidx%>].sequencer);
        //  data = (m_iordnosnp_seq<%=qidx%>.m_seq_item.m_has_data) ? m_iordnosnp_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rdata[0] : 0;
          data =  m_iordnosnp_iordonce_seq<%=qidx%>[<%=i%>].tr.data[0];
          <% } %>
          `uvm_info("access_boot_region_ioaiu<%=qidx%>", $sformatf("boot region[0x%0h] = 0x%0h", boot_region_addr, data), UVM_NONE)
      end
  end
endtask:access_boot_region_ioaiu<%=qidx%>
`else //`ifdef USE_VIP_SNPS_AXI_MASTERS-inhouse
task concerto_fullsys_qchannel_test::access_boot_region_ioaiu<%=qidx%>();
  bit [51:0] boot_region_addr;
  bit [31:0] data;
  
  ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdnosnp_seq m_iordnosnp_seq<%=qidx%>[<%=aiu_NumCores[idx]%>];
  ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq m_iordonce_seq<%=qidx%>[<%=aiu_NumCores[idx]%>];

  if($test$plusargs("boot_coh_access")) begin
     <% for(let i=0; i<aiu_NumCores[idx]; i++) { %>
      m_iordonce_seq<%=qidx%>[<%=i%>]   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq::type_id::create("m_iordonce_seq<%=qidx%>[<%=i%>]");
      m_iordonce_seq<%=qidx%>[<%=i%>].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>];
      <%}%>
      for(int i=0; i<ioaiu_num_trans; i=i+1) begin
          do begin
          boot_region_addr = addr_mgr.get_bootreg_addr(<%=obj.AiuInfo[idx].FUnitId%>, 1);
          end while (boot_region_addr[11:0] > 12'hFC0);
          `uvm_info("access_boot_region_ioaiu<%=qidx%>", $sformatf("Reading boot region addr 0x%0h", boot_region_addr), UVM_NONE)
         <% for(let i=0; i<aiu_NumCores[idx]; i++) { %>
          m_iordonce_seq<%=qidx%>[<%=i%>].m_addr = boot_region_addr;
          m_iordonce_seq<%=qidx%>[<%=i%>].m_len  = ((64*8)/ioaiu<%=qidx%>_axi_agent_pkg::WXDATA)-1;
          m_iordonce_seq<%=qidx%>[<%=i%>].start(m_ioaiu_vseqr<%=qidx%>[<%=i%>]);
          data = (m_iordonce_seq<%=qidx%>[<%=i%>].m_seq_item.m_has_data) ? m_iordonce_seq<%=qidx%>[<%=i%>].m_seq_item.m_read_data_pkt.rdata[0] : 0;
          <%}%>
          `uvm_info("access_boot_region_ioaiu<%=qidx%>", $sformatf("boot region[0x%0h] = 0x%0h", boot_region_addr, data), UVM_NONE)
//          boot_region_addr = boot_region_addr+8'b01000000;
      end
  end
  else begin
     <% for(let i=0; i<aiu_NumCores[idx]; i++) { %>
      m_iordnosnp_seq<%=qidx%>[<%=i%>]   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdnosnp_seq::type_id::create("m_iordnosnp_seq<%=qidx%>[<%=i%>]");
      m_iordnosnp_seq<%=qidx%>[<%=i%>].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>];
      <%}%>
      for(int i=0; i<test_cfg.ioaiu_num_trans; i=i+1) begin
          do begin
          boot_region_addr = addr_mgr.get_bootreg_addr(<%=obj.AiuInfo[idx].FUnitId%>, 1);
          end while (boot_region_addr[11:0] > 12'hFC0);
          `uvm_info("access_boot_region_ioaiu<%=qidx%>", $sformatf("Reading boot region addr 0x%0h", boot_region_addr), UVM_NONE)
          <% for(let i=0; i<aiu_NumCores[idx]; i++) { %>
          m_iordnosnp_seq<%=qidx%>[<%=i%>].m_addr = boot_region_addr;
          m_iordnosnp_seq<%=qidx%>[<%=i%>].m_len  = ((64*8)/ioaiu<%=qidx%>_axi_agent_pkg::WXDATA)-1;
          m_iordnosnp_seq<%=qidx%>[<%=i%>].start(m_ioaiu_vseqr<%=qidx%>[<%=i%>]);
          data = (m_iordnosnp_seq<%=qidx%>[<%=i%>].m_seq_item.m_has_data) ? m_iordnosnp_seq<%=qidx%>[<%=i%>].m_seq_item.m_read_data_pkt.rdata[0] : 0;
          <%}%>
          `uvm_info("access_boot_region_ioaiu<%=qidx%>", $sformatf("boot region[0x%0h] = 0x%0h", boot_region_addr, data), UVM_NONE)
      end
  end
endtask:access_boot_region_ioaiu<%=qidx%>
`endif //`ifdef USE_VIP_SNPS_AXI_MASTERS... `else
 <% qidx++;%>
 <%}}%>
