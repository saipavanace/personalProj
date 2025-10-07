`timescale 1 ns/1 ps

<%
//Embedded javascript code to figure number of blocks
   var pidx = 0;
   var chiaiu_idx = 0;
   var max_addr_width = 0;
   var max_data_width = 0;
   var max_node_id_width = 0;
%>

   <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
       <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       <% if (obj.testBench == "fsys") { %>
          <%
          if(max_data_width<obj.AiuInfo[pidx].interfaces.chiInt.params.wData) {
            max_data_width = obj.AiuInfo[pidx].interfaces.chiInt.params.wData;
          }
          if(max_addr_width<obj.AiuInfo[pidx].interfaces.chiInt.params.wAddr) {
            max_addr_width = obj.AiuInfo[pidx].interfaces.chiInt.params.wAddr;
          }
          if(max_node_id_width<obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID) {
            max_node_id_width = obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID;
          }
          %>
       <% } %>
       <% chiaiu_idx++; %>
     <% } %>
   <% } %>
<% if (obj.testBench !== "fsys") { %>
module <%=obj.BlockId%>_connection_wrapper_to_svt_chi_rn_if (<%=obj.BlockId%>_chi_if inhouse_chi_if, svt_chi_rn_if svt_chi_if);    

//`define always_block

`ifdef always_block
always @ (posedge svt_chi_if.clk) begin
     $display("%10.4t connection_wrapper_to_svt_chi_rn_if-posedge svt_chi_if.clk",$realtime);
    
/* TBD USE_VIP_SNPS - Fix the discrepancy*/
`ifdef SVT_CHI_ISSUE_B_ENABLE
     inhouse_chi_if.sysco_req = svt_chi_if.SYSCOREQ ;
     svt_chi_if.SYSCOACK = inhouse_chi_if.sysco_ack;
`elsif SVT_CHI_ISSUE_C_ENABLE
     inhouse_chi_if.sysco_req = svt_chi_if.SYSCOREQ ;
     svt_chi_if.SYSCOACK = inhouse_chi_if.sysco_ack;
`elsif SVT_CHI_ISSUE_D_ENABLE
     inhouse_chi_if.sysco_req = svt_chi_if.SYSCOREQ ;
     svt_chi_if.SYSCOACK = inhouse_chi_if.sysco_ack;
`elsif SVT_CHI_ISSUE_E_ENABLE
     inhouse_chi_if.sysco_req = svt_chi_if.SYSCOREQ ;
     svt_chi_if.SYSCOACK = inhouse_chi_if.sysco_ack;
`else
     inhouse_chi_if.sysco_req = 1 ;
`endif

    //-----------------------------------------------------------------------
    // Link Activation Status Signals
    //-----------------------------------------------------------------------
     inhouse_chi_if.tx_sactive = svt_chi_if.TXSACTIVE ; 
/* TBD USE_VIP_SNPS - Fix the discrepancy*/
     svt_chi_if.RXSACTIVE = inhouse_chi_if.rx_sactive; 
     //svt_chi_if.RXSACTIVE = 1; 

    //-----------------------------------------------------------------------
    // Link Activation Status Signals
    //-----------------------------------------------------------------------
     inhouse_chi_if.tx_link_active_req = svt_chi_if.TXLINKACTIVEREQ  ; 
     svt_chi_if.TXLINKACTIVEACK  = inhouse_chi_if.tx_link_active_ack ; 
     svt_chi_if.RXLINKACTIVEREQ  = inhouse_chi_if.rx_link_active_req ; 
     inhouse_chi_if.rx_link_active_ack = svt_chi_if.RXLINKACTIVEACK  ; 

    //-----------------------------------------------------------------------
    // TX Request Virtual Channel
    //-----------------------------------------------------------------------
     inhouse_chi_if.tx_req_flit_pend = svt_chi_if.TXREQFLITPEND ; 
     inhouse_chi_if.tx_req_flitv = svt_chi_if.TXREQFLITV    ; 
     inhouse_chi_if.tx_req_flit = svt_chi_if.TXREQFLIT     ; 
     svt_chi_if.TXREQLCRDV = inhouse_chi_if.tx_req_lcrdv   ;  

    //-----------------------------------------------------------------------
    // RX Response Virtual Channel
    //-----------------------------------------------------------------------
     svt_chi_if.RXRSPFLITPEND = inhouse_chi_if.rx_rsp_flit_pend  ;
     svt_chi_if.RXRSPFLITV    = inhouse_chi_if.rx_rsp_flitv      ;
     svt_chi_if.RXRSPFLIT     = inhouse_chi_if.rx_rsp_flit       ;
     inhouse_chi_if.rx_rsp_lcrdv = svt_chi_if.RXRSPLCRDV    ;

    //-----------------------------------------------------------------------
    // RX Dat Virtual Channel
    //-----------------------------------------------------------------------
     svt_chi_if.RXDATFLITPEND = inhouse_chi_if.rx_dat_flit_pend  ;
     svt_chi_if.RXDATFLITV    = inhouse_chi_if.rx_dat_flitv      ; 
     svt_chi_if.RXDATFLIT     = inhouse_chi_if.rx_dat_flit       ; 
     inhouse_chi_if.rx_dat_lcrdv = svt_chi_if.RXDATLCRDV    ; 

    //-----------------------------------------------------------------------
    // RX Snoop Virtual Channel
    //-----------------------------------------------------------------------
     svt_chi_if.RXSNPFLITPEND = inhouse_chi_if.rx_snp_flit_pend  ;
     svt_chi_if.RXSNPFLITV    = inhouse_chi_if.rx_snp_flitv      ;     
     svt_chi_if.RXSNPFLIT     = inhouse_chi_if.rx_snp_flit       ;    
     inhouse_chi_if.rx_snp_lcrdv = svt_chi_if.RXSNPLCRDV    ;     

    //-----------------------------------------------------------------------
    // TX Response Virtual Channel
    //-----------------------------------------------------------------------
     inhouse_chi_if.tx_rsp_flit_pend = svt_chi_if.TXRSPFLITPEND  ; 
     inhouse_chi_if.tx_rsp_flitv = svt_chi_if.TXRSPFLITV     ;
     inhouse_chi_if.tx_rsp_flit = svt_chi_if.TXRSPFLIT      ; 
     svt_chi_if.TXRSPLCRDV  = inhouse_chi_if.tx_rsp_lcrdv   ;

    //-----------------------------------------------------------------------
    // TX Dat Virtual Channel
    //-----------------------------------------------------------------------
     inhouse_chi_if.tx_dat_flit_pend = svt_chi_if.TXDATFLITPEND ;  
     inhouse_chi_if.tx_dat_flitv = svt_chi_if.TXDATFLITV    ;  
     inhouse_chi_if.tx_dat_flit = svt_chi_if.TXDATFLIT     ; 
     svt_chi_if.TXDATLCRDV  = inhouse_chi_if.tx_dat_lcrdv  ;
end //always     
`else // always_block
/* TBD USE_VIP_SNPS - Fix the discrepancy*/
`ifdef SVT_CHI_ISSUE_B_ENABLE
     assign inhouse_chi_if.sysco_req = svt_chi_if.SYSCOREQ ;
     assign svt_chi_if.SYSCOACK = inhouse_chi_if.sysco_ack;
`elsif SVT_CHI_ISSUE_C_ENABLE
     assign inhouse_chi_if.sysco_req = svt_chi_if.SYSCOREQ ;
     assign svt_chi_if.SYSCOACK = inhouse_chi_if.sysco_ack;
