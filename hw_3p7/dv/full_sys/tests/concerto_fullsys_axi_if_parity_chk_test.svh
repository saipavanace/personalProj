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
let computedAxiInt;

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
`ifdef USE_VIP_SNPS
`ifdef IO_UNITS_CNT_NON_ZERO
import addr_trans_mgr_pkg::*;

<% var hier_path_dut = 'tb_top.dut'; %>
typedef class ioaiu_svt_master_modify_computed_parity_value_cb;
class concerto_fullsys_axi_if_parity_chk_test extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_axi_if_parity_chk_test)
   string native_if_type="";
   string ioaiu_unit ="";
   io_subsys_axi_master_transaction io_master_xact; // to access static variable for interface parity injection control
   io_subsys_ace_master_snoop_transaction io_snoop_xact; // to access static variable for interface parity injection control
   int expected_ErrInfo;
   string inject_parity_err_aw_chnl,inject_parity_err_ar_chnl,inject_parity_err_w_chnl,inject_parity_err_cr_chnl,inject_parity_err_cd_chnl;
   string cb_inject_parity_err_aw_chnl,cb_inject_parity_err_ar_chnl,cb_inject_parity_err_w_chnl,cb_inject_parity_err_r_chnl,cb_inject_parity_err_b_chnl,cb_inject_parity_err_cr_chnl,cb_inject_parity_err_cd_chnl,cb_inject_parity_err_ac_chnl,cb_inject_parity_err_rack,cb_inject_parity_err_wack;
   uvm_event mission_fault_detected;
   bit configure_ioaiu_mstr_seqs_override_num_txns_from_test;
   int configure_ioaiu_mstr_seqs_num_txns;
   ioaiu_svt_master_modify_computed_parity_value_cb cb1;

  int max_iteration=2;
  static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();
  //static uvm_event fsc_test_done = ev_pool.get("fsc_test_done");
  //bit block_fsys_fsc_main_task=1;
  
  function new(string name = "concerto_fullsys_axi_if_parity_chk_test", uvm_component parent=null);
    super.new(name,parent);
    void'($value$plusargs("native_if_type=%0s",native_if_type));
    void'($value$plusargs("ioaiu_unit=%0s",ioaiu_unit));
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     <% if(obj.useResiliency == 1) { %>
    mission_fault_detected = new("mission_fault_detected");
    if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                    .inst_name(""),
                                    .field_name( "mission_fault_detected" ),
                                    .value( mission_fault_detected ))) begin
       `uvm_error("Fsc test", "Event mission_fault_detected is not found")
    end
     <% } %>
    if(!$value$plusargs("max_iteration=%0d",max_iteration)) begin
        max_iteration=2;
    end
  endfunction  

  virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      cb1 = new("ioaiu_svt_master_modify_computed_parity_value_cb");
          <% for(var pidx = 0; pidx < obj.IoaiuInfo.length; pidx++) { %>
          <%if(Array.isArray(obj.IoaiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.IoaiuInfo[pidx].interfaces.axiInt[0];
          }else{
               computedAxiInt = obj.IoaiuInfo[pidx].interfaces.axiInt;
          }%>
          <% if(((obj.IoaiuInfo[pidx].fnNativeInterface=="AXI5") || (obj.IoaiuInfo[pidx].fnNativeInterface=="ACELITE-E") ||(obj.IoaiuInfo[pidx].fnNativeInterface=="ACE5"))&& (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) { %>
      if(ioaiu_unit=="<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>")
        uvm_callbacks#(svt_amba_uvm_pkg::svt_axi_master, svt_amba_uvm_pkg::svt_axi_master_callback)::add(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.IoaiuInfo[pidx].nUnitId%> - <%=obj.ChiaiuInfo.length%>].driver,cb1);
          <% } %>
          <% } %>
      uvm_config_db#(svt_amba_uvm_pkg::svt_axi_master_callback)::set(this, "*", "cb1", cb1);
  endfunction : connect_phase


  // UVM PHASE
  extern task run_phase (uvm_phase phase);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// These hashtags are for normal stimulus driven from synopsys vip wrt interface parity check feature (checkType==ODD_PARITY_BYTE_ALL). 
// And fsys configuration hw_cfg_ncore37_with_if_parity_chk is utilised to verify all below cases in random tests with label=if_parity_chk_cfg_random_stimul). 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#Stimulus.FSYS.v371.if_parity_chk.AXI5
//#Stimulus.FSYS.v371.if_parity_chk.AXI5_with_async_adapter
//#Stimulus.FSYS.v371.if_parity_chk.ACE5
//#Stimulus.FSYS.v371.if_parity_chk.ACE5_with_async_adapter
//#Stimulus.FSYS.v371.if_parity_chk.ACE5-LiteDVM
//
//#Cover.FSYS.v371.if_parity_chk.AXI5
//#Cover.FSYS.v371.if_parity_chk.AXI5_with_async_adapter
//#Cover.FSYS.v371.if_parity_chk.ACE5
//#Cover.FSYS.v371.if_parity_chk.ACE5_with_async_adapter
//#Cover.FSYS.v371.if_parity_chk.ACE5-LiteDVM
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// These hashtags are for error case of interface parity check feature (checkType==ODD_PARITY_BYTE_ALL)
// And fsys configuration hw_cfg_ncore37_with_if_parity_chk is utilised to verify all below cases with label=. 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// #Stimulus.FSYS.v371.if_parity_chk_err.AXI5
// #Stimulus.FSYS.v371.if_parity_chk_err.AXI5_with_async_adapter
// #Stimulus.FSYS.v371.if_parity_chk_err.ACE5
// #Stimulus.FSYS.v371.if_parity_chk_err.ACE5_with_async_adapter
// #Stimulus.FSYS.v371.if_parity_chk_err.ACE5-LiteDVM
//
// #Cover.FSYS.v371.if_parity_chk_err.AXI5
// #Cover.FSYS.v371.if_parity_chk_err.AXI5_with_async_adapter
// #Cover.FSYS.v371.if_parity_chk_err.ACE5
// #Cover.FSYS.v371.if_parity_chk_err.ACE5_with_async_adapter
// #Cover.FSYS.v371.if_parity_chk_err.ACE5LiteDVM
  // FUNCTION
  task main_seq_iter_pre_hook(uvm_phase phase, int iter);
      bit[31:0]  read_data;
      bit[31:0]  write_data;
      uvm_status_e   status;

                  `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Iter-%0d main_seq_iter_pre_hook STARTS. ioaiu_unit %0s native_if_type %0s",iter,ioaiu_unit,native_if_type), UVM_LOW)
          //verify error reporting through interrupt, registers & fault
          //Set IntfCheckErrDetEn & IntfCheckErrIntEn
          <% for(var pidx = 0; pidx < obj.IoaiuInfo.length; pidx++) { %>
          <%if(Array.isArray(obj.IoaiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.IoaiuInfo[pidx].interfaces.axiInt[0];
          }else{
               computedAxiInt = obj.IoaiuInfo[pidx].interfaces.axiInt;
          }%>
          <% if(((obj.IoaiuInfo[pidx].fnNativeInterface=="AXI5") || (obj.IoaiuInfo[pidx].fnNativeInterface=="ACELITE-E") ||(obj.IoaiuInfo[pidx].fnNativeInterface=="ACE5"))&& (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) { %>
              if((ioaiu_unit=="<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>") && (native_if_type=="<%=obj.IoaiuInfo[pidx].fnNativeInterface%>")) begin : _reg_cfg_ioaiu_unit_<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>
                if(iter<1) begin : _set_IntfCheckErrDetEn_IntfCheckErrIntEn_
                  configure_ioaiu_mstr_seqs_override_num_txns_from_test = 1;
                  configure_ioaiu_mstr_seqs_num_txns = 2;
                  configure_ioaiu_mstr_seqs();
                  m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUEDR").read(status, read_data);
                  `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Reading <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUEDR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUEDR").get_address(),read_data), UVM_LOW)
                  write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUEDR.IntfCheckErrDetEn.get_lsb_pos());
                  m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUEDR").write(status, write_data);
                  `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Writing <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUEDR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUEDR").get_address(),write_data), UVM_LOW)

                  m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUEIR").read(status, read_data);
                  `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Reading <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUEIR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUEIR").get_address(),read_data), UVM_LOW)
                  write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUEIR.IntfCheckErrIntEn.get_lsb_pos());
                  m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUEIR").write(status, write_data);
                  `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Writing <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUEIR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUEIR").get_address(),write_data), UVM_LOW)
                   io_master_xact.io_subsys_axi_dis_inject_intf_parity_err[<%=obj.IoaiuInfo[pidx].nUnitId%> - <%=obj.ChiaiuInfo.length%>] = 0;
                   io_snoop_xact.io_subsys_axi_dis_inject_intf_parity_err[<%=obj.IoaiuInfo[pidx].nUnitId%> - <%=obj.ChiaiuInfo.length%>] = 0;
                   cb1.io_subsys_axi_dis_inject_intf_parity_err = 0;
                end : _set_IntfCheckErrDetEn_IntfCheckErrIntEn_
                else begin
                  configure_ioaiu_mstr_seqs_override_num_txns_from_test = 0;
                  configure_ioaiu_mstr_seqs();
                end
              end : _reg_cfg_ioaiu_unit_<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>
          <% } %>
          <% } %>

      fork : _verify_error_fork_
      begin
          <% for(var pidx = 0; pidx < obj.IoaiuInfo.length; pidx++) { %>
          <%if(Array.isArray(obj.IoaiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.IoaiuInfo[pidx].interfaces.axiInt[0];
          }else{
               computedAxiInt = obj.IoaiuInfo[pidx].interfaces.axiInt;
          }%>
          <% if(((obj.IoaiuInfo[pidx].fnNativeInterface=="AXI5") || (obj.IoaiuInfo[pidx].fnNativeInterface=="ACELITE-E") ||(obj.IoaiuInfo[pidx].fnNativeInterface=="ACE5"))&& (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) { %>
              if((ioaiu_unit=="<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>") && (native_if_type=="<%=obj.IoaiuInfo[pidx].fnNativeInterface%>") && ($test$plusargs("verify_interrupt_resiliency"))) begin : _verify_error_ioaiu_unit_<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>
                if(iter<1) begin : _verify_error_if_
                  // Wait for interrupt to go high after error injection
                  phase.raise_objection(this, "main_seq_iter_pre_hook_run_phase");
                  wait((io_master_xact.io_subsys_axi_intf_parity_err_count[<%=obj.IoaiuInfo[pidx].nUnitId%> - <%=obj.ChiaiuInfo.length%>]>0) || (cb1.io_subsys_axi_intf_parity_err_count>0) || (io_snoop_xact.io_subsys_axi_intf_parity_err_count[<%=obj.IoaiuInfo[pidx].nUnitId%> - <%=obj.ChiaiuInfo.length%>]>0));
                  if(io_master_xact.io_subsys_axi_intf_parity_err_count[<%=obj.IoaiuInfo[pidx].nUnitId%> - <%=obj.ChiaiuInfo.length%>]>0)
                      io_master_xact.io_subsys_axi_dis_inject_intf_parity_err[<%=obj.IoaiuInfo[pidx].nUnitId%> - <%=obj.ChiaiuInfo.length%>] = 1;
                  if(io_snoop_xact.io_subsys_axi_intf_parity_err_count[<%=obj.IoaiuInfo[pidx].nUnitId%> - <%=obj.ChiaiuInfo.length%>]>0)
                      io_snoop_xact.io_subsys_axi_dis_inject_intf_parity_err[<%=obj.IoaiuInfo[pidx].nUnitId%> - <%=obj.ChiaiuInfo.length%>] = 1;
                  if(cb1.io_subsys_axi_intf_parity_err_count>0)
                      cb1.io_subsys_axi_dis_inject_intf_parity_err = 1;

                  `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Waiting for Interrupt signal - <%=hier_path_dut%>.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_irq_uc to go high"), UVM_LOW)
                 if(!$test$plusargs("axi5_parity_chk_conc17350")) begin : _ignore_intr_and_error_logging_<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_
//#Cover.FSYS.v371.if_parity_chk_err.interrupt
                  wait(<%=hier_path_dut%>.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_irq_uc==1);
                  $value$plusargs("inject_parity_err_ar_chnl=%0s",inject_parity_err_ar_chnl);
                  $value$plusargs("cb_inject_parity_err_ar_chnl=%0s",cb_inject_parity_err_ar_chnl);

                  $value$plusargs("inject_parity_err_aw_chnl=%0s",inject_parity_err_aw_chnl);
                  $value$plusargs("cb_inject_parity_err_aw_chnl=%0s",cb_inject_parity_err_aw_chnl);

                  $value$plusargs("inject_parity_err_w_chnl=%0s",inject_parity_err_w_chnl);
                  $value$plusargs("cb_inject_parity_err_w_chnl=%0s",cb_inject_parity_err_w_chnl);

                  $value$plusargs("cb_inject_parity_err_r_chnl=%0s",cb_inject_parity_err_r_chnl);

                  $value$plusargs("cb_inject_parity_err_b_chnl=%0s",cb_inject_parity_err_b_chnl);

                  $value$plusargs("inject_parity_err_cr_chnl=%0s",inject_parity_err_cr_chnl);
                  $value$plusargs("cb_inject_parity_err_cr_chnl=%0s",cb_inject_parity_err_cr_chnl);

                  $value$plusargs("inject_parity_err_cd_chnl=%0s",inject_parity_err_cd_chnl);
                  $value$plusargs("cb_inject_parity_err_cd_chnl=%0s",cb_inject_parity_err_cd_chnl);

                  $value$plusargs("cb_inject_parity_err_ac_chnl=%0s",cb_inject_parity_err_ac_chnl);

                  $value$plusargs("cb_inject_parity_err_rack=%0s",cb_inject_parity_err_rack);

                  $value$plusargs("cb_inject_parity_err_wack=%0s",cb_inject_parity_err_wack);

                  //b00000 = AR Channel
                  //b00001 = AW Channel
                  //b00010 = W Channel
                  //b00011 = R Channel
                  //b00100 = B Channel
                  //b00101 = CR Channel
                  //b00110 = CD Channel
                  //b00111 = AC Channel
                  //b01000 = RACK
                  //b01001 = WACK

                  if(inject_parity_err_ar_chnl!= "" || cb_inject_parity_err_ar_chnl!= "")begin
                      expected_ErrInfo = 0;
                  end
                  else if(inject_parity_err_aw_chnl!= "" || cb_inject_parity_err_aw_chnl!= "")begin
                      expected_ErrInfo = 1;
                  end
                  else if(inject_parity_err_w_chnl!= "" || cb_inject_parity_err_w_chnl!="")begin
                      expected_ErrInfo = 2;
                  end
                  else if(cb_inject_parity_err_r_chnl!="")begin
                      expected_ErrInfo = 3;
                  end
                  else if(cb_inject_parity_err_b_chnl!="")begin
                      expected_ErrInfo = 4;
                  end
                  else if(inject_parity_err_cr_chnl!= "" || cb_inject_parity_err_cr_chnl!= "")begin
                      expected_ErrInfo = 5;
                  end
                  else if(inject_parity_err_cd_chnl!= "" || cb_inject_parity_err_cd_chnl!= "")begin
                      expected_ErrInfo = 6;
                  end
                  else if(cb_inject_parity_err_ac_chnl!="")begin
                      expected_ErrInfo = 7;
                  end
                  else if(cb_inject_parity_err_rack!="")begin
                      expected_ErrInfo = 8;
                  end
                  else if(cb_inject_parity_err_wack!="")begin
                      expected_ErrInfo = 9;
                  end

                  // Clear the interrupt
                  // XAIUUESR.ErrVld
                  m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").read(status, read_data);
                  `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Reading <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data), UVM_LOW)
                  // Check ErrVld, ErrType & ErrInfo 
                  // #Cover.FSYS.v371.if_parity_chk_err.XAIUUESR.ErrVld 
                  // #Cover.FSYS.v371.if_parity_chk_err.XAIUUESR.ErrInfo
                  // #Cover.FSYS.v371.if_parity_chk_err.XAIUUESR.ErrType
                  if(read_data[0]==1) begin
                      `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Expected <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUESR[ADDR 0x%0h] ErrVld 0x%0h value",m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data[0]), UVM_LOW)
                  end else begin
                      `uvm_error("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Unexpected <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUESR[ADDR 0x%0h] ErrVld 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data[0],1))
                  end

                  if(read_data[31:12]==expected_ErrInfo) begin
                      `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Expected <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUESR[ADDR 0x%0h] ErrInfo 0x%0h value",m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data[31:12]), UVM_LOW)
                  end else begin
                      `uvm_error("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Unexpected <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUESR[ADDR 0x%0h] ErrInfo 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data[31:12],expected_ErrInfo))
                  end
                  if(read_data[7:4]=='hD) begin
                      `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Expected <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUESR[ADDR 0x%0h] ErrType 0x%0h value",m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data[7:4]), UVM_LOW)
                  end else begin
                      `uvm_error("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Unexpected <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUESR[ADDR 0x%0h] ErrType 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data[7:4],'hD))
                  end

                  write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUESR.ErrVld.get_lsb_pos());
                  m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").write(status, write_data);
                  `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Writing <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),write_data), UVM_LOW)

                  m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").read(status, read_data);
                  `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Reading <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data), UVM_LOW)

//#Cover.FSYS.v371.if_parity_chk_err.interrupt
                  fork : wait_for_<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_irq_uce_to_go_low
                  begin
                      wait(<%=hier_path_dut%>.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_irq_uc==0);
                  end

                  begin
                      #1000ns;
                  end
                  join_any : wait_for_<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_irq_uce_to_go_low

                  disable  wait_for_<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_irq_uce_to_go_low;
                  if(<%=hier_path_dut%>.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_irq_uc==0) begin
                      `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_irq_uc is cleared after writing to <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUESR.ErrVld"), UVM_LOW)
                  end else begin
                    if($test$plusargs("if_parity_chk_test_bypass_intr_chk")) 
                      `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_irq_uc is not cleared after writing to <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUESR.ErrVld"),UVM_NONE)
                    else 
                      `uvm_error("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_irq_uc is not cleared after writing to <%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>.XAIUUESR.ErrVld"))
                  end

     <% if(obj.useResiliency == 1) { %>
                  `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Waiting for Event mission_fault_detected to be triggered"), UVM_LOW);
//#Cover.FSYS.v371.if_parity_chk_err.mission_fault
                   if(mission_fault_detected.is_off()) 
                       mission_fault_detected.wait_trigger();
                  `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Event mission_fault_detected"), UVM_LOW);
                  if(!$test$plusargs("if_parity_chk_test_bypass_bist_seq")) 
                      conc_fsc_tsk.run_bist_seq($urandom());
     <% } %>
                 end : _ignore_intr_and_error_logging_<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_
                 else begin
                  $value$plusargs("cb_inject_parity_err_ar_chnl=%0s",cb_inject_parity_err_ar_chnl);

                  $value$plusargs("cb_inject_parity_err_aw_chnl=%0s",cb_inject_parity_err_aw_chnl);

                  $value$plusargs("cb_inject_parity_err_w_chnl=%0s",cb_inject_parity_err_w_chnl);

                  $value$plusargs("cb_inject_parity_err_r_chnl=%0s",cb_inject_parity_err_r_chnl);

                  $value$plusargs("cb_inject_parity_err_b_chnl=%0s",cb_inject_parity_err_b_chnl);

                  $value$plusargs("cb_inject_parity_err_cr_chnl=%0s",cb_inject_parity_err_cr_chnl);

                  $value$plusargs("cb_inject_parity_err_cd_chnl=%0s",cb_inject_parity_err_cd_chnl);

                  $value$plusargs("cb_inject_parity_err_ac_chnl=%0s",cb_inject_parity_err_ac_chnl);
// As per CONC-17439:
// #Cover.FSYS.v371.if_parity_chk_err.async_adapter_check                 
                  if(cb_inject_parity_err_aw_chnl!="") begin
                    wait(tb_top.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_async_adapter_err[0]==1);
                  end else if(cb_inject_parity_err_w_chnl!="") begin
                    wait(tb_top.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_async_adapter_err[1]==1);
                  end else if(cb_inject_parity_err_b_chnl!="") begin
                    wait(tb_top.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_async_adapter_err[2]==1);
                  end else if(cb_inject_parity_err_ar_chnl!="") begin
                    wait(tb_top.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_async_adapter_err[3]==1);
                  end else if(cb_inject_parity_err_r_chnl!="") begin
                    wait(tb_top.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_async_adapter_err[4]==1);
                  end else if(cb_inject_parity_err_ac_chnl!="") begin
                    wait(tb_top.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_async_adapter_err[5]==1);
                  end else if(cb_inject_parity_err_cd_chnl!="") begin
                    wait(tb_top.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_async_adapter_err[6]==1);
                  end else if(cb_inject_parity_err_cr_chnl!="") begin
                    wait(tb_top.<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>_async_adapter_err[7]==1);
                  end
                 end
                  phase.drop_objection(this, "main_seq_iter_pre_hook_run_phase");
                end : _verify_error_if_

              end : _verify_error_ioaiu_unit_<%=obj.IoaiuInfo[pidx].strRtlNamePrefix%>
          <% } %>
          <% } %>
              `uvm_info("concerto_fullsys_axi_if_parity_chk_test", $sformatf("Iter-%0d main_seq_iter_pre_hook ENDS",iter), UVM_LOW)
          end
      join_none : _verify_error_fork_

      super.main_seq_iter_pre_hook(phase,iter); 

  endtask

  function void configure_ioaiu_mstr_seqs();
  int seq_id=0;
  foreach(io_subsys_mstr_seq_cfg_a[i]) begin 
      io_subsys_mstr_seq_cfg_a[i] = io_mstr_seq_cfg::type_id::create($psprintf("%0s_%0s_mstr_seq_cfg_p%0d_s%0d", addrMgrConst::io_subsys_nativeif_a[i].tolower(), addrMgrConst::io_subsys_instname_a[i], i,seq_id));
       io_subsys_mstr_seq_cfg_a[i].override_num_txns_from_test = configure_ioaiu_mstr_seqs_override_num_txns_from_test;
       if(configure_ioaiu_mstr_seqs_override_num_txns_from_test)
           io_subsys_mstr_seq_cfg_a[i].num_txns= configure_ioaiu_mstr_seqs_num_txns;
      io_subsys_mstr_seq_cfg_a[i].init_master_info(addrMgrConst::io_subsys_nativeif_a[i].tolower(), addrMgrConst::io_subsys_instname_a[i], addrMgrConst::io_subsys_funitid_a[i]); 
      uvm_config_db #(mstr_seq_cfg)::set(this ,"m_concerto_env.snps.svt.amba_system_env.axi_system[0]*", $sformatf("%0s_%0s_mstr_seq_cfg_p%0d_s%0d", addrMgrConst::io_subsys_nativeif_a[i].tolower(), addrMgrConst::io_subsys_instname_a[i], i,seq_id), io_subsys_mstr_seq_cfg_a[i]);
  end 
        
endfunction:configure_ioaiu_mstr_seqs;

 
endclass: concerto_fullsys_axi_if_parity_chk_test


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


task concerto_fullsys_axi_if_parity_chk_test::run_phase (uvm_phase phase); 
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
class ioaiu_svt_master_modify_computed_parity_value_cb extends svt_amba_uvm_pkg::svt_axi_master_callback;
 
string inject_parity_err_aw_chnl,inject_parity_err_ar_chnl,inject_parity_err_w_chnl,inject_parity_err_b_chnl,inject_parity_err_r_chnl,inject_parity_err_cr_chnl,inject_parity_err_ac_chnl,inject_parity_err_rack,inject_parity_err_wack;
static int io_subsys_axi_intf_parity_err_count;
static bit io_subsys_axi_dis_inject_intf_parity_err=1; // '{{ 4'h0 }}

  function new(string name);
    super.new(name);
  endfunction

  virtual function void modify_computed_parity_value(svt_axi_master axi_master, string signal_context = "", string parity_signal = "",ref bit calculated_parity_signal_val);
  if(io_subsys_axi_dis_inject_intf_parity_err==0) begin : _io_subsys_axi_dis_inject_intf_parity_err_
    /** Sample to update user inject valid_ready parity */
   $value$plusargs("cb_inject_parity_err_aw_chnl=%0s",inject_parity_err_aw_chnl);
   $value$plusargs("cb_inject_parity_err_ar_chnl=%0s",inject_parity_err_ar_chnl);
   $value$plusargs("cb_inject_parity_err_w_chnl=%0s", inject_parity_err_w_chnl);
   $value$plusargs("cb_inject_parity_err_b_chnl=%0s", inject_parity_err_b_chnl);
   $value$plusargs("cb_inject_parity_err_r_chnl=%0s", inject_parity_err_r_chnl);
   $value$plusargs("cb_inject_parity_err_cr_chnl=%0s", inject_parity_err_cr_chnl);
   $value$plusargs("cb_inject_parity_err_ac_chnl=%0s", inject_parity_err_ac_chnl);
   $value$plusargs("cb_inject_parity_err_rack=%0s", inject_parity_err_rack);
   $value$plusargs("cb_inject_parity_err_wack=%0s", inject_parity_err_wack);
   
   if(inject_parity_err_aw_chnl!="") begin
       inject_parity_err_aw_chnl = "AWVALID_CHK";
       `uvm_info(get_full_name(), $psprintf("modify_computed_parity_value.inject_parity_err_aw_chnl %0s",inject_parity_err_aw_chnl), UVM_MEDIUM);
   end
   else if(inject_parity_err_ar_chnl!="") begin
       inject_parity_err_ar_chnl = "ARVALID_CHK";
       `uvm_info(get_full_name(), $psprintf("modify_computed_parity_value.inject_parity_err_ar_chnl %0s",inject_parity_err_ar_chnl), UVM_MEDIUM);
   end
   else if(inject_parity_err_w_chnl!="") begin
       inject_parity_err_w_chnl = "WVALID_CHK";
       `uvm_info(get_full_name(), $psprintf("modify_computed_parity_value.inject_parity_err_w_chnl %0s",inject_parity_err_w_chnl), UVM_MEDIUM);
   end
   else if(inject_parity_err_b_chnl!="") begin
       inject_parity_err_b_chnl = "BREADY_CHK";
       `uvm_info(get_full_name(), $psprintf("modify_computed_parity_value.inject_parity_err_b_chnl %0s",inject_parity_err_b_chnl), UVM_MEDIUM);
   end
   else if(inject_parity_err_r_chnl!="") begin
       inject_parity_err_r_chnl = "RREADY_CHK";
       `uvm_info(get_full_name(), $psprintf("modify_computed_parity_value.inject_parity_err_r_chnl %0s",inject_parity_err_r_chnl), UVM_MEDIUM);
   end
   else if(inject_parity_err_cr_chnl!="") begin
       inject_parity_err_cr_chnl = "CRVALID_CHK";
       `uvm_info(get_full_name(), $psprintf("modify_computed_parity_value.inject_parity_err_cr_chnl %0s",inject_parity_err_cr_chnl), UVM_MEDIUM);
   end
   else if(inject_parity_err_ac_chnl!="") begin
       inject_parity_err_ac_chnl = "ACREADY_CHK";
       `uvm_info(get_full_name(), $psprintf("modify_computed_parity_value.inject_parity_err_ac_chnl %0s",inject_parity_err_ac_chnl), UVM_MEDIUM);
   end
   else if(inject_parity_err_rack!="") begin
       inject_parity_err_rack = "RACK";
       `uvm_info(get_full_name(), $psprintf("modify_computed_parity_value.inject_parity_err_rack %0s",inject_parity_err_rack), UVM_MEDIUM);
   end
   else if(inject_parity_err_wack!="") begin
       inject_parity_err_wack = "WACK";
       `uvm_info(get_full_name(), $psprintf("modify_computed_parity_value.inject_parity_err_wack %0s",inject_parity_err_wack), UVM_MEDIUM);
   end

   if( 
   (inject_parity_err_aw_chnl=="AWVALID_CHK")  ||
   (inject_parity_err_ar_chnl=="ARVALID_CHK")  ||
   (inject_parity_err_w_chnl=="WVALID_CHK") ||
   (inject_parity_err_b_chnl=="BREADY_CHK") ||
   (inject_parity_err_r_chnl=="RREADY_CHK") ||
   (inject_parity_err_cr_chnl=="CRVALID_CHK") ||
   (inject_parity_err_ac_chnl=="ACREADY_CHK") ||
   (inject_parity_err_rack=="RACK") ||
   (inject_parity_err_wack=="WACK") 
   ) begin
   end

    if(parity_signal == "AWVALIDCHK" && inject_parity_err_aw_chnl == "AWVALID_CHK") begin 
      if(signal_context == "ASSERT_AWVALID") begin
        calculated_parity_signal_val = 1;
      end else begin 
        calculated_parity_signal_val = 0;
      end
      io_subsys_axi_intf_parity_err_count = io_subsys_axi_intf_parity_err_count+1;
    end else if(parity_signal == "WVALIDCHK" && inject_parity_err_w_chnl == "WVALID_CHK") begin 
       if(signal_context == "ASSERT_WVALID") begin
        calculated_parity_signal_val = 1;
      end else begin 
        calculated_parity_signal_val = 0;
      end
      io_subsys_axi_intf_parity_err_count = io_subsys_axi_intf_parity_err_count+1;

    end else if(parity_signal == "BREADYCHK" && inject_parity_err_b_chnl == "BREADY_CHK") begin 
      calculated_parity_signal_val = 1;
      io_subsys_axi_intf_parity_err_count = io_subsys_axi_intf_parity_err_count+1;
    end else if(parity_signal == "ARVALIDCHK" && inject_parity_err_ar_chnl == "ARVALID_CHK") begin 
       if(signal_context == "ASSERT_ARVALID") begin
        calculated_parity_signal_val = 1;
      end else begin 
        calculated_parity_signal_val = 0;
      end
      io_subsys_axi_intf_parity_err_count = io_subsys_axi_intf_parity_err_count+1;
    end else if(parity_signal == "RREADYCHK" && inject_parity_err_r_chnl == "RREADY_CHK") begin 
      calculated_parity_signal_val = 1;
      io_subsys_axi_intf_parity_err_count = io_subsys_axi_intf_parity_err_count+1;
    end else if(parity_signal == "CRVALIDCHK" && inject_parity_err_cr_chnl == "CRVALID_CHK") begin 
     if(signal_context == "ASSERT_CRVALID") begin
      calculated_parity_signal_val = 1;
     end else begin
     calculated_parity_signal_val = 0;
     end
      io_subsys_axi_intf_parity_err_count = io_subsys_axi_intf_parity_err_count+1;
   end else if(parity_signal == "CRREADYCHK" && inject_parity_err_cr_chnl == "CRREADY_CHK") begin
     calculated_parity_signal_val = 1;
      io_subsys_axi_intf_parity_err_count = io_subsys_axi_intf_parity_err_count+1;
   end else if(parity_signal == "ACVALIDCHK" && inject_parity_err_ac_chnl == "ACVALID_CHK") begin 
     if(signal_context == "ASSERT_ACVALID") begin
      calculated_parity_signal_val = 1;
     end else begin
     calculated_parity_signal_val = 0;
     end
      io_subsys_axi_intf_parity_err_count = io_subsys_axi_intf_parity_err_count+1;
   end else if(parity_signal == "ACREADYCHK" && inject_parity_err_ac_chnl == "ACREADY_CHK") begin
     calculated_parity_signal_val = 1;
      io_subsys_axi_intf_parity_err_count = io_subsys_axi_intf_parity_err_count+1;
   end else if(parity_signal == "RACKCHK" && inject_parity_err_rack == "RACK") begin
     calculated_parity_signal_val = 1;
      io_subsys_axi_intf_parity_err_count = io_subsys_axi_intf_parity_err_count+1;
   end else if(parity_signal == "WACKCHK" && inject_parity_err_wack == "WACK") begin
     calculated_parity_signal_val = 1;
      io_subsys_axi_intf_parity_err_count = io_subsys_axi_intf_parity_err_count+1;
   end 
   `uvm_info(get_full_name(), $psprintf("modify_computed_parity_value.calculated_parity_signal_val %0d parity_signal=%0s signal_context=%0s",calculated_parity_signal_val,parity_signal,signal_context), UVM_MEDIUM);
  end : _io_subsys_axi_dis_inject_intf_parity_err_

  endfunction

endclass : ioaiu_svt_master_modify_computed_parity_value_cb
`endif 
`endif
