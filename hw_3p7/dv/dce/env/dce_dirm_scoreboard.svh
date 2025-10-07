//////////////////////////////////////////////////////////////
//Directory Manager Scoreboard
//////////////////////////////////////////////////////////////

class dce_dirm_scoreboard extends uvm_scoreboard;

     //////////////////////////////////////////////////////////////
     //Data Members
     //////////////////////////////////////////////////////////////
     //Debug flags
     bit m_scb_db;

     //handle for all requests/responses
    dce_dirm_req_item  m_req_pkt;
    dce_dirm_rsp_item  m_rsp_pkt;
    dirlookup_seq_item     m_misc_pkt;

    uvm_event e_per_cycle;
 
    //Handle for Directory Manager;
    dce_directory_mgr m_dirm_mgr;

<% if(obj.COVER_ON) { %>
    //Coverage collecter handle
    dce_coverage m_cov;
<% } %>

    //Directory transactions in flight
    //Associative array with att_id has index
    dce_dirm_txn m_dirm_txnq[bit [10:0]];

    //ATT_ID map order per cacheline. ATT must process cachelines in the order it received
    //on dir_rsp interface. this DS is to make sure that order is maintained
    bit [10:0] m_attid_map_per_addr[bit [47:0]][$];

<% if(numTagSf() > 0) { %>
    //D.S used to analyze Stimilus 
    bit [47:0] m_cachelines_alloc_in_sf[addrMgrConst::NUM_TAG_SF][$];
<% } else { %>
    //D.S used to analyze Stimilus 
    bit [47:0] m_cachelines_alloc_in_sf[1][$];
<% } %>

    //Maintence Recall pkt
    //<%=obj.BlockId + '_con'%>::dce_maint_pkt_t maint_pkt;
    
    //Recall counters per Tag SF
    bit recall_init_val_latched, reset_observed;
    int recall_randomizer[$];

    //events
    event e_coh_req, e_upd_req, e_wake_req, e_recall_req;
    event e_maint_req, e_commit_req, e_dirm_rsp;

     `uvm_component_utils(dce_dirm_scoreboard) 

     uvm_analysis_imp_dirm_req_chnl       #(dce_dirm_req_item, dce_dirm_scoreboard) dirm_req_port;
     uvm_analysis_imp_dirm_rsp_chnl       #(dce_dirm_rsp_item, dce_dirm_scoreboard) dirm_rsp_port;

<% if(obj.INHOUSE_APB_VIP) { %>
     uvm_analysis_imp_apb_req_chnl        #(apb_pkt_t, dce_dirm_scoreboard) apb_req_port;
     uvm_analysis_imp_apb_rsp_chnl        #(apb_pkt_t, dce_dirm_scoreboard) apb_rsp_port;
<% } %>

     uvm_analysis_imp_dirm_hw_status_chnl #(dce_dirm_hw_status_seq_item,
     dce_dirm_scoreboard) dirm_hw_status_port;
    
     //////////////////////////////////////////////////////////////
     //Methods
     //////////////////////////////////////////////////////////////
     extern function new(string name = "dce_dirm_scoreboard", uvm_component parent = null);
     extern function void build_phase(uvm_phase phase);
     extern function void report_phase(uvm_phase phase);
     extern task run_phase(uvm_phase phase);

     //Analysis Port Methods
     extern function void write_dirm_req_chnl(dce_dirm_req_item m_seq_item);
     extern function void write_dirm_rsp_chnl(dce_dirm_rsp_item m_seq_item);

<% if(obj.INHOUSE_APB_VIP) { %>
     extern function void write_apb_req_chnl(apb_pkt_t m_seq_item);
     extern function void write_apb_rsp_chnl(apb_pkt_t m_seq_item);
<% } %>

     extern function void write_dirm_hw_status_chnl(dce_dirm_hw_status_seq_item m_seq_item);

     //Tasks that process & compare req/rsp packets
     extern task process_coh_req(uvm_phase phase);
     extern task process_update_req();
     extern task process_wake_req();
     extern task process_recall_req(uvm_phase phase);
     extern task process_maint_recall_req(uvm_phase phase);
     extern task process_commit_req(uvm_phase phase);
     extern task process_dirm_rsp(uvm_phase phase);
     extern task recall_way_randomizer();

     //Methods for Directory mgr lookups & commits
     extern function void dirm_lookups(
         bit [10:0] lookup_attid,
         const ref int m_sf_spec_randomizer[$]);
     extern function void dirm_commits(
         uvm_phase phase,
         bit [10:0] commit_attid,
         bit pending_txn_in_att);

     extern function void record_maint_recall_req(uvm_phase phase,
         bit [47:0]   maint_addr);

     //attid2cacheline map
     extern function void alloc_attid2cacheline_map(
         bit [10:0] m_attid,
         bit [47:0] m_addr);

     extern function bit dealloc_attid2cacheline_map(
         bit [10:0] m_attid,
         bit [47:0] m_addr);

     //helper methods
     extern function int active_att_snapshot();
     extern function bit maint_req_progress_in_att();
     extern function bit compare_lookup_sf_info(const ref dce_dirm_rsp_item m_seq_item);
     extern function bit compare_commit_sf_info(const ref dce_dirm_req_item m_seq_item);

     extern function bit compare_way_selected(
                             const ref int exp_write_en[$],
                             const ref int exp_write_way[$],
                             const ref int act_write_en[$],
                             const ref int act_write_way[$]);
   
     //Hw Status update methods
     extern function void dirm_reset_asserted();
     extern function bit uncorr_err_observed(output bit [31:0] sf_disable);

     //////////////////////////////////////////////////////////////
     //Coverage collector
     //////////////////////////////////////////////////////////////
`ifdef COVER_ON
     bit [47:0] coh_addr_list[$];
     bit [47:0] recall_addr_list[$];
     extern function void collect_fun_coverage(bit [47:0] m_addr);
     extern function void collect_coh_addr_sec(bit [47:0] m_addr);
     extern function void collect_recall_addr_sec(bit [47:0] m_addr);
`endif
     extern function void analyze_dce_traffic(const ref dce_dirm_txn m_dirm_txn);
     extern function void print_cacheline_allocations();
     extern function int addr_cmp_excl_sec_bit(bit [47:0] m_addr, 
         const ref bit [47:0] addr_list[$]);

endclass: dce_dirm_scoreboard

function dce_dirm_scoreboard::new(string name = "dce_dirm_scoreboard", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

function void dce_dirm_scoreboard::build_phase(uvm_phase phase);
    
    `uvm_info("DIRM SCB", "Entered dce_dirm_scoreboard build_phase", UVM_MEDIUM)
    super.build_phase(phase);

    dirm_req_port       = new("dirm_req_port", this);
    dirm_rsp_port       = new("dirm_rsp_port", this);

<% if(obj.INHOUSE_APB_VIP) { %>
    apb_req_port        = new("apb_req_port", this);
    apb_rsp_port        = new("apb_rsp_port", this);
<% } %>
    dirm_hw_status_port = new("dirm_hw_status_port", this);

    m_dirm_mgr.assign_dbg_verbosity(m_scb_db);

    //construct uvm_event that triggers every clock cycle neg edge
    e_per_cycle = new("e_per_cycle");

endfunction: build_phase


//Run_phase method
//each task waits until respective event kicks off and 
//then process the packets accordingly.
task dce_dirm_scoreboard::run_phase(uvm_phase phase);
    
    `uvm_info("DIRM SCB", "Entered dce_dirm_scoreboard run_phase", UVM_NONE)

    fork
        begin
            forever begin
                process_coh_req(phase);
            end
        end
        begin
            forever begin
                process_update_req();
            end
        end
        begin
            forever begin
                process_wake_req();
            end
        end
        begin
            forever begin
                process_recall_req(phase);
            end
        end
        begin
            forever begin
                process_maint_recall_req(phase);
            end
        end
        begin
            forever begin
                process_commit_req(phase);
            end
        end
        begin
            forever begin
                process_dirm_rsp(phase);
            end
        end
    join_none
endtask: run_phase

//write method for directory requests
function void dce_dirm_scoreboard::write_dirm_req_chnl(dce_dirm_req_item m_seq_item);
    dce_dirm_req_item tmp_seq_item;

    //if(m_scb_db)
    //    `uvm_info("DIRM SCB", $psprintf("dirm req pkt {ACT}: %s", m_seq_item.convert2string()), UVM_HIGH)

    tmp_seq_item = dce_dirm_req_item::type_id::create("dirm_req_item");
    tmp_seq_item.copy(m_seq_item);
    //if(m_scb_db)
    //    `uvm_info("DIRM SCB", $psprintf("dirm req pkt {COPY}: %s", tmp_seq_item.convert2string()), UVM_HIGH)

    m_req_pkt = tmp_seq_item;
 
    if(tmp_seq_item.m_req_type == COH_REQ) begin
        if(m_scb_db)
            `uvm_info("DIRM SCB", "Received coherent request pkt", UVM_HIGH)
        ->e_coh_req;

    end else if(tmp_seq_item.m_req_type == UPD_REQ) begin
        if(m_scb_db)
            `uvm_info("DIRM SCB", "Received update request pkt", UVM_HIGH)
        ->e_upd_req;

    end else if(tmp_seq_item.m_req_type == CMT_REQ) begin
        if(m_scb_db)
            `uvm_info("DIRM SCB", "Received commit request pkt", UVM_HIGH)
        ->e_commit_req;

    end else if(tmp_seq_item.m_req_type == WKE_REQ) begin
        if(m_scb_db)
            `uvm_info("DIRM SCB", "Received Wake request pkt", UVM_HIGH)
        ->e_wake_req;
   
    end else if((tmp_seq_item.m_req_type == MNT_HIT_REQ) || (tmp_seq_item.m_req_type == MNT_MISS_REQ)) begin
        if(m_scb_db)
            `uvm_info("DIRM SCB", "Received maintenance request pkt", UVM_HIGH)
        ->e_maint_req;
    
    end else if(tmp_seq_item.m_req_type == REC_REQ) begin
        if(m_scb_db)
            `uvm_info("DIRM SCB", "Received Recall request pkt", UVM_HIGH)
        ->e_recall_req;
    end
