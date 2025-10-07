//=============================================================================
// Copyright(C) 2016 Arteris, Inc.
// All rights reserved
//=============================================================================
// DMI SFI Master Control Assertions
// Author: Travis Johnson
//=============================================================================
'use strict';
var utils = require('../../../rtl/lib/src/utils.js');

module.exports.init = function dmi_sfi_master_control_assertions (m) {
    var u = utils.init(m);

    var acd = u.getParam('acd');

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Message Type Assertion
    // RTL should only send valid message types
    // on outgoing DTR's
    //
    u.assert2(acd,
              'assert_sfi_master_sfi_mst_req_sfipriv',
              '@(posedge clk) disable iff (~reset_n) ' +
              '(sfi_mst_req_vld |-> ' +
              '((sfi_mst_req_sfipriv[' + (u.getParam('wSfiPrivMsgType') - 1) + ': 0] == DtrDataCln) ' +
              '| (sfi_mst_req_sfipriv[' + (u.getParam('wSfiPrivMsgType') - 1) + ': 0] == DtrDataDty) ' +
              '| (sfi_mst_req_sfipriv[' + (u.getParam('wSfiPrivMsgType') - 1) + ': 0] == DtrDataVis)))',
              'SFI Master Message Type Incorrect');

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Assert that Master interface is never valid
    // when flm is empty
    //
    u.assert2(acd,
              'assert_sfi_master_not_valid_when_no_available_transids',
              '@(posedge clk) disable iff (~reset_n) ' +
              '(sfi_mst_req_vld |-> ' +
              'transid_fifo.pop_valid)',
              'SFI Master Valid When No Available Transids');
}
