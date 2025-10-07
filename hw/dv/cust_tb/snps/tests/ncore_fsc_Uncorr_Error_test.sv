class ncore_fsc_Uncorr_Error_test extends ncore_base_test;

  `uvm_component_utils(ncore_fsc_Uncorr_Error_test);
  
  bit[31:0]  read_data,temp_read_data;
  bit[31:0]  write_data;
  bit [31:0] fsc_loop_cnt;
  bit bist_seq_automatic_manual;  
  uvm_status_e   status;
  uvm_object objectors_list[$];
  uvm_objection objection;
  uvm_event mission_fault_detected;
  int cnt;

  virtual svt_apb_if m_fsc_apb_if;

  function new (string name="ncore_fsc_Uncorr_Error_test", uvm_component parent);
      super.new (name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      `uvm_info("ncore_fsc_Uncorr_Error_test", "is entered", UVM_NONE)

     if(!uvm_config_db #(virtual svt_apb_if)::get(uvm_root::get(),"uvm_test_top.m_env.m_amba_env.apb_system[0]","vif",m_fsc_apb_if))begin
          `uvm_error("Fsc test", "virtual if is not found")
      end

      mission_fault_detected = new("mission_fault_detected");
      if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                          .inst_name(""),
                                          .field_name( "mission_fault_detected" ),
                                          .value( mission_fault_detected ))) begin
          `uvm_error("Fsc test", "Event mission_fault_detected is not found")
      end

      if (!uvm_config_db#(bit [31:0])::get(this,"","fsc_loop_cnt",fsc_loop_cnt)) begin
          `uvm_error("Fsc test", "fsc_loop_cnt  not found")
      end
      `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("fsc_loop_cnt %0d \n",fsc_loop_cnt),UVM_NONE);
      `uvm_info("ncore_fsc_Uncorr_Error_test", "build - is exited", UVM_NONE)

  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    int num_clk;
    super.run_phase(phase);
    `uvm_info("run_phase", "Entered...", UVM_NONE)
    phase.raise_objection(this);
    `uvm_info("ncore_fsc_Uncorr_Error_test", "Starting FSC uncorr sequence",UVM_NONE)
    fork
      begin
      `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("IN_REPEAT_B4_TRIGGER at time %t \n",$time),UVM_NONE);
      repeat(fsc_loop_cnt) begin
        `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("Waiting  mission_fault_detected triggered fsc_loop_cnt :%0d",fsc_loop_cnt), UVM_NONE);
        mission_fault_detected.wait_trigger();
        `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("Event mission_fault_detected triggered"), UVM_NONE);
        bist_seq_automatic_manual =  $urandom_range(0,1); // Deciding if start automatic bist seq or manual

        if(bist_seq_automatic_manual) begin //Manual Bist Seq
            write_data = 'h1;
            `uvm_info("ncore_fsc_Uncorr_Error_test", "Writing 1st location of FSCBISTCR to start manual Bist seq.",UVM_NONE)
            repeat(6) begin  
                    m_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                    `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("step:%0d apb_clk: %0d at time : %t\n",cnt,m_fsc_apb_if.pclk,$time),UVM_NONE)
                do begin
                    temp_read_data=0;
                    m_env.resiliency_m_regs.fsc.FSCBISTAR.read(status,temp_read_data);
                end while(temp_read_data[cnt] !=1);
                cnt++;
            end
            cnt = 0 ; 
        end
        else begin //Automatic Bist Seq  
            write_data = 'h2;
                m_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
            `uvm_info("ncore_fsc_Uncorr_Error_test", "Writing 1th location of FSCBISTCR to set  automatic Bist seq.",UVM_NONE)
            write_data = 'h3;
                m_env.resiliency_m_regs.fsc.FSCBISTCR.write(status,write_data);
                `uvm_info("ncore_fsc_Uncorr_Error_test", "Written 0th location of FSCBISTCR to start automatic Bist seq.",UVM_NONE)
                repeat(16500)  @(posedge m_fsc_apb_if.pclk); 
        end
            `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("apb_clk: %0d at time : %t\n",m_fsc_apb_if.pclk,$time),UVM_NONE)
            repeat(100)  @(posedge m_fsc_apb_if.pclk); 
            `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("apb_clk: %0d at time : %t\n",m_fsc_apb_if.pclk,$time),UVM_NONE)
        read_data=0;
            m_env.resiliency_m_regs.fsc.FSCBISTAR.read(status,read_data);
        `uvm_info("ncore_fsc_Uncorr_Error_test",$sformatf("SCBISTAR read data %0h",read_data),UVM_NONE);
        if(read_data[11:6] != 0) begin 
            `uvm_error("ncore_fsc_Uncorr_Error_test",$sformatf("Error detected in Bist seq, SCBISTAR Reg %0h",read_data[9:5]))
        end
        if(read_data[5:0] != 'h3F) begin
            `uvm_error("ncore_fsc_Uncorr_Error_test",$sformatf("Something went wrong in Bist seq, SCBISTAR Reg %0h",read_data[4:0]))
        end
      end
      `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("%0d times checked the BIST CSR flow, now exiting...",fsc_loop_cnt), UVM_NONE)
      // Fetching the objection from current phase
      objection = phase.get_objection();
      // Collecting all the objectors which currently have objections raised
      objection.get_objectors(objectors_list);
      // Dropping the objections forcefully
      foreach(objectors_list[i]) begin
          `uvm_info("run_main", $sformatf("objection count %d", objection.get_objection_count(objectors_list[i])),UVM_MEDIUM)
          while(objection.get_objection_count(objectors_list[i]) != 0) begin
              phase.drop_objection(objectors_list[i], "dropping objections to kill the test");
          end
      end
      `uvm_info("ncore_fsc_Uncorr_Error_test", $sformatf("Jumping to report_phase"), UVM_NONE)
      phase.jump(uvm_report_phase::get());
      end
    join
  endtask : run_phase
endclass : ncore_fsc_Uncorr_Error_test


