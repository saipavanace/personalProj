//=============================================================================
// Copyright(C) 2016 Arteris, Inc.
// All rights reserved
//=============================================================================
// DMI SFI Slave Control Assertions
// Author: Travis Johnson
//=============================================================================
'use strict';
var utils = require('../../../rtl/lib/src/utils.js');

module.exports.init = function dmi_sfi_slave_control_assertions (m) {
    var u = utils.init(m);

    var acd = u.getParam('acd');

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Message Type Assertion
    // TB should only send valid message types
    // on incoming MRD's, DTW's, and HNT's
    //
    u.assert2(acd,
              'assert_sfi_slave_msg_type',
              '@(posedge clk) disable iff (~reset_n) ' +
              '(sfi_slv_req_vld |-> ' +
              '((msg_type == DtwDataCln) ' +
              '| (msg_type == DtwDataPtl) ' +
              '| (msg_type == DtwDataDty) ' +
              '| (msg_type == HntRead) ' +
              '| (msg_type == MrdRdCln) ' +
              '| (msg_type == MrdRdVld) ' +
              '| (msg_type == MrdRdInv) ' +
              '| (msg_type == MrdRdFlsh) ' +
              '| (msg_type == MrdFlush)))',
              'SFI Slave Message Type Incorrect');
}
