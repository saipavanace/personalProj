//============================================================================
//  ACE Emu Interface
//  Contains API calls for ACE transactions      
//       
//       
//       
//
//       
//       
//       
//============================================================================
<% if (obj.testBench == "emu" ) { %>
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
   var aiu_axiIntLen;

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
   
   `ifndef VELOCE_HDL_COMPILE
    <% if (obj.testBench != "emu_t" ) { %>
   
   import uvm_pkg::*;
   `include "uvm_macros.svh" <% } %> 
   `endif
   
    <% if (obj.testBench == "emu" ) { %>
     `include "mgc_vtl_ace_pkg.sv"
    `include "<%=obj.BlockId%>_axi_agent_pkg.sv" 
    `include "/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog/mgc_axi_pkg.sv" //D
   
   <% } %>

interface <%=obj.BlockId%>_ace_emu_if (input clk, reset_n);
  
    import mgc_vtl_ace_pkg::* ;
    import <%=obj.BlockId%>_axi_agent_pkg::*; 
     //-----------------------------------------------------------------------
    // Queues/Events to drive/collect data packets on all ACE channels 
    //-----------------------------------------------------------------------
    `ifndef VELOCE_HDL_COMPILE
    <% if (obj.testBench != "emu_t" ) { %>
    ace_write_addr_pkt_t     m_drv_mst_wr_addr_q[$];
    event                    e_drv_mst_wr_addr_q;
    ace_write_data_pkt_t     m_drv_mst_wr_data_q[$];
    ace_write_data_pkt_t     m_drv_mst_wr_data_q_emu[$];
    event                    e_drv_mst_wr_data_q;
    ace_write_resp_pkt_t     m_drv_slv_wr_resp_q[$];
    event                    e_drv_slv_wr_resp_q;
    event                    e_drv_mst_crresp_collected;
    semaphore                s_ace_mst_read_addr = new(1);
    semaphore                s_ace_mst_write_addr = new(1);
    semaphore                s_ace_mst_write_data = new(1);
    <% } %> 
    `endif
    
//-----------------------------------------------------------------------
// AXI Interface Write Address Channel Signals
//-----------------------------------------------------------------------
    axi_awid_logic_t     awid;
    axi_axaddr_logic_t   awaddr;
    axi_axlen_logic_t    awlen;
    axi_axsize_logic_t   awsize;
    axi_axburst_logic_t  awburst;
    axi_axlock_logic_t   awlock;
    axi_axcache_logic_t  awcache;
    axi_axprot_logic_t   awprot;
    axi_axqos_logic_t    awqos;
    axi_axregion_logic_t awregion;
    axi_awuser_logic_t   awuser;
    logic                                           awvalid;
    logic                                           awready;
//-----------------------------------------------------------------------
// AXI ACE Extension of Write Address Channel Signals
//-----------------------------------------------------------------------
    axi_axdomain_logic_t awdomain;	
    axi_awsnoop_logic_t  awsnoop;	
    axi_axbar_logic_t    awbar; 
    logic                                           awunique;
//-----------------------------------------------------------------------
// ACE-LITE-E signals
//-----------------------------------------------------------------------
    axi_awatop_logic_t         awatop; 
    axi_awstashnid_logic_t     awstashnid; 
    axi_awstashlpid_logic_t    awstashlpid; 
    axi_awloop_logic_t         awloop;
    axi_awnsaid_logic_t        awnsaid;
    logic                                           awstashniden; 
    logic                                           awstashlpiden;
    logic                                           awtrace; 

//-----------------------------------------------------------------------
// AXI Interface Read Address Channel Signals
//-----------------------------------------------------------------------
    axi_arid_logic_t     arid;
    axi_axaddr_logic_t   araddr;
    axi_axlen_logic_t    arlen;
    axi_axsize_logic_t   arsize;
    axi_axburst_logic_t  arburst;
    axi_axlock_logic_t   arlock;
    axi_axcache_logic_t  arcache;
    axi_axprot_logic_t   arprot;
    axi_axqos_logic_t    arqos;
    axi_axregion_logic_t arregion;
    axi_aruser_logic_t   aruser;
    logic                                           arvalid;
    logic                                           arready;
//-----------------------------------------------------------------------
// AXI ACE Extension of Read Address Channel 
//-----------------------------------------------------------------------
    axi_axdomain_logic_t  ardomain;	
    axi_arsnoop_logic_t   arsnoop;	
    axi_axbar_logic_t     arbar; 
    axi_arvmidext_logic_t arvmid;
    axi_arloop_logic_t    arloop;
    axi_arnsaid_logic_t   arnsaid;
    logic                                           artrace;

//-----------------------------------------------------------------------
// AXI Interface Read Response Channel Signals
//-----------------------------------------------------------------------
    axi_arid_logic_t  rid;
    axi_xdata_logic_t rdata;
    axi_rresp_logic_t rresp;
    logic                                        rlast;
    axi_ruser_logic_t ruser;
