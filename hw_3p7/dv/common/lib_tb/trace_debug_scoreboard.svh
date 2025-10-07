///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// File         :   trace_debug_scoreboard.svh                               //
// Description  :   Trace Capture checker                                    //
// Revision     :   1.1   (Beta3.3)                                          //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////
typedef class trace_debug_scb;

import uvm_pkg::*;
`include "uvm_macros.svh"

const int TX = 0;                     // Used as direction
const int RX = 1;                     // Used as direction

localparam DTWSIZE    = 512;          // DTW size in bits
localparam TStampSize = 32;           // TimeStamp size in bits

typedef struct {
<% if(obj.testBench == 'dii') { %>
`ifndef CDNS
     bit [DTWSIZE-1:0] dtwMsg = {default:0};
`else // `ifndef CDNS
     bit [DTWSIZE-1:0] dtwMsg = '{default:'0};
`endif // `ifndef CDNS
<% } else {%>
     bit [DTWSIZE-1:0] dtwMsg = {default:0};
<% } %>
     int dtwPos=0;
   } dtwInfo;

   // Global variables
   int numMsgDropped   = 0;            // Total DTW Msgs dropped
   int numMsgProcess   = 0;            // Total DTW Msgs processed
   int numMsgRegister  = 0;            // Total DTW Msgs registered
   int numDtwProcess   = 0;            // Total DTWs processed
   int numMsgSeen      = 0;            // Total Number of Msgs encountered
   int numDtwRspSeen   = 0;            // Total Number of DtwDbgRsp encountered
   int frcModified     = 0;            // It indicates the user has altered the Free-Running-Counter
   int cctrlr_mod      = 0;            // Help determine if the user intends to modify CCTRLR
   int numMsgMissAllow = 0;            // Number of Msgs miss allowed when the user modifies CCTRLR
   int numMsgDropAllow = 4;            // Number of Msgs drop allowed when the user modifies CCTRLR
   int tStampChk       = 1000;         // Check TimeStamp every 1000 sgs processed

   int numMsgProcess_sent = 0;        // Total DTW Msgs registered sent to Perf Mon SB 
   
   //-----------------------
   // Ports declaration
   //-----------------------
   <% for (var i=0; i<obj.nSmiRx; i++) { %>
   `uvm_analysis_imp_decl (_smi<%=i%>_rx_port)
   <% } %>
   <% for (var i=0; i<obj.nSmiTx; i++) { %>
   `uvm_analysis_imp_decl (_smi<%=i%>_tx_port)
   <% } %>

   `uvm_analysis_imp_decl (_smi_dntx_ndp_only_port)
   `uvm_analysis_imp_decl (_smi_dnrx_ndp_only_port)

