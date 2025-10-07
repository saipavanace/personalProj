class ncore_reg_wr_rd_test extends ncore_sys_test;

  `uvm_component_utils(ncore_reg_wr_rd_test);
  reg_wr_rd_seq   csr_seq;

  function new (string name="ncore_reg_wr_rd_test", uvm_component parent);
    super.new (name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    csr_seq = reg_wr_rd_seq::type_id::create("csr_seq");

  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    <%var largest_index = (obj.nDCEs > obj.nDMIs) ? ((obj.nDCEs > obj.nDIIs) ? obj.nDCEs : obj.nDIIs) : ((obj.nDMIs > obj.nDIIs) ? obj.nDMIs : obj.nDIIs);%>
    csr_seq = reg_wr_rd_seq:: type_id:: create("csr_seq");
    csr_seq.model = m_env.regmodel;
      
    <% for (var idx = 0; idx < obj.nAIUs; idx++) {
         if (obj.AiuInfo[idx].fnNativeInterface.includes('CHI')) {%>
           uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>.NRSBAR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
           uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>.NRSBHR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
           uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>.NRSBLR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
           uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>.CAIUTAR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
           <%for (var j = 0; j < largest_index; j++) {%>
               uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>.CAIUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this); // To be rechecked
           <%} %>
         <%} else {
               for (var mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++) {%>
                 <%for (var pidx = 0; pidx < 8; ++pidx) {
                     if (obj.AiuInfo[idx].nNativeInterfacePorts > 1) {%>
                         uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>_<%=mpu_io%>.XAIUEDR<%=pidx %>.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
                     <%} else {%>
                         uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>.XAIUEDR<%=pidx%>.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
                     <%}
                 }%>
                 <% if ((obj.AiuInfo[idx].fnNativeInterface == 'AXI4'|| obj.AiuInfo[idx].fnNativeInterface == 'AXI5') && obj.AiuInfo[idx].useCache == 1) {
                     if (obj.AiuInfo[idx].nNativeInterfacePorts > 1) {%>
                         uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>_<%=mpu_io%>.XAIUPCISR.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
                         uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>_<%=mpu_io%>.XAIUPCMCR.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
                     <%} else {%>
                         uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>.XAIUPCISR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
                         uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>.XAIUPCMCR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
                     <%}
                 } %>
                 <% if (obj.AiuInfo[idx].nNativeInterfacePorts > 1) {%>
                      uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>_<%=mpu_io%>.XAIUNRSBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
                      uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>_<%=mpu_io%>.XAIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
                      <%for (var j = 0; j < largest_index; j++) {%>
                             uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>_<%=mpu_io%>.XAIUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
                      <%}%>
                 <%} else { %>
                       uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>.XAIUNRSBLR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
                       uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>.XAIUTAR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
                       <%for (var j = 0; j < largest_index; j++) {%>
                           uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix %>.XAIUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
                       <%}%>
                 <%}
               }
            }%>
    <%}%>
    <% for (var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
         uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.DceInfo[pidx].strRtlNamePrefix %>.DCEUTAR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
         uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.DceInfo[pidx].strRtlNamePrefix %>.DCEUSFMAR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
         <%for (var j = 0; j < obj.nDMIs; j++) {%>
             uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.DceInfo[pidx].strRtlNamePrefix %>.DCEUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this);
         <% } %>
    <% } %>
    <% for (var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
         <% if (obj.DmiInfo[pidx].useCmc) { %>
              uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.DmiInfo[pidx].strRtlNamePrefix %>.DMIUSMCISR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
              uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.DmiInfo[pidx].strRtlNamePrefix %>.DMIUSMCMCR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
         <% } %>
    <% } %>
    uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.sys_dii.DIIUTAR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
    <% for (var idx = 0; idx < (obj.DveInfo[0].nAius / 32); idx++) {%>
         uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.DveInfo[0].strRtlNamePrefix %>.DVEUSER<%=idx%>.get_full_name()}, "NO_REG_BIT_BASH_TEST", 1, this); //dve_ral_test.svh
         uvm_resource_db#(bit):: set({ "REG::", m_env.regmodel.<%=obj.DveInfo[0].strRtlNamePrefix %>.DVEMCNTCR.get_full_name() }, "NO_REG_BIT_BASH_TEST", 1, this);
    <% } %>
  
    phase.raise_objection(this);
        csr_seq.start(null);
        m_env.regmodel.print();
    phase.drop_objection(this);
  
  endtask: run_phase

endclass : ncore_reg_wr_rd_test