//-----------------------------------------------------------------------
// ACE-LITE-E signals
//-----------------------------------------------------------------------
    axi_rpoison_logic_t  rpoison;
    axi_rdatachk_logic_t rdatachk;
    axi_rloop_logic_t    rloop;
    logic                                        rtrace;
    logic                                        rvalid;
    logic                                        rready;
    // AXI ACE Extension of Read Data Channel
    <% if (obj.fnNativeInterface == "ACE") { %>    
    logic 		                               rack;
    <% } %>      

  //-----------------------------------------------------------------------
  // AXI Interface Write Channel Signals
  //-----------------------------------------------------------------------
  //axi_awid_logic_t  wid; // This is no longer used in AXI4 (only used in AXI3)
                        // Adding for legacy purposes
    axi_xdata_logic_t                           wdata;
    axi_xstrb_logic_t                           wstrb;
    logic                                       wlast;
    axi_wuser_logic_t                           wuser;
    // ACE-LITE-E signals
    axi_wpoison_logic_t  wpoison;
    axi_wdatachk_logic_t wdatachk;
    logic                                        wtrace;
    logic                                        wvalid;
    logic                                        wready;
    
    //-----------------------------------------------------------------------
    // AXI Interface Write Response Channel Signals
    //-----------------------------------------------------------------------
    axi_awid_logic_t                             bid;
    axi_bresp_logic_t                            bresp;
    axi_buser_logic_t                            buser;
    logic                                        bvalid;
    logic                                        bready;
    // AXI ACE Extension of Write Response Channel 
    <% if (obj.fnNativeInterface == "ACE") { %>    
    logic         		                 wack;
    <% } %>      
    // ACE-LITE-E signals
    axi_bloop_logic_t                            bloop;
    logic                                        btrace;
    
    //-----------------------------------------------------------------------
    // AXI ACE Interface SNOOP Address Channel Signals 
    //-----------------------------------------------------------------------
    logic                                          acvalid;
    logic                                          acready;
    axi_axaddr_logic_t                             acaddr;
    axi_acsnoop_logic_t                            acsnoop;
    axi_axprot_logic_t                             acprot;
    // ACE-LITE-E signals
    axi_acvmidext_logic_t                          acvmid;
    logic                                          actrace;
    
    //-----------------------------------------------------------------------
    // AXI ACE Interface SNOOP Response Channel Signals
    //-----------------------------------------------------------------------
    logic                                         crvalid;
    logic                                         crready;
    axi_crresp_logic_t                            crresp;
    // ACE-LITE-E signals
    axi_crnsaid_logic_t                           crnsaid;
    logic                                         crtrace;
    //-----------------------------------------------------------------------
    // AXI ACE Interface SNOOP Data Channel Signals
    //-----------------------------------------------------------------------
    logic                                         cdvalid;
    logic                                         cdready;
    axi_cddata_logic_t                            cddata;
    logic                                         cdlast;
    // ACE-LITE-E signals
    axi_cdpoison_logic_t                          cdpoison;
    axi_cddatachk_logic_t                         cddatachk;
    logic                                         cdtrace;
    
    bit  [1:0]                                    vif_ar_barrier;
    bit  [4:0]		                              vif_ar_txn_type;
    bit  [2:0]		                              vif_ar_prot;
    bit  [3:0] 			                          vif_ar_region;
    bit  [7:0] 			                          vif_ar_len;
    bit  [7:0] 			                          vif_r_len;
    bit  [2:0]			                          vif_ar_size;
    bit  [1:0] 			                          vif_ar_burst;
    bit  [1:0]			                          vif_ar_lock;
    bit  [3:0]			                          vif_ar_cache;
    bit  [3:0] 			                          vif_ar_qos;
    int unsigned 	                              vif_ar_id;
    bit [<%=obj.strRtlNamePrefix%>_ACE_ADDR_WIDTH-1:0] 	vif_ar_addr; 			// - A 64 bit signal indicates the address of the transfer
    bit [63:0] 			                          vif_ar_user_data;
    bit [2:0] 			                          vif_ar_domain;
    bit 		    	                          vif_ar_nb;
    bit  [7:0] 			                          vif_rdata_len;
    bit  [7:0]                                    vif_rdata_rwarp_len  ;
    int unsigned 		                          vif_ar_wrap_id        ;
    bit                                           vif_aw_unique  ; 
    bit [1:0]  	                                  vif_aw_barrier   ;
    bit [4:0] 	                                  vif_aw_txn_type  ;
    bit [2:0]	                                  vif_aw_prot      ;             
    bit [3:0] 		                              vif_aw_region    ;
    bit [7:0] 		                              vif_aw_len       ;
    bit [2:0] 		                              vif_aw_size      ;
    bit [1:0] 		                              vif_aw_burst     ;
    bit [1:0]		                              vif_aw_lock      ;
    bit [3:0] 		                              vif_aw_cache     ;
    bit [3:0] 		                              vif_aw_qos       ;
    int unsigned 		                          vif_aw_id        ;
    bit [<%=obj.strRtlNamePrefix%>_ACE_ADDR_WIDTH-1:0]    vif_aw_addr      ;		// - A 64 bit signal indicates the address of the transfer
    bit [63:0] 		                              vif_aw_user_data ;
    bit [1:0] 		                              vif_aw_domain    ;
    bit  			                              vif_aw_nb        ;
    //Write_snoop_local_variables
    bit [<%=obj.strRtlNamePrefix%>_ACE_ADDR_WIDTH-1:0]    vif_snp_aw_addr      ;		// - A 64 bit signal indicates the address of the transfer
    bit [4:0]                                     vif_snp_ac_snoop;
    int unsigned                                  vif_snp_ac_vmid;
    bit                                           vif_snp_ac_trace;  
    bit [2:0]	                                  vif_snp_ac_prot ;
    bit                                           vif_snp_aw_nb ;
    int unsigned 	                              vif_snp_id    ;
    ace_snoop_addr_pkt_t                          vif_wr_snp_pkt ;
    bit [4:0]                                     vif_resp ;
    bit [7:0]                                     vif_w_len; 
    int unsigned                                  vif_w_id;  
    int unsigned                                  vif_r_wrap_id;  
    bit                                           vif_w_nb;
    bit [2*<%=obj.strRtlNamePrefix%>_ACE_WDATA_WIDTH/8-1:0] vif_wstrb;
    bit [<%=obj.strRtlNamePrefix%>_ACE_WDATA_WIDTH-1:0] vif_wdata ;
    bit [<%=obj.strRtlNamePrefix%>_ACE_SDATA_WIDTH-1:0] vif_w_data ; 
    byte unsigned                                 checking_wr_data[]              ;
	int                                           core_id;
 

//----------------------------------------------------------------------------------------------------------
//----- Write Resp Wrapper
//----------------------------------------------------------------------------------------------------------

task ace_<%=obj.BlockId%>_write_data_wrapper (ace_write_data_pkt_t pkt, axi_axlen_logic_t len, bit valid = 1);

    ace_write_data_pkt_t m_pkt;
    m_pkt             = new();
    m_pkt.wstrb       = new[len+1];
    m_pkt.wdata       = new[len+1];
    m_pkt.wpoison     = new[len+1];
    m_pkt.wdatachk    = new[len+1];
    
    for (int i = 0; i <= len; i++) begin
    m_pkt.wlast       = ((i == len) ? 1'b1 : 1'b0);
    m_pkt.wuser       = pkt.wuser;
    m_pkt.wtrace      = pkt.wtrace;
    m_pkt.wstrb[i]    = pkt.wstrb[i];
    m_pkt.wdata[i]    = pkt.wdata[i];
    m_pkt.wpoison[i]  = pkt.wpoison[i];
    m_pkt.wdatachk[i] = pkt.wdatachk[i];
    end 
    
    m_drv_mst_wr_data_q_emu.push_back(m_pkt);
    vif_w_len = len;
    vif_w_id = vif_aw_id; 
    `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" Before calling ace_<%=obj.BlockId%>_write_data_chnl " ), UVM_LOW) 
    
    ace_<%=obj.BlockId%>_write_data_chnl(.len(vif_w_len), 
                                         .id(vif_w_id), 
                                         .nb(vif_w_nb),
                                         .ByteEnb(vif_wstrb) ,
                                         .wrapper_emu_write_pkt(m_pkt),
                                         .data(vif_wdata)
                                          ) ;
    
     `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" After calling ace_<%=obj.BlockId%>_write_data_chnl queue size is %0h",m_drv_mst_wr_data_q_emu.size()), UVM_LOW)
endtask:ace_<%=obj.BlockId%>_write_data_wrapper 


