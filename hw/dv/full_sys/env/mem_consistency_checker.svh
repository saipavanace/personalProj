////////////////////////////////////////////////////////////////////////////////
//
// Author       : Neha F
// Purpose      : Maintain each cacheline addr in their latest memory consistent 
//                state.
// Description  : Monitor each AIU's native i/f transactions and call appropriate
//                functions on addr_status class to keep native i/f & slave i/f 
//                memoery arrays updated.
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
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')) {
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
// mem_consistency_checker class code starts here
////////////////////////////////////////////////////////////////////////////////
import uvm_pkg::*;
`include "uvm_macros.svh"

`undef LABEL
`define  LABEL "mem_consistency_checker"

class mem_consistency_checker extends uvm_component;

   `uvm_component_utils(mem_consistency_checker)

   // Memory model arrays
   addr_status          native_if_mem[bit[63:0]];
   cache_data_t         slave_if_mem[bit[64:0]];
   cache_byte_en_t      slave_if_mem_be[bit[64:0]];
   read_data_s          slave_if_read_data[$];
   read_data_s          native_if_read_data[$];
   bit[64:0]            atomic_txn_addr_q[$];

   mem_checker_cfg      m_mem_checker_cfg;

   extern function new(string name = "mem_consistency_checker", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);
   extern function void write_on_native_if(bit[63:0] addr[], 
                                           cache_data_t wdata[], 
                                           cache_byte_en_t byte_en[], 
                                           int txn_id,
                                           bit ns,
                                           bit is_coh,
                                           bit is_chi,
                                           int funit_id, 
                                           input int core_id=0,
                                           int fsys_index, 
                                           ref fsys_scb_txn fsys_txn_q[$],
                                           input bit cached=0);
   extern function void read_on_native_if(bit[63:0] addr[], 
                                           cache_data_t rdata[], 
                                           cache_byte_en_t byte_en[], 
                                           int txn_id,
                                           bit ns,
                                           bit is_coh,
                                           bit is_chi,
                                           int funit_id, 
                                           input int core_id=0,
                                           time read_issue_time,
                                           bit cache_unit=0,
                                           int fsys_index, 
                                           ref fsys_scb_txn fsys_txn_q[$]);
   extern function void bresp_on_native_if(bit[63:0] addr[], 
                                           int txn_id,
                                           bit ns,
                                           bit is_coh,
                                           int funit_id, 
                                           input int core_id=0,
                                           bit  cached=0,
                                           int fsys_index, 
                                           ref fsys_scb_txn fsys_txn_q[$]);
   extern function void snoop_on_native_if(bit[63:0] addr, 
                                           cache_data_t data, 
                                           cache_byte_en_t byte_en, 
                                           byte snp_resp,
                                           int funit_id, 
                                           input int core_id=0,
                                           bit to_dmi=0,
                                           int fsys_index, 
                                           ref fsys_scb_txn fsys_txn_q[$]);

   extern function void write_on_slave_if(bit[63:0] addr, 
                                          cache_data_t wdata, 
                                          cache_byte_en_t byte_en, 
                                          int txn_id,
                                          bit ns,
                                          bit is_coh,
                                          int funit_id,
                                          bit eviction = 0,
                                          bit cache_unit=0);
   extern function void update_slave_mem_data(bit[63:0] addr, 
                                          bit ns,
                                          cache_data_t wdata, 
                                          cache_byte_en_t byte_en);
   extern function void read_on_slave_if(bit[63:0] addr, 
                                         cache_data_t rdata, 
                                         cache_byte_en_t byte_en, //Used for unaligned addr txns. 
                                         int txn_id,
                                         bit ns,
                                         bit is_coh,
                                         int funit_id,
                                         bit cache_unit=0);
   extern function void compare_native_rdata_slave_mem_data(bit[63:0] addr, 
                                                            bit ns,
                                                            cache_data_t rdata, 
                                                            cache_byte_en_t byte_en,
                                                            bit cache_unit=0);
   extern function void match_pending_native_read_data(bit[63:0] addr, 
                                                       cache_data_t data, 
                                                       cache_byte_en_t byte_en);
   extern function void atomic_on_native_if(bit[63:0] addr);

   // End of test checks
   extern function void check_phase(uvm_phase phase);
endclass : mem_consistency_checker

function mem_consistency_checker::new(string name = "mem_consistency_checker", uvm_component parent = null);
   super.new(name, parent);
endfunction : new

