//---------------------------------------------------------------------
// CCP Data In packet
//---------------------------------------------------------------------
<% var cmcUncorr = 0;
 if((obj.useCmc > 0) && (obj.DmiInfo[obj.Id].ccpParams.DataErrInfo.substring(0,4) !== "NONE" || obj.DmiInfo[obj.Id].ccpParams.TagErrInfo.substring(0,6)  !== "NONE")) { 
    cmcUncorr = 1;
}
%>


 class ccp_wr_data_pkt_t extends uvm_object;


  rand  ccp_ctrlwr_data_t           data[];
  rand  ccp_ctrlwr_byten_t          byten[];
  rand  ccp_ctrlwr_beatn_t          beatn[];
  rand  bit                         last;
  rand  bit                         poison[];
  time                              timestamp[];
  time                              t_pkt_seen_on_intf;

  `uvm_object_param_utils_begin(ccp_wr_data_pkt_t)
        `uvm_field_array_int     (data, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (byten, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (beatn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (last, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (poison, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (timestamp, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT)

  `uvm_object_utils_end

   
   function new(string name = "ccp_wr_data_pkt_t");

   endfunction : new
 
   constraint c_datasize {  data.size() == BURSTLN;}  

   constraint c_bytensize { byten.size() == BURSTLN;}  

   constraint c_beatnsize { beatn.size() == BURSTLN;}  

   constraint c_poison { poison.size() == BURSTLN;}  

   constraint cc_poison  {  foreach(poison[i]){
                                  poison[i] == 0};}  

   function string sprint_pkt();
      string 			    s;
        s = $sformatf("beat0:0x%0d Data0:0x%0x poison0 :%0b Byten0:0x%0x Time:%0t "
            ,beatn[0],data[0],poison[0],byten[0], t_pkt_seen_on_intf);  
        
        if(data.size() > 0) begin
            for (int i = 1; i < data.size(); i++) begin
                s = {s, $sformatf("Beat%0d:0x%0x ByteEn%0d:0x%0x Data%0d:0x%0x poison%0d :%0b "
                ,i, beatn[i],i, byten[i], i,data[i],i,poison[i])};
            end
        end else begin
            s = {s, " Data0:0x0"};
        end
        return s;
   endfunction : sprint_pkt

   function bit do_compare_pkts(ccp_wr_data_pkt_t m_pkt);
       bit done =1;
       foreach (this.poison[i]) begin
         if (this.poison[i] !== m_pkt.poison[i]) begin
             uvm_report_info(get_full_name(), $sformatf("ERROR beat:%0d Expected: poison bit: %0b Actual: poison bit: %0b",i,this.poison[i], m_pkt.poison[i]), UVM_NONE); 
             done = 0;
         end
       end
       if (this.data.size() !== m_pkt.data.size()) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlwr_data size: 0x%0d Actual: data size: 0x%0d", this.data.size(), m_pkt.data.size()), UVM_NONE); 
           done = 0;
       end
       foreach (this.data[i]) begin
         if (this.data[i] !== m_pkt.data[i]) begin
           if (!this.poison[i]) begin
              foreach(this.byten[,j]) begin
                if(this.byten[i][j])begin
                  if (this.data[i][j*8+:8] !== m_pkt.data[i][j*8+:8]) begin
                   uvm_report_info(get_full_name(), $sformatf("ERROR  beat:%0d byteen[%0d][%0d]:%0b Expected: ctrlwr_data: 0x%0x Actual: ctrlwr_data: 0x%0x",this.beatn[i],i,j,this.byten[i][j],this.data[i][j*8+:8], m_pkt.data[i][j*8+:8]), UVM_NONE); 
                   done = 0;
                  end
                end
              end
           end
         end
       end
       if (this.byten.size() !== m_pkt.byten.size()) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlwr_byten size: 0x%0d Actual: ctrlwr_byten size: 0x%0d",this.byten.size(), m_pkt.byten.size()), UVM_NONE); 
           done = 0;
       end
       foreach (this.byten[i]) begin
           if (this.byten[i] !== m_pkt.byten[i]) begin
               uvm_report_info(get_full_name(), $sformatf("ERROR  beat:%0d Expected: ctrlwr_byten: 0x%0x Actual: ctrlwr_byten: 0x%0x", i, this.byten[i], m_pkt.byten[i]), UVM_NONE); 
               done = 0;
           end
       end
       foreach (this.beatn[i]) begin
         if (this.beatn[i] !== m_pkt.beatn[i]) begin
             uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlwr_beatn: %d Actual: ctrlwr_beatn: %d", this.beatn[i], m_pkt.beatn[i]), UVM_NONE); 
             done = 0;
         end
       end
       return done;
   endfunction : do_compare_pkts
 endclass:ccp_wr_data_pkt_t

//---------------------------------------------------------------------
// CCP control and status  packet
//---------------------------------------------------------------------


 class ccp_ctrl_pkt_t extends uvm_object;

  rand  ccp_ctrlop_bank_t             bnk;
  rand  ccp_ctrlop_addr_t             addr;
  rand  ccp_ctrlop_security_t         security; 
  rand  ccp_ctrlop_allocate_t         alloc;
  rand  ccp_ctrlop_rd_data_t          rd_data;
  rand  ccp_ctrlop_wr_data_t          wr_data;
  rand  ccp_ctrlop_port_sel_t         rsp_evict_sel;
  rand  ccp_ctrlop_bypass_t           bypass;
  rand  ccp_ctrlop_rp_update_t        rp_update;
  rand  ccp_ctrlop_tag_state_update_t tagstateup;
  rand  ccp_cachestate_enum_t         state;
  rand  ccp_ctrlop_burstln_t          burstln;
  rand  ccp_ctrlop_burstwrap_t        burstwrap;
  rand  ccp_ctrlop_setway_debug_t     setway_debug;
  rand  ccp_ctrlop_waybusy_vec_t      waypbusy_vec;
  rand  ccp_ctrlop_waystale_vec_t     waystale_vec;
  rand  int                           setindex;
  rand  ccp_cachestate_enum_t         currstate;
  rand  ccp_cache_nru_vec_logic_t     currnruvec ;
  rand  ccp_cache_alloc_wayn_t        wayn ;
  rand  ccp_cache_hit_wayn_t          hitwayn ;
  rand  ccp_cache_evict_vld_t         evictvld;
  rand  ccp_cache_evictaddr_t         evictaddr;
  rand  ccp_cache_evictsecurity_t     evictsecurity;
  rand  ccp_cachestate_enum_t         evictstate;
  rand  ccp_cache_nackuce_t           nackuce;
  rand  ccp_cache_nack_t              nack;
  rand  ccp_cache_nackce_t            nackce;
  rand  ccp_cachenacknoalloc_t        nacknoalloc;
  rand  ccp_cachenoways2alloc_t       noways2alloc;
  rand  ccp_ctrlop_cancel_t           cancel;
  rand  bit                           lookup_p2;
  rand  bit                           t_pt_err;
  rand  int                           pt_id;
  rand  bit                           cachevld;
  rand  csr_maint_wrdata_t            wrdata;
  rand  csr_maint_req_data_t          reqdata;
  rand  csr_maint_rddata_t            rddata;
  rand  csr_maint_req_opc_t           opcode;
  rand  csr_maint_req_way_t           mntwayn;
  rand  csr_maint_req_entry_t         entry;
  rand  csr_maint_req_word_t          word;
  rand  csr_maint_req_array_sel_t     arraysel;
  rand  csr_maint_active_t            active;
  rand  csr_maint_rddata_en_t         rddata_en;

  longint unsigned                  cycle_count;
  bit   isRead;
  bit   retry;
  bit   isWrite;
  bit   isSnoop;
  bit   isMntOp;
  bit   isRead_Wakeup;
  bit   isWrite_Wakeup;
  bit   isSnoop_Wakeup;
  bit   write_upgrade;
  bit   stale_vec_flag;

  bit   read_hit;
  bit   read_miss_allocate;
  bit   write_hit;
  bit   write_miss_allocate;
  bit   snoop_hit;
  bit   write_hit_upgrade;

  bit   isReplay;
  bit   toReplay;
  bit   isRecycle;
  bit   isRecycleFailed;
  bit   isRplyVld;
  bit   isRttfull;
  bit   isWttfull;
  bit   isWttanyfull;
  bit   isWrfifofull;
  bit   isHntdropped;
  bit   cancel_p2;
  bit   ccp_tt_full_p2;
  bit   wr_addr_fifo_full;
  bit   [WSMIMSG-1:0]  msgType;
  bit   [WSMIMSG-1:0]  msgType_p0;
  bit  isCoh;
  bit   flush_fail_p2;
  bit   isRecycle_p1;

  time                                timestamp ;
  time                                t_pkt_seen_on_intf;
  int                                 nru_counter;
  
  int                                 posedge_count;

  bit [N_WAY-1:0]                    fake_hit_way;

  //for coverage
  bit b2b_same_index;
  bit b2b_same_addr = 1;

  `uvm_object_param_utils_begin(ccp_ctrl_pkt_t)
        `uvm_field_int         (bnk                   , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (addr                  , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (security              , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (alloc                 , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (rd_data               , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (wr_data               , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (rsp_evict_sel         , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (bypass                , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (rp_update             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (tagstateup            , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_enum        (ccp_cachestate_enum_t , state                      , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (burstln               , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (burstwrap             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (setway_debug          , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (waypbusy_vec           , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (waystale_vec          , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (cachevld              , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_enum        (ccp_cachestate_enum_t , currstate                  , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (currnruvec             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (setindex             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (wayn             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (hitwayn               , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (fake_hit_way          , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (evictvld              , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (evictaddr             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (evictsecurity         , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_enum        (ccp_cachestate_enum_t , evictstate                 , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (nackuce               , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (nack                  , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (nackce                , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (nacknoalloc           , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (noways2alloc          , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (cancel                , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (t_pt_err              , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (lookup_p2             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (pt_id                 , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (retry                 , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isRead                , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isWrite               , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isSnoop               , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isMntOp               , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isRead_Wakeup         , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isWrite_Wakeup        , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isSnoop_Wakeup        , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (write_upgrade         , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (stale_vec_flag        , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (wrdata                , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (rddata                , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (reqdata               , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (opcode                , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (mntwayn                  , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (entry                 , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (word                  , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (arraysel              , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (active                , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (rddata_en               , UVM_DEFAULT + UVM_NOPRINT)

        `uvm_field_int         (read_hit              , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (read_miss_allocate    , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (write_hit             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (write_miss_allocate   , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (snoop_hit             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (write_hit_upgrade     , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isReplay              , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (toReplay              , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isRecycle             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isRecycleFailed       , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isRplyVld             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (cancel_p2             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (ccp_tt_full_p2        , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (flush_fail_p2         , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isRttfull             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isWttfull             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isWttanyfull          , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isWrfifofull          , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isHntdropped          , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (msgType               , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (msgType_p0            , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isCoh                 , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (timestamp             , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (t_pkt_seen_on_intf    , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (nru_counter           , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (isRecycle_p1          , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int         (posedge_count          , UVM_DEFAULT + UVM_NOPRINT)
  `uvm_object_utils_end

   
   function new(string name = "ccp_ctrl_pkt_t");

   endfunction : new

 <% if(obj.nTagBanks >1) { %>
   constraint c_bank { bnk < N_TAG_BANK;}
 <% } else { %>
   constraint c_bank { bnk == 0;}
 <% } %>
   constraint c_bypass_alloc { (bypass & alloc) != 1'b1; }


   function string sprint_pkt();
        string 			     s;
      
        s = $sformatf("Bank:%0d Addr:0x%0x Security:0x%0x SetIndex:0x%0h alloc:%b rd_data:%b wr_data:%b rsp_evict_sel:%b bypass:%b rp_update:%b tagstateup:%b state:%s burstln:0x%0d burstwrap:0x%0d setway_debug:0x%0x waypbusy_vec:0b%0b waystale_vec:0b%0b currstate:%s wayn:0x%0h hitwayn:0x%0h fake_hit_way:0x%0x <% if (obj.useCache === undefined) {} else { if ((obj.useCache == 1) && (obj.AiuInfo[obj.Id].ccpParams.RepPolicy != "RANDOM") && (obj.AiuInfo[obj.Id].ccpParams.nWays>1)) {%>curr_nru_vec:0x%0h <%} }%> evictvld :%0b evictaddr:0x%0x evictsecurity:0x%0x evictstate:%s nackuce:%b nack:%b nackce:%b nacknoalloc:%b noways2alloc:%b nru_counter:0x%0d Time:%0t isRead:%0d isWrite:%0d isSnoop:%0d isMntOp:%0d isCancel:%0d isRead_Wakeup:%0d isWrite_Wakeup:%0d write_upgrade :%0b read_hit:%0d read_miss_alloc:%0d write_hit:%0d write_miss_alloc:%0d snoop_hit:%0d write_hit_upgrade:%0d,isReplay :%0b, toReplay :%0b, isRecycle :%0b, isRecycleFailed :%0b,isRplyVld :%0b cancel_p2:%0b, lookup_p2:%0b, flush_fail_p2:%0b,ccp_tt_full_p2:%0b isRttfull :%0b isWttfull :%0b isWttanyfull :%0b isWrfifofull :%0b isHntdropped :%0b msgType :%0b msgType_p0 :%0b isCoh :%0b retry: %b pt_id: 0x%0h, isRecycle_p1: %0d, posedge_count:%0d, t_pt_err:%0b", bnk,addr,security,setindex, alloc,rd_data,wr_data,rsp_evict_sel,bypass,rp_update,tagstateup,state.name(),burstln,burstwrap,setway_debug,waypbusy_vec,waystale_vec,currstate,wayn,hitwayn,fake_hit_way,<% if (obj.useCache === undefined) {} else { if ((obj.useCache == 1) && (obj.AiuInfo[obj.Id].ccpParams.RepPolicy != "RANDOM") && (obj.AiuInfo[obj.Id].ccpParams.nWays>1)) {%>currnruvec, <%} }%> evictvld,evictaddr,evictsecurity,evictstate.name(),
nackuce,nack,nackce,nacknoalloc,noways2alloc,nru_counter,t_pkt_seen_on_intf, isRead, isWrite, isSnoop, isMntOp, cancel, isRead_Wakeup,isWrite_Wakeup,write_upgrade, read_hit,read_miss_allocate,write_hit, write_miss_allocate, snoop_hit,write_hit_upgrade,isReplay,toReplay,isRecycle,isRecycleFailed,isRplyVld,cancel_p2,lookup_p2,flush_fail_p2,ccp_tt_full_p2,isRttfull,isWttfull,isWttanyfull,isWrfifofull,isHntdropped,msgType,msgType_p0,isCoh, retry, pt_id,isRecycle_p1, posedge_count, t_pt_err);  
      return s;
   endfunction : sprint_pkt

   function bit do_compare_pkts(ccp_ctrl_pkt_t m_pkt);
       bit done =1;
       if (this.bnk !== m_pkt.bnk) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_bnk: 0x%0x Actual: ctrlop_bnk: 0x%0x",  this.bnk, m_pkt.bnk), UVM_NONE); 
           done = 0;
       end
       if (this.addr !== m_pkt.addr) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_addr : 0x%0x Actual: ctrlop_addr : 0x%0x",  this.addr, m_pkt.addr), UVM_NONE); 
           done = 0;
       end
       if (this.alloc !== m_pkt.alloc) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_alloc: 0x%0x Actual: ctrlop_alloc: 0x%0x",  this.alloc, m_pkt.alloc), UVM_NONE); 
           done = 0;
       end
       if (this.rd_data !== m_pkt.rd_data) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_rd_data: 0x%0x Actual: ctrlop_rd_data: 0x%0x",  this.rd_data, m_pkt.rd_data), UVM_NONE); 
           done = 0;
       end
       if (this.wr_data !== m_pkt.wr_data) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_wr_data: 0x%0x Actual: ctrlop_wr_data: 0x%0x",  this.wr_data, m_pkt.wr_data), UVM_NONE); 
           done = 0;
       end
       if (this.rsp_evict_sel !== m_pkt.rsp_evict_sel) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_rsp_evict_sel: 0x%0x Actual: ctrlop_rsp_evict_sel: 0x%0x",  this.rsp_evict_sel, m_pkt.rsp_evict_sel), UVM_NONE); 
           done = 0;
       end
       if (this.bypass !== m_pkt.bypass) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_bypass: 0x%0x Actual: ctrlop_bypass: 0x%0x",  this.bypass, m_pkt.bypass), UVM_NONE); 
           done = 0;
       end
       if (this.rp_update !== m_pkt.rp_update) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_rp_update: 0x%0x Actual: ctrlop_rp_update: 0x%0x",  this.rp_update, m_pkt.rp_update), UVM_NONE); 
           done = 0;
       end
       if (this.tagstateup !== m_pkt.tagstateup) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_tagstateup: 0x%0x Actual: ctrlop_tagstateup: 0x%0x",  this.tagstateup, m_pkt.tagstateup), UVM_NONE); 
           done = 0;
       end
       if (this.state !== m_pkt.state) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_state: %s Actual: ctrlop_state: %s",  this.state.name(), m_pkt.state.name()), UVM_NONE); 
           done = 0;
       end
       if (this.burstln !== m_pkt.burstln) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_burstln: 0x%0x Actual: ctrlop_burstln: 0x%0x",  this.burstln, m_pkt.burstln), UVM_NONE); 
           done = 0;
       end
       if (this.burstwrap !== m_pkt.burstwrap) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_burstwrap: 0x%0x Actual: ctrlop_burstwrap: 0x%0x",  this.burstwrap, m_pkt.burstwrap), UVM_NONE); 
           done = 0;
       end
       if (this.setway_debug !== m_pkt.setway_debug) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_setway_debug: 0x%0x Actual: ctrlop_setway_debug: 0x%0x",  this.setway_debug, m_pkt.setway_debug), UVM_NONE); 
           done = 0;
       end
       if (this.waypbusy_vec !== m_pkt.waypbusy_vec) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_waypbusy_vec: 0x%0x Actual: ctrlop_waypbusy_vec: 0x%0x",  this.waypbusy_vec, m_pkt.waypbusy_vec), UVM_NONE); 
           done = 0;
       end
       if (this.waystale_vec !== m_pkt.waystale_vec) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlop_waystale_vec: 0x%0x Actual: ctrlop_waystale_vec: 0x%0x",  this.waystale_vec, m_pkt.waystale_vec), UVM_NONE); 
           done = 0;
       end
       if (this.currstate !== m_pkt.currstate) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cache_currstate: %s Actual: cache_currstate: %s",  this.currstate.name(), m_pkt.currstate.name()), UVM_NONE); 
           done = 0;
       end
       if (this.setindex !== m_pkt.setindex) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cache_set_index:0x%h Actual: cache_set_index:0x%0h",  this.setindex, m_pkt.setindex), UVM_NONE); 
           done = 0;
       end
       if (this.wayn !== m_pkt.wayn) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cache_alloc_wayn: 0x%0x Actual: cache_alloc_wayn: 0x%0x",  this.wayn, m_pkt.wayn), UVM_NONE); 
           done = 0;
       end
       if (this.hitwayn !== m_pkt.hitwayn) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cache_wayn: 0x%0x Actual: cache_wayn: 0x%0x",  this.hitwayn, m_pkt.hitwayn), UVM_NONE); 
           done = 0;
       end
       if (this.currnruvec !== m_pkt.currnruvec) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: curr_nru_vec: 0x%0x Actual: curr_nru_vec: 0x%0x",  this.currnruvec, m_pkt.currnruvec), UVM_NONE); 
           done = 0;
       end
       if (this.evictvld !== m_pkt.evictvld) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cache_evictvld: 0x%0b Actual: cache_evictaddr: 0x%0x",  this.evictvld, m_pkt.evictvld), UVM_NONE); 
           done = 0;
       end
       if (this.evictaddr !== m_pkt.evictaddr) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cache_evictaddr: 0x%0x Actual: cache_evictaddr: 0x%0x",  this.evictaddr, m_pkt.evictaddr), UVM_NONE); 
           done = 0;
       end
       if (this.evictstate !== m_pkt.evictstate) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cache_evictstate: %s Actual: cache_evictstate: %s",  this.evictstate.name(), m_pkt.evictstate.name()), UVM_NONE); 
           done = 0;
       end
       if (this.nackuce !== m_pkt.nackuce) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cache_nackuce: 0x%0x Actual: cache_nackuce: 0x%0x",  this.nackuce, m_pkt.nackuce), UVM_NONE); 
           done = 0;
       end
       if (this.nack !== m_pkt.nack) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cache_nack: 0x%0x Actual: cache_nack: 0x%0x",  this.nack, m_pkt.nack), UVM_NONE); 
           done = 0;
       end
       if (this.nackce !== m_pkt.nackce) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cache_nackce: 0x%0x Actual: cache_nackce: 0x%0x",  this.nackce, m_pkt.nackce), UVM_NONE); 
           done = 0;
       end
       if (this.nacknoalloc !== m_pkt.nacknoalloc) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cache_nacknoalloc: 0x%0x Actual: cache_nacknoalloc: 0x%0x",  this.nacknoalloc, m_pkt.nacknoalloc), UVM_NONE); 
           done = 0;
       end
       return done;
   endfunction : do_compare_pkts
 endclass:ccp_ctrl_pkt_t

//---------------------------------------------------------------------
// CCP ctrl fill packet
//---------------------------------------------------------------------


 class  ccp_fillctrl_pkt_t extends uvm_object;

  rand  ccp_ctrlfill_addr_t         addr;
  rand  ccp_ctrlfill_wayn_t         wayn;
  rand  ccp_ctrlfill_security_t     security;
  rand  ccp_cachestate_enum_t       state;
  time                              t_pkt_seen_on_intf;


  `uvm_object_param_utils_begin( ccp_fillctrl_pkt_t)
        `uvm_field_int           (addr, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (wayn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (security, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_enum          (ccp_cachestate_enum_t,state, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT)

  `uvm_object_utils_end

   
   function new(string name = " ccp_fillctrl_pkt_t");

   endfunction : new

 <%     if(obj.Block !=='dmi') { %>
<% if(obj.fnCacheStates === 'MEI'){ %>
   constraint c_state{ state inside {IX,UC,UD};};
<% } else if(obj.fnCacheStates === 'MSI-IX' || obj.fnCacheStates === 'MSI-SC' ) { %>
   constraint c_state{ state inside {IX,SC,UD};};
<% } else  { %>
   constraint c_state{ state inside {IX,SC,UC,UD};};
<% } %>
<% } else  { %>
   constraint c_state{ state inside {IX,SC,UD};};
<% } %>

   function string sprint_pkt();
      string 			    s;
      
      s = $sformatf("Addr:0x%0x Security:0x%0x wayn:0x%0d state:%s Time:%0t",addr,security,wayn,state,t_pkt_seen_on_intf);  
      return s;
   endfunction : sprint_pkt


   function bit do_compare_pkts( ccp_fillctrl_pkt_t m_pkt);
       bit done =1;
       if (this.addr !== m_pkt.addr) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlfill_addr size: 0x%0d Actual:ctrlfill_addr: 0x%0d", this.addr, m_pkt.addr), UVM_NONE); 
           done = 0;
       end
       if (this.wayn !== m_pkt.wayn) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected:ctrlfill_wayn: 0x%0x Actual: ctrlfill_wayn: 0x%0x", this.wayn, m_pkt.wayn), UVM_NONE); 
           done = 0;
       end
       if (this.security !== m_pkt.security) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected:ctrlfill_security: 0x%0x Actual: ctrlfill_security: 0x%0x", this.security, m_pkt.security), UVM_NONE); 
           done = 0;
       end
       if (this.state !== m_pkt.state) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrfill_state: %s Actual: ctrfill_state: %s",  this.state.name(), m_pkt.state.name()), UVM_NONE); 
           done = 0;
       end
       return done;
   endfunction : do_compare_pkts
 endclass: ccp_fillctrl_pkt_t

//---------------------------------------------------------------------
// CCP Data fill packet
//---------------------------------------------------------------------


 class  ccp_filldata_pkt_t extends uvm_object;

  rand  ccp_ctrlfill_data_t             data[];
  rand ccp_ctrlfilldata_scratchpad_t    scratchpad;
  rand  ccp_ctrlfilldata_Id_t           fillId;
  rand  ccp_ctrlfilldata_addr_t         addr;
  rand  ccp_ctrlfilldata_wayn_t         wayn;
  rand  ccp_ctrlfilldata_beatn_t        beatn[];
  rand  ccp_cachefill_doneId_t          doneId;
  rand  ccp_cachefill_done_t            done;
  rand  ccp_ctrlfilldata_byten_t        byten[];
  rand  ccp_ctrlfilldata_last_t         last;
  rand  bit                             poison[];
  //CONC-15425::CONC-15710 - Fill Interface udpdate: Adding Fill data full signal to the Fill Data Interafce
  rand  ccp_ctrlfilldata_full_t         data_full;
  time                                  timestamp[];
  time                                  t_pkt_seen_on_intf;


  `uvm_object_param_utils_begin(ccp_filldata_pkt_t)
        `uvm_field_array_int     (data, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (scratchpad, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (byten, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (fillId, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (addr, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (wayn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (poison, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (beatn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (doneId, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (done, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (last, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (data_full, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (timestamp, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT)

  `uvm_object_utils_end

   
   function new(string name = "ccp_filldata_pkt_t");

   endfunction : new

   constraint c_datasize {  data.size() == BURSTLN;}  

   constraint c_poison {  poison.size() == BURSTLN;}  

   constraint c_beatnsize { beatn.size() == BURSTLN;}  

   constraint cc_poison     {  foreach(poison[i]){
                                poison[i] == 0};}  

   function string sprint_pkt();
      string 				s;
        s = $sformatf("FillId:0x%0x Full:%b, Addr:0x%0x Wayn:0x%0x  Done:%b DoneId:0x%0x Scratchpad: 0x%0h Time0:%0t "
            ,fillId, data_full, addr,wayn,done,doneId,scratchpad, t_pkt_seen_on_intf);  

        if(data.size() > 0) begin
            for (int i = 0; i < data.size(); i++) begin
                s = {s, $sformatf("Beat%0d:0x%0x Data%0d:0x%0x poison%0d:%0b byten:%0h "
                ,i, beatn[i],i,data[i],i,poison[i],byten[i])};
            end
        end else begin
            s = {s, " Data0:0x0"};
        end

        return s;
   endfunction : sprint_pkt


   function bit do_compare_pkts( ccp_filldata_pkt_t m_pkt);
       bit done =1;
       if (this.data.size() !== m_pkt.data.size()) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlfill_data size: 0x%0d Actual:ctrlfill_data size: 0x%0d", this.data.size(), m_pkt.data.size()), UVM_NONE); 
           done = 0;
       end
       foreach (data[i]) begin
           if (this.data[i] !== m_pkt.data[i]) begin
               uvm_report_info(get_full_name(), $sformatf("ERROR  beat:%0d Expected: ctrlfill_data: 0x%0x Actual: ctrlfill_data: 0x%0x",this.beatn[i], this.data[i], m_pkt.data[i]), UVM_NONE); 
               done = 0;
           end
       end
       foreach (poison[i]) begin
         if (this.poison[i] !== m_pkt.poison[i]) begin
             uvm_report_info(get_full_name(), $sformatf("ERROR beat:%0d Expected: poison bit: %0b Actual: poison bit: %0b",this.beatn[i],this.poison[i], m_pkt.poison[i]), UVM_NONE); 
             done = 0;
         end
       end
       if (this.fillId !== m_pkt.fillId) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlfill_Id: 0x%0x Actual: ctrlfill_Id: 0x%0x", this.fillId, m_pkt.fillId), UVM_NONE); 
           done = 0;
       end
       if (this.wayn !== m_pkt.wayn) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected:ctrlfill_wayn: 0x%0x Actual: ctrlfill_wayn: 0x%0x", this.wayn, m_pkt.wayn), UVM_NONE); 
           done = 0;
       end
       foreach (beatn[i]) begin
         if (this.beatn[i] !== m_pkt.beatn[i]) begin
             uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlfill_beatn: %d Actual: ctrlfill_beatn: %d", this.beatn[i], m_pkt.beatn[i]), UVM_NONE); 
             done = 0;
         end
       end
       if (this.doneId !== m_pkt.doneId) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cache_filldoneId: 0x%0x Actual: cache_filldoneId: 0x%0x", this.doneId, m_pkt.doneId), UVM_NONE); 
           done = 0;
       end
       if (this.done !== m_pkt.done) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cache_filldone: 0x%0x Actual: cache_filldone: 0x%0x", this.done, m_pkt.done), UVM_NONE); 
           done = 0;
       end
       if (this.data_full !== m_pkt.data_full) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: Full: %b Actual: Full: %b", this.data_full, m_pkt.data_full), UVM_NONE); 
           done = 0;
       end
       return done;
   endfunction : do_compare_pkts
   function bit do_compare_data( ccp_filldata_pkt_t m_pkt);
       bit done =1;
       if (this.data.size() !== m_pkt.data.size()) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlfill_data size: 0x%0d Actual:ctrlfill_data size: 0x%0d", this.data.size(), m_pkt.data.size()), UVM_NONE); 
           done = 0;
       end

       foreach (this.data[i]) begin
         if(this.byten[i] != m_pkt.byten[i])begin
           uvm_report_info(get_full_name(), $sformatf("ERROR beat # :%0d  Expected: byte enable : 0x%0b Actual:byte enable: 0x%0b",this.beatn[i],this.byten[i], m_pkt.byten[i]), UVM_NONE); 
           done = 0;
         end
       end

       foreach (this.data[i]) begin
         bit [7:0] unpack_data_exp[WCCPDATA/8];
         bit [7:0] unpack_data[WCCPDATA/8];
         
         if (this.data[i] !== m_pkt.data[i]) begin
            uvm_report_info(get_full_name(), $sformatf("ERROR  beat:%0d Expected: ctrlfill_data: 0x%0x Actual: ctrlfill_data: 0x%0x",this.beatn[i], this.data[i], m_pkt.data[i]), UVM_NONE); 
            {>>{unpack_data_exp}} = this.data[i];
            {>>{unpack_data}}     = m_pkt.data[i];
            foreach(unpack_data_exp[j]) begin
              if(this.byten[i][j])begin
                if (unpack_data_exp[j] !== unpack_data[j]) begin
                 uvm_report_info(get_full_name(), $sformatf("ERROR  beat:%0d byte# :%0d Expected: ctrlfill_data: 0x%0x Actual: ctrlfill_data: 0x%0x",this.beatn[i],j,unpack_data_exp[j],unpack_data[j]), UVM_NONE); 
                end
                done = 0;
              end
            end
         end
       end
       foreach (poison[i]) begin
         if (this.poison[i] !== m_pkt.poison[i]) begin
             uvm_report_info(get_full_name(), $sformatf("ERROR beat:%0d Expected: poison bit: %0b Actual: poison bit: %0b",this.beatn[i],this.poison[i], m_pkt.poison[i]), UVM_NONE); 
             done = 0;
         end
       end
       foreach (beatn[i]) begin
         if (this.beatn[i] !== m_pkt.beatn[i]) begin
             uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: ctrlfill_beatn: %d Actual: ctrlfill_beatn: %d", this.beatn[i], m_pkt.beatn[i]), UVM_NONE); 
             done = 0;
         end
       end
       return done;
   endfunction : do_compare_data
 endclass: ccp_filldata_pkt_t

//---------------------------------------------------------------------
// CCP Data Out Evict packet
//---------------------------------------------------------------------


 class  ccp_evict_pkt_t extends uvm_object;

   rand  ccp_cache_evict_data_t            data[];
   rand  bit                               poison[];
   rand  ccp_cache_evict_byten_t           byten[];
   rand  ccp_cache_evict_cancel_t          datacancel;
   rand  time                              timestamp[];
   rand  time                              t_pkt_seen_on_intf;


  `uvm_object_param_utils_begin( ccp_evict_pkt_t)
        `uvm_field_array_int     (data, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (byten, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (poison, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (datacancel, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (timestamp, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT)
  `uvm_object_utils_end

   
   function new(string name = " ccp_evict_pkt_t");

   endfunction : new

   constraint c_datasize{  data.size() == BURSTLN;}  

   constraint c_pois{  poison.size() == BURSTLN;}  

   function string sprint_pkt();
      string s;
        s = $sformatf("Data0:0x%0x poison0:%0b Byten0:0x%0x datacancel:%b Time:%0t "
            ,data[0],poison[0],byten[0],datacancel,t_pkt_seen_on_intf);  
        if(data.size() > 0) begin
            for (int i = 1; i < data.size(); i++) begin
                s = {s, $sformatf("ByteEn%0d:0x%0x Data%0d:0x%0x Poison:0x%0x, "
                ,i,byten[i],i,data[i], poison[i])};
            end
        end else begin
            s = {s, " Data0:0x0"};
        end
        return s;
      
   endfunction : sprint_pkt


   function bit do_compare_pkts( ccp_evict_pkt_t m_pkt);
       bit done =1;
       if (this.data.size() !== m_pkt.data.size()) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: data size: 0x%0d Actual:data size: 0x%0d", this.data.size(), m_pkt.data.size()), UVM_NONE); 
           done = 0;
       end
       foreach (data[i]) begin
           if (this.data[i] !== m_pkt.data[i] && !m_pkt.poison[i]) begin
               uvm_report_info(get_full_name(), $sformatf("ERROR  beat:%0d Expected: data: 0x%0x Actual: data: 0x%0x", i, this.data[i], m_pkt.data[i]), UVM_NONE); 
               done = 0;
           end
       end
       foreach (poison[i]) begin
         if (this.poison[i] !== m_pkt.poison[i]) begin
             uvm_report_info(get_full_name(), $sformatf("ERROR beat:%0d  Expected: poison bit: %0b Actual: poison bit: %0b",i,this.poison[i], m_pkt.poison[i]), UVM_NONE); 
             done = 0;
         end
       end
       return done;
   endfunction : do_compare_pkts
 endclass: ccp_evict_pkt_t
//---------------------------------------------------------------------
// CCP Data Out Rd rsp packet
//---------------------------------------------------------------------


 class  ccp_rd_rsp_pkt_t extends uvm_object;

   rand  ccp_cache_rdrsp_data_t            data[];
   rand  bit                               poison[];
   rand  ccp_cache_rdrsp_byten_t           byten[];
   rand  ccp_cache_rdrsp_cancel_t          datacancel;
   rand  time                              timestamp[];
   rand  time                              t_pkt_seen_on_intf;
   bit                                     last;


  `uvm_object_param_utils_begin( ccp_rd_rsp_pkt_t)
        `uvm_field_array_int     (data, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (poison, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (byten, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (datacancel, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (timestamp, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (last, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT)

  `uvm_object_utils_end

   
   function new(string name = " ccp_rd_rsp_pkt_t");

   endfunction : new

   constraint c_datasize{  data.size() == BURSTLN;}  
   constraint c_pois{  poison.size() == BURSTLN;}  

   function string sprint_pkt();
      string 				   s;
      
        s = $sformatf("Data0:0x%0x poison0:%0b Byten0:0x%0b last:%b datacancel:%b Time:%0t "
            ,data[0],poison[0],byten[0],last, datacancel,t_pkt_seen_on_intf);  
        
        if(data.size() > 0) begin
            for (int i = 1; i < data.size(); i++) begin
                s = {s, $sformatf("ByteEn%0d:0x%0x Data%0d:0x%0x Poison:0x%0x, "
                ,i,byten[i],i,data[i], poison[i])};
            end
        end else begin
            s = {s, " Data0:0x0"};
        end
        return s;
      
   endfunction : sprint_pkt


   function bit do_compare_pkts( ccp_rd_rsp_pkt_t m_pkt);
       bit done =1;
       if (this.data.size() !== m_pkt.data.size()) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: cacherdrsp_data size: 0x%0d Actual:cacherdrsp_data size: 0x%0d", this.data.size(), m_pkt.data.size()), UVM_NONE); 
           done = 0;
       end
       foreach (data[i]) begin
           if (this.data[i] !== m_pkt.data[i] && !m_pkt.poison[i]) begin
               uvm_report_info(get_full_name(), $sformatf("ERROR  beat:%0d Expected: cacherdrsp_data: 0x%0x Actual: cacherdrsp_data: 0x%0x", i, this.data[i], m_pkt.data[i]), UVM_NONE); 
               done = 0;
           end
       end
<% if(!cmcUncorr) { %>
       foreach (poison[i]) begin
         if (this.poison[i] !== m_pkt.poison[i]) begin
             uvm_report_info(get_full_name(), $sformatf("ERROR  beat:%0d Expected: poison bit: %0b Actual: poison bit: %0b",i,this.poison[i], m_pkt.poison[i]), UVM_NONE); 
             done = 0;
         end
       end
<% } %>
       return done;
   endfunction : do_compare_pkts
 endclass: ccp_rd_rsp_pkt_t
//---------------------------------------------------------------------
// CCP CSR MAINTENANCE
//---------------------------------------------------------------------


 class  ccp_csr_maint_pkt_t extends uvm_object;

   rand  csr_maint_wrdata_t                wrdata;
   rand  csr_maint_req_data_t              reqdata;
   rand  csr_maint_rddata_t                rddata;
   rand  csr_maint_req_opc_t               opcode;
   rand  csr_maint_req_way_t               wayn;
   rand  csr_maint_req_entry_t             entry;
   rand  csr_maint_req_word_t              word;
   rand  csr_maint_req_array_sel_t         arraysel;
   rand  csr_maint_active_t                active;
   rand  csr_maint_rddata_en_t             rddata_en;
   rand  time                              timestamp[];
   rand  time                              t_pkt_seen_on_intf;


  `uvm_object_param_utils_begin( ccp_csr_maint_pkt_t)
        `uvm_field_int           (wrdata, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (rddata, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (reqdata, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (opcode, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (wayn, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (entry, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (word, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (arraysel, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (active, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (rddata_en, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_array_int     (timestamp, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (t_pkt_seen_on_intf, UVM_DEFAULT + UVM_NOPRINT)

  `uvm_object_utils_end

   
   function new(string name = " ccp_csr_maint_pkt_t");

   endfunction : new


   function string sprint_pkt();
      string s;
      
        s = $sformatf("wrData:0x%0x reqdata:0x%0x rdData:0x%0x  opcode:0x%0x wayn:0%0d entry:0x%0x word:0x%0x arraysel:0x%0b Time:%0t",wrdata,reqdata,rddata,opcode,wayn,entry,arraysel,word,t_pkt_seen_on_intf);
      return s;
      
   endfunction : sprint_pkt


   function bit do_compare_pkts( ccp_csr_maint_pkt_t m_pkt);
       bit done =1;
       if (this.wrdata !== m_pkt.wrdata) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: csr_maint_wrdata : 0x%0x Actual:csr_maint_wrdata : 0x%0x", this.wrdata, m_pkt.wrdata), UVM_NONE); 
           done = 0;
       end
       if (this.rddata !== m_pkt.rddata) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: csr_maint_rddata : 0x%0x Actual:csr_maint_rddata : 0x%0x", this.rddata, m_pkt.rddata), UVM_NONE); 
           done = 0;
       end
       if (this.reqdata !== m_pkt.reqdata) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: csr_maint_req_data : 0x%0x Actual:csr_maint_req_data : 0x%0x", this.reqdata, m_pkt.reqdata), UVM_NONE); 
           done = 0;
       end
       if (this.opcode !== m_pkt.opcode) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: csr_maint_req_opcode : 0x%0x Actual:csr_maint_req_opcode : 0x%0x", this.opcode, m_pkt.opcode), UVM_NONE); 
           done = 0;
       end
       if (this.wayn !== m_pkt.wayn) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: csr_maint_req_way : 0x%0x Actual:csr_maint_req_way : 0x%0x", this.wayn, m_pkt.wayn), UVM_NONE); 
           done = 0;
       end
       if (this.entry !== m_pkt.entry) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: csr_maint_req_entry : 0x%0x Actual:csr_maint_req_entry : 0x%0x", this.entry, m_pkt.entry), UVM_NONE); 
           done = 0;
       end
       if (this.arraysel !== m_pkt.arraysel) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: csr_maint_req_array_sel : 0x%0x Actual:csr_maint_req_array_sel : 0x%0x", this.arraysel, m_pkt.arraysel), UVM_NONE); 
           done = 0;
       end
       if (this.active !== m_pkt.active) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: csr_maint_req_active : 0x%0b Actual:csr_maint_req_active : 0x%0b", this.active, m_pkt.active), UVM_NONE); 
           done = 0;
       end
       if (this.rddata_en !== m_pkt.rddata_en) begin
           uvm_report_info(get_full_name(), $sformatf("ERROR  Expected: csr_maint_rddata_en : 0x%0b Actual:csr_maint_rddata_en : 0x%0b", this.rddata_en, m_pkt.rddata_en), UVM_NONE); 
           done = 0;
       end
       return done;
   endfunction : do_compare_pkts
 endclass: ccp_csr_maint_pkt_t
//---------------------------------------------------------------------
// CCP cache rtl pkt for  CCP checker
//---------------------------------------------------------------------
class cache_rtl_pkt extends uvm_sequence_item;
    logic valid;
    logic isFill;
    logic isLookup;
    logic isSnoop;
    logic isMntOp;
    logic isBogusFill;
    logic snoop_hit;
    logic snoop_hit_dirty;
    logic snoop_hit_shared;
    logic write_hit;
    logic write_hit_upgrade;
    logic write_miss_allocate;
    logic write_miss_no_allocate;
    logic read_hit;
    logic read_miss_allocate;
    logic read_miss_no_allocate;
    logic stall;
    logic replay;
    logic ctt_match;
    logic utt_match;
    logic isRead;
    logic isWrite;
    logic [1:0] cttTransType;
    logic alloc_ptl_rd_miss;
    logic alloc_ptl_wr_miss;
    logic alloc_full_rd_miss;
    logic alloc_full_wr_miss;    
    logic sample_alloc_en;    
    logic en_lookup;    
    logic en_fill;    
    logic PcSecAttr;    

    logic [3:0] mntOpType;
    logic       mntOpEn;
    logic       mntOpActv;
    logic       fillActv;
    logic       evictActv;
    logic       mntOpArrId;
    logic       tagError;
    logic       fillError;
    logic       dataError;
    bit         dataErrorPerBeat[];
    bit         rd_ecc_dataErrorPerBeat[];

    logic [1:0] flush_state;
    logic       flush_fail;

    ccp_ctrlop_addr_t                 addr;
    ccp_ctrlop_addr_t                 acaddr;
    ccp_ctrlop_security_t             acprot;

    cbi_cmdtype_t   cmd_type;
    ccp_cachestate_enum_t  cmd_state;


    bit isRtlCovPkt;

    bit ctt_full;
    bit utt_full;
    bit rdCttHit;
    bit wrCttHit;
    bit rdUttHit;
    bit wrUttHit;
    bit snoopCttHit;
    bit snoopUttHit;
    bit isFull;
    bit alloc;
    bit isHit;
    bit allWaysBusy; 
    bit indexFull; 
    bit security;

    bit cmd_wr_ptl;
    bit cmd_wr_full;
    bit rtl_tag_correctable_error;
    bit rtl_tag_uncorrectable_error;
    bit rtl_data_correctable_error;
    bit rtl_data_uncorrectable_error;

   bit cmd_state_valid_vld;
   bit cmd_state_valid_sel_lookup;
   bit cmd_state_tagstatevldvec;
   bit cmd_state_tagstateSCvec;
   bit cmd_state_tagstateUDvec;

   bit sfi_mst_rsp_vld;
   bit sfi_mst_rsp_status;
   bit sfi_mst_rsp_errcode;

   bit rtl_write_hit_ptl;
   bit rtl_write_hit_full;

   <% var num_SysCacheline = Math.pow(2, obj.wCacheLineOffset); %>
   <% var numBeats  = ((num_SysCacheline*8)/obj.wMasterData); %>
   <% for( var i = 0; i < numBeats; i++) { %>
   int data_mem<%=i%>_single_error_count;
   int data_mem<%=i%>_double_error_count;
   <% } %>
   int tag_mem_single_error_count;
   int tag_mem_double_error_count;
   int ott_dat0_mem_single_error_count;
   int ott_dat0_mem_double_error_count;
   int ott_dat1_mem_single_error_count;
   int ott_dat1_mem_double_error_count;

    bit isSFISTRReqAddrErr;
    bit isSFISTRReqDataErr;     
    bit isSFISTRReqTransportErr;
    bit isSFICMDRespErr;
    bit isSFIDTWrspErr;
    bit Bypass_en;




<% if(obj.isBridgeInterface && obj.useCache) { %>                   
    parameter NO_OF_WAYS        = <%=obj.nWays%>; 
    parameter NO_OF_SETS        = <%=obj.nSets%>; 
    parameter INDEX_SIZE        = $clog2(NO_OF_SETS);
<% } else { %>
    parameter NO_OF_WAYS        = 0;
    parameter NO_OF_SETS        = 0; 
    parameter INDEX_SIZE        = 1;
<% } %>


    bit [$clog2(NO_OF_WAYS)-1:0] nru_counter;
    bit [$clog2(NO_OF_WAYS)-1:0] evict_way;


    //Signal for Data checking
    logic                                   write_en;
    logic                                   chip_en;
    logic                                   mem_valid;
    logic                                   mem_stall;
    ccp_ctrlwr_data_t                       data[];
    logic [INDEX_SIZE-1:0]                  Index;
    logic [$clog2(NO_OF_WAYS)-1:0]          way;

    logic [INDEX_SIZE-1:0] mntEvictIndex;
    logic [$clog2(NO_OF_WAYS)-1:0] mntEvictWay;
    int mntEvictAddr;

   `uvm_object_param_utils_begin (cache_rtl_pkt)
        `uvm_field_int      ( addr                          , UVM_DEFAULT )
        `uvm_field_int      ( valid                         , UVM_DEFAULT )
        `uvm_field_int      ( isFill                        , UVM_DEFAULT )
        `uvm_field_int      ( isLookup                      , UVM_DEFAULT )
        `uvm_field_int      ( isSnoop                       , UVM_DEFAULT )
        `uvm_field_int      ( isMntOp                       , UVM_DEFAULT )
        `uvm_field_int      ( isBogusFill                   , UVM_DEFAULT )
        `uvm_field_int      ( snoop_hit                     , UVM_DEFAULT )
        `uvm_field_int      ( snoop_hit_dirty               , UVM_DEFAULT )
        `uvm_field_int      ( snoop_hit_shared              , UVM_DEFAULT )
        `uvm_field_int      ( write_hit                     , UVM_DEFAULT )
        `uvm_field_int      ( rtl_write_hit_ptl             , UVM_DEFAULT )
        `uvm_field_int      ( rtl_write_hit_full             , UVM_DEFAULT )
        `uvm_field_int      ( write_hit_upgrade             , UVM_DEFAULT )
        `uvm_field_int      ( write_miss_allocate           , UVM_DEFAULT )
        `uvm_field_int      ( write_miss_no_allocate        , UVM_DEFAULT )
        `uvm_field_int      ( read_hit                      , UVM_DEFAULT )
        `uvm_field_int      ( read_miss_allocate            , UVM_DEFAULT )
        `uvm_field_int      ( read_miss_no_allocate         , UVM_DEFAULT )
        `uvm_field_int      ( stall                         , UVM_DEFAULT )
        `uvm_field_int      ( replay                        , UVM_DEFAULT )
        `uvm_field_int      ( ctt_match                     , UVM_DEFAULT )
        `uvm_field_int      ( utt_match                     , UVM_DEFAULT )
        `uvm_field_int      ( acaddr                        , UVM_DEFAULT )
      //  `uvm_field_int      ( acsnoop                       , UVM_DEFAULT )
        `uvm_field_int      ( acprot                        , UVM_DEFAULT )
        `uvm_field_int      ( isRead                        , UVM_DEFAULT )
        `uvm_field_int      ( isWrite                       , UVM_DEFAULT )
        `uvm_field_int      ( nru_counter                   , UVM_DEFAULT )
        `uvm_field_int      ( evict_way                     , UVM_DEFAULT )
        `uvm_field_int      ( cttTransType                  , UVM_DEFAULT )
        `uvm_field_int      ( write_en                      , UVM_DEFAULT )
        `uvm_field_int      ( chip_en                       , UVM_DEFAULT )
        `uvm_field_int      ( mem_valid                     , UVM_DEFAULT )
        `uvm_field_int      ( mem_stall                     , UVM_DEFAULT )
        `uvm_field_int      ( Index                         , UVM_DEFAULT )
        `uvm_field_int      ( way                           , UVM_DEFAULT )
        `uvm_field_int      ( mntEvictIndex                 , UVM_DEFAULT )
        `uvm_field_int      ( mntEvictWay                   , UVM_DEFAULT )
        `uvm_field_int      ( mntEvictAddr                  , UVM_DEFAULT )
        `uvm_field_int      ( alloc_ptl_rd_miss             , UVM_DEFAULT )
        `uvm_field_int      ( alloc_ptl_wr_miss             , UVM_DEFAULT )
        `uvm_field_int      ( alloc_full_rd_miss            , UVM_DEFAULT )
        `uvm_field_int      ( alloc_full_wr_miss            , UVM_DEFAULT )
        `uvm_field_int      ( sample_alloc_en               , UVM_DEFAULT )
        `uvm_field_int      ( en_lookup                     , UVM_DEFAULT )
        `uvm_field_int      ( en_fill                       , UVM_DEFAULT )
        `uvm_field_int      ( PcSecAttr                     , UVM_DEFAULT )
        `uvm_field_int      ( mntOpType                     , UVM_DEFAULT )
        `uvm_field_int      ( mntOpEn                       , UVM_DEFAULT )
        `uvm_field_int      ( mntOpActv                     , UVM_DEFAULT )
        `uvm_field_int      ( fillActv                      , UVM_DEFAULT )
        `uvm_field_int      ( evictActv                     , UVM_DEFAULT )
        `uvm_field_int      ( mntOpArrId                    , UVM_DEFAULT )
        `uvm_field_int      ( tagError                      , UVM_DEFAULT )
        `uvm_field_int      ( fillError                     , UVM_DEFAULT )
        `uvm_field_int      ( dataError                     , UVM_DEFAULT )
        `uvm_field_int      ( flush_state                   , UVM_DEFAULT )
        `uvm_field_int      ( flush_fail                    , UVM_DEFAULT )

        `uvm_field_int       ( ctt_full                     , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( utt_full                     , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( rdCttHit                     , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( wrCttHit                     , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( rdUttHit                     , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( wrUttHit                     , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( snoopCttHit                  , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( snoopUttHit                  , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( alloc                        , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( isHit                        , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( isFull                       , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( allWaysBusy                  , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( indexFull                    , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( security                     , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( isRtlCovPkt                  , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( cmd_wr_full                  , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( cmd_wr_ptl                   , UVM_DEFAULT + UVM_NOPRINT)

        `uvm_field_int       ( rtl_tag_correctable_error    , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( rtl_tag_uncorrectable_error  , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( rtl_data_correctable_error   , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( rtl_data_uncorrectable_error , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( Bypass_en                    , UVM_DEFAULT + UVM_NOPRINT)

        `uvm_field_int       ( cmd_state_valid_vld          , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( cmd_state_valid_sel_lookup   , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( cmd_state_tagstatevldvec     , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( cmd_state_tagstateSCvec      , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( cmd_state_tagstateUDvec      , UVM_DEFAULT + UVM_NOPRINT)

        `uvm_field_int       ( sfi_mst_rsp_vld              , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( sfi_mst_rsp_status           , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( sfi_mst_rsp_errcode          , UVM_DEFAULT + UVM_NOPRINT)

        <% var num_SysCacheline = Math.pow(2, obj.wCacheLineOffset); %>
        <% var numBeats  = ((num_SysCacheline*8)/obj.wMasterData); %>
        <% for( var i = 0; i < numBeats; i++) { %>
        `uvm_field_int       ( data_mem<%=i%>_single_error_count          , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( data_mem<%=i%>_double_error_count          , UVM_DEFAULT + UVM_NOPRINT)
        <% } %>
        `uvm_field_int       ( tag_mem_single_error_count                 , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( tag_mem_double_error_count                 , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( ott_dat0_mem_single_error_count            , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( ott_dat0_mem_double_error_count            , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( ott_dat1_mem_single_error_count            , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( ott_dat1_mem_double_error_count            , UVM_DEFAULT + UVM_NOPRINT)



        `uvm_field_int       ( isSFISTRReqAddrErr            , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( isSFISTRReqDataErr            , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( isSFISTRReqTransportErr      , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( isSFICMDRespErr            , UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int       ( isSFIDTWrspErr            , UVM_DEFAULT + UVM_NOPRINT)


        `uvm_field_array_int( data                          , UVM_DEFAULT )
        `uvm_field_array_int( dataErrorPerBeat              , UVM_DEFAULT )
        `uvm_field_array_int( rd_ecc_dataErrorPerBeat       , UVM_DEFAULT )
        `uvm_field_enum     ( cbi_cmdtype_t                 , cmd_type                   , UVM_DEFAULT )
        `uvm_field_enum     ( ccp_cachestate_enum_t         , cmd_state                   , UVM_DEFAULT )
    `uvm_object_utils_end


    function new(string name = "axi_rd_seq_item");
      super.new(name);
      data                    = new[CACHELINE_SIZE];
      dataErrorPerBeat        = new[CACHELINE_SIZE];
      rd_ecc_dataErrorPerBeat = new[CACHELINE_SIZE];
    endfunction : new 

    //Print Function  
    function string sprint_pkt();
        string spkt,s;
        spkt = {"isFill:%0d, isLookup:%0d, isSnoop:%0d, isBogusFill:%0d, isMntOp:%0d",
                " Addr:0x%0x, AcAddr:0x%0x,AcProt:%0d",
                " CmdType:%0s, isRead:%0h,read_hit:%0b isWrite:%0h, write_hit:%0b Index:%0h",
                " Way:%0h, MntEvictIndex:%0h, MntEvictWay:%0h MntEvictAddr:%0h, ",
                " MntOpType:%0d, PcSecAttr:%0d "};
        s = $psprintf(spkt,isFill,isLookup, isSnoop, isBogusFill, isMntOp,
                      addr,acaddr,acprot,cmd_type,
                      isRead,read_hit,isWrite,write_hit,Index,way,mntEvictIndex,mntEvictWay,mntEvictAddr,
                      mntOpType, PcSecAttr);
    
        if(data.size() > 0) begin
            for (int i = 0; i < data.size(); i++) begin
                s = {s, $sformatf(" Data%0d:0x%0x"
                ,i, data[i])};
            end
        end else begin
            s = {s, " Data0:0x0"};
        end

       return s;
       
    endfunction : sprint_pkt
endclass



//scratchpad control packet
class ccp_sp_ctrl_pkt_t extends uvm_object;

 ccp_sp_ctrl_wr_data_t          sp_op_wr_data;
 ccp_sp_ctrl_rd_data_t          sp_op_rd_data;
 ccp_sp_ctrl_data_bank_t        sp_op_data_bank;
 ccp_sp_ctrl_index_addr_t       sp_op_index_addr;
 ccp_sp_ctrl_way_num_t          sp_op_way_num;
 ccp_sp_ctrl_beat_num_t         sp_op_beat_num;
 ccp_sp_ctrl_burst_len_t        sp_op_burst_len; 
 ccp_sp_ctrl_burst_type_t       sp_op_burst_type;
 ccp_sp_ctrl_msg_type_t         sp_op_msg_type;
 time                           t_pkt_seen_on_intf;
 int                            posedge_count;

 `uvm_object_param_utils_begin(ccp_sp_ctrl_pkt_t)
     `uvm_field_int       ( sp_op_wr_data        , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int       ( sp_op_rd_data        , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int       ( sp_op_data_bank      , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int       ( sp_op_index_addr     , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int       ( sp_op_way_num        , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int       ( sp_op_beat_num       , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int       ( sp_op_burst_len      , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int       ( sp_op_burst_type     , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int       ( sp_op_msg_type       , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int       ( t_pkt_seen_on_intf   , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int       ( posedge_count        , UVM_DEFAULT + UVM_NOPRINT)
 `uvm_object_utils_end

  
  function new(string name = "ccp_sp_ctrl_pkt_t");

  endfunction : new


  function string sprint_pkt();
      string spkt,s;
      spkt = {"sp_op_msg_type :%0x sp_op_wr_data:%0b, sp_op_rd_data:%0b, sp_op_index_addr:%0h, sp_op_way_num:%0h",
              " sp_op_beat_num:%0h, sp_op_burst_len:%0h,posedge_count:%0h,t_pkt_seen_on_intf:%t"};
      s = $psprintf(spkt,sp_op_msg_type,sp_op_wr_data, sp_op_rd_data, sp_op_index_addr, sp_op_way_num,
                             sp_op_beat_num, sp_op_burst_len,posedge_count,t_pkt_seen_on_intf);
     return s;
     
  endfunction : sprint_pkt

  function bit do_compare_pkts(ccp_sp_ctrl_pkt_t m_pkt);
      bit done =1;
      return done;
  endfunction : do_compare_pkts

endclass:ccp_sp_ctrl_pkt_t

//scratchpad write packet
class ccp_sp_wr_pkt_t extends uvm_object;

     ccp_ctrlwr_data_t       data[]; 
     ccp_data_poision_t      poison[];
     ccp_ctrlwr_byten_t      byten[];
     ccp_ctrlwr_beatn_t      beatn[];
     time                    timestamp[] ;
     time                    t_pkt_seen_on_intf;


 `uvm_object_param_utils_begin(ccp_sp_wr_pkt_t)
     `uvm_field_array_int       ( data        , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_array_int       ( poison      , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_array_int       ( byten       , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_array_int       ( beatn       , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_array_int       ( timestamp   , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int             ( t_pkt_seen_on_intf   , UVM_DEFAULT + UVM_NOPRINT)
 `uvm_object_utils_end

  
  function new(string name = "ccp_sp_wr_pkt_t");

  endfunction : new


  function string sprint_pkt();
     string 		     s;
     
      s = $sformatf("beat0:0x%0d Data0:0x%0x poison0 :%0b Byten0:0x%0x Time:%0t "
          ,beatn[0],data[0],poison[0],byten[0], t_pkt_seen_on_intf);  
      
      if(data.size() > 0) begin
          for (int i = 1; i < data.size(); i++) begin
              s = {s, $sformatf("Beat%0d:0x%0x ByteEn%0d:0x%0x Data%0d:0x%0x poison%0d :%0b "
              ,i, beatn[i],i, byten[i], i,data[i],i,poison[i])};
          end
      end else begin
          s = {s, " Data0:0x0"};
      end
     return s;
     
  endfunction : sprint_pkt

  function bit do_compare_pkts(ccp_sp_wr_pkt_t m_pkt);
      bit done =1;
      return done;
  endfunction : do_compare_pkts

endclass:ccp_sp_wr_pkt_t


//scratchpad output packet
class ccp_sp_output_pkt_t extends uvm_object;

 ccp_cache_rdrsp_data_t        data[];
 ccp_data_poision_t            poison[];
 ccp_cache_rdrsp_byten_t       byten[];
 ccp_cache_rdrsp_cancel_t      datacancel; 
 time                          timestamp[] ;
 time                          t_pkt_seen_on_intf;


 `uvm_object_param_utils_begin(ccp_sp_output_pkt_t)
     `uvm_field_array_int       ( data        , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_array_int       ( poison      , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_array_int       ( byten       , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_array_int       ( timestamp   , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int             ( datacancel  , UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int             ( t_pkt_seen_on_intf   , UVM_DEFAULT + UVM_NOPRINT)
 `uvm_object_utils_end

  
  function new(string name = "ccp_sp_output_pkt_t");

  endfunction : new


  function string sprint_pkt();
     string 		       s;
     
      s = $sformatf("Data0:0x%0x poison0 :%0b Byten0:0x%0x Time:%0t "
          ,data[0],poison[0],byten[0], t_pkt_seen_on_intf);  
      
      if(data.size() > 0) begin
          for (int i = 1; i < data.size(); i++) begin
              s = {s, $sformatf("ByteEn%0d:0x%0x Data%0d:0x%0x poison%0d :%0b "
              ,i, byten[i], i,data[i],i,poison[i])};
          end
      end else begin
          s = {s, " Data0:0x0"};
      end
     return s;
  endfunction : sprint_pkt

  function bit do_compare_pkts(ccp_sp_output_pkt_t m_pkt);
      bit done =1;
      return done;
  endfunction : do_compare_pkts

endclass:ccp_sp_output_pkt_t

