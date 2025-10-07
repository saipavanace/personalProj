class concerto_placeholder_test extends concerto_base_test;
    event kill_test;
    uvm_object objectors_list[$];
    uvm_objection objection;

   
//    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_placeholder_test)

    //////////////////
    //Methods
    //////////////////
    extern function new(string name = "concerto_placeholder_test", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase  phase);
    //extern virtual function void connect_pahse(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);

    extern virtual function void report_phase(uvm_phase phase);
    extern virtual function void print_status();

  //  extern function void parse_str(output string out[], input byte separator, input string in);

endclass: concerto_placeholder_test


function concerto_placeholder_test::new(string name = "concerto_placeholder_test", uvm_component parent = null);
    super.new(name, parent);
endfunction: new


function void concerto_placeholder_test::build_phase(uvm_phase phase);
    string msg_idx;
    `uvm_info("Build", "Entered Build Phase", UVM_LOW);
    super.build_phase(phase);
endfunction: build_phase

function void concerto_placeholder_test::end_of_elaboration_phase(uvm_phase phase);
    int file_handle;
    `uvm_info("end_of_elaboration_phase", "Entered...", UVM_LOW)
    if (this.get_report_verbosity_level() > UVM_LOW) begin
        uvm_top.print_topology();
    end
    `uvm_info("end_of_elaboration_phase", "Exiting...", UVM_LOW)
endfunction: end_of_elaboration_phase

task concerto_placeholder_test::run_phase(uvm_phase phase);
   //super.run_phase(phase);
   `uvm_info("FULLSYS_TEST", "Starting concerto_placeholder_test::exec_inhouse_seq ...", UVM_LOW)
 
 //  <% if(obj.useResiliency) { %>
 //   if (!uvm_config_db#(event)::get(this,
 //                                  .inst_name ( "" ),
 //                                  .field_name( "kill_test" ),
 //                                  .value( kill_test ))) begin
 //      `uvm_error( "fsys_test run_phase", "kill_test event not found" )
 //   end
 //   fork
 //      begin
 //         `uvm_info("run_main", "waiting for kill_test event to trigger",UVM_NONE)
 //          phase.raise_objection(this, "concerto_placeholder_test");
 //          @kill_test;
 //          phase.drop_objection(this, "concerto_placeholder_test");
 //      end
 //   join
 //  <% } %>
 
   `uvm_info("FULLSYS_TEST", "Finish concerto_placeholder_test ...", UVM_LOW)
endtask: run_phase

function void concerto_placeholder_test::report_phase(uvm_phase phase);
   print_status();
endfunction : report_phase


function void concerto_placeholder_test::print_status();
        int error_count, fatal_count;
        uvm_report_server m_urs;

        m_urs = uvm_report_server::get_server();
            `uvm_info("TEST","..Closing file\n", UVM_MEDIUM);
       
        error_count = m_urs.get_severity_count(UVM_ERROR);
        fatal_count = m_urs.get_severity_count(UVM_FATAL);

        if((error_count != 0) | (fatal_count != 0)) begin
            $display("\n===================================================================");
            $display("UVM FAILED!");
            $display("===================================================================");
        end else begin
            $display("\n===================================================================");
            $display("UVM PASSED!");
            $display("===================================================================");
        end
endfunction: print_status

