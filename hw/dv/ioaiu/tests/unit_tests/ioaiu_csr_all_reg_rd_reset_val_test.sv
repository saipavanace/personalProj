//******************************************************************************
// Class    : ioaiu_csr_all_reg_rd_reset_val_test 
// Purpose  : Reads all register reset values and matched with testbench
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

class ioaiu_csr_all_reg_rd_reset_val_test extends base_test;
    `uvm_component_utils(ioaiu_csr_all_reg_rd_reset_val_test)
    uvm_reg_hw_reset_seq reg_hw_reset_seq;
    <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
    ioaiu_csr_id_reset_seq_<%=i%> id_reset_seq_<%=i%>;
    <%}%>

    function new(string name = "ioaiu_csr_all_reg_rd_reset_val_test", uvm_component parent=null);
        super.new(name,parent);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(bit)::set(uvm_root::get(),"*", "include_coverage", 0);
    endfunction : build_phase

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
         <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
        uvm_resource_db#(bit)::set({"REG::",mp_env.m_env[0].<%=generateRegPath(i+'.XAIUIDR.get_full_name()')%>}, "NO_REG_TESTS", 1,this);
        uvm_resource_db#(bit)::set({"REG::",mp_env.m_env[0].<%=generateRegPath(i+'.XAIUFUIDR.get_full_name()')%>}, "NO_REG_TESTS", 1,this);
        <%if(obj.DutInfo.useCache){%>
            uvm_resource_db#(bit)::set({"REG::",mp_env.m_env[0].<%=generateRegPath(i+'.XAIUPCISR.get_full_name()')%>}, "NO_REG_TESTS", 1,this);
        <%}%>
        <%}%>
        reg_hw_reset_seq       = uvm_reg_hw_reset_seq::type_id::create("reg_hw_reset_seq");
        reg_hw_reset_seq.model = mp_env.m_env[0].m_regs;
        <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
        id_reset_seq_<%=i%>           = ioaiu_csr_id_reset_seq_<%=i%>::type_id::create("id_reset_seq_<%=i%>");
        id_reset_seq_<%=i%>.model     = mp_env.m_env[0].m_regs;
        <%}%>

        fork 
            begin
                phase.raise_objection(this, "Start IOAIU CSR reset sequence");
                #100ns;
                fork 
                    <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                    begin
                        `uvm_info("IOAIU CSR Seq", "Starting IOAIU CSR ID <%=i%> reset sequence",UVM_LOW)
                        id_reset_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                    end
                    <%}%>
                join
                #100ns;
                `uvm_info("IOAIU CSR Seq", "Starting IOAIU CSR reset sequence",UVM_LOW)
                reg_hw_reset_seq.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
                #100ns;
                phase.drop_objection(this, "Finish IOAIU CSR reset sequence");
            end
        join
    endtask : run_phase
endclass: ioaiu_csr_all_reg_rd_reset_val_test
