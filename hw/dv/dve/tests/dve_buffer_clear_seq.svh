<% 
const Dvm_NUnitIds = [] ;
const nMainTraceBufSize = obj.DutInfo.nMainTraceBufSize;

for (const elem of obj.AiuInfo) {
    if(elem.cmpInfo.nDvmSnpInFlight >0) {
        Dvm_NUnitIds.push(elem.nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}

const dvm_agent = Dvm_NUnitIds.length;
%>


import common_knob_pkg::*;

class dve_buffer_clear_seq extends dve_tacc_test_seq;
  `uvm_object_utils(dve_buffer_clear_seq)
  
  // Functions
  function new(string name = "dve_buffer_clear_seq");
    super.new(name);
  endfunction // new

  task body();
    // #Stimulus.DVE.v3.2.Clear
    // #Check.DVE.v3.2.Clear
    super.body();
    begin
      bit empty = 1'b0;
      // OK, do the thing
      issue_dtw_dbg_req();
      #20000000 buffer_is_empty(empty);
      if(empty) begin
        `uvm_error(get_name(), "TACC buffer empty after injection")
      end
      issue_csr_read();
      buffer_is_empty(empty);
      if(!empty) begin
        `uvm_error(get_name(), "TACC buffer not empty after all expected txns read")
      end
      for(int i = 0; i < <%=nMainTraceBufSize%>; i++) begin
        issue_dtw_dbg_req();
      end
      #20000000 buffer_is_empty(empty);
      if(empty) begin
        `uvm_error(get_name(), "TACC buffer empty after second injection")
      end
      issue_csr_clear();
      #1000000000 buffer_is_empty(empty);
      if(!empty) begin
        `uvm_error(get_name(), "TACC buffer not empty after BufferClear")
      end
      issue_dtw_dbg_req();
      #20000000 buffer_is_empty(empty);
      if(empty) begin
        `uvm_error(get_name(), "TACC buffer empty after third injection")
      end
      issue_csr_read();
      buffer_is_empty(empty);
      if(!empty) begin
        `uvm_error(get_name(), "TACC buffer not empty after all expected txns read")
      end
    end

  endtask // body
endclass // dve_buffer_clear_seq