//----------------------------------------------------------------------------------------------------------
//----- Write Resp Wrapper
//----------------------------------------------------------------------------------------------------------
task ace_<%=obj.BlockId%>_write_response_wrapper ();
 `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" Before calling ace_<%=obj.BlockId%>_write_response_chnl " ), UVM_LOW) 
  ace_<%=obj.BlockId%>_write_response_chnl() ;
 `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" After calling ace_<%=obj.BlockId%>_write_response_chnl " ), UVM_LOW)
endtask:ace_<%=obj.BlockId%>_write_response_wrapper

//----------------------------------------------------------------------------------------------------------
//----- _write_addr_chnl
//----------------------------------------------------------------------------------------------------------

task  ace_<%=obj.BlockId%>_write_addr_chnl (   bit                                   awunique,
                                                         bit [1:0]  	                     barrier,
                                                         bit [4:0] 	                     txn_type,
                                                         bit [2:0]	                     prot,
                                                         bit [3:0] 		             region,
                                                         bit [7:0] 		             len,
                                                         bit  [2:0] 		             size,
                                                         bit  [1:0] 		             burst,
                                                         bit  [1:0]		             lock,
                                                         bit  [3:0] 		             cache,
                                                         bit [3:0] 		             qos,
                                                         int unsigned 	                     id,
                                                         bit [<%=obj.strRtlNamePrefix%>_ACE_ADDR_WIDTH-1:0]            addr, 			// - A 64 bit signal indicates the address of the transfer
                                                         bit [63:0] 		             user_data,
                                                         bit [1:0] 		             domain,
                                                         bit  		                     nb
                                                      );
    
    automatic axi_addr_ph_s wr_addr_struct;
    
    bit nb_tmp;
    bit reset_status;
    
    $cast(wr_addr_struct.awunique    , awunique);
    $cast(wr_addr_struct.barrier    ,  barrier);
    $cast(wr_addr_struct.txn_type   ,  txn_type);
    $cast(wr_addr_struct.prot       ,  prot);
    $cast(wr_addr_struct.region     ,  region);
    $cast(wr_addr_struct.len        ,  len);
    $cast(wr_addr_struct.size       ,  size);
    $cast(wr_addr_struct.burst      ,  burst);
    $cast(wr_addr_struct.lock       ,  lock);
    $cast(wr_addr_struct.cache      ,  cache);
    $cast(wr_addr_struct.qos        ,  qos);
    $cast(wr_addr_struct.id         ,  id);
    $cast(wr_addr_struct.addr       ,  addr);
    $cast(wr_addr_struct.user_data  ,  user_data);
    $cast(wr_addr_struct.domain     ,  domain);
    
    <% if(obj.fnNativeInterface == 'ACE') { %>
        mgc_ace_m_if_<%=obj.BlockId%>.put_wr_addr (wr_addr_struct, nb_tmp, reset_status );
        mgc_ace_m_if_<%=obj.BlockId%>.wait_for_clk(2);
    <% } else if((obj.fnNativeInterface == "ACE-LITE" ) || (obj.fnNativeInterface === "ACELITE-E")) { %>
        mgc_acelite_m_if_<%=obj.strRtlNamePrefix%>.put_wr_addr (wr_addr_struct, nb_tmp, reset_status );
        mgc_acelite_m_if_<%=obj.strRtlNamePrefix%>.wait_for_clk(2);
    <% } else if (!((obj.fnNativeInterface == "ACE")||(obj.fnNativeInterface == "ACE-LITE")||(obj.fnNativeInterface === "ACELITE-E")||(obj.fnNativeInterface == 'CHI-A')||(obj.fnNativeInterface == 'CHI-B')))  { %>
    <% if(Array.isArray(obj.interfaces.axiInt)) { %>
       <% aiu_axiIntLen = obj.interfaces.axiInt.length; %>
       <% for (var i=0; i<aiu_axiIntLen; i++) { %>
        if (core_id == <%=i%>) begin
            mgc_axi_m_if_<%=obj.strRtlNamePrefix%>_<%=i%>.put_wr_addr (wr_addr_struct, nb_tmp, reset_status );
            mgc_axi_m_if_<%=obj.strRtlNamePrefix%>_<%=i%>.wait_for_clk(2);
		end
	   <% } %>
	   <% } else { %>
        mgc_axi_m_if_<%=obj.strRtlNamePrefix%>.put_wr_addr (wr_addr_struct, nb_tmp, reset_status );
        mgc_axi_m_if_<%=obj.strRtlNamePrefix%>.wait_for_clk(2);
	   <% } %>
    <%}%>
   
endtask:ace_<%=obj.BlockId%>_write_addr_chnl



//----------------------------------------------------------------------------------------------------------
//----- Write Addr Wrapper
//----------------------------------------------------------------------------------------------------------
task ace_<%=obj.BlockId%>_write_addr_wrapper ();
    `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" Before calling ace_<%=obj.BlockId%>_write_addr_chnl " ), UVM_LOW) 


      ace_<%=obj.BlockId%>_write_addr_chnl (.awunique(vif_aw_unique), 
                                                    .barrier(vif_aw_barrier),
                                                    .txn_type(vif_aw_txn_type), 
                                                    .prot(vif_aw_prot), 
                                                    .region(vif_aw_region), 
                                                    .len(vif_aw_len), 
                                                    .size(vif_aw_size), 
                                                    .burst(vif_aw_burst),  
                                                    .lock(vif_aw_lock), 
                                                    .cache(vif_aw_cache),
                                                    .qos(vif_aw_qos), 
                                                    .id(vif_aw_id), 
                                                    .addr(vif_aw_addr), 
                                                    .user_data(vif_aw_user_data), 
                                                    .domain(vif_aw_domain), 
                                                    .nb(vif_aw_nb) ) ;

    `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" After calling ace_<%=obj.BlockId%>_write_addr_chnl " ), UVM_LOW)
endtask: ace_<%=obj.BlockId%>_write_addr_wrapper

//----------------------------------------------------------------------------------------------------------
//----- _write_data_chnl
//----------------------------------------------------------------------------------------------------------

task  ace_<%=obj.BlockId%>_write_data_chnl (  
                                             bit [7:0] 		        len,
                                             int unsigned 			id,
                                             bit  				nb,
                                             bit [2*<%=obj.strRtlNamePrefix%>_ACE_WDATA_WIDTH/8-1:0]	ByteEnb ,
                                             bit  [<%=obj.strRtlNamePrefix%>_ACE_WDATA_WIDTH-1:0]    data,              
                                             input ace_write_data_pkt_t  wrapper_emu_write_pkt
                                             );

