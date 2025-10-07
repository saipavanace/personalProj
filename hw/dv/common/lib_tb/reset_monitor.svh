//----------------------------------------------------------------------- 
// Reset Monitor
//-----------------------------------------------------------------------
//`define <%=obj.BlockId%>_reset_if(input clk)
class reset_pkt extends uvm_object;
   int reset_on;   
   `uvm_object_param_utils_begin(reset_pkt)
      `uvm_field_int(reset_on, UVM_DEFAULT)
   `uvm_object_utils_end
   
   function new(string name = "");
      super.new(name);
      reset_on = 1;
   endfunction // new
   
endclass // reset_pkt


class reset_monitor extends uvm_component;
   `uvm_component_param_utils(reset_monitor);
   virtual <%=obj.BlockId + '_reset_if'%> m_vif;
   reset_pkt m_cur_pkt;
   uvm_analysis_port #(reset_pkt) reset_ap;

   function new(string name = "reset_monitor", uvm_component parent = null);
      super.new(name,parent);
   endfunction // new
   
   function void build_phase(uvm_phase phase);
      reset_ap = new("reset_ap",this);
   endfunction // build_phase
   
   function void connect_phase(uvm_phase phase);
      if(m_vif == null)
	$error("DC_DEBUG vif not defined");
   endfunction // connect_phase

   task run_phase(uvm_phase phase);
      reset_pkt cur_pkt;
      forever begin
	 m_vif.collect_reset_packet();
	 cur_pkt = new();
	 if(m_vif.m_inject_rst) begin //only note when reset is active
	    if(m_vif.rst_n_cbi.rst_n)
	      cur_pkt.reset_on = 0; //reset goes INACTIVE
	    else
	      cur_pkt.reset_on = 1; //reset goes ACTIVE
	    reset_ap.write(cur_pkt);
	 end
      end
   endtask // run_phase
   
endclass // reset_monitor