endfunction: write_dirm_req_chnl

//write method for directory responses
function void dce_dirm_scoreboard::write_dirm_rsp_chnl(dce_dirm_rsp_item m_seq_item);
    dce_dirm_rsp_item tmp_seq_itemp;

    //if(m_scb_db)
    //    `uvm_info("DIRM SCB", $psprintf("dirm rsp pkt {ACT}: %s", m_seq_item.convert2string()), UVM_MEDIUM)

    tmp_seq_itemp = dce_dirm_rsp_item::type_id::create("dirm_rsp_item");
    tmp_seq_itemp.copy(m_seq_item);

    //if(m_scb_db)
    //    `uvm_info("DIRM SCB", $psprintf("dirm rsp pkt {COPY}: %s", tmp_seq_itemp.convert2string()), UVM_MEDIUM)

    //Trigger the event
    m_rsp_pkt = tmp_seq_itemp;
    ->e_dirm_rsp;
    
endfunction: write_dirm_rsp_chnl

<% if(obj.INHOUSE_APB_VIP) { %>
//write method for SF reg pkts
function void dce_dirm_scoreboard::write_apb_req_chnl(apb_pkt_t m_seq_item);
    if(m_scb_db)
        `uvm_info("DIRM MGR", m_seq_item.sprint_pkt(), UVM_HIGH)

    //hard coded; FIXME TODO: mv to using dce_reg.svh
    //DIRUSFMLR0
<% if (obj.testBench == "psys") { %>
    if(m_seq_item.paddr[32:12] == ('h80 + 'h<%=obj.Id%>)) begin
<% } %>
      if((m_seq_item.paddr[11:0] == 'h88) && (m_seq_item.pwrite == apb_pwrite_t'(APB_WR))) begin
          if(m_dirm_mgr.maint_active_deasserted()) begin
              maint_pkt.maint_entry  = m_seq_item.pwdata[19:0];
              maint_pkt.maint_way    = m_seq_item.pwdata[25:20];
              maint_pkt.maint_word   = m_seq_item.pwdata[31:26];
          end else begin
              `uvm_info("DIRM SCB", "Older value of DIRUSFMLR0 is used", UVM_MEDIUM)
          end
      end

      //DIRUSFMLR1
      if((m_seq_item.paddr[11:0] == 'h8C) && (m_seq_item.pwrite == apb_pwrite_t'(APB_WR))) begin
          if(m_dirm_mgr.maint_active_deasserted()) begin
              maint_pkt.maint_addr   = m_seq_item.pwdata[11:0];
          end else begin
              `uvm_info("DIRM SCB", "Older value of DIRUSFMLR1 is used", UVM_MEDIUM)
          end
      end

      //DIRUSFMCR
      if((m_seq_item.paddr[11:0] == 'h80) && (m_seq_item.pwrite == apb_pwrite_t'(APB_WR))) begin
          if(m_dirm_mgr.maint_active_deasserted()) begin
              if(!$cast(maint_pkt.maint_opcode, m_seq_item.pwdata[3:0])) 
                  `uvm_fatal("DIRM SCB", "Cast failed")

              maint_pkt.sf_id        = m_seq_item.pwdata[20:16];
              maint_pkt.security_bit = m_seq_item.pwdata[21];

              //Call to directory manager
              if((maint_pkt.maint_opcode == <%=obj.BlockId + '_con'%>::RECALL_ALL)           ||
                 (maint_pkt.maint_opcode == <%=obj.BlockId + '_con'%>::RECALL_VICTIM_BUFFER) ||
                 (maint_pkt.maint_opcode == <%=obj.BlockId + '_con'%>::RECALL_INDEX_WAY)     ||
                 (maint_pkt.maint_opcode == <%=obj.BlockId + '_con'%>::RECALL_ADDRESS)       ||
                 (maint_pkt.maint_opcode == <%=obj.BlockId + '_con'%>::MEM_INIT)) begin

                  m_dirm_mgr.csr_maint_req(maint_pkt);
              end
          end else begin
              `uvm_info("DIRM SCB", "Older value of DIRUSFMCR is used", UVM_MEDIUM)
          end
      end
<% if (obj.testBench == "psys") { %>
    end
<% } %>
endfunction: write_apb_req_chnl

//write method for SF reg pkts
function void dce_dirm_scoreboard::write_apb_rsp_chnl(apb_pkt_t m_seq_item);

endfunction: write_apb_rsp_chnl
<% } %>

//write method for Hw status packets
function void dce_dirm_scoreboard::write_dirm_hw_status_chnl(dce_dirm_hw_status_seq_item m_seq_item);
    dce_dirm_hw_status_seq_item tmp_seq_item;

    //if(m_scb_db)
    //    `uvm_info("DIRM SCB", $psprintf("hw status pkt {ACT}: %s", m_seq_item.convert2string()), UVM_MEDIUM)

    tmp_seq_item = dce_dirm_hw_status_seq_item::type_id::create("dirm_hw_status_seq_item");
    tmp_seq_item.copy(m_seq_item);

    //if(m_scb_db)
    //    `uvm_info("DIRM SCB", $psprintf("dirm status pkt {COPY}: %s", tmp_seq_item.convert2string()), UVM_MEDIUM)

    if(tmp_seq_item.m_dirm_status == DIRM_RESET) begin
        `uvm_info("DIRM SCB", "reset asserted", UVM_MEDIUM)
        dirm_reset_asserted();
        m_dirm_mgr.dirm_sfen_reg_status(32'b0);
    end else begin
        //if(m_scb_db)
        //    `uvm_info("DIRM SCB", "counter triggered", UVM_MEDIUM)

        //Forwarded 
        m_dirm_mgr.dirm_sfen_reg_status(tmp_seq_item.DIRUSFER_SfEn);

        if((!recall_init_val_latched)) begin
            recall_init_val_latched = 1'b1;
        end
        reset_observed = 1'b1;
    end

    //Trigger the clock event
    e_per_cycle.trigger();
endfunction: write_dirm_hw_status_chnl

//Method called on reset detection
function void dce_dirm_scoreboard::dirm_reset_asserted();
    recall_init_val_latched = 1'b0;
endfunction:  dirm_reset_asserted

//Process Coherent requests.
task dce_dirm_scoreboard::process_coh_req(uvm_phase phase);
    dce_dirm_txn m_txn;

    @(e_coh_req);
    e_per_cycle.wait_ptrigger();

    if(m_scb_db)
        `uvm_info("DIRM SCB", "process_coh_req() called", UVM_MEDIUM)

    //Check{} if multiple Active Att transactions are found
    if(m_dirm_txnq.exists(m_req_pkt.m_attid)) begin
        `uvm_info("DIRM SCB", $psprintf("pkt that already exists in att %s", m_dirm_txnq[m_req_pkt.m_attid].convert2string()), UVM_NONE)
        `uvm_info("DIRM SCB", $psprintf("pkt received {ACT}: %s", m_req_pkt.convert2string()), UVM_NONE)
        `uvm_error("DIRM SCB", "Multiple requests detected with same att_id")
    end

    m_txn = dce_dirm_txn::type_id::create($sformatf("dce_dirm_txn[%0d]", m_req_pkt.m_attid));
    //Update cohrent request
    m_txn.assign_coh_req_info(m_req_pkt.m_time, m_req_pkt.m_attid, m_req_pkt.m_addr, m_req_pkt.m_aiuid, m_req_pkt.m_msg_type);

    //Add the pkt to attlist
    if(m_scb_db) begin
        `uvm_info("DIRM SCB", $psprintf("adding attid:%0d to attlist", m_req_pkt.m_attid), UVM_HIGH)
        //active_att_snapshot();
    end
    m_dirm_txnq[m_req_pkt.m_attid] = m_txn;

    if(m_scb_db) begin
        `uvm_info("DIRM SCB", $psprintf("coh req: %s", m_dirm_txnq[m_req_pkt.m_attid].convert2string()), UVM_MEDIUM)
    end
    //Raise one Objection for every coherent request, recall req, maintenance req
    //Drops one Objection for every commit request
    phase.raise_objection(this, "Raise objection");
    
endtask: process_coh_req

//Process Update requests.
task dce_dirm_scoreboard::process_update_req();
    time tmp_time;
    <%=obj.BlockId + '_con'%>::cacheAddress_t   tmp_addr;
    <%=obj.BlockId + '_con'%>::AIUID_t          tmp_aiuid;
    <%=obj.BlockId + '_con'%>::MsgType_t        tmp_msg_type;
    
    @(e_upd_req);
    e_per_cycle.wait_ptrigger();

    if(m_scb_db)
        `uvm_info("DIRM SCB", "process_update_req() called", UVM_MEDIUM)

    tmp_time     = m_req_pkt.m_time;
    tmp_addr     = m_req_pkt.m_addr;
    tmp_aiuid    = m_req_pkt.m_aiuid;
    tmp_msg_type = m_req_pkt.m_addr;
    m_dirm_mgr.update_request(tmp_addr, tmp_aiuid, tmp_msg_type);
    
    //Wait for 2-cycles before updating the directory.
    //Do not block the event-q
    //Below code is discarded becuse now we are monitoring 
    //P2 update signals
    //fork
    //    begin
    //        repeat(2)
    //            e_per_cycle.wait_trigger();

    //        //Call to directory manager to forward update req
    //        m_dirm_mgr.update_request(tmp_addr, tmp_aiuid, tmp_msg_type);
    //    end
    //join_none

endtask: process_update_req

//Process Wake Requests
task dce_dirm_scoreboard::process_wake_req();
    <%=obj.BlockId + '_con'%>::cacheAddress_t  tmp_addr;

    @(e_wake_req);
    e_per_cycle.wait_ptrigger();

    if(m_scb_db)
        `uvm_info("DIRM SCB", "process_wake_req() called", UVM_MEDIUM)

    //Check{} if this request already exists in active attq
    if(!m_dirm_txnq.exists(m_req_pkt.m_attid)) begin
        `uvm_info("DIRM SCB", $psprintf("wake req {ACT}: %s", m_req_pkt.convert2string()), UVM_NONE)
        void'(active_att_snapshot());
        `uvm_error("DRM SCB", "Wake req received missing in active dirm txn list")
    end

    //Check{} if wake was expected
    if(!(m_dirm_txnq[m_req_pkt.m_attid].wake_req_expected)) begin
        `uvm_info("DIRM SCB", $psprintf("{EXP}: %s", m_dirm_txnq[m_req_pkt.m_attid].convert2string()), UVM_NONE)
        `uvm_info("DIRM SCB", $psprintf("{ACT}: %s", m_req_pkt.convert2string()), UVM_NONE)
        `uvm_error("DRM SCB", "wake req was not expected {EXP}")
    end

    m_dirm_txnq[m_req_pkt.m_attid].assign_wake_req_info(m_req_pkt.m_time);

    //Check{} if order of wake-ups are correct.
    //#Check.DCE.ATTSWakingUpOrderIsCorrect
    tmp_addr = m_dirm_mgr.offset_align_cacheline(m_req_pkt.m_addr);
    if(m_attid_map_per_addr.exists(tmp_addr)) begin

        if(m_attid_map_per_addr[tmp_addr][0] == m_req_pkt.m_attid) begin
            `uvm_info("DIRM MGR", "wake requests observed in order", UVM_HIGH)
    
        end else begin 
            `uvm_info("DIRM MGR", $psprintf("addr:0x%0h {ACT, EXP} attid: {%0d, %0d}",
                m_req_pkt.m_addr, m_req_pkt.m_attid, m_attid_map_per_addr[tmp_addr][0]),
                UVM_NONE)
            `uvm_error("DIRM MGR", "Order of wake req from ATT are wrong") 
        end
    end else begin
        `uvm_info("DIRM SCB", $psprintf("{ACT} wake_req: %s", m_req_pkt.convert2string()), UVM_NONE)
        `uvm_error("DIRM SCB", "Unexpected wake req from unallocated attid")
    end

    if(m_scb_db) begin
        `uvm_info("DIRM SCB", $psprintf("wake req: %s", m_dirm_txnq[m_req_pkt.m_attid].convert2string()), UVM_MEDIUM)
    end

endtask: process_wake_req

//Process recall requests
task dce_dirm_scoreboard::process_recall_req(uvm_phase phase);
    dce_dirm_txn                            m_txn;
    <%=obj.BlockId + '_con'%>::cacheAddress_t            recall_addr;
    <%=obj.BlockId + '_con'%>::cacheAddress_t            new_addr;
    bit[<%=obj.BlockId + '_con'%>::DCE_nATTEntries-1:0]  m_attid;
    <%=obj.BlockId + '_con'%>::eMsgSNP                   msg;
    bit m_found;
    int status;

    @(e_recall_req);
    e_per_cycle.wait_ptrigger();

    if(m_scb_db)
        `uvm_info("DIRM SCB", "process_recall_req() called", UVM_MEDIUM)

    //Check{}: Recall message type is SnpREcall
    if(m_req_pkt.m_msg_type != <%=obj.BlockId + '_con'%>::eSnpRecall) begin

        if(!$cast(msg, m_req_pkt.m_msg_type))
            `uvm_fatal("DIRM SCB", "Unable to cast")

        `uvm_info("DIRM SCB", $psprintf("Recall request received: %s", m_req_pkt.convert2string()), UVM_NONE)
        `uvm_error("DIRM SCB", $psprintf("For recall Msg type mismatch  type {EXP}: eSnpRecall {ACT}: %s",
        msg.name()))
    end

    m_txn = dce_dirm_txn::type_id::create($sformatf("dce_dirm_txn[%0d]", m_req_pkt.m_attid));
    m_txn.assign_recall_req_info(m_req_pkt.m_time, m_req_pkt.m_attid, m_req_pkt.m_addr, m_req_pkt.m_msg_type);

    //Since Recall activate phase and direcory lookup for coherent transaction that initiated recall 
    //happen on same cycle in RTL, we wait until directory allocation is completed  to predict which
    //is being recalled. get_recall_cacheline is a blocking task that is released after allocation 
    //happens. There is no delay interms simulatione ime, It's just SW event blocking machanisim
    //for one process to complete before other process kicks off.

    //Get Expected Recall request
    //Check{}: returns 0 if unexpected recall request
    m_dirm_mgr.get_recall_cacheline(
        recall_addr,
        m_txn.m_olv,
        m_txn.m_slv,
        status);

    if(!status) begin
        `uvm_info("DIRM SCB", $psprintf("Recall pkt {ACT}: %s", m_req_pkt.convert2string()), UVM_NONE)
        m_dirm_mgr.print_all_ways(m_req_pkt.m_addr);
        `uvm_error("DIRM SCB", "Unexpected Recall request observed")
    end

    //Check{}: recall address observed matches with prediction
    if(recall_addr == m_req_pkt.m_addr) begin
        `uvm_info("DIRM SCB", "{ACT} recall address matches with {EXP}", UVM_MEDIUM)
    end else begin
        `uvm_info("DIRM SCB", $psprintf("Recall pkt {EXP}:0x%0h", recall_addr), UVM_NONE)
        `uvm_info("DIRM SCB", $psprintf("Recall pkt {ACT}: %s", m_req_pkt.convert2string()), UVM_NONE)
        `uvm_error("DIRM SCB", "{ACT} recall address does not match with {EXP}")
    end

    //Check{}: update the att_txn that caused the recall
    if(!m_dirm_txnq[m_rsp_pkt.m_attid].recall_req_expected) begin
        `uvm_info("DIRM SCB", $psprintf("Recall request shoud have been expected: %s",
        m_dirm_txnq[m_rsp_pkt.m_attid].convert2string()), UVM_NONE)
        `uvm_error("DIRM SCB", "Tb_Error: Recall expected bit not set")
    end
    if(m_dirm_txnq[m_rsp_pkt.m_attid].recall_req_observed) begin
        `uvm_info("DIRM SCB", $psprintf("Recall request observed already set: %s",
        m_dirm_txnq[m_rsp_pkt.m_attid].convert2string()), UVM_NONE)
        `uvm_error("DIRM SCB", "Tb_Error: Recall observed bit already set")
    end
    m_dirm_txnq[m_rsp_pkt.m_attid].update_recall_observed(m_req_pkt.m_time,
        m_req_pkt.m_attid, m_req_pkt.m_addr);

    //Add the pkt to attlist
    m_txn.att_recall_txn = 1'b1;
    m_dirm_txnq[m_req_pkt.m_attid] = m_txn;

    //Raise one Objection for every coherent request, recall req, maintenance req
    //Drops one Objection for every commit request
    phase.raise_objection(this, "Raise objection");

    if(m_scb_db)
        `uvm_info("DIRM MGR", $psprintf("recall att txn:%s",
            m_dirm_txnq[m_req_pkt.m_attid].convert2string()), UVM_MEDIUM)
endtask: process_recall_req

//Process maintence recall requests
//anippuleti (04/21/16) Maintenence operations logic is modified. With latest
//architecture Maint by addr, Maint by index/way follow different data paths
//Initiate Maintenance recall by address on specified cacheline.. 
task dce_dirm_scoreboard::process_maint_recall_req(uvm_phase phase);
    dce_dirm_txn                   m_txn;
    <%=obj.BlockId + '_con'%>::cacheAddress_t   maint_addr;
    bit maint_req_dropped;
    int match_attid;

    @(e_maint_req);
    e_per_cycle.wait_ptrigger();

    if(m_scb_db)
        `uvm_info("DIRM SCB", "process_maint_recall_req() called", UVM_MEDIUM)

    if(m_dirm_mgr.get_maint_opcode() == <%=obj.BlockId + '_con'%>::RECALL_ADDRESS) begin

        if(m_req_pkt.m_req_type != MNT_MISS_REQ) begin
            if(m_dirm_mgr.get_maint_recall_addr_prg(maint_addr)) begin
                record_maint_recall_req(phase, maint_addr);
            end
        end
    end else if((m_dirm_mgr.get_maint_opcode() == <%=obj.BlockId + '_con'%>::RECALL_ALL)           ||
                (m_dirm_mgr.get_maint_opcode() == <%=obj.BlockId + '_con'%>::RECALL_VICTIM_BUFFER) ||
                (m_dirm_mgr.get_maint_opcode() == <%=obj.BlockId + '_con'%>::RECALL_INDEX_WAY))    begin

        //It's either real miss where cacheline associated to index/way is neither present in tag filter
        //nor in ATT or associated index/way is pending in ATT. In latter senario we hal the CSR scheduler
        //and keep retrying untill the commit happens to tag filter and address is known. MaintActive bit
        //is asserted high and new requests are ignored.

        //A Uncorrectible error can occur on P2 for maint index/way lookup. When this happens request will
        //be dropped by the model. This information must be forwarded to directory mgr model so that pointers
        //are incremented

        //Check{} Maintence recall programmed is a miss..
        if(m_req_pkt.m_req_type == MNT_MISS_REQ) begin
            if((m_dirm_mgr.get_maint_recall_cacheline(maint_addr, m_req_pkt.uncorrectable_error))) begin
                `uvm_info("DIRM SCB", $psprintf("Maint req is hit within model {EXP}: 0x%0h", 
                    maint_addr), UVM_NONE)
                `uvm_error("DIRM SCB", "Maintenance request dropped which turned out to be a hit in model")
            end
        end else begin

            if(m_req_pkt.uncorrectable_error) 
                `uvm_error("DTRM SCB", "Maint req cannot proceed if an error is detected")

            if(m_dirm_mgr.get_maint_recall_cacheline(maint_addr, m_req_pkt.uncorrectable_error)) begin            
                record_maint_recall_req(phase, maint_addr);
            end else begin
                `uvm_info("DIRM SCB", $psprintf("Maint recall {ACT}: %s", m_req_pkt.convert2string()), UVM_NONE)
                `uvm_error("DIRM SCB", "Unexpected maintanence recall req, DIRUSFMCR reg was not programmed")
            end 
        end
    end
`ifdef COVER_ON
            collect_recall_addr_sec(maint_addr);
`endif
endtask: process_maint_recall_req

function void dce_dirm_scoreboard::record_maint_recall_req(uvm_phase phase, 
    <%=obj.BlockId + '_con'%>::cacheAddress_t   maint_addr);

    dce_dirm_txn                   m_txn;

    //Check{} if Maintence recall is happening on expected recall address expected.
    if(maint_addr == m_req_pkt.m_addr) begin
        if(m_scb_db)
            `uvm_info("DIRM SCB", $psprintf("Maintenance recall: %s", m_req_pkt.convert2string()), UVM_MEDIUM)
        `uvm_info("DIRM SCB", "{ACT} maintenance recall cacheline matches with {EXP}", UVM_MEDIUM)

    end else begin
        m_dirm_mgr.print_all_ways(maint_addr);
        `uvm_info("DIRM SCB", $psprintf("Maintenance recall{EXP}: 0x%0h", maint_addr), UVM_MEDIUM)
        `uvm_info("DIRM SCB", $psprintf("Maintenance recall{ACT}: %s", m_req_pkt.convert2string()), UVM_MEDIUM)
        `uvm_error("DIRM SCB", "Maintenance recall addr {ACT} does not match with {EXP}")
    end

    m_txn = dce_dirm_txn::type_id::create($sformatf("dce_dirm_txn[%0d]", m_req_pkt.m_attid));
    m_txn.assign_maint_req_info(m_req_pkt.m_time, m_req_pkt.m_attid, m_req_pkt.m_addr, m_req_pkt.maint_req_opcode);

    //Add the pkt to attlist
    m_dirm_txnq[m_req_pkt.m_attid] = m_txn;
    
    //Raise one Objection for every maint request
    //Drops one Objection for every commit request
    phase.raise_objection(this, "Raise objection");

endfunction: record_maint_recall_req

//Process commit requests
//04/16/16 Re-factored the commit & dirm_rsp logic. Now in process_commit_req()
//only comparisions happen and actual commit to dirm model happens in dirm commit rsp.
//This change is to accurately mirrior RTL. 
task dce_dirm_scoreboard::process_commit_req(uvm_phase phase);
    bit [<%=obj.BlockId + '_con'%>::DCE_nATTEntries-1:0] match_attid;
    bit status;
    <%=obj.BlockId + '_con'%>::cacheAddress_t   tmp_addr;

    @(e_commit_req);
    e_per_cycle.wait_ptrigger();

    if(m_scb_db)
        `uvm_info("DIRM SCB", "process_commit_req() called", UVM_MEDIUM)

    //Check{} commit req is a valid request
    if(m_dirm_txnq.exists(m_req_pkt.m_attid)) begin

        m_dirm_txnq[m_req_pkt.m_attid].assign_commit_req_info(m_req_pkt.m_time, m_req_pkt.m_ocv, m_req_pkt.m_scv,
            m_req_pkt.m_dir_commit_dont_write, m_req_pkt.m_sf_spec_write_en, m_req_pkt.m_sf_spec_way);

        //Check{} if wake request was expected and received
        if(m_dirm_txnq[m_req_pkt.m_attid].wake_req_expected) begin
            if(m_dirm_txnq[m_req_pkt.m_attid].wake_req_observed) begin
                `uvm_info("DIRM SCB", $psprintf("Wake req observed: %s",
                m_dirm_txnq[m_req_pkt.m_attid].convert2string()), UVM_HIGH)
            end else begin
                `uvm_info("DIRM SCB", $psprintf("{EXP} wake req but not observed: %s",
                m_dirm_txnq[m_req_pkt.m_attid].convert2string()), UVM_NONE)
                `uvm_error("DIRM SCB", "{EXP} wake request not observed before commit happened for current request")
            end
        end

        //Check{} if recall request was expected and received
        if(m_dirm_txnq[m_req_pkt.m_attid].recall_req_expected) begin
            if(m_dirm_txnq[m_req_pkt.m_attid].recall_req_observed) begin
                `uvm_info("DIRM SCB", $psprintf("Recall req observed: %s",
                m_dirm_txnq[m_req_pkt.m_attid].convert2string()), UVM_MEDIUM)
            end else begin
                `uvm_info("DIRM SCB", $psprintf("{EXP} recall req but not observed: %s",
                m_dirm_txnq[m_req_pkt.m_attid].convert2string()), UVM_NONE)

                `uvm_info("DIRM SCB", $psprintf("{EXP} recall req: %s",
                m_dirm_txnq[m_dirm_txnq[m_req_pkt.m_attid].recall_req_attid].convert2string()), UVM_NONE)
                `uvm_error("DIRM SCB", "{EXP} Recall request not observed before commit happened for current request")
            end
        end

        //Check if Commit req aiuid, cacheline are correct.
        if(!((m_dirm_txnq[m_req_pkt.m_attid].cacheline[DIRM_ADDR:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline] ==
        m_req_pkt.m_addr[DIRM_ADDR:<%=obj.BlockId + '_con'%>::SYS_wSysCacheline]) &&
        (m_dirm_txnq[m_req_pkt.m_attid].req_aiuid == m_req_pkt.m_aiuid))) begin
            
            `uvm_info("DIRM SCB", $psprintf("{EXP} commit: %s", m_dirm_txnq[m_req_pkt.m_attid].convert2string()), UVM_NONE)
            `uvm_info("DIRM SCB", $psprintf("{ACT} commit: %s", m_req_pkt.convert2string()), UVM_NONE)
            `uvm_error("DIRM SCB", "Commit req {ACT} cacheline/req_aiuid do not match with {EXP}")
        end

        //Check{} if Snoop Filter way commit is correct.
        status = compare_way_selected(
                     m_dirm_txnq[m_req_pkt.m_attid].sf_write_en,
                     m_dirm_txnq[m_req_pkt.m_attid].sf_write_way,
                     m_req_pkt.m_sf_spec_write_en,
                     m_req_pkt.m_sf_spec_way);


        if(!status) begin
            `uvm_info("DIRM SCB", $psprintf("{EXP} commit: %s", m_dirm_txnq[m_req_pkt.m_attid].convert2string()), UVM_NONE)
            `uvm_info("DIRM SCB", $psprintf("{ACT} commit: %s", m_req_pkt.convert2string()), UVM_NONE)
            `uvm_error("DIRM SCB", "Commit req {ACT} sf_write/way does not match with {EXP}")
        end

    end else begin
        `uvm_info("DIRM SCB", $psprintf("Commit req {ACT}: %s", m_req_pkt.convert2string()), UVM_NONE)
        void'(active_att_snapshot());
        `uvm_error("DIRM SCB", "Unexpect directory commit observed")
    end

endtask: process_commit_req

//Method returns 1'b1 if an uncorrectable error is observed on on lookup
//Also converts the error_signal value per SF to DIURUSFR format to be 
//compatable 
function bit dce_dirm_scoreboard::uncorr_err_observed(output bit [31:0] sf_disable);
    bit status;

    foreach(m_rsp_pkt.m_sf_uncor_error_detect[ridx]) begin
        if(m_rsp_pkt.m_sf_uncor_error_detect[ridx]) begin

            status = 1'b1;
            sf_disable[ridx] = 1'b0;

            if(m_scb_db)
                `uvm_info("DIRM SCB", $psprintf("Error observed on sfid:%0d", ridx), UVM_MEDIUM)
        end else begin
            sf_disable[ridx] = 1'b1;
        end
    end
    return(status);
endfunction: uncorr_err_observed

//Process Directory response pkts
task dce_dirm_scoreboard::process_dirm_rsp(uvm_phase phase);
    bit status;
    string msg;
    bit pending_txn_in_att;
    bit [31:0] sf_disable;
    bit skip_lookups;

    @(e_dirm_rsp);
    e_per_cycle.wait_ptrigger();

    if(m_scb_db)
        `uvm_info("DIRM SCB", "process_dirm_rsp() called", UVM_MEDIUM)

    //Call to forward uncorrectable error info to Dirm model.
    if(uncorr_err_observed(sf_disable)) begin
        //#Check.DCE.OnTagErrRespectiveSnoopFilterIsDisabled
        m_dirm_mgr.sf_disable_on_uncorr_err(sf_disable);
    end

    if(m_rsp_pkt.m_rsp_type == LKP_RSP || m_rsp_pkt.m_rsp_type == WKE_RSP) begin

        //Check{} if lookup request is from valid att-id
        if(m_dirm_txnq.exists(m_rsp_pkt.m_attid)) begin
            m_dirm_txnq[m_rsp_pkt.m_attid].coh_dir_rsp = 1'b1;

            if(m_scb_db) begin
                `uvm_info("DIRM SCB", $psprintf("Lookup request attid:%0d being processed",
                m_rsp_pkt.m_attid), UVM_MEDIUM)
            end

             skip_lookups = ((m_rsp_pkt.m_rsp_type == WKE_RSP) && (m_dirm_txnq[m_rsp_pkt.m_attid].att_recall_txn ||
                             (m_dirm_txnq[m_rsp_pkt.m_attid].maint_req && (m_dirm_mgr.get_maint_opcode() != <%=obj.BlockId + '_con'%>::RECALL_ADDRESS)))); 

            //skip lookups on Wakes for following txns
            //maint_req indx/way, maint recall_all, maint vctb & normal recall req
            if(!skip_lookups) 
                dirm_lookups(m_rsp_pkt.m_attid, m_rsp_pkt.m_sf_spec_randomizer);

            if(m_scb_db) begin
                `uvm_info("DIRM SCB", $psprintf("Lookup received:%s",
                    m_dirm_txnq[m_rsp_pkt.m_attid].convert2string()), UVM_MEDIUM)
            end

            //Check{} if OLV, SLV are correct
            //anippuleti (04/05/16) update: Note if SnpRecall goes to sleep
            //due to another pending SnpRecall then on WKE_RSP do not compare 
            //olv & slv vectors becuase ATT does not load the ne vectors, instead
            //it uses previous vectors. Ideally it would be better if dir_rsp is not
            //triggered
            if(!skip_lookups) begin
                if((m_dirm_txnq[m_rsp_pkt.m_attid].m_olv == m_rsp_pkt.m_olv) &&
                (m_dirm_txnq[m_rsp_pkt.m_attid].m_slv == m_rsp_pkt.m_slv)) begin

                    `uvm_info("DIRM SCB", "{ACT} olv & slv match with {EXP}", UVM_MEDIUM)
                end else begin
                    `uvm_info("DIRM SCB", $psprintf("{EXP} lookup rsp: %s",
                        m_dirm_txnq[m_rsp_pkt.m_attid].convert2string()), UVM_NONE)
                    `uvm_info("DIRM SCB", $psprintf("{ACT} lookup rsp: %s", m_rsp_pkt.convert2string()), UVM_NONE)
                    `uvm_error("DIRM SCB", "{ACT} olv & slv does not match with {EXP}")
                end
            end else begin
                `uvm_info("DIRM MGR", "Excluding olv/slv compares for wake rsponses, recall req", UVM_MEDIUM)
            end

            //Check{} if Snoop Filter way lookup is correct.
            //Way allocatioin happens only on Coherent req & is reused for wake txns'
            //as of 03/24/16 way & write_en for wake req is no more valid
            if(m_rsp_pkt.m_rsp_type == WKE_RSP) begin
                status = 1'b1;
                `uvm_info("DIRM MGR", "Excluding way compares for wake rsp", UVM_MEDIUM)
            end else begin
                status = compare_way_selected(
                    m_dirm_txnq[m_rsp_pkt.m_attid].sf_write_en,
                    m_dirm_txnq[m_rsp_pkt.m_attid].sf_write_way,
                    m_rsp_pkt.m_sf_spec_write_en,
                    m_rsp_pkt.m_sf_spec_way);
            end

            if(!status) begin
                m_dirm_mgr.print_all_ways(m_dirm_txnq[m_rsp_pkt.m_attid].cacheline);
                `uvm_info("DIRM SCB", $psprintf("{EXP} lookup rsp: %s",
                    m_dirm_txnq[m_rsp_pkt.m_attid].convert2string()), UVM_NONE)
                `uvm_info("DIRM SCB", $psprintf("{ACT} lookup rsp: %s", m_rsp_pkt.convert2string()), UVM_NONE)
                `uvm_error("DIRM SCB", "Dirm lookup rsp {ACT} sf_write/way does not match with {EXP}")
            end

            //Associate attid to cacheline dependency
            alloc_attid2cacheline_map(m_rsp_pkt.m_attid, m_dirm_txnq[m_rsp_pkt.m_attid].cacheline);
            if($test$plusargs("analyze_dce_traffic")) begin
                analyze_dce_traffic(m_dirm_txnq[m_rsp_pkt.m_attid]);
            end

`ifdef COVER_ON
            collect_fun_coverage(m_dirm_txnq[m_rsp_pkt.m_attid].cacheline);
            collect_coh_addr_sec(m_dirm_txnq[m_rsp_pkt.m_attid].cacheline);
`endif
        end else begin
            void'(active_att_snapshot());
            `uvm_info("DIRM SCB", $psprintf("{ACT} dirm rsp: %s", m_rsp_pkt.convert2string()), UVM_NONE)
            `uvm_error("DIRM SCB", "Unexpected directory lookup observed")
        end
    end else if(m_rsp_pkt.m_rsp_type == CMT_RSP) begin

        if(m_dirm_txnq.exists(m_rsp_pkt.m_attid)) begin
            pending_txn_in_att = dealloc_attid2cacheline_map(m_rsp_pkt.m_attid, m_dirm_txnq[m_rsp_pkt.m_attid].cacheline);
            //Commit Data into memory
            dirm_commits(phase, m_rsp_pkt.m_attid, pending_txn_in_att);
        
        end else begin
            void'(active_att_snapshot());
            `uvm_info("DIRM SCB", $psprintf("{ACT} dirm rsp: %s", m_rsp_pkt.convert2string()), UVM_NONE)
            `uvm_error("DIRM SCB", "Unexpected directory lookup observed")
        end
    end

    //Update model on maint req pending in ATT
    m_dirm_mgr.update_maint_req_pend_in_att(maint_req_progress_in_att());
endtask: process_dirm_rsp

function void dce_dirm_scoreboard::dirm_lookups(
    bit [10:0] lookup_attid, 
    const ref int m_sf_spec_randomizer[$]);

    //Packet received is due to a normal recall
    if(m_dirm_txnq[lookup_attid].att_recall_txn) begin
        
        if(m_scb_db) 
            `uvm_info("DIRM SCB", "recall lookup rsp", UVM_MEDIUM)

    //Special case for Maint index/way, all, victim buffer since they are filter dependent
    end else if(m_dirm_txnq[lookup_attid].maint_req) begin
        
        m_dirm_mgr.maint_lookup_request(
            m_dirm_txnq[lookup_attid].cacheline, 
            m_sf_spec_randomizer,
            m_dirm_txnq[lookup_attid].m_olv,
            m_dirm_txnq[lookup_attid].m_slv,
            m_dirm_txnq[lookup_attid].sf_write_en,
            m_dirm_txnq[lookup_attid].sf_write_way);

    end else begin
        //Constrcut way/olv,slv info normal lookup

        m_dirm_mgr.lookup_request(
            m_dirm_txnq[lookup_attid].cacheline, 
            m_dirm_txnq[lookup_attid].req_aiuid,
            m_dirm_txnq[lookup_attid].msg_type,
            m_sf_spec_randomizer,
            m_dirm_txnq[lookup_attid].m_olv,
            m_dirm_txnq[lookup_attid].m_slv,
            m_dirm_txnq[lookup_attid].sf_write_en,
            m_dirm_txnq[lookup_attid].sf_write_way,
            m_dirm_txnq[lookup_attid].recall_req_expected);
    end
endfunction: dirm_lookups

function void dce_dirm_scoreboard::dirm_commits(
    uvm_phase phase,
    bit [10:0] commit_attid,
    bit pending_txn_in_att);

    //update directory manager on commit request
    m_dirm_mgr.commit_request(
        m_dirm_txnq[commit_attid].cacheline,
        m_dirm_txnq[commit_attid].req_aiuid,
        m_dirm_txnq[commit_attid].m_dont_write, 
        pending_txn_in_att,
        m_dirm_txnq[commit_attid].m_ocv,
        m_dirm_txnq[commit_attid].m_scv,
        m_dirm_txnq[commit_attid].sf_write_en,
        m_dirm_txnq[commit_attid].sf_write_way);

    //{ACT}Commit req matches with {EXP}
    //Deleting the Att entry & drop objection
    `uvm_info("DIRM SCB", $psprintf("Deleting sucessful commit req: %s", m_dirm_txnq[commit_attid].convert2string()), UVM_MEDIUM)
    m_dirm_txnq.delete(commit_attid);
    phase.drop_objection(this, "Drop objection");

endfunction: dirm_commits

function bit dce_dirm_scoreboard::maint_req_progress_in_att();
    bit status;
    bit [10:0] m_attid;

    if(m_dirm_txnq.first(m_attid)) begin
        do begin
            status = status || m_dirm_txnq[m_attid].maint_req;
        end while(m_dirm_txnq.next(m_attid));
    end

    return(status);
endfunction: maint_req_progress_in_att

function void dce_dirm_scoreboard::alloc_attid2cacheline_map(
    bit [10:0] m_attid,
    bit [47:0]            m_addr);

    bit [47:0] tmp_addr;

    //Set Wake req expected and map attid's per cachline
    tmp_addr = m_dirm_mgr.offset_align_cacheline(m_addr);

    if(m_attid_map_per_addr.exists(tmp_addr)) begin
        if(!m_dirm_txnq[m_attid].wake_req_expected) begin
            m_attid_map_per_addr[tmp_addr].push_back(m_attid);
            m_dirm_txnq[m_attid].wake_req_expected = 1'b1;
        end
    end else begin
        m_attid_map_per_addr[tmp_addr][0] = m_attid;
    end

    if(m_scb_db) begin
        string s;
        $sformat(s, "%s \n@ dce attid's in ATT order of processing for cacheline:0x%0h:", s, tmp_addr);
        foreach(m_attid_map_per_addr[tmp_addr][ridx])
            $sformat(s, "%s %0d", s, m_attid_map_per_addr[tmp_addr][ridx]);

        `uvm_info("DIRM SCB" , s, UVM_MEDIUM)
    end

endfunction: alloc_attid2cacheline_map

//Method indicates if there are any pending ATTID's that are dependent on this 
//cacheline. 1 if dependent else 0.
//anippuleti(04/26/16): if a normal recall goes to sleep behing a maintanence recall 
// index/way, all,, victim_buffer, then for maint commits we say that pending txns == 0
//because the normal recall enry is already invalidated and its commit is a fake commit. 
function bit dce_dirm_scoreboard::dealloc_attid2cacheline_map(
    bit [10:0] m_attid,
    bit [47:0] m_addr);

    bit [47:0] tmp_addr;
    bit pending_txn_in_att;

    //Check if there is a active cacheline & take care of attid map ordering
    tmp_addr = m_dirm_mgr.offset_align_cacheline(m_addr);
    if(m_attid_map_per_addr.exists(tmp_addr)) begin

        if(m_attid_map_per_addr[tmp_addr][0] == m_attid) begin
            `uvm_info("DIRM MGR", "{EXP} commit observed in order", UVM_MEDIUM)
            void'(m_attid_map_per_addr[tmp_addr].pop_front());

            //No pending attid's on current attid
            if(m_attid_map_per_addr[tmp_addr].size() == 0) begin
                if(m_scb_db) begin
                    `uvm_info("DIRM MGR", $psprintf("observed attid:%0d deleting_addr:0x%0h",
                        m_attid, m_addr), UVM_MEDIUM)
                end
                m_attid_map_per_addr.delete(tmp_addr);

            end else begin
                //special case
                foreach(m_attid_map_per_addr[tmp_addr][idx]) begin
                   bit [10:0] tmp_id;

                   tmp_id = m_attid_map_per_addr[tmp_addr][idx];
                   if(!m_dirm_txnq[tmp_id].att_recall_txn) begin
                       pending_txn_in_att = 1'b1;
                   end
                end
            end 

        end else begin 
            `uvm_info("DIRM MGR", $psprintf("addr:0x%0h {ACT, EXP} attid: {%0d, %0d}",
                m_addr, m_attid, m_attid_map_per_addr[tmp_addr][0]),
                UVM_NONE)
            `uvm_error("DIRM MGR", "Order of commits from ATT are wrong") 
        end
    end else begin
        `uvm_info("DIRM SCB", $psprintf("{ACT} commit: %s", m_rsp_pkt.convert2string()), UVM_NONE)
        `uvm_error("DIRM SCB", "Unexpected commit req from unallocated attid")
    end

    return(pending_txn_in_att);
endfunction: dealloc_attid2cacheline_map

//Print All active ATT's
function int dce_dirm_scoreboard::active_att_snapshot();
    bit [10:0] m_attid;
    bit [47:0] addr_idx;
    string s;
    int status;

    status = m_dirm_txnq.num();

    $sformat(s, "%s \nPrinting all active pending ATTid's:", s);
    $sformat(s, "%s \n========================================================", s);

    if(m_dirm_txnq.first(m_attid)) begin
        do begin
            $sformat(s, "%s \npkt: %s", s, m_dirm_txnq[m_attid].convert2string());
        end while(m_dirm_txnq.next(m_attid));
    end

    $sformat(s, "%s \n\nPrinting all ATTid's associated per cacheline:", s);
    if(m_attid_map_per_addr.first(addr_idx)) begin
        do begin
           $sformat(s, "%s \n@ cacheline:0x%0h:", s, addr_idx);

           foreach(m_attid_map_per_addr[addr_idx][ridx])
               $sformat(s, "%s %0d", s, m_attid_map_per_addr[addr_idx][ridx]);
        end while(m_attid_map_per_addr.next(addr_idx));
    end

    $sformat(s, "%s \n========================================================", s);
    `uvm_info("DIRM SCB" , s, UVM_NONE)

     return(status);
endfunction: active_att_snapshot

//Comapre all valid SF ways for drim_req pkts
function bit dce_dirm_scoreboard::compare_commit_sf_info(
                 const ref dce_dirm_req_item m_seq_item);
   bit cmp_success;

   if(!((m_dirm_txnq[m_seq_item.get_attid()].sf_write_en.size() == m_seq_item.get_sf_write_size()) &&
   (m_dirm_txnq[m_seq_item.get_attid()].sf_write_way.size() == m_seq_item.get_sf_way_size()))) begin

       `uvm_info("DIRM SCB", $psprintf("{EXP} commit: %s", m_dirm_txnq[m_seq_item.get_attid()].convert2string()), UVM_NONE)
       `uvm_info("DIRM SCB", $psprintf("{ACT} commit: %s", m_seq_item.convert2string()), UVM_NONE)

       `uvm_error("DIRM SCB", $psprintf("Tb_Error: Num Snoop filter sizes don't match {EXP} {wr_en, ways}: {%0d, %0d}; {ACT} {wr_en, ways} {%0d, %0d}",
       m_dirm_txnq[m_seq_item.get_attid()].sf_write_en.size(), m_dirm_txnq[m_seq_item.get_attid()].sf_write_way.size(),
       m_seq_item.get_sf_write_size(), m_seq_item.get_sf_way_size()))
   end

   for(int ridx = 0; ridx < m_seq_item.get_sf_write_size(); ridx++) begin

       if((m_dirm_txnq[m_seq_item.get_attid()].sf_write_en[ridx] == m_seq_item.get_sf_write_value(ridx)) &&
       (m_dirm_txnq[m_seq_item.get_attid()].sf_write_way[ridx] == m_seq_item.get_sf_way_value(ridx))) begin
           cmp_success = 1'b1;
       end else begin
           cmp_success = 1'b0;
           break;
       end

   end

   if(m_scb_db) begin
       for(int ridx = 0; ridx < m_seq_item.get_sf_write_size(); ridx++) begin
           `uvm_info("DIRM SCB", $psprintf("{ACT, EXP} write_en:{%0d,%0d} way:{%0d,%0d}", 
           m_seq_item.get_sf_write_value(ridx),
           m_dirm_txnq[m_seq_item.get_attid()].sf_write_en[ridx],
           m_seq_item.get_sf_way_value(ridx),
           m_dirm_txnq[m_seq_item.get_attid()].sf_write_way[ridx]), UVM_HIGH)
       end
   end

   return(cmp_success);
endfunction: compare_commit_sf_info


function bit dce_dirm_scoreboard::compare_way_selected(
                 const ref int exp_write_en[$],
                 const ref int exp_write_way[$],
                 const ref int act_write_en[$],
                 const ref int act_write_way[$]);
    bit status;

    if(!(exp_write_en.size() == act_write_en.size()) &&
    (exp_write_way.size() == act_write_way.size())) begin
        `uvm_info("DIRM SCB", $psprintf("Tb_Error: Num Snoop filter sizes don't match {EXP} {wr_en, ways}: {%0d, %0d}; {ACT} {wr_en, ways} {%0d, %0d}",
        exp_write_en.size(), exp_write_way.size(), act_write_en.size(), act_write_way.size()), UVM_HIGH)
        return(1'b0);
    end

    //Either all SF are shut_down or configuration only has null filters
    if(exp_write_en.size() == 0) begin
        status = 1'b1;
    end

    for(int i = 0; i < act_write_en.size(); i++) begin
        if(exp_write_en[i] != act_write_en[i]) begin
            status = 1'b0;
            break;
        end

        if(act_write_en[i]) begin
            if(exp_write_way[i] == act_write_way[i]) begin
                status = 1'b1;
            end else begin
                status = 1'b0;
                break;
            end
        end else begin
            status = 1'b1;
        end
    end

    if(!status) begin
        for(int i = 0; i < act_write_en.size(); i++) begin
            `uvm_info("DIRM SCB", $psprintf("{ACT, EXP} write_en:{%0d,%0d} way:{%0d,%0d}", 
            act_write_en[i], exp_write_en[i], act_write_way[i], exp_write_way[i]), UVM_NONE)
        end
    end

    return(status);
endfunction: compare_way_selected


//Comapre all valid SF ways for dirm_rsp pkts
function bit dce_dirm_scoreboard::compare_lookup_sf_info(
                 const ref dce_dirm_rsp_item m_seq_item);
   bit cmp_success;

   if(!((m_dirm_txnq[m_seq_item.get_attid()].sf_write_en.size() == m_seq_item.get_sf_write_size()) &&
   (m_dirm_txnq[m_seq_item.get_attid()].sf_write_way.size() == m_seq_item.get_sf_way_size()))) begin

       `uvm_info("DIRM SCB", $psprintf("{EXP} commit: %s", m_dirm_txnq[m_seq_item.get_attid()].convert2string()), UVM_NONE)
       `uvm_info("DIRM SCB", $psprintf("{ACT} commit: %s", m_seq_item.convert2string()), UVM_NONE)

       `uvm_error("DIRM SCB", $psprintf("Tb_Error: Num Snoop filter sizes don't match {EXP} {wr_en, ways}: {%0d, %0d}; {ACT} {wr_en, ways} {%0d, %0d}",
       m_dirm_txnq[m_seq_item.get_attid()].sf_write_en.size(), m_dirm_txnq[m_seq_item.get_attid()].sf_write_way.size(),
       m_seq_item.get_sf_write_size(), m_seq_item.get_sf_way_size()))
   end

   for(int ridx = 0; ridx < m_seq_item.get_sf_write_size(); ridx++) begin

       if((m_dirm_txnq[m_seq_item.get_attid()].sf_write_en[ridx] == m_seq_item.get_sf_write_value(ridx)) &&
       (m_dirm_txnq[m_seq_item.get_attid()].sf_write_way[ridx] == m_seq_item.get_sf_way_value(ridx))) begin
           cmp_success = 1'b1;
       end else begin
           cmp_success = 1'b0;
           break;
       end

   end

   if(m_scb_db) begin
       for(int ridx = 0; ridx < m_seq_item.get_sf_write_size(); ridx++) begin
           `uvm_info("DIRM SCB", $psprintf("{ACT, EXP} write_en:{%0d,%0d} way:{%0d,%0d}", 
           m_seq_item.get_sf_write_value(ridx),
           m_dirm_txnq[m_seq_item.get_attid()].sf_write_en[ridx],
           m_seq_item.get_sf_way_value(ridx),
           m_dirm_txnq[m_seq_item.get_attid()].sf_write_way[ridx]), UVM_MEDIUM)
       end
   end

   return(cmp_success);
endfunction: compare_lookup_sf_info

task dce_dirm_scoreboard::recall_way_randomizer();
    int count;
    string msg;

    e_per_cycle.wait_ptrigger();
    count = 0;
    $sformat(msg, "recall_cnt_en:%b", recall_init_val_latched);

    if(recall_init_val_latched) begin
        for(int i = 0; i < addrMgrConst::NUM_SF; i++) begin
            if(addrMgrConst::snoop_filters_info[i].filter_type == "TAGFILTER") begin

                if(recall_randomizer[count] == addrMgrConst::snoop_filters_info[i].num_ways - 1) begin
                    recall_randomizer[count] = 0;
                end else begin
                    recall_randomizer[count]++;
                end
                $sformat(msg, "%s recall_cnt[%0d]:%0d", msg, count, recall_randomizer[count]);
                count++;  
            end
        end
    end

    if(m_scb_db)
        `uvm_info("DIRM SCB", msg, UVM_HIGH)
endtask: recall_way_randomizer

//End of test checks
function void dce_dirm_scoreboard::report_phase(uvm_phase phase);
    m_dirm_mgr.update_maint_req_pend_in_att(maint_req_progress_in_att());
    if(m_dirm_mgr.maint_req_in_progress)
        `uvm_error("DIRM MGR", "Pending Maintenance operations that were never processed by directory mgr")

     if($test$plusargs("analyze_dce_traffic")) begin
         print_cacheline_allocations();
     end
endfunction: report_phase

function void dce_dirm_scoreboard::analyze_dce_traffic(
    const ref dce_dirm_txn m_dirm_txn);
    int tagf_cnt;

    tagf_cnt = 0;
    foreach(addrMgrConst::snoop_filters_info[idx]) begin
        if(addrMgrConst::snoop_filters_info[idx].filter_type == "TAGFILTER") begin
            if(m_dirm_txn.sf_write_en[idx]) begin
                bit [47:0] matchq[$];

                matchq = m_cachelines_alloc_in_sf[tagf_cnt].find(item) with (
                             item == m_dirm_txn.cacheline);
                if(matchq.size() == 0) begin
                    m_cachelines_alloc_in_sf[tagf_cnt].push_back(m_dirm_txn.cacheline);
                end
            end
            tagf_cnt++;
        end
    end
endfunction: analyze_dce_traffic

function void dce_dirm_scoreboard::print_cacheline_allocations();
    bit [47:0] unique_cachelines[$];
    string s;
    int tagf_cnt;

    for(int i = 0; i < addrMgrConst::NUM_TAG_SF; i++) begin
        foreach(m_cachelines_alloc_in_sf[i][idx]) begin
            bit [47:0] matchq[$];

            matchq = unique_cachelines.find(item) with(
                         item == m_cachelines_alloc_in_sf[i][idx]);
            if(matchq.size() == 0) begin
                unique_cachelines.push_back(m_cachelines_alloc_in_sf[i][idx]);
            end
        end
    end

    $sformat(s, "%s \n unique_cachelines_generated:%0d", s, unique_cachelines.size());
    tagf_cnt = 0;
    foreach(addrMgrConst::snoop_filters_info[idx]) begin
        if(addrMgrConst::snoop_filters_info[idx].filter_type == "TAGFILTER") begin
            bit [31:0] unique_set_indexes[$];
            bit [47:0] cachelines_assoc2set_index[bit[31:0]][$];

            foreach(m_cachelines_alloc_in_sf[tagf_cnt][in_idx1]) begin
                bit [31:0] set_index;
                bit [31:0] matchq[$];

                set_index = m_dirm_mgr.set_index_for_cacheline(
                                m_cachelines_alloc_in_sf[tagf_cnt][in_idx1], idx);
                matchq = unique_set_indexes.find(item) with(
                             item == set_index);
                if(matchq.size() == 0) begin
                    unique_set_indexes.push_back(set_index);
                end

                if(cachelines_assoc2set_index.exists(set_index)) begin
                    cachelines_assoc2set_index[set_index].push_back(
                        m_cachelines_alloc_in_sf[tagf_cnt][in_idx1]);
                end else begin
                    cachelines_assoc2set_index[set_index][0] = 
                        m_cachelines_alloc_in_sf[tagf_cnt][in_idx1];
                end
            end

            $sformat(s, "%s \n SF%0d num_set_indexes_hit:%0d {set_index, assoc_num_addr}:",
                     s, idx, unique_set_indexes.size());
            foreach(unique_set_indexes[in_idx1]) begin
                $sformat(s, "%s {0x%0h %0d}", s, unique_set_indexes[in_idx1],
                    cachelines_assoc2set_index[unique_set_indexes[in_idx1]].size());
            end
            tagf_cnt++;
        end
    end
    `uvm_info("DIRM MGR", s, UVM_NONE)
endfunction: print_cacheline_allocations


`ifdef COVER_ON
function void dce_dirm_scoreboard::collect_fun_coverage(
    bit [47:0] m_addr);
    bit [47:0] addr_idx;    

    m_dirm_mgr.collect_fun_coverage(m_addr);
    if(m_cov == null)
       `uvm_fatal("DIRM MGR", "coverage object is null")
<% 
var vc_exists = function() {
    var exists = false;
    obj.SnoopFilterInfo.forEach(function(bundle, indx, array) {
        if(bundle.fnFilterType === "TAGFILTER") {
            if(bundle.StorageInfo.nVictimEntries) {
                exists = true;
            }
        }
    });
    return(exists);
};
%>

<% if(vc_exists()) { %>
    if(m_dirm_mgr.m_sampleq.size() > 0) begin
        int tagf_cnt;

        tagf_cnt = 0;
        for(int m_sfid = 0; m_sfid < addrMgrConst::NUM_SF; m_sfid++) begin
            if((addrMgrConst::snoop_filters_info[m_sfid].filter_type == "TAGFILTER") &&
                m_dirm_mgr.is_snoop_filter_en(m_sfid)) begin

                //`uvm_info("NAN", "vctbPush happened", UVM_NONE)
                //FIXME Coverage collector bins must be per Snoop Filter
                if(m_dirm_mgr.m_sampleq[tagf_cnt]["vctb_push"]) begin
                    m_cov.log_vc_push();
                end

                if(m_dirm_mgr.m_sampleq[tagf_cnt]["vctb_pop"])
                    m_cov.log_vc_hit();

                if(m_dirm_mgr.m_sampleq[tagf_cnt]["vctb_swap"])
                    m_cov.log_vc_swap();

                if(m_dirm_mgr.m_sampleq[tagf_cnt]["vctb_full"])
                    m_cov.log_vc_full();

                if(m_dirm_mgr.m_sampleq[tagf_cnt]["vctb_recall"])
                    m_cov.log_vc_recall();

                if(m_dirm_mgr.m_sampleq[tagf_cnt]["vctb_maint_op"])
                    m_cov.log_maint_vc_recall();

                if(m_dirm_mgr.m_sampleq[tagf_cnt]["vctb_maint_recall_by_addr"])
                    m_cov.log_maint_vc_addr();

                if(m_dirm_mgr.m_sampleq[tagf_cnt]["vctb_full2empty"])
                    m_cov.log_vc_empty();

                if(m_dirm_mgr.m_sampleq[tagf_cnt]["vctb_updinv"])
                    m_cov.cover_updReqHitVctb();

                if(m_dirm_mgr.m_sampleq[tagf_cnt]["vctb_cmp_updinv"]) begin
                    m_cov.log_vc_upd_invalidation();
                    m_cov.cover_updReqHitInvVctb();
                end
                
                if(m_dirm_mgr.obsrvd_vctb_hit_in_all_sf)
                    m_cov.log_vc_hit_per_sf();

                if(m_dirm_mgr.obsrvd_vctb_hit_tagf_hit)
                    m_cov.log_vc_hit_sf_hit();

                tagf_cnt++;
            end
        end
    end
<% } %>

    if(m_dirm_mgr.m_sampleq.size() > 0) begin
        int tagf_cnt;

        tagf_cnt = 0;
        for(int m_sfid = 0; m_sfid < addrMgrConst::NUM_SF; m_sfid++) begin
            if((addrMgrConst::snoop_filters_info[m_sfid].filter_type == "TAGFILTER") &&
                m_dirm_mgr.is_snoop_filter_en(m_sfid)) begin


                if(m_dirm_mgr.m_sampleq[tagf_cnt]["updinv_drop"])
                    m_cov.cover_updReqDrpInCoarseRep();

                if(m_dirm_mgr.m_sampleq[tagf_cnt]["upd_tagf_inv"])
                    m_cov.cover_updReqHitInvTf();

                if(m_dirm_mgr.m_sampleq[tagf_cnt]["upd_coarse_rep"])
                    m_cov.cover_updReqHitInCoarseRep();
                tagf_cnt++;
            end
        end
    end

    //Coverage analysis for ATT Linked-list intersting senarios
    if(m_attid_map_per_addr.first(addr_idx)) begin
        do begin
            if(m_attid_map_per_addr[addr_idx].size() > 1) begin
                bit [10:0] att_id0, att_id1;

                att_id0 = m_attid_map_per_addr[addr_idx][0];
                att_id1 = m_attid_map_per_addr[addr_idx][1];

                if(m_dirm_txnq[att_id0].att_recall_txn) begin
                    if(m_dirm_txnq[att_id1].att_recall_txn) begin
                        if(m_scb_db) begin
                            `uvm_info(this.get_name(),
                                "cover_recallReqinSleepBehindRecallReq", UVM_HIGH)
                        end
                        m_cov.cover_recallReqinSleepBehindRecallReq();
                    end else if(m_dirm_txnq[att_id1].maint_req) begin
                        if(m_scb_db) begin
                            `uvm_info(this.get_name(),
                                "cover_maintReqinSleepBehindRecallReq", UVM_HIGH)
                        end
                        m_cov.cover_maintReqinSleepBehindRecallReq();
                    end else begin
                        if(m_scb_db) begin
                            `uvm_info(this.get_name(),
                                "cover_cohReqinSleepBehindRecallReq", UVM_HIGH)
                        end
                        m_cov.cover_cohReqinSleepBehindRecallReq();
                    end

                end else if(m_dirm_txnq[att_id0].maint_req) begin
                    if(m_dirm_txnq[att_id1].att_recall_txn) begin
                        if(m_scb_db) begin
                            `uvm_info(this.get_name(),
                                "cover_recallReqinSleepBehindMaintReq", UVM_HIGH)
                        end
                        m_cov.cover_recallReqinSleepBehindMaintReq();
                    end else if(m_dirm_txnq[att_id1].maint_req) begin
                        if(m_scb_db) begin
                            `uvm_info(this.get_name(),
                                "cover_maintReqinSleepBehindMaintReq", UVM_HIGH)
                        end
                        m_cov.cover_maintReqinSleepBehindMaintReq();
                    end else begin
                        if(m_scb_db) begin
                            `uvm_info(this.get_name(),
                                "cover_cohReqinSleepBehindMaintReq", UVM_HIGH)
                        end
                        m_cov.cover_cohReqinSleepBehindMaintReq();
                    end

                end else begin
                    if(m_dirm_txnq[att_id1].maint_req) begin
                        if(m_scb_db) begin
                            `uvm_info(this.get_name(),
                                "cover_maintReqinSleepBehindCohReq", UVM_HIGH)
                        end
                        m_cov.cover_maintReqinSleepBehindCohReq();
                    end else begin
                        if(m_scb_db) begin
                            `uvm_info(this.get_name(),
                                "cover_cohReqinSleepBehindCohReq", UVM_HIGH)
                        end
                        m_cov.cover_cohReqinSleepBehindCohReq();
                    end
                end
            end
        end while(m_attid_map_per_addr.next(addr_idx));
    end