automatic axi_addr_ph_s wr_addr_struct;
    ace_write_data_pkt_t  emu_write_pkt; 
    bit[63:0]                     wr_data_user_data[]    ;
    byte unsigned                 wr_data[]              ;
    bit unsigned                  wr_strb[]              ;
    bit[63:0]                     wr_resp_user_data      ;
    bit                           nb_tmp                 ;
    bit                           reset_status           ;
    int                           total_number_of_bytes  ;
    int k;
    bit [<%=obj.strRtlNamePrefix%>_ACE_WDATA_WIDTH-1:0]     wdata                  ;
    bit [<%=obj.strRtlNamePrefix%>_ACE_WDATA_WIDTH/8-1:0]	  ByteEnb_temp           ;  //to be used along with data.
    bit [7:0]                     wr_len                    ;
    
    emu_write_pkt = new();
    wr_len = len ;
    wr_data_user_data         = new [len + 1];
    total_number_of_bytes     = ( (len + 1)* <%=obj.strRtlNamePrefix%>_ACE_WDATA_WIDTH) >> 3;
    wr_data                   = new[total_number_of_bytes];
    wr_strb                   = new[total_number_of_bytes];
    ByteEnb_temp = ByteEnb ; 
    emu_write_pkt = wrapper_emu_write_pkt;
    nb_tmp = nb;	
    wdata = data;
    for( int j = 0 ; j <=wr_len ; j++ ) begin
    data = emu_write_pkt.wdata[j];
    for( int i = 0 ; i < (<%=obj.strRtlNamePrefix%>_ACE_WDATA_WIDTH/8); i++ )
    begin
    k = (j*(<%=obj.strRtlNamePrefix%>_ACE_WDATA_WIDTH/8));
    wr_data[k+i] = data[7:0];
    data = data >> 8;
    wr_strb[k+i] = 1;
    end
    end  
    <% if(obj.fnNativeInterface == 'ACE') { %>
    `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" ace_<%=obj.BlockId%>_write_addr_chnl Writes total_number_of_bytes = %d wr_data[] = %x\n",total_number_of_bytes, wr_data), UVM_LOW)    
    `uvm_info("ACE_EMU_IF ", $sformatf(" write data chnl ace_<%=obj.BlockId%>_write_data vif_aw_len=%0h data len = %0h ",vif_aw_len,len ), UVM_LOW) 
    `uvm_info(" ACE_EMU_IF", $sformatf(" write data chnl ace_<%=obj.BlockId%>_write_data vif_aw_id=%0h data id = %0h ",vif_aw_id,id ), UVM_LOW)  
    
    mgc_ace_m_if_<%=obj.BlockId%>.put_wr_data_burst(wr_data_user_data, wr_data, wr_strb, len, id, nb_tmp ,reset_status) ;
    `uvm_info(" ACE_EMU_IF", $sformatf("After calling write data chnl ace_<%=obj.BlockId%>_write_data vif_aw_id=%0h data id = %0h ",vif_aw_id,id ), UVM_LOW)
    `uvm_info("ACE_EMU_IF ", $sformatf("After calling write data chnl ace_<%=obj.BlockId%>_write_data vif_aw_len=%0h data len = %0h wr_data =%0h ",vif_aw_len,len ,wr_data ), UVM_LOW) 
    <% } else if((obj.fnNativeInterface == "ACE-LITE" ) || (obj.fnNativeInterface === "ACELITE-E")) { %>
    `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" acelite_<%=obj.strRtlNamePrefix%>_write_addr_chnl Writes total_number_of_bytes = %d wr_data[] = %x\n",total_number_of_bytes, wr_data), UVM_LOW)    
    `uvm_info("ACE_EMU_IF ", $sformatf(" write data chnl acelite_<%=obj.strRtlNamePrefix%>_write_data vif_aw_len=%0h data len = %0h ",vif_aw_len,len ), UVM_LOW) 
    `uvm_info(" ACE_EMU_IF", $sformatf(" write data chnl acelite_<%=obj.strRtlNamePrefix%>_write_data vif_aw_id=%0h data id = %0h ",vif_aw_id,id ), UVM_LOW)  
    
    mgc_acelite_m_if_<%=obj.strRtlNamePrefix%>.put_wr_data_burst(wr_data_user_data, wr_data, wr_strb, len, id, nb_tmp ,reset_status) ;
    `uvm_info(" ACE_EMU_IF", $sformatf("After calling write data chnl acelite_<%=obj.strRtlNamePrefix%>_write_data vif_aw_id=%0h data id = %0h ",vif_aw_id,id ), UVM_LOW)
    `uvm_info("ACE_EMU_IF ", $sformatf("After calling write data chnl acelite_<%=obj.strRtlNamePrefix%>_write_data vif_aw_len=%0h data len = %0h wr_data =%0h ",vif_aw_len,len ,wr_data ), UVM_LOW) 
    <% } else if (!((obj.fnNativeInterface == "ACE")||(obj.fnNativeInterface == "ACE-LITE")||(obj.fnNativeInterface === "ACELITE-E")||(obj.fnNativeInterface == 'CHI-A')||(obj.fnNativeInterface == 'CHI-B')))  { %>
    <% if(Array.isArray(obj.interfaces.axiInt)) { %>
       <% aiu_axiIntLen = obj.interfaces.axiInt.length; %>
       <% for (var i=0; i<aiu_axiIntLen; i++) { %>
        if (core_id == <%=i%>) begin
           `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" axi_<%=obj.strRtlNamePrefix%>_write_addr_chnl Writes total_number_of_bytes = %d wr_data[] = %x core ID = %d\n",total_number_of_bytes, wr_data, core_id), UVM_LOW)    
           `uvm_info("ACE_EMU_IF ", $sformatf(" write data chnl axi_<%=obj.strRtlNamePrefix%>_write_data vif_aw_len=%0h data len = %0h core ID = %d\n",vif_aw_len,len, core_id ), UVM_LOW) 
           `uvm_info(" ACE_EMU_IF", $sformatf(" write data chnl axi_<%=obj.strRtlNamePrefix%>_write_data vif_aw_id=%0h data id = %0h core ID = %d\n",vif_aw_id,id, core_id ), UVM_LOW)  
           
           mgc_axi_m_if_<%=obj.strRtlNamePrefix%>_<%=i%>.put_wr_data_burst(wr_data_user_data, wr_data, wr_strb, len, id, nb_tmp ,reset_status) ;
           `uvm_info(" ACE_EMU_IF", $sformatf("After calling write data chnl axi_<%=obj.strRtlNamePrefix%>_write_data vif_aw_id=%0h data id = %0h  core ID = %d\n",vif_aw_id,id, core_id ), UVM_LOW)
           `uvm_info("ACE_EMU_IF ", $sformatf("After calling write data chnl axi_<%=obj.strRtlNamePrefix%>_write_data vif_aw_len=%0h data len = %0h wr_data =%0h  core ID = %d\n",vif_aw_len,len ,wr_data, core_id ), UVM_LOW) 
 		end
	   <% } %>
	   <% } else { %>
           `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" axi_<%=obj.strRtlNamePrefix%>_write_addr_chnl Writes total_number_of_bytes = %d wr_data[] = %x\n",total_number_of_bytes, wr_data), UVM_LOW)    
           `uvm_info("ACE_EMU_IF ", $sformatf(" write data chnl axi_<%=obj.strRtlNamePrefix%>_write_data vif_aw_len=%0h data len = %0h\n",vif_aw_len,len), UVM_LOW) 
           `uvm_info(" ACE_EMU_IF", $sformatf(" write data chnl axi_<%=obj.strRtlNamePrefix%>_write_data vif_aw_id=%0h data id = %0h\n",vif_aw_id,id), UVM_LOW)  
           
           mgc_axi_m_if_<%=obj.strRtlNamePrefix%>.put_wr_data_burst(wr_data_user_data, wr_data, wr_strb, len, id, nb_tmp ,reset_status) ;
           `uvm_info(" ACE_EMU_IF", $sformatf("After calling write data chnl axi_<%=obj.strRtlNamePrefix%>_write_data vif_aw_id=%0h data id = %0h\n",vif_aw_id,id), UVM_LOW)
           `uvm_info("ACE_EMU_IF ", $sformatf("After calling write data chnl axi_<%=obj.strRtlNamePrefix%>_write_data vif_aw_len=%0h data len = %0h wr_data =%0h\n",vif_aw_len,len ,wr_data), UVM_LOW) 
	   <% } %>
    <%}%>
    

