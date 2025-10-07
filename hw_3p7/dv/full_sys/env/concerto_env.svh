
////////////////////////////////////////////////////////////////////////////////
//
// concerto_env 
<% if (1 == 0) { %>
// Author: Satya Prakash
<% } %>
//
////////////////////////////////////////////////////////////////////////////////


<%
//Embedded javascript code to figure number of blocks
   var _child_blkid      = [];
   var _child_blk        = [];
   var pidx              = 0;
   var ridx              = 0;
   var qidx              = 0;
   var idx               = 0;
   var j                 = 0;
   var num_chi_aiu_tx_if = 0;
   var num_io_aiu_tx_if  = 0;
   var num_dmi_tx_if     = 0;
   var num_dii_tx_if     = 0;
   var num_dce_tx_if     = 0;
   var num_dve_tx_if     = 0;
   var num_chi_aiu_rx_if = 0;
   var num_io_aiu_rx_if  = 0;
   var num_dmi_rx_if     = 0;
   var num_dii_rx_if     = 0;
   var num_dce_rx_if     = 0;
   var num_dve_rx_if     = 0;
   var initiatorAgents   = obj.AiuInfo.length ;
   var numChiAiu         = 0;
   var numIoAiu          = 0;
   var aiu_NumCores = [];

   for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
     if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
         aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
     } else {
         aiu_NumCores[pidx]    = 1;
     }
   }
   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       num_chi_aiu_tx_if = obj.AiuInfo[pidx].smiPortParams.tx.length;
       num_chi_aiu_rx_if = obj.AiuInfo[pidx].smiPortParams.rx.length;
       numChiAiu = numChiAiu + 1;
       idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + qidx;
       _child_blk[pidx]   = 'ioaiu';
       num_io_aiu_tx_if = obj.AiuInfo[pidx].smiPortParams.tx.length;
       num_io_aiu_rx_if = obj.AiuInfo[pidx].smiPortParams.rx.length;
       numIoAiu = numIoAiu + 1;
       qidx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
       num_dce_tx_if = obj.DceInfo[pidx].smiPortParams.tx.length;
       num_dce_rx_if = obj.DceInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
       num_dmi_tx_if = obj.DmiInfo[pidx].smiPortParams.tx.length;
       num_dmi_rx_if = obj.DmiInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
       num_dii_tx_if = obj.DiiInfo[pidx].smiPortParams.tx.length;
       num_dii_rx_if = obj.DiiInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
       num_dve_tx_if = obj.DveInfo[pidx].smiPortParams.tx.length;
       num_dve_rx_if = obj.DveInfo[pidx].smiPortParams.rx.length;
   }
