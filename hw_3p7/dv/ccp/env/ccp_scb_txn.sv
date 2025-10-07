typedef enum bit [3:0] {READ, EVICT, WRITE,WRITE_HIT,WRITE_HIT_BYPASS,BYPASS,FILL,WRITEALLOC,MAINTOP} op_cmd_type_t;

class ccp_scb_txn extends uvm_object;

ccp_wr_data_pkt_t       m_ccp_wr_data_pkt;
ccp_wr_data_pkt_t       m_ccp_exp_bypass_data_pkt;
ccp_ctrl_pkt_t          m_ccp_ctrl_pkt;
ccp_fillctrl_pkt_t      m_ccp_fill_ctrl_pkt;
ccp_filldata_pkt_t      m_ccp_fill_data_pkt;
ccp_rd_rsp_pkt_t        m_ccp_got_rd_rsp_pkt;
ccp_rd_rsp_pkt_t        m_ccp_exp_rd_rsp_pkt;
ccp_evict_pkt_t         m_ccp_got_evict_pkt;
ccp_evict_pkt_t         m_ccp_exp_evict_pkt;
ccpCacheLine            m_evict_cache_pkt;
ccp_ctrlop_addr_t       ccp_addr;
ccp_ctrlop_addr_t       evict_addr;
ccp_ctrlop_addr_t       pendingaddr;
ccp_cachestate_enum_t   pendingstate;
ccp_ctrlwr_data_t       m_ccp_cache_data[];
bit                     m_dataErrorPerBeat[];

int                     ccp_index;
int                     fillwayn ;
int                     hitwayn ;
int                     pendingwayn ;
bit                     security;
bit                     evict_security;
bit                     pendingsecurity;
bit                     pendingrpUpdate;
bit                     port_sel;
bit                     isfillpending;
bit                     fillpending;
bit                     isdropped;
bit                     isCacheInvld;
bit                     DeleteCl;
bit [31:0]              scb_txn_id;


typedef enum bit [2:0] {READ_HIT, READ_MISS, WRITE_HIT, WRITE_MISS,WRITE_HIT_UPGRADE,SNOOP} cmd_type_t;

op_cmd_type_t m_op_cmd_type;


bit dtr_req_rcvd;
bit dtw_req_rcvd;
bit isEvictDtwNeeded;
bit isEvictUpdNeeded;
bit isHit;
bit isMntop;
bit isSnoop;
bit isflush;
bit isRead;
bit isWrTh;
bit isBypass;
bit isEvict;
bit isEvictDataAdded;//Flag to denote if TB has added evicted data in this entry
bit isEvicted;
bit isBypassrdrsp;
bit isBypassevict;
bit isReadDataRcvd;
bit isEvictDataRcvd;
bit isWrite;
bit isWriteAlloc;
bit isWriteHitUpgrade;
bit isWritePending;
bit isFillCtrlRcvd;
bit isFillDataRcvd;
bit isFillReqd;
bit isWriteDataRcvd;
bit isBypassDataRcvd;
bit isLookupDone;

bit write_upgrade;
time t_scb_txn;
string spkt;
//addr_trans_mgr m_addr_mgr;