////////////////////////////////////////////////////////////////////////////////
// Function : build_phase
////////////////////////////////////////////////////////////////////////////////
function void mem_consistency_checker::build_phase(uvm_phase phase);

  super.build_phase(phase);
  if(!(uvm_config_db #(mem_checker_cfg)::get(uvm_root::get(), "", "m_mem_checker_cfg", m_mem_checker_cfg)))begin
      `uvm_fatal(`LABEL, "Could not find mem_checker_cfg object in UVM DB");
  end
endfunction : build_phase

////////////////////////////////////////////////////////////////////////////////
// Function: write_on_native_if()
////////////////////////////////////////////////////////////////////////////////
function void mem_consistency_checker::write_on_native_if(bit[63:0] addr[], 
                                                          cache_data_t wdata[], 
                                                          cache_byte_en_t byte_en[], 
                                                          int txn_id,
                                                          bit ns,
                                                          bit is_coh,
                                                          bit is_chi,
                                                          int funit_id, 
                                                          input int core_id=0,
                                                          int fsys_index, 
                                                          ref fsys_scb_txn fsys_txn_q[$],
                                                          input bit cached=0);
   bit[63:0] cacheline_addr = {(addr[0] >> ncoreConfigInfo::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
   int         cacheline_incr = 2 ** <%=obj.wCacheLineOffset%>;
   if (addr.size() !== wdata.size()) begin
      `uvm_error(`LABEL, $psprintf("write_on_native_if: Size of addr array('d%0d) and data array('d%0d) is different", addr.size(), wdata.size()));
   end
   if (wdata.size() !== byte_en.size()) begin
      `uvm_error(`LABEL, $psprintf("write_on_native_if: Size of data array('d%0d) and byte_en array('d%0d) is different", wdata.size(), byte_en.size()));
   end
   for (int idx=0; idx < addr.size(); idx++) begin
      automatic bit[63:0] tmp_addr = addr[idx];
      automatic outstanding_data_s new_data;
      automatic addr_status new_mem_entry;
      new_data.data = wdata[idx];
      new_data.byte_en   = byte_en[idx];
      new_data.funit_id  = funit_id;
      new_data.core_id   = core_id;
      new_data.txn_id    = txn_id;
      new_data.ns        = ns;
      new_data.coh       = is_coh;
      new_data.cached    = cached;
      //`uvm_info('LABEL, $psprintf("write_on_native_if: tmp_addr=0x%0h, cacheline_incr=0x%0h, cacheline_addr=0x%0h", tmp_addr, cacheline_incr, cacheline_addr), UVM_NONE+50);
      if (native_if_mem.exists(tmp_addr)) begin
         if (is_chi == 0) begin
            `uvm_info(`LABEL, $psprintf(
               "write_on_native_if: Add to uncommitted_txn_q: Addr:0x%0h, Data:0x%0h, Byte_en:0x%0h"
               ,tmp_addr, new_data.data, new_data.byte_en), UVM_MEDIUM)
            native_if_mem[tmp_addr].add_pending_data(new_data);
         end else begin
            `uvm_info(`LABEL, $psprintf(
               "write_on_native_if: update current data: Addr:0x%0h, Data:0x%0h, Byte_en:0x%0h", 
               tmp_addr, wdata[idx], byte_en[idx]), UVM_MEDIUM)
            native_if_mem[tmp_addr].update_curr_data(wdata[idx], byte_en[idx]);
            native_if_mem[tmp_addr].committed_waiting_slave_if_txn_q.push_back(new_data);
         end
      end else begin
         new_mem_entry = addr_status::type_id::create($psprintf("addr_%0h",tmp_addr));
         new_mem_entry.initialize(.addr(tmp_addr),
                                  .data(new_data), 
                                  .state(IX),
                                  .ns_addr(ncoreConfigInfo::get_addr_gprar_nsx(tmp_addr)), 
                                  .coh_addr((ncoreConfigInfo::get_addr_gprar_nc(tmp_addr) == 1) ? 0 : 1), 
                                  .data_val((is_chi==1) ? 0 : 1));
         `uvm_info(`LABEL, $psprintf(
               "write_on_native_if: New addr added to native_if_mem: Addr:0x%0h"
               ,tmp_addr), UVM_MEDIUM)
         native_if_mem[tmp_addr] = new_mem_entry;
         if (is_chi == 1) begin
            `uvm_info(`LABEL, $psprintf(
               "write_on_native_if: update current data: Addr:0x%0h, Data:0x%0h, Byte_en:0x%0h",
               tmp_addr, wdata[idx], byte_en[idx]), UVM_MEDIUM)
            native_if_mem[tmp_addr].update_curr_data(wdata[idx], byte_en[idx]);
            native_if_mem[tmp_addr].committed_waiting_slave_if_txn_q.push_back(new_data);
         end
      end
      //If this is a multicacheline txn committing, check if there is a match in native_if_read_data array
      if(addr.size() > 1 && new_data.byte_en !== 'b0) begin
         match_pending_native_read_data(tmp_addr, new_data.data, new_data.byte_en);
      end
   end // foreach multi cacheline addr

endfunction : write_on_native_if

////////////////////////////////////////////////////////////////////////////////
// Function: read_on_native_if()
////////////////////////////////////////////////////////////////////////////////
//TODO: Add rresp response type checking
function void mem_consistency_checker::read_on_native_if(bit[63:0] addr[], 
                                                          cache_data_t rdata[], 
                                                          cache_byte_en_t byte_en[], 
                                                          int txn_id,
                                                          bit ns,
                                                          bit is_coh,
                                                          bit is_chi,
                                                          int funit_id, 
                                                          input int core_id=0,
                                                          time read_issue_time,
                                                          bit cache_unit=0,
                                                          int fsys_index, 
                                                          ref fsys_scb_txn fsys_txn_q[$]);
   bit[63:0] cacheline_addr = {(addr[0] >> ncoreConfigInfo::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
   int         cacheline_incr = 2 ** <%=obj.wCacheLineOffset%>;
   if (addr.size() !== rdata.size()) begin
      `uvm_error(`LABEL, $psprintf("read_on_native_if: Size of addr array('d%0d) and data array('d%0d) is different", addr.size(), rdata.size()));
   end
   if (rdata.size() !== byte_en.size()) begin
      `uvm_error(`LABEL, $psprintf("read_on_native_if: Size of data array('d%0d) and byte_en array('d%0d) is different", rdata.size(), byte_en.size()));
   end
   for (int idx=0; idx < addr.size(); idx++) begin
      automatic bit[63:0] tmp_addr = addr[idx];
      automatic outstanding_data_s new_data;
      automatic addr_status new_mem_entry;
      compare_native_rdata_slave_mem_data(tmp_addr, ns, rdata[idx], byte_en[idx], cache_unit);
      if (native_if_mem.exists(tmp_addr)) begin
         `uvm_info(`LABEL, $psprintf(
            "read_on_native_if: compare read data: Addr:0x%0h, Data:0x%0h, Byte_en:0x%0h, read_issue_time=%0t, current_data_commit_time=%0t"
            ,tmp_addr, rdata[idx], byte_en[idx], read_issue_time, native_if_mem[tmp_addr].current_data_commit_time), UVM_MEDIUM)
         //Check this read's issue time and current_data's commit time & compare data
         if (native_if_mem[tmp_addr].current_data_commit_time < read_issue_time) begin
            //TODO: Need slave seq to return same data as was written, without that support, this check won't pass.
            //if (!native_if_mem[tmp_addr].match_current_data(rdata[idx], byte_en[idx])) begin
            //   `uvm_error(`LABEL, $psprintf(
            //      "read_on_native_if[0x%0h]: DATA_MISMATCH: This read was issued after write commited, data should have matched current data in native mem. Read data 0x%0h, BE:0x%0h, current_data in native mem: 0x%0h, BE=0x%0h", 
            //      tmp_addr, rdata[idx], byte_en[idx], native_if_mem[tmp_addr].current_data, native_if_mem[tmp_addr].current_be));
            //end
         end // If read was issued after write commit
         //native_if_mem[tmp_addr].update_curr_data(rdata[idx], byte_en[idx]);
      end else begin
         new_mem_entry = addr_status::type_id::create($psprintf("addr_%0h",tmp_addr));
         new_mem_entry.initialize(.addr(tmp_addr),
                                  .data(new_data), 
                                  .state(IX),
                                  .ns_addr(ncoreConfigInfo::get_addr_gprar_nsx(tmp_addr)), 
                                  .coh_addr((ncoreConfigInfo::get_addr_gprar_nc(tmp_addr) == 1) ? 0 : 1), 
                                  .data_val(0));
         `uvm_info(`LABEL, $psprintf(
               "read_on_native_if: New addr added to native_if_mem: Addr:0x%0h"
               ,tmp_addr), UVM_MEDIUM)
         native_if_mem[tmp_addr] = new_mem_entry;
         //`uvm_info(`LABEL, $psprintf(
         //   "read_on_native_if: update current data: Addr:0x%0h, Data:0x%0h, Byte_en:0x%0h"
         //   ,tmp_addr, rdata[idx], byte_en[idx]), UVM_MEDIUM)
         //native_if_mem[tmp_addr].update_curr_data(rdata[idx], byte_en[idx]);
      end
   end // foreach multi cacheline addr
