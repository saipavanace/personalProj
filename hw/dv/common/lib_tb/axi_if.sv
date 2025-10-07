//////////////////////////////////////////////////////////////////////////////////
//
// AXI Interface
//
////////////////////////////////////////////////////////////////////////////////

//======================================================================= 
// Notes:
// 1) AXI VIP also has CCI400 interface. This is present in ace_vip/include/sverilog/svt_axi_cci400_config_if.svi. 
//    I have not included that interface below. It is available in case someone needs it
//======================================================================= 
`ifndef VELOCE_HDL_COMPILE
 <% if (obj.testBench != "emu_t" ) { %>

import uvm_pkg::*;
`include "uvm_macros.svh" <% } %> 
`endif

interface <%=obj.BlockId%>_axi_if (input clk, input rst_n);

  import <%=obj.BlockId%>_axi_agent_pkg::*;

  //----------------------------------------------------------------------- 
  // Delay values used in this interface
  //----------------------------------------------------------------------- 
  parameter axi_setup_time = 1;
  parameter axi_hold_time = 0;
  parameter goes_to_dut = 0;

  //-----------------------------------------------------------------------
  //params to control readys for perf counter(stall events)
  //-----------------------------------------------------------------------
  bit vif_rst_n = 1;
  int axi_if_clk_count;
  bit enable_r_stall = 0; 
  bit enable_b_stall = 0;
  bit en_r_stall     = 0;// enable AXI/ACE R stall TO DO:this shald be fixed to 0 as defailt value 
  int stall_r_period = 0;//number of clk cycles during which ready shall be maintained to low when valid is high
  bit stall_r_chnl_till_en_r_stall_deassrt = 0;
  bit en_ar_stall  = 0;// enable AXI/ACE AR stall TO DO:this shald be fixed to 0 as defailt value 
  int stall_ar_period = 0;//number of clk cycles during which ready shall be maintained to low when valid is high
  bit stall_ar_chnl_till_en_ar_stall_deassrt = 0;
  bit en_aw_stall  = 0;// enable AXI/ACE AW stall TO DO:this shald be fixed to 0 as defailt value 
  int stall_aw_period = 0;//number of clk cycles during which ready shall be maintained to low when valid is high
  bit stall_aw_chnl_till_en_aw_stall_deassrt = 0;
  bit en_w_stall   = 0;// enable AXI/ACE W stall TO DO:this shald be fixed to 0 as defailt value 
  int stall_w_period = 0;//number of clk cycles during which ready shall be maintained to low when valid is high
  bit stall_w_chnl_till_en_w_stall_deassrt = 0;
  bit en_b_stall   = 0;// enable AXI/ACE B stall TO DO:this shald be fixed to 0 as defailt value
  int stall_b_period = 0;//number of clk cycles during which ready shall be maintained to low when valid is high
  bit stall_b_chnl_till_en_b_stall_deassrt = 0;
  bit en_ac_stall  = 0;// enable ACE AC stall TO DO:this shald be fixed to 0 as defailt value  
  int stall_ac_period = 0;//number of clk cycles during which ready shall be maintained to low when valid is high
  bit stall_ac_chnl_till_en_ac_stall_deassrt = 0;
  bit en_cd_stall  = 0;// enable ACE CD stall TO DO:this shald be fixed to 0 as defailt value 
  int stall_cd_period = 0;//number of clk cycles during which ready shall be maintained to low when valid is high
  bit stall_cd_chnl_till_en_cd_stall_deassrt = 0;
  bit en_cr_stall  = 0;// enable ACE CR stall TO DO:this shald be fixed to 0 as defailt value 
  int stall_cr_period = 0;//number of clk cycles during which ready shall be maintained to low when valid is high
  bit stall_cr_chnl_till_en_cr_stall_deassrt = 0;
  bit bloc_axi_stall = 0;//bloc always ready to 0
  int RDY_NOT_ASSERTED_DURATION = 600 ; //Perf counter: duration during which ready  is blocked to 0
  int cnt_rdy_blckd_duration =0;//counter cycles of not asserted ready 

  int ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MIN      = 0;
  int ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MAX      = 1;
  int ACE_MASTER_READ_ADDR_CHANNEL_BURST_PCT      = 90;

  int ACE_MASTER_READ_DATA_CHANNEL_DELAY_MIN      = 1;
  int ACE_MASTER_READ_DATA_CHANNEL_DELAY_MAX      = 3;
  int ACE_MASTER_READ_DATA_CHANNEL_BURST_PCT      = 80;
  bit ACE_MASTER_READ_DATA_CHANNEL_WAIT_FOR_VLD   = 0;

  int ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MIN     = 0;
  int ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MAX     = 1;
  int ACE_MASTER_WRITE_ADDR_CHANNEL_BURST_PCT     = 90;

  int ACE_MASTER_WRITE_DATA_CHANNEL_DELAY_MIN     = 1;
  int ACE_MASTER_WRITE_DATA_CHANNEL_DELAY_MAX     = 3;
  int ACE_MASTER_WRITE_DATA_CHANNEL_BURST_PCT     = 80;

  int ACE_MASTER_WRITE_RESP_CHANNEL_DELAY_MIN     = 1;
  int ACE_MASTER_WRITE_RESP_CHANNEL_DELAY_MAX     = 3;
  int ACE_MASTER_WRITE_RESP_CHANNEL_BURST_PCT     = 80;
  bit ACE_MASTER_WRITE_RESP_CHANNEL_WAIT_FOR_VLD  = 0;

  int ACE_MASTER_SNOOP_ADDR_CHANNEL_DELAY_MIN     = 1;
  int ACE_MASTER_SNOOP_ADDR_CHANNEL_DELAY_MAX     = 3;
  int ACE_MASTER_SNOOP_ADDR_CHANNEL_BURST_PCT     = 80;
  bit ACE_MASTER_SNOOP_ADDR_CHANNEL_WAIT_FOR_VLD  = 0;

  int ACE_MASTER_SNOOP_RESP_CHANNEL_DELAY_MIN     = 1;
  int ACE_MASTER_SNOOP_RESP_CHANNEL_DELAY_MAX     = 3;
  int ACE_MASTER_SNOOP_RESP_CHANNEL_BURST_PCT     = 80;

  int ACE_MASTER_SNOOP_DATA_CHANNEL_DELAY_MIN     = 1;
  int ACE_MASTER_SNOOP_DATA_CHANNEL_DELAY_MAX     = 3;
  int ACE_MASTER_SNOOP_DATA_CHANNEL_BURST_PCT     = 80;

  int ACE_SLAVE_READ_ADDR_CHANNEL_DELAY_MIN       = 1;
  int ACE_SLAVE_READ_ADDR_CHANNEL_DELAY_MAX       = 3;
  int ACE_SLAVE_READ_ADDR_CHANNEL_BURST_PCT       = 80;
  int ACE_SLAVE_READ_ADDR_CHANNEL_WAIT_FOR_VLD    = 0;

  int ACE_SLAVE_WRITE_ADDR_CHANNEL_DELAY_MIN      = 1;
  int ACE_SLAVE_WRITE_ADDR_CHANNEL_DELAY_MAX      = 3;
  int ACE_SLAVE_WRITE_ADDR_CHANNEL_BURST_PCT      = 80;
  int ACE_SLAVE_WRITE_ADDR_CHANNEL_WAIT_FOR_VLD   = 0;

  int ACE_SLAVE_READ_DATA_DLY_AFTER_RLAST         = 0;
  int ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MIN       = 1;
  int ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MAX       = 3;
  int ACE_SLAVE_READ_DATA_CHANNEL_BURST_PCT       = 80;
  int ACE_SLAVE_READ_DATA_REORDER_SIZE            = 4;
<% if((obj.Block === "dmi")&&(obj.useRttDataEntries)&&(obj.useMemRspIntrlv)) { %>
  bit ACE_SLAVE_READ_DATA_INTERLEAVE_DIS          = 0;
<% } else { %>
  bit ACE_SLAVE_READ_DATA_INTERLEAVE_DIS          = 1;
<% } %>
  bit ACE_SLAVE_READ_DATA_CHANNEL_STRICT_DLY      = 0;
  bit ACE_SLAVE_READ_DATA_INTERBEATDLY_DIS        = 0;
  bit ACE_SLAVE_RANDOM_DLY_DIS        = 0; // Disable random on delay use only delay_max

  int ACE_SLAVE_WRITE_DATA_CHANNEL_DELAY_MIN      = 1;
  int ACE_SLAVE_WRITE_DATA_CHANNEL_DELAY_MAX      = 3;
  int ACE_SLAVE_WRITE_DATA_CHANNEL_BURST_PCT      = 80;
  int ACE_SLAVE_WRITE_DATA_CHANNEL_WAIT_FOR_VLD   = 0;

  int ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MIN      = 1;
  int ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MAX      = 3;
  int ACE_SLAVE_WRITE_RESP_CHANNEL_BURST_PCT      = 80;

  int ACE_SLAVE_SNOOP_ADDR_CHANNEL_DELAY_MIN      = 1;
  int ACE_SLAVE_SNOOP_ADDR_CHANNEL_DELAY_MAX      = 3;
  int ACE_SLAVE_SNOOP_ADDR_CHANNEL_BURST_PCT      = 80;

  int ACE_SLAVE_SNOOP_RESP_CHANNEL_DELAY_MIN      = 1;
  int ACE_SLAVE_SNOOP_RESP_CHANNEL_DELAY_MAX      = 3;
  int ACE_SLAVE_SNOOP_RESP_CHANNEL_BURST_PCT      = 80;

  int ACE_SLAVE_SNOOP_DATA_CHANNEL_DELAY_MIN      = 1;
  int ACE_SLAVE_SNOOP_DATA_CHANNEL_DELAY_MAX      = 3;
  int ACE_SLAVE_SNOOP_DATA_CHANNEL_BURST_PCT      = 80;
  
  int ACE_SLAVE_SYSCO_CHANNEL_DELAY_MIN      = 1;
  int ACE_SLAVE_SYSCO_CHANNEL_DELAY_MAX      = 3;
  int ACE_SLAVE_SYSCO_CHANNEL_BURST_PCT      = 80;

  bit IS_IF_A_SLAVE                               = 1;
  int wack_count                                  = 0;
  int rack_count                                  = 0;
  bit IS_ACTIVE                                   = 0;
  // This flag is used to not drop packets sent by the sequence when reset is asserted at the start of simulation
  // But it will drop packets whenever reset is asserted after the first de-assertion
  bit first_reset_seen = 0;
  // If below bit is set, delays will keep switching delay values over time
  bit is_bfm_delay_changing                       = 0;
  int delay_changing_time_period                  = 20000; //in ns 


  bit iocache_perf_test = 0;

  //-----------------------------------------------------------------------
  // rsp data interleaving assertion helper variables
  //-----------------------------------------------------------------------
  enum {EXPECT_RID_CONSTANT, DONT_EXPECT_RID_CONSTANT} rsp_data_cycle_ff;
  logic [31:0] rsp_bus_cycle_rid;

  //-----------------------------------------------------------------------
  // Queues/Events to drive/collect data packets on all ACE channels 
  //-----------------------------------------------------------------------
`ifndef VELOCE_HDL_COMPILE
 <% if (obj.testBench != "emu_t" ) { %>

  ace_read_data_pkt_t      m_mon_mst_rd_data_q[$];
  ace_read_data_pkt_t      m_mon_mst_rd_data_for_driver_q[$];
  event                    e_mon_mst_rd_collected;
  ace_read_data_pkt_t      m_mon_slv_rd_data_q[$];
  event                    e_mon_slv_rd_collected;
  ace_read_data_pkt_cell_t m_drv_slv_rd_data_q[$];
  event                    e_drv_slv_rd_collected;
  ace_read_addr_pkt_t      m_drv_mst_rd_addr_q[$];
  event                    e_drv_mst_rd_addr_q;
  ace_write_addr_pkt_t     m_drv_mst_wr_addr_q[$];
  event                    e_drv_mst_wr_addr_q;
  ace_write_data_pkt_t     m_drv_mst_wr_data_q[$];
  event                    e_drv_mst_wr_data_q;
  ace_snoop_resp_pkt_t     m_drv_mst_snp_resp_q[$];
  event                    e_drv_mst_snp_resp_q;
  ace_snoop_data_pkt_t     m_drv_mst_snp_data_q[$];
  event                    e_drv_mst_snp_data_q;
  ace_write_resp_pkt_t     m_drv_slv_wr_resp_q[$];
  event                    e_drv_slv_wr_resp_q;
  event                    e_drv_mst_crresp_collected;
  int 			   match_pattern = 0;
  semaphore                s_ace_mst_read_addr = new(1);
  semaphore                s_ace_mst_write_addr = new(1);
  semaphore                s_ace_mst_write_data = new(1);
<% } %> 
`endif
  //-----------------------------------------------------------------------
  // AXI Interface Write Address Channel Signals
  //-----------------------------------------------------------------------
  wire axi_awid_logic_t     awid;
  wire axi_axaddr_logic_t   awaddr;
  wire axi_axlen_logic_t    awlen;
  wire axi_axsize_logic_t   awsize;
  wire axi_axburst_logic_t  awburst;
  wire axi_axlock_logic_t   awlock;
  tri0 axi_axcache_logic_t  awcache;
  wire axi_axprot_logic_t   awprot;
  wire axi_axqos_logic_t    awqos;
  tri0 axi_axregion_logic_t awregion;
  tri0 axi_awuser_logic_t   awuser;
  tri0 axi_awuserchk_logic_t awuser_chk;
  wire logic                                           awvalid;
  wire logic                                           awready;
  // AXI ACE Extension of Write Address Channel Signals
  wire axi_axdomain_logic_t awdomain;	
  wire axi_awsnoop_logic_t  awsnoop;	
  wire axi_axbar_logic_t    awbar; 
  wire logic                                           awunique;
  // ACE-LITE-E signals
  wire axi_awatop_logic_t         awatop; 
  wire axi_awstashnid_logic_t     awstashnid; 
  wire axi_awstashlpid_logic_t    awstashlpid; 
  wire axi_awloop_logic_t         awloop;
  wire axi_awnsaid_logic_t        awnsaid;
  wire logic                                           awstashniden; 
  wire logic                                           awstashlpiden;
  wire logic                                           awtrace; 
  //Check signals
  wire logic                awvalid_chk;
  wire logic                awready_chk;
<% if( obj.testBench == 'fsys') { %>
  wire axi_awid_logic_t    awid_chk;
  wire axi_axaddr_logic_t awaddr_chk;
<% } else { %>
  wire axi_widchk_logic_t    awid_chk;
  wire axi_axaddrchk_logic_t awaddr_chk;
<% } %>
  wire logic                awlen_chk;
  wire logic                awctl_chk0; 
  wire logic                awctl_chk1; 
  wire logic                awctl_chk2; 
  wire logic                awctl_chk3; 
  wire logic                awstashnid_chk; 
  wire logic                awstashlpid_chk; 
  wire logic                awtrace_chk; 
  
  //-----------------------------------------------------------------------
  // AXI Interface Read Address Channel Signals
  //-----------------------------------------------------------------------
  wire axi_arid_logic_t     arid;
  wire axi_axaddr_logic_t   araddr;
  wire axi_axlen_logic_t    arlen;
  wire axi_axsize_logic_t   arsize;
  wire axi_axburst_logic_t  arburst;
  wire axi_axlock_logic_t   arlock;
  tri0 axi_axcache_logic_t  arcache;
  wire axi_axprot_logic_t   arprot;
  wire axi_axqos_logic_t    arqos;
  tri0 axi_axregion_logic_t arregion;
  tri0 axi_aruser_logic_t   aruser;
  tri0 axi_aruserchk_logic_t aruser_chk;
  wire logic                                           arvalid;
  wire logic                                           arready;
  // AXI ACE Extension of Read Address Channel 
  wire axi_axdomain_logic_t  ardomain;	
  wire axi_arsnoop_logic_t   arsnoop;	
  wire axi_axbar_logic_t     arbar; 
  // ACE-LITE-E signals
  wire axi_arvmidext_logic_t arvmidext;
  wire axi_arloop_logic_t    arloop;
  wire axi_arnsaid_logic_t   arnsaid;
  wire logic                                           artrace;
  //check_type signals
  wire logic               arvalid_chk;
  wire logic               arready_chk;
<% if( obj.testBench == 'fsys') { %>
  wire axi_arid_logic_t  arid_chk;
  wire axi_axaddr_logic_t  araddr_chk;
<% } else { %>
  wire axi_ridchk_logic_t  arid_chk;
  wire axi_axaddrchk_logic_t  araddr_chk;
<% } %>
  wire logic               arlen_chk;
  wire logic               arctl_chk0;
  wire logic               arctl_chk1;
  wire logic               arctl_chk2;
  wire logic               arctl_chk3;

  wire logic               artrace_chk;
 
  //-----------------------------------------------------------------------
  // AXI Interface Read Response Channel Signals
  //-----------------------------------------------------------------------
  wire axi_arid_logic_t  rid;
  wire axi_xdata_logic_t rdata;
  wire axi_rresp_logic_t rresp;
  wire logic                                        rlast;
  tri0 axi_ruser_logic_t ruser;
  tri0 axi_ruserchk_logic_t ruser_chk;
  // ACE-LITE-E signals
  wire axi_rpoison_logic_t  rpoison;
  wire axi_rdatachk_logic_t rdatachk;
  wire axi_rloop_logic_t    rloop;
  wire logic                                        rtrace;
  wire logic                                        rvalid;
  wire logic                                        rready;
  // AXI ACE Extension of Read Data Channel
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
  wire logic 		                               rack;
  wire logic 		                               rack_chk;
<% } %>      
  //check_type signals
  wire logic                   rvalid_chk;
  wire logic                   rready_chk;
<% if( obj.testBench == 'fsys') { %>
  wire axi_arid_logic_t       rid_chk;
  wire axi_xdata_logic_t      rdata_chk;
<% } else { %>
  wire axi_ridchk_logic_t       rid_chk;
  wire axi_rdatachk_logic_t    rdata_chk;
<% } %>
  wire logic                   rresp_chk;
  wire logic                   rlast_chk;
  wire logic                   rtrace_chk;

  //-----------------------------------------------------------------------
  // AXI Interface Write Channel Signals
  //-----------------------------------------------------------------------
  //axi_awid_logic_t  wid; // This is no longer used in AXI4 (only used in AXI3)
                        // Adding for legacy purposes
  wire axi_xdata_logic_t wdata;
  wire axi_xstrb_logic_t wstrb;
  wire logic                                        wlast;
  tri0 axi_wuser_logic_t wuser;
  tri0 axi_wuserchk_logic_t wuser_chk; 
  // ACE-LITE-E signals
  wire axi_wpoison_logic_t  wpoison;
  wire axi_wdatachk_logic_t wdatachk;
  wire logic                                        wtrace;
  wire logic                                        wvalid;
  wire logic                                        wready;
  //Check signals
  wire logic                 wvalid_chk;
  wire logic                 wready_chk;
<% if( obj.testBench == 'fsys') { %>
  wire axi_xdata_logic_t  wdata_chk;
  wire axi_xstrb_logic_t  wstrb_chk;
<% } else { %>
  wire axi_wdatachk_logic_t  wdata_chk;
  wire axi_wstrbchk_logic_t  wstrb_chk;
<% } %>
  wire logic                 wlast_chk;
  wire logic                 wtrace_chk;
  
  //-----------------------------------------------------------------------
  // AXI Interface Write Response Channel Signals
  //-----------------------------------------------------------------------
  wire axi_awid_logic_t  bid;
  wire axi_bresp_logic_t bresp;
  tri0 axi_buser_logic_t buser;
  tri0 axi_buserchk_logic_t buser_chk;
  wire logic                                        bvalid;
  wire logic                                        bready;
  // AXI ACE Extension of Write Response Channel 
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
  wire logic         		               wack;
  wire logic         		               wack_chk;
<% } %>      
  // ACE-LITE-E signals
  wire axi_bloop_logic_t    bloop;
  wire logic                                        btrace;
  //Check signals
  wire logic             bvalid_chk;
  wire logic             bready_chk;
  wire axi_widchk_logic_t      bid_chk; 
  wire logic             bresp_chk;
  wire logic             btrace_chk;

  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Address Channel Signals 
  //-----------------------------------------------------------------------
  wire logic                                          acvalid;
  wire logic                                          acready;
  wire axi_axaddr_logic_t  acaddr;
  wire axi_acsnoop_logic_t acsnoop;
  wire axi_axprot_logic_t  acprot;
  // ACE-LITE-E signals
  wire axi_acvmidext_logic_t acvmidext;
  wire logic                                          actrace;
  //Check signals
  wire logic               acready_chk;
  wire logic               acvalid_chk;
  wire axi_axaddrchk_logic_t  acaddr_chk;
  wire logic               acctl_chk;
  wire logic               actrace_chk;
  wire axi_acvmidext_logic_t               acvmidext_chk;

  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Response Channel Signals
  //-----------------------------------------------------------------------
  wire logic                                         crvalid;
  wire logic                                         crready;
  wire axi_crresp_logic_t crresp;
  // ACE-LITE-E signals
  wire axi_crnsaid_logic_t crnsaid;
  wire logic                                         crtrace;
  //Check signals
  wire logic               crready_chk;
  wire logic               crvalid_chk;
  wire logic               crresp_chk;
  wire logic               crtrace_chk;
  wire axi_cddatachk_logic_t cddata_chk;

  //-----------------------------------------------------------------------
  // AXI ACE Interface SNOOP Data Channel Signals
  //-----------------------------------------------------------------------
  wire logic                                         cdvalid;
  wire logic                                         cdvalid_chk;
  wire logic                                         cdready;
  wire logic                                         cdready_chk;
  wire axi_cddata_logic_t cddata;
  wire logic                                         cdlast;
  wire logic                                         cdlast_chk;
  // ACE-LITE-E signals
  wire axi_cdpoison_logic_t  cdpoison;
  wire axi_cddatachk_logic_t cddatachk;
  wire logic                                         cdtrace;
  wire logic                                         cdtrace_chk;
  wire logic                                         syscoreq; 
  wire logic                                         syscoack; 

`ifndef VELOCE_HDL_COMPILE
 <% if (obj.testBench != "emu_t" ) { %>
  //-----------------------------------------------------------------------
  // AXI clocking blocks 
  //-----------------------------------------------------------------------

  always @(posedge clk) begin
      axi_if_clk_count = axi_if_clk_count + 1;
  end

  /**
   * Clocking block that defines the AXI master Interface
   */
  clocking axi_master_cb @(posedge clk);
      
      default input #axi_setup_time output #axi_hold_time;
      input   rst_n;

      output  awid ;
      output  awaddr ;
      output  awlen ;
      output  awsize ;
      output  awburst ;
      output  awlock ;
      output  awcache ;
      output  awprot ;
      output  awqos ;
      output  awregion ;
      output  awuser ;
      output  awvalid ;
      input   awready ;
      output  awdomain;
      output  awsnoop;
      output  awbar;
      output  awunique;
      output  awatop; 
      output  awstashnid; 
      output  awstashlpid; 
      output  awloop;
      output  awnsaid;
      output  awstashniden; 
      output  awstashlpiden;
      output  awtrace;

      //check signals
      output  awvalid_chk;
      input   awready_chk;
      output   awid_chk;
      output   awaddr_chk;
      output   awlen_chk;
      output   awctl_chk0; 
      output   awctl_chk1; 
      output   awctl_chk2; 
      output   awctl_chk3; 
      output   awstashnid_chk; 
      output   awstashlpid_chk; 
      output   awtrace_chk; 
      //output  wid ;  
      output  wdata ;
      output  wstrb ;
      output  wlast ;
      output  wuser ;
      output  wvalid ;
      input   wready ;
      output  wpoison;
      output  wdatachk;
      output  wtrace;

      //check signal
      output wvalid_chk;
      input wready_chk;
      output wdata_chk;
      output wstrb_chk;
      output wlast_chk;
      output wtrace_chk;
      input   bid ;
      input   bresp ;
      input   buser ;
      input   bvalid ;
      output  bready ;

      //check signal
      input   bvalid_chk;
      output   bready_chk;
      input   bid_chk; 
      input   bresp_chk;
      input   btrace_chk;
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
      output  wack;
      output  wack_chk;
<% } %>      
      input   bloop;
      input   btrace;

      output  arid ; 
      output  araddr ;
      output  arlen ;
      output  arsize ;
      output  arburst ;
      output  arlock ;
      output  arcache ;
      output  arprot ;
      output  arqos ;
      output  arregion ;
      output  aruser ;
      output  arvalid ;
      input   arready ;
      output  ardomain;
      output  arsnoop;
      output  arbar;
      output  arvmidext;
      output  arloop;
      output  arnsaid;
      output  artrace;

      //check_type signals
      output arvalid_chk;
      input  arready_chk;
      output arid_chk;
      output araddr_chk;
      output arlen_chk;
      output arctl_chk0;
      output arctl_chk1;
      output arctl_chk2;
      output artrace_chk;
      input   rid ;
      input   rdata ;
      input   rresp ;
      input   rlast ;
      input   ruser ;
      input   rvalid ;
      output  rready ;

      //check_type signals
      input   rvalid_chk;
      output   rready_chk;
      input    rid_chk;
      input   rdata_chk;
      input   rresp_chk;
      input   rlast_chk;
      input   rtrace_chk;
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
      output  rack;
      output  rack_chk;
