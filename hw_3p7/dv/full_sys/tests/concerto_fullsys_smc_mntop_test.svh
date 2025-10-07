<%
//Embedded javascript code to figure number of blocks
var numChiAiu = 0; // Number of CHI AIUs
var numACEAiu = 0; // Number of ACE AIUs
var numIoAiu = 0; // Number of IO AIUs
var numCAiu = 0; // Number of Coherent AIUs
var numNCAiu = 0; // Number of Non-Coherent AIUs
var found_csr_access_ioaiu =0;
var found_csr_access_chi =0;
var csrAccess_ioaiu=0;//TMP COMPILE FIX CONC-11383
var csrAccess_chiaiu;//TMP COMPILE FIX CONC-11383

var qidx = 0;
var initiatorAgents   = obj.AiuInfo.length ;
var aiu_NumCores = [];
var numAiuRpns = 0;   //Total AIU RPN's
var chiaiu0;  // strRtlNamePrefix of chiaiu0
var aceaiu0;  // strRtlNamePrefix of aceaiu0
var _blkid = [];
var _blktype = [];
var _blksuffix = [];
var _blk   = [];
var pidx = 0;
var ridx = 0;
var chiaiu_idx = 0; 
var ioaiu_idx = 0;


for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       _blk[pidx]   = obj.AiuInfo[pidx];
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _blkid[pidx] = 'chiaiu' + chiaiu_idx;
       _blksuffix[pidx] = "_0";
       _blktype[pidx]   = 'chiaiu';
       chiaiu_idx++;
       } else {
       _blkid[pidx] = 'ioaiu' + ioaiu_idx;
       _blksuffix[pidx] = "_0";
       _blktype[pidx]   = 'ioaiu';
       ioaiu_idx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _blkid[ridx] = 'dce' + pidx;
       _blktype[ridx]   = 'dce';
       _blksuffix[ridx] = "";
       _blk[ridx]   = obj.DceInfo[pidx];
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _blkid[ridx] = 'dmi' + pidx;
       _blktype[ridx]   = 'dmi';
       _blksuffix[ridx] = "";
       _blk[ridx]   = obj.DmiInfo[pidx];
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _blkid[ridx] = 'dii' + pidx;
       _blk[ridx]   = 'dii';
       _blksuffix[ridx] = "";
       _blk[ridx]   = obj.DiiInfo[pidx];
   }
   
   var nALLs = ridx+1; 

for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
   } else {
       aiu_NumCores[pidx]    = 1;
   }
 }




