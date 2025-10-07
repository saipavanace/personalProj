////////////////////////////////////////////////////////////////////////////////
//
// Author       : Neha F
// Purpose      : This class stores data, cache state, etc status of a cacheline addr.
// Description  : Memory consistency checker will use an associative array of this 
//                class to create a DV memory model to run checks on.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Below code is copied from concerto_env.svh file to be able to use
//_child_blkid for loops
////////////////////////////////////////////////////////////////////////////////
//
// concerto_env 
<% if (1 == 0) { %>
// Author: Satya Prakash
<% } %>
//
////////////////////////////////////////////////////////////////////////////////


<%
//Embedded javascript code to figure number of blocks
   var _child_blkid      = [];
   var _child_blk        = [];
   var pidx              = 0;
   var ridx              = 0;
   var qidx              = 0;
   var idx               = 0;
   var j                 = 0;
   var num_chi_aiu_tx_if = 0;
   var num_io_aiu_tx_if  = 0;
   var num_dmi_tx_if     = 0;
   var num_dii_tx_if     = 0;
   var num_dce_tx_if     = 0;
   var num_dve_tx_if     = 0;
   var num_chi_aiu_rx_if = 0;
   var num_io_aiu_rx_if  = 0;
   var num_dmi_rx_if     = 0;
   var num_dii_rx_if     = 0;
   var num_dce_rx_if     = 0;
   var num_dve_rx_if     = 0;
   var initiatorAgents   = obj.AiuInfo.length ;
   var numChiAiu         = 0;
   var numIoAiu          = 0;
   var aiu_NumCores = [];

   for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
     if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
         aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
     } else {
         aiu_NumCores[pidx]    = 1;
     }
   }
   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       num_chi_aiu_tx_if = obj.AiuInfo[pidx].smiPortParams.tx.length;
       num_chi_aiu_rx_if = obj.AiuInfo[pidx].smiPortParams.rx.length;
       numChiAiu = numChiAiu + 1;
       idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + qidx;
       _child_blk[pidx]   = 'ioaiu';
       num_io_aiu_tx_if = obj.AiuInfo[pidx].smiPortParams.tx.length;
       num_io_aiu_rx_if = obj.AiuInfo[pidx].smiPortParams.rx.length;
       numIoAiu = numIoAiu + 1;
       qidx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
       num_dce_tx_if = obj.DceInfo[pidx].smiPortParams.tx.length;
       num_dce_rx_if = obj.DceInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
       num_dmi_tx_if = obj.DmiInfo[pidx].smiPortParams.tx.length;
       num_dmi_rx_if = obj.DmiInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
       num_dii_tx_if = obj.DiiInfo[pidx].smiPortParams.tx.length;
       num_dii_rx_if = obj.DiiInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
       num_dve_tx_if = obj.DveInfo[pidx].smiPortParams.tx.length;
       num_dve_rx_if = obj.DveInfo[pidx].smiPortParams.rx.length;
   }
%>


////////////////////////////////////////////////////////////////////////////////
// Addr_status class code starts here
////////////////////////////////////////////////////////////////////////////////
import uvm_pkg::*;
`include "uvm_macros.svh"

`undef LABEL
`define  LABEL "addr_status"

class addr_status extends uvm_object;

   `uvm_object_param_utils(addr_status)

   logic[64:0]          cacheline_addr;
   // 1: coherent addr, 0: non-coherent addr
   logic                coh_addr;
   // 1: non-secure addr, 0: secure addr
   logic                ns_addr;
   cache_data_t         current_data;
   cache_byte_en_t      current_be;
   outstanding_data_s   uncommitted_txn_q[$];
   outstanding_data_s   committed_waiting_slave_if_txn_q[$];
   logic                consistency_violated;
   //Index = {funit_id[7:0],core_id[2:0]}
   cache_state_t        cache_info_q[int];
   cacheline_location_t location;
   // Save data seen at slave i/f that didn't match any native data (IOAIU long multiline txns)
   cache_data_t         slave_data_waiting_native_data[$];
   cache_byte_en_t      slave_data_waiting_native_byte_en[$];
   bit                  slave_data_waiting_native_cache_unit[$];
   time                 current_data_commit_time;

   extern function new(string name = "addr_status");
   extern function void initialize(logic[64:0] addr, outstanding_data_s data, cache_state_t state=IX, logic ns_addr, logic coh_addr, bit data_val=1);
   extern function void update_curr_data(cache_data_t data, cache_byte_en_t byte_en);
   extern function void add_pending_data(outstanding_data_s data);
   extern function void update_cache_state(cache_state_t state=IX, int unit_id);
   extern function void commit_pending_data(outstanding_data_s data, bit cached=0, output outstanding_data_s out_data);
   extern function void compare_read_data(cache_data_t data, cache_byte_en_t byte_en);
   extern function bit compare_slave_if_out_data(cache_data_t data, cache_byte_en_t byte_en, bit cache_unit=0, bit possible_eviction=0, bit save_if_unmatched=0, bit no_error=0);
   extern function void compare_cache_state(cache_state_t state=IX, int unit_id);
   extern function void update_location(cacheline_location_t new_location);
   extern function void print_memory();
   extern function bit compare_native_if_out_data(cache_data_t data, cache_byte_en_t byte_en);
   extern function bit match_current_data(cache_data_t data, cache_byte_en_t byte_en);

