<%
let numChiAiu = 0; // Number of CHI AIUs
let numACEAiu = 0; // Number of ACE AIUs
let numIoAiu = 0; // Number of IO AIUs
let numCAiu = 0; // Number of Coherent AIUs
let numNCAiu = 0; // Number of Non-Coherent AIUs
let chiaiu0;  // strRtlNamePrefix of chiaiu0
let aceaiu0;  // strRtlNamePrefix of aceaiu0
let ncaiu0;   // strRtlNamePrefix of ncaiu0
let idxIoAiuWithPC = 0; // To get valid index of NCAIU with ProxyCache
let numDmiWithSMC = 0; // Number of DMIs with SystemMemoryCache
let idxDmiWithSMC = 0; // To get valid index of DMI with SystemMemoryCache
let numDmiWithSP = 0; // Number of DMIs with ScratchPad memory
let idxDmiWithSP = 0; // To get valid index of DMIs with ScratchPad memory
let numDmiWithWP = 0; // Number of DMIs with WayPartitioning
let idxDmiWithWP = 0; // To get valid index of DMIs with WayPartitioning

for(let pidx = 0; pidx < obj.nDMIs; pidx++) {
    if(obj.DmiInfo[pidx].useCmc)
       {
         numDmiWithSMC++;
         idxDmiWithSMC = pidx;
         if(obj.DmiInfo[pidx].ccpParams.useScratchpad)
            {
              numDmiWithSP++;
              idxDmiWithSP = pidx;
            }
         if(obj.DmiInfo[pidx].useWayPartitioning)
            {
              numDmiWithWP++;
              idxDmiWithWP = pidx;
            }
       }
}
for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface.includes('CHI'))) 
       { 
         if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
          numChiAiu++ ; numCAiu++ ; 
       }
    else
       { numIoAiu++ ; 
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { 
             if(numACEAiu == 0) { aceaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
             numCAiu++; numACEAiu++; 
         } else {
             if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
                 if (numNCAiu == 0) { ncaiu0  = obj.AiuInfo[pidx].strRtlNamePrefix + "_0"; }
             } else {
                 if (numNCAiu == 0) { ncaiu0  = obj.AiuInfo[pidx].strRtlNamePrefix; }
             }
             numNCAiu++ ;
         }
         if(obj.AiuInfo[pidx].useCache) idxIoAiuWithPC = numNCAiu;
       }
}

