<%const chipletObj = obj.lib.getAllChipletRefs();%>

class ncore_ral_reset_value_test extends ncore_sys_test;

  `uvm_component_utils(ncore_ral_reset_value_test);
  uvm_reg_hw_reset_seq   csr_seq;
  
  function new (string name="ncore_ral_reset_value_test", uvm_component parent);
    super.new (name, parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    csr_seq = uvm_reg_hw_reset_seq::type_id::create("csr_seq");
  endfunction : build_phase
  
  virtual task run_phase(uvm_phase phase);
    `uvm_info("run_phase", "Entered...", UVM_LOW)
    csr_seq = uvm_reg_hw_reset_seq::type_id::create("csr_seq");
    csr_seq.model = m_env.regmodel;
    
    phase.raise_objection(this);
    <% for(var idx = 0; idx < chipletObj[0].nAIUs; idx++) {
         if((chipletObj[0].AiuInfo[idx].fnNativeInterface == 'CHI-B')||(chipletObj[0].AiuInfo[idx].fnNativeInterface == 'CHI-E')) {%>
             uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.CAIUTAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
         <%} else {
               for (var mpu_io = 0; mpu_io < chipletObj[0].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                 <% if ((chipletObj[0].AiuInfo[idx].fnNativeInterface == 'AXI4' || chipletObj[0].AiuInfo[idx].fnNativeInterface == 'AXI5') && chipletObj[0].AiuInfo[idx].useCache == 1){%>
                      <% if(chipletObj[0].AiuInfo[idx].nNativeInterfacePorts > 1){%>
                          uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCISR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
                          uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCMAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
                      <%} else { %>
                          uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUPCISR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
                          uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUPCMAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
                      <%}
                 }%>
                 <% if(chipletObj[0].AiuInfo[idx].nNativeInterfacePorts > 1){%>
                      uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUNRSBLR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
                      uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
                      uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUBRAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
                      uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUBRBLR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
                 <%} else { %>
                      uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUNRSBLR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
                      uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
                      uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUBRAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
                      uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].AiuInfo[idx].strRtlNamePrefix%>.XAIUBRBLR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
                 <%}
              }%>
         <%}
    }%>
    <% for(var pidx = 0; pidx < chipletObj[0].nDMIs; pidx++) { %>
        <% if(chipletObj[0].DmiInfo[pidx].useCmc) { %>
            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>.DMIUSMCISR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].DmiInfo[pidx].strRtlNamePrefix%>.DMIUTAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
        <% } %>
    <%}%>
    <% for(var pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) { %>
        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>.DCEUTAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].DceInfo[pidx].strRtlNamePrefix%>.DCEUSFMAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    <%}%>
        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.sys_dii.DIIUTAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=chipletObj[0].DveInfo[0].strRtlNamePrefix%>.DVEUSER0.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this); //dve_ral_test.svh
    
    csr_seq.start(null);
    m_env.regmodel.print();
    phase.drop_objection(this);
  endtask : run_phase

endclass : ncore_ral_reset_value_test