endclass : addr_status

function addr_status::new(string name = "addr_status");
endfunction : new

////////////////////////////////////////////////////////////////////////////////
// Function: initialize()
////////////////////////////////////////////////////////////////////////////////
function void addr_status::initialize(logic[64:0] addr, outstanding_data_s data, cache_state_t state=IX, logic ns_addr, logic coh_addr, bit data_val=1);
   this.cacheline_addr = addr;
   if (data_val == 1) begin
      this.uncommitted_txn_q.push_back(data);
      `uvm_info(`LABEL, $psprintf(
         "initialize[0x%0h]: Add to uncommitted_txn_q: Data:0x%0h, Byte_en:0x%0h"
         ,addr, data.data, data.byte_en), UVM_MEDIUM)
      foreach (slave_data_waiting_native_data[idx]) begin
         if(compare_slave_if_out_data(slave_data_waiting_native_data[idx], slave_data_waiting_native_byte_en[idx], slave_data_waiting_native_cache_unit[idx], 0, 0, 1)) begin
            slave_data_waiting_native_data.delete(idx);
            slave_data_waiting_native_byte_en.delete(idx);
            slave_data_waiting_native_cache_unit.delete(idx);
            break;
         end
      end
   end
   this.cache_info_q[{data.funit_id[7:0],data.core_id[2:0]}] = state;
   this.consistency_violated = (coh_addr == 1 && (coh_addr == data.coh)) ? 0 : 1;
   this.ns_addr = ns_addr;
   this.coh_addr = coh_addr;
   this.current_data = 'bx;
   this.location = MEMORY; // default
endfunction : initialize

////////////////////////////////////////////////////////////////////////////////
// Function: update_curr_data()
////////////////////////////////////////////////////////////////////////////////
function void addr_status::update_curr_data(cache_data_t data, cache_byte_en_t byte_en);
   int w_byte_en = (2 ** <%=obj.wCacheLineOffset%>);
   for (int idx=0; idx < w_byte_en; idx++) begin
      if (byte_en[idx]) begin
         this.current_data[8*idx +: 8]  = data[8*idx +: 8];
         this.current_be[idx] = byte_en[idx];
      end // if byte en == 1
   end // byte enable for loop
   current_data_commit_time = $time;
   `uvm_info(`LABEL, $psprintf(
      "update_curr_data[0x%0h]: DATA: 0x%0h, BE=0x%0h", 
      cacheline_addr, current_data, current_be), UVM_LOW);
endfunction : update_curr_data

////////////////////////////////////////////////////////////////////////////////
// Function: add_pending_data()
////////////////////////////////////////////////////////////////////////////////
function void addr_status::add_pending_data(outstanding_data_s data);
   uncommitted_txn_q.push_back(data);
   foreach (slave_data_waiting_native_data[idx]) begin
      if(compare_slave_if_out_data(slave_data_waiting_native_data[idx], slave_data_waiting_native_byte_en[idx], slave_data_waiting_native_cache_unit[idx], 0, 0, 1)) begin
         slave_data_waiting_native_data.delete(idx);
         slave_data_waiting_native_byte_en.delete(idx);
         slave_data_waiting_native_cache_unit.delete(idx);
         break;
      end
   end
endfunction : add_pending_data

////////////////////////////////////////////////////////////////////////////////
// Function: update_cache_state()
////////////////////////////////////////////////////////////////////////////////
function void addr_status::update_cache_state(cache_state_t state=IX, int unit_id);
   this.cache_info_q[unit_id] = state;
   //TODO: Add cache transition & system level cache state checks here
endfunction : update_cache_state

