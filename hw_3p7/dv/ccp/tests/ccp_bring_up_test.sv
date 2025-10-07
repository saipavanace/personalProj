
//******************************************************************************
// ccp_bring_up_test
// Purpose : Directed test used for ccp bringup.
//******************************************************************************

  import uvm_pkg::*;
  `include "uvm_macros.svh"
class ccp_bring_up_test extends ccp_base_test;

  `uvm_component_utils(ccp_bring_up_test)

  //ccp_cache_model  m_ccp_cache_model;
  virtual <%=obj.BlockId%>_ccp_if  u_ccp_vif; 

  uvm_event    e_ctrlstatus_seq_done;

  function new(string name = "ccp_bring_up_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   // m_ccp_cache_model = new();
 
  endfunction : build_phase

  task run_phase (uvm_phase phase);
      ccp_ctrlstatus_seq   m_ctrlstatus_seq      = ccp_ctrlstatus_seq::type_id::create("ctrlstatus_seq");
      ccp_cachefill_seq    m_cachefill_seq       = ccp_cachefill_seq::type_id::create("cachefill_seq");

      super.run_phase(phase);
     
     // m_ctrlstatus_seq.m_ccp_cache_model          = m_ccp_cache_model; 
      m_ctrlstatus_seq.k_num_txn                    = env.m_agent.m_cfg.k_num_txn  ;                      
      m_ctrlstatus_seq.k_num_addr                   = env.m_agent.m_cfg.k_num_addr ;                      
      m_ctrlstatus_seq.k_num_read                   = env.m_agent.m_cfg.k_num_read ;                      
      m_ctrlstatus_seq.k_num_write                  = env.m_agent.m_cfg.k_num_write;                      
      m_ctrlstatus_seq.k_cache_warm_depth           = env.m_agent.m_cfg.k_cache_warm_depth;                      
      m_ctrlstatus_seq.k_cache_used_idx_depth       = env.m_agent.m_cfg.k_cache_used_idx_depth;                      
      m_ctrlstatus_seq.wt_used_addr                 = env.m_agent.m_cfg.wt_used_addr;                      
      m_ctrlstatus_seq.wt_used_index                = env.m_agent.m_cfg.wt_used_index;                      
      m_ctrlstatus_seq.wt_nop                       = env.m_agent.m_cfg.wt_nop;                      
      m_ctrlstatus_seq.wt_wrtoarray                 = env.m_agent.m_cfg.wt_wrtoarray;                
      m_ctrlstatus_seq.wt_wrtoarray_and_rdrsp_port  = env.m_agent.m_cfg.wt_wrtoarray_and_rdrsp_port; 
      m_ctrlstatus_seq.wt_wrtoarray_and_evct_port   = env.m_agent.m_cfg.wt_wrtoarray_and_evct_port;  
      m_ctrlstatus_seq.wt_bypass_wrtordrsp_port     = env.m_agent.m_cfg.wt_bypass_wrtordrsp_port;    
      m_ctrlstatus_seq.wt_bypass_wrtordevct_port    = env.m_agent.m_cfg.wt_bypass_wrtordevct_port;   
      m_ctrlstatus_seq.wt_rdtordrsp_port            = env.m_agent.m_cfg.wt_rdtordrsp_port;           
      m_ctrlstatus_seq.wt_rdtoevct_port             = env.m_agent.m_cfg.wt_rdtoevct_port;            
      m_ctrlstatus_seq.wt_rdtoevct_wrbypasstorsp    = env.m_agent.m_cfg.wt_rdtoevct_wrbypasstorsp;   
      m_ctrlstatus_seq.wt_rdtoevct_wrbypasstoevctp  = env.m_agent.m_cfg.wt_rdtoevct_wrbypasstoevctp; 
      m_ctrlstatus_seq.wt_wrtoarray_rdtoevctp       = env.m_agent.m_cfg.wt_wrtoarray_rdtoevctp;      
     
    if(!uvm_config_db#(virtual <%=obj.BlockId%>_ccp_if )::get(null, get_full_name(), "u_ccp_if",u_ccp_vif))
      `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})

       fork
         begin
         phase.raise_objection(this);
          m_ctrlstatus_seq.start(env.m_agent.m_ctrlstatus_sqr);
          `uvm_info("bringup_test",$sformatf("fill_addr_inflight_q size :%d",u_ccp_vif.fill_addr_inflight_q.size()),UVM_NONE);   
          wait(!u_ccp_vif.fill_addr_inflight_q.size()); 
          phase.drop_objection(this);
         end
         begin
          `uvm_info("bringup_test", $sformatf("Starting the Cachefill_Seq"),UVM_NONE);   
          m_cachefill_seq.start(env.m_agent.m_cachefill_sqr); 
          `uvm_info("bringup_test", $sformatf("Cachefill_Seq Done"),UVM_NONE);   
         end
       join
  endtask : run_phase

endclass: ccp_bring_up_test

class ccp_rd_test extends ccp_base_test;

  `uvm_component_utils(ccp_rd_test)

  rand ccp_ctrlop_addr_t temp_addr;
  uvm_event                 init_done;

  function new(string name = "ccp_rd_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
 
  endfunction : build_phase

  task run_phase (uvm_phase phase);
      ccp_ctrlstatus_rd_seq   m_ctrlstatus_seq   = ccp_ctrlstatus_rd_seq::type_id::create("ctrlstatus_seq");
      ccp_cachefill_seq    m_cachefill_seq       = ccp_cachefill_seq::type_id::create("cachefill_seq");

    super.run_phase(phase);
    m_ctrlstatus_seq.k_num_txn                    = env.m_agent.m_cfg.k_num_txn  ;
    fork
     begin 
      phase.raise_objection(this);
        m_ctrlstatus_seq.start(env.m_agent.m_ctrlstatus_sqr);
      phase.drop_objection(this);
     end
     begin
       m_cachefill_seq.state = SC;
       m_cachefill_seq.start(env.m_agent.m_cachefill_sqr); 
     end
    join
  endtask : run_phase

endclass: ccp_rd_test

class ccp_wr_test extends ccp_base_test;

  `uvm_component_utils(ccp_wr_test)


  function new(string name = "ccp_wr_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
 
  endfunction : build_phase

  task run_phase (uvm_phase phase);
      ccp_ctrlstatus_wr_seq     m_ctrlstatus_seq      = ccp_ctrlstatus_wr_seq::type_id::create("ctrlstatus_seq");
      ccp_cachefill_seq         m_cachefill_seq       = ccp_cachefill_seq::type_id::create("cachefill_seq");

    super.run_phase(phase);
    fork
     begin 
      phase.raise_objection(this);
        m_ctrlstatus_seq.start(env.m_agent.m_ctrlstatus_sqr);
      phase.drop_objection(this);
     end
     begin
       m_cachefill_seq.state = SC;
       m_cachefill_seq.start(env.m_agent.m_cachefill_sqr); 
     end
    join
  endtask : run_phase

endclass: ccp_wr_test

class ccp_wrhit_rdhit_test extends ccp_base_test;

  `uvm_component_utils(ccp_wrhit_rdhit_test)


  function new(string name = "ccp_wrhit_rdhit_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
 
  endfunction : build_phase

  task run_phase (uvm_phase phase);
      ccp_ctrlstatus_wrhit_rdhit_seq     m_ctrlstatus_seq      = ccp_ctrlstatus_wrhit_rdhit_seq::type_id::create("ctrlstatus_seq");
      ccp_cachefill_seq         m_cachefill_seq       = ccp_cachefill_seq::type_id::create("cachefill_seq");

    super.run_phase(phase);
    fork
     begin 
      phase.raise_objection(this);
        m_ctrlstatus_seq.start(env.m_agent.m_ctrlstatus_sqr);
      phase.drop_objection(this);
     end
     begin
       m_cachefill_seq.state = SC;
       m_cachefill_seq.start(env.m_agent.m_cachefill_sqr); 
     end
    join
  endtask : run_phase

endclass: ccp_wrhit_rdhit_test


