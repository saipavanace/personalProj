<% 

var attvec_width = 0;
var total_sf_ways = 0;
var max_sf_set_idx = 0;

obj.DceInfo.forEach(function(bundle) {
    if (bundle.nAttCtrlEntries > attvec_width) {
        attvec_width = bundle.nAttCtrlEntries;
    }
});

obj.SnoopFilterInfo.forEach(function(bundle) {
    if(bundle.fnFilterType === "EXPLICITOWNER") {
        total_sf_ways += bundle.nWays;
        if (bundle.SetSelectInfo.PriSubDiagAddrBits.length > max_sf_set_idx) {
			max_sf_set_idx = bundle.SetSelectInfo.PriSubDiagAddrBits.length;
        }
    }
});

%> 

////////////////////////////////////////////////////////////////////////////////
//
// DCE Probe Interface
// probe interface
////////////////////////////////////////////////////////////////////////////////
interface <%=obj.BlockId%>_probe_if (input clk, input rst_n);

  import <%=obj.BlockId%>_smi_agent_pkg::*;
  import addr_trans_mgr_pkg::*;
  import uvm_pkg::*;
  
  parameter setup_time = 1;
  parameter hold_time  = 1;
  parameter WATTVEC    = <%=attvec_width%>;
  parameter WSFWAYVEC  = <%=total_sf_ways%>;

  //signals needed for QOS testing 
  bit 				  sb_cmdrsp_vld;
  bit 				  sb_cmdrsp_rdy;
  bit [WSMITGTID-1:0] sb_cmdrsp_tgtid;
  bit [WSMIMSGID-1:0] sb_cmdrsp_rmsgid;
  bit				  sb_starv_mode;

  //signals needed to grab output of conc_mux for QOS testing -CONC-7215
  bit 			cmux_cmdreq_vld;
  bit 			cmux_cmdreq_rdy;
  bit [WSMIADDR-1:0] 	cmux_cmdreq_addr;
  bit 			cmux_cmdreq_ns;
  bit [WSMISRCID-1:0]   cmux_cmdreq_iid;
  bit [WSMIMSGTYPE-1:0] cmux_cmdreq_cm_type;
  bit [WSMIMSGID-1:0] 	cmux_cmdreq_msg_id;

  bit 			arb_cmdreq_vld;
  bit 			arb_cmdreq_rdy;
  bit [WSMIADDR-1:0] 	arb_cmdreq_addr;
  bit 			arb_cmdreq_ns;
  bit [WSMISRCID-1:0]   arb_cmdreq_iid;
  bit [WSMIMSGTYPE-1:0] arb_cmdreq_cm_type;
  bit [WSMIMSGID-1:0] 	arb_cmdreq_msg_id;

  // Signals needed to update snoop enable reg
  bit			sb_sysrsp_vld;
  bit			sb_sysrsp_rdy;
  bit [WSMITGTID-1:0] 	sb_sysrsp_tgtid;

  bit [WATTVEC-1:0] attvld_vec;
  logic IRQ_C;
  logic IRQ_UC;
  logic DCEUCESR_ErrVld;
  int cycle_counter;

  // YR: I dont understand guarding the signal definition for the variables!
  //     I would expect these guards to be in place where it gets used if at all
  //     such approach is taken! Removing the guards for now
<% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
  <% for(var i=0;i<item.nWays;i++){ %>
  logic        inject_tag_single_next<%=index%>_<%=i%>;
  logic        inject_tag_double_next<%=index%>_<%=i%>;
  logic        inject_tag_single_double_multi_blk_next<%=index%>_<%=i%>;
  logic        inject_tag_double_multi_blk_next<%=index%>_<%=i%>;
  logic        inject_tag_single_multi_blk_next<%=index%>_<%=i%>;
  logic        inject_tag_addr_next<%=index%>_<%=i%>;
  bit [WSMIADDR-1:0]                         find_cmd_req_addr_secded_err_<%=index%>_<%=i%>[$];
  bit [WSMIADDR-1:0]                         find_prev_cmd_req_addr_secded_err_<%=index%>_<%=i%>[$];
  <% } %>