endtask: ace_<%=obj.BlockId%>_write_data_chnl 


//----------------------------------------------------------------------------------------------------------
//----- _write_response_chnl
//----------------------------------------------------------------------------------------------------------

task  ace_<%=obj.BlockId%>_write_response_chnl();
    automatic axi_resp_e wr_resp;
    int unsigned   id  ;   
    bit[63:0]        wr_resp_user_data;
    bit              nb_tmp;
    bit              reset_status;
    nb_tmp = 0;
	
    <% if(obj.fnNativeInterface == 'ACE') { %>
        mgc_ace_m_if_<%=obj.BlockId%>.get_wr_resp(wr_resp, wr_resp_user_data,id,reset_status);
        $display("ACE <%=obj.strRtlNamePrefix%>:  MEM Writes Start 3 wr_resp_user_data = %p \n", wr_resp_user_data);
        mgc_ace_m_if_<%=obj.BlockId%>.put_wr_ack(0);
    <%}%>
endtask: ace_<%=obj.BlockId%>_write_response_chnl 


//----------------------------------------------------------------------------------------------------------
//----- _read_addr_wrapper
//----------------------------------------------------------------------------------------------------------

task ace_<%=obj.BlockId%>_read_addr_chnl(
    
                                          bit  [1:0]                 barrier,
                                          bit  [4:0] 		txn_type,
                                          bit  [2:0]                 prot,
                                          bit [3:0] 			region,
                                          bit [7:0] 			len,
                                          bit  [2:0]	                size,
                                          bit  [1:0]                 burst,
                                          bit  [1:0]                 lock,
                                          bit  [3:0]			cache,
                                          bit [3:0] 			qos,
                                          int  			id,
                                          bit [<%=obj.strRtlNamePrefix%>_ACE_ADDR_WIDTH-1:0] 	addr, 			// - A 64 bit signal indicates the address of the transfer
                                          bit [63:0] 			user_data,
                                          bit [1:0] 			domain,
                                          bit 				nb
    
                                          );
    
    automatic axi_addr_ph_s rd_addr_struct;
    automatic axi_resp_e rd_resp[];
    
    byte unsigned read_data[];
    bit[63:0] rd_resp_user_data[];
    bit nb_tmp;
    int total_number_of_bytes;
    bit[511:0] rd_data;
    bit[511:0] rdata;
    bit reset;
    bit reset_status;
    
    $cast(rd_addr_struct.barrier    ,  barrier);
    $cast(rd_addr_struct.txn_type   ,  txn_type);
    $cast(rd_addr_struct.prot       ,  prot);
    $cast(rd_addr_struct.region     ,  region);
    $cast(rd_addr_struct.len        ,  len);
    $cast(rd_addr_struct.size       ,  size);
    $cast(rd_addr_struct.burst      ,  burst);
    $cast(rd_addr_struct.lock       ,  lock);
    $cast(rd_addr_struct.cache      ,  cache);
    $cast(rd_addr_struct.qos        ,  qos);
    $cast(rd_addr_struct.id         ,  id);
    $cast(rd_addr_struct.addr       ,  addr);
    $cast(rd_addr_struct.user_data  ,  user_data);
    $cast(rd_addr_struct.domain     ,  domain);
    
        
    nb_tmp = nb;	
    
    
    <% if(obj.fnNativeInterface == 'ACE') { %>
        mgc_ace_m_if_<%=obj.BlockId%>.wait_for_clk(10); 
        $display("ACE_EMU_IF_<%=obj.BlockId%>:  Address structure : barrier = %0h txn_type = %0h prot = %0h region = %0h len = %0h size = %0h burst = %0h lock = %0h cache = %0h qos = %0h id = %0h addr = %0h domain = %0h nb = %0h", barrier, txn_type, prot, region, len, size, burst, lock, cache, qos, id, addr, domain, nb);
        mgc_ace_m_if_<%=obj.BlockId%>.put_rd_addr(rd_addr_struct, nb_tmp, reset_status); 
    <% } else if((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface === "ACELITE-E")) { %>
        mgc_acelite_m_if_<%=obj.strRtlNamePrefix%>.wait_for_clk(10); 
        $display("ACE_EMU_IF_<%=obj.BlockId%>:  Address structure : barrier = %0h txn_type = %0h prot = %0h region = %0h len = %0h size = %0h burst = %0h lock = %0h cache = %0h qos = %0h id = %0h addr = %0h domain = %0h nb = %0h", barrier, txn_type, prot, region, len, size, burst, lock, cache, qos, id, addr, domain, nb);
        mgc_acelite_m_if_<%=obj.strRtlNamePrefix%>.put_rd_addr(rd_addr_struct, nb_tmp, reset_status); 
    <% } else if (!((obj.fnNativeInterface == "ACE")||(obj.fnNativeInterface == "ACE-LITE")||(obj.fnNativeInterface === "ACELITE-E")||(obj.fnNativeInterface == 'CHI-A')||(obj.fnNativeInterface == 'CHI-B')))  { %>
    <% if(Array.isArray(obj.interfaces.axiInt)) { %>
       <% aiu_axiIntLen = obj.interfaces.axiInt.length; %>
       <% for (var i=0; i<aiu_axiIntLen; i++) { %>
        if (core_id == <%=i%>) begin
        mgc_axi_m_if_<%=obj.strRtlNamePrefix%>_<%=i%>.wait_for_clk(10); 
        $display("ACE_EMU_IF_<%=obj.BlockId%>:  Address structure : barrier = %0h txn_type = %0h prot = %0h region = %0h len = %0h size = %0h burst = %0h lock = %0h cache = %0h qos = %0h id = %0h addr = %0h domain = %0h nb = %0h core ID = %d", barrier, txn_type, prot, region, len, size, burst, lock, cache, qos, id, addr, domain, nb, core_id);
        mgc_axi_m_if_<%=obj.strRtlNamePrefix%>_<%=i%>.put_rd_addr(rd_addr_struct, nb_tmp, reset_status); 
        mgc_axi_m_if_<%=obj.strRtlNamePrefix%>_<%=i%>.wait_for_clk(2);
 		end
	   <% } %>
	   <% } else { %>
        mgc_axi_m_if_<%=obj.strRtlNamePrefix%>.wait_for_clk(10); 
        $display("ACE_EMU_IF_<%=obj.BlockId%>:  Address structure : barrier = %0h txn_type = %0h prot = %0h region = %0h len = %0h size = %0h burst = %0h lock = %0h cache = %0h qos = %0h id = %0h addr = %0h domain = %0h nb = %0h", barrier, txn_type, prot, region, len, size, burst, lock, cache, qos, id, addr, domain, nb);
        mgc_axi_m_if_<%=obj.strRtlNamePrefix%>.put_rd_addr(rd_addr_struct, nb_tmp, reset_status); 
        mgc_axi_m_if_<%=obj.strRtlNamePrefix%>.wait_for_clk(2);
 	   <% } %>
    <%}%>
    