endfunction : read_on_native_if

////////////////////////////////////////////////////////////////////////////////
// Function: bresp_on_native_if()
////////////////////////////////////////////////////////////////////////////////
function void mem_consistency_checker::bresp_on_native_if(bit[63:0] addr[], 
                                                          int txn_id,
                                                          bit ns,
                                                          bit is_coh,
                                                          int funit_id, 
                                                          input int core_id=0,
                                                          bit  cached=0,
                                                          int fsys_index, 
                                                          ref fsys_scb_txn fsys_txn_q[$]);
   bit[63:0] cacheline_addr = {(addr[0] >> ncoreConfigInfo::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
   int       cacheline_incr = 2 ** <%=obj.wCacheLineOffset%>;
   outstanding_data_s   out_data;  
   cacheline_location_t new_location = NCORE;
   for (int idx=0; idx < addr.size(); idx++) begin
      automatic bit[63:0] tmp_addr = addr[idx]; 
      automatic outstanding_data_s new_data;
      automatic addr_status new_mem_entry;
      new_data.funit_id  = funit_id;
      new_data.core_id   = core_id;
      new_data.txn_id    = txn_id;
      new_data.ns        = ns;
      new_data.coh       = is_coh;
      if (native_if_mem.exists(tmp_addr)) begin
         `uvm_info(`LABEL, $psprintf("bresp_on_native_if: commit data: Addr:0x%0h, cached: 0x%0h, txn_id=0x%0h, funit_id=0x%0h, core_id=0x%0h"
            , tmp_addr, cached, txn_id, funit_id, core_id), UVM_MEDIUM)
         native_if_mem[tmp_addr].commit_pending_data(new_data, cached, out_data);
         //If this is a multicacheline/single cacheline txn committing, check if there is a match in native_if_read_data array
         // There could be a write that saw wdata, but it's data would be sitting in uncommitted_txn_q, which isn't checked 
         // while comparing read data(because it's uncommitted and shouldn't have affected read, ideally). If a multi cacheline
         // txn is sending a bresp, make sure we are comparing the data against whatever is being removed from uncommitted_txn_q 
         if(addr.size() >= 1 && out_data.byte_en !== 'b0) begin
            match_pending_native_read_data(tmp_addr, out_data.data, out_data.byte_en);
         end
         if (out_data.seen_at_slv_if == 0 && cached == 1) begin
            //This means data was cached in NCore
            //Update slave memory & modify native_memory data's location bit
            //update_slave_mem_data(tmp_addr, ns, out_data.data, out_data.byte_en);
            native_if_mem[tmp_addr].update_location(new_location); // Data is in any of internal NCORE mem
         end
      end else begin
         `uvm_error(`LABEL, $psprintf("bresp_on_native_if: Addr(0x%0h) doesn't exist in native_if_mem", tmp_addr));
      end
   end // foreach multi cacheline addr
endfunction : bresp_on_native_if

////////////////////////////////////////////////////////////////////////////////
// Function: snoop_on_native_if()
////////////////////////////////////////////////////////////////////////////////
function void mem_consistency_checker::snoop_on_native_if(bit[63:0] addr, 
                                                          cache_data_t data, 
                                                          cache_byte_en_t byte_en, 
                                                          byte snp_resp,
                                                          int funit_id, 
                                                          input int core_id=0,
                                                          bit to_dmi=0,
                                                          int fsys_index, 
                                                          ref fsys_scb_txn fsys_txn_q[$]);

   bit[63:0] tmp_addr = addr;
   bit match_found = 0;
   outstanding_data_s new_data;
   addr_status new_mem_entry;
   new_data.data = data;
   new_data.byte_en   = byte_en;
   new_data.funit_id  = funit_id;
   new_data.core_id   = 0; // TODO 
   new_data.txn_id    = 0; // TODO
   new_data.ns        = 0; // TODO
   new_data.coh       = 1;
   `uvm_info(`LABEL, $psprintf("snoop_on_native_if: addr=0x%0h, data=0x%0h", tmp_addr, data), UVM_NONE+50);
   if (native_if_mem.exists(tmp_addr)) begin
      `uvm_info(`LABEL, $psprintf(
         "snoop_on_native_if: update current data: Addr:0x%0h, Data:0x%0h, Byte_en:0x%0h", 
         tmp_addr, data, byte_en), UVM_MEDIUM)
      native_if_mem[tmp_addr].update_curr_data(data, byte_en);
      foreach (native_if_mem[tmp_addr].slave_data_waiting_native_data[idx]) begin
         if(native_if_mem[tmp_addr].compare_slave_if_out_data(native_if_mem[tmp_addr].slave_data_waiting_native_data[idx], native_if_mem[tmp_addr].slave_data_waiting_native_byte_en[idx], native_if_mem[tmp_addr].slave_data_waiting_native_cache_unit[idx], 0, 0, 1)) begin
            native_if_mem[tmp_addr].slave_data_waiting_native_data.delete(idx);
            native_if_mem[tmp_addr].slave_data_waiting_native_byte_en.delete(idx);
            native_if_mem[tmp_addr].slave_data_waiting_native_cache_unit.delete(idx);
            match_found = 1;
            break;
         end
      end
      if (match_found == 0) begin
         if (to_dmi) begin
            native_if_mem[tmp_addr].committed_waiting_slave_if_txn_q.push_back(new_data);
         end else begin
            // Save this data as snooped data, so when the native read that got this data(as DTR) will match to this.
            new_data.snooped = 1;
            native_if_mem[tmp_addr].committed_waiting_slave_if_txn_q.push_back(new_data);
         end
      end
   end else begin
      new_mem_entry = addr_status::type_id::create($psprintf("addr_%0h",tmp_addr));
      new_mem_entry.initialize(.addr(tmp_addr),
                               .data(new_data), 
                               .state(IX),
                               .ns_addr(ncoreConfigInfo::get_addr_gprar_nsx(tmp_addr)), 
                               .coh_addr((ncoreConfigInfo::get_addr_gprar_nc(tmp_addr) == 1) ? 0 : 1), 
                               .data_val(1));
      `uvm_info(`LABEL, $psprintf(
            "snoop_on_native_if: New addr added to native_if_mem: Addr:0x%0h"
            ,tmp_addr), UVM_MEDIUM)
      native_if_mem[tmp_addr] = new_mem_entry;
      `uvm_info(`LABEL, $psprintf(
         "snoop_on_native_if: update current data: Addr:0x%0h, Data:0x%0h, Byte_en:0x%0h",
         tmp_addr, data, byte_en), UVM_MEDIUM)
      native_if_mem[tmp_addr].update_curr_data(data, byte_en);
      if(to_dmi) begin
         native_if_mem[tmp_addr].committed_waiting_slave_if_txn_q.push_back(new_data);
      end else begin
         // Save this data as snooped data, so when the native read that got this data(as DTR) will match to this.
         new_data.snooped = 1;
         native_if_mem[tmp_addr].committed_waiting_slave_if_txn_q.push_back(new_data);
      end
   end
