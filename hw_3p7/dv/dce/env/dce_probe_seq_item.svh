//----------------------------------------------------
// DM seq_item for all inputs and outputs to/from DM
//----------------------------------------------------
<% 
var total_sf_ways = 0;
var max_sf_set_idx = 0;

obj.SnoopFilterInfo.forEach(function(bundle) {
    if(bundle.fnFilterType === "EXPLICITOWNER") {
        total_sf_ways += bundle.nWays;
        if (bundle.SetSelectInfo.PriSubDiagAddrBits.length > max_sf_set_idx) {
			max_sf_set_idx = bundle.SetSelectInfo.PriSubDiagAddrBits.length;
        }
    }
});
%> 

localparam WSFWAYVEC  = <%=total_sf_ways%>;
localparam WSFSETIDX  = <%=max_sf_set_idx%>;

typedef enum bit [3:0] {
    DM_CMD_REQ, 
    DM_UPD_REQ, 
    DM_CMT_REQ,  
    DM_LKP_RSP,
    DM_REC_REQ, 
    DM_RTY_RSP 
} dirm_access_type_t;

typedef enum bit [1:0] {
    NO_UPD, 
    RSVD, 
    UPD_FAIL,  
    UPD_COMP
} upd_status_t;
typedef enum bit [1:0] {
    req = 1,
    ack,
    err
} event_in_t;

typedef enum bit {
    valid,
    invalid
} event_in_check;

typedef enum int { ACTIVE, SLEEP, WAKEUP } attid_state_t;


typedef struct {
    bit [WSMITGTID-1:0]	tgtid;
    bit [WSMIMSGID-1:0] rmsgid;
    bit					starv_mode;
    time 				m_time;
    longint				m_cycle_count;
} sb_cmdrsp_s;

typedef struct {
	bit [WSMIADDR-1:0] 	  addr;
  	bit 				  ns;
  	bit [WSMISRCID-1:0]   iid;
  	bit [WSMIMSGTYPE-1:0] cm_type;
 	bit [WSMIMSGID-1:0]   msg_id;
    time 				  m_time;
    longint				  cycle_count;
} probe_cmdreq_s;

typedef struct {
    longint				m_cycle_count;
    time 				m_time;
} cycle_tracker_s;

