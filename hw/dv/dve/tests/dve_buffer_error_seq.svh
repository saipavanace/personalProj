<%
const Dvm_NUnitIds = [] ;

for (const elem of obj.AiuInfo) {
    if(elem.cmpInfo.nDvmSnpInFlight >0) {
        Dvm_NUnitIds.push(elem.nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}

const dvm_agent = Dvm_NUnitIds.length;
%>


import common_knob_pkg::*;

class dve_buffer_error_seq extends dve_tacc_test_seq;
  `uvm_object_utils(dve_buffer_error_seq)
  function new(string name = "dve_buffer_error_seq");
    super.new(name);
  endfunction // new

  task body();
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event inject_single = ev_pool.get("dve_trace_mem_inject_single_error");
    super.body();
    fill_buffer();
    inject_single.trigger();
    drain_buffer();

  endtask // body
endclass // dve_buffer_error_seq
