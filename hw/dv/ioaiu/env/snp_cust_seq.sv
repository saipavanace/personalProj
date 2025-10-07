//=======================================================================
// COPYRIGHT (C) 2011, 2012, 2013 Synopsys Inc.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
//
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

/**
 * Abstract:
 * class axi_master_coherent_sequence defines a sequence that generates a
 * random discrete master transaction.  This sequence is used by the
 * axi_master_virtual_sequence which is set up as the default sequence for this
 * environment.
 *
 * Execution phase: main_phase
 * Sequencer: Virtual sequencer in AXI System ENV
 */


//------------------------------------------------------------------------------
//
// CLASS: snp_cust_seq
//
//------------------------------------------------------------------------------
    <% if(obj.testBench == "fsys") { %>
      `define NOT_USE_INHOUSE_ACE_MODEL
    <% } %>

<% var found_me      = 0;
   var my_ioaiu_id   = 0;
   var no_chi   = 0;


   for (var idx=0; idx < obj.AiuInfo.length; idx++) {
      if (obj.AiuInfo[idx].fnNativeInterface.indexOf("CHI") < 0) {
         if (obj.Id == idx) {
            found_me = 1;
         } else if (! found_me) {
            my_ioaiu_id ++;
         }   
      }
      if ((obj.AiuInfo[idx].fnNativeInterface == "CHI-A")||(obj.AiuInfo[idx].fnNativeInterface == "CHI-B")) {
      no_chi ++;
      }
   }
%>

<% var aiu_axiInt;
var aiu_NumCores ;
var aiu_rpn; 

if(obj.AiuInfo[obj.Id].interfaces.axiInt.length > 1) {
   aiu_axiInt = obj.AiuInfo[obj.Id].interfaces.axiInt[0];
   aiu_NumCores = obj.AiuInfo[obj.Id].interfaces.axiInt.length;
   aiu_rpn = obj.AiuInfo[obj.Id].rpn[0];
} else {
   aiu_axiInt = obj.AiuInfo[obj.Id].interfaces.axiInt;
   aiu_NumCores = 1;
   aiu_rpn = obj.AiuInfo[obj.Id].rpn;
}
%>

    svt_axi_master_transaction                         excl_rd[int][$]; 
class snps_snoop_response_seq extends svt_axi_ace_master_snoop_response_sequence;
     `uvm_object_param_utils(snps_snoop_response_seq)

function new(string name = "snps_snoop_response_seq");
    super.new(name);
endfunction : new

endclass

class snps_axi_master_read_seq extends svt_axi_master_base_sequence; 

    
    `uvm_object_param_utils(snps_axi_master_read_seq)
    `uvm_declare_p_sequencer(svt_axi_master_sequencer)

    realtime                                            time_t;
    svt_axi_master_transaction                          m_seq_item;
    svt_axi_master_transaction                          dvm_seq_item,dvm_cpy;
    svt_axi_master_transaction                          m_seq_item_rsp;
    svt_configuration get_cfg;
    static semaphore                                    m_rd;
 bit [63:0] start_addr;
  bit [63:0] end_addr;
 bit [63:0] start_addr_noncoh_q[$];
  bit [63:0] end_addr_noncoh_q[$];

 ncoreConfigInfo::intq noncoh_regionsq;
  ncoreConfigInfo::intq coh_regionsq;
  ncoreConfigInfo::intq iocoh_regionsq;
      addr_trans_mgr    m_addr_mgr;
      ncore_memory_map m_mem; 


    bit                                                 useFullCL;
    svt_axi_transaction::coherent_xact_type_enum        m_ace_rd_addr_chnl_snoop;
    bit                                                 is_coh;

    bit							is_DVMSyncOutStanding;
    bit                                                 is_DVMcomplete;
    bit							is_DvmSync;											
    bit                                                 is_force_single_dvm;
    bit                                                 is_force_multi_dvm;	
    bit                                                 m_constraint_snoop;
    bit                                                 lock;
    bit [`SVT_AXI_ADDR_WIDTH -2:0]                  m_ace_rd_addr_chnl_addr;
    bit [`SVT_AXI_MAX_ID_WIDTH -1:0]                    use_arid;
<% if (obj.wSecurityAttribute > 0) { %>                                             
    bit [<%=obj.wSecurityAttribute%>-1:0]               m_ace_rd_addr_chnl_security;
<% } %>                                                
    bit                                                 m_constraint_addr;
    bit                                                 should_randomize;
    bit                                                 m_constrain_cache;
    bit                                                 m_constrain_prot;
    bit                                                 m_constrain_domain;
    bit [2:0]                                           m_constrain_cache_type;
    bit 						m_constrain_axlen_256B;
    bit [1:0]                                           m_constrain_coh_noncoh_len;
    bit [1:0]                                           perf_noncoh_txn_size;
    bit [1:0]                                           perf_coh_txn_size;
    int incr_len,wrap_len,core;
    bit [1:0]                                           m_constrain_len;
    bit [<%=obj.nDCEs%>-1:0] AiuDce_connectivity_vec,exp_aiudce_connectivity_vec; 
    bit [<%=obj.nDMIs%>-1:0] AiuDmi_connectivity_vec,exp_aiudmi_connectivity_vec; 
    bit [<%=obj.nDIIs%>-1:0] AiuDii_connectivity_vec,exp_aiudii_connectivity_vec; 
    int fnmem_region_idx = 0;
    int FUnitId = 0;
    string unit_type = "";
    bit                                                 exclusive_access;
    bit                                                 multi_part_dvm;
   

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "snps_axi_master_read_seq");
    super.new(name);
    if(m_rd == null)
         m_rd = new(1);
  m_addr_mgr = addr_trans_mgr::get_instance();
   m_addr_mgr.gen_memory_map();
   m_mem = m_addr_mgr.get_memory_map_instance();
  noncoh_regionsq = m_mem.get_noncoh_mem_regions();
  iocoh_regionsq = m_mem.get_iocoh_mem_regions();
  coh_regionsq = m_mem.get_coh_mem_regions();
 foreach(iocoh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(iocoh_regionsq[indx], start_addr, end_addr);
        start_addr_noncoh_q.push_back(start_addr);
        end_addr_noncoh_q.push_back(end_addr);
 end
 foreach(noncoh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(noncoh_regionsq[indx], start_addr, end_addr);
        start_addr_noncoh_q.push_back(start_addr);
        end_addr_noncoh_q.push_back(end_addr);
 end

endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    bit success;
    AiuDce_connectivity_vec = 'h<%=obj.AiuInfo[obj.Id].hexAiuDceVec%>;//'
    AiuDmi_connectivity_vec = 'h<%=obj.AiuInfo[obj.Id].hexAiuDmiVec%>;//'
    AiuDii_connectivity_vec = 'h<%=obj.AiuInfo[obj.Id].hexAiuDiiVec%>;//'
    exp_aiudce_connectivity_vec = '1;//'
    exp_aiudmi_connectivity_vec = '1;//'
    exp_aiudii_connectivity_vec = '1;//'

    if(!(m_ace_rd_addr_chnl_snoop == svt_axi_transaction::CLEANINVALID || m_ace_rd_addr_chnl_snoop == svt_axi_transaction::CLEANSHARED))
        m_rd.get(1);
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
         `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end
    start_item(m_seq_item);
  //  m_seq_item.reasonable_bypass_cache_lookup.constraint_mode(0);      
//    m_seq_item.is_xact_for_snoop_data_transfer = 1;
    if (should_randomize) begin
`ifndef NOT_USE_INHOUSE_ACE_MODEL
    <% if(obj.testBench == "fsys") { %>
    <% } else { %>
      $display("READ ADDR is 0x%0h is_coh is %0d, trans is %s", m_ace_rd_addr_chnl_addr, is_coh,  m_ace_rd_addr_chnl_snoop);
    <% } %>
`endif
      if (m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READCLEAN          ||
          m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READNOTSHAREDDIRTY ||
          m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READSHARED         ||
          m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READUNIQUE         ||
          m_ace_rd_addr_chnl_snoop == svt_axi_transaction::CLEANUNIQUE        ||
          m_ace_rd_addr_chnl_snoop == svt_axi_transaction::MAKEUNIQUE         ||
          m_ace_rd_addr_chnl_snoop == svt_axi_transaction::CLEANSHARED        ||
          m_ace_rd_addr_chnl_snoop == svt_axi_transaction::CLEANINVALID       ||
          m_ace_rd_addr_chnl_snoop == svt_axi_transaction::MAKEINVALID        ||
          m_ace_rd_addr_chnl_snoop == svt_axi_transaction::CLEANSHAREDPERSIST
      ) begin 
         //alignment logic 
        int align=<%=(aiu_axiInt.params.wData/8 < 64)?aiu_axiInt.params.wData/8 : 64%>;
        m_ace_rd_addr_chnl_addr = (m_ace_rd_addr_chnl_addr/align)*align;
      end

        if((m_ace_rd_addr_chnl_addr[11:0] + ((<%=aiu_axiInt.params.wData/8%>)*<%=((aiu_axiInt.params.wData/8)<64)?64/(aiu_axiInt.params.wData/8):1%>)) >= 4096 )begin
       m_ace_rd_addr_chnl_addr[11:0] = m_ace_rd_addr_chnl_addr[11:0] - ((<%=aiu_axiInt.params.wData/8%>)*<%=((aiu_axiInt.params.wData/8)<64)?64/(aiu_axiInt.params.wData/8):1%>);  
       m_seq_item.burst_length = 1 ;
        end



<% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ %>
        create_len_for_connected_acess(m_ace_rd_addr_chnl_addr,<%=Math.log2(aiu_axiInt.params.wData/8)%>,incr_len,wrap_len);
        m_constrain_len=1;
<%}else{%>
  if(m_constraint_addr  == 1)begin
        FUnitId = ncoreConfigInfo::map_addr2dmi_or_dii(m_ace_rd_addr_chnl_addr,fnmem_region_idx);
    if( FUnitId inside {ncoreConfigInfo::dmi_ids}) begin
      unit_type = "DMI";
    end else if( FUnitId inside {ncoreConfigInfo::dii_ids}) begin
      unit_type = "DII";
    end 

    if((((AiuDce_connectivity_vec !=exp_aiudce_connectivity_vec) || (AiuDmi_connectivity_vec!=exp_aiudmi_connectivity_vec)) && unit_type == "DMI") || (((AiuDii_connectivity_vec!=exp_aiudii_connectivity_vec)) && unit_type == "DII") )begin
            create_len_for_connected_acess(m_ace_rd_addr_chnl_addr,<%=Math.log2(aiu_axiInt.params.wData/8)%>,incr_len,wrap_len);
            m_constrain_len=1;
    end
    end
<%}%>
        success = m_seq_item.randomize() with {
           port_cfg == cfg;
           if(burst_length != 0) burst_size == <%=Math.log2(aiu_axiInt.params.wData/8)%>; //CONC-8328
           burst_type != svt_axi_transaction::FIXED; //CONC-8304
    <% if(obj.testBench == "fsys") { %>
           //data_before_addr == 1;
           //reference_event_for_addr_valid_delay inside {svt_axi_transaction::FIRST_WVALID_DATA_BEFORE_ADDR ,svt_axi_transaction::FIRST_DATA_HANDSHAKE_DATA_BEFORE_ADDR};
  //    addr_valid_delay                       > k_addr_valid_delay; 
           addr_valid_delay                       > 1;
           //addr[5:0]  == 0;
           if (m_constraint_addr  == 1) addr[`SVT_AXI_ADDR_WIDTH -2:0] == m_ace_rd_addr_chnl_addr;
           addr / 4096 == (addr + ((1 << burst_size) * burst_length)) / 4096; 
    <% } %>
       //    bypass_cache_lookup == 1;          
        /*    if (is_DVMSyncOutStanding == 1) addr[14:12]inside {'b000, 'b001, 'b010, 'b011, 'b110};

           if (is_DVMSyncOutStanding== 0 && is_DvmSync) addr[14:12] == 'b100;
           if (is_force_single_dvm == 1)    addr[0] == 0;
           if (is_force_multi_dvm == 1)     addr[0] == 1;
           if (is_DVMcomplete == 1)         addr    == 'h0; */
    <% if(obj.testBench == "fsys") { %>
	   if(m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE && !is_DvmSync)addr[14:12] dist {'b000 := 7, 'b001 := 6 , 'b010 := 6 , 'b011 := 6 };
           if(m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE && is_DvmSync) addr[14:12] == 3'b100;
           //if(m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE && !is_DvmSync) addr[47:32] inside {['h0:'h1FFF],['h2000:'h9FFF],['hA000:'hFFFF]};
           if(m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE && !is_DvmSync) addr[23:16] dist {['h0:'h3F] := 5 ,['h40:'h7F] := 5 ,['h80:'hBF] := 5 ,['hC0:'hFF] := 5};
           if(m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE && !is_DvmSync) addr[31:24] dist {['h0:'h3F] := 5 ,['h40:'h7F] := 5 ,['h80:'hBF] := 5 ,['hC0:'hFF] := 5};
           if(m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE && !is_DvmSync && addr[14:12]=='b000){ addr[11:10] dist {'b00 := 5,'b01 := 5,'b10 := 5,'b11 := 5};
               addr[9:8] dist {'b00 := 5,'b10 := 5 ,'b11 := 5};
               addr[5:0] dist {'b100010 := 5,'b100001 := 5,'b100000 := 5,'b101001 := 5,'b110000 := 5,'b110001 := 5,'b111001 := 5,'b100101 := 5,'b101101 := 5};
           }

           if (m_constraint_snoop == 1) coherent_xact_type == m_ace_rd_addr_chnl_snoop;
           else { coherent_xact_type != svt_axi_transaction::DVMMESSAGE;
                  coherent_xact_type != svt_axi_transaction::DVMCOMPLETE; }
                if(exclusive_access==1){atomic_type == svt_axi_transaction::EXCLUSIVE;}
		else {atomic_type == svt_axi_transaction::NORMAL;}
<% } else { %> 
           if (m_constraint_snoop == 1) coherent_xact_type == m_ace_rd_addr_chnl_snoop;
<% }%>
    <% if(obj.testBench == "fsys") { %>
<% if ((obj.fnNativeInterface == "AXI4") ) { %>    
           xact_type == svt_axi_transaction::READ;          
<% } else { %> 
           data_before_addr == 1;
           reference_event_for_addr_valid_delay inside {svt_axi_transaction::FIRST_WVALID_DATA_BEFORE_ADDR ,svt_axi_transaction::FIRST_DATA_HANDSHAKE_DATA_BEFORE_ADDR};
           xact_type    == svt_axi_transaction::COHERENT;
<% }%>
          
    <% } else { %>
           if (m_constraint_addr  == 1) addr[`SVT_AXI_ADDR_WIDTH -2:0] == m_ace_rd_addr_chnl_addr;
    <% } %>
           if(useFullCL == 1) {force_xact_to_cache_line_size == 1;}
       //                                 id == use_arid;
        /*   if (m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READCLEAN ||
               m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READSHARED ||
               m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READNOTSHAREDDIRTY ||
               m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READUNIQUE) */
                     //force_to_invalid_state == 1;
      /*     if (m_ace_rd_addr_chnl_snoop == svt_axi_transaction::CLEANUNIQUE ||
               m_ace_rd_addr_chnl_snoop == svt_axi_transaction::MAKEUNIQUE ||
               m_ace_rd_addr_chnl_snoop == svt_axi_transaction::CLEANSHARED) */
                    // force_to_shared_state == 1;                    
//           reference_event_for_first_rvalid_delay == svt_axi_transaction::READ_ADDR_HANDSHAKE;
        	// for VZ bit - prefer to Section 4.4.3.3.9 table 4-16 of ConcertoCProtocol spec 
                if (m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READCLEAN          ||
                    m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READONCE         ||
                    m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READNOTSHAREDDIRTY   ||
                    m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READSHARED         ||
                    m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READUNIQUE          ||
                    m_ace_rd_addr_chnl_snoop == svt_axi_transaction::CLEANUNIQUE         ||
                    m_ace_rd_addr_chnl_snoop == svt_axi_transaction::MAKEUNIQUE          ||
                    m_ace_rd_addr_chnl_snoop == svt_axi_transaction::MAKEINVALID
                ) { 
    <% if(obj.testBench == "fsys") { %>
                    cache_type[0] == 1; 
    <% } else { %>
                    if(m_constrain_cache_type == 'b001){
                     cache_type[3:0] == 1;}
                    else if(m_constrain_cache_type == 'b010) {
                     cache_type[3:2] == 2'b11;}
		    else if(m_constrain_cache_type == 'b011){
                    cache_type[1] == 1'b1;} 
                    else if(m_constrain_cache_type == 'b100) {
                    cache_type[0] == 1'b0;}
                    else if(m_constrain_cache == 1) {cache_type == 4'hf;}
		    else if(m_constrain_cache_type == 'b111) {cache_type[3:1] == 0;}
		    else {
                    cache_type[0] == 1;} 
    <% } %>
                }
           if(m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READNOSNOOP) {
    <% if(obj.testBench == "fsys") { %>
                 if(exclusive_access==0)cache_type inside {0};
                 if(exclusive_access==1)cache_type inside {0,1,2,3};
               // domain_type == svt_axi_transaction::NONSHAREABLE;
                domain_type == svt_axi_transaction::SYSTEMSHAREABLE;
                if(m_constraint_addr==0)addr[`SVT_AXI_ADDR_WIDTH -2:0] inside {[start_addr_noncoh_q[0]: end_addr_noncoh_q[0]]};
        if(m_constrain_len==1 && burst_type == svt_axi_transaction::INCR)burst_length <= incr_len;
    <% } else { %>
                //cache_type inside {0,1,2,3};
                if(m_constrain_cache_type == 'b001){
                     cache_type[3:0] == 1;}
                    else if(m_constrain_cache_type == 'b010) {
                     cache_type[3:2] == 2'b11;}
		    else if(m_constrain_cache_type == 'b011){
                    cache_type[1] == 1'b1;} 
                    else if(m_constrain_cache_type == 'b100) {
                    cache_type[0] == 1'b0;}
                    else if(m_constrain_cache == 1) {cache_type == 4'hf;}
		    else if(m_constrain_cache_type == 'b111) {cache_type[3:1] == 0;}
		    else { cache_type inside {0,1,2,3}; }
                domain_type == svt_axi_transaction::NONSHAREABLE;
    <% } %>
                //atomic_type == svt_axi_transaction::NORMAL;
                //if(burst_type == svt_axi_transaction::WRAP){burst_length == <%=((aiu_axiInt.params.wData/8)<64)?64/(aiu_axiInt.params.wData/8):1%>;}
                if(burst_type == svt_axi_transaction::WRAP  && m_constrain_coh_noncoh_len == 0 && m_constrain_axlen_256B ==0 ){burst_length == <%=((aiu_axiInt.params.wData/8)<64)?64/(aiu_axiInt.params.wData/8):1%>;}
                else if(m_constrain_axlen_256B == 1) { burst_length == (256 / (2**burst_size)) - 1;}
                else if(m_constrain_coh_noncoh_len == 1) {burst_length == ((perf_noncoh_txn_size == 0)?((perf_noncoh_txn_size *8)/(2**burst_size)):1);}  
                burst_size == <%=Math.log2(aiu_axiInt.params.wData/8)%>;
//                lock      ==  <%=Math.log2(aiu_axiInt.params.arlock)%>;
           }
           else if(m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READONCE) {
                //atomic_type == svt_axi_transaction::NORMAL;
                //burst_length <= <%=((aiu_axiInt.params.wData/8)<64)?64/(aiu_axiInt.params.wData/8):1%>;
                if(m_constrain_domain ==1){ domain_type == svt_axi_transaction::NONSHAREABLE;}
               if(m_constrain_axlen_256B == 1) { burst_length == (256 / (2**burst_size)) - 1;}
                else { 
                burst_length <= <%=((aiu_axiInt.params.wData/8)<64)?64/(aiu_axiInt.params.wData/8):1%>;}
                burst_size == <%=Math.log2(aiu_axiInt.params.wData/8)%>;
//                lock      ==  <%=Math.log2(aiu_axiInt.params.arlock)%>;
           }
           else {
                //burst_length <= <%=((aiu_axiInt.params.wData/8)<64)?64/(aiu_axiInt.params.wData/8):1%>;
                 if(m_constrain_axlen_256B == 1) { burst_length == (256 / (2**burst_size)) - 1;}
                else if(m_constrain_coh_noncoh_len == 1) {burst_length == ((perf_noncoh_txn_size *8)/(2**burst_size)) - 1;}              
                else {
                burst_length <= <%=((aiu_axiInt.params.wData/8)<64)?64/(aiu_axiInt.params.wData/8):1%>;}
                //atomic_type == svt_axi_transaction::NORMAL;
                burst_size == <%=Math.log2(aiu_axiInt.params.wData/8)%>;
                if(cache_type inside {0,1})
                     burst_type == svt_axi_transaction::INCR;
`ifndef VCS
                solve cache_type before burst_type;
`endif                
                //if(is_coh == 1) domain_type inside {svt_axi_transaction::INNERSHAREABLE, svt_axi_transaction::OUTERSHAREABLE}; 
    <% if(obj.testBench == "fsys") { %>
                if(is_coh == 1) domain_type inside {svt_axi_transaction::INNERSHAREABLE}; 
    <% } else { %>
                if(is_coh == 1 && m_constrain_domain ==0 ) domain_type inside {svt_axi_transaction::INNERSHAREABLE, svt_axi_transaction::OUTERSHAREABLE}; 
                else if(m_constrain_domain ==1){ domain_type == svt_axi_transaction::NONSHAREABLE;}
    <% } %>
           }
`ifdef VCS
                solve cache_type before burst_type;
`endif                
                                                           
        };
    <% if(obj.testBench == "fsys") { %>
if(exclusive_access==1)begin
     excl_rd[core].push_back(m_seq_item);
     //m_seq_item.print();
end
     // $display("READ ADDR is 0x%0h is_coh is %0d, trans is %s", m_seq_item.addr, is_coh,  m_ace_rd_addr_chnl_snoop);
    `uvm_info("ADBG0", $sformatf("READ ADDR is 0x%0h is_coh is %0d, trans is %s xact %0s atomic %0s core %0d len %0d", m_seq_item.addr, is_coh, m_ace_rd_addr_chnl_snoop, m_seq_item.coherent_xact_type,m_seq_item.atomic_type,core, m_seq_item.burst_length),UVM_NONE);
if(m_seq_item.coherent_xact_type == svt_axi_transaction::DVMMESSAGE && m_seq_item.addr[0]==1)begin
 dvm_cpy=m_seq_item;
 multi_part_dvm=1;
//m_seq_item.print();
end
    <% } %>
         if(m_constrain_coh_noncoh_len == 1) begin
         //commenting below for CONC-8497
        //if (m_seq_item.burst_type == svt_axi_transaction::INCR) m_seq_item.burst_length = 255; /* ((perf_coh_txn_size *8)/(<%=(aiu_axiInt.params.wData)%>) -1 ); */
        end

        if (!success) begin
            uvm_report_error("SNPS RD AXI SEQ", $sformatf("TB Error: Could not randomize packet in snps_axi_master_read_seq"), UVM_NONE);
        end
      //  m_seq_item.rvalid_delay[0] = 5;
    end
    finish_item(m_seq_item);
if(multi_part_dvm==1)begin
  if(dvm_cpy.coherent_xact_type == svt_axi_transaction::DVMMESSAGE && dvm_cpy.addr[0]==1)begin
    `uvm_create(dvm_seq_item)
    assert(dvm_seq_item.randomize() with{ coherent_xact_type==svt_axi_transaction::DVMMESSAGE;
                                           id == dvm_cpy.id;
                                           addr[0]==0;
                                           addr[14:12]==dvm_cpy.addr[14:12];
    				       xact_type == svt_axi_transaction::COHERENT;
    });
    `uvm_info("ADBG0", $sformatf("2nd Part DVM ADDR is 0x%0h xact %0s atomic %0s core %0d ", dvm_seq_item.addr,dvm_seq_item.coherent_xact_type,dvm_seq_item.atomic_type,core),UVM_NONE);
    `uvm_send(dvm_seq_item)
  end
end 
 //   if(m_seq_item.phase_type == svt_axi_transaction::RD_ADDR) begin
         get_response(m_seq_item_rsp);
 //   end else begin
 //        m_seq_item_rsp = m_seq_item;
 //   end
endtask : body

task return_response(output svt_axi_master_transaction m_return_seq_item, input uvm_sequencer_base seqr, input uvm_sequence_base parent = null);
    this.start(seqr, parent);
    m_return_seq_item = m_seq_item_rsp;
endtask : return_response

endclass : snps_axi_master_read_seq

////////////////////////////////////////////////////////////////////////////////
class snps_axi_master_write_seq extends svt_axi_master_base_sequence;

    `uvm_object_param_utils(snps_axi_master_write_seq)
     `uvm_declare_p_sequencer(svt_axi_master_sequencer)

    svt_axi_master_transaction                          excl_wr;
    svt_axi_master_transaction                          m_seq_item;
    svt_axi_master_transaction                          m_seq_item_rsp;
    svt_configuration get_cfg;
    static semaphore                                    m_wr;
    svt_axi_transaction::coherent_xact_type_enum        m_ace_wr_addr_chnl_snoop;
    bit                                                 m_constraint_snoop;
    bit [`SVT_AXI_ADDR_WIDTH-2:0]                            m_ace_wr_addr_chnl_addr;
<% if (obj.wSecurityAttribute > 0) { %>                                             
    bit [<%=obj.wSecurityAttribute%>-1:0]               m_ace_wr_addr_chnl_security;
    svt_axi_transaction::prot_type_enum excl_prot_type;
<% } %>                                                
    bit                                                 m_constraint_addr;
    bit                                                 should_randomize;
    bit                                                 is_coh;
    bit [`SVT_AXI_CACHE_WIDTH - 1:0]                    excl_cache_type;
    svt_axi_transaction::burst_type_enum                excl_burst_type;
    bit [`SVT_AXI_MAX_BURST_LENGTH_WIDTH: 0] excl_burst_length;
 bit [63:0] start_addr;
  bit [63:0] end_addr;
 bit [63:0] start_addr_noncoh_q[$];
  bit [63:0] end_addr_noncoh_q[$];

 ncoreConfigInfo::intq noncoh_regionsq;
  ncoreConfigInfo::intq coh_regionsq;
  ncoreConfigInfo::intq iocoh_regionsq;
      addr_trans_mgr    m_addr_mgr;
      ncore_memory_map m_mem; 

    bit                                                 m_constraint_awunique;
    bit                                                 awunique;
    bit                                                 useFullCL;
    
    bit                                                 m_constrain_cache;
    bit                                                 m_constrain_prot;
    bit                                                 m_constrain_domain;
    bit [2:0]                                           m_constrain_cache_type;
    bit                                                 m_constrain_axlen_256B;
    bit [1:0]                                           m_constrain_coh_noncoh_len;
    bit [1:0]                                           m_constrain_len;
    bit [1:0]                                           perf_noncoh_txn_size;
    int                                                 perf_coh_txn_size;
    int incr_len,wrap_len,core;
    bit [<%=obj.nDCEs%>-1:0] AiuDce_connectivity_vec,exp_aiudce_connectivity_vec; 
    bit [<%=obj.nDMIs%>-1:0] AiuDmi_connectivity_vec,exp_aiudmi_connectivity_vec; 
    bit [<%=obj.nDIIs%>-1:0] AiuDii_connectivity_vec,exp_aiudii_connectivity_vec; 
    int fnmem_region_idx = 0;
    int FUnitId = 0;
    string unit_type = "";
    bit                                                 exclusive_access;
    bit                                                 excl_rd_exist;
    bit                                                 m_constraint_id;
    bit [`SVT_AXI_MAX_ID_WIDTH -1:0]                    excl_wr_id;
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------

function new(string name = "snps_axi_master_write_seq");
    super.new(name);
    if(m_wr == null)
         m_wr = new(1);
  m_addr_mgr = addr_trans_mgr::get_instance();
   m_addr_mgr.gen_memory_map();
   m_mem = m_addr_mgr.get_memory_map_instance();
  noncoh_regionsq = m_mem.get_noncoh_mem_regions();
  iocoh_regionsq = m_mem.get_iocoh_mem_regions();
  coh_regionsq = m_mem.get_coh_mem_regions();
 foreach(iocoh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(iocoh_regionsq[indx], start_addr, end_addr);
        start_addr_noncoh_q.push_back(start_addr);
        end_addr_noncoh_q.push_back(end_addr);
 end
 foreach(noncoh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(noncoh_regionsq[indx], start_addr, end_addr);
        start_addr_noncoh_q.push_back(start_addr);
        end_addr_noncoh_q.push_back(end_addr);
 end
  endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    bit success;
    AiuDce_connectivity_vec = 'h<%=obj.AiuInfo[obj.Id].hexAiuDceVec%>;//'
    AiuDmi_connectivity_vec = 'h<%=obj.AiuInfo[obj.Id].hexAiuDmiVec%>;//'
    AiuDii_connectivity_vec = 'h<%=obj.AiuInfo[obj.Id].hexAiuDiiVec%>;//'
    exp_aiudce_connectivity_vec = '1;//'
    exp_aiudmi_connectivity_vec = '1;//'
    exp_aiudii_connectivity_vec = '1;//'

    if(m_ace_wr_addr_chnl_snoop != svt_axi_transaction::WRITEBACK)
        m_wr.get(1);
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
         `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end
    m_seq_item         = svt_axi_master_transaction::type_id::create("m_seq_item");
//if(AiuDce_connectivity_vec=={<%=obj.nDCEs%>{1}} || AiuDmi_connectivity_vec=={<%=obj.nDMIs%>{1}} || AiuDii_connectivity_vec!={<%=obj.nDIIs%>{1}} )
    start_item(m_seq_item);
        m_seq_item.port_cfg = cfg;

//    m_seq_item.is_xact_for_snoop_data_transfer = 1;

 //   m_seq_item.ace_master_transaction_valid_ranges.constraint_mode(0);
`ifndef NOT_USE_INHOUSE_ACE_MODEL
    <% if(obj.testBench == "fsys") { %>
    <% } else { %>
    $display("WRITE ADDR is 0x%0h is_coh is %0d, trans is %s", m_ace_wr_addr_chnl_addr, is_coh, m_ace_wr_addr_chnl_snoop);
    <% } %>
`endif
    if(m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITEBACK)
    begin
           //  m_seq_item.print();
        m_seq_item.coherent_xact_type = svt_axi_transaction::WRITEBACK;
        m_seq_item.addr[`SVT_AXI_ADDR_WIDTH-2:0] = m_ace_wr_addr_chnl_addr;
        //m_seq_item.addr[`SVT_AXI_ADDR_WIDTH-1] = m_ace_wr_addr_chnl_security[0];
       // m_seq_item.force_to_invalid_state = 1;
       // m_seq_item.force_to_shared_state = 1;
        m_seq_item.is_unique = 0;
        m_seq_item.burst_length = 4;
        m_seq_item.burst_size = svt_axi_transaction::BURST_SIZE_128BIT;
        m_seq_item.burst_type = svt_axi_transaction::INCR;
        m_seq_item.cache_type = 2;
        m_seq_item.domain_type = svt_axi_transaction::INNERSHAREABLE;
        m_seq_item.xact_type = svt_axi_transaction::COHERENT;
        m_seq_item.atomic_type = svt_axi_transaction::NORMAL;
	m_seq_item.data = new[4];
        m_seq_item.wstrb = new[4];
        foreach(m_seq_item.data[i]) begin
              m_seq_item.data[i] = {$urandom,$urandom,$urandom,$urandom};
              m_seq_item.wstrb[i] = 16'hffff;
        end
    end
    else 
    if (should_randomize) begin
      if (m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITELINEUNIQUE ||
          m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITEEVICT      ||
          m_ace_wr_addr_chnl_snoop == svt_axi_transaction::EVICT
      ) begin 
         //alignment logic 
        int align=<%=(aiu_axiInt.params.wData/8 < 64)?aiu_axiInt.params.wData/8 : 64%>;
        m_ace_wr_addr_chnl_addr = (m_ace_wr_addr_chnl_addr/align)*align;
`ifndef NOT_USE_INHOUSE_ACE_MODEL
        $display("MODIFIED WRITE ADDR is 0x%0h is_coh is %0d, trans is %s", m_ace_wr_addr_chnl_addr, is_coh, m_ace_wr_addr_chnl_snoop);
`endif
      end
      //  m_seq_item.reasonable_bypass_cache_lookup.constraint_mode(0);      
        if((m_ace_wr_addr_chnl_addr[11:0] + ((<%=aiu_axiInt.params.wData/8%>)*<%=((aiu_axiInt.params.wData/8)<64)?64/(aiu_axiInt.params.wData/8):1%>)) >= 4096 )begin
       m_ace_wr_addr_chnl_addr[11:0] = m_ace_wr_addr_chnl_addr[11:0] - ((<%=aiu_axiInt.params.wData/8%>)*<%=((aiu_axiInt.params.wData/8)<64)?64/(aiu_axiInt.params.wData/8):1%>);  
       m_seq_item.burst_length = 1 ;
        end

<% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ %>
        create_len_for_connected_acess(m_ace_wr_addr_chnl_addr,<%=Math.log2(aiu_axiInt.params.wData/8)%>,incr_len,wrap_len);
        m_constrain_len=1;
<%}else{%>
if (m_constraint_addr  == 1)begin
        FUnitId = ncoreConfigInfo::map_addr2dmi_or_dii(m_ace_wr_addr_chnl_addr,fnmem_region_idx);
    if( FUnitId inside {ncoreConfigInfo::dmi_ids}) begin
      unit_type = "DMI";
    end else if( FUnitId inside {ncoreConfigInfo::dii_ids}) begin
      unit_type = "DII";
    end 

    if((((AiuDce_connectivity_vec !=exp_aiudce_connectivity_vec) || (AiuDmi_connectivity_vec!=exp_aiudmi_connectivity_vec)) && unit_type == "DMI") || (((AiuDii_connectivity_vec!=exp_aiudii_connectivity_vec)) && unit_type == "DII") )begin
            create_len_for_connected_acess(m_ace_wr_addr_chnl_addr,<%=Math.log2(aiu_axiInt.params.wData/8)%>,incr_len,wrap_len);
            m_constrain_len=1;
    end
    end
<%}%>
if(exclusive_access==1)begin
     if(excl_rd.exists(core))begin
       excl_wr=excl_rd[core][0];
       excl_wr.print();
       excl_rd_exist=1;
       excl_burst_length=excl_wr.burst_length;
       excl_burst_type=excl_wr.burst_type;
       excl_cache_type=excl_wr.cache_type;
<% if (obj.wSecurityAttribute > 0) { %>                                             
       excl_prot_type=excl_wr.prot_type;
<% } %>                                                
       m_ace_wr_addr_chnl_addr=excl_wr.addr;
       excl_wr_id = excl_wr.id; 
       m_constraint_id = 1;
     end
end
        success = m_seq_item.randomize() with {
           port_cfg == cfg;
           if(burst_length != 0) burst_size == <%=Math.log2(aiu_axiInt.params.wData/8)%>; //CONC-8328
           burst_type != svt_axi_transaction::FIXED; //CONC-8304
           //bypass_cache_lookup == 1;          
<% if(obj.testBench == "fsys") { %>
<% if ((obj.fnNativeInterface == "AXI4") ) { %>    
           xact_type == svt_axi_transaction::WRITE;          
<% } else { %>
           xact_type    == svt_axi_transaction::COHERENT;
<% }%> 
<% } else { %> 
<% if ((obj.fnNativeInterface == "AXI4") && (obj.NcMode == 1)) { %>    
           xact_type == WRITE;          
<% } else { %> 
           xact_type    == svt_axi_transaction::COHERENT;
<% }}%> 
    <% if(obj.testBench == "fsys") { %>
           if (m_constraint_snoop == 1) coherent_xact_type == m_ace_wr_addr_chnl_snoop;
           else { coherent_xact_type != svt_axi_transaction::DVMMESSAGE;
                  coherent_xact_type != svt_axi_transaction::DVMCOMPLETE; }
<% } else { %> 
           if (m_constraint_snoop == 1) coherent_xact_type == m_ace_wr_addr_chnl_snoop;
<% }%>
    <% if(obj.testBench == "fsys") { %>
   //        addr[`SVT_AXI_ADDR_WIDTH -2:0] inside {[start_addr_noncoh_q[0]: end_addr_noncoh_q[0]]};
           if (m_constraint_addr  == 1) addr[`SVT_AXI_ADDR_WIDTH-2:0] == m_ace_wr_addr_chnl_addr;
if(m_ace_wr_addr_chnl_snoop != svt_axi_transaction::EVICT){
   data_before_addr == 1;
           reference_event_for_addr_valid_delay inside {svt_axi_transaction::FIRST_WVALID_DATA_BEFORE_ADDR ,svt_axi_transaction::FIRST_DATA_HANDSHAKE_DATA_BEFORE_ADDR};
} else { data_before_addr == 0; }
           addr_valid_delay                       > 1; 
         //  addr[5:0]  == 0;
           addr / 4096 == (addr + ((1 << burst_size) * burst_length)) / 4096;
    <% } else { %>
           if (m_constraint_addr  == 1) addr[`SVT_AXI_ADDR_WIDTH-2:0] == m_ace_wr_addr_chnl_addr;
    <% } %>
           if(m_constraint_awunique == 1) is_unique == awunique;
           if(useFullCL == 1) {force_xact_to_cache_line_size == 1;}
//           reference_event_for_first_wvalid_delay == svt_axi_transaction::WRITE_ADDR_VALID;
         //  force_to_invalid_state == 1;
         //  force_to_shared_state == 1;
           if (m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITELINEUNIQUE || 
                     m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITEUNIQUE || 
                     m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITEEVICT || 
                     m_ace_wr_addr_chnl_snoop == svt_axi_transaction::EVICT  
              ) { 
   <% if(obj.testBench == "fsys") { %>
                     cache_type[1] == 1;}
                 if(exclusive_access==1 && excl_rd_exist==1){
                 burst_type == excl_burst_type;
                 burst_length == excl_burst_length;
                 cache_type == excl_cache_type;
                 id == excl_wr_id;
<% if (obj.wSecurityAttribute > 0) { %>                                             
                 prot_type == excl_prot_type;
<% } %>          }                                      
                 if(exclusive_access==1){
                 atomic_type == svt_axi_transaction::EXCLUSIVE;}
		 else {atomic_type == svt_axi_transaction::NORMAL;}
   <% } else { %> 
                  if(m_constrain_cache_type == 'b001)      {cache_type[3:0] == 1;}
                  else if(m_constrain_cache_type == 'b010) {cache_type[3:2] == 2'b11;}
                  else if(m_constrain_cache_type == 'b011) {cache_type[1] == 1'b1;} 
                  else if(m_constrain_cache_type == 'b100) {cache_type[0] == 1'b0;}
                  else if(m_constrain_cache == 1)          {cache_type == 4'hf;}
                  else if(m_constrain_cache_type == 'b111) {cache_type[3:1] == 0;}
                  else                                     {cache_type[0] == 1;}}
   <% } %> 
           if(m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITENOSNOOP ) {
    <% if(obj.testBench == "fsys") { %>
              //   cache_type inside {0,1,2,3};
                if(exclusive_access==0)cache_type inside {0};
                if(exclusive_access== 1 && excl_rd_exist==0)cache_type inside {0,1,2,3};
              //   domain_type == svt_axi_transaction::NONSHAREABLE;
                domain_type == svt_axi_transaction::SYSTEMSHAREABLE;
                if (m_constraint_addr  == 0)addr[`SVT_AXI_ADDR_WIDTH -2:0] inside {[start_addr_noncoh_q[0]: end_addr_noncoh_q[0]]};
        if(m_constrain_len==1 && burst_type == svt_axi_transaction::INCR && excl_rd_exist==0)burst_length <= incr_len;
    <% } else { %>
                 //cache_type inside {0,1,2,3};
                 if(m_constrain_cache_type == 'b001)      {cache_type[3:0] == 1;}
                 else if(m_constrain_cache_type == 'b010) {cache_type[3:2] == 2'b11;}
                 else if(m_constrain_cache_type == 'b011) {cache_type[1] == 1'b1;} 
                 else if(m_constrain_cache_type == 'b100) {cache_type[0] == 1'b0;}
                 else if(m_constrain_cache == 1)          {cache_type == 4'hf;}
                 else if(m_constrain_cache_type == 'b111) {cache_type[3:1] == 0;}
                 else                                     {cache_type inside {0,1,2,3};} 
                 domain_type == svt_axi_transaction::NONSHAREABLE;
    <% } %>
                 //atomic_type == svt_axi_transaction::NORMAL;
                 if(burst_type == svt_axi_transaction::WRAP){burst_length == <%=((aiu_axiInt.params.wData/8)<64)?64/(aiu_axiInt.params.wData/8):1%>;}
                 burst_size == <%=Math.log2(aiu_axiInt.params.wData/8)%>;       
           }
           else if(m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITEUNIQUE)  {
                 burst_length <= <%=((aiu_axiInt.params.wData/8)<64)?64/(aiu_axiInt.params.wData/8):1%>;
                 burst_size == <%=Math.log2(aiu_axiInt.params.wData/8)%>;
           }
           else {
                 burst_length <= <%=((aiu_axiInt.params.wData/8)<64)?64/(aiu_axiInt.params.wData/8):1%>;
                 //atomic_type == svt_axi_transaction::NORMAL;
                 if(cache_type inside {0,1})
                      burst_type == svt_axi_transaction::INCR;
                 burst_size == <%=Math.log2(aiu_axiInt.params.wData/8)%>;
`ifndef VCS
                 solve cache_type before burst_type;
`endif                
    <% if(obj.testBench == "fsys") { %>
                 if(is_coh == 1) domain_type inside {svt_axi_transaction::INNERSHAREABLE}; 
    <% } else { %>
                 if(is_coh == 1) domain_type inside {svt_axi_transaction::INNERSHAREABLE, svt_axi_transaction::OUTERSHAREABLE}; 
    <% } %>
           }
`ifdef VCS
                 solve cache_type before burst_type;
`endif                
                                                          
        };
    <% if(obj.testBench == "fsys") { %>
    $display("WRITE ADDR is 0x%0h is_coh is %0d, trans is %s xact %0s", m_seq_item.addr, is_coh, m_ace_wr_addr_chnl_snoop, m_seq_item.coherent_xact_type);
    `uvm_info("ADBG0", $sformatf("WRITE ADDR is 0x%0h is_coh is %0d, trans is %s xact %0s atomic %0s core %0d len %0d excl_prot_type %0s", m_seq_item.addr, is_coh, m_ace_wr_addr_chnl_snoop, m_seq_item.coherent_xact_type,m_seq_item.atomic_type,core, m_seq_item.burst_length,excl_prot_type),UVM_NONE);
    <% } %>
        if (!success) begin
            uvm_report_error("SNPS WR AXI SEQ", $sformatf("TB Error: Could not randomize packet in snps_axi_master_write_seq"), UVM_NONE);
        end
     //   m_seq_item.wvalid_delay[0] = 5;
    end
    finish_item(m_seq_item);
    get_response(m_seq_item_rsp);
    if(m_ace_wr_addr_chnl_snoop != svt_axi_transaction::WRITEBACK)
       m_wr.put(1);
endtask : body

task return_response(output svt_axi_master_transaction m_return_seq_item, input uvm_sequencer_base seqr, input uvm_sequence_base parent = null);
    this.start(seqr, parent);
    m_return_seq_item = m_seq_item_rsp;
endtask : return_response

function void txn_copy(axi_wr_seq_item s_txn);
   bit success; 
   svt_axi_transaction::coherent_xact_type_enum seq_xact_type;  
   case(s_txn.m_write_addr_pkt.awcmdtype)
     WRNOSNP : seq_xact_type = svt_axi_transaction::WRITENOSNOOP;
     WRUNQ   : seq_xact_type = svt_axi_transaction::WRITEUNIQUE;
     WRLNUNQ : seq_xact_type = svt_axi_transaction::WRITELINEUNIQUE;
     WRBK    : seq_xact_type = svt_axi_transaction::WRITEBACK;
     WRCLN   : seq_xact_type = svt_axi_transaction::WRITECLEAN;
     BARRIER : seq_xact_type = svt_axi_transaction::WRITEBARRIER;
     EVCT    : seq_xact_type = svt_axi_transaction::EVICT;
     WREVCT  : seq_xact_type = svt_axi_transaction::WRITEEVICT;
   endcase
   success = m_seq_item.randomize() with {
     addr         == s_txn.m_write_addr_pkt.awaddr;
     id           == s_txn.m_write_addr_pkt.awid;
     burst_length == s_txn.m_write_addr_pkt.awlen+1;
     burst_size   == s_txn.m_write_addr_pkt.awsize;
     burst_type   == s_txn.m_write_addr_pkt.awburst;
     xact_type    == svt_axi_transaction::COHERENT;
     atomic_type  == svt_axi_transaction::NORMAL;
     coherent_xact_type == seq_xact_type;
   };
   if(!success)`uvm_info("txn_copy", "randomization failed", UVM_NONE)
   `uvm_info("txn_copy", "in txn_copy", UVM_NONE)
endfunction : txn_copy
endclass : snps_axi_master_write_seq

class axi_master_base_seq extends uvm_sequence;
    
    `uvm_object_param_utils(axi_master_base_seq)

    typedef struct {
        ace_read_addr_pkt_t m_ace_read_addr_pkt;
        time                t_ace_read_addr_pkt;
    } read_addr_time_t;

    static semaphore s_rd   = new(1);

    static snps_axi_master_read_seq m_ott_q[$]; 
    static event            e_ott_q_del;
    static event e_delete_axid;
    static bit use_random_axid;
    static bit use_incrementing_axid;
    static bit axi_perf_mode;
    static bit use_full_cl = 0;
    static bit no_axid_collision = 0;
    static axi_arid_t axid_counter;
    static axi_arid_t axid_inuse_q[$];
    // To keep track of DVMs and Barrier AXIDs
    static axi_arid_t axid_unqinuse_q[$];
    // To keep track of Noncoh AXIDs
    <% if (obj.wNcAxIdSbCtr > 1) { %>
        static axi_arid_t axid_noncoh_inuse_q[$];
    <% } %>

    bit use_burst_incr;
    bit use_burst_wrap;
    bit iocache_perf_test = 0;
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
    function new(string name = "axi_master_base_seq");
        uvm_cmdline_processor clp;
        string arg_value; 
        super.new(name);
        clp = uvm_cmdline_processor::get_inst();
        clp.get_arg_value("+UVM_TESTNAME=", arg_value);
        if (arg_value == "concerto_inhouse_iocache_perf_test") begin
            iocache_perf_test = 1;
        end
        else begin
            iocache_perf_test = 0;
        end
        use_random_axid = (($urandom_range(0,100) < 75) && !$test$plusargs("incrementing_axid") && !$test$plusargs("axid_collision"));
        no_axid_collision = $test$plusargs("no_axid_collision");

        if (!use_random_axid && !$test$plusargs("axid_collision")) begin
            use_incrementing_axid = 1;
        end
        else begin
            if(!($test$plusargs("axid_collision"))) begin
                axi_perf_mode   = ($urandom_range(0,100) < 30);
            end
        end
        use_full_cl = $test$plusargs("use_full_cl");
        //FIXME: Please remove this guys once you are done with bringup 
        use_burst_wrap = $test$plusargs("use_burst_wrap");
        use_burst_incr = $test$plusargs("use_burst_incr");

        if (iocache_perf_test) begin
            axi_perf_mode = 1;
            use_incrementing_axid = 0;
            use_random_axid = 1;
        end
    endfunction : new

    // Task to support providing unique axids for all requests of cohsb or noncohsb are non-existent
    task get_axid(input ace_command_types_enum_t m_ace_cmd_type, output axi_arid_t use_axid, input bit firstReqDone = 1, input axi_arid_t force_this_axid = 0, input bit use_force_this_axid = 0);  
        // For coherent requests
        axi_arid_t tmp_axid;
        bit keep_axid = 0;
        bit done = 0;
        int m_tmp_q[$];
        use_axid = 0;
        if (use_random_axid) begin
            tmp_axid = $urandom_range(0,2**WARID-1);
        end
        else if (use_incrementing_axid) begin
            tmp_axid = axid_counter;
            axid_counter++;
            if (axid_counter == 2**WARID) begin
                axid_counter = 0;
            end
        end
        if (!firstReqDone && tmp_axid == 0) begin
            tmp_axid = 3;
        end
        do begin
            bit all_axids_used = 0;
            bit need_unq_axid = 0;
            int m_tmp_axid_q[$];
            m_tmp_axid_q = axid_inuse_q.unique_index();
            //`uvm_info("CHIRAGDBG", $sformatf("%p size %d axid_inuse_q %p use_force %0d force_axid 0x%0x", m_tmp_axid_q, m_tmp_axid_q.size(), axid_inuse_q, use_force_this_axid, force_this_axid), UVM_NONE)
            if (m_tmp_axid_q.size() >= (2**WARID)) begin
                all_axids_used = 1;
            end
            if (m_ace_cmd_type == BARRIER    || 
                m_ace_cmd_type == DVMMSG     || 
                m_ace_cmd_type == DVMCMPL    || 
                m_ace_cmd_type == ATMSTR     || 
                m_ace_cmd_type == ATMSWAP    ||
                m_ace_cmd_type == ATMLD      || 
                m_ace_cmd_type == ATMCOMPARE ||
            no_axid_collision) begin
                need_unq_axid = 1;
            end
            if (m_ace_cmd_type == RDNOSNP) begin
                <% if (obj.nNcAxIdSbEntries == 0) { %>
                    need_unq_axid = 1;
                <% } %>
            end
            else begin
                <%if (obj.nCohAxIdSbEntries == 0) { %>
                    need_unq_axid = 1;
                <% } %>
            end
            if (axi_perf_mode) begin
                need_unq_axid = 1;
            end
            // Checking to see if forced axid is already in use
            if (use_force_this_axid) begin
                m_tmp_axid_q = {};
                m_tmp_axid_q = axid_inuse_q.find_first_index with (item == force_this_axid);
                if (m_tmp_axid_q.size() > 0) begin
                    all_axids_used = 1;
                end 
            end
            m_tmp_q = {};
            m_tmp_q = axid_unqinuse_q.find_first_index with (item == tmp_axid);  
            if (m_tmp_q.size() > 0) begin
                need_unq_axid = 1;
            end
            if (need_unq_axid && all_axids_used) begin
                @e_delete_axid;
            end
            else begin
                done = 1;
                if (use_force_this_axid) begin
                    tmp_axid = force_this_axid;
                    // Sanity check to confirm force_this_axid is not in use
                    m_tmp_axid_q = {};
                    m_tmp_axid_q = axid_inuse_q.find_first_index with (item == force_this_axid);
                    if (m_tmp_axid_q.size() > 0) begin
                        `uvm_error("RD ARID Seq",$sformatf("TB Error: Trying to use ARID from sequence, but its found in inuse queue. force_this_axid 0x%0x axid_inuse_q %p", force_this_axid, axid_inuse_q))      
                    end
                end
                else if (need_unq_axid) begin
                    bit found = 0;
                    int m_tmp_qA[$];
                    int m_tmp_qB[$];
                    int count = 0;
                    randomize_helper_read x = new();
                    do begin
                        foreach (axid_inuse_q[i]) begin
                            x.queue_of_excluded_numbers.push_back(axid_inuse_q[i]);
                        end
                        x.randomize();
                        tmp_axid = x.randomized_number;
                        if (!firstReqDone && tmp_axid == 0) begin
                            tmp_axid = 3;
                        end
                        count++;
                        m_tmp_qA = {};
                        m_tmp_qA = axid_inuse_q.find_first_index with (item == tmp_axid);
                        m_tmp_qB = {};
                        m_tmp_qB = axid_unqinuse_q.find_first_index with (item == tmp_axid);
                        if (m_tmp_qA.size() == 0) begin
                            found = 1;
                            if (m_tmp_qB.size() > 0) begin
                                `uvm_error("RD ARID Seq",$sformatf("TB Error: Sanity check failed. ID chosen is in unique queue. axid_inuse_q %p axid_unqinuse_q %p ID chosen 0x%0x", axid_inuse_q, axid_unqinuse_q, tmp_axid))      
                            end
                        end
                        if (count > 100) begin
                            `uvm_error("RD ARID Seq",$sformatf("TB Error: Possible infinite loop. Taking too long to find axid. axid_inuse_q size %0d axid width %0d axid_inuse_q %p", axid_inuse_q.size(), WARID, axid_inuse_q))      
                        end
                    end while (!found);
                end
            end
        end while (!done);
        <% if (obj.wNcAxIdSbCtr > 1) { %>
            if (m_ace_cmd_type == RDNOSNP) begin
                if ($urandom_range(0,100) < 70 && axid_noncoh_inuse_q.size() > 0) begin
                    int tmp_index = $urandom_range(0,axid_noncoh_inuse_q.size());
                    tmp_axid = axid_noncoh_inuse_q[tmp_index];
                end
            end
        <% } %>
        //`uvm_info("CHIRAGDBG RD ARID Seq", $sformatf("Adding arid 0x%0x for snoop type %0s", tmp_axid, m_ace_cmd_type.name()), UVM_NONE)
        axid_inuse_q.push_back(tmp_axid);
        <% if (obj.wNcAxIdSbCtr > 1 && obj.nNcAxIdSbEntries > 0) { %>
            if (m_ace_cmd_type == RDNOSNP) begin
                axid_noncoh_inuse_q.push_back(tmp_axid);
            end
        <% } %>
        if (m_ace_cmd_type == BARRIER    || 
            m_ace_cmd_type == DVMMSG     || 
            m_ace_cmd_type == DVMCMPL    ||
            m_ace_cmd_type == ATMSTR     || 
            m_ace_cmd_type == ATMSWAP    ||
            m_ace_cmd_type == ATMLD      || 
            m_ace_cmd_type == ATMCOMPARE 
        ) begin
            axid_unqinuse_q.push_back(tmp_axid);
        end
        if (m_ace_cmd_type == RDNOSNP) begin
            <% if (obj.nNcAxIdSbEntries == 0) { %>
                axid_unqinuse_q.push_back(tmp_axid);
            <% } %>
        end
        else begin
            <%if (obj.nCohAxIdSbEntries == 0) { %>
                if (!(m_ace_cmd_type == BARRIER || m_ace_cmd_type == DVMMSG || m_ace_cmd_type == DVMCMPL)) begin
                    axid_unqinuse_q.push_back(tmp_axid);
                end
            <% } %>
        end
        use_axid = tmp_axid;
    endtask : get_axid

    task wait_till_arid_latest(snps_axi_master_read_seq m_axi_read_seq);
        int              m_tmp_q[$];

        m_axi_read_seq.time_t = $time;
        m_ott_q.push_back(m_axi_read_seq);
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with (item.m_seq_item.id == m_axi_read_seq.m_seq_item.id);
        if (m_tmp_q.size == 1) begin
            return;
        end
        else begin
            bit oldest;
            do begin
                oldest = 1;
                // Recalculating since m_ott_q has changed since last iteration of loop
                m_tmp_q = {};
                m_tmp_q = m_ott_q.find_index with (item.m_seq_item.id == m_axi_read_seq.m_seq_item.id);
                foreach (m_tmp_q[i]) begin
                    if (m_ott_q[m_tmp_q[i]].time_t < m_axi_read_seq.time_t) begin
                        oldest = 0;
                        break;
                    end
                end
                if (!oldest) begin
                    @e_ott_q_del;
                end
            end while (!oldest);
        end
    endtask : wait_till_arid_latest

    function void delete_axid_inuse(axi_arid_t arid);
        int m_tmp_q[$];

        m_tmp_q = {};
        m_tmp_q = axid_inuse_q.find_first_index with (item == arid);
        //`uvm_info("CHIRAGDBG RD AXID Seq", $sformatf("Deleting arid 0x%0x", m_ace_read_addr_pkt_tmp.arid), UVM_NONE)
        if (m_tmp_q.size == 0) begin
            `uvm_error("RD AXID Seq",$sformatf("TB Error: Trying to delete and axid even though its not in queue. Arid: 0x%0x Queue: %p", arid, axid_inuse_q))      
        end
        else begin
            axid_inuse_q.delete(m_tmp_q[0]);
            ->e_delete_axid;
        end
        <% if (obj.wNcAxIdSbCtr > 1) { %>
            m_tmp_q = {};
            m_tmp_q = axid_noncoh_inuse_q.find_first_index with (item == arid);
            if (m_tmp_q.size > 0) begin
                axid_noncoh_inuse_q.delete(m_tmp_q[0]);
            end
        <% } %>
        m_tmp_q = {};
        m_tmp_q = axid_unqinuse_q.find_first_index with (item == arid);
        if (m_tmp_q.size > 0) begin
            axid_unqinuse_q.delete(m_tmp_q[0]);
        end
    endfunction : delete_axid_inuse

    function void delete_ott_entry(snps_axi_master_read_seq m_axi_read_seq);
        int m_tmp_q[$];

        delete_axid_inuse(m_axi_read_seq.m_seq_item.id);
        m_tmp_q = {};
        m_tmp_q = m_ott_q.find_index with (item.m_seq_item.id == m_axi_read_seq.m_seq_item.id);
        if (m_tmp_q.size == 0) begin
            uvm_report_info("AXI SEQ ERROR", $sformatf("Printing ott_q entries size:%0d", m_ott_q.size()), UVM_NONE);
            foreach (m_ott_q[i]) begin
                uvm_report_info("AXI SEQ ERROR", $sformatf("Entry:%0d Value:%1p", i, m_ott_q[i]), UVM_NONE);
            end
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not find packet with arid: %0d address:0x%0x", m_axi_read_seq.m_seq_item.id, m_axi_read_seq.m_seq_item.addr), UVM_NONE);
        end
        else begin
            // Finding oldest entry to delete
            time t_temp;
            int  index_tmp;
            t_temp    = m_ott_q[m_tmp_q[0]].time_t;
            index_tmp = m_tmp_q[0];

            foreach (m_tmp_q[i]) begin
                if (t_temp > m_ott_q[m_tmp_q[i]].time_t) begin
                    t_temp    = m_ott_q[m_tmp_q[i]].time_t;
                    index_tmp = m_tmp_q[i];
                end
            end
            m_ott_q.delete(index_tmp);
            ->e_ott_q_del;
        end
    endfunction : delete_ott_entry
endclass : axi_master_base_seq

////////////////////////////////////////////////////////////////////////////////
class snps_axi_master_base_seq extends axi_master_base_seq;

    `uvm_object_param_utils(snps_axi_master_base_seq)

    snps_axi_master_read_seq            m_axi_read_seq;
    svt_axi_master_transaction          m_seq_item_rsp;
    svt_axi_master_sequencer            m_read_seqr;
    ace_cache_model                     m_ace_cache_model;
    ace_command_types_enum_t            ace_rd_addr_chnl_snoop;
    static semaphore s_rd   = new(1);
    int                         num_req;
    bit                         success;
    int                         m_tmp_q[$];
    addr_trans_mgr              m_addr_mgr;
    axi_bresp_t tmp_bresp[] = new[1];
    bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] sec_addr;
    bit is_coh = 0;
    axi_axaddr_t     tmp_wr_addr;
    aceState_t m_cache_state;
    bit m_constraint_awunique;
    int count;
    bit isDvmSync = 0;
    bit done = 0;
    int wt_ace_rd_bar_tmp;
    int wt_ace_dvm_msg_tmp;
    int wt_ace_dvm_sync_tmp;
    int force_single_dvm,force_multi_dvm;
    //Control Knobs
`ifdef PSEUDO_SYS_TB
    int wt_ace_rdnosnp      = 0;
`else
    int wt_ace_rdnosnp      = 5;
`endif

    int wt_ace_exclusive_rd = 0;
    int wt_ace_rdonce       = 5;
<% if (obj.fnNativeInterface == "ACE") { %>    
    int wt_ace_rdshrd       = 5;
    int wt_ace_rdcln        = 5;
    int wt_ace_rdnotshrddty = 5;
    int wt_ace_rdunq        = 5;
    int wt_ace_clnunq       = 5;
    int wt_ace_mkunq        = 5;
    // FIXME: Fix below weight to be non-zero
    int wt_ace_dvm_msg      = 0;
    int wt_ace_dvm_sync     = 0;
<% }  
else { %>    
    int wt_ace_rdshrd       = 0;
    int wt_ace_rdcln        = 0;
    int wt_ace_rdnotshrddty = 0;
    int wt_ace_rdunq        = 0;
    int wt_ace_clnunq       = 0;
    int wt_ace_mkunq        = 0;
    int wt_ace_dvm_msg      = 0;
    int wt_ace_dvm_sync     = 0;
<% } %>      
    int wt_ace_clnshrd       = 0;
    int wt_ace_clninvl       = 0;
    int wt_ace_mkinvl        = 0;
    int wt_ace_rd_cln_invld  = 0;
    int wt_ace_rd_make_invld = 0;
    int wt_ace_clnshrd_pers  = 0;
    int wt_ace_rd_bar        = 0; 
    int k_num_read_req      = 1;
    int k_access_boot_region = 0;
    int wt_illegal_op_addr   = 0;    
    int wt_not_illegal_op_addr   = 0;
    int is_illegal_op   = 0;
    int aiu_qos;
    
    // For directed test case purposes
    bit                                       use_addr_from_test = 0;
    bit                                       use_axcache_from_test = 0;
    bit [WAXADDR-1:0]          m_ace_rd_addr_from_test;
    <% if (obj.wSecurityAttribute > 0) { %>                                             
        bit [<%=obj.wSecurityAttribute%>-1:0] m_ace_rd_security_from_test;
    <% } %>                                                
    bit                                       m_ace_rd_two_line_multicl = 0;
 

    static bit firstReqDone         = 0;
    static int read_req_count       = 0;
    static int read_req_total_count = 0;
    static bit isDVMSyncOutStanding = 0;
    static bit sendDVMComplete      = 0;
    static int nDVMMSGCredit        = 256;
    //static bit sendDVMComplete      = 0;
    snps_axi_master_write_seq       m_axi_write_seq;
    svt_axi_master_sequencer        m_write_seqr;
    ace_command_types_enum_t        ace_wr_addr_chnl_snoop;
    static semaphore s_wr = new(1);
    static semaphore m_rd_dvm =new(1);
   
   int id;
    //Control Knobs
`ifdef PSEUDO_SYS_TB
    int wt_ace_wrnosnp = 0;
`else
    int wt_ace_wrnosnp = 5;
`endif
    int wt_ace_exclusive_wr = 0;

    // FIXME: Fix below weight to be non-zero
    int wt_ace_wrunq   = 5;
    int wt_ace_wrlnunq = 0;
    // FIXME: Fix below weights to be non-zero
    int wt_ace_wr_bar  = 0;

    // ACE_LITE_E operations
    int wt_ace_atm_str      = 0;
    int wt_ace_atm_ld       = 0;
    int wt_ace_atm_swap     = 0;
    int wt_ace_atm_comp     = 0;
    int wt_ace_ptl_stash    = 0;
    int wt_ace_full_stash   = 0;
    int wt_ace_shared_stash = 0;
    int wt_ace_unq_stash    = 0;
    int wt_ace_stash_trans  = 0;
    int wt_ace_wrbk         = 0;
    int wt_ace_wrcln       = 0;
    int wt_ace_evct        = 0;
    int wt_ace_wrevct      = 0;
    int k_num_write_req = 1;

    // For directed test case purposes
    bit                                     force_axlen_256B = 0; //
   // typedef bit [axiObj.WAXADDR-1:0] snps_axi_axaddr_t
    bit [WAXADDR-1-1:0] m_ace_wr_addr_from_test;
<% if (obj.wSecurityAttribute > 0) { %>                                             
    bit [<%=obj.wSecurityAttribute%>-1:0]   m_ace_wr_security_from_test;
<% } %>                                                
 
    static bit   req_sent = 0;
    static int   write_req_count = 0;
    static int   write_req_total_count = 0;
    static int   req_generation_count = 0;
    static bit   pwrmgt_power_down = 0;

    bit use_burst_incr;
    bit use_burst_wrap;

    int no_of_ones_in_a_byte=0;
    int ioaiu_force_axid; //newperf test force same axid on the transactions
    int en_force_axid;

    int perf_test;
    int perf_txn_size;
    int perf_coh_txn_size;    
    int perf_noncoh_txn_size;    
    int user_qos;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "snps_axi_master_base_seq");
    super.new(name);
     if($test$plusargs("DISABLE_INHOUSE_ACE_MODEL")) begin
      `define NOT_USE_INHOUSE_ACE_MODEL
       $display("NOT_USE_INHOUSE_ACE_MODEL snp_cust_seq");
       end
      else begin
      //$display("USE_INHOUSE_ACE_MODEL snp_cust_seq");
    <% if(obj.testBench != "fsys") { %>
       `undef NOT_USE_INHOUSE_ACE_MODEL
    <% } %>
      end
endfunction : new

task do_read();
             if($test$plusargs("perf_test")) begin
             perf_test = 1;
             end else begin
             perf_test = 0;
             end
           
            if(perf_txn_size !=0) begin
            perf_coh_txn_size = perf_txn_size;
            perf_noncoh_txn_size = perf_txn_size;
            end 
             `ifdef NOT_USE_INHOUSE_ACE_MODEL
            //  $display("NOT_USE_INHOUSE_ACE_MODEL snp_cust_seq...."); 
              `else
            //  $display ("USE_INHOUSE_ACE_MODEL");
              `endif 
             `ifndef NOT_USE_INHOUSE_ACE_MODEL
             if(m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE || m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMCOMPLETE) begin
                nDVMMSGCredit--;
                m_axi_read_seq.m_constraint_snoop = 1;
                //m_axi_read_seq.should_randomize   = 1;
                m_axi_read_seq.is_DVMSyncOutStanding           =isDVMSyncOutStanding ; 
                m_axi_read_seq.is_DvmSync                      = isDvmSync;
                m_axi_read_seq.is_force_multi_dvm                = force_single_dvm;
                 m_axi_read_seq.is_force_multi_dvm                = force_multi_dvm;
                  m_axi_read_seq.is_coh     = is_coh;
                  m_axi_read_seq.should_randomize   = 1;
                  if(m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMCOMPLETE)
                    m_axi_read_seq.is_DVMcomplete =1;
            end
            else begin
         //   get_axid(ace_rd_addr_chnl_snoop, m_axi_read_seq.use_arid, 1);
            m_axi_read_seq.m_constraint_snoop = 1;
            m_axi_read_seq.should_randomize   = 1;
            m_axi_read_seq.m_constraint_addr  = 1;
        /*   if(ace_rd_addr_chnl_snoop == RDNOSNP ||
           ace_rd_addr_chnl_snoop == RDONCE  ||
           ace_rd_addr_chnl_snoop == RDSHRD  ||
           ace_rd_addr_chnl_snoop == RDCLN   ||
           ace_rd_addr_chnl_snoop == RDNOTSHRDDIR ||
           ace_rd_addr_chnl_snoop == RDUNQ) */
          //  m_axi_read_seq.m_seq_item.phase_type         = svt_axi_master_transaction::RD_ADDR;
           	
            m_axi_read_seq.is_coh     = is_coh;
         /*   m_axi_read_seq.useFullCL      == ((use_addr_from_test & !m_ace_rd_two_line_multicl) || use_full_cl);
            m_axi_read_seq.use2FullCL     == (use_addr_from_test & m_ace_rd_two_line_multicl & ~use_full_cl);
            if (use_addr_from_test & m_ace_rd_two_line_multicl) m_axi_read_seq.arburst == AXIWRAP;

	    if(m_axi_read_seq.m_seq_item.burst_type == AXIWRAP) begin
	       m_axi_read_seq.m_seq_item.addr[WLOGXDATA-1:0] = 'h0;
	    end
        */

       // m_axi_read_seq.m_seq_item.reasonable_domain_based_addr_gen.constraint_mode(0);
      //  m_axi_read_seq.m_seq_item.reasonable_constraint_mode(0);
         end
         `endif

        `ifdef NOT_USE_INHOUSE_ACE_MODEL
          if(m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE || m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMCOMPLETE) begin
                nDVMMSGCredit--;
                m_axi_read_seq.m_constraint_snoop = 1;
                //m_axi_read_seq.should_randomize   = 1;
                m_axi_read_seq.is_DVMSyncOutStanding           =isDVMSyncOutStanding ; 
                m_axi_read_seq.is_DvmSync                      = isDvmSync;
                m_axi_read_seq.is_force_multi_dvm                = force_single_dvm;
                 m_axi_read_seq.is_force_multi_dvm                = force_multi_dvm;
                  m_axi_read_seq.is_coh     = is_coh;
                  m_axi_read_seq.should_randomize   = 1;
                  if(m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMCOMPLETE)
                    m_axi_read_seq.is_DVMcomplete =1;
            end
            else begin
         //   get_axid(ace_rd_addr_chnl_snoop, m_axi_read_seq.use_arid, 1);
            m_axi_read_seq.m_constraint_snoop = 1;
            m_axi_read_seq.should_randomize   = 1;
            m_axi_read_seq.m_constraint_addr  = 1;
        /*   if(ace_rd_addr_chnl_snoop == RDNOSNP ||
           ace_rd_addr_chnl_snoop == RDONCE  ||
           ace_rd_addr_chnl_snoop == RDSHRD  ||
           ace_rd_addr_chnl_snoop == RDCLN   ||
           ace_rd_addr_chnl_snoop == RDNOTSHRDDIR ||
           ace_rd_addr_chnl_snoop == RDUNQ) */
          //  m_axi_read_seq.m_seq_item.phase_type         = svt_axi_master_transaction::RD_ADDR;
           	
            m_axi_read_seq.is_coh     = is_coh;
         /*   m_axi_read_seq.useFullCL      == ((use_addr_from_test & !m_ace_rd_two_line_multicl) || use_full_cl);
            m_axi_read_seq.use2FullCL     == (use_addr_from_test & m_ace_rd_two_line_multicl & ~use_full_cl);
            if (use_addr_from_test & m_ace_rd_two_line_multicl) m_axi_read_seq.arburst == AXIWRAP;

	    if(m_axi_read_seq.m_seq_item.burst_type == AXIWRAP) begin
	       m_axi_read_seq.m_seq_item.addr[WLOGXDATA-1:0] = 'h0;
	    end
        */

       // m_axi_read_seq.m_seq_item.reasonable_domain_based_addr_gen.constraint_mode(0);
      //  m_axi_read_seq.m_seq_item.reasonable_constraint_mode(0);
         end
         `endif
 	  if(perf_test) begin
                if(force_axlen_256B)begin
                    //m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen = 256 / (2**m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsize) - 1;// 256B transfer for performance test       
		   m_axi_read_seq.m_constrain_axlen_256B =1;
                    /*
                    if ( (m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr + 
                    ((m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen+1) * (2**m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsize))) % 4096
                    <= m_read_addr_seq.m_seq_item.m_read_addr_pkt.araddr % 4096 ) begin
                        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen = 'h0 ;  // Limit burstsize to not cross 4kB boundary
                    end
                    */
                end else begin
					   if (m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READNOSNOOP) begin
				            m_axi_read_seq.perf_noncoh_txn_size = perf_noncoh_txn_size;
                                            m_axi_read_seq.m_constrain_coh_noncoh_len =1;			                                                                                            $display("perf_noncoh_txn_size is =%0d",perf_noncoh_txn_size);
				          end
                             //m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen = (((perf_noncoh_txn_size*8)/WXDATA) - 1); 
					   else  begin 
                                              m_axi_read_seq.perf_coh_txn_size = perf_coh_txn_size;
                                             m_axi_read_seq.m_constrain_coh_noncoh_len =1;
                                             $display("perf_coh_txn_size is =%0d",perf_coh_txn_size);	
				           end
                            // m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen = (((perf_coh_txn_size*8)/WXDATA) - 1);  
                end
          /*  m_read_addr_seq.m_seq_item.m_read_addr_pkt.arsize = WLOGXDATA;
            m_read_addr_seq.m_seq_item.m_read_addr_pkt.len_change_4k_boundary = 0;
            end
            if(m_read_addr_seq.m_seq_item.m_read_addr_pkt.len_change_4k_boundary) begin
                m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlen = 0;
            end */
            if(use_axcache_from_test) begin
                `uvm_info("AXI SEQ", $sformatf("use_axcache_from_test - araddr = 0x%0h", m_axi_read_seq.m_ace_rd_addr_chnl_addr), UVM_MEDIUM)
	        if(m_ace_cache_model.m_addr_mgr.get_addr_target_unit(m_axi_read_seq.m_ace_rd_addr_chnl_addr) == 0) begin
                   m_axi_read_seq.m_constrain_cache =1;
                   m_axi_read_seq.m_constrain_domain =1;
                   //$cast(m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache , 4'hf);
                   //$cast(m_read_addr_seq.m_seq_item.m_read_addr_pkt.ardomain , 'h0);
	           
	        end
            end
            else if(perf_test) begin
                       /* m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[0] = 1'b0;
                        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[1] = 1'b0; // secure access
                        m_read_addr_seq.m_seq_item.m_read_addr_pkt.arprot[2] = 1'b0; // Data access */
                        m_axi_read_seq.m_constrain_prot =1;
			m_axi_read_seq.m_constrain_cache_type = 'b001;
                        //m_read_addr_seq.m_seq_item.m_read_addr_pkt.arlock = axi_axlock_enum_t'(0);
                       // m_read_addr_seq.m_seq_item.m_read_addr_pkt.arbar = 0;
			
		          
				  // m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[3:0] = 1; // by default bufferable 
		            if (m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READNOSNOOP) begin:noncoh_rd_case
	                    if($test$plusargs("force_noncoh_allocate_txn")) m_axi_read_seq.m_constrain_cache_type = 'b010; 
		            if($test$plusargs("force_noncoh_cacheable_txn"))   m_axi_read_seq.m_constrain_cache_type = 'b011;
                  	    if($test$plusargs("force_noncoh_unbufferable_txn"))   m_axi_read_seq.m_constrain_cache_type = 'b100;       
            	            end:noncoh_rd_case	
                            else begin:coh_rd_case
	                    if($test$plusargs("force_coh_allocate_txn")) m_axi_read_seq.m_constrain_cache_type = 'b010;  
	                    if($test$plusargs("force_coh_cacheable_txn"))   m_axi_read_seq.m_constrain_cache_type = 'b011; 
                  	    if($test$plusargs("force_coh_unbufferable_txn")) m_axi_read_seq.m_constrain_cache_type = 'b100;
	                    end:coh_rd_case 
                    
                           if($test$plusargs("force_allocate_txn"))     m_axi_read_seq.m_constrain_cache_type = 'b010;  
	                   if($test$plusargs("force_cacheable_txn"))   m_axi_read_seq.m_constrain_cache_type = 'b011;  
                  	   if($test$plusargs("force_unbufferable_txn"))  m_axi_read_seq.m_constrain_cache_type = 'b100;  
            end		// end perf_test										   
            if($test$plusargs("k_axcache_0_to_dii")) begin
	        if(m_ace_cache_model.m_addr_mgr.get_addr_target_unit(m_axi_read_seq.m_ace_rd_addr_chnl_addr) == 1) begin
                      m_axi_read_seq.m_constrain_cache_type = 'b111;
	            //m_read_addr_seq.m_seq_item.m_read_addr_pkt.arcache[3:1] = 3'b000;
                end
	    end       
          end

         m_axi_read_seq.m_seq_item         = svt_axi_master_transaction::type_id::create("m_seq_item");
         m_axi_read_seq.return_response(m_seq_item_rsp, m_read_seqr);
       //  if (m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE || m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMCOMPLETE ) begin
            //m_rd_dvm.put(1);
       //  end
    m_axi_read_seq.m_rd.put(1);
         m_axi_read_seq.m_ace_rd_addr_chnl_addr     =  m_axi_read_seq.m_seq_item.addr;
   if (m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMCOMPLETE) begin
            sendDVMComplete = 0;
   end

   if (m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE &&
            m_axi_read_seq.m_seq_item.addr[14:12] == 'b100
        ) begin
            isDVMSyncOutStanding = 1;
        end

   if(m_axi_read_seq.m_seq_item.is_coherent_xact_dropped == 0) begin
         `ifndef  NOT_USE_INHOUSE_ACE_MODEL
        if (!(m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE  ||
              m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMCOMPLETE)
        ) begin
            sec_addr = m_axi_read_seq.m_ace_rd_addr_chnl_addr;
<%    if (obj.wSecurityAttribute > 0) { %>
            sec_addr[ncoreConfigInfo::W_SEC_ADDR - 1] = m_axi_read_seq.m_ace_rd_addr_chnl_security;
<%    } %>
	    m_addr_mgr.set_addr_in_agent_mem_map(sec_addr, <%=obj.AiuInfo[obj.Id].FUnitId%>);
            m_ace_cache_model.update_addr(ace_rd_addr_chnl_snoop, m_axi_read_seq.m_ace_rd_addr_chnl_addr
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    ,.security(m_axi_read_seq.m_ace_rd_addr_chnl_security)
                <% } %>
            );
         end
         `endif
       `ifdef NOT_USE_INHOUSE_ACE_MODEL
        //$display("NOT_USE_INHOUSE_ACE_MODEL");
        `else begin
        m_tmp_q = {};
        m_tmp_q = m_ace_cache_model.m_ort.find_index with (item.isRead == 1
            && item.m_addr == m_axi_read_seq.m_ace_rd_addr_chnl_addr
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                && item.m_security == m_axi_read_seq.m_ace_rd_addr_chnl_security
            <% } %>
        && item.isReqInFlight == 0);
        if (m_tmp_q.size > 0) begin
            m_ace_cache_model.m_ort[m_tmp_q[0]].isReqInFlight = 1;
        end
       end
      `endif //1206
        if (m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE &&
            m_axi_read_seq.m_seq_item.addr[0] == 1
        ) begin

            svt_axi_master_transaction   m_seq_item_tmp;
            snps_axi_master_read_seq     m_read_addr_seq_tmp;
            nDVMMSGCredit--;
            m_read_addr_seq_tmp                                                                            = snps_axi_master_read_seq::type_id::create("m_read_addr_seq_tmp");
            m_read_addr_seq_tmp.m_constraint_snoop                                                         = 1;
            m_read_addr_seq_tmp.m_constraint_addr                                                          = 0;
            m_read_addr_seq_tmp.should_randomize                                                           = 1;
            m_read_addr_seq_tmp.m_seq_item                                                                 = svt_axi_master_transaction::type_id::create("m_seq_item_tmp");
            m_read_addr_seq_tmp.m_seq_item.do_copy(m_axi_read_seq.m_seq_item);
            m_read_addr_seq_tmp.m_seq_item.addr[WAXADDR-1:16] = $urandom;
            m_read_addr_seq_tmp.m_seq_item.addr[2:0]                                       = 0;
            m_read_addr_seq_tmp.return_response(m_seq_item_tmp,m_read_seqr);
        end
        if(m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE) begin
            nDVMMSGCredit++;
        end
        if (m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE &&
            m_axi_read_seq.m_seq_item.addr[0] == 1
        ) begin
            snps_axi_master_read_seq m_read_data_seq_tmp;
	    svt_axi_master_transaction   m_seq_item;
            m_read_data_seq_tmp                  = snps_axi_master_read_seq::type_id::create("m_read_data_seq_tmp");
            m_read_data_seq_tmp.m_seq_item       = m_seq_item;
            m_read_data_seq_tmp.should_randomize = 0;
            m_read_data_seq_tmp.return_response(m_seq_item, m_read_seqr);
            nDVMMSGCredit++;
        end

        // m_axi_read_seq.m_rd.put(1);

     //   wait_till_arid_latest(m_axi_read_seq);

    /*    if(ace_rd_addr_chnl_snoop == RDNOSNP ||
           ace_rd_addr_chnl_snoop == RDONCE  ||
           ace_rd_addr_chnl_snoop == RDSHRD  ||
           ace_rd_addr_chnl_snoop == RDCLN   ||
           ace_rd_addr_chnl_snoop == RDNOTSHRDDIR ||
           ace_rd_addr_chnl_snoop == RDUNQ) 
        begin
            m_axi_read_seq.should_randomize   = 0;
            m_axi_read_seq.m_seq_item.phase_type         = svt_axi_master_transaction::RD_DATA;

            m_axi_read_seq.return_response(m_seq_item_rsp, m_read_seqr);
        end*/
      //  delete_ott_entry(m_axi_read_seq);
         `ifdef NOT_USE_INHOUSE_ACE_MODEL
          //$display("NOT_USE_INHOUSE_ACE_MODEL");
          `else begin
        <% if (obj.fnNativeInterface == "ACE") { %>    
        if (!(m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE  ||
              m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMCOMPLETE)
        ) begin
            bit [CBRESP-1:0] m_tmp_bresp[];
            m_tmp_bresp = new[m_seq_item_rsp.coh_rresp.size()];
            foreach (m_tmp_bresp[i]) begin
                m_tmp_bresp[i] = m_seq_item_rsp.coh_rresp[i][CRRESP-1:0];
            end
            $display("Shared bit is %0d, Dirty bit is %0d, addr is %h", m_seq_item_rsp.coh_rresp[0][1], m_seq_item_rsp.coh_rresp[0][0], m_seq_item_rsp.addr);
            m_ace_cache_model.modify_cache_line(m_seq_item_rsp.addr, ace_rd_addr_chnl_snoop, m_tmp_bresp, m_seq_item_rsp.data, , m_seq_item_rsp.burst_size,m_seq_item_rsp.coh_rresp[0][1], m_seq_item_rsp.coh_rresp[0][0], ((m_seq_item_rsp.atomic_type == svt_axi_transaction::EXCLUSIVE) ? (m_seq_item_rsp.rresp[0][1:0] == svt_axi_transaction::EXOKAY) : 1),.axdomain(m_seq_item_rsp.domain_type)
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,.security(m_axi_read_seq.m_ace_rd_addr_chnl_security)
<% } %>                                                
            );
        end
<% } else { %>
        //informing address manager that response for cacheline is received
        //For all NCB's this logic will be triggered and we evict on response
        sec_addr = m_axi_read_seq.m_seq_item.addr;
<%    if (obj.wSecurityAttribute > 0) { %>                                             
        sec_addr[ncoreConfigInfo::W_SEC_ADDR - 1] = m_axi_read_seq.m_ace_rd_addr_chnl_security;
<%    } %>
        if (!(m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE  ||
              m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMCOMPLETE)
        ) begin
        m_addr_mgr.addr_evicted_from_agent(
            <%=obj.AiuInfo[obj.Id].FUnitId%>, 1, sec_addr);
        end
<% } %>
else begin
    $display("READ dropped ADDR is %h, trans is %0d", m_axi_read_seq.m_seq_item.addr, m_axi_read_seq.m_seq_item.coherent_xact_type);
end
end
`endif //1270
end
endtask : do_read
  
task do_write();
       if($test$plusargs("perf_test")) begin
       perf_test = 1;
       end else begin
       perf_test = 0;
       end

       if(perf_txn_size !=0) begin
       perf_coh_txn_size = perf_txn_size;
       perf_noncoh_txn_size = perf_txn_size;
       end 

        `ifndef NOT_USE_INHOUSE_ACE_MODEL
        m_cache_state = m_ace_cache_model.current_cache_state(m_axi_write_seq.m_ace_wr_addr_chnl_addr
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    ,m_axi_write_seq.m_ace_wr_addr_chnl_security
                <% } %>                                                
            );

  if (ace_wr_addr_chnl_snoop == WRUNQ ||
                ace_wr_addr_chnl_snoop == WRLNUNQ
            ) begin
                if (m_cache_state == ACE_UC ||
                m_cache_state == ACE_SC) begin
<% if (obj.useAceUniquePort > 0) { %>
                    m_axi_write_seq.awunique = $urandom_range(0,1);
                    m_axi_write_seq.m_constraint_awunique = 1;
<% } else { %>
                    m_axi_write_seq.awunique = 0;
                    m_axi_write_seq.m_constraint_awunique = 1;
<% } %>
                end
<% if (obj.useAceUniquePort > 0) { %>
                else begin
                    m_axi_write_seq.awunique = 1;
                    m_axi_write_seq.m_constraint_awunique = 1;
                end
<% } %>
            end
            else if (ace_wr_addr_chnl_snoop == WRBK) begin 
                if (m_cache_state == ACE_SD) begin
                    m_axi_write_seq.awunique = 0;
                    m_axi_write_seq.m_constraint_awunique = 1;
                end
            end

        m_axi_write_seq.m_constraint_snoop        = 1;
        m_axi_write_seq.m_constraint_addr         = 1;
        m_axi_write_seq.should_randomize          = 1;
        m_axi_write_seq.is_coh        = is_coh;
        `endif
        `ifdef NOT_USE_INHOUSE_ACE_MODEL
         m_axi_write_seq.m_constraint_snoop        = 1;
        m_axi_write_seq.m_constraint_addr         = 1;
        m_axi_write_seq.should_randomize          = 1;
        m_axi_write_seq.is_coh        = is_coh;
        `endif
         if(use_axcache_from_test) begin
                `uvm_info("AXI SEQ", $sformatf("use_axcache_from_test - awaddr = 0x%0h", m_axi_write_seq.m_ace_wr_addr_chnl_addr), UVM_MEDIUM)
	        if(m_addr_mgr.get_addr_target_unit(m_axi_write_seq.m_ace_wr_addr_chnl_addr) == 0) begin // no dii
                   if(m_ace_cache_model.m_addr_mgr.get_addr_target_unit( m_axi_write_seq.m_ace_wr_addr_chnl_addr) == 0) begin
                    m_axi_write_seq.m_constrain_cache =1;
                    m_axi_write_seq.m_constrain_domain =1;
	        end
            end
          end
            else if(perf_test) begin
          		//m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlock =  axi_axlock_enum_t'(0); 
                       /* m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[2] = 1'b0 ; //Unprivileged access
                        m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1] = 1'b0 ; //secure access
                        m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[0] =  1'b0; // Data access
                        m_write_addr_seq.m_seq_item.m_write_addr_pkt.awbar = 0; */
                         m_axi_write_seq.m_constrain_prot =1;
			m_axi_write_seq.m_constrain_cache_type = 'b001;
  		       //m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcache[3:0] = 1; // bufferable by default
	                 if(m_axi_write_seq.m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITENOSNOOP) begin:noncoh_wr_case
	                     if($test$plusargs("force_noncoh_allocate_txn")) m_axi_write_seq.m_constrain_cache_type = 'b010; 
		            if($test$plusargs("force_noncoh_cacheable_txn"))   m_axi_write_seq.m_constrain_cache_type = 'b011;
                  	    if($test$plusargs("force_noncoh_unbufferable_txn"))   m_axi_write_seq.m_constrain_cache_type = 'b100;       
            	            end:noncoh_wr_case	
                            else begin:coh_wr_case
	                    if($test$plusargs("force_coh_allocate_txn")) m_axi_write_seq.m_constrain_cache_type = 'b010;  
	                    if($test$plusargs("force_coh_cacheable_txn"))   m_axi_write_seq.m_constrain_cache_type = 'b011; 
                  	    if($test$plusargs("force_coh_unbufferable_txn")) m_axi_write_seq.m_constrain_cache_type = 'b100;
	                    end:coh_wr_case 
                         end
                  if($test$plusargs("k_axcache_0_to_dii")) begin
	          if(m_addr_mgr.get_addr_target_unit(m_axi_write_seq.m_ace_wr_addr_chnl_addr) == 1) begin
	            m_axi_write_seq.m_constrain_cache_type = 3'b111;
	           end
	           end
  
                 if ((perf_test == 1)&&(m_axi_write_seq.m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITEUNIQUE)) begin
                if(force_axlen_256B)begin 
                  //  m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen = 256 / (2**m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize) - 1;// 256B transfer for performance test
                    m_axi_write_seq.m_constrain_axlen_256B =1;
                    /*
                    if ( (m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr + 
                    ((m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen+1) * (2**m_write_addr_seq.m_seq_item.m_write_addr_pkt.awsize))) % 4096
                        <= m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr % 4096 ) begin
                        m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen = 'h0 ;  // Limit burstsize to not cross 4kB boundary
                    end
                    */
                end else begin
                 	   if (m_axi_write_seq.m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITENOSNOOP) begin
                             //m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen = (((perf_noncoh_txn_size*8)/WXDATA) - 1);  // 64B transfer for performance test
		              m_axi_write_seq.perf_noncoh_txn_size = perf_noncoh_txn_size;
                              m_axi_write_seq.m_constrain_coh_noncoh_len =1;
			  end	
                          else begin
                            //m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen = (((perf_coh_txn_size*8)/WXDATA) - 1);  // 64B transfer for performance test
 			    m_axi_write_seq.perf_coh_txn_size = perf_coh_txn_size;
                            //$display("perf_coh_txn_size is =%0d",perf_coh_txn_size);
                            m_axi_write_seq.m_constrain_coh_noncoh_len =1;
		          end
                end
               end


m_axi_write_seq.m_seq_item                 = svt_axi_master_transaction::type_id::create("m_seq_item");
 m_axi_write_seq.return_response(m_seq_item_rsp, m_write_seqr);
`ifndef NOT_USE_INHOUSE_ACE_MODEL
if(m_axi_write_seq.m_seq_item.is_coherent_xact_dropped == 1)
begin
    $display("WRITE dropped ADDR is %h", m_axi_write_seq.m_seq_item.addr);
end
else begin
if(ace_wr_addr_chnl_snoop == WRBK) begin
                    m_tmp_q = {};
                    m_tmp_q = m_ace_cache_model.m_ort.find_index with (item.isRead == 0 &&
                        (item.m_cmdtype == WRBK || 
                            item.m_cmdtype == WREVCT ||
                            item.m_cmdtype == EVCT ||
                        item.m_cmdtype == WRCLN)
                    && item.isReqInFlight == 0);
                    for (int i = m_tmp_q.size - 1; i >=0;i--) begin
                        m_ace_cache_model.m_ort.delete(m_tmp_q[i]);
                        ->m_ace_cache_model.e_ort_delete;
                    end
end
else begin
 m_ace_cache_model.update_addr(ace_wr_addr_chnl_snoop, m_axi_write_seq.m_seq_item.addr, 0, tmp_wr_addr
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    ,.security(m_axi_write_seq.m_ace_wr_addr_chnl_security)
                <% } %>
            );
            sec_addr = m_axi_write_seq.m_seq_item.addr;
<%    if (obj.wSecurityAttribute > 0) { %>
            sec_addr[ncoreConfigInfo::W_SEC_ADDR - 1] = m_axi_write_seq.m_ace_wr_addr_chnl_security;
<%    } %>
	    m_addr_mgr.set_addr_in_agent_mem_map(sec_addr, <%=obj.AiuInfo[obj.Id].FUnitId%>);

        m_tmp_q = {};
        m_tmp_q = m_ace_cache_model.m_ort.find_index with (item.isRead == 0
            && item.isUpdate == 0
            && item.m_addr == m_axi_write_seq.m_seq_item.addr
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                && item.m_security == m_axi_write_seq.m_ace_wr_addr_chnl_security 
            <% } %>
        && item.isReqInFlight == 0);
        if (m_tmp_q.size > 0) begin
            m_ace_cache_model.m_ort[m_tmp_q[0]].isReqInFlight = 1;
        end

        tmp_bresp[0] = m_seq_item_rsp.bresp;
    <% if (obj.fnNativeInterface == "ACE") { %>    
        if (m_axi_write_seq.m_ace_wr_addr_chnl_snoop != svt_axi_transaction::WRITEBARRIER) begin
            if (m_axi_write_seq.m_ace_wr_addr_chnl_snoop == svt_axi_transaction::EVICT) begin
                axi_xdata_t wdata[];
                m_ace_cache_model.modify_cache_line(m_axi_write_seq.m_ace_wr_addr_chnl_addr, ace_wr_addr_chnl_snoop, tmp_bresp, wdata,.axdomain(m_axi_write_seq.m_seq_item.domain_type)
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,.security(m_axi_write_seq.m_ace_wr_addr_chnl_security)
<% } %>                                                
                );
            end
            else begin
                m_ace_cache_model.modify_cache_line(m_axi_write_seq.m_ace_wr_addr_chnl_addr, ace_wr_addr_chnl_snoop, tmp_bresp, m_axi_write_seq.m_seq_item.data , m_axi_write_seq.m_seq_item.burst_type, m_axi_write_seq.m_seq_item.burst_size,.awunique(m_axi_write_seq.m_seq_item.is_unique),.axdomain(m_axi_write_seq.m_seq_item.domain_type)
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,.security(m_axi_write_seq.m_ace_wr_addr_chnl_security)
<% } %>                                                
                );
            end
        end
<% } else { %> 
 //informing address manager that response for cacheline is received
        //For all NCB's this logic will be triggered and we evict on response
      
        sec_addr = m_axi_write_seq.m_ace_wr_addr_chnl_addr;
<%    if (obj.wSecurityAttribute > 0) { %>                                             
        sec_addr[ncoreConfigInfo::W_SEC_ADDR - 1] = m_axi_write_seq.m_ace_wr_addr_chnl_security;
<%    } %>
        m_addr_mgr.addr_evicted_from_agent(
            <%=obj.AiuInfo[obj.Id].FUnitId%>, 1, sec_addr);
 <% } %>
end
end
`endif
endtask : do_write

function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_addr_for_domain(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr,end_addr,int agentid,int core_id,bit is_rdnosnp);
  int primary_bits[$] = ncoreConfigInfo::mp_aiu_intv_bits[agentid].pri_bits;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] new_addr,addr;
    bit check_addr_unconnected = 0;
    bit [2:0] unit_unconnect = 0;
   int timeout;
   if(primary_bits.size()>0)
     primary_bits.sort();
  timeout=500;
  do begin
    timeout -=1;
    //new_addr = $urandom_range(start_addr,end_addr);
     std::randomize(new_addr) with { new_addr inside {[start_addr:end_addr]};};
   if(!is_rdnosnp) new_addr[5:0] = 0;

    foreach (primary_bits[j]) begin
      new_addr[primary_bits[j]]=core_id[j];
    end

    check_addr_unconnected = ncoreConfigInfo::check_unmapped_add(new_addr, agentid, unit_unconnect);

  end while(((new_addr>end_addr) || (new_addr < start_addr) ||(check_addr_unconnected)) && (timeout !=0) );

  if(timeout==0)
    `uvm_error("get_addr_for_domain", $sformatf("Timeout! Failed to randomize address"))
    
    return new_addr;
endfunction

endclass : snps_axi_master_base_seq 



    function void create_len_for_connected_acess(bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr,int size,output int incr_len,output int wrap_len);
    int native_core_id,core_id,temp_len;
    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr_n;
    bit [2:0] unit_unconnected;
    bit unconnected_access, native_unconnected_access,len_found;
    int timeout;
    
      
                ncoreConfigInfo::extract_intlv_bits_in_addr(ncoreConfigInfo::mp_aiu_intv_bits[<%=obj.DutInfo.FUnitId%>].pri_bits, addr, core_id);
    timeout =500;
              `uvm_info("create_len_for_connected_acess", $sformatf("size %0d addr %0h",size,addr),UVM_LOW)
   temp_len=0;
   len_found=0;
   do begin
      timeout -=1;
      if(temp_len==0)begin
        native_core_id=core_id;
        native_unconnected_access=0;
      end
      temp_len++;
      addr_n= addr+(temp_len*(1<<size));
                 //`uvm_info("create_len_for_connected_acess", $sformatf(" adddr_n %0h temp_len %0d len_foun %0d", addr_n,temp_len,len_found),UVM_LOW)
      unconnected_access = ncoreConfigInfo::check_unmapped_add(addr_n,<%=obj.DutInfo.FUnitId%>,unit_unconnected);
      ncoreConfigInfo::extract_intlv_bits_in_addr(ncoreConfigInfo::mp_aiu_intv_bits[<%=obj.DutInfo.FUnitId%>].pri_bits, addr_n, core_id);

      if (unconnected_access != native_unconnected_access || core_id != native_core_id) begin
        if(temp_len != 0) incr_len = temp_len;
        if (temp_len >= 16) begin
            wrap_len = 16;
        end else if (temp_len >= 8) begin
            wrap_len = 8;
        end else if (temp_len >= 4) begin
            wrap_len = 4;
        end else if (temp_len >= 2) begin
            wrap_len = 2;
        end else begin
            wrap_len = 1;
        end
        len_found=1; 
                if (unconnected_access != native_unconnected_access) begin
                    `uvm_info("create_len_for_connected_acess","Due to unconnected access",UVM_LOW)
                 end else begin
                    `uvm_info("create_len_for_connected_acess", "Due to Core txn length limit",UVM_LOW)
                 end
                 `uvm_info("create_len_for_connected_acess", $sformatf("LEN have been decided to %0d wrap_len %0d incr_len %0d", temp_len,wrap_len,incr_len),UVM_LOW)
      end
      
   end while(!len_found && (temp_len <= 256) && timeout !=0);    
   if(temp_len>256)begin
      incr_len=255;
            wrap_len = 8;
   end

  if(timeout==0)
    `uvm_error("create_len_for_connected_acess", $sformatf("Timeout! Failed to find len"))

    endfunction : create_len_for_connected_acess 


class snps_axi_master_read_all_seq extends snps_axi_master_base_seq;

    `uvm_object_param_utils(snps_axi_master_read_all_seq)
    
    svt_axi_port_configuration mst_cfg[<%=aiu_NumCores%>];
      int core,master_id;
    bit [`SVT_AXI_ADDR_WIDTH-2:0]                     coh_addr,noncoh_addr,exclusive_addr;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "snps_axi_master_read_all_seq");
    super.new(name);
        if($test$plusargs("DISABLE_INHOUSE_ACE_MODEL")) begin
      `define NOT_USE_INHOUSE_ACE_MODEL
       $display("NOT_USE_INHOUSE_ACE_MODEL snp_cust_seq");
       end
      else begin
      //$display("USE_INHOUSE_ACE_MODEL snp_cust_seq");
    <% if(obj.testBench != "fsys") { %>
       `undef NOT_USE_INHOUSE_ACE_MODEL
    <% } %>
       end
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------