class dm_seq_item extends uvm_sequence_item;

    `uvm_object_param_utils(dm_seq_item);

//FIXME: Use parameters and remove constants.

    //valid for all reqs/rsps
    time               						   m_time;
    dirm_access_type_t 						   m_access_type;
    attid_state_t      						   m_attid_state;

    //valid for COH_REQ, UPD_REQ
    bit [WSMISRCID-1:0] 					   m_iid;
    
    //valid for UPD_REQ
    upd_status_t 							   m_status;

    //stash id 
    bit [WSMISRCID-1:0] 					   m_sid;

    //stash id 
    int                                        m_iid_cacheid;
    int                                        m_sid_cacheid;
    
    //valid for COH_REQ only
    eMsgCMD  								   m_type;
    bit 	  								   m_wakeup;

    //valid for COH_REQ, UPD_REQ, RTY_RSP
    int        								   m_attid;

    //valid for COH_REQ, UPD_REQ, REC_RSP, CMT_REQ 
    bit [WSMIADDR-1:0]	 					   m_addr;
    bit					   			   m_ns;
    bit [WSMIMSGID-1:0]						   m_msg_id;

    //valid for all LKP_RSP, CMT_REQ. REC_RSP 
    bit                                        m_owner_val;
    bit [$clog2(addrMgrConst::NUM_CACHES)-1:0] m_owner_num;
    bit [addrMgrConst::NUM_CACHES-1:0]         m_sharer_vec;
    
    bit [addrMgrConst::NUM_CACHES-1:0]  	   m_change_vec;
   
    //valid for LKP_RSP and CMT_REQ and RTY_RSP
    bit [WSFWAYVEC-1:0]        			       m_way_vec_or_mask;
   
    //valid for COH_REQ
    bit [WSFWAYVEC-1:0]  				       m_busy_vec;
    bit [WSFWAYVEC-1:0] 			           m_busy_vec_dv;
    bit         							   m_alloc;
    bit         							   m_cancel;

    //valid for LKP_RSP only
    //bit  									   m_vhit;//CONC-5362
    bit  									   m_wr_required;
    bit [addrMgrConst::NUM_SF-1:0]		 	   m_rtl_vbhit_sfvec;
    bit										   m_error;
    int										   m_way;

    //valid for RTY_RSP, COH_REQ
    bit [$clog2(addrMgrConst::NUM_SF)-1:0]     m_filter_num;
    
    bit [WSFSETIDX-1:0]                 	   m_set_index;

	//verif signals
    bit                                        m_pipelined_req;
    bit [addrMgrConst::NUM_SF-1:0]             m_pipelined_req_sfvec;
    bit                                        m_predicted_eviction;
    bit [addrMgrConst::NUM_SF-1:0]             m_eviction_needed_sfvec;
    int                                        m_evict_wayq[$];
    bit [addrMgrConst::NUM_SF-1:0]             m_tfhit_sfvec;
    int                                        m_hit_wayq[$];
    bit [addrMgrConst::NUM_SF-1:0]             m_vbhit_sfvec;
    longint      							   m_cycle_count;
    longint                                    m_status_cycle_count;
    bit stash_target_id_detached;	// DV signal to predict alloc for stash ops

    extern function new(string name = "dm_seq_item");
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer); 
    extern function void do_copy(uvm_object rhs);
    extern function string convert2string();
    extern function bit is_dm_miss();
    extern function bit is_owner_present();
    extern function bit are_sharers_present();
endclass: dm_seq_item

//**************************************************************
function dm_seq_item::new(string name = "dm_seq_item");
   super.new(name);
endfunction: new

//**************************************************************
function void dm_seq_item::do_copy(uvm_object rhs);
    dm_seq_item _rhs;
    if(!$cast(_rhs, rhs)) begin
        `uvm_error("do_copy", "cast of rhs object failed")
    end
    this.m_time         = _rhs.m_time;
    this.m_cycle_count  = _rhs.m_cycle_count;
    this.m_status_cycle_count  = _rhs.m_status_cycle_count;
    this.m_access_type  = _rhs.m_access_type;
    this.m_iid          = _rhs.m_iid;
    this.m_sid          = _rhs.m_sid;
    this.m_type         = _rhs.m_type;
    this.m_attid        = _rhs.m_attid;
    this.m_addr         = _rhs.m_addr;
    this.m_ns           = _rhs.m_ns;
    this.m_owner_val    = _rhs.m_owner_val;
    this.m_owner_num    = _rhs.m_owner_num;
    this.m_sharer_vec   = _rhs.m_sharer_vec;
    this.m_change_vec   = _rhs.m_change_vec;
    this.m_way_vec_or_mask = _rhs.m_way_vec_or_mask;
    this.m_filter_num   = _rhs.m_filter_num;
    this.m_alloc        = _rhs.m_alloc;
    this.m_cancel        = _rhs.m_cancel;
    this.m_busy_vec     = _rhs.m_busy_vec;
    //this.m_busy_vec_dv  = _rhs.m_busy_vec_dv;
    //this.m_vhit         = _rhs.m_vhit;//CONC-5362
    this.m_wr_required  = _rhs.m_wr_required;
    this.m_rtl_vbhit_sfvec  = _rhs.m_rtl_vbhit_sfvec;
    this.m_wakeup       = _rhs.m_wakeup;
    this.m_status       = _rhs.m_status;
    this.m_error        = _rhs.m_error;
    this.m_set_index	= _rhs.m_set_index;
    this.stash_target_id_detached	= _rhs.stash_target_id_detached;
    this.m_msg_id	= _rhs.m_msg_id;

endfunction: do_copy

