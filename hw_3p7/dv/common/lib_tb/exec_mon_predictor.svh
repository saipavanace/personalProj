//typedef used for exclusive Monitor
   typedef int int_queue[$];
   // an entry in ex_min
   typedef struct {
	
         bit [addrMgrConst::W_SEC_ADDR -1:0] tagged_addr; //include NS bit on MSB
         bit [WSMISRCID+WSMIMPF2-1:0]        tagged_unit_id;
         bit                                 tagged_entry = 0;
   } tagged_exec_mon_t;
  
   typedef tagged_exec_mon_t exec_mon_tab[];
   typedef tagged_exec_mon_t exec_mon_queue[$];
   // type of operation
   typedef enum int {

      load,
      ex_load,
      store,
      ex_store
      
   } operation_t;
   // Status of exmon process 
    typedef enum int {
    IDLE,
    EX_FAIL, 
    EX_PASS} 
    exmon_status_t;
    
    
   typedef struct {
	
         bit event_trig = 0; //exmon_event is trigged
         time event_time       ;
   
   } exec_mon_event_t;
   
   typedef struct {

      exmon_status_t exmon_status;
      exec_mon_event_t exmon_event;
   
   } exec_mon_result_t;


    // Typedef to define exmon scenarios
    typedef enum int {
    loadex_addr_match_axid_funitid_match,
	 loadex_addr_match_axid_funitid_no_match_full,
    loadex_addr_match_axid_funitid_no_match_not_full,
    loadex_addr_no_match_axid_funitid_match,
    loadex_addr_no_match_axid_funitid_no_match_full,
    loadex_addr_no_match_axid_funitid_no_match_not_full,
    store_addr_match,
    store_addr_no_match,
    storeex_addr_match_axid_funitid_match,
    storeex_addr_match_axid_funitid_no_match,
    storeex_addr_no_match

    } exmon_scenario_t;