//Setup Ctrl packet
function void setup_ccp_ctrl_pkt(ccp_ctrl_pkt_t m_pkt,int agnt_id);

    //m_addr_mgr = addr_trans_mgr::get_instance();
    t_scb_txn = $time ;

   if(m_pkt.isMntOp  && m_pkt.setway_debug)begin
     ccp_addr  = m_pkt.evictaddr;
     security  = m_pkt.evictsecurity;
   end
   else begin
     ccp_addr  = m_pkt.addr;
     security  = m_pkt.security;
   end
    hitwayn   = onehot_to_binay(m_pkt.hitwayn);
    port_sel  = m_pkt.rsp_evict_sel;
    evict_addr     = m_pkt.evictaddr;
    evict_security = m_pkt.evictsecurity;
    //ccp_index =  addrMgrConst::get_set_index(ccp_addr,agent_id);
    ccp_index =  CcpCalcIndex(ccp_addr);
    
    /*if(m_pkt.isMntOp) begin
      isMntop = 1;
      m_op_cmd_type = MAINTOP;
      if(m_pkt.rd_data)begin
        isRead = 1'b1;
      end
      if(m_pkt.currstate == UD)begin
        isEvict = 1'b1;
        if(!m_pkt.rsp_evict_sel) begin
          isBypassrdrsp = 1;
        end else begin
          isBypassevict = 1;
        end
      end
      if(m_pkt.tagstateup && m_pkt.state == IX) begin
        isflush = 1;
      end
    end
    else*/
    if(m_pkt.rd_data && !m_pkt.evictvld) begin
        isRead = 1'b1;
      if(!m_pkt.rsp_evict_sel) begin
        isBypassrdrsp = 1;
      end else begin
        isBypassevict = 1;
      end
    end 
    else if(m_pkt.wr_data && m_pkt.bypass) begin
        isWrite  = 1;
        isBypass = 1;
        isWrTh   = 1;
      if(!m_pkt.rsp_evict_sel) begin
        isBypassrdrsp = 1;
      end else begin
        isBypassevict = 1;
      end
    end 
    else if(!m_pkt.wr_data &&  m_pkt.bypass) begin
        isBypass = 1'b1;
      if(!m_pkt.rsp_evict_sel) begin
        isBypassrdrsp = 1;
      end else begin
        isBypassevict = 1;
      end
    end 
    else if(m_pkt.wr_data && m_pkt.alloc && !m_pkt.nacknoalloc) begin
      isWrite = 1'b1;
      isWriteAlloc = 1'b1;
    end 
 <% if(obj.Block !== "dmi") { %>                           
    else if(m_pkt.write_hit_upgrade && m_pkt.alloc && !m_pkt.nacknoalloc) begin
      isWriteHitUpgrade = 1'b1;
      isFillReqd = 1'b1;
    end 
 <% } %>
    else if(m_pkt.wr_data && !m_pkt.alloc) begin
        isWrite = 1'b1;
    end 
    else if(m_pkt.alloc && !(m_pkt.nacknoalloc)) begin
        isFillReqd = 1'b1;
    end
    else if(m_pkt.tagstateup && m_pkt.state == IX &&  m_pkt.currstate == SC) begin
        isflush = 1;
    end

    if(!isWriteHitUpgrade) begin
      fillwayn  = m_pkt.wayn;
    end
    else begin
      fillwayn  = hitwayn;
    end

    if(m_pkt.isSnoop)begin
      isSnoop = 1;
    end
    if(m_pkt.evictvld && m_pkt.rd_data) begin
      evict_addr     = m_pkt.evictaddr;
      evict_security = m_pkt.evictsecurity;
      isBypassevict  = 1;
      isEvict        = 1;
    end
    m_ccp_ctrl_pkt = new();
    m_ccp_ctrl_pkt.copy(m_pkt);
endfunction