`elsif SVT_CHI_ISSUE_D_ENABLE
     assign inhouse_chi_if.sysco_req = svt_chi_if.SYSCOREQ ;
     assign svt_chi_if.SYSCOACK = inhouse_chi_if.sysco_ack;
`elsif SVT_CHI_ISSUE_E_ENABLE
     assign inhouse_chi_if.sysco_req = svt_chi_if.SYSCOREQ ;
     assign svt_chi_if.SYSCOACK = inhouse_chi_if.sysco_ack;
`else
     assign inhouse_chi_if.sysco_req = 1 ;
`endif    

    //-----------------------------------------------------------------------
    // Link Activation Status Signals
    //-----------------------------------------------------------------------
     assign inhouse_chi_if.tx_sactive = svt_chi_if.TXSACTIVE ; 
     assign svt_chi_if.RXSACTIVE = inhouse_chi_if.rx_sactive; 
/* TBD USE_VIP_SNPS - Fix the discrepancy*/
     //assign svt_chi_if.RXSACTIVE = 1; 

    //-----------------------------------------------------------------------
    // Link Activation Status Signals
    //-----------------------------------------------------------------------
     assign inhouse_chi_if.tx_link_active_req = svt_chi_if.TXLINKACTIVEREQ  ; 
     assign svt_chi_if.TXLINKACTIVEACK  = inhouse_chi_if.tx_link_active_ack ; 
     assign svt_chi_if.RXLINKACTIVEREQ  = inhouse_chi_if.rx_link_active_req ; 
     assign inhouse_chi_if.rx_link_active_ack = svt_chi_if.RXLINKACTIVEACK  ; 

    //-----------------------------------------------------------------------
    // TX Request Virtual Channel
    //-----------------------------------------------------------------------
     assign inhouse_chi_if.tx_req_flit_pend = svt_chi_if.TXREQFLITPEND ; 
     assign inhouse_chi_if.tx_req_flitv = svt_chi_if.TXREQFLITV    ; 
     assign inhouse_chi_if.tx_req_flit = svt_chi_if.TXREQFLIT     ; 
     assign svt_chi_if.TXREQLCRDV = inhouse_chi_if.tx_req_lcrdv   ;  

    //-----------------------------------------------------------------------
    // RX Response Virtual Channel
    //-----------------------------------------------------------------------
     assign svt_chi_if.RXRSPFLITPEND = inhouse_chi_if.rx_rsp_flit_pend  ;
     assign svt_chi_if.RXRSPFLITV    = inhouse_chi_if.rx_rsp_flitv      ;
     assign svt_chi_if.RXRSPFLIT     = inhouse_chi_if.rx_rsp_flit       ;
     assign inhouse_chi_if.rx_rsp_lcrdv = svt_chi_if.RXRSPLCRDV    ;

    //-----------------------------------------------------------------------
    // RX Dat Virtual Channel
    //-----------------------------------------------------------------------
     assign svt_chi_if.RXDATFLITPEND = inhouse_chi_if.rx_dat_flit_pend  ;
     assign svt_chi_if.RXDATFLITV    = inhouse_chi_if.rx_dat_flitv      ; 
     assign svt_chi_if.RXDATFLIT     = inhouse_chi_if.rx_dat_flit       ; 
     assign inhouse_chi_if.rx_dat_lcrdv = svt_chi_if.RXDATLCRDV    ; 

    //-----------------------------------------------------------------------
    // RX Snoop Virtual Channel
    //-----------------------------------------------------------------------
     assign svt_chi_if.RXSNPFLITPEND = inhouse_chi_if.rx_snp_flit_pend  ;
     assign svt_chi_if.RXSNPFLITV    = inhouse_chi_if.rx_snp_flitv      ;     
     assign svt_chi_if.RXSNPFLIT     = inhouse_chi_if.rx_snp_flit       ;    
     assign inhouse_chi_if.rx_snp_lcrdv = svt_chi_if.RXSNPLCRDV    ;     

    //-----------------------------------------------------------------------
    // TX Response Virtual Channel
    //-----------------------------------------------------------------------
     assign inhouse_chi_if.tx_rsp_flit_pend = svt_chi_if.TXRSPFLITPEND  ; 
     assign inhouse_chi_if.tx_rsp_flitv = svt_chi_if.TXRSPFLITV     ;
     assign inhouse_chi_if.tx_rsp_flit = svt_chi_if.TXRSPFLIT      ; 
     assign svt_chi_if.TXRSPLCRDV  = inhouse_chi_if.tx_rsp_lcrdv   ;

    //-----------------------------------------------------------------------
    // TX Dat Virtual Channel
    //-----------------------------------------------------------------------
     assign inhouse_chi_if.tx_dat_flit_pend = svt_chi_if.TXDATFLITPEND ;  
     assign inhouse_chi_if.tx_dat_flitv = svt_chi_if.TXDATFLITV    ;  
     assign inhouse_chi_if.tx_dat_flit = svt_chi_if.TXDATFLIT     ; 
     assign svt_chi_if.TXDATLCRDV  = inhouse_chi_if.tx_dat_lcrdv  ;
