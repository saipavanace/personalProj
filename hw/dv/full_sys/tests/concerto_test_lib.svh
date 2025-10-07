
////////////////////////////////////////////////////////////////////////////////
//
<% if (1 == 0) { %>
// Author: Satya Prakash
<% } %>
//
////////////////////////////////////////////////////////////////////////////////

<%

var numChiAiu = 0; // Number of CHI AIUs
var numACEAiu = 0; // Number of ACE AIUs
var numIoAiu = 0; // Number of IO AIUs
var numCAiu = 0; // Number of Coherent AIUs
var numNCAiu = 0; // Number of Non-Coherent AIUs
var numAiuRpns = 0;   //Total AIU RPN's
var initiatorAgents   = obj.AiuInfo.length ;
var aiu_NumCores = [];
var aiu_NumPorts =0;
 for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(obj.AiuInfo[pidx].nNativeInterfacePorts) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].nNativeInterfacePorts;
       aiu_NumPorts          += obj.AiuInfo[pidx].nNativeInterfacePorts;
   } else {
       aiu_NumCores[pidx]    = 1;
       aiu_NumPorts++;
   }
 }

// Assuming CHI AIU will appear first in AiuInfo in top.level.dv.json before IO-AIUs
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-B")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) 
       { 
       numChiAiu++ ; numCAiu++ ; 
       }
    else
       { 
         numIoAiu++ ; 
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { 
            numCAiu++; numACEAiu++; 
         } else {
            numNCAiu++ ;
         }
       }
    if(obj.AiuInfo[pidx].nNativeInterfacePorts) {
       numAiuRpns += obj.AiuInfo[pidx].nNativeInterfacePorts;
    } else {
       numAiuRpns++;
    }
}
%>
/*
<%  if((obj.INHOUSE_APB_VIP)|| (obj.useResiliency)) { %>
import apb_agent_pkg::*;
<%  } %>


class concerto_fullsys_ralgen_bitbash_test extends concerto_base_test;
    `uvm_component_utils(concerto_fullsys_ralgen_bitbash_test)

     uvm_reg_bit_bash_seq   csr_seq;
<%  if(obj.INHOUSE_APB_VIP) { %>
    apb_agent_config       m_apb_cfg;
<%  } %>

 <% if(obj.useResiliency) { %>
  apb_agent_config       m_fc_apb_cfg;
 <% } %>
    
    

    function new(string name = "concerto_fullsys_ralgen_bitbash_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction 

    function void build_phase(uvm_phase phase);
        string msg_idx;
        `uvm_info("Build", "Entered Build Phase", UVM_LOW);
        super.build_phase(phase);
       
        //Disable All coverage for RALGEN
        uvm_config_db#(bit)::set(uvm_root::get(),"*", "include_coverage", 0);


<%  if((obj.INHOUSE_APB_VIP)) { %>
        m_apb_cfg  = apb_agent_config::type_id::create("m_apb_cfg",  this);
        m_concerto_env_cfg.m_apb_cfg  = m_apb_cfg;
<%  } %>

    <% if(obj.useResiliency) { %>
        m_fc_apb_cfg  = apb_agent_config::type_id::create("m_fc_apb_cfg",  this);
        m_concerto_env_cfg.m_fc_apb_cfg  = m_fc_apb_cfg;
    <% } %>


        set_inactivity_period(m_args.k_timeout);
        `uvm_info("Build", "Exited Build Phase", UVM_LOW);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // these registers excluded from bit bash, these register are maintenance op for Cache. once we write  any valid opcode on these registers
  // R/W access to these register blocked till maintenance operation complete 
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  

    
        `uvm_info("run_phase", "Entered...", UVM_LOW)

        csr_seq = uvm_reg_bit_bash_seq::type_id::create("csr_seq");
        csr_seq.model = m_regs;

        //***********************************************
        // Run the reg model sequence
        //***********************************************
        phase.raise_objection(this, "Start RALGEN sequence");
        #2000ns;
<%  if((obj.INHOUSE_APB_VIP)) { %>
        csr_seq.start(m_concerto_env.m_apb_agent.m_apb_sequencer);
<%  } %>
        `uvm_info("NCORE", "Running RALGEN sequence",UVM_LOW)
        phase.drop_objection(this, "End RALGEN sequence");

        `uvm_info("run_phase", "Exiting...", UVM_LOW)
    endtask: run_phase


    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction
 

endclass: concerto_fullsys_ralgen_bitbash_test

class concerto_fullsys_ralgen_reset_test extends concerto_base_test;
    `uvm_component_utils(concerto_fullsys_ralgen_reset_test)

     uvm_reg_hw_reset_seq   csr_seq;
<%  if(obj.INHOUSE_APB_VIP) { %>
    apb_agent_config       m_apb_cfg;
<%  } %>

 <% if(obj.useResiliency) { %>
  apb_agent_config       m_fc_apb_cfg;
 <% } %>

        uvm_reg_hw_reset_seq   csr_seq;


    function new(string name = "concerto_fullsys_ralgen_reset_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction 

    function void build_phase(uvm_phase phase);
        string msg_idx;
        `uvm_info("Build", "Entered Build Phase", UVM_LOW);
        super.build_phase(phase);
       
        //Disable All coverage for RALGEN
        uvm_config_db#(bit)::set(uvm_root::get(),"*", "include_coverage", 0);


<%  if((obj.INHOUSE_APB_VIP)) { %>
        m_apb_cfg  = apb_agent_config::type_id::create("m_apb_cfg",  this);
        m_concerto_env_cfg.m_apb_cfg  = m_apb_cfg;
<%  } %>

    <% if(obj.useResiliency) { %>
        m_fc_apb_cfg  = apb_agent_config::type_id::create("m_fc_apb_cfg",  this);
        m_concerto_env_cfg.m_fc_apb_cfg  = m_fc_apb_cfg;
    <% } %>


        set_inactivity_period(m_args.k_timeout);
        `uvm_info("Build", "Exited Build Phase", UVM_LOW);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
    
        `uvm_info("run_phase", "Entered...", UVM_LOW)

        csr_seq = uvm_reg_hw_reset_seq::type_id::create("csr_seq");
        csr_seq.model = m_regs;

        //***********************************************
        // Run the reg model sequence
        //***********************************************
        phase.raise_objection(this, "Start RALGEN sequence");
        #2000ns;
<%  if((obj.INHOUSE_APB_VIP)) { %>
        csr_seq.start(m_concerto_env.m_apb_agent.m_apb_sequencer);
<%  } %>
        `uvm_info("NCORE", "Running RALGEN sequence",UVM_LOW)
        phase.drop_objection(this, "End RALGEN sequence");

        `uvm_info("run_phase", "Exiting...", UVM_LOW)
    endtask: run_phase


    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction
 

endclass: concerto_fullsys_ralgen_reset_test
*/


