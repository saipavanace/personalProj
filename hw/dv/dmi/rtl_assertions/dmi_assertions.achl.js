//=============================================================================
// Copyright(C) 2016 Arteris, Inc.
// All rights reserved
//=============================================================================
// DMI Top Level Assertions
// Author: Travis Johnson
//=============================================================================
'use strict';
var utils = require('../../../rtl/lib/src/utils.js');

module.exports.init = function dmi_assertions (m) {
    var u = utils.init(m);

    var acd = u.getParam('acd');

    //=========================================================================
    // In CMC design, cache connot hit while entry exists in WTT or RTT
    //=========================================================================
    if (u.getParam('useCmc')) {

        // RTT
        var rttAssertString;
        for (var entry = 0; entry < u.getParam('nRttCtrlEntries'); entry++) {
            rttAssertString = '';

            // clk and reset
            rttAssertString += '@(posedge clk) disable iff (~reset_n) ';

            // CMC hits
            rttAssertString += '~(dmi_ccp_ctrl_intf.ccp_st_hit_p2 &';

            // But without a correctable error
            rttAssertString += '~dmi_ccp_ctrl_intf.dmi_ccp.cache_nack_ce_p2 &';

            // Each entry is checked for match and valid and ~stale
            rttAssertString += ' (transaction_control.rtt_control.rtt_entry' + entry + '.valid';
            rttAssertString += ' & ~(transaction_control.rtt_control.rtt_entry' + entry + '.stale)';
            rttAssertString += ' & ~(transaction_control.rtt_control.rtt_entry' + entry + '.mrd_type)';
            rttAssertString += ' & ~(transaction_control.rtt_control.rtt_entry' + entry + '.cmd_pending';
            rttAssertString += '     & ~transaction_control.rtt_control.rtt_entry' + entry + '.read_outstanding';
            rttAssertString += '     & ~transaction_control.rtt_control.rtt_entry' + entry + '.dtr_pending';
            rttAssertString += '     & ~transaction_control.rtt_control.rtt_entry' + entry + '.fill_outstanding';
            rttAssertString += ' )';
            rttAssertString += ' & (transaction_control.rtt_control.rtt_entry' + entry + '.address[' + (u.getParam('beatAlignedwAddr') - 1) + ': ' + (u.getParam('wCacheLineOffset') - u.getParam('wByteOffset')) + ']';
            rttAssertString += ' == dmi_ccp_ctrl_intf.replay_queue_addr_p2[' + (u.getParam('wSfiSlaveAddr') - 1) + ': ' + u.getParam('wCacheLineOffset') + '])';
            if (u.getParam('wSfiSecurity') > 0) {
                rttAssertString += ' & (transaction_control.rtt_control.rtt_entry' + entry + '.security';
                rttAssertString += ' == dmi_ccp_ctrl_intf.replay_queue_security_p2)';
            }
            rttAssertString += '))';
            u.assert2(
                acd,
                'assert_address_not_in_rtt_entry' + entry + '_and_cache',
                rttAssertString,
                'Cache hit on entry ' + entry + ' in RTT'
            );
        }

        // WTT
        // Addresses *can* hit in the cache while allocated in WTTs
        // var wttAssertString;
        // for (var entry = 0; entry < u.getParam('nWttCtrlEntries'); entry++) {
        //     wttAssertString = '';

        //     // clk and reset
        //     wttAssertString += '@(posedge clk) disable iff (~reset_n) ';

        //     // CMC hits
        //     wttAssertString += '~(dmi_ccp_ctrl_intf.ccp_st_hit_p2 &';

        //     // Each entry is checked for match and valid
        //     wttAssertString += ' (transaction_control.wtt_control.wtt_entry' + entry + '.valid';
        //     wttAssertString += ' & (transaction_control.wtt_control.wtt_entry' + entry + '.address';
        //     wttAssertString += ' == dmi_ccp_ctrl_intf.replay_queue_addr_p2[' + (u.getParam('wSfiSlaveAddr') - 1) + ': ' + u.getParam('wCacheLineOffset') + '])';
        //     if (u.getParam('wSfiSecurity') > 0) {
        //         wttAssertString += ' & (transaction_control.wtt_control.wtt_entry' + entry + '.security';
        //         wttAssertString += ' == dmi_ccp_ctrl_intf.replay_queue_security_p2)';
        //     }
        //     wttAssertString += '))';
        //     u.assert2(
        //         acd,
        //         'assert_address_not_int_wtt_entry' + entry + '_and_cache',
        //         wttAssertString,
        //         'Cache hit on entry ' + entry + ' in WTT'
        //     );
        // }

        u.assert2(
            acd,
            'assert_read_clean_fifo_not_pushed_when_full',
            '@(posedge clk) disable iff (~reset_n) ' +
            '~(read_clean_fifo.push_valid & ~read_clean_fifo.push_ready)',
            'Read Clean FIFO pushed when full'
        );

        u.assert2(
            acd,
            'assert_read_clean_fifo_not_popped_when_empty',
            '@(posedge clk) disable iff (~reset_n) ' +
            '~(read_clean_fifo.pop_ready & ~read_clean_fifo.pop_valid)',
            'Read Clean FIFO popped when empty'
        );

        u.assert2(
            acd,
            'assert_write_order_fifo_not_pushed_when_full',
            '@(posedge clk) disable iff (~reset_n) ' +
            '~(write_order_fifo.push_valid & ~write_order_fifo.push_ready)',
            'Write Order Fifo pushed when full'
        );
    }
}