`endif  // always_block
endmodule   
<% } %>

<% if (obj.testBench == "fsys") { %>
module <%=obj.BlockId%>_connection_wrapper_to_svt_chi_rn_if (<%=obj.BlockId%>_chi_if inhouse_chi_if, svt_chi_rn_if svt_chi_if);
<% 
var chiaiu_range = [];

for(var j = 0; j < obj.AiuInfo.length; j++) { 
  if(obj.AiuInfo[j].fnNativeInterface.indexOf('CHI') >= 0) {
  chiaiu_range.push(j); 
 } }

var digit_loc=0;
var BlockId_arr = [];
BlockId_arr = obj.BlockId.split('');

for(var j = BlockId_arr.length-1; j>=0; j--) { 
  if(BlockId_arr[j] === '0' || BlockId_arr[j] === '1' || BlockId_arr[j] === '2'|| BlockId_arr[j] === '3'|| BlockId_arr[j] === '4'|| BlockId_arr[j] === '5'|| BlockId_arr[j] === '6'|| BlockId_arr[j] === '7'|| BlockId_arr[j] === '8'|| BlockId_arr[j] === '9') {
   digit_loc = digit_loc + 1;
  } else {
   break;
  }
}
var idx = obj.BlockId.slice(0-digit_loc);
var pidx = chiaiu_range[idx]; //extract by index
var chiaiu_data_width = obj.AiuInfo[pidx].interfaces.chiInt.params.wData;
var chiaiu_nodeid_width = obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID;
var chiaiu_addr_width = obj.AiuInfo[pidx].interfaces.chiInt.params.wAddr;
if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') {
var data_width_diff_to_max = max_data_width - chiaiu_data_width;
var nodeid_width_diff_to_max = max_node_id_width - chiaiu_nodeid_width;
var addr_width_diff_to_max = max_addr_width - chiaiu_addr_width;
} else {
var data_width_diff_to_max = 0;
var nodeid_width_diff_to_max = 0;
var addr_width_diff_to_max = 0;
}
var qos_width         = ((obj.AiuInfo[pidx].interfaces.chiInt.params.wQos>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.wQos:4);
var tgtid_width       = ((obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID:7);
var srcid_width       = ((obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID:7);
var txnid_width       = ((obj.AiuInfo[pidx].interfaces.chiInt.params.TxnID>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.TxnID:4);
var homenid_width     = ((obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID>0 && obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')?obj.AiuInfo[pidx].interfaces.chiInt.params.SrcID:0);
var opcode_width      = ((obj.AiuInfo[pidx].interfaces.chiInt.params.DAT_Opcode>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.DAT_Opcode:3);
var snp_opcode_width      = ((obj.AiuInfo[pidx].interfaces.chiInt.params.SNP_Opcode>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.SNP_Opcode:5);
var resp_opcode_width      = ((obj.AiuInfo[pidx].interfaces.chiInt.params.RSP_Opcode>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.RSP_Opcode:4);
var req_opcode_width      = ((obj.AiuInfo[pidx].interfaces.chiInt.params.REQ_Opcode>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.REQ_Opcode:6);
var resperr_width     = ((obj.AiuInfo[pidx].interfaces.chiInt.params.RespErr>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.RespErr:2);
var resp_width        = ((obj.AiuInfo[pidx].interfaces.chiInt.params.Resp>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.Resp:3);
var fwdstate_width    = ((obj.AiuInfo[pidx].interfaces.chiInt.params.FwdState>0 && obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')?obj.AiuInfo[pidx].interfaces.chiInt.params.FwdState:0);
var dbid_width        = ((obj.AiuInfo[pidx].interfaces.chiInt.params.DBID>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.DBID:8);
var ccid_width        = ((obj.AiuInfo[pidx].interfaces.chiInt.params.CCID>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.CCID:2);
var dataid_width      = ((obj.AiuInfo[pidx].interfaces.chiInt.params.DataID>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.DataID:2);
var tracetag_width    = ((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')?1:0);
var rsvdc_width       = ((obj.AiuInfo[pidx].interfaces.chiInt.params.DAT_RSVDC>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.DAT_RSVDC:0);
var req_rsvdc_width       = ((obj.AiuInfo[pidx].interfaces.chiInt.params.REQ_RSVDC>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.REQ_RSVDC:0);
var be_width          = ((obj.AiuInfo[pidx].interfaces.chiInt.params.BE>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.BE:(obj.AiuInfo[pidx].interfaces.chiInt.params.wData/8));
var data_width        = ((obj.AiuInfo[pidx].interfaces.chiInt.params.wData>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.wData:4);
var datacheck_width   = 0;
var poison_width      = ((obj.AiuInfo[pidx].interfaces.chiInt.params.wPoison>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.wPoison:0);
var pcrd_width      = ((obj.AiuInfo[pidx].interfaces.chiInt.params.PCrdType>0)?obj.AiuInfo[pidx].interfaces.chiInt.params.PCrdType:0);


console.log("fsys:connection_wrapper_to_svt_chi_rn_if: idx="+idx+",  pidx="+pidx+",chiaiu_data_width="+chiaiu_data_width+",chiaiu_nodeid_width="+chiaiu_nodeid_width+",chiaiu_addr_width="+chiaiu_addr_width+",max_data_width="+max_data_width+",max_addr_width="+max_addr_width+",max_node_id_width="+max_node_id_width+", digit_loc="+digit_loc);


let signalArr = [];
var chiaiu_prefix = obj.AiuInfo[pidx].strRtlNamePrefix;
for(var port=0; port<obj.ariaObj.PortList.length; port++) {
  var fullRTLSignal = obj.ariaObj.PortList[port].rtlSignal; 
  var finalInstName    = fullRTLSignal.split("_")[0];

  var fullDVSignal     = obj.ariaObj.PortList[port].dvSignal; 
  var fullSignalName   = fullDVSignal.split(".")[1]; 
  
  var obj1 = {};
  //if(finalInstName === 'caiu'+pidx && fullSignalName !==undefined ) {
  if(finalInstName === chiaiu_prefix && fullSignalName !==undefined ) {
  obj1.instName   = finalInstName; 
  obj1.signalName = fullSignalName.split("[")[0];
  }
  signalArr.push(obj1); 
  //console.log("fsys:connection_wrapper_to_svt_chi_rn_if signalArr="+JSON.stringify(signalArr) );
  }
%>
bit en_chiaiu_coherency_via_reg;  
bit sysco_attached_via_reg;
uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
static uvm_event ev_all_aiu_sysco_attached= ev_pool.get("ev_all_aiu_sysco_attached");

initial begin
    if (!$value$plusargs("en_chiaiu_coherency_via_reg=%0d",en_chiaiu_coherency_via_reg)) begin
        en_chiaiu_coherency_via_reg= 0; 
    end  
    ev_all_aiu_sysco_attached.wait_trigger();
    sysco_attached_via_reg = 1;
end
     /* TBD USE_VIP_SNPS - Fix the discrepancy*/
     <% if( signalArr.find(x => x.signalName === "sysco_req") ) { %> 
                                                                     `ifdef SVT_CHI_ISSUE_B_ENABLE
                                                                          assign inhouse_chi_if.sysco_req = (en_chiaiu_coherency_via_reg==0)?svt_chi_if.SYSCOREQ: 1'b0 ;
                                                                     `elsif SVT_CHI_ISSUE_C_ENABLE
                                                                          assign inhouse_chi_if.sysco_req = (en_chiaiu_coherency_via_reg==0)?svt_chi_if.SYSCOREQ: 1'b0 ;
                                                                     `elsif SVT_CHI_ISSUE_D_ENABLE
                                                                          assign inhouse_chi_if.sysco_req = (en_chiaiu_coherency_via_reg==0)?svt_chi_if.SYSCOREQ: 1'b0 ;
                                                                     `elsif SVT_CHI_ISSUE_E_ENABLE
                                                                          assign inhouse_chi_if.sysco_req = (en_chiaiu_coherency_via_reg==0)?svt_chi_if.SYSCOREQ: 1'b0 ;
                                                                     `else
                                                                          assign inhouse_chi_if.sysco_req = (en_chiaiu_coherency_via_reg==0)?1 : 1'b0;
                                                                     `endif
     <% } %>
     <% if( signalArr.find(x => x.signalName === "sysco_ack") ) { %> 
                                                                    `ifdef SVT_CHI_ISSUE_B_ENABLE
                                                                          assign svt_chi_if.SYSCOACK = (en_chiaiu_coherency_via_reg==0)?inhouse_chi_if.sysco_ack:( sysco_attached_via_reg && svt_chi_if.SYSCOREQ) ;
                                                                     `elsif SVT_CHI_ISSUE_C_ENABLE
                                                                          assign svt_chi_if.SYSCOACK = (en_chiaiu_coherency_via_reg==0)?inhouse_chi_if.sysco_ack:( sysco_attached_via_reg && svt_chi_if.SYSCOREQ) ;
                                                                     `elsif SVT_CHI_ISSUE_D_ENABLE
                                                                          assign svt_chi_if.SYSCOACK = (en_chiaiu_coherency_via_reg==0)?inhouse_chi_if.sysco_ack:( sysco_attached_via_reg && svt_chi_if.SYSCOREQ) ;
                                                                     `elsif SVT_CHI_ISSUE_E_ENABLE
                                                                          assign svt_chi_if.SYSCOACK = (en_chiaiu_coherency_via_reg==0)?inhouse_chi_if.sysco_ack:( sysco_attached_via_reg && svt_chi_if.SYSCOREQ) ;
                                                                     `endif
     <% } %>
    //-----------------------------------------------------------------------
    // Link Activation Status Signals
    //-----------------------------------------------------------------------
     <% if( signalArr.find(x => x.signalName === "tx_sactive") ) { %> assign inhouse_chi_if.tx_sactive = svt_chi_if.TXSACTIVE ; <% } %> 
     <% if( signalArr.find(x => x.signalName === "rx_sactive") ) { %> assign svt_chi_if.RXSACTIVE = inhouse_chi_if.rx_sactive ; <% } %> 
     /* TBD USE_VIP_SNPS - Fix the discrepancy*/
     //assign svt_chi_if.RXSACTIVE = 1;
    //-----------------------------------------------------------------------
    // Link Activation Status Signals
    //-----------------------------------------------------------------------
     <% if( signalArr.find(x => x.signalName === "tx_link_active_req") ) { %> assign inhouse_chi_if.tx_link_active_req = svt_chi_if.TXLINKACTIVEREQ  ; <% } %> 
     <% if( signalArr.find(x => x.signalName === "tx_link_active_ack") ) { %> assign svt_chi_if.TXLINKACTIVEACK  = inhouse_chi_if.tx_link_active_ack ; <% } %> 
     <% if( signalArr.find(x => x.signalName === "rx_link_active_req") ) { %> assign svt_chi_if.RXLINKACTIVEREQ  = inhouse_chi_if.rx_link_active_req ; <% } %> 
     <% if( signalArr.find(x => x.signalName === "rx_link_active_ack") ) { %> assign inhouse_chi_if.rx_link_active_ack = svt_chi_if.RXLINKACTIVEACK  ; <% } %> 

    //-----------------------------------------------------------------------
    // TX Request Virtual Channel
    //-----------------------------------------------------------------------
     <% if( signalArr.find(x => x.signalName === "tx_req_flit_pend") ) { %> assign inhouse_chi_if.tx_req_flit_pend = svt_chi_if.TXREQFLITPEND ; <% } %> 
     <% if( signalArr.find(x => x.signalName === "tx_req_flitv") ) { %> assign inhouse_chi_if.tx_req_flitv = svt_chi_if.TXREQFLITV    ; <% } %> 
     <% if( signalArr.find(x => x.signalName === "tx_req_flit") ) { %> 
     <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
     assign inhouse_chi_if.tx_req_flit = svt_chi_if.TXREQFLIT     ; 
     <% } else {%>
     assign inhouse_chi_if.tx_req_flit = 
     {
     <% if(addr_width_diff_to_max>0) { %>
     svt_chi_if.TXREQFLIT[<%=(3*nodeid_width_diff_to_max)+addr_width_diff_to_max+req_rsvdc_width+1+1+1+5+1+4+4+2+1+1+1+chiaiu_addr_width+3+req_opcode_width+8+1+srcid_width+txnid_width+srcid_width+srcid_width+qos_width%>-1:<%=(3*nodeid_width_diff_to_max)+addr_width_diff_to_max+chiaiu_addr_width+3+req_opcode_width+8+1+srcid_width+txnid_width+srcid_width+srcid_width+qos_width%>],
     svt_chi_if.TXREQFLIT[<%=(3*nodeid_width_diff_to_max)+chiaiu_addr_width+3+req_opcode_width+8+1+srcid_width+txnid_width+srcid_width+srcid_width+qos_width%>-1:<%=(3*nodeid_width_diff_to_max)+srcid_width+txnid_width+srcid_width+srcid_width+qos_width%>],
     <% } else {%>
     svt_chi_if.TXREQFLIT[<%=(3*nodeid_width_diff_to_max)+req_rsvdc_width+1+1+1+5+1+4+4+2+1+1+1+chiaiu_addr_width+3+req_opcode_width+8+1+srcid_width+txnid_width+srcid_width+srcid_width+qos_width%>-1:<%=srcid_width+nodeid_width_diff_to_max+txnid_width+nodeid_width_diff_to_max+srcid_width+nodeid_width_diff_to_max+srcid_width+qos_width%>],
     <% } %> 
     <% if(nodeid_width_diff_to_max>0) { %>
     svt_chi_if.TXREQFLIT[<%=srcid_width+txnid_width+nodeid_width_diff_to_max+srcid_width+nodeid_width_diff_to_max+srcid_width+qos_width%>-1:<%=nodeid_width_diff_to_max+srcid_width+nodeid_width_diff_to_max+srcid_width+qos_width%>],
     svt_chi_if.TXREQFLIT[<%=srcid_width+nodeid_width_diff_to_max+srcid_width+qos_width%>-1:<%=nodeid_width_diff_to_max+srcid_width+qos_width%>],
     svt_chi_if.TXREQFLIT[<%=srcid_width+qos_width%>-1:0]
     <% } else {%>
     svt_chi_if.TXREQFLIT[<%=srcid_width+txnid_width+srcid_width+srcid_width+qos_width%>-1:0]
     <% } %> 
     }; 
     <% } %> 
     <% } %> 
     <% if( signalArr.find(x => x.signalName === "tx_req_lcrdv") ) { %> assign svt_chi_if.TXREQLCRDV = inhouse_chi_if.tx_req_lcrdv   ; <% } %>  
    //-----------------------------------------------------------------------
    // RX Response Virtual Channel
    //-----------------------------------------------------------------------
     <% if( signalArr.find(x => x.signalName === "rx_rsp_flit_pend") ) { %> assign svt_chi_if.RXRSPFLITPEND = inhouse_chi_if.rx_rsp_flit_pend  ; <% } %>
     <% if( signalArr.find(x => x.signalName === "rx_rsp_flitv") ) { %> assign svt_chi_if.RXRSPFLITV    = inhouse_chi_if.rx_rsp_flitv      ; <% } %>
     <% if( signalArr.find(x => x.signalName === "rx_rsp_flit") ) { %> 
     <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
     assign svt_chi_if.RXRSPFLIT     = inhouse_chi_if.rx_rsp_flit       ; 
     <% } else {%>
     assign svt_chi_if.RXRSPFLIT     = 
     <% if(nodeid_width_diff_to_max>0) { %>
     {
     inhouse_chi_if.rx_rsp_flit[<%=tracetag_width+pcrd_width+dbid_width+3+resp_width+resperr_width+resp_opcode_width+txnid_width+srcid_width+srcid_width+qos_width%>-1:<%=srcid_width+srcid_width+qos_width%>], 
     <%=(nodeid_width_diff_to_max)%>'h0,
     inhouse_chi_if.rx_rsp_flit[<%=srcid_width+srcid_width+qos_width%>-1:<%=srcid_width+qos_width%>], 
     <%=(nodeid_width_diff_to_max)%>'h0,
     inhouse_chi_if.rx_rsp_flit[<%=srcid_width+qos_width%>-1:0]
     };
     <% } else {%>
     inhouse_chi_if.rx_rsp_flit       ; 
     <% } %> 
     <% } %>
     <% } %>
     <% if( signalArr.find(x => x.signalName === "rx_rsp_lcrdv") ) { %> assign inhouse_chi_if.rx_rsp_lcrdv = svt_chi_if.RXRSPLCRDV    ; <% } %>
    //-----------------------------------------------------------------------
    // RX Dat Virtual Channel
    //-----------------------------------------------------------------------
     <% if( signalArr.find(x => x.signalName === "rx_dat_flit_pend") ) { %> assign svt_chi_if.RXDATFLITPEND = inhouse_chi_if.rx_dat_flit_pend  ; <% } %>
     <% if( signalArr.find(x => x.signalName === "rx_dat_flitv") ) { %> assign svt_chi_if.RXDATFLITV    = inhouse_chi_if.rx_dat_flitv      ; <% } %> 
     <% if( signalArr.find(x => x.signalName === "rx_dat_flit") ) { %> 
     assign svt_chi_if.RXDATFLIT     = 
     {

     <% if(data_width_diff_to_max>0) { %>
        <% if((poison_width+datacheck_width)>0) { %>
        inhouse_chi_if.rx_dat_flit[<%=poison_width+datacheck_width+data_width+be_width+rsvdc_width+tracetag_width+dataid_width+ccid_width+dbid_width+fwdstate_width+resp_width+resperr_width+opcode_width+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=data_width+be_width+rsvdc_width+tracetag_width+dataid_width+ccid_width+dbid_width+fwdstate_width+resp_width+resperr_width+opcode_width+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>],
        <% } %>
        <%=(data_width_diff_to_max)%>'h0,
        inhouse_chi_if.rx_dat_flit[<%=data_width+be_width+rsvdc_width+tracetag_width+dataid_width+ccid_width+dbid_width+fwdstate_width+resp_width+resperr_width+opcode_width+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=be_width+rsvdc_width+tracetag_width+dataid_width+ccid_width+dbid_width+fwdstate_width+resp_width+resperr_width+opcode_width+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>],
        <%=(data_width_diff_to_max/8)%>'h0,
        inhouse_chi_if.rx_dat_flit[<%=be_width+rsvdc_width+tracetag_width+dataid_width+ccid_width+dbid_width+fwdstate_width+resp_width+resperr_width+opcode_width+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>],
     <% } else { %>
        inhouse_chi_if.rx_dat_flit[<%=poison_width+datacheck_width+data_width+be_width+rsvdc_width+tracetag_width+dataid_width+ccid_width+dbid_width+fwdstate_width+resp_width+resperr_width+opcode_width+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>],
     <% } %>
     <% if(nodeid_width_diff_to_max>0) { %>
       <%=nodeid_width_diff_to_max%>'h0,
       <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %> inhouse_chi_if.rx_dat_flit[<%=homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=txnid_width+srcid_width+tgtid_width+qos_width%>], <% } %>
       inhouse_chi_if.rx_dat_flit[<%=txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=srcid_width+tgtid_width+qos_width%>],
       <%=nodeid_width_diff_to_max%>'h0,
       inhouse_chi_if.rx_dat_flit[<%=srcid_width+tgtid_width+qos_width%>-1:<%=tgtid_width+qos_width%>],
       <%=nodeid_width_diff_to_max%>'h0,
       inhouse_chi_if.rx_dat_flit[<%=tgtid_width+qos_width%>-1:<%=qos_width%>],
     <% } else { %>
       <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %> inhouse_chi_if.rx_dat_flit[<%=homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=txnid_width+srcid_width+tgtid_width+qos_width%>], <% } %>
       inhouse_chi_if.rx_dat_flit[<%=txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=srcid_width+tgtid_width+qos_width%>],
       inhouse_chi_if.rx_dat_flit[<%=srcid_width+tgtid_width+qos_width%>-1:<%=tgtid_width+qos_width%>],
       inhouse_chi_if.rx_dat_flit[<%=tgtid_width+qos_width%>-1:<%=qos_width%>],
     <% } %>
       inhouse_chi_if.rx_dat_flit[<%=qos_width%>-1:0]
     }     ; 
     <% } %> 
     <% if( signalArr.find(x => x.signalName === "rx_dat_lcrdv") ) { %> assign inhouse_chi_if.rx_dat_lcrdv = svt_chi_if.RXDATLCRDV    ; <% } %> 
    //-----------------------------------------------------------------------
    // RX Snoop Virtual Channel
    //-----------------------------------------------------------------------
     <% if( signalArr.find(x => x.signalName === "rx_snp_flit_pend") ) { %> assign svt_chi_if.RXSNPFLITPEND = inhouse_chi_if.rx_snp_flit_pend  ; <% } %>
     <% if( signalArr.find(x => x.signalName === "rx_snp_flitv") ) { %> assign svt_chi_if.RXSNPFLITV    = inhouse_chi_if.rx_snp_flitv      ; <% } %>     
     <% if( signalArr.find(x => x.signalName === "rx_snp_flit") ) { %> 
     <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
     assign svt_chi_if.RXSNPFLIT     = inhouse_chi_if.rx_snp_flit; 
     <% } else {%>
     assign svt_chi_if.RXSNPFLIT     = 
     {
       inhouse_chi_if.rx_snp_flit[<%=4+chiaiu_addr_width-3+snp_opcode_width+txnid_width+srcid_width+txnid_width+srcid_width+qos_width%>:<%=chiaiu_addr_width-3+snp_opcode_width+txnid_width+srcid_width+txnid_width+srcid_width+qos_width%>],
     <% if(addr_width_diff_to_max>0) { %>
        <%=(addr_width_diff_to_max)%>'h0,
     <% } %>
     <% if(nodeid_width_diff_to_max>0) { %>
       inhouse_chi_if.rx_snp_flit[<%=chiaiu_addr_width-3+snp_opcode_width+txnid_width+srcid_width+txnid_width+srcid_width+qos_width%>-1:<%=srcid_width+txnid_width+srcid_width+qos_width%>],
        <%=(nodeid_width_diff_to_max)%>'h0,
       inhouse_chi_if.rx_snp_flit[<%=srcid_width+txnid_width+srcid_width+qos_width%>-1:<%=srcid_width+qos_width%>],
        <%=(nodeid_width_diff_to_max)%>'h0,
       inhouse_chi_if.rx_snp_flit[<%=srcid_width+qos_width%>-1:0]
     <% } else { %>
       inhouse_chi_if.rx_snp_flit[<%=chiaiu_addr_width-3+snp_opcode_width+txnid_width+srcid_width+txnid_width+srcid_width+qos_width%>-1:0]
     <% } %>
     }; 
     <% } %>    
     <% } %>    
     <% if( signalArr.find(x => x.signalName === "rx_snp_lcrdv") ) { %> assign inhouse_chi_if.rx_snp_lcrdv = svt_chi_if.RXSNPLCRDV    ; <% } %>     
    //-----------------------------------------------------------------------
    // TX Response Virtual Channel
    //-----------------------------------------------------------------------
     <% if( signalArr.find(x => x.signalName === "tx_rsp_flit_pend") ) { %> assign inhouse_chi_if.tx_rsp_flit_pend = svt_chi_if.TXRSPFLITPEND  ; <% } %> 
     <% if( signalArr.find(x => x.signalName === "tx_rsp_flitv") ) { %> assign inhouse_chi_if.tx_rsp_flitv = svt_chi_if.TXRSPFLITV     ; <% } %>
     <% if( signalArr.find(x => x.signalName === "tx_rsp_flit") ) { %> 
     <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
     assign inhouse_chi_if.tx_rsp_flit = svt_chi_if.TXRSPFLIT      ; 
     <% } else {%>
     assign inhouse_chi_if.tx_rsp_flit = 
     <% if(nodeid_width_diff_to_max>0) { %>
     {
     svt_chi_if.TXRSPFLIT[<%=tracetag_width+pcrd_width+dbid_width+3+resp_width+resperr_width+resp_opcode_width+txnid_width+nodeid_width_diff_to_max+nodeid_width_diff_to_max+srcid_width+srcid_width+qos_width%>-1:<%=nodeid_width_diff_to_max+nodeid_width_diff_to_max+srcid_width+srcid_width+qos_width%>],
     svt_chi_if.TXRSPFLIT[<%=nodeid_width_diff_to_max+srcid_width+srcid_width+qos_width%>-1:<%=nodeid_width_diff_to_max+srcid_width+qos_width%>],
     svt_chi_if.TXRSPFLIT[<%=srcid_width+qos_width%>-1:0]
     }; 
     <% } else { %>
     svt_chi_if.TXRSPFLIT;
     <% } %>
     <% } %> 
     <% } %> 
     <% if( signalArr.find(x => x.signalName === "tx_rsp_lcrdv") ) { %> assign svt_chi_if.TXRSPLCRDV  = inhouse_chi_if.tx_rsp_lcrdv   ; <% } %>
    //-----------------------------------------------------------------------
    // TX Dat Virtual Channel
    //-----------------------------------------------------------------------
     <% if( signalArr.find(x => x.signalName === "tx_dat_flit_pend") ) { %> assign inhouse_chi_if.tx_dat_flit_pend = svt_chi_if.TXDATFLITPEND ; <% } %>  
     <% if( signalArr.find(x => x.signalName === "tx_dat_flitv") ) { %> assign inhouse_chi_if.tx_dat_flitv = svt_chi_if.TXDATFLITV    ; <% } %>  
     <% if( signalArr.find(x => x.signalName === "tx_dat_flit") ) { %> 
     
     assign inhouse_chi_if.tx_dat_flit = //svt_chi_if.TXDATFLIT     ; 
     {

     <% if(data_width_diff_to_max>0) { %>
        <% if((poison_width+datacheck_width)>0) { %>
        svt_chi_if.TXDATFLIT[<%=poison_width+datacheck_width+data_width_diff_to_max+data_width+(data_width_diff_to_max/8)+be_width+rsvdc_width+tracetag_width+dataid_width+ccid_width+dbid_width+fwdstate_width+resp_width+resperr_width+opcode_width+(3*nodeid_width_diff_to_max)+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=data_width_diff_to_max+data_width+(data_width_diff_to_max/8)+be_width+rsvdc_width+tracetag_width+dataid_width+ccid_width+dbid_width+fwdstate_width+resp_width+resperr_width+opcode_width+(3*nodeid_width_diff_to_max)+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>],
        <% } %>
        svt_chi_if.TXDATFLIT[<%=data_width+(data_width_diff_to_max/8)+be_width+rsvdc_width+tracetag_width+dataid_width+ccid_width+dbid_width+fwdstate_width+resp_width+resperr_width+opcode_width+(3*nodeid_width_diff_to_max)+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=(data_width_diff_to_max/8)+be_width+rsvdc_width+tracetag_width+dataid_width+ccid_width+dbid_width+fwdstate_width+resp_width+resperr_width+opcode_width+(3*nodeid_width_diff_to_max)+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>],
        svt_chi_if.TXDATFLIT[<%=be_width+rsvdc_width+tracetag_width+dataid_width+ccid_width+dbid_width+fwdstate_width+resp_width+resperr_width+opcode_width+(3*nodeid_width_diff_to_max)+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=(3*nodeid_width_diff_to_max)+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>],
     <% } else { %>
        svt_chi_if.TXDATFLIT[<%=poison_width+datacheck_width+data_width+be_width+rsvdc_width+tracetag_width+dataid_width+ccid_width+dbid_width+fwdstate_width+resp_width+resperr_width+opcode_width+(3*nodeid_width_diff_to_max)+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=(3*nodeid_width_diff_to_max)+homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>],
     <% } %>
     <% if(nodeid_width_diff_to_max>0) { %>
       <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %> svt_chi_if.TXDATFLIT[<%=homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=txnid_width+srcid_width+tgtid_width+qos_width%>], <% } %>
       svt_chi_if.TXDATFLIT[<%=txnid_width+(2*nodeid_width_diff_to_max)+srcid_width+tgtid_width+qos_width%>-1:<%=(2*nodeid_width_diff_to_max)+srcid_width+tgtid_width+qos_width%>],
       svt_chi_if.TXDATFLIT[<%=srcid_width+tgtid_width+nodeid_width_diff_to_max+qos_width%>-1:<%=tgtid_width+nodeid_width_diff_to_max+qos_width%>],
       svt_chi_if.TXDATFLIT[<%=tgtid_width+qos_width%>-1:<%=qos_width%>],
     <% } else { %>
       <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %> svt_chi_if.TXDATFLIT[<%=homenid_width+txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=txnid_width+srcid_width+tgtid_width+qos_width%>], <% } %>
       svt_chi_if.TXDATFLIT[<%=txnid_width+srcid_width+tgtid_width+qos_width%>-1:<%=srcid_width+tgtid_width+qos_width%>],
       svt_chi_if.TXDATFLIT[<%=srcid_width+tgtid_width+qos_width%>-1:<%=tgtid_width+qos_width%>],
       svt_chi_if.TXDATFLIT[<%=tgtid_width+qos_width%>-1:<%=qos_width%>],
     <% } %>
       svt_chi_if.TXDATFLIT[<%=qos_width%>-1:0]
     }     ; 
     
     <% } %> 
     <% if( signalArr.find(x => x.signalName === "tx_dat_lcrdv") ) { %> assign svt_chi_if.TXDATLCRDV  = inhouse_chi_if.tx_dat_lcrdv  ; <% } %>

