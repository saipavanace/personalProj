<% obj.Dvm_aiuInfo = [] ;
obj.Dvm_NUnitIds = [] ;
for (i in obj.AiuInfo) {
    if(obj.AiuInfo[i].cmpInfo.nDvmSnpInFlight > 0) {
        obj.Dvm_aiuInfo.push(obj.AiuInfo[i]);
        obj.Dvm_NUnitIds.push(obj.AiuInfo[i].nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}
var dvm_agent = obj.Dvm_aiuInfo.length  %>


import common_knob_pkg::*;

class dve_drop_k_seq extends dve_tacc_test_seq;
  `uvm_object_utils(dve_drop_k_seq)
  
  // Functions
  function new(string name = "dve_drop_k_seq");
    super.new(name);
  endfunction // new

  task body();
    // #Stimulus.DVE.v3.2.DropK
    // #Check.DVE.v3.2.DropK
    super.body();

    begin
      bit full, empty = 1'b0;
      int k = 8;
      // OK, do the thing
      // inject N-1
      for(int i = 0; i < <%=nMainTraceBufSize%>-1; i++) begin
        issue_dtw_dbg_req();
      end
      #20000000 buffer_is_full(full);
      if(full) begin
        `uvm_error(get_name(), "TACC buffer full before fill completion")
      end
      // inject the Nth: buffer should only now be full
      issue_dtw_dbg_req();
      #20000000 buffer_is_full(full);
      if(!full) begin
        `uvm_error(get_name(), "TACC buffer not full after fill completion")
      end
      issue_csr_read();
      #20000000 buffer_is_full(full);
      if(full) begin
        `uvm_error(get_name(), "TACC buffer full after removing a packet")
      end
      // insert k+1 packets: k will be dropped
      for(int i = 0; i < k+1; i++) begin
        issue_dtw_dbg_req();
      end
      #20000000 buffer_is_full(full);
      if(!full) begin
        `uvm_error(get_name(), "TACC buffer not still full after adding packets for drop")
      end
      for(int i = 0; i < <%=nMainTraceBufSize%>; i++) begin
        issue_csr_read();
      end
      #20000000 buffer_is_empty(empty);
      if(!empty) begin
        `uvm_error(get_name(), "TACC buffer not empty after full read-out")
      end
    end

  endtask // body
endclass // dve_drop_k_seq
