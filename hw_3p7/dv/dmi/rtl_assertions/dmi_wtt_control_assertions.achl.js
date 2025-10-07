//=============================================================================
// Copyright(C) 2016 Arteris, Inc.
// All rights reserved
//=============================================================================
// DMI WTT Control Assertions
// Author: Travis Johnson
//=============================================================================
'use strict';
var utils = require('../../../rtl/lib/src/utils.js');

module.exports.init = function dmi_wtt_control_assertions (m) {
    var u = utils.init(m);

    var acd = u.getParam('acd');

    //=========================================================================
    // Implementation Assertions
    //=========================================================================

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Onehot Assertions
    //
    u.assert2(acd,
            'assert_wtt_control_collision_match_id_onehot0',
            '@(posedge clk) disable iff (~reset_n) ' +
            '$onehot0(collision_match_id)',
            'WTT Control collision_match_id Is Not Onehot0');

    if (u.getParam('useCmc')) {
        u.assert2(acd,
              'assert_wtt_control_evict_match_id_onehot0',
              '@(posedge clk) disable iff (~reset_n) ' +
              '$onehot0(evict_collision_id)',
              'WTT Control evict_match_id Is Not Onehot0');
    }
}
