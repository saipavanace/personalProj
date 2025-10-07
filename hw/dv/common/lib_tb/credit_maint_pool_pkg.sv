//////////////////////////////////////////////////////////////
//
//class: credit_maint_pool.svh
//Details:
//       Generic API for allocating and mainting credits.
//       This can be used by any environment
//////////////////////////////////////////////////////////////

package <%=obj.BlockId%>_credit_maint_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

typedef struct {
  string name;
  int max_credit_val;
} creditp_init_t;

typedef struct {
  int max_credits;
  int credits_available;
} creditp_maint_t;

class credit_semaphore extends uvm_object;

  local semaphore e_sem;

  `uvm_object_param_utils(credit_semaphore)

  function new(string name = "credit_semaphore");
    super.new(name);
    e_sem = new(1);
  endfunction: new

  task request_lock();
    `uvm_info("credit_semaphore", $psprintf("requesting lock for %s", this.get_name()), UVM_HIGH)
    e_sem.get(1);
    `uvm_info("credit_semaphore", $psprintf("lock granted for %s", this.get_name()), UVM_HIGH)
  endtask: request_lock

  task release_lock();
    e_sem.put(1);
    `uvm_info("credit_semaphore", $psprintf("released lock for %s", this.get_name()), UVM_HIGH)
  endtask: release_lock

endclass: credit_semaphore

class credit_maint_pool extends uvm_object;

  `uvm_object_param_utils(credit_maint_pool)

  //Properties
  local creditp_init_t  max_credits_per_pkt[$];
  local creditp_maint_t credit_maint_pool_s[string];
  local credit_semaphore m_semaphore[string];

  local int  lkup_period;
  local int timeout_cnt;

  local static credit_maint_pool m_handle;

  //interface Methods
  extern static function credit_maint_pool GetInstance();
  extern function void initialize_credits(ref creditp_init_t load_credits[$]);
  extern task get_credit(string name, output int credits_available);
  extern function void put_credit(string name, output int credits_available);
  extern function int peek_credits_available(string name);
  extern function void set_lkup_period_in_ns(int lkup_period = 10);
  extern function void set_timeout(int timeout_cnt = 100000);
  extern function void ncore_credits_initialization(
      ref creditp_init_t credits_flow_list[$]);

  //local methods
 <% if(obj.testBench == 'dce' || obj.testBench == 'fsys') { %>
 `ifndef VCS
  extern local function new(string name = "credit_maint_pool");
 `else // `ifndef VCS
  extern function new(string name = "credit_maint_pool");
 `endif // `ifndef VCS ... `else ... 
 <% } else {%>
  extern local function new(string name = "credit_maint_pool");
 <% } %>
  extern function void credit_flow_exists(string name);
  extern task block_until_credits_are_available(string name);
endclass: credit_maint_pool

function credit_maint_pool::new(string name = "credit_maint_pool");
  creditp_init_t load_credits[$];

  super.new(name);
  lkup_period = 10;
  timeout_cnt = 100000;
  ncore_credits_initialization(load_credits);
  initialize_credits(load_credits);
endfunction: new

function credit_maint_pool credit_maint_pool::GetInstance();
  if(m_handle == null)
      m_handle = new("credit_maint_pool");

  return(m_handle);
endfunction: GetInstance

//Provided value is multiplied by 1ns and is polled for every lkup_period ns
function void credit_maint_pool::set_lkup_period_in_ns(int lkup_period = 10);
  this.lkup_period = lkup_period;
endfunction: set_lkup_period_in_ns

//Provided value determines when to timeout or specifies how many times
//to poll for credit availablility before timeing out
//deault wait time is 5000nsec
function void credit_maint_pool::set_timeout(int timeout_cnt = 100000);
  this.timeout_cnt = timeout_cnt;
endfunction: set_timeout

function void credit_maint_pool::initialize_credits(
                                   ref creditp_init_t load_credits[$]);
  foreach(load_credits[idx]) begin
    credit_maint_pool_s[load_credits[idx].name].max_credits = 
    load_credits[idx].max_credit_val;

    credit_maint_pool_s[load_credits[idx].name].credits_available = load_credits[idx].max_credit_val;

    m_semaphore[load_credits[idx].name] =
    credit_semaphore::type_id::create(
      $sformatf("sem_%s", load_credits[idx].name));
  end

endfunction: initialize_credits

//remove credit from credit pool
task credit_maint_pool::get_credit( string name, output int credits_available);
  //Request Exclusive access
  if (m_semaphore.exists(name))
      m_semaphore[name].request_lock();
  else
      `uvm_fatal("credit_maint_pool", $psprintf("key:%s does not exist", name))

  //Only one will caller get access to this to poll for credit. 
  //All other requests are blocked until current request gets the credit..
  credit_flow_exists(name);
  if(credit_maint_pool_s[name].credits_available == 0) begin
      block_until_credits_are_available(name);
  end
  credit_maint_pool_s[name].credits_available--;
  credits_available = credit_maint_pool_s[name].credits_available;

  //putting back the keys for other processes to access.
  m_semaphore[name].release_lock();
endtask: get_credit

