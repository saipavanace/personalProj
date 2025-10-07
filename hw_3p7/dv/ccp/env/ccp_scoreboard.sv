///////////////////////////////////////////////////////////////////////////////
//                                                                           //  
// File         :   ccp_scoreboard.sv                                        //
// Description  :   CCP checker.                                             //
//                  I have adopted the aiu checker coding style where        //
//                  single packets stores all the information.               //
//                                                                           //
// Notes        :                                                            //
//                  Read_hit data read be postponed till wr_hit is finished. //
//                  burst_type is always WRAP
//                                                                           //
// Revision     :                                                            //
//                                                                           //
//                                                                           //
// Browse Code using this section                                            //
// Section1     :   CCP Cache Scoreboard                                     //
// Section2     :   Cache Model                                              //
// Section3     :   Helper code                                              //
//                                                                           //
//                                                                           // 
///////////////////////////////////////////////////////////////////////////////

/*
==============================================================================

Things I want to improve. 

1. Address and data should be one defined at one place and used repeatively. 
   Currently the ctrl_pkt has address fill_pkt has address_field. Similar issue
   exists on the data side.



=============================================================================== 
*/

//class coverage_cov;
//
//  covergroup ccp_cg;
//  
//   nack_condition:coverpoint {cov_txn.nackuce,cov_txn.nack,cov_txn.nackce,cov_txn.nacknoalloc} {
//                   bins uncorrerr_nocorrerr = {4'b1???};
//                   bins flush_p0_p1         = {4'b01??};
//                   bins retry               = {4'b001?};
//                   bins no_alloc            = {4'b0001};
//                   ignore_bins ignore_value = default;
//                   } 
//
//   opcode_for_data:coverpoint {cov_txn.evictvld,cov_txn.rd_data,cov_txn.wr_data,cov_txn.rsp_evict_sel,cov_txn.bypass} {
//                   bins NOP                     = {5'b?0000};
//                   bins RSP_BYPASS              = {5'b?0001};
//                   bins EVICT_BYPASS            = {5'b?0011};
//                   bins WRITE                   = {5'b?0100,5'b?0110};
//                   bins WRITE_RSP_BYPASS        = {5'b?0101};
//                   bins WRITE_EVICT_BYPASS      = {5'b?0111};
//                   bins READ_RSP_PORT           = {5'b01000};
//                   bins READ_EVICT_PORT         = {5'b110?0};
//                   bins RD_EVICT_WR_BYPASS_RSP  = {5'b11001};
//                   bins WRITE_RD_EVICT          = {5'b111?0};
//                   illegal_bins illegal_op      = {5'b?0010,5'b010?,5'b011?0,5'b11101,5'b11111};
//                   ignore_bins ignore_value = default;
//                   } 
//
//   back_to_back_pipeline_scenarions_for_same_addr:coverpoint {btob_wr_rd} {
//                   bins WR_HIT_RD_HIT_RD_HIT = {2'b00};
//                   bins WR_HIT_EVICT         = {4'b01};
//                   bins WR_HIT_BYPASS_EVICT  = {4'b11};
//                   ignore_bins ignore_value = default;
//                   } 
//   poision_bit :coverpoint {cov_txn.poision} {
//                   bins poisioned      = {1'b0};
//                   bins not_poisioned  = {1'b1};
//                   } 
//  endgroup
//
//  function new(string name = "coverage_cov");
//  endfunction:new 
//
//endclass:coverage_cov

`uvm_analysis_imp_decl( _ccp_wr_data_chnl   )
`uvm_analysis_imp_decl( _ccp_ctrl_chnl      )
`uvm_analysis_imp_decl( _ccp_fill_ctrl_chnl )
`uvm_analysis_imp_decl( _ccp_fill_data_chnl )
`uvm_analysis_imp_decl( _ccp_rd_rsp_chnl    )
`uvm_analysis_imp_decl( _ccp_evict_chnl     )



////////////////////////////////////////////////////////////////////////////////
//                                                                            
//          CCP Scoreboard                                               
//                                                                            
// Section1: Code implements the checks required to verify CCP.              
//
////////////////////////////////////////////////////////////////////////////////

class ccp_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ccp_scoreboard)


    //Analsis Ports
    uvm_analysis_imp_ccp_wr_data_chnl   # ( ccp_wr_data_pkt_t  , ccp_scoreboard) ccp_wr_data_port;
    uvm_analysis_imp_ccp_ctrl_chnl      # ( ccp_ctrl_pkt_t     , ccp_scoreboard) ccp_ctrl_port;
    uvm_analysis_imp_ccp_fill_ctrl_chnl # ( ccp_fillctrl_pkt_t , ccp_scoreboard) ccp_fill_ctrl_port;
    uvm_analysis_imp_ccp_fill_data_chnl # ( ccp_filldata_pkt_t , ccp_scoreboard) ccp_fill_data_port;
    uvm_analysis_imp_ccp_rd_rsp_chnl    # ( ccp_rd_rsp_pkt_t   , ccp_scoreboard) ccp_rd_rsp_port;
    uvm_analysis_imp_ccp_evict_chnl     # ( ccp_evict_pkt_t    , ccp_scoreboard) ccp_evict_port;


    //Common Variables
    string spkt;
    string snpFilterType;
    bit [31:0] scb_txn_id;
   <% /*if(obj.useCmc) { */%>
    localparam N_CCP_SETS   = <%=obj.nSets%>;
    localparam N_CCP_WAYS   = <%=obj.nWays%>;
    parameter SYS_wSysCacheline = <%=obj.wCacheLineOffset%>;

    bit sp_enabled;
    int NO_OF_SP_WAYS=0;
    ccp_ctrlop_addr_t lower_sp_addr, upper_sp_addr;
   <%/* } */%>
