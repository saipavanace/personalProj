//=============================================================================
// Copyright(C) 2016 Arteris, Inc.
// All rights reserved
//=============================================================================
// DMI WTT Entry Assertions
// Author: Travis Johnson
//=============================================================================
'use strict';
var utils = require('../../../rtl/lib/src/utils.js');

module.exports.init = function dmi_wtt_entry_assertions (m) {
    var u = utils.init(m);

    var acd = u.getParam('acd');

    //=========================================================================
    // Implementation Assertions
    //=========================================================================

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Counter cannot exceed max
    //
    u.assert2(
        acd,
        'assert_wtt' + u.getParam('entryNum') + 'counter_greater_than_max',
        '@(posedge clk) disable iff (~reset_n) ' +
        '~(pending_counter > ' + u.getParam('wWttPendingCounter') + '\'d' + u.getParam('maxWttPendingCounter') + ')',
        'WTT Entry ' + u.getParam('entryNum') + ' Pending Counter is greater than its Maximum: ' + u.getParam('maxWttPendingCounter')
    );

    //
    // Address cannot change when entry already valid
    //
    u.assert2(
        acd,
        'assert_wtt' + u.getParam('entryNum') + '_address_same_unless_not_valid',
        '@(posedge clk) disable iff (~reset_n) ' +
        '(((address != $past(address)) & valid_o) ? ~($past(valid_o)) : 1\'b1)',
        'WTT Entry ' + u.getParam('entryNum') + ' address changed when entry is valid'
    );

    //
    // pending_counter should not roll over
    //
    if (u.getParam('maxWttPendingCounter') > 1) {
        u.assert2(
            acd,
            'assert_wtt' + u.getParam('entryNum') + '_pending_counter_should_not_roll_over',
            '@(posedge clk) disable iff (~reset_n) ' +
            '~(($past(pending_counter) == ' + u.getParam('wWttPendingCounter') + '\'d' + u.getParam('maxWttPendingCounter') + ') && (pending_counter == ' + u.getParam('wWttPendingCounter') + '\'b0))',
            'WTT Entry ' + u.getParam('entryNum') + ' Pending Counter rolled over'
        );
    }
}