endtask :ace_<%=obj.BlockId%>_read_addr_chnl



//----------------------------------------------------------------------------------------------------------
//----- _read_addr_wrapper
//----------------------------------------------------------------------------------------------------------


task ace_<%=obj.BlockId%>_read_addr_wrapper ();
    `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" Before calling ace_<%=obj.BlockId%>_read_addr_chnl " ), UVM_LOW)
    
    vif_rdata_len = vif_ar_len; 
    ace_<%=obj.BlockId%>_read_addr_chnl (.barrier(vif_ar_barrier), 
                                         .txn_type(vif_ar_txn_type), 
                                         .prot(vif_ar_prot), 
                                         .region(vif_ar_region), 
                                         .len(vif_ar_len), 
                                         .size(vif_ar_size), 
                                         .burst(vif_ar_burst),  
                                         .lock(vif_ar_lock), 
                                         .cache(vif_ar_cache),
                                         .qos(vif_ar_qos), 
                                         .id(vif_ar_id), 
                                         .addr(vif_ar_addr), 
                                         .user_data(vif_ar_user_data), 
                                         .domain(vif_ar_domain), 
                                         .nb(vif_ar_nb) ) ;
    
    `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" After calling ace_<%=obj.BlockId%>_read_addr_chnl" ), UVM_LOW)
endtask :ace_<%=obj.BlockId%>_read_addr_wrapper 

//----------------------------------------------------------------------------------------------------------
//----- _read_data_chnl
//----------------------------------------------------------------------------------------------------------


task ace_<%=obj.BlockId%>_read_data_chnl(int unsigned len ,
                                           output ace_read_data_pkt_t  emu_pkt  );
   
    automatic axi_addr_ph_s rd_addr_struct;
    automatic axi_xdata_t xdata_emu[256];
   automatic axi_rresp_t xresp_emu[256];
   automatic int              beat_cnt; 
   ace_read_data_pkt_cell_t m_cell_emu; 
    int unsigned      rlen,temp;
    int               id  ;
    int               rd_data_width ; 
    axi_resp_e        resp [] ;
    byte unsigned     data[] ;
    bit [63:0]        resp_user[] ;
    bit               reset_status ;
    byte unsigned     read_data[];
    int               total_number_of_bytes ;
    len ='h100;     
    rlen = len;
    rd_data_width     = ((len + 1)* <%=obj.strRtlNamePrefix%>_ACE_RDATA_WIDTH) >> 3;
    read_data                 = new[rd_data_width];
    resp                      = new[rlen + 1];
    resp_user                 = new[rlen + 1];
    emu_pkt      = new();
    <% if(obj.fnNativeInterface == 'ACE') { %>
        `uvm_info("ACE_EMU_IF ", $sformatf(" before_read_data_chnl ace_<%=obj.BlockId%>_read_data r_len=%0h data len = %0h ",rlen,len ), UVM_LOW)
        `uvm_info(" ACE_EMU_IF", $sformatf(" before_read_data_chnl ace_<%=obj.BlockId%>_read_data r_id=%0h data id = %0h ",rid,id ), UVM_LOW) 
        mgc_ace_m_if_<%=obj.BlockId%>.get_rd_burst(resp,resp_user,read_data,rlen,id,reset_status) ;
        `uvm_info("ACE_EMU_IF ", $sformatf(" After_read_data_chnl ace_<%=obj.BlockId%>_read_data r_len=%0h data len = %0h ",rlen,len ), UVM_LOW)
        `uvm_info(" ACE_EMU_IF", $sformatf(" After_read_data_chnl ace_<%=obj.BlockId%>_read_data r_id=%0h data id = %0h ",rid,id ), UVM_LOW) 
    <% } else if((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface === "ACELITE-E")) { %>
        `uvm_info("ACE_EMU_IF ", $sformatf(" before_read_data_chnl ace_<%=obj.strRtlNamePrefix%>_read_data r_len=%0h data len = %0h ",rlen,len ), UVM_LOW)
        `uvm_info(" ACE_EMU_IF", $sformatf(" before_read_data_chnl ace_<%=obj.strRtlNamePrefix%>_read_data r_id=%0h data id = %0h ",rid,id ), UVM_LOW) 
        mgc_acelite_m_if_<%=obj.strRtlNamePrefix%>.get_rd_burst(resp,resp_user,read_data,rlen,id,reset_status) ;
        `uvm_info("ACE_EMU_IF ", $sformatf(" After_read_data_chnl ace_<%=obj.strRtlNamePrefix%>_read_data r_len=%0h data len = %0h ",rlen,len ), UVM_LOW)
        `uvm_info(" ACE_EMU_IF", $sformatf(" After_read_data_chnl ace_<%=obj.strRtlNamePrefix%>_read_data r_id=%0h data id = %0h ",rid,id ), UVM_LOW) 
    <% } else if (!((obj.fnNativeInterface == "ACE")||(obj.fnNativeInterface == "ACE-LITE")||(obj.fnNativeInterface === "ACELITE-E")||(obj.fnNativeInterface == 'CHI-A')||(obj.fnNativeInterface == 'CHI-B')))  { %>
    <% if(Array.isArray(obj.interfaces.axiInt)) { %>
       <% aiu_axiIntLen = obj.interfaces.axiInt.length; %>
       <% for (var i=0; i<aiu_axiIntLen; i++) { %>
        if (core_id == <%=i%>) begin
        `uvm_info("ACE_EMU_IF ", $sformatf(" before_read_data_chnl ace_<%=obj.strRtlNamePrefix%>_read_data r_len=%0h data len = %0h core ID = %d",rlen,len, core_id ), UVM_LOW)
        `uvm_info(" ACE_EMU_IF", $sformatf(" before_read_data_chnl ace_<%=obj.strRtlNamePrefix%>_read_data r_id=%0h data id = %0h core ID = %d ",rid,id, core_id ), UVM_LOW) 
        mgc_axi_m_if_<%=obj.strRtlNamePrefix%>_<%=i%>.get_rd_burst(resp,resp_user,read_data,rlen,id,reset_status) ;
        `uvm_info("ACE_EMU_IF ", $sformatf(" After_read_data_chnl ace_<%=obj.strRtlNamePrefix%>_read_data r_len=%0h data len = %0h core ID = %d ",rlen,len, core_id ), UVM_LOW)
        `uvm_info(" ACE_EMU_IF", $sformatf(" After_read_data_chnl ace_<%=obj.strRtlNamePrefix%>_read_data r_id=%0h data id = %0h core ID = %d ",rid,id, core_id), UVM_LOW) 
  		end
	   <% } %>
	   <% } else { %>
        `uvm_info("ACE_EMU_IF ", $sformatf(" before_read_data_chnl ace_<%=obj.strRtlNamePrefix%>_read_data r_len=%0h data len = %0h",rlen,len), UVM_LOW)
        `uvm_info(" ACE_EMU_IF", $sformatf(" before_read_data_chnl ace_<%=obj.strRtlNamePrefix%>_read_data r_id=%0h data id = %0h",rid,id), UVM_LOW) 
        mgc_axi_m_if_<%=obj.strRtlNamePrefix%>.get_rd_burst(resp,resp_user,read_data,rlen,id,reset_status) ;
        `uvm_info("ACE_EMU_IF ", $sformatf(" After_read_data_chnl ace_<%=obj.strRtlNamePrefix%>_read_data r_len=%0h data len = %0h",rlen,len), UVM_LOW)
        `uvm_info(" ACE_EMU_IF", $sformatf(" After_read_data_chnl ace_<%=obj.strRtlNamePrefix%>_read_data r_id=%0h data id = %0h",rid,id), UVM_LOW) 
  	   <% } %>
    <%}%>

