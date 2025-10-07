//=============================================================================
// Copyright(C) 2016 Arteris, Inc.
// All rights reserved
//=============================================================================
// DMI CCP Interface
// Author: Travis Johnson
//=============================================================================
'use strict';
var utils = require('../../../rtl/lib/src/utils.js');

module.exports.init = function dmi_ccp_ctrl_intf_assertions (m) {
    var u = utils.init(m);

    var acd = u.getParam('acd');

    // Assert that write state must be onehot0
    u.assert2(
        acd,
        'assert_onehot0_write_cache_state',
        '@(posedge clk) disable iff (~reset_n) ' +
        '$onehot0({ccp_st_inv_sel, ccp_st_cln_sel, ccp_st_dty_sel})',
        'CCP Interface is trying to write conflicting states.'
    );

    // Assert that hit way is never in 3rd invalid state
    u.assert2(
        acd,
        'assert_ccp_interface_not_cacheline_not_hit_in_invalid_state',
        '@(posedge clk) disable iff (~reset_n) ' +
        '~((ccp_valid_p2 & ~dmi_ccp.cache_nack_ce_p2) & dmi_ccp__cache_current_state_p2 == 2\'d3)',
        'CCP cacheline is in an invalid state.'
    );

    // If cache p2 is valid, one and only one msg type must be asserted
    u.assert2(
        acd,
        'assert_onehot_msg_type',
        '@(posedge clk) disable iff (~reset_n) ' +
        'ccp_valid_p2 ? $onehot({msg_mrd_rd_cln_p2, ' +
                                'msg_mrd_rd_flush_p2, ' +
                                'msg_mrd_rd_vld_p2, ' +
                                'msg_mrd_rd_inv_p2, ' +
                                'msg_mrd_flush_p2, ' +
                                'msg_dtw_cln_p2, ' +
                                'msg_dtw_ptl_p2, ' +
                                'msg_dtw_dty_p2, ' +
                                'msg_hnt_rd_p2, ' +
                                'msg_csr_inv_p2, ' +
                                'msg_csr_setway_p2, ' +
                                'msg_csr_rd_wr_p2}) ' +
                        ': 1\'b1',
        'CCP output is valid but msg type is not selected.'
    );
}
