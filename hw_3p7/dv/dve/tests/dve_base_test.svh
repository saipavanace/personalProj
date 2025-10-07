
import common_knob_pkg::*;


//Display outstanding objections upon hbfail.
class timeout_catcher extends uvm_report_catcher;
    uvm_phase phase;

    `uvm_object_utils(timeout_catcher)

<% if(obj.testBench == 'dve') { %>
 `ifdef CDNS
    function new(string name = "timeout_catcher");
        super.new(name);
    endfunction: new
 `endif 
<% }  %>
<% if(obj.testBench == 'dve') { %>
 `ifdef VCS 
// Add for UVM-1.2 compatibility
 // `ifdef UVM_VER_1_2
  function new (string name="timeout_catcher",uvm_component parent=null);
    super.new (name);
  endfunction : new
 //`endif 
 `endif 
<% }  %>
    function action_e catch();
        if(get_severity() == UVM_FATAL && get_id() == "HBFAIL") begin
            uvm_objection obj = phase.get_objection();
            `uvm_error("HBFAIL", $psprintf("Heartbeat failure! Objections:"));
            obj.display_objections();
        end
        return THROW;
    endfunction

endclass

<% if(obj.testBench == 'dve') { %>
 `ifdef VCS 
// Add for UVM-1.2 compatibility
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
`endif 
<% }  %>


class dve_base_test extends uvm_test;

function new (string name = "dve_base_test", uvm_component parent = null);
super.new(name,parent);
endfunction : new

function void start_of_simulation_phase(uvm_phase phase);
<% if(obj.testBench == 'dve') { %>
 `ifdef VCS 
 // `ifdef UVM_VER_1_2
    my_report_server my_server = new();
 // `endif
  `endif
<% } %>
    super.start_of_simulation_phase(phase);

<% if(obj.testBench == 'dve') { %>
 `ifdef VCS 
 // `ifdef UVM_VER_1_2
    uvm_report_server::set_server( my_server );
 //`endif
  `endif
<% } %>
endfunction : start_of_simulation_phase

endclass