%>
typedef class concerto_env; 
class report_test_status extends uvm_component;

   //////////////////
   //UVM Registery
   //////////////////   
   `uvm_component_utils(report_test_status)

   concerto_env env;
   concerto_env_cfg env_cfg;

    function new(string name = "report_test_status", uvm_component parent = null);
        super.new(name,parent);
    endfunction: new

   function void build_phase(uvm_phase phase);
     if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", env_cfg)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end   
      if(!(uvm_config_db #(concerto_env)::get(uvm_root::get(), "", "m_env", env)))begin
        `uvm_fatal(this.get_full_name(), "Could not find concerto_env_cfg object in UVM DB");
    end  
    endfunction:build_phase

    function void report_results(input bit trigger_from_error = 0);
        bit aiu_err, dce_err, dmi_err, dii_err, dve_err;

        //Hard coded to AIU0 since it is expected that there is atleast
        //one agent in Concerto system. Results printed in Cpp checker
        //if(m_concerto_env.m_cfg.is_cpp_model) begin
        //    m_concerto_env.m_aiu0_fwdr.eot_cpp_checks();
        //end
        <% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
            if(env_cfg.m_dmi<%=pidx%>_env_cfg.has_scoreboard) begin
                // DMI SCOREBOARD CHECKS - Turn off Pending TXN check for GPRA
                // Secure access test
                if($test$plusargs("gpra_secure_uncorr_err") || $test$plusargs("kill_coherency_test")) 
                     dmi_err = env.inhouse.m_dmi<%=pidx%>_env.m_sb.print_pending_txns(1);
                else
                     dmi_err = env.inhouse.m_dmi<%=pidx%>_env.m_sb.print_pending_txns(trigger_from_error);
            end
        <% } %>
        <% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
            if(env_cfg.m_dii<%=pidx%>_env_cfg.has_scoreboard) begin
                // DII SCOREBOARD CHECKS
                dii_err =((env.inhouse.m_dii<%=pidx%>_env.m_scb.statemachine_q.txn_q.size()!=0)||
                          (env.inhouse.m_dii<%=pidx%>_env.m_scb.order_q.txn_q.size()!=0)       ||
                          (env.inhouse.m_dii<%=pidx%>_env.m_scb.axi_w_q.size()!=0)               ) ? 1 : 0;
                if(dii_err == 1) begin
                    env.inhouse.m_dii<%=pidx%>_env.m_scb.pre_abort();
                end
            end
        <% } %>
        <% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
            if(env_cfg.m_dce<%=pidx%>_env_cfg.has_scoreboard) begin
               // DCE SCOREBOARD CHECKS
               dce_err = env.inhouse.m_dce<%=pidx%>_env.m_dce_scb.print_pend_txns();
            end
        <% } %>
       <% var qidx =0;var cidx=0;for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
            <%if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
                if(env_cfg.m_chiaiu<%=cidx%>_env_cfg.has_scoreboard && !env_cfg.has_chi_vip_snps) begin
                    // CHI AIU SCOREBOARD CHECKS
                    if (env.inhouse.m_chiaiu<%=cidx%>_env.m_scb.m_ott_q.size() !== 0) begin // if Q not empty
                        env.inhouse.m_chiaiu<%=cidx%>_env.m_scb.print_ott_info();
                        aiu_err=1;
                    end
                    // CHI AIU BFM CHECKS
                    if (env.inhouse.m_chi<%=cidx%>_container.m_txnid_pool.size() != 256) begin
                       aiu_err=1;
                    end
		 end // if (chiaiu_cmp<%=cidx%>.m_cfg.has_scoreboard)
		 <% cidx++; %>
            <% } else { %>
                <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %> 
                if (env_cfg.m_ioaiu<%=qidx%>_env_cfg[<%=i%>].has_scoreboard) begin
                    // IO AIU SCOREBOARD CHECKS
                    uvm_report_info("IO AIU SCB", $sformatf("---------------Pending IO AIU <%=qidx%> core <%=i%> scb transactions---------------"), UVM_NONE);
                    aiu_err = env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_scb.check_queues();
                    uvm_report_info("AIU TB", $sformatf("---------------DONE Pending IO AIU <%=qidx%> core <%=i%> scb transactions---------------"), UVM_NONE);
                end
               <% } %>
            <% qidx++; } %>
        <% } %>
        <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
            if(env_cfg.m_dve<%=pidx%>_env_cfg.has_sb) begin
               // DVE SCOREBOARD CHECKS
               if (env.inhouse.m_dve<%=pidx%>_env.m_dve_sb.m_ott_q.size() !== 0) begin // if Q not empty
                  env.inhouse.m_dve<%=pidx%>_env.m_dve_sb.print_ott_info();
                  dve_err = 1;
               end
            end
        <% } %>

        print_summary(aiu_err, dce_err, dmi_err, dii_err, dve_err);
    endfunction: report_results

    function void print_summary(bit aiu_err,
                                bit dce_err,
                                bit dmi_err,
                                bit dii_err,
                                bit dve_err);

        if(!(dce_err || aiu_err || dmi_err || dii_err || dve_err))
            `uvm_info("TEST", "PASS: No Pending Transactions in Scoreboards", UVM_MEDIUM);

    endfunction: print_summary

    function void print_status();
        int error_count, fatal_count;
        uvm_report_server m_urs;

        m_urs = uvm_report_server::get_server();
            `uvm_info("TEST","..Closing file\n", UVM_MEDIUM);
       
//	    $fclose(concerto_ref_helper::mhandle);
        error_count = m_urs.get_severity_count(UVM_ERROR);
        fatal_count = m_urs.get_severity_count(UVM_FATAL);

        if((error_count != 0) | (fatal_count != 0)) begin
            $display("\n===================================================================");
            $display("UVM FAILED!");
            $display("===================================================================");
        end else begin
            $display("\n===================================================================");
            $display("UVM PASSED!");
            $display("===================================================================");
        end
    endfunction: print_status