//Added to resolve CONC-9297 

     emu_pkt.rresp_per_beat     = new[rlen + 1];
     
     for (int j=0; j <= rlen; j++)begin        
     xresp_emu[0][4*j +: 4]   = resp[j];
     emu_pkt.rresp_per_beat[j]=resp[j];
     end
     //temp = rlen+1;
     //emu_pkt.rresp_per_beat=new[rlen+1](resp);
     emu_pkt.rresp  =   xresp_emu[0] ;                               
 
    for (int i = 0; i < rd_data_width; i++) begin
    xdata_emu[0][8*i +: 8] = read_data[i]; 
    //xdata_emu[len][8*i +: 8] = read_data[i]; 
    end
    emu_pkt.rdata = xdata_emu;
    emu_pkt.rid =id ;           
    <% if(obj.fnNativeInterface == 'ACE') { %>
        mgc_ace_m_if_<%=obj.BlockId%>.put_rd_ack(0); 
    <%}%>

endtask :ace_<%=obj.BlockId%>_read_data_chnl


//----------------------------------------------------------------------------------------------------------
//----- _read_data_wrapper
//----------------------------------------------------------------------------------------------------------
<% if(obj.fnNativeInterface == 'ACE') { %>
    task  automatic ace_<%=obj.BlockId%>_read_data_wrapper (ref ace_read_data_pkt_t emu_pkt,axi_axlen_t len);
        ace_<%=obj.BlockId%>_read_data_chnl (.len(len), .emu_pkt(emu_pkt) );
    endtask : ace_<%=obj.BlockId%>_read_data_wrapper 
<% } else { %>
    task  automatic ace_<%=obj.BlockId%>_read_data_wrapper (ref ace_read_data_pkt_t emu_pkt);
        ace_<%=obj.BlockId%>_read_data_chnl (.len(0), .emu_pkt(emu_pkt) );
    endtask : ace_<%=obj.BlockId%>_read_data_wrapper 
<% } %>

