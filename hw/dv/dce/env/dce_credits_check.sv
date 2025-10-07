//////////////////////////////////////////////////////////////
//
//Class: Credit checks
//       This class has handle to
//       $WORK_TOP/dv/common/lib_tb/credit_maint_pkg.sv
//       Credits initialization at run time.
//////////////////////////////////////////////////////////////

class dce_credits_check extends uvm_object;

    //Credits per block per message type.
    //Indexed {msg, obj.Id} string. 
    int credits_available[string];
    int max_credits[string];

    //handle to credit_maint_pool class. We invoke
    //ncore_credits_initialization() to get all credits
    //and then covert to credits_available format.
    credit_maint_pool m_credit_pool;

    //Factory initializatiion
    `uvm_object_param_utils(dce_credits_check)

    extern function new(string name = "dce_credits_check");
    extern function void initialize_credits(const ref creditp_init_t credits_flow_list[$]);
    extern function void get_max_credit(string name, output int max_credit);
    extern function void get_credit(string name, output int credits_remaining);
    extern function void put_credit(string name, output int credits_remaining);
    extern function void scm_credit(string name, input int new_credit);

endclass: dce_credits_check

//Constructor method
//initializes ncore credits to credits_available property
function dce_credits_check::new(string name = "dce_credits_check");
    creditp_init_t credits_flow_list[$];

    super.new(name);
    m_credit_pool = credit_maint_pool::GetInstance();
    m_credit_pool.ncore_credits_initialization(credits_flow_list);
    initialize_credits(credits_flow_list);
endfunction: new

//initialize credits
function void dce_credits_check::initialize_credits(
    const ref creditp_init_t credits_flow_list[$]);
    foreach(credits_flow_list[idx]) begin
        credits_available[credits_flow_list[idx].name] = credits_flow_list[idx].max_credit_val;
       `uvm_info(get_name(), $psprintf("[%-35s] {%40s : %4d}", "DceCredit-Init", credits_flow_list[idx].name, credits_available[credits_flow_list[idx].name]), UVM_NONE);
        max_credits[credits_flow_list[idx].name] = credits_flow_list[idx].max_credit_val;
    end
endfunction: initialize_credits

function void dce_credits_check::scm_credit(string name, input int new_credit);
	if(!credits_available.exists(name)) begin
        	`uvm_info("DCE SCB", $psprintf("Unexpected string %s passed to scm_credit() method", name), UVM_NONE)
        	`uvm_error("DCE SCB","scm_credit() method call failed")
    	end
	if(new_credit > max_credits[name]) begin
		credits_available[name] = credits_available[name] + (new_credit - max_credits[name]);
		max_credits[name] = new_credit;
	end
	if(new_credit < max_credits[name]) begin
		credits_available[name] = credits_available[name] + (new_credit - max_credits[name]);
		max_credits[name] = new_credit;
	end
   `uvm_info(get_name(), $psprintf("[%-35s] {%40s : %4d / %4d} (newCredit: %4d)", "DceCredit-SCM", name, credits_available[name], max_credits[name], new_credit), UVM_NONE);
endfunction: scm_credit

function void dce_credits_check::get_max_credit(string name, output int max_credit);
    if(!credits_available.exists(name)) begin
        `uvm_info("DCE SCB", $psprintf("Unexpected string %s passed to get_max_credit() method", name), UVM_NONE)
        `uvm_error("DCE SCB","get_max_credit() method call failed")
    end
    max_credit = max_credits[name];
    //`uvm_info("DCE SCB", $psprintf("SMI packet with message type %s received. Max credits configured :%0d", name, max_credits[name]), UVM_NONE)
endfunction: get_max_credit

//get_credit method decrements specific credit count value indexed by {msg, Id}
//if credit count value is already 0 then triggers failure
function void dce_credits_check::get_credit(string name, output int credits_remaining);
    //check-1
    if(!credits_available.exists(name)) begin
        `uvm_info("DCE SCB", $psprintf("Unexpected string %s passed to get_credit() method", name), UVM_NONE)
        `uvm_error("DCE SCB","get_credit() method call failed")
    end
    
    //check-2
    if(credits_available[name] == 0) begin
        `uvm_info("DCE SCB", $psprintf("SMI packet with message type %s received after all credits are used", name), UVM_NONE)
         $stacktrace();
        `uvm_error("DCE SCB","No credits available for received SMI packet")
    end
    
    credits_available[name]--;
    credits_remaining = credits_available[name];
   `uvm_info(get_name(), $psprintf("[%-35s] {%40s : %4d / %4d}", "DceCredit-Get", name, credits_available[name], max_credits[name]), UVM_HIGH);
    //`uvm_info("DCE SCB", $psprintf("SMI packet with message type %s received. Number of credits available:%0d", name, credits_available[name]), UVM_NONE)
endfunction: get_credit

//put_redit method increments specific credit count value indexed by {msg, Id}
//after response is recived
function void dce_credits_check::put_credit(string name, output int credits_remaining);
    
    //check-1
    if(!credits_available.exists(name)) begin
        `uvm_info("DCE SCB", $psprintf("Unexpected string %s passed to put_credit() method", name), UVM_NONE)
        `uvm_error("DCE SCB","put_credit() method call failed")
    end

    credits_available[name]++;
    credits_remaining = credits_available[name];
   `uvm_info(get_name(), $psprintf("[%-35s] {%40s : %4d / %4d}", "DceCredit-Put", name, credits_available[name], max_credits[name]), UVM_HIGH);
    //`uvm_info("DCE SCB", $psprintf("SMI packet with message type %s received. Number of credits available:%0d", name, credits_available[name]), UVM_NONE)
endfunction: put_credit