for(pidx = 0; pidx < obj.nAIUs; pidx++) {
    if( obj.AiuInfo[pidx].fnNativeInterface == "CHI-A" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" ||
        obj.AiuInfo[pidx].fnNativeInterface == "CHI-C" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-D" ||
        obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")
    {
        // CLU TMP COMPILE FIX CONC-11383 if ((found_csr_access_chi==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_chi_idx = numChiAiu;
            csrAccess_chiaiu = numChiAiu;
            found_csr_access_chi = 1;
         //  }
        if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
        numChiAiu = numChiAiu + 1;numCAiu++ ; 
    } else {
      
      // CLU TMP COMPILE FIX CONC-11383 if  if ((found_csr_access_ioaiu==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_io_idx = numIoAiu;
            csrAccess_ioaiu = numIoAiu;
            found_csr_access_ioaiu = 1;
       //     }
        numIoAiu = numIoAiu + 1;

         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { 
            if(numACEAiu == 0) { aceaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
            numCAiu++; numACEAiu++; 
         } else {
            if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
               if (numNCAiu == 0) { ncaiu0  = obj.AiuInfo[pidx].strRtlNamePrefix + "_0"; }
            } else {
               if (numNCAiu == 0) { ncaiu0  = obj.AiuInfo[pidx].strRtlNamePrefix; }
            }
            numNCAiu++ ;
         }
    }
  if(obj.AiuInfo[pidx].nNativeInterfacePorts) {
       numAiuRpns += obj.AiuInfo[pidx].nNativeInterfacePorts;
    } else {
       numAiuRpns++;
    }
}

var regPrefixName = function() {
                                if (obj.BlockId.charAt(0)=="d")
                                    {return obj.BlockId.match(/[a-z]+/i)[0].toUpperCase();} //dmi,dii,dce,dve => DMI,DII,DVE 
                                if ((obj[obj.AgentInfoName][obj.Id].fnNativeInterface == 'CHI-A')||(obj[obj.AgentInfoName][obj.Id].fnNativeInterface == 'CHI-B')||(obj[obj.AgentInfoName][obj.Id].fnNativeInterface == 'CHI-E')) 
                                    {return "CAIU";}
                                return "XAIU"; // by default
                                };
%>

<%function generateRegPath(regName) {
    if(obj.nNativeInterfacePorts > 1) {
        return 'm_regs.'+obj.strRtlNamePrefix+'_0.'+regName;
    } else {
        return 'm_regs.'+obj.strRtlNamePrefix+'.'+regName;
    }
}%>
class concerto_fullsys_smc_mntop_test extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_smc_mntop_test)

  bit  flush_set_way_en;  
  bit flush_adress_en ;  

  function new(string name = "concerto_fullsys_smc_mntop_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  // UVM PHASE
  extern function void end_of_elaboration_phase(uvm_phase phase);
  extern task run_phase (uvm_phase phase);


  // HOOK task call in the parent class
  extern virtual task main_seq_iter_pre_hook(uvm_phase phase, int iter); // at the beginning of the iteration(inside the iteration loop)
  extern virtual task main_seq_iter_post_hook(uvm_phase phase, int iter);// at the end of the iteration (inside the iteration)
  extern virtual task main_seq_hook_end_run_phase(uvm_phase phase);
  // PRIVATE TASK
  <% if (found_csr_access_ioaiu > 0) { %>
  <% for(var qidx = 0 ; qidx < obj.nDMIs; qidx++) { %>
  <% if (obj.DmiInfo[qidx].useCmc){ %>
  extern task dmi<%=qidx%>_flush_cache(string DmiName);
  <% } %>
  <% } %>
  <% } %>
  <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
//  TMP COMPILE FIX CONC-11383    if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
  extern task ioaiu<%=qidx%>_flush_cache(string AiuName);;// this task will do cache maintenance operations
  ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer  m_ioaiu_vseqr<%=qidx%>;
   <% //} 
 qidx++; }
 } %>

  // FUNCTION

 