////////////////////////////////////////////////////////////////////////
/////
//Tieoffs
/////
////////////////////////////////////////////////////////////////////////
     /* TBD USE_VIP_SNPS - Fix the discrepancy*/
     <% if( !signalArr.find(x => x.signalName === "sysco_req") ) { %> assign inhouse_chi_if.sysco_req = 1 ; <% } %>
    //-----------------------------------------------------------------------
    // Link Activation Status Signals
    //-----------------------------------------------------------------------
     <% if( !signalArr.find(x => x.signalName === "tx_sactive") ) { %> assign inhouse_chi_if.tx_sactive = 0; <% } %> 
     /* TBD USE_VIP_SNPS - Fix the discrepancy*/
    //-----------------------------------------------------------------------
    // Link Activation Status Signals
    //-----------------------------------------------------------------------
     <% if( !signalArr.find(x => x.signalName === "tx_link_active_req") ) { %> assign inhouse_chi_if.tx_link_active_req = 0; <% } %> 
     <% if( !signalArr.find(x => x.signalName === "tx_link_active_ack") ) { %> assign svt_chi_if.TXLINKACTIVEACK  = 0 ; <% } %> 
     <% if( !signalArr.find(x => x.signalName === "rx_link_active_req") ) { %> assign svt_chi_if.RXLINKACTIVEREQ  = 0 ; <% } %> 
     <% if( !signalArr.find(x => x.signalName === "rx_link_active_ack") ) { %> assign inhouse_chi_if.rx_link_active_ack = 0; <% } %> 

    //-----------------------------------------------------------------------
    // TX Request Virtual Channel
    //-----------------------------------------------------------------------
     <% if( !signalArr.find(x => x.signalName === "tx_req_flit_pend") ) { %> assign inhouse_chi_if.tx_req_flit_pend = 0; <% } %> 
     <% if( !signalArr.find(x => x.signalName === "tx_req_flitv") ) { %> assign inhouse_chi_if.tx_req_flitv = 0; <% } %> 
     <% if( !signalArr.find(x => x.signalName === "tx_req_flit") ) { %> assign inhouse_chi_if.tx_req_flit = 0; <% } %> 
     <% if( !signalArr.find(x => x.signalName === "tx_req_lcrdv") ) { %> assign svt_chi_if.TXREQLCRDV = 0   ; <% } %>  
    //-----------------------------------------------------------------------
    // RX Response Virtual Channel
    //-----------------------------------------------------------------------
     <% if( !signalArr.find(x => x.signalName === "rx_rsp_flit_pend") ) { %> assign svt_chi_if.RXRSPFLITPEND = 0; <% } %>
     <% if( !signalArr.find(x => x.signalName === "rx_rsp_flitv") ) { %> assign svt_chi_if.RXRSPFLITV    = 0; <% } %>
     <% if( !signalArr.find(x => x.signalName === "rx_rsp_flit") ) { %> assign svt_chi_if.RXRSPFLIT     = 0; <% } %>
     <% if( !signalArr.find(x => x.signalName === "rx_rsp_lcrdv") ) { %> assign inhouse_chi_if.rx_rsp_lcrdv = 0; <% } %>
    //-----------------------------------------------------------------------
    // RX Dat Virtual Channel
    //-----------------------------------------------------------------------
     <% if( !signalArr.find(x => x.signalName === "rx_dat_flit_pend") ) { %> assign svt_chi_if.RXDATFLITPEND =   0; <% } %>
     <% if( !signalArr.find(x => x.signalName === "rx_dat_flitv") ) { %> assign svt_chi_if.RXDATFLITV    =   0; <% } %> 
     <% if( !signalArr.find(x => x.signalName === "rx_dat_flit") ) { %>   assign svt_chi_if.RXDATFLIT     =   0; <% } %> 
     <% if( !signalArr.find(x => x.signalName === "rx_dat_lcrdv") ) { %> assign inhouse_chi_if.rx_dat_lcrdv = 0; <% } %> 
    //-----------------------------------------------------------------------
    // RX Snoop Virtual Channel
    //-----------------------------------------------------------------------
     <% if( !signalArr.find(x => x.signalName === "rx_snp_flit_pend") ) { %> assign svt_chi_if.RXSNPFLITPEND =   0; <% } %>
     <% if( !signalArr.find(x => x.signalName === "rx_snp_flitv") ) { %> assign svt_chi_if.RXSNPFLITV    =       0; <% } %>     
     <% if( !signalArr.find(x => x.signalName === "rx_snp_flit") ) { %> assign svt_chi_if.RXSNPFLIT     =        0; <% } %>    
     <% if( !signalArr.find(x => x.signalName === "rx_snp_lcrdv") ) { %> assign inhouse_chi_if.rx_snp_lcrdv = 0; <% } %>     
    //-----------------------------------------------------------------------
    // TX Response Virtual Channel
    //-----------------------------------------------------------------------
     <% if( !signalArr.find(x => x.signalName === "tx_rsp_flit_pend") ) { %> assign inhouse_chi_if.tx_rsp_flit_pend = 0; <% } %> 
     <% if( !signalArr.find(x => x.signalName === "tx_rsp_flitv") ) { %> assign inhouse_chi_if.tx_rsp_flitv = 0; <% } %>
     <% if( !signalArr.find(x => x.signalName === "tx_rsp_flit") ) { %> assign inhouse_chi_if.tx_rsp_flit = 0; <% } %> 
     <% if( !signalArr.find(x => x.signalName === "tx_rsp_lcrdv") ) { %> assign svt_chi_if.TXRSPLCRDV  = 0   ; <% } %>
    //-----------------------------------------------------------------------
    // TX Dat Virtual Channel
    //-----------------------------------------------------------------------
     <% if( !signalArr.find(x => x.signalName === "tx_dat_flit_pend") ) { %> assign inhouse_chi_if.tx_dat_flit_pend = 0; <% } %>  
     <% if( !signalArr.find(x => x.signalName === "tx_dat_flitv") ) { %> assign inhouse_chi_if.tx_dat_flitv = 0; <% } %>  
     <% if( !signalArr.find(x => x.signalName === "tx_dat_flit") ) { %> assign inhouse_chi_if.tx_dat_flit = 0; <% } %> 
     <% if( !signalArr.find(x => x.signalName === "tx_dat_lcrdv") ) { %> assign svt_chi_if.TXDATLCRDV  = inhouse_chi_if.tx_dat_lcrdv  ; <% } %>
endmodule
<% } %>
 
