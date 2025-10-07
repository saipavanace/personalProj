//-------------------------------------------------------------------------------------------------- 
// Write Arbiter Probe Transaction Packet
//--------------------------------------------------------------------------------------------------
class <%=obj.BlockId%>_write_probe_txn extends uvm_object;

  time   t_pkt;
  string pkt_type;

  bit valid;
  bit [<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0] addr;
  int  cmd_type;
  bit  ns;
  int  rmsg_id, aiu_id, dtw_aiu_id; //AIU IDs are source IDs
  
  `uvm_object_utils_begin(<%=obj.BlockId%>_write_probe_txn)
     `uvm_field_int   (t_pkt, UVM_DEFAULT)
     `uvm_field_string(pkt_type,UVM_DEFAULT)
     `uvm_field_int   (valid, UVM_DEFAULT)
     `uvm_field_int   (addr, UVM_DEFAULT)
     `uvm_field_int   (cmd_type, UVM_DEFAULT)
     `uvm_field_int   (ns, UVM_DEFAULT)
     `uvm_field_int   (aiu_id, UVM_DEFAULT)
     `uvm_field_int   (dtw_aiu_id, UVM_DEFAULT)
     `uvm_field_int   (rmsg_id, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "<%=obj.BlockId%>_write_probe_txn");
  endfunction : new

  function string sprint_pkt();
      sprint_pkt = $sformatf("%0s :: t_pkt:%0t CmdType:%0h Addr:%0h AiuId:%0h DTWAiuId:%0h RmsgId:%0h NS:%0b", pkt_type, t_pkt, cmd_type, addr, aiu_id, dtw_aiu_id, rmsg_id, ns);
  endfunction : sprint_pkt

endclass : <%=obj.BlockId%>_write_probe_txn

