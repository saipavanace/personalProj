//=============================================================================
// Copyright(C) 2016 Arteris, Inc.
// All rights reserved
//=============================================================================
// DMI Transaction Control Assertions
// Author: Travis Johnson
//=============================================================================
'use strict';
var utils = require('../../../rtl/lib/src/utils.js');

module.exports.init = function dmi_transaction_control_assertions (m) {
    var u = utils.init(m);

    var acd = u.getParam('acd');

    //=========================================================================
    // Interface x Assertions
    //=========================================================================

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Read Int
    //
    u.assert2(acd,
              'assert_transaction_control_read_int_valid_not_X',
              '@(posedge clk) disable iff (~reset_n) ' +
              '!($isunknown(read_int_valid))',
              'Read Int Valid is X');

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Write Int
    //
    u.assert2(acd,
              'assert_transaction_control_write_int_valid_not_X',
              '@(posedge clk) disable iff (~reset_n) ' +
              '!($isunknown(write_int_valid))',
              'Write Int Valid is X');

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Dtr
    //
    u.assert2(acd,
              'assert_transaction_control_dtr_valid_not_X',
              '@(posedge clk) disable iff (~reset_n) ' +
              '!($isunknown(dtr_valid))',
              'Dtr Valid is X');

    u.assert2(acd,
              'assert_transaction_control_dtr_ready_not_X',
              '@(posedge clk) disable iff (~reset_n) ' +
              '!($isunknown(dtr_ready))',
              'Dtr Ready is X');

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Write Address Req
    //
    u.assert2(acd,
              'assert_transaction_control_write_address_req_valid_not_X',
              '@(posedge clk) disable iff (~reset_n) ' +
              '!($isunknown(write_address_req_valid))',
              'Write Address Req Valid is X');

    u.assert2(acd,
              'assert_transaction_control_write_address_req_ready_not_X',
              '@(posedge clk) disable iff (~reset_n) ' +
              '!($isunknown(write_address_req_ready))',
              'Write Address Req Ready is X');

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Write Address Rsp
    //
    u.assert2(acd,
              'assert_transaction_control_write_address_rsp_valid_not_X',
              '@(posedge clk) disable iff (~reset_n) ' +
              '!($isunknown(write_address_rsp_valid))',
              'Write Address Rsp Valid is X');

    u.assert2(acd,
              'assert_transaction_control_write_address_rsp_ready_not_X',
              '@(posedge clk) disable iff (~reset_n) ' +
              '!($isunknown(write_address_rsp_ready))',
              'Write Address Rsp Ready is X');

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Read Req
    //
    u.assert2(acd,
              'assert_transaction_control_read_req_valid_not_X',
              '@(posedge clk) disable iff (~reset_n) ' +
              '!($isunknown(read_req_valid))',
              'Read Req Valid is X');

    u.assert2(acd,
              'assert_transaction_control_read_req_ready_not_X',
              '@(posedge clk) disable iff (~reset_n) ' +
              '!($isunknown(read_req_ready))',
              'Read Req Ready is X');

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Read Rsp
    //
    u.assert2(acd,
              'assert_transaction_control_read_rsp_valid_not_X',
              '@(posedge clk) disable iff (~reset_n) ' +
              '!($isunknown(read_rsp_valid))',
              'Read Rsp Valid is X');

    u.assert2(acd,
              'assert_transaction_control_read_rsp_ready_not_X',
              '@(posedge clk) disable iff (~reset_n) ' +
              '!($isunknown(read_rsp_ready))',
              'Read Rsp Ready is X');


    //=========================================================================
    // Implementation Assertions
    //=========================================================================

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // bypass_control_fifo.push_ready should always be ready when valid
    //
    if (u.getParam('useMemRspIntrlv') === 0) {
        if (!u.getParam('useRttDataEntries')) {
            u.assert2(acd,
                      'assert_transaction_control_bypass_control_fifo_push_ready_when_valid',
                      '@(posedge clk) disable iff (~reset_n) ' +
                      '(bypass_control_fifo.push_valid |-> ' +
                      'bypass_control_fifo.push_ready)',
                      'Bypass Fifo Push Not Ready When Valid');
        }
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // bypass_control_fifo.pop_valid should always be valid when ready
    //
    if (u.getParam('useMemRspIntrlv') === 0) {
        if (!u.getParam('useRttDataEntries')) {
            u.assert2(acd,
                      'assert_transaction_control_bypass_control_fifo_pop_valid_when_ready',
                      '@(posedge clk) disable iff (~reset_n) ' +
                      '(bypass_control_fifo.pop_ready |-> ' +
                      'bypass_control_fifo.pop_valid)',
                      'Bypass Fifo Pop Not Valid When Ready');
        }
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // rtt_control_pipe_fifo.push_ready ASSERT shouldn't backpressure
    //
    if (u.getParam('useRttDataEntries')) {
        u.assert2(acd,
                  'assert_transaction_control_rtt_control_pipe_fifo_push_valid_when_ready',
                  '@(posedge clk) disable iff (~reset_n) ' +
                  '(rtt_control_pipe_fifo.push_valid |-> ' +
                  'rtt_control_pipe_fifo.push_ready)',
                  'RTT Control Pipe Fifo Push Not Ready When Valid');
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // rtt_control_pipe_fifo.pop_valid ASSERT shouldn't backpressure
    //
    if (u.getParam('useRttDataEntries')) {
        u.assert2(acd,
                  'assert_transaction_control_rtt_control_pipe_fifo_pop_valid_when_ready',
                  '@(posedge clk) disable iff (~reset_n) ' +
                  '(rtt_control_pipe_fifo.pop_ready |-> ' +
                  'rtt_control_pipe_fifo.pop_valid)',
                  'RTT Control Pipe Fifo Pop Not Valid When Ready');
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Write Beat Counter Assertions
    //
    if (u.getParam('useRttDataEntries')) {
    }

    // NOTE: wtt_control.valid_vec is high if entry is not valid
    for (var rttEntryIndex = 0; rttEntryIndex < u.getParam('nRttCtrlEntries'); rttEntryIndex++) {
        u.assert2(acd,
                    'assert_transaction_control_rtt_entry' + rttEntryIndex + '_waiting_for_nonvalid_write',
                    '@(posedge clk) disable iff (~reset_n) ' +
                    '((' +
                        'rtt_control.rtt_entry' + rttEntryIndex + '.write_outstanding_o' +
                    ') ? ~(wtt_control.valid_vec[rtt_control.rtt_entry' + rttEntryIndex + '.wtt_id_o])' +
                    ' : 1\'b1)',
                    'RTT Entry ' + rttEntryIndex + ' is waiting for a WTT entry that is not valid');
    }
}