task body;
    $display("snps_axi_master_read_all_seq body start");

    m_addr_mgr = addr_trans_mgr::get_instance();
    num_req = 0;

<% for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
      if(!uvm_config_db#(svt_axi_port_configuration)::get(null, "*", "port_cfg_ioaiu<%=my_ioaiu_id%>_<%=k%>", mst_cfg[<%=k%>]))begin
        `uvm_error("m_axi_read_seq","Port config is not properly set for master <%=my_ioaiu_id%>");
      end
    <% } %>

    m_axi_read_seq = snps_axi_master_read_seq::type_id::create("m_axi_read_seq"); 
   // snps_axi_master_write_noncoh_seq m_tmp_write_seq = axi_master_write_noncoh_seq::type_id::create("m_tmp_write_seq");
   if($test$plusargs("force_single_dvm")) begin
	force_single_dvm = 1;
	force_multi_dvm = 0;
    end
    if($test$plusargs("force_multi_dvm")) begin
	force_single_dvm = 0;
	force_multi_dvm = 1;
    end

    do begin
            if (k_num_read_req == 1) begin
                read_req_count++;
            end
            
           // wt_ace_rd_bar_tmp = (m_wr_bar_seq_item_q.size() > 0 || m_tmp_write_seq.m_rd_bar_seq_item_q.size() > 0 || m_tmp_write_seq.write_req_count >= m_tmp_write_seq.write_req_total_count*0.9) ? 0 : wt_ace_rd_bar;
            wt_ace_dvm_msg_tmp = (nDVMMSGCredit > 1) ? wt_ace_dvm_msg : 0;
            wt_ace_dvm_sync_tmp = (nDVMMSGCredit > 1) ? wt_ace_dvm_sync : 0;

            count = 0;
            do begin
                if (sendDVMComplete == 1) begin
                m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::DVMCOMPLETE;
                ace_rd_addr_chnl_snoop = DVMCMPL;
                end 
                else begin
                    randcase
                        wt_ace_rdnosnp       : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READNOSNOOP;
                                                     ace_rd_addr_chnl_snoop = RDNOSNP; 
                                               end
                        wt_ace_rdonce        : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READONCE;
                                                     ace_rd_addr_chnl_snoop = RDONCE;
                                               end
                        wt_ace_rdshrd        : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READSHARED;
                                                     ace_rd_addr_chnl_snoop = RDSHRD;
                                               end
                        wt_ace_rdcln         : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READCLEAN;
                                                     ace_rd_addr_chnl_snoop = RDCLN;
                                               end
                        wt_ace_rdnotshrddty  : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READNOTSHAREDDIRTY;
                                                     ace_rd_addr_chnl_snoop = RDNOTSHRDDIR;
                                               end
                        wt_ace_rdunq         : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READUNIQUE;
                                                     ace_rd_addr_chnl_snoop = RDUNQ;
                                               end
                        wt_ace_clnunq        : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::CLEANUNIQUE;
                                                     ace_rd_addr_chnl_snoop = CLNUNQ;
                                               end
                        wt_ace_mkunq         : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::MAKEUNIQUE;
                                                     ace_rd_addr_chnl_snoop = MKUNQ;
                                               end
                        wt_ace_clnshrd       : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::CLEANSHARED;
                                                     ace_rd_addr_chnl_snoop = CLNSHRD;
                                               end 
                        wt_ace_clninvl       : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::CLEANINVALID;
                                                     ace_rd_addr_chnl_snoop = CLNINVL;   
                                               end 
                        wt_ace_mkinvl        : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::MAKEINVALID;
                                                     ace_rd_addr_chnl_snoop = MKINVL;
                                               end
                        wt_ace_rd_cln_invld  : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READONCECLEANINVALID;
                                                     ace_rd_addr_chnl_snoop = RDONCECLNINVLD;
                                               end
                        wt_ace_rd_make_invld : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READONCEMAKEINVALID;
                                                     ace_rd_addr_chnl_snoop = RDONCEMAKEINVLD;
                                               end
                        wt_ace_clnshrd_pers  : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::CLEANSHAREDPERSIST;
                                                     ace_rd_addr_chnl_snoop = CLNSHRDPERSIST;
                                               end
<% if ((obj.fnNativeInterface == "AXI4") ) { %>    
                        wt_ace_exclusive_rd  : begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READNOSNOOP;
                                                     m_axi_read_seq.exclusive_access = 1;
                                               end
<% }%> 
                     <% if(obj.DutInfo.cmpInfo.nDvmMsgInFlight > 0) { %>
                        
                        wt_ace_dvm_msg_tmp      :begin m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::DVMMESSAGE;
		        			      ace_rd_addr_chnl_snoop = DVMMSG;
 		        			end
		        wt_ace_dvm_sync_tmp     :begin
		             m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::DVMMESSAGE;
                              ace_rd_addr_chnl_snoop = DVMMSG; 
		             isDvmSync = 1;
		        end
                    <% } %>

                    endcase
                    //m_axi_read_seq.m_ace_rd_addr_chnl_snoop = svt_axi_transaction::READNOSNOOP;
                    // ace_rd_addr_chnl_snoop = RDNOSNP; 
                    end
                     `ifdef NOT_USE_INHOUSE_ACE_MODEL begin
                      //$display("NOT_USE_INHOUSE_ACE_MODEL");
                      done = 1;
                      end
                      `else begin 
                     if (m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMMESSAGE || m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::DVMCOMPLETE ) begin
//                     m_rd_dvm.get(1);
                    done = 1;
                    end 
                    else begin
	            if(k_access_boot_region == 1) begin
	               use_addr_from_test = 1;
                       if(m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READNOSNOOP) begin
                          m_ace_rd_addr_from_test = m_ace_cache_model.m_addr_mgr.get_noncohboot_addr(<%=obj.DutInfo.FUnitId%>, 1);
		       end else begin
                          m_ace_rd_addr_from_test = m_ace_cache_model.m_addr_mgr.get_cohboot_addr(<%=obj.DutInfo.FUnitId%>, 1);
                       end
                       <% if (obj.wSecurityAttribute > 0) { %>                                             
	                           m_ace_rd_security_from_test = 0;
                       <% } %>            
                    end                                    
                    done  = m_ace_cache_model.give_addr_for_ace_req_read(ace_rd_addr_chnl_snoop, m_axi_read_seq.m_ace_rd_addr_chnl_addr
                            <% if (obj.wSecurityAttribute > 0) { %>                                             
                                ,m_axi_read_seq.m_ace_rd_addr_chnl_security
                            <% } %>
                            ,is_coh
                            ,use_addr_from_test, m_ace_rd_addr_from_test
                            <% if (obj.wSecurityAttribute > 0) { %>                                             
                            ,m_ace_rd_security_from_test
                            <% } %>                                                
                     );
                     count++;
                     if (count > 50) begin
                        uvm_report_error("ACE BFM SEQ AIU <%=my_ioaiu_id%>", $sformatf("TB Error: Infinite loop possibility in read seq do-while loop"), UVM_NONE);
                     end
                     end
                     end `endif //1537
core = 0;
<% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
  if( master_id ==<%=aiu_rpn+k-no_chi%> )begin
    core =<%=k%>; 
  end
<% }} %>                                                
     
      if(m_axi_read_seq.m_ace_rd_addr_chnl_snoop == svt_axi_transaction::READNOSNOOP)m_axi_read_seq.m_ace_rd_addr_chnl_addr= m_addr_mgr.get_noncoh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, core);
      else m_axi_read_seq.m_ace_rd_addr_chnl_addr = get_addr_for_domain(mst_cfg[core].innershareable_start_addr[0],mst_cfg[core].innershareable_end_addr[0],<%=obj.DutInfo.FUnitId%>,core,0);
      m_axi_read_seq.core = core;

     
            end while (!done);

            if(ace_rd_addr_chnl_snoop == CLNINVL || ace_rd_addr_chnl_snoop == CLNSHRD)
                begin
                      m_axi_write_seq = snps_axi_master_write_seq::type_id::create("m_axi_write_seq");
                      m_axi_write_seq.m_ace_wr_addr_chnl_snoop = svt_axi_transaction::WRITEBACK; 
                      `ifdef NOT_USE_INHOUSE_ACE_MODEL
                      //$display("NOT_USE_INHOUSE_ACE_MODEL");
                     `else
                      ace_wr_addr_chnl_snoop = WRBK;
                     `endif //1580 
                      m_axi_write_seq.m_ace_wr_addr_chnl_security = m_axi_read_seq.m_ace_rd_addr_chnl_security;
                      m_axi_write_seq.m_ace_wr_addr_chnl_addr = (m_axi_read_seq.m_ace_rd_addr_chnl_addr/64)*64;
                      m_axi_write_seq.is_coh = 1;

                      m_axi_read_seq.m_rd.get(1);
                      do_write();
                end 

            do_read();

        num_req++;
    end while (num_req < k_num_read_req);

    `uvm_info("body", "Exiting...", UVM_LOW)
