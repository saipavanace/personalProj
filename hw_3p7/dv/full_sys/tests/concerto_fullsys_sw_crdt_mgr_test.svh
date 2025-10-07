<%
//Embedded javascript code to figure number of blocks
var numChiAiu = 0; // Number of CHI AIUs
var numACEAiu = 0; // Number of ACE AIUs
var numIoAiu = 0; // Number of IO AIUs
var numCAiu = 0; // Number of Coherent AIUs
var numNCAiu = 0; // Number of Non-Coherent AIUs
var found_csr_access_ioaiu =0;
var found_csr_access_chi =0;
var csrAccess_ioaiu=0;
var csrAccess_chiaiu;

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
        if ((found_csr_access_chi==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_chi_idx = numChiAiu;
            csrAccess_chiaiu = numChiAiu;
            found_csr_access_chi = 1;
            }
        if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
        numChiAiu = numChiAiu + 1;numCAiu++ ; 
    } else {
      
        if ((found_csr_access_ioaiu==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
            csrAccess_io_idx = numIoAiu;
            csrAccess_ioaiu = numIoAiu;
            found_csr_access_ioaiu = 1;
            }
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
import addr_trans_mgr_pkg::*;

class concerto_fullsys_sw_crdt_mgr_test extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_sw_crdt_mgr_test)


  int main_seq_iter=1;
  int numCmdCCR ;
  int boot_from_ioaiu = 1;
  
  // Handle sw credit manager 
  concerto_sw_credit_mgr  m_concerto_sw_credit_mgr;                               
                                  
  function new(string name = "concerto_fullsys_sw_crdt_mgr_test", uvm_component parent=null);
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
  <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
  extern task check_crdt_done<%=qidx%>(uvm_phase phase);// this function will check that all credit are back
  extern task read_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, output bit[31:0]data);
  ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer  m_ioaiu_vseqr<%=qidx%>;
   <% } 
 qidx++; }
 } %>

  // FUNCTION

 
