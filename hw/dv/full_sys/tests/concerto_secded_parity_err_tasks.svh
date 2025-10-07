<%
//Embedded javascript code to figure number of blocks
   const _blkid = [];
   const _blkidpkg = [];
   const _blktype = [];
   const _blkports_suffix =[];
   const _blk_nCore = [];
   const _blk   = [{}];
   let pidx = 0;
   let ridx = 0;
   let _idx = 0;
   let chiaiu_idx = 0;
   let ioaiu_idx = 0;
   let ioaiu_mpu_idx = 0;
   let nAIUs_mpu =0; 
   
   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _blk[_idx]   = obj.AiuInfo[pidx];
       _blkid[_idx] = 'chiaiu' + chiaiu_idx +"_0";
       _blkidpkg[_idx] = 'chiaiu' + chiaiu_idx;
       _blktype[_idx]   = 'chiaiu';
       _blk_nCore[pidx] = 1;
       chiaiu_idx++;
       nAIUs_mpu++;
       _idx++;
       } else {
       for (let port_idx = 0; port_idx < obj.AiuInfo[pidx].nNativeInterfacePorts; port_idx++) {
        _blk[_idx]   = obj.AiuInfo[pidx];
        _blkidpkg[_idx] = 'ioaiu' + ioaiu_idx;
        _blkid[_idx] = 'ioaiu' + ioaiu_idx +"_"+port_idx;
        _blkports_suffix[_idx] = "_" + port_idx;
        _blktype[_idx]   = 'ioaiu';
        _blk_nCore[pidx] = obj.AiuInfo[pidx].nNativeInterfacePorts;
         _idx++;
        nAIUs_mpu++;
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
   let nALLs = ridx+1; 
%>
class concerto_secded_parity_err_tasks extends uvm_component; 

  `uvm_component_utils(concerto_secded_parity_err_tasks)
   //set env 
   concerto_test_cfg test_cfg;
   concerto_env_cfg m_concerto_env_cfg;  
   concerto_env     m_concerto_env;
   concerto_register_map_pkg::ral_sys_ncore  m_regs;

    static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();
    static uvm_event csr_init_done = ev_pool.get("csr_init_done");
    <% for(pidx = 0; pidx < obj.nDMIs; pidx++) {if(obj.DmiInfo[pidx].useCmc) { %>
    uvm_event  ev_inject_error_dmi<%=pidx%>_smc = uvm_event_pool::get_global("inject_error_dmi<%=pidx%>_smc");<%}}%>

<% let valid_dmi_test = 0; let valid_ioaiu_test = 0; let ioaiu_test_unitid=0; let valid_dce_test = 0; let dce_test_unitid=0;
if(obj.DmiInfo[0].useCmc && ((obj.DmiInfo[0].ccpParams.TagErrInfo != 'NONE')||(obj.DmiInfo[0].ccpParams.DataErrInfo != 'NONE'))) {
  valid_dmi_test = 1;
}
for(pidx = 0; pidx < obj.nAIUs; pidx++) { 
 if(obj.AiuInfo[pidx].useCache==1 && obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') {
   for( let i=0;i<obj.AiuInfo[pidx].ccpParams.nDataBanks;i++){
     if( obj.AiuInfo[pidx].MemoryGeneration.dataMem[i].fnMemType == 'SRAM'){
       valid_ioaiu_test = 1;
       ioaiu_test_unitid = obj.AiuInfo[pidx].nUnitId;
}}}}
for(pidx = 0; pidx < obj.nDCEs; pidx++) { 
   for( let i=0;i<obj.DceInfo[pidx].SnoopFilterInfo[0].TagMem.length;i++){
     if( obj.DceInfo[pidx].SnoopFilterInfo[0].TagMem[i].fnMemType == 'SRAM'){
       valid_dce_test = 1;
       dce_test_unitid = obj.DceInfo[pidx].nUnitId;
}}}
for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>
<% if(obj.DmiInfo[pidx].useCmc) { %>
   <%for( let i=0;i<obj.DmiInfo[pidx].ccpParams.nTagBanks;i++){%>
   <% } %>
   <%for( let i=0;i<obj.DmiInfo[pidx].ccpParams.nDataBanks;i++){%>
    static uvm_event         dmi_injectSingleErrData_<%=pidx%>_<%=i%> = ev_pool.get("dmi_injectSingleErrData_<%=pidx%>_<%=i%>");
    static uvm_event         dmi_injectDoubleErrData_<%=pidx%>_<%=i%> = ev_pool.get("dmi_injectDoubleErrData_<%=pidx%>_<%=i%>");
   <% } %>
<% } } %>

<% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
<% if(obj.AiuInfo[pidx].useCache==1 && obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') { %>
   <%for( let i=0;i<obj.AiuInfo[pidx].ccpParams.nDataBanks;i++){%>
   <%if( obj.AiuInfo[pidx].MemoryGeneration.dataMem[i].fnMemType == 'SRAM'){%>
    static uvm_event         ioaiu_injectSingleErrData_<%=pidx%>_<%=i%> = ev_pool.get("ioaiu_injectSingleErrData_<%=pidx%>_<%=i%>");
    static uvm_event         ioaiu_injectDoubleErrData_<%=pidx%>_<%=i%> = ev_pool.get("ioaiu_injectDoubleErrData_<%=pidx%>_<%=i%>");
   <% } } %>
<% } } %>

<% for(pidx = 0; pidx < obj.nDCEs; pidx++) { 
   for( let i=0;i<obj.DceInfo[pidx].SnoopFilterInfo[0].TagMem.length;i++){
     if( obj.DceInfo[pidx].SnoopFilterInfo[0].TagMem[i].fnMemType == 'SRAM'){ %>
         static uvm_event         dce_injectSingleErrData_<%=pidx%>_<%=i%> = ev_pool.get("dce_injectSingleErrData_<%=pidx%>_<%=i%>");
         static uvm_event         dce_injectDoubleErrData_<%=pidx%>_<%=i%> = ev_pool.get("dce_injectDoubleErrData_<%=pidx%>_<%=i%>");
<% }}} %>
  function new(string name = "concerto_secded_parity_err_tasks", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  // UVM PHASE
  extern function void build_phase(uvm_phase phase);
  extern task inject_error(uvm_phase phase);

endclass: concerto_secded_parity_err_tasks


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
function void concerto_secded_parity_err_tasks::build_phase(uvm_phase phase);

   if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", m_concerto_env_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end   
      if(!(uvm_config_db #(concerto_env)::get(uvm_root::get(), "", "m_env", m_concerto_env)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end  
     if(!(uvm_config_db #(concerto_test_cfg)::get(uvm_root::get(), "", "test_cfg", test_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_test_cfg object in UVM DB");
    end

endfunction : build_phase

<% let hier_path_dut = 'tb_top.dut'; %>
task concerto_secded_parity_err_tasks::inject_error(uvm_phase phase); 
`uvm_info("SECDED_PARITY_ERR_TASKS", "START inject_error", UVM_LOW)

  if($test$plusargs("concerto_dmi_cmc_double_bit_error_to_datamem")) begin:_inject_dmi_uncorr_error
      bit[31:0]  read_data;
      bit[31:0]  write_data;
      uvm_status_e   status;
      uvm_object objectors_list[$];
      uvm_objection objection;

      `uvm_info("Concerto_Uncorr_Error_test", "Starting CONCERTO uncorr error test sequence",UVM_LOW)
      //csr_init_done.wait_trigger();
        #5ns;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUUEDR_MemErrDetEn_out = 1;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUUEIR_MemErrIntEn_out = 1;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUCECR_ErrIntEn_out = 1;
        phase.raise_objection(this, "Concerto_Uncorr_Error_test");

<% if(valid_dmi_test) { %>
<% for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>
<% if(obj.DmiInfo[pidx].useCmc) { %>
        m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("DMIUUEDR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUUEDR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("DMIUUEDR").get_address(),read_data), UVM_LOW)
        write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("DMIUUEDR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUUEDR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("DMIUUEDR").get_address(),write_data), UVM_LOW)

        m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("DMIUUEIR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUUEIR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("DMIUUEIR").get_address(),read_data), UVM_LOW)
        write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("DMIUUEIR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUUEIR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("DMIUUEIR").get_address(),write_data), UVM_LOW)
<% } } } %>

<% for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>
<% if(obj.DmiInfo[pidx].useCmc) { %>
   <%for( let i=0;i<obj.DmiInfo[pidx].ccpParams.nTagBanks;i++){%>
   <% } %>
   <%for( let i=0;i<obj.DmiInfo[pidx].ccpParams.nDataBanks;i++){%>
        //dmi_injectDoubleErrData_<%=pidx%>_<%=i%>.trigger();
        //`uvm_info("Concerto_Uncorr_Error_test","Triggerred dmi_injectDoubleErrData_<%=pidx%>_<%=i%>", UVM_LOW);   
   <% } %>
<% } } %>

