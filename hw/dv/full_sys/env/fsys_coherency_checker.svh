////////////////////////////////////////////////////////////////////////////////
//
// Author       : Satya Prakash
// Purpose      : Maintain each cacheline state in all coherent capable  agent.
// Description  : Monitor each AIU's native i/f and smi i/f (for AXI4+PC) transactions and call appropriate
//                functions to keep update state of cacheline  in cache of all coherent capable agent. 
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
   var aiu_NumCores      = [];

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
// fsys_coherency_checker class code starts here
////////////////////////////////////////////////////////////////////////////////
import uvm_pkg::*;
`include "uvm_macros.svh"

`undef LABEL
`define  LABEL "fsys_coherency_checker"

class fsys_coherency_checker extends uvm_object;

   `uvm_object_param_utils(fsys_coherency_checker)

   // Memory model arrays
   cache_dir_state_t    system_cache_dir[cache_dir_addr_t];

   extern function new(string name = "fsys_coherency_checker");
   extern function void check_state(bit [63:0] addr, bit ns);
   extern function void update_state(bit [63:0] addr, bit ns,bit [7:0] funit_idx,cache_state_t state,bit flush = 0);
   extern function bit  check_uc_ud(bit [63:0] addr, bit ns);
   extern function bit  check_ucud_scsd(bit [63:0] addr, bit ns);
   extern function bit  check_dirties(bit [63:0] addr, bit ns);
   extern function cache_state_t get_state(bit [63:0] addr, bit ns, bit [7:0] funit_idx );
endclass : fsys_coherency_checker

function fsys_coherency_checker::new(string name = "fsys_coherency_checker");
   super.new(name);
endfunction : new

function void fsys_coherency_checker::update_state(bit [63:0] addr, bit ns, bit [7:0] funit_idx,cache_state_t state,bit flush = 0);
       bit [64:0] cache_idx;
       bit [63:0] addr_claligned;
       int state_q[$],stateSC_q[$];
       cache_state_t init_state,end_state;

       addr_claligned = (addr >>6)<<6;
       `uvm_info(`LABEL,$sformatf(" updating Cacheline addr: %0h ns: %0b agent:%0d state:%0s flush:%0b", addr_claligned,ns,funit_idx,state.name(),flush),UVM_NONE+50);
       cache_idx = {ns,addr_claligned};
         if(!system_cache_dir.exists(cache_idx)) begin
       `uvm_info(`LABEL,$sformatf("  Cacheline does not exist ,initilizing addr: %0h ns: %0b", addr_claligned,ns),UVM_NONE+50);
           foreach(system_cache_dir[cache_idx][idx])
             system_cache_dir[cache_idx][idx] = IX;
             init_state = IX;
         end
         else begin
           init_state = get_state(addr,ns,funit_idx);
         end
         
         `uvm_info(`LABEL,$sformatf(" updating Cacheline addr: %0h ns: %0b agent:%0d init_state:%0s end_state:%0s", addr_claligned,ns,funit_idx,init_state.name(),state.name()),UVM_NONE+50);
         system_cache_dir[cache_idx][funit_idx] = state;
         check_state(addr_claligned,ns);
         if(state == IX)begin
           if(system_cache_dir.exists(cache_idx)) begin
             state_q = system_cache_dir[cache_idx].find_index with(item == UC || item == UD || item == SC || item == SD);
             stateSC_q = system_cache_dir[cache_idx].find_index with(item == SC);
             if(!state_q.size())begin
               `uvm_info(`LABEL,$sformatf("  Cacheline invalidated in all agent, deleting addr: %0h ns: %0b", addr_claligned,ns),UVM_NONE+50);
               system_cache_dir.delete(cache_idx);
             end
             else if((state_q.size() == stateSC_q.size()) && flush) begin
              `uvm_info(`LABEL,$sformatf("  Cacheline flushing  in all agent due to WrBk, deleting addr: %0h ns: %0b", addr_claligned,ns),UVM_NONE+50);
               system_cache_dir.delete(cache_idx);
             end
           end
         end


endfunction:update_state

function cache_state_t fsys_coherency_checker::get_state(bit [63:0] addr, bit ns, bit [7:0] funit_idx );
       bit [64:0] cache_idx;
       bit [63:0] addr_claligned;
       cache_state_t  state;
       addr_claligned = (addr >>6)<<6;
       `uvm_info(`LABEL,$sformatf(" updating Cacheline addr: %0h ns: %0b agent_id:%0d ", addr_claligned,ns,funit_idx),UVM_NONE+50);
       cache_idx = {ns,addr_claligned};

       if(system_cache_dir.exists(cache_idx)) begin
          state = system_cache_dir[cache_idx][funit_idx];
       end
       else begin
          state = IX;
       end  
      return state; 
endfunction:get_state

function void fsys_coherency_checker::check_state(bit [63:0] addr, bit ns);
       bit [64:0] cache_idx;

       cache_idx = {ns,addr};

       if(!system_cache_dir.exists(cache_idx)) begin
         `uvm_error(`LABEL,$sformatf("CacheLine Addr %0x ns :%0b does not exists in any Master cache",addr,ns)); 
       end
       else  if(check_uc_ud(addr,ns))begin
         `uvm_error(`LABEL,$sformatf(" UC/UD state can exist in Only one master :CacheLine Addr %0x ns :%0b",addr,ns)); 
       end  
       else if(check_ucud_scsd(addr,ns))begin
         `uvm_error(`LABEL,$sformatf("UC and SC/SD can't exist together  CacheLine Addr %0x ns :%0b",addr,ns)); 
       end
       else if(check_dirties(addr,ns))begin
         `uvm_error(`LABEL,$sformatf("More than 1 master can't hold dirt  CacheLine Addr %0x ns :%0b",addr,ns)); 
       end
         `uvm_info(`LABEL,$sformatf(" cacheline  addr: %0h ns: %0b", addr,ns),UVM_NONE+50);
       foreach(system_cache_dir[cache_idx][idx])
         `uvm_info(`LABEL,$sformatf("agent : %0d state: %0s", idx,system_cache_dir[cache_idx][idx].name()),UVM_NONE+50);
       
endfunction:check_state

function bit fsys_coherency_checker::check_uc_ud(bit [63:0] addr, bit ns);
        int ucud_q[$]; 
        bit [64:0] cache_idx;

        cache_idx = {ns,addr}; 
        ucud_q = system_cache_dir[cache_idx].find_index with(item == UC || item == UD);

        if(ucud_q.size()>1) begin
          return 1;
        end
        else begin
          return 0;
        end
endfunction:check_uc_ud

function bit fsys_coherency_checker::check_ucud_scsd(bit [63:0] addr, bit ns);
        int ucud_q[$],scsd_q[$];
        bit [64:0] cache_idx;

        cache_idx = {ns,addr}; 

        ucud_q = system_cache_dir[cache_idx].find_index with(item == UC || item == UD);

        if(ucud_q.size() ==1) begin
          scsd_q = system_cache_dir[cache_idx].find_index with(item == SC || item == SD);
          if(scsd_q.size()>0)begin
            return 1;
          end
          else begin
            return 0;
          end
        end
        else begin
          return 0;
        end
endfunction:check_ucud_scsd

function bit fsys_coherency_checker::check_dirties(bit [63:0] addr, bit ns);
        int udsd_q[$];
        bit [64:0] cache_idx;

        cache_idx = {ns,addr}; 

        udsd_q = system_cache_dir[cache_idx].find_index with(item == UD || item == SD);

        if(udsd_q.size() >1) begin
            return 1;
        end
        else begin
          return 0;
        end
endfunction:check_dirties
// End of file
