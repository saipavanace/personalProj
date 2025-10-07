typedef class timeout_catcher; 


  import uvm_pkg::*;
  `include "uvm_macros.svh"
class ccp_base_test extends uvm_test;


    ccp_env           env;
    ccp_agent_config  m_cfg;

    uvm_report_server urs;
    int               error_count;
    int               fatal_count;

    uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();

    bit en_ccp_sb                              = 1;
    int k_timeout                              = 20000000;
    int k_num_txn                              = 500;    
    int k_num_addr                             = 1;
    int k_num_read                             = 5;
    int k_num_write                            = 5;
    int k_cache_warm_depth                     = 100;    
    int k_cache_used_idx_depth                 = 5;    
    int wt_used_addr                           = 80;
    int wt_used_index                          = 50; 
    int wt_nop                                 = 0;
    int wt_wrtoarray                           = 50;
    int wt_wrtoarray_and_rdrsp_port            = 10;
    int wt_wrtoarray_and_evct_port             = 10;
    int wt_bypass_wrtordrsp_port               = 10;
    int wt_bypass_wrtordevct_port              = 10;
    int wt_rdtordrsp_port                      = 50;
    int wt_rdtoevct_port                       = 50;
    int wt_rdtoevct_wrbypasstorsp              = 10;
    int wt_rdtoevct_wrbypasstoevctp            = 10;
    int wt_wrtoarray_rdtoevctp                 = 10;
   
    int k_fill_if_delay_min                    = 1;
    int k_fill_if_delay_max                    = 10;
    int k_fill_if_delay_pct                    = 80;


    `uvm_component_utils_begin(ccp_base_test);
     `uvm_field_int(en_ccp_sb                        ,UVM_DEC);
     `uvm_field_int(k_timeout                        ,UVM_DEC);
     `uvm_field_int(k_num_txn                        ,UVM_DEC);
     `uvm_field_int(k_num_addr                       ,UVM_DEC);
     `uvm_field_int(k_num_read                       ,UVM_DEC);
     `uvm_field_int(k_num_write                      ,UVM_DEC);
     `uvm_field_int(wt_nop                           ,UVM_DEC);
     `uvm_field_int(wt_wrtoarray                     ,UVM_DEC);
     `uvm_field_int(wt_wrtoarray_and_evct_port       ,UVM_DEC);
     `uvm_field_int(wt_wrtoarray_and_rdrsp_port      ,UVM_DEC);
     `uvm_field_int(wt_bypass_wrtordrsp_port         ,UVM_DEC);
     `uvm_field_int(wt_bypass_wrtordevct_port        ,UVM_DEC);
     `uvm_field_int(wt_rdtordrsp_port                ,UVM_DEC);
     `uvm_field_int(wt_rdtoevct_port                 ,UVM_DEC);
     `uvm_field_int(wt_rdtoevct_wrbypasstorsp        ,UVM_DEC);
     `uvm_field_int(wt_rdtoevct_wrbypasstoevctp      ,UVM_DEC);
     `uvm_field_int(wt_wrtoarray_rdtoevctp           ,UVM_DEC);
     `uvm_field_int(k_fill_if_delay_min              ,UVM_DEC);
     `uvm_field_int(k_fill_if_delay_max              ,UVM_DEC);
     `uvm_field_int(k_fill_if_delay_pct              ,UVM_DEC);
    `uvm_component_utils_end


    function new(string name = "ccp_base_test", uvm_component parent=null);
        super.new(name,parent);
    endfunction: new
    
    virtual function void build_phase(uvm_phase phase);
       string arg_value;

        super.build_phase(phase);
        
        env   = ccp_env::type_id::create("env", this);
        m_cfg = ccp_agent_config::type_id::create("m_agent_cfg", this);

        if (!uvm_config_db#(virtual <%=obj.BlockId%>_ccp_if)::get(.cntxt( this ),
                                                 .inst_name( "*" ),
                                                 .field_name( "u_ccp_if" ),
                                                 .value( m_cfg.m_vif ))) begin
            `uvm_error("ccp_base_test", "ccp_vif not found")
        end
        
        uvm_config_db#(ccp_agent_config)::set(this,
                                              "*",
                                              "ccp_agent_config", 
                                                m_cfg);
       //------------------------------------------------
       // taking command line parameter value
       //------------------------------------------------
       if(clp.get_arg_value("+en_ccp_sb=", arg_value)) begin
          en_ccp_sb = arg_value.atoi();
       end

       
       if(clp.get_arg_value("+k_timeout=", arg_value)) begin
          k_timeout = arg_value.atoi();
       end

       if(clp.get_arg_value("+k_num_txn=", arg_value)) begin
          k_num_txn = arg_value.atoi();
       end
       else begin
          k_num_txn = $urandom_range(500,1000);
       end

       if(clp.get_arg_value("+k_num_addr=", arg_value)) begin
          k_num_addr = arg_value.atoi();
       end
       else begin
          k_num_addr = $urandom_range(1,100);
       end

       if(clp.get_arg_value("+k_cache_warm_depth=", arg_value)) begin
          k_cache_warm_depth = arg_value.atoi();
       end
       else begin
          k_cache_warm_depth = $urandom_range(0,100);
       end

       if(clp.get_arg_value("+k_cache_used_idx_depth=", arg_value)) begin
         k_cache_used_idx_depth = arg_value.atoi();
       end
       else begin
         k_cache_used_idx_depth = $urandom_range(0,100);
       end

       if(clp.get_arg_value("+k_num_read=", arg_value)) begin
          k_num_read = arg_value.atoi();
       end
       else begin
          k_num_read = $urandom_range(1,100);
       end

       if(clp.get_arg_value("+k_num_write=", arg_value)) begin
          k_num_write = arg_value.atoi();
       end
       else begin
          k_num_write = $urandom_range(1,100);
       end

       if(clp.get_arg_value("+wt_used_addr=", arg_value)) begin
          wt_used_addr = arg_value.atoi();
       end
       else begin
          wt_used_addr = $urandom_range(50,80);
       end

       if(clp.get_arg_value("+wt_used_index=", arg_value)) begin
          wt_used_index = arg_value.atoi();
       end
       else begin
          wt_used_index  = $urandom_range(10,20);
       end

       if(clp.get_arg_value("+wt_nop=", arg_value)) begin
          wt_nop = arg_value.atoi();
       end
       else begin
          wt_nop = $urandom_range(1,2);
       end

       if(clp.get_arg_value("+wt_wrtoarray=", arg_value)) begin
          wt_wrtoarray = arg_value.atoi();
       end
       else begin
          wt_wrtoarray = $urandom_range(1,100);
       end

       if(clp.get_arg_value("+wt_wrtoarray_and_rdrsp_port=", arg_value)) begin
          wt_wrtoarray_and_rdrsp_port = arg_value.atoi();
       end
       else begin
          wt_wrtoarray_and_rdrsp_port = $urandom_range(1,100);
       end

       if(clp.get_arg_value("+wt_wrtoarray_and_evct_port=", arg_value)) begin
          wt_wrtoarray_and_evct_port = arg_value.atoi();
       end
       else begin
          wt_wrtoarray_and_evct_port = $urandom_range(1,100);
       end

       if(clp.get_arg_value("+wt_bypass_wrtordrsp_port=", arg_value)) begin
          wt_bypass_wrtordrsp_port = arg_value.atoi();
       end
       else begin
          wt_bypass_wrtordrsp_port = $urandom_range(1,100);
       end

       if(clp.get_arg_value("+wt_bypass_wrtordevct_port=", arg_value)) begin
          wt_bypass_wrtordevct_port = arg_value.atoi();
       end
       else begin
          wt_bypass_wrtordevct_port = $urandom_range(1,100);
       end

       if(clp.get_arg_value("+wt_rdtordrsp_port=", arg_value)) begin
          wt_rdtordrsp_port = arg_value.atoi();
       end
       else begin
          wt_rdtordrsp_port = $urandom_range(1,100);
       end

       if(clp.get_arg_value("+wt_rdtoevct_port=", arg_value)) begin
          wt_rdtoevct_port = arg_value.atoi();
       end
       else begin
          wt_rdtoevct_port = $urandom_range(1,100);
       end

       if(clp.get_arg_value("+wt_rdtoevct_wrbypasstorsp=", arg_value)) begin
          wt_rdtoevct_wrbypasstorsp = arg_value.atoi();
       end
       else begin
          wt_rdtoevct_wrbypasstorsp = $urandom_range(1,100);
       end

       if(clp.get_arg_value("+wt_rdtoevct_wrbypasstoevctp=", arg_value)) begin
          wt_rdtoevct_wrbypasstoevctp = arg_value.atoi();
       end
       else begin
          wt_rdtoevct_wrbypasstoevctp = $urandom_range(1,100);
       end

       if(clp.get_arg_value("+wt_wrtoarray_rdtoevctp=", arg_value)) begin
          wt_wrtoarray_rdtoevctp = arg_value.atoi();
       end
       else begin
          wt_wrtoarray_rdtoevctp = $urandom_range(1,100);
       end

       if(clp.get_arg_value("+k_fill_if_delay_min=", arg_value)) begin
          k_fill_if_delay_min = arg_value.atoi();
       end
       else begin
          k_fill_if_delay_min = $urandom_range(1,7);
       end

       if(clp.get_arg_value("+k_fill_if_delay_max=", arg_value)) begin
          k_fill_if_delay_max = arg_value.atoi();
       end
       else begin
        randcase
          80:k_fill_if_delay_max = $urandom_range(k_fill_if_delay_min,15);
          20:k_fill_if_delay_max = $urandom_range(k_fill_if_delay_min,100);
        endcase
       end

       if(clp.get_arg_value("+k_fill_if_delay_pct=", arg_value)) begin
          k_fill_if_delay_pct = arg_value.atoi();
       end
       else begin
          k_fill_if_delay_pct = ($urandom_range(0,100) < 10) ? 100 : $urandom_range(5,95);
       end

       m_cfg.has_scoreboard              = en_ccp_sb;                 
       m_cfg.k_num_txn                   = k_num_txn;                 
       m_cfg.k_num_addr                  = k_num_addr;                 
       m_cfg.k_num_read                  = k_num_read;                 
       m_cfg.k_num_write                 = k_num_write;                
       m_cfg.k_cache_warm_depth          = k_cache_warm_depth;                
       m_cfg.k_cache_used_idx_depth      = k_cache_used_idx_depth;                
       m_cfg.wt_used_addr                = wt_used_addr;                
       m_cfg.wt_used_index               = wt_used_index;                
       m_cfg.wt_nop                      = wt_nop;                     
       m_cfg.wt_wrtoarray                = wt_wrtoarray;               
       m_cfg.wt_wrtoarray_and_rdrsp_port = wt_wrtoarray_and_rdrsp_port;
       m_cfg.wt_wrtoarray_and_evct_port  = wt_wrtoarray_and_evct_port; 
       m_cfg.wt_bypass_wrtordrsp_port    = wt_bypass_wrtordrsp_port;   
       m_cfg.wt_bypass_wrtordevct_port   = wt_bypass_wrtordevct_port;  
       m_cfg.wt_rdtordrsp_port           = wt_rdtordrsp_port;          
       m_cfg.wt_rdtoevct_port            = wt_rdtoevct_port;           
       m_cfg.wt_rdtoevct_wrbypasstorsp   = wt_rdtoevct_wrbypasstorsp;  
       m_cfg.wt_rdtoevct_wrbypasstoevctp = wt_rdtoevct_wrbypasstoevctp;
       m_cfg.wt_wrtoarray_rdtoevctp      = wt_wrtoarray_rdtoevctp;     
       m_cfg.k_fill_if_delay_min         = k_fill_if_delay_min;        
       m_cfg.k_fill_if_delay_max         = k_fill_if_delay_max;        
       m_cfg.k_fill_if_delay_pct         = k_fill_if_delay_pct;        
    endfunction: build_phase 

    function void start_of_simulation_phase(uvm_phase phase);

      super.start_of_simulation_phase(phase);
      heartbeat(phase);
    endfunction: start_of_simulation_phase

    function void end_of_elaboration_phase(uvm_phase phase);
      `uvm_info("end_of_elaboration_phase", "Entered...", UVM_LOW)
      uvm_top.print_topology();
      `uvm_info("end_of_elaboration_phase", "Exiting...", UVM_LOW)
    endfunction: end_of_elaboration_phase

   task run_phase(uvm_phase phase);
     uvm_objection uvm_obj = phase.get_objection();

      super.run_phase(phase);
      fork
          uvm_obj.set_drain_time(this, 40us);
      join_none
   endtask : run_phase


    function void heartbeat(uvm_phase phase);
      uvm_callbacks_objection cb;
      uvm_heartbeat hb;
      uvm_event e;
      uvm_component comp_q[$];
      timeout_catcher catcher;
      uvm_phase run_phase;

      e = new("e");
      run_phase = phase.find_by_name("run", 0);

      catcher            = timeout_catcher::type_id::create("catcher", this);
      catcher.phase      = run_phase;
      catcher.env        = env;
      uvm_report_cb::add(null, catcher);
      
      if(!$cast(cb, run_phase.get_objection()))
          `uvm_fatal("Run", "run phase objection type isn't of type uvm_callbacks_objection. you need to define UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE!");

      hb = new("activity_heartbeat", this, cb);
      uvm_top.find_all("*", comp_q, this);
      hb.set_mode(UVM_ANY_ACTIVE);
      hb.set_heartbeat(e, comp_q);

      fork begin
          forever
              #(k_timeout*1ns) e.trigger();
      end
      join_none
    endfunction: heartbeat

    function void set_inactivity_period(int timeout);
      k_timeout = timeout;
    endfunction: set_inactivity_period

    function void report_phase(uvm_phase phase);
        run_report(phase);
        urs                     = uvm_report_server::get_server();
        error_count             = urs.get_severity_count(UVM_ERROR);
        fatal_count             = urs.get_severity_count(UVM_FATAL);
        if ((error_count != 0) | (fatal_count != 0)) begin
            `uvm_info("TEST", "\n ===========\nUVM FAILED!\n===========", UVM_NONE);
        end else begin
            `uvm_info("TEST", "\n===========\nUVM PASSED!\n===========", UVM_NONE);
        end
    endfunction : report_phase

    function void final_phase(uvm_phase phase);
        uvm_report_server svr;
        `uvm_info("final_phase", "Entered...",UVM_LOW)
        super.final_phase(phase);
        `uvm_info("final_phase", "Exiting...", UVM_LOW)
    endfunction: final_phase

    function void run_report(uvm_phase phase);
    endfunction : run_report



endclass

class timeout_catcher extends uvm_report_catcher;
    uvm_phase   phase;
    ccp_env env;

    `uvm_object_utils(timeout_catcher)

    function new(string name = "timeout_catcher");
        super.new(name);
    endfunction: new

    function action_e catch();
        if(get_severity() == UVM_FATAL && get_id == "HBFAIL") begin
            `uvm_info("TEST", "\n===========\nUVM FAILED!!!!\n===========", UVM_NONE);
            uvm_report_fatal("HBFAIL", $psprintf("Heart Beat Failure Objection:"), UVM_NONE);
        end
        else if(get_severity() == UVM_ERROR) begin
            `uvm_info("TEST", "\n===========\nUVM FAILED!!!!\n===========", UVM_NONE);
            uvm_report_error(get_id(), get_message(), UVM_NONE);
        end
        return(THROW);
   endfunction: catch
endclass: timeout_catcher