class trace_debug_scb extends uvm_scoreboard;

   `uvm_component_param_utils(trace_debug_scb)

   //-----------------------
   // Ports initialization
   //-----------------------
   <% for (var i=0; i<obj.nSmiRx; i++) { %>
   uvm_analysis_imp_smi<%=i%>_rx_port #(smi_seq_item, trace_debug_scb) analysis_smi<%=i%>_rx_port;
   <% } %>
   <% for (var i=0; i<obj.nSmiTx; i++) { %>
   uvm_analysis_imp_smi<%=i%>_tx_port #(smi_seq_item, trace_debug_scb) analysis_smi<%=i%>_tx_port;
   <% } %>
   uvm_analysis_imp_smi_dntx_ndp_only_port #(smi_seq_item, trace_debug_scb) analysis_smi_dntx_ndp_only_port;
   uvm_analysis_imp_smi_dnrx_ndp_only_port #(smi_seq_item, trace_debug_scb) analysis_smi_dnrx_ndp_only_port;

   // Accessing CCTRLR register
   <% if(obj.testBench =='dmi'){ %>
   bit [7:0]   port_capture_en;
   bit [3:0]   gain;
   bit [11:0]  inc;
   <% } else {%>
   static bit [9:0]   port_capture_en;
   static bit [3:0]   gain;
   static bit [11:0]  inc;
   <% } %>

   // Performance monitor Interface
   virtual <%=obj.BlockId%>_stall_if stall_if;

   // Unsynthesized RTL registers
   static int         checkRtlRegCount;
   static int         captured_count;
   static int         dtwdbg_count;
   static int         dropped_count;
 
   // TimeStamp clock and cm_status field from the concerto MUX.
   static int         tsClock;
   static bit [31:0]  frCounter;
   static int         frcAlterAndWrap;

   // Queues for coming SMI packets
   //------------------------------------------
   // smi_seq_item  smi[0-obj.nSmiRx]_rx_q[$]; 
   //------------------------------------------
   <% for (var i=0; i<obj.nSmiRx; i++) { %>
   smi_seq_item  smi<%=i%>_rx_q[$]; 
   <% } %>

   //------------------------------------------
   // smi_seq_item  smi[0-obj.nSmiTx]_tx_q[$]; 
   //------------------------------------------
   <% for (var i=0; i<obj.nSmiTx; i++) { %>
   smi_seq_item  smi<%=i%>_tx_q[$]; 
   <% } %>

   // Queues to hold concerto msg built
   //------------------------------------------
   // bit[DTWSIZE-1:0]  my_smi[0-obj.nSmiRx]_rx_q[$]; 
   //------------------------------------------
   <% for (var i=0; i<obj.nSmiRx; i++) { %>
   bit[DTWSIZE-1:0] my_smi<%=i%>_rx_q[$];
   <% } %>

   <% for (var i=0; i<obj.nSmiTx; i++) { %>
   bit[DTWSIZE-1:0] my_smi<%=i%>_tx_q[$];
   <% } %>

   <% for (var i=0; i<obj.nSmiRx; i++) { %>
   dtwInfo gatherDTWdataRx<%=i%>;
   <% } %>

   <% for (var i=0; i<obj.nSmiTx; i++) { %>
   dtwInfo gatherDTWdataTx<%=i%>;
   <% } %>

   bit [31:0] tStamp_q[$];

   // <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
   // <><><><><><><><><> Functional Coverage for All Request Transactions <><><><><><><><><> 
   bit [31:0] tcapReg;
   bit [31:0] frcReg;
   bit [7:0] DmiReq;  
   bit [7:0] DiiReq;  
   bit [8:0] CaiuReq;  
   bit [8:0] IoaiuReq;  
   bit [8:0] DvmNCaiuReq;  
   string tBench  ="<%=obj.testBench%>";

   
   `ifndef FSYS_COVER_ON
   covergroup tcapCov;
    // #Cover.IOAIU.TCAP.CCTRLR.enables
    //#Cover.CHIAIU.TCAP.CCTRLR.enables
   //#Cover.DII.TCAP.CCTRLR.enables
   //#Check.IOAIU.TCAP.DTWDebugReq_RX
   //#Check.IOAIU.TCAP.DTWDebugReq_TX2
   //#Check.IOAIU.TCAP.DTWDebugReq_nonzero
   //#Check.IOAIU.TCAP.Num_SMI_ports
   //#Check.IOAIU.TCAP.Padding
   //#Check.IOAIU.TCAP.TraceMessage_not_found
     coverport : coverpoint tcapReg[7:0] {
       bins covPort0 = {1};     // TX[0] Port 
       bins covPort1 = {2};     // RX[0] Port 
       bins covPort2 = {4};     // TX[1] Port
       bins covPort3 = {8};     // RX[1] Port
       bins covPort4 = {16};    // TX[2] Port
       bins covPort5 = {32};    // RX[2] Port

    <% if(obj.Block =='dmi') { %>
       bins covPort6 = {64};    // TX[3] Port
       bins covPort7 = {128};   // RX[3] Port
    <% } %>
     }

    // #Cover.IOAIU.TCAP.CCTRLR.gain
    //#Cover.CHIAIU.TCAP.CCTRLR.gain
    //#Cover.DII.TCAP.CCTRLR.gain
     covergain : coverpoint tcapReg[19:16] { 
       bins covGain[] = {[0:$]};                 // Total of 16 bins.
     }   

    // #Cover.IOAIU.TCAP.CCTRLR.incr
    //#Cover.CHIAIU.TCAP.CCTRLR.incr
    //#Cover.DII.TCAP.CCTRLR.incr
     coverinc : coverpoint tcapReg[31:20] {
       bins incCov[] = {1,2,4,8,16,32,64,128,256,512,1024,2048}; 
     }
   endgroup : tcapCov

  <% if(obj.Block =='dmi') { %>
       covergroup frcCov;
       //---------------------------------------------------------------
       // Statement has been added for config7_snps0, as "assert_on"
       // has been defined FALSE, but TRUE for all the other DMI configs
       // Thus, no coverage will be collected for config7_snps0.
    <% if (obj.assertOn) { %>
       frcUpper : coverpoint frcReg[31:31] { 
           bins frcAlter = {1} iff (frcAlterAndWrap==1);   // FRC altered not yet wrapped around
           bins frcWrap  = {1} iff (frcAlterAndWrap==2);   // FRC wrapped around
       }
    <% } %>
       endgroup : frcCov
  <% } %>

   covergroup ConcReqCov;
  <% if(obj.Block =='dmi') { %>     
     Dmi_TmConcReq : coverpoint DmiReq[7:0] {
       bins dmiStrReq   = {8'h7A}; 
       bins dmiCmdReq   = {8'h2B};  // CmdReq range[8'h01:8'h2B]
       bins dmiRbrReq   = {8'h7C};
       bins dmiMrdReq   = {8'h68};  // MrdReq range[8'h60:8'h68] and
       bins dmiDtrReq   = {8'h80};
       bins dmiDtwReq   = {8'h9C};  // DtwReq range[8'h90:8'h93 and 8'h98:8'h9C]
     }
  <% } %>

  <% if(obj.Block =='dii') { %>     
     Dii_TmConcReq : coverpoint DiiReq[7:0] {
       bins diiStrReq   = {8'h7A}; 
       bins diiCmdReq   = {8'h2B};  // CmdReq range[8'h01:8'h2B]
       bins diiDtrReq   = {8'h80};
       bins diiDtwReq   = {8'h9C};  // DtwReq range[8'h90:8'h93 and 8'h98:8'h9C]
     }
  <% } %>

  <% if(obj.Block =='chi_aiu') { %>     
     Ciau_TmConcReq : coverpoint CaiuReq[8:0] {
       bins caiuStrReq   = {8'h7A}; 
       bins caiuCmdReq   = {8'h2B};  // CmdReq range[8'h01:8'h2B]

       ignore_bins caiuSysReqT  = {8'h7B};   // not supported in 3.2
       ignore_bins caiuSysReqR  = {9'h17B};  // not supported in 3.2

       bins caiuSnpReq   = {8'h51};  // SnpReq range[8'h41:8'h51]
       bins caiuDtrReqT  = {8'h80};  // Tx DtrReq range[8'h80:8'h84]
       bins caiuDtrReqR  = {9'h180}; // Rx DtrReq range[8'h80:8'h84]
       bins caiuDtwReq   = {8'h9C};  // DtwReq range[8'h90:8'h93 and 8'h98:8'h9C]
     }
  <% } %>

  <% if(obj.Block =='io_aiu') { %>     
     Ioaiu_TmConcReq : coverpoint IoaiuReq[8:0] {
       bins ioaiuStrReq   = {8'h7A}; 
       bins ioaiuCmdReq   = {8'h2B};  // CmdReq range[8'h01:8'h2B]

       ignore_bins ioaiuSysReqT  = {8'h7B};  // not supported in 3.2
       ignore_bins ioaiuSysReqR  = {9'h17B}; // not supported in 3.2

       <%if((obj.fnNativeInterface != "ACE-LITE") && (obj.fnNativeInterface !== "AXI4") && (obj.fnNativeInterface !== "AXI5")){ %>
       bins ioaiuDtrReqT  = {8'h80};  // Tx DtrReq range[8'h80:8'h84]
       bins ioaiuSnpReq   = {8'h51};  // SnpReq range[8'h41:8'h51]
       <%}%>
       bins ioaiuDtrReqR  = {9'h180}; // Rx DtrReq range[8'h80:8'h84]
       bins ioaiuDtwReq   = {8'h9C};  // DtwReq range[8'h90:8'h93 and 8'h98:8'h9C]
     }
  <% } %>

   endgroup : ConcReqCov
   `endif // FSYS_COVER_ON
   //-----------------------------------------------------
   // NEW Function:
   //-----------------------------------------------------
   function new(string name="trace_debug_scb", uvm_component parent=null);
      super.new(name,parent);

      // Those parms control the following::
      //  1._ Allow the user to add his/her own TimeStamp check value.
      //  2._ User has the capability to modify the current value of the
      //      FRC (Free Running Counter). Meaning intended to test Wrapping 
      $value$plusargs("tStampChk=%d",tStampChk);
      $value$plusargs("frcModified=%d",frcModified);
      $value$plusargs("cctrlr_mod=%d",cctrlr_mod);

    `ifndef FSYS_COVER_ON
    <% if(obj.Block =='dmi') { %>     
      frcCov = new();     // Instance created for FCOV
   <% } %>

      tcapCov = new();    // Instance created for FCOV
      ConcReqCov = new(); // Instance created for FCOV,
      `endif
      `uvm_info("NEW", {"HXP -- This is Trace_Capture: ", get_full_name()}, UVM_NONE)
   endfunction: new

    //-----------------------------------------------------
    // BUILD Phase::
    //-----------------------------------------------------
    function void build_phase(uvm_phase phase);
       super.build_phase(phase);

    <% for (var i=0; i<obj.nSmiRx; i++) { %>
       analysis_smi<%=i%>_rx_port      = new("analysis_smi<%=i%>_rx_port", this);
    <% } %>

    <% for (var i=0; i<obj.nSmiTx; i++) { %>
       analysis_smi<%=i%>_tx_port      = new("analysis_smi<%=i%>_tx_port", this);
    <% } %>

       analysis_smi_dntx_ndp_only_port = new("analysis_smi_dntx_ndp_only_port", this);
       analysis_smi_dnrx_ndp_only_port = new("analysis_smi_dnrx_ndp_only_port", this);

      // Bound Interface
      <% if (obj.testBench != "emu" && obj.testBench != "fsys") { %>
         <% if (obj.Block =='io_aiu') { %>     
            if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_0_m_top_stall_if_0", stall_if)) begin
         <%} else if (obj.Block =='chi_aiu') { %>     
            if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_0_m_top_stall_if", stall_if)) begin
         <%} else { %>
            if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_m_top_stall_if", stall_if)) begin
         <% } %>
            `uvm_fatal("Stall interface error", "virtual interface must be set for stall_if");
         end
      <% } else if(obj.testBench === "fsys"){%>
         <% if (obj.Block =='io_aiu') { %>     
         if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_0_m_top_stall_if_0", stall_if)) begin
         <%} else if (obj.Block =='chi_aiu') { %>     
         if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_0_m_top_stall_if", stall_if)) begin
         <%} else { %>
         if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_m_top_stall_if", stall_if)) begin
         <% } %>
            `uvm_fatal("Stall interface error", "virtual interface must be set for stall_if");
         end
      <%}%>
 
 
    endfunction: build_phase

    // Write functions based on the defined PORTs above
    <% for (var i=0; i<obj.nSmiRx; i++) { %>
    extern function void write_smi<%=i%>_rx_port      (const ref smi_seq_item         smiPkt) ;
    <% } %>

    <% for (var i=0; i<obj.nSmiTx; i++) { %>
    extern function void write_smi<%=i%>_tx_port      (const ref smi_seq_item         smiPkt) ;
    <% } %>

    extern function void write_smi_dntx_ndp_only_port(const ref smi_seq_item smiPkt);
    extern function void write_smi_dnrx_ndp_only_port(const ref smi_seq_item smiPkt);
    extern task run_phase(uvm_phase phase);
    extern function int calculateMsgLength(int mlen);
    extern function bit [11:0] covHighestBitSet4Inc();
    extern function void covConcTransType(int smiDir, bit [7:0] msg_type);
    extern function bit [DTWSIZE-1:0] calculateMSG(smi_seq_item mpkt,int msgNum);
    extern function int portCaptureValid(int smiDir, int numSmiPort, int portNum);
    extern function void perfmon_captured_dropped_packets();

    //-----------------------------------------------------
    // CHECK Phase::
    // Display function is used over UVM_INFO simply for
    // readability reason. Feel free to remove it, if it
    // doesn't suit your need. 
    //-----------------------------------------------------
   function void check_phase(uvm_phase phase);
     int tstamp_val0;
     int tstamp_val1;

     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>"), UVM_NONE)
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- Here is the simulation Status that one might be interested in. "), UVM_NONE)
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>"), UVM_NONE)
<% for (var i=0; i<obj.nSmiRx; i++) { %>
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- my_smi<%=i%>_tx_q = %0d", my_smi<%=i%>_tx_q.size()), UVM_NONE)
<% } %>

<% for (var i=0; i<obj.nSmiTx; i++) { %>
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- my_smi<%=i%>_rx_q = %0d", my_smi<%=i%>_rx_q.size()), UVM_NONE)
<% } %>

     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- <><><><><><><><><><>    DV  Final Values.   <><><><><><><><><><>"), UVM_NONE)
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- Number of MSGs successfully processed  ---------------->  %0d",numMsgProcess), UVM_NONE)
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- Number of DtwDbgReq command processed  ---------------->  %0d",numDtwProcess), UVM_NONE)
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- Number of MSGs suspected dropped       ---------------->  %0d",numMsgRegister-numMsgProcess), UVM_NONE)
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- <><><><><><><><><><>    RTL Final Values.   <><><><><><><><><><>"), UVM_NONE)
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- Number of MSGs successfully processed  ---------------->  %0d",captured_count), UVM_NONE)
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- Number of DtwDbgReq command processed  ---------------->  %0d",dtwdbg_count), UVM_NONE)
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- Number of MSGs suspected dropped       ---------------->  %0d",dropped_count), UVM_NONE)
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>"), UVM_NONE)
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- Total MSGs encountered regardless of TM-bit setting --->  %0d",numMsgSeen), UVM_NONE)
     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- TimeStamp was checked after processing every [%0d] Message(s)...",tStampChk), UVM_NONE)
     
     // There are couple things to know about this check
     // 1._ This is for the TimeStamp wrap around check.
     // 2._  "     "   only exist on DMI unit environment
     // 3._ frcModified is a parm that is controlled by the user. 
     if(frcModified) begin
        if (frcAlterAndWrap==1)
          `uvm_error(get_name(), $psprintf("TCAP_STATUS --- TimeStamp was altered by the user, but it has not wrapped around as expected.."))
        if (frcAlterAndWrap==2)
          `uvm_info(get_name(), $psprintf("TCAP_STATUS --- TimeStamp was altered by the user and successfully wrapped around.."), UVM_NONE)
     end
   
     // Number of DtwDbgReq processed need to match the DtwDbgRsp encountered. 
     // Should be uncommented for the future Revision...`
     // Only meaningful, if running at full_sys.
     if ((numDtwProcess != numDtwRspSeen) && (tBench=="fsys"))  
          `uvm_error(get_name(), $psprintf("TCAP_STATUS: --- Number of DtwDbgReq=%0d fails to match  DtwDbgRsp=%0d... for BlockID:: <%=obj.Block%>...",numDtwProcess,numDtwRspSeen)) 

     // There are couple things to know about this check
     // 1._ This check won't occur if Assertion is disable
     // 2._  "     "   only exist on DMI unit environment
     // 3._ checkRtlRegCount flag is set through dv/dmi/tb/dmi_tb_top.sv 
     if (checkRtlRegCount == 1) begin
        `uvm_info(get_name(), $psprintf("TCAP_STATUS --- <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>"), UVM_NONE)
        if (numDtwProcess != dtwdbg_count)
           `uvm_error(get_name(), $psprintf("TCAP_STATUS: --- RTL and DV mismatch on the number of DTWs processed:: RTL=%0d  vs DV=%0d",dtwdbg_count,numDtwProcess)) 

        // Error Case:::
        // DV and RTL might not  be consistent as far as messages being processed
        // when CCTRLR got altered during simulation, specially on the RX side.
        // To prevent fault fails, we set the threshold Miss/Drop to 4... 
        if (cctrlr_mod==1) begin 
            if (((numMsgRegister-numMsgProcess)-dropped_count) > numMsgDropAllow) 
              `uvm_error(get_name(), $psprintf("TCAP_STATUS: --- RTL and DV mismatch on the number of MSGs dropped with tolerance %0d:: RTL=%0d  vs DV=%0d",numMsgDropAllow,dropped_count,numMsgRegister-numMsgProcess)) 

              `uvm_warning(get_name(), $psprintf("TCAP_STATUS: --- User is resetting CCTRLR in the middle of simulation. As the diff between RTL drops and DV drops is less than 5.. no errors will be reported."))
        end

        if (numMsgProcess != captured_count) 
           `uvm_error(get_name(), $psprintf("TCAP_STATUS: --- RTL and DV mismatch on the number of MSGs processed:: RTL=%0d  vs DV=%0d",captured_count,numMsgProcess)) 
     end

     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>"), UVM_NONE)

     `uvm_info(get_name(), $psprintf("TCAP_STATUS --- TimeStamps collected during simulation: --------------->  %0p",tStamp_q), UVM_NONE)
        
     // -----------------------------------------------------
     // Check TimeStamp increments...
     // Bypass this check if user has altered FRC register..
     if (frcModified == 0) begin
        tstamp_val0 = tStamp_q.pop_front();
        while(tStamp_q.size()!=0) begin
          tstamp_val1 = tStamp_q.pop_front();

          if (tstamp_val0 >= tstamp_val1)
             `uvm_warning(get_name(), $psprintf("TCAP_STATUS: TimeStamp is incorrect, previous value 0x%0h higher than last one 0x%0h",tstamp_val0,tstamp_val1))

          else 
              tstamp_val0 = tstamp_val1;
        end
     end 
   endfunction: check_phase

endclass : trace_debug_scb

   // <<<<<<<<<<<<<<<<<<<<<<< ------------  >>>>>>>>>>>>>>>>>>>>>>>>>>

   //-----------------------------------------------------
   // RUN Phase::
   //-----------------------------------------------------
task trace_debug_scb::run_phase(uvm_phase phase);
    uvm_objection objection;

    // Basic assignment for objection
    objection = phase.get_objection();

    // There is nothing to add here, because the UNIT scoreboards
    // have instantiated this scoreboard. Therefore, this scoreboard 
    // relies heavily on the UNIT scoreboards objections raise/drop.
    // In short, my life depends on their existence..

endtask : run_phase


<% for (var i=0; i<obj.nSmiRx; i++) { %>
   //--------------------------------------------------------------------
   // Code block for packet coming from ::  TB_SMI<%=i%>_RX_PORT
   //--------------------------------------------------------------------
   function void trace_debug_scb::write_smi<%=i%>_rx_port(const ref smi_seq_item smiPkt) ;
      bit [DTWSIZE-1:0] newMsg, rtlMsg;
      bit [DTWSIZE-1:0] tmpMsg[];
     <% if(obj.testBench == 'dii') { %>
     `ifndef CDNS
      bit [DTWSIZE-1:0] tmpData={0};
      bit [DTWSIZE-1:0] tmpBuff={0};
     `else // `ifndef CDNS
      bit [DTWSIZE-1:0] tmpData='{DTWSIZE{0}};
      bit [DTWSIZE-1:0] tmpBuff='{DTWSIZE{0}};
     `endif // `ifndef CDNS
     <% } else {%>
      bit [DTWSIZE-1:0] tmpData={0};
      bit [DTWSIZE-1:0] tmpBuff={0};
     <% } %>
      smi_seq_item smi<%=i%>_tx, m_pkt;
      int msgLen, ndpPos, nStore;
      int q_size, msgFound,dtwMsgLen;


      m_pkt = new();
      m_pkt.do_copy(smiPkt);

      `uvm_info(get_name(), $psprintf("TCAP-TX:: port_capture_en[%0d]=%0d - TM_BIT=%0d.",<%=i%>,port_capture_en[(<%=i%>)*2],m_pkt.smi_tm), UVM_MEDIUM)

      //------------------------------------------------------------------
      //  No DTWDebug message should ever come to TX[0] nor TX[1] based
      //  on the current architecture definition. Please, refer to 
      //  Ncore system network connectivity and mapping" documentation.
      //------------------------------------------------------------------
      if(m_pkt.smi_dp_present && m_pkt.smi_msg_type==8'hA0) begin : unpack_dtw

          // Check for TM-bit of this cmd type. It is expected to be set to 0.
          if (m_pkt.smi_tm==1)
             `uvm_error(get_name(), $psprintf("RTL failed to clear the TM-bit for DTWDbgReq..."))

          // DTWDebug can only be processed from TX_PORT[3] for DMI and
          // from TX_PORT[2] for all the other blocks such:: DII, IOAIU and CAIU
          if ((2 > <%=i%>) || ((2==<%=i%>) && (4==<%=obj.nSmiTx%>))) begin
             `uvm_error(get_name(), $psprintf("DTWDebug is not expected to be on TX[%0d].",<%=i%>))
          end
          else begin : else_case
             if (m_pkt.smi_dp_last==1) begin : smiDP_last

                // dp_data can be unpacketed right here. Remember, the first set to data is
                // on the MSB.. Now, we need to move the MSB piece to the LSB position
                // To obtain the DTW format, start by moving the LSB is a better approach
                // than starting with the MSB.   
                nStore  = (DTWSIZE / wSmiDPdata);
                tmpData = {>>{m_pkt.smi_dp_data}};
                tmpMsg  = new[nStore];                // # stores to be made
              
              <% if(obj.testBench == 'dii') { %>
              `ifndef CDNS
                gatherDTWdataTx<%=i%>.dtwMsg = {0};
              `else // `ifndef CDNS
                gatherDTWdataTx<%=i%>.dtwMsg = '{DTWSIZE{0}};
              `endif // `ifndef CDNS
              <% } else {%>
                gatherDTWdataTx<%=i%>.dtwMsg = {0};
              <% } %>

                // These 64 bytes message had been stored in (DTWSIZE / wSmiDPdata) chunks
                // where tmpMsg[0] has to start from bit-0 and so on.
                for (int k=0; k<(nStore); ++k) begin
                    tmpMsg[k] = tmpData[(k*wSmiDPdata) +: wSmiDPdata];
                end

                // Time to store them in a DTW format, just as they are 
                // architecturaly defined (512 bits wide).
                for (int k=(nStore-1); k>=0; --k) begin
                    gatherDTWdataTx<%=i%>.dtwMsg |= tmpMsg[k] << (DTWSIZE - (wSmiDPdata * (k+1)));
                end
                
                if ($countones(gatherDTWdataTx<%=i%>.dtwMsg) == 0)
                   `uvm_error(get_name(), $psprintf("DTWDebug is all zero... shouldn't happen."))
                                
                rtlMsg = gatherDTWdataTx<%=i%>.dtwMsg;              // DTW representation

                // Actual position of the NDP
                ndpPos = WSMIHPROT+WSMIMSGTYPE+WSMIMSGTIER+WSMIMSGQOS+WSMIMSGPRI+WSMIMSGID+WSMIDPPRESENT+TStampSize;

                // Keeping track of DTWDebug processed 
                ++numDtwProcess;
               
                // ------------------------------------------------
                // Search until the new message is found...........
                // ------------------------------------------------
                while(rtlMsg != 0) begin : end_of_msg_check
                   msgFound = 0;
                
                   // Notice: (~tmpBuff >> (DTWSIZE-WSMINDPLEN)) is just a mask.
                   dtwMsgLen = (rtlMsg >> ndpPos) & (~tmpBuff >> (DTWSIZE-WSMINDPLEN));   // read ndp_len  

                   `uvm_info(get_name(), $psprintf("TCAP:: UNPACK_DTW = %0h",rtlMsg), UVM_MEDIUM)

                   // ----------------------------------------------------------------- 
                   // Need to calculate the length of each message.
                   dtwMsgLen = trace_debug_scb::calculateMsgLength(dtwMsgLen);
                   newMsg = (rtlMsg << (DTWSIZE - dtwMsgLen)) >> (DTWSIZE -dtwMsgLen);

                   // --------------------------------
                   // Let's register the TimeStamp.
                   if ((tStamp_q.size()==0) || ((numMsgProcess % tStampChk)==0)) begin  
                       tStamp_q.push_back(newMsg & {TStampSize{1'b1}});
                       `uvm_info(get_name(), $psprintf("TCAP-TimeStamp:: MsgProcess=%0d -- time2Check=%0d -- tStamp=0x%0h -- simtime=%0t",numMsgProcess,tStampChk,newMsg & {TStampSize{1'b1}},$time),UVM_MEDIUM)
                   end

                   newMsg = newMsg >> TStampSize;         // Message without TimeStamp
                   
                   if (newMsg==0) begin  // The only time we might see this is if the RTL fail to PAD.
                      `uvm_error(get_name(), $psprintf("TCAP-MSG is invalid, as the actual Msg has a value of 0..."))
                   end

                   `uvm_info(get_name(), $psprintf("TCAP:: Msg to be searched for %0h",newMsg),UVM_MEDIUM) 

                   // ----------------------------------------------------------------------
                   // -----  COMPARE THE DTW MSG WITH THE FIRST ENTRY OF THE TX QUEUES.-----
                   // ----------------------------------------------------------------------
             <% for (var j=0; j<obj.nSmiTx; j++) { %>
                   if ((msgFound==0) &&
                      (my_smi<%=j%>_tx_q.size() != 0)) begin

                      tmpData = my_smi<%=j%>_tx_q.pop_front();
                      tmpData = tmpData >> TStampSize;        // Don't compare the TimeStamp for now.

                      `uvm_info(get_name(), $psprintf("TCAP-TX:: check if this is the correct msg:: %0h",tmpData),UVM_MEDIUM)
                      if (tmpData == newMsg) begin
                         `uvm_info(get_name(), $psprintf("TCAP-TX:: MSG Found=%0h in TX_Q[<%=j%>].",tmpData),UVM_MEDIUM)
                         msgFound = 1; ++numMsgProcess; 
                      end
                      else begin
                          tmpData = {tmpData,32'hdeadface};
                          my_smi<%=j%>_tx_q.push_back(tmpData);
                      end
                   end
             <% } %>


                  // ----------------------------------------------------------------------
                  // -----  COMPARE THE DTW MSG WITH THE FIRST ENTRY OF THE RX QUEUES.-----
                  // ----------------------------------------------------------------------
             <% for (var j=0; j<obj.nSmiRx; j++) { %>
                  if ((msgFound==0) &&
                      (my_smi<%=j%>_rx_q.size() != 0)) begin

                      tmpData = my_smi<%=j%>_rx_q.pop_front();
                      tmpData = tmpData >> TStampSize;       // Don't compare the TimeStamp for now.

                      `uvm_info(get_name(), $psprintf("TCAP-RX:: check if this is the correct msg:: %0h",tmpData),UVM_MEDIUM)
                      if (tmpData == newMsg) begin
                          `uvm_info(get_name(), $psprintf("TCAP-RX:: MSG Found=%0h in RX_Q[<%=j%>].",tmpData),UVM_MEDIUM)
                           msgFound = 1; ++numMsgProcess;  
                      end
                      else begin
                           tmpData = {tmpData,32'hdeadface};
                           my_smi<%=j%>_rx_q.push_back(tmpData);
                      end
                   end
             <% } %>


                  // ----------------------------------------------------------------------
                  // -----  COMPARE THE DTW MSG AGAINST EVERY ENTRY OF THE TX QUEUES..-----
                  // -----               UNTIL A MATCH IS ENCOUNTERED.                -----
                  // ----------------------------------------------------------------------
             <% for (var j=0; j<obj.nSmiTx; j++) { %>
                  if ((msgFound==0) &&
                      (my_smi<%=j%>_tx_q.size() != 0)) begin

                    q_size = my_smi<%=j%>_tx_q.size();

                    while(q_size > 0) begin
                       tmpData = my_smi<%=j%>_tx_q.pop_front();
                       tmpData = tmpData >> TStampSize;      // Don't compare the TimeStamp for now.

                       `uvm_info(get_name(), $psprintf("TCAP-TX:: check if this is the correct msg:: %0h",tmpData),UVM_MEDIUM)

                       if (tmpData == newMsg) begin
                           `uvm_info(get_name(), $psprintf("TCAP-TX:: MSG Found=%0h in TX_Q[<%=j%>].",tmpData),UVM_MEDIUM)
                            msgFound = 1; ++numMsgProcess;
                            break; 
                       end
                       else begin
                            tmpData = {tmpData,32'hdeadface};
                            my_smi<%=j%>_tx_q.push_back(tmpData);
                       end

                       --q_size;
                    end
                end
             <% } %>



                  // ----------------------------------------------------------------------
                  // -----  COMPARE THE DTW MSG AGAINST EVERY ENTRY OF THE RX QUEUES..-----
                  // -----               UNTIL A MATCH IS ENCOUNTERED.                -----
                  // ----------------------------------------------------------------------
             <% for (var j=0; j<obj.nSmiRx; j++) { %>
                  if ((msgFound==0) &&
                      (my_smi<%=j%>_rx_q.size() != 0)) begin

                    q_size = my_smi<%=j%>_rx_q.size();

                    while(q_size > 0) begin
                      tmpData = my_smi<%=j%>_rx_q.pop_front();
                      tmpData = tmpData >> TStampSize;       // Don't compare the TimeStamp for now.

                      `uvm_info(get_name(), $psprintf("TCAP-RX:: check if this is the correct msg:: %0h",tmpData),UVM_MEDIUM)
                      if (tmpData == newMsg) begin
                         `uvm_info(get_name(), $psprintf("TCAP-RX:: MSG Found=%0h in RX_Q[<%=j%>].",tmpData),UVM_MEDIUM)
                          msgFound = 1;      // Indicator of match encountered
                          ++numMsgProcess;          // Use as a status
                          break;
                      end
                      else begin
                           tmpData = {tmpData,32'hdeadface};
                           my_smi<%=j%>_rx_q.push_back(tmpData);
                      end

                      --q_size;
                    end
                  end
             <% } %>

                if (msgFound == 0) begin
                    ++numMsgMissAllow;   
                    if ((cctrlr_mod==0) || (numMsgMissAllow==numMsgDropAllow)) begin
                    `uvm_error(get_name(), $psprintf("TCAP:: Msg %0h was never registered by DV.. MSG_TYPE --> %0h ::: NDP_LEN --> %0h ::: NDP_NDP --> %0h::: numAllowMiss --> %0d",newMsg,((newMsg >> (ndpPos-TStampSize-WSMIHPROT-WSMIMSGTYPE)) & {WSMIMSGTYPE{1'b1}}),(newMsg >> (ndpPos-TStampSize)) & {WSMINDPLEN{1'b1}},(newMsg >> (ndpPos-TStampSize+WSMINDPLEN+WSMISRCID+WSMISTEER+WSMITGTID)),numMsgMissAllow))
                    end
                end

                rtlMsg = rtlMsg >> dtwMsgLen;   // Get ready to search for the next Msg.`

               end : end_of_msg_check
             end : smiDP_last
          end : else_case
      end : unpack_dtw
      
      <% if(i < (obj.nSmiRx-1)) { %>
      else begin : tx_msg_to_capture

         ++numMsgSeen;                 // Register the Msg whether TM_bit is on or off
         // 4CN1DN : DII/CHIAIU/IOAIU uses smi_rx port-2. DMI uses smi_rx port-3.
         // 3CN1DN : DII/CHIAIU/IOAIU uses smi_rx port-1. DMI uses smi_rx port-1.
         numDtwRspSeen += (((1==<%=i%>) || (2==<%=i%>) || (3==<%=i%>)) && (m_pkt.smi_msg_type==8'hff)) ? 1 : 0;  

         if (m_pkt.smi_tm==1 && trace_debug_scb::portCaptureValid(TX,<%=obj.nSmiTx%>, <%=i%>)) begin
             smi<%=i%>_tx_q.push_back(m_pkt);   // register the packet(s)

             // Make sure this message is not a DtwDbgRsp..
             if (m_pkt.smi_msg_type==8'hff) 
                `uvm_error(get_name(), $psprintf("TCAP-TX:: TX[<%=i%>] - TM-Bit should not be set for DtwDbgRsp"))

             // For functional Coverage::: coverage for the current "SMI TX Port".
             covConcTransType(TX,m_pkt.smi_msg_type);
             //trace_debug_scb::DmiConcReq[7:0]= m_pkt.smi_msg_type;
             trace_debug_scb::tcapReg[7:0]   = (1 << ((2 * <%=i%>) + TX));
             trace_debug_scb::tcapReg[19:16] = gain;
             trace_debug_scb::tcapReg[31:20] = covHighestBitSet4Inc();
             trace_debug_scb::frcReg[31:0]   = (frcAlterAndWrap > 0) ? frCounter : 0;
            `ifndef FSYS_COVER_ON
             tcapCov.sample();
             <% if(obj.Block =='dmi') { %>
             frcCov.sample();
             <% } %>
             `endif

             foreach(smi<%=i%>_tx_q[i]) begin: foreach_smi<%=i%>_tx_q
               if (smi<%=i%>_tx_q.size() == 0) continue;

               begin 
                 // Create concerto message.
                 smi<%=i%>_tx = smi<%=i%>_tx_q.pop_front();    
          
                 // Calculate the real length of the message
                 // Those SMI parameters can be found in  "xxx_axi_if" files
                 msgLen = trace_debug_scb::calculateMsgLength(m_pkt.smi_ndp_len); 

                 newMsg = trace_debug_scb::calculateMSG(m_pkt,<%=i%>);
                 newMsg = {newMsg,32'hdeadface};

                 `uvm_info(get_name(), $psprintf("TCAP-TX:: Message Length per field for TX[%0d] -- WSMITGTID=%0d - WSMISRCID=%0d - WSMINDPLEN=%0d - WSMINDP=%0d - WSMIMSGTYPE=%0d - WSMIMSGID=%0d -WSMIDPPRESENT=%0d",<%=i%>,WSMITGTID,WSMISRCID,WSMINDPLEN,WSMINDP,WSMIMSGTYPE,WSMIMSGID,WSMIDPPRESENT), UVM_MEDIUM)

                 `uvm_info(get_name(), $psprintf("TCAP-TX:: Message Fields for TX[%0d] -- smi_targ_id=0x%0h - smi_src_id=0x%0h - smi_ndp_len=%0d - smi_ndp=0x%0h - smi_msg_type=0x%0h - smi_msg_id=0x%0h - smi_dp_present=%0d",<%=i%>,m_pkt.smi_targ_id,m_pkt.smi_src_id,m_pkt.smi_ndp_len,m_pkt.smi_ndp,m_pkt.smi_msg_type,m_pkt.smi_msg_id,m_pkt.smi_dp_present), UVM_MEDIUM)

                 `uvm_info(get_name(), $psprintf("TCAP-TX:: Message for TX[%0d] = 0x%0h - Total_Length = %0d.",<%=i%>,newMsg,msgLen), UVM_MEDIUM)

                 // Add new MSG onto the SMI<%=i%>_TX_Queue 
                 my_smi<%=i%>_tx_q.push_back(newMsg);
                 ++numMsgRegister;
               end
             end: foreach_smi<%=i%>_tx_q
         end
     end : tx_msg_to_capture
     <% } %>
     perfmon_captured_dropped_packets();


   endfunction
  <% } %>

    function void trace_debug_scb::write_smi_dnrx_ndp_only_port(const ref smi_seq_item smiPkt);

    <% var smi_port_no = (obj.nSmiTx-1) %>
        bit [DTWSIZE-1:0] newMsg;
        smi_seq_item smi<%=smi_port_no%>_tx, m_pkt;
        int msgLen;

        m_pkt = new();
        m_pkt.do_copy(smiPkt);
        
        ++numMsgSeen;                 // Register the Msg whether TM_bit is on or off
         // 4CN1DN : DII/CHIAIU/IOAIU uses smi_rx port-2. DMI uses smi_rx port-3.
         // 3CN1DN : DII/CHIAIU/IOAIU uses smi_rx port-1. DMI uses smi_rx port-1.
        numDtwRspSeen += (((1==<%=smi_port_no%>) || (2==<%=smi_port_no%>) || (3==<%=smi_port_no%>))&& (m_pkt.smi_msg_type==8'hff)) ? 1 : 0;

        `uvm_info("write_smi_dnrx_ndp_only_port", $sformatf("%p", smiPkt), UVM_MEDIUM)
        if (m_pkt.smi_tm==1 && trace_debug_scb::portCaptureValid(TX,<%=obj.nSmiTx%>, <%=smi_port_no%>)) begin
             smi<%=smi_port_no%>_tx_q.push_back(m_pkt);   // register the packet(s)

             // Make sure this message is not a DtwDbgRsp..
             if (m_pkt.smi_msg_type==8'hff) 
                `uvm_error(get_name(), $psprintf("TCAP-TX:: TX[<%=smi_port_no%>] - TM-Bit should not be set for DtwDbgRsp"))

             // For functional Coverage::: coverage for the current "SMI TX Port".
             covConcTransType(TX,m_pkt.smi_msg_type);
             trace_debug_scb::tcapReg[7:0]   = (1 << ((2 * <%=smi_port_no%>) + TX));
             trace_debug_scb::tcapReg[19:16] = gain;
             trace_debug_scb::tcapReg[31:20] = covHighestBitSet4Inc();
             trace_debug_scb::frcReg[31:0]   = (frcAlterAndWrap > 0) ? frCounter : 0;
            `ifndef FSYS_COVER_ON
             tcapCov.sample();
             <% if(obj.Block =='dmi') { %>
             frcCov.sample();
             <% } %>
             ConcReqCov.sample();
             `endif

             foreach(smi<%=smi_port_no%>_tx_q[i]) begin: foreach_smi<%=smi_port_no%>_tx_q
               if (smi<%=smi_port_no%>_tx_q.size() == 0) continue;

               begin 
                 // Create concerto message.
                 smi<%=smi_port_no%>_tx = smi<%=smi_port_no%>_tx_q.pop_front();    
          
                 // Calculate the real length of the message
                 // Those SMI parameters can be found in  "xxx_axi_if" files
                 msgLen = trace_debug_scb::calculateMsgLength(m_pkt.smi_ndp_len); 

                 newMsg = trace_debug_scb::calculateMSG(m_pkt,<%=smi_port_no%>);
                 newMsg = {newMsg,32'hdeadface};

                 `uvm_info(get_name(), $psprintf("TCAP-TX:: Message Length per field for TX[%0d] -- WSMITGTID=%0d - WSMISRCID=%0d - WSMINDPLEN=%0d - WSMINDP=%0d - WSMIMSGTYPE=%0d - WSMIMSGID=%0d -WSMIDPPRESENT=%0d",<%=smi_port_no%>,WSMITGTID,WSMISRCID,WSMINDPLEN,WSMINDP,WSMIMSGTYPE,WSMIMSGID,WSMIDPPRESENT), UVM_MEDIUM)

                 `uvm_info(get_name(), $psprintf("TCAP-TX:: Message Fields for TX[%0d] -- smi_targ_id=0x%0h - smi_src_id=0x%0h - smi_ndp_len=%0d - smi_ndp=0x%0h - smi_msg_type=0x%0h - smi_msg_id=0x%0h - smi_dp_present=%0d",<%=smi_port_no%>,m_pkt.smi_targ_id,m_pkt.smi_src_id,m_pkt.smi_ndp_len,m_pkt.smi_ndp,m_pkt.smi_msg_type,m_pkt.smi_msg_id,m_pkt.smi_dp_present), UVM_MEDIUM)

                 `uvm_info(get_name(), $psprintf("TCAP-TX:: Message for TX[%0d] = 0x%0h - Total_Length = %0d.",<%=smi_port_no%>,newMsg,msgLen), UVM_MEDIUM)

                 // Add new MSG onto the SMI<%=i%>_TX_Queue 
                 my_smi<%=smi_port_no%>_tx_q.push_back(newMsg);
                 ++numMsgRegister;
               end
             end: foreach_smi<%=smi_port_no%>_tx_q
         end
         perfmon_captured_dropped_packets();
    endfunction

<% for (var i=0; i<obj.nSmiTx; i++) { %>
   //--------------------------------------------------------------------
   // Code block for packet coming from ::  TB_SMI<%=i%>_TX_PORT
   //--------------------------------------------------------------------
   function void trace_debug_scb::write_smi<%=i%>_tx_port(const ref smi_seq_item smiPkt) ;
      bit [DTWSIZE-1:0] newMsg;
      smi_seq_item smi<%=i%>_rx, m_pkt;
      int msgLen, ndpPos;

      m_pkt = new();
      m_pkt.do_copy(smiPkt);

      `uvm_info(get_name(), $psprintf("TCAP-RX:: port_capture_en[%0d]=%0d - TM_BIT=%0d.",<%=i%>,port_capture_en[(<%=i%>)*2+1],m_pkt.smi_tm), UVM_MEDIUM)

      //------------------------------------------------------------------
      //  No DTWDebug message should ever come to any of the RX port.  
      //  This would be considered as an architecture violation. 
      //------------------------------------------------------------------
      if(m_pkt.smi_dp_present && m_pkt.smi_msg_type==8'hA0) begin 
         `uvm_error(get_name(), $psprintf("TCAP-RX:: MSG type 8'hAO should never come to an RX port"))
      end
      <% if(i < (obj.nSmiTx-1)) { %>
      else begin : rx_msg_to_capture

         ++numMsgSeen;                 // Register the Msg whether TM_bit is on or off
         // 4CN1DN : DII/CHIAIU/IOAIU uses smi_rx port-2. DMI uses smi_rx port-3.
         // 3CN1DN : DII/CHIAIU/IOAIU uses smi_rx port-1. DMI uses smi_rx port-1.
         numDtwRspSeen += (((1==<%=i%>) || (2==<%=i%>) || (3==<%=i%>)) && (m_pkt.smi_msg_type==8'hff)) ? 1 : 0;

         if (m_pkt.smi_tm==1 && trace_debug_scb::portCaptureValid(RX,<%=obj.nSmiRx%>, <%=i%>)) begin
             smi<%=i%>_rx_q.push_back(m_pkt);   // register the packet(s)

             // Make sure this message is not a DtwDbgRsp..
             if (m_pkt.smi_msg_type==8'hff) 
                `uvm_error(get_name(), $psprintf("TCAP-RX:: RX[<%=i%>] - TM-Bit should not be set for DtwDbgRsp"))

             // For functional Coverage::: coverage for the current "SMI RX Port".
             covConcTransType(RX, m_pkt.smi_msg_type);
             trace_debug_scb::tcapReg[7:0]   = (1 << ((2 * <%=i%>) + RX));
             trace_debug_scb::tcapReg[19:16] = gain;
             trace_debug_scb::tcapReg[31:20] = covHighestBitSet4Inc();
             trace_debug_scb::frcReg[31:0]   = (frcAlterAndWrap > 0) ? frCounter : 0;
            `ifndef FSYS_COVER_ON
             tcapCov.sample();
             <% if(obj.Block =='dmi') { %>
             frcCov.sample();
             <% } %>
             ConcReqCov.sample();
             `endif

             foreach(smi<%=i%>_rx_q[i]) begin: foreach_smi<%=i%>_rx_q
               if (smi<%=i%>_rx_q.size() == 0) continue;

               begin 
                 // Create concerto message.
                 smi<%=i%>_rx = smi<%=i%>_rx_q.pop_front();    
          
                 msgLen = trace_debug_scb::calculateMsgLength(m_pkt.smi_ndp_len);

                 // Read the TimeStamp ---- for now let's force it to  (( 32'hFACEDEAD ));
                 newMsg = trace_debug_scb::calculateMSG(m_pkt,<%=i%>);
                 newMsg = {newMsg,32'hdeadface};

                 `uvm_info(get_name(), $psprintf("TCAP-RX:: Message Length per field for RX[%0d] -- WSMITGTID=%0d - WSMISRCID=%0d - WSMINDPLEN=%0d - WSMINDP=%0d - WSMIMSGTYPE=%0d - WSMIMSGID=%0d -WSMIDPPRESENT=%0d",<%=i%>,WSMITGTID,WSMISRCID,WSMINDPLEN,WSMINDP,WSMIMSGTYPE,WSMIMSGID,WSMIDPPRESENT), UVM_MEDIUM)

                 `uvm_info(get_name(), $psprintf("TCAP-RX:: Message Fields for RX[%0d] -- smi_targ_id=0x%0h - smi_src_id=0x%0h - smi_ndp_len=%0d - smi_ndp=0x%0h - smi_msg_type=0x%0h - smi_msg_id=0x%0h - smi_dp_present=%0d",<%=i%>,m_pkt.smi_targ_id,m_pkt.smi_src_id,m_pkt.smi_ndp_len,m_pkt.smi_ndp,m_pkt.smi_msg_type,m_pkt.smi_msg_id,m_pkt.smi_dp_present), UVM_MEDIUM)

                 `uvm_info(get_name(), $psprintf("TCAP-RX:: Message for RX[%0d] = 0x%0h - Total_Length = %0d.",<%=i%>,newMsg,msgLen), UVM_MEDIUM)

                 // Add new MSG onto the SMI<%=i%>_RX_Queue 
                 my_smi<%=i%>_rx_q.push_back(newMsg);
                 ++numMsgRegister;
               end
             end: foreach_smi<%=i%>_rx_q
         end
     end : rx_msg_to_capture
     <% } %>
     perfmon_captured_dropped_packets();
   endfunction
  <% } %>

   function void trace_debug_scb::write_smi_dntx_ndp_only_port(const ref smi_seq_item smiPkt) ; 
        <% var smi_port_no = (obj.nSmiTx - 1)%>
        bit [DTWSIZE-1:0] newMsg;
        smi_seq_item smi<%=smi_port_no%>_rx, m_pkt;
        int msgLen;
        
        m_pkt = new();
        m_pkt.do_copy(smiPkt);

        ++numMsgSeen;                 // Register the Msg whether TM_bit is on or off
         // 4CN1DN : DII/CHIAIU/IOAIU uses smi_rx port-2. DMI uses smi_rx port-3.
         // 3CN1DN : DII/CHIAIU/IOAIU uses smi_rx port-1. DMI uses smi_rx port-1.
        numDtwRspSeen += (((1==<%=smi_port_no%>) || (2==<%=smi_port_no%>) || (2==<%=smi_port_no%>)) && (m_pkt.smi_msg_type==8'hff)) ? 1 : 0;

        `uvm_info("write_smi_dntx_ndp_only_port", $sformatf("%p", smiPkt), UVM_MEDIUM);
        if (m_pkt.smi_tm==1 && trace_debug_scb::portCaptureValid(RX,<%=obj.nSmiRx%>, <%=smi_port_no%>)) begin
             smi<%=smi_port_no%>_rx_q.push_back(m_pkt);   // register the packet(s)

             // Make sure this message is not a DtwDbgRsp..
             if (m_pkt.smi_msg_type==8'hff) 
                `uvm_error(get_name(), $psprintf("TCAP-RX:: RX[<%=smi_port_no%>] - TM-Bit should not be set for DtwDbgRsp"))

             // For functional Coverage::: coverage for the current "SMI RX Port".
             covConcTransType(RX, m_pkt.smi_msg_type);
             trace_debug_scb::tcapReg[7:0]   = (1 << ((2 * <%=smi_port_no%>) + RX));
             trace_debug_scb::tcapReg[19:16] = gain;
             trace_debug_scb::tcapReg[31:20] = covHighestBitSet4Inc();
             trace_debug_scb::frcReg[31:0]   = (frcAlterAndWrap > 0) ? frCounter : 0;
            `ifndef FSYS_COVER_ON
             tcapCov.sample();
             <% if(obj.Block =='dmi') { %>
             frcCov.sample();
             <% } %>
             ConcReqCov.sample();
             `endif

             foreach(smi<%=smi_port_no%>_rx_q[i]) begin: foreach_smi<%=smi_port_no%>_rx_q
               if (smi<%=smi_port_no%>_rx_q.size() == 0) continue;

               begin 
                 // Create concerto message.
                 smi<%=smi_port_no%>_rx = smi<%=smi_port_no%>_rx_q.pop_front();    
          
                 msgLen = trace_debug_scb::calculateMsgLength(m_pkt.smi_ndp_len);

                 // Read the TimeStamp ---- for now let's force it to  (( 32'hFACEDEAD ));
                 newMsg = trace_debug_scb::calculateMSG(m_pkt,<%=smi_port_no%>);
                 newMsg = {newMsg,32'hdeadface};

                 `uvm_info(get_name(), $psprintf("TCAP-RX:: Message Length per field for RX[%0d] -- WSMITGTID=%0d - WSMISRCID=%0d - WSMINDPLEN=%0d - WSMINDP=%0d - WSMIMSGTYPE=%0d - WSMIMSGID=%0d -WSMIDPPRESENT=%0d",<%=i%>,WSMITGTID,WSMISRCID,WSMINDPLEN,WSMINDP,WSMIMSGTYPE,WSMIMSGID,WSMIDPPRESENT), UVM_MEDIUM)

                 `uvm_info(get_name(), $psprintf("TCAP-RX:: Message Fields for RX[%0d] -- smi_targ_id=0x%0h - smi_src_id=0x%0h - smi_ndp_len=%0d - smi_ndp=0x%0h - smi_msg_type=0x%0h - smi_msg_id=0x%0h - smi_dp_present=%0d",<%=smi_port_no%>,m_pkt.smi_targ_id,m_pkt.smi_src_id,m_pkt.smi_ndp_len,m_pkt.smi_ndp,m_pkt.smi_msg_type,m_pkt.smi_msg_id,m_pkt.smi_dp_present), UVM_MEDIUM)

                 `uvm_info(get_name(), $psprintf("TCAP-RX:: Message for RX[%0d] = 0x%0h - Total_Length = %0d.",<%=smi_port_no%>,newMsg,msgLen), UVM_MEDIUM)

                 // Add new MSG onto the SMI<%=i%>_RX_Queue 
                 my_smi<%=smi_port_no%>_rx_q.push_back(newMsg);
                 ++numMsgRegister;
               end
             end: foreach_smi<%=smi_port_no%>_rx_q
         end
         perfmon_captured_dropped_packets();
    endfunction

   //-------------------------------------------------------
   // Will return the actual length of the message round
   // to the nearest byte. There is 1 thing to notice here:
   //  1._ Notice that WSMIHPROT is not part of those fields 
   //      because it is a shadow copy of WSMIMSGUSER. It 
   //      would be incorrect to add it among the other fields. 
   function int trace_debug_scb::calculateMsgLength(int mlen);
      int myLEN;

      if (WSMITGTID      != 0) begin myLEN += WSMITGTID;       end;   
      if (WSMISTEER      != 0) begin myLEN += WSMISTEER;       end;  
      if (WSMISRCID      != 0) begin myLEN += WSMISRCID;       end; 
      if (WSMINDPLEN     != 0) begin myLEN += WSMINDPLEN;      end;   
      if (WSMIMSGUSER    != 0) begin myLEN += WSMIMSGUSER;     end;   
      if (WSMIMSGTYPE    != 0) begin myLEN += WSMIMSGTYPE;     end;  
      if (WSMIMSGTIER    != 0) begin myLEN += WSMIMSGTIER;     end; 
      if (WSMIMSGQOS     != 0) begin myLEN += WSMIMSGQOS;      end;
      if (WSMIMSGPRI     != 0) begin myLEN += WSMIMSGPRI;      end;  
      if (WSMIMSGID      != 0) begin myLEN += WSMIMSGID;       end; 
      if (WSMIDPPRESENT  != 0) begin myLEN += WSMIDPPRESENT;   end; 

      myLEN  += (TStampSize + mlen);
    
      // Round to the nearest byte.
      if ((myLEN % 8) !=0)           
          myLEN += (8 - (myLEN % 8));

     `uvm_info(get_name(), $psprintf("TCAP:: Actual MSG length rounded to nearest byte=%0d.",myLEN), UVM_MEDIUM)
      return(myLEN);
   endfunction
  
   //-----------------------------------------------------
   // Return the most upper bit set in CCTRLR[INC].
   function bit [11:0] trace_debug_scb::covHighestBitSet4Inc();
      automatic bit [11:0] count=11;
      while(count != 0) begin
        if ((trace_debug_scb::inc >> count) != 12'h0)  return(1<<count);
        --count; 
      end
      return(trace_debug_scb::inc);  
   endfunction

   //-----------------------------------------------------
   // Will return the actual length of the message round
   // to the nearest byte. 
   function bit [DTWSIZE-1:0] trace_debug_scb::calculateMSG(smi_seq_item mpkt,int msgNum);
      bit [DTWSIZE-1:0] myMSG;

      myMSG = mpkt.smi_ndp;
      if (WSMITGTID    != 0) begin myMSG = {myMSG,mpkt.smi_targ_id};    end 
      if (WSMISTEER    != 0) begin myMSG = {myMSG,mpkt.smi_steer};      end 
      if (WSMISRCID    != 0) begin myMSG = {myMSG,mpkt.smi_src_id};     end 
      if (WSMINDPLEN   != 0) begin myMSG = {myMSG,mpkt.smi_ndp_len};    end 
      if (WSMIHPROT    != 0) begin myMSG = {myMSG,mpkt.smi_msg_user};   end 
      if (WSMIMSGTYPE  != 0) begin myMSG = {myMSG,mpkt.smi_msg_type};   end 
      if (WSMIMSGTIER  != 0) begin myMSG = {myMSG,mpkt.smi_msg_tier};   end 
      if (WSMIMSGQOS   != 0) begin myMSG = {myMSG,mpkt.smi_msg_qos};    end 
      if (WSMIMSGPRI   != 0) begin myMSG = {myMSG,mpkt.smi_msg_pri};    end 
      if (WSMIMSGID    != 0) begin myMSG = {myMSG,mpkt.smi_msg_id};     end 
      if (WSMIDPPRESENT!= 0) begin myMSG = {myMSG,mpkt.smi_dp_present}; end 

      `uvm_info(get_name(), $psprintf("TCAP:: Actual MSG for SMI-PORT[%0d]:: %0h",msgNum,myMSG), UVM_MEDIUM)
      return(myMSG);
   endfunction


   // --------------------------------------------------------------------
   // Function will return determine if the port is enable for Msg capture
   // Those parameters are defined as follow::
   //  - smiDir      -- SMI direction - can only be TX or RX.
   //  - numSmiPort  -- Number of Ports configured for TX or RX
   //  - portNum     -- The actual port number that we are dealing with.
   function int trace_debug_scb::portCaptureValid(int smiDir, int numSmiPort, int portNum);
     int pVal=0;

      // Currently, we are supporting 3 or 4  SMI-Networks.
      case(numSmiPort)
         3 : begin        // For DII, CAIU and NCAIU
               if (portNum<2) begin        // Only for portNum (0) or (1);     
                   if (smiDir==TX) pVal = (trace_debug_scb::port_capture_en[portNum * 2]==1) ? 1 : 0;
                   if (smiDir==RX) pVal = (trace_debug_scb::port_capture_en[portNum * 2 +1]==1) ? 1 : 0;
               end
               else begin                  // Only for portNum 3
                   if (smiDir==TX) pVal = (trace_debug_scb::port_capture_en[(portNum+1) * 2]==1) ? 1 : 0;
                   if (smiDir==RX) pVal = (trace_debug_scb::port_capture_en[(portNum+1) * 2 +1]==1) ? 1 : 0;
               end
             end

         4 : begin        // 3CN1DN - DMI, 4CN1DN - DII, CAIU and NCAIU
               if (smiDir==TX) pVal = (trace_debug_scb::port_capture_en[portNum * 2]==1) ? 1 : 0;
               if (smiDir==RX) pVal = (trace_debug_scb::port_capture_en[portNum * 2 +1]==1) ? 1 : 0;
             end
         5 : begin        // 4CN1DN - DMI
               if (smiDir==TX) pVal = (trace_debug_scb::port_capture_en[portNum * 2]==1) ? 1 : 0;
               if (smiDir==RX) pVal = (trace_debug_scb::port_capture_en[portNum * 2 +1]==1) ? 1 : 0;
             end
         default:
                 `uvm_error(get_name(), $psprintf("TCAP:: We only support [3 or 4] networks for this Rev."))
      endcase

     return(pVal);
   endfunction

   //-----------------------------------------------------------------
   // This function is only used for functional coverage collection.
   // Notes::
   //   The first parameter "smiDir" is used to distinguish TX vs RX.  
   //   Also, notice that some CMDs have been combined into 1 CMD
   //   such as:: [8'h60 : 8'h68]                     -->  8'h68
   //             [8'h80 : 8'h84]                     -->  8'h80
   //             [8'h90 : 8'h93] and [8'h98 : 8'h9C] -->  8'h9C
   //-----------------------------------------------------------------
   function void trace_debug_scb::covConcTransType(int smiDir, bit [7:0] msg_type);
      string tBlock  ="<%=obj.Block%>";

      case(tBlock)
        "dmi" :     begin
                      if (msg_type <= 8'h2B) trace_debug_scb::DmiReq[7:0]=8'h2B;
                      else if (msg_type>=8'h60  &&  msg_type<=8'h68) trace_debug_scb::DmiReq[7:0]=8'h68; 
                      else if ((msg_type>=8'h90  &&  msg_type<=8'h93) ||
                               (msg_type>=8'h98  &&  msg_type<=8'h9C)) trace_debug_scb::DmiReq[7:0]=8'h9C;
                      else if ((msg_type==8'h7A) || (msg_type==8'h7C) || 
                               (msg_type==8'h7D) || (msg_type==8'h80)) trace_debug_scb::DmiReq[7:0]=msg_type;
    
            `ifndef FSYS_COVER_ON
                      trace_debug_scb::ConcReqCov.sample();
                      `endif
                    end
        "dii" :     begin
                      if (msg_type <= 8'h2B) trace_debug_scb::DiiReq[7:0]=8'h2B;
                      else if ((msg_type>=8'h90  &&  msg_type<=8'h93) ||
                               (msg_type>=8'h98  &&  msg_type<=8'h9C)) trace_debug_scb::DiiReq[7:0]=8'h9C;
                      else if ((msg_type==8'h7A) || (msg_type==8'h80)) trace_debug_scb::DiiReq[7:0]=msg_type;
    
            `ifndef FSYS_COVER_ON
                      trace_debug_scb::ConcReqCov.sample();
                      `endif
                    end
        "chi_aiu" : begin
                      if (msg_type==8'h7A) trace_debug_scb::CaiuReq[8:0]=msg_type;
                      else if (msg_type <= 8'h2B) trace_debug_scb::CaiuReq[8:0]=8'h2B;
                      else if ((msg_type>=8'h90  &&  msg_type<=8'h93) ||
                               (msg_type>=8'h98  &&  msg_type<=8'h9C)) trace_debug_scb::CaiuReq[8:0]=8'h9C;
                      else if (msg_type>=8'h41  &&  msg_type<=8'h51) trace_debug_scb::CaiuReq[8:0]=8'h51;
                      else if ((msg_type>=8'h80 && msg_type<=8'h84) || (msg_type==8'h7B)) begin
                           if (msg_type>=8'h80 && msg_type<=8'h84) msg_type=8'h80;

                           trace_debug_scb::CaiuReq[8:0]=msg_type + (smiDir * 9'h100);
                      end

            `ifndef FSYS_COVER_ON
                      trace_debug_scb::ConcReqCov.sample();
            `endif
                    end
        "io_aiu"  : begin
                      if (msg_type==8'h7A) trace_debug_scb::IoaiuReq[8:0]=msg_type;
                      else if (msg_type <= 8'h2B) trace_debug_scb::IoaiuReq[8:0]=8'h2B;
                      else if ((msg_type>=8'h90  &&  msg_type<=8'h93) ||
                               (msg_type>=8'h98  &&  msg_type<=8'h9C)) trace_debug_scb::IoaiuReq[8:0]=8'h9C;
                      else if (msg_type>=8'h41  &&  msg_type<=8'h51) trace_debug_scb::IoaiuReq[8:0]=8'h51;
                      else if ((msg_type>=8'h80 && msg_type<=8'h84) || (msg_type==8'h7B)) begin
                           if (msg_type>=8'h80 && msg_type<=8'h84) msg_type=8'h80; 

                           trace_debug_scb::IoaiuReq[8:0]=msg_type + (smiDir * 9'h100);
                      end

            `ifndef FSYS_COVER_ON
                      trace_debug_scb::ConcReqCov.sample();
            `endif
                    end
        default :
                `uvm_info(get_name(), $psprintf("TCAP:: Not registering this message Type=0x%h..",msg_type), UVM_MEDIUM)
      endcase
   endfunction
    
   function void trace_debug_scb::perfmon_captured_dropped_packets();
      if((numMsgProcess - numMsgProcess_sent) > 0)
         stall_if.perf_count_events["Captured_SMI_packets"].push_back(numMsgProcess - numMsgProcess_sent);
      numMsgProcess_sent = numMsgProcess;

      numMsgDropped = numMsgRegister - numMsgProcess;

      stall_if.num_SMI_packets_registered = numMsgRegister;
      <% if( ! obj.BlockId.includes("dve") && ! obj.BlockId.includes("dce")) { %>
      stall_if.dropped_smi_packets        = numMsgDropped;
      <%}%>

   endfunction
 