<% } %>      
      input   rpoison;                        
      input   rdatachk;
      input   rloop;
      input   rtrace;

      input   acvalid;
      output  acready;
      input   acaddr;
      input   acsnoop;
      input   acprot;
      input   acvmidext;
      input   actrace;

      //Check signals
      output acready_chk;
      input acvalid_chk;
      input acaddr_chk;
      input acctl_chk;
      input actrace_chk;
      output  crvalid;
      input   crready;
      output  crresp;
      output  crnsaid;
      output  crtrace;

      //Check signals
      input crready_chk;
      output crvalid_chk;
      output crresp_chk;
      output crtrace_chk;
      output  cddata_chk;
      output  cdvalid;
      output  cdvalid_chk;
      input   cdready;
      input   cdready_chk;
      output  cddata;
      output  cdlast;
      output  cdlast_chk;
      output  cdpoison;
      output  cddatachk;
      output  cdtrace;

      output  syscoreq;
      input   syscoack;
				     
  endclocking : axi_master_cb

  /**
   * Clocking block that defines the AXI slave Interface
   */
  clocking axi_slave_cb @(posedge clk);
      
      default input #axi_setup_time output #axi_hold_time;
      input   rst_n;
  
      input   awid ;
      input   awaddr ;
      input   awlen ;
      input   awsize ;
      input   awburst ;
      input   awlock ;
      input   awcache ;
      input   awprot ;
      input   awqos ;
      input   awregion ;
      input   awuser ;
      input   awvalid ;
      output  awready ;
      input   awdomain;
      input   awsnoop;
      input   awbar;
      input   awunique;
      input   awatop; 
      input   awstashnid; 
      input   awstashlpid; 
      input   awloop;
      input   awnsaid;
      input   awstashniden; 
      input   awstashlpiden;
      input   awtrace;

      //input   wid ;  
      input   wdata ;
      input   wstrb ;
      input   wlast ;
      input   wuser ;
      input   wvalid ;
      output  wready ;
      input   wpoison;
      input   wdatachk;
      input   wtrace;

      output  bid ;
      output  bresp ;
      output  buser ;
      output  bvalid ;
      input   bready ;
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
      input   wack;
      input   wack_chk;
<% } %>      
      output  bloop;
      output  btrace;

      input   arid ; 
      input   araddr ;
      input   arlen ;
      input   arsize ;
      input   arburst ;
      input   arlock ;
      input   arcache ;
      input   arprot ;
      input   arqos ;
      input   arregion ;
      input   aruser ;
      input   arvalid ;
      output  arready ;
      input   ardomain;
      input   arsnoop;
      input   arbar;
      input   arvmidext;
      input   arloop;
      input   arnsaid;
      input   artrace;
  
      output  rid ;
      output  rdata ;
      output  rresp ;
      output  rlast ;
      output  ruser ;
      output  rvalid ;
      input   rready ;
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
      input   rack;
      input   rack_chk;
<% } %>      
      output  rpoison;                        
      output  rdatachk;
      output  rloop;
      output  rtrace;

      output  acvalid;
      input   acready;
      output  acaddr;
      output  acsnoop;
      output  acprot;
      output  acvmidext;
      output  actrace;
      
      input   crvalid;
      output  crready;
      input   crresp;
      input   crnsaid;
      input   crtrace;
      
      input   cdvalid;
      input   cdvalid_chk;
      input   cddata_chk;
      output  cdready;
      output  cdready_chk;
      input   cddata;
      input   cdlast;
      input   cdlast_chk;
      input   cdpoison;
      input   cddatachk;
      input   cdtrace;
  
      input   syscoreq;
      output  syscoack;
  endclocking : axi_slave_cb

  clocking axi_monitor_cb @(negedge clk);
      
      default input #axi_setup_time;
      input   rst_n;
  
      input   awid ;
      input   awaddr ;
      input   awlen ;
      input   awsize ;
      input   awburst ;
      input   awlock ;
      input   awcache ;
      input   awprot ;
      input   awqos ;
      input   awregion ;
      input   awuser ;
      input   awvalid ;
      input   awready ;
      input   awdomain;
      input   awsnoop;
      input   awbar;
      input   awunique;
      input   awatop; 
      input   awstashnid; 
      input   awstashlpid; 
      input   awloop;
      input   awnsaid;
      input   awstashniden; 
      input   awstashlpiden;
      input   awtrace;

      //input   wid ;  
      input   wdata ;
      input   wstrb ;
      input   wlast ;
      input   wuser ;
      input   wvalid ;
      input   wready ;
      input   wpoison;
      input   wdatachk;
      input   wtrace;

      input   bid ;
      input   bresp ;
      input   buser ;
      input   bvalid ;
      input   bready ;
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
      input   wack;
      input   wack_chk;
<% } %>      
      input   bloop;
      input   btrace;

      input   arid ; 
      input   araddr ;
      input   arlen ;
      input   arsize ;
      input   arburst ;
      input   arlock ;
      input   arcache ;
      input   arprot ;
      input   arqos ;
      input   arregion ;
      input   aruser ;
      input   arvalid ;
      input   arready ;
      input   ardomain;
      input   arsnoop;
      input   arbar;
      input   arvmidext;
      input   arloop;
      input   arnsaid;
      input   artrace;

      input   rid ;
      input   rdata ;
      input   rresp ;
      input   rlast ;
      input   ruser ;
      input   rvalid ;
      input   rready ;
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
      input   rack;
      input   rack_chk;
<% } %>      
      input   rpoison;                        
      input   rdatachk;
      input   rloop;
      input   rtrace;

      input   acvalid;
      input   acready;
      input   acaddr;
      input   acsnoop;
      input   acprot;
      input   acvmidext;
      input   actrace;
      
      input   crvalid;
      input   crready;
      input   crresp;
      input   crnsaid;
      input   crtrace;
      
      input   cdvalid;
      input   cdvalid_chk;
      input   cddata_chk;
      input   cdready;
      input   cdready_chk;
      input   cddata;
      input   cdlast;
      input   cdlast_chk;
      input   cdpoison;
      input   cddatachk;
      input   cdtrace;
  
      input   syscoreq;
      input   syscoack;
  endclocking : axi_monitor_cb

  modport axi_master (

      input   rst_n,
      output  awid ,
      output  awaddr ,
      output  awlen ,
      output  awsize ,
      output  awburst ,
      output  awlock ,
      output  awcache ,
      output  awprot ,
      output  awqos ,
      output  awregion ,
      output  awuser ,
      output  awvalid ,
      input   awready ,
      output  awdomain,
      output  awsnoop,
      output  awbar,
      output  awunique,
      output  awatop, 
      output  awstashnid, 
      output  awstashlpid, 
      output  awloop,
      output  awnsaid,
      output  awstashniden, 
      output  awstashlpiden,
      output  awtrace,

      //output  wid ,  
      output  wdata ,
      output  wstrb ,
      output  wlast ,
      output  wuser ,
      output  wvalid ,
      input   wready ,
      output  wpoison,
      output  wdatachk,
      output  wtrace,

      input   bid ,
      input   bresp ,
      input   buser ,
      input   bvalid ,
      output  bready ,
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
      output  wack,
      output  wack_chk,
<% } %>      
      input   bloop,
      input   btrace,
      
      output  arid , 
      output  araddr ,
      output  arlen ,
      output  arsize ,
      output  arburst ,
      output  arlock ,
      output  arcache ,
      output  arprot ,
      output  arqos ,
      output  arregion ,
      output  aruser ,
      output  arvalid ,
      input   arready ,
      output  ardomain,
      output  arsnoop,
      output  arbar,
      output  arvmidext,
      output  arloop,
      output  arnsaid,
      output  artrace,
  
      input   rid ,
      input   rdata ,
      input   rresp ,
      input   rlast ,
      input   ruser ,
      input   rvalid ,
      output  rready ,
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
      output  rack,
      output  rack_chk,
<% } %>      
      input   rpoison,                        
      input   rdatachk,
      input   rloop,
      input   rtrace,
      
      
      input   acvalid,
      output  acready,
      input   acaddr,
      input   acsnoop,
      input   acprot,
      input   acvmidext,
      input   actrace,
      
      output  crvalid,
      input   crready,
      output  crresp,
      output  crnsaid,
      output  crtrace,
      
      output  cdvalid,
      output  cdvalid_chk,
      output  cddata_chk,
      input   cdready,
      input   cdready_chk,
      output  cddata,
      output  cdlast,
      output  cdlast_chk,
      output  cdpoison,
      output  cddatachk,
      output  cdtrace,
      output  syscoreq,
      input   syscoack,
      import  async_reset_ace_master_read_addr_channel,
              drive_ace_master_read_addr_channel,
              drive_ace_master_read_addr_channel_nonvalid,
              collect_ace_master_read_addr_channel,
              async_reset_ace_master_write_addr_channel,
              drive_ace_master_write_addr_channel,
              drive_ace_master_write_addr_channel_nonvalid,
              collect_ace_master_write_addr_channel,
              async_reset_ace_master_read_data_channel,
              drive_ace_master_read_data_channel_ready,
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
              drive_ace_master_read_data_channel_rack,
              collect_ace_master_read_data_channel_rack,
<% } %>      
              collect_ace_master_read_data_channel,
              collect_ace_master_read_data_channel_every_beat,
              collect_ace_master_read_data_channel_for_driver,
              async_reset_ace_master_write_data_channel,
              drive_ace_master_write_data_channel,
              drive_ace_master_write_data_channel_nonvalid,
              collect_ace_master_write_data_channel,
              collect_ace_master_write_data_channel_every_beat,
              async_reset_ace_master_write_resp_channel,
              drive_ace_master_write_resp_channel_ready,
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
              drive_ace_master_write_resp_channel_wack,
              collect_ace_master_write_resp_channel_wack,
<% } %>      
              collect_ace_master_write_resp_channel,
              async_reset_ace_master_snoop_addr_channel,
              drive_ace_master_snoop_addr_channel,
              collect_ace_master_snoop_addr_channel,
              async_reset_ace_master_snoop_resp_channel,
              drive_ace_master_snoop_resp_channel,
              drive_ace_master_snoop_resp_channel_nonvalid,
              collect_ace_master_snoop_resp_channel,
              async_reset_ace_master_snoop_data_channel,
              drive_ace_master_snoop_data_channel,
              drive_ace_master_snoop_data_channel_nonvalid,
              collect_ace_master_snoop_data_channel
  );

  modport axi_slave (
      
      input   rst_n,
      input   awid ,
      input   awaddr ,
      input   awlen ,
      input   awsize ,
      input   awburst ,
      input   awlock ,
      input   awcache ,
      input   awprot ,
      input   awqos ,
      input   awregion ,
      input   awuser ,
      input   awvalid ,
      output  awready ,
      input   awdomain,
      input   awsnoop,
      input   awbar,
      input   awunique,
      input   awatop, 
      input   awstashnid, 
      input   awstashlpid, 
      input   awloop,
      input   awnsaid,
      input   awstashniden, 
      input   awstashlpiden,
      input   awtrace,

      //input   wid ,  
      input   wdata ,
      input   wstrb ,
      input   wlast ,
      input   wuser ,
      input   wvalid ,
      output  wready ,
      input   wpoison,
      input   wdatachk,
      input   wtrace,

      output  bid ,
      output  bresp ,
      output  buser ,
      output  bvalid ,
      input   bready ,
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
      input   wack,
      input   wack_chk,
<% } %>      
      output  bloop,
      output  btrace,
      
      input   arid , 
      input   araddr ,
      input   arlen ,
      input   arsize ,
      input   arburst ,
      input   arlock ,
      input   arcache ,
      input   arprot ,
      input   arqos ,
      input   arregion ,
      input   aruser ,
      input   arvalid ,
      output  arready ,
      input   ardomain,
      input   arsnoop,
      input   arbar,
      input   arvmidext,
      input   arloop,
      input   arnsaid,
      input   artrace,
  
      output  rid ,
      output  rdata ,
      output  rresp ,
      output  rlast ,
      output  ruser ,
      output  rvalid ,
      input   rready ,
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
      input   rack,
      input   rack_chk,
<% } %>      
      output  rpoison,                        
      output  rdatachk,
      output  rloop,
      output  rtrace,

      output  acvalid,
      input   acready,
      output  acaddr,
      output  acsnoop,
      output  acprot,
      output  acvmidext,
      output  actrace,
      
      input   crvalid,
      output  crready,
      input   crresp,
      input   crnsaid,
      input   crtrace,
      
      input   cdvalid,
      input   cdvalid_chk,
      input   cddata_chk,
      output  cdready,
      output  cdready_chk,
      input   cddata,
      input   cdlast,
      input   cdlast_chk,
      input   cdpoison,
      input   cddatachk,
      input   cdtrace,
      input   syscoreq,
      output  syscoack,
      import  force_vif_rst_n,
              release_vif_rst_n,
              async_reset_ace_slave_read_addr_channel,
              drive_ace_slave_read_addr_channel,
              collect_ace_slave_read_addr_channel,
              collect_ace_slave_read_addr_channel_for_driver,
              async_reset_ace_slave_write_addr_channel,
              drive_ace_slave_write_addr_channel,
              collect_ace_slave_write_addr_channel,
              collect_ace_slave_write_addr_channel_for_driver,
              async_reset_ace_slave_read_data_channel,
              drive_ace_slave_read_data_channel,
              collect_ace_slave_read_data_channel,
              async_reset_ace_slave_write_data_channel,
              drive_ace_slave_write_data_channel,
              collect_ace_slave_write_data_channel,
              collect_ace_slave_write_data_channel_for_driver,
              async_reset_ace_slave_write_resp_channel,
              drive_ace_slave_write_resp_channel,
              collect_ace_slave_write_resp_channel,
              async_reset_ace_slave_snoop_addr_channel,
              drive_ace_slave_snoop_addr_channel,
              collect_ace_slave_snoop_addr_channel,
              async_reset_ace_slave_snoop_resp_channel,
              drive_ace_slave_snoop_resp_channel,
              collect_ace_slave_snoop_resp_channel,
              collect_ace_slave_snoop_resp_channel_for_driver,
              async_reset_ace_slave_snoop_data_channel,
              drive_ace_slave_snoop_data_channel,
              collect_ace_slave_snoop_data_channel,
              collect_ace_slave_snoop_data_channel_for_driver

  );
  //----------------------------------------------------------------------- 
  // ASSERTS FOR READY
  //-----------------------------------------------------------------------