class exec_mon_predictor extends uvm_object;
  `uvm_object_param_utils(exec_mon_predictor)
  

   int exmon_size =  <%=obj.nExclusiveEntries%>;
   // exclusive Monitor object
   exec_mon_tab exec_mon;
   // exclusive monitor number of entries

   // Counter for round robin remplacement in exclusive monitor
   int evict_entry = 0 ; 
   
   smi_mpf1_asize_t  ex_asize;
   smi_mpf1_alength_t ex_burst_len;
   bit ex_vz = 1;

   // Covgroup for exclusive Monitor Scenario : 

   exmon_scenario_t m_exmon_scenario;
   covergroup cg_exmon;
        //#Cover.DII.ExMon.LoadScenario
        //#Cover.DMI.ExMon.LoadScenario
        //#Cover.FSYS.sysevent.DII.ExclusiveLoad
        //#Cover.FSYS.sysevent.DMI.ExclusiveLoad
      cp_exmon_scenario_load: coverpoint m_exmon_scenario {
            bins loadex_addr_match_axid_funitid_match                   = {loadex_addr_match_axid_funitid_match};
	        bins cp_loadex_addr_match_axid_funitid_no_match_full        = {loadex_addr_match_axid_funitid_no_match_full};
            bins cp_loadex_addr_match_axid_funitid_no_match_not_full    = {loadex_addr_match_axid_funitid_no_match_not_full};
            bins cp_loadex_addr_no_match_axid_funitid_match             = {loadex_addr_no_match_axid_funitid_match};
            bins cp_loadex_addr_no_match_axid_funitid_no_match_full     = {loadex_addr_no_match_axid_funitid_no_match_full};
            bins cp_loadex_addr_no_match_axid_funitid_no_match_not_full = {loadex_addr_no_match_axid_funitid_no_match_not_full};
        }

	    //#Cover.DII.ExMon.StoreScenario
           //#Cover.DMI.ExMon.StoreScenario
           //#Cover.FSYS.sysevent.DII.ExclusiveStore
           //#Cover.FSYS.sysevent.DMI.ExclusiveStore 
      cp_exmon_scenario_store: coverpoint m_exmon_scenario {
	        bins cp_store_addr_match                                  = {store_addr_match};
            bins cp_store_addr_no_match                               = {store_addr_no_match};
            bins cp_storeex_addr_match_axid_funitid_match             = {storeex_addr_match_axid_funitid_match};
            bins cp_storeex_addr_match_axid_funitid_no_match          = {storeex_addr_match_axid_funitid_no_match};
            bins cp_storeex_addr_no_match                             = {storeex_addr_no_match};
	    }
      //#Cover.DII.ExMon.Asize
      //#Cover.DMI.ExMon.Asize
      `ifndef FSYS_COVER_ON
      cp_exclusive_burst_size: coverpoint ex_asize {
            bins bytes_1   = {0};
            bins bytes_2   = {1};
            bins bytes_3   = {2};
            bins bytes_8   = {3};
            bins bytes_16  = {4};
            bins bytes_32  = {5};
            bins bytes_64  = {6};
            }
       `endif
      //#Cover.DII.ExMon.Visibility
      //#Cover.DMI.ExMon.Visibility
      cp_exclusive_visibility : coverpoint ex_vz {
            bins legal_vz = {1};
            illegal_bins illegal_vz = {0}; // exclusive cmd should not have EWA CONC-10036
            }
      `ifndef FSYS_COVER_ON      
      //#Cover.DII.ExMon.Alen 
      //#Cover.DMI.ExMon.Alen 
      cp_exclusive_burst_length: coverpoint ex_burst_len ;
      `endif
   endgroup

  
  function new(string name = "exec_mon_predictor");
    super.new(name);
    if (exmon_size > 0) exec_mon = new[exmon_size];
    cg_exmon = new();
  endfunction

function  exec_mon_result_t predict_exmon( smi_seq_item msg);
       
      bit [addrMgrConst::W_SEC_ADDR -1:0] sec_addr; //{ns,addr}
      bit [WSMISRCID+WSMIMPF2-1 :0] unit_id; //{mpf2,initiator_id}
      operation_t op_type;
      exec_mon_queue match_addr_list;
      int tag_index_unit_id;
      //// Exclusive monitor status 
      exmon_status_t m_exmon_status = IDLE;
      bit full;
      exec_mon_result_t m_exmon_result;

      
      
      unit_id = {msg.smi_mpf2_flowid, msg.smi_src_ncore_unit_id};
      sec_addr = {msg.smi_ns , msg.smi_addr[WSMIADDR-1:6]};
      op_type = get_operation_type(msg);



      `uvm_info($sformatf("%m"),  $sformatf("funit_id:%0h addr:%0h op_type:%s mpf2 : %0h flowid :%0h",msg.smi_src_ncore_unit_id, msg.smi_addr, op_type.name(),msg.smi_mpf2,msg.smi_mpf2_flowid), UVM_MEDIUM)
      `uvm_info($sformatf("%m"),  $sformatf("unit_id:%0h sec_addr :%0h", unit_id,sec_addr), UVM_MEDIUM)
      // get list of all matching address
      match_addr_list = get_match_addr_list(sec_addr);
      // get index in exclusive monitor of matching unit_id
      tag_index_unit_id     = get_match_unit_id(unit_id,match_addr_list,op_type);
      ////////////////////////////////////////////////////////////////////////

      /////// Exlusive laod

      ////////////////////////////////////////////////////////////////////////////
      if (op_type == ex_load) begin
         //Get asize, vz and burst length for coverage
         ex_asize       = msg.smi_mpf1_asize;
         ex_vz          = msg.smi_vz;
         ex_burst_len   = msg.smi_mpf1_alength;
         // match addr and match unit_id => Do nothing
         if ( match_addr_list.size()>0 && tag_index_unit_id != -1) begin
         m_exmon_scenario = loadex_addr_match_axid_funitid_match;
         `uvm_info($sformatf("%m"), $sformatf("Match addr and match unit_id => Do nothing"), UVM_MEDIUM)
         end
         // Match addr and no match unit_id => add new entry dependin on tag monitor status (Full or not full )
         else if (match_addr_list.size()>0 && tag_index_unit_id == -1) begin

            full = add_exmon_entry(sec_addr,unit_id);
            if (full) m_exmon_scenario = loadex_addr_match_axid_funitid_no_match_full;
            else m_exmon_scenario = loadex_addr_match_axid_funitid_no_match_not_full;
             `uvm_info($sformatf("%m"), $sformatf("Match addr and no match unit_id =>  add new entry depending on tag monitor status"), UVM_MEDIUM)
         end
         //no match addr and match unit_id => Replace the tag
         else if (match_addr_list.size() == 0 && tag_index_unit_id != -1) begin

            update_exmon_tag(sec_addr,tag_index_unit_id);
             m_exmon_scenario = loadex_addr_no_match_axid_funitid_match;
            `uvm_info($sformatf("%m"), $sformatf("No match addr and Match unit_id =>  Replace the tag"), UVM_MEDIUM)
         end

         // No match addr and no match unit_id => add new entry depending on exec monitor status (Full or not full)
         else if (match_addr_list.size() == 0 && tag_index_unit_id == -1) begin

            full = add_exmon_entry(sec_addr,unit_id);
            if (full) m_exmon_scenario = loadex_addr_no_match_axid_funitid_no_match_full;
            else m_exmon_scenario = loadex_addr_no_match_axid_funitid_no_match_not_full;
            `uvm_info($sformatf("%m"), $sformatf("No match addr and no match unit_id =>  add new entry depending on tag monitor status"), UVM_MEDIUM)
         end
         m_exmon_status = EX_PASS;
      end
      ////////////////////////////////////////////////////////////////////////

      /////// load

      ////////////////////////////////////////////////////////////////////////////

      else if (op_type == load) begin
         `uvm_info($sformatf("%m"), $sformatf("It's a non-exclusive load operation => Do nothing"), UVM_MEDIUM)
      end

      ////////////////////////////////////////////////////////////////////////

      /////// store 

      ////////////////////////////////////////////////////////////////////////////   
      else if (op_type == store) begin
         // match addr  ==> Clear all matching address
         if (match_addr_list.size() > 0) begin
            Clear_exmon_match_addr(sec_addr);
            m_exmon_scenario = store_addr_match;
            `uvm_info($sformatf("%m"), $sformatf("store : match addr  ==> Clear all matching address"), UVM_MEDIUM)
            m_exmon_result.exmon_event.event_trig = 1; // exclusive Monitor event is trigged
            m_exmon_result.exmon_event.event_time = $time;
         end
  
         // No match addr ==> do nothing
         else begin 
             m_exmon_scenario = store_addr_no_match;
               `uvm_info($sformatf("%m"), $sformatf("It's non exclusive Store operation with no match addr => Do nothing"), UVM_MEDIUM)
         end
      end
      ////////////////////////////////////////////////////////////////////////

      /////// store exclusive

      ////////////////////////////////////////////////////////////////////////////   
      else if (op_type == ex_store) begin
         //Get asize, vz and burst length for coverage
         ex_asize       = msg.smi_mpf1_asize;
         ex_vz          = msg.smi_vz;
         ex_burst_len   = msg.smi_mpf1_alength;
           // match addr and match unit_id ==> Clear all matching address
         if (match_addr_list.size() > 0 && tag_index_unit_id != -1) begin
            Clear_exmon_match_addr(sec_addr);
            //#Check.DII.ExMon.ExPassStatus
            //#Check.DMI.ExMon.ExPassStatus
            m_exmon_status = EX_PASS;
            m_exmon_scenario = storeex_addr_match_axid_funitid_match;
            `uvm_info($sformatf("%m"), $sformatf("EX store : match addr and match unit_id ==> Clear all matching address : status = %s", m_exmon_status.name()), UVM_MEDIUM)
            m_exmon_result.exmon_event.event_trig = 1; // exclusive Monitor event is trigged
            m_exmon_result.exmon_event.event_time = $time;
         end

          // match addr and no match unit ==> do nothing
         else if (match_addr_list.size() > 0 && tag_index_unit_id == -1) begin
            //#Check.DII.ExMon.ExFailStatus
            //#Check.DMI.ExMon.ExFailStatus
            m_exmon_status = EX_FAIL;
            m_exmon_scenario = storeex_addr_match_axid_funitid_no_match;
            `uvm_info($sformatf("%m"), $sformatf("It's an exclusive Store operation with match addr and no match unit_id : status = %s => Do nothing", m_exmon_status.name()), UVM_MEDIUM)
         end
         // No match addr ==> do nothing
         else if (match_addr_list.size() == 0) begin
            //#Check.DII.ExMon.ExFailStatus
            //#Check.DMI.ExMon.ExFailStatus
            m_exmon_status = EX_FAIL;
            m_exmon_scenario = storeex_addr_no_match;
            `uvm_info($sformatf("%m"), $sformatf("It's an exclusive Store operation with NO match : status = %s => Do nothing", m_exmon_status.name()), UVM_MEDIUM)
         end
      end

      m_exmon_result.exmon_status = m_exmon_status;

      print_exmon();
      collect_exmon_cov(); 
      return(m_exmon_result); // this is used only if op_type == ex_store

      
   endfunction : predict_exmon

   function bit add_exmon_entry(bit [addrMgrConst::W_SEC_ADDR -1:0] sec_addr , bit [WSMISRCID+WSMIMPF2-1:0] unit_id);
      bit full ;
      int_queue find_q;

      //Finding available entries tagged_entry = 0;
      
      find_q = exec_mon.find_index with (
            (item.tagged_entry == 0)
      );
         // exclusive monitor is not full
      if (find_q.size() > 0) begin
         exec_mon[find_q[0]].tagged_addr     = sec_addr;
         exec_mon[find_q[0]].tagged_unit_id  = unit_id;
         exec_mon[find_q[0]].tagged_entry    = 1;
         full = 0 ;
      end
      // exclusive monitor is  full ( all entries has tagged_entry = 1 )
      else begin
         exec_mon[evict_entry].tagged_addr = sec_addr;
         exec_mon[evict_entry].tagged_unit_id = unit_id;
          exec_mon[evict_entry].tagged_entry  = 1;
         // selection is based on round robin
         evict_entry = (evict_entry == exmon_size-1) ? 0 : evict_entry + 1;
         full = 1; 
      end

      return(full);
   endfunction : add_exmon_entry;

   function void update_exmon_tag(bit [addrMgrConst::W_SEC_ADDR -1:0] sec_addr, int tag_idex);

   
      exec_mon[tag_idex].tagged_addr = sec_addr;


   endfunction : update_exmon_tag;


   function void Clear_exmon_match_addr(bit [addrMgrConst::W_SEC_ADDR -1:0] sec_addr);
      int_queue find_q;
   
      find_q = exec_mon.find_index with (
         (item.tagged_addr == sec_addr)
      );
      foreach(find_q[i]) begin

         exec_mon[find_q[i]].tagged_addr = 0;
         exec_mon[find_q[i]].tagged_unit_id = 0;
         exec_mon[find_q[i]].tagged_entry = 0;
      end


   endfunction : Clear_exmon_match_addr;

   function int get_match_unit_id( bit [WSMISRCID+WSMIMPF2-1:0] unit_id , ref exec_mon_queue match_addr_list , operation_t op_type);
      int tag_unit_id = -1 ;
      int_queue find_q;
      int_queue find_q_id;
      // For store cmd or ex_store cmd with no match addr or load cmd no need to get matched unit_id
      if ((op_type == store) || (op_type == ex_store && match_addr_list.size() == 0) || (op_type == load)) begin  
            
            tag_unit_id = -1 ;
      
      end else begin
      // case 1 : there's no adress match <=> match_addr_list is empty
         // should going through all exclusive monitor entries
         if (match_addr_list.size() == 0) begin
            find_q = exec_mon.find_index with (
               (item.tagged_unit_id == unit_id && item.tagged_entry == 1)
            );
            if (find_q.size() == 1) begin

               tag_unit_id = find_q[0];
            end   
            else if (find_q.size() > 1)   `uvm_error($sformatf("%m"), $sformatf("match more than 1 tag for unit_id = %0d", unit_id))
            
         end
         // addr match 
         else begin
            find_q = match_addr_list.find_index with (
               (item.tagged_unit_id == unit_id && item.tagged_entry == 1)
            );
         
            if (find_q.size() == 0) begin
               find_q_id = exec_mon.find_index with (
                  (item.tagged_unit_id == unit_id && item.tagged_entry == 1)
               );
               if(find_q_id.size() == 1) begin //match ID on different entry ==> need to replace the tag so don't care about matching address
                  tag_unit_id = find_q_id[0];
                  match_addr_list.delete();
               end
               else if (find_q_id.size() > 1)   `uvm_error($sformatf("%m"), $sformatf("match more than 1 tag for unit_id = %0d", unit_id))

            end else tag_unit_id = find_q[0];
         end

      end
      return(tag_unit_id);
   endfunction : get_match_unit_id;

      function exec_mon_queue get_match_addr_list( bit [addrMgrConst::W_SEC_ADDR -1:0] sec_addr);
      exec_mon_queue find_q;

      find_q = exec_mon.find with (
         (item.tagged_addr == sec_addr && item.tagged_entry == 1 )
      );

      return(find_q);
   endfunction : get_match_addr_list;


   function operation_t get_operation_type (smi_seq_item msg);

      operation_t op_type;
      if(msg.isCmdNcRdMsg()) begin;
         if(msg.smi_es)  op_type = ex_load;
         else op_type = load;
      end
      else if (msg.isCmdNcWrMsg()) begin
         if(msg.smi_es)  op_type = ex_store;
         else op_type = store;
      end 
      // DMI : CONC-13190 : all atomics are considered to be writes. So an atomic reaching the monitor should behave like a non exclusive NC write.
      else if( msg.isCmdAtmStoreMsg() || msg.isCmdAtmLoadMsg()) begin
          `uvm_info($sformatf("%m"), $sformatf("exlusive monitor : It's an atomic transaction :  0x%h ",msg.smi_msg_type), UVM_LOW)
         op_type = store;
      end
      return (op_type);
   endfunction : get_operation_type;

   function void print_exmon();

      // printing the content of exclusive monitor entries
      foreach (exec_mon[i]) begin
         `uvm_info($sformatf("%m"), $sformatf("exlusive monitor entries %0d: ",i), UVM_MEDIUM)
         `uvm_info($sformatf("%m"), $sformatf("exlusive monitor tagged_addr = 0x%h", exec_mon[i].tagged_addr), UVM_MEDIUM)
         `uvm_info($sformatf("%m"), $sformatf("exlusive monitor tagged_unit_id = 0x%h", exec_mon[i].tagged_unit_id), UVM_MEDIUM)
       end
     


   endfunction : print_exmon;

   
function void collect_exmon_cov();

cg_exmon.sample();

endfunction : collect_exmon_cov
endclass