//**************************************************************
function bit dm_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
    dm_seq_item _rhs;
    bit legal = 1;
    string s; 
    string sf; 

    s = "";
    $sformat(s, "@ %t: ", $time);

    if(!$cast(_rhs, rhs))
    begin
      `uvm_error("do_compare", "cast of rhs object failed")
      return 0;
    end

    if (this.m_access_type !== _rhs.m_access_type)
    begin
      $sformat(sf, "ERROR Expected: access_type: %0s Actual: access_type: %0s", this.m_access_type, _rhs.m_access_type);
      $sformat(s, "%s : %s", s, sf);
      `uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
      legal = 0;
    end

    //#Check.DCE.DM.CmdReqCancel
    if (_rhs.m_access_type == DM_CMD_REQ)
    begin
      if ((this.m_attid_state == SLEEP) ^ _rhs.m_cancel)
      begin
        $sformat(sf, "ERROR attid_state:%s cancel:%0b", this.m_attid_state, _rhs.m_cancel); 
        `uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
        $sformat(s, "%s ; %s", s, sf);
        legal = 0;
      end
    end
    //#Check.DCE.DM.CmdReqATTIDChk2
    <%if(obj.testBench == 'dce') {%>
        if (_rhs.m_access_type == DM_CMD_REQ)
	begin
    	  if(_rhs.m_attid >= <%=obj.DceInfo[0].nAttCtrlEntries%>)
	  begin
            $sformat(sf, "ERROR attid is more than attid entries");
	    `uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
            $sformat(s, "%s ; %s", s, sf);
    	    legal = 0;
    	  end
        end
    <%}%>

    if (_rhs.m_access_type != DM_LKP_RSP)
    begin
      if ((this.m_iid >> WSMINCOREPORTID) !== (_rhs.m_iid >> WSMINCOREPORTID))
      begin
        $sformat(sf, "ERROR Expected: iid: 0x%0h Actual: iid: 0x%0h", this.m_iid, _rhs.m_iid);
        `uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
        $sformat(s, "%s ; %s", s, sf);
        legal = 0;
      end
    end

    //#Check.DCE.StashRequest.Sid
    if ((_rhs.m_access_type == DM_CMD_REQ) &&
    	(_rhs.m_type inside {CMD_LD_CCH_UNQ, CMD_LD_CCH_SH, CMD_WR_STSH_FULL, CMD_WR_STSH_PTL}) &&
        _rhs.m_alloc)
    begin
      if ((this.m_sid >> WSMINCOREPORTID) !== (_rhs.m_sid >> WSMINCOREPORTID))
      begin
        $sformat(sf, "ERROR Expected: sid: 0x%0h Actual: sid: 0x%0h", this.m_sid, _rhs.m_sid);
	`uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
        $sformat(s, "%s ; %s", s, sf);
        legal = 0;
      end
    end

    if (this.m_addr !== _rhs.m_addr)
    begin
      $sformat(sf, "ERROR Expected: addr: 0x%0h Actual: addr: 0x%0h", this.m_addr, _rhs.m_addr);
      `uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
      $sformat(s, "%s ; %s", s, sf);
      legal = 0;
    end

    if (this.m_ns !== _rhs.m_ns)
    begin
      $sformat(sf, "ERROR Expected: ns: 0x%0h Actual: ns: 0x%0h", this.m_ns, _rhs.m_ns);
      `uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
      $sformat(s, "%s ; %s", s, sf);
      legal = 0;
    end

    if (this.m_type !== _rhs.m_type)
    begin
      $sformat(sf, "ERROR Expected: cmd_type: %p Actual: cmd_type: %p", this.m_type, _rhs.m_type);
      `uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
      $sformat(s, "%s ; %s", s, sf);
      legal = 0;
    end

    if (this.m_way_vec_or_mask !== _rhs.m_way_vec_or_mask)
    begin
      if ((m_access_type == DM_LKP_RSP)
             //     && (  (m_sharer_vec == 0) ||  //dm_miss
      	//         //m_vhit 			    // CONC-5362
      	//         m_wr_required          //vhit or dm_eviction
      	//     	)
         )
      begin //refer CONC-5242 on why we disabled this check 
      //disable check since the way selection is so random, it is hard for tb to predict it.
      end
      else
      begin 
        $sformat(sf, "ERROR Expected: way_vec: 0x%0h Actual: way_vec: 0x%0h", this.m_way_vec_or_mask, _rhs.m_way_vec_or_mask);
	`uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
        $sformat(s, "%s ; %s", s, sf);
        legal = 0;
      end
    end

    if (this.m_sharer_vec !== _rhs.m_sharer_vec)
    begin
      $sformat(sf, "ERROR Expected: sharer_vec: 0x%0h Actual: sharer_vec: 0x%0h", this.m_sharer_vec, _rhs.m_sharer_vec);
      `uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
      $sformat(s, "%s ; %s", s, sf);
      legal = 0;
    end

    if (this.m_change_vec !== _rhs.m_change_vec)
    begin
      $sformat(sf, "ERROR Expected: change_vec: 0x%0h Actual: change_vec: 0x%0h", this.m_change_vec, _rhs.m_change_vec);
      `uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
      $sformat(s, "%s ; %s", s, sf);
      legal = 0;
    end

    if (this.m_owner_val !== _rhs.m_owner_val)
    begin
      $sformat(sf, "ERROR Expected: owner_val: 0x%0h Actual: owner_val: 0x%0h", this.m_owner_val, _rhs.m_owner_val);
      `uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
      $sformat(s, "%s ; %s", s, sf);
      legal = 0;
    end

    if (this.m_owner_num !== _rhs.m_owner_num)
    begin
      $sformat(sf, "ERROR Expected: owner_num: 0x%0h Actual: owner_num: 0x%0h", this.m_owner_num, _rhs.m_owner_num);
      `uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
      $sformat(s, "%s ; %s", s, sf);
      legal = 0;
    end

    //#Check.DCE.StashRequest.Alloc
    if ((m_access_type == DM_CMD_REQ) && (this.m_alloc !== _rhs.m_alloc))
    begin
      $sformat(sf, "ERROR Expected: alloc: 0x%0h Actual: alloc: 0x%0h", this.m_alloc, _rhs.m_alloc);
      `uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
      $sformat(s, "%s ; %s", s, sf);
      legal = 0;
    end

    if ((m_access_type == DM_CMD_REQ) && (m_alloc == 1) && (this.m_filter_num !== _rhs.m_filter_num))
    begin
      $sformat(sf, "ERROR Expected: filter_num: 0x%0h Actual: filter_num: 0x%0h", this.m_filter_num, _rhs.m_filter_num);
      `uvm_info(get_full_name(), $sformatf("%s", sf), UVM_NONE); 
      $sformat(s, "%s ; %s", s, sf);
      legal = 0;
    end

    // CONC-5362
    //if (this.m_vhit !== _rhs.m_vhit) begin
    //    `uvm_info(get_full_name(), $sformatf("ERROR Expected: vhit: 0x%0h Actual: vhit: 0x%0h", this.m_vhit, _rhs.m_vhit), UVM_NONE); 
    //    legal = 0;
    //end
    //Cannot check for wr_required after vb recovery is enabled.