<% }); %>
  bit [WSMIADDR-1:0]                         cmd_req_addr_secded_err[int];

  int                                        prev_addr_idx;
  bit [WSMIADDR-1:0]                         injected_addr;


  //cmd req interface (dce_dm_0.v)
  bit                                        cmd_req_vld;
  bit                                        cmd_req_rdy;
  bit [WSMIADDR-1:0]                         cmd_req_addr;
  bit                                        cmd_req_ns;
  bit [WSMIMSGTYPE-1:0]                      cmd_req_type;
  bit [WSMISRCID-1:0]                        cmd_req_iid;
  bit [WSMISRCID-1:0]                        cmd_req_sid;
  bit [WATTVEC-1:0]                          cmd_req_att_vec;
  bit                                        cmd_req_wakeup;
  bit [WSFWAYVEC-1:0]                        cmd_req1_busy_vec;
  bit [addrMgrConst::NUM_SF-1:0]             cmd_req1_filter_num;
  bit                                        cmd_req1_alloc;
  bit                                        cmd_req1_cancel;
  bit [WSMIMSGID-1:0]                        cmd_req_msg_id;

  //upd req interface (dce_dm_0.v)
  bit                                        upd_req_vld;
  bit                                        upd_req_rdy;
  bit [WSMIADDR-1:0]                         upd_req_addr;
  bit                                        upd_req_ns;
  bit [WSMISRCID-1:0]                        upd_req_iid;
  bit [1:0]                                  upd_req_status;
  bit                                        upd_req_status_vld;

  //dir rsp interface
  bit                                        cmd_rsp_rdy;
  bit                                        cmd_rsp_vld;
  bit [WATTVEC-1:0]                          cmd_rsp_att_vec;
  bit [WSFWAYVEC:0]                          cmd_rsp_way_vec;
  bit                                        cmd_rsp_owner_val;
  bit [$clog2(addrMgrConst::NUM_CACHES)-1:0] cmd_rsp_owner_num;
  bit [addrMgrConst::NUM_CACHES-1:0]         cmd_rsp_sharer_vec;
  bit [addrMgrConst::NUM_SF-1:0]             cmd_rsp_vbhit_sfvec;
  bit                                        cmd_rsp_wr_required;
  bit                                        cmd_rsp_error;
  
  //recall interface
  bit                                        recall_vld;
  bit                                        recall_rdy;
  bit [WSMIADDR-1:0]                         recall_addr;
  bit                                        recall_ns;
  bit                                        recall_owner_val;
  bit [$clog2(addrMgrConst::NUM_CACHES)-1:0] recall_owner_num;
  bit [addrMgrConst::NUM_CACHES-1:0]         recall_sharer_vec;
  bit [WATTVEC-1:0]                          recall_att_vec;
  
  //write interface
  bit                                        write_rdy;
  bit                                        write_vld;
  bit [WSMIADDR-1:0]                         write_addr;
  bit                                        write_ns;
  bit [WSFWAYVEC-1:0]                        write_way_vec;
  bit                                        write_owner_val;
  bit [$clog2(addrMgrConst::NUM_CACHES)-1:0] write_owner_num;
  bit [addrMgrConst::NUM_CACHES-1:0]         write_sharer_vec;
  bit [addrMgrConst::NUM_CACHES-1:0]         write_change_vec;

  //retry interface
  bit                                        retry_rdy; 
  bit                                        retry_vld; 
  bit [WATTVEC-1:0]                          retry_att_vec; 
  bit [addrMgrConst::NUM_SF-1:0]             retry_filter_vec;
  bit [WSFWAYVEC-1:0]                        retry_way_mask;
  
  bit 				                         dm_mem_init;
  bit 				                         dm_mem_init_delay_1;
  bit [2:0]				                     dm_flush;

  <% if (obj.useResiliency ) { %>
    logic fault_mission_fault;
    logic fault_latent_fault;
    logic [9:0]  cerr_threshold;
    logic [15:0] cerr_counter;
    logic        cerr_over_thres_fault;
  <% } %>

  bit event_in_req; 
  bit event_in_req_dly; 
  bit event_in_ack;
  bit protocol_err;
  bit event_bufferred;	// signal generated within this file
  bit store_pass;
  int prot_timeout_val;
  bit prot_timeout_err;
  bit event_err_valid;

  // Signals for the Error verification
  logic [30:0] timeout_threshold ;
  logic        uedr_timeout_err_det_en;
  logic        uesr_errvld ;
  logic [3:0]  uesr_err_type ;
  logic [15:0] uesr_err_info ;
  logic        ueir_timeout_irq_en ;

  clocking monitor_cb @(negedge clk);

    default input #setup_time output #hold_time;
	
	//sb cmd_rsp signals
	input sb_cmdrsp_vld;
	input sb_cmdrsp_rdy;
	input sb_cmdrsp_tgtid;
	input sb_cmdrsp_rmsgid;
	input sb_starv_mode;
  
	input sb_sysrsp_vld;
	input sb_sysrsp_rdy;
	input sb_sysrsp_tgtid;

  	input cmux_cmdreq_vld;
  	input cmux_cmdreq_rdy;
  	input cmux_cmdreq_addr;
  	input cmux_cmdreq_ns;
  	input cmux_cmdreq_iid;
  	input cmux_cmdreq_cm_type;
  	input cmux_cmdreq_msg_id;

  	input arb_cmdreq_vld;
  	input arb_cmdreq_rdy;
  	input arb_cmdreq_addr;
  	input arb_cmdreq_ns;
  	input arb_cmdreq_iid;
  	input arb_cmdreq_cm_type;
  	input arb_cmdreq_msg_id;

    input  attvld_vec;
    input event_in_req;
    input event_in_ack;
    input event_err_valid;
    //cmd req interface
    input  cmd_req_vld;
    input  cmd_req_rdy;
    input  cmd_req_addr;
    input  cmd_req_ns;
    input  cmd_req_type;
    input  cmd_req_iid;
    input  cmd_req_sid;
    input  cmd_req_att_vec;
    input  cmd_req_wakeup;
    input  cmd_req1_filter_num;
    input  cmd_req1_busy_vec;
    input  cmd_req1_alloc;
    input  cmd_req1_cancel;
    input  cmd_req_msg_id;

    //upd req interface (dce_dm_0.v)
    input  upd_req_vld;
    input  upd_req_rdy;
    input  upd_req_addr;
    input  upd_req_ns;
    input  upd_req_iid;
    input  upd_req_status;
    input  upd_req_status_vld;

  
    //rsp interface
    input  cmd_rsp_rdy;
    input  cmd_rsp_vld;
    input  cmd_rsp_att_vec;
    input  cmd_rsp_way_vec;
    input  cmd_rsp_owner_val;
    input  cmd_rsp_owner_num;
    input  cmd_rsp_sharer_vec;
    //input  cmd_rsp_vhit;//CONC-5362
    input  cmd_rsp_wr_required;
    input  cmd_rsp_vbhit_sfvec;
    input  cmd_rsp_error;

    //recall interface
    input  recall_vld;
    input  recall_rdy;
    input  recall_addr;
    input  recall_ns;
    input  recall_sharer_vec;
    input  recall_owner_val;
    input  recall_owner_num;
    input  recall_att_vec;
  
    //write interface
    input  write_rdy;
    input  write_vld;
    input  write_addr;
    input  write_ns;
    input  write_way_vec;
    input  write_owner_val;
    input  write_owner_num;
    input  write_sharer_vec;
    input  write_change_vec;
  
    //retry interface
    input  retry_rdy; 
    input  retry_vld; 
    input  retry_att_vec; 
    input  retry_filter_vec;
    input  retry_way_mask;
    
    input  dm_mem_init;
    input  dm_flush;

  endclocking : monitor_cb

  modport monitor (

	//sb cmd_rsp signals
	input sb_cmdrsp_vld,
	input sb_cmdrsp_rdy,
	input sb_cmdrsp_tgtid,
	input sb_cmdrsp_rmsgid,
	input sb_starv_mode,
  	
	input sb_sysrsp_vld,
	input sb_sysrsp_rdy,
	input sb_sysrsp_tgtid,

  	input cmux_cmdreq_vld,
  	input cmux_cmdreq_rdy,
  	input cmux_cmdreq_addr,
  	input cmux_cmdreq_ns,
  	input cmux_cmdreq_iid,
  	input cmux_cmdreq_cm_type,
  	input cmux_cmdreq_msg_id,

  	input arb_cmdreq_vld,
  	input arb_cmdreq_rdy,
  	input arb_cmdreq_addr,
  	input arb_cmdreq_ns,
  	input arb_cmdreq_iid,
  	input arb_cmdreq_cm_type,
  	input arb_cmdreq_msg_id,

    input  attvld_vec,
    input event_in_req,
    input event_in_ack,
    input event_err_valid,
    //cmd req interface
    input  cmd_req_vld,
    input  cmd_req_rdy,
    input  cmd_req_addr,
    input  cmd_req_ns,
    input  cmd_req_type,
    input  cmd_req_iid,
    input  cmd_req_sid,
    input  cmd_req_att_vec,
    input  cmd_req_wakeup,
    input  cmd_req1_busy_vec,
    input  cmd_req1_filter_num,
    input  cmd_req1_alloc,
    input  cmd_req1_cancel,
    input  cmd_req_msg_id,

    //upd req interface (dce_dm_0.v)
    input  upd_req_vld,
    input  upd_req_rdy,
    input  upd_req_addr,
    input  upd_req_ns,
    input  upd_req_iid,
    input  upd_req_status,
  
    //rsp interface
    input  cmd_rsp_rdy,
    input  cmd_rsp_vld,
    input  cmd_rsp_att_vec,
    input  cmd_rsp_way_vec,
    input  cmd_rsp_owner_val,
    input  cmd_rsp_owner_num,
    input  cmd_rsp_sharer_vec,
    //input  cmd_rsp_vhit,//CONC-5362
    input  cmd_rsp_wr_required,
    input  cmd_rsp_vbhit_sfvec,
    input  cmd_rsp_error,

    
    //recall interface
    input  recall_vld,
    input  recall_rdy,
    input  recall_addr,
    input  recall_ns,
    input  recall_sharer_vec,
    input  recall_owner_val,
    input  recall_owner_num,
    input  recall_att_vec,
  
    //write interface
    input  write_rdy,
    input  write_vld,
    input  write_addr,
    input  write_ns,
    input  write_way_vec,
    input  write_owner_val,
    input  write_owner_num,
    input  write_sharer_vec,
    input  write_change_vec,
    
    //retry interface
    input  retry_rdy, 
    input  retry_vld, 
    input  retry_att_vec, 
    input  retry_filter_vec,
    input  retry_way_mask,

    input  dm_mem_init,
    input  dm_flush
  );