endtask : body

endclass : snps_axi_master_read_all_seq

///////////////////////////////////////////////////////////////////////////////

class snps_axi_master_write_noncoh_seq extends snps_axi_master_base_seq;

    `uvm_object_param_utils(snps_axi_master_write_noncoh_seq)
    `uvm_declare_p_sequencer(svt_axi_system_sequencer)
    svt_configuration get_cfg;
    svt_axi_system_configuration sys_cfg;
    svt_axi_port_configuration mst_cfg[<%=aiu_NumCores%>];
      int core,master_id;
    
    bit [`SVT_AXI_ADDR_WIDTH-2:0]                     coh_addr,noncoh_addr,exclusive_addr;
    
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "snps_axi_master_write_noncoh_seq");
    super.new(name);
    //FIXME: Please remove this guys once you are done with bringup 
    use_burst_wrap = $test$plusargs("use_burst_wrap");
    use_burst_incr = $test$plusargs("use_burst_incr");
    user_qos = 0;
        if($test$plusargs("DISABLE_INHOUSE_ACE_MODEL")) begin
      `define NOT_USE_INHOUSE_ACE_MODEL
       $display("NOT_USE_INHOUSE_ACE_MODEL snp_cust_seq");
       end
      else begin
      //$display("USE_INHOUSE_ACE_MODEL snp_cust_seq");
    <% if(obj.testBench != "fsys") { %>
       `undef NOT_USE_INHOUSE_ACE_MODEL
    <% } %>
      end

endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;


m_addr_mgr = addr_trans_mgr::get_instance();
 num_req = 0;

<% for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
      if(!uvm_config_db#(svt_axi_port_configuration)::get(null, "*", "port_cfg_ioaiu<%=my_ioaiu_id%>_<%=k%>", mst_cfg[<%=k%>]))begin
        `uvm_error("m_axi_read_seq","Port config is not properly set for master <%=my_ioaiu_id%>");
      end
    <% } %>

m_axi_write_seq = snps_axi_master_write_seq::type_id::create("m_axi_write_seq");

do begin

        //axi_awid_t use_awid;
      

             randcase
                wt_ace_wrnosnp      : begin m_axi_write_seq.m_ace_wr_addr_chnl_snoop = svt_axi_transaction::WRITENOSNOOP;
 	        			    ace_wr_addr_chnl_snoop = WRNOSNP;
	        		      end
                wt_ace_wrunq        : begin m_axi_write_seq.m_ace_wr_addr_chnl_snoop = svt_axi_transaction::WRITEUNIQUE;
 	        			    ace_wr_addr_chnl_snoop = WRUNQ;
	        		      end
                wt_ace_wrlnunq      : begin m_axi_write_seq.m_ace_wr_addr_chnl_snoop = svt_axi_transaction::WRITELINEUNIQUE;
 	        			    ace_wr_addr_chnl_snoop = WRLNUNQ;
	        		      end
<% if ((obj.fnNativeInterface == "AXI4") ) { %>    
                wt_ace_exclusive_wr  : begin m_axi_write_seq.m_ace_wr_addr_chnl_snoop = svt_axi_transaction::WRITENOSNOOP;
                                             m_axi_write_seq.exclusive_access = 1;
                                       end
<% }%> 
           endcase 
            //m_axi_write_seq.m_ace_wr_addr_chnl_snoop = svt_axi_transaction::WRITENOSNOOP;
 	    //    			    ace_wr_addr_chnl_snoop = WRNOSNP;
            `ifndef NOT_USE_INHOUSE_ACE_MODEL 
            if(k_access_boot_region == 1) begin
		    use_addr_from_test = 1;
		    if(m_axi_write_seq.m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITENOSNOOP) begin
	               m_ace_wr_addr_from_test = m_ace_cache_model.m_addr_mgr.get_noncohboot_addr(<%=obj.DutInfo.FUnitId%>, 1);
                    end else begin
	               m_ace_wr_addr_from_test = m_ace_cache_model.m_addr_mgr.get_cohboot_addr(<%=obj.DutInfo.FUnitId%>, 1);
                    end
<% if (obj.wSecurityAttribute > 0) { %>                                             
	            m_ace_wr_security_from_test = 0;					    
<% } %>
                end
                 m_ace_cache_model.give_addr_for_ace_req_noncoh_write(ace_wr_addr_chnl_snoop, m_axi_write_seq.m_ace_wr_addr_chnl_addr
                    <% if (obj.wSecurityAttribute > 0) { %>                                             
                        ,m_axi_write_seq.m_ace_wr_addr_chnl_security
                    <% } %>
                    ,is_coh
                    ,use_addr_from_test, m_ace_wr_addr_from_test
<% if (obj.wSecurityAttribute > 0) { %>                                             
    ,m_ace_wr_security_from_test
<% } %>                                                
 
                );
              `endif //1647
core = 0;
<% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
  if( master_id ==<%=aiu_rpn+k-no_chi%> )begin
    core =<%=k%>; 
  end
<% }} %>                                                
     
      if(m_axi_write_seq.m_ace_wr_addr_chnl_snoop == svt_axi_transaction::WRITENOSNOOP)m_axi_write_seq.m_ace_wr_addr_chnl_addr= m_addr_mgr.get_noncoh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>,1, core);
      else m_axi_write_seq.m_ace_wr_addr_chnl_addr = get_addr_for_domain(mst_cfg[core].innershareable_start_addr[0],mst_cfg[core].innershareable_end_addr[0],<%=obj.DutInfo.FUnitId%>,core,0);
      m_axi_write_seq.core = core;
           do_write();

        write_req_count++;
        num_req++;
    end while (num_req < k_num_write_req);

    `uvm_info("body", "Exiting...", UVM_LOW)
endtask : body
endclass : snps_axi_master_write_noncoh_seq

<% if (obj.fnNativeInterface == "ACE") { %>    
<% var this_aiu_id = obj.Id; 
if (obj.NctiAgent === 1) {
    this_aiu_id = obj.Id + obj.AiuInfo.length + obj.BridgeAiuInfo.length;
}
%>
class snps_axi_master_write_coh_seq extends axi_master_write_base_seq;

    `uvm_object_param_utils(snps_axi_master_write_coh_seq)
    
    svt_axi_master_sequencer            m_write_seqr;
    //axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    //axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    //axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;
    ace_cache_model               m_ace_cache_model;
    axi_wr_seq_item               m_seq_item;
    static bit                    pwrmgt_power_down;
    static bit                    pwrmgt_power_down_done;
    static bit                    dont_ever_kill_seq = 0;

    typedef struct {
        ace_command_types_enum_t m_cmd_type;
        axi_axaddr_t             m_addr;
        <% if (obj.wSecurityAttribute > 0) { %>                                             
            bit [<%=obj.wSecurityAttribute%>-1:0]           m_security;
        <% } %>                                                
        axi_wr_seq_item                                     m_seq_item;
    } wr_req_t;

    typedef struct {
        axi_xdata_t m_data[];
        axi_wr_seq_item                        m_seq_item;
    } wr_dat_t;

    typedef struct {
        axi_axaddr_t   m_addr;
        <% if (obj.wSecurityAttribute > 0) { %>                                             
            bit [<%=obj.wSecurityAttribute%>-1:0] m_security;
        <% } %>                                                
        axi_xdata_t    m_data[];
    } wr_addr_data_t;

    event e_axi_wr_data_add_q;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "snps_axi_master_write_coh_seq");
    super.new(name);
        if($test$plusargs("DISABLE_INHOUSE_ACE_MODEL")) begin
      `define NOT_USE_INHOUSE_ACE_MODEL
       $display("NOT_USE_INHOUSE_ACE_MODEL snp_cust_seq");
       end
      else begin
     // $display("USE_INHOUSE_ACE_MODEL snp_cust_seq");
    <% if(obj.testBench != "fsys") { %>
       `undef NOT_USE_INHOUSE_ACE_MODEL
    <% } %>
      end
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    // FIXME: Note:
    // The coherent write sequence does NOT generate barriers. When Concerto will
    // add support for ACE agents sending barriers, we need to evaluate whether
    // we need barriers between coherent requests or not. If we do, then I should
    // add some support in this sequence to send barriers.

    wr_req_t m_axi_wr_req_q[$];
    wr_dat_t m_axi_wr_dat_q[$];
    wr_addr_data_t m_axi_wr_addr_data_q[$];
    axi_wr_seq_item m_axi_wr_rsp_q[$];
    bit firstReqDone                            = 0;
    bit last_access_done                        = 0;
    snps_axi_master_read_all_seq m_tmp_read_seq          = snps_axi_master_read_all_seq::type_id::create("m_tmp_read_seq");
    snps_axi_master_write_noncoh_seq m_tmp_write_seq = snps_axi_master_write_noncoh_seq::type_id::create("m_tmp_write_seq");
    bit sequence_done                           = 0;
    bit write_addr_done                         = 0;
    bit gen_req_done                            = 0;
    int count_outstanding_requests              = 0;
    event event_sequence_done;  // VS


                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here 0", UVM_NONE);
    fork
        begin : sequence_done_check
            int tmp_rd_count, tmp_wr_count;
            forever begin
                tmp_rd_count = m_tmp_read_seq.read_req_count;
                tmp_wr_count = m_tmp_write_seq.write_req_count;
		sequence_done = !dont_ever_kill_seq && ((m_tmp_write_seq.write_req_count >= m_tmp_write_seq.write_req_total_count)&& 
                (m_tmp_read_seq.read_req_count >= m_tmp_read_seq.read_req_total_count));
            uvm_report_info("CHIRAG<%=this_aiu_id%>", $sformatf("read count %0d total read count %0d write count %0d total write count %0d", m_tmp_read_seq.read_req_count, m_tmp_read_seq.read_req_total_count, m_tmp_write_seq.write_req_count, m_tmp_write_seq.write_req_total_count), UVM_LOW);
                if (sequence_done) begin
                    uvm_report_info("CHIRAG<%=this_aiu_id%>", "VS Sequence done, generate_requests breaking", UVM_NONE);
                    ->event_sequence_done;  // VS
                    break;
                end
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here 1", UVM_NONE);
                wait (tmp_rd_count !== m_tmp_read_seq.read_req_count ||
                    tmp_wr_count !== m_tmp_write_seq.write_req_count
                );
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here 2", UVM_NONE);
            end
        end : sequence_done_check
        begin : generate_requests
            forever begin
                wr_req_t m_axi_req_tmp;
                wr_dat_t m_axi_dat_tmp;
                bit done;
                bit loop_done;
                bit nothing_to_flush = 0;
                int m_tmp_q[$];
                bit is_coh;
                snps_axi_master_write_seq m_write_addr_seq;
                m_write_addr_seq = snps_axi_master_write_seq::type_id::create("m_write_addr_seq");
                m_axi_req_tmp.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
                m_axi_dat_tmp.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
                `uvm_info("CG DEBUG<%=this_aiu_id%>", "Reached here 0", UVM_NONE);
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here generate_requests 0", UVM_NONE);
                if (firstReqDone) begin
                    wait(last_access_done == 1 ||
                    sequence_done == 1
                );
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here generate_requests 1", UVM_NONE);
                end
                `uvm_info("CG DEBUG<%=this_aiu_id%>", "Reached here 1", UVM_NONE);
                last_access_done = 0;
                done = 0;
               `ifndef NOT_USE_INHOUSE_ACE_MODEL
                do begin
                    fork 
                        begin
                            wait (/*m_ace_cache_model.cache_flush_mode_on == 0 && */pwrmgt_power_down == 1 && m_ace_cache_model.pwrmgt_cache_flush == 0 && nothing_to_flush == 0);
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here generate_requests 2", UVM_NONE);
                            if (m_ace_cache_model.m_cache.size() == 0 && pwrmgt_power_down == 1 && count_outstanding_requests <= 1) begin
                                pwrmgt_power_down_done = 1;
                                m_ace_cache_model.pwrmgt_cache_flush = 0;
                                `uvm_info("CHIRAG", "POWER MGT DONE SET 1", UVM_NONE);
                                nothing_to_flush = 1;
                                m_ace_cache_model.m_ort = {};
                                ->m_ace_cache_model.e_cache_modify;
                            end
                            else begin
                                m_ace_cache_model.m_ort = {};
                                ->m_ace_cache_model.e_cache_modify;
                                m_ace_cache_model.pwrmgt_cache_flush   = 1;
                                m_ace_cache_model.coh_write_seq_active = 0;
                                pwrmgt_power_down_done                 = 0;
                                m_ace_cache_model.s_coh_noncoh.put();
                                `uvm_info("CHIRAG", "POWER MGT REQUEST SEEN", UVM_NONE);
                                loop_done = 0;
                            end
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here generate_requests 3", UVM_NONE);
                        end
                        begin
                            bit not_sending_addr;
                            m_ace_cache_model.give_addr_for_ace_req_coh_write(m_axi_req_tmp.m_cmd_type, not_sending_addr, m_axi_req_tmp.m_addr
                                <% if (obj.wSecurityAttribute > 0) { %>                                             
                                    ,m_axi_req_tmp.m_security
                                <% } %>
                            );
                            if (not_sending_addr) begin
                                pwrmgt_power_down_done = 1;
                                m_ace_cache_model.pwrmgt_cache_flush = 0;
                                `uvm_info("CHIRAG", "POWER MGT DONE SET 2", UVM_NONE);
                                nothing_to_flush = 1;
                                done = 1;
                                m_ace_cache_model.m_ort = {};
                                ->m_ace_cache_model.e_cache_modify;
                            end
                            loop_done = 1;
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here generate_requests 4", UVM_NONE);
                        end
                        begin
                            wait (m_tmp_read_seq.read_req_count >= m_tmp_read_seq.read_req_total_count);
                            loop_done = 1;
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here generate_requests 5", UVM_NONE);
                        end
                    join_any
                    disable fork;
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here generate_requests 6", UVM_NONE);
                end while (!loop_done);
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here generate_requests 7", UVM_NONE);
    $display("PT m_tmp_read_seq.read_req_count %0d, m_tmp_read_seq.read_req_total_count %0d", m_tmp_read_seq.read_req_count, m_tmp_read_seq.read_req_total_count);
    $display("PT m_tmp_write_seq.write_req_count %0d, m_tmp_write_seq.write_req_total_count %0d", m_tmp_write_seq.write_req_count, m_tmp_write_seq.write_req_total_count);
                if (m_tmp_read_seq.read_req_count >= m_tmp_read_seq.read_req_total_count) begin
                    `uvm_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("Breaking because all reads are done"), UVM_LOW);
                    done = 1;
                    // Deleting from m_ort
                    m_tmp_q = {};
                    m_tmp_q = m_ace_cache_model.m_ort.find_index with (item.isRead == 0 &&
                        (item.m_cmdtype == WRBK || 
                            item.m_cmdtype == WREVCT ||
                            item.m_cmdtype == EVCT ||
                        item.m_cmdtype == WRCLN)
                    && item.isReqInFlight == 0);
                    for (int i = m_tmp_q.size - 1; i >=0;i--) begin
                        m_ace_cache_model.m_ort.delete(m_tmp_q[i]);
                        ->m_ace_cache_model.e_ort_delete;
                    end
                    m_ace_cache_model.end_of_sim = 1;
                    m_ace_cache_model.s_coh_noncoh.put();
                    wait (m_tmp_write_seq.write_req_count >= m_tmp_write_seq.write_req_total_count && sequence_done == 1);
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here generate_requests 8", UVM_NONE);
                    // @(event_sequence_done);  // VS
                end
    $display("PT m_tmp_read_seq.read_req_count %0d, m_tmp_read_seq.read_req_total_count %0d", m_tmp_read_seq.read_req_count, m_tmp_read_seq.read_req_total_count);
    $display("PT m_tmp_write_seq.write_req_count %0d, m_tmp_write_seq.write_req_total_count %0d", m_tmp_write_seq.write_req_count, m_tmp_write_seq.write_req_total_count);        `endif
                if (!done) begin
                    bit success = 0;
                    bit constrain_awunique = 0;
                    bit m_tmp_awunique;
                    axi_awid_t use_awid;
                    `ifndef NOT_USE_INHOUSE_ACE_MODEL
                    aceState_t m_cache_state = m_ace_cache_model.current_cache_state(m_axi_req_tmp.m_addr
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            ,.security(m_axi_req_tmp.m_security)
                        <% } %>                                                
                    );
                    gen_req_done = 1;
                    `uvm_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("WRCOH snooptype %0s address 0x%0x secure bit 0x%0x", m_axi_req_tmp.m_cmd_type.name(), m_axi_req_tmp.m_addr, 
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            m_axi_req_tmp.m_security
                        <% } else { %>
                            0
                        <% } %>
                    ), UVM_MEDIUM);
                    m_tmp_q = {};
                    m_tmp_q = m_ace_cache_model.m_ort.find_first_index with (item.isRead == 0 &&
                        item.m_addr == m_axi_req_tmp.m_addr
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            && item.m_security == m_axi_req_tmp.m_security
                        <% } %>
                    );
                    if (m_tmp_q.size() == 0) begin
                        uvm_report_error("ACE BFM SEQ AIU 0", $sformatf("TB Error: Cannot find address 0x%0x in m_ort", m_axi_req_tmp.m_addr), UVM_NONE);
                    end
                    else begin
                        if (m_tmp_q.size() > 0) begin
                            m_ace_cache_model.m_ort[m_tmp_q[0]].isReqInFlight = 1;
                        end
                    end
                    constrain_awunique = 0;
                    if (m_axi_req_tmp.m_cmd_type == WRBK) begin 
                        if (m_cache_state == ACE_SD) begin
                            m_tmp_awunique     = 0;
                            constrain_awunique = 1;
                        end
                    end
                    get_axid(m_axi_req_tmp.m_cmd_type, use_awid);
                    m_tmp_q = {};
                    m_tmp_q = m_ace_cache_model.m_cache.find_first_index with (item.m_addr == m_axi_req_tmp.m_addr &&
                                                                            <% if (obj.wSecurityAttribute > 0) { %>
                                                                               item.m_security == m_axi_req_tmp.m_security
                                                                            <% } %>
                                                                              );
                    is_coh = !m_ace_cache_model.m_cache[m_tmp_q[0]].m_non_coherent_addr;
                    success = m_axi_req_tmp.m_seq_item.m_write_addr_pkt.randomize() with {
                        m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awid      == use_awid;
                        m_axi_req_tmp.m_seq_item.m_write_addr_pkt.coh_domain== is_coh;
                        m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awcmdtype == m_axi_req_tmp.m_cmd_type;
                        m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awaddr    == m_axi_req_tmp.m_addr;
                        <% if (obj.useAceUniquePort > 0) { %>
                            if (constrain_awunique == 1) m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awunique == m_tmp_awunique;
                        <% } %>
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awprot[1] == m_axi_req_tmp.m_security;
                        <% } %>                                                
                    };


                    `uvm_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("Coh write. CMD:%h, addr:0x%x, is_coh:%0b, awdomain:%h", m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awcmdtype, m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awaddr, is_coh, m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awdomain), UVM_DEBUG);
                        m_ace_cache_model.update_addr(m_axi_req_tmp.m_cmd_type, m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awaddr
                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                            ,.security(m_axi_req_tmp.m_seq_item.m_write_addr_pkt.awprot[1])
                        <% } %>
                    );
                    if (!success) begin
                        uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize write address packet in snps_axi_master_write_coh_seq"), UVM_NONE);
                    end

                     `endif
                      
                    `ifdef NOT_USE_INHOUSE_ACE_MODEL
                     m_write_addr_seq.should_randomize=1;
		     std::randomize(m_write_addr_seq.m_ace_wr_addr_chnl_snoop) with {m_write_addr_seq.m_ace_wr_addr_chnl_snoop inside {svt_axi_transaction::WRITEBACK,svt_axi_transaction::WRITELINEUNIQUE,svt_axi_transaction::WRITEEVICT,svt_axi_transaction::EVICT,svt_axi_transaction::WRITEUNIQUE};};
                     m_write_addr_seq.m_constraint_snoop = 1;
                     `endif

                                       if (!firstReqDone) begin
                        firstReqDone = 1;
                    end
                    //s_wr_addr.get();
                    //s_wr_data.get();
                    //uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("get s_wr_addr in coherent write"), UVM_HIGH);
                    m_axi_wr_req_q.push_back(m_axi_req_tmp);
                    count_outstanding_requests++;
                    gen_req_done = 0;
                `uvm_info("CG DEBUG", "Reached here 2", UVM_NONE);
                end
                if (sequence_done) begin
                    uvm_report_info("CHIRAG<%=this_aiu_id%>", "generate_requests breaking", UVM_NONE);
                    break;
                end
                // #10
                `uvm_info("CG DEBUG<%=this_aiu_id%>", "Reached here 3", UVM_NONE);
           end
        end : generate_requests
        begin : send_write_address
            int m_tmp_q[$];
            bit success;
            wr_req_t m_wr_req;
            wr_dat_t m_axi_dat_tmp;
            //axi_write_addr_seq m_write_addr_seq;
            snps_axi_master_write_seq m_write_addr_seq;
            svt_axi_master_transaction          m_seq_item_rsp;
            axi_wr_seq_item    m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
            m_wr_req.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");

                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here send_write_address 0", UVM_NONE);
            forever begin 
                wait(m_axi_wr_req_q.size() > 0 ||
                   (sequence_done == 1 && !gen_req_done)
                );
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here send_write_address 1", UVM_NONE);
                if ((m_axi_wr_req_q.size() == 0 && sequence_done ==1 && !gen_req_done)) begin
                    //uvm_report_info("CHIRAG", "send_write_address breaking", UVM_NONE);
                    write_addr_done = 1;
                    break;
                end
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here send_write_address 2", UVM_NONE);
                //m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq");
                //m_write_addr_seq.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
                m_write_addr_seq = snps_axi_master_write_seq::type_id::create("m_write_addr_seq");
                m_write_addr_seq.m_seq_item = svt_axi_master_transaction::type_id::create("m_seq_item");
                m_wr_req = m_axi_wr_req_q.pop_front();
                `ifdef NOT_USE_INHOUSE_ACE_MODEL
                  	m_write_addr_seq.should_randomize = 1;
		  	std::randomize(m_write_addr_seq.m_ace_wr_addr_chnl_snoop) with {m_write_addr_seq.m_ace_wr_addr_chnl_snoop inside {svt_axi_transaction::WRITEBACK,svt_axi_transaction::WRITELINEUNIQUE,svt_axi_transaction::WRITEEVICT,svt_axi_transaction::EVICT,svt_axi_transaction::WRITEUNIQUE};};
			m_write_addr_seq.m_constraint_snoop = 1;
		 `endif 
                `ifndef NOT_USE_INHOUSE_ACE_MODEL
                m_write_addr_seq.should_randomize = 0;
                //m_write_addr_seq.m_seq_item.do_copy(m_wr_req.m_seq_item);
                m_write_addr_seq.txn_copy(m_wr_req.m_seq_item);
                //check if the Coherent Wr is ok to send
                m_tmp_q = {};
                m_tmp_q = m_ace_cache_model.m_ort.find_first_index with (item.isRead == 0 &&
                    item.isUpdate == 1 &&
                    item.isCohWriteSent == 0 &&
                    item.m_addr[WAXADDR-1:SYS_wSysCacheline] == m_wr_req.m_addr[WAXADDR-1:SYS_wSysCacheline]
                    <% if (obj.wSecurityAttribute > 0) { %>
                        && item.m_security == m_wr_req.m_security
                    <% } %>
                );
                if (m_tmp_q.size() == 0) begin
                    m_ace_cache_model.print_queues();
                    uvm_report_error("ACE BFM SEQ AIU 0", $sformatf("TB Error: Cannot find address 0x%0x in m_ort", m_wr_req.m_addr), UVM_NONE);
                end
                else begin
                    aceState_t tmp_aceState;
                    start_state_queue_t m_possible_start_states_array = new();
                    aceState_t m_cache_state = m_ace_cache_model.current_cache_state(m_wr_req.m_addr
                        <% if (obj.wSecurityAttribute > 0) { %>
                            ,.security(m_wr_req.m_security)
                        <% } %>
                    );
                    m_possible_start_states_array = m_ace_cache_model.return_legal_start_states(m_wr_req.m_cmd_type);
                    success = 0;
                    for (int i = 0; i < m_possible_start_states_array.m_start_state_queue_t[0].size(); i++) begin
                        if(!$cast(tmp_aceState, m_possible_start_states_array.m_start_state_queue_t[0][i]))
                            `uvm_error("In Coh write seq(ACE CACHE MODEL)", "Cast failed to temp state");
                        if(m_cache_state == tmp_aceState) begin
                            success = 1;
                            break;
                        end
                    end
                    if(!success) begin
                        m_ace_cache_model.m_ort.delete(m_tmp_q[0]);
                        ->m_ace_cache_model.e_ort_delete;
                        //s_wr_addr.put();
                        //s_wr_data.put();
                        count_outstanding_requests--;
                        continue;
                    end
                end
                `endif
                //prepare Wr data
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here send_write_address 3", UVM_NONE);
                m_axi_dat_tmp.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
                 `ifdef NOT_USE_INHOUSE_ACE_MODEL
                   	m_write_addr_seq.should_randomize=1;
		   	std::randomize(m_write_addr_seq.m_ace_wr_addr_chnl_snoop) with {m_write_addr_seq.m_ace_wr_addr_chnl_snoop inside {svt_axi_transaction::WRITEBACK,svt_axi_transaction::WRITELINEUNIQUE,svt_axi_transaction::WRITEEVICT,svt_axi_transaction::EVICT,svt_axi_transaction::WRITEUNIQUE};};
			m_write_addr_seq.m_constraint_snoop = 1;
                  `endif 
                `ifndef NOT_USE_INHOUSE_ACE_MODEL
                success = m_axi_dat_tmp.m_seq_item.m_write_data_pkt.randomize();
                if (!success) begin
                    uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize write data packet in snps_axi_master_write_coh_seq"), UVM_NONE);
                end
                m_axi_dat_tmp.m_seq_item.m_write_data_pkt.wdata = new [m_wr_req.m_seq_item.m_write_addr_pkt.awlen + 1];
                m_axi_dat_tmp.m_seq_item.m_write_data_pkt.wstrb = new [m_wr_req.m_seq_item.m_write_addr_pkt.awlen + 1];
                m_ace_cache_model.give_data_for_ace_req(m_wr_req.m_seq_item.m_write_addr_pkt.awaddr, m_wr_req.m_cmd_type, m_wr_req.m_seq_item.m_write_addr_pkt.awlen, m_wr_req.m_seq_item.m_write_addr_pkt.awburst, m_wr_req.m_seq_item.m_write_addr_pkt.awsize, m_axi_dat_tmp.m_seq_item.m_write_data_pkt.wdata, m_axi_dat_tmp.m_seq_item.m_write_data_pkt.wstrb
                    <% if (obj.wSecurityAttribute > 0) { %>
                        ,m_wr_req.m_seq_item.m_write_addr_pkt.awprot[1]
                    <% } %>
                );
                m_axi_dat_tmp.m_seq_item.m_write_addr_pkt = m_wr_req.m_seq_item.m_write_addr_pkt;
                if (m_wr_req.m_seq_item.m_write_addr_pkt.awcmdtype !== EVCT) begin
                    m_axi_wr_dat_q.push_back(m_axi_dat_tmp);
                end
                else begin
                    //s_wr_data.put();
                end
                //set isCohWriteSent
                m_ace_cache_model.m_ort[m_tmp_q[0]].isCohWriteSent = 1;
                //uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("set isCohWriteSent for addr = 0x%x, cmdtype = %s", m_wr_req.m_addr, m_wr_req.m_cmd_type.name()), UVM_HIGH);
                //send Coherent Wr
                `endif
                //m_write_addr_seq.return_response(m_seq_item, m_write_addr_chnl_seqr);
	        m_seq_item_rsp = svt_axi_master_transaction::type_id::create("m_seq_item_rsp");
                m_write_addr_seq.return_response(m_seq_item_rsp, m_write_seqr);

                //uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("Done sent Coherent Write addr = 0x%x, cmdtype = %s", m_wr_req.m_addr, m_wr_req.m_cmd_type.name()), UVM_HIGH);
                last_access_done = 1;
                m_axi_wr_rsp_q.push_back(m_wr_req.m_seq_item);
           end
        end : send_write_address
        //begin : send_write_data
        //    wr_dat_t m_wr_dat;
        //    axi_write_data_seq m_write_data_seq;
        //    axi_wr_seq_item    m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
        //    wr_addr_data_t     m_wr_addr_data;
        //    m_wr_dat.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");

        //    forever begin 
        //        wait(m_axi_wr_dat_q.size() > 0 ||
        //            (sequence_done == 1 && write_addr_done == 1)
        //        );
        //        if (m_axi_wr_dat_q.size() == 0 && sequence_done == 1 &&  write_addr_done == 1) begin
        //            //uvm_report_info("CHIRAG", "send_write_data breaking", UVM_NONE);
        //            break;
        //        end
        //        m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq");
        //        m_write_data_seq.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
        //        m_wr_dat = m_axi_wr_dat_q.pop_front();
        //        m_write_data_seq.should_randomize = 0;
        //        m_write_data_seq.m_seq_item.do_copy(m_wr_dat.m_seq_item);
        //        m_write_data_seq.return_response(m_seq_item, m_write_data_chnl_seqr);
        //        m_wr_addr_data.m_addr = m_wr_dat.m_seq_item.m_write_addr_pkt.awaddr;
        //        <% if (obj.wSecurityAttribute > 0) { %>
        //            m_wr_addr_data.m_security = m_wr_dat.m_seq_item.m_write_addr_pkt.awprot[1];
        //        <% } %>                                                
        //        m_wr_addr_data.m_data = new[m_wr_dat.m_seq_item.m_write_data_pkt.wdata.size()] (m_wr_dat.m_seq_item.m_write_data_pkt.wdata);
        //        //uvm_report_info("AXI SEQ DEBUG", $sformatf("Address 0x%0x added to m_axi_wr_addr_data", m_wr_dat.m_seq_item.m_write_addr_pkt.awaddr), UVM_NONE);
        //        m_axi_wr_addr_data_q.push_back(m_wr_addr_data);
        //        ->e_axi_wr_data_add_q;
        //        last_access_done = 1;
        //   end
        //end : send_write_data
        `ifndef NOT_USE_INHOUSE_ACE_MODEL
        begin : get_write_response
            axi_wr_seq_item m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
            bit             copy_done = 1;

            forever begin
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here get_write_response 0", UVM_NONE);
                wait(m_axi_wr_rsp_q.size() > 0 ||
                    (sequence_done == 1 && count_outstanding_requests == 0)
                );
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here get_write_response 1", UVM_NONE);
                wait(copy_done == 1 ||
                    (sequence_done == 1 && count_outstanding_requests == 0)
                );
                `uvm_info("PT DEBUG<%=this_aiu_id%>", "Reached here get_write_response 2", UVM_NONE);
                if (m_axi_wr_rsp_q.size() > 0) begin
                    m_seq_item = m_axi_wr_rsp_q.pop_front();
                    copy_done = 0;
                    fork 
                        begin
                            axi_wr_seq_item m_fork_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
                            axi_write_resp_seq m_fork_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq");
                            m_fork_seq_item.do_copy(m_seq_item);
                            copy_done = 1;
                            // Waiting till data is sent before going through below set of code
                            if (m_fork_seq_item.m_write_addr_pkt.awcmdtype !== EVCT) begin
                                bit done = 0;
                                int m_tmp_q[$];
                                do begin
                                    m_tmp_q = {};
                                    m_tmp_q = m_axi_wr_addr_data_q.find_index with (item.m_addr == m_fork_seq_item.m_write_addr_pkt.awaddr 
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            && item.m_security == m_fork_seq_item.m_write_addr_pkt.awprot[1] 
                                        <% } %>                                                
                                    );
                                    if (m_tmp_q.size() == 0) begin
                                        @e_axi_wr_data_add_q;
                                    end 
                                    else begin
                                        done = 1;
                                    end
                                end while (!done);
                            end
                            //uvm_report_info("AXI SEQ DEBUG 1", $sformatf("Address 0x%0x id:0x%0x calling wait", m_fork_seq_item.m_write_addr_pkt.awaddr, m_fork_seq_item.m_write_addr_pkt.awid), UVM_NONE);
                            wait_till_awid_latest(m_fork_seq_item.m_write_addr_pkt);
                            //uvm_report_info("AXI SEQ DEBUG 1", $sformatf("Address 0x%0x id:0x%0x done waiting", m_fork_seq_item.m_write_addr_pkt.awaddr, m_fork_seq_item.m_write_addr_pkt.awid), UVM_NONE);
                            m_fork_resp_seq.should_randomize = 0;
                            m_fork_resp_seq.m_seq_item = axi_wr_seq_item::type_id::create("m_seq_item");
                            m_fork_resp_seq.m_seq_item.do_copy(m_fork_seq_item);
                            //uvm_report_info("AXI SEQ DEBUG 1", $sformatf("Address 0x%0x id:0x%0x calling fork", m_fork_seq_item.m_write_addr_pkt.awaddr, m_fork_seq_item.m_write_addr_pkt.awid), UVM_NONE);
                            //m_fork_resp_seq.return_response(m_fork_seq_item, m_write_resp_chnl_seqr);
                            //uvm_report_info("AXI SEQ DEBUG 1", $sformatf("Address 0x%0x id:0x%0x done calling fork", m_fork_seq_item.m_write_addr_pkt.awaddr, m_fork_seq_item.m_write_addr_pkt.awid), UVM_NONE);
                            delete_ott_entry(m_fork_resp_seq.m_seq_item.m_write_addr_pkt);
                            if (m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awcmdtype != BARRIER) begin
                                if (m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awcmdtype == EVCT) begin
                                    axi_xdata_t wdata[];
                                    axi_bresp_t tmp_bresp[] = new[1];
                                    tmp_bresp[0] = m_fork_resp_seq.m_seq_item.m_write_resp_pkt.bresp;
                                    m_ace_cache_model.modify_cache_line(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awaddr, m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awcmdtype , tmp_bresp, wdata,
                                        .axdomain(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awdomain)
                                        <% if (obj.wSecurityAttribute > 0) { %>                                             
                                            , .security(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awprot[1])
                                        <% } %>                                                
                                    );
                                end
                                else begin
                                    int m_tmp_q[$];
                                    axi_bresp_t tmp_bresp[] = new[1];
                                    m_tmp_q = m_axi_wr_addr_data_q.find_index with (item.m_addr == m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awaddr 
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            && item.m_security == m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awprot[1] 
                                        <% } %>                                                
                                    );
                                    if (m_tmp_q.size() == 0) begin
                                        foreach(m_axi_wr_addr_data_q[i]) begin
                                            uvm_report_info("AXI SEQ", $sformatf("i %0d Address:0x%0x", i, m_axi_wr_addr_data_q[i].m_addr), UVM_NONE);
                                        end
                                        uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not find write data packet in axi_wr_dat_q for address 0x%0x security 0x%0x", m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awaddr,
                                            <% if (obj.wSecurityAttribute > 0) { %>
                                                m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awprot[1]
                                            <% } else { %>                                                
                                                0
                                            <% } %>
                                        ), UVM_NONE);
                                    end
                                    tmp_bresp[0] = m_fork_resp_seq.m_seq_item.m_write_resp_pkt.bresp;
                                    m_ace_cache_model.modify_cache_line(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awaddr , m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awcmdtype, tmp_bresp, m_axi_wr_addr_data_q[m_tmp_q[0]].m_data,
                                        .axdomain(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awdomain)
                                        <% if (obj.wSecurityAttribute > 0) { %>
                                            , .security(m_fork_resp_seq.m_seq_item.m_write_addr_pkt.awprot[1])
                                        <% } %>                                                
                                    );
                                    //uvm_report_info("AXI SEQ DEBUG", $sformatf("Address 0x%0x deleting from m_axi_wr_addr_data", m_axi_wr_addr_data_q[m_tmp_q[0]].m_addr), UVM_NONE);
                                    m_axi_wr_addr_data_q.delete(m_tmp_q[0]);
                                end
                                if (m_ace_cache_model.m_cache.size() == 0 && pwrmgt_power_down == 1 && count_outstanding_requests <= 1) begin
                                    pwrmgt_power_down_done = 1;
                                    m_ace_cache_model.pwrmgt_cache_flush = 0;
                                    `uvm_info("CHIRAG", "POWER MGT DONE SET 3", UVM_NONE);
                                    m_ace_cache_model.m_ort = {};
                                    ->m_ace_cache_model.e_cache_modify;
                                end
                            end
                            count_outstanding_requests--;
                        end
                    join_none
                end
                if (sequence_done && count_outstanding_requests == 0) begin
                    wait fork;
                    //uvm_report_info("CHIRAG", "get_write_response breaking", UVM_NONE);
                    break;
                end
            end
        end : get_write_response
        `endif
    join

    `uvm_info("body", "Exiting...", UVM_LOW)