/*
   <% if(obj.useCache) { %>
    localparam N_CCP_SETS   = <%=obj.AiuInfo[obj.Id].ccpParams.nSets%>;
    localparam N_CCP_WAYS   = <%=obj.AiuInfo[obj.Id].ccpParams.nWays%>;
    parameter SYS_wSysCacheline = <%=obj.wCacheLineOffset%>;

    bit sp_enabled;
    int NO_OF_SP_WAYS=0;
    ccp_ctrlop_addr_t lower_sp_addr, upper_sp_addr;
   <% } %>
*/
    int        exp_dout_cnt;
    int        dout_cnt;
    int        dataIndex;
    int        dataWay;

    //Cache Model
    ccp_cache_model m_ccpCacheModel;
    ccpCacheLine    evicted_cachelines[$];

    //Main queue
    ccp_scb_txn btt_q[$];
    bit security_q[$];
    ccp_filldata_pkt_t  fill_data_q[$];

    //General Queues
    int fq_b[$];

    //Cache Model access Queue
    ccp_scb_txn op_q  [N_DATA_BANK][$];
    ccp_scb_txn data_q[N_DATA_BANK][$];

    // Alloc state
    ccp_cachestate_enum_t allocState; 

    // fill pending
    bit fillpending; 

    //Constructor
    function new(string name = "ccp_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        m_ccpCacheModel = new; 
        evicted_cachelines = {};
        //m_ioCacheModel.gen_dummy_cache();
    endfunction : new

    //Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        //Impl port
        ccp_wr_data_port   = new("ccp_wr_data_port", this);
        ccp_ctrl_port      = new("ccp_ctrl_port", this);
        ccp_fill_ctrl_port = new("ccp_fill_ctrl_port", this);
        ccp_fill_data_port = new("ccp_fill_data_port", this);
        ccp_rd_rsp_port    = new("ccp_rd_rsp_port", this);
        ccp_evict_port     = new("ccp_evict_port", this);
        
    endfunction : build_phase


    //================================
    // Run Phase & main function
    //================================
    task run_phase(uvm_phase phase);
    endtask


    //Extern task/functions
    //Ports write functions
    extern function void write_ccp_wr_data_chnl   ( ccp_wr_data_pkt_t    m_pkt  ) ;
    extern function void write_ccp_ctrl_chnl      ( ccp_ctrl_pkt_t       m_pkt  ) ;
    extern function void write_ccp_fill_ctrl_chnl ( ccp_fillctrl_pkt_t   m_pkt  ) ;
    extern function void write_ccp_fill_data_chnl ( ccp_filldata_pkt_t   m_pkt  ) ;
    extern function void write_ccp_rd_rsp_chnl    ( ccp_rd_rsp_pkt_t     m_pkt  ) ;
    extern function void write_ccp_evict_chnl     ( ccp_evict_pkt_t      m_pkt  ) ;


`ifndef INCA
//    extern task data_pipeline_model(int q_id);
`endif

    //Utility functions
    extern function void store_read_cacheline_data ( ref ccp_scb_txn ccp_pkt) ;
    extern function void give_read_cacheline_data  ( ref ccp_scb_txn ccp_pkt,input bit port_sel = 0) ;
    extern function void give_read_evicted_cacheline_data  ( ref ccp_scb_txn ccp_pkt,input bit port_sel = 0) ;
    extern function void give_evict_cacheline_data(ref ccp_scb_txn ccp_pkt,input bit port_sel = 1,int dataIndex,int dataWay, bit isEvicted=0);
    extern function void merge_write_data          ( ref ccp_scb_txn ccp_pkt ) ;
    extern function void merge_write_data_evicted  ( ref ccp_scb_txn ccp_pkt ) ;
    extern function void delete_btt_entry          ( int indx                ) ;
    extern function void delete_evicted_cacheline  ( ref ccp_scb_txn ccp_pkt) ;
    extern function int  find_oldest_txn_in_btt_q  ( int m_tmp_q[$]          ) ;
    extern function ccp_ctrlop_addr_t cl_aligned(ccp_ctrlop_addr_t addr);

   function void check_phase(uvm_phase phase);
`ifndef INCA
      if(btt_q.size()>0)begin
        uvm_report_info("<%=obj.BlockId%>:CCP-SCB", $sformatf("========pending txn :%d ======================",btt_q.size()),UVM_MEDIUM);
        uvm_report_info("<%=obj.BlockId%>:CCP-SCB", $sformatf("==========================================================="),UVM_MEDIUM);
         print_queues();
       `uvm_error("<%=obj.BlockId%>:CCP-SCB", $sformatf("pending txn :%d ",btt_q.size()));
      end
`endif
   endfunction:check_phase

   function void print_queues();
`ifndef INCA
        foreach(btt_q[i])begin
         btt_q[i].print_me();
      end
`endif
   endfunction:print_queues
endclass



////////////////////////////////////////////////////////////////////////////////
//                                                                            
//          CCP Write function for Analysis ports
//                                                                            
// Section2: Code implements all the write function for the analysis ports. 
//
////////////////////////////////////////////////////////////////////////////////




//=========================================================================
// Function: write_ccp_ctrl_chnl 
// Purpose: 
// 
// 
//=========================================================================

function void ccp_scoreboard::write_ccp_ctrl_chnl(ccp_ctrl_pkt_t m_pkt);
`ifndef INCA
    ccp_scb_txn            cpy_pkt;
    ccp_scb_txn            evict_entry;
    ccp_ctrlop_addr_t      m_ccp_addr;
    ccp_ctrlop_addr_t      m_ccp_filladdr;
    ccp_ctrl_pkt_t         m_ctrlop_pkt;
    ccp_ctrl_pkt_t         m_ctrlop_pkt_tmp;
    ccp_cache_rdrsp_data_t data_a[];
    bit                    allocate;
    bit                    evict;
    bit                    isWrTh = 0;
    int                    ccp_index;
    int                    ccp_addr_tag;
    ccpCacheLine           m_evict_cacheline;
    ccp_cachestate_enum_t  m_ccp_cache_state;
    bit                    security;
    bit                    cpy_dataErrorPerBeat[];
    int                    firstAvailWay;
    int                    wayn;
    int                    fq[$];
    int                    fq_tmp[$];
    int                    fq_w[$];
    int                    fq_fillwayinflight[$];
    int                    fq_fill[$];
    int                    fq_evict[$];
    int                    fq_fillp[$];
    int                    fq_idx;
    int                    sq[$];

    //Learn further about cancel & nack from Boon & modify if necessary
    if (m_pkt.nack) begin
      `uvm_info("<%=obj.BlockId_%>:CCP-SCB:write_ccp_ctrl_chnl", $sformatf("Ignoring this packet because nack is set"), UVM_MEDIUM)
       return;
    end
    
    m_ctrlop_pkt_tmp = new();
    m_ctrlop_pkt     = new();
    $cast(m_ctrlop_pkt_tmp,m_pkt); 
    m_ctrlop_pkt.copy(m_ctrlop_pkt_tmp);

//----------------------------------------------------------------------------------------------------------------------------
// AS per Parimal Discusion: if CCP evicted a cacheline and allocate the way of evicted cacheline to new addr, if fill of 
// allocated cacheline is pending,CCP  again will give HIT for evicted cacheline till fill of allocated cacheline complete, 
// NCBU/DMI has to ignore this false HIT
//--------------------------------------------------------------------------------------------------------------------------
   <%/* if(obj.useCmc) { */%>
    if ((m_ctrlop_pkt.addr >= lower_sp_addr) && (m_ctrlop_pkt.addr <= upper_sp_addr) && sp_enabled) begin
      `uvm_info("<%=obj.BlockId_%>:CCP-SCB:write_ccp_ctrl_chnl", $sformatf("it's a sp txn on ccp ctrl chnl"), UVM_MEDIUM)
      return;
    end
   <%/* } */%>

    fq_fillwayinflight = btt_q.find_index() with ((item.ccp_index == CcpCalcIndex(m_ctrlop_pkt.addr)) && 
                                       (item.isFillReqd == 1'b1) && 
                                       (item.fillwayn == m_ctrlop_pkt.wayn));

    if(fq_fillwayinflight.size()>0) begin
     `uvm_info("<%=obj.BlockId%>:CCP-SCB:write_ccp_ctrl_chnl", $sformatf("fill way in flight ignore the false HIT index :0%0x fillwayn :0%0x",btt_q[fq_fillwayinflight[0]].ccp_index,btt_q[fq_fillwayinflight[0]].fillwayn),UVM_MEDIUM);
    end 

      cpy_pkt = new();
      cpy_pkt.setup_ccp_ctrl_pkt(m_ctrlop_pkt,agent_id);
     
    if(m_ccpCacheModel.isCacheLineValid(cl_aligned(cpy_pkt.ccp_addr),cpy_pkt.security)) begin
       m_ccpCacheModel.give_state(.ccpAddr(cl_aligned(cpy_pkt.ccp_addr)),  
                                 .ccpState(m_ccp_cache_state),
                                 .security(cpy_pkt.security));

       m_ccpCacheModel.give_wayIndex(.ccpAddr(cl_aligned(cpy_pkt.ccp_addr)),
                                    .security(cpy_pkt.security),
                                    .way(dataWay),
                                    .Index(dataIndex));

       if($clog2(cpy_pkt.m_ccp_ctrl_pkt.hitwayn) != dataWay && cpy_pkt.m_ccp_ctrl_pkt.cachevld) begin
           `uvm_error("<%=obj.BlockId%>:CCP-SCB",$psprintf("Hit way vector Mismatch Exp:%0h but Got:%0h",
                     dataWay, $clog2(cpy_pkt.m_ccp_ctrl_pkt.hitwayn)))
       end

       if(cpy_pkt.m_ccp_ctrl_pkt.currstate != m_ccp_cache_state && cpy_pkt.m_ccp_ctrl_pkt.cachevld && !cpy_pkt.m_ccp_ctrl_pkt.waystale_vec[dataWay]) begin
           `uvm_error("<%=obj.BlockId%>:CCP-SCB",$psprintf("Current State Mismatch Exp:%0h but Got:%0h",
                     m_ccp_cache_state,cpy_pkt.m_ccp_ctrl_pkt.currstate))
       end

       if(cpy_pkt.m_ccp_ctrl_pkt.currstate != IX && cpy_pkt.m_ccp_ctrl_pkt.cachevld && cpy_pkt.m_ccp_ctrl_pkt.waystale_vec[dataWay]) begin
           `uvm_error("<%=obj.BlockId%>:CCP-SCB",$psprintf("Current State Mismatch Exp:IX but Got:%0h",
                     cpy_pkt.m_ccp_ctrl_pkt.currstate))
       end
    end else begin
       if(cpy_pkt.m_ccp_ctrl_pkt.currstate != IX && cpy_pkt.m_ccp_ctrl_pkt.cachevld) begin
           `uvm_error("<%=obj.BlockId%>:CCP-SCB",$psprintf("Current State Mismatch Exp:IX but Got:%0h",
                     cpy_pkt.m_ccp_ctrl_pkt.currstate))
       end
    end

    // update nru vector based on rp_update signal
    if((m_ccpCacheModel.isCacheLineValid(cl_aligned(cpy_pkt.ccp_addr),cpy_pkt.security) &&
       (cpy_pkt.m_ccp_ctrl_pkt.currstate !== IX))) begin
      if(cpy_pkt.m_ccp_ctrl_pkt.tagstateup && (cpy_pkt.m_ccp_ctrl_pkt.state == IX)) begin
        if(cpy_pkt.m_ccp_ctrl_pkt.rp_update)
            `uvm_error("<%=obj.BlockId%>:CCP-SCB",$psprintf("rp_update should not assert in case state is being updated to invalid"));
      end else begin
        if(cpy_pkt.m_ccp_ctrl_pkt.rp_update) begin
          m_ccpCacheModel.update_nru(cl_aligned(cpy_pkt.ccp_addr),cpy_pkt.security);
        end
      end
    end

   `uvm_info("<%=obj.BlockId%>:CCP-SCB:write_ccp_ctrl_chnl", $sformatf("ccp_ctrl_pkt: %s ",cpy_pkt.m_ccp_ctrl_pkt.sprint_pkt()), UVM_MEDIUM);

   <% if(obj.Block === "dmi") { %>                           
    if(cpy_pkt.isBypass || cpy_pkt.isRead || cpy_pkt.isWrite || cpy_pkt.isFillReqd || cpy_pkt.isEvict || cpy_pkt.isflush) begin
   <% } else { %>
    if((cpy_pkt.isBypass || cpy_pkt.isRead || cpy_pkt.isWrite || cpy_pkt.isFillReqd || cpy_pkt.isEvict || cpy_pkt.isSnoop || cpy_pkt.isflush)) begin
   <% } %>
    cpy_pkt.scb_txn_id = scb_txn_id++;
    fq_fill = btt_q.find_index() with ((cl_aligned(item.ccp_addr) == cl_aligned(cpy_pkt.ccp_addr)) && 
                                       (item.isFillReqd == 1) &&  (cpy_pkt.isFillReqd == 1) && 
                                       (item.security == cpy_pkt.security));
    if(fq_fill.size()>1) begin
      print_queues();
      `uvm_error("<%=obj.BlockId%>:CCP-SCB:write_ccp_ctrl_chnl", $sformatf(" two fill to same addr pending ccp_addr:0x%0x ",cpy_pkt.ccp_addr));
    end 

    //NF: To avoid end of test pending txn error. Don't add 2 back to back ccp_ctrl_pkts to queue
    if (fq_fill.size() == 0)
       btt_q.push_back(cpy_pkt);
    else begin
       btt_q.delete(fq_fill[0]);
       btt_q.push_back(cpy_pkt);
    end

    //Search the BTT queue
    fq = btt_q.find_index() with ((cl_aligned(item.ccp_addr) == cl_aligned(cpy_pkt.ccp_addr)) && 
                                  (item.security == cpy_pkt.security)); 
     fq_idx = fq.size()-1; 
     `uvm_info("<%=obj.BlockId%>:CCP-SCB:write_ccp_ctrl_chnl",$sformatf(" size of btt_q queue :%d fp :%d",btt_q.size(),fq.size()),UVM_HIGH);
     // btt_q[fq[fq_idx]].print_me();

     //Local CCP address
     m_ccp_addr = cl_aligned(btt_q[fq[fq_idx]].ccp_addr);
     security   = btt_q[fq[fq_idx]].security;

     wayn       = btt_q[fq[fq_idx]].fillwayn;
     evict      = 1;
     allocState = m_ctrlop_pkt.state;
     `uvm_info("<%=obj.BlockId%>:CCP-SCB:write_ccp_ctrl_chnl",$sformatf("m_ccp_addr :%0x btt_q[fq[fq_idx]].ccp_addr :%0x",
                                                                        m_ccp_addr,btt_q[fq[fq_idx]].ccp_addr),UVM_MEDIUM);

     //Calculate the Index and Tag
     ccp_addr_tag = mapAddrToCCPTag(m_ccp_addr);
     ccp_addr_tag = {security,ccp_addr_tag};
     //ccp_index =  addrMgrConst::get_set_index(m_ccp_addr,agent_id);
     ccp_index =  CcpCalcIndex(m_ccp_addr);
    
     `uvm_info("<%=obj.BlockId%>:CCP-SCB:write_ccp_ctrl_chnl",$sformatf("m_ccp_addr :%0x security :%0b ccp_addr_tag :%0x ccp_index :%0x isCacheIndexValid :%b isCacheLineValid :%b",
                                                                        m_ccp_addr,security,ccp_addr_tag,ccp_index,m_ccpCacheModel.isCacheIndexValid(m_ccp_addr),
                                                                        m_ccpCacheModel.isCacheLineValid(m_ccp_addr,security)),UVM_MEDIUM); 
     
     //Check if this is the first time I am getting this index.
     //I only generate a cache structure for that index when I 
     //get a address related to a particular index.
     if(!(m_ccpCacheModel.isCacheIndexValid(m_ccp_addr)))begin
       m_ccpCacheModel.initCacheIndex(m_ccp_addr); 
     end

     if(btt_q[fq[fq_idx]].isBypass && !btt_q[fq[fq_idx]].isRead && !btt_q[fq[fq_idx]].isWrite) begin
       btt_q[fq[fq_idx]].m_op_cmd_type = BYPASS;
       exp_dout_cnt++;
     end else begin
       //Cache Hit
      <% if(obj.Block !== "dmi") { %>                           
       fq_fillp = {};
       fq_fillp = btt_q.find_index() with (cl_aligned(item.ccp_addr) == cl_aligned(btt_q[fq[fq_idx]].ccp_addr) &&
                                           item.security             == btt_q[fq[fq_idx]].security && 
                                           btt_q[fq[fq_idx]].isSnoop &&
                                           btt_q[fq[fq_idx]].isRead  &&
                                           item.isWriteHitUpgrade);

       if(fq_fillp.size()>0)begin
        m_ccpCacheModel.set_pending_bit(cl_aligned(btt_q[fq_fillp[0]].ccp_addr),1'b0,btt_q[fq_fillp[0]].security);
       end
      <% } %>

       if(m_ccpCacheModel.isCacheLineValid(m_ccp_addr,security)) begin
           fq_w      = {};
           fq_evict  = {};

           if(cpy_pkt.m_ccp_ctrl_pkt.evictvld)begin
             fq_w     = btt_q.find_index() with ((cl_aligned(item.ccp_addr) == cl_aligned(cpy_pkt.m_ccp_ctrl_pkt.evictaddr)) && 
                                               ((item.isWrite == 1'b1 && !item.isBypass) && !item.isWriteDataRcvd) &&
                                               (item.security == cpy_pkt.m_ccp_ctrl_pkt.evictsecurity) && (item.t_scb_txn < $time)); 

             fq_evict = btt_q.find_index() with ((cl_aligned(item.ccp_addr) == cl_aligned(cpy_pkt.m_ccp_ctrl_pkt.evictaddr)) && 
                                               (((item.isWrite == 1'b1 && item.isBypass) ||(!item.isWrite == 1'b1 && item.isBypass) ) && !item.isWriteDataRcvd) &&
                                               (item.security == cpy_pkt.m_ccp_ctrl_pkt.evictsecurity) && (item.t_scb_txn < $time)); 
           end
           else begin
             fq_w     = btt_q.find_index() with ((cl_aligned(item.ccp_addr) == cl_aligned(m_ccp_addr)) && 
                                                 (item.security == security) &&
                                                 (( item.isWrite == 1'b1 && !item.isBypass) && !item.isWriteDataRcvd) &&
                                                 (item.t_scb_txn < $time));
 
             fq_evict = btt_q.find_index() with ((cl_aligned(item.ccp_addr) == cl_aligned(m_ccp_addr)) && 
                                                 (item.security == security) &&
                                                 (((item.isWrite == 1'b1 && item.isBypass) ||(!item.isWrite == 1'b1 && item.isBypass)) && !item.isWriteDataRcvd) &&
                                                 (item.t_scb_txn < $time)); 
           end

         <% if(obj.Block === "dmi") { %>                           
          if((!btt_q[fq[fq_idx]].isMntop) ||
             (btt_q[fq[fq_idx]].m_ccp_ctrl_pkt.msgType == 'h5c && btt_q[fq[fq_idx]].m_ccp_ctrl_pkt.currstate != IX)) begin
         <% } else { %>
          if(btt_q[fq[fq_idx]].isSnoop && btt_q[fq[fq_idx]].m_ccp_ctrl_pkt.state != IX ) begin
         <% } %>
            if(cpy_pkt.m_ccp_ctrl_pkt.tagstateup && (cpy_pkt.m_ccp_ctrl_pkt.state != IX)) begin
              m_ccpCacheModel.modify_state(m_ccp_addr,cpy_pkt.m_ccp_ctrl_pkt.state,security);
            end 
          end

          btt_q[fq[fq_idx]].isHit = 1'b1;

          if(btt_q[fq[fq_idx]].isRead) begin 
             btt_q[fq[fq_idx]].m_op_cmd_type = READ;

             fq_w = {};
             fq_w = btt_q.find_index() with (cl_aligned(item.ccp_addr) == cl_aligned(btt_q[fq[0]].ccp_addr) &&
                                             item.security == btt_q[fq[0]].security &&
                                             (item.isWrite && !item.isWriteDataRcvd));

             if(fq_w.size() >0)begin
               `uvm_info(":1",$sformatf("fq_w[0] :%d fq[0] :%d",fq_w[0],fq_idx),UVM_MEDIUM); 
             end

             // If there is any write pending, then don't read now as you'll get stale data, will read when wr data reaches wr data chnl
             if((fq_w.size() > 0) && btt_q[fq[fq_idx]].t_scb_txn > btt_q[fq_w[0]].t_scb_txn)begin
               `uvm_info(":2",$sformatf("fq_w[0] :%t fq[0] :%t",btt_q[fq_w[0]].t_scb_txn,btt_q[fq[fq_idx]].t_scb_txn),UVM_MEDIUM); 
               btt_q[fq[fq_idx]].isWritePending = 1; 
             end else begin
               if(btt_q[fq[fq_idx]].isBypassrdrsp ) begin
                 give_read_cacheline_data(btt_q[fq[fq_idx]],0);
               end else begin
                 give_read_cacheline_data(btt_q[fq[fq_idx]],1);
               end 
              <% if(obj.Block !== "dmi") { %>                           
               if(fq_fillp.size()>0)begin
                 m_ccpCacheModel.set_pending_bit(cl_aligned(btt_q[fq_fillp[0]].ccp_addr),1'b1,btt_q[fq_fillp[0]].security);
               end
              <% } %>
             end

             if(cpy_pkt.m_ccp_ctrl_pkt.tagstateup && cpy_pkt.m_ccp_ctrl_pkt.state == IX && !fq_fillp.size())begin
               if(fq_w.size()>0)begin
                   `uvm_info("DMI0-CCP_SCB",$sformatf("DEBUG1, setting isCacheInvld high, fq_w.size = %0d ",fq_w.size()),UVM_MEDIUM);
                   btt_q[fq_w[fq_w.size()-1]].print_debug();
                   btt_q[fq_w[fq_w.size()-1]].isCacheInvld = 1;
                   for (int i=0; i < fq_w.size(); i++) begin
                      btt_q[fq_w[i]].isEvicted = 1;
                   end
                   btt_q[fq_w[fq_w.size()-1]].DeleteCl = (cpy_pkt.m_ccp_ctrl_pkt.currstate == UD) && cpy_pkt.port_sel;
               end

               // setway_debug is high means it is a maint op and related to set-way
               if (cpy_pkt.m_ccp_ctrl_pkt.setway_debug) begin
                  cpy_pkt.ccp_addr = m_ccpCacheModel.ccpCacheSet[ccp_index][cpy_pkt.m_ccp_ctrl_pkt.mntwayn].addr;
                  cpy_pkt.security = m_ccpCacheModel.ccpCacheSet[ccp_index][cpy_pkt.m_ccp_ctrl_pkt.mntwayn].security;
                  cpy_pkt.m_ccp_ctrl_pkt.currstate = m_ccpCacheModel.ccpCacheSet[ccp_index][cpy_pkt.m_ccp_ctrl_pkt.mntwayn].state;
                  cpy_pkt.m_ccp_ctrl_pkt.hitwayn = (2**cpy_pkt.m_ccp_ctrl_pkt.mntwayn);
                  m_ccp_addr = cl_aligned(cpy_pkt.ccp_addr);
                  btt_q[fq[fq_idx]].hitwayn = cpy_pkt.m_ccp_ctrl_pkt.mntwayn;
               end

               if ((cpy_pkt.m_ccp_ctrl_pkt.currstate == UD) && cpy_pkt.port_sel) begin
                  evict_entry = new();
                  evict_entry.t_scb_txn = $time;
                  evict_entry.isBypassevict  = 1;
                  evict_entry.isEvict        = 1;
                  evict_entry.m_ccp_ctrl_pkt = new();
                  evict_entry.m_ccp_ctrl_pkt = cpy_pkt.m_ccp_ctrl_pkt;
                  evict_entry.evict_addr = cpy_pkt.ccp_addr;
                  evict_entry.evict_security = cpy_pkt.security;
                  evict_entry.ccp_index = ccp_index;
                  evict_entry.fillwayn = $clog2(cpy_pkt.m_ccp_ctrl_pkt.hitwayn);
                  give_evict_cacheline_data(evict_entry,1,btt_q[fq[fq_idx]].ccp_index,btt_q[fq[fq_idx]].hitwayn,0);
                  if (fq_w.size() == 0) evict_entry.isEvictDataAdded = 1;
                  btt_q.push_back(evict_entry);
                  btt_q[fq[fq_idx]].isBypassevict  = 0;
                  btt_q[fq[fq_idx]].isEvict  = 0;
                  btt_q.delete(fq[fq_idx]);
               end
               m_ccpCacheModel.copy_cacheline(m_ccp_addr,
                                              security,
                                              m_evict_cacheline
                                              );
               if (fq_w.size() > 0) begin
                  `uvm_info("", $sformatf("pushing entry in evicted_q"), UVM_MEDIUM);
                 // m_evict_cacheline.print();
                  evicted_cachelines.push_back(m_evict_cacheline);
               end
               m_ccpCacheModel.delete_cacheline(cl_aligned(m_ccp_addr),security);
             end
          end 
          else if(btt_q[fq[fq_idx]].isWrite && btt_q[fq[fq_idx]].isBypass) begin
             btt_q[fq[fq_idx]].m_op_cmd_type = WRITE_HIT_BYPASS;
             exp_dout_cnt++;
             if(cpy_pkt.m_ccp_ctrl_pkt.tagstateup && cpy_pkt.m_ccp_ctrl_pkt.state == IX)begin
                //Local CCP address
                m_ccp_addr = cl_aligned(cpy_pkt.ccp_addr);
                security   = cpy_pkt.security;
                fq_w = {};
                fq_w = btt_q.find_index() with (cl_aligned(item.ccp_addr) == cl_aligned(btt_q[fq[0]].ccp_addr) &&
                                                item.security == btt_q[fq[0]].security &&
                                                (item.isWrite && !item.isWriteDataRcvd));
                if(fq_w.size()>0)begin
                   `uvm_info("DMI0-CCP_SCB",$sformatf("DEBUG1, setting isCacheInvld high, fq_w.size = %0d ",fq_w.size()),UVM_MEDIUM);
                   btt_q[fq_w[fq_w.size()-1]].print_debug();
                   btt_q[fq_w[fq_w.size()-1]].isCacheInvld = 1;
                   for (int i=0; i < fq_w.size(); i++) begin
                      btt_q[fq_w[i]].isEvicted = 1;
                   end
                end
          
                m_ccpCacheModel.copy_cacheline(m_ccp_addr,
                                               security,
                                               m_evict_cacheline
                                               );
                if (fq_w.size() > 0) begin
                   `uvm_info("", $sformatf("pushing entry in evicted_q"), UVM_MEDIUM);
                 //  m_evict_cacheline.print();
                   evicted_cachelines.push_back(m_evict_cacheline);
                end
                m_ccpCacheModel.delete_cacheline(cl_aligned(m_ccp_addr),security);
             end
          end 
          else if(btt_q[fq[fq_idx]].isWrite) begin
            btt_q[fq[fq_idx]].m_op_cmd_type = WRITE_HIT;
            if(cpy_pkt.m_ccp_ctrl_pkt.tagstateup && (cpy_pkt.m_ccp_ctrl_pkt.state != IX)) begin
               m_ccpCacheModel.modify_state(m_ccp_addr,cpy_pkt.m_ccp_ctrl_pkt.state,security);
            end
          end
          else if(btt_q[fq[fq_idx]].isWriteHitUpgrade)begin
               m_ccpCacheModel.set_pending_bit(cl_aligned(btt_q[fq[fq_idx]].ccp_addr),1'b1,btt_q[fq[fq_idx]].security);
          end
          else if(btt_q[fq[fq_idx]].m_ccp_ctrl_pkt.tagstateup && btt_q[fq[fq_idx]].m_ccp_ctrl_pkt.state == IX &&  (btt_q[fq[fq_idx]].isSnoop || btt_q[fq[fq_idx]].isflush))begin
               if(fq_w.size()>0)begin
                 foreach(fq_w[i])begin
                     btt_q[fq_w[i]].isdropped = 1;
                 end
                 if(!fq_evict.size())begin
                   m_ccpCacheModel.delete_cacheline(cl_aligned(m_ccp_addr),security);
                 end
               end
   
               if(fq_evict.size()>0)begin
                 if(btt_q[fq_evict[fq_evict.size()-1]].isWrTh)begin
                   btt_q[fq_evict[fq_evict.size()-1]].isCacheInvld = 1;
                 end
                 else begin
                   m_ccpCacheModel.delete_cacheline(cl_aligned(m_ccp_addr),security);
                 end
               end
               
               if(!fq_evict.size() && !fq_w.size())begin
                   m_ccpCacheModel.delete_cacheline(cl_aligned(m_ccp_addr),security);
               end
   
                 btt_q.delete(fq[fq_idx]); 
          end
          else begin
               if(btt_q[fq[fq_idx]].isSnoop && !(btt_q[fq[fq_idx]].isWrite || btt_q[fq[fq_idx]].isRead))begin
                   btt_q.delete(fq[fq_idx]); 
               end
          end
       end 
       else begin
         //Cache Miss
         if(btt_q[fq[fq_idx]].isRead) begin 
            fq_w = {};
            fq_w = btt_q.find_index() with (cl_aligned(item.ccp_addr) == cl_aligned(btt_q[fq[0]].ccp_addr) && 
                                            item.security == btt_q[fq[0]].security && 
                                            (item.isWrite && !item.isWriteDataRcvd ));

            if(fq_w.size() >0 && btt_q[fq[fq_idx]].t_scb_txn > btt_q[fq_w[0]].t_scb_txn)begin
              `uvm_info(":2",$sformatf("fq_w[0] :%t fq[0] :%t",btt_q[fq_w[0]].t_scb_txn,btt_q[fq[fq_idx]].t_scb_txn),UVM_MEDIUM);
              btt_q[fq[fq_idx]].isWritePending = 1;
            end
         end

         if(cpy_pkt.m_ccp_ctrl_pkt.alloc) begin
           `uvm_info("",$sformatf("Index full :%0b",m_ccpCacheModel.isCacheIndexFull(m_ccp_addr, cpy_pkt.m_ccp_ctrl_pkt.waypbusy_vec)),UVM_MEDIUM);

           if(m_ccpCacheModel.isCacheIndexFull(m_ccp_addr, cpy_pkt.m_ccp_ctrl_pkt.waypbusy_vec)) begin
              foreach(m_ccpCacheModel.ccpCacheSet[ccp_index,i]) begin
               //   m_ccpCacheModel.ccpCacheSet[ccp_index][i].print();
              end
              fq_evict = btt_q.find_index() with ((cl_aligned(item.ccp_addr) == cl_aligned(cpy_pkt.m_ccp_ctrl_pkt.evictaddr)) && 
                                                  (item.isWrite == 1'b1 && !item.isWriteDataRcvd) &&
                                                  (item.security == cpy_pkt.m_ccp_ctrl_pkt.evictsecurity) && cpy_pkt.m_ccp_ctrl_pkt.evictvld); 
              //print_queues();
              if(fq_evict.size()>0) begin
                  `uvm_info("CCP-SCB",$sformatf("fq_evict.size = %0d evict_add :%0x evict seq :%0b ",fq_evict.size(),cpy_pkt.m_ccp_ctrl_pkt.evictaddr,cpy_pkt.m_ccp_ctrl_pkt.evictsecurity),UVM_MEDIUM);
                 if((cpy_pkt.m_ccp_ctrl_pkt.evictvld) || btt_q[fq_evict[0]].isWrTh ) begin
                   if(btt_q[fq_evict[0]].isWrTh)begin
                    isWrTh = 1;
                   end
                   for (int i=0; i<fq_evict.size(); i++) begin
                     btt_q[fq_evict[i]].isEvicted = cpy_pkt.m_ccp_ctrl_pkt.evictvld;
                   end
                   btt_q[fq_evict[fq_evict.size()-1]].DeleteCl = cpy_pkt.isEvict;
                 end
              end
          
              // m_ccpCacheModel.print_cache_model(); 
              if(cpy_pkt.m_ccp_ctrl_pkt.evictvld)begin
                if(!m_ccpCacheModel.isCacheLineValid(cpy_pkt.m_ccp_ctrl_pkt.evictaddr,cpy_pkt.m_ccp_ctrl_pkt.evictsecurity)) begin
                 `uvm_error("<%=obj.BlockId%>:CCP-SCB",$psprintf("Evicted cacheline for addr :%0x security :%0b not matching in cache model",
                             cpy_pkt.m_ccp_ctrl_pkt.evictaddr,cpy_pkt.m_ccp_ctrl_pkt.evictsecurity))
                end
              end

              if(evict && cpy_pkt.isEvict) begin 
                evict_entry = new();
                evict_entry.t_scb_txn = $time;
                evict_entry.isBypassevict  = 1;
                evict_entry.isEvict        = 1;
                evict_entry.m_ccp_ctrl_pkt = new();
                evict_entry.m_ccp_ctrl_pkt = cpy_pkt.m_ccp_ctrl_pkt;
                evict_entry.evict_addr = cpy_pkt.m_ccp_ctrl_pkt.evictaddr;
                evict_entry.ccp_index = ccp_index;
                evict_entry.fillwayn = cpy_pkt.m_ccp_ctrl_pkt.wayn;
                evict_entry.evict_security = cpy_pkt.m_ccp_ctrl_pkt.evictsecurity;
                give_evict_cacheline_data(evict_entry,1,btt_q[fq[fq_idx]].ccp_index,btt_q[fq[fq_idx]].fillwayn, 0);
                if (fq_evict.size() == 0) evict_entry.isEvictDataAdded = 1;
                btt_q.push_back(evict_entry);
                btt_q[fq[fq_idx]].isBypassevict  = 0;
                btt_q[fq[fq_idx]].isEvict  = 0;
              end
              //NF: Not fixing NRU policy related issues for now.
              //Use monitored wayn value to evict the cacheline
              cpy_pkt.m_ccp_ctrl_pkt.nru_counter = cpy_pkt.m_ccp_ctrl_pkt.wayn;

              m_ccpCacheModel.evict_cacheline(m_ccp_addr,
                                              evict,
                                              isWrTh, 
                                              cpy_pkt.m_ccp_ctrl_pkt.waypbusy_vec,
                                              cpy_pkt.m_ccp_ctrl_pkt.nru_counter,
                                              m_evict_cacheline
                                             );
              if (fq_evict.size() > 0) begin
                 `uvm_info("", $sformatf("pushing entry in evicted_q"), UVM_NONE);
                 evicted_cachelines.push_back(m_evict_cacheline);
              end

              `uvm_info("CCP-SCB",$sformatf("3: Evict:%0b cpy_pkt.m_ccp_ctrl_pkt.evictaddr :%0x ",evict,cpy_pkt.m_ccp_ctrl_pkt.evictaddr),UVM_MEDIUM);
              //Check the evicted line is correct  
              if((m_evict_cacheline.addr[WCCPADDR-1:CACHELINE_OFFSET] !== cpy_pkt.m_ccp_ctrl_pkt.evictaddr[WCCPADDR-1:CACHELINE_OFFSET]) || 
                 (m_evict_cacheline.security !== cpy_pkt.m_ccp_ctrl_pkt.evictsecurity) || 
                 (m_evict_cacheline.state !== cpy_pkt.m_ccp_ctrl_pkt.evictstate)) begin
                  `uvm_info("EXP_EVICT_CACHELINE",$psprintf("%s",
                            m_evict_cacheline.sprint_pkt()),UVM_MEDIUM)
                  spkt = {"Evict addr/state mismatch Exp Addr:%0h but Got Addr:%0h",
                          " Exp State :%s but Got State:%s"};
                  `uvm_error("<%=obj.BlockId%>:CCP-SCB",$psprintf( spkt,m_evict_cacheline.addr,
                                                 cpy_pkt.m_ccp_ctrl_pkt.evictaddr,
                                                 m_evict_cacheline.state,
                                                 cpy_pkt.m_ccp_ctrl_pkt.evictstate))
              end
           end
           else begin
              if(cpy_pkt.m_ccp_ctrl_pkt.evictvld) begin
                 `uvm_error("<%=obj.BlockId%>:CCP-SCB",$psprintf("evictvld should not be high when all ways are not full"))
              end

              //Check the allocated way is correct
              //NF: Disabling replacement policy checks -- Start
              //m_ccpCacheModel.chkFirstAvailWay(m_ccp_addr, cpy_pkt.m_ccp_ctrl_pkt.waypbusy_vec, firstAvailWay); 
              //if(firstAvailWay !== cpy_pkt.m_ccp_ctrl_pkt.wayn) begin
              //   foreach(m_ccpCacheModel.ccpCacheSet[ccp_index,i]) begin
              //  `uvm_info("",$sformatf("%s",m_ccpCacheModel.ccpCacheSet[ccp_index][i].sprint_pkt()),UVM_MEDIUM);
              //   end
              //  `uvm_info("<%=obj.BlockId%>:CCP-SCB",$psprintf("Alloc way mismatch Exp:%0h but Got:%0h",
              //              firstAvailWay,cpy_pkt.m_ccp_ctrl_pkt.wayn),UVM_MEDIUM)
              //  `uvm_error("<%=obj.BlockId%>:CCP-SCB",$psprintf("Alloc way mismatch Exp:%0h but Got:%0h",
              //              firstAvailWay,cpy_pkt.m_ccp_ctrl_pkt.wayn))
              //end
              //NF: Disabling replacement policy checks -- End
           end
           if(btt_q[fq[fq_idx]].isFillReqd || btt_q[fq[fq_idx]].isWriteAlloc) begin
             if(btt_q[fq[fq_idx]].isFillReqd)begin
               btt_q[fq[fq_idx]].m_op_cmd_type = FILL;
               allocState     = IX;
               fillpending    = 1;
             end
             else begin
               btt_q[fq[fq_idx]].m_op_cmd_type = WRITEALLOC;
               fillpending    = 0;
             end
             if(evict) begin
                 m_ccpCacheModel.add_cacheline(m_ccp_addr,allocState,fillpending,security,wayn);
              `ifndef V201
                 if(cpy_pkt.m_ccp_ctrl_pkt.rp_update &&  btt_q[fq[fq_idx]].isWriteAlloc) begin
                   m_ccpCacheModel.update_nru(m_ccp_addr,security);
                 end 
               `endif
                 `uvm_info("<%=obj.BlockId%>:CCP-SCB:write_ccp_ctrl_chnl",$sformatf("cacheline added :0x%x",m_ccp_addr),UVM_MEDIUM); 
             end
           //  m_ccpCacheModel.print_cache_model();
           end
        end
        if(btt_q[fq[fq_idx]].isSnoop && !(btt_q[fq[fq_idx]].isWrite || btt_q[fq[fq_idx]].isRead || btt_q[fq[fq_idx]].m_ccp_ctrl_pkt.alloc ))begin
            btt_q.delete(fq[fq_idx]); 
        end
      end
     end
  end else begin
     if(cpy_pkt.m_ccp_ctrl_pkt.tagstateup && cpy_pkt.m_ccp_ctrl_pkt.state == IX)begin
        //Local CCP address
        m_ccp_addr = cl_aligned(cpy_pkt.ccp_addr);
        security   = cpy_pkt.security;

        fq_w = {};
        fq_w = btt_q.find_index() with (cl_aligned(item.ccp_addr) == m_ccp_addr &&
                                        item.security == security &&
                                        (item.isWrite && !item.isWriteDataRcvd));
        if(fq_w.size()>0)begin
           `uvm_info("DMI0-CCP_SCB",$sformatf("DEBUG1, setting isCacheInvld high, fq_w.size = %0d ",fq_w.size()),UVM_MEDIUM);
           btt_q[fq_w[fq_w.size()-1]].print_debug();
           btt_q[fq_w[fq_w.size()-1]].isCacheInvld = 1;
           for (int i=0; i < fq_w.size(); i++) begin
              btt_q[fq_w[i]].isEvicted = 1;
           end
        end

        if(!cpy_pkt.m_ccp_ctrl_pkt.isMntOp && cpy_pkt.m_ccp_ctrl_pkt.currstate != IX) begin
           m_ccpCacheModel.copy_cacheline(m_ccp_addr,
                                          security,
                                          m_evict_cacheline
                                          );
           if (fq_w.size() > 0) begin
              `uvm_info("", $sformatf("pushing entry in evicted_q"), UVM_NONE);
              m_evict_cacheline.print();
              evicted_cachelines.push_back(m_evict_cacheline);
           end
           m_ccpCacheModel.delete_cacheline(cl_aligned(m_ccp_addr),security);
        end
     end
  end
`endif
endfunction

//=========================================================================
// Function: write_ccp_fill_chnl 
// Purpose: 
// 
// 
//=========================================================================

function void ccp_scoreboard::write_ccp_fill_ctrl_chnl(ccp_fillctrl_pkt_t m_pkt);
`ifndef INCA
    ccp_fillctrl_pkt_t    m_fillctrl_pkt_temp;
    ccp_fillctrl_pkt_t    m_fillctrl_pkt;
    ccp_filldata_pkt_t    m_filldata_pkt;
    ccp_scb_txn           tmp_pkt;
    int fq[$];
    int fq_wp[$];
    longint iotag;
    int index;

    m_fillctrl_pkt_temp = new();
    m_fillctrl_pkt      = new();
    m_filldata_pkt      = new();

    $cast(m_fillctrl_pkt_temp,m_pkt); 
    m_fillctrl_pkt.copy(m_fillctrl_pkt_temp);

    `uvm_info("<%=obj.BlockId%>:CCP-SCB:write_ccp_fill_ctrl_chnl", $sformatf("%t: cachefillctrl_pkt: %s", $time, m_pkt.sprint_pkt()), UVM_HIGH);

   <%/* if(obj.useCmc) { */%>
    if ((m_fillctrl_pkt.addr >= lower_sp_addr) && (m_fillctrl_pkt.addr <= upper_sp_addr) && sp_enabled) begin
      `uvm_info("<%=obj.BlockId_%>:CCP-SCB:write_ccp_fill_ctrl_chnl", $sformatf("it's a sp txn on ccp fill ctrl chnl"), UVM_MEDIUM)
      return;
    end
   <%/* } */%>

    //Search the BTT queue
    fq    = {};
    fq_wp = {};

    fq = btt_q.find_index() with ((cl_aligned(item.ccp_addr) == cl_aligned(m_fillctrl_pkt.addr)) && 
                                  (item.security == m_fillctrl_pkt.security) &&  
                                  (item.fillwayn == m_fillctrl_pkt.wayn) &&  
                                  (item.isFillReqd == 1) &&  
                                  (item.isFillCtrlRcvd == 0)); 

    fq_wp = btt_q.find_index() with ((cl_aligned(item.pendingaddr) == cl_aligned(m_fillctrl_pkt.addr)) &&
                                     (item.pendingsecurity == m_fillctrl_pkt.security) &&
                                     (item.pendingwayn == m_fillctrl_pkt.wayn) &&
                                     (item.isfillpending == 1));


    if(m_fillctrl_pkt.state === IX)begin
       if(fq.size()>0) begin
         m_ccpCacheModel.delete_cacheline_fill(cl_aligned(btt_q[fq[0]].ccp_addr),btt_q[fq[0]].security,btt_q[fq[0]].fillwayn);
         btt_q[fq[0]].print_debug();
         btt_q.delete(fq[0]);
       end 
       else if(m_ccpCacheModel.isCacheLineValid(m_fillctrl_pkt.addr,m_fillctrl_pkt.security)) begin
         m_ccpCacheModel.delete_cacheline_fill(cl_aligned(m_fillctrl_pkt.addr),m_fillctrl_pkt.security,m_fillctrl_pkt.wayn);
       end
       else begin
         `uvm_error("CCP_SB:write_ccp_fill_ctrl_chnl",$sformatf("Unexpected Cacheline  addr :%0x to invalidate",m_fillctrl_pkt.addr));
       end
    end
    else if(fq.size()>0) begin
        btt_q[fq[0]].m_ccp_fill_ctrl_pkt = new();
        btt_q[fq[0]].m_ccp_fill_ctrl_pkt.copy(m_fillctrl_pkt);
        btt_q[fq[0]].isFillCtrlRcvd=1'b1;

        if(fq_wp.size() >0)begin
          btt_q[fq_wp[0]].fillpending = 0;
          btt_q[fq_wp[0]].pendingstate   = m_fillctrl_pkt.state;
        end
        else begin
          m_ccpCacheModel.modify_state(cl_aligned(btt_q[fq[0]].ccp_addr),btt_q[fq[0]].m_ccp_fill_ctrl_pkt.state,
                                       btt_q[fq[0]].security);

          m_ccpCacheModel.set_pending_bit(cl_aligned(btt_q[fq[0]].ccp_addr),1'b0,btt_q[fq[0]].security);
          m_ccpCacheModel.update_nru(cl_aligned(btt_q[fq[0]].ccp_addr),btt_q[fq[0]].security,1'b1);
        end


        if(btt_q[fq[0]].isFillDataRcvd == 1) begin
          store_read_cacheline_data(btt_q[fq[0]]);
          if(!btt_q[fq[0]].isEvict || (btt_q[fq[0]].isEvict == 1 && btt_q[fq[0]].isEvictDataRcvd ==1)) begin
            btt_q[fq[0]].print_debug();
            btt_q.delete(fq[0]);
          end
         end
    end else begin
       `uvm_info("<%=obj.BlockId%>:CCP-SCB:write_ccp_fill_ctrl_chnl", $sformatf("%t: cachefillctrl_pkt: %s", $time, m_pkt.sprint_pkt()), UVM_MEDIUM);
       iotag     = mapAddrToCCPTag(m_fillctrl_pkt.addr);
       fq    = {};
       //index =  addrMgrConst::get_set_index(cl_aligned(m_fillctrl_pkt.addr),agent_id);
       index =  CcpCalcIndex(cl_aligned(m_fillctrl_pkt.addr));
        
       if( m_ccpCacheModel.ccpCacheSet.exists(index)) begin
          fq = m_ccpCacheModel.ccpCacheSet[index].find_index() with (
                     (item.tag == iotag) &&
                     (item.security == m_fillctrl_pkt.security)
                 );  

          if(fq.size() == 1 ) begin
             m_ccpCacheModel.modify_state(m_fillctrl_pkt.addr,m_fillctrl_pkt.state,
                                        m_fillctrl_pkt.security);

             m_ccpCacheModel.set_pending_bit(m_fillctrl_pkt.addr,1'b0,m_fillctrl_pkt.security);
             m_ccpCacheModel.update_nru(m_fillctrl_pkt.addr,m_fillctrl_pkt.security,1'b1);
          end
       end
       security_q.push_back(m_fillctrl_pkt.security);

        if (fill_data_q.size() > 0) begin
            m_filldata_pkt = fill_data_q.pop_front();
            tmp_pkt = new();
            tmp_pkt.ccp_addr = m_filldata_pkt.addr;
            tmp_pkt.security = security_q.pop_front();
            tmp_pkt.m_ccp_ctrl_pkt = new();
            tmp_pkt.m_ccp_ctrl_pkt.addr = m_filldata_pkt.addr;
            tmp_pkt.m_ccp_ctrl_pkt.security = tmp_pkt.security;
            tmp_pkt.m_ccp_fill_data_pkt = new();
            tmp_pkt.m_ccp_fill_data_pkt.copy(m_filldata_pkt);
            if(fq.size() == 0)
               m_ccpCacheModel.add_cacheline(cl_aligned(m_filldata_pkt.addr),m_fillctrl_pkt.state,0,tmp_pkt.security,m_filldata_pkt.wayn);
            store_read_cacheline_data(tmp_pkt);
        end
    end

`endif
endfunction



//=========================================================================
// Function: write_ccp_fill_data_chnl 
// Purpose: 
// 
// 
//=========================================================================
function void ccp_scoreboard::write_ccp_fill_data_chnl(ccp_filldata_pkt_t m_pkt);
`ifndef INCA
    ccp_filldata_pkt_t  m_filldata_pkt;
    ccp_filldata_pkt_t  m_filldata_pkt_tmp;
    int fq[$];

    ccp_scb_txn         data_pkt;
    ccp_scb_txn         tmp_pkt;

    m_filldata_pkt      = new();
    m_filldata_pkt_tmp  = new();

    $cast(m_filldata_pkt_tmp,m_pkt);

    m_filldata_pkt.copy(m_filldata_pkt_tmp);
 
   if(!m_filldata_pkt.done) begin
        `uvm_info("<%=obj.BlockId%>:CCP-SCB", $sformatf("%t: cachefilldata_pkt: %s", $time, m_filldata_pkt.sprint_pkt()), UVM_MEDIUM);
        `uvm_error("<%=obj.BlockId%>:CCP-SCB", $psprintf("done is Exp :1 Got :0"))
   end else begin
      if(m_filldata_pkt.doneId != m_filldata_pkt.fillId)begin
        `uvm_info("<%=obj.BlockId%>:CCP-SCB", $sformatf("%t: cachefilldata_pkt: %s", $time, m_filldata_pkt.sprint_pkt()), UVM_MEDIUM);
        `uvm_error("<%=obj.BlockId%>:CCP-SCB",$sformatf(" fill Id and done Id should be same :fillId :%0x doneId :%0x",m_filldata_pkt.fillId,m_filldata_pkt.doneId))
      end
   end

   `uvm_info("<%=obj.BlockId%>:CCP-SCB", $sformatf("%t: cachefilldata_pkt: %s", $time, m_pkt.sprint_pkt()), UVM_MEDIUM);

   <%/* if(obj.useCmc) { */%>
    if ((m_filldata_pkt.addr >= lower_sp_addr) && (m_filldata_pkt.addr <= upper_sp_addr) && sp_enabled) begin
      `uvm_info("<%=obj.BlockId_%>:CCP-SCB:write_ccp_fill_data_chnl", $sformatf("it's a sp txn on ccp fill data chnl"), UVM_MEDIUM)
      return;
    end
   <%/* } */%>

    //Search the BTT queue
    fq = btt_q.find_index() with ((cl_aligned(item.ccp_addr) == cl_aligned(m_filldata_pkt.addr)) && 
                                  (item.fillwayn  == m_filldata_pkt.wayn) &&  
                                  (item.isFillReqd == 1) &&  
                                  (item.isFillDataRcvd ==0)); 

    if(fq.size()>0) begin
        btt_q[fq[0]].m_ccp_fill_data_pkt = new();
        btt_q[fq[0]].m_ccp_fill_data_pkt.copy(m_filldata_pkt);
        btt_q[fq[0]].isFillDataRcvd = 1'b1;
        if(btt_q[fq[0]].isFillCtrlRcvd == 1) begin
          //  m_ccpCacheModel.modify_state(cl_aligned(btt_q[fq[0]].ccp_addr),btt_q[fq[0]].m_ccp_fill_ctrl_pkt.state,
          //  btt_q[fq[0]].security);

          //  m_ccpCacheModel.set_pending_bit(cl_aligned(btt_q[fq[0]].ccp_addr),1'b0,btt_q[fq[0]].security);
          //  m_ccpCacheModel.update_nru(cl_aligned(btt_q[fq[0]].ccp_addr),btt_q[fq[0]].security,1'b1);
            store_read_cacheline_data(btt_q[fq[0]]);
          if(!btt_q[fq[0]].isEvict || (btt_q[fq[0]].isEvict == 1 && btt_q[fq[0]].isEvictDataRcvd ==1)) begin
            btt_q[fq[0]].print_debug();
            btt_q.delete(fq[0]);
          end
        end
         
    end else begin
        `uvm_info("<%=obj.BlockId%>:CCP-SCB", $sformatf("%t: cachefilldata_pkt: %s", $time, m_pkt.sprint_pkt()), UVM_MEDIUM);
        if (security_q.size() > 0) begin
            tmp_pkt = new();
            tmp_pkt.ccp_addr = m_filldata_pkt.addr;
            tmp_pkt.security = security_q.pop_front();
            tmp_pkt.m_ccp_ctrl_pkt = new();
            tmp_pkt.m_ccp_ctrl_pkt.addr = m_filldata_pkt.addr;
            tmp_pkt.m_ccp_ctrl_pkt.security = tmp_pkt.security;
            tmp_pkt.m_ccp_fill_data_pkt = new();
            tmp_pkt.m_ccp_fill_data_pkt.copy(m_filldata_pkt);
            store_read_cacheline_data(tmp_pkt);
        end else begin
           fill_data_q.push_back(m_filldata_pkt);
        end
    end
`endif
endfunction

//=========================================================================
// Function: write_ccp_rd_rsp_chnl 
// Purpose: 
// 
// 
//=========================================================================
function void ccp_scoreboard::write_ccp_rd_rsp_chnl(ccp_rd_rsp_pkt_t m_pkt);
`ifndef INCA
    ccp_rd_rsp_pkt_t rd_rsp_pkt;
    ccp_rd_rsp_pkt_t rd_rsp_pkt_tmp;
    int fq[$];
    int fq_w[$];

    rd_rsp_pkt      = new();
    rd_rsp_pkt_tmp  = new();

    $cast(rd_rsp_pkt_tmp,m_pkt);
    rd_rsp_pkt.copy(rd_rsp_pkt_tmp); 

     `uvm_info("<%=obj.BlockId%>:CCP-SCB", $sformatf("%t: ccp_rdrsp_pkt_t: %s", $time, rd_rsp_pkt.sprint_pkt()), UVM_MEDIUM);
    
    //Search the BTT queue
    fq = btt_q.find_index() with (item.isBypassrdrsp && !item.isReadDataRcvd); 
   
    fq_w = btt_q.find_index() with (cl_aligned(item.ccp_addr) == cl_aligned(btt_q[fq[0]].ccp_addr) &&
                                    item.security == btt_q[fq[0]].security &&
                                    item.isWrite &&
                                    !item.isWriteDataRcvd &&
                                    (item.t_scb_txn < btt_q[fq[0]].t_scb_txn));

    if(fq_w.size() > 0 && btt_q[fq_w[0]].isWrite && btt_q[fq[0]].isRead)begin
        print_queues();
           spkt = {"Read Addr :0x%0x Security :%0b Exp:%s but Got:%s"};
           `uvm_info("<%=obj.BlockId%>:CCP-SCB", $psprintf(spkt, btt_q[fq_w[0]].ccp_addr,btt_q[fq_w[0]].security,btt_q[fq_w[0]].m_ccp_exp_rd_rsp_pkt.sprint_pkt(),
                      rd_rsp_pkt.sprint_pkt()),UVM_MEDIUM)
          `uvm_error("<%=obj.BlockId%>:CCP-SCB", $psprintf("Write should complete before read rsp"))
    
    end

    if(fq.size()>0) begin
        if(btt_q[fq[0]].isRead && btt_q[fq[0]].isHit && btt_q[fq[0]].isBypassrdrsp && btt_q[fq[0]].isWritePending ) begin
          give_read_cacheline_data(btt_q[fq[0]],0);
          if(btt_q[fq[0]].m_ccp_ctrl_pkt.tagstateup && btt_q[fq[0]].m_ccp_ctrl_pkt.state == IX)begin
            m_ccpCacheModel.delete_cacheline(cl_aligned(btt_q[fq[0]].ccp_addr),btt_q[fq[0]].security);
          end
        end
        btt_q[fq[0]].isReadDataRcvd = 1;
        btt_q[fq[0]].m_ccp_got_rd_rsp_pkt = new();
        btt_q[fq[0]].m_ccp_got_rd_rsp_pkt.copy(rd_rsp_pkt);
       if(btt_q[fq[0]].m_ccp_exp_rd_rsp_pkt.do_compare_pkts(rd_rsp_pkt) == 0) begin 
         print_queues();
           spkt = {"Read Response Mismatch Addr :0x%0x Security :%0b Exp:%s but Got:%s"};
           `uvm_error("<%=obj.BlockId%>:CCP-SCB", $psprintf(spkt, btt_q[fq[0]].ccp_addr,btt_q[fq[0]].security,btt_q[fq[0]].m_ccp_exp_rd_rsp_pkt.sprint_pkt(),
                      rd_rsp_pkt.sprint_pkt()))
       end 
       else if(btt_q[fq[0]].isFillReqd == 1'b1) begin
          if(btt_q[fq[0]].isFillDataRcvd == 1'b1 && btt_q[fq[0]].isFillCtrlRcvd == 1'b1 )begin
          `uvm_info("<%=obj.BlockId%>:CCP-SCB", $psprintf("Read rsp  Data Matched"),UVM_MEDIUM)
           btt_q[fq[0]].print_debug();
           btt_q.delete(fq[0]);
          end
       end 
       else if(btt_q[fq[0]].isWrite) begin
          if(btt_q[fq[0]].isWrite && btt_q[fq[0]].isWriteDataRcvd)begin
          `uvm_info("<%=obj.BlockId%>:CCP-SCB", $psprintf("Read rsp  Data Matched"),UVM_MEDIUM)
           btt_q[fq[0]].print_debug();
           btt_q.delete(fq[0]);
          end
       end 
       else begin
          `uvm_info("<%=obj.BlockId%>:CCP-SCB", $psprintf("Read rsp  Data Matched"),UVM_MEDIUM)
         btt_q[fq[0]].print_debug();
         btt_q.delete(fq[0]);
       end
    end else begin
        print_queues();
        `uvm_info("<%=obj.BlockId%>:CCP-SCB", $sformatf("%t: ccp_rdrsp_pkt_t: %s", $time, m_pkt.sprint_pkt()), UVM_MEDIUM);
        `uvm_error("<%=obj.BlockId%>:CCP-SCB", $psprintf("Couldn't match the Read Rsp pkt with any txns"))
    end
`endif
endfunction



//=========================================================================
// Function: write_ccp_evict_chnl 
// Purpose: 
// 
// 
//=========================================================================
function void ccp_scoreboard::write_ccp_evict_chnl(ccp_evict_pkt_t m_pkt);
`ifndef INCA
    ccp_evict_pkt_t rd_evict_pkt;
    ccp_evict_pkt_t rd_evict_pkt_tmp;
    int fq[$];
    int fq_w[$];

    rd_evict_pkt      = new();
    rd_evict_pkt_tmp  = new();

    $cast(rd_evict_pkt_tmp,m_pkt);
    rd_evict_pkt.copy(rd_evict_pkt_tmp); 

    `uvm_info("<%=obj.BlockId%>:CCP-SCB", $sformatf("%t: ccp_evict_pkt_t: %s", $time, rd_evict_pkt.sprint_pkt()), UVM_MEDIUM);

    fq = btt_q.find_index() with (item.isBypassevict && !item.isEvictDataRcvd); 

    fq_w = btt_q.find_index() with (((cl_aligned(item.ccp_addr) == cl_aligned(btt_q[fq[0]].evict_addr)) && 
                                    (item.security == btt_q[fq[0]].evict_security))||
                                    ((cl_aligned(item.ccp_addr) == cl_aligned(btt_q[fq[0]].ccp_addr)) && 
                                    (item.security == btt_q[fq[0]].security))); 

    if(fq_w.size() >1 && btt_q[fq_w[0]].isWrite && (btt_q[fq_w[0]].t_scb_txn < btt_q[fq[0]].t_scb_txn) && !btt_q[fq_w[0]].isWriteDataRcvd && (btt_q[fq[0]].isRead || btt_q[fq[0]].isEvict))begin
        print_queues();
          spkt = {"Evict addr Addr :0x%0x secu :%0b Exp:%s but Got:%s"};
          `uvm_info("<%=obj.BlockId%>:CCP-SCB", $psprintf(spkt,btt_q[fq[0]].evict_addr,btt_q[fq[0]].evict_security,btt_q[fq[0]].m_ccp_exp_evict_pkt.sprint_pkt(),
                     rd_evict_pkt.sprint_pkt()),UVM_MEDIUM)
          `uvm_error("<%=obj.BlockId%>:CCP-SCB", $psprintf("Write should complete before read evict"))
    
    end

    if(fq.size()>0) begin
       // btt_q[fq[0]].print_debug();
        if(btt_q[fq[0]].isRead && btt_q[fq[0]].isHit && btt_q[fq[0]].isBypassevict && btt_q[fq[0]].isWritePending ) begin
          give_read_cacheline_data(btt_q[fq[0]],1);
          if(btt_q[fq[0]].m_ccp_ctrl_pkt.tagstateup && btt_q[fq[0]].m_ccp_ctrl_pkt.state == IX)begin
            m_ccpCacheModel.delete_cacheline(cl_aligned(btt_q[fq[0]].ccp_addr),btt_q[fq[0]].security);
          end
        end
        btt_q[fq[0]].isEvictDataRcvd = 1;
        btt_q[fq[0]].m_ccp_got_evict_pkt = new();
        btt_q[fq[0]].m_ccp_got_evict_pkt.copy(rd_evict_pkt);
       if(btt_q[fq[0]].m_ccp_exp_evict_pkt.do_compare_pkts(rd_evict_pkt) == 0) begin 
         print_queues();
          spkt = {"Evict Mismatch  Addr :0x%0x secu :%0b Exp:%s but Got:%s"};
          `uvm_error("<%=obj.BlockId%>:CCP-SCB", $psprintf(spkt,btt_q[fq[0]].evict_addr,btt_q[fq[0]].evict_security,btt_q[fq[0]].m_ccp_exp_evict_pkt.sprint_pkt(),
                     rd_evict_pkt.sprint_pkt()))
       end 
       else if(btt_q[fq[0]].isFillReqd == 1'b1) begin
          if(btt_q[fq[0]].isFillDataRcvd == 1'b1 && btt_q[fq[0]].isFillCtrlRcvd == 1'b1 )begin
             `uvm_info("<%=obj.BlockId%>:CCP-SCB", $psprintf("Evict  Data Matched"),UVM_MEDIUM)
             btt_q[fq[0]].print_debug();
             btt_q.delete(fq[0]);
          end
       end 
       else if(btt_q[fq[0]].isWrite) begin
          if(btt_q[fq[0]].isWrite && btt_q[fq[0]].isWriteDataRcvd)begin
             `uvm_info("<%=obj.BlockId%>:CCP-SCB", $psprintf("Evict  Data Matched"),UVM_MEDIUM)
             btt_q[fq[0]].print_debug();
             btt_q.delete(fq[0]);
          end
       end 
       else begin
         `uvm_info("<%=obj.BlockId%>:CCP-SCB", $psprintf("Evict  Data Matched"),UVM_MEDIUM)
         btt_q[fq[0]].print_debug();
         btt_q.delete(fq[0]);
       end
    end else begin
        print_queues();
        `uvm_info("<%=obj.BlockId%>:CCP-SCB", $sformatf("%t: ccp_evict_pkt_t: %s", $time, m_pkt.sprint_pkt()), UVM_MEDIUM);
        `uvm_error("<%=obj.BlockId%>:CCP-SCB", $psprintf("Couldn't match the evict pkt with any txns"))
    end
`endif
endfunction


//=========================================================================
// Function: write_ccp_wr_data_chnl 
// Purpose: 
// 
// 
//=========================================================================
function void ccp_scoreboard::write_ccp_wr_data_chnl(ccp_wr_data_pkt_t m_pkt);
`ifndef INCA
    ccp_wr_data_pkt_t  m_wr_data_pkt;
    ccp_wr_data_pkt_t  m_wr_data_pkt_tmp;
    ccp_scb_txn        data_pkt;
    int burstln;
    int fq[$];
    int fq_e[$];
    int fq_all[$];
    int fq_wp[$];
    int fq_wr_pend[$];
    int fq_rd_pend[$];
    time curr_wr_entry_t_scb_txn;
    time next_wr_entry_t_scb_txn;
    bit curr_wr_entry_security;
    longint curr_wr_entry_addr;
    bit isEvicted;

    m_wr_data_pkt     = new();
    m_wr_data_pkt_tmp = new();
    
    $cast(m_wr_data_pkt_tmp,m_pkt);

    m_wr_data_pkt.copy(m_wr_data_pkt_tmp);

    data_pkt = new();
    data_pkt.m_ccp_wr_data_pkt = new();
    data_pkt.m_ccp_wr_data_pkt.copy(m_wr_data_pkt);

   `uvm_info("<%=obj.BlockId%>:CCP-SCB:write_ccp_wr_data_chnl", $sformatf("%t: ccp_wr_data_pkt: %s", $time, m_pkt.sprint_pkt()), UVM_MEDIUM);


    fq = btt_q.find_index() with ( item.isWrite && !item.isWriteDataRcvd ||
                                  !item.isWrite && item.isBypass && !item.isBypassDataRcvd || 
                                   item.isWrite && item.isBypass && !item.isWriteDataRcvd ); 

   `uvm_info("<%=obj.BlockId%>:CCP-SCB:write_ccp_wr_data_chnl", $sformatf("%t: btt_q.size: %d", $time,fq.size()), UVM_MEDIUM);

    if(fq.size()>0) begin
      btt_q[fq[0]].print_debug();
      curr_wr_entry_t_scb_txn = btt_q[fq[0]].t_scb_txn;
      curr_wr_entry_addr      = btt_q[fq[0]].ccp_addr;
      curr_wr_entry_security  = btt_q[fq[0]].security;

      isEvicted = btt_q[fq[0]].isEvicted | btt_q[fq[0]].DeleteCl;

      if(btt_q[fq[0]].isdropped)begin
        btt_q[fq[0]].isWriteDataRcvd=1'b1;
        btt_q[fq[0]].isBypassDataRcvd=1'b1;

        // Read from reference model for the pending read transactions to check the data on rdrsp chnl
        fq_wr_pend = {};
        fq_wr_pend = btt_q.find_index() with (item.isWrite  && !item.isWriteDataRcvd && 
                                              (cl_aligned(item.ccp_addr) == cl_aligned(curr_wr_entry_addr)) &&
                                              item.security              == curr_wr_entry_security &&
                                              item.t_scb_txn             >  curr_wr_entry_t_scb_txn);
  
        fq_rd_pend = {};
        fq_rd_pend = btt_q.find_index() with (item.isRead && 
                                              (cl_aligned(item.ccp_addr) == cl_aligned(curr_wr_entry_addr)) &&
                                              item.security              == curr_wr_entry_security);
  
        if (fq_wr_pend.size() > 0) begin
            fq_wr_pend[0] = find_oldest_txn_in_btt_q(fq_wr_pend);
            next_wr_entry_t_scb_txn = btt_q[fq_wr_pend[0]].t_scb_txn;
        end
  
        if (fq_rd_pend.size() > 0) begin
           foreach (fq_rd_pend[i]) begin
              if ((fq_wr_pend.size() > 0)) begin
                 if ((btt_q[fq_rd_pend[i]].t_scb_txn > curr_wr_entry_t_scb_txn) &&
                     (btt_q[fq_rd_pend[i]].t_scb_txn < next_wr_entry_t_scb_txn)) begin
                    if (!isEvicted) give_read_cacheline_data(btt_q[fq_rd_pend[i]],btt_q[fq_rd_pend[i]].isBypassevict);
                    else give_read_evicted_cacheline_data(btt_q[fq_rd_pend[i]],btt_q[fq_rd_pend[i]].isBypassevict);

                    btt_q[fq_rd_pend[i]].isWritePending = 0;
                 end
              end else begin
                 if (btt_q[fq_rd_pend[i]].t_scb_txn > curr_wr_entry_t_scb_txn) begin
                    if (!isEvicted) give_read_cacheline_data(btt_q[fq_rd_pend[i]],btt_q[fq_rd_pend[i]].isBypassevict);
                    else give_read_evicted_cacheline_data(btt_q[fq_rd_pend[i]],btt_q[fq_rd_pend[i]].isBypassevict);

                    btt_q[fq_rd_pend[i]].isWritePending = 0;
                 end
              end
           end
        end

        if(!((btt_q[fq[0]].isBypassrdrsp && !btt_q[fq[0]].isReadDataRcvd) || (btt_q[fq[0]].isBypassevict && !btt_q[fq[0]].isEvictDataRcvd ))) begin
         //btt_q[fq[0]].print_debug();
         btt_q.delete(fq[0]);
        end
      end
      else if(btt_q[fq[0]].isfillpending) begin
/*
        `uvm_info("<%=obj.BlockId%>:CCP-SCB:write_ccp_wr_data_chnl",$sformatf("btt_q[fq[0]].isfillpending :%0b pendingaddr :%0x pendingsecurity :%0b",btt_q[fq[0]].isfillpending,btt_q[fq[0]].pendingaddr,btt_q[fq[0]].pendingsecurity),UVM_MEDIUM);
        btt_q[fq[0]].isWriteDataRcvd=1'b1;
        btt_q[fq[0]].isBypassDataRcvd=1'b1;
        btt_q[fq[0]].m_ccp_wr_data_pkt  = new();
        btt_q[fq[0]].m_ccp_wr_data_pkt.copy(m_wr_data_pkt);
        merge_write_data(btt_q[fq[0]]);

        // Read from reference model for the pending read transactions to check the data on rdrsp chnl
        fq_wr_pend = {};
        fq_wr_pend = btt_q.find_index() with (item.isWrite  && !item.isWriteDataRcvd && 
                                              (cl_aligned(item.ccp_addr) == cl_aligned(curr_wr_entry_addr)) &&
                                              item.security              == curr_wr_entry_security &&
                                              item.t_scb_txn             >  curr_wr_entry_t_scb_txn);
  
        fq_rd_pend = {};
        fq_rd_pend = btt_q.find_index() with (item.isRead && 
                                              (cl_aligned(item.ccp_addr) == cl_aligned(curr_wr_entry_addr)) &&
                                              item.security              == curr_wr_entry_security);
  
        if (fq_wr_pend.size() > 0) begin
            fq_wr_pend[0] = find_oldest_txn_in_btt_q(fq_wr_pend);
            next_wr_entry_t_scb_txn = btt_q[fq_wr_pend[0]].t_scb_txn;
        end
  
        if (fq_rd_pend.size() > 0) begin
           foreach (fq_rd_pend[i]) begin
              if ((fq_wr_pend.size() > 0)) begin
                 if ((btt_q[fq_rd_pend[i]].t_scb_txn > curr_wr_entry_t_scb_txn) &&
                     (btt_q[fq_rd_pend[i]].t_scb_txn < next_wr_entry_t_scb_txn)) begin
                    give_read_cacheline_data(btt_q[fq_rd_pend[i]],0);
                    btt_q[fq_rd_pend[0]].isWritePending = 0;
                 end
              end else begin
                 if (btt_q[fq_rd_pend[i]].t_scb_txn > curr_wr_entry_t_scb_txn) begin
                    give_read_cacheline_data(btt_q[fq_rd_pend[i]],0);
                    btt_q[fq_rd_pend[0]].isWritePending = 0;
                 end
              end
           end
        end

        if(btt_q[fq[0]].isEvicted) begin
          fq_e = {};
          fq_e = btt_q.find_index() with (cl_aligned(item.evict_addr) == cl_aligned(btt_q[fq[0]].ccp_addr) &&
                                          item.isEvict    == 1'b1 &&
                                          item.evict_security == btt_q[fq[0]].security);
      
          give_evict_cacheline_data(btt_q[fq_e[0]],1,btt_q[fq_e[0]].ccp_index,btt_q[fq_e[0]].fillwayn);
        end
        else begin
          if(btt_q[fq[0]].isBypassrdrsp) begin
              give_read_cacheline_data(btt_q[fq[0]],0);
          end else if(btt_q[fq[0]].isBypassevict) begin
              give_read_cacheline_data(btt_q[fq[0]],1'b1);
          end
        end
        m_ccpCacheModel.delete_cacheline(cl_aligned(btt_q[fq[0]].ccp_addr),btt_q[fq[0]].security);
        m_ccpCacheModel.add_cacheline(cl_aligned(btt_q[fq[0]].pendingaddr),btt_q[fq[0]].pendingstate,btt_q[fq[0]].fillpending,btt_q[fq[0]].pendingsecurity,btt_q[fq[0]].pendingwayn);
       `ifndef V201
        if(btt_q[fq[0]].pendingrpUpdate) begin
           m_ccpCacheModel.update_nru(cl_aligned(btt_q[fq[0]].pendingaddr),btt_q[fq[0]].pendingsecurity);
        end 
       `endif
        if(!((btt_q[fq[0]].isBypassrdrsp && !btt_q[fq[0]].isReadDataRcvd) || (btt_q[fq[0]].isBypassevict && !btt_q[fq[0]].isEvictDataRcvd ))) begin
         btt_q[fq[0]].print_debug();
         btt_q.delete(fq[0]);
        end
*/
      end else if(btt_q[fq[0]].isBypass && btt_q[fq[0]].isWrite) begin
        btt_q[fq[0]].m_ccp_wr_data_pkt  = new();
        btt_q[fq[0]].m_ccp_wr_data_pkt.copy(m_wr_data_pkt);
        if (btt_q[fq[0]].isEvicted) begin
          merge_write_data_evicted(btt_q[fq[0]]);
        end else begin
          merge_write_data(btt_q[fq[0]]);
        end

        if(btt_q[fq[0]].isBypassrdrsp ) begin
           if (!isEvicted) give_read_cacheline_data(btt_q[fq[0]],0);
           else give_read_evicted_cacheline_data(btt_q[fq[0]],0);
        end else if(btt_q[fq[0]].isBypassevict) begin
           if (!isEvicted) give_read_cacheline_data(btt_q[fq[0]],1);
           else give_read_evicted_cacheline_data(btt_q[fq[0]],1);
        end

        // Read from reference model for the pending read transactions to check the data on rdrsp chnl
        fq_wr_pend = {};
        fq_wr_pend = btt_q.find_index() with (item.isWrite  && !item.isWriteDataRcvd && 
                                              (cl_aligned(item.ccp_addr) == cl_aligned(curr_wr_entry_addr)) &&
                                              item.security              == curr_wr_entry_security &&
                                              item.t_scb_txn             >  curr_wr_entry_t_scb_txn);
  
        fq_rd_pend = {};
        fq_rd_pend = btt_q.find_index() with (item.isRead && 
                                              (cl_aligned(item.ccp_addr) == cl_aligned(curr_wr_entry_addr)) &&
                                              item.security              == curr_wr_entry_security);
  
        if (fq_wr_pend.size() > 0) begin
            fq_wr_pend[0] = find_oldest_txn_in_btt_q(fq_wr_pend);
            next_wr_entry_t_scb_txn = btt_q[fq_wr_pend[0]].t_scb_txn;
        end
  
        if (fq_rd_pend.size() > 0) begin
           foreach (fq_rd_pend[i]) begin
              if ((fq_wr_pend.size() > 0)) begin
                 if ((btt_q[fq_rd_pend[i]].t_scb_txn > curr_wr_entry_t_scb_txn) &&
                     (btt_q[fq_rd_pend[i]].t_scb_txn < next_wr_entry_t_scb_txn)) begin
                    if (!isEvicted) give_read_cacheline_data(btt_q[fq_rd_pend[i]],btt_q[fq_rd_pend[i]].isBypassevict);
                    else give_read_evicted_cacheline_data(btt_q[fq_rd_pend[i]],btt_q[fq_rd_pend[i]].isBypassevict);

                    btt_q[fq_rd_pend[i]].isWritePending = 0;
                 end
              end else begin
                 if (btt_q[fq_rd_pend[i]].t_scb_txn > curr_wr_entry_t_scb_txn) begin
                    if (!isEvicted) give_read_cacheline_data(btt_q[fq_rd_pend[i]],btt_q[fq_rd_pend[i]].isBypassevict);
                    else give_read_evicted_cacheline_data(btt_q[fq_rd_pend[i]],btt_q[fq_rd_pend[i]].isBypassevict);

                    btt_q[fq_rd_pend[i]].isWritePending = 0;
                 end
              end
           end
        end

        btt_q[fq[0]].isWriteDataRcvd=1'b1;
        btt_q[fq[0]].isBypassDataRcvd=1'b1;

        if(btt_q[fq[0]].DeleteCl && !btt_q[fq[0]].isWritePending) begin
           fq_e = {};
           fq_e = btt_q.find_index() with (cl_aligned(item.evict_addr) == cl_aligned(btt_q[fq[0]].ccp_addr) &&
                                           item.isEvict    == 1'b1 &&
                                           item.isEvictDataAdded == 1'b0 &&
                                           item.evict_security == btt_q[fq[0]].security);
      
           give_evict_cacheline_data(btt_q[fq_e[0]],1,btt_q[fq_e[0]].ccp_index,btt_q[fq_e[0]].fillwayn, isEvicted);
           btt_q[fq_e[0]].isEvictDataAdded = 1;
        end
        if(btt_q[fq[0]].isCacheInvld || btt_q[fq[0]].DeleteCl)begin
          delete_evicted_cacheline(btt_q[fq[0]]);
        end

        if(!(btt_q[fq[0]].isBypassrdrsp | btt_q[fq[0]].isBypassevict)) begin
          btt_q[fq[0]].print_debug();
          btt_q.delete(fq[0]);
        end
      end else if(btt_q[fq[0]].isBypass && !btt_q[fq[0]].isWrite) begin
        burstln = m_wr_data_pkt.data.size();
        btt_q[fq[0]].isBypassDataRcvd=1'b1;
        btt_q[fq[0]].m_ccp_wr_data_pkt  = new();
        btt_q[fq[0]].m_ccp_wr_data_pkt.copy(m_wr_data_pkt);
        if(btt_q[fq[0]].isBypassrdrsp ) begin
           btt_q[fq[0]].m_ccp_exp_rd_rsp_pkt  = new();
           btt_q[fq[0]].m_ccp_exp_rd_rsp_pkt.data  = new[burstln];
           btt_q[fq[0]].m_ccp_exp_rd_rsp_pkt.poison  = new[burstln];
           btt_q[fq[0]].m_ccp_exp_rd_rsp_pkt.byten = new[burstln];
           btt_q[fq[0]].m_ccp_exp_rd_rsp_pkt.data  = m_wr_data_pkt.data;
           btt_q[fq[0]].m_ccp_exp_rd_rsp_pkt.poison  = m_wr_data_pkt.poison;
           btt_q[fq[0]].m_ccp_exp_rd_rsp_pkt.byten = m_wr_data_pkt.byten;
        end else if(btt_q[fq[0]].isBypassevict) begin
           btt_q[fq[0]].m_ccp_exp_evict_pkt       = new();
           btt_q[fq[0]].m_ccp_exp_evict_pkt.data  = new[burstln];
           btt_q[fq[0]].m_ccp_exp_evict_pkt.poison  = new[burstln];
           btt_q[fq[0]].m_ccp_exp_evict_pkt.byten = new[burstln];
           btt_q[fq[0]].m_ccp_exp_evict_pkt.data  = m_wr_data_pkt.data;
           btt_q[fq[0]].m_ccp_exp_evict_pkt.poison  = m_wr_data_pkt.poison;
           btt_q[fq[0]].m_ccp_exp_evict_pkt.byten = m_wr_data_pkt.byten;
        end
      end else if(btt_q[fq[0]].isWrite) begin
        btt_q[fq[0]].m_ccp_wr_data_pkt  = new();
        btt_q[fq[0]].m_ccp_wr_data_pkt.copy(m_wr_data_pkt);
        if (btt_q[fq[0]].isEvicted) begin
          merge_write_data_evicted(btt_q[fq[0]]);
        end else begin
          merge_write_data(btt_q[fq[0]]);
        end
        btt_q[fq[0]].isWriteDataRcvd=1'b1;

        // Read from reference model for the pending read transactions to check the data on rdrsp chnl
        fq_wr_pend = {};
        fq_wr_pend = btt_q.find_index() with (item.isWrite  && !item.isWriteDataRcvd && 
                                              (cl_aligned(item.ccp_addr) == cl_aligned(curr_wr_entry_addr)) &&
                                              item.security              == curr_wr_entry_security &&
                                              item.t_scb_txn             >  curr_wr_entry_t_scb_txn);
  
        fq_rd_pend = {};
        fq_rd_pend = btt_q.find_index() with (item.isRead && 
                                              (cl_aligned(item.ccp_addr) == cl_aligned(curr_wr_entry_addr)) &&
                                              item.security              == curr_wr_entry_security);
  
        if (fq_wr_pend.size() > 0) begin
            fq_wr_pend[0] = find_oldest_txn_in_btt_q(fq_wr_pend);
            next_wr_entry_t_scb_txn = btt_q[fq_wr_pend[0]].t_scb_txn;
        end
  
        if (fq_rd_pend.size() > 0) begin
           foreach (fq_rd_pend[i]) begin
              if ((fq_wr_pend.size() > 0)) begin
                 if ((btt_q[fq_rd_pend[i]].t_scb_txn > curr_wr_entry_t_scb_txn) &&
                     (btt_q[fq_rd_pend[i]].t_scb_txn < next_wr_entry_t_scb_txn)) begin
                    if (!isEvicted) give_read_cacheline_data(btt_q[fq_rd_pend[i]],btt_q[fq_rd_pend[i]].isBypassevict);
                    else give_read_evicted_cacheline_data(btt_q[fq_rd_pend[i]],btt_q[fq_rd_pend[i]].isBypassevict);

                    btt_q[fq_rd_pend[i]].isWritePending = 0;
                 end
              end else begin
                 if (btt_q[fq_rd_pend[i]].t_scb_txn > curr_wr_entry_t_scb_txn) begin
                    if (!isEvicted) give_read_cacheline_data(btt_q[fq_rd_pend[i]],btt_q[fq_rd_pend[i]].isBypassevict);
                    else give_read_evicted_cacheline_data(btt_q[fq_rd_pend[i]],btt_q[fq_rd_pend[i]].isBypassevict);

                    btt_q[fq_rd_pend[i]].isWritePending = 0;
                 end
              end
           end
        end

        if(btt_q[fq[0]].DeleteCl) begin
          fq_e = {};
          fq_e = btt_q.find_index() with (cl_aligned(item.evict_addr) == cl_aligned(btt_q[fq[0]].ccp_addr) &&
                                          item.isEvict                == 1'b1 &&
                                          item.isEvictDataAdded       == 1'b0 &&
                                          item.evict_security         == btt_q[fq[0]].security);

          btt_q[fq_e[0]].print_debug();
          give_evict_cacheline_data(btt_q[fq_e[0]],1,btt_q[fq_e[0]].ccp_index,btt_q[fq_e[0]].fillwayn, isEvicted);
          btt_q[fq_e[0]].isEvictDataAdded = 1;
        end

        if(btt_q[fq[0]].isCacheInvld || btt_q[fq[0]].DeleteCl)begin
          delete_evicted_cacheline(btt_q[fq[0]]);
        end
        
        if(!((btt_q[fq[0]].isBypassrdrsp && !btt_q[fq[0]].isReadDataRcvd) || (btt_q[fq[0]].isBypassevict && !btt_q[fq[0]].isEvictDataRcvd ))) begin
          btt_q[fq[0]].print_debug();
          btt_q.delete(fq[0]);
        end
      end
    end else begin
        print_queues();
        `uvm_info("<%=obj.BlockId%>:CCP-SCB", $sformatf("%t: ccp_wr_data_pkt: %s", $time, m_pkt.sprint_pkt()), UVM_MEDIUM);
       `uvm_error("<%=obj.BlockId%>:CCP-SCB", $psprintf("Couldn't match the write data pkt with any txns"))
    end
`endif    
endfunction

////////////////////////////////////////////////////////////////////////////////
//                                                                            
//          CCP Utility functions                                               
//                                                                            
// Section: Code implements the checks required to verify CCP.              
//
////////////////////////////////////////////////////////////////////////////////

//=========================================================================
// Function: give_read_cacheline_data 
// Purpose: 
// 
// 
//=========================================================================
function void ccp_scoreboard::give_read_cacheline_data(ref ccp_scb_txn ccp_pkt,input bit port_sel);
`ifndef INCA
    ccp_cache_rdrsp_data_t  data_a[];
    ccp_cache_rdrsp_data_t  m_data[];
    bit                     cpy_dataErrorPerBeat[];
    bit                     m_dataErrorPerBeat[];
    ccp_ctrlop_addr_t       wrap_addr;
    ccp_ctrlop_addr_t       m_ccpAddr;

    int      dataIndex;
    int      dataWay;
    int      no_of_bytes;
    int      burst_length;
    logic    security;
    longint  m_lower_wrapped_boundary;
    longint  m_upper_wrapped_boundary;
    longint  m_start_addr;
    string  sprint_pkt;


    bit [WCCPBEAT-1:0] data_beat;

    data_a                    = new[BURSTLN];
    cpy_dataErrorPerBeat      = new[BURSTLN];

    no_of_bytes               = (WCCPDATA/8);
    if(ccp_pkt.isWrTh)begin
      burst_length            = BURSTLN; 
    end
    else begin  
      burst_length            = ccp_pkt.m_ccp_ctrl_pkt.burstln+1;
    end

    //Caclulate the Wrap address based on the AXI spec
    m_start_addr             = ((ccp_pkt.m_ccp_ctrl_pkt.addr/(WCCPDATA/8)) * (WCCPDATA/8));
    m_lower_wrapped_boundary = ((ccp_pkt.m_ccp_ctrl_pkt.addr/(no_of_bytes * burst_length)) * (no_of_bytes*burst_length)); 
    m_upper_wrapped_boundary = m_lower_wrapped_boundary + (no_of_bytes * burst_length); 

    //Read the cachemodel and bring the entire cacheline
    //worth of data.
    m_ccpAddr                 = cl_aligned(ccp_pkt.ccp_addr);
    security                  = ccp_pkt.security;

    m_ccpCacheModel.give_wayIndex(.ccpAddr(m_ccpAddr),
                                 .security(security),
                                 .way(dataWay),
                                 .Index(dataIndex));

    m_ccpCacheModel.give_data(dataIndex,dataWay,data_a,cpy_dataErrorPerBeat);

    //Return the cacheline data
    //If arlen>0 => arsize [4] 
    //But arlen==0 => arsize [1-4] 
    data_beat = ccp_pkt.m_ccp_ctrl_pkt.addr[LINE_INDEX_HIGH:LINE_INDEX_LOW];
    if(burst_length >1) begin
        m_data                = new[burst_length];
        m_dataErrorPerBeat    = new[burst_length];
                                        
        for(int i=0; i<burst_length;i++) begin
            if((ccp_pkt.m_ccp_ctrl_pkt.burstwrap == 'h1) && (m_start_addr >= m_upper_wrapped_boundary)) begin
                data_beat    = m_lower_wrapped_boundary[LINE_INDEX_HIGH:LINE_INDEX_LOW];
                m_start_addr = m_lower_wrapped_boundary;
            end
            m_data[i]             = data_a[data_beat];
            m_dataErrorPerBeat[i] = cpy_dataErrorPerBeat[data_beat];
         `uvm_info("<%=obj.BlockId%>:CCP-SCB:give_read_cacheline_data",$sformatf("give read cacheline data_beat :%d data_a :%0x m_data :%0x",data_beat,data_a[data_beat],m_data[i]),UVM_HIGH);
            data_beat             = data_beat + 1'b1;
            m_start_addr          = m_start_addr + no_of_bytes;
        end
    end else begin
        m_data                = new[1];
        m_dataErrorPerBeat    = new[1];
        m_data[0]             = data_a[data_beat];
        m_dataErrorPerBeat[0] = cpy_dataErrorPerBeat[data_beat];
    end

    //Add the data to the expected packet
    if(!port_sel) begin
      ccp_pkt.m_ccp_exp_rd_rsp_pkt      = new();
      ccp_pkt.m_ccp_exp_rd_rsp_pkt.data = new[ccp_pkt.m_ccp_ctrl_pkt.burstln+1];
      ccp_pkt.m_ccp_exp_rd_rsp_pkt.data = m_data;
      ccp_pkt.m_ccp_exp_rd_rsp_pkt.poison = new[ccp_pkt.m_ccp_ctrl_pkt.burstln+1];
      ccp_pkt.m_ccp_exp_rd_rsp_pkt.poison = m_dataErrorPerBeat;
      uvm_report_info("<%=obj.BlockId%>:CCP-SCB:give_read_cacheline_data", $sformatf("m_ccp_exp_rd_rsp_pkt: %s",ccp_pkt.m_ccp_exp_rd_rsp_pkt.sprint_pkt()), UVM_MEDIUM);
    end  else begin
      ccp_pkt.m_ccp_exp_evict_pkt      = new();
      ccp_pkt.m_ccp_exp_evict_pkt.data = new[BURSTLN];
      ccp_pkt.m_ccp_exp_evict_pkt.data = m_data;
      ccp_pkt.m_ccp_exp_evict_pkt.poison = new[BURSTLN];
      ccp_pkt.m_ccp_exp_evict_pkt.poison = m_dataErrorPerBeat;
      uvm_report_info("<%=obj.BlockId%>:CCP-SCB:give_read_cacheline_data", $sformatf("m_ccp_exp_evict_pkt: %s",ccp_pkt.m_ccp_exp_evict_pkt.sprint_pkt()), UVM_MEDIUM);
    end
`endif
endfunction


//=========================================================================
// Function: give_read_evicted_cacheline_data 
// Purpose: 
// 
// 
//=========================================================================
function void ccp_scoreboard::give_read_evicted_cacheline_data(ref ccp_scb_txn ccp_pkt,input bit port_sel);
`ifndef INCA
    ccp_cache_rdrsp_data_t  data_a[];
    ccp_cache_rdrsp_data_t  m_data[];
    bit                     cpy_dataErrorPerBeat[];
    bit                     m_dataErrorPerBeat[];
    ccp_ctrlop_addr_t       wrap_addr;
    ccp_ctrlop_addr_t       m_ccpAddr;

    int      dataIndex;
    int      dataWay;
    int      no_of_bytes;
    int      burst_length;
    logic    security;
    longint  m_lower_wrapped_boundary;
    longint  m_upper_wrapped_boundary;
    longint  m_start_addr;
    string  sprint_pkt;

    int tmp_q[$];


    bit [WCCPBEAT-1:0] data_beat;

    data_a                    = new[BURSTLN];
    cpy_dataErrorPerBeat      = new[BURSTLN];

    no_of_bytes               = (WCCPDATA/8);
    if(ccp_pkt.isWrTh)begin
      burst_length            = BURSTLN; 
    end
    else begin  
      burst_length            = ccp_pkt.m_ccp_ctrl_pkt.burstln+1;
    end

    //Caclulate the Wrap address based on the AXI spec
    m_start_addr             = ((ccp_pkt.m_ccp_ctrl_pkt.addr/(WCCPDATA/8)) * (WCCPDATA/8));
    m_lower_wrapped_boundary = ((ccp_pkt.m_ccp_ctrl_pkt.addr/(no_of_bytes * burst_length)) * (no_of_bytes*burst_length)); 
    m_upper_wrapped_boundary = m_lower_wrapped_boundary + (no_of_bytes * burst_length); 

    //Read the cache model and bring the entire cacheline
    //worth of data.
    m_ccpAddr                 = cl_aligned(ccp_pkt.ccp_addr);
    security                  = ccp_pkt.security;

    tmp_q = {};
    tmp_q = evicted_cachelines.find_index() with (cl_aligned(item.addr) == cl_aligned(m_ccpAddr) &&
                                                  item.security == security);
    if (tmp_q.size() == 0) begin
       uvm_report_error("<%=obj.blockid%>:ccp-scb", $sformatf("no entry found in evicted_cachelines to merge"), UVM_NONE);
    end

    data_a = evicted_cachelines[tmp_q[0]].data;
    cpy_dataErrorPerBeat = evicted_cachelines[tmp_q[0]].dataErrorPerBeat;

    //Return the cacheline data
    //If arlen>0 => arsize [4] 
    //But arlen==0 => arsize [1-4] 
    data_beat = ccp_pkt.m_ccp_ctrl_pkt.addr[LINE_INDEX_HIGH:LINE_INDEX_LOW];
    if(burst_length >1) begin
        m_data                = new[burst_length];
        m_dataErrorPerBeat    = new[burst_length];
                                        
        for(int i=0; i<burst_length;i++) begin
            if((ccp_pkt.m_ccp_ctrl_pkt.burstwrap == 'h1) && (m_start_addr >= m_upper_wrapped_boundary)) begin
                data_beat    = m_lower_wrapped_boundary[LINE_INDEX_HIGH:LINE_INDEX_LOW];
                m_start_addr = m_lower_wrapped_boundary;
            end
            m_data[i]             = data_a[data_beat];
            m_dataErrorPerBeat[i] = cpy_dataErrorPerBeat[data_beat];
         `uvm_info("<%=obj.BlockId%>:CCP-SCB:give_read_evicted_cacheline_data",$sformatf("give read cacheline data_beat :%d data_a :%0x m_data :%0x",data_beat,data_a[data_beat],m_data[i]),UVM_HIGH);
            data_beat             = data_beat + 1'b1;
            m_start_addr          = m_start_addr + no_of_bytes;
        end
    end else begin
        m_data                = new[1];
        m_dataErrorPerBeat    = new[1];
        m_data[0]             = data_a[data_beat];
        m_dataErrorPerBeat[0] = cpy_dataErrorPerBeat[data_beat];
    end

    //Add the data to the expected packet
    if(!port_sel) begin
      ccp_pkt.m_ccp_exp_rd_rsp_pkt      = new();
      ccp_pkt.m_ccp_exp_rd_rsp_pkt.data = new[ccp_pkt.m_ccp_ctrl_pkt.burstln+1];
      ccp_pkt.m_ccp_exp_rd_rsp_pkt.data = m_data;
      ccp_pkt.m_ccp_exp_rd_rsp_pkt.poison = new[ccp_pkt.m_ccp_ctrl_pkt.burstln+1];
      ccp_pkt.m_ccp_exp_rd_rsp_pkt.poison = m_dataErrorPerBeat;
      uvm_report_info("<%=obj.BlockId%>:CCP-SCB:give_read_evicted_cacheline_data", $sformatf("m_ccp_exp_rd_rsp_pkt: %s",ccp_pkt.m_ccp_exp_rd_rsp_pkt.sprint_pkt()), UVM_MEDIUM);
    end  else begin
      ccp_pkt.m_ccp_exp_evict_pkt      = new();
      ccp_pkt.m_ccp_exp_evict_pkt.data = new[BURSTLN];
      ccp_pkt.m_ccp_exp_evict_pkt.data = m_data;
      ccp_pkt.m_ccp_exp_evict_pkt.poison = new[BURSTLN];
      ccp_pkt.m_ccp_exp_evict_pkt.poison = m_dataErrorPerBeat;
      uvm_report_info("<%=obj.BlockId%>:CCP-SCB:give_read_evicted_cacheline_data", $sformatf("m_ccp_exp_evict_pkt: %s",ccp_pkt.m_ccp_exp_evict_pkt.sprint_pkt()), UVM_MEDIUM);
    end
`endif
endfunction

//=========================================================================
// Function: give_evict_cacheline_data 
// Purpose: 
// 
// 
//=========================================================================
function void ccp_scoreboard::give_evict_cacheline_data(ref ccp_scb_txn ccp_pkt,input bit port_sel,int dataIndex,int dataWay, bit isEvicted=0);
`ifndef INCA
    ccp_cache_rdrsp_data_t  data_a[];
    ccp_cache_rdrsp_data_t  m_data[];
    bit                     cpy_dataErrorPerBeat[];
    bit                     m_dataErrorPerBeat[];
    ccp_ctrlop_addr_t       wrap_addr;

    int      no_of_bytes;
    int      burst_length;
    logic    security;
    longint  m_lower_wrapped_boundary;
    longint  m_upper_wrapped_boundary;
    longint  m_start_addr;
    string  sprint_pkt;

    int tmp_q[$];


    bit [WCCPBEAT-1:0] data_beat;

    data_a                    = new[BURSTLN];
    cpy_dataErrorPerBeat      = new[BURSTLN];

    no_of_bytes               = (WCCPDATA/8);
    burst_length              = BURSTLN;
    security                  = ccp_pkt.evict_security;


    //Caclulate the Wrap address based on the AXI spec
    m_start_addr             = ((ccp_pkt.evict_addr/(WCCPDATA/8)) * (WCCPDATA/8));
    m_lower_wrapped_boundary = ((ccp_pkt.evict_addr/(no_of_bytes * burst_length)) * (no_of_bytes*burst_length)); 
    m_upper_wrapped_boundary = m_lower_wrapped_boundary + (no_of_bytes * burst_length); 


    //Read the cachemodel and bring the entire cacheline
    //worth of data.
   // m_ccpCacheModel.give_wayIndex(.ccpAddr(ccp_pkt.evict_addr),
   //                              .security(ccp_pkt.evict_security),
   //                              .way(dataWay),
   //                              .Index(dataIndex));

    if (!isEvicted) begin
       m_ccpCacheModel.give_data(dataIndex,dataWay,data_a,cpy_dataErrorPerBeat);
    end else begin
       tmp_q = {};
       tmp_q = evicted_cachelines.find_index() with (cl_aligned(item.addr) == cl_aligned(ccp_pkt.evict_addr) &&
                                                     item.security == ccp_pkt.evict_security);
       if (tmp_q.size() == 0) begin
          uvm_report_error("<%=obj.blockid%>:ccp-scb", $sformatf("no entry found in evicted_cachelines to merge"), UVM_NONE);
       end
       data_a = evicted_cachelines[tmp_q[0]].data;
       cpy_dataErrorPerBeat = evicted_cachelines[tmp_q[0]].dataErrorPerBeat;
    end

    //Return the cacheline data
    //If arlen>0 => arsize [4] 
    //But arlen==0 => arsize [1-4] 
        data_beat = ccp_pkt.evict_addr[LINE_INDEX_HIGH:LINE_INDEX_LOW];
        m_data                = new[BURSTLN];
        m_dataErrorPerBeat    = new[BURSTLN];
                                        
        for(int i=0; i<burst_length;i++) begin
            //if( m_start_addr >= m_upper_wrapped_boundary) begin
            //    data_beat    = m_lower_wrapped_boundary[LINE_INDEX_HIGH:LINE_INDEX_LOW];
            //    m_start_addr = m_lower_wrapped_boundary;
            //end 
            m_data[i]             = data_a[data_beat];
            m_dataErrorPerBeat[i] = cpy_dataErrorPerBeat[data_beat];
         `uvm_info("<%=obj.BlockId%>:CCP-SCB:give_evict_cacheline_data",$sformatf("give read cacheline data_beat :%d data_a :%0x m_data :%0x",data_beat,data_a[data_beat],m_data[i]),UVM_HIGH);
            data_beat             = data_beat + 1'b1;
            m_start_addr          = m_start_addr + no_of_bytes;
        end


      ccp_pkt.m_ccp_exp_evict_pkt      = new();
      ccp_pkt.m_ccp_exp_evict_pkt.data = new[BURSTLN];
      ccp_pkt.m_ccp_exp_evict_pkt.data = m_data;
      ccp_pkt.m_ccp_exp_evict_pkt.poison = new[BURSTLN];
      ccp_pkt.m_ccp_exp_evict_pkt.poison = m_dataErrorPerBeat;
      uvm_report_info("<%=obj.BlockId%>:CCP-SCB:give_evict_cacheline_data", $sformatf("m_ccp_exp_evict_pkt: %s",ccp_pkt.m_ccp_exp_evict_pkt.sprint_pkt()), UVM_MEDIUM);
`endif
endfunction

//=========================================================================
// Function: stor_read_cacheline_data 
// Purpose: 
// 
// 
//=========================================================================
function void ccp_scoreboard::store_read_cacheline_data(ref ccp_scb_txn ccp_pkt);
`ifndef INCA
    ccp_cache_rdrsp_data_t  data_a[];
    ccp_ctrlfill_data_t  m_data[];
    ccp_ctrlop_addr_t    m_ccpAddr;
    bit                  cpy_dataErrorPerBeat[];
    bit                  m_dataErrorPerBeat[];

    int                  dataIndex;
    int                  dataWay;
    int                  no_of_bytes;
    int                  burst_length;
    logic                security;
    string               spkt;
    
    bit [WCCPBEAT-1:0]         data_beat;
    data_a                      = new[BURSTLN];
    cpy_dataErrorPerBeat        = new[BURSTLN];

    no_of_bytes                 = (WCCPDATA/8) ;
    burst_length                =  BURSTLN;

    //Read the cachemodel and bring the entire cacheline
    //worth of data.
    //cpy_data = scbdata.m_ccp_fill_data_pkt.data;
    
    `uvm_info("CCP SB:store_read_cacheline_data",$sformatf("m_ccp_addr :%0x security :%0b ",ccp_pkt.m_ccp_fill_data_pkt.addr,ccp_pkt.security),UVM_MEDIUM); 
    //Write the cacheline
    m_ccpAddr                 = cl_aligned(ccp_pkt.ccp_addr);
    security                  = ccp_pkt.security;
   
    m_ccpCacheModel.give_wayIndex(.ccpAddr(m_ccpAddr),
                                 .security(security),
                                 .way(dataWay),
                                 .Index(dataIndex));


    //Return the cacheline data
    //If arlen>0 => arsize [4] 
    //But arlen==0 => arsize [1-16] 
    data_beat          = ccp_pkt.m_ccp_ctrl_pkt.addr[LINE_INDEX_HIGH:LINE_INDEX_LOW];
    m_data             = new[burst_length];
    m_dataErrorPerBeat = new[burst_length];

    m_ccpCacheModel.give_data(dataIndex,dataWay,data_a,cpy_dataErrorPerBeat);
    for(int i=0; i<burst_length;i++) begin
       m_data[i]             = data_a[i];
       m_dataErrorPerBeat[i] = cpy_dataErrorPerBeat[i];
    end
    for(int i=0; i<ccp_pkt.m_ccp_fill_data_pkt.data.size();i++) begin
       //Adjust data according to byte en
       for (int idx=0; idx < WCCPBYTEEN; idx++) begin
          if (ccp_pkt.m_ccp_fill_data_pkt.byten[i][idx]) begin
             m_data[ccp_pkt.m_ccp_fill_data_pkt.beatn[i]][8*idx +: 8]  = ccp_pkt.m_ccp_fill_data_pkt.data[i][8*idx +: 8];
          end // if byte en == 1
       end // byte enable for loop
       m_dataErrorPerBeat[ccp_pkt.m_ccp_fill_data_pkt.beatn[i]] =ccp_pkt.m_ccp_fill_data_pkt.poison[i];
    end

    m_ccpCacheModel.modify_data(dataIndex,dataWay,m_data,m_dataErrorPerBeat);
`endif                
endfunction


//=========================================================================
// Function: merge_write_data 
// Purpose: 
// 
// 
//=========================================================================
function void ccp_scoreboard::merge_write_data( ref ccp_scb_txn ccp_pkt);
`ifndef INCA
    ccp_ctrlwr_data_t    full_cache_data[];
    ccp_ctrlwr_data_t    merge_data[];
    ccp_ctrlwr_byten_t   byten[];
    ccp_ctrlwr_data_t    cpy_sfi_data[];
    ccp_ctrlop_addr_t    m_ccpAddr;
    int                  temp_q[$];
    bit                  cpy_dataErrorPerBeat[];
    bit                  tmp_dataErrorPerBeat[];
    ccp_ctrlop_addr_t    wrap_addr;
    int                  no_of_bytes;
    int                  burst_length;
    string               sprint_pkt;
    logic                security;
    longint              m_lower_wrapped_boundary;
    longint              m_upper_wrapped_boundary;
    longint              m_start_addr;
    int                  dataIndex;
    int                  dataWay;
    bit [WCCPBEAT-1:0]         data_beat;


    no_of_bytes               = (WCCPDATA/8);
    burst_length              = ccp_pkt.m_ccp_ctrl_pkt.burstln+1;
    `uvm_info("<%=obj.BlockId%>:CCP-SCB:merge_write_data", $sformatf("m_ccp_ctrl_pkt: %s",ccp_pkt.m_ccp_ctrl_pkt.sprint_pkt()), UVM_MEDIUM);
    `uvm_info("<%=obj.BlockId%>:CCP-SCB:merge_write_data", $sformatf("ctrlwrpkt: %s",ccp_pkt.m_ccp_wr_data_pkt.sprint_pkt()), UVM_MEDIUM);

    //For a wrap the SFI data will be returned in critical beat
    //first so i need to store the data correctly.
    m_ccpAddr                 = cl_aligned(ccp_pkt.ccp_addr);
    security                  = ccp_pkt.security;
    m_ccpCacheModel.give_wayIndex(.ccpAddr(m_ccpAddr),
                                 .security(security),
                                 .way(dataWay),
                                 .Index(dataIndex));

    m_ccpCacheModel.give_data(dataIndex,dataWay,full_cache_data,cpy_dataErrorPerBeat);
    merge_data            = new[burst_length];
    byten                 = new[burst_length];
    merge_data            = ccp_pkt.m_ccp_wr_data_pkt.data;
    byten                 = ccp_pkt.m_ccp_wr_data_pkt.byten;

    //Caclulate the Wrap address based on the AXI spec

    <% if (obj.wSecurityAttribute > 0) { %>
    security    = ccp_pkt.m_ccp_ctrl_pkt.security; 
    <%}else{%>
    security    = 0;
    <%}%>
    //Update the cacheline data

    
    m_start_addr             = ((ccp_pkt.m_ccp_ctrl_pkt.addr/(WCCPDATA/8)) * (WCCPDATA/8));
    for(int i=0; i<burst_length;i++) begin
        data_beat = ccp_pkt.m_ccp_wr_data_pkt.beatn[i];
        

        `uvm_info("<%=obj.BlockId%>:CCP-SCB:merge_write_data",$psprintf("BEAT:%0d and Start Addr:%0h",data_beat,m_start_addr),UVM_MEDIUM)

        for(int index_bit=0; index_bit<no_of_bytes;index_bit++) begin
            if(ccp_pkt.m_ccp_wr_data_pkt.byten[i][index_bit] == 1'b1) begin
                full_cache_data[data_beat][(8*index_bit) +: 8] = 
                merge_data[i][(8*index_bit) +: 8];
            end
        end

        if(cpy_dataErrorPerBeat[data_beat] == 1'b1)begin
            if(&(byten[data_beat]))begin
                cpy_dataErrorPerBeat[data_beat]  = ccp_pkt.m_ccp_wr_data_pkt.poison[data_beat];
            end 
        end else begin
            cpy_dataErrorPerBeat[data_beat]  = ccp_pkt.m_ccp_wr_data_pkt.poison[data_beat];
        end
        
    end

    //Write the merge data to the cache model.
    m_ccpCacheModel.modify_data(dataIndex,dataWay,full_cache_data,cpy_dataErrorPerBeat);
`endif
endfunction

//=========================================================================
// Function: merge_write_data_evicted
// Purpose: 
// 
// 
//=========================================================================
function void ccp_scoreboard::merge_write_data_evicted( ref ccp_scb_txn ccp_pkt);
`ifndef INCA
    ccp_ctrlwr_data_t    full_cache_data[];
    ccp_ctrlwr_data_t    merge_data[];
    ccp_ctrlwr_byten_t   byten[];
    ccp_ctrlwr_data_t    cpy_sfi_data[];
    ccp_ctrlop_addr_t    m_ccpAddr;
    int                  tmp_q[$];
    bit                  cpy_dataErrorPerBeat[];
    bit                  tmp_dataErrorPerBeat[];
    ccp_ctrlop_addr_t    wrap_addr;
    int                  no_of_bytes;
    int                  burst_length;
    string               sprint_pkt;
    logic                security;
    longint              m_lower_wrapped_boundary;
    longint              m_upper_wrapped_boundary;
    longint              m_start_addr;
    int                  dataIndex;
    int                  dataWay;
    bit [WCCPBEAT-1:0]         data_beat;


    no_of_bytes               = (WCCPDATA/8);
    burst_length              = ccp_pkt.m_ccp_ctrl_pkt.burstln+1;
    `uvm_info("<%=obj.BlockId%>:CCP-SCB:merge_write_data", $sformatf("m_ccp_ctrl_pkt: %s",ccp_pkt.m_ccp_ctrl_pkt.sprint_pkt()), UVM_MEDIUM);
    `uvm_info("<%=obj.BlockId%>:CCP-SCB:merge_write_data", $sformatf("ctrlwrpkt: %s",ccp_pkt.m_ccp_wr_data_pkt.sprint_pkt()), UVM_MEDIUM);

    //For a wrap the SFI data will be returned in critical beat
    //first so i need to store the data correctly.
    m_ccpAddr                 = cl_aligned(ccp_pkt.ccp_addr);
    security                  = ccp_pkt.security;
    tmp_q = {};
    tmp_q = evicted_cachelines.find_index() with (cl_aligned(item.addr) == cl_aligned(m_ccpAddr) &&
                                                  item.security == security);
    if (tmp_q.size() == 0) begin
       uvm_report_error("<%=obj.blockid%>:ccp-scb", $sformatf("no entry found in evicted_cachelines to merge"), UVM_NONE);
    end

    full_cache_data = evicted_cachelines[tmp_q[0]].data;
    cpy_dataErrorPerBeat = evicted_cachelines[tmp_q[0]].dataErrorPerBeat;

    merge_data            = new[burst_length];
    byten                 = new[burst_length];
    merge_data            = ccp_pkt.m_ccp_wr_data_pkt.data;
    byten                 = ccp_pkt.m_ccp_wr_data_pkt.byten;

    //Caclulate the Wrap address based on the AXI spec
    <% if (obj.wSecurityAttribute > 0) { %>
    security    = ccp_pkt.m_ccp_ctrl_pkt.security; 
    <%}else{%>
    security    = 0;
    <%}%>

    //Update the cacheline data
    m_start_addr = ((ccp_pkt.m_ccp_ctrl_pkt.addr/(WCCPDATA/8)) * (WCCPDATA/8));
    for(int i=0; i<burst_length;i++) begin
        data_beat = ccp_pkt.m_ccp_wr_data_pkt.beatn[i];
        `uvm_info("<%=obj.BlockId%>:CCP-SCB:merge_write_data",$psprintf("BEAT:%0d and Start Addr:%0h",data_beat,m_start_addr),UVM_MEDIUM)

        for(int index_bit=0; index_bit<no_of_bytes;index_bit++) begin
            if(ccp_pkt.m_ccp_wr_data_pkt.byten[i][index_bit] == 1'b1) begin
                full_cache_data[data_beat][(8*index_bit) +: 8] = 
                merge_data[i][(8*index_bit) +: 8];
            end
        end

        if(cpy_dataErrorPerBeat[data_beat] == 1'b1)begin
            if(&(byten[data_beat]))begin
                cpy_dataErrorPerBeat[data_beat]  = ccp_pkt.m_ccp_wr_data_pkt.poison[data_beat];
            end 
        end else begin
            cpy_dataErrorPerBeat[data_beat]  = ccp_pkt.m_ccp_wr_data_pkt.poison[data_beat];
        end
    end

    //Write the merge data to the cache model.
    evicted_cachelines[tmp_q[0]].data = full_cache_data;
    evicted_cachelines[tmp_q[0]].dataErrorPerBeat = cpy_dataErrorPerBeat;

    m_ccpCacheModel.ccpCacheSet[evicted_cachelines[tmp_q[0]].Index][evicted_cachelines[tmp_q[0]].way].data             = full_cache_data;
    m_ccpCacheModel.ccpCacheSet[evicted_cachelines[tmp_q[0]].Index][evicted_cachelines[tmp_q[0]].way].dataErrorPerBeat = cpy_dataErrorPerBeat;
`endif
endfunction


function ccp_ctrlop_addr_t ccp_scoreboard::cl_aligned(ccp_ctrlop_addr_t addr);
   ccp_ctrlop_addr_t cl_aligned_addr;
   cl_aligned_addr = (addr >> <%=obj.wCacheLineOffset%>);
   cl_aligned_addr = (cl_aligned_addr << <%=obj.wCacheLineOffset%>);
   return cl_aligned_addr;
endfunction // cl_aligned


//-----------------------------------------------------------------------
// Function to find oldest btt entry
//-----------------------------------------------------------------------
function int ccp_scoreboard::find_oldest_txn_in_btt_q(int m_tmp_q[$]);
    time t_tmp_time;
    int  m_tmp_indx;
    t_tmp_time = btt_q[m_tmp_q[0]].t_scb_txn;
    m_tmp_indx = m_tmp_q[0];
    for (int i = 1; i < m_tmp_q.size(); i++) begin
        if (t_tmp_time > btt_q[m_tmp_q[i]].t_scb_txn) begin
            t_tmp_time = btt_q[m_tmp_q[i]].t_scb_txn;
            m_tmp_indx = m_tmp_q[i];
        end
        // Sanity check below
        else if (t_tmp_time == btt_q[m_tmp_q[i]].t_scb_txn) begin
            btt_q[m_tmp_indx].print_debug();
            btt_q[i].print_debug();
            uvm_report_error("<%=obj.blockid%>:ccp-scb", $sformatf("above two requests came on ccp control",
                                                                   " interface at the same time"), UVM_NONE);
        end
    end
    return m_tmp_indx;
endfunction : find_oldest_txn_in_btt_q


//=========================================================================
// Function: delete_btt_entry 
// Purpose: 
// 
// 
//=========================================================================
function void ccp_scoreboard::delete_btt_entry(int indx);
`ifndef INCA
    //Ready to delete BTT entry
    btt_q.delete(indx);
`endif
endfunction


//=========================================================================
// Function: delete_evicted_cacheline 
// Purpose: 
// 
// 
//=========================================================================
function void ccp_scoreboard::delete_evicted_cacheline( ref ccp_scb_txn ccp_pkt);
   int tmp_q[$];
   tmp_q = {};
   tmp_q = evicted_cachelines.find_index() with (cl_aligned(item.addr) == cl_aligned(ccp_pkt.ccp_addr) &&
                                                 item.security == ccp_pkt.security);
   if (tmp_q.size() > 0) begin
      `uvm_info("", $sformatf("deleting entry in evicted_q"), UVM_NONE);
      evicted_cachelines.delete(tmp_q[0]);
   end else begin
      uvm_report_error("<%=obj.blockid%>:ccp-scb", $sformatf("no entry found in evicted_cachelines to delete"), UVM_NONE);
   end
endfunction
