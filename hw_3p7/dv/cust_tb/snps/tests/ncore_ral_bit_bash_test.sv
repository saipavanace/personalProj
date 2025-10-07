class ncore_ral_bit_bash_test extends ncore_sys_test;

    `uvm_component_utils(ncore_ral_bit_bash_test);
    ncore_bit_bash_seq   csr_seq;

    function new (string name="ncore_ral_bit_bash_test", uvm_component parent);
        super.new (name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        `uvm_info("run_phase", "Entered...", UVM_LOW)
        csr_seq = ncore_bit_bash_seq::type_id::create("csr_seq");
        csr_seq.model = m_env.regmodel;

        <%var largest_index = (obj.nDCEs > obj.nDMIs) ? ( (obj.nDCEs > obj.nDIIs) ? obj.nDCEs : obj.nDIIs ) : ( (obj.nDMIs > obj.nDIIs) ? obj.nDMIs : obj.nDIIs );%>
        <% for(var idx = 0; idx < obj.nAIUs; idx++) {
            if(obj.AiuInfo[idx].fnNativeInterface.includes('CHI')) {%>
                uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.NRSBAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.NRSBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUBRAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUBRBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUNRSAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                <%for(var j=0;j<largest_index;j++) {%>
                    uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                <%} %>
            <%} else {
                for (var mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                    <%for(var pidx = 0; pidx < 8; ++pidx){
                        if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
                            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUEDR<%=pidx%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        <%} else { %>
                            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUEDR<%=pidx%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        <%}
                    }%>
                    <% if ((obj.AiuInfo[idx].fnNativeInterface == 'AXI4'|| obj.AiuInfo[idx].fnNativeInterface == 'AXI5')&& obj.AiuInfo[idx].useCache == 1){
                        if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
                            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCISR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCMAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        <%} else { %>
                            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCISR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCMAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        <%}
                    } %>
                    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
                        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUQOSSR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUNRSBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUBRAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUBRBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUNRSAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        <%for(var j=0;j<largest_index;j++) {%>
                            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        <%} %>
                    <%} else { %>
                        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUQOSSR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUNRSBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUBRAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUBRBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUNRSAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        <%for(var j=0;j<largest_index;j++) {%>
                            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                        <%} %>
                    <%}
                }
            }%>
     <%}%>
        <% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
            <% if(obj.DmiInfo[pidx].useCmc) { %>
                uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUSMCISR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
                uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUSMCMCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
            <% } %>
        <% } %>
        <% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUSER0.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUSFMAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
            <%for(var j=0;j<obj.nDMIs;j++) {%>
                uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
            <%}%>
        <%}%>
        uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.sys_dii.DIIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
        <% for(var idx = 0; idx < (obj.DveInfo[0].nAius / 32) ;idx++) {%>
            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVEUSER<%=idx%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this); //dve_ral_test.svh
            uvm_resource_db#(bit)::set({"REG::", m_env.regmodel.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVEMCNTCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this); //dve_ral_test.svh
        <%}%>

        phase.raise_objection(this);
        csr_seq.start(null);
        m_env.regmodel.print();
        phase.drop_objection(this);
  endtask : run_phase

endclass: ncore_ral_bit_bash_test
