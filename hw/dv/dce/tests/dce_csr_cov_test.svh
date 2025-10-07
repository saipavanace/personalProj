
`include "ocp_base_test.sv"

class dce_reg_cov_sequence extends svt_ocp_master_transaction_base_sequence;

  `uvm_object_utils(ocp_master_directed_reg_wr_rd_sequnence)

  /**
   Constructs the sequence
   @param name String to name the instance
   */
 function new(string name="ocp_master_directed_reg_wr_rd_sequnence");
   
  super.new(name);
   /**
   * Setup to use the response handler, relying on the base implementation which is a no-op.
   */
  use_response_handler(1);
  endfunction

  /**
   Executes the sequence.
   */
  virtual task body();
   
  int lsb,msb;
  bit [31:0]  rd_data, wr_data;
  bit [31:0]  mask_data;
  bit [31:0]  addr;
  bit status;
  string Rsvd; 
  string access;
  svt_ocp_master_transaction req;
  dce_reg_cov regs;   
  int count;
  
  `uvm_info("body", "Entered...", UVM_LOW)
    count = 0;
    regs = new();
    $display("size of array : %d",regs.reg_name.num());
    foreach (regs.reg_name[i])begin
    /**
     * Do a single beat WRITE transaction
     */
     lsb = regs.reg_lsb[i];
     msb = regs.reg_msb[i]; 
     addr = regs.reg_addr[i];
     mask_data =  0;


     Rsvd = regs.reg_rsvd[i];

     for(int i=0;i<32;i++)begin
      if(Rsvd != "RSVD")begin
        if(i>=lsb &&  i<=msb)begin
          mask_data[i] = 1;     
       end
      end
     end
    //---------------------------------------------------------------
    // Writing 1 on all  writable registers filed
    //---------------------------------------------------------------
     wr_data = (32'hffffffff & mask_data); 

    `uvm_info("BODY",$sformatf("reg_name =  %s,reg_addr = %x,mask_data = %x",regs.reg_name[i],regs.reg_addr[i],mask_data), UVM_LOW);
    `uvm_info("BODY",$sformatf("wr_data =  %x,mask_data = %x",wr_data,mask_data), UVM_LOW);

     if(regs.reg_access[i] != "RO" && regs.reg_access[i] != "RW1C") begin
    `uvm_info("BODY",$sformatf("reg_name =  %s,access = %s",regs.reg_name[i],regs.reg_access[i]), UVM_LOW);
      `uvm_do_with(req, 
      { 
        req.m_en_mcmd == svt_ocp_master_transaction::WRNP;
        req.m_bvv_maddr[0] == addr;
        req.m_bvv_data[0] == wr_data;
        req.m_n_mburstlength == 1;        
      })
      
      req.end_event.wait_trigger();

    //---------------------------------------------------------------
    //  Do a READ to the address just written, Read data should be same
    //  as wr_data
    //---------------------------------------------------------------
      `uvm_do_with(req, 
      { 
        req.m_en_mcmd == svt_ocp_master_transaction::RD;
        req.m_bvv_maddr[0] == addr;
        req.m_n_mburstlength == 1;        
      })
      req.end_event.wait_trigger();
      rd_data = req.m_bvv_data[0];

       if(wr_data == rd_data ) begin
        uvm_report_info("BODY",$sformatf("reg_name =  %s,Expected data: %x  Rd data : %x",regs.reg_name[i],wr_data,req.m_bvv_data[0]), UVM_LOW);
       end
       else begin 
        uvm_report_error("BODY",$sformatf("reg_name =  %s,Expected data: %x  Rd data : %x",regs.reg_name[i],wr_data,req.m_bvv_data[0]), UVM_LOW);
       end 

    //---------------------------------------------------------------
    // Writing 1 on all  writable field again, to verify that filed is 
    // not clear on write 1
    //---------------------------------------------------------------
      `uvm_do_with(req, 
      { 
        req.m_en_mcmd == svt_ocp_master_transaction::WRNP;
        req.m_bvv_maddr[0] == addr;
        req.m_bvv_data[0] == wr_data;
        req.m_n_mburstlength == 1;        
      })
      
      req.end_event.wait_trigger();

    //---------------------------------------------------------------
    //  Do a READ to the address just written, Read data should be same
    //  as wr_data
    //---------------------------------------------------------------
      `uvm_do_with(req, 
      { 
        req.m_en_mcmd == svt_ocp_master_transaction::RD;
        req.m_bvv_maddr[0] == addr;
        req.m_n_mburstlength == 1;        
      })
      req.end_event.wait_trigger();
      rd_data = req.m_bvv_data[0];
      `uvm_info("BODY",$sformatf("reg_name =  %s Rd Rsp : %s",regs.reg_name[i],req.m_env_sresp[0]), UVM_LOW);
      `uvm_info("BODY",$sformatf("reg_name =  %s Rd data : %x",regs.reg_name[i],rd_data), UVM_LOW);

       if(wr_data == rd_data ) begin
        uvm_report_info("BODY",$sformatf("reg_name =  %s,Expected data: %x  Rd data : %x",regs.reg_name[i],wr_data,req.m_bvv_data[0]), UVM_LOW);
       end
       else begin 
        uvm_report_error("BODY",$sformatf("reg_name =  %s,Expected data: %x  Rd data : %x",regs.reg_name[i],wr_data,req.m_bvv_data[0]), UVM_LOW);
       end 

    //---------------------------------------------------------------
    // Writing 0 on all  writable field again, to verify that filed is 
    // clear , it is not stuck to 1
    //---------------------------------------------------------------
      wr_data = 0;
      `uvm_do_with(req, 
      { 
        req.m_en_mcmd == svt_ocp_master_transaction::WRNP;
        req.m_bvv_maddr[0] == addr;
        req.m_bvv_data[0] == wr_data;
        req.m_n_mburstlength == 1;        
      })
      
      req.end_event.wait_trigger();

    //---------------------------------------------------------------
    //  Do a READ to the address just written, Read data should be same
    //  as wr_data
    //---------------------------------------------------------------
      `uvm_do_with(req, 
      { 
        req.m_en_mcmd == svt_ocp_master_transaction::RD;
        req.m_bvv_maddr[0] == addr;
        req.m_n_mburstlength == 1;        
      })
      req.end_event.wait_trigger();
      rd_data = req.m_bvv_data[0];
      `uvm_info("BODY",$sformatf("reg_name =  %s Rd Rsp : %s",regs.reg_name[i],req.m_env_sresp[0]), UVM_LOW);
      `uvm_info("BODY",$sformatf("reg_name =  %s Rd data : %x",regs.reg_name[i],rd_data), UVM_LOW);

       if(wr_data == rd_data ) begin
        uvm_report_info("BODY",$sformatf("reg_name =  %s,Expected data: %x  Rd data : %x",regs.reg_name[i],wr_data,req.m_bvv_data[0]), UVM_LOW);
       end
       else begin 
        uvm_report_error("BODY",$sformatf("reg_name =  %s,Expected data: %x  Rd data : %x",regs.reg_name[i],wr_data,req.m_bvv_data[0]), UVM_LOW);
       end 
    count++;
    end
    end
    $display(" Wr reg count = %d ",count);
  `uvm_info("body", "Exiting...", UVM_LOW)
endtask: body

endclass : dce_reg_cov_sequence

class dce_csr_cov_test extends ocp_base_test;

  /**
   * UVM object utility macro which implements the create() and get_type_name() methods.
   */
  `uvm_component_utils (dce_csr_cov_test)
   int unsigned sequence_length = 8;
  
  function new (string name="dce_csr_cov_test", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    `uvm_info ("build_phase", "is entered",UVM_LOW)
    super.build_phase(phase);
     /**
     * Apply the basic directed sequential master sequence to the master sequencer
     */
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.ocp_master_agent.df_sequencer.main_phase", "default_sequence", dce_reg_cov_sequence::type_id::get());

    /** Set the master sequence 'length' to generate as many directed transactions as were specified via the plusarg or the default (i.e., 20). */
    uvm_config_db#(int unsigned)::set(this, "m_env.ocp_master_agent.df_sequencer.ocp_master_directed_reg_wr_rd_sequnence", "sequence_length", sequence_length);

    `uvm_info ("build_phase", "is exited",UVM_LOW)

  endfunction : build_phase

endclass
