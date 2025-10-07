<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var pidx = 0;
   var ridx = 0;
   var chiaiu_idx = 0;
   var axiaiu_idx = 0;
   var aceaiu_idx = 0;
   var aceliteeaiu_idx = 0;
   var ioaiu_idx = 0;
   var initiatorAgents = obj.AiuInfo.length ;
   var nGPRA = 0;
   var nDII = 0;
   var nDMI = 0;
   var nAXI = 0;
   var nACE = 0;
   var nACELITE = 0;
   var nCHI = 0;
   var nINIT = 0;
   var nAIU = 0;
   var cnt_multi = 200*(obj.AiuInfo.length+obj.DceInfo.length+obj.DmiInfo.length+obj.DveInfo.length+obj.DiiInfo.length); 


   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
       _child_blk[pidx]   = 'chiaiu';
       chiaiu_idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
       _child_blk[pidx]   = 'ioaiu';
       ioaiu_idx+= obj.AiuInfo[pidx].nNativeInterfacePorts;
       }
       if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4'|| obj.AiuInfo[pidx].fnNativeInterface == 'AXI5' )) {
         axiaiu_idx+= obj.AiuInfo[pidx].nNativeInterfacePorts;
       } else if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')){
         aceliteeaiu_idx+= obj.AiuInfo[pidx].nNativeInterfacePorts;
       } else if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' )){
         aceaiu_idx+= obj.AiuInfo[pidx].nNativeInterfacePorts;
       }
   }
   nINIT = chiaiu_idx + ioaiu_idx;

   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
   }
   nGPRA = obj.AiuInfo[0].nGPRA;
   nDII = obj.nDIIs;
   nDMI = obj.nDMIs;
   nACE = 0;
   nAIU = obj.nAIUs;
%>
//chiaiu_idx = <%=chiaiu_idx%>
//nGPRA = <%=nGPRA%>
//nDII = <%=nDII%>
//   nAXI = <%=axiaiu_idx%>
//   nACE = <%=aceaiu_idx%>
//   nACELITE = <%=aceliteeaiu_idx%>
//   nCHI = <%=chiaiu_idx%>
//   nINIT = <%=nINIT%>
//--------------------------------------------------------
// Test : ncore_sys_test
//---------------------------------------------------------

class ncore_sys_test extends ncore_base_test;
  /** UVM Component Utility macro */
  `uvm_component_utils(ncore_sys_test)
  bit [1023:0]   data1,data2,data3,data4;
  uvm_status_e status;
  ncore_base_vseq m_base_vseq;

  int NUM_GPRA = <%=nGPRA%>;
  int NUM_INIT = <%=nINIT%>;
  int i,j;
  int delay = 1000;
  int seq_len = 1;
  
  // Addr domain queue
  addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t csrq[$];

  function new (string name="ncore_sys_test", uvm_component parent);
    super.new (name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info("ncore_sys_test", "is entered", UVM_LOW)

    // Create the sequence class
     m_base_vseq = ncore_base_vseq::type_id::create("ncore_base_vseq",,get_full_name());

    `uvm_info("ncore_sys_test", "build - is exited", UVM_LOW)
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase); 
    phase.raise_objection(this);
    this.csrq = addr_trans_mgr_pkg::addrMgrConst::get_all_gpra();
    m_base_vseq.csrq  = this.csrq;
    m_base_vseq.model = env.regmodel;
    #1us;
    m_base_vseq.start(null);
    phase.drop_objection(this);
  endtask : run_phase
endclass : ncore_sys_test