<% if(obj.testBench=="dce") {%>
<% if (obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true){ %> 
  assign inject_cmd_data_single_next_1 = dut.<%=obj.DceInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_NEXT; 
<% } } %>

<% if(obj.INHOUSE_APB_VIP && obj.assertOn && obj.testBench=="dce") {%>
<% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
  	<%	if (item.TagMem[0].MemType == "NONE") { %>
  <% for(var i=0;i<item.nWays;i++){ %>
  //assign inject_tag_single_next<%=index%>_<%=i%> = dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.INJECT_SINGLE_NEXT;
  //assign inject_tag_double_next<%=index%>_<%=i%> = dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.INJECT_DOUBLE_NEXT;
  //assign inject_tag_single_double_multi_blk_next<%=index%>_<%=i%> = dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
  //assign inject_tag_double_multi_blk_next<%=index%>_<%=i%> = dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.INJECT_DOUBLE_MULTI_BLK_NEXT;
  //assign inject_tag_single_multi_blk_next<%=i%> = dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.INJECT_SINGLE_MULTI_BLK_NEXT;
  assign inject_tag_single_next<%=index%>_<%=i%> = dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_NEXT;
  assign inject_tag_double_next<%=index%>_<%=i%> = dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_NEXT;
  assign inject_tag_single_double_multi_blk_next<%=index%>_<%=i%> = dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
  assign inject_tag_double_multi_blk_next<%=index%>_<%=i%> = dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_MULTI_BLK_NEXT;
  assign inject_tag_single_multi_blk_next<%=i%> = dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_MULTI_BLK_NEXT;
  assign inject_tag_addr_next<%=index%>_<%=i%> = dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_ADDR_NEXT;
  
  <% } %>
  <% } %>

  	<%	if (item.TagMem[0].MemType == "SYNOPSYS") { %>
  <% for(var i=0;i<item.nWays;i++){ %>
  //assign inject_tag_single_next<%=index%>_<%=i%> = dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.INJECT_SINGLE_NEXT;
  //assign inject_tag_double_next<%=index%>_<%=i%> = dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.INJECT_DOUBLE_NEXT;
  //assign inject_tag_single_double_multi_blk_next<%=index%>_<%=i%> = dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
  //assign inject_tag_double_multi_blk_next<%=index%>_<%=i%> = dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.INJECT_DOUBLE_MULTI_BLK_NEXT;
  //assign inject_tag_single_multi_blk_next<%=i%> = dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.INJECT_SINGLE_MULTI_BLK_NEXT;
  assign inject_tag_single_next<%=index%>_<%=i%> = dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_NEXT;
  assign inject_tag_double_next<%=index%>_<%=i%> = dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_DOUBLE_NEXT;
  assign inject_tag_single_double_multi_blk_next<%=index%>_<%=i%> = dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
  assign inject_tag_double_multi_blk_next<%=index%>_<%=i%> = dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_DOUBLE_MULTI_BLK_NEXT;
  assign inject_tag_single_multi_blk_next<%=i%> = dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_MULTI_BLK_NEXT;
  assign inject_tag_addr_next<%=index%>_<%=i%> = dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_ADDR_NEXT;
  <% } %>
  <% } %>
<% }); %>
  <%
  var ASILB = 0; // (obj.useResiliency & obj.enableUnitDuplication) ? 0 : 1;
  var hier_path_dce_csr  = '';
  if (!ASILB) {
    hier_path_dce_csr = 'dce_func_unit.u_csr';
  } else {
    hier_path_dce_csr = 'u_csr';
  }
  %>
  assign DCEUCESR_ErrVld 	  = dut.<%=hier_path_dce_csr%>.DCEUCESR_ErrVld_out;
<% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
  	<%	if (item.TagMem[0].MemType == "NONE") { %>
  <% for(var i=0;i<item.nWays;i++){ %>
always @(negedge clk) begin
//CONC-16188: Kavish added code to extract cmd_req_addr 1 previous cycle.
//This change is required when SRAMInputFlop=1 since the memory write cycle is now moved to P0plus cycle in this 3.7 update
//The memory error injection done in dce_tb_top happens at P0 cycle of a valid cmd_req, but RTL injects error in the same clock cyles' POplus address (valid cmd_req_addr 1 cycle before) as that is the memory write-cycle
//Because of this, the TB needs to capture the cmd_req_addr happened once cycle before INJECT_SINGLE_NEXT||INJECT_DOUBLE_NEXT goes high.
  if (cmd_req_vld === 1 && cmd_req_rdy === 1) begin
    find_prev_cmd_req_addr_secded_err_<%=index%>_<%=i%>.push_back(cmd_req_addr);
  end
  if ((dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_ADDR_NEXT === 1 || dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_NEXT === 1 || dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_NEXT === 1) && dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.write_enable === 0 && dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.chip_enable === 1) begin
    if (cmd_req_vld === 1 && cmd_req_rdy === 1) begin
        prev_addr_idx = find_prev_cmd_req_addr_secded_err_<%=index%>_<%=i%>.size()-2;
    end else begin //CONC-16401-The cmd_req_addr in P0plus is one cycle before the chip_enable goes high & INJECT_SINGLE_NEXT goes high. This else condition is when cmd_req_rdy & vld may not be high at that instance but it assumes it would have been high a cycle before, so we now need to pop the last cmd_req_addr instead of second last.
        prev_addr_idx = find_prev_cmd_req_addr_secded_err_<%=index%>_<%=i%>.size()-1;
    end
    injected_addr = find_prev_cmd_req_addr_secded_err_<%=index%>_<%=i%>[prev_addr_idx];
    <% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
    find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.push_back(injected_addr);
    <% } else { %>
    find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.push_back(cmd_req_addr);
    <% }%>
  end
end
  <% } %>
  <% } %>

  	<%	if (item.TagMem[0].MemType == "SYNOPSYS") { %>
  <% for(var i=0;i<item.nWays;i++){ %>
always @(negedge clk) begin
    //CONC-16188: Kavish added code to extract cmd_req_addr 1 previous cycle.
    //This change is required when SRAMInputFlop=1 since the memory write cycle is now moved to P0plus cycle in this 3.7 update
    //The memory error injection done in dce_tb_top happens at P0 cycle of a valid cmd_req, but RTL injects error in the same clock cyles' POplus address (valid cmd_req_addr 1 cycle before) as that is the memory write-cycle
    //Because of this, the TB needs to capture the cmd_req_addr happened once cycle before INJECT_SINGLE_NEXT||INJECT_DOUBLE_NEXT goes high.
   if (cmd_req_vld === 1 && cmd_req_rdy === 1) begin
    find_prev_cmd_req_addr_secded_err_<%=index%>_<%=i%>.push_back(cmd_req_addr);
  end
 if ((dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_NEXT === 1 || dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_DOUBLE_NEXT === 1) && dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.write_enable === 0 && dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.chip_enable === 1) begin
    if (cmd_req_vld === 1 && cmd_req_rdy === 1) begin
        prev_addr_idx = find_prev_cmd_req_addr_secded_err_<%=index%>_<%=i%>.size()-2;
    end else begin //CONC-16401-The cmd_req_addr in P0plus is one cycle before the chip_enable goes high & INJECT_SINGLE_NEXT goes high. This else condition is when cmd_req_rdy & vld may not be high at that instance but it assumes it would have been high a cycle before, so we now need to pop the last cmd_req_addr instead of second last.
        prev_addr_idx = find_prev_cmd_req_addr_secded_err_<%=index%>_<%=i%>.size()-1;
    end
    injected_addr = find_prev_cmd_req_addr_secded_err_<%=index%>_<%=i%>[prev_addr_idx];
    <% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
    find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.push_back(injected_addr);
    <% } else { %>
    find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.push_back(cmd_req_addr);
    <% }%>
  end
end
  <% } %>
  <% } %>
