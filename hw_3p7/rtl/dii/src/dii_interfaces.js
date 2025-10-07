//----------------------------------------------------------------------
// Copyright(C) 2017 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------

'use strict';

module.exports = function(params) {


    var log2ceil = function(n) { return Math.ceil(Math.log(n)/Math.LN2); };

      var addr_width      =  64;
//    var nAxiId          =  u.getParam('nAxiId');
//    var nRttEntries     =  u.getParam('nRttEntries');
      var rtt_num_entries =  16;
//    var wtt_num_entries  =  u.getParam('nWttEntries');
      var tid_width       =  10;
      var init_id_width   =  10; 
//    var rtt_id_width    =  log2ceil(rtt_num_entries);
//    var wtt_id_width    =  log2ceil(wtt_num_entries);
//    var axi_id_width    =  log2ceil(nAxiId);
      var axi_id_width    =  4;
      var tt_id_width     =  5;
      var cmd_mpf2_width  =  12;
      var axi_addr_width  =  32;
      var axi_data_width  =  32;
      var arburst_width   =  2;
      var arcache_width   =  1;
      var arlen_width     =  2;
      var arlock_width    =  1;
      var arprot_width    =  2;
      var arregion_width  =  1;
      var aruser_width    =  10;
      var rresp_width     =  10;
      var awburst_width   =  2;
      var awcache_width   =  1;
      var awlen_width     =  2;
      var awlock_width    =  1;
      var awprot_width    =  2;
      var awregion_width  =  1;
      var awuser_width    =  10;
      var wstrb_width     =  8;
      var bresp_width     =  10;
      var read_req_width  =  axi_id_width + addr_width + 3 + 4 + 2; //ID width, add width, size, qos, prot (NS,PR)

var RTT_CTL =  {
             allocate_new_entry : 1,
             addr               : addr_width,
             ordering           : 1,
             ro_depnd_set       : 1,
             eo_depnd_set       : 1,
             axi_depnd_set      : 1,
             ro_match_rd        : 1,
             ro_match_wr        : 1,
             eo_match_rd        : 1,
             eo_match_wr        : 1,
             valid_entries      : rtt_num_entries,
             retire_entry       : rtt_num_entries,
             muxarb_grant       : rtt_num_entries,
             ro_depnd_clear     : rtt_num_entries,
             eo_depnd_clear     : rtt_num_entries,
             axi_depnd_clear    : rtt_num_entries,
             ro_depnd_id_in     : 5,
             eo_depnd_id_in     : 5,
             axi_depnd_id_in    : 5,
             new_axi_id         : axi_id_width,
          }

var RTT_CTL_entry = {
    valid         : 1,
    wr_enable     : 1,
    clear         : 1,
    oldest        : 1,
    youngest_ro   : 1,
    youngest_eo   : 1,
    resp_pending  : 1,
    sleep         : 1,
    addr          : 64,
    ordering      : 2,
    ro_depnd_id   : 5,
    eo_depnd_id   : 5,
    axi_depnd_id  : 5,
            }


var TT_1 =  {
             addr             : addr_width,
             ordering         : 2, 
             attr             : 17,
             size             : 3,
             tof              : 3,
             qos              : 4,
             tid              : tid_width,
             prot             : 3,
             lock             : 3,
             mpf2             : cmd_mpf2_width,
             init_id          : init_id_width
          }

var TT_2 =  {
             allocate_new_entry  : 1,
             ro_depnd_set        : 1,
             eo_depnd_set        : 1,
             axi_depnd_set       : 1,
             ro_depnd_clear      : 1,
             eo_depnd_clear      : 1,
             axi_depnd_clear     : 1,
             ro_match_rd         : 1,
             ro_match_wr         : 1,
             eo_match_rd         : 1,
             eo_match_wr         : 1,
             ro_depnd_id_in      : 5,
             eo_depnd_id_in      : 5,
             axi_depnd_id_in     : 5,
             new_axi_id       : axi_id_width,
          }

var TT_entry_1 = {
    addr          : 64, 
    size          : 3,
    qos           : 4,
    ordering      : 2,
    tid       : 10,
    init_id   : 10,

            }

var TT_entry_2 = {
    valid         : 1,
    wr_enable     : 1,
    clear         : 1,
    oldest        : 1,
    youngest_ro   : 1,
    youngest_eo   : 1,
    resp_pending  : 1,
    sleep         : 1,
    ro_depnd      : 2,
    eo_depnd      : 2,
    axi_depnd     : 2,
    ro_depnd_id   : 5,
    eo_depnd_id   : 5,
    axi_depnd_id  : 5,
    axi_id        : 4,
            }


var TT_entry_dtr = {
    valid         : 1,
    oldest        : 1,
    axi_id        : 4,
    tid       : 10,
    init_id   : 10,
            }

var TT_entry_dtw = {
    valid         : 1,
    oldest        : 1,
    axi_id        : 4,
            }

var AXI_OUT = {
    axi_mst_arvalid   :  1,
    axi_mst_arid      :  axi_id_width,
    axi_mst_araddr    :  axi_addr_width,
    axi_mst_arburst   :  arburst_width,
    axi_mst_arcache   :  arcache_width,
    axi_mst_arlen     :  arlen_width,
    axi_mst_arlock    :  arlock_width,
    axi_mst_arprot    :  arprot_width,
    axi_mst_arqos     :  4,
    axi_mst_arsize    :  3,
    axi_mst_arregion  :  arregion_width,
    axi_mst_aruser    :  aruser_width,
    axi_mst_awvalid   :  1,
    axi_mst_awid      :  axi_id_width,
    axi_mst_awaddr    :  axi_addr_width,
    axi_mst_awburst   :  awburst_width,
    axi_mst_awcache   :  awcache_width,
    axi_mst_awlen     :  awlen_width,
    axi_mst_awlock    :  awlock_width,
    axi_mst_awprot    :  awprot_width,
    axi_mst_awqos     :  4,
    axi_mst_awsize    :  3,
    axi_mst_awregion  :  awregion_width,
    axi_mst_awuser    :  awuser_width,
    axi_mst_rready    :  1,
    axi_mst_wready    :  1,
    axi_mst_bready    :  1
}

var AXI_IN = {
    axi_mst_arready   :  1,
    axi_mst_awready   :  1,
    axi_mst_rid       :  axi_id_width,
    axi_mst_rdata     :  axi_data_width,
    axi_mst_rlast     :  1,
    axi_mst_rresp     :  rresp_width,
    axi_mst_rvalid    :  1,
    axi_mst_ruser     :  aruser_width,
    axi_mst_wid       :  axi_id_width,
    axi_mst_wdata     :  axi_data_width,
    axi_mst_wvalid    :  1,
    axi_mst_wlast     :  1,
    axi_mst_wstrb     :  wstrb_width,
    axi_mst_wuser     :  awuser_width,
    axi_mst_bvalid    :  1,
    axi_mst_bresp     :  bresp_width,
    axi_mst_bid       :  axi_id_width,
    axi_mst_buser     :  awuser_width,
}

var AXI_DTW = {
    axi_mst_wready    :  1,
    axi_mst_wid       :  axi_id_width,
    axi_mst_wdata     :  axi_data_width,
    axi_mst_wvalid    :  1,
    axi_mst_wlast     :  1,
    axi_mst_wstrb     :  wstrb_width
}

return {    
        RTT_CTL  : RTT_CTL,
        RTT_CTL_entry : RTT_CTL_entry,
        TT_1      : TT_1, 
        TT_2      : TT_2,
        TT_entry_1 : TT_entry_1,
        TT_entry_2 : TT_entry_2,
        TT_entry_dtr : TT_entry_dtr,
        AXI_IN  : AXI_IN,
        AXI_OUT  : AXI_OUT,
        }

};

