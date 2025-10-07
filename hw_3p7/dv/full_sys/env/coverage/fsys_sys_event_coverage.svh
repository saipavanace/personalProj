
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
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
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


class Fsys_sys_event_coverage;

    <% if(obj.nDCEs>0) { %>
<% for(var pidx = 0; pidx < 1; pidx++) { %>
bit dce<%=pidx%>_exmon_store_pass;
bit dce<%=pidx%>_event_in_req_assertion;
bit dce<%=pidx%>_event_in_ack_assertion;
<% } //foreach DCE %>
    <% } %>
    <% if(obj.nDIIs>0) { %>
<% for(var pidx = 0; pidx < 1; pidx++) { %>
bit dii<%=pidx%>_event_in_req_assertion;
bit dii<%=pidx%>_event_in_ack_assertion;
<% } //foreach DII %>
    <% } %>
    <% if(obj.nDMIs>0) { %>
<% for(var pidx = 0; pidx < 1; pidx++) { %>
bit dmi<%=pidx%>_event_in_req_assertion;
bit dmi<%=pidx%>_event_in_ack_assertion;
<% } //foreach DMI %>
    <% } %>
<%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { %>
<% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false) { %>
bit aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_assertion;
bit aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_ack_assertion;
 <%}%> 
<%}%>    

<%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { %>
<% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
bit aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_assertion;
bit aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_ack_assertion;
<%}}%>
    
///////////////////////////////////////////////////////////////////////////////////
// ####   ####  #    # ###### #####   ####  #####   ####  #    # #####   ####  
//#    # #    # #    # #      #    # #    # #    # #    # #    # #    # #      
//#      #    # #    # #####  #    # #      #    # #    # #    # #    #  ####  
//#      #    # #    # #      #####  #  ### #####  #    # #    # #####       # 
//#    # #    #  #  #  #      #   #  #    # #   #  #    # #    # #      #    # 
// ####   ####    ##   ###### #    #  ####  #    #  ####   ####  #       ####  
///////////////////////////////////////////////////////////////////////////////////


// Common covergroup 
    covergroup sys_event;
    <% if(obj.nDCEs>0) { %>
<% for(var pidx = 0; pidx < 1; pidx++) { %>
    // #Cover.FSYS.sysevent.DCE_exclusive_monitor_store_pass
    DCE<%=pidx%>_exclusive_monitor_store_pass : coverpoint dce<%=pidx%>_exmon_store_pass {
        ignore_bins ignore_DCE<%=pidx%>_exclusive_monitor_store_pass =  {0};
    }
    // #Cover.FSYS.sysevent.DCE_event_in_req_assertion
    DCE<%=pidx%>_event_in_req_assertion : coverpoint dce<%=pidx%>_event_in_req_assertion{
        ignore_bins ignore_DCE<%=pidx%>_event_in_req_assertion =  {0};
    }
    // #Cover.FSYS.sysevent.DCE_event_in_ack_assertion
    DCE<%=pidx%>_event_in_ack_assertion : coverpoint dce<%=pidx%>_event_in_ack_assertion{
        ignore_bins ignore_DCE<%=pidx%>_event_in_ack_assertion =  {0};
    }
<% } //foreach DCE %>
    <% } %>
<% if(obj.nDMIs>0) { %>
<% for(var pidx = 0; pidx < 1; pidx++) { %>
    // #Cover.FSYS.sysevent.DMI_event_in_req_assertion
   /* DMI<%=pidx%>_event_in_req_assertion : coverpoint dmi<%=pidx%>_event_in_req_assertion{
        ignore_bins ignore_DMI<%=pidx%>_event_in_req_assertion =  {0};
        option.weight = 1;//DMI TB dosen't done anything on sysevent so we can't connect this coverpoint
    }*/
    // #Cover.FSYS.sysevent.DMI_event_in_ack_assertion
   /* DMI<%=pidx%>_event_in_ack_assertion : coverpoint dmi<%=pidx%>_event_in_ack_assertion{
        ignore_bins ignore_DMI<%=pidx%>_event_in_ack_assertion =  {0};
        option.weight = 1;//DMI TB dosen't done anything on sysevent so we can't connect this coverpoint
    }*/
<% } //foreach DMI %>
    <% } %>
<% if(obj.nDIIs>0) { %>
<% for(var pidx = 0; pidx < 1; pidx++) { %>
  <% if (obj.DiiInfo[pidx].nExclusiveEntries  > 0) { %>
    // #Cover.FSYS.sysevent.DII_event_in_req_assertion
    DII<%=pidx%>_event_in_req_assertion : coverpoint dii<%=pidx%>_event_in_req_assertion{
        ignore_bins ignore_DII<%=pidx%>_event_in_req_assertion =  {0};
    }
    // #Cover.FSYS.sysevent.DII_event_in_ack_assertion
    DII<%=pidx%>_event_in_ack_assertion : coverpoint dii<%=pidx%>_event_in_ack_assertion{
        ignore_bins ignore_DII<%=pidx%>_event_in_ack_assertion =  {0};
    }
    <% } %>
<% } //foreach DII %>
    <% } %>
<%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { %>
<% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false) { %>
 // #Cover.FSYS.sysevent.AIU_event_in_req_assertion
     AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_assertion : coverpoint aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_assertion {
            ignore_bins ignore_AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_assertion =  {0};
        }

    // #Cover.FSYS.sysevent.AIU_event_in_ack_assertion
     AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_ack_assertion : coverpoint aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_ack_assertion {
            ignore_bins ignore_AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_ack_assertion =  {0};
        }
 <%}%> 