// This function is provided by Mentor graphics to resolve CONC-9297
function bit[3:0] cast_snoop_type(input bit[4:0] snoop_type);

    if(snoop_type==5'h16)

       return 4'h0;

    else if(snoop_type==5'h18)

       return 4'h1;

    else if(snoop_type==5'h17)

       return 4'h2;

    else if(snoop_type==5'h19)

       return 4'h3;

    else if(snoop_type==5'h1a)

       return 4'h7;

    else if(snoop_type==5'h1b)

       return 4'h8;

    else if(snoop_type==5'h1c)

       return 4'h9;

    else if(snoop_type==5'h1d)

       return 4'hd;

   else if(snoop_type==5'h1e)

       return 4'he;

    else if(snoop_type==5'h1f)

       return 4'hf;

         

endfunction

//----------------------------------------------------------------------------------------------------------
//----- _snoop_addr_chnl
//----------------------------------------------------------------------------------------------------------

task   ace_<%=obj.BlockId%>_snoop_addr_chnl (output  ace_snoop_addr_pkt_t wr_snp_pkt );

    bit [<%=obj.strRtlNamePrefix%>_ACE_ADDR_WIDTH-1:0]my_addr;
    bit [2:0] my_prot_type;
    bit [4:0] my_snoop_type_<%=obj.BlockId%>;
    bit [4:0] my_snoop_type_temp;
    wr_snp_pkt = new ();
  my_snoop_type_<%=obj.BlockId%> = 5'h0;
    
    <% if(obj.fnNativeInterface == 'ACE') { %>
        mgc_ace_m_if_<%=obj.BlockId%>.get_snp_addr (my_addr, my_snoop_type_temp, my_prot_type);
    <% } %>
 my_snoop_type_<%=obj.BlockId%>[3:0] = cast_snoop_type(my_snoop_type_temp);
    wr_snp_pkt.acaddr       =my_addr;
    
    if( (my_snoop_type_<%=obj.BlockId%>[3:0] == 4'b0000) || (my_snoop_type_<%=obj.BlockId%>[3:0] == 4'b0001) || (my_snoop_type_<%=obj.BlockId%>[3:0] == 4'b0010) || (my_snoop_type_<%=obj.BlockId%>[3:0] == 4'b0011) || (my_snoop_type_<%=obj.BlockId%>[3:0] == 4'b0111) || (my_snoop_type_<%=obj.BlockId%>[3:0] == 4'b1000) || (my_snoop_type_<%=obj.BlockId%>[3:0] == 4'b1001) || (my_snoop_type_<%=obj.BlockId%>[3:0] == 4'b1101) || (my_snoop_type_<%=obj.BlockId%>[3:0] == 4'b1110) || (my_snoop_type_<%=obj.BlockId%>[3:0] == 4'b1111)) begin
    wr_snp_pkt.acsnoop      = my_snoop_type_<%=obj.BlockId%>[3:0] ; 
    end else begin
    wr_snp_pkt.acsnoop      = 'h0 ; 
    end
    wr_snp_pkt.acprot       = my_prot_type  ;
    $display($time, "[ACE_EMU_IF]:: ace_<%=obj.BlockId%>_snoop_addr_chnl_after_api  my_snoop_type = %h ", my_snoop_type_<%=obj.BlockId%>[3:0]);
    $display($time, "[ACE_EMU_IF]:: ace_<%=obj.BlockId%>_snoop_addr_chnl_after_api  wr_snp_pkt.acsnoop = %h ",wr_snp_pkt.acsnoop);
    $display($time, "[ACE_EMU_IF]:: ace_<%=obj.BlockId%>_snoop_addr_chnl_after_api  my_snoop_type_temp = %h ", my_snoop_type_temp[3:0]);
    `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" ace_<%=obj.BlockId%>_snoop_addr_chnl_done " ), UVM_LOW)

endtask:ace_<%=obj.BlockId%>_snoop_addr_chnl


//----------------------------------------------------------------------------------------------------------
//----- _snoop_response_chnl
//----------------------------------------------------------------------------------------------------------

task  ace_<%=obj.BlockId%>_snoop_response_chnl (
                                                  bit[4:0] resp ,
                                                  input ace_snoop_resp_pkt_t wrapper_snoop_emu_pkt);


    ace_snoop_resp_pkt_t snoop_emu_pkt  ;
    int unsigned   id  ;   
    bit[4:0] wr_snp_resp;    
    bit      nb;
    bit      reset_status ; 
    nb = 0;
    snoop_emu_pkt   = new () ;
    snoop_emu_pkt  = wrapper_snoop_emu_pkt   ; 
    wr_snp_resp  =  snoop_emu_pkt.crresp ; 
    <% if(obj.fnNativeInterface == 'ACE') { %>
        mgc_ace_m_if_<%=obj.BlockId%>.put_snp_resp(wr_snp_resp,nb);
	<% } %>

endtask: ace_<%=obj.BlockId%>_snoop_response_chnl 

//----------------------------------------------------------------------------------------------------------
//-----  snoop Data chnl
//----------------------------------------------------------------------------------------------------------

task  ace_<%=obj.BlockId%>_snoop_data_chnl ( 
                                             input   ace_snoop_data_pkt_t emu_sdata_pkt 
                                             );
    ace_snoop_data_pkt_t sn_data ;
    bit  [<%=obj.strRtlNamePrefix%>_ACE_SDATA_WIDTH-1:0]    s_data; 
    int k;  
    int num_bytes_in_snoop_burst; 
    byte unsigned snp_data [] ; 
    bit nb_tmp ;
    bit reset_status;
    sn_data = new ();
    num_bytes_in_snoop_burst = ( 1 << <%=obj.strRtlNamePrefix%>_ACE_CACHE_LINE_WIDTH );
    sn_data = emu_sdata_pkt ;
    snp_data=new[num_bytes_in_snoop_burst]; 
    nb_tmp = 0;
    `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" ace_<%=obj.BlockId%>_snoop_data_chnl data channel final pkt data = %0p",sn_data.cddata), UVM_LOW)
    for( int j = 0 ; j <=num_bytes_in_snoop_burst ; j++ ) begin  
    s_data = emu_sdata_pkt.cddata[j];
    for( int i = 0 ; i < (<%=obj.strRtlNamePrefix%>_ACE_SDATA_WIDTH/8); i++ )
    begin
    k = (j*(<%=obj.strRtlNamePrefix%>_ACE_SDATA_WIDTH/8));
    snp_data[k+i] = s_data[7:0];
    s_data = s_data >> 8;
    end
    end  
    <% if(obj.fnNativeInterface == 'ACE') { %>
        mgc_ace_m_if_<%=obj.BlockId%>.put_snp_burst (snp_data,nb_tmp);
	<% } %>
endtask: ace_<%=obj.BlockId%>_snoop_data_chnl 

//----------------------------------------------------------------------------------------------------------
//-----  Snoop Addr Wrapper
//----------------------------------------------------------------------------------------------------------

task  automatic   ace_<%=obj.BlockId%>_snoop_addr_wrapper (ref ace_snoop_addr_pkt_t wr_snp_pkt  );
    `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" Before calling ace_<%=obj.BlockId%>_snoop_addr_chnl_in_snoop_addr_wrapper " ), UVM_LOW) 
     ace_<%=obj.BlockId%>_snoop_addr_chnl (.wr_snp_pkt(wr_snp_pkt)   ) ;
    `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" After calling ace_<%=obj.BlockId%>_snoop_addr_chnl_in_snoop_addr_wrapper " ), UVM_LOW)
endtask: ace_<%=obj.BlockId%>_snoop_addr_wrapper
      
//----------------------------------------------------------------------------------------------------------
//-----  snoop Resp Wrapper
//----------------------------------------------------------------------------------------------------------

task ace_<%=obj.BlockId%>_snoop_response_wrapper (ace_snoop_resp_pkt_t pkt, bit valid = 1 );  
    ace_snoop_resp_pkt_t s_pkt;
    s_pkt             = new();
    s_pkt.crresp      = pkt.crresp;
    vif_resp = s_pkt.crresp;
    ace_<%=obj.BlockId%>_snoop_response_chnl(.resp(vif_resp) , .wrapper_snoop_emu_pkt(s_pkt)) ;
    `uvm_info(" [ACE_EMU_IF]:: ", $sformatf(" After calling ace_<%=obj.BlockId%>_snoop_response_chnl_in_snoop_response_wrapper" ), UVM_LOW)
endtask:ace_<%=obj.BlockId%>_snoop_response_wrapper

//----------------------------------------------------------------------------------------------------------
//-----  snoop Data  Wrapper
//----------------------------------------------------------------------------------------------------------

task ace_<%=obj.BlockId%>_snoop_data_wrapper (ace_snoop_data_pkt_t pkt, bit valid = 1);
    ace_snoop_data_pkt_t  s_pkt_t;
    s_pkt_t = new ();
    s_pkt_t.cddata = pkt.cddata ;
    ace_<%=obj.BlockId%>_snoop_data_chnl(.emu_sdata_pkt(s_pkt_t)) ; 
    $display($time, "[ACE_EMU_IF]:: After calling ace_<%=obj.BlockId%>_snoop_data_chnl_snoop_data_wrapper data= %p\n ", s_pkt_t.cddata);
endtask:ace_<%=obj.BlockId%>_snoop_data_wrapper 

endinterface: <%=obj.BlockId%>_ace_emu_if



   <% } %>
