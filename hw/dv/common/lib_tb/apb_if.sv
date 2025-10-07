////////////////////////////////////////////////////////////////////////////////
//
// APB Interface
//
////////////////////////////////////////////////////////////////////////////////

//======================================================================= 
// Notes:
// 1) 
//======================================================================= 

interface <%=obj.BlockId%>_apb_if (input clk, input rst_n);

   import <%=obj.BlockId%>_apb_agent_pkg::*;

  //----------------------------------------------------------------------- 
  // Delay values used in this interface
  //-----------------------------------------------------------------------
  // bunch up requests together
   parameter apb_setup_time = 10ps;
   parameter apb_hold_time = 0;

   tri0 logic IS_IF_A_MONITOR; // use wire instead of parameter to avoid to change all the unit env but only fsys // init at 0 by default

   /*int APB_MCMD_DELAY_MIN                      = 0;
   int APB_MCMD_DELAY_MAX                      = 1;
   int APB_MCMD_BURST_PCT                      = 90;
   bit APB_MCMD_WAIT_FOR_SCMDACCEPT            = 0;

   int APB_MACCEPT_DELAY_MIN                   = 0;
   int APB_MACCEPT_DELAY_MAX                   = 1;
   int APB_MACCEPT_BURST_PCT                   = 90;
   bit APB_MACCEPT_WAIT_FOR_SRESP              = 0;*/

  //-----------------------------------------------------------------------
  // Queues/Events to drive/collect data packets on all ACE channels 
  //-----------------------------------------------------------------------
   apb_pkt_t                m_drv_mst_q[$];
   event                    e_drv_mst_q;

  //-----------------------------------------------------------------------
  // APB Signals
  //-----------------------------------------------------------------------

   wire apb_paddr_logic_t     paddr;
   wire apb_pwrite_logic_t    pwrite;
   wire apb_psel_logic_t      psel;
   wire apb_pprot_logic_t     pprot;
   wire apb_pstrb_logic_t     pstrb;
   wire apb_penable_logic_t   penable;
   wire apb_prdata_logic_t    prdata;
   wire apb_pwdata_logic_t    pwdata;
   wire apb_pready_logic_t    pready;
   wire apb_pslverr_logic_t   pslverr;
   wire logic                 IRQ_c;
   wire logic                 IRQ_uc;
   wire logic                 TransActv;


  //-----------------------------------------------------------------------
  // APB clocking blocks 
  //-----------------------------------------------------------------------

  /**
   * Clocking block that defines the APB master Interface
   */
   clocking apb_master_cb @(posedge clk);

     default input #apb_setup_time output #apb_hold_time;
     input                  rst_n;

     output                 paddr;
     output                 pwrite;
     output                 psel;
     output                 penable;
     output                 pwdata;
     output                 pprot;
     output                 pstrb;

     input                  prdata;
     input                  pready;
     input                  pslverr;
     input                  IRQ_c;
     input                  IRQ_uc;
     input                  TransActv;

  endclocking : apb_master_cb

   clocking apb_monitor_cb @(posedge clk);

     default input #apb_setup_time;
     input                  rst_n;

     input                 paddr;
     input                 pwrite;
     input                 psel;
     input                 penable;
     input                 pwdata;
     input                 pprot;
     input                 pstrb;

     input                  prdata;
     input                  pready;
     input                  pslverr;
     input                  IRQ_c;
     input                  IRQ_uc;
     input                  TransActv;

  endclocking : apb_monitor_cb

  modport apb_master (

     input    rst_n,
     output   paddr,
     output   pwrite,
     output   psel,
     output   penable,
     output   pwdata,
     output   pprot,
     output   pstrb,
     input    prdata,
     input    pready,
     input    pslverr,
     input    IRQ_c,
     input    IRQ_uc,
     input    TransActv,

     import  async_reset_apb_channel,
             drive_apb_channel,
             drive_apb_channel_nonvalid,
             //drive_apb_master_channel_ready,
              //drive_apb_slave_channel_nonvalid,
             collect_apb_channel,
             collect_apb_req_channel
  );

 modport apb_monitor (

     input   rst_n,
     input   paddr,
     input   pwrite,
     input   psel,
     input   penable,
     input   pwdata,
     input   pprot,
     input   pstrb,
     input   prdata,
     input   pready,
     input   pslverr,
     input   IRQ_c,
     input   IRQ_uc,
     input   TransActv,

     import  collect_apb_channel,
             collect_apb_req_channel
  );

  //----------------------------------------------------------------------- 
  // ASSERTS FOR READY
  //-----------------------------------------------------------------------

  //----------------------------------------------------------------------- 
  // Initial block where we vary speeds of the BFM over time 
  //----------------------------------------------------------------------- 


  //----------------------------------------------------------------------- 
  // Reset Apb channel
  //----------------------------------------------------------------------- 

  task automatic async_reset_apb_channel();
      apb_master_cb.paddr          <= 'bx;
      apb_master_cb.pwrite         <= 'b0;
      apb_master_cb.psel           <= 'b0;
      apb_master_cb.penable        <= 'b0;
      apb_master_cb.pwdata         <= 'b0;
      apb_master_cb.pprot          <= 'b0;
      apb_master_cb.pstrb          <= 'b0;
  endtask : async_reset_apb_channel

  //----------------------------------------------------------------------- 
  // Drive apb channel
  //----------------------------------------------------------------------- 

  task automatic drive_apb_channel(apb_pkt_t pkt, bit valid = 1);
  `ifndef USE_VIP_SNPS_APB
      apb_pkt_t m_pkt;
      m_pkt = new();
      m_pkt.copy(pkt);
      if (rst_n == 0) begin
          m_drv_mst_q = {};
          /*if (first_reset_seen) begin
              return;
          end*/
      end
     wait (rst_n == 1);
     //if (valid) begin
         @(apb_master_cb);
     //if (m_pkt.MCmd !== apb_mcmd_t'(IDLE)) begin
        m_drv_mst_q.push_back(m_pkt);
        ->e_drv_mst_q;
     //end
   `endif
  endtask : drive_apb_channel

  initial begin
  `ifndef USE_VIP_SNPS_APB
     int  m_dly;
     bit  done;
     time t_start_time;
     apb_pkt_t drv_pkt;
     #0; if (IS_IF_A_MONITOR === 0) begin // add #0 to catch the "parameter"
          forever begin
             // $display("%t: Checking queue size. Is %0d", $time, m_drv_mst_q.size());
              if (m_drv_mst_q.size() > 0) begin
                 drv_pkt = new();
                 drv_pkt = m_drv_mst_q.pop_front();
                 //m_dly = ($urandom_range(0,100) <= APB_MCMD_BURST_PCT) ? 0 : ($urandom_range(APB_MCMD_DELAY_MIN, APB_MCMD_DELAY_MAX));
                 m_dly = 0;
                 //was_scmdaccept_set_already = 1;
                 t_start_time            = $time;
                 done                    = 0;
                 do begin
                    if (m_dly > 0) begin
                       drive_apb_channel_nonvalid();
                       @(apb_master_cb);
                       if (rst_n == 0) begin
                          m_drv_mst_q = {};
                          break;
                       end
                       m_dly--;
                    end
                    else begin
                       apb_master_cb.paddr          <= drv_pkt.paddr;
                       apb_master_cb.pwrite         <= drv_pkt.pwrite;
                       apb_master_cb.psel           <= drv_pkt.psel;
                       if (drv_pkt.pwrite == apb_pwrite_t'(APB_WR)) begin
                          apb_master_cb.pwdata         <= drv_pkt.pwdata;
                          apb_master_cb.pstrb          <= 'b1111;
                       end
                       else begin
                          apb_master_cb.pstrb          <= 'b0;
                       end
                       if($test$plusargs("apb4_csr_privilege"))
                         apb_master_cb.pprot[0]          <= 'b1;
                       else
                         apb_master_cb.pprot[0]          <= 'b0;
                         //#Stimulus.FSYS.v3.6.APB4_debug_port_pslv_error
                       if($test$plusargs("apb4_csr_nonsecure"))
                         apb_master_cb.pprot[1]          <= 'b1;
                       else
                         apb_master_cb.pprot[1]          <= 'b0;
                       if($test$plusargs("apb4_csr_instruction"))
                         apb_master_cb.pprot[2]          <= 'b1;
                       else
                         apb_master_cb.pprot[2]          <= 'b0;
                       t_start_time            = $time;
                       @(apb_master_cb);
                       do begin
                           apb_master_cb.penable        <= apb_penable_t'(1);
                           @(apb_master_cb);
                       end while((apb_master_cb.pready === apb_pready_t'(0)) && (t_start_time !== $time)); // UNMATCHED !!
                       done = 1;
                       end
                       //else begin
                          //was_scmdaccept_set_already = 0;
                          //done = 0;
                       //end
                       if (!done) begin
                          @(apb_master_cb);
                       end
                  end while (!done);
              end // if (m_drv_mst_q.size() > 0)
              else begin
                 drive_apb_channel_nonvalid();
                 @(apb_master_cb);
                 /*if (rst_n == 0) begin
                  m_drv_mst_rd_addr_q = {};
                  end*/
                 if (m_drv_mst_q.size == 0) begin
                    @e_drv_mst_q;
                 end
              end
          end
      end
  `endif
  end // initial begin

  //-----------------------------------------------------------------------
  // Drive apb master channel nonvalid
  //-----------------------------------------------------------------------
  task automatic drive_apb_channel_nonvalid();
      apb_master_cb.paddr          <= 'bx;
      apb_master_cb.pwrite         <= 'b0;
      apb_master_cb.psel           <= 'b0;
      apb_master_cb.penable        <= 'b0;
      apb_master_cb.pwdata         <= 'bx;
      apb_master_cb.pprot          <= 'b0;
      apb_master_cb.pstrb          <= 'b0;
  endtask : drive_apb_channel_nonvalid

  //----------------------------------------------------------------------- 
  // Collect packet from apb slave channel - used by the driver task
  //----------------------------------------------------------------------- 
  
  task automatic collect_apb_channel(ref apb_pkt_t pkt);
      bit done = 0;
      time t_start_time;
      t_start_time            = $time;
      do begin
          @(apb_monitor_cb);
          if (rst_n == 0) begin
              return;
          end
          if ((apb_monitor_cb.pready==1) && (t_start_time !== $time)) 
          begin
             //#10;
             pkt.paddr        = apb_monitor_cb.paddr;
             pkt.prdata       = apb_monitor_cb.prdata;
             pkt.pwdata       = apb_monitor_cb.pwdata;
             pkt.psel         = apb_monitor_cb.psel;
             pkt.penable      = apb_monitor_cb.penable;
             pkt.pwrite       = apb_monitor_cb.pwrite;
             // TODO - NAVEEN - apb sqequence item needs to be updated to include the PPROT and PSTRB variables
             //pkt.pready       = apb_monitor_cb.pready;
             pkt.pslverr      = apb_monitor_cb.pslverr;
             done      = 1;
          end
      end while (!done);
  endtask : collect_apb_channel

  <% if ((!obj.CUSTOMER_ENV) || (obj.testBench == "fsc")) { %>
  //----------------------------------------------------------------------- 
  // Collect apb req channel - used by the monitor
  //----------------------------------------------------------------------- 

  task automatic collect_apb_req_channel(ref apb_pkt_t pkt);
      bit done = 0;
     time t_start_time;
     t_start_time            = $time;
      do begin
          @(apb_monitor_cb);
          if (rst_n == 0) begin
              return;
          end
          if(apb_monitor_cb.penable && apb_monitor_cb.pready) begin
              pkt.paddr   = apb_monitor_cb.paddr;
              pkt.prdata  = apb_monitor_cb.prdata;
              pkt.pwdata  = apb_monitor_cb.pwdata;
              pkt.psel    = apb_monitor_cb.psel;
              pkt.pwrite  = apb_monitor_cb.pwrite;
              pkt.pslverr = apb_monitor_cb.pslverr;
              done = 1'b1;
          end
      end while (!done);
  endtask : collect_apb_req_channel
<% } %>

endinterface
