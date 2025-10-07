class dve_coverage_seq;
    

    bit                snpreq_active;
    bit                snpreq_order;
    bit                snpreq_1_2_same_agt;
    bit                snprsp_order;
    bit                credit_alloc;
    bit                credit_dealloc;
    bit                cmprsp_gen;

    enum bit {idle_dtwReq_order,dtwReq_out_of_order} dtwReq_order;
covergroup snoop_manager;
  snprsp_outof_order: coverpoint snprsp_order {
     bins snprsp_order_bins   =  {1};
  }
  
endgroup:snoop_manager


covergroup dve_input_manager_process;
  cp_dtwReq_order : coverpoint dtwReq_order {

    ignore_bins  cp_idle_dtwReq_order       = {idle_dtwReq_order};   
    bins         cp_dtwReq_out_of_order     = {dtwReq_out_of_order};

  }
endgroup : dve_input_manager_process
    extern function new();
    extern function void collect_snprsp(bit snprsp_order);
    extern function void collect_dve_input_manager_process(bit dtwReq_order);
endclass: dve_coverage_seq

function void dve_coverage_seq::collect_snprsp (bit snprsp_order );
  this.snprsp_order = snprsp_order;
  snoop_manager.sample();
endfunction: collect_snprsp

function dve_coverage_seq::new();
    snoop_manager = new();
    dve_input_manager_process = new();
endfunction // new

function void dve_coverage_seq::collect_dve_input_manager_process(bit dtwReq_order);
  $cast(this.dtwReq_order,dtwReq_order);
  dve_input_manager_process.sample();
endfunction: collect_dve_input_manager_process