endfunction : snoop_on_native_if

////////////////////////////////////////////////////////////////////////////////
// Function: write_on_slave_if()
////////////////////////////////////////////////////////////////////////////////
function void mem_consistency_checker::write_on_slave_if(bit[63:0] addr, 
                                                         cache_data_t wdata, 
                                                         cache_byte_en_t byte_en, 
                                                         int txn_id,
                                                         bit ns,
                                                         bit is_coh,
                                                         int funit_id,
                                                         bit eviction = 0,
                                                         bit cache_unit=0);
   bit[63:0] cacheline_addr = {(addr >> ncoreConfigInfo::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
   int w_byte_en = (2 ** <%=obj.wCacheLineOffset%>);
   cache_data_t   curr_data = 0;
   cache_byte_en_t curr_be = 0;
   outstanding_data_s new_data;
   addr_status new_mem_entry;
   new_data.data      = wdata;
   new_data.byte_en   = byte_en;
   new_data.funit_id  = funit_id;
   new_data.txn_id    = txn_id;
   new_data.ns        = ns;
   new_data.coh       = is_coh;
   if (native_if_mem.exists(cacheline_addr)) begin
      native_if_mem[cacheline_addr].compare_slave_if_out_data(wdata, byte_en, cache_unit, eviction, 1);
   end else begin
      //Error if this isn't eviction.
      if (eviction == 0) begin
         `uvm_info(`LABEL, $psprintf(
            "write_on_slave_if[addr:0x%0h]: Observed write(funit_id:'d%0d) but no match in native i/f mem, saving for later match", 
            cacheline_addr, funit_id), UVM_MEDIUM)
         new_mem_entry = addr_status::type_id::create($psprintf("addr_%0h",addr));
         new_mem_entry.initialize(.addr(addr),
                                  .data(new_data), 
                                  .state(IX),
                                  .ns_addr(ncoreConfigInfo::get_addr_gprar_nsx(addr)), 
                                  .coh_addr((ncoreConfigInfo::get_addr_gprar_nc(addr) == 1) ? 0 : 1), 
                                  .data_val(0));
         `uvm_info(`LABEL, $psprintf(
               "write_on_slave_if: New addr added to native_if_mem: Addr:0x%0h"
               ,addr), UVM_MEDIUM)
         native_if_mem[addr] = new_mem_entry;
         native_if_mem[addr].slave_data_waiting_native_data.push_back(wdata);
         native_if_mem[addr].slave_data_waiting_native_byte_en.push_back(byte_en);
         native_if_mem[addr].slave_data_waiting_native_cache_unit.push_back(cache_unit);
      end
   end // else of native_if_mem.exists
   update_slave_mem_data(cacheline_addr, ns, wdata, byte_en);
