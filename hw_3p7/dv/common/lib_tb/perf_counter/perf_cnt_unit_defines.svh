
<%
// some list checkers
// checK if empty
if (obj.listEventArr.length==0) { throw new Error("none perf counter event find !!!");}

//check  the index number
obj.listEventArr.forEach( function(event,idx) { 
    if (event.evt_idx != idx) { throw new Error(`!!!Perf counter list event checker name:${event.name}!!! evt_idx: ${event.evt_idx} != index of the array: ${idx} Please check your list of Event!!!`);}
})
%>

 <% obj.debuglistEventArr.forEach( function(event,idx,array) { %>
       // test comment <%=idx%>  name = <%=event.name%>  <%if (event.itf_name) { %> itf:<%=event.itf_name%> <%}%> 
<%})%>

<%
if (obj.BlockId.includes("dii")) {
    xUser = obj.DiiInfo[obj.Id].interfaces.axiInt.params.wAwUser && obj.DiiInfo[obj.Id].interfaces.axiInt.params.wArUser;

}

if (obj.BlockId.includes("dmi")) {
    xUser = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wAwUser && obj.DmiInfo[obj.Id].interfaces.axiInt.params.wArUser;

}

if (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI")){
    xUser = obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC;
} 

if ((obj.testBench =="io_aiu")){
  if(obj.interfaces.axiInt.length > 1) {
  xUser = obj.interfaces.axiInt[0].params.wAwUser;
  } else {
  xUser = obj.interfaces.axiInt.params.wAwUser;
  }
}
///////////////////////////////////////////
%>
package <%=obj.BlockId%>_perf_cnt_unit_defines;

    
    typedef enum bit [6-1:0] 
    { 
    //#Stimulus.DII.Pmon.v3.2.NoEvent
    //#Stimulus.DII.Pmon.v3.2.Tx0Stall 
    //#Stimulus.DII.Pmon.v3.2.Tx1Stall 
    //#Stimulus.DII.Pmon.v3.2.Tx2Stall 
    //#Stimulus.DII.Pmon.v3.2.Rx0Stall 
    //#Stimulus.DII.Pmon.v3.2.Rx1Stall 
    //#Stimulus.DII.Pmon.v3.2.Rx2Stall
    //#Stimulus.DII.Pmon.v3.2.AxiAwStall 
    //#Stimulus.DII.Pmon.v3.2.AxiWStall 
    //#Stimulus.DII.Pmon.v3.2.AxiBStall
    //#Stimulus.DII.Pmon.v3.2.AxiArStall 
    //#Stimulus.DII.Pmon.v3.2.AxiRStall
    //#Stimulus.DII.Pmon.v3.2.ActiveWttEntries
    //#Stimulus.DII.Pmon.v3.2.ActiveRttEntries 
    //#Stimulus.DII.Pmon.v3.2.CapturedSmiPackets 
    //#Stimulus.DII.Pmon.v3.2.DroppedSmiPackets
    //#Stimulus.DII.Pmon.v3.2.AddressCollisions 
    //#Stimulus.DII.Pmon.v3.2.Div16

<%=obj.listEventArr.map(e =>`     ${e.name}`).join(',\n')%>
    } e_count_event;
  
    
     typedef enum bit [3-1:0] 
    {   //#Stimulus.DII.Pmon.v3.2.MinStallPeriod
        // Value is 2^(minimum stall period) clock cycles - valid range is 0 to 7
        NB_CYCLE_1   , // 000 – 2^0
        NB_CYCLE_2   , // 001 – 2^1
        NB_CYCLE_4   , // 010 – 2^2
        NB_CYCLE_8   , // 011 – 2^3 
        NB_CYCLE_16  , // 100 – 2^4 
        NB_CYCLE_32  , // 101 – 2^5
        NB_CYCLE_64  , // 110 – 2^6
        NB_CYCLE_128   // 111 – 2^7
    } e_minimum_stall_period;

   typedef enum bit [3-1:0] 
    {
        // Low pass filter coefficients (IIR filter)  1/value
        COEFF_0     , // 000 – 0
        COEFF_1_2   , // 001 – 1/2
        COEFF_1_4   , // 010 – 1/4
        COEFF_1_8   , // 011 – 1/8 
        COEFF_1_16  , // 100 – 1/16 
        COEFF_1_32  , // 101 – 1/32
        COEFF_1_64  , // 110 – 1/64
        COEFF_1_128   // 111 – 1/128
    } e_filter_select;

    typedef enum bit [3-1:0] 
    {   //#Stimulus.DII.Pmon.v3.2.CNTSRClear
        CLEAR          , // 000 – Clear CNTSR
        //#Stimulus.DII.Pmon.v3.2.Capture
        CAPTURE        , // 001 – Capture upper 63:31 count in CNTSR
        //#Stimulus.DII.Pmon.v3.2.LPF
        LPF            , // 010 – use CNTSR as low pass filter
        MAX_SATURATION ,  // 011 – use CNTSR as max/saturation value (currently used only for CHI AIU interleave count)
        //#Stimulus.DII.Pmon.v3.4.XCNT32BIT
        //#Stimulus.DMI.Pmon.v3.4.XCNT32BIT
        //#Stimulus.CHIAIU.Pmon.v3.4.XCNT32BIT
        COUNTER_32BIT_SAT   // 100 – use as 32-bit counter, for count event second 
        // 101 to 111 – reserved
    } e_ssr_count;

    typedef enum bit [3-1:0] 
    {
        
        //#Stimulus.DII.Pmon.v3.2.NormalMode
        NORMAL_C , // 000
        //#Stimulus.DII.Pmon.v3.2.AndMode
        AND_C    , // 001
        //#Stimulus.DII.Pmon.v3.2.XorMode
        XOR_C    , // 010
        //#Stimulus.DII.Pmon.v3.2.StaticMode
        STATIC_C ,  // 011
        //#Stimulus.DII.Pmon.v3.4.XCNT32BIT
        //#Stimulus.CHIAIU.Pmon.v3.4.XCNT32BIT
        //#Stimulus.IOAIU.Pmon.v3.4.XCNT32BIT
        COUNTER_32BIT_C // 1000
        // 101 to 111 – reserved
    } e_counter_control;

    typedef struct {
        bit unsigned [31:0] cnt_v;
        bit unsigned [31:0] cnt_v_str;
    } count_value_obj;
    
    typedef bit unsigned [64:0] counter_type;
    //Pmon 3.4 feature
    <% if (obj.BlockId.includes("dii") || (obj.testBench =="io_aiu")|| obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  
    ////// BW filter defines
    int xuser = <%=xUser%>;
    typedef bit unsigned [19:0] e_bw_filter_value;
    typedef enum bit  
    {
        USER_BITS_SELECT, //0
        FUNIT_ID_SELECT //1

    } e_bw_filter_select;
    typedef bit unsigned [19:0] e_bw_filter_mask;
    //Latency counter defines ////////

    typedef enum bit [1:0] 
    {
    // Value is 2^(minimum stall period+1) clock cycles - valid range is 0 to 3
    LCT_NB_CYCLE_2   , // 000 – 2^(0+1)
    LCT_NB_CYCLE_4   , // 001 – 2^(1+1)
    LCT_NB_CYCLE_8   , // 010 – 2^(2+1)
    LCT_NB_CYCLE_16    // 011 – 2^(3+1) 
    } e_latency_pre_scale;

    typedef enum bit 
    {
        LCT_READ,
        LCT_WRITE

    } e_latency_type;

    typedef bit unsigned [7:0] e_latency_bin_offset;

    <% } %>  

    /////////////////////////////////////////////////////////////
    //                      !!! Caution !! 
    //   If new fields are added , update/verify funcion  below
    //   hw-ncr/dv/common/lib_tb/perf_cnt_unit_cfg_seq.sv
    //                function get_write_data_cntcr
    /////////////////////////////////////////////////////////////

  //Counter Control Register (CNTCR) fields
    typedef struct {
		e_count_event          count_event_first        = SMI_0_Tx_Stall_event;
        e_count_event          count_event_second       = SMI_1_Tx_Stall_event;
        e_minimum_stall_period minimum_stall_period     = NB_CYCLE_1;
        e_filter_select        filter_select            = COEFF_0;
        e_ssr_count            ssr_count                = CAPTURE;
        e_counter_control      counter_control          = NORMAL_C;
        bit                    overflow_status          = 'b0;
        bit                    interrupt_enable         = 'b0;
        bit                    count_clear              = 'b0;
        bit                    count_enable             = 'b0;
    } st_cntcr_reg;
    //Pmon 3.4 feature
    <% if (obj.BlockId.includes("dii") || (obj.testBench =="io_aiu") || obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  

    typedef bit [8:0] latency_counter_type ;
    typedef latency_counter_type latency_counter_type_tab [];
    //BW Counter Filter Register (xBCNTFR) fields
    typedef struct {
		e_bw_filter_value         filter_value        = 20'h06;
        e_bw_filter_select        filter_select       = FUNIT_ID_SELECT;
        bit                       filter_enable       = 'b0;
    } st_bcntfr_reg;
    //BW Counter Mask Register (xBCNTMR) fields
    typedef struct {
		e_bw_filter_mask        mask_value        = 20'hFFFFF;
    } st_bcntmr_reg;

    typedef struct {
    
        e_latency_pre_scale     lct_pre_scale       = LCT_NB_CYCLE_2;
        bit                     lct_count_enable    = 1'b0;
        e_latency_type          lct_type            = LCT_WRITE;
        e_latency_bin_offset    lct_bin_offset      = 8'h0;

    } st_lcntcr_reg;
    bit [7:0] latency_cnt_bins;
    <% } %>  

    typedef struct {
        e_count_event		count_event_evt	= SMI_0_Tx_Stall_event;
        bit [31:0] cnt_v			= 0;
    } st_evt_xCNTVR;


    //Pmon 3.4 feature
    //Main Counter Control Register (xMCNTCR) fields
    typedef struct {
        //#Stimulus.CHIAIU.Pmon.v3.4.LocalEnableDisable
        //#Stimulus.IOAIU.Pmon.v3.4.LocalEnableDisable
        bit        local_count_enable        = 1'h0; //#Stimulus.DII.Pmon.v3.4.LocalEnableDisable
        //#Stimulus.IOAIU.Pmon.v3.4.LocalClear
        //#Stimulus.CHIAIU.Pmon.v3.4.LocalClear
        bit        local_count_clear         = 1'h0; //#Stimulus.DII.Pmon.v3.4.LocalClear
        bit        master_count_enable       = 1'h0;
    } st_xmcntcr_reg; 
 `ifndef FSYS_COVER_ON
 `ifndef IOAIU_SUBSYS_COVER_ON

