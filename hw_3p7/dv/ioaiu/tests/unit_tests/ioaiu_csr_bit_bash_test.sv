////////////////////////////////////////////////////////////////////////////////
//******************************************************************************
// Class    : ioaiu_csr_bit_bash_test 
// Purpose  : Write and read all registers to see if they are correctly written
//******************************************************************************
<%function generateRegPath(regName) {
    if(obj.DutInfo.nNativeInterfacePorts > 1) {
        return 'm_regs.'+obj.DutInfo.strRtlNamePrefix+'_'+regName;
    } else {
         var hold = regName.split('.');
        hold.shift();
        regName = hold.join('.');
        return 'm_regs.'+obj.DutInfo.strRtlNamePrefix+'.'+regName;    }
}%>
class ioaiu_csr_bit_bash_test extends base_test;
    `uvm_component_utils(ioaiu_csr_bit_bash_test)
    bit ccp_ready;
    uvm_reg_bit_bash_seq reg_bit_bash_seq;
    <%if(obj.DutInfo.useCache){%>
        <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
        ioaiu_chk_proxy_cache_initial_done_seq_<%=i%> check_ccp_initial_done_seq_<%=i%>;
        <%}%>
    <%}%>

    function new(string name = "ioaiu_csr_bit_bash_test", uvm_component parent=null);
        super.new(name,parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(bit)::set(uvm_root::get(),"*", "include_coverage", 0);
    endfunction : build_phase

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        //  uvm_resource_db#(bit)::set({"REG::",env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.XAIUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);
        //  uvm_resource_db#(bit)::set({"REG::",env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.XAIUFUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);
         <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
        `ifdef VCS
            uvm_resource_db#(bit)::set({"REG::",mp_env.m_env[0].<%=generateRegPath(i+'.XAIUNRSBLR.get_full_name()')%>}, "NO_REG_TESTS", 1,this);
        `endif 
        <%if(obj.DutInfo.useCache){%>
            uvm_resource_db#(bit)::set({"REG::",mp_env.m_env[0].<%=generateRegPath(i+'.XAIUPCMCR.get_full_name()')%>}, "NO_REG_TESTS", 1,this);
            uvm_resource_db#(bit)::set({"REG::",mp_env.m_env[0].<%=generateRegPath(i+'.XAIUPCISR.get_full_name()')%>}, "NO_REG_TESTS", 1,this);
        <%}%>
        <%}%>
        reg_bit_bash_seq       = uvm_reg_bit_bash_seq::type_id::create("reg_bit_bash_seq");
        reg_bit_bash_seq.model = mp_env.m_env[0].m_regs;
        fork
            <% if(obj.DutInfo.useCache) { %>
            <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
            begin
            wait(u_csr_probe_vif[<%=i%>].CCPReady=== 1'b1);
            ccp_ready =1;
            end 
           <% } %>
           <% } %>
            begin
                phase.raise_objection(this, "Start IOAIU bit-bash sequence");
                #200ns;
                `uvm_info("IOAIU CSR Seq", "Starting IOAIU CSR bit-bash sequence",UVM_NONE)
                reg_bit_bash_seq.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                fork
                    #200ns;   //sai - what is the use of this delay?
                    <% if(obj.DutInfo.useCache) { %>
                        <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                        begin
                            //Fix MultiCSRAccess for all ports-> ioaiu_chk_proxy_cache_initial_done_seq_0 <- do we need all ports to connect?
                            check_ccp_initial_done_seq_<%=i%> = ioaiu_chk_proxy_cache_initial_done_seq_<%=i%>::type_id::create("check_ccp_initial_done_seq_<%=i%>");
                            check_ccp_initial_done_seq_<%=i%>.model = mp_env.m_env[0].m_regs;
                            check_ccp_initial_done_seq_<%=i%>.done = u_csr_probe_vif[<%=i%>].CCPReady;
                            check_ccp_initial_done_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                            if(ccp_ready == 1) begin
                            //Fix MultiCSRAccess for all ports-> ioaiu_chk_proxy_cache_initial_done_seq_0 <- do we need all ports to connect?
                            check_ccp_initial_done_seq_<%=i%> = ioaiu_chk_proxy_cache_initial_done_seq_<%=i%>::type_id::create("check_ccp_initial_done_seq_<%=i%>");
                            check_ccp_initial_done_seq_<%=i%>.model = mp_env.m_env[0].m_regs;
                            check_ccp_initial_done_seq_<%=i%>.done = u_csr_probe_vif[<%=i%>].CCPReady;
                            check_ccp_initial_done_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                            end
                        end
                        <%}%>
                    <%}%>
                join
                phase.drop_objection(this, "Finish IOAIU bit-bash sequence");
            end
        join
    endtask : run_phase
endclass: ioaiu_csr_bit_bash_test
