//
//    Helper classes for dce_unit_test
//

class dce_report_test_status extends uvm_object;

     `uvm_object_utils(dce_report_test_status)

     dce_env m_env;

    function new(string name = "dce_report_test_status");
        super.new(name);
    endfunction: new

    function void report_results();
  
        //`uvm_info("", "Entered report results function", UVM_NONE);
        //if(m_env.m_cfg.has_dirm_scoreboard) begin
        //    m_env.m_dirm_scb.active_att_snapshot();
        //end
        if(m_env.m_env_cfg.has_scoreboard) begin
            m_env.m_dce_scb.print_pend_txns();
        end
    endfunction: report_results

    function void print_status();
        int error_count, fatal_count;
        uvm_report_server m_urs;

        //`uvm_info("", "Entered print_status function", UVM_NONE);
        m_urs = uvm_report_server::get_server();
        error_count = m_urs.get_severity_count(UVM_ERROR);
        fatal_count = m_urs.get_severity_count(UVM_FATAL);

        if((error_count != 0) || (fatal_count != 0)) begin
            `uvm_info("", "\n===================================================================", UVM_NONE);
            $display("UVM FAILED!");
            $display("===================================================================");
        end else begin
            $display("\n===================================================================");
            $display("UVM PASSED!");
            $display("===================================================================");
        end
    endfunction: print_status
endclass: dce_report_test_status

//Callback reporter message displayed on timeout
class dce_timeout_catcher extends uvm_report_catcher;

    uvm_phase phase;
    dce_report_test_status m_reporter;
    `uvm_object_utils(dce_timeout_catcher)

    function new(string name = "dce_timeout_catcher");
        super.new(name);
    endfunction: new

    function action_e catch();
        if(get_severity() == UVM_FATAL && get_id == "HBFAIL") begin
            uvm_objection obj = phase.get_objection();

            //$display("TEST HBFAIL %s %s", get_id(), get_full_name());
            obj.display_objections();

            m_reporter.report_results();
            `uvm_error("HBFAIL", $psprintf("Heart Beat Failure Objection:"));
            m_reporter.print_status();
            `uvm_fatal("HBFAIL", $psprintf("Heart Beat Failure Objection:"));
        end
        else if(get_severity() == UVM_ERROR) begin
            //Debug helper message:
            //$display("TEST ERROR %s %s", get_id(), get_full_name());
            m_reporter.report_results(); //#Check.DCE.HBTimeout_PendingTxns
            
            //TODO: I want status to be printed after UVM_ERROR message. Work on this later.
            //m_reporter.print_status();
            
            uvm_report_error(get_id(), get_message(), UVM_NONE);
        end
        else if(get_severity() == UVM_FATAL) begin
            uvm_objection obj = phase.get_objection();
            
            //$display("TEST FATAL %s %s", get_id(), get_full_name());
            obj.display_objections();

            m_reporter.report_results();
            uvm_report_error(get_id(), get_message(), UVM_NONE);
            m_reporter.print_status();
        end
 
        return(THROW);
   endfunction: catch

endclass: dce_timeout_catcher
