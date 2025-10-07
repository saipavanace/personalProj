 
  class ccp_ctrlstatus_seq  extends uvm_sequence #(ccp_ctrlstatus_seq_item);

       `uvm_declare_p_sequencer(ccp_ctrlstatus_sequencer) 

       uvm_event                 init_done;
       rand bit                  rd_data;
       rand bit                  wr_data;
       rand bit                  alloc;
       rand bit                  port_sel;
       rand bit                  bypass;
       rand bit                  unq_addr;
       //addr_trans_mgr            m_addr_mgr;

       rand ctrlopcmd_enum_t     ctrlopcmd_p2;
       fill_addr_inflight_t      filldone_pkt;
       busy_index_way_t          busy_index_way_q[$];
       busy_index_way_t          busy_index_way_pkt;
       ccp_ctrl_pkt_t            rsp_pkt;
       ctrlop_addr_t             seq_addr;
       ctrlop_addr_t             temp_addr;
       ctrlop_addr_t             addr_q[$];
       ccp_ctrlop_addr_t         temp_addr_idx;
       ccp_ctrlop_addr_t         temp_idx;
       ccp_ctrlop_addr_t         temp_idx1;
       ccp_ctrlop_addr_t         temp_wayaddr;
       ccp_ctrlop_addr_t         index_q[$];
       ccp_ctrlop_addr_t         temp_index;
       ccp_ctrlop_security_t     chnl_security;
       ccp_ctrlop_bank_t         bank;
       ccp_ctrlop_waybusy_vec_t busyway;
       rand bit                  used_idx;

       int k_num_txn                              = 10;    
       int k_cache_warm_depth                     = 0;    
       int k_cache_used_idx_depth                 = 5;    
       int k_num_addr                             = 1;
       int k_num_read                             = 5;
       int k_num_write                            = 5;
       int wt_used_addr                           = 20;
       int wt_used_index                          = 50; 
       int wt_nop                                 = 10;
       int wt_wrtoarray                           = 50;
       int wt_wrtoarray_and_rdrsp_port            = 10;
       int wt_wrtoarray_and_evct_port             = 10;
       int wt_bypass_wrtordrsp_port               = 10;
       int wt_bypass_wrtordevct_port              = 10;
       int wt_rdtordrsp_port                      = 50;
       int wt_rdtoevct_port                       = 50;
       int wt_rdtoevct_wrbypasstorsp              = 10;
       int wt_rdtoevct_wrbypasstoevctp            = 10;
       int wt_wrtoarray_rdtoevctp                 = 10;
        //m_addr_mgr = addr_trans_mgr::get_instance();


       `uvm_object_utils_begin(ccp_ctrlstatus_seq);
         `uvm_field_int  (rd_data,UVM_ALL_ON)
         `uvm_field_int  (wr_data,UVM_ALL_ON)
         `uvm_field_int  (alloc,UVM_ALL_ON)
         `uvm_field_int  (port_sel,UVM_ALL_ON)
         `uvm_field_int  (bypass,UVM_ALL_ON)
         `uvm_field_int  (unq_addr,UVM_ALL_ON)
         `uvm_field_enum (ctrlopcmd_enum_t,ctrlopcmd_p2,UVM_ALL_ON)
       `uvm_object_utils_end

       function new (string name = "ccp_ctrlstatus_seq");
        super.new();
        //m_addr_mgr = addr_trans_mgr::get_instance();
       endfunction:new

       virtual task body();


        `uvm_info("body", "Entered...", UVM_NONE)

        if(!uvm_config_db#(uvm_event)::get(null,get_full_name(),"init_done",init_done )) begin
              `uvm_error("body", "Event init_done not found")
        end


        `uvm_info("body", "Waiting for memory initializations to complete", UVM_NONE)
        init_done.wait_ptrigger();
        `uvm_info("body", "memory initializations is complete", UVM_NONE)

        
        addr_q = {}; 
     // fork 
     //   begin
          repeat(k_num_txn) begin
            //#200ns          
             randcase
               wt_used_index     : used_idx = 1; 
               100-wt_used_index : used_idx = 0;
             endcase

            randcase
               100-wt_used_addr      :seq_addr = get_cacheline_addr(addr_q,unq_addr,1,used_idx);
               wt_used_addr          :seq_addr = get_cacheline_addr(addr_q,unq_addr,0,used_idx);        
            endcase

          <% if((obj.nTagBanks >1) && (obj.testBench !== 'psys')) { %>
                //temp_index = m_addr_mgr.get_set_index(seq_addr, agent_id):
                temp_index = CcpCalcIndex(seq_addr):
              <% if(obj.Block == 'aiu') { %>
                  bank = temp_index[<%=obj.BridgeAiuInfo[0].NativeInfo.IoCacheInfo.CacheInfo.TagBankSelBits[0]%>];
              <% } else if(obj.Block == 'dmi') { %>
                  bank = temp_index[<%=obj.DmiInfo[0].ccpParams.TagBankSelBits[0]%>];
              <% } else { %>
                  bank = 0;
              <% } %>
          <% } else { %>
              bank = 0;
          <% } %>

           `uvm_info("body",$sformatf("got addr :x%0x addr_q :%p bank: %b",seq_addr.addr,addr_q,bank), UVM_HIGH)
           `uvm_info("body",$sformatf("Index :%p used_idx :%b",index_q,used_idx), UVM_HIGH)
           if(!unq_addr) begin  
            randcase
               wt_nop                           :ctrlopcmd_p2 = NOP;  
               wt_wrtoarray                     :ctrlopcmd_p2 = WRDATATOARRAY;
               wt_wrtoarray_and_rdrsp_port      :ctrlopcmd_p2 = WRDATATOARRAYANDRDP; 
               wt_wrtoarray                     :ctrlopcmd_p2 = WRDATATOARRAY1;
               wt_wrtoarray_and_evct_port       :ctrlopcmd_p2 = WRDATATOARRAYANDEVCTP;
               wt_bypass_wrtordrsp_port         :ctrlopcmd_p2 = BYPASSWRTORDP;
               wt_bypass_wrtordevct_port        :ctrlopcmd_p2 = BYPASSWRTOEVCTP;
               wt_rdtordrsp_port                :ctrlopcmd_p2 = RDDATATORDP;
               wt_rdtoevct_port                 :ctrlopcmd_p2 = RDDATATOEVCTP;
              // wt_rdtoevct_wrbypasstorsp        :ctrlopcmd_p2 = RDDATAEVCTBYWRTORDRSP;
              // wt_rdtoevct_wrbypasstoevctp      :ctrlopcmd_p2 = RDDATAEVCTBYWRTOEVCTP;
               wt_wrtoarray_rdtoevctp           :ctrlopcmd_p2 = WRTOANDRDTOEVCT;
               wt_wrtoarray_rdtoevctp           :ctrlopcmd_p2 = WRTOANDRDTOEVCT1;
            endcase
           end else begin
             randcase
               wt_wrtoarray                     :ctrlopcmd_p2 = WRDATATOARRAY1;
               wt_rdtordrsp_port                :ctrlopcmd_p2 = RDDATATORDP;
               wt_rdtoevct_port                 :ctrlopcmd_p2 = RDDATATOEVCTP;
             endcase
           end
 
            {rd_data,wr_data,port_sel,bypass} = ctrlopcmd_p2; 
            temp_wayaddr =  seq_addr.addr;
            busyway = get_busy_way(temp_wayaddr,busy_index_way_q);
         //  `uvm_info("body",$sformatf("busyway :%0b busy way sb: %p",busyway,busy_index_way_q), UVM_NONE)

           `uvm_do_with(req,{req.m_ctrlstatus_pkt.rd_data       == rd_data;
                             req.m_ctrlstatus_pkt.wr_data       == wr_data;
                             req.m_ctrlstatus_pkt.addr          == seq_addr.addr;
                             req.m_ctrlstatus_pkt.security      == seq_addr.secu;
                             req.m_ctrlstatus_pkt.bnk           == bank;
                             req.m_ctrlstatus_pkt.burstln       == BURSTLN-1;
                             req.m_ctrlstatus_pkt.rsp_evict_sel == port_sel;
                             req.m_ctrlstatus_pkt.bypass        == bypass;
                             req.m_ctrlstatus_pkt.rp_update     == 'b0;
                             req.m_ctrlstatus_pkt.tagstateup    == 'b0;
                             req.m_ctrlstatus_pkt.state         == 'b0;
                             req.m_ctrlstatus_pkt.setway_debug  == 'b0;
                             req.m_ctrlstatus_pkt.waypbusy_vec  == busyway;
                             })
           get_response(rsp);
           `uvm_info("body",$sformatf("got response ctrlstatuspkt p2: %s",rsp.m_ctrlstatus_pkt.sprint_pkt()), UVM_HIGH)
          end
      //  end
      //  begin
      //    forever
      //      begin
      //       p_sequencer.m_cachectrlstatus_fifo.get(rsp_pkt);  
      //     `uvm_info("body",$sformatf("got response ctrlstatuspkt p2: %s",rsp_pkt.sprint_pkt()), UVM_MEDIUM)
      //       if(rsp_pkt.alloc) begin
      //         filldone_pkt.addr = rsp_pkt.addr;         
      //         filldone_pkt.wayn = rsp_pkt.wayn;         
      //         update_index_way(filldone_pkt,1,busy_index_way_q);
      //       end
      //      end 
      //  end
      //  begin
      //    forever
      //      begin
      //      p_sequencer.m_cachefillctrl_fifo.get(filldone_pkt);  
      //      update_index_way(filldone_pkt,0,busy_index_way_q);
      //  //   `uvm_info("body",$sformatf("got filldone_pkt addr :0x%0x way :0x%0x",filldone_pkt.addr,filldone_pkt.wayn), UVM_NONE)
      //      end
      //  end
    //  join_any
         `uvm_info("body", "Exited...", UVM_NONE)
       endtask:body
//----------------------------------------------------------------------------------------------------------
// function to give cacheline
//----------------------------------------------------------------------------------------------------------

       function ctrlop_addr_t get_cacheline_addr(ref ctrlop_addr_t  addr_q[$],bit unq_addr,input bit unq = 0,input bit used_idx);
           int                q_idx;
           bit                done;
           int                tmp_idx[$];
         `uvm_info("body",$sformatf("unq :%b warm_depth :%d wt_useq:%d wt_unq:%d ",unq,k_cache_warm_depth,100-wt_used_addr,wt_used_addr), UVM_MEDIUM)
            if(unq) begin
               tmp_idx = {};
              do
              begin
                assert(randomize(temp_addr));
                //addr = m_addr_mgr.req_cacheline(0, m_cache, addr_q,0, 1))); 

                tmp_idx =  addr_q.find_first_index with (item.addr == temp_addr.addr &&
                                                         item.secu == temp_addr.secu);
                if(!tmp_idx.size()) begin
                 done = 1;
                end
              end
              while(!done); 
              unq_addr = 1;
            end else begin
             if(addr_q.size() > k_cache_warm_depth) begin
               q_idx     = $urandom_range(0,addr_q.size()-1);        
               temp_addr = addr_q[q_idx]; 
               unq_addr = 0;
             end else begin
               tmp_idx = {};
               do
               begin
                 assert(randomize(temp_addr));
                 tmp_idx =  addr_q.find_first_index with (item.addr == temp_addr.addr &&
                                                         item.secu == temp_addr.secu);
                 if(!tmp_idx.size()) begin
                  done = 1;
                 end
               end
               while(!done); 
               unq_addr = 1;
             end
            end
            if(unq_addr) begin
              temp_addr.addr[WLOGCCPDATA -1:0] = '0;
              addr_q.push_back(temp_addr);
            end
           
            if(index_q.size() < k_cache_used_idx_depth) begin
              temp_addr_idx = temp_addr.addr;
              temp_idx1 = mapAddrToIndexbits(temp_addr_idx);  
              index_q.push_back(temp_idx1); 
            end
            else begin
              if(used_idx) begin
                q_idx          = $urandom_range(0,index_q.size()-1);
                temp_idx1      = index_q[q_idx];
                temp_addr_idx  = temp_addr.addr; 
                temp_addr.addr = mapCCPIndexToAddr(temp_addr_idx,temp_idx1); 
              end
            end
           return(temp_addr);          
       endfunction
