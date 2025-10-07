<%
const chipletObj = obj.lib.getAllChipletRefs();
const chipletInstances = obj.lib.getAllChipletInstanceNames();
%>

class ncore_memregions_override_test extends ncore_sys_test;
    `uvm_component_utils(ncore_memregions_override_test);
    
    ncore_memregions_override_vseq m_memregions_vseq;
    longint memregions_start_q[$] = '{'hf56400000000, 'h40b000000000, 'h1608e00000000, 'h1719316000000, 'he812e0000000, 'h19f800000000, 'h1300000000000, 'h1cad800000000, 'h680000000000, 'h100000000000, 'h1a7fc00000000, 'h1a8260d200000, 'hc39900000000, 'h13a0000000000, 'h1f0c000000000, 'h7d8000000000};
    longint memregions_end_q[$] = '{'hf564ffffffff, 'h40bfffffffff, 'h1608fffffffff, 'h17193161fffff, 'he812ffffffff, 'h19ffffffffff, 'h133ffffffffff, 'h1cadfffffffff, 'h6fffffffffff, 'h17ffffffffff, 'h1a7fdffffffff, 'h1a8260d27ffff, 'hc399ffffffff, 'h13bffffffffff, 'h1f0dfffffffff, 'h7dffffffffff};

    int start_addr_result[$]; // 
    int end_addr_result[$];

    function new (string name="ncore_memregions_override_test", uvm_component parent);
        super.new (name, parent);
    endfunction : new
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        csrq = ncoreConfigInfo::get_all_gpra();
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        m_memregions_vseq = ncore_memregions_override_vseq::type_id::create("m_memregions_vseq");
        m_memregions_vseq.regmodel = m_env.regmodel;
        <%for(let i=0; i<chipletObj[0].nCHIs; i++){%>
            m_memregions_vseq.chi_rn_sqr<%=i%> = m_env.m_amba_env.chi_system[0].rn[<%=i%>].rn_xact_seqr;
        <%}%>

        <%let pidx=0;%>
        <%for(let idx = 0; idx < chipletObj[0].nAIUs; idx++) { %>
            <%if(!(chipletObj[0].AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                <%for (let mpu_io = 0; mpu_io < chipletObj[0].AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                    m_memregions_vseq.axi_xact_seqr<%=pidx%> = m_env.m_amba_env.axi_system[0].master[<%=pidx%>].sequencer;
                    <%pidx++;%>
                <%}%>
            <%}%>
        <%}%>

        foreach(ncoreConfigInfo::memregions_info[region]) begin
            start_addr_result = memregions_start_q.find_index() with (longint'(item) == longint'(ncoreConfigInfo::memregions_info[region].start_addr));
            end_addr_result = memregions_end_q.find_index() with (longint'(item) == longint'(ncoreConfigInfo::memregions_info[region].end_addr));

            if (start_addr_result.size() == 0) begin
               `uvm_error(get_name(), $psprintf("When externally overriding memregion, Start Addr: 0x%0h was not populated in address manager", ncoreConfigInfo::memregions_info[region].start_addr));
            end
            if (end_addr_result.size() == 0) begin
                `uvm_error(get_name(), $psprintf("When externally overriding memregion, End Addr: 0x%0h was not populated in address manager", ncoreConfigInfo::memregions_info[region].end_addr));
            end
        end
        
        m_memregions_vseq.start(null);
        phase.drop_objection(this);
    endtask: run_phase

endclass: ncore_memregions_override_test