<% if((obj.testBench == 'io_aiu')) { %>
    covergroup cov_perf_cnt_evt_xCNTVR (ref st_evt_xCNTVR rg);
    <% var local_count_event =["evt"] ;
        local_count_event.forEach(function(litteral_nbr) {
    %>
     count_event_<%=litteral_nbr%>_bins : coverpoint rg.count_event_<%=litteral_nbr%> {
    <% if (litteral_nbr =="evt") { %>

    <%=obj.listEventArr.map(e =>
`          ${(e.name.match(/reserved/i))?"ignore_":""}bins ${e.name}_bins = {${e.name}}; // ${e.evt_idx} ${(e.comment)?e.comment:""}`).join('\n') %>
    <%}%>       
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi') ||(obj.testBench == 'dce') ||(obj.testBench == 'dve')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
	`ifndef VCS
           ignore_bins Reserved_end_events     = {[<%=obj.listEventArr.length%>:63]};
	`endif // `ifndef VCS
<% } else {%>
           ignore_bins Reserved_end_events     = {[<%=obj.listEventArr.length%>:63]};
<% } %>
           ignore_bins not_event = {0};
           illegal_bins illegal_val = default;
        } 
    <%}) //end foreach local_count_event %>

        count_xcntvr_bins : coverpoint rg.cnt_v {
	       ignore_bins xcntvr_0    = {0};
	       	      bins xcntvr_1_5  = {[1:5]};
	              bins xcntvr_6_10 = {[6:10]};
            bins xcntvr_11_max = {[11:$]};
        }

        perf_evt_X_counter_value_bins : cross count_event_evt_bins,count_xcntvr_bins;
    endgroup : cov_perf_cnt_evt_xCNTVR