endfunction: collect_fun_coverage


function void dce_dirm_scoreboard::collect_coh_addr_sec(bit [47:0] m_addr);

<%if(obj.wSecurityAttribute) { %>
    if(addr_cmp_excl_sec_bit(m_addr, coh_addr_list)) begin
        m_cov.log_same_addr_dif_sec();

        //`uvm_info("DIRM MGR",
        //    $psprintf("log_same_addr_dif_sec observed:0x%h", m_addr), UVM_NONE)
    end else begin
        coh_addr_list.push_back(m_addr);
    end
<% } %>
endfunction: collect_coh_addr_sec

function void dce_dirm_scoreboard::collect_recall_addr_sec(bit [47:0] m_addr);

<%if(obj.wSecurityAttribute) { %>
    if(addr_cmp_excl_sec_bit(m_addr, recall_addr_list)) begin
        m_cov.log_recall_addr_dif_sec();

        //`uvm_info("DIRM MGR",
        //    $psprintf("log_recall_addr_dif_sec observed:0x%h", m_addr), UVM_NONE)
    end else begin
        recall_addr_list.push_back(m_addr);
    end
<% } %>
endfunction: collect_recall_addr_sec

function int dce_dirm_scoreboard::addr_cmp_excl_sec_bit(bit [47:0] m_addr,
    const ref bit [47:0] addr_list[$]);

    bit [47:0] tmp_list[$];
    tmp_list = addr_list.find(tmp_addr) with(((tmp_addr[<%=obj.wSfiAddr%> - 1:0] == m_addr[<%=obj.wSfiAddr%> - 1:0]) &&
                                              (tmp_addr[<%=obj.wSfiAddr%>]       != m_addr[<%=obj.wSfiAddr%>])));
    return(tmp_list.size());
endfunction: addr_cmp_excl_sec_bit

`endif
