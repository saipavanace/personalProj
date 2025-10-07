class auvm_scoreboard extends uvm_scoreboard;
    function new(string name="", uvm_component parent=null);
       super.new(name,parent);
    endfunction // new
   function void auvm_report_error(string label, string error_msg, int verbosity_level,string fail_code);
      uvm_report_info(label,error_msg,verbosity_level);
      triage_failure(fail_code);
   endfunction // auvm_report_error
   virtual function void triage_failure(string fail_code);
   endfunction // triage_failure
   
endclass : auvm_scoreboard
