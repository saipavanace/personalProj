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
    if(obj.DutInfo.nNativeInterfacePorts > 1) {
        return 'm_regs.'+obj.DutInfo.strRtlNamePrefix+'_0.'+regName;
    } else {
        return 'm_regs.'+obj.DutInfo.strRtlNamePrefix+'.'+regName;
    }
}%>
  import ncore_config_pkg::*;
import addr_trans_mgr_pkg::*;
`uvm_analysis_imp_decl(_dii0_rx0_analysis_smi)

class concerto_dii_backpressure_test extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_dii_backpressure_test)
  <% if(DiiInfo.length>0) { %>
  virtual dii0_axi_if       m_dii0_axi_vif;
  int dii0_rx_cmdreq_counter;
  int stall_dii0_native_if_till_num_cmdreq_collected=<%=DiiInfo[0].nCMDSkidBufSize%> - <%=ChiaiuInfo.length%>;
  uvm_analysis_imp_dii0_rx0_analysis_smi #(dii0_smi_agent_pkg::smi_seq_item, concerto_dii_backpressure_test) m_dii0_rx0_analysis_smi;
  <% } %>


  int main_seq_iter=1;
  static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();
  
  function new(string name = "concerto_dii_backpressure_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  // UVM PHASE
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);
  extern task run_phase (uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void build_phase(uvm_phase phase);

  // FUNCTION
  task main_seq_pre_hook(uvm_phase phase);
      `uvm_info("concerto_dii_backpressure_test", "START main_seq_pre_hook", UVM_LOW)
  if((test_cfg.chi_num_trans==0) && (test_cfg.ioaiu_num_trans==0)) begin // default mode with num_trans=0 -> Don't run      
      return;
  end  
  <% if(DiiInfo.length>0) { %>
  fork
  begin
      m_dii0_axi_vif.en_aw_stall = 1;
      m_dii0_axi_vif.en_w_stall  = 1;
      m_dii0_axi_vif.en_b_stall  = 1;
      m_dii0_axi_vif.en_ar_stall = 1;
      m_dii0_axi_vif.en_r_stall  = 1;
      m_dii0_axi_vif.stall_r_chnl_till_en_r_stall_deassrt = 1;
      m_dii0_axi_vif.stall_ar_chnl_till_en_ar_stall_deassrt = 1;
      m_dii0_axi_vif.stall_aw_chnl_till_en_aw_stall_deassrt = 1;
      m_dii0_axi_vif.stall_w_chnl_till_en_w_stall_deassrt = 1;
      m_dii0_axi_vif.stall_b_chnl_till_en_b_stall_deassrt = 1;
      //wait(dii0_rx_cmdreq_counter>=<%=DiiInfo[0].cmpInfo.nNcCmdInFlightToDii%>);
      wait(dii0_rx_cmdreq_counter>=stall_dii0_native_if_till_num_cmdreq_collected);
      `uvm_info("concerto_dii_backpressure_test", "Unblocking dii0 native i/f", UVM_LOW)
      m_dii0_axi_vif.stall_r_chnl_till_en_r_stall_deassrt = 0;
      m_dii0_axi_vif.stall_ar_chnl_till_en_ar_stall_deassrt = 0;
      m_dii0_axi_vif.stall_aw_chnl_till_en_aw_stall_deassrt = 0;
      m_dii0_axi_vif.stall_w_chnl_till_en_w_stall_deassrt = 0;
      m_dii0_axi_vif.stall_b_chnl_till_en_b_stall_deassrt = 0;
      m_dii0_axi_vif.en_aw_stall = 0;
      m_dii0_axi_vif.en_w_stall  = 0;
      m_dii0_axi_vif.en_b_stall  = 0;
      m_dii0_axi_vif.en_ar_stall = 0;
      m_dii0_axi_vif.en_r_stall  = 0;
  end
  join_none
  <% } %>

  endtask

  <% if(DiiInfo.length>0) { %>
  function void write_dii0_rx0_analysis_smi(dii0_smi_agent_pkg::smi_seq_item msg_in);
        dii0_smi_agent_pkg::smi_seq_item msg;
        msg_in.unpack_smi_seq_item();

        `uvm_info("concerto_dii_backpressure_test", $sformatf("DII0 got new smi msg: %p: cmd=%p unq_id=%p rsp_unq_id=%p dii0_rx_cmdreq_counter=%0d",
                                             msg_in.convert2string(), msg_in.smi_msg_type, msg_in.smi_unq_identifier, msg_in.smi_rsp_unq_identifier,dii0_rx_cmdreq_counter), UVM_LOW)

        //clean copy of packet to keep in the dii_txn
        msg = new();
        msg.copy(msg_in);
        if (msg.smi_msg_type inside {dii0_smi_agent_pkg::CMD_RD_NC, dii0_smi_agent_pkg::CMD_WR_NC_PTL, dii0_smi_agent_pkg::CMD_WR_NC_FULL, dii0_smi_agent_pkg::CMD_CLN_SH_PER, dii0_smi_agent_pkg::CMD_CLN_INV, dii0_smi_agent_pkg::CMD_MK_INV, dii0_smi_agent_pkg::CMD_CLN_VLD}) begin
            dii0_rx_cmdreq_counter = dii0_rx_cmdreq_counter+1; 
        end
        msg = null;
  endfunction:write_dii0_rx0_analysis_smi
  <% } %>
 
endclass: concerto_dii_backpressure_test


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

function void concerto_dii_backpressure_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
  <% if(DiiInfo.length>0) { %>
    m_dii0_rx0_analysis_smi = new ("m_dii0_rx0_analysis_smi", this);
    if(!$test$plusargs("dont_override_stall_count_plusarg")) begin
        if (!$value$plusargs("stall_dii0_native_if_till_num_cmdreq_collected=%d",stall_dii0_native_if_till_num_cmdreq_collected)) begin
            stall_dii0_native_if_till_num_cmdreq_collected = <%=DiiInfo[0].nCMDSkidBufSize%>- <%=ChiaiuInfo.length%>;
        end
    end
    //if ($test$plusargs("read_test")) begin
    //    stall_dii0_native_if_till_num_cmdreq_collected = stall_dii0_native_if_till_num_cmdreq_collected - <%=ChiaiuInfo.length%>; 
    //end

  <% } %>
endfunction:build_phase

function void concerto_dii_backpressure_test::end_of_elaboration_phase (uvm_phase phase);
  super.end_of_elaboration_phase(phase);
    main_seq_iter = test_cfg.test_main_seq_iter;
endfunction:end_of_elaboration_phase

function void concerto_dii_backpressure_test::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  <% if(DiiInfo.length>0) { %>
    if(!uvm_config_db #(virtual dii0_axi_if)::get(this, "", "m_dii0_axi_slv_if", m_dii0_axi_vif)) begin
        `uvm_error(get_full_name(), $sformatf("Cannot find m_dii0_axi_slv_if in config db")); 
    end
    m_concerto_env.inhouse.m_dii0_env.m_smi_agent.m_smi0_tx_monitor.smi_ap.connect(m_dii0_rx0_analysis_smi);
  <% } %>
endfunction:connect_phase

task concerto_dii_backpressure_test::run_phase (uvm_phase phase); 
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


////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////
