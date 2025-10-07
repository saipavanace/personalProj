////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Read Address Channel Driver (AR)
//
////////////////////////////////////////////////////////////////////////////////
<% if(obj.testBench =="emu"){ %>

<%
   var aiu_useAceQosPort = [];
   var aiu_useAceRegionPort = [];
   var aiu_wAwUser = [];
   var aiu_wWUser = [];
   var aiu_wBUser = [];
   var aiu_wArUser = [];
   var aiu_wRUser = [];
   var aiu_useAceUniquePort = [];

   var dmi_useAceQosPort = [];
   var dmi_useAceRegionPort = [];
   var dmi_wAwUser = [];
   var dmi_wWUser = [];
   var dmi_wBUser = [];
   var dmi_wArUser = [];
   var dmi_wRUser = [];
   var dmi_useAceUniquePort = [];
   
   var dii_useAceQosPort = [];
   var dii_useAceRegionPort = [];
   var dii_wAwUser = [];
   var dii_wWUser = [];
   var dii_wBUser = [];
   var dii_wArUser = [];
   var dii_wRUser = [];
   var dii_useAceUniquePort = [];
   var initiatorAgents        = obj.nAIUs ;
   var clocks = [];
   var clocks_freq = [];

   for(var pidx = 0; pidx < obj.nDMIs; pidx++) {
       if((obj.DmiInfo[pidx].interfaces.axiInt.params.wQos > 0 == 0) && (obj.wPriorityLevel == 0)) { 
           dmi_useAceQosPort.push(0);
       } else {
           dmi_useAceQosPort.push(1);
       }
       dmi_useAceRegionPort.push(obj.DmiInfo[pidx].interfaces.axiInt.params.useRegionPort);
       //TODO FIXME
       //dmi_useAceUniquePort.push();

       dmi_wAwUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wAwUser);
       dmi_wWUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wWUser);
       dmi_wBUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wBUser);
       dmi_wArUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wArUser);
       dmi_wRUser.push(obj.DmiInfo[pidx].interfaces.axiInt.params.wRUser);
   } 
   for(var pidx = 0; pidx < obj.nDIIs; pidx++) {
       if((obj.DiiInfo[pidx].interfaces.axiInt.params.wQos > 0 == 0) && (obj.wPriorityLevel == 0)) { 
           dii_useAceQosPort.push(0);
       } else {
           dii_useAceQosPort.push(1);
       }
       dii_useAceRegionPort.push(obj.DiiInfo[pidx].interfaces.axiInt.params.useRegionPort);
       //TODO FIXME
       //dii_useAceUniquePort.push();

       dii_wAwUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wAwUser);
       dii_wWUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wWUser);
       dii_wBUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wBUser);
       dii_wArUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wArUser);
       dii_wRUser.push(obj.DiiInfo[pidx].interfaces.axiInt.params.wRUser);
   }
%>		  
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var pidx = 0;
   var ridx = 0;
   var chiaiu_idx = 0;
   var ioaiu_idx = 0;
   var initiatorAgents = obj.AiuInfo.length ;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface.includes('CHI'))) {
       _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
       _child_blk[pidx]   = 'chiaiu';
       chiaiu_idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
       _child_blk[pidx]   = 'ioaiu';
       ioaiu_idx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
   }
%>

<%

var pma_en_dmi_blk = 1;
var pma_en_dii_blk = 1;
var pma_en_aiu_blk = 1;
var pma_en_dce_blk = 1;
var pma_en_dve_blk = 1;
var pma_en_all_blk = 1;

for(var pidx = 0; pidx < obj.nDMIs; pidx++) {
    pma_en_dmi_blk &= obj.DmiInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nDIIs; pidx++) {
    pma_en_dii_blk &= obj.DiiInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    pma_en_aiu_blk &= obj.AiuInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nDCEs; pidx++) {
    pma_en_dce_blk &= obj.DceInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nDVEs; pidx++) {
    pma_en_dve_blk &= obj.DveInfo[pidx].usePma;
}
%>
<% } %>