//put credit back into credit pool
function void credit_maint_pool::put_credit(string name, output int credits_available);
  string s;

  credit_maint_pool_s[name].credits_available++;
  if(credit_maint_pool_s[name].credits_available >
     credit_maint_pool_s[name].max_credits) begin

    $sformat(s, "%s Tb_error: for credit name:%s putting ",
             s, name);
    $sformat(s,
            "%s more credits than total number of credits. (%0d > %0d)",
             s, 
             credit_maint_pool_s[name].max_credits,
             credit_maint_pool_s[name].credits_available);
    `uvm_fatal("credit_maint_pool", s)
  end
  credits_available = credit_maint_pool_s[name].credits_available;
endfunction: put_credit

//retrun number of available credits for given 
function int credit_maint_pool::peek_credits_available(string name);
  return(credit_maint_pool_s[name].credits_available);
endfunction: peek_credits_available

//check if indexing key is right
function void credit_maint_pool::credit_flow_exists(string name);
  string s;

  if(!credit_maint_pool_s.exists(name)) begin
    $sformat(s,
             "%s TbError credit_type:%s does not exist. ", s, name);
    $sformat(s, "%s Existing credit pools are:\n", s);
    foreach(max_credits_per_pkt[idx])
      $sformat(s, "%s credit pool type:%s", s, max_credits_per_pkt[idx].name);

    `uvm_fatal("credit_maint_pool", s)
  end
endfunction: credit_flow_exists

task credit_maint_pool::block_until_credits_are_available(string name);
  for(int i = 0; i < timeout_cnt; i++) begin
    #(lkup_period * 1ns);
    if(credit_maint_pool_s[name].credits_available) begin
      `uvm_info("credit_maint_pool", $psprintf("credits for name:%s are available", name), UVM_MEDIUM)
      break;
    end else if(i == timeout_cnt -1) begin
      `uvm_fatal("credit_maint_pool", $psprintf("waited %0d ns for credit name:%s", (timeout_cnt * lkup_period), name))
    end
  end
endtask: block_until_credits_are_available

//method reads credit parameter values from config and initializes the         
//credit_maint_pool class.
function void credit_maint_pool::ncore_credits_initialization(ref creditp_init_t credits_flow_list[$]);

  creditp_init_t credits_flow;
  int cmd_credits;
	
  cmd_credits = <%=obj.DceInfo[0].nCMDSkidBufSize%> - ((<%=obj.DceInfo[0].nAius%> - <%=obj.DceInfo[0].nCachingAgents%>) * 2);
  while((cmd_credits % <%=obj.DceInfo[0].nCachingAgents%>) != 0) begin
  	cmd_credits = cmd_credits - 1;
  end
      `uvm_info("credit_maint_pool", $psprintf("credits for Coherent AIUs: %d and per AIU: %d", cmd_credits, cmd_credits/<%=obj.DceInfo[0].nCachingAgents%>), UVM_LOW)

//Aiu Credits
<% obj.AiuInfo.forEach(function(bundle_aiu) {
%>
	<% if(bundle_aiu.useCache || bundle_aiu.fnNativeInterface == "ACE" || bundle_aiu.fnNativeInterface == "CHI-A" || bundle_aiu.fnNativeInterface == "CHI-B"|| bundle_aiu.fnNativeInterface == "CHI-E") { %>			
	credits_flow.name = "aiu<%=bundle_aiu.FUnitId%>_nCmdInFlight";
	credits_flow.max_credit_val = cmd_credits/<%=obj.DceInfo[0].nCachingAgents%>;
	credits_flow_list.push_back(credits_flow);
	<%}
	else { %>
	credits_flow.name = "aiu<%=bundle_aiu.FUnitId%>_nCmdInFlight";
	credits_flow.max_credit_val = 2;
	credits_flow_list.push_back(credits_flow);
	<%}%>
	

<% 	});
%>


//Snp Credits
<% obj.DceInfo.forEach(function(bundle_dce) {
	 obj.AiuInfo.forEach(function(bundle_aiu) {
%>			
       credits_flow.name = "dce<%=bundle_dce.FUnitId%>_aiu<%=bundle_aiu.FUnitId%>_nSnpInFlight";
       credits_flow.max_credit_val = <%=bundle_dce.nSnpsPerAiu%>;
       credits_flow_list.push_back(credits_flow);

<% 	});
	});

%>

//Mrd Credits
<% obj.DceInfo.forEach(function(bundle_dce) {
	 obj.DmiInfo.forEach(function(bundle_dmi) {
%>			
       credits_flow.name = "dce<%=bundle_dce.FUnitId%>_dmi<%=bundle_dmi.FUnitId%>_nMrdInFlight"; //Ignore MrdInFlight this is only string used in DCE
       <%if(bundle_dmi.nMrdSkidBufSize > 31) {%>
       credits_flow.max_credit_val = 30;
	<%}
	else {%>
       credits_flow.max_credit_val = <%=bundle_dmi.nMrdSkidBufSize%>;
	<%}%>
	
       credits_flow_list.push_back(credits_flow);

<% 	});
	});

%>


endfunction: ncore_credits_initialization



endpackage: <%=obj.BlockId%>_credit_maint_pkg