<% if(!obj.CUSTOMER_ENV) { %>
//SLAVE ASSERTIONS
assert_mst_awready_low_on_rst:
  assert property (@(posedge clk) disable iff((IS_IF_A_SLAVE == 1) || (goes_to_dut == 0))
		   (~rst_n) |-> ((awready == 0) || (awready === 1'bx)))
  else `ASSERT_ERROR("ERROR", "a slave asserted awready while in reset")
assert_mst_wready_low_on_rst:
  assert property (@(posedge clk) disable iff((IS_IF_A_SLAVE == 1) || (goes_to_dut == 0))
		   (~rst_n) |-> ((wready == 0) || (wready === 1'bx)))
  else `ASSERT_ERROR("ERROR", "a slave asserted wready while in reset")
assert_mst_arready_low_on_rst:
  assert property (@(posedge clk) disable iff((IS_IF_A_SLAVE == 1) || (goes_to_dut == 0))
		   (~rst_n) |-> ((arready == 0) || (arready === 1'bx)))
  else `ASSERT_ERROR("ERROR", "a slave asserted arready while in reset")
assert_mst_crready_low_on_rst:
  assert property (@(posedge clk) disable iff((IS_IF_A_SLAVE == 1) || (goes_to_dut == 0))
		   (~rst_n) |-> ((crready == 0) || (crready === 1'bx)))
  else `ASSERT_ERROR("ERROR", "a slave asserted crready while in reset")
assert_mst_cdready_low_on_rst:
  assert property (@(posedge clk) disable iff((IS_IF_A_SLAVE == 1) || (goes_to_dut == 0))
		   (~rst_n) |-> ((cdready == 0) || (cdready === 1'bx)))
  else `ASSERT_ERROR("ERROR", "a slave asserted cdready while in reset")

//MASTER ASSERTIONS
assert_slv_rready_low_on_rst:
  assert property (@(posedge clk) disable iff((IS_IF_A_SLAVE == 0) || (goes_to_dut == 0))
		   (~rst_n) |-> ((rready == 0) || (rready === 1'bx)))
  else `ASSERT_ERROR("ERROR", "a master asserted rready while in reset")
assert_slv_bready_low_on_rst:
  assert property (@(posedge clk) disable iff((IS_IF_A_SLAVE == 0) || (goes_to_dut == 0))
		   (~rst_n) |-> ((bready == 0) || (bready === 1'bx)))
  else `ASSERT_ERROR("ERROR", "a master asserted bready while in reset")
assert_slv_acready_low_on_rst:
  assert property (@(posedge clk) disable iff((IS_IF_A_SLAVE == 0) || (goes_to_dut == 0))
		   (~rst_n) |-> ((acready == 0) || (acready === 1'bx)))
  else `ASSERT_ERROR("ERROR", "a master asserted acready while in reset")

<% } %>
  //----------------------------------------------------------------------- 
  // Initial block where I call the main data tasks 
  //----------------------------------------------------------------------- 

  initial begin
      #0;
      if (IS_IF_A_SLAVE == 0) begin
          collect_ace_master_read_data_channel_main();
      end
  end

  initial begin
      #0;
      if (IS_IF_A_SLAVE == 1) begin
          collect_ace_slave_read_data_channel_main();
      end
  end
    
  initial begin
      first_reset_seen = 0;
      wait ((rst_n == 1) && (vif_rst_n == 1));
      first_reset_seen = 1;
  end

  //----------------------------------------------------------------------- 
  // Initial block where I set up plusargs 
  //----------------------------------------------------------------------- 
 
  initial begin
      string arg_value; 
      if($value$plusargs("UVM_TESTNAME=%s", arg_value)) begin
      end
      if (arg_value == "concerto_inhouse_iocache_perf_test") begin
          iocache_perf_test = 1;
      end
      else begin
          iocache_perf_test = 0;
      end
  end

  //----------------------------------------------------------------------- 
  // Initial block where we vary speeds of the BFM over time 
  //----------------------------------------------------------------------- 

  initial begin
      #0;
      if (is_bfm_delay_changing && IS_IF_A_SLAVE == 0 && IS_ACTIVE) begin
          fork 
              begin : ace_read_addr
                  automatic int random_start = $urandom_range(0, delay_changing_time_period); 
                  #(random_start * 1ns);
                  forever begin
                      ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MIN = $urandom_range(1,25);
                      ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MAX = $urandom_range(ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MIN, 100);
                      ACE_MASTER_READ_ADDR_CHANNEL_BURST_PCT = $urandom_range(5,100);
                      #(delay_changing_time_period * 1ns);
                  end
              end
              begin : ace_write_addr
                  automatic int random_start = $urandom_range(0, delay_changing_time_period); 
                  #(random_start * 1ns);
                  forever begin
                      ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MIN = $urandom_range(1,25);
                      ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MAX = $urandom_range(ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MIN, 100);
                      ACE_MASTER_WRITE_ADDR_CHANNEL_BURST_PCT = $urandom_range(5,100);
                      #(delay_changing_time_period * 1ns);
                  end
              end
              begin : ace_read_data
                  automatic int random_start = $urandom_range(0, delay_changing_time_period); 
                  #(random_start * 1ns);
                  forever begin
                      ACE_MASTER_READ_DATA_CHANNEL_DELAY_MIN = $urandom_range(1,25);
                      ACE_MASTER_READ_DATA_CHANNEL_DELAY_MAX = $urandom_range(ACE_MASTER_READ_DATA_CHANNEL_DELAY_MIN, 100);
                      ACE_MASTER_READ_DATA_CHANNEL_BURST_PCT = $urandom_range(5,100);
                      #(delay_changing_time_period * 1ns);
                  end
              end
              begin : ace_write_data
                  automatic int random_start = $urandom_range(0, delay_changing_time_period); 
                  #(random_start * 1ns);
                  forever begin
                      ACE_MASTER_WRITE_DATA_CHANNEL_DELAY_MIN = $urandom_range(1,25);
                      ACE_MASTER_WRITE_DATA_CHANNEL_DELAY_MAX = $urandom_range(ACE_MASTER_WRITE_DATA_CHANNEL_DELAY_MIN, 100);
                      ACE_MASTER_WRITE_DATA_CHANNEL_BURST_PCT = $urandom_range(5,100);
                      #(delay_changing_time_period * 1ns);
                  end
              end
              begin : ace_write_resp
                  automatic int random_start = $urandom_range(0, delay_changing_time_period); 
                  #(random_start * 1ns);
                  forever begin
                      ACE_MASTER_WRITE_RESP_CHANNEL_DELAY_MIN = $urandom_range(1,25);
                      ACE_MASTER_WRITE_RESP_CHANNEL_DELAY_MAX = $urandom_range(ACE_MASTER_WRITE_RESP_CHANNEL_DELAY_MIN, 100);
                      ACE_MASTER_WRITE_RESP_CHANNEL_BURST_PCT = $urandom_range(5,100);
                      #(delay_changing_time_period * 1ns);
                  end
              end
              begin : ace_snoop_addr
                  automatic int random_start = $urandom_range(0, delay_changing_time_period); 
                  #(random_start * 1ns);
                  forever begin
                      ACE_MASTER_SNOOP_ADDR_CHANNEL_DELAY_MIN = $urandom_range(1,25);
                      ACE_MASTER_SNOOP_ADDR_CHANNEL_DELAY_MAX = $urandom_range(ACE_MASTER_SNOOP_ADDR_CHANNEL_DELAY_MIN, 100);
                      ACE_MASTER_SNOOP_ADDR_CHANNEL_BURST_PCT = $urandom_range(5,100);
                      #(delay_changing_time_period * 1ns);
                  end
              end
              begin : ace_snoop_data
                  automatic int random_start = $urandom_range(0, delay_changing_time_period); 
                  #(random_start * 1ns);
                  forever begin
                      ACE_MASTER_SNOOP_DATA_CHANNEL_DELAY_MIN = $urandom_range(1,25);
                      ACE_MASTER_SNOOP_DATA_CHANNEL_DELAY_MAX = $urandom_range(ACE_MASTER_SNOOP_DATA_CHANNEL_DELAY_MIN, 100);
                      ACE_MASTER_SNOOP_DATA_CHANNEL_BURST_PCT = $urandom_range(5,100);
                      #(delay_changing_time_period * 1ns);
                  end
              end
              begin : ace_snoop_resp
                  automatic int random_start = $urandom_range(0, delay_changing_time_period); 
                  #(random_start * 1ns);
                  forever begin
                      ACE_MASTER_SNOOP_RESP_CHANNEL_DELAY_MIN = $urandom_range(1,25);
                      ACE_MASTER_SNOOP_RESP_CHANNEL_DELAY_MAX = $urandom_range(ACE_MASTER_SNOOP_RESP_CHANNEL_DELAY_MIN, 100);
                      ACE_MASTER_SNOOP_RESP_CHANNEL_BURST_PCT = $urandom_range(5,100);
                      #(delay_changing_time_period * 1ns);
                  end
              end
          join_none
      end
  end
 
  //----------------------------------------------------------------------- 
  // Reset Ace master read address channel
  //----------------------------------------------------------------------- 

  task automatic async_reset_ace_master_read_addr_channel();
      axi_master_cb.arvalid  <= 1'b0;
      axi_master_cb.arvalid_chk  <= 1'b0;
  <% if (obj.DutInfo.useResiliency) { %>
      axi_master_cb.araddr   <= 'b0;
      axi_master_cb.arlen    <= 'b0;
      axi_master_cb.arsize   <= 'b0;
      axi_master_cb.arburst  <= 'b0;
      axi_master_cb.arlock   <= 'b0;
      axi_master_cb.arcache  <= 'b0;
      axi_master_cb.arprot   <= 'b0;
      axi_master_cb.arqos    <= 'b0;
      axi_master_cb.arregion <= 'b0;
      axi_master_cb.aruser   <= 'b0;
      axi_master_cb.ardomain <= 'b0;
      axi_master_cb.arsnoop  <= 'b0;
      axi_master_cb.arbar    <= 'b0;
      axi_master_cb.artrace  <= 'b0;
      axi_master_cb.arvmidext<= 'b0;

 <% } else { %>
      axi_master_cb.araddr   <= 'bx;
      axi_master_cb.arlen    <= 'bx;
      axi_master_cb.arsize   <= 'bx;
      axi_master_cb.arburst  <= 'bx;
      axi_master_cb.arlock   <= 'bx;
      axi_master_cb.arcache  <= 'bx;
      axi_master_cb.arprot   <= 'bx;
      axi_master_cb.arqos    <= 'bx;
      axi_master_cb.arregion <= 'bx;
      axi_master_cb.aruser   <= 'bx;
      axi_master_cb.ardomain <= 'bx;
      axi_master_cb.arsnoop  <= 'bx;
      axi_master_cb.arbar    <= 'bx;
      axi_master_cb.artrace  <= 'bx;
      axi_master_cb.arvmidext<= 'bx;

<% } %>
 
  endtask : async_reset_ace_master_read_addr_channel

  //----------------------------------------------------------------------- 
  // Drive ace master read address channel
  //----------------------------------------------------------------------- 

  task automatic drive_ace_master_read_addr_channel(ace_read_addr_pkt_t pkt, bit valid = 1);

      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          m_drv_mst_rd_addr_q = {};
          if (first_reset_seen) begin
              @(axi_slave_cb); //in case first_reset_seen  avoid eternal loop
              return;
          end
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      if (valid) begin
          //$display("%t: Waiting for size < 4 size %0d", $time, m_drv_mst_rd_addr_q.size());
          s_ace_mst_read_addr.get();
          wait (m_drv_mst_rd_addr_q.size() < 4);
          //$display("%t: Putting packet", $time);
          @(axi_master_cb);
          m_drv_mst_rd_addr_q.push_back(pkt);
          ->e_drv_mst_rd_addr_q;
          s_ace_mst_read_addr.put();
      end
  endtask : drive_ace_master_read_addr_channel
 
  initial begin
      #0;
      if (IS_ACTIVE == 1 && IS_IF_A_SLAVE == 0) begin

          int  m_dly;
          bit  done;
          bit  was_arready_set_already;
          time t_start_time;
          ace_read_addr_pkt_t pkt;

          forever begin
              //$display("%t: Checking queue size", $time);
              if (m_drv_mst_rd_addr_q.size() > 0) begin
                  //$display("%t: Found packet to drive", $time);
                  pkt = new();
                  pkt.copy(m_drv_mst_rd_addr_q[0]);
                  if(pkt.en_user_delay_before_txn) begin
                      m_dly = pkt.val_user_delay_before_txn;
                      //$display("%0t::RD_ADDR_CHAN - Addr-%0h Inserting %0d delay before txn on intf",$realtime,pkt.araddr,m_dly);
                  end else 
                      m_dly = ($urandom_range(1,100) <= ACE_MASTER_READ_ADDR_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MIN, ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MAX));
                  was_arready_set_already = 1;
                  t_start_time            = $time;
                  done                    = 0;
                  do begin
                      if (m_dly > 0) begin
                          drive_ace_master_read_addr_channel_nonvalid();
                          @(axi_master_cb);
                          if ((rst_n == 0) || (vif_rst_n ==0)) begin
                              m_drv_mst_rd_addr_q = {};
                              break;
                          end
                          m_dly--;
                      end
                      else begin
                          axi_master_cb.arvalid  <= 1'b1;
                          axi_master_cb.arid     <= pkt.arid;
                          axi_master_cb.araddr   <= pkt.araddr;
                          axi_master_cb.arlen    <= pkt.arlen;
                          axi_master_cb.arsize   <= pkt.arsize;
                          axi_master_cb.arburst  <= pkt.arburst;
                          axi_master_cb.arlock   <= pkt.arlock;
                          axi_master_cb.arcache  <= pkt.arcache;
                          axi_master_cb.arprot   <= pkt.arprot;
                          axi_master_cb.arqos    <= pkt.arqos;
                          axi_master_cb.arregion <= pkt.arregion;
                          axi_master_cb.aruser   <= pkt.aruser;
                          axi_master_cb.ardomain <= pkt.ardomain;
                          axi_master_cb.arsnoop  <= pkt.arsnoop;
                          axi_master_cb.arbar    <= pkt.arbar;
                          axi_master_cb.artrace  <= pkt.artrace;
                          axi_master_cb.arvmidext<= pkt.arvmid;
                          if (axi_master_cb.arready && (t_start_time !== $time)) begin
                              done = 1;
                          end
                          else begin
                              was_arready_set_already = 0;
                          end
                          if (!done || was_arready_set_already) begin
                              @(axi_master_cb);
                              if ((rst_n == 0) || (vif_rst_n ==0)) begin
                                  m_drv_mst_rd_addr_q = {};
                                  break;
                              end
                          end
                      end
                  end while (!done);
                  if(pkt.en_user_delay_after_txn) begin
                      drive_ace_master_read_addr_channel_nonvalid();
                      //$display("%0t::RD_ADDR_CHAN - Addr-%0h Inserting %0d delay after txn on intf",$realtime,pkt.araddr,pkt.val_user_delay_after_txn);
                      repeat(pkt.val_user_delay_after_txn) @(axi_master_cb);
                  end
                  void'(m_drv_mst_rd_addr_q.pop_front());
              end
              else begin
                  drive_ace_master_read_addr_channel_nonvalid();
                  @(axi_master_cb);
                  if ((rst_n == 0) || (vif_rst_n ==0)) begin
                      m_drv_mst_rd_addr_q = {};
                  end
                  //$display("%t: Waiting for new packet", $time);
                  if (m_drv_mst_rd_addr_q.size == 0) begin
                      @e_drv_mst_rd_addr_q;
                  end
                  //$display("%t: Found new packet", $time);
              end
          end
      end
  end
      
  //----------------------------------------------------------------------- 
  // Drive ace master read address channel nonvalid
  //----------------------------------------------------------------------- 

  task automatic drive_ace_master_read_addr_channel_nonvalid();


      axi_master_cb.arvalid  <= 1'b0;
      axi_master_cb.arvalid_chk  <= 1'b0;

  <% if (obj.DutInfo.useResiliency) { %>

      axi_master_cb.arid     <= 'b0;
      axi_master_cb.araddr   <= 'b0;
      axi_master_cb.arlen    <= 'b0;
      axi_master_cb.arsize   <= 'b0;
      axi_master_cb.arburst  <= 'b0;
      axi_master_cb.arlock   <= 'b0;
      axi_master_cb.arcache  <= 'b0;
      axi_master_cb.arprot   <= 'b0;
      axi_master_cb.arqos    <= 'b0;
      axi_master_cb.arregion <= 'b0;
      axi_master_cb.aruser   <= 'b0;
      axi_master_cb.ardomain <= 'b0;
     // axi_master_cb.arsnoop  <= 'b0;
      axi_master_cb.arbar    <= 'b0;
      axi_master_cb.artrace  <= 'b0;
      axi_master_cb.arvmidext<= 'b0;

  <% } else { %>
      axi_master_cb.arid     <= 'bx;
      axi_master_cb.araddr   <= 'bx;
      axi_master_cb.arlen    <= 'bx;
      axi_master_cb.arsize   <= 'bx;
      axi_master_cb.arburst  <= 'bx;
      axi_master_cb.arlock   <= 'bx;
      axi_master_cb.arcache  <= 'bx;
      axi_master_cb.arprot   <= 'bx;
      axi_master_cb.arqos    <= 'bx;
      axi_master_cb.arregion <= 'bx;
      axi_master_cb.aruser   <= 'bx;
      axi_master_cb.ardomain <= 'bx;
     // axi_master_cb.arsnoop  <= 'bx;
      axi_master_cb.arbar    <= 'bx;
      axi_master_cb.artrace  <= 'bx;
      axi_master_cb.arvmidext<= 'bx;

  <% } %>

  endtask : drive_ace_master_read_addr_channel_nonvalid 
 
  //----------------------------------------------------------------------- 
  // Collect packet from ace master read address channel
  //----------------------------------------------------------------------- 

task automatic collect_ace_master_read_addr_channel(ref ace_read_addr_pkt_t pkt);
    bit done = 0;
    bit first_pass = 0;

    do begin
        @(axi_monitor_cb);
        if ((rst_n == 0) || (vif_rst_n ==0)) begin
            return;
        end
        if (arvalid && first_pass == 0) begin
            pkt.t_pkt_seen_on_intf = $time;
            first_pass = 1;
        end
        if (arvalid & axi_monitor_cb.arready) begin
            pkt.arid     = arid;
            pkt.araddr   = araddr;
            pkt.arlen    = arlen;
            pkt.arsize   = arsize;
            pkt.arburst  = arburst;
            pkt.arlock   = axi_axlock_enum_t'(arlock);
            pkt.arcache  = axi_arcache_enum_t'(arcache);
            pkt.arprot   = arprot;
            pkt.arqos    = arqos;
            pkt.arregion = arregion;
            pkt.aruser   = aruser;
            pkt.ardomain = axi_axdomain_enum_t'(ardomain);
            pkt.arsnoop  = arsnoop;
            pkt.arbar    = arbar;
            pkt.artrace  = artrace;
            //eAc =<%=obj.DutInfo.eAc%> & DVMVersionSupport=<%=obj.system.DVMVersionSupport%>
            <% if (obj.DutInfo.eAc == 1 && obj.system.DVMVersionSupport > 128) { %>
            pkt.arvmid   = arvmidext; //KDB
            <% } %>
            done         = 1;
        end
    end while (!done);
endtask : collect_ace_master_read_addr_channel 
 
  //----------------------------------------------------------------------- 
  // Reset Ace master write address channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_master_write_addr_channel();
      axi_master_cb.awvalid  <= 'b0;
      axi_master_cb.awvalid_chk  <= 'b0;

  <% if (obj.DutInfo.useResiliency) { %>
      axi_master_cb.awaddr        <= 'b0;
      axi_master_cb.awlen         <= 'b0;
      axi_master_cb.awsize        <= 'b0;
      axi_master_cb.awburst       <= 'b0;
      axi_master_cb.awlock        <= 'b0;
      axi_master_cb.awcache       <= 'b0;
      axi_master_cb.awprot        <= 'b0;
      axi_master_cb.awqos         <= 'b0;
      axi_master_cb.awregion      <= 'b0;
      axi_master_cb.awuser        <= 'b0;
      axi_master_cb.awdomain      <= 'b0;
      axi_master_cb.awsnoop       <= 'b0;
      axi_master_cb.awbar         <= 'b0;
      axi_master_cb.awunique      <= 'b0;
      axi_master_cb.awatop        <= 'b0;
      axi_master_cb.awstashnid    <= 'b0;
      axi_master_cb.awstashlpid   <= 'b0; 
      axi_master_cb.awstashniden  <= 'b0;
      axi_master_cb.awstashlpiden <= 'b0;
      axi_master_cb.awtrace       <= 'b0;

  <% } else { %>
      axi_master_cb.awaddr        <= 'bx;
      axi_master_cb.awlen         <= 'bx;
      axi_master_cb.awsize        <= 'bx;
      axi_master_cb.awburst       <= 'bx;
      axi_master_cb.awlock        <= 'bx;
      axi_master_cb.awcache       <= 'bx;
      axi_master_cb.awprot        <= 'bx;
      axi_master_cb.awqos         <= 'bx;
      axi_master_cb.awregion      <= 'bx;
      axi_master_cb.awuser        <= 'bx;
      axi_master_cb.awdomain      <= 'bx;
      axi_master_cb.awsnoop       <= 'bx;
      axi_master_cb.awbar         <= 'bx;
      axi_master_cb.awunique      <= 'bx;
      axi_master_cb.awatop        <= 'bx;
      axi_master_cb.awstashnid    <= 'bx;
      axi_master_cb.awstashlpid   <= 'bx; 
      axi_master_cb.awstashniden  <= 'bx;
      axi_master_cb.awstashlpiden <= 'bx;
      axi_master_cb.awtrace       <= 'bx;
  <% } %>
  endtask : async_reset_ace_master_write_addr_channel

  //----------------------------------------------------------------------- 
  // Drive ace master write address channel
  //----------------------------------------------------------------------- 

  task automatic drive_ace_master_write_addr_channel(ace_write_addr_pkt_t pkt, bit valid = 1);

      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          m_drv_mst_wr_addr_q = {};
          if (first_reset_seen) begin
              return;
          end
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      if (valid) begin
          s_ace_mst_write_addr.get();
          wait (m_drv_mst_wr_addr_q.size() < 4); 
//          wait (m_drv_mst_wr_addr_q.size() < 1);
          @(axi_master_cb);
          m_drv_mst_wr_addr_q.push_back(pkt);
          ->e_drv_mst_wr_addr_q;
          s_ace_mst_write_addr.put();
      end
  endtask : drive_ace_master_write_addr_channel
 
  initial begin
      #0;
      if (IS_ACTIVE == 1 && IS_IF_A_SLAVE == 0) begin

          int  m_dly;
          bit  done;
          bit  was_awready_set_already;
          time t_start_time;
          ace_write_addr_pkt_t pkt;

          forever begin
              if (m_drv_mst_wr_addr_q.size() > 0) begin
                  pkt = new();
                  pkt.copy(m_drv_mst_wr_addr_q[0]);
                  if(pkt.en_user_delay_before_txn) begin
                      m_dly = pkt.val_user_delay_before_txn;
                      //$display("%0t::WR_ADDR_CHAN - Addr-%0h Inserting %0d delay before txn on intf",$realtime,pkt.awaddr,m_dly);
                  end else
                      m_dly = ($urandom_range(1,100) <= ACE_MASTER_WRITE_ADDR_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MIN, ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MAX));
                  was_awready_set_already = 1;
                  t_start_time            = $time;
                  done                    = 0;
                  do begin
                      if (m_dly > 0) begin
                          drive_ace_master_write_addr_channel_nonvalid();
                          @(axi_master_cb);
                          if ((rst_n == 0) || (vif_rst_n ==0)) begin
                              m_drv_mst_wr_addr_q = {};
                              break;
                          end
                          m_dly--;
                      end
                      else begin
                          axi_master_cb.awvalid       <= 1'b1;
                          axi_master_cb.awid          <= pkt.awid;
                          axi_master_cb.awaddr        <= pkt.awaddr;
                          axi_master_cb.awlen         <= pkt.awlen;
                          axi_master_cb.awsize        <= pkt.awsize;
                          axi_master_cb.awburst       <= pkt.awburst;
                          axi_master_cb.awlock        <= pkt.awlock;
                          axi_master_cb.awcache       <= pkt.awcache;
                          axi_master_cb.awprot        <= pkt.awprot;
                          axi_master_cb.awqos         <= pkt.awqos;
                          axi_master_cb.awregion      <= pkt.awregion;
                          axi_master_cb.awuser        <= pkt.awuser;
                          axi_master_cb.awdomain      <= pkt.awdomain;
                          axi_master_cb.awsnoop       <= pkt.awsnoop;
                          axi_master_cb.awbar         <= pkt.awbar;
                          axi_master_cb.awunique      <= pkt.awunique;
                          axi_master_cb.awatop        <= pkt.awatop; 
                          axi_master_cb.awstashnid    <= pkt.awstashnid; 
                          axi_master_cb.awstashlpid   <= pkt.awstashlpid; 
                          axi_master_cb.awstashniden  <= pkt.awstashniden; 
                          axi_master_cb.awstashlpiden <= pkt.awstashlpiden;
                          axi_master_cb.awtrace       <= pkt.awtrace;
                          if (axi_master_cb.awready && (t_start_time !== $time)) begin
                              done = 1;
                          end
                          else begin
                              was_awready_set_already = 0;
                          end
                          if (!done || was_awready_set_already) begin
                              @(axi_master_cb);
                              if ((rst_n == 0) || (vif_rst_n ==0)) begin
                                  m_drv_mst_wr_addr_q = {};
                                  break;
                              end
                          end
                      end
                  end while (!done);
                  if(pkt.en_user_delay_after_txn) begin
                      drive_ace_master_write_addr_channel_nonvalid();
                      //$display("%0t::WR_ADDR_CHAN - Addr-%0h Inserting %0d delay after txn on intf",$realtime,pkt.awaddr,pkt.val_user_delay_after_txn);
                      repeat(pkt.val_user_delay_after_txn) @(axi_master_cb);
                  end
                  void'(m_drv_mst_wr_addr_q.pop_front());
              end
              else begin
                  drive_ace_master_write_addr_channel_nonvalid();
                  @(axi_master_cb);
                  if ((rst_n == 0) || (vif_rst_n ==0)) begin
                      m_drv_mst_wr_addr_q = {};
                  end
                  if (m_drv_mst_wr_addr_q.size == 0) begin
                      @e_drv_mst_wr_addr_q;
                  end
              end
          end
      end
  end
      
  //----------------------------------------------------------------------- 
  // Drive ace master write address channel nonvalid
  //----------------------------------------------------------------------- 
  task automatic drive_ace_master_write_addr_channel_nonvalid;

      axi_master_cb.awvalid  <= 1'b0;
      axi_master_cb.awvalid_chk  <= 1'b0;

  <% if (obj.DutInfo.useResiliency) { %>

      axi_master_cb.awid          <= 'b0;
      axi_master_cb.awaddr        <= 'b0;
      axi_master_cb.awlen         <= 'b0;
      axi_master_cb.awsize        <= 'b0;
      axi_master_cb.awburst       <= 'b0;
      axi_master_cb.awlock        <= 'b0;
      axi_master_cb.awcache       <= 'b0;
      axi_master_cb.awprot        <= 'b0;
      axi_master_cb.awqos         <= 'b0;
      axi_master_cb.awregion      <= 'b0;
      axi_master_cb.awuser        <= 'b0;
      axi_master_cb.awdomain      <= 'b0;
      axi_master_cb.awsnoop       <= 'b0;
      axi_master_cb.awbar         <= 'b0;
      axi_master_cb.awunique      <= 'b0;
      axi_master_cb.awatop        <= 'b0;
      axi_master_cb.awstashnid    <= 'b0;
      axi_master_cb.awstashlpid   <= 'b0;
      axi_master_cb.awstashniden  <= 'b0;
      axi_master_cb.awstashlpiden <= 'b0;
      axi_master_cb.awtrace       <= 'b0;

   <% } else { %>
      axi_master_cb.awid          <= 'bx;
      axi_master_cb.awaddr        <= 'bx;
      axi_master_cb.awlen         <= 'bx;
      axi_master_cb.awsize        <= 'bx;
      axi_master_cb.awburst       <= 'bx;
      axi_master_cb.awlock        <= 'bx;
      axi_master_cb.awcache       <= 'bx;
      axi_master_cb.awprot        <= 'bx;
      axi_master_cb.awqos         <= 'bx;
      axi_master_cb.awregion      <= 'bx;
      axi_master_cb.awuser        <= 'bx;
      axi_master_cb.awdomain      <= 'bx;
      axi_master_cb.awsnoop       <= 'bx;
      axi_master_cb.awbar         <= 'bx;
      axi_master_cb.awunique      <= 'bx;
      axi_master_cb.awatop        <= 'bx;
      axi_master_cb.awstashnid    <= 'bx;
      axi_master_cb.awstashlpid   <= 'bx;
      axi_master_cb.awstashniden  <= 'bx;
      axi_master_cb.awstashlpiden <= 'bx;
      axi_master_cb.awtrace       <= 'bx;
   <% } %>
  endtask : drive_ace_master_write_addr_channel_nonvalid 
      

  //----------------------------------------------------------------------- 
  // Collect packet from ace master write address channel
  //----------------------------------------------------------------------- 

task automatic collect_ace_master_write_addr_channel(ref ace_write_addr_pkt_t pkt);
    bit done = 0;
    bit first_pass = 0;
    
    do begin
        @(axi_monitor_cb);
        if ((rst_n == 0) || (vif_rst_n ==0)) begin
            return;
        end
        if (awvalid && first_pass == 0) begin
            pkt.t_pkt_seen_on_intf = $time;
            first_pass = 1;
        end
        if (awvalid & axi_monitor_cb.awready) begin
            pkt.awid          = awid;
            pkt.awaddr        = awaddr;
            pkt.awlen         = awlen;
            pkt.awsize        = awsize;
            pkt.awburst       = awburst;
            pkt.awlock        = axi_axlock_enum_t'(awlock);
            pkt.awcache       = axi_awcache_enum_t'(awcache);
            pkt.awprot        = awprot;
            pkt.awqos         = awqos;
            pkt.awregion      = awregion;
            pkt.awuser        = awuser;
            pkt.awdomain      = axi_axdomain_enum_t'(awdomain);
            pkt.awsnoop       = awsnoop;
            pkt.awbar         = awbar;
            pkt.awunique      = awunique;
            pkt.awatop        = awatop; 
            pkt.awstashnid    = awstashnid; 
            pkt.awstashlpid   = awstashlpid; 
            pkt.awstashniden  = awstashniden; 
            pkt.awstashlpiden = awstashlpiden;
            pkt.awtrace       = awtrace;
            done              = 1;
        end
    end while (!done);
endtask : collect_ace_master_write_addr_channel 
 
//----------------------------------------------------------------------- 
  // Reset Ace master read data channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_master_read_data_channel();
      axi_master_cb.rready <= 1'b0;
      axi_master_cb.rready_chk <= 1'b0;
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
      axi_master_cb.rack   <= 1'b0;
      axi_master_cb.rack_chk   <= 1'b0;
<% } %>      
  endtask : async_reset_ace_master_read_data_channel
//------------------------------------------------------------------------------
// Perf counter clear stall function
//------------------------------------------------------------------------------
function void   ace_clear_stalls(int cnt_id);
  en_aw_stall       = 0 ;
  en_w_stall        = 0 ;
  en_b_stall        = 0 ;
  en_ar_stall       = 0 ;
  en_r_stall        = 0 ;
  en_cd_stall       = 0 ;
  en_ac_stall       = 0 ;
  en_cr_stall       = 0 ;
endfunction: ace_clear_stalls

  //----------------------------------------------------------------------- 
  // Drive ace master read data channel - ready
  //----------------------------------------------------------------------- 
 task automatic drive_ace_master_read_data_channel_ready(bit ready=1);
      int m_dly;
      bit done;

      m_dly = ($urandom_range(1,100) <= ACE_MASTER_READ_DATA_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_MASTER_READ_DATA_CHANNEL_DELAY_MIN, ACE_MASTER_READ_DATA_CHANNEL_DELAY_MAX));
      if (ACE_MASTER_READ_DATA_CHANNEL_WAIT_FOR_VLD) begin
          m_dly = 1;
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      do begin
          @(axi_master_cb);
          if (ready && (ACE_MASTER_READ_DATA_CHANNEL_WAIT_FOR_VLD == 1 ? rvalid : 1)) begin
              if (m_dly == 0) begin
                 if (rvalid == 1 && bloc_axi_stall == 1 ) begin
                    axi_master_cb.rready <= 1'b0; 
                    cnt_rdy_blckd_duration++;
                    if ( cnt_rdy_blckd_duration == RDY_NOT_ASSERTED_DURATION ) begin
                        cnt_rdy_blckd_duration = 0;
                        bloc_axi_stall         = 0;
                    end  
                 end 
                 else
                 if (rvalid == 1 && en_r_stall == 1 ) begin
                     axi_master_cb.rready <= 1'b0;
                     if(stall_r_chnl_till_en_r_stall_deassrt==1) begin
                         forever begin
                            @(posedge clk) ; 
                            if (en_r_stall == 0) begin 
                                 break;
                            end                         
                         end
                     end else begin
                         for (int i = 0; i <= stall_r_period; i++) begin
                            @(posedge clk) ; 
                            if (en_r_stall == 0) begin 
                                 break;
                            end                         
                         end
                     end
                     //cnt_stall++;
                     axi_master_cb.rready <= 1'b1;
                     @(posedge clk) ;
                     /*if (cnt_stall == stall_number) begin
                        en_r_stall = 0;
                        cnt_stall   = 0;
                     end */
                 end 
                 else begin
                  axi_master_cb.rready <= 1'b1;
                 end 
              end
              else begin
                  axi_master_cb.rready <= 1'b0;
              end
          end 
          else begin
              axi_master_cb.rready <= 1'b0;
          end

          done = m_dly ? 0 : 1;
          if (m_dly) m_dly--;
      end while (!done);  

  endtask : drive_ace_master_read_data_channel_ready
      
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
  //----------------------------------------------------------------------- 
  // Drive ace master read data channel - rack
  //----------------------------------------------------------------------- 
  task automatic drive_ace_master_read_data_channel_rack();

      @(axi_master_cb);
      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          rack_count = 0;
          return;
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      if (rready & axi_master_cb.rvalid & axi_master_cb.rlast) begin
          rack_count++;
      end
  endtask : drive_ace_master_read_data_channel_rack

  initial begin
      #0;
      if (IS_ACTIVE == 1 && IS_IF_A_SLAVE == 0) begin
          int m_dly;
          forever begin
              wait (rack_count > 0);
              m_dly = ($urandom_range(1,100) <= ACE_MASTER_READ_DATA_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_MASTER_READ_DATA_CHANNEL_DELAY_MIN, ACE_MASTER_READ_DATA_CHANNEL_DELAY_MAX));
              if (m_dly > 0) begin
                  axi_master_cb.rack <= 1'b0;
                  repeat(m_dly) @(axi_master_cb);
                  m_dly = 0;
              end
              axi_master_cb.rack <= 1'b1;
              @(axi_master_cb);
              rack_count--;
              if (rack_count == 0) begin
                  axi_master_cb.rack <= 1'b0;
              end
          end
      end
  end

  //----------------------------------------------------------------------- 
  // Collect ace master read data channel - rack
  //----------------------------------------------------------------------- 
  task automatic collect_ace_master_read_data_channel_rack();
      bit done = 0;
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.rack) begin
              done = 1;
          end
      end while (!done);
 
  endtask : collect_ace_master_read_data_channel_rack
<% } %>      
 
  //----------------------------------------------------------------------- 
  // Collect packet from ace master read data channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_master_read_data_channel(ref ace_read_data_pkt_t pkt);
      automatic bit done;

      @e_mon_mst_rd_collected;
      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          m_mon_mst_rd_data_q = {};
          return;
      end
      if (m_mon_mst_rd_data_q.size > 0) begin
          pkt = m_mon_mst_rd_data_q.pop_front();
      end
  endtask : collect_ace_master_read_data_channel

  task automatic collect_ace_master_read_data_channel_main();
      int                                         tmp_var[$];
      axi_arid_logic_t q_ids_being_collected[$];
      wait ((rst_n == 1) && (vif_rst_n == 1));
      forever begin
          `ifdef QUESTA
              #0;
          `endif
<% if(obj.testBench == 'dii' || obj.testBench == 'fsys') { %>
`ifdef VCS
              #0;
`endif // `ifdef VCS 
<% } %>
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              q_ids_being_collected = {};
              continue;
          end
          if (axi_monitor_cb.rvalid & rready) begin
              // Hitting a weird issue where if rid = 0 for the first rdata packet, its value below is x. Hacking this to set it to 0 if value is x.
              //axi_arid_logic_t m_tmp_rid;
              //if ($isunknown(axi_monitor_cb.rid)) begin
              //    m_tmp_rid = '0;
              //end
              //else begin
              //    m_tmp_rid = axi_monitor_cb.rid;
              //end
              tmp_var = {};
              tmp_var = q_ids_being_collected.find_index with (item == axi_monitor_cb.rid);
              //tmp_var = q_ids_being_collected.find_index with (item == m_tmp_rid);
              if (tmp_var.size() == 0) begin
                  fork 
                      begin
                          int tmp_var2[$];
                          q_ids_being_collected.push_back(axi_monitor_cb.rid);
                          collect_ace_master_read_data_channel_each(axi_monitor_cb.rid);
                          //q_ids_being_collected.push_back(m_tmp_rid);
                          //collect_ace_master_read_data_channel_each(m_tmp_rid);
                          tmp_var2 = {};
                          tmp_var2 = q_ids_being_collected.find_first_index with (item == axi_monitor_cb.rid); 
                          //tmp_var2 = q_ids_being_collected.find_first_index with (item == m_tmp_rid); 
`ifdef QUESTA
	 #0;// Don't delete ID until current time is done or can be sampled 2 times
`endif
<% if(obj.testBench == 'dii' || obj.testBench == 'fsys') { %>
`ifdef VCS
              #0;// Don't delete ID until current time is done or can be sampled 2 times
`endif // `ifdef VCS 
<% } %>
                          if (q_ids_being_collected.size() > 0)
                          q_ids_being_collected.delete(tmp_var2[0]);
                      end
                  join_none
              end
          end
      end
  endtask : collect_ace_master_read_data_channel_main

    task automatic collect_ace_master_read_data_channel_each(axi_arid_logic_t m_rid);
        automatic int                                    beat_cnt;
        automatic axi_xdata_t data[256];
        automatic axi_rresp_t resp[256];
        automatic axi_rpoison_t poison[256];
        automatic axi_rdatachk_t datachk[256];
        automatic int                                    rdata_pattern[256];
        automatic time                                   t_timestamp[256];
        automatic bit                                    done;
        ace_read_data_pkt_t                              pkt;
        int                                              tmp_var[$];
        bit                                              first_pass = 0;
    
        beat_cnt = 0;
        done     = 0;
        pkt      = new();
    
        do begin
            if (rvalid && first_pass == 0) begin
                pkt.t_pkt_seen_on_intf = $time;
                first_pass = 1;
            end
            if ((axi_monitor_cb.rvalid == 1) && 
                (rready == 1) && 
                (m_rid == axi_monitor_cb.rid)
            ) begin
                pkt.rid               = axi_monitor_cb.rid;
                data[beat_cnt]        = axi_monitor_cb.rdata;
                resp[beat_cnt]        = axi_monitor_cb.rresp;
                poison[beat_cnt]      = axi_monitor_cb.rpoison;
                datachk[beat_cnt]     = axi_monitor_cb.rdatachk;
                pkt.rtrace            = axi_monitor_cb.rtrace;
                pkt.rresp             = axi_monitor_cb.rresp;
                pkt.ruser             = axi_monitor_cb.ruser;
                pkt.rlast             = axi_monitor_cb.rlast;
                t_timestamp[beat_cnt] = $time;
                rdata_pattern[beat_cnt] = match_pattern;
	            match_pattern++;
                if (axi_monitor_cb.rlast) begin
                    pkt.rdata          = new[beat_cnt + 1] (data);
                    pkt.rdata_pattern  = new[beat_cnt + 1] (rdata_pattern);
                    pkt.rresp_per_beat = new[beat_cnt + 1] (resp);
                    pkt.rpoison        = new[beat_cnt + 1] (poison);
                    pkt.rdatachk       = new[beat_cnt + 1] (datachk);
                    pkt.t_rtime        = new[beat_cnt + 1] (t_timestamp);
                    done               = 1;
                    beat_cnt           = 0;
                    m_mon_mst_rd_data_q.push_back(pkt);
                    m_mon_mst_rd_data_for_driver_q.push_back(pkt);
                    ->e_mon_mst_rd_collected;
                end 
                else begin
                    beat_cnt++;
                end
            end
            if (!done) begin
                @(axi_monitor_cb);
                if ((rst_n == 0) || (vif_rst_n ==0)) begin
                    m_mon_mst_rd_data_for_driver_q = {};
                    m_mon_mst_rd_data_q            = {};
                    return;
                end
            end
        end while (!done);
    endtask : collect_ace_master_read_data_channel_each 
 
  task automatic collect_ace_master_read_data_channel_every_beat(ref ace_read_data_pkt_t pkt);
      bit done = 0;
      bit first_pass = 0;
      pkt = new();

      pkt.rdata    = new[1];
      pkt.rpoison  = new[1];
      pkt.rdatachk = new[1];
      pkt.t_rtime  = new[1];
      do begin
          //@(axi_monitor_cb);
          if (rvalid && first_pass == 0) begin
              pkt.t_pkt_seen_on_intf = $time;
              first_pass = 1;
          end
          if ((axi_monitor_cb.rvalid == 1) && 
              (rready == 1) 
          ) begin
              pkt.rid         = axi_monitor_cb.rid;
              pkt.rdata[0]    = axi_monitor_cb.rdata;
              pkt.rpoison[0]  = axi_monitor_cb.rpoison;
              pkt.rdatachk[0] = axi_monitor_cb.rdatachk;
              pkt.rtrace      = axi_monitor_cb.rtrace;
              pkt.rresp       = axi_monitor_cb.rresp;
              pkt.ruser       = axi_monitor_cb.ruser;
              pkt.t_rtime[0]  = $time;
	          done = 1'b1;
              pkt.rlast      = axi_monitor_cb.rlast;
          end
          //if (!done) begin
           @(axi_monitor_cb);
           if ((rst_n == 0) || (vif_rst_n ==0)) begin
               return;
           end
          //end
      end while (!done);
  endtask : collect_ace_master_read_data_channel_every_beat
 
  //----------------------------------------------------------------------- 
  // Collect packet from ace master read data channel for driver 
  //----------------------------------------------------------------------- 

  task automatic collect_ace_master_read_data_channel_for_driver(ref ace_read_data_pkt_t pkt);
      automatic bit done;

      @e_mon_mst_rd_collected;
      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          return;
      end
      if (m_mon_mst_rd_data_for_driver_q.size > 0) begin
          pkt = m_mon_mst_rd_data_for_driver_q.pop_front();
      end
  endtask : collect_ace_master_read_data_channel_for_driver


  //----------------------------------------------------------------------- 
  // Reset Ace master write data channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_master_write_data_channel();

      axi_master_cb.wvalid <= 1'b0;
      axi_master_cb.awvalid_chk <= 1'b0;

  <% if (obj.DutInfo.useResiliency) { %>
      axi_master_cb.wdata    <= 'b0;
      axi_master_cb.wstrb    <= 'b0;
      axi_master_cb.wlast    <= 'b0;
      axi_master_cb.wuser    <= 'b0;
      axi_master_cb.wtrace   <= 'b0;
      axi_master_cb.wpoison  <= 'b0;
      axi_master_cb.wdatachk <= 'b0;
  <% } else { %>
      axi_master_cb.wdata    <= 1'bx;
      axi_master_cb.wstrb    <= 1'bx;
      axi_master_cb.wlast    <= 1'bx;
      axi_master_cb.wuser    <= 1'bx;
      axi_master_cb.wtrace   <= 'bx;
      axi_master_cb.wpoison  <= 'bx;
      axi_master_cb.wdatachk <= 'bx;
  <% } %>
  endtask : async_reset_ace_master_write_data_channel

  //----------------------------------------------------------------------- 
  // Drive ace master write data channel
  //----------------------------------------------------------------------- 
  
  task automatic drive_ace_master_write_data_channel(ace_write_data_pkt_t pkt, axi_axlen_logic_t len, bit valid = 1);

      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          m_drv_mst_wr_data_q = {};
          if (first_reset_seen) begin
              return;
          end
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      if (valid) begin
          s_ace_mst_write_data.get();
          wait (m_drv_mst_wr_data_q.size() < 16);
          @(axi_master_cb);
          for (int i = 0; i <= len; i++) begin
              ace_write_data_pkt_t m_pkt;
              m_pkt             = new();
              m_pkt.wlast       = ((i == len) ? 1'b1 : 1'b0);
              m_pkt.wuser       = pkt.wuser;
              m_pkt.wtrace      = pkt.wtrace;
              m_pkt.wstrb       = new[1];
              m_pkt.wstrb[0]    = pkt.wstrb[i];
              m_pkt.wdata       = new[1];
              m_pkt.wdata[0]    = pkt.wdata[i];
              m_pkt.wpoison     = new[1];
              m_pkt.wpoison[0]  = pkt.wpoison[i];
              m_pkt.wdatachk    = new[1];
              m_pkt.wdatachk[0] = pkt.wdatachk[i];
              m_drv_mst_wr_data_q.push_back(m_pkt);
              ->e_drv_mst_wr_data_q;
          end 
          s_ace_mst_write_data.put();
      end
  endtask : drive_ace_master_write_data_channel

  initial begin
      #0;
      if (IS_ACTIVE == 1 && IS_IF_A_SLAVE == 0) begin

          int  m_dly;
          bit  done;
          bit  was_wready_set_already;
          time t_start_time;
          ace_write_data_pkt_t pkt;

          forever begin
              //$display("%t: Checking queue size", $time);
              if (m_drv_mst_wr_data_q.size() > 0) begin
                  //$display("%t: Found packet to drive", $time);
                  pkt = new();
                  pkt = m_drv_mst_wr_data_q.pop_front();
                  if(pkt.en_user_delay_before_txn) begin
                      m_dly = pkt.val_user_delay_before_txn;
                      //$display("%0t::WR_DATA_CHAN - Inserting %0d delay before txn on intf",$realtime,m_dly);
                  end
                  else begin
                      m_dly = ($urandom_range(1,100) <= ACE_MASTER_WRITE_DATA_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_MASTER_WRITE_DATA_CHANNEL_DELAY_MIN, ACE_MASTER_WRITE_DATA_CHANNEL_DELAY_MAX));
                  end
                  was_wready_set_already = 1;
                  t_start_time            = $time;
                  done                    = 0;
                  do begin
                      if (m_dly > 0) begin
                          drive_ace_master_write_data_channel_nonvalid();
                          @(axi_master_cb);
                          if ((rst_n == 0) || (vif_rst_n ==0)) begin
                              m_drv_mst_wr_data_q = {};
                              break;
                          end
                          m_dly--;
                      end
                      else begin
                          axi_master_cb.wvalid   <= 1'b1;
                          axi_master_cb.wlast    <= pkt.wlast; 
                          axi_master_cb.wuser    <= pkt.wuser;
                          axi_master_cb.wtrace   <= pkt.wtrace;
                          axi_master_cb.wpoison  <= pkt.wpoison[0];
                          axi_master_cb.wdatachk <= pkt.wdatachk[0];
                          axi_master_cb.wstrb    <= pkt.wstrb[0];
                          axi_master_cb.wdata    <= pkt.wdata[0];
                          if (axi_master_cb.wready && (t_start_time !== $time)) begin
                              done = 1;
                          end
                          else begin
                              was_wready_set_already = 0;
                          end
                          if (!done || was_wready_set_already) begin
                              @(axi_master_cb);
                              if ((rst_n == 0) || (vif_rst_n ==0)) begin
                                  m_drv_mst_wr_data_q = {};
                                  break;
                              end
                          end
                      end
                  end while (!done);
                  if(pkt.en_user_delay_after_txn) begin
                      drive_ace_master_write_data_channel_nonvalid();
                      //$display("%0t::WR_DATA_CHAN - Inserting %0d delay after txn on intf",$realtime,pkt.val_user_delay_after_txn);
                      repeat(pkt.val_user_delay_after_txn) @(axi_master_cb);
                  end
              end
              else begin
                  drive_ace_master_write_data_channel_nonvalid();
                  @(axi_master_cb);
                  if ((rst_n == 0) || (vif_rst_n ==0)) begin
                      m_drv_mst_wr_data_q = {};
                  end
                  //$display("%t: Waiting for new packet", $time);
                  if (m_drv_mst_wr_data_q.size == 0) begin
                      @e_drv_mst_wr_data_q;
                  end
                  //$display("%t: Found new packet", $time);
              end
          end
      end
  end
      
  //----------------------------------------------------------------------- 
  // Drive ace master write data channel nonvalid
  //----------------------------------------------------------------------- 
  task automatic drive_ace_master_write_data_channel_nonvalid;

      axi_master_cb.wvalid <= 1'b0;
      axi_master_cb.wlast  <= 1'b0;
      axi_master_cb.wvalid_chk <= 1'b0;
      axi_master_cb.wlast_chk  <= 1'b0;

  <% if (obj.DutInfo.useResiliency) { %>
      axi_master_cb.wstrb    <= 'b0;
      axi_master_cb.wdata    <= 'b0;
      axi_master_cb.wuser    <= 'b0;
      axi_master_cb.wtrace   <= 'b0;
      axi_master_cb.wpoison  <= 'b0;
      axi_master_cb.wdatachk <= 'b0;
  <% } else { %>
      axi_master_cb.wstrb    <= 'bx;
      axi_master_cb.wdata    <= 'bx;
      axi_master_cb.wuser    <= 'bx;
      axi_master_cb.wtrace   <= 'bx;
      axi_master_cb.wpoison  <= 'bx;
      axi_master_cb.wdatachk <= 'bx;
  <% } %>


  endtask : drive_ace_master_write_data_channel_nonvalid 

  //----------------------------------------------------------------------- 
  // Collect packet from ace master write data channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_master_write_data_channel(ref ace_write_data_pkt_t pkt);
      automatic int              beat_cnt;
      automatic axi_xdata_t data[256];
      automatic axi_xstrb_t strb[256];
      automatic axi_wpoison_t poison[256];
      automatic axi_wdatachk_t datachk[256];
      automatic time             t_timestamp[256];
      automatic bit              done;
      automatic bit              first_pass = 0;
  
      beat_cnt = 0;
      done     = 0;
  
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (wvalid && first_pass == 0) begin
              pkt.t_pkt_seen_on_intf = $time;
              first_pass = 1;
          end
          if (wvalid & axi_monitor_cb.wready) begin
              //pkt.wid               = wid;
              data[beat_cnt]        = wdata;
              strb[beat_cnt]        = wstrb;
              poison[beat_cnt]      = wpoison;
              datachk[beat_cnt]     = wdatachk;
              pkt.wuser             = wuser;
              pkt.wtrace            = wtrace;
              t_timestamp[beat_cnt] = $time;
              if (wlast) begin
                  pkt.wdata    = new[beat_cnt + 1] (data);
                  pkt.wstrb    = new[beat_cnt + 1] (strb);
                  pkt.wpoison  = new[beat_cnt + 1] (poison);
                  pkt.wdatachk = new[beat_cnt + 1] (datachk);
                  pkt.t_wtime  = new[beat_cnt + 1] (t_timestamp);
                  done        = 1;
                  beat_cnt    = 0;
              end 
              else begin
                  beat_cnt++;
              end
          end
      end while (!done);
  endtask : collect_ace_master_write_data_channel 
    
  task automatic collect_ace_master_write_data_channel_every_beat(ref ace_write_data_pkt_t pkt);
      automatic bit done;
      pkt = new();
  
      done = 0;
  
      pkt.wdata    = new[1];
      pkt.wstrb    = new[1];
      pkt.wpoison  = new[1];
      pkt.wdatachk = new[1];
      pkt.t_wtime  = new[1];
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (wvalid & axi_monitor_cb.wready) begin
              pkt.wdata[0]    = wdata;
              pkt.wstrb[0]    = wstrb;
              pkt.wpoison[0]  = wpoison;
              pkt.wdatachk[0] = wdatachk;
              pkt.wtrace      = wtrace;
              pkt.wuser       = wuser;
              pkt.t_wtime[0]  = $time;
              pkt.wlast       = wlast;
              done            = 1;
          end
      end while (!done);
  endtask : collect_ace_master_write_data_channel_every_beat 
 
  //----------------------------------------------------------------------- 
  // Reset Ace master write resp channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_master_write_resp_channel();
      axi_master_cb.bready <= 1'b0;
      axi_master_cb.bready_chk <= 1'b0;
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
      axi_master_cb.wack   <= 1'b0;
      axi_master_cb.wack_chk   <= 1'b0;
<% } %>      
  endtask : async_reset_ace_master_write_resp_channel

  //----------------------------------------------------------------------- 
  // Drive ace master write resp channel - ready
  //----------------------------------------------------------------------- 
  task automatic drive_ace_master_write_resp_channel_ready(bit ready=1);
      int m_dly;
      bit done;

      m_dly = ($urandom_range(1,100) <= ACE_MASTER_WRITE_RESP_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_MASTER_WRITE_RESP_CHANNEL_DELAY_MIN, ACE_MASTER_WRITE_RESP_CHANNEL_DELAY_MAX));
      if (ACE_MASTER_WRITE_RESP_CHANNEL_WAIT_FOR_VLD) begin
          m_dly = 1;
      end
      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          axi_master_cb.bready <= 1'b0;
		  #1; // avoid infinite loop in case of reset
          return;
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      do begin
          @(axi_master_cb);
          if (ready && (ACE_MASTER_WRITE_RESP_CHANNEL_WAIT_FOR_VLD == 1 ? bvalid : 1)) begin
              if (m_dly == 0) begin
                 if (bvalid == 1 && bloc_axi_stall == 1 ) begin
                    axi_master_cb.bready    <= 1'b0; 
                    cnt_rdy_blckd_duration++;
                    if ( cnt_rdy_blckd_duration == RDY_NOT_ASSERTED_DURATION ) begin
                        cnt_rdy_blckd_duration = 0;
                        bloc_axi_stall         = 0;
                    end 
                 end 
                 else 
                 if (bvalid == 1 && en_b_stall == 1 ) begin
                     axi_master_cb.bready <= 1'b0;
                     if(stall_b_chnl_till_en_b_stall_deassrt) begin
                         forever begin
                             if (en_b_stall == 0) begin 
                                 break;
                            end                    
                            @(posedge clk) ; 
                         end
                     end else begin
                         for (int i = 0; i <= stall_b_period; i++) begin
                             if (en_b_stall == 0) begin 
                                 break;
                            end                    
                            @(posedge clk) ; 
                         end
                     end
                     axi_master_cb.bready <= 1'b1;
                     @(posedge clk) ; 
                 end  
                 else begin
                  axi_master_cb.bready  <= 1'b1;
                 end 
              end
              else begin
                  axi_master_cb.bready <= 1'b0;
              end
          end 
          else begin
              axi_master_cb.bready <= 1'b0;
          end

          done = m_dly ? 0 : 1;
          if (m_dly) m_dly--;
      end while (!done);  

  endtask : drive_ace_master_write_resp_channel_ready
      
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    
  //----------------------------------------------------------------------- 
  // Drive ace master write resp channel - wack
  //----------------------------------------------------------------------- 
  task automatic drive_ace_master_write_resp_channel_wack();

      @(axi_master_cb);
      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          wack_count = 0;
          return; 
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      if (bready & axi_master_cb.bvalid) begin
          wack_count++;
      end
  endtask : drive_ace_master_write_resp_channel_wack

  initial begin
      #0;
      if (IS_ACTIVE == 1 && IS_IF_A_SLAVE == 0) begin
          int m_dly;
          forever begin
              wait (wack_count > 0);
              m_dly = ($urandom_range(1,100) <= ACE_MASTER_WRITE_RESP_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_MASTER_WRITE_RESP_CHANNEL_DELAY_MIN, ACE_MASTER_WRITE_RESP_CHANNEL_DELAY_MAX));
              if (m_dly > 0) begin
                  axi_master_cb.wack <= 1'b0;
                  repeat(m_dly) @(axi_master_cb);
              end
              axi_master_cb.wack <= 1'b1;
              @(axi_master_cb);
              wack_count--;
              if (wack_count == 0) begin
                  axi_master_cb.wack <= 1'b0;
              end
          end
      end
  end


  //----------------------------------------------------------------------- 
  // Collect ace master write resp channel - wack
  //----------------------------------------------------------------------- 
  task automatic collect_ace_master_write_resp_channel_wack();
      bit done = 0;
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.wack) begin
              done = 1;
          end
      end while (!done);
 
  endtask : collect_ace_master_write_resp_channel_wack