// For DMI registers's offset value
// ALLAN: This is not used. And it iterates through every DMI. So, I am not sure if it returns the correct value
function getDmiOffset(register) {
    let found=0;
    let offset=0; 
    obj.DmiInfo.forEach(function regOffsetFindSB(item,i){
                            if(!found){
                               const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                               if(reg != undefined) {
                                  found = 1;
                                  offset = reg.addressOffset;
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}


// For CHI registers's offset value
// ALLAN: This is not used. And it iterates through every DMI. So, I am not sure if it returns the correct value
function getChiOffset(register) {
    let found=0;
    let offset=0; 
    obj.AiuInfo.forEach(function regOffsetFindSB(item,i){
                            if(item.fnNativeInterface.includes('CHI')) {
                               if(!found){
                                  const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                                  if(reg != undefined) {
                                     found = 1;
                                     offset = reg.addressOffset;
                                  }
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For IOAIU registers's offset value
// ALLAN: This is not used. And it iterates through every AIU. So, I am not sure if it returns the correct value
function getIoOffset(register) {
    let found=0;
    let offset=0; 
    obj.AiuInfo.forEach(function regOffsetFindSB(item,i){
                            if(!(item.fnNativeInterface.includes('CHI'))) {
                               if(!found){
                                  const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                                  if(reg != undefined) {
                                     found = 1;
                                     offset = reg.addressOffset;
                                  }
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For DCE registers's offset value
// ALLAN: This is not used. And it iterates through every DCE. So, I am not sure if it returns the correct value
function getDceOffset(register) {
    let found=0;
    let offset=0; 
    obj.DceInfo.forEach(function regOffsetFindSB(item,i){
                            if(!found){
                               const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                               if(reg != undefined) {
                                  found = 1;
                                  offset = reg.addressOffset;
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For DVE registers's offset value
// ALLAN: This is not used.
function getDveOffset(register) {
    let found=0;
    let offset=0; 
    obj.DveInfo.forEach(function regOffsetFindSB(item,i){
                            if(!found){
                               const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                               if(reg != undefined) {
                                  found = 1;
                                  offset = reg.addressOffset;
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}
%>

class chi_aiu_vseq#(int ID = 0) extends chi_aiu_base_vseq#(ID);
`include "<%=obj.BlockId%>_smi_widths.svh";
`include "<%=obj.BlockId%>_smi_types.svh";
 
   `uvm_object_param_utils(chi_aiu_vseq#(ID))

  int num_txn_sent=0;
  semaphore s_txdat = new(1);

  int k_access_boot_region;
  bit k_directed_test;
  bit k_directed_test_alloc;
  int boot_coh_access;
  int              find_snpattr_q[$];

  int user_qos;
  int aiu_qos;		

  int num_alt_qos_values;
  int seq_iter;
  int total_aiu_qos_cycle;
  int aiu_qos1;
  int aiu_qos1_cycle;
  int aiu_qos2;
  int aiu_qos2_cycle;
  int aiu_qos3;
  int aiu_qos3_cycle;
  int aiu_qos4;
  int aiu_qos4_cycle;
  int duty_cycle; // duty_cycle = nbr of cycle of seq of transaction ex: WRRR => duty_cycle=4
  bit pause_main_traffic =0;

  static int qos_cycle_count;
  static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  static uvm_event ev_seq_done;
    <% if(obj.testBench == "fsys") { %>
    uvm_event ev_sim_done;
    <% } %>

  extern function new(string s = "chi_aiu_vseq");

  extern task body();

  //
  //Internal methods
  //
<%  if(obj.testBench!="chi_aiu") { %>
  extern task access_boot_region_seq();
  extern task write_memory(input addr_width_t addr, bit[511:0] data, int size, input bit init_ccid_zero=1);
  extern task atomic(input chi_bfm_opcode_type_t atomic_op_type=ATOMIC_ST_CMD, input chi_bfm_opcode_t atomic_op=BFM_ATOMICSTORE_STADD, input bit coh=0,input addr_width_t addr, bit[127:0] data, int size, input bit init_ccid_zero=1, input int width,  output bit[63:0] rd_data);
  extern task write_memory_coh(input addr_width_t addr, bit[511:0] data, int size, input bit init_ccid_zero=1);
  extern task write_flush_cache(input addr_width_t addr, bit[511:0] data, int size, input chi_bfm_cache_state_t cache_state);
  extern task read_memory(input addr_width_t addr, output bit[511:0] data, input int size, input int width);
  extern task read_memory_coh(input addr_width_t addr, output bit[511:0] data, input int size, input int width, input bit align_data_as_per_ccid=0);
  extern task read_coh(input addr_width_t addr, output bit[31:0] data);
  extern task chi_trace_capture_program(input bit[31:0] trace_capture_queue[$]);
  extern task chi_trace_accum_check(input bit[31:0] trace_capture_queue[$]);
  extern task chi_trace_trigger_program(input bit[31:0] trace_trigger_queue[$]);
<% } %>
endclass: chi_aiu_vseq

function chi_aiu_vseq::new(string s = "chi_aiu_vseq");
  super.new(s);

  uname = $psprintf("chi_aiu_vseq[%0d]", ID);

  k_access_boot_region = 0; 
  user_qos = 0;
endfunction: new

task chi_aiu_vseq::body();

  int txnid;
  addr_width_t boot_addr;
  chi_bfm_opcode_type_t  atomic_ops[] = {ATOMIC_LD_CMD, ATOMIC_ST_CMD, ATOMIC_SW_CMD, ATOMIC_CM_CMD};
  
  //newperf test  
  int nbr_write_coh_in_duty_cycle;
  int nbr_write_noncoh_in_duty_cycle;
  realtime delay_chi<%=obj.AiuInfo[obj.Id].nUnitId%>_req;  // add delay between 2 req ex: delay_chi0_req=200ns to allow the measure on the latency
 
   nbr_write_coh_in_duty_cycle = duty_cycle*m_args.k_wr_cohunq_pct.get_value()/100;
   nbr_write_noncoh_in_duty_cycle = duty_cycle*m_args.k_wr_noncoh_pct.get_value()/100;
  //end newperf test 
  
// set this dynamically from outside
//  if (!$value$plusargs("k_access_boot_region=%d",k_access_boot_region)) begin
//      k_access_boot_region = 0;
//  end
  if (!$value$plusargs("boot_coh_access=%d",boot_coh_access)) begin
      boot_coh_access = 0;
  end

  `uvm_info("CHIAIU<%=obj.AiuInfo[obj.Id].nUnitId%> SEQ", $sformatf("Creating ev_seq_done with name %s", seq_name), UVM_NONE)
  ev_seq_done = ev_pool.get(seq_name);
  <% if(obj.testBench == "fsys") { %>
  ev_sim_done = ev_pool.get("sim_done");
  <% } %>

  if($value$plusargs("<%=obj.BlockId%>_alt_qos_values=%d", num_alt_qos_values)) begin
    if(num_alt_qos_values <= 1) begin
 `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_alt_qos_values has to be greater than 1.  Specified value=%0d", num_alt_qos_values))
    end
    if(num_alt_qos_values > 1) begin
 if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos1=%d", aiu_qos1)) begin
    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos1 not specified."))
 end
 if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos1_cycle=%d", aiu_qos1_cycle)) begin
    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos1_cycle not specified."))
 end
 if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos2=%d", aiu_qos2)) begin
    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos2 not specified."))
 end
 if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos2_cycle=%d", aiu_qos2_cycle)) begin
    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos2_cycle not specified."))
 end
       total_aiu_qos_cycle = aiu_qos1_cycle + aiu_qos2_cycle;
    end
    if(num_alt_qos_values > 2) begin
 if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos3=%d", aiu_qos3)) begin
    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos3 not specified."))
 end
 if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos3_cycle=%d", aiu_qos3_cycle)) begin
    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos3_cycle not specified."))
 end
       total_aiu_qos_cycle += aiu_qos3_cycle;
    end
    if(num_alt_qos_values > 3) begin
 if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos4=%d", aiu_qos4)) begin
    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos4 not specified."))
 end
 if(!$value$plusargs("<%=obj.BlockId%>_aiu_qos4_cycle=%d", aiu_qos4_cycle)) begin
    `uvm_error(get_full_name(), $sformatf("<%=obj.BlockId%>_aiu_qos4_cycle not specified."))
 end
       total_aiu_qos_cycle += aiu_qos4_cycle;
    end
    if(num_alt_qos_values > 4) begin
 `uvm_error(get_full_name(), $sformatf("Only supporting maximum <%=obj.BlockId%>_alt_qos_values of 4.  Specified value=%0d", num_alt_qos_values))
    end
 end

  `uvm_info(uname, "Start CHI AIU VSEQ", UVM_MEDIUM)

// These tasks are called in concerto test body for full system
// no need to call them here for full system
<%  if(obj.testBench!="fsys") { %>
  //Initiate link and txs sequence
  `uvm_info(uname, "construct Link seq", UVM_MEDIUM)
fork
  construct_lnk_seq();
  construct_txs_seq();
join
<% } %>

<% if(obj.testBench != "fsys") { %>
  construct_sysco_seq(boot_sysco_st);
<% } %>

<%  if(obj.testBench!="chi_aiu") { %>
//  enum_boot_seq(); // Will start from FullSys' "exec_inhouse_seq" sequence, as CSR programming should be done once.
<% } %>
 
  `uvm_info(uname, "Start CHI AIU TRAFFIC", UVM_MEDIUM)
  fork
  
    //Pop CHI request channel flit from the chi_container 
    //and forward them to Seqr
    begin:t2_th
        chi_rn_traffic_cmd_seq m_seq;
        chi_bfm_txn req_txn;
        uvm_event txns_constructed;
        bit rand_txns_constructed;
        bit atomic_txns_constructed;
        bit all_txns_constructed;
        addr_width_t local_addr;
        int csr_addr_offset;
        int boot_addr_offset;
       
        m_seq = chi_rn_traffic_cmd_seq::type_id::create(
          $psprintf("m_seq[%0d]", ID));
        m_seq.get_cmd_args(m_args);
        txns_constructed = new("txns_constructed"); 


        `uvm_info(get_name(), 
          $psprintf("ntxns: %0d", m_args.k_num_requests.get_value()),
          UVM_MEDIUM)
        fork
            begin
                for (int ntxns = 0; ntxns < m_args.k_num_requests.get_value();++ntxns) begin
                  
                  if(num_alt_qos_values > 1) begin
                    user_qos=1;
                    if(qos_cycle_count < aiu_qos1_cycle) aiu_qos = aiu_qos1;
                    else if(qos_cycle_count < (aiu_qos1_cycle + aiu_qos2_cycle)) aiu_qos = aiu_qos2;
                    else if(qos_cycle_count < (aiu_qos1_cycle + aiu_qos2_cycle + aiu_qos3_cycle)) aiu_qos =  aiu_qos3;
                    else aiu_qos = aiu_qos4;
    
                    qos_cycle_count += 1;
                    if(qos_cycle_count == total_aiu_qos_cycle) qos_cycle_count = 0;
                   end

                  m_chi_container.wait_until_thld_rchd();
<%if(obj.testBench == "fsys"){ %>
                  if($test$plusargs("en_excl_txn"))
                     m_seq.m_excl_txn = 1;
<%} else { %>
                  if(!$value$plusargs("en_excl_txn=%d",m_seq.m_excl_txn))
                     m_seq.m_excl_txn = 0;
<%}%>
                  if($test$plusargs("en_excl_noncoh_txn"))
                     m_seq.m_excl_noncoh_txn = 1;
		  if (k_directed_test) begin
                      `ASSERT(m_seq.randomize());
                      m_seq.m_cacheable_alloc.m_alloc = k_directed_test_alloc ? 1 : 0 ;
                  end else if($test$plusargs("add_atomic")) begin
                          `ASSERT(m_seq.randomize() with {
                                                    m_opcode_type inside  {WR_COHUNQ_CMD};
                                                    m_opcode inside {BFM_WRITEUNIQUEFULL};
						    m_new_addr == 1;  
							  });
                  end else if($test$plusargs("dvm_hang_test")) begin
                          `ASSERT(m_seq.randomize() with {
                                                    m_opcode_type inside  {DVM_OPERT_CMD};
                                                    m_opcode inside {BFM_DVMOP};
						    m_new_addr == 1;  
							  });
                end else if($test$plusargs("perf_test_tens")) begin
                    int modulo_ntxns; 
                    m_seq.start_ix = 1;
                    $value$plusargs("chi_duty_cycle=%d",duty_cycle);
                    $value$plusargs("nbr_write_coh_in_duty_cycle=%d",nbr_write_coh_in_duty_cycle);
                    $value$plusargs("nbr_write_noncoh_in_duty_cycle=%d",nbr_write_noncoh_in_duty_cycle);
                    modulo_ntxns= ntxns % duty_cycle;

                    if($test$plusargs("coherent_test")) begin    // case noncoherent opcode
                        if ($test$plusargs("read_test")) begin
                            `ASSERT(m_seq.randomize() with {
                                m_mem_type    == NORMAL;
                                m_opcode_type == RD_LDRSTR_CMD;
                                m_opcode      == BFM_READUNIQUE;
                                m_ewa         == 1;  
                                m_addr_type   == COH_ADDR;
                                m_start_state == CHI_IX;
                                m_snoopme     == 1;   
                            });   
                                m_seq.m_expcompack.m_expcompack = 1 ;
                                //m_seq.m_cacheable_alloc.m_alloc = 1;
                                //m_seq.m_cacheable_alloc.m_cacheable = 1;
                                m_seq.m_order.m_order = NO_ORDER;
                        end 
                        if ($test$plusargs("read_write_test")) begin
                            `ASSERT(m_seq.randomize() with {
                                if (modulo_ntxns < nbr_write_coh_in_duty_cycle) { //generate write seq
                                    m_mem_type    == NORMAL;
                                    m_opcode_type ==  WR_COHUNQ_CMD;
                                    m_opcode      == BFM_WRITEUNIQUEFULL;
                                    m_ewa         == 1; 
                                    m_addr_type   == COH_ADDR; 
                                    m_start_state == CHI_IX;
                                    m_snoopme     == 1;
                                    m_size.perf_test==1;
                                } else { // else generate read seq 
                                    m_mem_type    == NORMAL;
                                    m_opcode_type == RD_LDRSTR_CMD;
                                    m_opcode      == BFM_READUNIQUE;
                                    m_ewa         == 1;  
                                    m_addr_type   == COH_ADDR;
                                    m_start_state == CHI_IX;
                                    m_snoopme     == 1; 
                                    m_size.perf_test==1;
                                } // generate write seq 
                             });
                            m_seq.m_expcompack.m_expcompack = (m_seq.m_opcode == BFM_READUNIQUE)?1 :0;
                            //m_seq.m_cacheable_alloc.m_alloc = 1;
                            //m_seq.m_cacheable_alloc.m_cacheable = 1;
                            m_seq.m_order.m_order = NO_ORDER;
                            m_seq.m_qos = (user_qos)? aiu_qos :0;
                        end // read_write_test      
                    end else if($test$plusargs("noncoherent_test")) begin    // case noncoherent opcode 
                        if ($test$plusargs("read_test")) begin
                            `ASSERT(m_seq.randomize() with {
                                m_mem_type == NORMAL;
                                m_opcode_type == RD_NONCOH_CMD;
                                m_opcode == BFM_READNOSNP;
                                m_ewa == 1;  
                                m_addr_type == NON_COH_ADDR;
                                m_start_state == CHI_IX;
                                m_snoopme == 0;                        
                            }); 
                            m_seq.m_expcompack.m_expcompack = 1 ;
                            m_seq.m_order.m_order = NO_ORDER;
                        end else if ($test$plusargs("read_write_test")) begin
                            `ASSERT(m_seq.randomize() with {
                                if (modulo_ntxns < nbr_write_noncoh_in_duty_cycle) { //generate write seq
                                    m_mem_type == NORMAL;
                                    m_opcode_type ==  WR_NONCOH_CMD;
                                    m_opcode == BFM_WRITENOSNPFULL;
                                    m_ewa == 1; 
                                    m_addr_type == NON_COH_ADDR; 
                                    m_start_state == CHI_IX;
                                    m_snoopme == 0;
                                    m_size.perf_test==1;
                                } else { // else generate read seq 
                                    m_mem_type == NORMAL;
                                    m_opcode_type == RD_NONCOH_CMD;
                                    m_opcode == BFM_READNOSNP;
                                    m_ewa == 1;  
                                    m_addr_type == NON_COH_ADDR;
                                    m_start_state == CHI_IX;
                                    m_size.perf_test==1;
                                    m_snoopme == 0;
                                } // end else generate write seq (read seq)
                            });        
                            // here becasue "with" constraints doesn't work
                            m_seq.m_expcompack.m_expcompack = 0;
                            m_seq.m_order.m_order = NO_ORDER;
                            m_seq.m_qos = (user_qos)? aiu_qos :0;
                        end //read_write_test + noncoherent_test
                    end //end noncoherent_test               
              end else begin //end perf_test_tens
		      if($test$plusargs("perf_test")) begin
			  m_seq.start_ix = 1;
              if($test$plusargs("chi<%=obj.AiuInfo[obj.Id].nUnitId%>_duty_cycle")) begin    //newperf test: case with "duty_cycle"
                           int modulo_ntxns= ntxns % duty_cycle;
						        m_seq.c_opcode_type.constraint_mode(0); // disable dist constraint when duty case
                                if($test$plusargs("noncoherent_test")) begin    // case noncoherent opcode
                                         `ASSERT(m_seq.randomize() with {
                                                              if (modulo_ntxns < nbr_write_noncoh_in_duty_cycle) { //generate write seq
                                                                              m_mem_type == NORMAL;
                                                                              m_opcode_type ==  WR_NONCOH_CMD;
                                                                              m_opcode == BFM_WRITENOSNPFULL;
                                                                              m_ewa == 1; 
                                                                              m_addr_type == NON_COH_ADDR; 
                                                                              m_start_state == CHI_IX;
                                                                              m_snoopme == 0;
                                                                              m_size.perf_test==1;
                                                              } else { // else generate read seq 
                                                                              m_mem_type == NORMAL;
                                                                               m_opcode_type == RD_NONCOH_CMD;
                                                                              m_opcode == BFM_READNOSNP;
                                                                              m_ewa == 1;  
                                                                              m_addr_type == NON_COH_ADDR;
                                                                              m_start_state == CHI_IX;
                                                                              m_size.perf_test==1;
                                                                              m_snoopme == 0;
                                                               } // end else generate write seq (read seq)
                                                                              });        
                                       // here becasue "with" constraints doesn't work
                                       m_seq.m_expcompack.m_expcompack = 0;
                                       m_seq.m_qos = (user_qos)? aiu_qos :0;
                                                  end else begin // else coherent opcode case
                                          int use_stash =  ($test$plusargs("chi<%=obj.Id%>_stashnid"))?1:0;  
                                    	  int use_rdonce= ($test$plusargs("k_rd_rdonce_pct") || $test$plusargs("force_chiaiu<%=obj.AiuInfo[obj.Id].nUnitId%>_rdonce"))?1 :0;
                                        `ASSERT(m_seq.randomize() with {
												              if (use_stash == 1) {
                                                                              m_mem_type == NORMAL;
                                                                              m_opcode_type ==  DT_LS_STH_CMD;
                                                                              m_opcode == BFM_STASHONCEUNIQUE;
                                                                              m_ewa == 1; 
                                                                              m_addr_type == COH_ADDR; 
                                                                              m_start_state == CHI_IX;
                                                                              m_snoopme == 1;
                                                                              m_size.perf_test==1;
															  } else { //no stash case
                                                              if (modulo_ntxns < nbr_write_coh_in_duty_cycle) { //generate write seq
                                                                              m_mem_type == NORMAL;
                                                                              m_opcode_type ==  WR_COHUNQ_CMD;
                                                                              m_opcode == BFM_WRITEUNIQUEFULL;
                                                                              m_ewa == 1; 
                                                                              m_addr_type == COH_ADDR; 
                                                                              m_start_state == CHI_IX;
                                                                              m_snoopme == 1;
                                                                              m_size.perf_test==1;
                                                              } else { // else generate read seq 
                                                                              m_mem_type == NORMAL;
                                                                              if (use_rdonce ==1 ) {
                                                                                 m_opcode_type == RD_RDONCE_CMD;
                                                                                 m_opcode == BFM_READONCE;
                                                                              } else {
                                                                              m_opcode_type == RD_LDRSTR_CMD;
                                                                              m_opcode == BFM_READUNIQUE;
                                                                              }
                                                                              m_ewa == 1;  
                                                                              m_addr_type == COH_ADDR;
                                                                              m_start_state == CHI_IX;
                                                                              m_size.perf_test==1;
                                                                              m_snoopme == 1;
                                                               } // end else generate write seq (read seq)
															  } // end else stash case
                                                                              });        
                                       // here becasue "with" constraints doesn't work
                                       m_seq.m_expcompack.m_expcompack = (m_seq.m_opcode == BFM_READUNIQUE)?1 :0;
                                       m_seq.m_qos = (user_qos)? aiu_qos :0;
                                end // end coherent 
                          end else begin // end duty_cycle//end newperf test 
                            if($test$plusargs("noncoherent_test")) begin    // case noncoherent opcode

                              `ASSERT(m_seq.randomize() with {
                                      m_opcode_type inside  {RD_NONCOH_CMD, WR_NONCOH_CMD};
                                      m_opcode inside {BFM_READNOSNP, BFM_WRITENOSNPFULL};
                                      m_ewa == 1;  
                                      m_new_addr == 1;
                                      if(user_qos==1) m_qos == aiu_qos;
                                      });
                            end else begin
                              `ASSERT(m_seq.randomize() with {
                                      m_opcode_type inside  {RD_NONCOH_CMD, RD_LDRSTR_CMD, RD_RDONCE_CMD,WR_NONCOH_CMD, WR_COHUNQ_CMD};
                                      m_opcode inside {BFM_READNOSNP, BFM_READUNIQUE, BFM_READONCE,BFM_WRITENOSNPFULL, BFM_WRITEUNIQUEFULL};
                                      m_ewa == 1;
                                      m_new_addr == 1;
                                      if(user_qos==1) m_qos == aiu_qos;
                                      });
                          end
					         end // end else duty_cycle
							 m_seq.m_order.m_order = ($test$plusargs("force_chi<%=obj.AiuInfo[obj.Id].nUnitId%>_req_order") && (m_seq.m_opcode != BFM_READUNIQUE))?REQUEST_ORDER:NO_ORDER;

			                 if(m_seq.m_opcode_type == WR_COHUNQ_CMD) begin
			                    m_seq.m_order.m_order = $urandom_range(0,1) ? REQUEST_ORDER : ENDPOINT_ORDER;
			                 end

			                 if((m_seq.m_opcode_type == RD_NONCOH_CMD) || (m_seq.m_opcode_type == WR_NONCOH_CMD)) begin
			                    m_seq.m_order.m_order = NO_ORDER;
			                 end
		      end else if($test$plusargs("add_selfid_rd") && (ntxns == 0)) begin
                          //m_seq.get_cmd_args(m_args);
                          m_seq.c_opcode.constraint_mode(0);
                          m_seq.c_opcode_type.constraint_mode(0);
                          m_seq.c_addr_type.constraint_mode(0);
                          m_seq.c_new_addr.constraint_mode(0);
                          `ASSERT(m_seq.randomize() with {
                                                    m_lpid == 0 ; // TODO:Assuming it to be 0
                                                    m_opcode_type == RD_NONCOH_CMD; m_opcode == BFM_READNOSNP;
                                                    m_addr_type == NON_COH_ADDR; m_ewa == 0; m_new_addr == 0;
                                                    //m_snpattr == 0; m_start_state == CHI_IX; m_snoopme == 0;// constraint takes care of these,based on "m_opcode_type"
                                                    });
		         if($test$plusargs("illegal_csr_format_uncrr")) begin
                          m_seq.m_order.m_order = REQUEST_ORDER;
                          m_seq.m_mem_type = NORMAL;
                          m_seq.m_size.m_size = 6;
                         end 
                         else begin
                          m_seq.m_order.m_order = ENDPOINT_ORDER;
                          m_seq.m_mem_type = DEVICE;
                          m_seq.m_size.m_size = 2;
                         end
                          m_seq.m_expcompack.m_expcompack = 0;
                          m_seq.m_excl.m_excl = 0;
                          m_seq.c_opcode.constraint_mode(1);
                          m_seq.c_opcode_type.constraint_mode(1);
                          m_seq.c_addr_type.constraint_mode(1);
                          m_seq.c_new_addr.constraint_mode(1);
		      end else if($test$plusargs("read_noncoh_txn_test")) begin
                          //m_seq.get_cmd_args(m_args);
                          m_seq.c_opcode.constraint_mode(0);
                          m_seq.c_opcode_type.constraint_mode(0);
                          m_seq.c_addr_type.constraint_mode(0);
                          m_seq.c_new_addr.constraint_mode(0);
                          `ASSERT(m_seq.randomize() with {
                                                    m_lpid == 0 ; // TODO:Assuming it to be 0
                                                    m_mem_type == NORMAL;
                                                    m_opcode_type == RD_NONCOH_CMD; m_opcode == BFM_READNOSNP;
                                                    m_addr_type == NON_COH_ADDR; m_ewa == 0; m_new_addr == 0;
                                                    //m_snpattr == 0; m_start_state == CHI_IX; m_snoopme == 0;// constraint takes care of these,based on "m_opcode_type"
                                                    });
                          m_seq.m_order.m_order = REQUEST_ORDER;
                          m_seq.c_opcode.constraint_mode(1);
                          m_seq.c_opcode_type.constraint_mode(1);
                          m_seq.c_addr_type.constraint_mode(1);
                          m_seq.c_new_addr.constraint_mode(1);
		      end else if($test$plusargs("atomic_err_txn_test")) begin
                          //m_seq.get_cmd_args(m_args);
                          m_seq.c_addr_type.constraint_mode(0);
                          m_seq.c_new_addr.constraint_mode(0);
                          `ASSERT(m_seq.randomize() with {
                                                    m_lpid == 0 ; // TODO:Assuming it to be 0
                                                    m_mem_type == NORMAL;
                                                    m_addr_type == COH_ADDR; m_new_addr == 0; m_excl_txn == 0; m_snpattr == 1;
                                                    });
                          m_seq.m_order.m_order = NO_ORDER;
                          m_seq.c_addr_type.constraint_mode(1);
                          m_seq.c_new_addr.constraint_mode(1);
				 end else begin  // end if perf test
                          m_seq.start_ix = $test$plusargs("start_ix") ? 1 : ntxns<(m_args.k_num_requests.get_value()/2);
                          m_seq.force_cleanuniq=0; // as same object is randomized need to set it 0 every time
                          if(($test$plusargs("use_copyback") || $test$plusargs("use_genuce")) && ntxns<(m_args.k_num_requests.get_value()*3/4))
			  begin
                            m_seq.force_cleanuniq=1;
			  end
                            `ASSERT(m_seq.randomize() with {
						      if(user_qos==1) m_qos == aiu_qos;							    
							   });
                      end
                  end
                  m_seq.m_boot_addr = k_access_boot_region;
                  <%  if(obj.testBench!="fsys") { %>
                  if (boot_sysco_st == DISCONNECT || boot_sysco_st == DISABLED) begin
                      m_seq.c_addr_type.constraint_mode(0);
                      `ASSERT(m_seq.randomize()  with {
                                                 m_opcode_type inside  {RD_NONCOH_CMD, DT_LS_UPD_CMD, DT_LS_CMO_CMD, WR_NONCOH_CMD, ATOMIC_ST_CMD, ATOMIC_LD_CMD, ATOMIC_SW_CMD, ATOMIC_CM_CMD, PRE_FETCH_CMD, RQ_LCRDRT_CMD};
                                                 m_addr_type == NON_COH_ADDR;
                                                 });
                      m_seq.c_addr_type.constraint_mode(1);
                  end
                  <% } %>
	          m_chi_container.construct_chi_txn(m_seq); // Creat chi_bfm_txn and put in "m_tx_req_chnl_cb"		   
		  if($test$plusargs("add_selfid_rd") && (ntxns == 0)) begin
		      //`uvm_info("CHIAIU SEQ", $sformatf("Issuing selfid read"), UVM_LOW);
                      // setting csrBaseAddress
                      local_addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE ; //  addr = {'h00b9b90, 8'hFF, 12'h000};
                      if($test$plusargs("boot_addr_offset")) begin
                          local_addr = ncore_config_pkg::ncoreConfigInfo::BOOT_REGION_BASE ; //  addr = {'h00b9b90, 8'hFF, 12'h000};
                      end
                      if(!$value$plusargs("csr_addr_offset=%d",csr_addr_offset))
                          csr_addr_offset = 0;
                      if(!$value$plusargs("boot_addr_offset=%d",boot_addr_offset)) //#Stimulus.CHIAIU.v3.4.Security.Bootecureaccess
                          boot_addr_offset = 0;
		      if($test$plusargs("illegal_csr_format_uncrr")) begin
                      local_addr[19:0] = csr_addr_offset ? (20'hFF000 + csr_addr_offset+1) : boot_addr_offset ? (20'h40000 + boot_addr_offset) : 20'hFF000;
                      end 
                      else begin
                      local_addr[19:0] = csr_addr_offset ? (20'hFF000 + csr_addr_offset) : boot_addr_offset ? (20'h40000 + boot_addr_offset) : 20'hFF000;
                      end
                      m_chi_container.get_txreq_chnl_txn(req_txn);
	              m_chi_container.del_entry_in_req_ordq_if_any(req_txn.m_req_txnid);
                      req_txn.m_req_ns = csr_addr_offset ? 1 : boot_addr_offset ? 1 : 0; //for now fix ns to 1 for csr_access/boot_access.
                      req_txn.m_req_addr = local_addr;
                      push_txreq(req_txn);
                  end
		  `uvm_info("CHIAIU<%obj.AiuInfo[obj.Id].nUnitId%> SEQ", $sformatf("CHI TXN: %s", m_seq.convert2string()), UVM_LOW);
                  trigger_on_threshold(ntxns, txns_constructed);
                end // for (int ntxns = 0; ntxns < m_args.k_num_requests.get_value();...
                rand_txns_constructed = 1;
            end // fork branch
	   
            begin: t2_inner_makeclean_th
	        if($test$plusargs("add_makeclean") && (ID == 0)) begin
                   wait((rand_txns_constructed == 1) &&
                        (m_chi_container.m_tx_req_chnl_cb.size() == 0) && 
                        (m_chi_container.m_unscheduled_txnq.size() == 0));
			
                   for (int ntxns = 0; ntxns < m_args.k_num_requests.get_value();++ntxns) begin
                        m_chi_container.wait_until_thld_rchd();
                        `ASSERT(m_seq.randomize()  with {
                                                   m_opcode_type == DT_LS_UPD_CMD;
						   m_opcode == BFM_MAKEUNIQUE; 
						   if(user_qos==1) m_qos == aiu_qos;
                                                   });
	                m_chi_container.construct_chi_txn(m_seq); // Creat chi_bfm_txn and put in "m_tx_req_chnl_cb"		   
                        trigger_on_threshold(ntxns, txns_constructed);
                   end
                   trigger_on_txns_done(txns_constructed);
                   all_txns_constructed = 1;
                end // if ($test$plusargs("add_makeclean"))
	        else if($test$plusargs("dvm_hang_test") && (ID == 0)) begin
                   wait((rand_txns_constructed == 1) &&
                        (m_chi_container.m_tx_req_chnl_cb.size() == 0) && 
                        (m_chi_container.m_unscheduled_txnq.size() == 0));
			
                   for (int ntxns = 0; ntxns < m_args.k_num_requests.get_value();++ntxns) begin
                       m_chi_container.wait_until_thld_rchd();
                       `ASSERT(m_seq.randomize()  with {
                                              m_opcode_type == DVM_OPERT_CMD;
				              m_opcode == BFM_DVMOP; 
				              m_new_addr == 1;  
                                              });
	               m_chi_container.construct_chi_txn(m_seq); // Creat chi_bfm_txn and put in "m_tx_req_chnl_cb"		   
                       trigger_on_threshold(ntxns, txns_constructed);
                   end
                   trigger_on_txns_done(txns_constructed);
                   all_txns_constructed = 1;
                end // if ($test$plusargs("dvm_hang_test"))
                else begin
                   wait(rand_txns_constructed == 1);
                   trigger_on_txns_done(txns_constructed);
                   all_txns_constructed = 1;
                end
	    end
	   
            begin: t2_inner_atomic_th
	        if($test$plusargs("add_atomic")) begin
                   wait((rand_txns_constructed == 1) &&
                        (m_chi_container.m_tx_req_chnl_cb.size() == 0) && 
                        (m_chi_container.m_unscheduled_txnq.size() == 0));
			
                   for (int ntxns = 0; ntxns < m_args.k_num_requests.get_value();++ntxns) begin
                        m_chi_container.wait_until_thld_rchd();
                        m_seq.start_ix = 1;
                        `ASSERT(m_seq.randomize()  with {
                                                   m_opcode_type == atomic_ops[ntxns%atomic_ops.size()];
						   m_new_addr == 0;
						   m_snpattr == 1;
                                                   });
	                m_chi_container.construct_chi_txn(m_seq); // Creat chi_bfm_txn and put in "m_tx_req_chnl_cb"		   
                        trigger_on_threshold(ntxns, txns_constructed);
                   end
                   trigger_on_txns_done(txns_constructed);
                   atomic_txns_constructed = 1;
                   //all_txns_constructed = 1;
                end
                else begin
                   wait(rand_txns_constructed == 1);
                   trigger_on_txns_done(txns_constructed);
                   atomic_txns_constructed = 1;
                   //all_txns_constructed = 1;
                end
	    end

            begin: t2_inner_read_after_atomic_th
	        if($test$plusargs("add_atomic")) begin
                   wait((atomic_txns_constructed == 1) &&
                        (m_chi_container.m_tx_req_chnl_cb.size() == 0) && 
                        (m_chi_container.m_unscheduled_txnq.size() == 0));
			
                   for (int ntxns = 0; ntxns < m_args.k_num_requests.get_value();++ntxns) begin
                        m_chi_container.wait_until_thld_rchd();
                          `ASSERT(m_seq.randomize() with {
                                                    m_opcode_type inside  {RD_LDRSTR_CMD};
                                                    m_opcode inside {BFM_READUNIQUE};
						    m_new_addr == 0;  
						    if(user_qos==1) m_qos == aiu_qos;
							  });
	                m_chi_container.construct_chi_txn(m_seq); // Creat chi_bfm_txn and put in "m_tx_req_chnl_cb"		   
                        trigger_on_threshold(ntxns, txns_constructed);
                   end
                   trigger_on_txns_done(txns_constructed);
                   all_txns_constructed = 1;
                end
                else begin
                   wait(atomic_txns_constructed == 1);
                   trigger_on_txns_done(txns_constructed);
                   all_txns_constructed = 1;
                end
	    end

            begin: t2_inner_t2_th
                int pending_txn_cnt, prior_itr_txn_cnt, cur_itr;

                txns_constructed.wait_ptrigger();
                while ((!all_txns_constructed)                          ||
                       (m_chi_container.m_tx_req_chnl_cb.size() != 0)   ||
                       (m_chi_container.m_unscheduled_txnq.size() != 0)) begin

		  `uvm_info("CHIAIU<%obj.AiuInfo[obj.Id].nUnitId%> SEQ", $sformatf("all_txns_constructed: %0d, m_tx_req_chnl_cb: %0d, m_unscheduled_txnq: %0d", all_txns_constructed, m_chi_container.m_tx_req_chnl_cb.size(), m_chi_container.m_unscheduled_txnq.size()), UVM_MEDIUM);

	          <% if(obj.testBench == "fsys"|| obj.testBench == "chi_aiu" ) { %>
                  if (!$test$plusargs("perf_test")) begin
                      if (all_txns_constructed && (m_chi_container.m_tx_req_chnl_cb.size() == 0) && (m_chi_container.m_unscheduled_txnq.size() != 0)) begin
                      <% if(obj.testBench == "fsys") { %>
                             wait (((m_chi_container.m_pend_endpoint_txnq.size() == 0) && (m_chi_container.m_pend_reqorder_txnq.size() == 0)) || (m_chi_container.m_tx_req_chnl_cb.size() != 0));
                      <% } else {%>
                            wait(((m_chi_container.m_pend_endpoint_txnq.size() == 0) && (m_chi_container.m_pend_reqorder_txnq.size() == 0))
                               || (m_chi_container.m_tx_req_chnl_cb.size() != 0)|| (m_chi_container.m_unscheduled_txnq.size() != 0)) 
                       <% } %>
             
                          if ((m_chi_container.m_tx_req_chnl_cb.size() == 0)) begin
                              foreach (m_chi_container.m_unscheduled_txnq[idx]) begin
                                  if (m_chi_container.m_chi_txns[m_chi_container.m_unscheduled_txnq[idx]].m_txn_order_blkd == 1'b1) begin
                                      `uvm_info("CHIAIU SEQ", $sformatf("Calling sch_any_order_block_txns to avoid HBFAIL"), UVM_NONE);
                                      m_chi_container.sch_any_order_block_txns(m_chi_container.m_unscheduled_txnq[idx]);
                                      break;
                                  end
                                  if (m_chi_container.m_chi_txns[m_chi_container.m_unscheduled_txnq[idx]].m_txn_state_blkd == 1'b1) begin
                                      `uvm_info("CHIAIU SEQ", $sformatf("Calling sch_any_state_blocked_txns to avoid HBFAIL"), UVM_NONE);
                                      m_chi_container.sch_any_state_blocked_txns();
                                      break;
                                  end
                              end
                          end
                      end
                  end
                  <% } %>

                  if (boot_sysco_st != ENABLED) begin
                     find_snpattr_q = m_chi_container.m_tx_req_chnl_cb.m_txn.find_first_index with(item.m_req_snpattr[0] == 'h0);
                        if(find_snpattr_q.size() == 'h1) begin
                            for (int i =0 ; i <= find_snpattr_q[0]; i++) begin
                                 m_chi_container.get_txreq_chnl_txn(req_txn);
                                 if (i != find_snpattr_q[0]) begin
                                     m_chi_container.put_txreq_chnl_txn(req_txn);
                                 end
                            end
                            find_snpattr_q.delete(0);
                         end else begin
                                 m_chi_container.get_txreq_chnl_txn(req_txn);
                         end
                  end else begin
                         m_chi_container.get_txreq_chnl_txn(req_txn);
                  end 

                   
                  if ($value$plusargs("delay_chi<%=obj.AiuInfo[obj.Id].nUnitId%>_req=%d", delay_chi<%=obj.AiuInfo[obj.Id].nUnitId%>_req))  begin //newperf test to allow to measure the latency with OTT empty
						  #(delay_chi<%=obj.AiuInfo[obj.Id].nUnitId%>_req);
                  end

                  if ($test$plusargs("zero_nonzero_crd_test")) begin  
                       wait(pause_main_traffic == 0); 
                  end
		  push_txreq(req_txn);
                  //For PRE_FETCH_CMD
                  if (req_txn.m_req_opcode == BFM_PREFETCHTARGET
                      || req_txn.m_req_opcode == BFM_REQLCRDRETURN)
                    reconsume_prefetch_txnid(req_txn.m_req_txnid);
                end // while ((!all_txns_constructed)                          ||...

	        // signal to top level test this sequence is done
	       `uvm_info("CHIAIU<%obj.AiuInfo[obj.Id].nUnitId%> SEQ", "CHI Master Sequence done", UVM_NONE)
          ev_seq_done.trigger(null);

            end: t2_inner_t2_th

	    <% if(obj.testBench == "fsys") { %>
	    // wait for top level test to signal all sequences done
	    begin: wait_sim_done
	        ev_sim_done.wait_trigger();
	       `uvm_info("CHIAIU<%obj.AiuInfo[obj.Id].nUnitId%> SEQ", "Received simulation done", UVM_NONE)
            end: wait_sim_done
            <% } %>
        join
    end:t2_th

         if ($test$plusargs("zero_nonzero_crd_test")) begin  
            begin : pause_traffic
                forever 
                   begin
                      uvm_config_db#(int)::get(null,"*","pause_main_traffic",pause_main_traffic);
                      if (pause_main_traffic == 1) begin
                         `uvm_info(get_full_name(),$sformatf("VSEQ_SEQ thread_pause_traffic : %0h",pause_main_traffic),UVM_DEBUG)
                      end else begin
                          pause_main_traffic = 'h0;
                      end
                      #2;
                   end                  
            end : pause_traffic
         end 

    //Pop CHI TX response channel flit
    //from the chi_container and forward them to Seqr
    begin: t3_th
      if(seq_iter == 0) begin
        forever begin
          chi_bfm_rsp_t rsp_txn;
          m_chi_container.get_txrsp_chnl_txn(rsp_txn);
          push_txrsp(rsp_txn);
        end
      end
    end: t3_th

    //Pop CHI TX data channel flit
    //from the chi_container and forward them to Seqr
    begin: t4_th
      forever begin
        chi_bfm_dat_t dat_txn;

        dat_txn.m_info = new(WBE);
        m_chi_container.get_txdat_chnl_txn(dat_txn);
        push_txdat(dat_txn);
      end
    end: t4_th

    //Push CHI RX response channel flits
    //received from Seqr to chi_container
    begin: t5_th
      forever begin
        chi_bfm_rsp_t rsp_txn;

        pop_rxrsp(rsp_txn);
        m_chi_container.put_rxrsp_chnl_txn(rsp_txn);
      end
    end: t5_th

    //Push CHI RX data channel flits
    //received from Seqr to chi_container
    begin: t6_th
      forever begin
        chi_bfm_dat_t dat_txn;

        pop_rxdat(dat_txn);
        m_chi_container.put_rxdat_chnl_txn(dat_txn);
      end
    end: t6_th

    //Push CHI RX snoop channel flits
    //received from Seqr to chi_container
    begin: t7_th
      forever begin
        chi_bfm_snp_t snp_txn;

        pop_rxsnp(snp_txn);
        m_chi_container.put_rxsnp_chnl_txn(snp_txn);
      end
    end: t7_th

    begin: t8_th
      forever begin
        m_chi_container.construct_chi_stashing_snprsp();
      end
    end

    begin: t9_th
      uvm_object uvm_obj;
      forever begin
        `uvm_info(uname, "VSEQ: dbg-0", UVM_DEBUG)
        #1 ev_toggle_sysco_<%=obj.BlockId%>.wait_ptrigger_data(uvm_obj);
        `uvm_info(uname, "VSEQ: dbg-1", UVM_DEBUG)
        is_SyscoNintf = (uvm_obj != null) ? 1 : 0;
        case(boot_sysco_st)
          CONNECT,
          ENABLED : begin
            construct_sysco_seq(DISCONNECT);
          end
          DISCONNECT,
          DISABLED : begin
            construct_sysco_seq(CONNECT);
          end
        endcase
      end
    end
  join_any
  `uvm_info(uname, "Stop CHI AIU VSEQ", UVM_MEDIUM)
endtask: body

<%  if(obj.testBench!="chi_aiu") { %>
task chi_aiu_vseq::access_boot_region_seq();
    addr_width_t addr;
    bit [31:0] data;
    int chi_num_trans = 10;				   

    addr = 'h0;
    if (!$value$plusargs("chi_num_trans=%d",chi_num_trans)) begin
        chi_num_trans = 1;
    end
    repeat(chi_num_trans)begin
        `uvm_info("access_boot_region_chiaiu<%=obj.Id%>", $sformatf("Reading boot region addr 0x%0h", addr), UVM_NONE)
        if($test$plusargs("boot_coh_access")) begin
            read_coh(addr,data);
        end
        else begin
            read_csr(addr,data);
	end // else: !if($test$plusargs("boot_coh_access"))				   
        `uvm_info("access_boot_region_chiaiu<%=obj.Id%>", $sformatf("boot region[0x%0h] = 0x%0h", addr, data), UVM_NONE)
        addr = addr+8'b01000000;
    end
endtask // access_boot_region_seq
				   

task chi_aiu_vseq::write_memory(input addr_width_t addr, input bit[511:0] data,input int size, input bit init_ccid_zero=1);
    chi_rn_traffic_cmd_seq m_seq;
    chi_bfm_txn req_txn;
    chi_bfm_dat_t dat_txn;
    chi_bfm_rsp_t rsp_txn;
    chi_data_be_t m_info;
    int wr_data_cancel = m_args.k_writedatacancel_pct.get_value();
    int addr_mask;
    int addr_offset;			
    int size_in_bytes;
    int ccid_offset;
    int max_offset;

    // FIXME - need to look at wSmiDPdata for data width
    addr_mask = wSmiDPdata/8 - 1;				   
    addr_offset = addr & addr_mask;

    `uvm_info("atomic", $psprintf("All input args  addr 0x%0h data 0x%0h size 0x%0h init_ccid_zero %0d wSmiDPdata 'd%0d addr_mask 0x%0h addr_offset 0x%0h",addr,data,size,init_ccid_zero,wSmiDPdata,addr_mask,addr_offset), UVM_LOW);
// For Write:
//   push_txreq // t2_th
//   pop_rxrsp  // t5_th
//   push_txdat // t4_th
//   pop_rxrsp  // t5_th
//      1 Create seq_item
        m_seq = chi_rn_traffic_cmd_seq::type_id::create($psprintf("m_seq[%0d]", ID)); 
        m_seq.get_cmd_args(m_args);
        m_args.k_writedatacancel_pct.set_value(0);
        `ASSERT(m_seq.randomize() with {
            m_tgtid == 0; m_lpid == 0 ; // TODO:Assuming it to be 0
            m_opcode_type == WR_NONCOH_CMD; m_opcode == BFM_WRITENOSNPPTL;
	    m_addr_type == NON_COH_ADDR; m_ewa == 0; m_new_addr == 0;
          //m_snpattr == 0; m_start_state == CHI_IX; m_snoopme == 0;// constraint takes care of these,based on "m_opcode_type"
        });
        m_seq.m_order.m_order = REQUEST_ORDER;
        m_seq.m_expcompack.m_expcompack = 0;
        m_seq.m_size.m_size = size;

//      2 Construct_chi_txn
        m_chi_container.construct_chi_txn(m_seq); // Creat chi_bfm_txn and put in "m_tx_req_chnl_cb"
//      3 Get the TXReq Chnl TXN snd Push in TXREQ_Q
        m_chi_container.get_txreq_chnl_txn(req_txn); // pop from the "m_tx_req_chnl_cb" chi_bfm_txn type
	// hack - remove txn from pending order queue
	m_chi_container.del_entry_in_req_ordq_if_any(req_txn.m_req_txnid);
        req_txn.m_req_ns = 0;
        req_txn.m_req_addr = addr;
        push_txreq(req_txn); // This will create actual Chi_seq_item and push it to chi_txn_Seq to finally be driven
//      4 Get the CResp with DBID( Assuming "The separate DBIDResp and Comp" and not "The combined CompDBIDResp")
        pop_rxrsp(rsp_txn);
        m_chi_container.put_rxrsp_chnl_txn(rsp_txn);

//      5 Give the write data and put in the container
        dat_txn.m_info = new(WBE);
        size_in_bytes = m_chi_container.pow2(req_txn.m_req_size);
        ccid_offset = (wSmiDPdata == 128) ? m_chi_container.get_ccid(req_txn.m_req_addr)*wSmiDPdata/8 : req_txn.m_req_addr[5]*wSmiDPdata/8;
        max_offset = (((addr_offset+ccid_offset)/size_in_bytes) + 1)*size_in_bytes;
        for (int i = 0; i < size_in_bytes; ++i) begin
        // for (int i = 0; i < 64; ++i) begin
            if ((i+addr_offset+ccid_offset) < max_offset) begin
                m_info.m_data[i+addr_offset+ccid_offset] = data[(i*8)+:8];
                m_info.m_be[i+addr_offset+ccid_offset]   = 1;
            end
            else begin
                if (m_seq.m_mem_type == NORMAL) begin
                    m_info.m_data[((i+addr_offset+ccid_offset)%max_offset) + (max_offset - size_in_bytes)] = data[(i*8)+:8];
                    m_info.m_be[((i+addr_offset+ccid_offset)%max_offset) + (max_offset - size_in_bytes)]   = 1;
                end
            end
	end
        m_chi_container.get_txdat_chnl_txn(dat_txn); // gives m_tx_dat_chnl_cb.get_chi_txn(dat_txn/chi_bfm_txn)
        dat_txn.m_info.m_dataid.delete();// To remove the entry, created in m_chi_container->put_rxrsp_chnl_txn->initiate_wr_data
        //dat_txn.m_info.tmp_be[63] = 0;
        dat_txn.m_info.set_txdat_info(
            //0,
            (init_ccid_zero==1) ? 0 : m_chi_container.get_ccid(req_txn.m_req_addr),
            m_chi_container.num_beats(req_txn.m_req_addr & 6'h3F, req_txn.m_req_size),
            m_info.m_data,
            m_info.m_be
        );
        push_txdat(dat_txn);
//      6 Get the CResp for Comp
        pop_rxrsp(rsp_txn);
        m_chi_container.put_rxrsp_chnl_txn(rsp_txn);

        m_args.k_writedatacancel_pct.set_value(wr_data_cancel);
endtask : write_memory

task chi_aiu_vseq::atomic(input chi_bfm_opcode_type_t atomic_op_type=ATOMIC_ST_CMD, input chi_bfm_opcode_t atomic_op=BFM_ATOMICSTORE_STADD, input bit coh=0, input addr_width_t addr, input bit[127:0] data,input int size, input bit init_ccid_zero=1, input int width,  output bit[63:0] rd_data);
    chi_rn_traffic_cmd_seq m_seq;
    chi_bfm_txn req_txn;
    chi_bfm_dat_t dat_txn;
    chi_bfm_rsp_t rsp_txn;
    chi_data_be_t m_info;
    int wr_data_cancel = m_args.k_writedatacancel_pct.get_value();
    int addr_mask;
    int addr_offset;			
    int size_in_bytes;
    int ccid_offset;
    int max_offset;

    chi_bfm_dat_t rd_dat_txn;
    bit [511:0] m_rd_data;
    bit [63:0] m_rd_be;
    bit [1:0] m_rd_resp_err;
    bit [511:0] temp_data;
    // FIXME - need to look at wSmiDPdata for data width
    addr_mask = wSmiDPdata/8 - 1;				   
    addr_offset = addr & addr_mask;
    `uvm_info("atomic", $psprintf("All input args atomic_op_type %0s atomic_op %0s coh %0d addr 0x%0h data 0x%0h size 0x%0h init_ccid_zero %0d wSmiDPdata 'd%0d addr_mask 0x%0h addr_offset 0x%0h",atomic_op_type,atomic_op,coh,addr,data,size,init_ccid_zero,wSmiDPdata,addr_mask,addr_offset), UVM_LOW);

//   push_txreq // t2_th
//   pop_rxrsp  // t5_th
//   push_txdat // t4_th
//   pop_rxrsp  // t5_th
//      1 Create seq_item
        m_seq = chi_rn_traffic_cmd_seq::type_id::create($psprintf("m_seq[%0d]", ID)); 
        m_seq.get_cmd_args(m_args);
        m_args.k_writedatacancel_pct.set_value(0);
        m_seq.start_ix = 1;
        `ASSERT(m_seq.randomize() with {
            m_tgtid == 0; m_lpid == 0 ; // TODO:Assuming it to be 0
            m_opcode_type == local::atomic_op_type; m_opcode == local::atomic_op;
	    m_addr_type == COH_ADDR; m_ewa == 0; m_new_addr == 0; m_snpattr == local::coh;
          //m_snpattr == 0; m_start_state == CHI_IX; m_snoopme == 0;// constraint takes care of these,based on "m_opcode_type"
        });
        m_seq.m_order.m_order = REQUEST_ORDER;
        m_seq.m_expcompack.m_expcompack = 0;
        m_seq.m_size.m_size = size;
        `uvm_info("atomic", $psprintf("Printing txn..."), UVM_LOW);
        m_seq.print();

//      2 Construct_chi_txn
        m_chi_container.construct_chi_txn(m_seq); // Creat chi_bfm_txn and put in "m_tx_req_chnl_cb"
        `uvm_info("atomic", $psprintf("Unblocked construct_chi_txn..."), UVM_LOW);
//      3 Get the TXReq Chnl TXN snd Push in TXREQ_Q
        m_chi_container.get_txreq_chnl_txn(req_txn); // pop from the "m_tx_req_chnl_cb" chi_bfm_txn type
        `uvm_info("atomic", $psprintf("Unblocked m_chi_container.get_txreq_chnl_txn..."), UVM_LOW);
	// hack - remove txn from pending order queue
	m_chi_container.del_entry_in_req_ordq_if_any(req_txn.m_req_txnid);
        req_txn.m_req_ns = 0;
        req_txn.m_req_addr = addr;
        push_txreq(req_txn); // This will create actual Chi_seq_item and push it to chi_txn_Seq to finally be driven
        `uvm_info("atomic", $psprintf("Unblocked push_txreq..."), UVM_LOW);
//      4 Get the CResp with DBID( Assuming "The separate DBIDResp and Comp" and not "The combined CompDBIDResp")
        pop_rxrsp(rsp_txn);
        `uvm_info("atomic", $psprintf("Unblocked pop_rxrsp..."), UVM_LOW);
        m_chi_container.put_rxrsp_chnl_txn(rsp_txn);
        `uvm_info("atomic", $psprintf("Unblocked m_chi_container.put_rxrsp_chnl_txn..."), UVM_LOW);

//      5 Give the txn data and put in the container
        dat_txn.m_info = new(WBE);
        `uvm_info("atomic", $psprintf("size_in_bytes 'd%0d addr 'h%0x req_txn.m_req_addr 'h%0x",size_in_bytes,addr,req_txn.m_req_addr), UVM_LOW);
        req_txn.m_req_size = size;
        req_txn.m_req_addr= addr;
        size_in_bytes = m_chi_container.pow2(size);
        //ccid_offset = (wSmiDPdata == 128) ? m_chi_container.get_ccid(req_txn.m_req_addr)*wSmiDPdata/8 : req_txn.m_req_addr[5]*wSmiDPdata/8;
        //max_offset = (((addr_offset+ccid_offset)/size_in_bytes) + 1)*size_in_bytes;
        ccid_offset = (wSmiDPdata == 128) ? req_txn.m_req_addr[5:4]*wSmiDPdata/8 : req_txn.m_req_addr[5]*wSmiDPdata/8;
        max_offset = (((addr_offset+ccid_offset)/size_in_bytes) + 1)*size_in_bytes;
        for (int i = 0; i < size_in_bytes; ++i) begin
        // for (int i = 0; i < 64; ++i) begin
            if ((i+addr_offset+ccid_offset) < max_offset) begin
                m_info.m_data[i+addr_offset+ccid_offset] = data[(i*8)+:8];
                m_info.m_be[i+addr_offset+ccid_offset]   = 1;
            end
            else begin
                if (m_seq.m_mem_type == NORMAL) begin
                    m_info.m_data[((i+addr_offset+ccid_offset)%max_offset) + (max_offset - size_in_bytes)] = data[(i*8)+:8];
                    m_info.m_be[((i+addr_offset+ccid_offset)%max_offset) + (max_offset - size_in_bytes)]   = 1;
                end
            end
	end
        m_chi_container.get_txdat_chnl_txn(dat_txn); // gives m_tx_dat_chnl_cb.get_chi_txn(dat_txn/chi_bfm_txn)
        `uvm_info("atomic", $psprintf("Unblocked m_chi_container.get_txdat_chnl_txn...size_in_bytes 'd%0d addr 'h%0x req_txn.m_req_addr 'h%0x",size_in_bytes,addr,req_txn.m_req_addr), UVM_LOW);
        dat_txn.m_info.m_dataid.delete();// To remove the entry, created in m_chi_container->put_rxrsp_chnl_txn->initiate_wr_data
        //dat_txn.m_info.tmp_be[63] = 0;
        dat_txn.m_info.set_txdat_info(
            //0,
            (init_ccid_zero==1) ? 0 : m_chi_container.get_ccid(req_txn.m_req_addr),
            m_chi_container.num_beats(req_txn.m_req_addr & 6'h3F, req_txn.m_req_size),
            m_info.m_data,
            m_info.m_be
        );
        push_txdat(dat_txn);
        `uvm_info("atomic", $psprintf("Unblocked push_txdat..."), UVM_LOW);

        m_args.k_writedatacancel_pct.set_value(wr_data_cancel);

//      6 Get the read data and put in the container
        if(atomic_op_type inside {ATOMIC_LD_CMD, ATOMIC_SW_CMD,ATOMIC_CM_CMD}) begin
            if(atomic_op_type==ATOMIC_CM_CMD) begin
                size = size - 1;
                req_txn.m_req_size = req_txn.m_req_size - 1;
            end
            pop_rxdat(rd_dat_txn);
            m_rd_data = rd_dat_txn.m_info.get_tx_data(0);
            m_rd_be = rd_dat_txn.m_info.get_tx_be(0);
            m_rd_resp_err = rd_dat_txn.m_resp.get_resp_err();

            if(m_rd_resp_err != m_seq.m_excl.m_excl) begin
                `uvm_error("READ_CSR",$sformatf("Resp_err :0x%0h on Read Data",m_rd_resp_err))
            end

            temp_data = 512'b0;

            if (width == 128) begin
               if (size == 5) begin
                  pop_rxdat(rd_dat_txn);
                  temp_data[255:128] = rd_dat_txn.m_info.get_tx_data(0);
               end
               if (size == 6) begin
                  pop_rxdat(rd_dat_txn);
                  temp_data[255:128] = rd_dat_txn.m_info.get_tx_data(0);
                  pop_rxdat(rd_dat_txn);
                  temp_data[383:256] = rd_dat_txn.m_info.get_tx_data(0);
                  pop_rxdat(rd_dat_txn);
                  temp_data[511:384] = rd_dat_txn.m_info.get_tx_data(0);
               end
            end

            if ((size == 6) && (width == 256)) begin
               pop_rxdat(rd_dat_txn);
               temp_data[511:256] = rd_dat_txn.m_info.get_tx_data(0);
            end
                       
            m_rd_data = m_rd_data | temp_data;

	    m_rd_data = m_rd_data >> (addr_offset*8);				   
            for (int i = 0; i < m_chi_container.pow2(req_txn.m_req_size); i++) begin
            // for (int i = 0; i < 64; i++) begin
                rd_data[(i*8)+:8] = m_rd_data[(i*8)+:8];
                if(m_rd_be[i] != 1)
                    `uvm_info("READ_CSR",$sformatf("Read Data ByteEn[%0d] is 0",i),UVM_LOW)
            end
            m_chi_container.put_rxdat_chnl_txn(rd_dat_txn);
        end
endtask : atomic


task chi_aiu_vseq::write_memory_coh(input addr_width_t addr, input bit[511:0] data,input int size, input bit init_ccid_zero=1);
    chi_rn_traffic_cmd_seq m_seq;
    chi_bfm_txn req_txn;
    chi_bfm_dat_t dat_txn;
    chi_bfm_rsp_t rsp_txn;
    chi_data_be_t m_info;
    int wr_data_cancel = m_args.k_writedatacancel_pct.get_value();
    int addr_mask;
    int addr_offset;			

    // FIXME - need to look at wSmiDPdata for data width
    addr_mask = wSmiDPdata/8 - 1;				   
    addr_offset = addr & addr_mask;

// For Write:
//   push_txreq // t2_th
//   pop_rxrsp  // t5_th
//   push_txdat // t4_th
//   pop_rxrsp  // t5_th
//      1 Create seq_item
        m_seq = chi_rn_traffic_cmd_seq::type_id::create($psprintf("m_seq[%0d]", ID)); 
        m_seq.get_cmd_args(m_args);
        m_args.k_writedatacancel_pct.set_value(0);
        `ASSERT(m_seq.randomize() with {
            m_tgtid == 0; m_lpid == 0 ; // TODO:Assuming it to be 0
            m_opcode_type == WR_COHUNQ_CMD; m_opcode == BFM_WRITEUNIQUEFULL;
	    m_addr_type == COH_ADDR; m_ewa == 0; m_new_addr == 0;
          //m_snpattr == 0; m_start_state == CHI_IX; m_snoopme == 0;// constraint takes care of these,based on "m_opcode_type"
        });
        m_seq.m_order.m_order = REQUEST_ORDER;
        m_seq.m_expcompack.m_expcompack = 0;
        m_seq.m_size.m_size = size;

//      2 Construct_chi_txn
        m_chi_container.construct_chi_txn(m_seq); // Creat chi_bfm_txn and put in "m_tx_req_chnl_cb"
//      3 Get the TXReq Chnl TXN snd Push in TXREQ_Q
        m_chi_container.get_txreq_chnl_txn(req_txn); // pop from the "m_tx_req_chnl_cb" chi_bfm_txn type
	// hack - remove txn from pending order queue
	m_chi_container.del_entry_in_req_ordq_if_any(req_txn.m_req_txnid);
        req_txn.m_req_ns = 0;
        req_txn.m_req_addr = addr;
        push_txreq(req_txn); // This will create actual Chi_seq_item and push it to chi_txn_Seq to finally be driven
//      4 Get the CResp with DBID( Assuming "The separate DBIDResp and Comp" and not "The combined CompDBIDResp")
        pop_rxrsp(rsp_txn);
        m_chi_container.put_rxrsp_chnl_txn(rsp_txn);

//      5 Give the write data and put in the container
        dat_txn.m_info = new(WBE);
          for (int i = 0; i < m_chi_container.pow2(req_txn.m_req_size); ++i) begin
        // for (int i = 0; i < 64; ++i) begin
            //m_info.m_data[i+addr_offset] = data[(i*8)+:8];
            //m_info.m_be[i+addr_offset]   = 1;
            // BE and Data should be accessible for WriteUniqueFull 
            // Normal memory: The bytes accessed are from (Aligned_Address) to (Aligned_Address + Number_Bytes) - 1.
            //  Device memory: The bytes accessed are from (Start_Address) to (Aligned_Address + Number_Bytes) - 1.whereAligned_Address = (INT(Start_Address / Number_Bytes)) x Number_Bytes.
            //Start_Address = Addr field value.
            //Number_Bytes = 2^Size field value.
            //INT(x) = Rounded down integer value of x.
            m_info.m_data[i] = data[(i*8)+:8];
            m_info.m_be[i]   = 1;
				   end
				   
        m_chi_container.get_txdat_chnl_txn(dat_txn); // gives m_tx_dat_chnl_cb.get_chi_txn(dat_txn/chi_bfm_txn)
        dat_txn.m_info.m_dataid.delete();// To remove the entry, created in m_chi_container->put_rxrsp_chnl_txn->initiate_wr_data
        dat_txn.m_info.set_txdat_info(
            //0,
            (init_ccid_zero==1) ? 0 : m_chi_container.get_ccid(req_txn.m_req_addr),
            m_chi_container.num_beats(req_txn.m_req_addr & 6'h3F, req_txn.m_req_size),
            m_info.m_data,
            m_info.m_be
        );
        push_txdat(dat_txn);
//      6 Get the CResp for Comp
        pop_rxrsp(rsp_txn);
        m_chi_container.put_rxrsp_chnl_txn(rsp_txn);

        m_args.k_writedatacancel_pct.set_value(wr_data_cancel);
endtask : write_memory_coh
task chi_aiu_vseq::write_flush_cache(input addr_width_t addr, input bit[511:0] data,input int size, input chi_bfm_cache_state_t cache_state);
    chi_rn_traffic_cmd_seq m_seq;
    chi_bfm_txn req_txn;
    chi_bfm_dat_t dat_txn;
    chi_bfm_rsp_t rsp_txn;
    chi_data_be_t m_info;
    chi_bfm_opcode_t opcode;
  //  int wr_data_cancel = m_args.k_writedatacancel_pct.get_value();
    int addr_mask;
    int addr_offset;			
    uvm_event txns_constructed;

    // FIXME - need to look at wSmiDPdata for data width
    addr_mask = wSmiDPdata/8 - 1;				   
    addr_offset = addr & addr_mask;

    if (cache_state == CHI_UC) begin
        opcode = BFM_WRITEEVICTFULL;
    end else if (cache_state == CHI_UD || cache_state == CHI_SD) begin
        opcode = BFM_WRITEBACKFULL;
    end else if (cache_state == CHI_UDP) begin
        opcode = BFM_WRITEBACKPTL;
    end

    txns_constructed = new("txns_constructed"); 
        m_seq = chi_rn_traffic_cmd_seq::type_id::create($psprintf("m_seq[%0d]", ID)); 
        m_seq.get_cmd_args(m_args);
      //  m_args.k_writedatacancel_pct.set_value(0);
          m_args.k_wr_cpybck_pct.set_value(100);
        `ASSERT(m_seq.randomize() with {
            m_tgtid == 0; m_lpid == 0 ; // TODO:Assuming it to be 0
            m_opcode_type == WR_CPYBCK_CMD; m_opcode == opcode;
	    m_addr_type == COH_ADDR; m_ewa == 1; m_new_addr == 0;
            m_order.m_order == NO_ORDER; m_seq.m_expcompack.m_expcompack == 0; 
          //m_snpattr == 0; m_start_state == CHI_IX; m_snoopme == 0;// constraint takes care of these,based on "m_opcode_type"
        });
        m_chi_container.cache_flush_addr = addr; 
        m_seq.cache_flush_start = 'h1;
        m_chi_container.construct_chi_txn(m_seq); // Creat chi_bfm_txn and put in "m_tx_req_chnl_cb"
        trigger_on_txns_done(txns_constructed);
        m_chi_container.get_txreq_chnl_txn(req_txn);
        push_txreq(req_txn); // This will create actual Chi_seq_item and push it to chi_txn_Seq to finally be driven


      //  m_seq.m_order.m_order = NO_ORDER;
      //  m_seq.m_expcompack.m_expcompack = 0;
      //  m_seq.m_size.m_size = size;

/*      2 Construct_chi_txn
        m_chi_container.construct_chi_txn(m_seq); // Creat chi_bfm_txn and put in "m_tx_req_chnl_cb"
        3 Get the TXReq Chnl TXN snd Push in TXREQ_Q
        m_chi_container.get_txreq_chnl_txn(req_txn); // pop from the "m_tx_req_chnl_cb" chi_bfm_txn type
	// hack - remove txn from pending order queue
	m_chi_container.del_entry_in_req_ordq_if_any(req_txn.m_req_txnid);
        req_txn.m_req_ns = 0;
        req_txn.m_req_addr = addr;
        push_txreq(req_txn); // This will create actual Chi_seq_item and push it to chi_txn_Seq to finally be driven
        4 Get the CResp with DBID( Assuming "The separate DBIDResp and Comp" and not "The combined CompDBIDResp")
        pop_rxrsp(rsp_txn);
        m_chi_container.put_rxrsp_chnl_txn(rsp_txn);

       5 Give the write data and put in the container
        dat_txn.m_info = new(WBE);
          for (int i = 0; i < m_chi_container.pow2(req_txn.m_req_size); ++i) begin
        // for (int i = 0; i < 64; ++i) begin
            m_info.m_data[i+addr_offset] = data[(i*8)+:8];
            m_info.m_be[i+addr_offset]   = 1;
				   end
				   
        m_chi_container.get_txdat_chnl_txn(dat_txn); // gives m_tx_dat_chnl_cb.get_chi_txn(dat_txn/chi_bfm_txn)
        dat_txn.m_info.m_dataid.delete();// To remove the entry, created in m_chi_container->put_rxrsp_chnl_txn->initiate_wr_data
        dat_txn.m_info.set_txdat_info(
            0,//m_chi_container.get_ccid(req_txn.m_req_addr),
            m_chi_container.num_beats(req_txn.m_req_addr & 6'h3F, req_txn.m_req_size),
            m_info.m_data,
            m_info.m_be
        );
        push_txdat(dat_txn);
        6 Get the CResp for Comp
        pop_rxrsp(rsp_txn);
        m_chi_container.put_rxrsp_chnl_txn(rsp_txn);

        m_args.k_writedatacancel_pct.set_value(wr_data_cancel); */
endtask : write_flush_cache

task chi_aiu_vseq::read_memory(input addr_width_t addr, output bit[511:0] data, input int size, input int width);
    chi_rn_traffic_cmd_seq m_seq;
    chi_bfm_txn req_txn;
    chi_bfm_dat_t dat_txn;
    chi_bfm_rsp_t rsp_txn;
    chi_data_be_t m_info;
    bit [511:0] m_data;
    bit [63:0] m_be;
    bit [1:0] m_resp_err;
    int addr_mask;
    int addr_offset;			
    bit [511:0] temp_data;

    // FIXME - need to look at wSmiDPdata for data width
    addr_mask = wSmiDPdata/8 - 1;				   
    addr_offset = addr & addr_mask;

// For Read:
//   push_txreq // t2_th
//   pop_rxdat  // t6_th
//   pop_rxrsp  // t5_th
//      1 Create seq_item
        m_seq = chi_rn_traffic_cmd_seq::type_id::create($psprintf("m_seq[%0d]", ID)); // Need to randomize
        m_seq.get_cmd_args(m_args);
        `ASSERT(m_seq.randomize() with {
            m_tgtid == 0; m_lpid == 0 ; // TODO:Assuming it to be 0
            m_opcode_type == RD_NONCOH_CMD; m_opcode == BFM_READNOSNP;
            m_addr_type == NON_COH_ADDR; m_ewa == 0; m_new_addr == 0;
          //m_snpattr == 0; m_start_state == CHI_IX; m_snoopme == 0;// constraint takes care of these,based on "m_opcode_type"
        });
        m_seq.m_order.m_order = REQUEST_ORDER;
        m_seq.m_expcompack.m_expcompack = 0;
        m_seq.m_size.m_size = size;
        //No need to make commands exclusive during boot sequence.
        if($test$plusargs("en_excl_txn") || $test$plusargs("en_excl_noncoh_txn")) begin
            m_seq.m_excl.m_excl = 0;
        end
//      2 Construct_chi_txn
        m_chi_container.construct_chi_txn(m_seq); // Creat chi_bfm_txn and put in "m_tx_req_chnl_cb"
        `uvm_info("READ_CSR", m_seq.convert2string(), UVM_LOW);
//      3 Get the TXReq Chnl TXN snd Push in TXREQ_Q
        m_chi_container.get_txreq_chnl_txn(req_txn); // pop from the "m_tx_req_chnl_cb" chi_bfm_txn type
	// hack - remove txn from pending order queue
	m_chi_container.del_entry_in_req_ordq_if_any(req_txn.m_req_txnid);
        req_txn.m_req_ns = 0;
        req_txn.m_req_addr = addr;
        push_txreq(req_txn); // This will create actual Chi_seq_item and push it to chi_txn_Seq to finally be driven

//      4 Get the read data and put in the container
        pop_rxdat(dat_txn);
        m_data = dat_txn.m_info.get_tx_data(0);
        m_be = dat_txn.m_info.get_tx_be(0);
        m_resp_err = dat_txn.m_resp.get_resp_err();

        if(m_resp_err != m_seq.m_excl.m_excl) begin
            `uvm_error("READ_CSR",$sformatf("Resp_err :0x%0h on Read Data",m_resp_err))
        end

        temp_data = 512'b0;

        if (width == 128) begin
           if (size == 5) begin
              pop_rxdat(dat_txn);
              temp_data[255:128] = dat_txn.m_info.get_tx_data(0);
           end
           if (size == 6) begin
              pop_rxdat(dat_txn);
              temp_data[255:128] = dat_txn.m_info.get_tx_data(0);
              pop_rxdat(dat_txn);
              temp_data[383:256] = dat_txn.m_info.get_tx_data(0);
              pop_rxdat(dat_txn);
              temp_data[511:384] = dat_txn.m_info.get_tx_data(0);
           end
        end

        if ((size == 6) && (width == 256)) begin
           pop_rxdat(dat_txn);
           temp_data[511:256] = dat_txn.m_info.get_tx_data(0);
        end
                   
        m_data = m_data | temp_data;

	m_data = m_data >> (addr_offset*8);				   
        for (int i = 0; i < m_chi_container.pow2(req_txn.m_req_size); i++) begin
        // for (int i = 0; i < 64; i++) begin
            data[(i*8)+:8] = m_data[(i*8)+:8];
            if(m_be[i] != 1)
                `uvm_info("READ_CSR",$sformatf("Read Data ByteEn[%0d] is 0",i),UVM_LOW)
        end
        m_chi_container.put_rxdat_chnl_txn(dat_txn);
//
//      5 Get the read response , Cresp with READRECEIPT
        pop_rxrsp(rsp_txn);
        m_chi_container.put_rxrsp_chnl_txn(rsp_txn);
	endtask : read_memory

task chi_aiu_vseq::read_memory_coh(input addr_width_t addr, output bit[511:0] data, input int size, input int width, input bit align_data_as_per_ccid=0);
    chi_rn_traffic_cmd_seq m_seq;
    chi_bfm_txn req_txn;
    chi_bfm_dat_t dat_txn;
    chi_bfm_rsp_t rsp_txn;
    chi_data_be_t m_info;
    bit [511:0] m_data;
    bit [511:0] m_data1;
    bit [63:0] m_be;
    bit [1:0] m_resp_err;
    int addr_mask;
    int addr_offset;			
    bit [511:0] temp_data;

    // FIXME - need to look at wSmiDPdata for data width
    addr_mask = wSmiDPdata/8 - 1;				   
    addr_offset = addr & addr_mask;

// For Read:
//   push_txreq // t2_th
//   pop_rxdat  // t6_th
//   pop_rxrsp  // t5_th
//      1 Create seq_item
        m_seq = chi_rn_traffic_cmd_seq::type_id::create($psprintf("m_seq[%0d]", ID)); // Need to randomize
        m_seq.get_cmd_args(m_args);
        `ASSERT(m_seq.randomize() with {
            m_tgtid == 0; m_lpid == 0 ; // TODO:Assuming it to be 0
            m_opcode_type == RD_RDONCE_CMD; m_opcode == BFM_READONCE;
            m_addr_type == COH_ADDR; m_ewa == 1; m_new_addr == 0;
          //m_snpattr == 0; m_start_state == CHI_IX; m_snoopme == 0;// constraint takes care of these,based on "m_opcode_type"
        });
        m_seq.m_order.m_order = REQUEST_ORDER;
        m_seq.m_expcompack.m_expcompack = 0;
        m_seq.m_size.m_size = size;
        //No need to make commands exclusive during boot sequence.
        if($test$plusargs("en_excl_txn") || $test$plusargs("en_excl_noncoh_txn")) begin
            m_seq.m_excl.m_excl = 0;
        end
//      2 Construct_chi_txn
        m_seq.m_start_state = CHI_IX;
        m_chi_container.construct_chi_txn(m_seq); // Creat chi_bfm_txn and put in "m_tx_req_chnl_cb"
        `uvm_info("READ_CSR", m_seq.convert2string(), UVM_LOW);
//      3 Get the TXReq Chnl TXN snd Push in TXREQ_Q
        m_chi_container.get_txreq_chnl_txn(req_txn); // pop from the "m_tx_req_chnl_cb" chi_bfm_txn type
	// hack - remove txn from pending order queue
	m_chi_container.del_entry_in_req_ordq_if_any(req_txn.m_req_txnid);
        req_txn.m_req_ns = 0;
        req_txn.m_req_addr = addr;
        push_txreq(req_txn); // This will create actual Chi_seq_item and push it to chi_txn_Seq to finally be driven

//      4 Get the read data and put in the container
        pop_rxdat(dat_txn);
        m_data = dat_txn.m_info.get_tx_data(0);
        m_be = dat_txn.m_info.get_tx_be(0);
        m_resp_err = dat_txn.m_resp.get_resp_err();

        if(m_resp_err != m_seq.m_excl.m_excl) begin
            `uvm_error("READ_CSR",$sformatf("Resp_err :0x%0h on Read Data",m_resp_err))
        end

        temp_data = 512'b0;

        if (width == 128) begin
           if (size == 5) begin
              pop_rxdat(dat_txn);
              temp_data[255:128] = dat_txn.m_info.get_tx_data(0);
           end
           if (size == 6) begin
              pop_rxdat(dat_txn);
              temp_data[255:128] = dat_txn.m_info.get_tx_data(0);
              pop_rxdat(dat_txn);
              temp_data[383:256] = dat_txn.m_info.get_tx_data(0);
              pop_rxdat(dat_txn);
              temp_data[511:384] = dat_txn.m_info.get_tx_data(0);
           end
        end

        if ((width == 256) && (size == 6)) begin
           pop_rxdat(dat_txn);
           temp_data[511:256] = dat_txn.m_info.get_tx_data(0);
        end

        m_data = m_data | temp_data;

        //`uvm_info("READ_COH",$sformatf("Before right-shift m_data %0h",m_data),UVM_LOW)
	//m_data = m_data >> (addr_offset*8);				   
        //`uvm_info("READ_COH",$sformatf("After right-shift m_data %0h",m_data),UVM_LOW)
        for (int i = 0; i < m_chi_container.pow2(req_txn.m_req_size); i++) begin
        // for (int i = 0; i < 64; i++) begin
            data[(i*8)+:8] = m_data[(i*8)+:8];
            if(m_be[i] != 1)
                `uvm_info("READ_CSR",$sformatf("Read Data ByteEn[%0d] is 0",i),UVM_LOW)
        end
        m_chi_container.put_rxdat_chnl_txn(dat_txn);
//
//      5 Get the read response , Cresp with READRECEIPT
        pop_rxrsp(rsp_txn);
        m_chi_container.put_rxrsp_chnl_txn(rsp_txn);

//Align the data as per ccid
if(align_data_as_per_ccid==1) begin
        temp_data = 0;
        if (width == 128) begin
           if (size == 5) begin
              //temp_data[255:128] = dat_txn.m_info.get_tx_data(0);
           end
           if (size == 6) begin
               if(addr[5:4]==1) begin
                  temp_data[255:128] = data[127:0];
                  temp_data[383:256] = data[255:128];
                  temp_data[511:384] = data[383:256];
                  temp_data[127:0]   = data[511:384];
                  data = temp_data;
               end else if (addr[5:4]==2) begin
                  temp_data[511:256] = data[255:0];
                  temp_data[255:0]   = data[511:256];
                  data = temp_data;
               end else if (addr[5:4]==3) begin
                  temp_data[127:0]   = data[255:128];
                  temp_data[255:128] = data[383:256];
                  temp_data[383:256] = data[511:384];
                  temp_data[511:384] = data[127:0];
                  data = temp_data;
               end
           end
        end

        if ((width == 256) && (size == 6)) begin
           if (addr[5]==1'b1) begin
              temp_data[511:256] = data[255:0];
              temp_data[255:0]   = data[511:256];
              data = temp_data;
           end
        end
end

        `uvm_info("VS", "READ EXITING", UVM_LOW)
	endtask : read_memory_coh

task chi_aiu_vseq::read_coh(input addr_width_t addr, output bit[31:0] data);
    chi_rn_traffic_cmd_seq m_seq;
    chi_bfm_txn req_txn;
    chi_bfm_dat_t dat_txn;
    chi_bfm_rsp_t rsp_txn;
    chi_data_be_t m_info;
    bit [511:0] m_data;
    bit [63:0] m_be;
    int addr_mask;
    int addr_offset;			

    // FIXME - need to look at wSmiDPdata for data width
    addr_mask = wSmiDPdata/8 - 1;				   
    addr_offset = addr & addr_mask;

// For Read:
//   push_txreq // t2_th
//   pop_rxdat  // t6_th
//   push_txrsp // t3_th
//      1 Create seq_item
        m_seq = chi_rn_traffic_cmd_seq::type_id::create($psprintf("m_seq[%0d]", ID)); // Need to randomize
        m_seq.get_cmd_args(m_args);
        `ASSERT(m_seq.randomize() with {
            m_tgtid == 0; m_lpid == 0 ; // TODO:Assuming it to be 0
            m_opcode_type == RD_LDRSTR_CMD; m_opcode == BFM_READUNIQUE;
            m_addr_type == COH_ADDR; m_new_addr == 0;
          //m_mem_type == NORMAL;m_ewa == 1; m_snpattr == 1; m_start_state == CHI_IX; m_snoopme == 0;// constraint takes care of these,based on "m_opcode_type"
        });
        //m_seq.m_order.m_order = REQUEST_ORDER;// ?? To check
	m_seq.m_expcompack.m_expcompack = 1;
        m_seq.m_size.m_size = 2;
//      2 Construct_chi_txn
        m_chi_container.construct_chi_txn(m_seq); // Creat chi_bfm_txn and put in "m_tx_req_chnl_cb"
        `uvm_info("READ_COH", m_seq.convert2string(), UVM_MEDIUM);
//      3 Get the TXReq Chnl TXN snd Push in TXREQ_Q
        m_chi_container.get_txreq_chnl_txn(req_txn); // pop from the "m_tx_req_chnl_cb" chi_bfm_txn type
	// hack - remove txn from pending order queue
	m_chi_container.del_entry_in_req_ordq_if_any(req_txn.m_req_txnid);
        req_txn.m_req_ns = 0;
        req_txn.m_req_addr = addr;
        push_txreq(req_txn); // This will create actual Chi_seq_item and push it to chi_txn_Seq to finally be driven

//      4 Get the read data and put in the container
        pop_rxdat(dat_txn);
        m_data = dat_txn.m_info.get_tx_data(0);
        m_be = dat_txn.m_info.get_tx_be(0);

	m_data = m_data >> (addr_offset*8);				   
        for (int i = 0; i < m_chi_container.pow2(req_txn.m_req_size); i++) begin
            data[(i*8)+:8] = m_data[(i*8)+:8];
            if(m_be[i] != 1)
                `uvm_info("READ_COH",$sformatf("Read Data ByteEn[%0d] is 0",i),UVM_LOW)
        end
        m_chi_container.put_rxdat_chnl_txn(dat_txn);
//
//      5 Give the CompAck Cresp 
        m_chi_container.get_txrsp_chnl_txn(rsp_txn);
        push_txrsp(rsp_txn);
//        pop_rxrsp(rsp_txn);
//        m_chi_container.put_rxrsp_chnl_txn(rsp_txn);
endtask : read_coh

task chi_aiu_vseq::chi_trace_capture_program(input bit[31:0] trace_capture_queue[$]);
    addr_width_t addr;
    bit [31:0] write_data;
    bit [7:0] rpn;
    bit [7:0] aiu_rpn;
    bit [7:0] dce_rpn;
    bit [7:0] dmi_rpn;
    bit [7:0] dii_rpn;

    int queue_idx = 0;

    // set csrBaseAddr
    addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE;
    aiu_rpn = 0;
    dce_rpn = aiu_rpn + <%=obj.nAIUs%>;
    dmi_rpn = dce_rpn + <%=obj.nDCEs%>;
    dii_rpn = dmi_rpn + <%=obj.nDMIs%>;

    // program CCTRLR for AIUs					   
    addr[11:0] = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUCCTRLR.get_offset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUCCTRLR.get_offset()<%}%>;
    write_data = <% if(numChiAiu) {%>m_regs.<%=chiaiu0%>.CAIUCCTRLR.get_reset()<%} else {%>m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUCCTRLR.get_reset()<%}%>;

<% for(var unit = 0; unit < obj.nAIUs; unit++) { %>
    write_data[7:0] = trace_capture_queue[queue_idx];
    if(write_data[7:0] > 0) begin
       addr[19:12] = aiu_rpn + <%=unit%>;
       `uvm_info("chi_trace_capture_program", $sformatf("Writing AIU<%=unit%>.XAIUCCTRLR = 0x%0h", write_data), UVM_MEDIUM)
       write_csr(addr, write_data);
    end
    queue_idx++;
<% } %>   

<% if(obj.nDMIs > 0) { %>
    // program CCTRLR for DMIs					   
    addr[11:0] = m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.DMICCTRLR.get_offset();
    write_data = m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.DMICCTRLR.get_reset() & 32'hFFFF_FF00;

<% for(var unit = 0; unit < obj.nDMIs; unit++) { %>
    write_data[7:0] = trace_capture_queue[queue_idx];
    if(write_data[7:0] > 0) begin
       addr[19:12] = dmi_rpn + <%=unit%>;
       `uvm_info("chi_trace_capture_en", $sformatf("Writing DMI<%=unit%>.DMICCTRLR = 0x%0h", write_data), UVM_MEDIUM)
       write_csr(addr, write_data);
    end
    queue_idx++;
<% } } %>   

<% if(obj.nDIIs > 1) { %>
    // program CCTRLR for DIIs					   
    addr[11:0] = m_regs.<%=obj.DiiInfo[0].strRtlNamePrefix%>.DIICCTRLR.get_offset();
    write_data = m_regs.<%=obj.DiiInfo[0].strRtlNamePrefix%>.DIICCTRLR.get_reset() & 32'hFFFF_FF00;

<% for(var unit = 0; unit < obj.nDIIs; unit++) { %>
    write_data[7:0] = trace_capture_queue[queue_idx];
    if(write_data[7:0] > 0) begin
       addr[19:12] = dii_rpn + <%=unit%>;
       `uvm_info("chi_trace_capture_en", $sformatf("Writing DII<%=unit%>.DIICCTRLR = 0x%0h", write_data), UVM_MEDIUM)
       write_csr(addr, write_data);
    end
    queue_idx++;
<% } } %>   

endtask: chi_trace_capture_program

task chi_aiu_vseq::chi_trace_accum_check(input bit[31:0] trace_capture_queue[$]);
    addr_width_t addr;
    bit [31:0] read_data;
    bit [7:0] dve_rpn;

    bit [31:0] aiu_trace_capture;
    bit [31:0] dmi_trace_capture;
    bit [31:0] dii_trace_capture;

    int trace_capture_enabled = 0; 

    foreach(trace_capture_queue[queue_idx]) begin
        trace_capture_enabled = trace_capture_enabled | (trace_capture_queue[queue_idx] & 8'hFF);
    end

    // set csrBaseAddr				  								
    addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE;
    dve_rpn = <%=obj.nAIUs%> + <%=obj.nDCEs%> + <%=obj.nDMIs%> + <%=obj.nDIIs%>;

    // read DVE TASCR					   
    addr[19:12] = dve_rpn;
    addr[11:0]  = m_regs.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETASCR.get_offset();
    read_csr(addr, read_data);

    if((trace_capture_enabled == 0) && (read_data[0]==0))
       `uvm_error("chi_trace_accum_check", "Trace Capture is not enabled and Trace Accum buffer is not empty")
  
    if((trace_capture_enabled != 0) && (read_data[0]==1))
       `uvm_error("chi_trace_accum_check", "Trace Capture is enabled and Trace Accum buffer is empty")

endtask: chi_trace_accum_check

task chi_aiu_vseq::chi_trace_trigger_program(input bit[31:0] trace_trigger_queue[$]);
    addr_width_t addr;
    bit [31:0] write_data;
    bit [7:0] aiu_rpn;

    int queue_idx = 0;

    // set csrBaseAddr
    addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE;
    aiu_rpn = 0;

<% for(var unit = 0; unit < obj.nAIUs; unit++) { %>
   addr[19:12] = aiu_rpn + <%=unit%>;

<% for(var set=0; set<obj.AiuInfo[unit].nTraceRegisters; set++) { %>

<% if ((obj.AiuInfo[unit].fnNativeInterface.includes('CHI'))) { %>
    addr[11:0] = m_regs.<%=chiaiu0%>.CAIUTBALR<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE') { %>
    addr[11:0] = m_regs.<%=aceaiu0%>.XAIUTBALR<%=set%>.get_offset();
<% } else { %>
    addr[11:0] = m_regs.<%=ncaiu0%>.XAIUTBALR<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("chi_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.XAIUTBALR[<%=set%>] = 0x%0h", write_data), UVM_MEDIUM)
    write_csr(addr, write_data);
    queue_idx++;

<% if ((obj.AiuInfo[unit].fnNativeInterface.includes('CHI'))) { %>
    addr[11:0] = m_regs.<%=chiaiu0%>.CAIUTBAHR<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE') { %>
    addr[11:0] = m_regs.<%=aceaiu0%>.XAIUTBAHR<%=set%>.get_offset();
<% } else { %>
    addr[11:0] = m_regs.<%=ncaiu0%>.XAIUTBAHR<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("chi_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.XAIUTBAHR[<%=set%>] = 0x%0h", write_data), UVM_MEDIUM)
    write_csr(addr, write_data);
    queue_idx++;

<% if ((obj.AiuInfo[unit].fnNativeInterface.includes('CHI'))) { %>
    addr[11:0] = m_regs.<%=chiaiu0%>.CAIUTOPCR0<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE') { %>
    addr[11:0] = m_regs.<%=aceaiu0%>.XAIUTOPCR0<%=set%>.get_offset();
<% } else { %>
    addr[11:0] = m_regs.<%=ncaiu0%>.XAIUTOPCR0<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("chi_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.XAIUTOPCR0[<%=set%>] = 0x%0h", write_data), UVM_MEDIUM)
    write_csr(addr, write_data);
    queue_idx++;

<% if ((obj.AiuInfo[unit].fnNativeInterface.includes('CHI'))) { %>
    addr[11:0] = m_regs.<%=chiaiu0%>.CAIUTOPCR1<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE') { %>
    addr[11:0] = m_regs.<%=aceaiu0%>.XAIUTOPCR1<%=set%>.get_offset();
<% } else { %>
    addr[11:0] = m_regs.<%=ncaiu0%>.XAIUTOPCR1<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("chi_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.XAIUTOPCR1[<%=set%>] = 0x%0h", write_data), UVM_MEDIUM)
    write_csr(addr, write_data);
    queue_idx++;

<% if ((obj.AiuInfo[unit].fnNativeInterface.includes('CHI'))) { %>
    addr[11:0] = m_regs.<%=chiaiu0%>.CAIUTUBR<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE') { %>
    addr[11:0] = m_regs.<%=aceaiu0%>.XAIUTUBR<%=set%>.get_offset();
<% } else { %>
    addr[11:0] = m_regs.<%=ncaiu0%>.XAIUTUBR<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("chi_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.XAIUTUBR[<%=set%>] = 0x%0h", write_data), UVM_MEDIUM)
    write_csr(addr, write_data);
    queue_idx++;

<% if ((obj.AiuInfo[unit].fnNativeInterface.includes('CHI'))) { %>
    addr[11:0] = m_regs.<%=chiaiu0%>.CAIUTUBMR<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE') { %>
    addr[11:0] = m_regs.<%=aceaiu0%>.XAIUTUBMR<%=set%>.get_offset();
<% } else { %>
    addr[11:0] = m_regs.<%=ncaiu0%>.XAIUTUBMR<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("chi_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.XAIUTUBMR[<%=set%>] = 0x%0h", write_data), UVM_MEDIUM)
    write_csr(addr, write_data);
    queue_idx++;

<% if ((obj.AiuInfo[unit].fnNativeInterface.includes('CHI'))) { %>
    addr[11:0] = m_regs.<%=chiaiu0%>.CAIUTCTRLR<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE') { %>
    addr[11:0] = m_regs.<%=aceaiu0%>.XAIUTCTRLR<%=set%>.get_offset();
<% } else { %>
    addr[11:0] = m_regs.<%=ncaiu0%>.XAIUTCTRLR<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("chi_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.XAIUTCTRLR[<%=set%>] = 0x%0h", write_data), UVM_MEDIUM)
    write_csr(addr, write_data);
    queue_idx++;

<% }
} %>   

endtask: chi_trace_trigger_program

<% } %>
