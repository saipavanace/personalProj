`ifndef GUARD_NCORE_BASE_TEST_SV
`define GUARD_NCORE_BASE_TEST_SV


//Callback reporter message displayed on timeout
class timeout_catcher extends uvm_report_catcher;
  uvm_phase m_run_phase;
 `uvm_object_utils(timeout_catcher)

  // Class Constructor
  function new (string name="timeout_catcher");
    super.new (name);
  endfunction : new

  function action_e catch();
    if(get_severity() == UVM_FATAL && get_id() == "HBFAIL") begin
      uvm_objection obj = m_run_phase.get_objection();
      `uvm_error("HBFAIL", $psprintf("Heartbeat failure! Objections:"));
      obj.display_objections();
    end
  return THROW;
  endfunction
endclass

class my_report_server extends uvm_default_report_server;

   function new(string name = "my_report_server");
    super.new();
   endfunction
 
   virtual function void report_summarize(UVM_FILE file = 0);
   uvm_report_server svr;
    string id;
    string name;
    string output_str;
    string q[$],q2[$];
    int m_max_quit_count,m_quit_count;
    int m_severity_count[uvm_severity];
    int m_id_count[string];
    bit enable_report_id_count_summary =1 ;
    uvm_severity q1[$];

    svr = uvm_report_server::get_server();
    m_max_quit_count = get_max_quit_count();
    m_quit_count = get_quit_count();

    svr.get_id_set(q2);
    foreach(q2[s])
      m_id_count[q2[s]] = svr.get_id_count(q2[s]);

    svr.get_severity_set(q1);
    foreach(q1[s])
      m_severity_count[q1[s]] = svr.get_severity_count(q1[s]);


    uvm_report_catcher::summarize();
    q.push_back("\n--- UVM Report Summary ---\n\n");

    if(m_max_quit_count != 0) begin
      if ( m_quit_count >= m_max_quit_count )
        q.push_back("Quit count reached!\n");
      q.push_back($sformatf("Quit count : %5d of %5d\n",m_quit_count, m_max_quit_count));
    end

    q.push_back("** Report counts by severity\n");
    foreach(m_severity_count[s]) begin
      q.push_back($sformatf("%s :%5d\n", s.name(), m_severity_count[s]));
    end

    if (enable_report_id_count_summary) begin
      q.push_back("** Report counts by id\n");
      foreach(m_id_count[id])
        q.push_back($sformatf("[%s] %5d\n", id, m_id_count[id]));
    end

    `uvm_info("UVM/REPORT/SERVER",`UVM_STRING_QUEUE_STREAMING_PACK(q),UVM_NONE)

  endfunction


endclass

class ncore_base_test extends uvm_test;

   //UVM Component Utility macro
  `uvm_component_utils (ncore_base_test)

  //Instance of the environment
  ncore_env env;
  
  //NCORE System Configuration
  ncore_vip_configuration cfg;

  // Class Constructor
  function new (string name="ncore_base_test", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new

  //  Build Phase
  //  Create and apply the customized configuration transaction factory
  //  Create the TB ENV
  //  Set the default sequences

  virtual function void build_phase(uvm_phase phase);
    `uvm_info("build_phase", "is entered",UVM_LOW)
    super.build_phase(phase);

    // Create the environment class 
    env = ncore_env::type_id::create ("env", this);
    
    // Create the NCORE configuration
    cfg = ncore_vip_configuration::type_id::create("cfg");

    // set NCORE system Configuration
    cfg.set_amba_sys_config();


    //Apply the configuration to the NCORE system ENV 
    uvm_config_db#(ncore_vip_configuration)::set(this, "env", "cfg", cfg);
    
    //Display the configuration
    `uvm_info("body", $sformatf("The NCORE system configuration is: \n%0s", cfg.sprint()), UVM_LOW)

    `uvm_info("build_phase", "is exited",UVM_LOW)
  endfunction : build_phase


  function void end_of_elaboration_phase(uvm_phase phase);
    `uvm_info("end_of_elaboration_phase", "is entered",UVM_LOW)
    super.end_of_elaboration_phase(phase);
  
    // Display the topology 
    uvm_top.print_topology();

    `uvm_info("end_of_elaboration_phase", "is exited",UVM_LOW)
  endfunction : end_of_elaboration_phase

  function void start_of_simulation_phase(uvm_phase phase);
  `ifndef UVM_VERSION_1_1
    my_report_server my_server = new;
  `endif

    `uvm_info("start_of_simulation_phase", "is entered",UVM_LOW)
    super.start_of_simulation_phase(phase);
     
  `ifndef UVM_VERSION_1_1
    uvm_report_server::set_server( my_server );
  `endif

    `uvm_info("start_of_simulation_phase", "is exited",UVM_LOW)
  endfunction :start_of_simulation_phase
  

  function void final_phase(uvm_phase phase);
    uvm_report_server svr;

    `uvm_info("final_phase", "is entered",UVM_LOW)
    super.final_phase(phase);
    svr = uvm_report_server::get_server();
      
    if (svr.get_severity_count(UVM_FATAL) +
      svr.get_severity_count(UVM_ERROR) > 0)
      $display("\n NCORE TEST RESULT: Failed\n");
    else
      $display("\n NCORE TEST RESULT: Passed\n");
    `uvm_info("final_phase", "is exited",UVM_LOW)
  endfunction

//----------------------------------------------------
 
endclass
`endif //GUARD_NCORE_BASE_TEST_SV