endfunction : write_on_slave_if

////////////////////////////////////////////////////////////////////////////////
// Function: update_slave_mem_data()
////////////////////////////////////////////////////////////////////////////////
function void mem_consistency_checker::update_slave_mem_data(bit[63:0] addr, 
                                                         bit ns,
                                                         cache_data_t wdata, 
                                                         cache_byte_en_t byte_en);
   int w_byte_en = (2 ** <%=obj.wCacheLineOffset%>);
   cache_data_t   curr_data = 0;
   cache_byte_en_t curr_be = 0;
   `uvm_info(`LABEL, $psprintf("update_slave_mem_data: Slave mem data update: Addr:0x%0h, Data:0x%0h, Byte_en:0x%0h", addr, wdata, byte_en), UVM_MEDIUM)
   for (int idx=0; idx < w_byte_en; idx++) begin
      if (byte_en[idx]) begin
         curr_data[8*idx +: 8]  = wdata[8*idx +: 8];
         curr_be[idx] = byte_en[idx];
      end // if byte en == 1
      else begin
         if (slave_if_mem.exists({ns,addr[63:0]})) begin
            curr_data[8*idx +: 8] = slave_if_mem[{ns,addr[63:0]}][8*idx +: 8];
            curr_be[idx] = slave_if_mem_be[{ns,addr[63:0]}][idx];
         end
      end
   end // byte enable for loop
   slave_if_mem[{ns,addr[63:0]}] = curr_data;
   slave_if_mem_be[{ns,addr[63:0]}] = curr_be;
   `uvm_info(`LABEL, $psprintf(
      "update_slave_mem_data: Slave i/f New data: Addr:0x%0h, NS:%0d, Data:0x%0h, BE=0x%0h", 
      addr, ns, slave_if_mem[{ns,addr[63:0]}],
      slave_if_mem_be[{ns,addr[63:0]}]), UVM_MEDIUM)
endfunction : update_slave_mem_data

