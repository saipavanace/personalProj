<%

var pma_en_dmi_blk = 1;
var pma_en_dii_blk = 1;
var pma_en_aiu_blk = 1;
var pma_en_dce_blk = 1;
var pma_en_dve_blk = 1;
var pma_en_at_least_1_blk = 0;
var pma_en_all_blk = 1;
var numChiAiu = 0; // Number of CHI AIUs
var numACEAiu = 0; // Number of ACE AIUs
var numIoAiu = 0; // Number of IO AIUs
var numCAiu = 0; // Number of Coherent AIUs
var numNCAiu = 0; // Number of Non-Coherent AIUs
var numBootIoAiu = 0; // Number of NCAIUs can participate in Boot
var chiaiu0;  // strRtlNamePrefix of chiaiu0
var aceaiu0;  // strRtlNamePrefix of aceaiu0
var ncaiu0;   // strRtlNamePrefix of aceaiu0
var csrAccess_ioaiu;
var csrAccess_chiaiu;
var idxIoAiuWithPC = obj.nAIUs; // To get valid index of NCAIU with ProxyCache. Initialize to nAIUs
var numDmiWithSMC = 0; // Number of DMIs with SystemMemoryCache
var idxDmiWithSMC = 0; // To get valid index of DMI with SystemMemoryCache
var numDmiWithSP = 0; // Number of DMIs with ScratchPad memory
var idxDmiWithSP = 0; // To get valid index of DMIs with ScratchPad memory
var numDmiWithWP = 0; // Number of DMIs with WayPartitioning
var idxDmiWithWP = 0; // To get valid index of DMIs with WayPartitioning
var noBootIoAiu = 1;
const BootIoAiu = [];
var found_csr_access_chiaiu=0;
var found_csr_access_ioaiu=0;
const aiu_axiInt = [];
var dmi_width= [];
var AiuCore;
var initiatorAgents   = obj.AiuInfo.length ;
var aiu_NumCores = [];
var aiu_rpn = [];
const aiuName = [];

   var _blkid = [];
   var _blkportsid =[];
   var _blk   = [{}];
   var _idx = 0;
   var aiu_idx = 0;
   obj.nAIUs_mpu =0; 
   
   for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
      if(!Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       _blk[_idx]   = obj.AiuInfo[pidx];
       _blkid[_idx] = 'aiu' + aiu_idx;
       _blkportsid[_idx] = 0;
       obj.nAIUs_mpu++;
       aiu_idx++;
       _idx++;
       } else {
       for (var port_idx = 0; port_idx < obj.AiuInfo[pidx].nNativeInterfacePorts; port_idx++) {
        _blk[_idx]   = obj.AiuInfo[pidx];
        _blkid[_idx] = 'aiu' + aiu_idx ;
        _blkportsid[_idx] = port_idx;
        _idx++;
        obj.nAIUs_mpu++;
        }
        aiu_idx++;
       }
   }

 for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn[0];
   } else {
       aiu_NumCores[pidx]    = 1;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn;
   }
 }

for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt[0];
        AiuCore = 'ioaiu_core0';
    } else {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt;
        AiuCore = 'ioaiu_core0';
    }
}

