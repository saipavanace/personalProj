//////////////////////////////////////////////////////////////
//
//DCE Directory Manager Scoreboard
//
//////////////////////////////////////////////////////////////

class dce_dirm_txn extends uvm_object;

     `uvm_object_param_utils(dce_dirm_txn)

     //////////////////////////////////////////////////////////////
     //Data Members
     //////////////////////////////////////////////////////////////
     bit [10:0]   attid;
     bit [10:0]   req_aiuid;
     bit [47:0]   cacheline;
     eMsgCMD      msg_type;
     int                                         sf_write_en[$];
     int                                         sf_write_way[$];
     //bit set if it is a recall transaction
     bit                                         att_recall_txn;

     //Coh req data members
     bit                                         coh_req;
     time                                        coh_req_time;

     //upd req data members
     bit                                         upd_req_observed;
     time                                        upd_req_time[$];
     bit [10:0]                                  upd_req_aiuid[$];

     //wake req data members
     bit                                         wake_req_expected;
     bit                                         wake_req_observed;
     time                                        wake_req_time;

     //recall req data memebers
     bit                                         recall_req_expected;
     bit                                         recall_req_observed;
     time                                        recall_req_time;
     int                                         recall_randomizer[$];
     bit [10:0]       recall_req_attid;;
     bit [47:0]       recall_req_cacheline;
     
     //maint recall data members
     bit                                         maint_req;

     //commit req data members
     bit                                         commit_req;
     time                                        commit_req_time;
     bit                                         m_dont_write;
     bit [10:0] m_ocv;
     bit [10:0] m_scv;

     //dir rsp data resp members
     bit coh_dir_rsp;
     bit [10:0] m_olv;
     bit [10:0] m_slv;
     //used only by dce scoreboard
     time t_dirm_rsp;
     int  m_lkup_sf_write_en[$];
     int  m_lkup_sf_write_way[$];
     
     //Maint req opcode observd at directory mgr interface
     //Used only by DCE scoreboard
     bit [10:0] maint_req_opcode;

     //////////////////////////////////////////////////////////////
     //Methods
     //////////////////////////////////////////////////////////////
     extern function new(string name = "dce_dirm_txn");
     extern function void assign_coh_req_info(time t,
                                              bit [10:0] m_attid,
                                              bit [47:0] m_addr,
                                              bit [10:0] m_aiuid,
                                              eMsgCMD    m_msg_type);

     extern function void assign_wake_req_info(time t);
     extern function void assign_recall_req_info(time t, 
                                                 bit [10:0] m_attid,
                                                 bit [47:0] m_addr,
                                                 eMsgCMD    m_msg_type);
     extern function void assign_commit_req_info(time t,
                                                 bit [10:0] m_ocv,
                                                 bit [10:0] m_scv,
                                                 bit m_dont_write,
                                                 const ref int sf_write_en[$],
                                                 const ref int sf_write_way[$]);
     extern function void assign_maint_req_info(time t,
                                                bit [10:0] m_attid,
                                                bit [47:0] m_addr,
                                                eMsgCMD maint_req_opcode);

     extern function void update_recall_observed(
                              time t,
                              bit [10:0] m_attid,
                              bit [47:0] m_addr);
                                                
     extern function string convert2string();
     //Used onlu by DCE scoreboard    
     extern function void assign_dirm_rsp_info(time t,
                                               bit [10:0] m_olv,
                                               bit [10:0] m_slv,
                                               const ref int sf_write_en[$],
                                               const ref int sf_write_way[$]);
endclass: dce_dirm_txn

function dce_dirm_txn::new(string name = "dce_dirm_txn");
    super.new(name);
endfunction: new

function void dce_dirm_txn::assign_coh_req_info(time t,
                  bit [10:0] m_attid,
                  bit [47:0] m_addr,
                  bit [10:0] m_aiuid,
                  eMsgCMD    m_msg_type);

    this.coh_req = 1'b1;
    this.coh_req_time = t;
    this.attid        = m_attid;
    this.req_aiuid    = m_aiuid;
    this.cacheline    = m_addr;
    this.msg_type     = m_msg_type;
endfunction: assign_coh_req_info

function void dce_dirm_txn::assign_wake_req_info(time t);
    this.wake_req_observed = 1'b1;
    this.wake_req_time = t;
endfunction: assign_wake_req_info

function void dce_dirm_txn::assign_recall_req_info(
                   time t,
                   bit [10:0] m_attid,
                   bit [47:0] m_addr,
                   eMsgCMD m_msg_type);

    this.recall_req_time = t;
    this.attid = m_attid;
    this.cacheline = m_addr;
    this.msg_type = m_msg_type;
endfunction: assign_recall_req_info

function void dce_dirm_txn::update_recall_observed(time t,
                   bit [10:0] m_attid,
                   bit [47:0] m_addr);

    this.recall_req_observed = 1'b1;
    this.recall_req_time = t;
    this.recall_req_attid = m_attid;
    this.recall_req_cacheline = m_addr;

endfunction: update_recall_observed

function void dce_dirm_txn::assign_maint_req_info(time t,
                                                               bit [10:0] m_attid,
                                                               bit [47:0] m_addr,
                                                               eMsgCMD maint_req_opcode);
    this.maint_req = 1'b1;
    this.attid = m_attid;
    this.cacheline = m_addr;
    this.maint_req_opcode = maint_req_opcode;

endfunction: assign_maint_req_info

function void dce_dirm_txn::assign_commit_req_info(time t,
                                                   bit [10:0] m_ocv,
                                                   bit [10:0] m_scv,
                                                   bit m_dont_write,
                                                   const ref int sf_write_en[$],
                                                   const ref int sf_write_way[$]);
    this.commit_req = 1;
    this.commit_req_time = t;
    this.m_dont_write = m_dont_write || this.m_dont_write;
    this.m_ocv = m_ocv;
    this.m_scv = m_scv;

    for(int i = 0; i < sf_write_en.size(); i++) begin
        this.sf_write_en[i]  = sf_write_en[i];
        this.sf_write_way[i] = sf_write_way[i];
    end

endfunction: assign_commit_req_info

//used onyl bt dce scoreboard
function void dce_dirm_txn::assign_dirm_rsp_info(time t,
    bit [10:0] m_olv,
    bit [10:0] m_slv,
    const ref int sf_write_en[$],
    const ref int sf_write_way[$]);

    this.t_dirm_rsp = $time;
    this.coh_dir_rsp = 1'b1;
    this.m_olv = m_olv;
    this.m_slv = m_slv;
    for(int i = 0; i < sf_write_en.size(); i++) begin
        this.m_lkup_sf_write_en[i]  = sf_write_en[i];
        this.m_lkup_sf_write_way[i] = sf_write_way[i];
    end
endfunction: assign_dirm_rsp_info

function string dce_dirm_txn::convert2string();
    string s;
    eMsgCMD msg;

    $timeformat(-9, 2, " ns", 10);

    $sformat(s, "%s\n", super.convert2string());
    $sformat(s, "%s@ %t: ", s, $time());

    if(coh_req) begin
        if(!$cast(msg, msg_type))
            `uvm_fatal("DIRM SCB", "Unable to cast")

        $sformat(s, "%sCOH_REQ time:%0t attid:0x%0h aiuid:0x%0h addr:0x%0h msg:%s",
        s, coh_req_time, attid, req_aiuid, cacheline, msg.name());

        if(coh_dir_rsp) begin
           $sformat(s, "%s olv:0x%h slv:0x%h", s, m_olv, m_slv);
            foreach(sf_write_en[ridx]) begin
                if(sf_write_en[ridx])
                    $sformat(s, "%s sf[%0d]_way:0x%0h", s, ridx, sf_write_way[ridx]);
            end
        end

    end else if(maint_req) begin
        $sformat(s, "%s MAINT_REQ time:%0t attid:0x%0h addr:0x%0h opcode:%p", s, coh_req_time, attid, cacheline, maint_req_opcode);

        if(coh_dir_rsp) begin
           $sformat(s, "%s olv: 0x%h slv:0x%h", s, m_olv, m_slv);
            foreach(sf_write_en[ridx]) begin
                if(sf_write_en[ridx])
                    $sformat(s, "%s sf[%0d]_way:0x%0h", s, ridx, sf_write_way[ridx]);
            end
        end
    end else if(att_recall_txn) begin
        $sformat(s, "%s RECALL_REQ time:%0t attid:0x%0h addr:0x%0h eSnpRecall",
        s, recall_req_time, attid, cacheline);

        if(coh_dir_rsp) begin
           $sformat(s, "%s olv: 0x%h slv:0x%h", s, m_olv, m_slv);
            foreach(sf_write_en[ridx]) begin
                if(sf_write_en[ridx])
                    $sformat(s, "%s sf[%0d]_way:0x%0h", s, ridx, sf_write_way[ridx]);
            end
        end
    end

    if(upd_req_observed) begin
        foreach(upd_req_time[i]) begin
            $sformat(s, "%s UPD_REQ[%0d] time:%0t aiuid:0x%0h msg:eUpdInv", s, i, upd_req_time[i], upd_req_aiuid[i]);
        end
    end

    if(wake_req_expected) begin
        $sformat(s, "%s WAKE_REQ time:%0t", s, wake_req_time);
    end

    if(recall_req_expected) begin
        $sformat(s, "%s RECALL_REQ time:%0t attid:0x%0h addr:0x%0h", s, recall_req_time, recall_req_attid, recall_req_cacheline);
    end

    if(commit_req) begin
        $sformat(s, "%s COMMIT_REQ time:%0t dont_write:%b ocv:0x%h scv:0x%h", s, commit_req_time, m_dont_write, m_ocv, m_scv);
        foreach(sf_write_en[i]) begin
            if(sf_write_en[i]) begin
                $sformat(s, "%s sf[%0d]_way:0x%0h", s, i, sf_write_way[i]);
            end
        end
    end

    return(s);
endfunction: convert2string

<% 
var numTagSf = function() {
    var n = 0;
    obj.SnoopFilterInfo.forEach(function(bundle, indx) {
        if(bundle.fnFilterType === "TAGFILTER") {
            n++;
        }
    });
    return(n);
};
%>