class ext_uvm_reg_bit_bash_seq extends uvm_reg_bit_bash_seq;

   `uvm_object_param_utils(ext_uvm_reg_bit_bash_seq)

   function new(string name="ext_uvm_reg_bit_bash_seq");
     super.new(name);
   endfunction


   // Task: body
   //
   // Executes the Register Bit Bash sequence.
   // Do not call directly. Use seq.start() instead.
   //
   virtual task body();
      
      if (model == null) begin
         `uvm_error("uvm_reg_bit_bash_seq", "No register model specified to run sequence on");
         return;
      end

      uvm_report_info("STARTING_SEQ",{"\n\nStarting ",get_name()," sequence...\n"},UVM_LOW);

      reg_seq = uvm_reg_single_bit_bash_seq::type_id::create("reg_single_bit_bash_seq");

      this.reset_blk(model);
      model.reset();

      do_block(model);
   endtask


   // Task: do_block
   //
   // Test all of the registers in a a given ~block~
   //
   protected virtual task do_block(uvm_reg_block blk);
      uvm_reg regs[$];
      uvm_reg_map maps[$];

      if (blk== null) begin
         `uvm_error("ext_uvm_reg_hw_reset_seq", "Not block or system specified to run sequence on");
         return;
      end
      

      if (uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
                                             "NO_REG_TESTS", 0) != null ||
          uvm_resource_db#(bit)::get_by_name({"REG::",blk.get_full_name()},
                                             "NO_REG_BIT_BASH_TEST", 0) != null )
         return;

      // Iterate over all registers, checking accesses
      //blk.get_registers(regs, UVM_NO_HIER);

      this.reset_blk(blk);
      blk.reset();
      blk.get_maps(maps);

      // Iterate over all maps defined for the RegModel block

      foreach (maps[d]) begin

        // Iterate over all registers in the map, checking accesses
        // Note: if map were in inner loop, could test simulataneous
        // access to same reg via different bus interfaces 

        regs.delete();
        maps[d].get_registers(regs);


        foreach (regs[i]) begin
           // Registers with some attributes are not to be tested
           if (uvm_resource_db#(bit)::get_by_name({"REG::",regs[i].get_full_name()},
                                                  "NO_REG_TESTS", 0) != null ||
               uvm_resource_db#(bit)::get_by_name({"REG::",regs[i].get_full_name()},
                                                  "NO_REG_BIT_BASH_TEST", 0) != null )
              continue;
           
           reg_seq.rg = regs[i];
           reg_seq.start(null,this);
        end
      end

      //begin
      //   uvm_reg_block blks[$];
      //   
      //   blk.get_blocks(blks);
      //   foreach (blks[i]) begin
      //      do_block(blks[i]);
      //   end
      //end
   endtask: do_block

endclass

<%  if(numIoAiu>0) { %>
class ioaiu_reg_frontdoor extends uvm_reg_frontdoor;
  concerto_base_test base_test = concerto_base_test::get_instance;
  static string parent_name_previous="";
  static int rpn;
  `uvm_object_param_utils(ioaiu_reg_frontdoor)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  task body;
    uvm_reg_block parent;
    string parent_name="";
    uvm_reg the_reg;

    bit            cmd;
    uvm_reg_addr_t addr;
    uvm_reg_data_t data;
    
    //bus_tx req;
    //uvm_sequence_item item;
    //bus_tx rsp;

    // set csrBaseAddr													
    addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE ; 
    $cast(the_reg, rw_info.element);  
    
    parent = the_reg.get_parent();
    parent_name = parent.get_name();

    if(parent_name == "") begin
      `uvm_error("ioaiu_reg_frontdoor",$psprintf("Parent name can not be blank for reg %0s",the_reg.get_full_name()))
    end

    if(parent_name!=parent_name_previous && parent_name_previous!="" && parent_name!="sys_global_register_blk") begin
      rpn = rpn + 1;
      addr[11:0] = the_reg.get_offset();
      addr[19:12]=rpn;// Register Page Number
    end else if (parent_name=="sys_global_register_blk") begin
      addr[19:0] = 20'hFF000;
      addr[11:0] = the_reg.get_offset();
    end else begin
      addr[11:0] = the_reg.get_offset();
      addr[19:12]=rpn;// Register Page Number
    end

    cmd  = (rw_info.kind == UVM_WRITE);
    parent_name_previous = parent_name;
    data = rw_info.value[0];

    if(cmd==1) begin
      base_test.rw_tsks.write_csr0(addr,data);
    end else begin
      base_test.rw_tsks.read_csr0(addr,data);
    end
    
    //req = bus_tx::type_id::create("req");
    //start_item(req);

    //req.cmd  = cmd;
    //req.addr = addr;
    //req.data = data;

    //finish_item(req);

    //get_response(item);
    //$cast(rsp, item);
    //assert(rsp != null);
    
    `uvm_info(get_type_name(), $sformatf("cmd = %b addr = %0d data = %0h", cmd, addr, data), UVM_LOW)
    
    //rw_info.extension.copy(rsp);
    if (cmd == 0)
      rw_info.value[0] = data;
    rw_info.status = UVM_IS_OK;
  endtask                                                                                                    