endtask : body

endclass : snps_axi_master_write_coh_seq

class snps_axi_master_writeback_seq extends axi_master_write_base_seq;

    `uvm_object_param_utils(snps_axi_master_writeback_seq)
    
    axi_write_addr_seq            m_write_addr_seq;
    axi_write_data_seq            m_write_data_seq;
    axi_write_resp_seq            m_write_resp_seq;
    axi_write_addr_chnl_sequencer m_write_addr_chnl_seqr;
    axi_write_data_chnl_sequencer m_write_data_chnl_seqr;
    axi_write_resp_chnl_sequencer m_write_resp_chnl_seqr;
    axi_wr_seq_item               m_seq_item0;
    axi_wr_seq_item               m_seq_item1;

    axi_axaddr_t     m_addr;
    axi_axlen_t      m_axlen;


    //Control Knobs

    int k_num_write_req         = 1;
    addr_trans_mgr m_addr_mgr;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "snps_axi_master_writeback_seq");
    super.new(name);
    m_addr_mgr = addr_trans_mgr::get_instance();
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    int num_req;
    bit success;
    ace_cache_line_model m_cache[$];
    bit [63:0]           m_inflight_q[$];

    num_req = 0;
    m_write_addr_seq = axi_write_addr_seq::type_id::create("m_write_addr_seq"); 
    m_write_data_seq = axi_write_data_seq::type_id::create("m_write_data_seq"); 
    m_write_resp_seq = axi_write_resp_seq::type_id::create("m_write_resp_seq"); 
    do begin
        bit done = 0;
        bit [ncoreConfigInfo::W_SEC_ADDR - 1 : 0] sec_addr;
        axi_awid_t use_awid;
        //s_wr.get();
	if(s_wr[core_id] == null) s_wr[core_id] = new(1);
        s_wr[core_id].get();
        m_write_addr_seq.m_ace_wr_addr_chnl_snoop = WRBK;
        sec_addr = m_addr_mgr.get_coh_addr(<%=obj.AiuInfo[obj.Id].FUnitId%>, 1);
        m_write_addr_seq.m_ace_wr_addr_chnl_addr = sec_addr;
        <% if (obj.wSecurityAttribute > 0) { %>                                             
            m_write_addr_seq.m_ace_wr_addr_chnl_security = sec_addr[ncoreConfigInfo::W_SEC_ADDR - 1];
        <% } %>                                                
        done = 1;
        if (done) begin
            uvm_report_info("ACE BFM SEQ AIU <%=this_aiu_id%>", $sformatf("WR snooptype %0s address 0x%0x secure bit 0x%0x", m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name(), m_write_addr_seq.m_ace_wr_addr_chnl_addr, 
                <% if (obj.wSecurityAttribute > 0) { %>                                             
                    m_write_addr_seq.m_ace_wr_addr_chnl_security
                <% } else { %>
                    0
                <% } %>
            ), UVM_MEDIUM);

        end
        m_write_addr_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_data_seq.m_seq_item                = axi_wr_seq_item::type_id::create("m_seq_item");
        m_write_addr_seq.m_constraint_snoop        = 1;
        m_write_addr_seq.m_constraint_addr         = 1;

        get_axid(m_write_addr_seq.m_ace_wr_addr_chnl_snoop, use_awid);
        success = m_write_addr_seq.m_seq_item.m_write_addr_pkt.randomize() with {if (m_write_addr_seq.m_constraint_snoop == 1) m_write_addr_seq.m_seq_item.m_write_addr_pkt.awcmdtype == m_write_addr_seq.m_ace_wr_addr_chnl_snoop;
            m_write_addr_seq.m_seq_item.m_write_addr_pkt.awid   == use_awid;
            m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr == m_write_addr_seq.m_ace_wr_addr_chnl_addr;
            // For directed test case purposes
            m_write_addr_seq.m_seq_item.m_write_addr_pkt.useFullCL == use_full_cl;
            <% if (obj.wSecurityAttribute > 0) { %>                                             
                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awprot[1]==m_write_addr_seq.m_ace_wr_addr_chnl_security;
            <% } %>
        };
        if (!success) begin
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize write address packet in snps_axi_master_writeback_seq"), UVM_NONE);
        end

        `uvm_info("ACE BFM SEQ",$sformatf("WR snooptype %0s address 0x%0x len 0x%0x" ,
                                m_write_addr_seq.m_ace_wr_addr_chnl_snoop.name() ,
                                m_write_addr_seq.m_seq_item.m_write_addr_pkt.awaddr, m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen), UVM_MEDIUM);

        success = m_write_data_seq.m_seq_item.m_write_data_pkt.randomize();
        if (!success) begin
            uvm_report_error("AXI SEQ", $sformatf("TB Error: Could not randomize write data packet in snps_axi_master_writeback_seq"), UVM_NONE);
        end
        m_write_data_seq.m_seq_item.m_write_data_pkt.wdata = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb = new [m_write_addr_seq.m_seq_item.m_write_addr_pkt.awlen + 1];
        foreach (m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[i]) begin
            axi_xdata_t tmp_data;
            axi_xstrb_t tmp_strb;
            assert(std::randomize(tmp_data))
            else begin
                uvm_report_error($sformatf("%s", get_full_name()), "Failure to randomize tmp_data", UVM_NONE);
            end
            assert(std::randomize(tmp_strb))
            else begin
                uvm_report_error($sformatf("%s", get_full_name()), "Failure to randomize tmp_strb", UVM_NONE);
            end
            m_write_data_seq.m_seq_item.m_write_data_pkt.wdata[i] = tmp_data;
            m_write_data_seq.m_seq_item.m_write_data_pkt.wstrb[i] = tmp_strb;
        end
        
        m_write_data_seq.m_seq_item.m_write_addr_pkt = m_write_addr_seq.m_seq_item.m_write_addr_pkt;
        m_write_addr_seq.should_randomize = 0;
        m_write_data_seq.should_randomize = 0;
        //s_wr_addr.get();
        //s_wr_data.get();
        fork 
            begin
                //m_write_addr_seq.return_response(m_seq_item0, m_write_addr_chnl_seqr);
            end
            begin
                // Nothing goes on write data channel for evicts
                if (m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== EVCT &&
                    m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== BARRIER &&
                    m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== STASHONCEUNQ &&		    
                    m_write_addr_seq.m_ace_wr_addr_chnl_snoop !== STASHONCESHARED

                ) begin
                    //m_write_data_seq.return_response(m_seq_item1, m_write_data_chnl_seqr);
                end
            end
        join
        s_wr[core_id].put();
        wait_till_awid_latest(m_write_addr_seq.m_seq_item.m_write_addr_pkt);
        m_write_resp_seq.should_randomize = 0;
        m_write_resp_seq.m_seq_item       = m_seq_item0;
        //m_write_resp_seq.return_response(m_seq_item0, m_write_resp_chnl_seqr);
        delete_ott_entry(m_write_addr_seq.m_seq_item.m_write_addr_pkt);
        num_req++;
    end while (num_req < k_num_write_req);