////////////////////////////////////////////////////////////////////////////////
// Function: commit_pending_data()
////////////////////////////////////////////////////////////////////////////////
function void addr_status::commit_pending_data(outstanding_data_s data, bit cached=0, output outstanding_data_s out_data);
   int find_q[$];
   find_q = uncommitted_txn_q.find_index with (
                  item.funit_id == data.funit_id
                  && item.core_id == data.core_id
                  && item.txn_id == data.txn_id);
   if (find_q.size() > 0) begin
      `uvm_info(`LABEL, $psprintf("commit_pending_data[0x%0h]: funit_id='d%0d, core_id='d%0d, txn_id=0x%0h", 
         cacheline_addr, data.funit_id, data.core_id, data.txn_id), UVM_LOW);
      if ((uncommitted_txn_q[find_q[0]].ns == 0 && this.ns_addr == 0)
          || (this.ns_addr == 1)) begin
         update_curr_data(uncommitted_txn_q[find_q[0]].data, uncommitted_txn_q[find_q[0]].byte_en);
      end else begin
         `uvm_info(`LABEL, $psprintf(
            "commit_pending_data[0x%0h]: NS access on Secure address detected. Data in memory model won't be updated", 
            cacheline_addr), UVM_LOW);
      end
      uncommitted_txn_q[find_q[0]].cached = (uncommitted_txn_q[find_q[0]].cached || cached);
      out_data = uncommitted_txn_q[find_q[0]];
      if (uncommitted_txn_q[find_q[0]].seen_at_slv_if == 0 || uncommitted_txn_q[find_q[0]].cached == 1) begin
         `uvm_info(`LABEL, $psprintf(
            "commit_pending_data[0x%0h]: Saving this data in committed_waiting_slave_if_txn_q", 
            cacheline_addr), UVM_LOW);
         committed_waiting_slave_if_txn_q.push_back(uncommitted_txn_q[find_q[0]]);
      end
      uncommitted_txn_q.delete(find_q[0]);
   end else begin
      `uvm_error(`LABEL, $psprintf("commit_pending_data[0x%0h]: Couldn't find matching pending_data in uncommitted_txn_q", cacheline_addr));
   end
endfunction : commit_pending_data

////////////////////////////////////////////////////////////////////////////////
// Function: compare_read_data()
////////////////////////////////////////////////////////////////////////////////
function void addr_status::compare_read_data(cache_data_t data, cache_byte_en_t byte_en);
   int            w_byte_en = (2 ** <%=obj.wCacheLineOffset%>);
   cache_data_t   current_data_be;
   cache_data_t   read_data_be;

   for (int idx=0; idx < w_byte_en; idx++) begin
      if (byte_en[idx] && current_be[idx]) begin
         current_data_be[8*idx +: 8]   = current_data[8*idx +: 8];
         read_data_be[8*idx +: 8]      = data[8*idx +: 8];
      end // if byte en == 1
      else begin
         current_data_be[8*idx +: 8]   = 'b0;
         read_data_be[8*idx +: 8]      = 'b0;
      end
   end // byte enable for loop
   if (current_data_be !== read_data_be) begin
      `uvm_error(`LABEL, $psprintf(
         "compare_read_data[0x%0h]: DATA_MISMATCH: Expected: 0x%0h, Actual: 0x%0h", 
         cacheline_addr, current_data_be, read_data_be));
   end else begin
      `uvm_info(`LABEL, $psprintf(
         "compare_read_data[0x%0h]: DATA_MATCH: Expected: 0x%0h, Actual: 0x%0h", 
         cacheline_addr, current_data_be, read_data_be), UVM_MEDIUM);
   end
endfunction : compare_read_data