<% } %>      
 
  //----------------------------------------------------------------------- 
  // Collect packet from ace master write resp channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_master_write_resp_channel(ref ace_write_resp_pkt_t pkt);
      bit done = 0;
      bit first_pass = 0;
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.bvalid && first_pass == 0) begin
              pkt.t_pkt_seen_on_intf = $time;
              first_pass = 1;
          end
          if (axi_monitor_cb.bvalid & bready) begin
              pkt.bid    = axi_monitor_cb.bid;
              pkt.bresp  = axi_bresp_enum_t'(axi_monitor_cb.bresp);
              pkt.buser  = axi_monitor_cb.buser;
              pkt.btrace = axi_monitor_cb.btrace;
              done      = 1;
          end
      end while (!done);
  endtask : collect_ace_master_write_resp_channel 
 
  //----------------------------------------------------------------------- 
  // Reset Ace master snoop addr channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_master_snoop_addr_channel();
      axi_master_cb.acready <= 1'b0;
      axi_master_cb.acready_chk <= 1'b0;
  endtask : async_reset_ace_master_snoop_addr_channel

  //----------------------------------------------------------------------- 
  // Drive ace master snoop addr channel 
  //----------------------------------------------------------------------- 
  task automatic drive_ace_master_snoop_addr_channel(bit ready=1);
      int m_dly;
      bit done;

      m_dly = ($urandom_range(1,100) <= ACE_MASTER_SNOOP_ADDR_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_MASTER_SNOOP_ADDR_CHANNEL_DELAY_MIN, ACE_MASTER_SNOOP_ADDR_CHANNEL_DELAY_MAX));
      if (ACE_MASTER_SNOOP_ADDR_CHANNEL_WAIT_FOR_VLD) begin
          m_dly = 1;
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      do begin
          @(axi_master_cb);
          if (ready && (ACE_MASTER_SNOOP_ADDR_CHANNEL_WAIT_FOR_VLD == 1 ? acvalid : 1)) begin
              if (m_dly == 0) begin
                 if (acvalid == 1 && bloc_axi_stall == 1 ) begin
                    axi_master_cb.acready    <= 1'b0; 
                    cnt_rdy_blckd_duration++;
                    if ( cnt_rdy_blckd_duration == RDY_NOT_ASSERTED_DURATION ) begin
                        cnt_rdy_blckd_duration = 0;
                        bloc_axi_stall         = 0;
                    end 
                 end 
                 else 
                 if (acvalid == 1 && en_ac_stall == 1 ) begin
                     axi_master_cb.acready <= 1'b0;
                     if(stall_ac_chnl_till_en_ac_stall_deassrt==1) begin
                         forever begin
                            if (en_ac_stall == 0) begin 
                                 break;
                            end                         
                            @(posedge clk) ; 
                         end
                     end else begin
                         for (int i = 0; i <= stall_ac_period; i++) begin
                            if (en_ac_stall == 0) begin 
                                 break;
                            end                         
                            @(posedge clk) ; 
                         end
                     end
                     axi_master_cb.acready <= 1'b1;
                     @(posedge clk) ;
                 end 
                 else begin
                  axi_master_cb.acready <= 1'b1;
                 end                     
              end
              else begin
                  axi_master_cb.acready <= 1'b0;
              end
          end 
          else begin
              axi_master_cb.acready <= 1'b0;
          end

          done = (m_dly > 0) ? 0 : 1;
          if (m_dly) m_dly--;
      end while (!done);  

  endtask : drive_ace_master_snoop_addr_channel

  //----------------------------------------------------------------------- 
  // Collect packet from ace master snoop addr channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_master_snoop_addr_channel(ref ace_snoop_addr_pkt_t pkt);
      bit done = 0;
      bit first_pass = 0;
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.acvalid && first_pass == 0) begin
              pkt.t_pkt_seen_on_intf = $time;
              first_pass = 1;
          end
          if (axi_monitor_cb.acvalid & acready) begin
              pkt.acaddr  = axi_monitor_cb.acaddr;
              pkt.acsnoop = axi_monitor_cb.acsnoop;
              pkt.acprot  = axi_monitor_cb.acprot;
              pkt.actrace = axi_monitor_cb.actrace;
              pkt.acvmid  = axi_monitor_cb.acvmidext;
              done        = 1;
          end
      end while (!done);
  endtask : collect_ace_master_snoop_addr_channel 
 
  //----------------------------------------------------------------------- 
  // Reset Ace master snoop resp channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_master_snoop_resp_channel();
      axi_master_cb.crvalid <= 1'b0;
      axi_master_cb.crvalid_chk <= 1'b0;

  <% if (obj.DutInfo.useResiliency) { %>
      axi_master_cb.crresp  <= 'b0;
      axi_master_cb.crtrace <= 'b0;
  <% } else { %>
//      axi_master_cb.crresp  <= 'bx;
//      axi_master_cb.crtrace <= 'bx;
      axi_master_cb.crresp  <= 'b0;
      axi_master_cb.crtrace <= 'b0;

  <% } %>
  endtask : async_reset_ace_master_snoop_resp_channel

  //----------------------------------------------------------------------- 
  // Drive ace master snoop resp channel
  //----------------------------------------------------------------------- 
  task automatic drive_ace_master_snoop_resp_channel(ace_snoop_resp_pkt_t pkt, bit valid = 1);

      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          m_drv_mst_snp_resp_q = {};
          if (first_reset_seen) begin
              return;
          end
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      if (valid) begin
          //$display("%t: Waiting for size < 4 size %0d", $time, m_drv_mst_snp_resp_q.size());
          wait (m_drv_mst_snp_resp_q.size() < 4);
          //$display("%t: Putting packet", $time);
          @(axi_master_cb);
          m_drv_mst_snp_resp_q.push_back(pkt);
          ->e_drv_mst_snp_resp_q;
      end
  endtask : drive_ace_master_snoop_resp_channel

  initial begin
      #0;
      if (IS_ACTIVE == 1 && IS_IF_A_SLAVE == 0) begin

          int  m_dly;
          bit  done;
          bit  was_crready_set_already;
          time t_start_time;
          ace_snoop_resp_pkt_t pkt;

          forever begin
              //$display("%t: Checking queue size", $time);
              if (m_drv_mst_snp_resp_q.size() > 0) begin
                  //$display("%t: Found packet to drive", $time);
                  pkt = new();
                  pkt.copy(m_drv_mst_snp_resp_q[0]);
                  m_dly = ($urandom_range(1,100) <= ACE_MASTER_SNOOP_RESP_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_MASTER_SNOOP_RESP_CHANNEL_DELAY_MIN, ACE_MASTER_SNOOP_RESP_CHANNEL_DELAY_MAX));
                  was_crready_set_already = 1;
                  t_start_time            = $time;
                  done                    = 0;
                  do begin
                      if (m_dly > 0) begin
                          drive_ace_master_snoop_resp_channel_nonvalid();
                          @(axi_master_cb);
                          if ((rst_n == 0) || (vif_rst_n ==0)) begin
                              m_drv_mst_snp_resp_q = {};
                              break;
                          end
                          m_dly--;
                      end
                      else begin
                          axi_master_cb.crvalid <= 1'b1;
                          axi_master_cb.crresp  <= pkt.crresp;
                          axi_master_cb.crtrace <= pkt.crtrace;
                          if (axi_master_cb.crready && (t_start_time !== $time)) begin
                              done = 1;
                          end
                          else begin
                              was_crready_set_already = 0;
                          end
                          if (!done || was_crready_set_already) begin
                              @(axi_master_cb);
                              if ((rst_n == 0) || (vif_rst_n ==0)) begin
                                  m_drv_mst_snp_resp_q = {};
                                  break;
                              end
                          end
                      end
                  end while (!done);
                  if(m_drv_mst_snp_resp_q.size() > 0) begin
                    m_drv_mst_snp_resp_q.delete(0);
                  end
                  ->e_drv_mst_crresp_collected;
              end
              else begin
                  drive_ace_master_snoop_resp_channel_nonvalid();
                  @(axi_master_cb);
                  if ((rst_n == 0) || (vif_rst_n ==0)) begin
                      m_drv_mst_snp_resp_q = {};
                  end
                  //$display("%t: Waiting for new packet", $time);
                  if (m_drv_mst_snp_resp_q.size == 0) begin
                      @e_drv_mst_snp_resp_q;
                  end
                  //$display("%t: Found new packet", $time);
              end
          end
      end
  end
  
  //----------------------------------------------------------------------- 
  // Drive ace master snoop resp channel nonvalid
  //----------------------------------------------------------------------- 
  task automatic drive_ace_master_snoop_resp_channel_nonvalid;
      axi_master_cb.crvalid <= 1'b0;
      axi_master_cb.crvalid_chk <= 1'b0;

  <% if (obj.DutInfo.useResiliency) { %>
      axi_master_cb.crresp  <= 'b0;
      axi_master_cb.crtrace <= 'b0;
  <% } else { %>
      axi_master_cb.crresp  <= 'bx;
      axi_master_cb.crtrace <= 'bx;
  <% } %>
  endtask : drive_ace_master_snoop_resp_channel_nonvalid 

  //----------------------------------------------------------------------- 
  // Collect packet from ace master snoop resp channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_master_snoop_resp_channel(ref ace_snoop_resp_pkt_t pkt);
      bit done = 0;
      bit first_pass = 0;
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (crvalid && first_pass == 0) begin
              pkt.t_pkt_seen_on_intf = $time;
              first_pass = 1;
          end
          if (crvalid & axi_monitor_cb.crready) begin
              pkt.crresp  = crresp;
              pkt.crtrace = crtrace;
              done       = 1;
          end
      end while (!done);
  endtask : collect_ace_master_snoop_resp_channel 
 
  //----------------------------------------------------------------------- 
  // Reset Ace master snoop data channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_master_snoop_data_channel();
      axi_master_cb.cdvalid   <= 1'b0;
      axi_master_cb.cdvalid_chk   <= 1'b0;
      axi_master_cb.cddata_chk <= 1'b0;
      axi_master_cb.cddata    <= 1'b0;
      axi_master_cb.cdlast    <= 1'b0;
      axi_master_cb.cdlast_chk    <= 1'b0;
      axi_master_cb.cdtrace   <= 1'b0;
      axi_master_cb.cddatachk <= 1'b0;
      axi_master_cb.cdpoison  <= 1'b0;
  endtask : async_reset_ace_master_snoop_data_channel

  //----------------------------------------------------------------------- 
  // Drive ace master snoop data channel
  //----------------------------------------------------------------------- 
  
  task automatic drive_ace_master_snoop_data_channel(ace_snoop_data_pkt_t pkt, bit valid = 1);
      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          m_drv_mst_snp_data_q = {};
          if (first_reset_seen) begin
              @(axi_slave_cb); //in case first_reset_seen  avoid eternal loop
              return;
          end
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      if (valid) begin
          wait (m_drv_mst_snp_data_q.size() < 16);
          @(axi_master_cb);
          for (int i = 0; i < ((SYS_nSysCacheline * 8)/WXDATA); i++) begin
              ace_snoop_data_pkt_t m_pkt;
              m_pkt              = new();
              m_pkt.cdlast       = ((i == ((SYS_nSysCacheline * 8)/WXDATA)-1) ? 1'b1 : 1'b0);
              m_pkt.cdtrace      = pkt.cdtrace;
              m_pkt.cddata       = new[1];
              m_pkt.cddata[0]    = pkt.cddata[i];
              m_pkt.cdpoison     = new[1];
              m_pkt.cdpoison[0]  = pkt.cdpoison[i];
              m_pkt.cddatachk    = new[1];
              m_pkt.cddatachk[0] = pkt.cddatachk[i];
              m_drv_mst_snp_data_q.push_back(m_pkt);
              ->e_drv_mst_snp_data_q;
          end 
      end
  endtask : drive_ace_master_snoop_data_channel

  initial begin
      #0;
      if (IS_ACTIVE == 1 && IS_IF_A_SLAVE == 0) begin

          int  m_dly;
          bit  done;
          bit  was_cdready_set_already;
          time t_start_time;
          ace_snoop_data_pkt_t pkt;

          forever begin
              //$display("%t: Checking queue size", $time);
              if (m_drv_mst_snp_data_q.size() > 0) begin
                  //$display("%t: Found packet to drive", $time);
                  pkt = new();
                  pkt = m_drv_mst_snp_data_q.pop_front();
                  m_dly = ($urandom_range(1,100) <= ACE_MASTER_SNOOP_DATA_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_MASTER_SNOOP_DATA_CHANNEL_DELAY_MIN, ACE_MASTER_SNOOP_DATA_CHANNEL_DELAY_MAX));
                  was_cdready_set_already = 1;
                  t_start_time            = $time;
                  done                    = 0;
                  do begin
                      if (m_dly > 0) begin
                          drive_ace_master_snoop_data_channel_nonvalid();
                          @(axi_master_cb);
                          if ((rst_n == 0) || (vif_rst_n ==0)) begin
                              m_drv_mst_snp_data_q = {};
                              break;
                          end
                          m_dly--;
                      end
                      else begin
                          axi_master_cb.cdvalid   <= 1'b1;
                          axi_master_cb.cdlast    <= pkt.cdlast; 
                          axi_master_cb.cddata    <= pkt.cddata[0];
                          axi_master_cb.cddatachk <= pkt.cddatachk[0];
                          axi_master_cb.cdpoison  <= pkt.cdpoison[0];
                          axi_master_cb.cdtrace   <= pkt.cdtrace;
                          if (axi_master_cb.cdready && (t_start_time !== $time)) begin
                              done = 1;
                          end
                          else begin
                              was_cdready_set_already = 0;
                          end
                          if (!done || was_cdready_set_already) begin
                              @(axi_master_cb);
                              if ((rst_n == 0) || (vif_rst_n ==0)) begin
                                  m_drv_mst_snp_data_q = {};
                                  break;
                              end
                          end
                      end
                  end while (!done);
              end
              else begin
                  drive_ace_master_snoop_data_channel_nonvalid();
                  @(axi_master_cb);
                  if ((rst_n == 0) || (vif_rst_n ==0)) begin
                      m_drv_mst_snp_data_q = {};
                  end
                  //$display("%t: Waiting for new packet", $time);
                  if (m_drv_mst_snp_data_q.size == 0) begin
                      @e_drv_mst_snp_data_q;
                  end
                  //$display("%t: Found new packet", $time);
              end
          end
      end
  end
      
  //----------------------------------------------------------------------- 
  // Drive ace master snoop data channel nonvalid
  //----------------------------------------------------------------------- 
  task automatic drive_ace_master_snoop_data_channel_nonvalid;
      axi_master_cb.cdvalid <= 1'b0;
      axi_master_cb.cdlast  <= 1'b0;
  <% if (obj.DutInfo.useResiliency) { %>
      axi_master_cb.cddata    <= 'b0;
      axi_master_cb.cddatachk <= 'b0;
      axi_master_cb.cdpoison  <= 'b0;
      axi_master_cb.cdtrace   <= 'b0;

  <% } else { %>
      axi_master_cb.cddata    <= 'bx;
      axi_master_cb.cddatachk <= 'bx;
      axi_master_cb.cdpoison  <= 'bx;
      axi_master_cb.cdtrace   <= 'bx;
  <% } %>

  endtask : drive_ace_master_snoop_data_channel_nonvalid 

  //----------------------------------------------------------------------- 
  // Collect packet from ace master snoop data channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_master_snoop_data_channel(ref ace_snoop_data_pkt_t pkt);
      automatic int               beat_cnt;
      automatic axi_cddata_t data[256];
      automatic axi_cddatachk_t datachk[256];
      automatic axi_cdpoison_t poison[256];
      automatic time              t_timestamp[256];
      automatic bit               done;
      automatic bit               first_pass = 0;

      beat_cnt = 0;
      done     = 0;
  
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (cdvalid && first_pass == 0) begin
              pkt.t_pkt_seen_on_intf = $time;
              first_pass = 1;
          end
          if (cdvalid & axi_monitor_cb.cdready) begin
              data[beat_cnt]    = cddata;
              datachk[beat_cnt] = cddatachk;
              poison[beat_cnt]  = cdpoison;
              pkt.cdtrace       = cdtrace;
              pkt.cdlast       = cdlast;

              t_timestamp[beat_cnt] = $time;
              if (cdlast) begin
                  pkt.cddata    = new[beat_cnt + 1] (data);
                  pkt.cddatachk = new[beat_cnt + 1] (datachk);
                  pkt.cdpoison  = new[beat_cnt + 1] (poison);
                  pkt.t_cdtime  = new[beat_cnt + 1] (t_timestamp);
                  done          = 1;
                  beat_cnt      = 0;
              end 
              else begin
                  beat_cnt++;
              end
          end
      end while (!done);
  endtask : collect_ace_master_snoop_data_channel 
 
  //----------------------------------------------------------------------- 
  // Drive ace slave snoop data channel 
  //----------------------------------------------------------------------- 
  task automatic drive_ace_master_sysco_channel(bit req=1);
      bit done;

      wait ((rst_n == 1) && (vif_rst_n == 1));
      @(axi_master_cb);
      axi_master_cb.syscoreq <= req;

  endtask : drive_ace_master_sysco_channel
  
  //----------------------------------------------------------------------- 
  // Force rst_n to reset interface only => force item_done() in the driver => to allow kill the sequence
  //----------------------------------------------------------------------- 
  task automatic force_vif_rst_n();
     @(negedge clk); 
     vif_rst_n = 1'b0;
    repeat (2) @(negedge clk);
  endtask : force_vif_rst_n
  
  task automatic release_vif_rst_n();
     #1 vif_rst_n = 1'b1;
  endtask : release_vif_rst_n
  //----------------------------------------------------------------------- 
  // Reset Ace slave read address channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_slave_read_addr_channel();
      axi_slave_cb.arready <= 1'b0;
  endtask : async_reset_ace_slave_read_addr_channel

  //----------------------------------------------------------------------- 
  // Drive ace slave read address channel 
  //----------------------------------------------------------------------- 
  task automatic drive_ace_slave_read_addr_channel(bit ready=1);
      int m_dly;
      bit done;

      m_dly = ($urandom_range(1,100) <= ACE_SLAVE_READ_ADDR_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_SLAVE_READ_ADDR_CHANNEL_DELAY_MIN, ACE_SLAVE_READ_ADDR_CHANNEL_DELAY_MAX));
      if (ACE_SLAVE_READ_ADDR_CHANNEL_WAIT_FOR_VLD) begin
          m_dly = 1;
      end
      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          axi_slave_cb.arready <= 1'b0;
          if (first_reset_seen) begin
              @(axi_slave_cb); //in case first_reset_seen  avoid eternal loop
              return;
          end
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      do begin
          @(axi_slave_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              axi_slave_cb.arready <= 1'b0;
              done = 1;
              break;
          end
          if (ready && (ACE_SLAVE_READ_ADDR_CHANNEL_WAIT_FOR_VLD == 1 ? arvalid : 1)) begin
              if (m_dly == 0) begin
                 if (arvalid == 1 && bloc_axi_stall == 1 ) begin
                    axi_slave_cb.arready <= 1'b0; 
                    cnt_rdy_blckd_duration++;
                    if ( cnt_rdy_blckd_duration == RDY_NOT_ASSERTED_DURATION ) begin
                        cnt_rdy_blckd_duration = 0;
                        bloc_axi_stall         = 0;
                    end 
                 end 
                 else                  
                 if (arvalid == 1 && en_ar_stall == 1 ) begin
                     axi_slave_cb.arready  <= 1'b0;
                     if(stall_ar_chnl_till_en_ar_stall_deassrt==1) begin
                         forever  begin
                            if (en_ar_stall == 0) begin 
                                 break;
                            end   
                            @(posedge clk) ; 
                         end
                     end else begin
                         for (int i = 0; i <= stall_ar_period; i++) begin
                            if (en_ar_stall == 0) begin 
                                 break;
                            end   
                            @(posedge clk) ; 
                         end
                     end
                     axi_slave_cb.arready  <= 1'b1;
                     @(posedge clk) ;
                 end 
                 else begin
                  axi_slave_cb.arready <= 1'b1;
                 end 
              end
              else begin
                  axi_slave_cb.arready <= 1'b0;
              end
          end 
          else begin
              axi_slave_cb.arready <= 1'b0;
          end

          done = m_dly ? 0 : 1;
          if (m_dly) m_dly--;
      end while (!done);  

  endtask : drive_ace_slave_read_addr_channel

  //----------------------------------------------------------------------- 
  // Collect packet from ace slave read address channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_slave_read_addr_channel(ref ace_read_addr_pkt_t pkt);
      bit done = 0;
      bit first_pass = 0;
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.arvalid && first_pass == 0) begin
              pkt.t_pkt_seen_on_intf = $time;
              first_pass = 1;
          end
          if (axi_monitor_cb.arvalid & arready) begin
              pkt.arid     = axi_monitor_cb.arid;
              pkt.araddr   = axi_monitor_cb.araddr;
              pkt.arlen    = axi_monitor_cb.arlen;
              pkt.arsize   = axi_monitor_cb.arsize;
              pkt.arburst  = axi_monitor_cb.arburst;
              pkt.arlock   = axi_axlock_enum_t'(axi_monitor_cb.arlock);
              pkt.arcache  = axi_arcache_enum_t'(axi_monitor_cb.arcache);
              pkt.arprot   = axi_monitor_cb.arprot;
              pkt.arqos    = axi_monitor_cb.arqos;
              pkt.arregion = axi_monitor_cb.arregion;
              pkt.aruser   = axi_monitor_cb.aruser;
              pkt.ardomain = axi_axdomain_enum_t'(axi_monitor_cb.ardomain);
              pkt.arsnoop  = axi_monitor_cb.arsnoop;
              pkt.arbar    = axi_monitor_cb.arbar;
              pkt.artrace  = axi_monitor_cb.artrace;
              pkt.arvmid   = axi_monitor_cb.arvmidext;
              done         = 1;
          end
      end while (!done);
  endtask : collect_ace_slave_read_addr_channel 
 
  //----------------------------------------------------------------------- 
  // Collect packet from ace slave read address channel - for driver
  //----------------------------------------------------------------------- 

  task automatic collect_ace_slave_read_addr_channel_for_driver(ref ace_read_addr_pkt_t pkt);
      bit done = 0;
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.arvalid & arready) begin
              pkt.arid     = axi_monitor_cb.arid;
              pkt.araddr   = axi_monitor_cb.araddr;
              pkt.arlen    = axi_monitor_cb.arlen;
              pkt.arsize   = axi_monitor_cb.arsize;
              pkt.arburst  = axi_monitor_cb.arburst;
              pkt.arlock   = axi_axlock_enum_t'(axi_monitor_cb.arlock);
              pkt.arcache  = axi_arcache_enum_t'(axi_monitor_cb.arcache);
              pkt.arprot   = axi_monitor_cb.arprot;
              pkt.arqos    = axi_monitor_cb.arqos;
              pkt.arregion = axi_monitor_cb.arregion;
              pkt.aruser   = axi_monitor_cb.aruser;
              pkt.ardomain = axi_axdomain_enum_t'(axi_monitor_cb.ardomain);
              pkt.arsnoop  = axi_monitor_cb.arsnoop;
              pkt.arbar    = axi_monitor_cb.arbar;
              pkt.artrace  = axi_monitor_cb.artrace;
              pkt.arvmid   = axi_monitor_cb.arvmidext;
              done         = 1;
          end
      end while (!done);
  endtask : collect_ace_slave_read_addr_channel_for_driver 
 
  //----------------------------------------------------------------------- 
  // Reset Ace slave write address channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_slave_write_addr_channel();
      axi_slave_cb.awready <= 1'b0;
  endtask : async_reset_ace_slave_write_addr_channel

  //----------------------------------------------------------------------- 
  // Drive ace slave write address channel 
  //----------------------------------------------------------------------- 
  task automatic drive_ace_slave_write_addr_channel(bit ready=1);
      int m_dly;
      bit done;

      m_dly = ($urandom_range(1,100) <= ACE_SLAVE_WRITE_ADDR_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_SLAVE_WRITE_ADDR_CHANNEL_DELAY_MIN, ACE_SLAVE_WRITE_ADDR_CHANNEL_DELAY_MAX));
      //if (ACE_SLAVE_WRITE_ADDR_CHANNEL_WAIT_FOR_VLD) begin
      //    m_dly = 1;
      //end
      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          axi_slave_cb.awready <= 1'b0;
          if (first_reset_seen) begin
              @(axi_slave_cb); //in case first_reset_seen  avoid eternal loop
              return;
          end
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              axi_slave_cb.awready <= 1'b0;
              done = 1;
              break;
          end
          if (ACE_SLAVE_WRITE_ADDR_CHANNEL_WAIT_FOR_VLD) begin
            while (awvalid === 0) begin
              @(axi_monitor_cb);
            end
          end 
          //if (ready && (ACE_SLAVE_WRITE_ADDR_CHANNEL_WAIT_FOR_VLD == 1 ? awvalid : 1)) begin
          if (ready) begin
              if (m_dly == 0) begin
                 if (awvalid == 1 && bloc_axi_stall == 1 ) begin
                    axi_slave_cb.awready  <= 1'b0; 
                    cnt_rdy_blckd_duration++;
                    if ( cnt_rdy_blckd_duration == RDY_NOT_ASSERTED_DURATION ) begin
                        cnt_rdy_blckd_duration = 0;
                        bloc_axi_stall         = 0;
                    end 
                 end 
                 else  
                 if (awvalid == 1 && en_aw_stall == 1 ) begin
                     axi_slave_cb.awready  <= 1'b0;
                     if(stall_aw_chnl_till_en_aw_stall_deassrt==1) begin
                         forever begin
                            if (en_aw_stall == 0) begin 
                                 break;
                            end  
                            @(posedge clk) ; 
                         end
                     end else begin
                         for (int i = 0; i <= stall_aw_period; i++) begin
                            if (en_aw_stall == 0) begin 
                                 break;
                            end  
                            @(posedge clk) ; 
                         end
                     end
                     axi_slave_cb.awready  <= 1'b1;
                     @(posedge clk) ;
                 end  
                 else begin
                  axi_slave_cb.awready  <= 1'b1;
                 end 
              end
              else begin
                  axi_slave_cb.awready <= 1'b0;
              end
          end 
          else begin
              axi_slave_cb.awready <= 1'b0;
          end

          done = m_dly ? 0 : 1;
          if (m_dly) m_dly--;
      end while (!done);  

  endtask : drive_ace_slave_write_addr_channel

  //----------------------------------------------------------------------- 
  // Collect packet from ace slave write address channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_slave_write_addr_channel(ref ace_write_addr_pkt_t pkt);
      bit done = 0;
      bit first_pass = 0;
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.awvalid && first_pass == 0) begin
              pkt.t_pkt_seen_on_intf = $time;
              first_pass = 1;
          end
          if (axi_monitor_cb.awvalid & awready) begin
              pkt.awid          = axi_monitor_cb.awid;
              pkt.awaddr        = axi_monitor_cb.awaddr;
              pkt.awlen         = axi_monitor_cb.awlen;
              pkt.awsize        = axi_monitor_cb.awsize;
              pkt.awburst       = axi_monitor_cb.awburst;
              pkt.awlock        = axi_axlock_enum_t'(axi_monitor_cb.awlock);
              pkt.awcache       = axi_awcache_enum_t'(axi_monitor_cb.awcache);
              pkt.awprot        = axi_monitor_cb.awprot;
              pkt.awqos         = axi_monitor_cb.awqos;
              pkt.awregion      = axi_monitor_cb.awregion;
              pkt.awuser        = axi_monitor_cb.awuser;
              pkt.awdomain      = axi_axdomain_enum_t'(axi_monitor_cb.awdomain);
              pkt.awsnoop       = axi_monitor_cb.awsnoop;
              pkt.awbar         = axi_monitor_cb.awbar;
              pkt.awatop        = axi_monitor_cb.awatop; 
              pkt.awstashnid    = axi_monitor_cb.awstashnid; 
              pkt.awstashlpid   = axi_monitor_cb.awstashlpid; 
              pkt.awstashniden  = axi_monitor_cb.awstashniden; 
              pkt.awstashlpiden = axi_monitor_cb.awstashlpiden;
              pkt.awtrace       = axi_monitor_cb.awtrace;
              done              = 1;
          end
      end while (!done);
  endtask : collect_ace_slave_write_addr_channel 
 
  //----------------------------------------------------------------------- 
  // Collect packet from ace slave write address channel - for driver
  //----------------------------------------------------------------------- 

  task automatic collect_ace_slave_write_addr_channel_for_driver(ref ace_write_addr_pkt_t pkt);
      bit done = 0;
      bit first_pass = 0;
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.awvalid && first_pass == 0) begin
              pkt.t_pkt_seen_on_intf = $time;
              first_pass = 1;
          end
          if (axi_monitor_cb.awvalid & awready) begin
              pkt.awid          = axi_monitor_cb.awid;
              pkt.awaddr        = axi_monitor_cb.awaddr;
              pkt.awlen         = axi_monitor_cb.awlen;
              pkt.awsize        = axi_monitor_cb.awsize;
              pkt.awburst       = axi_monitor_cb.awburst;
              pkt.awlock        = axi_axlock_enum_t'(axi_monitor_cb.awlock);
              pkt.awcache       = axi_awcache_enum_t'(axi_monitor_cb.awcache);
              pkt.awprot        = axi_monitor_cb.awprot;
              pkt.awqos         = axi_monitor_cb.awqos;
              pkt.awregion      = axi_monitor_cb.awregion;
              pkt.awuser        = axi_monitor_cb.awuser;
              pkt.awdomain      = axi_axdomain_enum_t'(axi_monitor_cb.awdomain);
              pkt.awsnoop       = axi_monitor_cb.awsnoop;
              pkt.awbar         = axi_monitor_cb.awbar;
              pkt.awatop        = axi_monitor_cb.awatop; 
              pkt.awstashnid    = axi_monitor_cb.awstashnid; 
              pkt.awstashlpid   = axi_monitor_cb.awstashlpid; 
              pkt.awstashniden  = axi_monitor_cb.awstashniden; 
              pkt.awstashlpiden = axi_monitor_cb.awstashlpiden;
              pkt.awtrace       = axi_monitor_cb.awtrace;
              done              = 1;
          end
      end while (!done);
  endtask : collect_ace_slave_write_addr_channel_for_driver 
  
  //----------------------------------------------------------------------- 
  // Reset Ace slave read data channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_slave_read_data_channel();
      axi_slave_cb.rvalid   <= 1'b0;
      axi_slave_cb.rid      <= 1'b0;
      axi_slave_cb.rdata    <= 1'b0;
      axi_slave_cb.rdatachk <= 1'b0;
      axi_slave_cb.rpoison  <= 1'b0;
      axi_slave_cb.rtrace   <= 1'b0;
      axi_slave_cb.rresp    <= 1'b0;
      axi_slave_cb.rlast    <= 1'b0;
      axi_slave_cb.ruser    <= 1'b0;
  endtask : async_reset_ace_slave_read_data_channel

  //----------------------------------------------------------------------- 
  // Drive ace slave read data channel
  //----------------------------------------------------------------------- 
  
  task automatic drive_ace_slave_read_data_channel(ace_read_data_pkt_t pkt, axi_axlen_logic_t len, bit valid = 1);
      bit done;

      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          m_drv_slv_rd_data_q = {};
          if (first_reset_seen) begin
              @(axi_slave_cb); //in case first_reset_seen  avoid eternal loop
              return;
          end
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      if (valid) begin
          for (int i = 0; i <= len; i++) begin
              ace_read_data_pkt_cell_t m_cell;
              m_cell          = new();
              m_cell.rdata    = pkt.rdata[i];
              m_cell.rresp    = pkt.rresp_per_beat[i];
              m_cell.rdatachk = pkt.rdatachk[i];
              m_cell.rpoison  = pkt.rpoison[i];
              m_cell.rtrace   = pkt.rtrace;
              m_cell.ruser    = pkt.ruser;
              m_cell.rid      = pkt.rid;
              m_cell.rlast    = (i == len) ? 1 : 0;
              m_cell.rctr     = i;
              m_cell.rtime    = $time;
              //m_cell.rtime_counter = 54;
              m_cell.rtime_counter = (iocache_perf_test)? 0 : ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MAX ;
              //randcase
              //    50: m_cell.rtime_counter = 8;
              //    50:  m_cell.rtime_counter = 100;
              //endcase
              m_drv_slv_rd_data_q.push_back(m_cell);
              ->e_drv_slv_rd_collected;
          end 
      end
  endtask : drive_ace_slave_read_data_channel
         
  initial begin
      #0;
      if (iocache_perf_test) begin
          ACE_SLAVE_READ_DATA_INTERLEAVE_DIS = 1; 
      end
      forever begin
          @(axi_slave_cb);
          foreach (m_drv_slv_rd_data_q[i]) begin
              m_drv_slv_rd_data_q[i].rtime_counter--;
          end
      end
  end