class axi_master_read_addr_chnl_driver extends uvm_driver #(axi_rd_seq_item);

    `uvm_component_param_utils(axi_master_read_addr_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;
<% if(obj.testBench =="emu") { %>
    virtual <%=obj.BlockId%>_ace_emu_if ace_emu_vif ;
    virtual mgc_axi_master_if mgc_ace_m_if_<%=obj.BlockId%>; 
     axi_rd_seq_item m_pkt;
<% } %>

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_master_read_addr_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new
   //-----------------------------------------------------------------------------
   // Build Phase
   //-----------------------------------------------------------------------------
<% if(obj.testBench =="emu") { %>
     function void build_phase(uvm_phase phase);
      super.build_phase(phase);
       if(!(uvm_config_db #(virtual <%=obj.BlockId%>_ace_emu_if)::get(this, "","<%=obj.BlockId%>_ace_emu_if",ace_emu_vif)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end
       if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(this,"","mgc_ace_m_if_<%=obj.BlockId%>",mgc_ace_m_if_<%=obj.BlockId%>)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end

     endfunction

<% } %>

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
<% if(obj.testBench !="emu") { %>
    task run_phase(uvm_phase phase);
        axi_rd_seq_item m_pkt;
        m_pkt = new();

        m_vif.async_reset_ace_master_read_addr_channel();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);
        forever begin
            seq_item_port.get_next_item(m_pkt);
            /* if((m_pkt.m_read_addr_pkt.pkt_type == "ACE") && (m_pkt.m_read_addr_pkt.arsnoop == 4'b1110)) */
            if(m_pkt.m_read_addr_pkt.arsnoop == 4'b1110) begin
                int dvm_sync_q[$];
                do begin
                    dvm_sync_q = {};
                    dvm_sync_q = m_vif.m_drv_mst_snp_resp_q.find_index with (item.is_dvm_sync_crresp == 1);
                    if(dvm_sync_q.size() != 0) @(m_vif.e_drv_mst_crresp_collected);
                end while(dvm_sync_q.size() > 0);
               // @(m_vif.e_drv_mst_crresp_collected);
            end
            m_vif.drive_ace_master_read_addr_channel(m_pkt.m_read_addr_pkt);
            seq_item_port.item_done();
        end 
    endtask : run_phase

<% } %>
<% if(obj.testBench =="emu") { %>
   task run_phase(uvm_phase phase);
        m_pkt = new();
            `uvm_info(" master read_channel_driver", $sformatf(" before_async_task  " ), UVM_LOW)
        m_vif.async_reset_ace_master_read_addr_channel();
            `uvm_info(" master read_channel_driver"," After_async_task", UVM_NONE)
            `uvm_info(" master read_channel_driver"," Before seq_item  ", UVM_LOW)
        mgc_ace_m_if_<%=obj.BlockId%>.wait_for_reset();
        repeat(100)   mgc_ace_m_if_<%=obj.BlockId%>.wait_for_clk(1);
        forever begin
            seq_item_port.get_next_item(m_pkt);
            /* if((m_pkt.m_read_addr_pkt.pkt_type == "ACE") && (m_pkt.m_read_addr_pkt.arsnoop == 4'b1110)) */
            if(m_pkt.m_read_addr_pkt.arsnoop == 4'b1110) begin
                wait(m_vif.m_drv_mst_snp_resp_q.size() == 0);
              end
      `uvm_info(" READ_ADDR_DRIVER", $sformatf("before_read_add_driver_ace_if_len_here arlen = %p",m_pkt.m_read_addr_pkt.arlen ), UVM_LOW)       
            prepare_rd_addr();
            ace_emu_vif.ace_<%=obj.BlockId%>_read_addr_wrapper() ;
      `uvm_info(" READ_ADDR_DRIVER", $sformatf("read_add_driver_ace_if_len_here arlen = %p",m_pkt.m_read_addr_pkt.arlen ), UVM_LOW)      
            `uvm_info(" master read_channel_driver", $sformatf(" After calling Task  " ), UVM_LOW)
            seq_item_port.item_done();
            `uvm_info(" master read_channel_driver", $sformatf(" After item done  " ), UVM_LOW)
        end 
     endtask : run_phase
    //--------------------------------------------------------------------------------------------------------------
    // Prepare Read Address 
    //--------------------------------------------------------------------------------------------------------------
task automatic  prepare_rd_addr();
      ace_emu_vif.vif_ar_barrier    =  m_pkt.m_read_addr_pkt.arbar        ;
      ace_emu_vif.vif_ar_txn_type   =  m_pkt.m_read_addr_pkt.arcmdtype    ;
      ace_emu_vif.vif_ar_prot       =  m_pkt.m_read_addr_pkt.arprot       ;
      ace_emu_vif.vif_ar_region     =  m_pkt.m_read_addr_pkt.arregion     ;
      ace_emu_vif.vif_ar_len        =  m_pkt.m_read_addr_pkt.arlen        ;
      ace_emu_vif.vif_ar_size       =  m_pkt.m_read_addr_pkt.arsize       ;
      ace_emu_vif.vif_ar_burst      =  m_pkt.m_read_addr_pkt.arburst      ;
      ace_emu_vif.vif_ar_lock       =  m_pkt.m_read_addr_pkt.arlock       ;
      ace_emu_vif.vif_ar_cache      =  m_pkt.m_read_addr_pkt.arcache      ;
      ace_emu_vif.vif_ar_qos        =  m_pkt.m_read_addr_pkt.arqos        ;
      ace_emu_vif.vif_ar_id         =  m_pkt.m_read_addr_pkt.arid         ;
      ace_emu_vif.vif_ar_addr       =  m_pkt.m_read_addr_pkt.araddr       ; 			
      ace_emu_vif.vif_ar_domain     =  m_pkt.m_read_addr_pkt.ardomain     ;
      ace_emu_vif.vif_ar_vmid       =  m_pkt.m_read_addr_pkt.arvmid       ;
      `uvm_info(" AXI_DRIVER", $sformatf("read_add_driver_ace_if_ace_emu_vif.vif_ar_len  = %p",ace_emu_vif.vif_ar_len  ), UVM_LOW)       
 endtask 
<% } %>

endclass: axi_master_read_addr_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Write Address Channel Driver (AW)
//
////////////////////////////////////////////////////////////////////////////////
class axi_master_write_addr_chnl_driver extends uvm_driver #(axi_wr_seq_item);

    `uvm_component_param_utils(axi_master_write_addr_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;
    <% if(obj.testBench =="emu") { %>
      virtual <%=obj.BlockId%>_ace_emu_if ace_emu_vif ;
      virtual mgc_axi_master_if mgc_ace_m_if_<%=obj.BlockId%>; 
      axi_wr_seq_item m_pkt;
    <% } %>

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_master_write_addr_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

   //------------------------------------------------------------------------------
    // Build Phase 
    //------------------------------------------------------------------------------

    <% if(obj.testBench =="emu") { %>

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
       if(!(uvm_config_db #(virtual <%=obj.BlockId%>_ace_emu_if)::get(this, "","<%=obj.BlockId%>_ace_emu_if",ace_emu_vif)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end
      if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(this,"","mgc_ace_m_if_<%=obj.BlockId%>",mgc_ace_m_if_<%=obj.BlockId%>)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end
	
     endfunction
    <% } %>


    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    <% if(obj.testBench !="emu") { %>
    task run_phase(uvm_phase phase);
        axi_wr_seq_item m_pkt;
        m_pkt = new();

        m_vif.async_reset_ace_master_write_addr_channel();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);

        forever begin
            seq_item_port.get_next_item(m_pkt);
            m_vif.drive_ace_master_write_addr_channel(m_pkt.m_write_addr_pkt);
            seq_item_port.item_done();
        end 
    endtask : run_phase
    <% } %>

<% if(obj.testBench =="emu") { %>
task run_phase(uvm_phase phase);
    m_pkt = new();
    m_vif.async_reset_ace_master_write_addr_channel();
    mgc_ace_m_if_<%=obj.BlockId%>.wait_for_reset();
    repeat(100)  mgc_ace_m_if_<%=obj.BlockId%>.wait_for_clk(1);
    forever begin
        seq_item_port.get_next_item(m_pkt);
        `uvm_info(" WRITE_ADDR_DRIVER", $sformatf("write_add_driver_axi_if_len_here awlen = %p",m_pkt.m_write_addr_pkt.awlen ), UVM_LOW)       
        prepare_wr_addr();          
        ace_emu_vif.ace_<%=obj.BlockId%>_write_addr_wrapper();
        seq_item_port.item_done();
    end 
endtask : run_phase


//--------------------------------------------------------------------------------------------------------------
// Prepare Write Address : axi_write_seq_item vars passed to emu_if 
//--------------------------------------------------------------------------------------------------------------
virtual task  prepare_wr_addr();
    // Write Address channel variables
    //if (m_pkt.m_write_addr_pkt.awcmdtype == WREVCT ) begin
    //    $display($time, "[AXI_DRIVER]:: txn_type_1_if_condition = %s\n ", m_pkt.m_write_addr_pkt.awcmdtype , m_pkt.m_write_addr_pkt.awcmdtype.name() );
    //    ace_emu_vif.vif_aw_unique = 1;
    //    $display($time, "[AXI_DRIVER]:: if_condition_awunique = %h\n ", ace_emu_vif.vif_aw_unique );
    //end
    //else
    //begin
    //   ace_emu_vif.vif_aw_unique =  m_pkt.m_write_addr_pkt.awunique ;
    //end
    ace_emu_vif.vif_aw_unique         = m_pkt.m_write_addr_pkt.awunique      ;
    ace_emu_vif.vif_aw_barrier        = m_pkt.m_write_addr_pkt.awbar         ; 
    ace_emu_vif.vif_aw_txn_type       = m_pkt.m_write_addr_pkt.awcmdtype     ;
    ace_emu_vif.vif_aw_prot           = m_pkt.m_write_addr_pkt.awprot        ;
    ace_emu_vif.vif_aw_region         = m_pkt.m_write_addr_pkt.awregion      ;
    ace_emu_vif.vif_aw_len            = m_pkt.m_write_addr_pkt.awlen         ;
    ace_emu_vif.vif_aw_size           = m_pkt.m_write_addr_pkt.awsize        ;
    ace_emu_vif.vif_aw_burst          = m_pkt.m_write_addr_pkt.awburst       ;
    ace_emu_vif.vif_aw_lock           = m_pkt.m_write_addr_pkt.awlock        ;
    ace_emu_vif.vif_aw_cache          = m_pkt.m_write_addr_pkt.awcache       ;
    ace_emu_vif.vif_aw_qos            = m_pkt.m_write_addr_pkt.awqos         ;
    ace_emu_vif.vif_aw_id             = m_pkt.m_write_addr_pkt.awid          ;
    ace_emu_vif.vif_aw_addr           = m_pkt.m_write_addr_pkt.awaddr        ;
    ace_emu_vif.vif_aw_nb             = 1'b0                                 ;    
    ace_emu_vif.vif_aw_domain         = m_pkt.m_write_addr_pkt.awdomain      ;

endtask : prepare_wr_addr


<% } %>

endclass: axi_master_write_addr_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Read Data Channel Driver (R)
//
////////////////////////////////////////////////////////////////////////////////
class axi_master_read_data_chnl_driver extends uvm_driver #(axi_rd_seq_item);

    `uvm_component_param_utils(axi_master_read_data_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;
<% if(obj.testBench =="emu") { %>
    virtual <%=obj.BlockId%>_ace_emu_if ace_emu_vif ;
    virtual mgc_axi_master_if mgc_ace_m_if_<%=obj.BlockId%>;

<% } %>
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_master_read_data_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new
      
    //------------------------------------------------------------------------------
    // Build Phase 
    //------------------------------------------------------------------------------


<% if(obj.testBench =="emu") { %>
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
       if(!(uvm_config_db #(virtual <%=obj.BlockId%>_ace_emu_if)::get(this, "","<%=obj.BlockId%>_ace_emu_if",ace_emu_vif)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end
       if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(this,"","mgc_ace_m_if_<%=obj.BlockId%>",mgc_ace_m_if_<%=obj.BlockId%>)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end
     endfunction

<% } %>


    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    <% if(obj.testBench !="emu") { %>
    task run_phase(uvm_phase phase);

        axi_rd_seq_item     m_pkt;
        ace_read_data_pkt_t m_tmp_pkt;
        ace_read_data_pkt_t m_tmp_q[$];
        int                 m_tmp_search_q[$];
        event               e_new_entry_in_q;
        bit                 done;
        semaphore           s_rack = new(1);
<% if(obj.testBench=='dmi') {%>
        uvm_phase my_phase;
        my_phase = phase;
<% } %>
        m_pkt     = new();
        m_tmp_pkt = new();
        m_vif.async_reset_ace_master_read_data_channel();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);

        fork
            begin
                forever begin
                    m_vif.drive_ace_master_read_data_channel_ready();
                end // forever
            end
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
            begin
                forever begin
                    m_vif.drive_ace_master_read_data_channel_rack();
                end // forever
            end
<% } %>      
            begin
                forever begin
                    seq_item_port.get_next_item(m_pkt);
                    m_pkt.m_has_data = 0;
                    done = 0;
                    do begin 
                        if (m_tmp_q.size > 0) begin
                            m_tmp_search_q = {};
                            m_tmp_search_q = m_tmp_q.find_index with (item.rid == m_pkt.m_read_addr_pkt.arid);
                            if (m_tmp_search_q.size > 1) begin
                                foreach (m_tmp_search_q[i]) begin
                                    uvm_report_info("AXI MASTER READ DATA DRIVER", $sformatf("%s", m_tmp_q[m_tmp_search_q[i]].sprint_pkt()), UVM_NONE);
                                end
                                uvm_report_info("AXI MASTER READ DATA DRIVER", $sformatf("%s", m_pkt.convert2string()), UVM_NONE);
                                uvm_report_error("AXI MASTER READ DATA DRIVER", $sformatf("TB Error: Above multiple read data entries match arid 0x%0x (above packet)", m_pkt.m_read_addr_pkt.arid), UVM_NONE);
                            end
                            else if (m_tmp_search_q.size == 1) begin
                                done = 1;
                                m_pkt.m_has_data = 1;
                                m_pkt.m_read_data_pkt.copy(m_tmp_q[m_tmp_search_q[0]]);
                                m_tmp_q.delete(m_tmp_search_q[0]);
                            end
                            else if (m_tmp_search_q.size == 0) begin
                                done = 1;
                                m_pkt.m_has_data = 0;
                            end
                        end
                        if (!done) begin
                            @e_new_entry_in_q;
                        end
                    end while (!done);
                    seq_item_port.item_done();
                end 
            end
            begin
                forever begin
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
    <% if(obj.testBench=='dmi') {%>
                   my_phase.raise_objection(this, "Raising objection in axi driver read data chnl");
    <% } %>

                    m_vif.collect_ace_master_read_data_channel_for_driver(m_tmp_pkt);
                    fork
                        begin
                            ace_read_data_pkt_t pkt_tmp;
                            pkt_tmp = new();
                            pkt_tmp.copy(m_tmp_pkt);
                            s_rack.get();
                            m_vif.collect_ace_master_read_data_channel_rack();
                            s_rack.put();
    <% if(obj.testBench=='dmi') {%>
                            my_phase.drop_objection(this, "Dropping objection in axi driver read data chnl");
    <% } %>
                            m_tmp_q.push_back(pkt_tmp);
                            ->e_new_entry_in_q;
                        end
                    join_none
<% } else { %>
    <% if(obj.testBench=='dmi') {%>
                   my_phase.raise_objection(this, "Raising objection in axi driver read data chnl");
    <% } %>
                    m_vif.collect_ace_master_read_data_channel_for_driver(m_tmp_pkt);
    <% if(obj.testBench=='dmi') {%>
                   my_phase.drop_objection(this, "Dropping objection in axi driver read data chnl");
    <% } %>
                    m_tmp_q.push_back(m_tmp_pkt);
                    ->e_new_entry_in_q;
<% } %>
                end
            end
        join
    endtask : run_phase
 
<% } %>



<% if(obj.testBench =="emu") { %>
  task run_phase(uvm_phase phase);
        axi_rd_seq_item     m_pkt;
        ace_read_data_pkt_t m_tmp_pkt;
        ace_read_data_pkt_t m_tmp_q[$];
        int                 m_tmp_search_q[$];
        event               e_new_entry_in_q;
        bit                 done;
        semaphore           s_rack = new(1);
   <% if(obj.testBench=='dmi') {%>
        uvm_phase my_phase;
        my_phase = phase;
   <% } %>
        m_pkt     = new();
        m_tmp_pkt = new();
        m_vif.async_reset_ace_master_read_data_channel();
        mgc_ace_m_if_<%=obj.BlockId%>.wait_for_reset();
        repeat(100)  mgc_ace_m_if_<%=obj.BlockId%>.wait_for_clk(1);

        fork
 
            begin
                forever begin
               seq_item_port.get_next_item(m_pkt);
                    m_pkt.m_has_data = 0;
                    done = 0;
                    do begin 
                        if (m_tmp_q.size > 0) begin
                            m_tmp_search_q = {};
//Added to resolve CONC-9297 

                            m_tmp_search_q = m_tmp_q.find_index with (item.rid == m_pkt.m_read_addr_pkt.arid);
                            if (m_tmp_search_q.size > 1) begin
                                foreach (m_tmp_search_q[i]) begin
                                    uvm_report_info("AXI MASTER READ DATA DRIVER", $sformatf("%s", m_tmp_q[m_tmp_search_q[i]].sprint_pkt()), UVM_NONE);
                                end
                                uvm_report_error("AXI MASTER READ DATA DRIVER", $sformatf("TB Error: Above multiple read data entries match arid 0x%0x (above packet)", m_pkt.m_read_addr_pkt.arid), UVM_NONE);
                            end
                            else if (m_tmp_search_q.size == 1) begin
                                done = 1;
                                m_pkt.m_has_data = 1;
                                m_pkt.m_read_data_pkt.copy(m_tmp_q[m_tmp_search_q[0]]);
                                m_tmp_q.delete(m_tmp_search_q[0]);
                            end
                            else if (m_tmp_search_q.size == 0) begin
                                done = 1;
                                m_pkt.m_has_data = 0;
                            end
                        end
                        if (!done) begin
                            @e_new_entry_in_q;
                        end
                    end while (!done);
                seq_item_port.item_done();
                end 
            end
begin
                forever begin
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
    <% if(obj.testBench=='dmi') {%>
                   my_phase.raise_objection(this, "Raising objection in axi driver read data chnl");
    <% } %>
	            
	          ace_emu_vif.ace_<%=obj.BlockId%>_read_data_wrapper(m_tmp_pkt,m_pkt.m_read_addr_pkt.arlen);
			fork
                        begin
                            ace_read_data_pkt_t pkt_tmp;
                            pkt_tmp = new();
                            pkt_tmp.copy(m_tmp_pkt);
                           
    <% if(obj.testBench=='dmi') {%>
                            my_phase.drop_objection(this, "Dropping objection in axi driver read data chnl");
    <% } %>
                            m_tmp_q.push_back(pkt_tmp);
                            ->e_new_entry_in_q;
                        end
                    join_none
<% } else { %>					
    <% if(obj.testBench=='dmi') {%>
                   my_phase.raise_objection(this, "Raising objection in axi driver read data chnl");
    <% } %>
	
	        ace_emu_vif.ace_<%=obj.BlockId%>_read_data_wrapper(m_tmp_pkt);
    <% if(obj.testBench=='dmi') {%>
                   my_phase.drop_objection(this, "Dropping objection in axi driver read data chnl");
    <% } %>
                    m_tmp_q.push_back(m_tmp_pkt);
                    ->e_new_entry_in_q;
<% } %>
                end
            end
        join
                               
    endtask : run_phase

 
<% } %>

endclass: axi_master_read_data_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Write Data Channel Driver (W)
//
////////////////////////////////////////////////////////////////////////////////
class axi_master_write_data_chnl_driver extends uvm_driver #(axi_wr_seq_item);

    `uvm_component_param_utils(axi_master_write_data_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;

<% if(obj.testBench =="emu") { %>
    virtual <%=obj.BlockId%>_ace_emu_if ace_emu_vif ;
     axi_wr_seq_item m_pkt;
    virtual mgc_axi_master_if mgc_ace_m_if_<%=obj.BlockId%>; 
<% } %>
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_master_write_data_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new
      
    //------------------------------------------------------------------------------
    // Build Phase 
    //------------------------------------------------------------------------------


<% if(obj.testBench =="emu") { %>
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
        <%var qidx = 0;%> 
       if(!(uvm_config_db #(virtual <%=obj.BlockId%>_ace_emu_if)::get(this, "","<%=obj.BlockId%>_ace_emu_if",ace_emu_vif)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end
      if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(this,"","mgc_ace_m_if_<%=obj.BlockId%>",mgc_ace_m_if_<%=obj.BlockId%>)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end
       
     endfunction

<% } %>

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
<% if(obj.testBench !="emu") { %>
    task run_phase(uvm_phase phase);
        axi_wr_seq_item m_pkt;
        m_pkt = new();

        m_vif.async_reset_ace_master_write_data_channel();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);

        forever begin
            seq_item_port.get_next_item(m_pkt);
        //`uvm_info("CG DATA DRV", $sformatf("Reached here 1a address 0x%0x", m_pkt.m_write_addr_pkt.awaddr), UVM_NONE)
            m_vif.drive_ace_master_write_data_channel(m_pkt.m_write_data_pkt, m_pkt.m_write_addr_pkt.awlen);
        //`uvm_info("CG DATA DRV", $sformatf("Reached here 1b address 0x%0x", m_pkt.m_write_addr_pkt.awaddr), UVM_NONE)
            seq_item_port.item_done();
        //`uvm_info("CG DATA DRV", $sformatf("Reached here 1c address 0x%0x", m_pkt.m_write_addr_pkt.awaddr), UVM_NONE)
        end 
    endtask : run_phase
<% } %>

<% if(obj.testBench =="emu") { %>
     task run_phase(uvm_phase phase);
        m_pkt = new();
        m_vif.async_reset_ace_master_write_data_channel();
        mgc_ace_m_if_<%=obj.BlockId%>.wait_for_reset();
        repeat(100) mgc_ace_m_if_<%=obj.BlockId%>.wait_for_clk(1);
            forever begin
                seq_item_port.get_next_item(m_pkt);
                `uvm_info(" WRITE_DATA_DRIVER", $sformatf("write_data_here_axi_if data = %p",m_pkt.m_write_data_pkt.wdata ), UVM_LOW)
                fork 
                    `uvm_info(" WRITE_DATA_DRIVER", $sformatf("write_data_ace_emu_len_here awlen = %p",m_pkt.m_write_addr_pkt.awlen ), UVM_LOW)   
                     prepare_wr_data();
                    ace_emu_vif.ace_<%=obj.BlockId%>_write_data_wrapper (m_pkt.m_write_data_pkt, m_pkt.m_write_addr_pkt.awlen);
                    `uvm_info(" WRITE_DATA_DRIVER", $sformatf("write_data_ace_emu_id_here awid = %p",m_pkt.m_write_addr_pkt.awid ), UVM_LOW)  
        
               join_none
        seq_item_port.item_done();
        end 
        
    
    endtask : run_phase


//--------------------------------------------------------------------------------------------------------------
// Prepare Write data : axi_write_seq_item vars passed to emu_if 
//--------------------------------------------------------------------------------------------------------------
    virtual task  prepare_wr_data();
    
    // Write data channel variables
        ace_emu_vif.vif_w_len       =  m_pkt.m_write_addr_pkt.awlen       ; 
        ace_emu_vif.vif_w_id        =  m_pkt.m_write_addr_pkt.awid        ; 
        ace_emu_vif.vif_w_nb        =  1'b0                         ;
        ace_emu_vif.vif_wstrb       =  m_pkt.m_write_data_pkt.wstrb[0]    ;
        ace_emu_vif.vif_wdata     =  m_pkt.m_write_data_pkt.wdata[0]    ; //temp
    endtask : prepare_wr_data
<% } %>

endclass: axi_master_write_data_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Write Response Channel Driver (B)
//
////////////////////////////////////////////////////////////////////////////////
class axi_master_write_resp_chnl_driver extends uvm_driver #(axi_wr_seq_item);

    `uvm_component_param_utils(axi_master_write_resp_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;
    <% if(obj.testBench =="emu") { %>
        virtual <%=obj.BlockId%>_ace_emu_if ace_emu_vif ;
        virtual mgc_axi_master_if  mgc_ace_m_if_<%=obj.BlockId%> ;
    
    <% } %>
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_master_write_resp_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new
  //------------------------------------------------------------------------------
    // Build Phase 
    //------------------------------------------------------------------------------


<% if(obj.testBench =="emu") { %>
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
        <%var qidx = 0;%> 
       if(!(uvm_config_db #(virtual <%=obj.BlockId%>_ace_emu_if)::get(this, "","<%=obj.BlockId%>_ace_emu_if",ace_emu_vif)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end
        if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(this,"","mgc_ace_m_if_<%=obj.BlockId%>",mgc_ace_m_if_<%=obj.BlockId%>)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end

     endfunction

<% } %>

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
<% if(obj.testBench !="emu") { %>
    task run_phase(uvm_phase phase);

        axi_wr_seq_item      m_pkt;
        ace_write_resp_pkt_t m_tmp_q[$];
        int                  m_tmp_search_q[$];
        int                  m_awid_search_q[$];
        int                  m_awid_active_q[$];// Active AwID that are looking for BID will be stored in this queue, if no AwID found associated to available BID, report an Error
        int                  count=0; // to find limit
        event                e_new_entry_in_q;
        bit                  done;
<% if(obj.testBench=='dmi') {%>
        uvm_phase my_phase;
        my_phase = phase;
<% } %>

        m_pkt     = new();
        m_vif.async_reset_ace_master_write_resp_channel();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);

        fork
            begin
                forever begin
                    m_vif.drive_ace_master_write_resp_channel_ready();
                end // forever
            end
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
            begin
                forever begin
                    m_vif.drive_ace_master_write_resp_channel_wack();
                end // forever
            end
<% } %>      
            begin
                forever begin
                    seq_item_port.get_next_item(m_pkt);
                    m_pkt.m_has_resp = 0;
                    done = 0;
                    do begin
                        if (m_tmp_q.size > 0) begin
                            m_tmp_search_q = {};
                            m_tmp_search_q = m_tmp_q.find_index with (item.bid == m_pkt.m_write_addr_pkt.awid);
                            if (m_tmp_search_q.size() > 1) begin
                                foreach (m_tmp_search_q[i]) begin
                                    uvm_report_info("AXI MASTER WRITE RESP DRIVER", $sformatf("%s", m_tmp_q[m_tmp_search_q[i]].sprint_pkt()), UVM_NONE);
                                end
                                uvm_report_info("AXI MASTER WRITE RESP DRIVER", $sformatf("%s", m_pkt.convert2string()), UVM_NONE);
                                uvm_report_error("AXI MASTER WRITE RESP DRIVER", $sformatf("TB Error: Above multiple write resp entries match awid 0x%0x (above packet)", m_pkt.m_write_addr_pkt.awid), UVM_NONE);
                            end
                            else if (m_tmp_search_q.size == 1) begin
                                done = 1;
                                m_pkt.m_has_resp = 1;
                                m_pkt.m_write_resp_pkt.copy(m_tmp_q[m_tmp_search_q[0]]);
                                m_tmp_q.delete(m_tmp_search_q[0]);

                                m_awid_search_q = m_awid_active_q.find_index with (item== m_pkt.m_write_addr_pkt.awid);
                                if(m_awid_search_q.size() == 1) begin // we will reach here if AwID is waiting for BID that is received
                                    m_awid_active_q.delete(m_awid_search_q[0]);
                                end
                            end
                            else if (m_tmp_search_q.size == 0) begin
                                m_awid_search_q = m_awid_active_q.find_index with(item==m_pkt.m_write_addr_pkt.awid);
                                if(!m_awid_search_q.size()) begin // we will reach here if AwID is waiting for BID that is not yet received
                                    string s = "AWID received:";
                                    m_awid_active_q.push_back(m_pkt.m_write_addr_pkt.awid);
                                    foreach(m_awid_active_q[i]) s = $sformatf("%s %d:%x",s, i, m_awid_active_q[i]);
                                    uvm_report_info("AXI MASTER WRITE RESP DRIVER", s, UVM_DEBUG);
                                end
                                if(count > 1000) // To catch 0 time simulation infinite loop, due to BID issue
                                    foreach(m_tmp_q[i]) begin
                                        // Check if the BID received has corresponding AWID present
                                        m_awid_search_q = m_awid_active_q.find_index with (item == m_tmp_q[i].bid);
                                            uvm_report_info("AXI MASTER WRITE RESP DRIVER", $sformatf("Received BID 0x%0x", m_tmp_q[i].bid), UVM_DEBUG);
                                        if(!m_awid_search_q.size()) begin
                                            uvm_report_info("AXI MASTER WRITE RESP DRIVER", $sformatf("%s", m_tmp_q[i].convert2string()), UVM_DEBUG);
                                            uvm_report_error("AXI MASTER WRITE RESP DRIVER", $sformatf("Error: Above write resp BID:0x%0x didn't match any active awid", m_tmp_q[i].bid), UVM_DEBUG);
                                        end
                                    end
                                count++;
                                done = 1;
                                m_pkt.m_has_resp = 0;
                            end
                        end
                        if (!done) begin
                                m_awid_search_q = m_awid_active_q.find_index with(item==m_pkt.m_write_addr_pkt.awid);
                                if(!m_awid_search_q.size()) begin // we will reach here if AwID is waiting for BID that is not yet received
                                    string s = "waiting AWIDs:";
                                    m_awid_active_q.push_back(m_pkt.m_write_addr_pkt.awid);
                                    foreach(m_awid_active_q[i]) s = $sformatf("%s %d:%x",s, i, m_awid_active_q[i]);
                                    uvm_report_info("AXI MASTER WRITE RESP DRIVER", s, UVM_DEBUG);
                                end
                            @e_new_entry_in_q;
                        end
                    end while (!done);
                    seq_item_port.item_done();
                end
            end
            begin
                forever begin
                    ace_write_resp_pkt_t m_tmp_pkt = new();
<% if(obj.testBench=='dmi') {%>
                   my_phase.raise_objection(this, "Raising objection in axi driver write resp chnl");
<% } %>
                    m_vif.collect_ace_master_write_resp_channel(m_tmp_pkt); 
<% if(obj.testBench=='dmi') {%>
                   my_phase.drop_objection(this, "Dropping objection in axi driver write resp chnl");
<% } %>
                    count = 0;
                    m_tmp_q.push_back(m_tmp_pkt);
                    ->e_new_entry_in_q;
                end
            end
 
        join
    endtask : run_phase
<% } %>
<% if(obj.testBench =="emu") { %>
     task run_phase(uvm_phase phase);
    
            axi_wr_seq_item      m_pkt;
            ace_write_resp_pkt_t m_tmp_q[$];
            int                  m_tmp_search_q[$];
            int                  m_awid_search_q[$];
            int                  m_awid_active_q[$];// Active AwID that are looking for BID will be stored in this queue, if no AwID found associated to available BID, report an Error
            int                  count=0; // to find limit
            event                e_new_entry_in_q;
            bit                  done;
        <% if(obj.testBench=='dmi') {%>
                uvm_phase my_phase;
                my_phase = phase;
        <% } %>
    
            m_pkt     = new();
            m_vif.async_reset_ace_master_write_resp_channel();
            mgc_ace_m_if_<%=obj.BlockId%>.wait_for_reset();
            repeat(100) mgc_ace_m_if_<%=obj.BlockId%>.wait_for_clk(1) ;
             fork
             
    <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
              
    <% } %>      
              
                begin
                    forever begin
                        ace_write_resp_pkt_t m_tmp_pkt = new(); 
                         seq_item_port.get_next_item(m_pkt);
                          uvm_report_info("AXI MASTER WRITE RESP DRIVER", "here1", UVM_DEBUG);
                          ace_emu_vif.ace_<%=obj.BlockId%>_write_response_wrapper();
                          seq_item_port.item_done(); 
                         uvm_report_info("AXI MASTER WRITE RESP DRIVER afterItemDone", "DONE", UVM_DEBUG);
    <% if(obj.testBench=='dmi') {%>
                       my_phase.raise_objection(this, "Raising objection in axi driver write resp chnl");
    <% } %>             
    <% if(obj.testBench=='dmi') {%>
                       my_phase.drop_objection(this, "Dropping objection in axi driver write resp chnl");
    <% } %>
                        count = 0;
                        m_tmp_q.push_back(m_tmp_pkt);
                       uvm_report_info("AXI MASTER WRITE RESP DRIVER ", "forever_event_triggered_before", UVM_DEBUG);
                        ->e_new_entry_in_q;
                       uvm_report_info("AXI MASTER WRITE RESP DRIVER ", "forever_event_triggered", UVM_DEBUG);
                       
                    end
                  end
     
            join
    
        endtask : run_phase
<% } %>
endclass: axi_master_write_resp_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Snoop Address Channel Driver (AC)
//
////////////////////////////////////////////////////////////////////////////////
class axi_master_snoop_addr_chnl_driver extends uvm_driver #(axi_snp_seq_item);

    `uvm_component_param_utils(axi_master_snoop_addr_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;
<% if(obj.testBench =="emu") { %>
    virtual <%=obj.BlockId%>_ace_emu_if ace_emu_vif ;
    virtual mgc_axi_master_if  mgc_ace_m_if_<%=obj.BlockId%> ;
     axi_snp_seq_item m_pkt;
     ace_snoop_addr_pkt_t  wr_snp_emu_pkt;
<% } %>
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_master_snoop_addr_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new
      
    //------------------------------------------------------------------------------
    // Build Phase 
    //------------------------------------------------------------------------------

<% if(obj.testBench =="emu") { %>

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
       if(!(uvm_config_db #(virtual <%=obj.BlockId%>_ace_emu_if)::get(this, "","<%=obj.BlockId%>_ace_emu_if",ace_emu_vif)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end
        if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(this,"","mgc_ace_m_if_<%=obj.BlockId%>",mgc_ace_m_if_<%=obj.BlockId%>)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end

     endfunction

<% } %>
    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
<% if(obj.testBench !="emu") { %>
    task run_phase(uvm_phase phase);
        axi_snp_seq_item m_pkt;
        m_pkt = new();

        m_vif.async_reset_ace_master_snoop_addr_channel();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);

        fork
            begin
                forever begin
                    m_vif.drive_ace_master_snoop_addr_channel();
                end 
            end 
            begin
                forever begin
                    seq_item_port.get_next_item(m_pkt);
                    m_vif.collect_ace_master_snoop_addr_channel(m_pkt.m_snoop_addr_pkt);
                    seq_item_port.item_done();
                end 
            end
        join
    endtask : run_phase
<% } %>
<% if(obj.testBench =="emu") { %>
  task run_phase(uvm_phase phase);
      m_pkt = new();
      wr_snp_emu_pkt = new ();
      m_vif.async_reset_ace_master_snoop_addr_channel();
      mgc_ace_m_if_<%=obj.BlockId%>.wait_for_reset();
      repeat(100) mgc_ace_m_if_<%=obj.BlockId%>.wait_for_clk(1);
        fork
            begin
                forever begin 
                    seq_item_port.get_next_item(m_pkt);
                    ace_emu_vif.ace_<%=obj.BlockId%>_snoop_addr_wrapper ( wr_snp_emu_pkt); 
                    m_pkt.m_has_addr = 1;
                    m_pkt.m_snoop_addr_pkt.copy(wr_snp_emu_pkt);
                   seq_item_port.item_done();
                end 
            end
        join
    endtask : run_phase
<% } %>
endclass: axi_master_snoop_addr_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Snoop Response Channel Driver (CR)
//
////////////////////////////////////////////////////////////////////////////////
class axi_master_snoop_resp_chnl_driver extends uvm_driver #(axi_snp_seq_item);

    `uvm_component_param_utils(axi_master_snoop_resp_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;
<% if(obj.testBench =="emu") { %>
    virtual <%=obj.BlockId%>_ace_emu_if ace_emu_vif ;
    virtual mgc_axi_master_if  mgc_ace_m_if_<%=obj.BlockId%> ;
<% } %>
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_master_snoop_resp_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new 
  
    //------------------------------------------------------------------------------
    // Build Phase 
    //------------------------------------------------------------------------------

<% if(obj.testBench =="emu") { %>

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
       if(!(uvm_config_db #(virtual <%=obj.BlockId%>_ace_emu_if)::get(this, "","<%=obj.BlockId%>_ace_emu_if",ace_emu_vif)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end
         if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(this,"","mgc_ace_m_if_<%=obj.BlockId%>",mgc_ace_m_if_<%=obj.BlockId%>)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end

     endfunction


<% } %>

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
<% if(obj.testBench !="emu") { %>
    task run_phase(uvm_phase phase);
        axi_snp_seq_item m_pkt;
        m_pkt = new();

        m_vif.async_reset_ace_master_snoop_resp_channel();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);

        forever begin
            seq_item_port.get_next_item(m_pkt);
            m_vif.drive_ace_master_snoop_resp_channel(m_pkt.m_snoop_resp_pkt);
            seq_item_port.item_done();
        end 
    endtask : run_phase
<% } %>
<% if(obj.testBench =="emu") { %>
    task run_phase(uvm_phase phase);
       axi_snp_seq_item m_pkt;
       m_pkt = new();
       m_vif.async_reset_ace_master_snoop_resp_channel();
       mgc_ace_m_if_<%=obj.BlockId%>.wait_for_reset();
       repeat(100) mgc_ace_m_if_<%=obj.BlockId%>.wait_for_clk(1);
           forever begin
               seq_item_port.get_next_item(m_pkt);
               ace_emu_vif.ace_<%=obj.BlockId%>_snoop_response_wrapper (m_pkt.m_snoop_resp_pkt); 
               seq_item_port.item_done();
           end 
       endtask : run_phase
<% } %>

endclass: axi_master_snoop_resp_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Snoop Data Channel Driver (CD)
//
////////////////////////////////////////////////////////////////////////////////
class axi_master_snoop_data_chnl_driver extends uvm_driver #(axi_snp_seq_item);

    `uvm_component_param_utils(axi_master_snoop_data_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;

<% if(obj.testBench =="emu") { %>
    virtual <%=obj.BlockId%>_ace_emu_if ace_emu_vif ;
    virtual mgc_axi_master_if  mgc_ace_m_if_<%=obj.BlockId%>;
<% } %>
    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_master_snoop_data_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

<% if(obj.testBench =="emu") { %>
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
       if(!(uvm_config_db #(virtual <%=obj.BlockId%>_ace_emu_if)::get(this, "","<%=obj.BlockId%>_ace_emu_if",ace_emu_vif)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end
         if(!(uvm_config_db #(virtual mgc_axi_master_if)::get(this,"","mgc_ace_m_if_<%=obj.BlockId%>",mgc_ace_m_if_<%=obj.BlockId%>)))begin
        `uvm_fatal("Missing VIF::", "ace_emu_vif ACE EMU virtual interface not found");   
       end

     endfunction

<% } %>
    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
<% if(obj.testBench !="emu") { %>
    task run_phase(uvm_phase phase);
        axi_snp_seq_item m_pkt;
        m_pkt = new();

        m_vif.async_reset_ace_master_snoop_data_channel();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);

        forever begin
            seq_item_port.get_next_item(m_pkt);
            m_vif.drive_ace_master_snoop_data_channel(m_pkt.m_snoop_data_pkt);
            seq_item_port.item_done();
        end 
    endtask : run_phase

<% } %>
<% if(obj.testBench =="emu") { %>
  task run_phase(uvm_phase phase);
        axi_snp_seq_item m_pkt;
        m_pkt = new();
        m_vif.async_reset_ace_master_snoop_data_channel();
        mgc_ace_m_if_<%=obj.BlockId%>.wait_for_reset();
        repeat(100) mgc_ace_m_if_<%=obj.BlockId%>.wait_for_clk(1);
            forever begin
                seq_item_port.get_next_item(m_pkt);
                 ace_emu_vif.ace_<%=obj.BlockId%>_snoop_data_wrapper (m_pkt.m_snoop_data_pkt);  
                `uvm_info(" SNOOP_DATA_DRIVER", $sformatf("After_snoop_data_wrapper_cddata = %p",m_pkt.m_snoop_data_pkt.cddata ), UVM_LOW)
            seq_item_port.item_done();
        end 
   endtask : run_phase

<% } %>
endclass: axi_master_snoop_data_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Slave SysCO Channel Driver
//
////////////////////////////////////////////////////////////////////////////////
class axi_master_sysco_chnl_driver extends uvm_driver #(axi_sysco_seq_item);

    `uvm_component_param_utils(axi_master_sysco_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_master_sysco_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        axi_sysco_seq_item      m_pkt;

        m_pkt = new();
        @(posedge m_vif.rst_n);
        repeat(100)  @(posedge m_vif.clk);

        forever begin
            seq_item_port.get_next_item(m_pkt);
	    m_vif.drive_ace_master_sysco_channel(m_pkt.syscoreq);
            seq_item_port.item_done();
        end 
    endtask : run_phase

endclass: axi_master_sysco_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Slave Read Address Channel Driver (AR)
//
////////////////////////////////////////////////////////////////////////////////
class axi_slave_read_addr_chnl_driver extends uvm_driver #(axi_rd_seq_item);

    `uvm_component_param_utils(axi_slave_read_addr_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_slave_read_addr_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        axi_rd_seq_item     m_pkt;
        ace_read_addr_pkt_t m_tmp_pkt;

        m_pkt = new();
        m_tmp_pkt = new();
        m_vif.async_reset_ace_slave_read_addr_channel();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);

        fork
            begin
                forever begin
                    m_vif.drive_ace_slave_read_addr_channel();
                end 
            end 
            begin
                forever begin
                    seq_item_port.get_next_item(m_pkt);
                    m_vif.collect_ace_slave_read_addr_channel_for_driver(m_tmp_pkt);
                    m_pkt.m_has_addr = 1;
                    m_pkt.m_read_addr_pkt.copy(m_tmp_pkt);
                    seq_item_port.item_done();
                end 
            end
        join
    endtask : run_phase


endclass: axi_slave_read_addr_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Slave Write Address Channel Driver (AW)
//
////////////////////////////////////////////////////////////////////////////////
class axi_slave_write_addr_chnl_driver extends uvm_driver #(axi_wr_seq_item);

    `uvm_component_param_utils(axi_slave_write_addr_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_slave_write_addr_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        axi_wr_seq_item      m_pkt;
        ace_write_addr_pkt_t m_tmp_pkt;

        m_pkt     = new();
        m_tmp_pkt = new();
        m_vif.async_reset_ace_slave_write_addr_channel();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);

        fork
            begin
                forever begin
                    m_vif.drive_ace_slave_write_addr_channel();
                end 
            end 
            begin
                forever begin
                    seq_item_port.get_next_item(m_pkt);
                    m_vif.collect_ace_slave_write_addr_channel_for_driver(m_tmp_pkt);
                    m_pkt.m_has_addr = 1;
                    m_pkt.m_write_addr_pkt.copy(m_tmp_pkt);
                    seq_item_port.item_done();
                end 
            end
 
        join
    endtask : run_phase


endclass: axi_slave_write_addr_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Slave Read Data Channel Driver (R)
//
////////////////////////////////////////////////////////////////////////////////
class axi_slave_read_data_chnl_driver extends uvm_driver #(axi_rd_seq_item);

    `uvm_component_param_utils(axi_slave_read_data_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_slave_read_data_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        axi_rd_seq_item m_pkt;
        m_pkt = new();

        m_vif.async_reset_ace_slave_read_data_channel();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);

        forever begin
            seq_item_port.get_next_item(m_pkt);
            m_vif.drive_ace_slave_read_data_channel(m_pkt.m_read_data_pkt, m_pkt.m_read_addr_pkt.arlen);
            seq_item_port.item_done();
        end // forever
    endtask : run_phase

endclass: axi_slave_read_data_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Slave Write Data Channel Driver (W)
//
////////////////////////////////////////////////////////////////////////////////
class axi_slave_write_data_chnl_driver extends uvm_driver #(axi_wr_seq_item);

    `uvm_component_param_utils(axi_slave_write_data_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_slave_write_data_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        axi_wr_seq_item      m_pkt;
        ace_write_data_pkt_t m_tmp_pkt;

        m_pkt = new();
        m_tmp_pkt = new();
        m_vif.async_reset_ace_slave_write_data_channel();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);

        fork
            begin
                forever begin
                    m_vif.drive_ace_slave_write_data_channel();
                end 
            end 
            begin
                forever begin
                    seq_item_port.get_next_item(m_pkt);
                    m_vif.collect_ace_slave_write_data_channel_for_driver(m_tmp_pkt);
                    m_pkt.m_has_data = 1;
                    m_pkt.m_write_data_pkt.copy(m_tmp_pkt);
                    seq_item_port.item_done();
                end 
            end
        join
    endtask : run_phase

endclass: axi_slave_write_data_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Slave Write Response Channel Driver (B)
//
////////////////////////////////////////////////////////////////////////////////
class axi_slave_write_resp_chnl_driver extends uvm_driver #(axi_wr_seq_item);

    `uvm_component_param_utils(axi_slave_write_resp_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_slave_write_resp_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        axi_wr_seq_item m_pkt;
        m_pkt = new();

        m_vif.async_reset_ace_slave_write_resp_channel();
        @(posedge m_vif.rst_n);
       repeat(100)  @(posedge m_vif.clk);

        forever begin
            seq_item_port.get_next_item(m_pkt);
            m_vif.drive_ace_slave_write_resp_channel(m_pkt.m_write_resp_pkt);
            seq_item_port.item_done();
        end // forever
    endtask : run_phase

endclass: axi_slave_write_resp_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Slave SysCO Channel Driver
//
////////////////////////////////////////////////////////////////////////////////
class axi_slave_sysco_chnl_driver extends uvm_driver #(axi_sysco_seq_item);

    `uvm_component_param_utils(axi_slave_sysco_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_slave_sysco_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        axi_sysco_seq_item      m_pkt;

        m_pkt = new();
        @(posedge m_vif.rst_n);
        repeat(100)  @(posedge m_vif.clk);

        forever begin
            seq_item_port.get_next_item(m_pkt);
	    m_vif.drive_ace_slave_sysco_channel(m_pkt.syscoreq);
            seq_item_port.item_done();
        end 
    endtask : run_phase

endclass: axi_slave_sysco_chnl_driver

/************************************************************************ 
// Commenting out section below as, at this point, Concerto AXI slaves will
// strictly be AXI4 slaves, and not ACE slaves

////////////////////////////////////////////////////////////////////////////////
//
// AXI Slave Snoop Address Channel Driver (AC)
//
////////////////////////////////////////////////////////////////////////////////
class axi_slave_snoop_addr_chnl_driver extends uvm_driver #(axi_snp_seq_item);

    `uvm_component_param_utils(axi_slave_snoop_addr_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_slave_snoop_addr_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        axi_snp_seq_item     m_pkt;
        m_pkt = new();

        m_vif.async_reset_ace_slave_snoop_addr_channel();
        @(posedge m_vif.rst_n);

        fork
            forever begin
                seq_item_port.get_next_item(m_pkt);
                m_vif.drive_ace_slave_snoop_addr_channel(m_pkt.m_snoop_addr_pkt);
                seq_item_port.item_done();
            end 
        join
    endtask : run_phase


endclass: axi_slave_snoop_addr_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Slave Snoop Response Channel Driver (CR)
//
////////////////////////////////////////////////////////////////////////////////
class axi_slave_snoop_resp_chnl_driver extends uvm_driver #(axi_snp_seq_item);

    `uvm_component_param_utils(axi_slave_snoop_resp_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_slave_snoop_resp_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);

        m_vif.async_reset_ace_slave_snoop_resp_channel();
        @(posedge m_vif.rst_n);

        fork
            forever begin
                m_vif.drive_ace_slave_snoop_resp_channel();
            end 
        join
    endtask : run_phase


endclass: axi_slave_snoop_resp_chnl_driver

////////////////////////////////////////////////////////////////////////////////
//
// AXI Slave Snoop Data Channel Driver (CD)
//
////////////////////////////////////////////////////////////////////////////////
class axi_slave_snoop_data_chnl_driver extends uvm_driver #(axi_snp_seq_item);

    `uvm_component_param_utils(axi_slave_snoop_data_chnl_driver)

    virtual <%=obj.BlockId + '_axi_if'%>  m_vif;

    //------------------------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------------------------
    function new(string name = "axi_slave_snoop_data_chnl_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    //------------------------------------------------------------------------------
    // Run Phase 
    //------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);

        m_vif.async_reset_ace_slave_snoop_data_channel();
        @(posedge m_vif.rst_n);

        fork
            forever begin
                m_vif.drive_ace_slave_snoop_data_channel();
            end 
        join
    endtask : run_phase


endclass: axi_slave_snoop_data_chnl_driver
************************************************************************/ 