<% }); %>
<% } %>

initial begin
	cycle_counter 	 <= 0;
	event_bufferred  <= 0;
   	forever begin
        @(monitor_cb)
        cycle_counter 		<= cycle_counter + 1;
        dm_mem_init_delay_1 <= dm_mem_init;
	end
end

function longint get_cycle_count();
	return cycle_counter;
endfunction: get_cycle_count

//----------------------------------------------------------------------- 
// Assertions and Cover-Property for DM interface 
//-----------------------------------------------------------------------

property dm_req_rsp_accepted_same_cycle_by_tm (vld, rdy);
   @(posedge clk) disable iff(!rst_n)
   vld |-> rdy;
endproperty

//#Check.DCE.dm_cmdrsp_accept
ASSERT_<%=obj.BlockId%>_dm_cmd_rsp_accepted_same_cycle_by_tm  : assert property(dm_req_rsp_accepted_same_cycle_by_tm(cmd_rsp_vld,  cmd_rsp_rdy)) 
else `ASSERT_ERROR("ERROR","\n ASSERT_<%=obj.BlockId%>_dm_cmd_rsp_accepted_same_cycle_by_tm: Assertion failed : dm_cmd_rsp was not immediately accepted by TM");

//CONC-15610: DM-RETRY Interafce can have backpressure
////#Check.DCE.dm_rtyreq_accept
//ASSERT_<%=obj.BlockId%>_dm_rty_req_accepted_same_cycle_by_tm  : assert property(dm_req_rsp_accepted_same_cycle_by_tm(retry_vld,  retry_rdy)) 
//else `ASSERT_ERROR("ERROR","\n ASSERT_<%=obj.BlockId%>_dm_rty_req_accepted_same_cycle_by_tm: Assertion failed : dm_rty_req was not immediately accepted by TM");

