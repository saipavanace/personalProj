//=============================================================================
// Copyright(C) 2016 Arteris, Inc.
// All rights reserved
//=============================================================================
// DMI RTT Control Assertions
// Author: Travis Johnson
//=============================================================================
'use strict';
var utils = require('../../../rtl/lib/src/utils.js');

module.exports.init = function dmi_rtt_control_assertions (m) {
    var u = utils.init(m);

    var acd = u.getParam('acd');

    //=========================================================================
    // Implementation Assertions
    //=========================================================================

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Onehot Assertions
    //
    u.assert2(acd,
              'assert_rtt_control_allocate0_is_onehot0',
              '@(posedge clk) disable iff (~reset_n) ' +
              '$onehot0(allocate0)',
              'allocate0 Is Not Onehot0');

    if (u.getParam('useCmc')) {
        u.assert2(acd,
                'assert_rtt_control_collision_match_id_onehot0',
                '@(posedge clk) disable iff (~reset_n) ' +
                '$onehot0(collision_match_id)',
                'RTT Control collision_match_id Is Not Onehot0');
    }
}