for(var pidx = 0; pidx < obj.nDMIs; pidx++) {
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
for(var pidx = 0; pidx < obj.nDIIs; pidx++) {
    pma_en_dii_blk &= obj.DiiInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DiiInfo[pidx].usePma;
}
// Assuming CHI AIU will appear first in AiuInfo in top.level.dv.json before IO-AIUs
var chi_idx=0;
var io_idx=0;
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
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
for(var pidx = 0; pidx < obj.nDCEs; pidx++) {
    pma_en_dce_blk &= obj.DceInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DceInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nDVEs; pidx++) {
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
                            if(item.fnNativeInterface.match("CHI")) {
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

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//               /\             /\            /\       
//              /  \           /  \          /  \
//             /    \         /    \        /    \
//            /  |   \       /  |   \      /  |   \
//           /   |    \     /   |    \    /   |    \
//          /    °     \   /    °     \  /    °     \
//         /____________\ /____________\/____________\
// LEGACY use with CONCERTO_FULLSYS_TEST +perf_test=1
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

class concerto_fullsys_perf_legacy_test extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_perf_legacy_test)

   // UVM PHASE
   extern virtual function void end_of_elaboration_phase(phase);
   extern virtual task exec_inhouse_seq (uvm_phase phase);
   <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
   if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
     extern virtual task ioaiu_write_bw<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t awid);
     extern virtual task ioaiu_read_bw<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t arid);
      ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer  m_ioaiu_vseqr<%=qidx%>[<%=aiu_NumCores[idx]%>];
   <% qidx++; }}%>

  function new(string name = "concerto_fullsys_perf_legacy_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  

endclass: concerto_fullsys_perf_legacy_test


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
function void concerto_fullsys_perf_legacy_test::end_of_elaboration_phase (uvm_phase phase);
  super.end_of_elaboration_phase(phase);
<% for(var pidx = 0,qidx=0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
      <% for(var coreidx=0; coreidx<aiu_NumCores[pidx]; coreidx++) { %> 
     if(!(uvm_config_db#(ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>]" ),.value( m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>] ) ))) begin
     `uvm_error(get_name(), "Cannot get m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>]")
     end
      <% } %>
      <%  qidx++; } %>
    <% } %>
endfunction:end_of_elaboration_phase

task concerto_fullsys_perf_legacy_test::exec_inhouse_seq (uvm_phase phase);
// OVERWRITE exec_inhouse_seq used in the main_phase
`uvm_info("perf_legacy_TEST", "START EXEC_INHOUSE_SEQ", UVM_LOW)
 if(!$test$plusargs("perf_test")) 
      `uvm_error("REG_BASH_TEST", "you must use +perf_test=1")
      
  // trigger csr_init_done to unit scoreboards
  csr_init_done.trigger(null);

  #100ns; 
  if ($value$plusargs("use_user_addrq=%d", use_user_addrq)) begin:_use_user_addrq
      gen_addr_use_user_addrq()
  end:_use_user_addrq     

`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
   fork 
      begin
         fork
	       <%var cidx=0; var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
            if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
            `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
            begin
               `uvm_info("FULLSYS_TEST", "Start CHIAIU<%=cidx%> VSEQ", UVM_NONE)
               phase.raise_objection(this, "CHIAIU<%=cidx%> sequence");
               m_chi<%=cidx%>_vseq.start(null);
               `uvm_info("FULLSYS_TEST", "Done CHIAIU<%=cidx%> VSEQ", UVM_NONE)
               //#5us;
               phase.drop_objection(this, "CHIAIU<%=cidx%> sequence");
            end // if ($test$plusargs("perf_test"))
            `endif //`ifndef USE_VIP_SNPS
		<% cidx ++;} else {%>
         <%   for(var i=0; i<aiu_NumCores[pidx]; i++) {  %>
	    begin
	       if(ioaiu_num_trans > 0) begin
	          phase.raise_objection(this, "IOAIU<%=qidx%>[<%=i%>] sequence");
		  `uvm_info("FULLSYS_TEST", "Start IOAIU<%=qidx%>[<%=i%>] VSEQ", UVM_NONE)
		  if($test$plusargs("read_test")) begin
                     fsys_main_traffic_vseq.ioaiu_traffic_vseq.m_iocache_seq<%=qidx%>[<%=i%>].start(null);
		  end else begin
                     for(int i=0; i<ioaiu_num_trans; i=i+1) begin
		        fork
			   automatic int id = i;
			   begin 
			      ioaiu_write_bw<%=qidx%>(id); 
			   end
			join_none;
           end

                     //wait fork;
		     //#100ns;
		     ev_ioaiu<%=qidx%>_seq_done[<%=i%>].trigger();
		  end
                  `uvm_info("FULLSYS_TEST", "Done IOAIU<%=qidx%>[<%=i%>] VSEQ", UVM_NONE)
                  //#5us;
                  phase.drop_objection(this, "IOAIU<%=qidx%>[<%=i%>] sequence");
		   end // if (ioaiu_num_trans > 0)
		end
           <%    } // foreach core
           qidx++; }
         } %>
            
               begin  // WAIT ALL TRIGGER
                fork
              <% var cidx=0; var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
                  if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
                   begin
                   ev_chi<%=cidx%>_seq_done.wait_trigger();
                   `uvm_info("FULLSYS_TEST", "ev_chi<%=cidx%>_seq_done triggerred", UVM_LOW)
		               end
	          	<% cidx++; } else { %>   
                  <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
                   begin
                     if(ioaiu_num_trans > 0) begin
                      ev_ioaiu<%=qidx%>_seq_done[<%=i%>].wait_trigger();
                      `uvm_info("FULLSYS_TEST", "ev_ioaiu<%=qidx%>_seq_done triggerred", UVM_LOW)	  
    	      	       end 
		               end		 
                   <%} // foreach core %>
				   <% qidx++;%>
          <% } %>
       <% } %>
                join
                `uvm_info("FULLSYS_TEST", "All sequences DONE", UVM_NONE)
                ev_sim_done.trigger(null);
                end
             join
	  end // if ($test$plusargs("perf_test"))
          begin
             #(sim_timeout_ms*1ms);
             timeout = 1;
          end
       join_any
       //disable fork;
`endif //`ifndef USE_VIP_SNPS
`uvm_info("perf_legacy_TEST", "END EXEC_INHOUSE_SEQ", UVM_LOW)
endtask: exec_inhouse_seq

////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////

<% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { 
%>
`ifdef USE_VIP_SNPS
task concerto_fullsys_perf_legacy_test::ioaiu_write_bw<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t awid);
 seq_lib_svt_ace_write_sequence write_bw_seq<%=qidx%>[17];
    
    for(int i = 0; i < 17; i++) begin
       automatic int k = i;
       fork
          begin 
             write_bw_seq<%=qidx%>[k]          = seq_lib_svt_ace_write_sequence ::type_id::create("write_bw_seq");
             write_bw_seq<%=qidx%>[k].m_coh_transaction =1;
	    // write_bw_seq<%=qidx%>[k].m_ace_cache_model = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>;
             write_bw_seq<%=qidx%>[k].awid = awid;
             write_bw_seq<%=qidx%>[k].axlen  = (k == 0) ? ((32*8)/ioaiu<%=qidx%>_axi_agent_pkg::WXDATA)-1: ((256*8)/ioaiu<%=qidx%>_axi_agent_pkg::WXDATA)-1;
             write_bw_seq<%=qidx%>[k].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=qidx%>].sequencer);
          end
       join_none
    end