endclass: concerto_fullsys_sw_crdt_mgr_test


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
function void concerto_fullsys_sw_crdt_mgr_test::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
 if(!(uvm_config_db#(ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=qidx%>[0]" ),.value( m_ioaiu_vseqr<%=qidx%> ) ))) begin
 `uvm_error(get_name(), "Cannot get m_ioaiu_vseqr<%=qidx%>")
 end
  <% } 
 qidx++; }
 } %>
endfunction : end_of_elaboration_phase

task concerto_fullsys_sw_crdt_mgr_test::run_phase (uvm_phase phase); 
  max_iteration = 4;
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
task concerto_fullsys_sw_crdt_mgr_test::main_seq_iter_pre_hook(uvm_phase phase, int iter);
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
task concerto_fullsys_sw_crdt_mgr_test::main_seq_iter_post_hook(uvm_phase phase, int iter);
  
  `uvm_info(get_name(), $sformatf("START HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)
if (iter == 0) begin//check first ieration when  credit are configured by boot sequence 
   <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
  if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
  if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
  check_crdt_done<%=qidx%>(phase);
      <% } 
    qidx++; }
    } %>

end else begin
//#Stimulus.FSYS.v3.4.sw_credit_manager.dynamic
<% if (found_csr_access_ioaiu > 0) { %>
   if(boot_from_ioaiu == 1) begin
        m_concerto_sw_credit_mgr.boot_sw_crdt();
   end
<% } %> 
   <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
  if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
  if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
  check_crdt_done<%=qidx%>(phase);
      <% } 
    qidx++; }
    } %>

  end 
  //clear num of cmd credi and mrd
  m_concerto_sw_credit_mgr.numCmdCCR=0;
  m_concerto_sw_credit_mgr.numMrdCCR=0;

    `ifndef USE_VIP_SNPS 
      `ifdef VCS
      super.main_seq_iter_post_hook(phase,iter); 
      `endif // `ifdef VCS
   `endif // `ifndef USE_VIP_SNPS 

  `uvm_info(get_name(), $sformatf("END HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)

endtask:main_seq_iter_post_hook

////////////////////////////////////////////////////////////
////////////   HOOK END RUN PHASE       ///////////////
task concerto_fullsys_sw_crdt_mgr_test::main_seq_hook_end_run_phase(uvm_phase phase);
  phase.raise_objection(this, "main_seq_hook_end_run_phase");
  `uvm_info(get_name(), "HOOK main_seq_hook_end_run_phase", UVM_NONE)
   

  `uvm_info(get_name(), "end of HOOK main_seq_hook_end_run_phase, ", UVM_NONE)
   phase.drop_objection(this, "main_seq_hook_end_run_phase");

endtask:main_seq_hook_end_run_phase

////////////////////////////////////////////////////////////
///////////// check all credit are done     ///////////////
 <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
task concerto_fullsys_sw_crdt_mgr_test::check_crdt_done<%=qidx%>(uvm_phase phase);

bit [31:0] data;
bit [2:0] DCECounterState[int];
bit [2:0] DMICounterState[int];
bit [2:0] DIICounterState[int];
string temp_string="";
uvm_reg_data_t fieldVal;
int rpn;
int cnt_crdt_done;
int cnt_check_time;//counter for time consumed for read reg 
bit crdt_done;

ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;	

numCmdCCR= m_concerto_sw_credit_mgr.numCmdCCR;


//phase.raise_objection(this, "START HOOK main_seq_iter_post_hook iter check_crdt_done<%=qidx%>");
//`uvm_info(get_name(), "HOOK START HOOK main_seq_iter_post_hook iter check_crdt_done<%=qidx%>", UVM_NONE)
    crdt_done=0;
 do begin
    rpn = 0; //chi_rpn;
    for(int i=0; i<<%=numAiuRpns%>; i++) begin
      addr = addr_trans_mgr_pkg::addrMgrConst::NRS_REGION_BASE ;
      for(int x=0;x<numCmdCCR;x++) begin
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUCCR0.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu>0){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUCCR0.get_offset()<%}%>;
        addr[11:0] = addr[11:0] + (x*4);
        read_csr<%=qidx%>(ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t'(addr),data);
         DCECounterState[x] = data[7:5];
         DMICounterState[x] = data[15:13];
         DIICounterState[x] = data[23:21];
        `uvm_info("concerto_fullsys_sw_crdt_mgr_test", $sformatf("Reading rpn %0d Reg AIUCCR-%0d ADDR 0x%0h DATA 0x%0h",rpn, i, addr, data), UVM_LOW)
        `uvm_info("concerto_fullsys_sw_crdt_mgr_test", $sformatf("DCECounterState[%0d] = %0d",x,DCECounterState[x]), UVM_LOW)
        `uvm_info("concerto_fullsys_sw_crdt_mgr_test", $sformatf("DMICounterState[%0d] = %0d",x,DMICounterState[x]), UVM_LOW)
        `uvm_info("concerto_fullsys_sw_crdt_mgr_test", $sformatf("DIICounterState[%0d] = %0d",x,DIICounterState[x]), UVM_LOW)
        //#Check.FSYS.RDCCRstate.neverreach_reserved
        if($test$plusargs("check_illegale_cntstate")) begin
            if((DCECounterState[x] == 5 || DCECounterState[x] == 6) && (DMICounterState[x] == 5 || DMICounterState[x] == 6) && (DIICounterState[x] == 5 || DIICounterState[x] == 6)) begin
                `uvm_error("check_crdt_done<%=qidx%>",$sformatf("illegale value of counterstate on one of above  Reg filed of  AIUCCR-%0d ADDR 0x%0h DATA 0x%0h", i, addr, data))
            end
        end
        if((DCECounterState[x] == 4 || DCECounterState[x] == 1) && (DMICounterState[x] == 4 || DMICounterState[x] == 1) && (DIICounterState[x] == 4 || DIICounterState[x] == 1)) begin
            `uvm_info("check_crdt_done<%=qidx%>",$sformatf(" cnt_crdt_done = %0d numCmdCCR = %0d ",cnt_crdt_done,numCmdCCR), UVM_NONE)
            cnt_crdt_done++;
        end
        
      end
      if (cnt_crdt_done >= numCmdCCR) begin
            crdt_done=1;
            cnt_crdt_done =0;
            `uvm_info(get_name(), "end of HOOK  main_seq_iter_post_hook iter check_crdt_done<%=qidx%>", UVM_NONE) 
            break;
        end
      rpn++;
    end // for (int i=0; i<nAIUs; i++)
     if (crdt_done==1) begin
         crdt_done=0;
         break;
     end
 end while(crdt_done != 0);

endtask:check_crdt_done<%=qidx%>

task concerto_fullsys_sw_crdt_mgr_test::read_csr<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, output bit[31:0] data);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_rdnosnp_seq m_iordnosnp_seq<%=qidx%>;
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] rdata;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_rresp_t rresp;
    int addr_mask;
    int addr_offset;
										
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;

    m_iordnosnp_seq<%=qidx%>   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_rdnosnp_seq::type_id::create("m_iordnosnp_seq_csr_<%=obj.BlockId%>");
    m_iordnosnp_seq<%=qidx%>.m_addr = addr;
    m_iordnosnp_seq<%=qidx%>.start(m_ioaiu_vseqr<%=qidx%>);
   
    rdata = (m_iordnosnp_seq<%=qidx%>.m_seq_item.m_has_data) ? m_iordnosnp_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rdata[0] : 0;
    data = rdata[(addr_offset*8)+:32];
    rresp =  (m_iordnosnp_seq<%=qidx%>.m_seq_item.m_has_data) ? m_iordnosnp_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rresp : 0;
    if(rresp) begin
        `uvm_error("READ_CSR",$sformatf("Resp_err :0x%0h on Read Data",rresp))
    end
endtask : read_csr<%=qidx%>
   <% } 
 qidx++; }
 } %>

//task concerto_fullsys_sw_crdt_mgr_test::post_shutdown_phase(uvm_phase phase);
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
