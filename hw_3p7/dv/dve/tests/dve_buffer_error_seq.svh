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