//force read data ready and bready for perf monitor test
logic force_rready = 1'bz;
logic force_rvalid = 1'bz;
logic force_bready = 1'bz;
logic force_bvalid = 1'bz;
logic force_crready = 1'bz;
logic force_crvalid = 1'bz;

initial begin
    int cr_stall_duration;
    cr_stall_duration = $urandom_range(9,99);
    if ( IS_IF_A_SLAVE == 1) begin
        forever begin
          @(posedge clk) ; 
         force_crready = 1'bz;
         force_crvalid = 1'bz;
         if (en_cr_stall == 1 ) begin
                @(posedge clk) ; 
                force_crready = 1'bz;
                force_crvalid = 1'bz;
                repeat(20) @(posedge clk) ;
                force_crready = 1'b0;
                force_crvalid = 1'b1;              
                repeat(cr_stall_duration) @(posedge clk) ;
                force_crready = 1'b0;
                force_crvalid = 1'b1;
                @(posedge clk) ;
                force_crready = 1'bz;
                force_crvalid = 1'bz;
                @(posedge clk) ; 
                break;
         end
        end
    end

end

initial begin
    if ( IS_IF_A_SLAVE == 1) begin
        forever begin
          @(posedge clk) ; 
         force_rready = 1'bz;
         force_rvalid = 1'bz;
         if (en_r_stall == 1 ) begin
                @(posedge clk) ; 
                force_rready = 1'bz;
                force_rvalid = 1'bz;
                repeat(20) @(posedge clk) ;
                force_rready = 1'b0;
                force_rvalid = 1'b1;              
                repeat(3) @(posedge clk) ;
                force_rready = 1'b0;
                force_rvalid = 1'b1;
                @(posedge clk) ;
                force_rready = 1'bz;
                force_rvalid = 1'bz;
                @(posedge clk) ; 
                break;
         end
        end
    end