<% if(valid_dmi_test) { %>
        // Verifying interrupt(irq_uc) through only one dmi - .<%=obj.DmiInfo[0].strRtlNamePrefix%>_irq_uc
        dmi_injectDoubleErrData_0_0.trigger();
        `uvm_info("Concerto_Uncorr_Error_test","Triggerred dmi_injectDoubleErrData_0_0", UVM_LOW);

        // Wait for interrupt to go high after error injection
        wait(<%=hier_path_dut%>.<%=obj.DmiInfo[0].strRtlNamePrefix%>_irq_uc==1);

        // Clear the interrupt
        // DMIUUESR.ErrVld
        m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUUESR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUUESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUUESR").get_address(),read_data), UVM_LOW)
        // Check ErrType & ErrInfo DMI cache data mem
        if(read_data[31:12]==1) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUUESR[ADDR 0x%0h] ErrInfo 0x%0h value",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUUESR").get_address(),read_data[31:12]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUUESR[ADDR 0x%0h] ErrInfo 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUUESR").get_address(),read_data[31:12],1))
        end
        if(read_data[7:4]==1) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUUESR[ADDR 0x%0h] ErrInfo 0x%0h value",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUUESR").get_address(),read_data[7:4]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUUESR[ADDR 0x%0h] ErrInfo 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUUESR").get_address(),read_data[7:4],1))
        end

        write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUUESR.ErrVld.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUUESR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUUESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUUESR").get_address(),write_data), UVM_LOW)

        m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUUESR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUUESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUUESR").get_address(),read_data), UVM_LOW)

        fork : wait_for_dmi0_irq_uce_to_go_low
        begin
            wait(<%=hier_path_dut%>.<%=obj.DmiInfo[0].strRtlNamePrefix%>_irq_uc==0);
        end

        begin
            #1000ns;
        end
        join_any : wait_for_dmi0_irq_uce_to_go_low

        disable  wait_for_dmi0_irq_uce_to_go_low;
        if(<%=hier_path_dut%>.<%=obj.DmiInfo[0].strRtlNamePrefix%>_irq_uc==0) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.DmiInfo[0].strRtlNamePrefix%>_irq_uc is cleared after writing to <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUUESR.ErrVld"), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.DmiInfo[0].strRtlNamePrefix%>_irq_uc is not cleared after writing to <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUUESR.ErrVld"))
        end
<% } %>

        phase.drop_objection(this, "Concerto_Uncorr_Error_test");

    end:_inject_dmi_uncorr_error

    if($test$plusargs("concerto_dmi_cmc_single_bit_error_to_datamem"))begin:_inject_dmi_corr_err
      bit[31:0]  read_data;
      bit[31:0]  write_data;
      uvm_status_e   status;
      uvm_object objectors_list[$];
      uvm_objection objection;
        phase.raise_objection(this, "Concerto_corr_Error_test");
        //csr_init_done.wait_trigger();
        #5ns;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUUEDR_MemErrDetEn_out = 1;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUUEIR_MemErrIntEn_out = 1;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUCECR_ErrIntEn_out = 1;
        // DMIUCECR.ErrDetEn   DMIUCECR.ErrIntEn
        //DMIUCESR.ErrVld w1c

<% if(valid_dmi_test) { %>
<% for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>
<% if(obj.DmiInfo[pidx].useCmc) { %>
        m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("DMIUCECR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading dmi<%=pidx%>.DMIUCECR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("DMIUCECR").get_address(),read_data), UVM_LOW)
        write_data = read_data  | (1 <<  m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUCECR.ErrIntEn.get_lsb_pos());
        write_data = write_data | (1 <<  m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUCECR.ErrDetEn.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("DMIUCECR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing dmi<%=pidx%>.DMIUCECR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.get_reg_by_name("DMIUCECR").get_address(),write_data), UVM_LOW)
<% } } } %>

<% for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>
<% if(obj.DmiInfo[pidx].useCmc) { %>
   <%for( let i=0;i<obj.DmiInfo[pidx].ccpParams.nTagBanks;i++){%>
   <% } %>
   <%for( let i=0;i<obj.DmiInfo[pidx].ccpParams.nDataBanks;i++){%>
        //dmi_injectSingleErrData_<%=pidx%>_<%=i%>.trigger();
        //`uvm_info("Concerto_corr_Error_test","Triggerred dmi_injectSingleErrData_<%=pidx%>_<%=i%>", UVM_LOW);   

   <% } %>
