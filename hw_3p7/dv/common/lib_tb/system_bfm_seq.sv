//#Stimulus.CHI.v3.6.NewCommands.Error_first_cmd
//#Stimulus.CHI.v3.6.NewCommands.Error_second_cmd
//#Stimulus.CHI.v3.6.CleanSharedPersistSep.Error
//#Stimulus.CHI.v3.7.WriteEvictOrEvict.Error

`ifndef SYSTEM_BFM_SEQ
`define SYSTEM_BFM_SEQ
typedef enum bit [2:0] {
     SysBfmIX, SysBfmSC, SysBfmSD, SysBfmUC, SysBfmUD, SysBfmSCOwner
} bfm_cacheState_t;

typedef enum bit [2:0] {
    State_Invalid = 3'b000, State_Owner = 3'b010, State_Sharer = 3'b011, State_Unique = 3'b100
} strReq_cmstatus_State_t;

typedef struct packed {
    smi_cmstatus_so_t SO; 
    smi_cmstatus_ss_t SS; 
    smi_cmstatus_sd_t SD; 
    smi_cmstatus_st_t ST; 
} coherResult_t;

<%
var DVMV8_4=(obj.DveInfo[0].DVMVersionSupport==132)?1:0;
var DVMV8_1=(obj.DveInfo[0].DVMVersionSupport==129)?1:0;
var DVMV8_0=(obj.DveInfo[0].DVMVersionSupport==128)?1:0;
%>

/////////////////////////////////////////////////////////give_random_dvm_addr///////////////////////
//
// System BFM Master Sequence
//
////////////////////////////////////////////////////////////////////////////////
<%     
        var num_of_dvms = 0;
        var num_of_dvms_sources = 0;
        for (var i = 0; i < obj.AiuInfo.length; i++) {
	    if((obj.AiuInfo[i].fnNativeInterface == "CHI-A")||(obj.AiuInfo[i].fnNativeInterface == "CHI-B") || (obj.AiuInfo[i].fnNativeInterface == "CHI-E")) {
	       if(obj.AiuInfo[i].cmpInfo.nDvmMsgInFlight) {
                  num_of_dvms_sources++;
                  num_of_dvms++;
	       } else if(obj.AiuInfo[i].cmpInfo.nDvmSnpInFlight) {
                  num_of_dvms++;
	       }
	    } else {
            for (let j=0; j<obj.AiuInfo[i].interfaces.axiInt.length; j++){
                if(obj.AiuInfo[i].interfaces.axiInt[j].params.eAc && obj.AiuInfo[i].interfaces.axiInt[j].params.eAc === 1) {
                  num_of_dvms++;
                }
            }
	    }
	    if((obj.AiuInfo[i].fnNativeInterface == "CHI-A")||(obj.AiuInfo[i].fnNativeInterface == "CHI-B") || (obj.AiuInfo[i].fnNativeInterface == "CHI-E")) {
	       if(obj.wXData > obj.AiuInfo[i].interfaces.chiInt.params.wData) {
	          unit_with_smaller_bus_width = 1
               }					      
	    } else {

            for (let j=0; j<obj.AiuInfo[i].interfaces.axiInt.length; j++){
                if(obj.AiuInfo[i].interfaces.axiInt[j].params.wData && (obj.wXData > obj.AiuInfo[i].interfaces.axiInt[j].params.wData)) {
    	            unit_with_smaller_bus_width = 1
                }
            }
	    }
        }
        if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { 
           var id_snoop_filter_slice = obj.sfid;
        }
        else if (obj.useCache) { 
	   var id_snoop_filter_slice = obj.sfid;
        }
        else if ((obj.fnNativeInterface == "CHI-A")||(obj.fnNativeInterface == "CHI-B") || (obj.fnNativeInterface == "CHI-E")) { 
	   var id_snoop_filter_slice = Math.floor(Math.random() * obj.SnoopFilterInfo.length);
        }
        else {
            var id_snoop_filter_slice = 0;
        }
	
%>
        <%
        var aiuid, sfid, sftype;
        var wrevict = 0;
        sfid   = obj.sfid;					      
        sftype = obj.sftype;
	var max_dvms = obj.DveInfo[0].nDVMAgentAius;
	if(obj.fnNativeInterface === "ACE-LITE") {
	   wrevict = 0;
	} else {
	   wrevict = obj.useWriteEvict;
	}
	  var n_snoops = 0;
	  for(var i=0; i < obj.nDCEs; i++) {
	    n_snoops += obj.DceInfo[i].nSnpsPerAiu;
	  }
	if(obj.Block == "io_aiu") {
	   n_snoops = obj.nSttCtrlEntries;
	   max_dvms = obj.nDvmSnpInFlight;
	}    
	if(obj.Block == "chi_aiu") {
	   n_snoops = n_snoops + obj.nDvmSnpInFlight;
	   max_dvms = obj.nDvmSnpInFlight;
	}


        %> 

////////////////////////////////////////////////////////////////////////////////
//
// System BFM Sequence
//
////////////////////////////////////////////////////////////////////////////////

int select_core_q[$];

class notDVMSyncAddr;
    rand bit[2:0] m_return_value;

    constraint c_return_value {
        m_return_value != 'b100;
    }
    <% if(obj.Block == "io_aiu") { %>
    constraint c_return_valud_ioaiu {
        m_return_value inside {'b000, 'b001, 'b010, 'b011, 'b110};
    }
    <% } %>
    <% if(obj.Block == "chi_aiu") { %>
    constraint c_return_valid_chiaiu {
        m_return_value inside {'b000, 'b001, 'b010, 'b011};
    }
    <% } %>
endclass : notDVMSyncAddr

<% if ((obj.testBench == "chi_aiu") || (obj.testBench == "io_aiu")) { %>
// CONC-7994, Error-1 : SnpDVMOp, Invalid Physical Instruction Cache Invalidate DVM operation type received having Address field in first part SNPDVMOp, Addr[8:4] observed is 	 11110 
class valid_address_for_dvm_operation_xact;
  rand smi_addr_security_t addr;

  constraint c_valid_address_for_dvm_operation_xact {
   // Constraints related to addr field for DVM Operation.
     
   	 // addr[3:0] are reserved and should be zero for DVM.
     addr[3:0] == 4'b0;

     addr[4] inside  {1'b0,1'b1};

     addr[5] inside  {1'b0,1'b1};

     addr[6] inside  {1'b0,1'b1};

    <% if (DVMV8_4 && (obj.testBench == "chi_aiu")) { %>
     addr[8:7] inside  {[2'b00:2'b11]};
    <% } else { %>    
     addr[8:7] inside  {2'b00,2'b10,2'b11};
    <% } %>


     // The values 3'b101-3'b111 on DVM message type field in DVM Request
     // Payload is reserved.
     <% if (obj.testBench == "chi_aiu") { %>
     addr[13:11] inside  {[3'b000:3'b100]};
     <% } else { %>
     addr[13:11] inside  {[3'b000:3'b100],'b110};
     <% } %>

<% if (obj.AiuInfo[obj.Id].wAddr > 40) { %>

    <% if ((obj.testBench == "chi_aiu")) { %>
        addr[39:38] inside  {[2'b00:2'b10]};
    <% } else { %>    
        <% if (obj.wAddr >= 39) { %>
            addr[39:38] inside  {[2'b00:2'b11]};
        <% } %>
    <% } %>

    <% if ((obj.testBench == "chi_aiu")) { %>
        addr[40] inside  {1'b0,1'b1};
    <% } else { %>    
        <% if (obj.wAddr >= 40) { %>
            addr[40] inside  {1'b0,1'b1};
        <% } %>
    <% } %>
     
    <% if ((obj.testBench == "chi_aiu")) { %>
        <% if (obj.AiuInfo[obj.Id].wAddr >= 46) { %>
        addr[WSMIADDR-1:46] == 'b0;
        <% } %>
    <% } else { %>    
        <% if (obj.wAddr >= 42) { %>
            //higher unused address fields should be 0
            addr[WSMIADDR-1:41] == 0;
        <% } %>
    <% } %>


     /** TLB constraints */
     //TLB Invalidate not supported operations. 
     if (addr[13:11] == 3'b000) {

        {addr[10:9],addr[8:7],addr[6],addr[5],addr[40],addr[39:38],addr[4]} 
            inside {
                    {2'b10 ,2'b10 ,1'b0 ,1'b0 ,1'b0 ,2'b00 ,1'b0}, // Secure TLB Invalidate all
                    {2'b10 ,2'b10 ,1'b0 ,1'b0 ,1'b0 ,2'b00 ,1'b1}, // Secure TLB Invalidate by VA
                    {2'b10 ,2'b10 ,1'b0 ,1'b0 ,1'b1 ,2'b00 ,1'b1}, // Secure TLB Invalidate by VA Leaf Entry only
                    {2'b10 ,2'b10 ,1'b1 ,1'b0 ,1'b0 ,2'b00 ,1'b0}, // Secure TLB Invalidate by ASID
                    {2'b10 ,2'b10 ,1'b1 ,1'b0 ,1'b0 ,2'b00 ,1'b1}, // Secure TLB Invalidate by ASID and VA
                    {2'b10 ,2'b10 ,1'b1 ,1'b0 ,1'b1 ,2'b00 ,1'b1}, // Secure TLB Invalidate by ASID and VA Leaf Entry only
                    <% if (DVMV8_4) { %>
                    {2'b10 ,2'b10 ,1'b0 ,1'b1 ,1'b0 ,2'b01 ,1'b0}, // Secure Guest OS, TLBI all, S1 invalidation only
                    {2'b10 ,2'b10 ,1'b1 ,1'b1 ,1'b0 ,2'b00 ,1'b0}, // Secure Guest OS, TLBI by ASID
                    {2'b10 ,2'b10 ,1'b0 ,1'b1 ,1'b0 ,2'b00 ,1'b1}, // Secure Guest OS, TLBI by VA
                    {2'b10 ,2'b10 ,1'b0 ,1'b1 ,1'b1 ,2'b00 ,1'b1}, // Secure Guest OS, TLBI by VA, Leaf only
                    {2'b10 ,2'b10 ,1'b1 ,1'b1 ,1'b0 ,2'b00 ,1'b1}, // Secure Guest OS, TLBI by ASID and VA
                    {2'b10 ,2'b10 ,1'b1 ,1'b1 ,1'b1 ,2'b00 ,1'b1}, // Secure Guest OS, TLBI by ASID and VA, Leaf only
                    {2'b10 ,2'b10 ,1'b0 ,1'b1 ,1'b0 ,2'b10 ,1'b1}, // Secure Guest OS, TLBI by Secure IPA
                    {2'b10 ,2'b10 ,1'b0 ,1'b1 ,1'b1 ,2'b10 ,1'b1}, // Secure Guest OS, TLBI by Secure IPA, Leaf only
                    {2'b10 ,2'b10 ,1'b0 ,1'b1 ,1'b0 ,2'b00 ,1'b0}, // Secure Guest OS TLBI all
                    {2'b10 ,2'b01 ,1'b0 ,1'b1 ,1'b0 ,2'b10 ,1'b1}, // Secure Guest OS, TLBI by Non-secure IPA
                    {2'b10 ,2'b01 ,1'b0 ,1'b1 ,1'b1 ,2'b10 ,1'b1}, // Secure Guest OS, TLBI by Non-secure IPA Leaf only
                    <% } %>
                    {2'b10 ,2'b11 ,1'b0 ,1'b0 ,1'b0 ,2'b00 ,1'b0}, // All Guest OS TLB Invalidate all
                    {2'b10 ,2'b11 ,1'b0 ,1'b1 ,1'b0 ,2'b01 ,1'b0}, // Guest OS TLB Invalidate all, Stage 1 invalidation only
                    {2'b10 ,2'b11 ,1'b0 ,1'b1 ,1'b0 ,2'b00 ,1'b0}, // Guest OS TLB Invalidate all, ARMv7 must carry out Stage 1 and Stage 2 invalidation.
                    {2'b10 ,2'b11 ,1'b0 ,1'b1 ,1'b0 ,2'b00 ,1'b1}, // Guest OS TLB Invalidate by VA
                    {2'b10 ,2'b11 ,1'b0 ,1'b1 ,1'b1 ,2'b00 ,1'b1}, // Guest OS TLB Invalidate by VA Leaf Entry only
                    {2'b10 ,2'b11 ,1'b1 ,1'b1 ,1'b0 ,2'b00 ,1'b0}, // Guest OS TLB Invalidate by ASID
                    {2'b10 ,2'b11 ,1'b1 ,1'b1 ,1'b0 ,2'b00 ,1'b1}, // Guest OS TLB Invalidate by ASID and VA
                    {2'b10 ,2'b11 ,1'b1 ,1'b1 ,1'b1 ,2'b00 ,1'b1}, // Guest OS TLB Invalidate by ASID and VA Leaf Entry only
                    {2'b10 ,2'b11 ,1'b0 ,1'b1 ,1'b0 ,2'b10 ,1'b1}, // Guest OS TLB Invalidate by IPA
                    {2'b10 ,2'b11 ,1'b0 ,1'b1 ,1'b1 ,2'b10 ,1'b1}, // Guest OS TLB Invalidate by IPA Leaf Entry only
                    <% if (DVMV8_4) { %>
                    {2'b11 ,2'b10 ,1'b0 ,1'b0 ,1'b0 ,2'b00 ,1'b0}, // Secure Hypervisor, TLBI all
                    {2'b11 ,2'b10 ,1'b1 ,1'b0 ,1'b0 ,2'b00 ,1'b1}, // Secure Hypervisor, TLBI by ASID and VA
                    {2'b11 ,2'b10 ,1'b1 ,1'b0 ,1'b1 ,2'b00 ,1'b1}, // Secure Hypervisor, TLBI by ASID and VA Leaf only
                    {2'b11 ,2'b10 ,1'b0 ,1'b0 ,1'b0 ,2'b00 ,1'b1}, // Secure Hypervisor, TLBI by VA
                    {2'b11 ,2'b10 ,1'b0 ,1'b0 ,1'b1 ,2'b00 ,1'b1}, // Secure Hypervisor, TLBI by VA, Leaf only
                    {2'b11 ,2'b10 ,1'b1 ,1'b0 ,1'b0 ,2'b00 ,1'b0}, // Secure Hypervisor, TLBI by ASID
                    <% } %>
                    {2'b11 ,2'b11 ,1'b0 ,1'b0 ,1'b0 ,2'b00 ,1'b0}, // Hypervisor TLB Invalidate all
                    {2'b11 ,2'b11 ,1'b0 ,1'b0 ,1'b0 ,2'b00 ,1'b1}, // Hypervisor TLB Invalidate by VA
                    {2'b11 ,2'b11 ,1'b0 ,1'b0 ,1'b1 ,2'b00 ,1'b1}, // Hypervisor TLB Invalidate by VA Leaf Entry only
                    <% if (DVMV8_1 || DVMV8_4) { %>
                    {2'b11 ,2'b11 ,1'b1 ,1'b0 ,1'b0 ,2'b00 ,1'b0}, // Hypervisor TLB Invalidate by ASID
                    {2'b11 ,2'b11 ,1'b1 ,1'b0 ,1'b0 ,2'b00 ,1'b1}, // Hypervisor TLB Invalidate by ASID and VA
                    {2'b11 ,2'b11 ,1'b1 ,1'b0 ,1'b1 ,2'b00 ,1'b1}, // Hypervisor TLB Invalidate by ASID and VA Leaf Entry only
                    <% } %>
                    {2'b01 ,2'b10 ,1'b0 ,1'b0 ,1'b0 ,2'b00 ,1'b1}, // EL3 TLB Invalidate by VA
                    {2'b01 ,2'b10 ,1'b0 ,1'b0 ,1'b1 ,2'b00 ,1'b1}, // EL3 TLB Invalidate by VA Leaf Entry only
                    {2'b01 ,2'b10 ,1'b0 ,1'b0 ,1'b0 ,2'b00 ,1'b0}  // EL3 TLB Invalidate All
                };
     }

     // Branch Predictor Invalidate applies to all Guest OS and Hypervisor,
     // applies to Secure and Non-Secure. 
     if (addr[13:11] == 3'b001) {
       addr[40] == 1'b0;
       addr[39:38] == 2'b00;
       addr[10:9] == 2'b00;
       addr[8:7] == 2'b00;
       //ASID,VMID valid field restrictions.
       addr[6] == 1'b0;
       addr[5] == 1'b0;
     }

     /** Phy Icache Invalidate constraints */
     // Phy Icache Invalidate applies to all Guest OS and Hypervisor.
     if (addr[13:11] == 3'b010) {
       addr[40] == 1'b0;
       addr[39:38] == 2'b00;
       addr[10:9] == 2'b00;
       addr[8:7] inside  {2'b10,2'b11};
       addr[6:4] inside  {3'b000,3'b001,3'b111};
     }

     /** Virtual Icache Invalidate constraints */
     // Virtual Icache Invalidate applies to all Guest OS and Hypervisor.
     if (addr[13:11] == 3'b011) {
       addr[40] == 1'b0;
       addr[39:38] == 2'b00;
       addr[10:9] inside  {2'b00,2'b10,2'b11};

       if(addr[10:9] == 2'b00){
         addr[8:4] inside  {5'b00000,5'b11000};
       }  
       else if(addr[10:9] == 2'b10){
            <% if (DVMV8_4) { %>
             addr[8:4] inside  {5'b10101,5'b10010,5'b10111,5'b11010,5'b11111};
            <% } else { %>    
             addr[8:4] inside  {5'b10101,5'b11010,5'b11111};
            <% } %>
       }
       else {
            <% if (DVMV8_1 || DVMV8_4) { %>
                addr[8:4] inside {5'b11001,5'b11101};
            <% } else { %>    
                addr[8:4] inside {5'b11001};
            <% } %>
       } 
     }

     /**  DVM Sync operation constraints */
     // DVM Sync operation applies to all Guest OS and Hypervisor,
     // applies to Secure and Non-Secure. 
     if (addr[13:11] == 3'b100) {
        <% if ((obj.testBench == "chi_aiu")) { %>
            addr[40] == 1'b0;
        <% } else { %>    
            <% if (obj.wAddr >= 40) { %>
                addr[40] == 1'b0;
            <% } %>
        <% } %>

        <% if ((obj.testBench == "chi_aiu")) { %>
            addr[39:38] == 2'b00;
        <% } else { %>    
            <% if (obj.wAddr >= 39) { %>
                addr[39:38] == 2'b00;
            <% } %>
        <% } %>
            addr[10:9] == 2'b00;
            addr[8:7] == 2'b00;
            addr[5] == 1'b0;
            addr[6] == 1'b0;
            addr[4] == 1'b0;
     }

<% } %>

  }

endclass
<% } %>

class system_bfm_seq extends uvm_sequence;

    `uvm_object_param_utils(system_bfm_seq)
    parameter int SYS_wSysCacheline = 6;
    smi_ncore_unit_id_bit_t DVE_Targ_Id[$];//<%=obj.AiuInfo.length + obj.DceInfo.length%>; 
    smi_ncore_unit_id_bit_t DCE_Funit_Id[$];//<%=obj.DceInfo.length%>; 
    smi_ncore_unit_id_bit_t DMI_Funit_Id[$];//<%=obj.DmiInfo.length%>; 
    smi_ncore_unit_id_bit_t DII_Funit_Id[$];//<%=obj.DiiInfo.length%>; 

    typedef struct {
        smi_src_id_bit_t      m_aiu_id;
        smi_msg_id_t          m_aiu_trans_id;
    } aiu_id_t;

    typedef struct {
        smi_addr_security_t m_addr;
        smi_unq_identifier_bit_t m_smi_unq_id;
    } req_in_process_t;

    typedef struct {
        smi_addr_security_t m_addr;
        bfm_cacheState_t    m_cache_state;
        bit                 m_isDVM;
        bit                 m_isCoherent;
    } str_state_list_t;

    typedef struct {
        smi_addr_security_t  m_addr;
        smi_seq_item         m_seq_item;
        time                 t_smi_ndp_ready;
        eMsgCMD              cmd_type;
    } smi_seq_item_addr_t;

    smi_seq      m_snpreq_tx;
    smi_seq      m_allrsp_tx;
    smi_seq      m_strreq_tx;
    smi_seq      m_dtrreq_tx;
    smi_seq      m_sysreq_tx;

    addr_trans_mgr m_addr_mgr;
    bit start_snoop_traffic;
    bit pause_snoops_traffic = 0;
    int stt_fill_count;
    int max_stt_fill_count;
    int select_core;
    smi_msg_id_bit_t dvm_msg_ids[smi_rbid_t];

    // Control Knobs
    bit                    aiu_scb_en;
   <%if(obj.Block =='io_aiu'){%>
   ioaiu_scoreboard        ioaiu_scb_handle;
   <%}%>
    <% if( obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
        ioaiu_scoreboard       m_ncbu_cache_handle;
    <%}%>
    <% if(obj.useCache ) {%>
        <%if(obj.nNativeInterfacePorts !== undefined) {%> 
        ioaiu_scoreboard       m_ncbu_cache_handle[<%=obj.DutInfo.nNativeInterfacePorts%>];
        <% } else { %>
        ioaiu_scoreboard       m_ncbu_cache_handle;
        <%}%>
    <%}%>

    const int            m_weights_for_k_num_snp[2]                   = {5, 95};
<% if((obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
//`ifndef VCS
  //  const t_minmax_range m_minmax_for_k_num_snp[2]                    = {{0,0}, {500,1500}};
//`else // `ifndef VCS
    const t_minmax_range m_minmax_for_k_num_snp[2]                    = '{'{m_min_range:0,m_max_range:0}, '{m_min_range:500,m_max_range:1500}};
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
    const t_minmax_range m_minmax_for_k_num_snp[2]                    = {{0,0}, {500,1500}};
<% } %>
    const int            m_weights_for_k_send_cmprsp_before_dtwrsp[2] = {95, 5};
<% if((obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
//`ifndef VCS
  //  const t_minmax_range m_minmax_for_k_send_cmprsp_before_dtwrsp[2]  = {{0,0}, {1,1}};
//`else // `ifndef VCS
    const t_minmax_range m_minmax_for_k_send_cmprsp_before_dtwrsp[2]  = '{'{m_min_range:0,m_max_range:0}, '{m_min_range:1,m_max_range:1}};
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
    const t_minmax_range m_minmax_for_k_send_cmprsp_before_dtwrsp[2]  = {{0,0}, {1,1}};
<% } %>
    const int            m_weights_for_k_snp_dvm_msg_not_sync[2]       = {15, 85};
<% if((obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
//`ifndef VCS
  //  const t_minmax_range m_minmax_for_k_snp_dvm_msg_not_sync[2]        = {{40,100}, {0,15}};
//`else // `ifndef VCS
    const t_minmax_range m_minmax_for_k_snp_dvm_msg_not_sync[2]        = '{'{m_min_range:40,m_max_range:100}, '{m_min_range:0,m_max_range:15}};
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
    const t_minmax_range m_minmax_for_k_snp_dvm_msg_not_sync[2]        = {{40,100}, {0,15}};
<% } %>
    common_knob_class k_num_snp                    = new("k_num_snp"                    , this , m_weights_for_k_num_snp              , m_minmax_for_k_num_snp);
    common_knob_class k_num_snp_q_pending          = new("k_num_snp_q_pending"          , this , m_weights_for_percentage             , m_minmax_for_percentage);
    common_knob_class wt_snp_cln_dtr               = new("wt_snp_cln_dtr"               , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_nitc                  = new("wt_snp_nitc"                  , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_vld_dtr               = new("wt_snp_vld_dtr"               , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_inv_dtr               = new("wt_snp_inv_dtr"               , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_inv_dtw               = new("wt_snp_inv_dtw"               , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_inv                   = new("wt_snp_inv"                   , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_cln_dtw               = new("wt_snp_cln_dtw"               , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_nosdint               = new("wt_snp_nosdint"               , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
<% if((obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[obj.Id].fnNativeInterface != "ACE") ) { %>
    common_knob_class wt_snp_inv_stsh              = new("wt_snp_inv_stsh"              , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_unq_stsh              = new("wt_snp_unq_stsh"              , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_stsh_sh               = new("wt_snp_stsh_sh"               , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_stsh_unq              = new("wt_snp_stsh_unq"              , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
<% } else { %>
<% if((obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
//`ifndef VCS
  //  common_knob_class wt_snp_inv_stsh              = new("wt_snp_inv_stsh"              , this , {100}                                , {{0,0}});
  //  common_knob_class wt_snp_unq_stsh              = new("wt_snp_unq_stsh"              , this , {100}                                , {{0,0}});
  //  common_knob_class wt_snp_stsh_sh               = new("wt_snp_stsh_sh"               , this , {100}                                , {{0,0}});
   // common_knob_class wt_snp_stsh_unq              = new("wt_snp_stsh_unq"              , this , {100}                                , {{0,0}});
//`else // `ifndef VCS
    common_knob_class wt_snp_inv_stsh              = new("wt_snp_inv_stsh"              , this , {100}                                , '{'{m_min_range:0,m_max_range:0}});
    common_knob_class wt_snp_unq_stsh              = new("wt_snp_unq_stsh"              , this , {100}                                , '{'{m_min_range:0,m_max_range:0}});
    common_knob_class wt_snp_stsh_sh               = new("wt_snp_stsh_sh"               , this , {100}                                , '{'{m_min_range:0,m_max_range:0}});
    common_knob_class wt_snp_stsh_unq              = new("wt_snp_stsh_unq"              , this , {100}                                , '{'{m_min_range:0,m_max_range:0}});
//`endif // `ifndef VCS ... `else ... 
<% } else { %>
    common_knob_class wt_snp_inv_stsh              = new("wt_snp_inv_stsh"              , this , {100}                                , {{0,0}});
    common_knob_class wt_snp_unq_stsh              = new("wt_snp_unq_stsh"              , this , {100}                                , {{0,0}});
    common_knob_class wt_snp_stsh_sh               = new("wt_snp_stsh_sh"               , this , {100}                                , {{0,0}});
    common_knob_class wt_snp_stsh_unq              = new("wt_snp_stsh_unq"              , this , {100}                                , {{0,0}});
<% } %>
<% } %>
<% if(obj.useCache == 1) { %>
    <% if(obj.testBench == 'io_aiu') { %>
        common_knob_class wt_snp_dvm_msg            = new("wt_snp_dvm_msg"               , this , {100}                                , '{'{m_min_range:0,m_max_range:0}});
    <% } else { %>
        `ifdef USE_VIP_SNPS_CHI
        common_knob_class wt_snp_dvm_msg            = new("wt_snp_dvm_msg"               , this , {100}                                , '{'{m_min_range:0,m_max_range:0}});
        `else
        common_knob_class wt_snp_dvm_msg            = new("wt_snp_dvm_msg"               , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
        `endif
    <% } %>
<%} else {%>
    `ifdef USE_VIP_SNPS_CHI
    common_knob_class wt_snp_dvm_msg                = new("wt_snp_dvm_msg"               , this , {100}                                , '{'{m_min_range:0,m_max_range:0}});
    `else
    common_knob_class wt_snp_dvm_msg                = new("wt_snp_dvm_msg"               , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    `endif
<%}%>
    //common_knob_class wt_snp_dvm_msg               = new("wt_snp_dvm_msg"               , this , {100}                                , {{0,0}});
    common_knob_class wt_snp_nitcci                = new("wt_snp_nitcci"                , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_nitcmi                = new("wt_snp_nitcmi"                , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_random_addr           = new("wt_snp_random_addr"           , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_for_stash_random_addr = new("wt_snp_for_stash_random_addr" , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class wt_snp_prev_addr             = new("wt_snp_prev_addr"             , this , {15,70,15}           , '{'{m_min_range:0,m_max_range:15}, '{m_min_range:85,m_max_range:99}, '{m_min_range:0,m_max_range:99}});
    common_knob_class wt_snp_cmd_req_addr          = new("wt_snp_cmd_req_addr"          , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
   common_knob_class wt_snp_ott_addr          = new("wt_snp_ott_addr"          , this , m_weights_for_weight_knobs           , m_minmax_for_weight_knobs);
    common_knob_class k_send_cmprsp_before_dtwrsp  = new("k_send_cmprsp_before_dtwrsp"  , this , m_weights_for_k_send_cmprsp_before_dtwrsp , m_minmax_for_k_send_cmprsp_before_dtwrsp);
    common_knob_class k_snp_dvm_msg_not_sync       = new("k_snp_dvm_msg_not_sync"       , this , m_weights_for_k_snp_dvm_msg_not_sync , m_minmax_for_k_snp_dvm_msg_not_sync);

<% if((obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
//`ifndef VCS
  //  common_knob_class k_num_event_msg              = new("k_num_event_msg"              , this , {100}        , {{0,0}});
//`else // `ifndef VCS
    common_knob_class k_num_event_msg              = new("k_num_event_msg"              , this , {100}        , '{'{m_min_range:0,m_max_range:0}});
//`endif // `ifndef VCS ... `else ... 
<% } else {%>
    common_knob_class k_num_event_msg              = new("k_num_event_msg"              , this , {100}        , {{0,0}});
<% } %>
    //common_knob_class k_num_event_msg              = new("k_num_event_msg"              , this , m_weights_for_k_num_event_msg        , m_minmax_for_k_num_event_msg);

    // TODO: CG below should be moved to common knob class
    bit dis_delay_dtr_req              = 0;
    bit dis_delay_str_req              = 0;
    bit dis_delay_tx_resp              = 0;
    bit dis_delay_cmd_resp             = 0;
    bit dis_delay_dtw_resp             = 0;
    bit dis_delay_upd_resp             = 0;
    bit dis_delay_dtr_resp             = 0; // TODO: Need to use this variable below
    int high_system_bfm_slv_rsp_delays = 0;
    bit gen_more_streaming_traffic     = 0;
    bit gen_cmp_resp_burst_traffic     = 0;

    typedef struct {
        smi_seq_item m_smi_seq_item;
        int          delay;
    } smi_rx_req_q_t;

    smi_seq_item_addr_t   m_smi_cmd_req_q[$];
    smi_seq_item_addr_t   m_smi_dvm_cmd_req_q[$];
    smi_seq_item_addr_t   m_smi_nc_cmd_req_q[$];

    smi_seq_item          m_smi_snp_req_q[$];
    smi_seq_item_addr_t   m_smi_str_req_q[$];
    smi_seq_item_addr_t   m_smi_cmd_self_snoop_req_q[$];
    smi_seq_item_addr_t   m_smi_cmd_self_snoop_req_sent_q[$];
    smi_seq_item_addr_t   m_smi_dtr_req_q[$];
    smi_seq_item          m_smi_dtr_req_for_atomics[smi_rbid_t];
    smi_seq_item          m_smi_tx_req_q[$];
    smi_seq_item          m_smi_rx_rsp_q[$];
    smi_rx_req_q_t        m_smi_rx_req_q[$];
    bit                   m_smi_cmd_pending_addr_h[smi_addr_security_t];
    smi_addr_security_t   m_smi_str_pending_addr_h[smi_unq_identifier_bit_t];
    smi_addr_security_t   m_smi_str_pending_mem_upd_addr_h[smi_unq_identifier_bit_t]; //for ACE Memory update commands
    bit                   m_smi_atomic_str_pending_addr_h[smi_unq_identifier_bit_t];
    smi_addr_security_t   m_addr_history[$];
    smi_addr_security_t   m_used_addr_q[$];
    smi_addr_security_t   m_used_snp_stash_addr_q[$];
    req_in_process_t      m_req_in_process[$];
    bit                   m_rbid_in_process[smi_rbid_t];
    bit                   m_rbid_in_process_nch[smi_rbid_t];
    bit                   m_unq_id_array[smi_unq_identifier_bit_t];
    bit                   m_snp_dtr_array[smi_mpf2_dtr_msg_id_t]; 
    smi_addr_security_t   m_processing_cmdreq_addr_q[$]; 
    smi_addr_security_t   m_processing_nc_cmdreq_addr_q[$]; 
    //smi_addr_security_t   m_processing_snpreq_addr_q[$]; 
    bit                   m_dvm_unq_identifier_q[smi_unq_identifier_bit_t];
    int                   m_pause_snoops_until_num_cmdreqs_vcs;
    int                   strreq_count;
    int                   dtrreq_count;
    event                 e_match_cmdreq_pause_cnt;
    event                 e_smi_outstandingq_del;
    event                 e_smi_rx_req_q;
    event                 e_smi_tx_req_q;
    event                 e_smi_rx_rsp_q;
    event                 e_smi_rx_rsp_dvm_cmd_q;
    event                 e_smi_cmd_req_q;
    event                 e_smi_nc_cmd_req_q;
    event                 e_smi_cmd_self_snoop_req_q;
    event                 e_smi_snp_req_q;
    event                 e_smi_snp_req_del_q;
    event                 e_smi_snp_req_free;
    event                 e_smi_str_req_q;
    event                 e_smi_str_pending_addr_h_freeup;
    event                 e_smi_dtr_req_q;
    event                 e_smi_unq_id_freeup;
    event                 e_smi_nc_unq_id_freeup;
    event                 e_addr_history;
    event                 e_smi_rbid_coh_freeup;
    event                 e_smi_rbid_ncoh_freeup;
    event                 e_snp_dtr_freeup;
    event                 e_unblock_process_cmd_req;
    event                 e_smi_sys_req_q;
    bit                   cmd_req_blocked;
   <% if(obj.testBench == 'io_aiu') { %>
  `ifndef VCS
    event                 e_tb_clk;
  `else // `ifndef VCS
    uvm_event             e_tb_clk;
  `endif // `ifndef VCS ... `else ... 
  <% } else {%>
    event                 e_tb_clk;
  <% } %>
    event                 e_delay_equal_zero;

    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_fill_stt = ev_pool.get("ev_fill_stt");
    uvm_event ev_max_snp_req_sent = ev_pool.get("ev_max_snp_req_sent");

    smi_src_id_bit_t      m_req_aiu_id = <%=obj.Id%>;
    bfm_cacheState_t      state_list[bit [WSMIADDR-1-SYS_wSysCacheline+<%=obj.wSecurityAttribute%>:0]];
    str_state_list_t      str_state_list[smi_unq_identifier_bit_t];
    smi_seq_item          m_smi_sys_req_q[$];
    int                   m_dce_dve_attach_st[smi_targ_id_bit_t];

    smi_virtual_sequencer m_smi_virtual_seqr;
    smi_sequencer         m_smi_seqr_rx_hash[string];
    smi_sequencer         m_smi_seqr_tx_hash[string];
    int                   snoop_count;
    int                   cmdreq_count;
    int                   snoop_outst;
    int 		  snoop_cred;
   
    // BW test - to disable all delays
    bit       bw_test = 0;
    bit       delay_str_req;
    bit       delay_dtr_req;
    bit       delay_tx_resp;
    bit       delay_cmd_resp;
    bit       delay_dtw_resp;
    bit       delay_upd_resp;
    int       delay_str_req_val    = 1;
    int       delay_dtr_req_val    = 1;
    int       delay_tx_resp_val = 1;
    int       delay_cmd_resp_val = 1;
    int       delay_dtw_resp_val = 1;
    int       delay_upd_resp_val = 1;
    bit       dis_drty_hndbck;
    semaphore s_unqid            = new(1);
    semaphore s_rbid             = new(1);
    semaphore s_rbid_nch         = new(1);
    semaphore s_snp              = new(1);
    semaphore s_addr             = new(1);
    semaphore s_nc_addr          = new(1);
    // dvm_sync_snoop_sent[X][1] : eDtrDvmCmp or SnpRsp received?
    // dvm_sync_snoop_sent[X][0] : DVM Sync snoop sent? 
<% if (num_of_dvms <= 2) { %> 
    //bit [1][1:0] dvm_sync_snoop_sent;
<% } else { %>
    //bit [<%=num_of_dvms%>-2:0][1:0] dvm_sync_snoop_sent;
<% } %>
    bit event_msg_inflight[int];
    bit exok_rand;
    rand bit str_snarf;
    rand int dtr_tgt_id_rand;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new (string name = "system_bfm_seq");
    super.new(name);
    //num_dvm_capable_aius = <%=num_of_dvms%>; 
    //num_dvm_source_aius  = <%=num_of_dvms_sources%>; 
    //foreach(dvm_sync_snoop_sent[i]) begin
    //    dvm_sync_snoop_sent[i]  = '0;
    //end
    m_addr_mgr = addr_trans_mgr::get_instance();
    if ($test$plusargs("hit_streaming_strreqs")) begin
        gen_more_streaming_traffic = 1;
    end
    else begin
        gen_more_streaming_traffic = ($urandom_range(0,100) < 30);
    end
    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
    gen_cmp_resp_burst_traffic = $urandom_range(0,1);
    <% } %>
   <% if((obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
   `ifndef VCS
    if(!$value$plusargs("aiu_scb_en", aiu_scb_en)) begin
   `else // `ifndef VCS
    if(!$value$plusargs("aiu_scb_en=%d", aiu_scb_en)) begin
   `endif // `ifndef VCS
   <% } else {%>
    if(!$value$plusargs("aiu_scb_en", aiu_scb_en)) begin
   <% } %>
        aiu_scb_en = 1;
    end
    if($test$plusargs("read_bw_test") || $test$plusargs("write_bw_test") || $test$plusargs("read_latency_test") || $test$plusargs("no_smi_delay"))begin
        bw_test = 1;
    end
    else begin
        bw_test = 0;
    end
    if($test$plusargs("dis_drty_hndbck"))begin
        dis_drty_hndbck = 1;
    end
    $value$plusargs("max_stt_fill_count=%d", max_stt_fill_count);
    dis_drty_hndbck = 1; // No dirty handbacks for Ncore 3.0
    if (bw_test) begin
        dis_delay_dtr_req              = 1;
        dis_delay_str_req              = 1;
        dis_delay_dtr_req              = 1;
        dis_delay_tx_resp              = 1;
        dis_delay_cmd_resp             = 1;
        dis_delay_dtw_resp             = 1;
        dis_delay_upd_resp             = 1;
        high_system_bfm_slv_rsp_delays = 0;
    end
   snoop_outst = 0;

//HS: Below is the correct code
   for(int i =0;i<($bits(DCE_FUNIT_IDS)/$bits(DCE_FUNIT_IDS[0]));i++)begin      
      DCE_Funit_Id.push_back(DCE_FUNIT_IDS[i]);
    end
    //foreach(CONNECTED_DCE_FUNIT_IDS[i]) begin
   // `uvm_info("SYS BFM DEBUG", $sformatf("func:new CONNECTED_DCE_FUNIT_IDS[%0d]:%0d", i, CONNECTED_DCE_FUNIT_IDS[i]), UVM_LOW)
   //end
   //foreach(DCE_FUNIT_IDS[i]) begin
   // `uvm_info("SYS BFM DEBUG", $sformatf("func:new DCE_FUNIT_IDS[%0d]:%0d", i, DCE_FUNIT_IDS[i]), UVM_LOW)
   //end
   // `uvm_info("SYS BFM DEBUG", $sformatf("func:new DCE_FUNIT_IDS:%0p", DCE_FUNIT_IDS), UVM_LOW)
   // `uvm_info("SYS BFM DEBUG", $sformatf("func:new CONNECTED_DCE_FUNIT_IDS:%0p", CONNECTED_DCE_FUNIT_IDS), UVM_LOW)
   //`uvm_info("SYS BFM DEBUG", $sformatf("func:new DCE_Funit_Id:%0p", DCE_Funit_Id), UVM_LOW)

   //`uvm_error("SYS BFM DEBUG", $sformatf("func:new End to debg"))

   for(int i =0;i<($bits(DMI_FUNIT_IDS)/$bits(DMI_FUNIT_IDS[0]));i++)begin      
      DMI_Funit_Id.push_back(DMI_FUNIT_IDS[i]);
   end
    for(int i =0;i<($bits(DII_FUNIT_IDS)/$bits(DII_FUNIT_IDS[0]));i++)begin      
      DII_Funit_Id.push_back(DII_FUNIT_IDS[i]);
    end
    for(int i =0;i<($bits(DVE_FUNIT_IDS)/$bits(DVE_FUNIT_IDS[0]));i++)begin      
      DVE_Targ_Id.push_back(DVE_FUNIT_IDS[i]);
    end

   `uvm_info("SYS BFM DEBUG", $sformatf("func:new DMI_Funit_Id:%0p queue_size %0d DII_FUNIT_IDS:%0p queue_size %0d DCE_FUNIT_IDS:%0p queue_size %0d DVE_Targ_Id:%p queue_size %0d", DMI_Funit_Id,DMI_Funit_Id.size(),DII_Funit_Id,DII_Funit_Id.size(),DCE_Funit_Id,DCE_Funit_Id.size(),DVE_Targ_Id,DVE_Targ_Id.size()), UVM_LOW)
 
   `ifdef VCS
   m_pause_snoops_until_num_cmdreqs_vcs=0;
       $value$plusargs("pause_snoops_until_num_cmdreqs=%d", m_pause_snoops_until_num_cmdreqs_vcs);
   `endif //`ifdef VCS    

endfunction : new

virtual task resend_correct_target_id (ref smi_seq m_tmp_ref_seq, input string m_tmp_arg_name);
    // This task will have input reference packet which needs to send again with correct target ID
    // & input arg_name for which type of message it is
    bit m_tmp_flag;
    string m_tmp_sqr_hash_name;
    smi_seq_item m_tmp_resend_seq_item;
    case(m_tmp_arg_name)
      "wrong_cmdrsp_target_id": begin
        if($test$plusargs(m_tmp_arg_name)) begin m_tmp_flag = 1; m_tmp_sqr_hash_name = "cmd_rsp_"; end
      end
      "wrong_strreq_target_id": begin
        if($test$plusargs(m_tmp_arg_name)) begin m_tmp_flag = 1; m_tmp_sqr_hash_name = "str_req_"; end
      end
      "wrong_snpreq_target_id": begin
        if($test$plusargs(m_tmp_arg_name)) begin m_tmp_flag = 1; m_tmp_sqr_hash_name = "snp_req_"; end
        if(m_tmp_ref_seq.m_seq_item.smi_targ_ncore_unit_id == <%=obj.FUnitId%>) begin
          m_tmp_flag = 0; m_tmp_sqr_hash_name = ""; // for snoop_me, no target id error injected yet
        end
      end
      "wrong_dtrreq_target_id": begin
        if($test$plusargs(m_tmp_arg_name)) begin m_tmp_flag = 1; m_tmp_sqr_hash_name = "dtr_req_rx_"; end
      end
      "wrong_dtrrsp_target_id": begin
        if($test$plusargs(m_tmp_arg_name)) begin m_tmp_flag = 1; m_tmp_sqr_hash_name = "dtr_rsp_rx_"; end
      end
      "wrong_dtwrsp_target_id": begin
        if($test$plusargs(m_tmp_arg_name)) begin m_tmp_flag = 1; m_tmp_sqr_hash_name = "dtw_rsp_"; end
      end
      "wrong_updrsp_target_id": begin
        if($test$plusargs(m_tmp_arg_name)) begin m_tmp_flag = 1; m_tmp_sqr_hash_name = "upd_rsp_"; end
      end
      "wrong_sysrsp_target_id": begin
        if($test$plusargs(m_tmp_arg_name)) begin m_tmp_flag = 1; m_tmp_sqr_hash_name = "sys_rsp_rx_"; end
      end
      "wrong_sysreq_target_id": begin
        if($test$plusargs(m_tmp_arg_name)) begin m_tmp_flag = 1; m_tmp_sqr_hash_name = "sys_req_rx_"; end
      end
       "wrong_DtwDbg_rsp_target_id": begin
        if($test$plusargs(m_tmp_arg_name)) begin m_tmp_flag = 1; m_tmp_sqr_hash_name = "dtw_dbg_rsp_"; end
      end
      default: begin
        m_tmp_flag = 0;
        `uvm_info("SYS BFM DEBUG", $sformatf("Not matching plusarg with argument name(%0s), m_tmp_flag=0x%0h", m_tmp_arg_name, m_tmp_flag), UVM_DEBUG);
      end
    endcase
    if(m_tmp_flag) begin
      $cast(m_tmp_resend_seq_item, m_tmp_ref_seq.m_seq_item.clone);
      m_tmp_resend_seq_item.smi_targ_ncore_unit_id = m_tmp_resend_seq_item.smi_targ_ncore_unit_id  ^ {WSMINCOREUNITID{1'h1}};
      m_tmp_ref_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
      m_tmp_ref_seq.m_seq_item = m_tmp_resend_seq_item;
      `uvm_info("SYS BFM DEBUG",  $sformatf("Resending corrected packet again due to %0s", m_tmp_arg_name), UVM_DEBUG);
      m_tmp_ref_seq.return_response(m_smi_seqr_tx_hash[m_tmp_sqr_hash_name]);
    end
endtask : resend_correct_target_id

function bit isAddrInSmiStrPendingAssocArray (smi_addr_security_t m_smi_addr);
    smi_unq_identifier_bit_t temp;
    if (m_smi_str_pending_addr_h.first(temp)) begin
        do begin
            if (((m_smi_str_pending_addr_h[temp] >> SYS_wSysCacheline) << SYS_wSysCacheline) == ((m_smi_addr >> SYS_wSysCacheline) << SYS_wSysCacheline)) begin
                return 1;
            end
        end while (m_smi_str_pending_addr_h.next(temp)); // UNMATCHED !!
    end
   //DCNOTES this looks at processing cmdreq q's
   for(int i=0;i < m_processing_cmdreq_addr_q.size();i++) begin
      if (((m_processing_cmdreq_addr_q[i] >> SYS_wSysCacheline) << SYS_wSysCacheline) == ((m_smi_addr >> SYS_wSysCacheline) << SYS_wSysCacheline)) begin
         return 1;
      end
   end
   return 0;
endfunction : isAddrInSmiStrPendingAssocArray 

function bit isAddrInSmiStrPendingMemUpdArray (smi_addr_security_t m_smi_addr);
    smi_unq_identifier_bit_t temp;
    if (m_smi_str_pending_mem_upd_addr_h.first(temp)) begin
        do begin
            if (((m_smi_str_pending_mem_upd_addr_h[temp] >> SYS_wSysCacheline) << SYS_wSysCacheline) == ((m_smi_addr >> SYS_wSysCacheline) << SYS_wSysCacheline)) begin
                return 1;
            end
        end while (m_smi_str_pending_mem_upd_addr_h.next(temp)); // UNMATCHED !!
    end
   return 0;
endfunction : isAddrInSmiStrPendingMemUpdArray

function bit isOutstandingSnoopFromAgent (smi_ncore_unit_id_bit_t agent_id);
    bit found = 0;
    foreach(m_smi_tx_req_q[i]) begin
        if (m_smi_tx_req_q[i].isSnpMsg()) begin
            if (m_smi_tx_req_q[i].smi_src_ncore_unit_id == agent_id) begin
              //`uvm_info(get_name(), $psprintf("[SNP-TRACE]  [cmd: %15s (0x%02h)] [src: 0x%04h] [tgt: 0x%04h] [msgId: 0x%08h] [addr: 0x%16h] {sysreqop: %1d}", "SNP-TX-REQ", m_smi_tx_req_q[i].smi_msg_type, m_smi_tx_req_q[i].smi_src_id, m_smi_tx_req_q[i].smi_targ_id, m_smi_tx_req_q[i].smi_msg_id, m_smi_tx_req_q[i].smi_addr, m_smi_tx_req_q[i].smi_sysreq_op), UVM_NONE);
               found = 1;
            end
        end
    end
    
    foreach (m_smi_snp_req_q[i]) begin
        if (m_smi_snp_req_q[i].smi_src_ncore_unit_id == agent_id) begin
              //`uvm_info(get_name(), $psprintf("[SNP-TRACE]  [cmd: %15s (0x%02h)] [src: 0x%04h] [tgt: 0x%04h] [msgId: 0x%08h] [addr: 0x%16h] {sysreqop: %1d}", "SNP-REQ", m_smi_snp_req_q[i].smi_msg_type, m_smi_snp_req_q[i].smi_src_id, m_smi_snp_req_q[i].smi_targ_id, m_smi_snp_req_q[i].smi_msg_id, m_smi_snp_req_q[i].smi_addr, m_smi_snp_req_q[i].smi_sysreq_op), UVM_NONE);
               found = 1;
        end
    end
    
    return found;
endfunction : isOutstandingSnoopFromAgent

function bit isAddrInSmiStrReqOutstandingArray (smi_addr_security_t m_smi_addr);
    foreach(m_smi_tx_req_q[i]) begin
        if (m_smi_tx_req_q[i].isStrMsg()) begin
            if (m_smi_str_pending_addr_h.exists(m_smi_tx_req_q[i].smi_unq_identifier) &&
                (((m_smi_str_pending_addr_h[m_smi_tx_req_q[i].smi_unq_identifier] >> SYS_wSysCacheline) << SYS_wSysCacheline) == ((m_smi_addr >> SYS_wSysCacheline) << SYS_wSysCacheline))) begin
                return 1;
            end
        end
    end
    return 0;
endfunction : isAddrInSmiStrReqOutstandingArray

function bit isAddrInStrReqArray (smi_addr_security_t m_smi_addr);
    foreach(m_smi_str_req_q[i]) begin
        if(((m_smi_str_req_q[i].m_addr >> SYS_wSysCacheline) << SYS_wSysCacheline) == ((m_smi_addr >> SYS_wSysCacheline) << SYS_wSysCacheline)) begin
            return 1;
        end
    end
    return 0;
endfunction : isAddrInStrReqArray

function bit isAddrInSmiSnpPendingArray (smi_addr_security_t m_smi_addr);
    foreach (m_smi_tx_req_q[i]) begin
        if (m_smi_tx_req_q[i].isSnpMsg()) begin
            if (m_smi_addr[WSMIADDR-1:SYS_wSysCacheline] == m_smi_tx_req_q[i].smi_addr[WSMIADDR-1:SYS_wSysCacheline]
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    && m_smi_addr[WSMIADDR] == m_smi_tx_req_q[i].smi_ns
                <% } %>                                                
            ) begin
                return 1;
            end
        end
    end
    foreach (m_smi_snp_req_q[i]) begin
        if (m_smi_addr[WSMIADDR-1:SYS_wSysCacheline] == m_smi_snp_req_q[i].smi_addr[WSMIADDR-1:SYS_wSysCacheline]
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                && m_smi_addr[WSMIADDR] == m_smi_snp_req_q[i].smi_ns
            <% } %>                                                
        ) begin
            return 1;
        end
    end
    return 0;
endfunction : isAddrInSmiSnpPendingArray

function bit isAddrInSmiSnpReqOutstandingArray (smi_addr_security_t m_smi_addr);
    foreach (m_smi_tx_req_q[i]) begin
        if (m_smi_tx_req_q[i].isSnpMsg() && (m_smi_tx_req_q[i].smi_msg_type != SNP_DVM_MSG)) begin
            if (m_smi_addr[WSMIADDR-1:SYS_wSysCacheline] == m_smi_tx_req_q[i].smi_addr[WSMIADDR-1:SYS_wSysCacheline]
                <% if (obj.wSecurityAttribute > 0) { %>
                    && m_smi_addr[WSMIADDR] == m_smi_tx_req_q[i].smi_ns
                <% } %>
            ) begin
                return 1;
            end
        end
    end
    return 0;
endfunction : isAddrInSmiSnpReqOutstandingArray

task monitor_rx_cmdupdreq();
    forever begin
        smi_seq_item m_tmp_seq_item;
        smi_rx_req_q_t m_tmp_smi_rx_req_item;
        smi_seq_item_addr_t m_tmp_seq_item_addr_t;
        bit                 m_cmdrsp_err_injected = 0;
        //`uvm_info("SYS BFM DEBUG", $sformatf("monitor_rx_cmdupdreq waiting for cmdreq"), UVM_HIGH)  
        m_smi_seqr_rx_hash["cmd_req_"].m_rx_analysis_fifo.get(m_tmp_seq_item); 

        if (!m_cmdrsp_err_injected && m_tmp_seq_item.isCmdMsg()) begin
            m_tmp_seq_item_addr_t.m_seq_item = m_tmp_seq_item;
            m_tmp_seq_item_addr_t.t_smi_ndp_ready = $time;
            m_tmp_seq_item_addr_t.m_addr     = { 
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    m_tmp_seq_item.smi_ns,
                <% } %>
            m_tmp_seq_item.smi_addr};
            <% if((obj.Block =='chi_aiu') || (obj.Block =='io_aiu')) { %>
            <% if(obj.Block =='chi_aiu'){ %>
            if (m_tmp_seq_item.smi_es && m_tmp_seq_item.smi_targ_ncore_unit_id inside {DCE_Funit_Id} && (m_tmp_seq_item.smi_tof == SMI_TOF_CHI) && m_dce_dve_attach_st.exists(m_tmp_seq_item.smi_targ_ncore_unit_id) && m_dce_dve_attach_st[m_tmp_seq_item.smi_targ_ncore_unit_id] == 1 && (m_tmp_seq_item.smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm})) begin
            <% } else { %>
            if (m_tmp_seq_item.smi_es && m_tmp_seq_item.smi_targ_ncore_unit_id inside {DCE_Funit_Id} && (m_tmp_seq_item.smi_tof == SMI_TOF_CHI) && m_dce_dve_attach_st.exists(m_tmp_seq_item.smi_targ_ncore_unit_id) && m_dce_dve_attach_st[m_tmp_seq_item.smi_targ_ncore_unit_id] == 1) begin
            <% } %>
            <% } else { %>
            if (m_tmp_seq_item.smi_es && m_tmp_seq_item.smi_targ_ncore_unit_id inside {DCE_Funit_Id} && (m_tmp_seq_item.smi_tof == SMI_TOF_CHI)) begin
            <% } %>
                m_smi_cmd_self_snoop_req_q.push_back(m_tmp_seq_item_addr_t);
                //`uvm_info("SYS BFM DEBUG", m_tmp_seq_item.smi_addr), UVM_HIGH)  
                ->e_smi_cmd_self_snoop_req_q;
            end else begin
	       addCmdReqToQueue(m_tmp_seq_item_addr_t);
            end
        end
        
        // TODO: Add if needed
        //To provide delay for CmdRsp
        //m_tmp_smi_slv_req_item.delay = ($urandom_range(1,100) <= k_smi_cmd_rsp_burst_pct) ? 0 : 
        //($urandom_range(k_smi_cmd_rsp_delay_min, k_smi_cmd_rsp_delay_max));
        m_tmp_smi_rx_req_item.m_smi_seq_item = m_tmp_seq_item; 
        // TODO: uncomment below
        m_tmp_smi_rx_req_item.delay = 0;
        m_smi_rx_req_q.push_back(m_tmp_smi_rx_req_item);
        ->e_smi_rx_req_q;
    end 
endtask : monitor_rx_cmdupdreq

task monitor_rx_dtrdtwreq();
    forever begin
        smi_seq_item m_tmp_seq_item;
        smi_rx_req_q_t m_tmp_smi_rx_req_item;
        m_tmp_smi_rx_req_item.m_smi_seq_item = smi_seq_item::type_id::create("m_seq_item");
        m_smi_seqr_rx_hash["dtw_req_"].m_rx_analysis_fifo.get(m_tmp_seq_item); 
        m_tmp_smi_rx_req_item.m_smi_seq_item = m_tmp_seq_item; 
        m_smi_rx_req_q.push_back(m_tmp_smi_rx_req_item);
        ->e_smi_rx_req_q;
    end 
endtask : monitor_rx_dtrdtwreq

task send_tx_resp_delay();
    delay_tx_resp = 0;
    if (!dis_delay_tx_resp) begin
        forever begin
            #(delay_tx_resp_val * 1ns);
            delay_tx_resp = ~delay_tx_resp;
            if (high_system_bfm_slv_rsp_delays) begin
                delay_tx_resp_val = $urandom_range(1000,10000);
            end
            else begin
                delay_tx_resp_val = $urandom_range(1,1000);
            end
        end
    end
endtask : send_tx_resp_delay

task send_cmd_resp_delay();
    delay_cmd_resp = 0;
    if (!dis_delay_cmd_resp) begin
        forever begin
            #(delay_cmd_resp_val * 1ns);
            delay_cmd_resp = ~delay_cmd_resp;
            delay_cmd_resp_val = $urandom_range(1,1000);
        end
    end
endtask : send_cmd_resp_delay

task send_dtw_resp_delay();
    delay_dtw_resp = 0;
    if (!dis_delay_dtw_resp) begin
        forever begin
            #(delay_dtw_resp_val * 1ns);
            delay_dtw_resp = ~delay_dtw_resp;
            delay_dtw_resp_val = $urandom_range(1,1000);
        end
    end
endtask : send_dtw_resp_delay
 
task send_upd_resp_delay();
    delay_upd_resp = 0;
    if (!dis_delay_upd_resp) begin
        forever begin
            #(delay_upd_resp_val * 1ns);
            delay_upd_resp = ~delay_upd_resp;
            delay_upd_resp_val = $urandom_range(1,1000);
        end
    end
endtask : send_upd_resp_delay
 
task decrement_delay_count();
    forever begin
        @e_tb_clk;
        foreach (m_smi_rx_req_q[i]) begin
            if (m_smi_rx_req_q[i].delay > 0) begin
                m_smi_rx_req_q[i].delay--;
                if (m_smi_rx_req_q[i].delay == 0) begin
                    ->e_delay_equal_zero;
                end
            end
            else begin
                ->e_delay_equal_zero;
            end
        end
    end
endtask : decrement_delay_count
 
task send_tx_resp();
    bit wti_err_inj_once;
    int num_sysreq_attach = 0;
    int num_exp_sysreq_attach = 0;
    bit drop;
    
    forever begin
        int m_index_q[$], sysreq_q[$], nonsysreq_q[$];
        bit [2:0] sysrsp_cmstatus_err_q[$];
        bit found;
        smi_seq_item    m_tmp_seq_item;
        smi_seq_item    m_rsp_seq_item;
        smi_seq_item    m_rsp2_seq_item;
        smi_rx_req_q_t m_tmp_smi_rx_req_item;
        bit [6:0]       random_cmdrsp_dtrrsp_cmstatus_error_payload;
        bit             done = 0;
        int k_dtwrsp_cmstatus_with_error_wgt;
        int              m_tmp_q[$];
        int              m_tmp_q_ott_addr[$];
        int picked_idx;

        if (delay_tx_resp) begin
            // TODO: uncomment below 
            //wait(delay_tx_resp == 0);
        end
        found = 0;
        //foreach(m_smi_rx_req_q[i])
	//    `uvm_info("SYS BFM DEBUG", $sformatf("B tsk:send_tx_resp m_smi_rx_req_q i:%0d delay:%0d %0s", i, m_smi_rx_req_q[i].delay, m_smi_rx_req_q[i].m_smi_seq_item.convert2string()), UVM_LOW)
        //
        do begin
            //m_index_q = {};
            //m_index_q = m_smi_rx_req_q.find_index with (item.delay <= 0);
            sysreq_q = m_smi_rx_req_q.find_index with (item.delay <= 0 && item.m_smi_seq_item.isSysReqMsg() && 
                                                    ((item.m_smi_seq_item.smi_sysreq_op inside {SMI_SYSREQ_ATTACH, SMI_SYSREQ_EVENT}) ||
                                                    ((item.m_smi_seq_item.smi_sysreq_op == SMI_SYSREQ_DETACH) && !isOutstandingSnoopFromAgent(item.m_smi_seq_item.smi_targ_ncore_unit_id))));
	
            nonsysreq_q = m_smi_rx_req_q.find_index with (item.delay <= 0 && !item.m_smi_seq_item.isSysReqMsg());

            if (sysreq_q.size > 0) begin: _attach_detach_event_rsp_ready_to_send_
                sysreq_q.shuffle();
                m_tmp_smi_rx_req_item = m_smi_rx_req_q[sysreq_q[0]];
		m_smi_rx_req_q.delete(sysreq_q[0]);
		m_smi_rx_req_q.push_front(m_tmp_smi_rx_req_item);
		picked_idx = 0;
                found = 1;
            end: _attach_detach_event_rsp_ready_to_send_
            else if (nonsysreq_q.size > 0) begin: _normal_txn_rsp_ready_to_send_ 
                nonsysreq_q.shuffle();
                m_tmp_smi_rx_req_item = m_smi_rx_req_q[nonsysreq_q[0]];
		m_smi_rx_req_q.delete(nonsysreq_q[0]);
		m_smi_rx_req_q.push_front(m_tmp_smi_rx_req_item);
		picked_idx = 0;
                found = 1;
            end: _normal_txn_rsp_ready_to_send_
            else begin: _wait_for_more_normal_txns_or_snpreq_tx_req_q_free 
                @(e_smi_rx_req_q or e_smi_snp_req_free);
            end: _wait_for_more_normal_txns_or_snpreq_tx_req_q_free 

        end while (!found);
        
        m_tmp_smi_rx_req_item = m_smi_rx_req_q[picked_idx];
        m_tmp_seq_item = m_tmp_smi_rx_req_item.m_smi_seq_item;
        m_smi_rx_req_q.delete(picked_idx);
	
        //`uvm_info("SYS BFM DEBUG", $sformatf("rsp to  be generated for this req_item:%0s", m_tmp_seq_item.convert2string()), UVM_LOW)
        m_rsp_seq_item = smi_seq_item::type_id::create("m_seq_item");
        //if (m_tmp_seq_item.isDtwMsg()) begin
        //    wait(delay_dtw_resp == 0);
        //end
        // Setting up SMI packet
        // CMH first
        //#Stimulus.IOAIU.WrongTargetId
        if(  ($test$plusargs("wrong_cmdrsp_target_id") && m_tmp_seq_item.isCmdMsg())
           ||($test$plusargs("wrong_updrsp_target_id") && m_tmp_seq_item.isUpdMsg())
           ||($test$plusargs("wrong_dtwrsp_target_id") && m_tmp_seq_item.isDtwMsg())
           ||($test$plusargs("wrong_dtrrsp_target_id") && m_tmp_seq_item.isDtrMsg())
           ||($test$plusargs("wrong_DtwDbg_rsp_target_id") && m_tmp_seq_item.isDtwDbgReqMsg())
           ||(  ($test$plusargs("wrong_sysrsp_target_id") && m_tmp_seq_item.isSysReqMsg())
              &&(!wti_err_inj_once)
              &&(  ((m_tmp_seq_item.smi_sysreq_op == SMI_SYSREQ_ATTACH) && $test$plusargs("check4_attach"))
                 ||((m_tmp_seq_item.smi_sysreq_op == SMI_SYSREQ_DETACH) && $test$plusargs("check4_detach"))
                )
             )
          )
        begin
        if($test$plusargs("error_in_2nd_part")) begin
         if(m_tmp_seq_item.smi_msg_type == eCmdClnInv || m_tmp_seq_item.smi_msg_type == eCmdClnVld || m_tmp_seq_item.smi_msg_type == eCmdClnShdPer)
          m_rsp_seq_item.smi_targ_ncore_unit_id = m_tmp_seq_item.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'h1}};
        end else if($test$plusargs("error_in_cmo_part")) begin
         if(m_tmp_seq_item.smi_msg_type != eCmdMkUnq) 
          m_rsp_seq_item.smi_targ_ncore_unit_id = m_tmp_seq_item.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'h1}};
        end else if($test$plusargs("error_in_writeevictorevict")) begin
         if(m_tmp_seq_item.smi_msg_type == eCmdEvict) 
          m_rsp_seq_item.smi_targ_ncore_unit_id = m_tmp_seq_item.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'h1}};
        end else begin
          m_rsp_seq_item.smi_targ_ncore_unit_id = m_tmp_seq_item.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'h1}};
        end
          if($test$plusargs("wti_err_inj_once")) wti_err_inj_once = 1;
        end else begin
          m_rsp_seq_item.smi_targ_ncore_unit_id = m_tmp_seq_item.smi_src_ncore_unit_id;
        end
        m_rsp_seq_item.smi_src_ncore_unit_id  = m_tmp_seq_item.smi_targ_ncore_unit_id;
        if (m_tmp_seq_item.isCmdMsg()) begin
            //if (m_tmp_seq_item.smi_ch) begin
            if (addrMgrConst::get_unit_type(m_tmp_seq_item.smi_targ_ncore_unit_id)==addrMgrConst::DCE) begin
                m_rsp_seq_item.smi_msg_type =  C_CMD_RSP;
            end
            else begin
                m_rsp_seq_item.smi_msg_type =  NC_CMD_RSP;
            end
            m_rsp_seq_item.smi_tm  = m_tmp_seq_item.smi_tm;
            <%if(obj.nNativeInterfacePorts !== null && obj.nNativeInterfacePorts > 1){%>
                m_rsp_seq_item.smi_msg_id[WSMIMSGID-1: WSMIMSGID-$clog2(<%=obj.nNativeInterfacePorts%>)] = m_tmp_seq_item.smi_msg_id[WSMIMSGID-1: WSMIMSGID-$clog2(<%=obj.nNativeInterfacePorts%>)];
            <%}%>
        end
        else if (m_tmp_seq_item.isUpdMsg()) begin
            m_rsp_seq_item.smi_msg_type =  UPD_RSP;
        end
        else if (m_tmp_seq_item.isDtwMsg()) begin
            exok_rand=$urandom_range(1, 0);
            m_rsp_seq_item.smi_msg_type =  DTW_RSP;
            m_rsp_seq_item.smi_cmstatus_err = 0;
            m_rsp_seq_item.smi_cmstatus[SMICMSTATUSSTRREQEXOK] = exok_rand;
            m_rsp_seq_item.smi_cmstatus_exok  = exok_rand;
            m_rsp_seq_item.smi_tm  = m_tmp_seq_item.smi_tm;
            <%if(obj.nNativeInterfacePorts !== null && obj.nNativeInterfacePorts > 1){%>
                m_rsp_seq_item.smi_msg_id[WSMIMSGID-1: WSMIMSGID-$clog2(<%=obj.nNativeInterfacePorts%>)] = m_tmp_seq_item.smi_msg_id[WSMIMSGID-1: WSMIMSGID-$clog2(<%=obj.nNativeInterfacePorts%>)];
            <%}%>
            if (m_smi_dtr_req_for_atomics.exists(m_tmp_seq_item.smi_rbid)) begin
                smi_seq_item_addr_t tmp_dtr_req;
                tmp_dtr_req.m_seq_item = m_smi_dtr_req_for_atomics[m_tmp_seq_item.smi_rbid];
                tmp_dtr_req.cmd_type = eCmdWrAtm; //Hack the cmdtype to pick one of the Atomic type
                m_smi_dtr_req_q.push_back(tmp_dtr_req);
                m_smi_dtr_req_for_atomics.delete(m_tmp_seq_item.smi_rbid);
                ->e_smi_dtr_req_q;
            end
        end
        else if (m_tmp_seq_item.isDtrMsg()) begin
            m_rsp_seq_item.smi_msg_type =  DTR_RSP;
            m_rsp_seq_item.smi_tm = m_tmp_seq_item.smi_tm;
            <%if(obj.nNativeInterfacePorts !== null && obj.nNativeInterfacePorts > 1){%>
                m_rsp_seq_item.smi_msg_id[WSMIMSGID-1: WSMIMSGID-$clog2(<%=obj.nNativeInterfacePorts%>)] = m_tmp_seq_item.smi_msg_id[WSMIMSGID-1: WSMIMSGID-$clog2(<%=obj.nNativeInterfacePorts%>)];
            <%}%>
            if(m_tmp_seq_item.smi_src_ncore_unit_id === <%=obj.AiuInfo[obj.Id].FUnitId%>)
            begin
                m_snp_dtr_array.delete(m_tmp_seq_item.smi_rmsg_id);
                ->e_snp_dtr_freeup;
            end
        end
        else if (m_tmp_seq_item.isDtwDbgReqMsg()) begin
            m_rsp_seq_item.smi_msg_type =  DTW_DBG_RSP;
            m_rsp_seq_item.smi_rl = 0; //FIXME:: balajik why is this needed??
            m_rsp_seq_item.smi_tm  = m_tmp_seq_item.smi_tm;
        end
        else if (m_tmp_seq_item.isSysReqMsg()) begin
            /* CONC-11273 update
             * the sysco connect state need to be updated after the response is sent and not before
            m_dce_dve_attach_st[m_tmp_seq_item.smi_targ_ncore_unit_id] = m_tmp_seq_item.smi_sysreq_op;
            */
            m_rsp_seq_item.smi_msg_type =  SYS_RSP;
            m_rsp_seq_item.smi_tm  = m_tmp_seq_item.smi_tm;
            m_rsp_seq_item.smi_cmstatus = 0;
            m_rsp_seq_item.smi_sysreq_op = m_tmp_seq_item.smi_sysreq_op;
        end
        m_rsp_seq_item.unpack_smi_unq_identifier();
        m_rsp_seq_item.smi_msg_tier       = 0;
        m_rsp_seq_item.smi_steer          = 0;
        m_rsp_seq_item.smi_msg_pri        = m_tmp_seq_item.smi_msg_pri;
        m_rsp_seq_item.smi_msg_qos        = m_tmp_seq_item.smi_msg_qos;
        // Rest of the packet
        $value$plusargs("dtwrsp_cmstatus_with_error=%d",k_dtwrsp_cmstatus_with_error_wgt); //#Stimulus.CHIAIU.v3.dtwrspmstatuserror
        if (!(m_tmp_seq_item.smi_targ_ncore_unit_id inside {DVE_Targ_Id})) begin
        if (($test$plusargs("dtwrsp_cmstatus_with_error") && m_tmp_seq_item.isDtwMsg())) begin
          randcase
          k_dtwrsp_cmstatus_with_error_wgt: begin 
                                              m_rsp_seq_item.smi_cmstatus_err   = 1;
                                              std::randomize(random_cmdrsp_dtrrsp_cmstatus_error_payload) with { random_cmdrsp_dtrrsp_cmstatus_error_payload inside {
																		     //#Stimulus.IOAIU.DTWrsp.CMStatusDataErr
                                                                                                                                                     7'b00_00_011, //CCMP reported error, protocol data error          
       																		     //#Stimulus.IOAIU.DTWrsp.CMStatusAddrErr
                                                                                                                                                     7'b00_00_100 //CCMP reported error, protocol address error
                                                                                                                                                      };
                                                                                                        };
                                              m_rsp_seq_item.smi_cmstatus_err_payload = random_cmdrsp_dtrrsp_cmstatus_error_payload;
                                            end
          (100-k_dtwrsp_cmstatus_with_error_wgt): begin
                                                    /*Do nothing - Retain previous value*/; 
                                                  end
          endcase
        end
        end
        m_rsp_seq_item.smi_rmsg_id = m_tmp_seq_item.smi_msg_id;
        m_allrsp_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
        m_allrsp_tx.m_seq_item = m_rsp_seq_item;
        //`uvm_info("SYS BFM DEBUG", $sformatf("Sending a response in send_tx_resp"), UVM_HIGH)  
        if (m_tmp_seq_item.isDtwMsg()) begin
            // If the DTW is targeted to the DVE, then also send a CMPRSP
            <% if ((obj.fnNativeInterface == "CHI-A")||(obj.fnNativeInterface == "CHI-B")|| (obj.fnNativeInterface == "CHI-E") || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")) && obj.nDvmSnpInFlight)) { %>
                if (m_tmp_seq_item.smi_targ_ncore_unit_id inside {DVE_Targ_Id}) begin
                    int k_cmprsp_cmstatus_with_error_wgt;
                    bit [6:0] random_cmprsp_cmstatus_error_payload;
                    m_index_q = {};
                    m_index_q = m_smi_rx_req_q.find_index with (item.m_smi_seq_item.isDtwMsg &&
                                                                item.m_smi_seq_item.smi_targ_ncore_unit_id inside {DVE_Targ_Id});
                    if(gen_cmp_resp_burst_traffic && (m_index_q.size() > 0)) begin
                        m_index_q.shuffle();
                        if(k_send_cmprsp_before_dtwrsp.get_value()) begin
                            m_rsp2_seq_item                        = smi_seq_item::type_id::create("m_seq_item");
                            m_rsp2_seq_item.smi_targ_ncore_unit_id = m_tmp_seq_item.smi_src_ncore_unit_id;
                            m_rsp2_seq_item.smi_src_ncore_unit_id  = m_tmp_seq_item.smi_targ_ncore_unit_id;
                            m_rsp2_seq_item.smi_msg_type           = CMP_RSP ;
                            m_rsp2_seq_item.unpack_smi_unq_identifier();
                            m_rsp2_seq_item.smi_msg_tier       = 0;
                            m_rsp2_seq_item.smi_steer          = 0;
                            m_rsp2_seq_item.smi_msg_pri        = m_tmp_seq_item.smi_msg_pri;
                            m_rsp2_seq_item.smi_msg_qos        = m_tmp_seq_item.smi_msg_qos;
                            m_rsp2_seq_item.smi_cmstatus = 0; // This needs to be driven to non-zero for error testing
                            <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                            m_rsp2_seq_item.smi_rmsg_id = dvm_msg_ids[m_tmp_seq_item.smi_rbid];
		            dvm_msg_ids.delete(m_tmp_seq_item.smi_rbid);
//                            m_rsp2_seq_item.smi_rmsg_id = m_tmp_seq_item.smi_msg_id;
		            <% } else { %>
                            m_rsp2_seq_item.smi_rmsg_id = m_tmp_seq_item.smi_msg_id;
                            <% } %>
                            m_allrsp_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
                            m_allrsp_tx.m_seq_item = m_rsp2_seq_item;
                            m_allrsp_tx.return_response(m_smi_seqr_tx_hash["cmp_rsp_"]);
                            foreach(m_index_q[idx]) begin
                                m_rsp2_seq_item                        = smi_seq_item::type_id::create("m_seq_item");
                                m_rsp2_seq_item.smi_targ_ncore_unit_id = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_src_ncore_unit_id;
                                m_rsp2_seq_item.smi_src_ncore_unit_id  = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_targ_ncore_unit_id;
                                m_rsp2_seq_item.smi_msg_type           = CMP_RSP ;
                                m_rsp2_seq_item.unpack_smi_unq_identifier();
                                m_rsp2_seq_item.smi_msg_tier       = 0;
                                m_rsp2_seq_item.smi_steer          = 0;
                                m_rsp2_seq_item.smi_msg_pri        = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_msg_pri;
                                m_rsp2_seq_item.smi_msg_qos        = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_msg_qos;
                                m_rsp2_seq_item.smi_cmstatus = 0; // This needs to be driven to non-zero for error testing
                                <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                                m_rsp2_seq_item.smi_rmsg_id = dvm_msg_ids[m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_rbid];
		                dvm_msg_ids.delete(m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_rbid);
//                                m_rsp2_seq_item.smi_rmsg_id = m_tmp_seq_item.smi_msg_id;
		                <% } else { %>
                                m_rsp2_seq_item.smi_rmsg_id = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_msg_id;
                                <% } %>
                                m_allrsp_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
                                m_allrsp_tx.m_seq_item = m_rsp2_seq_item;
                                m_allrsp_tx.return_response(m_smi_seqr_tx_hash["cmp_rsp_"]);
                            end
                            m_allrsp_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
                            m_allrsp_tx.m_seq_item = m_rsp_seq_item;
                            m_allrsp_tx.return_response(m_smi_seqr_tx_hash["dtw_rsp_"]);
                            foreach(m_index_q[idx]) begin
                                m_rsp_seq_item = smi_seq_item::type_id::create("m_seq_item");
                                m_rsp_seq_item.smi_targ_ncore_unit_id = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_src_ncore_unit_id;
                                m_rsp_seq_item.smi_src_ncore_unit_id  = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_targ_ncore_unit_id;
                                m_rsp_seq_item.smi_msg_type =  DTW_RSP;
                                m_rsp_seq_item.smi_cmstatus_exok  = $urandom_range(1, 0);
                                if (m_smi_dtr_req_for_atomics.exists(m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_rbid)) begin
                                    smi_seq_item_addr_t tmp_dtr_req;
                                    tmp_dtr_req.m_seq_item = m_smi_dtr_req_for_atomics[m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_rbid];
                                    tmp_dtr_req.cmd_type = eCmdWrAtm; //Hack the cmdtype to pick one of the Atomic type
                                    m_smi_dtr_req_q.push_back(tmp_dtr_req);
                                    m_smi_dtr_req_for_atomics.delete(m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_rbid);
                                    ->e_smi_dtr_req_q;
                                end
                                m_rsp_seq_item.unpack_smi_unq_identifier();
                                m_rsp_seq_item.smi_msg_tier       = 0;
                                m_rsp_seq_item.smi_steer          = 0;
                                m_rsp_seq_item.smi_msg_pri        = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_msg_pri;
                                m_rsp_seq_item.smi_msg_qos        = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_msg_qos;
                                m_rsp_seq_item.smi_cmstatus = 0; // This needs to be driven to non-zero for error testing
                                m_rsp_seq_item.smi_rmsg_id = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_msg_id;
                                m_allrsp_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
                                m_allrsp_tx.m_seq_item = m_rsp_seq_item;
                                m_allrsp_tx.return_response(m_smi_seqr_tx_hash["dtw_rsp_"]);
                            end
                            m_index_q.rsort();
                            foreach(m_index_q[idx]) begin
                                m_smi_rx_req_q.delete(m_index_q[idx]);
                            end
                        end else begin
                            m_allrsp_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
                            m_allrsp_tx.m_seq_item = m_rsp_seq_item;
                            m_allrsp_tx.return_response(m_smi_seqr_tx_hash["dtw_rsp_"]);
                            foreach(m_index_q[idx]) begin
                                m_rsp_seq_item = smi_seq_item::type_id::create("m_seq_item");
                                m_rsp_seq_item.smi_targ_ncore_unit_id = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_src_ncore_unit_id;
                                m_rsp_seq_item.smi_src_ncore_unit_id  = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_targ_ncore_unit_id;
                                m_rsp_seq_item.smi_msg_type =  DTW_RSP;
                                m_rsp_seq_item.smi_cmstatus_exok  = $urandom_range(1, 0);
                                if (m_smi_dtr_req_for_atomics.exists(m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_rbid)) begin
                                    smi_seq_item_addr_t tmp_dtr_req;
                                    tmp_dtr_req.m_seq_item = m_smi_dtr_req_for_atomics[m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_rbid];
                                    tmp_dtr_req.cmd_type = eCmdWrAtm; //Hack the cmdtype to pick one of the Atomic type
                                    m_smi_dtr_req_q.push_back(tmp_dtr_req);
                                    m_smi_dtr_req_for_atomics.delete(m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_rbid);
                                    ->e_smi_dtr_req_q;
                                end
                                m_rsp_seq_item.unpack_smi_unq_identifier();
                                m_rsp_seq_item.smi_msg_tier       = 0;
                                m_rsp_seq_item.smi_steer          = 0;
                                m_rsp_seq_item.smi_msg_pri        = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_msg_pri;
                                m_rsp_seq_item.smi_msg_qos        = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_msg_qos;
                                m_rsp_seq_item.smi_cmstatus = 0; // This needs to be driven to non-zero for error testing
                                m_rsp_seq_item.smi_rmsg_id = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_msg_id;
                                m_allrsp_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
                                m_allrsp_tx.m_seq_item = m_rsp_seq_item;
                                m_allrsp_tx.return_response(m_smi_seqr_tx_hash["dtw_rsp_"]);
                            end
                            m_rsp2_seq_item                        = smi_seq_item::type_id::create("m_seq_item");
                            m_rsp2_seq_item.smi_targ_ncore_unit_id = m_tmp_seq_item.smi_src_ncore_unit_id;
                            m_rsp2_seq_item.smi_src_ncore_unit_id  = m_tmp_seq_item.smi_targ_ncore_unit_id;
                            m_rsp2_seq_item.smi_msg_type           = CMP_RSP ;
                            m_rsp2_seq_item.unpack_smi_unq_identifier();
                            m_rsp2_seq_item.smi_msg_tier       = 0;
                            m_rsp2_seq_item.smi_steer          = 0;
                            m_rsp2_seq_item.smi_msg_pri        = m_tmp_seq_item.smi_msg_pri;
                            m_rsp2_seq_item.smi_msg_qos        = m_tmp_seq_item.smi_msg_qos;
                            m_rsp2_seq_item.smi_cmstatus = 0; // This needs to be driven to non-zero for error testing
                            <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                            m_rsp2_seq_item.smi_rmsg_id = dvm_msg_ids[m_tmp_seq_item.smi_rbid];
		            dvm_msg_ids.delete(m_tmp_seq_item.smi_rbid);
//                            m_rsp2_seq_item.smi_rmsg_id = m_tmp_seq_item.smi_msg_id;
		            <% } else { %>
                            m_rsp2_seq_item.smi_rmsg_id = m_tmp_seq_item.smi_msg_id;
                            <% } %>
                            m_allrsp_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
                            m_allrsp_tx.m_seq_item = m_rsp2_seq_item;
                            m_allrsp_tx.return_response(m_smi_seqr_tx_hash["cmp_rsp_"]);
                            foreach(m_index_q[idx]) begin
                                m_rsp2_seq_item                        = smi_seq_item::type_id::create("m_seq_item");
                                m_rsp2_seq_item.smi_targ_ncore_unit_id = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_src_ncore_unit_id;
                                m_rsp2_seq_item.smi_src_ncore_unit_id  = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_targ_ncore_unit_id;
                                m_rsp2_seq_item.smi_msg_type           = CMP_RSP ;
                                m_rsp2_seq_item.unpack_smi_unq_identifier();
                                m_rsp2_seq_item.smi_msg_tier       = 0;
                                m_rsp2_seq_item.smi_steer          = 0;
                                m_rsp2_seq_item.smi_msg_pri        = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_msg_pri;
                                m_rsp2_seq_item.smi_msg_qos        = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_msg_qos;
                                m_rsp2_seq_item.smi_cmstatus = 0; // This needs to be driven to non-zero for error testing
                                <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                                m_rsp2_seq_item.smi_rmsg_id = dvm_msg_ids[m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_rbid];
		                dvm_msg_ids.delete(m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_rbid);
//                                m_rsp2_seq_item.smi_rmsg_id = m_tmp_seq_item.smi_msg_id;
		                <% } else { %>
                                m_rsp2_seq_item.smi_rmsg_id = m_smi_rx_req_q[m_index_q[idx]].m_smi_seq_item.smi_msg_id;
                                <% } %>
                                m_allrsp_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
                                m_allrsp_tx.m_seq_item = m_rsp2_seq_item;
                                m_allrsp_tx.return_response(m_smi_seqr_tx_hash["cmp_rsp_"]);
                            end
                            m_index_q.rsort();
                            foreach(m_index_q[idx]) begin
                                m_smi_rx_req_q.delete(m_index_q[idx]);
                            end
                        end
                    end else begin
                        m_rsp2_seq_item                        = smi_seq_item::type_id::create("m_seq_item");
                        m_rsp2_seq_item.smi_targ_ncore_unit_id = m_tmp_seq_item.smi_src_ncore_unit_id;
                        m_rsp2_seq_item.smi_src_ncore_unit_id  = m_tmp_seq_item.smi_targ_ncore_unit_id;
                        m_rsp2_seq_item.smi_msg_type           = CMP_RSP ;
                        m_rsp2_seq_item.unpack_smi_unq_identifier();
                        m_rsp2_seq_item.smi_msg_tier       = 0;
                        m_rsp2_seq_item.smi_steer          = 0;
                        m_rsp2_seq_item.smi_msg_pri        = m_tmp_seq_item.smi_msg_pri;
                        m_rsp2_seq_item.smi_msg_qos        = m_tmp_seq_item.smi_msg_qos;
                        // Rest of the packet
                        $value$plusargs("cmprsp_cmstatus_with_error=%d",k_cmprsp_cmstatus_with_error_wgt);
                         <% if( obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
                        if(aiu_scb_en) begin
                        m_tmp_q = {};
                        m_tmp_q =  m_ncbu_cache_handle.m_ott_q.find_index with (item.isRead &&
					    item.m_ace_cmd_type == DVMMSG &&
                                            item.isSMIDTWReqSent && 
                                            item.isSMICMDReqSent &&
                                            item.m_ott_id == m_tmp_seq_item.smi_msg_id &&
                                            item.m_ott_status == ALLOCATED &&
                                            item.m_ace_read_addr_pkt.araddr[14:12] inside {'b100,'b110} &&
                                            !item.isSMISTRRespSent && !item.isSMICMPRespRecd ); 
					   
                         if(m_tmp_q.size() == 1) begin
                         if(m_ncbu_cache_handle.m_ott_q[m_tmp_q[0]].m_ace_read_addr_pkt.araddr[14:12] inside {'b100,'b110} ) begin
                         k_cmprsp_cmstatus_with_error_wgt = 0; //AMBA protocol : A component is not permitted to set CRRESP to 0b00010 in response to a DVM Sync or a DVM Complete
                         end
                         end
                         else if(m_tmp_q.size() > 1) begin
                         foreach (m_tmp_q[i]) begin
                         end
			 uvm_report_error("<%=obj.strRtlNamePrefix%> SCB ERROR",$sformatf("Cannot find match for CMP_RSP!"));
                         end
                         end
                         <% } %>
                        
                        if ($test$plusargs("cmprsp_cmstatus_with_error")) begin
                          randcase
                          k_cmprsp_cmstatus_with_error_wgt: begin
                                                              m_rsp2_seq_item.smi_cmstatus_err = 1;
                                                              std::randomize(random_cmprsp_cmstatus_error_payload) with { random_cmprsp_cmstatus_error_payload inside {
                                                                                                                                      																                                                                                   //#Stimulus.IOAIU.CMPrsp.CMStatusAddrErr
                                                                                                                                                          7'b00_00_100 //CCMP reported error, protocol address error ////DVE issuesCmpRsp with CMStatus = 8'b10000100 (Address Error) as per error spec
                                                                                                                                                                                                                                                                                 };
                                                                                                                        };
                                                              m_rsp2_seq_item.smi_cmstatus_err_payload = random_cmprsp_cmstatus_error_payload;
                                                            end
                          (100-k_cmprsp_cmstatus_with_error_wgt): begin
                                                                    m_rsp2_seq_item.smi_cmstatus = 0;
                                                                  end
                         endcase
                        end else begin
                          m_rsp2_seq_item.smi_cmstatus = 0; // This needs to be driven to non-zero for error testing
                        end
                        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                        m_rsp2_seq_item.smi_rmsg_id = dvm_msg_ids[m_tmp_seq_item.smi_rbid];
		        dvm_msg_ids.delete(m_tmp_seq_item.smi_rbid);
//                        m_rsp2_seq_item.smi_rmsg_id = m_tmp_seq_item.smi_msg_id;
		        <% } else { %>
                        m_rsp2_seq_item.smi_rmsg_id = m_tmp_seq_item.smi_msg_id;
                        <% } %>
                        if (k_send_cmprsp_before_dtwrsp.get_value()) begin
                            m_allrsp_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
                            m_allrsp_tx.m_seq_item = m_rsp2_seq_item;
                            m_allrsp_tx.return_response(m_smi_seqr_tx_hash["cmp_rsp_"]);
                            m_allrsp_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
                            m_allrsp_tx.m_seq_item = m_rsp_seq_item;
                            m_allrsp_tx.return_response(m_smi_seqr_tx_hash["dtw_rsp_"]);
                        end else begin
                            m_allrsp_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
                            m_allrsp_tx.m_seq_item = m_rsp_seq_item;
                            m_allrsp_tx.return_response(m_smi_seqr_tx_hash["dtw_rsp_"]);
                            m_allrsp_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
                            m_allrsp_tx.m_seq_item = m_rsp2_seq_item;
                            m_allrsp_tx.return_response(m_smi_seqr_tx_hash["cmp_rsp_"]);
                        end
                    end
                end else begin
                    m_allrsp_tx.return_response(m_smi_seqr_tx_hash["dtw_rsp_"]);
                    if($test$plusargs("resend_correct_target_id")) resend_correct_target_id(m_allrsp_tx, "wrong_dtwrsp_target_id");
                end
            <% } else { %>
                m_allrsp_tx.return_response(m_smi_seqr_tx_hash["dtw_rsp_"]);
                if($test$plusargs("resend_correct_target_id")) resend_correct_target_id(m_allrsp_tx, "wrong_dtwrsp_target_id");
            <% } %>
        end else if (m_tmp_seq_item.isCmdMsg()) begin
            if($test$plusargs("scm_bckpressure_test")) begin
               #100ns;
            end
            m_allrsp_tx.return_response(m_smi_seqr_tx_hash["cmd_rsp_"]);
            if($test$plusargs("resend_correct_target_id")) resend_correct_target_id(m_allrsp_tx, "wrong_cmdrsp_target_id");
        end else if (m_tmp_seq_item.isUpdMsg()) begin
            // Removing line from system bfm state list
            smi_unq_identifier_bit_t temp;
            if (state_list.exists({
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    m_tmp_seq_item.smi_ns,
                <% } %>                                                
            m_tmp_seq_item.smi_addr[WSMIADDR-1:SYS_wSysCacheline]})) begin
                smi_unq_identifier_bit_t temp;
                `uvm_info("SYS BFM DEBUG", $sformatf("Changing cache state on UPDreq- Addr: 0x%0x, Security: 0x%0x, start_state:%p, end_state:SysBfmIX", m_tmp_seq_item.smi_addr, m_tmp_seq_item.smi_ns, state_list[{m_tmp_seq_item.smi_ns, m_tmp_seq_item.smi_addr[WSMIADDR-1:SYS_wSysCacheline]}]), UVM_LOW)

                state_list.delete({
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        m_tmp_seq_item.smi_ns,
                    <% } %>                                                
                m_tmp_seq_item.smi_addr[WSMIADDR-1:SYS_wSysCacheline]});
            end
            // If I find a pending transaction in the STR state list and encounter an
            // UpdReq for the same address, I am changing the install state of this line
            // to IX. This can happen if an eviction races a previous STRRsp
            if (str_state_list.first(temp)) begin
                do begin
                    if (str_state_list[temp].m_addr >> SYS_wSysCacheline == {
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            m_tmp_seq_item.smi_ns,
                        <% } %>                                                
                    m_tmp_seq_item.smi_addr[WSMIADDR-1:SYS_wSysCacheline]}) begin
                        str_state_list[temp].m_cache_state = SysBfmIX;
                        break;
                    end
                end while (str_state_list.next(temp));
            end
            m_allrsp_tx.return_response(m_smi_seqr_tx_hash["upd_rsp_"]);
            if($test$plusargs("resend_correct_target_id")) resend_correct_target_id(m_allrsp_tx, "wrong_updrsp_target_id");
        end else if (m_tmp_seq_item.isDtrMsg()) begin
            m_allrsp_tx.return_response(m_smi_seqr_tx_hash["dtr_rsp_rx_"]);
            if($test$plusargs("resend_correct_target_id")) resend_correct_target_id(m_allrsp_tx, "wrong_dtrrsp_target_id");
        end else if (m_tmp_seq_item.isDtwDbgReqMsg()) begin
            //cm_status [7] Valid One indicates to increment the counter by value specified in bits 6:0 Zero indicates to decrement the counter by value specified in bits 6:0
            //cm_status [6:0] Value Value by which the counter needs to be adjusted, this maps to counter bits [10:4] of the local counter, bits [3:0] are zero.
	    std::randomize(m_allrsp_tx.m_seq_item.smi_cmstatus) with { m_allrsp_tx.m_seq_item.smi_cmstatus dist{ 0:/25, [1:127]:/25, 128:/25, [129:255]:/25};}; //FIXME:: balajik check if this randomization needs to changed.
            m_allrsp_tx.return_response(m_smi_seqr_tx_hash["dtw_dbg_rsp_"]);
            if($test$plusargs("resend_correct_target_id")) resend_correct_target_id(m_allrsp_tx, "wrong_DtwDbg_rsp_target_id");
        end else if (m_tmp_seq_item.isSysReqMsg()) begin
            m_allrsp_tx.m_seq_item.smi_cmstatus[2:0] = 3; //Final-Execution state machine went to IDLE after sending this response
            m_allrsp_tx.m_seq_item.smi_cmstatus[5:3] = 0; //Always '0          
            m_allrsp_tx.m_seq_item.smi_cmstatus[7:6] = 0; //Status Type : Success (noError)
                
            sysrsp_cmstatus_err_q = {'b110, 'b100, 'b010, 'b000}; //CONC-11211 SYSrsp.Err from DCE/DVE CMStatus[2:0] = xx0: No Operation performed

            if (m_tmp_seq_item.smi_sysreq_op == 'h1) 
                    num_sysreq_attach++;

            num_exp_sysreq_attach = addrMgrConst::NUM_DCES;
			<%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface === "ACE")){%>
			num_exp_sysreq_attach += addrMgrConst::NUM_DVES;
            <%}%>
            
            if (m_tmp_seq_item.smi_sysreq_op == 'h1) begin // SysReq.Attach
                    if($test$plusargs("attach_sys_rsp_error") && (num_sysreq_attach <= num_exp_sysreq_attach)) begin
                        m_allrsp_tx.m_seq_item.smi_cmstatus[7:6] = 1; // Status Type : Error  
		        sysrsp_cmstatus_err_q.shuffle();
                        m_allrsp_tx.m_seq_item.smi_cmstatus[2:0] = sysrsp_cmstatus_err_q[0];         
                    end
            end else if (m_tmp_seq_item.smi_sysreq_op == 'h2) begin                                          // SysReq.Detach
                    if($test$plusargs("detach_sys_rsp_error")) begin
                        m_allrsp_tx.m_seq_item.smi_cmstatus[7:6] = 1; // Status Type : Error           
		        sysrsp_cmstatus_err_q.shuffle();
                        m_allrsp_tx.m_seq_item.smi_cmstatus[2:0] = sysrsp_cmstatus_err_q[0];         
                    end
            end

		    drop = 0;
		    if($test$plusargs("timeout_attach_sys_rsp_error") && m_tmp_seq_item.smi_sysreq_op == 'h1 && (num_sysreq_attach <= num_exp_sysreq_attach)) begin
               //`uvm_info("SYSTEM BFM DEBUG", $sformatf("Drop SYS_RSP for attach_seq for attach_error_timeout_seq test num_sysreq_attach:%0d", num_sysreq_attach), UVM_LOW);
                drop = 1;
		    end 
		    if($test$plusargs("timeout_detach_sys_rsp_error") && m_tmp_seq_item.smi_sysreq_op == 'h2) begin
               //`uvm_info("SYSTEM BFM DEBUG", $sformatf("Drop SYS_RSP for detach_seq for detach_error_timeout_seq test"), UVM_LOW);
		    	drop = 1;
		    end

		    if ($test$plusargs("event_sys_rsp_timeout_error") && (m_tmp_seq_item.smi_sysreq_op == SMI_SYSREQ_EVENT)) begin
                        //`uvm_info("SYSTEM BFM DEBUG", $sformatf("Drop SYS_EVENT_RSP for error_timeout_seq test"), UVM_LOW);
            drop = 1;
		    end
            //
		    if(drop == 0) begin
                //`uvm_info("SYSTEM BFM DEBUG", $sformatf("About to master SYS_RSP for req_item:%0s rsp_item:%0s",m_tmp_seq_item.convert2string(), m_allrsp_tx.m_seq_item.convert2string()), UVM_LOW);
                m_allrsp_tx.return_response(m_smi_seqr_tx_hash["sys_rsp_rx_"]);
                
                //`uvm_info("SYSTEM BFM DEBUG", $sformatf("Sent SYS_RSP"), UVM_LOW);

          <% if((obj.testBench == 'chi_aiu')) { %>
              if($test$plusargs("resend_correct_target_id")) resend_correct_target_id(m_allrsp_tx, "wrong_sysrsp_target_id");
          <%  } %> 

                // CONC-11273 update
                if (m_tmp_seq_item.smi_sysreq_op inside {SMI_SYSREQ_ATTACH, SMI_SYSREQ_DETACH}) begin 
                    m_dce_dve_attach_st[m_tmp_seq_item.smi_targ_ncore_unit_id] = m_tmp_seq_item.smi_sysreq_op;
                    //foreach(m_dce_dve_attach_st[key]) begin 
                    //    `uvm_info("SYSTEM BFM DEBUG", $sformatf("After SYS_RSP was sent m_dce_dve_attach_st key:0x%0h value:%0h", key, m_dce_dve_attach_st[key]), UVM_LOW);
                    //end 
                end

		    end

        end
    end
endtask : send_tx_resp

task process_rx_resp();
    int k_random_dbad_value_wgt;

    bfm_cacheState_t    start_state;
    forever begin
        if (m_smi_rx_rsp_q.size == 0) begin
            fork 
               @e_smi_rx_rsp_q;
               @e_smi_rx_rsp_dvm_cmd_q;
            join_any
        end
        else begin
            int          m_tmp_q[$], m_tmp_qA[$], m_tmp_qB[$];
            smi_seq_item m_tmp_seq_item;
            m_smi_rx_rsp_q.shuffle();
            m_tmp_seq_item = m_smi_rx_rsp_q[0];
            m_smi_rx_rsp_q.delete(0);
            if (m_tmp_seq_item.isStrRspMsg()) begin
                m_tmp_qA = {};
                m_tmp_qA = m_smi_tx_req_q.find_index with (item.isStrMsg());
            end else if (m_tmp_seq_item.isSnpRspMsg()) begin
                m_tmp_qA = {};
                m_tmp_qA = m_smi_tx_req_q.find_index with (item.isSnpMsg());
            end else if (m_tmp_seq_item.isDtrRspMsg()) begin
                m_tmp_qA = {};
                m_tmp_qA = m_smi_tx_req_q.find_index with (item.isDtrMsg());
            end else if (m_tmp_seq_item.isSysRspMsg()) begin
                m_tmp_qA = {};
                m_tmp_qA = m_smi_tx_req_q.find_index with (item.isSysReqMsg());
            end
            m_tmp_qB = {};
            //m_tmp_qB = m_tmp_qA.find_index with (m_smi_tx_req_q[item].smi_msg_id == m_tmp_seq_item.smi_rmsg_id);
            m_tmp_qB = m_tmp_qA.find_index with (m_smi_tx_req_q[item].smi_unq_identifier == m_tmp_seq_item.smi_rsp_unq_identifier);
            if (m_tmp_qB.size() == 0) begin
                `uvm_info("SYS BFM DEBUG", "Printing outstanding requests below:", UVM_LOW);
                foreach (m_smi_tx_req_q[i]) begin
                    `uvm_info("SYS BFM DEBUG", m_smi_tx_req_q[i].convert2string(), UVM_LOW);
                end
                `uvm_info("SYS BFM DEBUG", "Printing response below:", UVM_LOW);
                `uvm_info("SYS BFM DEBUG", m_tmp_seq_item.convert2string(), UVM_LOW);
                `uvm_error("SYSTEM BFM MASTER RSP", $sformatf("Got above SMI response message without finding a matching message that BFM sent"));
            end
            else if (m_tmp_qB.size() > 1) begin
                `uvm_info("SYS BFM DEBUG", "Printing all matching requests below:", UVM_LOW);
                foreach (m_tmp_qB[i]) begin
                    `uvm_info("SYS BFM DEBUG", m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[i]]].convert2string(), UVM_LOW);
                end
                `uvm_info("SYS BFM DEBUG", "Printing response below:", UVM_LOW);
                `uvm_info("SYS BFM DEBUG", m_tmp_seq_item.convert2string(), UVM_LOW);
                `uvm_error("SYSTEM BFM MASTER RSP", $sformatf("TB Error: Got above SMI response message that matches multiple outstanding requests"));
            end
            else begin
                // Updating state_list based on snoop response
                // RV = 0 -> IX
                // RV = 1 RS = 1 -> SC
                // RV = 1 RS = 0 DC = 1 -> OC
                // RV = 1 RS = 0 DC = 0 -> Unique becomes owned else SS = ES
                if (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].isSnpMsg()) begin
                    m_unq_id_array.delete(m_tmp_seq_item.smi_rsp_unq_identifier);
                    if (!(m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type == SNP_INV_STSH ||
                        m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type == SNP_UNQ_STSH ||
                        m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type == SNP_STSH_SH  ||
                        m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type == SNP_STSH_UNQ
                    )) begin
                          if(m_tmp_seq_item.isSnpRspMsg() && (m_tmp_seq_item.smi_cmstatus_err || m_tmp_seq_item.smi_cmstatus_dt_aiu =='0))
                          begin
                            m_snp_dtr_array.delete(m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_mpf2_dtr_msg_id);
                            ->e_snp_dtr_freeup;
                          end
                    end
		    freeSmiRbId(m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]],1'b0);

                    //->e_smi_rbid_freeup;
                    // Checking if this snoop response is due to a atomic snoop me request
                    if (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type == eSnpInvDtw) begin
                        foreach (m_smi_cmd_self_snoop_req_sent_q[i]) begin
                            if (m_smi_cmd_self_snoop_req_sent_q[i].m_addr == {
                                <% if (obj.wSecurityAttribute > 0) { %>                                             
                                    m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_ns,
                                <% } %>
                            m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr} ) begin
                                m_smi_cmd_req_q.push_back(m_smi_cmd_self_snoop_req_sent_q[i]);
                                m_smi_cmd_self_snoop_req_sent_q.delete(i);
//			        addCmdReqToQueue(m_smi_cmd_self_snoop_req_sent_q[i]);
                                ->e_smi_cmd_req_q;
                                ->e_smi_unq_id_freeup;
                                break;
                            end
                        end
                    end 
                    `uvm_info("SYS BFM DEBUG", $sformatf("Deleting RBID 0x%0x", m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_rbid), UVM_HIGH)
                    // Send DTR for Snoop stash requests with snarf = 1
                    if (m_tmp_seq_item.smi_cmstatus_snarf &&
                        !m_tmp_seq_item.smi_cmstatus_err &&
                        (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type == eSnpStshUnq ||
                        m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type == eSnpStshShd ||
                        m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type == eSnpInvStsh ||
                        m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type == eSnpUnqStsh
                    )) begin
                        smi_seq_item       m_tmp_dtr_item;
    			bit [2:0]	   l_dwid;
                        int unsigned       num_data_beats = 64 / wSmiDPbe;
                        smi_dp_data_bit_t  m_random_data[] = new [num_data_beats];
                        smi_dp_be_t        m_random_be[] = new [num_data_beats];
                        smi_seq_item_addr_t tmp_dtr_req;
                        for (int j = 0; j <  num_data_beats; j++) begin
                            smi_dp_data_bit_t  tmp;
                            assert(std::randomize(tmp))
                            else begin
                                `uvm_error("SYS BFM SEQ", "Failure to randomize tmp");
                            end
                            m_random_data[j] = tmp;
                            m_random_be[j]   = '1;
                            //foreach (m_random_be[i]) begin
                            //    if ($urandom_range(1,100) < prob_dtrreq_data_err_inj) begin
                            //        m_random_be[i] = '0;
                            //    end
                            //end
                        end
                        m_tmp_dtr_item = smi_seq_item::type_id::create("m_tmp_dtr_item");
                        m_tmp_dtr_item.smi_targ_ncore_unit_id = m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_targ_ncore_unit_id;
                        // FIXME: Below source id should be randomized
                        m_tmp_dtr_item.smi_src_ncore_unit_id  = (m_tmp_dtr_item.smi_targ_ncore_unit_id == 0) ? 1 : 0;
                        unique case (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type) 
                            eSnpInvStsh: m_tmp_dtr_item.smi_msg_type = eDtrDataUnqDty;
                            eSnpUnqStsh: m_tmp_dtr_item.smi_msg_type = eDtrDataUnqDty;
                            eSnpStshShd: m_tmp_dtr_item.smi_msg_type = eDtrDataShrCln;
                            eSnpStshUnq: m_tmp_dtr_item.smi_msg_type = eDtrDataUnqCln;
                        endcase
                        m_tmp_dtr_item.unpack_smi_unq_identifier();
//                        `uvm_info("SYS BFM DEBUG", $sformatf("Reached here DTR 5"), UVM_HIGH)
                        giveSmiMsgId(m_tmp_dtr_item);
//                        `uvm_info("SYS BFM DEBUG", $sformatf("Reached here DTR 6"), UVM_HIGH)
                        m_tmp_dtr_item.smi_msg_tier = 0;
                        m_tmp_dtr_item.smi_steer    = 0;
                        m_tmp_dtr_item.smi_msg_pri  = m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_pri;
                        m_tmp_dtr_item.smi_msg_qos  = m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_qos;
                        m_tmp_dtr_item.smi_cmstatus = 0;
                        m_tmp_dtr_item.smi_rl       = SMI_RL_COHERENCY;
                        m_tmp_dtr_item.smi_tm       = m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_tm;
                        m_tmp_dtr_item.smi_rmsg_id  = m_tmp_seq_item.smi_mpf1_dtr_msg_id;
                        m_tmp_dtr_item.smi_dp_data  = new[m_random_data.size()] (m_random_data);
                        m_tmp_dtr_item.smi_dp_be    = new[m_random_be.size()] (m_random_be);
                        m_tmp_dtr_item.smi_dp_dwid  = new[m_tmp_dtr_item.smi_dp_data.size()];
                        m_tmp_dtr_item.smi_dp_dbad  = new[m_tmp_dtr_item.smi_dp_data.size()];
                        foreach (m_tmp_dtr_item.smi_dp_dwid[i]) begin
         			<%if(obj.AiuInfo[obj.Id].wData==128){ %>
             			  if(m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_size == 'h5 && m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr[5:4]%2==1)
             			  begin
	   				l_dwid = (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr[5:4]-i)*2;
        				m_tmp_dtr_item.smi_dp_dwid[i] = {l_dwid+1, l_dwid};
             			  end
	     			  else
             			  begin
	   				l_dwid = (i+m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr[5:4])*2;
        				m_tmp_dtr_item.smi_dp_dwid[i] = {l_dwid+1, l_dwid};
				  end
        			<%} else if(obj.AiuInfo[obj.Id].wData==256){%>
	   				l_dwid = (i+m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr[5])*4;
        				m_tmp_dtr_item.smi_dp_dwid[i] = {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid};
				<%}%>
                            if ($value$plusargs("random_dbad_value=%d",k_random_dbad_value_wgt)) begin
                              //#Stimulus.IOAIU.DTRreq.DBad
                              randcase
                                k_random_dbad_value_wgt: m_tmp_dtr_item.smi_dp_dbad[i] = $random(); 
                                (100-k_random_dbad_value_wgt): m_tmp_dtr_item.smi_dp_dbad[i] = '0;
                              endcase
                            end else begin
                              m_tmp_dtr_item.smi_dp_dbad[i] = '0; //FIXME
                            end
                        end
                        tmp_dtr_req.m_seq_item = m_tmp_dtr_item;
                        tmp_dtr_req.cmd_type = eCmdWrStshFull; // Hack the cmd_type to show the DtrReq is related to Stash
                        m_smi_dtr_req_q.push_back(tmp_dtr_req);
                        ->e_smi_dtr_req_q;
                    end 
                    if (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type !== eSnpDvmMsg) begin
                        if (state_list.exists({
                            <% if (obj.wSecurityAttribute > 0) { %>                                             
                                m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_ns,
                            <% } %>                                                
                        m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr[WSMIADDR-1:SYS_wSysCacheline]})) begin
                        smi_addr_security_t m_tmp_addr = {<% if (obj.wSecurityAttribute > 0) { %>
                                                                m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_ns,
                                                              <% } %>
                                                                m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr[WSMIADDR-1:SYS_wSysCacheline]};
                        start_state = state_list[m_tmp_addr];

                        <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                            
                                 getEndStateForACESnp(eMsgSNP'(m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type), m_tmp_addr, m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr, m_tmp_seq_item.smi_cmstatus_rv, m_tmp_seq_item.smi_cmstatus_rs, m_tmp_seq_item.smi_cmstatus_dc,m_tmp_seq_item.smi_cmstatus_err); // update str_state_list if SNP finishes first
                            // update str_state_list if SNP finishes first
                            /* foreach(str_state_list[i]) begin */
                            /*     if(str_state_list[i].m_addr >> SYS_wSysCacheline == m_tmp_addr) begin */
                            /*         str_state_list[i].m_cache_state = state_list[m_tmp_addr]; */
                            /*     end */
                            /* end */
                        <% } else { %>
                            unique case ({m_tmp_seq_item.smi_cmstatus_rv, m_tmp_seq_item.smi_cmstatus_rs, m_tmp_seq_item.smi_cmstatus_dc})
                                3'b000,
                                3'b001: begin 
                                    state_list.delete({
                                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                                            m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_ns,
                                        <% } %>                                                
                                    m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr[WSMIADDR-1:SYS_wSysCacheline]});
                                end
                                3'b100: begin
                                    // No change in state
                                end
                                3'b110: begin
                                    if (state_list[{
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_ns,
                                        <% } %>
                                    m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr[WSMIADDR-1:SYS_wSysCacheline]}] == SysBfmUC) begin
                                        state_list[{
                                            <% if (obj.wSecurityAttribute > 0) { %>
                                                m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_ns,
                                            <% } %>
                                        m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr[WSMIADDR-1:SYS_wSysCacheline]}] = SysBfmSC;
                                    end
                                    else if (state_list[{
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_ns,
                                        <% } %>
                                    m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr[WSMIADDR-1:SYS_wSysCacheline]}] == SysBfmUD) begin
                                        state_list[{
                                            <% if (obj.wSecurityAttribute > 0) { %>
                                                m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_ns,
                                            <% } %>
                                        m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr[WSMIADDR-1:SYS_wSysCacheline]}] = SysBfmSD;
                                    end
                                end
                                3'b111: begin
                                    state_list[{
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_ns,
                                        <% } %>
                                    m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr[WSMIADDR-1:SYS_wSysCacheline]}] = SysBfmSD;
                                end
                                default: begin
                                    `uvm_error("SYS BFM SEQ", $sformatf("Incorrect snoop response received: %p", m_tmp_seq_item)); 
                                end
                            endcase
                            <% } %>
                            `uvm_info("SYS BFM DEBUG", $sformatf("Changing cache state on SnpRsp - Addr:0x%0x Security:0x%0x from start_state:%0p to end_state %0p",m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr,  m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_ns, start_state, state_list[{
                                <% if (obj.wSecurityAttribute > 0) { %>
                                    m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_ns,
                                <% } %>
                            m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_addr[WSMIADDR-1:SYS_wSysCacheline]}]), UVM_LOW);
                        end
                    end
                end
                else if (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].isDtrMsg()) begin
                    if (!m_unq_id_array.exists(m_tmp_seq_item.smi_rsp_unq_identifier))
                        `uvm_warning("SYS BFM DEBUG", $sformatf("tsk:process_rx_resp: Deleting key:0x%0h", m_tmp_seq_item.smi_rsp_unq_identifier))
                        m_unq_id_array.delete(m_tmp_seq_item.smi_rsp_unq_identifier);
                    //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_rx_resp: Deleting key:m_tmp_seq_item.smi_rsp_unq_identifier",), UVM_LOW)
                end
                else if (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].isStrMsg()) begin
                    `uvm_info("SYS BFM DEBUG", $sformatf("Deleting RBID str 0x%0x", m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_rbid), UVM_HIGH)

                    if (!str_state_list.exists(m_tmp_seq_item.smi_rsp_unq_identifier)) begin
                        `uvm_error("SYS BFM SEQ", $sformatf("TB Error: STR response received but no entry found in str_state_list (id:0x%0x)", m_tmp_seq_item.smi_rmsg_id)); 
                    end
                    else begin
                        if (str_state_list[m_tmp_seq_item.smi_rsp_unq_identifier].m_isDVM == 0) begin
                            if (str_state_list[m_tmp_seq_item.smi_rsp_unq_identifier].m_cache_state == SysBfmIX) begin
                                state_list.delete(str_state_list[m_tmp_seq_item.smi_rsp_unq_identifier].m_addr[WSMIADDR-1+<%=obj.wSecurityAttribute%>:SYS_wSysCacheline]);
                            end
                            else begin
                                start_state = state_list[str_state_list[m_tmp_seq_item.smi_rsp_unq_identifier].m_addr[WSMIADDR-1+<%=obj.wSecurityAttribute%>:SYS_wSysCacheline]];
                                state_list[str_state_list[m_tmp_seq_item.smi_rsp_unq_identifier].m_addr[WSMIADDR-1+<%=obj.wSecurityAttribute%>:SYS_wSysCacheline]] = str_state_list[m_tmp_seq_item.smi_rsp_unq_identifier].m_cache_state;
                            end
                            `uvm_info("SYS BFM DEBUG",$sformatf("Changing cache state on STRrsp- address 0x%0x start_state:%0p to end_state %0p, isCoh %x", str_state_list[m_tmp_seq_item.smi_rsp_unq_identifier].m_addr, start_state, str_state_list[m_tmp_seq_item.smi_rsp_unq_identifier].m_cache_state, str_state_list[m_tmp_seq_item.smi_rsp_unq_identifier].m_isCoherent), UVM_LOW);
                    end
                    //if (!(m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm} && m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_ch) || (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm} && m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_ch && (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_cmstatus_err === 1))) 
                    if (!(m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm} && m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_targ_ncore_unit_id inside {DCE_Funit_Id}) || (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm} && m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_targ_ncore_unit_id inside {DCE_Funit_Id} && (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_cmstatus_err === 1))) 
		       freeSmiRbId(m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]], !str_state_list[m_tmp_seq_item.smi_rsp_unq_identifier].m_isCoherent);
                    if (m_smi_dtr_req_for_atomics.exists(m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_rbid) && (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_cmstatus_err === 1)) begin
                        m_smi_dtr_req_for_atomics.delete(m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_rbid);
                    end
		       
                        str_state_list.delete(m_tmp_seq_item.smi_rsp_unq_identifier);

//                        m_rbid_in_process.delete(m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_rbid);
                        //`uvm_info("SYS BFM DEBUG", $sformatf("Deleting RBID 0x%0x", m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_rbid), UVM_HIGH)
                        //->e_smi_rbid_freeup;
                    end
                    `uvm_info("SYS BFM DEBUG", $sformatf("deleting UnqId:0x%0h Addr:0x%0h",m_tmp_seq_item.smi_rsp_unq_identifier,m_smi_str_pending_addr_h[m_tmp_seq_item.smi_rsp_unq_identifier]), UVM_HIGH)
                    if (m_smi_str_pending_addr_h.exists(m_tmp_seq_item.smi_rsp_unq_identifier)) begin
                        m_smi_str_pending_addr_h.delete(m_tmp_seq_item.smi_rsp_unq_identifier);
                        ->e_smi_str_pending_addr_h_freeup;
                    end
                    <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                    if (m_smi_str_pending_mem_upd_addr_h.exists(m_tmp_seq_item.smi_rsp_unq_identifier)) begin
                        m_smi_str_pending_mem_upd_addr_h.delete(m_tmp_seq_item.smi_rsp_unq_identifier);
                    end
                    <% } %>
                    m_unq_id_array.delete(m_tmp_seq_item.smi_rsp_unq_identifier);
                end
                else if (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].isSysReqMsg()) begin
                    event_msg_inflight.delete(m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_src_ncore_unit_id);
                    m_unq_id_array.delete(m_tmp_seq_item.smi_rsp_unq_identifier);
                    //`uvm_info("SYS BFM DEBUG", m_tmp_seq_item.smi_rsp_unq_identifier), UVM_HIGH)
                end
                ->e_smi_unq_id_freeup;
                if (m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].isSnpMsg()) begin
		   uvm_report_info("DCDEBUG",$sformatf("snoopoutst:%0d",snoop_outst),UVM_HIGH);
		   if(m_smi_tx_req_q[m_tmp_qA[m_tmp_qB[0]]].smi_msg_type == SNP_DVM_MSG)
		     snoop_outst -= 2;
		   else
		     snoop_outst--;
		   ->e_smi_snp_req_free;
	        end
                m_smi_tx_req_q.delete(m_tmp_qA[m_tmp_qB[0]]);
                `ifdef VCS
                 -> e_smi_outstandingq_del;
                `endif
            end
            m_tmp_q = {};
            m_tmp_q = m_req_in_process.find_index with (item.m_smi_unq_id == m_tmp_seq_item.smi_rsp_unq_identifier);
            if (m_tmp_q.size() > 0) begin
                if (m_tmp_q.size() > 1) begin
                    `uvm_info("SYS BFM DEBUG", "Printing all matching requests below:", UVM_LOW);
                    foreach (m_tmp_q[i]) begin
                        `uvm_info("SYS BFM DEBUG", $sformatf("%0p", m_req_in_process[m_tmp_q[i]]), UVM_LOW);
                    end
                    `uvm_info("SYS BFM DEBUG", "Printing response below:", UVM_LOW);
                    `uvm_info("SYS BFM DEBUG", m_tmp_seq_item.convert2string(), UVM_LOW);
                    `uvm_error("SYSTEM BFM MASTER RSP REQ IN PROCESS QUEUE", $sformatf("TB Error: Got above response on SMI master port with transID that matches multiple outstanding requests"));
                end
                else begin
                    m_req_in_process.delete(m_tmp_q[0]);
                end
            end
        end
    end 
endtask : process_rx_resp

task create_str_req(ref smi_seq_item_addr_t m_str_item, const ref coherResult_t coher_result_final, const ref smi_seq_item m_cmd_trans);
    bit [6:0] random_strreq_cmstatus_error_payload;
   <% if((obj.testBench == 'io_aiu') || (obj.testBench == 'chi_aiu')) { %>
   `ifdef VCS
    bit [WSMICMSTATUSERRPAYLOAD-1:0] smi_cmstatus_err_payload_vcs;
   `endif // `ifdef VCS ... `endif ... 
   <%  } %> 
    smi_intfsize_t    smi_intfsize;
    bit 	      isNonCoh;
    int k_strreq_cmstatus_with_error_wgt;
   
    m_str_item.m_seq_item                        = smi_seq_item::type_id::create("m_str_item");
//    m_str_item.m_seq_item.randomize();
//   std::randomize(smi_intfsize);
   std::randomize(smi_intfsize) with {
      smi_intfsize inside {0,1,2};
   };
    //#Cov.IOAIU.DataRotation
    m_str_item.m_seq_item.smi_intfsize      = smi_intfsize;
    //#Stimulus.IOAIU.WrongTargetId
    if($test$plusargs("wrong_strreq_target_id")) begin
      if($test$plusargs("error_in_2nd_part")) begin
        if(m_cmd_trans.smi_msg_type == eCmdClnInv || m_cmd_trans.smi_msg_type == eCmdClnVld || m_cmd_trans.smi_msg_type == eCmdClnShdPer)
       	  m_str_item.m_seq_item.smi_targ_ncore_unit_id = m_cmd_trans.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'h1}};
      end else if($test$plusargs("error_in_cmo_part")) begin
         if(m_cmd_trans.smi_msg_type != eCmdMkUnq) 
        	   m_str_item.m_seq_item.smi_targ_ncore_unit_id = m_cmd_trans.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'h1}};
      end else if($test$plusargs("error_in_writeevictorevict")) begin
         if(m_cmd_trans.smi_msg_type == eCmdEvict) 
        	   m_str_item.m_seq_item.smi_targ_ncore_unit_id = m_cmd_trans.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'h1}};
      end else begin 
       	   m_str_item.m_seq_item.smi_targ_ncore_unit_id = m_cmd_trans.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'h1}};
      end
    end else begin
            m_str_item.m_seq_item.smi_targ_ncore_unit_id = m_cmd_trans.smi_src_ncore_unit_id;
    end
    m_str_item.m_seq_item.smi_src_ncore_unit_id  = m_cmd_trans.smi_targ_ncore_unit_id;
    m_str_item.m_seq_item.smi_msg_type           = STR_STATE;
    m_str_item.m_seq_item.unpack_smi_unq_identifier();
    //`uvm_info("SYS BFM DEBUG", $sformatf("Reached here 5"), UVM_HIGH)
    giveSmiMsgId(m_str_item.m_seq_item);
//    `uvm_info("SYS BFM DEBUG", $sformatf("Reached here 6"), UVM_HIGH)
    m_str_item.m_seq_item.smi_msg_tier       = 0;
    m_str_item.m_seq_item.smi_steer          = 0;
    m_str_item.m_seq_item.smi_msg_pri        = m_cmd_trans.smi_msg_pri;
    m_str_item.m_seq_item.smi_msg_qos        = m_cmd_trans.smi_msg_qos;
    m_str_item.m_seq_item.smi_tm             = m_cmd_trans.smi_tm;
    $value$plusargs("strreq_cmstatus_with_error=%d",k_strreq_cmstatus_with_error_wgt);
    if ($test$plusargs("strreq_cmstatus_with_error")) begin //#Stimulus.CHIAIU.v3.strcmstatuserror
      randcase
        k_strreq_cmstatus_with_error_wgt: begin
                                            if ((m_str_item.m_seq_item.smi_src_ncore_unit_id >= DCE_Funit_Id[0]) && (m_str_item.m_seq_item.smi_src_ncore_unit_id <= DCE_Funit_Id[<%=obj.DceInfo.length-1%>])) begin
                                                //`uvm_info("SYS BFM DEBUG", $sformatf("strreq going from DCE (cmstatus with error) cmd_req addr: 0x%0h msgid: %0d only address error is possible", m_cmd_trans.smi_addr, m_cmd_trans.smi_msg_id), UVM_LOW)
                                                //#Stimulus.IOAIU.STRreq.CMStatusAddrErr
                                                //#Stimulus.IOAIU.STRreq.CMStatusDataErr
						if($test$plusargs("error_in_2nd_part"))begin
						   if(m_cmd_trans.smi_msg_type == eCmdClnInv || m_cmd_trans.smi_msg_type == eCmdClnVld || m_cmd_trans.smi_msg_type == eCmdClnShdPer)
					              m_str_item.m_seq_item.smi_cmstatus_err   = 1;	
						end else begin
                                              	m_str_item.m_seq_item.smi_cmstatus_err   = 1;
						end
                                                <% if ((obj.testBench =="io_aiu")) { %>
                                                if($test$plusargs("strreq_data_error"))begin
                                                m_str_item.m_seq_item.smi_cmstatus_err_payload = 7'b00_00_011;  
						end
                                                else if($test$plusargs("strreq_address_error")) begin
                                                m_str_item.m_seq_item.smi_cmstatus_err_payload = 7'b00_00_100;
                                                end
                                                else begin
                                                <% if(obj.testBench == 'io_aiu') { %>
                                                `ifndef VCS
						std::randomize(m_str_item.m_seq_item.smi_cmstatus_err_payload) with {m_str_item.m_seq_item.smi_cmstatus_err_payload inside{7'b00_00_011,7'b00_00_100};};
                                                `else
						std::randomize(smi_cmstatus_err_payload_vcs) with {smi_cmstatus_err_payload_vcs inside{7'b00_00_011,7'b00_00_100};};
                                                m_str_item.m_seq_item.smi_cmstatus_err_payload=smi_cmstatus_err_payload_vcs;
                                                `endif // `ifndef VCS ... `else ... 
                                                <%  } else {%>
						std::randomize(m_str_item.m_seq_item.smi_cmstatus_err_payload) with {m_str_item.m_seq_item.smi_cmstatus_err_payload inside{7'b00_00_011,7'b00_00_100};};
                                                <%  } %> 
                                                end
						<%} else {%>
                                                <% if(obj.testBench == 'chi_aiu') { %>
                                                `ifndef VCS
						 if($test$plusargs("error_in_2nd_part"))begin
						    if(m_cmd_trans.smi_msg_type == eCmdClnInv || m_cmd_trans.smi_msg_type == eCmdClnVld || m_cmd_trans.smi_msg_type == eCmdClnShdPer) begin
			     	                       std::randomize(m_str_item.m_seq_item.smi_cmstatus_err_payload) with {m_str_item.m_seq_item.smi_cmstatus_err_payload inside{7'b00_00_011,7'b00_00_100};};
				                    end
						 end else begin
			        	               std::randomize(m_str_item.m_seq_item.smi_cmstatus_err_payload) with {m_str_item.m_seq_item.smi_cmstatus_err_payload inside{7'b00_00_011,7'b00_00_100};};
						 end
                                                `else
						  if($test$plusargs("error_in_2nd_part"))begin
						     if(m_cmd_trans.smi_msg_type == eCmdClnInv || m_cmd_trans.smi_msg_type == eCmdClnVld || m_cmd_trans.smi_msg_type == eCmdClnShdPer) begin
						        std::randomize(smi_cmstatus_err_payload_vcs) with {smi_cmstatus_err_payload_vcs inside{7'b00_00_011,7'b00_00_100};};
                                                        m_str_item.m_seq_item.smi_cmstatus_err_payload=smi_cmstatus_err_payload_vcs;
					             end
						  end else begin
						     if(m_cmd_trans.smi_msg_type == eCmdEvict)
						         std::randomize(smi_cmstatus_err_payload_vcs) with {smi_cmstatus_err_payload_vcs inside{7'b00_00_100};};
						    else std::randomize(smi_cmstatus_err_payload_vcs) with {smi_cmstatus_err_payload_vcs inside{7'b00_00_011,7'b00_00_100};};
                                                        m_str_item.m_seq_item.smi_cmstatus_err_payload=smi_cmstatus_err_payload_vcs;
						  end
                                                `endif // `ifndef VCS ... `else ... 
                                                <% } else {%>
				                        std::randomize(m_str_item.m_seq_item.smi_cmstatus_err_payload) with {m_str_item.m_seq_item.smi_cmstatus_err_payload inside{7'b00_00_011,7'b00_00_100};};
                                                <%}%> 
                                                <%}%> 
                                            end
                                            else begin
                                                //`uvm_info("SYS BFM DEBUG", $sformatf("strreq going from DMI (cannot have cmstatus error) cmd_req addr: 0x%0h msgid: %0d", m_cmd_trans.smi_addr, m_cmd_trans.smi_msg_id), UVM_LOW)
                                                m_str_item.m_seq_item.smi_cmstatus_err   = 0;
                                                m_str_item.m_seq_item.smi_cmstatus_so    = coher_result_final.SO;
                                                m_str_item.m_seq_item.smi_cmstatus_ss    = coher_result_final.SS;
                                                m_str_item.m_seq_item.smi_cmstatus_sd    = coher_result_final.SD;
                                                m_str_item.m_seq_item.smi_cmstatus_st    = coher_result_final.ST;
                                            end
                                          end
        (100-k_strreq_cmstatus_with_error_wgt): begin
                                                  m_str_item.m_seq_item.smi_cmstatus_err   = 0;
                                                  m_str_item.m_seq_item.smi_cmstatus_so    = coher_result_final.SO;
                                                  m_str_item.m_seq_item.smi_cmstatus_ss    = coher_result_final.SS;
                                                  m_str_item.m_seq_item.smi_cmstatus_sd    = coher_result_final.SD;
                                                  m_str_item.m_seq_item.smi_cmstatus_st    = coher_result_final.ST;
                                                end
      endcase
   end else begin // if ($test$plusargs("strreq_cmstatus_with_error"))
      m_str_item.m_seq_item.smi_cmstatus_err   = 0;
      m_str_item.m_seq_item.smi_cmstatus_so    = coher_result_final.SO;
      m_str_item.m_seq_item.smi_cmstatus_ss    = coher_result_final.SS;
      m_str_item.m_seq_item.smi_cmstatus_sd    = coher_result_final.SD;
      m_str_item.m_seq_item.smi_cmstatus_st    = coher_result_final.ST;
    end // else: !if($test$plusargs("strreq_cmstatus_with_error"))

      
    // m_str_item.m_seq_item.smi_cmstatus_snarf = $urandom_range(m_cmd_trans.smi_mpf1_stash_valid,0);
    //CONC-12159
    //#Stimulus.IOAIU.SMI.StrReq.cmstatus.Snarf
    //#Stimulus.IOAIU.SMI.CMDReq.MPF1.StashNId
    if (   m_cmd_trans.smi_mpf1_stash_valid 
             && (addrMgrConst::is_stash_enable(addrMgrConst::agentid_assoc2funitid(m_cmd_trans.smi_mpf1_stash_nid)))
             && (m_cmd_trans.smi_mpf1_stash_nid != m_cmd_trans.smi_src_ncore_unit_id)
     )
     begin
        //m_str_item.m_seq_item.smi_cmstatus_snarf = $urandom_range(m_cmd_trans.smi_mpf1_stash_valid,0);
        std::randomize(str_snarf) with {str_snarf dist {0:=10,1:=90} ;};
        m_str_item.m_seq_item.smi_cmstatus_snarf =str_snarf ;
        //`uvm_info("SYS_BFM",$sformatf("Target Identified setting snarf = %0d for %s cmd:%s",m_str_item.m_seq_item.smi_cmstatus_snarf,m_str_item.m_seq_item.convert2string(),m_cmd_trans.convert2string()),UVM_LOW);
     end
    else begin
            m_str_item.m_seq_item.smi_cmstatus_snarf = 0;
    end
    
     //m_report_info("DCDEBUG",$sformatf("setting snarf = %0d for %s cmd:%s",m_str_item.m_seq_item.smi_cmstatus_snarf,m_str_item.m_seq_item.convert2string(),m_cmd_trans.convert2string()),UVM_MEDIUM);
    if(m_str_item.m_seq_item.smi_cmstatus_snarf) begin
        m_str_item.m_seq_item.smi_mpf1_stash_nid = m_cmd_trans.smi_mpf1_stash_nid;
    end

   
    m_str_item.m_seq_item.smi_cmstatus_exok  = (m_cmd_trans.smi_es == 1) ? 
					       ((m_cmd_trans.smi_msg_type === eCmdWrNCPtl) || (m_cmd_trans.smi_msg_type === eCmdWrNCFull)|| (m_cmd_trans.smi_msg_type === eCmdRdNC)) ? 1 :  
						$urandom_range(1, 0) : 0;
    isNonCoh =  ((m_cmd_trans.smi_msg_type === eCmdWrNCPtl) || 
                 (m_cmd_trans.smi_msg_type === eCmdWrNCFull)||
                 (m_cmd_trans.smi_msg_type === eCmdRdNC)    ||
    <% if ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E") ) { %>
                 ((m_cmd_trans.smi_msg_type === eCmdClnShdPer ||
                   m_cmd_trans.smi_msg_type == eCmdClnVld ||
                   m_cmd_trans.smi_msg_type == eCmdClnInv ||
                   m_cmd_trans.smi_msg_type == eCmdMkInv) &&
                   !(m_cmd_trans.smi_targ_ncore_unit_id inside {DCE_Funit_Id})) ||
                <% } %>
		// (m_cmd_trans.smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm} &&  !m_cmd_trans.smi_ch);
		 (m_cmd_trans.smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm} &&  m_cmd_trans.smi_targ_ncore_unit_id inside {DMI_Funit_Id}));

//`uvm_info("SYS BFM DEBUG", $psprintf("func:create_str_req m_cmd_trans:%0s isNonCoh:%0b", m_cmd_trans.convert2string, isNonCoh), UVM_LOW)
//if((m_cmd_trans.smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm} &&  m_cmd_trans.smi_ch==1)) //smi_targ_ncore_unit_id inside {DCE_Funit_Id}))
if(m_cmd_trans.smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm} && m_cmd_trans.smi_targ_ncore_unit_id inside {DCE_Funit_Id}) 
	m_str_item.m_seq_item.smi_rbid= '1;
else begin
    giveSmiRbId(m_str_item.m_seq_item,isNonCoh);
end
    m_str_item.m_seq_item.smi_rmsg_id     = m_cmd_trans.smi_msg_id;
    m_str_item.m_seq_item.smi_mpf1_argv   = 0;
    if(m_cmd_trans.smi_msg_type == eCmdWrStshFull &&
       m_str_item.m_seq_item.smi_cmstatus_snarf == 1) begin
        giveSmiSnpDtrMsgId(m_str_item.m_seq_item);
        m_str_item.m_seq_item.smi_mpf2 = m_str_item.m_seq_item.smi_mpf2_dtr_msg_id;
    end else begin
        m_str_item.m_seq_item.smi_mpf2_flowid = 0;
    end
    m_str_item.m_seq_item.pack_smi_seq_item();
    m_str_item.t_smi_ndp_ready = $time;
    m_str_item.m_addr = { <%if(obj.wSecurityAttribute > 0){%>m_cmd_trans.smi_ns,<%}%> m_cmd_trans.smi_addr};
    $cast(m_str_item.cmd_type, m_cmd_trans.smi_msg_type);
    //`uvm_info("SYS BFM DEBUG", $psprintf("func:create_str_req isNonCoh:%0b CMDreq:%0s ******* STRreq:%0s", isNonCoh, m_cmd_trans.convert2string, m_str_item.m_seq_item.convert2string()), UVM_LOW)
endtask : create_str_req

task create_dtr_req(ref smi_seq_item m_dtr_item, const ref bfm_cacheState_t ending_state, const ref smi_seq_item m_cmd_trans);
    bit                flag = 1;
    bit [2:0]	       l_dwid;
    int unsigned       num_data_beats = (((2**m_cmd_trans.smi_size)/wSmiDPbe) == 0) ? 1 : ((2**m_cmd_trans.smi_size) /  wSmiDPbe);
    smi_dp_data_bit_t  m_random_data[];
    smi_dp_be_t        m_random_be[];
    int                mem_region;
    bit [6:0]          random_dtrreq_cmstatus_error_payload;
    int                cmstatus_data_error;
    int                cmstatus_non_data_error;
    bfm_cacheState_t   start_state;
    int                k_random_dbad_value_wgt;

    //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:create_dtr_req entry m_cmd_trans:%0s", m_cmd_trans.convert2string), UVM_LOW)
    //for atomic compare. Only half of data size is returned.
    if(m_cmd_trans.smi_msg_type == eCmdCompAtm && num_data_beats>1)
 	num_data_beats  = 1;
	
    m_random_data = new [num_data_beats];
    m_random_be   = new [num_data_beats];

    for (int j = 0; j <  num_data_beats; j++) begin
        smi_dp_data_bit_t  tmp;
        assert(std::randomize(tmp))
        else begin
            `uvm_error("SYS BFM SEQ", "Failure to randomize tmp");
        end
        m_random_data[j] = tmp;
        m_random_be[j]   = '1;
    end
    m_dtr_item = smi_seq_item::type_id::create("m_dtr_item");
    //#Stimulus.IOAIU.WrongTargetId
    if ($test$plusargs("wrong_dtrreq_target_id")) begin
      m_dtr_item.smi_targ_ncore_unit_id = m_cmd_trans.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'h1}};
    end else begin
      m_dtr_item.smi_targ_ncore_unit_id = m_cmd_trans.smi_src_ncore_unit_id;
    end
    // FIXME: Below target id should be randomized
    m_dtr_item.smi_src_ncore_unit_id  = addrMgrConst::map_addr2dmi_or_dii(m_cmd_trans.smi_addr, mem_region);
    case (ending_state)
        SysBfmUC: m_dtr_item.smi_msg_type = eDtrDataUnqCln;
        SysBfmUD: m_dtr_item.smi_msg_type = eDtrDataUnqDty;
        SysBfmSC: m_dtr_item.smi_msg_type = eDtrDataShrCln;
        SysBfmSCOwner: m_dtr_item.smi_msg_type = eDtrDataUnqCln;
        SysBfmSD: m_dtr_item.smi_msg_type = eDtrDataShrDty;
        SysBfmIX: m_dtr_item.smi_msg_type = eDtrDataInv;
        default: begin
            `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unrecognized end_state in process_cmd_req"));
        end
    endcase
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
    start_state = SysBfmIX;
    if (state_list.exists({
    <% if (obj.wSecurityAttribute > 0) { %>
        m_cmd_trans.smi_ns,
    <% } %>
    m_cmd_trans.smi_addr[WSMIADDR-1:SYS_wSysCacheline]})) begin
        start_state = state_list[{
        <% if (obj.wSecurityAttribute > 0) { %>
            m_cmd_trans.smi_ns,
        <% } %>
            m_cmd_trans.smi_addr[WSMIADDR-1:SYS_wSysCacheline]}];
    end
    if(start_state == SysBfmUC || start_state == SysBfmUD) begin
        if (m_cmd_trans.smi_msg_type == eCmdRdNC)
            m_dtr_item.smi_msg_type = eDtrDataInv;
        else
            m_dtr_item.smi_msg_type = eDtrDataUnqCln;
    end
    if(start_state == SysBfmSD || start_state == SysBfmSCOwner) begin
        if (ending_state == SysBfmUD) begin
            m_dtr_item.smi_msg_type = eDtrDataUnqCln;
        end else if (ending_state == SysBfmSD || ending_state == SysBfmSCOwner) begin
            m_dtr_item.smi_msg_type = eDtrDataShrCln;
        end
    end
    if( m_cmd_trans.smi_msg_type == eCmdRdNITC ||
        m_cmd_trans.smi_msg_type == eCmdClnVld ) begin
        if(start_state == SysBfmIX && ending_state == SysBfmIX) begin
            randcase
                50: m_dtr_item.smi_msg_type = eDtrDataInv;
                50: m_dtr_item.smi_msg_type = eDtrDataShrCln;
            endcase
        end
    end

<% } %>

    //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:create_dtr_req cmdtype:%0p dtrtype:%0p start_state:%0p endstate:%0p", m_cmd_trans.smi_msg_type, m_dtr_item.smi_msg_type, start_state, ending_state), UVM_LOW)

    m_dtr_item.unpack_smi_unq_identifier();
    //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:create_dtr_req before giveSmiMsgId call m_cmd_trans:%0s", m_cmd_trans.convert2string), UVM_LOW)
    giveSmiMsgId(m_dtr_item);
    //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:create_dtr_req after giveSmiMsgId call m_cmd_trans:%0s", m_cmd_trans.convert2string), UVM_LOW)
    m_dtr_item.smi_msg_tier = 0;
    m_dtr_item.smi_steer    = 0;
    m_dtr_item.smi_msg_pri  = m_cmd_trans.smi_msg_pri;
    m_dtr_item.smi_msg_qos  = m_cmd_trans.smi_msg_qos;
    $value$plusargs("cmstatus_data_error=%d",cmstatus_data_error);
    $value$plusargs("cmstatus_non_data_error=%d",cmstatus_non_data_error);
    if ($test$plusargs("dtrreq_cmstatus_with_error")) begin //#Stimulus.CHIAIU.v3.derrondtrreq //#Stimulus.CHIAIU.v3.nderrondtrreq
      //#Stimulus.IOAIU.DTRreq.CMStatusAddrErr  
      //#Stimulus.IOAIU.DTRreq.CMStatusDataErr
      std::randomize(random_dtrreq_cmstatus_error_payload) with { if (cmstatus_non_data_error > 0) { random_dtrreq_cmstatus_error_payload dist {
                                        		7'b00_00_100 := cmstatus_non_data_error, //CCMP reported error, protocol address error
                                            	0 := (100-cmstatus_non_data_error)
                                            	};
                                            } else if (cmstatus_data_error > 0) { random_dtrreq_cmstatus_error_payload dist {
                                        		7'b00_00_011 := cmstatus_data_error, //CCMP reported error, protocol data error
                                        		0 := (100-cmstatus_data_error)
                                				};
                                        	} 
                                            else {
                                                random_dtrreq_cmstatus_error_payload == 0;
                                                }
                                            };
      if (random_dtrreq_cmstatus_error_payload == 0) begin
        m_dtr_item.smi_cmstatus_err   = 0;
      end else begin
        m_dtr_item.smi_cmstatus_err   = 1;
      end
      m_dtr_item.smi_cmstatus_err_payload = random_dtrreq_cmstatus_error_payload;
    end else begin
      m_dtr_item.smi_cmstatus = 0;
    end


    m_dtr_item.smi_rl       = 0;
    <% if(obj.Block =='chi_aiu') { %>
    m_dtr_item.smi_tm       = m_cmd_trans.smi_tm;
    <% } else { %>
    m_dtr_item.smi_tm       = $urandom_range(0,1);
    <% } %>
    m_dtr_item.smi_cmstatus_exok  = (m_cmd_trans.smi_es == 1 && m_dtr_item.smi_cmstatus_err == 0) ? $urandom_range(1, 0) : 0;
    m_dtr_item.smi_rmsg_id  = m_cmd_trans.smi_msg_id;
    m_dtr_item.smi_dp_data  = new[m_random_data.size()] (m_random_data);
    m_dtr_item.smi_dp_be    = new[m_random_be.size()] (m_random_be);
    m_dtr_item.smi_dp_dwid  = new[m_dtr_item.smi_dp_data.size()];
    m_dtr_item.smi_dp_dbad  = new[m_dtr_item.smi_dp_data.size()];
    foreach (m_dtr_item.smi_dp_dwid[i]) begin
         <%if(obj.AiuInfo[obj.Id].wData==128){ %>
             if(m_cmd_trans.smi_size == 'h5 && m_cmd_trans.smi_addr[5:4]%2==1 && m_cmd_trans.smi_msg_type != eCmdCompAtm)
             begin
	   	l_dwid = (m_cmd_trans.smi_addr[5:4]-i)*2;
        	m_dtr_item.smi_dp_dwid[i] = {l_dwid+1, l_dwid};
             end
	     else
             begin
	   	l_dwid = (i+m_cmd_trans.smi_addr[5:4])*2;
        	m_dtr_item.smi_dp_dwid[i] = {l_dwid+1, l_dwid};
             end
        <%} else if(obj.AiuInfo[obj.Id].wData==256){%>
	   	l_dwid = (i+m_cmd_trans.smi_addr[5])*4;
        	m_dtr_item.smi_dp_dwid[i] = {l_dwid+3'h3, l_dwid+3'h2, l_dwid+3'h1, l_dwid};
	<%}%>
        if ($value$plusargs("random_dbad_value=%d",k_random_dbad_value_wgt)) begin
          randcase
            k_random_dbad_value_wgt: m_dtr_item.smi_dp_dbad[i] = $random; 
            (100-k_random_dbad_value_wgt): m_dtr_item.smi_dp_dbad[i] = '0;
          endcase
        end else begin
          m_dtr_item.smi_dp_dbad[i] = '0; //FIXME
        end
    end

    //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:create_dtr_req exit m_cmd_trans:%0s \n DTRreq:%0s", m_cmd_trans.convert2string, m_dtr_item.convert2string()), UVM_LOW)

endtask : create_dtr_req  

  <% if (obj.smiPortParams.tx.length == 4) { %>
task monitor_rx_dtr_resp();
    forever begin
        smi_seq_item m_tmp_seq_item;
        m_smi_seqr_rx_hash["dtr_rsp_tx_"].m_rx_analysis_fifo.get(m_tmp_seq_item); 
        m_smi_rx_rsp_q.push_back(m_tmp_seq_item);
        //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:monitor_rx_resp pushed into m_smi_rx_rsp_q- %0s",m_tmp_seq_item.convert2string()), UVM_LOW)
        ->e_smi_rx_rsp_q;
    end 
endtask : monitor_rx_dtr_resp
<% } %>

<% if (obj.smiPortParams.tx.length == 4) { %>
task monitor_rx_str_snp_sys_resp();
<% } else { %>
task monitor_rx_str_snp_dtr_sys_resp();
<% } %>

    forever begin
        smi_seq_item m_tmp_seq_item;
        m_smi_seqr_rx_hash["str_rsp_"].m_rx_analysis_fifo.get(m_tmp_seq_item); 
        m_smi_rx_rsp_q.push_back(m_tmp_seq_item);
        //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:monitor_rx_resp pushed into m_smi_rx_rsp_q- %0s",m_tmp_seq_item.convert2string()), UVM_LOW)
        if (m_dvm_unq_identifier_q[m_tmp_seq_item.smi_rsp_unq_identifier] == 1'b1) begin 
            ->e_smi_rx_rsp_dvm_cmd_q;
            m_dvm_unq_identifier_q.delete(m_tmp_seq_item.smi_rsp_unq_identifier);
        end
        else begin
            ->e_smi_rx_rsp_q;
        end
    end 

<% if (obj.smiPortParams.tx.length == 4) { %>
endtask: monitor_rx_str_snp_sys_resp;
<% } else { %>
endtask: monitor_rx_str_snp_dtr_sys_resp;
<% } %>


task process_cmd_req(bit isCoherent);
   smi_seq_item                          m_cmd_trans;
   coherResult_t                         coher_result[$];
   bfm_cacheState_t                      start_state;
   bfm_cacheState_t                      ending_state;
   coherResult_t                         coher_result_final;
   coherResult_t                         coher_result_dvm;
   bit                                   isNonCohCmd;
   bit                                   flag;
   int                                   rand_index;
   bit                                   isDVM;
   int                                   count_cmdreq;
   int                                   total_cmdreq;
   int                                   index[$];
   smi_seq_item_addr_t                   m_tmp_str_item;
   smi_seq_item                          m_tmp_dtr_item;
   req_in_process_t                      m_req;
   smi_unq_identifier_bit_t temp;
   smi_seq_item_addr_t                   smi_cmd_req_q[$];
   smi_addr_security_t                   processing_cmdreq_addr_q[$];
   smi_addr_security_t                   m_tmp_addr;
   smi_addr_security_t                   m_tmp_addr1;

   smi_seq_item_addr_t                   m_tmp_cmd_item;
   eMsgCMD                               cmd_type;
   int                                  key;

   if(isCoherent) begin
      total_cmdreq = m_smi_cmd_req_q.size();
      //m_smi_cmd_req_q.shuffle();
      //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req COH size:%0d, DVM size:%0d",m_smi_cmd_req_q.size(), m_smi_dvm_cmd_req_q.size()), UVM_LOW)

   end else begin
      total_cmdreq = m_smi_nc_cmd_req_q.size();
      //m_smi_nc_cmd_req_q.shuffle();
      //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req NON-COH size:%0d",m_smi_nc_cmd_req_q.size()), UVM_LOW)
   end

		  
   //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req waiting for s_addr semaphore"), UVM_LOW)
   count_cmdreq = 0;
   if(isCoherent) begin
       #1   //This is definately needed to avoid race condition with get and put. Need get to be evaluated at end of timestamp
     s_addr.get(); //OUTERLOCK
    end else begin
       #1   //This is definately needed to avoid race condition with get and put. Need get to be evaluated at end of timestamp
     s_nc_addr.get();
    end

   //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req acquired s_addr semaphore"), UVM_LOW)
   
    
    do begin
      int index;
      int m_tmp_q[$];
      flag= 1;
      if(isCoherent) begin
          if(m_smi_dvm_cmd_req_q.size()>0 && m_smi_cmd_req_q.size()==0) begin
            m_cmd_trans = m_smi_dvm_cmd_req_q[0].m_seq_item;
          end else if(m_smi_dvm_cmd_req_q.size()==0 && m_smi_cmd_req_q.size()>0) begin
            m_cmd_trans = m_smi_cmd_req_q[count_cmdreq].m_seq_item;
          end else begin
              randcase
	        50: m_cmd_trans = m_smi_cmd_req_q[count_cmdreq].m_seq_item;
	        50: m_cmd_trans = m_smi_dvm_cmd_req_q[0].m_seq_item;
              endcase
          end
      end else begin
	 	  m_cmd_trans = m_smi_nc_cmd_req_q[count_cmdreq].m_seq_item;
      end
    //  `uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req m_cmd_trans:%0s", m_cmd_trans.convert2string()), UVM_LOW)

      
      if (m_cmd_trans.smi_msg_type == eCmdDvmMsg) begin
         isDVM = 1;
      end else if ((m_cmd_trans.smi_msg_type inside {eCmdWrNCPtl, eCmdWrNCFull, eCmdRdNC, eCmdPref}) ||
                <% if ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E") ) { %>
                    (((m_cmd_trans.smi_msg_type === eCmdClnShdPer)||
                      (m_cmd_trans.smi_msg_type === eCmdClnVld)   ||
                      (m_cmd_trans.smi_msg_type === eCmdClnInv)   ||
                      (m_cmd_trans.smi_msg_type === eCmdMkInv ))  &&
                    !(m_cmd_trans.smi_targ_ncore_unit_id inside {DCE_Funit_Id})) ||
                <% } %>
                ((m_cmd_trans.smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm}) && (m_cmd_trans.smi_targ_ncore_unit_id inside {DMI_Funit_Id}))) begin
         isNonCohCmd = 1;
      end 

      if (!isDVM) begin : _notDvm_
         if (!isNonCohCmd) begin: _CohCmd_
            flag = !(isAddrInSmiStrPendingAssocArray({
                <% if (obj.wSecurityAttribute > 0) { %>                                             
		      m_cmd_trans.smi_ns,
                <% } %>                                                
                      m_cmd_trans.smi_addr[WSMIADDR-1:0]}) ||
                     isAddrInSmiSnpPendingArray({
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                      m_cmd_trans.smi_ns,
                <% } %>                                                
                      m_cmd_trans.smi_addr[WSMIADDR-1:0]})
                <% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                    || isAddrInSmiStrPendingMemUpdArray({
                    <% if (obj.wSecurityAttribute > 0) { %>
                        m_cmd_trans.smi_ns,
                    <% } %>
                        m_cmd_trans.smi_addr[WSMIADDR-1:0]})
                <% } %>
                  );
            //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:process_cmd_req (inside !isNonCohCmd) m_cmd_trans:%0s flag=%b str_pending=%0d, snp_pending=%0d memUpd_pending:%0d", m_cmd_trans.convert2string(), flag, isAddrInSmiStrPendingAssocArray({<% if (obj.wSecurityAttribute > 0) { %>m_cmd_trans.smi_ns,<% } %>m_cmd_trans.smi_addr[WSMIADDR-1:0]}), isAddrInSmiSnpPendingArray({ <% if (obj.wSecurityAttribute > 0) { %> m_cmd_trans.smi_ns, <% } %>m_cmd_trans.smi_addr[WSMIADDR-1:0]}) <% if(obj.fnNativeInterface == "ACE"){%> , isAddrInSmiStrPendingMemUpdArray({
         //           <% if (obj.wSecurityAttribute > 0) { %>
         //               m_cmd_trans.smi_ns,
         //           <% } %>
         //               m_cmd_trans.smi_addr[WSMIADDR-1:0]})
         //       <% } %>), UVM_LOW)
            if (m_cmd_trans.smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm}) begin
               //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:process_cmd_req Atomic addr=0x%0h, str_pending=%0d, snp_pending=%0d", m_cmd_trans.smi_addr, isAddrInSmiStrPendingAssocArray({<% if (obj.wSecurityAttribute > 0) { %>m_cmd_trans.smi_ns,<% } %>m_cmd_trans.smi_addr[WSMIADDR-1:0]}), isAddrInSmiSnpPendingArray({ <% if (obj.wSecurityAttribute > 0) { %> m_cmd_trans.smi_ns, <% } %>m_cmd_trans.smi_addr[WSMIADDR-1:0]})), UVM_LOW)
               if (flag == 0
                   && (isAddrInSmiStrPendingAssocArray({
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                          m_cmd_trans.smi_ns,
                    <% } %>                                                
                          m_cmd_trans.smi_addr[WSMIADDR-1:0]}))
                   && !(isAddrInSmiSnpReqOutstandingArray({
                       <% if (obj.wSecurityAttribute > 0) { %>                                             
                          m_cmd_trans.smi_ns,
                       <% } %>                                                
                          m_cmd_trans.smi_addr[WSMIADDR-1:0]}))) begin
                  // //Atomic transactions will have STR_RSP pending until both STR_REQs(DVE and DMI) are seen and precessed by AIU.
                  // //STR_RSP for both requests will be seen at the end of transaction.
                  if (m_smi_atomic_str_pending_addr_h.exists(m_cmd_trans.smi_unq_identifier)) begin
                     flag = 1; 
                  end
               end
            end
            m_tmp_q = {};
            m_tmp_q = processing_cmdreq_addr_q.find_first_index with (item[WSMIADDR-1:SYS_wSysCacheline] == m_cmd_trans.smi_addr[WSMIADDR-1:SYS_wSysCacheline]
	<% if (obj.wSecurityAttribute > 0) { %>                                             
		&& item[$size(item) - 1 : $size(item) - <%=obj.wSecurityAttribute%>] == m_cmd_trans.smi_ns    
	<% } %>                                                
                       );
            if (m_tmp_q.size() > 0) begin
               flag = 0;
                //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:process_cmd_req Setting flag=0 since there is already another outstanding cmdreq being processed with same address"), UVM_LOW)
            end
         end: _CohCmd_
	 
         //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:process_cmd_req NonCohCmd:%0d (outside !isNonCohCmd) m_cmd_trans:%0s flag=%b", isNonCohCmd, m_cmd_trans.convert2string(), flag), UVM_LOW)
         
         if (!flag) begin: _flag0_
            count_cmdreq++;
            //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:process_cmd_req count_cmdreq:%0d total_cmdreq:%0d", count_cmdreq, total_cmdreq), UVM_LOW)
            if (count_cmdreq >= total_cmdreq) begin
               //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req Waiting for e_smi_unq_id_freeup"), UVM_LOW)
//	       if(isCoherent)
		 @e_smi_unq_id_freeup;
//	       else 
//		 @e_smi_nc_unq_id_freeup;
               //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req Done waiting for e_smi_unq_id_freeup"), UVM_LOW)
               count_cmdreq = 0;
	       if(isCoherent) begin
		  total_cmdreq = m_smi_cmd_req_q.size();
		  smi_cmd_req_q.shuffle();
	       end else begin
		  total_cmdreq = m_smi_nc_cmd_req_q.size();
		  m_smi_nc_cmd_req_q.shuffle();
	       end
            end
         end: _flag0_
         else begin: _flag1_
            // Processing the oldest CmdReq to this cacheline first
            int  index;
            time t_index;
            m_tmp_q = {};
	    if(isCoherent) begin
               m_tmp_q = m_smi_cmd_req_q.find_index with (item.m_addr[WSMIADDR-1:SYS_wSysCacheline] == m_cmd_trans.smi_addr[WSMIADDR-1:SYS_wSysCacheline] 
               <% if (obj.wSecurityAttribute > 0) { %>                                             
                                && item.m_addr[$size(item.m_addr) - 1 : $size(item.m_addr) - <%=obj.wSecurityAttribute%>] == m_cmd_trans.smi_ns
               <% } %>                                                
                      );
	    end else begin
               m_tmp_q = m_smi_nc_cmd_req_q.find_index with (item.m_addr[WSMIADDR-1:SYS_wSysCacheline] == m_cmd_trans.smi_addr[WSMIADDR-1:SYS_wSysCacheline] 
               <% if (obj.wSecurityAttribute > 0) { %>                                             
                                && item.m_addr[$size(item.m_addr) - 1 : $size(item.m_addr) - <%=obj.wSecurityAttribute%>] == m_cmd_trans.smi_ns
               <% } %>                                                
                      );
	    end

            if (m_tmp_q.size() == 0) begin
               `uvm_error("SYS BFM SEQ", $sformatf("TB Error: Not possible to reach here for address 0x%0x", m_cmd_trans.smi_addr)); 
            end
            else if (m_tmp_q.size() > 1) begin
               index = m_tmp_q[0];
	       if(isCoherent) begin
		  t_index = m_smi_cmd_req_q[m_tmp_q[0]].t_smi_ndp_ready;
		  for (int i = 1; i < m_tmp_q.size(); i++) begin
                     if (t_index > m_smi_cmd_req_q[m_tmp_q[i]].t_smi_ndp_ready) begin
			t_index = m_smi_cmd_req_q[m_tmp_q[i]].t_smi_ndp_ready;
			index   = m_tmp_q[i];
                     end
		  end
	       end else begin
		  t_index = m_smi_nc_cmd_req_q[m_tmp_q[0]].t_smi_ndp_ready;
		  for (int i = 1; i < m_tmp_q.size(); i++) begin
                     if (t_index > m_smi_nc_cmd_req_q[m_tmp_q[i]].t_smi_ndp_ready) begin
			t_index = m_smi_nc_cmd_req_q[m_tmp_q[i]].t_smi_ndp_ready;
			index   = m_tmp_q[i];
                     end
		  end
	       end
            end
            else begin
               index = m_tmp_q[0];
            end
            count_cmdreq = index;
	    if(isCoherent) begin
	       m_cmd_trans = m_smi_cmd_req_q[count_cmdreq].m_seq_item;
	    end else begin
	       m_cmd_trans = m_smi_nc_cmd_req_q[count_cmdreq].m_seq_item;
	    end
         end: _flag1_ 
      end : _notDvm_
   end while (!flag);
   
  // `uvm_info("SYS BFM DEBUG", $psprintf("tsk:process_cmd_req done with do-while loop m_cmd_trans:%0s flag=%b", m_cmd_trans.convert2string(), flag), UVM_LOW)
   
   if (m_cmd_trans.smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm}) begin

        //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:process_cmd_req m_cmd_trans:%0s m_smi_atomic_str_pending_addr_h contents before", m_cmd_trans.convert2string()), UVM_LOW)
        //foreach(m_smi_atomic_str_pending_addr_h[key]) $display("key: 0x%0h value: %d", key, m_smi_atomic_str_pending_addr_h[key]);
      // //Atomic transactions will have STR_RSP pending until both STR_REQs(DVE and DMI) are seen and precessed by AIU.
      // //STR_RSP for both requests will be seen at the end of transaction.
     <% if(obj.testBench == 'chi_aiu') { %>
     `ifndef VCS
      if(m_cmd_trans.smi_targ_ncore_unit_id inside {DCE_Funit_Id})begin 
     `else
      if(m_cmd_trans.smi_ch)begin // && m_cmd_trans.smi_targ_ncore_unit_id inside {DCE_Funit_Id}) begin
     `endif // `ifndef VCS ... `else ... 
     <%  } else {%>
      if(m_cmd_trans.smi_targ_ncore_unit_id inside {DCE_Funit_Id})begin 
     <%  } %> 
         //`uvm_info("SYS BFM DEBUG", $psprintf("reached here adding this address in m_smi_atomic_str_pending_addr_h addr=0x%0h, unq_identifier:0x%0h", m_cmd_trans.smi_addr,m_cmd_trans.smi_unq_identifier), UVM_HIGH)
         m_smi_atomic_str_pending_addr_h[m_cmd_trans.smi_unq_identifier] = 1;
      end else if (m_smi_atomic_str_pending_addr_h.exists(m_cmd_trans.smi_unq_identifier)) begin
         //`uvm_info("SYS BFM DEBUG", $psprintf("reached here 3 addr=0x%0h, unq_identifier=0x%0h", m_cmd_trans.smi_addr, m_cmd_trans.smi_unq_identifier), UVM_HIGH)
         m_smi_atomic_str_pending_addr_h.delete(m_cmd_trans.smi_unq_identifier);
      end

        //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:process_cmd_req m_cmd_trans:%0s m_smi_atomic_str_pending_addr_h contents after", m_cmd_trans.convert2string()), UVM_LOW)
        //foreach(m_smi_atomic_str_pending_addr_h[key]) $display("key: 0x%0h value: %d", key, m_smi_atomic_str_pending_addr_h[key]);

   end
   
   //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:process_cmd_req about to delete from smi_cmd_req_q m_cmd_trans:%0s", m_cmd_trans.convert2string), UVM_LOW)
      if(isCoherent) begin
         if(isDVM) begin
            m_smi_dvm_cmd_req_q.delete(0);
            `ifdef VCS
            -> e_smi_outstandingq_del;
            `endif
         end else begin
	    m_smi_cmd_req_q.delete(count_cmdreq);
            `ifdef VCS
            -> e_smi_outstandingq_del;
            `endif
         end
      end else begin
	 m_smi_nc_cmd_req_q.delete(count_cmdreq);
      end
  <%if (obj.orderedWriteObservation == true) {%>
  if(m_cmd_trans.smi_msg_type != 'h05)begin
   cmdreq_count++;
   end
   <%}else{%>
   cmdreq_count++;
   <%}%>
   `ifdef VCS
   if(cmdreq_count == m_pause_snoops_until_num_cmdreqs_vcs) begin
   ->e_match_cmdreq_pause_cnt;
//`uvm_info("SYS BFM DEBUG", $sformatf("In trigger function pause until %0d , cmd_req %0d ", m_pause_snoops_until_num_cmdreqs_vcs, cmdreq_count), UVM_LOW)
   end
   `endif //`ifdef VCS

   // Only adding addresses to addr_history for read type requests where the cache will end up with the line
   if ((m_cmd_trans.smi_msg_type == eCmdRdCln) || 
       (m_cmd_trans.smi_msg_type == eCmdRdNShD) || 
       (m_cmd_trans.smi_msg_type == eCmdRdVld) || 
       (m_cmd_trans.smi_msg_type == eCmdRdUnq) || 
       (m_cmd_trans.smi_msg_type == eCmdClnUnq) || 
       (m_cmd_trans.smi_msg_type == eCmdMkUnq)
       ) begin
      smi_addr_security_t   m_tmp[$];
      m_addr_history.push_back({
       <% if (obj.wSecurityAttribute > 0) { %>                                             
                m_cmd_trans.smi_ns,
       <% } %>                                                
                m_cmd_trans.smi_addr[WSMIADDR-1:0]});
      m_tmp = m_addr_history.unique;
      m_addr_history = m_tmp;
      ->e_addr_history;
   end
   if (m_cmd_trans.smi_msg_type == eCmdDvmMsg) begin
      isDVM = 1;
   end
   if (!isDVM) begin 
      processing_cmdreq_addr_q.push_back({
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        m_cmd_trans.smi_ns,
                    <% } %>                                                
                m_cmd_trans.smi_addr[WSMIADDR-1:0]});

<% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
    if(aiu_scb_en) begin
        int              m_tmp_q[$];
        smi_addr_security_t cmd_addr;
        ace_command_types_enum_t ace_cmdtype;
        cmd_addr = {
            <% if (obj.wSecurityAttribute > 0) { %>
                m_cmd_trans.smi_ns,
                <% } %>
                m_cmd_trans.smi_addr[WSMIADDR-1:0]};
        m_tmp_q = {};
        m_tmp_q = m_ncbu_cache_handle.ace_cmd_addr_q.find_first_index with ( item.m_addr == cmd_addr);
        ace_cmdtype = m_ncbu_cache_handle.ace_cmd_addr_q[m_tmp_q[0]].m_cmdtype;
        if(m_ncbu_cache_handle.ace_cmd_addr_q[m_tmp_q[0]].m_axdomain inside {INNRSHRBL, OUTRSHRBL}) begin
            m_processing_cmdreq_addr_q.push_back({
                                <% if (obj.wSecurityAttribute > 0) { %>
                                m_cmd_trans.smi_ns,
                                <% } %>
                                m_cmd_trans.smi_addr[WSMIADDR-1:0]});
        end
    end
<% } else { %>
      m_processing_cmdreq_addr_q.push_back({
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        m_cmd_trans.smi_ns,
                    <% } %>                                                
                m_cmd_trans.smi_addr[WSMIADDR-1:0]});
<% } %>
    
 //     `uvm_info("SYS BFM DEBUG", $psprintf("tsk:process_cmd_req adding to processingq size:%0d m_cmd_trans:%0s", processing_cmdreq_addr_q.size(), m_cmd_trans.convert2string), UVM_LOW)
      $cast(cmd_type, m_cmd_trans.smi_msg_type);
      giveLegalSTRreqResultForCmd(cmd_type, coher_result);
      if ((m_cmd_trans.smi_msg_type == eCmdRdNITC)       ||
          (m_cmd_trans.smi_msg_type == eCmdRdCln)        ||
          (m_cmd_trans.smi_msg_type == eCmdRdVld)        ||
          (m_cmd_trans.smi_msg_type == eCmdRdUnq)        ||
          (m_cmd_trans.smi_msg_type == eCmdRdNShD)       ||
          (m_cmd_trans.smi_msg_type == eCmdRdNC)         ||
          (m_cmd_trans.smi_msg_type == eCmdRdNITCMkInv)  ||
          (m_cmd_trans.smi_msg_type == eCmdRdNITCClnInv) ||
          (m_cmd_trans.smi_msg_type == eCmdRdAtm)        ||
          (m_cmd_trans.smi_msg_type == eCmdSwAtm)        ||
          (m_cmd_trans.smi_msg_type == eCmdCompAtm)
          ) begin
         foreach (coher_result[i]) begin
            coher_result[i].ST = 1;
         end
      end
      else begin
         foreach (coher_result[i]) begin
            coher_result[i].ST = 0;
         end
      end
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" ||
       obj.fnNativeInterface == "CHI-A" ||
       obj.fnNativeInterface == "CHI-B" ||
       obj.fnNativeInterface == "CHI-E" ||
       (obj.useCache)) { %> 
      start_state = SysBfmIX;
      if (state_list.exists({
       <% if (obj.wSecurityAttribute > 0) { %>                                             
		m_cmd_trans.smi_ns,
       <% } %>                                                
      m_cmd_trans.smi_addr[WSMIADDR-1:SYS_wSysCacheline]})) begin
      start_state = state_list[{
       <% if (obj.wSecurityAttribute > 0) { %>                                             
            m_cmd_trans.smi_ns,
       <% } %>                                                
      m_cmd_trans.smi_addr[WSMIADDR-1:SYS_wSysCacheline]}];
     end
     coher_result = coher_result.unique();
     rand_index = $urandom_range(0, coher_result.size()-1);
     coher_result_final = coher_result[rand_index];
<% } else { %>    
     coher_result = coher_result.unique();
     rand_index = $urandom_range(0, coher_result.size()-1);
     coher_result_final = coher_result[rand_index];
<% } %>
   end
   if (!isDVM) begin
<%  if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
      m_tmp_addr = {
                    <% if (obj.wSecurityAttribute > 0) { %>
                        m_cmd_trans.smi_ns,
                    <% } %>
                m_cmd_trans.smi_addr[WSMIADDR-1:0]};

      m_tmp_addr1 = {
                    <% if (obj.wSecurityAttribute > 0) { %>
                        m_cmd_trans.smi_ns,
                    <% } %>
                m_cmd_trans.smi_addr[WSMIADDR-1:SYS_wSysCacheline]};

       
      //pending CL state in Str_state_list
      foreach(str_state_list[i]) begin
         if(str_state_list[i].m_addr[WSMIADDR:SYS_wSysCacheline]  == m_tmp_addr1) begin
              start_state = str_state_list[i].m_cache_state;
          end
      end
      //`uvm_info("SYS BFM DEBUG", $sformatf("Reached here 5 for address: 0x%0h to get ending_state for command: %p, start_state: %p", m_cmd_trans.smi_addr, eMsgCMD'(m_cmd_trans.smi_msg_type), start_state), UVM_HIGH)
      getEndStateForACE(eMsgCMD' (m_cmd_trans.smi_msg_type), m_tmp_addr, m_cmd_trans.smi_mpf1_awunique, start_state, ending_state);
 <% } else { %>
      getEndStateFromStrReq(eMsgCMD' (m_cmd_trans.smi_msg_type), coher_result_final, ending_state);
      //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:process_cmd_req finished getting endStateFromStrReq m_cmd_trans:%0s ending_state:%0p", m_cmd_trans.convert2string, ending_state), UVM_LOW)
<% } %>

    //Dont look here for cacheline state changes. Look at state change in state_list when STRrsp is received.
  // `uvm_info("SYS BFM", $sformatf("Changing cache state in str_state_list in process_cmd_req: Addr: 0x%0x, security: 0x%0x, cmd_type: %p, start_state: %p, end_state: %p",m_cmd_trans.smi_addr,
  //     <% if(obj.wSecurityAttribute > 0) { %>
  //      m_cmd_trans.smi_ns,
  //     <% } else { %>
  //         0,
  //     <% } %>
  //      eMsgCMD'(m_cmd_trans.smi_msg_type), start_state, ending_state), UVM_LOW)

   end
   if (isDVM) begin
      coher_result_final = coher_result_dvm;
   end
   create_str_req(m_tmp_str_item, coher_result_final, m_cmd_trans);
  //  `uvm_info("SYS BFM DEBUG", $psprintf("tsk:process_cmd_req after create_str_req m_cmd_trans:%0s \n******\n strreq:%0s", m_cmd_trans.convert2string, m_tmp_str_item.m_seq_item.convert2string()), UVM_LOW)
   
    //If STRreq.CMStatus reports an Error, there is no commit to snoop-filter/directory.
    if (m_tmp_str_item.m_seq_item.smi_cmstatus[7:6] != 0) begin
        ending_state = start_state; 
    end

    //Dont look here for cacheline state changes. Look at state change in state_list when STRrsp is received.
    `uvm_info("SYS BFM", $sformatf("Changing cache state in str_state_list in process_cmd_req: Addr: 0x%0x, security: 0x%0x, cmd_type: %p, start_state: %p, end_state: %p",m_cmd_trans.smi_addr,
       <% if(obj.wSecurityAttribute > 0) { %>
        m_cmd_trans.smi_ns,
       <% } else { %>
           0,
       <% } %>
        eMsgCMD'(m_cmd_trans.smi_msg_type), start_state, ending_state), UVM_LOW)

   <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {  %>
      //`uvm_info("SYS BFM DEBUG", $sformatf("Reached here 6 for address: 0x%0h to adjust ending_state for command: %p, start_state: %p. ES:%0b, cmstatus_exok=%b, smi_targ_ncore_unit_id=0x%x, inside =%b, DCE_Funit_Id=%p, inside = %b", m_cmd_trans.smi_addr, eMsgCMD'(m_cmd_trans.smi_msg_type), start_state, m_cmd_trans.smi_es, m_tmp_str_item.m_seq_item.smi_cmstatus_exok, m_cmd_trans.smi_targ_ncore_unit_id, (m_cmd_trans.smi_targ_ncore_unit_id inside {DCE_Funit_Id}),  DCE_Funit_Id, (m_cmd_trans.smi_targ_ncore_unit_id inside {DCE_Funit_Id})), UVM_HIGH)
   if( (m_cmd_trans.smi_es == 1) &&
       (m_tmp_str_item.m_seq_item.smi_cmstatus_exok == 0) &&
       (m_cmd_trans.smi_targ_ncore_unit_id inside {DCE_Funit_Id})) begin
        ending_state = start_state;
        str_state_list[m_tmp_str_item.m_seq_item.smi_unq_identifier].m_cache_state = ending_state;
        `uvm_info("SYS BFM DEBUG", $sformatf("Changing cache state back(exclusive access failed): Addr: 0x%0x, security: 0x%0x, cmd_type: %p, start_state: %p, end_state: %p",m_cmd_trans.smi_addr,
            <% if(obj.wSecurityAttribute > 0) { %>
            m_cmd_trans.smi_ns,
            <% } else { %>
            0,
            <% } %>
            eMsgCMD'(m_cmd_trans.smi_msg_type), start_state, ending_state), UVM_DEBUG)
   end
   <% } %>
   <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>

       //CONC-7711 DCE will always send back STRreq.State.Unique on CLNUNQ irrespective of exclusive/not pass/fail 
       if(m_cmd_trans.smi_msg_type == eCmdClnUnq && m_cmd_trans.smi_targ_ncore_unit_id inside {DCE_Funit_Id})
    		m_tmp_str_item.m_seq_item.smi_cmstatus_state = State_Unique;

       if( m_cmd_trans.smi_msg_type == eCmdMkUnq  ||
           ((m_cmd_trans.smi_msg_type == eCmdClnVld ||
             m_cmd_trans.smi_msg_type == eCmdClnShdPer ||
             m_cmd_trans.smi_msg_type == eCmdClnInv    ||
             m_cmd_trans.smi_msg_type == eCmdMkInv) &&
            m_cmd_trans.smi_targ_ncore_unit_id inside {DCE_Funit_Id})
         ) begin
            case(ending_state) 
                 SysBfmIX:
                     m_tmp_str_item.m_seq_item.smi_cmstatus_state = State_Invalid;
                 SysBfmUC,SysBfmUD:
                     m_tmp_str_item.m_seq_item.smi_cmstatus_state = State_Unique;
                 SysBfmSCOwner, SysBfmSD:
                     m_tmp_str_item.m_seq_item.smi_cmstatus_state = State_Owner;
                 SysBfmSC:
                     m_tmp_str_item.m_seq_item.smi_cmstatus_state = State_Sharer;
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported ending state:%s for setting StrReq cmstatus State field", ending_state.name));
                end
            endcase
        end
   <% } %>
  // `uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req CMDreq:%0s *** STRreq:%0s", m_cmd_trans.convert2string(), m_tmp_str_item.m_seq_item.convert2string()), UVM_LOW);
   m_req.m_smi_unq_id = m_cmd_trans.smi_unq_identifier;
   if (isDVM) begin
      m_req.m_addr         = '0;
   end
   else begin
      m_req.m_addr         = {
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        m_cmd_trans.smi_ns,
                    <% } %>                                                
                m_cmd_trans.smi_addr[WSMIADDR-1:0]};
   end
   //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req before m_req_in_process push"), UVM_LOW);
   m_req_in_process.push_back(m_req);
   if (isDVM) begin
      str_state_list[m_tmp_str_item.m_seq_item.smi_unq_identifier].m_addr[WSMIADDR-1+<%=obj.wSecurityAttribute%>:0] = {
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        m_cmd_trans.smi_ns,
                    <% } %>                                                
                m_cmd_trans.smi_addr[WSMIADDR-1:0]};
      str_state_list[m_tmp_str_item.m_seq_item.smi_unq_identifier].m_cache_state = SysBfmIX;
      str_state_list[m_tmp_str_item.m_seq_item.smi_unq_identifier].m_isDVM       = 1;
      str_state_list[m_tmp_str_item.m_seq_item.smi_unq_identifier].m_isCoherent  = 0;
   end
   else begin
      if((m_cmd_trans.smi_msg_type === eCmdWrNCFull) || 
	 (m_cmd_trans.smi_msg_type === eCmdWrNCPtl)  ||
	 //(m_cmd_trans.smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm} && !m_cmd_trans.smi_ch)) begin // && m_cmd_trans.smi_targ_ncore_unit_id inside {DMI_Funit_Id})) begin
	 (m_cmd_trans.smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm} && m_cmd_trans.smi_targ_ncore_unit_id inside {DMI_Funit_Id})) begin // && m_cmd_trans.smi_targ_ncore_unit_id inside {DMI_Funit_Id})) begin
	 str_state_list[m_tmp_str_item.m_seq_item.smi_unq_identifier].m_isCoherent = 0;
      end
      else begin
	 str_state_list[m_tmp_str_item.m_seq_item.smi_unq_identifier].m_isCoherent = 1;
      end
      
      str_state_list[m_tmp_str_item.m_seq_item.smi_unq_identifier].m_cache_state = ending_state;
      str_state_list[m_tmp_str_item.m_seq_item.smi_unq_identifier].m_addr        = {
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        m_cmd_trans.smi_ns,
                    <% } %>                                                
                m_cmd_trans.smi_addr[WSMIADDR-1:0]};
      str_state_list[m_tmp_str_item.m_seq_item.smi_unq_identifier].m_isDVM       = 0;
      //TODO:replace this is whole condition with is_coherent_addr call to
      //addrMgrConst
      if (!(m_cmd_trans.smi_msg_type inside {eCmdWrNCPtl, eCmdWrNCFull, eCmdRdNC}) &&
          !(m_cmd_trans.smi_targ_ncore_unit_id inside {DII_Funit_Id})) begin
         if (m_smi_str_pending_addr_h.exists(m_tmp_str_item.m_seq_item.smi_unq_identifier)) begin
            //`uvm_error("SYS BFM SEQ", $sformatf("TB Error: Found an entry in smi_str_pending_addr for unique identifier 0x%0x (addr:0x%0x) while attempting to write value 0x%0x", m_tmp_str_item.m_seq_item.smi_unq_identifier, m_smi_str_pending_addr_h[m_tmp_str_item.m_seq_item.smi_unq_identifier], m_cmd_trans.smi_addr));
         end

	//`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req before s_snp.get"), UVM_LOW);
	if(!$test$plusargs("wrong_sysrsp_target_id")) s_snp.get();
	//`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req after s_snp.get"), UVM_LOW);
         m_smi_str_pending_addr_h[m_tmp_str_item.m_seq_item.smi_unq_identifier] = {
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            m_cmd_trans.smi_ns,
                        <% } %>                                                
                    m_cmd_trans.smi_addr[WSMIADDR-1:0]};
	 if(!$test$plusargs("wrong_sysrsp_target_id")) s_snp.put();
      end
      <% if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
          else begin
         if(m_cmd_trans.smi_msg_type == eCmdWrNCPtl ||
            m_cmd_trans.smi_msg_type == eCmdWrNCFull) begin
            if(aiu_scb_en) begin
               int              m_tmp_q[$];
               smi_addr_security_t cmd_addr;
               ace_command_types_enum_t ace_cmdtype;
               cmd_addr = {
                       <% if (obj.wSecurityAttribute > 0) { %>
                          m_cmd_trans.smi_ns,
                       <% } %>
                           m_cmd_trans.smi_addr[WSMIADDR-1:0]};
               m_tmp_q = {};
               m_tmp_q = m_ncbu_cache_handle.ace_cmd_addr_q.find_first_index with ( item.m_addr == cmd_addr);
               ace_cmdtype = m_ncbu_cache_handle.ace_cmd_addr_q[m_tmp_q[0]].m_cmdtype;
               if(ace_cmdtype inside {WRBK, WRCLN, WREVCT}) begin
                    m_smi_str_pending_mem_upd_addr_h[m_tmp_str_item.m_seq_item.smi_unq_identifier] = {
                                <% if (obj.wSecurityAttribute > 0) { %>
                                    m_cmd_trans.smi_ns,
                                <% } %>
                            m_cmd_trans.smi_addr[WSMIADDR-1:0]};
               end
            end
          end
      end
      <% } %>
    
      //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req looking for address in processing_cmdreq_addr_q"), UVM_LOW);
      index = {};
      index = processing_cmdreq_addr_q.find_first_index with (item[WSMIADDR-1:0] == m_cmd_trans.smi_addr[WSMIADDR-1:0]
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        && item[$size(item) - 1:$size(item) - <%=obj.wSecurityAttribute%>] == m_cmd_trans.smi_ns    
                    <% } %>                                                
                );
      if (index.size == 0) begin
         `uvm_error("SYS BFM SEQ", $sformatf("TB Error: Could not find an entry in processing_cmdreq_addr_q for address 0x%0x", m_cmd_trans.smi_addr));
      end
      else begin
         processing_cmdreq_addr_q.delete(index[0]);
         if (m_processing_cmdreq_addr_q.size) 
         m_processing_cmdreq_addr_q.delete(index[0]);
      end
      //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req deleted address from processing_cmdreq_addr_q"), UVM_LOW);
   end // else: !if(isDVM)
   
   //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req coh_result_final_ST:%0d targ_ncore_unit_id:0x%0h", coher_result_final.ST, m_cmd_trans.smi_targ_ncore_unit_id), UVM_LOW);
   m_cmd_trans.unpack_smi_seq_item();
   //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req coh_result_final_ST:%0d targ_ncore_unit_id:0x%0h DCE_FUNIT_ID:%0p DMI_FUNIT_ID:%0p", coher_result_final.ST, m_cmd_trans.smi_targ_ncore_unit_id, DCE_Funit_Id, DMI_Funit_Id), UVM_LOW);


   if (coher_result_final.ST > 0 && !isDVM && !m_tmp_str_item.m_seq_item.smi_cmstatus_err) begin
      if ((m_cmd_trans.smi_msg_type inside {eCmdRdAtm, eCmdSwAtm, eCmdCompAtm}) && 
          (addrMgrConst::get_unit_type(m_cmd_trans.smi_targ_ncore_unit_id) == addrMgrConst::DCE)) begin
            //DTRreq will not be generated for Atomic txns going to DCE
            //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req DTRreq is not created"), UVM_LOW);
      end else begin
            //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req DTRreq is created"), UVM_LOW);
         create_dtr_req(m_tmp_dtr_item, ending_state, m_cmd_trans);
        //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req DTRreq:%0s", m_tmp_dtr_item.convert2string()), UVM_LOW);
         <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
         if( (m_cmd_trans.smi_es == 1) &&
             (m_tmp_dtr_item.smi_cmstatus_exok == 0) &&
             (m_cmd_trans.smi_targ_ncore_unit_id inside {DMI_Funit_Id})) begin
            ending_state = start_state;
            str_state_list[m_tmp_str_item.m_seq_item.smi_unq_identifier].m_cache_state = ending_state;
           // `uvm_info("SYS BFM DEBUG", $sformatf("Changing cache state back(exclusive access failed): Addr: 0x%0x, security: 0x%0x, cmd_type: %p, start_state: %p, end_state: %p",m_cmd_trans.smi_addr,
           // <% if(obj.wSecurityAttribute > 0) { %>
           // m_cmd_trans.smi_ns,
           // <% } else { %>
           // 0,
           // <% } %>
           // eMsgCMD'(m_cmd_trans.smi_msg_type), start_state, ending_state), UVM_HIGH)
        end
         <% } %>
      end
   end


 //  `uvm_info("SYS BFM DEBUG", $sformatf("tsk:process_cmd_req CMDreq:%0s \n STRreq:%0s \nabout to push into m_smi_str_req queue", m_cmd_trans.convert2string(), m_tmp_str_item.m_seq_item.convert2string()), UVM_LOW);

   fork 
      begin : create_str_pkt
         if(m_cmd_trans.smi_msg_type == eCmdDvmMsg) begin
	    dvm_msg_ids[m_tmp_str_item.m_seq_item.smi_rbid] = m_cmd_trans.smi_msg_id;
	 end
	 
         m_smi_str_req_q.push_back(m_tmp_str_item);
         ->e_smi_str_req_q;
//	 uvm_report_info("DEBUG",$sformatf("create_str_pkt thread"),UVM_LOW);
      end : create_str_pkt
      begin : create_dtr_pkt

         bit localIsDVM = isDVM;
         if (coher_result_final.ST > 0 && !localIsDVM) begin
            if (m_cmd_trans.smi_msg_type inside {eCmdRdAtm, eCmdSwAtm, eCmdCompAtm}) begin: _atm_
                if (addrMgrConst::get_unit_type(m_cmd_trans.smi_targ_ncore_unit_id) == addrMgrConst::DMI) begin
                    if (m_smi_dtr_req_for_atomics.exists(m_tmp_str_item.m_seq_item.smi_rbid)) begin
                        `uvm_error("SYS BFM SEQ", $sformatf("TB Error: Multiple RBID match for DTR atomics for rbid 0x%0x. Might need to add more debug prints here", m_tmp_str_item.m_seq_item.smi_rbid))
                    end else begin
                        m_smi_dtr_req_for_atomics[m_tmp_str_item.m_seq_item.smi_rbid] = m_tmp_dtr_item;
                    end
                end
            end: _atm_
            else begin: _non_atm_
	        if(m_tmp_str_item.m_seq_item.smi_cmstatus_err == 0) begin
                    smi_seq_item_addr_t tmp_dtr_req;
                    tmp_dtr_req.m_seq_item = m_tmp_dtr_item;
                    $cast(tmp_dtr_req.cmd_type, m_cmd_trans.smi_msg_type);
                    tmp_dtr_req.m_addr = {
                                <% if (obj.wSecurityAttribute > 0) { %>
                                    m_cmd_trans.smi_ns,
                                <% } %>
                                    m_cmd_trans.smi_addr[WSMIADDR-1:0]};
		    m_smi_dtr_req_q.push_back(tmp_dtr_req);
		    ->e_smi_dtr_req_q;
	        end //if(m_tmp_str_item.m_seq_item.smi_cmstatus_err == 0)
            end: _non_atm_
        end//if (coher_result_final.ST > 0 && !localIsDVM) 
//	s_addr.put(); //DCDEBUG	 

//	 uvm_report_info("DEBUG",$sformatf("create_dtr_pkt thread"),UVM_LOW);
      end : create_dtr_pkt
   join

   if(isCoherent) begin 
 //  uvm_report_info("DEBUG", $sformatf("s_addr Released by process_cmd_req coherent"),UVM_LOW);
   s_addr.put();
 end else begin
  // uvm_report_info("DEBUG", $sformatf("s_addr Released by process_cmd_req non-coherent"),UVM_LOW);
     s_nc_addr.put();
    end

 endtask:process_cmd_req
   
task process_nc_cmd_req();
    forever begin
        if (m_smi_nc_cmd_req_q.size() == 0) begin
            //`uvm_info("SYS BFM DEBUG", $sformatf("Reached here start cmd_req = 0"), UVM_HIGH)
            @e_smi_nc_cmd_req_q;
            //`uvm_info("SYS BFM DEBUG", $sformatf("Reached here end cmd_req = 0"), UVM_HIGH)
        end
        else begin
//	   process_cmd_req(0,m_smi_nc_cmd_req_q,m_processing_nc_cmdreq_addr_q);
	   process_cmd_req(0);
	end
    end
endtask : process_nc_cmd_req

task process_c_cmd_req();
    forever begin
   //     uvm_report_info(`LABEL,$sformatf("process_c_cmd_req cmdreq_size:%0d dvmreqq_size:%0d",m_smi_cmd_req_q.size(), m_smi_dvm_cmd_req_q.size()),UVM_LOW);
        if ((m_smi_cmd_req_q.size() == 0) && (m_smi_dvm_cmd_req_q.size() == 0)) begin
    //        `uvm_info("SYS BFM DEBUG", $sformatf("waiting for e_smi_cmd_req_q event"), UVM_LOW)
            @e_smi_cmd_req_q;
     //       `uvm_info("SYS BFM DEBUG", $sformatf("done waiting for e_smi_cmd_req_q event"), UVM_LOW)
        end
        else begin
      //      `uvm_info("SYS BFM DEBUG", $sformatf("call process cmd req cmdreqq.size:%0d dvmcmdreqq.size:%0d", m_smi_cmd_req_q.size(), m_smi_dvm_cmd_req_q.size()), UVM_LOW)
//	   process_cmd_req(1,m_smi_cmd_req_q,m_processing_cmdreq_addr_q);
	   process_cmd_req(1);
	end
    end
endtask : process_c_cmd_req

task send_str_req_delay();
    delay_str_req = 0;
    if (!dis_delay_str_req) begin
        forever begin
            #(delay_str_req_val * 1ns);
            delay_str_req = ~delay_str_req;
            if (gen_more_streaming_traffic) begin
                delay_str_req_val = $urandom_range(100,1000);
            end
            else begin
                delay_str_req_val = $urandom_range(1,1000);
            end
        end
    end
endtask : send_str_req_delay

task send_str_req();
    forever begin
        if (delay_str_req) begin
            wait(delay_str_req == 0);
        end
        if (m_smi_str_req_q.size == 0) begin
           @e_smi_str_req_q;
        end
        else begin
            smi_seq_item_addr_t m_tmp_seq_item;
            smi_seq_item_addr_t m_tmp2_seq_item;
            int                 m_tmp_q[$];
            int                 index;
            time                t_index;
            bit                 flag = 0;

            do begin
                m_smi_str_req_q.shuffle();
                m_tmp_seq_item = m_smi_str_req_q[0];
                if((isAddrInSmiSnpReqOutstandingArray(m_smi_str_req_q[0].m_addr) && (m_smi_str_req_q[0].m_seq_item.smi_src_ncore_unit_id inside {DCE_Funit_Id})) || (isAddrInSmiStrReqOutstandingArray(m_smi_str_req_q[0].m_addr) && !(m_smi_str_req_q[0].cmd_type inside {eCmdWrAtm, eCmdRdAtm,eCmdSwAtm,eCmdCompAtm}))) begin
                    flag = 0;// Flag that a SnpReq found for which noStrRsp is pending
                    foreach(m_smi_str_req_q[i]) begin
                        flag = !((isAddrInSmiSnpReqOutstandingArray(m_smi_str_req_q[i].m_addr) && (m_smi_str_req_q[i].m_seq_item.smi_src_ncore_unit_id inside {DCE_Funit_Id})) || (isAddrInSmiStrReqOutstandingArray(m_smi_str_req_q[i].m_addr) && !(m_smi_str_req_q[i].cmd_type inside {eCmdWrAtm, eCmdRdAtm,eCmdSwAtm,eCmdCompAtm})));
                        if(flag)  begin // if a non pending txn found , use it, also move it to first place
                            m_tmp_seq_item = m_smi_str_req_q[i];
                            m_smi_str_req_q.delete(i);
                            m_smi_str_req_q.push_front(m_tmp_seq_item);
                            break;
                        end
                    end
                    // if no luck with getting StrReq than wait for either new str or wait for snpreq complete
                    if(!flag) begin
                        fork
                        @e_smi_str_req_q;
                        @e_smi_rx_rsp_q;
                        @e_smi_rx_rsp_dvm_cmd_q;
                        @e_smi_str_pending_addr_h_freeup;
                        join_any
                    end
                end else begin
                    flag = 1;
                end
            end while(!flag);

            m_tmp_q = {};
            m_tmp_q = m_smi_str_req_q.find_index with (item.m_addr[$size(item.m_addr)-1:SYS_wSysCacheline] == m_tmp_seq_item.m_addr[$size(item.m_addr)-1:SYS_wSysCacheline]);
            if (m_tmp_q.size() == 0) begin
            `uvm_error("SYS BFM SEQ", $sformatf("TB Error: Not possible to reach here for address 0x%0x", m_tmp_seq_item.m_addr)); 
            end
            else if (m_tmp_q.size() > 1) begin
               index = m_tmp_q[0];
               t_index = m_smi_str_req_q[m_tmp_q[0]].t_smi_ndp_ready;
               for (int i = 1; i < m_tmp_q.size(); i++) begin
                  if (t_index > m_smi_str_req_q[m_tmp_q[i]].t_smi_ndp_ready) begin
                     t_index = m_smi_str_req_q[m_tmp_q[i]].t_smi_ndp_ready;
                     index   = m_tmp_q[i];
                  end
               end
	    end
            else begin
               index = m_tmp_q[0];
            end
               m_tmp_seq_item = m_smi_str_req_q[index];
               m_smi_str_req_q.delete(index);
               `ifdef VCS
                -> e_smi_outstandingq_del;
                strreq_count++;
               `endif
               `uvm_info("SYS BFM DEBUG", $sformatf("driving STRReq snarf = %0d %s",m_tmp_seq_item.m_seq_item.smi_cmstatus_snarf,m_tmp_seq_item.m_seq_item.convert2string()), UVM_HIGH);
               // Copy for Err inj
               m_tmp2_seq_item = m_tmp_seq_item;
               m_tmp2_seq_item.m_seq_item =  smi_seq_item::type_id::create("m_seq_item");
               m_tmp2_seq_item.m_seq_item.copy(m_tmp_seq_item.m_seq_item);
               // Pushing the request onto mst_req_q to wait for response
               m_smi_tx_req_q.push_back(m_tmp2_seq_item.m_seq_item);
               m_strreq_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
               m_strreq_tx.m_seq_item = m_tmp_seq_item.m_seq_item;
               m_strreq_tx.return_response(m_smi_seqr_tx_hash["str_req_"]);
               ->e_smi_tx_req_q;
               if($test$plusargs("resend_correct_target_id")) resend_correct_target_id(m_strreq_tx, "wrong_strreq_target_id");
	    end
	end
endtask : send_str_req

task send_dtr_req_delay();
    delay_dtr_req = 0;
    if (!dis_delay_dtr_req) begin
        forever begin
            #(delay_dtr_req_val * 1ns);
            delay_dtr_req = ~delay_dtr_req;
            if (gen_more_streaming_traffic) begin
                delay_dtr_req_val = $urandom_range(100,1000);
            end
            else begin
                delay_dtr_req_val = $urandom_range(1,1000);
            end
        end
    end
endtask: send_dtr_req_delay

task send_dtr_req;
    forever begin
        if (delay_dtr_req) begin
            wait(delay_dtr_req == 0);
        end
        if (m_smi_dtr_req_q.size == 0) begin
            @e_smi_dtr_req_q;
        end
        else begin
            smi_seq_item_addr_t tmp_dtr_req;
            smi_seq_item m_tmp_seq_item;
            smi_seq_item m_tmp2_seq_item;
            bit flag = 0;

            do begin
                m_smi_dtr_req_q.shuffle();
                foreach(m_smi_dtr_req_q[idx]) begin
                    if(m_smi_dtr_req_q[idx].cmd_type == eCmdWrAtm ||
                       m_smi_dtr_req_q[idx].cmd_type == eCmdWrStshFull) begin
                        flag = 1;
                    end else begin
                        //not send DtrReq if there is oustanding SnpReq
                        if(!isAddrInSmiSnpReqOutstandingArray(m_smi_dtr_req_q[idx].m_addr)) begin
                            flag = 1;
                        end
                    end
                    if(flag) begin
                        tmp_dtr_req = m_smi_dtr_req_q[idx];
                        m_smi_dtr_req_q.delete(idx);
                        m_smi_dtr_req_q.push_front(tmp_dtr_req);
                        `ifdef VCS
                        -> e_smi_outstandingq_del;
                        dtrreq_count++;
                        `endif
                        break;
                    end
                end
                if(!flag) begin
                    fork
                        @e_smi_dtr_req_q;
                        @e_smi_rx_rsp_q;
                    join_any
                end
            end while(!flag);
            m_tmp_seq_item = m_smi_dtr_req_q[0].m_seq_item;
            m_smi_dtr_req_q.delete(0);
            `ifdef VCS
            -> e_smi_outstandingq_del;
            `endif
            m_dtrreq_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
            m_dtrreq_tx.m_seq_item = m_tmp_seq_item;
            // Copy for Err inj
            m_tmp2_seq_item = smi_seq_item::type_id::create("m_seq_item");
            m_tmp2_seq_item.copy(m_tmp_seq_item);
			//`uvm_info("SYS BFM DEBUG", $sformatf("fn:send_dtr_req %s", m_dtrreq_tx.m_seq_item.convert2string()), UVM_LOW);
            m_dtrreq_tx.return_response(m_smi_seqr_tx_hash["dtr_req_rx_"]);
            // Pushing the request onto mst_req_q to wait for response
            m_smi_tx_req_q.push_back(m_tmp2_seq_item);
            //if (m_smi_rx_req_q.size() > <%=obj.nPendingTransactions%> + 1) begin
            //    `uvm_error("SYS BFM SEQ", $sformatf("There are more than nPendingTransactions sent on AIU's SFI slave interface without a SFI response (nPendingTrans: %0d Outstanding requests: %0d", <%=obj.nPendingTransactions%>, m_smi_rx_req_q.size()));
            //end
            ->e_smi_tx_req_q;
            if($test$plusargs("resend_correct_target_id")) resend_correct_target_id(m_dtrreq_tx, "wrong_dtrreq_target_id");
        end
    end
endtask : send_dtr_req

task send_snp_req;
    bit isFirstDVMSnoopSent;
    smi_unq_identifier_bit_t m_first_DVM_unq_id;
    smi_unq_identifier_bit_t m_first_DVM_dvmop_id;
    smi_msg_id_t             m_first_DVM_msg_id;
        bit                 isOwner  = 0;
        bit                 isSharer = 0;
    eMsgSNP     snp_type;	

    forever begin
        if (m_smi_snp_req_q.size == 0) begin
            @e_smi_snp_req_q;
        end
        else begin
            int count_dvm_snoops;
            int count_snoops;
            smi_seq_item m_tmp_seq_item;
            smi_seq_item m_tmp2_seq_item;
            bit          flag;
            int          m_index_to_delete;
            int          dvm_snp_rsp;
            do begin
                bit is_dvm_snp_ok = 1;
                count_dvm_snoops = 0;
                count_snoops     = 0;
                dvm_snp_rsp      = 0;

                foreach(m_smi_tx_req_q[i]) begin
                    if (m_smi_tx_req_q[i].isSnpMsg()) begin
                        if (m_smi_tx_req_q[i].smi_msg_type == SNP_DVM_MSG) begin
                            count_dvm_snoops++;
                        end
                        else begin
                            count_snoops++;
                        end
                    end
                end

                if((count_snoops + count_dvm_snoops*2 + isFirstDVMSnoopSent) >= <%=n_snoops%> ) begin
	                if($test$plusargs("snp_srsp_delay") && stt_fill_count < max_stt_fill_count) begin
                        ev_max_snp_req_sent.trigger();
                        `uvm_info("SYS BFM DEBUG",$sformatf("tsk:send_snp_req waiting for stt to clear stt_fill_count: %0d, max_stt_fill_count: %0d, m_smi_tx_req_q size: %0d", stt_fill_count, max_stt_fill_count, m_smi_tx_req_q.size()),UVM_HIGH);
                        while(count_snoops != 0) begin
                            @e_smi_snp_req_free;
                            count_snoops = 0;
                            count_dvm_snoops = 0;
                            foreach(m_smi_tx_req_q[i]) begin
                                if (m_smi_tx_req_q[i].isSnpMsg()) begin
                                    if (m_smi_tx_req_q[i].smi_msg_type == SNP_DVM_MSG) begin
                                        count_dvm_snoops++;
                                    end else begin
                                        count_snoops++;
                                    end
                                end
                            end
                        end
                        #10ns;
                        //wait(m_smi_tx_req_q.size() == 0);
	                    ev_fill_stt.trigger();
                        stt_fill_count = stt_fill_count + 1;
	                    `uvm_info("SYS BFM DEBUG",$sformatf("tsk:send_snp_req done waiting for stt to clear stt_fill_count: %0d, max_stt_fill_count: %0d, m_smi_tx_req_q size: %0d", stt_fill_count, max_stt_fill_count, m_smi_tx_req_q.size()),UVM_HIGH);
	                end else begin                
                        @e_smi_snp_req_free;
                        continue;
                    end
                end

                if(count_dvm_snoops*2 + isFirstDVMSnoopSent >= <%=max_dvms%>) begin
                   is_dvm_snp_ok = 0;
                end
                //m_smi_snp_req_q.shuffle();// CONC-10938
                m_tmp_seq_item = m_smi_snp_req_q[0];

                if(m_tmp_seq_item.smi_msg_type == SNP_DVM_MSG && is_dvm_snp_ok) begin
                    flag = 1;
                end else begin
                    // CONC-7087/6892
                    //check if the address is snpreq has associated StrRsp pending, then wait for it
                    flag = 0;// Flag that a SnpReq found for which noStrRsp is pending
                    foreach(m_smi_snp_req_q[i]) begin
                        if(m_smi_snp_req_q[i].smi_msg_type == SNP_DVM_MSG) begin
                            flag = is_dvm_snp_ok;
                        end else begin
                            flag = !(isAddrInSmiStrReqOutstandingArray({ <%if(obj.wSecurityAttribute > 0){%>m_smi_snp_req_q[i].smi_ns,<%}%>  m_smi_snp_req_q[i].smi_addr[WSMIADDR-1:0]}) || isAddrInSmiSnpReqOutstandingArray({ <%if(obj.wSecurityAttribute > 0){%>m_smi_snp_req_q[i].smi_ns,<%}%>  m_smi_snp_req_q[i].smi_addr[WSMIADDR-1:0]}) || isAddrInStrReqArray({ <%if(obj.wSecurityAttribute > 0){%>m_smi_snp_req_q[i].smi_ns,<%}%>  m_smi_snp_req_q[i].smi_addr[WSMIADDR-1:0]}));
                        end
                        if(flag)  begin // if a non pending txn found , use it, also move it to first place
                            if(i != 0) begin
                                m_tmp_seq_item = m_smi_snp_req_q[i];
                                m_smi_snp_req_q.delete(i);
                                m_smi_snp_req_q.push_front(m_tmp_seq_item);
                            end
                            break;
                        end
                    end
                    // if no luck with getting SnpReq than wait for either new snp or wait for strreq complete
                    if(!flag) begin
                        fork
                        @e_smi_snp_req_q;
                        @e_smi_rx_rsp_q;
                        @e_smi_str_pending_addr_h_freeup;
                        begin
                            @e_smi_rx_rsp_dvm_cmd_q;
                            dvm_snp_rsp = 1;
                        end
                        join_any
                        if ((dvm_snp_rsp == 1) && (count_snoops == 0)) begin
                            break;
                        end
                    end
                end
            end while(!flag);
            if (m_tmp_seq_item.smi_msg_type != SNP_DVM_MSG) begin
                flag = !(isAddrInSmiStrReqOutstandingArray({ <%if(obj.wSecurityAttribute > 0){%>m_tmp_seq_item.smi_ns,<%}%>  m_tmp_seq_item.smi_addr[WSMIADDR-1:0]}) || isAddrInSmiSnpReqOutstandingArray({ <%if(obj.wSecurityAttribute > 0){%>m_tmp_seq_item.smi_ns,<%}%>  m_tmp_seq_item.smi_addr[WSMIADDR-1:0]}) || isAddrInStrReqArray({ <%if(obj.wSecurityAttribute > 0){%>m_tmp_seq_item.smi_ns,<%}%>  m_tmp_seq_item.smi_addr[WSMIADDR-1:0]}));
                if(!flag) continue;
            end
 flag = 0;
            // Want to make sure that if a SNP_DVM_MSG is chosen and its the first part of the 
            // of the snoop, its addr[3] = 0 
            if (m_tmp_seq_item.smi_msg_type == SNP_DVM_MSG && !isFirstDVMSnoopSent && m_tmp_seq_item.smi_addr[3] != 'b0) begin
                // Swapping the queue to move smi_addr[3] = 0 to be the first packet in m_smi_snp_req_q
                smi_seq_item m_tmp;
                int          m_tmp_q[$];
                m_tmp                       = m_tmp_seq_item;
                m_tmp_q                     = m_smi_snp_req_q.find_first_index with (item.smi_msg_type == SNP_DVM_MSG && item.smi_addr[3] == 'b0);
                m_smi_snp_req_q[0]          = m_smi_snp_req_q[m_tmp_q[0]];
                m_smi_snp_req_q[m_tmp_q[0]] = m_tmp;
                m_tmp_seq_item              = m_smi_snp_req_q[0];
            end
            flag                 = 0;
            //#Stimulus.IOAIU.SMISnpReqDVM
            if (m_tmp_seq_item.smi_msg_type == SNP_DVM_MSG) begin
                if (!isFirstDVMSnoopSent) begin
                    flag                = 1;
                    isFirstDVMSnoopSent = 1;
                    m_first_DVM_unq_id   = m_tmp_seq_item.smi_unq_identifier;
                    m_first_DVM_dvmop_id = m_tmp_seq_item.smi_mpf2_dvmop_id;
                    m_first_DVM_msg_id   = m_tmp_seq_item.smi_msg_id;
                end else begin
                    int m_tmp_q[$];
//                    m_tmp_q = m_smi_snp_req_q.find_index with (item.smi_unq_identifier == m_first_DVM_unq_id &&
//		    					   item.smi_mpf2_dvmop_id == m_first_DVM_dvmop_id);
                    m_tmp_q = m_smi_snp_req_q.find_index with (item.smi_unq_identifier == m_first_DVM_unq_id &&
		   					       item.smi_mpf2_dvmop_id == m_first_DVM_dvmop_id);
                    if (m_tmp_q.size !== 1) begin
                        foreach (m_smi_snp_req_q[i]) begin
                            `uvm_info("SYSTEM BFM", $sformatf("%p", m_smi_snp_req_q[i]), UVM_NONE)
                        end
                        `uvm_error("SYSTEM BFM", $sformatf("TB Error: Found 0 or more than 1 match for smi_unq_id 0x%0x index locator array %p outstanding array %p", m_first_DVM_unq_id, m_tmp_q, m_smi_snp_req_q));
                    end else begin
                        isFirstDVMSnoopSent = 0;
                        m_tmp_seq_item      = m_smi_snp_req_q[m_tmp_q[0]];
//		          m_tmp_seq_item.smi_mpf2_dvmop_id = m_first_DVM_dvmop_id;
//		          m_tmp_seq_item.smi_mpf3_dvmop_portion = 1;
//		          m_tmp_seq_item.smi_msg_id        = m_smi_snp_req_q[m_tmp_q[0]].smi_msg_id;
                        m_index_to_delete   = m_tmp_q[0];
                        flag                = 1;
                    end
                end
            end else begin
                flag = 1;
            end
            `uvm_info("SYSTEM BFM", $sformatf("In send SnpReq. count_snoops = %0d, count_dvm_snoops = %0d, isFirstDVMSnoopSent = %0d, snoop_outst = %0d", count_snoops, count_dvm_snoops, isFirstDVMSnoopSent, snoop_outst), UVM_DEBUG)

            if (m_tmp_seq_item.smi_msg_type == SNP_DVM_MSG && !isFirstDVMSnoopSent) begin
                   `uvm_info("SYS BFM DEBUG", $sformatf("Deleting the following seq item from index %d of smi_snp_req_q %p", m_index_to_delete, m_smi_snp_req_q[m_index_to_delete]), UVM_LOW)
                    m_smi_snp_req_q.delete(m_index_to_delete);
            end else begin
                `uvm_info("SYS BFM DEBUG", $sformatf("Deleting the following seq item from index 0 of smi_snp_req_q %p", m_smi_snp_req_q[0]), UVM_LOW)
                m_smi_snp_req_q.delete(0);
            end
            ->e_smi_snp_req_del_q;
            `ifdef VCS
            -> e_smi_outstandingq_del;
            `endif
            <% if((obj.Block =='chi_aiu') || (obj.Block =='io_aiu')) { %>
            //foreach(m_dce_dve_attach_st[key]) begin 
            //        `uvm_info("SYSTEM BFM DEBUG", $sformatf("tsk:send_snp_req SYS_RSP was sent m_dce_dve_attach_st key:0x%0h value:%0h", key, m_dce_dve_attach_st[key]), UVM_LOW);
            //end 

            if (m_dce_dve_attach_st.exists(m_tmp_seq_item.smi_src_ncore_unit_id) && m_dce_dve_attach_st[m_tmp_seq_item.smi_src_ncore_unit_id] == 1) begin
            <% } %>
            if (m_tmp_seq_item.smi_msg_type == SNP_DVM_MSG ? !isFirstDVMSnoopSent : 1) begin
                // Copy for Err inj
                m_tmp2_seq_item = smi_seq_item::type_id::create("m_seq_item");
                m_tmp2_seq_item.copy(m_tmp_seq_item);
                m_smi_tx_req_q.push_back(m_tmp2_seq_item);
            end

            //Need to recompute once STRreq of any CMDreq is done since that could lead to dir st update of the requestor 
            //and this snp req was generated before that state change   
            if (m_tmp_seq_item.smi_msg_type != SNP_DVM_MSG) begin
                if (state_list.exists({m_tmp_seq_item.smi_ns,m_tmp_seq_item.smi_addr[WSMIADDR-1:SYS_wSysCacheline]})) begin
                    if (state_list[{m_tmp_seq_item.smi_ns,m_tmp_seq_item.smi_addr[WSMIADDR-1:SYS_wSysCacheline]}] == SysBfmSC) begin
                        isSharer = 1;
                        isOwner  = 0;
                    end
                    else if(state_list[{m_tmp_seq_item.smi_ns,m_tmp_seq_item.smi_addr[WSMIADDR-1:SYS_wSysCacheline]}] == SysBfmIX) begin
                        isSharer = 0;
                        isOwner  = 0;
                    end 
                    else begin
                        isSharer = 0;
                        isOwner  = 1;
                    end
                end
                if (isOwner && (state_list[{m_tmp_seq_item.smi_ns,m_tmp_seq_item.smi_addr[WSMIADDR-1:SYS_wSysCacheline]}] == SysBfmSD)) begin
                        if ($urandom_range(0,100) > 50) begin //update with using knobs
                            m_tmp_seq_item.smi_up = SMI_UP_PRESENCE; // #Stimulus.CHIAIU.v3.4.SP.Random
                        end else begin
                            m_tmp_seq_item.smi_up = SMI_UP_PERMISSION; // #Stimulus.CHIAIU.v3.4.SP.Random
                        end
                        if(m_tmp_seq_item.smi_up == SMI_UP_PERMISSION)
                            m_tmp_seq_item.smi_mpf3_intervention_unit_id = <%=obj.FUnitId%>;
                end 
                else if (isOwner) begin
                    m_tmp_seq_item.smi_up   = SMI_UP_PRESENCE;
                end
                else if (isSharer) begin
                        if ($urandom_range(0,100) > 50) begin //update with using knobs
                        m_tmp_seq_item.smi_up = SMI_UP_PRESENCE; // #Stimulus.CHIAIU.v3.4.SP.Random
                        end else begin
                        m_tmp_seq_item.smi_up = SMI_UP_PERMISSION; // #Stimulus.CHIAIU.v3.4.SP.Random
                        end
                        if ($urandom_range(100) > 10 || m_tmp_seq_item.smi_msg_type inside {SNP_CLN_DTR, SNP_VLD_DTR, SNP_NOSDINT, SNP_INV_DTR, SNP_NITC, SNP_NITCCI, SNP_NITCMI}) begin //update with using knobs
                            m_tmp_seq_item.smi_mpf3_intervention_unit_id = <%=obj.FUnitId%>;
                        end else begin
                            m_tmp_seq_item.smi_mpf3_intervention_unit_id = <%=obj.FUnitId%> + 1;
                        end
                end else begin
                    m_tmp_seq_item.smi_up   = SMI_UP_PRESENCE; //Need to change this when we have work around for snoops
                end
            end

         <% if (obj.AiuInfo[obj.Id].wAddr < 41) { %> //CONC-12977 ACADDR[3] is SBZ when wAddr < 41 for 2nd AC Snoop DVM Req as per ARM Spec IHI 0022H.c Table D13-6
-            if ((m_tmp_seq_item.smi_msg_type == SNP_DVM_MSG) && (m_tmp_seq_item.smi_addr[3] === 1'b1)) begin
-                m_tmp_seq_item.smi_addr[38] = 0;
-            end
-            <%}%>    
            
            m_snpreq_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
            m_snpreq_tx.m_seq_item = m_tmp_seq_item;
	
        snp_type=eMsgSNP'(m_tmp_seq_item.smi_msg_type);//Explicit conversion from logic vector to enum bit
        `uvm_info("SYS BFM DEBUG", $sformatf("Sending snoop to addr:0x%0x NS:%0b snp:%0s from initial state:%0s", m_tmp_seq_item.smi_addr, m_tmp_seq_item.smi_ns, snp_type.name(), state_list[{m_tmp_seq_item.smi_ns,m_tmp_seq_item.smi_addr[WSMIADDR-1:SYS_wSysCacheline]}]), UVM_LOW)
            
        `uvm_info("SYS BFM DEBUG", $sformatf("Sending snoop to address 0x%0x snoop type %p snoop unq id 0x%0x firstDvmsnoopsent %0d DVM Unq ID 0x%0x",m_tmp_seq_item.smi_addr, m_tmp_seq_item.smi_msg_type, m_tmp_seq_item.smi_unq_identifier, isFirstDVMSnoopSent, m_first_DVM_unq_id), UVM_LOW); 
            `uvm_info("SYS BFM DEBUG", $sformatf("fn: send_snp_req m_snpreq_tx.m_seq_item - %0s",m_snpreq_tx.m_seq_item.convert2string()), UVM_LOW); 
            `uvm_info("SYS BFM DEBUG", $sformatf("fn: send_snp_req m_tmp_seq_item - %0s",m_tmp_seq_item.convert2string()), UVM_LOW); 
            if ((m_tmp_seq_item.smi_msg_type == SNP_DVM_MSG) && (!m_dvm_unq_identifier_q.exists(m_tmp_seq_item.smi_unq_identifier))) begin
                m_dvm_unq_identifier_q[m_tmp_seq_item.smi_unq_identifier] = 1;
            end 
            m_snpreq_tx.return_response(m_smi_seqr_tx_hash["snp_req_"]);
            //if (m_sfi_mst_req_q.size() > <%=obj.nPendingTransactions%> + 1) begin
            //    `uvm_error("SYS BFM SEQ", $sformatf("There are more than nPendingTransactions sent on AIU's SFI slave interface without a SFI response (nPendingTrans: %0d Outstanding requests: %0d", <%=obj.nPendingTransactions%>, m_sfi_mst_req_q.size()), UVM_NONE);
            //end
            ->e_smi_tx_req_q;
            if($test$plusargs("resend_correct_target_id")) resend_correct_target_id(m_snpreq_tx, "wrong_snpreq_target_id");
            <% if((obj.Block =='chi_aiu') || (obj.Block =='io_aiu')) { %>
            end
            else begin
                if ((m_tmp_seq_item.smi_msg_type == SNP_DVM_MSG) && (!m_dvm_unq_identifier_q.exists(m_tmp_seq_item.smi_unq_identifier))) begin
                    m_dvm_unq_identifier_q[m_tmp_seq_item.smi_unq_identifier] = 1;
                end 
            end
            <% } %>
//	   s_addr.put();
        end // else: !if(m_smi_snp_req_q.size == 0)
    end // forever begin
   
endtask : send_snp_req

function bit [<%=obj.AiuInfo[obj.Id].concParams.hdrParams.wPriority%>-1:0] qos_mapping(int qos);
    <%if(obj.AiuInfo[obj.Id].fnEnableQos){%>
        int qos_array[<%=obj.AiuInfo[obj.Id].QosInfo.qosMap.length%>];
	<%obj.AiuInfo[obj.Id].QosInfo.qosMap.forEach(function(val, idx){ %>
	  qos_array[<%=idx%>] = <%=val%>;
	<%});%>
          foreach(qos_array[i])
		if(qos_array[i][qos])
			return(i);
    <%}else{%>
	qos_mapping='0;
    <%}%>
endfunction//qos_mapping

task create_snoop_req_for_snoopme;
    forever begin
        if (m_smi_cmd_self_snoop_req_q.size == 0) begin
            @e_smi_cmd_self_snoop_req_q;
        end
        else begin
            smi_seq_item m_tmp_snp_item;
            int qos_val = 1 ? $urandom_range(0, 15) : '0;
            bit done = 1;
	   
//	   uvm_report_info("DCDEBUG", $sformatf("Waiting for create_snoop_req_for_snoopme"),UVM_MEDIUM);
	   s_addr.get(); //OUTERLOCK
//	   uvm_report_info("DCDEBUG", $sformatf("Locked by create_snoop_req_for_snoopme"),UVM_MEDIUM);
            s_snp.get();
            do begin
                smi_addr_security_t m_tmp_addr;
                smi_msg_type_bit_t  snp;
                m_smi_cmd_self_snoop_req_q.shuffle();
                done = 1;
//	       uvm_report_info("DCDEBUG",$sformatf("Locked at create_snoop_req_for_snoopme"),UVM_MEDIUM);
                if (isAddrInSmiStrPendingAssocArray(m_smi_cmd_self_snoop_req_q[0].m_addr)) begin
                    done = 0;
                    //`uvm_info("SYS BFM DEBUG", $sformatf("Reached here Self Snoop 2"), UVM_HIGH)
                    @e_smi_unq_id_freeup;
                    //`uvm_info("SYS BFM DEBUG", $sformatf("Reached here Self Snoop 3"), UVM_HIGH)
                end
                if (isAddrInSmiSnpPendingArray(m_smi_cmd_self_snoop_req_q[0].m_addr)) begin
                    done = 0;
                    //`uvm_info("SYS BFM DEBUG", $sformatf("Reached here Self Snoop 4"), UVM_HIGH)
                    @e_smi_unq_id_freeup;
                    //`uvm_info("SYS BFM DEBUG", $sformatf("Reached here Self Snoop 5"), UVM_HIGH)
                end
//	       s_addr.put(); //DCDEBUG
            end while(!done);
            m_tmp_snp_item = smi_seq_item::type_id::create("m_tmp_snp_item");
            m_tmp_snp_item.smi_targ_ncore_unit_id = <%=obj.FUnitId%>;
            m_tmp_snp_item.smi_src_ncore_unit_id =
            <% if(obj.testBench == "chi_aiu" || obj.testBench == "io_aiu" ) { %>addrMgrConst::aiu_connected_dce_ids[<%=obj.FUnitId%>].ConnectedfUnitIds[$urandom_range(0,addrMgrConst::aiu_connected_dce_ids[<%=obj.FUnitId%>].ConnectedfUnitIds.size()-1)]; <% } else { %> DCE_Funit_Id[$urandom_range(0,1)]; // FIXME <% } %>

            m_tmp_snp_item.smi_msg_type = SNP_INV_DTW;
            m_tmp_snp_item.unpack_smi_unq_identifier();
            <% if((obj.Block =='chi_aiu') || (obj.Block =='io_aiu')) { %>
            if (m_dce_dve_attach_st.exists(m_tmp_snp_item.smi_src_ncore_unit_id) && m_dce_dve_attach_st[m_tmp_snp_item.smi_src_ncore_unit_id] == 1) begin
            <% } %>
            //`uvm_info("SYS BFM DEBUG", $sformatf("Reached here Self Snoop 6"), UVM_HIGH)
            giveSmiMsgId(m_tmp_snp_item);
            //`uvm_info("SYS BFM DEBUG", $sformatf("Reached here Self Snoop 7"), UVM_HIGH)
            m_tmp_snp_item.smi_addr            = m_smi_cmd_self_snoop_req_q[0].m_addr[WSMIADDR-1:0];
            m_tmp_snp_item.smi_msg_tier        = 0;
            m_tmp_snp_item.smi_steer           = 0;
            m_tmp_snp_item.smi_msg_pri         = 1 ? qos_mapping(qos_val) : '0;
            m_tmp_snp_item.smi_msg_qos         = |qos_val;
            m_tmp_snp_item.smi_qos             = qos_val;
            m_tmp_snp_item.smi_cmstatus        = 0;
            m_tmp_snp_item.smi_vz              = 0;
            m_tmp_snp_item.smi_ac              = 1;
            m_tmp_snp_item.smi_ca              = 1;
            m_tmp_snp_item.smi_ns              = m_smi_cmd_self_snoop_req_q[0].m_addr[WSMIADDR];
            m_tmp_snp_item.smi_pr              = 0;
            m_tmp_snp_item.smi_up              = 0;
            m_tmp_snp_item.smi_rl              = 0;
            m_tmp_snp_item.smi_tm              = 0;
    	    <% if((obj.fnNativeInterface == "CHI-A")||(obj.fnNativeInterface == "CHI-B")||(obj.fnNativeInterface == "CHI-E")){%>
	    	m_tmp_snp_item.smi_tof	       = 1;
    	    <%}else if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
	    	m_tmp_snp_item.smi_tof	       = 2;
    	    <%}else if(obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5"){%>
//	    	m_tmp_snp_item.smi_tof	       = 3;
	    <%}%>

            m_tmp_snp_item.smi_mpf1_dtr_tgt_id = <%=obj.FUnitId%> + 1;
            giveSmiSnpDtrMsgId(m_tmp_snp_item);
	   <%/*if(obj.testBench == "io_aiu") { */%>
//	    m_tmp_snp_item.smi_intfsize        = <%=Math.ceil(Math.log2(obj.wXData)/Math.log(2))%>;
//	    m_tmp_snp_item.smi_intfsize        = <%=Math.ceil(Math.log2(obj.wXData / 64))%>;
	   <% /*} else { */%>
            std::randomize(m_tmp_snp_item.smi_intfsize) with {m_tmp_snp_item.smi_intfsize >= 0;
                                                          m_tmp_snp_item.smi_intfsize < 3;};
	   <% /*}*/ %>
            std::randomize(m_tmp_snp_item.smi_dest_id) with{m_tmp_snp_item.smi_dest_id inside {<%obj.DmiInfo.forEach(function(dmi, idx){%><%=dmi.FUnitId%><%if(idx<(obj.DmiInfo.length-1)){%>, <%}%><%});%>};};
            giveSmiRbId(m_tmp_snp_item,1'b0);
//	    uvm_report_info("DCDEBUG",$sformatf("Locked at create_snoop_req_for_snoopme"),UVM_MEDIUM);
            m_smi_snp_req_q.push_back(m_tmp_snp_item);
            m_smi_cmd_self_snoop_req_sent_q.push_back(m_smi_cmd_self_snoop_req_q[0]);
            m_smi_cmd_self_snoop_req_q.delete(0);
            s_snp.put();
//	   uvm_report_info("DCDEBUG", $sformatf("Released by create_snoop_req_for_snoopme"),UVM_MEDIUM);
            s_addr.put(); //OUTERLOCK
            ->e_smi_snp_req_q;
            <% if((obj.Block =='chi_aiu') || (obj.Block =='io_aiu')) { %>
            end
            else begin
                m_smi_cmd_self_snoop_req_q.delete(0);
                s_snp.put();
                s_addr.put(); //OUTERLOCK
            end
            `ifdef VCS
            -> e_smi_outstandingq_del;
            `endif
            <% } %>
         end // else: !if(m_smi_cmd_self_snoop_req_q.size == 0)
       
    end
endtask : create_snoop_req_for_snoopme

function smi_addr_security_t give_random_dvm_addr(const ref bit isDVMSync);
<% if ((obj.testBench == "chi_aiu") || (obj.testBench == "io_aiu")) { %>
    smi_addr_security_t m_tmp_addr;
    //smi_addr_security_t m_tmp_addr = $urandom();
    // CONC-7994, Error-1 : SnpDVMOp, Invalid Physical Instruction Cache Invalidate DVM operation type received having Address field in first part SNPDVMOp, Addr[8:4] observed is 	 11110 
    valid_address_for_dvm_operation_xact dvm_operation_xact_addr = new();
    if (isDVMSync) begin
      dvm_operation_xact_addr.randomize() with {addr[13:11]==3'b100;} ;
      m_tmp_addr = dvm_operation_xact_addr.addr;
    end
    else if ($test$plusargs("prob_ace_snp_resp_error"))begin
      if ($test$plusargs("tlb_invld_only")) begin
         dvm_operation_xact_addr.randomize() with {addr[13:11]==3'b000;} ;
      end else if ($test$plusargs("bpi_only")) begin
         dvm_operation_xact_addr.randomize() with {addr[13:11]==3'b001;} ;
      end else if ($test$plusargs("pici_only")) begin
         dvm_operation_xact_addr.randomize() with {addr[13:11]==3'b010;} ;
      end else if ($test$plusargs("vici_only")) begin
         dvm_operation_xact_addr.randomize() with {addr[13:11]==3'b011;} ;
      end else if ($test$plusargs("hint_only")) begin
         dvm_operation_xact_addr.randomize() with {addr[13:11]==3'b110;} ;
      end else begin
         dvm_operation_xact_addr.randomize() with {addr[13:11] dist{3'b000:=20,3'b001:=20,3'b010:=20,3'b011:=20,'b110:=20};};
      end
      m_tmp_addr = dvm_operation_xact_addr.addr;
    end
    else begin 
      dvm_operation_xact_addr.randomize() with {addr[13:11]!=3'b100;} ;
      m_tmp_addr = dvm_operation_xact_addr.addr;
    end
<% } else { %>    
    smi_addr_security_t m_tmp_addr = $urandom();
    if (isDVMSync) begin
        m_tmp_addr[13:11] = 'b100;
    end else begin
        notDVMSyncAddr m_tmp = new();
        m_tmp.randomize();
        m_tmp_addr[13:11] = m_tmp.m_return_value; 
    end
<% } %>

    m_tmp_addr[2:0] = '0;

     <% if (obj.AiuInfo[obj.Id].wAddr == 32) { %>  
    m_tmp_addr[31:30] =2'b00; // not used because ASID[15:8] not used in case 32bits
    <% } %>

    give_random_dvm_addr = m_tmp_addr;
    `uvm_info("DEBUG", $sformatf("first_part of dvm snoop : %0h, OP_type :%0d ",give_random_dvm_addr,give_random_dvm_addr[13:11]),UVM_LOW);
endfunction : give_random_dvm_addr

function smi_addr_security_t give_second_part_dvm_addr();
    smi_addr_security_t m_tmp_addr;
    <% if (obj.wAddr >= 50) { %>
    m_tmp_addr[WSMIADDR-1:50] = 0;
    m_tmp_addr[49:10] = $urandom;
    <% } else {%>
    m_tmp_addr[WSMIADDR-1:10] = $urandom;
    <% } %>
    <% if (obj.wAddr > 42) { %>
    m_tmp_addr[45:43] = $urandom_range(0,7);
    <% } %>
    m_tmp_addr[9:8] = $urandom_range(0,3);
    m_tmp_addr[7:6] = $urandom_range(0,3);
    m_tmp_addr[5:4] = $urandom_range(0,3);
    m_tmp_addr[3]   = 1; //Table 7-5: Format of the second DVM SNPReq message
    m_tmp_addr[2:0] = 0; //Reserved Table 7-5: Format of the second DVM SNPReq message

    give_second_part_dvm_addr = m_tmp_addr;

endfunction : give_second_part_dvm_addr

task create_snoop_req;
    int count;
    int count_outstanding_snps = 0;
    int snp_critical_Byte;
    int pause_snoops_until_num_cmdreqs;
    int do_count = 0;
    int dvm_snp_count = 0;
    eMsgSNP     snp_type;	
    int fnmem_region_idx;

    smi_seq_item m_tmp_snp_item;
    <% if (obj.Block =='chi_aiu') { %>
	if ($test$plusargs("zero_nonzero_crd_test")) begin  
        fork
            begin : pause_traffic
                forever 
                   begin
                      uvm_config_db#(int)::get(null,"*","pause_main_traffic",pause_snoops_traffic);
                      if (pause_snoops_traffic == 1) begin
                         `uvm_info(get_full_name(),$sformatf("SYSTEM BFM thread_pause_snoops_traffic : %0h",pause_snoops_traffic),UVM_DEBUG)
                      end else begin
                          pause_snoops_traffic = 'h0;
                      end
                      #100;
                   end                  
            end : pause_traffic
        join_none
    end
    <% } %>

	if (($value$plusargs("pause_snoops_until_num_cmdreqs=%d", pause_snoops_until_num_cmdreqs))) begin 
		//`uvm_info("SYS BFM DEBUG", $sformatf("before wait pause_snoops_until_num_cmdreqs:%0d cmdreq_count:%0d", pause_snoops_until_num_cmdreqs, cmdreq_count), UVM_LOW)

	        `uvm_info("SYS BFM DEBUG", $sformatf("ioaiup:pause_snoops_until_num_cmd_req before waiting"), UVM_LOW)
         <%if (obj.orderedWriteObservation == true) {%>
           do begin 
	      #(<%=obj.Clocks[0].params.period%>ps * 10);
           end    
        while(cmdreq_count < pause_snoops_until_num_cmdreqs);
	        `uvm_info("SYS BFM DEBUG", $sformatf("ioaiup:pause_snoops_until_num_cmd_req done waiting"), UVM_LOW)

          <%} else {%> 
          do begin 
             if(!(cmdreq_count == pause_snoops_until_num_cmdreqs && 
                  strreq_count == pause_snoops_until_num_cmdreqs &&
                  m_smi_cmd_req_q.size() == 0 &&
                  m_smi_dvm_cmd_req_q.size() == 0 &&
                  m_smi_snp_req_q.size() == 0 &&
	          m_smi_str_req_q.size() == 0 &&
	          m_smi_tx_req_q.size() == 0 &&
	          m_smi_cmd_self_snoop_req_q.size() == 0 &&
	          m_smi_dtr_req_q.size() == 0))
                  begin
	        `uvm_info("SYS BFM DEBUG", $sformatf("before fork"), UVM_LOW)
                  fork 
                      @(e_smi_outstandingq_del);
                      @(e_match_cmdreq_pause_cnt);
                  join_any
	        `uvm_info("SYS BFM DEBUG", $sformatf("after fork"), UVM_LOW)
             end
             do_count++;
          end
          while(!(cmdreq_count == pause_snoops_until_num_cmdreqs &&
                  strreq_count == pause_snoops_until_num_cmdreqs &&
                  //dtrreq_count == pause_snoops_until_num_cmdreqs &&
                  m_smi_cmd_req_q.size() == 0 &&
                  m_smi_dvm_cmd_req_q.size() == 0 &&
                  m_smi_snp_req_q.size() == 0 &&
	          m_smi_str_req_q.size() == 0 &&
	          m_smi_tx_req_q.size() == 0 &&
	          m_smi_cmd_self_snoop_req_q.size() == 0 &&
	          m_smi_dtr_req_q.size() == 0) && (do_count<10000));

          if (do_count == 10000)
          `uvm_error("SYS BFM DEBUG", "10000 tries to wait till all smi_outstanding queues becomes empty");

	  //`uvm_info("SYS BFM DEBUG", $sformatf("after wait pause_snoops_until_num_cmdreqs:%0d cmdreq_count:%0d", pause_snoops_until_num_cmdreqs, cmdreq_count), UVM_LOW)
          <%}%>
	end 
        else begin 
          <% if((obj.Block =='chi_aiu') || (obj.Block =='io_aiu')) { %>
		wait(m_dce_dve_attach_st.size() == <%if(obj.fnNativeInterface == "ACELITE-E" && obj.nDvmSnpInFlight){%> DVE_Targ_Id.size()); 
                                            <%} else if(obj.useCache){%> DCE_Funit_Id.size());
                                            <%} else {%> DVE_Targ_Id.size()+ DCE_Funit_Id.size());<%}%>

            <% if(obj.Block =='io_aiu') { %>
                  if (!aiu_scb_en) begin
                      #(<%=obj.Clocks[0].params.period%>ps * 100);
                  end
         <%}%>
         <%}%>
		if (!($test$plusargs("snoop_bw_test")) && !($test$plusargs("dvm_bringup")) && !($test$plusargs("ace_bringup")) && !($test$plusargs("dvm_snp_test"))) begin
			<% if(!(obj.useCache)) {%>
				wait (cmdreq_count > 50);
			<% } else { %>
			  if (aiu_scb_en) begin
                          wait(
                             <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                             m_ncbu_cache_handle[<%=i%>].numReadHits + <%}%>
                             <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                             m_ncbu_cache_handle[<%=i%>].numReadMiss + <%}%>
                             <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                             m_ncbu_cache_handle[<%=i%>].numWriteHits + <%}%>
                             <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                             m_ncbu_cache_handle[<%=i%>].numWriteMiss+ <%}%> 0
                          > 100);
                             //uvm_report_info("MYDISP",$sformatf("Out of wait TotalnumTxn:%0d ", <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%> m_ncbu_cache_handle[<%=i%>].numReadHits + <%}%> <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%> m_ncbu_cache_handle[<%=i%>].numReadMiss + <%}%> <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%> m_ncbu_cache_handle[<%=i%>].numWriteHits + <%}%> <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%> m_ncbu_cache_handle[<%=i%>].numWriteMiss+ <%}%> 0),UVM_LOW);
			  
			  end
			<% } %>
		end
		else if (($test$plusargs("dvm_bringup")) || ($test$plusargs("ace_bringup"))) begin
			//#50ns;
		end
		else if ($test$plusargs("dvm_snp_test")) begin
			//#50ns;
		end
		<% if(obj.useCache) {%>
			if (($test$plusargs("snoop_bw_test"))) begin
				wait (start_snoop_traffic==1);
			end
		<%}%>
	end
    
       `ifdef USE_VIP_SNPS
    	<% if((obj.fnNativeInterface == "CHI-A")){%>
              if ($test$plusargs("inject_smi_uncorr_error")) begin
			<% if(!(obj.useCache)) {%>
				wait (cmdreq_count > 50);
			<% } %>
              end
        <% } %>                                                
       `endif
    uvm_report_info("SYS BFM DEBUG",$sformatf("before getting into snpreq generation while-loop k_num_snp:%0d", k_num_snp.get_value()),UVM_LOW);
    
	while (snoop_count < k_num_snp.get_value()) begin
        smi_addr_security_t m_tmp_addr;
        smi_addr_security_t m_tmp_addr1;
        smi_msg_type_bit_t  snp;
        <%if(obj.nNativeInterfacePorts !== undefined) {%> 
        int                 tmp_indx_prev_coh_addr[<%=obj.DutInfo.nNativeInterfacePorts%>][$];
        <% } else { %>
        int                 tmp_indx_prev_coh_addr[1][$];
        <%}%>
        int                 tmp_indx_cmd_req_coh_addr[$];
        int                 temp_index_size;
        int                 random_core_idq[$];
        int 		    	m_tmp_qB[$];
        int                 wt_tmp_snp_prev_addr;
        int                 wt_tmp_snp_ott_addr;
        int                 wt_tmp_snp_cmd_req_addr;
        int                 wt_tmp_snp_random_addr;
        bit                 flag;
        bit                 isOwner  = 0;
        bit                 isSharer = 0;
        bit                 isDVMSync = 0;
	int		    prev_addr_try;
        int                 qos_val = <%=obj.AiuInfo[obj.Id].fnEnableQos%> ? $urandom_range(0, 15) : '0;
        string 				s = "";
        int                 dve_sttid = 0;
        int                 dce_attid = 0;
        int                 m_tmp_q_ott_addr[$];

        <% if (obj.Block =='io_aiu') { %>
        //Code checks to make sure we do not have more snoops outstanding than
        //the SttCtrlEntries of IOAIU, kind of slows down snoop processing, to allow room for incoming cmdreq processing 
	//uvm_report_info("SYS BFM DEBUG",$sformatf("tsk:create_snoop_req snoop_outst:%0d k_num_snp_q_pending_value:%0d", snoop_outst, k_num_snp_q_pending.get_value()),UVM_LOW);
        while (snoop_outst >= k_num_snp_q_pending.get_value()) begin 
            @e_smi_snp_req_free;
        end

        //slow down DVM snoops, I need to see some coming in after reattach. 
        if ($test$plusargs("enable_reattach_seq") && ((dvm_snp_count % 2 == 0) || (snoop_count % 4 == 0))) begin 
	    #(<%=obj.Clocks[0].params.period%>ps * 10);
        end 
        <% } %>
        <% if (obj.Block =='chi_aiu') { %>
	    if($test$plusargs("snp_srsp_delay") && stt_fill_count < max_stt_fill_count) begin
            if (snoop_outst >= <%=n_snoops%>+10) begin 
                `uvm_info("SYS BFM DEBUG", $psprintf("waiting for ev_fill_stt max_stt_fill_count: %d stt_fill_count: %0d", max_stt_fill_count, stt_fill_count), UVM_HIGH)
                ev_fill_stt.wait_ptrigger();
                `uvm_info("SYS BFM DEBUG", $psprintf("done waiting for ev_fill_stt max_stt_fill_count: %d stt_fill_count: %0d", max_stt_fill_count, stt_fill_count), UVM_HIGH)
            end
        end
	    if ($test$plusargs("zero_nonzero_crd_test") && pause_snoops_traffic == 1) begin  
	    `uvm_info("SYS BFM DEBUG",$sformatf("tsk:create_snoop_req waiting for pause_snoops_traffic value: %0d", pause_snoops_traffic),UVM_LOW);
            wait(pause_snoops_traffic == 0);
	    `uvm_info("SYS BFM DEBUG",$sformatf("tsk:create_snoop_req done waiting for pause_snoops_traffic value: %0d", pause_snoops_traffic),UVM_LOW);
        end
        <% } %>

            s_addr.get();//OUTERLOCK
	//uvm_report_info("SYS BFM DEBUG",$sformatf("tsk:create_snoop_req s_addr semaphore acquired"),UVM_LOW);
            s_snp.get();
	//uvm_report_info("SYS BFM DEBUG",$sformatf("tsk:create_snoop_req s_snp semaphore acquired"),UVM_LOW);
        

        randcase
        wt_snp_inv.get_value()        : snp = SNP_INV;
        wt_snp_cln_dtr.get_value()    : snp = SNP_CLN_DTR; 
        wt_snp_vld_dtr.get_value()    : snp = SNP_VLD_DTR;
        wt_snp_inv_dtr.get_value()    : snp = SNP_INV_DTR;
        wt_snp_cln_dtw.get_value()    : snp = SNP_CLN_DTW;
        wt_snp_inv_dtw.get_value()    : snp = SNP_INV_DTW;
        wt_snp_nitc.get_value()       : snp = SNP_NITC;
        wt_snp_nitcci.get_value()     : snp = SNP_NITCCI;
        wt_snp_nitcmi.get_value()     : snp = SNP_NITCMI;
        wt_snp_nosdint.get_value()    : snp = SNP_NOSDINT;
        wt_snp_inv_stsh.get_value()   : snp = SNP_INV_STSH;
        wt_snp_unq_stsh.get_value()   : snp = SNP_UNQ_STSH;
        wt_snp_stsh_sh.get_value()    : snp = SNP_STSH_SH;
        wt_snp_stsh_unq.get_value()   : snp = SNP_STSH_UNQ;
        wt_snp_dvm_msg.get_value()    : snp = SNP_DVM_MSG;
        endcase

	    snp_type=eMsgSNP'(snp);//Explicit conversion from logic vector to enum bit
        if (snp == SNP_DVM_MSG) begin
            if ($urandom_range(0,100) > k_snp_dvm_msg_not_sync.get_value() || $test$plusargs("dvmsync_only")) begin
                isDVMSync = 1;
            end
            m_tmp_addr = give_random_dvm_addr(isDVMSync);
            if($test$plusargs("force_single_dvm")) begin
                m_tmp_addr[4] = 0;
            end
            if($test$plusargs("force_multi_dvm")) begin
                m_tmp_addr[4] = 1;
            end
        end else begin
            do begin
            	//Get addresses that are already established in cache(AXI4 w/ proxyCache) or used earlier(ACE)
                 <%if(obj.Block =='io_aiu'){%>	
                m_tmp_q_ott_addr = {};
                if (aiu_scb_en) begin
                m_tmp_q_ott_addr =  ioaiu_scb_handle.m_ott_q.find_index with (item.isWrite == 1 && 
									  item.m_ott_status == ALLOCATED &&
                                                                          item.isCoherent === 1 
                                                                          );
                end
                <%}%>
                foreach(tmp_indx_prev_coh_addr[i]) begin
                tmp_indx_prev_coh_addr[i] = {};
                end
                <% if(obj.useCache) { %>
          		if (aiu_scb_en) begin
                           <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    				foreach (m_ncbu_cache_handle[<%=i%>].m_ncbu_cache_q[i]) begin
	      				if (!(isAddrInSmiStrPendingAssocArray({
	      				<% if (obj.wSecurityAttribute > 0) { %>                                             
            			        m_ncbu_cache_handle[<%=i%>].m_ncbu_cache_q[i].security,
        				<% } %>                                                
    					m_ncbu_cache_handle[<%=i%>].m_ncbu_cache_q[i].addr})
                                        || isAddrInSmiSnpPendingArray({
                                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                                        m_ncbu_cache_handle[<%=i%>].m_ncbu_cache_q[i].security,
                                        <% } %>                                                
                                        m_ncbu_cache_handle[<%=i%>].m_ncbu_cache_q[i].addr})) &&
					(m_ncbu_cache_handle[<%=i%>].m_ncbu_cache_q[i].state != IX) && 
                		(addrMgrConst::get_addr_gprar_nc(m_ncbu_cache_handle[<%=i%>].m_ncbu_cache_q[i].addr) == 0 ||
                                $test$plusargs("en_address_aliasing")) //coherent address, CONC-10938 CONC-10915
                		) begin
                    		tmp_indx_prev_coh_addr[<%=i%>].push_back(i);
                		 end
            		      end
			   <%}%>
          		end
        		<% } else { %>
            	foreach (m_addr_history[i]) begin
                	if (!(isAddrInSmiStrPendingAssocArray(m_addr_history[i]) || isAddrInSmiSnpPendingArray(m_addr_history[i]))) begin
                    	tmp_indx_prev_coh_addr[0].push_back(i);
                	end
            	end
		if(wt_snp_prev_addr.get_value() == 100) begin
			tmp_indx_prev_coh_addr[0] = {};
			foreach (m_addr_history[i]) begin
				m_tmp_addr = m_addr_history[i];
                		if (!(isAddrInSmiStrPendingAssocArray(m_addr_history[i]) || isAddrInSmiSnpPendingArray(m_addr_history[i]))) begin
					if(state_list.exists(m_tmp_addr[WSMIADDR:SYS_wSysCacheline])) begin
                    				tmp_indx_prev_coh_addr[0].push_back(i);
					end
                		end
            		end
		end
        		<% } %>
        		
            	//Get addresses that are being processed to create snoop collision with outstanding transactions
        		tmp_indx_cmd_req_coh_addr = {};
        		foreach (m_processing_cmdreq_addr_q[i]) begin
                    <% if(obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") { %>
            		if (!(isAddrInSmiStrPendingAssocArray(m_processing_cmdreq_addr_q[i]) || isAddrInSmiSnpPendingArray(m_processing_cmdreq_addr_q[i])) && (addrMgrConst::get_addr_gprar_nc(m_processing_cmdreq_addr_q[i]) == 0 || $test$plusargs("en_address_aliasing"))) begin
					<% } else {%>
            		if (!(isAddrInSmiStrPendingAssocArray(m_processing_cmdreq_addr_q[i]) || isAddrInSmiSnpPendingArray(m_processing_cmdreq_addr_q[i]))) begin
        			<% } %>
                		tmp_indx_cmd_req_coh_addr.push_back(i);
            		end
        		end

	//			`uvm_info("SYS BFM DEBUG",  $sformatf("tmp_indx_prev_coh_addr - %0p", tmp_indx_prev_coh_addr), UVM_LOW);
	//			`uvm_info("SYS BFM DEBUG",  $sformatf("tmp_indx_cmd_req_coh_addr - %0p", tmp_indx_cmd_req_coh_addr), UVM_LOW);
                                temp_index_size=0;
                                foreach(tmp_indx_prev_coh_addr[i]) begin
                                temp_index_size=temp_index_size+tmp_indx_prev_coh_addr[i].size();
                                end
			        wt_tmp_snp_ott_addr     = (m_tmp_q_ott_addr.size()>0) ? wt_snp_ott_addr.get_value() : 0;	
				wt_tmp_snp_prev_addr    = (temp_index_size > 0) ? wt_snp_prev_addr.get_value() : 0;
				wt_tmp_snp_cmd_req_addr = (tmp_indx_cmd_req_coh_addr.size() > 0) ? wt_snp_cmd_req_addr.get_value() : 0;
				wt_tmp_snp_random_addr  = ((wt_snp_random_addr.get_value() == 0) && ($test$plusargs("pause_snoops_until_num_cmdreqs") == 0)) ? 1 : wt_snp_random_addr.get_value();
	//			`uvm_info("SYS BFM DEBUG",  $sformatf("wt_snp_prev_addr:%0d wt_snp_cmd_req_addr:%0d wr_snp_rando_addr:%0d wt_snp_ott_addr %0d", wt_tmp_snp_prev_addr, wt_tmp_snp_cmd_req_addr,wt_tmp_snp_random_addr,wt_tmp_snp_ott_addr), UVM_LOW);
            	
            	if (snp inside {SNP_INV_STSH, SNP_UNQ_STSH, SNP_STSH_SH, SNP_STSH_UNQ})
            		wt_tmp_snp_random_addr = (wt_snp_for_stash_random_addr.get_value() == 0) ? 1 : wt_snp_for_stash_random_addr.get_value();
            	if (wt_tmp_snp_prev_addr == 0 && wt_tmp_snp_cmd_req_addr == 0 && wt_tmp_snp_random_addr == 0)
                	`uvm_error("SYS BFM ERROR", $sformatf("tsk:create_snoop_req None of the weights were non-zero. Snp type %p Snp Prev Addr weight %0d Snp Cmd Addr weight %0d Snp Random Addr %0d wt_snp_random_addr %0d wt_snp_for_stash_random_addr %0d", snp, wt_tmp_snp_prev_addr, wt_tmp_snp_cmd_req_addr, wt_tmp_snp_random_addr, wt_snp_random_addr.get_value(), wt_snp_for_stash_random_addr.get_value()))
	//		    `uvm_info("SYS BFM DEBUG",  $sformatf("fn: create_snoop_req wt_snp_prev_addr:%0d wt_snp_cmd_req_addr:%0d wt_snp_random_addr:%0d  wt_snp_ott_addr.get_value() %0d", wt_snp_prev_addr.get_value(), wt_snp_cmd_req_addr.get_value(), wt_snp_random_addr.get_value(), wt_snp_ott_addr.get_value()), UVM_LOW);
                randcase
                    wt_tmp_snp_ott_addr:
                    begin 
                     <%if(obj.Block =='io_aiu'){%>
                    m_tmp_q_ott_addr.shuffle();
                    m_tmp_addr = {ioaiu_scb_handle.m_ott_q[m_tmp_q_ott_addr[0]].m_ace_write_addr_pkt.awprot[1],ioaiu_scb_handle.m_ott_q[m_tmp_q_ott_addr[0]].m_ace_write_addr_pkt.awaddr};
                     <%}%>
                    end
                    wt_tmp_snp_prev_addr:
                    begin
                       foreach(tmp_indx_prev_coh_addr[i])begin
                       if (tmp_indx_prev_coh_addr[i].size() > 0)
		       random_core_idq.push_back(i);
                       end
                        random_core_idq.shuffle();
                        tmp_indx_prev_coh_addr[random_core_idq[0]].shuffle();
                        <% if(obj.useCache) { %>
                           if (aiu_scb_en) begin
                            m_tmp_addr = {m_ncbu_cache_handle[random_core_idq[0]].m_ncbu_cache_q[tmp_indx_prev_coh_addr[random_core_idq[0]][0]].security, m_ncbu_cache_handle[random_core_idq[0]].m_ncbu_cache_q[tmp_indx_prev_coh_addr[random_core_idq[0]][0]].addr};
                           end
                        <% } else { %>
			    foreach(tmp_indx_prev_coh_addr[i]) begin
				m_tmp_addr = m_addr_history[tmp_indx_prev_coh_addr[0][i]];
				if(state_list.exists(m_tmp_addr[WSMIADDR:SYS_wSysCacheline])) begin
					break;
				end
			    end
                        <% } %>
						s = "prev_addrq";
			//`uvm_info("SYS BFM", $psprintf("Inside snp prev addr"), UVM_LOW)
                    end
                    wt_tmp_snp_cmd_req_addr:
                    begin
                        tmp_indx_cmd_req_coh_addr.shuffle();
                        m_tmp_addr = m_processing_cmdreq_addr_q[tmp_indx_cmd_req_coh_addr[0]];
						s = "processing_cmdreq_addrq";
			//`uvm_info("SYS BFM", $psprintf("Inside snp cmd addr"), UVM_LOW)
                    end
                    wt_tmp_snp_random_addr:
                    begin
                        bit done = 0;
                        bit used_addr = 0;
                        <%if(obj.nNativeInterfacePorts !== undefined) {%> 
						bit [$clog2(<%=obj.nNativeInterfacePorts%>)-1:0] random_core_id;
						<%}%>
                        do begin
                        	<%if(obj.nNativeInterfacePorts !== undefined) {%> 
                        	 if(select_core_q.size() == <%=obj.nNativeInterfacePorts%>)
                                select_core_q = {};
                                do begin 
                                if(!$test$plusargs("constraint_traffic_to_single_core")) begin
                        	random_core_id = $urandom_range(0,(<%=obj.nNativeInterfacePorts%>-1));
                                end else begin
                                random_core_id = select_core;
                                break;
                                end 
                                end while(random_core_id inside {select_core_q});
				<%}%>
                        	<%if(obj.nNativeInterfacePorts !== undefined) {%> 
                            	m_tmp_addr = m_addr_mgr.get_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>, 1, .core_id(random_core_id));
				<%} else {%>
				<% if((obj.fnNativeInterface == "CHI-A")|| (obj.fnNativeInterface == "CHI-B") ||(obj.fnNativeInterface == "CHI-E")){%>
				do begin
					    used_addr = 0;
                            		    m_tmp_addr = m_addr_mgr.gen_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>, 1);
				    foreach(m_used_snp_stash_addr_q[i]) begin
					m_tmp_addr1 = m_used_snp_stash_addr_q[i];
					if(m_tmp_addr1[WSMIADDR-1:SYS_wSysCacheline] == m_tmp_addr[WSMIADDR-1:SYS_wSysCacheline]) begin
					    used_addr = 1;
					    break;
					end
				    end
				end while (used_addr);
				<%} else {%>
                            	m_tmp_addr = m_addr_mgr.get_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>, 1);
				<%}%>
				<%}%>
		            	<% if (obj.wSecurityAttribute) { %>
                            if((m_tmp_addr[WSMIADDR] == 1) && (addrMgrConst::get_addr_gprar_nsx(m_tmp_addr[WSMIADDR-1:0]) == 0)) begin //CONC-10601
                                m_tmp_addr[WSMIADDR] = 'h0;
                            end 
	                    <% } %>
                            done = !(isAddrInSmiStrPendingAssocArray(m_tmp_addr) || isAddrInSmiSnpPendingArray(m_tmp_addr));
                            <% if(obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") {%>
			    			//IOAIU/CHI would never get a snoop targeting NC=1 region, since snoops can only be originated from DCE for coherent addresses(NC=0)
							done = done & !addrMgrConst::get_addr_gprar_nc(m_tmp_addr[WSMIADDR-1:0]);
                                   if($test$plusargs("en_address_aliasing")) 
                                   done = !(isAddrInSmiStrPendingAssocArray(m_tmp_addr) || isAddrInSmiSnpPendingArray(m_tmp_addr));
							<%}%>
                            //IOAIU/CHIAIU would never get a snoop with NS=1 hitting a NSX=0 region since the transaction would have terminated in master, with DECERR, will never get to Concerto/SMI
			    <% if(obj.testBench == "chi_aiu") { %>
			    `ifdef USE_VIP_SNPS
				if($test$plusargs("random_gpra_secure") || $test$plusargs("all_gpra_secure")) begin
			    	    foreach(m_used_addr_q[i]) begin
			    	        if(m_tmp_addr == m_used_addr_q[i]) begin
					    done = 0;
			    	            break;
			    	        end
			    	    end
				end
			    `endif // `ifdef USE_VIP_SNPS
	                    <% } %>
							<% if (obj.wSecurityAttribute) { %> done = done & !((m_tmp_addr[WSMIADDR] == 1) && (addrMgrConst::get_addr_gprar_nsx(m_tmp_addr[WSMIADDR-1:0]) == 0));
							<% } %>
                            if (!done) begin
                                @e_smi_unq_id_freeup;
                            end
                        end while (!done);
                         <%if(obj.nNativeInterfacePorts !== undefined) {%>
                         select_core_q.push_back(random_core_id);
                         <% } %>
						s = "new_random_addrq";
			//`uvm_info("SYS BFM", $psprintf("Inside snp random addr"), UVM_LOW)
                    end
                endcase

                if (state_list.exists(m_tmp_addr[WSMIADDR:SYS_wSysCacheline])) begin
                    if (state_list[m_tmp_addr[WSMIADDR:SYS_wSysCacheline]] == SysBfmSC) begin
                        isSharer = 1;
                        isOwner  = 0;
                    end
		    else if(state_list[m_tmp_addr[WSMIADDR:SYS_wSysCacheline]] == SysBfmIX) begin
                        isSharer = 0;
                        isOwner  = 0;
 		    end 
		    else begin
                        isSharer = 0;
                        isOwner  = 1;
                    end
                end
		//`uvm_info("SYS BFM", $psprintf("temp index size = %d",temp_index_size),UVM_LOW)
                if((isOwner == 0 && isSharer == 0) && (wt_snp_prev_addr.get_value() == 100)) begin
                    	flag = 1;
		    	if((wt_snp_prev_addr.get_value() == 100) && (temp_index_size == 0)) begin
				if(prev_addr_try == 10) begin
					prev_addr_try = 0;
					break;
				end
				#(<%=obj.Clocks[0].params.period%>ps * 10);
				prev_addr_try++;	
		    	end
                end 
		else
                    break;
            end while(flag);
        end
	m_used_addr_q.push_back(m_tmp_addr);
        m_tmp_snp_item = smi_seq_item::type_id::create("m_tmp_snp_item");
        //#Stimulus.IOAIU.WrongTargetId
        if ($test$plusargs("wrong_snpreq_target_id")) begin
          m_tmp_snp_item.smi_targ_ncore_unit_id = <%=obj.FUnitId%> ^ {WSMINCOREUNITID{1'h1}};
        end else begin
          m_tmp_snp_item.smi_targ_ncore_unit_id = <%=obj.FUnitId%>;
        end
        m_tmp_snp_item.smi_src_ncore_unit_id  = (snp == SNP_DVM_MSG) ? DVE_Targ_Id[0]:
        <% if(obj.testBench == "chi_aiu" || obj.testBench == "io_aiu" ) { %>addrMgrConst::aiu_connected_dce_ids[<%=obj.FUnitId%>].ConnectedfUnitIds[$urandom_range(0,addrMgrConst::aiu_connected_dce_ids[<%=obj.FUnitId%>].ConnectedfUnitIds.size()-1)];<%} else { %>DCE_Funit_Id[$urandom_range(0,<%=obj.DceInfo.length-1%>)]; // FIXME<%}%>
        m_tmp_snp_item.smi_msg_type      = snp;
        m_tmp_snp_item.unpack_smi_unq_identifier();
        <% if((obj.Block =='chi_aiu') || (obj.Block =='io_aiu')) { %>
            // foreach(m_dce_dve_attach_st[key]) begin 
 //                    `uvm_info("SYSTEM BFM DEBUG", $sformatf("tsk:create_snoop_req m_dce_dve_attach_st key:0x%0h value:%0h", key, m_dce_dve_attach_st[key]), UVM_LOW);
//                end 

        if (m_dce_dve_attach_st.exists(m_tmp_snp_item.smi_src_ncore_unit_id) && m_dce_dve_attach_st[m_tmp_snp_item.smi_src_ncore_unit_id] == 1) begin
      <% } %>

        `uvm_info("SYS BFM DEBUG", $sformatf("Generating snoop addr:0x%0x NS:%0b snp:%0s from initial state = %p", m_tmp_addr, m_tmp_addr[WSMIADDR], snp_type.name(), state_list[m_tmp_addr[WSMIADDR:SYS_wSysCacheline]]), UVM_LOW)
        giveSmiMsgId(m_tmp_snp_item);
        if(snp == SNP_DVM_MSG) begin
            m_tmp_snp_item.smi_mpf2_dvmop_id = m_tmp_snp_item.smi_msg_id; //msg_id and dvmop_id are the same, it is the STTID in DVE
            m_tmp_snp_item.smi_addr = m_tmp_addr[WSMIADDR-1:0];
        end else begin
            m_tmp_snp_item.smi_addr[WSMIADDR-1:SYS_wSysCacheline]     = m_tmp_addr[WSMIADDR-1:SYS_wSysCacheline];
	    	
	    	std::randomize(snp_critical_Byte) with { snp_critical_Byte dist{ 0:=10, [1:2**SYS_wSysCacheline-1]:=20};};
            m_tmp_snp_item.smi_addr[SYS_wSysCacheline-1:0] = snp_critical_Byte;
        end
        m_tmp_snp_item.smi_msg_tier = 0;
        m_tmp_snp_item.smi_steer    = 0;
        m_tmp_snp_item.smi_msg_pri  = <%=obj.AiuInfo[obj.Id].fnEnableQos%> ? qos_mapping(qos_val) : '0;
        m_tmp_snp_item.smi_msg_qos  = |qos_val;
        m_tmp_snp_item.smi_qos      = qos_val;
        m_tmp_snp_item.smi_cmstatus = 0;
    	<% if((obj.fnNativeInterface == "CHI-A")|| (obj.fnNativeInterface == "CHI-B") ||(obj.fnNativeInterface == "CHI-E")){%>

            if(snp == SNP_DVM_MSG) begin
	        m_tmp_snp_item.smi_tof	       = $urandom_range(0,1) ? SMI_TOF_CHI : SMI_TOF_ACE;
            end
            else if (snp == SNP_NITCCI ||
               snp == SNP_NITCMI ||
               snp == SNP_INV_STSH ||
               snp == SNP_UNQ_STSH ||
               snp == SNP_STSH_SH ||
               snp == SNP_STSH_UNQ ) begin
	        m_tmp_snp_item.smi_tof	       = $urandom_range(0,1) ? SMI_TOF_CHI : SMI_TOF_AXI;
            end
            else begin
                randcase
	            50: m_tmp_snp_item.smi_tof	       = SMI_TOF_CHI;
	            50: m_tmp_snp_item.smi_tof	       = $urandom_range(0,1) ? SMI_TOF_ACE : SMI_TOF_AXI;
                endcase
            end
            if (snp == SNP_DVM_MSG) begin
                m_tmp_snp_item.smi_mpf1_vmid_ext = $urandom();
                //`uvm_info("DEBUG", $sformatf("smi_mpf1_vmid_ext = 0x%x", m_tmp_snp_item.smi_mpf1_vmid_ext), UVM_HIGH)
            end
            if (snp == SNP_INV_STSH ||
               snp == SNP_UNQ_STSH ||
               snp == SNP_STSH_SH ||
               snp == SNP_STSH_UNQ ) begin
		m_used_snp_stash_addr_q.push_back(m_tmp_addr);
            end
    	<%}else if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
            if(snp == SNP_NITC    ||
               snp == SNP_CLN_DTW ||
               snp == SNP_INV_DTW ||
               snp == SNP_INV ) begin
                randcase
	    	    50: m_tmp_snp_item.smi_tof	       = SMI_TOF_ACE;
	    	    50: m_tmp_snp_item.smi_tof	       = $urandom_range(0,1) ? SMI_TOF_CHI : SMI_TOF_AXI;
                endcase
            end
            if(snp == SNP_NITCCI   ||
               snp == SNP_NITCMI) begin
	         m_tmp_snp_item.smi_tof	       = $urandom_range(0,1) ? SMI_TOF_CHI : SMI_TOF_AXI;
            end
            if(snp == SNP_INV_STSH ||
               snp == SNP_UNQ_STSH ||
               snp == SNP_STSH_SH  ||
               snp == SNP_STSH_UNQ ) begin
	         m_tmp_snp_item.smi_tof	       = $urandom_range(0,1) ? SMI_TOF_CHI : SMI_TOF_ACE;
            end
            if(snp == SNP_CLN_DTR ||
               snp == SNP_VLD_DTR ||
               snp == SNP_INV_DTR ||
               snp == SNP_NOSDINT ) begin
	         m_tmp_snp_item.smi_tof	       = $urandom_range(0,1) ? SMI_TOF_CHI : SMI_TOF_ACE;
            end

    	<%}else if(obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5"){%>
	        m_tmp_snp_item.smi_tof	       = $urandom_range(0,1) ? SMI_TOF_CHI : SMI_TOF_ACE; //DCTODO put some knob here?
	<%}%>

        <% if ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") ||
               (((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")) && obj.nDvmSnpInFlight)
              ) { %>
        if(snp == SNP_DVM_MSG) begin
	    m_tmp_snp_item.smi_tof = $urandom_range(0,1) ? SMI_TOF_CHI : SMI_TOF_ACE;
            m_tmp_snp_item.smi_mpf1_vmid_ext = $urandom();
            // DVM Version is <%=obj.DVMVersionSupport%>
            <% if (obj.DVMVersionSupport >= 132) { %>
            m_tmp_snp_item.smi_mpf3_range = $urandom_range(0,1);
            <% } else { %>
            m_tmp_snp_item.smi_mpf3_range = 0;
            <% } %>
            m_tmp_snp_item.smi_mpf3_num[0] = 0;//Table 7-4: Format of the first DVM SNPReq message (MPF)                
        end
        <% } else if (obj.testBench == "chi_aiu") {%>
            if(snp == SNP_DVM_MSG) begin
                // DVM Version is <%=obj.DVMVersionSupport%>
                <% if (obj.DVMVersionSupport >= 132) { %>
                if (m_tmp_snp_item.smi_addr[13:11] == 0) m_tmp_snp_item.smi_mpf3_range = $urandom_range(0,1);
                <% } %>
            end
        <% } %>

        unique if (snp == SNP_CLN_DTW) begin
            m_tmp_snp_item.smi_vz   = SMI_VZ_SYSTEM_DOMAIN;
      <% if((obj.Block =='chi_aiu') || (obj.Block =='io_aiu')) { %>
        end else if (snp == SNP_INV) begin
            //m_tmp_snp_item.smi_vz   = SMI_VZ_SYSTEM_DOMAIN;
            m_tmp_snp_item.smi_vz   = ($urandom_range(0,100) > 50) ? SMI_VZ_COHERENCY_DOMAIN : SMI_VZ_SYSTEM_DOMAIN;
      <% } %>
        end else if (snp == SNP_INV_DTW) begin
            m_tmp_snp_item.smi_vz   = ($urandom_range(0,100) > 50) ? SMI_VZ_COHERENCY_DOMAIN : SMI_VZ_SYSTEM_DOMAIN;
        end else begin
            m_tmp_snp_item.smi_vz   = SMI_VZ_COHERENCY_DOMAIN;
        end
        unique if (snp == SNP_NITCMI || snp == SNP_NITCCI) begin
            m_tmp_snp_item.smi_ac   = SMI_AC_NOALLOC_IN_SYSTEM_CACHE;
      <% if((obj.Block =='chi_aiu') || (obj.Block =='io_aiu')) { %>
        end else if (snp == SNP_INV_DTW || snp == SNP_INV) begin
       <% } else { %>    
        end else if (snp == SNP_INV) begin
       <% } %>
            m_tmp_snp_item.smi_ac   = ($urandom_range(0,100) > 50) ? SMI_AC_NOALLOC_IN_SYSTEM_CACHE: SMI_AC_ALLOC_IN_SYSTEM_CACHE;
        end else begin
            m_tmp_snp_item.smi_ac   = SMI_AC_ALLOC_IN_SYSTEM_CACHE;
        end
        m_tmp_snp_item.smi_ca       = 1;
      <% if((obj.Block =='chi_aiu') || (obj.Block =='io_aiu')) { %>
        // CONC-7994, Error-2 : SnpDVMOp, Invalid value for NS field, svt_chi_flit.is_non_secure_access observed value is 1, expected value is 0 
        if(snp == SNP_DVM_MSG) begin
          m_tmp_snp_item.smi_ns       = 1'b0;
        end
        else begin
          m_tmp_snp_item.smi_ns       = m_tmp_addr[WSMIADDR];
        end
      <% } else { %>    
        m_tmp_snp_item.smi_ns       = m_tmp_addr[WSMIADDR];
      <% } %>

        m_tmp_snp_item.smi_pr       = ($urandom_range(0,100) > 50) ? 0 : 1;
        if (snp == SNP_CLN_DTR  ||
            snp == SNP_VLD_DTR  ||
            snp == SNP_INV_DTR  ||
            snp == SNP_NITC     ||
            snp == SNP_NITCCI   ||
            snp == SNP_NITCMI   ||
            snp == SNP_NOSDINT  ||
            snp == SNP_INV_STSH ||
            snp == SNP_UNQ_STSH ||
            snp == SNP_STSH_SH  ||
            snp == SNP_STSH_UNQ
 
        <% if((obj.Block =='chi_aiu') || (obj.Block =='io_aiu')) { %>
            || snp == SNP_INV   || 
            snp == SNP_INV_DTW  ||
            snp == SNP_CLN_DTW  
            ) begin
          <% } else { %>
            ) begin
           <% } %>
           //#Stimulus.IOAIU.SP.Random
            if (isOwner && (state_list[m_tmp_addr[WSMIADDR:SYS_wSysCacheline]] == SysBfmSD)) begin
                    if ($urandom_range(0,100) > 50) begin //update with using knobs
                    	m_tmp_snp_item.smi_up = SMI_UP_PRESENCE; // #Stimulus.CHIAIU.v3.4.SP.Random
                    end else begin
                    	m_tmp_snp_item.smi_up = SMI_UP_PERMISSION; // #Stimulus.CHIAIU.v3.4.SP.Random
                    end
		    if(m_tmp_snp_item.smi_up == SMI_UP_PERMISSION)
		    	m_tmp_snp_item.smi_mpf3_intervention_unit_id = <%=obj.FUnitId%>;
            end 
	    else if (isOwner) begin
                m_tmp_snp_item.smi_up   = SMI_UP_PRESENCE;
	    end
	    else if (isSharer) begin
                    if ($urandom_range(0,100) > 50) begin //update with using knobs
                    m_tmp_snp_item.smi_up = SMI_UP_PRESENCE; // #Stimulus.CHIAIU.v3.4.SP.Random
                    end else begin
                    m_tmp_snp_item.smi_up = SMI_UP_PERMISSION; // #Stimulus.CHIAIU.v3.4.SP.Random
                    end
                    if ($urandom_range(100) > 10 || snp inside {SNP_CLN_DTR, SNP_VLD_DTR, SNP_NOSDINT, SNP_INV_DTR, SNP_NITC, SNP_NITCCI, SNP_NITCMI}) begin //update with using knobs
                        m_tmp_snp_item.smi_mpf3_intervention_unit_id = <%=obj.FUnitId%>;
                    end else begin
                        m_tmp_snp_item.smi_mpf3_intervention_unit_id = <%=obj.FUnitId%> + 1;
                    end
                 <% if(obj.testBench == 'chi_aiu') { %>
                    if($test$plusargs("placeholder_snprspdata_ptl"))begin
                    if (snp == SNP_VLD_DTR) begin
                           m_tmp_snp_item.smi_up = SMI_UP_PERMISSION; // #Stimulus.CHIAIU.v3.4.SP.Random
                    end 
                    end
                 <%  } %> 
            end else begin
                m_tmp_snp_item.smi_up   = SMI_UP_PRESENCE; //Need to change this when we have work around for snoops
            end
        end else begin
            m_tmp_snp_item.smi_up   = SMI_UP_NONE;
        end
        if ($test$plusargs("drop_data_case") && isSharer) begin
            m_tmp_snp_item.smi_up   = SMI_UP_PERMISSION;
            m_tmp_snp_item.smi_mpf3_intervention_unit_id = <%=obj.FUnitId%> + 1;
        end
        m_tmp_snp_item.smi_rl       = SMI_RL_COHERENCY;
        m_tmp_snp_item.smi_tm       = $urandom_range(0,1);

      <% if (obj.testBench == "chi_aiu") { %>
      if ((m_tmp_snp_item.smi_msg_type inside {SNP_UNQ_STSH,SNP_STSH_UNQ,SNP_STSH_SH,SNP_INV_STSH,SNP_INV_DTW,SNP_CLN_DTW}) && (m_tmp_snp_item.smi_up == SMI_UP_PERMISSION) && ($urandom_range(0,100) > 50)) begin
           m_tmp_snp_item.smi_mpf3_intervention_unit_id = <%=obj.FUnitId%> + 1;
      end 
      if ((m_tmp_snp_item.smi_msg_type == SNP_INV) && (m_tmp_snp_item.smi_up == SMI_UP_PERMISSION || m_tmp_snp_item.smi_up == SMI_UP_PRESENCE) && ($urandom_range(0,100) > 50)) begin
           m_tmp_snp_item.smi_mpf3_intervention_unit_id = <%=obj.FUnitId%> + 1;
      end
      <% } %>
        if (snp inside {SNP_INV_STSH, SNP_UNQ_STSH, SNP_STSH_SH, SNP_STSH_UNQ}) begin
            <% if (obj.testBench == "io_aiu") { %>
                //IO-AIU can never be a stash target
                m_tmp_snp_item.smi_mpf1_stash_valid = ($urandom_range(0,100) > 50) ? 1 : 0; // valid target identified or not 
                do begin 
                    m_tmp_snp_item.smi_mpf1_stash_nid  = $urandom_range(0,<%=obj.AiuInfo.length-1%>); 
                end while (m_tmp_snp_item.smi_mpf1_stash_nid == <%=obj.AiuInfo[obj.Id].FUnitId%>);
            <% } else { %>
                //CHI can be a valid stash target, 80% of the time DUT is the
                //stash target
                m_tmp_snp_item.smi_mpf1_stash_valid = '1; 
                m_tmp_snp_item.smi_mpf1_stash_nid  = ($urandom_range(0,100) > 20) ? <%=obj.AiuInfo[obj.Id].FUnitId%> : $urandom_range(0,<%=obj.AiuInfo.length-1%>); 
            <% } %>
        end else begin
            do begin 
                m_tmp_snp_item.smi_mpf1_dtr_tgt_id = $urandom_range(0,<%=obj.AiuInfo.length-1%>); 
            end while (m_tmp_snp_item.smi_mpf1_dtr_tgt_id == <%=obj.AiuInfo[obj.Id].FUnitId%>);
            giveSmiSnpDtrMsgId(m_tmp_snp_item);
        end
	      std::randomize(m_tmp_snp_item.smi_intfsize) with {m_tmp_snp_item.smi_intfsize >= 0; m_tmp_snp_item.smi_intfsize < 3;};
        if (snp != SNP_DVM_MSG) m_tmp_snp_item.smi_dest_id = addrMgrConst::map_addr2dmi_or_dii(m_tmp_snp_item.smi_addr, fnmem_region_idx);
        else m_tmp_snp_item.smi_dest_id = DVE_Targ_Id[0]; 
        giveSmiRbId(m_tmp_snp_item,1'b0);
        if (snp == SNP_DVM_MSG) begin
            dvm_snp_count++;
            `uvm_info("DEBUG", $sformatf("Sending first_part of dvm snoop : %0h, OP_type :%0d",m_tmp_snp_item.smi_addr,m_tmp_snp_item.smi_addr[13:11]),UVM_LOW);
        end    
        m_smi_snp_req_q.push_back(m_tmp_snp_item);
	snoop_outst++;
        // Sending second DVM snoop
        if (snp == SNP_DVM_MSG) begin
            smi_seq_item m_tmp2_snp_item = smi_seq_item::type_id::create("m_tmp2_snp_item");
            m_tmp2_snp_item.copy(m_tmp_snp_item);
`ifdef USE_VIP_SNPS
<% if (obj.testBench == "chi_aiu") { %>
            // CONC-7994, Error-3 : SnpDVMOp, Invalid value for vmid_ext field for second part snpdvmop, observed value is 1111010, expected value is 0
            m_tmp2_snp_item.smi_mpf1_vmid_ext = 0;
<% } %>
`endif // `ifdef USE_VIP_SNPS
            <% if ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")) && obj.nDvmSnpInFlight)) { %>
            m_tmp2_snp_item.smi_mpf1_vmid_ext = {4'b0, $urandom()};
            m_tmp2_snp_item.smi_mpf3_num[0] = 1;//Table 7-6: Format of the second DVM SNPReq message (MPF)                
            <% if (obj.DVMVersionSupport >= 132) { %>
            m_tmp2_snp_item.smi_mpf3_num = $urandom();
            <% } else { %>
            m_tmp2_snp_item.smi_mpf3_num = 0;
            <% } %>
            if(m_tmp_snp_item.smi_addr[4] == 0) begin
                m_tmp2_snp_item.smi_addr = '0;
                `uvm_info("DEBUG", $sformatf("DISP1 Sending second_part of dvm snoop : %0h",m_tmp2_snp_item.smi_addr),UVM_LOW);
            end else begin
                <% if (obj.testBench == "io_aiu") { %>
                m_tmp2_snp_item.smi_addr = give_second_part_dvm_addr();
                <% if (obj.DVMVersionSupport >= 132) { /*DVMVersionSupport  = 132 -> DVM v8.4  */ %> 
                if(m_tmp_snp_item.smi_mpf3_range == 1 && m_tmp_snp_item.smi_addr[13:11]=='b0) begin
                   m_tmp2_snp_item.smi_mpf3_num = $urandom_range(0,2**6-1);                
                   m_tmp2_snp_item.smi_mpf3_num[4:3] = $urandom;                
                end else begin
                   m_tmp2_snp_item.smi_mpf3_num[4:3] = $urandom;                
                   m_tmp2_snp_item.smi_mpf3_num[2:0] = 0;                
                end
                <% } else {%>
                   m_tmp2_snp_item.smi_mpf3_num[4:3] = $urandom;                
                `uvm_info("DEBUG", $sformatf("DISP2 Sending second_part of dvm snoop : %0d",m_tmp2_snp_item.smi_mpf3_num),UVM_LOW);
                <% } %>

                <% } else {%>
                m_tmp2_snp_item.smi_addr = give_random_dvm_addr(isDVMSync);
                <% } %>
            end
            <% } else {%>
            m_tmp2_snp_item.smi_addr = give_random_dvm_addr(isDVMSync);
            if(m_tmp_snp_item.smi_mpf3_range == 1) begin
                m_tmp2_snp_item.smi_mpf3_num = $urandom_range(0,2**4-1);                
                m_tmp2_snp_item.smi_addr[5:4] = $urandom_range(0,3);
                m_tmp2_snp_item.smi_addr[7:6] = $urandom_range(1,3);
                m_tmp2_snp_item.smi_addr[9:8] = $urandom_range(0,3);
                if(m_tmp2_snp_item.smi_addr[9:8] == 'b10) begin 
                    m_tmp2_snp_item.smi_addr[11:10] = 0;
                end else if(m_tmp2_snp_item.smi_addr[9:8] == 'b11) begin 
                    m_tmp2_snp_item.smi_addr[13:10] = 0;
                end 
            end
            <% } %>
            m_tmp2_snp_item.smi_addr[3] = 1;
            m_tmp2_snp_item.smi_mpf3_dvmop_portion = 1;
            if (snp == SNP_DVM_MSG) begin
                dvm_snp_count++;
                `uvm_info("DEBUG", $sformatf("Sending second_part of dvm snoop : %0h",m_tmp2_snp_item.smi_addr),UVM_LOW);
            end    
            m_smi_snp_req_q.push_back(m_tmp2_snp_item);
	    snoop_outst++;
        end
        snoop_count++;

        ->e_smi_snp_req_q;
        s_snp.put();
	//uvm_report_info("SYS BFM DEBUG",$sformatf("tsk:create_snoop_req s_snp semaphore released"),UVM_LOW);
	s_addr.put();//OUTERLOCK
	//uvm_report_info("SYS BFM DEBUG",$sformatf("tsk:create_snoop_req s_addr semaphore released"),UVM_LOW);

        //`uvm_info("SYS BFM DEBUG", $sformatf("Creating snoop to address 0x%0x snoop type 0x%0x snoop unq id 0x%0x snoop_count:%0d",m_tmp_snp_item.smi_addr, m_tmp_snp_item.smi_msg_type, m_tmp_snp_item.smi_unq_identifier, snoop_count), UVM_LOW); 
  
        <% if((obj.Block =='chi_aiu') || (obj.Block =='io_aiu')) { %>
         end
        else begin
      wait(m_dce_dve_attach_st.exists(m_tmp_snp_item.smi_src_ncore_unit_id) && m_dce_dve_attach_st[m_tmp_snp_item.smi_src_ncore_unit_id] == 1); 
            s_snp.put();
           s_addr.put();//OUTERLOCK
        end
        <% } %>
      end // while (snoop_count < k_num_snp.get_value())
 
endtask : create_snoop_req

task create_sys_req;
    smi_seq_item m_tmp_sys_req_item;
    int sys_req_event_count = 0;

    wait (cmdreq_count > 1);

    while (sys_req_event_count < k_num_event_msg.get_value()) begin

        int qos_val = <%=obj.AiuInfo[obj.Id].fnEnableQos%> ? $urandom_range(0, 15) : '0;

        m_tmp_sys_req_item = smi_seq_item::type_id::create("m_tmp_sys_req_item");
        //#Stimulus.IOAIU.WrongTargetId
        if($test$plusargs("wrong_sysreq_target_id"))
            m_tmp_sys_req_item.smi_targ_ncore_unit_id = <%=obj.FUnitId%>^{WSMINCOREUNITID{1'h1}};
        else
            m_tmp_sys_req_item.smi_targ_ncore_unit_id = <%=obj.FUnitId%>;
        
        m_tmp_sys_req_item.smi_src_ncore_unit_id  = DVE_Targ_Id[0];
        if (!event_msg_inflight.exists(m_tmp_sys_req_item.smi_src_ncore_unit_id)) begin
            m_tmp_sys_req_item.smi_msg_type = SYS_REQ;
            m_tmp_sys_req_item.unpack_smi_unq_identifier();
            giveSmiMsgId(m_tmp_sys_req_item); 
            m_tmp_sys_req_item.smi_msg_tier = 0;
            m_tmp_sys_req_item.smi_steer    = 0;
            m_tmp_sys_req_item.smi_msg_pri  = <%=obj.AiuInfo[obj.Id].fnEnableQos%> ? qos_mapping(qos_val) : '0;
            m_tmp_sys_req_item.smi_msg_qos  = |qos_val;
            m_tmp_sys_req_item.smi_qos      = qos_val;
            m_tmp_sys_req_item.smi_cmstatus = 0;
            m_tmp_sys_req_item.smi_tm = 0;
            m_tmp_sys_req_item.smi_sysreq_op = 3;
            //m_tmp_sys_req_item.smi_rmsg_id = $urandom(); //FIXME: balajik Need to check.
            m_smi_sys_req_q.push_back(m_tmp_sys_req_item);
            sys_req_event_count++;
            ->e_smi_sys_req_q;
            //`uvm_info("SYS BFM DEBUG", $sformatf("Creating SysReq event message type 0x%0x event unq id 0x%0x", m_tmp_sys_req_item.smi_msg_type, m_tmp_sys_req_item.smi_unq_identifier), UVM_LOW); 
            event_msg_inflight[m_tmp_sys_req_item.smi_src_ncore_unit_id] = 1;
        end
        else begin
            @e_smi_tx_req_q;
        end
    end // while (sys_req_msg_count < k_num_event_msg.get_value())
endtask : create_sys_req

task send_sys_req;
    forever begin
        if (m_smi_sys_req_q.size == 0) begin
            @e_smi_sys_req_q;
        end
        else begin
            smi_seq_item m_tmp_seq_item;

            m_smi_sys_req_q.shuffle();
            //balajik: FIXME add logic to make sure only one outstanding sysReq per DCE.
            m_tmp_seq_item = m_smi_sys_req_q[0];
            m_smi_sys_req_q.delete(0);

            m_smi_tx_req_q.push_back(m_tmp_seq_item);

            m_sysreq_tx.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
            m_sysreq_tx.m_seq_item = m_tmp_seq_item;
            m_sysreq_tx.return_response(m_smi_seqr_tx_hash["sys_req_rx_"]);
            if($test$plusargs("resend_correct_target_id")) resend_correct_target_id(m_sysreq_tx, "wrong_sysreq_target_id");
            ->e_smi_tx_req_q;
        end // else: !if(m_smi_sys_req_q.size == 0)
    end // forever begin
   
endtask : send_sys_req

// Some information from CMPS Rev B and some on CHI-ConcertoC Mappings Sheet-Concerto C Tables
function void giveLegalSTRreqResultForCmd(input  eMsgCMD cmd, output coherResult_t coher_result [$]);

    coherResult_t m_coher_result_list[$] = {};
    case (cmd)
        eCmdRdNC, eCmdWrNCFull, eCmdWrNCPtl, eCmdPref: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdRdNITC : begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 1; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 1; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 1; m_coher_result_tmp.SS = 1; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdRdVld: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 1; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 1; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 1; m_coher_result_tmp.SD = 1; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 1; m_coher_result_tmp.SS = 1; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdRdCln: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 1; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 1; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 1; m_coher_result_tmp.SS = 1; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdRdNShD: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 1; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 1; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 1; m_coher_result_tmp.SS = 1; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdRdUnq: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 1; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdClnUnq, eCmdMkUnq: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdClnVld, eCmdClnShdPer: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 1; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 1; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdClnInv, eCmdMkInv: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdWrUnqPtl: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdWrUnqFull: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdEvict, eCmdWrBkPtl, eCmdWrClnPtl, eCmdWrEvict, eCmdWrBkFull, eCmdWrClnFull: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdWrStshFull, eCmdWrStshPtl: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 1; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdLdCchShd: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 1; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdLdCchUnq: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 1; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdRdNITCClnInv : begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 1; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        eCmdRdNITCMkInv: begin
            coherResult_t m_coher_result_tmp;
            m_coher_result_tmp.SO = 0; m_coher_result_tmp.SS = 0; m_coher_result_tmp.SD = 0; 
            m_coher_result_list.push_back(m_coher_result_tmp);
        end

        default: begin
            `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported CmdReq received in giveLegalSTRreqResultForCmd for CmdReq:%p", cmd));
        end
    endcase

    coher_result = m_coher_result_list;

endfunction : giveLegalSTRreqResultForCmd

function void getEndStateFromStrReq (
        input  eMsgCMD       msg,
        input  coherResult_t coher_result,
    output bfm_cacheState_t ending_state);
    bit isSS = coher_result.SS;
    bit isSO = coher_result.SO;
    bit isSD = coher_result.SD;
    //ending_state = SysBfmSC;
    case (msg)
        eCmdRdNC, eCmdWrNCFull, eCmdWrNCPtl, eCmdPref: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmIX; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdRdNITC: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmIX; 
                end
                3'b010: begin
                    ending_state = SysBfmIX; 
                end
                3'b100: begin
                    ending_state = SysBfmIX; 
                end
                3'b110: begin
                    ending_state = SysBfmIX; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdRdVld: begin
            <% if (obj.useCache == 1) {%>
                if ($test$plusargs("force_shared_endst_for_rdvld")) begin
                  randcase
                      1: ending_state = SysBfmSD;
                      1: ending_state = SysBfmSC;
                  endcase
                end 
                else begin
                  randcase
                      1: ending_state = SysBfmUC; 
                      1: ending_state = SysBfmUD;
                      1: ending_state = SysBfmSD;
                      1: ending_state = SysBfmSC;
                  endcase
                end
            <% } else {%>
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmUC; 
                end
                3'b010: begin
                    ending_state = SysBfmSC; 
                end
                3'b001: begin
                    randcase
                    50: ending_state = SysBfmUC; 
                    50: ending_state = SysBfmUD; 
                    endcase
                end
                3'b011: begin
                    ending_state = SysBfmSD; 
                end
                3'b110: begin
                    ending_state = SysBfmSC; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
            <% } %>
        end

        eCmdRdCln: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmUC; 
                end
                3'b010: begin
                    ending_state = SysBfmSC; 
                end
                3'b001: begin
                    ending_state = SysBfmUC; 
                end
                3'b110: begin
                    ending_state = SysBfmSC; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdRdNShD: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmSC; 
                end
                3'b010: begin
                    ending_state = SysBfmSC; 
                end
                3'b001: begin
                    randcase
                    50: ending_state = SysBfmUC; 
                    50: ending_state = SysBfmUD; 
                    endcase
                end
                3'b110: begin
                    ending_state = SysBfmSC; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdRdUnq: begin
    	    <% if(obj.useCache == 1) {%>
                ending_state = SysBfmUD; 
            <%} else {%>
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmUC; 
                end
                3'b001: begin
                    randcase
                    50: ending_state = SysBfmUC; 
                    50: ending_state = SysBfmUD; 
                    endcase
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
            <%}%>
        end

        eCmdClnUnq, eCmdMkUnq: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmUC; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdClnVld, eCmdClnShdPer: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmIX; 
                end
                3'b010: begin
                    ending_state = SysBfmSC; 
                end
                3'b100: begin
                    ending_state = SysBfmUC; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdClnInv, eCmdMkInv: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmIX; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdWrUnqPtl, eCmdWrUnqFull: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmIX; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmIX; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdWrBkFull ,eCmdWrClnFull ,eCmdEvict ,eCmdWrEvict, eCmdWrBkPtl, eCmdWrClnPtl: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmIX; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdWrStshFull: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmIX; 
                end
                3'b100: begin
                    ending_state = SysBfmUD; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdWrStshPtl: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmIX; 
                end
                3'b100: begin
                    ending_state = SysBfmUC; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdLdCchShd: begin
            case ({isSO, isSS, isSD})
                3'b010: begin
                    ending_state = SysBfmSC; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdLdCchUnq: begin
            case ({isSO, isSS, isSD})
                3'b100: begin
                    ending_state = SysBfmUC; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdRdNITCClnInv: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmIX; 
                end
                3'b010: begin
                    ending_state = SysBfmIX; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        eCmdRdNITCMkInv: begin
            case ({isSO, isSS, isSD})
                3'b000: begin
                    ending_state = SysBfmIX; 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported StrReq received in getEndStateFromStrReq for CmdReq:%p SO:%0d SS:%0d SD:%0d", msg, isSO, isSS, isSD));
                end
            endcase
        end

        default: begin
            `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported CmdReq received in getEndStateFromStrReq"));
    end
    endcase
endfunction : getEndStateFromStrReq


<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
function void getEndStateForACE (
        input  eMsgCMD       cmd,
        input  smi_addr_security_t addr,
        input  smi_mpf1_awunique_t mpf1_awunique,
        input  bfm_cacheState_t start_state,
        output bfm_cacheState_t ending_state);
    
    int              rand_index;
    int              m_tmp_q[$];
    ace_command_types_enum_t ace_cmdtype;
    axi_axdomain_t           ace_axdomain; 
    bfm_cacheState_t ending_state_list[$] = {};

    if (aiu_scb_en) begin
        m_tmp_q = {};
        m_tmp_q = m_ncbu_cache_handle.ace_cmd_addr_q.find_first_index with ( item.m_addr == addr);
        if(!m_ncbu_cache_handle.hasErr && m_tmp_q.size == 0) begin
            `uvm_error("SYSTEM BFM", $sformatf("TB Error: Cannot find related transaction in ace_cmd_addr_q"));
        end else begin
            ace_cmdtype = m_ncbu_cache_handle.ace_cmd_addr_q[m_tmp_q[0]].m_cmdtype;
            ace_axdomain = m_ncbu_cache_handle.ace_cmd_addr_q[m_tmp_q[0]].m_axdomain;
        end
    end

    case (cmd)
        eCmdRdNC: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmIX, SysBfmUC, SysBfmSC: begin
                    ending_state_tmp = SysBfmIX;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUD: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSD,SysBfmSCOwner: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        eCmdRdNITC: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmIX: begin
                    ending_state_tmp = SysBfmIX;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUD: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmSC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSCOwner: begin
                    ending_state_tmp = SysBfmSCOwner;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSD: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmSD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        eCmdRdCln: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmIX, SysBfmSC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmSC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUD: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSD: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmSD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSCOwner: begin
                    ending_state_tmp = SysBfmSCOwner;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        eCmdRdNShD: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmIX, SysBfmSC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmSC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUD: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSD: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmSD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSCOwner: begin
                    ending_state_tmp = SysBfmSCOwner;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        eCmdRdVld: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmIX, SysBfmSC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmSC;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmSD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUD: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSCOwner: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSD: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmSD;
                    ending_state_list.push_back(ending_state_tmp); 
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        eCmdRdUnq: begin
            bfm_cacheState_t ending_state_tmp;      
            case (start_state)
                SysBfmIX, SysBfmSC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUD: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSD, SysBfmSCOwner: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        eCmdClnUnq: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmIX: begin
                    ending_state_tmp = SysBfmIX;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUD: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSCOwner: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSD: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        eCmdClnVld,eCmdClnShdPer: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmIX: begin
                    ending_state_tmp = SysBfmIX;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUC, SysBfmUD: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmSC; //CONC-6925
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSCOwner, SysBfmSD: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                    ending_state_tmp = SysBfmSCOwner;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        eCmdClnInv: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmIX, SysBfmUC: begin //silent evict from UC->IX
                    ending_state_tmp = SysBfmIX;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin //CONC-13651 DCE would always invalidate the requestor on receiving a ClnIn, initial state doesn't matter, final state should be IX
                    ending_state_tmp = SysBfmIX;
                    ending_state_list.push_back(ending_state_tmp);
                end
            endcase
        end
        eCmdMkUnq: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmIX, SysBfmSC, SysBfmSD, SysBfmSCOwner, SysBfmUC, SysBfmUD: begin
                    ending_state_tmp = SysBfmUD;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        eCmdMkInv: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmIX, SysBfmUC, SysBfmUD: begin //silent evict from UC->IX
                    ending_state_tmp = SysBfmIX;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin //CONC-13651 DCE would always invalidate the requestor on receiving a MkInv, initial state doesn't matter, final state should be IX
                    ending_state_tmp = SysBfmIX;
                    ending_state_list.push_back(ending_state_tmp);
                end
            endcase
        end
        eCmdWrNCFull, eCmdWrNCPtl: begin
            if(ace_cmdtype == WRCLN) begin
            //DCE does not get this transaction at all, so no change in state 
                bfm_cacheState_t ending_state_tmp;
                case (start_state)
                    SysBfmIX: begin
                        //ending_state_tmp = SysBfmIX;
                        ending_state_tmp = start_state;
                        ending_state_list.push_back(ending_state_tmp);
                    end
                    SysBfmUC, SysBfmUD: begin
                        //ending_state_tmp = SysBfmUC;
                        ending_state_tmp = start_state;
                        ending_state_list.push_back(ending_state_tmp);
                    end
                    SysBfmSC: begin
                        //ending_state_tmp = SysBfmUC;
                        ending_state_tmp = start_state;
                        ending_state_list.push_back(ending_state_tmp);
                    end
                    SysBfmSD, SysBfmSCOwner: begin
                        //From Ncore System point of view, there is no change in
                        //Ownership, WRCLN if initiated from owner state (UD, UC, SD)
                        //end state in DCE will still be an owner since DCE does
                        //not get this transaction at all, so no change in state 

                        //if(ace_axdomain inside {INNRSHRBL, OUTRSHRBL}) begin
                        //    ending_state_tmp = SysBfmSC;
                        //    ending_state_list.push_back(ending_state_tmp); 
                        //end else begin
                            //ending_state_tmp = SysBfmUC;
                            ending_state_tmp = start_state;
                            ending_state_list.push_back(ending_state_tmp); 
                        //end
                    end
                    default: begin
                        `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p(ACE:WRCLN) Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                    end
                endcase
            end else if(ace_cmdtype == WRBK) begin
                bfm_cacheState_t ending_state_tmp;
                case (start_state)
                    SysBfmUD, SysBfmSD, SysBfmSCOwner, SysBfmIX, SysBfmUC, SysBfmSC: begin
                        ending_state_tmp = SysBfmIX;
                        ending_state_list.push_back(ending_state_tmp);
                    end
                    default: begin
                        `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p(ACE:WRBK) Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                    end
                endcase
            end else begin
                bfm_cacheState_t ending_state_tmp;
                case (start_state)
                    SysBfmIX: begin
                        ending_state_tmp = SysBfmIX;
                        ending_state_list.push_back(ending_state_tmp);
                    end
                    SysBfmUC: begin
                        ending_state_tmp = SysBfmUC;
                        ending_state_list.push_back(ending_state_tmp);
                    end
                    SysBfmUD: begin
                        ending_state_tmp = SysBfmUC;
                        ending_state_list.push_back(ending_state_tmp);
                    end
                    SysBfmSC: begin
                        ending_state_tmp = SysBfmUC;
                        ending_state_list.push_back(ending_state_tmp);
                    end
                    SysBfmSD, SysBfmSCOwner: begin
                        ending_state_tmp = SysBfmUC;
                        ending_state_list.push_back(ending_state_tmp); 
                    end
                    default: begin
                        `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                    end
                endcase
            end
        end
        eCmdWrUnqFull, eCmdWrUnqPtl: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmIX: begin
                    ending_state_tmp = SysBfmIX;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmUC, SysBfmUD, SysBfmSC, SysBfmSCOwner,SysBfmSD: begin
                    if(mpf1_awunique) begin
                        ending_state_tmp = SysBfmIX;
                        ending_state_list.push_back(ending_state_tmp);
                    end else begin
                        ending_state_tmp = SysBfmSC;
                        ending_state_list.push_back(ending_state_tmp);
                    end
                end
                default: begin
                    // `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        eCmdWrBkFull, eCmdWrBkPtl: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmUD, SysBfmUC: begin
                    ending_state_tmp = SysBfmIX;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSD, SysBfmSCOwner: begin
                    ending_state_tmp = SysBfmIX;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        eCmdWrClnFull, eCmdWrClnPtl: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmUD, SysBfmUC: begin
                    ending_state_tmp = SysBfmUC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                SysBfmSD, SysBfmSCOwner: begin
                    ending_state_tmp = SysBfmSC;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        eCmdWrEvict: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmUC: begin
                    ending_state_tmp = SysBfmIX;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        eCmdEvict: begin
            bfm_cacheState_t ending_state_tmp;
            case (start_state)
                SysBfmUC, SysBfmSC, SysBfmSCOwner, SysBfmIX: begin  //Allow I state when UpdReq sends before StrReq
                    ending_state_tmp = SysBfmIX;
                    ending_state_list.push_back(ending_state_tmp);
                end
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported Start State received in getEndStateForACE for CmdReq:%p Start_state: %p Addr: 0x%0x", cmd, start_state, addr));
                end
            endcase
        end
        default: begin
            `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported CmdReq received in getEndStateForACE for CmdReq:%p Addr:0x%0x", cmd, addr));
        end
    endcase
    ending_state_list = ending_state_list.unique();
    rand_index = $urandom_range(0, ending_state_list.size()-1);
    ending_state = ending_state_list[rand_index];
endfunction : getEndStateForACE

function void getEndStateForACESnp (
        input  eMsgSNP       cmd,
        input  smi_addr_security_t addr,
        input  smi_addr_t        smi_addr,
        input  smi_cmstatus_rv_t cmstatus_rv,
        input  smi_cmstatus_rs_t cmstatus_rs,
        input  smi_cmstatus_dc_t cmstatus_dc,
        input  smi_cmstatus_err_t cmstatus_err);

    bfm_cacheState_t start_state = state_list[addr];
    bfm_cacheState_t ending_state;
    bit[2:0] RV_RS_DC = {cmstatus_rv, cmstatus_rs, cmstatus_dc};
    case (cmd)
        eSnpNITC: begin
            case(RV_RS_DC)
                3'b000,
                3'b001: ending_state = SysBfmIX;
                3'b100: ending_state = SysBfmUC;
                3'b110: ending_state = SysBfmSC;
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported cmstatus RV_RS_DC(0b%b) received in getEndStateForACESnp for SnpReq:%p Start_state: %p Addr: 0x%0x", RV_RS_DC, cmd, start_state, addr));
                end
            endcase
        end
        eSnpNITCCI,
        eSnpNITCMI,
        eSnpInvDtw,
        eSnpInv,
        eSnpInvStsh,
        eSnpUnqStsh,
        eSnpStshShd,
        eSnpStshUnq: begin
            case(RV_RS_DC)
                3'b000: ending_state = SysBfmIX;
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported cmstatus RV_RS_DC(0b%b) received in getEndStateForACESnp for SnpReq:%p Start_state: %p Addr: 0x%0x", RV_RS_DC, cmd, start_state, addr));
                end
            endcase
        end
        eSnpClnDtr: begin
            case(RV_RS_DC)
                3'b000,
                3'b001: ending_state = SysBfmIX;
                3'b100: begin
                    if (start_state == SysBfmSC)
                        ending_state = SysBfmSC;
                    else if(start_state inside {SysBfmUC, SysBfmSCOwner})
                        ending_state = SysBfmSCOwner;
                    else
                        ending_state = SysBfmSD;
                end
                3'b110: ending_state = SysBfmSC;
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported cmstatus RV_RS_DC(0b%b) received in getEndStateForACESnp for SnpReq:%p Start_state: %p Addr: 0x%0x", RV_RS_DC, cmd, start_state, addr));
                end
            endcase
        end
        eSnpVldDtr: begin
            case(RV_RS_DC)
                3'b000,
                3'b001: ending_state = SysBfmIX;
                3'b100: begin
                    if (start_state == SysBfmSC)
                        ending_state = SysBfmSC;
                    else if(start_state inside {SysBfmUC, SysBfmSCOwner})
                        ending_state = SysBfmSCOwner;
                    else
                        ending_state = SysBfmSD;
                end
                3'b110,
                3'b111: ending_state = SysBfmSC;
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported cmstatus RV_RS_DC(0b%b) received in getEndStateForACESnp for SnpReq:%p Start_state: %p Addr: 0x%0x", RV_RS_DC, cmd, start_state, addr));
                end
            endcase
        end
        eSnpInvDtr: begin
            case(RV_RS_DC)
                3'b000,
                3'b001: ending_state = SysBfmIX;
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported cmstatus RV_RS_DC(0b%b) received in getEndStateForACESnp for SnpReq:%p Start_state: %p Addr: 0x%0x", RV_RS_DC, cmd, start_state, addr));
                end
            endcase
        end
        eSnpNoSDInt: begin
            case(RV_RS_DC)
                3'b000,
                3'b001: ending_state = SysBfmIX;
                3'b100: begin
                    if(start_state == SysBfmUC ||
                       start_state == SysBfmSCOwner ||
                       start_state == SysBfmSC)
                        ending_state = SysBfmSCOwner;
                    else
                        ending_state = SysBfmSD;
                end
                3'b110: ending_state = SysBfmSC;
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported cmstatus RV_RS_DC(0b%b) received in getEndStateForACESnp for SnpReq:%p Start_state: %p Addr: 0x%0x", RV_RS_DC, cmd, start_state, addr));
                end
            endcase
        end
        eSnpClnDtw: begin
            case(RV_RS_DC)
                3'b000: ending_state = SysBfmIX;
                3'b100: ending_state = SysBfmUC;
                3'b110: ending_state = SysBfmSC;
                default: begin
                    `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported cmstatus RV_RS_DC(0b%b) received in getEndStateForACESnp for SnpReq:%p Start_state: %p Addr: 0x%0x", RV_RS_DC, cmd, start_state, addr));
                end
            endcase
        end
        //CONC-7381
        /* eSnpStshShd: begin */
        /*     case(RV_RS_DC) */
        /*         3'b000: ending_state = SysBfmIX; */
        /*         3'b100: ending_state = SysBfmUC; */
        /*         3'b110: ending_state = SysBfmSC; */
        /*         default: begin */
        /*             `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported cmstatus RV_RS_DC(0b%b) received in getEndStateForACESnp for SnpReq:%p Start_state: %p Addr: 0x%0x", RV_RS_DC, cmd, start_state, addr)); */
        /*         end */
        /*     endcase */
        /* end */
        default: begin
            `uvm_error("SYSTEM BFM", $sformatf("TB Error: Unsupported SnpReq received in getEndStateForACESnp for SnpReq:%p Addr:0x%0x", cmd, addr));
        end
    endcase

     if (cmstatus_err) begin: _snp_error //CONC-9473
        case (cmd)
           eSnpNITC,
           eSnpVldDtr,
           eSnpClnDtr,
           eSnpNoSDInt,
           eSnpClnDtw: begin
                ending_state = start_state;
               `uvm_info("SYS BFM DEBUG", $sformatf("cmstatus_err with %0s => don't change state %0s",cmd.name,ending_state.name), UVM_MEDIUM)
           end
        default: begin
             ending_state = SysBfmIX;
            `uvm_info("SYS BFM DEBUG", $sformatf("cmstatus_err with %0s => SysBfmIX",cmd.name), UVM_MEDIUM)
        end
        endcase 
    end: _snp_error

    if(ending_state == SysBfmIX)
        state_list.delete(addr);
    else
        state_list[addr] = ending_state;

    `uvm_info("SYS BFM DEBUG", $sformatf("Changing state_list after receiving SnpReq:%p for address 0x%0x security 0x%0x from start_state %0p to end_state: %p",cmd, smi_addr,
    <% if (obj.wSecurityAttribute > 0) { %>
    addr[WSMIADDR-1-SYS_wSysCacheline+<%=obj.wSecurityAttribute%>],
    <% } else { %>
    0,
    <% } %>
    start_state, ending_state), UVM_HIGH);
endfunction : getEndStateForACESnp
<% } %>
/*
    cacheState_t  end_state;
    transResult_t result;
    coherResult_t coher;
    bit           isReqAIUToUpdateMem;
    int           qx [$];
    int           qy [$];
    bit           is_dtw_data;

    coher_result.delete();
    trans_result.delete();
    ending_state.delete();

    foreach (Concerto_cacheState_List [i]) begin
        end_state = Concerto_cacheState_List[i];

        for (int s = 4'b0000; s <= 4'b1111; s++) begin
            coher.SS = s[3];
            coher.SO = s[2];
            coher.SD = s[1];
            coher.ST = s[0] ? $urandom_range((2**$bits(coher.ST))-1, 1) : 0;
            if (isLegalSTRreqEndingState ( coher,
                end_state,
            isReqAIUToUpdateMem )) begin
                for (int d = 2'b00; d < 2'b11; d++) begin //NOTE: TR={DO,DS}=2'b11 is reserved.
                    result.DO = d[1];
                    result.DS = d[0];
                    if (isLegalSTRreqResultForCmd ( msg,
                        coher,
                        end_state,
                        result,
                        initial_state,
                    is_dtw_data)) 
                    begin
                        qx = ending_state.find_first_index() with ( item == end_state);
                        qy = trans_result.find_first_index() with ( item == trans_result[qx[0]]);
                        if (qx.size() && qy.size()) begin
                            // duplicate is found, don't push it to output list
                        end else begin
                            if (msg == eCmdClnVld) begin
                                if ((~result.DO & result.DS) | (result.DO & ~result.DS)) begin
                                    coher_result.push_back(coher);
                                    trans_result.push_back(result);
                                    ending_state.push_back(end_state);
                                end
                            end else if (isLegalSTRrspInstalledState(result.DO, result.DS, end_state)) begin
                                coher_result.push_back(coher);
                                trans_result.push_back(result);
                                ending_state.push_back(end_state);
                            end
                        end
                    end
                end // for d
            end // if
        end // for s
    end // foreach 
    */

task giveSmiMsgId (ref smi_seq_item m_seq_item);
    bit          flag;
    int          count;
    smi_msg_id_t m_tmp_smi_msg_id;
    smi_unq_identifier_bit_t key;
    //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:giveSmiMsgId seq_item:%0s", m_seq_item.convert2string()), UVM_LOW)
    s_unqid.get();
    flag  = 0;
    count = 0;

    //foreach(m_unq_id_array[key]) 
        //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:giveSmiMsgId m_unq_id_array- key:0x%0h value:%0d", key, m_unq_id_array[key]), UVM_LOW)

    //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:giveSmiMsgId before do-while"), UVM_LOW)
    do begin
        m_tmp_smi_msg_id = count;
        count++;
        m_seq_item.smi_msg_id = m_tmp_smi_msg_id;
        m_seq_item.unpack_smi_unq_identifier();
        if (!m_unq_id_array.exists(m_seq_item.smi_unq_identifier)) begin
            flag = 1;
            m_unq_id_array[m_seq_item.smi_unq_identifier] = 1;
        end
        //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:giveSmiMsgId flag:%0d count:%0d unq_identifier:0x%0h", flag, count, m_seq_item.smi_unq_identifier), UVM_LOW)
        if ((m_seq_item.isStrMsg() || m_seq_item.isSnpMsg()) ? 
	    m_unq_id_array.num >= 2**WSMIUNQIDENTIFIER - 1: 
	    m_unq_id_array.num >= 2**WSMIUNQIDENTIFIER - 2) begin //reserve extra id for Strs
            //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:giveSmiMsgId Waiting for free up"), UVM_LOW)
            @e_smi_unq_id_freeup;
            count = 0;
            //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:giveSmiMsgId Done Waiting for free up"), UVM_LOW)
        end
    end while (!flag && (count < 2**WSMIMSGID));
    if (count == 2**WSMIMSGID)
        `uvm_error("SYS BFM ERROR", $sformatf("tsk:giveSmi %0d tries to get unique SmiMsgId",2**WSMIMSGID-1))
    s_unqid.put();
endtask: giveSmiMsgId

function freeSmiRbId(smi_seq_item m_item, bit isNonCoh);
   if(m_item.smi_rbid>2**(WSMIRBID - 1) - 1)
   begin
     m_rbid_in_process_nch.delete(m_item.smi_rbid);
     ->e_smi_rbid_ncoh_freeup;
      `uvm_info("SYS BFM DEBUG",$sformatf("free smi_rbid %x ncoh %x num %h", m_item.smi_rbid, isNonCoh, m_rbid_in_process_nch.num), UVM_HIGH)

   end
   else 
   begin
     m_rbid_in_process.delete(m_item.smi_rbid);
     ->e_smi_rbid_coh_freeup;
      `uvm_info("SYS BFM DEBUG",$sformatf("free smi_rbid %x coh %x num %h", m_item.smi_rbid, !isNonCoh, m_rbid_in_process.num), UVM_HIGH)

   end

//if(!isNonCoh)
//   		foreach(m_rbid_in_process[i])
//			$display("rbid coh in use %x", i);
//else
//		foreach(m_rbid_in_process_nch[i])
//			$display("rbid ncho in use %x", i);
/*
   if(m_item.isSnpMsg()) begin
     m_rbid_in_pprocess.delete(m_item.smi_rbid);
   end
   else if(m_item.isStrMsg()) begin
	//figure out if this StrMsg is Coherent or NonCoherent		  
   end
   else begin
     m_rbid_in_process.delete(m_item.smi_rbid);
   end
 */
endfunction // freeSmiRbId
   
      
task giveSmiRbId (ref smi_seq_item m_seq_item, input bit isNonCoh);
    bit        flag;
    int        count;
   
    smi_rbid_t m_tmp_rbid;
    smi_rbid_t m_tmp_rbid_nch;


    //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:giveSmiRbId isNonCoh:%0b strreq:%0s", isNonCoh, m_seq_item.convert2string()), UVM_LOW)
    if(!isNonCoh) begin

       if (m_rbid_in_process.num() == 2**(WSMIRBID - 1)) begin
          `uvm_info("SYS BFM DEBUG", $sformatf("wait pkt %s",m_seq_item.convert2string()), UVM_HIGH)
          `uvm_info("SYS BFM DEBUG", $sformatf("smi_rbid Waiting for CH free up 1"), UVM_HIGH)
          @e_smi_rbid_coh_freeup;
          `uvm_info("SYS BFM DEBUG", $sformatf("wake pkt %s",m_seq_item.convert2string()), UVM_HIGH)
          `uvm_info("SYS BFM DEBUG", $sformatf("smi_rbid Done Waiting CH for free up 1"), UVM_HIGH)
       end
       flag = 0;
       count = 0;
       s_rbid.get();
       do begin
          count++;
	  m_tmp_rbid = $urandom_range(2**(WSMIRBID - 1) - 1,0);
//	  m_tmp_rbid = 1'b1 << (WSMIRBID - 1) | m_tmp_rbid;
//          `uvm_info("SYS BFM DEBUG", $sformatf("Count going through RBID cho loop %0d RBID 0x%0x num %x", count, m_tmp_rbid , m_rbid_in_process.num), UVM_HIGH)
          if (!m_rbid_in_process.exists(m_tmp_rbid)) begin
//	     s_rbid.get();
             flag                = 1;
             m_seq_item.smi_rbid = m_tmp_rbid;
             m_rbid_in_process[m_seq_item.smi_rbid] = 1;
//	     s_rbid.put();
//             `uvm_info("SYS BFM DEBUG", $sformatf("Using RBID cho 0x%0x", m_seq_item.smi_rbid), UVM_HIGH)
          end
          else if (m_rbid_in_process.num()>= 2**(WSMIRBID - 1)) begin
//	     s_rbid.put();
             `uvm_info("SYS BFM DEBUG", $sformatf("smi_rbid Waiting for CH free up 2"), UVM_HIGH)
             @e_smi_rbid_coh_freeup;
//	     s_rbid.get();
             `uvm_info("SYS BFM DEBUG", $sformatf("smi_rbid Done Waiting for CH free up 2"), UVM_HIGH) 
          end
       end while (!flag);
       s_rbid.put();
    end // if (!isNonCoh)
    else begin
       if (m_rbid_in_process_nch.num() == (2**(WSMIRBID - 1)-1)) begin
          //`uvm_info("SYS BFM DEBUG", $sformatf("smi_rbid Waiting for NCH free up 1"), UVM_HIGH)
          //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:giveSmiRbId Waiting for NCH rbid free-up 1"), UVM_LOW)
          @e_smi_rbid_ncoh_freeup;
          //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:giveSmiRbId Done Waiting for NCH rbid free-up 1"), UVM_LOW)
       end
       flag = 0;
       count = 0;
       s_rbid_nch.get();
       do begin
          count++;
//          m_tmp_rbid_nch = $urandom_range(2**(WSMIRBID - 1) - 1, 0);
          m_tmp_rbid_nch = $urandom_range(2**(WSMIRBID) - 2, 2**(WSMIRBID - 1));
//          `uvm_info("SYS BFM DEBUG", $sformatf("Count going through RBID loop %0d RBID 0x%0x num %x", count, m_tmp_rbid , m_rbid_in_process.num), UVM_HIGH)
          if (!m_rbid_in_process_nch.exists(m_tmp_rbid_nch)) begin
//	     s_rbid.get();
             flag                = 1;
             m_seq_item.smi_rbid = m_tmp_rbid_nch;
             m_rbid_in_process_nch[m_seq_item.smi_rbid] = 1;
//	     s_rbid_nch.put();
             //`uvm_info("SYS BFM DEBUG", $sformatf("tsk:giveSmiRbId Using RBID 0x%0x", m_seq_item.smi_rbid), UVM_LOW)
//	     s_rbid.put();
          end
          else if (m_rbid_in_process_nch.num() >= (2**(WSMIRBID - 1)-1)) begin
//	     s_rbid_nch.put();
             //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:giveSmiRbId Waiting for NCH rbid free-up 2"), UVM_LOW)
             @e_smi_rbid_ncoh_freeup;
             //`uvm_info("SYS BFM DEBUG", $psprintf("tsk:giveSmiRbId Done Waiting for NCH rbid free-up 2"), UVM_LOW)
//	     s_rbid_nch.get();
          end
       end while (!flag);
       s_rbid_nch.put();
    end // else: !if(!isNonCoh)
   
/*
    if (m_rbid_in_process.num() == 2**WSMIRBID) begin
        //`uvm_info("SYS BFM DEBUG", $sformatf("smi_rbid Waiting for free up 1"), UVM_HIGH)
        @e_smi_rbid_freeup;
        //`uvm_info("SYS BFM DEBUG", $sformatf("smi_rbid Done Waiting for free up 1"), UVM_HIGH)
    end
    flag = 0;
    count = 0;
    do begin
        count++;
        m_tmp_rbid = $urandom_range(2**WSMIRBID - 1);
        //`uvm_info("SYS BFM DEBUG", $sformatf("Count going through RBID loop %0d RBID 0x%0x", count, m_tmp_rbid), UVM_HIGH)
        if (!m_rbid_in_process.exists(m_tmp_rbid)) begin
            flag                = 1;
            m_seq_item.smi_rbid = m_tmp_rbid;
            m_rbid_in_process[m_seq_item.smi_rbid] = 1;
            //`uvm_info("SYS BFM DEBUG", $sformatf("Using RBID 0x%0x", m_seq_item.smi_rbid), UVM_HIGH)
        end
        else if (m_rbid_in_process.num() >= 2**WSMIRBID) begin
            //`uvm_info("SYS BFM DEBUG", $sformatf("smi_rbid Waiting for free up 2"), UVM_HIGH)
            @e_smi_rbid_freeup;
            //`uvm_info("SYS BFM DEBUG", $sformatf("smi_rbid Done Waiting for free up 2"), UVM_HIGH)
        end
    end while (!flag);
*/
//    s_rbid.put();
endtask : giveSmiRbId

task giveSmiSnpDtrMsgId (ref smi_seq_item m_seq_item);
    bit          flag;
    int          count;
    smi_msg_id_t m_tmp_smi_msg_id;
    if (m_snp_dtr_array.num() == 2**WSMIMSGID- 1) begin
        //`uvm_info("SYS BFM DEBUG", $sformatf("smi_msg_id Waiting for free up 1"), UVM_HIGH)
        @e_snp_dtr_freeup;
        //`uvm_info("SYS BFM DEBUG", $sformatf("smi_msg_id Done Waiting for free up 1"), UVM_HIGH)
    end
    flag  = 0;
    count = 0;
    do begin
        count++;
        m_tmp_smi_msg_id = $urandom_range(2**WSMIMSGID- 1);
        m_seq_item.smi_mpf2_dtr_msg_id = m_tmp_smi_msg_id;
        if (!m_snp_dtr_array.exists(m_seq_item.smi_mpf2_dtr_msg_id)) begin
            flag = 1;
            m_snp_dtr_array[m_seq_item.smi_mpf2_dtr_msg_id] = 1;
        end
        //`uvm_info("SYS BFM DEBUG", m_seq_item.smi_unq_identifier), UVM_HIGH)
        if (m_snp_dtr_array.num() >= 2**WSMIMSGID-1) begin
            //`uvm_info("SYS BFM DEBUG", $sformatf("smi_msg_id Waiting for free up 2"), UVM_HIGH)
            @e_snp_dtr_freeup;
            //`uvm_info("SYS BFM DEBUG", $sformatf("smi_msg_id Done Waiting for free up 2"), UVM_HIGH)
        end
    end while (!flag);
endtask: giveSmiSnpDtrMsgId

function bit end_of_test_checks();
    string msg;
    bit error = 0;

    if (m_smi_cmd_req_q.size() !== 0) begin
        $sformat(msg, "\nCMD Req Queue has %0d pending messages", m_smi_cmd_req_q.size());
        error = 1;
    end
    if (m_smi_dvm_cmd_req_q.size() !== 0) begin
        $sformat(msg, "\nDVM CMD Req Queue has %0d pending messages", m_smi_dvm_cmd_req_q.size());
        error = 1;
    end
    if (m_smi_snp_req_q.size() !== 0) begin
        $sformat(msg, "%s\nSNP Req Queue has %0d pending messages", msg, m_smi_snp_req_q.size());
        foreach(m_smi_snp_req_q[idx])
    		$sformat(msg, "%s\n m_smi_snp_req_q[%0d] = %s", msg, idx, m_smi_snp_req_q[idx].convert2string);
        error = 1;
    end
    if (m_smi_str_req_q.size() !== 0) begin
        $sformat(msg, "%s\nSTR Req Queue has %0d pending messages", msg, m_smi_str_req_q.size());
        foreach(m_smi_str_req_q[idx])
            $sformat(msg, "%s\n m_smi_str_req_q[%0d] = %s, Addr = 0x%0x", msg, idx, m_smi_str_req_q[idx].m_seq_item.convert2string, m_smi_str_req_q[idx].m_addr);
        error = 1;
    end
    if(m_smi_tx_req_q.size != 0) begin
        $sformat(msg, "%s\nSMI TX Queue has %0d pending messages", msg, m_smi_tx_req_q.size());
        foreach (m_smi_tx_req_q[idx])
         $sformat(msg, "%s\n m_smi_tx_req_q[%0d] = %s, CmdType: %p, Addr = 0x%0x", msg, idx, m_smi_tx_req_q[idx].convert2string,m_smi_tx_req_q[idx].smi_msg_type, m_smi_tx_req_q[idx].smi_addr);
    end
    if (m_smi_cmd_self_snoop_req_q.size() !== 0) begin
        $sformat(msg, "%s\nSelf Snoop CMD Req Queue has %0d pending messages", msg, m_smi_cmd_self_snoop_req_q.size());
        error = 1;
    end
    if (m_smi_dtr_req_q.size() !== 0) begin
        $sformat(msg, "%s\nDTR Req Queue has %0d pending messages", msg, m_smi_dtr_req_q.size());
        error = 1;
    end
    if (snoop_count !== k_num_snp.get_value()) begin
        $sformat(msg, "%s\nOut of %0d snoops only %0d snoops were sent", msg, k_num_snp.get_value(), snoop_count);
        error = 1;
    end
    `uvm_info(get_type_name(), msg, UVM_NONE)
    if (!error)
        `uvm_info(get_type_name(), "All the pending transactions are sent", UVM_NONE)
    return(error);

endfunction : end_of_test_checks


function check_queues();
      uvm_report_info(`LABEL,"PROCESSING CMDREQ QuEUES",UVM_NONE);      
   foreach(m_processing_cmdreq_addr_q[i]) begin
      uvm_report_info(`LABEL,$sformatf("Processing Cmd addr[%0d]: 0x%0h", i, m_processing_cmdreq_addr_q[i]),UVM_NONE);      
   end
      uvm_report_info(`LABEL,"PROCESSING NC CMDREQ QuEUES",UVM_NONE);      
   foreach(m_processing_nc_cmdreq_addr_q[i]) begin
      uvm_report_info(`LABEL,$sformatf("Processing Cmd addr[%0d]: 0x%0h", i, m_processing_nc_cmdreq_addr_q[i]),UVM_NONE);      
   end
      uvm_report_info(`LABEL,"NC CMDREQ QuEUES",UVM_NONE);
   if(m_smi_cmd_req_q.size() > 0) begin      
   foreach(m_smi_nc_cmd_req_q[i]) begin
      uvm_report_info(`LABEL,$sformatf("Outst NC CMD #%0d",i),UVM_NONE);
      uvm_report_info(`LABEL,$sformatf("%s", m_smi_nc_cmd_req_q[i].m_seq_item.convert2string()),UVM_NONE);      
   end
   end
      uvm_report_info(`LABEL,"CMDREQ QuEUES",UVM_NONE);      
   foreach(m_smi_cmd_req_q[i]) begin
      uvm_report_info(`LABEL,$sformatf("Outst CMD #%0d",i),UVM_NONE);
      uvm_report_info(`LABEL,$sformatf("%s", m_smi_cmd_req_q[i].m_seq_item.convert2string()),UVM_NONE);      
   end
      uvm_report_info(`LABEL,"DVM CMDREQ QuEUES",UVM_NONE);
   if(m_smi_dvm_cmd_req_q.size() > 0) begin
   foreach(m_smi_dvm_cmd_req_q[i]) begin
      uvm_report_info(`LABEL,$sformatf("Outst DVM CMD #%0d",i),UVM_NONE);
      uvm_report_info(`LABEL,$sformatf("%s", m_smi_dvm_cmd_req_q[i].m_seq_item.convert2string()),UVM_NONE);
   end
   end
  
   foreach(m_rbid_in_process_nch[i]) begin
      uvm_report_info(`LABEL,$sformatf("Outst NCH RBID 0x%0h",i),UVM_NONE);
   end 

   foreach(m_rbid_in_process[i]) begin
      uvm_report_info(`LABEL,$sformatf("Outst CH RBID 0x%0h",i),UVM_NONE);
   end 
     
endfunction // check_queues
   
//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    common_knob_list m_common_knob_list = common_knob_list::get_instance();
    // Disable stashing snoops for non-CHI AIUs
    <% if(!((obj.fnNativeInterface == "CHI-A")||(obj.fnNativeInterface == "CHI-B")||(obj.fnNativeInterface == "CHI-E") || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache))) { %>
        wt_snp_inv_stsh.set_value(0);
        wt_snp_unq_stsh.set_value(0);
        wt_snp_stsh_sh.set_value(0);   
        wt_snp_stsh_unq.set_value(0);
    <% } %>
    <% if (!((obj.fnNativeInterface == "CHI-A")|| (obj.fnNativeInterface == "CHI-B")||(obj.fnNativeInterface == "CHI-E") ||
        (obj.useCache) ||
        (obj.orderedWriteObservation == true) ||
        (obj.nDvmCmpInFlight > 0) ||
        (obj.nDvmSnpInFlight > 0)
    )) { %>    
        k_num_snp.set_value(0);
    <% } %>
 
    m_common_knob_list.print();
    // Constructing sequencer hash for ease of use in main sequence code
    // Reversing TX and RX directions because polarity is opposite for TB than it is for RTL
    <% /*for (var i = 0; i < obj.smiPortParams.rx[i].length; i++) { */%>
    <% for (var i = 0; i < obj.nSmiRx; i++) { %>
        <% for (var j = 0; j < obj.smiPortParams.rx[i].params.fnMsgClass.length; j++) { %>
            m_smi_seqr_tx_hash["<%=obj.smiPortParams.rx[i].params.fnMsgClass[j]%>"] = m_smi_virtual_seqr.m_smi<%=i%>_tx_seqr;
        <% } %>
    <% } %>
    <% /*for (var i = 0; i < obj.smiPortParams.tx[i].length; i++) { */%>
    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
        <% for (var j = 0; j < obj.smiPortParams.tx[i].params.fnMsgClass.length; j++) { %>
            m_smi_seqr_rx_hash["<%=obj.smiPortParams.tx[i].params.fnMsgClass[j]%>"] = m_smi_virtual_seqr.m_smi<%=i%>_rx_seqr;
        <% } %>
    <% } %>

    m_snpreq_tx    = smi_seq::type_id::create("m_snpreq_tx");
    m_allrsp_tx    = smi_seq::type_id::create("m_allrsp_tx");
    m_strreq_tx    = smi_seq::type_id::create("m_strreq_tx");
    m_dtrreq_tx    = smi_seq::type_id::create("m_dtrreq_tx");
    m_sysreq_tx    = smi_seq::type_id::create("m_sysreq_tx");
    
    fork
        begin : monitor_rx_cmdupdreq_body
            monitor_rx_cmdupdreq();
        end : monitor_rx_cmdupdreq_body
        begin : monitor_rx_dtrdtwreq_body
            monitor_rx_dtrdtwreq();
        end : monitor_rx_dtrdtwreq_body
        begin : send_tx_resp_delay_body
            send_tx_resp_delay();
        end : send_tx_resp_delay_body
        begin : send_cmd_resp_delay_body
            send_cmd_resp_delay();
        end : send_cmd_resp_delay_body
        begin : send_dtw_resp_delay_body
            send_dtw_resp_delay();
        end : send_dtw_resp_delay_body
        begin : send_upd_resp_delay_body
            send_upd_resp_delay();
        end : send_upd_resp_delay_body
        begin : decrement_delay_count_body
            decrement_delay_count();
        end : decrement_delay_count_body
        begin : send_tx_resp_body
            send_tx_resp();
        end : send_tx_resp_body
        begin : process_rx_resp_body
            process_rx_resp();
        end : process_rx_resp_body
        begin : monitor_rx_resp_body
<% if (obj.smiPortParams.tx.length == 4) { %>
    monitor_rx_str_snp_sys_resp();
<% } else { %>
    monitor_rx_str_snp_dtr_sys_resp();
<% } %>
        end : monitor_rx_resp_body
<% if (obj.smiPortParams.tx.length == 4) { %>
        begin : monitor_rx_dtr_resp_body
    monitor_rx_dtr_resp();
        end : monitor_rx_dtr_resp_body
<% } %>
        begin : process_c_cmd_req_body
            process_c_cmd_req();
        end : process_c_cmd_req_body
        begin : process_nc_cmd_req_body
            process_nc_cmd_req();
        end : process_nc_cmd_req_body
        begin : send_str_req_delay_body
            send_str_req_delay();
        end : send_str_req_delay_body
        begin : send_str_req_body
            send_str_req();
        end : send_str_req_body
        begin : send_dtr_req_delay_body
            send_dtr_req_delay();
        end : send_dtr_req_delay_body
        begin : send_dtr_req_body
            send_dtr_req();
        end : send_dtr_req_body
        <% if ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") ||
       (obj.fnNativeInterface == "CHI-A") ||
       (obj.fnNativeInterface == "CHI-B") ||
       (obj.fnNativeInterface == "CHI-E") ||
      (obj.useCache) ||
      (obj.orderedWriteObservation == true) ||
      (((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")) && obj.nDvmSnpInFlight)
) { %>    
 
        begin : send_snp_req_body
            send_snp_req();
        end : send_snp_req_body
        begin : create_snoop_req_body
            create_snoop_req();
        end : create_snoop_req_body
        begin : create_snoop_req_for_snoopme_body
            create_snoop_req_for_snoopme();
        end : create_snoop_req_for_snoopme_body
<% } %>
        // Send event messages only for CHI, ACE and AXI4 with proxy cache
    	<% if ((obj.fnNativeInterface.includes('CHI')) ||(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.useCache == 1)) { %>
            begin : send_sys_req_body
                send_sys_req();
            end : send_sys_req_body
            begin : create_sys_req_body
                create_sys_req();
            end : create_sys_req_body
        <%}%>


    join_none

endtask : body

function void shuffleCmdReq();
   smi_seq_item_addr_t nc_cmd_req[$],c_cmd_req[$],new_smi_cmd_req_q[$];
   smi_seq_item_addr_t m_cmd_trans;
   int orig_size;
   nc_cmd_req = {};
   c_cmd_req  = {};
   new_smi_cmd_req_q = {};
   orig_size = m_smi_cmd_req_q.size();
   
   for(int i = 0; i < orig_size; i++) begin
      m_cmd_trans = m_smi_cmd_req_q.pop_front();
//      m_cmd_trans = m_smi_cmd_req_q[i];
      if((m_cmd_trans.m_seq_item.smi_msg_type === eCmdWrNCPtl) || 
           (m_cmd_trans.m_seq_item.smi_msg_type === eCmdRdNC)||
           (m_cmd_trans.m_seq_item.smi_msg_type === eCmdWrNCFull)||
	   //(m_cmd_trans.m_seq_item.smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm} &&  !m_cmd_trans.m_seq_item.smi_ch)) begin
	   (m_cmd_trans.m_seq_item.smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm} &&  m_cmd_trans.m_seq_item.smi_targ_ncore_unit_id inside {DMI_Funit_Id})) begin
	 nc_cmd_req.push_back(m_cmd_trans);
      end
      else begin
	 c_cmd_req.push_back(m_cmd_trans);
      end
   end
   nc_cmd_req.shuffle();
   c_cmd_req.shuffle();
   for(int i = 0; i < nc_cmd_req.size();i++) begin
      new_smi_cmd_req_q.push_back(nc_cmd_req.pop_front());
   end

   for(int i = 0; i < c_cmd_req.size();i++) begin
      new_smi_cmd_req_q.push_back(c_cmd_req.pop_front());
   end
   m_smi_cmd_req_q = new_smi_cmd_req_q;
   
endfunction : shuffleCmdReq
   
function addCmdReqToQueue(smi_seq_item_addr_t cmd_req);
   if((cmd_req.m_seq_item.smi_msg_type === eCmdWrNCPtl) || 
        (cmd_req.m_seq_item.smi_msg_type === eCmdRdNC)||
        (cmd_req.m_seq_item.smi_msg_type === eCmdWrNCFull)||
    <% if ((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || (obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E") ) { %>
        (((cmd_req.m_seq_item.smi_msg_type === eCmdClnShdPer)||
          (cmd_req.m_seq_item.smi_msg_type === eCmdClnVld)   ||
          (cmd_req.m_seq_item.smi_msg_type === eCmdClnInv)   ||
          (cmd_req.m_seq_item.smi_msg_type === eCmdMkInv ))  &&
        !(cmd_req.m_seq_item.smi_targ_ncore_unit_id inside {DCE_Funit_Id})) ||
    <% } %>
	(cmd_req.m_seq_item.smi_msg_type inside {eCmdWrAtm, eCmdRdAtm, eCmdSwAtm, eCmdCompAtm} && 
	 cmd_req.m_seq_item.smi_targ_ncore_unit_id inside {DMI_Funit_Id})) begin
         //uvm_report_info(`LABEL,$sformatf("Txn put in NC cmdreq q:%0s",cmd_req.m_seq_item.convert2string()),UVM_LOW);
            
      m_smi_nc_cmd_req_q.push_back(cmd_req);
      ->e_smi_nc_unq_id_freeup;
      ->e_smi_nc_cmd_req_q;
   end 
   else begin
      if(cmd_req.m_seq_item.smi_msg_type === eCmdDvmMsg) begin
        m_smi_dvm_cmd_req_q.push_back(cmd_req);
      end else begin
        m_smi_cmd_req_q.push_back(cmd_req);
      end
        //uvm_report_info(`LABEL,$sformatf("Txn put in C cmdreq cmdq_sz:%0d dvmq_sz:%0d CMDreq:%0s",m_smi_cmd_req_q.size(), m_smi_dvm_cmd_req_q.size(), cmd_req.m_seq_item.convert2string()),UVM_LOW);
      ->e_smi_unq_id_freeup;
      ->e_smi_cmd_req_q;
   end
endfunction : addCmdReqToQueue
   
endclass : system_bfm_seq

`endif