end

initial begin
    if ( IS_IF_A_SLAVE == 1) begin
        forever begin
          @(posedge clk) ; 
         force_bready = 1'bz;
         force_bvalid = 1'bz;
         if (en_b_stall == 1 ) begin
                @(posedge clk) ; 
                force_bready = 1'bz;
                force_bvalid = 1'bz;
                repeat(20) @(posedge clk) ;
                force_bready = 1'b0;
                force_bvalid = 1'b1;
                repeat(3) @(posedge clk) ;
                force_bready = 1'b0;
                force_bvalid = 1'b1;
                @(posedge clk) ;
                force_bready = 1'bz;
                force_bvalid = 1'bz;
                @(posedge clk) ; 
                break;
         end 
        end
    end

end



  initial begin
      #0;
      if (IS_ACTIVE == 1 && IS_IF_A_SLAVE == 1) begin
          automatic int count = 0;
          forever begin
              @(axi_slave_cb);
              if (m_drv_slv_rd_data_q.size() > 0) begin
                  count++;
              end
              if (m_drv_slv_rd_data_q.size() >= ACE_SLAVE_READ_DATA_REORDER_SIZE || 
                  (!ACE_SLAVE_READ_DATA_CHANNEL_STRICT_DLY &&
                    m_drv_slv_rd_data_q.size() > 0 && 
                    count > 100
                  ) ||
                  (ACE_SLAVE_READ_DATA_CHANNEL_STRICT_DLY &&
                    m_drv_slv_rd_data_q.size() > 0 && 
                    count > 5000
                  )
              ) begin
                  automatic int                         m_dly = 0;
                  bit                                   was_rready_set_already;
                  axi_arid_t m_arid_being_driven;
                  automatic bit                         m_send_same_arid = 0;
                  automatic bit                         last_beat = 1;
                  count = 0;
                  if (!iocache_perf_test) begin
                      m_dly = ($urandom_range(1,100) <= ACE_SLAVE_READ_DATA_CHANNEL_BURST_PCT || ACE_SLAVE_RANDOM_DLY_DIS) ? 0 : ($urandom_range(ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MIN, ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MAX));
                  end
                  do begin
                      ace_read_data_pkt_cell_t m_cell;
                      int                      m_tmp_q[$];
                      int                      m_tmp_index;
                      int                      m_tmp_ctr;
                      time                     m_tmp_time;
                      bit                      done;
                      time                     t_start_time;
                      //#Check.DMI.Concerto.v3.0.RdDataIntrLv
                      if ((ACE_SLAVE_READ_DATA_INTERLEAVE_DIS==0) && (m_send_same_arid==0)) begin
                          m_drv_slv_rd_data_q.shuffle();
                      end
                      m_cell = m_drv_slv_rd_data_q[0];
                      if(ACE_SLAVE_READ_DATA_DLY_AFTER_RLAST > 0)begin
                        if (m_cell.rlast == 1) begin 
                          m_dly = ACE_SLAVE_READ_DATA_DLY_AFTER_RLAST;
                        end else begin
                          m_dly =$urandom_range(1,10000)<= 1 ? 1 : 0;
                        end
                      end
                      //bit done_here = 0;
                      //int m_tmp_here_q[$];
                      //do begin
                      //    m_tmp_here_q = {};
                      //    m_tmp_here_q = m_drv_slv_rd_data_q.find_first_index with (item.rtime_counter <= 0);
                      //    if (m_tmp_here_q.size() == 0) begin
                      //        drive_ace_slave_read_data_channel_nonvalid();
                      //        @(axi_slave_cb);
                      //    end
                      //    else begin
                      //        m_cell = m_drv_slv_rd_data_q[m_tmp_here_q[0]];
                      //        done_here = 1;
                      //    end
                      //end while (!done_here);

                      if (m_drv_slv_rd_data_q.size() > 0) begin
                         // Selecting the youngest beat for the first entry
                         m_tmp_q     = {};
                         m_tmp_q     = m_drv_slv_rd_data_q.find_index with (item.rid == m_cell.rid);
                         m_tmp_time  = m_cell.rtime;
                         if (m_tmp_q.size() == 0) begin
                            $error("%m: %t: TB ERROR: Could not find arid 0x%0x", $time, m_cell.rid);
                         end
                         m_tmp_index = m_tmp_q[0];
                         // Finding the oldest request to this axid
                         foreach (m_tmp_q[i]) begin
                            if (m_drv_slv_rd_data_q[m_tmp_q[i]].rtime < m_tmp_time) begin
                               m_tmp_time = m_drv_slv_rd_data_q[m_tmp_q[i]].rtime;
                               m_tmp_index = m_tmp_q[i];
                            end
                         end
                         m_tmp_q = {};
                         m_tmp_q = m_drv_slv_rd_data_q.find_index with (item.rid == m_cell.rid && item.rtime == m_tmp_time);
                         if (m_tmp_q.size() == 0) begin
                            $error("%m: %t: TB ERROR: Could not find arid 0x%0x with time %t", $time, m_cell.rid, m_tmp_time);
                         end
                         m_cell      = m_drv_slv_rd_data_q[m_tmp_q[0]];
                         m_tmp_index = m_tmp_q[0];
                         m_tmp_ctr   = m_cell.rctr;
                         // Finding the smallest beat that is not sent
                         foreach (m_tmp_q[i]) begin
                            if (m_drv_slv_rd_data_q[m_tmp_q[i]].rctr < m_tmp_ctr) begin
                               m_tmp_ctr = m_drv_slv_rd_data_q[m_tmp_q[i]].rctr;
                               m_tmp_index = m_tmp_q[i];
                            end
                         end
                         m_cell = m_drv_slv_rd_data_q[m_tmp_index];
                         m_drv_slv_rd_data_q.delete(m_tmp_index);

                         //Code modified for Read_data_interleaving.
                         if (ACE_SLAVE_READ_DATA_INTERLEAVE_DIS==1)  
                            m_send_same_arid = 1;
                         else m_send_same_arid = $urandom_range(0,1);

                         m_arid_being_driven    = m_cell.rid;
                         done                   = 0;
                         was_rready_set_already = 1;
                         t_start_time           = $time;
                         if (iocache_perf_test || ACE_SLAVE_RANDOM_DLY_DIS) begin
                            m_dly = m_cell.rtime_counter;
                         end
                         do begin
                            if ((rst_n == 0) || (vif_rst_n ==0)) begin
                               drive_ace_slave_read_data_channel_nonvalid();
                               done = 1;
                               break;
                            end
                            if (m_dly > 0 && last_beat) begin
                               drive_ace_slave_read_data_channel_nonvalid();
                               @(axi_slave_cb);
                               if(axi_monitor_cb.rready) begin
                                 m_dly--;
                               end
                            end
                            else begin
                                if(enable_r_stall)begin 
                                    wait(enable_r_stall == 0);
                                end
                               axi_slave_cb.rvalid   <= 1'b1;
                               axi_slave_cb.rlast    <= m_cell.rlast;
                               axi_slave_cb.ruser    <= m_cell.ruser;
                               axi_slave_cb.rid      <= m_cell.rid;
                               axi_slave_cb.rresp    <= m_cell.rresp;
                               axi_slave_cb.rdata    <= m_cell.rdata;
                               axi_slave_cb.rdatachk <= m_cell.rdatachk;
                               axi_slave_cb.rpoison  <= m_cell.rpoison;
                               axi_slave_cb.rtrace   <= m_cell.rtrace;
                               if (ACE_SLAVE_READ_DATA_INTERBEATDLY_DIS)begin
                                last_beat              = 0;
                               end
                               if (axi_monitor_cb.rready && (t_start_time !== $time)) begin
                                  if (!iocache_perf_test && !ACE_SLAVE_RANDOM_DLY_DIS ) begin
                                     m_dly       = ($urandom_range(1,100) <= ACE_SLAVE_READ_DATA_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MIN, ACE_SLAVE_READ_DATA_CHANNEL_DELAY_MAX));
                                  end
                                  done        = 1;
                               end
                               else begin 
                                  was_rready_set_already = 0;
                               end
                               if (!done || was_rready_set_already) begin
                                  @(axi_slave_cb);
                               end
                               if (m_cell.rlast == 1 && axi_monitor_cb.rready) begin
                                  m_send_same_arid = 0;
                                  last_beat        = 1;
                               end
                            end
                         end while (!done);
                      end // if (m_drv_slv_rd_data_q.size() > 0)
                  end while (m_drv_slv_rd_data_q.size() > 0);
                  if (m_drv_slv_rd_data_q.size() == 0) begin
                      drive_ace_slave_read_data_channel_nonvalid();
                      @e_drv_slv_rd_collected;
                  end
              end
          end
      end
  end
  //----------------------------------------------------------------------- 
  // Drive ace slave read data channel nonvalid
  //----------------------------------------------------------------------- 
  task automatic drive_ace_slave_read_data_channel_nonvalid;
      axi_slave_cb.rvalid <= 1'b0;
      axi_slave_cb.rlast  <= 1'b0;
  <% if (obj.DutInfo.useResiliency) { %>
      axi_slave_cb.rid      <= 'b0;
      axi_slave_cb.rresp    <= 'b0;
      axi_slave_cb.rdata    <= 'b0;
      axi_slave_cb.rdatachk <= 'b0;
      axi_slave_cb.rpoison  <= 'b0;
      axi_slave_cb.rtrace   <= 'b0;
      axi_slave_cb.ruser    <= 'b0;
  <% } else { %>
      axi_slave_cb.rid      <= 'bx;
      axi_slave_cb.rresp    <= 'bx;
      axi_slave_cb.rdata    <= 'bx;
      axi_slave_cb.rdatachk <= 'bx;
      axi_slave_cb.rpoison  <= 'bx;
      axi_slave_cb.rtrace   <= 'bx;
      axi_slave_cb.ruser    <= 'bx;
  <% } %>
  endtask : drive_ace_slave_read_data_channel_nonvalid 

  //----------------------------------------------------------------------- 
  // Collect packet from ace slave read data channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_slave_read_data_channel(ref ace_read_data_pkt_t pkt);
      automatic bit done;

      @e_mon_slv_rd_collected;
      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          m_mon_slv_rd_data_q = {};
          return;
      end
      if (m_mon_slv_rd_data_q.size > 0) begin
          pkt = m_mon_slv_rd_data_q.pop_front();
      end
  endtask : collect_ace_slave_read_data_channel

  task automatic collect_ace_slave_read_data_channel_main();
      int                                         tmp_var[$];
      axi_arid_logic_t q_ids_being_collected[$];
      wait ((rst_n == 1) && (vif_rst_n == 1));
      forever begin
          `ifdef QUESTA
              #0;
          `endif
<% if(obj.testBench == 'dii' || obj.testBench == 'fsys') { %>
`ifdef VCS
              #0;
`endif // `ifdef VCS 
<% } %>
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              q_ids_being_collected = {};
              continue;
          end
          if (rvalid & axi_monitor_cb.rready) begin
              tmp_var = {};
              tmp_var = q_ids_being_collected.find_index with (item == rid);
              if (tmp_var.size() == 0) begin
                  fork 
                      begin
                          int tmp_var2[$];
                          q_ids_being_collected.push_back(rid);
                          collect_ace_slave_read_data_channel_each(rid);