endclass                  
<%  } %>

<%  if(numChiAiu>0) { %>
typedef class concerto_fullsys_test;

class chiaiu_reg_frontdoor extends uvm_reg_frontdoor;
  concerto_fullsys_test fullsys_test = concerto_fullsys_test::get_instance;
  static string parent_name_previous="";
  static int rpn;
  `uvm_object_param_utils(chiaiu_reg_frontdoor)
  
  function new (string name = "");
    super.new(name);
  endfunction
  
  task body;
    uvm_reg_block parent;
    string parent_name="";
    uvm_reg the_reg;

    bit            cmd;
    uvm_reg_addr_t addr;
    uvm_reg_data_t data;
    
    //bus_tx req;
    //uvm_sequence_item item;
    //bus_tx rsp;

    // set csrBaseAddr													
    addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE ; 
    $cast(the_reg, rw_info.element);  
    
    parent = the_reg.get_parent();
    parent_name = parent.get_name();

    if(parent_name == "") begin
      `uvm_error("chiaiu_reg_frontdoor",$psprintf("Parent name can not be blank for reg %0s",the_reg.get_full_name()))
    end

    if(parent_name!=parent_name_previous && parent_name_previous!="" && parent_name!="sys_global_register_blk") begin
      rpn = rpn + 1;
      addr[11:0] = the_reg.get_offset();
      addr[19:12]=rpn;// Register Page Number
    end else if (parent_name=="sys_global_register_blk") begin
      addr[19:0] = 20'hFF000;
      addr[11:0] = the_reg.get_offset();
    end else begin
      addr[11:0] = the_reg.get_offset();
      addr[19:12]=rpn;// Register Page Number
    end

    cmd  = (rw_info.kind == UVM_WRITE);
    parent_name_previous = parent_name;
    data = rw_info.value[0];

`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
    if(cmd==1) begin
      fullsys_test.m_chi0_vseq.write_csr(addr,data);
    end else begin
      fullsys_test.m_chi0_vseq.read_csr(addr,data);
    end
`endif //`ifndef USE_VIP_SNPS
    
    //req = bus_tx::type_id::create("req");
    //start_item(req);

    //req.cmd  = cmd;
    //req.addr = addr;
    //req.data = data;

    //finish_item(req);

    //get_response(item);
    //$cast(rsp, item);
    //assert(rsp != null);
    
    `uvm_info(get_type_name(), $sformatf("cmd = %b addr = %0d data = %0h", cmd, addr, data), UVM_LOW)
    
    //rw_info.extension.copy(rsp);
    if (cmd == 0)
      rw_info.value[0] = data;
    rw_info.status = UVM_IS_OK;
  endtask                                                                                                    

endclass                  
<%  } %>

