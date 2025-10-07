<%const chipletObj = obj.lib.getAllChipletRefs();%>

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
var initiatorAgents = chipletObj[0].AiuInfo.length ;
var nGPRA = 0;
var nDII = 0;
var nDMI = 0;
var nAXI = 0;
var nACE = 0;
var nACELITE = 0;
var nCHI = 0;
var nINIT = 0;
var nAIU = 0;
var cnt_multi = 200*(chipletObj[0].AiuInfo.length+chipletObj[0].DceInfo.length+chipletObj[0].DmiInfo.length+chipletObj[0].DveInfo.length+chipletObj[0].DiiInfo.length); 

for(pidx = 0; pidx < chipletObj[0].nAIUs; pidx++) {
    if((chipletObj[0].AiuInfo[pidx].fnNativeInterface.includes('CHI'))) {
        _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
        _child_blk[pidx]   = 'chiaiu';
        chiaiu_idx++;
    } else {
        _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
        _child_blk[pidx]   = 'ioaiu';
        ioaiu_idx+= chipletObj[0].AiuInfo[pidx].nNativeInterfacePorts;
    }
    if((chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'AXI4' || chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'AXI5' )) {
        axiaiu_idx+= chipletObj[0].AiuInfo[pidx].nNativeInterfacePorts;
    } else if((chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')){
        aceliteeaiu_idx+= chipletObj[0].AiuInfo[pidx].nNativeInterfacePorts;
    } else if((chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'ACE') || (chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'ACE5')){
        aceaiu_idx+= chipletObj[0].AiuInfo[pidx].nNativeInterfacePorts;
    }
}
nINIT = chiaiu_idx + ioaiu_idx;

for(pidx = 0; pidx < chipletObj[0].nDCEs; pidx++) {
    ridx = pidx + chipletObj[0].nAIUs;
    _child_blkid[ridx] = 'dce' + pidx;
    _child_blk[ridx]   = 'dce';
}
for(pidx =  0; pidx < chipletObj[0].nDMIs; pidx++) {
    ridx = pidx + chipletObj[0].nAIUs + chipletObj[0].nDCEs;
    _child_blkid[ridx] = 'dmi' + pidx;
    _child_blk[ridx]   = 'dmi';
}
for(pidx = 0; pidx < chipletObj[0].nDIIs; pidx++) {
    ridx = pidx + chipletObj[0].nAIUs + chipletObj[0].nDCEs + chipletObj[0].nDMIs;
    _child_blkid[ridx] = 'dii' + pidx;
    _child_blk[ridx]   = 'dii';
}
for(pidx = 0; pidx < chipletObj[0].nDVEs; pidx++) {
    ridx = pidx + chipletObj[0].nAIUs + chipletObj[0].nDCEs + chipletObj[0].nDMIs + chipletObj[0].nDIIs;
    _child_blkid[ridx] = 'dve' + pidx;
    _child_blk[ridx]   = 'dve';
}
nGPRA = chipletObj[0].AiuInfo[0].nGPRA;
nDII = chipletObj[0].nDIIs;
nDMI = chipletObj[0].nDMIs;
nACE = 0;
nAIU = chipletObj[0].nAIUs;
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
    uvm_event sys_test_done_event;

    ncore_chi_base_seq chi_seq;
    ncore_axi_base_seq axi_seq;
    int NUM_GPRA = <%=nGPRA%>;
    int NUM_INIT = <%=nINIT%>;
    int i,j;
    int delay = 1000;
    int seq_len = 1;
    bit [<%=nINIT-1%>:0] enable;
    string command [<%=nINIT%>];
    int transaction [<%=nINIT%>];
    bit [6:0] cache_val [<%=nINIT%>];
    int txn_no [<%=nINIT%>];
    int group [<%=nINIT%>];
    bit rd[<%=nINIT%>],wr[<%=nINIT%>];
    int addr_incr [<%=nINIT%>];
    int aiu_id [<%=nINIT%>];
    bit has_multi_port [<%=nINIT%>];
    int addr_group [<%=nINIT%>];
    bit [<%=chipletObj[0].wSysAddr-1%>:0] start_addr [<%=nINIT%>][int];
    bit [<%=chipletObj[0].wSysAddr-1%>:0] start_addr_mp [<%=nINIT%>][int];
    int burst_len[<%=nINIT%>];
    int addr_offset [<%=nINIT%>];
    int is_finished [<%=nINIT%>];
    int transaction_delay [<%=nINIT%>];
    int interval_delay_cycle=0;
    int qos_value[<%=nINIT%>];
    int id_width[<%=nINIT%>];
    int no_inf[<%=nINIT%>];
    int data_width[<%=nINIT%>];
    int dii_region, cnt;
    string protocol [<%=nINIT%>] ;
    int aiu_dmi_connect[<%=nINIT%>],aiu_dii_connect[<%=nINIT%>] ;
    int mem_region[<%=nINIT%>];
    bit [<%=nINIT-1%>:0] tmp_enable[$];
    bit [<%=nINIT-1%>:0] sum_enable[$];
    int num_chiplets = <%=chipletObj.length%>;

        ncore_base_vseq m_base_vseq;



    // Addr domain queue
    // ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];

    function new (string name="ncore_sys_test", uvm_component parent);
        super.new (name, parent);
        sys_test_done_event = uvm_event_pool::get_global("sys_test_done_event");
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        `uvm_info("ncore_sys_test", "is entered", UVM_LOW)
            m_base_vseq = ncore_base_vseq::type_id::create("ncore_base_vseq",,get_full_name());

        // Create the sequence class

        `uvm_info("ncore_sys_test", "build - is exited", UVM_LOW)
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);

        // FIXME: Move the below lines into configure phase
        // m_base_vseq.csrq  = this.csrq;
        <% for (let i = 0; i < chipletObj.length; i++) { %>
        m_base_vseq.model = m_env.regmodel;
        <%for(let idx = 0; idx < chipletObj[i].nCHIs; idx++) { %>
            m_base_vseq.rn_xact_seqr<%=i%>_<%=idx%> = m_env.m_amba_env.chi_system[<%=i%>].rn[<%=idx%>].rn_xact_seqr;
            m_base_vseq.link_seqr<%=i%>_<%=idx%> = m_env.m_amba_env.chi_system[<%=i%>].rn[<%=idx%>].link_svc_seqr;
            m_base_vseq.chi_sysco_seqr<%=i%>_<%=idx%> = m_env.m_amba_env.chi_system[<%=i%>].rn[<%=idx%>].prot_svc_seqr;
        <%}%>
        <%for(let idx = 0; idx < chipletObj[i].nIOAIUs; idx++) { %>
            m_base_vseq.axi_xact_seqr<%=i%>_<%=idx%> = m_env.m_amba_env.axi_system[0].master[<%=idx%>].sequencer;
        <%}%>
        <%}%>

        #1us;
        m_base_vseq.start(null);
        #100us;
        phase.drop_objection(this);

        sys_test_done_event.trigger();
    endtask : run_phase
endclass : ncore_sys_test

