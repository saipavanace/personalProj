interface <%=obj.BlockId%>_clock_counter_if(input clk, input rst_n);
  import uvm_pkg::*;

  parameter setup_time = 0;
  parameter hold_time  = 0;

  longint cycle_counter;
  time   current_time;
  logic [127:0] probe_sig1;
   
  clocking monitor_cb @(negedge clk);
    default input #setup_time output #hold_time;

     input rst_n;     
  endclocking : monitor_cb

initial begin
	cycle_counter 	 <= 0;
   	forever begin
        @(monitor_cb)
        cycle_counter <= cycle_counter + 1;
        current_time  <= $time;   
	end
end

function longint get_cycle_count();
	return cycle_counter;
endfunction: get_cycle_count

function time get_current_time();
	return current_time;
endfunction: get_current_time

function logic[127:0] get_probe_sig1();
	return probe_sig1;
endfunction: get_probe_sig1

endinterface : <%=obj.BlockId%>_clock_counter_if
