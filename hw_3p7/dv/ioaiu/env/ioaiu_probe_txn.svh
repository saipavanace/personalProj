/*
*
*
*/
typedef struct {
    longint				m_cycle_count;
    time 				m_time;
} cycle_tracker_s;

class ioaiu_probe_txn extends uvm_sequence_item;
    `uvm_object_param_utils(ioaiu_probe_txn)
    bit [nOttEntries-1 : 0] ott_entries         ;
    bit snp_req_vld       ;
    smi_addr_security_t snp_req_addr;
    bit [nOttEntries-1 : 0] snp_req_match       ;
    bit [nOttEntries-1 : 0] ott_entries_chit    ;
    int                     ott_msg_id          ;
    bit                     starvation          ;
    bit                     gc_threshold_reached;
    bit [nOttEntries-1 : 0] overflow            ;
    shortint                global_counter      ;
    shortint                starv_threshold     ;
    int                     starv_counter       ;
    longint                 cycle_counter       ;

    bit [nOttEntries-1 : 0] ott_owned_st ;
    bit [nOttEntries-1 : 0] ott_oldest_st ;
    bit [nOttEntries-1 : 0] ott_security;
    bit [nOttEntries-1 : 0] ott_prot;
    smi_addr_t ott_address[nOttEntries-1 : 0];
    smi_addr_t ott_address[nOttEntries-1 : 0];
    bit [WAXID-1:0] ott_id[nOttEntries-1 : 0];
    int    ott_user[nOttEntries-1 : 0];
    bit [nOttEntries-1 : 0]    ott_qos[nOttEntries-1 : 0];
    bit [nOttEntries-1 : 0]    ott_write[nOttEntries-1 : 0];
    bit [nOttEntries-1 : 0]    ott_evict[nOttEntries-1 : 0];
    bit [nOttEntries-1:0] ottvld_vec;
    bit [nOttEntries-1:0] ottvld_vec_prev;
    bit [3 : 0]    	       ott_cache[nOttEntries-1 : 0];
    <%if(obj.useCache){%>
            <% if(obj.testBench =="io_aiu") {%>
                <%for( var i=0;i<obj.nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                   bit bypass_bank<%=i%>; 
                <%}%>
            <%}%>
    <%}%>


    function new(string name = "ioaiu_probe_txn");
        super.new(name);
    endfunction : new
endclass