<%}%>  

<%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { %>
<% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
    // #Cover.FSYS.sysevent.AIU_event_out_req_assertion
     AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_assertion : coverpoint aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_assertion {
            ignore_bins ignore_AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_assertion =  {0};
        }

    // #Cover.FSYS.sysevent.AIU_event_out_ack_assertion
     AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_ack_assertion : coverpoint aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_ack_assertion {
            ignore_bins ignore_AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_ack_assertion =  {0};
        }
 <%}%> 
<%}%>  

    endgroup

    function new(); 
       `uvm_info("Fsys_sys_event_coverage::new",$psprintf(""),UVM_LOW)
    // DCEs Commun covergroup
        sys_event = new();
    endfunction:new

    function DCE_sys_event_sample();
    string message="";
    <% if(obj.nDCEs>0) { %>
<% for(var pidx = 0; pidx < 1; pidx++) { %>
        message = $sformatf("%0s dce<%=pidx%>_exmon_store_pass         = %0d\n",message,dce<%=pidx%>_exmon_store_pass       );
        message = $sformatf("%0s dce<%=pidx%>_event_in_req_assertion   = %0d\n",message,dce<%=pidx%>_event_in_req_assertion );
        message = $sformatf("%0s dce<%=pidx%>_event_in_ack_assertion   = %0d\n",message,dce<%=pidx%>_event_in_ack_assertion );
<% } //foreach DCE %>
    <% } %>
       `uvm_info("Fsys_sys_event_coverage::DCE_sys_event_sample",$psprintf("Coverpoints hit with below values\n%0s",message),UVM_HIGH)
        sys_event.sample();
    endfunction : DCE_sys_event_sample 

    function DMI_sys_event_sample();
    string message="";
    <% if(obj.nDMIs>0) { %>
<% for(var pidx = 0; pidx < 1; pidx++) { %>
        message = $sformatf("%0s dmi<%=pidx%>_event_in_req_assertion   = %0d\n",message,dmi<%=pidx%>_event_in_req_assertion );
        message = $sformatf("%0s dmi<%=pidx%>_event_in_ack_assertion   = %0d\n",message,dmi<%=pidx%>_event_in_ack_assertion );
<% } //foreach DMI %>
    <% } %>
       `uvm_info("Fsys_sys_event_coverage::DMI_sys_event_sample",$psprintf("Coverpoints hit with below values\n%0s",message),UVM_HIGH)
        sys_event.sample();
    endfunction : DMI_sys_event_sample 

    function DII_sys_event_sample();
    string message="";
    <% if(obj.nDIIs>0) { %>
<% for(var pidx = 0; pidx < 1; pidx++) { %>
        message = $sformatf("%0s dii<%=pidx%>_event_in_req_assertion   = %0d\n",message,dii<%=pidx%>_event_in_req_assertion );
        message = $sformatf("%0s dii<%=pidx%>_event_in_ack_assertion   = %0d\n",message,dii<%=pidx%>_event_in_ack_assertion );
<% } //foreach DMI %>
    <% } %>
       `uvm_info("Fsys_sys_event_coverage::DII_sys_event_sample",$psprintf("Coverpoints hit with below values\n%0s",message),UVM_HIGH)
        sys_event.sample();
    endfunction : DII_sys_event_sample 

    function AIU_sys_event_sample();
    string message="";

<%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) {%>
    <% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
        message = $sformatf("%0s aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_assertion = %0d\n",message, aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_assertion    );
        message = $sformatf("%0s aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_ack_assertion = %0d\n",message, aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_ack_assertion   );
<%}}%>
<%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { %>
<% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false) { %>
        message = $sformatf("%0s aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_assertion = %0d\n",message, aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_assertion    );
        message = $sformatf("%0s aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_ack_assertion = %0d\n",message, aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_ack_assertion   );    
 <%}%> 
<%}%> 
       `uvm_info("Fsys_sys_event_coverage::AIU_sys_event_sample",$psprintf("Coverpoints hit with below values\n%0s",message),UVM_HIGH)
        sys_event.sample();
    endfunction : AIU_sys_event_sample

    function restore_defaults();
<% if(obj.nDCEs>0) { %>
<% for(var pidx = 0; pidx < 1; pidx++) { %>
    dce<%=pidx%>_exmon_store_pass         = 0;
    dce<%=pidx%>_event_in_req_assertion   = 0;
    dce<%=pidx%>_event_in_ack_assertion   = 0;
<% } //foreach DCE %>
    <% } %>
    <% if(obj.nDMIs>0) { %>
<% for(var pidx = 0; pidx < 1; pidx++) { %>
    dmi<%=pidx%>_event_in_req_assertion   = 0;
    dmi<%=pidx%>_event_in_ack_assertion   = 0;
<% } //foreach DMI %>
    <% } %>
    <% if(obj.nDIIs>0) { %>
<% for(var pidx = 0; pidx < 1; pidx++) { %>
    dii<%=pidx%>_event_in_req_assertion   = 0;
    dii<%=pidx%>_event_in_ack_assertion   = 0;
<% } //foreach DII %>
    <% } %>

<%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) {%>
    <% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
    aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_assertion = 0;
    aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_ack_assertion = 0;
<%}}%>
    endfunction : restore_defaults
endclass
