//=============================================================================
// Copyright(C) 2016 Arteris, Inc.
// All rights reserved
//=============================================================================
// DMI RTT Entry Assertions
// Author: Travis Johnson
//=============================================================================
'use strict';
var utils = require('../../../rtl/lib/src/utils.js');

module.exports.init = function dmi_rtt_entry_assertions (m) {
    var u = utils.init(m);

    var acd = u.getParam('acd');

    //=========================================================================
    // Implementation Assertions
    //=========================================================================

    // Assert that is valid is low, all flags are low
    if (u.getParam('useCmc')) {
        u.assert2(
            acd,
            'assert_rtt' + u.getParam('entryNum') + '_entry_active_but_not_valid',
            '@(posedge clk) disable iff (~reset_n) ' +
            '~(~valid'
            + ' & (speculative '
                + '| stale '
                + '| read_pending '
                + '| read_outstanding '
                + '| write_outstanding '
                + '| reissue '
                + '| fill_outstanding '
                + '| cmd_pending '
                + '| fill_invalid_pending '
                + '| fill_invalid_outstanding '
                + '| dtr_pending))',
            'RTT Entry ' + u.getParam('entryNum') + ' is active but valid is not asserted'
        );
    }
}