endtask : body

endclass : snps_axi_master_writeback_seq

<% } %>

class snps_axi_master_seq extends svt_axi_master_base_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `uvm_object_param_utils(snps_axi_master_seq)

  /** Class Constructor */
  function new(string name="snps_axi_master_seq");
  super.new(name);
  endfunction
 

function bit [ncoreConfigInfo::W_SEC_ADDR -1:0] get_addr_for_domain(bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr,end_addr,int agentid,int core_id,bit is_rdnosnp);
   int primary_bits[$] = ncoreConfigInfo::mp_aiu_intv_bits[agentid].pri_bits;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] new_addr,addr;
   bit check_addr_unconnected = 0;
   bit [2:0] unit_unconnect = 0;
   int timeout;

              `uvm_info("get_addr_for_domain", $sformatf("primary_bits %0p addr %0h agentid %0d sta_addr %0h end_addr %0h",primary_bits,new_addr,agentid,start_addr,end_addr),UVM_LOW)
   if(primary_bits.size()>0)
     primary_bits.sort();
  timeout=500;
  do begin
    timeout -=1;
    //new_addr = $urandom_range(start_addr,end_addr);
     std::randomize(new_addr) with { new_addr inside {[start_addr:end_addr]};};
    if(!is_rdnosnp)new_addr[5:0] = 0;

    foreach (primary_bits[j]) begin
      new_addr[primary_bits[j]]=core_id[j];
    end

    check_addr_unconnected = ncoreConfigInfo::check_unmapped_add(new_addr, agentid, unit_unconnect);
             // `uvm_info("get_addr_for_domain", $sformatf(" primary_bits %0p addr %0h check_addr_unconnected %0d",primary_bits,new_addr,check_addr_unconnected),UVM_LOW)

  end while(((new_addr>end_addr) || (new_addr < start_addr) ||(check_addr_unconnected)) && (timeout !=0) );

  if(timeout==0)
    `uvm_error("get_addr_for_domain", $sformatf("Timeout! Failed to randomize address start_addr %0h end_addr %0h",start_addr,end_addr))
    
    return new_addr;
endfunction

endclass: snps_axi_master_seq

///////////////////////////////////////////////////////////////////////////////
/////////////////////////    Snoop Sequence    ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////

class snps_axi_master_snoop_seq extends snps_axi_master_seq;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length = 0;

  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }

  /** UVM Object Utility macro */
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `uvm_object_param_utils(snps_axi_master_snoop_seq)
   
  svt_axi_master_sequencer        m_write_seqr;
 
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr0,end_addr0,start_addr1,end_addr1; 
  int master_id,core;

  svt_axi_system_configuration axi_sys_cfg;
  svt_axi_transaction::coherent_xact_type_enum      read_txn_type;
  svt_axi_transaction::coherent_xact_type_enum      read_txn_type_1;
  svt_axi_transaction::coherent_xact_type_enum      write_txn_type;
  svt_axi_transaction::prot_type_enum prot_type;
  addr_trans_mgr    m_addr_mgr;
    bit [63:0] rdnsnp_addr_que[int][$],rdnsnp_addr_orig_que[int][$],snoop_adr;
  
  /** Class Constructor */
  function new(string name="snps_axi_master_snoop_seq");
  super.new(name);
  m_addr_mgr = addr_trans_mgr::get_instance();
  m_addr_mgr.gen_memory_map();
 

  endfunction
  
  virtual task body();
   
    svt_axi_master_transaction write_tran, read_tran ,read_tran_1;
    svt_configuration get_cfg;
    bit status;
    int align;
	 int size, _tmp;
    `uvm_info("body", "Entered ...", UVM_LOW)
   

    super.body();

    status = uvm_config_db #(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);

    /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end

core = 0;
<% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
  if( master_id ==<%=aiu_rpn+k-no_chi%> )begin
    core =<%=k%>; 
  end
<% }} %>


   m_addr_mgr.get_dmi_unit_addr_range(start_addr0,end_addr0,start_addr1,end_addr1);

      <% if (obj.fnNativeInterface == "ACE") { %>
    for(int i = 0; i < sequence_length; i++) begin

     
      /** Set up the read transaction */
      `uvm_create(read_tran)
      read_tran.port_cfg     = cfg;
      read_tran.port_cfg.enable_domain_based_addr_gen = 1;

      read_tran.xact_type    = svt_axi_transaction::COHERENT;
       if(read_tran.port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE)begin
        std::randomize(read_txn_type)with{read_txn_type inside {svt_axi_transaction::READUNIQUE};};
        read_tran.coherent_xact_type = read_txn_type;
       end

       
      read_tran.burst_type   = svt_axi_transaction::WRAP;

      case(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)
      	3: read_tran.burst_size   = svt_axi_transaction::BURST_SIZE_64BIT;
      	4: read_tran.burst_size   = svt_axi_transaction::BURST_SIZE_128BIT;
      	5: read_tran.burst_size   = svt_axi_transaction::BURST_SIZE_256BIT;
      	default:read_tran.burst_size   = svt_axi_transaction::BURST_SIZE_32BIT;
      endcase

      read_tran.atomic_type  = svt_axi_transaction::NORMAL;
      read_tran.burst_length = <%=((obj.AiuInfo[obj.Id].wData/8)<64)?64/(obj.AiuInfo[obj.Id].wData/8):1%>;
        //std::randomize(prot_type);
        read_tran.prot_type = svt_axi_transaction::DATA_SECURE_NORMAL; 

      	 
      	read_tran.domain_type = svt_axi_transaction::INNERSHAREABLE;
	//read_tran.addr = get_addr_for_domain(read_tran.port_cfg.innershareable_start_addr[0],read_tran.port_cfg.innershareable_end_addr[0],<%=obj.DutInfo.FUnitId%>,core,0);
	read_tran.addr = get_addr_for_domain(read_tran.port_cfg.innershareable_start_addr[0],read_tran.port_cfg.innershareable_start_addr[0]+4000,<%=obj.DutInfo.FUnitId%>,core,0);
        rdnsnp_addr_que[core].push_back(read_tran.addr);
        rdnsnp_addr_orig_que[core].push_back(read_tran.addr);
      	read_tran.cache_type[1] = 1;

      read_tran.rresp    = new[read_tran.burst_length];
      read_tran.data         = new[read_tran.burst_length];
      read_tran.rready_delay = new[read_tran.burst_length];
      read_tran.data_user    = new[read_tran.burst_length];
      <% if (obj.fnNativeInterface == "ACE") { %>
      read_tran.coh_rresp    = new[read_tran.burst_length];
      <% } %>
      
      foreach (read_tran.rready_delay[i]) begin
        read_tran.rready_delay[i]=i;
      end
        if($test$plusargs("long_delay_en")) begin
        read_tran.bready_delay=$urandom_range(30,60);
        end

      /** Send the read transaction */
      `uvm_send(read_tran)

      /** Wait for the read transaction to complete */
      get_response(rsp);
    
      `uvm_info("body", "AXI READ transaction completed", UVM_LOW);
 
    end
      <% } %>
     
    //size=rdnsnp_addr_que[core].size();

    for(int i = 0; i < sequence_length; i++) begin

    size=rdnsnp_addr_que[core].size();
       /** Set up the read transaction */
      `uvm_create(read_tran_1)
      read_tran_1.port_cfg     = cfg;
      read_tran_1.port_cfg.enable_domain_based_addr_gen = 1;
      read_tran_1.port_cfg.data_transfer_for_makeinvalid_snoop_enable    = 1;
      read_tran_1.port_cfg.transfer_snoop_data_always_if_valid_cacheline     = 0;

      read_tran_1.xact_type    = svt_axi_transaction::COHERENT;
      if( read_tran_1.port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE)begin
         std::randomize(read_txn_type_1)with{read_txn_type_1 inside {svt_axi_transaction::READCLEAN,
								svt_axi_transaction::READUNIQUE,
								svt_axi_transaction::READONCE,
								svt_axi_transaction::READNOTSHAREDDIRTY,
								svt_axi_transaction::READSHARED,
								svt_axi_transaction::CLEANSHARED,
								svt_axi_transaction::CLEANUNIQUE,
								//svt_axi_transaction::MAKEUNIQUE,
								svt_axi_transaction::CLEANINVALID,
								svt_axi_transaction::MAKEINVALID};};
        read_tran_1.coherent_xact_type = read_txn_type_1;	
        //read_tran_1.prot_type = svt_axi_transaction::DATA_SECURE_NORMAL; 
       end else if(read_tran_1.port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE)begin
        std::randomize(read_txn_type_1)with{read_txn_type_1 inside {svt_axi_transaction::READONCE,
								svt_axi_transaction::CLEANSHARED,
								svt_axi_transaction::CLEANINVALID,
								svt_axi_transaction::MAKEINVALID};};
        read_tran_1.coherent_xact_type = read_txn_type;
      end else begin
      read_tran_1.coherent_xact_type = svt_axi_transaction::READNOSNOOP;
      end
        std::randomize(prot_type);
        read_tran_1.prot_type = svt_axi_transaction::DATA_SECURE_NORMAL; 
      
      read_tran_1.burst_type   = svt_axi_transaction::WRAP;
      case(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)

      3: read_tran_1.burst_size   = svt_axi_transaction::BURST_SIZE_64BIT;
      4: read_tran_1.burst_size   = svt_axi_transaction::BURST_SIZE_128BIT;
      5: read_tran_1.burst_size   = svt_axi_transaction::BURST_SIZE_256BIT;
      default:read_tran_1.burst_size   = svt_axi_transaction::BURST_SIZE_32BIT;
      endcase
      read_tran_1.atomic_type  = svt_axi_transaction::NORMAL;
      read_tran_1.burst_length = <%=((obj.AiuInfo[obj.Id].wData/8)<64)?64/(obj.AiuInfo[obj.Id].wData/8):1%>;
      if(size && (read_tran_1.port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE || read_tran_1.port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE))begin
      	std::randomize(_tmp)with{_tmp inside {[0:(size-1)]};};	
        snoop_adr=rdnsnp_addr_que[core][_tmp];
        rdnsnp_addr_que[core].delete(_tmp);
	read_tran_1.addr = snoop_adr;
     end

      if(read_tran_1.coherent_xact_type == svt_axi_transaction::READNOSNOOP) begin
          read_tran_1.cache_type[1:0] = 2'b00;
          read_tran_1.domain_type = svt_axi_transaction::SYSTEMSHAREABLE;
          if(!size)begin
	  if(start_addr0 == read_tran_1.port_cfg.innershareable_start_addr[0]) read_tran_1.addr = get_addr_for_domain(start_addr1,end_addr1,<%=obj.DutInfo.FUnitId%>,core,0);
	  else read_tran_1.addr = get_addr_for_domain(start_addr0,end_addr0,<%=obj.DutInfo.FUnitId%>,core,0);
          end
      end else begin 
	  if(!size)read_tran_1.addr = get_addr_for_domain(read_tran_1.port_cfg.innershareable_start_addr[0],read_tran_1.port_cfg.innershareable_start_addr[0]+4000,<%=obj.DutInfo.FUnitId%>,core,0);
          read_tran_1.cache_type[1:0] = 2'b11;
          read_tran_1.domain_type = svt_axi_transaction::INNERSHAREABLE;
      end
      
      if(read_tran_1.coherent_xact_type==svt_axi_transaction::CLEANSHARED || read_tran_1.coherent_xact_type==svt_axi_transaction::CLEANINVALID || read_tran_1.coherent_xact_type==svt_axi_transaction::MAKEINVALID || read_tran_1.coherent_xact_type==svt_axi_transaction::CLEANUNIQUE || read_tran_1.coherent_xact_type== svt_axi_transaction::MAKEUNIQUE)begin
      read_tran_1.rresp        = new[1];
      read_tran_1.data         = new[1];
      read_tran_1.rready_delay = new[1];
      read_tran_1.data_user    = new[1];
      <% if (obj.fnNativeInterface == "ACE") { %>
      read_tran_1.coh_rresp    = new[1];
      <% } %>
     end else begin
      read_tran_1.rresp    = new[read_tran_1.burst_length];
      read_tran_1.data         = new[read_tran_1.burst_length];
      read_tran_1.rready_delay = new[read_tran_1.burst_length];
      read_tran_1.data_user    = new[read_tran_1.burst_length];
      <% if (obj.fnNativeInterface == "ACE") { %>
      read_tran_1.coh_rresp    = new[read_tran_1.burst_length];
      <% } %>
     end

      
      `uvm_info("body",$sformatf( "AXI READ 1st addr %0h addr1 %0h end_addr1 %0h start_addr0 %0h end_Addr %0h", read_tran_1.addr,start_addr1,end_addr1,start_addr0,end_addr0),UVM_NONE);

      foreach (read_tran_1.rready_delay[i]) begin
        read_tran_1.rready_delay[i]=i;
      end
        if($test$plusargs("long_delay_en")) begin
        read_tran_1.bready_delay=$urandom_range(30,60);
        end

      /** Send the read transaction */
      `uvm_send(read_tran_1)

      /** Wait for the read transaction to complete */
      get_response(rsp);
      `uvm_info("body", "AXI READ transaction completed_2", UVM_LOW);

    end

    for(int i = 0; i < sequence_length; i++) begin

    size=rdnsnp_addr_orig_que[core].size();
      /** Set up the write transaction */
      `uvm_create(write_tran)
      write_tran.port_cfg     = cfg;
      write_tran.xact_type    = svt_axi_transaction::COHERENT;
      write_tran.port_cfg.data_transfer_for_makeinvalid_snoop_enable    = 1;
      write_tran.port_cfg.transfer_snoop_data_always_if_valid_cacheline     = 0;

       if(write_tran.port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE)begin
          std::randomize(write_txn_type)with{write_txn_type inside{  svt_axi_transaction::WRITEUNIQUE,
								     svt_axi_transaction::WRITELINEUNIQUE,
								     svt_axi_transaction::WRITECLEAN };};
      	  write_tran.coherent_xact_type = write_txn_type;
      	 // write_tran.prot_type = prot_type ; 
       end else if(write_tran.port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE)begin
          std::randomize(write_txn_type)with{write_txn_type inside{  svt_axi_transaction::WRITEUNIQUE,
								     svt_axi_transaction::WRITELINEUNIQUE};};
      	  write_tran.coherent_xact_type = write_txn_type;
        end else begin 
         write_tran.coherent_xact_type = svt_axi_transaction::WRITENOSNOOP;
        end
        
        std::randomize(prot_type);
        write_tran.prot_type = svt_axi_transaction::DATA_SECURE_NORMAL; 

      write_tran.burst_type   = svt_axi_transaction::WRAP;
      case(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)
      	3: write_tran.burst_size   = svt_axi_transaction::BURST_SIZE_64BIT;
      	4: write_tran.burst_size   = svt_axi_transaction::BURST_SIZE_128BIT;
      	5: write_tran.burst_size   = svt_axi_transaction::BURST_SIZE_256BIT;
      	default:write_tran.burst_size   = svt_axi_transaction::BURST_SIZE_32BIT;
      endcase
      write_tran.atomic_type  = svt_axi_transaction::NORMAL;
      write_tran.burst_length = <%=((obj.AiuInfo[obj.Id].wData/8)<64)?64/(obj.AiuInfo[obj.Id].wData/8):1%>;

      if(size && (write_tran.port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE || write_tran.port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE))begin
      	std::randomize(_tmp)with{_tmp inside {[0:(size-1)]};};	
        snoop_adr=rdnsnp_addr_orig_que[core][_tmp];
        rdnsnp_addr_orig_que[core].delete(_tmp);
	write_tran.addr = snoop_adr;
     end

      if(write_tran.coherent_xact_type==svt_axi_transaction::WRITENOSNOOP)begin
       	write_tran.cache_type[2:0] = 3'b000;
       	write_tran.domain_type = svt_axi_transaction::SYSTEMSHAREABLE;
	if(start_addr0 == write_tran.port_cfg.innershareable_start_addr[0]) write_tran.addr = get_addr_for_domain(start_addr1,end_addr1,<%=obj.DutInfo.FUnitId%>,core,0);
	else write_tran.addr = get_addr_for_domain(start_addr0,end_addr0,<%=obj.DutInfo.FUnitId%>,core,0);
      end else begin
	if(!size)write_tran.addr = get_addr_for_domain(write_tran.port_cfg.innershareable_start_addr[0],write_tran.port_cfg.innershareable_start_addr[0]+4000,<%=obj.DutInfo.FUnitId%>,core,0);
       	write_tran.cache_type[2:0] = 3'b111;
       	write_tran.domain_type = svt_axi_transaction::INNERSHAREABLE;
      end
      
      write_tran.data         = new[write_tran.burst_length];
      write_tran.wstrb        = new[write_tran.burst_length];
      write_tran.data_user    = new[write_tran.burst_length];
      
       case(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)
       2: foreach(write_tran.wstrb[i])begin 
            write_tran.wstrb[i] = 32'h0000_000f;
          end       
       3:foreach(write_tran.wstrb[i]) begin 
            write_tran.wstrb[i] = 32'h0000_00ff;
          end
       4:foreach(write_tran.wstrb[i]) begin 
            write_tran.wstrb[i] = 32'h0000_ffff;
          end
       5:foreach(write_tran.wstrb[i]) begin 
            write_tran.wstrb[i] = 32'hffff_ffff;
          end
       default: `uvm_error("VS", $sformatf("Unsupported Size WXDATA"))
    endcase

        if($test$plusargs("long_delay_en")) begin
        write_tran.bready_delay=$urandom_range(30,60);
        end
      write_tran.wvalid_delay = new[write_tran.burst_length];
      foreach (write_tran.wvalid_delay[i]) begin
        write_tran.wvalid_delay[i]=i;
      end

      /** Send the write transaction */
      `uvm_send(write_tran)

      /** Wait for the write transaction to complete */
      get_response(rsp);

      `uvm_info("body", "AXI WRITE transaction completed", UVM_LOW);

        end


    `uvm_info("body", "Exiting...", UVM_LOW)
     
  endtask: body

endclass: snps_axi_master_snoop_seq

////////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
 ////////////////////////    Copyback Sequence    ////////////////////////////
/////////////////////////////////////////////////////////////////////////////

class snps_axi_master_copyback_seq extends snps_axi_master_seq;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length = 0;

  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }

  /** UVM Object Utility macro */
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `uvm_object_param_utils(snps_axi_master_copyback_seq)
   
  //seqr handle
  svt_axi_master_sequencer        m_write_seqr;
 
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr0,end_addr0,start_addr1,end_addr1; 
  int master_id,core;

  svt_axi_system_configuration axi_sys_cfg;
  svt_axi_transaction::coherent_xact_type_enum      read_txn_type;
  svt_axi_transaction::coherent_xact_type_enum      read_txn_type_1;
  svt_axi_transaction::coherent_xact_type_enum      write_txn_type;
  svt_axi_transaction::prot_type_enum prot_type;
  addr_trans_mgr    m_addr_mgr;
  bit [63:0] snoop_addr;
  /** Class Constructor */
  function new(string name="snps_axi_master_copyback_seq");
  super.new(name);
  m_addr_mgr = addr_trans_mgr::get_instance();
  m_addr_mgr.gen_memory_map();
 

  endfunction
  
  virtual task body();
   
    svt_axi_master_transaction write_tran, read_tran ,read_tran_1;
    svt_configuration get_cfg;
    bit status;
    int align;
    `uvm_info("body", "Entered ...", UVM_LOW)
   

    super.body();

    status = uvm_config_db #(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);

    /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end


core = 0;
<% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
  if( master_id ==<%=aiu_rpn+k-no_chi%> )begin
    core =<%=k%>; 
  end
<% }} %>


   m_addr_mgr.get_dmi_unit_addr_range(start_addr0,end_addr0,start_addr1,end_addr1);

    for(int i = 0; i < sequence_length; i++) begin


      /** Set up the read transaction */
      `uvm_create(read_tran)
      read_tran.port_cfg     = cfg;
      read_tran.port_cfg.enable_domain_based_addr_gen = 1;


      read_tran.xact_type    = svt_axi_transaction::COHERENT;
       if(read_tran.port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE)begin
	std::randomize(read_txn_type)with{read_txn_type inside {svt_axi_transaction::READUNIQUE};};
        read_tran.coherent_xact_type = read_txn_type;
        //std::randomize(prot_type)with{prot_type inside {svt_axi_transaction::DATA_SECURE_NORMAL,svt_axi_transaction::DATA_NON_SECURE_NORMAL};};
        //read_tran.prot_type = svt_axi_transaction::DATA_SECURE_NORMAL; 
       end else if(read_tran.port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE)begin
        std::randomize(read_txn_type)with{read_txn_type inside {svt_axi_transaction::READONCE,
								svt_axi_transaction::CLEANSHARED,
								svt_axi_transaction::CLEANINVALID,
								svt_axi_transaction::MAKEINVALID};};
        read_tran.coherent_xact_type = read_txn_type;
       end else begin 
        read_tran.coherent_xact_type = svt_axi_transaction::READNOSNOOP;
       end

       
      read_tran.burst_type   = svt_axi_transaction::WRAP;

      case(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)
      	3: read_tran.burst_size   = svt_axi_transaction::BURST_SIZE_64BIT;
      	4: read_tran.burst_size   = svt_axi_transaction::BURST_SIZE_128BIT;
      	5: read_tran.burst_size   = svt_axi_transaction::BURST_SIZE_256BIT;
      	default:read_tran.burst_size   = svt_axi_transaction::BURST_SIZE_32BIT;
      endcase

      read_tran.atomic_type  = svt_axi_transaction::NORMAL;
      read_tran.burst_length = <%=((obj.AiuInfo[obj.Id].wData/8)<64)?64/(obj.AiuInfo[obj.Id].wData/8):1%>;

      if(read_tran.coherent_xact_type==svt_axi_transaction::READNOSNOOP)begin
      	read_tran.domain_type = svt_axi_transaction::SYSTEMSHAREABLE;
	if(start_addr0 == read_tran.port_cfg.innershareable_start_addr[0]) read_tran.addr = get_addr_for_domain(start_addr1,end_addr1,<%=obj.DutInfo.FUnitId%>,core,0);
	else read_tran.addr = get_addr_for_domain(start_addr0,end_addr0,<%=obj.DutInfo.FUnitId%>,core,0);
	
      	read_tran.cache_type[1:0] = 2'b00;
      end else begin 
      	read_tran.domain_type = svt_axi_transaction::INNERSHAREABLE;
	read_tran.addr = get_addr_for_domain(read_tran.port_cfg.innershareable_start_addr[0],read_tran.port_cfg.innershareable_start_addr[0]+4000,<%=obj.DutInfo.FUnitId%>,core,0);
      	read_tran.cache_type[1] = 1;
        snoop_addr=read_tran.addr;
      end
      
     if(read_tran.coherent_xact_type==svt_axi_transaction::CLEANSHARED || read_tran.coherent_xact_type==svt_axi_transaction::CLEANINVALID || read_tran.coherent_xact_type==svt_axi_transaction::MAKEINVALID || read_tran.coherent_xact_type==svt_axi_transaction::CLEANUNIQUE || read_tran.coherent_xact_type== svt_axi_transaction::MAKEUNIQUE)begin
      read_tran.rresp        = new[1];
      read_tran.data         = new[1];
      read_tran.rready_delay = new[1];
      read_tran.data_user    = new[1];
      <% if (obj.fnNativeInterface == "ACE") { %>
      read_tran.coh_rresp    = new[1];
      <% } %>
     end else begin
      read_tran.rresp    = new[read_tran.burst_length];
      read_tran.data         = new[read_tran.burst_length];
      read_tran.rready_delay = new[read_tran.burst_length];
      read_tran.data_user    = new[read_tran.burst_length];
      <% if (obj.fnNativeInterface == "ACE") { %>
      read_tran.coh_rresp    = new[read_tran.burst_length];
      <% } %>
     end
      
      foreach (read_tran.rready_delay[i]) begin
        read_tran.rready_delay[i]=i;
      end

      /** Send the read transaction */
      `uvm_send(read_tran)

      /** Wait for the read transaction to complete */
      get_response(rsp);
    
      `uvm_info("body", "AXI READ transaction completed", UVM_LOW);
     

      /** Set up the write transaction */
      `uvm_create(write_tran)
      write_tran.port_cfg     = cfg;
      write_tran.xact_type    = svt_axi_transaction::COHERENT;
      write_tran.port_cfg.data_transfer_for_makeinvalid_snoop_enable    = 1;

       if(write_tran.port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE)begin
          std::randomize(write_txn_type)with{write_txn_type inside { svt_axi_transaction::WRITECLEAN,
								     svt_axi_transaction::WRITEBACK,
								     svt_axi_transaction::EVICT,
								     svt_axi_transaction::WRITEEVICT};};
      	  write_tran.coherent_xact_type = write_txn_type;
	  if(write_txn_type == svt_axi_transaction::WRITEEVICT || write_txn_type == svt_axi_transaction::EVICT) begin
          	write_tran.port_cfg.writeevict_enable = 1;
	 	write_tran.port_cfg.awunique_enable = 1;
	  end
      	  //write_tran.prot_type = prot_type ; 
       end else if(write_tran.port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE)begin
          std::randomize(write_txn_type)with{write_txn_type inside { svt_axi_transaction::WRITEUNIQUE,
								     svt_axi_transaction::WRITELINEUNIQUE};};
      	  write_tran.coherent_xact_type = write_txn_type;
        end else begin 
          write_tran.coherent_xact_type = svt_axi_transaction::WRITENOSNOOP;
        end
        

      write_tran.burst_type   = svt_axi_transaction::WRAP;
      case(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)
      	3: write_tran.burst_size   = svt_axi_transaction::BURST_SIZE_64BIT;
      	4: write_tran.burst_size   = svt_axi_transaction::BURST_SIZE_128BIT;
      	5: write_tran.burst_size   = svt_axi_transaction::BURST_SIZE_256BIT;
      	default:write_tran.burst_size   = svt_axi_transaction::BURST_SIZE_32BIT;
      endcase
      write_tran.atomic_type  = svt_axi_transaction::NORMAL;
      write_tran.burst_length = <%=((obj.AiuInfo[obj.Id].wData/8)<64)?64/(obj.AiuInfo[obj.Id].wData/8):1%>;

      if(write_tran.coherent_xact_type==svt_axi_transaction::WRITENOSNOOP)begin
       	write_tran.cache_type[2:0] = 3'b000;
       	write_tran.domain_type = svt_axi_transaction::SYSTEMSHAREABLE;
	if(start_addr0 == write_tran.port_cfg.innershareable_start_addr[0]) write_tran.addr = get_addr_for_domain(start_addr1,end_addr1,<%=obj.DutInfo.FUnitId%>,core,0);
	else write_tran.addr = get_addr_for_domain(start_addr0,end_addr0,<%=obj.DutInfo.FUnitId%>,core,0);
	
      end else begin
	write_tran.addr = snoop_addr;
       	write_tran.cache_type[2:0] = 3'b111;
       	write_tran.domain_type = svt_axi_transaction::INNERSHAREABLE;
      end
      
      write_tran.data         = new[write_tran.burst_length];
      write_tran.wstrb        = new[write_tran.burst_length];
      write_tran.data_user    = new[write_tran.burst_length];
      
       case(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)
       2: foreach(write_tran.wstrb[i])begin 
            write_tran.wstrb[i] = 32'h0000_000f;
          end       
       3:foreach(write_tran.wstrb[i]) begin 
            write_tran.wstrb[i] = 32'h0000_00ff;
          end
       4:foreach(write_tran.wstrb[i]) begin 
            write_tran.wstrb[i] = 32'h0000_ffff;
          end
       5:foreach(write_tran.wstrb[i]) begin 
            write_tran.wstrb[i] = 32'hffff_ffff;
          end
       default: `uvm_error("VS", $sformatf("Unsupported Size WXDATA"))
    endcase

      write_tran.wvalid_delay = new[write_tran.burst_length];
      foreach (write_tran.wvalid_delay[i]) begin
        write_tran.wvalid_delay[i]=i;
      end

      /** Send the write transaction */
      `uvm_send(write_tran)

      /** Wait for the write transaction to complete */
      get_response(rsp);

      `uvm_info("body", "AXI WRITE transaction completed", UVM_LOW);



     //  /** Set up the read transaction */
     // `uvm_create(read_tran_1)
     // read_tran_1.port_cfg     = cfg;
     // read_tran_1.port_cfg.enable_domain_based_addr_gen = 1;
     // read_tran_1.xact_type    = svt_axi_transaction::COHERENT;
     // if( read_tran_1.port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE)begin
     //    std::randomize(read_txn_type_1)with{read_txn_type_1 inside{    svt_axi_transaction::READCLEAN,
     //   								svt_axi_transaction::READUNIQUE,
     //   								svt_axi_transaction::READONCE,
     //   								svt_axi_transaction::READNOTSHAREDDIRTY,
     //   								svt_axi_transaction::READSHARED,
     //   								svt_axi_transaction::CLEANSHARED,
     //   								svt_axi_transaction::CLEANUNIQUE,
     //   								svt_axi_transaction::MAKEUNIQUE,
     //   								svt_axi_transaction::CLEANINVALID,
     //   								svt_axi_transaction::MAKEINVALID};};
     //   read_tran_1.coherent_xact_type = read_txn_type_1;	
     //   //read_tran_1.prot_type = svt_axi_transaction::DATA_SECURE_NORMAL; 
     // end else if(read_tran_1.port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE)begin
     //   std::randomize(read_txn_type_1)with{read_txn_type_1 inside {svt_axi_transaction::READONCE,
     //   							svt_axi_transaction::CLEANSHARED,
     //   							svt_axi_transaction::CLEANINVALID,
     //   							svt_axi_transaction::MAKEINVALID};};
     //   read_tran_1.coherent_xact_type = read_txn_type_1;
     // end else begin
     //   read_tran_1.coherent_xact_type = svt_axi_transaction::READNOSNOOP;
     // end
     // 
     // read_tran_1.burst_type   = svt_axi_transaction::WRAP;
     // case(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)

     // 3: read_tran_1.burst_size   = svt_axi_transaction::BURST_SIZE_64BIT;
     // 4: read_tran_1.burst_size   = svt_axi_transaction::BURST_SIZE_128BIT;
     // 5: read_tran_1.burst_size   = svt_axi_transaction::BURST_SIZE_256BIT;
     // default:read_tran_1.burst_size   = svt_axi_transaction::BURST_SIZE_32BIT;
     // endcase
     // read_tran_1.atomic_type  = svt_axi_transaction::NORMAL;
     // read_tran_1.burst_length = <%=((obj.AiuInfo[obj.Id].wData/8)<64)?64/(obj.AiuInfo[obj.Id].wData/8):1%>;

     // if(read_tran_1.coherent_xact_type == svt_axi_transaction::READNOSNOOP) begin
     //     read_tran_1.cache_type[1:0] = 2'b00;
     //     read_tran_1.domain_type = svt_axi_transaction::SYSTEMSHAREABLE;
     //     if(start_addr0 == read_tran_1.port_cfg.innershareable_start_addr[0]) read_tran_1.addr = get_addr_for_domain(start_addr1,end_addr1,<%=obj.DutInfo.FUnitId%>,core,0);
     //     else read_tran_1.addr = get_addr_for_domain(start_addr0,end_addr0,<%=obj.DutInfo.FUnitId%>,core,0);
     //     
     // end else begin 
     //     read_tran_1.addr = get_addr_for_domain(read_tran_1.port_cfg.innershareable_start_addr[0],read_tran_1.port_cfg.innershareable_start_addr[0]+4000,<%=obj.DutInfo.FUnitId%>,core,0);
     //     read_tran_1.cache_type[1:0] = 2'b11;
     //     read_tran_1.domain_type = svt_axi_transaction::INNERSHAREABLE;
     // end
     // 
     // if(read_tran_1.coherent_xact_type==svt_axi_transaction::CLEANSHARED || read_tran_1.coherent_xact_type==svt_axi_transaction::CLEANINVALID || read_tran_1.coherent_xact_type==svt_axi_transaction::MAKEINVALID || read_tran_1.coherent_xact_type==svt_axi_transaction::CLEANUNIQUE || read_tran_1.coherent_xact_type== svt_axi_transaction::MAKEUNIQUE)begin
     // read_tran_1.rresp        = new[1];
     // read_tran_1.data         = new[1];
     // read_tran_1.rready_delay = new[1];
     // read_tran_1.data_user    = new[1];
     // <% if (obj.fnNativeInterface == "ACE") { %>
     // read_tran_1.coh_rresp    = new[1];
     // <% } %>
     //end else begin
     // read_tran_1.rresp    = new[read_tran_1.burst_length];
     // read_tran_1.data         = new[read_tran_1.burst_length];
     // read_tran_1.rready_delay = new[read_tran_1.burst_length];
     // read_tran_1.data_user    = new[read_tran_1.burst_length];
     // <% if (obj.fnNativeInterface == "ACE") { %>
     // read_tran_1.coh_rresp    = new[read_tran_1.burst_length];
     // <% } %>
     //end

     // 
     // foreach (read_tran_1.rready_delay[i]) begin
     //   read_tran_1.rready_delay[i]=i;
     // end

     // /** Send the read transaction */
     // `uvm_send(read_tran_1)

     // /** Wait for the read transaction to complete */
     // get_response(rsp);
     // `uvm_info("body", "AXI READ transaction completed_2", UVM_LOW);


        end

    `uvm_info("body", "Exiting...", UVM_LOW)
     
  endtask: body


endclass: snps_axi_master_copyback_seq

////////////////////////////////////////////////////////////////////////////////


  /////////////////////////////////////////////////////////////////////////////
 ////////////////////    Read Outstanding Sequence    ////////////////////////
/////////////////////////////////////////////////////////////////////////////

class snps_axi_master_outstanding_read_seq extends snps_axi_master_seq;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length = 10;

  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }

  /** UVM Object Utility macro */
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `uvm_object_param_utils(snps_axi_master_outstanding_read_seq)
   
  //seqr handle
  svt_axi_master_sequencer        m_write_seqr;
 
 bit [63:0] start_addr_q[$],start_addr,end_addr,addr;
 bit [63:0] end_addr_q[$];
 bit [63:0] start_addr_coh_q[$];
 bit [63:0] end_addr_coh_q[$];
 bit [63:0] domain_size;
 bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr0,end_addr0,start_addr1,end_addr1; 
 int align;
	 int size, _tmp;
  int master_id,core,incr_len,wrap_len;
   int primary_bits[$] = ncoreConfigInfo::mp_aiu_intv_bits[<%=obj.DutInfo.FUnitId%>].pri_bits;
   bit check_addr_unconnected = 0;
   int timeout;

 
    svt_axi_system_configuration axi_sys_cfg;
    svt_axi_transaction::coherent_xact_type_enum      txn_type;
    addr_trans_mgr    m_addr_mgr;
    ncoreConfigInfo::intq noncoh_regionsq;
    ncoreConfigInfo::intq coh_regionsq;
    ncoreConfigInfo::intq iocoh_regionsq;
    ncore_memory_map m_mem;
 
  /** Class Constructor */
  function new(string name="snps_axi_master_outstanding_read_seq");
    super.new(name);

     m_addr_mgr = addr_trans_mgr::get_instance();
     m_addr_mgr.gen_memory_map();
     m_mem = m_addr_mgr.get_memory_map_instance(); 
     noncoh_regionsq = m_mem.get_noncoh_mem_regions();
     iocoh_regionsq = m_mem.get_iocoh_mem_regions();
     coh_regionsq = m_mem.get_coh_mem_regions();

     foreach(iocoh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(iocoh_regionsq[indx], start_addr, end_addr);
	if (indx != 0) begin
        start_addr_coh_q.push_back(start_addr);
        end_addr_coh_q.push_back(end_addr);
        //`uvm_info("func",$psprintf("iocoh_start_arry[%0d] is %0h  &  iocoh_end_arry[%0d] is %0h", indx, start_addr, indx, end_addr),UVM_LOW)
	end
     end
     foreach(noncoh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(noncoh_regionsq[indx], start_addr, end_addr);
	//if (indx != 0) begin
        start_addr_q.push_back(start_addr);
        end_addr_q.push_back(end_addr);
        //`uvm_info("func",$psprintf("noncoh_start_arry[%0d] is %0h  &  noncoh_end_arry[%0d] is %0h", indx, start_addr, indx, end_addr),UVM_LOW)
	//end
     end 
     //m_addr_mgr.get_dmi_unit_addr_range(start_addr0,end_addr0,start_addr1,end_addr1);
     //start_addr_q.push_back(start_addr1);
     //end_addr_q.push_back(end_addr1);
     size = start_addr_q.size();
        `uvm_info("func",$psprintf(" size is %d",  size),UVM_LOW)

  endfunction
  
  virtual task body();
   
    svt_axi_master_transaction read_tran ,read_tran_1;
    svt_configuration get_cfg;
    int inner_domain_masters_0[];
    bit status;
    `uvm_info("body", "Entered ...", UVM_LOW)
   

    super.body();

    status = uvm_config_db #(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);
    `uvm_info("body", $sformatf("sequence_length is %0d as a result of %0s. start_arry:%0p end_arry:%0p", sequence_length, status ? "config DB" : "randomization", start_addr_q,end_addr_q), UVM_LOW);

    /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end
core = 0;
<% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
  if( master_id ==<%=aiu_rpn+k-no_chi%> )begin
    core =<%=k%>; 
  end
<% }} %>


    for(int i = 0; i <sequence_length; i++) begin

      	/** Set up the read transaction */
      	`uvm_create(read_tran)
      	read_tran.port_cfg     = cfg;
      	read_tran.port_cfg.enable_domain_based_addr_gen = 1;

    	`uvm_info("body", $sformatf("sequence_length is %0d as a result of %0s. start_arry:%0p end_arry:%0p", sequence_length, status ? "config DB" : "randomization",read_tran.port_cfg.innershareable_start_addr,read_tran.port_cfg.innershareable_end_addr ), UVM_LOW);

      	std::randomize(_tmp)with{_tmp inside {[0:(size-1)]};};	
	//std::randomize(addr)with{addr inside {[start_addr_q[_tmp]:end_addr_q[_tmp]]};};
        addr  = get_addr_for_domain(start_addr_q[_tmp],end_addr_q[_tmp],<%=obj.DutInfo.FUnitId%>,core,1);
        create_len_for_connected_acess(addr,<%=Math.log2(aiu_axiInt.params.wData/8)%>,incr_len,wrap_len);
      	
	read_tran.xact_type    = svt_axi_transaction::COHERENT;
        read_tran.coherent_xact_type = svt_axi_transaction::READNOSNOOP;
       
        if($test$plusargs("long_delay_en")) begin
	read_tran.addr_valid_delay    =100;
        end

      	case(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)
      		3: read_tran.burst_size   = svt_axi_transaction::BURST_SIZE_64BIT;
      		4: read_tran.burst_size   = svt_axi_transaction::BURST_SIZE_128BIT;
      		5: read_tran.burst_size   = svt_axi_transaction::BURST_SIZE_256BIT;
      		default:read_tran.burst_size   = svt_axi_transaction::BURST_SIZE_32BIT;
      	endcase

      	read_tran.burst_type   = svt_axi_transaction::INCR;
        if($test$plusargs("same_id")) begin
      	read_tran.id   = 8;
        end else begin
	read_tran.id   		= $urandom_range(0,31);   		
	end   		

      	read_tran.burst_length = <%=((obj.AiuInfo[obj.Id].wData/8)<64)?64/(obj.AiuInfo[obj.Id].wData/8):1%>;
      	read_tran.domain_type = svt_axi_transaction::SYSTEMSHAREABLE;
      	//read_tran.cache_type[1:0] = 2'b00;
	std::randomize(read_tran.cache_type)with{read_tran.cache_type inside {0,1,2,3};};
	
	align = (2**(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)) * read_tran.burst_length;
	read_tran.addr = (addr/align)*align;

      	read_tran.atomic_type  = svt_axi_transaction::NORMAL;

      	read_tran.rresp        = new[read_tran.burst_length];
      	<% if (obj.fnNativeInterface == "ACE") { %>
      	read_tran.coh_rresp    = new[read_tran.burst_length];
      	<% } %>
      	read_tran.data         = new[read_tran.burst_length];
      	read_tran.rready_delay = new[read_tran.burst_length];
      	read_tran.data_user    = new[read_tran.burst_length];
      	foreach (read_tran.rready_delay[i]) begin
        if($test$plusargs("long_delay_en")) begin
        	read_tran.rready_delay[i]=$urandom_range(10,50);
        end else begin
        	read_tran.rready_delay[i]=$urandom_range(4,16);
        end
      	end
      foreach (read_tran.rvalid_delay[i]) begin
        read_tran.rvalid_delay[i]=$urandom_range(4,16);
      end
        if($test$plusargs("long_delay_en")) begin
        read_tran.bready_delay=$urandom_range(30,60);
        end


/** Set up the 2nd read transaction */

	`uvm_create(read_tran_1)
      	read_tran_1.port_cfg     = cfg;
      	read_tran_1.port_cfg.enable_domain_based_addr_gen = 1;

      	
	read_tran_1.xact_type    	= read_tran.xact_type;    	  
        read_tran_1.coherent_xact_type 	= read_tran.coherent_xact_type;
        read_tran_1.burst_size   	= read_tran.burst_size;	
                                                                        
      	read_tran_1.burst_type   	= read_tran.burst_type;  	
        if($test$plusargs("same_id")) begin
      	read_tran_1.id   		= read_tran.id;		
        end else begin
	read_tran_1.id   		= $urandom_range(0,31);   		
	end   		

      	read_tran_1.burst_length 	= read_tran.burst_length; 	
      	read_tran_1.domain_type 	= read_tran.domain_type;	
      	read_tran_1.cache_type	 	= read_tran.cache_type; 	
	                                  
	read_tran_1.addr 		= read_tran.addr; 		
      	read_tran_1.atomic_type  	= read_tran.atomic_type; 	
      	read_tran_1.rresp        	= new[read_tran.burst_length];   	
      	<% if (obj.fnNativeInterface == "ACE") { %>
      	read_tran_1.coh_rresp    	= new[read_tran.burst_length];
      	<% } %>
      	read_tran_1.data         	= new[read_tran.burst_length];
      	read_tran_1.rready_delay 	= new[read_tran.burst_length];
      	read_tran_1.data_user   	= new[read_tran.burst_length];
	foreach (read_tran_1.rready_delay[i]) begin
        if($test$plusargs("long_delay_en")) begin
          read_tran_1.rready_delay[i]=$urandom_range(10,50);
        end else begin
        	read_tran_1.rready_delay[i]=$urandom_range(4,16);
        end
      	end
      foreach (read_tran_1.rvalid_delay[i]) begin
        read_tran_1.rvalid_delay[i]=$urandom_range(4,16);
      end
        if($test$plusargs("long_delay_en")) begin
        read_tran_1.bready_delay=$urandom_range(30,60);
        end


	`uvm_send(read_tran)
    	`uvm_info("body",$sformatf(" READ sent... at %t",$time), UVM_LOW)

	`uvm_send(read_tran_1)
    	`uvm_info("body",$sformatf(" READ_2 sent... at %t",$time), UVM_LOW)

	end

    `uvm_info("body", "Exiting...", UVM_LOW)
     
  endtask: body

endclass: snps_axi_master_outstanding_read_seq

////////////////////////////////////////////////////////////////////////////////


  /////////////////////////////////////////////////////////////////////////////
 ////////////////////    Write Outstanding Sequence    ///////////////////////
/////////////////////////////////////////////////////////////////////////////

class snps_axi_master_outstanding_write_seq extends snps_axi_master_seq;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length = 10;

  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }

  /** UVM Object Utility macro */
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `uvm_object_param_utils(snps_axi_master_outstanding_write_seq)
   
  //seqr handle
  svt_axi_master_sequencer        m_write_seqr;
 
 bit [63:0] start_addr_q[$],start_addr,end_addr,addr;
 bit [63:0] end_addr_q[$];
 bit [63:0] start_addr_coh_q[$];
 bit [63:0] end_addr_coh_q[$];
 bit [63:0] domain_size;
 bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr0,end_addr0,start_addr1,end_addr1; 
 int align;
 int size, _tmp;
  int master_id,core,incr_len,wrap_len;

 
    svt_axi_system_configuration axi_sys_cfg;
    svt_axi_transaction::coherent_xact_type_enum      txn_type;
    addr_trans_mgr    m_addr_mgr;
    ncoreConfigInfo::intq noncoh_regionsq;
    ncoreConfigInfo::intq coh_regionsq;
    ncoreConfigInfo::intq iocoh_regionsq;
    ncore_memory_map m_mem;
 
  /** Class Constructor */
  function new(string name="snps_axi_master_outstanding_write_seq");
    super.new(name);

     m_addr_mgr = addr_trans_mgr::get_instance();
     m_addr_mgr.gen_memory_map();
     m_mem = m_addr_mgr.get_memory_map_instance(); 
     noncoh_regionsq = m_mem.get_noncoh_mem_regions();
     iocoh_regionsq = m_mem.get_iocoh_mem_regions();
     coh_regionsq = m_mem.get_coh_mem_regions();

     foreach(iocoh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(iocoh_regionsq[indx], start_addr, end_addr);
	if (indx != 0) begin
        start_addr_coh_q.push_back(start_addr);
        end_addr_coh_q.push_back(end_addr);
        //`uvm_info("func",$psprintf("iocoh_start_arry[%0d] is %0h  &  iocoh_end_arry[%0d] is %0h", indx, start_addr, indx, end_addr),UVM_NONE)
	end
     end
     foreach(noncoh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(noncoh_regionsq[indx], start_addr, end_addr);
	///if (indx != 0) begin
        start_addr_q.push_back(start_addr);
        end_addr_q.push_back(end_addr);
       // `uvm_info("func",$psprintf("noncoh_start_arry[%0d] is %0h  &  noncoh_end_arry[%0d] is %0h", indx, start_addr, indx, end_addr),UVM_NONE)
	//end
     end 
     //m_addr_mgr.get_dmi_unit_addr_range(start_addr0,end_addr0,start_addr1,end_addr1);
     //start_addr_q.push_back(start_addr1);
     //end_addr_q.push_back(end_addr1);
     size = start_addr_q.size();
        `uvm_info("func",$psprintf(" & size is %d", size),UVM_NONE)

  endfunction
  
  virtual task body();
   
    svt_axi_master_transaction write_tran, write_tran_1;
    svt_configuration get_cfg;
    bit status;
    `uvm_info("body", "Entered ...", UVM_LOW)
   

    super.body();

    status = uvm_config_db #(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);
    `uvm_info("body", $sformatf("sequence_length is %0d as a result of %0s. start_arry:%0p end_arry:%0p", sequence_length, status ? "config DB" : "randomization", start_addr_q,end_addr_q), UVM_LOW);

    /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end


    core = 0;
    <% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
      if( master_id ==<%=aiu_rpn+k-no_chi%> )begin
        core =<%=k%>; 
      end
    <% }} %>

    for(int i = 0; i <sequence_length; i++) begin



      	std::randomize(_tmp)with{_tmp inside {[0:(size-1)]};};	
	//std::randomize(addr)with{addr inside {[start_addr_q[_tmp]:end_addr_q[_tmp]]};};

      addr =get_addr_for_domain(start_addr_q[_tmp],end_addr_q[_tmp],<%=obj.DutInfo.FUnitId%>,core,1);
        create_len_for_connected_acess(addr,<%=Math.log2(aiu_axiInt.params.wData/8)%>,incr_len,wrap_len);
	
      	/** Set up the write transaction */
      	`uvm_create(write_tran)
     	write_tran.port_cfg     = cfg;
      	write_tran.port_cfg.enable_domain_based_addr_gen = 1;


     	write_tran.xact_type    = svt_axi_transaction::COHERENT;
        write_tran.coherent_xact_type = svt_axi_transaction::WRITENOSNOOP;
        

        if($test$plusargs("long_delay_en")) begin
	write_tran.addr_valid_delay    =100;
        end
      	case(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)
      		3: write_tran.burst_size   = svt_axi_transaction::BURST_SIZE_64BIT;
	      	4: write_tran.burst_size   = svt_axi_transaction::BURST_SIZE_128BIT;
	      	5: write_tran.burst_size   = svt_axi_transaction::BURST_SIZE_256BIT;
      		default:write_tran.burst_size   = svt_axi_transaction::BURST_SIZE_32BIT;
      	endcase

      	write_tran.burst_length = <%=((obj.AiuInfo[obj.Id].wData/8)<64)?64/(obj.AiuInfo[obj.Id].wData/8):1%>;
       	write_tran.domain_type = svt_axi_transaction::SYSTEMSHAREABLE;
       	//write_tran.cache_type[2:0] = 3'b000;
	std::randomize(write_tran.cache_type)with{write_tran.cache_type inside {0,1,2,3};};
      	write_tran.burst_type   = svt_axi_transaction::INCR;
        if($test$plusargs("same_id")) begin
	write_tran.id   = 8;
        end else begin
	write_tran.id   		= $urandom_range(0,31);   		
	end   		

	align = (2**(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)) * write_tran.burst_length;
	write_tran.addr = (addr/align)*align;

       	write_tran.atomic_type  = svt_axi_transaction::NORMAL;

      write_tran.data         = new[write_tran.burst_length];
      write_tran.wstrb        = new[write_tran.burst_length];
      write_tran.data_user    = new[write_tran.burst_length];
      
       case(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)
       2: foreach(write_tran.wstrb[i])begin 
            write_tran.wstrb[i] = 32'h0000_000f;
          end       
       3:foreach(write_tran.wstrb[i]) begin 
            write_tran.wstrb[i] = 32'h0000_00ff;
          end
       4:foreach(write_tran.wstrb[i]) begin 
            write_tran.wstrb[i] = 32'h0000_ffff;
          end
       5:foreach(write_tran.wstrb[i]) begin 
            write_tran.wstrb[i] = 32'hffff_ffff;
          end
       default: `uvm_error("VS", $sformatf("Unsupported Size WXDATA"))
    endcase

      write_tran.wvalid_delay = new[write_tran.burst_length];
      foreach (write_tran.wvalid_delay[i]) begin
        write_tran.wvalid_delay[i]=$urandom_range(4,16);
      end
      foreach (write_tran.wready_delay[i]) begin
        if($test$plusargs("long_delay_en")) begin
 write_tran.wready_delay[i]=$urandom_range(10,50);
        end else begin
        write_tran.wready_delay[i]=$urandom_range(4,16);
        end
      end
        if($test$plusargs("long_delay_en")) begin
      write_tran.bready_delay=$urandom_range(30,60);
        end


/** Set up 2nd the write transaction */
      	`uvm_create(write_tran_1)
     	write_tran_1.port_cfg     = cfg;
     	write_tran_1.xact_type    = svt_axi_transaction::COHERENT;

        write_tran_1.coherent_xact_type = write_tran.coherent_xact_type; 	
	write_tran_1.burst_size   	= write_tran.burst_size;   	
                                                                          
      	write_tran_1.burst_length 	= write_tran.burst_length; 	
       	write_tran_1.domain_type 	= write_tran.domain_type; 		
       	write_tran_1.cache_type 	= write_tran.cache_type; 	
      	write_tran_1.burst_type   	= write_tran.burst_type;   	
        if($test$plusargs("same_id")) begin
	write_tran_1.id   		= write_tran.id;   		
        end else begin
	write_tran_1.id   		= $urandom_range(0,31);
	end   		
                                                                          
      	write_tran_1.addr         	= write_tran.addr;         	
                                                                          
       	write_tran_1.atomic_type  	= write_tran.atomic_type;  	

      	write_tran_1.data         	= new[write_tran_1.burst_length];
      	write_tran_1.wstrb        	= new[write_tran_1.burst_length];
      	write_tran_1.data_user    	= new[write_tran_1.burst_length];
      	write_tran_1.wvalid_delay 	= new[write_tran_1.burst_length];
      
       	foreach(write_tran_1.wstrb[i]) begin 
            write_tran_1.wstrb[i] = write_tran.wstrb[i];
	end
        if($test$plusargs("long_delay_en")) begin
	write_tran_1.addr_valid_delay    =100;
	end

      foreach (write_tran_1.wvalid_delay[i]) begin
        write_tran_1.wvalid_delay[i]=$urandom_range(4,16);
      end
      foreach (write_tran_1.wready_delay[i]) begin
        write_tran_1.wready_delay[i]=$urandom_range(4,16);
//write_tran_1.wready_delay[i]=$urandom_range(10,50);
      end
        if($test$plusargs("long_delay_en")) begin
        write_tran_1.bready_delay=$urandom_range(30,60);
	end



	`uvm_send(write_tran)
    	`uvm_info("body",$sformatf(" WRITE sent... at %t",$time), UVM_LOW)


	`uvm_send(write_tran_1)
    	`uvm_info("body",$sformatf(" WRITE_2 sent... at %t",$time), UVM_LOW)
      	
    end

    `uvm_info("body", "Exiting...", UVM_LOW)
     
  endtask: body

endclass: snps_axi_master_outstanding_write_seq

////////////////////////////////////////////////////////////////////////////////

class snps_ace_dvm_outstanding_seq extends snps_axi_master_seq;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length = 10;

  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }

  /** UVM Object Utility macro */
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `uvm_object_param_utils(snps_ace_dvm_outstanding_seq)
   
  //seqr handle
  svt_axi_master_sequencer        m_write_seqr;
 
    svt_axi_port_configuration mst_cfg[<%=aiu_NumCores%>];
 bit [63:0] start_addr_q[$],start_addr,end_addr,addr,new_addr;
 bit [63:0] end_addr_q[$];
 bit [63:0] start_addr_coh_q[$];
 bit [63:0] end_addr_coh_q[$];
 bit [63:0] domain_size;
 bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr0,end_addr0,start_addr1,end_addr1; 
 int align;
	 int size, _tmp;
  int master_id,core,incr_len,wrap_len;
   int primary_bits[$] = ncoreConfigInfo::mp_aiu_intv_bits[<%=obj.DutInfo.FUnitId%>].pri_bits;
   bit check_addr_unconnected = 0;
   int timeout;
    bit [`SVT_AXI_MAX_ID_WIDTH - 1:0] dvm_id = 0;

 
    svt_axi_system_configuration axi_sys_cfg;
    svt_axi_transaction::coherent_xact_type_enum      txn_type;
    addr_trans_mgr    m_addr_mgr;
    ncoreConfigInfo::intq noncoh_regionsq;
    ncoreConfigInfo::intq coh_regionsq;
    ncoreConfigInfo::intq iocoh_regionsq;
    ncore_memory_map m_mem;
 
  /** Class Constructor */
  function new(string name="snps_ace_dvm_outstanding_seq");
    super.new(name);

  endfunction
  
  virtual task body();
   
    svt_axi_master_transaction read_tran ,read_tran_1;
    svt_configuration get_cfg;
    int inner_domain_masters_0[];
    bit status;
    `uvm_info("body", "Entered ...", UVM_LOW)
   

    super.body();

    status = uvm_config_db #(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);
    `uvm_info("body", $sformatf("sequence_length is %0d as a result of %0s. start_arry:%0p end_arry:%0p", sequence_length, status ? "config DB" : "randomization", start_addr_q,end_addr_q), UVM_LOW);


    /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end
core = 0;
<% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
  if( master_id ==<%=aiu_rpn+k-no_chi%> )begin
    core =<%=k%>; 
  end
<% }} %>


    for(int i = 0; i <sequence_length; i++) begin

       randcase 
        1 : dvm_id =8;
        1 : dvm_id   		= $urandom_range(0,31);
       endcase

      	/** Set up the read transaction */
      	`uvm_create(read_tran)
        
         assert(read_tran.randomize() with {
              port_cfg     == cfg;
              coherent_xact_type inside {svt_axi_transaction::DVMMESSAGE,svt_axi_transaction::DVMCOMPLETE};
              if(coherent_xact_type==svt_axi_transaction::DVMCOMPLETE){ addr==0;
             } else { addr[14:12] inside {'b000, 'b001, 'b010, 'b011,'b100}; } 
	      xact_type    == svt_axi_transaction::COHERENT;
	      burst_size == <%=Math.log2(aiu_axiInt.params.wData/8)%>;
	      burst_type   == svt_axi_transaction::INCR;
              id == dvm_id ;
	      burst_length == 1;
	      cache_type[3:0] == 'b0010;
	      domain_type == svt_axi_transaction::INNERSHAREABLE;
      	      atomic_type  == svt_axi_transaction::NORMAL;
}); 

/** Set up the 2nd read transaction */

        if(dvm_id==8) begin
      	dvm_id  = 8;
        end else begin
	dvm_id   		= $urandom_range(9,31);   		
	end   		

	`uvm_create(read_tran_1)

 assert(read_tran_1.randomize() with {
              port_cfg     == cfg;
              coherent_xact_type == svt_axi_transaction::DVMMESSAGE;
              addr[14:12]=='b000;
	      xact_type    == svt_axi_transaction::COHERENT;
	      burst_size == <%=Math.log2(aiu_axiInt.params.wData/8)%>;
	      burst_type   == svt_axi_transaction::INCR;
	      burst_length == 1;
              id == dvm_id ;
	      cache_type[3:0] == 'b0010;
	      domain_type == svt_axi_transaction::INNERSHAREABLE;
      	      atomic_type  == svt_axi_transaction::NORMAL;
});
      
	`uvm_send(read_tran)
    	`uvm_info("body",$sformatf(" READ sent... at %t addr is %0h",$time,read_tran.addr), UVM_LOW)

	`uvm_send(read_tran_1)
    	`uvm_info("body",$sformatf(" READ_2 sent... at %t addr %0h",$time,read_tran_1.addr), UVM_LOW)

	end

    `uvm_info("body", "Exiting...", UVM_LOW)
     
  endtask: body

endclass: snps_ace_dvm_outstanding_seq

////////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
 ////////////////////////    Exclusive Sequence    ///////////////////////////
/////////////////////////////////////////////////////////////////////////////

class snps_axi_master_exclusive_seq extends snps_axi_master_seq;

 rand int unsigned sequence_length = 10;

 constraint reasonable_sequence_length {
    sequence_length <= 100;
  }

 bit [63:0] start_addr_noncoh_q[$],start_addr,end_addr,coh_addr;
 bit [63:0] end_addr_noncoh_q[$];
 bit [63:0] domain_size;
 bit [1:0]  cache_line_state=0;

 bit [63:0] start_addr_coh_q[$];
 bit [63:0] end_addr_coh_q[$];
 bit [63:0] start_addr_q[$];
 bit [63:0] end_addr_q[$];


  svt_axi_system_configuration axi_sys_cfg;
   svt_axi_transaction::coherent_xact_type_enum      txn_type;
   bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr0,end_addr0,start_addr1,end_addr1;  
   addr_trans_mgr    m_addr_mgr;
   svt_axi_master_transaction load, store, _tmp_xact;

   ncoreConfigInfo::intq noncoh_regionsq;
   ncoreConfigInfo::intq coh_regionsq;
   ncoreConfigInfo::intq iocoh_regionsq;
   ncore_memory_map m_mem;

  /** UVM Object Utility macro */
   `uvm_declare_p_sequencer(svt_axi_master_sequencer)
  `uvm_object_param_utils(snps_axi_master_exclusive_seq)

   rand bit                              init_cachelines;
   svt_axi_transaction::burst_size_enum  exclusive_accesses_burst_size;
   rand int ace_exclusive_select =0 ;
   int _tmp ,core,master_id,wrap_len,incr_len,size;


   function new(string name = "snps_axi_master_exclusive_seq");
    super.new(name);
    m_addr_mgr = addr_trans_mgr::get_instance();
    m_addr_mgr.gen_memory_map();
    m_mem = m_addr_mgr.get_memory_map_instance(); 
    noncoh_regionsq = m_mem.get_noncoh_mem_regions();

     foreach(noncoh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(noncoh_regionsq[indx], start_addr, end_addr);
        start_addr_coh_q.push_back(start_addr);
        end_addr_coh_q.push_back(end_addr);
        //`uvm_info("func",$psprintf("iocoh_start_arry[%0d] is %0h  &  iocoh_end_arry[%0d] is %0h", indx, start_addr, indx, end_addr),UVM_NONE)
     end

   endfunction
   
   task body();

   bit rand_success;
   int port_offset, port_num, excl_seq_mode, id_width,align;
   svt_axi_transaction::coherent_xact_type_enum    txn_type;
   svt_configuration get_cfg;
   bit[1:0] state;

   super.body();

   /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end

core = 0;
    <% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
  	if( master_id ==<%=aiu_rpn+k-no_chi%> )begin
    	    core =<%=k%>; 
  	end
    <% }} %>

size=start_addr_coh_q.size();
    m_addr_mgr.get_dmi_unit_addr_range(start_addr0,end_addr0,start_addr1,end_addr1);
<% if ((obj.fnNativeInterface != "AXI4") ) { %>

  for(int i = 0; i <sequence_length; i++) begin

   `svt_xvm_create(load)
    load.port_cfg     = cfg;
    load.port_cfg.enable_domain_based_addr_gen = 1;
    load.port_cfg.exclusive_access_enable=1;
   foreach(load.port_cfg.innershareable_start_addr[i]) begin
           std::randomize(coh_addr)with{coh_addr inside {[load.port_cfg.innershareable_start_addr[i]:load.port_cfg.innershareable_end_addr[i]]};};
      end
        std::randomize(_tmp)with{_tmp inside {[0:(size-1)]};};
        coh_addr = get_addr_for_domain(start_addr_coh_q[_tmp],end_addr_coh_q[_tmp],<%=obj.DutInfo.FUnitId%>,core,0);
      create_len_for_connected_acess(coh_addr,<%=Math.log2(aiu_axiInt.params.wData/8)%>,incr_len,wrap_len);

        std::randomize(load.id)with { load.id inside {[1:30]} ;};
        load.atomic_type = svt_axi_transaction::EXCLUSIVE; 
        load.xact_type = svt_axi_transaction::COHERENT;
        load.burst_type = svt_axi_transaction::WRAP;
        if(load.port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE || load.port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE)begin
             load.coherent_xact_type = svt_axi_transaction::READNOSNOOP;
        end else begin 
	   load.coherent_xact_type = svt_axi_transaction::READNOSNOOP;
        end
             load.burst_length = 2;

      case(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)
      3: load.burst_size   = svt_axi_transaction::BURST_SIZE_64BIT;
      4: load.burst_size   = svt_axi_transaction::BURST_SIZE_128BIT;
      5: load.burst_size   = svt_axi_transaction::BURST_SIZE_256BIT;
      default:load.burst_size   = svt_axi_transaction::BURST_SIZE_32BIT;
      endcase

      if(load.port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE  || load.port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE)begin
          load.domain_type = svt_axi_transaction::SYSTEMSHAREABLE;
          load.port_cfg.exclusive_access_enable=1;
          load.port_cfg.shareable_exclusive_access_from_acelite_ports_enable=1;
          load.atomic_type = svt_axi_transaction::EXCLUSIVE;
          align=(2**load.burst_size)*(load.burst_length);
          $display("align:%d b_size:%d b_len:%d",align,load.burst_size,load.burst_length);
          load.addr = coh_addr;
          load.cache_type[1] = 1;
      end else begin 
          load.domain_type = svt_axi_transaction::SYSTEMSHAREABLE;
          load.atomic_type = svt_axi_transaction::NORMAL;
          load.cache_type[1:0] = 2'b00;
          align=(2**load.burst_size)*(load.burst_length);
          load.addr=(start_addr1/align)*align;
      end

        load.rresp        = new[load.burst_length];
        load.data         = new[load.burst_length];
        load.rready_delay = new[load.burst_length];
        load.data_user    = new[load.burst_length];
        <% if (obj.fnNativeInterface == "ACE") { %>
        load.coh_rresp    = new[load.burst_length];
        <% } %>


       `svt_xvm_send(load)
    	`uvm_info("body",$sformatf(" LOAD sent... at %t",$time), UVM_LOW)
    	`uvm_info("body",$sformatf(" LOAD::status is ACCEPT... at %t",$time), UVM_LOW)
          get_response(rsp);
    	`uvm_info("body",$sformatf(" LOAD::got response ... at %t",$time), UVM_LOW)
          load.wait_for_transaction_end();
    	`uvm_info("body",$sformatf(" LOAD::transaction ended... at %t",$time), UVM_LOW)



_tmp_xact = load;

 `svt_xvm_create(store)
      store.port_cfg     = cfg;
      store.port_cfg.enable_domain_based_addr_gen = 1;
      store.port_cfg.exclusive_access_enable=1;
	store.id   = _tmp_xact.id;	 
	store.xact_type = svt_axi_transaction::COHERENT;
        if(store.port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE ||load.port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE)begin
	   store.coherent_xact_type = svt_axi_transaction::WRITENOSNOOP;
           store.atomic_type = svt_axi_transaction::EXCLUSIVE;
        end else begin
	   store.coherent_xact_type = svt_axi_transaction::WRITENOSNOOP;
           store.atomic_type = svt_axi_transaction::NORMAL;
        end
      
        store.domain_type = _tmp_xact.domain_type;
	store.addr = _tmp_xact.addr;
	store.burst_size   = _tmp_xact.burst_size;
	store.burst_length = _tmp_xact.burst_length;
	store.burst_type  = _tmp_xact.burst_type;
	store.prot_type   = _tmp_xact.prot_type;
	store.cache_type  = _tmp_xact.cache_type; 

      store.data         = new[store.burst_length];
      store.wstrb        = new[store.burst_length];
      store.data_user    = new[store.burst_length];
      
       case(<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>)
       2: foreach(store.wstrb[i])begin 
            store.wstrb[i] = 32'h0000_000f;
          end       
       3:foreach(store.wstrb[i]) begin 
            store.wstrb[i] = 32'h0000_00ff;
          end
       4:foreach(store.wstrb[i]) begin 
            store.wstrb[i] = 32'h0000_ffff;
          end
       5:foreach(store.wstrb[i]) begin 
            store.wstrb[i] = 32'hffff_ffff;
          end
       default: `uvm_error("VS", $sformatf("Unsupported Size WXDATA"))
    endcase


      store.wvalid_delay = new[store.burst_length];
      foreach (store.wvalid_delay[i]) begin
      store.wvalid_delay[i]=i;
      end


       `svt_xvm_send(store)
    	`uvm_info("body",$sformatf(" STORE sent... at %t",$time), UVM_LOW)
    	`uvm_info("body",$sformatf(" STORE::status is ACCEPT... at %t",$time), UVM_LOW)
          get_response(rsp);
    	`uvm_info("body",$sformatf(" STORE::got response ... at %t",$time), UVM_LOW)
          store.wait_for_transaction_end();
    	`uvm_info("body",$sformatf(" STORE::transaction ended... at %t",$time), UVM_LOW)

end
<%}%>
   endtask: body 


endclass: snps_axi_master_exclusive_seq

////////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
 ////////////////////////    Ace Read Sequence    ////////////////////////////
/////////////////////////////////////////////////////////////////////////////


class snps_ace_master_read_seq extends snps_axi_master_seq;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length = 10;

  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }

  /** UVM Object Utility macro */
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `uvm_object_param_utils(snps_ace_master_read_seq)
   
  //seqr handle
  svt_axi_master_sequencer        m_write_seqr;
 
  bit [63:0] start_addr_noncoh_q[$],start_addr,end_addr;
  bit [63:0] end_addr_noncoh_q[$];
  bit [63:0] domain_size;
  bit rand_success;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr0,end_addr0,start_addr1,end_addr1; 
  int align;
  int master_id,core;
 
  svt_axi_system_configuration axi_sys_cfg;
  svt_axi_transaction::coherent_xact_type_enum      txn_type;
  addr_trans_mgr    m_addr_mgr;
  /** Class Constructor */
  function new(string name="snps_ace_master_read_seq");
    super.new(name);
    m_addr_mgr = addr_trans_mgr::get_instance();
    m_addr_mgr.gen_memory_map();
  endfunction
  
  virtual task body();
   
    svt_axi_master_transaction read_tran;
    svt_configuration get_cfg;
    bit status;
    `uvm_info("body", "Entered ...", UVM_LOW)
   

    super.body();

    status = uvm_config_db #(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);

    /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end

    core = 0;
    <% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
  	if( master_id ==<%=aiu_rpn+k-no_chi%> )begin
    	    core =<%=k%>; 
  	end
    <% }} %>
    m_addr_mgr.get_dmi_unit_addr_range(start_addr0,end_addr0,start_addr1,end_addr1);

    for(int i = 0; i <sequence_length; i++) begin

    /** Set up the read transaction */
        `uvm_create(read_tran)
        read_tran.port_cfg     = cfg;
        rand_success = read_tran.randomize() with { 
                atomic_type == svt_axi_transaction::NORMAL;
      		if(port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE || port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE) {
		    xact_type == svt_axi_transaction::COHERENT;
		    coherent_xact_type inside {svt_axi_transaction::READNOSNOOP,svt_axi_transaction::READONCE,svt_axi_transaction::CLEANSHARED,svt_axi_transaction::CLEANINVALID,svt_axi_transaction::MAKEINVALID};
		    <% if (obj.fnNativeInterface == "AXI4" ) { %>    
                	if(coherent_xact_type == svt_axi_transaction::READNOSNOOP)  domain_type == svt_axi_transaction::SYSTEMSHAREABLE;
			else   domain_type == svt_axi_transaction::OUTERSHAREABLE;	
        	    <% } else { %>
                	if(coherent_xact_type == svt_axi_transaction::READNOSNOOP)  domain_type inside {svt_axi_transaction::SYSTEMSHAREABLE/*, svt_axi_transaction::NONSHAREABLE*/};
			else domain_type == svt_axi_transaction::OUTERSHAREABLE;	
		    <% } %>
		    cache_type inside {'h2,'h3,'h6,'h7,'ha,'hb,'he,'hf};
		} else {
		    xact_type == svt_axi_transaction::READ;
		    coherent_xact_type == svt_axi_transaction::READNOSNOOP;
		    domain_type == svt_axi_transaction::SYSTEMSHAREABLE;
		    cache_type inside {'h0,'h1,'h2,'h3,'h6,'h7,'ha,'hb,'he,'hf};
		}

		id  inside {[0:31]};
		burst_size inside {svt_axi_transaction::BURST_SIZE_8BIT,svt_axi_transaction::BURST_SIZE_16BIT,svt_axi_transaction::BURST_SIZE_32BIT,svt_axi_transaction::BURST_SIZE_64BIT,svt_axi_transaction::BURST_SIZE_128BIT,svt_axi_transaction::BURST_SIZE_256BIT};
 	    
        };

        read_tran.burst_type = svt_axi_transaction::INCR;
	read_tran.burst_length = 1;

	if(read_tran.domain_type == svt_axi_transaction::SYSTEMSHAREABLE) begin
		//read_tran.addr = get_addr_for_domain(start_addr1,end_addr1,<%=obj.DutInfo.FUnitId%>,core);;
		if(start_addr0 == read_tran.port_cfg.outershareable_start_addr[0]) read_tran.addr = get_addr_for_domain(start_addr1,end_addr1,<%=obj.DutInfo.FUnitId%>,core,1);
		else read_tran.addr = get_addr_for_domain(start_addr0,end_addr0,<%=obj.DutInfo.FUnitId%>,core,1);
	end else if(read_tran.domain_type == svt_axi_transaction::OUTERSHAREABLE) begin
		read_tran.addr =  get_addr_for_domain(read_tran.port_cfg.outershareable_start_addr[0],read_tran.port_cfg.outershareable_end_addr[0],<%=obj.DutInfo.FUnitId%>,core,0);
	end else begin
		read_tran.addr =  get_addr_for_domain(read_tran.port_cfg.nonshareable_start_addr[0],read_tran.port_cfg.nonshareable_end_addr[0],<%=obj.DutInfo.FUnitId%>,core,0);
	end

	if (read_tran.burst_type == svt_axi_transaction::INCR) begin
		align = (2**<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>) * (<%=((obj.AiuInfo[obj.Id].wData/8)<64)?64/(obj.AiuInfo[obj.Id].wData/8):1%>);
		read_tran.addr = (read_tran.addr/align)*align;
	end else begin
		align = (2**<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>); 
		read_tran.addr = (read_tran.addr/align)*align;
	end

	if(read_tran.coherent_xact_type == svt_axi_transaction::CLEANSHARED || read_tran.coherent_xact_type == svt_axi_transaction::CLEANINVALID || read_tran.coherent_xact_type == svt_axi_transaction::MAKEINVALID) begin
		read_tran.rresp        			= new[1];
		<% if (obj.fnNativeInterface == "ACE") { %>
		read_tran.coh_rresp    			= new[1];
		<% } %>
		read_tran.data         			= new[1];
		read_tran.rready_delay 			= new[1];
		read_tran.data_user    			= new[1];
		read_tran.random_interleave_array    	= new[1];
	end else begin
		read_tran.rresp        			= new[read_tran.burst_length];
		<% if (obj.fnNativeInterface == "ACE") { %>
		read_tran.coh_rresp    			= new[read_tran.burst_length];
		<% } %>
		read_tran.data         			= new[read_tran.burst_length];
		read_tran.rready_delay 			= new[read_tran.burst_length];
		read_tran.data_user    			= new[read_tran.burst_length];
		read_tran.random_interleave_array    	= new[read_tran.burst_length];
	end
	        
        if(!rand_success) begin
            `svt_xvm_error("snps_ace_master_read_seq", " randomization failure....");
            return;
        end
   
	/** Send the read transaction */
	`uvm_send(read_tran)
	/** Wait for the read transaction to complete */
	get_response(rsp);
    
        `uvm_info("body", "ACE READ transaction completed", UVM_LOW);
   
    end
     
  endtask: body

endclass: snps_ace_master_read_seq

////////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
 ///////////////////////    Ace Write Sequence    ////////////////////////////
/////////////////////////////////////////////////////////////////////////////

class snps_ace_master_write_seq extends snps_axi_master_seq;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length = 10;

  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }

  /** UVM Object Utility macro */
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `uvm_object_param_utils(snps_ace_master_write_seq)
   
  //seqr handle
  svt_axi_master_sequencer        m_write_seqr;
 
  bit [63:0] start_addr_noncoh_q[$],start_addr,end_addr;
  bit [63:0] end_addr_noncoh_q[$];
  bit [63:0] domain_size;
  bit rand_success;
  bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr0,end_addr0,start_addr1,end_addr1;
  int align;
  int master_id,core;
 
  svt_axi_system_configuration axi_sys_cfg;
  svt_axi_transaction::coherent_xact_type_enum      txn_type;
  addr_trans_mgr    m_addr_mgr;
  
  /** Class Constructor */
  function new(string name="snps_ace_master_write_seq");
    super.new(name);
	m_addr_mgr = addr_trans_mgr::get_instance();
    m_addr_mgr.gen_memory_map();
  endfunction
  

  virtual task body();

    svt_axi_master_transaction write_tran;
    svt_configuration get_cfg;
    bit status;
    `uvm_info("body", "Entered ...", UVM_LOW)
   
    super.body();

    status = uvm_config_db #(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);
    `uvm_info("body", $sformatf("sequence_length is %0d as a result of %0s. start_arry:%0p end_arry:%0p", sequence_length, status ? "config DB" : "randomization", start_addr_noncoh_q,end_addr_noncoh_q), UVM_LOW);

    /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end

    core = 0;
    <% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
  	if( master_id ==<%=aiu_rpn+k-no_chi%> )begin
    	    core =<%=k%>; 
  	end
    <% }} %>

    m_addr_mgr.get_dmi_unit_addr_range(start_addr0,end_addr0,start_addr1,end_addr1);

    for(int i = 0; i <sequence_length; i++) begin

 
	/* Set up the write transaction */
	`uvm_create(write_tran)
	write_tran.port_cfg     = cfg;
	write_tran.port_cfg.enable_domain_based_addr_gen = 1;
	`uvm_info("body", $sformatf("sequence_length is %0d as a result of %0s. start_arry:%0p end_arry:%0p", sequence_length, status ? "config DB" : "randomization",write_tran.port_cfg.innershareable_start_addr,write_tran.port_cfg.innershareable_end_addr ), UVM_LOW);


	rand_success = write_tran.randomize() with { 
                atomic_type == svt_axi_transaction::NORMAL;
		coherent_xact_type inside {svt_axi_transaction::WRITEUNIQUE ,svt_axi_transaction::WRITELINEUNIQUE,svt_axi_transaction::WRITENOSNOOP};

                if(port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE || port_cfg.axi_interface_type == svt_axi_port_configuration:: ACE_LITE ){
                    if(coherent_xact_type == svt_axi_transaction::WRITEUNIQUE || coherent_xact_type == svt_axi_transaction::WRITELINEUNIQUE){
			domain_type == svt_axi_transaction::OUTERSHAREABLE;
			xact_type == svt_axi_transaction::COHERENT;
			cache_type inside {'h2,'h3,'h6,'h7,'ha,'hb,'he,'hf};
                    } else {
                        <% if (obj.fnNativeInterface == "AXI4") { %>
				domain_type == svt_axi_transaction::SYSTEMSHAREABLE;
                        <% } else {  %>
				domain_type inside {svt_axi_transaction::SYSTEMSHAREABLE/*,svt_axi_transaction::NONSHAREABLE*/};
                        <% } %>        
                        cache_type inside {'h0,'h1,'h2,'h3,'h6,'h7,'ha,'hb,'he,'hf};
		    }
                } else {
			xact_type == svt_axi_transaction::WRITE;
			domain_type inside {svt_axi_transaction::SYSTEMSHAREABLE};
                    	cache_type inside {'h0,'h1,'h2,'h3,'h6,'h7,'ha,'hb,'he,'hf};
		}

		burst_size inside {svt_axi_transaction::BURST_SIZE_8BIT,svt_axi_transaction::BURST_SIZE_16BIT,svt_axi_transaction::BURST_SIZE_32BIT,svt_axi_transaction::BURST_SIZE_64BIT,svt_axi_transaction::BURST_SIZE_128BIT,svt_axi_transaction::BURST_SIZE_256BIT};
		burst_type == svt_axi_transaction::INCR;
		burst_length == 1;
        };
	
	if(write_tran.domain_type == svt_axi_transaction::SYSTEMSHAREABLE) begin
		//write_tran.addr = get_addr_for_domain(start_addr1,end_addr1,<%=obj.DutInfo.FUnitId%>,core);;
		if(start_addr0 == write_tran.port_cfg.outershareable_start_addr[0]) write_tran.addr = get_addr_for_domain(start_addr1,end_addr1,<%=obj.DutInfo.FUnitId%>,core,1);
		else write_tran.addr = get_addr_for_domain(start_addr0,end_addr0,<%=obj.DutInfo.FUnitId%>,core,1);
	end else if(write_tran.domain_type == svt_axi_transaction::OUTERSHAREABLE) begin
		write_tran.addr =  get_addr_for_domain(write_tran.port_cfg.outershareable_start_addr[0],write_tran.port_cfg.outershareable_end_addr[0],<%=obj.DutInfo.FUnitId%>,core,0);
	end else begin
		write_tran.addr =  get_addr_for_domain(write_tran.port_cfg.nonshareable_start_addr[0],write_tran.port_cfg.nonshareable_end_addr[0],<%=obj.DutInfo.FUnitId%>,core,0);
	end

	
	if (write_tran.burst_type == svt_axi_transaction::INCR) begin
		align = (2**<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>) * (<%=((obj.AiuInfo[obj.Id].wData/8)<64)?64/(obj.AiuInfo[obj.Id].wData/8):1%>);
		write_tran.addr = (write_tran.addr/align)*align;
	end else begin
		align = (2**<%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>); 
		write_tran.addr = (write_tran.addr/align)*align;
	end


	write_tran.data         = new[write_tran.burst_length];
	write_tran.wstrb        = new[write_tran.burst_length];
	write_tran.data_user    = new[write_tran.burst_length];


	case(write_tran.burst_size)
            svt_axi_transaction::BURST_SIZE_8BIT: foreach(write_tran.wstrb[i])begin 
                 					write_tran.wstrb[i] = 32'h0000_0001;
               					end       
            svt_axi_transaction::BURST_SIZE_16BIT: foreach(write_tran.wstrb[i])begin 
                 					write_tran.wstrb[i] = 32'h0000_0003;
               					end       
            svt_axi_transaction::BURST_SIZE_32BIT: foreach(write_tran.wstrb[i])begin 
                 					write_tran.wstrb[i] = 32'h0000_000f;
               					end       
            svt_axi_transaction::BURST_SIZE_64BIT:foreach(write_tran.wstrb[i]) begin 
                 					write_tran.wstrb[i] = 32'h0000_00ff;
               					end
            svt_axi_transaction::BURST_SIZE_128BIT:foreach(write_tran.wstrb[i]) begin 
			std::randomize(write_tran.wstrb[i])with{write_tran.wstrb[i] inside {32'h0000_ffff,32'h0000_5555,32'h0000_aaaa};};
               					end
            svt_axi_transaction::BURST_SIZE_256BIT:foreach(write_tran.wstrb[i]) begin 
			std::randomize(write_tran.wstrb[i])with{write_tran.wstrb[i] inside {32'hffff_ffff,32'h5555_5555,32'haaaa_aaaa};};
               					end
            default: `uvm_error("VS", $sformatf("Unsupported Size WXDATA"))
	endcase

        if(!rand_success) begin
            `svt_xvm_error("snps_ace_master_write_seq", " randomization failure....");
            return;
        end
     
	/* Send the write transaction/*/
	`uvm_send(write_tran)

	/* Wait for the write transaction to complete */
	get_response(rsp);

        `uvm_info("body", "ACE WRITE transaction completed", UVM_LOW);
         
    end
     
  endtask: body

endclass: snps_ace_master_write_seq

////////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////
 ////////////////////    Axi4 Read Write Sequence    /////////////////////////
/////////////////////////////////////////////////////////////////////////////

class snps_axi4_master_read_write_seq extends snps_axi_master_seq;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length = 10;

  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 1000;
  }

  /** UVM Object Utility macro */
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `svt_xvm_object_param_utils(snps_axi4_master_read_write_seq)

    bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr0,end_addr0,start_addr1,end_addr1,start_addr,end_addr;
    bit [63:0] start_addr_noncoh_q[$];
    bit [63:0] end_addr_noncoh_q[$];
    bit [63:0] start_addr_coh_q[$];
    bit [63:0] end_addr_coh_q[$];
    bit [63:0] start_addr_q[$];
    bit [63:0] end_addr_q[$];
    int blen;
    bit status;
    int align,size,_tmp,incr_len,wrap_len;
    bit read_rand_success, write_rand_success;
    int master_id,core;
    svt_axi_transaction::prot_type_enum  prot_type;
    svt_axi_transaction::burst_type_enum burst_type;
    svt_axi_transaction::burst_size_enum b_size;
    ncoreConfigInfo::intq noncoh_regionsq;
    ncoreConfigInfo::intq coh_regionsq;
    ncoreConfigInfo::intq iocoh_regionsq;
    addr_trans_mgr    m_addr_mgr;
    ncore_memory_map m_mem;
    bit [63:0] rdnsnp_addr;
    bit  constrain_len=0;
    bit  tmp_len=0;
    bit  constrain_4k=0;
  ncoreConfigInfo::sys_addr_csr_t csrq[$];
    bit [<%=obj.nDIIs%>-1:0] AiuDii_connectivity_vec,exp_aiudii_connectivity_vec; 
    int dii_connect[$],dii_id,dii_que_size;
    bit [63:0] domain_size;
    bit dii_access=0;

   function new(string name="snps_axi4_master_read_write_seq");
	super.new(name);

     m_addr_mgr = addr_trans_mgr::get_instance();
     m_addr_mgr.gen_memory_map();
     m_mem = m_addr_mgr.get_memory_map_instance(); 
     noncoh_regionsq = m_mem.get_noncoh_mem_regions();
     iocoh_regionsq = m_mem.get_iocoh_mem_regions();
     coh_regionsq = m_mem.get_coh_mem_regions();

     foreach(iocoh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(iocoh_regionsq[indx], start_addr, end_addr);
	if (indx != 0) begin
        start_addr_coh_q.push_back(start_addr);
        end_addr_coh_q.push_back(end_addr);
        //`uvm_info("func",$psprintf("iocoh_start_arry[%0d] is %0h  &  iocoh_end_arry[%0d] is %0h", indx, start_addr, indx, end_addr),UVM_NONE)
	end
     end
     foreach(noncoh_regionsq[indx]) begin
        m_addr_mgr.get_mem_region_bounds(noncoh_regionsq[indx], start_addr, end_addr);
        start_addr_q.push_back(start_addr);
        end_addr_q.push_back(end_addr);
        //`uvm_info("func",$psprintf("noncoh_start_arry[%0d] is %0h  &  noncoh_end_arry[%0d] is %0h", indx, start_addr, indx, end_addr),UVM_NONE)
     end 
     size = start_addr_q.size();
     `uvm_info("func",$psprintf(" & size is %d", size),UVM_NONE)

  endfunction

  virtual task body();
    svt_axi_master_transaction  read_tran,write_tran;
        svt_configuration get_cfg;
   bit check_addr_unconnected = 0;
   bit [2:0] unit_unconnect = 0;
   
        `uvm_info("body", "Entered ...", UVM_LOW)
      
    /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end
    m_addr_mgr.get_dmi_unit_addr_range(start_addr0,end_addr0,start_addr1,end_addr1);

    exp_aiudii_connectivity_vec = '1;//'
    AiuDii_connectivity_vec = 'h<%=obj.AiuInfo[obj.Id].hexAiuDiiVec%>;//'

    if(AiuDii_connectivity_vec != exp_aiudii_connectivity_vec)begin
      AiuDii_connectivity_vec = {<<{ AiuDii_connectivity_vec }};
      foreach(AiuDii_connectivity_vec[i])begin
       if(AiuDii_connectivity_vec[i]) dii_connect.push_back(i);
      end
      start_addr_coh_q={};
      end_addr_coh_q={};
      csrq = ncoreConfigInfo::get_all_gpra();
      foreach(dii_connect[j])begin
         dii_id = dii_connect[j];
         foreach (csrq[i]) begin
           if(csrq[i].unit == ncoreConfigInfo::DII && csrq[i].mig_nunitid == dii_id) begin
             start_addr = csrq[i].low_addr << 12;
             domain_size = (1 << (csrq[i].size+12));
             end_addr = start_addr + domain_size - 1;
             start_addr_coh_q.push_back(start_addr);
             end_addr_coh_q.push_back(end_addr);
             //`uvm_info("ADB",$psprintf(" j %0d unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d",j, csrq[i].unit.name(), csrq[i].mig_nunitid,csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),UVM_NONE) 
           end
         end
      end
    end
     size = start_addr_coh_q.size();

    core = 0;
    <% if(obj.AiuInfo[obj.Id].nNativeInterfacePorts>1){ for(var k=0;k<obj.AiuInfo[obj.Id].nNativeInterfacePorts;k++) { %>
  	if( master_id ==<%=aiu_rpn+k-no_chi%> )begin
    	    core =<%=k%>; 
  	end
    <% }} %>

    for(int i = 0; i <sequence_length; i++) begin
  

      /** Set up the read transaction */
      `uvm_create(read_tran)
      read_tran.port_cfg     = cfg;
      if(dii_access)read_tran.port_cfg.enable_domain_based_addr_gen = 0;
      else read_tran.port_cfg.enable_domain_based_addr_gen = 1;
            
      constrain_4k=0;
      if(dii_access)begin
        std::randomize(_tmp)with{_tmp inside {[0:(size-1)]};};
        rdnsnp_addr = get_addr_for_domain(start_addr_coh_q[_tmp],end_addr_coh_q[_tmp],<%=obj.DutInfo.FUnitId%>,core,1);
      end else begin
        check_addr_unconnected = ncoreConfigInfo::check_unmapped_add(read_tran.port_cfg.nonshareable_start_addr[0], <%=obj.DutInfo.FUnitId%>, unit_unconnect);
        if(check_addr_unconnected==0)rdnsnp_addr = get_addr_for_domain(read_tran.port_cfg.nonshareable_start_addr[0],read_tran.port_cfg.nonshareable_end_addr[0],<%=obj.DutInfo.FUnitId%>,core,1);
      end
 
     check_addr_unconnected = ncoreConfigInfo::check_unmapped_add(rdnsnp_addr, <%=obj.DutInfo.FUnitId%>, unit_unconnect);
     if(check_addr_unconnected==0)begin

      create_len_for_connected_acess(rdnsnp_addr,<%=Math.log2(aiu_axiInt.params.wData/8)%>,incr_len,wrap_len);
      constrain_len=1;
      if((rdnsnp_addr[11:0] + ((<%=obj.AiuInfo[obj.Id].wData/8%>)*1)) >= 4096 )begin
        rdnsnp_addr[11:0]= rdnsnp_addr[11:0] -((<%=obj.AiuInfo[obj.Id].wData/8%>)*1);
        constrain_4k=1;
	tmp_len=1;
      end
            
          
          read_rand_success = read_tran.randomize() with { 
		                 id  inside {[0:30]};	 
                                 if(port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE || port_cfg.axi_interface_type == svt_axi_port_configuration:: ACE_LITE ){
                                   coherent_xact_type inside {svt_axi_transaction::READNOSNOOP,svt_axi_transaction::CLEANSHARED,svt_axi_transaction::CLEANINVALID,svt_axi_transaction::MAKEINVALID};
                                 } else { 
                                   coherent_xact_type == svt_axi_transaction::READNOSNOOP; }
		                 xact_type != svt_axi_transaction::WRITE;
                                 burst_type != svt_axi_transaction::FIXED;
                                 if(dii_access)domain_type == svt_axi_transaction::SYSTEMSHAREABLE;
				 else domain_type == svt_axi_transaction::NONSHAREABLE;
				 addr == rdnsnp_addr;
                                 if(constrain_4k)burst_length==tmp_len;
                                 if(constrain_len && burst_type==svt_axi_transaction::WRAP && !constrain_4k )burst_length <= wrap_len;
                                 if(constrain_len && burst_type==svt_axi_transaction::INCR && !constrain_4k )burst_length <= incr_len;
                                 burst_size == <%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>;
                                 addr / 4096 == (addr + ((1 << burst_size) * burst_length)) / 4096;
                                 if(burst_type==svt_axi_transaction::WRAP){
                                    burst_length inside {2,4,8,16};
                                  }
          };
        if(!read_rand_success) begin
            `svt_xvm_error("READ :: snps_axi4_master_read_write_seq", " randomization failure....");
            return;
          end

      /** Send the read transaction */
      `uvm_send(read_tran)

      /** Wait for the read transaction to complete */
      get_response(rsp);
    
      `uvm_info("body", "AXI READ transaction completed", UVM_LOW);


      /** Set up the read transaction */
      `uvm_create(write_tran)
      write_tran.port_cfg     = cfg;
      if(dii_access)write_tran.port_cfg.enable_domain_based_addr_gen = 0;
      else write_tran.port_cfg.enable_domain_based_addr_gen = 1;

      constrain_4k=0;
      if(dii_access)rdnsnp_addr = get_addr_for_domain(start_addr_coh_q[_tmp],end_addr_coh_q[_tmp],<%=obj.DutInfo.FUnitId%>,core,1);
      else rdnsnp_addr = get_addr_for_domain(write_tran.port_cfg.nonshareable_start_addr[0],write_tran.port_cfg.nonshareable_end_addr[0],<%=obj.DutInfo.FUnitId%>,core,1);
      create_len_for_connected_acess(rdnsnp_addr,<%=Math.log2(aiu_axiInt.params.wData/8)%>,incr_len,wrap_len);
      constrain_len=1;
      if((rdnsnp_addr[11:0] + ((<%=obj.AiuInfo[obj.Id].wData/8%>)*1)) >= 4096 )begin
        rdnsnp_addr[11:0]= rdnsnp_addr[11:0] -((<%=obj.AiuInfo[obj.Id].wData/8%>)*1);
        constrain_4k=1;
        tmp_len=1;
      end

          
          write_rand_success = write_tran.randomize() with { 
		                 id  inside {[0:30]};	 
                                 coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
		                 xact_type != svt_axi_transaction::READ;
                                 burst_type != svt_axi_transaction::FIXED;
				 if(dii_access)domain_type == svt_axi_transaction::SYSTEMSHAREABLE;
				 else domain_type == svt_axi_transaction::NONSHAREABLE;
                                 burst_size == <%=Math.log2(obj.AiuInfo[obj.Id].wData/8)%>;
                                 if(constrain_4k)burst_length==tmp_len;
                                 if(constrain_len && burst_type==svt_axi_transaction::WRAP && !constrain_4k )burst_length <= wrap_len;
                                 if(constrain_len && burst_type==svt_axi_transaction::INCR && !constrain_4k )burst_length <= incr_len;
				 addr == rdnsnp_addr;
                                 addr / 4096 == (addr + ((1 << burst_size) * burst_length)) / 4096;
          };
        if(!write_rand_success) begin
            `svt_xvm_error("WRITE :: snps_axi4_master_read_write_seq", " randomization failure....");
            return;
        end

      /** Send the read transaction */
      `uvm_send(write_tran)

      /** Wait for the read transaction to complete */
      get_response(rsp);
    
      `uvm_info("body", "AXI write_tran transaction completed", UVM_LOW);
      end // check_unconnected_addr
end
endtask:body
   
endclass:snps_axi4_master_read_write_seq

////////////////////////////////////////////////////////////////////////////////