endclass: report_test_status
class concerto_env extends uvm_env;

    //////////////////////////////////
    //UVM Registery
    //////////////////////////////////        
    `uvm_component_utils(concerto_env)
  
    //////////////////////////////////
    //Concerto env config handle
    concerto_env_inhouse inhouse;
    concerto_env_snps snps;

    concerto_env_cfg env_cfg;
    ral_sys_ncore  m_regs;
  <% if(obj.useResiliency == 1){ %>
    ral_sys_resiliency resiliency_m_regs;
  <%}%>
    //Handle to end of test reporter
    report_test_status m_reporter;

<% if(obj.testBench=="emu") { %>
    // Unit ID calculation
    <% var ncidx = 0; %>
    <% var ncidx_rx = 0; %>
    <% obj.AiuInfo.forEach(function(bundle, indx) { %>
        <% for (var i = 0; i < bundle.interfaces.smiTxInt.length; i++) { %>
            <% if (bundle.interfaces.smiTxInt[i].params.wSmiDPdata > 0) { %>
    		    ioaiu_smi_pkg::ioaiu_smi_monitor_<%=ncidx%> ioaiu_smi_bfm_<%=ncidx%>;
                <%ncidx++;%>
    	    <% } %>
    		ioaiu_smi_pkg::ioaiu_smi_monitor_<%=ncidx%> ioaiu_smi_bfm_<%=ncidx%>;
            <%ncidx++;%>
    	<% } %>
        <% for (var i = 0; i < bundle.interfaces.smiRxInt.length; i++) { %>
            <% if (bundle.interfaces.smiRxInt[i].params.wSmiDPdata > 0) { %>
    		    ioaiu_smi_pkg::ioaiu_smi_monitor_rx_<%=ncidx_rx%> ioaiu_smi_bfm_rx_<%=ncidx_rx%>;
                <%ncidx_rx++;%>
    	    <% } %>
    		ioaiu_smi_pkg::ioaiu_smi_monitor_rx_<%=ncidx_rx%> ioaiu_smi_bfm_rx_<%=ncidx_rx%>;
            <%ncidx_rx++;%>
    	<% } %>
    <% }); %>
<% } %>

    //////////////////////////////////
    extern function new(string name = "concerto_env", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);

endclass:concerto_env
////////////////////////////////////////
// Constructing the Concerto_env
///////////////////////////////////////
function concerto_env::new(string name = "concerto_env", uvm_component parent = null);
  super.new(name,parent);
endfunction
//////////////////////////////////
//Calling Method: UVM Factory()
//Description: Method builds sub-block env's
//Arguments:   UVM Default
//Return type: Void
//////////////////////////////////
function void concerto_env::build_phase(uvm_phase phase);

    string inst_name;
    int fsys_scb_en;
    
     `uvm_info("concerto_env", "Entered Concerto Environment build Phase", UVM_LOW);
    if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", env_cfg)))begin
        `uvm_fatal("Missing Config Obj", "Could not find concerto_env_cfg object in UVM DB");
    end
   


<% if(obj.testBench=="emu") { %>
    // Unit ID calculation
    <% var ncidx = 0; %>
    <% var ncidx_rx = 0; %>
    <% obj.AiuInfo.forEach(function(bundle, indx) { %>
        <% for (var i = 0; i < bundle.interfaces.smiTxInt.length; i++) { %>
            <% if (bundle.interfaces.smiTxInt[i].params.wSmiDPdata > 0) { %>
                ioaiu_smi_bfm_<%=ncidx%> = ioaiu_smi_monitor_<%=ncidx%>::type_id::create("ioaiu_smi_bfm_<%=ncidx%>", this);
                <% ncidx++; %>
    		<% } %>
            ioaiu_smi_bfm_<%=ncidx%> = ioaiu_smi_monitor_<%=ncidx%>::type_id::create("ioaiu_smi_bfm_<%=ncidx%>", this);
            <% ncidx++; %>
    	<% } %>
        <% for (var i = 0; i < bundle.interfaces.smiRxInt.length; i++) { %>
            <% if (bundle.interfaces.smiRxInt[i].params.wSmiDPdata > 0) { %>
                ioaiu_smi_bfm_rx_<%=ncidx_rx%> = ioaiu_smi_monitor_rx_<%=ncidx_rx%>::type_id::create("ioaiu_smi_bfm_rx_<%=ncidx_rx%>", this);
                <% ncidx_rx++; %>
    		<% } %>
            ioaiu_smi_bfm_rx_<%=ncidx_rx%> = ioaiu_smi_monitor_rx_<%=ncidx_rx%>::type_id::create("ioaiu_smi_bfm_rx_<%=ncidx_rx%>", this);
            <% ncidx_rx++; %>
    	<% } %>
    <% }); %>
<% } %>

    m_regs = ral_sys_ncore::type_id::create("m_regs", this); 
    m_regs.build();
    m_regs.lock_model();
    uvm_config_db #(ral_sys_ncore)::set(null, "", "m_regs", m_regs);
    
  <% if(obj.useResiliency == 1){ %>
    resiliency_m_regs = ral_sys_resiliency::type_id::create("resiliency_m_regs", this);
    resiliency_m_regs.build();
    resiliency_m_regs.lock_model();
    uvm_config_db #(ral_sys_resiliency)::set(null, "", "resiliency_m_regs", resiliency_m_regs);
  <% }%>

   m_reporter = report_test_status::type_id::create("m_reporter",this);
  
   if (env_cfg.has_vip_snps) begin
       snps = concerto_env_snps::type_id::create("snps",this);
       uvm_config_db #(concerto_env_snps)::set(this, "", "snps", snps);
    end
    inhouse = concerto_env_inhouse::type_id::create("inhouse",this);
    uvm_config_db #(concerto_env_inhouse)::set(this, "", "inhouse", inhouse);

endfunction: build_phase