<% if(obj.testBench == 'dii' || obj.testBench == 'fsys') { %>
`ifdef VCS
                            #0.001ns;
`endif // `ifdef VCS 
<% } %>
                          tmp_var2 = {};
                          tmp_var2 = q_ids_being_collected.find_first_index with (item == rid); 
                          q_ids_being_collected.delete(tmp_var2[0]);
                      end
                  join_none
              end
          end
      end
  endtask : collect_ace_slave_read_data_channel_main

  task automatic collect_ace_slave_read_data_channel_each(axi_arid_logic_t m_rid);
      automatic int              beat_cnt;
      automatic axi_xdata_t data[256];
      automatic axi_rdatachk_t datachk[256];
      automatic axi_rpoison_t poison[256];
      automatic axi_rresp_t resp[256];
      automatic time             t_timestamp[256];
      automatic bit              done;
      ace_read_data_pkt_t        pkt;
      int                        tmp_var[$];
      bit                        first_pass = 0;
  
      beat_cnt = 0;
      done     = 0;
      pkt      = new();
  
      do begin
          if (rvalid && first_pass == 0) begin
              pkt.t_pkt_seen_on_intf = $time;
              first_pass = 1;
          end
          if ((rvalid == 1) && 
              (axi_monitor_cb.rready == 1) && 
              (m_rid == rid)
          ) begin
              pkt.rid               = rid;
              data[beat_cnt]        = rdata;
              resp[beat_cnt]        = rresp;
              datachk[beat_cnt]     = rdatachk;
              poison[beat_cnt]      = rpoison;
              pkt.rtrace            = rtrace;
              pkt.rresp             = rresp;
              pkt.ruser             = ruser;
              t_timestamp[beat_cnt] = $time;
              if (rlast) begin
                  pkt.rdata          = new[beat_cnt + 1] (data);
                  pkt.rdatachk       = new[beat_cnt + 1] (datachk);
                  pkt.rpoison        = new[beat_cnt + 1] (poison);
                  pkt.rresp_per_beat = new[beat_cnt + 1] (resp);
                  pkt.t_rtime        = new[beat_cnt + 1] (t_timestamp);
                  done               = 1;
                  beat_cnt           = 0;
                  m_mon_slv_rd_data_q.push_back(pkt);
                  ->e_mon_slv_rd_collected;
              end 
              else begin
                  beat_cnt++;
              end
          end
          if (!done) begin
              @(axi_monitor_cb);
              if ((rst_n == 0) || (vif_rst_n ==0)) begin
                  return;
              end
          end
      end while (!done);
  endtask : collect_ace_slave_read_data_channel_each 
 
  //----------------------------------------------------------------------- 
  // Reset Ace slave write data channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_slave_write_data_channel();
      axi_slave_cb.wready <= 1'b0;
  endtask : async_reset_ace_slave_write_data_channel
  
  //----------------------------------------------------------------------- 
  // Drive ace slave write data channel
  //----------------------------------------------------------------------- 
  task automatic drive_ace_slave_write_data_channel(bit ready=1);
      int m_dly;
      bit done;

      m_dly = ($urandom_range(1,100) <= ACE_SLAVE_WRITE_DATA_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_SLAVE_WRITE_DATA_CHANNEL_DELAY_MIN, ACE_SLAVE_WRITE_DATA_CHANNEL_DELAY_MAX));
      //if (ACE_SLAVE_WRITE_DATA_CHANNEL_WAIT_FOR_VLD) begin
      //    m_dly = 1;
      //end
      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          axi_slave_cb.wready <= 1'b0;
          if (first_reset_seen) begin
              @(axi_slave_cb); //in case first_reset_seen  avoid eternal loop
              return;
          end
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      do begin
          @(axi_slave_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              axi_slave_cb.wready <= 1'b0;
              done = 1;
              break;
          end
          if (ACE_SLAVE_WRITE_DATA_CHANNEL_WAIT_FOR_VLD) begin
            while (wvalid === 0) begin
              @(axi_monitor_cb);
              axi_slave_cb.wready <= 1'b0;
            end
          end 
          //if (ready && (ACE_SLAVE_WRITE_DATA_CHANNEL_WAIT_FOR_VLD == 1 ? wvalid : 1)) begin
          if (ready) begin
              if (m_dly == 0) begin
                 if (wvalid == 1 && bloc_axi_stall == 1 ) begin
                    axi_slave_cb.wready   <= 1'b0; 
                    cnt_rdy_blckd_duration++;
                    if ( cnt_rdy_blckd_duration == RDY_NOT_ASSERTED_DURATION ) begin
                        cnt_rdy_blckd_duration = 0;
                        bloc_axi_stall         = 0;
                    end 
                 end 
                 else 
                 if (wvalid == 1 && en_w_stall == 1 ) begin
                     axi_slave_cb.wready<= 1'b0;
                     if(stall_w_chnl_till_en_w_stall_deassrt) begin
                         forever begin
                            if (en_w_stall == 0) begin 
                                 break;
                            end                          
                            @(posedge clk) ; 
                         end
                     end else begin
                         for (int i = 0; i <= stall_w_period; i++) begin
                            if (en_w_stall == 0) begin 
                                 break;
                            end                          
                            @(posedge clk) ; 
                         end
                     end
                     axi_slave_cb.wready <= 1'b1;
                     @(posedge clk) ; 
                 end 
                 else begin
                  axi_slave_cb.wready <= 1'b1;
                 end                      
              end
              else begin
                  axi_slave_cb.wready <= 1'b0;
              end
          end 
          else begin
              axi_slave_cb.wready <= 1'b0;
          end

          done = m_dly ? 0 : 1;
          if (m_dly) m_dly--;
      end while (!done);  

  endtask : drive_ace_slave_write_data_channel
 
  //----------------------------------------------------------------------- 
  // Collect packet from ace slave write data channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_slave_write_data_channel(ref ace_write_data_pkt_t pkt);
      automatic int              beat_cnt;
      automatic axi_xdata_t data[256];
      automatic axi_xstrb_t wstrb[256];
      automatic axi_wpoison_t wpoison[256];
      automatic axi_wdatachk_t wdatachk[256];
      automatic time             t_timestamp[256];
      automatic bit              done;
      automatic bit              first_pass = 0;
  
      beat_cnt = 0;
      done     = 0;
  
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.wvalid && first_pass == 0) begin
              pkt.t_pkt_seen_on_intf = $time;
              first_pass = 1;
          end
          if (axi_monitor_cb.wvalid & wready) begin
              //pkt.wid               = axi_monitor_cb.wid;
              data[beat_cnt]        = axi_monitor_cb.wdata;
              wstrb[beat_cnt]       = axi_monitor_cb.wstrb;
              wpoison[beat_cnt]     = axi_monitor_cb.wpoison;
              wdatachk[beat_cnt]    = axi_monitor_cb.wdatachk;
              pkt.wuser             = axi_monitor_cb.wuser;
              pkt.wtrace            = axi_monitor_cb.wtrace;
              t_timestamp[beat_cnt] = $time;
              if (axi_monitor_cb.wlast) begin
                  pkt.wdata    = new[beat_cnt + 1] (data);
                  pkt.wstrb    = new[beat_cnt + 1] (wstrb);
                  pkt.wpoison  = new[beat_cnt + 1] (wpoison);
                  pkt.wdatachk = new[beat_cnt + 1] (wdatachk);
                  pkt.t_wtime  = new[beat_cnt + 1] (t_timestamp);
                  done         = 1;
                  beat_cnt     = 0;
              end 
              else begin
                  beat_cnt++;
              end
          end
      end while (!done);
  endtask : collect_ace_slave_write_data_channel 
 
  //----------------------------------------------------------------------- 
  // Collect packet from ace slave write data channel - for driver
  //----------------------------------------------------------------------- 

  task automatic collect_ace_slave_write_data_channel_for_driver(ref ace_write_data_pkt_t pkt);
      automatic int              beat_cnt;
      automatic axi_xdata_t data[256];
      automatic axi_xstrb_t wstrb[256];
      automatic axi_wpoison_t wpoison[256];
      automatic axi_wdatachk_t wdatachk[256];
      automatic time             t_timestamp[256];
      automatic bit              done;
      automatic bit              first_pass = 0;
  
      beat_cnt = 0;
      done     = 0;
  
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.wvalid && first_pass == 0) begin
              pkt.t_pkt_seen_on_intf = $time;
              first_pass = 1;
          end
          if (axi_monitor_cb.wvalid & wready) begin
              //pkt.wid               = axi_monitor_cb.wid;
              data[beat_cnt]        = axi_monitor_cb.wdata;
              wstrb[beat_cnt]       = axi_monitor_cb.wstrb;
              wpoison[beat_cnt]     = axi_monitor_cb.wpoison;
              wdatachk[beat_cnt]    = axi_monitor_cb.wdatachk;
              pkt.wuser             = axi_monitor_cb.wuser;
              pkt.wtrace            = axi_monitor_cb.wtrace;
              t_timestamp[beat_cnt] = $time;
              if (axi_monitor_cb.wlast) begin
                  pkt.wdata    = new[beat_cnt + 1] (data);
                  pkt.wstrb    = new[beat_cnt + 1] (wstrb);
                  pkt.wpoison  = new[beat_cnt + 1] (wpoison);
                  pkt.wdatachk = new[beat_cnt + 1] (wdatachk);
                  pkt.t_wtime  = new[beat_cnt + 1] (t_timestamp);
                  done         = 1;
                  beat_cnt     = 0;
              end 
              else begin
                  beat_cnt++;
              end
          end
      end while (!done);
  endtask : collect_ace_slave_write_data_channel_for_driver 
   
  //----------------------------------------------------------------------- 
  // Reset Ace slave write resp channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_slave_write_resp_channel();
      axi_slave_cb.bvalid <= 1'b0;
      axi_slave_cb.bid    <= 1'b0;
      axi_slave_cb.bresp  <= 1'b0;
      axi_slave_cb.buser  <= 1'b0;
      axi_slave_cb.btrace <= 1'b0;
  endtask : async_reset_ace_slave_write_resp_channel

  //----------------------------------------------------------------------- 
  // Drive ace slave write resp channel
  //----------------------------------------------------------------------- 
  
  task automatic drive_ace_slave_write_resp_channel(ace_write_resp_pkt_t pkt, bit valid = 1);
      if ((rst_n == 0) || (vif_rst_n ==0)) begin
          m_drv_slv_wr_resp_q = {};
          if (first_reset_seen) begin
   <% if(obj.testBench =="fsys") { %>
              @(axi_slave_cb); //in case first_reset_seen  avoid eternal loop
<%}%>
              return;
          end
      end
      wait ((rst_n == 1) && (vif_rst_n == 1));
      if (valid) begin
          //$display("%t: Waiting for size < 2 size %0d", $time, m_drv_slv_wr_resp_q.size());
		  if (!ACE_SLAVE_RANDOM_DLY_DIS) begin //newperf_test CLU keep legacy 
          wait (m_drv_slv_wr_resp_q.size() < 2);
          //$display("%t: Putting packet", $time);
          @(axi_slave_cb);
          end
	      pkt.rtime_counter = ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MAX;
          m_drv_slv_wr_resp_q.push_back(pkt);
          ->e_drv_slv_wr_resp_q;
      end
  endtask : drive_ace_slave_write_resp_channel
 
  initial begin
      #0;
      forever begin
          @(axi_slave_cb);
          foreach (m_drv_slv_wr_resp_q[i]) begin
             if (m_drv_slv_wr_resp_q[i].rtime_counter >0) m_drv_slv_wr_resp_q[i].rtime_counter--;
          end
      end
  end

  initial begin
      #0;
      if (IS_ACTIVE == 1 && IS_IF_A_SLAVE == 1) begin

          int  m_dly;
          bit  done;
          bit  was_bready_set_already;
          time t_start_time;
          ace_write_resp_pkt_t pkt,pktNxt;

          forever begin
              //$display("%t: Checking queue size", $time);
              if (m_drv_slv_wr_resp_q.size() > 0) begin
                  //$display("%t: Found packet to drive", $time);
                  pkt = new();
                  
                  if(m_drv_slv_wr_resp_q.size() == 2)begin
                    if(m_drv_slv_wr_resp_q[0].bid != m_drv_slv_wr_resp_q[1].bid)begin
                      m_drv_slv_wr_resp_q.shuffle();
                    end
                  end
                
                  pkt = m_drv_slv_wr_resp_q.pop_front();

                  

                  m_dly = ($urandom_range(1,100) <= ACE_SLAVE_WRITE_RESP_CHANNEL_BURST_PCT ) ? 0 : ($urandom_range(ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MIN, ACE_SLAVE_WRITE_RESP_CHANNEL_DELAY_MAX));
				  // newperf_test fix write_bresp delay
				  m_dly= (ACE_SLAVE_RANDOM_DLY_DIS)? pkt.rtime_counter : m_dly;
                  was_bready_set_already = 1;
                  t_start_time            = $time;
                  done                    = 0;
                  do begin
                      if (m_dly > 0) begin
                          drive_ace_slave_write_resp_channel_nonvalid();
                          @(axi_slave_cb);
                          if ((rst_n == 0) || (vif_rst_n ==0)) begin
                              m_drv_slv_wr_resp_q = {};
                              break;
                          end
                          m_dly--;
                      end
                      else begin
                          if(enable_b_stall)begin
                            wait(enable_b_stall == 0);
                          end
                          axi_slave_cb.bvalid <= 1'b1;
                          axi_slave_cb.buser  <= pkt.buser;
                          axi_slave_cb.bid    <= pkt.bid;
                          axi_slave_cb.bresp  <= pkt.bresp;
                          axi_slave_cb.btrace <= pkt.btrace;
                          if (axi_slave_cb.bready && (t_start_time !== $time)) begin
                              done = 1;
                          end
                          else begin
                              was_bready_set_already = 0;
                          end
                          if (!done || was_bready_set_already) begin
                              @(axi_slave_cb);
                              if ((rst_n == 0) || (vif_rst_n ==0)) begin
                                  m_drv_slv_wr_resp_q = {};
                                  break;
                              end
                          end
                      end
                  end while (!done);
              end
              else begin
                  drive_ace_slave_write_resp_channel_nonvalid();
                  @(axi_slave_cb);
                  if ((rst_n == 0) || (vif_rst_n ==0)) begin
                      m_drv_slv_wr_resp_q = {};
                  end
                  //$display("%t: Waiting for new packet", $time);
                  if (m_drv_slv_wr_resp_q.size == 0) begin
                      @e_drv_slv_wr_resp_q;
                  end
                  //$display("%t: Found new packet", $time);
              end
          end
      end
  end



  <% if((obj.Block === "dmi") && !(obj.DutInfo.cmpInfo.useMemRspIntrlv)) { %>


  always @(posedge clk or negedge rst_n)
  if (!rst_n) begin
     rsp_data_cycle_ff <= DONT_EXPECT_RID_CONSTANT;
     rsp_bus_cycle_rid <= '0;
  end else begin
       if (rvalid & rlast) begin
           rsp_data_cycle_ff <= DONT_EXPECT_RID_CONSTANT;
           rsp_bus_cycle_rid <= '0;
       end
       else if (rvalid & ~rlast) begin
           rsp_data_cycle_ff <= EXPECT_RID_CONSTANT;
           rsp_bus_cycle_rid <= rid;
       end
  end

  <%=obj.BlockId%>_rdata_interleaving_support_not_enabled:
  assert property (@(posedge clk) disable iff (~rst_n) ((rsp_data_cycle_ff == EXPECT_RID_CONSTANT) && (rvalid===1)) |-> (rid == rsp_bus_cycle_rid)) else begin
  `uvm_error("AXI <%=obj.BlockId%> Assertion Checker", $sformatf("rdata interleaving occurring on response data interface for (ID:0x%0x) and (ID:0x%0x), though generated rtl does not support interleaving on this interface", rid, rsp_bus_cycle_rid)); 
  end

<% } %>
      
  //----------------------------------------------------------------------- 
  // Drive ace slave write resp channel nonvalid
  //----------------------------------------------------------------------- 
  task automatic drive_ace_slave_write_resp_channel_nonvalid;
      axi_slave_cb.bvalid <= 1'b0;
  <% if (obj.DutInfo.useResiliency) { %>
      axi_slave_cb.buser  <= 'b0;
      axi_slave_cb.bid    <= 'b0;
      axi_slave_cb.bresp  <= 'b0;
      axi_slave_cb.btrace <= 'b0;
  <% } else { %>
      axi_slave_cb.buser  <= 'bx;
      axi_slave_cb.bid    <= 'bx;
      axi_slave_cb.bresp  <= 'bx;
      axi_slave_cb.btrace <= 'bx;
  <% } %>
  endtask : drive_ace_slave_write_resp_channel_nonvalid 

  //----------------------------------------------------------------------- 
  // Collect packet from ace slave write resp channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_slave_write_resp_channel(ref ace_write_resp_pkt_t pkt);
      bit done = 0;
      bit first_pass = 0;
      do begin 
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (bvalid && first_pass == 0) begin
              pkt.t_pkt_seen_on_intf = $time;
              first_pass = 1;
          end
          if (bvalid & axi_monitor_cb.bready) begin
              pkt.bid    = bid;
              pkt.bresp  = axi_bresp_enum_t'(bresp);
              pkt.buser  = buser;
              pkt.btrace = btrace;
              done       = 1;
          end
      end while (!done);
  endtask : collect_ace_slave_write_resp_channel 
 
  //----------------------------------------------------------------------- 
  // Reset Ace slave snoop addr channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_slave_snoop_addr_channel();
      axi_slave_cb.acvalid <= 1'b0;
      axi_slave_cb.acaddr  <= 1'b0;
      axi_slave_cb.acsnoop <= 1'b0;
      axi_slave_cb.acprot  <= 1'b0;
      axi_slave_cb.actrace <= 1'b0;
      axi_slave_cb.acvmidext<=1'b0;
  endtask : async_reset_ace_slave_snoop_addr_channel

  //----------------------------------------------------------------------- 
  // Drive ace slave snoop addr channel
  //----------------------------------------------------------------------- 
  
  task automatic drive_ace_slave_snoop_addr_channel(ace_snoop_addr_pkt_t pkt, bit valid = 1);
      int m_dly;
      
      m_dly = ($urandom_range(1,100) <= ACE_SLAVE_SNOOP_ADDR_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_SLAVE_SNOOP_ADDR_CHANNEL_DELAY_MIN, ACE_SLAVE_SNOOP_ADDR_CHANNEL_DELAY_MAX));
      wait ((rst_n == 1) && (vif_rst_n == 1));
      if (valid) begin
          @(axi_slave_cb);
          if (m_dly) begin
              axi_slave_cb.acvalid <= 1'b0;
              m_dly--;
          end
          else begin
              axi_slave_cb.acvalid <= 1'b1;
              axi_slave_cb.acaddr  <= pkt.acaddr;
              axi_slave_cb.acsnoop <= pkt.acsnoop;
              axi_slave_cb.acprot  <= pkt.acprot;
              axi_slave_cb.actrace <= pkt.actrace;
              axi_slave_cb.acvmidext<=pkt.acvmid;
              if (axi_slave_cb.bready) begin
                  @(axi_slave_cb);
                  drive_ace_slave_snoop_addr_channel_nonvalid();
              end
              else begin
                  @(axi_slave_cb.acready);
                  @(axi_slave_cb);
                  drive_ace_slave_snoop_addr_channel_nonvalid();
              end
          end
      end
      else begin
          @(axi_slave_cb);
          axi_slave_cb.acvalid <= 1'b0;
      end
  endtask : drive_ace_slave_snoop_addr_channel
      
  //----------------------------------------------------------------------- 
  // Drive ace slave snoop addr channel nonvalid
  //----------------------------------------------------------------------- 
  task automatic drive_ace_slave_snoop_addr_channel_nonvalid;
      axi_slave_cb.acvalid <= 1'b0;
  <% if (obj.DutInfo.useResiliency) { %>
      axi_slave_cb.acaddr  <= 'b0;
      axi_slave_cb.acsnoop <= 'b0;
      axi_slave_cb.acprot  <= 'b0;
      axi_slave_cb.actrace <= 'b0;
      axi_slave_cb.acvmidext<='b0;

  <% } else { %>
      axi_slave_cb.acaddr  <= 'bx;
      axi_slave_cb.acsnoop <= 'bx;
      axi_slave_cb.acprot  <= 'bx;
      axi_slave_cb.actrace <= 'bx;
      axi_slave_cb.acvmidext<='bx;
  <% } %>
  endtask : drive_ace_slave_snoop_addr_channel_nonvalid 

  //----------------------------------------------------------------------- 
  // Collect packet from ace slave snoop addr channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_slave_snoop_addr_channel(ref ace_snoop_addr_pkt_t pkt);
      bit done = 0;
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (acvalid & axi_monitor_cb.acready) begin
              pkt.acaddr  = acaddr;
              pkt.acsnoop = acsnoop;
              pkt.acprot  = acprot;
              pkt.actrace = actrace;
              <% if (obj.DutInfo.eAc == 1 && obj.system.DVMVersionSupport > 128) { %>
              pkt.acvmid  = acvmidext;
              <% } %>
              done        = 1;
          end
      end while (!done);
  endtask : collect_ace_slave_snoop_addr_channel 

  //----------------------------------------------------------------------- 
  // Reset Ace slave snoop resp channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_slave_snoop_resp_channel();
      axi_slave_cb.crready <= 1'b0;
  endtask : async_reset_ace_slave_snoop_resp_channel

  //----------------------------------------------------------------------- 
  // Drive ace slave snoop resp channel 
  //----------------------------------------------------------------------- 
  task automatic drive_ace_slave_snoop_resp_channel(bit ready=1);
      int m_dly;
      bit done;

      m_dly = ($urandom_range(1,100) <= ACE_SLAVE_SNOOP_RESP_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_SLAVE_SNOOP_RESP_CHANNEL_DELAY_MIN, ACE_SLAVE_SNOOP_RESP_CHANNEL_DELAY_MAX));
      wait ((rst_n == 1) && (vif_rst_n == 1));
      do begin
          @(axi_slave_cb);
          if (ready) begin
              if (m_dly == 0) begin
                  axi_slave_cb.crready <= 1'b1;
              end
              else begin
                  axi_slave_cb.crready <= 1'b0;
              end
          end 
          else begin
              axi_slave_cb.crready <= 1'b0;
          end

          done = m_dly ? 0 : 1;
          if (m_dly) m_dly--;
      end while (!done);  

  endtask : drive_ace_slave_snoop_resp_channel

  //----------------------------------------------------------------------- 
  // Collect packet from ace slave snoop resp channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_slave_snoop_resp_channel(ref ace_snoop_resp_pkt_t pkt);
      bit done = 0;
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.crvalid & crready) begin
              pkt.crresp  = axi_monitor_cb.crresp;
              pkt.crtrace = axi_monitor_cb.crtrace;
              done        = 1;
          end
      end while (!done);
  endtask : collect_ace_slave_snoop_resp_channel 

  //----------------------------------------------------------------------- 
  // Collect packet from ace slave snoop resp channel - for driver
  //----------------------------------------------------------------------- 

  task automatic collect_ace_slave_snoop_resp_channel_for_driver(ref ace_snoop_resp_pkt_t pkt);
      bit done = 0;
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.crvalid & crready) begin
              pkt.crresp  = axi_monitor_cb.crresp;
              pkt.crtrace = axi_monitor_cb.crtrace;
              done       = 1;
          end
      end while (!done);
  endtask : collect_ace_slave_snoop_resp_channel_for_driver 


  //----------------------------------------------------------------------- 
  // Reset Ace slave snoop data channel
  //----------------------------------------------------------------------- 
  task automatic async_reset_ace_slave_snoop_data_channel();
      axi_slave_cb.cdready <= 1'b0;
  endtask : async_reset_ace_slave_snoop_data_channel

  //----------------------------------------------------------------------- 
  // Drive ace slave snoop data channel 
  //----------------------------------------------------------------------- 
  task automatic drive_ace_slave_snoop_data_channel(bit ready=1);
      int m_dly;
      bit done;

      m_dly = ($urandom_range(1,100) <= ACE_SLAVE_SNOOP_DATA_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_SLAVE_SNOOP_DATA_CHANNEL_DELAY_MIN, ACE_SLAVE_SNOOP_DATA_CHANNEL_DELAY_MAX));
      wait ((rst_n == 1) && (vif_rst_n == 1));
      do begin
          @(axi_slave_cb);
          if (ready) begin
              if (m_dly == 0) begin
                 if (cdvalid == 1 && bloc_axi_stall == 1 ) begin
                    axi_slave_cb.cdready    <= 1'b0; 
                    cnt_rdy_blckd_duration++;
                    if ( cnt_rdy_blckd_duration == RDY_NOT_ASSERTED_DURATION ) begin
                        cnt_rdy_blckd_duration = 0;
                        bloc_axi_stall         = 0;
                    end 
                 end 
                 else 
                 if (cdvalid == 1 && en_cd_stall == 1 ) begin
                     axi_slave_cb.cdready <= 1'b0;
                     if(stall_cd_chnl_till_en_cd_stall_deassrt) begin
                         forever begin
                            if (en_cd_stall == 0) begin 
                                 break;
                            end                         
                            @(posedge clk) ; 
                         end
                     end else begin
                         for (int i = 0; i <= stall_cd_period; i++) begin
                            if (en_cd_stall == 0) begin 
                                 break;
                            end                         
                            @(posedge clk) ; 
                         end
                     end
                     axi_slave_cb.cdready <= 1'b1;
                     @(posedge clk) ;
                 end 
                 else begin
                  axi_slave_cb.cdready <= 1'b1;
                 end
              end
              else begin
                  axi_slave_cb.cdready <= 1'b0;
              end
          end 
          else begin
              axi_slave_cb.cdready <= 1'b0;
          end

          done = m_dly ? 0 : 1;
          if (m_dly) m_dly--;
      end while (!done);  

  endtask : drive_ace_slave_snoop_data_channel

  //----------------------------------------------------------------------- 
  // Collect packet from ace slave snoop data channel
  //----------------------------------------------------------------------- 

  task automatic collect_ace_slave_snoop_data_channel(ref ace_snoop_data_pkt_t pkt);
      automatic int               beat_cnt;
      automatic axi_cddata_t data[256];
      automatic axi_cddatachk_t datachk[256];
      automatic axi_cdpoison_t poison[256];
      automatic time              t_timestamp[256];
      automatic bit               done;

      beat_cnt = 0;
      done     = 0;
  
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.cdvalid & cdready) begin
              data[beat_cnt]        = axi_monitor_cb.cddata;
              datachk[beat_cnt]     = axi_monitor_cb.cddatachk;
              poison[beat_cnt]      = axi_monitor_cb.cdpoison;
              pkt.cdtrace           = axi_monitor_cb.cdtrace;
              t_timestamp[beat_cnt] = $time;
              if (axi_monitor_cb.cdlast) begin
                  pkt.cddata    = new[beat_cnt + 1] (data);
                  pkt.cddatachk = new[beat_cnt + 1] (datachk);
                  pkt.cdpoison  = new[beat_cnt + 1] (poison);
                  pkt.t_cdtime  = new[beat_cnt + 1] (t_timestamp);
                  done          = 1;
                  beat_cnt      = 0;
              end 
              else begin
                  beat_cnt++;
              end
          end
      end while (!done);
  endtask : collect_ace_slave_snoop_data_channel 
 
  //----------------------------------------------------------------------- 
  // Collect packet from ace slave snoop data channel - for driver
  //----------------------------------------------------------------------- 

  task automatic collect_ace_slave_snoop_data_channel_for_driver(ref ace_snoop_data_pkt_t pkt);
      automatic int               beat_cnt;
      automatic axi_cddata_t data[256];
      automatic axi_cddatachk_t datachk[256];
      automatic axi_cdpoison_t poison[256];
      automatic time              t_timestamp[256];
      automatic bit               done;

      beat_cnt = 0;
      done     = 0;
  
      do begin
          @(axi_monitor_cb);
          if ((rst_n == 0) || (vif_rst_n ==0)) begin
              return;
          end
          if (axi_monitor_cb.cdvalid & cdready) begin
              data[beat_cnt]        = axi_monitor_cb.cddata;
              datachk[beat_cnt]     = axi_monitor_cb.cddatachk;
              poison[beat_cnt]      = axi_monitor_cb.cdpoison;
              pkt.cdtrace           = axi_monitor_cb.cdtrace;
              t_timestamp[beat_cnt] = $time;
              if (axi_monitor_cb.cdlast) begin
                  pkt.cddata    = new[beat_cnt + 1] (data);
                  pkt.cddatachk = new[beat_cnt + 1] (datachk);
                  pkt.cdpoison  = new[beat_cnt + 1] (poison);
                  pkt.t_cdtime  = new[beat_cnt + 1] (t_timestamp);
                  done          = 1;
                  beat_cnt      = 0;
              end 
              else begin
                  beat_cnt++;
              end
          end
      end while (!done);
  endtask : collect_ace_slave_snoop_data_channel_for_driver 


  //----------------------------------------------------------------------- 
  // Drive ace slave snoop data channel 
  //----------------------------------------------------------------------- 
  task automatic drive_ace_slave_sysco_channel(bit ack=1);
      int m_dly;
      bit done;

      m_dly = ($urandom_range(1,100) <= ACE_SLAVE_SYSCO_CHANNEL_BURST_PCT) ? 0 : ($urandom_range(ACE_SLAVE_SYSCO_CHANNEL_DELAY_MIN, ACE_SLAVE_SYSCO_CHANNEL_DELAY_MAX));
      wait ((rst_n == 1) && (vif_rst_n == 1));
      do begin
          @(axi_slave_cb);
          done = m_dly ? 0 : 1;
          if (m_dly) m_dly--;

          if(done)
             axi_slave_cb.syscoack <= ack;
      end while (!done);  

  endtask : drive_ace_slave_sysco_channel

  // Loop to send back SYSCOACK
  initial begin
      #0;
      if (IS_ACTIVE == 1 && IS_IF_A_SLAVE == 1) begin
          forever begin
              @(axi_slave_cb.syscoreq);
	      drive_ace_slave_sysco_channel(axi_slave_cb.syscoreq);
	  end
      end
  end
				     
//----------------------------------------------------------------------- 
// Collect packet from ace slave snoop data channel - for driver
//----------------------------------------------------------------------- 

<% if (obj.Block == "io_aiu") { %>    
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>    

`ifdef ASSERT_ON2
<%=obj.BlockId%>_AcePC m_ace_arm_sva          (


   // Global Signals
   .ACLK                     ( clk                           ) ,
   .ARESETn                  ( rst_n                          ) ,

   // PROT signals 
   .AWPROT                   ( awprot                    ) ,
   .ARPROT                   ( arprot                    ) ,
   .ACPROT                   ( acprot                    ) ,


   // QOS signals 
<% if (obj.DutInfo.wQos) { %>
   .AWQOS                    ( awqos                     ) ,
   .ARQOS                    ( arqos                     ) ,
<% } else { %>
   .AWQOS                    ( '0                               ) ,
   .ARQOS                    ( '0                               ) ,
<% } %>

   // REGION signals
<% if (obj.DutInfo.wRegion) { %>
   .AWREGION                 ( awregion                  ) ,
   .ARREGION                 ( arregion                  ) ,
<% } else { %>
   .AWREGION                 ( '0                               ) ,
   .ARREGION                 ( '0                               ) ,
<% } %>

   // USER signals
<%if (obj.DutInfo.wAwUser){%>
   .AWUSER                   ( awuser                    ) ,
<% } else { %>
   .AWUSER                   ( '0                               ) ,
<% } %>
<%if (obj.DutInfo.wWUser){%>
   .WUSER                    ( wuser                     ) ,
<% } else { %>
   .WUSER                    ( '0                               ) ,
<% } %>
<%if (obj.DutInfo.wBUser){%>
   .BUSER                    ( buser                     ) ,
<% } else { %>
   .BUSER                    ( '0                               ) ,
<% } %>
<%if (obj.DutInfo.wArUser){%>
   .ARUSER                   ( aruser                    ) ,
<% } else { %>
   .ARUSER                   ( '0                               ) ,
<% } %>
<%if (obj.DutInfo.wRUser){%>
   .RUSER                    ( ruser                     ) ,
<% } else { %>
   .RUSER                    ( '0                               ) ,
<% } %>

   // CACHE signals
   .AWCACHE                  ( awcache                   ) ,
   .ARCACHE                  ( arcache                   ) ,

   // Write Address Channel
   .AWID                     ( awid                      ) ,
   .AWADDR                   ( awaddr                    ) ,
   .AWLEN                    ( awlen                     ) ,
   .AWSIZE                   ( awsize                    ) ,
   .AWBURST                  ( awburst                   ) ,
   .AWLOCK                   ( awlock                    ) ,
   .AWSNOOP                  ( awsnoop                   ) ,
   .AWBAR                    ( awbar                     ) ,
   .AWDOMAIN                 ( awdomain                  ) ,
//   .AWATOP                   ( awatop                    ) ,
//   .AWSTASHNID               ( awstashnid                ) ,
//   .AWSTASHNIDEN             ( awstashniden              ) ,
//   .AWSTASHLPID              ( awstashlpid               ) ,
//   .AWSTASHLPIDEN            ( awstashlpiden             ) ,
//   .AWTRACE                  ( awtrace                   ) ,
   .AWVALID                  ( awvalid                   ) ,
   .AWREADY                  ( awready                   ) ,

   // Write Channel
   .WDATA                    ( wdata                     ) ,
   .WSTRB                    ( wstrb                     ) ,
   .WLAST                    ( wlast                     ) ,
//   .WTRACE                   ( wtrace                    ) ,
//   .WPOISON                  ( wpoison                   ) ,
//   .WDATACHK                 ( wdatachk                  ) ,
   .WVALID                   ( wvalid                    ) ,
   .WREADY                   ( wready                    ) ,

   // Write Response Channel
   .BID                      ( bid                       ) ,
   .BRESP                    ( bresp                     ) ,
//   .BTRACE                    ( btrace                     ) ,
   .BVALID                   ( bvalid                    ) ,
   .BREADY                   ( bready                    ) ,

   .WACK                     ( wack                      ) ,

   // Read Address Channel
   .ARID                     ( arid                      ) ,
   .ARADDR                   ( araddr                    ) ,
   .ARLEN                    ( arlen                     ) ,
   .ARSIZE                   ( arsize                    ) ,
   .ARBURST                  ( arburst                   ) ,
   .ARLOCK                   ( arlock                    ) ,
   .ARSNOOP                  ( arsnoop                   ) ,
   .ARBAR                    ( arbar                     ) ,
   .ARDOMAIN                 ( ardomain                  ) ,
//   .ARTRACE                  ( artrace                   ) ,
<% if (obj.DutInfo.eAc == 1 && obj.system.DVMVersionSupport > 128) { %>
   .ARVMID                   ( arvmidext                    ) ,
<% } else { %>
   .ARVMID                   ( '0                    ) ,
<% } %>
   .ARVALID                  ( arvalid                   ) ,
   .ARREADY                  ( arready                   ) ,

   //  Read Channel
   .RID                      ( rid                       ) ,
   .RLAST                    ( rlast                     ) ,
   .RDATA                    ( rdata                     ) ,
//   .RDATACHK                 ( rdatachk                  ) ,
//   .RPOISON                  ( rpoison                   ) ,
//   .RTRACE                   ( rtrace                    ) ,
   .RRESP                    ( rresp                     ) ,
   .RVALID                   ( rvalid                    ) ,
   .RREADY                   ( rready                    ) ,

   .RACK                     ( rack                      ) ,

   // Snoop Address Channel
   .ACADDR                   ( acaddr                    ) ,
   .ACSNOOP                  ( acsnoop                   ) ,
//   .ACTRACE                  ( actrace                   ) ,
//   .ACVMID                   ( acvmidext                    ) ,
   .ACVALID                  ( acvalid                   ) ,
   .ACREADY                  ( acready                   ) ,

   // Snoop Response Channel
   .CRRESP                   ( crresp                    ) ,
   .CRVALID                  ( crvalid                   ) ,
//   .CRTRACE                  ( crtrace                   ) ,
   .CRREADY                  ( crready                   ) ,

   // Snoop Data Channel
   .CDVALID                  ( cdvalid                   ) ,
   .CDREADY                  ( cdready                   ) ,
   .CDLAST                   ( cdlast                    ) ,
   .CDDATA                   ( cddata                    ) ,
//   .CDDATACHK              ( cddatachk                 ) ,
//   .CDPOISON               ( cdpoison                  ) ,
//   .CDTRACE                ( cdtrace                   ) ,

   // Low Power Interface
   .CACTIVE                  ( 'b1                       ) ,
   .CSYSREQ                  ( 'b1                  ) ,
   .CSYSACK                  ( 'b1                  )
) ;
`endif

<%}else if (obj.fnNativeInterface == "ACE-LITE" ) { %>    


`ifdef ASSERT_ON2
<%=obj.BlockId%>_AceLitePC m_acelite_arm_sva  (
   // Global Signals
   .ACLK                     ( clk                           ) ,
   .ARESETn                  ( rst_n                          ) ,

   // PROT signals 
   .AWPROT                   ( awprot                    ) ,
   .ARPROT                   ( arprot                    ) ,
//  .ACPROT                   ( ace_if.acprot                    ) ,


   // QOS signals 
<% if (obj.DutInfo.wQos) { %>
   .AWQOS                    ( awqos                     ) ,
   .ARQOS                    ( arqos                     ) ,
<% } else { %>
   .AWQOS                    ( '0                               ) ,
   .ARQOS                    ( '0                               ) ,
<% } %>

   // REGION signals
<% if (obj.DutInfo.wRegion) { %>
   .AWREGION                 ( awregion                  ) ,
   .ARREGION                 ( arregion                  ) ,
<% } else { %>
   .AWREGION                 ( '0                               ) ,
   .ARREGION                 ( '0                               ) ,
<% } %>

   // USER signals
<%if (obj.DutInfo.wAwUser){%>
   .AWUSER                   ( awuser                    ) ,
<% } else { %>
   .AWUSER                   ( '0                               ) ,
<% } %>
<%if (obj.DutInfo.wWUser){%>
   .WUSER                    ( wuser                     ) ,
<% } else { %>
   .WUSER                    ( '0                               ) ,
<% } %>
<%if (obj.DutInfo.wBUser){%>
   .BUSER                    ( buser                     ) ,
<% } else { %>
   .BUSER                    ( '0                               ) ,
<% } %>
<%if (obj.DutInfo.wArUser){%>
   .ARUSER                   ( aruser                    ) ,
<% } else { %>
   .ARUSER                   ( '0                               ) ,
<% } %>
<%if (obj.DutInfo.wRUser){%>
   .RUSER                    ( ruser                     ) ,
<% } else { %>
   .RUSER                    ( '0                               ) ,
<% } %>

   // CACHE signals
   .AWCACHE                  ( awcache                   ) ,
   .ARCACHE                  ( arcache                   ) ,

   // Write Address Channel
   .AWID                     ( awid                      ) ,
   .AWADDR                   ( awaddr                    ) ,
   .AWLEN                    ( awlen                     ) ,
   .AWSIZE                   ( awsize                    ) ,
   .AWBURST                  ( awburst                   ) ,
   .AWLOCK                   ( awlock                    ) ,
   .AWSNOOP                  ( awsnoop                   ) ,
   .AWBAR                    ( awbar                     ) ,
   .AWDOMAIN                 ( awdomain                  ) ,
//   .AWATOP                   ( awatop                    ) ,
//   .AWSTASHNID               ( awstashnid                ) ,
//   .AWSTASHNIDEN             ( awstashniden              ) ,
//   .AWSTASHLPID              ( awstashlpid               ) ,
//   .AWSTASHLPIDEN            ( awstashlpiden             ) ,
//   .AWTRACE                  ( awtrace                   ) ,
   .AWVALID                  ( awvalid                   ) ,
   .AWREADY                  ( awready                   ) ,

   // Write Channel
   .WDATA                    ( wdata                     ) ,
   .WSTRB                    ( wstrb                     ) ,
   .WLAST                    ( wlast                     ) ,
//   .WTRACE                   ( wtrace                    ) ,
//   .WPOISON                  ( wpoison                   ) ,
//   .WDATACHK                 ( wdatachk                  ) ,
   .WVALID                   ( wvalid                    ) ,
   .WREADY                   ( wready                    ) ,

   // Write Response Channel
   .BID                      ( bid                       ) ,
   .BRESP                    ( bresp                     ) ,
//   .BTRACE                    ( btrace                     ) ,
   .BVALID                   ( bvalid                    ) ,
   .BREADY                   ( bready                    ) ,

   // Read Address Channel
   .ARID                     ( arid                      ) ,
   .ARADDR                   ( araddr                    ) ,
   .ARLEN                    ( arlen                     ) ,
   .ARSIZE                   ( arsize                    ) ,
   .ARBURST                  ( arburst                   ) ,
   .ARLOCK                   ( arlock                    ) ,
   .ARSNOOP                  ( arsnoop                   ) ,
   .ARBAR                    ( arbar                     ) ,
   .ARDOMAIN                 ( ardomain                  ) ,
//   .ARTRACE                  ( artrace                   ) ,
<% if (obj.DutInfo.eAc == 1 && obj.system.DVMVersionSupport > 128) { %>
   .ARVMID                   ( arvmidext                    ) ,
<% } else { %>
   .ARVMID                   ( '0                    ) ,
<% } %>
   .ARVALID                  ( arvalid                   ) ,
   .ARREADY                  ( arready                   ) ,

   //  Read Channel
   .RID                      ( rid                       ) ,
   .RLAST                    ( rlast                     ) ,
   .RDATA                    ( rdata                     ) ,
   .RRESP                    ( rresp                     ) ,
//   .RDATACHK                 ( rdatachk                  ) ,
//   .RPOISON                  ( rpoison                   ) ,
//   .RTRACE                   ( rtrace                    ) ,
   .RVALID                   ( rvalid                    ) ,
   .RREADY                   ( rready                    ) ,

   // Low Power Interface
   .CACTIVE                  ( 'b1                       ) ,
   .CSYSREQ                  ( 'b1                  ) ,
   .CSYSACK                  ( 'b1                  )
);


`endif
<%}%>
<%}%>

//------------------------------------------------------------------------------
// INDEX:   3) X-Propagation Rules
//------------------------------------------------------------------------------

//`ifdef ASSERT_ON
`ifndef ASSERT_OFF    
<% if(!obj.CUSTOMER_ENV) { %>
  // X-Checking on by default


  // INDEX:        - AXI4_ERRM_BREADY_X
  // =====
  property AXI4_ERRM_BREADY_X;
    @(posedge clk)
      rst_n
      |-> ! $isunknown(bready);
  endproperty
  axi4_errm_bready_x: assert property (AXI4_ERRM_BREADY_X) 
  else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "bready must not be unknown.");

  // INDEX:        - AXI4_ERRS_BID_X
  // =====
  property AXI4_ERRS_BID_X;
    @(posedge clk) 
      rst_n & bvalid
      |-> ! $isunknown(bid);
  endproperty
  axi4_errs_bid_x: assert property (AXI4_ERRS_BID_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "bid must not be unknown.");


  // INDEX:        - AXI4_ERRS_BRESP_X
  // =====
  property AXI4_ERRS_BRESP_X;
    @(posedge clk) 
      rst_n & bvalid
      |-> ! $isunknown(bresp);
  endproperty
  axi4_errs_bresp_x: assert property (AXI4_ERRS_BRESP_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "bresp must not be unknown.");


  // INDEX:        - AXI4_ERRS_BVALID_X
  // =====
  property AXI4_ERRS_BVALID_X;
    @(posedge clk) 
      rst_n
      |-> ! $isunknown(bvalid);
  endproperty
  axi4_errs_bvalid_x: assert property (AXI4_ERRS_BVALID_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "bvalid must not be unknown.");

  // 03/10/2017 We looked at the ARM ace assertion and they zero this out for 
  // INDEX:        - AXI4_ERRS_RDATA_X
  // =====
  //property AXI4_ERRS_RDATA_X;
  //  @(posedge clk)
  //    rst_n & rvalid
  //    |-> ! $isunknown(rdata);
  //endproperty
  //axi4_errs_rdata_x: assert property (AXI4_ERRS_RDATA_X) 
  //  else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "rdata must not be unknown.");


  // INDEX:        - AXI4_ERRM_RREADY_X
  // =====
  property AXI4_ERRM_RREADY_X;
    @(posedge clk)
      rst_n
      |-> ! $isunknown(rready);
  endproperty
  axi4_errm_rready_x: assert property (AXI4_ERRM_RREADY_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "rready must not be unknown.");


  // INDEX:        - AXI4_ERRS_RID_X
  // =====
  property AXI4_ERRS_RID_X;
    @(posedge clk)
      rst_n & rvalid
      |-> ! $isunknown(rid);
  endproperty
  axi4_errs_rid_x: assert property (AXI4_ERRS_RID_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "rid must not be unknown.");


  // INDEX:        - AXI4_ERRS_RLAST_X
  // =====
  property AXI4_ERRS_RLAST_X;
    @(posedge clk)
      rst_n & rvalid
      |-> ! $isunknown(rlast);
  endproperty
  axi4_errs_rlast_x: assert property (AXI4_ERRS_RLAST_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "rlast must not be unknown.");


  // INDEX:        - AXI4_ERRS_RRESP_X
  // =====
  property AXI4_ERRS_RRESP_X;
    @(posedge clk) 
      rst_n & rvalid
      |-> ! $isunknown(rresp);
  endproperty
  axi4_errs_rresp_x: assert property (AXI4_ERRS_RRESP_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "rresp must not be unknown.");


  // INDEX:        - AXI4_ERRS_RVALID_X
  // =====
  property AXI4_ERRS_RVALID_X;
    @(posedge clk)
      rst_n
      |-> ! $isunknown(rvalid);
  endproperty
  axi4_errs_rvalid_x: assert property (AXI4_ERRS_RVALID_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "rvalid must not be unknown.");

/*
  // INDEX:        - AXI4_ERRS_AWATOP_X
  // =====
  property AXI4_ERRS_AWATOP_X;
    @(posedge clk)
      rst_n & awvalid
      |-> ! $isunknown(awatop);
  endproperty
  axi4_errs_awatop_x: assert property (AXI4_ERRS_AWATOP_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "awatop must not be unknown.");


  // INDEX:        - AXI4_ERRS_AWSTASHNID_X
  // =====
  property AXI4_ERRS_AWSTASHNID_X;
    @(posedge clk)
      rst_n & awvalid
      |-> ! $isunknown(awstashnid);
  endproperty
  axi4_errs_awstashnid_x: assert property (AXI4_ERRS_AWSTASHNID_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "awstashnid must not be unknown.");


  // INDEX:        - AXI4_ERRS_AWSTASHNIDEN_X
  // =====
  property AXI4_ERRS_AWSTASHNIDEN_X;
    @(posedge clk)
      rst_n & awvalid
      |-> ! $isunknown(awstashniden);
  endproperty
  axi4_errs_awstashniden_x: assert property (AXI4_ERRS_AWSTASHNIDEN_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "awstashniden must not be unknown.");


  // INDEX:        - AXI4_ERRS_AWSTASHLPIDEN_X
  // =====
  property AXI4_ERRS_AWSTASHLPIDEN_X;
    @(posedge clk)
      rst_n & awvalid
      |-> ! $isunknown(awstashlpiden);
  endproperty
  axi4_errs_awstashlpiden_x: assert property (AXI4_ERRS_AWSTASHLPIDEN_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "awstashlpiden must not be unknown.");


  // INDEX:        - AXI4_ERRS_AWTRACE_X
  // =====
  property AXI4_ERRS_AWTRACE_X;
    @(posedge clk)
      rst_n & awvalid
      |-> ! $isunknown(awtrace);
  endproperty
  axi4_errs_awtrace_x: assert property (AXI4_ERRS_AWTRACE_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "awtrace must not be unknown.");


  // INDEX:        - AXI4_ERRS_AWSTASHLPID_X
  // =====
  property AXI4_ERRS_AWSTASHLPID_X;
    @(posedge clk)
      rst_n & awvalid
      |-> ! $isunknown(awstashlpid);
  endproperty
  axi4_errs_awstashlpid_x: assert property (AXI4_ERRS_AWSTASHLPID_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "awstashlpid must not be unknown.");


  // INDEX:        - AXI4_ERRS_ARTRACE_X
  // =====
  property AXI4_ERRS_ARTRACE_X;
    @(posedge clk)
      rst_n & arvalid
      |-> ! $isunknown(artrace);
  endproperty
  axi4_errs_artrace_x: assert property (AXI4_ERRS_ARTRACE_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "artrace must not be unknown.");


  // INDEX:        - AXI4_ERRS_ARVMIDEXT_X
  // =====
  property AXI4_ERRS_ARVMIDEXT_X;
    @(posedge clk)
      rst_n & arvalid
      |-> ! $isunknown(arvmidext);
  endproperty
  axi4_errs_arvmidext_x: assert property (AXI4_ERRS_ARVMIDEXT_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "arvmidext must not be unknown.");


  // INDEX:        - AXI4_ERRS_WTRACE_X
  // =====
  property AXI4_ERRS_WTRACE_X;
    @(posedge clk)
      rst_n & wvalid
      |-> ! $isunknown(wtrace);
  endproperty
  axi4_errs_wtrace_x: assert property (AXI4_ERRS_WTRACE_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "wtrace must not be unknown.");


  // INDEX:        - AXI4_ERRS_WPOISON_X
  // =====
  property AXI4_ERRS_WPOISON_X;
    @(posedge clk)
      rst_n & wvalid
      |-> ! $isunknown(wpoison);
  endproperty
  axi4_errs_wpoison_x: assert property (AXI4_ERRS_WPOISON_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "wpoison must not be unknown.");


  // INDEX:        - AXI4_ERRS_WDATACHK_X
  // =====
  property AXI4_ERRS_WDATACHK_X;
    @(posedge clk)
      rst_n & wvalid
      |-> ! $isunknown(wdatachk);
  endproperty
  axi4_errs_wdatachk_x: assert property (AXI4_ERRS_WDATACHK_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "wdatachk must not be unknown.");


  // INDEX:        - AXI4_ERRS_CRTRACE_X
  // =====
  property AXI4_ERRS_CRTRACE_X;
    @(posedge clk)
      rst_n & crvalid
      |-> ! $isunknown(crtrace);
  endproperty
  axi4_errs_crtrace_x: assert property (AXI4_ERRS_CRTRACE_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "crtrace must not be unknown.");


  // INDEX:        - AXI4_ERRS_CDTRACE_X
  // =====
  property AXI4_ERRS_CDTRACE_X;
    @(posedge clk)
      rst_n & cdvalid
      |-> ! $isunknown(cdtrace);
  endproperty
  axi4_errs_cdtrace_x: assert property (AXI4_ERRS_CDTRACE_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "cdtrace must not be unknown.");


  // INDEX:        - AXI4_ERRS_CDDATACHK_X
  // =====
  property AXI4_ERRS_CDDATACHK_X;
    @(posedge clk)
      rst_n & cdvalid
      |-> ! $isunknown(cddatachk);
  endproperty
  axi4_errs_cddatachk_x: assert property (AXI4_ERRS_CDDATACHK_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "cddatachk must not be unknown.");


  // INDEX:        - AXI4_ERRS_CDPOISON_X
  // =====
  property AXI4_ERRS_CDPOISON_X;
    @(posedge clk)
      rst_n & cdvalid
      |-> ! $isunknown(cdpoison);
  endproperty
  axi4_errs_cdpoison_x: assert property (AXI4_ERRS_CDPOISON_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "cdpoison must not be unknown.");


  // INDEX:        - AXI4_ERRS_BTRACE_X
  // =====
  property AXI4_ERRS_BTRACE_X;
    @(posedge clk)
      rst_n & bvalid
      |-> ! $isunknown(btrace);
  endproperty
  axi4_errs_btrace_x: assert property (AXI4_ERRS_BTRACE_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "btrace must not be unknown.");


  // INDEX:        - AXI4_ERRS_ACTRACE_X
  // =====
  property AXI4_ERRS_ACTRACE_X;
    @(posedge clk)
      rst_n & acvalid
      |-> ! $isunknown(actrace);
  endproperty
  axi4_errs_actrace_x: assert property (AXI4_ERRS_ACTRACE_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "actrace must not be unknown.");


  // INDEX:        - AXI4_ERRS_ACVMIDEXT_X
  // =====
  property AXI4_ERRS_ACVMIDEXT_X;
    @(posedge clk)
      rst_n & acvalid
      |-> ! $isunknown(acvmidext);
  endproperty
  axi4_errs_acvmidext_x: assert property (AXI4_ERRS_ACVMIDEXT_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "acvmidext must not be unknown.");


  // INDEX:        - AXI4_ERRS_RTRACE_X
  // =====
  property AXI4_ERRS_RTRACE_X;
    @(posedge clk)
      rst_n & rvalid
      |-> ! $isunknown(rtrace);
  endproperty
  axi4_errs_rtrace_x: assert property (AXI4_ERRS_RTRACE_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "rtrace must not be unknown.");


  // INDEX:        - AXI4_ERRS_RDATACHK_X
  // =====
  property AXI4_ERRS_RDATACHK_X;
    @(posedge clk)
      rst_n & rvalid
      |-> ! $isunknown(rdatachk);
  endproperty
  axi4_errs_rdatachk_x: assert property (AXI4_ERRS_RDATACHK_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "rdatachk must not be unknown.");


  // INDEX:        - AXI4_ERRS_RPOISON_X
  // =====
  property AXI4_ERRS_RPOISON_X;
    @(posedge clk)
      rst_n & rvalid
      |-> ! $isunknown(rpoison);
  endproperty
  axi4_errs_rpoison_x: assert property (AXI4_ERRS_RPOISON_X) 
    else `uvm_error("<%=obj.BlockId%> ERROR AXI IF", "rpoison must not be unknown.");
*/
<% } %>

`endif // ASSERT_OFF
//`endif // ASSERT_ON


<% } %> 
`endif

 
endinterface
