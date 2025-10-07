//-------------------------------------------------------------------------------------------------- 
// ACE transaction packets
//--------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------- 
// ACE Read address channel transaction packet (AR)
//-------------------------------------------------------------------------------------------------- 

class <%=obj.BlockId%>_rtl_cmd_rsp_pkt extends uvm_object;

    string pkt_type;
    bit                                                      isCmd;
    bit                                                      cmd_starv_mode;
    bit                                                      cmd_rsp_push_valid;
    bit [<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0]     cmd_rsp_push_rmsg_id;
    bit [<%=obj.Widths.Concerto.Ndp.Header.wFUnitId-1%>:0]   cmd_rsp_push_targ_id;

    bit                                                      isMrd;
    bit                                                      mrd_pop_valid;
    bit  [<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0]    mrd_pop_msg_id;
    bit  [<%=obj.Widths.Concerto.Ndp.Header.wFUnitId-1%>:0]  mrd_pop_initiator_id;
    bit  [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]       mrd_pop_addr;
    bit                                                      mrd_pop_ns;
    bit                                                      mrd_starv_mode;
    time    t_pkt;
   
    `uvm_object_utils_begin(<%=obj.BlockId%>_rtl_cmd_rsp_pkt)
        `uvm_field_int     (isCmd, UVM_DEFAULT)
        `uvm_field_int     (cmd_rsp_push_rmsg_id, UVM_DEFAULT)
        `uvm_field_int     (cmd_rsp_push_targ_id, UVM_DEFAULT)
        `uvm_field_int     (cmd_starv_mode, UVM_DEFAULT)
        `uvm_field_int     (isMrd, UVM_DEFAULT)
        `uvm_field_int     (mrd_pop_msg_id, UVM_DEFAULT)
        `uvm_field_int     (mrd_pop_initiator_id, UVM_DEFAULT)
        `uvm_field_int     (mrd_pop_addr, UVM_DEFAULT)
        `uvm_field_int     (mrd_pop_ns, UVM_DEFAULT)
        `uvm_field_int     (mrd_starv_mode, UVM_DEFAULT)
        `uvm_field_int     (t_pkt, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "<%=obj.BlockId%>_rtl_cmd_rsp_pkt");
        pkt_type = "RTL_PKT";
    endfunction : new

    function string sprint_pkt();
      if(isCmd)begin
        sprint_pkt = $sformatf("%0s t_pkt:%0t isCmd push_rmsg_id:%0x push_targ_id:%0x cmd_starv_mode :%0b", pkt_type,t_pkt,cmd_rsp_push_rmsg_id,cmd_rsp_push_targ_id,cmd_starv_mode);  
      end
      else begin
        sprint_pkt = $sformatf("%0s t_pkt:%0t isMrd mrd_pop_msg_id:%0x mrd_pop_initiator_id:%0x add :%0x ns :%0b mrd_starv_mode :%0b", pkt_type,t_pkt,mrd_pop_msg_id,mrd_pop_initiator_id,mrd_pop_addr,mrd_pop_ns,mrd_starv_mode);  
      end

    endfunction : sprint_pkt

endclass : <%=obj.BlockId%>_rtl_cmd_rsp_pkt

