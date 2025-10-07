//-------------------------------------------------------------
//  CCP driver
//-------------------------------------------------------------

 class ccp_ctrlstatus_driver extends uvm_driver #(ccp_ctrlstatus_seq_item);

   `uvm_component_utils(ccp_ctrlstatus_driver)

    virtual  <%=obj.BlockId + '_ccp_if'%> m_vif;

    //----------------------------------------------------------------------- 
    // New
    //----------------------------------------------------------------------- 

    function new(string name = "ccp_ctrlstatus_driver", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new
    
    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        ccp_ctrlstatus_seq_item m_pkt;
        m_pkt = new();

        m_vif.aysnc_reset_ccpctrlstatus();
        m_vif.aysnc_reset_ccpwr();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);
       fork
        begin
           forever begin
               seq_item_port.get_next_item(m_pkt);
               m_vif.drive_ctrlstatus_data(m_pkt);
               seq_item_port.item_done(m_pkt);
           end
        end
       // begin    
       //    forever begin
       //      m_vif.collect_ctrlstatus_p2_pkt(m_pkt);
       //      seq_item_port.put(m_pkt);
       //    end
       // end   
       join 
    endtask : run_phase

 endclass: ccp_ctrlstatus_driver

 class ccp_cachefill_driver extends uvm_driver #(ccp_cachefill_seq_item);

   `uvm_component_utils(ccp_cachefill_driver)

    virtual  <%=obj.BlockId + '_ccp_if'%> m_vif;

    //----------------------------------------------------------------------- 
    // New
    //----------------------------------------------------------------------- 

    function new(string name = "ccp_cachefill_driver", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new
    
    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        ccp_cachefill_seq_item m_pkt;
        m_pkt       = new();

        m_vif.aysnc_reset_ccpfillctrl;
        m_vif.aysnc_reset_ccpfilldata;
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);
         forever begin
             seq_item_port.get_next_item(m_pkt);
             m_vif.drive_cachefill_data(m_pkt);
             seq_item_port.item_done(m_pkt);
         end 
    endtask : run_phase

 endclass: ccp_cachefill_driver

 class ccp_csr_maint_driver extends uvm_driver #(ccp_csr_maint_seq_item);

   `uvm_component_utils(ccp_csr_maint_driver)

    virtual  <%=obj.BlockId + '_ccp_if'%> m_vif;

    //----------------------------------------------------------------------- 
    // New
    //----------------------------------------------------------------------- 

    function new(string name = "ccp_csr_maint_driver", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new
    
    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        ccp_csr_maint_seq_item m_pkt;
        m_pkt       = new();

        m_vif.aysnc_reset_csr_maint_data;
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);
         forever begin
             seq_item_port.get_next_item(m_pkt);
             m_vif.drive_csr_maint_data(m_pkt);
             seq_item_port.item_done();
         end 
    endtask : run_phase

 endclass: ccp_csr_maint_driver
     