//    if (this.m_wr_required !== _rhs.m_wr_required) begin
//        `uvm_info(get_full_name(), $sformatf("ERROR Expected: wr_required: 0x%0h Actual: wr_required: 0x%0h", this.m_wr_required, _rhs.m_wr_required), UVM_NONE); 
//        //legal = 0;
//    end
//    if (this.m_busy_vec !== _rhs.m_busy_vec) begin
//        `uvm_info(get_full_name(), $sformatf("ERROR Expected: busy_vec: 0x%0h Actual: busy_vec: 0x%0h", this.m_busy_vec, _rhs.m_busy_vec), UVM_NONE); 
//       TODO: Enable the check once interface to look into attid allocation deallocation is ready
//       legal = 0;
//    end
	
    if (!legal) begin
        $stacktrace();
       if(m_access_type == DM_CMD_REQ) // Only DM.Req Interafce has command signal
       begin
         `uvm_error("do_compare", $sformatf("%s Mismatched cmd_type = %p: %s", m_access_type.name, this.m_type, s))
       end
       else
       begin
         `uvm_error("do_compare", $sformatf("%s Mismatched: %s", m_access_type.name, s))
       end
    end
    return legal;
endfunction: do_compare

//**************************************************************
function string dm_seq_item::convert2string();
    string s; 

    $sformat(s, "@ %t: access:%s", m_time, m_access_type.name());
    if(m_access_type == DM_CMD_REQ) begin
        $sformat(s, "%s cc:%0d status_cc:%0d attid_state:%s attid:0x%0h addr:0x%016h ns:%p iid:0x%02h (cacheid:0x%02h) sid:0x%02h (cacheid:0x%02h) cmd_type:%p alloc:%p filter_num:0x%02h set_index:0x%0h busy_vec:0x%X busy_vec_dv:%p pipelined_req_sfvec:0x%0h wakeup:%0b cancel:%0b", s, m_cycle_count, m_status_cycle_count, m_attid_state.name(), m_attid, m_addr, m_ns, m_iid, m_iid_cacheid, m_sid, m_sid_cacheid, m_type, m_alloc, m_filter_num, m_set_index, m_busy_vec, m_busy_vec_dv, m_pipelined_req_sfvec, m_wakeup, m_cancel);
    end else if (m_access_type == DM_UPD_REQ) begin
        $sformat(s, "%s cc:%0d addr:0x%016h ns:%p iid:0x%02h (cacheid:0x%02h) busy_vec:0x%04h upd_status:%p", s, m_cycle_count, m_addr, m_ns, m_iid, m_iid_cacheid, m_busy_vec, m_status);
    end else if (m_access_type == DM_LKP_RSP) begin
        $sformat(s, "%s cc:%0d attid_state:%s attid:0x%0h %0s way_vec:0x%04h owner_val:%p owner_num:%p sharer_vec:0x%04h wr_required:%0b rtl_vbhit_sfvec:%0p error:%0p", s, m_cycle_count, m_attid_state.name, m_attid, (m_alloc == 1 || m_alloc == 0) ? $psprintf("{sfid:%0d setidx:0x%0h way:%0d}", m_filter_num, m_set_index, m_way) : "", m_way_vec_or_mask, m_owner_val, m_owner_num, m_sharer_vec, m_wr_required, m_rtl_vbhit_sfvec, m_error);
    end else if (m_access_type == DM_CMT_REQ) begin
        $sformat(s, "%s cc:%0d attid:0x%0h addr:0x%016h ns:%p way_vec:0x%04h owner_val:%p owner_num:%p sharer_vec:0x%04h change_vec:0x%04h", s, m_cycle_count, m_attid, m_addr, m_ns, m_way_vec_or_mask, m_owner_val, m_owner_num, m_sharer_vec, m_change_vec);
    end else if (m_access_type == DM_RTY_RSP) begin
        $sformat(s, "%s cc:%0d attid:0x%0h filter_num:0x%02h way_mask:0x%02h", s, m_cycle_count, m_attid, m_filter_num, m_way_vec_or_mask);
    end else if (m_access_type == DM_REC_REQ) begin
        $sformat(s, "%s cc:%0d addr:0x%016h ns:%p attid: 0x%0h owner_val:%p owner_num:%p sharer_vec:0x%04h", s, m_cycle_count, m_addr, m_ns, m_attid,m_owner_val, m_owner_num, m_sharer_vec);
    end

    return(s);
endfunction: convert2string

//**************************************************************
function bit dm_seq_item::is_dm_miss();
	return ((m_owner_val == 0) && (m_owner_num == 0) && (m_sharer_vec == 0));
endfunction:is_dm_miss

//**************************************************************
function bit dm_seq_item::is_owner_present();
	return (m_owner_val == 1);
endfunction:is_owner_present

//**************************************************************
function bit dm_seq_item::are_sharers_present();
	return (m_sharer_vec != 0);
endfunction:are_sharers_present

//**************************************************************
class sys_seq_item extends uvm_sequence_item;

    `uvm_object_param_utils(sys_seq_item);
	
	function new(string name = "sys_seq_item");
   		super.new(name);
	endfunction: new

endclass: sys_seq_item

//**************************************************************





