// Notes: ArrayId = 0 to read/write tag memory and 1 for data memroy
// TODO:
// 1. confirm the values of ErrType and ErrInfo register fields for
//    single/double bit errors and errors in tag/data memory
// 2. Guard single/double bit error tests with Partiy/SECDED protection type

<% if(obj.useCmc){%>
<%
  var wDataNoProt = obj.DmiInfo[obj.Id].ccpParams.wData* obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank + 1 ; // 1bit of poison
  var wDataArrayEntry = wDataNoProt + (obj.DmiInfo[obj.Id].ccpParams.DataErrInfo == "PARITYENTRY" ? 1 : (obj.DmiInfo[obj.Id].ccpParams.DataErrInfo == "SECDED" ? (Math.ceil(Math.log2(wDataNoProt + Math.ceil(Math.log2(wDataNoProt)) + 1)) + 1):0));
  var wTagNoProt  = obj.DmiInfo[obj.Id].ccpParams.wAddr - obj.DmiInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length - obj.DmiInfo[obj.Id].ccpParams.wCacheLineOffset + obj.DmiInfo[obj.Id].ccpParams.wSecurity // TagWidth
                    + obj.DmiInfo[obj.Id].ccpParams.wStateBits // State
                     // Only add when replacement policy is NRU
                    + (((obj.DmiInfo[obj.Id].ccpParams.nWays > 1) && (obj.DmiInfo[obj.Id].ccpParams.RepPolicy !== 'RANDOM') && (obj.DmiInfo[obj.Id].ccpParams.nRPPorts === 1)) ? 1 : 0);
  var wTagArrayEntry = wTagNoProt + (obj.DmiInfo[obj.Id].ccpParams.TagErrInfo == "PARITYENTRY" ? 1 : (obj.DmiInfo[obj.Id].ccpParams.TagErrInfo == "SECDED" ? (Math.ceil(Math.log2(wTagNoProt + Math.ceil(Math.log2(wTagNoProt)) + 1)) + 1):0));
  var smiQosEn = 0;
  var NSMIIFTX = obj.DmiInfo[obj.Id].nSmiRx;
  var NSMIIFRX = obj.DmiInfo[obj.Id].nSmiTx;
  for (var i = 0; i < NSMIIFRX; i++) {
    if(obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiMsgQos >0){ smiQosEn = 1;}
  }
  for (var i = 0; i < NSMIIFTX; i++) {
    if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiMsgQos >0){ smiQosEn = 1;}
  }
%>

string tag_fnerrdetectcorrect = "<%=obj.DmiInfo[obj.Id].ccpParams.TagErrInfo%>";
string data_fnerrdetectcorrect = "<%=obj.DmiInfo[obj.Id].ccpParams.DataErrInfo%>";

bit tag_secded = (("<%=obj.DmiInfo[obj.Id].ccpParams.TagErrInfo%>" == "SECDED") ||
                  ("<%=obj.DmiInfo[obj.Id].ccpParams.TagErrInfo%>" == "SECDED64BITS") ||
                  ("<%=obj.DmiInfo[obj.Id].ccpParams.TagErrInfo%>" == "SECDED128BITS"));

bit tag_parity = (("<%=obj.DmiInfo[obj.Id].ccpParams.TagErrInfo%>" == "PARITYENTRY") ||
                  ("<%=obj.DmiInfo[obj.Id].ccpParams.TagErrInfo%>" == "PARITY8BITS") ||
                  ("<%=obj.DmiInfo[obj.Id].ccpParams.TagErrInfo%>" == "PARITY16BITS"));

bit data_secded = (("<%=obj.DmiInfo[obj.Id].ccpParams.DataErrInfo%>" == "SECDED") ||
                   ("<%=obj.DmiInfo[obj.Id].ccpParams.DataErrInfo%>" == "SECDED64BITS") ||
                   ("<%=obj.DmiInfo[obj.Id].ccpParams.DataErrInfo%>" == "SECDED128BITS"));

bit data_parity = (("<%=obj.DmiInfo[obj.Id].ccpParams.DataErrInfo%>" == "PARITYENTRY") ||
                   ("<%=obj.DmiInfo[obj.Id].ccpParams.DataErrInfo%>" == "PARITY8BITS") ||
                   ("<%=obj.DmiInfo[obj.Id].ccpParams.DataErrInfo%>" == "PARITY16BITS"));
<%}%>
bit wbuffer_parity = (("<%=obj.DmiInfo[obj.Id].fnErrDetectCorrect%>" == "PARITYENTRY") ||
                      ("<%=obj.DmiInfo[obj.Id].fnErrDetectCorrect%>" == "PARITY8BITS") ||
                      ("<%=obj.DmiInfo[obj.Id].fnErrDetectCorrect%>" == "PARITY16BITS"));

bit wbuffer_secded = (("<%=obj.DmiInfo[obj.Id].fnErrDetectCorrect%>" == "SECDED") ||
                      ("<%=obj.DmiInfo[obj.Id].fnErrDetectCorrect%>" == "SECDED64BITS") ||
                      ("<%=obj.DmiInfo[obj.Id].fnErrDetectCorrect%>" == "SECDED128BITS"));

<% var has_secded = 0;
 if (obj.DmiInfo[obj.Id].useCmc) {
   if ((obj.DmiInfo[obj.Id].ccpParams.TagErrInfo === "SECDED") || (obj.DmiInfo[obj.Id].ccpParams.DataErrInfo === "SECDED") || (obj.DmiInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") || (obj.DmiInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) {
    has_secded = 1;
    console.log("has_secded: "+has_secded);
   }
 }
var wbuffer_fnerrdetectcorrect = 0;
if (obj.DmiInfo[obj.Id].fnErrDetectCorrect == "SECDED" || obj.DmiInfo[obj.Id].fnErrDetectCorrect == "PARITYENTRY") {
  wbuffer_fnerrdetectcorrect = 1;
}

var mrd_sram_secded = 0;
var cmd_sram_secded = 0;
var mrd_sram_parity = 0;
var cmd_sram_parity = 0;

if(obj.DmiInfo[obj.Id].fnErrDetectCorrect == "SECDED"){
  if(obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM") { 
    mrd_sram_secded = 1;
  }
  if(obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { 
    cmd_sram_secded = 1;
  }  
}
else if(obj.DmiInfo[obj.Id].fnErrDetectCorrect == "PARITYENTRY"){
  if(obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM") { 
    mrd_sram_parity = 1;
  }
  if(obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { 
    cmd_sram_parity = 1;
  } 
}
%>

//-----------------------------------------------------------------------
//   base method for dmi 
//-----------------------------------------------------------------------
class dmi_ral_csr_base_seq extends ral_csr_base_seq;

    virtual dmi_csr_probe_if u_csr_probe_vif;
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev = ev_pool.get("ev");
    uvm_event inject_err = ev_pool.get("inject_err");
    uvm_event ev_always_inject_error = ev_pool.get("ev_always_inject_error");
    uvm_event ev_bresp = ev_pool.get("ev_bresp");
    uvm_event ev_rresp = ev_pool.get("ev_rresp");
    uvm_event ev_wrong_targ_id = ev_pool.get("ev_wrong_targ_id");

    localparam ADDR_WIDTH_WBUF  = $clog2(((2**(<%=obj.wCacheLineOffset%>)*8)/ <%=obj.DmiInfo[obj.Id].wData%>)*( <%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%>))-1;

    bit [ADDR_WIDTH_WBUF:0] wbuf_addr;

    virtual <%=obj.BlockId%>_apb_if  apb_vif;

    uvm_event         injectSingleErrwbuffer0;
    uvm_event         injectDoubleErrwbuffer0;
    uvm_event         inject_multi_block_single_double_Errwbuffer0;
    uvm_event         inject_multi_block_double_Errwbuffer0;
    uvm_event         inject_multi_block_single_Errwbuffer0;
    uvm_event         injectAddrErrBuffer0;

    uvm_event         injectSingleErrwbuffer1;
    uvm_event         injectDoubleErrwbuffer1;
    uvm_event         inject_multi_block_single_double_Errwbuffer1;
    uvm_event         inject_multi_block_double_Errwbuffer1;
    uvm_event         inject_multi_block_single_Errwbuffer1;
    uvm_event         injectAddrErrBuffer1;

  <% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM") { %>
    uvm_event         injectSingleDataErrMrdSRAM;
    uvm_event         injectDoubleDataErrMrdSRAM;
    uvm_event         injectSingleAddrErrMrdSRAM;
  <% } %>
  <% if (obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
    uvm_event         injectSingleDataErrCmdSRAM;
    uvm_event         injectDoubleDataErrCmdSRAM;
    uvm_event         injectSingleAddrErrCmdSRAM;
  <% } %>
<% if(obj.useCmc) { %>
  <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nTagBanks;i++){%>
    uvm_event         injectSingleErrTag<%=i%>;
    uvm_event         injectDoubleErrTag<%=i%>;
    uvm_event         inject_multi_block_single_double_ErrTag<%=i%>;
    uvm_event         inject_multi_block_double_ErrTag<%=i%>;
    uvm_event         inject_multi_block_single_ErrTag<%=i%>;
    uvm_event         injectAddrErrTag<%=i%>;
  <% } %>
  <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nDataBanks;i++){%>
    uvm_event         injectSingleErrData<%=i%>;
    uvm_event         injectDoubleErrData<%=i%>;
    uvm_event         inject_multi_block_single_double_ErrData<%=i%>;
    uvm_event         inject_multi_block_double_ErrData<%=i%>;
    uvm_event         inject_multi_block_single_ErrData<%=i%>;
    uvm_event         injectAddrErrData<%=i%>;
  <% } %>
  <%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
    uvm_event setPlruSingleDataErrInj, setPlruDoubleDataErrInj;
    uvm_event setPlruAddrErrInj;
  <% } %>
<% } %>
    dmi_env_config m_cfg;
    dmi_scoreboard dmi_scb;
    string LABEL= "dmi_ral_csr_base_seq";

    function new(string name="dmi_ral_csr_base_seq");
      super.new(name);
    endfunction

    function get_cfg();
      if(!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                       .inst_name( get_full_name() ),
                                       .field_name( "dmi_env_config" ),
                                       .value( m_cfg ))) begin
        `uvm_error(LABEL, "dmi_env_config handle not found")
      end
      if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                              .inst_name( "*" ),
                                              .field_name( "dmi_scb" ),
                                              .value( dmi_scb ))) begin
         `uvm_error(LABEL, "dmi_scb model not found")
      end
    endfunction

    function getInjectErrEvent();

      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectSingleErrwbuffer0"),
                                          .value(injectSingleErrwbuffer0)))
        `uvm_error(get_name,"Failed to get error event for single error wbuffer0")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectDoubleErrwbuffer0"),
                                          .value(injectDoubleErrwbuffer0)))
        `uvm_error(get_name,"Failed to get error event for double error wbuffer0")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_double_Errwbuffer0"),
                                          .value(inject_multi_block_single_double_Errwbuffer0)))
        `uvm_error(get_name,"Failed to get error event for multi block single double error wbuffer0")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_double_Errwbuffer0"),
                                          .value(inject_multi_block_double_Errwbuffer0)))
        `uvm_error(get_name,"Failed to get error event for multi block double error wbuffer0")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_Errwbuffer0"),
                                          .value(inject_multi_block_single_Errwbuffer0)))
        `uvm_error(get_name,"Failed to get error event for multi block single error wbuffer0")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name( this.get_full_name() ),
                                          .field_name( "injectAddrErrBuffer0" ),
                                          .value( injectAddrErrBuffer0)))
        `uvm_error(get_name,"Failed to get error event for inject address error wbuffer0") 
  
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectSingleErrwbuffer1"),
                                          .value(injectSingleErrwbuffer1)))
        `uvm_error(get_name,"Failed to get error event for single error wbuffer1")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectDoubleErrwbuffer1"),
                                          .value(injectDoubleErrwbuffer1)))
        `uvm_error(get_name,"Failed to get error event for double error wbuffer1")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_double_Errwbuffer1"),
                                          .value(inject_multi_block_single_double_Errwbuffer1)))
        `uvm_error(get_name,"Failed to get error event for multi block single double error wbuffer1")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_double_Errwbuffer1"),
                                          .value(inject_multi_block_double_Errwbuffer1)))
        `uvm_error(get_name,"Failed to get error event for multi block double error wbuffer1")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_Errwbuffer1"),
                                          .value(inject_multi_block_single_Errwbuffer1)))
        `uvm_error(get_name,"Failed to get error event for multi block single error wbuffer1")   
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name( this.get_full_name() ),
                                          .field_name( "injectAddrErrBuffer1" ),
                                          .value( injectAddrErrBuffer1)))
        `uvm_error(get_name,"Failed to get error event for inject address error wbuffer1")   
<% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM") { %>
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectSingleDataErrMrdSRAM" ),
                                          .value(injectSingleDataErrMrdSRAM))) begin
        `uvm_error(get_name,"Failed to get error event for MRD SRAM Inject Single Data Error")
      end
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectDoubleDataErrMrdSRAM" ),
                                          .value(injectDoubleDataErrMrdSRAM))) begin
        `uvm_error(get_name,"Failed to get error event for MRD SRAM Inject Double Data Error")
      end
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectSingleAddrErrMrdSRAM" ),
                                          .value(injectSingleAddrErrMrdSRAM))) begin
        `uvm_error(get_name,"Failed to get error event for MRD SRAM Inject Address Error")
      end
<% } %>
<% if (obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectSingleDataErrCmdSRAM" ),
                                          .value(injectSingleDataErrCmdSRAM))) begin
        `uvm_error(get_name,"Failed to get error event for CMD SRAM Inject Single Data Error")
      end
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectDoubleDataErrCmdSRAM" ),
                                          .value(injectDoubleDataErrCmdSRAM))) begin
        `uvm_error(get_name,"Failed to get error event for CMD SRAM Inject Double Data Error")
      end
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectSingleAddrErrCmdSRAM" ),
                                          .value(injectSingleAddrErrCmdSRAM))) begin
        `uvm_error(get_name,"Failed to get error event for CMD SRAM Inject Address Error")
      end
<% } %>
<% if(obj.useCmc) { %>
      <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nTagBanks;i++){%>
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectSingleErrTag<%=i%>"),
                                          .value(injectSingleErrTag<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for single error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectDoubleErrTag<%=i%>"),
                                          .value(injectDoubleErrTag<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for double error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_double_ErrTag<%=i%>"),
                                          .value(inject_multi_block_single_double_ErrTag<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block single double error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_double_ErrTag<%=i%>"),
                                          .value(inject_multi_block_double_ErrTag<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block double error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_ErrTag<%=i%>"),
                                          .value(inject_multi_block_single_ErrTag<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block single error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                        .inst_name( this.get_full_name() ),
                                        .field_name( "injectAddrErrTag<%=i%>" ),
                                        .value(injectAddrErrTag<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for inject address error tag")
      <% } %>
      <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nDataBanks;i++){%>
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectSingleErrData<%=i%>"),
                                          .value(injectSingleErrData<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for single error data")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectDoubleErrData<%=i%>"),
                                          .value(injectDoubleErrData<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for double error data")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_double_ErrData<%=i%>"),
                                          .value(inject_multi_block_single_double_ErrData<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block single double error data")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_double_ErrData<%=i%>"),
                                          .value(inject_multi_block_double_ErrData<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block double error data")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_ErrData<%=i%>"),
                                          .value(inject_multi_block_single_ErrData<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block single error data")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                        .inst_name( this.get_full_name() ),
                                        .field_name( "injectAddrErrData<%=i%>" ),
                                        .value(injectAddrErrData<%=i%>)))      
        `uvm_error(get_name,"Failed to get error event for inject address error data")
<% } %>
<%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
    if(!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                        .inst_name( this.get_full_name() ),
                                        .field_name( "setPlruSingleDataErrInj" ),
                                        .value(setPlruSingleDataErrInj))) begin
      `uvm_error(get_name,"Failed to get error event for PLRU Single Data error injection")
    end
    if(!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                        .inst_name( this.get_full_name() ),
                                        .field_name( "setPlruDoubleDataErrInj" ),
                                        .value(setPlruDoubleDataErrInj))) begin
      `uvm_error(get_name,"Failed to get error event for PLRU Double Data error injection")
    end
    if(!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                        .inst_name( this.get_full_name() ),
                                        .field_name( "setPlruAddrErrInj" ),
                                        .value(setPlruAddrErrInj))) begin
      `uvm_error(get_name,"Failed to get error event for PLRU address error injection")
    end
<% } %>
<% } %>

    endfunction

    task body();
      get_cfg();
    endtask
  <% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM") { %>
    task inject_mrd_sram_error(input int error_threshold = 1, int delay_btwn_err_inj = 1, bit serial_err_inj = 0);
      int i;
      semaphore sema = new(1);

      int no_of_single_bit_data_errors_injected;
      int no_of_double_bit_data_errors_injected;
      int no_of_address_errors_injected;

      `uvm_info("INJECT_MRD_SRAM_ERROR",$sformatf("error_threshold = %0h",error_threshold),UVM_LOW)
      fork
        do begin
          sema.get(1);
          `uvm_info("INJECT_MRD_SRAM_ERROR",$sformatf("fork--begin i:%0d error_threshold= %0d",i,error_threshold),UVM_DEBUG)
          if(i < error_threshold) begin
            if(!serial_err_inj) begin
              i++;
              sema.put(1);
            end
            if(m_cfg.m_args.k_sram_single_bit_error) begin
              injectSingleDataErrMrdSRAM.trigger();
              @(negedge u_csr_probe_vif.inject_mrd_data_single_next);
              no_of_single_bit_data_errors_injected++;
            end
            if(m_cfg.m_args.k_sram_double_bit_error) begin
              injectDoubleDataErrMrdSRAM.trigger();
              @(negedge u_csr_probe_vif.inject_mrd_data_double_next);
              no_of_double_bit_data_errors_injected++;
            end
            if(m_cfg.m_args.k_sram_address_error) begin
              injectSingleAddrErrMrdSRAM.trigger();
              @(negedge u_csr_probe_vif.inject_mrd_addr_next);
              no_of_address_errors_injected++;
            end
            repeat(delay_btwn_err_inj) begin
              @(negedge u_csr_probe_vif.clk);
            end
            if(serial_err_inj) begin
              i++;
              sema.put(1);
            end
          end
          `uvm_info("INJECT_MRD_SRAM_ERROR",$sformatf("fork--end i:%0d error_threshold= %0d",i,error_threshold),UVM_DEBUG)
        end while(i < error_threshold);
      join
      `uvm_info("INJECT_MRD_SRAM_ERROR",$sformatf("no_of_single_bit_data_errors_injected=%0d",no_of_single_bit_data_errors_injected),UVM_LOW)
      `uvm_info("INJECT_MRD_SRAM_ERROR",$sformatf("no_of_double_bit_data_errors_injected=%0d",no_of_double_bit_data_errors_injected),UVM_LOW)
      `uvm_info("INJECT_MRD_SRAM_ERROR",$sformatf("no_of_address_errors_injected=%0d",no_of_address_errors_injected),UVM_LOW)
    endtask
  <% } %>
  <% if (obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
    task inject_cmd_sram_error(input int error_threshold = 1, int delay_btwn_err_inj = 1, bit serial_err_inj = 0);
      int i;
      semaphore sema = new(1);

      int no_of_single_bit_data_errors_injected;
      int no_of_double_bit_data_errors_injected;
      int no_of_address_errors_injected;

      `uvm_info("INJECT_CMD_SRAM_ERROR",$sformatf("error_threshold = %0h",error_threshold),UVM_LOW)
      fork
        do begin
          sema.get(1);
          `uvm_info("INJECT_CMD_SRAM_ERROR",$sformatf("fork--begin i:%0d error_threshold= %0d",i,error_threshold),UVM_DEBUG)
          if(i < error_threshold) begin
            if(!serial_err_inj) begin
              i++;
              sema.put(1);
            end
            if(m_cfg.m_args.k_sram_single_bit_error) begin
              injectSingleDataErrCmdSRAM.trigger();
              @(negedge u_csr_probe_vif.inject_cmd_data_single_next);
              no_of_single_bit_data_errors_injected++;
            end
            if(m_cfg.m_args.k_sram_double_bit_error) begin
              injectDoubleDataErrCmdSRAM.trigger();
              @(negedge u_csr_probe_vif.inject_cmd_data_double_next);
              no_of_double_bit_data_errors_injected++;
            end
            if(m_cfg.m_args.k_sram_address_error) begin
              injectSingleAddrErrCmdSRAM.trigger();
              @(negedge u_csr_probe_vif.inject_cmd_addr_next);
              no_of_address_errors_injected++;
            end
            repeat(delay_btwn_err_inj) begin
              @(negedge u_csr_probe_vif.clk);
            end
            if(serial_err_inj) begin
              i++;
              sema.put(1);
            end
          end
          `uvm_info("INJECT_CMD_SRAM_ERROR",$sformatf("fork--end i:%0d error_threshold= %0d",i,error_threshold),UVM_DEBUG)
        end while(i < error_threshold);
      join
      `uvm_info("INJECT_CMD_SRAM_ERROR",$sformatf("no_of_single_bit_data_errors_injected=%0d",no_of_single_bit_data_errors_injected),UVM_LOW)
      `uvm_info("INJECT_CMD_SRAM_ERROR",$sformatf("no_of_double_bit_data_errors_injected=%0d",no_of_double_bit_data_errors_injected),UVM_LOW)
      `uvm_info("INJECT_CMD_SRAM_ERROR",$sformatf("no_of_address_errors_injected=%0d",no_of_address_errors_injected),UVM_LOW)
    endtask
  <% } %>

    task inject_error(input int error_threshold = 1, input int delay_btwn_err_inj = 1, input bit serial_err_inj = 0, output bit [ADDR_WIDTH_WBUF:0] wbuffer_addr);
      int i,j,k;
      semaphore sema_tag=new(1);
      semaphore sema_data=new(1);
      semaphore sema_wbuffer=new(1);

      int no_of_sngl_bit_wbuffer_err_injected_bank_1;
      int no_of_dbl_bit_wbuffer_err_injected_bank_1;
      int no_of_mlt_blk_sngl_dbl_bit_wbuffer_err_injected_bank_1;
      int no_of_mlt_blk_dbl_bit_wbuffer_err_injected_bank_1;
      int no_of_mlt_blk_sngl_bit_wbuffer_err_injected_bank_1;

      int no_of_sngl_bit_wbuffer_err_injected_bank_0;
      int no_of_dbl_bit_wbuffer_err_injected_bank_0;
      int no_of_mlt_blk_sngl_dbl_bit_wbuffer_err_injected_bank_0;
      int no_of_mlt_blk_dbl_bit_wbuffer_err_injected_bank_0;
      int no_of_mlt_blk_sngl_bit_wbuffer_err_injected_bank_0;

    <%if(obj.useCmc) { %>
      <%if(obj.DmiInfo[obj.Id].ccpParams.TagErrInfo.substring(0,6) === "SECDED" || obj.DmiInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") {%>
        <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nTagBanks;i++){%>
          int no_of_sngl_bit_tag_err_injected_bank_<%=i%>;
          int no_of_dbl_bit_tag_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_sngl_dbl_bit_tag_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_dbl_bit_tag_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_sngl_bit_tag_err_injected_bank_<%=i%>;
        <% } %>
      <% } %>
      <%if(obj.DmiInfo[obj.Id].ccpParams.DataErrInfo.substring(0,6) === "SECDED" || obj.DmiInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY") {%>
        <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nDataBanks;i++){%>
          int no_of_sngl_bit_data_err_injected_bank_<%=i%>;
          int no_of_dbl_bit_data_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_sngl_dbl_bit_data_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_dbl_bit_data_err_injected_bank_<%=i%>;
          int no_of_mlt_blk_sngl_bit_data_err_injected_bank_<%=i%>;
        <% } %>
      <% } %>
    <% } %>
    `uvm_info("INJECT_ERROR",$sformatf("error_threshold = %0h",error_threshold),UVM_NONE)
    fork
      do begin
          sema_wbuffer.get(1);
          if (k < error_threshold) begin
            if(!serial_err_inj) begin
              k++;
              sema_wbuffer.put(1);
            end
            if($test$plusargs("wbuffer_single_bit_error_test")) begin
              injectSingleErrwbuffer0.trigger();
              @(negedge u_csr_probe_vif.inject_wbuffer0_single_next); 
              wbuffer_addr = {u_csr_probe_vif.wbuffer0_addr,1'b0};
              no_of_sngl_bit_wbuffer_err_injected_bank_0++;
            end
            if($test$plusargs("wbuffer_double_bit_error_test")) begin
              injectDoubleErrwbuffer0.trigger();
              @(negedge u_csr_probe_vif.inject_wbuffer0_double_next); 
              wbuffer_addr = {u_csr_probe_vif.wbuffer0_addr,1'b0};
              no_of_dbl_bit_wbuffer_err_injected_bank_0++;
            end
            if($test$plusargs("wbuffer_multi_blk_single_double_bit_error_test")) begin
              inject_multi_block_single_double_Errwbuffer0.trigger();
              @(negedge u_csr_probe_vif.inject_wbuffer0_single_double_multi_blk_next); 
              wbuffer_addr = {u_csr_probe_vif.wbuffer0_addr,1'b0};
              no_of_mlt_blk_sngl_dbl_bit_wbuffer_err_injected_bank_0++;
            end
            if($test$plusargs("wbuffer_multi_blk_double_bit_error_test")) begin
              inject_multi_block_double_Errwbuffer0.trigger();
              @(negedge u_csr_probe_vif.inject_wbuffer0_double_multi_blk_next); 
              wbuffer_addr = {u_csr_probe_vif.wbuffer0_addr,1'b0};
              no_of_mlt_blk_dbl_bit_wbuffer_err_injected_bank_0++;
            end
            if($test$plusargs("wbuffer_multi_blk_single_bit_error_test")) begin
              inject_multi_block_single_Errwbuffer0.trigger();
              @(negedge u_csr_probe_vif.inject_wbuffer0_single_multi_blk_next); 
              wbuffer_addr = {u_csr_probe_vif.wbuffer0_addr,1'b0};
              no_of_mlt_blk_sngl_bit_wbuffer_err_injected_bank_0++;
            end
            if($test$plusargs("address_error_test_wbuff")) begin
      	      injectAddrErrBuffer0.trigger();
              @(negedge u_csr_probe_vif.inject_wbuffer0_addr_next);
	          end
  
            repeat(delay_btwn_err_inj) begin
              @(negedge u_csr_probe_vif.clk);
            end
            if (serial_err_inj) begin
              k++;
              sema_wbuffer.put(1);
            end
          end else begin 
            sema_wbuffer.put(1);
          end
      end while (k < error_threshold);

      do begin
          sema_wbuffer.get(1);
          if (k < error_threshold) begin
            if (!serial_err_inj) begin
              k++;
              sema_wbuffer.put(1);
            end
            if ($test$plusargs("wbuffer_single_bit_error_test")) begin
                injectSingleErrwbuffer1.trigger();
                @(negedge u_csr_probe_vif.inject_wbuffer1_single_next); 
                wbuffer_addr = {u_csr_probe_vif.wbuffer1_addr,1'b1};
                no_of_sngl_bit_wbuffer_err_injected_bank_1++;
            end
            if ($test$plusargs("wbuffer_double_bit_error_test")) begin
                injectDoubleErrwbuffer1.trigger();
                @(negedge u_csr_probe_vif.inject_wbuffer1_double_next); 
                wbuffer_addr = {u_csr_probe_vif.wbuffer1_addr,1'b1};
                no_of_dbl_bit_wbuffer_err_injected_bank_1++;
            end
            if ($test$plusargs("wbuffer_multi_blk_single_double_bit_error_test")) begin
                inject_multi_block_single_double_Errwbuffer1.trigger();
                @(negedge u_csr_probe_vif.inject_wbuffer1_single_double_multi_blk_next); 
                wbuffer_addr = {u_csr_probe_vif.wbuffer1_addr,1'b1};
                no_of_mlt_blk_sngl_dbl_bit_wbuffer_err_injected_bank_1++;
            end
            if ($test$plusargs("wbuffer_multi_blk_double_bit_error_test")) begin
                inject_multi_block_double_Errwbuffer1.trigger();
                @(negedge u_csr_probe_vif.inject_wbuffer1_double_multi_blk_next); 
                wbuffer_addr = {u_csr_probe_vif.wbuffer1_addr,1'b1};
                no_of_mlt_blk_dbl_bit_wbuffer_err_injected_bank_1++;
            end
            if ($test$plusargs("wbuffer_multi_blk_single_bit_error_test")) begin
                inject_multi_block_single_Errwbuffer1.trigger();
                @(negedge u_csr_probe_vif.inject_wbuffer1_single_multi_blk_next); 
                wbuffer_addr = {u_csr_probe_vif.wbuffer1_addr,1'b1};
                no_of_mlt_blk_sngl_bit_wbuffer_err_injected_bank_1++;
            end
            if($test$plusargs("address_error_test_wbuff")) begin
                injectAddrErrBuffer1.trigger();
                @(negedge u_csr_probe_vif.inject_wbuffer1_addr_next); 
            end
            
              repeat(delay_btwn_err_inj) begin
              @(negedge u_csr_probe_vif.clk);
            end
            if (serial_err_inj) begin
              k++;
              sema_wbuffer.put(1);
            end
          end else begin 
            sema_wbuffer.put(1);
          end
      end while (k < error_threshold);
    join

    <% if(obj.useCmc) { %>
      fork
        <%if(obj.DmiInfo[obj.Id].ccpParams.TagErrInfo.substring(0,6) === "SECDED" || obj.DmiInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") {%>
          <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nTagBanks;i++){%>
        do begin
          sema_tag.get(1);
          if (i < error_threshold) begin 
            if (!serial_err_inj) begin
              i++;
              sema_tag.put(1);
            end
            if ($test$plusargs("ccp_single_bit_tag_direct_error_test")) begin
                injectSingleErrTag<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_tag_single_next<%=i%>); 
                no_of_sngl_bit_tag_err_injected_bank_<%=i%>++;
            end
            if ($test$plusargs("ccp_double_bit_direct_tag_error_test")) begin
                injectDoubleErrTag<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_tag_double_next<%=i%>); 
                no_of_dbl_bit_tag_err_injected_bank_<%=i%>++;
            end
            if ($test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test")) begin
                inject_multi_block_single_double_ErrTag<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_tag_single_double_multi_blk_next<%=i%>); 
                no_of_mlt_blk_sngl_dbl_bit_tag_err_injected_bank_<%=i%>++;
            end
            if ($test$plusargs("ccp_multi_blk_double_tag_direct_error_test")) begin
                inject_multi_block_double_ErrTag<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_tag_double_multi_blk_next<%=i%>); 
                no_of_mlt_blk_dbl_bit_tag_err_injected_bank_<%=i%>++;
            end
            if ($test$plusargs("ccp_multi_blk_single_tag_direct_error_test")) begin
                inject_multi_block_single_ErrTag<%=i%>.trigger();
                @(negedge u_csr_probe_vif.inject_tag_single_multi_blk_next<%=i%>); 
                no_of_mlt_blk_sngl_bit_tag_err_injected_bank_<%=i%>++;
            end
            if($test$plusargs("address_error_test_tag")) begin
                  injectAddrErrTag<%=i%>.trigger();
                  @(negedge u_csr_probe_vif.inject_tag_addr_next<%=i%>);
            end
            repeat(delay_btwn_err_inj) begin
              @(negedge u_csr_probe_vif.clk);
            end
            if (serial_err_inj) begin
              i++;
              sema_tag.put(1);
            end
          end else begin
            sema_tag.put(1);
          end
        end while (i < error_threshold);
          <% } %>
        <% } %>
        <%if(obj.DmiInfo[obj.Id].ccpParams.DataErrInfo.substring(0,6) === "SECDED" || obj.DmiInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY") {%>
          <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nDataBanks;i++){%>
        do begin
          sema_data.get(1);
          if (j < error_threshold) begin
            if (!serial_err_inj) begin
              j++;
              sema_data.put(1);
            end
            if($test$plusargs("ccp_single_bit_data_direct_error_test")) begin
              injectSingleErrData<%=i%>.trigger();
              @(negedge u_csr_probe_vif.inject_data_single_next<%=i%>); 
              no_of_sngl_bit_data_err_injected_bank_<%=i%>++;
            end
            if($test$plusargs("ccp_double_bit_data_direct_error_test")) begin
              injectDoubleErrData<%=i%>.trigger();
              @(negedge u_csr_probe_vif.inject_data_double_next<%=i%>); 
              no_of_dbl_bit_data_err_injected_bank_<%=i%>++;
            end
            if($test$plusargs("ccp_multi_blk_single_double_data_direct_error_test")) begin
              inject_multi_block_single_double_ErrData<%=i%>.trigger();
              @(negedge u_csr_probe_vif.inject_data_single_double_multi_blk_next<%=i%>); 
              no_of_mlt_blk_sngl_dbl_bit_data_err_injected_bank_<%=i%>++;
            end
            if($test$plusargs("ccp_multi_blk_double_data_direct_error_test")) begin
              inject_multi_block_double_ErrData<%=i%>.trigger();
              @(negedge u_csr_probe_vif.inject_data_double_multi_blk_next<%=i%>); 
              no_of_mlt_blk_dbl_bit_data_err_injected_bank_<%=i%>++;
            end
            if($test$plusargs("ccp_multi_blk_single_data_direct_error_test")) begin
              inject_multi_block_single_ErrData<%=i%>.trigger();
              @(negedge u_csr_probe_vif.inject_data_single_multi_blk_next<%=i%>); 
              no_of_mlt_blk_sngl_bit_data_err_injected_bank_<%=i%>++;
            end
            if($test$plusargs("address_error_test_data")) begin
		           injectAddrErrData<%=i%>.trigger();
               @(negedge u_csr_probe_vif.inject_data_addr_next<%=i%>);
            end
            repeat(delay_btwn_err_inj) begin
              @(negedge u_csr_probe_vif.clk);
            end
            if(serial_err_inj) begin
              j++;
              sema_data.put(1);
            end
          end else begin 
            sema_data.put(1);
          end
        end while (j < error_threshold);
          <% } %>
        <% } %>
      join

      <%if(obj.DmiInfo[obj.Id].ccpParams.TagErrInfo.substring(0,6) === "SECDED" || obj.DmiInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") {%>
        <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nTagBanks;i++){%>
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_single_bit_tag_error_injected_bank_<%=i%> = %0h",no_of_sngl_bit_tag_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_double_bit_tag_error_injected_bank_<%=i%> = %0h",no_of_dbl_bit_tag_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_double_bit_tag_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_sngl_dbl_bit_tag_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_double_bit_tag_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_dbl_bit_tag_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_bit_tag_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_sngl_bit_tag_err_injected_bank_<%=i%>),UVM_NONE)
        <% } %>
      <% } %>
      <%if(obj.DmiInfo[obj.Id].ccpParams.DataErrInfo.substring(0,6) === "SECDED" || obj.DmiInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY") {%>
        <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nDataBanks;i++){%>
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_single_bit_data_error_injected_bank_<%=i%> = %0h",no_of_sngl_bit_data_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_double_bit_data_error_injected_bank_<%=i%> = %0h",no_of_dbl_bit_data_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_double_bit_data_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_sngl_dbl_bit_data_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_double_bit_data_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_dbl_bit_data_err_injected_bank_<%=i%>),UVM_NONE)
          `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_bit_data_error_injected_bank_<%=i%> = %0h",no_of_mlt_blk_sngl_bit_data_err_injected_bank_<%=i%>),UVM_NONE)
        <% } %>
      <% } %>
    <% } %>
      `uvm_info("INJECT_ERROR",$sformatf("number_of_time_single_bit_wbuffer_error_injected_bank_0 = %0h",no_of_sngl_bit_wbuffer_err_injected_bank_0),UVM_NONE)
      `uvm_info("INJECT_ERROR",$sformatf("number_of_time_double_bit_wbuffer_error_injected_bank_0 = %0h",no_of_dbl_bit_wbuffer_err_injected_bank_0),UVM_NONE)
      `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_double_bit_wbuffer_error_injected_bank_0 = %0h",no_of_mlt_blk_sngl_dbl_bit_wbuffer_err_injected_bank_0),UVM_NONE)
      `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_double_bit_wbuffer_error_injected_bank_0 = %0h",no_of_mlt_blk_dbl_bit_wbuffer_err_injected_bank_0),UVM_NONE)
      `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_bit_wbuffer_error_injected_bank_0 = %0h",no_of_mlt_blk_sngl_bit_wbuffer_err_injected_bank_0),UVM_NONE)

      `uvm_info("INJECT_ERROR",$sformatf("number_of_time_single_bit_wbuffer_error_injected_bank_1 = %0h",no_of_sngl_bit_wbuffer_err_injected_bank_1),UVM_NONE)
      `uvm_info("INJECT_ERROR",$sformatf("number_of_time_double_bit_wbuffer_error_injected_bank_1 = %0h",no_of_dbl_bit_wbuffer_err_injected_bank_1),UVM_NONE)
      `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_double_bit_wbuffer_error_injected_bank_1 = %0h",no_of_mlt_blk_sngl_dbl_bit_wbuffer_err_injected_bank_1),UVM_NONE)
      `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_double_bit_wbuffer_error_injected_bank_1 = %0h",no_of_mlt_blk_dbl_bit_wbuffer_err_injected_bank_1),UVM_NONE)
      `uvm_info("INJECT_ERROR",$sformatf("number_of_time_multi_block_single_bit_wbuffer_error_injected_bank_1 = %0h",no_of_mlt_blk_sngl_bit_wbuffer_err_injected_bank_1),UVM_NONE)
    endtask
   
    function getCsrProbeIf();
        if(!uvm_config_db#(virtual dmi_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif))
            `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    endfunction // checkCsrProbeIf
     
    function control_mrd_delay(input bit long_delay=0);
      <% for (var i = 0; i < obj.DmiInfo[0].nSmiTx; i++) { 
      if (obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fnMsgClass[0] == "mrd_rsp_") { %>
        m_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif.k_delay_min = long_delay ? 10000 : 5;
        m_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif.k_delay_max = long_delay ? 11000 : 10;
        m_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif.k_burst_pct = long_delay ? 0     : 100;
      <%} }%>
    endfunction

    function control_cmd_delay(input bit long_delay=0);
      <% for (var i = 0; i < obj.DmiInfo[0].nSmiTx; i++) {
      if (obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fnMsgClass[0] == "cmd_rsp_") { %>
        m_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif.k_delay_min = long_delay ? 10000 : 5;
        m_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif.k_delay_max = long_delay ? 11000 : 10;
        m_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif.k_burst_pct = long_delay ? 0     : 100;
      <%} }%>
    endfunction

    task poll_DMIUCESR_ErrVld(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld,poll_till,fieldVal);
    endtask

    task poll_DMIUUESR_ErrVld(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld,poll_till,fieldVal);
    endtask

    task poll_DMIUCESR_ErrCount(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount,poll_till,fieldVal);
    endtask

    task poll_DMIUCESR_ErrCountOverflow(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow,poll_till,fieldVal);
    endtask

    function bit [`UVM_REG_ADDR_WIDTH-1 : 0] get_unmapped_csr_addr();
      bit [`UVM_REG_ADDR_WIDTH-1 : 0] all_csr_addr[$];
      typedef struct packed {
                             bit [`UVM_REG_ADDR_WIDTH-1 : 0] lower_addr;
                             bit [`UVM_REG_ADDR_WIDTH-1 : 0] upper_addr;
                            } csr_addr;
      csr_addr csr_unmapped_addr_range[$];
      int randomly_selected_unmapped_csr_sddr;
      
      <% obj.DmiInfo[obj.Id].csr.spaceBlock[0].registers.forEach(function GetAllregAddr(item,i){ %>
                                  //all_csr_addr.push_back({12'h<%=obj.DmiInfo[obj.Id].nrri%>,8'h<%=obj.DmiInfo[obj.Id].rpn%>,12'h<%=item.addressOffset%>});
                                  all_csr_addr.push_back(<%=item.addressOffset%>);
                               <% }); %>
      all_csr_addr.sort();
      `uvm_info(get_full_name(),$sformatf("all_csr_addr : %0p",all_csr_addr),UVM_NONE);
      for (int i = 0; i <= (all_csr_addr.size() - 2); i++) begin 
        if ((all_csr_addr[i+1] - all_csr_addr[i]) > 'h4) begin
          csr_unmapped_addr_range.push_back({(all_csr_addr[i]+'h4),(all_csr_addr[i+1]-4)});
        end
      end
      `uvm_info(get_full_name(),$sformatf("csr_unmapped_addr_range : %0p",csr_unmapped_addr_range),UVM_NONE);
      randomly_selected_unmapped_csr_sddr = $urandom_range((csr_unmapped_addr_range.size()-1),0);
      get_unmapped_csr_addr = $urandom_range(csr_unmapped_addr_range[randomly_selected_unmapped_csr_sddr].lower_addr,csr_unmapped_addr_range[randomly_selected_unmapped_csr_sddr].upper_addr);
      `uvm_info(get_full_name(),$sformatf("unmapped_csr_addr : 0x%0x",get_unmapped_csr_addr),UVM_NONE);
    endfunction : get_unmapped_csr_addr

    function void get_apb_if();
      if (!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("apb_if"),
                                          .value(apb_vif)))
        `uvm_error(get_name,"Failed to get apb if")
    endfunction
  <%if (obj.DmiInfo[obj.Id].fnErrDetectCorrect != "NONE") {%>
    task program_xCECR(bit int_en, bit det_en, bit[7:0] threshold);
      `uvm_info("RUN_MAIN",$sformatf("Programming CECR | ErrIntEn:%0b ErrDetEn:%0b Threshold:%0d",int_en,det_en,threshold),UVM_LOW)
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, int_en);
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, det_en);
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, threshold);
    endtask
  

    task program_xUEDR_xUEIR(bit det_en, bit int_en);
      `uvm_info("RUN_MAIN",$sformatf("Programming UEDR | ErrDetEn:%0b || UEIR | ErrIntEn:%0b",det_en,int_en),UVM_LOW)
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, det_en);
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, int_en);
    endtask
  <% } %>
    task check_IRQ_C(bit expected);
      if(expected) begin
        if(u_csr_probe_vif.IRQ_C === 1)begin
          `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupt asseretd"), UVM_LOW)
        end else begin
          `uvm_error("RUN_MAIN",$sformatf("IRQ_C interrupt still de-asserted"));
        end       
      end
      else begin
        if(u_csr_probe_vif.IRQ_C === 0)begin
          `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupt de-asserted"), UVM_LOW)
        end else begin
          `uvm_error("RUN_MAIN",$sformatf("IRQ_C interrupt still asserted"));
        end
      end
    endtask


    task check_IRQ_UC(bit expected);
      if(expected) begin
        if(u_csr_probe_vif.IRQ_UC === 1)begin
          `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupt asseretd"), UVM_LOW)
        end else begin
          `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interrupt still de-asserted"));
        end       
      end
      else begin
        if(u_csr_probe_vif.IRQ_UC === 0)begin
          `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupt de-asserted"), UVM_LOW)
        end else begin
          `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interrupt still asserted"));
        end
      end
    endtask

    task wait_on_IRQ_C(bit expected);
      if(expected) begin
        fork 
          begin
            `uvm_info("RUN_MAIN",$sformatf("Waiting for a correctable interrupt. It should trigger"), UVM_LOW)
            @(u_csr_probe_vif.IRQ_C);
            `uvm_info("RUN_MAIN", $sformatf("Expected correctable interrupt registered"),UVM_LOW)
          end
          begin
            #50000ns;
            `uvm_error("RUN_MAIN",$sformatf("Done waiting. No correctable interrupt received"))
          end
        join_any
      end
      else begin
        fork 
          begin
            `uvm_info("RUN_MAIN",$sformatf("Waiting for correctable interrupt. It should not trigger"), UVM_LOW)
            @(u_csr_probe_vif.IRQ_C);
            `uvm_error("RUN_MAIN", $sformatf("Unexpected correctable interrupt!"))
          end
          begin
            #500ns;
            `uvm_info("RUN_MAIN",$sformatf("Done waiting. No correctable interrupt received"), UVM_LOW)
          end
        join_any
      end
      disable fork;
    endtask
 <% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM") { %>
    task wait_on_mrd_sram_init_done();
      fork
        begin
          `uvm_info("RUN_MAIN",$sformatf("Waiting for MRD SRAM Initializion to complete"), UVM_LOW)
          if(u_csr_probe_vif.mrd_sram_init_done == 0) begin
            @(posedge u_csr_probe_vif.mrd_sram_init_done);
            `uvm_info("RUN_MAIN", $sformatf("MRD SRAM Initializion complete"),UVM_LOW)
          end
          else begin
            `uvm_info("RUN_MAIN", $sformatf("MRD SRAM already initialized"),UVM_LOW)
          end
        end
        begin
          #5ms;
          `uvm_error("RUN_MAIN",$sformatf("MRD SRAM Initializion incomplete"))
        end
      join_any
    endtask
 <%}%>
 <% if (obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
    task wait_on_cmd_sram_init_done();
      fork
        begin
          `uvm_info("RUN_MAIN",$sformatf("Waiting for CMD SRAM Initializion to complete"), UVM_LOW)
          if(u_csr_probe_vif.cmd_sram_init_done == 0) begin
            @(posedge u_csr_probe_vif.cmd_sram_init_done);
            `uvm_info("RUN_MAIN", $sformatf("CMD SRAM Initializion complete"),UVM_LOW)
          end
          else begin
            `uvm_info("RUN_MAIN", $sformatf("CMD SRAM already initialized"),UVM_LOW)
          end
        end
        begin
          #5ms;
          `uvm_error("RUN_MAIN",$sformatf("CMD SRAM Initializion incomplete"))
        end
      join_any
    endtask
 <%}%>
    task wait_on_IRQ_UC(bit expected);
      if(expected) begin
        fork 
          begin
            `uvm_info("RUN_MAIN",$sformatf("Waiting for an uncorrectable interrupt. It should trigger"), UVM_LOW)
            @(u_csr_probe_vif.IRQ_UC);
            `uvm_info("RUN_MAIN", $sformatf("Expected uncorrectable interrupt registered"),UVM_LOW)
          end
          begin
            #50000ns;
            `uvm_error("RUN_MAIN",$sformatf("Done waiting. No uncorrectable interrupt received"))
          end
        join_any
      end
      else begin
        fork 
          begin
            `uvm_info("RUN_MAIN",$sformatf("Waiting for an uncorrectable interrupt. It should not trigger"), UVM_LOW)
            @(u_csr_probe_vif.IRQ_UC);
            `uvm_error("RUN_MAIN", $sformatf("Unexpected uncorrectable interrupt!"))
          end
          begin
            #500ns;
            `uvm_info("RUN_MAIN",$sformatf("Done waiting. No uncorrectable interrupt received"), UVM_LOW)
          end
        join_any
      end
      disable fork;
    endtask
endclass : dmi_ral_csr_base_seq

class access_unmapped_csr_addr extends dmi_ral_csr_base_seq;
  `uvm_object_utils(access_unmapped_csr_addr)
  bit [`UVM_REG_ADDR_WIDTH-1 : 0] unmapped_csr_addr;
  apb_pkt_t apb_pkt;

  function new(string name="");
      super.new(name);
  endfunction

  task body();
    get_apb_if();
    ev.trigger();
    unmapped_csr_addr = get_unmapped_csr_addr();
    apb_pkt = apb_pkt_t::type_id::create("apb_pkt");
    apb_pkt.paddr = unmapped_csr_addr;
    apb_pkt.pwrite = 1;
    apb_pkt.psel = 1;
    apb_pkt.pwdata = $urandom;
    apb_vif.drive_apb_channel(apb_pkt);
  endtask
endclass : access_unmapped_csr_addr

class dmi_csr_CMO_test_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_CMO_test_seq)
  uvm_reg_data_t read_data, write_data, write_data_to_compare,lookupen;
  rand bit [5:0]  cache_word;
  rand bit [5:0]  cache_way;
  rand bit [19:0] cache_entry;
  rand bit [5:0]  cache_arrayId;
  bit [31:0] mask =32'hffff_ffff;
  bit security;
  dmi_scoreboard dmi_scb;

  <% if (obj.DmiInfo[obj.Id].useCmc){ %>
  constraint c_nSets  { cache_entry >= 0; cache_entry < <%=obj.DmiInfo[obj.Id].ccpParams.nSets%>;}
  constraint c_nWays  { cache_way >= 0; cache_way < <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>;}  
  <%}%>

  function new(string name="");
      super.new(name);
  endfunction

  task body();
    <% if (obj.DmiInfo[obj.Id].useCmc){ %>
    if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                               .inst_name( "*" ),
                                               .field_name( "dmi_scb" ),
                                               .value( dmi_scb ))) begin
      `uvm_error("dmi_csr_CMO_test_seq", "dmi_scb model not found")
    end

    if(dmi_scb.m_dmi_cache_q.size()==0) begin
        `uvm_warning("dmi_csr_CMO_test_seq", "No entry in cache to inject errors, skipping CMO sequence")
    end
    else begin
      foreach(dmi_scb.m_dmi_cache_q[i]) begin
        mask = 32'hFFFF_FFFF;
        // lookupen should be random, Ncore 3.0 release support lookupen = 1 and will be fix in lated release, CONC-7176.
        //lookupen = $urandom_range(0,1);
        lookupen = 1;
        `uvm_info("CMO_TEST_SEQ",$sformatf("configuring lookupen: 0x%0x",lookupen),UVM_NONE)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCTCR.LookupEn, lookupen);
        cache_entry = dmi_scb.m_dmi_cache_q[i].Index;
        cache_way = dmi_scb.m_dmi_cache_q[i].way;
        security = dmi_scb.m_dmi_cache_q[i].security;
        cache_arrayId = $urandom_range(0,1);
        `uvm_info("CMO_TEST_SEQ",$sformatf("configuring Array_Id: 0x%0x",cache_arrayId),UVM_NONE)
        //#Check.DMI.Concerto.v3.6.WordLookup
        if(cache_arrayId) begin
          <% if(obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2 && obj.DmiInfo[obj.Id].ccpParams.wData == 256) { %>  
             //256 wdata| words 0->16 | beat 0 | nBeats/Bank 2
             cache_word = $urandom_range(0,16);
             mask &= (cache_word[4:0] == <%=Math.ceil(wDataArrayEntry/32)-1%> ) ? ((32'h1 << <%=(wDataArrayEntry%32)-1%>)-32'h1): mask;
          <%}else if( (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2 && obj.DmiInfo[obj.Id].ccpParams.wData == 128) ||
                       (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 1 && obj.DmiInfo[obj.Id].ccpParams.wData == 256) ){%>
             //256 wdata| words 0->16 | beat 0->1 | nBeats/Bank 2
             //128 wdata| words 0->16 | beat 0->1 | nBeats/Bank 2
             bit status = 0;
             status = std::randomize(cache_word) with  { cache_word inside {[0:8],[16:24]};};
             if(!status) `uvm_error("CMO_TEST_SEQ","Randomization failure on cache_word")
             mask &= (cache_word[3:0] == <%=Math.ceil(wDataArrayEntry/32)-1%> ) ? ((32'h1 << <%=(wDataArrayEntry%32)-1%>)-32'h1): mask;
          <%}else if( obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 1 && obj.DmiInfo[obj.Id].ccpParams.wData == 128) {%>
             bit status = 0;
             status = std::randomize(cache_word) with  { cache_word inside {[0:4],[8:12],[16:20],[24:28]};};
             if(!status) `uvm_error("CMO_TEST_SEQ","Randomization failure on cache_word")
             mask &= (cache_word[2:0] == <%=Math.ceil(wDataArrayEntry/32)-1%> ) ? ((32'h1 << <%=(wDataArrayEntry%32)-1%>)-32'h1): mask;
          <%}else {%>
             `uvm_error("CMO_TEST_SEQ", $sformatf("Illegal combination | Nbeats/bank:%0d wData:%0d", <%=obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank%>, <%= obj.DmiInfo[obj.Id].ccpParams.wData%>))
          <%}%>
        end else begin
           cache_word = $urandom_range(0,<%=Math.ceil(wTagArrayEntry/32)-1%>);
           mask &= (cache_word == <%=Math.ceil(wTagArrayEntry/32)-1%> ) ? ((32'h1 << <%=(wTagArrayEntry%32)%>)-32'h1): mask;
        end

        `uvm_info("CMO_TEST_SEQ",$sformatf("configuring Sets :0x%0x,  way :0x%0x,  Word :0x%0x, security = 0x%0x, mask: 0x%0x",cache_entry,cache_way,cache_word,security,mask), UVM_NONE)

        //Set cache index way word
        write_data = {cache_word,cache_way,cache_entry};
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));

        //Execute debug read // To check with the cacheQ content
        write_data = {9'h0,security,cache_arrayId,12'h0,4'hc};
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));
        //Wait for MntOp to complete
        do 
            m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
        while(field_rd_data);
        //Read the Data from data register to compare with write data
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.read(status,field_rd_data,.parent(this));

        //Write data in to data register
        write_data_to_compare = $urandom;
        `uvm_info("CMO_TEST_SEQ", $psprintf("Writing data: 0x%0x",write_data_to_compare),UVM_NONE);
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.write(status,write_data_to_compare,.parent(this));

        //Execute debug write
        write_data = {9'h0,security,cache_arrayId,12'h0,4'he};
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

        //Wait for MntOp to complete
        do
        begin
            data = 0;
            m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
        end while(field_rd_data != data);

        //corrupting previous debug write data to make sure previous write is not lingering and do not false match with debug read data.
        write_data = write_data_to_compare ^ 32'hFFFF_FFFF;
        `uvm_info("CMO_TEST_SEQ", $psprintf("corrupting previous debug write data in register XAIUPCMDR by writing data: 0x%0x",write_data),UVM_NONE);
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.write(status,write_data,.parent(this));
        
        //Execute debug read
        write_data = {9'h0,security,cache_arrayId,12'h0,4'hc};
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

        //Wait for MntOp to complete
        do
        begin
            data = 0;
            m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
        end while(field_rd_data != data);

        //Read the Data from data register to compare with write data
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.read(status,field_rd_data,.parent(this));
        if ((write_data_to_compare & mask) !== (field_rd_data & mask)) begin
          `uvm_error("CMO_TEST_SEQ",$sformatf("CMO debug read data: 0x%0x not matching with debug write data:0x%0x mask:0x%0x",field_rd_data,write_data_to_compare, mask))
        end else begin
          `uvm_info("CMO_TEST_SEQ",$sformatf("CMO debug read data: 0x%0x matching with debug write data:0x%0x mask:0x%0x",field_rd_data,write_data_to_compare, mask),UVM_NONE)
        end
      end
    end
    <% } %>
  endtask
endclass: dmi_csr_CMO_test_seq

class dmi_csr_mnt_CMO_RAW_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_mnt_CMO_RAW_seq)
  uvm_reg_data_t read_data, write_data, write_data_to_compare,lookupen;
  rand bit [5:0]  cache_word;
  rand bit [5:0]  cache_way;
  rand bit [19:0] cache_entry;
  rand bit [5:0]  cache_arrayId;
  bit [31:0] mask =32'hffff_ffff;
  bit security;
  dmi_scoreboard dmi_scb;

  function new(string name="");
      super.new(name);
  endfunction

  task body();
    bit all_flags_set = 0;
    <% if (obj.DmiInfo[obj.Id].useCmc){ %>
    if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                               .inst_name( "*" ),
                                               .field_name( "dmi_scb" ),
                                               .value( dmi_scb ))) begin
      `uvm_error("dmi_csr_mnt_CMO_RAW_seq", "dmi_scb model not found")
    end
    mask = 32'hFFFF_FFFF;
    lookupen = 1;
    `uvm_info("CMO_MNT_RAW_SEQ",$sformatf("configuring lookupen: 0x%0x",lookupen),UVM_NONE)
    write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCTCR.LookupEn, lookupen);
    cache_arrayId = $urandom_range(0,1);
    `uvm_info("CMO_MNT_RAW_SEQ",$sformatf("configuring Array_Id: 0x%0x",cache_arrayId),UVM_NONE)



    for(int sets_accessed=0; sets_accessed < 5; sets_accessed++) begin
      cache_entry = $urandom_range(0,<%=obj.DmiInfo[obj.Id].ccpParams.nSets%>);
      for(cache_way=0; cache_way<<%=obj.DmiInfo[obj.Id].ccpParams.nWays%>; cache_way++) begin
        //#Check.DMI.Concerto.v3.6.WordLookup
        if(cache_arrayId) begin
          <% if(obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2 && obj.DmiInfo[obj.Id].ccpParams.wData == 256) { %>  
             //256 wdata| words 0->16 | beat 0 | nBeats/Bank 2
             cache_word = $urandom_range(0,16);
             mask &= (cache_word[4:0] == <%=Math.ceil(wDataArrayEntry/32)-1%> ) ? ((32'h1 << <%=(wDataArrayEntry%32)-1%>)-32'h1): mask;
          <%}else if( (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2 && obj.DmiInfo[obj.Id].ccpParams.wData == 128) ||
                       (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 1 && obj.DmiInfo[obj.Id].ccpParams.wData == 256) ){%>
             //256 wdata| words 0->16 | beat 0->1 | nBeats/Bank 2
             //128 wdata| words 0->16 | beat 0->1 | nBeats/Bank 2
             bit status = 0;
             status = std::randomize(cache_word) with  { cache_word inside {[0:8],[16:24]};};
             if(!status) `uvm_error("CMO_MNT_RAW_SEQ","Randomization failure on cache_word")
             mask &= (cache_word[3:0] == <%=Math.ceil(wDataArrayEntry/32)-1%> ) ? ((32'h1 << <%=(wDataArrayEntry%32)-1%>)-32'h1): mask;
          <%}else if( obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 1 && obj.DmiInfo[obj.Id].ccpParams.wData == 128) {%>
             bit status = 0;
             status = std::randomize(cache_word) with  { cache_word inside {[0:4],[8:12],[16:20],[24:28]};};
             if(!status) `uvm_error("CMO_MNT_RAW_SEQ","Randomization failure on cache_word")
             mask &= (cache_word[2:0] == <%=Math.ceil(wDataArrayEntry/32)-1%> ) ? ((32'h1 << <%=(wDataArrayEntry%32)-1%>)-32'h1): mask;
          <%}else {%>
             `uvm_error("CMO_MNT_RAW_SEQ", $sformatf("Illegal combination | Nbeats/bank:%0d wData:%0d", <%=obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank%>, <%= obj.DmiInfo[obj.Id].ccpParams.wData%>))
          <%}%>
        end else begin
           cache_word = $urandom_range(0,<%=Math.ceil(wTagArrayEntry/32)-1%>);
           mask &= (cache_word == <%=Math.ceil(wTagArrayEntry/32)-1%> ) ? ((32'h1 << <%=(wTagArrayEntry%32)%>)-32'h1): mask;
        end
        for(int ns_itr=0; ns_itr <2; ns_itr++)begin
          `uvm_info("CMO_MNT_RAW_SEQ",$sformatf("configuring Sets :0x%0x,  way :0x%0x,  Word :0x%0x, security = 0x%0x, mask: 0x%0x",cache_entry,cache_way,cache_word,ns_itr,mask), UVM_NONE)
         //Set cache index way word
          write_data = {cache_word,cache_way,cache_entry};
          m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));
          //Execute debug read 
          write_data = {9'h0,ns_itr,cache_arrayId,12'h0,4'hc};
          //Wait for MntOp to complete
          do 
            m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
          while(field_rd_data);
          //Read the Data from data register to compare with write data
          m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.read(status,field_rd_data,.parent(this));

          //Write data in to data register
          write_data_to_compare = $urandom;
          `uvm_info("CMO_MNT_RAW_SEQ", $psprintf("Writing data: 0x%0x",write_data_to_compare),UVM_NONE);
          m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.write(status,write_data_to_compare,.parent(this));

          //Execute debug write
          write_data = {9'h0,ns_itr,cache_arrayId,12'h0,4'he};
          m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

          //Wait for MntOp to complete
          do
          begin
            data = 0;
            m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
          end while(field_rd_data != data);
          

          //Execute debug read
          write_data = {9'h0,security,cache_arrayId,12'h0,4'hc};
          m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

          //Wait for MntOp to complete
          do
          begin
            data = 0;
            m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
          end while(field_rd_data != data);
          
          //Read the Data from data register to compare with write data
          m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.read(status,field_rd_data,.parent(this));
          if ((write_data_to_compare & mask) !== (field_rd_data & mask)) begin
            `uvm_error("CMO_MNT_RAW_SEQ",$sformatf("CMO debug read data: 0x%0x not matching with debug write data:0x%0x mask:0x%0x",field_rd_data,write_data_to_compare, mask))
          end else begin
            `uvm_info("CMO_MNT_RAW_SEQ",$sformatf("CMO debug read data: 0x%0x matching with debug write data:0x%0x mask:0x%0x",field_rd_data,write_data_to_compare, mask),UVM_NONE)
          end
        end
      end
    end
    ev.trigger();
    <% } %>
  endtask
endclass: dmi_csr_mnt_CMO_RAW_seq
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check error interrupt functionality through alias register write. 
* 1. Enable correctable error interrupt. 
* 2. Write 1 to DMIUCESAR.ErrVld (alias register) so that DMIUCESR.ErrVld asserts in actual register.
* 3. Check that uncorrectable error interrupt should be asserted by DUT.
* 4. Write 0 to DMIUCESAR.ErrVld (alias register) so that DMIUCESR.ErrVld de-asserts in actual register.
* 5. Check that uncorrectable error interrupt should be de-asserted by DUT.
* 2. Write 1 to DMIUCESAR.ErrVld (alias register) so that DMIUCESR.ErrVld asserts in actual register.
* 3. Check that uncorrectable error interrupt should be asserted by DUT.
* 4. Write 0 to DMIUCESAR.ErrVld (alias register) so that DMIUCESR.ErrVld de-asserts in actual register.
* 5. Check that uncorrectable error interrupt should be de-asserted by DUT.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dmi_corr_errint_check_through_dmicesar_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_corr_errint_check_through_dmicesar_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
           getCsrProbeIf();
           ev.trigger();
           //set correctable error interrupt
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
       
           //Assert DMIUCESR.ErrVld through alias register write
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, write_data);
         
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
           compareValues("DMIUCESR_ErrVld", "set", read_data, 1);

           // wait for IRQ_C interrupt 
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 1);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
           join_any
           disable fork;
  
           //De-assert DMIUCESR.ErrVld through alias register write

           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, write_data);

           // Read the DMIUCESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
           compareValues("DMIUCESR_ErrVld", "now clear", read_data, 0);

           // wait for IRQ_C interrupt to de-assert
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 0);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C de-asserted"));
           end
           join_any
           disable fork;

           //Repeat the entire procedure
           //set correctable error interrupt
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
       
           //Assert DMIUCESR.ErrVld through alias register write
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, write_data);
         
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
           compareValues("DMIUCESR_ErrVld", "set", read_data, 1);

           // wait for IRQ_C interrupt 
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 1);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
           join_any
           disable fork;
  
           //De-assert DMIUCESR.ErrVld through alias register write

           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, write_data);

           // Read the DMIUCESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
           compareValues("DMIUCESR_ErrVld", "now clear", read_data, 0);

           // wait for IRQ_C interrupt to de-assert
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 0);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C de-asserted"));
           end
           join_any
           disable fork;
  
    endtask
endclass : dmi_corr_errint_check_through_dmicesar_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check alias register can be reflected in actual register in status. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. write each filed of alias register and should reflect in actual status register. 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dmi_csr_dmicesar_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicesar_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, write_data);
           ev.trigger();
           inject_error(.wbuffer_addr(wbuf_addr)); 
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
           compareValues("DMIUCESR_ErrVld", "set", read_data, 1);
           // write  DMIUCESR_ErrVld = 1 , W1C
           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, write_data);
           // Read the DMIUCESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
           compareValues("DMIUCESR_ErrVld", "now clear", read_data, 0);
           // Write Alias CSR field ErrType to reflect into SR ErrType filed
           write_data = 4'b1111;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrType, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, read_data);
           compareValues("DMIUCESR_ErrType", "set", read_data, write_data);
           write_data = 4'b0000;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrType, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, read_data);
           compareValues("DMIUCESR_ErrType", "set", read_data, write_data);
           // Write Alias CSR field ErrInfo to reflect into SR ErrInfo filed
           write_data = 16'hffff;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrInfo, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrInfo, read_data);
           compareValues("DMIUCESR_ErrInfo", "set", read_data, write_data);
           write_data = 16'h0000;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrInfo, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrInfo, read_data);
           compareValues("DMIUCESR_ErrInfo", "set", read_data, write_data);
<% } else { %>
           ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmicesar_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check alias register can be reflected in actual register in status. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. write each filed of alias register and should reflect in actual status register. 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dmi_csr_dmiuesar_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuesar_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, write_data);
           ev.trigger();
           inject_error(.wbuffer_addr(wbuf_addr)); 
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "set", read_data, 1);
           // write  DMIUUESR_ErrVld = 1 , W1C
           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "now clear", read_data, 0);
           // Write Alias CSR field ErrType to reflect into SR ErrType filed
           write_data = 4'b1111;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType", "set", read_data, write_data);
           write_data = 4'b0000;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType", "set", read_data, write_data);
           // Write Alias CSR field ErrInfo to reflect into SR ErrInfo filed
           write_data = 20'hfffff;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrInfo, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
           compareValues("DMIUUESR_ErrInfo", "set", read_data, write_data);
           write_data = 20'h00000;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrInfo, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
           compareValues("DMIUUESR_ErrInfo", "set", read_data, write_data);
<% } else { %>
           ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmiuesar_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are corrected (ErrThreshold filed CECR register) which should be count by Error counter. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. If dmi contains SECDED, Write Error threshold with random value b/w 1 to 255 (DUT must assert Interrupt once threshold value errors are corrected.
* 2. Eable Error detection from correctable CSR.
* 3. Enable Error Interrupt from CSR. If enabled then correctable iterrupt signal is asserted.
* 4. Inejct single error = ErrThd
* 5. Poll ErrVld=0,ErrOvf=0,Errcount= ErrThd
* 6. Inject single error
* 7. Poll ErrVld=1,ErrOvf=0,Errcount= ErrThd
* 8. Inject single error
* 9. Poll ErrVld=1,ErrOvf=1,Errcount= ErrThd
* 10. Disable Error Detection and Error Interrupt filed by writing 0.
* 11. Clear ErrVld by writting 1 (W1C access types of this field) in status register
* 12. Check if ErrCount should be cleared.
* 13. Repeat step 1 to 12.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
class dmi_csr_dmicecr_errThd_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicecr_errThd_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task inject_until_corr_err_ovrflw_set(int pgm_threshold);
      int count;
      bit errvld=0;
      int errcount=0;
      uvm_reg_data_t csr_data, err_ovrflw;
      read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, err_ovrflw);
      while( count < 1000 && err_ovrflw == 0) begin
        inject_error(1,.wbuffer_addr(wbuf_addr));
        repeat(20) @(posedge u_csr_probe_vif.clk);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, err_ovrflw);
        if(err_ovrflw==0) begin
          compareValues("DMIUUESR_ErrCountOverflow", "not set", err_ovrflw, 0);
        end
        else begin
          compareValues("DMIUUESR_ErrCountOverflow", "set", err_ovrflw, 1);
        end
        `uvm_info("RUN_MAIN",$sformatf("::inject_until_corr_err_ovrflw_set:: Error count overflow is currently at %0d", err_ovrflw),UVM_LOW)
        count++;
      end
      if(count == 1000 || err_ovrflw == 0) begin
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, csr_data);
        `uvm_error("RUN_MAIN",$sformatf("::inject_until_corr_err_ovrflw_set:: After 1000 attempts, could not inject enough errors=%0d to set ErrCountOverflow",csr_data))
      end
      else begin
        `uvm_info("RUN_MAIN",$sformatf("::inject_until_corr_err_ovrflw_set:: After %0d attempts, overflow=%0b", count, err_ovrflw),UVM_LOW)
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, csr_data);
        if(csr_data != pgm_threshold) begin
          `uvm_error("RUN_MAIN",$sformatf("::inject_until_corr_err_ovrflw_set:: Count should never cross threshold %0d!=%0d",csr_data,pgm_threshold))
        end
      end
    endtask

    task inject_until_corr_errvld_set(int pgm_threshold);
      int count;
      bit check_overflow_flg =1;
      int errcount=0;
      int hysteresis_count=0;
      uvm_reg_data_t csr_data, errvld;
      read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, errvld);
      while( count < 1000 && errvld == 0) begin
        inject_error(1,.wbuffer_addr(wbuf_addr));
        repeat(20) @(posedge u_csr_probe_vif.clk);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, errvld);
        if(errvld ==0) begin
          compareValues("DMIUUESR_ErrVld", "not set", errvld, 0);
        end
        else begin
          compareValues("DMIUUESR_ErrVld", "set", errvld, 1);
        end
        //overflow count should not assert until error valid is set and threshold+2
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, csr_data);
        `uvm_info("RUN_MAIN",$sformatf("::inject_until_corr_errvld_set:: Error count is currently at %0d", csr_data),UVM_LOW)
        errcount = csr_data;
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, csr_data);
        `uvm_info("RUN_MAIN",$sformatf("::inject_until_corr_errvld_set:: Error count overflow is currently at %0d", csr_data),UVM_LOW)
        if(check_overflow_flg) begin
          if(errcount == pgm_threshold) begin
            hysteresis_count++;
          end
          if(errvld && hysteresis_count==pgm_threshold+1) begin
            check_overflow_flg = 0;
            `uvm_info("RUN_MAIN",$sformatf("::inject_until_corr_errvld_set:: Hysteresis Count hit threshold +1 with error valid set. Exiting."),UVM_LOW)
            break;
          end
          compareValues("DMIUUESR_ErrCountOverflow", "should be 0 until error threshold+2", csr_data, 0);
        end
        count++;
      end
      read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, errvld);
      if(count == 1000 || errvld == 0) begin
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, csr_data);
        `uvm_error("RUN_MAIN",$sformatf("::inject_until_corr_errvld_set:: After 1000 attempts, could not inject enough errors=%0d to set ErrVld",csr_data))
      end
      else begin
        `uvm_info("RUN_MAIN",$sformatf("::inject_until_corr_errvld_set:: After %0d attempts, errvld=%0b", count, errvld),UVM_LOW)
      end
    endtask

    task inject_until_CESR_hit_threshold(int threshold);
      int count;
      uvm_reg_data_t csr_data;
      read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, csr_data);
      while( count < 1000 && csr_data < threshold) begin
        inject_error(1,.wbuffer_addr(wbuf_addr));
        repeat(20) @(posedge u_csr_probe_vif.clk);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, csr_data);
        if(csr_data ==threshold) begin
          compareValues("DMIUUESR_ErrCount", "hit threshold", csr_data, 0);
        end
        count++;
      end
      read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, csr_data);
      `uvm_info("RUN_MAIN",$sformatf("::inject_until_CESR_hit_threshold:: Error count is currently at %0d", csr_data),UVM_LOW)
      if(count == 1000 || csr_data != threshold) begin
        `uvm_error("RUN_MAIN",$sformatf("::inject_until_CESR_hit_threshold:: After 1000 attempts, could not hit threshold=> %0d != %0d",csr_data,threshold))
      end
      else begin
        `uvm_info("RUN_MAIN",$sformatf("::inject_until_CESR_hit_threshold:: After %0d attempts, curr_threshold=%0d exp_threshold=%0d", count, csr_data, threshold),UVM_LOW)
      end
    endtask

    task body();
      
        getCsrProbeIf();
        getInjectErrEvent();
<% if(has_secded) { %>
        if((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin
          // Set the DMIUCECR_ErrThreshold 
          errthd = $urandom_range(1,10);
          `uvm_info("RUN_MAIN",$sformatf("Executing first sequence and programming errthd:%0d",errthd),UVM_LOW)
          write_data = errthd;
          <% if(obj.useResiliency) { %>
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCRTR.ResThreshold, write_data);
          <% } %>
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          // Set the DMIUCECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // Set the DMIUCECR_ErrIntEn = 1
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
          ev.trigger();
          inject_error(errthd,5,1'b1,.wbuffer_addr(wbuf_addr)); 
          //at err count reached errthd, ErrVld and Overflow should be 0
          inject_until_corr_errvld_set(errthd);
          // Read DMIUCESR_ErrCount , it should be at errthd
          poll_data = 0;
          poll_DMIUCESR_ErrCount(errthd,poll_data);
          if(poll_data < errthd) begin
              `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
          end
          else begin
            `uvm_info("RUN_MAIN",$sformatf("ErrCount %0d is same as ErrThreshold %0d",poll_data,errthd),UVM_LOW)
          end
          //ovf should set if error = errthd+2
          write_data = 0;
          inject_until_corr_err_ovrflw_set(errthd);
          poll_DMIUCESR_ErrVld(1, poll_data);
          poll_DMIUCESR_ErrCountOverflow(1,poll_data);
          // Read DMIUCESR_ErrCount , it should be at errthd
          poll_data = 0;
          poll_DMIUCESR_ErrCount(errthd,poll_data);

          if(poll_data < errthd) begin
              `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
          end
          else begin
            `uvm_info("RUN_MAIN",$sformatf("ErrCount %0d is same as ErrThreshold %0d",poll_data,errthd),UVM_LOW)
          end
          `uvm_info("RUN_MAIN","Entering second sequence, performing reset",UVM_LOW);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // write : DMIUCESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
          // Read DMIUCESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "now clear", read_data, 0);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
          compareValues("DMIUCESR_ErrCount", "now clear", read_data, 0);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR_ErrOvf", "now clear", read_data, 0);
          // Set the DMIUCECR_ErrThreshold 
          errthd = $urandom_range(1,10);
          write_data = errthd;
          `uvm_info("RUN_MAIN",$sformatf("Executing second sequence and programming errthd:%0d",errthd),UVM_LOW)
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          // Set the DMIUCECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // Set the DMIUCECR_ErrIntEn = 1
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
          ev.trigger();
          inject_error(errthd,5,1'b1,.wbuffer_addr(wbuf_addr)); 
          //at err count reached errthd, ErrVld and Overflow should be 0
          inject_until_corr_errvld_set(errthd);
          inject_until_CESR_hit_threshold(errthd);
          //errVld should be 1, if error = errthd+1
          //errOvf should be 0, if error = errthd+1
          poll_DMIUCESR_ErrVld(1, poll_data);
          poll_DMIUCESR_ErrCountOverflow(0,poll_data);
          // Read DMIUCESR_ErrCount , it should be at errthd
          poll_data = 0;
          poll_DMIUCESR_ErrCount(errthd,poll_data);
          if(poll_data < errthd) begin
            `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
          end
          else begin
            `uvm_info("RUN_MAIN",$sformatf("ErrCount %0d is same as ErrThreshold %0d",poll_data,errthd),UVM_LOW)
          end
          //ovf should set if error = errthd+2
          write_data = 0;
          inject_until_corr_err_ovrflw_set(errthd);
          poll_DMIUCESR_ErrVld(1, poll_data);
          poll_DMIUCESR_ErrCountOverflow(1,poll_data);
          // Read DMIUCESR_ErrCount , it should be at errthd
          poll_data = 0;
          poll_DMIUCESR_ErrCount(errthd,poll_data);
          if(poll_data < errthd) begin
              `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
          end
          <% if(obj.useResiliency) { %>
          begin
            if(!u_csr_probe_vif.cerr_over_thres_fault) begin
              `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted. tag_(secded=%0d|parity=%0d), data_(secded=%0d|parity=%0d), wbuffer_(secded=%0d|parity=%0d)", tag_secded, tag_parity, data_secded, data_parity, wbuffer_secded, wbuffer_parity));
            end
            else begin
              `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted. tag_(secded=%0d|parity=%0d), data_(secded=%0d|parity=%0d), wbuffer_(secded=%0d|parity=%0d)", tag_secded, tag_parity, data_secded, data_parity, wbuffer_secded, wbuffer_parity), UVM_NONE);
            end
          end
          <% } %>
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // write : DMIUCESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
          // Read DMIUCESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "now clear", read_data, 0);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
          compareValues("DMIUCESR_ErrCount", "now clear", read_data, 0);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR_ErrCountOverflow", "now clear", read_data, 0);
        end else if((tag_parity && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_parity && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_parity && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin 
          // Set the DMIUUEDR_MemErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          // Set the DMIUUEDR_MemErrIntEn = 1
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          poll_DMIUUESR_ErrVld(1, poll_data);

          fork
          begin
              wait (u_csr_probe_vif.IRQ_UC === 1);
          end
          begin
            #200000ns;
            `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
          end
          join_any
          disable fork;

          <% if(obj.useResiliency) { %>
          begin
            if(u_csr_probe_vif.cerr_over_thres_fault) begin
              `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted. tag_(secded=%0d|parity=%0d), data_(secded=%0d|parity=%0d), wbuffer_(secded=%0d|parity=%0d)", tag_secded, tag_parity, data_secded, data_parity, wbuffer_secded, wbuffer_parity));
            end
            else begin
              `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted. tag_(secded=%0d|parity=%0d), data_(secded=%0d|parity=%0d), wbuffer_(secded=%0d|parity=%0d)", tag_secded, tag_parity, data_secded, data_parity, wbuffer_secded, wbuffer_parity), UVM_NONE);
            end
          end
          <% } %>
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
          // write DMIUUESR_ErrVld = 1 to clear it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          // Read DMIUUESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "reset", read_data, 0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC === 0)begin
            `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
          end else begin
            `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
          end
        end else begin
          ev.trigger();
        end
<% } else if (wbuffer_fnerrdetectcorrect) { %>
        if(wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) begin
          // Set the DMIUCECR_ErrThreshold 
          errthd = $urandom_range(1,10);
          write_data = errthd;
          <% if(obj.useResiliency) { %>
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCRTR.ResThreshold, write_data);
          <% } %>
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          // Set the DMIUCECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // Set the DMIUCECR_ErrIntEn = 1
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
          ev.trigger();
          inject_error(errthd,5,1'b1,.wbuffer_addr(wbuf_addr)); 
          //at err count reached errthd, ErrVld and Overflow should be 0
          poll_DMIUCESR_ErrVld(0, poll_data);
          poll_DMIUCESR_ErrCountOverflow(0,poll_data);
          //keep on  Reading the DMIUCESR_ErrVld bit = 1 
          inject_error(1,.wbuffer_addr(wbuf_addr)); 
          //errVld should be 1, if error = errthd+1
          //errOvf should be 0, if error = errthd+1
          poll_DMIUCESR_ErrVld(1, poll_data);
          poll_DMIUCESR_ErrCountOverflow(0,poll_data);
          // Read DMIUCESR_ErrCount , it should be at errthd
          poll_data = 0;
          poll_DMIUCESR_ErrCount(errthd,poll_data);
          if(poll_data < errthd) begin
              `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
          end
          //ovf should set if error = errthd+2
          write_data = 0;
          inject_error(1,.wbuffer_addr(wbuf_addr)); 
          poll_DMIUCESR_ErrVld(1, poll_data);
          poll_DMIUCESR_ErrCountOverflow(1,poll_data);
          // Read DMIUCESR_ErrCount , it should be at errthd
          poll_data = 0;
          poll_DMIUCESR_ErrCount(errthd,poll_data);
          if(poll_data < errthd) begin
              `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
          end
          <% if(obj.useResiliency) { %>
          begin
            if(!u_csr_probe_vif.cerr_over_thres_fault) begin
              `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted. wbuffer_(secded=%0d|parity=%0d)", wbuffer_secded, wbuffer_parity));
            end
            else begin
              `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted. wbuffer_(secded=%0d|parity=%0d)", wbuffer_secded, wbuffer_parity), UVM_NONE);
            end
          end
          <% } %>
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // write : DMIUCESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
          // Read DMIUCESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "now clear", read_data, 0);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
          compareValues("DMIUCESR_ErrCount", "now clear", read_data, 0);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR_ErrOvf", "now clear", read_data, 0);
          // Set the DMIUCECR_ErrThreshold 
          errthd = $urandom_range(1,10);
          write_data = errthd;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          // Set the DMIUCECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // Set the DMIUCECR_ErrIntEn = 1
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
          ev.trigger();
          inject_error(errthd,5,1'b1,.wbuffer_addr(wbuf_addr)); 
          //at err count reached errthd, ErrVld and Overflow should be 0
          poll_DMIUCESR_ErrVld(0, poll_data);
          poll_DMIUCESR_ErrCountOverflow(0,poll_data);
          //keep on  Reading the DMIUCESR_ErrVld bit = 1 
          inject_error(1,.wbuffer_addr(wbuf_addr)); 
          //errVld should be 1, if error = errthd+1
          //errOvf should be 0, if error = errthd+1
          poll_DMIUCESR_ErrVld(1, poll_data);
          poll_DMIUCESR_ErrCountOverflow(0,poll_data);
          // Read DMIUCESR_ErrCount , it should be at errthd
          poll_data = 0;
          poll_DMIUCESR_ErrCount(errthd,poll_data);
          if(poll_data < errthd) begin
              `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
          end
          //ovf should set if error = errthd+2
          write_data = 0;
          inject_error(1,.wbuffer_addr(wbuf_addr)); 
          poll_DMIUCESR_ErrVld(1, poll_data);
          poll_DMIUCESR_ErrCountOverflow(1,poll_data);
          // Read DMIUCESR_ErrCount , it should be at errthd
          poll_data = 0;
          poll_DMIUCESR_ErrCount(errthd,poll_data);
          if(poll_data < errthd) begin
              `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
          end
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // write : DMIUCESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
          // Read DMIUCESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "now clear", read_data, 0);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
          compareValues("DMIUCESR_ErrCount", "now clear", read_data, 0);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR_ErrCountOverflow", "now clear", read_data, 0);
        end else if(wbuffer_parity && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) begin
          // Set the DMIUUEDR_MemErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          // Set the DMIUUEDR_MemErrIntEn = 1
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          poll_DMIUUESR_ErrVld(1, poll_data);

          fork
          begin
              wait (u_csr_probe_vif.IRQ_UC === 1);
          end
          begin
            #200000ns;
            `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
          end
          join_any
          disable fork;
          <% if(obj.useResiliency) { %>
          begin
            if(u_csr_probe_vif.cerr_over_thres_fault) begin
              `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted. wbuffer_(secded=%0d|parity=%0d)", wbuffer_secded, wbuffer_parity));
            end
            else begin
              `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted. wbuffer_(secded=%0d|parity=%0d)", wbuffer_secded, wbuffer_parity), UVM_NONE);
            end
          end
          <% } %>
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
          // write DMIUUESR_ErrVld = 1 to clear it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          // Read DMIUUESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "reset", read_data, 0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC === 0)begin
            `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
          end else begin
            `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
          end
        end else begin 
          ev.trigger();
        end
<% } else { %>
          ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmicecr_errThd_seq

//-----------------------------------------------------------------------
/*
* Abstract:
* 
* In this test we will check if ErrDetEn is set, correctable errors are logged by design. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. If dmi contains SECDED, enable Error detection from correctable CSR
* 2. Enable SRAM single-bit error from command line with 100% (all writes/read in SRAM)
* 3. Poll Error valid bit from Correctable status register until it is 1. (Error captured)
* 4. Disable error detection in CSR.
* 5. Read ErrVld, which should be set until its cleared.
* 6. Clear ErrVld by writting 1 (W1C access types of this field) in status register
* 7. Compare read value with 0 for ErrVld field in status register (should be cleared)
*/
//-----------------------------------------------------------------------
class dmi_csr_dmicecr_errDetEn_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicecr_errDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      getCsrProbeIf();
      getInjectErrEvent();
      //Inject Tag and Data Errors
      <% if(has_secded) { %>
      if((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin
         write_data = 0;
         write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
         // Set the DMIUCECR_ErrDetEn = 1
         write_data = 1;
         write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
         ev.trigger();
         inject_error(1,.wbuffer_addr(wbuf_addr)); 
         //keep on  Reading the DMIUCESR_ErrVld bit = 1
         poll_DMIUCESR_ErrVld(1, poll_data);
         // Set the DMIUCECR_ErrDetEn = 0, to diable the error detection
         write_data = 0;
         write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
         // Read DMIUCESR_ErrVld , it should be 1
         read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
         compareValues("DMIUCESR_ErrVld", "set", read_data, 1);
         // write  DMIUCESR_ErrVld = 1 , W1C
         write_data = 0;
         write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, write_data);
         // Read the DMIUCESR_ErrVld should be cleared
         read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
         compareValues("DMIUCESR_ErrVld", "now clear", read_data, 0);
      end else if((tag_parity && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_parity && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_parity && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin 
        // Set the DMIUUEDR_MemErrDetEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
        ev.trigger();
        inject_error(.wbuffer_addr(wbuf_addr)); 
        poll_DMIUUESR_ErrVld(1, poll_data);
        write_data = 0;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
        // write DMIUUESR_ErrVld = 1 to clear it
        write_data = 1;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
        // Read DMIUUESR_ErrVld , it should be 0
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
        compareValues("DMIUUESR_ErrVld", "reset", read_data, 0);
      end else begin
        // Read the DMIUCESR_ErrVld should be clear
        ev.trigger();
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
        compareValues("DMIUESR_ErrVld", "RAZ/WI", read_data, 0);
        // Read DMIUCESAR_ErrVld , it should also clear, beacuse it is alias register
        // of register DMIUCESR_*
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, read_data);
        compareValues("DMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
      end
      <% } else if (wbuffer_fnerrdetectcorrect) { %>
      if(wbuffer_secded && (($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin
        write_data = 0;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
        // Set the DMIUCECR_ErrDetEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
        ev.trigger();
        inject_error(1,.wbuffer_addr(wbuf_addr)); 
        //keep on  Reading the DMIUCESR_ErrVld bit = 1
        poll_DMIUCESR_ErrVld(1, poll_data);
        // Set the DMIUCECR_ErrDetEn = 0, to diable the error detection
        write_data = 0;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
        // Read DMIUCESR_ErrVld , it should be 1
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
        compareValues("DMIUCESR_ErrVld", "set", read_data, 1);
        // write  DMIUCESR_ErrVld = 1 , W1C
        write_data = 0;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, write_data);
        // Read the DMIUCESR_ErrVld should be cleared
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
        compareValues("DMIUCESR_ErrVld", "now clear", read_data, 0);
      end else if(wbuffer_parity && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) begin
        // Set the DMIUUEDR_MemErrDetEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
        ev.trigger();
        inject_error(.wbuffer_addr(wbuf_addr)); 
        poll_DMIUUESR_ErrVld(1, poll_data);
        write_data = 0;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
        // write DMIUUESR_ErrVld = 1 to clear it
        write_data = 1;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
        // Read DMIUUESR_ErrVld , it should be 0
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
        compareValues("DMIUUESR_ErrVld", "reset", read_data, 0);
      end else begin
        // Read the DMIUCESR_ErrVld should be clear
        ev.trigger();
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
        compareValues("DMIUESR_ErrVld", "RAZ/WI", read_data, 0);
        // Read DMIUCESAR_ErrVld , it should also clear, beacuse it is alias register
        // of register DMIUCESR_*
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, read_data);
        compareValues("DMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
      end
      <% } else { %>
      // Read the DMIUCESR_ErrVld should be clear
      ev.trigger();
      read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
      compareValues("DMIUESR_ErrVld", "RAZ/WI", read_data, 0);
      // Read DMIUCESAR_ErrVld , it should also clear, beacuse it is alias register
      // of register DMIUCESR_*
      read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, read_data);
      compareValues("DMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
      <% } %>
    endtask
endclass : dmi_csr_dmicecr_errDetEn_seq

//Sequence to inject correctable errors of various types 8.1.3.1
// +CESR_skid_buffer_errors ::  CMD/MRD SRAM Skid Buffer
// +CESR_transport_errors :: Inject Transport errosr
//MRD and CMD SMI I/F are delayed to fill the SRAM skid buffer and once initialization is complete an error is injected. 
//This avoids x propagation by injecting errors on uninitialized data/address locations
//To exercise both CMD/MRD sequence separately to avoid long test times a bit switch is used.
//All values including detection,count and overflow are randomized and not testlist specified.
class dmi_CESR_seq extends dmi_ral_csr_base_seq;

  `uvm_object_utils(dmi_CESR_seq)

  string LABEL = "dmi_CESR_seq";

  uvm_reg_data_t poll_data, read_data, write_data;
  bit        err_int_det_switch, inj_overflow_switch, choose_cmd_sequence;
  bit [7:0]  err_count;
  int        exp_err_info,exp_err_type;

  function new(string name="dmi_CESR_seq");
    super.new(name);
  endfunction

  task body();
    super.body();
    getCsrProbeIf();
    getInjectErrEvent();
    if(m_cfg.m_args.CESR_transport_errors) begin
      `uvm_info(get_full_name(),"Starting transport error sequence on CESR",UVM_LOW)
      transport_errors();
    end
    else if(m_cfg.m_args.CESR_skid_buffer_errors) begin
      `uvm_info(get_full_name(),"Starting SkidBuffer error sequence on CESR",UVM_LOW)
      SRAM_skid_buffer_errors();
    end
  endtask: body

  task transport_errors();
    smi_seq_item wrong_tag_id_pkt;
    bit[15:0] source_id_error_info;
    exp_err_type = 8;
    <%if (obj.DmiInfo[obj.Id].fnErrDetectCorrect == "NONE") {%>
    `uvm_error(get_full_name(),"Errors on configs without error support cannot be injected");
    return;
    <%} else { %>
    program_xCECR(1,1,0);
    ev.trigger();
    if(m_cfg.m_args.k_wrong_target_id) begin
      ev_wrong_targ_id.wait_ptrigger();
      $cast(wrong_tag_id_pkt,ev_wrong_targ_id.get_trigger_data());
      source_id_error_info[15:6] = wrong_tag_id_pkt.smi_src_ncore_unit_id;
    end
    `uvm_info(get_full_name(),$sformatf("Transport SourceId Error Injected = 'h%0h",source_id_error_info),UVM_MEDIUM)
    poll_DMIUCESR_ErrVld(1, poll_data);
    wait_on_IRQ_C(1);
    //Read error type, info and count and ensure it matches expected
    read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
    compareValues("DMIUCESR_ErrVld", "set after interrupt", read_data, 1);
    read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, read_data);
    compareValues("DMIUCESR_ErrType","valid type", read_data, exp_err_type);
    read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
    compareValues("DMIUCESR_ErrCount","injected error count", read_data, err_count);
    read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrInfo, read_data);
    compareValues("DMIUUESR_ErrType","valid type", read_data, source_id_error_info);
    <% } %>
  endtask

  task SRAM_skid_buffer_errors();
    err_int_det_switch = ($urandom_range(0,100) < 95) ? 1 : 0;
    choose_cmd_sequence = $urandom_range(0,10) < 5 ? 1 : 0;
    if(err_int_det_switch) begin
       inj_overflow_switch = ($urandom_range(0,100) < 50) ? 1 : 0;
       assert(std::randomize(err_count) with { err_count dist { [  0:127] := 5,
                                                                [128:255] := 5
                                                              };});
    end

    exp_err_type = 0;
    exp_err_info = 0;

    if(!m_cfg.m_args.sram_error_test) begin //Do not force if user settable bits are configured.
      m_cfg.m_args.k_sram_single_bit_error = 1;
    end
    else begin
      err_int_det_switch = 1;
    end
    `uvm_info("RUN_MAIN",$sformatf("Choosing to execute sequence CMD:%0b MRD:%0b",choose_cmd_sequence,!choose_cmd_sequence),UVM_LOW)
    <% if(mrd_sram_secded) { %>
    //#Check.DMI.Concerto.v3.7/SECDEDSingleBitDataC
    ///////////MRD SRAM SECDED///////////////////////////////////////////////////////////////////
    if(!choose_cmd_sequence) begin
      if(m_cfg.m_args.k_sram_single_bit_error) begin
        exp_err_info = 3'h6;
      end
      else if(m_cfg.m_args.k_sram_address_error || m_cfg.m_args.k_sram_double_bit_error) begin
        exp_err_info = 3'h0;
      end
      `uvm_info("RUN_MAIN",$sformatf("Error scenario for MRD SRAM| Detection/Interrupt:%0b Overflow:%0b Count:%0d",err_int_det_switch,inj_overflow_switch,err_count),UVM_LOW)
      program_xCECR(err_int_det_switch,err_int_det_switch,err_count); 
      ev.trigger();
      control_mrd_delay(1);
      wait_on_mrd_sram_init_done();
      control_mrd_delay(0);
      inject_mrd_sram_error(err_count+1);
      if(err_int_det_switch) begin
        //Check injected error propagates to interrupt
        wait_on_IRQ_C(1);
        //Read error type, info and count and ensure it matches expected
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
        compareValues("DMIUCESR_ErrVld", "set after interrupt", read_data, 1);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, read_data);
        compareValues("DMIUCESR_ErrType","valid type", read_data, exp_err_type);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
        compareValues("DMIUCESR_ErrCount","injected error count", read_data, err_count);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrInfo, read_data);
        compareValues("DMIUUESR_ErrType","valid type", read_data, exp_err_info);
        if(inj_overflow_switch) begin
          inject_mrd_sram_error(1);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "set after interrupt", read_data, 1);
          poll_DMIUCESR_ErrCountOverflow(1,read_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR_ErrOverflow","expected", read_data, 1);
        end
        //Reset ErrVld
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, 1);
        //Check Reset
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
        compareValues("DMIUCESR_ErrVld", "Reset", read_data, 0);
        dmi_scb.cov.collect_skidbuf_CE_stats(inj_overflow_switch,err_count,exp_err_info);
      end
      else begin
        //Check injected error does not propagates to interrupt
        wait_on_IRQ_C(0);
        //Read error type, info and count and ensure it isn't toggling
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
        compareValues("DMIUCESR_ErrVld", "set after interrupt", read_data, 0);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, read_data);
        compareValues("DMIUCESR_ErrType","valid type", read_data, exp_err_type);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
        compareValues("DMIUCESR_ErrCount","injected error count", read_data, 0);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrInfo, read_data);
        compareValues("DMIUUESR_ErrType","valid type", read_data, 0);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
        compareValues("DMIUCESR_ErrCount","injected error count", read_data, 0);
      end
      //End of flow check
      check_IRQ_C(0);
      //Reset registers////////////////////////////////////////////////////////////////////////////
      program_xCECR(0,0,0);
    end
    <% } %>
    <% if(cmd_sram_secded) { %>
    ///////////CMD SRAM SECDED///////////////////////////////////////////////////////////////////
    //#Check.DMI.Concerto.v3.7/SECDEDSingleBitDataC
    if(choose_cmd_sequence)begin
      if(m_cfg.m_args.k_sram_single_bit_error) begin
        exp_err_info = 3'h5;
      end
      else if(m_cfg.m_args.k_sram_address_error || m_cfg.m_args.k_sram_double_bit_error) begin
        exp_err_info = 3'h0;
      end
      `uvm_info("RUN_MAIN",$sformatf("Error scenario for CMD SRAM| Detection/Interrupt:%0b Overflow:%0b Count:%0h",err_int_det_switch,inj_overflow_switch,err_count),UVM_LOW)
      program_xCECR(err_int_det_switch,err_int_det_switch,err_count); 
      ev.trigger();
      control_cmd_delay(1); 
      wait_on_cmd_sram_init_done();
      control_cmd_delay(0); 
      inject_cmd_sram_error(err_count+1);
      if(err_int_det_switch) begin
        //Check injected error propagates to interrupt
        wait_on_IRQ_C(1);
        //Read error type, info and count and ensure it matches expected
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
        compareValues("DMIUCESR_ErrVld", "set after interrupt", read_data, 1);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, read_data);
        compareValues("DMIUCESR_ErrType","valid type", read_data, exp_err_type);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
        compareValues("DMIUCESR_ErrCount","matches injected", read_data, err_count);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrInfo, read_data);
        compareValues("DMIUUESR_ErrType","valid type", read_data, exp_err_info);
        if(inj_overflow_switch) begin
          inject_cmd_sram_error(1);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "set after interrupt", read_data, 1);
          poll_DMIUCESR_ErrCountOverflow(1,read_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR_ErrOverflow","expected", read_data, 1);
        end
        //Reset ErrVld
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, 1);
        //Check Reset
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
        compareValues("DMIUCESR_ErrVld", "reset", read_data, 0);
        dmi_scb.cov.collect_skidbuf_CE_stats(inj_overflow_switch,err_count,exp_err_info);
      end
      else begin
        //Check injected error propagates to interrupt
        wait_on_IRQ_C(0);
        //Read error type, info and count and ensure it matches expected
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
        compareValues("DMIUCESR_ErrVld", "set after interrupt", read_data, 0);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, read_data);
        compareValues("DMIUCESR_ErrType","valid type", read_data, 0);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
        compareValues("DMIUCESR_ErrCount","matches injected", read_data, 0);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrInfo, read_data);
        compareValues("DMIUUESR_ErrType","valid type", read_data, 0);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
        compareValues("DMIUCESR_ErrCount","injected error count", read_data, 0);
      end
      //End of flow check
      check_IRQ_C(0);
      //Reset registers////////////////////////////////////////////////////////////////////////////
      program_xCECR(0,0,0);
    end
    <% } %>
    //SECDED--END/////////////////////////////////////////////////////////////////////////////////
    <% if(!(mrd_sram_secded || cmd_sram_secded)) { %>
    //Unexpected IRQ_C in any scenario that is not MRD or CMD SRAM with SECDED'
    m_cfg.m_args.sram_error_test = 0; //Enable end of test checks on CSR for error registers.
    ev.trigger();
    fork 
      begin
        `uvm_info("RUN_MAIN",$sformatf("Waiting for a correctable interrupt. It should not trigger"), UVM_LOW)
        @(u_csr_probe_vif.IRQ_C);
        `uvm_error("RUN_MAIN", $sformatf("Unexpected correctable interrupt!"))
      end
      begin
        #5000ns;
        `uvm_info("RUN_MAIN",$sformatf("Done waiting. No correctable interrupt received"), UVM_LOW)
      end
    join_any
    //ErrVld should be 0
    read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
    compareValues("DMIUCESR_ErrVld", "set", read_data, 0);
    read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, read_data);
    compareValues("DMIUCESAR_ErrVld", "set", read_data, 0);
    <% } %>
  endtask: SRAM_skid_buffer_errors
endclass
//Sequence to inject uncorrectable errors in CMD/MRD SRAM Skid Buffer
//MRD and CMD SMI I/F are delayed to fill the SRAM skid buffer and once initialization is complete an error is injected. 
//This avoids x propagation by injecting errors on uninitialized data/address locations
//To exercise both CMD/MRD sequence separately to avoid long test times a bit switch is used.
//All values including detection,count and overflow are randomized and not testlist specified.
//This sequence also tests mission fault when +expect_mission_fault is specified. 

class dmi_sram_uncorr_err_seq extends dmi_ral_csr_base_seq;
  `uvm_object_utils(dmi_sram_uncorr_err_seq)

  uvm_reg_data_t poll_data, read_data, write_dattype_of_data_errora;
  bit [3:0]  exp_err_type, exp_err_info;
  bit        err_int_det_switch;
  bit        data_switch; //addr=0 data =1
  bit        choose_cmd_sequence;
  bit        is_mission_fault_test;
  function new(string name="dmi_sram_uncorr_err_seq");
    super.new(name);
  endfunction

  task body();
    super.body();
    getCsrProbeIf();
    getInjectErrEvent();
    exp_err_type = 4'h0;
    exp_err_info = 4'h0;
    err_int_det_switch = ($urandom_range(0,100) < 95) ? 1 : 0;
    data_switch = ($urandom_range(0,100) < 50) ? 1 : 0;
    choose_cmd_sequence = $urandom_range(0,10) < 5 ? 1 : 0;

    if($test$plusargs("expect_mission_fault")) begin 
      is_mission_fault_test = 1;
    end
    if(!m_cfg.m_args.sram_error_test) begin //Do not force if user settable bits are configured.
      if(!data_switch) begin
        //#Check.DMI.Concerto.v3.7/PARITYAddressUC
        m_cfg.m_args.k_sram_address_error = 1;
      end
      else begin
      <%if(mrd_sram_parity|| cmd_sram_parity) { %>
        //#Check.DMI.Concerto.v3.7/PARITYSingleBitDataUC
        m_cfg.m_args.k_sram_single_bit_error = err_int_det_switch;
      <%} else {%>
        //#Check.DMI.Concerto.v3.7/PARITYDoubleBitUC
        m_cfg.m_args.k_sram_double_bit_error = err_int_det_switch;
      <%}%>
      end
    end
    else begin //Defaults if configured from cmdline
      err_int_det_switch = 1;
      data_switch = 0;
    end

    <% if(mrd_sram_secded || mrd_sram_parity) { %>
    if(!choose_cmd_sequence) begin
      `uvm_info("RUN_MAIN",$sformatf("Error Scenario MRD | Address:%0b SingleBitData:%0b DoubleBitData:%0b switches(detect:%0b,data/addr:%0b,mission:%0b)",
        m_cfg.m_args.k_sram_address_error,m_cfg.m_args.k_sram_single_bit_error,m_cfg.m_args.k_sram_double_bit_error,err_int_det_switch,data_switch,is_mission_fault_test),UVM_LOW)
      //SECDED/PARITY--BEGIN/////////////////////////////////////////////////////////////////////////
      ///////////MRD SRAM /////////////////////////////////////////////////////////////////////////
      <% if(mrd_sram_secded) {%>
      if(m_cfg.m_args.k_sram_address_error || m_cfg.m_args.k_sram_double_bit_error) begin
        exp_err_info = 3'h6;
      end
      <%} else {%>
      if(m_cfg.m_args.k_sram_address_error || m_cfg.m_args.k_sram_single_bit_error) begin
        exp_err_info = 3'h6;
      end
      <%} %>
      m_cfg.m_args.sram_uc_error_test = m_cfg.m_args.k_sram_address_error | m_cfg.m_args.k_sram_single_bit_error | m_cfg.m_args.k_sram_double_bit_error;
      program_xUEDR_xUEIR(err_int_det_switch,err_int_det_switch); 
      ev.trigger();
      control_mrd_delay(1);
      wait_on_mrd_sram_init_done();
      control_mrd_delay(0);
      inject_mrd_sram_error();
      if(err_int_det_switch) begin
        //Check injected error propagates to interrupt
        wait_on_IRQ_UC(1);
        //Read error type, info and count and ensure it matches expected
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
        compareValues("DMIUUESR_ErrVld", "set after interrupt", read_data, 1);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
        compareValues("DMIUUESR_ErrType","valid type", read_data, exp_err_type);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
        compareValues("DMIUUESR_ErrType","valid type", read_data, exp_err_info);
        if(m_cfg.m_args.k_sram_address_error) begin
          bit addr_match;
          int addr_elr[2];
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR0.ErrAddr, read_data);
          addr_elr[0] = read_data;
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR1.ErrAddr, read_data);
          addr_elr[1] = read_data;
          addr_match = ($countones(u_csr_probe_vif.mrd_error_injected_addr ^ addr_elr[0]) == 1 );
          if(addr_match) begin
            `uvm_info("RUN_MAIN",$sformatf("Error location check:: DMIUUELR0:'h%0h DMIUUELR1:'h%0h | addr_match=%0b", addr_elr[0], addr_elr[1], addr_match),UVM_LOW)
          end
          else begin
            `uvm_error("RUN_MAIN",$sformatf("Error location check::Injected MRD address error mismatches with value read from CSR. DMIUUELR0:'h%0h DMIUUELR1:'h%0h != error_address:'h%0h| addr_match=%0b", addr_elr[0], addr_elr[1], u_csr_probe_vif.mrd_error_injected_addr, addr_match))
          end
        end
        //Reset ErrVld
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, 1);
        //Check Reset
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
        compareValues("DMIUUESR_ErrVld", "reset", read_data, 0);
        dmi_scb.cov.collect_skidbuf_UCE_stats(exp_err_info,is_mission_fault_test);
      end
      else begin
        //Check injected error does not propagates to interrupt
        wait_on_IRQ_UC(0);
        //Read error type, info and count and ensure it isn't toggling
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
        compareValues("DMIUUESR_ErrVld", "set after interrupt", read_data, 0);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
        compareValues("DMIUUESR_ErrType","valid type", read_data, 0);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
        compareValues("DMIUUESR_ErrType","valid type", read_data, 0);
      end
      //End of flow check
      check_IRQ_UC(0);
      //Reset registers////////////////////////////////////////////////////////////////////////////
      program_xUEDR_xUEIR(0,0); 
    end
    <% } %>
    <% if(cmd_sram_secded || cmd_sram_parity) { %>
    ///////////CMD SRAM /////////////////////////////////////////////////////////////////////////
    if(choose_cmd_sequence) begin
      <% if(cmd_sram_secded) {%>
      //#Check.DMI.Concerto.v3.7/SECDEDAddressUC
      //#Check.DMI.Concerto.v3.7/SECDEDMultiBitDataUC
      if(m_cfg.m_args.k_sram_address_error || m_cfg.m_args.k_sram_double_bit_error) begin
        exp_err_info = 3'h5;
      end
      <%} else {%>
      if(m_cfg.m_args.k_sram_address_error || m_cfg.m_args.k_sram_single_bit_error) begin
        exp_err_info = 3'h5;
      end
      <%} %>
      `uvm_info("RUN_MAIN",$sformatf("Error Scenario CMD | Address:%0b SingleBitData:%0b DoubleBitData:%0b switches(detect:%0b,data/addr:%0b,mission:%0b)",
        m_cfg.m_args.k_sram_address_error,m_cfg.m_args.k_sram_single_bit_error,m_cfg.m_args.k_sram_double_bit_error,err_int_det_switch,data_switch,is_mission_fault_test),UVM_LOW)
      m_cfg.m_args.sram_uc_error_test = m_cfg.m_args.k_sram_address_error | m_cfg.m_args.k_sram_single_bit_error | m_cfg.m_args.k_sram_double_bit_error;
      program_xUEDR_xUEIR(err_int_det_switch,err_int_det_switch); 
      ev.trigger();
      control_cmd_delay(1); 
      wait_on_cmd_sram_init_done();
      control_cmd_delay(0);
      inject_cmd_sram_error();
      if(err_int_det_switch) begin
        //Check injected error propagates to interrupt
        wait_on_IRQ_UC(1);
        //Read error type, info and count and ensure it matches expected
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
        compareValues("DMIUUESR_ErrVld", "set after interrupt", read_data, 1);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
        compareValues("DMIUUESR_ErrType","valid type", read_data, exp_err_type);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
        compareValues("DMIUUESR_ErrType","valid type", read_data, exp_err_info);
        if(m_cfg.m_args.k_sram_address_error) begin
          bit addr_match;
          int addr_elr[2];
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR0.ErrAddr, read_data);
          addr_elr[0] = read_data;
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR1.ErrAddr, read_data);
          addr_elr[1] = read_data;
          addr_match = ($countones(u_csr_probe_vif.cmd_error_injected_addr ^ addr_elr[0]) == 1 );
          if(addr_match) begin
            `uvm_info("RUN_MAIN",$sformatf("Error location check:: DMIUUELR0:'h%0h DMIUUELR1:'h%0h | addr_match=%0b", addr_elr[0], addr_elr[1], addr_match),UVM_LOW)
          end
          else begin
            `uvm_error("RUN_MAIN",$sformatf("Error location check::Injected CMD address error mismatches with value read from CSR. DMIUUELR0:'h%0h DMIUUELR1:'h%0h != error_address:'h%0h| addr_match=%0b", addr_elr[0], addr_elr[1], u_csr_probe_vif.cmd_error_injected_addr, addr_match))
          end
        end
        //Reset ErrVld
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, 1);
        //Check Reset
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
        compareValues("DMIUUESR_ErrVld", "reset", read_data, 0);
        dmi_scb.cov.collect_skidbuf_UCE_stats(exp_err_info,is_mission_fault_test);
      end
      else begin
        //Check injected error does not propagates to interrupt
        wait_on_IRQ_UC(0);
        //Read error type, info and count and ensure it isn't toggling
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
        compareValues("DMIUUESR_ErrVld", "set after interrupt", read_data, 0);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
        compareValues("DMIUUESR_ErrType","valid type", read_data, 0);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
        compareValues("DMIUUESR_ErrType","valid info", read_data, 0);
      end
      //End of flow check
      check_IRQ_UC(0);
      //Reset registers////////////////////////////////////////////////////////////////////////////
      program_xUEDR_xUEIR(0,0);
    end
    //SECDED/PARITY--END///////////////////////////////////////////////////////////////////////////
    <% } %>

    <% if(!(mrd_sram_secded || cmd_sram_secded || mrd_sram_parity || cmd_sram_parity)) { %>
    //Unexpected IRQ_UC in any scenario that is not MRD or CMD SRAM with protection enabled
    m_cfg.m_args.sram_error_test = 0; //Enable end of test checks on CSR for error registers.
    ev.trigger();
    fork 
      begin
        `uvm_info("RUN_MAIN",$sformatf("Waiting for an uncorrectable interrupt. It should not trigger"), UVM_LOW)
        @(u_csr_probe_vif.IRQ_UC);
        `uvm_error("RUN_MAIN", $sformatf("Unexpected uncorrectable interrupt!"))
      end
      begin
        #5000ns;
        `uvm_info("RUN_MAIN",$sformatf("Done waiting. No uncorrectable interrupt received"), UVM_LOW)
      end
    join_any
    //ErrVld should be 0
    read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
    compareValues("DMIUUESR_ErrVld", "set", read_data, 0);
    read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
    compareValues("DMIUCESAR_ErrVld", "set", read_data, 0);
    <% } %>
  endtask
endclass

class plru_error_injection_seq extends dmi_ral_csr_base_seq;
  `uvm_object_utils(plru_error_injection_seq)

  error_type_t error_type;

  function new(string name="plru_error_injection_seq");
    super.new(name);
  endfunction

  task body();
    super.body();
  <%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
    `uvm_info("RUN_MAIN","Starting plru_error_injection_seq.",UVM_LOW)
    getCsrProbeIf();
    getInjectErrEvent();
    if(m_cfg.m_args.k_plru_error_mode == NULL_ERROR) begin 
      std::randomize(error_type) with { error_type inside {ADDRESS_ERROR,SINGLE_BIT_DATA_ERROR,DOUBLE_BIT_DATA_ERROR}; };
    end
    if(error_type==ADDRESS_ERROR) begin
      m_cfg.m_args.k_plru_error_mode = ADDRESS_ERROR;
      `uvm_info("RUN_MAIN","Setting non-zero values for PLRU address error injection",UVM_LOW)
      setPlruAddrErrInj.trigger();
    end
    else if(error_type == SINGLE_BIT_DATA_ERROR) begin
      m_cfg.m_args.k_plru_error_mode = SINGLE_BIT_DATA_ERROR;
      `uvm_info("RUN_MAIN","Setting non-zero values for PLRU Single bit data error injection",UVM_LOW)
      setPlruSingleDataErrInj.trigger();
    end
    else if(error_type == DOUBLE_BIT_DATA_ERROR) begin
      m_cfg.m_args.k_plru_error_mode = DOUBLE_BIT_DATA_ERROR;
      `uvm_info("RUN_MAIN","Setting non-zero values for PLRU Double bit data error injection",UVM_LOW)
      setPlruDoubleDataErrInj.trigger();
    end
    else begin
      `uvm_fatal("RUN_MAIN",$sformatf("PLRU sequence needs a valid error type set to proceed. Current type :%0s", error_type.name))
    end
    `uvm_info("RUN_MAIN","plru_error_injection_seq finished.",UVM_LOW)
    ev.trigger();
  <% } %>
  endtask
endclass
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are logged and interupt signal is asserted from DUT.
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. If dmi contains SECDED, Write Error threshold with 1 (DUT must assert Interrupt once threshold value errors are corrected.
* 2. Eable Error detection from correctable CSR.
* 3. Enable Error Interrupt from CSR. If enabled then correctable iterrupt signal is asserted.
* 4. Enable SRAM single-bit error from command line with 100% (all writes/read in SRAM)
* 5. Poll interrupt signal from interface if not asserted issue Timeout error.
* 6. Read ErrVld field should be 1 (Error information logged) and Check ErrType 0x1 (Read Buffer in this case)
* 7. Disable Error Detection and Error Interrupt filed by writing 0.
* 8. Clear ErrVld by writting 1 (W1C access types of this field) in status register
* 9. Compare read value with 0 for ErrVld field in status register (should be cleared)
* 10. Poll for interrupt signal after disabling error detection and interrupt, should not assert this signal.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
class dmi_csr_dmicecr_errInt_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicecr_errInt_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
    getCsrProbeIf();
    getInjectErrEvent();
    <% if(has_secded) { %>
        if((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin
           repeat(5) begin
           // Set the DMIUCECR_ErrThreshold 
           if(($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test")) || ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) begin
             errtype = 4'b1;
           end else if($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")) begin
             errtype = 4'b0;
           end

           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
           // Set the DMIUCECR_ErrDetEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
           // Set the DMIUCECR_ErrIntEn = 1
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
           // wait for IRQ_C interrupt 
           ev.trigger();
           inject_error(1,.wbuffer_addr(wbuf_addr)); 
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 1);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
           join_any
           disable fork;
           // Read the DMIUCESR_ErrVld
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
           compareValues("DMIUCESR_ErrVld", "set after inte", read_data, 1);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, read_data);
           compareValues("DMIUCESR_ErrType","Valid Type", read_data, errtype);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
           // write DMIUCESR_ErrVld = 1 to clear it
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
           // Read DMIUCESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
           compareValues("DMIUCESR_ErrVld", "reset", read_data, 0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_C === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asserted"), UVM_LOW)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still aseerted"));
           end
            if(!$test$plusargs("back_to_back_error"))
            break;
        end
        // Set the DMIUCECR_ErrDetEn = 0, to disable the error detection
           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
           // Set the DMIUCECR_ErrIntEn = 0, to disable the error Interrupt
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);

        end else if((tag_parity && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_parity && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_parity && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin 
          // Set the DMIUUEDR_MemErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          // Set the DMIUUEDR_MemErrIntEn = 1
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          poll_DMIUUESR_ErrVld(1, poll_data);

          fork
          begin
              wait (u_csr_probe_vif.IRQ_UC === 1);
          end
          begin
            #200000ns;
            `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
          end
          join_any
          disable fork;
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "set after inte", read_data, 1);

          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
          // write DMIUUESR_ErrVld = 1 to clear it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          // Read DMIUUESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "reset", read_data, 0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC === 0)begin
            `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
          end else begin
            `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
          end
        end else begin
          // Read DMIUCESR_ErrVld , it should be 0
           ev.trigger();
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
           compareValues("DMIUCESR_ErrVld", "set", read_data, 0);
          // Read DMIUCESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, read_data);
           compareValues("DMIUCESAR_ErrVld", "set", read_data, 0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_C === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asserted"), UVM_LOW)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still asserted"));
          end
        end
    <% } else if (wbuffer_fnerrdetectcorrect) { %>
        if(wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) begin
          // Set the DMIUCECR_ErrThreshold 
          errtype = 4'b0;

          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          // Set the DMIUCECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // Set the DMIUCECR_ErrIntEn = 1
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
          // wait for IRQ_C interrupt 
          ev.trigger();
          inject_error(1,.wbuffer_addr(wbuf_addr)); 
          fork
          begin
            wait (u_csr_probe_vif.IRQ_C === 1);
          end
          begin
            #200000ns;
            `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
          end
          join_any
          disable fork;
          // Read the DMIUCESR_ErrVld
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "set after inte", read_data, 1);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, read_data);
          compareValues("DMIUCESR_ErrType","Valid Type", read_data, errtype);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
          // Set the DMIUCECR_ErrDetEn = 0, to disable the error detection
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // Set the DMIUCECR_ErrIntEn = 0, to disable the error Interrupt
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
          // write DMIUCESR_ErrVld = 1 to clear it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
          // Read DMIUCESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "reset", read_data, 0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_C === 0)begin
            `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asserted"), UVM_LOW)
          end else begin
            `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still aseerted"));
          end
        end else if(wbuffer_parity && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) begin
          // Set the DMIUUEDR_MemErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          // Set the DMIUUEDR_MemErrIntEn = 1
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          poll_DMIUUESR_ErrVld(1, poll_data);

          fork
          begin
              wait (u_csr_probe_vif.IRQ_UC === 1);
          end
          begin
            #200000ns;
            `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
          end
          join_any
          disable fork;
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "set after inte", read_data, 1);

          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
          // write DMIUUESR_ErrVld = 1 to clear it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          // Read DMIUUESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "reset", read_data, 0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC === 0)begin
            `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
          end else begin
            `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
          end
        end else begin
          // Read DMIUCESR_ErrVld , it should be 0
           ev.trigger();
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
           compareValues("DMIUCESR_ErrVld", "set", read_data, 0);
          // Read DMIUCESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, read_data);
           compareValues("DMIUCESAR_ErrVld", "set", read_data, 0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_C === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asserted"), UVM_LOW)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still asserted"));
          end
        end
    <% } else { %>
          // Read DMIUCESR_ErrVld , it should be 0
           ev.trigger();
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
           compareValues("DMIUCESR_ErrVld", "set", read_data, 0);
          // Read DMIUCESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, read_data);
           compareValues("DMIUCESAR_ErrVld", "set", read_data, 0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_C === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asserted"), UVM_LOW)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still asserted"));
          end
    <% } %>
    endtask
endclass : dmi_csr_dmicecr_errInt_seq
//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
//#Test.DMI.ErrInjWhileSoftwareWriteHappens
class dmi_csr_dmicecr_sw_write_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicecr_sw_write_seq)

   uvm_reg_data_t poll_data, read_data, read_data2, write_data;
   bit [7:0]  errthd;
   int        errcount_vld, errthd_vld;
   int        i,j;

    function new(string name="");
        super.new(name);
    endfunction

   task body();

       //getCsrProbeIf();
getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
        if((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin
          // Set the DMIUCECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          ev.trigger();
          inject_error(1,.wbuffer_addr(wbuf_addr)); 
          poll_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld,1,poll_data);
          // write  DMIUCESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);

          write_data = 0;
          fork
              begin
                 for (i=0;i<100;i++) begin
                    write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, write_data);
                 end
              end
              begin
                for (j=0;j<10;j++) begin
                  inject_error(.wbuffer_addr(wbuf_addr)); 
                end
              end
          join
          // Set the DMIUCECR_ErrDetEn = 0
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // if vld is set, reset it
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          if(read_data) begin
             write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, write_data);
          end
        end else begin
          ev.trigger();
        end
<% } else { %>
           ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmicecr_sw_write_seq

class set_max_errthd extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(set_max_errthd)

  uvm_reg_data_t write_data;
  uvm_reg_data_t poll_data;

  function new(string name="");
      super.new(name);
  endfunction

  task body();
    bit dis_cecr_med_4resiliency = $test$plusargs("dis_cecr_med_4resiliency") ? 1 : 0;
    getCsrProbeIf();
    getInjectErrEvent();
    write_data = 255; //Set max errThd
    <% if(obj.useResiliency) { %>
    `uvm_info(get_name(), $sformatf("Writing DMIUCRTR res_corr_err_threshold = %0d", write_data), UVM_NONE)
    write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCRTR.ResThreshold, write_data);
    <% } %>
    if(!dis_cecr_med_4resiliency) begin
    write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
    write_data = 1;
    write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
    write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
    ev.trigger();
    inject_error(255,5,1'b1,.wbuffer_addr(wbuf_addr)); 
    poll_DMIUCESR_ErrVld(0, poll_data);
    poll_DMIUCESR_ErrCountOverflow(0,poll_data);
    poll_DMIUCESR_ErrCount(255,poll_data);
    if(poll_data != 255) begin
        `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be 255",poll_data))
    end
    inject_error(1,.wbuffer_addr(wbuf_addr)); 
    poll_DMIUCESR_ErrVld(1, poll_data);
    // wait for IRQ_C interrupt 
    fork
    begin
      wait (u_csr_probe_vif.IRQ_C === 1);
    end
    begin
      #200000ns;
      `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
    end
    join_any
    disable fork;
    poll_DMIUCESR_ErrCountOverflow(0,poll_data);
    poll_DMIUCESR_ErrCount(255,poll_data);
    if(poll_data != 255) begin
        `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be 255",poll_data))
    end
    inject_error(1,.wbuffer_addr(wbuf_addr)); 
    poll_DMIUCESR_ErrVld(1, poll_data);
    poll_DMIUCESR_ErrCountOverflow(1,poll_data);
    poll_DMIUCESR_ErrCount(255,poll_data);
    if(poll_data != 255) begin
        `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be 255",poll_data))
    end
    write_data = 0;
    write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
    write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
    end
    else begin
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, 0);
      ev.trigger();
      inject_error(256,5,1'b1,.wbuffer_addr(wbuf_addr));
      #200us;
      `uvm_info("RUN_MAIN",$sformatf("Timeout!"), UVM_NONE);
    end
    <% if(obj.useResiliency) { %>
    begin
      bit is_check = <% if(has_secded) { %> (tag_secded || data_secded || wbuffer_secded) ? 1 : 0; <% } else if (wbuffer_fnerrdetectcorrect) { %> (wbuffer_secded) ? 1 : 0; <% } else { %> 0; <% } %>
      if(is_check) begin
        if(!u_csr_probe_vif.cerr_over_thres_fault) begin
          `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted"));
        end
        else begin
          `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted"), UVM_NONE);
        end
      end
    end
    <% } %>
  endtask
endclass : set_max_errthd

class always_inject_error extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(always_inject_error)

  uvm_reg_data_t write_data;

  function new(string name="");
      super.new(name);
  endfunction

  task body();
    write_data = 1;
    write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
    ev.trigger();
    ev_always_inject_error.trigger();
  endtask
endclass : always_inject_error

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are injected and logging is disabled (ErrDetEn set to 0) ErrVld and ErrCount should be 0. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. Enable SRAM single-bit error from command line with 100% (all writes/read in SRAM)
* 2. Compare ErrVld value and should be zero 
* 3. Compare ErrCount value and should be zero 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
//#Test.DMI.DetectEnNotSetErrorsInjected
class dmi_csr_dmicecr_noDetEn_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicecr_noDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       //getCsrProbeIf();
getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
        if((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          // Don't Set the DMIUCECR_ErrDetEn = 1
          //Reading the DMIUCESR_ErrVld bit = 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "not set", read_data, 0);
          // Read DMIUCESR_ErrCount , it should be at 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
          compareValues("DMIUCESR_ErrCount","not set", read_data, 0); 
        end else if((tag_parity && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_parity && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_parity && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin 
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          // Set the DMIUUEDR_MemErrIntEn = 1
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "not set", read_data, 0);
        end else begin
          ev.trigger();
       // Read the DMIUCESR_ErrVld should be cleared
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "not set", read_data, 0);
        // Read DMIUCESAR_ErrVld , it should also clear, beacuse it is alias register
        // of register DMIUCESR_*
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, read_data);
          compareValues("DMIUCESAR_ErrVld", "not set", read_data, 0);
        end
<% } else if (wbuffer_fnerrdetectcorrect) { %>
        if(wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) begin
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          // Don't Set the DMIUCECR_ErrDetEn = 1
          //Reading the DMIUCESR_ErrVld bit = 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "not set", read_data, 0);
          // Read DMIUCESR_ErrCount , it should be at 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
          compareValues("DMIUCESR_ErrCount","not set", read_data, 0);
        end else if(wbuffer_parity && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) begin
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          // Set the DMIUUEDR_MemErrIntEn = 1
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "not set", read_data, 0);
        end else begin
          ev.trigger();
       // Read the DMIUCESR_ErrVld should be cleared
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "not set", read_data, 0);
        // Read DMIUCESAR_ErrVld , it should also clear, beacuse it is alias register
        // of register DMIUCESR_*
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, read_data);
          compareValues("DMIUCESAR_ErrVld", "not set", read_data, 0); 
        end
<% } else { %>
          ev.trigger();
       // Read the DMIUCESR_ErrVld should be cleared
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "not set", read_data, 0);
        // Read DMIUCESAR_ErrVld , it should also clear, beacuse it is alias register
        // of register DMIUCESR_*
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, read_data);
          compareValues("DMIUCESAR_ErrVld", "not set", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_dmicecr_noDetEn_seq
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are injected and interrupt assertion is disabled (ErrIntEn set to 0) ErrVld and ErrCount should be 0. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. Enable SRAM single-bit error from command line with 100% (all writes/read in SRAM)
* 2. Program ErrThreshold to 1 so we can check interupt is asserted or not.
* 3. Enable  error detection and logging.       
* 4. Wait to check if interrupt signal is asserted or not.
* 5. Poll for ErrVld be set and compare to 1.
* 6. Clear ErrVld value and should be zero 
* 7. Compare ErrCountOverflow value and should be zero 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dmi_csr_dmicecr_noIntEn_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicecr_noIntEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
        if((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin
          // Set the DMIUCECR_ErrThreshold 
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          // Set the DMIUCECR_ErrDetEn = 1
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // Dont Set the DMIUCECR_ErrIntEn = 1
          ev.trigger();
          inject_error(2,5,1'b1,.wbuffer_addr(wbuf_addr)); 
          // wait for IRQ_C interrupt for a while. should not trigger. Then join
          //#Cov.DMI.ErrIntDisEnCorrErrs
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It should not trigger"), UVM_LOW)
             @(u_csr_probe_vif.IRQ_C);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #50000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_LOW)
            end
          join_any
          disable fork;
          //Reading the DMIUCESR_ErrVld bit = 1
          poll_DMIUCESR_ErrVld(1, poll_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "set", read_data, 1);
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // write DMIUCESR_ErrVld = 1 to clear it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR_ErrCountOverflow", "Should be clear", read_data, 0);
          // write DMIUCESR_ErrVld = 1 to clear it
        end else if((tag_parity && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_parity && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_parity && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin 
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          // Set the DMIUUEDR_MemErrIntEn = 1
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It should not trigger"), UVM_LOW)
             @(u_csr_probe_vif.IRQ_UC);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #50000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_LOW)
            end
          join_any
          disable fork;
          poll_DMIUUESR_ErrVld(1, poll_data);
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "not set", read_data, 0);
        end else begin
          ev.trigger();
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It should not trigger"), UVM_LOW)
            @(u_csr_probe_vif.IRQ_C);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #100000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_LOW)
            end
          join_any
          disable fork;
        end
<% } else if (wbuffer_fnerrdetectcorrect) { %>
        if(wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) begin
          // Set the DMIUCECR_ErrThreshold 
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          // Set the DMIUCECR_ErrDetEn = 1
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          // Dont Set the DMIUCECR_ErrIntEn = 1
          ev.trigger();
          inject_error(2,5,1'b1,.wbuffer_addr(wbuf_addr)); 
          // wait for IRQ_C interrupt for a while. should not trigger. Then join
          //#Cov.DMI.ErrIntDisEnCorrErrs
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It should not trigger"), UVM_LOW)
             @(u_csr_probe_vif.IRQ_C);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #50000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_LOW)
            end
          join_any
          disable fork;
          //Reading the DMIUCESR_ErrVld bit = 1
          poll_DMIUCESR_ErrVld(1, poll_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "set", read_data, 1);
          // write DMIUCESR_ErrVld = 1 to clear it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR_ErrCountOverflow", "Should be clear", read_data, 0);
          // write DMIUCESR_ErrVld = 1 to clear it
        end else if(wbuffer_parity && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) begin
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          // Set the DMIUUEDR_MemErrIntEn = 1
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It should not trigger"), UVM_LOW)
             @(u_csr_probe_vif.IRQ_UC);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #50000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_LOW)
            end
          join_any
          disable fork;
          poll_DMIUUESR_ErrVld(1, poll_data);
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "not set", read_data, 0);
        end else begin
          ev.trigger();
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It should not trigger"), UVM_LOW)
            @(u_csr_probe_vif.IRQ_C);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #100000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_LOW)
            end
          join_any
          disable fork;
        end
<% } else { %>
          ev.trigger();
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It should not trigger"), UVM_LOW)
            @(u_csr_probe_vif.IRQ_C);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #100000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_LOW)
            end
          join_any
          disable fork;
<% } %>
    endtask
endclass : dmi_csr_dmicecr_noIntEn_seq
//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : To test writing to Vld bit when it is not set doesn't affect count
//  Note    : If the error count field is equal to the error threshold field, the
//            error valid bit is set when a new error is corrected, and once the error valid bit becomes set, the error
//            count field is frozen at its current value. If the error valid bit is set and a new error is corrected, the
//            error overflow bit is set. 
//-----------------------------------------------------------------------
class dmi_csr_dmicesr_rstNoVld_seq1 extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicesr_rstNoVld_seq1)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
        if((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin
          ev.trigger();
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          // Try Set the DMIUCESR_ErrVld = 1. should not work as this field is W1C
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld","Should be 0", read_data, 0);

          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR_ErrCountOverflow","Should be 0", read_data, 0);
        end else begin
          ev.trigger();
        end

<% } else { %>
           ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmicesr_rstNoVld_seq1

class dmi_csr_dmicesr_rstNoVld_seq2 extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicesr_rstNoVld_seq2)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
          //keep on  Reading the DMIUCESR_ErrCount bit = 1
<% if(has_secded) { %>
        if((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin
          write_data = 1;
          errthd = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, errthd);
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          poll_DMIUCESR_ErrCount(1, poll_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "set", read_data, 0);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR.ErrCountOverflow", "not set yet", read_data, 0);


          write_data = 0;
          errthd = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, errthd);
          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld","Should be 0", read_data, 0);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR_ErrCountOverflow","Should be 0", read_data, 0);
        end else begin
          ev.trigger();
        end
<% } else { %>
           ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmicesr_rstNoVld_seq2

class dmi_csr_dmicesr_rstNoVld_seq3 extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicesr_rstNoVld_seq3)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
          //keep on  Reading the DMIUCESR_ErrCount bit = 1
<% if(has_secded) { %>
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          poll_DMIUCESR_ErrCount(1, poll_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld", "not set yer", read_data, 0);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR.ErrCountOverflow", "not set yet", read_data, 0);


          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld","Should be 0", read_data, 0);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR_ErrVld","Should be 0", read_data, 0);

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCount, read_data);
          compareValues("DMIUCESR_ErrCount", "not reset", read_data, 1);

<% } else { %>
           ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmicesr_rstNoVld_seq3
/////////////////////////////////////////////////////////////
// 1.:vsp


class dmi_csr_dmicelr_seq22 extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicelr_seq22)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    bit [19:0] errentry;
    bit [25:20] errway;
    bit [31:26] errword;
    int erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCELR0.ErrAddr, read_data);
          {errword,errway,errentry} = read_data;
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCELR1.ErrAddr, read_data);
          erraddr = read_data;

<% } else { %>
           ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmicelr_seq22

class dmi_csr_dmicelr_seq3 extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicelr_seq3)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    bit [19:0] errentry;
    bit [25:20] errway;
    bit [31:26] errword;
    int erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          //poll_DMIUCESR_ErrCount(2, poll_data);
          poll_DMIUCESR_ErrCountOverflow(1, poll_data);
          //compareValues("DMIUCESR.ErrCountOverflow", "set now", read_data, 1);

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCELR0.ErrAddr, read_data);
          compareValues("DMIUCELR0_ErrEntry", "match with older value", read_data[19:0], errentry);
          compareValues("DMIUCELR0_ErrWay", "match with older value", read_data[25:20], errway);
          compareValues("DMIUCELR0_ErrWord", "match with older value", read_data[31:26], errword);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCELR1.ErrAddr, read_data);
          compareValues("DMIUCELR1_ErrAddr", "match with older value", read_data, erraddr);
<% } else { %>
           ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmicelr_seq3

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_dmicelr_seq1 extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicelr_seq1)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          // Try Set the DMIUCESR_ErrVld = 1. should not work as this field is W1C
          //#Check.DMI.DetectEnSet
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
          compareValues("DMIUCESR_ErrVld","Should be 0", read_data, 0);

          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrCountOverflow, read_data);
          compareValues("DMIUCESR_ErrVld","Should be 0", read_data, 0);

          //assert(randomize(errthd));
          errthd = 1; // TODO: Randomize
          write_data = errthd;
          // Set the DMIUCECR_ErrThreshold
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          // Set the DMIUCECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
          inject_error(errthd,.wbuffer_addr(wbuf_addr)); 
<% } else { %>
           ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmicelr_seq1

class dmi_csr_dmicelr_seq11 extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmicelr_seq11)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          //keep on  Reading the DMIUCESR_ErrCount bit = 1
          poll_DMIUCESR_ErrCount(1, poll_data);
<% } else { %>
           ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmicelr_seq11

class dmi_csr_elr_seq_trans_err extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_elr_seq_trans_err)

    uvm_reg_data_t poll_data, read_data, write_data;
    bit [19:0] errentry;
    bit [5:0] errway;
    bit [5:0] errword;
    bit [19:0] erraddr;
    int wr_resp_err;
    int rd_resp_err;
    bit [19:0] errinfo_rresp_err;
    bit [19:0] errinfo_bresp_err;
    bit [15:0]errinfo_targ_id_err;
    axi_axaddr_t exp_err_addr;
    bit [51:0]actual_err_addr;
    dmi_scb_txn scb_txn;
    smi_seq_item wrong_tag_id_pkt;
    axi_rresp_t rresp_err;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      bit dis_uedr_ted_4resiliency = $test$plusargs("dis_uedr_ted_4resiliency") ? 1 : 0;

      getCsrProbeIf();
      getInjectErrEvent();
      if(dis_uedr_ted_4resiliency) begin
        `uvm_info(get_full_name(),$sformatf("Skipping enabling of error detection inside xUEDR"),UVM_NONE)
        ev.trigger();
        if(m_cfg.m_args.k_wrong_target_id) begin
          ev_wrong_targ_id.wait_ptrigger();
        end
      end
      else begin
          `uvm_info("RUN_MAIN",$sformatf("Entered in to CSR seq"), UVM_LOW)
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.TransErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.TransErrIntEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.ProtErrIntEn, write_data);
          ev.trigger();
          if ($value$plusargs("prob_ace_wr_resp_error=%d",wr_resp_err)) begin
            if (wr_resp_err == 100) begin
              fork
                begin
                  ev_bresp.wait_ptrigger();
                  $cast(scb_txn,ev_bresp.get_trigger_data());
                  exp_err_addr = scb_txn.axi_write_addr_pkt.awaddr;
                  errinfo_bresp_err = {scb_txn.axi_write_addr_pkt.awid,4'h0,scb_txn.isEvict,scb_txn.security,scb_txn.axi_write_resp_pkt.bresp};
                end
                begin
                  #30000ns;
                  `uvm_error("BRESP","BRESP event was not triggered")
                end
              join_any
              disable fork;
            end
          end
          if ($value$plusargs("prob_ace_rd_resp_error=%d",rd_resp_err)) begin
            if (rd_resp_err == 100) begin
              fork
                begin
                  ev_rresp.wait_ptrigger();
                  $cast(scb_txn,ev_rresp.get_trigger_data());
                  exp_err_addr = scb_txn.axi_read_addr_pkt.araddr;
                  foreach(scb_txn.axi_read_data_pkt.rresp_per_beat[i]) begin
                    if(scb_txn.axi_read_data_pkt.rresp_per_beat[i] === 2 || scb_txn.axi_read_data_pkt.rresp_per_beat[i] === 3) begin
                      rresp_err = scb_txn.axi_read_data_pkt.rresp_per_beat[i];
                      break;
                    end
                  end
                  errinfo_rresp_err = {scb_txn.axi_read_addr_pkt.arid,4'h0,scb_txn.fillExpd,scb_txn.security,rresp_err};
                end
                begin
                  #30000ns;
                  `uvm_error("RRESP","RRESP event was not triggered")
                end
              join_any
              disable fork;
            end
          end
          if(m_cfg.m_args.k_wrong_target_id) begin
            ev_wrong_targ_id.wait_ptrigger();
            $cast(wrong_tag_id_pkt,ev_wrong_targ_id.get_trigger_data());
            errinfo_targ_id_err[15:6] = wrong_tag_id_pkt.smi_src_ncore_unit_id;
            //errinfo_targ_id_err[5:1] = 1'b0;  //Reserved
            errinfo_targ_id_err[0] = 1'b0;      //Type, 1;b0: wrong targ_id
          end
          `uvm_info(get_full_name(),$sformatf("errinfo_targ_id_err = 0x%0x",errinfo_targ_id_err),UVM_MEDIUM)
          `uvm_info(get_full_name(),$sformatf("exp_err_addr = 0x%0x, errinfo_bresp_err = 0x%0x",exp_err_addr,errinfo_bresp_err),UVM_MEDIUM)
          `uvm_info(get_full_name(),$sformatf("exp_err_addr = 0x%0x, errinfo_rresp_err = 0x%0x",exp_err_addr,errinfo_rresp_err),UVM_MEDIUM)
          poll_DMIUUESR_ErrVld(1, poll_data);
          fork
          begin
              wait (u_csr_probe_vif.IRQ_UC === 1);
          end
          begin
            #200000ns;
            `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
          end
          join_any
          disable fork;
          if (rd_resp_err == 100) begin
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
            compareValues("DMIUUESR.ErrType","should be",read_data,3);
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
            compareValues("DMIUUESR.ErrInfo","should be",read_data,errinfo_rresp_err);
          end
          if (wr_resp_err == 100) begin
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
            compareValues("DMIUUESR.ErrType","should be",read_data,2);
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
            compareValues("DMIUUESR.ErrInfo","should be",read_data,errinfo_bresp_err);
          end
          if ($test$plusargs("wrong_targ_id_dtw") || $test$plusargs("wrong_targ_id_cmd") || $test$plusargs("wrong_targ_id_mrd")) begin
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
            compareValues("DMIUUESR.ErrType","should be",read_data,8);
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
            compareValues("DMIUUESR.ErrInfo","should be",read_data,errinfo_targ_id_err);
          end

          if (rd_resp_err == 100 || wr_resp_err == 100) begin
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR0.ErrAddr, read_data);
            {errword,errway,errentry} = read_data;
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR1.ErrAddr, read_data);
            erraddr = read_data;
            actual_err_addr = {erraddr,errword,errway,errentry};
            if (actual_err_addr !== exp_err_addr) begin
              `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x, expected(word 0x%0x,way 0x%0x,entry 0x%0x), actual :(word 0x%0x, way 0x%0x entry 0x%0x)",actual_err_addr,exp_err_addr,exp_err_addr[31:25],exp_err_addr[25:20],exp_err_addr[19:0],errentry,errway,errword))
            end
          end
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.TransErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.TransErrIntEn, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.ProtErrIntEn, write_data);
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld","Should be 0", read_data, 0);
      end
    endtask
endclass : dmi_csr_elr_seq_trans_err
class dmi_csr_time_out_error_seq_no_checks extends dmi_ral_csr_base_seq; 
  dmi_scoreboard dmi_scb;
  `uvm_object_utils(dmi_csr_time_out_error_seq_no_checks)

  uvm_reg_data_t poll_data, read_data, write_data,timeout_threshold;
  dmi_env_config m_env_cfg;

  function new(string name="dmi_csr_time_out_error_seq_no_checks");
    super.new(name);
  endfunction

  task body();
    `uvm_info("dmi_csr_time_out_error_seq_no_checks", "Starting timeout CSR sequence.",UVM_LOW)
    getCsrProbeIf();
    if (!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                             .inst_name( get_full_name() ),
                                             .field_name( "dmi_env_config" ),
                                             .value( m_env_cfg ))) begin
      `uvm_error("dmi_csr_time_out_error_seq_no_checks", "dmi_env_config handle not found")
    end
    if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                             .inst_name( get_full_name() ),
                                             .field_name( "dmi_scb" ),
                                             .value( dmi_scb ))) begin
      `uvm_error("dmi_csr_time_out_error_seq_no_checks", "dmi_scb model not found")
    end
    #50us;

    write_data = 1;
    write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.TimeoutErrDetEn, write_data);
    write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.TimeoutErrIntEn, write_data);
    timeout_threshold = $urandom_range(1,2);
    write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUTOCR.TimeOutThreshold, timeout_threshold);
    uvm_config_db#(int)::set(null, "uvm_test_top", "timeout_threshold", timeout_threshold);
    ev.trigger();

    fork
      begin
        if (m_env_cfg.m_args.k_wtt_timeout_error_test) begin
          int tt_txn_limit = $urandom_range(0,3);
          //<%=obj.strProjectName%>
          `uvm_info("dmi_csr_time_out_error_seq_no_checks", $sformatf("Injecting WTT timeout at txn#%0d",tt_txn_limit),UVM_LOW)
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MIN = 2000;
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MAX = 2200;
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_BURST_PCT = 0;
          wait(dmi_scb.wtt_q.size() == tt_txn_limit);
          `uvm_info("dmi_csr_time_out_error_seq_no_checks", $sformatf("Wait done. Setting WTT timeout at txn#%0d",tt_txn_limit),UVM_LOW)
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MIN = (timeout_threshold*4096*2);
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MAX = ((timeout_threshold*4096*2)+10);
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_BURST_PCT = 0;
          @(posedge u_csr_probe_vif.DMIUUESR_ErrVld)
          if(m_env_cfg.m_args.k_rtt_timeout_error_test) begin
            if((u_csr_probe_vif.DMIUUESR_ErrType[4:0] == 4'h9) &&
               (u_csr_probe_vif.DMIUUESR_ErrInfo[1:0] == 4'h0)) begin
              write_data = 1;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
              compareValues("DMIUUESR_ErrVld","Should be 0", read_data, 0);
              `uvm_info("dmi_csr_time_out_error_seq_no_checks", $sformatf("Registered a WTT timeout. Will continue to wait for RTT timeout"),UVM_LOW)
              @(posedge u_csr_probe_vif.DMIUUESR_ErrVld);
            end
          end

          `uvm_info("dmi_csr_time_out_error_seq_no_checks", $sformatf("ErrVld set for WTT timeout"),UVM_LOW)
          if((u_csr_probe_vif.DMIUUESR_ErrType[4:0] == 4'h9) &&
             (u_csr_probe_vif.DMIUUESR_ErrInfo[1:0] == 4'h1)) begin
            `uvm_info("dmi_csr_time_out_error_seq_no_checks", $sformatf("Registered a WTT timeout with ErrVld Set"),UVM_LOW)
          end
          else begin
            `uvm_error("dmi_csr_time_out_error_seq_no_checks", $sformatf("ErrVld asserted but csr_probe_if values are not what's expected. ErrType:%0h ErrInfo:%0h",
             u_csr_probe_vif.DMIUUESR_ErrType,u_csr_probe_vif.DMIUUESR_ErrInfo[1:0]))
          end
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MIN = 5;
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MAX = 10;
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_BURST_PCT = 100;
        end
      end
      begin
        if (m_env_cfg.m_args.k_rtt_timeout_error_test) begin
          int tt_txn_limit = $urandom_range(0,3);
          `uvm_info("dmi_csr_time_out_error_seq_no_checks", $sformatf("Injecting RTT timeout at txn#%0d",tt_txn_limit),UVM_LOW)
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MIN = 2000;
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MAX = 2200;
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_BURST_PCT = 0;
          wait(dmi_scb.rtt_q.size() == tt_txn_limit);
          `uvm_info("dmi_csr_time_out_error_seq_no_checks", $sformatf("Wait done. Setting RTT timeout at txn#%0d",tt_txn_limit),UVM_LOW)
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MIN = (timeout_threshold*4096*2);
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MAX = ((timeout_threshold*4096*2)+10);
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_BURST_PCT = 0;
          @(posedge u_csr_probe_vif.DMIUUESR_ErrVld)
          if(m_env_cfg.m_args.k_wtt_timeout_error_test) begin
            if((u_csr_probe_vif.DMIUUESR_ErrType[4:0] == 4'h9) &&
               (u_csr_probe_vif.DMIUUESR_ErrInfo[1:0] == 4'h1)) begin
              write_data = 1;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
              compareValues("DMIUUESR_ErrVld","Should be 0", read_data, 0);
              `uvm_info("dmi_csr_time_out_error_seq_no_checks", $sformatf("Registered a RTT timeout. Will continue to wait for WTT timeout"),UVM_LOW)
              @(posedge u_csr_probe_vif.DMIUUESR_ErrVld);
            end
          end
          `uvm_info("dmi_csr_time_out_error_seq_no_checks", $sformatf("ErrVld set for RTT timeout"),UVM_LOW)
          if((u_csr_probe_vif.DMIUUESR_ErrType[4:0] == 4'h9) &&
             (u_csr_probe_vif.DMIUUESR_ErrInfo[1:0] == 4'h0)) begin
            `uvm_info("dmi_csr_time_out_error_seq_no_checks", $sformatf("Registered a RTT timeout with ErrVld Set"),UVM_LOW)
          end
          else begin
            `uvm_error("dmi_csr_time_out_error_seq_no_checks", $sformatf("ErrVld asserted but csr_probe_if values are not what's expected. ErrType:%0h ErrInfo:%0h",
             u_csr_probe_vif.DMIUUESR_ErrType,u_csr_probe_vif.DMIUUESR_ErrInfo[1:0]))
          end
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MIN = 5;
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MAX = 10;
          m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_BURST_PCT = 100;
        end
      end
    join
    `uvm_info("dmi_csr_time_out_error_seq_no_checks", "Finished timeout CSR sequence.",UVM_LOW)
  endtask

endclass : dmi_csr_time_out_error_seq_no_checks

class dmi_csr_time_out_error_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_time_out_error_seq)

    uvm_reg_data_t poll_data, read_data, write_data,timeout_threshold;
    bit [47:0] actual_addr;
    bit [47:0] expt_addr;
    dmi_scoreboard dmi_scb;
    int m_rand_index_dirty_state[$];
    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    bit security;
    bit [15:0]errinfo;
    bit [19:0] errentry;
    bit [5:0] errway;
    bit [5:0] errword;
    bit [19:0] erraddr;
    dmi_env_config m_env_cfg;

<% if (obj.DmiInfo[obj.Id].useCmc) { %>
    constraint c_nSets  { m_nSets >= 0; m_nSets < <%=obj.DmiInfo[obj.Id].ccpParams.nSets%>;}
    constraint c_nWays  { m_nWays >= 0; m_nWays < <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>;}  
<% } %>

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      getCsrProbeIf();
      if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                               .inst_name( "*" ),
                                               .field_name( "dmi_scb" ),
                                               .value( dmi_scb ))) begin
           `uvm_error("dmi_csr_time_out_error_seq", "dmi_scb model not found")
      end
      if (!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                               .inst_name( get_full_name() ),
                                               .field_name( "dmi_env_config" ),
                                               .value( m_env_cfg ))) begin
           `uvm_error("dmi_csr_time_out_error_seq", "dmi_env_config handle not found")
      end
      #500us;

      write_data = 1;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.TimeoutErrDetEn, write_data);
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.TimeoutErrIntEn, write_data);
      timeout_threshold = $urandom_range(1,10);
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUTOCR.TimeOutThreshold, timeout_threshold);

      errinfo[1:0] = 2'b00; //Default Read error
      if (m_env_cfg.m_args.k_smc_timeout_error_test) begin
<% if (obj.DmiInfo[obj.Id].useCmc) { %>
        m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_DELAY_MIN = (timeout_threshold*4096*2);
        m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_DELAY_MAX = ((timeout_threshold*4096*2)+10);
        m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_BURST_PCT = 0;
        m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_DATA_CHANNEL_WAIT_FOR_VLD = 1;
        errinfo[1:0] = 2'b01; //Expecting writes
<% } %>
      end else if (m_env_cfg.m_args.k_wtt_timeout_error_test) begin
        m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MIN = (timeout_threshold*4096*2);
        m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MAX = ((timeout_threshold*4096*2)+10);
        m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_BURST_PCT = 0;
        errinfo[1:0] = 2'b01; //Expecting writes
        ev.trigger();
      end else if (m_env_cfg.m_args.k_rtt_timeout_error_test) begin
        m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MIN = (timeout_threshold*4096*2);
        m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MAX = ((timeout_threshold*4096*2)+10);
        m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_READ_DATA_CHANNEL_BURST_PCT = 0;
        errinfo[1:0] = 2'b00; //Expecting Reads
        ev.trigger();
      end

       uvm_config_db#(int)::set(null, "uvm_test_top", "timeout_threshold", timeout_threshold);

<% if (obj.DmiInfo[obj.Id].useCmc) { %>
      if (m_env_cfg.m_args.k_smc_timeout_error_test) begin
        if(dmi_scb.m_dmi_cache_q.size()>0) begin
          m_rand_index_dirty_state = dmi_scb.m_dmi_cache_q.find_index with (item.state == UD);
          `uvm_info("dmi_csr_time_out_error_seq",$sformatf("index %d cache model q size %d",m_rand_index_dirty_state[0],
                                                               dmi_scb.m_dmi_cache_q.size()), UVM_NONE)
          m_nSets = dmi_scb.m_dmi_cache_q[m_rand_index_dirty_state[0]].Index; 
          m_nWays = dmi_scb.m_dmi_cache_q[m_rand_index_dirty_state[0]].way; 
          security = dmi_scb.m_dmi_cache_q[m_rand_index_dirty_state[0]].security; 
          expt_addr = (dmi_scb.m_dmi_cache_q[m_rand_index_dirty_state[0]].addr >> <%=obj.wCacheLineOffset%>) << <%=obj.wCacheLineOffset%>;
        end

        `uvm_info("dmi_csr_time_out_error_seq",$sformatf("configuring m_nSets :%x,  m_nWays :%x ",m_nSets,m_nWays), UVM_NONE)

        errinfo[2] = security;
        errinfo[15:3] = 13'b0; //reserved

        //Poll the MntOp Active Bit
        do begin
           data = 0;
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
        end while(field_rd_data != data);

        wr_data = m_nSets;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntSet, wr_data);
        wr_data = m_nWays;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWay, wr_data);

        // ************************************************************************************
        //  Initiate and complete a Flush by set-way operation (Proxy Cache Maintenance Control 
        //  Register and Proxy Cache Maintenance Activity Register).
        //  a. the "DMIUSMCMCR0.ArrayId" field is 0. This will flush the tag array
        // ************************************************************************************
        wr_data   = 'h5;
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status, wr_data, .parent(this));

        //Poll the MntOp Active Bit
        do begin
           data = 0;
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
        end while(field_rd_data != data);
      end
<% } %>
      
      fork 
        do begin
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
        end while (read_data == 0);
        begin
          repeat((timeout_threshold*4096*2)+100) @(posedge u_csr_probe_vif.clk);
          `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see DMIUUESR.ErrVld asserted"));
        end
      join_any
      disable fork;

      fork
      begin
          wait (u_csr_probe_vif.IRQ_UC === 1);
      end
      begin
        #200000ns;
        `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
      end
      join_any
      disable fork;

      if (m_env_cfg.m_args.k_wtt_timeout_error_test) begin
        errinfo[2] = dmi_scb.wtt_time_out_err_test_sec_q[0];
        errinfo[15:3] = 13'b0; //reserved
        expt_addr = dmi_scb.wtt_time_out_err_test_addr_q[0];
      end
      else if (m_env_cfg.m_args.k_rtt_timeout_error_test) begin
        if(dmi_scb.rtt_q[0].mrd_req_pkt == null) begin
          `uvm_error("dmi_csr_time_out_error_seq",$sformatf("RTT size(%0d)", dmi_scb.rtt_q.size))
        end
        errinfo[2] = dmi_scb.rtt_q[0].mrd_req_pkt.smi_ns;
        errinfo[7:3] = 5'b0; //reserved
        errinfo[15:8] = dmi_scb.rtt_q[0].axi_read_addr_pkt.arid;
        expt_addr = dmi_scb.rtt_q[0].mrd_req_pkt.smi_addr;
      end

      read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
      compareValues("DMIUUESR.ErrType","should be",read_data,9);
      read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
      if(read_data[15:6] != 0) begin
        compareValues("Ignoring AXID field, DMIUUESR.ErrInfo[5:0]","should be",read_data[5:0],errinfo[5:0]);
      end
      else begin
        compareValues("DMIUUESR.ErrInfo","should be",read_data,errinfo);
      end
      read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR0.ErrAddr, read_data);
      {errword,errway,errentry} = read_data;
      read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR1.ErrAddr, read_data);
      erraddr = read_data;
      actual_addr = {erraddr,errword,errway,errentry};
      if (actual_addr !== expt_addr) begin
        `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, expt_addr))
      end
      write_data = 0;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.TimeoutErrDetEn, write_data);
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.TimeoutErrIntEn, write_data);
      write_data = 1;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
      read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
      compareValues("DMIUUESR_ErrVld","Should be 0", read_data, 0);
    endtask

endclass : dmi_csr_time_out_error_seq

class dmi_csr_elr_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_elr_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    bit [47:0] actual_addr;
    bit [47:0] expt_addr;
    int        errcount_vld, errthd_vld;
    bit [19:0] errentry;
    bit [25:20] errway;
    bit [31:26] errword;
    int erraddr;;
    rand bit [5:0]  err_injected_cache_word;
    rand bit [5:0]  err_injected_cache_way;
    rand bit [19:0] err_injected_cache_entry;
    bit [31:0]  mask1;
    bit [31:0]  mask2;
    bit [31:0]  mask;
    smi_addr_t  m_addr; 
    int offset = <%=obj.wCacheLineOffset%>;
    dmi_scoreboard dmi_scb;
    int unsigned m_rand_index;
    int m_rand_index_dirty_state[$];
    bit security;
<% if(has_secded) { %>
    ccp_ctrl_pkt_t m_ccp_pkt;
    axi4_write_resp_pkt_t m_axi_bresp_pkt;
    axi4_read_data_pkt_t m_axi_rresp_pkt;
    ccp_ctrl_pkt_t ccp_ctrl_pkt;
<% } %>
    int wr_resp_err;
    int rd_resp_err;
<% if (obj.DmiInfo[obj.Id].useCmc) { %>
    constraint c_nWord  { err_injected_cache_word  < 15;}
    <% if (obj.DmiInfo[obj.Id].ccpParams.nSets>1){ %>
    constraint c_nSets  { err_injected_cache_entry  < <%=obj.DmiInfo[obj.Id].ccpParams.nSets%>;}
    <%}%>
    
    <% if (obj.DmiInfo[obj.Id].ccpParams.nWays>1){ %>
    constraint c_nWays  { err_injected_cache_way  < <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>;}  
    <%}%>
<% } %>

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
      if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                                .inst_name( "*" ),
                                                .field_name( "dmi_scb" ),
                                                .value( dmi_scb ))) begin
           `uvm_error("dmi_csr_elr_seq", "dmi_scb model not found")
      end
<% if(has_secded) { %>
        if((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test") || $test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test") || $test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin
          `uvm_info("RUN_MAIN",$sformatf("Entered in to CSR seq"), UVM_LOW)
          if($test$plusargs("corr_mem_err_en")) begin
            write_data = 1;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
            write_data = 0;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          end
          if($test$plusargs("uncorr_mem_err_en")) begin
            write_data = 1;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          end
          ev.trigger();
          if ($test$plusargs("wbuffer_error_test")) begin
            inject_error(.wbuffer_addr(wbuf_addr)); 
          end
          if ($test$plusargs("data_error_test")) begin
            if(dmi_scb.m_dmi_cache_q.size()==0) `uvm_error("dmi_csr_elr_seq", "no entry in cache to inject errors")
            if(dmi_scb.m_dmi_cache_q.size()>0) begin
              //m_rand_index = $urandom_range(0, dmi_scb.m_dmi_cache_q.size()-1);
              m_rand_index_dirty_state = dmi_scb.m_dmi_cache_q.find_index with (item.state == UD);
              err_injected_cache_entry = dmi_scb.m_dmi_cache_q[m_rand_index_dirty_state[0]].Index;
              err_injected_cache_way = dmi_scb.m_dmi_cache_q[m_rand_index_dirty_state[0]].way;
              security = dmi_scb.m_dmi_cache_q[m_rand_index_dirty_state[0]].security;
              m_addr   = dmi_scb.m_dmi_cache_q[m_rand_index_dirty_state[0]].addr; 
              err_injected_cache_word = 0;
              `uvm_info("RUN_MAIN",$sformatf("configuring Sets :0x%0x,  way :0x%0x,  Word :0x%0x, security = 0x%0x, addr = 0x%0x",err_injected_cache_entry,err_injected_cache_way,err_injected_cache_word,security,m_addr), UVM_NONE)
              
              //Setup MntOp Read
              write_data = {err_injected_cache_word,err_injected_cache_way,err_injected_cache_entry};
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));

              write_data = {9'h0,security,6'h1,12'h0,4'hc}; //ArrayId = 1 for Data array
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

              //Wait for MntOpActv
              do
              begin
                  data = 0;
                  m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
              end while(field_rd_data != data);

              //Read the Data
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.read(status,field_rd_data,.parent(this));

              if($test$plusargs("corr_mem_err_en")) begin
                //Inject the tag Error 
                mask = 1'b1 << $urandom_range(31, 0);
                write_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));
              end

              if ($test$plusargs("uncorr_mem_err_en")) begin
                mask1 = 1'b1 << $urandom_range(15, 0);
                mask2 = 1'b1 << $urandom_range(31, 16);
                mask = mask1 | mask2;
                write_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));
              end

              `uvm_info("RUN_MAIN", $psprintf("RD_DATA:%0h and WR_DATA:%0h and Mask:%0h", 
                           field_rd_data,write_data,mask),UVM_NONE);

              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.write(status,write_data,.parent(this));

              write_data = {9'h0,security,6'h1,12'h0,4'he};
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

              //Wait for MntOpActv
              do
              begin
                  data = 0;
                  m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
              end while(field_rd_data != data);

              <% if((obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset) > 32) {%>
              //Program the ML0 Entry for Addr
              write_data   = m_addr >> offset;
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));
              `uvm_info("dmi_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_NONE)

              //Program the ML1 Entry for Addr
              write_data   = m_addr >> offset;
              write_data   = write_data >> 'h20;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR1.MntAddr, write_data);
              `uvm_info("dmi_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_NONE)
              `uvm_info("dmi_csr_elr_seq",$sformatf("Found the Addr size to be greater than 32 Size:%0d",<%=obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset%>), UVM_NONE)
             <%}else{%>
              //Program the ML0 Entry for Addr
              write_data   = m_addr >> offset;
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));
              `uvm_info("dmi_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_NONE)
             <%}%>

              //Program the MntOp Register with Opcode-6 to flush the entry
              write_data = {9'h0,security,6'h0,12'h0,4'h6};
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

              //Wait for MntOpActv
              do
              begin
                  data = 0;
                  m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
              end while(field_rd_data != data);
            end
          end
          if ($test$plusargs("tag_error_test")) begin
            if(dmi_scb.m_dmi_cache_q.size()==0) `uvm_error("dmi_csr_elr_seq", "no entry in cache to inject errors")
            if(dmi_scb.m_dmi_cache_q.size()>0) begin
              m_rand_index = $urandom_range(0, dmi_scb.m_dmi_cache_q.size()-1);
              err_injected_cache_entry = dmi_scb.m_dmi_cache_q[m_rand_index].Index;
              err_injected_cache_way = dmi_scb.m_dmi_cache_q[m_rand_index].way;
              security = dmi_scb.m_dmi_cache_q[m_rand_index].security;
              m_addr   = dmi_scb.m_dmi_cache_q[m_rand_index].addr; 
              err_injected_cache_word = 0;
              `uvm_info("RUN_MAIN",$sformatf("configuring Sets :0x%0x,  way :0x%0x,  Word :0x%0x, security = 0x%0x, addr = 0x%0x",err_injected_cache_entry,err_injected_cache_way,err_injected_cache_word,security,m_addr), UVM_MEDIUM)
              
              //Setup MntOp Read
              write_data = {err_injected_cache_word,err_injected_cache_way,err_injected_cache_entry};
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));

              write_data = {9'h0,security,6'h0,12'h0,4'hc}; //ArrayId = 0 for Tag array
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

              //Wait for MntOpActv
              do
              begin
                  data = 0;
                  m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
              end while(field_rd_data != data);

              //Read the Data
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.read(status,field_rd_data,.parent(this));

              if($test$plusargs("corr_mem_err_en")) begin
                //Inject the tag Error 
                <% if (wTagArrayEntry > 32) { %>
                mask = 1'b1 << $urandom_range(31, 0);
                <% } else { %>
                mask = 1'b1 << $urandom_range(<%=(wTagArrayEntry-1)%>, 0);
                <% } %>
                write_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));
              end

              if ($test$plusargs("uncorr_mem_err_en")) begin
                <% if (wTagArrayEntry > 32) { %>
                mask1 = 1'b1 << $urandom_range(15, 0);
                mask2 = 1'b1 << $urandom_range(31, 16);
                <% } else { %>
                mask1 = 1'b1 << $urandom_range(<%=(Math.ceil(wTagArrayEntry/2)-1)%>, 0);
                mask2 = 1'b1 << $urandom_range(<%=(wTagArrayEntry-1)%>, <%=Math.ceil(wTagArrayEntry/2)%>);
                <% } %>
                mask = mask1 | mask2;
                write_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));
              end

              `uvm_info("RUN_MAIN", $psprintf("RD_DATA:%0h and WR_DATA:%0h and Mask:%0h", 
                           field_rd_data,write_data,mask),UVM_MEDIUM);

              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.write(status,write_data,.parent(this));

              write_data = {9'h0,security,6'h0,12'h0,4'he};
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

              //Wait for MntOpActv
              do
              begin
                  data = 0;
                  m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
              end while(field_rd_data != data);

              <% if((obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset) > 32) {%>
              //Program the ML0 Entry for Addr
              write_data   = m_addr >> offset;
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));
              `uvm_info("dmi_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)

              //Program the ML1 Entry for Addr
              write_data   = m_addr >> offset;
              write_data   = write_data >> 'h20;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR1.MntAddr, write_data);
              `uvm_info("dmi_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)
              `uvm_info("dmi_csr_elr_seq",$sformatf("Found the Addr size to be greater than 32 Size:%0d",<%=obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset%>), UVM_MEDIUM)
             <%}else{%>
              //Program the ML0 Entry for Addr
              write_data   = m_addr >> offset;
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));
              `uvm_info("dmi_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)
             <%}%>

              //Program the MntOp Register with Opcode-6 to flush the entry
              write_data = {9'h0,security,6'h0,12'h0,4'h6};
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

              //Wait for MntOpActv
              do
              begin
                  data = 0;
                  m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
              end while(field_rd_data != data);
            end
          end
          if ($test$plusargs("uncorr_mem_err_en")) begin
            poll_DMIUUESR_ErrVld(1, poll_data);
          end
          if($test$plusargs("corr_mem_err_en")) begin
            poll_DMIUCESR_ErrVld(1, poll_data);
          end
          if ($test$plusargs("uncorr_mem_err_en")) begin
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
            if ($test$plusargs("tag_error_test") || $test$plusargs("data_error_test")) begin
              compareValues("DMIUUESR.ErrType","should be",read_data,1);
            end else if ($test$plusargs("wbuffer_error_test")) begin
              compareValues("DMIUUESR.ErrType","should be",read_data,0);
            end
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
            if ($test$plusargs("tag_error_test")) begin
              compareValues("DMIUUESR.ErrInfo","should be",read_data,0);
            end
            if ($test$plusargs("data_error_test")) begin
              compareValues("DMIUUESR.ErrInfo","should be",read_data,1);
            end
            if ($test$plusargs("wbuffer_error_test")) begin
              compareValues("DMIUUESR.ErrInfo","should be",read_data,2);
            end
          end
          if($test$plusargs("corr_mem_err_en")) begin
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, read_data);
            if ($test$plusargs("tag_error_test") || $test$plusargs("data_error_test")) begin
              compareValues("DMIUCESR.ErrType","should be",read_data,1);
            end else if ($test$plusargs("wbuffer_error_test")) begin
              compareValues("DMIUCESR.ErrType","should be",read_data,0);
            end
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrInfo, read_data);
            if ($test$plusargs("tag_error_test")) begin
              compareValues("DMIUCESR.ErrInfo","should be",read_data,0);
            end
            if ($test$plusargs("data_error_test")) begin
              compareValues("DMIUCESR.ErrInfo","should be",read_data,1);
            end
            if ($test$plusargs("wbuffer_error_test")) begin
              compareValues("DMIUCESR.ErrInfo","should be",read_data,2);
            end
          end

          if($test$plusargs("corr_mem_err_en")) begin
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCELR0.ErrAddr, read_data);
            {errword,errway,errentry} = read_data;
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCELR1.ErrAddr, read_data);
            erraddr = read_data;
            if ($test$plusargs("data_error_test")) begin
              compareValues("DMIUCELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
              compareValues("DMIUCELR0.ErrWord", "should be", errword, err_injected_cache_word);
              compareValues("DMIUCELR0.ErrWay", "should be", errway, err_injected_cache_way);
              compareValues("DMIUCELR0.ErrEntry", "should be", errentry, err_injected_cache_entry);
            end
            if ($test$plusargs("tag_error_test")) begin
              compareValues("DMIUCELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
              compareValues("DMIUCELR0.ErrWord", "should be", errword, err_injected_cache_word);
              compareValues("DMIUCELR0.ErrWay", "should be", errway, err_injected_cache_way);
              compareValues("DMIUCELR0.ErrEntry", "should be", errentry, err_injected_cache_entry);
            end
            if ($test$plusargs("wbuffer_error_test")) begin
              compareValues("DMIUCELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
              compareValues("DMIUCELR0.ErrWord", "ErrWord must be zero", errword, 0); //Word MBZ
              compareValues("DMIUCELR0.ErrWay", "ErrWay must be zero", errway, 0); //Way MBZ
              compareValues("DMIUCELR0.ErrEntry", "should be", errentry, wbuf_addr);
            end
          end
          if($test$plusargs("uncorr_mem_err_en")) begin
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR0.ErrAddr, read_data);
            {errword,errway,errentry} = read_data;
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR1.ErrAddr, read_data);
            erraddr = read_data;
            if ($test$plusargs("data_error_test")) begin
              compareValues("DMIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
              compareValues("DMIUUELR0.ErrWord", "should be", errword, err_injected_cache_word);
              compareValues("DMIUUELR0.ErrWay", "should be", errway, err_injected_cache_way);
              compareValues("DMIUUELR0.ErrEntry", "should be", errentry, err_injected_cache_entry);
            end
            if ($test$plusargs("tag_error_test")) begin
              compareValues("DMIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
              compareValues("DMIUUELR0.ErrWord", "should be", errword, err_injected_cache_word);
              compareValues("DMIUUELR0.ErrWay", "should be", errway, err_injected_cache_way);
              compareValues("DMIUUELR0.ErrEntry", "should be", errentry, err_injected_cache_entry);
            end
            if ($test$plusargs("wbuffer_error_test")) begin
              compareValues("DMIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
              compareValues("DMIUUELR0.ErrWord", "ErrWord must be zero", errword, 0); //Word MBZ
              compareValues("DMIUUELR0.ErrWay", "ErrWay must be zero", errway, 0); //Way MBZ
              compareValues("DMIUUELR0.ErrEntry", "should be", errentry, wbuf_addr);
            end
          end
          if($test$plusargs("corr_mem_err_en")) begin
            write_data = 0;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
            write_data = 0;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          end
          if($test$plusargs("uncorr_mem_err_en")) begin
            write_data = 0;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          end
          if($test$plusargs("corr_mem_err_en")) begin
            write_data = 1;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
            compareValues("DMIUCESR_ErrVld","Should be 0", read_data, 0);
          end
          if ($test$plusargs("uncorr_mem_err_en")) begin
            write_data = 1;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
            compareValues("DMIUUESR_ErrVld","Should be 0", read_data, 0);
          end
        end else if((tag_parity && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_parity && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_parity && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          ev.trigger();
          if ($test$plusargs("wbuffer_error_test")) begin
            inject_error(.wbuffer_addr(wbuf_addr)); 
          end
          if ($test$plusargs("data_error_test")) begin
            if(dmi_scb.m_dmi_cache_q.size()==0) `uvm_error("dmi_csr_elr_seq", "no entry in cache to inject errors")
            if(dmi_scb.m_dmi_cache_q.size()>0) begin
              //m_rand_index = $urandom_range(0, dmi_scb.m_dmi_cache_q.size()-1);
              m_rand_index_dirty_state = dmi_scb.m_dmi_cache_q.find_index with (item.state == UD);
              err_injected_cache_entry = dmi_scb.m_dmi_cache_q[m_rand_index_dirty_state[0]].Index;
              err_injected_cache_way = dmi_scb.m_dmi_cache_q[m_rand_index_dirty_state[0]].way;
              security = dmi_scb.m_dmi_cache_q[m_rand_index_dirty_state[0]].security;
              m_addr   = dmi_scb.m_dmi_cache_q[m_rand_index_dirty_state[0]].addr; 
              err_injected_cache_word = 0;
              `uvm_info("RUN_MAIN",$sformatf("configuring Sets :0x%0x,  way :0x%0x,  Word :0x%0x, security = 0x%0x, addr = 0x%0x",err_injected_cache_entry,err_injected_cache_way,err_injected_cache_word,security,m_addr), UVM_NONE)
              
              //Setup MntOp Read
              write_data = {err_injected_cache_word,err_injected_cache_way,err_injected_cache_entry};
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));

              write_data = {9'h0,security,6'h1,12'h0,4'hc}; //ArrayId = 1 for Data array
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

              //Wait for MntOpActv
              do
              begin
                  data = 0;
                  m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
              end while(field_rd_data != data);

              //Read the Data
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.read(status,field_rd_data,.parent(this));

              //Inject the tag Error 
              mask = 1'b1 << $urandom_range(31, 0);
              write_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));

              `uvm_info("RUN_MAIN", $psprintf("RD_DATA:%0h and WR_DATA:%0h and Mask:%0h", 
                           field_rd_data,write_data,mask),UVM_NONE);

              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.write(status,write_data,.parent(this));

              write_data = {9'h0,security,6'h1,12'h0,4'he};
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

              //Wait for MntOpActv
              do
              begin
                  data = 0;
                  m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
              end while(field_rd_data != data);

              <% if((obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset) > 32) {%>
              //Program the ML0 Entry for Addr
              write_data   = m_addr >> offset;
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));
              `uvm_info("dmi_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_NONE)

              //Program the ML1 Entry for Addr
              write_data   = m_addr >> offset;
              write_data   = write_data >> 'h20;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR1.MntAddr, write_data);
              `uvm_info("dmi_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_NONE)
              `uvm_info("dmi_csr_elr_seq",$sformatf("Found the Addr size to be greater than 32 Size:%0d",<%=obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset%>), UVM_NONE)
             <%}else{%>
              //Program the ML0 Entry for Addr
              write_data   = m_addr >> offset;
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));
              `uvm_info("dmi_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_NONE)
             <%}%>

              //Program the MntOp Register with Opcode-6 to flush the entry
              write_data = {9'h0,security,6'h0,12'h0,4'h6};
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

              //Wait for MntOpActv
              do
              begin
                  data = 0;
                  m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
              end while(field_rd_data != data);
            end
          end
          if ($test$plusargs("tag_error_test")) begin
            if(dmi_scb.m_dmi_cache_q.size()==0) `uvm_error("dmi_csr_elr_seq", "no entry in cache to inject errors")
            if(dmi_scb.m_dmi_cache_q.size()>0) begin
              m_rand_index = $urandom_range(0, dmi_scb.m_dmi_cache_q.size()-1);
              err_injected_cache_entry = dmi_scb.m_dmi_cache_q[m_rand_index].Index;
              err_injected_cache_way = dmi_scb.m_dmi_cache_q[m_rand_index].way;
              security = dmi_scb.m_dmi_cache_q[m_rand_index].security;
              m_addr   = dmi_scb.m_dmi_cache_q[m_rand_index].addr; 
              err_injected_cache_word = 0;
              `uvm_info("RUN_MAIN",$sformatf("configuring Sets :0x%0x,  way :0x%0x,  Word :0x%0x, security = 0x%0x, addr = 0x%0x",err_injected_cache_entry,err_injected_cache_way,err_injected_cache_word,security,m_addr), UVM_MEDIUM)
              
              //Setup MntOp Read
              write_data = {err_injected_cache_word,err_injected_cache_way,err_injected_cache_entry};
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));

              write_data = {9'h0,security,6'h0,12'h0,4'hc}; //ArrayId = 0 for Tag array
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

              //Wait for MntOpActv
              do
              begin
                  data = 0;
                  m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
              end while(field_rd_data != data);

              //Read the Data
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.read(status,field_rd_data,.parent(this));

              //Inject the tag Error 
              <% if (wTagArrayEntry > 32) { %>
              mask = 1'b1 << $urandom_range(31, 0);
              <% } else { %>
              mask = 1'b1 << $urandom_range(<%=(wTagArrayEntry-1)%>, 0);
              <% } %>
              write_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));

              `uvm_info("RUN_MAIN", $psprintf("RD_DATA:%0h and WR_DATA:%0h and Mask:%0h", 
                           field_rd_data,write_data,mask),UVM_MEDIUM);

              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.write(status,write_data,.parent(this));

              write_data = {9'h0,security,6'h0,12'h0,4'he};
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

              //Wait for MntOpActv
              do
              begin
                  data = 0;
                  m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
              end while(field_rd_data != data);

              <% if((obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset) > 32) {%>
              //Program the ML0 Entry for Addr
              write_data   = m_addr >> offset;
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));
              `uvm_info("dmi_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)

              //Program the ML1 Entry for Addr
              write_data   = m_addr >> offset;
              write_data   = write_data >> 'h20;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR1.MntAddr, write_data);
              `uvm_info("dmi_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)
              `uvm_info("dmi_csr_elr_seq",$sformatf("Found the Addr size to be greater than 32 Size:%0d",<%=obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset%>), UVM_MEDIUM)
             <%}else{%>
              //Program the ML0 Entry for Addr
              write_data   = m_addr >> offset;
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,write_data,.parent(this));
              `uvm_info("dmi_csr_elr_seq",$sformatf("Sending Addr :%x from IO cache model",write_data), UVM_MEDIUM)
             <%}%>

              //Program the MntOp Register with Opcode-6 to flush the entry
              write_data = {9'h0,security,6'h0,12'h0,4'h6};
              m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,write_data,.parent(this));

              //Wait for MntOpActv
              do
              begin
                  data = 0;
                  m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
              end while(field_rd_data != data);
            end
          end
          poll_DMIUUESR_ErrVld(1, poll_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
          if ($test$plusargs("tag_error_test") || $test$plusargs("data_error_test")) begin
            compareValues("DMIUUESR.ErrType","should be",read_data,1);
          end else if ($test$plusargs("wbuffer_error_test")) begin
            compareValues("DMIUUESR.ErrType","should be",read_data,0);
          end
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
          if ($test$plusargs("tag_error_test")) begin
            compareValues("DMIUUESR.ErrInfo","should be",read_data,0);
          end
          if ($test$plusargs("data_error_test")) begin
            compareValues("DMIUUESR.ErrInfo","should be",read_data,1);
          end
          if ($test$plusargs("wbuffer_error_test")) begin
            compareValues("DMIUUESR.ErrInfo","should be",read_data,2);
          end
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR0.ErrAddr, read_data);
          {errword,errway,errentry} = read_data;
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR1.ErrAddr, read_data);
          erraddr = read_data;
          if ($test$plusargs("data_error_test")) begin
            compareValues("DMIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
            compareValues("DMIUUELR0.ErrWord", "should be", errword, err_injected_cache_word);
            compareValues("DMIUUELR0.ErrWay", "should be", errway, err_injected_cache_way);
            compareValues("DMIUUELR0.ErrEntry", "should be", errentry, err_injected_cache_entry);
          end
          if ($test$plusargs("tag_error_test")) begin
            compareValues("DMIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
            compareValues("DMIUUELR0.ErrWord", "should be", errword, err_injected_cache_word);
            compareValues("DMIUUELR0.ErrWay", "should be", errway, err_injected_cache_way);
            compareValues("DMIUUELR0.ErrEntry", "should be", errentry, err_injected_cache_entry);
          end
          if ($test$plusargs("wbuffer_error_test")) begin
            compareValues("DMIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
            compareValues("DMIUUELR0.ErrWord", "ErrWord must be zero", errword, 0); //Word MBZ
            compareValues("DMIUUELR0.ErrWay", "ErrWay must be zero", errway, 0); //Way MBZ
            compareValues("DMIUUELR0.ErrEntry", "should be", errentry, wbuf_addr);
          end
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld","Should be 0", read_data, 0);
        end else begin
           ev.trigger();
        end
<% } else if (wbuffer_fnerrdetectcorrect) { %>
        if(wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) begin
          `uvm_info("RUN_MAIN",$sformatf("Entered in to CSR seq"), UVM_LOW)
          if($test$plusargs("corr_mem_err_en")) begin
            write_data = 1;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
            write_data = 0;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          end
          if($test$plusargs("uncorr_mem_err_en")) begin
            write_data = 1;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          end
          ev.trigger();
          if ($test$plusargs("wbuffer_error_test")) begin
            inject_error(.wbuffer_addr(wbuf_addr)); 
          end
          if ($test$plusargs("uncorr_mem_err_en")) begin
            poll_DMIUUESR_ErrVld(1, poll_data);
          end
          if($test$plusargs("corr_mem_err_en")) begin
            poll_DMIUCESR_ErrVld(1, poll_data);
          end
          if ($test$plusargs("uncorr_mem_err_en")) begin
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
            compareValues("DMIUUESR.ErrType","should be",read_data,0);
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
            compareValues("DMIUUESR.ErrInfo","should be",read_data,2);
          end
          if($test$plusargs("corr_mem_err_en")) begin
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, read_data);
            compareValues("DMIUCESR.ErrType","should be",read_data,0);
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrInfo, read_data);
            compareValues("DMIUCESR.ErrInfo","should be",read_data,2);
          end

          if($test$plusargs("corr_mem_err_en")) begin
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCELR0.ErrAddr, read_data);
            {errword,errway,errentry} = read_data;
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCELR1.ErrAddr, read_data);
            erraddr = read_data;
            if ($test$plusargs("wbuffer_error_test")) begin
              compareValues("DMIUCELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
              compareValues("DMIUCELR0.ErrWord", "ErrWord must be zero", errword, 0); //Word MBZ
              compareValues("DMIUCELR0.ErrWay", "ErrWay must be zero", errway, 0); //Way MBZ
              compareValues("DMIUCELR0.ErrEntry", "should be", errentry, wbuf_addr);
            end
          end
          if($test$plusargs("uncorr_mem_err_en")) begin
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR0.ErrAddr, read_data);
            {errword,errway,errentry} = read_data;
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR1.ErrAddr, read_data);
            erraddr = read_data;
            if ($test$plusargs("wbuffer_error_test")) begin
              compareValues("DMIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
              compareValues("DMIUUELR0.ErrWord", "ErrWord must be zero", errword, 0); //Word MBZ
              compareValues("DMIUUELR0.ErrWay", "ErrWay must be zero", errway, 0); //Way MBZ
              compareValues("DMIUUELR0.ErrEntry", "should be", errentry, wbuf_addr);
            end
          end
          if($test$plusargs("corr_mem_err_en")) begin
            write_data = 0;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
            write_data = 0;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
          end
          if($test$plusargs("uncorr_mem_err_en")) begin
            write_data = 0;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          end
          if ($test$plusargs("uncorr_mem_err_en")) begin
            write_data = 1;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
            compareValues("DMIUUESR_ErrVld","Should be 0", read_data, 0);
          end
          if($test$plusargs("corr_mem_err_en")) begin
            write_data = 1;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
            compareValues("DMIUCESR_ErrVld","Should be 0", read_data, 0);
          end
        end else if(wbuffer_parity && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) begin
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          poll_DMIUUESR_ErrVld(1, poll_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
          compareValues("DMIUUESR.ErrType","should be",read_data,0);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, read_data);
          compareValues("DMIUUESR.ErrInfo","should be",read_data,2);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR0.ErrAddr, read_data);
          {errword,errway,errentry} = read_data;
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR1.ErrAddr, read_data);
          erraddr = read_data;
          compareValues("DMIUUELR1.ErrAddr", "ErrAddr must be zero", erraddr, 0); //Addr MBZ
          compareValues("DMIUUELR0.ErrWord", "ErrWord must be zero", errword, 0); //Word MBZ
          compareValues("DMIUUELR0.ErrWay", "ErrWay must be zero", errway, 0); //Way MBZ
          compareValues("DMIUUELR0.ErrEntry", "should be", errentry, wbuf_addr);
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld","Should be 0", read_data, 0);
        end else begin
          ev.trigger();
        end
<% } else { %>
          ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_elr_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Test Uncorrectable Error registers
//
//-----------------------------------------------------------------------
//#Check.DMI.ErrIntEnUnCorrErrs
class dmi_csr_dmiuecr_errCntOvf_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuecr_errCntOvf_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0] errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>

          assert(randomize(errthd));
          write_data = errthd;
          // Try Set the DMIUCECR_ErrThreshold. should not work as this is RAZ/WI
          //SG write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUECR.ErrThreshold, write_data);
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUECR.ErrThreshold, read_data);
          //SG compareValues("DMIUUECR_ErrThreshold","Should be 0", read_data, 0);

          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          // Try Set the DMIUUESR_ErrVld = 1. should not work as this field is W1C
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld","Should be 0", read_data, 0);

          //SG write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrOvf, write_data);
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrOvf, read_data);
          //SG compareValues("DMIUUESR_ErrVld","Should be 0", read_data, 0);

         // Set the DMIUUECR_ErrDetEn = 1
          //#Check.DMI.DetectEnSet
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data); 
         //SG // Set the DMIUUECR_ErrIntEn = 1
         //SG  write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUECR.ErrIntEn, write_data);
         // write  DMIUUESR_ErrVld = 1 , to reset it
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          ev.trigger();
          inject_error(errthd,.wbuffer_addr(wbuf_addr)); 
        ///////////////////////////////////////////////////////////

          //keep on  Reading the DMIUUESR_ErrVld bit = 1
          poll_DMIUUESR_ErrVld(1, poll_data);
          compareValues("DMIUUESR_ErrVld", "set", poll_data, 1);

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
          compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrCount, read_data);
          //SG compareValues("DMIUUESR_ErrCount","For uncorrectable", read_data, 0);

          //keep on  Reading the DMIUUESR_ErrcountOvf bit = 1 
          //SG poll_DMIUUESR_ErrOvf(1, poll_data);
          //SG compareValues("DMIUUESR_ErrOvf", "set", poll_data, 1);

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "set", read_data, 1);

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
          compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrCount, read_data);
          //SG compareValues("DMIUUESR_ErrCount","For uncorrectable", read_data, 0);

          // Read DMIUUESAR_ErrVld , it should be 1
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
          compareValues("DMIUESAR_ErrVld", "set", read_data, 1);

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
          compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);

          // Reset the DMIUUECR_ErrDetEn = 0
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data); 

          // Clear the DMIUUECR_ErrIntEn = 0
          //SG write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUECR.ErrIntEn, write_data);
          //#Test.DMI.ErrVldErrOvfResetW1CAfterSet
          // write  DMIUUESAR_ErrVld = 0 , to reset it
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, write_data);
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrOvf, read_data);
          //SG compareValues("DMIUUESR_ErrOvf", "still set", read_data, 1);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
          compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);

         // Read DMIUUESAR_ErrVld , it should also be 0, because it is alias of register
         // DMIUUESR_ErrVld
          //#Test.DMI.ErrVldErrOvfResetW1CAfterSet
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
          compareValues("DMIUESAR_ErrVld", "cleared previously", read_data, 0);
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrOvf, read_data);
          //SG compareValues("DMIUUESAR_ErrOvf", "still set", read_data, 1);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, read_data);
          compareValues("DMIUUESAR_ErrType","Valid Type", read_data, errtype);

          //#Test.DMI.ErrVldErrOvfResetW1CAfterSet
          // Read DMIUUESR_ErrOvf , it should be 1
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrOvf, read_data);
          //SG compareValues("DMIUUESR_ErrOvf", "still set", read_data, 1);

          // write  DMIUUESR_ErrOvf = 1 , to reset it
          //SG write_data = 1;
          //SG write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrOvf, write_data);

          //SG //#Test.DMI.ErrVldErrOvfResetW1CAfterSet
          //SG // Read DMIUUESR_ErrOvf , it should be 0
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrOvf, read_data);
          //SG compareValues("DMIUUESR_ErrOvf", "now clear", read_data, 0);
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrCount, read_data);
          //SG compareValues("DMIUUESR_ErrCount","cleared", read_data, 0);
          //SG // Read DMIUUESAR_ErrOvf , it should be 0
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrOvf, read_data);
          //SG compareValues("DMIUUESAR_ErrOvf", "now clear", read_data, 0);
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrCount, read_data);
          //SG compareValues("DMIUUESAR_ErrCount","cleared", read_data, 0);

          // write  DMIUUESAR_ErrVld = 1 , to set it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, write_data);

          //#Test.DMI.ESARWriteUpdatesESR
          // write  DMIUUESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);

          // Read DMIUUESAR_ErrOvf , it should be 0
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrOvf, read_data);
          //SG compareValues("DMIUUESAR_ErrOvf", "clear", read_data, 0);
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrCount, read_data);
          //SG compareValues("DMIUUESAR_ErrCount","cleared", read_data, 0);

<% } else { %>
          ev.trigger();
          // Read the DMIUUESR_ErrVld bit = 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUESR_ErrVld", "RAZ/WI", read_data, 0);
          // Read the DMIUUESR_ErrcountOvf bit = 0 
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrOvf, read_data);
          //SG compareValues("DMIUUESR_ErrOvf", "RAZ/WI", read_data, 0);
          // Read DMIUUESAR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
          compareValues("DMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, read_data);
          compareValues("DMIUUESAR_ErrType","RAZ/WI", read_data, 0);
          // Read DMIUUESR_ErrVld , it should be 0
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrOvf, read_data);
          //SG compareValues("DMIUUESR_ErrOvf", "RAZ/WI", read_data, 0);
          // Read DMIUUESAR_ErrVld , it should also be 0, because it is alias of register
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrOvf, read_data);
          //SG compareValues("DMIUUESAR_ErrOvf", "RAZ/WI", read_data, 0);
          // write  DMIUUESAR_ErrVld = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          // Read DMIUUESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUESR_ErrVld", "RAZ/WI", read_data, 0);
          // write  DMIUUESR_ErrOvf = 1
          //SG write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrOvf, write_data);
          // Read DMIUUESR_ErrOvf , it should be 0
          //SG read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrOvf, read_data);
          //SG compareValues("DMIUUESR_ErrOvf", "RAZ/WI", read_data, 0);

<% } %>
    endtask
endclass : dmi_csr_dmiuecr_errCntOvf_seq

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if insert wrong target id then it should be captured. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* Inject incorrect target id from command request. 
* 1. Program Error detection for concerto messages 
* 2. Poll until error information logged.
* 3. Compare error type with appropriate type mentioned in table.
* 4. Clear ErrVld bit with writing 1.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
class dmi_csr_dmiuuedr_TransErrDetEn_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuuedr_TransErrDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>

           //if ($test$plusargs("inject_cmd_trgt_id_err"))
           //  errtype = 4'h4;
           //else
           //  errtype = 4'h3;

           // Set the DMIUUECR_ErrDetEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.TransErrDetEn, write_data);
           ev.trigger();
          //inject_error(.wbuffer_addr(wbuf_addr)); 
           ////keep on  Reading the DMIUUESR_ErrVld bit = 1
           //poll_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld,1,poll_data);
           //  
           //read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           //compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);
           //// Read DMIUUESAR_ErrVld , it should be 1
           //read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           // Set the DMIUUECR_ErrDetEn = 0
           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.TransErrDetEn, write_data);
           // write  DMIUUESR_ErrVld = 1 , W1C
           //write_data = 1;
           //write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           //// Read the DMIUUESR_ErrVld should be cleared
           //read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           //compareValues("DMIUUESR_ErrVld", "now clear", read_data, 0);
           //// write  DMIUUESR_ErrVld = 1 , to make sure it only reset by 1, not set by 1
           //write_data = 1;
           //write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           //// Read the DMIUUESR_ErrVld should be still be 0
           //read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           //compareValues("DMIUUESR_ErrVld", "still clear", read_data, 0);
<% } else { %>
           ev.trigger();
           // Read the DMIUUESR_ErrVld should be clear
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DMIUUESR_*
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the DMIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "still clear", read_data, 0);
           // write  DMIUUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be cleared
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "clear", read_data, 0);
           // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DMIUUESR_*
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "clear", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_dmiuuedr_TransErrDetEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_dmiuuedr_MemErrDetEn_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuuedr_MemErrDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
        if( $test$plusargs("address_error_test_wbuff") || $test$plusargs("address_error_test_tag") || $test$plusargs("address_error_test_data") || (tag_secded && ($test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test")))) begin

           if ($test$plusargs("address_error_test_tag") || $test$plusargs("address_error_test_data") || ($test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test")) || ($test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))) begin
             errtype = 4'h1;
           end else if ($test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test")) begin
             errtype = 4'h0;
           end

           // Set the DMIUUECR_ErrDetEn = 1
           write_data = 1;
           `uvm_info("dmi_csr_dmiuuedr_MemErrDetEn_seq:NKR","Setting the MemErrDetEn in the DMIUUEDR register", UVM_DEBUG)
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data); 
           `uvm_info("dmi_csr_dmiuuedr_MemErrDetEn_seq:NKR",$sformatf("Setting the MemErrDetEn in the DMIUUEDR register Done"), UVM_DEBUG)
           ev.trigger();

           if($test$plusargs("address_error_test_wbuff")) begin
              `uvm_info("dmi_csr_dmiuuedr_MemErrDetEn_seq:NKR",$sformatf("Waiting for the inject_err event trigger"), UVM_DEBUG)
               inject_err.wait_ptrigger();
              `uvm_info("dmi_csr_dmiuuedr_MemErrDetEn_seq:NKR",$sformatf("inject_err event trigger received"), UVM_DEBUG)
           end
           inject_error(.wbuffer_addr(wbuf_addr));
           //keep on  Reading the DMIUUESR_ErrVld bit = 1
           `uvm_info("dmi_csr_dmiuuedr_MemErrDetEn_seq:NKR",$sformatf("Polling for ErrVld in DMIUUESR register"), UVM_DEBUG)
           poll_DMIUUESR_ErrVld(1, poll_data);
           `uvm_info("dmi_csr_dmiuuedr_MemErrDetEn_seq:NKR",$sformatf("Polling for ErrVld in DMIUUESR register Done"), UVM_DEBUG)
             
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);
           // Read DMIUUESAR_ErrVld , it should be 1
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data); 
           // write  DMIUUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "now clear", read_data, 0);
           // write  DMIUUESR_ErrVld = 1 , to make sure it only reset by 1, not set by 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "still clear", read_data, 0);
        end else begin
           ev.trigger();
           // Read the DMIUUESR_ErrVld should be clear
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DMIUUESR_*
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the DMIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "still clear", read_data, 0);
           // write  DMIUUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be cleared
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "clear", read_data, 0);
           // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DMIUUESR_*
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "clear", read_data, 0);
        end
<% } else if (wbuffer_fnerrdetectcorrect) { %>
        if ( (wbuffer_secded && ($test$plusargs("address_error_test_wbuff") ||$test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test")))) begin
           if ($test$plusargs("address_error_test_tag") || $test$plusargs("address_error_test_data") || ($test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test")) || ($test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))) begin
             errtype = 4'h1;
           end else if ($test$plusargs("address_error_test_wbuff") || $test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test")) begin
             errtype = 4'h0;
           end

           // Set the DMIUUECR_ErrDetEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data); 
           ev.trigger();
           if($test$plusargs("address_error_test_wbuff")) begin
              `uvm_info("dmi_csr_dmiuuedr_MemErrDetEn_seq:NKR",$sformatf("Waiting for the inject_err event trigger wbuffer_fnerrdetectcorrect"), UVM_DEBUG)
           inject_err.wait_ptrigger();
              `uvm_info("dmi_csr_dmiuuedr_MemErrDetEn_seq:NKR",$sformatf("Waiting for the inject_err event trigger wbuffer_fnerrdetectcorrect DONE"), UVM_DEBUG)
           end
           inject_error(.wbuffer_addr(wbuf_addr)); 
           //keep on  Reading the DMIUUESR_ErrVld bit = 1
           `uvm_info("dmi_csr_dmiuuedr_MemErrDetEn_seq:NKR",$sformatf("Polling for ErrVld in DMIUUESR register wbuffer_fnerrdetectcorrect"), UVM_DEBUG)
           poll_DMIUUESR_ErrVld(1, poll_data);
           `uvm_info("dmi_csr_dmiuuedr_MemErrDetEn_seq:NKR",$sformatf("Polling for ErrVld in DMIUUESR register wbuffer_fnerrdetectcorrect DONE"), UVM_DEBUG)
             
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);
           // Read DMIUUESAR_ErrVld , it should be 1
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data); 
           // write  DMIUUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "now clear", read_data, 0);
           // write  DMIUUESR_ErrVld = 1 , to make sure it only reset by 1, not set by 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "still clear", read_data, 0);
        end else begin
           ev.trigger();
           // Read the DMIUUESR_ErrVld should be clear
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DMIUUESR_*
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the DMIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "still clear", read_data, 0);
           // write  DMIUUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be cleared
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "clear", read_data, 0);
           // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DMIUUESR_*
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "clear", read_data, 0);
        end
<% } else { %>
           ev.trigger();
           // Read the DMIUUESR_ErrVld should be clear
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DMIUUESR_*
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the DMIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "still clear", read_data, 0);
           // write  DMIUUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be cleared
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "clear", read_data, 0);
           // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DMIUUESR_*
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "clear", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_dmiuuedr_MemErrDetEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_dmiuuedr_rdProtErrDetEn_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuuedr_rdProtErrDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>

           if ($test$plusargs("smi_dtw_err_en"))
             errtype = 4'h0;
           else
             errtype = 4'h3;

           // Set the DMIUUECR_ErrDetEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);  
           ev.trigger();
           //keep on  Reading the DMIUUESR_ErrVld bit = 1
           poll_DMIUUESR_ErrVld(1, poll_data);
             
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);
           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
           // write  DMIUUESR_ErrVld = 1 , to make sure it only reset by 1, not set by 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "still clear", read_data, 0);
<% } else { %>
           ev.trigger();
           // Read the DMIUUESR_ErrVld should be clear
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DMIUUESR_*
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the DMIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "still clear", read_data, 0);
           // write  DMIUUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be cleared
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "clear", read_data, 0);
           // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DMIUUESR_*
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "clear", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_dmiuuedr_rdProtErrDetEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_dmiuuedr_wrProtErrDetEn_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuuedr_wrProtErrDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>

           if ($test$plusargs("smi_dtw_err_en"))
             errtype = 4'h0;
           else
             errtype = 4'h2;

           // Set the DMIUUECR_ErrDetEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data); 
           ev.trigger();
           //keep on  Reading the DMIUUESR_ErrVld bit = 1
           poll_DMIUUESR_ErrVld(1, poll_data);
             
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);
           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data); 
           // write  DMIUUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "now clear", read_data, 0);
           // of register DMIUUESR_*
           // write  DMIUUESR_ErrVld = 1 , to make sure it only reset by 1, not set by 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "still clear", read_data, 0);
<% } else { %>
           ev.trigger();
           // Read the DMIUUESR_ErrVld should be clear
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DMIUUESR_*
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the DMIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "still clear", read_data, 0);
           // write  DMIUUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read the DMIUUESR_ErrVld should be cleared
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "clear", read_data, 0);
           // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DMIUUESR_*
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "clear", read_data, 0);
<% } %>

    endtask
endclass : dmi_csr_dmiuuedr_wrProtErrDetEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
//#Test.DMI.ErrInjWhileSoftwareWriteHappens
class dmi_csr_dmiuecr_sw_write_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuecr_sw_write_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        i;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       //getCsrProbeIf();
getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
          // Set the DMIUUECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          poll_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld,1,poll_data);
          // write  DMIUCESR_ErrVld = 1 , to reset it
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          write_data = 0;

          fork
              begin
                 for (i=0;i<100;i++) begin
                    write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, write_data);
                 end
              end
              begin
                for (i=0;i<50;i++) begin
                  inject_error(.wbuffer_addr(wbuf_addr)); 
                end
              end
          join

          // Set the DMIUUECR_ErrDetEn = 0
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
          // if vld is set, reset it
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          if(read_data) begin
             write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, write_data);
          end
<% } else { %>
           ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmiuecr_sw_write_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_dmiuuedr_ProtErrThd_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuuedr_ProtErrThd_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       //getCsrProbeIf();
getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
          // Set the DMIUUECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data); 
          // write  DMIUUESR_ErrVld = 1 , to reset it
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          //keep on  Reading the DMIUUESR_ErrVld bit = 1 
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          poll_DMIUUESR_ErrVld(1, poll_data);
          // Read DMIUUESR_ErrCount , it should be at errthd
//          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrCount, read_data);
//          if(read_data == 0)begin
//              `uvm_error("RUN_MAIN",$sformatf("ErrCount should not be 0"))
//          end
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
          // write : DMIUUESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          // Read DMIUUESAR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
          compareValues("DMIUUESAR_ErrVld", "now clear", read_data, 0);
          // Read DMIUUESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "now clear", read_data, 0);
//          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrCount, read_data);
//          compareValues("DMIUUESR_ErrCount", "now clear", read_data, 0);
          //////////////////////////////////////////////////////////
          // Repeat entire process
          //////////////////////////////////////////////////////////
          // Set the DMIUUECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data); 
          // write  DMIUUESR_ErrVld = 1 , to reset it
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          inject_error(.wbuffer_addr(wbuf_addr)); 
          //keep on  Reading the DMIUUESR_ErrVld bit = 1 
          poll_DMIUUESR_ErrVld(1, poll_data);
          // Read DMIUUESR_ErrCount , it should be at errthd
//          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrCount, read_data);
//          if(read_data == 0)begin
//              `uvm_error("RUN_MAIN",$sformatf("ErrCount should not be 0"))
//          end
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
          // write : DMIUUESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          // Read DMIUUESAR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
          compareValues("DMIUUESAR_ErrVld", "now clear", read_data, 0);
          // Read DMIUUESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "now clear", read_data, 0);
//          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrCount, read_data);
//          compareValues("DMIUUESR_ErrCount", "now clear", read_data, 0);
    
<% } else { %>
          ev.trigger();
          // Read DMIUUESR_ErrCount , it should be 0
          // write alias : DMIUUESAR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          //#Test.DMI.ESARWriteUpdatesESR
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "clear", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_dmiuuedr_ProtErrThd_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
//#Test.DMI.DetectEnNotSetErrorsInjected
class dmi_csr_dmiuecr_noDetEn_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuecr_noDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
        if((tag_secded && ($test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test")))) begin
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          // Don't Set the DMIUUECR_ErrDetEn = 1
          //Reading the DMIUUESR_ErrVld bit = 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "not set", read_data, 0);
          // Read DMIUUESR_ErrCount , it should be at 0
        end else begin
          ev.trigger();
          // Read the DMIUUESR_ErrVld should be cleared
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "not set", read_data, 0);
          // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
          // of register DMIUUESR_*
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
          compareValues("DMIUUESAR_ErrVld", "not set", read_data, 0);
        end
<% } else if (wbuffer_fnerrdetectcorrect) { %>
        if (wbuffer_secded && ($test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test"))) begin
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          // Don't Set the DMIUUECR_ErrDetEn = 1
          //Reading the DMIUUESR_ErrVld bit = 0
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "not set", read_data, 0);
          // Read DMIUUESR_ErrCount , it should be at 0
        end else begin
          ev.trigger();
          // Read the DMIUUESR_ErrVld should be cleared
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "not set", read_data, 0);
          // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
          // of register DMIUUESR_*
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
          compareValues("DMIUUESAR_ErrVld", "not set", read_data, 0);
        end
<% } else { %>
          ev.trigger();
          // Read the DMIUUESR_ErrVld should be cleared
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "not set", read_data, 0);
          // Read DMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
          // of register DMIUUESR_*
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
          compareValues("DMIUUESAR_ErrVld", "not set", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_dmiuecr_noDetEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_dmiueir_ProtErrInt_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiueir_ProtErrInt_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0] errtype;
    int rd_resp_err, wr_resp_err;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>

           if ($value$plusargs("prob_ace_rd_resp_error=%d",rd_resp_err)) begin
             if (rd_resp_err == 100)
               errtype = 4'h3;
           end
           if ($value$plusargs("prob_ace_wr_resp_error=%d",wr_resp_err)) begin
             if (wr_resp_err == 100)
               errtype = 4'h2;
           end
           // Set the DMIUUEIR_ProtErrIntEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
           // Set the DMIUUEIR_ProtErrIntEn = 1
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.ProtErrIntEn, write_data);
           ev.trigger();
           inject_error(.wbuffer_addr(wbuf_addr)); 
           // wait for IRQ_UC interrupt 
           //if(u_csr_probe_vif.IRQ_UC == 0)begin // wait only if not already set
           fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 1);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
           end
           join_any
           disable fork;
           //end
           // Read the DMIUUESR_ErrVld
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "set after inte", read_data, 1);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);
           // Set the DMIUUECR_ErrDetEn = 0, to disable the error detection
           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.ProtErrIntEn, write_data);
           // write DMIUUESR_ErrVld = 1 to clear it
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read DMIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "reset", read_data, 0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
<% } else { %>
           ev.trigger();
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
           end
          // Read DMIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, 4'h0);
          // Read DMIUUESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, read_data);
           compareValues("DMIUUESAR_ErrType","Valid Type", read_data, 4'h0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
          end
<% } %>
    endtask
endclass : dmi_csr_dmiueir_ProtErrInt_seq

class dmi_csr_error_detect_off_seq extends dmi_ral_csr_base_seq;

  typedef enum int { 
    PROT_ERR,
    MEM_ERR,
    TIMEOUT_ERR,
    ATOMIC_ERR} err_type_e;
  string LABEL= "dmi_csr_error_detect_off_seq";
  dmi_env_config m_env_cfg;
  err_type_e inject_type;
  string arg_type;
  uvm_reg_data_t write_data,read_data;

  `uvm_object_utils(dmi_csr_error_detect_off_seq)

  function new(string name= "dmi_csr_error_detect_off_seq");
    super.new(name);
  endfunction

  task body();
    if($value$plusargs("inject_csr_error_type=%0s",arg_type))begin
      if(arg_type == "MEM_ERR") inject_type = MEM_ERR;
      else if(arg_type == "PROT_ERR") inject_type = PROT_ERR;
      else if(arg_type == "TIMEOUT_ERR") inject_type = TIMEOUT_ERR;
      else if(arg_type == "ATOMIC_ERR") inject_type = TIMEOUT_ERR;
      else `uvm_error(LABEL,$sformatf("Invalid %0s inject_csr_error_type",arg_type))
    end
    getCsrProbeIf();
    getInjectErrEvent();
    if (!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                             .inst_name( get_full_name() ),
                                             .field_name( "dmi_env_config" ),
                                             .value( m_env_cfg ))) begin
     `uvm_error(LABEL, "dmi_env_config handle not found")
    end
    `uvm_info(LABEL,$sformatf("Exercising inject_error:%0s",inject_type.name),UVM_LOW)
    if(inject_type == PROT_ERR) begin
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, 1);
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.TransErrDetEn, 1);
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.ProtErrIntEn, '0);
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.TransErrIntEn, '0);
    end
    <%if(has_secded){%>
    if(inject_type == MEM_ERR) begin
      program_xUEDR_xUEIR(1,0);
    end
    <%}%>
    if(inject_type == ATOMIC_ERR) begin
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.SoftwareProgConfigErrDetEn, 1);
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.SoftwareProgConfigErrIntEn, '0);
    end
    if(inject_type == TIMEOUT_ERR) begin
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.TimeoutErrDetEn, 1);
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.TimeoutErrIntEn, '0);
      //Delay for WTT timeout
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUTOCR.TimeOutThreshold, 1);
      m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MIN = (4096*2);
      m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MAX = ((4096*2)+10);
      m_env_cfg.m_axi_slave_agent_cfg.m_vif.ACE_SLAVE_WRITE_RESP_CHANNEL_BURST_PCT = 0;
    end
    ev.trigger();

    <%if(has_secded){%>
    fork
      begin
        if(inject_type == PROT_ERR || inject_type == MEM_ERR) begin
          //For ProtErrDetEn and MemErrDetEn
          inject_error(.wbuffer_addr(wbuf_addr)); 
        end
      end
    join_any
    <%}%>

    fork 
      begin
        `uvm_info(LABEL,$sformatf("Waiting for an uncorrectable interrupt. It should not trigger"), UVM_LOW)
        @(u_csr_probe_vif.IRQ_UC);
        `uvm_error(LABEL, $sformatf("Unexpected uncorrectable interrupt when all enables are off!"))
      end
      begin
        @(posedge u_csr_probe_vif.DMIUUESR_ErrVld);
        #50ns;
        `uvm_info(LABEL,$sformatf("Done waiting. Received ErrVld, uncorrectable interrupt should have propagated by now"), UVM_LOW)
        //Clear errvld
        write_data = 1;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
        compareValues("DMIUUESR_ErrVld", "not set", read_data, 0);
      end
    join_any
  endtask


endclass: dmi_csr_error_detect_off_seq
//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Correctable Error with Protocol Error
//
//-----------------------------------------------------------------------
class dmi_csr_CorrErr_with_ProtErr_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_CorrErr_with_ProtErr_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0] errtype, errtype_corr;
    int rd_resp_err, wr_resp_err;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();
       getInjectErrEvent();
       <% if(has_secded) { %>
           if((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin

               if(($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test")) || ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) begin
                 errtype_corr = 4'b1;
               end else if($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")) begin
                 errtype_corr = 4'b0;
               end

               write_data = 0;
               write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, write_data);
               // Set the DMIUCECR_ErrDetEn = 1
               write_data = 1;
               write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
               // Set the DMIUCECR_ErrIntEn = 1
               write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
           end

           if ($value$plusargs("prob_ace_rd_resp_error=%d",rd_resp_err)) begin
             if (rd_resp_err == 100)
               errtype = 4'h3;
           end
           if ($value$plusargs("prob_ace_wr_resp_error=%d",wr_resp_err)) begin
             if (wr_resp_err == 100)
               errtype = 4'h2;
           end

           // Set the DMIUUEIR_ProtErrIntEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
           // Set the DMIUUEIR_ProtErrIntEn = 1
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.ProtErrIntEn, write_data);
           ev.trigger();
           inject_error(.wbuffer_addr(wbuf_addr)); 
           // wait for IRQ_UC  and IRQ_C interrupt 
           fork
           begin
               wait ((u_csr_probe_vif.IRQ_UC === 1) && (u_csr_probe_vif.IRQ_C === 1));
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
           end
           join_any
           disable fork;
           //end
           fork 
           begin // CorrErrInt
               if((tag_secded && ($test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test")))) begin
                   // Read the DMIUCESR_ErrVld
                   read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
                   compareValues("DMIUCESR_ErrVld", "set after inte", read_data, 1);
                   read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, read_data);
                   compareValues("DMIUCESR_ErrType","Valid Type", read_data, errtype_corr);
                   write_data = 1;
                   write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, write_data);
                   // Read DMIUCESR_ErrVld , it should be 0
                   read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
                   compareValues("DMIUCESR_ErrVld", "reset", read_data, 0);
                   // Monitor IRQ_C pin , it should be 0 now
                   if(u_csr_probe_vif.IRQ_C === 0)begin
                     `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asserted"), UVM_LOW)
                   end else begin
                     `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still aseerted"));
                   end
                   write_data = 0;
                   write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, write_data);
                   // Set the DMIUCECR_ErrIntEn = 0, to disable the error Interrupt
                   write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, write_data);
               end
           end // CorrErrInt
           begin // ProtErrInt
               // Read the DMIUUESR_ErrVld
               read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
               compareValues("DMIUUESR_ErrVld", "set after inte", read_data, 1);
               read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
               compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);
         
               // Set the DMIUUECR_ErrDetEn = 0, to disable the error detection
               write_data = 0;
               write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
               write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.ProtErrIntEn, write_data);
               // write DMIUUESR_ErrVld = 1 to clear it
               write_data = 1;
               write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
               // Read DMIUUESR_ErrVld , it should be 0
               read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
               compareValues("DMIUUESR_ErrVld", "reset", read_data, 0);
               // Monitor IRQ_C pin , it should be 0 now
               if(u_csr_probe_vif.IRQ_UC === 0)begin
                 `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
               end else begin
                 `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
               end
           end // ProtErrInt
           join
<% } else { %>
           ev.trigger();
          // Read DMIUUESR,DMIUCESR ErrType and ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, 4'h0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, read_data);
           compareValues("DMIUCESR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, read_data);
           compareValues("DMIUCESR_ErrType", "Valid Type", read_data, 0);
          // Read DMIUUESAR, DMIUCESAR ErrVld and ErrType, it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, read_data);
           compareValues("DMIUUESAR_ErrType","Valid Type", read_data, 4'h0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrVld, read_data);
           compareValues("DMIUCESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESAR.ErrType, read_data);
           compareValues("DMIUCESAR_ErrType", "Valid Type", read_data, 0);
          // Monitor IRQ_C pin and IRQ_UC , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
          end
          if(u_csr_probe_vif.IRQ_C === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asserted"), UVM_LOW)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still asserted"));
          end
<% } %>
    endtask
endclass : dmi_csr_CorrErr_with_ProtErr_seq

//-------------------------------------------------------------------------------------------
//  Task    : 
//  Purpose : Uncorrectable Interrupt Enable for ProtErr using the DMIUUESAR Alias Register
//
//-------------------------------------------------------------------------------------------
class dmi_csr_dmiuesar_ProtErrInt_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuesar_ProtErrInt_seq)

    uvm_reg_data_t poll_data, read_data, write_data;
    bit [3:0] errtype;
    int rd_resp_err, wr_resp_err;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();
       getInjectErrEvent();
       <% if(has_secded) { %>

           if ($value$plusargs("prob_ace_rd_resp_error=%d",rd_resp_err)) begin
             if (rd_resp_err == 100)
               errtype = 4'h3;
           end
           if ($value$plusargs("prob_ace_wr_resp_error=%d",wr_resp_err)) begin
             if (wr_resp_err == 100)
               errtype = 4'h2;
           end
           // Set the DMIUUEIR_ProtErrIntEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
           // Set the DMIUUEIR_ProtErrIntEn = 1
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.ProtErrIntEn, write_data);
           ev.trigger();
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, write_data);
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, errtype);
           //inject_error(.wbuffer_addr(wbuf_addr)); 
           // wait for IRQ_UC interrupt 
           fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 1);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
           end
           join_any
           disable fork;
           //end
           // Read the DMIUUESAR_ErrVld
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "set after inte", read_data, 1);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "set after inte", read_data, 1);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, read_data);
           compareValues("DMIUUESAR_ErrType","Valid Type", read_data, errtype);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);

           // Set the DMIUUECR_ErrDetEn = 0, to disable the error detection
           write_data = 0;
           //write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
           //write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.ProtErrIntEn, write_data);
           // write DMIUUESAR_ErrVld = 0 to clear it
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, write_data);
           // Read DMIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "reset", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "reset", read_data, 0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
       <% } else { %>
           ev.trigger();
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
           end

          // Read DMIUUESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, read_data);
           compareValues("DMIUUESAR_ErrType","Valid Type", read_data, 4'h0);
          
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
          end
<% } %>
    endtask
endclass : dmi_csr_dmiuesar_ProtErrInt_seq
//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_dmiuecr_noIntEn_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuecr_noIntEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
          // Set the DMIUUECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.ProtErrIntEn, write_data);
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
          // Dont Set the DMIUUECR_ErrIntEn = 1
          // wait for IRQ_UC interrupt for a while. should not trigger. Then join
          //#Cov.DMI.ErrIntDisEnUnCorrErrs
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It should not trigger"), UVM_LOW)
             @(u_csr_probe_vif.IRQ_UC);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #100000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_LOW)
            end
          join_any
          disable fork;
          //Reading the DMIUUESR_ErrVld bit = 1
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld", "set", read_data, 1);
          write_data = 0;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.ProtErrIntEn, write_data);
          // write DMIUUESR_ErrVld = 1 to clear it
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          //write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrCountOverflow, write_data);
<% } else { %>
          ev.trigger();
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It should not trigger"), UVM_LOW)
             @(u_csr_probe_vif.IRQ_UC);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #100000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_LOW)
            end
          join_any
          disable fork;
<% } %>
    endtask
endclass : dmi_csr_dmiuecr_noIntEn_seq


//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_dmiueir_MemErrInt_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiueir_MemErrInt_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0] errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
        if((tag_secded && ($test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test"))) || (data_secded && ($test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))) || (wbuffer_secded && ($test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test")))) begin
        repeat(5) begin
           if (($test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test")) || ($test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))) begin
                      errtype = 4'h1;
           end else if ($test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test")) begin
             errtype = 4'h0;
           end
           // Set the DMIUUEIR_ProtErrIntEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
           // Set the DMIUUEIR_ProtErrIntEn = 1
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
           ev.trigger();
           inject_error(.wbuffer_addr(wbuf_addr)); 
           // wait for IRQ_UC interrupt 
           //if(u_csr_probe_vif.IRQ_UC == 0)begin // wait only if not already set
           fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 1);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
           end
           join_any
           disable fork;
           //end
           // Read the DMIUUESR_ErrVld
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "set after inte", read_data, 1);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);
           // write DMIUUESR_ErrVld = 1 to clear it
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read DMIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "reset", read_data, 0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
            if(!$test$plusargs("back_to_back_error"))
             break;
          end
        // Set the DMIUUECR_ErrDetEn = 0, to disable the error detection
           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);

         end else begin
           ev.trigger();
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
           end
          // Read DMIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, 4'h0);
          // Read DMIUUESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, read_data);
           compareValues("DMIUUESAR_ErrType","Valid Type", read_data, 4'h0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
              `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
              `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
         end 
<% } else if (wbuffer_fnerrdetectcorrect) { %>
        if (wbuffer_secded && ($test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test"))) begin
           if (($test$plusargs("ccp_double_bit_direct_tag_error_test") || $test$plusargs("ccp_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_double_tag_direct_error_test")) || ($test$plusargs("ccp_double_bit_data_direct_error_test") || $test$plusargs("ccp_multi_blk_single_double_data_direct_error_test") || $test$plusargs("ccp_multi_blk_double_data_direct_error_test"))) begin
             errtype = 4'h1;
           end else if ($test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test")) begin
             errtype = 4'h0;
           end
           // Set the DMIUUEIR_ProtErrIntEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
           // Set the DMIUUEIR_ProtErrIntEn = 1
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
           ev.trigger();
           inject_error(.wbuffer_addr(wbuf_addr)); 
           // wait for IRQ_UC interrupt 
           //if(u_csr_probe_vif.IRQ_UC == 0)begin // wait only if not already set
           fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 1);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
           end
           join_any
           disable fork;
           //end
           // Read the DMIUUESR_ErrVld
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "set after inte", read_data, 1);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, errtype);
           // Set the DMIUUECR_ErrDetEn = 0, to disable the error detection
           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.MemErrDetEn, write_data);
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
           // write DMIUUESR_ErrVld = 1 to clear it
           write_data = 1;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
           // Read DMIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "reset", read_data, 0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
        end else begin
           ev.trigger();
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
           end
          // Read DMIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, 4'h0);
          // Read DMIUUESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, read_data);
           compareValues("DMIUUESAR_ErrType","Valid Type", read_data, 4'h0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
              `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
              `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
         end
<% } else { %>
           ev.trigger();
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
           end
          // Read DMIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, 4'h0);
          // Read DMIUUESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, read_data);
           compareValues("DMIUUESAR_ErrType","Valid Type", read_data, 4'h0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
              `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
              `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
<% } %>
    endtask
endclass : dmi_csr_dmiueir_MemErrInt_seq


//--------------------------------------------------------------------------------
//  Task    : dmi_csr_dmiuesar_MemErrInt_seq
//  Purpose : Software way of Generating an Uncorrectable Memory Error and IRQ_UC
//
//--------------------------------------------------------------------------------

class dmi_csr_dmiuesar_MemErrInt_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuesar_MemErrInt_seq)

    uvm_reg_data_t write_data, read_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
       <% if(has_secded) { %>
           getCsrProbeIf();
           getInjectErrEvent();

           write_data = 1;
           // Set the DMIUUEIR_MemErrIntEn = 1
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.MemErrIntEn, write_data);
           // Set the DMIUUESAR_ErrVld to 1
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, write_data);
           write_data = 0;
           // Set the DMIUUESAR_ErrType to 0
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, write_data);
           ev.trigger();
           // wait for IRQ_UC interrupt 
           //if(u_csr_probe_vif.IRQ_UC == 0)begin // wait only if not already set
           fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 1);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
           end
           join_any
           disable fork;
           // Set the DMIUUESAR_ErrVld to 0
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, write_data);
           fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 0);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC de-asserted"));
           end
           join_any
           disable fork;
       <% } else { %>
           ev.trigger();
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
           end
          // Read DMIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, 4'h0);
          // Read DMIUUESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, read_data);
           compareValues("DMIUUESAR_ErrType","Valid Type", read_data, 4'h0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
              `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
              `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
       <% } %>
    endtask
endclass : dmi_csr_dmiuesar_MemErrInt_seq

//--------------------------------------------------------------------------------
//  Task    : dmi_csr_dmiuesar_MemErrInt_seq
//  Purpose : Software way of Generating an Timeout Error and IRQ_UC
//
//--------------------------------------------------------------------------------

class dmi_csr_dmiuesar_TimeOutErrInt_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuesar_TimeOutErrInt_seq)

    uvm_reg_data_t write_data, read_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
       <% if(has_secded) { %>
           getCsrProbeIf();
           getInjectErrEvent();

           write_data = 9;
           // Set the DMIUUESAR_ErrType to 9
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, write_data);
           write_data = 1;
           // Set the DMIUUEIR_MemErrIntEn = 1
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.TimeoutErrIntEn, write_data);
           // Set the DMIUUESAR_ErrVld to 1
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, write_data);
           ev.trigger();
           // wait for IRQ_UC interrupt 
           //if(u_csr_probe_vif.IRQ_UC == 0)begin // wait only if not already set
           fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 1);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
           end
           join_any
           disable fork;
           // Set the DMIUUESAR_ErrVld to 0
           write_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, write_data);
           fork
           begin
               wait (u_csr_probe_vif.IRQ_UC === 0);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC de-asserted"));
           end
           join_any
           disable fork;
       <% } else { %>
           ev.trigger();
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
           end
          // Read DMIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
           compareValues("DMIUUESR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, read_data);
           compareValues("DMIUUESR_ErrType","Valid Type", read_data, 4'h0);
          // Read DMIUUESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrVld, read_data);
           compareValues("DMIUUESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESAR.ErrType, read_data);
           compareValues("DMIUUESAR_ErrType","Valid Type", read_data, 4'h0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC === 0)begin
              `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
              `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
       <% } %>
    endtask
endclass : dmi_csr_dmiuesar_TimeOutErrInt_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_dmiuelr_seq1 extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuelr_seq1)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          // Try Set the DMIUUESR_ErrVld = 1. should not work as this field is W1C
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, read_data);
          compareValues("DMIUUESR_ErrVld","Should be 0", read_data, 0);

          //write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrCountOverflow, write_data);
          //read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrCountOverflow, read_data);
          //compareValues("DMIUUESR_ErrVld","Should be 0", read_data, 0);

          // Set the DMIUUECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);  
<% } else { %>
           ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmiuelr_seq1

class dmi_csr_dmiuelr_seq2 extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_dmiuelr_seq2)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

getCsrProbeIf();
getInjectErrEvent();
<% if(has_secded) { %>
          ev.trigger();
          inject_error(.wbuffer_addr(wbuf_addr)); 
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          //keep on  Reading the DMIUUESR_ErrCount bit = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, write_data);
          poll_DMIUUESR_ErrVld(1, poll_data);
          //read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrCountOverflow, read_data);
          //compareValues("DMIUUESR_ErrCountOverflow", "not set yet", read_data, 0);

          //#Test.DMI.UnCorrErrErrLoggingSetAfterErrorCntCrossesErrThreshold
          //#Test.DMI.UnCorrErrErrLoggingRegisters
          //#Check.DMI.DetectEnSet
          //readCompareUELR(1);
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR0.ErrAddr, read_data);
          {errword,errway,errentry} = read_data;
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR1.ErrAddr, read_data);
          erraddr = read_data;

<% } else { %>
           ev.trigger();
<% } %>
    endtask
endclass : dmi_csr_dmiuelr_seq2

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Initialization of DMI config registers
//-----------------------------------------------------------------------
class dmi_csr_init_seq extends ral_csr_base_seq; 
   `uvm_object_utils(dmi_csr_init_seq)
   dmi_env_config m_cfg;
   bit ScPadEn                =0;
   bit ScPadAmigEn            =0;
   bit found                  =0;
   int count                  =0;
   bit uncorr_wrbuffer_err; 
   bit [5:0] cmc_policy;
   bit [31:0] agent_id;
   bit [31:0] agent_ids_assigned_q[$];
  <% if(obj.DmiInfo[obj.Id].useWayPartitioning==1) {%>
   int  way_partition_q[<%=obj.DmiInfo[obj.Id].nWayPartitioningRegisters%>];
  <% } %>
   bit [<%=obj.DmiInfo[obj.Id].wAddr%>-1:0] ScPadBaseAddr, ScPadBaseAddr_i;
   smi_addr_t k_sp_base_addr; 
   int NumScPadWays;
   int ScPadSize;
   uvm_status_e           status;
   dmi_scoreboard dmi_scb;
   <% if(obj.useCmc) { %>
   <%=obj.BlockId%>_ccp_env_pkg::ccp_scoreboard ccp_scb;
   <% } %>
   bit ccp_scb_en;
   bit dmi_scb_en = 1;
   int ISR_value; //Proxy Cache Initializtion Status Registe: 0: nothing ready 1:tag initialized, 2:data intialized  3: tag & dat initialized
   bit sp_ns      = 0;
   bit perfmon_test = 0;
   bit WrDataClnPropagateEn = 0;

   //Scratchpad Memory Interleaving
   bit AMIG_valid = 0;
   int AMIG_set;
   int AMIF_way, AMIF_function;
   `ifdef ADDR_MGR
     addr_trans_mgr       m_addr_mgr;
     bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] low_addr_dmi0;
     bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] upp_addr_dmi0;
     bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] low_addr_dmi1;
     bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] upp_addr_dmi1;
   `endif
   uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
   
   function new(string name="");
       string arg_value;
       super.new(name);
       if (clp.get_arg_value("+dmi_scb_en=", arg_value)) begin
         dmi_scb_en = arg_value.atoi();
       end
       if (clp.get_arg_value("+ccp_scb_en=", arg_value)) begin
         ccp_scb_en = arg_value.atoi();
      end
      if ($test$plusargs("uncorr_error_test") || $test$plusargs("uncorr_error_inj_test") || $test$plusargs("double_bit_tag_error_test") || $test$plusargs("double_bit_data_error_test")) begin
         ccp_scb_en = 0;
      end
   endfunction
  
   function initialize_csr_values();
     if(m_cfg.EN_DMI_VSEQ) begin
       cmc_policy = m_cfg.m_args.k_cmc_policy;
       WrDataClnPropagateEn = m_cfg.csr_wr_data_cln_prop_en;
     end
   endfunction

   task body(); 
      `uvm_info("body", "Entered...", UVM_MEDIUM)
      if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                              .inst_name( "*" ),
                                              .field_name( "dmi_scb" ),
                                              .value( dmi_scb ))) begin
         `uvm_error("init_seq", "dmi_scb model not found")
      end
      if(!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                       .inst_name( get_full_name() ),
                                       .field_name( "dmi_env_config" ),
                                       .value( m_cfg ))) begin
      `uvm_error("init_seq", "dmi_env_config handle not found")
     end

   <% if(obj.useCmc) { %>
      if (!uvm_config_db#(ccp_scoreboard)::get(.cntxt( null ),
                                              .inst_name( "*" ),
                                              .field_name( "ccp_scb" ),
                                              .value( ccp_scb ))) begin
         `uvm_error("init_seq", "ccp_scb component not found")
      end
   <% } %>
     
     initialize_csr_values();

     <% if(obj.useCmc){%>
      m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCISR.read(status,field_rd_data,.parent(this));
      
      wr_data = 'h0;
      m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,wr_data, .parent(this));
      do begin
          data = 0;
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
      end while(field_rd_data != data);
      wr_data = 'h10000;
      m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,wr_data, .parent(this));
    
      do begin
          data = 0;
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
      end while(field_rd_data != data);

      // Setting LookUpEn and AllocEn high
      `uvm_info("dmi_base_test",$sformatf("LookupEn:%0b, AllocEn:%0b ClnWrAllocDisable:%0b DtyWrAllocDisable:%0b",
                                          cmc_policy[0], cmc_policy[1],cmc_policy[2],cmc_policy[3]), UVM_NONE)
      `uvm_info("dmi_base_test",$sformatf("RdAllocDisable:%0b WrAllocDisable:%0b WrDataClnPropagateEn:%0b",
                                          cmc_policy[4],cmc_policy[5], WrDataClnPropagateEn), UVM_NONE)
      wr_data = cmc_policy[0] ;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCTCR.LookupEn, wr_data);
      wr_data = cmc_policy[1] ;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCTCR.AllocEn, wr_data);
      wr_data = cmc_policy[2] ;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCAPR.ClnWrAllocDisable, wr_data);
      wr_data = cmc_policy[3] ;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCAPR.DtyWrAllocDisable, wr_data);
      wr_data = cmc_policy[4] ;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCAPR.RdAllocDisable, wr_data);
      wr_data = cmc_policy[5] ;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCAPR.WrAllocDisable, wr_data);

      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, 10);
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, 1'b1);
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, 1'b1);

      if (dmi_scb_en) begin
        if(!uncorr_wrbuffer_err) begin
          dmi_scb.cov.cmc_policy            = cmc_policy;
        end
      end
      wr_data = 1;
     <%if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
      `uvm_info("dmi_base_test",$sformatf("ScpadBaseAddr 0%0h, NumScPadWays 0%0h sp_size:%0x sp_ns:%0b ",
                                          ScPadBaseAddr, NumScPadWays,ScPadSize,sp_ns), UVM_NONE)
     <% if((obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset) > 32) {%>
      // Scratchpad registers configuration
      wr_data = ScPadBaseAddr[31:0];
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCSPBR0.ScPadBaseAddr, wr_data);

      wr_data = ScPadBaseAddr >> 32;
      //wr_data[<%=obj.DmiInfo[obj.Id].wAddr-32-1%>] = sp_ns;
      wr_data[<%=obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset-32%>] = sp_ns;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCSPBR1.ScPadBaseAddrHi, wr_data);
     <%}else{%>
      wr_data = ScPadBaseAddr;
      wr_data[<%=obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset%>] = sp_ns;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCSPBR0.ScPadBaseAddr, wr_data);
     <%}%>

      wr_data = NumScPadWays;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCSPCR0.NumScPadWays, wr_data);

      wr_data = ScPadSize - 1;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCSPCR1.ScPadSize, wr_data);
      if(NumScPadWays >= 0 && ScPadEn && AMIG_valid) begin
        `uvm_info("dmi_base_test",$sformatf("Scratchpad memory interleaving enabled | Set:%0d Way:%0d Function:%0d", AMIG_set, AMIF_way, AMIF_function), UVM_NONE)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIAMIGR.AMIGS, AMIG_set);
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIAMIGR.Valid, AMIG_valid);
        case(AMIF_way)
           2:  write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIMIFSR.MIG2AIFId , AMIF_function);
           4:  write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIMIFSR.MIG4AIFId , AMIF_function);
           8:  write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIMIFSR.MIG8AIFId , AMIF_function);
          16:  write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIMIFSR.MIG16AIFId, AMIF_function);
          default : `uvm_error("dmi_base_test", $sformatf("Failed to randomize a legal interleave function group. Way:%0d Func:%0d",AMIF_way,AMIF_function))
        endcase
      end
      else `uvm_info("dmi_base_test", $sformatf("Scratchpad memory interleaving disabled | Valid:%0d Set:%0d Way:%0d Function:%0d",AMIG_valid, AMIG_set, AMIF_way,AMIF_function),UVM_NONE)

      wr_data = (NumScPadWays<0) ? 0 : ScPadEn;
      `uvm_info("dmi_base_test",$sformatf("wr_data 0%0h ScPadEn %0h", wr_data, ScPadEn), UVM_NONE)
      if (dmi_scb_en) begin
        dmi_scb.cov.collect_sp_pgm(AMIG_valid, AMIF_function, AMIG_set, AMIF_way);
        if(!(NumScPadWays<0))begin
          if(!uncorr_wrbuffer_err) begin
             if (ccp_scb_en) begin
                ccp_scb.set_sp_variables(ScPadEn, sp_ns, k_sp_base_addr, (NumScPadWays+1));
             end
          end
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCSPCR0.ScPadEn, wr_data);
        end
      end
    <%}%>
      uvm_report_info("dmi_csr_init_seq",$sformatf("sp_base 0%0h",ScPadBaseAddr),UVM_NONE);
      
      //Setting DMI CERR Error threshold to high value so that it wont cross
      //with few cerr expected errors
      <% if(obj.useResiliency) { %>
      if ($test$plusargs("inject_smi_uncorr_error")) begin
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCRTR.ResThreshold,'d255);
      end 
      <% } %>


    <% if(obj.DmiInfo[obj.Id].useWayPartitioning==1) {%>
      if ($test$plusargs("no_way_partitioning")) begin
        <%for( var i=0;i<obj.DmiInfo[obj.Id].nWayPartitioningRegisters;i++){%>
         wr_data = 'h0;
         m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCWPCR0<%=i%>.write(status, wr_data,.parent(this));
        <%}%>
      end else begin
       <%for( var i=0;i<obj.DmiInfo[obj.Id].nAius;i++){%>
        agent_ids_assigned_q.push_back(<%=obj.AiuInfo[i].nUnitId%>);
       <%}%>

        agent_ids_assigned_q.shuffle();

       <%for( var i=0;i<obj.DmiInfo[obj.Id].nWayPartitioningRegisters;i++){%>

        randcase
          10 : wr_data = 32'h0000_0000 |  agent_ids_assigned_q[<%=i%>];
          90 : wr_data = 32'h8000_0000 |  agent_ids_assigned_q[<%=i%>];
        endcase
     <%  if(i==0 && !obj.DmiInfo[obj.Id].useAtomic) { %>
        if ($test$plusargs("all_way_partitioning")) begin
          wr_data = 32'h8000_0000 |  agent_ids_assigned_q[<%=i%>];
        end
     <% } else { %>
          wr_data = 32'h0000_0000 |  agent_ids_assigned_q[<%=i%>];
     <%}%>
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCWPCR0<%=i%>.write(status, wr_data,.parent(this));
        if(!uncorr_wrbuffer_err && dmi_scb_en) begin
        //dmi_scb.way_partition_vld[<%=i%>]    = wr_data[31];
        //dmi_scb.way_partition_reg_id[<%=i%>] = wr_data[30:0];
          uvm_report_info("dmi_csr_init_seq",$sformatf("way-part reg no %0d vld %0b id %0h",<%=i%>,
                          dmi_scb.way_partition_vld[<%=i%>], dmi_scb.way_partition_reg_id[<%=i%>]),UVM_NONE);
        end
     <%}%>
     //   randcase
   //       10 : begin
                <%for( var i=0;i<obj.DmiInfo[obj.Id].nWayPartitioningRegisters;i++){%>
             <%
                if(DmiInfo[obj.Id].useAtomic){
                  var shared_ways_per_user = Math.trunc((obj.DmiInfo[obj.Id].ccpParams.nWays-1)/obj.DmiInfo[obj.Id].nWayPartitioningRegisters)
                }else{
                  var shared_ways_per_user = Math.trunc((obj.DmiInfo[obj.Id].ccpParams.nWays)/obj.DmiInfo[obj.Id].nWayPartitioningRegisters)
                }
                  var rand_way = Math.floor(Math.random()*(shared_ways_per_user))+1;
              %>
                  <% if (obj.DmiInfo[obj.Id].ccpParams.nWay < obj.DmiInfo[obj.Id].nWayPartitioningRegisters) { %>
                       `uvm_error("dmi_csr_init_seq",$sformatf("nWays = %0d is less than nWayPartitioningRegisters = %0d, Please check configuration", <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>, <%=obj.DmiInfo[obj.Id].nWayPartitioningRegisters%>))
                  <% } %>
    if ($test$plusargs("checkin_test")) begin
                 <% if (shared_ways_per_user <= 1) { %>
                 `uvm_warning("dmi_csr_init_seq",$sformatf("check shared_ways_per_user = %0d, nWays = %0d, nWayPartitioningRegisters = %0d",<%=shared_ways_per_user%>, <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>, <%=obj.DmiInfo[obj.Id].nWayPartitioningRegisters%>))
                 wr_data = {1{1'b1}} << 1*<%=i%>;
                 <% } else { %>
                 wr_data = {<%=shared_ways_per_user-1%>{1'b1}} << <%=shared_ways_per_user%>*<%=i%>;
                 <% } %>
    end
    else begin
                 wr_data = {<%=rand_way%>{1'b1}} << <%=shared_ways_per_user%>*<%=i%>;
    end
     <%  if(i==0 && !obj.DmiInfo[obj.Id].useAtomic) { %>
    if ($test$plusargs("all_way_partitioning")) begin
                 wr_data = {<%=nWays%>{1'b1}} ;
    end
     <%}%>
                 m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCWPCR1<%=i%>.write(status, wr_data,.parent(this));
              if(!uncorr_wrbuffer_err && dmi_scb_en) begin
               //dmi_scb.way_partition_reg_way[<%=i%>] = wr_data;
                 uvm_report_info("dmi_csr_init_seq",$sformatf("way-part reg no %0d way %0b",<%=i%>,dmi_scb.way_partition_reg_way[<%=i%>]),UVM_NONE);
               end
                <%}%>
    //           end

       //   90 : begin
       //         <%for( var i=0;i<obj.DmiInfo[obj.Id].nWayPartitioningRegisters;i++){%>
       //          wr_data = $urandom_range(0,(2**<%=obj.DmiInfo[obj.Id].ccpParams.nWays%>)-2);
       //          m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCWPCR1<%=i%>.write(status, wr_data,.parent(this));
       //          dmi_scb.way_partition_reg_way[<%=i%>] = wr_data;
       //          uvm_report_info("dmi_csr_init_seq",$sformatf("way-part reg no %0d way %0b",<%=i%>,dmi_scb.way_partition_reg_way[<%=i%>]),UVM_NONE);
       //         <%}%>
       //        end
      // endcase
      end
    <%}%>
    <% if(obj.DmiInfo[obj.Id].useAddrTranslation==1) {%>
      if (!$test$plusargs("no_way_partitioning")) begin
      end
    <%}%>

      do begin
          data = 0;
          m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.read(status,field_rd_data,.parent(this));
      end while(field_rd_data != data);
     <%}%>
     <% if(obj.DmiInfo[obj.Id].fnEnableQos && smiQosEn) { %>
     begin
       bit qos_en;
       bit [WSMIMSGQOS:0] qos_evict;
       qos_evict = $urandom;
       qos_en = $urandom;
       qos_evict[WSMIMSGQOS] = qos_en;
       if(qos_evict[WSMIMSGQOS]) begin
         uvm_config_db#(int)::set(null, "uvm_test_top", "eviction_qos", qos_evict);
         `uvm_info("dmi_csr_init_seq",$sformatf("Writing evict QoS value %0x to DMIUQOSCR with QoS useEviction %0x", qos_evict[WSMIMSGQOS-1:0],qos_evict[WSMIMSGQOS]),UVM_LOW)
         write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUQOSCR0.EvictionQoS, qos_evict[WSMIMSGQOS-1:0]);
         write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUQOSCR0.useEvictionQoS, qos_evict[WSMIMSGQOS]);
       end
     end
     if($test$plusargs("Qos_Event_Thrs")) begin
          int eventThreshold;
          $value$plusargs("Qos_Event_Thrs=%d",eventThreshold);
          `uvm_info("dmi_csr_init_seq",$sformatf("Writing QoS Event Threshold:%0d",eventThreshold),UVM_LOW)
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUQOSCR0.EventThreshold, eventThreshold);
     end 
     <%}%>
     <% if(obj.DmiInfo[obj.Id].fnEnableQos) {%>
     begin
      int ctrl_threshold = -1;
      $value$plusargs("QoS_ctrl_threshold=%d",ctrl_threshold);
      if(ctrl_threshold != -1) begin
        `uvm_info("dmi_csr_init_seq",$sformatf("Writing QoS Control Threshold:%0d",ctrl_threshold),UVM_LOW)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUTQOSCR0.QoSThVal, ctrl_threshold);
      end
     end
     <%}%>
     write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUWRDATACLN.EnClnDataWr, WrDataClnPropagateEn);
     `uvm_info("body", "Exiting...", UVM_MEDIUM)
   endtask
endclass : dmi_csr_init_seq

class dmi_SMC_init_done_check_csr_seq extends dmi_ral_csr_base_seq; 
   `uvm_object_utils(dmi_SMC_init_done_check_csr_seq)
    function new(string name="");
        super.new(name);
    endfunction

   task body(); 
   <% if(obj.useCmc){%>
      m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCISR.read(status,field_rd_data,.parent(this));
      compareValues("DMIUSMCISR", "", field_rd_data, 3);
      ev.trigger();
   <% } else {%>
      ev.trigger();
   <% } %>
   endtask
endclass

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//  Task    : dmi_cctrlr_csr_seq
//  Purpose : configures trace capture csr registers
//
//-----------------------------------------------------------------------

class dmi_cctrlr_csr_seq extends ral_csr_base_seq;
    `uvm_object_utils(dmi_cctrlr_csr_seq)

    bit [7:0]   port_capture_en;
    bit [3:0]   gain;
    bit [11:0]  inc;
    bit [7:0]   set_port_capture_en;
    bit [3:0]   set_gain;
    bit [11:0]  set_inc;
    bit [31:0]  cctrlr_value;

    uvm_reg_data_t write_value =32'hFFFF_FFFF;
    uvm_reg_data_t read_value;
    uvm_status_e status;
    uvm_reg my_register;
    uvm_reg_data_t mirrored_value;

   function new (string name="");
    super.new(name); 
   endfunction 

    task body();
       `uvm_info("body","Entered...",UVM_MEDIUM)
        port_capture_en         = cctrlr_value[7:0];
        gain                    = cctrlr_value[19:16];
        inc                     = cctrlr_value[31:20];
        `uvm_info("dmi_cctrlr_csr_seq",$sformatf("programming cctrlr register. cctlr_value:%0h port_capture_en 0b'%0b gain 0h'%0h incr d'%0d", cctrlr_value, port_capture_en, gain, inc), UVM_MEDIUM)

        wr_data = (port_capture_en >> 0) & 1;
        `uvm_info("dmi_cctrlr_csr_seq",$sformatf("writing %0b to DMICCTRLR.ndn0Tx",wr_data),UVM_DEBUG)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMICCTRLR.ndn0Tx, wr_data);
        set_port_capture_en[0] = wr_data ? (port_capture_en[0] | 'b1) : (port_capture_en[0] & 'b0);

        wr_data = (port_capture_en >> 1) & 1;
        `uvm_info("dmi_cctrlr_csr_seq",$sformatf("writing %0b to DMICCTRLR.ndn0Rx",wr_data),UVM_DEBUG)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMICCTRLR.ndn0Rx, wr_data);
        set_port_capture_en[1] = wr_data ? (port_capture_en[1] | 'b1) : (port_capture_en[1] & 'b0);

        wr_data = (port_capture_en >> 2) & 1;
        `uvm_info("dmi_cctrlr_csr_seq",$sformatf("writing %0b to DMICCTRLR.ndn1Tx",wr_data),UVM_DEBUG)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMICCTRLR.ndn1Tx, wr_data);
        set_port_capture_en[2] = wr_data ? (port_capture_en[2] | 'b1) : (port_capture_en[2] & 'b0);

        wr_data = (port_capture_en >> 3) & 1;
        `uvm_info("dmi_cctrlr_csr_seq",$sformatf("writing %0b to DMICCTRLR.ndn1Rx",wr_data),UVM_DEBUG)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMICCTRLR.ndn1Rx, wr_data);
        set_port_capture_en[3] = wr_data ? (port_capture_en[3] | 'b1) : (port_capture_en[3] & 'b0);

        wr_data = (port_capture_en >> 4) & 1;
        `uvm_info("dmi_cctrlr_csr_seq",$sformatf("writing %0b to DMICCTRLR.ndn2Tx",wr_data),UVM_DEBUG)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMICCTRLR.ndn2Tx, wr_data);
        set_port_capture_en[4] = wr_data ? (port_capture_en[4] | 'b1) : (port_capture_en[4] & 'b0);

        wr_data = (port_capture_en >> 5) & 1;
        `uvm_info("dmi_cctrlr_csr_seq",$sformatf("writing %0b to DMICCTRLR.ndn2Rx",wr_data),UVM_DEBUG)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMICCTRLR.ndn2Rx, wr_data);
        set_port_capture_en[5] = wr_data ? (port_capture_en[5] | 'b1) : (port_capture_en[5] & 'b0);

        wr_data = (port_capture_en >> 6) & 1;
        `uvm_info("dmi_cctrlr_csr_seq",$sformatf("writing %0b to DMICCTRLR.dn0Tx",wr_data),UVM_DEBUG)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMICCTRLR.dn0Tx, wr_data);
        set_port_capture_en[6] = wr_data ? (port_capture_en[6] | 'b1) : (port_capture_en[6] & 'b0);

        wr_data = (port_capture_en >> 7) & 1;
        `uvm_info("dmi_cctrlr_csr_seq",$sformatf("writing %0b to DMICCTRLR.dn0Rx",wr_data),UVM_DEBUG)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMICCTRLR.dn0Rx, wr_data);
        set_port_capture_en[7] = wr_data ? (port_capture_en[7] | 'b1) : (port_capture_en[7] & 'b0);

        wr_data = gain;
        `uvm_info("dmi_cctrlr_csr_seq",$sformatf("writing %0b to DMICCTRLR.gain",wr_data),UVM_DEBUG)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMICCTRLR.gain, wr_data);
        set_gain              = gain;
        
        wr_data = inc;
        `uvm_info("dmi_cctrlr_csr_seq",$sformatf("writing %0b to DMICCTRLR.inc",wr_data),UVM_DEBUG)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMICCTRLR.inc, wr_data);
        set_inc               = inc;
  
       `uvm_info("body","Exiting...",UVM_MEDIUM)

       if(this.model == null) begin
        `uvm_error(get_type_name(),"this.model in seq is null");
    end

    my_register = this.model.get_reg_by_name("DMIUUELR0");
    if(my_register == null) begin
        `uvm_error(get_type_name(),"The value of my_register is null because it couldnt find DMIUUELR0");
    end

    my_register.write(status, write_value);
    `uvm_info(get_type_name(),$sformatf("The value written in DMIUUELR0 is %0h", write_value),UVM_LOW)

    if(status != UVM_IS_OK) begin
       `uvm_error(get_type_name(), $sformatf("Error writing to reg DMIUUELR0: %s", status.name()));
        return;
    end

    my_register.read(status,read_value);
    `uvm_info(get_type_name(), $sformatf("And DMIUUELR0 in seq after reading is %0h",read_value),UVM_LOW)

    if(status != UVM_IS_OK) begin
       `uvm_error(get_type_name(), $sformatf("Error reading from reg DMIUUELR0: %s", status.name()));
        return;
    end

    mirrored_value = my_register.get_mirrored_value();
    `uvm_info(get_type_name(),$sformatf("The mirrored value in sequence is %0h", mirrored_value), UVM_LOW)
    endtask : body

endclass : dmi_cctrlr_csr_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//  Task    : dmi_csr_id_reset_seq
//  Purpose : test unit ids against json, rather than cpr
//
//-----------------------------------------------------------------------
class dmi_csr_id_reset_seq extends ral_csr_base_seq; 
   `uvm_object_utils(dmi_csr_id_reset_seq)

    uvm_reg_data_t read_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
       read_data = 'hDEADBEEF ;  //bogus sentinel

       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUIDR.RPN, read_data);
       compareValues("DMIUFUIDR_RPN", "should be <%=obj.DmiInfo[obj.Id].rpn%> (json)", read_data, <%=obj.DmiInfo[obj.Id].rpn%>);  //TODO FIXME meaningful values from json
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUIDR.NRRI, read_data);
       compareValues("DMIUIDR_NRRI", "should be <%=obj.DmiInfo[obj.Id].nrri%> (json)", read_data, <%=obj.DmiInfo[obj.Id].nrri%>);  //TODO FIXME meaningful values from json
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUIDR.NUnitId, read_data);
       compareValues("DMIUIDR_NUnitId", "should be <%=obj.DmiInfo[obj.Id].nUnitId%> (json)", read_data, <%=obj.DmiInfo[obj.Id].nUnitId%>);
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUIDR.Valid, read_data);
       compareValues("DMIUIDR_Valid", "should always be 1", read_data, 1);  
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUFUIDR.FUnitId, read_data);
       compareValues("DMIUIDR_FUnitId", "should be <%=obj.DmiInfo[obj.Id].FUnitId%> (json)", read_data, <%=obj.DmiInfo[obj.Id].FUnitId%>);

       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUEVIDR.EngVerId, read_data);
       compareValues("EVIDR_EngVerId", "should be <%=obj.DmiInfo[obj.Id].engVerId%> (json)", read_data, <%=obj.DmiInfo[obj.Id].engVerId%>);
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUINFOR.ImplVer, read_data);
       compareValues("INFOR_ImplVer", "should be <%=obj.DmiInfo[obj.Id].implVerId%> (json)", read_data, <%=obj.DmiInfo[obj.Id].implVerId%>);
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUINFOR.UT, read_data);
       compareValues("INFOR_UT", "should be ", read_data, 9);
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUINFOR.AE, read_data);
       compareValues("INFOR_AE", "should be <%=obj.DmiInfo[obj.Id].useAtomic%> (json)", read_data, <%=obj.DmiInfo[obj.Id].useAtomic%>);
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUINFOR.SMC, read_data);
       compareValues("INFOR_SMC", "should be <%=obj.DmiInfo[obj.Id].useCmc%> (json)", read_data, <%=obj.DmiInfo[obj.Id].useCmc%>);
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUINFOR.Valid, read_data);
       compareValues("INFOR_Valid", "should be ", read_data, 1);

       <% if (obj.DmiInfo[obj.Id].useCmc) { %>
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCIFR.NumSet, read_data);
       compareValues("DMIUSMCIFR_NumSet", "should be <%=obj.DmiInfo[obj.Id].ccpParams.nSets-1%> (json)", read_data, <%=obj.DmiInfo[obj.Id].ccpParams.nSets-1%>);
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCIFR.NumWay, read_data);
       compareValues("DMIUSMCIFR_NumWay", "should be <%=obj.DmiInfo[obj.Id].ccpParams.nWays-1%> (json)", read_data, <%=obj.DmiInfo[obj.Id].ccpParams.nWays-1%>);
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCIFR.SP, read_data);
       compareValues("DMIUSMCIFR_SP", "should be <%=obj.DmiInfo[obj.Id].ccpParams.useScratchpad%> (json)", read_data, <%=obj.DmiInfo[obj.Id].ccpParams.useScratchpad%>);
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCIFR.WP, read_data);
       compareValues("DMIUSMCIFR_WP", "should be <%=obj.DmiInfo[obj.Id].useWayPartitioning%> (json)", read_data, <%=obj.DmiInfo[obj.Id].useWayPartitioning%>);
       <% if(obj.DmiInfo[obj.Id].useWayPartitioning==1) {%>
       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCIFR.nWP, read_data);
       compareValues("DMIUSMCIFR_nWP", "should be <%=obj.DmiInfo[obj.Id].nWayPartitioningRegisters-1%> (json)", read_data, <%=obj.DmiInfo[obj.Id].nWayPartitioningRegisters-1%>);
       <% } %>
       <% } %>
    endtask
endclass : dmi_csr_id_reset_seq


<% if(obj.useCmc){%>
//-----------------------------------------------------------------------
//  Task    : single_bit_data_mem_err_inj_chk_seq
//  Purpose :
//
//-----------------------------------------------------------------------
class single_bit_data_mem_err_inj_chk_seq extends ral_csr_base_seq; 
   `uvm_object_utils(single_bit_data_mem_err_inj_chk_seq)

    uvm_reg_data_t field_rd_data;
    int test_hang_count;
    virtual <%=obj.BlockId%>_apb_if u_apb_vif;
    rand bit [2:0] errthd=1;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
       if(!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::get(null, get_full_name(), "apb_if",u_apb_vif))
         `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})

       //Set the Error Threshold & Enable the Interrupt
       assert(randomize(errthd));
       if (data_secded) begin
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, errthd);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, 1'b1);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, 1'b1);
       end else if (data_parity) begin
          //write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUECR.ErrIntEn, 1'b1);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, 1'b1);
       end else begin
          `uvm_fatal("single_bit_data_mem_err_inj_chk_seq", "Run this test for only configurations having PARITY/SECDED error protection")
       end

       data = 1;
       do begin
          if (data_secded) begin
             read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, field_rd_data);
             if(field_rd_data == 'h1)  
                `uvm_error("single_bit_data_mem_err_inj_chk_seq",$sformatf("DMIUUESR Error_valid should not be high :%x",field_rd_data));

             read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, field_rd_data);
             test_hang_count = test_hang_count + 1;
             if(test_hang_count == 50000) 
                 `uvm_fatal("single_bit_data_mem_err_inj_chk_seq", "Test hanged since Error Valid bit is never set")
          end else if (data_parity) begin
             read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, field_rd_data);
             if(field_rd_data == 'h1)  
                `uvm_error("single_bit_data_mem_err_inj_chk_seq",$sformatf("DMIUCESR Error_valid should not be high :%x",field_rd_data));

             read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, field_rd_data);
             test_hang_count = test_hang_count + 1;
             if(test_hang_count == 50000) 
                 `uvm_fatal("single_bit_data_mem_err_inj_chk_seq", "Test hanged since Error Valid bit is never set")
          end
       end while(field_rd_data != data);

       //Check the Error Interrupt Bit is set
       if (data_secded) begin
          if((u_apb_vif.IRQ_c !== 1) || (u_apb_vif.IRQ_uc !== 0)) 
              `uvm_error("single_bit_data_mem_err_inj_chk_seq", "Expected IRQ_C to be high and IRQ_UC to be low when Error Valid is high")

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType,field_rd_data);
          if(field_rd_data != 'h1)
              `uvm_error("single_bit_data_mem_err_inj_chk_seq",$sformatf("DMIUCESR  Not valid error type :%x",field_rd_data));

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrInfo,field_rd_data);
          if(field_rd_data != 'h1)  
              `uvm_error("single_bit_data_mem_err_inj_chk_seq",$sformatf("DMIUCESR  Not valid error info :%x",field_rd_data));
       end else if (data_parity) begin
          if((u_apb_vif.IRQ_c !== 0) || (u_apb_vif.IRQ_uc !== 1))
              `uvm_error("single_bit_data_mem_err_inj_chk_seq", "Expected IRQ_UC to be high and IRQ_C to be low when Error Valid is high")

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType,field_rd_data);
          if(field_rd_data != 'h1)
              `uvm_error("single_bit_data_mem_err_inj_chk_seq",$sformatf("DMIUUESR  Not valid error type :%x",field_rd_data));

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo,field_rd_data);
          if(field_rd_data != 'h1)  
              `uvm_error("single_bit_data_mem_err_inj_chk_seq",$sformatf("DMIUUESR  Not valid error info :%x",field_rd_data));
       end
    endtask
endclass : single_bit_data_mem_err_inj_chk_seq


//-----------------------------------------------------------------------
//  Task    : double_bit_data_mem_err_inj_chk_seq
//  Purpose :
//
//-----------------------------------------------------------------------
class double_bit_data_mem_err_inj_chk_seq extends ral_csr_base_seq; 
   `uvm_object_utils(double_bit_data_mem_err_inj_chk_seq)

    uvm_reg_data_t field_rd_data;
    int test_hang_count;
    virtual <%=obj.BlockId%>_apb_if u_apb_vif;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
       if(!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::get(null, get_full_name(), "apb_if",u_apb_vif))
         `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})

       //Set the Error Threshold & Enable the Interrupt
       if (tag_secded) begin
          //write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUECR.ErrIntEn, 1'b1);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, 1'b1);
       end else begin
          `uvm_fatal("double_bit_data_mem_err_inj_chk_seq", "Run this test for only configurations having SECDED error protection")
       end

       data = 1;
       do begin
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, field_rd_data);
          if(field_rd_data == 'h1)  
             `uvm_error("single_bit_data_mem_err_inj_chk_seq",$sformatf("DMIUCESR Error_valid should not be high :%x",field_rd_data));

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, field_rd_data);
          test_hang_count = test_hang_count + 1;
          if(test_hang_count == 50000) 
              `uvm_fatal("double_bit_data_mem_err_inj_chk_seq", "Test hanged since Error Valid bit is never set")
       end while(field_rd_data[0] != data);

       //Check the Error Interrupt Bit is set
       if((u_apb_vif.IRQ_c !== 0) || (u_apb_vif.IRQ_uc !== 1))
           `uvm_error("double_bit_data_mem_err_inj_chk_seq", "Expected IRQ_UC to be high when Error Valid is high")

       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType,field_rd_data);
       if(field_rd_data != 'h1)  
           `uvm_error("double_bit_data_mem_err_inj_chk_seq",$sformatf("DMIUUESR  Not valid error type :%x",field_rd_data));

       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo,field_rd_data);
       if(field_rd_data != 'h1)  
           `uvm_error("double_bit_data_mem_err_inj_chk_seq",$sformatf("DMIUUESR  Not valid error info :%x",field_rd_data));
    endtask
endclass : double_bit_data_mem_err_inj_chk_seq


//-----------------------------------------------------------------------
//  Task    : single_bit_tag_mem_err_inj_chk_seq
//  Purpose :
//
//-----------------------------------------------------------------------
class single_bit_tag_mem_err_inj_chk_seq extends ral_csr_base_seq; 
   `uvm_object_utils(single_bit_tag_mem_err_inj_chk_seq)

    uvm_reg_data_t field_rd_data;
    int test_hang_count;
    virtual <%=obj.BlockId%>_apb_if u_apb_vif;
    rand bit [2:0] errthd=1;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
       if(!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::get(null, get_full_name(), "apb_if",u_apb_vif))
         `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})

       //Set the Error Threshold & Enable the Interrupt
       assert(randomize(errthd));
       if (tag_secded) begin
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, errthd);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, 1'b1);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, 1'b1);
       end else if (tag_parity) begin
          //write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUECR.ErrIntEn, 1'b1);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, 1'b1);
       end else begin
          `uvm_fatal("single_bit_tag_mem_err_inj_chk_seq", "Run this test for only configurations having PARITY/SECDED error protection")
       end

       data = 1;
       do begin
          if (tag_secded) begin
             read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, field_rd_data);
             if(field_rd_data == 'h1)  
                `uvm_error("single_bit_tag_mem_err_inj_chk_seq",$sformatf("DMIUUESR Error_valid should not be high :%x",field_rd_data));

             read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, field_rd_data);
             test_hang_count = test_hang_count + 1;
             if(test_hang_count == 50000) 
                 `uvm_fatal("single_bit_data_mem_err_inj_chk_seq", "Test hanged since Error Valid bit is never set")
          end else if (tag_parity) begin
             read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, field_rd_data);
             if(field_rd_data == 'h1)  
                `uvm_error("single_bit_tag_mem_err_inj_chk_seq",$sformatf("DMIUCESR Error_valid should not be high :%x",field_rd_data));

             read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, field_rd_data);
             test_hang_count = test_hang_count + 1;
             if(test_hang_count == 50000) 
                 `uvm_fatal("single_bit_tag_mem_err_inj_chk_seq", "Test hanged since Error Valid bit is never set")
          end
       end while(field_rd_data != data);

       //Check the Error Interrupt Bit is set
       if (tag_secded) begin
          if((u_apb_vif.IRQ_c !== 1) || (u_apb_vif.IRQ_uc !== 0)) 
              `uvm_error("single_bit_tag_mem_err_inj_chk_seq", "Expected IRQ_C to be high and IRQ_UC to be low when Error Valid is high")

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType,field_rd_data);
          if(field_rd_data != 'h1)
              `uvm_error("single_bit_tag_mem_err_inj_chk_seq",$sformatf("DMIUCESR  Not valid error type :%x",field_rd_data));

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrInfo,field_rd_data);
          if(field_rd_data != 'h1)  
              `uvm_error("single_bit_tag_mem_err_inj_chk_seq",$sformatf("DMIUCESR  Not valid error info :%x",field_rd_data));
       end else if (tag_parity) begin
          if((u_apb_vif.IRQ_c !== 0) || (u_apb_vif.IRQ_uc !== 1))
              `uvm_error("single_bit_tagem_err_inj_chk_seq", "Expected IRQ_UC to be high and IRQ_C to be low when Error Valid is high")

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType,field_rd_data);
          if(field_rd_data != 'h1)
              `uvm_error("single_bit_tag_mem_err_inj_chk_seq",$sformatf("DMIUUESR  Not valid error type :%x",field_rd_data));

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo,field_rd_data);
          if(field_rd_data != 'h0)  
              `uvm_error("single_bit_tag_mem_err_inj_chk_seq",$sformatf("DMIUUESR  Not valid error info :%x",field_rd_data));
       end
    endtask
endclass : single_bit_tag_mem_err_inj_chk_seq


//-----------------------------------------------------------------------
//  Task    : double_bit_tag_mem_err_inj_chk_seq
//  Purpose :
//
//-----------------------------------------------------------------------
class double_bit_tag_mem_err_inj_chk_seq extends ral_csr_base_seq; 
   `uvm_object_utils(double_bit_tag_mem_err_inj_chk_seq)

    uvm_reg_data_t field_rd_data;
    int test_hang_count;
    virtual <%=obj.BlockId%>_apb_if u_apb_vif;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
       if(!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::get(null, get_full_name(), "apb_if",u_apb_vif))
         `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})

       //Set the Error Threshold & Enable the Interrupt
       if (tag_secded) begin
          //write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUECR.ErrIntEn, 1'b1);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.ProtErrDetEn, 1'b1);
       end else begin
          `uvm_fatal("double_bit_tag_mem_err_inj_chk_seq", "Run this test for only configurations having SECDED error protection")
       end

       data = 1;
       do begin
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, field_rd_data);
          if(field_rd_data == 'h1)  
             `uvm_error("single_bit_data_mem_err_inj_chk_seq",$sformatf("DMIUCESR Error_valid should not be high :%x",field_rd_data));

          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, field_rd_data);
          test_hang_count = test_hang_count + 1;
          if(test_hang_count == 50000) 
              `uvm_fatal("double_bit_tag_mem_err_inj_chk_seq", "Test hanged since Error Valid bit is never set")
       end while(field_rd_data[0] != data);

       //Check the Error Interrupt Bit is set
       if((u_apb_vif.IRQ_c !== 0) || (u_apb_vif.IRQ_uc !== 1))
           `uvm_error("double_bit_tag_mem_err_inj_chk_seq", "Expected IRQ_UC to be high when Error Valid is high")

       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType,field_rd_data);
       if(field_rd_data != 'h1)
           `uvm_error("double_bit_tag_mem_err_inj_chk_seq",$sformatf("DMIUUESR  Not valid error type :%x",field_rd_data));

       read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo,field_rd_data);
       if(field_rd_data != 'h0)
           `uvm_error("double_bit_tag_mem_err_inj_chk_seq",$sformatf("DMIUUESR  Not valid error info :%x",field_rd_data));
    endtask
endclass : double_bit_tag_mem_err_inj_chk_seq

//-----------------------------------------------------------------------
//  Class : 
//  Purpose : 
//  Note : For this testcase since i flush the entry after injecting 
//  error so i don't need to worry about injecting multiple errors on 
//  same way.
//-----------------------------------------------------------------------
class dmi_ccp_single_double_bit_data_error_intr_info_seq extends ral_csr_base_seq; 
  `uvm_object_utils(dmi_ccp_single_double_bit_data_error_intr_info_seq)

    dmi_scoreboard dmi_scb;
    int unsigned m_rand_index;
    bit security;
    bit flag;
    int error_count;

    bit [31:0]  mask1;
    bit [31:0]  mask2;
    bit [31:0]  mask;
    smi_addr_t  m_addr; 

    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    rand bit [5:0]  m_nWord;

    bit [19:0] cpy_nSets;
    bit [5:0]  cpy_nWays;
    bit [5:0]  cpy_nWord;
    string spkt;
    int test_hang_count;
    virtual <%=obj.BlockId%>_apb_if u_apb_vif;

    rand bit [7:0]  errthd;
    bit valid_test;
    bit error_valid;

   <% if (obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.nSets>1){ %>
    constraint c_nSets  { m_nSets  < <%=obj.DmiInfo[obj.Id].ccpParams.nSets%>;}
   <%}%>

   <% if (obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.nWays>1){ %>
    constraint c_nWays  { m_nWays  < <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>;}  
   <%}%>

    constraint c_errthd {errthd inside {[0:7]};}
    constraint c_m_nWord {m_nWord inside {[0:((<%=obj.DmiInfo[obj.Id].wData%>/32)-1)]};}

    function new(string name="");
        super.new(name);
    endfunction

    task post_body();
        if(!valid_test) begin
            spkt = {"dmi_ccp_single_double_bit_data_error_intr_info_seq has invalid stimulus ",
                     " error threshold never reached error_count_value:%0d and ",
                     " error_threshold_value:%0d "};
            `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq", $psprintf(spkt,error_count, errthd))
        end
    endtask

    task body();
        `uvm_info("body", "Entered...", UVM_MEDIUM)
        #(1us);

        if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                                .inst_name( "*" ),
                                                .field_name( "dmi_scb" ),
                                                .value( dmi_scb ))) begin
           `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq", "dmi_scb model not found")
        end
        if(dmi_scb.m_dmi_cache_q.size()==0) `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq", "no entry in cache to inject errors")

        if(!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::get(null, get_full_name(), "apb_if",u_apb_vif))
          `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})

        //Set the Error Threshold & Enable the Error detection and Interrupt
        assert(randomize(errthd));
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, errthd);
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, 1'b1);
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, 1'b1);

        // TODO: guard this for Parity, parity protection can't correct error
        repeat(500) begin
           if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                                   .inst_name( "*" ),
                                                   .field_name( "dmi_scb" ),
                                                   .value( dmi_scb ))) begin
              `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq", "dmi_scb model not found")
           end

           if(dmi_scb.m_dmi_cache_q.size()>0) begin
              m_rand_index = $urandom_range(0, dmi_scb.m_dmi_cache_q.size()-1);
              m_nSets = dmi_scb.m_dmi_cache_q[m_rand_index].Index;
              m_nWays = dmi_scb.m_dmi_cache_q[m_rand_index].way;
              assert(randomize(m_nWord));
              security = dmi_scb.m_dmi_cache_q[m_rand_index].security;
              `uvm_info("RUN_MAIN",$sformatf("configuring m_nSets :%x,  mway :%x ",m_nSets,m_nWays), UVM_MEDIUM)

              //Setup MntOp Read
              wr_data = m_nSets;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntSet, wr_data);
              wr_data = m_nWays;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWay, wr_data);
              wr_data = m_nWord;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWord, wr_data);

              wr_data   = 'hc;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.MntOp, wr_data);
              wr_data   = 'h1;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.ArrayID, wr_data);
              wr_data   = security;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.SecAttr, wr_data);
              
              // Wait for MntOpActv to go low
              do begin
                  data = 0;
                  read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
              end while(field_rd_data != data);
              
              //Read the Data
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.MntData,field_rd_data);

              //Inject single bit data Error 
              mask = 1'b1 << $urandom_range(15, 0);
              wr_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));

              `uvm_info("AMAN", $psprintf("RD_DATA:%0h and WR_DATA:%0h and Mask:%0h", 
                                          field_rd_data,wr_data,mask),UVM_MEDIUM);

              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.MntData,wr_data);

              // Write the data (with error injected) back
              wr_data   = 'he;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.MntOp, wr_data);
              wr_data   = 'h1;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.ArrayID, wr_data);
              wr_data   = security;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.SecAttr, wr_data);

              do begin
                  data = 0;
                  read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
              end while(field_rd_data != data);

              if (dmi_scb.m_dmi_cache_q[m_rand_index].state == UD) begin
                  error_count = error_count + 1;
                  error_valid = 1;
              end
           end else begin
              if ((error_count < (errthd+1))) begin
                 valid_test = 1;
                 error_valid = 0;
                 break;
              end
           end

           //Program the ML0 Entry for Addr
           wr_data = m_nSets;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntSet, wr_data);
           wr_data = m_nWays;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWay, wr_data);
           wr_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWord, wr_data);
           `uvm_info("dmi_ccp_single_double_bit_data_error_intr_info_seq",$sformatf("Sending set %0h way %0h", m_nSets, m_nWays), UVM_MEDIUM)

           //Program the MntOp Register with Opcode-5 to flush the entry
           wr_data   = 'h5;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.MntOp, wr_data);
           wr_data   = 'h0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.ArrayID, wr_data);
           wr_data   = security;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.SecAttr, wr_data);

           //Poll the MntOp Active Bit
           do begin
              data = 0;
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
           end while(field_rd_data != data);

           //Check Error Logging Registers
           if((error_count == (errthd+1)) && error_valid) begin
              error_valid = 0;
              cpy_nSets = m_nSets;
              cpy_nWays = m_nWays;
              cpy_nWord = m_nWord;

              //Poll the ErrVld Bit
              test_hang_count = 0;
              do begin
                data = 1;
                read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, field_rd_data);
                test_hang_count = test_hang_count + 1;
                if(test_hang_count == 5000) 
                   `uvm_fatal("dmi_ccp_single_double_bit_data_error_intr_info_seq", "Test hanged since Error Valid bit is never set")
              end while(field_rd_data[0] != data);

              //Check the Error Interrupt Bit is set
              if(u_apb_vif.IRQ_c !== 1) 
                  `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq", "Expected IRQ_C to valid when Error Valid is high")

              //Read the Error Type, should be 1 for data mem error
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, field_rd_data);
              if(field_rd_data != 'h1)  
                  `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq",$sformatf("DMIUCESR  Not valid error type :%x",field_rd_data));

              //Read the Error Info, should be 1 for single bit error
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrInfo, field_rd_data);
              if(field_rd_data != 'h1)  
                  `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq",$sformatf("DMIUCESR  Not valid error info :%x",field_rd_data));

              //Error Location Register matches the injected error location 
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCELR0.ErrAddr,field_rd_data );
              if(field_rd_data[19:0] != cpy_nSets)  
                  `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq",$sformatf("DMIUCELR0 has an unexpcted error location  Expected nSets:%0h but Got nSets:%0h", cpy_nSets,field_rd_data));
              if(field_rd_data[25:20] != cpy_nWays)  
                  `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq",$sformatf("DMIUCELR0 has an unexpcted error location  Expected nWays:%0h but Got nWays:%0h", cpy_nWays,field_rd_data));
              if(field_rd_data[31:26] != cpy_nWord) begin
                 `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq",$sformatf("DMIUCELR0 has an unexpcted error location  Expected nWord:%0h but Got nWord:%0h", cpy_nWord,field_rd_data));
              end
              break;
           end
        end

        error_valid = 0;
        repeat(500) begin
           if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                                   .inst_name( "*" ),
                                                   .field_name( "dmi_scb" ),
                                                   .value( dmi_scb ))) begin
               `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq", "dmi_scoreboard not found")
           end
           #(1us);

           if(dmi_scb.m_dmi_cache_q.size()>0) begin
              m_rand_index = $urandom_range(0, dmi_scb.m_dmi_cache_q.size()-1);
              m_nSets = dmi_scb.m_dmi_cache_q[m_rand_index].Index;
              m_nWays = dmi_scb.m_dmi_cache_q[m_rand_index].way;
              assert(randomize(m_nWord));
              security = dmi_scb.m_dmi_cache_q[m_rand_index].security;
              `uvm_info("RUN_MAIN",$sformatf("configuring m_nSets :%x,  mway :%x ",m_nSets,m_nWays), UVM_MEDIUM)

              //Setup MntOp Read
              wr_data = m_nSets;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntSet, wr_data);
              wr_data = m_nWays;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWay, wr_data);
              wr_data = m_nWord;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWord, wr_data);

              wr_data   = 'hc;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.MntOp, wr_data);
              wr_data   = 'h1;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.ArrayID, wr_data);
              wr_data   = security;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.SecAttr, wr_data);
              
              // Wait for MntOpActv to go low
              do begin
                  data = 0;
                  read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
              end while(field_rd_data != data);
              
              //Read the Data
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.MntData,field_rd_data);

              //Inject double bit data Error 
              // TODO: make it work for Parity as well, only single bit error will be uncorrectable
              mask1 = 1'b1 << $urandom_range(15, 0);
              mask2 = 1'b1 << $urandom_range(31, 16);
              mask = mask1 | mask2;
              wr_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));
              `uvm_info("AMAN", $psprintf("RD_DATA:%0h and WR_DATA:%0h and Mask:%0h", 
                                          field_rd_data,wr_data,mask),UVM_MEDIUM);

              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.MntData,wr_data);

              // Write the data (with error injected) back
              wr_data   = 'he;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.MntOp, wr_data);
              wr_data   = 'h1;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.ArrayID, wr_data);
              wr_data   = security;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.SecAttr, wr_data);

              do begin
                 data = 0;
                 read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
              end while(field_rd_data != data);

              if (dmi_scb.m_dmi_cache_q[m_rand_index].state == UD) error_valid = 1;
            end else begin
               valid_test = 1;
               error_valid = 0;
               break;
            end

            //Program the ML0 Entry for Addr
            wr_data = m_nSets;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntSet, wr_data);
            wr_data = m_nWays;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWay, wr_data);
            wr_data = 0;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWord, wr_data);
            `uvm_info("dmi_ccp_single_double_bit_data_error_intr_info_seq",$sformatf("Sending set %0h way %0h", m_nSets, m_nWays), UVM_MEDIUM)

            //Program the MntOp Register with Opcode-5 to flush the entry
            wr_data   = 'h5;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.MntOp, wr_data);
            wr_data   = 'h0;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.ArrayID, wr_data);
            wr_data   = security;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.SecAttr, wr_data);

            //Poll the MntOp Active Bit
            do begin
               data = 0;
               read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
            end while(field_rd_data != data);

            //Check Error Logging Registers
            if(error_valid) begin
              error_valid = 0;
              cpy_nSets = m_nSets;
              cpy_nWays = m_nWays;
              cpy_nWord = m_nWord;

              //Poll the ErrVld Bit
              test_hang_count = 0;
              do begin
                data = 1;
                read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, field_rd_data);
                test_hang_count = test_hang_count + 1;
                if(test_hang_count == 5000) 
                   `uvm_fatal("dmi_ccp_single_double_bit_data_error_intr_info_seq", "Test hanged since Error Valid bit is never set")
              end while(field_rd_data[0] != data);

              //Check the Error Interrupt Bit is set
              if(u_apb_vif.IRQ_uc !== 1) 
                  `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq", "Expected IRQ_UC to valid when Error Valid is high")

              //Read the Error Type, should be 1 for data mem error
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, field_rd_data);
              if(field_rd_data != 'h1)  
                  `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq",$sformatf("DMIUCESR  Not valid error type :%x",field_rd_data));

              //Read the Error Info, should be 1 for single bit error
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, field_rd_data);
              if(field_rd_data != 'h1)  
                  `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq",$sformatf("DMIUCESR  Not valid error info :%x",field_rd_data));

              //Error Location Register matches the injected error location 
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR0.ErrAddr, field_rd_data);

              if(field_rd_data[19:0] != cpy_nSets)  
                  `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq",$sformatf("DMIUCELR0 has an unexpcted error location  Expected nSets:%0h but Got nSets:%0h", cpy_nSets,field_rd_data));

              if(field_rd_data[25:20] != cpy_nWays)  
                  `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq",$sformatf("DMIUCELR0 has an unexpcted error location  Expected nWays:%0h but Got nWays:%0h", cpy_nWays,field_rd_data));

              if(field_rd_data[31:26] != cpy_nWord) begin
                 `uvm_error("dmi_ccp_single_double_bit_data_error_intr_info_seq",$sformatf("DMIUCELR0 has an unexpcted error location  Expected nWord:%0h but Got nWord:%0h", cpy_nWord,field_rd_data));
              end
              valid_test = 1'b1;
              break;
           end
        end
      `uvm_info("body", "Exiting...", UVM_NONE)
    endtask
endclass : dmi_ccp_single_double_bit_data_error_intr_info_seq


//-----------------------------------------------------------------------
//  Class : dmi_ccp_single_double_bit_tag_error_intr_info_seq
//  Purpose : 
//  Note : 
//-----------------------------------------------------------------------
class dmi_ccp_single_double_bit_tag_error_intr_info_seq extends ral_csr_base_seq; 
  `uvm_object_utils(dmi_ccp_single_double_bit_tag_error_intr_info_seq)

    dmi_scoreboard dmi_scb;
    int unsigned m_rand_index;
    bit security;
    bit flag;
    int error_count;

    bit [31:0]  mask1;
    bit [31:0]  mask2;
    bit [31:0]  mask;
    smi_addr_t  m_addr; 

    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    rand bit [5:0]  m_nWord;

    bit [19:0] cpy_nSets;
    bit [5:0]  cpy_nWays;
    bit [5:0]  cpy_nWord;
    string spkt;
    int test_hang_count;
    virtual <%=obj.BlockId%>_apb_if u_apb_vif;

    rand bit [7:0]  errthd;
    bit valid_test;
    bit error_valid;

   <% if (obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.nSets>1){ %>
    constraint c_nSets  { m_nSets < <%=obj.DmiInfo[obj.Id].ccpParams.nSets%>;}
   <%}%>

   <% if (obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.nWays>1){ %>
    constraint c_nWays  { m_nWays < <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>;}  
   <%}%>

    constraint c_errthd {errthd inside {[0:7]};}
    constraint c_m_nWord {m_nWord inside {[0:((<%=obj.DmiInfo[obj.Id].wData%>/32)-1)]};}

    function new(string name="");
        super.new(name);
    endfunction

    task post_body();
        if(!valid_test) begin
            spkt = {"dmi_ccp_single_double_bit_tag_error_intr_info_seq has invalid stimulus ",
                     " error threshold never reached error_count_value:%0d and ",
                     " error_threshold_value:%0d "};
            `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq", $psprintf(spkt,error_count, errthd))
        end
    endtask

    task body();
        `uvm_info("body", "Entered...", UVM_MEDIUM)
        #(1us);

        if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                                .inst_name( "*" ),
                                                .field_name( "dmi_scb" ),
                                                .value( dmi_scb ))) begin
           `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq", "dmi_scb model not found")
        end

        if(dmi_scb.m_dmi_cache_q.size()==0) `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq", "no entry in cache to inject errors")

        if(!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::get(null, get_full_name(), "apb_if",u_apb_vif))
          `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})

        //Set the Error Threshold & Enable the Error detection and Interrupt
        assert(randomize(errthd));
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrThreshold, errthd);
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrIntEn, 1'b1);
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCECR.ErrDetEn, 1'b1);

        // TODO: guard this for Parity, parity protection can't correct error
        repeat(500) begin
           #100ns;
           if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                                   .inst_name( "*" ),
                                                   .field_name( "dmi_scb" ),
                                                   .value( dmi_scb ))) begin
              `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq", "dmi_scb model not found")
           end

           if(dmi_scb.m_dmi_cache_q.size()>0) begin
              m_rand_index = $urandom_range(0, dmi_scb.m_dmi_cache_q.size()-1);
              m_nSets = dmi_scb.m_dmi_cache_q[m_rand_index].Index;
              m_nWays = dmi_scb.m_dmi_cache_q[m_rand_index].way;
              security = dmi_scb.m_dmi_cache_q[m_rand_index].security;
              `uvm_info("RUN_MAIN",$sformatf("configuring m_nSets :%x,  mway :%x ",m_nSets,m_nWays), UVM_MEDIUM)

              //Setup MntOp Read
              wr_data = m_nSets;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntSet, wr_data);
              wr_data = m_nWays;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWay, wr_data);
              wr_data = 0;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWord, wr_data);

              wr_data   = 'hc;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.MntOp, wr_data);
              wr_data   = 'h0;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.ArrayID, wr_data);
              wr_data   = security;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.SecAttr, wr_data);
              
              // Wait for MntOpActv to go low
              do begin
                  data = 0;
                  read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
              end while(field_rd_data != data);
              
              //Read the Data
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.MntData,field_rd_data);

              //Inject single bit data Error 
              mask = 1'b1 << $urandom_range(15, 0);
              wr_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));

              `uvm_info("AMAN", $psprintf("RD_DATA:%0h and WR_DATA:%0h and Mask:%0h", 
                                          field_rd_data,wr_data,mask),UVM_MEDIUM);

              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.MntData,wr_data);

              // Write the data (with error injected) back
              wr_data   = 'he;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.MntOp, wr_data);
              wr_data   = 'h0;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.ArrayID, wr_data);
              wr_data   = security;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.SecAttr, wr_data);

              do begin
                  data = 0;
                  read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
              end while(field_rd_data != data);

              error_count = error_count + 1;
              error_valid = 1;
           end else begin
              if ((error_count < (errthd+1))) begin
                 valid_test = 1;
                 error_valid = 0;
                 break;
              end
           end

           //Program the ML0 Entry for Addr
           wr_data = m_nSets;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntSet, wr_data);
           wr_data = m_nWays;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWay, wr_data);
           wr_data = 0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWord, wr_data);
           `uvm_info("dmi_ccp_single_double_bit_tag_error_intr_info_seq",$sformatf("Sending set %0h way %0h", m_nSets, m_nWays), UVM_MEDIUM)

           //Program the MntOp Register with Opcode-5 to flush the entry
           wr_data   = 'h5;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.MntOp, wr_data);
           wr_data   = 'h0;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.ArrayID, wr_data);
           wr_data   = security;
           write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.SecAttr, wr_data);

           //Poll the MntOp Active Bit
           do begin
              data = 0;
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
           end while(field_rd_data != data);

           //Check Error Logging Registers
           if((error_count == (errthd+1)) && error_valid) begin
              error_valid = 0;
              cpy_nSets = m_nSets;
              cpy_nWays = m_nWays;
              cpy_nWord = 0;

              //Poll the ErrVld Bit
              test_hang_count = 0;
              do begin
                data = 1;
                read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrVld, field_rd_data);
                test_hang_count = test_hang_count + 1;
                if(test_hang_count == 5000) 
                   `uvm_fatal("dmi_ccp_single_double_bit_tag_error_intr_info_seq", "Test hanged since Error Valid bit is never set")
              end while(field_rd_data[0] != data);

              //Check the Error Interrupt Bit is set
              if(u_apb_vif.IRQ_c !== 1) 
                  `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq", "Expected IRQ_C to valid when Error Valid is high")

              //Read the Error Type, should be 1 for data mem error
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrType, field_rd_data);
              if(field_rd_data != 'h1)  
                  `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq",$sformatf("DMIUCESR  Not valid error type :%x",field_rd_data));

              //Read the Error Info, should be 1 for single bit error
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCESR.ErrInfo, field_rd_data);
              if(field_rd_data != 'h1)  
                  `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq",$sformatf("DMIUCESR  Not valid error info :%x",field_rd_data));

              //Error Location Register matches the injected error location 
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCELR0.ErrAddr, field_rd_data);
              if(field_rd_data[19:0] != cpy_nSets)  
                  `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq",$sformatf("DMIUCELR0 has an unexpcted error location  Expected nSets:%0h but Got nSets:%0h", cpy_nSets,field_rd_data));

              if(field_rd_data[25:20] != cpy_nWays)  
                  `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq",$sformatf("DMIUCELR0 has an unexpcted error location  Expected nWays:%0h but Got nWays:%0h", cpy_nWays,field_rd_data));

              if(field_rd_data[31:26] != cpy_nWord) begin
                 `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq",$sformatf("DMIUCELR0 has an unexpcted error location  Expected nWord:%0h but Got nWord:%0h", cpy_nWord,field_rd_data));
              end
              break;
           end
        end

        error_valid = 0;
        repeat(500) begin
           if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                                   .inst_name( "*" ),
                                                   .field_name( "dmi_scb" ),
                                                   .value( dmi_scb ))) begin
               `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq", "dmi_scoreboard not found")
           end
           #(1us);

           if(dmi_scb.m_dmi_cache_q.size()>0) begin
              m_rand_index = $urandom_range(0, dmi_scb.m_dmi_cache_q.size()-1);
              m_nSets = dmi_scb.m_dmi_cache_q[m_rand_index].Index;
              m_nWays = dmi_scb.m_dmi_cache_q[m_rand_index].way;
              security = dmi_scb.m_dmi_cache_q[m_rand_index].security;
              `uvm_info("RUN_MAIN",$sformatf("configuring m_nSets :%x,  mway :%x ",m_nSets,m_nWays), UVM_MEDIUM)

              //Setup MntOp Read
              wr_data = m_nSets;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntSet, wr_data);
              wr_data = m_nWays;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWay, wr_data);
              wr_data = 0;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWord, wr_data);

              wr_data   = 'hc;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.MntOp, wr_data);
              wr_data   = 'h0;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.ArrayID, wr_data);
              wr_data   = security;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.SecAttr, wr_data);
              
              // Wait for MntOpActv to go low
              do begin
                  data = 0;
                  read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
              end while(field_rd_data != data);
              
              //Read the Data
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.MntData,field_rd_data);

              //Inject double bit data Error 
              // TODO: make it work for Parity as well, only single bit error will be uncorrectable
              mask1 = 1'b1 << $urandom_range(15, 0);
              mask2 = 1'b1 << $urandom_range(31, 16);
              mask = mask1 | mask2;
              wr_data = ((field_rd_data & ~mask) | (~field_rd_data & mask));
              `uvm_info("AMAN", $psprintf("RD_DATA:%0h and WR_DATA:%0h and Mask:%0h", 
                                          field_rd_data,wr_data,mask),UVM_MEDIUM);

              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMDR.MntData,wr_data);

              // Write the data (with error injected) back
              wr_data   = 'he;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.MntOp, wr_data);
              wr_data   = 'h0;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.ArrayID, wr_data);
              wr_data   = security;
              write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.SecAttr, wr_data);

              do begin
                 data = 0;
                 read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
              end while(field_rd_data != data);

              error_valid = 1;
            end else begin
               valid_test = 1;
               error_valid = 0;
               break;
            end

            //Program the ML0 Entry for Addr
            wr_data = m_nSets;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntSet, wr_data);
            wr_data = m_nWays;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWay, wr_data);
            wr_data = 0;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWord, wr_data);
            `uvm_info("dmi_ccp_single_double_bit_tag_error_intr_info_seq",$sformatf("Sending set %0h way %0h", m_nSets, m_nWays), UVM_MEDIUM)

            //Program the MntOp Register with Opcode-5 to flush the entry
            wr_data   = 'h5;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.MntOp, wr_data);
            wr_data   = 'h0;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.ArrayID, wr_data);
            wr_data   = security;
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.SecAttr, wr_data);

            //Poll the MntOp Active Bit
            do begin
               data = 0;
               read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
            end while(field_rd_data != data);

            //Check Error Logging Registers
            if(error_valid) begin
              error_valid = 0;
              cpy_nSets = m_nSets;
              cpy_nWays = m_nWays;
              cpy_nWord = 0;

              //Poll the ErrVld Bit
              test_hang_count = 0;
              do begin
                data = 1;
                read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, field_rd_data);
                test_hang_count = test_hang_count + 1;
                if(test_hang_count == 5000) 
                   `uvm_fatal("dmi_ccp_single_double_bit_tag_error_intr_info_seq", "Test hanged since Error Valid bit is never set")
              end while(field_rd_data[0] != data);

              //Check the Error Interrupt Bit is set
              if(u_apb_vif.IRQ_uc !== 1) 
                  `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq", "Expected IRQ_UC to valid when Error Valid is high")

              //Read the Error Type, should be 1 for data mem error
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, field_rd_data);
              if(field_rd_data != 'h1)  
                  `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq",$sformatf("DMIUCESR  Not valid error type :%x",field_rd_data));

              //Read the Error Info, should be 1 for single bit error
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, field_rd_data);
              if(field_rd_data != 'h1)  
                  `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq",$sformatf("DMIUCESR  Not valid error info :%x",field_rd_data));

              //Error Location Register matches the injected error location 
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUELR0.ErrAddr, field_rd_data);

              if(field_rd_data[19:0] != cpy_nSets)  
                  `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq",$sformatf("DMIUUELR0 has an unexpcted error location  Expected nSets:%0h but Got nSets:%0h", cpy_nSets,field_rd_data));

              if(field_rd_data[25:20] != cpy_nWays)  
                  `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq",$sformatf("DMIUUELR0 has an unexpcted error location  Expected nWays:%0h but Got nWays:%0h", cpy_nWays,field_rd_data));

              if(field_rd_data[31:26] != cpy_nWord) begin
                 `uvm_error("dmi_ccp_single_double_bit_tag_error_intr_info_seq",$sformatf("DMIUUELR0 has an unexpcted error location   Expected nWord:%0h but Got nWord:%0h", cpy_nWord,field_rd_data));
              end
              valid_test = 1'b1;
              break;
           end
        end
       `uvm_info("body", "Exiting...", UVM_NONE)
    endtask
endclass : dmi_ccp_single_double_bit_tag_error_intr_info_seq
<%}%>

//-----------------------------------------------------------------------
//  Class : dmi_end_of_test_seq
//  Purpose : Checks the TransActv, AllocActv and EvictActv register
//-----------------------------------------------------------------------
class dmi_end_of_test_seq extends ral_csr_base_seq;
  `uvm_object_utils(dmi_end_of_test_seq)
    dmi_scoreboard dmi_scb;

    function new(string name="dmi_end_of_test_seq");
        super.new(name);
    endfunction

    virtual task body();
       `uvm_info("body", "Entered...", UVM_MEDIUM)
       m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUTAR.read(status,field_rd_data,.parent(this));
       if (field_rd_data != 0) begin
          `uvm_error("dmi_end_of_test_seq", "TransActv should be low after the test is over")
       end
<%if(obj.useCmc){%>
       m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCTAR.read(status,field_rd_data,.parent(this));
       if (field_rd_data != 0) begin
             `uvm_error("dmi_end_of_test_seq", "AllocActv and EvictActv should be low after the test is over")
       end
<%}%>
       `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask: body
endclass : dmi_end_of_test_seq

//-----------------------------------------------------------------------
//  Class : dmi_trans_actv_high_seq
//  Purpose : Checks the TransActv
//-----------------------------------------------------------------------
class dmi_trans_actv_high_seq extends ral_csr_base_seq;
  `uvm_object_utils(dmi_trans_actv_high_seq)
    dmi_scoreboard dmi_scb;

    function new(string name="dmi_trans_actv_high_seq");
        super.new(name);
    endfunction

    virtual task body();
      if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                                .inst_name( "*" ),
                                                .field_name( "dmi_scb" ),
                                                .value( dmi_scb ))) begin
        `uvm_error("dmi_trans_actv_high_seq", "dmi_scb model not found")
      end
       `uvm_info("body", "Entered...", UVM_MEDIUM)
       m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUTAR.read(status,field_rd_data,.parent(this));
       if(field_rd_data != 1 && (dmi_scb.rtt_q.size()+dmi_scb.wtt_q.size() != 0)) begin
         dmi_scb.compute_pma_exceptions($time);
         m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUTAR.read(status,field_rd_data,.parent(this)); //Perform a second read, things might have shifted in design.
         if(field_rd_data != 1 && dmi_scb.wtt_q.size()+dmi_scb.rtt_q.size() != dmi_scb.num_rb_waiting_on_dtw ) begin
           `uvm_error("dmi_trans_actv_high_seq", $sformatf("TransActv should be high when there are transactions in DMI | WTT:%0d RTT:%0d Rbs waiting on DTWs:%0d", dmi_scb.wtt_q.size(),dmi_scb.rtt_q.size(),dmi_scb.num_rb_waiting_on_dtw))
         end
       end
       `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask: body
endclass : dmi_trans_actv_high_seq
<% if (obj.useCmc) { %>
//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Set lookup_en and alloc_en to some random values and check
//            if the entries are allocated in cache or not
//-----------------------------------------------------------------------
class dmi_rand_lookup_alloc_en_seq extends ral_csr_base_seq; 
   `uvm_object_utils(dmi_rand_lookup_alloc_en_seq)

   bit lookup_en=0;
   bit alloc_en=0;

   function new(string name="");
       super.new(name);
   endfunction

   task body(); 
      `uvm_info("body", "Entered...", UVM_MEDIUM)

      // Setting LookUpEn and AllocEn to some random value
      wr_data = lookup_en;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCTCR.LookupEn, wr_data);
      wr_data = alloc_en;
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCTCR.AllocEn, wr_data);

      `uvm_info("body", "Exiting...", UVM_MEDIUM)
   endtask
endclass


//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Flushes cachelines using address range
//-----------------------------------------------------------------------
class dmi_csr_flush_by_addr_range_seq extends ral_csr_base_seq;
  `uvm_object_utils(dmi_csr_flush_by_addr_range_seq)

  dmi_scoreboard dmi_scb;
  dmi_env_config m_cfg;
  
  int unsigned m_rand_index;
  bit security;
  smi_addr_t  m_addr; 
  int offset = <%=obj.wCacheLineOffset%>;
  int k_num_flush_cmd=1;
  int cache_size = (<%=obj.DmiInfo[obj.Id].ccpParams.nSets%> * <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>);
  string LABEL = "dmi_csr_flush_by_addr_range_seq";

  function new(string name="dmi_csr_flush_by_addr_range_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info("RUN_MAIN", "Started dmi_csr_flush_by_addr_range_seq", UVM_LOW)
    repeat(k_num_flush_cmd) begin
        #(1000ns);
        if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                                .inst_name( "*" ),
                                                .field_name( "dmi_scb" ),
                                                .value( dmi_scb ))) begin
          `uvm_error("dmi_csr_flush_by_addr_range_seq", "dmi_scb model not found")
        end
        if(!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                         .inst_name( "uvm_test_top.*" ),
                                         .field_name( "dmi_env_config" ),
                                         .value( m_cfg ))) begin
          `uvm_error("dmi_csr_flush_by_addr_range_seq", "dmi_env_config handle not found")
        end

        m_addr   = $urandom();
        security = $urandom();

        if( dmi_scb.m_dmi_cache_q.size()>0) begin
            m_rand_index = $urandom_range(0, dmi_scb.m_dmi_cache_q.size()-1);
            `uvm_info(LABEL,$sformatf("index %d cache model q size %d",m_rand_index,
                                           dmi_scb.m_dmi_cache_q.size()), UVM_LOW)
            m_addr   = dmi_scb.m_dmi_cache_q[m_rand_index].addr; 
            security = dmi_scb.m_dmi_cache_q[m_rand_index].security; 
            `uvm_info(LABEL,$sformatf("Hurray Got Addr :%x from IO cache model",m_addr), UVM_LOW)
        end 

        //Poll the MntOp Active Bit
        do begin
           data = 0;
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
        end while(field_rd_data != data);

       <% if((obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset) > 32) {%>
        //Program the ML0 Entry for Addr
        wr_data   = m_addr >> offset;
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,wr_data,.parent(this));
        `uvm_info(LABEL,$sformatf("Sending Addr :%x from IO cache model",wr_data), UVM_MEDIUM)

        //Program the ML1 Entry for Addr
        wr_data   = m_addr >> offset;
        wr_data   = wr_data >> 'h20;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR1.MntAddr, wr_data);
        `uvm_info(LABEL,$sformatf("Sending Addr :%x from IO cache model",wr_data), UVM_MEDIUM)
        `uvm_info(LABEL,$sformatf("Found the Addr size to be greater than 32 Size:%0d",<%=obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset%>), UVM_MEDIUM)
        <%}else{%>
        //Program the ML0 Entry for Addr
        wr_data   = m_addr >> offset;
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,wr_data,.parent(this));
        `uvm_info(LABEL,$sformatf("Sending Addr :%x from IO cache model",wr_data), UVM_MEDIUM)
        <%}%>
        if(m_cfg.m_args.k_MNTOP_addr_range_max) begin
          wr_data = (<%=obj.DmiInfo[obj.Id].ccpParams.nSets%> * <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>);
        end
        else begin
          int limited_max = (cache_size/10 == 0) ? 5 : cache_size/10;
          wr_data = $urandom_range(1,limited_max);
        end
        `uvm_info(LABEL,$sformatf("Setting MntRange:%0d CacheSize:%0d MaxMode:%0b",wr_data,cache_size,m_cfg.m_args.k_MNTOP_addr_range_max), UVM_MEDIUM)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR1.MntRange, wr_data);

        //Program the MntOp Register with Opcode-7
        wr_data   = {9'h0,security,22'h7};
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,wr_data, .parent(this));

        //Poll the MntOp Active Bit
        do begin
           data = 0;
           read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
        end while(field_rd_data != data);
    end
    `uvm_info("RUN_MAIN", "Finished dmi_csr_flush_by_addr_range_seq", UVM_LOW)
  endtask      
endclass : dmi_csr_flush_by_addr_range_seq 


//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Flushes cachelines using address
//-----------------------------------------------------------------------
class dmi_csr_flush_by_addr_seq extends ral_csr_base_seq;
  `uvm_object_utils(dmi_csr_flush_by_addr_seq)

  dmi_scoreboard dmi_scb;
  int unsigned m_rand_index;
  bit security;
  smi_addr_t  m_addr; 
  int offset = <%=obj.wCacheLineOffset%>;
  int k_num_flush_cmd=1;

  function new(string name="dmi_csr_flush_by_addr_seq");
      super.new(name);
  endfunction

  task body();
      `uvm_info("body", "Entered...", UVM_NONE)
      repeat(k_num_flush_cmd) begin
         #(100ns);
          if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                                  .inst_name( "*" ),
                                                  .field_name( "dmi_scb" ),
                                                  .value( dmi_scb ))) begin
             `uvm_error("dmi_csr_flush_by_addr_seq", "dmi_scb model not found")
          end

          m_addr   = $urandom();
          security = $urandom();

          if( dmi_scb.m_dmi_cache_q.size()>0) begin
              m_rand_index = $urandom_range(0, dmi_scb.m_dmi_cache_q.size()-1);
              `uvm_info("dmi_csr_flush_by_addr_seq",$sformatf("index %d cache model q size %d",m_rand_index,
                                             dmi_scb.m_dmi_cache_q.size()), UVM_NONE)
              m_addr   = dmi_scb.m_dmi_cache_q[m_rand_index].addr; 
              security = dmi_scb.m_dmi_cache_q[m_rand_index].security; 
              `uvm_info("dmi_csr_flush_by_addr_seq",$sformatf("Hurray Got Addr :%x from IO cache model",m_addr), UVM_NONE)
          end 

          //Poll the MntOp Active Bit
          do begin
             data = 0;
             read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
          end while(field_rd_data != data);

         <% if((obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset) > 32) {%>
          //Program the ML0 Entry for Addr
          wr_data   = m_addr >> offset;
          m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,wr_data,.parent(this));
          `uvm_info("dmi_csr_flush_by_addr_seq",$sformatf("Sending Addr :%x from IO cache model",wr_data), UVM_MEDIUM)

          //Program the ML1 Entry for Addr
          wr_data   = m_addr >> offset;
          wr_data   = wr_data >> 'h20;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR1.MntAddr, wr_data);
          `uvm_info("dmi_csr_flush_by_addr_seq",$sformatf("Sending Addr :%x from IO cache model",wr_data), UVM_MEDIUM)
          `uvm_info("dmi_csr_flush_by_addr_seq",$sformatf("Found the Addr size to be greater than 32 Size:%0d",<%=obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset%>), UVM_MEDIUM)
         <%}else{%>
          //Program the ML0 Entry for Addr
          wr_data   = m_addr >> offset;
          m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.write(status,wr_data,.parent(this));
          `uvm_info("dmi_csr_flush_by_addr_seq",$sformatf("Sending Addr :%x from IO cache model",wr_data), UVM_MEDIUM)
         <%}%>

          //Program the MntOp Register with Opcode-6
          wr_data   = {9'h0,security,22'h6};
          m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,wr_data, .parent(this));

          //Poll the MntOp Active Bit
          do begin
             data = 0;
             read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
          end while(field_rd_data != data);
      end
      `uvm_info("body", "Exiting...", UVM_NONE)
  endtask      
endclass : dmi_csr_flush_by_addr_seq 


//-----------------------------------------------------------------------
//  Class : dmi_csr_flush_by_index_way_range_seq
//  Purpose : To flush cache entries using index and way
//-----------------------------------------------------------------------
class dmi_csr_flush_by_index_way_range_seq extends ral_csr_base_seq; 
    `uvm_object_utils(dmi_csr_flush_by_index_way_range_seq)

    dmi_scoreboard dmi_scb;
    dmi_env_config m_cfg;

    int unsigned m_rand_index;

    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    rand bit [5:0]  m_nWord;
    int cache_size = (<%=obj.DmiInfo[obj.Id].ccpParams.nSets%> * <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>);
    int k_num_flush_cmd=1;
    string spkt;
    string LABEL = "dmi_csr_flush_by_index_way_range_seq";
    <% if (obj.useCmc){ %>
    constraint c_nSets  { m_nSets >= 0; m_nSets < <%=obj.DmiInfo[obj.Id].ccpParams.nSets%>;}
    constraint c_nWays  { m_nWays >= 0; m_nWays < <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>;}  
    <%}%>

    function new(string name="dmi_csr_flush_by_index_way_range_seq");
      super.new(name);
    endfunction

    task body();
      `uvm_info("RUN_MAIN", "Started dmi_csr_flush_by_index_way_range_seq", UVM_MEDIUM)
      repeat(k_num_flush_cmd) begin
        #100ns;

        if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                                .inst_name( "*" ),
                                                .field_name( "dmi_scb" ),
                                                .value( dmi_scb ))) begin
          `uvm_error("dmi_csr_flush_by_index_way_range_seq", "dmi_scb model not found")
        end
        if(!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                         .inst_name( "uvm_test_top.*" ),
                                         .field_name( "dmi_env_config" ),
                                         .value( m_cfg ))) begin
          `uvm_error("dmi_csr_flush_by_index_way_range_seq", "dmi_env_config handle not found")
        end

        assert(randomize(m_nSets))
        assert(randomize(m_nWays))

        if(dmi_scb.m_dmi_cache_q.size()>0) begin
          m_rand_index = $urandom_range(0, dmi_scb.m_dmi_cache_q.size()-1);
          `uvm_info("dmi_csr_flush_by_index_way_range_seq",$sformatf("index %d cache model q size %d",m_rand_index,
                                                               dmi_scb.m_dmi_cache_q.size()), UVM_NONE)
          m_nSets = dmi_scb.m_dmi_cache_q[m_rand_index].Index; 
          m_nWays = dmi_scb.m_dmi_cache_q[m_rand_index].way; 
        end 

        `uvm_info("dmi_csr_flush_by_index_way_range_seq",$sformatf("configuring m_nSets :%x,  m_nWays :%x ",m_nSets,m_nWays), UVM_NONE)

        //Poll the MntOp Active Bit
        do begin
          data = 0;
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
        end while(field_rd_data != data);

        wr_data = m_nSets;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntSet, wr_data);
        wr_data = m_nWays;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWay, wr_data);
        
        if(m_cfg.m_args.k_MNTOP_addr_range_max) begin
          wr_data = (<%=obj.DmiInfo[obj.Id].ccpParams.nSets%> * <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>);
        end
        else begin
          int limited_max = (cache_size/10 == 0) ? 5 : cache_size/10;
          wr_data = $urandom_range(1,limited_max);
        end
        `uvm_info(LABEL,$sformatf("Setting MntRange:%0d CacheSize:%0d MaxMode:%0b",wr_data,cache_size,m_cfg.m_args.k_MNTOP_addr_range_max), UVM_MEDIUM)
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR1.MntRange, wr_data);

        // ************************************************************************************
        //  Initiate and complete a Flush by set-way range operation (Proxy Cache Maintenance Control 
        //  Register and Proxy Cache Maintenance Activity Register).
        //  a. the "DMIUSMCMCR0.ArrayId" field is 0. This will flush the tag array
        // ************************************************************************************
        wr_data = {9'h0,1'h0,6'h0,12'h0,4'h8}; //MntOp = 'h8, ArrayID = 'h0
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,wr_data, .parent(this));

        //Poll the MntOp Active Bit
        do begin
          data = 0;
          read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
        end while(field_rd_data != data);
      end
      `uvm_info("RUN_MAIN", "Finished dmi_csr_flush_by_index_way_range_seq", UVM_MEDIUM)
    endtask
endclass : dmi_csr_flush_by_index_way_range_seq

//-----------------------------------------------------------------------
//  Class : dmi_csr_flush_by_index_way_seq
//  Purpose : To flush cache entries using index and way range
//-----------------------------------------------------------------------
class dmi_csr_flush_by_index_way_seq extends ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_flush_by_index_way_seq)

    dmi_scoreboard dmi_scb;
    int unsigned m_rand_index;

    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    rand bit [5:0]  m_nWord;
    int k_num_flush_cmd=1;
    string spkt;

   <% if (obj.useCmc){ %>
    constraint c_nSets  { m_nSets >= 0; m_nSets < <%=obj.DmiInfo[obj.Id].ccpParams.nSets%>;}
    constraint c_nWays  { m_nWays >= 0; m_nWays < <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>;}  
   <%}%>

    function new(string name="");
        super.new(name);
    endfunction

    task body();
       `uvm_info("body", "Entered...", UVM_MEDIUM)
       repeat(k_num_flush_cmd) begin
          #100ns;
          if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                                  .inst_name( "*" ),
                                                  .field_name( "dmi_scb" ),
                                                  .value( dmi_scb ))) begin
             `uvm_error("dmi_csr_flush_by_index_way_seq", "dmi_scb model not found")
          end

          assert(randomize(m_nSets))
          assert(randomize(m_nWays))

          if(dmi_scb.m_dmi_cache_q.size()>0) begin
              m_rand_index = $urandom_range(0, dmi_scb.m_dmi_cache_q.size()-1);
              `uvm_info("dmi_csr_flush_by_index_way_seq",$sformatf("index %d cache model q size %d",m_rand_index,
                                                                   dmi_scb.m_dmi_cache_q.size()), UVM_NONE)
              m_nSets = dmi_scb.m_dmi_cache_q[m_rand_index].Index; 
              m_nWays = dmi_scb.m_dmi_cache_q[m_rand_index].way; 
          end 

          `uvm_info("dmi_csr_flush_by_index_way_seq",$sformatf("configuring m_nSets :%x,  m_nWays :%x ",m_nSets,m_nWays), UVM_NONE)

          //Poll the MntOp Active Bit
          do begin
             data = 0;
             read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
          end while(field_rd_data != data);

          wr_data = m_nSets;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntSet, wr_data);
          wr_data = m_nWays;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMLR0.MntWay, wr_data);

          // ************************************************************************************
          //  Initiate and complete a Flush by set-way operation (Proxy Cache Maintenance Control 
          //  Register and Proxy Cache Maintenance Activity Register).
          //  a. the "DMIUSMCMCR0.ArrayId" field is 0. This will flush the tag array
          // ************************************************************************************
          wr_data   = 'h5;
          m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status, wr_data, .parent(this));

          //Poll the MntOp Active Bit
          do begin
             data = 0;
             read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
          end while(field_rd_data != data);
       end

       `uvm_info("body", "Exiting...", UVM_NONE)
    endtask
endclass : dmi_csr_flush_by_index_way_seq


//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Flushes complete cache
//-----------------------------------------------------------------------
class dmi_ccp_offline_seq extends ral_csr_base_seq;

    `uvm_object_utils(dmi_ccp_offline_seq)
    dmi_scoreboard dmi_scb;

    function new(string name="dmi_ccp_offline_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info("body", "Entered...", UVM_MEDIUM)
        #100us;
        if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                                .inst_name( "*" ),
                                                .field_name( "dmi_scb" ),
                                                .value( dmi_scb ))) begin
           `uvm_error("dmi_csr_offline_seq", "dmi_scb model not found")
        end
        uvm_report_info("dmi_ccp_offline_seq",$sformatf("setting fill en to 0"),UVM_NONE);
        // ************************************************************************************
        //  Clear the Proxy Cache Fill Enable bit (Proxy Cache Transaction Control Register)
        // ************************************************************************************
        //wr_data = 0;
        //write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCTCR.AllocEn, wr_data); // commented as per CONC-7184
        // ************************************************************************************
        //  Poll the Proxy Cache Fill Active bit (Proxy Cache Transaction Activity Register) 
        //  until clear
        // ************************************************************************************
        do begin
           data = 0;
           m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCTAR.read(status,field_rd_data,.parent(this));
        end while(field_rd_data != data);

        // Wait for MntOpActv to go low
        do begin
            data = 0;
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
        end while(field_rd_data != data);

        // ************************************************************************************
        //  Initiate and complete a Full cache flush operation (Proxy Cache Maintenance Control 
        //  Register and Proxy Cache Maintenance Activity Register).
        //  a. the "DMIUSMCMCR0.ArrayId" field is 0. This will flush the tag array
        // ************************************************************************************
        wr_data = {9'h0,1'h0,6'h0,12'h0,4'h4}; //MntOp = 'h4, ArrayID = 'h0
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMCR.write(status,wr_data, .parent(this));

        // Wait for MntOpActv to go low
        do begin
            data = 0;
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCMAR.MntOpActv, field_rd_data);
        end while(field_rd_data != data);

        // ************************************************************************************
        //  Poll the Proxy Cache Evict Active bit (Proxy Cache Transaction Activity Register) 
        //  until clear
        // ************************************************************************************
        do begin
           data = 0;
           m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCTAR.read(status,field_rd_data,.parent(this));
        end while(field_rd_data != data);

       //Poll the transaction activity register to ensure no transactions are pending in DMI
        do begin
           m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUTAR.read(status,field_rd_data,.parent(this));
        end while(field_rd_data != 0);
        `uvm_info("RUN_MAIN","DMIUTAR returns 0 indicating no active transactions in DMI",UVM_LOW)
        <%if(obj.useCmc){%>
        do begin
           m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCTAR.read(status,field_rd_data,.parent(this));
        end while(field_rd_data != 0);
        `uvm_info("RUN_MAIN","DMIUSMCTAR returns 0 indicating alloc and evictactv are low for SMC",UVM_LOW)
       <%}%>

        // ************************************************************************************
        //  Clear the Proxy Cache Lookup Enable bit (Proxy Cache Transaction Control Register)
        //  the main phase of the Master agent's dataflow Sequencer
        // ************************************************************************************
        wr_data = 0;
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSMCTCR.LookupEn, wr_data);
        dmi_scb.lookup_en = 0;
        dmi_scb.cov.cmc_policy[0] = 0;

        `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask: body
endclass : dmi_ccp_offline_seq 


//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Flushes cachelines via different types of flushes selected randomly
//-----------------------------------------------------------------------
class dmi_csr_rand_all_type_flush_seq extends ral_csr_base_seq; 

    dmi_scoreboard dmi_scb;
    dmi_env_config m_cfg;

    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    randc bit [3:0] mntop_cmd;

    apb_sequencer   m_apb_sequencer;

    constraint c_mntop_cmd { mntop_cmd inside {5,6,7,8};}

   <% if (obj.useCmc){ %>
    constraint c_nSets  { m_nSets >= 0; m_nSets < <%=obj.DmiInfo[obj.Id].ccpParams.nSets%>;}
    constraint c_nWays  { m_nWays >= 0; m_nWays < <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>;}  
   <%}%>
    string LABEL = "dmi_csr_rand_all_type_flush_seq";
    `uvm_object_utils(dmi_csr_rand_all_type_flush_seq)

    function new(string name="dmi_csr_rand_all_type_flush_seq");
      super.new(name);
    endfunction

    function get_cfg();
      if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                              .inst_name( get_full_name() ),
                                              .field_name( "dmi_scb" ),
                                              .value( dmi_scb ))) begin
         `uvm_error(LABEL, "dmi_scb model not found")
      end
      if(!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                       .inst_name( get_full_name() ),
                                       .field_name( "dmi_env_config" ),
                                       .value( m_cfg ))) begin
        `uvm_error(LABEL, "dmi_env_config handle not found")
      end
    endfunction

    task body();
       `uvm_info("RUN_MAIN", "Starting dmi_csr_rand_all_type_flush_seq", UVM_MEDIUM)
       get_cfg();
       for(int i=1; i <=5; i++) begin
          if (i == 5) begin
            mntop_cmd = 'h4; //CCP should go offline when all activity is concluded on not when transactions are in-flight
          end
          else begin
            randomize(mntop_cmd);
          end
          `uvm_info("rand_all_flush_seq",$sformatf("iteration:%0d mntop_cmd %d",i,mntop_cmd),UVM_MEDIUM)

          //If Flush By Index 
          if(mntop_cmd == 'h5) begin
              dmi_csr_flush_by_index_way_seq csr_seq = dmi_csr_flush_by_index_way_seq::type_id::create("csr_seq");
              csr_seq.model = this.model; 
              csr_seq.k_num_flush_cmd = $urandom_range(1,3); 
              csr_seq.start(m_apb_sequencer);
          //Else if Flush by Addr
          end else if(mntop_cmd == 'h6) begin
              dmi_csr_flush_by_addr_seq csr_seq = dmi_csr_flush_by_addr_seq::type_id::create("csr_seq");
              csr_seq.model = this.model; 
              csr_seq.k_num_flush_cmd = $urandom_range(1,3); 
              csr_seq.start(m_apb_sequencer);
          //Else if Flush by Addr Range
          end else if(mntop_cmd == 'h7) begin
              dmi_csr_flush_by_addr_range_seq csr_seq = dmi_csr_flush_by_addr_range_seq::type_id::create("csr_seq");
              csr_seq.model = this.model; 
              csr_seq.k_num_flush_cmd = $urandom_range(1,3); 
              csr_seq.start(m_apb_sequencer);
          //Else if Flush by Set-Way Range
          end else if(mntop_cmd == 'h8) begin
              dmi_csr_flush_by_index_way_range_seq csr_seq = dmi_csr_flush_by_index_way_range_seq::type_id::create("csr_seq");
              csr_seq.model = this.model;
              csr_seq.k_num_flush_cmd = $urandom_range(1,3);
              csr_seq.start(m_apb_sequencer);
          //Else flush all
          end else if(mntop_cmd == 'h4) begin
              dmi_ccp_offline_seq csr_seq = dmi_ccp_offline_seq::type_id::create("csr_seq");
              csr_seq.model = this.model; 
              csr_seq.start(m_apb_sequencer);
          end
          else begin
            `uvm_error("RUN_MAIN", $sformatf("mntop_cmd=%0h randomization error",mntop_cmd))
          end
       end
       `uvm_info("RUN_MAIN", "Finished dmi_csr_rand_all_type_flush_seq", UVM_MEDIUM)
    endtask
endclass : dmi_csr_rand_all_type_flush_seq

<%}%> // useCmc



//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
 * Abstract:
 * 
 * set up address translation based on number of DMI memory regions and
 * number of address translation registers
 * 
 */
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
<% if ((obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys")) { %>
<% if(obj.testBench == 'dmi') { %>
`ifndef VCS
typedef class addr_trans_mgr;
typedef class ncore_memory_map;
`endif
<% } else { %>
typedef class addr_trans_mgr;
typedef class ncore_memory_map;
<% } %>
<% } %>

class dmi_csr_addr_trans_seq extends dmi_ral_csr_base_seq; 
   `uvm_object_utils(dmi_csr_addr_trans_seq)
    string LABEL = "dmi_csr_addr_trans_seq";
    uvm_reg_data_t read_data;
    uvm_reg_data_t write_data;
    dmi_env_config m_cfg;
    <% if ((obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys")) { %>
    addr_trans_mgr      m_addr_mgr;
    ncoreConfigInfo::intq  iocoh_regq;
    <% } %>

    function new(string name="");
        super.new(name);
    endfunction

    task pre_body();
    <% if (obj.testBench == "fsys"|| obj.testBench == "emu" ) { %>
        $cast(m_regs,model);
    <% } %> 
    endtask

    task body();
    <% if ((obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys")) { %>
       int        nAddrTrans;
       bit [3:0]  transV;
       bit [3:0]  t_mask;
       bit [3:0]  mask[3:0];
       bit [31:0] addrTransV, addrTransFrom, addrTransTo;
       ncore_memory_map m_map;
       bit [ncoreConfigInfo::W_SEC_ADDR -1:0] lower_bound, upper_bound;

       if(!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                         .inst_name( get_full_name() ),
                                         .field_name( "dmi_env_config" ),
                                         .value( m_cfg ))) begin
        `uvm_error(LABEL, "dmi_env_config handle not found")
       end
       nAddrTrans = <%=obj.DmiInfo[obj.Id].nAddrTransRegisters%>;

       m_addr_mgr = addr_trans_mgr::get_instance();
       m_map      = m_addr_mgr.get_memory_map_instance();

       iocoh_regq = m_map.get_iocoh_mem_regions();
       `uvm_info("AddrTrans", $sformatf("No IOCOH regions=%0d", iocoh_regq.size()), UVM_HIGH)
       for (int i=0; i<iocoh_regq.size(); i++) begin                                                                                 
          m_addr_mgr.get_mem_region_bounds(iocoh_regq[i], lower_bound, upper_bound);
          `uvm_info("AddrTrans", $sformatf("region:%d, lb addr:%p, ub addr:%p", i, lower_bound, upper_bound), UVM_HIGH)
       end

       // has one translation at least
       if (!m_regs) begin
          `uvm_error($sformatf("%m"), $sformatf("m_regs is null"))
       end                                                                                         
       assert(std::randomize(t_mask));
       write_data = ($urandom_range(0,100) < 98);
       transV[0]  = (write_data > 0);
       write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER0.Valid, write_data);
       write_data = t_mask;
       mask[0]    = t_mask;
       write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER0.Mask, write_data);

       // For from address, in may cover only partially the memory region, controlled by mask
       m_addr_mgr.get_mem_region_bounds(iocoh_regq[0], lower_bound, upper_bound);
       write_data = (lower_bound >> 20) & 32'hffff_ffff;
       write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURFAR0.FromAddr, write_data);
       write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURTAR0.ToAddr, ~write_data);

       <% if (obj.DmiInfo[obj.Id].nAddrTransRegisters > 1) { %>
       if ( iocoh_regq.size() > 1 )begin
          assert(std::randomize(t_mask));
          write_data = ($urandom_range(0,100) < 98);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER1.Valid, write_data);
          transV[1]  = (write_data > 0);
          write_data = t_mask;
          mask[1]    = t_mask;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER1.Mask, write_data);

          // For from address, in may cover only partially the memory region, controlled by mask
          m_addr_mgr.get_mem_region_bounds(iocoh_regq[1], lower_bound, upper_bound);
          write_data = (lower_bound >> 20) & 32'hffff_ffff;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURFAR1.FromAddr, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURTAR1.ToAddr, ~write_data);
       end                                                       
       <% } %>

       <% if (obj.DmiInfo[obj.Id].nAddrTransRegisters > 2) { %>
       if ( iocoh_regq.size() > 2 )begin
          assert(std::randomize(t_mask));
          write_data = ($urandom_range(0,100) < 98);
          transV[2]  = (write_data > 0);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER2.Valid, write_data);
          write_data = t_mask;
          mask[2]    = t_mask;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER2.Mask, write_data);

          // For from address, in may cover only partially the memory region, controlled by mask
          m_addr_mgr.get_mem_region_bounds(iocoh_regq[2], lower_bound, upper_bound);
          write_data = (lower_bound >> 20) & 32'hffff_ffff;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURFAR2.FromAddr, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURTAR2.ToAddr, ~write_data);
       end                                                       
       <% } %>

       <% if (obj.DmiInfo[obj.Id].nAddrTransRegisters > 3) { %>
       if ( iocoh_regq.size() > 3 )begin
          assert(std::randomize(t_mask));
          write_data = ($urandom_range(0,100) < 98);
          transV[3]  = (write_data > 0);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER3.Valid, write_data);
          write_data = t_mask;
          mask[3]    = t_mask;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER3.Mask, write_data);

          // For from address, in may cover only partially the memory region, controlled by mask
          m_addr_mgr.get_mem_region_bounds(iocoh_regq[3], lower_bound, upper_bound);
          write_data = (lower_bound >> 20) & 32'hffff_ffff;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURFAR3.FromAddr, write_data);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURTAR3.ToAddr, ~write_data);
       end                                                    
       <% } %>

       // check the settings
       for ( int i=0; i<nAddrTrans; i++ ) begin
           if (i == 0) begin
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER0.Valid, read_data);
              addrTransV = read_data << 31;
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER0.Mask, read_data);
              addrTransV |= read_data;
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURFAR0.FromAddr, addrTransFrom);
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURTAR0.ToAddr, addrTransTo);

              dmi_scoreboard::addrTransV[0]     = addrTransV;
              dmi_scoreboard::addrTransFrom[0]  = addrTransFrom;
              dmi_scoreboard::addrTransTo[0]    = addrTransTo;
              dmi_seq::addrTransV[0]            = addrTransV;
              dmi_seq::addrTransFrom[0]         = addrTransFrom;
              dmi_seq::addrTransTo[0]           = addrTransTo;
           end
           <% if (obj.DmiInfo[obj.Id].nAddrTransRegisters > 1) { %>
           if (i == 1) begin
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER1.Valid, read_data);
              addrTransV = read_data << 31;
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER1.Mask, read_data);
              addrTransV |= read_data;
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURFAR1.FromAddr, addrTransFrom);
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURTAR1.ToAddr, addrTransTo);

              dmi_scoreboard::addrTransV[1]     = addrTransV;
              dmi_scoreboard::addrTransFrom[1]  = addrTransFrom;
              dmi_scoreboard::addrTransTo[1]    = addrTransTo;
              dmi_seq::addrTransV[1]            = addrTransV;
              dmi_seq::addrTransFrom[1]         = addrTransFrom;
              dmi_seq::addrTransTo[1]           = addrTransTo;

           end
           <% } %>
           <% if (obj.DmiInfo[obj.Id].nAddrTransRegisters > 2) { %>                                                                                                   
           if (i == 2) begin
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER2.Valid, read_data);
              addrTransV  = read_data << 31;
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER2.Mask, read_data);
              addrTransV |= read_data;
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURFAR2.FromAddr, addrTransFrom);
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURTAR2.ToAddr, addrTransTo);

              dmi_scoreboard::addrTransV[2]     = addrTransV;
              dmi_scoreboard::addrTransFrom[2]  = addrTransFrom;
              dmi_scoreboard::addrTransTo[2]    = addrTransTo;
              dmi_seq::addrTransV[2]            = addrTransV;
              dmi_seq::addrTransFrom[2]         = addrTransFrom;
              dmi_seq::addrTransTo[2]           = addrTransTo;

           end
           <% } %>
           <% if (obj.DmiInfo[obj.Id].nAddrTransRegisters > 2) { %>                                                                                                   
           if (i == 3) begin
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER3.Valid, read_data);
              addrTransV = read_data << 31;
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUATER3.Mask, read_data);
              addrTransV |= read_data;
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURFAR3.FromAddr, addrTransFrom);
              read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIURTAR3.ToAddr, addrTransTo);

              dmi_scoreboard::addrTransV[3]     = addrTransV;
              dmi_scoreboard::addrTransFrom[3]  = addrTransFrom;
              dmi_scoreboard::addrTransTo[3]    = addrTransTo;
              dmi_seq::addrTransV[3]            = addrTransV;
              dmi_seq::addrTransFrom[3]         = addrTransFrom;
              dmi_seq::addrTransTo[3]           = addrTransTo;

           end
           <% } %>
           if(m_cfg.EN_DMI_VSEQ) begin
             m_cfg.m_rsrc_mgr.addrTransV[i] = addrTransV;
             m_cfg.m_rsrc_mgr.addrTransFrom[i] = addrTransFrom;
             m_cfg.m_rsrc_mgr.addrTransTo[i] = addrTransTo;
           end
           if ( i < iocoh_regq.size() )  begin
              m_addr_mgr.get_mem_region_bounds(iocoh_regq[i], lower_bound, upper_bound);
              if (addrTransV != ((transV[i]<<31) | mask[i])) begin
                 `uvm_error($sformatf("%m"), $sformatf("DMIUATER%0d not match wrote=%0h read=%0h", i, (transV[i]<<31)|mask[i], addrTransV))
              end
              if (addrTransFrom != ((lower_bound >> 20) & 32'hffff_ffff)) begin
                 `uvm_error($sformatf("%m"), $sformatf("DMIURFARAx not match wrote=%0h read=%0h", (lower_bound >> 20) & 32'hffff_ffff, addrTransFrom))
              end
              if (addrTransTo != ((~(lower_bound >> 20)) & 32'hffff_ffff)) begin
                 `uvm_error($sformatf("%m"), $sformatf("DMIURTARAx not match wrote=%0h read=%0h", (~(lower_bound >> 20)) & 32'hffff_ffff, addrTransTo))
              end
           end else begin
              if ((addrTransV > 31) == 1) begin
                 `uvm_error($sformatf("%m"), $sformatf("DIUATERx Valid is set for i=%0d", i))
              end
           end
       end
       
    <% } %>
    endtask
endclass : dmi_csr_addr_trans_seq

class res_corr_err_threshold_seq extends ral_csr_base_seq; 
   `uvm_object_utils(res_corr_err_threshold_seq)

    uvm_reg_data_t write_data, read_data;
    uvm_status_e   status;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      <% if(obj.useResiliency) { %>
      if(!$value$plusargs("res_corr_err_threshold=%0d", write_data)) begin
        write_data = $urandom_range(5,50);
      end
      `uvm_info(get_name(), $sformatf("Writing DMIUCRTR res_corr_err_threshold = %0d", write_data), UVM_NONE)
      write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUCRTR.ResThreshold, write_data);
      <% } %>
    endtask

endclass : res_corr_err_threshold_seq

/**********************************************************/
// Abstract : Sequence to program the DMIUTQOSCR register
/**********************************************************/

class dmi_csr_qos_ctrl_reg_seq extends ral_csr_base_seq;

  `uvm_object_utils(dmi_csr_qos_ctrl_reg_seq)
  dmi_scoreboard  dmi_scb;
  uvm_reg_data_t  write_data, read_data;
  uvm_status_e    status;
  dmi_env_config  m_cfg;
  rand bit [7:0]  dmi_wtt_qos_rsv;
  rand bit [7:0]  dmi_rtt_qos_rsv;
  rand bit [3:0]  dmi_qos_th_val;
  bit [31:0] mask;
  int pgm_idx = 0;
  //Stimulus.DMI.QosRsvMax
  int wtt_qos_rsv_max; 
  int rtt_qos_rsv_max = (<%=obj.DmiInfo[obj.Id].cmpInfo.nRttCtrlEntries%> > 33) ? 32 : (<%=obj.DmiInfo[obj.Id].cmpInfo.nRttCtrlEntries%> - 1);

  function new(string name="");
    super.new(name);
  endfunction: new

  // Function to return the minimum of the 3 parameters {nWttCtrlEntries, nDmiRbEntries, nDceRbEntries} 
  // compared with the default Max value of nDmiWttQoSRsv=32.
  function int wtt_max();
    int wtt_qos_rsv = 33;

    if(<%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries%> < wtt_qos_rsv)
       wtt_qos_rsv = <%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries%>;
    if(<%=obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries%> < wtt_qos_rsv)
       wtt_qos_rsv = <%=obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries%>;
    if(<%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%> < wtt_qos_rsv)
       wtt_qos_rsv = <%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%>;

    wtt_max = wtt_qos_rsv - 1;
  endfunction: wtt_max
  //#Check.DMI.QosReset
  task body();
   <% if(obj.DmiInfo[obj.Id].fnEnableQos) { %>
    if (!uvm_config_db#(dmi_scoreboard)::get(.cntxt( null ),
                                        .inst_name( "*" ),
                                        .field_name( "dmi_scb" ),
                                        .value( dmi_scb ))) begin
       `uvm_error("dmi_csr_qos_ctrl_reg_seq", "dmi_scb model not found")
    end
    if (!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                     .inst_name( get_full_name() ),
                                     .field_name( "dmi_env_config" ),
                                     .value( m_cfg ))) begin
       `uvm_error("dmi_csr_time_out_error_seq", "dmi_env_config handle not found")
    end
    mask = 32'hF000FFFF; // Bits [27:16] are reserved fields in the DMIUTQOSCR register

    wtt_qos_rsv_max = wtt_max();
    //#Stimulus.DMI.QosRegRand
    //#Stimulus.DMI.QosSmiRand
    //#Stimulus.DMI.QosRsvMin
    pgm_idx = (m_cfg.qos_mode== QOS_UPDATE) ? 1 : 0;
    if(!$value$plusargs("k_dmi_qos_th_val=%0d", dmi_qos_th_val)) begin
      dmi_qos_th_val = m_cfg.dmi_qos_th_val[pgm_idx];
    end
    //#Stimulus.DMI.QosRsvMax
    if(!$value$plusargs("k_dmi_wtt_qos_rsv=%0d", dmi_wtt_qos_rsv)) begin
      dmi_wtt_qos_rsv = $test$plusargs("k_dmi_wtt_qos_rsv_max") ? wtt_qos_rsv_max : m_cfg.wtt_qos_rsv_val[pgm_idx];
    end
    if(!$value$plusargs("k_dmi_rtt_qos_rsv=%0d", dmi_rtt_qos_rsv)) begin
      dmi_rtt_qos_rsv = $test$plusargs("k_dmi_rtt_qos_rsv_max") ? rtt_qos_rsv_max : m_cfg.rtt_qos_rsv_val[pgm_idx];
    end

    write_data = {dmi_qos_th_val, 12'h000, dmi_rtt_qos_rsv, dmi_wtt_qos_rsv};

    `uvm_info(get_name(), $sformatf("Writing DMIUTQOSCR Register = %0x", write_data), UVM_NONE)
    m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUTQOSCR0.write(status,write_data,.parent(this));

    `uvm_info(get_name(), $sformatf("Reading DMIUTQOSCR Register"), UVM_NONE)
    m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUTQOSCR0.read(status,read_data,.parent(this));
    `uvm_info(get_name(), $sformatf("DMIUTQOSCR Read Data = %0x", read_data), UVM_NONE)

    if((read_data & mask) != write_data) begin
      `uvm_error(get_name(), $sformatf("Mismatch in DMIUTQOSCR Register. Write_data : %0x, Read data : %0x", write_data, (read_data & mask)))
    end
    else begin
      dmi_scb.cov.collect_dmiutqoscr_reg_cov(dmi_wtt_qos_rsv, dmi_rtt_qos_rsv, dmi_qos_th_val);
    end
   <% } %>
  endtask
endclass : dmi_csr_qos_ctrl_reg_seq

class dmi_csr_sys_event_seq extends dmi_ral_csr_base_seq; 
  `uvm_object_utils(dmi_csr_sys_event_seq)


  function new(string name="");
    super.new(name);
  endfunction

  task body();
    getCsrProbeIf();
    fork
      // program Error Related registers when timeout is enabled
      begin
        //FIXME Disable events until implementing Dv updates for event messaging feature 
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUTCR.EventDisable, 1'b1); // Disable events
      end
    join
  endtask
endclass : dmi_csr_sys_event_seq

class dmi_csr_poll_error_status_seq extends dmi_ral_csr_base_seq;
  bit done = 0;
  bit check_for_interrupt = 0;
  int timeout = 5000;
  int reset_timeout = 1000;
  dmi_env_config m_env_cfg;
  uvm_reg_data_t read_data,err_vld, err_type, err_info,timeout_threshold;
  uvm_reg_data_t exp_err_type, exp_err_info;
  uvm_status_e status;
  uvm_event ev_uesr_error = ev_pool.get("ev_uesr_error");
  
  `uvm_object_utils_begin(dmi_csr_poll_error_status_seq)

  `uvm_object_utils_end
  function new(string name="");
    super.new(name);
  endfunction

  task body();
    getCsrProbeIf();
    if(!$value$plusargs("uesr_errtype=%0h",exp_err_type))
     `uvm_error( "dmi_csr_poll_error_status_seq", "Failed to set expected error type, check your test arguments")

    if(!$value$plusargs("uesr_errinfo=%0h",exp_err_info))
     `uvm_error( "dmi_csr_poll_error_status_seq", "Failed to set expected error type, check your test arguments")

    if (!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                             .inst_name( get_full_name() ),
                                             .field_name( "dmi_env_config" ),
                                             .value( m_env_cfg ))) begin
     `uvm_error("dmi_csr_time_out_error_seq", "dmi_env_config handle not found")
    end

    `uvm_info("dmi_csr_poll_error_status_seq", $sformatf("Expected values set | ErrType:%0h ErrInfo:%0h", exp_err_type, exp_err_info),UVM_LOW)
    case(exp_err_type)
      4'hC:
        write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.SoftwareProgConfigErrDetEn, 1'b1);
      4'hA: 
        begin
          timeout = 50000;
          check_for_interrupt = 1;
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.TimeoutErrDetEn, 1'b1);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.TimeoutErrIntEn, 1'b1);
          write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUSEPTOCR.TimeOutThreshold, timeout_threshold);
        end
      default:
        m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.write(status, 7'h7F);
    endcase
    
    do begin
      read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, err_vld);
      if(err_vld) begin
        `uvm_info("dmi_csr_poll_error_status_seq", $sformatf("Error Valid Set"),UVM_LOW)
        if(check_for_interrupt)begin
          fork
          begin
              wait (u_csr_probe_vif.IRQ_UC === 1);
          end
          begin
            #200000ns;
            `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
          end
          join_any
          disable fork;
        end
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrType, err_type);
        `uvm_info("dmi_csr_poll_error_status_seq", $sformatf("Error Type %0h", err_type),UVM_LOW)
        read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrInfo, err_info);
        `uvm_info("dmi_csr_poll_error_status_seq", $sformatf("Error Info %0h", err_info),UVM_LOW)
        if((err_type == exp_err_type)&& (err_info == exp_err_info)) begin
          ev_uesr_error.trigger();
          `uvm_info("dmi_csr_poll_error_status_seq", $sformatf("Triggering Timeout Error Event. Received Type:0x%0h Info:0x%0h", err_type, err_info),UVM_LOW)
          if(check_for_interrupt) begin
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, err_vld);
            compareValues("DMIUUESR_ErrVld", "set after interrupt", err_vld, 1);
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEDR.TimeoutErrDetEn, 0);
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUEIR.TimeoutErrIntEn, 0);
          end
          do begin
            // write DMIUUESR_ErrVld = 1 to clear it
            write_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, 1);
            // Read DMIUUESR_ErrVld , it should be 0
            read_csr(m_regs.<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>.DMIUUESR.ErrVld, err_vld);
            reset_timeout--;
          end while(err_vld && (reset_timeout!=0));
          if((reset_timeout == 0) && err_vld) begin
            `uvm_info("dmi_csr_poll_error_status_seq","Failed to reset DMIUUESR.ErrVld", UVM_LOW)
          end
          compareValues("DMIUUESR_ErrVld", "reset", err_vld, 0);
          done = 1;
        end
        else begin
          `uvm_warning("dmi_csr_poll_error_status_seq", $sformatf("UESR register read status | ErrType: [Exp:0x%0h Rcvd:0x%0h] ErrInfo: [Exp:0x%0h Rcvd:0x%0h]", exp_err_type, err_type, exp_err_info, err_info))
        end
      end
      #10us;
      timeout--;
    end while(!done && (timeout != 0));

  endtask
endclass