<% } } %>

<% if(valid_dmi_test) { %>

        // Verifying interrupt(irq_c) through only one dmi - <%=obj.DmiInfo[0].strRtlNamePrefix%>_irq_c
        dmi_injectSingleErrData_0_0.trigger();
        `uvm_info("Concerto_Uncorr_Error_test","Triggerred dmi_injectSingleErrData_0_0", UVM_LOW);   

        // Wait for interrupt to go high after error injection
        wait(<%=hier_path_dut%>.<%=obj.DmiInfo[0].strRtlNamePrefix%>_irq_c==1);

        // Clear the interrupt
        // DMIUCESR.ErrVld
        m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUCESR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUCESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUCESR").get_address(),read_data), UVM_LOW)
        // Check ErrType & ErrInfo DMI cache data mem
        if(read_data[31:16]==1) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUCESR[ADDR 0x%0h] ErrInfo 0x%0h value",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUCESR").get_address(),read_data[31:16]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUCESR[ADDR 0x%0h] ErrInfo 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUCESR").get_address(),read_data[31:16],1))
        end
        if(read_data[15:12]==1) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUCESR[ADDR 0x%0h] ErrInfo 0x%0h value",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUCESR").get_address(),read_data[15:12]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUCESR[ADDR 0x%0h] ErrInfo 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUCESR").get_address(),read_data[15:12],1))
        end

        write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUCESR.ErrVld.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUCESR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUCESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUCESR").get_address(),write_data), UVM_LOW)

        m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUCESR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUCESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.get_reg_by_name("DMIUCESR").get_address(),read_data), UVM_LOW)


        fork : wait_for_dmi0_irq_c_to_go_low
        begin
            wait(<%=hier_path_dut%>.<%=obj.DmiInfo[0].strRtlNamePrefix%>_irq_c==0);
        end

        begin
            #1000ns;
        end
        join_any : wait_for_dmi0_irq_c_to_go_low

        disable  wait_for_dmi0_irq_c_to_go_low;
        if(<%=hier_path_dut%>.<%=obj.DmiInfo[0].strRtlNamePrefix%>_irq_c==0) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.DmiInfo[0].strRtlNamePrefix%>_irq_c is cleared after writing to <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUCESR.ErrVld"), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.DmiInfo[0].strRtlNamePrefix%>_irq_c is not cleared after writing to <%=obj.DmiInfo[0].strRtlNamePrefix%>.DMIUCESR.ErrVld"))
        end
<% } %>
     
        phase.drop_objection(this, "Concerto_corr_Error_test");
    end:_inject_dmi_corr_err

`ifdef EN_IOAIU_MEM_ACCESS_TO_INJECT_ERR
  if($test$plusargs("concerto_ioaiu_cache_double_bit_error_to_datamem")) begin:_inject_ioaiu_uncorr_error
      bit[31:0]  read_data;
      bit[31:0]  write_data;
      uvm_status_e   status;
      uvm_object objectors_list[$];
      uvm_objection objection;

      `uvm_info("Concerto_Uncorr_Error_test", "Starting CONCERTO uncorr error test sequence",UVM_LOW)
      //csr_init_done.wait_trigger();
        #5ns;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUUEDR_MemErrDetEn_out = 1;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUUEIR_MemErrIntEn_out = 1;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUCECR_ErrIntEn_out = 1;
        phase.raise_objection(this, "Concerto_Uncorr_Error_test");

<% if(valid_ioaiu_test) { %>
        m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUEDR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUEDR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUEDR").get_address(),read_data), UVM_LOW)
        write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUEDR.MemErrDetEn.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUEDR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUEDR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUEDR").get_address(),write_data), UVM_LOW)

        m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUEIR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUEIR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUEIR").get_address(),read_data), UVM_LOW)
        write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUEIR.MemErrIntEn.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUEIR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUEIR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUEIR").get_address(),write_data), UVM_LOW)


        // Verifying interrupt(irq_uc) through only one ioaiu - <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_uc
        ioaiu_injectDoubleErrData_<%=ioaiu_test_unitid%>_0.trigger();
        `uvm_info("Concerto_Uncorr_Error_test","Triggerred ioaiu_injectDoubleErrData_<%=ioaiu_test_unitid%>_0", UVM_LOW);

        // Wait for interrupt to go high after error injection
        wait(<%=hier_path_dut%>.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_uc==1);

        // Clear the interrupt
        // XAIUUESR.ErrVld
        m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data), UVM_LOW)
        // Check ErrType & ErrInfo IOAIU cache data mem
        if(read_data[31:12]==1) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUESR[ADDR 0x%0h] ErrInfo 0x%0h value",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data[31:12]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUESR[ADDR 0x%0h] ErrInfo 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data[31:12],1))
        end
        if(read_data[7:4]==1) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUESR[ADDR 0x%0h] ErrInfo 0x%0h value",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data[7:4]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUESR[ADDR 0x%0h] ErrInfo 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data[7:4],1))
        end

        write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUESR.ErrVld.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),write_data), UVM_LOW)

        m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUUESR").get_address(),read_data), UVM_LOW)

        fork : wait_for_<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_uce_to_go_low
        begin
            wait(<%=hier_path_dut%>.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_uc==0);
        end

        begin
            #1000ns;
        end
        join_any : wait_for_<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_uce_to_go_low

        disable  wait_for_<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_uce_to_go_low;
        if(<%=hier_path_dut%>.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_uc==0) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_uc is cleared after writing to <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUESR.ErrVld"), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_uc is not cleared after writing to <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUESR.ErrVld"))
        end
