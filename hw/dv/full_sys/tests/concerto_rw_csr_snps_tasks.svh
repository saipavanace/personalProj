///////////////////////////////////////////////////////////
//                                                        //
//Description: external tasks for legacy tasks ncore      //
//                                                        //
//                                                        //
//File     : concerto_rw_csr_snps_tasks.sv                       //
//Author   : Cyrille LUDWIG                               //
////////////////////////////////////////////////////////////
class concerto_rw_csr_snps_tasks extends concerto_rw_csr_generic;

   //////////////////
   //UVM Registery
   //////////////////   
   `uvm_component_utils(concerto_rw_csr_snps_tasks)

   //////////////////
   //Properties
   //////////////////
   concerto_test_cfg test_cfg;
   concerto_env_cfg m_concerto_env_cfg;  
   concerto_env     m_concerto_env;

   //////////////////
   //Methods
   //////////////////
  <% var chi_idx=0;%>
  <% for(var idx = 0;  idx < obj.nAIUs; idx++) {%> 
  <% if (obj.AiuInfo[idx].fnNativeInterface.match('CHI')) { %>
   chi_subsys_pkg::chi_subsys_vseq         m_chi<%=chi_idx%>_vseq;
   chi_aiu_unit_args_pkg::chi_aiu_unit_args m_chi<%=chi_idx%>_args;
   <% chi_idx++;} }%>

   //constructor
   extern function new(string name = "concerto_rw_csr_snps_tasks", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);
   extern function void start_of_simulation_phase(uvm_phase phase);

   // TASKS
    <% var chi_idx=0;%>
    <% for(var idx = 0;  idx < obj.nAIUs; idx++) {%> 
    <% if (obj.AiuInfo[idx].fnNativeInterface.match('CHI')) { %>
//   CLU TMP COMPILE FIX CONC-11383  if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
    extern virtual task write_chk_chi<%=chi_idx%>(input  chiaiu<%=chi_idx%>_chi_bfm_types_pkg::addr_width_t addr, bit[31:0] data, bit check=0, bit nonblocking=0);
    extern virtual task write_csr_chi<%=chi_idx%>(input  chiaiu<%=chi_idx%>_chi_bfm_types_pkg::addr_width_t addr, bit[31:0] data, bit nonblocking=0);
    extern virtual task read_csr_chi<%=chi_idx%>(input   chiaiu<%=chi_idx%>_chi_bfm_types_pkg::addr_width_t  addr, output bit[31:0] data);
    virtual task read_csr_ral_chi<%=chi_idx%>(uvm_reg_field field, output uvm_reg_data_t fieldVal);endtask
    //task to set xNRSAR valid field for all AIU
    virtual task set_aiu_nrsar_reg_chi<%=chi_idx%>(); endtask
    <% chi_idx++;} }%>
endclass: concerto_rw_csr_snps_tasks


function concerto_rw_csr_snps_tasks::new(string name = "concerto_rw_csr_snps_tasks", uvm_component parent = null);

  super.new(name,parent);
    
endfunction: new
// ////////////////////////////////////////////////////////////////////////////
// #     # #     # #     #         ######  #     #    #     #####  #######
// #     # #     # ##   ##         #     # #     #   # #   #     # #
// #     # #     # # # # #         #     # #     #  #   #  #       #
// #     # #     # #  #  #         ######  ####### #     #  #####  #####
// #     #  #   #  #     #         #       #     # #######       # #
// #     #   # #   #     #         #       #     # #     # #     # #
//  #####     #    #     # ####### #       #     # #     #  #####  #######
////////////////////////////////////////////////////////////////////////////
function void concerto_rw_csr_snps_tasks::build_phase(uvm_phase phase);

     
     if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", m_concerto_env_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end   
      if(!(uvm_config_db #(concerto_env)::get(uvm_root::get(), "", "m_env", m_concerto_env)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end  
     if(!(uvm_config_db #(concerto_test_cfg)::get(uvm_root::get(), "", "test_cfg", test_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_test_cfg object in UVM DB");
    end 

endfunction:build_phase

function void concerto_rw_csr_snps_tasks::start_of_simulation_phase(uvm_phase phase);
// create VSEQ use in case of read or write csr via CHI
 <% var chi_idx=0;%>
  <% for(var idx = 0;  idx < obj.nAIUs; idx++) {%> 
  <% if (obj.AiuInfo[idx].fnNativeInterface.match('CHI')) { %>
  m_chi<%=chi_idx%>_vseq = chi_subsys_pkg::chi_subsys_vseq::type_id::create("m_chi<%=chi_idx%>_seq");
  m_chi<%=chi_idx%>_vseq.set_seq_name("m_chi<%=chi_idx%>_seq");
  m_chi<%=chi_idx%>_vseq.set_done_event_name("done_svt_chi_rn_seq_h<%=chi_idx%>");
  m_chi<%=chi_idx%>_vseq.rn_xact_seqr    =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chi_idx%>].rn_xact_seqr;  
  m_chi<%=chi_idx%>_vseq.shared_status =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chi_idx%>].shared_status;  
  m_chi<%=chi_idx%>_vseq.chi_num_trans =  10;  
  m_chi<%=chi_idx%>_vseq.m_regs = m_concerto_env.m_regs;
  // Due to STATIC m_chi0_args must create a dummy one.
  m_chi<%=chi_idx%>_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create("chi<%=chi_idx%>_aiu_unit_args");
  m_chi<%=chi_idx%>_args.k_num_requests.set_value(10);
  m_chi<%=chi_idx%>_args.k_coh_addr_pct.set_value(50);
  m_chi<%=chi_idx%>_args.k_noncoh_addr_pct.set_value(50);
  m_chi<%=chi_idx%>_args.k_device_type_mem_pct.set_value(50);
  m_chi<%=chi_idx%>_args.k_new_addr_pct.set_value(50);
  m_chi<%=chi_idx%>_vseq.set_unit_args(m_chi<%=chi_idx%>_args);
  m_chi<%=chi_idx%>_vseq.m_regs = m_concerto_env.m_regs;
   <% chi_idx++;} }%>

endfunction:start_of_simulation_phase

/////////////////////////////////////
// #######    #     #####  #    #
//    #      # #   #     # #   #
//    #     #   #  #       #  #
//    #    #     #  #####  ###
//    #    #######       # #  #
//    #    #     # #     # #   #
//    #    #     #  #####  #    #
// /////////////////////////////////////
 <% var chi_idx=0;%>
  <% for(var idx = 0;  idx < obj.nAIUs; idx++) {%> 
  <% if (obj.AiuInfo[idx].fnNativeInterface.match('CHI')) { %>
   task concerto_rw_csr_snps_tasks::read_csr_chi<%=chi_idx%>(input  chiaiu<%=chi_idx%>_chi_bfm_types_pkg::addr_width_t addr, output bit[31:0] data);
           m_chi<%=chi_idx%>_vseq.read_csr(addr,data);
   endtask:read_csr_chi<%=chi_idx%>
    
   task concerto_rw_csr_snps_tasks::write_csr_chi<%=chi_idx%>(input  chiaiu<%=chi_idx%>_chi_bfm_types_pkg::addr_width_t addr, bit[31:0] data, bit nonblocking=0);
           m_chi<%=chi_idx%>_vseq.write_csr(addr,data);
   endtask:write_csr_chi<%=chi_idx%>
    
   task concerto_rw_csr_snps_tasks::write_chk_chi<%=chi_idx%>(input  chiaiu<%=chi_idx%>_chi_bfm_types_pkg::addr_width_t addr, bit[31:0] data, bit check=0, bit nonblocking=0);
           m_chi<%=chi_idx%>_vseq.write_chk(addr,data,check);
   endtask:write_chk_chi<%=chi_idx%>

   <% chi_idx++;} }%>