////////////////////////////////////////////////////////////////////////////////
// Function: compare_slave_if_out_data()
////////////////////////////////////////////////////////////////////////////////
function bit addr_status::compare_slave_if_out_data(cache_data_t data, cache_byte_en_t byte_en, bit cache_unit=0, bit possible_eviction=0, bit save_if_unmatched=0, bit no_error=0);
   int            w_byte_en = (2 ** <%=obj.wCacheLineOffset%>);
   cache_data_t   current_data_be;
   cache_data_t   slv_data_be;
   bit            matched = 0;

   // If this is whole cacheline write, it could be an eviction from IOAIU
   if (byte_en == '1) possible_eviction = 1;

   for (int idx=0; idx < w_byte_en; idx++) begin
      if (byte_en[idx] && current_be[idx]) begin
         current_data_be[8*idx +: 8]   = current_data[8*idx +: 8];
         slv_data_be[8*idx +: 8]      = data[8*idx +: 8];
      end // if byte en == 1
      else begin
         current_data_be[8*idx +: 8]   = 'b0;
         slv_data_be[8*idx +: 8]      = 'b0;
      end
   end // byte enable for loop
   `uvm_info(`LABEL, $psprintf(
         "compare_slave_if_out_data[0x%0h]: Current data in cacheline: 0x%0h, Seen on Slave i/f: 0x%0h", 
         cacheline_addr, current_data_be, slv_data_be), UVM_MEDIUM);
   if (current_data_be == slv_data_be) begin
      `uvm_info(`LABEL, $psprintf(
         "compare_slave_if_out_data[0x%0h]: DATA_MATCH: Expected: 0x%0h, Actual: 0x%0h", 
         cacheline_addr, current_data_be, slv_data_be), UVM_MEDIUM);
      matched = 1;
   end else begin
      foreach (uncommitted_txn_q[idx]) begin
         current_data_be = 0;
         slv_data_be = 0;
         for (int i=0; i < w_byte_en; i++) begin
            if (byte_en[i]) begin
               slv_data_be[8*i +: 8]      = data[8*i +: 8];
            end // if byte en == 1
            else begin
               slv_data_be[8*i +: 8]      = 'b0;
            end
            if (uncommitted_txn_q[idx].byte_en[i]) begin
               current_data_be[8*i +: 8]   = uncommitted_txn_q[idx].data[8*i +: 8];
            end // if byte en == 1
            else begin
               current_data_be[8*i +: 8]   = 'b0;
            end
         end // byte enable for loop
         `uvm_info(`LABEL, $psprintf(
            "compare_slave_if_out_data[0x%0h]: uncommitted_txn_q[%0d] data: 0x%0h, Seen on Slave i/f: 0x%0h", 
            cacheline_addr, idx, current_data_be, slv_data_be), UVM_HIGH);
         if (current_data_be == slv_data_be) begin
            `uvm_info(`LABEL, $psprintf(
               "compare_slave_if_out_data[0x%0h]: DATA_MATCH to uncommitted_txn_q[%0d]: Expected: 0x%0h, Actual: 0x%0h", 
               cacheline_addr, idx, current_data_be, slv_data_be), UVM_MEDIUM);
            matched = 1;
            uncommitted_txn_q[idx].seen_at_slv_if = 1;
            uncommitted_txn_q[idx].cached = (uncommitted_txn_q[idx].cached || cache_unit);
            break;
         end
      end // foreach uncommitted_txn_q
   end // else of data match
   if (matched == 0) begin
      foreach (committed_waiting_slave_if_txn_q[idx]) begin
         current_data_be = 0;
         slv_data_be = 0;
         for (int i=0; i < w_byte_en; i++) begin
            if (committed_waiting_slave_if_txn_q[idx].byte_en[i]) begin
               current_data_be[8*i +: 8]   = committed_waiting_slave_if_txn_q[idx].data[8*i +: 8];
               slv_data_be[8*i +: 8]      = data[8*i +: 8];
            end // if byte en == 1
            else begin
               current_data_be[8*i +: 8]   = 'b0;
               slv_data_be[8*i +: 8]      = 'b0;
            end
         end // byte enable for loop
         `uvm_info(`LABEL, $psprintf(
            "compare_slave_if_out_data[0x%0h]: committed_waiting_slave_if_txn_q[%0d] data: 0x%0h, Seen on Slave i/f: 0x%0h", 
            cacheline_addr, idx, current_data_be, slv_data_be), UVM_HIGH);
         if (current_data_be == slv_data_be) begin
            `uvm_info(`LABEL, $psprintf(
               "compare_slave_if_out_data[0x%0h]: DATA_MATCH to committed_waiting_slave_if_txn_q[%0d]: Expected: 0x%0h, Actual: 0x%0h",
               cacheline_addr, idx, current_data_be, slv_data_be), UVM_MEDIUM);
            matched = 1;
            committed_waiting_slave_if_txn_q[idx].cached = (committed_waiting_slave_if_txn_q[idx].cached || cache_unit);
            if (committed_waiting_slave_if_txn_q[idx].cached == 0) begin
               // Save snooped data sent as DTR to match native reads committing later
               if (committed_waiting_slave_if_txn_q[idx].snooped == 0) begin
                  committed_waiting_slave_if_txn_q.delete(idx);
               end
            end else begin
               `uvm_info(`LABEL, $psprintf(
                  "compare_slave_if_out_data[0x%0h]: committed_waiting_slave_if_txn_q[%0d] is cached, not deleting from queue",
                  cacheline_addr, idx), UVM_MEDIUM);
            end
            break;
         end
      end // foreach committed_waiting_slave_if_txn_q
   end
   if (matched == 0) begin
      if (save_if_unmatched == 1 && possible_eviction == 0) begin
         `uvm_info(`LABEL, $psprintf(
            "compare_slave_if_out_data[0x%0h]: DATA_MISMATCH: Didn't match any of current_data or uncommitted_txn_q or committed_waiting_slave_if_txn_q, saving to be matched later. Data received: 0x%0h", 
            cacheline_addr, slv_data_be), UVM_MEDIUM);
         slave_data_waiting_native_data.push_back(data);
         slave_data_waiting_native_byte_en.push_back(byte_en);
         slave_data_waiting_native_cache_unit.push_back(cache_unit);
      end else begin
         if (possible_eviction == 1 || no_error == 1) begin
            `uvm_info(`LABEL, $psprintf(
               "compare_slave_if_out_data[0x%0h]: Possible Eviction or no_error flag set, error downgraded. DATA_MISMATCH: Didn't match any of current_data or uncommitted_txn_q or committed_waiting_slave_if_txn_q. Data received: 0x%0h", 
               cacheline_addr, slv_data_be), UVM_MEDIUM);
         end else begin
            `uvm_error(`LABEL, $psprintf(
               "compare_slave_if_out_data[0x%0h]: DATA_MISMATCH: Didn't match any of current_data or uncommitted_txn_q or committed_waiting_slave_if_txn_q. Data received: 0x%0h", 
               cacheline_addr, slv_data_be));
         end
      end
   end
   return(matched);
