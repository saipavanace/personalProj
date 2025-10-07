////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Pipelined base Sequence
//
////////////////////////////////////////////////////////////////////////////////

<% var this_aiu_id = obj.Id; 
if (obj.NctiAgent === 1) {
    this_aiu_id = obj.Id + obj.AiuInfo.length + obj.BridgeAiuInfo.length;
}
%>
<% var found_me      = 0;
   var my_ioaiu_id   = 0;

   for (var idx=0; idx < obj.AiuInfo.length; idx++) {
      if (obj.AiuInfo[idx].fnNativeInterface.indexOf("CHI") < 0) {
         if (obj.Id == idx) {
            found_me = 1;
         } else if (! found_me) {
            my_ioaiu_id ++;
         }   
      }
   }
%>
<% if((obj.Block === 'io_aiu') || (obj.Block === 'aiu') || (obj.Block === 'mem' && obj.is_master === 1)) { %>
class axi_master_pipeline_base_seq extends uvm_sequence #(axi_rd_seq_item);
    
    <% if (obj.testBench == "fsys") { %>
      `uvm_object_utils(ioaiu<%=my_ioaiu_id%>_inhouse_axi_bfm_pkg::axi_master_pipeline_base_seq)
    <% }else {%>
      `uvm_object_param_utils(axi_master_pipeline_base_seq)
    <% } %>

    // Knobs
<% if (((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5")) && !obj.useCache) { %>
    int wt_ace_rdnosnp                         = 5;
    int wt_ace_rdonce                          = 0;
<% } else { %>
`ifdef PSEUDO_SYS_TB
    int wt_ace_rdnosnp                         = 0;
`else
    int wt_ace_rdnosnp                         = 5;
`endif
    int wt_ace_rdonce                          = 5;
<% } %>					  
<% if (obj.fnNativeInterface == "ACE"||obj.fnNativeInterface == "ACE5") { %>    
    int wt_ace_rdshrd                          = 5;
    int wt_ace_rdcln                           = 5;
    int wt_ace_rdnotshrddty                    = 5;
    int wt_ace_rdunq                           = 5;
    int wt_ace_clnunq                          = 5;
    int wt_ace_mkunq                           = 5;
    int wt_ace_dvm_msg                         = 5;
    int wt_ace_dvm_sync                        = 5;
<% }  
else { %>    
    int wt_ace_rdshrd                          = 0;
    int wt_ace_rdcln                           = 0;
    int wt_ace_rdnotshrddty                    = 0;
    int wt_ace_rdunq                           = 0;
    int wt_ace_clnunq                          = 0;
    int wt_ace_mkunq                           = 0;
    int wt_ace_dvm_msg                         = 0;
    int wt_ace_dvm_sync                        = 0;
<% } %>      
    int wt_ace_clnshrd                         = 0;
    int wt_ace_clninvl                         = 0;
    int wt_ace_mkinvl                          = 0;
    int wt_ace_rd_bar                          = 0;
    // FIXME: Fix below weight to be non-zero
<% if (((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5"))  && !obj.useCache) { %>
    int wt_ace_wrnosnp                         = 5;
    int wt_ace_wrunq                           = 0;
    int wt_ace_wrlnunq                         = 0;
<% } else { %>
`ifdef PSEUDO_SYS_TB
    int wt_ace_wrnosnp                         = 0;
`else
    int wt_ace_wrnosnp                         = 5;
`endif
    int wt_ace_wrunq                           = 5; // no notion of WRUNQ with AXI4 but seems just to get cohereerenent region address
    int wt_ace_wrlnunq                         = <%=((obj.fnNativeInterface != "AXI4")&&(obj.fnNativeInterface != "AXI5"))?5:0%>;
<% } %>					  
<% if ((obj.fnNativeInterface == "AXI4") || (obj.fnNativeInterface == "AXI5") ||(obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")) { %>    
    int wt_ace_wrcln                           = 0;
    int wt_ace_wrbk                            = 0;
    int wt_ace_evct                            = 0;
    int wt_ace_wrevct                          = 0;
<% }  
else { %>    
    int wt_ace_wrcln                           = 5;
    int wt_ace_wrbk                            = 5;
    int wt_ace_evct                            = 5;
    int wt_ace_wrevct                          = 5;
<% } %>   
    int num_sets;

    //For data bank selection
     <%if((obj.testBench == "io_aiu" && obj.useCache) && (obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "SECDED" || obj.AiuInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) {%>
     bit[<%=Math.log2(obj.DutInfo.nDataBanks)%>-1:0]             sel_bank;
	<%}%>

<% if(obj.testBench =="io_aiu" && (obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "SECDED" || obj.AiuInfo[obj.Id].cmpInfo.OttErrorType === "PARITY")) { %>
   bit[<%=(Math.log2((obj.DutInfo.nNativeInterfacePorts) * obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks))%>-1:0]sel_ott_bank;
<%}%>
    
    // ACE_LITE_E operations
    int wt_ace_atm_str                         = 0;
    int wt_ace_atm_ld                          = 0;
    int wt_ace_atm_swap                        = 0;
    int wt_ace_atm_comp                        = 0;
    int wt_ace_ptl_stash                       = 0;
    int wt_ace_full_stash                      = 0;
    int wt_ace_shared_stash                    = 0;
    int wt_ace_unq_stash                       = 0;
    int wt_ace_stash_trans                     = 0;
    // FIXME: Fix below weights to be non-zero
    int wt_ace_wr_bar                          = 0;
    int wt_ace_rd_cln_invld  = 0;
    int wt_ace_rd_make_invld = 0;
    int wt_ace_clnshrd_pers  = 0;

    int k_num_read_req                         = 100;
    int k_num_write_req                        = 100;
    int k_num_exclusive_req                    = 0;
    int k_access_boot_region                   = 0;
    bit k_directed_test                        = 0;
    bit k_directed_test_alloc                  = 0;
    bit k_directest_test_addr                  = 0;
    int wt_illegal_op_addr                     = 0;    
    int wt_not_illegal_op_addr   = 0;
    int user_qos;
    int aiu_qos;													   
     // Bit to set if we dont want any updates
    bit no_updates                             = 0;
    <% if (obj.testBench == "fsys") { %>
    ioaiu<%=my_ioaiu_id%>_inhouse_axi_bfm_pkg::mstr_seq_cfg mstr_cfg;
    ioaiu<%=my_ioaiu_id%>_inhouse_axi_bfm_pkg::io_mstr_seq_cfg  cfg;
    int seq_id;
    <% } %>
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string _name = "axi_master_pipeline_base_seq");
    super.new(_name);
endfunction : new

virtual task pre_body();
    super.pre_body();
     <% if (obj.testBench == "fsys") { %>
    `uvm_info(get_full_name(), $psprintf("fn:pre_body Get <%=obj.fnNativeInterface%>_<%=obj.DutInfo.strRtlNamePrefix%>_mstr_seq_cfg_p<%=my_ioaiu_id%>_s%0d from config_db",seq_id), UVM_LOW);

    if (!uvm_config_db #(ioaiu<%=my_ioaiu_id%>_inhouse_axi_bfm_pkg::mstr_seq_cfg)::get(null, get_full_name(), $sformatf("<%=obj.fnNativeInterface%>_<%=obj.DutInfo.strRtlNamePrefix%>_mstr_seq_cfg_p<%=my_ioaiu_id%>_s%0d",seq_id) ,mstr_cfg))

    `uvm_error(get_full_name(), $psprintf("axi_master_pipeline_base_seq: Failed to Get <%=obj.fnNativeInterface%>_<%=obj.DutInfo.strRtlNamePrefix%>_mstr_seq_cfg_p<%=my_ioaiu_id%>_s%0d ",seq_id));
      

    if (!$cast(cfg, mstr_cfg)) begin
      `uvm_error(get_full_name(), $psprintf("fn:pre_body cfg cannot be cast to io_mstr_seq_cfg"));
    end else begin
      `uvm_info(get_full_name(), $psprintf("fn:pre_body io_mstr_seq_cfg- %0s", cfg.print()), UVM_LOW);
    end
    //if ($test$plusargs("en_mst_cfg_inhouse")) begin
    // Knobs
     k_num_read_req                         = cfg.k_num_read_req;
     k_num_write_req                        = cfg.k_num_write_req;
if(cfg.dont_use_cfg_obj_wt_in_mstr_pipelined_seq==0) begin : _dont_use_cfg_wt_in_mstr_pipelined_seq_
     wt_ace_rdnosnp                         = cfg.rdnosnp;
     wt_ace_rdonce                          = cfg.rdonce;
     wt_ace_rdshrd                          = cfg.rdshrd;
     wt_ace_rdcln                           = cfg.rdcln;
     wt_ace_rdnotshrddty                    = cfg.rdnotshrddty;
     wt_ace_rdunq                           = cfg.rdunq;
     wt_ace_clnunq                          = cfg.clnunq;
     wt_ace_mkunq                           = cfg.mkunq;
     wt_ace_dvm_msg                         = cfg.dvmnonsync;
     wt_ace_dvm_sync                        = cfg.dvmsync;
     wt_ace_clnshrd                         = cfg.clnshrd;
     wt_ace_clninvl                         = cfg.clninvld;
     wt_ace_mkinvl                          = cfg.mkinvld;
     wt_ace_wrnosnp                         = cfg.wrnosnp;
     wt_ace_wrunq                           = cfg.wrunq;
     wt_ace_wrlnunq                         = cfg.wrlnunq;
     wt_ace_wrcln                           = cfg.wrcln;
     wt_ace_wrbk                            = cfg.wrbk;
     wt_ace_evct                            = cfg.evct;
     wt_ace_wrevct                          = cfg.wrevct;
     wt_ace_rd_make_invld                   = cfg.rdoncemakeinvld;
     wt_ace_rd_cln_invld                    = cfg.rdonceclinvld;
     wt_ace_clnshrd_pers                    = cfg.clnshardpersist;
     no_updates                             = cfg.no_updates;
     wt_ace_rd_bar                          = cfg.rd_bar;
     wt_ace_ptl_stash                       = cfg.wrunqptlstsh;
     wt_ace_full_stash                      = cfg.wrunqfullstsh;
     wt_ace_shared_stash                    = cfg.stshonceshrd;
     wt_ace_unq_stash                       = cfg.stshonceunq;
     wt_ace_stash_trans                     = cfg.stshtrans;
     wt_ace_atm_str                         = cfg.atmstr;
     wt_ace_atm_ld                          = cfg.atmld;
     wt_ace_atm_swap                        = cfg.atmswp;
     wt_ace_atm_comp                        = cfg.atmcmp;
     //end
     // `uvm_info(get_full_name(), $psprintf("Read and Write txn weights- %0s", sprint()), UVM_LOW);
     // 
end : _dont_use_cfg_wt_in_mstr_pipelined_seq_  
    <% } %>
      
  endtask:pre_body

  virtual task body();
  endtask:body
  function string sprint();
    string s;

    s = $sformatf("RD TXN - k_num_read_req:%0d,wt_ace_rdnosnp:%0d,wt_ace_rdonce:%0d,wt_ace_rdshrd:%0d,wt_ace_rdcln:%0d,wt_ace_rdnotshrddty:%0d,wt_ace_rdunq:%0d,wt_ace_clnunq:%0d,wt_ace_mkunq:%0d,wt_ace_dvm_msg:%0d,wt_ace_dvm_sync:%0d,wt_ace_clnshrd:%0d,wt_ace_clninvl:%0d,wt_ace_mkinvl:%0d,wt_ace_rd_make_invld:%0d,wt_ace_rd_cln_invld:%0d, wt_ace_clnshrd_pers:%0d,no_updates:%0d, wt_ace_rd_bar:%0d", k_num_read_req,wt_ace_rdnosnp,wt_ace_rdonce,wt_ace_rdshrd,wt_ace_rdcln,wt_ace_rdnotshrddty,wt_ace_rdunq,wt_ace_clnunq,wt_ace_mkunq,wt_ace_dvm_msg,wt_ace_dvm_sync,wt_ace_clnshrd,wt_ace_clninvl,wt_ace_mkinvl,wt_ace_rd_make_invld,wt_ace_rd_cln_invld, wt_ace_clnshrd_pers,no_updates, wt_ace_rd_bar);

    s = $sformatf("%0s WR TXN - k_num_write_req:%0d, wt_ace_wrnosnp:%0d,wt_ace_wrunq:%0d ,wt_ace_wrlnunq:%0d, wt_ace_wrcln:%0d, wt_ace_wrbk:%0d, wt_ace_evct:%0d, wt_ace_wrevct:%0d, wt_ace_ptl_stash:%0d,wt_ace_full_stash:%0d, wt_ace_shared_stash:%0d, wt_ace_unq_stash:%0d, wt_ace_stash_trans:%0d, wt_ace_atm_str:%0d, wt_ace_atm_ld:%0d, wt_ace_atm_swap:%0d, wt_ace_atm_comp:%0d ", s,k_num_write_req, wt_ace_wrnosnp,wt_ace_wrunq ,wt_ace_wrlnunq, wt_ace_wrcln, wt_ace_wrbk, wt_ace_evct, wt_ace_wrevct, wt_ace_ptl_stash,wt_ace_full_stash, wt_ace_shared_stash, wt_ace_unq_stash, wt_ace_stash_trans, wt_ace_atm_str, wt_ace_atm_ld, wt_ace_atm_swap, wt_ace_atm_comp);

    return s;
endfunction:sprint
        
endclass:axi_master_pipeline_base_seq
<% } %>
