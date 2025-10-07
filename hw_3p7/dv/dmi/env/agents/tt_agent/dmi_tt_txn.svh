//-------------------------------------------------------------------------------------------------- 
//  Transaction Table packet
//-------------------------------------------------------------------------------------------------- 

class <%=obj.BlockId%>_tt_alloc_pkt extends uvm_object;

    bit                                                                                             isRtt;
    bit                                                                                             isWtt;
    logic                                                                                           alloc_valid; 
    logic [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]                                             alloc_addr;
    logic                                                                                           alloc_ns;
    logic [<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0]                                          alloc_msg_id;
    logic [<%=obj.Widths.Concerto.Ndp.Header.wFUnitId-1%>:0]                                        alloc_aiu_unit_id;
    logic [<%=obj.Widths.Concerto.Ndp.Header.wCmType-1%>:0]                                         alloc_msg_type;
    bit                                                                                             dealloc_vld;
    time                                                                                            t_pkt;
   
    `uvm_object_utils_begin(<%=obj.BlockId%>_tt_alloc_pkt)
        `uvm_field_int     (isRtt, UVM_DEFAULT)
        `uvm_field_int     (isWtt, UVM_DEFAULT)
        `uvm_field_int     (alloc_valid, UVM_DEFAULT)
        `uvm_field_int     (alloc_addr, UVM_DEFAULT)
        `uvm_field_int     (alloc_ns, UVM_DEFAULT)
        `uvm_field_int     (alloc_msg_id, UVM_DEFAULT)
        `uvm_field_int     (alloc_aiu_unit_id, UVM_DEFAULT)
        `uvm_field_int     (alloc_msg_type, UVM_DEFAULT)
        `uvm_field_int     (dealloc_vld, UVM_DEFAULT)
        `uvm_field_int     (t_pkt, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "<%=obj.BlockId%>_tt_alloc_pkt");
        super.new(name);    
    endfunction : new

    function string sprint_pkt();
        sprint_pkt = $sformatf("isRtt:%0b isWtt:%0b alloc_valid:%0b alloc_addr:0x%0h alloc_ns:%0b alloc_msg_id:0x%0h alloc_aiu_unit_id:0x%0h alloc_msg_type:%p dealloc_vld:%0d time:%0t", isRtt, isWtt, alloc_valid, alloc_addr, alloc_ns, alloc_msg_id, alloc_aiu_unit_id, alloc_msg_type, dealloc_vld, t_pkt);
    endfunction : sprint_pkt

endclass : <%=obj.BlockId%>_tt_alloc_pkt