<% } %>

        phase.drop_objection(this, "Concerto_Uncorr_Error_test");

    end:_inject_ioaiu_uncorr_error

    if($test$plusargs("concerto_ioaiu_cache_single_bit_error_to_datamem"))begin:_inject_ioaiu_corr_err
      bit[31:0]  read_data;
      bit[31:0]  write_data;
      uvm_status_e   status;
      uvm_object objectors_list[$];
      uvm_objection objection;
        phase.raise_objection(this, "Concerto_corr_Error_test");
        //csr_init_done.wait_trigger();
        #5ns;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUUEDR_MemErrDetEn_out = 1;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUUEIR_MemErrIntEn_out = 1;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUCECR_ErrIntEn_out = 1;
        // DMIUCECR.ErrDetEn   DMIUCECR.ErrIntEn
        //DMIUCESR.ErrVld w1c

<% if(valid_ioaiu_test) { %>
        m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCECR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUCECR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCECR").get_address(),read_data), UVM_LOW)
        write_data = read_data  | (1 <<  m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUCECR.ErrIntEn.get_lsb_pos());
        write_data = write_data | (1 <<  m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUCECR.ErrDetEn.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCECR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUCECR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCECR").get_address(),write_data), UVM_LOW)


        // Verifying interrupt(irq_c) through only one ioaiu - <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_c
        ioaiu_injectSingleErrData_<%=ioaiu_test_unitid%>_0.trigger();
        `uvm_info("Concerto_Uncorr_Error_test","Triggerred ioaiu_injectSingleErrData_<%=ioaiu_test_unitid%>_0", UVM_LOW);   

        // Wait for interrupt to go high after error injection
        wait(<%=hier_path_dut%>.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_c==1);

        // Clear the interrupt
        // XAIUCESR.ErrVld
        m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCESR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUCESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCESR").get_address(),read_data), UVM_LOW)
        // Check ErrType & ErrInfo DMI cache data mem
        if(read_data[31:16]==1) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUCESR[ADDR 0x%0h] ErrInfo 0x%0h value",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCESR").get_address(),read_data[31:16]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUCESR[ADDR 0x%0h] ErrInfo 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCESR").get_address(),read_data[31:16],1))
        end
        if(read_data[15:12]==1) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUCESR[ADDR 0x%0h] ErrInfo 0x%0h value",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCESR").get_address(),read_data[15:12]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUCESR[ADDR 0x%0h] ErrInfo 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCESR").get_address(),read_data[15:12],1))
        end
        

        write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUCESR.ErrVld.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCESR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUCESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCESR").get_address(),write_data), UVM_LOW)

        m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCESR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUCESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.get_reg_by_name("XAIUCESR").get_address(),read_data), UVM_LOW)

        fork : wait_for_<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_c_to_go_low
        begin
            wait(<%=hier_path_dut%>.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_c==0);
        end

        begin
            #1000ns;
        end
        join_any : wait_for_<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_c_to_go_low

        disable  wait_for_<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_c_to_go_low;
        if(<%=hier_path_dut%>.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_c==0) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_c is cleared after writing to <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUCESR.ErrVld"), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>_irq_c is not cleared after writing to <%=obj.AiuInfo[ioaiu_test_unitid].strRtlNamePrefix%>.XAIUUCESR.ErrVld"))
        end
<% } %>
     
        phase.drop_objection(this, "Concerto_corr_Error_test");
    end:_inject_ioaiu_corr_err
`endif // `ifdef EN_IOAIU_MEM_ACCESS_TO_INJECT_ERR

`ifdef EN_DCE_MEM_ACCESS_TO_INJECT_ERR
  if($test$plusargs("concerto_dce_double_bit_error_to_tagmem")) begin:_inject_dce_uncorr_error
      bit[31:0]  read_data;
      bit[31:0]  write_data;
      uvm_status_e   status;
      uvm_object objectors_list[$];
      uvm_objection objection;

      `uvm_info("Concerto_Uncorr_Error_test", "Starting CONCERTO uncorr error test sequence",UVM_LOW)
      //csr_init_done.wait_trigger();
        #5ns;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUUEDR_MemErrDetEn_out = 1;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUUEIR_MemErrIntEn_out = 1;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUCECR_ErrIntEn_out = 1;
        phase.raise_objection(this, "Concerto_Uncorr_Error_test");

<% if(valid_dce_test) { %>
        m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUEDR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUEDR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUEDR").get_address(),read_data), UVM_LOW)
        write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUEDR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUEDR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUEDR").get_address(),write_data), UVM_LOW)

        m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUEIR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUEIR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUEIR").get_address(),read_data), UVM_LOW)
        write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUEIR.MemErrIntEn.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUEIR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUEIR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUEIR").get_address(),write_data), UVM_LOW)


        // Verifying interrupt(irq_uc) through only one dce - <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_uc
        dce_injectDoubleErrData_<%=dce_test_unitid%>_0.trigger();
        `uvm_info("Concerto_Uncorr_Error_test","Triggerred dce_injectDoubleErrData_<%=dce_test_unitid%>_0", UVM_LOW);

        // Wait for interrupt to go high after error injection
        wait(<%=hier_path_dut%>.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_uc==1);

        // Clear the interrupt
        // DCEUUESR.ErrVld
        m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUESR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUESR").get_address(),read_data), UVM_LOW)
        // Check ErrType & ErrInfo DCE snoop filter 
        if(read_data[14:12]==3) begin // ErrInfo[2:0] Storage Type
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUESR[ADDR 0x%0h] ErrInfo.Storage Type 0x%0h value",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUESR").get_address(),read_data[14:12]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUESR[ADDR 0x%0h] ErrInfo.Storage Type 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUESR").get_address(),read_data[14:12],3))
        end
        if(read_data[31:20]==0) begin // ErrInfo[19:8] Snoop Filter ID
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUESR[ADDR 0x%0h] ErrInfo.Storage Type 0x%0h value",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUESR").get_address(),read_data[31:20]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUESR[ADDR 0x%0h] ErrInfo.Storage Type 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUESR").get_address(),read_data[31:20],0))
        end
        if(read_data[7:4]==0) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUESR[ADDR 0x%0h] ErrInfo 0x%0h value",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUESR").get_address(),read_data[7:4]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUESR[ADDR 0x%0h] ErrInfo 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUESR").get_address(),read_data[7:4],0))
        end

        write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUESR.ErrVld.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUESR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUESR").get_address(),write_data), UVM_LOW)

        m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUESR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUUESR").get_address(),read_data), UVM_LOW)

        fork : wait_for_<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_uce_to_go_low
        begin
            wait(<%=hier_path_dut%>.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_uc==0);
        end

        begin
            #1000ns;
        end
        join_any : wait_for_<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_uce_to_go_low

        disable  wait_for_<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_uce_to_go_low;
        if(<%=hier_path_dut%>.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_uc==0) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_uc is cleared after writing to <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUESR.ErrVld"), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_uc is not cleared after writing to <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUESR.ErrVld"))
        end
<% } %>

        phase.drop_objection(this, "Concerto_Uncorr_Error_test");

    end:_inject_dce_uncorr_error

    if($test$plusargs("concerto_dce_single_bit_error_to_tagmem"))begin:_inject_dce_corr_err
      bit[31:0]  read_data;
      bit[31:0]  write_data;
      uvm_status_e   status;
      uvm_object objectors_list[$];
      uvm_objection objection;
        phase.raise_objection(this, "Concerto_corr_Error_test");
        //csr_init_done.wait_trigger();
        #5ns;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUUEDR_MemErrDetEn_out = 1;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUUEIR_MemErrIntEn_out = 1;
        //force tb_top.dut.dmi0.dmi_unit.csr.DMIUCECR_ErrIntEn_out = 1;
        // DMIUCECR.ErrDetEn   DMIUCECR.ErrIntEn
        //DMIUCESR.ErrVld w1c

<% if(valid_dce_test) { %>
        m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCECR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCECR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCECR").get_address(),read_data), UVM_LOW)
        write_data = read_data  | (1 <<  m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCECR.ErrIntEn.get_lsb_pos());
        write_data = write_data | (1 <<  m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCECR.ErrDetEn.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCECR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCECR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCECR").get_address(),write_data), UVM_LOW)


        // Verifying interrupt(irq_c) through only one dce - <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_c
        dce_injectSingleErrData_<%=dce_test_unitid%>_0.trigger();
        `uvm_info("Concerto_Uncorr_Error_test","Triggerred dce_injectSingleErrData_<%=dce_test_unitid%>_0", UVM_LOW);   

        // Wait for interrupt to go high after error injection
        wait(<%=hier_path_dut%>.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_c==1);

        // Clear the interrupt
        // DCEUCESR.ErrVld
        m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCESR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCESR").get_address(),read_data), UVM_LOW)
        // Check ErrType & ErrInfo DCE snoop filter 
        if(read_data[18:16]==3) begin // ErrInfo[2:0] Storage Type
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCESR[ADDR 0x%0h] ErrInfo.Storage Type 0x%0h value",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCESR").get_address(),read_data[18:16]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCESR[ADDR 0x%0h] ErrInfo.Storage Type 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCESR").get_address(),read_data[18:16],3))
        end
        if(read_data[31:24]==0) begin // ErrInfo[19:8] Snoop Filter ID
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCESR[ADDR 0x%0h] ErrInfo.Storage Type 0x%0h value",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCESR").get_address(),read_data[31:24]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCESR[ADDR 0x%0h] ErrInfo.Storage Type 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCESR").get_address(),read_data[31:24],0))
        end
        if(read_data[15:12]==0) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Expected <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCESR[ADDR 0x%0h] ErrInfo 0x%0h value",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCESR").get_address(),read_data[15:12]), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Unexpected <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCESR[ADDR 0x%0h] ErrInfo 0x%0h value. Expected value=0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCESR").get_address(),read_data[15:12],0))
        end


        write_data = read_data | (1 <<  m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCESR.ErrVld.get_lsb_pos());
        m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCESR").write(status, write_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Writing <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCESR").get_address(),write_data), UVM_LOW)

        m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCESR").read(status, read_data);
        `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Reading <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUCESR ADDR 0x%0h DATA 0x%0h",m_concerto_env.m_regs.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.get_reg_by_name("DCEUCESR").get_address(),read_data), UVM_LOW)

        fork : wait_for_<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_c_to_go_low
        begin
            wait(<%=hier_path_dut%>.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_c==0);
        end

        begin
            #1000ns;
        end
        join_any : wait_for_<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_c_to_go_low

        disable  wait_for_<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_c_to_go_low;
        if(<%=hier_path_dut%>.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_c==0) begin
            `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_c is cleared after writing to <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUCESR.ErrVld"), UVM_LOW)
        end else begin
            `uvm_error("Concerto_Uncorr_Error_test", $sformatf("Interrupt <%=hier_path_dut%>.<%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>_irq_c is not cleared after writing to <%=obj.DceInfo[dce_test_unitid].strRtlNamePrefix%>.DCEUUCESR.ErrVld"))
        end
<% } %>
     
        phase.drop_objection(this, "Concerto_corr_Error_test");
    end:_inject_dce_corr_err
`endif // `ifdef EN_DCE_MEM_ACCESS_TO_INJECT_ERR

`uvm_info("SECDED_PARITY_ERR_TASKS", "END inject_error", UVM_LOW)
endtask:inject_error

////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////