endfunction : compare_slave_if_out_data 

////////////////////////////////////////////////////////////////////////////////
// Function: compare_cache_state()
////////////////////////////////////////////////////////////////////////////////
function void addr_status::compare_cache_state(cache_state_t state=IX, int unit_id);
   if (cache_info_q.exists(unit_id)) begin
      if (cache_info_q[unit_id] !== state) begin
         `uvm_error(`LABEL, $psprintf(
            "compare_cache_state[0x%0h]: Cache state mismatch(funit:'d%0d, Core:'d%0d): Expected: 0x%0h, Actual: 0x%0h", 
            cacheline_addr, unit_id[10:3], unit_id[2:0], cache_info_q[unit_id], state));
      end else begin
         `uvm_info(`LABEL, $psprintf(
            "compare_cache_state[0x%0h]: Cache state matched(funit:'d%0d, Core:'d%0d): Expected: 0x%0h, Actual: 0x%0h", 
            cacheline_addr, unit_id[10:3], unit_id[2:0], cache_info_q[unit_id], state), UVM_MEDIUM);
      end
   end else begin
      `uvm_info(`LABEL, $psprintf(
         "compare_cache_state[0x%0h]: Adding new unit cache state(funit:'d%0d, Core:'d%0d): State: 0x%0h", 
         cacheline_addr, unit_id[10:3], unit_id[2:0], state), UVM_LOW);
      cache_info_q[unit_id] = state;
   end
endfunction : compare_cache_state

////////////////////////////////////////////////////////////////////////////////
// Function: update_location()
////////////////////////////////////////////////////////////////////////////////
function void addr_status::update_location(cacheline_location_t new_location);
   location = new_location;
   //TODO: Remove from uncommitted_txn_q or committed_waiting_slave_if_txn_q?
   //TODO: Code later. When will this be called?
endfunction : update_location

////////////////////////////////////////////////////////////////////////////////
// Function: print_memory()
////////////////////////////////////////////////////////////////////////////////
function void addr_status::print_memory();
   string msg = "";
endfunction : print_memory