property req_vld2rdy (vld, rdy);
   @(posedge clk) disable iff(!rst_n)
   $rose(vld && !rdy) |=> $stable(vld) throughout (!rdy[*0:$] ##[0:1] $rose(rdy));
endproperty

//#Check.DCE.dm_validStableUntilReady
ASSERT_dm_cmd_req  : assert property(req_vld2rdy(cmd_req_vld,  cmd_req_rdy)) else `ASSERT_ERROR("ERROR","\n ASSERT_dm_cmd_req : Assertion failed : valid was not stable until ready");
ASSERT_dm_cmd_rsp  : assert property(req_vld2rdy(cmd_rsp_vld,  cmd_rsp_rdy)) else `ASSERT_ERROR("ERROR","\n ASSERT_dm_cmd_rsp : Assertion failed : valid was not stable until ready");
ASSERT_dm_upd_req  : assert property(req_vld2rdy(upd_req_vld,  upd_req_rdy)) else `ASSERT_ERROR("ERROR","\n ASSERT_dm_upd_req : Assertion failed : valid was not stable until ready");
ASSERT_dm_wr_req   : assert property(req_vld2rdy(write_vld,    write_rdy)) else `ASSERT_ERROR("ERROR","\n ASSERT_dm_wr_req : Assertion failed : valid was not stable until ready");
ASSERT_dm_rec_req  : assert property(req_vld2rdy(recall_vld,   recall_rdy)) else `ASSERT_ERROR("ERROR","\n ASSERT_dm_rec_req : Assertion failed : valid was not stable until ready");
ASSERT_dm_rty_req  : assert property(req_vld2rdy(retry_vld,    retry_rdy)) else `ASSERT_ERROR("ERROR","\n ASSERT_dm_rty_req : Assertion failed : valid was not stable until ready");

property dm_accept_priority_order (req1_vld, req1_rdy, req2_vld, req2_rdy);
   @(posedge clk) disable iff(!rst_n)
   (req1_vld && req2_vld) |-> (req1_vld && req1_rdy && !req2_rdy)[*1:$] ##1 (req2_vld && req2_rdy && !(req1_vld && req1_rdy));
endproperty

//coverproperties for dm_acceptance priority
//#Cover.DCE.dm_wrreq_updreq_priority
COVER_dm_accept_priority_order_wr_upd : cover property(dm_accept_priority_order(write_vld, write_rdy, upd_req_vld, upd_req_rdy)); 

//cmd_req_vld will not be high when cmd_req_rdy is low reason is stated below in cmdreq_backpressure section.
//#Cover.DCE.dm_wrreq_cmdreq_priority
//COVER_dm_accept_priority_order_wr_cmd : cover property(dm_accept_priority_order(write_vld, write_rdy, cmd_req_vld, cmd_req_rdy)); 

//#Cover.DCE.dm_updreq_cmdreq_priority
//COVER_dm_accept_priority_order_upd_cmd: cover property(dm_accept_priority_order(upd_req_vld, upd_req_rdy, cmd_req_vld, cmd_req_rdy)); 

property dm_req_same_cycle (req1_vld,req1_rdy,req2_vld,req2_rdy);
   @(posedge clk) disable iff(!rst_n)
   req1_vld |-> (req1_vld && req1_rdy && req2_vld && req2_rdy);
endproperty

//#Cover.DCE.dm_recall_lkprsp_same_cycle
COVER_dm_recall_lkprsp_same_cycle: cover property(dm_req_same_cycle(recall_vld,recall_rdy,cmd_rsp_vld,cmd_rsp_rdy));
//#Cover.DCE.dm_recall_retry_same_cycle
COVER_dm_recall_retry_same_cycle: cover property(dm_req_same_cycle(recall_vld,recall_rdy,retry_vld,retry_rdy));

property dm_cmt_back_back (req_vld,req_rdy);
   @(negedge clk) disable iff(!rst_n || dm_mem_init || dm_flush)
   req_vld |-> (req_vld && req_rdy && $past((req_vld && req_rdy),1) && $past((req_vld && req_rdy),2));
endproperty

COVER_dm_cmt_back_back: cover property(dm_cmt_back_back(write_vld,write_rdy));

property dm_input_backpressure (req_vld, req_rdy, num_cycles);
   @(posedge clk) disable iff(!rst_n)
   req_vld |-> (req_vld && !req_rdy)[*num_cycles];
endproperty

//coverproperties for dm_input_backpressure
//#Cover.DCE.dm_cmdreq_backpressure 	cmdreq_backpressure has been removed because cmd_req_vld can be high only when cmd_req_rdy is high, the reason for this is when cmd_req_rdy is low the intake handler will pull req_valid signal low.
//COVER_dm_input_backpressure_cmdreq_2cyc: cover property(dm_input_backpressure(cmd_req_vld, cmd_req_rdy, 2)); 
//COVER_dm_input_backpressure_cmdreq_3cyc: cover property(dm_input_backpressure(cmd_req_vld, cmd_req_rdy, 3)); 
//COVER_dm_input_backpressure_cmdreq_4cyc: cover property(dm_input_backpressure(cmd_req_vld, cmd_req_rdy, 4)); 

//#Cover.DCE.dm_updreq_backpressure
COVER_dm_input_backpressure_updreq_2cyc: cover property(dm_input_backpressure(upd_req_vld, upd_req_rdy, 2)); 
COVER_dm_input_backpressure_updreq_3cyc: cover property(dm_input_backpressure(upd_req_vld, upd_req_rdy, 3)); 
COVER_dm_input_backpressure_updreq_4cyc: cover property(dm_input_backpressure(upd_req_vld, upd_req_rdy, 4)); 

//#Cover.DCE.dm_writereq_backpressure
COVER_dm_input_backpressure_wrreq_2cyc: cover property(dm_input_backpressure(write_vld, write_rdy, 2));
<% if(obj.SnoopFilterInfo[0].TagFilterErrorInfo.fnErrDetectCorrect == "SECDED"){ %> // Only configs with SECDED type can have write_backpressure of more than 2 cycles because DM require 1 extra cycle to correct error.
COVER_dm_input_backpressure_wrreq_3cyc: cover property(dm_input_backpressure(write_vld, write_rdy, 3)); 
COVER_dm_input_backpressure_wrreq_4cyc: cover property(dm_input_backpressure(write_vld, write_rdy, 4)); 
<%}


if(obj.SnoopFilterInfo[0].TagFilterErrorInfo.fnErrDetectCorrect != "SECDED"){ %> // If config is not SECDED type SF write cannot be backpressured more than 2 cycles.
property dm_write_valid_ready (req_vld, req_rdy);
   @(posedge clk) disable iff(!rst_n)
   req_vld |-> ##[0:2] (req_vld && req_rdy);
endproperty

ASSERT_dm_write_valid_ready: assert property(dm_write_valid_ready(write_vld, write_rdy)) else `ASSERT_ERROR("ERROR","\n ASSERT_dm_write_valid_ready : Assertion failed : write ready not high after 2 cycles (check)"); 
<%}%>

property dm_cmd_req_valid_ready (req_vld, req_rdy);
   @(posedge clk) disable iff(!rst_n)
   req_vld |-> req_rdy;
endproperty

ASSERT_dm_cmd_req_valid_ready : assert property(dm_cmd_req_valid_ready(cmd_req_vld, cmd_req_rdy)) else  `ASSERT_ERROR("ERROR","\n ASSERT_dm_cmd_req_valid_ready : Assertion failed : DM_CMD_REQ Valid is high when ready is low");
	

//wrreq should be accepted by DM provided it is not in middle of a UPDreq
<% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
property dm_wrreq_accept;
   @(negedge clk) disable iff(!rst_n || dm_mem_init || dm_flush || $test$plusargs("error_test"))
   (write_vld && ($past((upd_req_vld && upd_req_rdy), 1) == 0) && ($past((upd_req_vld && upd_req_rdy), 2) == 0) && ($past((upd_req_vld && upd_req_rdy), 3) == 0)) |-> write_rdy;
endproperty
<%} else { %>
property dm_wrreq_accept;
   @(negedge clk) disable iff(!rst_n || dm_mem_init || dm_flush || $test$plusargs("error_test"))
   (write_vld && ($past((upd_req_vld && upd_req_rdy), 1) == 0) && ($past((upd_req_vld && upd_req_rdy), 2) == 0)) |-> write_rdy;
endproperty
<% } %>

//#Check.DCE.dm_wrreq_accept
ASSERT_<%=obj.BlockId%>_dm_write_accept: assert property(dm_wrreq_accept) else `ASSERT_ERROR("ERROR", "ASSERT_<%=obj.BlockId%>_dm_write_accept : Assertion failed : dm_wrreq was not accepted by DM the cycle it was presented") ;

//updreq should be accepted by DM provided it is not in middle of a UPDreq or wrreq
//this assertion can be excluded for error tests since pipeline is stalled for few cycles while error is being corrected.
<% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
property dm_updreq_accept;
   @(negedge clk) disable iff(!rst_n || dm_mem_init || dm_flush || $test$plusargs("error_test"))
   (upd_req_vld && !write_vld && ($past((upd_req_vld && upd_req_rdy), 1) == 0) && ($past((upd_req_vld && upd_req_rdy), 2) == 0) && ($past((upd_req_vld && upd_req_rdy), 3) == 0)) |-> upd_req_rdy;
endproperty
<%} else { %>
property dm_updreq_accept;
   @(negedge clk) disable iff(!rst_n || dm_mem_init || dm_flush || $test$plusargs("error_test"))
   (upd_req_vld && !write_vld && ($past((upd_req_vld && upd_req_rdy), 1) == 0) && ($past((upd_req_vld && upd_req_rdy), 2) == 0)) |-> upd_req_rdy;
endproperty
<% } %>

//#Check.DCE.dm_updreq_accept
ASSERT_<%=obj.BlockId%>_dm_updreq_accept: assert property(dm_updreq_accept) else `ASSERT_ERROR("ERROR","ASSERT_<%=obj.BlockId%>_dm_updreq_accept : Assertion failed : dm_updreq was not accepted by DM the cycle it was presented") ;

//cmdreq should be accepted by DM provided it is not in middle of a UPDreq or wrreq
//#Check.DCE.dm_cmdreq_accept
<% if(obj.DceInfo[obj.Id].useSramInputFlop) { %>
<%} else { %>
<% } %>
property dm_cmdreq_accept;
   @(negedge clk) disable iff(!rst_n || dm_mem_init || dm_flush)
   (cmd_req_vld && !write_vld && !upd_req_vld && ($past((upd_req_vld && upd_req_rdy), 1) == 0) && ($past((upd_req_vld && upd_req_rdy), 2) == 0)) |-> cmd_req_rdy;
endproperty

//#Check.DCE.dm_wrreq_accept
ASSERT_<%=obj.BlockId%>_dm_cmdreq_accept: assert property(dm_cmdreq_accept) else `ASSERT_ERROR("ERROR","ASSERT_<%=obj.BlockId%>_dm_cmdreq_accept : Assertion failed : dm_cmdreq was not accepted by DM the cycle it was presented") ;

	////////////////////////////////////////////////////////
	// modelling the event message buffer using assertions//
	////////////////////////////////////////////////////////

	// combine all store passes during active handshake into a single event_bufferred signal
	//always @(posedge store_pass) begin
	//	if(event_in_req_dly) begin
	//		event_bufferred = 1;
	//	end
	//end
	always @(posedge clk) begin
		if(event_in_req_dly && store_pass) begin
			event_bufferred = 1;
			@(negedge event_in_ack);
			event_bufferred = 0;
		end
	end

	// use delayed version of event_in_req
	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			event_in_req_dly <= 0;
		end else begin
			event_in_req_dly <= event_in_req;
		end
	end
	
	// reset the event_bufferred when ack arrives
	always @(posedge event_in_ack) begin
		event_bufferred = 0;
	end

	// sequence to model dynamic delay
  	sequence dynamic_delay(count);
 		int v;
 		(1, v=count) ##0 first_match((1, v=v-1'b1) [*0:$] ##1 v<=0);
  	endsequence

	//make sure when store_pass is asserted, event_in_req is always high in the same cycle
	property p_store_pass_to_req_gen;
		@(posedge clk) disable iff(!rst_n)
		$rose(store_pass) |-> event_in_req;
	endproperty : p_store_pass_to_req_gen

	// make sure after event_in_req, event_in_ack arrives within protocol_threshold_value
	// if event_in_ack arrives before threshold, it is all fine.
	// FIXME : need to disable if there is a protocol error
	property p_ev_msg_req_ack;
   		@(posedge clk) disable iff(!rst_n || event_in_ack)
   		event_in_req |-> dynamic_delay(prot_timeout_val) ##0 (event_in_ack && prot_timeout_err);
	endproperty : p_ev_msg_req_ack

	property p_req_due_to_bufferred_events;
		@(posedge clk) disable iff(!rst_n)
		$fell(event_bufferred) |-> ##[0:3] $rose(event_in_req);
	endproperty : p_req_due_to_bufferred_events

	ASSERT_<%=obj.BlockId%>_req_due_to_bufferred_events : assert property(p_req_due_to_bufferred_events)
	else `ASSERT_ERROR("ERROR","\n ASSERT_<%=obj.BlockId%>_req_due_to_bufferred_events : Assertion failed : bufferred event did not generate proper event handshake");
	
<% if(obj.testBench=="dce") {%>
task inject_double_error(); 

<% if (obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>   
  dut.<%=obj.DceInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_double_error() ; 
<% } %>    

endtask: inject_double_error

task inject_single_error(); 

<% if (obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>
  dut.<%=obj.DceInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
<% } %>  

endtask: inject_single_error


task inject_addr_error(); 

<%if(obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>
  dut.<%=obj.DceInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.init_addr_error(100);
  dut.<%=obj.DceInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
<%}%>

endtask: inject_addr_error
<% } %>

endinterface : <%=obj.BlockId%>_probe_if