////////////////////////////////////////////////////////////////////////////////
// Function: read_on_slave_if()
////////////////////////////////////////////////////////////////////////////////
function void mem_consistency_checker::read_on_slave_if(bit[63:0] addr, 
                                                        cache_data_t rdata, 
                                                        cache_byte_en_t byte_en, //Used for unaligned addr txns. 
                                                        int txn_id,
                                                        bit ns,
                                                        bit is_coh,
                                                        int funit_id,
                                                        bit cache_unit=0);
   bit[63:0] cacheline_addr = {(addr >> ncoreConfigInfo::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
   int w_byte_en = (2 ** <%=obj.wCacheLineOffset%>);
   cache_data_t   curr_data = 0;
   cache_byte_en_t curr_be = 0;
   read_data_s     read_data;
   
   //TODO: Add a check to make sure this rdata matches data in slave_if_mem, if supported by sequences.
   `uvm_info(`LABEL, $psprintf("read_on_slave_if: Slave i/f data: Addr:0x%0h, Data:0x%0h, Byte_en:0x%0h", cacheline_addr, rdata, byte_en), UVM_MEDIUM)
   for (int idx=0; idx < w_byte_en; idx++) begin
      if (byte_en[idx]) begin
         curr_data[8*idx +: 8]  = rdata[8*idx +: 8];
         curr_be[idx] = byte_en[idx];
      end // if byte en == 1
      else begin
         if (slave_if_mem.exists({ns,cacheline_addr[63:0]})) begin
            curr_data[8*idx +: 8] = slave_if_mem[{ns,cacheline_addr[63:0]}][8*idx +: 8];
            curr_be[idx] = slave_if_mem_be[{ns,cacheline_addr[63:0]}][idx];
         end
      end
   end // byte enable for loop
   slave_if_mem[{ns,cacheline_addr[63:0]}] = curr_data;
   slave_if_mem_be[{ns,cacheline_addr[63:0]}] = curr_be;
   read_data.addr = {ns,cacheline_addr[63:0]};
   read_data.data = curr_data;
   read_data.byte_en = curr_be;
   if (byte_en == '1 && cache_unit==1) read_data.cached = 1;
   //TODO: Figure out a way to clean up this array, it could build up over time
   slave_if_read_data.push_back(read_data);
   `uvm_info(`LABEL, $psprintf(
      "read_on_slave_if: Slave i/f New data: Addr:0x%0h, NS:%0d, Data:0x%0h, BE=0x%0h", 
      cacheline_addr, ns, slave_if_mem[{ns,cacheline_addr[63:0]}], 
      slave_if_mem_be[{ns,cacheline_addr[63:0]}]), UVM_MEDIUM)
endfunction : read_on_slave_if

////////////////////////////////////////////////////////////////////////////////
// Function: compare_native_rdata_slave_mem_data()
////////////////////////////////////////////////////////////////////////////////
function void mem_consistency_checker::compare_native_rdata_slave_mem_data(bit[63:0] addr, bit ns, cache_data_t rdata, cache_byte_en_t byte_en, bit cache_unit=0);
   int                  w_byte_en = (2 ** <%=obj.wCacheLineOffset%>);
   cache_data_t         rdata_be;
   cache_data_t         slvmem_data_be = '1;
   cacheline_location_t new_location = NCORE;
   bit                  matched = 0;
   read_data_s          read_data;

   foreach (slave_if_read_data[dt_idx]) begin
      //`uvm_info(`LABEL, $psprintf(
      //   "compare_native_rdata_slave_mem_data[0x%0h]: NS: %0d Data in slave_if_read_data[%0d]: 0x%0h", 
      //   slave_if_read_data[dt_idx].addr[63:0], slave_if_read_data[dt_idx].addr[64:64], dt_idx, slave_if_read_data[dt_idx].data), UVM_MEDIUM);
      if (slave_if_read_data[dt_idx].addr == {ns,addr[63:0]}) begin
         slvmem_data_be = 0;
         for (int idx=0; idx < w_byte_en; idx++) begin
            if (byte_en[idx] && slave_if_read_data[dt_idx].byte_en[idx]) begin
               rdata_be[8*idx +: 8]       = rdata[8*idx +: 8];
               slvmem_data_be[8*idx +: 8] = slave_if_read_data[dt_idx].data[8*idx +: 8];
            end // if byte en == 1
            else begin
               rdata_be[8*idx +: 8]   = 'b0;
               slvmem_data_be[8*idx +: 8]      = 'b0;
            end
         end // byte enable for loop
         `uvm_info(`LABEL, $psprintf(
            "compare_native_rdata_slave_mem_data[0x%0h]: Data in slave_if_read_data[%0d]: 0x%0h, Seen on native i/f: 0x%0h", 
            addr, dt_idx, slvmem_data_be, rdata_be), UVM_MEDIUM);
         if (rdata_be == slvmem_data_be) begin
            `uvm_info(`LABEL, $psprintf(
               "compare_native_rdata_slave_mem_data[0x%0h]: DATA_MATCH: in slave_if_read_data[%0d]: 0x%0h, Seen on native i/f: 0x%0h", 
               addr, dt_idx, slvmem_data_be, rdata_be), UVM_MEDIUM);
            matched = 1;
            // Only remove if all byte_en are same. 
            // Some slave reads need to stay for multiple reads to match
            // if few bytes were overwritten by later write
            if (slave_if_read_data[dt_idx].cached == 0 && cache_unit == 0
               && slave_if_read_data[dt_idx].byte_en == byte_en) begin
               //TODO: Add logic to cleanup & delete these cached copies.
               //On a write on slave i/f? 
               slave_if_read_data.delete(dt_idx);
            end
            break;
         end
      end // if addr match
   end // foreach slave_if_read_data
   // Match with current data in slave mem
   if (matched == 0) begin
      if (slave_if_mem.exists({ns,addr[63:0]})) begin
         slvmem_data_be = 0;
         for (int idx=0; idx < w_byte_en; idx++) begin
            if (byte_en[idx] && slave_if_mem_be[{ns,addr[63:0]}]) begin
               rdata_be[8*idx +: 8]       = rdata[8*idx +: 8];
               slvmem_data_be[8*idx +: 8] = slave_if_mem[{ns,addr[63:0]}][8*idx +: 8];
            end // if byte en == 1
            else begin
               rdata_be[8*idx +: 8]   = 'b0;
               slvmem_data_be[8*idx +: 8]      = 'b0;
            end
         end // byte enable for loop
         `uvm_info(`LABEL, $psprintf(
            "compare_native_rdata_slave_mem_data[0x%0h]: Data in slave_if_mem: 0x%0h, Seen on native i/f: 0x%0h", 
            addr, slvmem_data_be, rdata_be), UVM_FULL);
         if (rdata_be == slvmem_data_be) begin
            `uvm_info(`LABEL, $psprintf(
               "compare_native_rdata_slave_mem_data[0x%0h]: DATA_MATCH: in slave_if_mem: 0x%0h, Seen on native i/f: 0x%0h", 
               addr, slvmem_data_be, rdata_be), UVM_MEDIUM);
            matched = 1;
         end
      end
   end
   if (matched == 0) begin
      // There could have been a write that committed to SMC, hence data in slave_mem maynot be updated 
      // Account for that by matching with current_data and committed_waiting_slave_if_txn_q
      // TODO: What about addr that fall in DII space? back to back reads in DII returns different data from DV
      if (native_if_mem.exists(addr)) begin
         if(native_if_mem[addr].compare_native_if_out_data(rdata, byte_en)) begin
            `uvm_info(`LABEL, $psprintf("compare_native_rdata_slave_mem_data[0x%0h]: DATA_MATCH found", addr), UVM_MEDIUM);
            native_if_mem[addr].update_location(new_location); // Data is in any of internal NCORE mem
         end else begin
            if (m_mem_checker_cfg.is_sp_addr(addr)) begin
               `uvm_info(`LABEL, $psprintf(
                  "compare_native_rdata_slave_mem_data[0x%0h]: DATA_MISMATCH: Didn't match slave mem data and addr doesn't exist in native_if_mem. This is a SP addr with first access being a read, not saving to compare. Seen on native: 0x%0h, BE:0x%0h", 
                  addr, rdata, byte_en), UVM_NONE+50);
            end else begin
               //TODO: Check read's issue order and when the native mem's data was last updated. If read was issued before data update, then ignore the check
               if (native_if_mem[addr].location == NCORE) begin
                  `uvm_info(`LABEL, $psprintf(
                     "compare_native_rdata_slave_mem_data[0x%0h]: DATA_MISMATCH: Didn't match any of slave mem data or native commited data. This data was read from one of NCORE internal caches, skipping the check with slave mem data. Seen on native: 0x%0h, BE:0x%0h", 
                     addr, rdata, byte_en), UVM_NONE+50);
               end else begin
                  `uvm_info(`LABEL, $psprintf(
                     "compare_native_rdata_slave_mem_data[0x%0h]: DATA_MISMATCH: Didn't match any of slave mem data or native commited data, saving to compare later when a multi cacheline txn commits. Seen on native: 0x%0h, BE:0x%0h", 
                     addr, rdata, byte_en), UVM_NONE+50);
                  read_data.addr = addr;
                  read_data.data = rdata;
                  read_data.byte_en = byte_en;
                  if (byte_en != 'b0)
                     native_if_read_data.push_back(read_data);
               end
            end
         end
      end else begin
         if (m_mem_checker_cfg.is_sp_addr(addr)) begin
            `uvm_info(`LABEL, $psprintf(
               "compare_native_rdata_slave_mem_data[0x%0h]: DATA_MISMATCH: Didn't match slave mem data and addr doesn't exist in native_if_mem. This is a SP addr with first access being a read, not saving to compare. Seen on native: 0x%0h, BE:0x%0h", 
               addr, rdata, byte_en), UVM_NONE+50);
         end else begin
            `uvm_info(`LABEL, $psprintf(
               "compare_native_rdata_slave_mem_data[0x%0h]: DATA_MISMATCH: Didn't match slave mem data and addr doesn't exist in native_if_mem, saving to compare later when a multi cacheline txn commits. Seen on native: 0x%0h, BE:0x%0h", 
               addr, rdata, byte_en), UVM_NONE+50);
            read_data.addr = addr;
            read_data.data = rdata;
            read_data.byte_en = byte_en;
            if (byte_en != 'b0)
               native_if_read_data.push_back(read_data);
         end
      end
   end
endfunction : compare_native_rdata_slave_mem_data

////////////////////////////////////////////////////////////////////////////////
// Function: match_pending_native_read_data()
////////////////////////////////////////////////////////////////////////////////
function void mem_consistency_checker::match_pending_native_read_data(bit[63:0] addr, cache_data_t data, cache_byte_en_t byte_en);
   int                  w_byte_en = (2 ** <%=obj.wCacheLineOffset%>);
   cache_data_t         data_be;
   cache_data_t         ntvmem_data_be = '1;

   for (int dt_idx = 0; dt_idx < native_if_read_data.size(); dt_idx++) begin
      if (native_if_read_data[dt_idx].addr == addr[63:0]) begin
         ntvmem_data_be = 0;
         for (int idx=0; idx < w_byte_en; idx++) begin
            if (byte_en[idx] && native_if_read_data[dt_idx].byte_en[idx]) begin
               data_be[8*idx +: 8]       = data[8*idx +: 8];
               ntvmem_data_be[8*idx +: 8] = native_if_read_data[dt_idx].data[8*idx +: 8];
            end // if byte en == 1
            else begin
               data_be[8*idx +: 8]   = 'b0;
               ntvmem_data_be[8*idx +: 8]      = 'b0;
            end
         end // byte enable for loop
         `uvm_info(`LABEL, $psprintf(
            "match_pending_native_read_data[0x%0h]: Data in native_if_read_data[%0d]: 0x%0h, write data from multi cacheline write: 0x%0h", 
            addr, dt_idx, ntvmem_data_be, data_be), UVM_MEDIUM);
         if (data_be == ntvmem_data_be) begin
            `uvm_info(`LABEL, $psprintf(
               "match_pending_native_read_data[0x%0h]: DATA_MATCH: in native_if_read_data[%0d]: 0x%0h, write data from multi cacheline write: 0x%0h", 
               addr, dt_idx, ntvmem_data_be, data_be), UVM_MEDIUM);
               native_if_read_data.delete(dt_idx);
            dt_idx = dt_idx - 1;
         end
      end // if addr match
   end // foreach native_if_read_data