endclass: concerto_fullsys_smc_mntop_test


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
function void concerto_fullsys_smc_mntop_test::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
//  TMP COMPILE FIX CONC-11383 if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
 if(!(uvm_config_db#(ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=qidx%>[0]" ),.value( m_ioaiu_vseqr<%=qidx%> ) ))) begin
 `uvm_error(get_name(), "Cannot get m_ioaiu_vseqr<%=qidx%>")
 end
  <% // } 
 qidx++; }
 } %>
endfunction : end_of_elaboration_phase

task concerto_fullsys_smc_mntop_test::run_phase (uvm_phase phase); 
 // Before start the iteration create & setup all the attributs
  max_iteration = 2;
  super.run_phase(phase);
endtask:run_phase

////////////////////////////////////////////////////////////////////////////////////////
// #     #  #######  #######  #    #         #######     #      #####   #    #   #####   
// #     #  #     #  #     #  #   #             #       # #    #     #  #   #   #     #  
// #     #  #     #  #     #  #  #              #      #   #   #        #  #    #        
// #######  #     #  #     #  ###               #     #     #   #####   ###      #####   
// #     #  #     #  #     #  #  #              #     #######        #  #  #          #  
// #     #  #     #  #     #  #   #             #     #     #  #     #  #   #   #     #  
// #     #  #######  #######  #    #  #####     #     #     #   #####   #    #   #####  
////////////////////////////////////////////////////////////////////////////////////////
//////////////////// PRE HOOK                   ////////////
task concerto_fullsys_smc_mntop_test::main_seq_iter_pre_hook(uvm_phase phase, int iter);
  `uvm_info(get_name(), $sformatf("START HOOK main_seq_iter_pre_hook iter:%0d",iter), UVM_NONE)
  phase.raise_objection(this, "Start  cfg sequence");
  `uvm_info(get_name(), " cfg sequence started", UVM_NONE)

  #1us; // wait propagation of the last write to register
    // TODO FOREACH DVE,DCE,DMI,DII
  phase.drop_objection(this, "Finish  cfg sequence");
  `uvm_info(get_name(), $sformatf("END HOOK main_seq_iter_pre_hook iter:%0d",iter), UVM_NONE)

endtask:main_seq_iter_pre_hook

////////////////////////////////////////////////////////////
//////////////////// POST HOOK ///////////
task concerto_fullsys_smc_mntop_test::main_seq_iter_post_hook(uvm_phase phase, int iter);
  
  `uvm_info(get_name(), $sformatf("START HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)
if (iter == 0) begin//at the end of the first iteration:when all txn are excuted do cache maintenance operation:flush all entries
  
  flush_set_way_en = 0;
  flush_adress_en =0; 
  if($test$plusargs("dmi_cmc_mntop_test")) begin//do dmi cmc mntop
   <% if (found_csr_access_ioaiu > 0) { %>
    <% for(var qidx = 0 ; qidx < obj.nDMIs; qidx++) { %>
    <% if (obj.DmiInfo[qidx].useCmc){ %>
    `uvm_info("concerto_fullsys_smc_mntop_test", "Calling dmi<%=qidx%>_flush_cache(dmi<%=qidx%>)", UVM_NONE)
    dmi<%=qidx%>_flush_cache("dmi<%=qidx%>");
    <% } %>
    <% } %>
    <% } %>
  end else begin//do proxy cache mntop
    <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
    //  TMP COMPILE FIX CONC-11383 if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>

    <% for(var coreidx=0; coreidx < aiu_NumCores[idx]; coreidx++) { %>
    <% if((((obj.AiuInfo[idx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[idx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[idx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[idx].fnNativeInterface == "ACE") || ((obj.AiuInfo[idx].fnNativeInterface == "AXI4") && (obj.AiuInfo[idx].useCache))) { %>

    `uvm_info("concerto_fullsys_smc_mntop_test", "Calling ioaiu<%=qidx%>_flush_cache(<%=obj.AiuInfo[idx].strRtlNamePrefix+((aiu_NumCores[idx]>1)?("_"+coreidx):"")%> for ioaiu<%=ioaiu_idx%>_<%=coreidx%>)", UVM_NONE)
    ioaiu<%=qidx%>_flush_cache("<%=obj.AiuInfo[idx].strRtlNamePrefix+((aiu_NumCores[idx]>1)?("_"+coreidx):"")%>"); 
  
    #5us; // still wait a bit for all pipes to drain
    <% } %> 
    <% } %> 
  
  
    <% // } 
    qidx++; }
    } %>
  end
end else if (iter == 1) begin////at the end of the second iteration:when all txn are excuted do cache maintenance operation:flush entry at set and way

  flush_set_way_en = 0;
  flush_adress_en =1;
  if($test$plusargs("dmi_cmc_mntop_test")) begin
  <% if (found_csr_access_ioaiu > 0) { %>
  <% for(var qidx = 0 ; qidx < obj.nDMIs; qidx++) { %>
  <% if (obj.DmiInfo[qidx].useCmc){ %>
  `uvm_info("concerto_fullsys_smc_mntop_test", "Calling dmi<%=qidx%>_flush_cache(dmi<%=qidx%>)", UVM_NONE)
  dmi<%=qidx%>_flush_cache("dmi<%=qidx%>");
  <% } %>
  <% } %>
  <% } %>
  end else begin
  <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
  if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
  //  TMP COMPILE FIX CONC-11383 if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>

  <% for(var coreidx=0; coreidx < aiu_NumCores[idx]; coreidx++) { %>
  <% if((((obj.AiuInfo[idx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[idx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[idx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[idx].fnNativeInterface == "ACE") || ((obj.AiuInfo[idx].fnNativeInterface == "AXI4") && (obj.AiuInfo[idx].useCache))) { %>
 
  `uvm_info("concerto_fullsys_smc_mntop_test", "Calling ioaiu<%=qidx%>_flush_cache(<%=obj.AiuInfo[idx].strRtlNamePrefix+((aiu_NumCores[idx]>1)?("_"+coreidx):"")%> for ioaiu<%=ioaiu_idx%>_<%=coreidx%>)", UVM_NONE)
  ioaiu<%=qidx%>_flush_cache("<%=obj.AiuInfo[idx].strRtlNamePrefix+((aiu_NumCores[idx]>1)?("_"+coreidx):"")%>"); 
  #5us; // still wait a bit for all pipes to drain

  <% } %> 
  <% } %> 
 
 
  <% // } 
  qidx++; }
  } %>  
  end
end

  `ifndef USE_VIP_SNPS 
      `ifdef VCS
      super.main_seq_iter_post_hook(phase,iter); 
      `endif // `ifdef VCS
   `endif // `ifndef USE_VIP_SNPS 

  `uvm_info(get_name(), $sformatf("END HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)

endtask:main_seq_iter_post_hook

////////////////////////////////////////////////////////////
////////////   HOOK END RUN PHASE       ///////////////
task concerto_fullsys_smc_mntop_test::main_seq_hook_end_run_phase(uvm_phase phase);
  phase.raise_objection(this, "main_seq_hook_end_run_phase");
  `uvm_info(get_name(), "HOOK main_seq_hook_end_run_phase", UVM_NONE)
   

  `uvm_info(get_name(), "end of HOOK main_seq_hook_end_run_phase, ", UVM_NONE)
   phase.drop_objection(this, "main_seq_hook_end_run_phase");

endtask:main_seq_hook_end_run_phase

////////////////////////////////////////////////////////////
///////////// flush proxy cache     ///////////////
 <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
//  TMP COMPILE FIX CONC-11383 if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
task concerto_fullsys_smc_mntop_test::ioaiu<%=qidx%>_flush_cache(string AiuName);
    ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;
    bit [31:0] data;
    bit [31:0] cache_addr;
    bit [31:0] mask;
    bit [31:0] field_val;
    bit [19:0] MntSet;
    bit [5:0]  MntWay;
    int unsigned nindex;
    bit m_security;
    int offset = <%=obj.wCacheLineOffset%>;
  	ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t m_addr; 
    uvm_reg    ral_reg;
    uvm_reg_field ral_field;

    // Test if a proxy $ is present
    ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUINFOR");
    ral_field = ral_reg.get_field_by_name("UT");
    
    rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
    field_val = ((1 << ral_field.get_n_bits())-1) & (data >> ral_field.get_lsb_pos());

    // flush only an NCAIU with proxy $
    `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_MEDIUM)
    if (field_val== 2) begin   // TODO replace hard-code val
        `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("UT=0x%0h, ioaiu<%=qidx%>_flush_cache(%s)", field_val, AiuName), UVM_NONE)
        // ioaiu<%=qidx%>_flush_cache(AiuName);
        end 
    else 
        return;

    `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("ioaiu<%=qidx%>_flush_cache: Flushing all tag array entries for %s", AiuName), UVM_NONE)
    // poll until no more active ops
    ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUPCMAR");
    ral_field = ral_reg.get_field_by_name("MntOpActv");

    do begin
        rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
        field_val = ((1 << ral_field.get_n_bits())-1) & (data >> ral_field.get_lsb_pos());
        `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)    
    end while(field_val == 1);

    if (flush_adress_en) begin
    // Flush  entry at set and way of proxy cache 

        <% if (obj.AiuInfo[idx].useCache){ %>
        MntSet = $urandom_range(0,<%=obj.AiuInfo[idx].ccpParams.nSets%>);
        MntWay = $urandom_range(0,<%=obj.AiuInfo[idx].ccpParams.nWayss%>); 
          
        if( m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_scb.m_ncbu_cache_q.size()>0) begin
            nindex = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_scb.m_ncbu_cache_q.size()-1;
            `uvm_info("concerto_fullsys_smc_mntop_test",$sformatf("index %d cache model q size %d",nindex,
                        m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_scb.m_ncbu_cache_q.size()), UVM_MEDIUM)
            MntSet = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_scb.m_ncbu_cache_q[nindex].Index; 
            MntWay = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_scb.m_ncbu_cache_q[nindex].way; 
        end 
        <%}%> 
        `uvm_info("concerto_fullsys_smc_mntop_test",$sformatf("configuring MntSet :%x,  MntWay :%x ",MntSet,MntWay), UVM_NONE)
        ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUPCMLR0");
        rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);

        // set XAIUPCMLR0 MntSet field 
        ral_field = ral_reg.get_field_by_name("MntSet");
        mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
        data &= mask; // set field to 0
        data |= (MntSet << ral_field.get_lsb_pos()); // set field to value
        
        // set XAIUPCMLR0 MntWay field  
        ral_field = ral_reg.get_field_by_name("MntWay");
        mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
        data &= mask; // set field to 0
        data |= (MntWay << ral_field.get_lsb_pos()); // set field to value
        rw_tsks.write_csr<%=qidx%>(ral_reg.get_address(), data);                                                
      `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)
      #100ns;
      
      // RMWrite : Op = 5 (flush Entry at Set and Way), ArrayID=0 (Tag array)
      ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUPCMCR");
      rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
      ral_field = ral_reg.get_field_by_name("ArrayID");
      mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
      data &= mask; // set field to 0
      ral_field = ral_reg.get_field_by_name("MntOp");
      // `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_NONE)
      mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
      data &= mask; // set field to 0
      data |= (5 << ral_field.get_lsb_pos()); // set field to value       

    end else if(flush_set_way_en) begin
    // Flush cachelines using address
       <% if (obj.AiuInfo[idx].useCache){ %>
        
        if( m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_scb.m_ncbu_cache_q.size()>0) begin
            nindex = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_scb.m_ncbu_cache_q.size()-1;
            `uvm_info("concerto_fullsys_smc_mntop_test",$sformatf("index %d cache model q size %d",nindex,
                        m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_scb.m_ncbu_cache_q.size()), UVM_MEDIUM)
            m_addr     = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_scb.m_ncbu_cache_q[nindex].addr; 
            m_security = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_scb.m_ncbu_cache_q[nindex].security; 
            `uvm_info("concerto_fullsys_smc_mntop_test",$sformatf("Flush cachelines using addressr :%x from IO cache model",m_addr), UVM_LOW)
        end 
        <%}%> 

        // set XAIUPCMLR1 MntWay field 

	      <% if((obj.AiuInfo[idx].wAddr-obj.wCacheLineOffset) > 32) {%>
        cache_addr = m_addr >> offset;
        cache_addr = cache_addr >> 'h20;
        <%}else{%>
        cache_addr = m_addr >> offset; 
        <%}%>
       ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUPCMLR1");
       rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);    
       ral_field = ral_reg.get_field_by_name("MntAddr");
       mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
       data &= mask; // set field to 0
       data |= (cache_addr << ral_field.get_lsb_pos()); // set field to value
       rw_tsks.write_csr<%=qidx%>(ral_reg.get_address(), data); 
      #200ns;

      // RMWrite : Op = 6 flush Entry at adress

      ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUPCMCR");
      rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
      ral_field = ral_reg.get_field_by_name("ArrayID");
      mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
      data &= mask; // set field to 0
      ral_field = ral_reg.get_field_by_name("MntOp");
      // `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_NONE)
      mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
      data &= mask; // set field to 0
      data |= (6 << ral_field.get_lsb_pos()); // set field to value 

    end else begin
      // Flush all entries of proxy cache Tag array
      // RMWrite : Op = 4 (flush all entries), ArrayID=0 (Tag array)
      ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUPCMCR");
      rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
      ral_field = ral_reg.get_field_by_name("ArrayID");
      mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
      data &= mask; // set field to 0
      ral_field = ral_reg.get_field_by_name("MntOp");
      // `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_NONE)
      mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
      data &= mask; // set field to 0
      data |= (4 << ral_field.get_lsb_pos()); // set field to value
    end
    rw_tsks.write_csr<%=qidx%>(ral_reg.get_address(), data);                                                
    `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)
    #10ns;
    // poll until no more active ops
    ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUPCMAR");
    ral_field = ral_reg.get_field_by_name("MntOpActv");
    do begin
        #100ns;                                                                        
        rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
        field_val = ((1 << ral_field.get_n_bits())-1) & (data >> ral_field.get_lsb_pos());
        `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)
    end while(field_val == 1);

endtask : ioaiu<%=qidx%>_flush_cache
  <% // } 
 qidx++; }
 } %>

////////////////////////////////////////////////////////////
///////////// flush DMI CMC     ///////////////
<% if (found_csr_access_ioaiu > 0) { %>
  <% for(var pidx=0, qidx = 0 ; qidx < obj.nDMIs; qidx++) { %>
  <% if (obj.DmiInfo[qidx].useCmc){ %>
task concerto_fullsys_smc_mntop_test::dmi<%=qidx%>_flush_cache(string DmiName);
    bit [31:0] data;
    bit [31:0] cache_addr;
    bit [31:0] mask;
    bit [31:0] field_val;
    bit [19:0] MntSet;
    bit [5:0]  MntWay;
    int unsigned nindex;
    bit m_security;
    uvm_reg    ral_reg;
    uvm_reg_field ral_field;



    `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("dmi<%=qidx%>_flush_cache: Flushing all tag array entries for %s", DmiName), UVM_NONE)
    // poll until no more active ops
    ral_reg = m_concerto_env.m_regs.get_block_by_name(DmiName).get_reg_by_name("DMIUSMCMAR");
    ral_field = ral_reg.get_field_by_name("MntOpActv");

    do begin
        rw_tsks.read_csr<%=csrAccess_ioaiu%>(ral_reg.get_address(), data);
        field_val = ((1 << ral_field.get_n_bits())-1) & (data >> ral_field.get_lsb_pos());
        `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("dmi<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)    
    end while(field_val == 1);

    if (flush_adress_en) begin
    // Flush  entry at set and way of cmc cache 

        <% if (obj.DmiInfo[qidx].useCmc){ %>
        MntSet = $urandom_range(0,<%=obj.DmiInfo[qidx].ccpParams.nSets%>);
        MntWay = $urandom_range(0,<%=obj.DmiInfo[qidx].ccpParams.nWays%>); 
          
        if(  m_concerto_env.inhouse.m_dmi<%=qidx%>_env.m_sb.m_dmi_cache_q.size()>0) begin
            nindex =  m_concerto_env.inhouse.m_dmi<%=qidx%>_env.m_sb.m_dmi_cache_q.size()-1;
            `uvm_info("concerto_fullsys_smc_mntop_test",$sformatf("index %d cache model q size %d",nindex,
                         m_concerto_env.inhouse.m_dmi<%=qidx%>_env.m_sb.m_dmi_cache_q.size()), UVM_MEDIUM)
            MntSet =  m_concerto_env.inhouse.m_dmi<%=qidx%>_env.m_sb.m_dmi_cache_q[nindex].Index; 
            MntWay =  m_concerto_env.inhouse.m_dmi<%=qidx%>_env.m_sb.m_dmi_cache_q[nindex].way; 
        end 
        <%}%> 
        `uvm_info("concerto_fullsys_smc_mntop_test",$sformatf("configuring MntSet :%x,  MntWay :%x ",MntSet,MntWay), UVM_NONE)
        ral_reg = m_concerto_env.m_regs.get_block_by_name(DmiName).get_reg_by_name("DMIUSMCMLR0");
        rw_tsks.read_csr<%=csrAccess_ioaiu%>(ral_reg.get_address(), data);

        // set DMIUSMCMLR0 MntSet field 
        ral_field = ral_reg.get_field_by_name("MntSet");
        mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
        data &= mask; // set field to 0
        data |= (MntSet << ral_field.get_lsb_pos()); // set field to value
        
        // set DMIUSMCMLR0 MntWay field  
        ral_field = ral_reg.get_field_by_name("MntWay");
        mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
        data &= mask; // set field to 0
        data |= (MntWay << ral_field.get_lsb_pos()); // set field to value
        rw_tsks.read_csr<%=csrAccess_ioaiu%>(ral_reg.get_address(), data);                                                
      `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("dmi<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)
      #100ns;
      
      // RMWrite : Op = 5 (flush Entry at Set and Way), ArrayID=0 (Tag array)
      ral_reg = m_concerto_env.m_regs.get_block_by_name(DmiName).get_reg_by_name("DMIUSMCMCR");
      rw_tsks.read_csr<%=csrAccess_ioaiu%>(ral_reg.get_address(), data);
      ral_field = ral_reg.get_field_by_name("ArrayID");
      mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
      data &= mask; // set field to 0
      ral_field = ral_reg.get_field_by_name("MntOp");
      // `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_NONE)
      mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
      data &= mask; // set field to 0
      data |= (5 << ral_field.get_lsb_pos()); // set field to value       

    end else begin
      // Flush all entries of CMC cache Tag array
      // RMWrite : Op = 4 (flush all entries), ArrayID=0 (Tag array)
      ral_reg = m_concerto_env.m_regs.get_block_by_name(DmiName).get_reg_by_name("DMIUSMCMCR");
      rw_tsks.read_csr<%=csrAccess_ioaiu%>(ral_reg.get_address(), data);
      ral_field = ral_reg.get_field_by_name("ArrayID");
      mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
      data &= mask; // set field to 0
      ral_field = ral_reg.get_field_by_name("MntOp");
      mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
      data &= mask; // set field to 0
      data |= (4 << ral_field.get_lsb_pos()); // set field to value
    end
    rw_tsks.read_csr<%=csrAccess_ioaiu%>(ral_reg.get_address(), data);                                                
    `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("dmi<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)
    #10ns;
    // poll until no more active ops
    ral_reg = m_concerto_env.m_regs.get_block_by_name(DmiName).get_reg_by_name("DMIUSMCMAR");
    ral_field = ral_reg.get_field_by_name("MntOpActv");
    do begin
        #100ns;                                                                        
        rw_tsks.read_csr<%=csrAccess_ioaiu%>(ral_reg.get_address(), data);
        field_val = ((1 << ral_field.get_n_bits())-1) & (data >> ral_field.get_lsb_pos());
        `uvm_info("concerto_fullsys_smc_mntop_test", $sformatf("dmi<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)
    end while(field_val == 1);

endtask : dmi<%=qidx%>_flush_cache
<% } %>	
<% } %>	
<% } %>	

//task concerto_fullsys_smc_mntop_test::post_shutdown_phase(uvm_phase phase);
//main_seq_hook_end_run_phase(phase);
//endtask:post_shutdown_phase


////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////
