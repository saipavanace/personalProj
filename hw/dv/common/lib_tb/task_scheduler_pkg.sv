////////////////////////////////////////////////////////////
//                                                        //
//Description: Provides a mechanism to schedule tasks and //
//             control sequence execution                 //
//                                                        //
//File:        task_scheduler_pkg.sv                      //
//                                                        //
////////////////////////////////////////////////////////////

package task_scheduler_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

class task_scheduler extends uvm_object;

  `uvm_object_utils(task_scheduler)

  static task_scheduler m_task_scheduler;

  //main task queue for all users
  protected uvm_event task_evt_q_array[string][$];
  protected int max_task_idx_length;
  protected int max_q_size = 1;

  //constructor
  extern function new(string s = "task_scheduler");
  
  //class Interface 
  extern static function task_scheduler get_instance();

  //add an event to the main task array
  extern function void task_schedule (string task_idx);//, integer timer_wait = 0);

  //wait for tigger of task start of execution
  extern task task_wait_start_exec(string task_idx);  

  //tigger end of execution of the task
  extern function void task_trig_end_exec(string task_idx);

  //create a dependancy between different tasks
  extern function void task_add_dependancy(string task_idx, string task_dep_list[]);

  //run task: create process for waiting and trigging events according to inter-dependancy array
  extern task run ();

  //printing tasks array
  extern function void print_scheduled_tasks();
endclass;

  //constructor
  function task_scheduler::new(string s = "task_scheduler");
    super.new(s);
  endfunction: new

  function task_scheduler task_scheduler::get_instance();
    if (m_task_scheduler == null)
      m_task_scheduler = new("m_task_scheduler");

    return m_task_scheduler;
  endfunction:get_instance

  function void task_scheduler::task_schedule (string task_idx);//, integer timer_wait = 0);
	if (!task_evt_q_array.exists(task_idx)) begin
    uvm_event task_evt = new(task_idx);
	  task_evt_q_array[task_idx].push_back(task_evt);
    //calculate maximum length of the task_id, that will be used for printing
    if (task_idx.len() > max_task_idx_length)
        max_task_idx_length = task_idx.len();
  end else begin
    `uvm_error("task_scheduler", $sformatf("error when adding %0s to scheduler. the task id is already used", task_idx))
  end
  endfunction

  //create a dependancy between different tasks
  function void task_scheduler::task_add_dependancy(string task_idx, string task_dep_list[]);
    int target_task_queue_size;
    string task_idy;
    if (!task_evt_q_array.exists(task_idx)) begin
      `uvm_error("task_scheduler", $sformatf("taskid %s is not found in the registred tasks:", task_idx))
      print_scheduled_tasks();
    end else if (task_dep_list.size() == 0) begin
      `uvm_error("task_scheduler", $sformatf("list of dependancies is empty"))
    end else begin
      target_task_queue_size = task_evt_q_array[task_idx].size();
      foreach (task_dep_list[i]) begin
        task_idy = task_dep_list[i];
	      if (task_evt_q_array.exists(task_idy)) begin
	        task_evt_q_array[task_idx].push_back(task_evt_q_array[task_idy][0]);
        end else begin
	        `uvm_error("task_scheduler", $sformatf("task dependancy %s to be added to %s is not found in the registered tasks", task_idy, task_idx))
          print_scheduled_tasks();
        end
      end //foreach
      //calculate maximum length of dependancy queue, that will be used for printing
      target_task_queue_size = task_evt_q_array[task_idx].size();
      if ((target_task_queue_size) > max_q_size)
        max_q_size = target_task_queue_size;
    end //last else
  endfunction
  

  //wait for tigger of task start of execution
  task task_scheduler::task_wait_start_exec(string task_idx);  
    uvm_event task_idx_evt = task_evt_q_array[task_idx][0];
    `uvm_info("task_scheduler", $sformatf("Waiting for start of execution trigger of taskid= %0s", task_idx_evt.get_name()), UVM_NONE)
    task_idx_evt.wait_on();
  endtask

  //tigger end of execution of the task
  function void task_scheduler::task_trig_end_exec(string task_idx);
    uvm_event task_idx_evt = task_evt_q_array[task_idx][0];
    `uvm_info("task_scheduler", $sformatf("trigging end of execution trigger of taskid= %0s", task_idx_evt.get_name()), UVM_NONE)
    task_idx_evt.reset();
  endfunction


  //run task: create process for waiting and trigging events according to inter-dependancy array
  task task_scheduler::run();
     //`uvm_info("task_scheduler", $sformatf("run events in %p ",task_evt_q_array),UVM_NONE)
     foreach (task_evt_q_array[task_idx]) begin
      `uvm_info("task_scheduler", $sformatf("%0s events queue processes will be created", task_idx),UVM_NONE)
      fork: task_evt_q_array_queue
        automatic string task_idx_l = task_idx;
        automatic uvm_event task_dep_evt_q[$] = task_evt_q_array[task_idx_l];
        //check if there is a dependancy
        begin
          if (task_dep_evt_q.size() > 1) begin
            `uvm_info("task_scheduler", $sformatf("%0s has %0d dependancies", task_idx_l,(task_dep_evt_q.size()-1)),UVM_NONE)
		        for (int i=1; i< task_dep_evt_q.size(); i++) begin: queue_loop
              fork: fork_task_idx_queue
		            automatic int evt_indx=i;
                uvm_event task_depend_evt = task_dep_evt_q[evt_indx];
                begin
                  //wait for the trig from scheduler for 1st time
                  `uvm_info("task_scheduler", $sformatf("Wait for %0s start of execution trigger", task_depend_evt.get_name()),UVM_NONE)
                  task_depend_evt.wait_on();
                  //wait for the trig from task executer
                  `uvm_info("task_scheduler", $sformatf("Wait for %0s end of execution trigger", task_depend_evt.get_name()),UVM_NONE)
                  task_depend_evt.wait_off();
                  `uvm_info("task_scheduler", $sformatf("%0s end of execution event was trigged", task_depend_evt.get_name()),UVM_NONE)
                end
              join_none: fork_task_idx_queue
		        end: queue_loop
            wait fork;
          end
          //trig the execution of the task by the executer
          task_dep_evt_q[0].trigger();
          `uvm_info("task_scheduler", $sformatf("%0s[0] event is trigged for start of execution", task_idx_l),UVM_NONE)
        end
      join_none: task_evt_q_array_queue
     end //foreach loop
    wait fork;
    `uvm_info("task_scheduler", $sformatf("ending scheduler run task"), UVM_NONE)
  endtask

  //printing tasks array
  function void task_scheduler::print_scheduled_tasks();
		string header_line, line_separator;
    string fmt = $sformatf(" %%-%0ds ", max_task_idx_length);
    `uvm_info("task_scheduler", $sformatf("\n List of scheduled tasks"), UVM_NONE)
    repeat(max_q_size*(max_task_idx_length+3)+1) line_separator = {line_separator,"="};
    $display("%s",line_separator);
    header_line = {"|",$sformatf(fmt, "task_idx"),"|"};
    if (max_q_size>1) header_line = {header_line,$sformatf($sformatf("%%-%0ds",((max_q_size-1)*(max_task_idx_length+3)-1))," dependancies"),"|"};
    $display("%s",header_line);
    $display("%s",line_separator);
    foreach (task_evt_q_array[task_idx]) begin
      string task_line = {"|",$sformatf(fmt, task_idx),"|"};
      uvm_event task_dep_evt_q[$] = task_evt_q_array[task_idx];
      int queue_size = task_dep_evt_q.size();
      if (queue_size > 1) begin
		    for (int i=1; i< queue_size; i++) begin
          task_line = {task_line,$sformatf(fmt, task_dep_evt_q[i].get_name())};
          if (i == queue_size - 1) task_line = {task_line,$sformatf($sformatf("%%%0ds", (max_q_size-queue_size)*(max_task_idx_length+3)+1), "|")};
          else task_line = {task_line,"&"};
        end
      end else if (max_q_size>1) begin
        task_line = {task_line,$sformatf($sformatf("%%%0ds", (max_q_size-1)*(max_task_idx_length+3)), "|")};
      end
      $display("%s",task_line);
    end
    $display("%s",line_separator);
  endfunction
endpackage: task_scheduler_pkg