////////////////////////////////////////////////////////////////////////////////
// Function: compare_native_if_out_data()
////////////////////////////////////////////////////////////////////////////////
function bit addr_status::compare_native_if_out_data(cache_data_t data, cache_byte_en_t byte_en);
   int            w_byte_en = (2 ** <%=obj.wCacheLineOffset%>);
   cache_data_t   current_data_be;
   cache_data_t   slv_data_be;
   bit            matched = 0;

   for (int idx=0; idx < w_byte_en; idx++) begin
      if (byte_en[idx] && current_be[idx]) begin
         current_data_be[8*idx +: 8]   = current_data[8*idx +: 8];
         slv_data_be[8*idx +: 8]      = data[8*idx +: 8];
      end // if byte en == 1
      else begin
         current_data_be[8*idx +: 8]   = 'b0;
         slv_data_be[8*idx +: 8]      = 'b0;
      end
   end // byte enable for loop
   `uvm_info(`LABEL, $psprintf(
         "compare_native_if_out_data[0x%0h]: Current data in cacheline: 0x%0h, Seen on native i/f: 0x%0h",
         cacheline_addr, current_data_be, slv_data_be), UVM_MEDIUM);
   if (current_data_be == slv_data_be) begin
      `uvm_info(`LABEL, $psprintf(
         "compare_native_if_out_data[0x%0h]: DATA_MATCH: Expected: 0x%0h, Actual: 0x%0h", 
         cacheline_addr, current_data_be, slv_data_be), UVM_MEDIUM);
      matched = 1;
   end
   // Compare with committed_waiting_slave_if_txn_q anyways, so we cleanup snooped data queue if there is a match.
   //if (matched == 0) begin
      foreach (committed_waiting_slave_if_txn_q[idx]) begin
         current_data_be = 0;
         slv_data_be = 0;
         for (int i=0; i < w_byte_en; i++) begin
            if (byte_en[i] && committed_waiting_slave_if_txn_q[idx].byte_en[i]) begin
               current_data_be[8*i +: 8]   = committed_waiting_slave_if_txn_q[idx].data[8*i +: 8];
               slv_data_be[8*i +: 8]      = data[8*i +: 8];
            end // if byte en == 1
            else begin
               current_data_be[8*i +: 8]   = 'b0;
               slv_data_be[8*i +: 8]      = 'b0;
            end
         end // byte enable for loop
         `uvm_info(`LABEL, $psprintf(
            "compare_native_if_out_data[0x%0h]: committed_waiting_slave_if_txn_q[%0d] data: 0x%0h, native i/f data: 0x%0h", 
            cacheline_addr, idx, current_data_be, slv_data_be), UVM_MEDIUM);
         if (current_data_be == slv_data_be) begin
            `uvm_info(`LABEL, $psprintf(
               "compare_native_if_out_data[0x%0h]: DATA_MATCH to committed_waiting_slave_if_txn_q[%0d]: Expected: 0x%0h, Actual: 0x%0h",
               cacheline_addr, idx, current_data_be, slv_data_be), UVM_MEDIUM);
            matched = 1;
            //This data now resides in one of NCore cache. Multiple reads could match.
            //Hence, not deleting.
            // only delete snooped data sent as DTR
            if (committed_waiting_slave_if_txn_q[idx].snooped) begin
               committed_waiting_slave_if_txn_q.delete(idx);
            end
            break;
         end
      end // foreach committed_waiting_slave_if_txn_q
   //end
   return(matched);
endfunction : compare_native_if_out_data 

////////////////////////////////////////////////////////////////////////////////
// Function: match_current_data()
////////////////////////////////////////////////////////////////////////////////
function bit addr_status::match_current_data(cache_data_t data, cache_byte_en_t byte_en);
   int            w_byte_en = (2 ** <%=obj.wCacheLineOffset%>);
   cache_data_t   current_data_be;
   cache_data_t   slv_data_be;
   bit            matched = 0;

   for (int idx=0; idx < w_byte_en; idx++) begin
      if (byte_en[idx] && current_be[idx]) begin
         current_data_be[8*idx +: 8]   = current_data[8*idx +: 8];
         slv_data_be[8*idx +: 8]      = data[8*idx +: 8];
      end // if byte en == 1
      else begin
         current_data_be[8*idx +: 8]   = 'b0;
         slv_data_be[8*idx +: 8]      = 'b0;
      end
   end // byte enable for loop
   `uvm_info(`LABEL, $psprintf(
         "match_current_data[0x%0h]: Current data in cacheline: 0x%0h, Seen on native i/f: 0x%0h",
         cacheline_addr, current_data_be, slv_data_be), UVM_MEDIUM);
   if (current_data_be == slv_data_be) begin
      `uvm_info(`LABEL, $psprintf(
         "match_current_data[0x%0h]: DATA_MATCH: Expected: 0x%0h, Actual: 0x%0h", 
         cacheline_addr, current_data_be, slv_data_be), UVM_MEDIUM);
      matched = 1;
   end 
   return(matched);
endfunction: match_current_data

// End of file