//----------------------------------------------------------------------------------------------------------
// Scoreboard to keep track of busy way
//----------------------------------------------------------------------------------------------------------
       task update_index_way(input fill_addr_inflight_t  filldone_pkt,input bit set_flg,ref busy_index_way_t busy_index_way_q[$]);
          int bwy_idx_q[$];
          ccp_ctrlop_addr_t done_idx;
          ccp_ctrlop_waybusy_vec_t tmp_way;
          done_idx = mapAddrToIndexbits(filldone_pkt.addr);
          bwy_idx_q = {};
          bwy_idx_q =  busy_index_way_q.find_first_index with (item.indx == done_idx); 
          if(!set_flg) begin
            if(!bwy_idx_q.size()) begin
              `uvm_error("body","update_index_way: unexpected cache_fill_addr generated")   
            end else begin
               tmp_way = busy_index_way_q[bwy_idx_q[0]].wayn;
               tmp_way[filldone_pkt.wayn] = set_flg;
               busy_index_way_q[bwy_idx_q[0]].wayn = tmp_way; 
            end 
          end else begin
            if(!bwy_idx_q.size()) begin
              busy_index_way_pkt.indx = done_idx;
              busy_index_way_pkt.wayn[filldone_pkt.wayn] = set_flg;  
              busy_index_way_q.push_back(busy_index_way_pkt);
            end else begin
               busy_index_way_q[bwy_idx_q[0]].wayn[filldone_pkt.wayn] = set_flg; 
            end 
          end
       endtask:update_index_way
//----------------------------------------------------------------------------------------------------------
// function to get busy way
//----------------------------------------------------------------------------------------------------------
    function ccp_ctrlop_waybusy_vec_t get_busy_way(input ccp_ctrlop_addr_t addr, ref busy_index_way_t busy_index_way_q[$] );  
       int bwy_idx_q[$];
       ccp_ctrlop_addr_t idx;
       ccp_ctrlop_waybusy_vec_t tmp_way;
       idx = mapAddrToIndexbits(addr);
       bwy_idx_q = {};
       bwy_idx_q =  busy_index_way_q.find_first_index with (item.indx == idx ); 
       if(!bwy_idx_q.size()) begin
         tmp_way = 0;
       end else begin
         tmp_way = busy_index_way_q[bwy_idx_q[0]].wayn;
       end
      return(tmp_way);
    endfunction:get_busy_way

function ccp_ctrlop_addr_t  mapAddrToIndexbits(input ccp_ctrlop_addr_t  address);
 
    ccp_ctrlop_addr_t  index;
    ccp_ctrlop_addr_t indexbits;

//    indexbits = ncoreConfigInfo::get_set_Indexbits(agent_id); 
    index = address & indexbits;

    return index;
endfunction
function ccp_ctrlop_addr_t  mapCCPIndexToAddr(input ccp_ctrlop_addr_t address, IndexAddr);
 
    ccp_ctrlop_addr_t  index;
    ccp_ctrlop_addr_t  indexbits;

//    indexbits = ncoreConfigInfo::get_set_Indexbits(agent_id); 
    index = (address & ~indexbits ) | IndexAddr ;
    
    return index;
endfunction
endclass:ccp_ctrlstatus_seq
//--------------------------------------------------------------------
//  Busy way generate sequence
//---------------------------------------------------------------------
  
//----------------------------------------------------------------------------------------------------------
// fill sequence
//----------------------------------------------------------------------------------------------------------
  class ccp_cachefill_seq  extends uvm_sequence #(ccp_cachefill_seq_item);
     
       `uvm_declare_p_sequencer(ccp_cachefill_sequencer) 

       rand  ccp_cachestate_enum_t       state;
       rand  ccp_ctrlfill_security_t     security;
       ccp_cachefill_seq_item fillmiss_pkt;
       ccp_ctrlop_addr_t         temp_index;

       `uvm_object_utils_begin(ccp_cachefill_seq);
        `uvm_field_enum          (ccp_cachestate_enum_t,state, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int           (security, UVM_DEFAULT + UVM_NOPRINT)
       `uvm_object_utils_end

      
       function new (string name = "ccp_cachefill_seq");
        super.new();
       endfunction:new

       virtual task body();
        forever begin
          if (p_sequencer == null) begin
             $display("acessing the p_sequencer");
          end else begin
             $display("cachefill_fifo size : %0d", p_sequencer.m_cachefill_fifo.size());
          end
          p_sequencer.m_cachefill_fifo.get(fillmiss_pkt);  
    uvm_report_info("FILL SEQ", $sformatf("%t: e_fill_cacheline triggered fill : %s", $time, fillmiss_pkt.fillctrl_pkt.sprint_pkt()), UVM_HIGH);
          if(fillmiss_pkt.fillctrl_pkt.state == UD) begin
             state = UD;
          end else begin
<% if(obj.fnCacheStates === 'MEI'){ %>
             state = UC;
<% } else if(obj.fnCacheStates === 'MSI-IX' || obj.fnCacheStates === 'MSI-SC' ) { %>
             state = SC;
<% } %>
          end
         `uvm_do_with(req,{req.fillctrl_pkt.addr == fillmiss_pkt.fillctrl_pkt.addr;
                           req.fillctrl_pkt.wayn == fillmiss_pkt.fillctrl_pkt.wayn;
                         
                           req.fillctrl_pkt.state == state;
                           req.fillctrl_pkt.security == fillmiss_pkt.fillctrl_pkt.security;
                         //  req.filldata_pkt.pois  == 0;
                           req.filldata_pkt.wayn == fillmiss_pkt.fillctrl_pkt.wayn;
                           req.filldata_pkt.addr == fillmiss_pkt.fillctrl_pkt.addr;})
         get_response(rsp);
     uvm_report_info("body", $sformatf("rsp:cp_cachefill_seq: %s", rsp.filldata_pkt.sprint_pkt()), UVM_MEDIUM);
         end 
       endtask:body
  endclass:ccp_cachefill_seq

  class ccp_ctrlstatus_rd_seq  extends uvm_sequence #(ccp_ctrlstatus_seq_item);

       `uvm_declare_p_sequencer(ccp_ctrlstatus_sequencer) 

       rand bit                  rd_data;
       rand bit                  wr_data;
       rand bit                  alloc;
       rand bit                  port_sel;
       rand bit                  bypass;
       rand bit                  unq_addr;
       uvm_event                 init_done;

       rand ctrlopcmd_enum_t  ctrlopcmd_p2;
       rand ccp_ctrlop_addr_t seq_addr;
       rand ccp_ctrlop_addr_t temp_addr;
       ccp_ctrlop_burstln_t   burstln;
       ccp_ctrlop_addr_t      addr_q[$];
       ccp_ctrlop_security_t  chnl_security;
       ccp_ctrlop_bank_t      bank;
       ccp_ctrlop_addr_t      temp_index;

       int k_num_txn                              = 10;

       `uvm_object_utils_begin(ccp_ctrlstatus_rd_seq);
         `uvm_field_int  (rd_data,UVM_ALL_ON)
         `uvm_field_int  (wr_data,UVM_ALL_ON)
         `uvm_field_int  (seq_addr,UVM_ALL_ON)
         `uvm_field_int  (temp_addr,UVM_ALL_ON)
         `uvm_field_int  (alloc,UVM_ALL_ON)
         `uvm_field_int  (port_sel,UVM_ALL_ON)
         `uvm_field_int  (bypass,UVM_ALL_ON)
         `uvm_field_int  (unq_addr,UVM_ALL_ON)
         `uvm_field_enum (ctrlopcmd_enum_t,ctrlopcmd_p2,UVM_ALL_ON)
       `uvm_object_utils_end

       function new (string name = "ccp_ctrlstatus_rd_seq");
        super.new();
       endfunction:new

       virtual task body();


        `uvm_info("body", "Entered...", UVM_MEDIUM)

         if(!uvm_config_db#(uvm_event)::get(null,get_full_name(),"init_done",init_done )) begin
               `uvm_error("body", "Event init_done not found")
         end
         
         `uvm_info("body", "Waiting for memory initializations to complete", UVM_MEDIUM)
         init_done.wait_ptrigger();

          ctrlopcmd_p2                 = RDDATATORDP;                      

         repeat(k_num_txn) begin
          assert(randomize(temp_addr));

          temp_addr[WLOGCCPDATA -1:0] = '0;
          seq_addr = temp_addr;
          burstln = 'h3; 
          <% if((obj.nTagBanks >1) && (obj.testBench !== 'psys')) { %>
                //temp_index = m_addr_mgr.get_set_index(seq_addr, agent_id):
                temp_index = CcpCalcIndex(seq_addr):
              <% if(obj.Block == 'aiu') { %>
                  bank = temp_index[<%=obj.BridgeAiuInfo[0].NativeInfo.IoCacheInfo.CacheInfo.TagBankSelBits[0]%>];
              <% } else if(obj.Block == 'dmi') { %>
                  bank = temp_index[<%=obj.DmiInfo[0].ccpParams.TagBankSelBits[0]%>];
              <% } else { %>
                  bank = 0;
              <% } %>
          <% } else { %>
              bank = 0;
          <% } %>
         `uvm_info("body",$sformatf("got addr :x%0x addr_q :%p bank: %b",seq_addr,addr_q,bank), UVM_HIGH)
          {rd_data,wr_data,port_sel,bypass} = ctrlopcmd_p2; 
         //repeat(2) begin
         `uvm_do_with(req,{req.m_ctrlstatus_pkt.rd_data       == rd_data;
                           req.m_ctrlstatus_pkt.wr_data       == wr_data;
                           req.m_ctrlstatus_pkt.addr          == seq_addr;
                           req.m_ctrlstatus_pkt.bnk           == bank;
                           req.m_ctrlstatus_pkt.rsp_evict_sel == port_sel;
                           req.m_ctrlstatus_pkt.bypass        == bypass;
                           req.m_ctrlstatus_pkt.burstln       == BURSTLN-1;
                           req.m_ctrlstatus_pkt.security      == chnl_security;
                           req.m_ctrlstatus_pkt.rp_update     == 'b0;
                           req.m_ctrlstatus_pkt.tagstateup    == 'b0;
                           req.m_ctrlstatus_pkt.state         == 'b0;
                           req.m_ctrlstatus_pkt.setway_debug  == 'b0;
                           req.m_ctrlstatus_pkt.waypbusy_vec  == 'b0;})
                           //req.m_wr_pkt.pois            == 'b0;})
         get_response(rsp);
          #400ns;
         end
         `uvm_info("body",$sformatf("seq_addr PUSH :0x%0x ctrlopcmd_p2 :%s ",req.m_ctrlstatus_pkt.addr,ctrlopcmd_p2.name()), UVM_MEDIUM)
         `uvm_info("body", "Exited...", UVM_MEDIUM)
       endtask:body

  endclass:ccp_ctrlstatus_rd_seq
  class ccp_ctrlstatus_wr_seq  extends uvm_sequence #(ccp_ctrlstatus_seq_item);

       `uvm_declare_p_sequencer(ccp_ctrlstatus_sequencer) 

       rand bit                  rd_data;
       rand bit                  wr_data;
       rand bit                  alloc;
       rand bit                  port_sel;
       rand bit                  bypass;
       rand bit                  unq_addr;
       uvm_event                 init_done;

       rand ctrlopcmd_enum_t  ctrlopcmd_p2;
       rand ccp_ctrlop_addr_t seq_addr;
       rand ccp_ctrlop_addr_t temp_addr;
       ccp_ctrlop_addr_t      addr_q[$];
       ccp_ctrlop_security_t  chnl_security;
       ccp_ctrlop_bank_t      bank;
       ccp_ctrlop_addr_t      temp_index;
       ccp_ctrlop_burstln_t     burstln;



       `uvm_object_utils_begin(ccp_ctrlstatus_wr_seq);
         `uvm_field_int  (rd_data,UVM_ALL_ON)
         `uvm_field_int  (wr_data,UVM_ALL_ON)
         `uvm_field_int  (seq_addr,UVM_ALL_ON)
         `uvm_field_int  (temp_addr,UVM_ALL_ON)
         `uvm_field_int  (alloc,UVM_ALL_ON)
         `uvm_field_int  (port_sel,UVM_ALL_ON)
         `uvm_field_int  (bypass,UVM_ALL_ON)
         `uvm_field_int  (unq_addr,UVM_ALL_ON)
         `uvm_field_enum (ctrlopcmd_enum_t,ctrlopcmd_p2,UVM_ALL_ON)
       `uvm_object_utils_end

       function new (string name = "ccp_ctrlstatus_wr_seq");
        super.new();
       endfunction:new

       virtual task body();


        `uvm_info("body", "Entered...", UVM_MEDIUM)

         if(!uvm_config_db#(uvm_event)::get(null,get_full_name(),"init_done",init_done )) begin
               `uvm_error("body", "Event init_done not found")
         end
         
         `uvm_info("body", "Waiting for memory initializations to complete", UVM_MEDIUM)
         init_done.wait_ptrigger();

          ctrlopcmd_p2                 = WRDATATOARRAY;                      
          assert(randomize(temp_addr));
          temp_addr[WLOGCCPDATA -1:0] = '0;
 
          seq_addr = temp_addr;
          <% if((obj.nTagBanks >1) && (obj.testBench !== 'psys')) { %>
                //temp_index = m_addr_mgr.get_set_index(seq_addr, agent_id):
                temp_index = CcpCalcIndex(seq_addr):
              <% if(obj.Block == 'aiu') { %>
                  bank = temp_index[<%=obj.BridgeAiuInfo[0].NativeInfo.IoCacheInfo.CacheInfo.TagBankSelBits[0]%>];
              <% } else if(obj.Block == 'dmi') { %>
                  bank = temp_index[<%=obj.DmiInfo[0].ccpParams.TagBankSelBits[0]%>];
              <% } else { %>
                  bank = 0;
              <% } %>
          <% } else { %>
              bank = 0;
          <% } %>
         `uvm_info("body",$sformatf("got addr :x%0x addr_q :%p bank: %b",seq_addr,addr_q,bank), UVM_HIGH)
 
          {rd_data,wr_data,port_sel,bypass} = ctrlopcmd_p2;
          burstln = 'h3; 
         `uvm_do_with(req,{req.m_ctrlstatus_pkt.rd_data       == rd_data;
                           req.m_ctrlstatus_pkt.wr_data       == wr_data;
                           req.m_ctrlstatus_pkt.addr          == seq_addr;
                           req.m_ctrlstatus_pkt.bnk           == bank;
                           req.m_ctrlstatus_pkt.rsp_evict_sel == port_sel;
                           req.m_ctrlstatus_pkt.bypass        == bypass;
                           req.m_ctrlstatus_pkt.burstln       == BURSTLN-1;
                           req.m_ctrlstatus_pkt.security      == chnl_security;
                           req.m_ctrlstatus_pkt.rp_update     == 'b0;
                           req.m_ctrlstatus_pkt.tagstateup    == 'b0;
                           req.m_ctrlstatus_pkt.state         == 'b0;
                           req.m_ctrlstatus_pkt.setway_debug  == 'b0;
                          // req.m_wr_pkt.pois                  == 'b0;
                           req.m_ctrlstatus_pkt.waypbusy_vec  == 'b0;})
         get_response(rsp);
          #400ns;
          ctrlopcmd_p2                 = RDDATATORDP;                      
 
          {rd_data,wr_data,port_sel,bypass} = ctrlopcmd_p2; 
         `uvm_do_with(req,{req.m_ctrlstatus_pkt.rd_data       == rd_data;
                           req.m_ctrlstatus_pkt.wr_data       == wr_data;
                           req.m_ctrlstatus_pkt.addr          == seq_addr;
                           req.m_ctrlstatus_pkt.bnk           == bank;
                           req.m_ctrlstatus_pkt.rsp_evict_sel == port_sel;
                           req.m_ctrlstatus_pkt.bypass        == bypass;
                           req.m_ctrlstatus_pkt.burstln       == BURSTLN-1;
                           req.m_ctrlstatus_pkt.security      == chnl_security;
                           req.m_ctrlstatus_pkt.rp_update     == 'b0;
                           req.m_ctrlstatus_pkt.tagstateup    == 'b0;
                           req.m_ctrlstatus_pkt.state         == 'b0;
                           req.m_ctrlstatus_pkt.setway_debug  == 'b0;
                          // req.m_wr_pkt.pois                  == 'b0;
                           req.m_ctrlstatus_pkt.waypbusy_vec  == 'b0;})
         get_response(rsp);
          #400ns;
          ctrlopcmd_p2                 = WRDATATOARRAY;                      
          {rd_data,wr_data,port_sel,bypass} = ctrlopcmd_p2; 
         `uvm_do_with(req,{req.m_ctrlstatus_pkt.rd_data       == rd_data;
                           req.m_ctrlstatus_pkt.wr_data       == wr_data;
                           req.m_ctrlstatus_pkt.addr          == seq_addr;
                           req.m_ctrlstatus_pkt.bnk           == bank;
                           req.m_ctrlstatus_pkt.rsp_evict_sel == port_sel;
                           req.m_ctrlstatus_pkt.bypass        == bypass;
                           req.m_ctrlstatus_pkt.burstln       == BURSTLN-1;
                           req.m_ctrlstatus_pkt.security      == chnl_security;
                           req.m_ctrlstatus_pkt.rp_update     == 'b0;
                           req.m_ctrlstatus_pkt.tagstateup    == 'b0;
                           req.m_ctrlstatus_pkt.state         == 'b0;
                           req.m_ctrlstatus_pkt.setway_debug  == 'b0;
                         //  req.m_wr_pkt.pois                  == 'b0;
                           req.m_ctrlstatus_pkt.waypbusy_vec  == 'b0;})
         get_response(rsp);
          #400ns;
          ctrlopcmd_p2                 = RDDATATORDP;                      
 
          {rd_data,wr_data,port_sel,bypass} = ctrlopcmd_p2; 
         `uvm_do_with(req,{req.m_ctrlstatus_pkt.rd_data       == rd_data;
                           req.m_ctrlstatus_pkt.wr_data       == wr_data;
                           req.m_ctrlstatus_pkt.addr          == seq_addr;
                           req.m_ctrlstatus_pkt.bnk           == bank;
                           req.m_ctrlstatus_pkt.rsp_evict_sel == port_sel;
                           req.m_ctrlstatus_pkt.bypass        == bypass;
                           req.m_ctrlstatus_pkt.burstln       == BURSTLN-1;
                           req.m_ctrlstatus_pkt.security      == chnl_security;
                           req.m_ctrlstatus_pkt.rp_update     == 'b0;
                           req.m_ctrlstatus_pkt.tagstateup    == 'b0;
                           req.m_ctrlstatus_pkt.state         == 'b0;
                          // req.m_wr_pkt.pois                  == 'b0;
                           req.m_ctrlstatus_pkt.setway_debug  == 'b0;
                           req.m_ctrlstatus_pkt.waypbusy_vec  == 'b0;})
         get_response(rsp);
         `uvm_info("body",$sformatf("seq_addr PUSH :0x%0x ctrlopcmd_p2 :%s ",req.m_ctrlstatus_pkt.addr,ctrlopcmd_p2.name()), UVM_MEDIUM)
         `uvm_info("body", "Exited...", UVM_MEDIUM)
       endtask:body

  endclass:ccp_ctrlstatus_wr_seq
  class ccp_ctrlstatus_wrhit_rdhit_seq  extends uvm_sequence #(ccp_ctrlstatus_seq_item);

       `uvm_declare_p_sequencer(ccp_ctrlstatus_sequencer) 

       rand bit                  rd_data;
       rand bit                  wr_data;
       rand bit                  alloc;
       rand bit                  port_sel;
       rand bit                  bypass;
       rand bit                  unq_addr;
       uvm_event                 init_done;

       rand ctrlopcmd_enum_t  ctrlopcmd_p2;
       rand ccp_ctrlop_addr_t seq_addr;
       rand ccp_ctrlop_addr_t temp_addr;
       ccp_ctrlop_addr_t      addr_q[$];
       ccp_ctrlop_security_t  chnl_security;
       ccp_ctrlop_bank_t      bank;
       ccp_ctrlop_addr_t      temp_index;
       ccp_ctrlop_burstln_t     burstln;



       `uvm_object_utils_begin(ccp_ctrlstatus_wrhit_rdhit_seq);
         `uvm_field_int  (rd_data,UVM_ALL_ON)
         `uvm_field_int  (wr_data,UVM_ALL_ON)
         `uvm_field_int  (seq_addr,UVM_ALL_ON)
         `uvm_field_int  (temp_addr,UVM_ALL_ON)
         `uvm_field_int  (alloc,UVM_ALL_ON)
         `uvm_field_int  (port_sel,UVM_ALL_ON)
         `uvm_field_int  (bypass,UVM_ALL_ON)
         `uvm_field_int  (unq_addr,UVM_ALL_ON)
         `uvm_field_enum (ctrlopcmd_enum_t,ctrlopcmd_p2,UVM_ALL_ON)
       `uvm_object_utils_end

       function new (string name = "ccp_ctrlstatus_wrhit_rdhit_seq");
        super.new();
       endfunction:new

       virtual task body();


        `uvm_info("body", "Entered...", UVM_MEDIUM)

         if(!uvm_config_db#(uvm_event)::get(null,get_full_name(),"init_done",init_done )) begin
               `uvm_error("body", "Event init_done not found")
         end
         
         `uvm_info("body", "Waiting for memory initializations to complete", UVM_MEDIUM)
         init_done.wait_ptrigger();

          ctrlopcmd_p2                 = WRDATATOARRAY;                      
          assert(randomize(temp_addr));
          temp_addr[WLOGCCPDATA -1:0] = '0;
 
          seq_addr = temp_addr;
          <% if((obj.nTagBanks >1) && (obj.testBench !== 'psys')) { %>
                //temp_index = m_addr_mgr.get_set_index(seq_addr, agent_id):
                temp_index = CcpCalcIndex(seq_addr):
              <% if(obj.Block == 'aiu') { %>
                  bank = temp_index[<%=obj.BridgeAiuInfo[0].NativeInfo.IoCacheInfo.CacheInfo.TagBankSelBits[0]%>];
              <% } else if(obj.Block == 'dmi') { %>
                  bank = temp_index[<%=obj.DmiInfo[0].ccpParams.TagBankSelBits[0]%>];
              <% } else { %>
                  bank = 0;
              <% } %>
          <% } else { %>
              bank = 0;
          <% } %>
         `uvm_info("body",$sformatf("got addr :x%0x addr_q :%p bank: %b",seq_addr,addr_q,bank), UVM_HIGH)
 
          {rd_data,wr_data,port_sel,bypass} = ctrlopcmd_p2;
          burstln = 'h3; 
         `uvm_do_with(req,{req.m_ctrlstatus_pkt.rd_data       == rd_data;
                           req.m_ctrlstatus_pkt.wr_data       == wr_data;
                           req.m_ctrlstatus_pkt.addr          == seq_addr;
                           req.m_ctrlstatus_pkt.bnk           == bank;
                           req.m_ctrlstatus_pkt.rsp_evict_sel == port_sel;
                           req.m_ctrlstatus_pkt.bypass        == bypass;
                           req.m_ctrlstatus_pkt.burstln       == BURSTLN-1;
                           req.m_ctrlstatus_pkt.security      == chnl_security;
                           req.m_ctrlstatus_pkt.rp_update     == 'b0;
                           req.m_ctrlstatus_pkt.tagstateup    == 'b0;
                           req.m_ctrlstatus_pkt.state         == 'b0;
                           req.m_ctrlstatus_pkt.setway_debug  == 'b0;
                          // req.m_wr_pkt.pois                  == 'b0;
                           req.m_ctrlstatus_pkt.waypbusy_vec  == 'b0;})
         get_response(rsp);
          #400ns;
          ctrlopcmd_p2                 = RDDATATORDP;                      
 
          {rd_data,wr_data,port_sel,bypass} = ctrlopcmd_p2; 
         `uvm_do_with(req,{req.m_ctrlstatus_pkt.rd_data       == rd_data;
                           req.m_ctrlstatus_pkt.wr_data       == wr_data;
                           req.m_ctrlstatus_pkt.addr          == seq_addr;
                           req.m_ctrlstatus_pkt.bnk           == bank;
                           req.m_ctrlstatus_pkt.rsp_evict_sel == port_sel;
                           req.m_ctrlstatus_pkt.bypass        == bypass;
                           req.m_ctrlstatus_pkt.burstln       == BURSTLN-1;
                           req.m_ctrlstatus_pkt.security      == chnl_security;
                           req.m_ctrlstatus_pkt.rp_update     == 'b0;
                           req.m_ctrlstatus_pkt.tagstateup    == 'b0;
                           req.m_ctrlstatus_pkt.state         == 'b0;
                           req.m_ctrlstatus_pkt.setway_debug  == 'b0;
                          // req.m_wr_pkt.pois                  == 'b0;
                           req.m_ctrlstatus_pkt.waypbusy_vec  == 'b0;})
         get_response(rsp);
          #400ns;
          ctrlopcmd_p2                 = WRDATATOARRAY;                      
          {rd_data,wr_data,port_sel,bypass} = ctrlopcmd_p2; 
         `uvm_do_with(req,{req.m_ctrlstatus_pkt.rd_data       == rd_data;
                           req.m_ctrlstatus_pkt.wr_data       == wr_data;
                           req.m_ctrlstatus_pkt.addr          == seq_addr;
                           req.m_ctrlstatus_pkt.bnk           == bank;
                           req.m_ctrlstatus_pkt.rsp_evict_sel == port_sel;
                           req.m_ctrlstatus_pkt.bypass        == bypass;
                           req.m_ctrlstatus_pkt.burstln       == BURSTLN-1;
                           req.m_ctrlstatus_pkt.security      == chnl_security;
                           req.m_ctrlstatus_pkt.rp_update     == 'b0;
                           req.m_ctrlstatus_pkt.tagstateup    == 'b0;
                           req.m_ctrlstatus_pkt.state         == 'b0;
                           req.m_ctrlstatus_pkt.setway_debug  == 'b0;
                         //  req.m_wr_pkt.pois                  == 'b0;
                           req.m_ctrlstatus_pkt.waypbusy_vec  == 'b0;})
         get_response(rsp);
         ctrlopcmd_p2                 = RDDATATORDP;                      
 
          {rd_data,wr_data,port_sel,bypass} = ctrlopcmd_p2; 
         `uvm_do_with(req,{req.m_ctrlstatus_pkt.rd_data       == rd_data;
                           req.m_ctrlstatus_pkt.wr_data       == wr_data;
                           req.m_ctrlstatus_pkt.addr          == seq_addr;
                           req.m_ctrlstatus_pkt.bnk           == bank;
                           req.m_ctrlstatus_pkt.rsp_evict_sel == port_sel;
                           req.m_ctrlstatus_pkt.bypass        == bypass;
                           req.m_ctrlstatus_pkt.burstln       == BURSTLN-1;
                           req.m_ctrlstatus_pkt.security      == chnl_security;
                           req.m_ctrlstatus_pkt.rp_update     == 'b0;
                           req.m_ctrlstatus_pkt.tagstateup    == 'b0;
                           req.m_ctrlstatus_pkt.state         == 'b0;
                          // req.m_wr_pkt.pois                  == 'b0;
                           req.m_ctrlstatus_pkt.setway_debug  == 'b0;
                           req.m_ctrlstatus_pkt.waypbusy_vec  == 'b0;})
         get_response(rsp);
          #400ns;
      repeat(10)
         begin
          ctrlopcmd_p2                 = WRDATATOARRAY;                      
          {rd_data,wr_data,port_sel,bypass} = ctrlopcmd_p2; 
         `uvm_do_with(req,{req.m_ctrlstatus_pkt.rd_data       == rd_data;
                           req.m_ctrlstatus_pkt.wr_data       == wr_data;
                           req.m_ctrlstatus_pkt.addr          == seq_addr;
                           req.m_ctrlstatus_pkt.bnk           == bank;
                           req.m_ctrlstatus_pkt.rsp_evict_sel == port_sel;
                           req.m_ctrlstatus_pkt.bypass        == bypass;
                           req.m_ctrlstatus_pkt.burstln       == BURSTLN-1;
                           req.m_ctrlstatus_pkt.security      == chnl_security;
                           req.m_ctrlstatus_pkt.rp_update     == 'b0;
                           req.m_ctrlstatus_pkt.tagstateup    == 'b0;
                           req.m_ctrlstatus_pkt.state         == 'b0;
                           req.m_ctrlstatus_pkt.setway_debug  == 'b0;
                         //  req.m_wr_pkt.pois                  == 'b0;
                           req.m_ctrlstatus_pkt.waypbusy_vec  == 'b0;})
         get_response(rsp);
         ctrlopcmd_p2                 = RDDATATORDP;                      
 
          {rd_data,wr_data,port_sel,bypass} = ctrlopcmd_p2; 
         `uvm_do_with(req,{req.m_ctrlstatus_pkt.rd_data       == rd_data;
                           req.m_ctrlstatus_pkt.wr_data       == wr_data;
                           req.m_ctrlstatus_pkt.addr          == seq_addr;
                           req.m_ctrlstatus_pkt.bnk           == bank;
                           req.m_ctrlstatus_pkt.rsp_evict_sel == port_sel;
                           req.m_ctrlstatus_pkt.bypass        == bypass;
                           req.m_ctrlstatus_pkt.burstln       == BURSTLN-1;
                           req.m_ctrlstatus_pkt.security      == chnl_security;
                           req.m_ctrlstatus_pkt.rp_update     == 'b0;
                           req.m_ctrlstatus_pkt.tagstateup    == 'b0;
                           req.m_ctrlstatus_pkt.state         == 'b0;
                          // req.m_wr_pkt.pois                  == 'b0;
                           req.m_ctrlstatus_pkt.setway_debug  == 'b0;
                           req.m_ctrlstatus_pkt.waypbusy_vec  == 'b0;})
         get_response(rsp);
       end
         `uvm_info("body",$sformatf("seq_addr PUSH :0x%0x ctrlopcmd_p2 :%s ",req.m_ctrlstatus_pkt.addr,ctrlopcmd_p2.name()), UVM_MEDIUM)
         `uvm_info("body", "Exited...", UVM_MEDIUM)
       endtask:body

  endclass:ccp_ctrlstatus_wrhit_rdhit_seq