endfunction : match_pending_native_read_data 


////////////////////////////////////////////////////////////////////////////////
// Function: atomic_on_native_if()
////////////////////////////////////////////////////////////////////////////////
function void mem_consistency_checker::atomic_on_native_if(bit[63:0] addr);
   atomic_txn_addr_q.push_back(addr);
endfunction : atomic_on_native_if

////////////////////////////////////////////////////////////////////////////////
// Function: check_phase
// Description: Runs end of test checks and prints debug information
////////////////////////////////////////////////////////////////////////////////
function void mem_consistency_checker::check_phase(uvm_phase phase);
   bit error = 0;
   bit[63:0] native_addr;
   if (native_if_read_data.size() !== 0) begin
      foreach(native_if_read_data[idx]) begin
         if (!(native_if_read_data[idx].addr inside {atomic_txn_addr_q})) begin 
            `uvm_warning(`LABEL, $psprintf("native_if_read_data[0x%0h]: data: 0x%0h, BE: 0x%0h", native_if_read_data[idx].addr, native_if_read_data[idx].data, native_if_read_data[idx].byte_en));
            error = 1;
         end else begin
            `uvm_info(`LABEL, $psprintf("native_if_read_data[0x%0h]: data: 0x%0h, BE: 0x%0h - Ignoring becuase an atomic was seen on this addr", native_if_read_data[idx].addr, native_if_read_data[idx].data, native_if_read_data[idx].byte_en), UVM_NONE);
         end
      end
      if (error)
         `uvm_error("check_phase", $psprintf("mem_consistency_checker: There were %0d reads on native i/f that didn't pass any data comparisons", native_if_read_data.size()))
      else
         `uvm_info("check_phase", $psprintf("mem_consistency_checker: PASS: Native i/f read queues are empty for all addresses"), UVM_NONE)
   end else begin
      `uvm_info("check_phase", $psprintf("mem_consistency_checker: PASS: Native i/f read queues are empty for all addresses"), UVM_NONE)
   end
   //foreach(native_if_mem[idx]) begin
   error = 0;
   if (native_if_mem.first(native_addr)) begin
      do begin
         if (native_if_mem[native_addr].slave_data_waiting_native_data.size() !== 0) begin
            foreach(native_if_mem[native_addr].slave_data_waiting_native_data[idx]) begin
               `uvm_warning(`LABEL, $psprintf("slave_data_waiting_native_data[0x%0h]: data: 0x%0h, BE: 0x%0h", native_if_mem[native_addr].cacheline_addr, native_if_mem[native_addr].slave_data_waiting_native_data[idx], native_if_mem[native_addr].slave_data_waiting_native_byte_en[idx]));
            end
            error = 1;
         end else begin
            //`uvm_info(`LABEL, $psprintf("native_if_mem[native_addr].slave_data_waiting_native_data is empty for addr: 0x%0h", native_if_mem[native_addr].cacheline_addr), UVM_NONE);
         end
      end while(native_if_mem.next(native_addr));
   end
   if (error) begin
      `uvm_error("check_phase", $psprintf("mem_consistency_checker: There were some writes on slave i/f that didn't pass any data comparisons, check above warnings for details"))
   end else begin
      `uvm_info("check_phase", $psprintf("mem_consistency_checker: PASS: Slave i/f write queues are empty for all addresses"), UVM_NONE)
   end
endfunction : check_phase

// End of file