//todo
`uvm_info("WIP", "Task5: ioaiu_write_bw<%=qidx%>", UVM_NONE);


endtask
`else //`ifdef USE_VIP_SNPS
task concerto_fullsys_perf_legacy_test::ioaiu_write_bw<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t awid);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrunq_seq write_bw_seq<%=qidx%>[<%=aiu_NumCores[idx]%>][17];

    for(int i = 0; i < 17; i++) begin
       automatic int k = i;
       fork
    <%for(var i=0; i<aiu_NumCores[idx]; i++) { %> 
          begin
            write_bw_seq<%=qidx%>[<%=i%>][k]          = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrunq_seq::type_id::create("write_bw_seq[<%=i%>]");
	        write_bw_seq<%=qidx%>[<%=i%>][k].m_ace_cache_model = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>];
            write_bw_seq<%=qidx%>[<%=i%>][k].use_awid = awid;
            write_bw_seq<%=qidx%>[<%=i%>][k].m_axlen  = (k == 0) ? ((32*8)/ioaiu<%=qidx%>_axi_agent_pkg::WXDATA)-1: ((256*8)/ioaiu<%=qidx%>_axi_agent_pkg::WXDATA)-1;
            write_bw_seq<%=qidx%>[<%=i%>][k].start(m_ioaiu_vseqr<%=qidx%>[<%=i%>]);
          end
    <% }%>
       join_none
    end
endtask : ioaiu_write_bw<%=qidx%>
`endif //`ifdef USE_VIP_SNPS ... `else

`ifdef USE_VIP_SNPS
task concerto_fullsys_perf_legacy_test::ioaiu_read_bw<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t arid);
seq_lib_svt_ace_read_sequence  read_bw_seq<%=qidx%>[16];

    for(int i = 0; i < 16; i++) begin
       automatic int k = i;
       fork
          begin
             read_bw_seq<%=qidx%>[k]          = seq_lib_svt_ace_read_sequence ::type_id::create("read_bw_seq");
             read_bw_seq<%=qidx%>[k].m_coh_transaction =1;
             read_bw_seq<%=qidx%>[k].myAddr   = addr_mgr.get_coh_addr(<%=obj.AiuInfo[idx].FUnitId%>,1);
             read_bw_seq<%=qidx%>[k].arid = arid;
             read_bw_seq<%=qidx%>[k].axlen   = ((256*8)/`SVT_AXI_ADDR_WIDTH) - 1;
             read_bw_seq<%=qidx%>[k].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=qidx%>].sequencer);
          end
       join
    end

endtask : ioaiu_read_bw<%=qidx%>
`else //`ifdef USE_VIP_SNPS
task concerto_fullsys_perf_legacy_test::ioaiu_read_bw<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t arid);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq read_bw_seq<%=qidx%>[<%=aiu_NumCores[idx]%>][16];

    for(int i = 0; i < 16; i++) begin
       automatic int k = i;
       fork
    <%for(var i=0; i<aiu_NumCores[idx]; i++) { %> 
          begin
             read_bw_seq<%=qidx%>[<%=i%>][k]          = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq::type_id::create("read_bw_seq[<%=i%>]");
             read_bw_seq<%=qidx%>[<%=i%>][k].m_addr   = addr_mgr.get_coh_addr(<%=obj.AiuInfo[idx].FUnitId%>,1);
             read_bw_seq<%=qidx%>[<%=i%>][k].use_arid = arid;
             read_bw_seq<%=qidx%>[<%=i%>][k].m_len    = ((256*8)/ioaiu<%=qidx%>_axi_agent_pkg::WXDATA) - 1;
             read_bw_seq<%=qidx%>[<%=i%>][k].start(m_ioaiu_vseqr<%=qidx%>[<%=i%>]);
          end
    <% }%>
       join
    end
endtask : ioaiu_read_bw<%=qidx%>
`endif //`ifdef USE_VIP_SNPS ... `else

<% qidx++; }
 } %>