<% } %>

    covergroup cov_perf_cnt (ref st_cntcr_reg rg);
    
    <% var local_count_event =["first","second"] ;
        local_count_event.forEach(function(litteral_nbr) {
      %>
      <% if (litteral_nbr =="first") { %>
    //#Cover.DII.Pmon.v3.2.EventFirstTx0Stall 
    //#Cover.DII.Pmon.v3.2.EventFirstTx1Stall
    //#Cover.DII.Pmon.v3.2.EventFirstTx2Stall 
    //#Cover.DII.Pmon.v3.2.EventFirstRx0Stall
    //#Cover.DII.Pmon.v3.2.EventFirstRx1Stall 
    //#Cover.DII.Pmon.v3.2.EventFirstRx2Stall
    //#Cover.DII.Pmon.v3.2.EventFirstAXIAW 
    //#Cover.DII.Pmon.v3.2.EventFirstAXIW
    //#Cover.DII.Pmon.v3.2.EventFirstAXIB 
    //#Cover.DII.Pmon.v3.2.EventFirstAXIAR
    //#Cover.DII.Pmon.v3.2.EventFirstAXIR 
    //#Cover.DII.Pmon.v3.2.EventFirstActiveWttEntries
    //#Cover.DII.Pmon.v3.2.EventFirstActiveRttEntries 
    //#Cover.DII.Pmon.v3.2.EventFirstActiveRttEntries
    //#Cover.DII.Pmon.v3.2.EventFirstCapturedSmiPackets 
    //#Cover.DII.Pmon.v3.2.EventFirstDroppedSmiPackets 
    //#Cover.DII.Pmon.v3.2.EventFirstAddressCollisions	
    //#Cover.DII.Pmon.v3.2.EventFirstDiv16
    //#Cover.DII.Pmon.v3.4.DtrReq 
    //#Cover.DMI.Pmon.v3.4.DtrReq 
    //#Cover.DII.Pmon.v3.4.DtwReq
    //#Cover.DMI.Pmon.v3.4.DtwReq
    //#Cover.CHIAIU.Pmon.v3.4.CmdReqWr 
    //#Cover.CHIAIU.Pmon.v3.4.CmdReqRd 
    //#Cover.CHIAIU.Pmon.v3.4.SnpRsp
    //#Cover.IOAIU.Pmon.v3.4.CmdReqWR 
    //#Cover.IOAIU.Pmon.v3.4.CmdReqRD 
    //#Cover.IOAIU.Pmon.v3.4.SnpReq 
      <%} else { %> 
    //#Cover.DII.Pmon.v3.2.EventSecondTx0Stall 
    //#Cover.DII.Pmon.v3.2.EventSecondTx1Stall
    //#Cover.DII.Pmon.v3.2.EventSecondTx2Stall 
    //#Cover.DII.Pmon.v3.2.EventSecondRx0Stall
    //#Cover.DII.Pmon.v3.2.EventSecondRx1Stall
    //#Cover.DII.Pmon.v3.2.EventSecondRx2Stall
    //#Cover.DII.Pmon.v3.2.EventSecondAXIAW
    //#Cover.DII.Pmon.v3.2.EventSecondAXIW
    //#Cover.DII.Pmon.v3.2.EventSecondAXIB
    //#Cover.DII.Pmon.v3.2.EventSecondAXIAR
    //#Cover.DII.Pmon.v3.2.EventSecondAXIR
    //#Cover.DII.Pmon.v3.2.EventSecondActiveWttEntries
    //#Cover.DII.Pmon.v3.2.EventSecondActiveRttEntries
    //#Cover.DII.Pmon.v3.2.EventSecondActiveRttEntries
    //#Cover.DII.Pmon.v3.2.EventSecondCapturedSmiPackets
    //#Cover.DII.Pmon.v3.2.EventSecondDroppedSmiPackets
    //#Cover.DII.Pmon.v3.2.EventSecondAddressCollisions
    //#Cover.DII.Pmon.v3.2.EventSecondDiv16
      <%}%>  
     count_event_<%=litteral_nbr%>_bins : coverpoint rg.count_event_<%=litteral_nbr%> {
    <% if (litteral_nbr =="second") { %>
    <%=obj.listEventArr.map(e =>
`          ${(e.name.match(/reserved/i)) || (e.name.match(/Active/i)) || (e.type == "bw") || (e.name.match(/interleave/i)) || (e.name.match(/DtwDbgReq/i)) ?"ignore_":""}bins ${e.name}_bins = {${e.name}}; // ${e.evt_idx} ${(e.comment)?e.comment:""}`).join('\n') %>
    <%} else { %> 
    <%=obj.listEventArr.map(e =>
`          ${(e.name.match(/reserved/i))?"ignore_":""}bins ${e.name}_bins = {${e.name}}; // ${e.evt_idx} ${(e.comment)?e.comment:""}`).join('\n') %>
    <%}%>       
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi') ||(obj.testBench == 'dce') ||(obj.testBench == 'dve')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
`ifndef VCS
           ignore_bins Reserved_end_events     = {[<%=obj.listEventArr.length%>:63]};
`endif // `ifndef VCS
<% } else {%>
           ignore_bins Reserved_end_events     = {[<%=obj.listEventArr.length%>:63]};
<% } %>
           ignore_bins not_event = {0};
           illegal_bins illegal_val = default;
        } 
    <%}) //end foreach local_count_event %>
        //#Cover.DII.Pmon.v3.2.MinStallPeriod
        minimum_stall_period_bins : coverpoint rg.minimum_stall_period {

            bins NB_CYCLE_1_bins     = {NB_CYCLE_1};  
            bins NB_CYCLE_2_bins     = {NB_CYCLE_2};  
            bins NB_CYCLE_4_bins     = {NB_CYCLE_4};  
            bins NB_CYCLE_8_bins     = {NB_CYCLE_8};  
            bins NB_CYCLE_16_bins    = {NB_CYCLE_16}; 
            bins NB_CYCLE_32_bins    = {NB_CYCLE_32}; 
            bins NB_CYCLE_64_bins    = {NB_CYCLE_64}; 
            bins NB_CYCLE_128_bins   = {NB_CYCLE_128};
            illegal_bins illegal_val = default;

        }
        //#Cover.DII.Pmon.v3.2.LPF.COEFF
        filter_select_bins : coverpoint rg.filter_select {
    
            bins COEFF_0_bins        = {COEFF_0};  
            bins COEFF_1_2_bins      = {COEFF_1_2};  
            bins COEFF_1_4_bins      = {COEFF_1_4};  
            bins COEFF_1_8_bins      = {COEFF_1_8};  
            bins COEFF_1_16_bins     = {COEFF_1_16}; 
            bins COEFF_1_32_bins     = {COEFF_1_32}; 
            bins COEFF_1_64_bins     = {COEFF_1_64}; 
            bins COEFF_1_128_bins    = {COEFF_1_128};
            illegal_bins illegal_val = default;
        }

        ssr_count_bins : coverpoint rg.ssr_count {
            //#Cover.DII.Pmon.v3.2.SSR.CLEAR
            bins CLEAR_bins          = {CLEAR};  
            //#Cover.DII.Pmon.v3.2.SSR.CAPTURE
            bins CAPTURE_bins        = {CAPTURE};  
            //#Cover.DII.Pmon.v3.2.SSR.LPF
            bins LPF_bins            = {LPF}; 
          <% if((obj.testBench == 'chi_aiu') || (obj.testBench == 'io_aiu')) { %>
            bins MAX_SATURATION_bins = {MAX_SATURATION}; 
            <% } %>
            //#Cover.DII.Pmon.v3.4.SSR.32BIT
            //#Cover.DMI.Pmon.v3.4.SSR.32BIT
            //#Cover.CHIAIU.Pmon.v3.4.SSR.32BIT
            //#Cover.IOAIU.Pmon.v3.4.SSR.32BIT
            bins COUNTER_32BIT_SAT_bins = {COUNTER_32BIT_SAT}; 
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi') ||(obj.testBench == 'dce')||(obj.testBench == 'dve')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
`ifndef VCS
            bins RESERVED            = {[3'b101:3'b111]};   
`endif // `ifndef VCS
<% } else {%>
            bins RESERVED            = {[3'b101:3'b111]};   
<% } %>
            illegal_bins illegal_val = default;
        }

        counter_control_bins : coverpoint rg.counter_control {
            //#Cover.DII.Pmon.v3.2.CONTROL.Normal
            //#Cover.CHIAIU.Pmon.v3.2.CONTROL.Normal
            bins NORMAL_C_bins          = {NORMAL_C};
            //#Cover.DII.Pmon.v3.2.CONTROL.AND
            //#Cover.CHIAIU.Pmon.v3.2.CONTROL.AND
            bins AND_C_bins             = {AND_C};    
            //#Cover.DII.Pmon.v3.2.CONTROL.XOR
            //#Cover.CHIAIU.Pmon.v3.2.CONTROL.XOR
            bins XOR_C_bins             = {XOR_C}; 
            //#Cover.DII.Pmon.v3.2.CONTROL.STATIC 
            //#Cover.CHIAIU.Pmon.v3.2.CONTROL.STATIC 
            bins STATIC_C_bins          = {STATIC_C};
            //#Cover.DII.Pmon.v3.4.CONTROL.32BIT
            //#Cover.DMI.Pmon.v3.4.CONTROL.32BIT
            //#Cover.CHIAIU.Pmon.v3.4.CONTROL.32BIT
            //#Cover.IOAIU.Pmon.v3.4.CONTROL.32BIT
            bins COUNTER_32BIT_C_bins   = {COUNTER_32BIT_C}; 
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi') ||(obj.testBench == 'dce')||(obj.testBench == 'dve')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
`ifndef VCS
            bins RESERVED            = {[3'b101:3'b111]};   
`endif // `ifndef VCS
<% } else {%>
            bins RESERVED            = {[3'b101:3'b111]};   
<% } %>
            illegal_bins illegal_val = default;
        }

        interrupt_enable_bins : coverpoint rg.interrupt_enable {
            bins ENABLE_INTR         = {1'b1};
            bins DISABLE_INTR        = {1'b0};     
            illegal_bins illegal_val = default;
        }

        count_clear_bins : coverpoint rg.count_clear {
            bins CLEAR_COUNT         = {1'b1};
            bins NOT_CLEAR           = {1'b0};     
            illegal_bins illegal_val = default;
        }
                
        count_enable_bins : coverpoint rg.count_enable {
            bins ENABLE_COUNT        = {1'b1};
            bins DISABLE_COUNT       = {1'b0};     
            illegal_bins illegal_val = default;
        }
        
        ssr_count_X_counter_control_bins : cross ssr_count_bins,counter_control_bins {
            ignore_bins ignore_not_possible_ssr_coubnt_and_counter_control_bins = (
                binsof(ssr_count_bins) intersect {LPF} && binsof(counter_control_bins) intersect {NORMAL_C,AND_C,XOR_C,COUNTER_32BIT_C})
        
            ||

            (binsof(ssr_count_bins) intersect {MAX_SATURATION} && binsof(counter_control_bins) intersect {NORMAL_C,AND_C,XOR_C,STATIC_C,COUNTER_32BIT_C})
            ||

            (binsof(ssr_count_bins) intersect {CAPTURE} && binsof(counter_control_bins) intersect {STATIC_C,COUNTER_32BIT_C})
            ||

            (binsof(ssr_count_bins) intersect {COUNTER_32BIT_SAT} && binsof(counter_control_bins) intersect {NORMAL_C,AND_C,XOR_C,STATIC_C})
            ||

            (binsof(ssr_count_bins) intersect {CLEAR} && binsof(counter_control_bins) intersect {AND_C,XOR_C,STATIC_C,COUNTER_32BIT_C});
            
            

            
        }
        //count_event_first_X_count_event_second_bins : cross count_event_first_bins,count_event_second_bins { 
        //ignore_bins ignore_not_possible_count_event_combinaison = (
        //    binsof (count_event_first_bins) intersect {<%=obj.listEventStallName.map(item => `${item}`).join(",")%>} && 
        //    binsof (count_event_second_bins) intersect {${obj.listEventArr.filter(e => (e.width > 1 || e.name == obj.listEventArr[0].name)).map(e => e.name).join(',')}}
        //) || 
        //
        //(
        //    binsof (count_event_second_bins) intersect {<%=obj.listEventStallName.map(item => `${item}`).join(",")%>} && 
        //    binsof (count_event_first_bins) intersect {${obj.listEventArr.filter(e => (e.width > 1 || e.name == obj.listEventArr[0].name)).map(e => e.name).join(',')}}
        //)
//
        //;
        //}
    
    endgroup : cov_perf_cnt
//Pmon 3.4 feature
    covergroup cov_main_cnt (ref st_xmcntcr_reg rg);

        local_count_clear_bins : coverpoint rg.local_count_clear {
            bins CLEAR_COUNT         = {1'b1};
            bins NOT_CLEAR           = {1'b0};     
            illegal_bins illegal_val = default;
        }
                
        local_count_enable_bins : coverpoint rg.local_count_enable {
            bins ENABLE_COUNT        = {1'b1};
            bins DISABLE_COUNT       = {1'b0};     
            illegal_bins illegal_val = default;
        }

<% if (obj.BlockId.includes("dve")) { %>
        master_count_enable_bins : coverpoint rg.master_count_enable {
            bins ENABLE_COUNT        = {1'b1};
            bins DISABLE_COUNT       = {1'b0};     
            illegal_bins illegal_val = default;
        }
<% } %>
    endgroup : cov_main_cnt
<% if (obj.BlockId.includes("dii") || (obj.testBench =="io_aiu") || obj.BlockId.includes("dmi") || (obj.BlockId.includes("aiu") && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>  
 
covergroup cov_bw_cnt (ref st_bcntfr_reg rg);
    //#Cover.DII.Pmon.v3.4.FilterSelect
    //#Cover.DMI.Pmon.v3.4.FilterSelect
    //#Cover.CHIAIU.Pmon.v3.4.FilterSelect
    //#Cover.IOAIU.Pmon.v3.4.FilterSelect
    filter_select_bins : coverpoint rg.filter_select {
        <% if ( xUser > 0) {  %>  
        bins USER_BITS_SELECT_bins    = {USER_BITS_SELECT};
        <% } else { %>
        ignore_bins USER_BITS_SELECT_bins    = {USER_BITS_SELECT};
        <% } %>
        bins FUNIT_ID_SELECT_bins     = {FUNIT_ID_SELECT};  
        illegal_bins illegal_val = default;

    }
endgroup : cov_bw_cnt

 
covergroup cov_lct_cnt (ref st_lcntcr_reg rg);
    //#Cover.DII.Pmon.v3.4.LatencyScale
    //#Cover.DMI.Pmon.v3.4.LatencyScale
    //#Cover.CHIAIU.Pmon.v3.4.LatencyScale
    //#Cover.IOAIU.Pmon.v3.4.LatencyScale
    lct_pre_scale_bins : coverpoint rg.lct_pre_scale {

    bins LCT_NB_CYCLE_2_bins  =  {LCT_NB_CYCLE_2};
    bins LCT_NB_CYCLE_4_bins  =  {LCT_NB_CYCLE_4};
    bins LCT_NB_CYCLE_8_bins  =  {LCT_NB_CYCLE_8};
    bins LCT_NB_CYCLE_16_bins =  {LCT_NB_CYCLE_16};
    illegal_bins illegal_val = default;

    }
    //#Cover.DII.Pmon.v3.4.LatencyType
    //#Cover.DMI.Pmon.v3.4.LatencyType
    //#Cover.CHIAIU.Pmon.v3.4.LatencyType
    //#Cover.IOAIU.Pmon.v3.4.LatencyType
    lct_type_bins : coverpoint rg.lct_type {
    bins LCT_READ_bins = {LCT_READ};
    bins LCT_WRITE_bins = {LCT_WRITE};
    illegal_bins illegal_val = default;
    }
    //#Cover.IOAIU.Pmon.v3.7.1LatencyOffset
    lct_offset_bins : coverpoint rg.lct_bin_offset {
      bins lct_offset_bins_0X3f = {[0:63]};
      bins lct_offset_bins_40X7f = {[64:127]};
      bins lct_offset_bins_80Xbf = {[128:191]};
      bins lct_offset_bins_c0Xff = {[192:255]};
    }
    //#Cover.IOAIU.Pmon.v3.7.1LatencyCounterBins
    lct_cnt_bins : coverpoint latency_cnt_bins {
     wildcard bins xCNTVR0 = {8'b???????1};
     wildcard bins xCNTSR0 = {8'b??????1?};
     wildcard bins xCNTVR1 = {8'b?????1??};
     wildcard bins xCNTSR1 = {8'b????1???};
     wildcard bins xCNTVR2 = {8'b???1????};
     wildcard bins xCNTSR2 = {8'b??1?????};
     wildcard bins xCNTVR3 = {8'b?1??????};
     wildcard bins xCNTSR3 = {8'b1???????};
    }
    //#Cover.IOAIU.Pmon.v3.7.1Latency_scale_type_offset_cntbins
   crossXcov_lct_cnt : cross lct_pre_scale_bins,lct_type_bins,lct_offset_bins,lct_cnt_bins;

endgroup : cov_lct_cnt

<% }  %>  
`endif // `ifndef IOAIU_SUBSYS_COVER_ON
`endif // `ifndef FSYS_COVER_ON

endpackage: <%=obj.BlockId%>_perf_cnt_unit_defines