//Print Function
function void print_me();

    `uvm_info("CCP-SB",$psprintf("t_scb_txn :%t ccp_addr :x%0x, security :%0b fillwayn :%0b m_op_cmd_type :%s ",t_scb_txn,ccp_addr,security,fillwayn,m_op_cmd_type.name()),UVM_NONE)
    `uvm_info("CCP-SB",$psprintf("isHit :%0b, isRead :%0b, isWrite :%0b isBypass :%0b, isEvict :%0b isWriteAlloc :%0b, write_upgrade :%0b isMntOp :%0b isdropped :%0b isSnoop :%0b isWriteHitUpgrade :%0b isflush :%0b isWritePending :%0b isCacheInvld :%0b %0b {isFillReqd,isBypassrdrsp,isBypassevict,isFillCtrlRcvd,isFillDataRcvd,isReadDataRcvd,isWriteDataRcvd,isBypassDataRcvd,isEvictDataRcvd}",
                 isHit,isRead,isWrite,isBypass,isEvict,isWriteAlloc,write_upgrade,isMntop,isdropped,isSnoop,isWriteHitUpgrade,isflush,isWritePending,isCacheInvld,{isFillReqd,isBypassrdrsp,isBypassevict,isFillCtrlRcvd,isFillDataRcvd,isReadDataRcvd,isWriteDataRcvd,isBypassDataRcvd,isEvictDataRcvd}),UVM_NONE);  

        //Ctrl pkt  
        `uvm_info("CCP_CTRL_PKT", $psprintf("%s",m_ccp_ctrl_pkt.sprint_pkt()),UVM_NONE)
    if(isRead) begin
        //Rd Rsp
        if(isHit & isReadDataRcvd  )
            `uvm_info("CCP_RD_RSP_PKT", $psprintf("%s",m_ccp_got_rd_rsp_pkt.sprint_pkt()),UVM_NONE)

    end else if(isEvict) begin
        //Evict
        if(isEvict & isEvictDataRcvd)
            `uvm_info("CCP_EVICT_PKT", $psprintf("%s",m_ccp_got_evict_pkt.sprint_pkt()),UVM_NONE)

    end else if(isWrite & !isBypass) begin
        if(isHit & isWriteDataRcvd )
            `uvm_info("CCP_WR_DATA_PKT", $psprintf("%s",m_ccp_wr_data_pkt.sprint_pkt()),UVM_NONE)

    end else if(isBypass) begin
        if(isHit & isWriteDataRcvd )
            `uvm_info("CCP_WR_DATA_PKT", $psprintf("%s",m_ccp_wr_data_pkt.sprint_pkt()),UVM_NONE)

    end else if(!isHit && isFillReqd ) begin
        //Fill
        if(isFillCtrlRcvd) begin
            `uvm_info("CCP_FILL_CTRL_PKT", $psprintf("%s",m_ccp_fill_ctrl_pkt.sprint_pkt()),UVM_NONE)
        end
        if(isFillDataRcvd) begin
            `uvm_info("CCP_FILL_DATA_PKT", $psprintf("%s",m_ccp_fill_data_pkt.sprint_pkt()),UVM_NONE)
        end

    end

endfunction
function void print_debug();

    `uvm_info("CCP-SB",$psprintf("t_scb_txn :%t ccp_addr :x%0x, security :%0b fillwayn :%0b m_op_cmd_type :%s ",t_scb_txn,ccp_addr,security,fillwayn,m_op_cmd_type.name()),UVM_MEDIUM)
    `uvm_info("CCP-SB",$psprintf("isHit :%0b, isRead :%0b, isWrite :%0b isBypass :%0b, isEvict :%0b isWriteAlloc :%0b, write_upgrade :%0b isMntOp :%0b isdropped :%0b isSnoop %0b, isWritePending :%0b isCacheInvld :%0b %0b {isFillReqd,isBypassrdrsp,isBypassevict,isFillCtrlRcvd,isFillDataRcvd,isReadDataRcvd,isWriteDataRcvd,isBypassDataRcvd,isEvictDataRcvd}",
                 isHit,isRead,isWrite,isBypass,isEvict,isWriteAlloc,write_upgrade,isMntop,isdropped,isSnoop,isWritePending,isCacheInvld,{isFillReqd,isBypassrdrsp,isBypassevict,isFillCtrlRcvd,isFillDataRcvd,isReadDataRcvd,isWriteDataRcvd,isBypassDataRcvd,isEvictDataRcvd}),UVM_MEDIUM);  

        `uvm_info("CCP_CTRL_PKT", $psprintf("%s",m_ccp_ctrl_pkt.sprint_pkt()),UVM_MEDIUM)
    if(isRead) begin
        //Rd Rsp
        if(isHit & isReadDataRcvd  )
            `uvm_info("CCP_RD_RSP_PKT", $psprintf("%s",m_ccp_got_rd_rsp_pkt.sprint_pkt()),UVM_MEDIUM)

    end else if((isEvict|| isEvicted)) begin
        //Evict
        if(isEvictDataRcvd)
            `uvm_info("CCP_EVICT_PKT", $psprintf("%s",m_ccp_got_evict_pkt.sprint_pkt()),UVM_MEDIUM)

    end else if(isWrite & !isBypass) begin
        if(isHit & isWriteDataRcvd )
            `uvm_info("CCP_WR_DATA_PKT", $psprintf("%s",m_ccp_wr_data_pkt.sprint_pkt()),UVM_MEDIUM)

    end else if(isBypass) begin
        if(isHit & isWriteDataRcvd )
            `uvm_info("CCP_WR_DATA_PKT", $psprintf("%s",m_ccp_wr_data_pkt.sprint_pkt()),UVM_MEDIUM)

    end else if(!isHit && isFillReqd ) begin
        //Fill
        if(isFillCtrlRcvd) begin
            `uvm_info("CCP_FILL_CTRL_PKT", $psprintf("%s",m_ccp_fill_ctrl_pkt.sprint_pkt()),UVM_MEDIUM)
        end
        if(isFillDataRcvd) begin
            `uvm_info("CCP_FILL_DATA_PKT", $psprintf("%s",m_ccp_fill_data_pkt.sprint_pkt()),UVM_MEDIUM)
        end

    end

endfunction

function int onehot_to_binay(bit [N_WAY-1:0] in_word);
    int position;
    
    position = -1;
    for(int i=0; i<$size(in_word); i++) begin
        if(in_word[i] == 1) begin
            position = i;
            break;
        end
    end

    return position;

endfunction

endclass
